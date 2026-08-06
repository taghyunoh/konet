package egovframework.sejong.user.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.user.model.CompConDTO;
import egovframework.sejong.user.model.CompMdDTO;
import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;


@Mapper("UserMapper")
public interface UserMapper {

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
	int deleteShipoutZone(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;   // 출고장(DC_CD+INWH)+출고일자 활성분 소프트 삭제(ACTION_YN='D')
	int getShipoutNextJobSeq(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	int insertShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutPrev(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistAll(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	/* 발주현황표 업로드 이력 — 출고현황이력조회 화면 (2026-07-25). 배치 단위 집계 + 배치 명세 */
	java.util.List<java.util.Map<String,Object>> selectSalesChart(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;        /* 매출 그래프 — 월별·출고장별 (2026-07-25) */
	java.util.List<java.util.Map<String,Object>> selectSalesChartDaily(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;   /* 매출 그래프 — 일자별. 월별과 따로 둔다 */
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadHist(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadDtl(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutSrcFiles() throws Exception;   // 이미 업로드(반영)된 원본 파일명 목록 — 폴더 업로드 화면 '이미 반영' 표시용

	// ===== 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 (TBL_SALES_MST) =====
	int markSalesHistory(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int getSalesNextJobSeq(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int insertSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesSrcFiles() throws Exception;

	// 출고장 정정(2026-07-27) — 잘못 저장된 DC_NM 을 바로잡는다. 옮겨갈 이름에 활성배치가 이미 있으면 막는다
	int countSalesDcConflict(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int updateSalesDcNm(egovframework.sejong.user.model.SalesDTO dto) throws Exception;
	int mergeSalepriceFromSales(egovframework.sejong.user.model.SalesDTO dto) throws Exception;   // 매출 엑셀 판매단가 → TBL_PROD_SALEPRICE_HST upsert (APPLY_DT=발주일자)

	// ===== 거래처 마스터 (TBL_VENDOR_MST) — TBL_BIZI_MST(사업장)와 별개 =====
	java.util.List<egovframework.sejong.user.model.VendorDTO> selectVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectVendorTrxSum(egovframework.sejong.user.model.VendorDTO dto) throws Exception;   // 최근 6개월 거래처별 매출·매입 합계 (거래처 팝업 정렬용)
	int vendorDupChk(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int insertVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int updateVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;
	int deleteVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;   // 소프트 삭제(ACTION_YN='N')
	int mergeVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception;    // 거래처리스트.xls 재업로드 upsert

	// ===== 사업장 분류 마스터 (TBL_BIZI_MST) =====
	java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziMst() throws Exception;
	int insertBiziIfAbsent(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int updateBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int updateBiziParcel(egovframework.sejong.user.model.BiziDTO dto) throws Exception; /* 택배 정보(주소·전화·운임)만 저장 (2026-08-06) */
	java.util.List<java.util.Map<String,Object>> selectParcelOutList(java.util.Map<String,Object> p) throws Exception; /* 택배출고관리 — 출고일자 직송 목록 (2026-08-06) */
	int deleteBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	// ===== 거래처관리(사업장) CRUD — TBL_BIZI_MST =====
	java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziList(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int biziDupChk(egovframework.sejong.user.model.BiziDTO dto) throws Exception;   // 코드 중복(활성) 체크
	int insertBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int updateBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int deleteBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	// ===== 수금/미수금 — TBL_RECEIVE_MST =====
	java.util.List<egovframework.sejong.user.model.ReceiveDTO> selectReceiveList(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;
	int insertReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;
	int updateReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;
	int deleteReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;      // rcvSeq 기준 소프트삭제
	int upsertReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception;      // 엑셀업로드(귀속월+거래처 MERGE)
	int carryForwardReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception; // 전월 미수잔액 → 당월 전월이월 이월
	// ===== 출금/미지급 — TBL_PAYMENT_MST =====
	java.util.List<egovframework.sejong.user.model.PaymentDTO> selectPaymentList(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;
	int insertPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;
	int updatePayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;
	int deletePayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;      // paySeq 기준 소프트삭제
	int upsertPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception;      // 엑셀업로드(귀속월+매입처 MERGE)
	int carryForwardPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception; // 전월 미지급잔액 → 당월 전월이월 이월
	// ===== 정산 마감상태 — TBL_SETTLE_CLOSE_MST (수금/출금 공용) =====
	int isSettleClosed(egovframework.sejong.user.model.SettleCloseDTO dto) throws Exception;   // 확정(STATUS='Y') 여부 count
	egovframework.sejong.user.model.SettleCloseDTO selectSettleClose(egovframework.sejong.user.model.SettleCloseDTO dto) throws Exception; // 상태 조회(UI)
	int confirmSettleClose(egovframework.sejong.user.model.SettleCloseDTO dto) throws Exception; // 확정(MERGE)
	int cancelSettleClose(egovframework.sejong.user.model.SettleCloseDTO dto) throws Exception;  // 해제(STATUS='N')

	// ===== 상품마스터 (TBL_PROD_MST) =====
	java.util.List<egovframework.sejong.user.model.ProdDTO> selectProdList(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int insertProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int updateProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int deleteProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception;
	int countProdRelated(egovframework.sejong.user.model.ProdDTO dto) throws Exception;   // 연관(매입가/판매가/재고) 활성건수

	// ===== 매입가 이력 (TBL_PROD_INPRICE_HST) =====
	java.util.List<egovframework.sejong.user.model.ProdInpriceDTO> selectInpriceList(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception;
	int insertInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception;
	int deleteInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception;

	/* ===== 거래처별 품목 표기(교차참조) — TBL_PROD_XREF (2026-08-01) =====
	   코네트 품목은 하나, 거래처가 요청하는 코드·품명은 이 표에 N건. 가상코드를 만들지 않는다.
	   resolve* 는 업로드 배치의 PROD_SEQ 를 '한 문장에' 채운다(행마다 조회하지 않음). */
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefList(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectUnmappedItems(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefCandidates(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefAudit(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;  // 매핑 점검 리포트
	java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefNames(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;  // 그 거래처로 나갈 때 쓸 품명(품목당 1건)
	int insertXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int updateXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int confirmXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int deleteXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int clearXrefMain(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	/* 잘못 연결한 매핑을 지우거나 고칠 때 — 그 코드로 이미 채워진 행을 되돌리기 위한 것들 */
	egovframework.sejong.user.model.ProdXrefDTO selectXrefById(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<String> selectShipoutDatesByExtCd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int clearShipoutProdByExtCd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int clearSalesProdByExtCd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;        // 1차 : XREF 매핑
	int resolveSalesProd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProdExt(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;     // 2차 : 통보품목 대장에 골라 둔 우리 상품코드
	int resolveSalesProdExt(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProdDirect(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;  // 3차 : 코드 직결(거래처 코드 = 우리 코드)
	int resolveSalesProdDirect(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	// 되돌려 붙이기 : 직결로 이미 붙은 행을 매칭코드의 주코드로 (2026-08-06 — 매칭코드를 늦게 등록한 과거분)
	int repointShipoutProdExt(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	int repointSalesProdExt(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<String> selectShipoutDatesByProd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception;  // 소급 재고반영 대상 출고일자

	/* ===== 거래처 통보품목 — TBL_EXT_ITEM_MST (2026-08-01) =====
	   거래처가 미리 통보해 주는 코드·품명을 원문 그대로 받아 두는 접수대장.
	   ★매핑 표가 아니다(우리 품목과 잇는 방식은 추후 결정) — TBL_PROD_XREF 와 섞지 말 것. */
	java.util.List<egovframework.sejong.user.model.ExtItemDTO> selectExtItemList(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception;
	int countExtItemCd(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception;   // (거래처+코드) 중복 확인
	int insertExtItem(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception;
	int updateExtItem(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception;
	egovframework.sejong.user.model.ExtItemDTO selectExtItemById(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception;  // 삭제 전 원본 확보(되돌리기용)
	int deleteExtItem(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception;
	int mergeExtItem(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception;     // 통보서 붙여넣기(있으면 갱신)
	int syncProdInPrice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception;   // TBL_PROD_MST.IN_PRICE 동기화

	// ===== 판매가 이력 (TBL_PROD_SALEPRICE_HST) =====
	java.util.List<egovframework.sejong.user.model.ProdSalepriceDTO> selectSalepriceList(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception;
	int insertSaleprice(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception;
	int deleteSaleprice(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception;
	int syncProdSalePrice(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception; // TBL_PROD_MST.SALE_PRICE/WHOLE_PRICE 동기화

	// ===== 재고 수불원장 / 현황 (TBL_STOCK_LEDGER / TBL_STOCK_MST) =====
	java.util.List<egovframework.sejong.user.model.StockLedgerDTO> selectStockLedgerList(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.StockLedgerDTO> selectInboundList(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception; // 입고내역(전체 입고 거래)
	int insertStockLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;
	int deleteStockLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;
	egovframework.sejong.user.model.StockMstDTO selectStockMst(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;
	int recalcStockMst(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;      // 원장 누계로 현재고 재집계(MERGE)
	java.util.List<egovframework.sejong.user.model.StockMstDTO> selectStockMstList(egovframework.sejong.user.model.StockMstDTO dto) throws Exception; // 전체 현재고 목록(재고현황)
	// (A) 출고(SHIPOUT)→원장 자동연동
	int deleteShipoutLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;  // 특정 출고일자 SHIPOUT 파생 O행 삭제
	int insertShipoutLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;  // 특정 출고일자 활성 SHIPOUT → O행 생성
	int recalcStockMstAll(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;    // 전체 품목 현재고 재집계
	int zeroOrphanStockMst(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception;  // 원장에서 사라진 품목의 캐시 0으로
	java.util.List<String> selectShipoutDates() throws Exception;                                 // 활성 SHIPOUT의 출고일자 목록(전체 재집계용)
	java.util.List<String> selectClosedYmList() throws Exception;                                 // 마감 확정월(YYYYMM) 목록

	// ===== 마감(매출/매입/마진) 집계 — 출고(TBL_SHIPOUT_MST) × 단가이력/마스터 =====
	java.util.List<egovframework.sejong.user.model.ClosingDTO> selectClosing(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;
	/* 출고미상 — 정산서에는 있는데 출고 자료에 짝이 없는 행(마감에서 통째로 빠지는 금액) */
	java.util.List<egovframework.sejong.user.model.ClosingDTO> selectClosingUnmatched(egovframework.sejong.user.model.ClosingDTO dto) throws Exception;
	// ===== 재고마감 집계 — TBL_STOCK_LEDGER (기초+입고-출고±조정=기말) =====
	java.util.List<egovframework.sejong.user.model.StockClosingDTO> selectStockClosing(egovframework.sejong.user.model.StockClosingDTO dto) throws Exception;
	// ===== 입고(매입)마감 집계 — TBL_STOCK_LEDGER 당월 입고(IO_GB='I') =====
	java.util.List<egovframework.sejong.user.model.StockClosingDTO> selectInboundClosing(egovframework.sejong.user.model.StockClosingDTO dto) throws Exception;

	// ===== 마감 확정/잠금/이월 — TBL_CLOSING_MST / TBL_CLOSING_STOCK =====
	egovframework.sejong.user.model.ClosingMstDTO selectClosingMst(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception; // 헤더 조회(없으면 null)
	java.util.List<egovframework.sejong.user.model.ClosingMstDTO> selectClosingMstList(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception; // 월별 마감 이력 목록
	int isClosedYm(@Param("closeYm") String closeYm, @Param("compCd") String compCd) throws Exception;   // ★compCd 를 시그니처에 둔다 — 인터셉터가 못 넣어도 ParamMap 에 키가 있어 #{compCd} 가 안 터진다(fail-open)
	int updateClosingMst(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception; // 확정 UPDATE(있으면)
	int insertClosingMst(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception; // 확정 INSERT(없으면)
	int cancelClosingMst(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception; // 확정 해제(ACTION_YN='N')
	int deleteClosingStock(@Param("closeYm") String closeYm, @Param("compCd") String compCd) throws Exception; // 재고 스냅샷 삭제 — compCd 는 위와 같은 이유
	int insertClosingStock(egovframework.sejong.user.model.StockClosingDTO dto) throws Exception; // 재고 스냅샷 1건

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

	/** 약관 본문 조회 (T_SIGN_MST) — termsGb 별 */
	List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception;

	/** termsGb 의 가장 최신(MAX TERMS_SEQ) USE_YN='Y' 약관 SEQ — 동의이력 INSERT 시 어느 버전에 동의했는지 기록용 */
	String selectLatestTermsSeq(String termsGb) throws Exception;

	/** 동의이력 INSERT (T_PERSIGN_TRAN) — 회원가입 시 termsGb 1/2/3 각 1건씩 호출 */
	int insertPersign(PersignDTO dto) throws Exception;

	/* ===== 매입등록 (TBL_PURCHASE_MST / DTL) — 2026-07-25 ===== */
	java.util.List<egovframework.sejong.user.model.PurchaseDTO> selectPurchaseList(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.PurchaseDtlDTO> selectPurchaseDtl(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	String selectPurchaseNextNo(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	int insertPurchaseMst(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	int updatePurchaseMst(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	int deletePurchaseMst(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	int deletePurchaseDtlAll(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
	int insertPurchaseDtl(egovframework.sejong.user.model.PurchaseDtlDTO dto) throws Exception;
	int deletePurchaseLedger(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception;
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

	/* ===== 판매등록 (TBL_SALES_TRX_MST/DTL) — 2026-07-25. 매입등록과 대칭 ===== */
	java.util.List<egovframework.sejong.user.model.SalesTrxDTO> selectSalesTrxList(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesTrxDtlDTO> selectSalesTrxDtl(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	String selectSalesTrxNextNo(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	int insertSalesTrxMst(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	int updateSalesTrxMst(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	int deleteSalesTrxMst(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	int deleteSalesTrxDtlAll(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	int insertSalesTrxDtl(egovframework.sejong.user.model.SalesTrxDtlDTO dto) throws Exception;
	int deleteSalesTrxLedger(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;
	Double selectCustLastPrice(egovframework.sejong.user.model.SalesTrxDtlDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesTrxDtlDTO> selectSalesPriceHist(egovframework.sejong.user.model.SalesTrxDtlDTO dto) throws Exception;
	/** 매출내역 화면에 얹을 판매전표 명세 — 정산서 행과 같은 모양으로 돌아온다 */
	java.util.List<java.util.Map<String,Object>> selectSalesTrxHist(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception;

	/* ===== 납품분 / 납품분 제외 — 2026-07-31. DDL: sql/sales_dlv_excl_ddl.sql ===== */
	java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectSalesDlvList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
	/** 매입분 — 그 매입처에서 사 온 품목(매입전표 + 매입단가이력). 제외는 같은 표의 GB='P' */
	java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectPurchDlvList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectSalesDlvExclList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
	int updateSalesDlvExcl(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
	int insertSalesDlvExcl(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception;
}
