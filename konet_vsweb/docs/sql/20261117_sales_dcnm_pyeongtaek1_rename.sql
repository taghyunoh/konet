/* =====================================================================
   정산서 출고장 이름 「평택 (1)」 → 「평택」 (2026-11-17 사용자 「출고장도 평택으로」)

   상황 : 11-05 납품 평택 정산서 중복 정리(20261116_sales_dup_pyeongtaek_1105.sql) 뒤
          남은 54줄의 출고장 이름이 파일 이름 그대로 「평택 (1)」이다
          (파일 2026.11.05_평택 (1).xlsx — 브라우저가 같은 이름 파일을 받을 때 붙인 꼬리).
          출고장 코드(DC_CD)는 이미 평택과 같은 E500 이라 재고·정산은 맞다 — **이름만** 고친다.
   확인 (2026-11-17 읽기 전용 조회) : 「(1)」 꼬리는 TBL_SALES_MST 의 이 54줄뿐
          (TBL_DC_MST · TBL_EXT_ITEM_MST · TBL_SHIPOUT_MST 0건).
   재고 : 원장은 출고장 이름을 쓰지 않는다 — [출고반영 재집계] 다시 누를 필요 없음.

   실행 순서 : ① 확인 → ② 백업 → ③ 고치기 → ④ 확인.  되돌리기는 맨 아래.
   ===================================================================== */

-- ① 확인 (기대 : 평택 (1) · E500 · 54줄 · 16,993,539)
SELECT DC_NM, DC_CD, ACTION_YN, COUNT(*) AS 줄, SUM(SALE_AMT) AS 금액
  FROM TBL_SALES_MST
 WHERE DC_NM = N'평택 (1)'
 GROUP BY DC_NM, DC_CD, ACTION_YN;

-- ② 백업 (이미 있으면 건너뛴다)
IF OBJECT_ID('dbo.BAK_20261117_SALES_PT1NM', 'U') IS NULL
  SELECT SALES_SEQ, DC_NM, UPD_DTTM, UPD_USER, UPD_IP
    INTO dbo.BAK_20261117_SALES_PT1NM
    FROM TBL_SALES_MST
   WHERE DC_NM = N'평택 (1)';
-- 기대 : 54개 행

-- ③ 고치기
BEGIN TRAN;

UPDATE TBL_SALES_MST
   SET DC_NM    = N'평택',
       UPD_DTTM = CONVERT(VARCHAR(19), GETDATE(), 120),
       UPD_USER = 'fix20261117',
       UPD_IP   = 'sql-dcnm-pt1'
 WHERE DC_NM = N'평택 (1)';
-- 기대 : (54개 행 적용됨) — 아니면 아래 ROLLBACK

COMMIT;
-- ROLLBACK;

-- ④ 확인 — 「평택 (1)」 0줄, 11-05 평택(사용) 54줄 · 16,993,539
SELECT COUNT(*) AS 남은_꼬리 FROM TBL_SALES_MST WHERE DC_NM = N'평택 (1)';
SELECT DC_NM, DC_CD, COUNT(*) AS 줄, SUM(SALE_AMT) AS 금액
  FROM TBL_SALES_MST
 WHERE ACTION_YN = 'Y' AND ISNULL(NULLIF(DLV_DT, ''), OUT_DT) = '20261105' AND DC_NM LIKE N'평택%'
 GROUP BY DC_NM, DC_CD;

/* ── 되돌리기(필요할 때만) ─────────────────────────────────────────
UPDATE m SET m.DC_NM = b.DC_NM, m.UPD_DTTM = b.UPD_DTTM, m.UPD_USER = b.UPD_USER, m.UPD_IP = b.UPD_IP
  FROM TBL_SALES_MST m JOIN dbo.BAK_20261117_SALES_PT1NM b ON b.SALES_SEQ = m.SALES_SEQ;
──────────────────────────────────────────────────────────────────── */
