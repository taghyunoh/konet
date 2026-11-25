-- 판매전표 2024-04-11 / 0001 (주)더세경 (SALE_SEQ 181) — 「지운 사람」이 merge20261110 으로 보이던 것 (2026-11-25)
-- 까닭 : 이 전표는 2026-11-10 16:19:42 에 마스터(admin)가 지웠다(명세 줄에 그렇게 남아 있다).
--        그 뒤 17:43:54 에 돌린 거래처 병합 SQL(20261110_vendor_merge_00355_to_00288.sql)이 «지운 전표의 머리»까지
--        거래처코드를 바꾸면서 고친 때·사람을 merge20261110 으로 덮어썼다.
-- [🗑 삭제 전표] 창은 프로그램이 명세의 때·사람을 읽도록 고쳤다(재기동 뒤). 아래는 머리 값 자체를 되돌려
-- 품목 판매이력 · 수불 내역의 「삭제된 출고」 줄에서도 같은 값이 보이게 하는 것 — 돌리지 않아도 재고·금액은 달라지지 않는다.

-- ① 확인 (1줄 : merge20261110 / 2026-11-10 17:43:54)
SELECT SALE_SEQ, SALE_DT, SALE_NO, CUST_NM, ACTION_YN, UPD_DTTM, UPD_USER
  FROM TBL_SALES_TRX_MST WHERE SALE_SEQ = 181;
SELECT DTL_SEQ, ACTION_YN, UPD_DTTM, UPD_USER FROM TBL_SALES_TRX_DTL WHERE SALE_SEQ = 181;

-- ② 고치기 (1줄)
UPDATE TBL_SALES_TRX_MST
   SET UPD_DTTM = '2026-11-10 16:19:42', UPD_USER = 'admin'
 WHERE SALE_SEQ = 181 AND ACTION_YN = 'N' AND UPD_USER = 'merge20261110';

-- ③ 확인 (admin / 2026-11-10 16:19:42)
SELECT SALE_SEQ, UPD_DTTM, UPD_USER FROM TBL_SALES_TRX_MST WHERE SALE_SEQ = 181;
