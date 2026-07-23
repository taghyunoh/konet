/* =====================================================================================
   출금/미지급 관리 — TBL_PAYMENT_MST (매입처 × 귀속월 미지급금 현황)  MSSQL
   · 수금/미수금(TBL_RECEIVE_MST)의 매입(지급) 쪽 대칭 테이블
   · 미지급잔액 = 전월이월 + 당월매입 − 당월출금 (조회/화면에서 계산)
   · 상태       = 미지급잔액 > 0 → '미지급' / else '완납' (계산)
   · PK = PAY_SEQ IDENTITY, (귀속월+매입처) UNIQUE — 엑셀업로드는 이 키로 upsert
   ===================================================================================== */
USE [KOLGSDB]
GO

IF OBJECT_ID('dbo.TBL_PAYMENT_MST','U') IS NULL
CREATE TABLE dbo.TBL_PAYMENT_MST (
    PAY_SEQ      INT IDENTITY(1,1) NOT NULL,   -- PK
    PAY_YM       NVARCHAR(6)    NOT NULL,       -- 귀속월 'YYYYMM'
    BIZ_CD       NVARCHAR(20)   NULL,           -- 매입처(거래처)코드
    BIZ_NM       NVARCHAR(100)  NULL,           -- 매입처명
    PREV_AMT     DECIMAL(18,2)  NULL,           -- 전월이월(미지급)
    PURCH_AMT    DECIMAL(18,2)  NULL,           -- 당월매입
    PAYOUT_AMT   DECIMAL(18,2)  NULL,           -- 당월출금(지급)
    PAYOUT_DT    NVARCHAR(8)    NULL,           -- 최근 출금일자 'YYYYMMDD'
    PAY_GB       NVARCHAR(20)   NULL,           -- 지급방법(현금/계좌이체/어음 등)
    REMARK       NVARCHAR(500)  NULL,           -- 비고
    ACTION_YN    NCHAR(1)       NOT NULL DEFAULT 'Y',
    REG_DTTM     NVARCHAR(19)   NULL,
    REG_USER     NVARCHAR(50)   NULL,
    REG_IP       NVARCHAR(50)   NULL,
    UPD_DTTM     NVARCHAR(19)   NULL,
    UPD_USER     NVARCHAR(50)   NULL,
    UPD_IP       NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_PAYMENT_MST PRIMARY KEY (PAY_SEQ),
    CONSTRAINT UQ_TBL_PAYMENT_MST UNIQUE (PAY_YM, BIZ_CD)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PAYMENT_YM' AND object_id=OBJECT_ID('dbo.TBL_PAYMENT_MST'))
    CREATE INDEX IX_PAYMENT_YM ON dbo.TBL_PAYMENT_MST (PAY_YM, BIZ_NM);
GO
