/* =====================================================================
   DbRead — 읽기 전용 DB 조회기 (2026-09-16, 사용자 요청)
     왜 : 「저장했음」과 실제 자료가 어긋난 일이 있었다(출고장→창고 매핑·재고마감 스냅샷).
          화면이 멀쩡해 보여도 저장이 0건이면 아무 흔적이 없다 ⇒ 표를 직접 세어 보고 말한다.

   ★이 도구는 SELECT 만 한다. 고치는 SQL 은 **거부**한다(아래 guard).
     · 접속 주소·계정 = 앱과 같은 곳(context-datasource.xml 을 읽는다)
     · 비밀번호 = 앱과 같은 파일(<톰캣>/conf/konet-db.properties) — **저장소에 넣지 않는다. 찍지도 않는다.**
     · 연결도 read-only 로 연다(setReadOnly).

   쓰는 법 (Java 8, 드라이버는 WAR lib 의 mssql-jdbc) :
     javac -encoding UTF-8 -cp "<WAR>/WEB-INF/lib/mssql-jdbc-9.4.1.jre8.jar" -d . DbRead.java
     java  -cp ".;<WAR>/WEB-INF/lib/mssql-jdbc-9.4.1.jre8.jar" DbRead "SELECT TOP 5 * FROM TBL_WH_MST"
     java  -cp ... DbRead @wh          (미리 넣어 둔 조회 — 아래 SHORTCUTS)
     java  -cp ... DbRead @dc
     java  -cp ... DbRead @closing

   ⚠운영 DB 다. 조회도 무거운 것은 피한다(TOP 을 붙이거나 집계로).
   ===================================================================== */
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.util.*;
import java.util.regex.*;

public class DbRead {

    /* 자주 쓰는 조회 — 이름 앞에 @ 를 붙여 부른다 */
    static final Map<String,String> SHORTCUTS = new LinkedHashMap<String,String>();
    static {
        SHORTCUTS.put("wh",
            "SELECT WH_CD, COUNT(*) AS 원장행, SUM(CASE WHEN IO_GB IN ('I','R','A') THEN QTY ELSE -QTY END) AS 현재고 "
          + "FROM TBL_STOCK_LEDGER WHERE ACTION_YN='Y' GROUP BY WH_CD ORDER BY WH_CD");
        SHORTCUTS.put("whmst",
            "SELECT COMP_CD, WH_CD, WH_NM, DEFAULT_YN, USE_YN, SORT_ORD FROM TBL_WH_MST ORDER BY COMP_CD, SORT_ORD");
        SHORTCUTS.put("dc",
            "SELECT COMP_CD, DC_CD, DC_NM, GRP_NM, WH_CD, UPD_USER, UPD_DTTM FROM TBL_DC_MST ORDER BY COMP_CD, SORT_ORD");
        SHORTCUTS.put("closing",
            "SELECT CLOSE_YM, WH_CD, COUNT(*) AS 품목, SUM(END_QTY) AS 기말수량 FROM TBL_CLOSING_STOCK GROUP BY CLOSE_YM, WH_CD ORDER BY CLOSE_YM, WH_CD");
        SHORTCUTS.put("safe",
            "SELECT COUNT(*) AS 전체품목, SUM(CASE WHEN ISNULL(SAFE_STOCK,0) > 0 THEN 1 ELSE 0 END) AS 적정있음 "
          + "FROM TBL_PROD_MST WHERE ACTION_YN='Y'");
        SHORTCUTS.put("comp",
            "SELECT COMP_CD, COUNT(*) AS 원장행 FROM TBL_STOCK_LEDGER WHERE ACTION_YN='Y' GROUP BY COMP_CD");
    }

    /* 고치는 SQL 은 받지 않는다 — 실수로라도 운영 자료가 바뀌면 안 된다 */
    static final Pattern BANNED = Pattern.compile(
        "(?i)\\b(insert|update|delete|merge|truncate|drop|alter|create|grant|revoke|exec|execute|sp_|xp_|backup|restore|shutdown|into\\s+\\w+\\s+from)\\b");

    public static void main(String[] args) throws Exception {
        if (args.length == 0) { usage(); return; }
        String sql = args[0].trim();
        if (sql.startsWith("@")) {
            String k = sql.substring(1);
            if (!SHORTCUTS.containsKey(k)) { System.out.println("그런 이름이 없습니다 : " + k); usage(); return; }
            sql = SHORTCUTS.get(k);
        }
        String head = sql.replaceFirst("^\\s*(?i)(;|\\s)*", "");
        if (!(head.regionMatches(true, 0, "select", 0, 6) || head.regionMatches(true, 0, "with", 0, 4))) {
            System.out.println("거부 : SELECT(또는 WITH) 로 시작하는 조회만 됩니다."); return;
        }
        Matcher m = BANNED.matcher(sql);
        if (m.find()) { System.out.println("거부 : 고치는 낱말이 들어 있습니다 → " + m.group()); return; }
        if (sql.indexOf(';') >= 0 && sql.trim().indexOf(';') != sql.trim().length() - 1) {
            System.out.println("거부 : 한 번에 한 문장만."); return;
        }

        Map<String,String> ds = readDataSource();
        String pw = readPassword();
        if (pw == null) {
            System.out.println("비밀번호 파일을 못 찾았습니다 — <톰캣>/conf/konet-db.properties 의 konet.db.password");
            return;
        }
        System.out.println("접속 : " + ds.get("url").replaceAll("(?i)password=[^;]*", "password=***"));
        System.out.println("조회 : " + sql.replaceAll("\\s+", " "));
        System.out.println();

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection c = null; Statement st = null; ResultSet rs = null;
        try {
            c = DriverManager.getConnection(ds.get("url"), ds.get("username"), pw);
            c.setReadOnly(true);                 // 연결 자체를 읽기 전용으로
            c.setAutoCommit(true);
            st = c.createStatement();
            st.setQueryTimeout(60);
            rs = st.executeQuery(sql);
            print(rs);
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (st != null) try { st.close(); } catch (Exception e) {}
            if (c  != null) try { c.close();  } catch (Exception e) {}
        }
    }

    /** 접속 주소·계정은 앱 설정에서 그대로 읽는다(둘이 갈리지 않게) */
    static Map<String,String> readDataSource() throws IOException {
        String[] cand = {
            "src/main/resources/egovframework/spring/context-datasource.xml",
            "../../../src/main/resources/egovframework/spring/context-datasource.xml",
            "C:/Users/user/git/konet/konet_vsweb/src/main/resources/egovframework/spring/context-datasource.xml"
        };
        for (String p : cand) {
            File f = new File(p);
            if (!f.isFile()) continue;
            String x = new String(Files.readAllBytes(f.toPath()), StandardCharsets.UTF_8);
            int i = x.indexOf("jdbc:sqlserver:");
            if (i < 0) continue;
            int s = x.lastIndexOf("value=\"", i) + 7, e = x.indexOf('"', s);
            String url = x.substring(s, e);
            Matcher mu = Pattern.compile("name=\"username\"\\s+value=\"([^\"]*)\"").matcher(x.substring(e));
            String user = mu.find() ? mu.group(1) : "sa";
            Map<String,String> r = new HashMap<String,String>();
            r.put("url", url); r.put("username", user);
            return r;
        }
        throw new FileNotFoundException("context-datasource.xml 을 못 찾았습니다 — 저장소 뿌리에서 실행하세요.");
    }

    /** 비밀번호는 앱이 쓰는 그 파일에서만 읽는다. 저장소에 복사하지 않고, 화면에도 안 찍는다. */
    static String readPassword() throws IOException {
        String[] cand = {
            System.getProperty("konet.db.file", ""),
            "D:/egv/Servers/konet_vsweb-tomcat/conf/konet-db.properties",
            "D:/egv/Servers/konet_vsweb-vscode/conf/konet-db.properties"
        };
        for (String p : cand) {
            if (p == null || p.isEmpty()) continue;
            File f = new File(p);
            if (!f.isFile()) continue;
            Properties pr = new Properties();
            InputStream in = new FileInputStream(f);
            try { pr.load(in); } finally { in.close(); }
            String v = pr.getProperty("konet.db.password");
            if (v != null && !v.trim().isEmpty()) return v.trim();
        }
        return null;
    }

    static void print(ResultSet rs) throws SQLException {
        ResultSetMetaData md = rs.getMetaData();
        int n = md.getColumnCount();
        List<String[]> rows = new ArrayList<String[]>();
        String[] head = new String[n];
        for (int i = 1; i <= n; i++) head[i-1] = md.getColumnLabel(i);
        rows.add(head);
        int cnt = 0;
        while (rs.next() && cnt < 500) {
            String[] r = new String[n];
            for (int i = 1; i <= n; i++) { Object o = rs.getObject(i); r[i-1] = (o == null ? "NULL" : String.valueOf(o)); }
            rows.add(r); cnt++;
        }
        int[] w = new int[n];
        for (String[] r : rows) for (int i = 0; i < n; i++) w[i] = Math.max(w[i], width(r[i]));
        for (int k = 0; k < rows.size(); k++) {
            StringBuilder sb = new StringBuilder();
            String[] r = rows.get(k);
            for (int i = 0; i < n; i++) { sb.append(pad(r[i], w[i])); if (i < n-1) sb.append("  "); }
            System.out.println(sb.toString());
            if (k == 0) { StringBuilder u = new StringBuilder();
                for (int i = 0; i < n; i++) { for (int j = 0; j < w[i]; j++) u.append('-'); if (i < n-1) u.append("  "); }
                System.out.println(u.toString()); }
        }
        System.out.println();
        System.out.println("줄 = " + cnt + (cnt >= 500 ? " (500줄에서 끊음)" : ""));
    }
    /* 한글은 두 칸 폭으로 센다 — 안 그러면 표가 어긋난다 */
    static int width(String s) { int w = 0; for (int i = 0; i < s.length(); i++) w += (s.charAt(i) > 0x1100 ? 2 : 1); return w; }
    static String pad(String s, int w) { StringBuilder sb = new StringBuilder(s); for (int i = width(s); i < w; i++) sb.append(' '); return sb.toString(); }

    static void usage() {
        System.out.println("쓰는 법 : DbRead \"SELECT …\"   또는   DbRead @이름");
        System.out.println("미리 넣어 둔 이름 :");
        for (Map.Entry<String,String> e : SHORTCUTS.entrySet())
            System.out.println("  @" + e.getKey() + "  — " + e.getValue().replaceAll("\\s+", " ").substring(0, Math.min(90, e.getValue().replaceAll("\\s+", " ").length())) + "…");
        System.out.println();
        System.out.println("★SELECT 만 됩니다. 고치는 SQL 은 거부합니다(운영 DB).");
    }
}
