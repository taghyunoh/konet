/* =====================================================================
   직원 공지사항 · 직원 메신저 (2026-09-22 신설) — ⛔새 WAR 를 올리기 <전에> 운영DB(KOLGSDB, SQL Server 2012)에서 한 번 실행. 재실행 안전.

   사용자 확정(2026-09-22) :
     ① 메신저 = 1:1 + 그룹방        ② 공지 = 관리자(총괄·부관리자, MAIN_GU 1·2)만 쓰고 전원 읽기
     ③ 글만(파일·사진 첨부 없음)     ④ PC 웹(9071) 먼저, 모바일 앱(9072)은 다음

   표 5개 — 전부 COMP_CD 로 회사를 가른다(다중회사).
     TBL_EMP_NOTICE       공지 머리·본문 (삭제 = ACTION_YN 'N')
     TBL_EMP_NOTICE_READ  누가 언제 읽었나 (공지 × 직원 한 줄) — 「안 읽은 공지 N」 배지·읽은 사람 목록의 근거
     TBL_EMP_ROOM         대화방 (ROOM_GB D=1:1 · G=그룹). 1:1 은 DM_KEY(두 아이디를 정렬해 '|' 로 붙임)로 한 방만 — 필터 유니크 인덱스
     TBL_EMP_ROOM_MBR     방 구성원 + 어디까지 읽었나(LAST_READ_SEQ) — 안 읽은 수 = 그 뒤에 남이 쓴 메시지 수
     TBL_EMP_MSG          메시지 (글만)

   ⚠사용자 이름은 저장하지 않는다 — TBL_USER_MST(이력형, 활성·최근 1줄)에서 그때그때 읽는다(이름을 바꾸면 옛 글도 새 이름).
     공지 작성자 이름(REG_NM)만 그 시점 이름으로 남긴다(작성자가 퇴사해 계정이 지워져도 누가 썼는지 보이게).
   ===================================================================== */

-- 1) 공지
IF OBJECT_ID('dbo.TBL_EMP_NOTICE','U') IS NULL
CREATE TABLE dbo.TBL_EMP_NOTICE (
    COMP_CD     VARCHAR(10)   NOT NULL,
    NOTICE_SEQ  INT IDENTITY(1,1) NOT NULL,
    TITLE       NVARCHAR(200) NOT NULL,
    CONTENT     NVARCHAR(MAX) NULL,
    PIN_YN      CHAR(1)       NOT NULL CONSTRAINT DF_EMP_NOTICE_PIN DEFAULT 'N',   -- 상단 고정
    ACTION_YN   CHAR(1)       NOT NULL CONSTRAINT DF_EMP_NOTICE_ACT DEFAULT 'Y',   -- 'N' = 삭제
    REG_USER    VARCHAR(50)   NULL,
    REG_NM      NVARCHAR(50)  NULL,
    REG_DTTM    DATETIME      NOT NULL CONSTRAINT DF_EMP_NOTICE_REG DEFAULT GETDATE(),
    UPD_USER    VARCHAR(50)   NULL,
    UPD_DTTM    DATETIME      NULL,
    CONSTRAINT PK_EMP_NOTICE PRIMARY KEY (NOTICE_SEQ)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EMP_NOTICE_COMP')
    CREATE INDEX IX_EMP_NOTICE_COMP ON dbo.TBL_EMP_NOTICE (COMP_CD, ACTION_YN, PIN_YN, NOTICE_SEQ);
GO

-- 2) 공지 읽음
IF OBJECT_ID('dbo.TBL_EMP_NOTICE_READ','U') IS NULL
CREATE TABLE dbo.TBL_EMP_NOTICE_READ (
    COMP_CD     VARCHAR(10) NOT NULL,
    NOTICE_SEQ  INT         NOT NULL,
    USER_ID     VARCHAR(50) NOT NULL,
    READ_DTTM   DATETIME    NOT NULL CONSTRAINT DF_EMP_NOTICE_READ_DT DEFAULT GETDATE(),
    CONSTRAINT PK_EMP_NOTICE_READ PRIMARY KEY (COMP_CD, NOTICE_SEQ, USER_ID)
);
GO

-- 3) 대화방
IF OBJECT_ID('dbo.TBL_EMP_ROOM','U') IS NULL
CREATE TABLE dbo.TBL_EMP_ROOM (
    COMP_CD       VARCHAR(10)   NOT NULL,
    ROOM_SEQ      INT IDENTITY(1,1) NOT NULL,
    ROOM_GB       CHAR(1)       NOT NULL,            -- D = 1:1 · G = 그룹
    ROOM_NM       NVARCHAR(100) NULL,                -- 그룹방 이름(1:1 은 비움 — 상대 이름을 그때 읽는다)
    DM_KEY        VARCHAR(120)  NULL,                -- 1:1 : 두 USER_ID 를 정렬해 '|' 로 붙인 값 (회사 안에서 한 방만)
    LAST_MSG_SEQ  INT           NOT NULL CONSTRAINT DF_EMP_ROOM_LAST DEFAULT 0,
    LAST_TXT      NVARCHAR(200) NULL,                -- 목록에 보일 마지막 글(앞 200자)
    LAST_USER     VARCHAR(50)   NULL,
    LAST_DTTM     DATETIME      NULL,
    REG_USER      VARCHAR(50)   NULL,
    REG_DTTM      DATETIME      NOT NULL CONSTRAINT DF_EMP_ROOM_REG DEFAULT GETDATE(),
    CONSTRAINT PK_EMP_ROOM PRIMARY KEY (ROOM_SEQ)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_EMP_ROOM_DMKEY')
    CREATE UNIQUE INDEX UX_EMP_ROOM_DMKEY ON dbo.TBL_EMP_ROOM (COMP_CD, DM_KEY) WHERE DM_KEY IS NOT NULL;
GO

-- 4) 방 구성원
IF OBJECT_ID('dbo.TBL_EMP_ROOM_MBR','U') IS NULL
CREATE TABLE dbo.TBL_EMP_ROOM_MBR (
    COMP_CD        VARCHAR(10) NOT NULL,
    ROOM_SEQ       INT         NOT NULL,
    USER_ID        VARCHAR(50) NOT NULL,
    LAST_READ_SEQ  INT         NOT NULL CONSTRAINT DF_EMP_ROOM_MBR_READ DEFAULT 0,   -- 이 번호까지 읽었다
    LEAVE_YN       CHAR(1)     NOT NULL CONSTRAINT DF_EMP_ROOM_MBR_LEAVE DEFAULT 'N',
    JOIN_DTTM      DATETIME    NOT NULL CONSTRAINT DF_EMP_ROOM_MBR_JOIN DEFAULT GETDATE(),
    CONSTRAINT PK_EMP_ROOM_MBR PRIMARY KEY (COMP_CD, ROOM_SEQ, USER_ID)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EMP_ROOM_MBR_USER')
    CREATE INDEX IX_EMP_ROOM_MBR_USER ON dbo.TBL_EMP_ROOM_MBR (COMP_CD, USER_ID, LEAVE_YN);
GO

-- 5) 메시지
IF OBJECT_ID('dbo.TBL_EMP_MSG','U') IS NULL
CREATE TABLE dbo.TBL_EMP_MSG (
    COMP_CD    VARCHAR(10)   NOT NULL,
    MSG_SEQ    INT IDENTITY(1,1) NOT NULL,
    ROOM_SEQ   INT           NOT NULL,
    USER_ID    VARCHAR(50)   NOT NULL,
    MSG_TXT    NVARCHAR(MAX) NULL,
    MSG_GB     CHAR(1)       NOT NULL CONSTRAINT DF_EMP_MSG_GB DEFAULT 'T',   -- T = 글 · S = 시스템(입장·나감 안내)
    REG_DTTM   DATETIME      NOT NULL CONSTRAINT DF_EMP_MSG_REG DEFAULT GETDATE(),
    CONSTRAINT PK_EMP_MSG PRIMARY KEY (MSG_SEQ)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EMP_MSG_ROOM')
    CREATE INDEX IX_EMP_MSG_ROOM ON dbo.TBL_EMP_MSG (COMP_CD, ROOM_SEQ, MSG_SEQ);
GO

-- 확인
SELECT name FROM sys.tables WHERE name IN ('TBL_EMP_NOTICE','TBL_EMP_NOTICE_READ','TBL_EMP_ROOM','TBL_EMP_ROOM_MBR','TBL_EMP_MSG') ORDER BY name;
