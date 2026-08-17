/* ======================================================================
   TBL_PROD_MST — 「거래처」 칸 신설 (2026-08-17)

   [왜] 상품코드 등록 창에서 **이 상품의 거래처를 기록**하려는데 저장할 자리가 없었다.
        · TBL_PROD_MST 에는 거래처 칸이 **아예 없었다**(29개 컬럼 실측 확인)
        · 거래처는 TBL_EXT_ITEM_MST(거래처코드 매칭)에만 있었고, 그 표는
          `EXT_ITEM_CD` 가 **NOT NULL** 이라 ***코드 없이 거래처만 등록할 수 없다.***
        ⇒ 「거래처만 등록」을 하려면 상품마스터에 칸이 있어야 한다 → 이 스크립트.

   [무엇] VENDOR_CD(코드) + VENDOR_NM(이름)을 함께 둔다.
        ★이름까지 두는 이유 : 목록·엑셀에서 **조인 없이 바로 보여 주려는 것**이다.
          거래처명이 바뀌면 이 값은 옛 이름으로 남는다 — 「그때 그 이름」이라 오히려 자료로 맞다.
          지금 이름이 필요하면 화면이 거래처 목록(VEN)에서 코드로 찾아 쓰면 된다.

   [구분] 이 칸은 **거래처코드 매칭(TBL_EXT_ITEM_MST)과 다른 것**이다.
        · 여기(VENDOR_CD)      = 「이 상품을 주로 대는 거래처」 — 사람이 보는 정보
        · TBL_EXT_ITEM_MST   = 「거래처가 부르는 코드 ↔ 우리 상품코드」 — 매입 자료를 잡는 열쇠
        ***섞지 말 것.*** 매입 매칭은 여전히 코드가 있어야 동작한다.

   ⚠되돌리기 : 아래 ROLLBACK 절 참고(기본값 제약이 없어 컬럼만 지우면 된다).
   ====================================================================== */

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME='TBL_PROD_MST' AND COLUMN_NAME='VENDOR_CD')
  ALTER TABLE TBL_PROD_MST ADD VENDOR_CD nvarchar(20) NULL;
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME='TBL_PROD_MST' AND COLUMN_NAME='VENDOR_NM')
  ALTER TABLE TBL_PROD_MST ADD VENDOR_NM nvarchar(100) NULL;
GO

/* 확인 */
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME='TBL_PROD_MST' AND COLUMN_NAME IN ('VENDOR_CD','VENDOR_NM');
GO

/* ── ROLLBACK (되돌릴 때만) ─────────────────────────────────────────────
ALTER TABLE TBL_PROD_MST DROP COLUMN VENDOR_CD;
ALTER TABLE TBL_PROD_MST DROP COLUMN VENDOR_NM;
   ───────────────────────────────────────────────────────────────────── */
