/* ★수정재고 고정 (2026-11-25) — 재고조정으로 맞춘 재고를 «기준점»으로 굳히는 칸 셋. 재실행 안전.
   ⚠새 WAR 보다 «먼저» 실행 — 현재고 재집계(recalcStockMst · recalcStockMstAll)가 이 칸을 읽는다. 칸이 없으면 전표 저장·업로드·재집계가 실패한다.

   FRZ_QTY  : 고정값 = (조정을 저장한 순간의 그 품목·창고 원장 합) − (조정한 날짜부터의 다른 줄 합). NULL = 이 기능 전에 한 조정(종전 동작 그대로).
   FIX_QTY  : 저장 뒤 프로그램이 이 조정 줄의 증감에 더한 보정량 누계(조정한 날짜보다 앞 날짜의 기록이 바뀌어 현재고를 지키려고 고친 양).
              처음 저장한 증감 = DIFF_QTY − FIX_QTY · 처음 화면에 보였던 「전」 = BEF_QTY + FIX_QTY.
   FIX_DTTM : 마지막으로 보정한 때.

   실행해도 지금 재고는 하나도 안 바뀐다. 이 뒤에 «새로 저장하는» 재고조정부터 고정된다(그 전 조정은 다시 조정하면 그때부터). */
IF COL_LENGTH('TBL_STOCK_ADJ_HIS', 'FRZ_QTY') IS NULL
    ALTER TABLE TBL_STOCK_ADJ_HIS ADD FRZ_QTY DECIMAL(18,3) NULL;
GO
IF COL_LENGTH('TBL_STOCK_ADJ_HIS', 'FIX_QTY') IS NULL
    ALTER TABLE TBL_STOCK_ADJ_HIS ADD FIX_QTY INT NULL;
GO
IF COL_LENGTH('TBL_STOCK_ADJ_HIS', 'FIX_DTTM') IS NULL
    ALTER TABLE TBL_STOCK_ADJ_HIS ADD FIX_DTTM NVARCHAR(19) NULL;
GO

/* 확인 — 세 줄이 나오면 끝 */
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TBL_STOCK_ADJ_HIS' AND COLUMN_NAME IN ('FRZ_QTY','FIX_QTY','FIX_DTTM');
