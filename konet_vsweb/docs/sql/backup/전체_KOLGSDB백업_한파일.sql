/* =====================================================================
   KOLGSDB 백업 — 전체 묶음 (이 파일 하나면 됩니다)
   =====================================================================
   대상   : KOLGSDB @ saynice.co.kr:1433  (서버명 SRCMAIN)
   서버   : SQL Server 2012 Standard Edition (64-bit) — 11.0.2100.60
   목표   : 매일 자정(00:00) 전체 백업 1회, 14일 보관
   폴더   : C:\SQLBackup\      (이 서버는 C 드라이브 하나뿐 · 여유 약 131GB)

   ---------------------------------------------------------------------
   ★사용법 — 이 파일을 통째로 실행하지 마세요.
     아래 [1단계]~[8단계] 중 필요한 블록만 **드래그로 선택해서 F5** 합니다.
     각 단계 머리에 [완료] / [남음] / [필요할 때] 표시를 해 두었습니다.
   ---------------------------------------------------------------------

   진행 현황 (2026-08-03)
     [완료] 1. 진단
     [완료] 2. 백업 폴더 + 첫 백업
     [완료] 3. 복구모델 전체 → 단순, 로그 122.9MB → 64.6MB
     [완료] 4. 백업 프로시저 설치 (실행 확인 : 15.2MB · 1초 · 성공)
     [남음] 5. SQL Server Agent 서비스 켜기   ← ★원격데스크톱에서만 가능
     [남음] 6. 매일 자정 작업 등록
            7. 수동 백업 (자동화 전까지, 그리고 위험한 작업 전에)
            8. 점검 · 복원

   ★가장 중요한 사실 — 5·6번을 마쳐야 '자동'이 됩니다.
     그전까지는 7번을 손으로 실행해야 백업이 생깁니다.
   ===================================================================== */


/* =====================================================================
   [완료] 1단계 — 진단  (다시 볼 일이 있을 때만)
   ===================================================================== */
/*
SELECT SERVERPROPERTY('Edition') AS 에디션, SERVERPROPERTY('ProductVersion') AS 버전,
       CASE SERVERPROPERTY('EngineEdition') WHEN 4 THEN 'Express — Agent 없음'
            ELSE 'Agent 사용 가능' END AS 스케줄방식;

SELECT d.name AS DB명, d.recovery_model_desc AS 복구모델, mf.name AS 파일명,
       mf.type_desc AS 종류, CAST(mf.size*8.0/1024 AS DECIMAL(12,1)) AS 크기MB
  FROM sys.databases d JOIN sys.master_files mf ON mf.database_id = d.database_id
 WHERE d.name = 'KOLGSDB' ORDER BY mf.type_desc DESC;

EXEC master.dbo.xp_fixeddrives;                                  -- 드라이브 여유공간
SELECT servicename, status_desc, startup_type_desc               -- Agent 상태
  FROM sys.dm_server_services WHERE servicename LIKE '%Agent%';
*/


/* =====================================================================
   [완료] 2단계 — 백업 폴더 만들기
   ---------------------------------------------------------------------
   SQL Server 가 직접 만들므로 폴더 권한을 따로 줄 필요가 없다.
   (사람이 만든 폴더를 쓰면 서비스 계정 NT SERVICE\MSSQLSERVER 에 '수정' 권한 필요)
   ===================================================================== */
/*
EXEC master.dbo.xp_create_subdir N'C:\SQLBackup';
*/


/* =====================================================================
   [완료] 3단계 — 복구모델 전체(FULL) → 단순(SIMPLE) + 로그 축소
   ---------------------------------------------------------------------
   ★이 선택의 뜻 : 로그가 더 이상 안 커지는 대신, 복구는 '마지막 백업 시점'
     까지만 가능하다(최대 하루치 손실). 하루 1회 백업 방침에 맞춘 결정.
     나중에 "몇 시간 전으로 되돌려줘" 요구가 생기면 이 결정부터 다시 볼 것.
   ===================================================================== */
/*
ALTER DATABASE KOLGSDB SET RECOVERY SIMPLE;
USE KOLGSDB;
DBCC SHRINKFILE (N'KOLGSDB_log', 64);
SELECT name AS 파일명, type_desc AS 종류,
       CAST(size*8.0/1024 AS DECIMAL(12,1)) AS 크기MB FROM sys.database_files;
*/


/* =====================================================================
   [완료] 4단계 — 백업 프로시저  (다시 만들 일이 있으면 이 블록만 실행)
   ---------------------------------------------------------------------
   이 프로시저 하나가 : 전체백업 → 검증 → 옛 파일 삭제 → 결과기록 을 다 한다.
   부르는 쪽은 EXEC dbo.SP_BACKUP_FULL 한 줄이면 되므로,
   경로·보관기간을 바꿔도 스케줄(6단계)은 손대지 않아도 된다.
   ===================================================================== */
USE master;
GO

IF OBJECT_ID('dbo.TBL_BACKUP_LOG') IS NULL
BEGIN
    CREATE TABLE dbo.TBL_BACKUP_LOG (
        SEQ         INT IDENTITY(1,1) PRIMARY KEY,
        DB_NAME     NVARCHAR(128),
        BACKUP_TYPE NVARCHAR(20),
        FILE_PATH   NVARCHAR(500),
        START_DT    DATETIME,
        END_DT      DATETIME,
        ELAPSED_SEC INT,
        FILE_MB     DECIMAL(12,1),
        RESULT      NVARCHAR(20),      -- 성공 / 실패
        MESSAGE     NVARCHAR(2000)
    );
END
GO

IF OBJECT_ID('dbo.SP_BACKUP_FULL') IS NOT NULL DROP PROCEDURE dbo.SP_BACKUP_FULL;
GO

CREATE PROCEDURE dbo.SP_BACKUP_FULL
    @DbName     NVARCHAR(128)  = N'KOLGSDB',
    @BackupDir  NVARCHAR(400)  = N'C:\SQLBackup\',   -- ★끝에 역슬래시 필수
    @KeepDays   INT            = 14
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @file NVARCHAR(500), @stamp NVARCHAR(20), @start DATETIME = GETDATE(),
            @msg NVARCHAR(2000) = N'', @sql NVARCHAR(MAX), @compress BIT = 0, @mb DECIMAL(12,1);

    /* 파일명 : KOLGSDB_20260803_2219.bak — 이름만 보고 언제 것인지 알 수 있게.
       ★자정 백업이라 '하루 넘어간 날짜'가 찍힌다 :
         8/3 하루치 자료를 담은 백업의 파일명은 KOLGSDB_20260804_0000.bak.
         복원할 때 한 칸 헷갈리기 쉬우니 알고 있을 것. */
    SET @stamp = CONVERT(NVARCHAR(8), @start, 112) + N'_'
               + REPLACE(CONVERT(NVARCHAR(5), @start, 108), N':', N'');
    SET @file  = @BackupDir + @DbName + N'_' + @stamp + N'.bak';

    /* 백업 압축 — 2012 Standard 는 지원한다(실측 97MB → 15.2MB). Express 만 제외. */
    IF SERVERPROPERTY('EngineEdition') <> 4
       AND CAST(PARSENAME(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)), 4) AS INT) >= 10
        SET @compress = 1;

    BEGIN TRY
        /* ① 전체 백업 — CHECKSUM 으로 페이지 손상을 백업 시점에 잡아낸다 */
        SET @sql = N'BACKUP DATABASE ' + QUOTENAME(@DbName)
                 + N' TO DISK = N''' + REPLACE(@file, N'''', N'''''') + N'''
                   WITH INIT, CHECKSUM, STATS = 10,
                        NAME = N''' + @DbName + N' 전체 백업'''
                 + CASE WHEN @compress = 1 THEN N', COMPRESSION' ELSE N'' END + N';';
        EXEC sp_executesql @sql;

        /* ② 검증 — 쓰다 만 백업은 없느니만 못하다 */
        SET @sql = N'RESTORE VERIFYONLY FROM DISK = N''' + REPLACE(@file, N'''', N'''''') + N''' WITH CHECKSUM;';
        EXEC sp_executesql @sql;

        SELECT TOP 1 @mb = CAST(compressed_backup_size / 1024.0 / 1024 AS DECIMAL(12,1))
          FROM msdb.dbo.backupset
         WHERE database_name = @DbName AND type = 'D' ORDER BY backup_start_date DESC;

        /* ③ 오래된 백업 삭제 — xp_delete_file 은 SQL Server 가 만든 백업 파일만 지운다 */
        DECLARE @cut DATETIME = DATEADD(DAY, -@KeepDays, GETDATE());
        BEGIN TRY
            EXEC master.dbo.xp_delete_file 0, @BackupDir, N'bak', @cut, 0;
        END TRY
        BEGIN CATCH
            SET @msg = N'옛 백업 삭제 실패(백업 자체는 성공): ' + ERROR_MESSAGE();
        END CATCH

        INSERT dbo.TBL_BACKUP_LOG (DB_NAME, BACKUP_TYPE, FILE_PATH, START_DT, END_DT, ELAPSED_SEC, FILE_MB, RESULT, MESSAGE)
        VALUES (@DbName, N'전체', @file, @start, GETDATE(), DATEDIFF(SECOND, @start, GETDATE()), @mb, N'성공', @msg);
    END TRY
    BEGIN CATCH
        INSERT dbo.TBL_BACKUP_LOG (DB_NAME, BACKUP_TYPE, FILE_PATH, START_DT, END_DT, ELAPSED_SEC, FILE_MB, RESULT, MESSAGE)
        VALUES (@DbName, N'전체', @file, @start, GETDATE(), DATEDIFF(SECOND, @start, GETDATE()), NULL, N'실패', ERROR_MESSAGE());

        /* ★오류를 다시 던진다 — 안 던지면 Agent 가 '성공'으로 보고 조용히 넘어간다 */
        THROW;
    END CATCH
END
GO


/* =====================================================================
   [남음] 5단계 — SQL Server Agent 서비스 켜기
   ---------------------------------------------------------------------
   ★★ 이 단계는 SQL 로 못 한다. 반드시 원격데스크톱(RDP)으로 서버에서 한다.

     1) 내 PC : 시작 → mstsc → 컴퓨터 saynice.co.kr → 서버 관리자 계정 로그인
     2) 서버  : 시작 → services.msc
     3) 서버  : SQL Server Agent (MSSQLSERVER) 오른쪽 클릭 → 속성
     4) 서버  : 시작 유형 = 자동  → 적용 → 시작(S) → 확인

   ★시작 유형을 반드시 '자동' 으로. '수동' 이면 서버 재부팅 때 Agent 가 안 올라와
     백업이 조용히 멈춘다 — 사고 나기 전까지 아무도 모른다.

   ※ xp_cmdshell 로 'net start SQLSERVERAGENT' 를 시도했으나
     Access is denied(오류 5) 로 실패했다(2026-08-03). SQL Server 서비스 계정에
     다른 서비스를 제어할 권한이 없다. ★다시 시도하지 말 것 —
     보안 기능(xp_cmdshell)만 잠깐 열렸다 닫힐 뿐이다.

   서비스를 켠 뒤 아래로 확인 (Running / Automatic 이면 성공)
   ===================================================================== */
/*
SELECT servicename AS 서비스, status_desc AS 상태, startup_type_desc AS 시작유형
  FROM sys.dm_server_services WHERE servicename LIKE '%Agent%';
*/


/* =====================================================================
   [남음] 6단계 — 매일 자정 작업 등록   ★5단계를 마친 뒤에 실행
   ---------------------------------------------------------------------
   여러 번 실행해도 안전하다(같은 이름 작업이 있으면 지우고 다시 만든다).
   ===================================================================== */
/*
USE msdb;
GO
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'KOLGSDB 일일 전체백업')
    EXEC msdb.dbo.sp_delete_job @job_name = N'KOLGSDB 일일 전체백업', @delete_unused_schedule = 1;
GO
EXEC msdb.dbo.sp_add_job
     @job_name    = N'KOLGSDB 일일 전체백업',
     @description = N'매일 00:00(자정) KOLGSDB 전체 백업 + 검증 + 14일 지난 파일 삭제. 본체는 master.dbo.SP_BACKUP_FULL',
     @enabled     = 1;
GO
EXEC msdb.dbo.sp_add_jobstep
     @job_name       = N'KOLGSDB 일일 전체백업',
     @step_name      = N'전체백업 실행',
     @subsystem      = N'TSQL',
     @database_name  = N'master',
     @command        = N'EXEC dbo.SP_BACKUP_FULL @DbName = N''KOLGSDB'', @BackupDir = N''C:\SQLBackup\'', @KeepDays = 14;',
     @retry_attempts = 2,      -- 일시적 파일 잠김 등으로 실패하면 5분 뒤 두 번 더
     @retry_interval = 5,
     @on_success_action = 1,
     @on_fail_action    = 2;
GO
EXEC msdb.dbo.sp_add_jobschedule
     @job_name          = N'KOLGSDB 일일 전체백업',
     @name              = N'매일 자정',
     @freq_type         = 4,        -- 매일
     @freq_interval     = 1,
     @active_start_time = 0;        -- 00:00:00
GO
EXEC msdb.dbo.sp_add_jobserver @job_name = N'KOLGSDB 일일 전체백업';
GO

-- 등록 직후 즉시 한 번 돌려 확인 (자정까지 기다리지 말 것)
EXEC msdb.dbo.sp_start_job @job_name = N'KOLGSDB 일일 전체백업';
WAITFOR DELAY '00:00:10';
SELECT TOP 3 SEQ, START_DT, FILE_MB, RESULT, MESSAGE
  FROM master.dbo.TBL_BACKUP_LOG ORDER BY SEQ DESC;
*/


/* =====================================================================
   [필요할 때] 7단계 — 수동 백업  ★★가장 자주 쓸 한 줄★★
   ---------------------------------------------------------------------
   · 자동(5·6단계)이 걸리기 전까지는 이것으로 백업한다.
   · 자동이 걸린 뒤에도 '위험한 작업 전'에는 이걸 한 번 눌러 두면 안전하다.
       - 대량 삭제 · 마감 처리 · 자료 일괄 수정 전
       - 하루치 매입·매출 등록을 마친 뒤
   · 1초면 끝나고, 실행 중에도 konet 웹은 정상 동작한다(사용자가 써도 됨).
   · 파일명에 실행 시각이 붙으므로 하루에 여러 번 해도 서로 덮어쓰지 않는다.
   ===================================================================== */

EXEC master.dbo.SP_BACKUP_FULL @BackupDir = N'C:\SQLBackup\', @KeepDays = 14;

SELECT TOP 10 SEQ, START_DT AS 시작, ELAPSED_SEC AS 초, FILE_MB AS MB,
       RESULT AS 결과, FILE_PATH AS 파일, MESSAGE AS 메모
  FROM master.dbo.TBL_BACKUP_LOG ORDER BY SEQ DESC;
GO


/* =====================================================================
   8단계 — 점검   (가끔, 한 달에 한 번쯤)
   ---------------------------------------------------------------------
   ★백업이 '조용히 실패'하는 것이 가장 무섭다. 아래 셋만 보면 된다.
   ===================================================================== */
/*
-- (1) 최근 백업이 성공했나 · 며칠째 안 돌고 있지 않나
SELECT TOP 15 SEQ, START_DT AS 시작, FILE_MB AS MB, RESULT AS 결과, MESSAGE AS 메모
  FROM master.dbo.TBL_BACKUP_LOG ORDER BY SEQ DESC;

-- (2) 마지막 백업이 언제인가 (하루 넘었으면 뭔가 잘못된 것)
SELECT MAX(backup_finish_date) AS 마지막_전체백업,
       DATEDIFF(HOUR, MAX(backup_finish_date), GETDATE()) AS 몇시간_지났나
  FROM msdb.dbo.backupset WHERE database_name = 'KOLGSDB' AND type = 'D';

-- (3) Agent 작업이 잘 돌고 있나
SELECT TOP 10 j.name AS 작업명,
       CASE h.run_status WHEN 1 THEN '성공' WHEN 0 THEN '실패' ELSE '기타' END AS 결과,
       msdb.dbo.agent_datetime(h.run_date, h.run_time) AS 실행시각, h.message AS 메시지
  FROM msdb.dbo.sysjobhistory h JOIN msdb.dbo.sysjobs j ON j.job_id = h.job_id
 WHERE j.name = N'KOLGSDB 일일 전체백업' AND h.step_id = 0
 ORDER BY h.instance_id DESC;
*/


/* =====================================================================
   9단계 — 복원  (사고 났을 때)
   ---------------------------------------------------------------------
   ★순서를 지킬 것 : 원본을 바로 덮지 않는다.
     ① 쓸 수 있는 백업 확인 → ② 파일 검증 → ③ 다른 이름으로 복원해 자료 확인
     → ④ 그래도 되돌려야 하면 그때 운영 DB 복원
   ===================================================================== */
/*
-- ① 쓸 수 있는 백업 목록
SELECT TOP 20 bs.backup_finish_date AS 백업시각,
       CAST(bs.compressed_backup_size/1024.0/1024 AS DECIMAL(12,1)) AS 파일MB,
       bmf.physical_device_name AS 백업파일
  FROM msdb.dbo.backupset bs
  JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = bs.media_set_id
 WHERE bs.database_name = 'KOLGSDB' AND bs.type = 'D'
 ORDER BY bs.backup_finish_date DESC;

-- ② 파일 검증 · 논리파일명 확인 (경로는 ①에서 복사)
RESTORE VERIFYONLY   FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_2219.bak' WITH CHECKSUM;
RESTORE FILELISTONLY FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_2219.bak';

-- ③ ★권장 : 다른 이름으로 복원해 자료를 눈으로 확인 (운영 DB 안 건드림)
RESTORE DATABASE KOLGSDB_CHK
  FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_2219.bak'
  WITH MOVE N'KOLGSDB'     TO N'C:\SQLBackup\KOLGSDB_CHK.mdf',
       MOVE N'KOLGSDB_log' TO N'C:\SQLBackup\KOLGSDB_CHK_log.ldf',
       RECOVERY, STATS = 5;
-- 확인 후 정리 : DROP DATABASE KOLGSDB_CHK;

-- ④ 운영 DB 되돌리기 — ★이 시점 이후 자료는 전부 사라진다. 관련자에게 알린 뒤 실행.
BACKUP DATABASE KOLGSDB TO DISK = N'C:\SQLBackup\KOLGSDB_복원직전_긴급.bak'
  WITH INIT, CHECKSUM, COMPRESSION;                       -- 잘못 복원했을 때 돌아올 자리
ALTER DATABASE KOLGSDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;   -- 접속 끊기
RESTORE DATABASE KOLGSDB FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_2219.bak'
  WITH REPLACE, RECOVERY, STATS = 5;
ALTER DATABASE KOLGSDB SET MULTI_USER;                    -- 다시 열기
-- 그다음 톰캣 재기동 (커넥션풀이 새로 붙어야 한다)
*/


/* =====================================================================
   남은 위험 — 아직 해결 안 된 것
   ---------------------------------------------------------------------
   ★백업 파일이 DB와 같은 C 드라이브에 있다.
     이 디스크가 죽으면 DB와 백업이 동시에 사라진다.
     백업이 15MB 밖에 안 되므로, 다른 PC·NAS·클라우드로 복사해 두는 것을
     6단계까지 마친 뒤 반드시 붙일 것. (robocopy 배치로 5분이면 된다)

   ※ 참고 : SQL Server 2012 는 지원 종료(연장지원 2022-07) 버전이다.
     백업과 별개 문제지만 보안 갱신이 없다는 점은 알고 있을 것.
   ===================================================================== */
