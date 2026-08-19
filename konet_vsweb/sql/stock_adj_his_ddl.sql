/* =====================================================================================
 * 재고 일괄조정 이력 — TBL_STOCK_ADJ_HIS                                    2026-08-19
 *
 *   재고 수불원장(TBL_STOCK_LEDGER)은 **차이(조정수량)만** 남는다.
 *   "420 이던 것을 400 으로 고쳤다" 를 나중에 볼 수 없고, 한 번에 저장한 묶음도 흩어진다.
 *   그래서 조정 전/후 값과 저장 묶음을 따로 남긴다.
 *
 *   · 재고의 주인은 여전히 원장이다. 이 표는 **설명용 기록**이지 재고를 만들지 않는다.
 *   · LEDGER_SEQ 로 원장행과 짝을 맞춘다. 원장행이 지워지면(ACTION_YN='N') 여기도 함께 내린다.
 *   · PACK_QTY 를 같이 남기는 이유 : 입수수량이 나중에 바뀌면 BOX 환산이 달라져
 *     과거 기록을 재현할 수 없다. 그때의 값을 박아 둔다.
 *   · BATCH_NO 로 묶으면 [수정저장] 한 번을 통째로 되돌릴 수 있다.
 *
 *   ※ 운영 DB(KOLGSDB)에 반영합니다. 실행 전 백업 권장.
 * =================================================================================== */

IF OBJECT_ID('dbo.TBL_STOCK_ADJ_HIS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_STOCK_ADJ_HIS
    (
        ADJ_SEQ      INT             IDENTITY(1,1) NOT NULL,   -- 일련번호
        BATCH_NO     NVARCHAR(30)    NOT NULL,                 -- 저장 묶음 (수정저장 1회 = 1개)
        COMP_CD      VARCHAR(20)     NOT NULL,
        PROD_SEQ     BIGINT          NOT NULL,                 -- 상품마스터 PK 와 같은 형(BIGINT)
        PROD_CD      NVARCHAR(30)    NULL,

        BASE_DT      NVARCHAR(8)     NOT NULL,                 -- 기준일자 (YYYYMMDD) = 조정행 거래일자

        BEF_QTY      INT             NOT NULL DEFAULT 0,       -- 변경 전 재고 (EA 환산)
        AFT_QTY      INT             NOT NULL DEFAULT 0,       -- 변경 후 재고 (EA 환산)
        DIFF_QTY     INT             NOT NULL DEFAULT 0,       -- 차이 = 원장 조정행 수량

        BEF_BOX      INT             NULL,                     -- 화면에 보인 그대로
        BEF_EA       INT             NULL,
        AFT_BOX      INT             NULL,                     -- 사용자가 적은 그대로
        AFT_EA       INT             NULL,
        PACK_QTY     INT             NULL,                     -- 그때의 입수수량(환산 근거)

        LEDGER_SEQ   INT             NULL,                     -- 만들어진 원장행 (차이가 0이면 NULL)

        REMARK       NVARCHAR(200)   NULL,                     -- 사유
        ACTION_YN    NCHAR(1)        NOT NULL DEFAULT 'Y',
        REG_DTTM     NVARCHAR(19)    NULL,
        REG_USER     NVARCHAR(50)    NULL,
        REG_IP       NVARCHAR(50)    NULL,
        UPD_DTTM     NVARCHAR(19)    NULL,
        UPD_USER     NVARCHAR(50)    NULL,
        UPD_IP       NVARCHAR(50)    NULL,

        CONSTRAINT PK_STOCK_ADJ_HIS PRIMARY KEY CLUSTERED (ADJ_SEQ)
    );

    /* 조회 : 기간·품목·묶음 */
    CREATE INDEX IX_STOCK_ADJ_HIS_DT    ON dbo.TBL_STOCK_ADJ_HIS (COMP_CD, BASE_DT, PROD_SEQ);
    CREATE INDEX IX_STOCK_ADJ_HIS_BATCH ON dbo.TBL_STOCK_ADJ_HIS (BATCH_NO);
    CREATE INDEX IX_STOCK_ADJ_HIS_PROD  ON dbo.TBL_STOCK_ADJ_HIS (PROD_SEQ, BASE_DT DESC);
END
GO

/* 확인 --------------------------------------------------------------------------- */
-- SELECT TOP 50 * FROM dbo.TBL_STOCK_ADJ_HIS ORDER BY ADJ_SEQ DESC;
-- SELECT BATCH_NO, COUNT(*) AS 품목수, MIN(REG_DTTM) AS 저장시각, MAX(REG_USER) AS 등록자
--   FROM dbo.TBL_STOCK_ADJ_HIS WHERE ACTION_YN='Y' GROUP BY BATCH_NO ORDER BY 저장시각 DESC;
