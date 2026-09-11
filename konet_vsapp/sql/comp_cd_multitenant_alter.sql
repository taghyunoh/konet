/* ============================================================================
   다중회사(멀티테넌트) 지원 — 업무 테이블 COMP_CD 컬럼 추가        (2026-07-30)

   · 로그인은 이미 COMP_CD + USER_ID (TBL_USER_MST) 인데, 업무 테이블에는
     COMP_CD 가 없어 회사별 데이터 구분이 안 되던 것을 보완한다.
   · 기존 데이터는 전부 코네트(W1234567) 것이므로 DEFAULT 'W1234567' WITH VALUES
     로 추가하면서 그대로 백필한다.
   · DEFAULT 제약은 지우지 않고 남긴다 — COMP_CD 를 안 넣는 구버전 코드가
     돌아도 W1234567 로 들어가 기존 회사 업무가 깨지지 않는 안전망.
   · 공통코드(TBL_CODE_MST/DTL)는 회사 공유 자산이라 제외.
   · TBL_COMP_MST / TBL_COMPCONT_MST / TBL_USER_MST 는 이미 COMP_CD 보유.

   [업무키 확장] 회사가 달라지면 같은 코드/번호가 공존해야 하므로
     - PK   : TBL_BIZI_MST(BIZ_CD) · TBL_VENDOR_MST(VENDOR_CD)
              · TBL_SETTLE_CLOSE_MST(SETTLE_GB,CLOSE_YM) 앞에 COMP_CD 포함
     - UNIQUE: CLOSING_MST(CLOSE_YM) · PAYMENT_MST(PAY_YM,BIZ_CD)
              · RECEIVE_MST(RCV_YM,BIZ_CD) · PURCHASE_MST(PURCH_DT,PURCH_NO)
              · SETTLE_TRX(TRX_GB,TRX_DT,TRX_NO) 앞에 COMP_CD 포함
     - IDENTITY(…_SEQ) PK 는 회사와 무관하게 유일하므로 그대로 둔다.
       (TBL_STOCK_MST UQ(PROD_SEQ) 도 PROD_SEQ 가 회사별로 다른 행이라 그대로)

   실행: SSMS 에서 전체 실행 (여러 번 실행해도 안전 — 전 구문 idempotent)
   ============================================================================ */

/* ---------- 1. COMP_CD 컬럼 추가 (19개 테이블, 기존행 W1234567 백필) ---------- */

IF COL_LENGTH('dbo.TBL_BIZI_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_BIZI_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_BIZI_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_CLOSING_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_CLOSING_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_CLOSING_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_CLOSING_STOCK','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_CLOSING_STOCK ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_CLOSING_STOCK_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_PAYMENT_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_PAYMENT_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_PAYMENT_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_PROD_INPRICE_HST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_PROD_INPRICE_HST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_PROD_INPRICE_HST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_PROD_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_PROD_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_PROD_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_PROD_SALEPRICE_HST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_PROD_SALEPRICE_HST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_PROD_SALEPRICE_HST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_PURCHASE_DTL','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_PURCHASE_DTL ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_PURCHASE_DTL_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_PURCHASE_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_PURCHASE_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_PURCHASE_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_RECEIVE_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_RECEIVE_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_RECEIVE_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_SALES_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_SALES_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_SALES_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_SALES_TRX_DTL','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_SALES_TRX_DTL ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_SALES_TRX_DTL_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_SALES_TRX_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_SALES_TRX_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_SALES_TRX_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_SETTLE_CLOSE_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_SETTLE_CLOSE_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_SETTLE_CLOSE_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_SETTLE_TRX','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_SETTLE_TRX ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_SETTLE_TRX_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_SHIPOUT_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_SHIPOUT_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_SHIPOUT_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_STOCK_LEDGER','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_STOCK_LEDGER ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_STOCK_LEDGER_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_STOCK_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_STOCK_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_STOCK_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO
IF COL_LENGTH('dbo.TBL_VENDOR_MST','COMP_CD') IS NULL
    ALTER TABLE dbo.TBL_VENDOR_MST ADD COMP_CD VARCHAR(10) NOT NULL
        CONSTRAINT DF_TBL_VENDOR_MST_COMP_CD DEFAULT 'W1234567' WITH VALUES;
GO

/* ---------- 2. 업무키(PK/UNIQUE) 에 COMP_CD 포함 ---------- */

/* TBL_BIZI_MST : PK(BIZ_CD) → PK(COMP_CD, BIZ_CD) */
IF NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_BIZI_MST') AND i.is_primary_key=1 AND c.name='COMP_CD')
BEGIN
    DECLARE @pk1 sysname = (SELECT name FROM sys.key_constraints
                             WHERE parent_object_id=OBJECT_ID('dbo.TBL_BIZI_MST') AND type='PK');
    EXEC('ALTER TABLE dbo.TBL_BIZI_MST DROP CONSTRAINT ['+@pk1+']');
    ALTER TABLE dbo.TBL_BIZI_MST ADD CONSTRAINT PK_TBL_BIZI_MST PRIMARY KEY CLUSTERED (COMP_CD, BIZ_CD);
END
GO

/* TBL_VENDOR_MST : PK(VENDOR_CD) → PK(COMP_CD, VENDOR_CD) */
IF NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_VENDOR_MST') AND i.is_primary_key=1 AND c.name='COMP_CD')
BEGIN
    DECLARE @pk2 sysname = (SELECT name FROM sys.key_constraints
                             WHERE parent_object_id=OBJECT_ID('dbo.TBL_VENDOR_MST') AND type='PK');
    EXEC('ALTER TABLE dbo.TBL_VENDOR_MST DROP CONSTRAINT ['+@pk2+']');
    ALTER TABLE dbo.TBL_VENDOR_MST ADD CONSTRAINT PK_TBL_VENDOR_MST PRIMARY KEY CLUSTERED (COMP_CD, VENDOR_CD);
END
GO

/* TBL_SETTLE_CLOSE_MST : PK(SETTLE_GB,CLOSE_YM) → PK(COMP_CD,SETTLE_GB,CLOSE_YM) */
IF NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_SETTLE_CLOSE_MST') AND i.is_primary_key=1 AND c.name='COMP_CD')
BEGIN
    DECLARE @pk3 sysname = (SELECT name FROM sys.key_constraints
                             WHERE parent_object_id=OBJECT_ID('dbo.TBL_SETTLE_CLOSE_MST') AND type='PK');
    EXEC('ALTER TABLE dbo.TBL_SETTLE_CLOSE_MST DROP CONSTRAINT ['+@pk3+']');
    ALTER TABLE dbo.TBL_SETTLE_CLOSE_MST ADD CONSTRAINT PK_TBL_SETTLE_CLOSE_MST PRIMARY KEY CLUSTERED (COMP_CD, SETTLE_GB, CLOSE_YM);
END
GO

/* TBL_CLOSING_MST : UQ(CLOSE_YM) → UQ(COMP_CD, CLOSE_YM) */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.TBL_CLOSING_MST') AND name='UQ_TBL_CLOSING_MST')
   AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_CLOSING_MST') AND i.name='UQ_TBL_CLOSING_MST' AND c.name='COMP_CD')
BEGIN
    ALTER TABLE dbo.TBL_CLOSING_MST DROP CONSTRAINT UQ_TBL_CLOSING_MST;
    ALTER TABLE dbo.TBL_CLOSING_MST ADD CONSTRAINT UQ_TBL_CLOSING_MST UNIQUE (COMP_CD, CLOSE_YM);
END
GO

/* TBL_PAYMENT_MST : UQ(PAY_YM,BIZ_CD) → UQ(COMP_CD,PAY_YM,BIZ_CD) */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.TBL_PAYMENT_MST') AND name='UQ_TBL_PAYMENT_MST')
   AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_PAYMENT_MST') AND i.name='UQ_TBL_PAYMENT_MST' AND c.name='COMP_CD')
BEGIN
    ALTER TABLE dbo.TBL_PAYMENT_MST DROP CONSTRAINT UQ_TBL_PAYMENT_MST;
    ALTER TABLE dbo.TBL_PAYMENT_MST ADD CONSTRAINT UQ_TBL_PAYMENT_MST UNIQUE (COMP_CD, PAY_YM, BIZ_CD);
END
GO

/* TBL_RECEIVE_MST : UQ(RCV_YM,BIZ_CD) → UQ(COMP_CD,RCV_YM,BIZ_CD) */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.TBL_RECEIVE_MST') AND name='UQ_TBL_RECEIVE_MST')
   AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_RECEIVE_MST') AND i.name='UQ_TBL_RECEIVE_MST' AND c.name='COMP_CD')
BEGIN
    ALTER TABLE dbo.TBL_RECEIVE_MST DROP CONSTRAINT UQ_TBL_RECEIVE_MST;
    ALTER TABLE dbo.TBL_RECEIVE_MST ADD CONSTRAINT UQ_TBL_RECEIVE_MST UNIQUE (COMP_CD, RCV_YM, BIZ_CD);
END
GO

/* TBL_PURCHASE_MST : UX(PURCH_DT,PURCH_NO) → UX(COMP_CD,PURCH_DT,PURCH_NO) */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.TBL_PURCHASE_MST') AND name='UX_PURCH_NO')
   AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_PURCHASE_MST') AND i.name='UX_PURCH_NO' AND c.name='COMP_CD')
BEGIN
    DROP INDEX UX_PURCH_NO ON dbo.TBL_PURCHASE_MST;
    CREATE UNIQUE NONCLUSTERED INDEX UX_PURCH_NO ON dbo.TBL_PURCHASE_MST (COMP_CD, PURCH_DT, PURCH_NO);
END
GO

/* TBL_SETTLE_TRX : UX(TRX_GB,TRX_DT,TRX_NO) → UX(COMP_CD,TRX_GB,TRX_DT,TRX_NO) */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.TBL_SETTLE_TRX') AND name='UX_SETTLE_TRX_NO')
   AND NOT EXISTS (SELECT 1 FROM sys.index_columns ic
                JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id
                JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
               WHERE i.object_id=OBJECT_ID('dbo.TBL_SETTLE_TRX') AND i.name='UX_SETTLE_TRX_NO' AND c.name='COMP_CD')
BEGIN
    DROP INDEX UX_SETTLE_TRX_NO ON dbo.TBL_SETTLE_TRX;
    CREATE UNIQUE NONCLUSTERED INDEX UX_SETTLE_TRX_NO ON dbo.TBL_SETTLE_TRX (COMP_CD, TRX_GB, TRX_DT, TRX_NO);
END
GO

/* ---------- 3. 확인 ---------- */
SELECT t.name AS tbl,
       CASE WHEN c.name IS NULL THEN 'X' ELSE 'O' END AS comp_cd
  FROM sys.tables t
  LEFT JOIN sys.columns c ON c.object_id=t.object_id AND c.name='COMP_CD'
 WHERE t.name LIKE 'TBL_%'
 ORDER BY t.name;
GO

/* ============================================================================
   되돌리기 (참고 — 각 테이블별)
   ALTER TABLE dbo.TBL_X DROP CONSTRAINT DF_TBL_X_COMP_CD;
   ALTER TABLE dbo.TBL_X DROP COLUMN COMP_CD;
   (PK/UNIQUE 를 되돌릴 땐 위 2절의 원래 컬럼 구성으로 재생성)
   ============================================================================ */
