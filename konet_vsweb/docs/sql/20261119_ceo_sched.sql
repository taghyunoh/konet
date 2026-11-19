/* =====================================================================
   대표이사 일정 (2026-11-19, 사용자 「직원일정 말고 대표이사 일정 등록하고 완료여부 체크, 편집기능도」 「총괄관리자만 보여지면 됨」)
     · TBL_CEO_SCHED : 일정 한 건 = 기간(FROM_DT~TO_DT, yyyymmdd) · 시간(SCHED_TM, hh:mm, 없어도 됨) · 제목 · 장소 · 내용(CONTENT, 편집기로 쓴 HTML)
                       DONE_YN = 완료 여부(Y/N) · DONE_DTTM/DONE_USER = 완료로 바꾼 때·사람
                       지우기 = ACTION_YN 'N' (줄은 남는다)
     화면 = 직원관리 ▸ 🗓 대표이사 일정 (mangr/ceoSched.jsp) · 자바 = /mangr/ceoSched*.do · 매퍼 = User_SQL.xml 「대표이사 일정」 묶음
     권한 = 총괄관리자(TBL_USER_MST.MAIN_GU '1')만 — 메뉴도 서버도 같은 조건으로 막는다
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접, 한 번. 두 번 실행해도 안전(IF OBJECT_ID … IS NULL).
          성공하면 저절로 COMMIT, 중간에 오류가 나면 저절로 ROLLBACK 하고 오류 글을 보여 준다.
   ===================================================================== */
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRAN;

    IF OBJECT_ID('dbo.TBL_CEO_SCHED','U') IS NULL
    CREATE TABLE dbo.TBL_CEO_SCHED (
        SCHED_SEQ   BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        COMP_CD     VARCHAR(10)    NOT NULL,
        FROM_DT     CHAR(8)        NOT NULL,                 -- yyyymmdd
        TO_DT       CHAR(8)        NOT NULL,                 -- 하루짜리는 FROM_DT 와 같다
        SCHED_TM    VARCHAR(5)     NULL,                     -- hh:mm (없으면 종일)
        TITLE       NVARCHAR(200)  NOT NULL,
        PLACE       NVARCHAR(100)  NULL,
        CONTENT     NVARCHAR(MAX)  NULL,                     -- 편집기로 쓴 HTML (그림·스크립트는 저장 전에 걸러 낸다)
        DONE_YN     CHAR(1)        NOT NULL DEFAULT 'N',     -- 상태 : N 미완료 · Y 완료 · C 일정취소 (2026-11-19 — 칸은 그대로, 처음엔 완료 여부 Y/N 뿐이었다)
        DONE_DTTM   VARCHAR(19)    NULL,
        DONE_USER   NVARCHAR(50)   NULL,
        ACTION_YN   CHAR(1)        NOT NULL DEFAULT 'Y',
        REG_DTTM    VARCHAR(19)    NULL, REG_USER NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
        UPD_DTTM    VARCHAR(19)    NULL, UPD_USER NVARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL
    );

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CEO_SCHED_COMP_DT' AND object_id=OBJECT_ID('dbo.TBL_CEO_SCHED'))
        CREATE INDEX IX_CEO_SCHED_COMP_DT ON dbo.TBL_CEO_SCHED (COMP_CD, FROM_DT, TO_DT);

    COMMIT;
    PRINT N'완료 — TBL_CEO_SCHED 준비됨 (이미 있었다면 그대로 두었습니다)';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT N'실패 — 되돌렸습니다 : ' + ERROR_MESSAGE();
END CATCH;
