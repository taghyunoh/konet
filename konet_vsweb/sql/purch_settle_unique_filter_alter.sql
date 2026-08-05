/* ============================================================
   전표번호 UNIQUE 인덱스 — 논리삭제(ACTION_YN='N') 행 제외 (2026-08-05)

   [장애] 매입등록에서 특정 일자(20260507)만 저장 실패.
     · 원인 : 등록했다 삭제한 전표(ACTION_YN='N')가 UNIQUE 키 (COMP_CD, PURCH_DT, PURCH_NO)
       를 계속 점유 → 채번(selectPurchaseNextNo)은 활성(Y) 행만 세서 같은 번호를 다시 주고
       → INSERT 가 2601(중복 키) 로 터짐. 그 일자는 영원히 저장 불가가 된다.
     · 조치 : UNIQUE 인덱스에 WHERE ACTION_YN='Y' 필터를 걸어 삭제분은 키에서 제외.
       (채번 로직과 같은 기준이 된다 — 삭제된 번호는 재사용)
     · 대상 : TBL_PURCHASE_MST.UX_PURCH_NO, TBL_SETTLE_TRX.UX_SETTLE_TRX_NO(같은 구조).
       TBL_SALES_TRX_MST 는 전표번호 UNIQUE 가 없어 해당 없음.
     · 재실행 안전. comp_cd_multitenant_alter.sql 의 UX 재생성 블록은
       'COMP_CD 미포함일 때만' 드롭하므로 이 필터를 덮어쓰지 않는다.
   ============================================================ */

-- ① 매입 전표번호
IF EXISTS (SELECT 1 FROM sys.indexes
            WHERE object_id=OBJECT_ID('dbo.TBL_PURCHASE_MST') AND name='UX_PURCH_NO' AND has_filter=0)
BEGIN
    DROP INDEX UX_PURCH_NO ON dbo.TBL_PURCHASE_MST;
END
IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE object_id=OBJECT_ID('dbo.TBL_PURCHASE_MST') AND name='UX_PURCH_NO')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_PURCH_NO
        ON dbo.TBL_PURCHASE_MST (COMP_CD, PURCH_DT, PURCH_NO)
     WHERE ACTION_YN = 'Y';
END
GO

-- ② 수금/지급 전표번호
IF EXISTS (SELECT 1 FROM sys.indexes
            WHERE object_id=OBJECT_ID('dbo.TBL_SETTLE_TRX') AND name='UX_SETTLE_TRX_NO' AND has_filter=0)
BEGIN
    DROP INDEX UX_SETTLE_TRX_NO ON dbo.TBL_SETTLE_TRX;
END
IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE object_id=OBJECT_ID('dbo.TBL_SETTLE_TRX') AND name='UX_SETTLE_TRX_NO')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_SETTLE_TRX_NO
        ON dbo.TBL_SETTLE_TRX (COMP_CD, TRX_GB, TRX_DT, TRX_NO)
     WHERE ACTION_YN = 'Y';
END
GO

-- ③ 판매 전표번호 — 종전에는 UNIQUE 자체가 없어(PK뿐) 중복 전표번호가 무방비였다.
--    매입·수금/지급과 같은 기준으로 신설(처음부터 필터 포함). 2026-08-05 적용.
IF NOT EXISTS (SELECT 1 FROM sys.indexes
                WHERE object_id=OBJECT_ID('dbo.TBL_SALES_TRX_MST') AND name='UX_SALES_TRX_NO')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_SALES_TRX_NO
        ON dbo.TBL_SALES_TRX_MST (COMP_CD, SALE_DT, SALE_NO)
     WHERE ACTION_YN = 'Y';
END
GO
