/* =====================================================================
   견적서 작성 시작일 바로잡기 (2026-09-29)
   앞 스크립트는 기존 견적서의 시작일을 「지금 줄의 등록일」로 채웠다. 그런데 같은 문서번호를 다시 저장하면
   옛 줄을 이력(ACTION_YN='N')으로 닫고 새 줄을 넣으므로, 지금 줄의 등록일은 «마지막 저장일»이다.
   이력 줄까지 모아 «처음 저장한 날»로 고친다.
   실측 : Konet260918-01  09-23 → 09-18 (저장 10번) · Konet260923-02  09-29 → 09-23 (저장 9번). 나머지 셋은 그대로.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 전체 실행. 두 번 실행해도 같은 결과.
   ===================================================================== */
/* ① 미리 보기 */
SELECT a.DOC_NO, a.START_DT AS nowStart, f.firstSave
  FROM dbo.TBL_QUOTE_MST a
  CROSS APPLY ( SELECT MIN(LEFT(REPLACE(h.REG_DTTM,'-',''),8)) AS firstSave
                  FROM dbo.TBL_QUOTE_MST h
                 WHERE h.COMP_CD = a.COMP_CD AND h.DOC_NO = a.DOC_NO AND ISNULL(h.REG_DTTM,'') <> '' ) f
 WHERE a.ACTION_YN = 'Y' AND f.firstSave IS NOT NULL AND ISNULL(a.START_DT,'') <> f.firstSave;
GO
/* ② 고치기 — 처음 저장한 날이 지금 값보다 이를 때만 */
UPDATE a SET a.START_DT = f.firstSave
  FROM dbo.TBL_QUOTE_MST a
  CROSS APPLY ( SELECT MIN(LEFT(REPLACE(h.REG_DTTM,'-',''),8)) AS firstSave
                  FROM dbo.TBL_QUOTE_MST h
                 WHERE h.COMP_CD = a.COMP_CD AND h.DOC_NO = a.DOC_NO AND ISNULL(h.REG_DTTM,'') <> '' ) f
 WHERE a.ACTION_YN = 'Y' AND f.firstSave IS NOT NULL AND (a.START_DT IS NULL OR f.firstSave < a.START_DT);
GO
/* ③ 확인 */
SELECT DOC_NO, QUOTE_DT, START_DT FROM dbo.TBL_QUOTE_MST WHERE ACTION_YN = 'Y' ORDER BY DOC_NO;
