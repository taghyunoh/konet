/* =====================================================================
   직원 공지사항 — 게시 기간(유효기간) (2026-09-22 사용자 요청 「공지사항 유효기간 설정기능」)
   ⛔새 WAR 를 올리기 <전에> 운영DB(KOLGSDB)에서 한 번 실행. 재실행 안전.
     (칸 없이 새 WAR 가 뜨면 공지 목록·저장·배지가 조회 오류가 난다 — 매퍼가 START_DT·END_DT 를 읽는다)

   START_DT · END_DT = 'YYYYMMDD' (비면 제한 없음 — 기존 공지는 전부 NULL 이라 종전처럼 늘 보인다)
     · 일반 직원 : 목록·하단 흐름 띠·우측 패널·안 읽음 배지 모두 <오늘이 기간 안인 공지만>
     · 관리자    : 공지 화면에서 「기간 지남」·「게시 예정」 공지도 표시와 함께 보고 기간을 다시 고칠 수 있다
   ===================================================================== */

IF COL_LENGTH('dbo.TBL_EMP_NOTICE','START_DT') IS NULL
    ALTER TABLE dbo.TBL_EMP_NOTICE ADD START_DT VARCHAR(8) NULL;   -- 게시 시작일
GO
IF COL_LENGTH('dbo.TBL_EMP_NOTICE','END_DT') IS NULL
    ALTER TABLE dbo.TBL_EMP_NOTICE ADD END_DT VARCHAR(8) NULL;     -- 게시 종료일(이 날까지 보인다)
GO

-- 확인 (두 칸이 보여야 한다)
SELECT COL_LENGTH('dbo.TBL_EMP_NOTICE','START_DT') AS START_DT_LEN, COL_LENGTH('dbo.TBL_EMP_NOTICE','END_DT') AS END_DT_LEN;
