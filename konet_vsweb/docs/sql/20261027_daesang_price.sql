/* =====================================================================
   대상 발주 — 수량별 단가 · 차수 (2026-10-27 사용자 요청 · 씨앗 값은 10-27 견적서 그림으로 보정 — 이미 돌렸으면 20261027_daesang_price_fix.sql) — ⛔새 화면을 쓰기 <전에> 운영DB 에서 한 번 실행. 재실행 안전.

   사용자 요청 :
     「품목마다 기본수량일 때 단가, 이하일 때 단가가 있어서 관리하게 · 받는 사람 하나로 합해서 3만원부터 택배무료, 3만원 미만이면 4,000원 ·
       Ctrl+C → Ctrl+V 할 때나 수동 입력 시 · 바로 수정 시도 적용 · 나중에 해당 자료를 보내 주어야 함 — 엑셀 일자에 10월 1차 찍어야 하니 관리하게」

   이 스크립트가 하는 것 :
     1) TBL_DS_PRICE — 대상 단가표. 품목코드마다 기본 수량 · 이상 단가 · 미만 단가.
          수량 ≥ 기본 수량 → 이상 단가 / 수량 < 기본 수량 → 미만 단가. 기본 수량이 0 이면 늘 이상 단가(단가 하나인 품목).
          화면(대상 발주 등록 ▸ [💲 대상 단가표])에서 고친다. 아래 씨앗 값은 「대상급식 마감.xlsx」 2026-09·10월 시트에서 실제로 매긴 단가와
          견적서(0310-1 급식제품.xls)로 맞춘 것이다.
     2) TBL_SHIPOUT_MST.DS_ROUND — 차수(「10월 1차」). 대상 줄만 쓴다(다른 줄은 NULL). 마감 엑셀의 「일자」 칸에 날짜와 함께 찍힌다.
     ⚠이 표·칸이 없으면 「대상 발주 등록」 화면의 조회·저장이 오류가 난다. 다른 화면은 읽지 않는다.
   ===================================================================== */

-- 1) 대상 단가표
IF OBJECT_ID('TBL_DS_PRICE', 'U') IS NULL
BEGIN
    CREATE TABLE TBL_DS_PRICE (
        COMP_CD      VARCHAR(20)    NOT NULL,
        PROD_CD      NVARCHAR(30)   NOT NULL,      -- 우리 품목코드(상품코드)
        BASE_QTY     INT            NOT NULL DEFAULT 0,   -- 기본 수량(이상이면 BASE_PRICE) — 0 = 단가 하나
        BASE_PRICE   DECIMAL(18,2)  NOT NULL DEFAULT 0,   -- 기본 수량 이상일 때 단가(개당, 부가세 별도)
        UNDER_PRICE  DECIMAL(18,2)  NULL,                 -- 기본 수량 미만일 때 단가 — 비면 BASE_PRICE
        REMARK       NVARCHAR(200)  NULL,
        SORT_ORD     INT            NOT NULL DEFAULT 0,
        USE_YN       CHAR(1)        NOT NULL DEFAULT 'Y',
        REG_DTTM     DATETIME       NULL DEFAULT GETDATE(),
        REG_USER     VARCHAR(50)    NULL,
        UPD_DTTM     DATETIME       NULL,
        UPD_USER     VARCHAR(50)    NULL,
        CONSTRAINT PK_DS_PRICE PRIMARY KEY (COMP_CD, PROD_CD)
    );
END
GO

-- 2) 차수 칸
IF COL_LENGTH('TBL_SHIPOUT_MST', 'DS_ROUND') IS NULL
    ALTER TABLE TBL_SHIPOUT_MST ADD DS_ROUND NVARCHAR(20) NULL;
GO

-- 3) 씨앗 값 (이미 있는 품목은 건드리지 않는다) — 회사 코드 W1234567
DECLARE @c VARCHAR(20) = 'W1234567';
DECLARE @s TABLE (PROD_CD NVARCHAR(30), BASE_QTY INT, BASE_PRICE DECIMAL(18,2), UNDER_PRICE DECIMAL(18,2), REMARK NVARCHAR(200), SORT_ORD INT);
INSERT INTO @s VALUES
 (N'1010014032', 1000, 62,  67,   N'급식 친환경 종이컵 10oz 에코라이프', 10),
 (N'4003071185', 1000, 62,  67,   N'급식 접은(무접착제) 핫도그 트레이',  15),
 (N'9904012192', 1500, 44,  46,   N'급식 시식용트레이 무지(소)',         20),
 (N'4003004135', 2000, 49,  51,   N'급식 시식용트레이 무지(대)',         30),
 (N'6010040023', 2000, 33,  47,   N'(급식) 유산지 스마일(L자)',          40),
 (N'1010010032', 1000, 44,  49,   N'급식 콜팝용 16oz 음료컵',            50),
 (N'1002020170', 1000, 30,  33,   N'급식 콜팝 용 용기',                  60),
 (N'2010016009', 7000, 5.3, 6.7,  N'급식 콜팝 스트로우 자바라',          70),
 (N'9904012907', 400,  108, 112.5, N'급식 트레이(플래터용)',             80);
INSERT INTO TBL_DS_PRICE (COMP_CD, PROD_CD, BASE_QTY, BASE_PRICE, UNDER_PRICE, REMARK, SORT_ORD, USE_YN, REG_USER)
SELECT @c, s.PROD_CD, s.BASE_QTY, s.BASE_PRICE, s.UNDER_PRICE, s.REMARK, s.SORT_ORD, 'Y', 'ddl20261027'
  FROM @s s
 WHERE NOT EXISTS (SELECT 1 FROM TBL_DS_PRICE p WHERE p.COMP_CD = @c AND p.PROD_CD = s.PROD_CD);
GO

-- 확인
SELECT * FROM TBL_DS_PRICE ORDER BY COMP_CD, SORT_ORD;
SELECT COL_LENGTH('TBL_SHIPOUT_MST', 'DS_ROUND') AS DS_ROUND_LEN;
