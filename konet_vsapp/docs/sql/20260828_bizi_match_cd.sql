/* ============================================================================
   사업장 공통 매칭코드 — TBL_BIZI_MST 칸 추가                    2026-08-28
   ----------------------------------------------------------------------------
   목적 : 여러 사업장(점포)을 하나로 묶는 <공통 매칭코드 + 매칭명칭>.
          예) (데블다이스) 강남시티점 / 광주충장로점 / 동성로1호점 …  →  M0001 (데블다이스)

   쓰는 곳 : 지금은 [기준정보관리 > 거래처관리(사업장)] 화면의 등록·조회·엑셀뿐.
             ★출고현황표(대시보드/가로표/엑셀)의 사업장 묶음에는 아직 쓰지 않는다
               — 2026-08-28 「아직은 등록만」으로 확정.

   실행 : SSMS 등에서 KOLGSDB 에 직접 실행. (로컬 톰캣이 운영 DB 를 보고 있어 앱에서 돌리지 않는다)
   되돌리기 : 맨 아래 주석 참고.
   ============================================================================ */

USE KOLGSDB;
GO

/* 1) 칸 추가 — 이미 있으면 건너뛴다(여러 번 실행해도 안전) */
IF COL_LENGTH('dbo.TBL_BIZI_MST', 'MATCH_CD') IS NULL
    ALTER TABLE dbo.TBL_BIZI_MST ADD MATCH_CD nvarchar(20) NULL;
GO
IF COL_LENGTH('dbo.TBL_BIZI_MST', 'MATCH_NM') IS NULL
    ALTER TABLE dbo.TBL_BIZI_MST ADD MATCH_NM nvarchar(100) NULL;
GO

/* 2) 찾기용 인덱스 — 매칭코드로 묶어 보는 조회가 잦다 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_TBL_BIZI_MST_MATCH_CD' AND object_id=OBJECT_ID('dbo.TBL_BIZI_MST'))
    CREATE INDEX IX_TBL_BIZI_MST_MATCH_CD ON dbo.TBL_BIZI_MST (MATCH_CD) INCLUDE (BIZ_CD, BIZ_NM);
GO

/* 3) 확인 */
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME='TBL_BIZI_MST' AND COLUMN_NAME IN ('MATCH_CD','MATCH_NM');
GO

/* ── 되돌리기 (필요할 때만) ──────────────────────────────────────────────
DROP INDEX IX_TBL_BIZI_MST_MATCH_CD ON dbo.TBL_BIZI_MST;
ALTER TABLE dbo.TBL_BIZI_MST DROP COLUMN MATCH_CD, MATCH_NM;
   ──────────────────────────────────────────────────────────────────── */
