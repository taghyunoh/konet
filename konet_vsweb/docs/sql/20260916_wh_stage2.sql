/* =====================================================================
   창고 2단계 — 출고장 → 창고 매핑 · 재고마감 창고별 스냅샷 (2026-09-16, 설계 = docs/설계_창고2단계_출고장매핑_2026-09-16.md)
     · TBL_DC_MST.WH_CD        : 그 출고장(센터)으로 나가는 물건이 어느 창고에서 빠지나. 비면 기본창고(1단계와 같음).
                                 발주현황표·정산서 출고 자동연동(insertShipoutLedger/insertSalesLedger)이 이 칸을 본다. 창고 관리 화면에서 고친다.
     · TBL_CLOSING_STOCK.WH_CD : 재고마감 스냅샷을 품목 × 창고로. 기존 행은 전부 WH1. 마감 화면·기초 이월은 창고 합으로 읽는다(selectStockClosing).
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF … IS NULL).
   ⚠소급 없음(추천안) — 매핑을 저장한 뒤 업로드·재동기화되는 날짜부터 창고별로 빠진다. [출고반영 재집계]를 누르면 과거까지 매핑대로 다시 갈린다.
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_DC_MST','WH_CD') IS NULL
  ALTER TABLE dbo.TBL_DC_MST ADD WH_CD VARCHAR(20) NULL;
IF COL_LENGTH('dbo.TBL_CLOSING_STOCK','WH_CD') IS NULL
  ALTER TABLE dbo.TBL_CLOSING_STOCK ADD WH_CD VARCHAR(20) NOT NULL CONSTRAINT DF_TBL_CLOSING_STOCK_WH DEFAULT 'WH1' WITH VALUES;
GO
SELECT COMP_CD, DC_CD, DC_NM, GRP_NM, WH_CD FROM dbo.TBL_DC_MST ORDER BY COMP_CD, SORT_ORD;   -- WH_CD 는 전부 NULL(= 기본창고)로 시작
SELECT WH_CD, COUNT(*) AS rows_ FROM dbo.TBL_CLOSING_STOCK GROUP BY WH_CD;
