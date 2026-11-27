package egovframework.konet.tax.web;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.konet.tax.service.TaxBillService;

/**
 * 매출·매입 계산서 (2026-11-27 사용자 「홀세일처럼 매출계산서, 매입계산서 (전자세금계산서 연동)」 → 「화면부터 먼저」)
 *
 *  화면 : /tax/billMake.do?gb=S|P      생성(합계·건별·상품별)   → mangr/taxBillMake.jsp
 *         /tax/billList.do?mode=cfm|issue|hist&gb=S|P|A  확정·발행·내역 → mangr/taxBillList.jsp
 *  자료 : 전부 POST + JSON 본문(@RequestBody) — HTMLTagFilter 는 폼 값만 바꾸므로 비고의 < > & 가 그대로 간다(화면은 esc 로 그린다).
 *  · 로그인은 web.xml LoginCheckFilter 가 먼저 막고, 여기서도 회사 코드를 다시 본다(모든 SQL 이 세션 회사코드로만).
 *  · 국세청 전송(전자 발행)은 아직 없다 — 중계업체(바로빌·팝빌 등) 계약 뒤 /tax/issue.do 를 붙인다.
 */
@Controller
public class TaxBillController {

	private static final Logger LOG = LoggerFactory.getLogger(TaxBillController.class);
	private static final int MAX_DAYS = 93;   // 한 번에 묶는 기간 상한(원천 낱줄이 한 달 3천~5천 줄)

	@Resource(name = "TaxBillService")
	private TaxBillService svc;

	private static String s(HttpSession ss, String k) { Object v = ss == null ? null : ss.getAttribute(k); return v == null ? "" : String.valueOf(v).trim(); }
	private static String comp(HttpSession ss) { return s(ss, "s_comp_cd"); }
	private static String user(HttpSession ss) { return s(ss, "s_user_id"); }
	private static Map<String, Object> fail(String msg) { Map<String, Object> r = new HashMap<String, Object>(); r.put("ok", false); r.put("msg", msg); return r; }
	private static Map<String, Object> needLogin(HttpServletResponse res) { res.setStatus(401); Map<String, Object> r = fail("로그인이 끊겼습니다 — 다시 로그인한 뒤 해 주세요."); r.put("login", true); return r; }
	private static int days(String fr, String to) {
		try {
			java.text.SimpleDateFormat f = new java.text.SimpleDateFormat("yyyyMMdd");
			return (int) ((f.parse(to).getTime() - f.parse(fr).getTime()) / 86400000L) + 1;
		} catch (Exception e) { return -1; }
	}

	/* ── 화면 ── */
	@RequestMapping(value = "/tax/billMake.do")
	public String billMake(HttpSession session) {
		if (comp(session).isEmpty()) return ".login/base_login";
		return ".raw/main/mangr/taxBillMake";
	}
	@RequestMapping(value = "/tax/billList.do")
	public String billList(HttpSession session) {
		if (comp(session).isEmpty()) return ".login/base_login";
		return ".raw/main/mangr/taxBillList";
	}

	/* ── 생성 화면 재료 ── body = { gb, frDt, toDt } */
	@RequestMapping(value = "/tax/srcData.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> srcData(@RequestBody Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		if (comp(session).isEmpty()) return needLogin(res);
		try {
			String gb = "P".equals(TaxBillService.str(body.get("gb"))) ? "P" : "S";
			String fr = TaxBillService.d8(body.get("frDt")), to = TaxBillService.d8(body.get("toDt"));
			if (fr.isEmpty() || to.isEmpty()) return fail("기간을 넣어 주세요.");
			int d = days(fr, to);
			if (d < 1) return fail("시작일이 종료일보다 뒤입니다.");
			if (d > MAX_DAYS) return fail("기간은 " + MAX_DAYS + "일(약 3개월)까지 묶을 수 있습니다.");
			return svc.srcData(comp(session), gb, fr, to);
		} catch (Exception e) {
			LOG.error("tax srcData : " + e.getMessage(), e);
			return fail("조회 중 오류 : " + e.getMessage());
		}
	}

	/* ── 계산서 만들기 ── */
	@RequestMapping(value = "/tax/create.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> create(@RequestBody Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		if (comp(session).isEmpty()) return needLogin(res);
		try {
			return svc.createBills(comp(session), user(session), body);
		} catch (IllegalArgumentException e) {
			return fail(e.getMessage());
		} catch (Exception e) {
			LOG.error("tax create : " + e.getMessage(), e);
			String m = String.valueOf(e.getMessage());
			if (m.contains("TBL_TAXBILL")) return fail("계산서 표가 아직 없습니다 — docs/sql/20261127_taxbill.sql 을 먼저 실행해 주세요.");
			return fail("저장 중 오류 — 아무것도 저장되지 않았습니다 : " + m);
		}
	}

	/* ── 목록 ── body = { gb, frDt, toDt, status:[W,C,I], inclDel, kw } */
	@RequestMapping(value = "/tax/list.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> list(@RequestBody Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		if (comp(session).isEmpty()) return needLogin(res);
		try { return svc.list(comp(session), body); }
		catch (Exception e) { LOG.error("tax list : " + e.getMessage(), e); return fail("조회 중 오류 : " + e.getMessage()); }
	}

	/* ── 한 장 (보기·인쇄) ── body = { billSeq } */
	@RequestMapping(value = "/tax/get.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> get(@RequestBody Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		if (comp(session).isEmpty()) return needLogin(res);
		try { return svc.get(comp(session), TaxBillService.lng(body.get("billSeq"))); }
		catch (Exception e) { LOG.error("tax get : " + e.getMessage(), e); return fail("조회 중 오류 : " + e.getMessage()); }
	}

	/* ── 확정 · 확정 취소 · 삭제 ── body = { act: cfm|uncfm|del, seqs:[] } */
	@RequestMapping(value = "/tax/status.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> status(@RequestBody Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		if (comp(session).isEmpty()) return needLogin(res);
		try {
			List<Long> seqs = new ArrayList<Long>();
			if (body.get("seqs") instanceof List) for (Object o : (List<?>) body.get("seqs")) { long v = TaxBillService.lng(o); if (v > 0 && !seqs.contains(v)) seqs.add(v); }
			if (seqs.size() > 1000) return fail("한 번에 1000장까지 처리합니다.");
			return svc.status(comp(session), user(session), TaxBillService.str(body.get("act")), seqs);
		} catch (Exception e) { LOG.error("tax status : " + e.getMessage(), e); return fail("처리 중 오류 : " + e.getMessage()); }
	}

	/* ── 머리 고치기(작성 상태만) ── body = { billSeq, writeDt, purposeGb, email, remark } */
	@RequestMapping(value = "/tax/saveHead.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> saveHead(@RequestBody Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		if (comp(session).isEmpty()) return needLogin(res);
		try { return svc.saveHead(comp(session), user(session), body); }
		catch (IllegalArgumentException e) { return fail(e.getMessage()); }
		catch (Exception e) { LOG.error("tax saveHead : " + e.getMessage(), e); return fail("저장 중 오류 : " + e.getMessage()); }
	}
}
