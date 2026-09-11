/* ============================================================================
   판매등록 전표 — TBL_SALES_TRX_MST / TBL_SALES_TRX_DTL      2026-07-25
   ----------------------------------------------------------------------------
   ★ 왜 TBL_SALES_MST 를 안 쓰는가
     TBL_SALES_MST 는 출고장이 준 정산서 엑셀을 담는 '업로드 적재표'다.
     같은 (납품일자 + 출고장) 을 다시 올리면 markSalesHistory 가
       UPDATE TBL_SALES_MST SET ACTION_YN='N' WHERE DLV_DT=… AND DC_NM=…
     로 그 날짜·그 출고장의 기존 활성행을 통째로 죽이고 JOB_SEQ+1 배치를 새로 넣는다.
     여기에 손으로 친 판매를 섞어두면 정산서를 재업로드하는 순간 같이 죽는다.
     또 낱알이 발주번호(ORD_NO)+발주항번이라 발주 없는 직접판매는 담을 자리도 없다.
     → 판매등록은 매입등록과 대칭인 별도 전표표를 쓴다.

   ★ 구조는 TBL_PURCHASE_MST / DTL 과 같게 맞췄다 (컬럼명·타입 동일)
     · 전표번호 = SALE_DT(yyyymmdd) + SALE_NO('0001')  — 일자별 순번, 매입과 같은 체계
     · 삭제는 ACTION_YN='N' (물리삭제 안 함)
     · 저장 시 재고원장(TBL_STOCK_LEDGER) 출고행을 파생 생성 : REF_GB='SALE'
     · 원장(selectCustLedger)의 매출 열은 정산서 + 이 표를 함께 더한다

   ★ 매입과 다른 칸
     · CUST_CD/CUST_NM  : 매출처 (매입의 VENDOR_CD 자리)
     · DLV_DT           : 납품일자 — 정산서의 DLV_DT 와 같은 뜻. 원장 귀속일
     · TAX_GB           : 과세/면세
   ============================================================================ */

IF OBJECT_ID('TBL_SALES_TRX_MST','U') IS NULL
BEGIN
CREATE TABLE TBL_SALES_TRX_MST (
    SALE_SEQ      int IDENTITY(1,1) NOT NULL,
    SALE_DT       varchar(8)    NOT NULL,   -- 판매일자 yyyymmdd
    SALE_NO       varchar(4)    NOT NULL,   -- 그날의 순번 '0001'
    DLV_DT        varchar(8)        NULL,   -- 납품일자(원장 귀속일). 비면 SALE_DT 로 본다
    CUST_CD       varchar(20)       NULL,   -- 매출처
    CUST_NM       nvarchar(100)     NULL,
    MGR_CD        varchar(20)       NULL,   -- 담당사원
    MGR_NM        nvarchar(50)      NULL,
    WH_CD         varchar(20)       NULL,   -- 출고 창고
    WH_NM         nvarchar(50)      NULL,
    TOT_BOX_QTY   decimal(19,2)     NULL,
    TOT_EA_QTY    decimal(19,2)     NULL,
    TOT_QTY       decimal(19,2)     NULL,
    SUPPLY_AMT    decimal(19,2)     NULL,   -- 공급가
    VAT_AMT       decimal(19,2)     NULL,   -- 부가세
    TOT_AMT       decimal(19,2)     NULL,   -- 합계 = 공급가 + 부가세
    DC_AMT        decimal(19,2)     NULL,   -- 매출할인
    PAY_GB        varchar(20)       NULL,   -- 현금/카드/외상 …
    PAY_AMT       decimal(19,2)     NULL,   -- 전표에서 바로 받은 금액
    TAX_GB        varchar(10)       NULL,   -- 과세/면세
    REMARK        nvarchar(500)     NULL,
    ACTION_YN     char(1)       NOT NULL CONSTRAINT DF_SALES_TRX_MST_ACT DEFAULT('Y'),
    REG_DTTM      varchar(19)       NULL,
    REG_USER      nvarchar(50)      NULL,
    REG_IP        varchar(45)       NULL,
    UPD_DTTM      varchar(19)       NULL,
    UPD_USER      nvarchar(50)      NULL,
    UPD_IP        varchar(45)       NULL,
    CONSTRAINT PK_TBL_SALES_TRX_MST PRIMARY KEY CLUSTERED (SALE_SEQ)
);
CREATE INDEX IX_SALES_TRX_MST_DT   ON TBL_SALES_TRX_MST(SALE_DT, SALE_NO);
CREATE INDEX IX_SALES_TRX_MST_CUST ON TBL_SALES_TRX_MST(CUST_CD, DLV_DT);
END
GO

IF OBJECT_ID('TBL_SALES_TRX_DTL','U') IS NULL
BEGIN
CREATE TABLE TBL_SALES_TRX_DTL (
    DTL_SEQ       int IDENTITY(1,1) NOT NULL,
    SALE_SEQ      int           NOT NULL,   -- → TBL_SALES_TRX_MST.SALE_SEQ
    ROW_NO        int           NOT NULL,   -- 명세 줄번호 1,2,3 …
    PROD_SEQ      int               NULL,
    PROD_CD       varchar(20)       NULL,
    PROD_NM       nvarchar(200)     NULL,
    SPEC          nvarchar(100)     NULL,
    PACK_QTY      decimal(19,2)     NULL,   -- 입수
    BOX_QTY       decimal(19,2)     NULL,
    EA_QTY        decimal(19,2)     NULL,
    QTY           decimal(19,2)     NULL,   -- 총수량 = 박스*입수 + 낱개
    UNIT_PRICE    decimal(19,2)     NULL,   -- 판매단가
    AMT           decimal(19,2)     NULL,
    DC_AMT        decimal(19,2)     NULL,
    SUPPLY_AMT    decimal(19,2)     NULL,
    VAT_AMT       decimal(19,2)     NULL,
    TOT_AMT       decimal(19,2)     NULL,
    SERVICE_QTY   decimal(19,2)     NULL,   -- 서비스(무상) 수량
    REMARK        nvarchar(200)     NULL,
    EVENT_YN      char(1)           NULL,
    TRX_GB        varchar(10)       NULL,   -- 판매 / 반품
    LEDGER_SEQ    int               NULL,   -- 파생 생성한 재고원장 행
    ACTION_YN     char(1)       NOT NULL CONSTRAINT DF_SALES_TRX_DTL_ACT DEFAULT('Y'),
    REG_DTTM      varchar(19)       NULL,
    REG_USER      nvarchar(50)      NULL,
    REG_IP        varchar(45)       NULL,
    UPD_DTTM      varchar(19)       NULL,
    UPD_USER      nvarchar(50)      NULL,
    UPD_IP        varchar(45)       NULL,
    CONSTRAINT PK_TBL_SALES_TRX_DTL PRIMARY KEY CLUSTERED (DTL_SEQ)
);
CREATE INDEX IX_SALES_TRX_DTL_MST  ON TBL_SALES_TRX_DTL(SALE_SEQ);
CREATE INDEX IX_SALES_TRX_DTL_PROD ON TBL_SALES_TRX_DTL(PROD_CD, SALE_SEQ);
END
GO
