# .vscode 설정 템플릿

`.vscode/settings.json` 과 `.vscode/tasks.json` 은 **PC마다 경로가 달라서 git으로 공유하지 않는다**
(`.gitignore` 처리됨). 한 PC는 egv 인프라가 `C:\egv`, 다른 PC는 `D:\egv` 에 있어서,
공유하면 pull 할 때마다 서로 덮어쓰거나 충돌한다.

## 새 PC에서 세팅할 때

1. 이 폴더의 두 파일을 `.vscode/` 로 복사한다.

   ```
   copy .vscode-sample\settings.json .vscode\
   copy .vscode-sample\tasks.json .vscode\
   ```

2. 복사한 파일에서 자기 PC 값으로 고친다.

   | 항목 | 고칠 곳 | 예시 |
   | --- | --- | --- |
   | egv 루트 | `maven.executable.path`, `CATALINA_HOME`, `CATALINA_OPTS`, WAR 빌드 태스크의 mvn 경로 | `C:\egv` 또는 `D:\egv` |
   | JAVA_HOME | `maven.terminal.customEnv`, 각 태스크의 `env.JAVA_HOME` | Java 8 JDK 경로 |
   | maven settings.xml | `java.configuration.maven.userSettings` | 없으면 키 자체를 지운다(기본 `~/.m2` 사용) |

3. 고친 파일은 커밋되지 않는다. **템플릿 쪽(`.vscode-sample/`)에 공통 설정을 추가했을 때만 커밋**한다.

`.vscode/extensions.json`, `.vscode/launch.json` 은 경로가 없어서 그대로 공유한다(계속 git 추적).
