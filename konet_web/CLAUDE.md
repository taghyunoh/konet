# konet_web 프로젝트 메모

## 스택/구조
- **MSSQL** + egovframework + MyBatis, 패키지 `egovframework.sejong`
- 뷰: Apache Tiles. `.raw/*` = tiles 래핑 없는 단독 페이지, `.main/*` = 표준 레이아웃(main.jsp+top.jsp, top.jsp는 사실상 비어있음 — 실제 네비 없음)
- **물류관리 화면은 `.raw/main/admin/logistics_demo2.jsp`(약 3000줄) 단독 셸** — 좌측 사이드바 + 모든 패널 + JS를 한 파일에 내장. 대시보드1(출고현황표)=`logistics_demo1.jsp`(iframe 로드). 사이드바 메뉴 onclick이 demo2 내부 함수/패널에 강결합 → 리팩터링 시 주의.
- 컨벤션: PK `XXX_SEQ IDENTITY`, 품목연결 `PROD_SEQ`+`PROD_CD`, 금액 `DECIMAL(18,2)`, 일자 `NVARCHAR(8)'YYYYMMDD'`·일시 `NVARCHAR(19)`, 소프트삭제 `ACTION_YN`, 감사컬럼 `REG_/UPD_`. 날짜 저장 시 `REPLACE(...,'-','')`. XML `<=`/`<` 는 CDATA 필수.

## 상품 가격/재고 관리 (prodmst.jsp ↔ TBL_PROD_MST)
상품관리 각 행 클릭 → 하단 도킹 **이력/재고 3탭**(매입가/판매가/재고 수불).
- **테이블 4개**(DDL: `sql/logistics_price_stock_ddl.sql` 1~4): `TBL_PROD_INPRICE_HST`(매입가이력), `TBL_PROD_SALEPRICE_HST`(판매가이력), `TBL_STOCK_LEDGER`(수불원장), `TBL_STOCK_MST`(현재고집계)
- 매입가/판매가 등록 → `TBL_PROD_MST.IN_PRICE/SALE_PRICE` 동기화. 재고 수불 입출고 → `recalcStockMst`(MERGE)로 현재고·이동평균 재집계.
- 재고 입고폼에 **매입처(VENDOR_CD) 입력** 有. 입고 단가는 마스터 IN_PRICE 자동채움(수정가능).
- 상품 삭제 가드: 연관(이력/재고) 있으면 삭제 차단(`countProdRelated`).
- DTO: ProdInpriceDTO/ProdSalepriceDTO/StockLedgerDTO/StockMstDTO. 엔드포인트 `/prod/inprice*·saleprice*·stock*`.

## 마감관리 (logistics_demo2.jsp 좌측 '마감관리 ★')
서브메뉴 4개 = **매출마감 / 매입마감 / 재고마감 / 마감현황(월계표)**. **월마감(YYYYMM)** 단위. 상단 매출/매입 업로드·출고데이타저장 버튼은 삭제됨.

### 공통 UX (매출·매입·재고 마감 3화면)
기간(마감월 선택→시작/종료일자 자동세팅, 직접조정 가능) + 그룹핑·소계·접기/펼치기(⊟전체토글) + **행 단위 페이징(25행/page, 페이지가 그룹 중간 시작 시 문맥 헤더 표시)** + 상단 **총합계**(teal, 흰글자).

### 매출마감 (출고 기준)
- 원천 `TBL_SHIPOUT_MST`(SHPOUT_DT) × **출고일자 시점 유효단가**(SALEPRICE_HST/INPRICE_HST APPLY_DT≤출고일 최신, 없으면 TBL_PROD_MST 폴백, saleSrc/inSrc='이력'/'마스터' 표기)
- **3탭**: 출고장별(2단 트리 = 대표 오산센터묶음[E200/E300/E400/E600/E700→오산센터, 제주→오산센터, 그 외 dcNm] → 개별 물류센터 출고장 → 품목) / 사업장별 / 품목
- 컬럼: 출고수량·매입단가·출고단가·매출액·매입액·순마진액. 엔드포인트 `/shipout/selectClosing.do`, ClosingDTO(ym·fromDt·toDt·dcCd·dcNm…)

### 매입마감 (**입고 기준**, COGS 아님)
- `TBL_STOCK_LEDGER` 당월 입고(IO_GB='I')를 **매입처(VENDOR_CD)×품목**별 집계. 매입단가=매입액÷입고수량(가중평균)
- 매입처별 그룹 + 소계 + 접기/펼치기. 엔드포인트 `/shipout/selectInboundClosing.do`

### 재고마감
- `TBL_STOCK_LEDGER`: 기초(시작일자 이전 누계)+입고(+반품)−출고±조정=기말, 재고금액=기말×이동평균. `selectStockClosing`은 `WITH B`(기간경계)+품목별 대표매입처 OUTER APPLY
- **2탭**: 매입처별 품목코드 / 품목코드. 엔드포인트 `/shipout/selectStockClosing.do`

### 마감확정 (월 확정·잠금·이월) — TBL_CLOSING_MST / TBL_CLOSING_STOCK
DDL: `sql/logistics_price_stock_ddl.sql` 5~6.
- **확정**(마감현황 🔒): 3종 집계→헤더 upsert(매출/COGS/마진/매입/기말재고금액)+재고 스냅샷 저장. `confirmClosing`. UNIQUE(CLOSE_YM).
- **잠금**: 확정월의 재고 수불(insert/deleteStockLedger)에 `guardClosed`로 등록·삭제 차단.
- **해제**(🔓): 헤더 ACTION_YN='N' + 스냅샷 삭제.
- DTO: ClosingMstDTO. 엔드포인트 `/shipout/{selectClosingStatus,confirmClosing,cancelClosing}.do`.
- 주의: 마감현황 KPI '매입액'=출고기반 COGS(selectClosing), 확정헤더 PURCHASE_AMT=입고기반 — 의도된 차이.

## 업무 설명서 동기화 (필수 방침)
- **메뉴·기능이 바뀔 때마다 `logistics_demo2.jsp`의 업무설명서 패널(`panel-guide`)도 반드시 함께 수정**한다 (사용자 상시 요청 2026-07-05). 화면 추가/삭제/이동, 성격 변경 시 설명서 표의 해당 행을 갱신.

## 배포
- **.java / User_SQL.xml 변경 → WAR 재빌드 + 톰캣 재배포 필수.** JSP만 변경 시 파일 교체로 반영.
- DB: 위 6개 테이블(재고4+마감2) 선생성 필요.

## 진행/대기
- [완료] 상품 가격/재고, 마감 3종(공통 UX), 마감확정(확정·잠금·해제)
- [완료] **이월 기초 스냅샷 연동** — selectStockClosing에서 기초 = ISNULL(직전 확정월 TBL_CLOSING_STOCK.END_QTY, 원장 재계산). CTE B(prevYm=FORMAT(DATEADD(MONTH,-1,fromB월),'yyyyMM')) + LEFT JOIN TBL_CLOSING_STOCK cs. avgInPrice도 스냅샷 폴백. XML만 변경(자바 무변경).
- [대기·협의후] **재고부족 출고 차단** — 출고/조정(−) 시 현재고 초과 거부(음수재고 방지). 마감 잠금과 별개
- **[확정 방침 2026-07-05] 출고→재고 미연동(현행 유지)**: 출고는 TBL_SHIPOUT_MST(발주현황표 업로드)로만 잡히고 TBL_STOCK_LEDGER에 자동기록 안 함(saveShipoutMst는 원장에 안 씀). 따라서 **재고현황(현재고)·재고마감은 입고만 반영 → 출고 미차감(실제 재고와 다름)**. 사용자 결정으로 현행 유지. 재연동 요청 시 옵션: (A)출고저장시 원장 'O' 자동INSERT(REF_GB='SHIPOUT', 재업로드 시 삭제후재삽입, ITEM_CD=PROD_CD 매칭) (B)재고 쿼리에서 SHIPOUT 직접 차감. 매출/매입마감은 각각 SHIPOUT/입고 원천이라 정상.
- [대기] 마감 출고 잠금(확정월 shipout 저장 차단), 매출/매입/재고 화면 '🔒 마감 확정' 버튼(현재 플레이스홀더) 연동, 마감 엑셀 출력, 일마감(안함 — 월마감만)

## 참고 이력 (이 프로젝트에서 겪은 것)
- Eclipse 빨간X = WTP 검증기 오탐(대용량 인라인 JS). 미사용 JSTL taglib 제거로 일부 해소.
- 사이드바 메뉴 대거 삭제(창고/입고등록/재고현황/재고위치/주문/발주리스트/출고지시/출고내역) — 데모 패널은 잔존(도달불가·display:none·무해).
