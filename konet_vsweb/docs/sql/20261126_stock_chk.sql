/* ══════════════════════════════════════════════════════════════════════════
   재고 변동 확인 (2026-11-26) — 손으로 넣은 전표(매입·판매·반품)를 재고 담당자가 확인
   사용자 「재고담당자가 입고·판매 관련 내용을 보고 재고에 반영할지, 적용 안 할지 관리」 → 「반영 후 확인 방식으로 진행해줘」
          「삭제한 것은 … 재고에서 제외 여부 있어야 250 재고로 포함 나옴」(같은 날 — 품목 단위로)

   · 전표는 지금처럼 저장·삭제하는 순간 재고에 반영된다. 담당자는 [재고 변동 확인] 화면에서 [확인] 하거나 [재고에서 제외] 한다.
   · 표 = 전표마다 한 줄(PROD_SEQ = 0 — 확인 C · 전표 전체 제외 X) + 품목마다 한 줄(PROD_SEQ = 품목 — 그 품목만 제외 X).
     - 살아 있는 전표를 제외 = 그 전표(품목)의 재고 원장 줄이 ACTION_YN 'X' → 재고 수량에서만 빠진다(매입·매출 금액은 그대로).
     - 지운 전표를 제외 = «삭제를 재고에 반영하지 않는다» → 지울 때 빠진 원장 줄이 되살아난다(근거구분 PURCHK · SALEK).
   · 「시작 표시」 한 줄(REF_GB = 'START') — 이 스크립트를 «처음» 돌린 때부터 생긴(등록·수정·삭제된) 전표만 «미확인» 으로 센다.

   ★여러 번 돌려도 된다 — 표가 없으면 만들고, 있으면(2026-11-26 오전 판) 품목 칸(PROD_SEQ)만 더한다. 시작 시각·기록은 그대로. 지금 재고는 하나도 바뀌지 않는다.
   ★순서 : 이 스크립트 → 새 WAR. (칸이 없어도 새 WAR 의 전표 저장·재고 계산은 그대로 돈다 — 화면만 「표를 먼저 만들어 주세요」.)
   ══════════════════════════════════════════════════════════════════════════ */
IF OBJECT_ID('dbo.TBL_STOCK_CHK', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.TBL_STOCK_CHK (
    CHK_SEQ    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_STOCK_CHK PRIMARY KEY,
    COMP_CD    VARCHAR(10)   NOT NULL,
    REF_GB     VARCHAR(10)   NOT NULL,   -- PURCH 매입전표 · SALE 판매전표 · START 시작 표시
    REF_SEQ    INT           NOT NULL,   -- 전표 키(PURCH_SEQ · SALE_SEQ) · 시작 표시는 0
    PROD_SEQ   INT           NOT NULL CONSTRAINT DF_TBL_STOCK_CHK_PROD DEFAULT 0,   -- 0 = 전표 전체 · 그 밖 = 그 품목만(제외)
    STATE      CHAR(1)       NOT NULL,   -- C 확인(전표) · X 재고에서 제외(전표 전체 또는 품목) · S 시작 표시
    VER_DTTM   VARCHAR(19)   NULL,       -- 처리할 때 그 전표의 «마지막 변경 시각»(수정·삭제한 때, 없으면 등록한 때) — 확인 뒤에 또 바뀌면 다시 미확인
    MEMO       NVARCHAR(200) NULL,       -- 제외 사유 등
    REG_DTTM   VARCHAR(19)   NULL,
    REG_USER   NVARCHAR(50)  NULL,
    REG_IP     VARCHAR(45)   NULL,
    UPD_DTTM   VARCHAR(19)   NULL,
    UPD_USER   NVARCHAR(50)  NULL,
    UPD_IP     VARCHAR(45)   NULL
  );
END
GO

/* 오전 판(전표 단위)으로 이미 만든 표 — 품목 칸을 더한다 */
IF COL_LENGTH('dbo.TBL_STOCK_CHK', 'PROD_SEQ') IS NULL
  ALTER TABLE dbo.TBL_STOCK_CHK ADD PROD_SEQ INT NOT NULL CONSTRAINT DF_TBL_STOCK_CHK_PROD DEFAULT 0;
GO

/* 한 줄 = 전표 + 품목 */
IF EXISTS ( SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TBL_STOCK_CHK') AND name = 'UX_TBL_STOCK_CHK_REF' )
  DROP INDEX UX_TBL_STOCK_CHK_REF ON dbo.TBL_STOCK_CHK;
GO
IF NOT EXISTS ( SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TBL_STOCK_CHK') AND name = 'UX_TBL_STOCK_CHK_REF2' )
  CREATE UNIQUE INDEX UX_TBL_STOCK_CHK_REF2 ON dbo.TBL_STOCK_CHK (COMP_CD, REF_GB, REF_SEQ, PROD_SEQ);
GO

/* 시작 표시 — 회사마다 한 줄. 이미 있으면 그대로 둔다(다시 돌려도 시작 시각이 안 바뀐다) */
INSERT INTO dbo.TBL_STOCK_CHK (COMP_CD, REF_GB, REF_SEQ, PROD_SEQ, STATE, VER_DTTM, MEMO, REG_DTTM, REG_USER)
SELECT c.COMP_CD, 'START', 0, 0, 'S', CONVERT(VARCHAR(19), GETDATE(), 120), N'재고 변동 확인 시작', CONVERT(VARCHAR(19), GETDATE(), 120), 'ddl'
  FROM ( SELECT DISTINCT COMP_CD FROM dbo.TBL_PURCHASE_MST WHERE ISNULL(COMP_CD,'') <> ''
         UNION SELECT DISTINCT COMP_CD FROM dbo.TBL_SALES_TRX_MST WHERE ISNULL(COMP_CD,'') <> '' ) c
 WHERE NOT EXISTS ( SELECT 1 FROM dbo.TBL_STOCK_CHK x WHERE x.COMP_CD = c.COMP_CD AND x.REF_GB = 'START' AND x.REF_SEQ = 0 );
GO

/* 확인 */
SELECT COMP_CD, REF_GB, STATE, VER_DTTM AS 시작시각, COL_LENGTH('dbo.TBL_STOCK_CHK', 'PROD_SEQ') AS 품목칸 FROM dbo.TBL_STOCK_CHK WHERE REF_GB = 'START';
