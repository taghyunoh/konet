/* =====================================================================
   발주목록 — TBL_PO_REQ (2026-10-02 — 사용자
   「대시보드에서 현재고 앞에 적정재고 보여주고 적정재고 미달일 경우 표시하고, 실행하면 발주서등록을 위해 데이터 발생해서
     발주서등록에서 조회해서 선택 등록할 수 있게 · 조회조건 미등록/등록 구분 · 버튼 제목은 발주목록 리스트 · 거래처 선택 못하면 등록 못하게」)

   납기현황표(대시보드)의 [📋 발주목록 실행]이 «적정재고에 못 미치는 품목»을 이 표에 쌓고,
   발주서 관리의 [📋 발주목록 리스트]가 이 표를 읽어 골라 담는다.
     · 한 줄 = 한 품목의 발주 필요 건. PROD_CD 는 주코드(재고의 주인)다.
     · 수량 근거는 추천 발주와 같다 : 가용 = 현재고(음수면 0) + 입고예정(발주 잔량) · 부족 = 적정재고 − 가용 · 발주수량 = 부족을 입수 배수로 올림.
       이미 발주해 입고예정으로 채워지는 품목은 만들지 않는다(중복 발주 방지).
     · REG_YN : 'N' 미등록(아직 발주서에 안 담음) · 'Y' 등록(발주서에 담아 저장함 — PO_SEQ 로 그 발주서를 가리킨다).
       같은 품목의 미등록 줄이 이미 있으면 새로 넣지 않고 그 줄의 숫자만 고친다(실행을 여러 번 눌러도 줄이 안 쌓인다).
       발주서를 지우면 그 발주서로 등록됐던 줄은 다시 미등록이 된다.
     · VENDOR_CD/NM : 실행할 때의 대표 매입처(가장 최근 입고한 매입처, 없으면 상품코드의 거래처). 비어 있을 수 있다 —
       발주서에 담을 때는 발주서의 거래처를 골라야 한다(화면이 막는다).
     · SRC_DLV_DT : 실행할 때 대시보드에 조회해 둔 납기일자(어느 날 출고분을 보고 만들었는지).

   실행 : 사용자가 운영 DB(KOLGSDB)에서 <전체> 실행. 두 번 실행해도 안전.
   ⚠이 표가 없어도 대시보드·발주서 관리는 그대로 열린다 — [발주목록 실행]·[발주목록 리스트]만 안 된다(안내 문구가 뜬다).
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_PO_REQ','U') IS NULL
CREATE TABLE dbo.TBL_PO_REQ (
  REQ_SEQ        BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_PO_REQ PRIMARY KEY,
  COMP_CD        VARCHAR(20)    NOT NULL,
  REQ_DT         CHAR(8)        NOT NULL,
  PROD_SEQ       BIGINT         NULL,
  PROD_CD        NVARCHAR(30)   NOT NULL,
  PROD_NM        NVARCHAR(200)  NULL,
  SPEC           NVARCHAR(100)  NULL,
  PACK_QTY       DECIMAL(19,2)  NULL,
  IN_PRICE       DECIMAL(19,2)  NULL,
  TAX_GB         NVARCHAR(10)   NULL,
  SAFE_STOCK     DECIMAL(19,2)  NULL,
  CUR_QTY        DECIMAL(19,2)  NULL,
  PO_REMAIN_QTY  DECIMAL(19,2)  NULL,
  SHORT_QTY      DECIMAL(19,2)  NULL,
  REQ_QTY        DECIMAL(19,2)  NULL,
  VENDOR_CD      NVARCHAR(30)   NULL,
  VENDOR_NM      NVARCHAR(100)  NULL,
  SRC_DLV_DT     CHAR(8)        NULL,
  REG_YN         CHAR(1)        NOT NULL CONSTRAINT DF_TBL_PO_REQ_REG DEFAULT 'N',
  PO_SEQ         BIGINT         NULL,
  PO_REG_DTTM    VARCHAR(19)    NULL,
  PO_REG_USER    NVARCHAR(50)   NULL,
  ACTION_YN      CHAR(1)        NOT NULL CONSTRAINT DF_TBL_PO_REQ_ACT DEFAULT 'Y',
  REG_DTTM       VARCHAR(19)    NULL,
  REG_USER       NVARCHAR(50)   NULL,
  REG_IP         NVARCHAR(50)   NULL,
  UPD_DTTM       VARCHAR(19)    NULL,
  UPD_USER       NVARCHAR(50)   NULL,
  UPD_IP         NVARCHAR(50)   NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_PO_REQ_PROD' AND object_id = OBJECT_ID('dbo.TBL_PO_REQ'))
  CREATE INDEX IX_TBL_PO_REQ_PROD ON dbo.TBL_PO_REQ (COMP_CD, REG_YN, PROD_CD);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_PO_REQ_PO' AND object_id = OBJECT_ID('dbo.TBL_PO_REQ'))
  CREATE INDEX IX_TBL_PO_REQ_PO ON dbo.TBL_PO_REQ (PO_SEQ);
GO
/* ── 확인 : 숫자가 나오면 표가 있는 것 ── */
SELECT OBJECT_ID('dbo.TBL_PO_REQ','U') AS tbl,
       (SELECT COUNT(*) FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TBL_PO_REQ') AND name LIKE 'IX_TBL_PO_REQ%') AS idx,
       (SELECT COUNT(*) FROM dbo.TBL_PO_REQ) AS cnt;
