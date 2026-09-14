package egovframework.konet.cmmn;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

/**
 * 메일 발송 (2026-09-09 신설) — 지금은 <거래명세서 이메일 발송> 하나가 쓴다.
 *
 * <p>★설정은 src/main/resources/mail.properties. 위너넷(wnn_medcost)과 같은 키다.
 *   <pre>
 *   mail.smtp.host / mail.smtp.port / mail.smtp.ssl / mail.smtp.user / mail.smtp.password
 *   mail.from / mail.fromName
 *   </pre>
 *
 * <p>★<b>계정이 비어 있으면 보내지 않고 {@link #ready()} 가 false 를 돌려준다.</b>
 *   화면은 그때 [메일 프로그램 열기] 로 넘긴다 — 계정이 없어도 기능이 죽지 않게 하려는 것이다.
 *
 * <p>★<b>설정을 찾는 차례</b> (2026-09-14 — 비밀번호를 저장소에서 뺐다) :
 *   <ol>
 *   <li>톰캣 실행옵션 {@code -Dmail.smtp.password=…}</li>
 *   <li><b>{@code <톰캣>/conf/konet-mail.properties}</b> — git 밖 파일. WAR 를 새로 올려도 지워지지 않는다.
 *       <b>비밀번호는 여기에 둔다</b>(PC·운영 서버마다 한 번 만든다).</li>
 *   <li>{@code src/main/resources/mail.properties} — 저장소 파일. 서버·아이디·보내는사람만 담고 비밀번호는 빈 칸.</li>
 *   </ol>
 *
 * <p>⚠네이버·구글은 로그인 비밀번호가 아니라 <b>애플리케이션 비밀번호</b>를 요구한다.
 *   네이버는 465(SSL), 구글은 465(SSL) 또는 587(STARTTLS).
 */
public class MailSender {

	private MailSender() {}

	/** git 밖에 두는 설정 파일 이름 — {@code <톰캣>/conf/} 아래 (2026-09-14) */
	public static final String EXT_FILE = "konet-mail.properties";

	/** 실행옵션(-D…) → 톰캣 conf/konet-mail.properties → mail.properties 차례로 찾는다. */
	public static String prop(String key) {
		try { String v = System.getProperty(key); if (v != null && !v.trim().isEmpty()) return v.trim(); } catch (Exception e) {}
		String v = extProp(key);
		if (!v.isEmpty()) return v;
		/* ResourceBundle 은 Java 8 에서 ISO-8859-1 로 읽어 한글(보내는사람 이름)이 깨진다 — UTF-8 로 직접 읽는다 */
		try (InputStream in = MailSender.class.getClassLoader().getResourceAsStream("mail.properties")) {
			if (in == null) return "";
			Properties p = new Properties();
			p.load(new InputStreamReader(in, StandardCharsets.UTF_8));
			String s = p.getProperty(key);
			return s == null ? "" : s.trim();
		} catch (Exception e) { return ""; }
	}

	/** {@code <톰캣>/conf/konet-mail.properties} 의 값 — 파일이 없거나 톰캣 밖(catalina.base 없음)이면 빈 값 */
	private static String extProp(String key) {
		try {
			String base = System.getProperty("catalina.base");
			if (base == null || base.trim().isEmpty()) return "";
			java.io.File f = new java.io.File(new java.io.File(base.trim(), "conf"), EXT_FILE);
			if (!f.isFile()) return "";
			try (InputStream in = new java.io.FileInputStream(f)) {
				Properties p = new Properties();
				p.load(new InputStreamReader(in, StandardCharsets.UTF_8));
				String s = p.getProperty(key);
				return s == null ? "" : s.trim();
			}
		} catch (Exception e) { return ""; }
	}

	/**
	 * 지금 쓰는 비밀번호가 <b>어디서 온 것인가</b> — {@code "실행옵션"} / {@code "톰캣설정파일"} / {@code "파일"} / {@code "없음"}.
	 *
	 * <p>★비밀번호 <b>값은 절대 내보내지 않는다</b> — 「어디서 왔나」만 말한다.
	 *
	 * <p>2026-09-10 에 이것 때문에 한나절을 썼다 : <b>같은 WAR</b> 인데 로컬은 메일이 나가고 운영은 535 로 거부됐다.
	 *   실행옵션(-Dmail.smtp.password=)이 <b>파일보다 먼저</b> 쓰이므로, 운영에 옛 실행옵션이 걸려 있으면
	 *   새 WAR 의 올바른 비밀번호가 <b>조용히 무시된다</b> — 어느 쪽이 쓰이는지 볼 길이 없어 원인을 못 가렸다.
	 */
	public static String pwSource() {
		try { String v = System.getProperty("mail.smtp.password"); if (v != null && !v.trim().isEmpty()) return "실행옵션"; } catch (Exception e) {}
		if (!extProp("mail.smtp.password").isEmpty()) return "톰캣설정파일";
		return prop("mail.smtp.password").length() > 0 ? "파일" : "없음";
	}

	/** 보낼 수 있는 상태인가 — 서버·계정·보내는사람이 모두 채워져 있어야 한다. */
	public static boolean ready() {
		return prop("mail.smtp.host").length() > 0
		    && prop("mail.smtp.user").length() > 0
		    && prop("mail.smtp.password").length() > 0
		    && prop("mail.from").length() > 0;
	}

	/**
	 * HTML 메일 한 통. 보낸 뒤 아무것도 남기지 않는다(보관은 메일 서버의 보낸편지함이 한다).
	 *
	 * @param to      받는사람 — 「;」 또는 「,」 로 여럿
	 * @param subject 제목
	 * @param html    본문(HTML)
	 * @throws IllegalStateException 계정이 설정되지 않았을 때
	 */
	public static void sendHtml(String to, String subject, String html) throws Exception {
		if (!ready()) throw new IllegalStateException("메일 계정이 설정되지 않았습니다 (비밀번호 = 톰캣 conf/" + EXT_FILE + ").");
		if (to == null || to.trim().isEmpty()) throw new IllegalArgumentException("받는사람이 비어 있습니다.");

		final String host = prop("mail.smtp.host");
		final String port = prop("mail.smtp.port").isEmpty() ? "465" : prop("mail.smtp.port");
		final boolean ssl = !"false".equalsIgnoreCase(prop("mail.smtp.ssl"));
		final String user = prop("mail.smtp.user");
		final String pass = prop("mail.smtp.password");

		Properties p = new Properties();
		p.put("mail.smtp.host", host);
		p.put("mail.smtp.port", port);
		p.put("mail.smtp.auth", "true");
		p.put("mail.smtp.connectiontimeout", "10000");
		p.put("mail.smtp.timeout", "20000");
		p.put("mail.smtp.writetimeout", "20000");
		if (ssl) {
			/* 465 = 처음부터 SSL. 네이버가 이 방식이다. */
			p.put("mail.smtp.ssl.enable", "true");
			p.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
			p.put("mail.smtp.socketFactory.port", port);
			p.put("mail.smtp.socketFactory.fallback", "false");
		} else {
			/* 587 = 평문으로 붙었다가 STARTTLS 로 올린다(구글 등) */
			p.put("mail.smtp.starttls.enable", "true");
		}

		Session s = Session.getInstance(p, new javax.mail.Authenticator() {
			@Override protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
				return new javax.mail.PasswordAuthentication(user, pass);
			}
		});

		MimeMessage msg = new MimeMessage(s);
		String fromNm = prop("mail.fromName");
		msg.setFrom(fromNm.isEmpty() ? new InternetAddress(prop("mail.from"))
		                             : new InternetAddress(prop("mail.from"), fromNm, "UTF-8"));
		/* 「;」 도 받는다 — 거래처 마스터 EMAIL 에 주소를 세미콜론으로 이어 담기 때문 */
		msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to.replace(';', ',').trim(), false));
		msg.setSubject(subject == null ? "" : subject, "UTF-8");
		msg.setContent(html == null ? "" : html, "text/html; charset=UTF-8");
		msg.setSentDate(new java.util.Date());
		Transport.send(msg);
	}
}
