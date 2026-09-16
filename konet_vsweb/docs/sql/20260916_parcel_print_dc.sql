/* =====================================================================
   P3 두 건 (2026-09-16) — ① 택배 「출력됨」 서버 저장  ② 출고장(삼성 센터) 판정 상수 통합
     ① TBL_PARCEL_PRINT : 택배출고관리에서 엑셀(송장)에 담은 줄. 키 = 화면 병합키(출고일자 × 사업장 × 품목명)와 같다.
                          종전엔 브라우저(localStorage)에만 남아 PC 를 바꾸면 「출력됨」이 안 보였다 → 어느 PC 에서나 같이 본다(누가 언제).
     ② TBL_DC_MST       : 출고장(물류센터) 코드·지역명·묶음(오산센터)·거래처(삼성웰스토리 지점)·표시 차례 — 화면 JS(asset/js/dc-map.js)가 읽는 단일 원천.
                          ⚠매퍼 SQL 의 이름→코드 규칙은 <sql id="dcKeyOf"> 조각 한 곳(User_SQL.xml 머리) — 센터가 늘면 이 표 + 그 조각 두 곳.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전.
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_PARCEL_PRINT','U') IS NULL
CREATE TABLE dbo.TBL_PARCEL_PRINT (
  COMP_CD    VARCHAR(20)   NOT NULL,
  OUT_DT     CHAR(8)       NOT NULL,          -- 출고일자 YYYYMMDD (택배출고관리 조회 기준일)
  BIZ_CD     VARCHAR(40)   NOT NULL,          -- 사업장코드('' 허용 — 미등록 사업장)
  ITEM_NM    NVARCHAR(200) NOT NULL,          -- 품목명(발주현황표 표기 그대로 — 병합키)
  PRINT_DTTM VARCHAR(19)   NULL,
  PRINT_USER NVARCHAR(50)  NULL,
  CONSTRAINT PK_TBL_PARCEL_PRINT PRIMARY KEY (COMP_CD, OUT_DT, BIZ_CD, ITEM_NM)
);
GO
IF OBJECT_ID('dbo.TBL_DC_MST','U') IS NULL
CREATE TABLE dbo.TBL_DC_MST (
  COMP_CD   VARCHAR(20)  NOT NULL,
  DC_CD     VARCHAR(10)  NOT NULL,            -- E100~E700
  DC_NM     NVARCHAR(30) NOT NULL,            -- 지역명(용인·왜관…) — 화면 표기·이름→코드 환원 키워드
  GRP_NM    NVARCHAR(30) NULL,                -- 묶음(오산센터). 비면 단독
  VENDOR_CD VARCHAR(20)  NULL,                -- 삼성웰스토리 지점 거래처코드(정산서 → 채권·채무 연결)
  SORT_ORD  INT          NOT NULL CONSTRAINT DF_TBL_DC_MST_SORT DEFAULT 0,
  USE_YN    CHAR(1)      NOT NULL CONSTRAINT DF_TBL_DC_MST_USE  DEFAULT 'Y',
  REG_DTTM  VARCHAR(19)  NULL, REG_USER NVARCHAR(50) NULL, UPD_DTTM VARCHAR(19) NULL, UPD_USER NVARCHAR(50) NULL,
  CONSTRAINT PK_TBL_DC_MST PRIMARY KEY (COMP_CD, DC_CD)
);
GO
/* 씨앗 — 화면 상수(logi-oh.js KONET_DC · SS_DCGROUP/ZONEORDER · vendorMng DC_MAP)와 같은 값. 차례 = 용인·평택 단독, 오산센터 묶음(왜관·광주·김해·제주·오산) */
;WITH C AS ( SELECT DISTINCT COMP_CD FROM dbo.TBL_COMP_MST WHERE ISNULL(COMP_CD,'') <> '' UNION SELECT 'W1234567' ),
      S AS ( SELECT * FROM (VALUES
               ('E100', N'용인', NULL,        '00273', 10),
               ('E500', N'평택', NULL,        '00272', 20),
               ('E200', N'왜관', N'오산센터', '00275', 30),
               ('E400', N'광주', N'오산센터', '00276', 40),
               ('E300', N'김해', N'오산센터', '00274', 50),
               ('E600', N'제주', N'오산센터', '00277', 60),
               ('E700', N'오산', N'오산센터', '00278', 70)
             ) v (DC_CD, DC_NM, GRP_NM, VENDOR_CD, SORT_ORD) )
INSERT INTO dbo.TBL_DC_MST (COMP_CD, DC_CD, DC_NM, GRP_NM, VENDOR_CD, SORT_ORD, USE_YN, REG_DTTM, REG_USER)
SELECT C.COMP_CD, S.DC_CD, S.DC_NM, S.GRP_NM, S.VENDOR_CD, S.SORT_ORD, 'Y', CONVERT(VARCHAR(19),GETDATE(),120), 'seed'
  FROM C CROSS JOIN S
 WHERE NOT EXISTS (SELECT 1 FROM dbo.TBL_DC_MST t WHERE t.COMP_CD = C.COMP_CD AND t.DC_CD = S.DC_CD);
GO
SELECT COMP_CD, DC_CD, DC_NM, GRP_NM, VENDOR_CD, SORT_ORD FROM dbo.TBL_DC_MST ORDER BY COMP_CD, SORT_ORD;
SELECT COUNT(*) AS parcel_print_rows FROM dbo.TBL_PARCEL_PRINT;
