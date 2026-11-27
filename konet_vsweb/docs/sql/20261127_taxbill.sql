/* =====================================================================
   매출·매입 계산서 (2026-11-27 신설) — ⛔새 WAR(또는 재빌드)를 올리기 <전에> 운영DB(KOLGSDB)에서 한 번 실행. 재실행 안전.

   사용자 요청 「홀세일처럼 매출계산서, 매입계산서 (전자세금계산서 연동)」 → 「화면부터 먼저」.
     · 이번 단계 = 생성(합계·건별·상품별) · 확정 · 발행 내역 · 인쇄. **국세청 전송(전자 발행)은 중계업체 계약 뒤** —
       그때 쓸 칸(NTS_NO·ISSUE_*·ASP_KEY)만 미리 둔다.
     · 공급받는자(매출)·공급자(매입) 정보는 만들 때 거래처 마스터에서 **그 시점 값으로 복사**한다 —
       계산서는 발행 뒤 거래처 정보가 바뀌어도 그대로여야 한다.

   표 2개 — COMP_CD 로 회사를 가른다(다중회사).
     TBL_TAXBILL_MST  계산서 머리 (한 장 = 한 줄)
     TBL_TAXBILL_DTL  품목 줄 (전자세금계산서 최대 99줄)

   STATUS : W 작성 → C 확정 → I 발행(국세청 전송, 다음 단계) / 삭제 = ACTION_YN 'N'
   ===================================================================== */
SET XACT_ABORT ON;
BEGIN TRAN;

IF OBJECT_ID('dbo.TBL_TAXBILL_MST','U') IS NULL
CREATE TABLE dbo.TBL_TAXBILL_MST (
    BILL_SEQ      INT IDENTITY(1,1) NOT NULL,
    COMP_CD       VARCHAR(10)    NOT NULL,
    BILL_GB       CHAR(1)        NOT NULL,                 -- S 매출 / P 매입
    MAKE_GB       VARCHAR(4)     NOT NULL,                 -- SUM 합계 / DOC 건별 / ITEM 상품별
    BASIS_GB      VARCHAR(4)     NOT NULL CONSTRAINT DF_TAXBILL_BASIS DEFAULT 'TRX',   -- TRX 매출(매입)기준 / CASH 수금(지급)기준
    TAX_GB        NVARCHAR(4)    NOT NULL CONSTRAINT DF_TAXBILL_TAX DEFAULT N'과세',  -- 과세 / 면세(= 계산서)
    PURPOSE_GB    NVARCHAR(4)    NOT NULL CONSTRAINT DF_TAXBILL_PUR DEFAULT N'청구',  -- 청구 / 영수
    WRITE_DT      CHAR(8)        NOT NULL,                 -- 작성일자(발행일자) YYYYMMDD
    FR_DT         CHAR(8)        NULL,                     -- 묶은 거래 기간
    TO_DT         CHAR(8)        NULL,
    SRC_KEY       NVARCHAR(200)  NULL,                     -- 건별일 때 원천 전표 열쇠(중복 생성 표시용)
    CUST_CD       NVARCHAR(20)   NOT NULL,
    CUST_NM       NVARCHAR(100)  NULL,
    CUST_FULL_NM  NVARCHAR(100)  NULL,                     -- 정식 명칭(상호)
    CUST_BIZNO    NVARCHAR(20)   NULL,
    CUST_CEO_NM   NVARCHAR(50)   NULL,
    CUST_BIZ_COND NVARCHAR(100)  NULL,
    CUST_BIZ_ITEM NVARCHAR(200)  NULL,
    CUST_ADDR     NVARCHAR(400)  NULL,
    CUST_EMAIL    NVARCHAR(100)  NULL,
    SUPPLY_AMT    DECIMAL(18,0)  NOT NULL CONSTRAINT DF_TAXBILL_SUP DEFAULT 0,
    VAT_AMT       DECIMAL(18,0)  NOT NULL CONSTRAINT DF_TAXBILL_VAT DEFAULT 0,
    TOT_AMT       DECIMAL(18,0)  NOT NULL CONSTRAINT DF_TAXBILL_TOT DEFAULT 0,
    REMARK        NVARCHAR(300)  NULL,
    STATUS        CHAR(1)        NOT NULL CONSTRAINT DF_TAXBILL_STS DEFAULT 'W',
    NTS_NO        VARCHAR(40)    NULL,                     -- 국세청 승인번호(다음 단계)
    ASP_KEY       VARCHAR(60)    NULL,                     -- 중계업체 문서 관리번호(다음 단계)
    ISSUE_DTTM    DATETIME       NULL,
    ISSUE_USER    VARCHAR(50)    NULL,
    CFM_DTTM      DATETIME       NULL,
    CFM_USER      VARCHAR(50)    NULL,
    ACTION_YN     CHAR(1)        NOT NULL CONSTRAINT DF_TAXBILL_ACT DEFAULT 'Y',
    REG_USER      VARCHAR(50)    NULL,
    REG_DTTM      DATETIME       NOT NULL CONSTRAINT DF_TAXBILL_REG DEFAULT GETDATE(),
    UPD_USER      VARCHAR(50)    NULL,
    UPD_DTTM      DATETIME       NULL,
    CONSTRAINT PK_TAXBILL_MST PRIMARY KEY (BILL_SEQ)
);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TAXBILL_MST_Q' AND object_id = OBJECT_ID('dbo.TBL_TAXBILL_MST'))
CREATE INDEX IX_TAXBILL_MST_Q ON dbo.TBL_TAXBILL_MST (COMP_CD, BILL_GB, WRITE_DT) INCLUDE (CUST_CD, STATUS, ACTION_YN);

IF OBJECT_ID('dbo.TBL_TAXBILL_DTL','U') IS NULL
CREATE TABLE dbo.TBL_TAXBILL_DTL (
    BILL_SEQ      INT            NOT NULL,
    LINE_NO       INT            NOT NULL,
    ITEM_DT       CHAR(8)        NULL,                     -- 품목 일자(YYYYMMDD — 계산서엔 월·일만 찍힌다)
    ITEM_CD       NVARCHAR(40)   NULL,
    ITEM_NM       NVARCHAR(200)  NULL,
    SPEC          NVARCHAR(100)  NULL,
    QTY           DECIMAL(18,2)  NULL,
    PRICE         DECIMAL(18,2)  NULL,                     -- 공급가 단가
    SUPPLY_AMT    DECIMAL(18,0)  NOT NULL CONSTRAINT DF_TAXBILL_DTL_SUP DEFAULT 0,
    VAT_AMT       DECIMAL(18,0)  NOT NULL CONSTRAINT DF_TAXBILL_DTL_VAT DEFAULT 0,
    REMARK        NVARCHAR(200)  NULL,
    CONSTRAINT PK_TAXBILL_DTL PRIMARY KEY (BILL_SEQ, LINE_NO)
);

COMMIT;

-- 확인 : 두 표가 보이면 끝
SELECT name FROM sys.tables WHERE name IN ('TBL_TAXBILL_MST','TBL_TAXBILL_DTL');
