/* =====================================================================
   담당자 옛 코드 「005 김민지」 → 직원 계정 「K001 김민지」 (2026-11-11 사용자 「005 김민지는 K001로 옮겨줘요」)
   · 20261111_mgr_001_to_admin.sql 과 같은 식 — 거래처 관리 담당자 + 전표 3표(매입·판매·수금/지급). 2026-11-11 실측 : 거래처 2곳, 전표 0장.
   · 한 트랜잭션, 끝에 자동 COMMIT, 오류 시 자동 ROLLBACK. SSMS 에서 전체 실행.
   ===================================================================== */
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  UPDATE dbo.TBL_VENDOR_MST    SET MGR_CD = 'K001', MGR_NM = N'김민지', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-k001'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '005';
  SELECT '거래처 담당자' AS 단계, @@ROWCOUNT AS 건수;
  UPDATE dbo.TBL_PURCHASE_MST  SET MGR_CD = 'K001', MGR_NM = N'김민지', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-k001'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '005';
  SELECT '매입전표' AS 단계, @@ROWCOUNT AS 건수;
  UPDATE dbo.TBL_SALES_TRX_MST SET MGR_CD = 'K001', MGR_NM = N'김민지', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-k001'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '005';
  SELECT '판매전표' AS 단계, @@ROWCOUNT AS 건수;
  UPDATE dbo.TBL_SETTLE_TRX    SET MGR_CD = 'K001', MGR_NM = N'김민지', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-k001'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND MGR_CD = '005';
  SELECT '수금지급전표' AS 단계, @@ROWCOUNT AS 건수;
  COMMIT;
  PRINT 'COMMIT 완료';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  PRINT '오류 — ROLLBACK : ' + ERROR_MESSAGE();
END CATCH;

/* 확인 — 「005」 가 남은 곳이 없어야 한다 */
SELECT '거래처' AS 표, ISNULL(MGR_CD,'(없음)') AS MGR_CD, ISNULL(MGR_NM,'') AS MGR_NM, COUNT(*) AS 건수 FROM dbo.TBL_VENDOR_MST WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
ORDER BY 4 DESC;
