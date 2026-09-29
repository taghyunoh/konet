/* =====================================================================
   견적서 진행 상태 — 빠진 칸 보충 (2026-09-29)
   20260929_quote_stat.sql 실행 뒤 운영 DB 를 보니 STAT_GB … STAT_USER 여덟 칸은 들어갔고
   START_DT · EDIT_CNT · EDIT_MEMO · EDIT_DTTM · EDIT_USER 다섯 칸이 빠져 있었다(UPDATE 가 「열 이름 START_DT 잘못」으로 멈춘 까닭).
   이 파일을 <처음부터 끝까지 전체> 실행한다(일부만 골라 실행하지 말 것). 두 번 실행해도 안전.
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_MST','START_DT')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD START_DT  CHAR(8)       NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_CNT')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD EDIT_CNT  INT           NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_MEMO') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD EDIT_MEMO NVARCHAR(300) NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_DTTM') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD EDIT_DTTM VARCHAR(19)   NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_USER') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD EDIT_USER NVARCHAR(50)  NULL;
GO
/* 이미 있는 견적서의 작성 시작일 = 그 줄의 등록일 */
UPDATE dbo.TBL_QUOTE_MST SET START_DT = LEFT(REPLACE(REG_DTTM,'-',''),8)
 WHERE ACTION_YN = 'Y' AND START_DT IS NULL AND ISNULL(REG_DTTM,'') <> '';
GO
/* ── 확인 : 다섯 칸 모두 숫자가 나오면 된다(NULL 이면 그 칸이 없는 것) ── */
SELECT COL_LENGTH('dbo.TBL_QUOTE_MST','START_DT')  AS startDt,
       COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_CNT')  AS editCnt,
       COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_MEMO') AS editMemo,
       COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_DTTM') AS editDttm,
       COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_USER') AS editUser;
SELECT DOC_NO, START_DT FROM dbo.TBL_QUOTE_MST WHERE ACTION_YN = 'Y' ORDER BY QUOTE_SEQ DESC;
