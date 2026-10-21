/* ============================================================================
   직원 휴가 관리 v3 — 전년 이월 자동 (2026-10-21 사용자 「그럼 2027년도는 자동 이월이죠」)
     · TBL_LEAVE_QUOTA.CARRY_DAYS 를 NULL 허용으로 : NULL = 자동(전년 잔여 = 전년 이월 + 부여 − 사용을 서버가 계산해 넘긴다),
       숫자 = 그 값으로 고정(화면 [⚙ 부여 일수] 에서 넣은 값). 전년 자료(부여 줄·휴가)가 하나도 없으면 자동 이월도 없음(0).
     · 2026년 줄은 양식(연차양식.xlsx) 값이 숫자로 들어가 있어 그대로 고정. 2027년부터는 줄을 안 만들거나 이월을 비우면 자동.
   실행 : 사용자가 운영 DB(KOLGSDB) 에서 직접. 두 번 실행해도 안전.
   ============================================================================ */
IF COLUMNPROPERTY(OBJECT_ID('dbo.TBL_LEAVE_QUOTA'), 'CARRY_DAYS', 'AllowsNull') = 0
    ALTER TABLE dbo.TBL_LEAVE_QUOTA ALTER COLUMN CARRY_DAYS DECIMAL(5,1) NULL;
GO

/* 확인 — AllowsNull 이 1 이면 됨 */
SELECT COLUMNPROPERTY(OBJECT_ID('dbo.TBL_LEAVE_QUOTA'), 'CARRY_DAYS', 'AllowsNull') AS CARRY_ALLOWS_NULL;
