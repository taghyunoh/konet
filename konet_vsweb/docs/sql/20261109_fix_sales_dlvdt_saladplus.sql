/* =====================================================================
   판매전표 납품일자 바로잡기 — 샐러드 플러스(001554) 2025년 12월 5건 (2026-11-09)

   증상 : 수금등록·거래처 원장에서 샐러드 플러스 12월 매출이 안 보이고, 2026-01-08 한 줄(3,923,540)에 합쳐져 보인다.
   원인 : 11-08 새벽 01-08 전표를 불러와 판매일자만 12월로 바꿔 저장하면서 납품일자(DLV_DT)가 20260108 로 따라갔다.
          원장은 납품일자를 먼저 쓰므로(없으면 판매일자) 5건이 모두 01-08 로 들어갔다.
   범위 : DB 전체에서 납품일자 ≠ 판매일자인 판매전표는 이 5건뿐이다(2026-11-09 조회).
   재고 : 판매전표의 재고 원장 줄은 이미 판매일자(20251202 등)로 들어가 있어 손대지 않는다.
   조치 : 5건의 DLV_DT 를 SALE_DT 와 같게. 금액·품목·재고는 바뀌지 않는다.

   실행 순서 : ① 확인 → ② 백업 → ③ 고치기 → ④ 확인.  되돌리기는 맨 아래.
   ===================================================================== */

-- ① 확인 — 5줄, DLV_DT 가 모두 20260108 이어야 한다
SELECT SALE_SEQ, SALE_DT, SALE_NO, DLV_DT, CUST_CD, CUST_NM, TOT_AMT, REG_DTTM
  FROM TBL_SALES_TRX_MST
 WHERE ACTION_YN = 'Y' AND CUST_CD = '001554'
   AND SALE_SEQ IN (162, 163, 164, 165, 166)
 ORDER BY SALE_DT;

-- ② 백업 (이미 있으면 건너뛴다)
IF OBJECT_ID('dbo.TBL_SALES_TRX_MST_BAK_20261109', 'U') IS NULL
  SELECT * INTO dbo.TBL_SALES_TRX_MST_BAK_20261109
    FROM TBL_SALES_TRX_MST
   WHERE SALE_SEQ IN (162, 163, 164, 165, 166);

-- ③ 고치기 — 판매일자가 2025-12 이고 납품일자가 20260108 인 줄만(다른 줄은 걸리지 않는다)
UPDATE TBL_SALES_TRX_MST
   SET DLV_DT   = SALE_DT,
       UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120),
       UPD_USER = 'fix20261109'
 WHERE ACTION_YN = 'Y' AND CUST_CD = '001554'
   AND SALE_SEQ IN (162, 163, 164, 165, 166)
   AND SALE_DT LIKE '202512%'
   AND DLV_DT = '20260108';
-- 기대 : (5개 행 적용됨)

-- ④ 확인 — 납품일자 = 판매일자, 그리고 DB 전체에 어긋난 전표가 0건
SELECT SALE_SEQ, SALE_DT, SALE_NO, DLV_DT, TOT_AMT, UPD_USER
  FROM TBL_SALES_TRX_MST
 WHERE SALE_SEQ IN (162, 163, 164, 165, 166)
 ORDER BY SALE_DT;

SELECT COUNT(*) AS 남은_어긋남
  FROM TBL_SALES_TRX_MST
 WHERE ACTION_YN = 'Y' AND ISNULL(DLV_DT, '') <> '' AND DLV_DT <> SALE_DT;
-- 기대 : 0

/* ── 되돌리기(필요할 때만) ─────────────────────────────────────────
UPDATE m SET m.DLV_DT = b.DLV_DT, m.UPD_DTTM = b.UPD_DTTM, m.UPD_USER = b.UPD_USER
  FROM TBL_SALES_TRX_MST m
  JOIN dbo.TBL_SALES_TRX_MST_BAK_20261109 b ON b.SALE_SEQ = m.SALE_SEQ;
──────────────────────────────────────────────────────────────────── */
