/* =====================================================================
   재고 일괄조정 — 승인 요청 표 TBL_STOCK_ADJ_REQ                          2026-11-18
   ---------------------------------------------------------------------
   왜 : 「재고 일괄조정에서 총괄관리자·부관리자가 승인해야 저장되게(작성 후 승인이 돼야 저장)」.
        직원이 [수정저장]을 누르면 재고(원장·조정 이력)를 바로 바꾸지 않고 이 표에 «요청»으로 쌓는다.
        총괄관리자·부관리자(MAIN_GU 1·2)가 승인하면 그때 종전 저장(saveStockAdjBatch)이 그대로 돈다.

   · PAYLOAD  = 화면이 보낸 조정 줄(JSON 배열 — prodSeq·prodCd·prodNm·packQty·befQty·befBox·befEa·aftBox·aftEa).
                승인 때 이 줄을 그대로 다시 태운다 = 「전 → 후」 차이(증감)만큼 조정된다(요청 뒤 출고가 더 나가도 증감은 같다).
   · STAT_GB  = P 승인 대기 · A 승인(재고 반영됨 · BATCH_NO = 조정 묶음 번호) · R 반려 · C 요청자가 취소
   · 일시는 이 프로젝트 규칙대로 NVARCHAR(19) 'yyyy-MM-dd HH:mm:ss'

   ★재실행 안전(이미 있으면 건너뛴다). ★새 WAR 보다 «먼저» 실행한다 — 표가 없으면 직원의 [수정저장]과 승인 요청 목록이 오류가 난다
     (관리자의 저장은 종전대로 이 표를 안 거친다).
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_STOCK_ADJ_REQ', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_STOCK_ADJ_REQ
    (
        REQ_SEQ     BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        COMP_CD     VARCHAR(10)    NOT NULL CONSTRAINT DF_STOCK_ADJ_REQ_COMP DEFAULT 'W1234567',
        BASE_DT     NVARCHAR(8)    NULL,                      -- 기준일자(조정행 날짜) YYYYMMDD
        WH_CD       NVARCHAR(20)   NULL,                      -- 조정 창고(비면 기본창고)
        REMARK      NVARCHAR(200)  NULL,                      -- 사유
        ITEM_CNT    INT            NOT NULL CONSTRAINT DF_STOCK_ADJ_REQ_CNT DEFAULT 0,   -- 고친 줄 수
        DIFF_SUM    INT            NOT NULL CONSTRAINT DF_STOCK_ADJ_REQ_DIF DEFAULT 0,   -- 증감 합
        PAYLOAD     NVARCHAR(MAX)  NULL,                      -- 조정 줄(JSON)
        SRC         NVARCHAR(20)   NULL,                      -- 어느 화면에서(stockAdj · prodcd)
        STAT_GB     CHAR(1)        NOT NULL CONSTRAINT DF_STOCK_ADJ_REQ_STAT DEFAULT 'P',
        REQ_USER    NVARCHAR(50)   NULL,
        REQ_DTTM    NVARCHAR(19)   NULL,
        REQ_IP      NVARCHAR(50)   NULL,
        APPR_USER   NVARCHAR(50)   NULL,                      -- 승인·반려·취소한 사람
        APPR_DTTM   NVARCHAR(19)   NULL,
        APPR_MEMO   NVARCHAR(200)  NULL,                      -- 반려 사유 등
        REQ_SEEN_DTTM NVARCHAR(19) NULL,                      -- 요청한 사람이 결과(승인·반려)를 «확인»한 때. NULL = 아직 안 봄 → 메뉴 배지·알림
        BATCH_NO    NVARCHAR(40)   NULL                       -- 승인으로 만들어진 조정 묶음(TBL_STOCK_ADJ_HIS.BATCH_NO)
    );
    PRINT 'TBL_STOCK_ADJ_REQ 생성';
END
ELSE PRINT 'TBL_STOCK_ADJ_REQ 이미 있음 — 건너뜀';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_STOCK_ADJ_REQ_STAT' AND object_id = OBJECT_ID('dbo.TBL_STOCK_ADJ_REQ'))
BEGIN
    CREATE INDEX IX_STOCK_ADJ_REQ_STAT ON dbo.TBL_STOCK_ADJ_REQ (COMP_CD, STAT_GB, REQ_SEQ DESC);
    PRINT 'IX_STOCK_ADJ_REQ_STAT 생성';
END
GO

/* ── 요청한 직원에게 결과 알림 (2026-11-18 「요청한 직원에게도 승인/반려 결과 알림 표시」) ──
   REQ_SEEN_DTTM = 요청한 사람이 결과를 [확인했습니다] 한 때. NULL 이고 상태가 승인·반려(·남이 한 취소)면 그 직원 메뉴에 배지·알림이 뜬다.
   ★표를 이미 만든 DB 는 이 블록만 새로 돈다(위 CREATE 는 건너뜀). 이 칸이 없어도 승인·저장은 되고, 결과 알림만 안 뜬다. */
IF COL_LENGTH('dbo.TBL_STOCK_ADJ_REQ', 'REQ_SEEN_DTTM') IS NULL
BEGIN
    ALTER TABLE dbo.TBL_STOCK_ADJ_REQ ADD REQ_SEEN_DTTM NVARCHAR(19) NULL;
    PRINT 'REQ_SEEN_DTTM 추가';
END
ELSE PRINT 'REQ_SEEN_DTTM 이미 있음 — 건너뜀';
GO

/* 확인 */
SELECT COUNT(*) AS reqRows, COL_LENGTH('dbo.TBL_STOCK_ADJ_REQ', 'REQ_SEEN_DTTM') AS seenColLen FROM dbo.TBL_STOCK_ADJ_REQ;
