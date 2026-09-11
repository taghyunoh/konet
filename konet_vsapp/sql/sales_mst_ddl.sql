/* =====================================================================================
   매출(판매) 확정내역 — TBL_SALES_MST (출고장 제공 엑셀 원본 보관)  MSSQL
   · 원천 : 출고한 곳(출고장) 프로그램이 출력하는 엑셀 (생성기 'DataLudi', 시트 'Sheet1')
   · ★관점 주의 : 엑셀은 '출고장 기준'으로 쓰여 있다. 우리 기준으로 뒤집어 저장한다.
        엑셀 '입고량'    = 출고장이 받은 수량   = 우리 출고량      → OUT_QTY
        엑셀 '단가'      = 출고장의 매입단가    = 우리 판매단가    → SALE_PRICE
        엑셀 '매입금액'  = 출고장의 매입금액    = 우리 매출액      → SALE_AMT
        엑셀 '입고일자'  = 출고장 입고일        = 우리 출고일자    → OUT_DT
     (근거: 평택 엑셀 단가를 매출마감 화면과 대조 → 6건 중 5건이 '출고단가'와 정확히 일치,
      '매입단가'와 일치한 건은 0건. 남은 1건은 화면이 월 가중평균이라 월중 단가변경으로 설명됨)
   · 우리 매입가(공급업체→우리)는 이 표와 무관 — TBL_PROD_MST.IN_PRICE / TBL_PROD_INPRICE_HST 가 계속 담당
   · 낱알(grain) = 발주번호(ORD_NO) + 발주항번(ORD_ITEM_NO)  → TBL_SHIPOUT_MST 의 ORD_NO+ORD_ITEM_NO 와 동일
   · 배치·이력 복합키 = (DLV_DT 납품일자 + DC_NM 출고장) / 버전 JOB_SEQ / 활성·이력 ACTION_YN
     (엑셀 파일 1개 = 1배치. 재업로드 시 기존 활성배치 ACTION_YN='N' 이력마감 후 JOB_SEQ+1 신규 적재)

   설계 메모 (실제 파일 4건 파싱으로 확인한 사실)
     · 출고장(평택/오산/왜관/용인)은 엑셀 안에 없고 파일명에만 있다 → DC_NM 은 파일명에서 확보
     · 한 파일에 발주번호가 여러 개 올 수 있다 (평택: 5059104963 + 5059112297)
     · 수량은 소수·음수가 온다 (발주량 0.49 / 입고량 -0.49 반품행) → INT 금지, DECIMAL(18,3)
     · 납품일자·입고일자는 엑셀 date serial(46214=2026-07-11) → 화면에서 yyyy-mm-dd 로 변환 후 전송
     · 마지막 행은 합계행 → 적재 제외 (품목코드 없는 행으로 판별)
     · 매입금액 = 입고량 × 단가 (전 행 검산 일치) → SALE_AMT = OUT_QTY × SALE_PRICE

   TBL_SHIPOUT_MST 와 분리한 이유
     · 발주현황표는 재업로드 시 통째 이력화된다. 거기에 단가를 얹으면 확정 금액이 함께 사라진다.
     · 원천·생명주기가 다르다(발주표=물류 지시 / 이 표=금액 확정본).
   ===================================================================================== */
USE [KOLGSDB]
GO

IF OBJECT_ID('dbo.TBL_SALES_MST','U') IS NULL
CREATE TABLE dbo.TBL_SALES_MST (
    SALES_SEQ    INT IDENTITY(1,1) NOT NULL,   -- PK

    -- ----- 배치·이력 메타 -----
    JOB_SEQ      INT            NOT NULL,       -- 업로드(배치) 버전
    ACTION_YN    NCHAR(1)       NOT NULL DEFAULT 'Y',   -- 'Y'=활성 / 'N'=이력(재업로드로 대체됨)
    ROW_NO       INT            NULL,           -- 엑셀 No
    SRC_FILE     NVARCHAR(200)  NULL,           -- 원본 엑셀 파일명 (예: 2026.07.11_평택.xlsx)
    UPLOAD_DTTM  DATETIME       NULL,           -- 업로드 일시

    -- ----- 출고장(파일명에서 확보) -----
    DC_CD        NVARCHAR(20)   NULL,           -- 물류센터코드 (선택 — 매핑 확정 전이면 NULL)
    DC_NM        NVARCHAR(100)  NULL,           -- 출고장명 (평택/오산/왜관/용인) ★배치키

    -- ----- 엑셀 본문 (우리 관점으로 환산) -----
    ORD_NO       NVARCHAR(30)   NULL,           -- 발주번호 (엑셀 '발주번호')
    ORD_ITEM_NO  NVARCHAR(20)   NULL,           -- 발주항번 (엑셀 '발주항번' 00010, 00020 …)
    ITEM_CD      NVARCHAR(30)   NULL,           -- 품목코드
    ITEM_NM      NVARCHAR(300)  NULL,           -- 품목명
    SPEC         NVARCHAR(300)  NULL,           -- 규격
    UNIT         NVARCHAR(20)   NULL,           -- 단위 (BOX 등)
    ORD_QTY      DECIMAL(18,3)  NULL,           -- 발주량 (출고장이 발주한 수량, 소수 가능)
    SETTLE_QTY   DECIMAL(18,3)  NULL,           -- 정산수량 (현재 0 — 추후 채워질 수 있어 컬럼만 확보)
    SETTLE_AMT   DECIMAL(18,2)  NULL,           -- 정산금액 (현재 0)
    DLV_DT       NVARCHAR(8)    NOT NULL,       -- 납품일자 'YYYYMMDD' ★배치키
    OUT_DT       NVARCHAR(8)    NULL,           -- 우리 출고일자 'YYYYMMDD'  ← 엑셀 '입고일자'
    OUT_QTY      DECIMAL(18,3)  NULL,           -- 우리 출고량 (음수=반품/차감)  ← 엑셀 '입고량'
    SALE_PRICE   DECIMAL(18,2)  NULL,           -- 우리 판매(출고)단가          ← 엑셀 '단가'
    SALE_AMT     DECIMAL(18,2)  NULL,           -- 우리 매출액 (= OUT_QTY × SALE_PRICE)  ← 엑셀 '매입금액'
    DLV_TYPE     NVARCHAR(50)   NULL,           -- 납품유형
    TAX_GB       NVARCHAR(10)   NULL,           -- 면과세 구분

    -- ----- 감사 -----
    REG_DTTM     NVARCHAR(19)   NULL,
    REG_USER     NVARCHAR(50)   NULL,
    REG_IP       NVARCHAR(50)   NULL,
    UPD_DTTM     NVARCHAR(19)   NULL,
    UPD_USER     NVARCHAR(50)   NULL,
    UPD_IP       NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_SALES_MST PRIMARY KEY (SALES_SEQ)
);
GO

/* 배치 조회·이력마감용 (납품일자 + 출고장 + 활성여부) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALES_BATCH' AND object_id=OBJECT_ID('dbo.TBL_SALES_MST'))
    CREATE INDEX IX_SALES_BATCH ON dbo.TBL_SALES_MST (DLV_DT, DC_NM, ACTION_YN);
GO

/* 품목별 판매단가 추적용 (→ 추후 TBL_PROD_SALEPRICE_HST 적재 근거) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALES_ITEM' AND object_id=OBJECT_ID('dbo.TBL_SALES_MST'))
    CREATE INDEX IX_SALES_ITEM ON dbo.TBL_SALES_MST (ITEM_CD, OUT_DT);
GO

/* 발주 라인 매칭용 (TBL_SHIPOUT_MST.ORD_NO + ORD_ITEM_NO 와 조인) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALES_ORD' AND object_id=OBJECT_ID('dbo.TBL_SALES_MST'))
    CREATE INDEX IX_SALES_ORD ON dbo.TBL_SALES_MST (ORD_NO, ORD_ITEM_NO);
GO
