/* =====================================================================
   견적서 — 원가·마진 계산 근거자료 (2026-09-17 「원가마진계산을 견적서 작성에서 · 견적서 하나당 기본으로 근거자료로 저장」)
     · TBL_QUOTE_MST.CALC_JSON : 작성 화면(quoteEdit)이 저장하는 JSON —
       { v, use2(양식2 여부), set(배송 갈래·센터·택배비), calcs(품목 줄 차례대로 MOQ·구매단가·입수·운송·보관·소분·박스·목표마진·부대비),
         genRows(부대비 서브 줄로 만들어 넣은 품목 줄의 ROW_NO — 불러올 때 걷어내고 계산에서 다시 만든다) }
     · 센터별 물류비율·보관 기본값은 회사 설정(TBL_COMP_SET.SET_JSON 의 cost 키)이라 이 표에는 없다.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전.
   ⚠WAR 배포 <전에> 실행할 것 — insertQuoteMst·selectQuoteMst 가 이 칸을 읽고 쓴다(없으면 견적서 저장·수정·인쇄가 실패한다).
   순서 : 20260917_quote_mst_dtl.sql → 20260917_quote_price2.sql → 이 파일.
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_MST','CALC_JSON') IS NULL ALTER TABLE dbo.TBL_QUOTE_MST ADD CALC_JSON NVARCHAR(MAX) NULL;
GO
/* ── 확인 ── */
SELECT COL_LENGTH('dbo.TBL_QUOTE_MST','CALC_JSON') AS calc_json_len;
