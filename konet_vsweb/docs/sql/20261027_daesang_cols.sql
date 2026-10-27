/* =====================================================================
   대상 발주 등록 — 판매등록 그리드와 같은 칸 (2026-10-27 사용자 「이 내용(단가·금액·DC·공급가·부가세·판매금액·서비스·비고·영세·거래구분) 동일하게」)
   ⛔새 화면을 쓰기 <전에> 운영DB 에서 한 번 실행. 재실행 안전. 대상 줄만 쓴다(다른 줄은 NULL).

     DS_DC_AMT   DC(할인액, 원)      — 공급가 = 수량 × 단가 − DC. 매출에서 뺀다.
     DS_SVC_QTY  서비스 수량(무상)   — 재고에서는 빠지고 매출에는 안 들어간다.
     DS_ZERO_YN  영세 'Y'            — 부가세 0 (화면 표시용. 매출 조회는 공급가 기준이라 영향 없음).
     DS_TRX_GB   거래구분 '판매'/'반품' — 반품은 매출이 음수, 재고는 입고(R)로 되돌아온다.
     DS_MEMO     비고(사용자 글)     — REMARK 는 프로그램이 적는 수정·복구 기록이라 따로 둔다.
   ===================================================================== */
IF COL_LENGTH('TBL_SHIPOUT_MST', 'DS_DC_AMT') IS NULL  ALTER TABLE TBL_SHIPOUT_MST ADD DS_DC_AMT DECIMAL(18,2) NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'DS_SVC_QTY') IS NULL ALTER TABLE TBL_SHIPOUT_MST ADD DS_SVC_QTY INT NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'DS_ZERO_YN') IS NULL ALTER TABLE TBL_SHIPOUT_MST ADD DS_ZERO_YN CHAR(1) NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'DS_TRX_GB') IS NULL  ALTER TABLE TBL_SHIPOUT_MST ADD DS_TRX_GB NVARCHAR(10) NULL;
GO
IF COL_LENGTH('TBL_SHIPOUT_MST', 'DS_MEMO') IS NULL    ALTER TABLE TBL_SHIPOUT_MST ADD DS_MEMO NVARCHAR(200) NULL;
GO
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='TBL_SHIPOUT_MST' AND COLUMN_NAME LIKE 'DS[_]%' ORDER BY COLUMN_NAME;
