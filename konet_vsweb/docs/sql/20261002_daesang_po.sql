/* =====================================================================
   대상 발주 등록 (2026-10-02 사용자 요청) — ⛔새 화면을 쓰기 <전에> 운영DB 에서 한 번 실행. 재실행 안전.

   사용자 확정 :
     ① 대상(대상주식회사)이 이메일로 보내는 배송요청 표(받는 사람·주소·전화·수량·제품코드·제품명)를 올려 출고·매출로 저장
     ② 금액이 없다 → 상품코드의 판매가를 자동으로 넣고 화면에서 고친다
     ③ 발주일자(납품일자)가 없다 → 화면에서 넣는다
     ④ 매출 거래처 = 대상주식회사 [VENDOR_CD = '1']
     ⑤ 받는 사람(학교·지점)은 사업장으로 등록하지 않고 줄마다 배송 정보로만 남긴다
     ⑥ 매출은 토더처럼 — 저장하면 곧 출고·매출(수량 × 판매가), 재고도 빠진다

   이 스크립트가 하는 것 :
     1) TBL_SHIPOUT_MST 에 배송 정보 칸 5개 — 받는 사람·주소·전화 1·전화 2·대상 제품코드. 대상 줄만 쓴다(다른 줄은 NULL).
        ⚠이 칸이 없으면 「대상 발주 등록」 화면의 조회·저장이 오류가 난다. 다른 화면은 이 칸을 읽지 않는다.
     2) 매출 거래처 「대상주식회사」(VENDOR_CD='1')의 물류센터코드(DC_CD) = 'DAESANG'
        — 채권·채무·일계장·거래처 원장이 토더와 같은 규칙(거래처의 DC_CD = 출고 줄의 DC_CD)으로 대상 매출을 이 거래처에 붙인다.
        대상 출고 줄의 DC_CD 는 처음부터 'DAESANG' 이다(대상 발주 등록 저장). 이미 다른 값이 들어 있으면 건드리지 않는다.
   ===================================================================== */

-- 1) 배송 정보 칸
IF COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_NM') IS NULL
    ALTER TABLE TBL_SHIPOUT_MST ADD RCV_NM NVARCHAR(100) NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_ADDR') IS NULL
    ALTER TABLE TBL_SHIPOUT_MST ADD RCV_ADDR NVARCHAR(300) NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_TEL') IS NULL
    ALTER TABLE TBL_SHIPOUT_MST ADD RCV_TEL NVARCHAR(40) NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_TEL2') IS NULL
    ALTER TABLE TBL_SHIPOUT_MST ADD RCV_TEL2 NVARCHAR(40) NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_ITEM_CD') IS NULL
    ALTER TABLE TBL_SHIPOUT_MST ADD RCV_ITEM_CD NVARCHAR(30) NULL;
GO

-- 2) 매출 거래처 「대상주식회사」 — 물류센터코드가 비어 있을 때만 넣는다
UPDATE TBL_VENDOR_MST
   SET DC_CD = 'DAESANG'
 WHERE VENDOR_CD = '1' AND VENDOR_NM = N'대상주식회사' AND VENDOR_GB = N'매출' AND ACTION_YN = 'Y'
   AND ISNULL(DC_CD,'') = '';
GO

-- 확인
SELECT COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_NM') AS rcvNm, COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_ADDR') AS rcvAddr,
       COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_TEL') AS rcvTel, COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_TEL2') AS rcvTel2,
       COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_ITEM_CD') AS rcvItemCd;
SELECT COMP_CD, VENDOR_CD, VENDOR_NM, VENDOR_GB, DC_CD, VAT_GB, ACTION_YN FROM TBL_VENDOR_MST WHERE DC_CD = 'DAESANG';
