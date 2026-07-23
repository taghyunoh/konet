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
	int markShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	int deleteShipoutZone(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;   // 출고장+출고일자 활성분 소프트 삭제
	int getShipoutNextJobSeq(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	int insertShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutPrev(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistAll(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutSrcFiles() throws Exception;   // 이미 업로드(반영)된 원본 파일명 목록

	// ===== 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 (TBL_SALES_MST) =====
	int markSalesHistory(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int getSalesNextJobSeq(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int insertSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesSrcFiles() throws Exception;
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
}