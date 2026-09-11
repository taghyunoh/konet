/* =====================================================================================
   거래처 마스터 — TBL_VENDOR_MST (MSSQL)
   · 원천: 회계/영업 시스템이 뽑아주는 `거래처리스트.xls` (확장자만 xls, 실제는 HTML 표 40컬럼)
   · 초기적재: sql/vendor_mst_insert.sql (477행 → 코드기준 432종 병합)

   ★ TBL_BIZI_MST 와 합치지 않고 별도로 두는 이유 (실측 근거)
     · 코드체계가 다르다 : BIZI = 'A0386956'(발주현황표 사업장코드) / 거래처 = '0089','2-57'(회계 거래처코드)
     · 코드 교집합 0건, 이름 교집합도 0/155 (괄호·공백·'주식회사' 제거 정규화 후 대조)
     · 즉 같은 대상을 다르게 부르는 게 아니라 애초에 다른 모집단이다.
         TBL_BIZI_MST  = 물류센터가 배송해 주는 '사업장(점포)'  — 런던베이글 잠실점, (신)푸드박스 …
         TBL_VENDOR_MST= 코네트의 회계상 '거래처(매입처/매출처)' — (주)대양상사, 삼성웰스토리 …
     · 합치면 이을 수 없는 두 코드체계가 한 테이블에 섞이고 BIZ_CD PK 도 깨진다.

   ★ 원본 코드는 PK 가 못 된다 → 코드기준 병합 후 PK
     · 원본 477행 중 45종이 중복. 정체는 '같은 거래처가 거래유형/담당자별로 여러 줄' 인 비정규화.
         예) 00398 (주)카레타 → 매출 1줄 + 매입 1줄 / 3-2 아방뮤제(판교현대점) → 담당 남대성·김동근 2줄
     · 그래서 코드기준 1행으로 병합하고 거래유형은 합집합('매입&매출')으로 통합 → 432종
     · 담당자는 대표 1명만 남는다. 담당자를 복수로 관리해야 하면 별도 테이블(TBL_VENDOR_MGR)로 분리할 것.

   ★ 일부러 안 넣은 컬럼
     · 주민번호  : 개인정보. 원본 477행 중 값 1건뿐이라 실익도 없음.
     · 방문일    : 전부 공백(0%)
     · 장비      : 전부 'N'
     · 현잔고/여신/발행율/최종매출일/최종수금일/마감일자/수금일자
                 : 회계 시스템이 원본. 여기 복사하면 업로드 시점에 박제돼 금방 낡는다.

   ★ DC_CD — 물류센터 ↔ 거래처 연결 (이번에 밝혀진 것)
     · 발주현황표의 출고장(물류센터) 7곳이 전부 '삼성웰스토리 지점' 거래처와 1:1 대응한다.
         E100 용인=00273 / E200 왜관=00275 / E300 김해=00274 / E400 광주=00276
         E500 평택=00272 / E600 제주=00277 / E700 오산=00278
     · 매출 엑셀(TBL_SALES_MST.DC_NM='평택')과 발주현황표(DC_CD='E500')를 잇는 다리 역할.
   ===================================================================================== */
USE [KOLGSDB]
GO

IF OBJECT_ID('dbo.TBL_VENDOR_MST','U') IS NULL
CREATE TABLE dbo.TBL_VENDOR_MST (
    VENDOR_CD   NVARCHAR(20)   NOT NULL,       -- 거래처코드 (원본 '코드'. PK)
    VENDOR_NM   NVARCHAR(100)  NULL,           -- 거래처명
    FULL_NM     NVARCHAR(100)  NULL,           -- 정식명칭
    ALIAS       NVARCHAR(100)  NULL,           -- 별칭
    CEO_NM      NVARCHAR(50)   NULL,           -- 대표자명
    VENDOR_GB   NVARCHAR(10)   NULL,           -- 거래유형 '매입' / '매출' / '매입&매출'  ★매입가 등록의 매입처 후보 = 매입 포함분
    BIZ_COND    NVARCHAR(100)  NULL,           -- 업태
    BIZ_ITEM    NVARCHAR(200)  NULL,           -- 종목
    MGR_CD      NVARCHAR(10)   NULL,           -- 담당자코드
    MGR_NM      NVARCHAR(50)   NULL,           -- 담당자명 (병합 시 대표 1명)
    TYPE_CD     NVARCHAR(10)   NULL,           -- 유형코드
    TYPE_NM     NVARCHAR(100)  NULL,           -- 유형명
    AREA_CD     NVARCHAR(10)   NULL,           -- 지역코드
    AREA_NM     NVARCHAR(50)   NULL,           -- 지역명
    ZIPCD       NVARCHAR(10)   NULL,           -- 우편번호
    ADDR        NVARCHAR(200)  NULL,           -- 주소
    ADDR2       NVARCHAR(200)  NULL,           -- 상세주소
    EMAIL       NVARCHAR(100)  NULL,           -- 이메일
    HP          NVARCHAR(30)   NULL,           -- 연락처(휴대폰)
    TEL         NVARCHAR(30)   NULL,           -- 전화
    FAX         NVARCHAR(30)   NULL,           -- 팩스
    BIZNO       NVARCHAR(20)   NULL,           -- 사업자등록번호
    BANK_ACCT   NVARCHAR(200)  NULL,           -- 계좌
    TAXBILL_GB  NVARCHAR(10)   NULL,           -- 계산서발행 '발행'/'미발행'
    VAT_GB      NVARCHAR(10)   NULL,           -- 부가세 '포함'/'별도'
    REG_DT      NVARCHAR(8)    NULL,           -- 원본 등록일 'YYYYMMDD'
    DC_CD       NVARCHAR(20)   NULL,           -- ★물류센터코드 (발주현황표 TBL_SHIPOUT_MST.DC_CD 와 연결. 삼성웰스토리 지점 7곳만)
    SORT_ORD    INT            NULL,           -- 정렬순서
    REMARK      NVARCHAR(500)  NULL,           -- 비고(원본 비고1~3 합침)
    ACTION_YN   NCHAR(1)       NOT NULL DEFAULT 'Y',   -- 'Y'=사용 / 'N'=미사용(소프트삭제)
    REG_DTTM    NVARCHAR(19)   NULL,
    REG_USER    NVARCHAR(50)   NULL,
    REG_IP      NVARCHAR(50)   NULL,
    UPD_DTTM    NVARCHAR(19)   NULL,
    UPD_USER    NVARCHAR(50)   NULL,
    UPD_IP      NVARCHAR(50)   NULL,
    CONSTRAINT PK_TBL_VENDOR_MST PRIMARY KEY (VENDOR_CD)
);
GO

/* 거래처명 검색 (매입처 선택 팝업/자동완성) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VENDOR_NM' AND object_id=OBJECT_ID('dbo.TBL_VENDOR_MST'))
    CREATE INDEX IX_VENDOR_NM ON dbo.TBL_VENDOR_MST (VENDOR_NM);
GO

/* 거래유형별 조회 (매입처 후보 = VENDOR_GB LIKE '%매입%') */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VENDOR_GB' AND object_id=OBJECT_ID('dbo.TBL_VENDOR_MST'))
    CREATE INDEX IX_VENDOR_GB ON dbo.TBL_VENDOR_MST (VENDOR_GB, ACTION_YN);
GO

/* 물류센터 ↔ 거래처 역참조 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VENDOR_DC' AND object_id=OBJECT_ID('dbo.TBL_VENDOR_MST'))
    CREATE INDEX IX_VENDOR_DC ON dbo.TBL_VENDOR_MST (DC_CD);
GO
