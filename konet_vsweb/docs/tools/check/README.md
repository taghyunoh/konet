# 검사 도구 (2026-10-06)

서버를 띄우지 않고 고친 것을 확인하는 도구들. **세션 임시 폴더에 두었다가 하룻밤 사이 지워져 다시 만든 일이 있어 저장소로 옮겼다.**
경로는 이 PC 기준 절대 경로다(다른 PC 에서는 파일 맨 위 경로만 바꾼다).

| 파일 | 하는 일 | 쓰는 법 |
|---|---|---|
| `jspsyn.js` | JSP 인라인 `<script>` 문법 검사(JSP 표현식은 자리표로 바꿔 파싱) | `node docs/tools/check/jspsyn.js <a.jsp> <b.jsp>` |
| `MapperParse.java` | 매퍼 XML 을 **MyBatis 가 실제로 읽게** 하고, 이름 준 문장은 SQL 을 한 번 조립해 본다(include·if 가 깨지면 여기서 터진다) | 아래 |
| `sqlof.js` | 매퍼 문장 하나를 꺼내 `#{…}` 에 값을 넣은 SQL 로 만든다 → 읽기 전용 조회기(`docs/tools/dbread`)로 운영 DB 에 태운다 | `node docs/tools/check/sqlof.js selectPipelinePo compCd=W1234567` |
| `sim_pipeline.js` | 정보 현황 ▸ 진행 현황 화면 시뮬(36) | `node docs/tools/check/sim_pipeline.js` |
| `sim_salesquote.js` | 판매 등록 [📄 견적서] 가져오기 시뮬(26) | `node docs/tools/check/sim_salesquote.js` |

```bash
cd docs/tools/check && javac -encoding UTF-8 -nowarn -cp "D:/egv/Servers/konet_vsweb-vscode/lib/*" MapperParse.java && java -cp "D:/egv/Servers/konet_vsweb-vscode/lib/*;." MapperParse selectPipelinePo insertSalesTrxMst
```

⚠jsdom 은 이 저장소에 깔려 있지 않다 — 시뮬은 `C:/Users/user/git/winn/wnn_medcost/docs/tools/sim/node_modules/jsdom` 을 빌려 쓴다.
⚠jsdom 에서 `onclick="…"` 속성을 실행하려면 `runScripts: 'dangerously'` 여야 한다(`'outside-only'` 면 눌러도 아무 일이 없어 「단계를 눌러도 목록이 안 뜬다」로 오판한다).
⚠`sqlof.js` 로 만든 SQL 이 `WITH` 로 시작하면 그대로 넘긴다 — `SELECT … FROM ( … ) z` 로 감싸면 CTE 문법 오류가 난다.
