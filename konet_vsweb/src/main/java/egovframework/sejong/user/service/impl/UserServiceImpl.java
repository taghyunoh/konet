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
	@Override public int insertShipoutMstBulk(java.util.List<egovframework.sejong.user.model.ShipoutDTO> list) throws Exception { return mapper.insertShipoutMstBulk(list); }
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
	@Override public java.util.List<java.util.Map<String,Object>> selectVendorTrxSum(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.selectVendorTrxSum(dto); }
	@Override public int vendorDupChk(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.vendorDupChk(dto); }
	@Override public int insertVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.insertVendorMst(dto); }
	@Override public int updateVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.updateVendorMst(dto); }
	@Override public int deleteVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.deleteVendorMst(dto); }
	@Override public int mergeVendorMst(egovframework.sejong.user.model.VendorDTO dto) throws Exception { return mapper.mergeVendorMst(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziMst() throws Exception { return mapper.selectBiziMst(); }
	@Override public int insertBiziIfAbsent(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.insertBiziIfAbsent(dto); }
	@Override public int updateBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.updateBiziMst(dto); }
	@Override public int updateBiziParcel(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.updateBiziParcel(dto); }
	@Override public int updateBiziMatch(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.updateBiziMatch(dto); }
	@Override public int biziMatchNextNo(egovframework.sejong.user.model.BiziDTO dto) throws Exception { return mapper.biziMatchNextNo(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectParcelOutList(java.util.Map<String,Object> p) throws Exception { return mapper.selectParcelOutList(p); }
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
	@Override public int insertReceive(egovframework.sejong.user.model.ReceiveDTO dto) throws Exception {
		guardSettleClosed("RCV", dto.getRcvYm());
		/* MERGE — 삭제(N)행 되살림/신규 INSERT. 살아있는 중복이면 0건 → 2601 대신 알아듣는 안내(2026-08-05) */
		int n = mapper.insertReceive(dto);
		if (n == 0) throw new Exception("이미 등록된 귀속월·거래처입니다. 목록에서 해당 행을 직접 수정하세요.");
		return n;
	}
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
	@Override public int insertPayment(egovframework.sejong.user.model.PaymentDTO dto) throws Exception {
		guardSettleClosed("PAY", dto.getPayYm());
		/* MERGE — 삭제(N)행 되살림/신규 INSERT. 살아있는 중복이면 0건 → 2601 대신 알아듣는 안내(2026-08-05) */
		int n = mapper.insertPayment(dto);
		if (n == 0) throw new Exception("이미 등록된 귀속월·매입처입니다. 목록에서 해당 행을 직접 수정하세요.");
		return n;
	}
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
	@Override public java.util.List<egovframework.sejong.user.model.ProdDTO> selectProdDeletedList(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.selectProdDeletedList(dto); }
	@Override public int restoreProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.restoreProd(dto); }
	@Override public int stopProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.stopProd(dto); }
	@Override public int unstopProd(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.unstopProd(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ProdDTO> selectStoppedAmong(java.util.Map<String,Object> p) throws Exception { return mapper.selectStoppedAmong(p); }
	@Override public egovframework.sejong.user.model.ProdDTO selectProdStopById(java.util.Map<String,Object> p) throws Exception { return mapper.selectProdStopById(p); }

	@Override public int countProdRelated(egovframework.sejong.user.model.ProdDTO dto) throws Exception { return mapper.countProdRelated(dto); }

	/* ===== 매입가 이력 : 등록 시 마스터(IN_PRICE) 동기화 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.ProdInpriceDTO> selectInpriceList(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception { return mapper.selectInpriceList(dto); }
	@Override public int insertInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception {
		int n = mapper.insertInprice(dto);
		mapper.syncProdInPrice(dto);   // TBL_PROD_MST.IN_PRICE ← 새 매입단가
		return n;
	}
	@Override public int deleteInprice(egovframework.sejong.user.model.ProdInpriceDTO dto) throws Exception { return mapper.deleteInprice(dto); }

	/* ===== 거래처별 품목 표기(교차참조) — TBL_PROD_XREF (2026-08-01) =====================
	   코네트 품목은 하나, 거래처 요청 표기는 이 표에 N건. 가상코드를 만들지 않는다. */
	@Override public java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefList(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefList(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectUnmappedItems(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectUnmappedItems(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefCandidates(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefCandidates(dto); }
	@Override public int confirmXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception { return mapper.confirmXref(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefAudit(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefAudit(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ProdXrefDTO> selectXrefNames(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefNames(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.ExtItemDTO> selectSubCodesAmong(java.util.Map<String,Object> param) throws Exception { return mapper.selectSubCodesAmong(param); }

	/* 등록/수정 — 저장만 하고 끝내면 안 된다.
	   ★매핑을 뒤늦게 걸면 그동안 PROD_SEQ 가 비어 재고에서 빠져 있던 출고분이 남는다.
	     저장 직후 resolve* 로 과거분을 소급으로 채우고, 그 품목이 걸린 출고일자만 골라
	     원장을 다시 만든다. 이 한 걸음이 빠지면 '연결했는데 재고가 그대로'가 된다.
	   ★재고 재동기화 실패가 매핑 저장을 롤백하지 않도록 별도 try — 실패해도 매핑은 남고
	     [재고 재집계] 버튼으로 복구할 수 있다. */
	@Override public int saveXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception {
		if ("Y".equals(dto.getMainYn())) mapper.clearXrefMain(dto);   // 그 거래처의 대표 표기는 하나
		int n = (dto.getXrefSeq() == null) ? mapper.insertXref(dto) : mapper.updateXref(dto);

		// 소급 반영 — 이 품목으로 해석되지 않은 과거 업로드분을 채운다
		egovframework.sejong.user.model.ProdXrefDTO f = new egovframework.sejong.user.model.ProdXrefDTO();
		f.setCompCd(dto.getCompCd());
		f.setProdSeq(dto.getProdSeq());
		int back = mapper.resolveShipoutProd(f) + mapper.resolveSalesProd(f);

		if (back > 0) {
			try {
				java.util.List<String> ds = mapper.selectShipoutDatesByProd(f);
				if (ds != null) for (String d : ds) syncShipoutLedgerDate(d, dto.getRegUser(), dto.getRegIp());
				recalcStockMstAll(dto.getRegUser(), dto.getRegIp());
			} catch (Exception se) {
				LOGGER.error(" saveXref 재고 소급반영 WARN : " + se.getMessage());
			}
		}
		return n;
	}

	/* ★잘못 연결했을 때 되돌리기 (2026-08-01 — 사용자 질문 "잘못 연결하면 어떻게 고치나요")
	     매핑만 지우면 반쪽이다. 그 코드로 이미 채워진 행의 PROD_SEQ 가 남아 있어
	     **엉뚱한 품목의 재고가 그대로 굳는다**. 그래서 지운 뒤에
	       ① 그 코드로 채워진 출고·정산 행을 NULL 로 되돌리고
	       ② 다시 해석한다(다른 매핑이나 코드 직결로 잡힐 수 있다)
	       ③ 그 코드가 나갔던 출고일자만 골라 재고를 다시 만든다
	     ★출고일자는 되돌리기 '전에' 받아 둔다 — PROD_SEQ 를 비운 뒤에는 찾을 수 없다.
	     ★재고 재생성 실패가 삭제를 롤백하지 않도록 별도 try(로그만) — 실패해도 [재고 재집계]로 복구된다. */
	@Override public int deleteXref(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception {
		egovframework.sejong.user.model.ProdXrefDTO cur = mapper.selectXrefById(dto);   // 무엇을 지우는지 먼저 확보
		int n = mapper.deleteXref(dto);
		if (cur == null || cur.getExtItemCd() == null || cur.getExtItemCd().trim().isEmpty()) return n;

		egovframework.sejong.user.model.ProdXrefDTO f = new egovframework.sejong.user.model.ProdXrefDTO();
		f.setCompCd(dto.getCompCd());
		f.setExtItemCd(cur.getExtItemCd());
		java.util.List<String> ds = mapper.selectShipoutDatesByExtCd(f);   // ★비우기 전에 날짜 확보
		mapper.clearShipoutProdByExtCd(f);
		mapper.clearSalesProdByExtCd(f);

		egovframework.sejong.user.model.ProdXrefDTO all = new egovframework.sejong.user.model.ProdXrefDTO();
		all.setCompCd(dto.getCompCd());
		resolveShipoutProd(all);   // 남은 매핑·코드 직결로 다시 해석 (없으면 미매핑으로 남는다)
		resolveSalesProd(all);

		try {
			if (ds != null) for (String d : ds) syncShipoutLedgerDate(d, dto.getUpdUser(), dto.getUpdIp());
			if (ds != null && !ds.isEmpty()) recalcStockMstAll(dto.getUpdUser(), dto.getUpdIp());
		} catch (Exception se) {
			LOGGER.error(" deleteXref 재고 되돌리기 WARN : " + se.getMessage());
		}
		return n;
	}

	/* 업로드 자료의 '우리 품목' 해석 — 반드시 3패스, 순서가 중요하다. (2026-08-01 통보대장 추가)
	     1차 XREF 매핑   : 사람이 확정한 연결 (품목코드(매핑)·업로드 미리보기의 [연결])
	     2차 통보품목대장 : 거래처 통보를 받아 두면서 우리 상품코드를 미리 골라 둔 것
	     3차 코드 직결   : 거래처가 우리와 같은 코드로 보내는 품목(대다수) — 종전 동작과 동일
	   ★사람이 지정한 것(1·2차)이 먼저다. 직결을 먼저 돌리면 거래처 코드가 우연히 우리 코드와
	     같을 때 지정한 연결을 덮어쓴다. 1차가 2차보다 먼저인 이유 = 잘못 이어진 통보분을
	     XREF 에서 고쳤을 때 그 수정이 이겨야 하기 때문.
	   ★셋 다 못 찾으면 PROD_CD 가 NULL 로 남는다 = 미매핑 → 재고에서 빠진다(보류).
	     즉 **통보대장에 골라 둔 것이 없으면 종전과 완전히 같은 결과**이고,
	     품목코드(매핑)·[연결] 흐름이 그대로 필요하다(2026-08-01 사용자 확정). */
	@Override public int resolveShipoutProd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception {
		return mapper.resolveShipoutProd(dto) + mapper.resolveShipoutProdExt(dto) + mapper.resolveShipoutProdDirect(dto);
	}
	@Override public int resolveSalesProd(egovframework.sejong.user.model.ProdXrefDTO dto) throws Exception {
		return mapper.resolveSalesProd(dto) + mapper.resolveSalesProdExt(dto) + mapper.resolveSalesProdDirect(dto);
	}

	/* ===== 거래처 통보품목 — TBL_EXT_ITEM_MST (2026-08-01) =====
	   거래처가 미리 통보한 코드·품명을 원문 그대로 받아 두는 접수대장.
	   ★여기서 우리 품목과 잇지 않는다 — 매핑 방식은 추후 결정. 그래서 resolve*·재고 재집계를 부르지 않는다
	     (부르면 안 된다. 이 표는 업로드 해석 경로에 아직 끼어 있지 않다). */
	@Override public java.util.List<egovframework.sejong.user.model.ExtItemDTO> selectExtItemList(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception { return mapper.selectExtItemList(dto); }
	@Override public int countExtItemCd(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception { return mapper.countExtItemCd(dto); }
	@Override public int insertExtItem(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception {
		int n = mapper.insertExtItem(dto); extItemRetro(dto); return n;
	}
	@Override public int updateExtItem(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception {
		int n = mapper.updateExtItem(dto); extItemRetro(dto); return n;
	}
	/* ★매칭코드를 지우면 붙여 놨던 것도 되돌린다 (2026-08-06 — deleteXref 와 같은 구조·같은 이유)
	     종전에는 지우기만 해서, 잘못 붙인 코드를 지워도 과거 출고·정산은 그 주코드에 붙은 채 남았다.
	     [출고반영 재집계]로도 안 돌아온다 — resolve* 는 빈 행만 채우고 repoint* 는 매칭코드가 있어야 돈다.
	   ★순서 : 날짜 확보 → 비우기 → 다시 해석(XREF → 남은 매칭코드 → 코드 직결) → 원장 재생성.
	     출고일자는 **비우기 전에** 받아 둔다 — PROD_SEQ 를 지운 뒤에는 그 품목으로 찾을 수 없다.
	   ★상품을 안 고른 줄(prodSeq 없음)은 해석에 쓰인 적이 없으므로 아무것도 되돌릴 게 없다.
	   ★되돌리기 실패가 삭제를 롤백하지 않도록 별도 try — 실패해도 [출고반영 재집계]로 복구된다. */
	@Override public int deleteExtItem(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception {
		egovframework.sejong.user.model.ExtItemDTO cur = mapper.selectExtItemById(dto);   // 무엇을 지우는지 먼저 확보
		int n = mapper.deleteExtItem(dto);
		if (cur == null || cur.getProdSeq() == null) return n;
		if (cur.getExtItemCd() == null || cur.getExtItemCd().trim().isEmpty()) return n;

		egovframework.sejong.user.model.ProdXrefDTO f = new egovframework.sejong.user.model.ProdXrefDTO();
		f.setCompCd(dto.getCompCd());
		f.setExtItemCd(cur.getExtItemCd());
		java.util.List<String> ds = mapper.selectShipoutDatesByExtCd(f);   // ★비우기 전에 날짜 확보
		mapper.clearShipoutProdByExtCd(f);
		mapper.clearSalesProdByExtCd(f);

		egovframework.sejong.user.model.ProdXrefDTO all = new egovframework.sejong.user.model.ProdXrefDTO();
		all.setCompCd(dto.getCompCd());
		resolveShipoutProd(all);   // 남은 매핑·코드 직결로 다시 해석 (없으면 미매핑으로 남는다)
		resolveSalesProd(all);

		try {
			if (ds != null) for (String d : ds) syncShipoutLedgerDate(d, dto.getUpdUser(), dto.getUpdIp());
			if (ds != null && !ds.isEmpty()) recalcStockMstAll(dto.getUpdUser(), dto.getUpdIp());
		} catch (Exception se) {
			LOGGER.error(" deleteExtItem 재고 되돌리기 WARN : " + se.getMessage());
		}
		return n;
	}

	/* ★매칭코드를 붙이면 과거 업로드분까지 소급으로 채운다 (saveXref 와 같은 이유·같은 방식)
	     붙이기 전에 들어온 출고·정산 행은 PROD_SEQ 가 비어 재고에서 빠져 있다. 저장만 하고 끝내면
	     "등록했는데 재고가 그대로 · 품목코드(매핑) 화면에 여전히 미매핑으로 남아 있다" 가 된다.
	   ★상품을 안 고른 줄(prodSeq 없음)은 해석에 쓰이지 않으므로 아무 일도 하지 않는다.
	   ★재고 재동기화 실패가 매칭코드 저장을 롤백하지 않도록 별도 try — 실패해도 [재고 재집계]로 복구된다.
	   ★repoint* 도 같이 돈다 (2026-08-06) — resolve* 는 '아직 안 붙은' 행만 채우므로,
	     거래처 코드가 우리 상품마스터에도 있어 3차 직결로 이미 제 코드에 붙어 버린 과거분은
	     매칭코드를 등록해도 안 옮겨졌다. 그 결과 매입은 주코드·출고는 거래처 코드로 갈려
	     재고가 음수로 보였다(1000736040 → 주코드 9904013222 사례). */
	private void extItemRetro(egovframework.sejong.user.model.ExtItemDTO dto) throws Exception {
		if (dto == null || dto.getProdSeq() == null) return;
		egovframework.sejong.user.model.ProdXrefDTO f = new egovframework.sejong.user.model.ProdXrefDTO();
		f.setCompCd(dto.getCompCd());
		f.setProdSeq(dto.getProdSeq());
		int back = mapper.resolveShipoutProdExt(f) + mapper.resolveSalesProdExt(f)
		         + mapper.repointShipoutProdExt(f) + mapper.repointSalesProdExt(f);
		if (back <= 0) return;
		try {
			java.util.List<String> ds = mapper.selectShipoutDatesByProd(f);
			if (ds != null) for (String d : ds) syncShipoutLedgerDate(d, dto.getRegUser(), dto.getRegIp());
			recalcStockMstAll(dto.getRegUser(), dto.getRegIp());
		} catch (Exception se) {
			LOGGER.error(" extItemRetro 재고 소급반영 WARN : " + se.getMessage());
		}
	}
	/* 통보서 붙여넣기 — 한 줄씩 MERGE(있으면 갱신·없으면 신규). 한 트랜잭션이라 중간에 실패하면 전부 취소된다. */
	@Override public int mergeExtItems(java.util.List<egovframework.sejong.user.model.ExtItemDTO> list) throws Exception {
		if (list == null || list.isEmpty()) return 0;
		int n = 0;
		for (egovframework.sejong.user.model.ExtItemDTO d : list) {
			if (d == null || d.getExtItemCd() == null || d.getExtItemCd().trim().isEmpty()) continue;
			n += mapper.mergeExtItem(d);
		}
		return n;
	}

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
	@Override public java.util.List<egovframework.sejong.user.model.StockMstDTO> selectStockQtyMap(egovframework.sejong.user.model.StockMstDTO dto) throws Exception { return mapper.selectStockQtyMap(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectStockOutByMonth(java.util.Map<String,Object> p) throws Exception { return mapper.selectStockOutByMonth(p); }
	@Override public java.util.List<egovframework.sejong.user.model.StockLedgerDTO> selectInboundList(egovframework.sejong.user.model.StockLedgerDTO dto) throws Exception { return mapper.selectInboundList(dto); }
	/* ══════════════════════════════════════════════════════════════════════════
	 *  발주현황표(SHIPOUT) → 재고원장 연동 종료                        2026-08-19
	 *
	 *  출고 원천을 정산서(TBL_SALES_MST)로 옮겼다. 발주현황표는 이제
	 *  **출고현황을 보는 판**이고, 재고를 만들지 않는다.
	 *
	 *  ★기존 원장행(REF_GB='SHIPOUT')은 지우지 않는다 —
	 *    정산서를 아직 안 올린 과거 기간의 재고가 그대로 유지된다.
	 *    그 날짜에 정산서를 올리면 syncSalesLedger 가 걷어내고 정산서로 바꾼다.
	 *  ★되돌리려면 이 값만 true 로 바꾸면 된다. 호출부는 그대로 두었다.
	 *
	 *  [2026-09-03 되돌림] 다시 true — 정산서가 열흘쯤 늦게 와서 그 사이 재고현황을 볼 수 없었다.
	 *    · 발주현황표 업로드 → 그 출고일자의 O행을 먼저 만든다(예상 출고)
	 *    · 정산서 업로드    → 같은 날의 SHIPOUT 파생행을 걷어내고 정산서로 바꾼다(확정 출고)
	 *    이중 차감 방지 두 겹(syncSalesLedgerCore 의 deleteShipoutLedger + insertShipoutLedger 의
	 *    NOT EXISTS)은 그대로 살아 있어, 켜기만 하면 된다.
	 *  ⚠켠 뒤 <과거 날짜>는 저절로 채워지지 않는다 — 재고현황 [출고반영 재집계] 를 한 번 눌러야 한다.
	 * ════════════════════════════════════════════════════════════════════════ */
	private static final boolean SHIPOUT_LEDGER_ON = true;

	/* (A) 출고(SHIPOUT)→원장 자동연동 : 해당 출고일자 O행을 지우고 활성 SHIPOUT으로 다시 생성. 마감 확정월이면 원장 불변이므로 skip */
	@Override public int syncShipoutLedgerDate(String shpoutDt, String regUser, String regIp) throws Exception {
		if (!SHIPOUT_LEDGER_ON) return 0;          // 연동 종료 — 발주현황표는 재고를 만들지 않는다
		if (shpoutDt == null || shpoutDt.trim().isEmpty()) return 0;
		String cym = ym6FromTrx(shpoutDt);
		if (cym != null && mapper.isClosedYm(cym, null) > 0) return 0;   // 마감 확정월 → 원장 건드리지 않음
		egovframework.sejong.user.model.StockLedgerDTO d = new egovframework.sejong.user.model.StockLedgerDTO();
		d.setTrxDt(shpoutDt); d.setRegUser(regUser); d.setRegIp(regIp);
		mapper.deleteShipoutLedger(d);
		return mapper.insertShipoutLedger(d);
	}
	@Override public int recalcStockMstAll(String regUser, String regIp) throws Exception {
		egovframework.sejong.user.model.StockLedgerDTO d = new egovframework.sejong.user.model.StockLedgerDTO();
		d.setRegUser(regUser); d.setRegIp(regIp);
		int n = mapper.recalcStockMstAll(d);
		/* ★원장에서 사라진 품목의 캐시 0으로 (2026-08-06)
		   위 MERGE 는 원장에 있는 품목만 갱신한다(WHEN NOT MATCHED BY SOURCE 없음). 매칭코드로
		   출고를 주코드로 옮기면 옛 코드는 원장에서 통째로 빠지는데, 캐시표에는 옛 수량이 그대로 남아
		   점검화면 '④ 재고 음수' 에 유령으로 계속 떴다. 재고현황 화면은 원장 직접 집계라 무관. */
		mapper.zeroOrphanStockMst(d);
		return n;
	}
	/* (A) 화면 버튼: 전체 출고일자를 돌며 원장 O행 재동기화 후 전체 현재고 재집계 (백필 SQL 없이 UI에서 실행) */
	@Override public int rebuildShipoutLedgerAll(String regUser, String regIp) throws Exception {
		int dates = 0;
		/* ★재집계 전에 '우리 품목' 부터 해석한다 (2026-08-01).
		   재고연동이 ITEM_CD 가 아니라 PROD_CD 기준으로 바뀌었으므로, PROD_CD 가 안 채워진
		   자료(배포 이전 업로드분·매핑을 뒤늦게 건 품목)는 재집계해도 재고에 안 잡힌다.
		   파라미터를 비우면 resolve* 의 조건이 모두 열려 전체를 훑는다 → 이 버튼 하나가
		   '해석 + 재집계' 를 다 해 준다(배포 직후 1회 눌러 주면 된다). */
		/* 진행 상황을 게시판(RebuildProgress)에 적어 둔다 — 화면이 폴링해 진짜 진행바를 그린다.
		   가짜 막대를 쓰지 않는 이유 : 여기는 '출고일자 몇 개 중 몇 개' 를 실제로 알고 있다.
		   ★반드시 finally 에서 end() — 안 그러면 다음에 열 때 '진행 중' 으로 남는다. */
		String pk = regUser;
		try {
			egovframework.sejong.user.model.ProdXrefDTO all = new egovframework.sejong.user.model.ProdXrefDTO();
			egovframework.sejong.cmmn.RebuildProgress.set(pk, "품목 해석 중… (거래처 코드 → 우리 품목)", 0, 0);
			resolveShipoutProd(all);
			resolveSalesProd(all);
			/* ★매칭코드를 뒤늦게 등록한 품목 되돌려 붙이기 (2026-08-06)
			   resolve* 는 안 붙은 행만 채운다. 거래처 코드가 우리 상품마스터에도 있어 3차 직결로
			   제 코드에 붙어 버린 과거분은 이 버튼으로만 주코드로 옮겨진다. */
			mapper.repointShipoutProdExt(all);
			mapper.repointSalesProdExt(all);

			/* 발주현황표 연동 종료(2026-08-19) — 기존 원장행은 그대로 두고 새로 만들지 않는다.
			   되살리려면 SHIPOUT_LEDGER_ON 만 true 로. */
			java.util.List<String> ds = SHIPOUT_LEDGER_ON ? mapper.selectShipoutDates()
			                                              : new java.util.ArrayList<String>();
			int total = ds.size();
			egovframework.sejong.cmmn.RebuildProgress.set(pk, "출고 원장 재생성", 0, total);
			if (ds != null) for (String d : ds) {
				syncShipoutLedgerDate(d, regUser, regIp);
				dates++;
				egovframework.sejong.cmmn.RebuildProgress.set(pk, "출고 원장 재생성 — " + d, dates, total);
			}

			/* ★정산서 → 원장 재생성 (2026-08-19)
			   출고 원천을 정산서로 옮기는 중이라, 이 버튼이 두 원천을 모두 다시 만든다.
			   정산서가 있는 날짜만 돈다 — 없는 기간은 발주현황표 몫으로 남는다.
			   ※두 원천이 같은 날을 덮으면 그 날 출고가 두 번 빠진다.
			     어느 쪽을 쓸지(D1) 정해지면 여기서 한쪽을 걸러야 한다. */
			java.util.List<String> sds = mapper.selectSalesDates(new egovframework.sejong.user.model.StockLedgerDTO());
			int stotal = (sds == null) ? 0 : sds.size();
			if (stotal > 0) {
				int sdone = 0;
				egovframework.sejong.cmmn.RebuildProgress.set(pk, "정산서 원장 재생성", 0, stotal);
				for (String d : sds) {
					syncSalesLedgerCore(d, null, regUser, regIp);   // 집계는 루프 끝 recalcStockMstAll 1회
					sdone++;
					egovframework.sejong.cmmn.RebuildProgress.set(pk, "정산서 원장 재생성 — " + d, sdone, stotal);
				}
				dates += sdone;
			}
			egovframework.sejong.cmmn.RebuildProgress.set(pk, "현재고 집계 중…", total, total);
			recalcStockMstAll(regUser, regIp);
			return dates;
		} finally {
			egovframework.sejong.cmmn.RebuildProgress.end(pk);
		}
	}
	@Override public java.util.List<String> selectClosedYmList() throws Exception { return mapper.selectClosedYmList(); }
	/* 거래일자(YYYY-MM-DD)의 월이 마감 확정되었으면 예외 → 수불 등록/삭제 차단 */
	private void guardClosed(String trxDt) throws Exception {
		String cym = ym6FromTrx(trxDt);
		if (cym != null && mapper.isClosedYm(cym, null) > 0)
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
		mapper.deleteClosingStock(cym, null);
		for (egovframework.sejong.user.model.StockClosingDTO r : stock) { r.setYm(ymDash); mapper.insertClosingStock(r); }
		return 1;
	}
	@Override public int cancelClosing(egovframework.sejong.user.model.ClosingMstDTO dto) throws Exception {
		String cym = ym6(dto.getYm()); dto.setCloseYm(cym);
		int n = mapper.cancelClosingMst(dto);
		mapper.deleteClosingStock(cym, null);
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

	/* ===== 납품분 / 납품분 제외 — 2026-07-31 ===== */
	@Override public java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectSalesDlvList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception { return mapper.selectSalesDlvList(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectPurchDlvList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception { return mapper.selectPurchDlvList(dto); }
	@Override public java.util.List<egovframework.sejong.user.model.SalesDlvDTO> selectSalesDlvExclList(egovframework.sejong.user.model.SalesDlvDTO dto) throws Exception { return mapper.selectSalesDlvExclList(dto); }
	/** 제외 켜기/끄기 — (거래처+상품) 한 줄을 뒤집는다. 없으면 새로 만든다(켤 때만).
	 *  UNIQUE(COMP_CD,CUST_CD,PROD_CD) 라 같은 품목을 두 번 빼도 줄이 늘지 않는다. */
	@Override public int saveSalesDlvExcl(egovframework.sejong.user.model.SalesDlvDTO dto, java.util.List<String> prodCds) throws Exception {
		if (prodCds == null || prodCds.isEmpty()) return 0;
		boolean on = !"N".equals(dto.getActionYn());
		dto.setActionYn(on ? "Y" : "N");
		int cnt = 0;
		for (String cd : prodCds) {
			if (cd == null || cd.trim().isEmpty()) continue;
			dto.setProdCd(cd.trim());
			int n = mapper.updateSalesDlvExcl(dto);
			if (n == 0 && on) n = mapper.insertSalesDlvExcl(dto);   // 해제는 없는 줄을 만들 필요가 없다
			cnt += n;
		}
		return cnt;
	}

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

	/* ══════════════════════════════════════════════════════════════════════════
	 *  재고 일괄조정 (2026-08-19)
	 *
	 *  기존화면(거래처 시스템)의 [리스트조회] + [수정저장] 을 우리 구조로 옮긴 것.
	 *  ★재고의 주인은 수불원장 하나다. 수정값으로 덮어쓰지 않고 **차이만큼 조정행(A)** 을 더한다.
	 *    덮어쓰면 과거 이력이 사라지고, 같은 날 두 번 저장하면 값이 겹쳐 어긋난다.
	 *  ★BOX/EA 는 화면 표기다. 원장에는 EA 로 환산해 담는다(EA = BOX × 입수수량 + EA).
	 *  ★매입등록으로 맞추지 않는 이유 : 단가 0 입고가 이동평균 분모에 들어가
	 *    재고금액이 실제보다 낮아진다. 조정행은 단가를 안 넣어 그 문제가 없다.
	 * ════════════════════════════════════════════════════════════════════════ */

	@Override
	public java.util.List<egovframework.sejong.user.model.StockMstDTO>
	    selectStockAdjList(egovframework.sejong.user.model.StockMstDTO dto) throws Exception {
		return mapper.selectStockAdjList(dto);
	}

	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public int saveStockAdjBatch(egovframework.sejong.user.model.StockAdjHisDTO head,
	                             java.util.List<egovframework.sejong.user.model.StockAdjHisDTO> rows) throws Exception {

		if (rows == null || rows.isEmpty()) return 0;

		String baseDt = head.getBaseDt() == null ? "" : head.getBaseDt().replace("-", "");
		guardClosed(baseDt);                       // 마감 확정월 잠금 — 다른 조정과 같은 규칙

		// 저장 묶음 번호 : 되돌리기가 이 번호를 따라간다
		String batchNo = "ADJ" + new java.text.SimpleDateFormat("yyyyMMddHHmmss")
		                              .format(new java.util.Date());
		int n = 0;

		for (egovframework.sejong.user.model.StockAdjHisDTO r : rows) {
			if (r == null || r.getProdSeq() == null) continue;

			int pack = (r.getPackQty() == null || r.getPackQty() < 1) ? 1 : r.getPackQty();
			int bef  = r.getBefQty() == null ? 0 : r.getBefQty();
			int aft  = (r.getAftBox() == null ? 0 : r.getAftBox()) * pack
			         + (r.getAftEa()  == null ? 0 : r.getAftEa());
			int diff = aft - bef;

			// 안 고친 줄은 건너뛴다 — 0짜리 조정행을 쌓지 않는다
			if (diff == 0) continue;

			/* ① 원장 조정행. 단가는 넣지 않는다(이동평균 보호).
			      IO_GB : 늘리면 'A'(+), 줄이면 'A'(−) 로 음수 수량을 담는다.
			      현재고 집계가 A 를 그대로 더하므로 음수면 차감된다. */
			egovframework.sejong.user.model.StockLedgerDTO led =
			        new egovframework.sejong.user.model.StockLedgerDTO();
			led.setCompCd(head.getCompCd());
			led.setProdSeq(r.getProdSeq());
			led.setProdCd(r.getProdCd());
			led.setTrxDt(baseDt);
			led.setIoGb("A");
			led.setQty(diff);
			led.setRefGb("");                      // 수기조정 표식 — 삭제 가능 대상
			led.setRemark(head.getRemark() == null || head.getRemark().trim().isEmpty()
			              ? "재고 일괄조정" : head.getRemark());
			led.setRegUser(head.getRegUser());
			led.setRegIp(head.getRegIp());
			mapper.insertStockLedger(led);         // useGeneratedKeys 로 ledgerSeq 채워짐

			// ② 이력 — 원장에 안 남는 '전 → 후' 를 여기에 남긴다
			r.setBatchNo(batchNo);
			r.setCompCd(head.getCompCd());
			r.setBaseDt(baseDt);
			r.setAftQty(aft);
			r.setDiffQty(diff);
			r.setPackQty(pack);
			r.setLedgerSeq(led.getLedgerSeq());
			r.setRemark(led.getRemark());
			r.setRegUser(head.getRegUser());
			r.setRegIp(head.getRegIp());
			mapper.insertStockAdjHis(r);

			n++;
		}

		// ③ 현재고 재집계 — 한 번만 돈다(품목마다 돌리면 느리다)
		if (n > 0) recalcStockMstAll(head.getRegUser(), head.getRegIp());

		head.setBatchNo(batchNo);
		return n;
	}

	@Override
	public java.util.List<egovframework.sejong.user.model.StockAdjHisDTO>
	    selectStockAdjHisList(egovframework.sejong.user.model.StockAdjHisDTO dto) throws Exception {
		return mapper.selectStockAdjHisList(dto);
	}

	/** 묶음 되돌리기 — 원장행을 먼저 내리고(짝을 아직 아는 동안) 이력을 내린다. 순서를 바꾸면 짝을 잃는다. */
	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public int cancelStockAdjBatch(egovframework.sejong.user.model.StockAdjHisDTO dto) throws Exception {
		mapper.cancelStockAdjBatchLedger(dto);
		int n = mapper.cancelStockAdjBatch(dto);
		if (n > 0) recalcStockMstAll(dto.getRegUser(), dto.getRegIp());
		return n;
	}

	/**
	 * 입수수량 일괄 저장 (2026-08-19).
	 *
	 * BOX/EA 는 이 값으로 나뉜다. 비어 있으면 BOX 칸에 전체 수량이 그대로 나온다.
	 * 재고를 맞추다 알게 되는 값이라 같은 화면에서 바로 채울 수 있게 열었다.
	 * ★재고(원장)는 건드리지 않는다 — 환산 기준만 바뀐다.
	 *   이미 남은 조정 이력의 PACK_QTY 는 그때 값이 박혀 있어 과거 기록은 안 흔들린다.
	 */
	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public int saveProdPackQty(java.util.List<egovframework.sejong.user.model.StockMstDTO> rows) throws Exception {
		if (rows == null || rows.isEmpty()) return 0;
		int n = 0;
		for (egovframework.sejong.user.model.StockMstDTO r : rows) {
			if (r == null || r.getProdSeq() == null) continue;
			n += mapper.updateProdPackQty(r);
		}
		return n;
	}

	/**
	 * 정산서 → 재고원장 재동기화 (2026-08-19).
	 *
	 * 발주현황표 연동과 같은 방식이다 — 그 날짜의 파생행을 지우고 다시 만든다.
	 * 그래서 같은 날짜를 몇 번 올려도 재고가 겹치지 않는다.
	 *
	 * ★이중 차감 방지는 두 겹 — ①여기서 같은 날 SHIPOUT 파생행을 걷고
	 *   ②insertShipoutLedger 는 정산서 있는 날을 안 만든다(NOT EXISTS).
	 * ★마감 확정월은 **조용히 건너난다**(throw 아님) — syncShipoutLedgerDate 와 같은 규칙.
	 *   던져 버리면 재집계(rebuild) 루프가 그 날짜에서 통째로 죽는다.
	 * ★[수정 2026-08-19] 날짜 단위 동기화는 품목이 여럿이라 **recalcStockMst(품목 1건용)를 쓰면 안 된다** —
	 *   prodSeq 가 비어 MERGE 가 PROD_SEQ NULL 행을 INSERT 하려다 NOT NULL 위반으로 터졌다
	 *   (재집계가 한 번도 성공 못한 원인). 집계는 set 기반 recalcStockMstAll 로 한다(실측 20ms).
	 */
	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public int syncSalesLedger(String dlvDt, String compCd, String regUser, String regIp) throws Exception {
		int n = syncSalesLedgerCore(dlvDt, compCd, regUser, regIp);
		/* 재집계 루프는 core 를 직접 부르고 끝에 한 번만 집계한다 — 여기는 단건(업로드 후) 경로 */
		egovframework.sejong.user.model.StockLedgerDTO d = new egovframework.sejong.user.model.StockLedgerDTO();
		d.setCompCd(compCd); d.setRegUser(regUser); d.setRegIp(regIp);
		mapper.recalcStockMstAll(d);
		mapper.zeroOrphanStockMst(d);   // 재업로드로 원장에서 빠진 품목의 캐시도 0 으로
		return n;
	}
	/** 날짜 하나의 삭제+재생성만 — 현재고 집계는 부르는 쪽 몸이다(재집계 루프가 쓴다). */
	private int syncSalesLedgerCore(String dlvDt, String compCd, String regUser, String regIp) throws Exception {
		if (dlvDt == null || dlvDt.trim().isEmpty()) return 0;
		String dt = dlvDt.replace("-", "");

		/* 마감 확정월 → 원장 불변이므로 skip (syncShipoutLedgerDate 와 같은 규칙 — throw 하면 재집계 전체가 죽는다) */
		String cym = ym6FromTrx(dt);
		if (cym != null && mapper.isClosedYm(cym, null) > 0) return 0;

		egovframework.sejong.user.model.StockLedgerDTO led =
		        new egovframework.sejong.user.model.StockLedgerDTO();
		led.setTrxDt(dt);
		led.setCompCd(compCd);
		led.setRegUser(regUser);
		led.setRegIp(regIp);

		/* ★같은 날짜의 발주현황표 파생행을 먼저 걷어낸다 — 그 날은 정산서가 출고의 주인이다. */
		egovframework.sejong.user.model.StockLedgerDTO sh =
		        new egovframework.sejong.user.model.StockLedgerDTO();
		sh.setTrxDt(dt); sh.setCompCd(compCd);
		mapper.deleteShipoutLedger(sh);

		mapper.deleteSalesLedger(led);
		int n = mapper.insertSalesLedger(led);

		/* ★[2026-09-03] 납품일자 D 의 발주행이 <다른 출고일자> 밑에 합산돼 있으면 그 날짜들도 다시 만든다.
		     김해는 매일 하루 먼저 나가(출고 D-1 · 납품 D) SHIPOUT 원장이 D-1 에 붙어 있다.
		     위 deleteShipoutLedger(D) 는 D 만 지우므로 D-1 의 김해 몫이 남아 정산서와 <두 번> 빠졌다.
		     다시 만들면 insertShipoutLedger 의 NOT EXISTS(납품일자 기준)가 D 몫을 알아서 뺀다.
		   ★스위치가 꺼져 있으면 syncShipoutLedgerDate 가 0 을 돌려주므로 여기서 따로 가릴 것 없다. */
		java.util.List<String> sds = mapper.selectShipoutDtsByDlvDt(sh);
		if (sds != null) for (String sd : sds) {
			if (sd != null && !sd.equals(dt)) syncShipoutLedgerDate(sd, regUser, regIp);
		}
		return n;
	}
}
