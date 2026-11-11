/* =====================================================================
   담당자 옛 코드 「001 김동근」 → 직원 계정 「admin 마스터」 (2026-11-11 사용자 「옛 코드 001 김동근은 admin 마스터로 옮겨줘요」)

   ★배경 : 종합 실적 담당사원은 직원(로그인 계정 K001…·admin) 기준으로 확정(같은 날 「K002·K003·admin 이 내용으로 적용」).
          거래처 관리의 담당자와 전표(판매·매입·수금/지급)에는 홀세일 시절 코드 「001 김동근」이 남아 있어 사원별 현황에 「옛 코드」 줄로 섰다.
   ★순서 (한 트랜잭션, 끝에 COMMIT — 오류 나면 전부 ROLLBACK) :
     A. 앞서 20261111_purchase_mgr_fix.sql 이 001 김동근으로 바꿔 둔 「발주서 → 매입전환」 46장은 발주서의 담당자(K002·K003·admin)로 되돌린다
        (20261111_purchase_mgr_restore.sql 과 같은 문장 — 아직 안 돌렸으면 여기서 같이, 이미 돌렸으면 0건으로 지나간다).
     B. 남은 001 김동근을 admin 마스터로 — 매입전표 · 판매전표 · 수금/지급전표 · 거래처 관리(담당자). 거래처를 바꿔야 앞으로 저장되는 전표와
        정산서·토더 매출(출고장 거래처의 담당자)도 admin 으로 잡힌다.
   ★손대지 않는 것 : 006 남대성(거래처 167곳) · 005 김민지(2곳) · 코드 없이 이름만 있는 담당자(이정호·김연태 과장·박선희 과장) · 발주서(TBL_PO_MST).
   실행 : SSMS 에서 전체 실행. 결과 창의 건수(매입 451 안팎 · 판매 151 · 수금지급 188 · 거래처 226)와 맨 아래 확인 표를 본다.
   ===================================================================== */
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  /* A. 전환 46장 되돌리기 — 발주서 담당자로 (이미 되돌렸으면 0건) */
  UPDATE m
     SET m.MGR_CD = p.MGR_CD, m.MGR_NM = p.MGR_NM,
         m.UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), m.UPD_USER = 'admin', m.UPD_IP = 'sql-20261111-restore'
    FROM dbo.TBL_PURCHASE_MST m
    JOIN dbo.TBL_PO_MST p ON p.PO_SEQ = m.PO_SEQ AND p.COMP_CD = m.COMP_CD
   WHERE m.COMP_CD = 'W1234567' AND m.ACTION_YN = 'Y' AND m.UPD_IP = 'sql-20261111'
     AND ISNULL(p.MGR_CD,'') <> '';
  SELECT 'A 전환 46장 되돌림' AS 단계, @@ROWCOUNT AS 건수;

  /* B-1. 매입전표 */
  UPDATE dbo.TBL_PURCHASE_MST
     SET MGR_CD = 'admin', MGR_NM = N'마스터',
         UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-admin'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '001';
  SELECT 'B-1 매입전표' AS 단계, @@ROWCOUNT AS 건수;

  /* B-2. 판매전표 */
  UPDATE dbo.TBL_SALES_TRX_MST
     SET MGR_CD = 'admin', MGR_NM = N'마스터',
         UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-admin'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '001';
  SELECT 'B-2 판매전표' AS 단계, @@ROWCOUNT AS 건수;

  /* B-3. 수금/지급 전표 */
  UPDATE dbo.TBL_SETTLE_TRX
     SET MGR_CD = 'admin', MGR_NM = N'마스터',
         UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-admin'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '001';
  SELECT 'B-3 수금지급전표' AS 단계, @@ROWCOUNT AS 건수;

  /* B-4. 거래처 관리 담당자 — 앞으로의 전표·정산서·토더 매출이 admin 으로 잡히게 */
  UPDATE dbo.TBL_VENDOR_MST
     SET MGR_CD = 'admin', MGR_NM = N'마스터',
         UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-admin'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '001';
  SELECT 'B-4 거래처 담당자' AS 단계, @@ROWCOUNT AS 건수;

  COMMIT;
  PRINT 'COMMIT 완료';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  PRINT '오류 — ROLLBACK : ' + ERROR_MESSAGE();
END CATCH;

/* 확인 — 「001」 이 남은 곳이 없어야 한다 */
SELECT '매입전표' AS 표, ISNULL(MGR_CD,'(없음)') AS MGR_CD, ISNULL(MGR_NM,'') AS MGR_NM, COUNT(*) AS 건수 FROM dbo.TBL_PURCHASE_MST  WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
UNION ALL
SELECT '판매전표', ISNULL(MGR_CD,'(없음)'), ISNULL(MGR_NM,''), COUNT(*) FROM dbo.TBL_SALES_TRX_MST WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
UNION ALL
SELECT '수금지급', ISNULL(MGR_CD,'(없음)'), ISNULL(MGR_NM,''), COUNT(*) FROM dbo.TBL_SETTLE_TRX    WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
UNION ALL
SELECT '거래처',   ISNULL(MGR_CD,'(없음)'), ISNULL(MGR_NM,''), COUNT(*) FROM dbo.TBL_VENDOR_MST    WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
ORDER BY 1, 4 DESC;
