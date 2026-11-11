/* =====================================================================
   매입전표 담당자 바로잡기 — 로그인 아이디 → 거래처 담당자 (2026-11-11 사용자 「매입등록 담당자는 거래처 담당자로 맞추고 48장 고치는 SQL」)

   ★원인 (2026-11-11 실측)
     · 발주서 관리(poReg.jsp)가 발주서 담당자를 <로그인 사용자>(K002 설재우 · K003 전원배 · admin 마스터 …)로 저장하고,
       [📦 매입전환](UserController poConvert)이 그 값을 매입전표 MGR_CD/MGR_NM 에 그대로 옮겼다.
     · 매입등록 화면에서 직접 저장한 전표는 거래처 담당자(001 김동근 …)가 들어간다 — 종합 실적 사원별 현황은 이 체계(거래처 담당자코드)다.
     · 코드 수정(같은 날) : 매입전환이 거래처 마스터의 담당자를 넣도록 바꿨다(거래처에 담당자가 없을 때만 발주서 값). 이 SQL 은 지난 전표를 고친다.

   ★대상 = TBL_PURCHASE_MST 중 MGR_CD 가 로그인 아이디(TBL_USER_MST.USER_ID)인 전표 46장 (2026-09-11 ~ 2026-11-10, 전부 「발주서 … 전환」).
     · MGR_CD 가 빈 전표 6장(모두상사 4 · 후아인터내셔널 2)은 거래처 자체에 담당자코드가 없어 바꿀 값이 없다 → 그대로 둔다
       (거래처 관리에서 담당자를 넣은 뒤 이 SQL 을 다시 돌리면 그때 같이 고쳐진다 — 조건이 「거래처 담당자가 있는 것」이라서).
     · 발주서(TBL_PO_MST)의 담당자는 <발주서 작성자>로 보고 손대지 않는다.

   실행 : 반드시 ① 미리보기 → ② UPDATE(트랜잭션 안, 건수 확인 뒤 COMMIT) → ③ 확인 순서. 운영 DB.
   ===================================================================== */

/* ① 미리보기 — 바뀔 전표 (46건이어야 한다) */
SELECT m.PURCH_SEQ, m.PURCH_DT, m.PURCH_NO, m.VENDOR_CD, m.VENDOR_NM,
       m.MGR_CD AS 전표담당코드, m.MGR_NM AS 전표담당, v.MGR_CD AS 거래처담당코드, v.MGR_NM AS 거래처담당, m.REMARK
  FROM dbo.TBL_PURCHASE_MST m
  JOIN dbo.TBL_VENDOR_MST v ON v.COMP_CD = m.COMP_CD AND v.VENDOR_CD = m.VENDOR_CD AND v.ACTION_YN = 'Y'
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y'
   AND ISNULL(v.MGR_CD,'') <> ''
   AND ( ISNULL(m.MGR_CD,'') = ''
         OR m.MGR_CD IN (SELECT LTRIM(RTRIM(u.USER_ID)) FROM dbo.TBL_USER_MST u WHERE u.COMP_CD = m.COMP_CD) )
   AND ( ISNULL(m.MGR_CD,'') <> ISNULL(v.MGR_CD,'') OR ISNULL(m.MGR_NM,'') <> ISNULL(v.MGR_NM,'') )
 ORDER BY m.PURCH_DT, m.PURCH_NO;

/* ② 바꾸기 — 거래처 담당자코드·이름으로. 건수가 ①과 다르면 ROLLBACK */
BEGIN TRAN;
UPDATE m
   SET m.MGR_CD = v.MGR_CD, m.MGR_NM = v.MGR_NM,
       m.UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), m.UPD_USER = 'admin', m.UPD_IP = 'sql-20261111'
  FROM dbo.TBL_PURCHASE_MST m
  JOIN dbo.TBL_VENDOR_MST v ON v.COMP_CD = m.COMP_CD AND v.VENDOR_CD = m.VENDOR_CD AND v.ACTION_YN = 'Y'
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y'
   AND ISNULL(v.MGR_CD,'') <> ''
   AND ( ISNULL(m.MGR_CD,'') = ''
         OR m.MGR_CD IN (SELECT LTRIM(RTRIM(u.USER_ID)) FROM dbo.TBL_USER_MST u WHERE u.COMP_CD = m.COMP_CD) )
   AND ( ISNULL(m.MGR_CD,'') <> ISNULL(v.MGR_CD,'') OR ISNULL(m.MGR_NM,'') <> ISNULL(v.MGR_NM,'') );
SELECT @@ROWCOUNT AS 바뀐건수;   -- 46 이면 COMMIT, 아니면 ROLLBACK
-- COMMIT;
-- ROLLBACK;

/* ③ 확인 — 로그인 아이디가 담당자로 남은 매입전표가 0건이어야 한다 */
SELECT ISNULL(m.MGR_CD,'(없음)') AS MGR_CD, ISNULL(m.MGR_NM,'') AS MGR_NM, COUNT(*) AS 건수
  FROM dbo.TBL_PURCHASE_MST m
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y'
 GROUP BY m.MGR_CD, m.MGR_NM
 ORDER BY 3 DESC;
