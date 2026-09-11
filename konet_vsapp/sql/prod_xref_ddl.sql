/* =====================================================================================
   거래처별 품목 표기(교차참조) — TBL_PROD_XREF                        2026-08-01
   -------------------------------------------------------------------------------------
   왜 만드나
     코네트는 품목코드·품목명을 하나로 쓰고 싶은데, 거래처(출고장)는 같은 물건을 자기
     코드·자기 품명으로 요청한다. 종전에는 그 표기마다 TBL_PROD_MST 에 '가상코드'를 새로
     등록해 맞췄고, 그래서 **재고가 원코드와 가상코드로 갈라졌다.**

     원인은 운영이 아니라 모델이다 — 지금 SQL 이 '거래처 코드 = 우리 코드' 를 전제로
     `pm.PROD_CD = t.ITEM_CD` 로 직접 비교한다(User_SQL.xml 17군데 / 6개 구문:
     selectClosing · selectSalesChart · selectSalesChartDaily · selectShipoutMst ·
     selectStockLedgerList · insertShipoutLedger). 거래처 표기를 담을 자리가 없다.

   원칙
     · **품목 마스터는 하나. 거래처 표기는 이 표에 N건.** 가상코드는 만들지 않는다.
     · 재고·원가는 언제나 TBL_PROD_MST.PROD_SEQ 하나가 주인이다.
     · 업로드 원본(TBL_SHIPOUT_MST.ITEM_CD/ITEM_NM, TBL_SALES_MST.ITEM_CD/ITEM_NM)은
       **거래처가 준 값 그대로 계속 저장**한다(원본 보존). 거기에 '우리 어느 품목이냐'는
       칸(PROD_SEQ)만 덧붙인다.
     · 출고서·거래명세서에 찍히는 품명 = ISNULL(XREF.EXT_ITEM_NM, PROD_MST.PROD_NM)
       → **거래처가 요청한 이름으로 나간다.**

   ★역방향 유일성 (이 표에서 가장 중요한 제약)
     (거래처 + 그쪽 코드) → 우리 품목은 반드시 **1개**. 안 그러면 업로드된 행이 어느
     품목으로 갈지 정할 수 없다. UX_PROD_XREF_EXT 가 강제한다.
     반대로 우리 품목 하나에 거래처 코드가 여럿인 것은 정상(허용).

   재실행 안전 — 이미 있으면 건너뛴다.
   ===================================================================================== */


/* -------------------------------------------------------------------------------------
   1) TBL_PROD_XREF — 거래처별 품목 표기
   ------------------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.TBL_PROD_XREF', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_PROD_XREF (
        XREF_SEQ      INT IDENTITY(1,1) NOT NULL,      -- PK
        COMP_CD       VARCHAR(10)    NOT NULL DEFAULT 'W1234567',  -- 회사(멀티테넌트). DEFAULT 는 지우지 말 것

        /* 우리 쪽 — 재고의 주인 */
        PROD_SEQ      INT            NOT NULL,         -- TBL_PROD_MST.PROD_SEQ
        PROD_CD       NVARCHAR(30)   NOT NULL,         -- 우리 품목코드(가독용 사본)

        /* 거래처 쪽 — 요청 표기 */
        VENDOR_CD     NVARCHAR(30)   NULL,             -- 거래처코드. ★NULL = 모든 거래처 공통 별칭
        VENDOR_NM     NVARCHAR(100)  NULL,             -- 거래처명(가독용 사본)
        DC_CD         NVARCHAR(20)   NULL,             -- 출고장까지 표기가 갈릴 때만. NULL = 그 거래처 전체
        EXT_ITEM_CD   NVARCHAR(30)   NOT NULL,         -- ★거래처가 쓰는 품목코드 (업로드 ITEM_CD 와 맞대는 칸)
        EXT_ITEM_NM   NVARCHAR(300)  NULL,             -- ★거래처가 쓰는 품목명 (출고서·명세서에 찍히는 이름)
        EXT_SPEC      NVARCHAR(300)  NULL,             -- 거래처 규격 표기(검증 대조용)
        EXT_UNIT      NVARCHAR(20)   NULL,             -- 거래처 단위 표기('BOX' 등)

        /* 환산 — 거래처가 박스로 세고 우리가 낱개로 셀 때. 기본 1.
           가상코드 방식은 이걸 담을 곳이 아예 없었다(가상코드에 별도 재고가 생겨서). */
        CONV_QTY      DECIMAL(18,3)  NOT NULL DEFAULT 1,   -- 거래처 수량 1 = 우리 수량 N

        MAIN_YN       NCHAR(1)       NOT NULL DEFAULT 'N',  -- 그 거래처의 대표 표기(출력 기본값)

        /* 검증 상태 — 자동 추천은 무조건 미확인('N')으로 들어오고, 사람이 확인해야 'Y'.
           자동 확정은 두지 않는다. 잘못 매핑되면 재고와 매출이 동시에 틀어진다. */
        MATCH_SCORE   INT            NULL,             -- 자동 대조 점수 0~100 (단가·규격·면과세·품명)
        CONFIRM_YN    NCHAR(1)       NOT NULL DEFAULT 'N',
        CONFIRM_USER  NVARCHAR(50)   NULL,
        CONFIRM_DTTM  NVARCHAR(19)   NULL,

        REMARK        NVARCHAR(500)  NULL,
        ACTION_YN     NCHAR(1)       NOT NULL DEFAULT 'Y',   -- 소프트삭제
        REG_DTTM      NVARCHAR(19)   NULL,
        REG_USER      NVARCHAR(50)   NULL,
        REG_IP        NVARCHAR(50)   NULL,
        UPD_DTTM      NVARCHAR(19)   NULL,
        UPD_USER      NVARCHAR(50)   NULL,
        UPD_IP        NVARCHAR(50)   NULL,
        CONSTRAINT PK_TBL_PROD_XREF PRIMARY KEY (XREF_SEQ)
    );
    PRINT 'TBL_PROD_XREF 생성';
END
ELSE PRINT 'TBL_PROD_XREF 이미 있음 — 건너뜀';
GO

/* ★(거래처 + 출고장 + 그쪽 코드) → 우리 품목 1개. 같은 코드를 두 품목에 붙이면 INSERT 가 실패한다.
     MSSQL 은 UNIQUE 인덱스에서 NULL 끼리를 '같다'고 보므로 VENDOR_CD/DC_CD 가 NULL(공통 별칭)인
     경우도 중복이 막힌다 — 의도한 동작이다.
     ACTION_YN='Y' 필터라 삭제(소프트)한 행은 제약에서 빠진다 → 지웠다가 다시 걸 수 있다. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_PROD_XREF_EXT' AND object_id=OBJECT_ID('dbo.TBL_PROD_XREF'))
    CREATE UNIQUE INDEX UX_PROD_XREF_EXT ON dbo.TBL_PROD_XREF
        (COMP_CD, VENDOR_CD, DC_CD, EXT_ITEM_CD) WHERE ACTION_YN = 'Y';
GO

/* 업로드 해석(resolveShipoutProd/resolveSalesProd)의 조인 — 거래처 코드로 우리 품목을 찾는 길.
   조인에 필요한 칸을 INCLUDE 해 두면 인덱스만 읽고 끝난다(수천 행 배치를 한 문장으로 처리). */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PROD_XREF_ITEM' AND object_id=OBJECT_ID('dbo.TBL_PROD_XREF'))
    CREATE INDEX IX_PROD_XREF_ITEM ON dbo.TBL_PROD_XREF (COMP_CD, EXT_ITEM_CD, ACTION_YN)
        INCLUDE (PROD_SEQ, PROD_CD, VENDOR_CD, DC_CD, CONV_QTY, EXT_ITEM_NM);
GO

/* 상품관리 화면 — 이 품목의 거래처 표기 목록 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PROD_XREF_PROD' AND object_id=OBJECT_ID('dbo.TBL_PROD_XREF'))
    CREATE INDEX IX_PROD_XREF_PROD ON dbo.TBL_PROD_XREF (COMP_CD, PROD_SEQ, ACTION_YN);
GO


/* -------------------------------------------------------------------------------------
   2) TBL_SHIPOUT_MST — '우리 어느 품목이냐' 두 칸 추가 (발주현황표 업로드)
      · ITEM_CD / ITEM_NM 은 그대로 둔다 — 거래처가 준 원본이다.
      · PROD_SEQ 가 NULL = 미매핑. 재고연동에서 자연히 빠진다(별도 조건 불필요).
      · 채우는 것은 배치 저장 직후 UPDATE 한 문장(resolveShipoutProd). 행마다 조회하지 않는다.
   ------------------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.TBL_SHIPOUT_MST') AND name='PROD_SEQ')
    ALTER TABLE dbo.TBL_SHIPOUT_MST ADD PROD_SEQ INT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.TBL_SHIPOUT_MST') AND name='PROD_CD')
    ALTER TABLE dbo.TBL_SHIPOUT_MST ADD PROD_CD NVARCHAR(30) NULL;
GO
/* 재고연동(syncShipoutLedgerDate)이 PROD_SEQ 기준으로 바뀌므로 그 길을 열어 준다.
   기존 IX_SHIPOUT_DASH(SHPOUT_DT, ACTION_YN, COMP_CD)는 그대로 둔다 — 용도가 다르다. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SHIPOUT_PRODSEQ' AND object_id=OBJECT_ID('dbo.TBL_SHIPOUT_MST'))
    CREATE INDEX IX_SHIPOUT_PRODSEQ ON dbo.TBL_SHIPOUT_MST (COMP_CD, PROD_SEQ, SHPOUT_DT, ACTION_YN);
GO
/* 미매핑 목록 — '처음 보는 코드'를 거래처·코드별로 모아 보여줄 때 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SHIPOUT_UNMAPPED' AND object_id=OBJECT_ID('dbo.TBL_SHIPOUT_MST'))
    CREATE INDEX IX_SHIPOUT_UNMAPPED ON dbo.TBL_SHIPOUT_MST (COMP_CD, ITEM_CD, ACTION_YN)
        INCLUDE (ITEM_NM, DC_CD, DC_NM, VENDOR_CD, SHPOUT_DT) WHERE PROD_SEQ IS NULL;
GO


/* -------------------------------------------------------------------------------------
   3) TBL_SALES_MST — 같은 두 칸 (정산서 엑셀 업로드)
      · 이 표에는 SPEC / SALE_PRICE / TAX_GB 가 있어 **매핑 검증의 주 근거**가 된다.
        (실측 근거: 정산 엑셀 단가는 우리 '출고단가'와 일치 — 평택 6건 중 5건 정확히 일치,
         매입단가 일치 0건. CLAUDE.md 기록)
   ------------------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.TBL_SALES_MST') AND name='PROD_SEQ')
    ALTER TABLE dbo.TBL_SALES_MST ADD PROD_SEQ INT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.TBL_SALES_MST') AND name='PROD_CD')
    ALTER TABLE dbo.TBL_SALES_MST ADD PROD_CD NVARCHAR(30) NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALES_PRODSEQ' AND object_id=OBJECT_ID('dbo.TBL_SALES_MST'))
    CREATE INDEX IX_SALES_PRODSEQ ON dbo.TBL_SALES_MST (COMP_CD, PROD_SEQ, DLV_DT, ACTION_YN);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALES_UNMAPPED' AND object_id=OBJECT_ID('dbo.TBL_SALES_MST'))
    CREATE INDEX IX_SALES_UNMAPPED ON dbo.TBL_SALES_MST (COMP_CD, ITEM_CD, ACTION_YN)
        INCLUDE (ITEM_NM, SPEC, UNIT, SALE_PRICE, TAX_GB, DC_CD, DC_NM, DLV_DT) WHERE PROD_SEQ IS NULL;
GO


/* -------------------------------------------------------------------------------------
   확인
   ------------------------------------------------------------------------------------- */
-- SELECT COUNT(*) AS xref FROM dbo.TBL_PROD_XREF;
-- SELECT name FROM sys.columns WHERE object_id=OBJECT_ID('dbo.TBL_SHIPOUT_MST') AND name IN ('PROD_SEQ','PROD_CD');
-- SELECT name FROM sys.columns WHERE object_id=OBJECT_ID('dbo.TBL_SALES_MST')   AND name IN ('PROD_SEQ','PROD_CD');

/* -------------------------------------------------------------------------------------
   [참고] 가동 전 초기화(go_live_reset.sql)와의 관계
     TBL_PROD_XREF 는 상품·거래처와 같은 **기준정보**다 → 거래 데이터 초기화 때 지우지 않는다.
     다만 TBL_PROD_MST 를 비운다면 XREF 도 함께 비워야 한다(PROD_SEQ 가 붕 뜬다).
       -- TRUNCATE TABLE TBL_PROD_XREF;   -- 상품마스터를 지울 때만 같이
   ------------------------------------------------------------------------------------- */
