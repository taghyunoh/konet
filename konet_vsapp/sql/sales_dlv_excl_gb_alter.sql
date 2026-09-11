/* ============================================================================
   납품분 제외표를 매출·매입 공용으로 — TBL_SALES_DLV_EXCL 에 GB 추가   2026-07-31
   ----------------------------------------------------------------------------
   판매등록의 [납품분] 과 매입등록의 [매입분] 이 같은 구조라 표를 하나로 쓴다.
     GB = 'S' 판매(납품분)  /  'P' 매입(매입분)
   거래처마스터(TBL_VENDOR_MST)는 매출처·매입처가 한 표라 코드가 겹칠 수 있다.
   GB 없이 CUST_CD+PROD_CD 로만 잡으면 '매출에서 뺀 품목이 매입에서도 사라지는'
   사고가 난다 — 그래서 유니크 키에 GB 를 넣는다.

   ※ sql/sales_dlv_excl_ddl.sql 을 이미 돌린 뒤에 이 파일을 돌린다.
     기존 줄은 전부 판매(S)로 채워진다.
   ============================================================================ */
USE [KOLGSDB]
GO

IF COL_LENGTH('dbo.TBL_SALES_DLV_EXCL','GB') IS NULL
    ALTER TABLE dbo.TBL_SALES_DLV_EXCL
      ADD GB CHAR(1) NOT NULL CONSTRAINT DF_SALES_DLV_EXCL_GB DEFAULT('S');
GO

/* 유니크 키를 (회사+구분+거래처+상품) 으로 다시 건다 */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_SALES_DLV_EXCL' AND object_id=OBJECT_ID('dbo.TBL_SALES_DLV_EXCL'))
    DROP INDEX UX_SALES_DLV_EXCL ON dbo.TBL_SALES_DLV_EXCL;
GO
CREATE UNIQUE INDEX UX_SALES_DLV_EXCL ON dbo.TBL_SALES_DLV_EXCL (COMP_CD, GB, CUST_CD, PROD_CD);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALES_DLV_EXCL_CUST' AND object_id=OBJECT_ID('dbo.TBL_SALES_DLV_EXCL'))
    DROP INDEX IX_SALES_DLV_EXCL_CUST ON dbo.TBL_SALES_DLV_EXCL;
GO
CREATE INDEX IX_SALES_DLV_EXCL_CUST ON dbo.TBL_SALES_DLV_EXCL (COMP_CD, GB, CUST_CD, ACTION_YN);
GO
