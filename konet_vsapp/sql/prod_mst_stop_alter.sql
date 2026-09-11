/* ============================================================================
   상품마스터 — 「거래중지」 칼럼 추가 (2026-08-17 요청)

   ★왜 필요한가
     같은 물건이 두 코드로 갈라졌을 때, 잘못된 코드를 ***지울 수 없다.***
     거래가 붙으면 삭제가 막히고(매입가·판매가 이력·재고 원장), 지워서도 안 된다 —
     지우면 그 원장 행이 주인 없는 자료가 된다.
     ⇒ 지우는 대신 **「앞으로 쓰지 않는 코드」로 표시**한다.
       · 옛 전표·재고는 **그대로 유지**된다(이력 보존)
       · 새 매입·판매에서는 **고를 수 없게** 막는다

   ★ACTION_YN 과 섞지 않는다 — 축이 다르다.
       ACTION_YN='N'  = 삭제된 것 (목록에서 사라진다)
       STOP_YN  ='Y'  = 살아 있지만 **더 쓰지 않는 것** (목록엔 보이고 새 거래만 막힌다)
     둘을 한 칸으로 합치면 「지운 것」과 「안 쓰는 것」을 가릴 수 없다.

   되돌리기 :  ALTER TABLE TBL_PROD_MST DROP CONSTRAINT DF_PROD_MST_STOP_YN;
               ALTER TABLE TBL_PROD_MST DROP COLUMN STOP_YN, STOP_FR_DT, STOP_DTTM, STOP_USER, STOP_MEMO;
               DROP INDEX IX_PROD_MST_STOP ON TBL_PROD_MST;
               ⚠기본값 제약을 먼저 지워야 칼럼이 지워진다(SQL Server).
   ============================================================================ */

/* ★★「언제부터 중지인가」를 STOP_FR_DT 로 따로 둔다 (2026-08-17 지적) ─────────────────
     STOP_DTTM(누른 시각) 하나만 두면 ***지난 전표를 판단할 수 없다.***
     예) 7월까지 정상 거래하다 8월부터 안 쓰기로 한 코드를 8/17 에 중지 처리하면,
         STOP_DTTM 만 보고는 "7월 매입도 중지된 코드로 넣은 것"처럼 읽힌다.
     ⇒ 두 칸의 뜻이 다르다.
        STOP_FR_DT  = ***업무상 중지 시작일***(YYYYMMDD) — 이 날짜부터 새 거래를 막는다
        STOP_DTTM   = 누가 언제 그 처리를 **했는지**(감사 기록) — 업무 판단에 쓰지 않는다
     ⚠막을 때 견주는 것은 **STOP_FR_DT 와 전표일자**다(오늘 날짜가 아니다) —
       지난 일자로 전표를 넣는 일이 실제로 있으므로. */
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME='TBL_PROD_MST' AND COLUMN_NAME='STOP_YN')
BEGIN
    ALTER TABLE TBL_PROD_MST ADD
        STOP_YN    CHAR(1)       NOT NULL CONSTRAINT DF_PROD_MST_STOP_YN DEFAULT 'N',  -- 'Y' = 거래중지
        STOP_FR_DT VARCHAR(8)    NULL,      -- ★중지 시작일(YYYYMMDD) — 이 날짜부터 새 거래를 막는다
        STOP_DTTM  VARCHAR(19)   NULL,      -- 중지 처리를 한 시각(감사 기록)
        STOP_USER  NVARCHAR(50)  NULL,      -- 누가 처리했나
        STOP_MEMO  NVARCHAR(200) NULL;      -- 왜 중지했나 (예: "9904013214 로 대체")
END
GO

/* 조회가 STOP_YN 을 자주 거른다 — 상품 목록·매입/판매 상품검색이 전부 본다 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PROD_MST_STOP' AND object_id=OBJECT_ID('TBL_PROD_MST'))
BEGIN
    CREATE INDEX IX_PROD_MST_STOP ON TBL_PROD_MST (COMP_CD, STOP_YN, ACTION_YN);
END
GO

/* 확인 */
SELECT STOP_YN, COUNT(*) AS 건수 FROM TBL_PROD_MST GROUP BY STOP_YN;
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME='TBL_PROD_MST' AND COLUMN_NAME LIKE 'STOP%' ORDER BY ORDINAL_POSITION;
