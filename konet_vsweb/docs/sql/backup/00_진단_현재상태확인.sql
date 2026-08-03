/* =====================================================================
   KOLGSDB 백업 — ① 현재 상태 진단
   ---------------------------------------------------------------------
   백업을 걸기 전에 이것부터 SSMS 에서 실행해 결과를 확인한다.
   여기서 나오는 값에 따라 스케줄 방식(SQL Agent / 작업 스케줄러)과
   복구모델 조정 여부가 갈린다.

   실행 위치 : SSMS → saynice.co.kr 접속 → 새 쿼리
   영향      : 조회만 한다. 아무것도 바꾸지 않는다.
   ===================================================================== */
USE master;
GO

/* ── 1. 서버 판                                            ────────────
     · Edition 에 'Express' 가 있으면 → SQL Server Agent 를 못 쓴다.
       (백업 자동화는 Windows 작업 스케줄러 + sqlcmd 로 한다)
     · 'Standard' / 'Enterprise' → SQL Agent 작업으로 거는 게 정석이다.
     · ProductVersion 10.50 이상(2008R2+) Standard 면 백업 압축을 쓸 수 있다. */
SELECT
    SERVERPROPERTY('MachineName')      AS 서버이름,
    SERVERPROPERTY('Edition')          AS 에디션,
    SERVERPROPERTY('ProductVersion')   AS 버전,
    SERVERPROPERTY('ProductLevel')     AS 서비스팩,
    CASE SERVERPROPERTY('EngineEdition')
         WHEN 4 THEN 'Express — SQL Agent 없음 (작업 스케줄러로)'
         ELSE        'Agent 사용 가능'
    END                                AS 스케줄방식;
GO

/* ── 2. SQL Server Agent 가 실제로 돌고 있나 ───────────────────────── */
SELECT servicename AS 서비스, status_desc AS 상태, startup_type_desc AS 시작유형
  FROM sys.dm_server_services
 WHERE servicename LIKE '%Agent%';
GO

/* ── 3. 데이터베이스 복구모델·크기                         ────────────
     ★핵심 확인 : recovery_model_desc 가 FULL 인데 로그백업을 안 하고 있으면
       트랜잭션 로그(.ldf)가 무한정 커진다. 하루 1회 전체백업만 할 계획이면
       SIMPLE 이 맞다(02번 스크립트에서 바꾼다).
     로그파일이 데이터파일보다 크면 이 상태일 가능성이 높다. */
SELECT
    d.name                                        AS DB명,
    d.recovery_model_desc                         AS 복구모델,
    d.state_desc                                  AS 상태,
    d.compatibility_level                         AS 호환수준,
    mf.name                                       AS 논리파일명,
    mf.type_desc                                  AS 파일종류,
    CAST(mf.size * 8.0 / 1024 AS DECIMAL(12,1))   AS 크기MB,
    mf.physical_name                              AS 실제경로
  FROM sys.databases d
  JOIN sys.master_files mf ON mf.database_id = d.database_id
 WHERE d.name = 'KOLGSDB'
 ORDER BY mf.type_desc DESC, mf.name;
GO

/* ── 4. 지금까지의 백업 이력 (최근 30건)                   ────────────
     · 아무것도 안 나오면 → 백업이 한 번도 안 돌고 있다.
     · type : D=전체, I=차등, L=로그
     · 백업이 이미 돌고 있다면 어디에 쌓이는지(경로)도 여기서 보인다. */
SELECT TOP 30
    bs.database_name                                        AS DB명,
    CASE bs.type WHEN 'D' THEN '전체' WHEN 'I' THEN '차등'
                 WHEN 'L' THEN '로그' ELSE bs.type END      AS 종류,
    bs.backup_start_date                                    AS 시작,
    bs.backup_finish_date                                   AS 종료,
    DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS 소요초,
    CAST(bs.backup_size   / 1024.0 / 1024 AS DECIMAL(12,1)) AS 원본MB,
    CAST(bs.compressed_backup_size / 1024.0 / 1024 AS DECIMAL(12,1)) AS 파일MB,
    bmf.physical_device_name                                AS 백업파일
  FROM msdb.dbo.backupset bs
  LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = bs.media_set_id
 WHERE bs.database_name = 'KOLGSDB'
 ORDER BY bs.backup_start_date DESC;
GO

/* ── 5. 마지막 백업이 언제인지 한 줄 요약                  ──────────── */
SELECT
    d.name AS DB명,
    MAX(CASE WHEN bs.type = 'D' THEN bs.backup_finish_date END) AS 마지막_전체백업,
    MAX(CASE WHEN bs.type = 'I' THEN bs.backup_finish_date END) AS 마지막_차등백업,
    MAX(CASE WHEN bs.type = 'L' THEN bs.backup_finish_date END) AS 마지막_로그백업
  FROM sys.databases d
  LEFT JOIN msdb.dbo.backupset bs ON bs.database_name = d.name
 WHERE d.name = 'KOLGSDB'
 GROUP BY d.name;
GO

/* ── 6. 기본 백업 경로 (스크립트에 넣을 폴더를 정할 때 참고)  ───────── */
SELECT
    SERVERPROPERTY('InstanceDefaultDataPath') AS 기본데이터경로,
    SERVERPROPERTY('InstanceDefaultLogPath')  AS 기본로그경로;
GO
