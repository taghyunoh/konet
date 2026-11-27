package egovframework.konet.tax.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.konet.tax.mapper.TaxBillMapper;

/**
 * 매출·매입 계산서 (2026-11-27 사용자 「홀세일처럼 매출계산서, 매입계산서 (전자세금계산서 연동)」 → 「화면부터 먼저」)
 *
 * · 이번 단계 = 생성(합계·건별·상품별) → 확정 → 내역·인쇄. 국세청 전송(전자 발행)은 중계업체 계약 뒤 —
 *   표에 NTS_NO·ASP_KEY·ISSUE_* 칸만 미리 있다. 상태 : W 작성 → C 확정 → I 발행.
 * · 원천을 접는 셈(합계·건별·상품별, ÷1.1 환산)은 화면(taxBillMake.jsp)이 한다 — 종합실적과 같은 방식.
 *   서버는 ① 원천 낱줄을 주고 ② 화면이 접은 계산서를 «검사해서» 넣는다 :
 *   품목 줄 합으로 머리 금액을 다시 셈 · 면세면 세액 0 · 99줄 상한 · 받는 쪽 정보는 거래처 마스터에서 복사(화면 값 안 믿음).
 * · createBills 는 한 묶음(트랜잭션 — context-transaction.xml taxBillTx). 한 장이라도 실패하면 전부 안 들어간다.
 */
@Service("TaxBillService")
public class TaxBillService {

	private static final Logger LOG = LoggerFactory.getLogger(TaxBillService.class);
	public static final int MAX_LINES = 99;
	public static final int MAX_BILLS = 500;

	@Resource(name = "TaxBillMapper")
	private TaxBillMapper mapper;

	/* ── 작은 도구 ── */
	public static String str(Object o) { return o == null ? "" : String.valueOf(o).trim(); }
	public static String d8(Object o) { String s = str(o).replace("-", ""); return s.matches("\\d{8}") ? s : ""; }
	public static long lng(Object o) {
		if (o == null) return 0L;
		try { return new BigDecimal(String.valueOf(o).trim()).setScale(0, BigDecimal.ROUND_HALF_UP).longValue(); } catch (Exception e) { return 0L; }
	}
	public static BigDecimal dec(Object o) {
		if (o == null || str(o).isEmpty()) return null;
		try { return new BigDecimal(String.valueOf(o).trim()); } catch (Exception e) { return null; }
	}
	private static String cut(String s, int n) { return s == null ? "" : (s.length() > n ? s.substring(0, n) : s); }
	private static boolean isMissingTable(Exception e) {
		String m = String.valueOf(e.getMessage()) + (e.getCause() == null ? "" : String.valueOf(e.getCause().getMessage()));
		return m.contains("TBL_TAXBILL") && (m.contains("Invalid object") || m.contains("개체 이름") || m.contains("유효하지 않"));
	}

	/** 생성 화면 재료 — 원천 낱줄 · 거래처 · 기간이 겹치는 기존 계산서 */
	public Map<String, Object> srcData(String compCd, String gb, String frDt, String toDt) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("frDt", frDt); p.put("toDt", toDt); p.put("billGb", gb);
		Map<String, Object> r = new HashMap<String, Object>();
		r.put("lines", "P".equals(gb) ? mapper.selectTaxSrcPurch(p) : mapper.selectTaxSrcSale(p));
		r.put("vendors", mapper.selectTaxVendors(p));
		try {
			r.put("existing", mapper.selectTaxExisting(p));
		} catch (Exception e) {
			if (!isMissingTable(e)) throw new RuntimeException(e);
			r.put("existing", new ArrayList<Object>());
			r.put("noTable", true);   // DDL 전 — 화면이 「표가 아직 없습니다」를 띄우고 [생성]을 막는다
		}
		r.put("ok", true);
		return r;
	}

	/**
	 * 계산서 넣기 — 화면이 접은 장들을 검사한 뒤 머리 + 품목 줄.
	 * body = { gb, makeGb, basisGb, frDt, toDt, writeDt, purposeGb, bills:[{ custCd, taxGb, srcKey, remark, lines:[{itemDt,itemCd,itemNm,spec,qty,price,supplyAmt,vatAmt,remark}] }] }
	 */
	@SuppressWarnings("unchecked")
	public Map<String, Object> createBills(String compCd, String userId, Map<String, Object> body) {
		String gb = str(body.get("gb")), makeGb = str(body.get("makeGb")), basisGb = str(body.get("basisGb"));
		String writeDt = d8(body.get("writeDt")), frDt = d8(body.get("frDt")), toDt = d8(body.get("toDt"));
		String purposeGb = str(body.get("purposeGb"));
		if (!"S".equals(gb) && !"P".equals(gb)) throw new IllegalArgumentException("매출/매입 구분이 없습니다.");
		if (!makeGb.matches("SUM|DOC|ITEM")) throw new IllegalArgumentException("생성 방식(합계·건별·상품별)이 없습니다.");
		if (!basisGb.matches("TRX|CASH")) basisGb = "TRX";
		if (writeDt.isEmpty()) throw new IllegalArgumentException("발행일자를 넣어 주세요.");
		if (!"영수".equals(purposeGb)) purposeGb = "청구";
		Object bo = body.get("bills");
		if (!(bo instanceof List) || ((List<Object>) bo).isEmpty()) throw new IllegalArgumentException("고른 거래처가 없습니다.");
		List<Object> bills = (List<Object>) bo;
		if (bills.size() > MAX_BILLS) throw new IllegalArgumentException("한 번에 " + MAX_BILLS + "장까지 만들 수 있습니다.");

		List<Object> seqs = new ArrayList<Object>();
		long sumTot = 0;
		for (Object b0 : bills) {
			Map<String, Object> b = (Map<String, Object>) b0;
			String custCd = str(b.get("custCd"));
			if (custCd.isEmpty()) throw new IllegalArgumentException("거래처 코드가 빈 계산서가 있습니다.");
			String taxGb = "면세".equals(str(b.get("taxGb"))) ? "면세" : "과세";
			List<Object> lines = b.get("lines") instanceof List ? (List<Object>) b.get("lines") : new ArrayList<Object>();
			if (lines.isEmpty()) throw new IllegalArgumentException("[" + custCd + "] 품목 줄이 없습니다.");
			if (lines.size() > MAX_LINES) throw new IllegalArgumentException("[" + custCd + "] 품목이 " + MAX_LINES + "줄을 넘습니다.");

			List<Map<String, Object>> ls = new ArrayList<Map<String, Object>>();
			long sup = 0, vat = 0; int no = 0;
			for (Object l0 : lines) {
				Map<String, Object> l = (Map<String, Object>) l0;
				long s = lng(l.get("supplyAmt")), v = "면세".equals(taxGb) ? 0L : lng(l.get("vatAmt"));
				Map<String, Object> x = new HashMap<String, Object>();
				x.put("lineNo", ++no);
				x.put("itemDt", d8(l.get("itemDt")).isEmpty() ? writeDt : d8(l.get("itemDt")));
				x.put("itemCd", cut(str(l.get("itemCd")), 40));
				x.put("itemNm", cut(str(l.get("itemNm")), 200));
				x.put("spec", cut(str(l.get("spec")), 100));
				x.put("qty", dec(l.get("qty")));
				x.put("price", dec(l.get("price")));
				x.put("supplyAmt", s); x.put("vatAmt", v);
				x.put("remark", cut(str(l.get("remark")), 200));
				ls.add(x);
				sup += s; vat += v;
			}
			if (sup + vat <= 0) throw new IllegalArgumentException("[" + custCd + "] 합계가 0 이하입니다(할인·반품만 있는 거래처는 이번 단계에서 만들지 않습니다).");

			Map<String, Object> h = new HashMap<String, Object>();
			h.put("compCd", compCd); h.put("billGb", gb); h.put("makeGb", makeGb); h.put("basisGb", basisGb);
			h.put("taxGb", taxGb); h.put("purposeGb", purposeGb); h.put("writeDt", writeDt);
			h.put("frDt", frDt.isEmpty() ? null : frDt); h.put("toDt", toDt.isEmpty() ? null : toDt);
			h.put("srcKey", cut(str(b.get("srcKey")), 200));
			h.put("custCd", custCd);
			h.put("supplyAmt", sup); h.put("vatAmt", vat); h.put("totAmt", sup + vat);
			h.put("remark", cut(str(b.get("remark")), 300));
			h.put("userId", userId);
			int n = mapper.insertTaxBillMst(h);
			if (n != 1 || h.get("billSeq") == null) throw new IllegalArgumentException("[" + custCd + "] 거래처 마스터에 없는 거래처입니다.");
			Map<String, Object> dp = new HashMap<String, Object>();
			dp.put("billSeq", h.get("billSeq")); dp.put("lines", ls);
			mapper.insertTaxBillDtl(dp);
			seqs.add(h.get("billSeq"));
			sumTot += sup + vat;
		}
		LOG.info("taxbill create comp=" + compCd + " gb=" + gb + " make=" + makeGb + " cnt=" + seqs.size() + " tot=" + sumTot + " user=" + userId);
		Map<String, Object> r = new HashMap<String, Object>();
		r.put("ok", true); r.put("cnt", seqs.size()); r.put("seqs", seqs); r.put("totAmt", sumTot);
		return r;
	}

	public Map<String, Object> list(String compCd, Map<String, Object> body) {
		Map<String, Object> p = new HashMap<String, Object>();
		String gb = str(body.get("gb"));
		p.put("compCd", compCd);
		p.put("billGb", "S".equals(gb) || "P".equals(gb) ? gb : "");
		String fr = d8(body.get("frDt")), to = d8(body.get("toDt"));
		p.put("frDt", fr.isEmpty() ? "00000000" : fr); p.put("toDt", to.isEmpty() ? "99999999" : to);
		List<String> st = new ArrayList<String>();
		if (body.get("status") instanceof List) for (Object o : (List<?>) body.get("status")) { String s = str(o); if (s.matches("[WCI]")) st.add(s); }
		p.put("statusList", st);
		p.put("inclDel", "Y".equals(str(body.get("inclDel"))) ? "Y" : "N");
		p.put("kw", str(body.get("kw")));
		Map<String, Object> r = new HashMap<String, Object>();
		try {
			r.put("rows", mapper.selectTaxBillList(p));
		} catch (Exception e) {
			if (!isMissingTable(e)) throw new RuntimeException(e);
			r.put("rows", new ArrayList<Object>()); r.put("noTable", true);
		}
		r.put("ok", true);
		return r;
	}

	public Map<String, Object> get(String compCd, long billSeq) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("billSeq", billSeq);
		Map<String, Object> r = new HashMap<String, Object>();
		Map<String, Object> h = mapper.selectTaxBillOne(p);
		if (h == null) { r.put("ok", false); r.put("msg", "계산서를 찾지 못했습니다."); return r; }
		r.put("head", h);
		r.put("lines", mapper.selectTaxBillDtl(p));
		r.put("comp", mapper.selectTaxComp(p));
		r.put("ok", true);
		return r;
	}

	/** 확정(cfm W→C) · 확정 취소(uncfm C→W) · 삭제(del, W 만) */
	public Map<String, Object> status(String compCd, String userId, String act, List<Long> seqs) {
		Map<String, Object> r = new HashMap<String, Object>();
		if (seqs.isEmpty()) { r.put("ok", false); r.put("msg", "고른 계산서가 없습니다."); return r; }
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("userId", userId); p.put("seqs", seqs);
		int n;
		if ("cfm".equals(act)) {
			List<Map<String, Object>> bad = mapper.selectTaxBadBizno(p);
			if (!bad.isEmpty()) {
				List<Long> ok = new ArrayList<Long>(seqs);
				for (Map<String, Object> b : bad) ok.remove(Long.valueOf(lng(b.get("billSeq"))));
				r.put("bad", bad);
				if (ok.isEmpty()) { r.put("ok", true); r.put("cnt", 0); return r; }
				p.put("seqs", ok);
			}
			p.put("fromSt", "W"); p.put("toSt", "C");
			n = mapper.updateTaxBillStatus(p);
		} else if ("uncfm".equals(act)) {
			p.put("fromSt", "C"); p.put("toSt", "W");
			n = mapper.updateTaxBillStatus(p);
		} else if ("del".equals(act)) {
			n = mapper.deleteTaxBill(p);
		} else { r.put("ok", false); r.put("msg", "알 수 없는 동작입니다."); return r; }
		LOG.info("taxbill " + act + " comp=" + compCd + " req=" + seqs.size() + " done=" + n + " user=" + userId);
		r.put("ok", true); r.put("cnt", n);
		return r;
	}

	public Map<String, Object> saveHead(String compCd, String userId, Map<String, Object> body) {
		Map<String, Object> p = new HashMap<String, Object>();
		String wd = d8(body.get("writeDt"));
		if (wd.isEmpty()) throw new IllegalArgumentException("작성일자를 넣어 주세요.");
		p.put("compCd", compCd); p.put("userId", userId);
		p.put("billSeq", lng(body.get("billSeq")));
		p.put("writeDt", wd);
		p.put("purposeGb", "영수".equals(str(body.get("purposeGb"))) ? "영수" : "청구");
		p.put("email", cut(str(body.get("email")), 100));
		p.put("remark", cut(str(body.get("remark")), 300));
		int n = mapper.updateTaxBillHead(p);
		Map<String, Object> r = new HashMap<String, Object>();
		r.put("ok", n == 1);
		if (n != 1) r.put("msg", "작성 상태의 계산서만 고칠 수 있습니다(확정됐으면 먼저 확정 취소).");
		return r;
	}
}
