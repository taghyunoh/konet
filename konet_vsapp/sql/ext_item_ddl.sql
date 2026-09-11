/* =====================================================================================
   거래처 통보품목 — TBL_EXT_ITEM_MST                                     2026-08-01
   -------------------------------------------------------------------------------------
   왜 만드나
     지금은 거래처 코드(삼성웰스토리 등)를 **발주현황표를 올리는 순간**에야 처음 본다.
     그 자리에서 [연결]을 눌러 TBL_PROD_XREF 를 만드는데, 이는 '물건이 이미 나간 뒤'다.
     실제 업무는 반대로 흐른다 — 거래처가 **미리 품목코드·품목명을 통보**한다.
     그 통보를 받아 두는 자리가 없어서, 통보서는 메일·엑셀로만 굴러다니고
     업로드할 때 다시 손으로 맞췄다.

     이 표는 그 **통보 내용을 그대로 받아 두는 접수대장**이다.

   ★이 표는 매핑 표가 아니다 (2026-08-01 사용자 확정)
     · 여기 등록한다고 TBL_PROD_MST 에 상품이 생기지 않는다. 재고·원가와 무관하다.
     · 우리 품목과 이어 붙이는 방식(자동 추천/일괄 연결/업로드 시 자동 적용 등)은
       **다음에 결정한다.** 그래서 지금은 PROD_SEQ/PROD_CD/XREF_SEQ 칸만 비워 두고,
       채우는 로직은 넣지 않았다. 정하고 나면 이 칸을 쓰거나, 여기서 XREF 를 만들면 된다.
     · 발주현황표 업로드 흐름은 **아무것도 바뀌지 않는다** — 종전 그대로 동작한다.

   ★TBL_PROD_XREF 와의 차이 (섞지 말 것)
       TBL_PROD_XREF   = 거래처 코드 → **우리 품목** 확정 연결. 재고·출고서가 이걸 본다.
       TBL_EXT_ITEM_MST= 거래처가 통보한 코드·품명 **원문 접수**. 아직 우리 품목과 무관.
     통보를 받아 두었다가 → (방식 결정 후) → XREF 로 승격시키는 순서다.

   재실행 안전 — 이미 있으면 건너뛴다.
   ===================================================================================== */

IF OBJECT_ID('dbo.TBL_EXT_ITEM_MST', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_EXT_ITEM_MST (
        EXT_SEQ       INT IDENTITY(1,1) NOT NULL,      -- PK
        COMP_CD       VARCHAR(10)    NOT NULL DEFAULT 'W1234567',  -- 회사(멀티테넌트). DEFAULT 는 지우지 말 것

        /* 통보한 쪽 */
        VENDOR_CD     NVARCHAR(30)   NULL,             -- 거래처코드. NULL = 거래처 안 가림(공통)
        VENDOR_NM     NVARCHAR(100)  NULL,             -- 거래처명(가독용 사본)
        DC_CD         NVARCHAR(20)   NULL,             -- 출고장까지 지정해 통보한 경우만. NULL = 전체
        DC_NM         NVARCHAR(100)  NULL,

        /* 통보 내용 — ★원문 그대로 넣는다. 우리 식으로 고치지 않는다 */
        EXT_ITEM_CD   NVARCHAR(30)   NOT NULL,         -- 통보 품목코드
        EXT_ITEM_NM   NVARCHAR(300)  NULL,             -- 통보 품목명
        EXT_SPEC      NVARCHAR(300)  NULL,             -- 규격(오면)
        EXT_UNIT      NVARCHAR(20)   NULL,             -- 단위('BOX' 등)
        EXT_PRICE     DECIMAL(18,2)  NULL,             -- 단가(오면). 나중 매핑 대조에 가장 쓸모 있는 값
        TAX_GB        NVARCHAR(10)   NULL,             -- 과세/면세(오면)

        NOTI_DT       NVARCHAR(8)    NULL,             -- 통보받은 날 (YYYYMMDD)
        USE_FR_DT     NVARCHAR(8)    NULL,             -- 적용 시작일(오면)
        STAT_GB       NVARCHAR(10)   NULL,             -- 통보 구분 : 신규 / 변경 / 중단

        /* ↓ 매핑 자리 — 지금은 비워 둔다. 채우는 방식은 다음에 결정(위 설명 참조) */
        PROD_SEQ      INT            NULL,             -- 우리 품목(TBL_PROD_MST.PROD_SEQ)
        PROD_CD       NVARCHAR(30)   NULL,             -- 우리 품목코드(가독용 사본)
        XREF_SEQ      INT            NULL,             -- 실제 연결(TBL_PROD_XREF)로 승격했을 때 그 행

        REMARK        NVARCHAR(500)  NULL,
        ACTION_YN     NCHAR(1)       NOT NULL DEFAULT 'Y',   -- 소프트삭제
        REG_DTTM      NVARCHAR(19)   NULL,
        REG_USER      NVARCHAR(50)   NULL,
        REG_IP        NVARCHAR(50)   NULL,
        UPD_DTTM      NVARCHAR(19)   NULL,
        UPD_USER      NVARCHAR(50)   NULL,
        UPD_IP        NVARCHAR(50)   NULL,
        CONSTRAINT PK_TBL_EXT_ITEM_MST PRIMARY KEY (EXT_SEQ)
    );
    PRINT 'TBL_EXT_ITEM_MST 생성';
END
ELSE PRINT 'TBL_EXT_ITEM_MST 이미 있음 — 건너뜀';
GO

/* (거래처 + 통보 코드) 는 한 건만. 같은 코드가 또 통보되면 '새 줄'이 아니라 그 줄을 고친다.
   MSSQL 은 UNIQUE 인덱스에서 NULL 끼리를 같다고 보므로 VENDOR_CD 가 NULL(공통)인 경우도 중복이 막힌다.
   ACTION_YN='Y' 필터라 지운(소프트) 줄은 제약에서 빠진다 → 지웠다가 다시 넣을 수 있다. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_EXT_ITEM_CD' AND object_id=OBJECT_ID('dbo.TBL_EXT_ITEM_MST'))
    CREATE UNIQUE INDEX UX_EXT_ITEM_CD ON dbo.TBL_EXT_ITEM_MST
        (COMP_CD, VENDOR_CD, EXT_ITEM_CD) WHERE ACTION_YN = 'Y';
GO

/* ★업로드 해석(resolveShipoutProdExt/resolveSalesProdExt)의 조인 길 — 거래처 코드로 우리 품목을 찾는다.
     TBL_PROD_XREF 의 IX_PROD_XREF_ITEM 과 같은 역할. 골라 둔 것(PROD_SEQ NOT NULL)만 쓰므로 필터 인덱스. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EXT_ITEM_RESOLVE' AND object_id=OBJECT_ID('dbo.TBL_EXT_ITEM_MST'))
    CREATE INDEX IX_EXT_ITEM_RESOLVE ON dbo.TBL_EXT_ITEM_MST (COMP_CD, EXT_ITEM_CD, ACTION_YN)
        INCLUDE (PROD_SEQ, PROD_CD, VENDOR_CD) WHERE PROD_SEQ IS NOT NULL;
GO

/* 목록 조회(최근 통보 순) · 코드로 찾기 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EXT_ITEM_LIST' AND object_id=OBJECT_ID('dbo.TBL_EXT_ITEM_MST'))
    CREATE INDEX IX_EXT_ITEM_LIST ON dbo.TBL_EXT_ITEM_MST (COMP_CD, ACTION_YN, NOTI_DT)
        INCLUDE (EXT_ITEM_CD, EXT_ITEM_NM, VENDOR_CD, VENDOR_NM, PROD_SEQ);
GO


/* -------------------------------------------------------------------------------------
   확인
   ------------------------------------------------------------------------------------- */
-- SELECT COUNT(*) AS extItem FROM dbo.TBL_EXT_ITEM_MST;
-- SELECT TOP 50 * FROM dbo.TBL_EXT_ITEM_MST WHERE ACTION_YN='Y' ORDER BY EXT_SEQ DESC;

/* [참고] 가동 전 초기화(go_live_reset.sql)와의 관계
     통보대장은 상품·거래처와 같은 **기준정보**다 → 거래 데이터 초기화 때 지우지 않는다. */
