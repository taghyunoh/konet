package egovframework.konet.user.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.konet.user.model.CompConDTO;
import egovframework.konet.user.model.CompMdDTO;
import egovframework.konet.user.model.PersignDTO;
import egovframework.konet.user.model.SjgnDTO;
import egovframework.konet.user.model.UserDTO;


@Mapper("UserMapper")
public interface UserMapper {

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
	int deleteShipoutZone(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;   // 출고장(DC_CD+INWH)+출고일자 활성분 소프트 삭제(ACTION_YN='D')
	int getShipoutNextJobSeq(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	int insertShipoutMst(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	/* 대량 INSERT (2026-08-28) — 여러 행을 한 문장으로. 행마다 던지던 것이 업로드 병목이었다.
	   ★한 번에 40행까지만 — SQL Server 는 한 문장의 파라미터가 2,100개를 넘을 수 없다(행당 41개). */
	int insertShipoutMstBulk(java.util.List<egovframework.konet.user.model.ShipoutDTO> list) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutMst(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutPrev(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutHistory(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutHistAll(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	/* 발주현황표 업로드 이력 — 출고현황이력조회 화면 (2026-07-25). 배치 단위 집계 + 배치 명세 */
	java.util.List<java.util.Map<String,Object>> selectSalesChart(egovframework.konet.user.model.ClosingDTO dto) throws Exception;        /* 매출 그래프 — 월별·출고장별 (2026-07-25) */
	java.util.List<java.util.Map<String,Object>> selectSalesChartDaily(egovframework.konet.user.model.ClosingDTO dto) throws Exception;   /* 매출 그래프 — 일자별. 월별과 따로 둔다 */
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadHist(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectShipoutUploadDtl(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutSrcFiles() throws Exception;   // 이미 업로드(반영)된 원본 파일명 목록 — 폴더 업로드 화면 '이미 반영' 표시용

	// ===== 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 (TBL_SALES_MST) =====
	int markSalesHistory(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	int getSalesNextJobSeq(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	int insertSalesMst(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesDTO> selectSalesMst(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesDTO> selectSalesSrcFiles() throws Exception;

	// 출고장 정정(2026-07-27) — 잘못 저장된 DC_NM 을 바로잡는다. 옮겨갈 이름에 활성배치가 이미 있으면 막는다
	int countSalesDcConflict(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	int updateSalesDcNm(egovframework.konet.user.model.SalesDTO dto) throws Exception;
	int mergeSalepriceFromSales(egovframework.konet.user.model.SalesDTO dto) throws Exception;   // 매출 엑셀 판매단가 → TBL_PROD_SALEPRICE_HST upsert (APPLY_DT=발주일자)

	// ===== 거래처 마스터 (TBL_VENDOR_MST) — TBL_BIZI_MST(사업장)와 별개 =====
	java.util.List<egovframework.konet.user.model.VendorDTO> selectVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectVendorTrxSum(egovframework.konet.user.model.VendorDTO dto) throws Exception;   // 최근 6개월 거래처별 매출·매입 합계 (거래처 팝업 정렬용)
	int vendorDupChk(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int insertVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int updateVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	/** 거래처 이메일만 저장 — 거래명세서 [이메일발송] 창의 「저장」 (2026-09-09) */
	int updateVendorEmail(egovframework.konet.user.model.VendorDTO dto) throws Exception;
	int deleteVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;   // 소프트 삭제(ACTION_YN='N')
	int mergeVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception;    // 거래처리스트.xls 재업로드 upsert

	// ===== 사업장 분류 마스터 (TBL_BIZI_MST) =====
	java.util.List<egovframework.konet.user.model.BiziDTO> selectBiziMst() throws Exception;
	/** 사업장별 통상 출고장 이력(2026-09-16) — 대시보드1 이상 배지. 한 줄 = 사업장·출고장 낱알·날짜 수 */
	java.util.List<java.util.Map<String,Object>> selectBizZoneHist(egovframework.konet.user.model.ShipoutDTO dto) throws Exception;
	int insertBiziIfAbsent(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectBiziNoAddr(java.util.Map<String,Object> p) throws Exception;   // 주소 없는 사업장 — 업로드 결과창 (2026-09-16 P2-c)
	int updateBiziMst(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int updateBiziParcel(egovframework.konet.user.model.BiziDTO dto) throws Exception; /* 택배 정보(주소·전화·운임)만 저장 (2026-08-06) */
	/* 사업장 공통 매칭코드 (2026-08-28) — 선택한 사업장들에 코드·명칭 일괄 지정 / 다음 자동채번 번호 */
	int updateBiziMatch(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int biziMatchNextNo(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectParcelOutList(java.util.Map<String,Object> p) throws Exception; /* 택배출고관리 — 출고일자 직송 목록 (2026-08-06) */
	int deleteBiziMst(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	// ===== 거래처관리(사업장) CRUD — TBL_BIZI_MST =====
	java.util.List<egovframework.konet.user.model.BiziDTO> selectBiziList(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int biziDupChk(egovframework.konet.user.model.BiziDTO dto) throws Exception;   // 코드 중복(활성) 체크
	int insertBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int updateBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	int deleteBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception;
	// ===== 수금 월 마감 스냅샷 — TBL_RECEIVE_MST 재활용 (2026-09-16). 수기 입력 메서드 12개(Receive*/Payment*)는 삭제 =====
	int deleteRcvSnapshot(java.util.Map<String,Object> p) throws Exception;                                       // 그 달 스냅샷 지우기(다시 확정)
	int insertRcvSnapshot(java.util.Map<String,Object> p) throws Exception;                                       // 거래처 한 줄(이월·매출·수금)
	java.util.List<java.util.Map<String,Object>> selectRcvSnapshot(java.util.Map<String,Object> p) throws Exception;   // rcvYm 비면 전체
	// ===== 정산 마감상태 — TBL_SETTLE_CLOSE_MST (수금/출금 공용) =====
	java.util.List<java.util.Map<String,Object>> selectSettleCloseList(egovframework.konet.user.model.SettleCloseDTO dto) throws Exception; // 확정된 달 목록
	int isSettleClosed(egovframework.konet.user.model.SettleCloseDTO dto) throws Exception;   // 확정(STATUS='Y') 여부 count
	egovframework.konet.user.model.SettleCloseDTO selectSettleClose(egovframework.konet.user.model.SettleCloseDTO dto) throws Exception; // 상태 조회(UI)
	int confirmSettleClose(egovframework.konet.user.model.SettleCloseDTO dto) throws Exception; // 확정(MERGE)
	int cancelSettleClose(egovframework.konet.user.model.SettleCloseDTO dto) throws Exception;  // 해제(STATUS='N')

	// ===== 상품마스터 (TBL_PROD_MST) =====
	java.util.List<egovframework.konet.user.model.ProdDTO> selectProdList(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	java.util.Map<String,Object> countProdCd(egovframework.konet.user.model.ProdDTO dto) throws Exception;   // 상품코드 중복 확인(2026-09-07) — ALIVE/DELETED
	int insertProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	int updateProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	int deleteProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdDTO> selectProdDeletedList(egovframework.konet.user.model.ProdDTO dto) throws Exception;   // 삭제한 상품(ACTION_YN='N') 목록
	int restoreProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	/* ★거래중지 (2026-08-17) — 지울 수 없는 코드를 「앞으로 안 쓰는 코드」로 표시한다. */
	int stopProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	int unstopProd(egovframework.konet.user.model.ProdDTO dto) throws Exception;
	/** 전표일자 기준으로 **중지된 코드만** 골라 준다(매입·판매 저장 관문). */
	java.util.List<egovframework.konet.user.model.ProdDTO> selectStoppedAmong(java.util.Map<String,Object> p) throws Exception;
	/** PROD_SEQ 하나가 거래중지인지 — 중지면 그 줄, 아니면 null (매칭코드 등록 관문, 2026-08-19). */
	egovframework.konet.user.model.ProdDTO selectProdStopById(java.util.Map<String,Object> p) throws Exception;
	int countProdRelated(egovframework.konet.user.model.ProdDTO dto) throws Exception;   // 연관(매입가/판매가/재고) 활성건수

	// ===== 매입가 이력 (TBL_PROD_INPRICE_HST) =====
	java.util.List<egovframework.konet.user.model.ProdInpriceDTO> selectInpriceList(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;
	/** 정산실적 시점 단가(2026-09-16 P2-f) — 회사 전체 매입가 이력(품목·적용일·단가) */
	java.util.List<egovframework.konet.user.model.ProdInpriceDTO> selectInpriceHstAll(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;
	int insertInprice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;
	int deleteInprice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;

	/* ===== 거래처별 품목 표기(교차참조) — TBL_PROD_XREF (2026-08-01) =====
	   코네트 품목은 하나, 거래처가 요청하는 코드·품명은 이 표에 N건. 가상코드를 만들지 않는다.
	   resolve* 는 업로드 배치의 PROD_SEQ 를 '한 문장에' 채운다(행마다 조회하지 않음). */
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefList(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectUnmappedItems(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefCandidates(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefAudit(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;  // 매핑 점검 리포트
	java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefNames(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;  // 그 거래처로 나갈 때 쓸 품명(품목당 1건)
	/** ★넘긴 코드 중 <b>서브코드인 것</b>만 마스터코드와 함께 (2026-08-17 · 원천=TBL_EXT_ITEM_MST) — 매입을 서브코드로 잡는 것을 막는다. */
	java.util.List<egovframework.konet.user.model.ExtItemDTO> selectSubCodesAmong(java.util.Map<String,Object> param) throws Exception;
	int insertXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int updateXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int confirmXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int deleteXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int clearXrefMain(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	/* 잘못 연결한 매핑을 지우거나 고칠 때 — 그 코드로 이미 채워진 행을 되돌리기 위한 것들 */
	egovframework.konet.user.model.ProdXrefDTO selectXrefById(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<String> selectShipoutDatesByExtCd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<String> selectSalesDatesByExtCd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;    // 정산서 납품일자 — 그 코드(2026-09-13)
	java.util.List<String> selectSalesDatesByExtProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;  // 정산서 납품일자 — 그 상품의 매칭·추가 코드
	int clearShipoutProdByExtCd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int clearSalesProdByExtCd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;        // 1차 : XREF 매핑
	int resolveSalesProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProdExt(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;     // 2차 : 통보품목 대장에 골라 둔 우리 상품코드
	int resolveSalesProdExt(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProdAdd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;     // 2.5차 : 추가 매칭코드(ADD_ITEM_CD, 2026-09-13)
	int resolveSalesProdAdd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int resolveShipoutProdDirect(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;  // 3차 : 코드 직결(거래처 코드 = 우리 코드)
	int resolveSalesProdDirect(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	// 되돌려 붙이기 : 직결로 이미 붙은 행을 매칭코드의 주코드로 (2026-08-06 — 매칭코드를 늦게 등록한 과거분)
	int repointShipoutProdExt(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int repointSalesProdExt(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	int repointShipoutProdAdd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;    // 추가 매칭코드판 (2026-09-13)
	int repointSalesProdAdd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;
	java.util.List<String> selectShipoutDatesByProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception;  // 소급 재고반영 대상 출고일자

	/* ===== 거래처 통보품목 — TBL_EXT_ITEM_MST (2026-08-01) =====
	   거래처가 미리 통보해 주는 코드·품명을 원문 그대로 받아 두는 접수대장.
	   ★매핑 표가 아니다(우리 품목과 잇는 방식은 추후 결정) — TBL_PROD_XREF 와 섞지 말 것. */
	java.util.List<egovframework.konet.user.model.ExtItemDTO> selectExtItemList(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	int countExtItemCd(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;   // (거래처+코드) 중복 확인
	egovframework.konet.user.model.ExtItemDTO selectExtCodeConflict(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;  // 추가 매칭코드 겹침(2026-09-13)
	int insertExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	int updateExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	egovframework.konet.user.model.ExtItemDTO selectExtItemById(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;  // 삭제 전 원본 확보(되돌리기용)
	int deleteExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;
	int mergeExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception;     // 통보서 붙여넣기(있으면 갱신)
	int syncProdInPrice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;   // TBL_PROD_MST.IN_PRICE 동기화

	// ===== 판매가 이력 (TBL_PROD_SALEPRICE_HST) =====
	java.util.List<egovframework.konet.user.model.ProdSalepriceDTO> selectSalepriceList(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception;
	int insertSaleprice(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception;
	int deleteSaleprice(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception;
	int syncProdSalePrice(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception; // TBL_PROD_MST.SALE_PRICE/WHOLE_PRICE 동기화

	// ===== 재고 수불원장 / 현황 (TBL_STOCK_LEDGER / TBL_STOCK_MST) =====
	java.util.List<egovframework.konet.user.model.StockLedgerDTO> selectStockLedgerList(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectStockLedgerInList(java.util.Map<String,Object> p) throws Exception;   // 월별 출고현황 하단 입고내역 — 출고(O)행 뺀 가벼운 원장 (2026-09-03 속도점검)
	java.util.List<egovframework.konet.user.model.StockLedgerDTO> selectInboundList(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception; // 입고내역(전체 입고 거래)
	int insertStockLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	int deleteStockLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	egovframework.konet.user.model.StockMstDTO selectStockMst(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	int recalcStockMst(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;      // 원장 누계로 현재고 재집계(MERGE)
	java.util.List<egovframework.konet.user.model.StockMstDTO> selectStockMstList(egovframework.konet.user.model.StockMstDTO dto) throws Exception; // 전체 현재고 목록(재고현황)
	java.util.List<egovframework.konet.user.model.StockMstDTO> selectStockQtyMap(egovframework.konet.user.model.StockMstDTO dto) throws Exception; // 코드별 재고만(출고현황표 대시보드용 — extQtys 없이 가볍게)
	java.util.List<java.util.Map<String,Object>> selectStockOutByMonth(java.util.Map<String,Object> p) throws Exception;   // 출고재고현황 — 년월×품목 출고량 (2026-09-03)
	java.util.List<java.util.Map<String,Object>> selectStockOutSrcDays(java.util.Map<String,Object> p) throws Exception;   // 출고재고현황 — 월별 정산서/발주 원천 일수 (2026-09-03)
	java.util.List<java.util.Map<String,Object>> selectStockOutDetail(java.util.Map<String,Object> p) throws Exception;    // 출고재고현황 하단 — 납기일자별 출고내역 (2026-09-03)
	// (A) 출고(SHIPOUT)→원장 자동연동
	java.util.List<String> selectShipoutDtsByDlvDt(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;  // 납품일자 D 의 발주행이 나간 출고일자들 (2026-09-03)
	int deleteShipoutLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;  // 특정 출고일자 SHIPOUT 파생 O행 삭제
	int deleteShipoutLedgerAll(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;  // 재집계 시작 때 SHIPOUT 파생행 전부 삭제(마감월 제외) — 원장 키 납기일자 전환(2026-09-03)
	int insertShipoutLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;  // 특정 출고일자 활성 SHIPOUT → O행 생성
	int recalcStockMstAll(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;    // 전체 품목 현재고 재집계
	int zeroOrphanStockMst(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;  // 원장에서 사라진 품목의 캐시 0으로
	java.util.List<String> selectShipoutDates() throws Exception;                                 // 활성 SHIPOUT의 출고일자 목록(전체 재집계용)
	java.util.List<String> selectClosedYmList() throws Exception;                                 // 마감 확정월(YYYYMM) 목록

	// ===== 마감(매출/매입/마진) 집계 — 출고(TBL_SHIPOUT_MST) × 단가이력/마스터 =====
	java.util.List<egovframework.konet.user.model.ClosingDTO> selectClosing(egovframework.konet.user.model.ClosingDTO dto) throws Exception;
	/* 출고미상 — 정산서에는 있는데 출고 자료에 짝이 없는 행(마감에서 통째로 빠지는 금액) */
	java.util.List<egovframework.konet.user.model.ClosingDTO> selectClosingUnmatched(egovframework.konet.user.model.ClosingDTO dto) throws Exception;
	// ===== 재고마감 집계 — TBL_STOCK_LEDGER (기초+입고-출고±조정=기말) =====
	java.util.List<egovframework.konet.user.model.StockClosingDTO> selectStockClosing(egovframework.konet.user.model.StockClosingDTO dto) throws Exception;
	// ===== 입고(매입)마감 집계 — TBL_STOCK_LEDGER 당월 입고(IO_GB='I') =====
	java.util.List<egovframework.konet.user.model.StockClosingDTO> selectInboundClosing(egovframework.konet.user.model.StockClosingDTO dto) throws Exception;

	// ===== 마감 확정/잠금/이월 — TBL_CLOSING_MST / TBL_CLOSING_STOCK =====
	egovframework.konet.user.model.ClosingMstDTO selectClosingMst(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception; // 헤더 조회(없으면 null)
	java.util.List<egovframework.konet.user.model.ClosingMstDTO> selectClosingMstList(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception; // 월별 마감 이력 목록

	// ===== 택배 「출력됨」 서버 저장 · 출고장 표 (2026-09-16 P3) =====
	java.util.List<java.util.Map<String,Object>> selectParcelPrintList(java.util.Map<String,Object> p) throws Exception;   // compCd·frDt·toDt
	int upsertParcelPrint(java.util.Map<String,Object> p) throws Exception;                                                // 한 줄 MERGE
	java.util.List<java.util.Map<String,Object>> selectDcList(java.util.Map<String,Object> p) throws Exception;            // TBL_DC_MST
	int updateDcWh(java.util.Map<String,Object> p) throws Exception;                                                    // 출고장 → 창고(2단계)
	java.util.List<egovframework.konet.user.model.StockClosingDTO> selectStockClosingByWh(egovframework.konet.user.model.StockClosingDTO dto) throws Exception;   // 마감 스냅샷 품목 × 창고

	// ===== 창고 (2026-09-16 P3 1단계) — TBL_WH_MST · 원장 WH_CD · 창고 이동(REF_GB='MOVE') =====
	java.util.List<java.util.Map<String,Object>> selectWhList(java.util.Map<String,Object> p) throws Exception;          // compCd·useOnly
	int upsertWhMst(java.util.Map<String,Object> p) throws Exception;
	int clearWhDefault(java.util.Map<String,Object> p) throws Exception;                                             // 기본창고는 하나 — 나머지 N
	java.util.List<java.util.Map<String,Object>> selectWhQtyMap(java.util.Map<String,Object> p) throws Exception;        // 창고별 현재고 합(창고 관리 표시용)
	java.util.List<java.util.Map<String,Object>> selectStockByWh(egovframework.konet.user.model.StockMstDTO dto) throws Exception;   // 품목 × 창고 현재고
	int insertStockMoveLedger(java.util.Map<String,Object> p) throws Exception;                                      // 이동 = A 행 한 쌍(2행)
	java.util.List<java.util.Map<String,Object>> selectStockMoveList(java.util.Map<String,Object> p) throws Exception;
	int cancelStockMove(java.util.Map<String,Object> p) throws Exception;

	// ===== 비용 (2026-09-16 P2-e) — TBL_EXPENSE_ITEM(항목) · TBL_EXPENSE_TRX(달×항목 수기) · 직송 택배 운임 자동 =====
	java.util.List<java.util.Map<String,Object>> selectExpenseItem(java.util.Map<String,Object> p) throws Exception;
	int upsertExpenseItem(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectExpenseTrx(java.util.Map<String,Object> p) throws Exception;     // compCd·expYm
	int upsertExpenseTrx(java.util.Map<String,Object> p) throws Exception;                                             // 달×항목 MERGE
	// 비용 내역 (2026-09-17) — TBL_EXPENSE_DTL. 내역 저장 뒤 syncExpenseTrxFromDtl 로 달×항목 금액을 내역 합계로 굳힌다
	java.util.List<java.util.Map<String,Object>> selectExpenseDtl(java.util.Map<String,Object> p) throws Exception;
	int insertExpenseDtl(java.util.Map<String,Object> p) throws Exception;
	int updateExpenseDtl(java.util.Map<String,Object> p) throws Exception;
	int deleteExpenseDtl(java.util.Map<String,Object> p) throws Exception;
	int syncExpenseTrxFromDtl(java.util.Map<String,Object> p) throws Exception;
	// DC 발주 (2026-09-17) — TBL_SHIPOUT_MST PROD_KIND='DC'. 납기현황관리에서만 빠지고 재고·정산서 대사에는 들어간다
	java.util.Map<String,Object> selectProdVendorOfItem(java.util.Map<String,Object> p) throws Exception;   // 품목(주·서브코드)의 상품 마스터 매입처 — DC 발주 저장 때 채운다(2026-09-21)
	int markDcPoReplace(java.util.Map<String,Object> p) throws Exception;
	// 견적서 관리 (2026-09-17) — TBL_QUOTE_MST/DTL
	java.util.List<java.util.Map<String,Object>> selectQuoteList(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectQuoteDtl(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectQuoteFile(java.util.Map<String,Object> p) throws Exception;
	int markQuoteReplace(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectQuoteByDoc(java.util.Map<String,Object> p) throws Exception;   // 같은 문서번호 활성 건(없으면 null)
	java.util.Map<String,Object> selectQuoteMst(java.util.Map<String,Object> p) throws Exception;     // 한 건 머리(작성·인쇄, 2026-09-17)
	int selectQuoteNoCnt(java.util.Map<String,Object> p) throws Exception;                            // 문서번호 머리로 시작하는 건수
	java.util.List<java.util.Map<String,Object>> selectQuoteNames(java.util.Map<String,Object> p) throws Exception;   // 쌓인 담당자·수신 이름
	java.util.List<java.util.Map<String,Object>> selectQuoteCompare(java.util.Map<String,Object> p) throws Exception;   // 비교분석 — compCd · seqs(List)
	int insertQuoteMst(java.util.Map<String,Object> p) throws Exception;
	int insertQuoteDtl(java.util.Map<String,Object> p) throws Exception;
	int deleteQuote(java.util.Map<String,Object> p) throws Exception;
	int deleteDcPo(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectDcPoList(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectParcelFeeAuto(java.util.Map<String,Object> p) throws Exception;                // {cnt, amt} — 직송 출고 × 사업장 운임(없으면 feeDef)
	int isClosedYm(@Param("closeYm") String closeYm, @Param("compCd") String compCd) throws Exception;   // ★compCd 를 시그니처에 둔다 — 인터셉터가 못 넣어도 ParamMap 에 키가 있어 #{compCd} 가 안 터진다(fail-open)
	int updateClosingMst(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception; // 확정 UPDATE(있으면)
	int insertClosingMst(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception; // 확정 INSERT(없으면)
	int cancelClosingMst(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception; // 확정 해제(ACTION_YN='N')
	int deleteClosingStock(@Param("closeYm") String closeYm, @Param("compCd") String compCd) throws Exception; // 재고 스냅샷 삭제 — compCd 는 위와 같은 이유
	int insertClosingStock(egovframework.konet.user.model.StockClosingDTO dto) throws Exception; // 재고 스냅샷 1건

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

	/** 약관 본문 조회 (T_SIGN_MST) — termsGb 별 */
	List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception;

	/** termsGb 의 가장 최신(MAX TERMS_SEQ) USE_YN='Y' 약관 SEQ — 동의이력 INSERT 시 어느 버전에 동의했는지 기록용 */
	String selectLatestTermsSeq(String termsGb) throws Exception;

	/** 동의이력 INSERT (T_PERSIGN_TRAN) — 회원가입 시 termsGb 1/2/3 각 1건씩 호출 */
	int insertPersign(PersignDTO dto) throws Exception;

	/* ===== 매입등록 (TBL_PURCHASE_MST / DTL) — 2026-07-25 ===== */
	java.util.List<egovframework.konet.user.model.PurchaseDTO> selectPurchaseList(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.PurchaseDtlDTO> selectPurchaseDtl(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectSubStockList(java.util.Map<String,Object> p) throws Exception;   // 서브코드 재고 정리 ① 재고가 남은 서브코드 (2026-09-13)
	java.util.List<java.util.Map<String,Object>> selectSubPurchList(java.util.Map<String,Object> p) throws Exception;   // 서브코드 재고 정리 ② 서브코드로 잡힌 매입 줄 (2026-09-13)
	String selectPurchaseNextNo(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	int insertPurchaseMst(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	int updatePurchaseMst(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	int deletePurchaseMst(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	int deletePurchaseDtlAll(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
	int insertPurchaseDtl(egovframework.konet.user.model.PurchaseDtlDTO dto) throws Exception;
	int deletePurchaseLedger(egovframework.konet.user.model.PurchaseDTO dto) throws Exception;
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

	/* ===== 판매등록 (TBL_SALES_TRX_MST/DTL) — 2026-07-25. 매입등록과 대칭 ===== */
	java.util.List<egovframework.konet.user.model.SalesTrxDTO> selectSalesTrxList(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesTrxDtlDTO> selectSalesTrxDtl(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	String selectSalesTrxNextNo(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	int insertSalesTrxMst(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	int updateSalesTrxMst(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	int deleteSalesTrxMst(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	int deleteSalesTrxDtlAll(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	int insertSalesTrxDtl(egovframework.konet.user.model.SalesTrxDtlDTO dto) throws Exception;
	int deleteSalesTrxLedger(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	/** 거래명세서 공유 — 공개 주소 토큰 발급(처음 한 번) + 보낸 횟수 (2026-09-09) */
	int updateSalesTrxShare(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;
	egovframework.konet.user.model.SalesTrxDtlDTO selectCustLastPrice(egovframework.konet.user.model.SalesTrxDtlDTO dto) throws Exception;   // 단가 + 이전 비고(2026-09-13)
	java.util.List<egovframework.konet.user.model.SalesTrxDtlDTO> selectSalesPriceHist(egovframework.konet.user.model.SalesTrxDtlDTO dto) throws Exception;
	/** 매출내역 화면에 얹을 판매전표 명세 — 정산서 행과 같은 모양으로 돌아온다 */
	java.util.List<java.util.Map<String,Object>> selectSalesTrxHist(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception;

	/* ===== 납품분 / 납품분 제외 — 2026-07-31. DDL: sql/sales_dlv_excl_ddl.sql ===== */
	java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectSalesDlvList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;
	/** 매입분 — 그 매입처에서 사 온 품목(매입전표 + 매입단가이력). 제외는 같은 표의 GB='P' */
	java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectPurchDlvList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectSalesDlvExclList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;
	int updateSalesDlvExcl(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;
	int insertSalesDlvExcl(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception;

	/* ── 재고 일괄조정 (2026-08-19) ───────────────────────────────────── */
	java.util.List<egovframework.konet.user.model.StockMstDTO>
	    selectStockAdjList(egovframework.konet.user.model.StockMstDTO dto) throws Exception;
	int insertStockAdjHis(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception;
	java.util.List<egovframework.konet.user.model.StockAdjHisDTO>
	    selectStockAdjHisList(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception;
	int cancelStockAdjBatchLedger(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception;
	int cancelStockAdjBatch(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception;

	/* ── 정산서 → 재고원장 연동 (2026-08-19) ──────────────────────────── */
	java.util.List<String> selectSalesDates(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	int deleteSalesLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	int insertSalesLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception;
	int updateProdPackQty(egovframework.konet.user.model.StockMstDTO dto) throws Exception;
	/* ── 발주서 관리 (2026-09-03) — HashMap 기반 */
	java.util.List<java.util.Map<String,Object>> selectPoList(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectPoRecentByProd(java.util.Map<String,Object> p) throws Exception;   // 품목별 최근 발주 한 줄 (2026-09-16)
	/* 발주 잔량·부분입고 (2026-09-16 P1-b) — 입고는 저장하지 않고 연결된 매입 명세 합으로 센다 */
	java.util.List<java.util.Map<String,Object>> selectPoRemainByProd(java.util.Map<String,Object> p) throws Exception;   // 품목별 미입고(잔량 합) = 입고예정
	java.util.List<java.util.Map<String,Object>> selectSafeStockShort(java.util.Map<String,Object> p) throws Exception;   // 적정재고 미달 목록 = 추천 발주 (2026-09-16 P1-c 후반)
	int updateSafeStockByCd(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectSafeStockSuggest(java.util.Map<String,Object> p) throws Exception;   // 적정재고 자동 산출 자료(2026-09-17) — compCd·frDt·toDt                                             // 적정재고 일괄 입력 — 품목코드 한 줄
	java.util.List<java.util.Map<String,Object>> selectPoLinkedPurch(java.util.Map<String,Object> p) throws Exception;    // 이 발주서를 보고 있는 매입전표들
	java.util.List<java.util.Map<String,Object>> selectPoOpenLines(java.util.Map<String,Object> p) throws Exception;      // 잔량 남은 발주 줄 — 매입등록 [발주분] (2단계)
	java.util.List<java.util.Map<String,Object>> selectVendorPriceCmp(java.util.Map<String,Object> p) throws Exception;   // 거래처별 매입가 비교 (2026-09-16 P2-a)
	int updatePoLineClose(java.util.Map<String,Object> p) throws Exception;                                               // 발주 줄 마감(더 안 온다)/해제
	int relinkPurchaseDtlPo(java.util.Map<String,Object> p) throws Exception;                                             // 발주서를 고쳐 저장해 줄 번호가 바뀌면 매입 연결을 새 번호로
	String selectPoNextNo(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectPoMst(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectPoDtl(java.util.Map<String,Object> p) throws Exception;
	int insertPoMst(java.util.Map<String,Object> p) throws Exception;
	int updatePoMst(java.util.Map<String,Object> p) throws Exception;
	int deletePoMst(java.util.Map<String,Object> p) throws Exception;
	int deletePoDtlAll(java.util.Map<String,Object> p) throws Exception;
	int insertPoDtl(java.util.Map<String,Object> p) throws Exception;
	int updatePoShared(java.util.Map<String,Object> p) throws Exception;
	int updatePoPurchSeq(java.util.Map<String,Object> p) throws Exception;   // 매입전환 결과 기억
	java.util.Map<String,Object> selectCompInfo(java.util.Map<String,Object> p) throws Exception;
	/* 회사 정보 수정 (2026-09-11) — compInfo.jsp */
	Double selectAvgInPrice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception;
	java.util.Map<String,Object> selectStockAvailForSale(java.util.Map<String,Object> p) throws Exception;
	java.util.Map<String,Object> selectCompInfoFull(java.util.Map<String,Object> p) throws Exception;
	int updateCompInfoSelf(java.util.Map<String,Object> p) throws Exception;
	String selectCompSetJson(java.util.Map<String,Object> p) throws Exception;
	int mergeCompSetJson(java.util.Map<String,Object> p) throws Exception;
	int mergeCompStamp(java.util.Map<String,Object> p) throws Exception;
	List<java.util.Map<String,Object>> selectCompBankList(java.util.Map<String,Object> p) throws Exception;
	int insertCompBank(java.util.Map<String,Object> p) throws Exception;
	int updateCompBank(java.util.Map<String,Object> p) throws Exception;
	int deleteCompBank(java.util.Map<String,Object> p) throws Exception;
	List<java.util.Map<String,Object>> selectCompCardList(java.util.Map<String,Object> p) throws Exception;
	int insertCompCard(java.util.Map<String,Object> p) throws Exception;
	int updateCompCard(java.util.Map<String,Object> p) throws Exception;
	int deleteCompCard(java.util.Map<String,Object> p) throws Exception;
	/* ── 문서 전송이력 (2026-09-10) — 거래명세표(STMT)·매입발주서(PO) 공용 표 TBL_SEND_HIST */
	int insertSendHist(java.util.Map<String,Object> p) throws Exception;
	java.util.List<java.util.Map<String,Object>> selectSendHistList(java.util.Map<String,Object> p) throws Exception;
	int updateSendHistMailOpen(java.util.Map<String,Object> p) throws Exception;   // 메일 열림(1×1 그림)
	int updateSendHistView(java.util.Map<String,Object> p) throws Exception;       // 링크 열람(공개 페이지)
}
