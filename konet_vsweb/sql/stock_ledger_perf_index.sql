/* =====================================================================
   TBL_STOCK_LEDGER 집계 성능 인덱스  (2026-08-19)  MSSQL/KOLGSDB
   ---------------------------------------------------------------------
   배경: 재고 일괄조정(selectStockAdjList)·재고현황·재고마감이 전부
         원장을 품목별로 SUM 하는데(ACTION_YN + COMP_CD + TRX_DT 필터,
         PROD_SEQ 로 GROUP BY), 기존 인덱스(IX_STOCK_LEDGER_PROD 등)에는
         ACTION_YN/COMP_CD/IO_GB/QTY 가 없어 매번 **클러스터드 전체 스캔**
         (REMARK NVARCHAR(500) 같은 안 쓰는 컬럼까지 통째로 읽음)이었다.
   효과: 집계가 이 인덱스 하나로 끝난다(커버링 — key lookup 없음).
         읽는 폭이 행 전체 → 6컬럼으로 줄어 스캔이어도 몇 배 가볍다.
         ※ COMP_CD 조건이 fail-open OR 이라 seek 는 안 되지만,
           좁은 인덱스 스캔이라 그것으로 충분하다.
   같이 빨라지는 곳: selectStockAdjList(재고 일괄조정) ·
         selectStockMstList/recalcStockMst(재고현황) ·
         selectStockClosing(재고마감) · selectInboundClosing(매입마감)
   실행: 운영 DB(KOLGSDB)에서 1회. 재실행 안전(IF NOT EXISTS 가드).
         WAR 재빌드 불필요 — DB만 바꾼다.
   ===================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE name = 'IX_STOCK_LEDGER_AGG'
                  AND object_id = OBJECT_ID('dbo.TBL_STOCK_LEDGER'))
    CREATE NONCLUSTERED INDEX IX_STOCK_LEDGER_AGG
        ON dbo.TBL_STOCK_LEDGER (COMP_CD, ACTION_YN, PROD_SEQ, TRX_DT)
        INCLUDE (IO_GB, QTY);
