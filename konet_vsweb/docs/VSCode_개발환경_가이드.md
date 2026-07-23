# VS Code 개발환경 가이드 (konet_vsweb)

VS Code 설치 후 **서버 실행 · WAR 빌드 · Git 동기화**까지 한 번에 정리한 문서.
2026-07-23 실제 구축·검증한 내용 기준.

> **핵심 3줄**
> - 서버: 탐색기 사이드바 **SERVERS** 패널 → 우클릭 Start (Eclipse의 Servers 뷰와 동일)
> - WAR: 탐색기 사이드바 **MAVEN** → Favorites → ▶
> - Git: **소스 제어** 패널 → `⋯`(Pull) / 메시지+Commit / Sync Changes

---

## 0. 이 프로젝트의 전제

| 항목 | 값 | 비고 |
|---|---|---|
| 프로젝트 | `C:\Users\user\git\konet\konet_vsweb` | VS Code 전용 사본 |
| Git 저장소 | `C:\Users\user\git\konet` (**상위 폴더**) | `konet_web` 과 공용 |
| 원격 | `https://github.com/taghyunoh/konet.git` (Private) | 인증: `taghyunoh` + PAT |
| **JDK** | **`C:\Program Files\Java\jre-1.8`** | 이름은 jre 지만 실제 **JDK 8**. 11 이상 쓰면 로그인 실패(§6-2) |
| Maven | `D:\egv\apache-maven-3.8.4` | 설치본 아님 — Eclipse 내장 부품 조립(§4-3) |
| 톰캣 | `D:\egv\Servers\konet_vsweb-tomcat` | 8.5.66 전용 복사본 |
| 웹앱 JAR | `D:\egv\Servers\konet_vsweb-vscode\lib` | 113개 |
| HTTP / 셧다운 / 디버그 포트 | 9071 / 9013 / 9171 | Eclipse `konet_web` 은 9070 → **동시 실행 가능** |

`konet_web`(Eclipse용)과 `konet_vsweb`(VS Code용)은 **독립된 사본**이다.
한쪽 수정이 다른 쪽에 반영되지 않으므로 **고친 쪽에서 빌드**할 것.
두 곳에서 만든 WAR 는 같은 `pom.xml`·`.m2`·war-plugin 을 쓰므로 구조·파일명이 동일하다.
(2026-07-23 실측: 둘 다 89.3MB, 항목 1,289 vs 1,291 — 차이는 그 사이 추가/삭제된 소스 4개뿐)

---

## 1. 확장 설치 (최초 1회)

프로젝트를 열면 우측 하단에 권장 확장 알림이 뜬다(`.vscode/extensions.json`). **Install** 클릭.
안 뜨면 확장 탭에서 `@recommended` 검색.

| 확장 | 용도 |
|---|---|
| `vscjava.vscode-java-pack` | Java 언어지원·디버거·Maven 패널 |
| `redhat.vscode-community-server-connector` | **SERVERS 패널** (톰캣 시작/중지) |

터미널로 설치하려면:

```
"C:\Users\user\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension vscjava.vscode-java-pack
```

> **⚠ 설치 직후 반드시 확인** — Java 확장팩에 **`vscjava.migrate-java-to-azure`(Java 자동 업그레이드)** 가 딸려 온다.
> 이 확장이 사고를 냈다. §6-5 를 먼저 읽고 **비활성화할 것.**

---

## 2. 프로젝트 열기

**File → Open Folder** → `C:\Users\user\git\konet\konet_vsweb`

- 신뢰 확인창 → **Yes, I trust the authors**
- Restricted Mode 배너가 남아 있으면 **Manage → Trust**
- Java 확장이 `pom.xml` 을 읽어 의존성을 잡는 데 1~2분 걸린다(우측 하단 진행표시)

---

## 3. 서버 실행 — SERVERS 패널

탐색기(Explorer) 사이드바 **맨 아래 SERVERS** 섹션. 안 보이면 **View → Open View... → Servers**.

### 3-1. 서버 등록 (최초 1회)

1. `Community Server Connector` 우클릭(또는 **+**) → **Create New Server**
   - 처음 펼칠 때 RSP 실행모듈을 자동 다운로드한다(인터넷 필요, 수십 초)
2. **"No, use server on disk"** 선택
3. 폴더 → `D:\egv\Servers\konet_vsweb-tomcat`
4. `Apache Tomcat 8.5` 자동 감지 → Enter
5. **Server Name** 입력 (예: `konet_vsweb`) — 비우면 `Tomcat 8.5` 로 등록되고 **이름 변경 기능은 없다**(바꾸려면 Remove 후 재등록)
6. **`Required Attributes` 를 펼쳐** `server.home.dir` = `D:\egv\Servers\konet_vsweb-tomcat`
   - 접혀 있으면 값이 비어 Finish 가 안 눌린다
7. `Optional Attributes`
   - `vm.install.path` = `C:\Program Files\Java\jre-1.8` ← **JDK 8 필수**
   - `server.base.dir` = **비워둠** (넣으면 우리 `server.xml` 이 무시될 수 있음)
8. **Finish**

등록 후 우클릭 → **Edit Server** 에서 `server.http.port` 를 **9071** 로 고치고 `Ctrl+S`.
(기본값 8080 이라 그대로 두면 Open in Browser 가 엉뚱한 포트로 열린다)

### 3-2. 사용

서버 우클릭 → **Start / Stop / Restart / Debug**. 첫 기동 약 30초.
브라우저: http://localhost:9071/ · 로그: 우클릭 → **Show Output Channel**

**배포(Add Deployment)는 하지 않는다.** `server.xml` 의 Context 가 프로젝트 폴더를 직접 가리켜서 **WAR 없이** 실행된다.

- JSP: `src/main/webapp` → 저장 후 새로고침이면 반영
- 클래스: `target/classes` → Java 확장이 자동 컴파일. Debug 로 띄웠으면 핫스왑, 아니면 Restart

### 3-3. 대체 수단 (터미널)

`Ctrl+Shift+P` → `Tasks: Run Task` → **톰캣 시작 (konet_vsweb :9071)** / **톰캣 중지**
디버그는 **F5** → `톰캣 디버그 연결`.
SERVERS 패널과 **같은 톰캣**이므로 동시에 켜면 포트 충돌.

---

## 4. WAR 빌드 — MAVEN 패널

탐색기 사이드바 **MAVEN** → `konet_web` → **Favorites** → 항목 옆 **▶**

| 항목 | 명령 | 언제 |
|---|---|---|
| WAR 빌드 (오프라인) | `-o -DskipTests clean package` | **평소** |
| WAR 빌드 (의존성 갱신) | `-DskipTests clean package` | `pom.xml` 에 의존성 추가했을 때만 |

결과물 **`target\konet_web-1.0.0.war`** (약 89MB, 45초~1분).
artifactId 가 `konet_web` 그대로라 **기존 배포 파일명과 동일** → 서버 배포 절차 변경 불필요.

`Ctrl+Shift+B` (Tasks의 **WAR 빌드**)로도 같은 빌드가 돈다.

### 4-1. 터미널에서 직접

```
set JAVA_HOME=C:\Program Files\Java\jre-1.8
D:\egv\apache-maven-3.8.4\bin\mvn.cmd -o -DskipTests clean package
```

### 4-2. 배포 원칙 (CLAUDE.md 와 동일)

- **JSP만 수정** → WAR 재빌드 불필요. 서버의 해당 JSP 파일만 교체
- **`.java` / SQL XML 수정** → **WAR 재빌드 + 톰캣 재기동 필수**

### 4-3. Maven 이 별도 설치본이 아니다 (재구성 시 필독)

이 PC 에 Maven 이 설치돼 있지 않아, **Eclipse(eGovFrame) 내장 m2e Maven 3.8.4 부품을 모아 조립**했다(다운로드 없음).

- `lib\` ← `D:\egv\eGovFrameDev-4.1.0-64bit\eclipse\plugins\org.eclipse.m2e.maven.runtime_*\jars\*.jar` + `...slf4j.simple_*\jars\*.jar`
- `bin\m2.conf`, `bin\mvn.cmd` — 직접 작성
- **추가로 채워야 하는 3개** (m2e 는 OSGi 런타임에서 받으므로 jars 폴더에 없음):

| 파일 | 출처 | 주의 |
|---|---|---|
| `slf4j-api-1.7.36.jar` | 로컬 `.m2` 저장소 | **Eclipse 의 `org.slf4j.api_*.jar` 는 서명돼 있어 쓰면 `signer information does not match` 오류** |
| `javax.inject-1.jar` | 로컬 `.m2` 저장소 | 없으면 `NoClassDefFoundError: javax/inject/Provider` |
| `guava-30.1.0.jar` | `eclipse\plugins\com.google.guava_30.1.0.*.jar` | 없으면 `NoClassDefFoundError: com/google/common/collect/ImmutableSet` |

`settings.json` 의 `maven.executable.path` 가 이 경로를 가리킨다. 정식 Maven 설치 시 그 값만 바꾸면 된다.

---

## 5. Git — pull / commit / push

### 5-1. 소스 제어 패널

좌측 활동 표시줄 **가지 모양 아이콘**.

처음 열면 *"A Git repository was found in the workspace..."* 안내가 뜬다 —
**저장소가 상위 폴더(`konet`)** 이기 때문이며 정상이다. **Open Repository** 클릭.
(`settings.json` 의 `git.openRepositoryInParentFolders: always` 로 이후 자동 열림)

### 5-2. 순서

| 시점 | 동작 | 위치 |
|---|---|---|
| 작업 **시작 전** | **Pull** (받기) | `SOURCE CONTROL` 우측 `⋯` → Pull |
| 파일 수정 후 | `Ctrl+S` 저장 | 편집기 (`Ctrl+K S` = 전체 저장) |
| 저장 후 | 메시지 입력 → **Commit** | 패널 상단 입력칸 |
| 커밋 후 | **Sync Changes** (올리기) | Commit 버튼이 바뀜 |

**Pull 은 내 수정 여부와 무관하게 항상 실행 가능**하다(원격 내용을 받는 기능).

가장 간편한 방법: **맨 아래 상태 표시줄의 `main` 옆 동기화 아이콘(⟳)** — pull + push 한 번에.
옆의 `↑2` `↓1` 숫자는 각각 올릴 커밋 / 받을 커밋 개수.

### 5-3. CLI (Eclipse EGit 오류 시 대체)

```
git -C C:\Users\user\git\konet pull
git -C C:\Users\user\git\konet add -A
git -C C:\Users\user\git\konet commit -m "작업 내용"
git -C C:\Users\user\git\konet push origin main
```

### 5-4. 커밋 전 필수 확인 2가지

1. **브랜치가 `main` 인가** — 좌측 하단 상태 표시줄. `appmod/...` 등 낯선 브랜치면 §6-5
2. **파일 목록에 어느 폴더가 올라와 있나** — 저장소가 `konet` 전체라 **`konet_web`(Eclipse용) 변경까지 함께 커밋**된다

### 5-5. 자주 겪는 것

- **"There are no staged changes to commit. Would you like to stage all..."**
  → 평소엔 **Yes** (전체 스테이징 후 커밋). Git 원래 방식이 `add` 한 것만 커밋하기 때문에 묻는 것
- **커밋 메시지 입력칸에 타이핑이 안 됨**
  → `COMMIT_EDITMSG` 탭이 열려 있어서 잠긴 것. **그 탭을 닫으면** 풀린다.
  (`git.useEditorAsCommitInput: false` 로 꺼 뒀으므로 재발하지 않음)

---

## 6. 함정 모음

### 6-1. 웹앱 JAR 3개 제외

`D:\egv\Servers\konet_vsweb-vscode\lib` 에서 아래 3개를 **반드시 제외**한다.
두면 기동은 되지만 **첫 화면 요청에서 500** — `ClassNotFoundException: com.sun.el.ExpressionFactoryImpl`.
컨테이너가 제공하는 API 를 웹앱 JAR 가 덮어쓰기 때문이며, 컴파일 전용 스텁이라 런타임엔 불필요하다.

- `javaee-api-7.0.jar` (→ `lib-excluded\` 로 이동해 둠)
- `servlet-api-2.5.jar`
- `jsp-api-2.1.jar`

의존성 갱신 시:

```
robocopy C:\Users\user\git\konet\konet_vsweb\target\konet_web-1.0.0\WEB-INF\lib D:\egv\Servers\konet_vsweb-vscode\lib /E /XF javaee-api-7.0.jar servlet-api-2.5.jar jsp-api-2.1.jar
```

### 6-2. JDK 11 이상이면 **로그인만** 실패

기동도 되고 화면도 다 뜨는데 로그인에서만 500 — 화면엔 *"로그인 요청 중 오류가 발생했습니다"*.
서버 로그의 실제 원인:

```
java.lang.NoClassDefFoundError: javax/xml/bind/DatatypeConverter
```

`javax.xml.bind`(JAXB)는 Java 9에서 분리, **11에서 제거**됐는데 로그인 처리가 이를 쓴다.
이 프로젝트는 Java 8 전용(`pom.xml` `source/target 1.8`)이므로 **반드시 JDK 8**.

- SERVERS 패널: Edit Server → `vm.install.path` = `C:\Program Files\Java\jre-1.8`
- Tasks: `tasks.json` 의 `JAVA_HOME`
- Maven: `settings.json` 의 `maven.terminal.customEnv`

> `javaee-api-7.0.jar` 를 lib 에 되돌리면 이 클래스는 채워지지만 **EL 충돌로 모든 화면이 500**(§6-1)이 된다. 그 방향은 답이 아니다.

### 6-3. 콘솔 한글 깨짐 — 실행 방식마다 인코딩이 **반대**

| 실행 방식 | 쓰는 설정 | ConsoleHandler.encoding |
|---|---|---|
| SERVERS 패널(RSP OUTPUT) | `conf/logging.properties` | **EUC-KR** |
| Tasks(터미널) | `conf/logging-utf8.properties` | **UTF-8** |

터미널 쪽은 `tasks.json` 의 `CATALINA_OPTS` 에서
`-Djava.util.logging.config.file=...logging-utf8.properties` 로 갈아끼우고 `-Dfile.encoding=UTF-8` 도 준다.

**판별법**: log4j2 줄(`DEBUG [org.egovframe...]`)과 톰캣 줄(`INFO [main] org.apache...`) 중 **어느 쪽이 깨지는지** 본다.
톰캣 줄만 깨지면 ConsoleHandler 가 안 맞는 것, log4j2 줄만 깨지면 `-Dfile.encoding` 이 안 맞는 것.
로그 **파일**(`logs\*.log`)은 어느 경우든 UTF-8 이라 무관.

### 6-4. 셧다운 포트가 잡혀 있으면 조용히 죽는다

이전 톰캣이 완전히 안 죽은 상태에서 새로 띄우면 **HTTP 포트는 잡히고 기동 로그도 정상**인데
9013 바인딩 실패(`BindException`)로 **곧바로 자기 자신을 종료**한다. "시작됐는데 응답 없음" 으로 보인다.

```
Get-NetTCPConnection -State Listen -LocalPort 9013,9071 | Select-Object LocalPort,OwningProcess
```

### 6-5. ⚠ Java 자동 업그레이드 확장 — **소스 삭제 사고**

**2026-07-23 실제 발생.** Java 확장팩에 딸려 오는 **`vscjava.migrate-java-to-azure`**
("Java 런타임 최신 LTS 업그레이드")가 **auto-execution mode** 로 실행되어:

- `konet_vsweb` 의 **`src`·`pom.xml`·`docs`·`sql`·`CLAUDE.md`·`.vscode` 가 전부 삭제**됨
- `C:\Users\user\.jdk\jdk-25.0.2`, `C:\Users\user\.maven\maven-3.10.0-rc-1` 설치
- `appmod/java-upgrade-<timestamp>` 브랜치 생성 후 체크아웃
- 프로젝트 안에 `.github/modernize/java-upgrade/` 작업폴더 생성
- **VS Code 를 껐다 켜자 자동 재시작**됨 (작업폴더가 남아 있으면 이어서 실행)

**이 프로젝트에 Java 업그레이드 자동화를 돌리면 안 된다.** §6-2 와 같은 이유로 Java 25 에서는 기동조차 안 된다.

**예방**: 확장 탭에서 `migrate-java-to-azure` 검색 → **Disable**(또는 Uninstall).

**징후 / 복구**:

| 징후 | 확인 |
|---|---|
| 브랜치가 `appmod/...` | `git branch --show-current` |
| 프로젝트에 `.github/modernize/` 존재 | 작업폴더 — 밖으로 옮길 것 |
| 탐색기엔 파일이 보이는데 실제로 없음 | 화면이 갱신 안 된 것. `ls` 로 확인 |

복구 순서 (2026-07-23 실제 수행):

1. **먼저 확장/작업을 중지** — 안 멈추면 복구해도 다시 지워진다
2. `.github` 를 프로젝트 밖으로 이동 (자동 재시작 차단)
3. 원본 `konet_web` 에서 소스 복원
   `robocopy C:\Users\user\git\konet\konet_web C:\Users\user\git\konet\konet_vsweb /E /XD bin target .git`
4. `.project` 의 `<name>` 과 `.settings\org.eclipse.wst.common.component` 를 `konet_vsweb` 로 수정
5. `.vscode\*.json` 재작성
6. 브랜치 복귀 — 그 브랜치의 **내 커밋은 살려서** 옮긴다
   `git switch main && git merge --ff-only appmod/java-upgrade-<timestamp>`
7. WAR 빌드로 검증

> 사고 당시 에이전트 작업폴더는 `C:\Users\user\git\konet\_java-upgrade-agent-backup-20260723\` 로 옮겨 보관 중.
> 톰캣·Maven·웹앱 JAR 는 `D:\egv` 아래라 **영향 없었다** — 설정을 프로젝트 밖에 둔 것이 결과적으로 유효했다.

---

## 7. 새 PC에서 처음 세팅하는 순서

1. GitHub 에서 clone — `git clone https://github.com/taghyunoh/konet.git` (PAT 인증)
2. VS Code 설치 → 프로젝트 폴더 열기 → 권장 확장 설치 → **`migrate-java-to-azure` 비활성화**(§6-5)
3. JDK 8 확인 (`C:\Program Files\Java\jre-1.8`)
4. Maven 준비 — 정식 설치하거나 §4-3 방식으로 조립 후 `settings.json` 의 `maven.executable.path` 수정
5. 톰캣 복사본 만들기 — `apache-tomcat-8.5.66` 복사 → `conf\server.xml` 에 포트(9071/9013)와 프로젝트 Context 지정, `conf\logging.properties` 준비
6. 웹앱 JAR 채우기 — §6-1 의 3개 제외
7. SERVERS 패널에 등록(§3-1) → Start → http://localhost:9071/ 로그인까지 확인
8. WAR 빌드 1회 검증(§4)
