import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.util.*;
import java.util.regex.*;

/** 임시 표(#)만 만드는 읽기 전용 스크립트 시간 재기 — args: <sqlFile> [반복=2] [이름]
 *  허용 : SELECT · WITH · SET NOCOUNT · IF OBJECT_ID('tempdb..#X') ... DROP TABLE #X · SELECT ... INTO #X
 *  거부 : INSERT · UPDATE · DELETE · MERGE · ALTER · EXEC · CREATE · TRUNCATE, 그리고 # 이 아닌 표에 대한 INTO / DROP */
public class TmpTime2 {
    public static void main(String[] a) throws Exception {
        String sql = new String(Files.readAllBytes(Paths.get(a[0])), StandardCharsets.UTF_8);
        int n = a.length > 1 ? Integer.parseInt(a[1]) : 2;
        String low = sql.toLowerCase();
        /* 임시 표(#)에 인덱스를 만드는 문장만 허용 — 실제 표는 여전히 못 건드린다 */
        low = low.replaceAll("create\\s+(unique\\s+)?(clustered\\s+|nonclustered\\s+)?index\\s+\\w+\\s+on\\s+#\\w+", " ");
        if (low.matches("(?s).*\\b(insert|update|delete|merge|alter|exec|execute|create|truncate)\\b.*")) { System.out.println("거부: 고치는 낱말"); return; }
        Matcher m1 = Pattern.compile("(?i)\\binto\\s+([#\\w.\\[\\]]+)").matcher(sql);
        while (m1.find()) if (!m1.group(1).startsWith("#")) { System.out.println("거부: INTO " + m1.group(1)); return; }
        Matcher m2 = Pattern.compile("(?i)\\bdrop\\s+table\\s+([#\\w.\\[\\]]+)").matcher(sql);
        while (m2.find()) if (!m2.group(1).startsWith("#")) { System.out.println("거부: DROP " + m2.group(1)); return; }
        Map<String,String> ds = DbRead.readDataSource();
        String pw = DbRead.readPassword();
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        File pf = new File(a[0] + ".params");
        List<String> pv = pf.isFile() ? Files.readAllLines(pf.toPath(), StandardCharsets.UTF_8) : null;
        try (Connection c = DriverManager.getConnection(ds.get("url"), ds.get("username"), pw)) {
            for (int i = 0; i < n; i++) {
                long t0 = System.nanoTime(); int rows = 0; long hash = 0; Map<String,Integer> cnt = new TreeMap<>();
                try (PreparedStatement st = c.prepareStatement(sql)) {
                    st.setQueryTimeout(120);
                    if (pv != null) { int k = 0; for (String v : pv) { k++; if (v.isEmpty()) st.setNull(k, Types.VARCHAR); else st.setString(k, v); } }
                    boolean isRs = st.execute();
                    while (true) {
                        if (isRs) {
                            try (ResultSet rs = st.getResultSet()) {
                                int cc = rs.getMetaData().getColumnCount();
                                while (rs.next()) { rows++; long rh = 0; for (int k = 1; k <= cc; k++) { String v = rs.getString(k); if (v != null) for (char ch : v.toCharArray()) rh = rh * 31 + ch; rh = rh * 31 + 7; }
                                    rh ^= (rh >>> 29); rh *= 0x9E3779B97F4A7C15L; hash += rh;
                                    String key = rs.getString(1) + "/" + rs.getString(2); cnt.merge(key, 1, Integer::sum); }
                            }
                        } else if (st.getUpdateCount() == -1) break;
                        isRs = st.getMoreResults();
                    }
                }
                System.out.println((a.length > 2 ? a[2] + " " : "") + "run" + (i + 1) + " " + (System.nanoTime() - t0) / 1000000 + "ms rows=" + rows + " hash=" + Long.toHexString(hash) + " " + cnt);
            }
        }
    }
}
