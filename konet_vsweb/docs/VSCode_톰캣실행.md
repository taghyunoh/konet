# VS Code 톰캣 실행 · WAR 빌드 (konet_vsweb)

## 실행 — SERVERS 패널 (Eclipse의 Servers 뷰와 같은 방식)

좌측 **탐색기(Explorer)** 사이드바 아래 **SERVERS** 패널에서 서버를 우클릭해 **Start / Stop / Restart / Debug** 한다.

### 최초 1회 등록

1. `Community Server Connector` 우클릭(또는 **+**) → **Create New Server**
2. **"No, use server on disk"** 선택
3. 폴더 → `D:\egv\Servers\konet_vsweb-tomcat`
4. 감지된 `Apache Tomcat 8.5` 확인 → 이름 입력
5. `Required Attributes` 를 펼쳐 `server.home.dir` = `D:\egv\Servers\konet_vsweb-tomcat`
6. `Optional Attributes` → `vm.install.path` = `C:\Program Files\Java\jre-1.8` (**JDK 8 필수**, 아래 함정 참조), `server.base.dir` 은 **비워둠**
7. Finish → 서버 우클릭 → **Start** → http://localhost:9071/

등록 후 **Edit Server** 로 `server.http.port` 를 `9071` 로 고쳐 저장하면 우클릭 → Open in Browser 가 제대로 열린다(기본값 8080).

**배포(Add Deployment)는 하지 않는다.** `server.xml` 에 프로젝트를 가리키는 Context 가 이미 있어서 Start 만 하면 서비스된다.

### 대체 수단 (터미널)

`Ctrl+Shift+P` → `Tasks: Run Task` → **톰캣 시작 (konet_vsweb :9071)** / **톰캣 중지**. 디버그는 **F5** → `톰캣 디버그 연결`. SERVERS 패널과 **같은 톰캣**이라 동시에 켜면 포트 충돌.

## WAR 생성 — MAVEN 패널

탐색기 사이드바 **MAVEN** → `konet_web` → **Favorites** → 항목 옆 **▶**

- **WAR 빌드 (오프라인)** `-o -DskipTests clean package` — 평소엔 이것
- **WAR 빌드 (의존성 갱신)** — `pom.xml` 에 의존성을 추가했을 때만

결과물 `target\konet_web-1.0.0.war` (약 89MB, 45초). artifactId 가 `konet_web` 그대로라 **기존 배포 파일명과 동일**. `Ctrl+Shift+B` (Tasks) 로도 같은 빌드가 돈다.

터미널에서 직접:

```
set JAVA_HOME=C:\Program Files\Java\jre-1.8
D:\egv\apache-maven-3.8.4\bin\mvn.cmd -o -DskipTests clean package
```

## 구성

| 항목 | 값 |
|---|---|
| HTTP 포트 | 9071 (Eclipse konet_web 은 9070 — 동시 실행 가능) |
| 셧다운 포트 | 9013 |
| 디버그 포트 | 9171 (터미널 실행 시) |
| 톰캣 | `D:\egv\Servers\konet_vsweb-tomcat` (8.5.66 전용 복사본) |
| 웹앱 JAR | `D:\egv\Servers\konet_vsweb-vscode\lib` |
| Maven | `D:\egv\apache-maven-3.8.4` (조립본 — 아래 참조) |
| **JDK** | **`C:\Program Files\Java\jre-1.8`** (이름은 jre 지만 실제로는 JDK 8) |

Eclipse 가 쓰는 `D:\egv\apache-tomcat-8.5.66` 과 `D:\egv\Servers\konet_web-config` 는 건드리지 않았다.

`server.xml` 의 Context 가 프로젝트 폴더를 직접 가리키므로 **WAR 배포 없이 실행**된다.

- JSP: `src/main/webapp` → 저장 후 새로고침이면 반영
- 클래스: `target/classes` → VS Code Java 확장이 자동 컴파일. 디버그로 띄웠으면 핫스왑, 아니면 Restart

## 함정

### 1. 웹앱 JAR 3개 제외

`lib` 폴더에서 아래 3개를 **반드시 제외**한다. 두면 기동은 되지만 첫 요청에서 500(`ClassNotFoundException: com.sun.el.ExpressionFactoryImpl`) — 컨테이너가 제공하는 API 를 웹앱 JAR 가 덮어쓴다. 컴파일 전용 스텁이라 런타임엔 불필요.

- `javaee-api-7.0.jar` (→ `lib-excluded/` 로 이동해 둠)
- `servlet-api-2.5.jar`
- `jsp-api-2.1.jar`

### 2. JDK 11 이상이면 로그인만 실패

기동도 되고 화면도 뜨는데 **로그인에서만 500**("로그인 요청 중 오류가 발생했습니다"). 실제 원인:

```
java.lang.NoClassDefFoundError: javax/xml/bind/DatatypeConverter
```

`javax.xml.bind`(JAXB)는 Java 9에서 분리, **11에서 제거**됐는데 로그인 처리가 이걸 쓴다. 이 프로젝트는 Java 8 전용(`pom.xml` `source/target 1.8`)이므로 **반드시 JDK 8**. `javaee-api-7.0.jar` 를 되돌리면 이 클래스는 생기지만 EL 충돌로 **모든 화면이 500**이 되므로 그 방향은 안 된다.

> **자동 업그레이드 도구 주의**: 2026-07-23 GitHub Copilot 의 "Java 런타임 최신 LTS 업그레이드" 에이전트가 auto-execution 모드로 이 프로젝트에서 실행되어 **`src`·`pom.xml`·`docs`·설정이 전부 삭제**됐다(JDK 25 + Maven 3.10 설치까지 진행). `konet_web` 원본에서 복구함. 에이전트 작업 폴더는 `C:\Users\user\git\konet\_java-upgrade-agent-backup-20260723\` 로 옮겨 뒀다. **이 프로젝트에 Java 업그레이드 자동화 도구를 돌리지 말 것.**

### 3. 콘솔 한글 깨짐 — 실행 방식마다 인코딩이 반대다

| 실행 방식 | 쓰는 설정 | ConsoleHandler.encoding |
|---|---|---|
| SERVERS 패널(RSP) | `conf/logging.properties` | EUC-KR |
| Tasks(터미널) | `conf/logging-utf8.properties` | UTF-8 |

터미널 쪽은 `tasks.json` 의 `CATALINA_OPTS` 에서 `-Djava.util.logging.config.file=...logging-utf8.properties` 로 갈아끼우고 `-Dfile.encoding=UTF-8` 도 준다.

**판별법**: log4j2 줄(`DEBUG [org.egovframe...]`)과 톰캣 줄(`INFO [main] org.apache...`) 중 어느 쪽이 깨지는지 본다. 톰캣 줄만 깨지면 ConsoleHandler 가 안 맞는 것, log4j2 줄만 깨지면 `-Dfile.encoding` 이 안 맞는 것. 로그 **파일**은 어느 경우든 UTF-8.

### 4. 셧다운 포트가 잡혀 있으면 조용히 죽는다

이전 톰캣이 완전히 안 죽은 상태에서 새로 띄우면 HTTP 포트는 잡히고 기동 로그도 정상인데 9013 바인딩 실패(`BindException`)로 **곧바로 자기 자신을 종료**한다.

```
Get-NetTCPConnection -State Listen -LocalPort 9013,9071 | Select-Object LocalPort,OwningProcess
```

## Maven 이 별도 설치본이 아니다

이 PC 에 Maven 이 설치돼 있지 않아, **Eclipse(eGovFrame) 내장 m2e Maven 3.8.4 구성요소를 모아 `D:\egv\apache-maven-3.8.4` 로 조립**했다(다운로드 없음).

- `lib\` ← `eclipse\plugins\org.eclipse.m2e.maven.runtime_*\jars\*.jar` + slf4j-simple
- `bin\m2.conf`, `bin\mvn.cmd` (직접 작성)
- 추가로 채운 것 (m2e 는 OSGi 런타임에서 받으므로 jars 폴더에 없음):
  - `slf4j-api-1.7.36.jar` ← 로컬 `.m2` (**Eclipse 의 `org.slf4j.api_*.jar` 는 서명돼 있어 쓰면 `signer information does not match` 오류**)
  - `javax.inject-1.jar` ← 로컬 `.m2`
  - `guava-30.1.0.jar` ← `eclipse\plugins\com.google.guava_30.1.0.*.jar`

`settings.json` 의 `maven.executable.path` 가 이 경로를 가리킨다. 정식 Maven 설치 시 그 값만 바꾸면 된다.

## 라이브러리 갱신

`pom.xml` 의존성을 바꿨다면 WAR 빌드 후:

```
robocopy C:\Users\user\git\konet\konet_vsweb\target\konet_web-1.0.0\WEB-INF\lib D:\egv\Servers\konet_vsweb-vscode\lib /E /XF javaee-api-7.0.jar servlet-api-2.5.jar jsp-api-2.1.jar
```

## konet_web 과의 관계

`konet_web`(Eclipse용)과 `konet_vsweb`(VS Code용)은 **독립된 사본**이다. 한쪽 수정이 다른 쪽에 반영되지 않으므로 **고친 쪽에서 빌드**해야 한다. 두 곳에서 만든 WAR 는 같은 `pom.xml`·`.m2`·war-plugin 을 쓰므로 **구조·파일명이 동일**하다(2026-07-23 실측: 89.3MB, 항목 1,289 vs 1,291 — 차이는 그 사이 추가/삭제된 소스 4개뿐).
