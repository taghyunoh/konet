package egovframework.sejong.cmmn;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * 다중회사(멀티테넌트) — 요청마다 로그인 세션의 회사코드(s_comp_cd)를
 * CompCdContext(ThreadLocal) 에 실어 주는 필터. web.xml 의 *.do 에 걸려 있다.
 *
 * 세션이 없거나 미로그인(s_comp_cd 없음)이면 아무것도 싣지 않는다
 * — 그 경우 SQL 의 COMP_CD 필터는 fail-open(전체 조회)으로 동작해 기존 화면이 깨지지 않는다.
 */
public class CompCdFilter implements Filter {

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		try {
			if (request instanceof HttpServletRequest) {
				HttpSession session = ((HttpServletRequest) request).getSession(false);
				Object v = (session != null) ? session.getAttribute("s_comp_cd") : null;
				CompCdContext.set(v != null ? String.valueOf(v) : null);
			}
			chain.doFilter(request, response);
		} finally {
			// 톰캣 스레드풀 재사용 대비 — 요청 끝나면 반드시 비운다(다른 회사 값 잔존 방지)
			CompCdContext.clear();
		}
	}

	@Override
	public void destroy() {}
}
