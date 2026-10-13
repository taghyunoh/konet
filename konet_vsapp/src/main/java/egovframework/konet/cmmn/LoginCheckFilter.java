package egovframework.konet.cmmn;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 로그인 확인 필터 — 모바일 앱(konet_vsapp) 판 (2026-10-13).
 *
 * <p>까닭 : 미로그인이면 회사코드(compCd)가 빈 값이라 SQL 의 COMP_CD 조건이 fail-open(전체 조회)으로 돈다.
 *   웹(konet_vsweb)에는 같은 날 같은 필터를 넣었는데, 앱 WAR(/konetapp)는 {@code MobileGuardFilter} 가
 *   <b>헤더 X-Konet-M 이 달린 요청만</b> 보므로 헤더 없이 부르면
 *   {@code /konetapp/mangr/salesTrxList.do} 가 로그인 없이 돌았다(운영 실측 — 200).
 *
 * <p>순서 : web.xml 에서 {@code mobileGuardFilter} 뒤에 둔다 — 앱 화면(헤더 있음)은 지금처럼
 *   그 필터가 {"ok":false,"login":true}(401) 로 답하고(m.js 가 그 답으로 로그인 화면을 띄운다),
 *   이 필터는 <b>헤더 없는 요청</b>까지 막는다.
 *
 * <p>막을 때 :
 * <ul>
 *   <li>화면 이동(GET + 브라우저가 HTML 을 원함) → 앱 로그인(/m/index.do)으로. 302 대신 상대 주소로 옮기는 작은 페이지
 *       (운영 톰캣의 302 는 http 절대주소라 https 화면에서 막힌다 — 웹과 같은 까닭).</li>
 *   <li>그 밖(fetch·ajax·POST) → 401 「로그인이 필요합니다」.</li>
 * </ul>
 *
 * <p>로그인 없이 열려야 하는 곳(PUBLIC) — 앱 화면 /m/*(제가 로그인 여부를 보고 로그인 화면을 그린다)·로그인 처리·
 *   웹과 같은 로그인/비밀번호/약관/공개 링크. 새 공개 주소를 만들면 여기에 더한다(웹 LoginCheckFilter 와 같이).
 */
public class LoginCheckFilter implements Filter {

	/** 이 주소들은 그대로 통과(정확히 같은 주소) */
	private static final java.util.Set<String> PUBLIC_EXACT = new java.util.HashSet<String>(java.util.Arrays.asList(
		"/konet.do", "/index.do", "/main.do",
		"/user/loginAct.do", "/user/loginChk.do", "/user/loginOutAct.do",
		"/user/sessionChk.do",
		"/getSignList.do",
		"/patient/login.do", "/patient/register.do",
		"/json/user/pwdresetAct.do", "/json/user/pwdchgAct.do"
	));
	/** 이 앞머리로 시작하면 통과 */
	private static final String[] PUBLIC_PREFIX = {
		"/m/",       // 앱 화면·세션 확인·로그아웃 — MobileController 가 로그인 여부를 스스로 본다
		"/pub/",     // 공개 링크(토큰으로만 연다)
		"/popup/"    // 로그인 화면이 여는 비밀번호 창
	};

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		if (!(request instanceof HttpServletRequest)) { chain.doFilter(request, response); return; }
		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse res = (HttpServletResponse) response;

		String ctx = req.getContextPath();
		String path = req.getRequestURI().substring(ctx.length());
		int semi = path.indexOf(';');                 // ;KONETAPP_SID= 꼬리 제거
		if (semi >= 0) path = path.substring(0, semi);

		if (isPublic(path)) { chain.doFilter(request, response); return; }

		HttpSession session = req.getSession(false);
		if (session != null && session.getAttribute("s_comp_cd") != null) { chain.doFilter(request, response); return; }

		String accept = req.getHeader("Accept");
		boolean page = "GET".equalsIgnoreCase(req.getMethod())
			&& accept != null && accept.contains("text/html")
			&& !"XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
		if (page) {
			String to = ctx + "/m/index.do";
			res.setStatus(200);
			res.setContentType("text/html; charset=UTF-8");
			res.setHeader("Cache-Control", "no-store");
			res.getWriter().write("<!doctype html><html><head><meta charset=\"utf-8\"><title>로그인</title></head><body>"
				+ "<script>(function(u){try{if(window.top!==window.self){window.top.location.replace(u);return;}}catch(e){}location.replace(u);})('" + to + "');</script>"
				+ "<noscript><a href=\"" + to + "\">로그인이 필요합니다 — 로그인 화면으로</a></noscript></body></html>");
			return;
		}

		res.setStatus(401);
		res.setContentType("text/plain; charset=UTF-8");
		res.setHeader("Cache-Control", "no-store");
		res.getWriter().write("로그인이 필요합니다. 다시 로그인해 주세요.");
	}

	static boolean isPublic(String path) {
		if (PUBLIC_EXACT.contains(path)) return true;
		for (String p : PUBLIC_PREFIX) if (path.startsWith(p)) return true;
		return false;
	}

	@Override
	public void destroy() {}
}
