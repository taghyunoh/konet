-- =====================================================================
-- 출고자료 기준 사업장 일괄 생성 — 직송(ZONE='직송')만 (2026-08-06, 사용자 확정)
--   TBL_SHIPOUT_MST 에는 있는데 TBL_BIZI_MST 에 없는 사업장을 코드·이름만 만든다.
--   · 이름 = 그 사업장의 **가장 최근 출고 줄**의 BIZ_NM (같은 코드로 이름이 바뀐 이력 대비)
--   · 주소·전화·택배정보는 넣지 않는다 — 주소는 별도 저장(사용자 확정 2026-08-06)
--   · 이미 있으면 건드리지 않는다(이름도 안 덮어씀)
--   ★부작용(확인됨): 출고현황표(대시보드) 묶음이 이 사업장들에 한해
--     품목 괄호 브랜드 → 사업장명으로 바뀐다(분류 규칙: BIZI 에 있으면 사업장명 우선).
--   되돌리려면 : UPDATE TBL_BIZI_MST SET ACTION_YN='N' WHERE REG_USER='shipout_auto';
-- =====================================================================
CREATE TABLE #N (BIZ_CD NVARCHAR(40) COLLATE DATABASE_DEFAULT, BIZ_NM NVARCHAR(200) COLLATE DATABASE_DEFAULT);

INSERT INTO #N (BIZ_CD, BIZ_NM)
SELECT x.BIZ_CD, x.BIZ_NM
  FROM (
        SELECT s.BIZ_CD, s.BIZ_NM,
               ROW_NUMBER() OVER (PARTITION BY s.BIZ_CD
                                  ORDER BY s.SHPOUT_DT DESC, s.SEQ DESC) AS rn
          FROM TBL_SHIPOUT_MST s
         WHERE s.ACTION_YN = 'Y'
           AND s.ZONE = N'직송'
           AND ISNULL(s.BIZ_CD,'') <> ''
           AND ISNULL(s.BIZ_NM,'') <> ''
           AND NOT EXISTS (SELECT 1 FROM TBL_BIZI_MST b WHERE b.BIZ_CD = s.BIZ_CD)
       ) x
 WHERE x.rn = 1;

INSERT INTO dbo.TBL_BIZI_MST (COMP_CD, BIZ_CD, JOB_SEQ, ACTION_YN, BIZ_NM, REG_DTTM, REG_USER)
SELECT 'W1234567', n.BIZ_CD, 1, 'Y', n.BIZ_NM, GETDATE(), N'shipout_auto'
  FROM #N n
 WHERE NOT EXISTS (SELECT 1 FROM dbo.TBL_BIZI_MST b WHERE b.BIZ_CD = n.BIZ_CD);

SELECT COUNT(*) AS 신규등록 FROM dbo.TBL_BIZI_MST WHERE REG_USER = N'shipout_auto';
SELECT COUNT(DISTINCT s.BIZ_CD) AS 남은직송누락
  FROM TBL_SHIPOUT_MST s
 WHERE s.ACTION_YN='Y' AND s.ZONE=N'직송' AND ISNULL(s.BIZ_CD,'')<>''
   AND NOT EXISTS (SELECT 1 FROM TBL_BIZI_MST b WHERE b.BIZ_CD = s.BIZ_CD);
DROP TABLE #N;
