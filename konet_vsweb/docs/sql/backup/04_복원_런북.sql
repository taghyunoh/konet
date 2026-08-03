/* =====================================================================
   KOLGSDB 백업 — ④ 복원 런북 (사고 났을 때 보는 문서)
   ---------------------------------------------------------------------
   ★백업은 '복원해 본 적이 있어야' 백업이다. 한 번도 복원해 보지 않은 백업은
     정작 필요할 때 안 열리는 경우가 많다. 아래 [연습] 절차를 분기에 한 번쯤 해 둘 것.

   사고가 났을 때는 당황하지 말고 순서대로 —
     1. 지금 DB를 더 건드리지 않는다 (덮어쓰기 전에 현 상태를 먼저 보존)
     2. 3번으로 쓸 수 있는 백업 파일이 있는지 확인
     3. **다른 이름으로 먼저 복원**해서 자료를 확인 (원본을 바로 덮지 않는다)
     4. 확인 끝난 뒤에 결정
   ===================================================================== */

/* ── 1. 쓸 수 있는 백업이 무엇이 있나 ──────────────────────────────── */
SELECT TOP 20
       bs.backup_finish_date                       AS 백업시각,
       CASE bs.type WHEN 'D' THEN '전체' WHEN 'I' THEN '차등' ELSE bs.type END AS 종류,
       CAST(bs.compressed_backup_size/1024.0/1024 AS DECIMAL(12,1)) AS 파일MB,
       bmf.physical_device_name                    AS 백업파일
  FROM msdb.dbo.backupset bs
  JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = bs.media_set_id
 WHERE bs.database_name = 'KOLGSDB' AND bs.type = 'D'
 ORDER BY bs.backup_finish_date DESC;
GO

/* ── 2. 백업 파일이 멀쩡한지 · 안에 뭐가 들었는지 ───────────────────
     복원 전에 반드시 본다. 파일 경로는 1번 결과에서 복사해 넣는다. */
-- RESTORE VERIFYONLY FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_0200.bak' WITH CHECKSUM;
-- RESTORE HEADERONLY FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_0200.bak';
-- RESTORE FILELISTONLY FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_0200.bak';   -- 논리파일명 확인용
GO

/* ── 3. ★권장 : 다른 이름(KOLGSDB_CHK)으로 복원해서 자료 확인 ────────
     운영 DB를 건드리지 않으므로 안전하다. 여기서 자료를 조회해 보고
     "이 백업이 맞다" 를 확인한 다음에야 4번을 생각한다.
     · MOVE 의 논리파일명은 위 FILELISTONLY 결과를 그대로 쓴다.
     · 복원 위치는 디스크 여유가 있는 곳으로. */
/*
RESTORE DATABASE KOLGSDB_CHK
  FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_0200.bak'
  WITH MOVE N'KOLGSDB'     TO N'C:\SQLData\KOLGSDB_CHK.mdf',
       MOVE N'KOLGSDB_log' TO N'C:\SQLData\KOLGSDB_CHK_log.ldf',
       RECOVERY, STATS = 5;
*/
GO

/* ── 4. 운영 DB를 백업 시점으로 되돌리기 (되돌릴 수 없는 작업) ───────
     ★★ 이 시점 이후에 들어온 자료는 전부 사라진다. 3번 확인을 마치고,
        관련자에게 알린 뒤에 실행할 것.
     ★ 먼저 지금 상태를 별도 파일로 백업해 둔다 — 잘못 복원했을 때 돌아올 자리다. */
/*
-- (가) 지금 상태 보존
BACKUP DATABASE KOLGSDB TO DISK = N'C:\SQLBackup\KOLGSDB_복원직전_긴급.bak' WITH INIT, CHECKSUM, COMPRESSION;

-- (나) 접속 끊기 — 열린 세션이 있으면 복원이 시작되지 않는다
ALTER DATABASE KOLGSDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- (다) 복원
RESTORE DATABASE KOLGSDB
  FROM DISK = N'C:\SQLBackup\KOLGSDB_20260803_0200.bak'
  WITH REPLACE, RECOVERY, STATS = 5;

-- (라) 다시 열기
ALTER DATABASE KOLGSDB SET MULTI_USER;
*/
GO

/* ── 5. 복원 뒤 확인 ────────────────────────────────────────────────
     WAS(톰캣)는 재기동해야 커넥션풀이 새로 붙는다. 아래로 자료가 맞는지 본다. */
/*
USE KOLGSDB;
SELECT TOP 5 * FROM TBL_SALES_MST ORDER BY 1 DESC;
SELECT COUNT(*) AS 거래처수 FROM TBL_VENDOR_MST;
*/
GO

/* =====================================================================
   [연습] 분기에 한 번 — 복원이 되는지 실제로 해 보기
     ① 최신 백업으로 3번(KOLGSDB_CHK)을 실행
     ② 몇 개 표의 건수를 운영과 비교
     ③ DROP DATABASE KOLGSDB_CHK; 로 정리
   이 세 줄을 해 두면 사고 때 "복원이 될까?" 를 고민하지 않아도 된다.
   ===================================================================== */
