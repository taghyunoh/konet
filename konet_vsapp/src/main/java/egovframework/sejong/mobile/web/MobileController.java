package egovframework.sejong.mobile.web;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * 모바일(PWA) 화면 — /m/*.do  (konet_vsapp 전용, 2026-09-11 신설)
 *
 * 화면은 JSP 두 장뿐이다 : /WEB-INF/jsp/m/login.jsp · /WEB-INF/jsp/m/index.jsp (tiles .raw 패턴 — tiles 수정 없음).
 * 자료는 PC 화면이 쓰는 기존 조회(*.do)를 그대로 부른다 — 금액 규칙을 두 벌로 만들지 않기 위함.
 *
 * ★/m/session.do 가 필요한 이유 : 기존 조회 엔드포인트는 세션을 보지 않는다.
 *   세션이 끊긴 채 부르면 compCd 가 빈 값이 되어 SQL 의 fail-open 조건을 타고 «전 회사» 자료가 온다.
 *   그래서 모바일 화면은 자료를 부르기 **전에** 이 엔드포인트로 로그인 여부를 먼저 확인한다.
 */
@Controller
public class MobileController {

	private static boolean loggedIn(HttpSession session) {
		return session.getAttribute("q_user_id") != null && session.getAttribute("s_comp_cd") != null;
	}

	/** 모바일 첫 화면 — 로그인 전이면 모바일 로그인 화면 */
	@RequestMapping(value = "/m/index.do")
	public String index(HttpSession session) {
		return loggedIn(session) ? ".raw/m/index" : ".raw/m/login";
	}

	/** 모바일 로그인 화면 — 실제 로그인은 PC 와 같은 /user/loginChk.do 를 쓴다 */
	@RequestMapping(value = "/m/login.do")
	public String login(HttpSession session) {
		return ".raw/m/login";
	}

	/** 로그인 여부 확인(자료 조회 전에 부른다) */
	@RequestMapping(value = "/m/session.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> session(HttpSession session) {
		Map<String, Object> res = new HashMap<String, Object>();
		boolean ok = loggedIn(session);
		res.put("ok", ok);
		if (ok) {
			res.put("compNm", session.getAttribute("s_comp_nm"));
			res.put("userNm", session.getAttribute("s_user_nm"));
		}
		return res;
	}

	/** 로그아웃 → 모바일 로그인 화면 */
	@RequestMapping(value = "/m/logout.do")
	public String logout(HttpSession session) {
		session.invalidate();
		return "redirect:/m/login.do";
	}
}
