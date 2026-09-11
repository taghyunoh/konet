package egovframework.sejong.cmmn;

/**
 * 다중회사(멀티테넌트) — 현재 요청의 회사코드(COMP_CD) 보관소.
 *
 * CompCdFilter 가 요청 시작 시 로그인 세션(s_comp_cd)의 회사코드를 넣어 두면,
 * CompCdMybatisInterceptor 가 모든 SQL 실행 직전에 파라미터(compCd)로 자동 주입한다.
 * 요청 스레드 단위(ThreadLocal)라 컨트롤러/서비스 코드는 손대지 않아도 된다.
 */
public final class CompCdContext {

	private static final ThreadLocal<String> HOLDER = new ThreadLocal<String>();

	private CompCdContext() {}

	public static void set(String compCd) {
		if (compCd == null || compCd.trim().isEmpty()) {
			HOLDER.remove();
		} else {
			HOLDER.set(compCd.trim());
		}
	}

	/** 현재 요청의 회사코드. 미로그인 등으로 없으면 null */
	public static String get() {
		return HOLDER.get();
	}

	public static void clear() {
		HOLDER.remove();
	}
}
