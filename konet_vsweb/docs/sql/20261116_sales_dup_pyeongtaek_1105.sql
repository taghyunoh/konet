/* =====================================================================
   정산서 중복 정리 — 2026-11-05 납품 평택 (2026-11-16 사용자 「평택(1) 남고」)

   상황 : 11-05 납품 평택 정산서가 두 번 올라와 있다(둘 다 K002).
            ① 「평택」     11-05 09:30 업로드 · 파일 2026.11.05_평택.xlsx      52줄 · 4,721,139원
            ② 「평택 (1)」 11-10 16:34 업로드 · 파일 2026.11.05_평택 (1).xlsx  54줄 · 16,993,539원
          ①의 52줄은 ②에 전부 같은 값으로 있다(주문번호·품목·수량·단가·정산금액·입고일·납품유형 52쌍 모두 일치).
          ②는 그 52줄 + 새 2줄(호호솥밥 252·240박스, 12,272,400원).
          → 매출이 4,721,139원 두 번 잡혀 있고, 재고 원장(정산서 몫은 그날 활성 정산서를 품목별로 합산)도 그 52품목이 두 번 빠져 있다.
   조치 : ①의 52줄을 사용 안 함(ACTION_YN='N')으로. 지우지 않는다. ②는 그대로 남는다(출고장 이름은 「평택 (1)」).
   ⚠재고 : SQL 은 정산서만 고친다. 실행 뒤 화면에서 재고현황 ▸ [🔄 출고반영 재집계] 를 한 번 눌러야
          11-05 정산서 원장이 다시 만들어져 52품목의 이중 차감이 풀린다(앱이 쓰는 같은 규칙으로 다시 만든다).

   실행 순서 : ① 확인 → ② 백업 → ③ 고치기 → ④ 확인 → ⑤ [출고반영 재집계].  되돌리기는 맨 아래.
   ===================================================================== */

-- ① 확인 — 출고장별 줄 수·금액 (기대 : 평택 52 · 4,721,139 / 평택 (1) 54 · 16,993,539)
SELECT DC_NM, REG_USER, LEFT(REG_DTTM, 16) AS 올린시각, COUNT(*) AS 줄, SUM(SALE_AMT) AS 금액
  FROM TBL_SALES_MST
 WHERE ACTION_YN = 'Y' AND ISNULL(NULLIF(DLV_DT, ''), OUT_DT) = '20261105' AND DC_NM IN (N'평택', N'평택 (1)')
 GROUP BY DC_NM, REG_USER, LEFT(REG_DTTM, 16);

-- 정리 대상 — 「평택 (1)」에 같은 줄이 있는 「평택」 줄만 (기대 : 52줄 · 4,721,139)
SELECT COUNT(*) AS 대상, SUM(a.SALE_AMT) AS 금액
  FROM TBL_SALES_MST a
 WHERE a.ACTION_YN = 'Y' AND a.DC_NM = N'평택'
   AND ISNULL(NULLIF(a.DLV_DT, ''), a.OUT_DT) = '20261105' AND LEFT(a.REG_DTTM, 16) = '2026-11-05 09:30'
   AND EXISTS (SELECT 1 FROM TBL_SALES_MST b
                WHERE b.ACTION_YN = 'Y' AND b.DC_NM = N'평택 (1)'
                  AND b.ORD_NO = a.ORD_NO AND b.ITEM_CD = a.ITEM_CD
                  AND ISNULL(b.ORD_ITEM_NO, '') = ISNULL(a.ORD_ITEM_NO, '')
                  AND ISNULL(b.OUT_QTY, 0) = ISNULL(a.OUT_QTY, 0));

-- ② 백업 (이미 있으면 건너뛴다)
IF OBJECT_ID('dbo.BAK_20261116_SALES_PT1105', 'U') IS NULL
  SELECT * INTO dbo.BAK_20261116_SALES_PT1105
    FROM TBL_SALES_MST
   WHERE ACTION_YN = 'Y' AND DC_NM = N'평택'
     AND ISNULL(NULLIF(DLV_DT, ''), OUT_DT) = '20261105' AND LEFT(REG_DTTM, 16) = '2026-11-05 09:30';
-- 기대 : 52개 행

-- ③ 고치기
BEGIN TRAN;

UPDATE a
   SET a.ACTION_YN = 'N',
       a.UPD_DTTM  = CONVERT(VARCHAR(19), GETDATE(), 120),
       a.UPD_USER  = 'fix20261116',
       a.UPD_IP    = 'sql-dup-pt1105'
  FROM TBL_SALES_MST a
 WHERE a.ACTION_YN = 'Y' AND a.DC_NM = N'평택'
   AND ISNULL(NULLIF(a.DLV_DT, ''), a.OUT_DT) = '20261105' AND LEFT(a.REG_DTTM, 16) = '2026-11-05 09:30'
   AND EXISTS (SELECT 1 FROM TBL_SALES_MST b
                WHERE b.ACTION_YN = 'Y' AND b.DC_NM = N'평택 (1)'
                  AND b.ORD_NO = a.ORD_NO AND b.ITEM_CD = a.ITEM_CD
                  AND ISNULL(b.ORD_ITEM_NO, '') = ISNULL(a.ORD_ITEM_NO, '')
                  AND ISNULL(b.OUT_QTY, 0) = ISNULL(a.OUT_QTY, 0));
-- 기대 : (52개 행 적용됨) — 아니면 아래 ROLLBACK

COMMIT;
-- ROLLBACK;

-- ④ 확인 — 평택은 0줄, 평택 (1) 54줄 그대로
SELECT DC_NM, COUNT(*) AS 줄, SUM(SALE_AMT) AS 금액
  FROM TBL_SALES_MST
 WHERE ACTION_YN = 'Y' AND ISNULL(NULLIF(DLV_DT, ''), OUT_DT) = '20261105' AND DC_NM IN (N'평택', N'평택 (1)')
 GROUP BY DC_NM;

-- ⑤ 화면 : 재고 관리 ▸ 재고현황 ▸ [🔄 출고반영 재집계] (11-05 정산서 원장을 다시 만든다)

/* ── 되돌리기(필요할 때만 — 되돌린 뒤에도 [출고반영 재집계]) ─────────────────
UPDATE m SET m.ACTION_YN = b.ACTION_YN, m.UPD_DTTM = b.UPD_DTTM, m.UPD_USER = b.UPD_USER, m.UPD_IP = b.UPD_IP
  FROM TBL_SALES_MST m JOIN dbo.BAK_20261116_SALES_PT1105 b ON b.SALES_SEQ = m.SALES_SEQ;
──────────────────────────────────────────────────────────────────── */
