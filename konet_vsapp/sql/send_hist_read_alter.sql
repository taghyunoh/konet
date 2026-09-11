/* =====================================================================================
   TBL_SEND_HIST 에 <읽음 · 열람> 칸 추가 (MSSQL)  — 2026-09-10
   · 배경 : 전송이력에 「메일을 읽었는지 · 명세서를 열어 봤는지」 도 보이게(사용자 요청 「메일 읽은정보 표시」).
   · 두 가지 신호를 <따로> 센다 — 뜻이 다르다 :
       MAIL_OPEN_* = 메일 본문의 1×1 그림(/pub/mailOpen.do?k=)이 불렸다 = 메일을 열었다.
                     ⚠메일 프로그램이 그림을 막으면 안 잡힌다(못 잡았다고 안 읽은 것이 아니다).
       VIEW_*      = 공개 명세서·발주서 링크(/pub/stmt.do · /pub/po.do)를 열었다 = 실제로 봤다. 이쪽이 더 확실하다.
   · TRACK_KEY = 보낼 때마다 새로 만드는 무작위 열쇠. 링크 뒤에 &s=열쇠 · 그림 주소에 ?k=열쇠 로 붙어 나가,
     열렸을 때 «어느 전송»이 열린 것인지 이 줄로 돌아온다(토큰은 전표당 하나라 전송을 못 가른다).
   · 각 구문 IF 가드로 재실행 안전. 신규 설치는 send_hist_ddl.sql 만으로 같은 칸이 생긴다.
   ===================================================================================== */
USE [KOLGSDB]
GO

IF COL_LENGTH('dbo.TBL_SEND_HIST','TRACK_KEY') IS NULL
    ALTER TABLE dbo.TBL_SEND_HIST ADD TRACK_KEY VARCHAR(32) NULL;         -- 전송 한 건의 열쇠(무작위 20자)
GO
IF COL_LENGTH('dbo.TBL_SEND_HIST','MAIL_OPEN_DTTM') IS NULL
    ALTER TABLE dbo.TBL_SEND_HIST ADD MAIL_OPEN_DTTM NVARCHAR(19) NULL;   -- 메일을 처음 연 일시
GO
IF COL_LENGTH('dbo.TBL_SEND_HIST','MAIL_OPEN_CNT') IS NULL
    ALTER TABLE dbo.TBL_SEND_HIST ADD MAIL_OPEN_CNT INT NULL;             -- 메일을 연 횟수
GO
IF COL_LENGTH('dbo.TBL_SEND_HIST','VIEW_DTTM') IS NULL
    ALTER TABLE dbo.TBL_SEND_HIST ADD VIEW_DTTM NVARCHAR(19) NULL;        -- 명세서(링크)를 처음 열어 본 일시
GO
IF COL_LENGTH('dbo.TBL_SEND_HIST','VIEW_CNT') IS NULL
    ALTER TABLE dbo.TBL_SEND_HIST ADD VIEW_CNT INT NULL;                  -- 열어 본 횟수
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SEND_HIST_KEY' AND object_id=OBJECT_ID('dbo.TBL_SEND_HIST'))
    CREATE INDEX IX_SEND_HIST_KEY ON dbo.TBL_SEND_HIST (TRACK_KEY) WHERE TRACK_KEY IS NOT NULL;
GO

/* 확인
SELECT TOP 50 SEND_SEQ, SEND_GB, SEND_TO, REG_DTTM, MAIL_OPEN_DTTM, MAIL_OPEN_CNT, VIEW_DTTM, VIEW_CNT
  FROM dbo.TBL_SEND_HIST ORDER BY SEND_SEQ DESC;
*/
