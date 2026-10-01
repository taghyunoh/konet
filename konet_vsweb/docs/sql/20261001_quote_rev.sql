/* =====================================================================
   견적서 문서번호 = «담당자별 · 그 날짜» 번호 + 개정(판) 이력 (2026-10-01 — 사용자
   「문서번호는 담당자가 동일하면 Konet261001-01 · 작성 중엔 번호 하나 · 제출완료 뒤 변경은 -02, 또 변경되면 -03 ·
     채택 뒤 변경도 사유 넣고 -04 · 담당자가 다르면 -01 부터 · 최종이 만들어지기까지 변경이력 조회」 · 「담당자에 문서번호 증가로 보면 됨 · 해당년월일에」)

     · DOC_BASE  : 문서번호 앞부분 'Konet' + 견적일 yyMMdd (예 Konet261001). 개정판도 같은 값을 물려받는다.
     · REV_NO    : 뒤 두 자리 -NN. ★같은 (회사 · DOC_BASE · 담당자) 안에서 1 씩 늘어난다 — 새 견적서든 개정판이든 그 담당자의 그 날짜 다음 번호.
                   담당자가 다르면 같은 날짜라도 -01 부터.
     · PREV_SEQ  : 이 판이 어느 판을 고쳐 만든 것인지(QUOTE_SEQ). NULL = 처음 판. 이 사슬이 곧 변경 이력이다.
     · LATEST_YN : 그 사슬의 <최신 판>이면 Y. 개정판을 만들면 앞 판은 N 이 되고(ACTION_YN 은 Y 그대로 — 인쇄·이력 조회는 된다),
                   목록은 Y 만 보인다. 최신 판을 지우면 앞 판이 다시 Y 가 된다.
     · REV_MEMO · REV_DTTM · REV_USER : 이 판을 만든 사유·때·사람(제출완료 뒤 고칠 때 적는 「변경 사유」 — 채택 뒤에는 필수).
   ★작성 중(W)인 견적서는 종전대로 같은 번호에 덮어쓴다(옛 줄 ACTION_YN='N'). 제출완료(S)·채택(A)·거절(R)·보류(H) 뒤에 고쳐 저장하면
     새 판(REV_NO+1)이 생긴다 — 서비스 saveQuote 가 가른다.
   ★기존 자료 : 문서번호에서 DOC_BASE·REV_NO 를 떼어 채우고 전부 LATEST_YN='Y'(각각 제 사슬의 첫 판). 종전 -02 는 「그 날 두 번째 견적서」였지만
     새 규칙에서도 그 담당자의 다음 번호가 그 뒤부터 이어지므로 번호가 겹치지 않는다.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 <전체> 실행. 두 번 실행해도 안전(IF COL_LENGTH … IS NULL · 채우기는 NULL 인 줄만).
   ⚠WAR 배포 <전에> 실행할 것 — 새 매퍼가 이 칸들을 읽고 쓴다(견적서 목록·저장·작성·이력).
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_QUOTE_MST','DOC_BASE')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD DOC_BASE  NVARCHAR(30) NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','REV_NO')    IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD REV_NO    INT          NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','PREV_SEQ')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD PREV_SEQ  BIGINT       NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','LATEST_YN') IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD LATEST_YN CHAR(1)      NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','REV_MEMO')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD REV_MEMO  NVARCHAR(300) NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','REV_DTTM')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD REV_DTTM  VARCHAR(19)  NULL;
GO
IF COL_LENGTH('dbo.TBL_QUOTE_MST','REV_USER')  IS NULL  ALTER TABLE dbo.TBL_QUOTE_MST ADD REV_USER  NVARCHAR(50) NULL;
GO
/* ── 기존 줄 채우기 — 문서번호 'Konet261001-02' → DOC_BASE 'Konet261001' · REV_NO 2. '-' 가 없거나 뒤가 숫자가 아니면 그대로 1 ── */
UPDATE dbo.TBL_QUOTE_MST
   SET DOC_BASE = CASE WHEN CHARINDEX('-', DOC_NO) > 1 THEN LEFT(DOC_NO, CHARINDEX('-', DOC_NO) - 1) ELSE DOC_NO END,
       REV_NO   = CASE WHEN CHARINDEX('-', DOC_NO) > 1 AND ISNUMERIC(SUBSTRING(DOC_NO, CHARINDEX('-', DOC_NO) + 1, 10)) = 1
                       THEN TRY_CAST(SUBSTRING(DOC_NO, CHARINDEX('-', DOC_NO) + 1, 10) AS INT) ELSE 1 END
 WHERE DOC_BASE IS NULL;
GO
UPDATE dbo.TBL_QUOTE_MST SET REV_NO = 1 WHERE REV_NO IS NULL OR REV_NO < 1;
GO
UPDATE dbo.TBL_QUOTE_MST SET LATEST_YN = 'Y' WHERE LATEST_YN IS NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_QUOTE_MST_REV' AND object_id = OBJECT_ID('dbo.TBL_QUOTE_MST'))
  CREATE INDEX IX_TBL_QUOTE_MST_REV ON dbo.TBL_QUOTE_MST (COMP_CD, DOC_BASE, MGR_NM, REV_NO);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_QUOTE_MST_PREV' AND object_id = OBJECT_ID('dbo.TBL_QUOTE_MST'))
  CREATE INDEX IX_TBL_QUOTE_MST_PREV ON dbo.TBL_QUOTE_MST (PREV_SEQ);
GO
/* ── 확인 : 일곱 칸 모두 숫자가 나오고, 아래 표에 NULL 이 없어야 한다 ── */
SELECT COL_LENGTH('dbo.TBL_QUOTE_MST','DOC_BASE') AS docBase, COL_LENGTH('dbo.TBL_QUOTE_MST','REV_NO') AS revNo,
       COL_LENGTH('dbo.TBL_QUOTE_MST','PREV_SEQ') AS prevSeq, COL_LENGTH('dbo.TBL_QUOTE_MST','LATEST_YN') AS latestYn,
       COL_LENGTH('dbo.TBL_QUOTE_MST','REV_MEMO') AS revMemo, COL_LENGTH('dbo.TBL_QUOTE_MST','REV_DTTM') AS revDttm, COL_LENGTH('dbo.TBL_QUOTE_MST','REV_USER') AS revUser;
SELECT QUOTE_SEQ, DOC_NO, DOC_BASE, REV_NO, MGR_NM, LATEST_YN, PREV_SEQ, ACTION_YN FROM dbo.TBL_QUOTE_MST ORDER BY QUOTE_SEQ DESC;
