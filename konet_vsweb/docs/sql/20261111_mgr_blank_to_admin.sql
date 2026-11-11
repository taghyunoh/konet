/* =====================================================================
   담당자 「코드 없이 이름만(퇴사 직원)」·「비어 있음」 → 「admin 마스터」로 통합 (2026-11-11 사용자 「마스터로 통합 — 퇴사 직원」)
   · 2026-11-11 실측 (종합 실적 「(담당 없음)」 묶음의 원천) :
       A. 이름만 적힌 담당자(퇴사 직원) — 거래처 3곳 : 0046 태건우(김연태 과장) · 0090 후아인터내셔널(이정호) · 0111 선우피앤디(박선희 과장)
          전표 : 매입 2장(후아 — 이정호) · 판매 1장(태건우 — 김연태 과장)
       B. 담당자가 비어 있는 거래처 3곳(모두상사 등) + 출고장 거래처 TODER(토더)·DONGWON(동원홈푸드) → 토더·동원 발주 매출이 「담당 없음」으로 잡히던 원인
          전표 : 매입 4장(모두상사)
   · 거래처 담당자와 전표 3표를 같이 바꾼다. 한 트랜잭션, 끝에 자동 COMMIT, 오류 시 자동 ROLLBACK. SSMS 에서 전체 실행.
   · 이것으로 거래처·전표의 담당자는 전부 직원 계정(admin·K001·K002·K003)이 된다 — 종합 실적에 「(담당 없음)」·「(옛 코드)」 줄이 없어진다.
   ===================================================================== */
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  /* ── 거래처 관리 담당자 ── */
  UPDATE dbo.TBL_VENDOR_MST SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-blank'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND ISNULL(MGR_CD,'') = '';   -- 이름만 있는 것(A)·비어 있는 것(B) 모두 코드가 비어 있다
  SELECT 'A+B 거래처 담당자' AS 단계, @@ROWCOUNT AS 건수;   -- 8곳 안팎(3 + 3 + 토더 + 동원)

  /* ── 전표 (코드 빈 것 전부) ── */
  UPDATE dbo.TBL_PURCHASE_MST  SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-blank'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND ISNULL(MGR_CD,'') = '';
  SELECT '매입전표' AS 단계, @@ROWCOUNT AS 건수;   -- 6장(후아 2 · 모두상사 4)
  UPDATE dbo.TBL_SALES_TRX_MST SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-blank'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND ISNULL(MGR_CD,'') = '';
  SELECT '판매전표' AS 단계, @@ROWCOUNT AS 건수;   -- 1장(태건우)
  UPDATE dbo.TBL_SETTLE_TRX    SET MGR_CD = 'admin', MGR_NM = N'마스터', UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120), UPD_USER = 'admin', UPD_IP = 'sql-20261111-blank'
   WHERE COMP_CD = 'W1234567' AND ACTION_YN = 'Y' AND ISNULL(MGR_CD,'') = '';
  SELECT '수금지급전표' AS 단계, @@ROWCOUNT AS 건수;   -- 0장

  COMMIT;
  PRINT 'COMMIT 완료';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  PRINT '오류 — ROLLBACK : ' + ERROR_MESSAGE();
END CATCH;

/* 확인 — 담당자코드가 비거나 직원 아이디가 아닌 곳이 0 이어야 한다 */
SELECT '거래처' AS 표, ISNULL(MGR_CD,'(없음)') AS MGR_CD, ISNULL(MGR_NM,'') AS MGR_NM, COUNT(*) AS 건수 FROM dbo.TBL_VENDOR_MST    WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
UNION ALL
SELECT '매입전표', ISNULL(MGR_CD,'(없음)'), ISNULL(MGR_NM,''), COUNT(*) FROM dbo.TBL_PURCHASE_MST  WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
UNION ALL
SELECT '판매전표', ISNULL(MGR_CD,'(없음)'), ISNULL(MGR_NM,''), COUNT(*) FROM dbo.TBL_SALES_TRX_MST WHERE COMP_CD='W1234567' AND ACTION_YN='Y' GROUP BY MGR_CD, MGR_NM
ORDER BY 1, 4 DESC;
