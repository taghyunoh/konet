/* ============================================================================================
   납기현황표(발주현황표 TBL_SHIPOUT_MST) 삭제 — «출고일자» 기준 (2026-11-24 사용자 「출고일자 발주현황표로 업로드한 것은 모두 삭제」 · 「9/21 모두 삭제, 9/22 김해·제주 삭제」)
   · 회사 W1234567
     - 출고일자 2026-09-21 : 전 센터
     - 출고일자 2026-09-22 : 김해(E300) · 제주(E600) — 납기일자 9/22(오늘 11:39 admin) + 9/23(9/21 17:52 K003) 둘 다
   · 방식 = 앱의 출고장 삭제(deleteShipoutZone, 출고일자+출고장 기준)와 같은 «소프트 삭제» : ACTION_YN 'Y' → 'D'
       줄을 지우지 않으므로 맨 아래 ④ 로 그대로 되돌릴 수 있다(UPD_USER 'del20261124' 가 표식).
   · 대상 = 살아 있는 발주현황표 줄(PROD_KIND TC). 토더·대상 발주(TD)·DC 발주는 발주현황표 업로드가 아니라 빼 두었다(9/21 토더 15줄 · 9/22 대상 14줄은 남는다).
   · 이미 닫힌 옛 차수(N)·지운 줄(D)은 건드리지 않는다.

   [2026-11-24 조회 기준 건수 — ① 을 먼저 돌려 같은지 확인]
     출고 9/21 : 용인 37 · 왜관 14 · 광주 4 · 평택 122 · 오산 16 (전부 오늘 11:35 admin, 납기 9/21)          = 193줄
     출고 9/22 : 김해 5 (납기 9/22, 오늘 11:39 admin) · 김해 13 (납기 9/23, 9/21 17:52 K003) · 제주 1 (납기 9/22, 오늘 11:39 admin) = 19줄
     합계 212줄
     ⚠남는 것 : 납기 9/21 김해 14줄 — 출고일자가 9/19(9/18 K001 업로드)라 «출고 9/21» 에 안 든다. 이것도 지우려면 ② 의 ㉠ 줄 주석을 푼다(212 + 14 = 226줄).

   [재고 영향] 납기 9/21 · 9/22 · 9/23 모두 정산서가 와 있어 재고 원장은 정산서로 잡혀 있다(발주현황표 TC 줄은 원장에 안 쓰인다) — 재고 숫자는 그대로다.
   [화면 영향] 지운 날·센터의 정산서는 짝 찾을 발주현황표가 없어져 월별 출고현황에서 「(정산서·발주없음)」 으로 보이고, 표 위 알림 줄에 다시 뜬다.
   ============================================================================================ */

/* ① 확인 — 지울 줄 (출고일자·납기일자·센터별) */
SELECT SHPOUT_DT AS 출고일자, DLV_DT AS 납기일자, ISNULL(DC_CD,'') AS 센터, MAX(DC_NM) AS 센터명, ISNULL(PROD_KIND,'') AS 종류,
       COUNT(*) AS 줄수, MIN(CONVERT(VARCHAR(16), REG_DTTM, 120)) AS 등록, MAX(REG_USER) AS 등록자
  FROM TBL_SHIPOUT_MST
 WHERE COMP_CD = 'W1234567'
   AND ACTION_YN = 'Y'
   AND ISNULL(PROD_KIND,'') NOT IN ('DC','TD')
   AND (    SHPOUT_DT = '20260921'
        OR ( SHPOUT_DT = '20260922' AND UPPER(LTRIM(RTRIM(ISNULL(DC_CD,'')))) IN ('E300','E600') ) )
 GROUP BY SHPOUT_DT, DLV_DT, ISNULL(DC_CD,''), ISNULL(PROD_KIND,'')
 ORDER BY 1, 2, 3;

/* ② 삭제 */
BEGIN TRAN;

UPDATE TBL_SHIPOUT_MST
   SET ACTION_YN = 'D', UPD_DTTM = GETDATE(), UPD_USER = 'del20261124', UPD_IP = 'sql'
 WHERE COMP_CD = 'W1234567'
   AND ACTION_YN = 'Y'
   AND ISNULL(PROD_KIND,'') NOT IN ('DC','TD')
   AND (    SHPOUT_DT = '20260921'
        OR ( SHPOUT_DT = '20260922' AND UPPER(LTRIM(RTRIM(ISNULL(DC_CD,'')))) IN ('E300','E600') )
--      OR ( DLV_DT = '20260921' AND UPPER(LTRIM(RTRIM(ISNULL(DC_CD,'')))) = 'E300' )   /* ㉠ 납기 9/21 김해(출고 9/19) 14줄까지 지우려면 이 줄 주석을 푼다 */
       )
;
/* 위 결과 «영향 받은 행» 이 212 (㉠ 을 풀었으면 226) 이면 COMMIT, 아니면 ROLLBACK */
-- COMMIT;
-- ROLLBACK;

/* ③ 확인 — 출고 9/21 은 토더(TD) 15줄만 Y, 출고 9/22 는 김해·제주가 D 이고 용인·왜관·광주·평택·오산·대상은 Y 그대로 */
SELECT SHPOUT_DT AS 출고일자, DLV_DT AS 납기일자, ISNULL(DC_CD,'') AS 센터, ACTION_YN, ISNULL(PROD_KIND,'') AS 종류, COUNT(*) AS 줄수
  FROM TBL_SHIPOUT_MST
 WHERE COMP_CD = 'W1234567' AND SHPOUT_DT IN ('20260921', '20260922')
   AND ACTION_YN IN ('Y','D')
 GROUP BY SHPOUT_DT, DLV_DT, ISNULL(DC_CD,''), ACTION_YN, ISNULL(PROD_KIND,'')
 ORDER BY 1, 3, 2, 4 DESC;

/* ④ 되돌리기 (필요할 때만) — 이 스크립트가 지운 줄만 다시 살린다 */
-- UPDATE TBL_SHIPOUT_MST
--    SET ACTION_YN = 'Y', UPD_DTTM = GETDATE(), UPD_USER = 'undo20261124'
--  WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'D' AND UPD_USER = 'del20261124';
