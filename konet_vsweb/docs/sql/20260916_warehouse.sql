/* =====================================================================
   창고별 재고 1단계 (2026-09-16 P3, 설계 = docs/설계_창고별재고_2026-09-16.md — 사용자 「창고는 3개 · 설정할 수 있게」)
     · TBL_WH_MST            : 창고 마스터(회사 × 창고). 화면(기준정보관리 ▸ 창고 관리)에서 이름·기본창고·차례·사용을 고친다
     · TBL_STOCK_LEDGER.WH_CD: 원장 행마다 창고. **기존 행은 전부 WH1(기본창고)** — 지금 재고가 곧 제1창고 재고가 된다
     · 창고 간 이동 = 원장 A 행 한 쌍(보내는 창고 −수량 · 받는 창고 +수량, REF_GB='MOVE', 같은 REF_NO) — 새 표 없음
     · 출고 자동연동(발주현황표·정산서)은 1단계에서 **기본창고(DEFAULT_YN='Y')** 로 나간다(발주현황표엔 창고가 없다)
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF … IS NULL / NOT EXISTS).
   ⚠GO 로 묶음 — 새 표·칸을 같은 배치에서 바로 쓰면 컴파일 단계에서 「없음」이 난다.
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_WH_MST','U') IS NULL
CREATE TABLE dbo.TBL_WH_MST (
  COMP_CD    VARCHAR(20)  NOT NULL,
  WH_CD      VARCHAR(20)  NOT NULL,
  WH_NM      NVARCHAR(50) NOT NULL,
  DEFAULT_YN CHAR(1)      NOT NULL CONSTRAINT DF_TBL_WH_MST_DEF  DEFAULT 'N',   -- 기본창고(회사마다 하나) — 출고 자동연동·창고 안 고른 전표가 쓴다
  SORT_ORD   INT          NOT NULL CONSTRAINT DF_TBL_WH_MST_SORT DEFAULT 0,
  USE_YN     CHAR(1)      NOT NULL CONSTRAINT DF_TBL_WH_MST_USE  DEFAULT 'Y',
  REG_DTTM   VARCHAR(19)  NULL, REG_USER NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL,
  UPD_DTTM   VARCHAR(19)  NULL, UPD_USER NVARCHAR(50) NULL, UPD_IP VARCHAR(50) NULL,
  CONSTRAINT PK_TBL_WH_MST PRIMARY KEY (COMP_CD, WH_CD)
);
GO
IF COL_LENGTH('dbo.TBL_STOCK_LEDGER','WH_CD') IS NULL
  ALTER TABLE dbo.TBL_STOCK_LEDGER ADD WH_CD VARCHAR(20) NOT NULL CONSTRAINT DF_TBL_STOCK_LEDGER_WH DEFAULT 'WH1' WITH VALUES;   -- 기존 행 = WH1
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_STOCK_LEDGER_WH' AND object_id = OBJECT_ID('dbo.TBL_STOCK_LEDGER'))
  CREATE INDEX IX_TBL_STOCK_LEDGER_WH ON dbo.TBL_STOCK_LEDGER (COMP_CD, WH_CD, PROD_SEQ, ACTION_YN);
GO
/* ── 씨앗 : 회사마다 창고 3개(이름은 화면에서 바꾼다). 있는 것은 안 건드린다 ── */
;WITH C AS ( SELECT DISTINCT COMP_CD FROM dbo.TBL_COMP_MST WHERE ISNULL(COMP_CD,'') <> ''
             UNION SELECT 'W1234567' ),
      S AS ( SELECT * FROM (VALUES ('WH1', N'제1창고', 'Y', 10), ('WH2', N'제2창고', 'N', 20), ('WH3', N'제3창고', 'N', 30)) v (WH_CD, WH_NM, DEFAULT_YN, SORT_ORD) )
INSERT INTO dbo.TBL_WH_MST (COMP_CD, WH_CD, WH_NM, DEFAULT_YN, SORT_ORD, USE_YN, REG_DTTM, REG_USER)
SELECT C.COMP_CD, S.WH_CD, S.WH_NM, S.DEFAULT_YN, S.SORT_ORD, 'Y', CONVERT(VARCHAR(19),GETDATE(),120), 'seed'
  FROM C CROSS JOIN S
 WHERE NOT EXISTS (SELECT 1 FROM dbo.TBL_WH_MST t WHERE t.COMP_CD = C.COMP_CD AND t.WH_CD = S.WH_CD);
GO
/* ── 확인 ── */
SELECT COMP_CD, WH_CD, WH_NM, DEFAULT_YN, SORT_ORD, USE_YN FROM dbo.TBL_WH_MST ORDER BY COMP_CD, SORT_ORD;
SELECT WH_CD, COUNT(*) AS rows_ FROM dbo.TBL_STOCK_LEDGER GROUP BY WH_CD;   -- 전부 WH1 이어야 정상
