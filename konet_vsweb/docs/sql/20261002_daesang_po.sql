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
-- 1-2) 택배비(운임) 칸 — 같은 날 추가(사용자 「기본 택배비는 4500으로 입력 가능하게」 · 「DB 저장은 없나요」). 줄마다 한 값, 엑셀의 운임 칸으로 나간다. 매출·재고와 무관.
--      ⚠이 파일을 이미 한 번 실행했어도 다시 실행하면 된다 — 없는 칸만 생긴다.
--      ★칸을 «처음 만들 때 한 번만» 이미 저장돼 있던 대상 발주 줄에 기본 택배비 4,500 을 넣는다(칸이 생기기 전에 저장한 줄이라 값이 없다).
--        다시 실행할 때는 칸이 이미 있으므로 이 UPDATE 는 돌지 않는다 — 화면에서 비우거나 고친 값을 덮어쓰지 않는다.
IF COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_FEE') IS NULL
BEGIN
    ALTER TABLE TBL_SHIPOUT_MST ADD RCV_FEE INT NULL;
    EXEC('UPDATE TBL_SHIPOUT_MST SET RCV_FEE = 4500 WHERE PROD_KIND = ''TD'' AND DC_CD = ''DAESANG'' AND ACTION_YN = ''Y'' AND RCV_FEE IS NULL');
END
GO

-- 2) 매출 거래처 「대상주식회사」 — 물류센터코드가 비어 있을 때만 넣는다
UPDATE TBL_VENDOR_MST
   SET DC_CD = 'DAESANG'
 WHERE VENDOR_CD = '1' AND VENDOR_NM = N'대상주식회사' AND VENDOR_GB = N'매출' AND ACTION_YN = 'Y'
   AND ISNULL(DC_CD,'') = '';
GO

-- 확인
SELECT COUNT(*) AS dsRows, SUM(CASE WHEN RCV_FEE IS NULL THEN 1 ELSE 0 END) AS feeNull FROM TBL_SHIPOUT_MST WHERE PROD_KIND = 'TD' AND DC_CD = 'DAESANG' AND ACTION_YN = 'Y';
SELECT COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_NM') AS rcvNm, COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_ADDR') AS rcvAddr,
       COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_TEL') AS rcvTel, COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_TEL2') AS rcvTel2,
       COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_ITEM_CD') AS rcvItemCd, COL_LENGTH('TBL_SHIPOUT_MST', 'RCV_FEE') AS rcvFee;
SELECT COMP_CD, VENDOR_CD, VENDOR_NM, VENDOR_GB, DC_CD, VAT_GB, ACTION_YN FROM TBL_VENDOR_MST WHERE DC_CD = 'DAESANG';
