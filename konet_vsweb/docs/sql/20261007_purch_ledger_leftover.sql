/* =====================================================================
   매입전표 «날짜를 고쳐 다시 저장»할 때 남은 옛 재고 기록 정리 (2026-10-07)
   — 사용자 「7월 1일 매입자료가 없는데 확인해줘」 (품목별재고현황 · 1000810680 (마라인더컵)32온스 컵 홀더)

   무슨 일이었나 :
     매입전표를 저장하면 재고 원장(TBL_STOCK_LEDGER)에 입고 줄이 생긴다. 번호(REF_NO) = 전표일자-전표번호.
     전표를 고쳐 다시 저장할 때 옛 줄을 지우는데, 종전엔 «화면이 보낸 새 일자»로 찾았다.
     그래서 날짜를 바꿔 다시 저장하면 옛 날짜의 줄이 그대로 남고 새 날짜의 줄이 또 들어가 — 같은 입고가 두 번 잡혔다.
     (예 : 전표 460 을 9/29 16:14:07 에 7/1 로 저장 → 31초 뒤 9/29 로 고쳐 저장 → 7/1-0006 줄 50개가 남음)
     프로그램은 고쳤다(매퍼 deletePurchaseLedger — 저장돼 있는 전표의 일자·번호로 찾는다). 이 스크립트는 이미 남은 줄을 닫는다.

   남은 줄 (2026-10-07 운영 DB 읽기 전용 조회 — 5건 10줄, 모두 지금 살아 있는 전표가 같은 품목을 새 날짜로 갖고 있다) :
     20260407-0002  9904013190 30 · 9904013191 30      (09-05 14:27 저장 — 그날 오후 날짜를 고친 0002 전표)
     20260701-0006  1000810680 50 · 4002041105 1       (전표 460 → 지금 20260929-0006)
     20260916-0004  9904013190 24 · 9904013191 24      (전표 429 → 지금 20260917-0004)
     20260927-0001  1000758525 31 · 1000794701 6       (전표 456 → 지금 20260924-0001)
     20261004-0002  9904013332 20 · 9904013344 10      (전표 471 → 지금 20261006-0002)

   하는 일 : 위 줄을 ACTION_YN='N'(논리삭제)로 바꾼다. 지우지 않는다 — 되돌리려면 'Y' 로 바꾸면 된다.
   ★조건이 두 겹이다 — ①위 5개 번호 ②그 번호의 살아 있는 매입전표가 «없을» 때만. 그 사이에 같은 번호로 새 전표가 저장됐으면 건드리지 않는다.
   실행 뒤 : 재고 화면은 원장을 바로 읽으므로 따로 할 일은 없다. 품목별재고현황에서 [새로고침].
   ===================================================================== */

-- 0) 미리 보기 — 닫을 줄 (10줄이 나와야 한다)
SELECT l.LEDGER_SEQ, l.REF_NO, l.TRX_DT, l.PROD_CD, l.QTY, l.AMT, CONVERT(varchar(19), l.REG_DTTM, 120) AS reg, l.REG_USER
  FROM TBL_STOCK_LEDGER l
 WHERE l.ACTION_YN = 'Y' AND l.REF_GB = 'PURCH' AND l.COMP_CD = 'W1234567'
   AND l.REF_NO IN ('20260407-0002','20260701-0006','20260916-0004','20260927-0001','20261004-0002')
   AND NOT EXISTS ( SELECT 1 FROM TBL_PURCHASE_MST m
                     WHERE m.COMP_CD = l.COMP_CD AND m.ACTION_YN = 'Y'
                       AND REPLACE(ISNULL(m.PURCH_DT,''),'-','') + '-' + m.PURCH_NO = l.REF_NO )
 ORDER BY l.REF_NO, l.LEDGER_SEQ;
GO

-- 1) 닫기
UPDATE l
   SET l.ACTION_YN = 'N',
       l.UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), l.UPD_USER = N'leftover-fix', l.UPD_IP = '127.0.0.1',
       l.REMARK = LEFT(ISNULL(l.REMARK,'') + N' · 2026-10-07 정리: 날짜 고쳐 다시 저장한 매입전표의 옛 줄', 500)
  FROM TBL_STOCK_LEDGER l
 WHERE l.ACTION_YN = 'Y' AND l.REF_GB = 'PURCH' AND l.COMP_CD = 'W1234567'
   AND l.REF_NO IN ('20260407-0002','20260701-0006','20260916-0004','20260927-0001','20261004-0002')
   AND NOT EXISTS ( SELECT 1 FROM TBL_PURCHASE_MST m
                     WHERE m.COMP_CD = l.COMP_CD AND m.ACTION_YN = 'Y'
                       AND REPLACE(ISNULL(m.PURCH_DT,''),'-','') + '-' + m.PURCH_NO = l.REF_NO );
GO

-- 2) 확인 — 살아 있는 전표와 짝이 없는 매입 원장 줄이 0줄이어야 한다
SELECT COUNT(*) AS leftover
  FROM TBL_STOCK_LEDGER l
 WHERE l.ACTION_YN = 'Y' AND l.REF_GB = 'PURCH' AND l.COMP_CD = 'W1234567'
   AND NOT EXISTS ( SELECT 1 FROM TBL_PURCHASE_MST m
                     WHERE m.COMP_CD = l.COMP_CD AND m.ACTION_YN = 'Y'
                       AND REPLACE(ISNULL(m.PURCH_DT,''),'-','') + '-' + m.PURCH_NO = l.REF_NO );
