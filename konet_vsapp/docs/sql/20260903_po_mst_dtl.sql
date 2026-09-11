/* =====================================================================
   발주서 관리 (2026-09-03 신설) — 매입 관리 ▸ 발주서 관리
     · TBL_PO_MST : 발주서 한 장 (발주일자 + 일련번호, 거래처, 합계, 카톡 공유 토큰)
     · TBL_PO_DTL : 발주 품목 줄
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접 실행한다. 두 번 실행해도 안전(IF NOT EXISTS).
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_PO_MST','U') IS NULL
BEGIN
  CREATE TABLE dbo.TBL_PO_MST (
    PO_SEQ          BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_PO_MST PRIMARY KEY,
    COMP_CD         VARCHAR(20)   NOT NULL,
    PO_DT           CHAR(8)       NOT NULL,          -- 발주일자 yyyymmdd
    PO_NO           VARCHAR(4)    NOT NULL,          -- 그 날의 일련번호 0001~
    VENDOR_CD       VARCHAR(20)   NULL,
    VENDOR_NM       NVARCHAR(100) NULL,
    MGR_CD          VARCHAR(20)   NULL,              -- 담당자(사용자ID)
    MGR_NM          NVARCHAR(50)  NULL,
    TOT_BOX_QTY     DECIMAL(18,2) NULL,
    TOT_EA_QTY      DECIMAL(18,2) NULL,
    TOT_QTY         DECIMAL(18,2) NULL,
    SUPPLY_AMT      DECIMAL(18,0) NULL,
    VAT_AMT         DECIMAL(18,0) NULL,
    TOT_AMT         DECIMAL(18,0) NULL,
    DC_AMT          DECIMAL(18,0) NULL,
    REMARK          NVARCHAR(500) NULL,
    SHARE_TOKEN     VARCHAR(40)   NULL,              -- 카톡 공유 링크 토큰 (/pub/po.do?t=)
    SHARE_CNT       INT           NOT NULL CONSTRAINT DF_TBL_PO_MST_SHARE_CNT DEFAULT 0,
    LAST_SHARE_DTTM VARCHAR(19)   NULL,
    PURCH_SEQ       BIGINT        NULL,              -- 매입전환 시 만들어진 매입전표(예정)
    ACTION_YN       CHAR(1)       NOT NULL CONSTRAINT DF_TBL_PO_MST_ACTION_YN DEFAULT 'Y',
    REG_DTTM        VARCHAR(19)   NULL, REG_USER VARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
    UPD_DTTM        VARCHAR(19)   NULL, UPD_USER VARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL
  );
  CREATE INDEX IX_TBL_PO_MST_DT ON dbo.TBL_PO_MST (COMP_CD, PO_DT, ACTION_YN);
  CREATE UNIQUE INDEX UX_TBL_PO_MST_TOKEN ON dbo.TBL_PO_MST (SHARE_TOKEN) WHERE SHARE_TOKEN IS NOT NULL;
END;

IF OBJECT_ID('dbo.TBL_PO_DTL','U') IS NULL
BEGIN
  CREATE TABLE dbo.TBL_PO_DTL (
    PO_DTL_SEQ  BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_PO_DTL PRIMARY KEY,
    COMP_CD     VARCHAR(20)   NOT NULL,
    PO_SEQ      BIGINT        NOT NULL,
    ROW_NO      INT           NULL,
    PROD_SEQ    INT           NULL,
    PROD_CD     VARCHAR(30)   NULL,
    PROD_NM     NVARCHAR(200) NULL,
    SPEC        NVARCHAR(200) NULL,
    PACK_QTY    DECIMAL(18,2) NULL,                  -- 입수(BOX당 EA)
    BOX_QTY     DECIMAL(18,2) NULL,
    EA_QTY      DECIMAL(18,2) NULL,
    QTY         DECIMAL(18,2) NULL,                  -- 합계수량 = BOX×입수 + EA
    UNIT_PRICE  DECIMAL(18,2) NULL,                  -- EA 단가
    AMT         DECIMAL(18,0) NULL,                  -- 금액 = 수량×단가
    DC_AMT      DECIMAL(18,0) NULL,
    SUPPLY_AMT  DECIMAL(18,0) NULL,                  -- 공급가 = 금액 − DC
    VAT_AMT     DECIMAL(18,0) NULL,
    TOT_AMT     DECIMAL(18,0) NULL,                  -- 매입금액 = 공급가 + 부가세
    SERVICE_QTY DECIMAL(18,2) NULL,
    TAX_GB      VARCHAR(10)   NULL,                  -- 상품 과세구분(면세면 부가세 0)
    REMARK      NVARCHAR(300) NULL,
    ACTION_YN   CHAR(1)       NOT NULL CONSTRAINT DF_TBL_PO_DTL_ACTION_YN DEFAULT 'Y',
    REG_DTTM    VARCHAR(19)   NULL, REG_USER VARCHAR(50) NULL
  );
  CREATE INDEX IX_TBL_PO_DTL_SEQ ON dbo.TBL_PO_DTL (PO_SEQ, ACTION_YN);
END;

/* 확인 */
SELECT 'TBL_PO_MST' AS tbl, COUNT(*) AS rows FROM dbo.TBL_PO_MST
UNION ALL SELECT 'TBL_PO_DTL', COUNT(*) FROM dbo.TBL_PO_DTL;
