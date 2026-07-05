/* =====================================================================================
   수금/미수금 관리 — TBL_RECEIVE_MST (거래처 × 귀속월 미수금 현황)  MSSQL
   · 데모(전월이월·당월매출·당월수금·미수잔액·상태) 기준 컬럼 구성
   · 미수잔액 = 전월이월 + 당월매출 − 당월수금 (조회/화면에서 계산)
   · 상태     = 미수잔액 > 0 → '미수' / else '완납' (계산)
   · PK = RCV_SEQ IDENTITY, (귀속월+거래처) UNIQUE — 엑셀업로드는 이 키로 upsert
   ===================================================================================== */
USE [KOLGSDB]
GO

IF OBJECT_ID('dbo.TBL_RECEIVE_MST','U') IS NULL
CREATE TABLE dbo.TBL_RECEIVE_MST (
    RCV_SEQ      INT IDENTITY(1,1) NOT NULL,   -- PK
    RCV_YM       NVARCHAR(6)    NOT NULL,       -- 귀속월 'YYYYMM'
    BIZ_CD       NVARCHAR(20)   NULL,           -- 거래처(사업장)코드
    BIZ_NM       NVARCHAR(100)  NULL,           -- 거래처명
    PREV_AMT     DECIMAL(18,2)  NULL,           -- 전월이월(미수)
    SALES_AMT    DECIMAL(18,2)  NULL,           -- 당월매출
    COLLECT_AMT  DECIMAL(18,2)  NULL,           -- 당월수금
    COLLECT_DT   NVARCHAR(8)    NULL,           -- 최근 수금일자 'YYYYMMDD'
    PAY_GB       NVARCHAR(20)   NULL,           -- 수금방법(현금/카드/계좌이체 등)
    REMARK       NVARCHAR(500)  NULL,           -- 비고
    ACTION_YN    NCHAR(1)       NOT NULL DEFAULT 'Y',
    REG_DTTM     NVARCHAR(19)   NULL,
    REG_USER     NVARCHAR(50)   NULL,
    REG_IP       NVARCHAR(50)   NULL,
    UPD_DTTM     NVARCHAR(19)   NULL,
    UPD_USER     NVARCHAR(50)   NULL,
    UPD_IP       NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_RECEIVE_MST PRIMARY KEY (RCV_SEQ),
    CONSTRAINT UQ_TBL_RECEIVE_MST UNIQUE (RCV_YM, BIZ_CD)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RECEIVE_YM' AND object_id=OBJECT_ID('dbo.TBL_RECEIVE_MST'))
    CREATE INDEX IX_RECEIVE_YM ON dbo.TBL_RECEIVE_MST (RCV_YM, BIZ_NM);
GO
