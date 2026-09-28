/* =====================================================================
   견적서 품목 줄에 「제조사」 (2026-09-28 — 고객 요청 「견적서 품목에서 제조사 추가」)
     · TBL_QUOTE_DTL.MAKER_NM : 그 품목의 제조사. 🔍 상품 찾기로 고르면 상품마스터(TBL_PROD_MST.MAKER_NM)에서 자동으로 들어오고,
       직접 적을 수도 있다. 비면 종전과 똑같이 동작한다(인쇄·엑셀에 칸 자체가 안 생긴다).
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF … IS NULL).
   ⚠WAR 배포 <전에> 실행할 것 — 새 매퍼(selectQuoteDtl·insertQuoteDtl)가 이 칸을 읽고 쓴다.
     칸이 없는 채 새 WAR 를 올리면 견적서 작성·수정·저장·목록 상세가 모두 조회 오류가 난다.
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_DTL','MAKER_NM') IS NULL
  ALTER TABLE dbo.TBL_QUOTE_DTL ADD MAKER_NM NVARCHAR(100) NULL;
GO
/* ── 확인 ── */
SELECT COL_LENGTH('dbo.TBL_QUOTE_DTL','MAKER_NM') AS maker_nm_len;
