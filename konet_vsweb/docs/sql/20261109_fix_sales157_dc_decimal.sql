/* =====================================================================
   판매전표 157 할인 소수점 바로잡기 — 우리푸드(001532) 2025-12-02 (2026-11-09)

   증상 : 전표 합계가 3,438,851.5 로 소수점이 있다(원장에는 반올림해 3,438,852 로 보임).
   원인 : 6번째 줄(DTL_SEQ 1404, JB303 5칸)의 할인 칸에 -0.5 가 들어가
          금액 = 21 × 50,104 − (−0.5) = 1,052,184.5 로 저장됐다. (판매전표 전체에서 소수 금액은 이 한 줄뿐)
          화면은 같은 날 할인을 원 단위 정수로 반올림하게 고쳤다(salesReg.jsp saCalcRow).
   조치 : 그 줄의 할인 0 → 금액·공급가 1,052,184 · 부가세 105,218(그대로) · 줄 합계 1,157,402
          전표 머리 공급가 3,126,229 · 부가세 312,622(그대로) · 합계 3,438,851
   영향 : 수량은 그대로라 재고 원장(TBL_STOCK_LEDGER)은 손대지 않는다. 원장·수금·매출 집계는 전표를 바로 읽으므로 따라 바뀐다.
          거래처 잔고가 1원 줄어든다(3,438,852 로 보이던 것이 3,438,851).

   실행 순서 : ① 확인 → ② 백업 → ③ 고치기 → ④ 확인.  되돌리기는 맨 아래.
   ===================================================================== */

-- ① 확인 — 줄 1건(DC −0.50 · 합계 1,157,402.50), 머리 1건(공급가 3,126,229.50 · 합계 3,438,851.50)
SELECT DTL_SEQ, SALE_SEQ, ROW_NO, QTY, UNIT_PRICE, AMT, DC_AMT, SUPPLY_AMT, VAT_AMT, TOT_AMT, TRX_GB
  FROM TBL_SALES_TRX_DTL
 WHERE SALE_SEQ = 157 AND DTL_SEQ = 1404;

SELECT SALE_SEQ, SALE_DT, CUST_CD, SUPPLY_AMT, VAT_AMT, TOT_AMT, DC_AMT
  FROM TBL_SALES_TRX_MST
 WHERE SALE_SEQ = 157;

-- ② 백업 (이미 있으면 건너뛴다)
IF OBJECT_ID('dbo.TBL_SALES_TRX_DTL_BAK_20261109_157', 'U') IS NULL
  SELECT * INTO dbo.TBL_SALES_TRX_DTL_BAK_20261109_157 FROM TBL_SALES_TRX_DTL WHERE SALE_SEQ = 157;
IF OBJECT_ID('dbo.TBL_SALES_TRX_MST_BAK_20261109_157', 'U') IS NULL
  SELECT * INTO dbo.TBL_SALES_TRX_MST_BAK_20261109_157 FROM TBL_SALES_TRX_MST WHERE SALE_SEQ = 157;

-- ③ 고치기 — 지금 값이 그대로일 때만 걸린다(두 번 돌려도 안전)
BEGIN TRAN;

UPDATE TBL_SALES_TRX_DTL
   SET DC_AMT     = 0,
       AMT        = 1052184,
       SUPPLY_AMT = 1052184,
       VAT_AMT    = 105218,
       TOT_AMT    = 1157402,
       UPD_DTTM   = CONVERT(VARCHAR(19), GETDATE(), 120),
       UPD_USER   = 'fix20261109'
 WHERE SALE_SEQ = 157 AND DTL_SEQ = 1404
   AND DC_AMT = -0.50 AND AMT = 1052184.50 AND TOT_AMT = 1157402.50;
-- 기대 : (1개 행 적용됨)

UPDATE TBL_SALES_TRX_MST
   SET SUPPLY_AMT = 3126229,
       TOT_AMT    = 3438851,
       UPD_DTTM   = CONVERT(VARCHAR(19), GETDATE(), 120),
       UPD_USER   = 'fix20261109'
 WHERE SALE_SEQ = 157
   AND SUPPLY_AMT = 3126229.50 AND TOT_AMT = 3438851.50 AND VAT_AMT = 312622;
-- 기대 : (1개 행 적용됨)

-- 두 UPDATE 가 모두 1행이면 COMMIT, 아니면 ROLLBACK
COMMIT;
-- ROLLBACK;

-- ④ 확인 — 머리 = 줄 합계(반품 줄은 뺀다), 그리고 판매전표 전체에 소수 금액 0건
SELECT m.SALE_SEQ, m.SUPPLY_AMT, m.VAT_AMT, m.TOT_AMT,
       SUM(CASE WHEN d.TRX_GB IN (N'반품', N'불량반품') THEN -d.SUPPLY_AMT ELSE d.SUPPLY_AMT END) AS 줄_공급가,
       SUM(CASE WHEN d.TRX_GB IN (N'반품', N'불량반품') THEN -d.VAT_AMT    ELSE d.VAT_AMT    END) AS 줄_부가세,
       SUM(CASE WHEN d.TRX_GB IN (N'반품', N'불량반품') THEN -d.TOT_AMT    ELSE d.TOT_AMT    END) AS 줄_합계
  FROM TBL_SALES_TRX_MST m
  JOIN TBL_SALES_TRX_DTL d ON d.SALE_SEQ = m.SALE_SEQ AND d.ACTION_YN = 'Y'
 WHERE m.SALE_SEQ = 157
 GROUP BY m.SALE_SEQ, m.SUPPLY_AMT, m.VAT_AMT, m.TOT_AMT;
-- 기대 : 3,126,229 / 312,622 / 3,438,851 — 줄 합계와 같음

SELECT COUNT(*) AS 남은_소수금액
  FROM TBL_SALES_TRX_DTL d
  JOIN TBL_SALES_TRX_MST m ON m.SALE_SEQ = d.SALE_SEQ
 WHERE d.ACTION_YN = 'Y' AND m.ACTION_YN = 'Y'
   AND (d.AMT <> ROUND(d.AMT, 0) OR d.DC_AMT <> ROUND(d.DC_AMT, 0) OR d.TOT_AMT <> ROUND(d.TOT_AMT, 0)
        OR m.TOT_AMT <> ROUND(m.TOT_AMT, 0));
-- 기대 : 0

/* ── 되돌리기(필요할 때만) ─────────────────────────────────────────
UPDATE d SET d.DC_AMT = b.DC_AMT, d.AMT = b.AMT, d.SUPPLY_AMT = b.SUPPLY_AMT, d.VAT_AMT = b.VAT_AMT,
             d.TOT_AMT = b.TOT_AMT, d.UPD_DTTM = b.UPD_DTTM, d.UPD_USER = b.UPD_USER
  FROM TBL_SALES_TRX_DTL d JOIN dbo.TBL_SALES_TRX_DTL_BAK_20261109_157 b ON b.DTL_SEQ = d.DTL_SEQ;
UPDATE m SET m.SUPPLY_AMT = b.SUPPLY_AMT, m.TOT_AMT = b.TOT_AMT, m.UPD_DTTM = b.UPD_DTTM, m.UPD_USER = b.UPD_USER
  FROM TBL_SALES_TRX_MST m JOIN dbo.TBL_SALES_TRX_MST_BAK_20261109_157 b ON b.SALE_SEQ = m.SALE_SEQ;
──────────────────────────────────────────────────────────────────── */
