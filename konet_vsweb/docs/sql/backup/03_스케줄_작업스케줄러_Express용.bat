@echo off
REM =====================================================================
REM  KOLGSDB 백업 - 3-나. SQL Server Express 용 (SQL Agent 가 없을 때)
REM ---------------------------------------------------------------------
REM  Express 에는 SQL Server Agent 가 없다. Windows 작업 스케줄러가 이 배치를
REM  매일 부르고, 배치는 sqlcmd 로 백업 프로시저(SP_BACKUP_FULL)를 실행한다.
REM
REM  설치 방법 (서버에 원격데스크톱으로 접속해서)
REM    1) 이 파일을 서버의 C:\SQLBackup\ 에 복사
REM    2) 아래 SET 값 4개를 서버 환경에 맞게 고친다
REM    3) 명령 프롬프트에서 한 번 실행해 성공하는지 확인
REM    4) 작업 스케줄러 등록 (관리자 권한 명령 프롬프트에서 아래 한 줄)
REM
REM       schtasks /create /tn "KOLGSDB 일일 전체백업" /tr "C:\SQLBackup\03_스케줄_작업스케줄러_Express용.bat" /sc daily /st 02:00 /ru SYSTEM /rl HIGHEST /f
REM
REM       - /ru SYSTEM : 로그인하지 않아도 돌게 한다 (사람이 로그아웃해도 백업은 돈다)
REM       - /rl HIGHEST: 관리자 권한으로 실행
REM =====================================================================

REM ── 고칠 곳 ──────────────────────────────────────────────────────────
SET SQLINST=localhost
REM   ↑ 기본 인스턴스면 localhost. 명명 인스턴스면 localhost\SQLEXPRESS
SET BACKUPDIR=C:\SQLBackup\
REM   ↑ 끝에 역슬래시 필수. 이 폴더가 서버에 실제로 있어야 한다
SET KEEPDAYS=14
REM   ↑ 며칠치를 남길지
SET LOGFILE=C:\SQLBackup\backup_log.txt
REM ─────────────────────────────────────────────────────────────────────

echo. >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"
echo [%date% %time%] 백업 시작 >> "%LOGFILE%"

REM  -E = Windows 인증으로 접속 (SYSTEM 계정이 sysadmin 이어야 한다).
REM       Windows 인증이 안 되면 -E 를 지우고 -U sa -P 암호 로 바꾼다.
REM       ★그 경우 이 파일에 암호가 평문으로 남으니 폴더 접근 권한을 관리자만으로 제한할 것.
REM  -b = 오류가 나면 종료코드를 0 이 아닌 값으로 돌려준다 (실패를 스케줄러가 알아채게)
sqlcmd -S %SQLINST% -E -b -d master -Q "EXEC dbo.SP_BACKUP_FULL @DbName = N'KOLGSDB', @BackupDir = N'%BACKUPDIR%', @KeepDays = %KEEPDAYS%;" >> "%LOGFILE%" 2>&1

IF ERRORLEVEL 1 (
    echo [%date% %time%] *** 백업 실패 — 위 메시지 확인 *** >> "%LOGFILE%"
    exit /b 1
) ELSE (
    echo [%date% %time%] 백업 성공 >> "%LOGFILE%"
    exit /b 0
)
