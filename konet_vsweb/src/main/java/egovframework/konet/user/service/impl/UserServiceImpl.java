package egovframework.konet.user.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.konet.user.mapper.UserMapper;
import egovframework.konet.user.model.CompConDTO;
import egovframework.konet.user.model.CompMdDTO;
import egovframework.konet.user.model.PersignDTO;
import egovframework.konet.user.model.SjgnDTO;
import egovframework.konet.user.model.UserDTO;
import egovframework.konet.user.service.UserService;


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
	@Override public int updateCompBizInfo(CompMdDTO dto) throws Exception { return mapper.updateCompBizInfo(dto); }

	// ===== 출고장(발주현황표) 업로드 저장 (TBL_SHIPOUT_MST) =====
	@Override public java.util.List<String> selectShipoutActiveShpoutDts(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutActiveShpoutDts(dto); }
	@Override public int markShipoutHistory(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.markShipoutHistory(dto); }
	@Override public int deleteShipoutZone(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.deleteShipoutZone(dto); }
	@Override public int getShipoutNextJobSeq(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.getShipoutNextJobSeq(dto); }
	@Override public int insertShipoutMst(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.insertShipoutMst(dto); }
	@Override public int insertShipoutMstBulk(java.util.List<egovframework.konet.user.model.ShipoutDTO> list) throws Exception { return mapper.insertShipoutMstBulk(list); }
	@Override public java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutMst(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutMst(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutPrev(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutPrev(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutHistory(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutHistory(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutHistAll(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutHistAll(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSalesChart(egovframework.konet.user.model.ClosingDTO dto) throws Exception { return mapper.selectSalesChart(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSalesChartDaily(egovframework.konet.user.model.ClosingDTO dto) throws Exception { return mapper.selectSalesChartDaily(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectShipoutUploadHist(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutUploadHist(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectShipoutUploadDtl(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectShipoutUploadDtl(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ShipoutDTO> selectShipoutSrcFiles() throws Exception { return mapper.selectShipoutSrcFiles(); }

	// ===== 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 (TBL_SALES_MST) =====
	@Override public int markSalesHistory(egovframework.konet.user.model.SalesDTO dto) throws Exception { return mapper.markSalesHistory(dto); }
	@Override public int getSalesNextJobSeq(egovframework.konet.user.model.SalesDTO dto) throws Exception { return mapper.getSalesNextJobSeq(dto); }
	@Override public int insertSalesMst(egovframework.konet.user.model.SalesDTO dto) throws Exception { return mapper.insertSalesMst(dto); }
	@Override public java.util.List<egovframework.konet.user.model.SalesDTO> selectSalesMst(egovframework.konet.user.model.SalesDTO dto) throws Exception { return mapper.selectSalesMst(dto); }
	@Override public java.util.List<egovframework.konet.user.model.SalesDTO> selectSalesSrcFiles() throws Exception { return mapper.selectSalesSrcFiles(); }

	/* 출고장 정정(2026-07-27) — 배치키가 (DLV_DT + DC_NM) 이라 이름 변경 = 그 배치를 옮기는 것.
	     옮겨갈 이름으로 '같은 납품일자에 이미 활성배치'가 있으면 정정하면 안 된다(활성배치가 둘 → 매출 이중계상).
	     그때는 -1 을 돌려 화면이 "이미 그 출고장 자료가 있다"고 안내하게 한다. */
	@Override public int renameSalesDc(egovframework.konet.user.model.SalesDTO dto) throws Exception {
		if (mapper.countSalesDcConflict(dto) > 0) return -1;
		return mapper.updateSalesDcNm(dto);
	}
	@Override public int mergeSalepriceFromSales(egovframework.konet.user.model.SalesDTO dto) throws Exception { return mapper.mergeSalepriceFromSales(dto); }

	// ===== 거래처 마스터 (TBL_VENDOR_MST) =====
	@Override public java.util.List<egovframework.konet.user.model.VendorDTO> selectVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.selectVendorMst(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectVendorTrxSum(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.selectVendorTrxSum(dto); }
	@Override public int vendorDupChk(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.vendorDupChk(dto); }
	@Override public int insertVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.insertVendorMst(dto); }
	@Override public int updateVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.updateVendorMst(dto); }
	@Override public int updateVendorEmail(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.updateVendorEmail(dto); }
	@Override public int deleteVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.deleteVendorMst(dto); }
	@Override public int mergeVendorMst(egovframework.konet.user.model.VendorDTO dto) throws Exception { return mapper.mergeVendorMst(dto); }
	@Override public java.util.List<egovframework.konet.user.model.BiziDTO> selectBiziMst() throws Exception { return mapper.selectBiziMst(); }
	@Override public java.util.List<java.util.Map<String,Object>> selectBizZoneHist(egovframework.konet.user.model.ShipoutDTO dto) throws Exception { return mapper.selectBizZoneHist(dto); }   // 통상 출고장 이력(2026-09-16)
	@Override public int insertBiziIfAbsent(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.insertBiziIfAbsent(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectBiziNoAddr(java.util.Map<String,Object> p) throws Exception { return mapper.selectBiziNoAddr(p); }
	@Override public int updateBiziMst(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.updateBiziMst(dto); }
	@Override public int updateBiziParcel(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.updateBiziParcel(dto); }
	@Override public int updateBiziMatch(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.updateBiziMatch(dto); }
	@Override public int biziMatchNextNo(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.biziMatchNextNo(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectParcelOutList(java.util.Map<String,Object> p) throws Exception { return mapper.selectParcelOutList(p); }
	@Override public int deleteBiziMst(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.deleteBiziMst(dto); }
	@Override public java.util.List<egovframework.konet.user.model.BiziDTO> selectBiziList(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.selectBiziList(dto); }
	@Override public int biziDupChk(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.biziDupChk(dto); }
	@Override public int insertBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.insertBizi(dto); }
	@Override public int updateBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.updateBizi(dto); }
	@Override public int deleteBizi(egovframework.konet.user.model.BiziDTO dto) throws Exception { return mapper.deleteBizi(dto); }
	/* ===== 정산 월 마감 (2026-09-16 P2-g) =====
	   · 수기 장부 메서드 12개(Receive·Payment)·guardSettleClosed(확정 월 저장 차단)·nextYm(다음달 이월) 은 삭제했다 — 실사용 0.
	   · 확정은 «막는 장치»가 아니라 «굳히는 장치»다 : RCV 확정 때 그 달의 거래처별 이월·매출·수금을 TBL_RECEIVE_MST 에 스냅샷으로 남기고,
	     전표는 그대로 고쳐진다(수금·판매 등록 화면이 확인창만 띄운다 — 사용자 방침 「메시지 처리」).
	   · 스냅샷 원천 = selectCustBalance(채권·채무 화면과 같은 4갈래 UNION)를 **자바에서 접는다** — 같은 계산을 SQL 로 한 벌 더 두면 화면 잔액과 어긋난다.
	     이월 = 그 달 이전 (매출−매출할인−수금) 누계 · 매출 = 그 달 (매출−매출할인) · 수금 = 그 달 수금. 셋 다 0 인 거래처는 안 남긴다. */
	@Override public egovframework.konet.user.model.SettleCloseDTO selectSettleClose(String settleGb, String ym) throws Exception {
		egovframework.konet.user.model.SettleCloseDTO d = new egovframework.konet.user.model.SettleCloseDTO();
		d.setSettleGb(settleGb); d.setCloseYm(ym);
		return mapper.selectSettleClose(d);
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectSettleCloseList(String settleGb, String compCd) throws Exception {
		egovframework.konet.user.model.SettleCloseDTO d = new egovframework.konet.user.model.SettleCloseDTO();
		d.setSettleGb(settleGb); d.setCompCd(compCd);
		return mapper.selectSettleCloseList(d);
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectRcvSnapshot(String ym, String compCd) throws Exception {
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
		p.put("rcvYm", ym == null ? "" : ym.replace("-", "")); p.put("compCd", compCd);
		return mapper.selectRcvSnapshot(p);
	}
	@Override public int confirmSettleClose(String settleGb, String ym, String user, String ip, String compCd) throws Exception {
		String y = ym.replace("-", "");
		if ("RCV".equals(settleGb)) {
			egovframework.konet.user.model.SettleTrxDTO q = new egovframework.konet.user.model.SettleTrxDTO();
			q.setCompCd(compCd);
			java.util.List<java.util.Map<String,Object>> rows = mapper.selectCustBalance(q);
			java.util.Map<String,double[]> acc = new java.util.LinkedHashMap<String,double[]>();   // custCd → [이월, 매출, 수금]
			java.util.Map<String,String> nm = new java.util.HashMap<String,String>();
			for (java.util.Map<String,Object> r : rows) {
				String cd = scStr(r.get("custCd")), rym = scStr(r.get("ym"));
				if (cd.isEmpty() || rym.isEmpty() || rym.compareTo(y) > 0) continue;   // 기준월 이후는 아직 안 일어난 일(화면 cbFold 와 같은 규칙)
				double sale = scNum(r.get("saleAmt")) - scNum(r.get("saleDcAmt")), rcv = scNum(r.get("rcvAmt"));
				double[] a = acc.get(cd);
				if (a == null) { a = new double[3]; acc.put(cd, a); nm.put(cd, scStr(r.get("custNm"))); }
				if (rym.equals(y)) { a[1] += sale; a[2] += rcv; } else { a[0] += sale - rcv; }
			}
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("rcvYm", y); p.put("compCd", compCd);
			mapper.deleteRcvSnapshot(p);            // 다시 확정하면 그 달 스냅샷은 통째로 새로 쓴다
			for (java.util.Map.Entry<String,double[]> e : acc.entrySet()) {
				double[] a = e.getValue();
				if (Math.round(a[0]) == 0 && Math.round(a[1]) == 0 && Math.round(a[2]) == 0) continue;
				java.util.Map<String,Object> s = new java.util.HashMap<String,Object>();
				s.put("rcvYm", y); s.put("compCd", compCd); s.put("bizCd", e.getKey()); s.put("bizNm", nm.get(e.getKey()));
				s.put("prevAmt", Math.round(a[0])); s.put("salesAmt", Math.round(a[1])); s.put("collectAmt", Math.round(a[2]));
				s.put("regUser", user); s.put("regIp", ip);
				mapper.insertRcvSnapshot(s);
			}
		}
		egovframework.konet.user.model.SettleCloseDTO d = new egovframework.konet.user.model.SettleCloseDTO();
		d.setSettleGb(settleGb); d.setCloseYm(y); d.setConfirmUser(user); d.setCompCd(compCd);
		return mapper.confirmSettleClose(d);
	}
	@Override public int cancelSettleClose(String settleGb, String ym, String user, String compCd) throws Exception {
		egovframework.konet.user.model.SettleCloseDTO d = new egovframework.konet.user.model.SettleCloseDTO();
		d.setSettleGb(settleGb); d.setCloseYm(ym); d.setUpdUser(user); d.setCompCd(compCd);
		return mapper.cancelSettleClose(d);
	}
	private static String scStr(Object o) { return o == null ? "" : String.valueOf(o).trim(); }
	private static double scNum(Object o) {
		if (o == null) return 0; if (o instanceof Number) return ((Number) o).doubleValue();
		try { return Double.parseDouble(String.valueOf(o).replace(",", "")); } catch (Exception e) { return 0; }
	}

	@Override public java.util.List<egovframework.konet.user.model.ProdDTO> selectProdList(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.selectProdList(dto); }
	@Override public java.util.Map<String,Object> countProdCd(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.countProdCd(dto); }
	@Override public int insertProd(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.insertProd(dto); }
	@Override public int updateProd(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.updateProd(dto); }
	@Override public int deleteProd(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.deleteProd(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ProdDTO> selectProdDeletedList(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.selectProdDeletedList(dto); }
	@Override public int restoreProd(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.restoreProd(dto); }
	@Override public int stopProd(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.stopProd(dto); }
	@Override public int unstopProd(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.unstopProd(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ProdDTO> selectStoppedAmong(java.util.Map<String,Object> p) throws Exception { return mapper.selectStoppedAmong(p); }
	@Override public egovframework.konet.user.model.ProdDTO selectProdStopById(java.util.Map<String,Object> p) throws Exception { return mapper.selectProdStopById(p); }

	@Override public int countProdRelated(egovframework.konet.user.model.ProdDTO dto) throws Exception { return mapper.countProdRelated(dto); }

	/* ===== 매입가 이력 : 등록 시 마스터(IN_PRICE) 동기화 ===== */
	@Override public java.util.List<egovframework.konet.user.model.ProdInpriceDTO> selectInpriceList(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception { return mapper.selectInpriceList(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ProdInpriceDTO> selectInpriceHstAll(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception { return mapper.selectInpriceHstAll(dto); }   // 정산실적 시점 단가(2026-09-16)
	@Override public int insertInprice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception {
		int n = mapper.insertInprice(dto);
		mapper.syncProdInPrice(dto);   // TBL_PROD_MST.IN_PRICE ← 새 매입단가
		return n;
	}
	@Override public int deleteInprice(egovframework.konet.user.model.ProdInpriceDTO dto) throws Exception { return mapper.deleteInprice(dto); }

	/* ===== 거래처별 품목 표기(교차참조) — TBL_PROD_XREF (2026-08-01) =====================
	   코네트 품목은 하나, 거래처 요청 표기는 이 표에 N건. 가상코드를 만들지 않는다. */
	@Override public java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefList(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefList(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectUnmappedItems(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectUnmappedItems(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefCandidates(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefCandidates(dto); }
	@Override public int confirmXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception { return mapper.confirmXref(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefAudit(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefAudit(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ProdXrefDTO> selectXrefNames(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception { return mapper.selectXrefNames(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ExtItemDTO> selectSubCodesAmong(java.util.Map<String,Object> param) throws Exception { return mapper.selectSubCodesAmong(param); }

	/* 등록/수정 — 저장만 하고 끝내면 안 된다.
	   ★매핑을 뒤늦게 걸면 그동안 PROD_SEQ 가 비어 재고에서 빠져 있던 출고분이 남는다.
	     저장 직후 resolve* 로 과거분을 소급으로 채우고, 그 품목이 걸린 출고일자만 골라
	     원장을 다시 만든다. 이 한 걸음이 빠지면 '연결했는데 재고가 그대로'가 된다.
	   ★재고 재동기화 실패가 매핑 저장을 롤백하지 않도록 별도 try — 실패해도 매핑은 남고
	     [재고 재집계] 버튼으로 복구할 수 있다. */
	@Override public int saveXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception {
		if ("Y".equals(dto.getMainYn())) mapper.clearXrefMain(dto);   // 그 거래처의 대표 표기는 하나
		int n = (dto.getXrefSeq() == null) ? mapper.insertXref(dto) : mapper.updateXref(dto);

		// 소급 반영 — 이 품목으로 해석되지 않은 과거 업로드분을 채운다
		egovframework.konet.user.model.ProdXrefDTO f = new egovframework.konet.user.model.ProdXrefDTO();
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
	@Override public int deleteXref(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception {
		egovframework.konet.user.model.ProdXrefDTO cur = mapper.selectXrefById(dto);   // 무엇을 지우는지 먼저 확보
		int n = mapper.deleteXref(dto);
		if (cur == null || cur.getExtItemCd() == null || cur.getExtItemCd().trim().isEmpty()) return n;

		egovframework.konet.user.model.ProdXrefDTO f = new egovframework.konet.user.model.ProdXrefDTO();
		f.setCompCd(dto.getCompCd());
		f.setExtItemCd(cur.getExtItemCd());
		java.util.List<String> ds = mapper.selectShipoutDatesByExtCd(f);   // ★비우기 전에 날짜 확보
		mapper.clearShipoutProdByExtCd(f);
		mapper.clearSalesProdByExtCd(f);

		egovframework.konet.user.model.ProdXrefDTO all = new egovframework.konet.user.model.ProdXrefDTO();
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
	/* ★[2026-09-13] 2차와 3차 사이에 «추가 매칭코드»(ADD_ITEM_CD) 패스 — 삼성이 옛 코드로 발주해도 주코드로 잡는다.
	     매칭코드(2차)가 먼저라 기존 매칭이 이기고, 코드 직결(3차)보다는 먼저라 옛 코드가 상품마스터에 있어도 주코드로 간다. */
	@Override public int resolveShipoutProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception {
		return mapper.resolveShipoutProd(dto) + mapper.resolveShipoutProdExt(dto) + mapper.resolveShipoutProdAdd(dto)
		     + mapper.resolveShipoutProdDirect(dto);
	}
	@Override public int resolveSalesProd(egovframework.konet.user.model.ProdXrefDTO dto) throws Exception {
		return mapper.resolveSalesProd(dto) + mapper.resolveSalesProdExt(dto) + mapper.resolveSalesProdAdd(dto)
		     + mapper.resolveSalesProdDirect(dto);
	}

	/* ===== 거래처 통보품목 — TBL_EXT_ITEM_MST (2026-08-01) =====
	   거래처가 미리 통보한 코드·품명을 원문 그대로 받아 두는 접수대장.
	   ★여기서 우리 품목과 잇지 않는다 — 매핑 방식은 추후 결정. 그래서 resolve*·재고 재집계를 부르지 않는다
	     (부르면 안 된다. 이 표는 업로드 해석 경로에 아직 끼어 있지 않다). */
	@Override public java.util.List<egovframework.konet.user.model.ExtItemDTO> selectExtItemList(egovframework.konet.user.model.ExtItemDTO dto) throws Exception { return mapper.selectExtItemList(dto); }
	@Override public int countExtItemCd(egovframework.konet.user.model.ExtItemDTO dto) throws Exception { return mapper.countExtItemCd(dto); }
	@Override public egovframework.konet.user.model.ExtItemDTO selectExtCodeConflict(egovframework.konet.user.model.ExtItemDTO dto) throws Exception { return mapper.selectExtCodeConflict(dto); }
	@Override public int insertExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception {
		int n = mapper.insertExtItem(dto); extItemRetro(dto); return n;
	}
	@Override public int updateExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception {
		/* ★추가 매칭코드를 바꾸거나 지우면 옛 코드로 잡혀 있던 행부터 되돌린다 (2026-09-13)
		     — 안 하면 옛 코드가 이 주코드에 붙은 채 굳는다(추가 칸을 비워도 재고가 안 돌아온다). */
		egovframework.konet.user.model.ExtItemDTO cur = mapper.selectExtItemById(dto);
		String oldAdd = (cur == null || cur.getAddItemCd() == null) ? "" : cur.getAddItemCd().trim();
		String newAdd = dto.getAddItemCd() == null ? "" : dto.getAddItemCd().trim();
		int n = mapper.updateExtItem(dto);
		if (!oldAdd.isEmpty() && !oldAdd.equalsIgnoreCase(newAdd))
			extCodeUndo(dto.getCompCd(), java.util.Collections.singletonList(oldAdd), dto.getUpdUser(), dto.getUpdIp());
		extItemRetro(dto);
		return n;
	}
	/* ★매칭코드를 지우면 붙여 놨던 것도 되돌린다 (2026-08-06 — deleteXref 와 같은 구조·같은 이유)
	     종전에는 지우기만 해서, 잘못 붙인 코드를 지워도 과거 출고·정산은 그 주코드에 붙은 채 남았다.
	     [출고반영 재집계]로도 안 돌아온다 — resolve* 는 빈 행만 채우고 repoint* 는 매칭코드가 있어야 돈다.
	   ★순서 : 날짜 확보 → 비우기 → 다시 해석(XREF → 남은 매칭코드 → 코드 직결) → 원장 재생성.
	     출고일자는 **비우기 전에** 받아 둔다 — PROD_SEQ 를 지운 뒤에는 그 품목으로 찾을 수 없다.
	   ★상품을 안 고른 줄(prodSeq 없음)은 해석에 쓰인 적이 없으므로 아무것도 되돌릴 게 없다.
	   ★되돌리기 실패가 삭제를 롤백하지 않도록 별도 try — 실패해도 [출고반영 재집계]로 복구된다. */
	@Override public int deleteExtItem(egovframework.konet.user.model.ExtItemDTO dto) throws Exception {
		egovframework.konet.user.model.ExtItemDTO cur = mapper.selectExtItemById(dto);   // 무엇을 지우는지 먼저 확보
		int n = mapper.deleteExtItem(dto);
		if (cur == null || cur.getProdSeq() == null) return n;
		java.util.List<String> codes = new java.util.ArrayList<String>();
		if (cur.getExtItemCd() != null && !cur.getExtItemCd().trim().isEmpty()) codes.add(cur.getExtItemCd().trim());
		/* 추가 매칭코드도 함께 푼다 (2026-09-13) — 그 코드로 잡혀 있던 행도 이 주코드에서 떼어야 한다 */
		if (cur.getAddItemCd() != null && !cur.getAddItemCd().trim().isEmpty()) codes.add(cur.getAddItemCd().trim());
		extCodeUndo(dto.getCompCd(), codes, dto.getUpdUser(), dto.getUpdIp());
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
	private void extItemRetro(egovframework.konet.user.model.ExtItemDTO dto) throws Exception {
		if (dto == null || dto.getProdSeq() == null) return;
		egovframework.konet.user.model.ProdXrefDTO f = new egovframework.konet.user.model.ProdXrefDTO();
		f.setCompCd(dto.getCompCd());
		f.setProdSeq(dto.getProdSeq());
		int back = mapper.resolveShipoutProdExt(f) + mapper.resolveSalesProdExt(f)
		         + mapper.repointShipoutProdExt(f) + mapper.repointSalesProdExt(f)
		         /* ★추가 매칭코드 (2026-09-13) — 매칭코드 다음 · 코드 직결 전. 같은 상품으로 좁혀서 */
		         + mapper.resolveShipoutProdAdd(f) + mapper.resolveSalesProdAdd(f)
		         + mapper.repointShipoutProdAdd(f) + mapper.repointSalesProdAdd(f);
		if (back <= 0) return;
		String user = dto.getRegUser() != null ? dto.getRegUser() : dto.getUpdUser();   // 수정 경로는 upd* 만 채워져 온다
		String ip   = dto.getRegIp()   != null ? dto.getRegIp()   : dto.getUpdIp();
		/* 정산서 날짜는 이 상품의 매칭코드·추가 매칭코드가 들어 있는 날만 — 위 패스가 옮기는 행은 그 코드들뿐이다 */
		extLedgerResync(mapper.selectShipoutDatesByProd(f), mapper.selectSalesDatesByExtProd(f), user, ip);
	}
	/* ★코드를 «풀었을 때» 되돌리기 — deleteExtItem(품목코드·추가 매칭코드)·updateExtItem(추가 매칭코드를 바꾸거나 지웠을 때)이 같이 쓴다.
	     그 코드로 채워진 출고·정산 행을 비우고 → 다시 해석(XREF → 남은 매칭 → 추가 매칭 → 코드 직결) → 원장 재생성.
	   ★날짜는 **비우기 전에** 받아 둔다 — PROD_SEQ 를 지운 뒤에는 찾을 수 없다. */
	private void extCodeUndo(String compCd, java.util.List<String> codes, String user, String ip) throws Exception {
		if (codes == null || codes.isEmpty()) return;
		java.util.TreeSet<String> ship = new java.util.TreeSet<String>(), sales = new java.util.TreeSet<String>();
		for (String c : codes) {
			egovframework.konet.user.model.ProdXrefDTO f = new egovframework.konet.user.model.ProdXrefDTO();
			f.setCompCd(compCd);
			f.setExtItemCd(c);
			java.util.List<String> a = mapper.selectShipoutDatesByExtCd(f);   // ★비우기 전에 날짜 확보
			java.util.List<String> b = mapper.selectSalesDatesByExtCd(f);
			if (a != null) ship.addAll(a);
			if (b != null) sales.addAll(b);
			mapper.clearShipoutProdByExtCd(f);
			mapper.clearSalesProdByExtCd(f);
		}
		egovframework.konet.user.model.ProdXrefDTO all = new egovframework.konet.user.model.ProdXrefDTO();
		all.setCompCd(compCd);
		resolveShipoutProd(all);   // 남은 매핑으로 다시 해석 (없으면 미매핑으로 남는다)
		resolveSalesProd(all);
		extLedgerResync(ship, sales, user, ip);
	}
	/* ★매칭코드를 붙이거나 풀면 «정산서 원장»까지 다시 만든다 (2026-09-13)
	     재고의 원천은 정산서(REF_GB='SALES')다 — SHIPOUT_LEDGER_ON=false 라 syncShipoutLedgerDate 는 아무 일도 안 한다.
	     종전에는 발주현황표 날짜만 다시 만들어, 매칭코드를 붙여도 정산서 원장이 옛 코드에 남아
	     [출고반영 재집계]를 눌러야 주코드로 옮겨졌다. 날짜 단위 삭제+재생성이라 옛 코드 몫도 함께 걷힌다.
	   ★실패해도 저장·삭제는 롤백하지 않는다(로그만) — [재고 재집계]로 복구된다. */
	private void extLedgerResync(java.util.Collection<String> shipDts, java.util.Collection<String> salesDts, String user, String ip) {
		try {
			int k = 0;
			if (shipDts  != null) for (String d : shipDts)  { syncShipoutLedgerDate(d, user, ip); k++; }
			if (salesDts != null) for (String d : salesDts) { syncSalesLedgerCore(d, null, user, ip); k++; }
			if (k > 0) recalcStockMstAll(user, ip);
		} catch (Exception se) {
			LOGGER.error(" 매칭코드 재고 재동기화 WARN : " + se.getMessage());
		}
	}
	/* 통보서 붙여넣기 — 한 줄씩 MERGE(있으면 갱신·없으면 신규). 한 트랜잭션이라 중간에 실패하면 전부 취소된다. */
	@Override public int mergeExtItems(java.util.List<egovframework.konet.user.model.ExtItemDTO> list) throws Exception {
		if (list == null || list.isEmpty()) return 0;
		int n = 0;
		for (egovframework.konet.user.model.ExtItemDTO d : list) {
			if (d == null || d.getExtItemCd() == null || d.getExtItemCd().trim().isEmpty()) continue;
			n += mapper.mergeExtItem(d);
		}
		return n;
	}

	/* ===== 판매가 이력 : 등록 시 마스터(SALE_PRICE/WHOLE_PRICE) 동기화 ===== */
	@Override public java.util.List<egovframework.konet.user.model.ProdSalepriceDTO> selectSalepriceList(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception { return mapper.selectSalepriceList(dto); }
	@Override public int insertSaleprice(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception {
		int n = mapper.insertSaleprice(dto);
		// 공통가(판매처 없음)만 마스터 동기화 — 판매처 전용가가 기본가(SALE_PRICE)를 덮으면 안 된다
		if (dto.getVendorCd() == null || dto.getVendorCd().trim().isEmpty())
			mapper.syncProdSalePrice(dto); // TBL_PROD_MST.SALE_PRICE/WHOLE_PRICE ← 새 판매/도매단가
		return n;
	}
	@Override public int deleteSaleprice(egovframework.konet.user.model.ProdSalepriceDTO dto) throws Exception { return mapper.deleteSaleprice(dto); }

	/* ===== 재고 수불 : 원장 입출력 후 현재고(TBL_STOCK_MST) 재집계 ===== */
	@Override public java.util.List<egovframework.konet.user.model.StockLedgerDTO> selectStockLedgerList(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception { return mapper.selectStockLedgerList(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectStockLedgerInList(java.util.Map<String,Object> p) throws Exception { return mapper.selectStockLedgerInList(p); }
	@Override public egovframework.konet.user.model.StockMstDTO selectStockMst(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception { return mapper.selectStockMst(dto); }
	@Override public int insertStockLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception {
		guardClosed(dto.getTrxDt());   // 마감 확정월 잠금
		int n = mapper.insertStockLedger(dto);
		mapper.recalcStockMst(dto);    // 원장 누계로 현재고 재집계
		return n;
	}
	@Override public int deleteStockLedger(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception {
		guardClosed(dto.getTrxDt());   // 마감 확정월 잠금
		int n = mapper.deleteStockLedger(dto);
		mapper.recalcStockMst(dto);    // 삭제 후에도 현재고 재집계
		return n;
	}
	@Override public java.util.List<egovframework.konet.user.model.StockMstDTO> selectStockMstList(egovframework.konet.user.model.StockMstDTO dto) throws Exception { return mapper.selectStockMstList(dto); }
	@Override public java.util.List<egovframework.konet.user.model.StockMstDTO> selectStockQtyMap(egovframework.konet.user.model.StockMstDTO dto) throws Exception { return mapper.selectStockQtyMap(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectStockOutByMonth(java.util.Map<String,Object> p) throws Exception { return mapper.selectStockOutByMonth(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectStockOutSrcDays(java.util.Map<String,Object> p) throws Exception { return mapper.selectStockOutSrcDays(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectStockOutDetail(java.util.Map<String,Object> p) throws Exception { return mapper.selectStockOutDetail(p); }
	@Override public java.util.List<egovframework.konet.user.model.StockLedgerDTO> selectInboundList(egovframework.konet.user.model.StockLedgerDTO dto) throws Exception { return mapper.selectInboundList(dto); }
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
		egovframework.konet.user.model.StockLedgerDTO d = new egovframework.konet.user.model.StockLedgerDTO();
		d.setTrxDt(shpoutDt); d.setRegUser(regUser); d.setRegIp(regIp);
		mapper.deleteShipoutLedger(d);
		return mapper.insertShipoutLedger(d);
	}
	@Override public int recalcStockMstAll(String regUser, String regIp) throws Exception {
		egovframework.konet.user.model.StockLedgerDTO d = new egovframework.konet.user.model.StockLedgerDTO();
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
			egovframework.konet.user.model.ProdXrefDTO all = new egovframework.konet.user.model.ProdXrefDTO();
			egovframework.konet.cmmn.RebuildProgress.set(pk, "품목 해석 중… (거래처 코드 → 우리 품목)", 0, 0);
			resolveShipoutProd(all);
			resolveSalesProd(all);
			/* ★매칭코드를 뒤늦게 등록한 품목 되돌려 붙이기 (2026-08-06)
			   resolve* 는 안 붙은 행만 채운다. 거래처 코드가 우리 상품마스터에도 있어 3차 직결로
			   제 코드에 붙어 버린 과거분은 이 버튼으로만 주코드로 옮겨진다. */
			mapper.repointShipoutProdExt(all);
			mapper.repointSalesProdExt(all);
			mapper.repointShipoutProdAdd(all);   // 추가 매칭코드(2026-09-13) — 매칭코드 되돌려 붙이기 뒤에
			mapper.repointSalesProdAdd(all);

			/* 발주현황표 연동 종료(2026-08-19) — 기존 원장행은 그대로 두고 새로 만들지 않는다.
			   되살리려면 SHIPOUT_LEDGER_ON 만 true 로. */
			/* ★[2026-09-03] 원장 키가 출고일자→납기일자로 바뀌었다. 옛 키로 남은 SHIPOUT 행은 아래 날짜 루프로는 안 지워질 수 있어
			   먼저 통째로 걷는다(마감 확정월 제외). 그 다음 납기일자별로 다시 만든다. */
			if (SHIPOUT_LEDGER_ON) mapper.deleteShipoutLedgerAll(new egovframework.konet.user.model.StockLedgerDTO());
			java.util.List<String> ds = SHIPOUT_LEDGER_ON ? mapper.selectShipoutDates()
			                                              : new java.util.ArrayList<String>();
			int total = ds.size();
			egovframework.konet.cmmn.RebuildProgress.set(pk, "출고 원장 재생성", 0, total);
			if (ds != null) for (String d : ds) {
				syncShipoutLedgerDate(d, regUser, regIp);
				dates++;
				egovframework.konet.cmmn.RebuildProgress.set(pk, "출고 원장 재생성 — " + d, dates, total);
			}

			/* ★정산서 → 원장 재생성 (2026-08-19)
			   출고 원천을 정산서로 옮기는 중이라, 이 버튼이 두 원천을 모두 다시 만든다.
			   정산서가 있는 날짜만 돈다 — 없는 기간은 발주현황표 몫으로 남는다.
			   ※두 원천이 같은 날을 덮으면 그 날 출고가 두 번 빠진다.
			     어느 쪽을 쓸지(D1) 정해지면 여기서 한쪽을 걸러야 한다. */
			java.util.List<String> sds = mapper.selectSalesDates(new egovframework.konet.user.model.StockLedgerDTO());
			int stotal = (sds == null) ? 0 : sds.size();
			if (stotal > 0) {
				int sdone = 0;
				egovframework.konet.cmmn.RebuildProgress.set(pk, "정산서 원장 재생성", 0, stotal);
				for (String d : sds) {
					syncSalesLedgerCore(d, null, regUser, regIp);   // 집계는 루프 끝 recalcStockMstAll 1회
					sdone++;
					egovframework.konet.cmmn.RebuildProgress.set(pk, "정산서 원장 재생성 — " + d, sdone, stotal);
				}
				dates += sdone;
			}
			egovframework.konet.cmmn.RebuildProgress.set(pk, "현재고 집계 중…", total, total);
			recalcStockMstAll(regUser, regIp);
			return dates;
		} finally {
			egovframework.konet.cmmn.RebuildProgress.end(pk);
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
	@Override public egovframework.konet.user.model.ClosingMstDTO selectClosingMst(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception {
		if (dto.getCloseYm()==null) dto.setCloseYm(ym6(dto.getYm()));
		return mapper.selectClosingMst(dto);
	}
	@Override public java.util.List<egovframework.konet.user.model.ClosingMstDTO> selectClosingMstList(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception { return mapper.selectClosingMstList(dto); }
	@Override public int confirmClosing(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception {
		String ymDash = dto.getYm();
		String cym = ym6(ymDash);
		// ① 매출/매출원가 (출고 기준)
		egovframework.konet.user.model.ClosingDTO cq = new egovframework.konet.user.model.ClosingDTO(); cq.setYm(ymDash);
		double sAmt=0, cogs=0;
		for (egovframework.konet.user.model.ClosingDTO r : mapper.selectClosing(cq)) {
			sAmt += r.getSalesAmt()!=null ? r.getSalesAmt() : 0;
			cogs += r.getCostAmt()!=null ? r.getCostAmt() : 0;
		}
		// ② 매입 (입고 수불 기준)
		egovframework.konet.user.model.StockClosingDTO sq = new egovframework.konet.user.model.StockClosingDTO(); sq.setYm(ymDash);
		double pAmt=0;
		for (egovframework.konet.user.model.StockClosingDTO r : mapper.selectInboundClosing(sq)) pAmt += r.getInAmt()!=null ? r.getInAmt() : 0;
		// ③ 재고 (기말재고금액) + 스냅샷 대상
		java.util.List<egovframework.konet.user.model.StockClosingDTO> stock = mapper.selectStockClosing(sq);
		double stkAmt=0;
		for (egovframework.konet.user.model.StockClosingDTO r : stock) {
			double q = r.getEndQty()!=null ? r.getEndQty() : 0, a = r.getAvgInPrice()!=null ? r.getAvgInPrice() : 0;
			stkAmt += q*a;
		}
		// ④ 헤더 upsert (UPDATE 먼저 → 0건이면 INSERT)
		dto.setCloseYm(cym); dto.setStatus("C");
		dto.setSalesAmt(sAmt); dto.setCogsAmt(cogs); dto.setMarginAmt(sAmt-cogs); dto.setPurchaseAmt(pAmt); dto.setStockAmt(stkAmt);
		// ⑥ 비용(2026-09-16 P2-e) = 직송 택배 운임 자동 + 수기 항목 → 순마진 = 매출총이익(MARGIN_AMT) − 비용. 확정 시점 값으로 굳힌다
		double exp = expenseSumOf(cym, dto.getCompCd());
		dto.setExpenseAmt(exp); dto.setNetMarginAmt(sAmt - cogs - exp);
		if (mapper.updateClosingMst(dto) == 0) mapper.insertClosingMst(dto);
		// ⑤ 재고 스냅샷 재작성(이월 근거) — 창고 2단계(2026-09-16) : 품목 × 창고로 쌓는다. 단가는 품목 평균(위 stock), 마감 화면·이월은 창고 합으로 읽는다
		mapper.deleteClosingStock(cym, null);
		java.util.Map<Long,Double> avg = new java.util.HashMap<Long,Double>();
		for (egovframework.konet.user.model.StockClosingDTO r : stock) if (r.getProdSeq() != null) avg.put(r.getProdSeq(), r.getAvgInPrice() != null ? r.getAvgInPrice() : 0d);
		for (egovframework.konet.user.model.StockClosingDTO r : mapper.selectStockClosingByWh(sq)) {
			r.setYm(ymDash); r.setAvgInPrice(avg.containsKey(r.getProdSeq()) ? avg.get(r.getProdSeq()) : 0d);
			mapper.insertClosingStock(r);
		}
		return 1;
	}
	@Override public int cancelClosing(egovframework.konet.user.model.ClosingMstDTO dto) throws Exception {
		String cym = ym6(dto.getYm()); dto.setCloseYm(cym);
		int n = mapper.cancelClosingMst(dto);
		mapper.deleteClosingStock(cym, null);
		return n;
	}

	/* ===== 비용 (2026-09-16 P2-e) — TBL_EXPENSE_ITEM(항목) · TBL_EXPENSE_TRX(달×항목 수기 금액) · 직송 택배 운임 자동(selectParcelFeeAuto).
	   순마진 = 매출총이익(매출−매출원가) − 비용. 자동 운임은 전표를 안 만들고 그때그때 센다 — 근거가 택배출고관리에 있어 거기서 고치면 따라온다. ===== */
	private int parcelFeeDefOf(String compCd) {   // 회사 설정 SET_JSON 의 func.parcelFeeDef(기본 4500) — JSON 라이브러리 없이 숫자만 뽑는다
		try {
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("compCd", (compCd == null || compCd.trim().isEmpty()) ? "W1234567" : compCd);
			String js = mapper.selectCompSetJson(p);
			if (js != null) {
				java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"parcelFeeDef\"\\s*:\\s*\"?(\\d+)").matcher(js);
				if (m.find()) { int v = Integer.parseInt(m.group(1)); if (v >= 0) return v; }
			}
		} catch (Exception e) { /* 설정을 못 읽으면 기본값 */ }
		return 4500;
	}
	@Override public java.util.Map<String,Object> selectExpenseMonth(String ym, String compCd) throws Exception {
		String y = ym == null ? "" : ym.replace("-", "").trim();
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
		p.put("compCd", compCd); p.put("expYm", y); p.put("feeDef", parcelFeeDefOf(compCd));
		java.util.Map<String,Object> r = new java.util.HashMap<String,Object>();
		r.put("items", mapper.selectExpenseItem(p));
		r.put("trx", y.length() == 6 ? mapper.selectExpenseTrx(p) : new java.util.ArrayList<java.util.Map<String,Object>>());
		r.put("auto", y.length() == 6 ? mapper.selectParcelFeeAuto(p) : null);
		r.put("feeDef", p.get("feeDef"));
		/* 비용 내역(2026-09-17) — 표(TBL_EXPENSE_DTL)가 아직 없으면(DDL 미실행) 화면 전체를 죽이지 않고 내역만 비우고 dtlReady=false 로 알린다 */
		java.util.List<java.util.Map<String,Object>> dtl = new java.util.ArrayList<java.util.Map<String,Object>>(); boolean ready = true;
		if (y.length() == 6) { try { dtl = mapper.selectExpenseDtl(p); } catch (Exception e) { ready = false; LOGGER.warn(" selectExpenseDtl 표 없음? : " + e.getMessage()); } }
		r.put("dtl", dtl); r.put("dtlReady", ready);
		return r;
	}
	@SuppressWarnings("unchecked")
	@Override public double expenseSumOf(String ym, String compCd) throws Exception {
		java.util.Map<String,Object> m = selectExpenseMonth(ym, compCd);
		java.util.Map<String,Object> auto = (java.util.Map<String,Object>) m.get("auto");
		java.util.Set<String> on = new java.util.HashSet<String>();
		double t = 0;
		for (java.util.Map<String,Object> it : (java.util.List<java.util.Map<String,Object>>) m.get("items")) {
			if (!"Y".equals(scStr(it.get("useYn")))) continue;                       // 사용 끈 항목은 안 센다
			if ("PARCEL".equals(scStr(it.get("autoSrc")))) { if (auto != null) t += scNum(auto.get("amt")); }
			else on.add(scStr(it.get("itemCd")));
		}
		for (java.util.Map<String,Object> r : (java.util.List<java.util.Map<String,Object>>) m.get("trx"))
			if (on.contains(scStr(r.get("itemCd")))) t += scNum(r.get("amt"));
		return Math.round(t);
	}
	@Override public int saveExpenseItem(java.util.Map<String,Object> p) throws Exception { return mapper.upsertExpenseItem(p); }
	@Override public int saveExpenseTrx(java.util.List<java.util.Map<String,Object>> rows, String ym, String user, String ip, String compCd) throws Exception {
		String y = ym.replace("-", "").trim(); int n = 0;
		if (rows == null) return 0;
		for (java.util.Map<String,Object> r : rows) {
			String cd = scStr(r.get("itemCd")); if (cd.isEmpty()) continue;
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("compCd", compCd); p.put("expYm", y); p.put("itemCd", cd);
			p.put("amt", Math.round(scNum(r.get("amt")))); p.put("remark", scStr(r.get("remark")));
			p.put("regUser", user); p.put("regIp", ip);
			n += mapper.upsertExpenseTrx(p);
			/* 내역이 있는 항목은 금액을 손으로 못 바꾼다 — 비고만 받고 금액은 내역 합계로 되돌린다(화면도 읽기 전용이지만 서버가 최종) */
			try { boolean has = false; for (java.util.Map<String,Object> d : mapper.selectExpenseDtl(p)) { if (cd.equals(scStr(d.get("itemCd")))) { has = true; break; } }
			      if (has) mapper.syncExpenseTrxFromDtl(p); } catch (Exception e) { /* 내역 표가 아직 없으면 종전대로 */ }
		}
		return n;
	}
	/* 비용 내역 저장(2026-09-17) — rows = [{dtlSeq, del, expDt, title, amt, remark, chkYn}] : dtlSeq 없으면 새 줄, del=Y 면 지움(ACTION_YN='N').
	   끝에 그 달·항목의 TRX 금액을 내역 합계로 굳힌다. 마감 확정된 달도 막지 않는다(수기 금액과 같은 방침 — 화면이 확인창을 띄운다). */
	/* ===== 견적서 관리 (2026-09-17 「견적서 엑셀을 입고예약서처럼 올리고 저장, 일자·담당자·문서번호로 관리」) =====
	   엑셀(xls/xlsx) 해석 규칙 — 표본 260729-1(900cc, 500cc).xls :
	   · 머리 : 「문서 번호」「수 신」「견 적 일」「담 당 자」「유효기간」 이름표 칸의 <오른쪽 첫 값>. 이름표는 띄어쓰기·줄바꿈을 지우고 맞춘다.
	   · 제목 : 「견적을 드립니다」가 든 칸.   · 품목 머리줄 : 품명·수량·단가 가 함께 있는 줄 → 칸 번호. 바로 아랫줄이 Box/ea 같은 보조 머리면 건너뛴다.
	   · 품목 줄 : 품명이나 수량이 있는 줄. 「비고」 이름표 줄에서 끝. 단위 칸이 숫자면 Box 수, 글이면 단위. 금액은 수식이면 계산값, 비면 수량×단가.
	   · 비고 : 「비고」 이름표 줄부터 끝까지 이름표 오른쪽 글을 줄로 모은다. */
	private static String qzCell(org.apache.poi.ss.usermodel.Cell c, org.apache.poi.ss.usermodel.DataFormatter df, org.apache.poi.ss.usermodel.FormulaEvaluator ev) {
		if (c == null) return "";
		try {
			org.apache.poi.ss.usermodel.CellType t = c.getCellTypeEnum();
			if (t == org.apache.poi.ss.usermodel.CellType.FORMULA) {
				org.apache.poi.ss.usermodel.CellValue v = ev.evaluate(c);
				if (v == null) return "";
				if (v.getCellTypeEnum() == org.apache.poi.ss.usermodel.CellType.NUMERIC) return qzNum(v.getNumberValue());
				return String.valueOf(v.formatAsString()).replace("\"", "").trim();
			}
			if (t == org.apache.poi.ss.usermodel.CellType.NUMERIC) {
				if (org.apache.poi.ss.usermodel.DateUtil.isCellDateFormatted(c)) return new java.text.SimpleDateFormat("yyyyMMdd").format(c.getDateCellValue());
				return qzNum(c.getNumericCellValue());
			}
			return df.formatCellValue(c).trim();
		} catch (Exception e) { return ""; }
	}
	private static String qzNum(double d) { return (d == Math.rint(d)) ? String.valueOf((long) d) : String.valueOf(d); }
	private static String qzKey(String s) { return s == null ? "" : s.replaceAll("[\\s\u00A0:：]", ""); }
	private static double qzD(String s) { try { String t = (s == null ? "" : s).replace(",", "").replaceAll("[^0-9.\\-]", ""); return t.isEmpty() ? 0 : Double.parseDouble(t); } catch (Exception e) { return 0; } }
	/* 엑셀 날짜 : 숫자(엑셀 일련번호)·yyyy-mm-dd·yyyy.mm.dd·yyyymmdd 모두 'yyyyMMdd' 로 */
	private static String qzDate(String v) {
		String s = v == null ? "" : v.trim(); if (s.isEmpty()) return "";
		String d = s.replaceAll("[^0-9]", "");
		if (d.length() == 8) return d;
		try { double n = Double.parseDouble(s); if (n > 20000 && n < 80000) return new java.text.SimpleDateFormat("yyyyMMdd").format(org.apache.poi.ss.usermodel.DateUtil.getJavaDate(n)); } catch (Exception e) { }
		return "";
	}
	@Override public java.util.Map<String,Object> parseQuoteXls(byte[] data, String fileNm) throws Exception {
		java.util.Map<String,Object> q = new java.util.LinkedHashMap<String,Object>();
		java.util.List<java.util.Map<String,Object>> lines = new java.util.ArrayList<java.util.Map<String,Object>>();
		q.put("fileNm", fileNm); q.put("docNo", ""); q.put("quoteDt", ""); q.put("recvNm", ""); q.put("mgrNm", ""); q.put("validTxt", ""); q.put("titleTxt", ""); q.put("remark", "");
		q.put("price1Nm", ""); q.put("price2Nm", "");
		org.apache.poi.ss.usermodel.Workbook wb = org.apache.poi.ss.usermodel.WorkbookFactory.create(new java.io.ByteArrayInputStream(data));
		try {
			org.apache.poi.ss.usermodel.DataFormatter df = new org.apache.poi.ss.usermodel.DataFormatter();
			org.apache.poi.ss.usermodel.FormulaEvaluator ev = wb.getCreationHelper().createFormulaEvaluator();
			org.apache.poi.ss.usermodel.Sheet sh = wb.getSheetAt(0);
			/* 줄마다 값 있는 칸만 (열 번호 → 글) */
			java.util.List<java.util.TreeMap<Integer,String>> rows = new java.util.ArrayList<java.util.TreeMap<Integer,String>>();
			for (int r = 0; r <= sh.getLastRowNum(); r++) {
				java.util.TreeMap<Integer,String> cells = new java.util.TreeMap<Integer,String>();
				org.apache.poi.ss.usermodel.Row row = sh.getRow(r);
				if (row != null) for (int c = 0; c < row.getLastCellNum(); c++) { String v = qzCell(row.getCell(c), df, ev); if (!v.isEmpty()) cells.put(c, v); }
				rows.add(cells);
			}
			int cName = -1, cSpec = -1, cUnit = -1, cQty = -1, cRmk = -1, hdrEnd = -1;
			int cP1 = -1, cA1 = -1, cP2 = -1, cA2 = -1;
			/* ── 머리표 + 품목 머리줄 찾기 ── */
			for (int r = 0; r < rows.size(); r++) {
				java.util.TreeMap<Integer,String> cells = rows.get(r);
				if (cells.isEmpty()) continue;
				for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
					String k = qzKey(e.getValue()); java.util.Map.Entry<Integer,String> nv = cells.higherEntry(e.getKey());
					String val = nv == null ? "" : nv.getValue().trim();
					if ("문서번호".equals(k) && !val.isEmpty()) q.put("docNo", val);
					else if ("수신".equals(k) && !val.isEmpty()) q.put("recvNm", val);
					else if (("견적일".equals(k) || "견적일자".equals(k) || "일자".equals(k)) && !val.isEmpty()) q.put("quoteDt", qzDate(val));
					else if ("담당자".equals(k) && !val.isEmpty()) q.put("mgrNm", val);
					else if ("유효기간".equals(k) && !val.isEmpty()) q.put("validTxt", val);
					else if (e.getValue().indexOf("견적을") >= 0 && e.getValue().indexOf("드립니다") >= 0) q.put("titleTxt", e.getValue().trim());
				}
				/* 품목 머리줄 = 품명/품목 + 수량 이 같은 줄. 단가는 같은 줄(한 줄 머리) 또는 아랫줄(두 줄 머리 — 센터배송/택배출고 묶음) */
				boolean hn = false, hq = false;
				for (String v : cells.values()) { String k = qzKey(v); if (k.startsWith("품명") || k.startsWith("품목")) hn = true; if ("수량".equals(k)) hq = true; }
				if (!(hn && hq)) continue;
				java.util.TreeMap<Integer,String> sub = (r + 1 < rows.size()) ? rows.get(r + 1) : new java.util.TreeMap<Integer,String>();
				boolean twoRow = false;
				for (String v : sub.values()) { String k = qzKey(v); if ("단가".equals(k) || "금액".equals(k) || "box".equalsIgnoreCase(k) || "ea".equalsIgnoreCase(k)) twoRow = true; }
				for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
					String k = qzKey(e.getValue());
					if (k.startsWith("품명") || k.startsWith("품목")) cName = e.getKey(); else if (k.startsWith("규격")) cSpec = e.getKey();
					else if ("단위".equals(k)) cUnit = e.getKey(); else if ("수량".equals(k)) cQty = e.getKey();
					else if (k.startsWith("비고")) cRmk = e.getKey();
				}
				/* 단가·금액 칸 — 묶음 이름은 윗줄에서 그 칸 왼쪽(같거나 앞) 가장 가까운 「알려지지 않은」 머리글 */
				java.util.TreeMap<Integer,String> priceRow = twoRow ? sub : cells;
				java.util.List<int[]> pcs = new java.util.ArrayList<int[]>();   /* {단가칸, 금액칸} 차례대로 */
				int lastP = -1;
				for (java.util.Map.Entry<Integer,String> e : priceRow.entrySet()) {
					String k = qzKey(e.getValue());
					if ("단가".equals(k)) { lastP = e.getKey(); pcs.add(new int[]{ lastP, -1 }); }
					else if (("금액".equals(k) || "공급가액".equals(k)) && !pcs.isEmpty() && pcs.get(pcs.size() - 1)[1] < 0) pcs.get(pcs.size() - 1)[1] = e.getKey();
				}
				boolean priceFromSub = twoRow;
				if (pcs.isEmpty() && twoRow) {   /* 아랫줄이 Box/ea 뿐이고 단가는 윗줄에 있는 양식(첫 표본) — 윗줄에서 다시 찾는다 */
					priceFromSub = false; lastP = -1;
					for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
						String k = qzKey(e.getValue());
						if ("단가".equals(k)) { lastP = e.getKey(); pcs.add(new int[]{ lastP, -1 }); }
						else if (("금액".equals(k) || "공급가액".equals(k)) && !pcs.isEmpty() && pcs.get(pcs.size() - 1)[1] < 0) pcs.get(pcs.size() - 1)[1] = e.getKey();
					}
				}
				if (!pcs.isEmpty()) { cP1 = pcs.get(0)[0]; cA1 = pcs.get(0)[1]; }
				if (pcs.size() > 1) { cP2 = pcs.get(1)[0]; cA2 = pcs.get(1)[1]; }
				if (priceFromSub) {
					java.util.Set<String> known = new java.util.HashSet<String>(java.util.Arrays.asList("품명","품목","규격","단위","수량","단가","금액","비고","공급가액"));
					for (int g = 0; g < Math.min(2, pcs.size()); g++) {
						String nm = "";
						for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
							if (e.getKey() > pcs.get(g)[0]) break;
							String k = qzKey(e.getValue()); boolean kn = false; for (String s : known) if (k.startsWith(s)) kn = true;
							if (!kn) nm = e.getValue().replace("\n", " ").trim();
						}
						q.put(g == 0 ? "price1Nm" : "price2Nm", nm);
					}
				}
				/* 단위 이름(ea) — 아랫줄 수량 칸 자리 */
				if (twoRow) for (java.util.Map.Entry<Integer,String> e : sub.entrySet()) if (cQty >= 0 && e.getKey() == cQty) q.put("unitDef", e.getValue().trim());
				hdrEnd = twoRow ? r + 1 : r;
				break;
			}
			/* ── 품목 줄 · 비고 ── */
			StringBuilder rmk = new StringBuilder(); boolean inRmk = false; int rowNo = 0;
			if (hdrEnd >= 0) for (int r = hdrEnd + 1; r < rows.size(); r++) {
				java.util.TreeMap<Integer,String> cells = rows.get(r);
				if (cells.isEmpty()) continue;
				String first = cells.firstEntry().getValue().trim();
				if (!inRmk && qzKey(first).startsWith("비고") && cells.firstKey() <= Math.max(0, cName)) inRmk = true;
				if (inRmk) {
					for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
						String t = e.getValue().trim();
						if (e.getKey() == cells.firstKey() && qzKey(t).startsWith("비고")) { t = t.replaceFirst("^\\s*비\\s*고\\s*[:：]?\\s*", "").trim(); if (t.isEmpty()) continue; }
						if (rmk.length() > 0) rmk.append("\n"); rmk.append(t);
					}
					continue;
				}
				String nm = cName >= 0 && cells.containsKey(cName) ? cells.get(cName) : "";
				String qs = cQty >= 0 && cells.containsKey(cQty) ? cells.get(cQty) : "";
				String ps = cP1 >= 0 && cells.containsKey(cP1) ? cells.get(cP1) : "";
				if (nm.isEmpty() && qzD(qs) == 0 && qzD(ps) == 0) continue;
				if ("합계".equals(qzKey(nm)) || "총계".equals(qzKey(nm)) || "소계".equals(qzKey(nm))) continue;
				java.util.Map<String,Object> l = new java.util.LinkedHashMap<String,Object>();
				String us = cUnit >= 0 && cells.containsKey(cUnit) ? cells.get(cUnit) : "";
				double qty = qzD(qs), price = qzD(ps);
				String as = cA1 >= 0 && cells.containsKey(cA1) ? cells.get(cA1) : "";
				double amt = qzD(as); if (amt == 0 && qty != 0 && price != 0) amt = Math.round(qty * price);
				double price2 = cP2 >= 0 && cells.containsKey(cP2) ? qzD(cells.get(cP2)) : 0;
				double amt2 = cA2 >= 0 && cells.containsKey(cA2) ? qzD(cells.get(cA2)) : 0; if (amt2 == 0 && qty != 0 && price2 != 0) amt2 = Math.round(qty * price2);
				l.put("rowNo", ++rowNo); l.put("prodNm", nm.replace("\n", " ").trim()); l.put("spec", (cSpec >= 0 && cells.containsKey(cSpec) ? cells.get(cSpec) : "").replace("\n", " ").trim());
				boolean unitNum = !us.isEmpty() && us.replaceAll("[0-9.,]", "").isEmpty();
				l.put("boxQty", unitNum ? Double.valueOf(qzD(us)) : null);
				l.put("unit", unitNum ? String.valueOf(q.get("unitDef") == null ? "ea" : q.get("unitDef")) : us);
				l.put("qty", Double.valueOf(qty)); l.put("unitPrice", Double.valueOf(price)); l.put("amt", Double.valueOf(amt));
				l.put("unitPrice2", cP2 >= 0 ? Double.valueOf(price2) : null); l.put("amt2", cP2 >= 0 ? Double.valueOf(amt2) : null);
				l.put("remark", (cRmk >= 0 && cells.containsKey(cRmk) ? cells.get(cRmk) : "").replace("\n", " ").trim());
				lines.add(l);
			}
			q.remove("unitDef");
			q.put("remark", rmk.toString());
		} finally { wb.close(); }
		double sum = 0; for (java.util.Map<String,Object> l : lines) sum += scNum(l.get("amt"));
		q.put("supplyAmt", Double.valueOf(Math.round(sum)));
		q.put("lines", lines);
		return q;
	}
	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public long saveQuote(java.util.Map<String,Object> q, String user, String ip, String compCd) throws Exception {
		String docNo = scStr(q.get("docNo"));
		if (docNo.isEmpty()) throw new Exception("문서번호가 없습니다.");
		java.util.Map<String,Object> m = new java.util.HashMap<String,Object>();
		m.put("compCd", compCd); m.put("docNo", docNo); m.put("regUser", user); m.put("regIp", ip);
		mapper.markQuoteReplace(m);                                                   // 같은 문서번호는 대체
		String dt = scStr(q.get("quoteDt")).replace("-", "").replace("/", "").replace(".", "");
		m.put("quoteDt", dt.length() == 8 ? dt : null);
		m.put("recvNm", scStr(q.get("recvNm"))); m.put("mgrNm", scStr(q.get("mgrNm"))); m.put("validTxt", scStr(q.get("validTxt")));
		m.put("titleTxt", scStr(q.get("titleTxt"))); String rm = scStr(q.get("remark")); m.put("remark", rm.length() > 990 ? rm.substring(0, 990) : rm);
		String p1 = scStr(q.get("price1Nm")), p2 = scStr(q.get("price2Nm"));   /* 단가 묶음 이름(센터배송 · 택배출고) — 묶음이 하나면 비운다 */
		m.put("price1Nm", p1.isEmpty() ? null : p1); m.put("price2Nm", p2.isEmpty() ? null : p2);
		String fn = scStr(q.get("fileNm")); m.put("fileNm", fn.length() > 190 ? fn.substring(0, 190) : fn);
		Object b64 = q.get("fileB64"); m.put("fileB64", (b64 == null || String.valueOf(b64).isEmpty()) ? null : String.valueOf(b64));
		java.util.List<?> raw = (q.get("lines") instanceof java.util.List) ? (java.util.List<?>) q.get("lines") : new java.util.ArrayList<Object>();
		double sum = 0; java.util.List<java.util.Map<String,Object>> rows = new java.util.ArrayList<java.util.Map<String,Object>>();
		int no = 0;
		for (Object o : raw) {
			if (!(o instanceof java.util.Map)) continue;
			@SuppressWarnings("unchecked") java.util.Map<String,Object> l = (java.util.Map<String,Object>) o;
			String nm = scStr(l.get("prodNm")); double qty = scNum(l.get("qty")), price = scNum(l.get("unitPrice")), amt = scNum(l.get("amt"));
			if (nm.isEmpty() && qty == 0 && amt == 0) continue;
			if (amt == 0 && qty != 0 && price != 0) amt = Math.round(qty * price);
			java.util.Map<String,Object> d = new java.util.HashMap<String,Object>();
			d.put("rowNo", ++no); d.put("prodNm", nm); d.put("spec", scStr(l.get("spec")));
			d.put("boxQty", l.get("boxQty") == null || scStr(l.get("boxQty")).isEmpty() ? null : Double.valueOf(scNum(l.get("boxQty"))));
			d.put("unit", scStr(l.get("unit"))); d.put("qty", Double.valueOf(qty)); d.put("unitPrice", Double.valueOf(price)); d.put("amt", Double.valueOf(Math.round(amt)));
			d.put("remark", scStr(l.get("remark"))); d.put("prodCd", scStr(l.get("prodCd")).isEmpty() ? null : scStr(l.get("prodCd")));
			boolean has2 = l.get("unitPrice2") != null && !scStr(l.get("unitPrice2")).isEmpty();
			double pr2 = scNum(l.get("unitPrice2")), am2 = scNum(l.get("amt2")); if (has2 && am2 == 0 && qty != 0 && pr2 != 0) am2 = Math.round(qty * pr2);
			d.put("unitPrice2", has2 ? Double.valueOf(pr2) : null); d.put("amt2", has2 ? Double.valueOf(Math.round(am2)) : null);
			rows.add(d); sum += Math.round(amt);
		}
		m.put("supplyAmt", Double.valueOf(sum));
		mapper.insertQuoteMst(m);
		long seq = Math.round(scNum(m.get("quoteSeq")));
		for (java.util.Map<String,Object> d : rows) { d.put("quoteSeq", Long.valueOf(seq)); mapper.insertQuoteDtl(d); }
		return seq;
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectQuoteList(java.util.Map<String,Object> p) throws Exception { return mapper.selectQuoteList(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectQuoteDtl(java.util.Map<String,Object> p) throws Exception { return mapper.selectQuoteDtl(p); }
	@Override public java.util.Map<String,Object> selectQuoteFile(java.util.Map<String,Object> p) throws Exception { return mapper.selectQuoteFile(p); }
	@Override public int deleteQuote(java.util.Map<String,Object> p) throws Exception { return mapper.deleteQuote(p); }
	@Override public java.util.Map<String,Object> selectQuoteByDoc(java.util.Map<String,Object> p) throws Exception { return mapper.selectQuoteByDoc(p); }
	@Override public java.util.Map<String,Object> selectQuoteMst(java.util.Map<String,Object> p) throws Exception { return mapper.selectQuoteMst(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectQuoteNames(java.util.Map<String,Object> p) throws Exception { return mapper.selectQuoteNames(p); }
	/* ===== 견적서 엑셀 = 우리 양식 파일에 값만 채운다 (2026-09-17 「엑셀로 출력은 양식 그대로」) =====
	   양식 = resources/quote_tpl1.xls(단가 묶음 1, 표본 260729-1) · quote_tpl2.xls(묶음 2, 표본 260730-1). 서식·병합·공급자 칸은 양식 그대로.
	   · 머리 : 「문서 번호」「수 신」「견 적 일」「담 당 자」「유효기간」 이름표의 오른쪽 칸, 제목 줄은 「견적을 드립니다」가 든 칸
	   · 품목 : 머리줄(품명/품목 + 수량) 아래 줄들. 양식 줄보다 많으면 비고 줄부터 아래로 밀고 마지막 품목 줄의 서식·병합을 복사, 적으면 남는 줄은 비운다
	   · 금액은 수식 대신 값으로 넣는다(줄을 끼워 넣어도 안 어긋나게). 비고 줄은 「비고」 이름표 오른쪽(또는 「비고 : …」 한 칸). */
	private static java.util.TreeMap<Integer,String> qzRowText(org.apache.poi.ss.usermodel.Row row, org.apache.poi.ss.usermodel.DataFormatter df) {
		java.util.TreeMap<Integer,String> m = new java.util.TreeMap<Integer,String>();
		if (row == null) return m;
		for (int c = 0; c < row.getLastCellNum(); c++) {
			org.apache.poi.ss.usermodel.Cell cl = row.getCell(c); if (cl == null) continue;
			String v = "";
			try { if (cl.getCellTypeEnum() == org.apache.poi.ss.usermodel.CellType.STRING) v = cl.getStringCellValue().trim(); else if (cl.getCellTypeEnum() != org.apache.poi.ss.usermodel.CellType.FORMULA) v = df.formatCellValue(cl).trim(); } catch (Exception e) { v = ""; }
			if (!v.isEmpty()) m.put(c, v);
		}
		return m;
	}
	private static org.apache.poi.ss.usermodel.Cell qzCellOf(org.apache.poi.ss.usermodel.Row row, int c) {
		if (c < 0) return null;
		org.apache.poi.ss.usermodel.Cell cl = row.getCell(c); if (cl == null) cl = row.createCell(c);
		return cl;
	}
	/* 빈 값은 <빈 칸>(BLANK)으로 — "" 글자를 넣으면 양식의 금액 수식(E13*F13)이 빈 글자끼리 곱해 #VALUE! 가 났다(2026-09-17 실제 발생).
	   수식 칸은 먼저 숫자 칸으로 바꿔 수식을 지운다 — POI 는 수식 칸에 값을 넣으면 수식을 남기고 계산값만 바꾼다. */
	private static void qzSet(org.apache.poi.ss.usermodel.Row row, int c, String v) {
		org.apache.poi.ss.usermodel.Cell cl = qzCellOf(row, c); if (cl == null) return;
		if (cl.getCellTypeEnum() == org.apache.poi.ss.usermodel.CellType.FORMULA) cl.setCellType(org.apache.poi.ss.usermodel.CellType.STRING);
		if (v == null || v.isEmpty()) cl.setCellType(org.apache.poi.ss.usermodel.CellType.BLANK); else cl.setCellValue(v);
	}
	private static void qzNumSet(org.apache.poi.ss.usermodel.Row row, int c, Object v) {
		org.apache.poi.ss.usermodel.Cell cl = qzCellOf(row, c); if (cl == null) return;
		if (cl.getCellTypeEnum() == org.apache.poi.ss.usermodel.CellType.FORMULA) cl.setCellType(org.apache.poi.ss.usermodel.CellType.NUMERIC);
		if (v == null || scStr(v).isEmpty()) { cl.setCellType(org.apache.poi.ss.usermodel.CellType.BLANK); return; }
		cl.setCellValue(scNum(v));
	}
	/* 강조 색 (2026-09-17 「엑셀에 빨간 표시 안 나옴」) — 양식 1(묶음 하나)엔 원본부터 색이 없어 어느 양식이든 같은 규칙으로 넣는다 :
	   빨간 굵게 = 둘째 묶음(택배출고) 머리·단가·금액, 비고(MOQ) 값, 아래 비고 줄 / 파란 굵게 = 첫째 묶음(센터배송) 머리(묶음이 둘일 때).
	   셀 서식은 복제해 글꼴만 바꾼다(테두리·정렬 유지). 같은 (원서식, 색) 짝은 캐시해 서식 수가 늘지 않게. */
	private static void qzColor(org.apache.poi.ss.usermodel.Workbook wb, org.apache.poi.ss.usermodel.Row row, int c, short color, java.util.Map<String,org.apache.poi.ss.usermodel.CellStyle> cache) {
		if (row == null || c < 0) return;
		org.apache.poi.ss.usermodel.Cell cl = row.getCell(c); if (cl == null) cl = row.createCell(c);
		org.apache.poi.ss.usermodel.CellStyle old = cl.getCellStyle();
		String key = old.getIndex() + ":" + color;
		org.apache.poi.ss.usermodel.CellStyle ns = cache.get(key);
		if (ns == null) {
			ns = wb.createCellStyle(); ns.cloneStyleFrom(old);
			org.apache.poi.ss.usermodel.Font of = wb.getFontAt(old.getFontIndex());
			org.apache.poi.ss.usermodel.Font nf = wb.createFont();
			nf.setFontName(of.getFontName()); nf.setFontHeight(of.getFontHeight()); nf.setItalic(of.getItalic()); nf.setUnderline(of.getUnderline());
			nf.setBold(true); nf.setColor(color);
			ns.setFont(nf); cache.put(key, ns);
		}
		cl.setCellStyle(ns);
	}
	@Override public byte[] buildQuoteXls(java.util.Map<String,Object> mst, java.util.List<java.util.Map<String,Object>> lines) throws Exception {
		boolean two = !scStr(mst.get("price2Nm")).isEmpty();
		java.io.InputStream in = UserServiceImpl.class.getClassLoader().getResourceAsStream(two ? "quote_tpl2.xls" : "quote_tpl1.xls");
		if (in == null) throw new Exception("견적서 양식 파일(quote_tpl" + (two ? 2 : 1) + ".xls)이 없습니다.");
		org.apache.poi.hssf.usermodel.HSSFWorkbook wb = new org.apache.poi.hssf.usermodel.HSSFWorkbook(in);
		try {
			org.apache.poi.ss.usermodel.Sheet sh = wb.getSheetAt(0);
			org.apache.poi.ss.usermodel.DataFormatter df = new org.apache.poi.ss.usermodel.DataFormatter();
			int hdr = -1, cName = -1, cSpec = -1, cUnit = -1, cQty = -1, cP1 = -1, cA1 = -1, cP2 = -1, cA2 = -1, cRmk = -1; boolean twoRow = false;
			java.util.Set<String> known = new java.util.HashSet<String>(java.util.Arrays.asList("품명","품목","규격","단위","수량","단가","금액","비고","공급가액","box","ea"));
			for (int r = 0; r <= sh.getLastRowNum(); r++) {
				org.apache.poi.ss.usermodel.Row row = sh.getRow(r); if (row == null) continue;
				java.util.TreeMap<Integer,String> cells = qzRowText(row, df);
				if (cells.isEmpty()) continue;
				for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
					String k = qzKey(e.getValue()); java.util.Map.Entry<Integer,String> nv = cells.higherEntry(e.getKey());
					int vc = (nv == null || nv.getKey() > e.getKey() + 2) ? e.getKey() + 1 : nv.getKey();
					if ("문서번호".equals(k)) qzSet(row, vc, scStr(mst.get("docNo")));
					else if ("수신".equals(k)) qzSet(row, vc, scStr(mst.get("recvNm")));
					else if ("견적일".equals(k) || "견적일자".equals(k)) {
						String d = scStr(mst.get("quoteDt")); org.apache.poi.ss.usermodel.Cell c = qzCellOf(row, vc);
						if (d.length() == 8) c.setCellValue(new java.text.SimpleDateFormat("yyyyMMdd").parse(d)); else c.setCellValue("");
					}
					else if ("담당자".equals(k)) qzSet(row, vc, scStr(mst.get("mgrNm")));
					else if ("유효기간".equals(k)) qzSet(row, vc, scStr(mst.get("validTxt")));
					else if (e.getValue().indexOf("견적을") >= 0 && e.getValue().indexOf("드립니다") >= 0 && !scStr(mst.get("titleTxt")).isEmpty()) qzSet(row, e.getKey(), scStr(mst.get("titleTxt")));
				}
				boolean hn = false, hq = false;
				for (String v : cells.values()) { String k = qzKey(v); if (k.startsWith("품명") || k.startsWith("품목")) hn = true; if ("수량".equals(k)) hq = true; }
				if (hn && hq && hdr < 0) {
					hdr = r;
					for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
						String k = qzKey(e.getValue());
						if (k.startsWith("품명") || k.startsWith("품목")) cName = e.getKey(); else if (k.startsWith("규격")) cSpec = e.getKey();
						else if ("단위".equals(k)) cUnit = e.getKey(); else if ("수량".equals(k)) cQty = e.getKey(); else if (k.startsWith("비고")) cRmk = e.getKey();
					}
					java.util.TreeMap<Integer,String> sub = qzRowText(sh.getRow(r + 1), df);
					for (String v : sub.values()) { String k = qzKey(v).toLowerCase(); if ("단가".equals(k) || "금액".equals(k) || "box".equals(k) || "ea".equals(k)) twoRow = true; }
					java.util.List<int[]> pcs = new java.util.ArrayList<int[]>();
					java.util.TreeMap<Integer,String> pr = twoRow ? sub : cells;
					for (int pass = 0; pass < 2 && pcs.isEmpty(); pass++) {
						java.util.TreeMap<Integer,String> src = (pass == 0) ? pr : cells;
						for (java.util.Map.Entry<Integer,String> e : src.entrySet()) {
							String k = qzKey(e.getValue());
							if ("단가".equals(k)) pcs.add(new int[]{ e.getKey(), -1 });
							else if (("금액".equals(k) || "공급가액".equals(k)) && !pcs.isEmpty() && pcs.get(pcs.size() - 1)[1] < 0) pcs.get(pcs.size() - 1)[1] = e.getKey();
						}
					}
					if (!pcs.isEmpty()) { cP1 = pcs.get(0)[0]; cA1 = pcs.get(0)[1]; }
					if (pcs.size() > 1) { cP2 = pcs.get(1)[0]; cA2 = pcs.get(1)[1]; }
					/* 두 줄 머리의 묶음 이름(센터배송·택배출고) → 견적서에 적힌 이름으로 */
					if (two && twoRow) {
						int g = 0;
						for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
							String k = qzKey(e.getValue()).toLowerCase(); boolean kn = false; for (String s : known) if (k.startsWith(s)) kn = true;
							if (kn) continue;
							String nm = scStr(mst.get(g == 0 ? "price1Nm" : "price2Nm")); if (!nm.isEmpty()) qzSet(row, e.getKey(), nm);
							if (++g >= 2) break;
						}
					}
				}
			}
			if (hdr < 0 || cName < 0 || cQty < 0) throw new Exception("양식에서 품목 머리줄(품명·수량)을 찾지 못했습니다.");
			int start = hdr + (twoRow ? 2 : 1);
			int rmkRow = -1;
			for (int r = start; r <= sh.getLastRowNum(); r++) {
				java.util.TreeMap<Integer,String> cells = qzRowText(sh.getRow(r), df);
				if (!cells.isEmpty() && qzKey(cells.firstEntry().getValue()).startsWith("비고") && cells.firstKey() <= Math.max(0, cName)) { rmkRow = r; break; }
			}
			int tplRows = rmkRow < 0 ? 2 : rmkRow - start;
			int need = Math.max(1, lines.size());
			if (need > tplRows) {
				int add = need - tplRows, last = sh.getLastRowNum();
				org.apache.poi.ss.usermodel.Row src = sh.getRow(start + tplRows - 1);
				java.util.List<int[]> srcMerges = new java.util.ArrayList<int[]>();
				for (int i = 0; i < sh.getNumMergedRegions(); i++) {
					org.apache.poi.ss.util.CellRangeAddress m = sh.getMergedRegion(i);
					if (src != null && m.getFirstRow() == src.getRowNum() && m.getLastRow() == src.getRowNum()) srcMerges.add(new int[]{ m.getFirstColumn(), m.getLastColumn() });
				}
				if (start + tplRows <= last) sh.shiftRows(start + tplRows, last, add, true, false);
				for (int k = 0; k < add; k++) {
					int rn = start + tplRows + k;
					org.apache.poi.ss.usermodel.Row nr = sh.getRow(rn); if (nr == null) nr = sh.createRow(rn);
					if (src != null) {
						nr.setHeight(src.getHeight());
						for (int c = 0; c < src.getLastCellNum(); c++) {
							org.apache.poi.ss.usermodel.Cell sc = src.getCell(c); if (sc == null) continue;
							org.apache.poi.ss.usermodel.Cell nc = nr.getCell(c); if (nc == null) nc = nr.createCell(c);
							nc.setCellStyle(sc.getCellStyle());
						}
					}
					for (int[] m : srcMerges) sh.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rn, rn, m[0], m[1]));
				}
			}
			for (int i = 0; i < Math.max(need, tplRows); i++) {
				org.apache.poi.ss.usermodel.Row row = sh.getRow(start + i); if (row == null) row = sh.createRow(start + i);
				java.util.Map<String,Object> l = i < lines.size() ? lines.get(i) : null;
				qzSet(row, cName, l == null ? "" : scStr(l.get("prodNm")));
				if (cSpec >= 0) qzSet(row, cSpec, l == null ? "" : scStr(l.get("spec")));
				qzNumSet(row, cUnit, l == null ? null : l.get("boxQty"));
				qzNumSet(row, cQty, l == null ? null : l.get("qty"));
				qzNumSet(row, cP1, l == null ? null : l.get("unitPrice"));
				qzNumSet(row, cA1, l == null ? null : l.get("amt"));
				if (two) {   /* 둘째 묶음 단가가 없는 줄(0)은 원본처럼 빈칸 */
					Object p2 = l == null ? null : l.get("unitPrice2"), a2 = l == null ? null : l.get("amt2");
					qzNumSet(row, cP2, (p2 == null || scNum(p2) == 0) ? null : p2); qzNumSet(row, cA2, (a2 == null || scNum(a2) == 0) ? null : a2);
				}
				if (cRmk >= 0) qzSet(row, cRmk, l == null ? "" : scStr(l.get("remark")));
			}
			int rr = start + Math.max(need, tplRows);
			org.apache.poi.ss.usermodel.Row rrow = sh.getRow(rr);
			if (rrow != null) {
				java.util.TreeMap<Integer,String> cells = qzRowText(rrow, df);
				String rem = scStr(mst.get("remark")).replace("\r", "").replace("\n", " / ");
				if (!cells.isEmpty()) {
					int fc = cells.firstKey(); String first = cells.firstEntry().getValue();
					if (qzKey(first).replaceAll("[:：]", "").equals("비고")) { java.util.Map.Entry<Integer,String> nv = cells.higherEntry(fc); qzSet(rrow, nv == null ? fc + 2 : nv.getKey(), rem); }
					else if (qzKey(first).startsWith("비고")) qzSet(rrow, fc, "비고 : " + rem);
				}
			}
			/* 강조 색 적용 */
			{
				java.util.Map<String,org.apache.poi.ss.usermodel.CellStyle> cache = new java.util.HashMap<String,org.apache.poi.ss.usermodel.CellStyle>();
				short RED = org.apache.poi.hssf.util.HSSFColor.HSSFColorPredefined.RED.getIndex(), BLUE = org.apache.poi.hssf.util.HSSFColor.HSSFColorPredefined.BLUE.getIndex();
				int rowsAll = Math.max(need, tplRows);
				for (int i = 0; i < rowsAll; i++) {
					org.apache.poi.ss.usermodel.Row row = sh.getRow(start + i); if (row == null) continue;
					if (cRmk >= 0) qzColor(wb, row, cRmk, RED, cache);
					if (two) { qzColor(wb, row, cP2, RED, cache); qzColor(wb, row, cA2, RED, cache); }
				}
				org.apache.poi.ss.usermodel.Row h1 = sh.getRow(hdr), h2 = twoRow ? sh.getRow(hdr + 1) : null;
				if (two) {
					if (h2 != null) { qzColor(wb, h2, cP2, RED, cache); qzColor(wb, h2, cA2, RED, cache); qzColor(wb, h1, cP2, RED, cache); qzColor(wb, h1, cP1, BLUE, cache); }
					else { qzColor(wb, h1, cP2, RED, cache); qzColor(wb, h1, cA2, RED, cache); }
				}
				if (rrow != null) { java.util.TreeMap<Integer,String> rc = qzRowText(rrow, df); for (Integer c : rc.keySet()) qzColor(wb, rrow, c, RED, cache); }
			}
			try { wb.getCreationHelper().createFormulaEvaluator().evaluateAll(); } catch (Exception e) { /* 수식이 있어도 값은 넣어 뒀다 */ }
			java.io.ByteArrayOutputStream bo = new java.io.ByteArrayOutputStream();
			wb.write(bo);
			return bo.toByteArray();
		} finally { wb.close(); in.close(); }
	}
	/* 문서번호 = 'Konet' + 견적일 yyMMdd + '-' + 두 자리 차례 (표본 Konet260729-01 과 같은 꼴). 그날 번호가 이미 있으면 다음 번호 */
	@Override public String nextQuoteNo(String compCd, String quoteDt) throws Exception {
		String d = quoteDt == null ? "" : quoteDt.replaceAll("[^0-9]", "");
		if (d.length() != 8) d = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
		String prefix = "Konet" + d.substring(2) + "-";
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
		p.put("compCd", compCd); p.put("prefix", prefix);
		int n = mapper.selectQuoteNoCnt(p) + 1;
		for (int guard = 0; guard < 50; guard++) {                                  // 번호가 비어 있는 자리가 있어도 겹치지 않게
			String cand = prefix + (n < 10 ? "0" + n : String.valueOf(n));
			java.util.Map<String,Object> k = new java.util.HashMap<String,Object>(); k.put("compCd", compCd); k.put("docNo", cand);
			if (mapper.selectQuoteByDoc(k) == null) return cand;
			n++;
		}
		return prefix + n;
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectQuoteCompare(java.util.Map<String,Object> p) throws Exception { return mapper.selectQuoteCompare(p); }

	/* ===== DC 발주 (2026-09-17) — 입고예약서·발주서에서 읽은 줄을 TBL_SHIPOUT_MST 에 PROD_KIND='DC' 로.
	   납기일자별로 한 배치(JOB_SEQ = 그 날·출고장의 다음 번호). 같은 (납기일자, 품목코드) 활성 DC 줄은 먼저 이력(N)으로 닫는다.
	   품목 해석(매칭코드 → 우리 품목)은 발주현황표 업로드와 같은 resolveShipoutProd. 재고 원장 재동기화는 컨트롤러가 한다. ===== */
	@Override public int saveDcPo(java.util.List<egovframework.konet.user.model.ShipoutDTO> rows, String user, String ip, String compCd) throws Exception {
		if (rows == null || rows.isEmpty()) return 0;
		java.util.LinkedHashMap<String, java.util.List<egovframework.konet.user.model.ShipoutDTO>> g = new java.util.LinkedHashMap<String, java.util.List<egovframework.konet.user.model.ShipoutDTO>>();
		for (egovframework.konet.user.model.ShipoutDTO r : rows) {
			String k = scStr(r.getDlvDt()).replace("-", "") + "|" + scStr(r.getDcCd());
			java.util.List<egovframework.konet.user.model.ShipoutDTO> l = g.get(k);
			if (l == null) { l = new java.util.ArrayList<egovframework.konet.user.model.ShipoutDTO>(); g.put(k, l); }
			l.add(r);
		}
		int n = 0;
		for (java.util.List<egovframework.konet.user.model.ShipoutDTO> grp : g.values()) {
			egovframework.konet.user.model.ShipoutDTO head = grp.get(0);
			for (egovframework.konet.user.model.ShipoutDTO r : grp) {
				java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
				p.put("compCd", compCd); p.put("dlvDt", r.getDlvDt()); p.put("itemCd", r.getItemCd()); p.put("regUser", user); p.put("regIp", ip);
				mapper.markDcPoReplace(p);
			}
			head.setCompCd(compCd);
			int jobSeq = mapper.getShipoutNextJobSeq(head);
			int seq = 0;
			java.util.List<egovframework.konet.user.model.ShipoutDTO> buf = new java.util.ArrayList<egovframework.konet.user.model.ShipoutDTO>();
			for (egovframework.konet.user.model.ShipoutDTO r : grp) {
				r.setCompCd(compCd); r.setJobSeq(jobSeq); r.setActionYn("Y"); r.setRowNo(++seq);
				r.setProdKind("DC"); r.setRegUser(user); r.setRegIp(ip);
				buf.add(r); n++;
				if (buf.size() >= 40) { mapper.insertShipoutMstBulk(buf); buf.clear(); }   // 한 문장 파라미터 상한(2,100) — 발주현황표 업로드와 같은 40행
			}
			if (!buf.isEmpty()) mapper.insertShipoutMstBulk(buf);
			egovframework.konet.user.model.ProdXrefDTO rx = new egovframework.konet.user.model.ProdXrefDTO();
			rx.setJobSeq(Long.valueOf(jobSeq)); rx.setDlvDt(head.getDlvDt()); rx.setDcCd(head.getDcCd()); rx.setCompCd(compCd);
			resolveShipoutProd(rx);
		}
		return n;
	}
	@Override public int deleteDcPo(java.util.List<java.util.Map<String,Object>> keys, String user, String ip, String compCd) throws Exception {
		int n = 0;
		if (keys == null) return 0;
		for (java.util.Map<String,Object> k : keys) {
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("compCd", compCd); p.put("dlvDt", scStr(k.get("dlvDt"))); p.put("itemCd", scStr(k.get("itemCd"))); p.put("regUser", user); p.put("regIp", ip);
			if (scStr(k.get("itemCd")).isEmpty() || scStr(k.get("dlvDt")).isEmpty()) continue;
			n += mapper.deleteDcPo(p);
		}
		return n;
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectDcPoList(java.util.Map<String,Object> p) throws Exception { return mapper.selectDcPoList(p); }
	@Override public int saveExpenseDtl(java.util.List<java.util.Map<String,Object>> rows, String ym, String itemCd, String user, String ip, String compCd) throws Exception {
		String y = ym.replace("-", "").trim(); int n = 0;
		if (rows != null) for (java.util.Map<String,Object> r : rows) {
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("compCd", compCd); p.put("expYm", y); p.put("itemCd", itemCd); p.put("regUser", user); p.put("regIp", ip);
			long seq = Math.round(scNum(r.get("dtlSeq"))); p.put("dtlSeq", seq);
			if ("Y".equals(scStr(r.get("del")))) { if (seq > 0) n += mapper.deleteExpenseDtl(p); continue; }
			String dt = scStr(r.get("expDt")).replace("-", "");
			p.put("expDt", dt.length() == 8 ? dt : null);
			p.put("title", scStr(r.get("title"))); p.put("amt", Math.round(scNum(r.get("amt")))); p.put("remark", scStr(r.get("remark")));
			p.put("chkYn", "Y".equals(scStr(r.get("chkYn"))) ? "Y" : "N");
			n += (seq > 0) ? mapper.updateExpenseDtl(p) : mapper.insertExpenseDtl(p);
		}
		java.util.Map<String,Object> s = new java.util.HashMap<String,Object>();
		s.put("compCd", compCd); s.put("expYm", y); s.put("itemCd", itemCd); s.put("regUser", user); s.put("regIp", ip);
		mapper.syncExpenseTrxFromDtl(s);
		return n;
	}

	/* ===== 창고 (2026-09-16 P3 1단계) — TBL_WH_MST · 원장 WH_CD(비면 기본창고, SQL 이 채운다) · 창고 이동 =====
	   이동 = 보내는 창고 A(−qty) + 받는 창고 A(+qty), REF_GB='MOVE', 같은 REF_NO — 전체 재고는 안 변하고 창고별만 옮긴다.
	   품목 재고 캐시(TBL_STOCK_MST)는 품목 합이라 이동으로 안 바뀐다(recalc 불필요). */
	@Override public java.util.List<java.util.Map<String,Object>> selectWhList(String compCd, boolean useOnly) throws Exception {
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
		p.put("compCd", compCd); p.put("useOnly", useOnly ? "Y" : "N");
		return mapper.selectWhList(p);
	}
	@Override public java.util.Map<String,Object> selectWhQtyMap(String compCd) throws Exception {
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>(); p.put("compCd", compCd);
		java.util.Map<String,Object> r = new java.util.HashMap<String,Object>();
		for (java.util.Map<String,Object> m : mapper.selectWhQtyMap(p)) r.put(scStr(m.get("whCd")), m.get("curQty"));
		return r;
	}
	@Override public int saveWhMst(java.util.Map<String,Object> p) throws Exception {
		int n = mapper.upsertWhMst(p);
		if ("Y".equals(scStr(p.get("defaultYn")))) mapper.clearWhDefault(p);   // 기본창고는 하나
		return n;
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectStockByWh(egovframework.konet.user.model.StockMstDTO dto) throws Exception { return mapper.selectStockByWh(dto); }
	@Override public int saveStockMove(java.util.Map<String,Object> p) throws Exception {
		String ym = ym6FromTrx(scStr(p.get("trxDt")));
		if (ym != null) {
			egovframework.konet.user.model.ClosingMstDTO c = new egovframework.konet.user.model.ClosingMstDTO();
			c.setCloseYm(ym); c.setCompCd(scStr(p.get("compCd")));
			egovframework.konet.user.model.ClosingMstDTO cm = mapper.selectClosingMst(c);
			if (cm != null && "C".equals(cm.getStatus())) throw new Exception("마감 확정된 달(" + ym.substring(0,4) + "-" + ym.substring(4) + ")입니다 — 재고 수불이 잠겨 있어 이동할 수 없습니다.");
		}
		if (p.get("refNo") == null) p.put("refNo", "MV" + System.currentTimeMillis());
		int n = mapper.insertStockMoveLedger(p);
		if (n != 2) throw new Exception("품목코드 " + scStr(p.get("prodCd")) + " 을(를) 상품마스터에서 찾지 못했습니다.");
		return n;
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectStockMoveList(java.util.Map<String,Object> p) throws Exception { return mapper.selectStockMoveList(p); }
	@Override public int cancelStockMove(java.util.Map<String,Object> p) throws Exception { return mapper.cancelStockMove(p); }

	/* ===== 택배 「출력됨」 서버 저장 · 출고장 표 (2026-09-16 P3) ===== */
	@Override public java.util.List<java.util.Map<String,Object>> selectParcelPrintList(String compCd, String frDt, String toDt) throws Exception {
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
		p.put("compCd", compCd); p.put("frDt", frDt); p.put("toDt", toDt);
		return mapper.selectParcelPrintList(p);
	}
	@Override public int markParcelPrint(java.util.List<java.util.Map<String,Object>> rows, String user, String compCd) throws Exception {
		if (rows == null) return 0;
		int n = 0;
		for (java.util.Map<String,Object> r : rows) {
			String dt = scStr(r.get("outDt")).replace("-", ""), nm = scStr(r.get("itemNm"));
			if (dt.length() != 8 || nm.isEmpty()) continue;             // 키가 안 되는 줄은 건너뛴다
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("compCd", compCd); p.put("outDt", dt); p.put("bizCd", scStr(r.get("bizCd"))); p.put("itemNm", nm); p.put("printUser", user);
			n += mapper.upsertParcelPrint(p);
		}
		return n;
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectDcList(String compCd) throws Exception {
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>(); p.put("compCd", compCd);
		return mapper.selectDcList(p);
	}
	@Override public int saveDcWh(java.util.Map<String,Object> p) throws Exception { return mapper.updateDcWh(p); }

	/* ===== 마감 집계 ===== */
	@Override public java.util.List<egovframework.konet.user.model.ClosingDTO> selectClosing(egovframework.konet.user.model.ClosingDTO dto) throws Exception { return mapper.selectClosing(dto); }
	@Override public java.util.List<egovframework.konet.user.model.ClosingDTO> selectClosingUnmatched(egovframework.konet.user.model.ClosingDTO dto) throws Exception { return mapper.selectClosingUnmatched(dto); }
	@Override public java.util.List<egovframework.konet.user.model.StockClosingDTO> selectStockClosing(egovframework.konet.user.model.StockClosingDTO dto) throws Exception { return mapper.selectStockClosing(dto); }
	@Override public java.util.List<egovframework.konet.user.model.StockClosingDTO> selectInboundClosing(egovframework.konet.user.model.StockClosingDTO dto) throws Exception { return mapper.selectInboundClosing(dto); }

	@Override public List<CompConDTO> selectCompContList(CompConDTO dto) throws Exception { return mapper.selectCompContList(dto); }
	@Override public List<CompConDTO> getCompContList(CompConDTO dto) throws Exception { return mapper.getCompContList(dto); }
	@Override public String CompContDupChk(CompConDTO dto) throws Exception { return mapper.CompContDupChk(dto); }
	@Override public int insertCompCont(CompConDTO dto) throws Exception { return mapper.insertCompCont(dto); }
	@Override public int updateCompCont(CompConDTO dto) throws Exception { return mapper.updateCompCont(dto); }

	@Override public java.util.List<java.util.Map<String,Object>> selectCommCodeList(java.util.Map<String,Object> param) throws Exception { return mapper.selectCommCodeList(param); }

	// ===== 공통코드 관리 (codecd.jsp) =====
	@Override public List<egovframework.konet.user.model.CodeMdDTO> codeMstList(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.codeMstList(dto); }
	@Override public String codeMstDupChk(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.codeMstDupChk(dto); }
	@Override public int insertCodeMst(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.insertCodeMst(dto); }
	@Override public int updateCodeMst(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.updateCodeMst(dto); }
	@Override public List<egovframework.konet.user.model.CodeMdDTO> codeDtlList(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.codeDtlList(dto); }
	@Override public String codeDtlDupChk(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.codeDtlDupChk(dto); }
	@Override public int insertCodeDtl(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.insertCodeDtl(dto); }
	@Override public int updateCodeDtl(egovframework.konet.user.model.CodeMdDTO dto) throws Exception { return mapper.updateCodeDtl(dto); }
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
	@Override public java.util.List<egovframework.konet.user.model.PurchaseDTO> selectPurchaseList(egovframework.konet.user.model.PurchaseDTO dto) throws Exception { return mapper.selectPurchaseList(dto); }
	@Override public String selectPurchaseNextNo(egovframework.konet.user.model.PurchaseDTO dto) throws Exception { return mapper.selectPurchaseNextNo(dto); }
	@Override public egovframework.konet.user.model.PurchaseDtlDTO selectVendorLastPrice(egovframework.konet.user.model.PurchaseDtlDTO dto) throws Exception { return mapper.selectVendorLastPrice(dto); }
	@Override public java.util.List<egovframework.konet.user.model.PurchaseDtlDTO> selectPurchasePriceHist(egovframework.konet.user.model.PurchaseDtlDTO dto) throws Exception { return mapper.selectPurchasePriceHist(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectPurchaseLedger(egovframework.konet.user.model.PurchaseDTO dto) throws Exception { return mapper.selectPurchaseLedger(dto); }

	@Override public egovframework.konet.user.model.PurchaseDTO selectPurchaseOne(egovframework.konet.user.model.PurchaseDTO dto) throws Exception {
		java.util.List<egovframework.konet.user.model.PurchaseDTO> l = mapper.selectPurchaseList(dto);
		egovframework.konet.user.model.PurchaseDTO head = null;
		for (egovframework.konet.user.model.PurchaseDTO r : l) {
			if (r.getPurchSeq()!=null && r.getPurchSeq().equals(dto.getPurchSeq())) { head = r; break; }
		}
		if (head == null) return null;
		head.setItems(mapper.selectPurchaseDtl(dto));
		return head;
	}

	@Override public int savePurchase(egovframework.konet.user.model.PurchaseDTO dto) throws Exception {
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
		java.util.List<egovframework.konet.user.model.PurchaseDtlDTO> items = dto.getItems();
		if (items == null) return 0;
		java.util.Map<String,Object> fn = compFunc();      // 회사 설정 「기능」 (2026-09-11) — 입고 매입단가 갱신 규칙
		String refNo = ym8(dto.getPurchDt()) + "-" + (dto.getPurchNo()==null?"":dto.getPurchNo());
		int rowNo = 0;
		for (egovframework.konet.user.model.PurchaseDtlDTO d : items) {
			if (d.getProdCd()==null || d.getProdCd().trim().isEmpty()) continue;   // 빈 줄 건너뜀
			rowNo++;
			d.setPurchSeq(dto.getPurchSeq());
			d.setRowNo(rowNo);
			d.setRegUser(dto.getRegUser()); d.setRegIp(dto.getRegIp());
			if (d.getTrxGb()==null || d.getTrxGb().trim().isEmpty()) d.setTrxGb("매입");
			/* ★부호 정규화 (2026-09-05) — 규칙 : 명세의 수량·금액은 늘 양수, 반품은 TRX_GB 로만 표시.
			     화면에서 「음수 수량 + 반품」이 함께 들어오면 머리 합계(화면)·재고원장(아래 -q)·조회 SQL(CASE 반품 → −)이
			     각자 한 번씩 더 뒤집어, 반품인데 매입액이 더해지고 재고가 늘었다(2026-07-29/0005 실사고). 여기서 한 번 더 막는다. */
			boolean negQ = d.getQty()!=null && d.getQty() < 0;
			if (negQ && !isRtnS(d.getTrxGb())) d.setTrxGb("반품");
			if (negQ || isRtnS(d.getTrxGb())) {
				d.setBoxQty(absD(d.getBoxQty())); d.setEaQty(absD(d.getEaQty())); d.setQty(absD(d.getQty()));
				d.setAmt(absD(d.getAmt())); d.setSupplyAmt(absD(d.getSupplyAmt())); d.setVatAmt(absD(d.getVatAmt())); d.setTotAmt(absD(d.getTotAmt()));
			}

			// ① 파생 재고원장 — 반품이면 R(+), 매입이면 I(+). 원장 QTY 는 int 라 반올림한다
			//    ★매입 「불량반품」(2026-09-11 회사 설정)은 반품과 같다 — 불량품을 거래처로 되돌려 보내므로 재고에서 빠진다
			egovframework.konet.user.model.StockLedgerDTO led = new egovframework.konet.user.model.StockLedgerDTO();
			led.setProdSeq(d.getProdSeq()); led.setProdCd(d.getProdCd());
			led.setTrxDt(dto.getPurchDt());
			led.setIoGb(isRtnS(d.getTrxGb()) ? "R" : "I");
			double q = d.getQty()==null ? 0d : d.getQty();
			led.setQty((int) Math.round(isRtnS(d.getTrxGb()) ? -q : q));
			led.setUnitPrice(d.getUnitPrice());
			led.setAmt(d.getAmt());
			led.setVendorCd(dto.getVendorCd());
			led.setWhCd(dto.getWhCd());            // 전표 창고(비면 기본창고) — 2026-09-16 P3
			led.setRefGb("PURCH"); led.setRefNo(refNo);
			led.setRemark(d.getRemark());
			led.setRegUser(dto.getRegUser()); led.setRegIp(dto.getRegIp());
			mapper.insertStockLedger(led);
			mapper.recalcStockMst(led);

			mapper.insertPurchaseDtl(d);

			// ② 매입단가 이력 — 판매단가가 정산엑셀에서 쌓이는 것과 같은 방식(적용일자 = 매입일자)
			if (d.getUnitPrice()!=null && d.getUnitPrice() > 0 && !isRtnS(d.getTrxGb())) {
				egovframework.konet.user.model.ProdInpriceDTO ip = new egovframework.konet.user.model.ProdInpriceDTO();
				ip.setProdSeq(d.getProdSeq()); ip.setProdCd(d.getProdCd());
				ip.setVendorCd(dto.getVendorCd()); ip.setVendorNm(dto.getVendorNm());
				ip.setApplyDt(dto.getPurchDt()); ip.setInPrice(d.getUnitPrice());
				ip.setRemark("매입등록 " + refNo);
				ip.setRegUser(dto.getRegUser()); ip.setRegIp(dto.getRegIp());
				try {
					mapper.insertInprice(ip);                    // 이력은 설정과 무관하게 늘 남긴다
					/* 회사 설정 「입고」(2026-09-11) — 매입단가 자동 갱신(기본 예 = 종전) · 평균 매입단가 사용(기본 아니오) */
					if ("Y".equals(funcStr(fn, "inPriceAuto", "Y"))) {
						if ("Y".equals(funcStr(fn, "inPriceAvg", "N"))) {
							Double avg = mapper.selectAvgInPrice(ip);   // 방금 넣은 입고(원장)까지 포함된 평균
							if (avg != null && avg > 0) ip.setInPrice(Math.round(avg * 100d) / 100d);
						}
						mapper.syncProdInPrice(ip);
					}
				}
				catch (Exception ignore) { LOGGER.warn("매입단가 이력 적재 건너뜀 : " + d.getProdCd() + " / " + ignore.getMessage()); }
			}
		}
		return rowNo;
	}

	@Override public int deletePurchase(egovframework.konet.user.model.PurchaseDTO dto) throws Exception {
		mapper.deletePurchaseLedger(dto);
		mapper.deletePurchaseDtlAll(dto);
		return mapper.deletePurchaseMst(dto);
	}

	/** 'yyyy-mm-dd' | 'yyyymmdd' → 'yyyymmdd' */
	private String ym8(String s) { return s==null ? "" : s.replace("-", "").trim(); }
	/** 반품 줄인가 — 「불량반품」(2026-09-11 회사 설정 「불량 반품 사용」)도 금액 부호는 반품과 같다 */
	private static boolean isRtnS(String g) { return "반품".equals(g) || "불량반품".equals(g); }
	/** 회사 설정 「기능」 한 덩어리 (기준정보관리 ▸ 회사 정보 수정, 2026-09-11) — TBL_COMP_SET.SET_JSON 의 func.
	 *  ★못 읽으면 빈 맵 = 종전 동작(기본값은 화면 comp-set.js 의 DEF 와 같게 호출부에서 준다). */
	@SuppressWarnings("unchecked")
	private java.util.Map<String,Object> compFunc() {
		try {
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("compCd", egovframework.konet.cmmn.CompCdContext.get());
			String js = mapper.selectCompSetJson(p);
			if (js == null || js.trim().isEmpty()) return new java.util.HashMap<String,Object>();
			java.util.Map<String,Object> all = new com.fasterxml.jackson.databind.ObjectMapper().readValue(js, java.util.Map.class);
			Object f = all.get("func");
			return f instanceof java.util.Map ? (java.util.Map<String,Object>) f : new java.util.HashMap<String,Object>();
		} catch (Exception e) {
			LOGGER.warn("회사 설정 읽기 실패 — 종전 동작으로 : " + e.getMessage());
			return new java.util.HashMap<String,Object>();
		}
	}
	private static String funcStr(java.util.Map<String,Object> f, String k, String def) {
		Object v = f.get(k); return (v == null || String.valueOf(v).trim().isEmpty()) ? def : String.valueOf(v);
	}

	/** 판매 저장 전 «회사 설정» 관문 (2026-09-11 회사 정보 수정 「기능 ▸ 매출」) — 막을 이유가 있으면 그 글을, 없으면 null.
	 *  · 재고 부족 제한 : 품목마다 (판매 − 반품) 수량이 판매 가능 재고(원장 누계 + 이 전표가 이미 잡아 둔 출고)를 넘으면 막는다.
	 *    불량반품은 재고로 안 돌아가므로 빼지 않는다. 늘리지 않은 품목(고친 뒤 수량이 줄었거나 같은)은 막지 않는다.
	 *  · 여신 초과 제한 : 거래후잔고(원장 잔고 − 이 전표가 이미 반영한 몫 + 이번 전표)가 거래처 여신한도를 넘으면 막는다.
	 *    잔고를 줄이는 저장(금액을 낮춤)은 막지 않는다. 한도가 비었거나 0 이면 한도 없음. */
	@Override public String salesLimitMsg(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception {
		java.util.Map<String,Object> f = compFunc();
		boolean stockOn  = "Y".equals(funcStr(f, "stockLimit", "N"));
		boolean creditOn = "Y".equals(funcStr(f, "creditLimit", "N"));
		if (!stockOn && !creditOn) return null;
		egovframework.konet.user.model.SalesTrxDTO old = null;
		if (dto.getSaleSeq() != null && dto.getSaleSeq() > 0) {
			egovframework.konet.user.model.SalesTrxDTO q = new egovframework.konet.user.model.SalesTrxDTO();
			q.setSaleSeq(dto.getSaleSeq());
			java.util.List<egovframework.konet.user.model.SalesTrxDTO> l = mapper.selectSalesTrxList(q);
			for (egovframework.konet.user.model.SalesTrxDTO r : l) if (dto.getSaleSeq().equals(r.getSaleSeq())) { old = r; break; }
		}
		if (stockOn && dto.getItems() != null) {
			String oldRef = old == null ? "" : ym8(old.getSaleDt()) + "-" + (old.getSaleNo()==null?"":old.getSaleNo());
			java.util.Map<String,Double> need = new java.util.LinkedHashMap<String,Double>();
			java.util.Map<String,String> nm = new java.util.HashMap<String,String>();
			for (egovframework.konet.user.model.SalesTrxDtlDTO d : dto.getItems()) {
				if (d.getProdCd()==null || d.getProdCd().trim().isEmpty()) continue;
				double q = Math.abs(d.getQty()==null ? 0d : d.getQty());
				String g = d.getTrxGb();
				double sgn = "반품".equals(g) ? -1 : ("불량반품".equals(g) ? 0 : 1);
				if (d.getQty()!=null && d.getQty() < 0 && !"불량반품".equals(g)) sgn = -1;   // 음수 수량 = 반품(saveSalesTrx 와 같은 해석)
				String cd = d.getProdCd().trim();
				need.put(cd, (need.containsKey(cd) ? need.get(cd) : 0d) + sgn * q);
				if (!nm.containsKey(cd)) nm.put(cd, d.getProdNm()==null ? "" : d.getProdNm());
			}
			StringBuilder sb = new StringBuilder(); int cnt = 0;
			for (java.util.Map.Entry<String,Double> e : need.entrySet()) {
				if (e.getValue() <= 0) continue;
				java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
				p.put("prodCd", e.getKey()); p.put("refNo", oldRef);
				p.put("whCd", dto.getWhCd());          // 재고 제한은 전표 창고의 재고로(비면 전 창고) — 2026-09-16 P3
				java.util.Map<String,Object> r = mapper.selectStockAvailForSale(p);
				double cur  = r == null || r.get("cur")  == null ? 0d : ((Number) r.get("cur")).doubleValue();
				double mine = r == null || r.get("mine") == null ? 0d : ((Number) r.get("mine")).doubleValue();
				double avail = cur + mine;
				if (e.getValue() > avail + 0.0001 && e.getValue() > mine + 0.0001) {
					/* ★글만 돌려준다(HTML 없이) — 화면이 이 글을 escape 해서 찍는다 */
					if (cnt < 8) sb.append(" · ").append(e.getKey()).append(' ').append(nm.get(e.getKey()))
					              .append(" (판매 ").append(fmtN(e.getValue())).append(" / 재고 ").append(fmtN(avail)).append(')');
					cnt++;
				}
			}
			if (cnt > 0) return "재고가 모자라 저장하지 않았습니다 [회사 설정 「재고 부족 제한」]" + sb
			                  + (cnt > 8 ? " … 외 " + (cnt - 8) + "품목" : "")
			                  + " — 수량을 줄이거나 기준정보관리 ▸ 회사 정보 수정 ▸ 기능에서 제한을 끌 수 있습니다.";
		}
		if (creditOn) {
			egovframework.konet.user.model.VendorDTO vq = new egovframework.konet.user.model.VendorDTO();
			vq.setVendorCd(dto.getCustCd());
			java.util.List<egovframework.konet.user.model.VendorDTO> vl = mapper.selectVendorMst(vq);
			double limit = 0d;
			if (vl != null && !vl.isEmpty() && vl.get(0).getCreditLimit() != null && !vl.get(0).getCreditLimit().trim().isEmpty())
				try { limit = Double.parseDouble(vl.get(0).getCreditLimit().trim()); } catch (NumberFormatException ignore) {}
			if (limit > 0) {
				egovframework.konet.user.model.SettleTrxDTO sq = new egovframework.konet.user.model.SettleTrxDTO();
				sq.setCustCd(dto.getCustCd());
				double bal = 0d;
				for (java.util.Map<String,Object> r : mapper.selectCustLedger(sq)) {
					bal += numOf(r.get("saleAmt")) - numOf(r.get("dcAmt")) - numOf(r.get("rcvAmt")) - numOf(r.get("discAmt"));
				}
				double oldNet = old == null ? 0d : dbl(old.getTotAmt()) - dbl(old.getPayAmt()) - dbl(old.getDcAmt());
				double newNet = dbl(dto.getTotAmt()) - dbl(dto.getPayAmt()) - dbl(dto.getDcAmt());
				double after = bal - oldNet + newNet;
				if (after > limit + 0.5 && newNet > oldNet + 0.5)
					return "여신한도를 넘어 저장하지 않았습니다 [회사 설정 「여신 초과 제한」]"
					     + " · 여신한도 " + fmtN(limit) + " / 거래후잔고 " + fmtN(after) + " (초과 " + fmtN(after - limit) + ")"
					     + " — 수금을 함께 넣거나, 거래처의 여신한도를 올리거나, 회사 정보 수정 ▸ 기능에서 제한을 끌 수 있습니다.";
			}
		}
		return null;
	}
	private static double numOf(Object o) {
		if (o == null) return 0d;
		if (o instanceof Number) return ((Number) o).doubleValue();
		try { return Double.parseDouble(String.valueOf(o).replace(",", "")); } catch (NumberFormatException e) { return 0d; }
	}
	private static double dbl(Object o) { return numOf(o); }
	private static String fmtN(double v) {
		return (Math.abs(v - Math.rint(v)) < 0.0005) ? String.format("%,d", (long) Math.rint(v)) : String.format("%,.3f", v);
	}
	/** null 은 그대로, 값은 절대값 — 전표 명세 부호 정규화용 (2026-09-05) */
	private static Double absD(Double v) { return v==null ? null : Math.abs(v); }
	/* ===== 수금/지급 등록 — 2026-07-25 ===== */
	@Override public java.util.List<egovframework.konet.user.model.SettleTrxDTO> selectSettleList(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectSettleList(dto); }
	@Override public String selectSettleNextNo(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectSettleNextNo(dto); }
	@Override public int insertSettleTrx(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception {
		if (dto.getTrxNo()==null || dto.getTrxNo().trim().isEmpty()) dto.setTrxNo(mapper.selectSettleNextNo(dto));
		return mapper.insertSettleTrx(dto);
	}
	@Override public int updateSettleTrx(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.updateSettleTrx(dto); }
	@Override public int deleteSettleTrx(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.deleteSettleTrx(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectCustLedger(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectCustLedger(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectCustBalance(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectCustBalance(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectCustDayDetail(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectCustDayDetail(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectDayBook(egovframework.konet.user.model.SettleTrxDTO dto) throws Exception { return mapper.selectDayBook(dto); }

	/* ===== 판매등록 — 2026-07-25. savePurchase 와 대칭 =====
	   매입은 재고가 들어오고(I), 판매는 나간다(O). 그 한 가지가 다르다.
	   매입에 있던 '매입단가 이력 적재'는 여기 없다 — 판매단가 이력은 상품관리의
	   판매가 탭(TBL_PROD_SALEPRICE_HST)이 따로 담당하고, 그건 정산서 밖 판매도
	   손으로 등록할 수 있게 열어둔 칸이라 전표가 덮어쓰면 안 된다. */
	@Override public java.util.List<egovframework.konet.user.model.SalesTrxDTO> selectSalesTrxList(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception { return mapper.selectSalesTrxList(dto); }
	@Override public String selectSalesTrxNextNo(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception { return mapper.selectSalesTrxNextNo(dto); }
	@Override public egovframework.konet.user.model.SalesTrxDtlDTO selectCustLastPrice(egovframework.konet.user.model.SalesTrxDtlDTO dto) throws Exception { return mapper.selectCustLastPrice(dto); }
	@Override public java.util.List<egovframework.konet.user.model.SalesTrxDtlDTO> selectSalesPriceHist(egovframework.konet.user.model.SalesTrxDtlDTO dto) throws Exception { return mapper.selectSalesPriceHist(dto); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSalesTrxHist(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception { return mapper.selectSalesTrxHist(dto); }

	/* ===== 납품분 / 납품분 제외 — 2026-07-31 ===== */
	@Override public java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectSalesDlvList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception { return mapper.selectSalesDlvList(dto); }
	@Override public java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectPurchDlvList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception { return mapper.selectPurchDlvList(dto); }
	@Override public java.util.List<egovframework.konet.user.model.SalesDlvDTO> selectSalesDlvExclList(egovframework.konet.user.model.SalesDlvDTO dto) throws Exception { return mapper.selectSalesDlvExclList(dto); }
	/** 제외 켜기/끄기 — (거래처+상품) 한 줄을 뒤집는다. 없으면 새로 만든다(켤 때만).
	 *  UNIQUE(COMP_CD,CUST_CD,PROD_CD) 라 같은 품목을 두 번 빼도 줄이 늘지 않는다. */
	@Override public int saveSalesDlvExcl(egovframework.konet.user.model.SalesDlvDTO dto, java.util.List<String> prodCds) throws Exception {
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

	@Override public egovframework.konet.user.model.SalesTrxDTO selectSalesTrxOne(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception {
		java.util.List<egovframework.konet.user.model.SalesTrxDTO> l = mapper.selectSalesTrxList(dto);
		egovframework.konet.user.model.SalesTrxDTO head = null;
		for (egovframework.konet.user.model.SalesTrxDTO r : l) {
			if (r.getSaleSeq()!=null && r.getSaleSeq().equals(dto.getSaleSeq())) { head = r; break; }
		}
		if (head == null) return null;
		head.setItems(mapper.selectSalesTrxDtl(dto));
		return head;
	}

	/* 거래명세서 공유 (2026-09-09) — 카톡·이메일로 보낼 공개 주소의 토큰.
	   ★토큰은 <처음 보낼 때> 발급한다(저장할 때가 아니다) — 예전에 쌓인 전표도 그대로 보낼 수 있어야 한다.
	   ★UPDATE 가 `ISNULL(SHARE_TOKEN, 새토큰)` 이라 이미 발급된 전표는 <옛 토큰이 그대로>다.
	     그래서 새로 만든 후보 토큰을 그냥 돌려주면 안 되고, 쓴 뒤 다시 읽어 확인한다. */
	@Override public String shareSalesTrx(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception {
		dto.setShareToken(java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 24));
		if (mapper.updateSalesTrxShare(dto) == 0) return null;          // 없는 전표거나 다른 회사
		/* ★다시 읽기 전에 후보 토큰을 <반드시 비운다> — 안 비우면 selectSalesTrxList 의 shareToken 필터가
		     그 후보 토큰으로 걸린다. 이미 한 번 보낸 전표는 옛 토큰이 그대로 남아 있으므로 <한 건도 안 잡혀>
		     「전표를 찾을 수 없습니다」가 뜬다 = 두 번째 보내기가 늘 실패한다. 찾는 열쇠는 saleSeq 다. */
		dto.setShareToken(null);
		java.util.List<egovframework.konet.user.model.SalesTrxDTO> l = mapper.selectSalesTrxList(dto);
		for (egovframework.konet.user.model.SalesTrxDTO r : l) {
			if (r.getSaleSeq()!=null && r.getSaleSeq().equals(dto.getSaleSeq())) return r.getShareToken();
		}
		return null;
	}
	/* 공개 링크 — 토큰 하나로 찾는다. 로그인이 없어 compCd 가 빈 값이므로 <토큰이 곧 열쇠>다.
	   ★토큰이 비면 절대 조회하지 않는다 — 빈 토큰은 SQL 의 fail-open 을 타 전표가 통째로 나온다. */
	@Override public egovframework.konet.user.model.SalesTrxDTO selectSalesTrxByToken(String token) throws Exception {
		if (token == null || token.trim().isEmpty()) return null;
		egovframework.konet.user.model.SalesTrxDTO q = new egovframework.konet.user.model.SalesTrxDTO();
		q.setShareToken(token.trim());
		java.util.List<egovframework.konet.user.model.SalesTrxDTO> l = mapper.selectSalesTrxList(q);
		if (l == null || l.isEmpty()) return null;
		egovframework.konet.user.model.SalesTrxDTO head = l.get(0);
		egovframework.konet.user.model.SalesTrxDTO d = new egovframework.konet.user.model.SalesTrxDTO();
		d.setSaleSeq(head.getSaleSeq()); d.setCompCd(head.getCompCd());
		head.setItems(mapper.selectSalesTrxDtl(d));
		return head;
	}

	@Override public int saveSalesTrx(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception {
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
		java.util.List<egovframework.konet.user.model.SalesTrxDtlDTO> items = dto.getItems();
		if (items == null) return 0;
		String refNo = ym8(dto.getSaleDt()) + "-" + (dto.getSaleNo()==null?"":dto.getSaleNo());
		int rowNo = 0;
		for (egovframework.konet.user.model.SalesTrxDtlDTO d : items) {
			if (d.getProdCd()==null || d.getProdCd().trim().isEmpty()) continue;   // 빈 줄 건너뜀
			rowNo++;
			d.setSaleSeq(dto.getSaleSeq());
			d.setRowNo(rowNo);
			d.setRegUser(dto.getRegUser()); d.setRegIp(dto.getRegIp());
			if (d.getTrxGb()==null || d.getTrxGb().trim().isEmpty()) d.setTrxGb("판매");
			/* ★부호 정규화 (2026-09-05) — 매입등록과 같은 규칙 : 수량·금액은 양수, 반품은 TRX_GB 로만 (조회 SQL 이 CASE 반품 → − 를 붙인다) */
			boolean negQ = d.getQty()!=null && d.getQty() < 0;
			if (negQ && !isRtnS(d.getTrxGb())) d.setTrxGb("반품");
			if (negQ || isRtnS(d.getTrxGb())) {
				d.setBoxQty(absD(d.getBoxQty())); d.setEaQty(absD(d.getEaQty())); d.setQty(absD(d.getQty()));
				d.setAmt(absD(d.getAmt())); d.setSupplyAmt(absD(d.getSupplyAmt())); d.setVatAmt(absD(d.getVatAmt())); d.setTotAmt(absD(d.getTotAmt()));
			}
			/* ★「불량반품」(2026-09-11 회사 설정 「불량 반품 사용」) — 금액은 반품처럼 빠지지만(조회 SQL 이 반품과 같이 − 를 붙인다)
			     <재고로는 돌아가지 않는다>(팔 수 없는 물건). 그래서 재고원장을 만들지 않는다. */
			if ("불량반품".equals(d.getTrxGb())) { mapper.insertSalesTrxDtl(d); continue; }

			// 파생 재고원장 — 판매는 출고 'O', 판매반품(고객이 되돌려줌)은 'R'.
			// ★ 부호 주의 : 집계(recalcStockMst·재고현황)가
			//     IO_GB IN ('I','R') → +QTY,  IO_GB='O' → -QTY
			//   로 뒤집으므로 QTY 는 둘 다 양수로 넣는다. 여기서 음수를 넣으면
			//   판매했는데 재고가 늘어난다. (매입의 '반품'은 우리가 되돌려보내는 것이라
			//    'R'에 음수를 넣는데, 판매반품은 방향이 반대라 양수다.)
			// 원장 QTY 는 int 라 반올림한다(매입과 같다).
			egovframework.konet.user.model.StockLedgerDTO led = new egovframework.konet.user.model.StockLedgerDTO();
			led.setProdSeq(d.getProdSeq()); led.setProdCd(d.getProdCd());
			led.setTrxDt(dto.getSaleDt());
			boolean isReturn = "반품".equals(d.getTrxGb());
			led.setIoGb(isReturn ? "R" : "O");
			double q = d.getQty()==null ? 0d : d.getQty();
			led.setQty((int) Math.round(Math.abs(q)));
			led.setUnitPrice(d.getUnitPrice());
			led.setAmt(d.getAmt());
			led.setVendorCd(dto.getCustCd());
			led.setWhCd(dto.getWhCd());            // 전표 창고(비면 기본창고) — 2026-09-16 P3
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
			if (d.getUnitPrice()!=null && d.getUnitPrice() > 0 && !isRtnS(d.getTrxGb())) {
				egovframework.konet.user.model.ProdSalepriceDTO sp = new egovframework.konet.user.model.ProdSalepriceDTO();
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

	@Override public int deleteSalesTrx(egovframework.konet.user.model.SalesTrxDTO dto) throws Exception {
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
	public java.util.List<egovframework.konet.user.model.StockMstDTO>
	    selectStockAdjList(egovframework.konet.user.model.StockMstDTO dto) throws Exception {
		return mapper.selectStockAdjList(dto);
	}

	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public int saveStockAdjBatch(egovframework.konet.user.model.StockAdjHisDTO head,
	                             java.util.List<egovframework.konet.user.model.StockAdjHisDTO> rows) throws Exception {

		if (rows == null || rows.isEmpty()) return 0;

		String baseDt = head.getBaseDt() == null ? "" : head.getBaseDt().replace("-", "");
		guardClosed(baseDt);                       // 마감 확정월 잠금 — 다른 조정과 같은 규칙

		// 저장 묶음 번호 : 되돌리기가 이 번호를 따라간다
		String batchNo = "ADJ" + new java.text.SimpleDateFormat("yyyyMMddHHmmss")
		                              .format(new java.util.Date());
		int n = 0;

		for (egovframework.konet.user.model.StockAdjHisDTO r : rows) {
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
			egovframework.konet.user.model.StockLedgerDTO led =
			        new egovframework.konet.user.model.StockLedgerDTO();
			led.setCompCd(head.getCompCd());
			led.setProdSeq(r.getProdSeq());
			led.setProdCd(r.getProdCd());
			led.setTrxDt(baseDt);
			led.setIoGb("A");
			led.setQty(diff);
			led.setWhCd(head.getWhCd());           // 조정 창고(비면 기본창고) — 2026-09-16 P3
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

	/* ══ 서브코드 재고 정리 (2026-09-13 「주코드에 매칭된 서브코드 제품 모두 재고 0으로 조정」) ══════════════
	   화면 prod/subStockFix.jsp — ①재고가 남은 서브코드 ②서브코드로 잡힌 매입 줄 ③남은 재고 0 으로 조정.
	   ★매입 전표는 여기서 고치지 않는다 — 화면이 매입등록으로 보내 그 전표에서 주코드로 바꾸게 한다(사용자 결정 「중복업무라서」).
	   ★조정은 saveStockAdjBatch 를 그대로 쓴다 — 조정행(A)·이력(TBL_STOCK_ADJ_HIS)·묶음번호가 재고 일괄조정과 같아
	     그 화면 [조정 이력]에서 보이고 묶음째 되돌릴 수 있다. (서브코드 조정을 막는 관문은 컨트롤러 stockAdjSave 에만 있다 — 여기는 그 예외 길)
	   ★조정 전 수량은 화면 값을 믿지 않고 여기서 원장으로 다시 센다. */
	@Override
	public java.util.Map<String,Object> selectSubStock(java.util.Map<String,Object> p) throws Exception {
		java.util.Map<String,Object> r = new java.util.HashMap<String,Object>();
		r.put("subs",  mapper.selectSubStockList(p));
		r.put("purch", mapper.selectSubPurchList(p));
		return r;
	}

	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public java.util.Map<String,Object> saveSubStockZero(java.util.List<String> subCds, boolean merge,
	                                                    String compCd, String user, String ip) throws Exception {
		java.util.List<egovframework.konet.user.model.StockAdjHisDTO> rows =
		        new java.util.ArrayList<egovframework.konet.user.model.StockAdjHisDTO>();
		/* 주코드마다 더할 수량 — 서브코드 여럿이 한 주코드에 걸릴 수 있다. {주코드 PROD_SEQ, 주코드 현재고, 더할 수량} */
		java.util.LinkedHashMap<String, long[]> mainAdd = new java.util.LinkedHashMap<String, long[]>();
		int subs = 0;
		for (String raw : subCds) {
			String cd = raw == null ? "" : raw.trim();
			if (cd.isEmpty()) continue;
			java.util.Map<String,Object> q = new java.util.HashMap<String,Object>();
			q.put("compCd", compCd); q.put("subCd", cd);
			java.util.List<java.util.Map<String,Object>> l = mapper.selectSubStockList(q);
			if (l == null || l.isEmpty()) continue;                    // 그새 0 이 됐다 — 건너뜀
			java.util.Map<String,Object> s = l.get(0);
			if (subNum(s.get("mainCnt")) > 1)
				throw new Exception("서브코드 " + cd + " 가 주코드 여러 개에 매칭돼 있어 합칠 곳을 정할 수 없습니다 — 상품코드등록에서 먼저 정리하세요.");
			if (subNum(s.get("alsoMain")) > 0)
				throw new Exception("코드 " + cd + " 는 다른 매칭코드의 주코드이기도 합니다 — 서브코드가 아닐 수 있어 조정하지 않습니다(상품코드등록에서 확인).");
			long subSeq = subNum(s.get("subSeq"));
			if (subSeq <= 0) throw new Exception("서브코드 " + cd + " 가 상품마스터에 없습니다.");
			int cur = (int) subNum(s.get("subCur"));
			if (cur == 0) continue;
			rows.add(subAdjRow(subSeq, cd, cur, 0));
			subs++;
			if (merge) {
				String mc = String.valueOf(s.get("mainCd"));
				long[] a = mainAdd.get(mc);
				if (a == null) { a = new long[]{ subNum(s.get("mainSeq")), subNum(s.get("mainCur")), 0L }; mainAdd.put(mc, a); }
				a[2] += cur;
			}
		}
		for (java.util.Map.Entry<String, long[]> e : mainAdd.entrySet()) {
			long[] a = e.getValue();
			if (a[0] <= 0) throw new Exception("주코드 " + e.getKey() + " 가 상품마스터에 없습니다.");
			rows.add(subAdjRow(a[0], e.getKey(), (int) a[1], (int) (a[1] + a[2])));
		}
		egovframework.konet.user.model.StockAdjHisDTO head = new egovframework.konet.user.model.StockAdjHisDTO();
		head.setCompCd(compCd);
		head.setBaseDt(new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date()));
		head.setRemark(merge ? "서브코드 정리 — 주코드로 합침" : "서브코드 정리 — 0으로");
		head.setRegUser(user); head.setRegIp(ip);
		int n = rows.isEmpty() ? 0 : saveStockAdjBatch(head, rows);
		java.util.Map<String,Object> res = new java.util.HashMap<String,Object>();
		res.put("cnt", n); res.put("subs", subs); res.put("mains", mainAdd.size()); res.put("batchNo", head.getBatchNo());
		return res;
	}
	/** 조회 결과(HashMap)의 숫자 — SQL Server 는 칸에 따라 Integer·Long·BigDecimal 로 준다 */
	private static long subNum(Object o) {
		if (o == null) return 0L;
		if (o instanceof Number) return Math.round(((Number) o).doubleValue());
		try { return Math.round(Double.parseDouble(String.valueOf(o))); } catch (Exception e) { return 0L; }
	}
	/** 조정 한 줄 — EA 로만(입수 1) : 조정 전 bef → 조정 후 aft */
	private static egovframework.konet.user.model.StockAdjHisDTO subAdjRow(long seq, String cd, int bef, int aft) {
		egovframework.konet.user.model.StockAdjHisDTO r = new egovframework.konet.user.model.StockAdjHisDTO();
		r.setProdSeq(Long.valueOf(seq)); r.setProdCd(cd); r.setPackQty(Integer.valueOf(1));
		r.setBefQty(Integer.valueOf(bef)); r.setBefBox(Integer.valueOf(bef)); r.setBefEa(Integer.valueOf(0));
		r.setAftBox(Integer.valueOf(aft)); r.setAftEa(Integer.valueOf(0));
		return r;
	}

	@Override
	public java.util.List<egovframework.konet.user.model.StockAdjHisDTO>
	    selectStockAdjHisList(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception {
		return mapper.selectStockAdjHisList(dto);
	}

	/** 묶음 되돌리기 — 원장행을 먼저 내리고(짝을 아직 아는 동안) 이력을 내린다. 순서를 바꾸면 짝을 잃는다. */
	@Override
	@org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
	public int cancelStockAdjBatch(egovframework.konet.user.model.StockAdjHisDTO dto) throws Exception {
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
	public int saveProdPackQty(java.util.List<egovframework.konet.user.model.StockMstDTO> rows) throws Exception {
		if (rows == null || rows.isEmpty()) return 0;
		int n = 0;
		for (egovframework.konet.user.model.StockMstDTO r : rows) {
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
		egovframework.konet.user.model.StockLedgerDTO d = new egovframework.konet.user.model.StockLedgerDTO();
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

		egovframework.konet.user.model.StockLedgerDTO led =
		        new egovframework.konet.user.model.StockLedgerDTO();
		led.setTrxDt(dt);
		led.setCompCd(compCd);
		led.setRegUser(regUser);
		led.setRegIp(regIp);

		/* ★같은 날짜의 발주현황표 파생행을 먼저 걷어낸다 — 그 날은 정산서가 출고의 주인이다. */
		egovframework.konet.user.model.StockLedgerDTO sh =
		        new egovframework.konet.user.model.StockLedgerDTO();
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
	/* ══════════ 발주서 관리 (2026-09-03) ══════════ */
	@Override public java.util.List<java.util.Map<String,Object>> selectPoList(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoList(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectPoRecentByProd(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoRecentByProd(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectPoRemainByProd(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoRemainByProd(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSafeStockShort(java.util.Map<String,Object> p) throws Exception { return mapper.selectSafeStockShort(p); }
	/* 회사 설정(SET_JSON func.*) 정수 하나 — parcelFeeDefOf 와 같은 정규식 방식(JSON 라이브러리 없이) */
	private int compSetInt(String compCd, String key, int def) {
		try {
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("compCd", (compCd == null || compCd.trim().isEmpty()) ? "W1234567" : compCd);
			String js = mapper.selectCompSetJson(p);
			if (js != null) {
				java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"" + key + "\"\\s*:\\s*\"?(\\d+)").matcher(js);
				if (m.find()) return Integer.parseInt(m.group(1));
			}
		} catch (Exception e) { /* 설정을 못 읽으면 기본값 */ }
		return def;
	}
	/* ===== 적정재고 자동 산출 (2026-09-17, 설계 docs/설계_적정재고_자동산출_2026-09-17.md) =====
	   적정 S = ceil( 일평균 d × (리드타임 L + 안전일수 A) ÷ 입수 ) × 입수,  d = 기간 W일 원장 출고 ÷ W.
	   · 출고 일수 < N(최소 출고일수) 이면 「간헐」 — 제안 없음.  · 상한 = W일 출고량.  · 조건이 비면 회사 설정(safeWindow·safeLeadDays·safeBufDays·safeMinDays).
	   · 가용 = max(현재고,0) + 입고예정 (음수 재고는 0 — 결정 ④). 여기서는 계산만, 적용은 saveSafeStockBulk(src='A'). */
	@Override public java.util.Map<String,Object> selectSafeStockSuggest(String compCd, Integer window, Integer lead, Integer buf, Integer minDays) throws Exception {
		int W = (window != null && window >= 7 && window <= 365) ? window : compSetInt(compCd, "safeWindow", 90);   // 기간 7~365 (2026-09-17 「10일로」 — 종전 30 이 최소라 되돌아갔다)
		int L = (lead != null && lead >= 0 && lead <= 90) ? lead : compSetInt(compCd, "safeLeadDays", 7);
		int A = (buf != null && buf >= 0 && buf <= 90) ? buf : compSetInt(compCd, "safeBufDays", 7);
		int N = (minDays != null && minDays >= 1 && minDays <= 90) ? minDays : compSetInt(compCd, "safeMinDays", 5);
		if (L + A > W) A = Math.max(0, W - L);                                   // 리드+안전이 기간을 넘는 설정은 막는다
		if (N > W) N = W;                                                        // 최소 출고일수는 기간을 넘을 수 없다(기간 10일에 5일이면 「10일 중 5일 이상 나간 품목」)
		java.text.SimpleDateFormat f = new java.text.SimpleDateFormat("yyyyMMdd");
		java.util.Calendar c = java.util.Calendar.getInstance();
		String toDt = f.format(c.getTime()); c.add(java.util.Calendar.DATE, -(W - 1)); String frDt = f.format(c.getTime());
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
		p.put("compCd", compCd); p.put("frDt", frDt); p.put("toDt", toDt);
		java.util.List<java.util.Map<String,Object>> rows = mapper.selectSafeStockSuggest(p);
		int cand = 0, chg = 0, newShort = 0, protectM = 0, sporadic = 0, neg = 0;
		for (java.util.Map<String,Object> r : rows) {
			double out = scNum(r.get("outQty")); int days = (int) Math.round(scNum(r.get("outDays")));
			int pack = Math.max(1, (int) Math.round(scNum(r.get("packQty"))));
			long cur = Math.round(scNum(r.get("curQty"))), rem = Math.round(scNum(r.get("poRemainQty")));
			long avail = Math.max(cur, 0) + rem;
			long safeNow = Math.round(scNum(r.get("safeStock"))); String src = scStr(r.get("safeStockSrc"));
			double d = out / W;
			Long sug = null; String flag = "";
			if (out <= 0) flag = "출고 0";
			else if (days < N) { flag = "간헐"; sporadic++; }
			else {
				double raw = d * (L + A); if (raw > out) raw = out;                  // 상한 = 기간 출고량
				long s = (long) Math.ceil(raw / pack) * pack; if (s < pack) s = pack;
				sug = Long.valueOf(s); cand++;
			}
			r.put("perDay", Double.valueOf(Math.round(d * 100) / 100.0));
			r.put("suggestQty", sug); r.put("flag", flag);
			r.put("diffQty", sug == null ? null : Long.valueOf(sug.longValue() - safeNow));
			r.put("availQty", Long.valueOf(avail));
			boolean sh = sug != null && avail < sug.longValue();
			r.put("afterShort", sh ? "Y" : "N");
			if (sug != null && sug.longValue() != safeNow) { chg++; if ("M".equals(src)) protectM++; }
			if (sh) newShort++;
			if (cur < 0) neg++;
		}
		java.util.Map<String,Object> params = new java.util.HashMap<String,Object>();
		params.put("window", W); params.put("lead", L); params.put("buf", A); params.put("minDays", N); params.put("frDt", frDt); params.put("toDt", toDt);
		java.util.Map<String,Object> sum = new java.util.HashMap<String,Object>();
		sum.put("rows", rows.size()); sum.put("cand", cand); sum.put("chg", chg); sum.put("newShort", newShort); sum.put("protectM", protectM); sum.put("sporadic", sporadic); sum.put("neg", neg);
		java.util.Map<String,Object> res = new java.util.HashMap<String,Object>();
		res.put("data", rows); res.put("params", params); res.put("summary", sum);
		return res;
	}
	/* 적정재고 일괄 입력 (2026-09-16) — 줄마다 품목코드·적정재고. 없는 코드는 세어서 돌려준다(막지 않는다 — 사용자 원칙 「메시지 처리」).
	   ★한 줄이 실패해도 멈추지 않는다 : 코드 하나가 틀렸다고 나머지 수백 줄을 버리면 붙여넣기가 소용없다. */
	@Override public java.util.Map<String,Object> saveSafeStockBulk(java.util.List<java.util.Map<String,Object>> rows, String compCd, String regUser) throws Exception {
		int done = 0, miss = 0; java.util.List<String> missCds = new java.util.ArrayList<String>();
		if (rows != null) for (java.util.Map<String,Object> r : rows) {
			String cd = r.get("prodCd") == null ? "" : String.valueOf(r.get("prodCd")).trim();
			if (cd.isEmpty()) continue;
			int qty; try { qty = (int) Math.round(Double.parseDouble(String.valueOf(r.get("safeStock")).replace(",", "").trim())); }
			catch (Exception e) { miss++; if (missCds.size() < 20) missCds.add(cd + "(수량 아님)"); continue; }
			if (qty < 0) qty = 0;
			java.util.Map<String,Object> p = new java.util.HashMap<String,Object>();
			p.put("prodCd", cd); p.put("safeStock", Integer.valueOf(qty)); p.put("compCd", compCd); p.put("regUser", regUser);
			p.put("src", "A".equals(String.valueOf(r.get("src"))) ? "A" : "M");   // 출처(2026-09-17) — 자동 산출 적용은 A, 붙여넣기는 M
			int n = 0; try { n = mapper.updateSafeStockByCd(p); } catch (Exception e) { n = 0; }
			if (n > 0) done += n; else { miss++; if (missCds.size() < 20) missCds.add(cd); }
		}
		java.util.Map<String,Object> res = new java.util.HashMap<String,Object>();
		res.put("done", Integer.valueOf(done)); res.put("miss", Integer.valueOf(miss)); res.put("missCds", missCds);
		return res;
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectPoLinkedPurch(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoLinkedPurch(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectPoOpenLines(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoOpenLines(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectVendorPriceCmp(java.util.Map<String,Object> p) throws Exception { return mapper.selectVendorPriceCmp(p); }
	@Override public int updatePoLineClose(java.util.Map<String,Object> p) throws Exception { return mapper.updatePoLineClose(p); }
	@Override public String selectPoNextNo(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoNextNo(p); }
	@Override public java.util.Map<String,Object> selectPoMst(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoMst(p); }
	@Override public java.util.Map<String,Object> selectPoMstByToken(String token) throws Exception {
		java.util.Map<String,Object> p = new java.util.HashMap<String,Object>(); p.put("token", token); p.put("poSeq", 0);
		return mapper.selectPoMst(p);
	}
	@Override public java.util.List<java.util.Map<String,Object>> selectPoDtl(java.util.Map<String,Object> p) throws Exception { return mapper.selectPoDtl(p); }
	@Override public int updatePoShared(java.util.Map<String,Object> p) throws Exception { return mapper.updatePoShared(p); }
	@Override public int updatePoPurchSeq(java.util.Map<String,Object> p) throws Exception { return mapper.updatePoPurchSeq(p); }
	@Override public java.util.Map<String,Object> selectCompInfo(java.util.Map<String,Object> p) throws Exception { return mapper.selectCompInfo(p); }
	/* 회사 정보 수정 (2026-09-11) — compInfo.jsp. 회사코드는 컨트롤러가 세션에서 넣는다. */
	@Override public java.util.Map<String,Object> selectCompInfoFull(java.util.Map<String,Object> p) throws Exception { return mapper.selectCompInfoFull(p); }
	@Override public int updateCompInfoSelf(java.util.Map<String,Object> p) throws Exception { return mapper.updateCompInfoSelf(p); }
	@Override public String selectCompSetJson(java.util.Map<String,Object> p) throws Exception { return mapper.selectCompSetJson(p); }
	@Override public int mergeCompSetJson(java.util.Map<String,Object> p) throws Exception { return mapper.mergeCompSetJson(p); }
	@Override public int mergeCompStamp(java.util.Map<String,Object> p) throws Exception { return mapper.mergeCompStamp(p); }
	@Override public List<java.util.Map<String,Object>> selectCompBankList(java.util.Map<String,Object> p) throws Exception { return mapper.selectCompBankList(p); }
	@Override public int saveCompBank(java.util.Map<String,Object> p) throws Exception {
		Object seq = p.get("bankSeq");
		return (seq == null || String.valueOf(seq).trim().isEmpty()) ? mapper.insertCompBank(p) : mapper.updateCompBank(p);
	}
	@Override public int deleteCompBank(java.util.Map<String,Object> p) throws Exception { return mapper.deleteCompBank(p); }
	@Override public List<java.util.Map<String,Object>> selectCompCardList(java.util.Map<String,Object> p) throws Exception { return mapper.selectCompCardList(p); }
	@Override public int saveCompCard(java.util.Map<String,Object> p) throws Exception {
		Object seq = p.get("cardSeq");
		return (seq == null || String.valueOf(seq).trim().isEmpty()) ? mapper.insertCompCard(p) : mapper.updateCompCard(p);
	}
	@Override public int deleteCompCard(java.util.Map<String,Object> p) throws Exception { return mapper.deleteCompCard(p); }
	/* ══════════ 문서 전송이력 (2026-09-10) ══════════
	   ★이력 남기기가 실패해도 «보내기 자체»는 성공으로 둔다 — 부르는 쪽에서 예외를 삼킨다.
	     기록이 못 남았다고 이미 나간 카톡·메일을 되돌릴 수는 없다. */
	@Override public int insertSendHist(java.util.Map<String,Object> p) throws Exception { return mapper.insertSendHist(p); }
	@Override public java.util.List<java.util.Map<String,Object>> selectSendHistList(java.util.Map<String,Object> p) throws Exception { return mapper.selectSendHistList(p); }
	/* 읽음·열람 (2026-09-10) — 로그인 없는 공개 요청이 부른다. 열쇠(TRACK_KEY)가 맞는 줄의 횟수만 올린다 */
	@Override public int updateSendHistMailOpen(java.util.Map<String,Object> p) throws Exception { return mapper.updateSendHistMailOpen(p); }
	@Override public int updateSendHistView(java.util.Map<String,Object> p) throws Exception { return mapper.updateSendHistView(p); }
	@Override public int deletePo(java.util.Map<String,Object> p) throws Exception {
		int n = mapper.deletePoMst(p);
		if (n > 0) mapper.deletePoDtlAll(p);
		return n;
	}
	/** 발주서 저장 — 신규면 번호 채번(그 날 0001~) + 공유 토큰 발급, 수정이면 머리 갱신 + 줄 전부 지우고 다시 넣는다. */
	@SuppressWarnings("unchecked")
	@Override public long savePo(java.util.Map<String,Object> b, String user, String ip) throws Exception {
		java.util.Map<String,Object> m = new java.util.HashMap<String,Object>(b);
		m.put("regUser", user); m.put("regIp", ip);
		long seq = 0;
		try { Object s = b.get("poSeq"); if (s != null && String.valueOf(s).trim().length() > 0) seq = Long.parseLong(String.valueOf(s).trim()); } catch (Exception e) { seq = 0; }
		String no = b.get("poNo") == null ? "" : String.valueOf(b.get("poNo")).trim();
		m.put("shareToken", java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 24));   // 수정 때는 기존 토큰이 있으면 그대로(ISNULL)
		if (seq <= 0) {
			no = mapper.selectPoNextNo(m);   // ★화면이 보낸 번호는 믿지 않는다 — 두 번 저장하면 같은 번호가 두 장 생겼다(2026-09-03 실제)
			m.put("poNo", no);
			mapper.insertPoMst(m);
			Object k = m.get("poSeq");
			seq = (k == null) ? 0 : Long.parseLong(String.valueOf(k).split("[.]")[0]);
		} else {
			m.put("poSeq", seq);
			mapper.updatePoMst(m);
			mapper.deletePoDtlAll(m);
		}
		Object items = b.get("items");
		int row = 0;
		if (items instanceof java.util.List) for (Object o : (java.util.List<?>) items) {
			if (!(o instanceof java.util.Map)) continue;
			java.util.Map<String,Object> d = new java.util.HashMap<String,Object>((java.util.Map<String,Object>) o);
			if (d.get("prodCd") == null || String.valueOf(d.get("prodCd")).trim().isEmpty()) continue;
			d.put("poSeq", seq); d.put("rowNo", ++row); d.put("regUser", user); d.put("compCd", b.get("compCd"));
			/* 발주 연결 보존 (2026-09-16 P1-b) — 고쳐 저장하면 줄이 지워지고 다시 들어가 PO_DTL_SEQ 가 바뀐다.
			   화면이 줄마다 옛 poDtlSeq 를 실어 보내므로, 새 번호를 받아(useGeneratedKeys → newDtlSeq) 매입 명세의 연결을 옮긴다.
			   안 옮기면 부분 입고된 발주서를 한 번 고쳐 저장하는 순간 입고·잔량이 0 으로 보인다. */
			long oldDtl = 0;
			try { Object od = d.get("poDtlSeq"); if (od != null && String.valueOf(od).trim().length() > 0) oldDtl = Long.parseLong(String.valueOf(od).trim().split("[.]")[0]); } catch (Exception e) { oldDtl = 0; }
			d.remove("poDtlSeq"); d.remove("newDtlSeq");
			mapper.insertPoDtl(d);
			if (oldDtl > 0 && d.get("newDtlSeq") != null) {
				long newDtl = Long.parseLong(String.valueOf(d.get("newDtlSeq")).split("[.]")[0]);
				if (newDtl > 0 && newDtl != oldDtl) {
					java.util.Map<String,Object> rl = new java.util.HashMap<String,Object>();
					rl.put("oldSeq", oldDtl); rl.put("newSeq", newDtl); rl.put("poSeq", seq);
					mapper.relinkPurchaseDtlPo(rl);
				}
			}
		}
		return seq;
	}
}
