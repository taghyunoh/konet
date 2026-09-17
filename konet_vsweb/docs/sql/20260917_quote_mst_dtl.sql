/* =====================================================================
   견적서 관리 (2026-09-17 — 「견적서 엑셀을 입고예약서처럼 올리고 저장, 일자·담당자·문서번호로 관리」)
     · TBL_QUOTE_MST : 견적서 머리 — 문서번호(Konet260729-01)·견적일·수신처·담당자·유효기간·비고·공급가 합계 + 원본 파일(base64)
     · TBL_QUOTE_DTL : 품목 줄 — 품명·규격·Box수·수량(ea)·단가·금액·비고
     · 같은 회사·같은 문서번호를 다시 올리면 앞의 것을 이력(ACTION_YN='N')으로 닫고 새로 넣는다(화면 [저장] = 대체)
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF … IS NULL).
   ⚠WAR 배포 <전에> 실행할 것 — 견적서 관리 화면이 이 표를 읽는다(다른 화면은 영향 없음).
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_QUOTE_MST','U') IS NULL
CREATE TABLE dbo.TBL_QUOTE_MST (
  QUOTE_SEQ   BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_QUOTE_MST PRIMARY KEY,
  COMP_CD     VARCHAR(20)    NOT NULL,
  DOC_NO      NVARCHAR(50)   NOT NULL,                                                  -- 문서번호 (예 Konet260729-01)
  QUOTE_DT    CHAR(8)        NULL,                                                      -- 견적일 'YYYYMMDD'
  RECV_NM     NVARCHAR(100)  NULL,                                                      -- 수신 (예 삼성웰스토리)
  MGR_NM      NVARCHAR(50)   NULL,                                                      -- 담당자 (예 김정호 프로님)
  VALID_TXT   NVARCHAR(100)  NULL,                                                      -- 유효기간 (글 그대로)
  TITLE_TXT   NVARCHAR(200)  NULL,                                                      -- 「아래와 같이 견적을 드립니다.(센타배송, 부가세 별도)」
  REMARK      NVARCHAR(1000) NULL,                                                      -- 아래 비고 줄들
  SUPPLY_AMT  DECIMAL(15,0)  NOT NULL CONSTRAINT DF_TBL_QUOTE_MST_AMT DEFAULT 0,       -- 금액 합(부가세 별도)
  FILE_NM     NVARCHAR(200)  NULL,                                                      -- 올린 파일 이름
  FILE_B64    NVARCHAR(MAX)  NULL,                                                      -- 원본 파일(base64) — [원본 내려받기]
  ACTION_YN   CHAR(1)        NOT NULL CONSTRAINT DF_TBL_QUOTE_MST_ACT DEFAULT 'Y',     -- Y 활성 · N 대체된 이력 · D 삭제
  REG_DTTM    VARCHAR(19)    NULL, REG_USER NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
  UPD_DTTM    VARCHAR(19)    NULL, UPD_USER NVARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL
);
GO
IF OBJECT_ID('dbo.TBL_QUOTE_DTL','U') IS NULL
CREATE TABLE dbo.TBL_QUOTE_DTL (
  QUOTE_DTL_SEQ BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_QUOTE_DTL PRIMARY KEY,
  QUOTE_SEQ   BIGINT         NOT NULL,
  ROW_NO      INT            NOT NULL,
  PROD_NM     NVARCHAR(200)  NULL,
  SPEC        NVARCHAR(300)  NULL,
  BOX_QTY     DECIMAL(15,3)  NULL,                                                      -- 단위 칸의 Box 수
  UNIT        NVARCHAR(20)   NULL,                                                      -- 수량 단위(보통 ea)
  QTY         DECIMAL(15,3)  NOT NULL CONSTRAINT DF_TBL_QUOTE_DTL_QTY DEFAULT 0,
  UNIT_PRICE  DECIMAL(15,2)  NOT NULL CONSTRAINT DF_TBL_QUOTE_DTL_PRC DEFAULT 0,
  AMT         DECIMAL(15,0)  NOT NULL CONSTRAINT DF_TBL_QUOTE_DTL_AMT DEFAULT 0,
  REMARK      NVARCHAR(200)  NULL,                                                      -- 예 MOQ : 50,000개
  PROD_CD     NVARCHAR(30)   NULL                                                       -- 우리 품목코드(나중에 이어 쓸 자리, 지금은 비움)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_QUOTE_MST_DOC' AND object_id = OBJECT_ID('dbo.TBL_QUOTE_MST'))
  CREATE INDEX IX_TBL_QUOTE_MST_DOC ON dbo.TBL_QUOTE_MST (COMP_CD, DOC_NO, ACTION_YN);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_QUOTE_DTL_MST' AND object_id = OBJECT_ID('dbo.TBL_QUOTE_DTL'))
  CREATE INDEX IX_TBL_QUOTE_DTL_MST ON dbo.TBL_QUOTE_DTL (QUOTE_SEQ);
GO
/* ── 확인 ── */
SELECT OBJECT_ID('dbo.TBL_QUOTE_MST','U') AS mst, OBJECT_ID('dbo.TBL_QUOTE_DTL','U') AS dtl;
