/* =====================================================================
   상품코드 계약(납품기간) 이력 — TBL_PROD_CONTRACT (2026-10-01 — 사용자
   「삼성하고 계약으로 이루어진 코드 · 엑셀로 제공 · 신규코드는 납품기간(from~to)이 있어야 함(상품코드에 등록) ·
     기존코드는 이력관리해서 입력되게 · 기존 시스템은 날짜 도래 시 입력했다고 함」)

   삼성웰스토리가 주는 계약 엑셀(품목코드 · 품명 · 단위 · 계약단가 · 납품기간 From~To)을 상품코드 등록 화면에서 올린다.
     · 한 줄 = 한 품목의 한 번의 계약. 같은 품목에 계약이 다시 오면 줄이 하나 더 쌓인다(= 이력).
       같은 (품목 · 납품 시작일)을 다시 올리면 앞의 줄을 닫고(ACTION_YN='N') 새 줄을 넣는다.
     · FR_DT ~ TO_DT   : 납품기간. 계약단가는 FR_DT 부터 적용된다.
     · CONTRACT_PRICE  : 계약단가. 저장할 때 판매가 이력(TBL_PROD_SALEPRICE_HST · 공통가 · APPLY_DT = FR_DT)에도 한 줄 넣는다 —
                         발주·출고 마감이 「적용일 <= 발주일 중 최신」으로 단가를 집으므로 날짜가 되면 저절로 새 단가가 걸린다.
     · APPLIED_YN      : 상품코드의 판매단가(TBL_PROD_MST.SALE_PRICE)에 반영했는지.
                         FR_DT 가 오늘 이전이면 저장할 때 바로 Y. 미래면 N 으로 두었다가, 그 날짜가 된 뒤 상품 목록을 읽을 때 반영하고 Y 로 바꾼다.
     · NEW_YN          : 이 계약으로 상품코드를 새로 만들었으면 Y(신규코드).
     · PREV_PRICE      : 올릴 때의 상품코드 판매단가(바뀌기 전 값).
     · TO_DT 가 지나도 단가는 그대로 둔다 — 화면이 「계약 만료」(30일 전부터 「만료 임박」)만 표시한다(사용자 결정).
     · 배송구분 · 물류비율 · 수수료율은 저장하지 않는다(사용자 결정).

   실행 : 사용자가 운영 DB(KOLGSDB)에서 <전체> 실행. 두 번 실행해도 안전.
   ⚠WAR 배포 <전에> 실행할 것. 이 표가 없어도 상품 목록·저장은 그대로 되고, 계약 엑셀 올리기만 안 된다.
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_PROD_CONTRACT','U') IS NULL
CREATE TABLE dbo.TBL_PROD_CONTRACT (
  CONTRACT_SEQ    BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_PROD_CONTRACT PRIMARY KEY,
  COMP_CD         VARCHAR(10)    NOT NULL,
  PROD_SEQ        BIGINT         NULL,
  PROD_CD         NVARCHAR(30)   NOT NULL,
  PROD_NM         NVARCHAR(300)  NULL,
  UNIT            NVARCHAR(20)   NULL,
  TAX_GB          NVARCHAR(10)   NULL,
  CONTRACT_PRICE  DECIMAL(18,2)  NOT NULL,
  PREV_PRICE      DECIMAL(18,2)  NULL,
  FR_DT           CHAR(8)        NOT NULL,
  TO_DT           CHAR(8)        NULL,
  NEW_YN          CHAR(1)        NULL,
  APPLIED_YN      CHAR(1)        NULL,
  APPLIED_DTTM    VARCHAR(19)    NULL,
  SRC_FILE        NVARCHAR(200)  NULL,
  REMARK          NVARCHAR(300)  NULL,
  ACTION_YN       CHAR(1)        NOT NULL CONSTRAINT DF_TBL_PROD_CONTRACT_ACT DEFAULT 'Y',
  REG_DTTM        VARCHAR(19)    NULL,
  REG_USER        NVARCHAR(50)   NULL,
  REG_IP          NVARCHAR(50)   NULL,
  UPD_DTTM        VARCHAR(19)    NULL,
  UPD_USER        NVARCHAR(50)   NULL,
  UPD_IP          NVARCHAR(50)   NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_PROD_CONTRACT_CD' AND object_id = OBJECT_ID('dbo.TBL_PROD_CONTRACT'))
  CREATE INDEX IX_TBL_PROD_CONTRACT_CD ON dbo.TBL_PROD_CONTRACT (COMP_CD, PROD_CD, FR_DT);
GO
/* ── 확인 : 숫자가 나오면 표가 있는 것 ── */
SELECT OBJECT_ID('dbo.TBL_PROD_CONTRACT','U') AS tbl,
       (SELECT COUNT(*) FROM sys.indexes WHERE name = 'IX_TBL_PROD_CONTRACT_CD') AS idx,
       (SELECT COUNT(*) FROM dbo.TBL_PROD_CONTRACT) AS cnt;
