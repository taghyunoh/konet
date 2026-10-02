/* =====================================================================
   판매 등록 「출고차감」 — TBL_SALES_TRX_DTL.STOCK_CUT_QTY (2026-10-02 — 사용자
   「판매등록에서 정상적인 금액을 위해 수량은 입력하지만 재고수량은 출고차감이라고 해서 재고에서는 덜 나가는 것으로 처리 ·
     (정상적 출고수량 − 출고차감) · 외부 나가는 것은 모두 정상 출고수량으로 · 내부에서 재고처리 하기 위해 · 매출금액은 유지」)

     · STOCK_CUT_QTY : 그 줄에서 «재고로는 안 나가는» 수량(합계수량과 같은 단위). NULL·0 = 종전과 같음.
     · 재고(수불원장 TBL_STOCK_LEDGER)에 나가는 수량 = 합계수량(QTY) − STOCK_CUT_QTY. 0 이 되면 원장 줄을 만들지 않는다.
       반품 줄이면 재고로 «돌아오는» 수량이 같은 식으로 준다.
     · 수량(QTY)·단가·금액·부가세·판매금액은 그대로 — 매출·거래처 원장·거래명세서(인쇄·카톡·메일)는 전부 정상 수량·정상 금액.
     · 회사 설정 「재고 부족 제한」도 (합계수량 − 출고차감)으로 본다.
     · 재고 화면(품목별 재고현황·수불·재고마감·재고 일괄조정·적정재고)은 전부 수불원장을 읽으므로 따로 고칠 것이 없다.

   실행 : 사용자가 운영 DB(KOLGSDB)에서 <전체> 실행. 두 번 실행해도 안전.
   ⚠WAR 배포(톰캣 재시작) <전에> 실행할 것 — 이 칸이 없으면 판매 등록 저장·조회가 실패한다(전표 줄 INSERT·SELECT 가 이 칸을 쓴다).
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_SALES_TRX_DTL','STOCK_CUT_QTY') IS NULL
  ALTER TABLE dbo.TBL_SALES_TRX_DTL ADD STOCK_CUT_QTY DECIMAL(19,2) NULL;
GO
/* ── 확인 : 숫자가 나오면 칸이 있는 것 ── */
SELECT COL_LENGTH('dbo.TBL_SALES_TRX_DTL','STOCK_CUT_QTY') AS stockCutQty,
       (SELECT COUNT(*) FROM dbo.TBL_SALES_TRX_DTL WHERE ISNULL(STOCK_CUT_QTY,0) <> 0) AS usedRows;
