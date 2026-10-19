/* =====================================================================
   매입 전표 등록자(REG_USER) 빈칸 채우기 (2026-10-19, 사용자 「등록자가 없는데 확인해 주세요」 → 「쿼리해 주세요 실행하겠음」)
     · 원인 : 세션이 죽은(재배포·만료) 채 열려 있던 매입등록 화면에서 저장 → 저장 관문에 로그인 검사가 없어
             REG_USER 빈칸·COMP_CD 기본값으로 그대로 저장됐다. 2026-08-05 ~ 2026-09-17 등록분 21건.
             (2026-09-19 「세션·재배포 확인」 뒤 재발 없음. 2026-10-19 저장 관문에 로그인 검사 추가.)
     · 채우는 값 : 나중에 그 전표를 고친 사람(UPD_USER)이 있으면 그 사람, 없으면 'admin'
             — 9월 1~18일 등록 137건 중 126건이 admin, K001 은 9/18 부터라 빈칸은 admin 세션으로 본다. 다르면 아래 CASE 를 고쳐 실행.
     · 대상 : TBL_PURCHASE_MST 21건 + 그 명세(TBL_PURCHASE_DTL) + 그 재고원장(TBL_STOCK_LEDGER, REF_GB='PURCH', REF_NO='yyyymmdd-번호')
     · 실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. ① 미리보기로 21건인지 확인 → ② 갱신(트랜잭션). 두 번 실행해도 안전(빈칸만 채운다).
   ===================================================================== */

-- ① 미리보기 — 21줄이 나와야 한다. FILL 칸이 들어갈 값
SELECT m.PURCH_SEQ, m.PURCH_DT, m.PURCH_NO, m.VENDOR_NM, m.REG_DTTM, ISNULL(m.UPD_USER,'') AS UPD_USER,
       CASE WHEN ISNULL(m.UPD_USER,'') <> '' THEN m.UPD_USER ELSE 'admin' END AS FILL
  FROM dbo.TBL_PURCHASE_MST m
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y' AND ISNULL(m.REG_USER,'') = ''
   AND m.PURCH_SEQ IN (191,192,193,194,256,257,154,155,156,158,159,403,378,384,386,387,430,429,431,433,434)
 ORDER BY m.PURCH_DT, m.PURCH_NO;

-- ② 갱신 — 미리보기가 21줄이면 아래를 통째로 실행
BEGIN TRAN;

UPDATE m
   SET m.REG_USER = CASE WHEN ISNULL(m.UPD_USER,'') <> '' THEN m.UPD_USER ELSE 'admin' END
  FROM dbo.TBL_PURCHASE_MST m
 WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y' AND ISNULL(m.REG_USER,'') = ''
   AND m.PURCH_SEQ IN (191,192,193,194,256,257,154,155,156,158,159,403,378,384,386,387,430,429,431,433,434);
-- 기대 : 21건

UPDATE d
   SET d.REG_USER = m.REG_USER
  FROM dbo.TBL_PURCHASE_DTL d
  JOIN dbo.TBL_PURCHASE_MST m ON m.PURCH_SEQ = d.PURCH_SEQ AND m.COMP_CD = d.COMP_CD
 WHERE m.COMP_CD = 'W1234567' AND ISNULL(d.REG_USER,'') = ''
   AND m.PURCH_SEQ IN (191,192,193,194,256,257,154,155,156,158,159,403,378,384,386,387,430,429,431,433,434);
-- 기대 : 63건(명세 줄)

UPDATE l
   SET l.REG_USER = m.REG_USER
  FROM dbo.TBL_STOCK_LEDGER l
  JOIN dbo.TBL_PURCHASE_MST m ON m.COMP_CD = l.COMP_CD
                              AND l.REF_GB = 'PURCH'
                              AND l.REF_NO = REPLACE(ISNULL(m.PURCH_DT,''),'-','') + '-' + m.PURCH_NO
 WHERE m.COMP_CD = 'W1234567' AND ISNULL(l.REG_USER,'') = ''
   AND m.PURCH_SEQ IN (191,192,193,194,256,257,154,155,156,158,159,403,378,384,386,387,430,429,431,433,434);
-- 기대 : 61건(재고원장 줄)

-- 확인 — 0 이어야 한다
SELECT COUNT(*) AS STILL_EMPTY
  FROM dbo.TBL_PURCHASE_MST
 WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND ISNULL(REG_USER,'') = '';

COMMIT;
-- 이상하면 COMMIT 대신 ROLLBACK;
