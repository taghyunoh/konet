/* =====================================================================================
   TBL_EXT_ITEM_MST — 「추가 매칭코드」(ADD_ITEM_CD) 신설                          2026-09-13
   -------------------------------------------------------------------------------------
   왜 만드나
     같은 물건을 싸게 대체 구매하면 그 품목을 매칭코드로 등록한다. 그런데 삼성은 새 코드를 잘 몰라
     **옛 코드로 발주**를 보낸다. 그 옛 코드도 이 줄의 주코드로 잡아 **재고를 주코드 하나로** 모은다.
     (실측 2026-09-13 : 1칸 펄프용기 몸체가 1000759548 +48 / 9904013208 +50 / 주코드 9904013353 −270 으로 갈라짐)

   해석 순서 (발주현황표·정산서 → 우리 품목)
       XREF → 매칭코드(EXT_ITEM_CD) → ★추가 매칭코드(ADD_ITEM_CD) → 코드 직결
     · 기존 매칭(품목코드 칸)이 먼저 — 추가 매칭은 거기서 못 찾았을 때만 본다
     · 코드 직결보다 먼저 — 옛 코드가 상품마스터에 있어도 주코드로 간다(재고의 주인은 주코드)
     · 거래처를 가리지 않는다 — 발주하는 쪽이 보내는 코드이므로
     · 매입·재고조정의 서브코드 관문도 이 코드를 서브코드로 본다(주코드로 바꾸라고 막는다)

   유일
     한 코드는 표 전체에서 **한 곳에만** — 다른 줄의 추가 매칭코드와도, 어느 줄의 품목코드와도 겹치면 안 된다
     (겹치면 어느 주코드로 갈지 정할 수 없다).
     아래 인덱스는 «추가 코드끼리»만 막는다. 품목코드와의 겹침은 저장 때 서버가 막는다(selectExtCodeConflict).

   ★이 스크립트를 먼저 돌린 뒤 WAR 를 배포할 것 — 새 매퍼가 ADD_ITEM_CD 를 읽으므로 칸이 없으면
     매칭코드 조회·업로드 해석이 전부 실패한다. 재실행 안전.
   ===================================================================================== */

IF COL_LENGTH('dbo.TBL_EXT_ITEM_MST','ADD_ITEM_CD') IS NULL
BEGIN
    ALTER TABLE dbo.TBL_EXT_ITEM_MST ADD ADD_ITEM_CD NVARCHAR(30) NULL;   -- EXT_ITEM_CD 와 같은 길이
    PRINT 'ADD_ITEM_CD 추가';
END
ELSE PRINT 'ADD_ITEM_CD 이미 있음 — 건너뜀';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_EXT_ITEM_ADD' AND object_id=OBJECT_ID('dbo.TBL_EXT_ITEM_MST'))
BEGIN
    CREATE UNIQUE INDEX UX_EXT_ITEM_ADD ON dbo.TBL_EXT_ITEM_MST (COMP_CD, ADD_ITEM_CD)
        WHERE ACTION_YN = 'Y' AND ADD_ITEM_CD IS NOT NULL;
    PRINT 'UX_EXT_ITEM_ADD 생성';
END
ELSE PRINT 'UX_EXT_ITEM_ADD 이미 있음 — 건너뜀';
GO

/* 확인
SELECT EXT_SEQ, EXT_ITEM_CD, ADD_ITEM_CD, PROD_CD, EXT_ITEM_NM
  FROM dbo.TBL_EXT_ITEM_MST WHERE ACTION_YN='Y' AND ADD_ITEM_CD IS NOT NULL;
*/

/* 되돌리기 (코드를 옛 판으로 돌린 뒤에)
DROP INDEX UX_EXT_ITEM_ADD ON dbo.TBL_EXT_ITEM_MST;
ALTER TABLE dbo.TBL_EXT_ITEM_MST DROP COLUMN ADD_ITEM_CD;
*/
