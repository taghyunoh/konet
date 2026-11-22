import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.util.*;
import java.util.regex.*;

/* 읽기 전용 — prep.js 가 만든 「?」 SQL 을 앱과 같은 PreparedStatement(문자열 매개변수)로 돌려 시간·줄 수만 잰다.
   java SqlTime <file.sql> [반복]   · SELECT/WITH 만 받는다 */
public class SqlTime {
  public static void main(String[] a) throws Exception {
    String raw = new String(Files.readAllBytes(Paths.get(a[0])), StandardCharsets.UTF_8);
    int nl = raw.lastIndexOf('\n'); String sql = raw.substring(0, nl).trim(); String[] ps = raw.substring(nl + 1).isEmpty() ? new String[0] : raw.substring(nl + 1).split("\u0001", -1);
    String head = sql.replaceAll("^[\\s;]+", "").toUpperCase();
    if (!(head.startsWith("SELECT") || head.startsWith("WITH") || head.startsWith(";WITH") || head.startsWith("SET NOCOUNT ON"))) { System.out.println("SELECT 만"); return; }
    String up = " " + head.replaceAll("#[A-Z_0-9]+", "#T").replaceAll("CREATE (CLUSTERED |NONCLUSTERED )?INDEX [A-Z_0-9]+ ON #T", "IDX #T") + " "; if (up.matches("(?s).*\b(UPDATE|DELETE|MERGE|TRUNCATE|ALTER|CREATE|EXEC|INSERT)\b.*")) { System.out.println("고치는 문장 거부"); return; }
    int rep = a.length > 1 ? Integer.parseInt(a[1]) : 1;
    String ctx = new String(Files.readAllBytes(Paths.get("C:/Users/HYUN/git/konet/konet_vsweb/src/main/resources/egovframework/spring/context-datasource.xml")), StandardCharsets.UTF_8);
    Matcher mu = Pattern.compile("name=\"url\"\\s+value=\"([^\"]+)\"").matcher(ctx); mu.find();
    Matcher mn = Pattern.compile("name=\"username\"\\s+value=\"([^\"]+)\"").matcher(ctx); mn.find();
    Properties pp = new Properties(); try (java.io.InputStream in = Files.newInputStream(Paths.get("C:/egv/Servers/konet_vsweb-tomcat/conf/konet-db.properties"))) { pp.load(in); }
    try (Connection c = DriverManager.getConnection(mu.group(1), mn.group(1), pp.getProperty("konet.db.password"))) {
      c.setReadOnly(true);
      for (int k = 0; k < rep; k++) {
        long t0 = System.nanoTime(); int n = 0; long hs = 0, ho = 7;
        try (PreparedStatement st = c.prepareStatement(sql)) {
          st.setQueryTimeout(120);
          for (int i = 0; i < ps.length; i++) { if ("\u0000".equals(ps[i])) st.setString(i + 1, null); else st.setString(i + 1, ps[i]); }
          try (ResultSet rs = st.executeQuery()) { int cc = rs.getMetaData().getColumnCount(); while (rs.next()) { n++; StringBuilder sb = new StringBuilder(); for (int c2 = 1; c2 <= cc; c2++) { sb.append(rs.getString(c2)).append((char)1); } int h = sb.toString().hashCode(); hs += h; ho = ho * 31 + h; } }
        }
        System.out.println("줄 " + n + " · 내용 " + Long.toHexString(hs) + " · 차례 " + Long.toHexString(ho) + " · " + ((System.nanoTime() - t0) / 1000000) + "ms");
      }
    }
  }
}
