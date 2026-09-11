package egovframework.sejong.cmmn;

import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 오래 걸리는 작업의 진행 상황 게시판 (2026-08-01)
 *
 *  [출고반영 재집계] 는 출고일자 수만큼 원장을 다시 만들기 때문에 자료가 쌓이면 수십 초가 걸린다.
 *  그런데 요청은 POST 하나로 끝나서 화면이 멈춘 것처럼 보였다 — "진행 바가 없어서" 지적.
 *
 *  가짜 진행바(시간으로 늘어나는 막대)를 쓰지 않는다. 서버가 '몇 개 중 몇 개' 를 실제로 알고 있으므로
 *  여기에 적어 두고, 화면은 별도 요청으로 그 값을 읽어 진짜 진행률을 그린다.
 *
 *  · 키 = 사용자 ID (한 사람이 두 번 동시에 돌릴 일은 없다)
 *  · 작업이 끝나면 반드시 end() — finally 에서 부른다
 *  · 서버가 죽거나 end() 를 못 부른 찌꺼기는 조회할 때 10분 지난 것부터 치운다
 *  · DB 를 쓰지 않으므로 폴링이 재집계 트랜잭션을 방해하지 않는다
 */
public final class RebuildProgress {

	/** 오래된 찌꺼기 정리 기준 (ms) */
	private static final long STALE_MS = 10 * 60 * 1000L;

	public static final class P {
		public volatile String phase = "";
		public volatile int done;
		public volatile int total;      // 0 이면 '총량 모름'(단계 표시만)
		public volatile long ts;
	}

	private static final Map<String, P> MAP = new ConcurrentHashMap<String, P>();

	private RebuildProgress() {}

	private static String key(String k) { return (k == null || k.trim().isEmpty()) ? "-" : k.trim(); }

	/** 진행 상황 기록 — 같은 키면 덮어쓴다 */
	public static void set(String k, String phase, int done, int total) {
		P p = MAP.get(key(k));
		if (p == null) { p = new P(); MAP.put(key(k), p); }
		p.phase = (phase == null ? "" : phase);
		p.done = done; p.total = total; p.ts = System.currentTimeMillis();
	}

	/** 작업 종료 — 반드시 finally 에서 */
	public static void end(String k) { MAP.remove(key(k)); }

	/** 조회 (없으면 null = 진행 중 아님). 겸사겸사 오래된 찌꺼기를 치운다. */
	public static P get(String k) {
		long now = System.currentTimeMillis();
		for (Iterator<Map.Entry<String, P>> it = MAP.entrySet().iterator(); it.hasNext(); ) {
			Map.Entry<String, P> e = it.next();
			if (e.getValue() == null || now - e.getValue().ts > STALE_MS) it.remove();
		}
		return MAP.get(key(k));
	}
}
