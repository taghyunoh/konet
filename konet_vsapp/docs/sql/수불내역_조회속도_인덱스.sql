/* =====================================================================
   재고현황 ②수불내역 조회 속도 개선 — 인덱스 추가
   ---------------------------------------------------------------------
   증상 (2026-08-06 실측)
     · 상단 품목을 누르면 하단이 늦게 뜬다.
     · 화면 콘솔 : [수불내역] prodSeq=8 · 서버 1345ms · 그리기 4ms · 전체 72건
       → 그리기는 4ms. **서버가 전부**다.
     · 서버에서 직접 재보니 560ms (5회 반복 모두 550~580ms, 34KB / 72행)

   원인 — selectStockLedgerList (User_SQL.xml) 안의 **행별 서브쿼리 2개**
     ① 사업장명 : REF_GB='SHIPOUT' 인 행마다 TBL_SHIPOUT_MST 를 FOR XML 로 훑는다
     ② 거래처명 : 행마다 TBL_VENDOR_MST 에서 VENDOR_NM 을 찾는다
     72행이면 이 서브쿼리가 72번 돈다. 행 수가 아니라 **한 행당 비용**이 문제라
     조회 건수를 줄여도(기간 1개월) 서버 시간은 별로 안 준다.

   조치 — 쿼리를 고치기 전에 **인덱스부터** 본다. 세 개면 대개 끝난다.
     쿼리 재작성(OUTER APPLY 등)은 결과가 달라질 위험이 있어 인덱스로 안 되면 그때 한다.

   실행 위치 : SSMS → saynice.co.kr → KOLGSDB
   영향      : 인덱스 추가는 조회 결과를 바꾸지 않는다. 다만 아래 [주의] 참고.
   ===================================================================== */
USE KOLGSDB;
GO

/* ── 1. 지금 인덱스가 무엇이 있나 (먼저 확인) ───────────────────── */
SELECT t.name AS 테이블, i.name AS 인덱스, i.type_desc AS 종류,
       STUFF((SELECT ', ' + c.name
                FROM sys.index_columns ic2
                JOIN sys.columns c ON c.object_id = ic2.object_id AND c.column_id = ic2.column_id
               WHERE ic2.object_id = i.object_id AND ic2.index_id = i.index_id AND ic2.is_included_column = 0
               ORDER BY ic2.key_ordinal FOR XML PATH('')), 1, 2, '') AS 키컬럼
  FROM sys.indexes i
  JOIN sys.tables t ON t.object_id = i.object_id
 WHERE t.name IN ('TBL_STOCK_LEDGER','TBL_SHIPOUT_MST','TBL_VENDOR_MST')
   AND i.type > 0
 ORDER BY t.name, i.index_id;
GO

/* ── 2. 표 크기 (인덱스 만드는 시간을 가늠) ─────────────────────── */
SELECT 'TBL_STOCK_LEDGER' AS 테이블, COUNT(*) AS 행수 FROM TBL_STOCK_LEDGER
UNION ALL SELECT 'TBL_SHIPOUT_MST', COUNT(*) FROM TBL_SHIPOUT_MST
UNION ALL SELECT 'TBL_VENDOR_MST',  COUNT(*) FROM TBL_VENDOR_MST;
GO


/* =====================================================================
   3. 인덱스 3개 — 하나씩 만들고 그때마다 화면에서 재 볼 것
   ---------------------------------------------------------------------
   ★가장 효과가 큰 것은 (가) 다. 여기서 끝나는 경우가 많다.
   ===================================================================== */

/* (가) 사업장명 서브쿼리용 — 이 화면 느림의 주범
       WHERE PROD_CD = … AND SHPOUT_DT = … 로 찾고, BIZ_NM·CUR_QTY 를 읽는다.
       INCLUDE 로 읽는 칸까지 넣어 두면 원본 표를 다시 안 봐도 된다. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SHIPOUT_PRODCD_DT' AND object_id=OBJECT_ID('dbo.TBL_SHIPOUT_MST'))
    CREATE NONCLUSTERED INDEX IX_SHIPOUT_PRODCD_DT
        ON dbo.TBL_SHIPOUT_MST (PROD_CD, SHPOUT_DT)
        INCLUDE (BIZ_NM, CUR_QTY, COMP_CD, ACTION_YN);
GO

/* (나) 원장 본체 — WHERE PROD_SEQ = … AND ACTION_YN='Y' ORDER BY TRX_DT DESC */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_LEDGER_PRODSEQ' AND object_id=OBJECT_ID('dbo.TBL_STOCK_LEDGER'))
    CREATE NONCLUSTERED INDEX IX_LEDGER_PRODSEQ
        ON dbo.TBL_STOCK_LEDGER (PROD_SEQ, ACTION_YN, TRX_DT DESC);
GO

/* (다) 거래처명 서브쿼리용 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VENDOR_CD_ACT' AND object_id=OBJECT_ID('dbo.TBL_VENDOR_MST'))
    CREATE NONCLUSTERED INDEX IX_VENDOR_CD_ACT
        ON dbo.TBL_VENDOR_MST (VENDOR_CD, ACTION_YN, COMP_CD)
        INCLUDE (VENDOR_NM);
GO


/* ── 4. 효과 확인 — 인덱스 만든 뒤 이걸 돌려 본다 ───────────────
     화면(F12 콘솔)의 '서버 xxxms' 와 견줘 본다. 1345ms → 100ms 안쪽이면 성공. */
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO
-- prodSeq 는 화면 콘솔에 찍힌 값을 넣는다 (예: 8)
DECLARE @seq INT = 8;
SELECT COUNT(*) AS 행수 FROM TBL_STOCK_LEDGER WHERE PROD_SEQ=@seq AND ACTION_YN='Y';
GO
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


/* =====================================================================
   [주의] 인덱스를 만들 때 알아 둘 것
   ---------------------------------------------------------------------
   · 만드는 동안 그 표에 **잠금**이 걸린다. 표가 크면 그동안 출고·매입 등록이 잠시 멈춘다.
     → 업무시간을 피해서 하는 게 안전하다. (2번 결과로 행수를 먼저 볼 것)
   · 인덱스는 **입력·수정을 아주 조금 느리게** 한다. 조회가 훨씬 잦은 표라 남는 장사지만,
     효과가 없으면 아래로 지우고 원래대로 둔다 :
        DROP INDEX IX_SHIPOUT_PRODCD_DT ON dbo.TBL_SHIPOUT_MST;
        DROP INDEX IX_LEDGER_PRODSEQ    ON dbo.TBL_STOCK_LEDGER;
        DROP INDEX IX_VENDOR_CD_ACT     ON dbo.TBL_VENDOR_MST;
   · ★인덱스로 충분히 안 빨라지면 그다음은 **쿼리 재작성**이다 —
     사업장명 서브쿼리를 OUTER APPLY 로 한 번만 돌게 바꾸는 방법.
     결과가 달라질 위험이 있어 인덱스를 먼저 시도한다.
   ===================================================================== */
