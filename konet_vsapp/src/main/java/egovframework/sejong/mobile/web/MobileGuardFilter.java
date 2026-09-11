package egovframework.sejong.mobile.web;

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
 * 모바일(PWA) 요청 가드 — konet_vsapp 전용 (2026-09-11 신설, web.xml *.do).
 *
 * ★왜 필요한가 : 기존 조회·저장 엔드포인트는 세션을 보지 않는다. 세션이 끊긴 채 부르면
 *   compCd 가 빈 값이 되어 조회는 «전 회사» 자료가 오고(SQL fail-open), 저장은 기본 회사로 들어간다.
 *   모바일은 저장(판매·수금·지급)까지 하므로 화면의 /m/session.do 확인만으로는 모자란다
 *   — 확인과 저장 사이에 세션이 끊길 수 있다.
 *
 * ★모바일 화면(m/m.js)이 보내는 요청에만 걸린다 — 헤더 `X-Konet-M` 가 표시다.
 *   헤더가 없는 요청(PC 화면)은 그대로 통과 → PC 동작은 바뀌지 않는다.
 *   세션이 없으면 401 + {"ok":false,"login":true} — 화면은 이걸 보고 모바일 로그인으로 보낸다.
 */
public class MobileGuardFilter implements Filter {

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		if (request instanceof HttpServletRequest && response instanceof HttpServletResponse) {
			HttpServletRequest req = (HttpServletRequest) request;
			if (req.getHeader("X-Konet-M") != null && !isOpen(req) && !loggedIn(req.getSession(false))) {
				HttpServletResponse res = (HttpServletResponse) response;
				res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
				res.setContentType("application/json; charset=UTF-8");
				res.getWriter().write("{\"ok\":false,\"login\":true}");
				return;
			}
		}
		chain.doFilter(request, response);
	}

	/** 로그인 없이 불러야 하는 주소 — 로그인 처리 자체와 로그인 여부 확인 */
	private static boolean isOpen(HttpServletRequest req) {
		String p = req.getRequestURI().substring(req.getContextPath().length());
		return p.equals("/user/loginChk.do") || p.startsWith("/m/");
	}

	/** MobileController.loggedIn 과 같은 기준 */
	private static boolean loggedIn(HttpSession session) {
		return session != null && session.getAttribute("q_user_id") != null && session.getAttribute("s_comp_cd") != null;
	}

	@Override
	public void destroy() {}
}
