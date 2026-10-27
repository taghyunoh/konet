/* 대상 발주 — 부가세 손으로 고치기 (2026-10-27 사용자 「부가세 수정도 가능하게」). 20261027_daesang_cols.sql 뒤에 한 번 실행. 재실행 안전.
   DS_VAT_AMT = 손으로 넣은 부가세(원). NULL = 자동(과세 10% · 영세·면세 0). 비우면 다시 자동. */
IF COL_LENGTH('TBL_SHIPOUT_MST', 'DS_VAT_AMT') IS NULL ALTER TABLE TBL_SHIPOUT_MST ADD DS_VAT_AMT DECIMAL(18,2) NULL;
GO
SELECT COL_LENGTH('TBL_SHIPOUT_MST', 'DS_VAT_AMT') AS DS_VAT_AMT_LEN;
