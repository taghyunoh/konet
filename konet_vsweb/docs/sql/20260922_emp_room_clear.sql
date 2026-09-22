/* =====================================================================
   직원 메신저 — 대화 지우기 (2026-09-22 사용자 「대화도 지울 수 있게」) — ⛔새 WAR 를 올리기 <전에> 운영DB 에서 한 번 실행. 재실행 안전.
     TBL_EMP_ROOM_MBR.CLEAR_SEQ : 이 사람이 「대화 지우기/나가기」 한 시점의 마지막 글 번호.
       · 이 번호까지의 글은 그 사람에게 안 보인다(글 자체는 지우지 않는다 — 상대에게는 그대로).
       · 다시 대화가 열리면(같은 상대와 1:1 을 다시 시작 · 그룹에 다시 초대) 그 뒤 글만 보인다.
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_EMP_ROOM_MBR','CLEAR_SEQ') IS NULL
    ALTER TABLE dbo.TBL_EMP_ROOM_MBR ADD CLEAR_SEQ INT NOT NULL CONSTRAINT DF_EMP_ROOM_MBR_CLEAR DEFAULT 0;
GO
SELECT COL_LENGTH('dbo.TBL_EMP_ROOM_MBR','CLEAR_SEQ') AS clearSeqLen;
