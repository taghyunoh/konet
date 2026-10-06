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
 * 로그인 확인 필터 (2026-10-06) — *.do 요청은 <b>로그인 세션(s_comp_cd)이 있어야</b> 통과한다.
 *
 * <p>까닭 : 미로그인이면 회사코드(compCd)가 빈 값이라 SQL 의 COMP_CD 조건이 fail-open(전체 조회)으로 돈다.
 *   그래서 로그인 없이 /mangr/salesTrxList.do 를 부르면 <b>모든 회사의 판매전표</b>가 나왔다(로컬 실측).
 *   엔드포인트 340여 개에 하나씩 검사를 넣는 대신 여기 한 곳에서 막는다.
 *
 * <p>막을 때 :
 * <ul>
 *   <li>화면 이동(GET + 브라우저가 HTML 을 원함) → 로그인 화면(/konet.do)으로 보낸다
 *       (302 가 아니라 상대 주소로 옮기는 작은 페이지 — 운영 톰캣의 302 는 http 절대주소라 https 셸의 iframe 에서 막힌다).</li>
 *   <li>그 밖(fetch·ajax·POST) → <b>401</b> + 「로그인이 필요합니다」. 화면의 오류 알림에 그 글이 그대로 뜬다.
 *       ※운영 nginx 는 401 을 그대로 통과시킨다(2026-10-06 실측 — 404 만 가비아 오류 페이지로 바뀐다).</li>
 * </ul>
 *
 * <p>로그인 없이 열려야 하는 곳(아래 PUBLIC) — 로그인·비밀번호 화면, 환자 가입, 약관, 세션 확인,
 *   카톡·메일로 보낸 <b>공개 링크(/pub/*)</b>(토큰이 곧 열쇠). 새 공개 주소를 만들면 여기에 더한다.
 */
public class LoginCheckFilter implements Filter {

	/** 이 주소들은 그대로 통과(정확히 같은 주소) */
	private static final java.util.Set<String> PUBLIC_EXACT = new java.util.HashSet<String>(java.util.Arrays.asList(
		"/konet.do", "/index.do", "/main.do",                    // 정문·로그인 화면(main.do 는 미로그인이면 스스로 로그인 화면을 그린다)
		"/user/loginAct.do", "/user/loginChk.do", "/user/loginOutAct.do",
		"/user/sessionChk.do",                                   // 화면이 5분마다 묻는 세션·재배포 확인 — 미로그인이면 login=N 을 돌려줘야 한다
		"/getSignList.do",                                       // 회원가입 약관
		"/patient/login.do", "/patient/register.do",
		"/json/user/pwdresetAct.do", "/json/user/pwdchgAct.do"   // 로그인 화면의 비밀번호 초기화·변경
	));
	/** 이 앞머리로 시작하면 통과 */
	private static final String[] PUBLIC_PREFIX = {
		"/pub/",     // 공개 링크(거래명세서·발주서·견적서·메일 열람) — 토큰으로만 연다
		"/popup/"    // 로그인 화면이 여는 비밀번호 변경·초기화 창
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
		int semi = path.indexOf(';');                 // ;jsessionid= 꼬리 제거
		if (semi >= 0) path = path.substring(0, semi);

		if (isPublic(path)) { chain.doFilter(request, response); return; }

		HttpSession session = req.getSession(false);
		if (session != null && session.getAttribute("s_comp_cd") != null) { chain.doFilter(request, response); return; }

		/* 미로그인 — 화면 이동이면 로그인 화면으로, 데이터 요청이면 401 */
		String accept = req.getHeader("Accept");
		boolean page = "GET".equalsIgnoreCase(req.getMethod())
			&& accept != null && accept.contains("text/html")
			&& !"XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
		/* ★sendRedirect 를 쓰지 않는다 (2026-10-06 운영 실측) — 운영 톰캣은 Location 을 <절대 http://allcare24.kr/…> 로 만든다(앞단 nginx 가 https 를 풀어서 넘김).
		     메뉴 화면은 https 셸 안의 iframe 이라 http 로 튀면 Mixed Content 로 막혀 <빈 칸>이 된다. 그래서 상대 주소로 옮기는 작은 페이지를 준다 —
		     iframe 안이면 <창 전체(top)>를 로그인 화면으로(로그인 화면이 메뉴 칸 안에 박히지 않게). */
		if (page) {
			String to = ctx + "/konet.do";
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
