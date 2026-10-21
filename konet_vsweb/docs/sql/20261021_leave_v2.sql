/* ============================================================================
   직원 휴가 관리 v2 — 입사일·전년 이월 (2026-10-21)
   사용자 수기 양식 「연차양식.xlsx」(2026-10-21 카카오톡) 를 보고 보탠 것 :
     · TBL_USER_MST.JOIN_DT      : 입사일(yyyymmdd). 근속 연차·권장 연차 일수 계산, 「연차 양식」 엑셀의 입사일 칸
     · TBL_LEAVE_QUOTA.CARRY_DAYS: 전년에서 넘어온 연차(양식의 「25년 남은 일수」). 잔여 = 이월 + 부여 − 사용
   화면 = 직원관리 ▸ 휴가 관리 [⚙ 부여 일수] 에서 입사일·이월·부여를 고친다. 엑셀 [📥 연차 양식] 이 양식 모양으로 나간다.
   실행 : 사용자가 운영 DB(KOLGSDB) 에서 직접. 두 번 실행해도 안전. ALTER 뒤에 GO 가 있어야 다음 문장이 새 열을 본다(SSMS 기준).
   ============================================================================ */

IF COL_LENGTH('dbo.TBL_LEAVE_QUOTA', 'CARRY_DAYS') IS NULL
    ALTER TABLE dbo.TBL_LEAVE_QUOTA ADD CARRY_DAYS DECIMAL(5,1) NOT NULL CONSTRAINT DF_LEAVE_QUOTA_CARRY DEFAULT 0;   -- 전년 이월 연차
GO
IF COL_LENGTH('dbo.TBL_USER_MST', 'JOIN_DT') IS NULL
    ALTER TABLE dbo.TBL_USER_MST ADD JOIN_DT CHAR(8) NULL;   -- 입사일 yyyymmdd (휴가 관리에서 씀)
GO

/* ── 양식에 적힌 값 그대로 (2026년) ──
   입사일 : 설재우 23.11.01 · 이지훈 23.10.23 · 전원배 25.11.17 · 강인성 25.12.01 · 이영섭 25.12.01
   2026년 부여 / 전년 이월 : 설재우 16/7 · 이지훈 16/7 · 전원배 13/0 · 강인성 12/0 · 이영섭 12/0
   (김민지·마스터는 양식에 없어 그대로 둔다 — 화면 [⚙ 부여 일수] 에서 넣으면 된다) */
UPDATE dbo.TBL_USER_MST SET JOIN_DT = '20231101' WHERE COMP_CD = 'W1234567' AND LTRIM(RTRIM(USER_ID)) = 'K002';   -- 설재우
UPDATE dbo.TBL_USER_MST SET JOIN_DT = '20231023' WHERE COMP_CD = 'W1234567' AND LTRIM(RTRIM(USER_ID)) = 'K005';   -- 이지훈
UPDATE dbo.TBL_USER_MST SET JOIN_DT = '20251117' WHERE COMP_CD = 'W1234567' AND LTRIM(RTRIM(USER_ID)) = 'K003';   -- 전원배
UPDATE dbo.TBL_USER_MST SET JOIN_DT = '20251201' WHERE COMP_CD = 'W1234567' AND LTRIM(RTRIM(USER_ID)) = 'K004';   -- 강인성
UPDATE dbo.TBL_USER_MST SET JOIN_DT = '20251201' WHERE COMP_CD = 'W1234567' AND LTRIM(RTRIM(USER_ID)) = 'K006';   -- 이영섭

DECLARE @q TABLE (USER_ID VARCHAR(20), ANNUAL_DAYS DECIMAL(5,1), CARRY_DAYS DECIMAL(5,1));
INSERT INTO @q VALUES ('K002', 16, 7), ('K005', 16, 7), ('K003', 13, 0), ('K004', 12, 0), ('K006', 12, 0);

UPDATE Q
   SET ANNUAL_DAYS = T.ANNUAL_DAYS, CARRY_DAYS = T.CARRY_DAYS,
       UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin'
  FROM dbo.TBL_LEAVE_QUOTA Q JOIN @q T ON Q.USER_ID = T.USER_ID
 WHERE Q.COMP_CD = 'W1234567' AND Q.LEAVE_YEAR = '2026';

INSERT INTO dbo.TBL_LEAVE_QUOTA (COMP_CD, USER_ID, LEAVE_YEAR, ANNUAL_DAYS, MONTHLY_DAYS, CARRY_DAYS, REMARK, REG_DTTM, REG_USER)
SELECT 'W1234567', T.USER_ID, '2026', T.ANNUAL_DAYS, 0, T.CARRY_DAYS, N'연차양식.xlsx (2026-10-21)', CONVERT(VARCHAR(19), GETDATE(), 120), 'admin'
  FROM @q T
 WHERE NOT EXISTS (SELECT 1 FROM dbo.TBL_LEAVE_QUOTA Q WHERE Q.COMP_CD = 'W1234567' AND Q.USER_ID = T.USER_ID AND Q.LEAVE_YEAR = '2026');

/* 확인 */
SELECT LTRIM(RTRIM(U.USER_ID)) AS USER_ID, U.USER_NM, U.JOIN_DT, Q.LEAVE_YEAR, Q.ANNUAL_DAYS, Q.CARRY_DAYS, Q.MONTHLY_DAYS
  FROM dbo.TBL_USER_MST U LEFT JOIN dbo.TBL_LEAVE_QUOTA Q ON Q.COMP_CD = U.COMP_CD AND Q.USER_ID = LTRIM(RTRIM(U.USER_ID)) AND Q.LEAVE_YEAR = '2026'
 WHERE U.COMP_CD = 'W1234567' AND U.ACTION_YN = 'Y'
 ORDER BY U.MAIN_GU, U.USER_NM;
