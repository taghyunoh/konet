/* ============================================================================
   납품분 제외 — TBL_SALES_DLV_EXCL                              2026-07-31
   ----------------------------------------------------------------------------
   판매등록 화면의 [납품분] 팝업은 '그 거래처에 이미 나간 품목'을 중복 없이 모아
   보여준다(판매전표 TBL_SALES_TRX_DTL + 정산서 TBL_SALES_MST).
   단종·계약종료처럼 앞으로 다시 안 팔 품목은 [납품분제외]로 목록에서 뺀다.

   ★ 거래처별 제외다 (2026-07-31 협의)
     A거래처에서 뺀 품목도 B거래처 납품분에는 그대로 나온다.
     같은 상품이 거래처마다 계약이 다르기 때문. 그래서 키가 (CUST_CD + PROD_CD).

   ★ 지우지 않고 ACTION_YN 으로 되돌린다
     제외 = ACTION_YN 'Y' / 해제 = 'N'. 팝업의 [제외이력보기]가 'Y' 목록이고
     거기서 [해제]를 누르면 'N' 이 되어 다시 납품분에 나온다. 판매 자료는 손대지 않는다
     — 제외는 '보이지 않게 하는 것'일 뿐, 과거 판매 이력을 지우는 게 아니다.
   ============================================================================ */
USE [KOLGSDB]
GO

IF OBJECT_ID('dbo.TBL_SALES_DLV_EXCL','U') IS NULL
BEGIN
CREATE TABLE dbo.TBL_SALES_DLV_EXCL (
    EXCL_SEQ   INT IDENTITY(1,1) NOT NULL,
    COMP_CD    VARCHAR(20)    NOT NULL,          -- 회사코드(멀티테넌트)
    CUST_CD    VARCHAR(20)    NOT NULL,          -- 거래처(매출처) — 제외는 거래처별이다
    PROD_CD    VARCHAR(20)    NOT NULL,          -- 상품코드
    PROD_NM    NVARCHAR(200)      NULL,          -- 제외 당시 상품명(표시용 스냅샷)
    REASON     NVARCHAR(200)      NULL,          -- 제외 사유(선택)
    ACTION_YN  CHAR(1)        NOT NULL CONSTRAINT DF_SALES_DLV_EXCL_ACT DEFAULT('Y'),
    REG_DTTM   VARCHAR(19)        NULL,
    REG_USER   NVARCHAR(50)       NULL,
    REG_IP     VARCHAR(45)        NULL,
    UPD_DTTM   VARCHAR(19)        NULL,
    UPD_USER   NVARCHAR(50)       NULL,
    UPD_IP     VARCHAR(45)        NULL,
    CONSTRAINT PK_TBL_SALES_DLV_EXCL PRIMARY KEY CLUSTERED (EXCL_SEQ)
);
END
GO

/* (회사 + 거래처 + 상품) 한 줄만 둔다. 다시 제외하면 그 줄을 'Y' 로 되살린다 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_SALES_DLV_EXCL' AND object_id=OBJECT_ID('dbo.TBL_SALES_DLV_EXCL'))
    CREATE UNIQUE INDEX UX_SALES_DLV_EXCL ON dbo.TBL_SALES_DLV_EXCL (COMP_CD, CUST_CD, PROD_CD);
GO

/* 납품분 조회에서 NOT EXISTS 로 걸러낼 때 쓰는 길 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALES_DLV_EXCL_CUST' AND object_id=OBJECT_ID('dbo.TBL_SALES_DLV_EXCL'))
    CREATE INDEX IX_SALES_DLV_EXCL_CUST ON dbo.TBL_SALES_DLV_EXCL (COMP_CD, CUST_CD, ACTION_YN);
GO
