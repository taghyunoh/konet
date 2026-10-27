/* =====================================================================
   대상 단가표 보정 (2026-10-27 — 20261027_daesang_price.sql 을 돌린 뒤 한 번 실행. 재실행 안전)

   사용자 「설정 확인해줘 · 금액 다시 확인해줘」 — 견적서(0310-1 급식제품, 대상급식 9품목 그림)와 다시 대조한 결과 씨앗 값 셋이 어긋났다 :
     ① 플래터 트레이(9904012907) = 「단가 하나 108」이 아니라 400개 이상 108 · 미만 112.5 (견적서 「최소 발주량 1 → 112.50」)
     ② 핫도그 트레이(4003071185)가 빠졌다 — 1,000개 이상 62 · 미만 67
     ③ 시식용트레이(대) — 견적서의 품목코드는 4003004135 인데 씨앗은 9904012191(마감 엑셀의 「급식 시식용트레이 무지(대) 2,000개」 코드)로 넣었다 → 견적서 코드로 바꾼다.
        표는 견적서대로 9품목(사용자 「표 9개임 사용 중지 제하고」). 다른 코드로 발주가 오면 화면([💲 대상 단가표])에서 더하면 된다.
   그 밖(종이컵·트레이 소·유산지·음료컵·콜팝 용기·자바라)은 견적서 그대로였다. 종이빨대는 「사용 중지」라 넣지 않는다.
   ===================================================================== */
DECLARE @c VARCHAR(20) = 'W1234567';

-- ① 플래터 트레이 : 400개 이상 108 · 미만 112.5
UPDATE TBL_DS_PRICE SET BASE_QTY = 400, BASE_PRICE = 108, UNDER_PRICE = 112.5,
       REMARK = N'급식 트레이(플래터용)', UPD_DTTM = GETDATE(), UPD_USER = 'fix20261027'
 WHERE COMP_CD = @c AND PROD_CD = N'9904012907';

-- ② 핫도그 트레이 : 1,000개 이상 62 · 미만 67
IF NOT EXISTS (SELECT 1 FROM TBL_DS_PRICE WHERE COMP_CD = @c AND PROD_CD = N'4003071185')
    INSERT INTO TBL_DS_PRICE (COMP_CD, PROD_CD, BASE_QTY, BASE_PRICE, UNDER_PRICE, REMARK, SORT_ORD, USE_YN, REG_DTTM, REG_USER)
    VALUES (@c, N'4003071185', 1000, 62, 67, N'급식 접은(무접착제) 핫도그 트레이', 15, 'Y', GETDATE(), 'fix20261027');

-- ③ 시식용트레이(대) : 코드를 견적서의 4003004135 로 (씨앗이 마감 엑셀 코드 9904012191 로 들어갔다) — 단가 2,000 이상 49 · 미만 51 그대로. 표는 견적서대로 9품목(사용자 「표 9개임 사용 중지 제하고」)
IF EXISTS (SELECT 1 FROM TBL_DS_PRICE WHERE COMP_CD = @c AND PROD_CD = N'9904012191')
   AND NOT EXISTS (SELECT 1 FROM TBL_DS_PRICE WHERE COMP_CD = @c AND PROD_CD = N'4003004135')
    UPDATE TBL_DS_PRICE SET PROD_CD = N'4003004135', REMARK = N'급식 시식용트레이 무지(대)', UPD_DTTM = GETDATE(), UPD_USER = 'fix20261027'
     WHERE COMP_CD = @c AND PROD_CD = N'9904012191';
GO

-- 확인 : 견적서 9품목 순서 (9줄이어야 한다)
SELECT PROD_CD, BASE_QTY AS 기본수량, BASE_PRICE AS 이상단가, UNDER_PRICE AS 미만단가, REMARK FROM TBL_DS_PRICE WHERE COMP_CD = 'W1234567' ORDER BY SORT_ORD;
