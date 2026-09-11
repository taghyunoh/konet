/* =====================================================================================
   TBL_COMP_MST 에 업태·종목·계좌 추가 (MSSQL)  — 2026-09-09
   · 배경 : 판매등록 [🖨 거래명세표] 의 <공급자(우리 회사)> 칸에 업태·종목·계좌가 들어가는데
     회사 마스터에 그 칸이 없어 브라우저(localStorage)에만 적어 두고 있었다.
     ⇒ PC·브라우저가 바뀌면 그 세 칸이 비어 나온다. 사용자 요청("업태 종목 계좌 서버에 넣어주세요")으로 컬럼 신설.
   · 쓰는 곳 : selCompCdList(회사/사용자 관리 화면) · selectCompInfo(발주서 인쇄) ·
     updateCompBizInfo(거래명세표 조건 창의 [💾 회사 정보로 저장] — 이 세 칸만 고친다)
   · ★TBL_COMP_MST 는 이력형(JOB_SEQ + ACTION_YN)이다. 회사 수정은 <옛 행 ACTION_YN='N' + 새 행 INSERT> 라
     insertCompCdMst 에 이 세 칸이 빠지면 회사를 한 번 수정할 때마다 값이 사라진다 — 함께 넣어 두었다.
   · 각 구문 IF 가드로 재실행 안전.
   ===================================================================================== */
USE [KOLGSDB]
GO

IF COL_LENGTH('dbo.TBL_COMP_MST','BIZ_COND') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD BIZ_COND  NVARCHAR(100) NULL;   -- 업태 (예: 제조)
GO
IF COL_LENGTH('dbo.TBL_COMP_MST','BIZ_ITEM') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD BIZ_ITEM  NVARCHAR(200) NULL;   -- 종목 (예: 사출성형용기)
GO
IF COL_LENGTH('dbo.TBL_COMP_MST','BANK_ACCT') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD BANK_ACCT NVARCHAR(200) NULL;   -- 계좌 (은행 + 예금주 + 계좌번호 한 줄)
GO

/* ★값은 넣지 않는다 — 추측으로 채우면 그대로 거래명세서에 찍힌다.
   화면에서 한 번 넣으면 된다 :
     · 판매등록 ▸ [🖨 거래명세표] ▸ 공급자 칸에 적고 [💾 회사 정보로 저장]  (그 브라우저에 적어 둔 값이 이미 채워져 있다)
     · 또는 기준정보관리 ▸ 회사/사용자 관리 ▸ 회사 수정 (관리자 회사만)
   비어 있으면 명세서의 종목·계좌 칸이 빈 칸으로 나갈 뿐, 다른 화면에는 아무 영향이 없다. */

/* 확인
SELECT COMP_CD, JOB_SEQ, ACTION_YN, COMP_NM, BIZ_COND, BIZ_ITEM, BANK_ACCT
  FROM dbo.TBL_COMP_MST ORDER BY COMP_CD, JOB_SEQ;
*/
