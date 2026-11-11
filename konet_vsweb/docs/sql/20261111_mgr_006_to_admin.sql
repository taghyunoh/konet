/* =====================================================================
   담당자 옛 코드 「006 남대성」 → 직원 계정 「admin 마스터」 (2026-11-11 사용자 「006 남대성은 admin 마스터로 옮겨줘요」)
   · 20261111_mgr_001_to_admin.sql · 20261111_mgr_005_to_K001.sql 과 같은 식 — 거래처 관리 담당자 + 전표 3표. 2026-11-11 실측 : 거래처 167곳, 전표 0장.
   · 이것으로 홀세일 시절 담당자코드(001·005·006)는 모두 직원 계정으로 바뀐다. 남는 것은 코드 없이 이름만 있는 담당자 3곳·담당자 없는 3곳(거래처 관리에서 직접).
   · 한 트랜잭션, 끝에 자동 COMMIT, 오류 시 자동 ROLLBACK. SSMS 에서 전체 실행.
   ===================================================================== */
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  UPDATE dbo.TBL_VENDOR_MST    SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-006'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '006';
  SELECT '거래처 담당자' AS 단계, @@ROWCOUNT AS 건수;
  UPDATE dbo.TBL_PURCHASE_MST  SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-006'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '006';
  SELECT '매입전표' AS 단계, @@ROWCOUNT AS 건수;
  UPDATE dbo.TBL_SALES_TRX_MST SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-006'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '006';
  SELECT '판매전표' AS 단계, @@ROWCOUNT AS 건수;
  UPDATE dbo.TBL_SETTLE_TRX    SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-006'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '006';
  SELECT '수금지급전표' AS 단계, @@ROWCOUNT AS 건수;
  COMMIT;
  PRINT 'COMMIT 완료';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  PRINT '오류 — ROLLBACK : ' + ERROR_MESSAGE();
END CATCH;

/* 확인 — 숫자 코드(001·005·006)가 남은 곳이 없어야 한다 */
SELECT '거래처' AS 표, ISNULL(MGR_CD,'(없음)') AS MGR_CD, ISNULL(MGR_NM,'') AS MGR_NM, COUNT(*) AS 건수 FROM dbo.TBL_VENDOR_MST WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
ORDER BY 4 DESC;
