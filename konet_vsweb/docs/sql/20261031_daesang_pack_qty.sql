/* 대상 9품목 입수(PACK_QTY) 맞추기 — 2026-10-31 사용자 결정 「입수수량을 변경하는 것으로」
   · 뜻 : 매입등록 합계수량 = BOX × 입수 + EA 이므로 입수가 1 이면 상자 수가 그대로 「개수」로 들어가 출고(개수)와 어긋난다.
   · 단가는 손대지 않는다(사용자 「구매단가든 출고단가든 사용자가 치니까 그 금액으로」) — 전표에 친 값이 정본.
   · TBL_PROD_MST 는 이력형 — 살아 있는 줄(ACTION_YN='Y')을 그 자리에서 고친다(상품코드등록 수정 창과 같은 방식).
   · 재실행 안전(같은 값이면 0건).
   ★이 파일을 돌린 뒤 할 일(사용자, 화면에서) :
     ① 매입등록에서 상자 단가로 들어간 전표 6장(아래 목록)을 열어 BOX 칸 상자 수 · 단가 칸 개당값으로 다시 저장 → 원장 입고가 개수로, 매입가 이력이 개당으로
     ② 대상 발주 등록 ▸ [⚠ 중복 점검] 에서 대상 판매전표 23장 삭제 · 10-23 겹친 묶음 정리 → [🔄 출고반영 재집계]
   ⚠입수를 바꾼 뒤 상품코드등록 수정 창을 열면 BOX·EA 재고 칸이 새 입수로 다시 나뉜다 — 그 창에서 저장하기 전에 값을 확인할 것. */
SET NOCOUNT ON;

/* 1) 이름·규격에 입수가 적힌 것 — 확실 */
UPDATE p SET p.PACK_QTY = 1000 FROM TBL_PROD_MST p WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y' AND p.PROD_CD = '1010014032' AND ISNULL(p.PACK_QTY,0) <> 1000;   -- 급식 친환경 종이컵 10oz 에코라이프 1000입
-- (2026-10-31 사용자 「제공한 내용에서 지움」) 4003071185 핫도그 트레이 — 대상 출고·판매전표 0건이라 뺐다. 재고를 개수로 보려면 입수 1200 + 05-12 영신기업 전표 재저장(단가 32)으로.
-- UPDATE p SET p.PACK_QTY = 1200 FROM TBL_PROD_MST p WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y' AND p.PROD_CD = '4003071185' AND ISNULL(p.PACK_QTY,0) <> 1200;
UPDATE p SET p.PACK_QTY = 2000 FROM TBL_PROD_MST p WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y' AND p.PROD_CD = '9904012191' AND ISNULL(p.PACK_QTY,0) <> 2000;   -- 급식 시식용트레이 무지(대) 2,000개
UPDATE p SET p.PACK_QTY = 1500 FROM TBL_PROD_MST p WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y' AND p.PROD_CD = '9904012192' AND ISNULL(p.PACK_QTY,0) <> 1500;   -- 급식 시식용트레이 무지(소) 1,500개

/* 2) 입수를 자료로 확인한 것 — 유산지 : 매입 4줄 중 3줄은 낱장 50,000 × 22~24원, 1줄(2026-09-03 0002)은 9 × 120,000원.
      120,000 ÷ 24 = 5,000장 → 한 상자 5,000장으로 본다(이름의 「2000장 이상」은 최소 주문량). 틀리면 아래 숫자만 고쳐 다시 돌릴 것 */
UPDATE p SET p.PACK_QTY = 5000 FROM TBL_PROD_MST p WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y' AND p.PROD_CD = '6010040023' AND ISNULL(p.PACK_QTY,0) <> 5000;   -- (급식) 유산지 스마일 (L자)

/* 3) ⚠입수를 모르는 것 — 사용자가 값을 넣고 주석(--)을 풀어 돌릴 것
      · 1010010032 급식 콜팝용 16oz 음료컵(기성)인쇄 : 매입가 35,000(상자값) · 단가표 기본수량 1,000 — 한 상자 1,000개로 짐작되나 확인 필요
      · 9904012907 급식 트레이(플래터용),크라프트 : 매입가·판매가 0 · 매입 기록 없음 — 입수 모름 */
-- UPDATE p SET p.PACK_QTY = 1000 FROM TBL_PROD_MST p WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y' AND p.PROD_CD = '1010010032' AND ISNULL(p.PACK_QTY,0) <> 1000;
-- UPDATE p SET p.PACK_QTY = 400  FROM TBL_PROD_MST p WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y' AND p.PROD_CD = '9904012907' AND ISNULL(p.PACK_QTY,0) <> 400;

/* 4) 이미 맞는 것(손대지 않음) : 1002020170 콜팝 용기 1000 · 2010016009 자바라 500 */

/* 확인 */
SELECT p.PROD_CD, p.PROD_NM, p.PACK_QTY, p.IN_PRICE, p.SALE_PRICE
  FROM TBL_PROD_MST p
 WHERE p.COMP_CD = 'W1234567' AND p.ACTION_YN = 'Y'
   AND p.PROD_CD IN ('1002020170','1010010032','1010014032','2010016009','4003071185','6010040023','9904012191','9904012192','9904012907')
 ORDER BY p.PROD_CD;

/* ★다시 저장할 매입전표(상자 단가로 들어간 줄) — 매입등록에서 그 전표를 열어 BOX 칸은 그대로, 단가 칸만 개당값으로(금액 불변)
   2026-04-06 0001  종이컵 95상자 · 0.5상자 → 단가 37
   2026-05-12 0002  핫도그 42상자            → 단가 32 (38,400 ÷ 1,200)
   2026-05-13 0001  종이컵 64상자            → 단가 37
   2026-06-16 0005  종이컵 96상자            → 단가 37
   2026-09-03 0002  유산지 9상자             → 단가 24 (120,000 ÷ 5,000)
   2026-09-09 0001  종이컵 96상자            → 단가 37
   (유산지 2026-03-09·05-13·07-22 세 줄은 EA 칸에 50,000장 · 22~24원이라 그대로) */
