/* =====================================================================
   매입전표 담당자 되돌리기 — 거래처 담당자(001 김동근) → 발주서 담당자(로그인 사용자 K002·K003·admin)
   (2026-11-11 사용자 「K002·K003·admin 이 내용으로 적용해줘」 — 같은 날 앞서 돌린 20261111_purchase_mgr_fix.sql 의 반대 방향)

   · 20261111_purchase_mgr_fix.sql 이 46장을 001 김동근으로 바꿨다(UPD_IP='sql-20261111' 도장).
     그 46장은 전부 「발주서 → 매입전환」 전표라 PO_SEQ 로 발주서(TBL_PO_MST)와 이어지고, 발주서의 MGR_CD/MGR_NM 이 원래 값(로그인 사용자)이다.
   · 조치 : 도장 찍힌 46장의 담당자를 발주서 담당자로 되돌린다. 건수가 46이 아니면 스스로 ROLLBACK (열린 트랜잭션이 남아 조회를 막던 일 방지).
   · 코드도 같은 날 되돌렸다 — 매입전환은 다시 발주서 담당자(=발주서를 쓴 로그인 사용자)를 넣는다.
   ===================================================================== */

/* ① 미리보기 (46건) */
SELECT m.PURCH_SEQ, m.PURCH_DT, m.PURCH_NO, m.VENDOR_NM, m.MGR_CD AS 지금코드, m.MGR_NM AS 지금이름, p.MGR_CD AS 발주서코드, p.MGR_NM AS 발주서담당
  FROM dbo.TBL_PURCHASE_MST m
  JOIN dbo.TBL_PO_MST p ON p.PO_SEQ = m.PO_SEQ AND p.COMP_CD = m.COMP_CD
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y' AND m.UPD_IP = 'sql-20261111'
   AND ISNULL(p.MGR_CD,'') <> ''
 ORDER BY m.PURCH_DT, m.PURCH_NO;

/* ② 되돌리기 — 46건이면 COMMIT, 아니면 ROLLBACK (자동) */
BEGIN TRAN;
UPDATE m
   SET m.MGR_CD = p.MGR_CD, m.MGR_NM = p.MGR_NM,
       m.UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), m.UPD_USER = 'admin', m.UPD_IP = 'sql-20261111-restore'
  FROM dbo.TBL_PURCHASE_MST m
  JOIN dbo.TBL_PO_MST p ON p.PO_SEQ = m.PO_SEQ AND p.COMP_CD = m.COMP_CD
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y' AND m.UPD_IP = 'sql-20261111'
   AND ISNULL(p.MGR_CD,'') <> '';
IF @@ROWCOUNT = 46 BEGIN COMMIT; PRINT '46건 되돌림 — COMMIT'; END
ELSE BEGIN ROLLBACK; PRINT '건수가 46이 아니라 ROLLBACK — 미리보기(①)를 확인하세요'; END

/* ③ 확인 */
SELECT ISNULL(m.MGR_CD,'(없음)') AS MGR_CD, ISNULL(m.MGR_NM,'') AS MGR_NM, COUNT(*) AS 건수
  FROM dbo.TBL_PURCHASE_MST m
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y'
 GROUP BY m.MGR_CD, m.MGR_NM
 ORDER BY 3 DESC;
