/* =====================================================================================
   정산(수금/출금) 월 마감상태 — TBL_SETTLE_CLOSE_MST   MSSQL
   · 수금(RCV)·출금(PAY) 귀속월별 확정/해제 상태 보관
   · 확정(STATUS='Y') → 해당 월 수정/삭제/업로드/이월 잠금 + 다음 달 전월이월 자동 반영
   · 해제(STATUS='N') → 잠금 해제(다시 수정 가능)
   · PK = (SETTLE_GB, CLOSE_YM)
   ===================================================================================== */
USE [KOLGSDB]
GO

IF OBJECT_ID('dbo.TBL_SETTLE_CLOSE_MST','U') IS NULL
CREATE TABLE dbo.TBL_SETTLE_CLOSE_MST (
    SETTLE_GB     NVARCHAR(3)   NOT NULL,       -- 'RCV'(수금/미수) / 'PAY'(출금/미지급)
    CLOSE_YM      NVARCHAR(6)   NOT NULL,       -- 귀속월 'YYYYMM'
    STATUS        NCHAR(1)      NOT NULL DEFAULT 'Y',   -- 'Y' 확정 / 'N' 해제
    CONFIRM_DTTM  NVARCHAR(19)  NULL,           -- 최초 확정 일시
    CONFIRM_USER  NVARCHAR(50)  NULL,           -- 확정자
    UPD_DTTM      NVARCHAR(19)  NULL,
    UPD_USER      NVARCHAR(50)  NULL,
    CONSTRAINT PK_TBL_SETTLE_CLOSE_MST PRIMARY KEY (SETTLE_GB, CLOSE_YM)
);
GO
