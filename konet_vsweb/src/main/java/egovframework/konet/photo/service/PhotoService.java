package egovframework.konet.photo.service;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.konet.photo.mapper.PhotoMapper;

/**
 * 사진함 (2026-11-26 사용자 「모바일에서 찍은 사진을 한꺼번에 PC 에서 보는 방법」 → 「날짜별 모음 · 줄인 사진만」 · 「보관 1개월로」)
 *
 * · 한 번 올리기 = 묶음 하나(그날 날짜 + 한 줄 이름). 사진은 폰에서 줄인 JPEG 만 받는다(원본 없음).
 * · ★1개월 보관 — 묶음 날짜가 한 달 지난 것은 하루 한 번(첫 조회·올리기 때) «완전히» 지운다. KEEP_MONTHS 한 곳만 바꾸면 된다.
 * · ★konet_vsweb · konet_vsapp 두 앱에 같은 파일이 있다(같은 DB) — 한쪽을 고치면 다른 쪽도 복사.
 */
@Service("PhotoService")
public class PhotoService {

	private static final Logger LOG = LoggerFactory.getLogger(PhotoService.class);

	/** 보관 개월 수 (2026-11-26 사용자 「보관 1개월로 — 그때그때 정리하면 되니까」) */
	public static final int KEEP_MONTHS = 1;
	/** 한 장 상한(줄인 JPEG) — 폰이 1600px · 품질 0.8 로 줄이면 보통 0.2~0.6MB. 넘으면 거절 */
	public static final int MAX_IMG_BYTES = 3 * 1024 * 1024;
	public static final int MAX_THUMB_BYTES = 400 * 1024;

	private static volatile String lastPurgeDay = "";

	@Resource(name = "PhotoMapper")
	private PhotoMapper mapper;

	private static String ymd(Calendar c) { return new SimpleDateFormat("yyyyMMdd").format(c.getTime()); }
	public static String today() { return ymd(Calendar.getInstance()); }
	/** 보관 경계 — 이 날짜보다 앞 묶음은 지운다 (오늘이 12-26 이면 11-26 부터 남는다) */
	public static String cutDay() { Calendar c = Calendar.getInstance(); c.add(Calendar.MONTH, -KEEP_MONTHS); return ymd(c); }

	/** 하루 한 번 — 오래된 사진 지우기. 실패해도 화면은 계속(로그만) */
	public void purgeDaily() {
		String d = today();
		if (d.equals(lastPurgeDay)) return;
		lastPurgeDay = d;
		try {
			Map<String, Object> p = new HashMap<String, Object>();
			p.put("cutDt", cutDay());
			Calendar y = Calendar.getInstance(); y.add(Calendar.DATE, -1); p.put("yday", ymd(y));
			int n, tot = 0, guard = 0;
			do { n = mapper.deletePhotoOld(p); tot += n; } while (n > 0 && ++guard < 500);
			int g = mapper.deletePhotoGrpOld(p) + mapper.deletePhotoGrpEmpty(p);
			if (tot > 0 || g > 0) LOG.info("[photo] 보관 기간 지난 사진 " + tot + "장 · 묶음 " + g + "개 지움 (경계 " + p.get("cutDt") + ")");
		} catch (Exception e) {
			LOG.error("[photo] purge 실패 : " + e.getMessage());
			lastPurgeDay = "";   // 다음 호출에서 다시
		}
	}

	public long newGroup(String compCd, String title, String user, String userNm, String ip) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("grpDt", today()); p.put("title", title);
		p.put("regUser", user); p.put("regNm", userNm); p.put("regIp", ip);
		mapper.insertPhotoGrp(p);
		Object k = p.get("grpSeq");
		return k == null ? 0L : Long.parseLong(String.valueOf(k));
	}

	public Map<String, Object> group(String compCd, long grpSeq) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("grpSeq", grpSeq);
		return mapper.selectPhotoGrpOne(p);
	}

	public long addPhoto(Map<String, Object> p) {
		mapper.insertPhoto(p);
		mapper.updatePhotoGrpCnt(p);
		Object k = p.get("photoSeq");
		return k == null ? 0L : Long.parseLong(String.valueOf(k));
	}

	public Map<String, Object> list(String compCd, String frDt, String toDt) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("frDt", frDt); p.put("toDt", toDt);
		Map<String, Object> r = new HashMap<String, Object>();
		r.put("days", mapper.selectPhotoDays(p));
		r.put("groups", mapper.selectPhotoGrpList(p));
		r.put("photos", mapper.selectPhotoList(p));
		return r;
	}

	public Map<String, Object> img(String compCd, long photoSeq, boolean thumb) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("photoSeq", photoSeq);
		return thumb ? mapper.selectPhotoThumb(p) : mapper.selectPhotoImg(p);
	}

	/** 한 장 지우기 — 묶음이 비면 묶음도 지운다 */
	public void delPhoto(String compCd, long photoSeq, long grpSeq) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("photoSeq", photoSeq); p.put("grpSeq", grpSeq);
		mapper.deletePhoto(p);
		mapper.updatePhotoGrpCnt(p);
		Map<String, Object> g = mapper.selectPhotoGrpOne(p);
		if (g != null && Integer.parseInt(String.valueOf(g.get("photoCnt"))) == 0) mapper.deletePhotoGrp(p);
	}

	public void delGroup(String compCd, long grpSeq) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("grpSeq", grpSeq);
		mapper.deletePhotoByGrp(p);
		mapper.deletePhotoGrp(p);
	}

	public void setTitle(String compCd, long grpSeq, String title) {
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("compCd", compCd); p.put("grpSeq", grpSeq); p.put("title", title);
		mapper.updatePhotoGrpTitle(p);
	}

	public static List<?> nz(List<?> l) { return l == null ? new java.util.ArrayList<Object>() : l; }
}
