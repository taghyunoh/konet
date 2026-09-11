/* ============================================================================
   TBL_BIZI_MST 채우기 — 발주현황표에 나왔는데 등록 안 된 사업장          2026-08-28
   ----------------------------------------------------------------------------
   왜 : 업로드 자동등록이 「품목명이 ( 로 시작하면 제외」였던 탓에
        배고픈덮밥이·파스타입니다·명동피자 … 576곳이 등록된 적이 없다.
        거래처관리 목록에 없으니 <공통 매칭코드를 줄 수가 없다>.
        (업로드 쪽 규칙은 2026-08-28 에 없앴다 — 이 스크립트는 그동안 쌓인 것을 한 번에 채운다)

   무엇 : TBL_SHIPOUT_MST 활성분(ACTION_YN='Y')에 나온 사업장코드 중
          TBL_BIZI_MST 에 없는 것만 INSERT. 기존 행은 <절대> 건드리지 않는다.
   이름 : 사업장코드 하나에 이름이 여러 개인 곳이 14곳 있다 → <가장 최근 자료의 이름>을 쓴다.

   실행 : SSMS 등에서 KOLGSDB 에 ①확인 → ②등록 → ③검증 순서로.
          ①만 돌려 보고 숫자가 납득되면 ②를 돌리면 된다. 여러 번 돌려도 안전(NOT EXISTS).
   되돌리기 : 맨 아래 주석 참고.
   ============================================================================ */

USE KOLGSDB;
GO

/* ── ① 먼저 확인 (읽기만 한다) ─────────────────────────────────────────── */
;WITH miss AS (
    SELECT  s.BIZ_CD,
            COMP_CD = ISNULL(NULLIF(LTRIM(RTRIM(MAX(s.COMP_CD))),''),'W1234567'),
            BIZ_NM  = MAX(CASE WHEN s.rn = 1 THEN LTRIM(RTRIM(ISNULL(s.BIZ_NM,''))) END),
            행수    = COUNT(*)
      FROM ( SELECT BIZ_CD, BIZ_NM, COMP_CD,
                    rn = ROW_NUMBER() OVER (PARTITION BY BIZ_CD
                                            ORDER BY DLV_DT DESC, REG_DTTM DESC)
               FROM dbo.TBL_SHIPOUT_MST
              WHERE ACTION_YN = 'Y' AND ISNULL(BIZ_CD,'') <> '' ) s
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.TBL_BIZI_MST b
                         WHERE b.BIZ_CD = s.BIZ_CD AND ISNULL(b.ACTION_YN,'Y') = 'Y' )
     GROUP BY s.BIZ_CD
)
SELECT COUNT(*) AS 넣을사업장수, SUM(행수) AS 관련발주행수 FROM miss;
GO

/* 목록도 눈으로 보고 싶으면 (상위 30곳) */
;WITH miss AS (
    SELECT  s.BIZ_CD,
            COMP_CD = ISNULL(NULLIF(LTRIM(RTRIM(MAX(s.COMP_CD))),''),'W1234567'),
            BIZ_NM  = MAX(CASE WHEN s.rn = 1 THEN LTRIM(RTRIM(ISNULL(s.BIZ_NM,''))) END),
            행수    = COUNT(*)
      FROM ( SELECT BIZ_CD, BIZ_NM, COMP_CD,
                    rn = ROW_NUMBER() OVER (PARTITION BY BIZ_CD
                                            ORDER BY DLV_DT DESC, REG_DTTM DESC)
               FROM dbo.TBL_SHIPOUT_MST
              WHERE ACTION_YN = 'Y' AND ISNULL(BIZ_CD,'') <> '' ) s
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.TBL_BIZI_MST b
                         WHERE b.BIZ_CD = s.BIZ_CD AND ISNULL(b.ACTION_YN,'Y') = 'Y' )
     GROUP BY s.BIZ_CD
)
SELECT TOP 30 BIZ_CD, BIZ_NM, COMP_CD, 행수 FROM miss ORDER BY 행수 DESC;
GO

/* ── ② 등록 ────────────────────────────────────────────────────────────
      · 없는 것만 넣는다(NOT EXISTS) — 여러 번 돌려도 중복이 안 생긴다.
      · JOB_SEQ=1 / ACTION_YN='Y' — 앱의 자동등록(insertBiziIfAbsent)과 같은 값.
      · REG_USER 를 'BACKFILL-20260828' 로 남긴다 → 나중에 이 스크립트로 들어온 것만 추릴 수 있다. */
;WITH miss AS (
    SELECT  s.BIZ_CD,
            COMP_CD = ISNULL(NULLIF(LTRIM(RTRIM(MAX(s.COMP_CD))),''),'W1234567'),
            BIZ_NM  = MAX(CASE WHEN s.rn = 1 THEN LTRIM(RTRIM(ISNULL(s.BIZ_NM,''))) END)
      FROM ( SELECT BIZ_CD, BIZ_NM, COMP_CD,
                    rn = ROW_NUMBER() OVER (PARTITION BY BIZ_CD
                                            ORDER BY DLV_DT DESC, REG_DTTM DESC)
               FROM dbo.TBL_SHIPOUT_MST
              WHERE ACTION_YN = 'Y' AND ISNULL(BIZ_CD,'') <> '' ) s
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.TBL_BIZI_MST b
                         WHERE b.BIZ_CD = s.BIZ_CD AND ISNULL(b.ACTION_YN,'Y') = 'Y' )
     GROUP BY s.BIZ_CD
)
INSERT INTO dbo.TBL_BIZI_MST (COMP_CD, BIZ_CD, JOB_SEQ, ACTION_YN, BIZ_NM, REG_DTTM, REG_USER, REG_IP)
SELECT m.COMP_CD, m.BIZ_CD, 1, 'Y', m.BIZ_NM, GETDATE(), 'BACKFILL-20260828', 'SCRIPT'
  FROM miss m
 WHERE NOT EXISTS ( SELECT 1 FROM dbo.TBL_BIZI_MST t
                     WHERE t.BIZ_CD = m.BIZ_CD AND t.COMP_CD = m.COMP_CD );
GO

/* ── ③ 검증 ──────────────────────────────────────────────────────────── */
SELECT '이번에 넣은 수' AS 항목, COUNT(*) AS 값
  FROM dbo.TBL_BIZI_MST WHERE REG_USER = 'BACKFILL-20260828'
UNION ALL
SELECT '아직 안 들어간 사업장(0이어야 정상)', COUNT(*) FROM (
    SELECT DISTINCT s.BIZ_CD FROM dbo.TBL_SHIPOUT_MST s
     WHERE s.ACTION_YN='Y' AND ISNULL(s.BIZ_CD,'')<>''
       AND NOT EXISTS (SELECT 1 FROM dbo.TBL_BIZI_MST b
                        WHERE b.BIZ_CD=s.BIZ_CD AND ISNULL(b.ACTION_YN,'Y')='Y') ) x
UNION ALL
SELECT '이름이 빈 채로 들어간 것(0이어야 정상)', COUNT(*)
  FROM dbo.TBL_BIZI_MST WHERE REG_USER='BACKFILL-20260828' AND ISNULL(LTRIM(RTRIM(BIZ_NM)),'')=''
UNION ALL
SELECT '거래처관리 전체(활성)', COUNT(*) FROM dbo.TBL_BIZI_MST WHERE ISNULL(ACTION_YN,'Y')='Y';
GO

/* ── 되돌리기 (이 스크립트로 넣은 것만 지운다. 그 사이 매칭코드를 준 것이 있으면 같이 사라지니 주의) ──
DELETE FROM dbo.TBL_BIZI_MST WHERE REG_USER = 'BACKFILL-20260828';
   ──────────────────────────────────────────────────────────────────── */
