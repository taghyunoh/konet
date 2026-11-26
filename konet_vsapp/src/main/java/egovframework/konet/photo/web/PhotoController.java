package egovframework.konet.photo.web;

import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.konet.photo.service.PhotoService;

/**
 * 사진함 (2026-11-26 사용자 「모바일에서 사진을 여러 장 찍어 카톡으로 하나씩 보내 PC 에서 받던 일 — 한꺼번에 PC 에서 보게」
 *          → 「날짜별 모음 · 줄인 사진만」 · 「보관 1개월로」)
 *
 *  · 모바일 앱(konet_vsapp /m/photo.do) — 여러 장을 고르면 폰에서 줄인 뒤 묶음 하나로 올린다 : grpNew → upload(한 장씩).
 *    ★한 장씩 보내는 까닭 = 운영 nginx 의 본문 크기 한도(기본 1MB)를 넘지 않게 · 중간에 끊겨도 올라간 것은 남게.
 *  · PC(konet_vsweb 정보 현황 ▸ 사진함 /photo/photoBox.do) — 날짜별 묶음·사진 격자 · 크게 보기 · ZIP 내려받기 · 지우기.
 *  · 권한 : 같은 회사 직원은 다 본다. 지우기·이름 고치기 = 올린 사람 또는 관리자(MAIN_GU 1·2).
 *  · 로그인은 web.xml 의 LoginCheckFilter(·앱은 MobileGuardFilter)가 먼저 막고, 여기서도 회사 코드를 다시 본다.
 *  · ★konet_vsweb · konet_vsapp 두 앱에 같은 파일(같은 DB) — 한쪽을 고치면 다른 쪽도 복사.
 *  · 요청 본문은 JSON(@RequestBody) — HTMLTagFilter 는 폼 값만 바꾸므로 묶음 이름의 < > & 가 그대로 저장된다(화면은 esc 로 그린다).
 */
@Controller
public class PhotoController {

	private static final Logger LOG = LoggerFactory.getLogger(PhotoController.class);
	private static final int MAX_DAYS = 62;          // 한 번에 보는 기간 상한(날짜 목록은 보관 기간 전체)
	private static final int MAX_ZIP = 300;

	@Resource(name = "PhotoService")
	private PhotoService svc;

	/* ── 세션 ── */
	private static String s(HttpSession ss, String k) { Object v = ss == null ? null : ss.getAttribute(k); return v == null ? "" : String.valueOf(v).trim(); }
	private static String comp(HttpSession ss) { return s(ss, "s_comp_cd"); }
	private static String user(HttpSession ss) { String u = s(ss, "s_user_id"); return u.isEmpty() ? s(ss, "q_user_id") : u; }
	private static boolean admin(HttpSession ss) { String g = s(ss, "s_main_gu"); return "1".equals(g) || "2".equals(g); }
	private static Map<String, Object> fail(String msg) { Map<String, Object> r = new HashMap<String, Object>(); r.put("ok", false); r.put("msg", msg); return r; }
	private static Map<String, Object> needLogin(HttpServletResponse res) { res.setStatus(401); Map<String, Object> r = fail("로그인이 필요합니다."); r.put("login", true); return r; }
	private static long lng(Object v) { try { return Long.parseLong(String.valueOf(v).trim()); } catch (Exception e) { return 0L; } }
	private static int inte(Object v) { try { return (int) Math.round(Double.parseDouble(String.valueOf(v).trim())); } catch (Exception e) { return 0; } }
	private static String str(Object v, int max) { String t = v == null ? "" : String.valueOf(v).trim(); return t.length() > max ? t.substring(0, max) : t; }
	private static String d8(String v) { return v == null ? "" : v.replaceAll("[^0-9]", ""); }
	private static String ip(HttpServletRequest req) { String f = req.getHeader("X-Forwarded-For"); return str((f != null && !f.isEmpty()) ? f.split(",")[0] : req.getRemoteAddr(), 50); }

	/** dataURL 이든 순수 base64 든 JPEG 바이트로. 모양이 JPEG 가 아니면 null */
	private static byte[] jpeg(Object v) {
		if (v == null) return null;
		String t = String.valueOf(v);
		int c = t.indexOf(','); if (t.startsWith("data:") && c > 0) t = t.substring(c + 1);
		try {
			byte[] b = Base64.getDecoder().decode(t.replaceAll("\\s", ""));
			if (b.length < 4 || (b[0] & 0xFF) != 0xFF || (b[1] & 0xFF) != 0xD8 || (b[2] & 0xFF) != 0xFF) return null;   // JPEG 머리(FF D8 FF)
			return b;
		} catch (Exception e) { return null; }
	}

	/* ── PC 화면 ── */
	@RequestMapping(value = "/photo/photoBox.do")
	public String photoBox(HttpSession session) {
		if (comp(session).isEmpty()) return ".login/base_login";
		return ".raw/main/mangr/photoBox";
	}

	/* ── 묶음 만들기 (모바일이 올리기 시작할 때) ── */
	@RequestMapping(value = "/photo/grpNew.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> grpNew(@RequestBody(required = false) Map<String, Object> body, HttpSession session,
	                                  HttpServletRequest req, HttpServletResponse res) {
		String cc = comp(session); if (cc.isEmpty()) return needLogin(res);
		svc.purgeDaily();
		String title = str(body == null ? null : body.get("title"), 100);
		long g = svc.newGroup(cc, title, user(session), s(session, "s_user_nm"), ip(req));
		if (g <= 0) return fail("묶음을 만들지 못했습니다.");
		Map<String, Object> r = new HashMap<String, Object>();
		r.put("ok", true); r.put("grpSeq", g); r.put("grpDt", PhotoService.today());
		return r;
	}

	/* ── 사진 한 장 올리기 ── {grpSeq, sortNo, fileNm, shotDttm, w, h, img(dataURL·base64 JPEG), thumb} */
	@RequestMapping(value = "/photo/upload.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> upload(@RequestBody(required = false) Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		String cc = comp(session); if (cc.isEmpty()) return needLogin(res);
		if (body == null) return fail("보낸 내용이 없습니다.");
		long grp = lng(body.get("grpSeq"));
		Map<String, Object> g = grp > 0 ? svc.group(cc, grp) : null;
		if (g == null) return fail("묶음을 찾지 못했습니다(다시 올려 주세요).");
		if (!user(session).equals(String.valueOf(g.get("regUser")))) return fail("다른 사람이 만든 묶음에는 올릴 수 없습니다.");
		byte[] img = jpeg(body.get("img"));
		if (img == null) return fail("사진 형식이 올바르지 않습니다(JPEG).");
		if (img.length > PhotoService.MAX_IMG_BYTES) return fail("사진이 너무 큽니다(" + (img.length / 1024) + "KB).");
		byte[] th = jpeg(body.get("thumb"));
		if (th != null && th.length > PhotoService.MAX_THUMB_BYTES) th = null;
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", cc); p.put("grpSeq", grp); p.put("sortNo", inte(body.get("sortNo")));
		p.put("fileNm", str(body.get("fileNm"), 200)); p.put("shotDttm", str(body.get("shotDttm"), 19));
		p.put("imgW", inte(body.get("w"))); p.put("imgH", inte(body.get("h"))); p.put("imgBytes", img.length);
		p.put("img", img); p.put("thumb", th); p.put("regUser", user(session));
		try {
			long seq = svc.addPhoto(p);
			Map<String, Object> r = new HashMap<String, Object>();
			r.put("ok", true); r.put("photoSeq", seq); r.put("bytes", img.length);
			return r;
		} catch (Exception e) {
			LOG.error("[photo] upload 실패 : " + e.getMessage());
			return fail("저장하지 못했습니다 : " + e.getMessage());
		}
	}

	/* ── 목록 (PC) — 날짜 목록(보관 기간 전체) + 고른 기간의 묶음·사진 정보 ── */
	@RequestMapping(value = "/photo/list.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> list(@RequestParam(value = "frDt", required = false) String frDt,
	                                @RequestParam(value = "toDt", required = false) String toDt,
	                                HttpSession session, HttpServletResponse res) {
		String cc = comp(session); if (cc.isEmpty()) return needLogin(res);
		svc.purgeDaily();
		String to = d8(toDt), fr = d8(frDt), today = PhotoService.today(), cut = PhotoService.cutDay();
		if (to.length() != 8) to = today;
		if (fr.length() != 8) fr = to;
		if (fr.compareTo(to) > 0) { String t = fr; fr = to; to = t; }
		Map<String, Object> r = svc.list(cc, fr, to);
		/* 날짜 목록은 보관 기간 전체(왼쪽 달력용) */
		r.put("days", svc.list(cc, cut, today).get("days"));
		r.put("ok", true); r.put("frDt", fr); r.put("toDt", to); r.put("cutDt", cut); r.put("keepMonths", PhotoService.KEEP_MONTHS);
		r.put("me", user(session)); r.put("admin", admin(session));
		return r;
	}

	/* ── 그림 (GET — img 태그가 부른다) ?seq=&thumb=1&dl=1 ── */
	@RequestMapping(value = "/photo/img.do")
	public void img(@RequestParam("seq") long seq, @RequestParam(value = "thumb", required = false) String thumb,
	                @RequestParam(value = "dl", required = false) String dl,
	                HttpSession session, HttpServletResponse res) throws Exception {
		String cc = comp(session);
		if (cc.isEmpty()) { res.setStatus(401); return; }
		boolean th = "1".equals(thumb);
		Map<String, Object> m = svc.img(cc, seq, th);
		Object b = m == null ? null : (m.containsKey("img") ? m.get("img") : m.get("IMG"));
		if (!(b instanceof byte[])) { res.setStatus(404); return; }
		byte[] bytes = (byte[]) b;
		res.setContentType("image/jpeg");
		res.setContentLength(bytes.length);
		res.setHeader("Cache-Control", "private, max-age=604800");   // 같은 번호의 그림은 안 바뀐다
		if ("1".equals(dl) && !th) {
			String nm = fileName(m, seq);
			res.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + URLEncoder.encode(nm, "UTF-8").replace("+", "%20"));
		}
		OutputStream os = res.getOutputStream(); os.write(bytes); os.flush();
	}

	/** 내려받기 이름 = 20261126_묶음이름_03.jpg (이름이 비면 날짜_번호) */
	private static String fileName(Map<String, Object> m, long seq) {
		String dt = String.valueOf(m.get("grpDt"));
		String t = String.valueOf(m.get("title") == null ? "" : m.get("title")).replaceAll("[\\\\/:*?\"<>|\\r\\n\\t]", " ").trim();
		if (t.length() > 40) t = t.substring(0, 40).trim();
		int n = inte(m.get("sortNo"));
		return dt + (t.isEmpty() ? "" : "_" + t) + "_" + (n < 9 ? "0" : "") + (n + 1) + "_" + seq + ".jpg";
	}

	/* ── 여러 장 ZIP (POST seqs=1,2,3) ── */
	@RequestMapping(value = "/photo/zip.do", method = RequestMethod.POST)
	public void zip(@RequestParam("seqs") String seqs, HttpSession session, HttpServletResponse res) throws Exception {
		String cc = comp(session);
		if (cc.isEmpty()) { res.setStatus(401); return; }
		List<Long> list = new ArrayList<Long>(); Set<Long> seen = new HashSet<Long>();
		for (String x : seqs.split("[,\\s]+")) { long v = lng(x); if (v > 0 && seen.add(v)) list.add(v); if (list.size() >= MAX_ZIP) break; }
		if (list.isEmpty()) { res.setStatus(400); return; }
		String zn = "사진_" + PhotoService.today() + "_" + list.size() + "장.zip";
		res.setContentType("application/zip");
		res.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + URLEncoder.encode(zn, "UTF-8").replace("+", "%20"));
		res.setHeader("Cache-Control", "no-store");
		ZipOutputStream z = new ZipOutputStream(res.getOutputStream(), java.nio.charset.StandardCharsets.UTF_8);
		z.setLevel(java.util.zip.Deflater.NO_COMPRESSION);   // JPEG 는 더 줄지 않는다 — 시간만 든다
		for (Long seq : list) {
			Map<String, Object> m = svc.img(cc, seq, false);
			Object b = m == null ? null : m.get("img");
			if (!(b instanceof byte[])) continue;
			z.putNextEntry(new ZipEntry(fileName(m, seq)));
			z.write((byte[]) b);
			z.closeEntry();
		}
		z.finish(); z.flush();
	}

	/* ── 지우기 {photoSeq} 또는 {grpSeq} — 올린 사람 또는 관리자 ── */
	@RequestMapping(value = "/photo/del.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> del(@RequestBody(required = false) Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		String cc = comp(session); if (cc.isEmpty()) return needLogin(res);
		if (body == null) return fail("보낸 내용이 없습니다.");
		long ps = lng(body.get("photoSeq")), gs = lng(body.get("grpSeq"));
		if (ps > 0) {
			Map<String, Object> m = svc.img(cc, ps, false);
			if (m == null) return fail("사진을 찾지 못했습니다.");
			if (!admin(session) && !user(session).equals(String.valueOf(m.get("regUser")))) return fail("올린 사람이나 관리자만 지울 수 있습니다.");
			svc.delPhoto(cc, ps, lng(m.get("grpSeq")));
		} else if (gs > 0) {
			Map<String, Object> g = svc.group(cc, gs);
			if (g == null) return fail("묶음을 찾지 못했습니다.");
			if (!admin(session) && !user(session).equals(String.valueOf(g.get("regUser")))) return fail("올린 사람이나 관리자만 지울 수 있습니다.");
			svc.delGroup(cc, gs);
		} else return fail("지울 것을 고르세요.");
		Map<String, Object> r = new HashMap<String, Object>(); r.put("ok", true); return r;
	}

	/* ── 묶음 이름 고치기 {grpSeq, title} ── */
	@RequestMapping(value = "/photo/title.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> title(@RequestBody(required = false) Map<String, Object> body, HttpSession session, HttpServletResponse res) {
		String cc = comp(session); if (cc.isEmpty()) return needLogin(res);
		long gs = body == null ? 0 : lng(body.get("grpSeq"));
		Map<String, Object> g = gs > 0 ? svc.group(cc, gs) : null;
		if (g == null) return fail("묶음을 찾지 못했습니다.");
		if (!admin(session) && !user(session).equals(String.valueOf(g.get("regUser")))) return fail("올린 사람이나 관리자만 고칠 수 있습니다.");
		svc.setTitle(cc, gs, str(body.get("title"), 100));
		Map<String, Object> r = new HashMap<String, Object>(); r.put("ok", true); return r;
	}
}
