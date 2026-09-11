/* =====================================================================================
   TBL_COMP_MST 에 거래명세서 <공지사항> 추가 (MSSQL)  — 2026-09-09
   · 배경 : 업태·종목·계좌는 2026-09-09 에 서버로 옮겼는데(comp_mst_bizinfo_alter.sql)
     **공지사항만 브라우저(localStorage)에 남아 있었다.** PC 를 바꾸면 그 칸이 빈 채로 찍힌다.
     사용자 요청("공지내용 서버적용")으로 같은 자리(회사 정보)에 넣는다.
   · 찍히는 곳 : 거래명세서 맨 아래 「공지사항」 칸 (asset/js/stmt-sheet.js) —
     화면 인쇄와 공개 링크(/pub/stmt.do)에 똑같이 나간다.
   · 고치는 곳 : 판매등록 [🖨 거래명세표] ▸ 공급자 칸 ▸ [💾 저장]  또는
     기준정보관리 ▸ 회사/사용자 관리 ▸ 회사 수정(관리자 회사만)
   · ★TBL_COMP_MST 는 이력형(JOB_SEQ + ACTION_YN)이다 — insertCompCdMst 에도 이 칸이 들어가야
     회사를 수정할 때 값이 사라지지 않는다(업태·종목·계좌와 같은 규칙).
   · IF 가드로 재실행 안전. 값은 넣지 않는다 — 화면에서 적는다(적어 둔 브라우저 값이 이미 채워져 있다).
   ===================================================================================== */
USE [KOLGSDB]
GO

IF COL_LENGTH('dbo.TBL_COMP_MST','STMT_NOTICE') IS NULL
    ALTER TABLE dbo.TBL_COMP_MST ADD STMT_NOTICE NVARCHAR(500) NULL;   -- 거래명세서 맨 아래 공지사항 한 줄
GO

/* 확인
SELECT COMP_CD, JOB_SEQ, ACTION_YN, COMP_NM, BIZ_COND, BIZ_ITEM, BANK_ACCT, STMT_NOTICE
  FROM dbo.TBL_COMP_MST ORDER BY COMP_CD, JOB_SEQ;
*/
