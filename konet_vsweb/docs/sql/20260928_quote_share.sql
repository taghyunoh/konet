/* =====================================================================
   견적서 카톡 공유 (2026-09-28 — 사용자 「견적서 관리에서도 발주서 관리처럼 카톡 공유」)
     카카오톡은 파일을 못 붙인다. 그래서 «로그인 없이 그 견적서 하나만 보는 공개 주소»를 만들어 링크를 보낸다
     → /pub/quote.do?t=토큰  (발주서 /pub/po.do · 거래명세서 /pub/stmt.do 와 같은 방식)
     · SHARE_TOKEN      : 공개 주소의 열쇠. ★한 번 발급되면 바뀌지 않는다(이미 보낸 링크가 살아 있어야 한다).
                          링크를 죽이려면 그 견적서의 SHARE_TOKEN 을 NULL 로 지운다.
     · SHARE_CNT        : 몇 번 보냈나 · LAST_SHARE_DTTM : 마지막으로 보낸 때
   ★필터 UNIQUE 인덱스 — 토큰은 전 회사를 통틀어 유일해야 한다(공개 조회가 토큰 하나만 보고 찾는다).
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전.
   ⚠WAR 배포 <전에> 실행할 것 — 새 매퍼가 이 칸을 읽는다(견적서 목록·공유·공개 페이지).
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_MST','SHARE_TOKEN') IS NULL
  ALTER TABLE dbo.TBL_QUOTE_MST ADD SHARE_TOKEN NVARCHAR(40) NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','SHARE_CNT') IS NULL
  ALTER TABLE dbo.TBL_QUOTE_MST ADD SHARE_CNT INT NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','LAST_SHARE_DTTM') IS NULL
  ALTER TABLE dbo.TBL_QUOTE_MST ADD LAST_SHARE_DTTM VARCHAR(19) NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_QUOTE_SHARE_TOKEN' AND object_id = OBJECT_ID('dbo.TBL_QUOTE_MST'))
  CREATE UNIQUE INDEX UX_QUOTE_SHARE_TOKEN ON dbo.TBL_QUOTE_MST (SHARE_TOKEN) WHERE SHARE_TOKEN IS NOT NULL;
GO
/* ── 확인 ── */
SELECT COL_LENGTH('dbo.TBL_QUOTE_MST','SHARE_TOKEN') AS token_len,
       COL_LENGTH('dbo.TBL_QUOTE_MST','SHARE_CNT')   AS cnt_len,
       COL_LENGTH('dbo.TBL_QUOTE_MST','LAST_SHARE_DTTM') AS dttm_len;
