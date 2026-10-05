import java.io.*;
import java.util.*;
import org.apache.ibatis.builder.xml.*;
import org.apache.ibatis.mapping.*;
import org.apache.ibatis.session.Configuration;

/* 매퍼 XML 을 MyBatis 가 실제로 읽게 해 본다(정형성 + include·동적 SQL 조립까지) — 서버 기동 없이.
   설정(sql-mapper-config.xml)의 별칭을 먼저 읽고, 매퍼는 «src 의 파일»을 직접 넘긴다(target/classes 는 옛 것일 수 있다).
   새로 넣은 문장은 빈 값으로 SQL 을 한 번 조립해 본다(include·if 가 깨지면 여기서 터진다). */
public class MapperParse {
  public static void main(String[] a) throws Exception {
    String root = "C:/Users/user/git/konet/konet_vsweb/src/main/resources/egovframework/sqlmap/";
    Configuration cfg;
    try (InputStream in = new FileInputStream(root + "config/sql-mapper-config.xml")) {
      XMLConfigBuilder cb = new XMLConfigBuilder(in);
      cfg = cb.parse();
    }
    String mf = root + "mapper/User_SQL.xml";
    try (InputStream in = new FileInputStream(mf)) {
      new XMLMapperBuilder(in, cfg, mf, cfg.getSqlFragments()).parse();
    }
    Set<String> seen = new HashSet<String>();
    int n = 0, bad = 0;
    for (Object o : cfg.getMappedStatements()) {
      if (!(o instanceof MappedStatement)) continue;
      MappedStatement ms = (MappedStatement) o;
      if (!seen.add(ms.getId())) continue;
      n++;
      if (a.length > 0) {
        String sid = ms.getId().substring(ms.getId().lastIndexOf('.') + 1);
        if (Arrays.asList(a).contains(sid)) {
          try {
            Map<String,Object> p = new HashMap<String,Object>();
            p.put("compCd", "W1234567"); p.put("stage", "PO"); p.put("frDt", ""); p.put("toDt", ""); p.put("findData", "");
            BoundSql bs = ms.getBoundSql(p);
            System.out.println("  조립 OK " + sid + " (" + bs.getSql().length() + "자, 자리표 " + bs.getParameterMappings().size() + ")");
          } catch (Exception e) { bad++; System.out.println("  ✗ 조립 실패 " + sid + " : " + e.getMessage()); }
        }
      }
    }
    System.out.println("statements parsed=" + n + " bad=" + bad);
  }
}
