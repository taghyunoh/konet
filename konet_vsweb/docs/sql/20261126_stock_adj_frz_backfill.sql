/* ============================================================================
   기존 재고수정을 전부 «고정» 으로 (2026-11-26)
   사용자 : 「안되는 메세지 나와야 되는 것 아닌가요 조정이후 건데」(11-18 재고수정 뒤 9/16 전표 삭제 — 1000736038)
            → 「사용자가 재고수정했으면 고정입니다」

   ■ 왜 필요한가
     수정재고 고정(매퍼 조각 adjAnchorKeep)은 재고수정 이력의 기준값 FRZ_QTY 가 있어야 동작한다.
     FRZ_QTY 는 «고정 기능이 들어간 프로그램으로 재고수정을 저장할 때» 만 채워진다(insertStockAdjHis → updateStockAdjFrz —
     재고 일괄조정 · 상품코드등록 재고 수정 모두 이 한 길). 그 전에 저장한 재고수정(운영 772건 전부)은 «차이만» 기억하고 있어,
     11-18 에 412 로 맞춘 뒤 9/16 전표를 지우자 현재고에서 250 이 빠졌다(68). 재고 변동 확인의 「🔒 적용 안 됨」 도 안 떴다.

   ■ 무엇을 하나 — (품목, 창고)마다 «가장 나중에 저장한» 재고수정 중 FRZ_QTY 가 빈 것을 «전부» 고정한다. 두 갈래 :
     (가) @FROM(기본 2026-11-15 · 이번 실사 기간) 이후 저장분 = «저장 당시 기준»
          FRZ_QTY = 수정재고(AFT_QTY) − (그 재고수정을 저장할 때 이미 있던, 재고수정 날짜부터의 다른 줄 합)
          = 프로그램이 그때 저장했다면 남겼을 값. «저장할 때 이미 있던» = 원장 줄 REG_DTTM < 재고수정 저장 시각.
          → 현재고가 실사 숫자 기준으로 돌아간다(1000736038 68 → 299 = 412 − 11-18 이후 출고).
     (나) 그보다 오래된 저장분 = «지금 현재고 기준»
          FRZ_QTY = 지금 원장 합 − 재고수정 날짜부터의 다른 줄 합 → 현재고는 그대로, 앞으로 과거 전표가 바뀌어도 흔들리지 않는다.
          오래된 것을 저장 당시 기준으로 되살리면 그 뒤 재집계로 다시 만들어진 줄(REG_DTTM 이 늦다) 때문에 계산이 틀어진다
          (미리보기에서 1010014032 −116,000 → 86,000 · 2만씩 튀는 품목이 나왔다).

   ■ 2026-11-26 운영 미리보기(조회만) — 대상 772
     (가) 45품목 중 현재고가 바뀌는 것 8개 :
       1000736038 68 → 299 · 1000808776 4 → 109 · 1000800552 102 → 46 · 1000800551 48 → 39 · 9904013323 680 → 675
       1000455370 4 → 0 · 1000795149 22 → 20 · 9904013422 25 → 24   (1000736038 · 1000808776 은 11-25 실사 대조 304/302 · 109/109 와 맞는다)
     (나) 727품목은 현재고 그대로(고정만)

   ■ 순서 (⚠꼭 지킬 것)
     ① 운영에 고정 기능이 들어간 WAR 를 먼저 반영 — 그 전에 넣으면 그 사이 옛 프로그램으로 저장한 재고수정이 또 빈 채로 남는다
     ② [1] 미리보기를 돌려 숫자를 본다
     ③ [2] 실행(되돌리기 목록을 떠 두고 · 트랜잭션 — 맞으면 COMMIT, 아니면 ROLLBACK)
     ④ 품목별재고현황에서 [🔄 출고반영 재집계] 한 번 — 그때 현재고가 «고정 후» 숫자로 바뀐다
     ⚠로컬 개발 서버도 운영 DB 를 본다 — ③ 뒤에 로컬에서 그 품목 전표를 건드리면 ④ 전에 현재고가 바뀔 수 있다.
     되돌리기 = [3]
   ============================================================================ */

DECLARE @FROM DATETIME = '2026-11-15';

/* [1] 미리보기 — 무엇이 얼마로 바뀌나 (조회만) */
;WITH a AS (
  SELECT l.COMP_CD, l.PROD_SEQ, ISNULL(l.WH_CD,'') AS WH, l.LEDGER_SEQ, l.TRX_DT, h.ADJ_SEQ, h.PROD_CD, h.AFT_QTY, h.REG_DTTM, h.FRZ_QTY,
         ROW_NUMBER() OVER (PARTITION BY l.COMP_CD, l.PROD_SEQ, ISNULL(l.WH_CD,'') ORDER BY l.LEDGER_SEQ DESC) AS rn
    FROM TBL_STOCK_LEDGER l
    JOIN TBL_STOCK_ADJ_HIS h ON h.LEDGER_SEQ = l.LEDGER_SEQ AND h.COMP_CD = l.COMP_CD AND h.ACTION_YN = 'Y'
   WHERE l.ACTION_YN = 'Y' AND l.IO_GB = 'A' ),
b AS (
  SELECT a.*,
    ISNULL((SELECT SUM(CASE WHEN z.IO_GB IN ('I','R','A') THEN z.QTY WHEN z.IO_GB = 'O' THEN -z.QTY ELSE 0 END) FROM TBL_STOCK_LEDGER z
             WHERE z.COMP_CD = a.COMP_CD AND z.PROD_SEQ = a.PROD_SEQ AND ISNULL(z.WH_CD,'') = a.WH AND z.ACTION_YN = 'Y'), 0) AS T,
    ISNULL((SELECT SUM(CASE WHEN z.IO_GB IN ('I','R','A') THEN z.QTY WHEN z.IO_GB = 'O' THEN -z.QTY ELSE 0 END) FROM TBL_STOCK_LEDGER z
             WHERE z.COMP_CD = a.COMP_CD AND z.PROD_SEQ = a.PROD_SEQ AND ISNULL(z.WH_CD,'') = a.WH AND z.ACTION_YN = 'Y'
               AND z.TRX_DT >= a.TRX_DT AND z.LEDGER_SEQ <> a.LEDGER_SEQ), 0) AS E,
    ISNULL((SELECT SUM(CASE WHEN z.IO_GB IN ('I','R','A') THEN z.QTY WHEN z.IO_GB = 'O' THEN -z.QTY ELSE 0 END) FROM TBL_STOCK_LEDGER z
             WHERE z.COMP_CD = a.COMP_CD AND z.PROD_SEQ = a.PROD_SEQ AND ISNULL(z.WH_CD,'') = a.WH AND z.ACTION_YN = 'Y'
               AND z.TRX_DT >= a.TRX_DT AND z.LEDGER_SEQ <> a.LEDGER_SEQ AND z.REG_DTTM < a.REG_DTTM), 0) AS ES
    FROM a WHERE a.rn = 1 AND a.FRZ_QTY IS NULL )
SELECT CASE WHEN b.REG_DTTM >= @FROM THEN N'(가) 저장 당시' ELSE N'(나) 지금 기준' END AS gb,
       b.PROD_CD, LEFT(REPLACE(b.TRX_DT,'-',''),8) AS adjDt, CONVERT(VARCHAR(16), b.REG_DTTM, 120) AS saved, b.AFT_QTY AS aftQty, ROUND(b.T,0) AS nowQty,
       CASE WHEN b.REG_DTTM >= @FROM THEN ROUND(b.AFT_QTY - b.ES + b.E, 0) ELSE ROUND(b.T,0) END AS fixedQty,
       CASE WHEN b.REG_DTTM >= @FROM THEN ROUND(b.AFT_QTY - b.ES + b.E, 0) - ROUND(b.T,0) ELSE 0 END AS diff,
       CASE WHEN b.REG_DTTM >= @FROM THEN b.AFT_QTY - b.ES ELSE b.T - b.E END AS newFrz
  FROM b
 ORDER BY CASE WHEN b.REG_DTTM >= @FROM AND ROUND(b.AFT_QTY - b.ES + b.E, 0) <> ROUND(b.T,0) THEN 0 ELSE 1 END,
          CASE WHEN b.REG_DTTM >= @FROM THEN ABS(ROUND(b.AFT_QTY - b.ES + b.E, 0) - ROUND(b.T,0)) ELSE 0 END DESC, b.REG_DTTM DESC;

/* [2] 실행 — 주석을 풀어 돌린다
SELECT ADJ_SEQ INTO TBL_STOCK_ADJ_HIS_FRZBAK_20261126 FROM TBL_STOCK_ADJ_HIS WHERE FRZ_QTY IS NULL;   -- 되돌리기용 목록([3])
BEGIN TRAN;
;WITH a AS (
  SELECT l.COMP_CD, l.PROD_SEQ, ISNULL(l.WH_CD,'') AS WH, l.LEDGER_SEQ, l.TRX_DT, h.ADJ_SEQ, h.AFT_QTY, h.REG_DTTM, h.FRZ_QTY,
         ROW_NUMBER() OVER (PARTITION BY l.COMP_CD, l.PROD_SEQ, ISNULL(l.WH_CD,'') ORDER BY l.LEDGER_SEQ DESC) AS rn
    FROM TBL_STOCK_LEDGER l
    JOIN TBL_STOCK_ADJ_HIS h ON h.LEDGER_SEQ = l.LEDGER_SEQ AND h.COMP_CD = l.COMP_CD AND h.ACTION_YN = 'Y'
   WHERE l.ACTION_YN = 'Y' AND l.IO_GB = 'A' ),
b AS (
  SELECT a.ADJ_SEQ,
         CASE WHEN a.REG_DTTM >= @FROM   -- (가) 저장 당시 기준
              THEN a.AFT_QTY - ISNULL((SELECT SUM(CASE WHEN z.IO_GB IN ('I','R','A') THEN z.QTY WHEN z.IO_GB = 'O' THEN -z.QTY ELSE 0 END) FROM TBL_STOCK_LEDGER z
                                        WHERE z.COMP_CD = a.COMP_CD AND z.PROD_SEQ = a.PROD_SEQ AND ISNULL(z.WH_CD,'') = a.WH AND z.ACTION_YN = 'Y'
                                          AND z.TRX_DT >= a.TRX_DT AND z.LEDGER_SEQ <> a.LEDGER_SEQ AND z.REG_DTTM < a.REG_DTTM), 0)
              -- (나) 지금 현재고 기준 — 현재고 그대로
              ELSE ISNULL((SELECT SUM(CASE WHEN z.IO_GB IN ('I','R','A') THEN z.QTY WHEN z.IO_GB = 'O' THEN -z.QTY ELSE 0 END) FROM TBL_STOCK_LEDGER z
                            WHERE z.COMP_CD = a.COMP_CD AND z.PROD_SEQ = a.PROD_SEQ AND ISNULL(z.WH_CD,'') = a.WH AND z.ACTION_YN = 'Y'), 0)
                 - ISNULL((SELECT SUM(CASE WHEN z.IO_GB IN ('I','R','A') THEN z.QTY WHEN z.IO_GB = 'O' THEN -z.QTY ELSE 0 END) FROM TBL_STOCK_LEDGER z
                            WHERE z.COMP_CD = a.COMP_CD AND z.PROD_SEQ = a.PROD_SEQ AND ISNULL(z.WH_CD,'') = a.WH AND z.ACTION_YN = 'Y'
                              AND z.TRX_DT >= a.TRX_DT AND z.LEDGER_SEQ <> a.LEDGER_SEQ), 0) END AS NEW_FRZ
    FROM a WHERE a.rn = 1 AND a.FRZ_QTY IS NULL )
UPDATE h SET h.FRZ_QTY = b.NEW_FRZ
  FROM TBL_STOCK_ADJ_HIS h JOIN b ON b.ADJ_SEQ = h.ADJ_SEQ;
SELECT @@ROWCOUNT AS updatedRows;   -- 2026-11-26 미리보기 기준 772 근처((가) 45 + (나) 727)
-- COMMIT;   -- 숫자가 맞으면
-- ROLLBACK; -- 아니면
*/

/* [3] 되돌리기 — [2] 앞에 떠 둔 목록의 FRZ_QTY 만 다시 비운다. 실행 뒤 [🔄 출고반영 재집계]
UPDATE h SET h.FRZ_QTY = NULL FROM TBL_STOCK_ADJ_HIS h JOIN TBL_STOCK_ADJ_HIS_FRZBAK_20261126 k ON k.ADJ_SEQ = h.ADJ_SEQ;
*/
