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
 * 화면 = /WEB-INF/jsp/m/ 의 login · index(요약) · sales(판매등록) · settle(수금·지급) · stock(재고·상품) (tiles .raw 패턴 — tiles 수정 없음).
 * 자료·저장은 PC 화면이 쓰는 기존 엔드포인트(*.do)를 그대로 부른다 — 금액·재고 규칙을 두 벌로 만들지 않기 위함.
 * 모바일 화면이 보내는 요청은 MobileGuardFilter 가 세션을 확인한다(헤더 X-Konet-M).
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

	/* ★로그인 전이면 **넘기지 않고 그 자리에서** 로그인 화면을 보여 준다 (2026-09-11 운영 실측).
	     운영은 nginx(https) 뒤의 톰캣(http)이라 redirect: 를 쓰면 넘김 주소가 http:// 로 바뀌어
	     PWA(https 전용)가 끊긴다. 로그인 화면(login.jsp)은 로그인 뒤 원래 보던 화면으로 되돌아간다. */

	/** 판매등록 — 저장은 PC 와 같은 /mangr/salesTrxSave.do */
	@RequestMapping(value = "/m/sales.do")
	public String sales(HttpSession session) {
		return loggedIn(session) ? ".raw/m/sales" : ".raw/m/login";
	}

	/** 수금·지급 등록(?gb=RCV|PAY) — 저장은 PC 와 같은 /mangr/settleSave.do */
	@RequestMapping(value = "/m/settle.do")
	public String settle(HttpSession session) {
		return loggedIn(session) ? ".raw/m/settle" : ".raw/m/login";
	}

	/** 재고·상품 조회 */
	@RequestMapping(value = "/m/stock.do")
	public String stock(HttpSession session) {
		return loggedIn(session) ? ".raw/m/stock" : ".raw/m/login";
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

	/** 로그아웃 → 그 자리에서 모바일 로그인 화면(넘기지 않는다 — 위 주석) */
	@RequestMapping(value = "/m/logout.do")
	public String logout(HttpSession session) {
		session.invalidate();
		return ".raw/m/login";
	}
}
