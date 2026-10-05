/* =====================================================================
   견적 → 판매등록 연결 (2026-10-06 — 사용자 「견적서관리에서 등록·제출서·채택 과정 및 판매등록 진행 상황 볼 수 있게」)

   견적서(TBL_QUOTE_MST)에는 이미 진행 상태가 있다 — W 작성 중 / S 제출완료 / A 채택 / R 거절 / H 보류 + 항목별 일자.
   없던 것은 **마지막 단계**다 : 어느 판매가 어느 견적에서 나온 것인지 알 길이 없었다.
     · 견적서의 수신처(RECV_NM)는 «자유 글자»이고 판매전표는 «거래처 코드»다 — 이름으로 짝을 맞추면 틀린 짝이 생긴다.
       그래서 추정하지 않고 **판매전표에 견적 번호를 적어 둔다**(판매 등록 화면 [📄 견적서에서 가져오기]).

     · QUOTE_SEQ    : 이 판매가 나온 견적서(TBL_QUOTE_MST.QUOTE_SEQ). 비어 있으면 견적을 거치지 않은 판매다(대부분이 그렇다).
     · QUOTE_DOC_NO : 그때의 문서번호. ★번호를 «함께» 남기는 까닭 — 견적서는 판이 바뀌면 새 줄이 되고 옛 줄은 닫힌다.
                      번호만 보고도 「어느 견적에서 나온 판매인지」를 말할 수 있어야 한다.

   ★칸을 더하기만 한다 — 기존 판매전표는 둘 다 NULL 이고, 화면·조회는 NULL 을 「견적 없는 판매」로 본다.
   실행 : 사용자가 운영 DB(KOLGSDB)에서 <전체> 실행. 두 번 실행해도 안전(IF COL_LENGTH … IS NULL).
   ⚠WAR 배포 <전에> 실행할 것 — 새 매퍼가 이 칸들을 읽고 쓴다(판매 저장·견적 진행 현황).
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_SALES_TRX_MST','QUOTE_SEQ')    IS NULL
  ALTER TABLE dbo.TBL_SALES_TRX_MST ADD QUOTE_SEQ    BIGINT        NULL;
GO
IF COL_LENGTH('dbo.TBL_SALES_TRX_MST','QUOTE_DOC_NO') IS NULL
  ALTER TABLE dbo.TBL_SALES_TRX_MST ADD QUOTE_DOC_NO NVARCHAR(50)  NULL;
GO
/* 견적 번호로 판매를 찾는 조회(견적서 관리의 「판매」 배지 · 진행 현황 4단계)가 그 병원 행만 훑게 한다 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_SALES_TRX_MST_QUOTE' AND object_id = OBJECT_ID('dbo.TBL_SALES_TRX_MST'))
  CREATE INDEX IX_TBL_SALES_TRX_MST_QUOTE ON dbo.TBL_SALES_TRX_MST (COMP_CD, QUOTE_SEQ) WHERE QUOTE_SEQ IS NOT NULL;
GO

/* ── 확인 ── */
SELECT COUNT(*) AS 판매전표, SUM(CASE WHEN QUOTE_SEQ IS NULL THEN 0 ELSE 1 END) AS 견적에서온것
  FROM dbo.TBL_SALES_TRX_MST WHERE ACTION_YN = 'Y';   -- 지금은 견적에서온것 = 0 이 정상(앞으로 쌓인다)
SELECT ISNULL(NULLIF(STAT_GB,''),'W') AS 진행상태, COUNT(*) AS 건수
  FROM dbo.TBL_QUOTE_MST WHERE ACTION_YN = 'Y' GROUP BY ISNULL(NULLIF(STAT_GB,''),'W') ORDER BY 1;
