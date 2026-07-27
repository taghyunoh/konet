package egovframework.sejong.user.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.sejong.user.mapper.UserMapper;
import egovframework.sejong.user.model.CompConDTO;
import egovframework.sejong.user.model.CompMdDTO;
import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;
import egovframework.sejong.user.service.UserService;


@Service("UserService")
public class UserServiceImpl implements UserService {

	private static final Logger LOGGER = LoggerFactory.getLogger(UserServiceImpl.class);

	@Autowired
	private UserMapper mapper;

	@Override
	public UserDTO userLoginCheck(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userLoginCheck(dto);
	}

	@Override
	public UserDTO compLoginCheck(UserDTO dto) throws Exception {
		return mapper.compLoginCheck(dto);
	}

	@Override
	public UserDTO compUserInfo(UserDTO dto) throws Exception {
		return mapper.compUserInfo(dto);
	}

	@Override
	public int compPwdUpdate(UserDTO dto) throws Exception {
		return mapper.compPwdUpdate(dto);
	}

	// ===== 회사/계약/사용자 관리 (compcd.jsp) =====
	@Override public List<CompMdDTO> selCompCdList(CompMdDTO dto) throws Exception { return mapper.selCompCdList(dto); }
	@Override public String CompCdMstDupChk(CompMdDTO dto) throws Exception { return mapper.CompCdMstDupChk(dto); }
	@Override public int insertCompCdMst(CompMdDTO dto) throws Exception { return mapper.insertCompCdMst(dto); }
	@Override public int updateCompCdMst(CompMdDTO dto) throws Exception { return mapper.updateCompCdMst(dto); }

	// ===== 출고장(발주현황표) 업로드 저장 (TBL_SHIPOUT_MST) =====
	@Override public java.util.List<String> selectShipoutActiveShpoutDts(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutActiveShpoutDts(dto); }
	@Override public int markShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.markShipoutHistory(dto); }
	@Override public int deleteShipoutZone(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.deleteShipoutZone(dto); }
	@Override public int getShipoutNextJobSeq(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.getShipoutNextJobSeq(dto); }
	@Override public int insertShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.insertShipoutMst(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutMst(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutPrev(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutPrev(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutHistory(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutHistAll(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutHistAll(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSalesChart(egovframework.sejong.user.model.ClosingDTO dto) throws Exception { return mapper.selectSalesChart(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSalesChartDaily(egovframework.sejong.user.model.ClosingDTO dto) throws Exception { return mapper.selectSalesChartDaily(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectShipoutUploadHist(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutUploadHist(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectShipoutUploadDtl(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutUploadDtl(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutSrcFiles() throws Exception { return mapper.selectShipoutSrcFiles(); }

	// ===== 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 (TBL_SALES_MST) =====
	@Override public int markSalesHistory(egovframework.sejong.user.model.SalesDTO dto) throws Exception { return mapper.markSalesHistory(dto); }
	@Override public int getSalesNextJobSeq(egovframework.sejong.user.model.SalesDTO dto) throws Exception { return mapper.getSalesNextJobSeq(dto); }
	@Override public int insertSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception { return mapper.insertSalesMst(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesMst(egovframework.sejong.user.model.SalesDTO dto) throws Exception { return mapper.selectSalesMst(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.SalesDTO> selectSalesSrcFiles() throws Exception { return mapper.selectSalesSrcFiles(); }

	/* 출고장 정정(2026-07-27) — 배치키가 (DLV_DT + DC_NM) 이라 이름 변경 = 그 배치를 옮기는 것.
	     옮겨갈 이름으로 '같은 납품일자에 이미 활성배치'가 있으면 정정하면 안 된다(활성배치가 둘 → 매출 이중계상).
	     그때는 -1 을 돌려 화면이 "이미 그 출고장 자료가 있다"고 안내하게 한다. */
	@Override public int renameSalesDc(egovframework.sejong.user.model.SalesDTO dto) throws Exception {
		if (mapper.countSalesDcConflict(dto) > 0) return -1;
		return mapper.updateSalesDcNm(dto);
	}
	@Override public int mergeSalepriceFromSales(egovframework.sejong.user.model.SalesDTO dto) throws Exception { return mapper.mergeSalepriceFromSales(dto); }

	// ===== 거래처 마스터 (TBL_VENDOR_MST) =====
	@Override public java.util.List<egovframework.sejong.user.model.VendorDTO> selectVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.selectVendorMst(dto); }
	@Override public int vendorDupChk(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.vendorDupChk(dto); }
	@Override public int insertVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.insertVendorMst(dto); }
	@Override public int updateVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.updateVendorMst(dto); }
	@Override public int deleteVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.deleteVendorMst(dto); }
	@Override public int mergeVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.mergeVendorMst(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziMst() throws Exception { return mapper.selectBiziMst(); }
	@Override public int insertBiziIfAbsent(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.insertBiziIfAbsent(dto); }
	@Override public int updateBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.updateBiziMst(dto); }
	@Override public int deleteBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.deleteBiziMst(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziList(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.selectBiziList(dto); }
	@Override public int biziDupChk(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.biziDupChk(dto); }
	@Override public int insertBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.insertBizi(dto); }
	@Override public int updateBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.updateBizi(dto); }
	@Override public int deleteBizi(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.deleteBizi(dto); }
	/* ===== 정산 마감 공통 유틸 ===== */
	private void guardSettleClosed(String gb, String ym) throws Exception {
		if (ym==null || ym.trim().isEmpty()) return;
		egovframework.sejong.user.model.SettleCloseDTO d = new egovframework.sejong.user.model.SettleCloseDTO();
		d.setSettleGb(gb); d.setCloseYm(ym);
		if (mapper.isSettleClosed(d) > 0) throw new RuntimeException("마감(확정)된 월입니다. 먼저 마감을 해제하세요.");
	}
	private String nextYm(String ym) {   // 'YYYY-MM'/'YYYYMM' → 다음달 'YYYYMM'
		String s = ym.replace("-", "");
		int y = Integer.parseInt(s.substring(0,4)), m = Integer.parseInt(s.substring(4,6));
		m++; if (m > 12) { m = 1; y++; }
		return String.format("%04d%02d", y, m);
	}
	@Override public egovframework.sejong.user.model.SettleCloseDTO selectSettleClose(String settleGb, String ym) throws Exception {
		egovframework.sejong.user.model.SettleCloseDTO d = new egovframework.sejong.user.model.SettleCloseDTO();
		d.setSettleGb(settleGb); d.setCloseYm(ym);
		return mapper.selectSettleClose(d);
	}
	@Override public int confirmSettleClose(String settleGb, String ym, String user) throws Exception {
		// 1) 다음 달 전월이월 자동 반영(다음 달이 이미 확정된 경우는 건너뜀)
		String nym = nextYm(ym);
		egovframework.sejong.user.model.SettleCloseDTO nd = new egovframework.sejong.user.model.SettleCloseDTO();
		nd.setSettleGb(settleGb); nd.setCloseYm(nym);
		if (mapper.isSettleClosed(nd) == 0) {
			if ("PAY".equals(settleGb)) {
				egovframework.sejong.user.model.PaymentDTO cf = new egovframework.sejong.user.model.PaymentDTO();
				cf.setPayYm(nym); cf.setRegUser(user); mapper.carryForwardPayment(cf);
			} else {
				egovframework.sejong.user.model.ReceiveDTO cf = new egovframework.sejong.user.model.ReceiveDTO();
				cf.setRcvYm(nym); cf.setRegUser(user); mapper.carryForwardReceive(cf);
			}
		}
		// 2) 해당 월 확정(잠금)
		egovframework.sejong.user.model.SettleCloseDTO d = new egovframework.sejong.user.model.SettleCloseDTO();
		d.setSettleGb(settleGb); d.setCloseYm(ym); d.setConfirmUser(user);
		return mapper.confirmSettleClose(d);
	}
	@Override public int cancelSettleClose(String settleGb, String ym, String user) throws Exception {
		egovframework.sejong.user.model.SettleCloseDTO d = new egovframework.sejong.user.model.SettleCloseDTO();
		d.setSettleGb(settleGb); d.setCloseYm(ym); d.setUpdUser(user);
		return mapper.cancelSettleClose(d);
	}
	/* ===== 수금/미수금 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.ReceiveDTO> selectReceiveList(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception { return mapper.selectReceiveList(dto); }
	@Override public int insertReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception { guardSettleClosed("RCV", dto.getRcvYm()); return mapper.insertReceive(dto); }
	@Override public int updateReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception { guardSettleClosed("RCV", dto.getRcvYm()); return mapper.updateReceive(dto); }
	@Override public int deleteReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception { guardSettleClosed("RCV", dto.getRcvYm()); return mapper.deleteReceive(dto); }
	@Override public int upsertReceiveList(java.util.List<egovframework.sejong.user.model.ReceiveDTO> rows, String regUser, String regIp) throws Exception {
		if (rows == null) return 0;
		int n = 0;
		for (egovframework.sejong.user.model.ReceiveDTO r : rows) {
			if (r.getRcvYm()==null || r.getRcvYm().trim().isEmpty() || r.getBizCd()==null || r.getBizCd().trim().isEmpty()) continue;
			guardSettleClosed("RCV", r.getRcvYm());
			r.setRegUser(regUser); r.setRegIp(regIp);
			n += mapper.upsertReceive(r);
		}
		return n;
	}
	@Override public int carryForwardReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception { guardSettleClosed("RCV", dto.getRcvYm()); return mapper.carryForwardReceive(dto); }
	/* ===== 출금/미지급 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.PaymentDTO> selectPaymentList(egovframework.sejong.user.model.PaymentDTO dto) throws Exception { return mapper.selectPaymentList(dto); }
	@Override public int insertPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception { guardSettleClosed("PAY", dto.getPayYm()); return mapper.insertPayment(dto); }
	@Override public int updatePayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception { guardSettleClosed("PAY", dto.getPayYm()); return mapper.updatePayment(dto); }
	@Override public int deletePayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception { guardSettleClosed("PAY", dto.getPayYm()); return mapper.deletePayment(dto); }
	@Override public int upsertPaymentList(java.util.List<egovframework.sejong.user.model.PaymentDTO> rows, String regUser, String regIp) throws Exception {
		if (rows == null) return 0;
		int n = 0;
		for (egovframework.sejong.user.model.PaymentDTO r : rows) {
			if (r.getPayYm()==null || r.getPayYm().trim().isEmpty() || r.getBizCd()==null || r.getBizCd().trim().isEmpty()) continue;
			guardSettleClosed("PAY", r.getPayYm());
			r.setRegUser(regUser); r.setRegIp(regIp);
			n += mapper.upsertPayment(r);
		}
		return n;
	}
	@Override public int carryForwardPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception { guardSettleClosed("PAY", dto.getPayYm()); return mapper.carryForwardPayment(dto); }

	@Override public java.util.List<egovframework.sejong.user.model.ProdDTO> selectProdList(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.selectProdList(dto); }
	@Override public int insertProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.insertProd(dto); }
	@Override public int updateProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.updateProd(dto); }
	@Override public int deleteProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.deleteProd(dto); }
	@Override public int countProdRelated(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.countProdRelated(dto); }

	/* ===== 매입가 이력 : 등록 시 마스터(IN_PRICE) 동기화 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.ProdInpriceDTO> selectInpriceList(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception { return mapper.selectInpriceList(dto); }
	@Override public int insertInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception {
		int n = mapper.insertInprice(dto);
		mapper.syncProdInPrice(dto);   // TBL_PROD_MST.IN_PRICE ← 새 매입단가
		return n;
	}
	@Override public int deleteInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception { return mapper.deleteInprice(dto); }

	/* ===== 판매가 이력 : 등록 시 마스터(SALE_PRICE/WHOLE_PRICE) 동기화 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.ProdSalepriceDTO> selectSalepriceList(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception { return mapper.selectSalepriceList(dto); }
	@Override public int insertSaleprice(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception {
		int n = mapper.insertSaleprice(dto);
		// 공통가(판매처 없음)만 마스터 동기화 — 판매처 전용가가 기본가(SALE_PRICE)를 덮으면 안 된다
		if (dto.getVendorCd() == null || dto.getVendorCd().trim().isEmpty())
			mapper.syncProdSalePrice(dto); // TBL_PROD_MST.SALE_PRICE/WHOLE_PRICE ← 새 판매/도매단가
		return n;
	}
	@Override public int deleteSaleprice(egovframework.sejong.user.model.ProdSalepriceDTO dto) throws Exception { return mapper.deleteSaleprice(dto); }

	/* ===== 재고 수불 : 원장 입출력 후 현재고(TBL_STOCK_MST) 재집계 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.StockLedgerDTO> selectStockLedgerList(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception { return mapper.selectStockLedgerList(dto); }
	@Override public egovframework.sejong.user.model.StockMstDTO selectStockMst(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception { return mapper.selectStockMst(dto); }
	@Override public int insertStockLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception {
		guardClosed(dto.getTrxDt());   // 마감 확정월 잠금
		int n = mapper.insertStockLedger(dto);
		mapper.recalcStockMst(dto);    // 원장 누계로 현재고 재집계
		return n;
	}
	@Override public int deleteStockLedger(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception {
		guardClosed(dto.getTrxDt());   // 마감 확정월 잠금
		int n = mapper.deleteStockLedger(dto);
		mapper.recalcStockMst(dto);    // 삭제 후에도 현재고 재집계
		return n;
	}
	@Override public java.util.List<egovframework.sejong.user.model.StockMstDTO> selectStockMstList(egovframework.sejong.user.model.StockMstDTO dto) throws Exception { return mapper.selectStockMstList(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.StockLedgerDTO> selectInboundList(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception { return mapper.selectInboundList(dto); }
	/* (A) 출고(SHIPOUT)→원장 자동연동 : 해당 출고일자 O행을 지우고 활성 SHIPOUT으로 다시 생성. 마감 확정월이면 원장 불변이므로 skip */
	@Override public int syncShipoutLedgerDate(String shpoutDt, String regUser, String regIp) throws Exception {
		if (shpoutDt == null || shpoutDt.trim().isEmpty()) return 0;
		String cym = ym6FromTrx(shpoutDt);
		if (cym != null && mapper.isClosedYm(cym) > 0) return 0;   // 마감 확정월 → 원장 건드리지 않음
		egovframework.sejong.user.model.StockLedgerDTO d = new egovframework.sejong.user.model.StockLedgerDTO();
		d.setTrxDt(shpoutDt); d.setRegUser(regUser); d.setRegIp(regIp);
		mapper.deleteShipoutLedger(d);
		return mapper.insertShipoutLedger(d);
	}
	@Override public int recalcStockMstAll(String regUser, String regIp) throws Exception {
		egovframework.sejong.user.model.StockLedgerDTO d = new egovframework.sejong.user.model.StockLedgerDTO();
		d.setRegUser(regUser); d.setRegIp(regIp);
		return mapper.recalcStockMstAll(d);
	}
	/* (A) 화면 버튼: 전체 출고일자를 돌며 원장 O행 재동기화 후 전체 현재고 재집계 (백필 SQL 없이 UI에서 실행) */
	@Override public int rebuildShipoutLedgerAll(String regUser, String regIp) throws Exception {
		int dates = 0;
		java.util.List<String> ds = mapper.selectShipoutDates();
		if (ds != null) for (String d : ds) { syncShipoutLedgerDate(d, regUser, regIp); dates++; }
		recalcStockMstAll(regUser, regIp);
		return dates;
	}
	@Override public java.util.List<String> selectClosedYmList() throws Exception { return mapper.selectClosedYmList(); }
	/* 거래일자(YYYY-MM-DD)의 월이 마감 확정되었으면 예외 → 수불 등록/삭제 차단 */
	private void guardClosed(String trxDt) throws Exception {
		String cym = ym6FromTrx(trxDt);
		if (cym != null && mapper.isClosedYm(cym) > 0)
			throw new Exception("["+cym.substring(0,4)+"-"+cym.substring(4,6)+"] 마감 확정된 월입니다. 마감 확정을 먼저 해제해야 재고 수불을 변경할 수 있습니다.");
	}
	private String ym6(String ymDash) { if (ymDash==null) return null; String s=ymDash.replace("-",""); return s.length()>=6 ? s.substring(0,6) : s; }
	private String ym6FromTrx(String trx) { if (trx==null) return null; String s=trx.replace("-",""); return s.length()>=6 ? s.substring(0,6) : null; }

	/* ===== 마감 확정/해제/조회 ===== */
	@Override public egovframework.sejong.user.model.ClosingMstDTO selectClosingMst(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception {
		if (dto.getCloseYm()==null) dto.setCloseYm(ym6(dto.getYm()));
		return mapper.selectClosingMst(dto);
	}
	@Override public java.util.List<egovframework.sejong.user.model.ClosingMstDTO> selectClosingMstList(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception { return mapper.selectClosingMstList(dto); }
	@Override public int confirmClosing(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception {
		String ymDash = dto.getYm();
		String cym = ym6(ymDash);
		// ① 매출/매출원가 (출고 기준)
		egovframework.sejong.user.model.ClosingDTO cq = new egovframework.sejong.user.model.ClosingDTO(); cq.setYm(ymDash);
		double sAmt=0, cogs=0;
		for (egovframework.sejong.user.model.ClosingDTO r : mapper.selectClosing(cq)) {
			sAmt += r.getSalesAmt()!=null ? r.getSalesAmt() : 0;
			cogs += r.getCostAmt()!=null ? r.getCostAmt() : 0;
		}
		// ② 매입 (입고 수불 기준)
		egovframework.sejong.user.model.StockClosingDTO sq = new egovframework.sejong.user.model.StockClosingDTO(); sq.setYm(ymDash);
		double pAmt=0;
		for (egovframework.sejong.user.model.StockClosingDTO r : mapper.selectInboundClosing(sq)) pAmt += r.getInAmt()!=null ? r.getInAmt() : 0;
		// ③ 재고 (기말재고금액) + 스냅샷 대상
		java.util.List<egovframework.sejong.user.model.StockClosingDTO> stock = mapper.selectStockClosing(sq);
		double stkAmt=0;
		for (egovframework.sejong.user.model.StockClosingDTO r : stock) {
			double q = r.getEndQty()!=null ? r.getEndQty() : 0, a = r.getAvgInPrice()!=null ? r.getAvgInPrice() : 0;
			stkAmt += q*a;
		}
		// ④ 헤더 upsert (UPDATE 먼저 → 0건이면 INSERT)
		dto.setCloseYm(cym); dto.setStatus("C");
		dto.setSalesAmt(sAmt); dto.setCogsAmt(cogs); dto.setMarginAmt(sAmt-cogs); dto.setPurchaseAmt(pAmt); dto.setStockAmt(stkAmt);
		if (mapper.updateClosingMst(dto) == 0) mapper.insertClosingMst(dto);
		// ⑤ 재고 스냅샷 재작성(이월 근거)
		mapper.deleteClosingStock(cym);
		for (egovframework.sejong.user.model.StockClosingDTO r : stock) { r.setYm(ymDash); mapper.insertClosingStock(r); }
		return 1;
	}
	@Override public int cancelClosing(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception {
		String cym = ym6(dto.getYm()); dto.setCloseYm(cym);
		int n = mapper.cancelClosingMst(dto);
		mapper.deleteClosingStock(cym);
		return n;
	}

	/* ===== 마감 집계 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.ClosingDTO> selectClosing(egovframework.sejong.user.model.ClosingDTO dto) throws Exception { return mapper.selectClosing(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ClosingDTO> selectClosingUnmatched(egovframework.sejong.user.model.ClosingDTO dto) throws Exception { return mapper.selectClosingUnmatched(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.StockClosingDTO> selectStockClosing(egovframework.sejong.user.model.StockClosingDTO dto) throws Exception { return mapper.selectStockClosing(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.StockClosingDTO> selectInboundClosing(egovframework.sejong.user.model.StockClosingDTO dto) throws Exception { return mapper.selectInboundClosing(dto); }

	@Override public List<CompConDTO> selectCompContList(CompConDTO dto) throws Exception { return mapper.selectCompContList(dto); }
	@Override public List<CompConDTO> getCompContList(CompConDTO dto) throws Exception { return mapper.getCompContList(dto); }
	@Override public String CompContDupChk(CompConDTO dto) throws Exception { return mapper.CompContDupChk(dto); }
	@Override public int insertCompCont(CompConDTO dto) throws Exception { return mapper.insertCompCont(dto); }
	@Override public int updateCompCont(CompConDTO dto) throws Exception { return mapper.updateCompCont(dto); }

	@Override public java.util.List<java.util.Map<String,Object>> selectCommCodeList(java.util.Map<String,Object> param) throws Exception { return mapper.selectCommCodeList(param); }

	// ===== 공통코드 관리 (codecd.jsp) =====
	@Override public List<egovframework.sejong.user.model.CodeMdDTO> codeMstList(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.codeMstList(dto); }
	@Override public String codeMstDupChk(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.codeMstDupChk(dto); }
	@Override public int insertCodeMst(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.insertCodeMst(dto); }
	@Override public int updateCodeMst(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.updateCodeMst(dto); }
	@Override public List<egovframework.sejong.user.model.CodeMdDTO> codeDtlList(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.codeDtlList(dto); }
	@Override public String codeDtlDupChk(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.codeDtlDupChk(dto); }
	@Override public int insertCodeDtl(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.insertCodeDtl(dto); }
	@Override public int updateCodeDtl(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception { return mapper.updateCodeDtl(dto); }
	@Override public List<UserDTO> compUserList(UserDTO dto) throws Exception { return mapper.compUserList(dto); }
	@Override public int insertCompUser(UserDTO dto) throws Exception { return mapper.insertCompUser(dto); }
	@Override public int updateCompUser(UserDTO dto) throws Exception { return mapper.updateCompUser(dto); }
	@Override public String CompUserDupChk(UserDTO dto) throws Exception { return mapper.CompUserDupChk(dto); }
	@Override public String CompUseridDupChk(UserDTO dto) throws Exception { return mapper.CompUseridDupChk(dto); }

	@Override
	public UserDTO userInfo(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userInfo(dto);
	}

	@Override
	public boolean userPwdReset(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userPwdReset(dto);
	}

	@Override
	public boolean userPwdChange(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userPwdChange(dto);
	}

	@Override
	public List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception {
		return mapper.getSignList(map);
	}

	@Override
	public String selectLatestTermsSeq(String termsGb) throws Exception {
		return mapper.selectLatestTermsSeq(termsGb);
	}

	@Override
	public int insertPersign(PersignDTO dto) throws Exception {
		return mapper.insertPersign(dto);
	}

	@Override
	public int saveAllPatientAgreements(String userUuid, String regId) throws Exception {
		// SEJONG_APP login.jsp 의 약관 3종 (3=이용약관, 1=개인정보, 2=고유식별) 모두 동의 상태로 저장.
		// T_SIGN_MST/T_PERSIGN_TRAN 이 아직 없거나 비어 있는 케이스(초기 운영)를 흡수하기 위해
		// 각 termsGb 처리를 개별 try/catch 로 격리 — 1개가 실패해도 다른 항목은 계속 시도.
		String[] termsGbList = { "1", "2", "3" };
		int total = 0;
		for (String gb : termsGbList) {
			try {
				String termsSeq = mapper.selectLatestTermsSeq(gb);
				if (termsSeq == null || termsSeq.isEmpty()) {
					// 해당 termsGb 의 활성 약관이 없으면 기록하지 않음 (마스터 미설정/빈 테이블 케이스).
					LOGGER.info("[Persign] no active termsSeq for termsGb={} — skip", gb);
					continue;
				}
				PersignDTO p = new PersignDTO();
				p.setUserUuid(userUuid);
				p.setTermsSeq(termsSeq);
				p.setTermsGb(gb);
				p.setAgreeYn("Y");
				p.setRegId(regId);
				total += mapper.insertPersign(p);
			} catch (Exception perGbEx) {
				// 테이블 미존재 등의 SQL 오류 — 다음 termsGb 계속 시도.
				LOGGER.warn("[Persign] save failed for termsGb={} (table missing/schema mismatch?): {}",
						gb, perGbEx.getMessage());
			}
		}
		return total;
	}


	/* ===== 매입등록 (2026-07-25) =====================================================
	   전표가 원본이고, 재고원장·매입단가 이력은 저장할 때 만들어지는 파생 기록이다.
	   그래서 재고현황·재고마감·매입마감·매출마감 원가가 별도 작업 없이 맞는다.
	   수정은 '지우고 다시 넣기' — 명세 행이 늘거나 줄 수 있어 부분 갱신보다 안전하다. */
	@Override public java.util.List<egovframework.sejong.user.model.PurchaseDTO> selectPurchaseList(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception { return mapper.selectPurchaseList(dto); }
	@Override public String selectPurchaseNextNo(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception { return mapper.selectPurchaseNextNo(dto); }
	@Override public Double selectVendorLastPrice(egovframework.sejong.user.model.PurchaseDtlDTO dto) throws Exception { return mapper.selectVendorLastPrice(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.PurchaseDtlDTO> selectPurchasePriceHist(egovframework.sejong.user.model.PurchaseDtlDTO dto) throws Exception { return mapper.selectPurchasePriceHist(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectPurchaseLedger(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception { return mapper.selectPurchaseLedger(dto); }

	@Override public egovframework.sejong.user.model.PurchaseDTO selectPurchaseOne(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception {
		java.util.List<egovframework.sejong.user.model.PurchaseDTO> l = mapper.selectPurchaseList(dto);
		egovframework.sejong.user.model.PurchaseDTO head = null;
		for (egovframework.sejong.user.model.PurchaseDTO r : l) {
			if (r.getPurchSeq()!=null && r.getPurchSeq().equals(dto.getPurchSeq())) { head = r; break; }
		}
		if (head == null) return null;
		head.setItems(mapper.selectPurchaseDtl(dto));
		return head;
	}

	@Override public int savePurchase(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception {
		boolean isNew = (dto.getPurchSeq() == null || dto.getPurchSeq() <= 0);
		if (isNew) {
			if (dto.getPurchNo()==null || dto.getPurchNo().trim().isEmpty()) dto.setPurchNo(mapper.selectPurchaseNextNo(dto));
			mapper.insertPurchaseMst(dto);          // useGeneratedKeys → dto.purchSeq 채워짐
		} else {
			// 이 전표가 만든 파생 원장·명세를 먼저 걷어낸다(전표번호는 그대로 유지)
			mapper.deletePurchaseLedger(dto);
			mapper.deletePurchaseDtlAll(dto);
			mapper.updatePurchaseMst(dto);
		}
		java.util.List<egovframework.sejong.user.model.PurchaseDtlDTO> items = dto.getItems();
		if (items == null) return 0;
		String refNo = ym8(dto.getPurchDt()) + "-" + (dto.getPurchNo()==null?"":dto.getPurchNo());
		int rowNo = 0;
		for (egovframework.sejong.user.model.PurchaseDtlDTO d : items) {
			if (d.getProdCd()==null || d.getProdCd().trim().isEmpty()) continue;   // 빈 줄 건너뜀
			rowNo++;
			d.setPurchSeq(dto.getPurchSeq());
			d.setRowNo(rowNo);
			d.setRegUser(dto.getRegUser()); d.setRegIp(dto.getRegIp());
			if (d.getTrxGb()==null || d.getTrxGb().trim().isEmpty()) d.setTrxGb("매입");

			// ① 파생 재고원장 — 반품이면 R(+), 매입이면 I(+). 원장 QTY 는 int 라 반올림한다
			egovframework.sejong.user.model.StockLedgerDTO led = new egovframework.sejong.user.model.StockLedgerDTO();
			led.setProdSeq(d.getProdSeq()); led.setProdCd(d.getProdCd());
			led.setTrxDt(dto.getPurchDt());
			led.setIoGb("반품".equals(d.getTrxGb()) ? "R" : "I");
			double q = d.getQty()==null ? 0d : d.getQty();
			led.setQty((int) Math.round("반품".equals(d.getTrxGb()) ? -q : q));
			led.setUnitPrice(d.getUnitPrice());
			led.setAmt(d.getAmt());
			led.setVendorCd(dto.getVendorCd());
			led.setRefGb("PURCH"); led.setRefNo(refNo);
			led.setRemark(d.getRemark());
			led.setRegUser(dto.getRegUser()); led.setRegIp(dto.getRegIp());
			mapper.insertStockLedger(led);
			mapper.recalcStockMst(led);

			mapper.insertPurchaseDtl(d);

			// ② 매입단가 이력 — 판매단가가 정산엑셀에서 쌓이는 것과 같은 방식(적용일자 = 매입일자)
			if (d.getUnitPrice()!=null && d.getUnitPrice() > 0 && !"반품".equals(d.getTrxGb())) {
				egovframework.sejong.user.model.ProdInpriceDTO ip = new egovframework.sejong.user.model.ProdInpriceDTO();
				ip.setProdSeq(d.getProdSeq()); ip.setProdCd(d.getProdCd());
				ip.setVendorCd(dto.getVendorCd()); ip.setVendorNm(dto.getVendorNm());
				ip.setApplyDt(dto.getPurchDt()); ip.setInPrice(d.getUnitPrice());
				ip.setRemark("매입등록 " + refNo);
				ip.setRegUser(dto.getRegUser()); ip.setRegIp(dto.getRegIp());
				try { mapper.insertInprice(ip); mapper.syncProdInPrice(ip); }
				catch (Exception ignore) { LOGGER.warn("매입단가 이력 적재 건너뜀 : " + d.getProdCd() + " / " + ignore.getMessage()); }
			}
		}
		return rowNo;
	}

	@Override public int deletePurchase(egovframework.sejong.user.model.PurchaseDTO dto) throws Exception {
		mapper.deletePurchaseLedger(dto);
		mapper.deletePurchaseDtlAll(dto);
		return mapper.deletePurchaseMst(dto);
	}

	/** 'yyyy-mm-dd' | 'yyyymmdd' → 'yyyymmdd' */
	private String ym8(String s) { return s==null ? "" : s.replace("-", "").trim(); }
	/* ===== 수금/지급 등록 — 2026-07-25 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.SettleTrxDTO> selectSettleList(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectSettleList(dto); }
	@Override public String selectSettleNextNo(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectSettleNextNo(dto); }
	@Override public int insertSettleTrx(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception {
		if (dto.getTrxNo()==null || dto.getTrxNo().trim().isEmpty()) dto.setTrxNo(mapper.selectSettleNextNo(dto));
		return mapper.insertSettleTrx(dto);
	}
	@Override public int updateSettleTrx(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.updateSettleTrx(dto); }
	@Override public int deleteSettleTrx(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.deleteSettleTrx(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectCustLedger(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectCustLedger(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectCustBalance(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectCustBalance(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectCustDayDetail(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectCustDayDetail(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectDayBook(egovframework.sejong.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectDayBook(dto); }

	/* ===== 판매등록 — 2026-07-25. savePurchase 와 대칭 =====
	   매입은 재고가 들어오고(I), 판매는 나간다(O). 그 한 가지가 다르다.
	   매입에 있던 '매입단가 이력 적재'는 여기 없다 — 판매단가 이력은 상품관리의
	   판매가 탭(TBL_PROD_SALEPRICE_HST)이 따로 담당하고, 그건 정산서 밖 판매도
	   손으로 등록할 수 있게 열어둔 칸이라 전표가 덮어쓰면 안 된다. */
	@Override public java.util.List<egovframework.sejong.user.model.SalesTrxDTO> selectSalesTrxList(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception { return mapper.selectSalesTrxList(dto); }
	@Override public String selectSalesTrxNextNo(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception { return mapper.selectSalesTrxNextNo(dto); }
	@Override public Double selectCustLastPrice(egovframework.sejong.user.model.SalesTrxDtlDTO dto) throws Exception { return mapper.selectCustLastPrice(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.SalesTrxDtlDTO> selectSalesPriceHist(egovframework.sejong.user.model.SalesTrxDtlDTO dto) throws Exception { return mapper.selectSalesPriceHist(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSalesTrxHist(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception { return mapper.selectSalesTrxHist(dto); }

	@Override public egovframework.sejong.user.model.SalesTrxDTO selectSalesTrxOne(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception {
		java.util.List<egovframework.sejong.user.model.SalesTrxDTO> l = mapper.selectSalesTrxList(dto);
		egovframework.sejong.user.model.SalesTrxDTO head = null;
		for (egovframework.sejong.user.model.SalesTrxDTO r : l) {
			if (r.getSaleSeq()!=null && r.getSaleSeq().equals(dto.getSaleSeq())) { head = r; break; }
		}
		if (head == null) return null;
		head.setItems(mapper.selectSalesTrxDtl(dto));
		return head;
	}

	@Override public int saveSalesTrx(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception {
		boolean isNew = (dto.getSaleSeq() == null || dto.getSaleSeq() <= 0);
		if (isNew) {
			if (dto.getSaleNo()==null || dto.getSaleNo().trim().isEmpty()) dto.setSaleNo(mapper.selectSalesTrxNextNo(dto));
			mapper.insertSalesTrxMst(dto);          // useGeneratedKeys → dto.saleSeq 채워짐
		} else {
			// 이 전표가 만든 파생 원장·명세를 먼저 걷어낸다(전표번호는 그대로 유지)
			mapper.deleteSalesTrxLedger(dto);
			mapper.deleteSalesTrxDtlAll(dto);
			mapper.updateSalesTrxMst(dto);
		}
		java.util.List<egovframework.sejong.user.model.SalesTrxDtlDTO> items = dto.getItems();
		if (items == null) return 0;
		String refNo = ym8(dto.getSaleDt()) + "-" + (dto.getSaleNo()==null?"":dto.getSaleNo());
		int rowNo = 0;
		for (egovframework.sejong.user.model.SalesTrxDtlDTO d : items) {
			if (d.getProdCd()==null || d.getProdCd().trim().isEmpty()) continue;   // 빈 줄 건너뜀
			rowNo++;
			d.setSaleSeq(dto.getSaleSeq());
			d.setRowNo(rowNo);
			d.setRegUser(dto.getRegUser()); d.setRegIp(dto.getRegIp());
			if (d.getTrxGb()==null || d.getTrxGb().trim().isEmpty()) d.setTrxGb("판매");

			// 파생 재고원장 — 판매는 출고 'O', 판매반품(고객이 되돌려줌)은 'R'.
			// ★ 부호 주의 : 집계(recalcStockMst·재고현황)가
			//     IO_GB IN ('I','R') → +QTY,  IO_GB='O' → -QTY
			//   로 뒤집으므로 QTY 는 둘 다 양수로 넣는다. 여기서 음수를 넣으면
			//   판매했는데 재고가 늘어난다. (매입의 '반품'은 우리가 되돌려보내는 것이라
			//    'R'에 음수를 넣는데, 판매반품은 방향이 반대라 양수다.)
			// 원장 QTY 는 int 라 반올림한다(매입과 같다).
			egovframework.sejong.user.model.StockLedgerDTO led = new egovframework.sejong.user.model.StockLedgerDTO();
			led.setProdSeq(d.getProdSeq()); led.setProdCd(d.getProdCd());
			led.setTrxDt(dto.getSaleDt());
			boolean isReturn = "반품".equals(d.getTrxGb());
			led.setIoGb(isReturn ? "R" : "O");
			double q = d.getQty()==null ? 0d : d.getQty();
			led.setQty((int) Math.round(Math.abs(q)));
			led.setUnitPrice(d.getUnitPrice());
			led.setAmt(d.getAmt());
			led.setVendorCd(dto.getCustCd());
			led.setRefGb("SALE"); led.setRefNo(refNo);
			led.setRemark(d.getRemark());
			led.setRegUser(dto.getRegUser()); led.setRegIp(dto.getRegIp());
			mapper.insertStockLedger(led);
			mapper.recalcStockMst(led);

			mapper.insertSalesTrxDtl(d);

			// ② 판매단가 이력 — 매입등록이 매입단가 이력을 쌓는 것과 대칭(2026-07-25 추가).
			//    상품관리의 판매가 탭을 조회 전용으로 바꾸면서, 이력을 만드는 책임이 전표로 넘어왔다.
			//    ★ vendorCd 를 함께 넣는다 = '그 거래처 전용가'로 쌓인다.
			//      insertSaleprice 는 거래처가 비었을 때만 마스터 SALE_PRICE 를 덮으므로,
			//      한 거래처에 싸게 판 값이 전 품목 기본 판매가를 덮어쓰는 사고가 나지 않는다.
			if (d.getUnitPrice()!=null && d.getUnitPrice() > 0 && !"반품".equals(d.getTrxGb())) {
				egovframework.sejong.user.model.ProdSalepriceDTO sp = new egovframework.sejong.user.model.ProdSalepriceDTO();
				sp.setProdSeq(d.getProdSeq()); sp.setProdCd(d.getProdCd());
				sp.setVendorCd(dto.getCustCd()); sp.setVendorNm(dto.getCustNm());
				sp.setApplyDt(dto.getSaleDt()); sp.setSalePrice(d.getUnitPrice());
				sp.setRemark("판매등록 " + refNo);
				sp.setRegUser(dto.getRegUser()); sp.setRegIp(dto.getRegIp());
				try { insertSaleprice(sp); }
				catch (Exception ignore) { LOGGER.warn("판매단가 이력 적재 건너뜀 : " + d.getProdCd() + " / " + ignore.getMessage()); }
			}
		}
		return rowNo;
	}

	@Override public int deleteSalesTrx(egovframework.sejong.user.model.SalesTrxDTO dto) throws Exception {
		mapper.deleteSalesTrxLedger(dto);
		mapper.deleteSalesTrxDtlAll(dto);
		return mapper.deleteSalesTrxMst(dto);
	}
}
