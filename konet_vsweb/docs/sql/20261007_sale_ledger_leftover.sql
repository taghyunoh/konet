/* =====================================================================
   판매전표 «날짜를 고쳐 다시 저장»할 때 남은 옛 출고 기록 정리 (2026-10-07)
   — 사용자 「혹시 판매등록도 그런 경우는 확인해줘」 (같은 날 매입전표 정리 20261007_purch_ledger_leftover.sql 의 짝)

   무슨 일이었나 : 판매등록을 저장하면 재고 원장에 출고 줄(REF_GB='SALE', 번호 = 전표일자-전표번호)이 생긴다.
     고쳐 다시 저장할 때 옛 줄을 «화면이 보낸 새 일자»로 찾아 지워서, 날짜를 바꿔 저장하면 옛 날짜의 출고 줄이 남았다 — 같은 출고가 두 번 빠졌다.
     프로그램은 고쳤다(매퍼 deleteSalesTrxLedger — 저장돼 있는 전표의 일자·번호로 찾는다). 이 스크립트는 이미 남은 줄을 닫는다.

   남은 줄 (2026-10-07 운영 DB 읽기 전용 조회 — 2건 11줄) :
     20260911-0001  9904012626 출고 60          (전표 12 대상주식회사 → 지금 20260929-0001, 149 개 출고로 다시 잡혀 있음)
     20260928-0002  10품목 출고 14             (전표 23 퐁퐁플라워 광주 빛고을센터 → 지금 20261001-0002 에 같은 10품목이 그대로 있음)

   하는 일 : 위 줄을 ACTION_YN='N'(논리삭제)로 바꾼다. 되돌리려면 'Y' 로. 조건 두 겹 — ①위 2개 번호 ②그 번호의 살아 있는 판매전표가 «없을» 때만.
   실행 뒤 : 재고 화면은 원장을 바로 읽는다 — 품목별재고현황 [새로고침].
   ===================================================================== */

-- 0) 미리 보기 — 닫을 줄 (11줄이 나와야 한다)
SELECT l.LEDGER_SEQ, l.REF_NO, l.TRX_DT, l.PROD_CD, l.IO_GB, l.QTY, l.AMT, CONVERT(varchar(19), l.REG_DTTM, 120) AS reg, l.REG_USER
  FROM TBL_STOCK_LEDGER l
 WHERE l.ACTION_YN = 'Y' AND l.REF_GB = 'SALE' AND l.COMP_CD = 'W1234567'
   AND l.REF_NO IN ('20260911-0001','20260928-0002')
   AND NOT EXISTS ( SELECT 1 FROM TBL_SALES_TRX_MST m
                     WHERE m.COMP_CD = l.COMP_CD AND m.ACTION_YN = 'Y'
                       AND REPLACE(ISNULL(m.SALE_DT,''),'-','') + '-' + m.SALE_NO = l.REF_NO )
 ORDER BY l.REF_NO, l.LEDGER_SEQ;
GO

-- 1) 닫기
UPDATE l
   SET l.ACTION_YN = 'N',
       l.UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), l.UPD_USER = N'leftover-fix', l.UPD_IP = '127.0.0.1',
       l.REMARK = LEFT(ISNULL(l.REMARK,'') + N' · 2026-10-07 정리: 날짜 고쳐 다시 저장한 판매전표의 옛 줄', 500)
  FROM TBL_STOCK_LEDGER l
 WHERE l.ACTION_YN = 'Y' AND l.REF_GB = 'SALE' AND l.COMP_CD = 'W1234567'
   AND l.REF_NO IN ('20260911-0001','20260928-0002')
   AND NOT EXISTS ( SELECT 1 FROM TBL_SALES_TRX_MST m
                     WHERE m.COMP_CD = l.COMP_CD AND m.ACTION_YN = 'Y'
                       AND REPLACE(ISNULL(m.SALE_DT,''),'-','') + '-' + m.SALE_NO = l.REF_NO );
GO

-- 2) 확인 — 살아 있는 판매전표와 짝이 없는 출고 줄이 0줄이어야 한다
SELECT COUNT(*) AS leftover
  FROM TBL_STOCK_LEDGER l
 WHERE l.ACTION_YN = 'Y' AND l.REF_GB = 'SALE' AND l.COMP_CD = 'W1234567'
   AND NOT EXISTS ( SELECT 1 FROM TBL_SALES_TRX_MST m
                     WHERE m.COMP_CD = l.COMP_CD AND m.ACTION_YN = 'Y'
                       AND REPLACE(ISNULL(m.SALE_DT,''),'-','') + '-' + m.SALE_NO = l.REF_NO );
