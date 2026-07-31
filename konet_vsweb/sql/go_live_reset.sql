/* ============================================================================
   가동(운영 개시) 전 데이터 초기화 스크립트                        2026-07-31
   ----------------------------------------------------------------------------
   ★★ 실행 전에 반드시 읽어 주세요 ★★

   1) 이 스크립트는 '거래 데이터'를 지웁니다. 되돌릴 수 없습니다.
      실행 전에 DB 전체 백업을 먼저 받으세요.
          BACKUP DATABASE KOLGSDB TO DISK='D:\backup\KOLGSDB_golive.bak' WITH INIT, COMPRESSION;

   2) 기준정보(상품·거래처·사업장·공통코드·회사·사용자)는 지우지 않습니다.
      그것까지 비우려면 맨 아래 [구역 3]의 주석을 직접 푸세요.

   3) 대상 DB 가 맞는지 먼저 확인하세요. 아래 한 줄을 돌려 KOLGSDB 가 나와야 합니다.
          SELECT DB_NAME();

   4) 사용자가 시스템을 쓰고 있지 않을 때 실행하세요.
      TRUNCATE 는 테이블 잠금을 잡습니다.

   ----------------------------------------------------------------------------
   실행 시점의 자료 현황 (2026-07-31 실측)

     [거울 데이터 — 지웁니다]
       TBL_SHIPOUT_MST          45,095   발주현황표 업로드(출고)
       TBL_STOCK_LEDGER         16,366   재고 수불원장
       TBL_SALES_MST             5,534   정산서 엑셀 업로드(매출)
       TBL_PROD_SALEPRICE_HST    1,994   판매단가 이력 (1,993건이 정산서 업로드 파생)
       TBL_STOCK_MST               562   현재고 집계(원장에서 파생)
       TBL_PURCHASE_DTL             72   매입전표 명세
       TBL_PROD_INPRICE_HST         68   매입단가 이력 (전부 매입전표 파생)
       TBL_PURCHASE_MST              2   매입전표
       TBL_SETTLE_TRX                1   수금/지급 전표
       TBL_CLOSING_MST               1   마감
       TBL_SALES_TRX_MST/DTL         0   판매전표
       TBL_CLOSING_STOCK             0   재고마감
       TBL_SETTLE_CLOSE_MST          0   정산마감
       TBL_RECEIVE_MST               0   수금/미수금(월) — 안 쓰는 표
       TBL_PAYMENT_MST               0   출금/미지급(월) — 안 쓰는 표

     [기준정보 — 남깁니다]
       TBL_PROD_MST              1,940   상품 (매입가 1,632 · 판매가 1,516 보유)
       TBL_BIZI_MST              1,373   사업장
       TBL_VENDOR_MST              432   거래처
       TBL_CODE_MST/DTL          10/42   공통코드
       TBL_COMP_MST/COMPCONT_MST   6/2   회사·계약
       TBL_USER_MST                  2   사용자

   ----------------------------------------------------------------------------
   왜 TRUNCATE 인가
     · 이 DB 에는 외래키(FK)가 하나도 없어 TRUNCATE 가 가능합니다(2026-07-31 확인).
     · DELETE 보다 훨씬 빠르고 로그를 적게 씁니다(SHIPOUT 45,095행).
     · IDENTITY 가 자동으로 초기화되어 전표번호·SEQ 가 1 부터 다시 시작합니다.
       → 별도의 DBCC CHECKIDENT 가 필요 없습니다.

   함께 지워야 하는 짝
     · 재고원장(STOCK_LEDGER) 을 지우면 현재고(STOCK_MST) 도 반드시 같이 지웁니다.
       원장은 비었는데 현재고만 남으면 유령 재고가 됩니다.
     · 매입전표(PURCHASE_MST) 와 명세(PURCHASE_DTL) 는 한 쌍입니다.
     · 판매전표(SALES_TRX_MST) 와 명세(SALES_TRX_DTL) 도 한 쌍입니다.
   ============================================================================ */

SET NOCOUNT ON;

/* ── 0. 대상 확인 — 여기서 멈춰 눈으로 보세요 ───────────────────────────── */
PRINT '대상 DB : ' + DB_NAME();
PRINT '실행 시각 : ' + CONVERT(VARCHAR(19), GETDATE(), 120);
PRINT '';

IF DB_NAME() <> 'KOLGSDB'
BEGIN
    RAISERROR('대상 DB 가 KOLGSDB 가 아닙니다. 스크립트를 멈춥니다.', 16, 1);
    SET NOEXEC ON;
END
GO

/* ── 1. 삭제 전 건수 ────────────────────────────────────────────────────── */
PRINT '=== 삭제 전 ===';
SELECT '삭제대상' AS 구분, t.name AS 테이블, SUM(p.rows) AS 행수
  FROM sys.tables t
  JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
 WHERE t.name IN ('TBL_SHIPOUT_MST','TBL_SALES_MST','TBL_STOCK_LEDGER','TBL_STOCK_MST',
                  'TBL_PURCHASE_MST','TBL_PURCHASE_DTL','TBL_SALES_TRX_MST','TBL_SALES_TRX_DTL',
                  'TBL_SETTLE_TRX','TBL_PROD_INPRICE_HST','TBL_PROD_SALEPRICE_HST',
                  'TBL_CLOSING_MST','TBL_CLOSING_STOCK','TBL_SETTLE_CLOSE_MST',
                  'TBL_RECEIVE_MST','TBL_PAYMENT_MST')
 GROUP BY t.name
 ORDER BY 행수 DESC;
GO


/* ============================================================================
   [구역 1] 거래 데이터 삭제 — 이 구역이 '가동 초기화'의 본체입니다
   ============================================================================ */
BEGIN TRY
    BEGIN TRAN;

    -- ① 업로드 원본 (출고 · 정산서)
    TRUNCATE TABLE TBL_SHIPOUT_MST;          -- 발주현황표
    TRUNCATE TABLE TBL_SALES_MST;            -- 정산서(매출 엑셀)

    -- ② 전표 (매입 · 판매 · 수금/지급)
    TRUNCATE TABLE TBL_PURCHASE_DTL;
    TRUNCATE TABLE TBL_PURCHASE_MST;
    TRUNCATE TABLE TBL_SALES_TRX_DTL;
    TRUNCATE TABLE TBL_SALES_TRX_MST;
    TRUNCATE TABLE TBL_SETTLE_TRX;           -- 수금(RCV) · 지급(PAY) 공용

    -- ③ 전표에서 파생된 것 — 원본을 지웠으니 반드시 함께 지운다
    TRUNCATE TABLE TBL_STOCK_LEDGER;         -- 재고 수불원장
    TRUNCATE TABLE TBL_STOCK_MST;            -- 현재고(원장 재집계 결과)
    TRUNCATE TABLE TBL_PROD_INPRICE_HST;     -- 매입단가 이력 (매입전표가 만든다)
    TRUNCATE TABLE TBL_PROD_SALEPRICE_HST;   -- 판매단가 이력 (정산서 업로드·판매전표가 만든다)

    -- ④ 마감
    TRUNCATE TABLE TBL_CLOSING_MST;          -- 매출/매입 마감
    TRUNCATE TABLE TBL_CLOSING_STOCK;        -- 재고 마감
    TRUNCATE TABLE TBL_SETTLE_CLOSE_MST;     -- 정산(수금/지급) 마감

    -- ⑤ 안 쓰는 월 단위 표 (메뉴에서 내렸지만 표는 남겨둔 것)
    TRUNCATE TABLE TBL_RECEIVE_MST;
    TRUNCATE TABLE TBL_PAYMENT_MST;

    COMMIT TRAN;
    PRINT '';
    PRINT '[구역 1] 거래 데이터 삭제 완료 — 커밋했습니다.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT '';
    PRINT '[구역 1] 실패 — 롤백했습니다. 아무것도 지워지지 않았습니다.';
    PRINT '오류 : ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO


/* ============================================================================
   [구역 2] 상품마스터의 파생 단가 초기화 — 선택 사항 (기본은 실행 안 함)

     상품마스터의 IN_PRICE / SALE_PRICE 는 이력이 쌓일 때 함께 갱신되는 칸입니다.
     이력을 비웠으니 이 값도 0 으로 돌릴지 정해야 합니다.

       그대로 두면  : 마감·매출내역의 단가 근거가 '이력' 대신 '마스터'로 잡힙니다.
                      금액이 0 이 되지 않아 가동 첫 달부터 숫자가 나옵니다.  ← 권장
       0 으로 돌리면: 매입·판매 전표를 넣기 전까지 단가가 없어 마감 금액이 0 이 되고
                      '매입가없음' 배지가 대량으로 뜹니다.

     지금 보유 현황 : 매입가 1,632 품목 · 판매가 1,516 품목 (전체 1,940)
     ★ 쓰던 단가를 그대로 살려 가동하려면 이 구역을 건드리지 마세요.
   ============================================================================ */
-- UPDATE TBL_PROD_MST SET IN_PRICE = 0, SALE_PRICE = 0, WHOLE_PRICE = 0
--  WHERE ACTION_YN = 'Y';
-- PRINT '[구역 2] 상품마스터 단가 초기화 완료';
GO


/* ============================================================================
   [구역 3] 기준정보까지 비우기 — 선택 사항 (기본은 실행 안 함)

     완전히 빈 상태로 시작할 때만 쓰세요. 지우면 상품·거래처를 다시 올려야 합니다.

     · TBL_BIZI_MST(사업장 1,373) 은 발주현황표를 올릴 때 자동으로 채워집니다.
       출고 자료를 비웠으니 함께 비워도 되고, 두면 다음 업로드 때 그대로 재사용됩니다.
     · TBL_USER_MST / TBL_COMP_MST 를 지우면 ★로그인이 안 됩니다★. 손대지 마세요.
   ============================================================================ */
-- TRUNCATE TABLE TBL_BIZI_MST;     -- 사업장 (업로드 시 자동 재생성됨)
-- TRUNCATE TABLE TBL_VENDOR_MST;   -- 거래처 (거래처리스트.xls 재업로드 필요)
-- TRUNCATE TABLE TBL_PROD_MST;     -- 상품   (상품마스터 재등록 필요)
GO


/* ── 4. 삭제 후 확인 ────────────────────────────────────────────────────── */
PRINT '';
PRINT '=== 삭제 후 ===';
SELECT CASE WHEN t.name IN ('TBL_PROD_MST','TBL_VENDOR_MST','TBL_BIZI_MST','TBL_CODE_MST',
                            'TBL_CODE_DTL','TBL_COMP_MST','TBL_COMPCONT_MST','TBL_USER_MST')
            THEN '기준정보(유지)' ELSE '거래데이터(초기화)' END AS 구분,
       t.name AS 테이블,
       SUM(p.rows) AS 행수,
       IDENT_CURRENT(t.name) AS 다음SEQ기준
  FROM sys.tables t
  JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
 GROUP BY t.name
 ORDER BY 1, 3 DESC;

PRINT '';
PRINT '남은 거래 데이터가 있으면 아래가 0 이 아닙니다 (0 이어야 정상)';
SELECT (SELECT COUNT(*) FROM TBL_SHIPOUT_MST)
     + (SELECT COUNT(*) FROM TBL_SALES_MST)
     + (SELECT COUNT(*) FROM TBL_STOCK_LEDGER)
     + (SELECT COUNT(*) FROM TBL_STOCK_MST)
     + (SELECT COUNT(*) FROM TBL_PURCHASE_MST)
     + (SELECT COUNT(*) FROM TBL_SALES_TRX_MST)
     + (SELECT COUNT(*) FROM TBL_SETTLE_TRX) AS 남은거래행수;
GO

SET NOEXEC OFF;
GO

/* ============================================================================
   가동 후 첫 점검 (이 스크립트 실행 뒤 화면에서 확인)

     1. 출고현황표(대시보드)      → 자료 없음. 발주현황표 엑셀 업로드부터 시작
     2. 출고현황이력조회          → 업로드 이력 0건. 첫 업로드 후 1차로 잡히는지
     3. 재고현황                  → 전 품목 0. 매입등록하면 늘어나는지
     4. 매입등록 · 판매등록       → 전표번호가 yyyymmdd-0001 부터 시작하는지
     5. 수금등록 · 지급등록       → 전표번호 0001, 거래처 원장 빈 상태인지
     6. 마감현황(월계표)          → 0원. 자료를 넣으면 숫자가 도는지
     7. 매출 그래프(월별/일자별)  → [조회] 눌러 빈 그래프가 정상 표시되는지

   되돌리려면 : 백업본을 복원하는 방법뿐입니다.
       RESTORE DATABASE KOLGSDB FROM DISK='D:\backup\KOLGSDB_golive.bak' WITH REPLACE;
   ============================================================================ */
