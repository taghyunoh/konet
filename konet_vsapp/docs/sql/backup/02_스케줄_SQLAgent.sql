/* =====================================================================
   KOLGSDB 백업 — ③-가. SQL Server Agent 로 매일 자정(00:00) 실행
   ---------------------------------------------------------------------
   ★00번 진단에서 에디션이 Express 가 아니면 이 방법을 쓴다.
     Express 면 이 스크립트는 실패한다 → 03번(작업 스케줄러)으로 갈 것.

   실행 위치 : SSMS → saynice.co.kr → 새 쿼리 → 통째로 실행 (1회)
   ===================================================================== */
USE msdb;
GO

/* 같은 이름 작업이 있으면 지우고 다시 만든다 (여러 번 실행해도 안전) */
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
     /* ★@BackupDir 은 서버에 실제로 있는 폴더로 고칠 것 (끝에 \ 필수) */
     @command        = N'EXEC dbo.SP_BACKUP_FULL @DbName = N''KOLGSDB'', @BackupDir = N''C:\SQLBackup\'', @KeepDays = 14;',
     @retry_attempts = 2,      -- 일시적인 파일 잠김 등으로 실패하면 두 번 더 시도
     @retry_interval = 5,      -- 5분 간격
     @on_success_action = 1,   -- 성공하면 작업 종료
     @on_fail_action    = 2;   -- 실패하면 작업 실패로 기록 (로그에 남는다)
GO

/* 매일 00:00 (자정) — 2026-08-03 사용자 지정.
   ★백업 파일 이름에는 '자정을 넘긴 날짜'가 찍힌다.
     예) 8/3 하루치 자료를 담은 백업의 파일명은 KOLGSDB_20260804_0000.bak.
     나중에 "8월 3일 자료를 되돌려줘" 할 때 한 칸 헷갈리기 쉬우니 알고 있을 것.
     (신경 쓰이면 @active_start_time 을 235000 = 23:50 으로 바꾸면 같은 날짜로 찍힌다) */
EXEC msdb.dbo.sp_add_jobschedule
     @job_name              = N'KOLGSDB 일일 전체백업',
     @name                  = N'매일 자정',
     @freq_type             = 4,        -- 매일
     @freq_interval         = 1,
     @active_start_time     = 0;        -- 00:00:00 (자정)
GO

/* 이 서버에서 돌도록 등록 */
EXEC msdb.dbo.sp_add_jobserver @job_name = N'KOLGSDB 일일 전체백업';
GO

/* ── 지금 한 번 돌려 확인 ────────────────────────────────────────── */
-- EXEC msdb.dbo.sp_start_job @job_name = N'KOLGSDB 일일 전체백업';

/* ── 작업 이력 확인 ──────────────────────────────────────────────── */
SELECT TOP 20
       j.name                                   AS 작업명,
       CASE h.run_status WHEN 1 THEN '성공' WHEN 0 THEN '실패'
                         WHEN 3 THEN '취소' ELSE '진행/재시도' END AS 결과,
       msdb.dbo.agent_datetime(h.run_date, h.run_time) AS 실행시각,
       h.run_duration                           AS 소요_HHMMSS,
       h.message                                AS 메시지
  FROM msdb.dbo.sysjobhistory h
  JOIN msdb.dbo.sysjobs j ON j.job_id = h.job_id
 WHERE j.name = N'KOLGSDB 일일 전체백업' AND h.step_id = 0
 ORDER BY h.instance_id DESC;
GO
