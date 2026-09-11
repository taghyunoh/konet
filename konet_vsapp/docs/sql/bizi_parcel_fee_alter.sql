-- TBL_BIZI_MST.PARCEL_FEE 신설 (2026-08-06) — 사업장별 기본 택배운임(원).
--   택배출고관리 엑셀의 운임 칸: PARCEL_FEE 우선, 없으면 4500. 사업장관리 화면에서 입력.
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.TBL_BIZI_MST') AND name='PARCEL_FEE')
BEGIN
    ALTER TABLE dbo.TBL_BIZI_MST ADD PARCEL_FEE INT NULL;
END
GO
