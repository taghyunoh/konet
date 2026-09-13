# 여러 PC 작업 규칙 (konet)

PC 여러 대에서 같은 저장소(`https://github.com/taghyunoh/konet.git`)와 같은 DB 를 쓴다.
**새 PC 를 처음 세팅하는 순서**는 [konet_vsweb/docs/VSCode_개발환경_가이드.md](konet_vsweb/docs/VSCode_개발환경_가이드.md) §7 —
이 문서는 **여러 PC 를 오가며 작업할 때 어긋나지 않게 하는 규칙**만 적는다. (2026-09-14 작성)

> **핵심 3줄**
> 1. 브랜치는 **`main` 하나** — 화면 맨 아래 상태 표시줄에서 확인
> 2. 작업 **시작 전 pull**, 작업 **끝나면 commit + push** (다른 PC 로 옮기기 전에 반드시 push)
> 3. pull 받은 뒤 Java·SQL XML 이 바뀌었으면 **두 앱 모두 컴파일**

---

## 1. 매일 규칙

| 시점 | 할 일 | 명령 |
|---|---|---|
| 작업 시작 전 | 브랜치가 `main` 인지 확인 → **pull** | `git -C <저장소> status -sb` → `git -C <저장소> pull` |
| 작업 끝 | **commit + push** | `git -C <저장소> add -A` → `commit -m "내용"` → `push origin main` |
| 다른 PC 로 옮길 때 | 지금 PC 에서 **push 까지 끝낸 뒤** 옮긴다 | |

`<저장소>` = 그 PC 의 `...\git\konet` (상위 폴더. `konet_vsweb` 이 아니다).

### 이런 일이 실제로 있었다

- **2026-09-14 「다른 PC 에서 하고 pull 했는데 적용이 안 돼요」** — 이 PC 가 `konet-vsapp` 브랜치에 있었고
  다른 PC 는 `main` 에 올렸다. pull 을 해도 받을 게 없었다. → `git checkout main` 후 pull 로 해결.
  ⇒ **pull 전에 브랜치부터 본다.**
- **2026-09-13 11:45 매입등록 화면이 하루 전 판으로 덮여 커밋됐다**(`eb66381`) — 한 PC 의 옛 파일이 그대로 올라가
  단가·비고가 안 들어오는 증상으로 나타났다.
  ⇒ **같은 파일을 두 PC 에서 동시에 고치지 않는다.** 특히 큰 파일일수록 잘 부딪힌다 :
  `logistics_demo2.jsp` · `User_SQL.xml` · `UserController.java` · `salesReg.jsp` · `purchaseReg.jsp` · `CLAUDE.md`

### push 가 거절될 때 (`rejected`, `fetch first`)

다른 PC 가 먼저 올린 것이 있다는 뜻이다. **pull 먼저 → 다시 push.**
pull 중 **충돌(conflict)** 이 나면 짐작으로 고치지 말고 어느 PC 의 작업이 맞는지 확인한 뒤 정리한다.

---

## 2. pull 받은 뒤 반영하는 법

무엇이 바뀌었는지는 `git -C <저장소> log --stat -5` 또는 소스 제어 패널에서 본다.

| 바뀐 것 | 할 일 |
|---|---|
| JSP · JS · CSS | 브라우저 **Ctrl+F5** (톰캣이 `src/main/webapp` 을 직접 본다) |
| `*.java` · `User_SQL.xml` | **두 앱 모두** `mvn -o compile` — 톰캣을 켜 둔 채로 두면 스스로 다시 올라온다(수십 초). §4 의 server.xml 설정이 되어 있어야 한다 |
| `sql/*.sql` (DDL) | **DB 는 모든 PC 가 같이 쓴다** → 다른 PC 에서 이미 돌렸는지 먼저 확인. 한 번만 돌린다 |
| `pom.xml` (의존성) | 온라인 빌드(`-DskipTests clean package`) 후 웹앱 JAR 폴더 갱신 — 가이드 §6-1 |

```
set JAVA_HOME=C:\Program Files\Java\jre-1.8
C:\egv\apache-maven-3.8.4\bin\mvn.cmd -o -q compile -f <저장소>\konet_vsweb\pom.xml
C:\egv\apache-maven-3.8.4\bin\mvn.cmd -o -q compile -f <저장소>\konet_vsapp\pom.xml
```

⚠ **두 앱(konet_vsweb 9071 · konet_vsapp 9072)은 완전히 따로인 사본**이다. Java·SQL 을 한쪽만 고치면 조용히 어긋난다.

---

## 3. PC 마다 따로인 것 · 모두 같은 것

| 구분 | 무엇 | 비고 |
|---|---|---|
| **모두 같다** | 소스(git) | pull/push 로 맞춘다 |
| | DB (`saynice.co.kr` KOLGSDB) | DDL 은 한 PC 에서 한 번만 |
| **PC 마다 따로** (git 밖) | 톰캣 `conf\server.xml` | §4 — 그 PC 의 프로젝트 경로를 가리킨다 |
| | `.vscode\settings.json` · `tasks.json` | `.vscode-sample\` 에서 복사해 경로만 고친다 |
| | Maven · JDK · `C:\egv` 정션 | 가이드 §0 · §7 |
| | **브라우저에 저장되는 화면 설정** | 자주 쓰는 메뉴 · 택배 「출력됨」 기록 · 칸 폭 · 표 높이 · 글자 크기 · 팝업 위치 — **PC(브라우저)마다 다른 게 정상** |

---

## 4. 톰캣 server.xml — 이 설정이 있어야 「컴파일만 하면 반영」된다

`C:\egv\Servers\konet_vsweb-tomcat\conf\server.xml` 의 `<Host>` 안 (`<사용자>` 는 그 PC 의 윈도우 사용자 이름):

```xml
<Context docBase="C:/Users/<사용자>/git/konet/konet_vsweb/src/main/webapp" path="" reloadable="true">
  <Resources>
    <PostResources base="C:/Users/<사용자>/git/konet/konet_vsweb/target/classes"
                   className="org.apache.catalina.webresources.DirResourceSet" webAppMount="/WEB-INF/classes"/>
    <PostResources base="C:/egv/Servers/konet_vsweb-vscode/lib"
                   className="org.apache.catalina.webresources.DirResourceSet" webAppMount="/WEB-INF/lib"/>
  </Resources>
</Context>
```

konet_vsapp 은 같은 꼴에서 `konet_vsweb` → `konet_vsapp` 로 바꾼다.

| 앱 | 톰캣 폴더 | HTTP / 셧다운 / 디버그 포트 |
|---|---|---|
| konet_vsweb (PC 웹) | `C:\egv\Servers\konet_vsweb-tomcat` | 9071 / 9013 / 9171 |
| konet_vsapp (모바일) | `C:\egv\Servers\konet_vsapp-tomcat` | 9072 / 9014 / 9172 |

- `reloadable="true"` + `target/classes` 연결 → 클래스가 바뀌면 톰캣이 스스로 다시 올라온다(로그에 「컨텍스트를 다시 로드」).
- 이 설정이 없는 PC 는 컴파일 후 **톰캣 재기동**이 필요하다.
- 도구가 `D:\egv` 에 있는 PC 는 `C:` 대신 `D:` 로 쓰거나 `mklink /J C:\egv D:\egv` 정션을 만든다(가이드 §0).

---

## 5. 줄바꿈 — `.gitattributes` 가 맞춰 준다

- 저장소 맨 위 `.gitattributes` 가 **저장소 안 = LF, 작업 폴더 = CRLF** 로 고정한다. PC 의 git 설정과 관계없다.
- 이 파일이 없던 때에는 설정이 다른 PC 에서 한 줄만 고쳐도 **파일 전체가 바뀐 것**으로 잡힐 수 있었다.
- ⚠ 소스를 `sed -i` · `perl -pi` 로 고치지 말 것 — 줄바꿈이 통째로 바뀐다.
- 한 줄만 고쳤는데 수천 줄이 바뀐 것으로 나오면 : `git -C <저장소> diff --stat` 로 확인하고 커밋하지 말 것.

---

## 6. 주의 — 비밀번호 파일

`src/main/resources/mail.properties` 에 메일 계정 비밀번호가 들어간 채로 저장소에 올라가 있다(파일 주석은 「저장소에는 빈 채로」).
PC 가 늘수록 그 파일도 같이 퍼진다. 운영 서버는 톰캣 실행옵션 `-Dmail.smtp.password=` 가 파일보다 우선이다.

---

## 7. 「pull 했는데 안 바뀐다」 점검 순서

1. 브랜치가 `main` 인가 — `git -C <저장소> status -sb` 첫 줄이 `## main...origin/main`
2. 정말 받았나 — `git -C <저장소> log --oneline -3` 에 다른 PC 의 커밋이 보이는가
3. Java·SQL XML 이 바뀌었으면 두 앱 컴파일했나 (§2)
4. 브라우저 **Ctrl+F5** 했나
5. 새 DDL 이 있으면 DB 에 들어가 있나 (§2)
