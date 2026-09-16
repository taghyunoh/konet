/* =====================================================================
   비용 스키마 · 순마진 (2026-09-16 P2-e, 설계 = docs/설계_비용스키마_순마진_2026-09-16.md)
     · TBL_EXPENSE_ITEM : 비용 항목 마스터 — 「무엇을 비용으로 세는가」. AUTO_SRC='PARCEL' 항목은 직송 택배 운임을
                          자동으로 센다(수기 입력 없음 · 근거 = 택배출고관리 직송 출고 × 사업장 운임)
     · TBL_EXPENSE_TRX  : 달 × 항목 한 줄(수기 금액). UNIQUE(COMP_CD, EXP_YM, ITEM_CD)
     · TBL_CLOSING_MST  : EXPENSE_AMT(그 달 비용 합계 = 자동 운임 + 수기) · NET_MARGIN_AMT(순마진 = MARGIN_AMT − EXPENSE_AMT)
                          MARGIN_AMT 는 그대로 «매출총이익» — 옛 확정분이 안 깨진다(화면 이름만 바꿈)
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF … IS NULL / MERGE).
   ⚠GO 로 묶음 — 새 표·칸을 같은 배치에서 바로 쓰면 컴파일 단계에서 「없음」이 난다.
   씨앗 항목 5개는 TBL_COMP_MST 의 회사마다(없으면 W1234567) 넣는다 — 화면(비용 등록 ▸ 비용 항목)에서 고치거나 더할 수 있다.
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_EXPENSE_ITEM','U') IS NULL
CREATE TABLE dbo.TBL_EXPENSE_ITEM (
  COMP_CD   VARCHAR(20)   NOT NULL,
  ITEM_CD   VARCHAR(20)   NOT NULL,
  ITEM_NM   NVARCHAR(50)  NOT NULL,
  ITEM_GB   VARCHAR(3)    NOT NULL CONSTRAINT DF_TBL_EXPENSE_ITEM_GB   DEFAULT 'FIX',   -- FIX 고정 / VAR 변동 (표시용)
  AUTO_SRC  VARCHAR(10)   NULL,                                                         -- 'PARCEL' = 직송 택배 운임 자동 집계
  SORT_ORD  INT           NOT NULL CONSTRAINT DF_TBL_EXPENSE_ITEM_SORT DEFAULT 0,
  USE_YN    CHAR(1)       NOT NULL CONSTRAINT DF_TBL_EXPENSE_ITEM_USE  DEFAULT 'Y',
  REG_DTTM  VARCHAR(19)   NULL, REG_USER NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
  UPD_DTTM  VARCHAR(19)   NULL, UPD_USER NVARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL,
  CONSTRAINT PK_TBL_EXPENSE_ITEM PRIMARY KEY (COMP_CD, ITEM_CD)
);
GO
IF OBJECT_ID('dbo.TBL_EXPENSE_TRX','U') IS NULL
CREATE TABLE dbo.TBL_EXPENSE_TRX (
  EXP_SEQ   BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_EXPENSE_TRX PRIMARY KEY,
  COMP_CD   VARCHAR(20)   NOT NULL,
  EXP_YM    CHAR(6)       NOT NULL,                                                     -- 'YYYYMM'
  ITEM_CD   VARCHAR(20)   NOT NULL,
  AMT       DECIMAL(15,0) NOT NULL CONSTRAINT DF_TBL_EXPENSE_TRX_AMT DEFAULT 0,        -- 실제 나간 돈(세포함 — 매출·원가와 같은 잣대)
  VENDOR_CD VARCHAR(20)   NULL,
  REMARK    NVARCHAR(200) NULL,
  ACTION_YN CHAR(1)       NOT NULL CONSTRAINT DF_TBL_EXPENSE_TRX_ACT DEFAULT 'Y',
  REG_DTTM  VARCHAR(19)   NULL, REG_USER NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
  UPD_DTTM  VARCHAR(19)   NULL, UPD_USER NVARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL,
  CONSTRAINT UQ_TBL_EXPENSE_TRX UNIQUE (COMP_CD, EXP_YM, ITEM_CD)
);
GO
IF COL_LENGTH('dbo.TBL_CLOSING_MST','EXPENSE_AMT')    IS NULL ALTER TABLE dbo.TBL_CLOSING_MST ADD EXPENSE_AMT    DECIMAL(15,0) NULL;
IF COL_LENGTH('dbo.TBL_CLOSING_MST','NET_MARGIN_AMT') IS NULL ALTER TABLE dbo.TBL_CLOSING_MST ADD NET_MARGIN_AMT DECIMAL(15,0) NULL;
GO
/* ── 씨앗 항목 (있는 것은 안 건드린다) ── */
;WITH C AS ( SELECT DISTINCT COMP_CD FROM dbo.TBL_COMP_MST WHERE ISNULL(COMP_CD,'') <> ''
             UNION SELECT 'W1234567' ),
      S AS ( SELECT * FROM (VALUES
               ('PARCEL',  N'직송 택배 운임', 'VAR', 'PARCEL', 10),
               ('LABOR',   N'인건비',         'FIX', NULL,     20),
               ('VEHICLE', N'차량·유류',      'FIX', NULL,     30),
               ('RENT',    N'임차료',         'FIX', NULL,     40),
               ('ETC',     N'기타 경비',      'VAR', NULL,     90)
             ) v (ITEM_CD, ITEM_NM, ITEM_GB, AUTO_SRC, SORT_ORD) )
MERGE dbo.TBL_EXPENSE_ITEM AS t
USING ( SELECT C.COMP_CD, S.ITEM_CD, S.ITEM_NM, S.ITEM_GB, S.AUTO_SRC, S.SORT_ORD FROM C CROSS JOIN S ) AS s
   ON ( t.COMP_CD = s.COMP_CD AND t.ITEM_CD = s.ITEM_CD )
WHEN NOT MATCHED THEN
  INSERT (COMP_CD, ITEM_CD, ITEM_NM, ITEM_GB, AUTO_SRC, SORT_ORD, USE_YN, REG_DTTM, REG_USER)
  VALUES (s.COMP_CD, s.ITEM_CD, s.ITEM_NM, s.ITEM_GB, s.AUTO_SRC, s.SORT_ORD, 'Y', CONVERT(VARCHAR(19),GETDATE(),120), 'seed');
GO
/* ── 확인 ── */
SELECT COMP_CD, ITEM_CD, ITEM_NM, ITEM_GB, AUTO_SRC, SORT_ORD, USE_YN FROM dbo.TBL_EXPENSE_ITEM ORDER BY COMP_CD, SORT_ORD;
SELECT COL_LENGTH('dbo.TBL_CLOSING_MST','EXPENSE_AMT') AS expense_col, COL_LENGTH('dbo.TBL_CLOSING_MST','NET_MARGIN_AMT') AS net_col;
