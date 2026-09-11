/* =====================================================================================
   물류 - 매입가 / 판매가 / 재고 관리 추가 테이블 (MSSQL)
   기준: TBL_PROD_MST(품목마스터=현재값 보유) + TBL_SHIPOUT_MST(출고)
   설계원칙:
     · TBL_PROD_MST 는 "현재값"(IN_PRICE 매입, SALE_PRICE 판매, WHOLE_PRICE 도매, SAFE_STOCK 적정재고) 유지
     · 아래 4개 테이블은 "변경 이력 / 수불(입출고) 원장 / 현재고 집계" 를 분리 관리
     · PK = XXX_SEQ IDENTITY, 품목연결 = PROD_SEQ(마스터 PK) + PROD_CD(가독성)
     · 금액/단가 DECIMAL(18,2), 일자 NVARCHAR(8) 'YYYYMMDD', 일시 NVARCHAR(19) 'YYYY-MM-DD HH:MI:SS'
     · 소프트삭제 ACTION_YN('Y'/'N') + 감사컬럼(REG_/UPD_)
   ===================================================================================== */


/* -------------------------------------------------------------------------------------
   1) 매입가 관리 — TBL_PROD_INPRICE_HST (매입단가 이력)
      · 매입처(협력업체)별·적용일자별 매입단가를 기록. 현재값은 TBL_PROD_MST.IN_PRICE 로 동기화
      · "언제부터 / 어느 매입처 / 얼마" 를 이력으로 남겨 단가 추적·소급조회 가능
   ------------------------------------------------------------------------------------- */
CREATE TABLE TBL_PROD_INPRICE_HST (
    INPRICE_SEQ   INT IDENTITY(1,1) NOT NULL,   -- PK
    PROD_SEQ      INT            NOT NULL,       -- 품목마스터 PK (TBL_PROD_MST.PROD_SEQ)
    PROD_CD       NVARCHAR(30)   NOT NULL,       -- 품목코드(가독/조회용)
    VENDOR_CD     NVARCHAR(30)   NULL,           -- 매입처(협력업체) 코드
    VENDOR_NM     NVARCHAR(100)  NULL,           -- 매입처명
    APPLY_DT      NVARCHAR(8)    NOT NULL,       -- 적용시작일자 'YYYYMMDD'
    IN_PRICE      DECIMAL(18,2)  NOT NULL,       -- 매입단가
    PREV_PRICE    DECIMAL(18,2)  NULL,           -- 직전 매입단가(변동폭 확인용)
    TAX_GB        NVARCHAR(10)   NULL,           -- 과세구분('과세'/'면세') — 마스터와 동일 체계
    REMARK        NVARCHAR(500)  NULL,           -- 사유/비고
    ACTION_YN     NCHAR(1)       NOT NULL DEFAULT 'Y',   -- 'Y'=유효 / 'N'=취소·삭제
    REG_DTTM      NVARCHAR(19)   NULL,
    REG_USER      NVARCHAR(50)   NULL,
    REG_IP        NVARCHAR(50)   NULL,
    UPD_DTTM      NVARCHAR(19)   NULL,
    UPD_USER      NVARCHAR(50)   NULL,
    UPD_IP        NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_PROD_INPRICE_HST PRIMARY KEY (INPRICE_SEQ)
);
CREATE INDEX IX_INPRICE_PROD ON TBL_PROD_INPRICE_HST (PROD_SEQ, APPLY_DT);
CREATE INDEX IX_INPRICE_CD   ON TBL_PROD_INPRICE_HST (PROD_CD, APPLY_DT);


/* -------------------------------------------------------------------------------------
   2) 판매가 관리 — TBL_PROD_SALEPRICE_HST (판매/도매 단가 이력)
      · 적용일자별 판매단가·도매단가를 기록. 현재값은 TBL_PROD_MST.SALE_PRICE/WHOLE_PRICE 로 동기화
      · 마진(판매가-매입가) 참고를 위해 기준매입가(BASE_INPRICE)도 스냅샷 저장
   ------------------------------------------------------------------------------------- */
CREATE TABLE TBL_PROD_SALEPRICE_HST (
    SALEPRICE_SEQ INT IDENTITY(1,1) NOT NULL,   -- PK
    PROD_SEQ      INT            NOT NULL,       -- 품목마스터 PK
    PROD_CD       NVARCHAR(30)   NOT NULL,       -- 품목코드
    APPLY_DT      NVARCHAR(8)    NOT NULL,       -- 적용시작일자 'YYYYMMDD'
    SALE_PRICE    DECIMAL(18,2)  NOT NULL,       -- 판매(출고)단가
    WHOLE_PRICE   DECIMAL(18,2)  NULL,           -- 도매단가
    BASE_INPRICE  DECIMAL(18,2)  NULL,           -- 산정 시점 매입단가(마진 계산 기준 스냅샷)
    MARGIN_RT     DECIMAL(9,2)   NULL,           -- 마진율(%) = (SALE_PRICE-BASE_INPRICE)/SALE_PRICE*100 (선택 저장)
    PREV_PRICE    DECIMAL(18,2)  NULL,           -- 직전 판매단가
    REMARK        NVARCHAR(500)  NULL,
    ACTION_YN     NCHAR(1)       NOT NULL DEFAULT 'Y',
    REG_DTTM      NVARCHAR(19)   NULL,
    REG_USER      NVARCHAR(50)   NULL,
    REG_IP        NVARCHAR(50)   NULL,
    UPD_DTTM      NVARCHAR(19)   NULL,
    UPD_USER      NVARCHAR(50)   NULL,
    UPD_IP        NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_PROD_SALEPRICE_HST PRIMARY KEY (SALEPRICE_SEQ)
);
CREATE INDEX IX_SALEPRICE_PROD ON TBL_PROD_SALEPRICE_HST (PROD_SEQ, APPLY_DT);
CREATE INDEX IX_SALEPRICE_CD   ON TBL_PROD_SALEPRICE_HST (PROD_CD, APPLY_DT);


/* -------------------------------------------------------------------------------------
   3) 재고 관리 (원장) — TBL_STOCK_LEDGER (재고 수불원장)
      · 모든 입/출/조정/반품 이동을 1행씩 기록. 현재고 = 이 원장의 누계
      · 입고행 UNIT_PRICE=매입단가, 출고행 UNIT_PRICE=판매(출고)단가
      · 출고는 TBL_SHIPOUT_MST 연동 가능(REF_GB='SHIPOUT', REF_NO=출고일자/발주번호 등)
   ------------------------------------------------------------------------------------- */
CREATE TABLE TBL_STOCK_LEDGER (
    LEDGER_SEQ    INT IDENTITY(1,1) NOT NULL,   -- PK
    PROD_SEQ      INT            NOT NULL,       -- 품목마스터 PK
    PROD_CD       NVARCHAR(30)   NOT NULL,       -- 품목코드
    TRX_DT        NVARCHAR(8)    NOT NULL,       -- 거래일자 'YYYYMMDD'
    IO_GB         NCHAR(1)       NOT NULL,       -- 입출구분 'I'=입고/매입 'O'=출고/판매 'A'=조정 'R'=반품
    QTY           INT            NOT NULL,       -- 수량(항상 양수, 증감방향은 IO_GB로 판단)
    UNIT_PRICE    DECIMAL(18,2)  NULL,           -- 단가(입고=매입단가, 출고=출고단가)
    AMT           DECIMAL(18,2)  NULL,           -- 금액 = QTY * UNIT_PRICE
    BAL_QTY       INT            NULL,           -- 거래 후 잔량(스냅샷, 선택) — 성능/추적용
    VENDOR_CD     NVARCHAR(30)   NULL,           -- 매입처(입고 시)
    BIZ_CD        NVARCHAR(30)   NULL,           -- 사업장(출고 시)
    REF_GB        NVARCHAR(20)   NULL,           -- 근거구분 'SHIPOUT'/'INBOUND'/'ADJUST' 등
    REF_NO        NVARCHAR(50)   NULL,           -- 근거번호(출고일자/발주번호 등)
    REMARK        NVARCHAR(500)  NULL,
    ACTION_YN     NCHAR(1)       NOT NULL DEFAULT 'Y',
    REG_DTTM      NVARCHAR(19)   NULL,
    REG_USER      NVARCHAR(50)   NULL,
    REG_IP        NVARCHAR(50)   NULL,
    UPD_DTTM      NVARCHAR(19)   NULL,
    UPD_USER      NVARCHAR(50)   NULL,
    UPD_IP        NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_STOCK_LEDGER PRIMARY KEY (LEDGER_SEQ)
);
CREATE INDEX IX_STOCK_LEDGER_PROD ON TBL_STOCK_LEDGER (PROD_SEQ, TRX_DT);
CREATE INDEX IX_STOCK_LEDGER_CD   ON TBL_STOCK_LEDGER (PROD_CD, TRX_DT);
CREATE INDEX IX_STOCK_LEDGER_REF  ON TBL_STOCK_LEDGER (REF_GB, REF_NO);


/* -------------------------------------------------------------------------------------
   4) 재고 관리 (현황) — TBL_STOCK_MST (품목별 현재고 집계)
      · 품목당 1행(PROD_SEQ UNIQUE). 원장 이동 시 갱신하는 "빠른 조회용 현재고"
      · 이동평균 매입가(AVG_IN_PRICE) 보유 → 원가/재고평가에 활용
      · 마스터의 IN_PRICE/SALE_PRICE 는 '현재 단가', 여기 CUR_QTY 는 '현재 수량'
   ------------------------------------------------------------------------------------- */
CREATE TABLE TBL_STOCK_MST (
    STOCK_SEQ     INT IDENTITY(1,1) NOT NULL,   -- PK
    PROD_SEQ      INT            NOT NULL,       -- 품목마스터 PK (UNIQUE)
    PROD_CD       NVARCHAR(30)   NOT NULL,       -- 품목코드
    CUR_QTY       INT            NOT NULL DEFAULT 0,   -- 현재고 수량
    AVG_IN_PRICE  DECIMAL(18,2)  NULL,           -- 이동평균 매입단가
    LAST_INPRICE  DECIMAL(18,2)  NULL,           -- 최근 매입단가
    LAST_SALEPRICE DECIMAL(18,2) NULL,           -- 최근 판매단가
    STOCK_AMT     DECIMAL(18,2)  NULL,           -- 재고금액 = CUR_QTY * AVG_IN_PRICE
    LAST_IN_DT    NVARCHAR(8)    NULL,           -- 최근 입고일자
    LAST_OUT_DT   NVARCHAR(8)    NULL,           -- 최근 출고일자
    ACTION_YN     NCHAR(1)       NOT NULL DEFAULT 'Y',
    REG_DTTM      NVARCHAR(19)   NULL,
    REG_USER      NVARCHAR(50)   NULL,
    REG_IP        NVARCHAR(50)   NULL,
    UPD_DTTM      NVARCHAR(19)   NULL,
    UPD_USER      NVARCHAR(50)   NULL,
    UPD_IP        NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_STOCK_MST PRIMARY KEY (STOCK_SEQ),
    CONSTRAINT UQ_TBL_STOCK_MST_PROD UNIQUE (PROD_SEQ)
);
CREATE INDEX IX_STOCK_MST_CD ON TBL_STOCK_MST (PROD_CD);



-- 5) 마감 확정 헤더 (마감월별 1행)
CREATE TABLE TBL_CLOSING_MST (
    CLOSE_SEQ     INT IDENTITY(1,1) NOT NULL,
    CLOSE_YM      NVARCHAR(6)    NOT NULL,       -- 마감월 'YYYYMM'
    STATUS        NCHAR(1)       NOT NULL DEFAULT 'C',   -- 'C'=확정
    SALES_AMT     DECIMAL(18,2)  NULL,           -- 매출액(출고 기준)
    COGS_AMT      DECIMAL(18,2)  NULL,           -- 매출원가(출고 × 매입단가)
    MARGIN_AMT    DECIMAL(18,2)  NULL,           -- 순마진(매출 − 매출원가)
    PURCHASE_AMT  DECIMAL(18,2)  NULL,           -- 매입액(입고 수불 기준)
    STOCK_AMT     DECIMAL(18,2)  NULL,           -- 기말재고금액
    CONFIRM_DTTM  NVARCHAR(19)   NULL,
    CONFIRM_USER  NVARCHAR(50)   NULL,
    ACTION_YN     NCHAR(1)       NOT NULL DEFAULT 'Y',
    REG_DTTM      NVARCHAR(19)   NULL,
    REG_USER      NVARCHAR(50)   NULL,
    REG_IP        NVARCHAR(50)   NULL,
    UPD_DTTM      NVARCHAR(19)   NULL,
    UPD_USER      NVARCHAR(50)   NULL,
    UPD_IP        NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_CLOSING_MST PRIMARY KEY (CLOSE_SEQ),
    CONSTRAINT UQ_TBL_CLOSING_MST UNIQUE (CLOSE_YM)
);

-- 6) 마감 재고 스냅샷 (마감월 × 품목 기말재고 → 차월 기초 이월)
CREATE TABLE TBL_CLOSING_STOCK (
    CLOSE_STK_SEQ INT IDENTITY(1,1) NOT NULL,
    CLOSE_YM      NVARCHAR(6)    NOT NULL,       -- 마감월 'YYYYMM'
    PROD_SEQ      INT            NOT NULL,
    PROD_CD       NVARCHAR(30)   NOT NULL,
    END_QTY       INT            NULL,           -- 기말수량(→ 차월 기초)
    AVG_IN_PRICE  DECIMAL(18,2)  NULL,           -- 이동평균 매입단가
    STOCK_AMT     DECIMAL(18,2)  NULL,           -- 재고금액
    REG_DTTM      NVARCHAR(19)   NULL,
    REG_USER      NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_CLOSING_STOCK PRIMARY KEY (CLOSE_STK_SEQ)
);
CREATE INDEX IX_CLOSING_STOCK_YM ON TBL_CLOSING_STOCK (CLOSE_YM, PROD_CD);