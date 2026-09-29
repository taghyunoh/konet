/* =====================================================================
   견적서 진행 상태 (2026-09-29 — 사용자 「견적서관리에서 제출완료(일자), 채택(일자), 거절(일자), 보류(일자)
   각 항목에 대한 일자 관리 할 수 있게」 · 화면 메모 「이 화면에서 견적서 진행 내용을 알 수 있으면 좋겠어요」)

     · STAT_GB   : 지금 상태 한 글자 —  W 작성 중(기본·빈 값도 작성 중) / S 제출완료 / A 채택 / R 거절 / H 보류
     · SUBMIT_DT · ADOPT_DT · REJECT_DT · HOLD_DT
                 : 항목마다 «따로» 둔다. 제출완료 뒤 채택이 되면 두 일자가 다 남는다(이력이 지워지지 않는다).
                   상태를 되돌려도 일자는 그대로 두고, 화면에서 그 칸을 비워 저장하면 지워진다.
     · STAT_MEMO : 진행 메모(거절 사유 등) · STAT_DTTM · STAT_USER : 마지막으로 상태를 바꾼 때·사람
   ★칸을 새로 더하기만 한다 — 기존 자료는 STAT_GB 가 NULL 이고, 화면·조회는 NULL 을 「작성 중」으로 본다.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF COL_LENGTH … IS NULL).
   ⚠WAR 배포 <전에> 실행할 것 — 새 매퍼가 이 칸들을 읽는다(견적서 목록·상태 저장).
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_MST','STAT_GB')   IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD STAT_GB   NVARCHAR(10)  NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','SUBMIT_DT') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD SUBMIT_DT CHAR(8)       NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','ADOPT_DT')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD ADOPT_DT  CHAR(8)       NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','REJECT_DT') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD REJECT_DT CHAR(8)       NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','HOLD_DT')   IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD HOLD_DT   CHAR(8)       NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','STAT_MEMO') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD STAT_MEMO NVARCHAR(200) NULL;
GO
/* ── 작성 기간 · 채택 뒤 수정 (2026-09-29 「작성하기 시작해서 끝나는데 며칠 걸리는지」·「채택된 견적서는 수정 못하게, 꼭 해야 하면 수정 사유」) ──
     · START_DT  : 작성 시작일. ★같은 문서번호를 다시 저장하면 옛 줄을 닫고 새 줄을 넣는 구조라 REG_DTTM 은 «마지막 저장 때»가 된다.
                   그래서 시작일을 따로 두고, 대체 저장 때 옛 줄의 값을 그대로 이어받는다(없으면 옛 줄의 등록일).
                   작성 기간 = 제출완료일 − 작성 시작일. 아직 제출 전이면 오늘까지 며칠째인지 센다.
     · EDIT_CNT · EDIT_MEMO · EDIT_DTTM · EDIT_USER
                 : 채택(A) 된 견적서를 고칠 때만 쓴다. 사유 없이는 저장이 막힌다(화면·서버 둘 다).
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
/* 이미 있는 견적서의 작성 시작일 = 그 줄의 등록일(처음 한 번만 채운다) */
UPDATE dbo.TBL_QUOTE_MST SET START_DT = LEFT(REPLACE(REG_DTTM,'-',''),8)
 WHERE ACTION_YN = 'Y' AND START_DT IS NULL AND ISNULL(REG_DTTM,'') <> '';
GO

IF COL_LENGTH('dbo.TBL_QUOTE_MST','STAT_DTTM') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD STAT_DTTM VARCHAR(19)   NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','STAT_USER') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD STAT_USER NVARCHAR(50)  NULL;
GO

/* ── 확인 ── */
SELECT COL_LENGTH('dbo.TBL_QUOTE_MST','STAT_GB')   AS statGb,
       COL_LENGTH('dbo.TBL_QUOTE_MST','SUBMIT_DT') AS submitDt,
       COL_LENGTH('dbo.TBL_QUOTE_MST','ADOPT_DT')  AS adoptDt,
       COL_LENGTH('dbo.TBL_QUOTE_MST','REJECT_DT') AS rejectDt,
       COL_LENGTH('dbo.TBL_QUOTE_MST','HOLD_DT')   AS holdDt,
       COL_LENGTH('dbo.TBL_QUOTE_MST','STAT_MEMO') AS statMemo, COL_LENGTH('dbo.TBL_QUOTE_MST','START_DT') AS startDt, COL_LENGTH('dbo.TBL_QUOTE_MST','EDIT_MEMO') AS editMemo;

/* ── 지금 상태 보기(실행 뒤 전부 「작성 중」으로 나오는 것이 정상) ── */
SELECT ISNULL(NULLIF(STAT_GB,''),'W') AS statGb, COUNT(*) AS cnt
  FROM dbo.TBL_QUOTE_MST WHERE ACTION_YN = 'Y' GROUP BY ISNULL(NULLIF(STAT_GB,''),'W');
