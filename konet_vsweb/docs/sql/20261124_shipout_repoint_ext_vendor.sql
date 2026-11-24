/* ============================================================================================
   발주현황표 상품코드 바로잡기 — 거래처가 지정된 매칭코드 때문에 «주코드»가 아니라 같은 번호의 다른 상품에 붙은 줄 (2026-11-24)
   · 원인 : 매칭코드(TBL_EXT_ITEM_MST)의 거래처 = 우리 매입 거래처(예 00266) / 발주현황표 VENDOR_CD = 삼성 협력업체코드(코네트 A0223036) — 체계가 달라
            종전 업로드 해석이 거래처 지정 매칭코드를 못 써서 «코드 직결»로 붙었다. 정산서는 거래처를 안 봐 주코드로 갔다 → 두 자료 상품코드가 갈림.
   · 코드 고침 = User_SQL.xml resolveShipoutProdExt · repointShipoutProdExt (거래처로 거르지 않고 고른다). 배포(WAR 재빌드+재기동) 뒤
     [출고반영 재집계] 를 한 번 누르면 이 SQL 과 같은 일을 하고 재고 원장까지 다시 만든다 — ★보통은 그 단추로 충분하다.
   · 이 SQL 은 «배포 전에 자료만 먼저» 바로잡고 싶을 때만. 실행 뒤에도 재고를 맞추려면 [출고반영 재집계] 를 누른다.

   [2026-11-24 조회 기준] 6품목 · 사용 중(Y) 483줄 (이력 N·삭제 D 포함 전체 2,017줄)
     1000455369 → 9904012198 (Y 124)   1000455370 → 9904013345 (Y 279)   1000713438 → 1010019129 (Y 4)
     1000718241 → 9904013410 (Y 35)    1000735981 → 6010007023 (Y 11)    1000753315 → 1010042032 (Y 30)
   ============================================================================================ */

/* ① 확인 — 옮겨질 줄 (지금 코드 → 바뀔 주코드) */
SELECT s.ITEM_CD, s.PROD_CD AS 지금코드, e.PROD_CD AS 바뀔코드, s.ACTION_YN, COUNT(*) AS 줄수, MIN(s.DLV_DT) AS 처음납기, MAX(s.DLV_DT) AS 마지막납기
  FROM TBL_SHIPOUT_MST s
 CROSS APPLY ( SELECT TOP 1 e1.PROD_SEQ, e1.PROD_CD FROM TBL_EXT_ITEM_MST e1
                WHERE e1.COMP_CD = s.COMP_CD AND e1.ACTION_YN = 'Y' AND e1.PROD_SEQ IS NOT NULL AND e1.EXT_ITEM_CD = s.ITEM_CD
                ORDER BY CASE WHEN ISNULL(e1.VENDOR_CD,'') = ISNULL(s.VENDOR_CD,'') THEN 0 WHEN ISNULL(e1.VENDOR_CD,'') = '' THEN 1 ELSE 2 END, e1.EXT_SEQ DESC ) e
 WHERE s.COMP_CD = 'W1234567'
   AND s.PROD_SEQ IS NOT NULL AND e.PROD_SEQ <> s.PROD_SEQ
   AND s.PROD_CD = s.ITEM_CD                                   /* 코드 직결로 붙은 줄만 — 사람이 고른 연결은 안 건드린다 */
   AND NOT EXISTS ( SELECT 1 FROM TBL_PROD_XREF x
                     WHERE x.COMP_CD = s.COMP_CD AND x.ACTION_YN = 'Y' AND x.EXT_ITEM_CD = s.ITEM_CD
                       AND ISNULL(x.VENDOR_CD,'') IN ('', ISNULL(s.VENDOR_CD,'')) AND ISNULL(x.DC_CD,'') IN ('', ISNULL(s.DC_CD,'')) )
 GROUP BY s.ITEM_CD, s.PROD_CD, e.PROD_CD, s.ACTION_YN
 ORDER BY 1, 4 DESC;

/* ② 바로잡기 (repointShipoutProdExt 와 같은 문장) */
BEGIN TRAN;

UPDATE s
   SET s.PROD_SEQ = e.PROD_SEQ, s.PROD_CD = e.PROD_CD
  FROM TBL_SHIPOUT_MST s
 CROSS APPLY ( SELECT TOP 1 e1.PROD_SEQ, e1.PROD_CD FROM TBL_EXT_ITEM_MST e1
                WHERE e1.COMP_CD = s.COMP_CD AND e1.ACTION_YN = 'Y' AND e1.PROD_SEQ IS NOT NULL AND e1.EXT_ITEM_CD = s.ITEM_CD
                ORDER BY CASE WHEN ISNULL(e1.VENDOR_CD,'') = ISNULL(s.VENDOR_CD,'') THEN 0 WHEN ISNULL(e1.VENDOR_CD,'') = '' THEN 1 ELSE 2 END, e1.EXT_SEQ DESC ) e
 WHERE s.COMP_CD = 'W1234567'
   AND s.PROD_SEQ IS NOT NULL AND e.PROD_SEQ <> s.PROD_SEQ
   AND s.PROD_CD = s.ITEM_CD
   AND NOT EXISTS ( SELECT 1 FROM TBL_PROD_XREF x
                     WHERE x.COMP_CD = s.COMP_CD AND x.ACTION_YN = 'Y' AND x.EXT_ITEM_CD = s.ITEM_CD
                       AND ISNULL(x.VENDOR_CD,'') IN ('', ISNULL(s.VENDOR_CD,'')) AND ISNULL(x.DC_CD,'') IN ('', ISNULL(s.DC_CD,'')) );
/* 「영향 받은 행」 이 ① 합계(2026-11-24 기준 2,017)와 같으면 COMMIT, 아니면 ROLLBACK */
-- COMMIT;
-- ROLLBACK;

/* ③ 확인 — ① 을 다시 돌려 0줄 · 9/21 오산 No 193(발주 5060046017)이 9904012198 */
SELECT DLV_DT, DC_CD, ACTION_YN, ROW_NO, ITEM_CD, PROD_CD, ORD_NO
  FROM TBL_SHIPOUT_MST WHERE COMP_CD = 'W1234567' AND ORD_NO = '5060046017' AND ITEM_CD = '1000455369' AND ACTION_YN = 'Y';
