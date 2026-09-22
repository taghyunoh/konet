package egovframework.konet.user.service;

import java.util.List;
import java.util.Map;

import egovframework.konet.user.model.CompConDTO;
import egovframework.konet.user.model.CompMdDTO;
import egovframework.konet.user.model.PersignDTO;
import egovframework.konet.user.model.SjgnDTO;
import egovframework.konet.user.model.UserDTO;

public interface UserService {

	// ===== 회사/계약/사용자 관리 (compcd.jsp) =====
	List<CompMdDTO> selCompCdList(CompMdDTO dto) throws Exception;
	String CompCdMstDupChk(CompMdDTO dto) throws Exception;
	int insertCompCdMst(CompMdDTO dto) throws Exception;
	int updateCompCdMst(CompMdDTO dto) throws Exception;
	/** 거래명세표 <공급자> 칸(업태·종목·계좌)만 고친다 — 이력 안 만든다 (2026-09-09) */
	int updateCompBizInfo(CompMdDTO dto) throws Exception;

	List<CompConDTO> selectCompContList(CompConDTO dto) throws Exception;
	List<CompConDTO> getCompContList(CompConDTO dto) throws Exception;
	String CompContDupChk(CompConDTO dto) throws Exception;
	int insertCompCont(CompConDTO dto) throws Exception;
	int updateCompCont(CompConDTO dto) throws Exception;

	List<java.util.Map<String,Object>> selectCommCodeList(java.util.Map<String,Object> param) throws Exception;

	// ===== 출고장(발주현황표) 업로드 저장 (TBL_SHIPOUT_MST) =====
	java.util.List<String> selectShipoutActiveShpoutDts(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;  // 이력마감 전 (납품일자+물류센터) 활성배치의 출고일자 — 재고연동용
	int markShipoutHistory(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	int deleteShipoutZone(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;   // 출고장+출고일자 활성분 소프트 삭제
	int getShipoutNextJobSeq(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	int insertShipoutMst(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	/* 대량 INSERT (2026-08-28) — 여러 행을 한 문장으로. 행마다 던지던 것이 업로드 병목이었다.
	   ★한 번에 40행까지만 — SQL Server 는 한 문장의 파라미터가 2,100개를 넘을 수 없다(행당 41개). */
	int insertShipoutMstBulk(java.util.List<egovframework.konet.user.model.ShipoutDTO> list) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutMst(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutPrev(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutHistory(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutHistAll(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	/* 발주현황표 업로드 이력 — 출고현황이력조회 (2026-07-25) */
	java.util.List<java.util.Map<String,Object>> selectSalesChart(egovframework.konet.user.model.ClosingDTO dto) throws Exception;        /* 매출 그래프 — 월별·출고장별 (2026-07-25) */
	java.util.List<java.util.Map<String,Object>> selectSalesChartDaily(egovframework.konet.user.model.ClosingDTO dto) throws Exception;   /* 매출 그래프 — 일자별. 월별과 따로 둔다 */
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadHist(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadDtl(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutSrcFiles() throws Exception;   // 이미 업로드(반영)된 원본 파일명 목록

	// ===== 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 (TBL_SALES_MST) =====
	int markSalesHistory(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	int getSalesNextJobSeq(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	int insertSalesMst(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesDTO> selectSalesMst(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesDTO> selectSalesSrcFiles() throws Exception;

	// 출고장 정정(2026-07-27) — 반환: 바뀐 행수. 키가 겹치면 -1(정정 불가, 화면에서 안내)
	int renameSalesDc(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	int mergeSalepriceFromSales(egovframework.konet.user.model.SalesDTO dto) throws Exception;   // 매출 엑셀 판매단가 → 판매가 이력 upsert

	// ===== 거래처 마스터 (TBL_VENDOR_MST) =====
	java.util.List<egovframework.konet.user.model.VendorDTO> selectVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectVendorTrxSum(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int vendorDupChk(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int insertVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int updateVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	/** 거래처 이메일만 저장 — 거래명세서 [이메일발송] 창의 「저장」 (2026-09-09) */
	int updateVendorEmail(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int deleteVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int mergeVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;

	// ===== 사업장 분류 마스터 (TBL_BIZI_MST) =====
	java.util.List<egovframework.konet.user.model.BiziDTO> selectBiziMst() throws Exception;
	java.util.List<java.util.Map<String,Object>> selectBizZoneHist(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;   // 통상 출고장 이력(2026-09-16)
	int insertBiziIfAbsent(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectBiziNoAddr(java.util.Map<String,Object> p) throws Exception;   // 주소 없는 사업장 — 업로드 결과창 (2026-09-16 P2-c)
	int updateBiziMst(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int updateBiziParcel(egovframework.konet.user.model.BiziDTO dto) throws Exception; /* 택배 정보(주소·전화·운임)만 저장 (2026-08-06) */
	int updateBiziMatch(egovframework.konet.user.model.BiziDTO dto) throws Exception;  /* 공통 매칭코드 일괄 지정/해제 (2026-08-28) */
	int biziMatchNextNo(egovframework.konet.user.model.BiziDTO dto) throws Exception;  /* 매칭코드 자동채번용 다음 번호 */
	java.util.List<java.util.Map<String,Object>> selectParcelOutList(java.util.Map<String,Object> p) throws Exception; /* 택배출고관리 — 출고일자 직송 목록 (2026-08-06) */
	int deleteBiziMst(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	// ===== 거래처관리(사업장) CRUD =====
	java.util.List<egovframework.konet.user.model.BiziDTO> selectBiziList(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int biziDupChk(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int insertBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int updateBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int deleteBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	// ===== 정산 월 마감 — TBL_SETTLE_CLOSE_MST (2026-09-16 P2-g) =====
	//   수기 장부 메서드 12개(Receive*/Payment*)는 삭제(실사용 0). 확정(RCV)은 그 달 거래처별 이월·매출·수금을 TBL_RECEIVE_MST 에 스냅샷으로 남긴다.
	egovframework.konet.user.model.SettleCloseDTO selectSettleClose(String settleGb, String ym) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectSettleCloseList(String settleGb, String compCd) throws Exception;   // 확정된 달 목록
	java.util.List<java.util.Map<String,Object>> selectRcvSnapshot(String ym, String compCd) throws Exception;            // 확정 스냅샷(ym 비면 전체)
	int confirmSettleClose(String settleGb, String ym, String user, String ip, String compCd) throws Exception; // 확정: RCV 는 스냅샷 + 잠금
	int cancelSettleClose(String settleGb, String ym, String user, String compCd) throws Exception;              // 해제: 잠금만 푼다(스냅샷은 남긴다)

	// ===== 상품마스터 (TBL_PROD_MST) =====
	java.util.List<egovframework.konet.user.model.ProdDTO> selectProdList(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	java.util.Map<String,Object> countProdCd(egovframework.konet.user.model.ProdDTO dto) throws Exception;   // 상품코드 중복 확인(2026-09-07) — ALIVE/DELETED
	int insertProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	int updateProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	java.util.Map<String,Object> selectProdInPriceBySeq(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	int updateSubProdInPrice(java.util.Map<String,Object> p) throws Exception;
	/* 토더 발주 등록 (2026-09-21) */
	int saveTdPo(java.util.List<egovframework.konet.user.model.ShipoutDTO> rows, String user, String ip, String compCd) throws Exception;
	int deleteTdPo(java.util.List<java.util.Map<String,Object>> keys, String user, String ip, String compCd) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectTdPoList(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectTdPoMap(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectTdCodeExist(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> updateTdPoCode(String kind, String nm, String cd, String user, String ip, String compCd) throws Exception;
	String updateTdPoRow(String ordNo, String bizNm, String itemNm, int qty, Double salePrice, String user, String ip, String compCd) throws Exception;
	java.util.Map<String,Object> saveExpenseCopy(String fromYm, String toYm, boolean overwrite, String user, String ip, String compCd) throws Exception;   // 비용 등록 : 한 달을 다른 달로 복사(2026-09-21)
	int deleteProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdDTO> selectProdDeletedList(egovframework.konet.user.model.ProdDTO dto) throws Exception;   // 삭제한 상품(ACTION_YN='N') 목록
	int restoreProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	/* ★거래중지 (2026-08-17) — 지울 수 없는 코드를 「앞으로 안 쓰는 코드」로 표시한다. */
	int stopProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	int unstopProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	/** 전표일자 기준으로 **중지된 코드만** 골라 준다(매입·판매 저장 관문). */
	java.util.List<egovframework.konet.user.model.ProdDTO> selectStoppedAmong(java.util.Map<String,Object> p) throws Exception;
	egovframework.konet.user.model.ProdDTO selectProdStopById(java.util.Map<String,Object> p) throws Exception;   // 매칭코드 등록 관문(2026-08-19)
	int countProdRelated(egovframework.konet.user.model.ProdDTO dto) throws Exception;   // 연관(매입가/판매가/재고) 활성건수

	// ===== 매입가 이력 =====
	java.util.List<egovframework.konet.user.model.ProdInpriceDTO> selectInpriceList(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdInpriceDTO> selectInpriceHstAll(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;   // 정산실적 시점 단가(2026-09-16)
	int insertInprice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;   // 이력 INSERT + 마스터 IN_PRICE 동기화
	int deleteInprice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;

	/* ===== 거래처별 품목 표기(교차참조) — TBL_PROD_XREF (2026-08-01) ===== */
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefList(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectUnmappedItems(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefCandidates(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefAudit(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;  // 매핑 점검 리포트
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefNames(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;  // 그 거래처로 나갈 때 쓸 품명(품목당 1건)
	/** ★넘긴 코드 중 <b>서브코드인 것</b>만 마스터코드와 함께 (2026-08-17 · 원천=TBL_EXT_ITEM_MST) — 매입을 서브코드로 잡는 것을 막는다. */
	java.util.List<egovframework.konet.user.model.ExtItemDTO> selectSubCodesAmong(java.util.Map<String,Object> param) throws Exception;
	int saveXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;    // 등록/수정 + 대표표기 정리 + 소급 반영
	int confirmXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int deleteXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int resolveSalesProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;

	/* ===== 거래처 통보품목 — TBL_EXT_ITEM_MST (2026-08-01) =====
	   거래처가 미리 통보한 코드·품명 접수대장. ★매핑 표가 아니다(우리 품목과 잇는 방식은 추후 결정). */
	java.util.List<egovframework.konet.user.model.ExtItemDTO> selectExtItemList(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	int countExtItemCd(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	egovframework.konet.user.model.ExtItemDTO selectExtCodeConflict(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;  // 추가 매칭코드 겹침(2026-09-13)
	int insertExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	int updateExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	int deleteExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	int mergeExtItems(java.util.List<egovframework.konet.user.model.ExtItemDTO> list) throws Exception;   // 통보서 붙여넣기 일괄

	// ===== 판매가 이력 =====
	java.util.List<egovframework.konet.user.model.ProdSalepriceDTO> selectSalepriceList(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception;
	int insertSaleprice(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception; // 이력 INSERT + 마스터 SALE/WHOLE 동기화
	int deleteSaleprice(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception;

	// ===== 재고 수불 / 현황 =====
	java.util.List<egovframework.konet.user.model.StockLedgerDTO> selectStockLedgerList(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectStockLedgerInList(java.util.Map<String,Object> p) throws Exception;   // 월별 출고현황 하단 입고내역 (2026-09-03 속도점검)
	egovframework.konet.user.model.StockMstDTO selectStockMst(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	int insertStockLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception; // 원장 INSERT + 현재고 재집계
	int deleteStockLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception; // 원장 삭제 + 현재고 재집계
	java.util.List<egovframework.konet.user.model.StockMstDTO> selectStockMstList(egovframework.konet.user.model.StockMstDTO dto) throws Exception; // 재고현황(전체 현재고)
	java.util.List<egovframework.konet.user.model.StockMstDTO> selectStockQtyMap(egovframework.konet.user.model.StockMstDTO dto) throws Exception; // 코드별 재고만(대시보드용)
	java.util.List<java.util.Map<String,Object>> selectStockOutByMonth(java.util.Map<String,Object> p) throws Exception;   // 출고재고현황 — 년월×품목 출고량 (2026-09-03)
	java.util.List<java.util.Map<String,Object>> selectStockOutSrcDays(java.util.Map<String,Object> p) throws Exception;   // 출고재고현황 — 월별 정산서/발주 원천 일수 (2026-09-03)
	java.util.List<java.util.Map<String,Object>> selectStockOutDetail(java.util.Map<String,Object> p) throws Exception;    // 출고재고현황 하단 — 납기일자별 출고내역 (2026-09-03)
	java.util.List<egovframework.konet.user.model.StockLedgerDTO> selectInboundList(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception; // 입고내역
	// (A) 출고(SHIPOUT)→원장 자동연동
	int syncShipoutLedgerDate(String shpoutDt, String regUser, String regIp) throws Exception; // 출고일자별 O행 재동기화(마감월이면 skip)
	int recalcStockMstAll(String regUser, String regIp) throws Exception;                       // 전체 현재고 재집계
	int rebuildShipoutLedgerAll(String regUser, String regIp) throws Exception;                 // 전체 출고→원장 재동기화+재집계(화면 버튼)
	java.util.List<String> selectClosedYmList() throws Exception;                                // 마감 확정월 목록(재집계 팝업 표시용)

	// ===== 마감 집계 =====
	java.util.List<egovframework.konet.user.model.ClosingDTO> selectClosing(egovframework.konet.user.model.ClosingDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ClosingDTO> selectClosingUnmatched(egovframework.konet.user.model.ClosingDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.StockClosingDTO> selectStockClosing(egovframework.konet.user.model.StockClosingDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.StockClosingDTO> selectInboundClosing(egovframework.konet.user.model.StockClosingDTO dto) throws Exception;

	// ===== 마감 확정/해제/조회 =====
	egovframework.konet.user.model.ClosingMstDTO selectClosingMst(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ClosingMstDTO> selectClosingMstList(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception;

	// ===== 택배 「출력됨」 서버 저장 · 출고장 표 (2026-09-16 P3) =====
	java.util.List<java.util.Map<String,Object>> selectParcelPrintList(String compCd, String frDt, String toDt) throws Exception;
	int markParcelPrint(java.util.List<java.util.Map<String,Object>> rows, String user, String compCd) throws Exception;   // 줄마다 MERGE, 건수
	java.util.List<java.util.Map<String,Object>> selectDcList(String compCd) throws Exception;
	int saveDcWh(java.util.Map<String,Object> p) throws Exception;                                                      // 출고장 → 창고(2단계)

	// ===== 창고 (2026-09-16 P3 1단계) =====
	java.util.List<java.util.Map<String,Object>> selectWhList(String compCd, boolean useOnly) throws Exception;
	java.util.Map<String,Object> selectWhQtyMap(String compCd) throws Exception;                         // whCd → 현재고 합
	int saveWhMst(java.util.Map<String,Object> p) throws Exception;                                     // 기본창고 Y 면 나머지 N
	java.util.List<java.util.Map<String,Object>> selectStockByWh(egovframework.konet.user.model.StockMstDTO dto) throws Exception;
	int saveStockMove(java.util.Map<String,Object> p) throws Exception;                                 // 2행 아니면 예외(품목 없음)
	java.util.List<java.util.Map<String,Object>> selectStockMoveList(java.util.Map<String,Object> p) throws Exception;
	int cancelStockMove(java.util.Map<String,Object> p) throws Exception;

	// ===== 비용 (2026-09-16 P2-e) — 순마진 = 매출총이익 − 비용. 확정(confirmClosing)이 expenseSumOf 로 굳힌다 =====
	java.util.Map<String,Object> selectExpenseMonth(String ym, String compCd) throws Exception;          // {items, trx, auto:{cnt,amt}, feeDef}
	double expenseSumOf(String ym, String compCd) throws Exception;                                       // 자동 운임 + 사용 중인 수기 항목 합
	int saveExpenseItem(java.util.Map<String,Object> p) throws Exception;
	int saveExpenseTrx(java.util.List<java.util.Map<String,Object>> rows, String ym, String user, String ip, String compCd) throws Exception;
	// DC 발주 (2026-09-17) — 저장(같은 납기일자·품목은 대체) · 삭제 · 목록. 저장·삭제 뒤 재고 원장은 호출 쪽이 납기일자별로 다시 맞춘다
	// 견적서 관리 (2026-09-17) — 엑셀 해석 · 저장(같은 문서번호 대체) · 목록 · 줄 · 원본 · 삭제
	java.util.Map<String,Object> parseQuoteXls(byte[] data, String fileNm) throws Exception;
	long saveQuote(java.util.Map<String,Object> q, String user, String ip, String compCd) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectQuoteList(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectQuoteDtl(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectQuoteFile(java.util.Map<String,Object> p) throws Exception;
	int deleteQuote(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectQuoteByDoc(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectQuoteMst(java.util.Map<String,Object> p) throws Exception;
	String nextQuoteNo(String compCd, String quoteDt) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectQuoteNames(java.util.Map<String,Object> p) throws Exception;
	byte[] buildQuoteXls(java.util.Map<String,Object> mst, java.util.List<java.util.Map<String,Object>> lines) throws Exception;   // 양식 파일에 값 채운 xls (2026-09-17)   // 'Konet' + yyMMdd + '-' + 두 자리 (2026-09-17 견적서 작성)
	java.util.List<java.util.Map<String,Object>> selectQuoteCompare(java.util.Map<String,Object> p) throws Exception;
	int saveDcPo(java.util.List<egovframework.konet.user.model.ShipoutDTO> rows, String user, String ip, String compCd) throws Exception;
	int deleteDcPo(java.util.List<java.util.Map<String,Object>> keys, String user, String ip, String compCd) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectDcPoList(java.util.Map<String,Object> p) throws Exception;
	int saveExpenseDtl(java.util.List<java.util.Map<String,Object>> rows, String ym, String itemCd, String user, String ip, String compCd) throws Exception;   // 비용 내역(2026-09-17) — 줄 추가·수정·삭제 뒤 달×항목 금액을 내역 합계로
	int confirmClosing(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception; // 집계+헤더+재고스냅샷 저장(확정)
	int cancelClosing(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception;  // 확정 해제

	// ===== 공통코드 관리 (codecd.jsp) =====
	List<egovframework.konet.user.model.CodeMdDTO> codeMstList(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;
	String codeMstDupChk(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;
	int insertCodeMst(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;
	int updateCodeMst(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;
	List<egovframework.konet.user.model.CodeMdDTO> codeDtlList(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;
	String codeDtlDupChk(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;
	int insertCodeDtl(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;
	int updateCodeDtl(egovframework.konet.user.model.CodeMdDTO dto) throws Exception;

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
	java.util.List<egovframework.konet.user.model.PurchaseDTO> selectPurchaseList(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	egovframework.konet.user.model.PurchaseDTO selectPurchaseOne(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	String selectPurchaseNextNo(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	/** 전표 저장(신규/수정) — 헤더·명세 + 파생 재고원장 + 매입단가 이력을 한 번에 */
	int savePurchase(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	/** 서브코드 재고 정리 (2026-09-13) — {subs: 재고가 남은 서브코드, purch: 서브코드로 잡힌 매입 줄} */
	java.util.Map<String,Object> selectSubStock(java.util.Map<String,Object> p) throws Exception;
	/** 서브코드 재고 정리 — 고른 서브코드 재고를 0 으로(merge = 같은 수량을 주코드에 더함). 재고 일괄조정과 같은 조정행·이력 */
	java.util.Map<String,Object> saveSubStockZero(java.util.List<String> subCds, boolean merge, String compCd, String user, String ip) throws Exception;
	int deletePurchase(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	egovframework.konet.user.model.PurchaseDtlDTO selectVendorLastPrice(egovframework.konet.user.model.PurchaseDtlDTO dto) throws Exception;   // 단가 + 이전 비고(2026-09-13)
	java.util.List<egovframework.konet.user.model.PurchaseDtlDTO> selectPurchasePriceHist(egovframework.konet.user.model.PurchaseDtlDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectPurchaseLedger(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	/* ===== 수금/지급 등록 (TBL_SETTLE_TRX) — 2026-07-25 ===== */
	java.util.List<egovframework.konet.user.model.SettleTrxDTO> selectSettleList(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;
	String selectSettleNextNo(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;
	int insertSettleTrx(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;
	int updateSettleTrx(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;
	int deleteSettleTrx(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectCustLedger(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectCustBalance(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;   /* 거래처별 받을금액/지급할금액 — 전 거래처 × 월 (2026-07-26) */
	java.util.List<java.util.Map<String,Object>> selectCustDayDetail(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception; /* 위 화면 하단 — 한 거래처의 특정일자 하루 건별 내역(출고·매입·입금·출금) (2026-07-27) */
	java.util.List<java.util.Map<String,Object>> selectDayBook(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception;       /* 일계장 — 하루치 거래처별 매출·매입·수금·지급 (2026-07-26) */

	/* ===== 판매등록 — 2026-07-25 ===== */
	java.util.List<egovframework.konet.user.model.SalesTrxDTO> selectSalesTrxList(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	egovframework.konet.user.model.SalesTrxDTO selectSalesTrxOne(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	/** 거래명세서 공유 — 토큰을 발급(처음 한 번)하고 그 토큰을 돌려준다. 카톡·이메일 보내기가 부른다 (2026-09-09) */
	String shareSalesTrx(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	/** 공개 링크 — 토큰 하나로 전표+명세를 읽는다. 로그인 없음(/pub/stmt.do) (2026-09-09) */
	egovframework.konet.user.model.SalesTrxDTO selectSalesTrxByToken(String token) throws Exception;
	String selectSalesTrxNextNo(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	int saveSalesTrx(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	int deleteSalesTrx(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	egovframework.konet.user.model.SalesTrxDtlDTO selectCustLastPrice(egovframework.konet.user.model.SalesTrxDtlDTO dto) throws Exception;   // 단가 + 이전 비고(2026-09-13)
	java.util.List<egovframework.konet.user.model.SalesTrxDtlDTO> selectSalesPriceHist(egovframework.konet.user.model.SalesTrxDtlDTO dto) throws Exception;
	/** 매출내역 화면에 얹을 판매전표 명세 — 정산서 행과 같은 모양 */
	java.util.List<java.util.Map<String,Object>> selectSalesTrxHist(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;

	/* ===== 납품분(그 거래처에 나간 품목) / 납품분 제외 — 2026-07-31 ===== */
	java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectSalesDlvList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectPurchDlvList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectSalesDlvExclList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;
	/** 납품분 제외 켜기/끄기 — dto.actionYn 'Y' 제외 / 'N' 해제. 처리한 품목 수를 돌려준다 */
	int saveSalesDlvExcl(egovframework.konet.user.model.SalesDlvDTO dto, java.util.List<String> prodCds) throws Exception;

	/* ── 재고 일괄조정 (2026-08-19) ─────────────────────────────────────
	   기존화면(거래처 시스템)의 [리스트조회] + [수정저장].
	   재고의 주인은 수불원장이다. 덮어쓰지 않고 **차이만큼 조정행(A)** 을 더한다. */

	/** 목록 : 기준일자까지의 누계 현재고 + BOX/EA 환산 */
	java.util.List<egovframework.konet.user.model.StockMstDTO>
	    selectStockAdjList(egovframework.konet.user.model.StockMstDTO dto) throws Exception;

	/** 일괄저장 : 차이만큼 조정행 생성 + 이력 기록. 처리한 품목 수를 돌려준다 */
	int saveStockAdjBatch(egovframework.konet.user.model.StockAdjHisDTO head,
	                      java.util.List<egovframework.konet.user.model.StockAdjHisDTO> rows) throws Exception;

	/** 조정 이력 조회 */
	java.util.List<egovframework.konet.user.model.StockAdjHisDTO>
	    selectStockAdjHisList(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception;

	/** 묶음 되돌리기 : 이력 + 짝인 원장 조정행을 함께 내린다 */
	int cancelStockAdjBatch(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception;

	/** 입수수량만 고친다 — BOX/EA 환산 기준. 재고(원장)는 안 건드린다 */
	int saveProdPackQty(java.util.List<egovframework.konet.user.model.StockMstDTO> rows) throws Exception;

	/** 정산서 → 재고원장 재동기화 : 그 납품일자의 SALES 파생행을 지우고 다시 만든다 */
	int syncSalesLedger(String dlvDt, String compCd, String regUser, String regIp) throws Exception;
	/* ── 발주서 관리 (2026-09-03) */
	java.util.List<java.util.Map<String,Object>> selectPoList(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectPoRecentByProd(java.util.Map<String,Object> p) throws Exception;   // 품목별 최근 발주 한 줄 (2026-09-16)
	java.util.List<java.util.Map<String,Object>> selectPoRemainByProd(java.util.Map<String,Object> p) throws Exception;   // 품목별 미입고(잔량 합) (2026-09-16 P1-b)
	java.util.List<java.util.Map<String,Object>> selectSafeStockShort(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectSafeStockSuggest(String compCd, Integer window, Integer lead, Integer buf, Integer minDays) throws Exception;   // 적정재고 자동 산출 제안(2026-09-17) — {data, params, summary}   // 적정재고 미달 목록 = 추천 발주 (2026-09-16 P1-c 후반)
	java.util.Map<String,Object> saveSafeStockBulk(java.util.List<java.util.Map<String,Object>> rows, String compCd, String regUser) throws Exception;   // 적정재고 일괄 입력
	java.util.List<java.util.Map<String,Object>> selectPoLinkedPurch(java.util.Map<String,Object> p) throws Exception;    // 이 발주서를 보고 있는 매입전표들
	java.util.List<java.util.Map<String,Object>> selectPoOpenLines(java.util.Map<String,Object> p) throws Exception;      // 잔량 남은 발주 줄 — 매입등록 [발주분] (2단계)
	java.util.List<java.util.Map<String,Object>> selectVendorPriceCmp(java.util.Map<String,Object> p) throws Exception;   // 거래처별 매입가 비교 (2026-09-16 P2-a)
	int updatePoLineClose(java.util.Map<String,Object> p) throws Exception;                                               // 발주 줄 마감/해제
	String selectPoNextNo(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectPoMst(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectPoMstByToken(String token) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectPoDtl(java.util.Map<String,Object> p) throws Exception;
	long savePo(java.util.Map<String,Object> body, String user, String ip) throws Exception;   // 머리+줄 저장, poSeq 반환
	int deletePo(java.util.Map<String,Object> p) throws Exception;
	int updatePoShared(java.util.Map<String,Object> p) throws Exception;
	int updatePoPurchSeq(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectCompInfo(java.util.Map<String,Object> p) throws Exception;
	/* 회사 정보 수정 (2026-09-11) — compInfo.jsp */
	/** 판매 저장 전 회사 설정 관문(재고 부족·여신 초과) — 막을 이유가 있으면 그 글, 없으면 null */
	String salesLimitMsg(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	java.util.Map<String,Object> selectCompInfoFull(java.util.Map<String,Object> p) throws Exception;
	int updateCompInfoSelf(java.util.Map<String,Object> p) throws Exception;
	String selectCompSetJson(java.util.Map<String,Object> p) throws Exception;
	int mergeCompSetJson(java.util.Map<String,Object> p) throws Exception;
	int mergeCompStamp(java.util.Map<String,Object> p) throws Exception;
	List<java.util.Map<String,Object>> selectCompBankList(java.util.Map<String,Object> p) throws Exception;
	int saveCompBank(java.util.Map<String,Object> p) throws Exception;
	int deleteCompBank(java.util.Map<String,Object> p) throws Exception;
	List<java.util.Map<String,Object>> selectCompCardList(java.util.Map<String,Object> p) throws Exception;
	int saveCompCard(java.util.Map<String,Object> p) throws Exception;
	int deleteCompCard(java.util.Map<String,Object> p) throws Exception;
	/* ── 문서 전송이력 (2026-09-10) — 거래명세표·발주서가 한 표를 쓴다(DOC_GB 로만 가른다) */
	int insertSendHist(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectSendHistList(java.util.Map<String,Object> p) throws Exception;
	int updateSendHistMailOpen(java.util.Map<String,Object> p) throws Exception;   // 메일 열림(1×1 그림)
	int updateSendHistView(java.util.Map<String,Object> p) throws Exception;       // 링크 열람(공개 페이지)
}
