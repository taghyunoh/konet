/* =====================================================================
   발주 잔량(미입고) · 부분 입고 · 발주↔매입 연결 (2026-09-16, 설계 = docs/설계_발주잔량_부분입고_2026-09-16.md)
     · TBL_PURCHASE_DTL.PO_SEQ / PO_DTL_SEQ : 이 매입 줄이 어느 발주서·어느 발주 줄에서 왔는가 (연결 키 — 입고수량은 저장하지 않고 이걸로 센다)
     · TBL_PURCHASE_MST.PO_SEQ            : 대표 발주서(표시용)
     · TBL_PO_DTL.CLOSE_YN / CLOSE_RMK     : 잔량이 있어도 「더 안 온다」로 닫은 줄
   실행 : 사용자가 운영 DB(KOLGSDB)에서 직접. 두 번 실행해도 안전(IF … IS NULL).
   ⚠GO 로 두 묶음 — 새 칸을 같은 배치에서 바로 쓰면 컴파일 단계에서 「칸 없음」이 난다.
   형은 가리키는 표를 그대로 베꼈다 : PO_SEQ·PO_DTL_SEQ = BIGINT (TBL_PO_MST/DTL 이 BIGINT IDENTITY).
   ===================================================================== */
IF COL_LENGTH('dbo.TBL_PURCHASE_DTL','PO_SEQ')     IS NULL ALTER TABLE dbo.TBL_PURCHASE_DTL ADD PO_SEQ     BIGINT NULL;
IF COL_LENGTH('dbo.TBL_PURCHASE_DTL','PO_DTL_SEQ') IS NULL ALTER TABLE dbo.TBL_PURCHASE_DTL ADD PO_DTL_SEQ BIGINT NULL;
IF COL_LENGTH('dbo.TBL_PURCHASE_MST','PO_SEQ')     IS NULL ALTER TABLE dbo.TBL_PURCHASE_MST ADD PO_SEQ     BIGINT NULL;
IF COL_LENGTH('dbo.TBL_PO_DTL','CLOSE_YN')  IS NULL ALTER TABLE dbo.TBL_PO_DTL ADD CLOSE_YN  CHAR(1) NOT NULL CONSTRAINT DF_TBL_PO_DTL_CLOSE_YN DEFAULT 'N';
IF COL_LENGTH('dbo.TBL_PO_DTL','CLOSE_RMK') IS NULL ALTER TABLE dbo.TBL_PO_DTL ADD CLOSE_RMK NVARCHAR(200) NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TBL_PURCHASE_DTL_PODTL' AND object_id = OBJECT_ID('dbo.TBL_PURCHASE_DTL'))
  CREATE INDEX IX_TBL_PURCHASE_DTL_PODTL ON dbo.TBL_PURCHASE_DTL (PO_DTL_SEQ, ACTION_YN);
GO
/* ── 이관 : 이미 전환된 발주서(TBL_PO_MST.PURCH_SEQ 있음)의 매입 명세에 발주 줄을 짝지어 넣는다.
     짝 = 같은 전표 안 같은 품목코드, 같은 품목이 여러 줄이면 ROW_NO 차례. 이미 채워진 줄(PO_DTL_SEQ 있음)은 건드리지 않는다.
     못 짝지은 줄은 비워 둔다 → 그 발주 줄은 「입고 0」으로 보인다(아래 확인 SELECT 로 사람이 본다). */
;WITH PD AS (
    SELECT D.DTL_SEQ, D.PURCH_SEQ, D.PROD_CD,
           ROW_NUMBER() OVER (PARTITION BY D.PURCH_SEQ, D.PROD_CD ORDER BY D.ROW_NO, D.DTL_SEQ) AS rn
      FROM dbo.TBL_PURCHASE_DTL D
     WHERE D.ACTION_YN = 'Y' AND D.PO_DTL_SEQ IS NULL
), OD AS (
    SELECT O.PO_DTL_SEQ, O.PO_SEQ, O.PROD_CD, M.PURCH_SEQ,
           ROW_NUMBER() OVER (PARTITION BY O.PO_SEQ, O.PROD_CD ORDER BY O.ROW_NO, O.PO_DTL_SEQ) AS rn
      FROM dbo.TBL_PO_DTL O
      JOIN dbo.TBL_PO_MST M ON M.PO_SEQ = O.PO_SEQ AND M.ACTION_YN = 'Y' AND M.PURCH_SEQ IS NOT NULL
     WHERE O.ACTION_YN = 'Y'
)
UPDATE D SET D.PO_SEQ = OD.PO_SEQ, D.PO_DTL_SEQ = OD.PO_DTL_SEQ
  FROM dbo.TBL_PURCHASE_DTL D
  JOIN PD ON PD.DTL_SEQ = D.DTL_SEQ
  JOIN OD ON OD.PURCH_SEQ = PD.PURCH_SEQ AND OD.PROD_CD = PD.PROD_CD AND OD.rn = PD.rn;

UPDATE PM SET PM.PO_SEQ = M.PO_SEQ
  FROM dbo.TBL_PURCHASE_MST PM
  JOIN dbo.TBL_PO_MST M ON M.PURCH_SEQ = PM.PURCH_SEQ AND M.ACTION_YN = 'Y'
 WHERE PM.PO_SEQ IS NULL;
GO
/* 확인 */
SELECT '연결된 매입 줄' AS what, COUNT(*) AS cnt FROM dbo.TBL_PURCHASE_DTL WHERE PO_DTL_SEQ IS NOT NULL AND ACTION_YN = 'Y'
UNION ALL
SELECT '전환됐는데 매입 줄을 하나도 못 짝지은 발주서', COUNT(*)
  FROM dbo.TBL_PO_MST M
 WHERE M.ACTION_YN = 'Y' AND M.PURCH_SEQ IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.TBL_PURCHASE_DTL P WHERE P.PO_SEQ = M.PO_SEQ AND P.ACTION_YN = 'Y');
