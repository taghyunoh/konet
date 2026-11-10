/* =====================================================================
   매입/매출 거래처 — 거래유형을 전부 「매입&매출」로 (2026-11-10 사용자 「거래유형을 매입+매출로 모두 변경」)

   대상 : TBL_VENDOR_MST 사용 중(ACTION_YN='Y') 거래처 402곳 중 「매입&매출」이 아닌 것
          조회 당시(2026-11-10) = 매입 84 · 매출 294 → 378곳 바뀜 (이미 매입&매출 24곳은 그대로)
          삭제된 거래처(ACTION_YN='N' 36곳)는 손대지 않는다.
   영향 : 화면의 거래처 고르기는 VENDOR_GB 에 '매입'/'매출' 이 «들어 있는지»로 거른다(LIKE).
          → 바꾼 뒤에는 매입 화면(매입등록·매입가·재고입고)에도 매출 거래처가, 매출 화면에도 매입 거래처가 함께 나온다.
          거래처 관리의 [매입처]·[매출처] 탭도 모두 402곳이 된다.

   실행 순서 : ① 확인 → ② 백업 → ③ 고치기 → ④ 확인.  되돌리기는 맨 아래.
   ===================================================================== */

-- ① 확인 — 지금 거래유형별 수 (사용 중만)
SELECT VENDOR_GB, COUNT(*) AS 수
  FROM TBL_VENDOR_MST
 WHERE ACTION_YN = 'Y'
 GROUP BY VENDOR_GB
 ORDER BY VENDOR_GB;
-- 기대 : 매입 84 · 매입&매출 24 · 매출 294 (합 402)

-- ② 백업 — 거래유형만 (이미 있으면 건너뛴다)
IF OBJECT_ID('dbo.TBL_VENDOR_MST_GB_BAK_20261110', 'U') IS NULL
  SELECT COMP_CD, VENDOR_CD, VENDOR_GB, UPD_DTTM, UPD_USER
    INTO dbo.TBL_VENDOR_MST_GB_BAK_20261110
    FROM TBL_VENDOR_MST
   WHERE ACTION_YN = 'Y' AND ISNULL(VENDOR_GB, '') <> N'매입&매출';
-- 기대 : 378개 행

-- ③ 고치기
UPDATE TBL_VENDOR_MST
   SET VENDOR_GB = N'매입&매출',
       UPD_DTTM  = CONVERT(VARCHAR(19), GETDATE(), 120),
       UPD_USER  = 'fix20261110'
 WHERE ACTION_YN = 'Y'
   AND ISNULL(VENDOR_GB, '') <> N'매입&매출';
-- 기대 : (378개 행 적용됨)

-- ④ 확인 — 사용 중 거래처가 모두 매입&매출
SELECT VENDOR_GB, COUNT(*) AS 수
  FROM TBL_VENDOR_MST
 WHERE ACTION_YN = 'Y'
 GROUP BY VENDOR_GB;
-- 기대 : 매입&매출 402

/* ── 되돌리기(필요할 때만) ─────────────────────────────────────────
UPDATE m SET m.VENDOR_GB = b.VENDOR_GB, m.UPD_DTTM = b.UPD_DTTM, m.UPD_USER = b.UPD_USER
  FROM TBL_VENDOR_MST m
  JOIN dbo.TBL_VENDOR_MST_GB_BAK_20261110 b ON b.COMP_CD = m.COMP_CD AND b.VENDOR_CD = m.VENDOR_CD;
──────────────────────────────────────────────────────────────────── */
