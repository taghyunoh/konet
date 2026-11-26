/* =====================================================================
   사진함 (2026-11-26 사용자 「모바일에서 찍은 사진을 한꺼번에 PC 에서 보는 방법」 → 「날짜별 모음 · 줄인 사진만 · 1년 보관」 → 같은 날 「보관 1개월로」)
     · 모바일 앱(konetapp ▸ 📷 사진)에서 여러 장을 한 번에 올리면 «묶음» 하나(그날 날짜 + 한 줄 이름)가 생긴다.
     · 사진은 폰에서 줄여서(긴 변 1600px JPEG · 장당 약 0.2~0.5MB) 보낸다 — 원본은 저장하지 않는다. 목록용 작은 그림(THUMB, 긴 변 360px)도 함께.
     · PC(konet_vsweb ▸ 🖼 사진함)는 날짜별로 묶음·사진을 격자로 보고, 크게 보기 · 여러 장 ZIP 내려받기 · 지우기.
     · ★1개월 보관 — 묶음 날짜(GRP_DT)가 한 달 지난 것은 앱이 하루 한 번 «완전히» 지운다(용량을 비우려는 것이라 소프트 삭제가 아니다).
     · 두 앱(web·app)은 WAR 가 따로라 디스크 폴더를 함께 못 쓴다 → 같은 DB 에 그림을 넣는다(VARBINARY(MAX)).
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접 한 번. 두 번 실행해도 안전(IF … IS NULL).
   용량 어림 : 하루 50장 × 0.35MB ≈ 18MB/일 · 한 달 ≈ 0.5GB(한 달 지나면 지워지므로 그 근처에서 멈춘다).
   ===================================================================== */
IF OBJECT_ID('dbo.TBL_PHOTO_GRP','U') IS NULL
CREATE TABLE dbo.TBL_PHOTO_GRP (
  GRP_SEQ   BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_PHOTO_GRP PRIMARY KEY,
  COMP_CD   VARCHAR(20)   NOT NULL,
  GRP_DT    CHAR(8)       NOT NULL,                                                  -- 묶음 날짜 'YYYYMMDD' (올린 날)
  TITLE     NVARCHAR(100) NULL,                                                      -- 한 줄 이름(예: 선피앤피 입고 검수)
  PHOTO_CNT INT           NOT NULL CONSTRAINT DF_TBL_PHOTO_GRP_CNT DEFAULT 0,
  REG_DTTM  VARCHAR(19)   NULL, REG_USER NVARCHAR(50) NULL, REG_NM NVARCHAR(50) NULL, REG_IP VARCHAR(50) NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_PHOTO_GRP_DT' AND object_id = OBJECT_ID('dbo.TBL_PHOTO_GRP'))
CREATE INDEX IX_TBL_PHOTO_GRP_DT ON dbo.TBL_PHOTO_GRP (COMP_CD, GRP_DT);
GO
IF OBJECT_ID('dbo.TBL_PHOTO','U') IS NULL
CREATE TABLE dbo.TBL_PHOTO (
  PHOTO_SEQ BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TBL_PHOTO PRIMARY KEY,
  GRP_SEQ   BIGINT         NOT NULL,
  COMP_CD   VARCHAR(20)    NOT NULL,
  SORT_NO   INT            NOT NULL CONSTRAINT DF_TBL_PHOTO_SORT DEFAULT 0,
  FILE_NM   NVARCHAR(200)  NULL,                                                     -- 폰의 원래 파일 이름(참고)
  SHOT_DTTM VARCHAR(19)    NULL,                                                     -- 찍은(파일) 시각 'YYYY-MM-DD HH:MM:SS' — 폰이 알려 줄 때만
  IMG_W     INT            NULL, IMG_H INT NULL, IMG_BYTES INT NULL,
  IMG       VARBINARY(MAX) NOT NULL,                                                 -- 줄인 사진(JPEG)
  THUMB     VARBINARY(MAX) NULL,                                                     -- 목록용 작은 그림(JPEG)
  REG_DTTM  VARCHAR(19)    NULL, REG_USER NVARCHAR(50) NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_PHOTO_GRP' AND object_id = OBJECT_ID('dbo.TBL_PHOTO'))
CREATE INDEX IX_TBL_PHOTO_GRP ON dbo.TBL_PHOTO (GRP_SEQ, SORT_NO);
GO
/* 확인 */
SELECT OBJECT_ID('dbo.TBL_PHOTO_GRP','U') AS GRP_TBL, OBJECT_ID('dbo.TBL_PHOTO','U') AS PHOTO_TBL;
