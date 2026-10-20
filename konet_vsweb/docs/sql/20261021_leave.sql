/* =====================================================================
   직원 휴가 관리 (2026-10-21, 사용자 「기존 직원 휴가 내용을 메시지로 처리하고 있는데 연차·월차·반차·병가 등 구분으로 직원별 휴가 관리,
                                 메뉴는 직원 메신저 밑에, 달력으로 한눈에, 총괄관리자는 현황을 한눈에, 엑셀 월별·연별·사원별」)
     · TBL_LEAVE_MST   : 휴가 한 건 = 직원 × 구분 × 기간(FROM_DT~TO_DT, yyyymmdd) × 일수(DAYS, 반차 0.5)
                         STATUS = 신청 / 승인 / 반려 — 총괄관리자(MAIN_GU 1)가 넣거나 승인하면 「승인」, 그 밖(부관리자·담당자)이 넣으면 「신청」. 수정은 본인 것만, 총괄관리자는 전부
                         LEAVE_GB = 연차 · 월차 · 반차(오전) · 반차(오후) · 병가 · 경조 · 공가 · 기타 (화면 고정 목록)
     · TBL_LEAVE_QUOTA : 직원 × 연도의 부여 일수(연차·월차) — 현황의 「잔여」= 부여 − 사용(반려 제외). 관리자가 화면 [⚙ 연차 설정]에서 넣는다
     화면 = 직원 소통 ▸ 🏖 직원 휴가 관리 (mangr/leaveMng.jsp) · 자바 = /mangr/leave*.do · 매퍼 = User_SQL.xml 「직원 휴가」 묶음
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF OBJECT_ID … IS NULL).
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_LEAVE_MST','U') IS NULL
CREATE TABLE dbo.TBL_LEAVE_MST (
    LEAVE_SEQ   BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    COMP_CD     VARCHAR(10)   NOT NULL,
    USER_ID     VARCHAR(20)   NOT NULL,
    USER_NM     NVARCHAR(50)  NULL,
    LEAVE_GB    NVARCHAR(20)  NOT NULL,                 -- 연차·월차·반차(오전)·반차(오후)·병가·경조·공가·기타
    FROM_DT     CHAR(8)       NOT NULL,                 -- yyyymmdd
    TO_DT       CHAR(8)       NOT NULL,
    DAYS        DECIMAL(5,1)  NOT NULL DEFAULT 1,       -- 반차 0.5, 주말 뺀 평일 수(화면 계산, 고칠 수 있음)
    REMARK      NVARCHAR(200) NULL,
    STATUS      NVARCHAR(10)  NOT NULL DEFAULT N'신청',  -- 신청·승인·반려
    STAT_USER   NVARCHAR(50)  NULL,
    STAT_DTTM   VARCHAR(19)   NULL,
    ACTION_YN   CHAR(1)       NOT NULL DEFAULT 'Y',
    REG_DTTM    VARCHAR(19)   NULL, REG_USER NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
    UPD_DTTM    VARCHAR(19)   NULL, UPD_USER NVARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL
);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_LEAVE_MST_COMP_DT' AND object_id=OBJECT_ID('dbo.TBL_LEAVE_MST'))
    CREATE INDEX IX_LEAVE_MST_COMP_DT ON dbo.TBL_LEAVE_MST (COMP_CD, FROM_DT, TO_DT);

IF OBJECT_ID('dbo.TBL_LEAVE_QUOTA','U') IS NULL
CREATE TABLE dbo.TBL_LEAVE_QUOTA (
    COMP_CD      VARCHAR(10)   NOT NULL,
    USER_ID      VARCHAR(20)   NOT NULL,
    LEAVE_YEAR   CHAR(4)       NOT NULL,                -- yyyy
    ANNUAL_DAYS  DECIMAL(5,1)  NOT NULL DEFAULT 15,     -- 연차 부여
    MONTHLY_DAYS DECIMAL(5,1)  NOT NULL DEFAULT 0,      -- 월차 부여(연간 합)
    REMARK       NVARCHAR(200) NULL,
    REG_DTTM     VARCHAR(19)   NULL, REG_USER NVARCHAR(50) NULL,
    UPD_DTTM     VARCHAR(19)   NULL, UPD_USER NVARCHAR(50) NULL,
    CONSTRAINT PK_LEAVE_QUOTA PRIMARY KEY (COMP_CD, USER_ID, LEAVE_YEAR)
);
