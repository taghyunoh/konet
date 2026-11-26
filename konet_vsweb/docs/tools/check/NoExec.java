import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.util.*;

/** SQL 을 «실행하지 않고» 서버가 문법·칸 이름만 검사하게 한다 — args: <sqlFile> [sqlFile …]
 *  SET NOEXEC ON = 배치를 컴파일만 하고 실행하지 않는다(SQL Server). 켜졌는지 먼저 확인한다(SELECT 1 이 결과를 안 주면 켜진 것) —
 *  확인이 안 되면 아무것도 보내지 않고 끝낸다. 덧붙여 자동 커밋을 끄고 끝에 ROLLBACK 한다(혹시라도 실행됐을 때의 두 번째 안전판). */
public class NoExec {
    public static void main(String[] a) throws Exception {
        Map<String,String> ds = DbRead.readDataSource();
        String pw = DbRead.readPassword();
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        try (Connection c = DriverManager.getConnection(ds.get("url"), ds.get("username"), pw)) {
            c.setAutoCommit(false);
            try (Statement st = c.createStatement()) {
                st.execute("SET NOEXEC ON");
                boolean rs = st.execute("SELECT 1 AS x");
                if (rs) { System.out.println("중단 : NOEXEC 가 켜지지 않았습니다 — 아무것도 보내지 않았습니다."); c.rollback(); return; }
                for (String f : a) {
                    String sql = new String(Files.readAllBytes(Paths.get(f)), StandardCharsets.UTF_8);
                    try { st.setQueryTimeout(60); st.execute(sql); System.out.println("문법 OK  " + Paths.get(f).getFileName()); }
                    catch (SQLException e) { System.out.println("오류     " + Paths.get(f).getFileName() + " : " + e.getMessage()); }
                }
                st.execute("SET NOEXEC OFF");
            } finally { c.rollback(); }
        }
    }
}
