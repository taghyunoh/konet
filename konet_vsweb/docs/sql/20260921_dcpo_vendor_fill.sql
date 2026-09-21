/* =====================================================================
   DC 발주 출고분 매입처 채우기 (2026-09-21 — 「DC 발주 출고에 매입처 채우기」)
     · DC 발주 등록(입고예약서·발주서)으로 들어간 TBL_SHIPOUT_MST(PROD_KIND='DC') 에는 매입처가 비어 있었다.
       그래서 원가 관리·마감의 매입처별에서 「매입처 없음」으로 잡혔다.
     · 새로 저장하는 것부터는 프로그램이 상품 마스터(서브코드면 주코드 상품)의 매입처를 넣는다.
       이 파일은 <이미 들어가 있는> 줄을 같은 규칙으로 채운다.
     · 실측 2026-09-21 : 2026-09 에 품목 2개(1000805164 → 00288 (주)더세경 / 1000805165 → 00382 버개스패키지), 각 2줄.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. ① 로 대상을 먼저 확인하고 ② 를 실행. 두 번 실행해도 안전(빈 것만 채운다).
   ===================================================================== */

/* ── ① 미리 보기 — 채워질 줄 ── */
SELECT s.COMP_CD, s.DLV_DT, s.DC_NM, s.ITEM_CD, s.ITEM_NM, x.VENDOR_CD AS newVendorCd, x.VENDOR_NM AS newVendorNm
  FROM dbo.TBL_SHIPOUT_MST s
 CROSS APPLY (
        SELECT TOP 1 p.VENDOR_CD, ISNULL(p.VENDOR_NM,'') AS VENDOR_NM
          FROM dbo.TBL_PROD_MST p
         WHERE p.ACTION_YN = 'Y' AND p.COMP_CD = s.COMP_CD AND ISNULL(p.VENDOR_CD,'') <> ''
           AND ( p.PROD_CD = s.ITEM_CD
              OR p.PROD_CD IN ( SELECT e.PROD_CD FROM dbo.TBL_EXT_ITEM_MST e
                                 WHERE e.ACTION_YN = 'Y' AND e.COMP_CD = s.COMP_CD
                                   AND ( e.EXT_ITEM_CD = s.ITEM_CD OR e.ADD_ITEM_CD = s.ITEM_CD ) ) )
         ORDER BY CASE WHEN p.PROD_CD = s.ITEM_CD THEN 0 ELSE 1 END, p.PROD_SEQ DESC
      ) x
 WHERE s.ACTION_YN = 'Y' AND s.PROD_KIND = 'DC' AND ISNULL(s.VENDOR_CD,'') = ''
 ORDER BY s.DLV_DT, s.ITEM_CD;
GO

/* ── ② 채우기 ── */
UPDATE s
   SET s.VENDOR_CD = x.VENDOR_CD,
       s.VENDOR_NM = x.VENDOR_NM
  FROM dbo.TBL_SHIPOUT_MST s
 CROSS APPLY (
        SELECT TOP 1 p.VENDOR_CD, ISNULL(p.VENDOR_NM,'') AS VENDOR_NM
          FROM dbo.TBL_PROD_MST p
         WHERE p.ACTION_YN = 'Y' AND p.COMP_CD = s.COMP_CD AND ISNULL(p.VENDOR_CD,'') <> ''
           AND ( p.PROD_CD = s.ITEM_CD
              OR p.PROD_CD IN ( SELECT e.PROD_CD FROM dbo.TBL_EXT_ITEM_MST e
                                 WHERE e.ACTION_YN = 'Y' AND e.COMP_CD = s.COMP_CD
                                   AND ( e.EXT_ITEM_CD = s.ITEM_CD OR e.ADD_ITEM_CD = s.ITEM_CD ) ) )
         ORDER BY CASE WHEN p.PROD_CD = s.ITEM_CD THEN 0 ELSE 1 END, p.PROD_SEQ DESC
      ) x
 WHERE s.ACTION_YN = 'Y' AND s.PROD_KIND = 'DC' AND ISNULL(s.VENDOR_CD,'') = '';
GO

/* ── ③ 확인 — 남은 빈 줄(상품 마스터에도 매입처가 없는 것만 남는다) ── */
SELECT COUNT(*) AS stillEmpty
  FROM dbo.TBL_SHIPOUT_MST s
 WHERE s.ACTION_YN = 'Y' AND s.PROD_KIND = 'DC' AND ISNULL(s.VENDOR_CD,'') = '';
