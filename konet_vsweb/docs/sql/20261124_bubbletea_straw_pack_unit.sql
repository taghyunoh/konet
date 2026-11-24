/* 버블티스트로우(9904013061) 매입단가를 «팩» 단위로 (2026-11-24 사용자 「버블티스트로우 매입단가 팩 단위로 수정 SQL 만들어줘」)

   상품 : 9904013061 (벌크)12.0mm*250mm 버블티 플라스틱 빨대(투명) 200*12 — 1박스 = 12팩 · 1팩 = 200개
          상품마스터 = 입수 12 · 입고가 2,108.33원(팩당) — 이미 팩 단위(2026-11-05 수정)
   문제 : 매입단가 이력(TBL_PROD_INPRICE_HST) 4줄이 «박스» 단가(23,300 · 25,630 · 24,470 · 25,300)다.
          출고·정산서는 «팩» 단위라 매출마감 원가가 「팩 수 × 박스 단가」로 12배 잡힌다(11월 62팩 원가 1,568,600원 — 실제 약 13만 원).
   ─────────────────────────────────────────────────────────────────────────────
   [A] 매입단가 이력 ÷ 12  ← 요청하신 것. 이것만 돌려도 매출마감 원가는 바로 맞는다(이력 단가를 먼저 읽으므로).
   [B] (선택) 매입 전표·재고까지 팩 단위로 맞추기 — 아래 설명을 읽고 필요할 때만. 주석으로 막아 두었다.
   ⚠DB 쓰기 — 사용자가 직접 실행. 되돌리기 = 맨 아래.
   ───────────────────────────────────────────────────────────────────────────── */

-- [A-0] 미리보기 — 4줄 : 23300→1941.67 · 25630→2135.83 · 24470→2039.17 · 25300→2108.33
SELECT INPRICE_SEQ, APPLY_DT, IN_PRICE AS 지금, ROUND(IN_PRICE / 12.0, 2) AS 바꿀값, PREV_PRICE AS 지금_이전가, ROUND(PREV_PRICE / 12.0, 2) AS 바꿀_이전가, REMARK
  FROM TBL_PROD_INPRICE_HST
 WHERE COMP_CD = 'W1234567' AND PROD_CD = '9904013061' AND ACTION_YN = 'Y' AND IN_PRICE > 10000   -- 박스 단가인 줄만(두 번 돌려도 다시 안 나눈다)
 ORDER BY APPLY_DT;

-- [A-1] 고치기 (4줄이면 COMMIT)
BEGIN TRAN;
UPDATE TBL_PROD_INPRICE_HST
   SET IN_PRICE   = ROUND(IN_PRICE / 12.0, 2),
       PREV_PRICE = CASE WHEN PREV_PRICE > 10000 THEN ROUND(PREV_PRICE / 12.0, 2) ELSE PREV_PRICE END,
       REMARK     = LEFT(ISNULL(REMARK,'') + N' · 팩 단가로(÷12) 2026-11-24', 200),
       UPD_DTTM   = CONVERT(varchar(19), GETDATE(), 120), UPD_USER = 'packfix20261124'
 WHERE COMP_CD = 'W1234567' AND PROD_CD = '9904013061' AND ACTION_YN = 'Y' AND IN_PRICE > 10000;
SELECT @@ROWCOUNT AS [A 4줄];
-- COMMIT;
-- ROLLBACK;

-- [A-2] 확인 — 최근 단가 2,108.33 (상품마스터 입고가와 같다)
SELECT APPLY_DT, IN_PRICE, PREV_PRICE FROM TBL_PROD_INPRICE_HST WHERE COMP_CD = 'W1234567' AND PROD_CD = '9904013061' AND ACTION_YN = 'Y' ORDER BY APPLY_DT;


/* ═════════════════════════════════════════════════════════════════════════════
   [B] (선택) 매입 전표 · 재고원장 · 재고조정까지 팩 단위로
   지금 이 품목은 세 가지 단위가 섞여 있다(2026-11-24 조회) :
     · 매입 전표·입고 원장 = «박스»  : 12 · 12 · 32 · 36 박스 (입수 1 로 저장 · 단가 박스당)
     · 출고(정산서)        = «팩»    : 1년 출고 1,378
     · 재고조정 11/05 15:04 = «낱개» : 27박스 + 1,800개를 입수 2,400(=200×12)으로 넣어 수정재고 66,600 → 지금 현재고 66,544
   ⇒ 현재고 66,544 는 «낱개» 숫자인데 출고는 팩으로 1씩 빠진다. 재고금액도 66,544 × 평균단가 24,793 = 16.5억으로 잡혀 있다.
   팩으로 맞추면 : 매입 = 144 · 144 · 384 · 432 팩(합 1,104) / 11/05 실사 = 27박스 9팩 = 333팩 / 지금 현재고 = 277팩(333 − 그 뒤 출고).
   ★B 는 네 문장이 한 묶음이다 — 일부만 돌리면 재고가 더 어긋난다. 돌린 뒤 [🔄 재고 재집계](또는 출고반영 재집계)로 현재고·평균단가를 다시 계산한다.
   ★B-4(재고조정 환산)는 «11/05 실사가 27박스 + 1,800개(=9팩)였다» 는 전제다 — 맞는지 확인하고 돌릴 것.
   ═════════════════════════════════════════════════════════════════════════════ */
/*
BEGIN TRAN;

-- B-1 매입 전표 명세 4줄 : 입수 12 · 수량 = 박스 × 12 · 단가 ÷ 12 (금액은 그대로)
UPDATE TBL_PURCHASE_DTL
   SET PACK_QTY = 12, QTY = BOX_QTY * 12 + ISNULL(EA_QTY,0), UNIT_PRICE = ROUND(UNIT_PRICE / 12.0, 2),
       UPD_DTTM = CONVERT(varchar(19), GETDATE(), 120), UPD_USER = 'packfix20261124'
 WHERE COMP_CD = 'W1234567' AND PROD_CD = '9904013061' AND ACTION_YN = 'Y' AND DTL_SEQ IN (1071, 1074, 1078, 1083) AND PACK_QTY = 1 AND UNIT_PRICE > 10000;
SELECT @@ROWCOUNT AS [B-1 4줄];

-- B-2 그 전표 머리의 총수량 = 명세 수량 합 (다른 전표와 같은 규칙 : TOT_QTY = Σ QTY)
UPDATE m SET m.TOT_QTY = x.Q
  FROM TBL_PURCHASE_MST m
  JOIN ( SELECT PURCH_SEQ, SUM(QTY) AS Q FROM TBL_PURCHASE_DTL WHERE ACTION_YN = 'Y' AND PURCH_SEQ IN (262, 263, 265, 268) GROUP BY PURCH_SEQ ) x ON x.PURCH_SEQ = m.PURCH_SEQ
 WHERE m.PURCH_SEQ IN (262, 263, 265, 268);
SELECT @@ROWCOUNT AS [B-2 4줄];

-- B-3 재고원장 입고 4줄 : 수량 × 12 · 단가 ÷ 12 (금액 그대로) → 12·12·32·36 → 144·144·384·432
UPDATE TBL_STOCK_LEDGER
   SET QTY = QTY * 12, UNIT_PRICE = ROUND(UNIT_PRICE / 12.0, 2),
       UPD_DTTM = CONVERT(varchar(19), GETDATE(), 120), UPD_USER = 'packfix20261124'
 WHERE COMP_CD = 'W1234567' AND PROD_CD = '9904013061' AND ACTION_YN = 'Y' AND IO_GB = 'I' AND REF_GB = 'PURCH'
   AND LEDGER_SEQ IN (984212, 999251, 999255, 999260) AND UNIT_PRICE > 10000;
SELECT @@ROWCOUNT AS [B-3 4줄];

-- B-4 11/05 15:04 재고조정(낱개 66,600) → 팩(333) : 조정 전 재고 220 + 입고 환산분 1,012(= 92박스 × 11) = 1,232 → 수정재고 333 · 증감 −899
UPDATE TBL_STOCK_LEDGER SET QTY = -899, UPD_DTTM = CONVERT(varchar(19), GETDATE(), 120), UPD_USER = 'packfix20261124'
 WHERE LEDGER_SEQ = 3054184 AND PROD_CD = '9904013061' AND IO_GB = 'A' AND QTY = 66380;
SELECT @@ROWCOUNT AS [B-4 원장 1줄];
UPDATE TBL_STOCK_ADJ_HIS
   SET BEF_QTY = 1232, AFT_QTY = 333, DIFF_QTY = -899, BEF_BOX = 102, BEF_EA = 8, AFT_BOX = 27, AFT_EA = 9, PACK_QTY = 12,
       REMARK = LEFT(ISNULL(REMARK,'') + N' · 낱개 66,600 → 팩 333 환산 2026-11-24', 200),
       UPD_DTTM = CONVERT(varchar(19), GETDATE(), 120), UPD_USER = 'packfix20261124'
 WHERE ADJ_SEQ = 1537 AND PROD_CD = '9904013061' AND AFT_QTY = 66600;
SELECT @@ROWCOUNT AS [B-4 이력 1줄];
-- (그 앞 14:14 「서브코드 정리」 이력 ADJ_SEQ 1532 의 전·후 표시 −1,201 → 221 은 그대로 둔다 — 증감 +1,422 는 팩 수라 맞다. 표시만 옛 숫자로 남는다)

-- 확인 : 원장 합 = 277 (입고 1,104 + 반품 28 + 조정 1,422 − 899 − 출고 1,378)
SELECT SUM(CASE WHEN IO_GB = 'O' THEN -QTY ELSE QTY END) AS 원장합_277이어야
  FROM TBL_STOCK_LEDGER WHERE COMP_CD = 'W1234567' AND PROD_CD = '9904013061' AND ACTION_YN = 'Y';

-- COMMIT;   → 그 뒤 화면에서 [🔄 재고 재집계]
-- ROLLBACK;
*/

/* ── 되돌리기 ──
   [A] UPDATE TBL_PROD_INPRICE_HST SET IN_PRICE = CASE INPRICE_SEQ WHEN 1064 THEN 23300 WHEN 1067 THEN 25630 WHEN 1071 THEN 24470 WHEN 1076 THEN 25300 END,
                                        PREV_PRICE = CASE INPRICE_SEQ WHEN 1064 THEN 26917 WHEN 1067 THEN 23300 WHEN 1071 THEN 25630 WHEN 1076 THEN 24470 END
        WHERE INPRICE_SEQ IN (1064, 1067, 1071, 1076) AND UPD_USER = 'packfix20261124';
   [B] 명세 : PACK_QTY 1 · QTY = BOX_QTY · UNIT_PRICE 23300/25630/24470/25300 (DTL_SEQ 1071/1074/1078/1083) · 머리 TOT_QTY 176/112/232/260
       원장 : QTY 12/12/32/36 · UNIT_PRICE 위와 같음 (LEDGER_SEQ 984212/999251/999255/999260) · 조정 3054184 QTY 66380
       이력 : ADJ_SEQ 1537 BEF 220 · AFT 66600 · DIFF 66380 · BEF_BOX 220 · BEF_EA 0 · AFT_BOX 27 · AFT_EA 1800 · PACK_QTY 2400 */
