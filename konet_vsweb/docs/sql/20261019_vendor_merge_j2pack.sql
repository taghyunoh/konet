/* =====================================================================
   거래처 중복 합치기 — 제이투팩(주) 001586 → 001595 (2026-10-19, 사용자 「지급등록 원장에 7월 자료만 나오네」)
     · 원인 : 2026-07-17 거래처 리스트 업로드 때 같은 회사가 두 줄로 들어갔다.
             001595 = 거래유형 «매입»(1~10월 매입 36건, 123,943,930) · 001586 = 거래유형 «매출»(7월 매입 4건, 15,222,735 + 10/19 지급 4,000,000).
             지급등록 거래처 고르기에서 같은 이름이 둘 보여 001586 을 골랐고, 원장은 그 코드의 자료(7월)만 보였다.
     · 처리 : 001586 에 달린 자료를 모두 001595 로 옮기고 001586 은 사용 안 함(ACTION_YN='N')으로.
     · 대상(읽기 전용으로 센 값, 2026-10-19) :
         TBL_PURCHASE_MST 4 · TBL_SETTLE_TRX 1 · TBL_STOCK_LEDGER 12 · TBL_PROD_INPRICE_HST 12 · TBL_PROD_MST 0 · 판매 전표 0
     · 실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. ① 미리보기 → ② 갱신(트랜잭션). 두 번 실행해도 안전(옮길 것이 없으면 0건).
     · 다른 중복 거래처도 있다(같은 이름 두 코드) : (주)플러스 001568/001569 · 경성팩 00321/00322 · 대상주식회사 0068/1 · 디케이씨 001601/001605
       — 어느 쪽을 남길지 정해 주면 같은 꼴로 만든다. 여기서는 제이투팩만.
   ===================================================================== */

-- ① 미리보기 — 옮길 건수 (4 · 1 · 12 · 12 가 나와야 한다)
SELECT 'PURCHASE_MST' AS T, COUNT(*) AS CNT FROM dbo.TBL_PURCHASE_MST     WHERE COMP_CD='W1234567' AND VENDOR_CD='001586'
UNION ALL SELECT 'SETTLE_TRX',   COUNT(*) FROM dbo.TBL_SETTLE_TRX         WHERE COMP_CD='W1234567' AND CUST_CD='001586'
UNION ALL SELECT 'STOCK_LEDGER', COUNT(*) FROM dbo.TBL_STOCK_LEDGER       WHERE COMP_CD='W1234567' AND VENDOR_CD='001586'
UNION ALL SELECT 'INPRICE_HST',  COUNT(*) FROM dbo.TBL_PROD_INPRICE_HST   WHERE COMP_CD='W1234567' AND VENDOR_CD='001586'
UNION ALL SELECT 'PROD_MST',     COUNT(*) FROM dbo.TBL_PROD_MST           WHERE COMP_CD='W1234567' AND VENDOR_CD='001586';

-- ② 갱신 — 미리보기가 맞으면 통째로 실행
BEGIN TRAN;

UPDATE dbo.TBL_PURCHASE_MST   SET VENDOR_CD='001595', VENDOR_NM=N'제이투팩(주)' WHERE COMP_CD='W1234567' AND VENDOR_CD='001586';   -- 4
UPDATE dbo.TBL_SETTLE_TRX     SET CUST_CD='001595'                               WHERE COMP_CD='W1234567' AND CUST_CD='001586';     -- 1 (10/19 지급 4,000,000)
UPDATE dbo.TBL_STOCK_LEDGER   SET VENDOR_CD='001595'                             WHERE COMP_CD='W1234567' AND VENDOR_CD='001586';   -- 12
UPDATE dbo.TBL_PROD_INPRICE_HST SET VENDOR_CD='001595'                           WHERE COMP_CD='W1234567' AND VENDOR_CD='001586';   -- 12
UPDATE dbo.TBL_PROD_MST       SET VENDOR_CD='001595'                             WHERE COMP_CD='W1234567' AND VENDOR_CD='001586';   -- 0

-- 001586 은 사용 안 함. 계좌는 001595 에 없으니 옮겨 둔다(001586 에만 국민은행 계좌가 있었다)
UPDATE dbo.TBL_VENDOR_MST SET BANK_ACCT = N'국민은행/699237-01-004560((주)코네트)'
 WHERE COMP_CD='W1234567' AND VENDOR_CD='001595' AND ISNULL(BANK_ACCT,'')='';
UPDATE dbo.TBL_VENDOR_MST SET ACTION_YN='N', UPD_DTTM=CONVERT(VARCHAR(19),GETDATE(),120), UPD_USER='admin'
 WHERE COMP_CD='W1234567' AND VENDOR_CD='001586';

-- 확인 — 모두 0 이어야 하고, 001586 은 ACTION_YN='N'
SELECT (SELECT COUNT(*) FROM dbo.TBL_PURCHASE_MST   WHERE COMP_CD='W1234567' AND VENDOR_CD='001586')
     + (SELECT COUNT(*) FROM dbo.TBL_SETTLE_TRX     WHERE COMP_CD='W1234567' AND CUST_CD='001586')
     + (SELECT COUNT(*) FROM dbo.TBL_STOCK_LEDGER   WHERE COMP_CD='W1234567' AND VENDOR_CD='001586')
     + (SELECT COUNT(*) FROM dbo.TBL_PROD_INPRICE_HST WHERE COMP_CD='W1234567' AND VENDOR_CD='001586') AS STILL_ON_001586,
       (SELECT ACTION_YN FROM dbo.TBL_VENDOR_MST WHERE COMP_CD='W1234567' AND VENDOR_CD='001586') AS V001586_ACTION_YN;

COMMIT;
-- 이상하면 COMMIT 대신 ROLLBACK;
