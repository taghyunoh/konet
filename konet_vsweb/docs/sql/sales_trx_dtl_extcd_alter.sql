-- =====================================================================
-- TBL_SALES_TRX_DTL.EXT_CD 신설 (2026-08-06)
--   매칭코드로 판매한 줄의 '거래처 매칭코드'를 전표에 기록한다.
--   · 원코드 판매 줄 / 이 칼럼 추가 이전의 옛 전표 = NULL (매칭 표시 안 붙음 — 정확)
--   · 화면: 판매등록 명세 그리드·일괄등록(담을 내용/최근 판매내역)이 이 값으로
--     "주코드 위 + 🔖 매칭코드 아래" 표기를 한다. 종전의 품명 추정 방식은 폐기.
--   ★실행 순서: ① 이 스크립트를 운영DB(KOLGSDB)에 실행 → ② konet_vsweb `mvn compile`
--     (DTO·매퍼가 EXT_CD 를 쓰므로, 칼럼 없이 컴파일만 먼저 하면 판매 저장이 실패한다)
-- =====================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns
                WHERE object_id = OBJECT_ID('dbo.TBL_SALES_TRX_DTL') AND name = 'EXT_CD')
BEGIN
    ALTER TABLE dbo.TBL_SALES_TRX_DTL ADD EXT_CD NVARCHAR(50) NULL;
END
GO
