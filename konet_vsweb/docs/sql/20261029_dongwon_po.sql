/* =====================================================================
   동원홈푸드 등록 (2026-10-29 사용자 요청 「대상 발주 등록 밑에 동원홈푸드 등록 메뉴 — 토더 등록 형태 · 매출장부 엑셀 · 매출·재고 직접 연계」)
   ⛔새 WAR 를 올리기 <전에> 운영DB 에서 한 번 실행. 재실행 안전.

   동원홈푸드가 내려 주는 「직송발주정보_주문내역」 엑셀(배송일자·상품코드·상품명·규격·출고단위·최종주문량·주문번호·순번·배송처코드·배송처·주소·연락처)을
   올려 TBL_SHIPOUT_MST 에 PROD_KIND='TD' · DC_CD='DONGWON' 으로 넣는다 — 토더·대상과 같은 종류라 매출·재고·마감·채권·일계장 조회를 하나도 안 고치고 선다.

   이 스크립트가 하는 것 :
     1) 매출 거래처 「동원홈푸드」(VENDOR_CD='DONGWON', DC_CD='DONGWON', 부가세 별도) — 회사마다 한 번.
        채권·채무·일계장·거래처 원장이 토더와 같은 규칙(거래처의 DC_CD = 출고 줄의 DC_CD)으로 동원홈푸드 매출을 이 거래처에 붙인다.
        이름·사업자번호·담당 등은 거래처관리(매입/매출 거래처)에서 채우면 된다. 코드·DC_CD 는 바꾸지 말 것.
     2) 칸은 새로 만들지 않는다 — 판매가 SALE_PRICE(20260922_toder_sales.sql) · 받는 곳 RCV_NM/RCV_ADDR/RCV_TEL/RCV_ITEM_CD(20261002_daesang_po.sql)를 그대로 쓴다.
        ⚠그 두 DDL 이 먼저 돌아 있어야 한다(운영 2026-10 기준 이미 적용).
   ===================================================================== */

INSERT INTO TBL_VENDOR_MST (COMP_CD, VENDOR_CD, VENDOR_NM, VENDOR_GB, DC_CD, VAT_GB, ACTION_YN)
SELECT c.COMP_CD, 'DONGWON', N'동원홈푸드', N'매출', 'DONGWON', N'별도', 'Y'
  FROM ( SELECT DISTINCT COMP_CD FROM TBL_COMP_MST WHERE ACTION_YN = 'Y' ) c
 WHERE NOT EXISTS ( SELECT 1 FROM TBL_VENDOR_MST v WHERE v.COMP_CD = c.COMP_CD AND v.VENDOR_CD = 'DONGWON' );
GO

-- 확인
SELECT COL_LENGTH('TBL_SHIPOUT_MST', 'SALE_PRICE') AS salePriceLen, COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_NM') AS rcvNmLen, COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_ITEM_CD') AS rcvItemCdLen;
SELECT COMP_CD, VENDOR_CD, VENDOR_NM, VENDOR_GB, DC_CD, VAT_GB, ACTION_YN FROM TBL_VENDOR_MST WHERE VENDOR_CD = 'DONGWON';
