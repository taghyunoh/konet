/* =====================================================================================
   회사 정보 수정 (기준정보관리 ▸ 회사 정보 수정) — 2026-09-11
   · 배경 : 고객 요청 「회사정보를 이렇게 바꿔 달라」(다른 프로그램의 설정 ▸ 회사정보 수정 화면 3장).
     ① 필수·기본 정보  ② 도장  ③ 거래명세서 인쇄 옵션 + 그 사이의 「기능」 설정 — 없는 칸은 채운다.
   · 종전에는 회사 정보를 고치는 곳이 관리자 회사 전용(회사/사용자 관리)과 거래명세표 조건 창뿐이라
     일반 회사는 자기 회사 정보를 고칠 길이 없었다.

   1) TBL_COMP_MST 칸 추가 — 이메일·휴대폰·설립일·법인번호·대표자 생년월일·공지사항2
      ★TBL_COMP_MST 는 이력형(JOB_SEQ + ACTION_YN)이다. 관리자 화면의 회사 수정은 <옛 행 N + 새 행 INSERT>
        라서 insertCompCdMst 에 이 칸들을 <직전 행 값 물려받기>로 넣어 두었다(업태·종목과 같은 규칙).
   2) TBL_COMP_SET — 회사당 한 줄. 도장 이미지 + 설정(JSON 한 칸 : 기능·인쇄 옵션).
      ★이력형이 아니다 — 설정 칸이라 MERGE 로 그 자리에서 고친다.
      ★설정을 칸마다 컬럼으로 만들지 않고 JSON 한 칸에 둔다 — 항목이 자주 늘고, 늘 때마다 DDL·DTO·
        이력형 INSERT 를 같이 고치다 보면 하나씩 빠진다(TBL_COMP_MST 에서 겪은 일).
   3) TBL_COMP_BANK — 은행계좌 관리(여러 개). 거래명세서의 계좌 칸(TBL_COMP_MST.BANK_ACCT)은
      여기서 <결제계좌>로 고른 한 줄이 들어간다(종전 칸·코드는 그대로 쓴다).
   4) TBL_COMP_CARD — 카드 관리. ★카드번호는 뒤 4자리만 둔다(전체 번호를 저장하지 않는다).
   · 각 구문 IF 가드로 재실행 안전. 값은 넣지 않는다.
   ===================================================================================== */
USE [KOLGSDB]
GO

/* ---------- 1) TBL_COMP_MST 칸 추가 ---------- */
IF COL_LENGTH('dbo.TBL_COMP_MST','COMP_EMAIL') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD COMP_EMAIL   NVARCHAR(100) NULL;   -- 이메일
GO
IF COL_LENGTH('dbo.TBL_COMP_MST','COMP_HP') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD COMP_HP      NVARCHAR(30)  NULL;   -- 휴대폰번호
GO
IF COL_LENGTH('dbo.TBL_COMP_MST','FOUND_DT') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD FOUND_DT     NVARCHAR(8)   NULL;   -- 설립일 YYYYMMDD
GO
IF COL_LENGTH('dbo.TBL_COMP_MST','CORP_NO') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD CORP_NO      NVARCHAR(20)  NULL;   -- 법인번호
GO
IF COL_LENGTH('dbo.TBL_COMP_MST','CEO_BIRTH') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD CEO_BIRTH    NVARCHAR(8)   NULL;   -- 대표자 생년월일 YYYYMMDD
GO
IF COL_LENGTH('dbo.TBL_COMP_MST','STMT_NOTICE2') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD STMT_NOTICE2 NVARCHAR(500) NULL;   -- 거래명세서 공지사항 2
GO

/* ---------- 2) TBL_COMP_SET ---------- */
IF OBJECT_ID('dbo.TBL_COMP_SET','U') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_COMP_SET (
        COMP_CD    VARCHAR(10)   NOT NULL CONSTRAINT PK_COMP_SET PRIMARY KEY,
        SET_JSON   NVARCHAR(MAX) NULL,      -- {"func":{...}, "prt":{...}, "prtApp":{...}}
        STAMP_IMG  NVARCHAR(MAX) NULL,      -- 도장 이미지 data:image/png;base64,... (화면이 줄여서 올린다)
        REG_DTTM   NVARCHAR(19)  NULL,
        REG_USER   VARCHAR(50)   NULL,
        UPD_DTTM   NVARCHAR(19)  NULL,
        UPD_USER   VARCHAR(50)   NULL,
        UPD_IP     VARCHAR(50)   NULL
    );
END
GO

/* ---------- 3) TBL_COMP_BANK ---------- */
IF OBJECT_ID('dbo.TBL_COMP_BANK','U') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_COMP_BANK (
        BANK_SEQ    BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_COMP_BANK PRIMARY KEY,
        COMP_CD     VARCHAR(10)   NOT NULL,
        BANK_NM     NVARCHAR(50)  NULL,     -- 은행명
        ACCT_NO     NVARCHAR(50)  NULL,     -- 계좌번호
        ACCT_HOLDER NVARCHAR(100) NULL,     -- 예금주
        ALIAS_NM    NVARCHAR(100) NULL,     -- 별칭(용도)
        SORT_ORD    INT           NULL,
        ACTION_YN   CHAR(1)       NOT NULL CONSTRAINT DF_COMP_BANK_ACTION DEFAULT 'Y',
        REG_DTTM    NVARCHAR(19)  NULL,
        REG_USER    VARCHAR(50)   NULL,
        UPD_DTTM    NVARCHAR(19)  NULL,
        UPD_USER    VARCHAR(50)   NULL
    );
    CREATE INDEX IX_COMP_BANK_COMP ON dbo.TBL_COMP_BANK (COMP_CD, ACTION_YN);
END
GO

/* ---------- 4) TBL_COMP_CARD ---------- */
IF OBJECT_ID('dbo.TBL_COMP_CARD','U') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_COMP_CARD (
        CARD_SEQ    BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_COMP_CARD PRIMARY KEY,
        COMP_CD     VARCHAR(10)   NOT NULL,
        CARD_CO     NVARCHAR(50)  NULL,     -- 카드사
        CARD_NM     NVARCHAR(100) NULL,     -- 카드 이름(별칭)
        CARD_LAST4  VARCHAR(4)    NULL,     -- 카드번호 뒤 4자리 (전체 번호는 저장하지 않는다)
        CARD_USER   NVARCHAR(50)  NULL,     -- 사용자
        CARD_GB     NVARCHAR(10)  NULL,     -- 법인/개인
        REMARK      NVARCHAR(200) NULL,
        SORT_ORD    INT           NULL,
        ACTION_YN   CHAR(1)       NOT NULL CONSTRAINT DF_COMP_CARD_ACTION DEFAULT 'Y',
        REG_DTTM    NVARCHAR(19)  NULL,
        REG_USER    VARCHAR(50)   NULL,
        UPD_DTTM    NVARCHAR(19)  NULL,
        UPD_USER    VARCHAR(50)   NULL
    );
    CREATE INDEX IX_COMP_CARD_COMP ON dbo.TBL_COMP_CARD (COMP_CD, ACTION_YN);
END
GO

/* ---------- 5) TBL_COMP_SET.AVG_ZERO_YN ----------
   ★DB 가 SQL Server 2012(호환 110)라 JSON_VALUE 를 못 쓴다 — SQL 이 직접 봐야 하는 설정은 칸으로 따로 둔다.
   「평균 매입단가 산출 시 금액이 0인 거래 포함」 : 'Y'(기본·종전 동작) = 단가 0 입고도 평균에 넣는다 / 'N' = 뺀다.
   화면 저장(compInfoSave)이 JSON 과 이 칸을 함께 맞춘다. */
IF COL_LENGTH('dbo.TBL_COMP_SET','AVG_ZERO_YN') IS NULL
    ALTER TABLE dbo.TBL_COMP_SET ADD AVG_ZERO_YN CHAR(1) NULL;
GO

/* ---------- 6) TBL_VENDOR_MST — DC 사용 · DC율 · 여신한도 ----------
   회사 설정 「거래처 : DC 사용 / 기본 DC율」 은 <새 거래처의 기본값>이고, 실제 DC 는 거래처마다 이 칸으로 걸린다.
   DC_YN='Y' 이고 DC_RATE>0 이면 판매·매입 명세에 상품을 담을 때 DC 금액 = 금액 × DC율 이 자동으로 들어간다.
   CREDIT_LIMIT = 여신한도(원). 회사 설정 「여신 초과 제한」이 켜져 있으면 거래후잔고가 이 값을 넘는 판매 저장을 막는다.
   NULL/0 = 한도 없음. */
IF COL_LENGTH('dbo.TBL_VENDOR_MST','DC_YN') IS NULL
    ALTER TABLE dbo.TBL_VENDOR_MST ADD DC_YN NCHAR(1) NULL;
GO
IF COL_LENGTH('dbo.TBL_VENDOR_MST','DC_RATE') IS NULL
    ALTER TABLE dbo.TBL_VENDOR_MST ADD DC_RATE DECIMAL(5,2) NULL;
GO
IF COL_LENGTH('dbo.TBL_VENDOR_MST','CREDIT_LIMIT') IS NULL
    ALTER TABLE dbo.TBL_VENDOR_MST ADD CREDIT_LIMIT DECIMAL(18,2) NULL;
GO

/* 확인
SELECT VENDOR_CD, VENDOR_NM, VAT_GB, DC_YN, DC_RATE, CREDIT_LIMIT FROM dbo.TBL_VENDOR_MST WHERE ACTION_YN='Y' AND (DC_YN IS NOT NULL OR CREDIT_LIMIT IS NOT NULL);
SELECT COMP_CD, JOB_SEQ, ACTION_YN, COMP_NM, COMP_EMAIL, COMP_HP, FOUND_DT, CORP_NO, CEO_BIRTH, STMT_NOTICE2
  FROM dbo.TBL_COMP_MST WHERE ACTION_YN='Y';
SELECT COMP_CD, LEN(SET_JSON) AS jsonLen, LEN(STAMP_IMG) AS stampLen, UPD_DTTM FROM dbo.TBL_COMP_SET;
SELECT * FROM dbo.TBL_COMP_BANK WHERE ACTION_YN='Y';
SELECT * FROM dbo.TBL_COMP_CARD WHERE ACTION_YN='Y';
*/
