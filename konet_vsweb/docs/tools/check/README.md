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
| `mapper_audit.js` | 아래 표 참고 | `node docs/tools/check/mapper_audit.js count` |

```bash
cd docs/tools/check && javac -encoding UTF-8 -nowarn -cp "D:/egv/Servers/konet_vsweb-vscode/lib/*;../../../target/classes" MapperParse.java && java -cp "D:/egv/Servers/konet_vsweb-vscode/lib/*;../../../target/classes;." MapperParse selectPipelinePo insertSalesTrxMst
```

⚠jsdom 은 이 저장소에 깔려 있지 않다 — 시뮬은 `C:/Users/user/git/winn/wnn_medcost/docs/tools/sim/node_modules/jsdom` 을 빌려 쓴다.
⚠jsdom 에서 `onclick="…"` 속성을 실행하려면 `runScripts: 'dangerously'` 여야 한다(`'outside-only'` 면 눌러도 아무 일이 없어 「단계를 눌러도 목록이 안 뜬다」로 오판한다).
⚠`sqlof.js` 로 만든 SQL 이 `WITH` 로 시작하면 그대로 넘긴다 — `SELECT … FROM ( … ) z` 로 감싸면 CTE 문법 오류가 난다.
| `mapper_audit.js` | ① `count` 모든 INSERT 의 **칸 수 = 값 수** ② `diff <옛.xml>` 옛 판과 문장 단위로 견주어 **바뀐 문장 id** 목록 — javac·XML·MyBatis 파싱이 못 잡는 것을 잡는다 | `node docs/tools/check/mapper_audit.js count` |

⚠⚠**[2026-10-06 사고] 패치 도우미 `sub1` 이 `s///`(g 없음)라 «첫 번째로 맞는 곳»을 바꾸고 1 을 돌려줬다** — 같은 글이 여러 문장에 있으면 엉뚱한 문장이 바뀐다.
견적 연결 값 두 개가 판매가 아니라 **매입 INSERT** 에 들어가 운영에서 판매·매입 **새 전표 저장이 둘 다 실패**했다(판매 「Failed to fetch」).
⇒ 앞으로 패치는 ①**문장 블록을 먼저 잘라 그 안에서만** 고치고 ②바뀐 곳을 **`s///g` 로 세어** 정확히 1 인지 본다 ③끝나면 `mapper_audit.js diff` 로 **의도한 문장만** 바뀌었는지, `count` 로 INSERT 칸·값을 본다.
