/* =====================================================================================
   TBL_PROD_SALEPRICE_HST 에 판매처 컬럼 추가 (MSSQL)  — 2026-07-18
   · 배경: 판매는 삼성웰스토리 출고장 외에 별도 판매처(TBL_VENDOR_MST 매출 거래처)로도 나간다.
     판매처마다 단가가 다를 수 있어 판매가 이력에 '누구에게 파는 가격인지' 차원을 추가한다.
   · 규칙:
       VENDOR_CD IS NULL  = 공통(기본) 판매가 — 기존 이력 전부 여기 해당. 매출 엑셀 업로드 확정가도 공통으로 적재.
       VENDOR_CD 있음     = 그 판매처 전용 판매가 (화면 '판매가' 탭에서 판매처 선택 등록)
   · ★매출마감(selectClosing)은 물류센터(삼성웰스토리) 출고 집계이므로 '공통가(VENDOR_CD IS NULL)'만 집는다.
     판매처 전용가는 마감 단가에 영향 없음 (User_SQL.xml 조회에 h.VENDOR_CD IS NULL 가드 추가됨).
   · ★판매처 전용가는 TBL_PROD_MST.SALE_PRICE(기본가) 를 동기화하지 않는다 (UserServiceImpl.insertSaleprice 분기).
   · 각 구문 IF 가드로 재실행 안전.
   ===================================================================================== */
USE [KOLGSDB]
GO

IF COL_LENGTH('dbo.TBL_PROD_SALEPRICE_HST','VENDOR_CD') IS NULL
    ALTER TABLE dbo.TBL_PROD_SALEPRICE_HST ADD VENDOR_CD NVARCHAR(20)  NULL;   -- 판매처코드(TBL_VENDOR_MST) · NULL=공통가
GO
IF COL_LENGTH('dbo.TBL_PROD_SALEPRICE_HST','VENDOR_NM') IS NULL
    ALTER TABLE dbo.TBL_PROD_SALEPRICE_HST ADD VENDOR_NM NVARCHAR(100) NULL;   -- 판매처명(가독/조회용 스냅샷)
GO

/* 판매처별 단가 소급조회용 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SALEPRICE_VENDOR' AND object_id=OBJECT_ID('dbo.TBL_PROD_SALEPRICE_HST'))
    CREATE INDEX IX_SALEPRICE_VENDOR ON dbo.TBL_PROD_SALEPRICE_HST (VENDOR_CD, PROD_CD, APPLY_DT);
GO
