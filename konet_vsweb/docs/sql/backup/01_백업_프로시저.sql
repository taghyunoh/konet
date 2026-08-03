/* =====================================================================
   KOLGSDB 백업 — ② 백업 프로시저 만들기
   ---------------------------------------------------------------------
   하루 1회 전체 백업 (사용자 확정 2026-08-03).

   이 프로시저 하나만 부르면 —
     ① 전체 백업 (압축 지원되면 압축, CHECKSUM 으로 손상 검사)
     ② 백업 파일 검증 (RESTORE VERIFYONLY — 쓰다 만 파일을 걸러낸다)
     ③ 보관기간 지난 옛 백업 파일 삭제
     ④ 결과를 로그 테이블에 기록
   까지 한 번에 끝난다.

   ★왜 프로시저로 만드나 — SQL Agent 작업이든 작업 스케줄러든 부르는 쪽은
     `EXEC dbo.SP_BACKUP_FULL` 한 줄이면 된다. 나중에 경로·보관기간을 바꿔도
     스케줄은 손대지 않는다.

   실행 위치 : SSMS → saynice.co.kr → 새 쿼리 → 통째로 실행 (1회)
   ===================================================================== */
USE master;
GO

/* ── 백업 결과 기록 테이블 ─────────────────────────────────────────
     백업이 조용히 실패하는 것이 가장 무섭다. 성공·실패를 남겨 두고
     05번 점검 쿼리로 가끔 확인한다. */
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
    @BackupDir  NVARCHAR(400)  = N'C:\SQLBackup\',   -- ★서버에 실제로 있는 폴더로 고칠 것 (끝에 \ 필수)
    @KeepDays   INT            = 14                  -- 이 일수보다 오래된 백업 파일은 지운다
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @file    NVARCHAR(500),
            @stamp   NVARCHAR(20),
            @start   DATETIME = GETDATE(),
            @msg     NVARCHAR(2000) = N'',
            @sql     NVARCHAR(MAX),
            @compress BIT = 0,
            @mb      DECIMAL(12,1);

    /* 파일명 : KOLGSDB_20260803_0200.bak — 이름만 보고 언제 것인지 알 수 있게 */
    SET @stamp = CONVERT(NVARCHAR(8), @start, 112) + N'_'
               + REPLACE(CONVERT(NVARCHAR(5), @start, 108), N':', N'');
    SET @file  = @BackupDir + @DbName + N'_' + @stamp + N'.bak';

    /* 백업 압축 — Express 와 옛 Standard 는 못 쓴다. 되는 판에서만 켠다.
       (압축하면 용량이 1/4 안팎으로 줄고 백업 시간도 짧아진다) */
    IF SERVERPROPERTY('EngineEdition') <> 4
       AND CAST(PARSENAME(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)), 4) AS INT) >= 10
        SET @compress = 1;

    BEGIN TRY
        /* ── ① 전체 백업 ────────────────────────────────────────────
             CHECKSUM  : 페이지 손상을 백업 시점에 잡아낸다
             INIT      : 같은 이름 파일이 있으면 덮어쓴다(날짜가 붙어 사실상 새 파일)
             STATS = 10: 진행률을 10%마다 남긴다 */
        SET @sql = N'BACKUP DATABASE ' + QUOTENAME(@DbName)
                 + N' TO DISK = N''' + REPLACE(@file, N'''', N'''''') + N'''
                   WITH INIT, CHECKSUM, STATS = 10,
                        NAME = N''' + @DbName + N' 전체 백업'''
                 + CASE WHEN @compress = 1 THEN N', COMPRESSION' ELSE N'' END + N';';
        EXEC sp_executesql @sql;

        /* ── ② 검증 — 쓰다 만 백업은 없느니만 못하다 ──────────────── */
        SET @sql = N'RESTORE VERIFYONLY FROM DISK = N''' + REPLACE(@file, N'''', N'''''') + N''' WITH CHECKSUM;';
        EXEC sp_executesql @sql;

        SELECT TOP 1 @mb = CAST(compressed_backup_size / 1024.0 / 1024 AS DECIMAL(12,1))
          FROM msdb.dbo.backupset
         WHERE database_name = @DbName AND type = 'D'
         ORDER BY backup_start_date DESC;

        /* ── ③ 오래된 백업 파일 삭제 ─────────────────────────────────
             xp_delete_file 는 SQL Server 가 만든 백업 파일만 지운다
             (0 = 백업파일, 확장자 bak). 엉뚱한 파일이 지워질 일이 없다. */
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

        /* ★오류를 다시 던진다 — 안 던지면 스케줄러가 '성공'으로 보고 조용히 넘어간다 */
        THROW;
    END CATCH
END
GO

/* ── 지금 한 번 돌려 본다 (스케줄 걸기 전에 반드시 확인) ──────────────
     폴더가 없거나 SQL Server 서비스 계정에 쓰기 권한이 없으면 여기서 실패한다.
     그 경우 03번 문서의 '폴더 권한' 항목을 볼 것. */
-- EXEC dbo.SP_BACKUP_FULL @BackupDir = N'C:\SQLBackup\', @KeepDays = 14;
-- SELECT TOP 5 * FROM dbo.TBL_BACKUP_LOG ORDER BY SEQ DESC;
