/* =====================================================================
   TBL_SHIPOUT_MST 대시보드 조회 성능 인덱스  (2026-07-31)  MSSQL/KOLGSDB
   ---------------------------------------------------------------------
   배경: 대시보드 최초 진입 조회 4건(selectShipoutMst / selectShipoutPrev /
         selectShipoutHistAll / 셸 조회)이 전부 출고일자(SHPOUT_DT) 기준인데
         이 테이블에는 인덱스가 없어 매 조회가 풀스캔이었다.
         (운영 실측: selectShipoutPrev 2.2s · selectShipoutHistAll 1.3s)
   효과: 출고일자 슬라이스 seek + key lookup 으로 축소.
         selectShipoutPrev 는 쿼리도 윈도우 함수로 재작성(User_SQL.xml).
   실행: 운영 DB(KOLGSDB)에서 1회. 재실행 안전(IF NOT EXISTS 가드).
   ===================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE name = 'IX_SHIPOUT_DASH'
                  AND object_id = OBJECT_ID('dbo.TBL_SHIPOUT_MST'))
    CREATE NONCLUSTERED INDEX IX_SHIPOUT_DASH
        ON dbo.TBL_SHIPOUT_MST (SHPOUT_DT, ACTION_YN, COMP_CD);

/* 업로드 배치 대체(markShipoutHistory / getShipoutNextJobSeq)와
   매출내역 대사 조회는 납품일자(DLV_DT)+출고장(DC_CD)이 키 — 별도 인덱스 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE name = 'IX_SHIPOUT_BATCH'
                  AND object_id = OBJECT_ID('dbo.TBL_SHIPOUT_MST'))
    CREATE NONCLUSTERED INDEX IX_SHIPOUT_BATCH
        ON dbo.TBL_SHIPOUT_MST (DLV_DT, DC_CD, ACTION_YN, COMP_CD);
