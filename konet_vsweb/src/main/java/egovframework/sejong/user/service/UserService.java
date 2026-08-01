package egovframework.sejong.user.service;

import java.util.List;
import java.util.Map;

import egovframework.sejong.user.model.CompConDTO;
import egovframework.sejong.user.model.CompMdDTO;
import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;

public interface UserService {

	// ===== 회사/계약/사용자 관리 (compcd.jsp) =====
	List<CompMdDTO> selCompCdList(CompMdDTO dto) throws Exception;
	String CompCdMstDupChk(CompMdDTO dto) throws Exception;
	int insertCompCdMst(CompMdDTO dto) throws Exception;
	int updateCompCdMst(CompMdDTO dto) throws Exception;

	List<CompConDTO> selectCompContList(CompConDTO dto) throws Exception;
	List<CompConDTO> getCompContList(CompConDTO dto) throws Exception;
	String CompContDupChk(CompConDTO dto) throws Exception;
	int insertCompCont(CompConDTO dto) throws Exception;
	int updateCompCont(CompConDTO dto) throws Exception;

	List<java.util.Map<String,Object>> selectCommCodeList(java.util.Map<String,Object> param) throws Exception;

	// ===== 출고장(발주현황표) 업로드 저장 (TBL_SHIPOUT_MST) =====
	java.util.List<String> selectShipoutActiveShpoutDts(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;  // 이력마감 전 (납품일자+물류센터) 활성배치의 출고일자 — 재고연동용
	int markShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	int deleteShipoutZone(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;   // 출고장+출고일자 활성분 소프트 삭제
	int getShipoutNextJobSeq(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	int insertShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutPrev(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistAll(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	/* 발주현황표 업로드 이력 — 출고현황이력조회 (2026-07-25) */
	java.util.List<java.util.Map<String,Object>> selectSalesChart(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;        /* 매출 그래프 — 월별·출고장별 (2026-07-25) */
	java.util.List<java.util.Map<String,Object>> selectSalesChartDaily(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;   /* 매출 그래프 — 일자별. 월별과 따로 둔다 */
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadHist(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadDtl(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutSrcFiles() throws Exception;   // 이미 업로드(반영)된 원본 파일명 목록

	// ===== 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 (TBL_SALES_MST) =====
	int markSalesHistory(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int getSalesNextJobSeq(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int insertSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesSrcFiles() throws Exception;

	// 출고장 정정(2026-07-27) — 반환: 바뀐 행수. 키가 겹치면 -1(정정 불가, 화면에서 안내)
	int renameSalesDc(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int mergeSalepriceFromSales(egovframework.sejong.user.model.SalesDTO dto) throws Exception;   // 매출 엑셀 판매단가 → 판매가 이력 upsert

	// ===== 거래처 마스터 (TBL_VENDOR_MST) =====
	java.util.List<egovframework.sejong.user.model.VendorDTO> selectVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int vendorDupChk(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int insertVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int updateVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int deleteVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int mergeVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;

	// ===== 사업장 분류 마스터 (TBL_BIZI_MST) =====
	java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziMst() throws Exception;
	int insertBiziIfAbsent(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int updateBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int deleteBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	// ===== 거래처관리(사업장) CRUD =====
	java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziList(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int biziDupChk(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int insertBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int updateBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int deleteBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	// ===== 수금/미수금 =====
	java.util.List<egovframework.sejong.user.model.ReceiveDTO> selectReceiveList(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;
	int insertReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;
	int updateReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;
	int deleteReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;
	int upsertReceiveList(java.util.List<egovframework.sejong.user.model.ReceiveDTO> rows, String regUser, String regIp) throws Exception; // 엑셀업로드 일괄
	int carryForwardReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception; // 전월 미수잔액 → 당월 전월이월

	// ===== 출금/미지급 (TBL_PAYMENT_MST) =====
	java.util.List<egovframework.sejong.user.model.PaymentDTO> selectPaymentList(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;
	int insertPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;
	int updatePayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;
	int deletePayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;
	int upsertPaymentList(java.util.List<egovframework.sejong.user.model.PaymentDTO> rows, String regUser, String regIp) throws Exception; // 엑셀업로드 일괄
	int carryForwardPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception; // 전월 미지급잔액 → 당월 전월이월

	// ===== 정산 마감(수금/출금 월 확정·잠금·자동이월) =====
	egovframework.sejong.user.model.SettleCloseDTO selectSettleClose(String settleGb, String ym) throws Exception;
	int confirmSettleClose(String settleGb, String ym, String user) throws Exception; // 확정: 다음달 전월이월 자동반영 + 잠금
	int cancelSettleClose(String settleGb, String ym, String user) throws Exception;  // 해제: 잠금 풀기

	// ===== 상품마스터 (TBL_PROD_MST) =====
	java.util.List<egovframework.sejong.user.model.ProdDTO> selectProdList(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int insertProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int updateProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int deleteProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int countProdRelated(egovframework.sejong.user.model.ProdDTO dto) throws Exception;   // 연관(매입가/판매가/재고) 활성건수

	// ===== 매입가 이력 =====
	java.util.List<egovframework.sejong.user.model.ProdInpriceDTO> selectInpriceList(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception;
	int insertInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception;   // 이력 INSERT + 마스터 IN_PRICE 동기화
	int deleteInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception;

	/* ===== 거래처별 품목 표기(교차참조) — TBL_PROD_XREF (2026-08-01) ===== */
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefList(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectUnmappedItems(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefCandidates(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefAudit(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;  // 매핑 점검 리포트
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefNames(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;  // 그 거래처로 나갈 때 쓸 품명(품목당 1건)
	int saveXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;    // 등록/수정 + 대표표기 정리 + 소급 반영
	int confirmXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int deleteXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int resolveSalesProd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;

	// ===== 판매가 이력 =====
	java.util.List<egovframework.sejong.user.model.ProdSalepriceDTO> selectSalepriceList(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception;
	int insertSaleprice(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception; // 이력 INSERT + 마스터 SALE/WHOLE 동기화
	int deleteSaleprice(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception;

	// ===== 재고 수불 / 현황 =====
	java.util.List<egovframework.sejong.user.model.StockLedgerDTO> selectStockLedgerList(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;
	egovframework.sejong.user.model.StockMstDTO selectStockMst(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;
	int insertStockLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception; // 원장 INSERT + 현재고 재집계
	int deleteStockLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception; // 원장 삭제 + 현재고 재집계
	java.util.List<egovframework.sejong.user.model.StockMstDTO> selectStockMstList(egovframework.sejong.user.model.StockMstDTO dto) throws Exception; // 재고현황(전체 현재고)
	java.util.List<egovframework.sejong.user.model.StockLedgerDTO> selectInboundList(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception; // 입고내역
	// (A) 출고(SHIPOUT)→원장 자동연동
	int syncShipoutLedgerDate(String shpoutDt, String regUser, String regIp) throws Exception; // 출고일자별 O행 재동기화(마감월이면 skip)
	int recalcStockMstAll(String regUser, String regIp) throws Exception;                       // 전체 현재고 재집계
	int rebuildShipoutLedgerAll(String regUser, String regIp) throws Exception;                 // 전체 출고→원장 재동기화+재집계(화면 버튼)
	java.util.List<String> selectClosedYmList() throws Exception;                                // 마감 확정월 목록(재집계 팝업 표시용)

	// ===== 마감 집계 =====
	java.util.List<egovframework.sejong.user.model.ClosingDTO> selectClosing(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ClosingDTO> selectClosingUnmatched(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.StockClosingDTO> selectStockClosing(egovframework.sejong.user.model.StockClosingDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.StockClosingDTO> selectInboundClosing(egovframework.sejong.user.model.StockClosingDTO dto) throws Exception;

	// ===== 마감 확정/해제/조회 =====
	egovframework.sejong.user.model.ClosingMstDTO selectClosingMst(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ClosingMstDTO> selectClosingMstList(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception;
	int confirmClosing(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception; // 집계+헤더+재고스냅샷 저장(확정)
	int cancelClosing(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception;  // 확정 해제

	// ===== 공통코드 관리 (codecd.jsp) =====
	List<egovframework.sejong.user.model.CodeMdDTO> codeMstList(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	String codeMstDupChk(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int insertCodeMst(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int updateCodeMst(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	List<egovframework.sejong.user.model.CodeMdDTO> codeDtlList(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	String codeDtlDupChk(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int insertCodeDtl(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int updateCodeDtl(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;

	List<UserDTO> compUserList(UserDTO dto) throws Exception;
	int insertCompUser(UserDTO dto) throws Exception;
	int updateCompUser(UserDTO dto) throws Exception;
	String CompUserDupChk(UserDTO dto) throws Exception;
	String CompUseridDupChk(UserDTO dto) throws Exception;
	UserDTO userLoginCheck(UserDTO dto) throws Exception;

	/** KOLGSDB 로그인: COMP_CD + USER_ID 로 최신 활성 사용자 1건 조회 */
	UserDTO compLoginCheck(UserDTO dto) throws Exception;

	/** KOLGSDB 비밀번호 변경/초기화용 현재 정보 조회 */
	UserDTO compUserInfo(UserDTO dto) throws Exception;

	/** KOLGSDB 비밀번호 갱신 (변경/초기화 공용) */
	int compPwdUpdate(UserDTO dto) throws Exception;

	UserDTO userInfo(UserDTO dto) throws Exception;

	boolean userPwdReset(UserDTO dto) throws Exception;

	boolean userPwdChange(UserDTO dto) throws Exception;

	/** 약관 본문 조회 (T_SIGN_MST) */
	List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception;

	/** termsGb 의 가장 최신 USE_YN='Y' termsSeq */
	String selectLatestTermsSeq(String termsGb) throws Exception;

	/** 동의이력 1건 저장 (T_PERSIGN_TRAN) */
	int insertPersign(PersignDTO dto) throws Exception;

	/**
	 * 가입 시 termsGb 1/2/3 에 대해 각각 최신 termsSeq 를 lookup 하여 T_PERSIGN_TRAN 에 INSERT.
	 * @param userUuid 가입 직후 생성된 사용자 UUID
	 * @param regId    감사 ID (보통 userUuid 또는 시스템)
	 * @return 실제 INSERT 된 row 수 (정상이면 3)
	 */
	int saveAllPatientAgreements(String userUuid, String regId) throws Exception;

	/* ===== 매입등록 — 2026-07-25 ===== */
	java.util.List<egovframework.sejong.user.model.PurchaseDTO> selectPurchaseList(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	egovframework.sejong.user.model.PurchaseDTO selectPurchaseOne(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	String selectPurchaseNextNo(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	/** 전표 저장(신규/수정) — 헤더·명세 + 파생 재고원장 + 매입단가 이력을 한 번에 */
	int savePurchase(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	int deletePurchase(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	Double selectVendorLastPrice(egovframework.sejong.user.model.PurchaseDtlDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.PurchaseDtlDTO> selectPurchasePriceHist(egovframework.sejong.user.model.PurchaseDtlDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectPurchaseLedger(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	/* ===== 수금/지급 등록 (TBL_SETTLE_TRX) — 2026-07-25 ===== */
	java.util.List<egovframework.sejong.user.model.SettleTrxDTO> selectSettleList(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;
	String selectSettleNextNo(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;
	int insertSettleTrx(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;
	int updateSettleTrx(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;
	int deleteSettleTrx(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectCustLedger(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectCustBalance(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;   /* 거래처별 받을금액/지급할금액 — 전 거래처 × 월 (2026-07-26) */
	java.util.List<java.util.Map<String,Object>> selectCustDayDetail(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception; /* 위 화면 하단 — 한 거래처의 특정일자 하루 건별 내역(출고·매입·입금·출금) (2026-07-27) */
	java.util.List<java.util.Map<String,Object>> selectDayBook(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception;       /* 일계장 — 하루치 거래처별 매출·매입·수금·지급 (2026-07-26) */

	/* ===== 판매등록 — 2026-07-25 ===== */
	java.util.List<egovframework.sejong.user.model.SalesTrxDTO> selectSalesTrxList(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	egovframework.sejong.user.model.SalesTrxDTO selectSalesTrxOne(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	String selectSalesTrxNextNo(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	int saveSalesTrx(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	int deleteSalesTrx(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	Double selectCustLastPrice(egovframework.sejong.user.model.SalesTrxDtlDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesTrxDtlDTO> selectSalesPriceHist(egovframework.sejong.user.model.SalesTrxDtlDTO dto) throws Exception;
	/** 매출내역 화면에 얹을 판매전표 명세 — 정산서 행과 같은 모양 */
	java.util.List<java.util.Map<String,Object>> selectSalesTrxHist(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;

	/* ===== 납품분(그 거래처에 나간 품목) / 납품분 제외 — 2026-07-31 ===== */
	java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectSalesDlvList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectPurchDlvList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectSalesDlvExclList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
	/** 납품분 제외 켜기/끄기 — dto.actionYn 'Y' 제외 / 'N' 해제. 처리한 품목 수를 돌려준다 */
	int saveSalesDlvExcl(egovframework.sejong.user.model.SalesDlvDTO dto, java.util.List<String> prodCds) throws Exception;
}
