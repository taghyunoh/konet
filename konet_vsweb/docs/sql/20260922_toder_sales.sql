/* =====================================================================
   토더 발주 = 매출 (2026-09-22 사용자 확정) — ⛔새 WAR 를 올리기 <전에> 운영DB 에서 한 번 실행. 재실행 안전.

   사용자 확정 6가지 :
     ① 토더 엑셀 「매입가」 = 우리 판매가        ② 그 값은 부가세 포함
     ③ 받을 상대 = 토더(플랫폼) 하나             ④ 사용자가 골라 저장하면 곧 출고·매출
     ⑤ 반품은 당분간 저장된 줄을 「수정」으로     ⑥ 날짜 = 발주일자 = 출고일자

   이 스크립트가 하는 것 :
     1) TBL_SHIPOUT_MST.SALE_PRICE — 토더 줄의 판매가(부가세 포함). 삼성 발주현황표 줄은 비워 둔다(NULL).
        ⚠새 매퍼(마감·매출그래프·토더 저장)가 이 칸을 읽는다 — 칸 없이 새 WAR 를 올리면 그 화면들이 조회 오류.
     2) 매출 거래처 「토더」(VENDOR_CD='TODER', DC_CD='TODER') — 채권·채무·일계장·거래처 원장이
        정산서와 같은 규칙(거래처의 DC_CD = 출고 줄의 DC_CD)으로 토더 매출을 이 거래처에 붙인다.
        토더 출고 줄의 DC_CD 는 처음부터 'TODER' 다(토더 발주 등록 저장).
        이름·사업자번호·담당 등은 거래처관리(매입/매출 거래처)에서 채우면 된다. 코드·DC_CD 는 바꾸지 말 것.
   ===================================================================== */

-- 1) 판매가 칸
IF COL_LENGTH('TBL_SHIPOUT_MST', 'SALE_PRICE') IS NULL
    ALTER TABLE TBL_SHIPOUT_MST ADD SALE_PRICE DECIMAL(18,2) NULL;
GO

-- 2) 매출 거래처 「토더」 — 회사마다 한 번
INSERT INTO TBL_VENDOR_MST (COMP_CD, VENDOR_CD, VENDOR_NM, VENDOR_GB, DC_CD, VAT_GB, ACTION_YN)
SELECT c.COMP_CD, 'TODER', N'토더', N'매출', 'TODER', N'포함', 'Y'
  FROM ( SELECT DISTINCT COMP_CD FROM TBL_COMP_MST WHERE ACTION_YN = 'Y' ) c
 WHERE NOT EXISTS ( SELECT 1 FROM TBL_VENDOR_MST v WHERE v.COMP_CD = c.COMP_CD AND v.VENDOR_CD = 'TODER' );
GO

-- 확인
SELECT COL_LENGTH('TBL_SHIPOUT_MST', 'SALE_PRICE') AS salePriceLen;
SELECT COMP_CD, VENDOR_CD, VENDOR_NM, VENDOR_GB, DC_CD, VAT_GB, ACTION_YN FROM TBL_VENDOR_MST WHERE VENDOR_CD = 'TODER';
