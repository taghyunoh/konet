/* =====================================================================
   적정재고 자동 산출 (2026-09-17, 설계 = docs/설계_적정재고_자동산출_2026-09-17.md)
     · TBL_PROD_MST.SAFE_STOCK_SRC  : 적정재고 출처 — 'M' 수기(상품코드관리·일괄 붙여넣기) · 'A' 자동 산출 · NULL 미설정
                                       자동 산출은 수기('M') 값을 [수기 입력값도 덮어쓰기]를 켜지 않으면 건드리지 않는다
     · TBL_PROD_MST.SAFE_STOCK_DTTM : 마지막으로 적정재고가 바뀐 때
     · 기존에 들어 있던 적정재고(운영 4건)는 수기('M')로 표시한다
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(COL_LENGTH IS NULL).
   ⚠WAR 배포 <전에> 실행할 것 — 상품 목록(selectProdList)·산출 SQL 이 이 칸을 읽는다.
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_PROD_MST','SAFE_STOCK_SRC')  IS NULL ALTER TABLE dbo.TBL_PROD_MST ADD SAFE_STOCK_SRC  CHAR(1)     NULL;
IF COL_LENGTH('dbo.TBL_PROD_MST','SAFE_STOCK_DTTM') IS NULL ALTER TABLE dbo.TBL_PROD_MST ADD SAFE_STOCK_DTTM VARCHAR(19) NULL;
GO
UPDATE dbo.TBL_PROD_MST SET SAFE_STOCK_SRC = 'M', SAFE_STOCK_DTTM = ISNULL(UPD_DTTM, REG_DTTM)
 WHERE ISNULL(SAFE_STOCK,0) > 0 AND SAFE_STOCK_SRC IS NULL;
GO
/* ── 확인 ── */
SELECT COL_LENGTH('dbo.TBL_PROD_MST','SAFE_STOCK_SRC') AS src_col, COL_LENGTH('dbo.TBL_PROD_MST','SAFE_STOCK_DTTM') AS dttm_col;
SELECT ISNULL(SAFE_STOCK_SRC,'(없음)') AS src, COUNT(*) AS n FROM dbo.TBL_PROD_MST WHERE ACTION_YN = 'Y' GROUP BY SAFE_STOCK_SRC;
