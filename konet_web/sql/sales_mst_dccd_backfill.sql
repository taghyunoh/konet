/* ============================================================================
   TBL_SALES_MST.DC_CD 백필 (2026-07-22)
   ----------------------------------------------------------------------------
   정산 엑셀에는 물류센터코드가 없고 파일명에 지역명만 있어서 DC_CD 가 NULL 로
   쌓여 있었다. 2026-07-22 부터는 업로드 화면(logistics_demo2.jsp `slsDcCd`)이
   저장 시 코드를 붙이므로, 그 이전에 저장된 자료만 이 스크립트로 채운다.

   대응표 근거 = TBL_SHIPOUT_MST 실데이터의 DC_CD ↔ DC_NM
     E100 용인 / E200 왜관 / E300 김해 / E400 광주 / E500 평택 / E600 제주 / E700 오산
   (거래처(TBL_VENDOR_MST) 대응: 00273 / 00275 / 00274 / 00276 / 00272 / 00277 / 00278)

   · 이력행(ACTION_YN='N')도 함께 채운다 — 과거 배치도 코드로 조회되게.
   · 대응표에 없는 출고장명은 건드리지 않는다(추측하지 않음). 아래 ③으로 확인.
   ============================================================================ */

/* ① 실행 전 확인 — 무엇이 몇 건 바뀌는지 */
SELECT ISNULL(DC_CD,'(NULL)') AS DC_CD, DC_NM, COUNT(*) AS CNT
  FROM TBL_SALES_MST
 GROUP BY DC_CD, DC_NM
 ORDER BY DC_NM;

/* ② 백필 */
UPDATE TBL_SALES_MST
   SET DC_CD = CASE LTRIM(RTRIM(DC_NM))
                 WHEN '용인' THEN 'E100'
                 WHEN '왜관' THEN 'E200'
                 WHEN '김해' THEN 'E300'
                 WHEN '광주' THEN 'E400'
                 WHEN '평택' THEN 'E500'
                 WHEN '제주' THEN 'E600'
                 WHEN '오산' THEN 'E700'
               END
 WHERE ISNULL(DC_CD,'') = ''
   AND LTRIM(RTRIM(DC_NM)) IN ('용인','왜관','김해','광주','평택','제주','오산');

/* ③ 실행 후 확인 — 여기 남는 행이 있으면 출고장명이 대응표에 없다는 뜻 */
SELECT DC_NM, COUNT(*) AS CNT
  FROM TBL_SALES_MST
 WHERE ISNULL(DC_CD,'') = ''
 GROUP BY DC_NM;
