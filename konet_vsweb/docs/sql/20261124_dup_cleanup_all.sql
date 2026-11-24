/* 두 번 들어간 정산서·발주현황표 줄 정리 — 전체 기간 (2026-11-24 사용자 「4월뿐만 아니라 전체 확인」)
   원인 : 파일 여러 개를 한 번에 저장하면 (날짜+출고장) 묶음 안에서 «파일끼리» 겹친 줄을 거르지 않았다 → 같은 날을 담은 두 파일을 함께 올린 날이 통째로 두 번.
          (서버 수정 = UserController saveSalesMst · saveShipoutMst 의 salesDupKey · shipDupKey — 재기동 뒤부터 안 생긴다)
   조회 결과(2026-11-24, 정산서 2026-01-01~11-24 35,896줄 · 발주현황표 전체) — 아래 세 묶음뿐이다 :
     ① 정산서 김해 4/21~4/30      76줄 · 2,938,476원 (2026.08.23_김해.xlsx = 2026.08.24_김해.xlsx 와 같은 줄)
     ② 정산서 10/03·10/05 「광주」 6줄 ·   885,994원 (2026.10.07_광주.xlsx 안의 6줄이 2026.10.07_왜관.xlsx 와 똑같다 — 발주번호 5060199371·5060200120 은 왜관 발주(발주현황표 확인).
                                                    광주 파일에 왜관 자료가 들어 있었다. 그 광주 파일에는 이 6줄뿐 — 내려도 광주 정산서가 없어지는 날은 없다)
     ③ 발주현황표 1/8 · 3/24 · 7/17 · 10/13  786줄 · 수량 936 (8.xlsx=9.xlsx · 24=25 · 17=18 · 2026.10.12_23.31.11=23.31.22)
        — 네 날 모두 정산서가 있어 재고에는 영향이 없었다(정산서 온 날은 정산서로 셈). 월별 출고현황 칸 · 매출마감 수량 · 정산실적 발주현황표 칸만 두 배였다.
   처리 : 겹친 쪽(위 괄호의 앞 파일 · ②는 광주 파일)만 ACTION_YN='N' — 짝이 살아 있을 때만. 되돌리기 = UPD_USER 'dupfix20261124'.
   실행 뒤 : [🔄 출고반영 재집계] 한 번 (마감 확정은 202601 만 — 그달은 해당 없음).
   ⚠DB 쓰기 — 사용자가 직접 실행. 각 묶음의 미리보기 건수가 위와 같은지 먼저 본다. */

-- ① 정산서 김해 4/21~4/30 ------------------------------------------------------------
SELECT COUNT(*) AS 줄, SUM(a.SALE_AMT) AS 금액    -- 기대 76 · 2,938,476
  FROM TBL_SALES_MST a
 WHERE a.ACTION_YN = 'Y' AND a.DC_NM = N'김해' AND a.SRC_FILE = N'2026.08.23_김해.xlsx' AND a.DLV_DT BETWEEN '20260421' AND '20260430'
   AND EXISTS ( SELECT 1 FROM TBL_SALES_MST b WHERE b.ACTION_YN = 'Y' AND b.COMP_CD = a.COMP_CD AND b.DC_NM = a.DC_NM AND b.DLV_DT = a.DLV_DT
                   AND b.SRC_FILE = N'2026.08.24_김해.xlsx' AND ISNULL(b.ORD_NO,'') = ISNULL(a.ORD_NO,'') AND ISNULL(b.ORD_ITEM_NO,'') = ISNULL(a.ORD_ITEM_NO,'') AND ISNULL(b.ITEM_CD,'') = ISNULL(a.ITEM_CD,'') );

-- ② 정산서 광주 파일 안의 왜관 자료 ---------------------------------------------------------
SELECT COUNT(*) AS 줄, SUM(a.SALE_AMT) AS 금액    -- 기대 6 · 885,994
  FROM TBL_SALES_MST a
 WHERE a.ACTION_YN = 'Y' AND a.DC_NM = N'광주' AND a.SRC_FILE = N'2026.10.07_광주.xlsx' AND a.DLV_DT IN ('20261003','20261005')
   AND EXISTS ( SELECT 1 FROM TBL_SALES_MST b WHERE b.ACTION_YN = 'Y' AND b.COMP_CD = a.COMP_CD AND b.DC_NM = N'왜관' AND b.DLV_DT = a.DLV_DT
                   AND b.SRC_FILE = N'2026.10.07_왜관.xlsx' AND ISNULL(b.ORD_NO,'') = ISNULL(a.ORD_NO,'') AND ISNULL(b.ORD_ITEM_NO,'') = ISNULL(a.ORD_ITEM_NO,'') AND ISNULL(b.ITEM_CD,'') = ISNULL(a.ITEM_CD,'')
                   AND ISNULL(b.OUT_QTY,0) = ISNULL(a.OUT_QTY,0) AND ISNULL(b.SALE_AMT,0) = ISNULL(a.SALE_AMT,0) );

-- ③ 발주현황표 네 날 ---------------------------------------------------------------------
SELECT a.DLV_DT, COUNT(*) AS 줄, SUM(a.LABEL_QTY) AS 수량   -- 기대 0108 168/189 · 0324 195/252 · 0717 233/285 · 1013 190/210
  FROM TBL_SHIPOUT_MST a
 WHERE a.ACTION_YN = 'Y' AND ISNULL(a.PROD_KIND,'') <> 'TD'
   AND (   (a.DLV_DT = '20260108' AND a.SRC_FILE = N'9.xlsx')
        OR (a.DLV_DT = '20260324' AND a.SRC_FILE = N'25.xlsx')
        OR (a.DLV_DT = '20260717' AND a.SRC_FILE = N'18.xlsx')
        OR (a.DLV_DT = '20261013' AND a.SRC_FILE = N'2026.10.12_23.31.11.xlsx') )
   AND EXISTS ( SELECT 1 FROM TBL_SHIPOUT_MST b
                 WHERE b.ACTION_YN = 'Y' AND b.COMP_CD = a.COMP_CD AND b.DLV_DT = a.DLV_DT AND b.SEQ <> a.SEQ
                   AND b.SRC_FILE = CASE a.DLV_DT WHEN '20260108' THEN N'8.xlsx' WHEN '20260324' THEN N'24.xlsx' WHEN '20260717' THEN N'17.xlsx' ELSE N'2026.10.12_23.31.22.xlsx' END
                   AND ISNULL(b.DC_CD,'') = ISNULL(a.DC_CD,'') AND ISNULL(b.ORD_NO,'') = ISNULL(a.ORD_NO,'') AND ISNULL(b.ORD_ITEM_NO,'') = ISNULL(a.ORD_ITEM_NO,'')
                   AND ISNULL(b.BIZ_CD,'') = ISNULL(a.BIZ_CD,'') AND ISNULL(b.ITEM_CD,'') = ISNULL(a.ITEM_CD,'')
                   AND ISNULL(b.LABEL_QTY,-1) = ISNULL(a.LABEL_QTY,-1) AND ISNULL(b.CUR_QTY,-1) = ISNULL(a.CUR_QTY,-1)
                   AND ISNULL(b.JUMUN_NO,'') = ISNULL(a.JUMUN_NO,'') AND ISNULL(b.JUMUN_ITEM_NO,'') = ISNULL(a.JUMUN_ITEM_NO,'') )
 GROUP BY a.DLV_DT;

-- ===== 내리기 (트랜잭션 — 세 줄 수가 76 · 6 · 786 이면 COMMIT, 아니면 ROLLBACK) =====
BEGIN TRAN;

UPDATE a SET a.ACTION_YN = 'N', a.UPD_DTTM = CONVERT(varchar(19), GETDATE(), 120), a.UPD_USER = 'dupfix20261124'
  FROM TBL_SALES_MST a
 WHERE a.ACTION_YN = 'Y' AND a.DC_NM = N'김해' AND a.SRC_FILE = N'2026.08.23_김해.xlsx' AND a.DLV_DT BETWEEN '20260421' AND '20260430'
   AND EXISTS ( SELECT 1 FROM TBL_SALES_MST b WHERE b.ACTION_YN = 'Y' AND b.COMP_CD = a.COMP_CD AND b.DC_NM = a.DC_NM AND b.DLV_DT = a.DLV_DT
                   AND b.SRC_FILE = N'2026.08.24_김해.xlsx' AND ISNULL(b.ORD_NO,'') = ISNULL(a.ORD_NO,'') AND ISNULL(b.ORD_ITEM_NO,'') = ISNULL(a.ORD_ITEM_NO,'') AND ISNULL(b.ITEM_CD,'') = ISNULL(a.ITEM_CD,'') );
SELECT @@ROWCOUNT AS [① 76];

UPDATE a SET a.ACTION_YN = 'N', a.UPD_DTTM = CONVERT(varchar(19), GETDATE(), 120), a.UPD_USER = 'dupfix20261124'
  FROM TBL_SALES_MST a
 WHERE a.ACTION_YN = 'Y' AND a.DC_NM = N'광주' AND a.SRC_FILE = N'2026.10.07_광주.xlsx' AND a.DLV_DT IN ('20261003','20261005')
   AND EXISTS ( SELECT 1 FROM TBL_SALES_MST b WHERE b.ACTION_YN = 'Y' AND b.COMP_CD = a.COMP_CD AND b.DC_NM = N'왜관' AND b.DLV_DT = a.DLV_DT
                   AND b.SRC_FILE = N'2026.10.07_왜관.xlsx' AND ISNULL(b.ORD_NO,'') = ISNULL(a.ORD_NO,'') AND ISNULL(b.ORD_ITEM_NO,'') = ISNULL(a.ORD_ITEM_NO,'') AND ISNULL(b.ITEM_CD,'') = ISNULL(a.ITEM_CD,'')
                   AND ISNULL(b.OUT_QTY,0) = ISNULL(a.OUT_QTY,0) AND ISNULL(b.SALE_AMT,0) = ISNULL(a.SALE_AMT,0) );
SELECT @@ROWCOUNT AS [② 6];

UPDATE a SET a.ACTION_YN = 'N', a.UPD_DTTM = CONVERT(varchar(19), GETDATE(), 120), a.UPD_USER = 'dupfix20261124'
  FROM TBL_SHIPOUT_MST a
 WHERE a.ACTION_YN = 'Y' AND ISNULL(a.PROD_KIND,'') <> 'TD'
   AND (   (a.DLV_DT = '20260108' AND a.SRC_FILE = N'9.xlsx')
        OR (a.DLV_DT = '20260324' AND a.SRC_FILE = N'25.xlsx')
        OR (a.DLV_DT = '20260717' AND a.SRC_FILE = N'18.xlsx')
        OR (a.DLV_DT = '20261013' AND a.SRC_FILE = N'2026.10.12_23.31.11.xlsx') )
   AND EXISTS ( SELECT 1 FROM TBL_SHIPOUT_MST b
                 WHERE b.ACTION_YN = 'Y' AND b.COMP_CD = a.COMP_CD AND b.DLV_DT = a.DLV_DT AND b.SEQ <> a.SEQ
                   AND b.SRC_FILE = CASE a.DLV_DT WHEN '20260108' THEN N'8.xlsx' WHEN '20260324' THEN N'24.xlsx' WHEN '20260717' THEN N'17.xlsx' ELSE N'2026.10.12_23.31.22.xlsx' END
                   AND ISNULL(b.DC_CD,'') = ISNULL(a.DC_CD,'') AND ISNULL(b.ORD_NO,'') = ISNULL(a.ORD_NO,'') AND ISNULL(b.ORD_ITEM_NO,'') = ISNULL(a.ORD_ITEM_NO,'')
                   AND ISNULL(b.BIZ_CD,'') = ISNULL(a.BIZ_CD,'') AND ISNULL(b.ITEM_CD,'') = ISNULL(a.ITEM_CD,'')
                   AND ISNULL(b.LABEL_QTY,-1) = ISNULL(a.LABEL_QTY,-1) AND ISNULL(b.CUR_QTY,-1) = ISNULL(a.CUR_QTY,-1)
                   AND ISNULL(b.JUMUN_NO,'') = ISNULL(a.JUMUN_NO,'') AND ISNULL(b.JUMUN_ITEM_NO,'') = ISNULL(a.JUMUN_ITEM_NO,'') );
SELECT @@ROWCOUNT AS [③ 786];

-- COMMIT;
-- ROLLBACK;

-- ===== 확인 — 둘 다 0 이어야 한다 =====
SELECT COUNT(*) AS 정산서겹침 FROM ( SELECT 1 x FROM TBL_SALES_MST WHERE ACTION_YN = 'Y' AND ISNULL(ORD_NO,'') <> ''
   GROUP BY COMP_CD, DLV_DT, ORD_NO, ORD_ITEM_NO, ITEM_CD, ISNULL(DLV_TYPE,'') HAVING COUNT(*) > 1 ) t;
SELECT COUNT(*) AS 발주현황표겹침 FROM ( SELECT 1 x FROM TBL_SHIPOUT_MST WHERE ACTION_YN = 'Y' AND ISNULL(PROD_KIND,'') <> 'TD'
   GROUP BY COMP_CD, DLV_DT, ORD_NO, ORD_ITEM_NO, BIZ_CD, ITEM_CD, LABEL_QTY, JUMUN_NO, JUMUN_ITEM_NO, DC_CD HAVING COUNT(*) > 1 ) t;

-- 되돌리기 : UPDATE TBL_SALES_MST SET ACTION_YN='Y' WHERE UPD_USER='dupfix20261124';
--            UPDATE TBL_SHIPOUT_MST SET ACTION_YN='Y' WHERE UPD_USER='dupfix20261124';
