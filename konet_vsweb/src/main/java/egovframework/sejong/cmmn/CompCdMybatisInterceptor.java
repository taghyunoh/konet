package egovframework.sejong.cmmn;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.apache.ibatis.executor.Executor;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.plugin.Interceptor;
import org.apache.ibatis.plugin.Intercepts;
import org.apache.ibatis.plugin.Invocation;
import org.apache.ibatis.plugin.Plugin;
import org.apache.ibatis.plugin.Signature;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.RowBounds;

/**
 * 다중회사(멀티테넌트) — 모든 SQL 실행 직전에 현재 로그인 회사코드(compCd)를
 * 파라미터에 자동 주입하는 MyBatis 플러그인. (sql-mapper-config.xml 에 등록)
 *
 * 동작 규칙
 *  · CompCdContext(요청 필터가 세션 s_comp_cd 를 실어 둠)에 회사코드가 있을 때만 동작
 *  · 파라미터가 DTO 이고 compCd 속성이 비어 있으면 setCompCd() 로 채운다
 *    (이미 값이 있으면 존중 — 로그인 화면처럼 사용자가 입력한 회사코드 우선)
 *  · 파라미터가 Map(파라미터 여러 개/foreach 포함)이면 compCd 키를 채운다
 *  · 파라미터가 없는 구문(null)이면 compCd 만 담은 Map 으로 바꿔 #{compCd} 참조를 살린다
 *  · compCd 속성/키가 아예 없는 파라미터(공통코드 등)는 조용히 통과 — 부작용 없음
 *
 * 이 플러그인 덕에 컨트롤러 ~90개 엔드포인트에 일일이 dto.setCompCd(...) 를 넣지 않아도
 * 되고, 새 화면을 추가해도 COMP_CD 주입이 누락되지 않는다.
 */
@Intercepts({
	@Signature(type = Executor.class, method = "update",
	           args = {MappedStatement.class, Object.class}),
	@Signature(type = Executor.class, method = "query",
	           args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class})
})
public class CompCdMybatisInterceptor implements Interceptor {

	@Override
	public Object intercept(Invocation invocation) throws Throwable {
		String compCd = CompCdContext.get();
		if (compCd != null && !compCd.isEmpty()) {
			Object param = invocation.getArgs()[1];
			if (param == null) {
				Map<String, Object> m = new HashMap<String, Object>();
				m.put("compCd", compCd);
				invocation.getArgs()[1] = m;
			} else if (param instanceof Map) {
				injectIntoMap((Map<Object, Object>) param, compCd);
			} else if (!(param instanceof String) && !(param instanceof Number) && !(param instanceof Boolean)) {
				injectIntoBean(param, compCd);
			}
			// String/Number 단일 파라미터 구문은 주입 불가 — 해당 구문은 Map 파라미터로 바꿔서 쓸 것
		}
		return invocation.proceed();
	}

	@SuppressWarnings({"rawtypes", "unchecked"})
	private void injectIntoMap(Map param, String compCd) {
		try {
			// ParamMap 은 없는 키 get() 시 예외 — 반드시 containsKey 로 확인
			Object cur = param.containsKey("compCd") ? param.get("compCd") : null;
			if (cur == null || String.valueOf(cur).trim().isEmpty()) {
				param.put("compCd", compCd);
			}
		} catch (UnsupportedOperationException ignore) {
			// 수정 불가 Map 이면 주입 포기(해당 구문은 원래 compCd 를 안 쓰는 구문)
		}
	}

	private void injectIntoBean(Object param, String compCd) {
		try {
			Method getter = param.getClass().getMethod("getCompCd");
			Object cur = getter.invoke(param);
			if (cur == null || String.valueOf(cur).trim().isEmpty()) {
				Method setter = param.getClass().getMethod("setCompCd", String.class);
				setter.invoke(param, compCd);
			}
		} catch (NoSuchMethodException ignore) {
			// compCd 없는 DTO(공통코드 등) — 대상 아님
		} catch (Exception ignore) {
			// 주입 실패는 치명적이지 않음(SQL 쪽 fail-open) — 조용히 통과
		}
	}

	@Override
	public Object plugin(Object target) {
		return Plugin.wrap(target, this);
	}

	@Override
	public void setProperties(Properties properties) {}
}
