/* =====================================================================
   견적서 관리 — 단가 묶음 둘 (2026-09-17, 표본 260730-1(900cc,500cc,부직포 가방).xls)
     · 견적서에 「센터배송 단가·금액」과 「택배출고(D2~3) 단가·금액」처럼 단가 묶음이 둘인 양식이 있다.
     · TBL_QUOTE_MST.PRICE1_NM / PRICE2_NM : 묶음 이름(센터배송 · 택배출고(D2~3)). 묶음이 하나면 PRICE2_NM 은 NULL
     · TBL_QUOTE_DTL.UNIT_PRICE2 / AMT2    : 둘째 묶음 단가·금액 (첫째 묶음은 종전 UNIT_PRICE / AMT)
     · SUPPLY_AMT(합계)는 첫째 묶음 기준(종전과 같다)
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전. 20260917_quote_mst_dtl.sql 다음에.
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_MST','PRICE1_NM') IS NULL ALTER TABLE dbo.TBL_QUOTE_MST ADD PRICE1_NM NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.TBL_QUOTE_MST','PRICE2_NM') IS NULL ALTER TABLE dbo.TBL_QUOTE_MST ADD PRICE2_NM NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.TBL_QUOTE_DTL','UNIT_PRICE2') IS NULL ALTER TABLE dbo.TBL_QUOTE_DTL ADD UNIT_PRICE2 DECIMAL(15,2) NULL;
IF COL_LENGTH('dbo.TBL_QUOTE_DTL','AMT2') IS NULL ALTER TABLE dbo.TBL_QUOTE_DTL ADD AMT2 DECIMAL(15,0) NULL;
GO
SELECT COL_LENGTH('dbo.TBL_QUOTE_MST','PRICE2_NM') AS mst_p2, COL_LENGTH('dbo.TBL_QUOTE_DTL','AMT2') AS dtl_amt2;
