/* =====================================================================
   견적서 카톡 공유 — 마스터 승인 (2026-11-05 사용자 「견적서 카톡공유 마스터 승인없이 못올라게」)
     · 카톡 공유·링크 복사(공개 주소 발급)는 총괄관리자(TBL_USER_MST.MAIN_GU='1')가 승인한 견적서만 된다.
     · APPR_YN   : 'Y' 승인 · 그 외 미승인
     · APPR_DTTM : 승인한 때 · APPR_USER : 승인한 사람(로그인 아이디)
     · 고쳐 저장하면 새 줄(새 QUOTE_SEQ)이 생기므로 승인은 저절로 풀린다(승인한 내용 그대로만 나간다).
       이미 발급된 옛 링크(SHARE_TOKEN)는 그대로 살아 있다 — 죽이려면 SHARE_TOKEN 을 NULL 로.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전.
   ⚠톰캣(WAR) 올리기 <전에> 실행할 것 — 새 매퍼가 이 칸을 읽는다(견적서 목록·공유).
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_MST','APPR_YN') IS NULL
  ALTER TABLE dbo.TBL_QUOTE_MST ADD APPR_YN CHAR(1) NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','APPR_DTTM') IS NULL
  ALTER TABLE dbo.TBL_QUOTE_MST ADD APPR_DTTM VARCHAR(19) NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','APPR_USER') IS NULL
  ALTER TABLE dbo.TBL_QUOTE_MST ADD APPR_USER NVARCHAR(50) NULL;
GO
/* ── 확인 — 셋 다 숫자가 나오면 됨 ── */
SELECT COL_LENGTH('dbo.TBL_QUOTE_MST','APPR_YN') AS appr_yn,
       COL_LENGTH('dbo.TBL_QUOTE_MST','APPR_DTTM') AS appr_dttm,
       COL_LENGTH('dbo.TBL_QUOTE_MST','APPR_USER') AS appr_user;
