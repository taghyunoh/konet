/* =====================================================================
   비용 내역 (2026-09-17 — 비용 등록 「기타경비 여기에서 등록 · 추가 발생 시 해당 월 목록에 추가 · 체크」)
     · TBL_EXPENSE_DTL : 달 × 항목 아래 여러 줄(일자·내용·금액·비고·확인 체크). 주로 ETC(기타 경비)에 쓰지만 수기 항목 어디든 된다.
     · 내역이 한 줄이라도 있는 달·항목은 TBL_EXPENSE_TRX.AMT 를 내역 합계로 굳힌다(매퍼 syncExpenseTrxFromDtl) —
       마감 확정(expenseSumOf)은 TRX 만 읽으므로 순마진까지 저절로 맞는다. 화면에서 그 항목 금액 칸은 읽기 전용이 된다.
     · CHK_YN = 「확인」 체크(지급·처리 표시). 합계 계산엔 영향 없다 — 표시용.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF … IS NULL).
   표가 없으면 화면은 내역 칸만 「표가 아직 없습니다」로 보이고 나머지는 종전대로 돈다.
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_EXPENSE_DTL','U') IS NULL
CREATE TABLE dbo.TBL_EXPENSE_DTL (
  DTL_SEQ   BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_EXPENSE_DTL PRIMARY KEY,
  COMP_CD   VARCHAR(20)   NOT NULL,
  EXP_YM    CHAR(6)       NOT NULL,                                                     -- 'YYYYMM' (귀속월)
  ITEM_CD   VARCHAR(20)   NOT NULL,                                                     -- TBL_EXPENSE_ITEM.ITEM_CD (주로 'ETC')
  EXP_DT    CHAR(8)       NULL,                                                         -- 'YYYYMMDD' 발생일(선택)
  TITLE     NVARCHAR(100) NULL,                                                         -- 내용 (소모품·식대 …)
  AMT       DECIMAL(15,0) NOT NULL CONSTRAINT DF_TBL_EXPENSE_DTL_AMT DEFAULT 0,        -- 실제 나간 돈(세포함)
  REMARK    NVARCHAR(200) NULL,
  CHK_YN    CHAR(1)       NOT NULL CONSTRAINT DF_TBL_EXPENSE_DTL_CHK DEFAULT 'N',      -- 확인 체크
  ACTION_YN CHAR(1)       NOT NULL CONSTRAINT DF_TBL_EXPENSE_DTL_ACT DEFAULT 'Y',
  REG_DTTM  VARCHAR(19)   NULL, REG_USER NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
  UPD_DTTM  VARCHAR(19)   NULL, UPD_USER NVARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_EXPENSE_DTL_YM' AND object_id = OBJECT_ID('dbo.TBL_EXPENSE_DTL'))
  CREATE INDEX IX_TBL_EXPENSE_DTL_YM ON dbo.TBL_EXPENSE_DTL (COMP_CD, EXP_YM, ITEM_CD, ACTION_YN);
GO
/* ── 확인 ── */
SELECT OBJECT_ID('dbo.TBL_EXPENSE_DTL','U') AS dtl_table, COUNT(*) AS rows_now FROM dbo.TBL_EXPENSE_DTL;
