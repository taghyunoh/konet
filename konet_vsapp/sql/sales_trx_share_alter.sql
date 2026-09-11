/* =====================================================================================
   TBL_SALES_TRX_MST 에 <공유 토큰> 추가 (MSSQL)  — 2026-09-09
   · 배경 : 판매등록 [🖨 거래명세표] 를 거래처에 **카톡·이메일로 보내는** 기능(2026-09-09 요청).
     카카오는 파일을 붙일 수 없고 <링크 카드>만 보낼 수 있으므로, 발주서(TBL_PO_MST.SHARE_TOKEN)와
     **똑같은 방식**으로 «로그인 없이 그 전표 하나만 보는 공개 주소»를 만든다 → /pub/stmt.do?t=토큰
   · 토큰은 전표를 저장할 때가 아니라 **처음 보낼 때** 발급한다(salesTrxShare.do) —
     이미 쌓여 있는 옛 전표도 그대로 보낼 수 있어야 하기 때문.
   · SHARE_CNT / LAST_SHARE_DTTM = 몇 번, 언제 보냈는지. 화면에 「N번 보냄」으로 보여 준다.
   · ★토큰을 지우면 그 링크는 즉시 죽는다(공개 조회가 토큰으로만 찾는다) — 잘못 보냈을 때의 회수 수단.
   · 각 구문 IF 가드로 재실행 안전.
   ===================================================================================== */
USE [KOLGSDB]
GO

IF COL_LENGTH('dbo.TBL_SALES_TRX_MST','SHARE_TOKEN') IS NULL
    ALTER TABLE dbo.TBL_SALES_TRX_MST ADD SHARE_TOKEN VARCHAR(32) NULL;      -- 공개 주소 열쇠(UUID 24자)
GO
IF COL_LENGTH('dbo.TBL_SALES_TRX_MST','SHARE_CNT') IS NULL
    ALTER TABLE dbo.TBL_SALES_TRX_MST ADD SHARE_CNT INT NULL;                -- 보낸 횟수
GO
IF COL_LENGTH('dbo.TBL_SALES_TRX_MST','LAST_SHARE_DTTM') IS NULL
    ALTER TABLE dbo.TBL_SALES_TRX_MST ADD LAST_SHARE_DTTM NVARCHAR(19) NULL; -- 마지막으로 보낸 일시 'YYYY-MM-DD HH:MM:SS'
GO

/* ★토큰은 전 회사를 통틀어 유일해야 한다 — 공개 조회가 토큰 하나만 보고 전표를 찾기 때문.
   필터 인덱스라 토큰이 없는(=아직 안 보낸) 전표는 여러 건이어도 걸리지 않는다. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_SALES_TRX_SHARE' AND object_id=OBJECT_ID('dbo.TBL_SALES_TRX_MST'))
    CREATE UNIQUE INDEX UX_SALES_TRX_SHARE ON dbo.TBL_SALES_TRX_MST (SHARE_TOKEN) WHERE SHARE_TOKEN IS NOT NULL;
GO

/* 확인
SELECT SALE_SEQ, SALE_DT, SALE_NO, CUST_NM, SHARE_TOKEN, SHARE_CNT, LAST_SHARE_DTTM
  FROM dbo.TBL_SALES_TRX_MST WHERE SHARE_TOKEN IS NOT NULL ORDER BY LAST_SHARE_DTTM DESC;

-- 잘못 보낸 링크 죽이기 (그 전표만)
-- UPDATE dbo.TBL_SALES_TRX_MST SET SHARE_TOKEN = NULL WHERE SALE_SEQ = ?;
*/
