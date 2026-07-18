# konet_web 프로젝트 메모

## 스택/구조
- **MSSQL** + egovframework + MyBatis, 패키지 `egovframework.sejong`
- 뷰: Apache Tiles. `.raw/*` = tiles 래핑 없는 단독 페이지, `.main/*` = 표준 레이아웃(main.jsp+top.jsp, top.jsp는 사실상 비어있음 — 실제 네비 없음)
- **물류관리 화면은 `.raw/main/admin/logistics_demo2.jsp`(약 3000줄) 단독 셸** — 좌측 사이드바 + 모든 패널 + JS를 한 파일에 내장. 대시보드1(출고현황표)=`logistics_demo1.jsp`(iframe 로드). 사이드바 메뉴 onclick이 demo2 내부 함수/패널에 강결합 → 리팩터링 시 주의.
- 컨벤션: PK `XXX_SEQ IDENTITY`, 품목연결 `PROD_SEQ`+`PROD_CD`, 금액 `DECIMAL(18,2)`, 일자 `NVARCHAR(8)'YYYYMMDD'`·일시 `NVARCHAR(19)`, 소프트삭제 `ACTION_YN`, 감사컬럼 `REG_/UPD_`. 날짜 저장 시 `REPLACE(...,'-','')`. XML `<=`/`<` 는 CDATA 필수.

## 상품 가격/재고 관리 (prodmst.jsp ↔ TBL_PROD_MST)
상품관리 각 행 클릭 → 하단 도킹 **이력/재고 4탭**(매입가/판매가/매출단가(조회)/재고 수불).
- **거래처 콤보(vsel)**: 매입처(매입가·재고입고)=매입 거래처 121종, 판매처(판매가)=매출 거래처 334종. '선택 안에 찾기' — 버튼 클릭→드롭다운 내 검색창, Enter=첫 후보, 아래 공간 부족 시 위로 열림(하단 도킹 패널이라 보통 위로). 데이터 원천은 `_vdata(id)` — `sl_vendor`만 SVENDORS(매출).
- 적용일/거래일 기본값 = 오늘(진입 시 + 품목 클릭 시).
- **테이블 4개**(DDL: `sql/logistics_price_stock_ddl.sql` 1~4): `TBL_PROD_INPRICE_HST`(매입가이력), `TBL_PROD_SALEPRICE_HST`(판매가이력), `TBL_STOCK_LEDGER`(수불원장), `TBL_STOCK_MST`(현재고집계)
- 매입가/판매가 등록 → `TBL_PROD_MST.IN_PRICE/SALE_PRICE` 동기화. 재고 수불 입출고 → `recalcStockMst`(MERGE)로 현재고·이동평균 재집계.
- 재고 입고폼에 **매입처(VENDOR_CD) 입력** 有. 입고 단가는 마스터 IN_PRICE 자동채움(수정가능).
- 상품 삭제 가드: 연관(이력/재고) 있으면 삭제 차단(`countProdRelated`).
- DTO: ProdInpriceDTO/ProdSalepriceDTO/StockLedgerDTO/StockMstDTO. 엔드포인트 `/prod/inprice*·saleprice*·stock*`.
- **매출단가(조회) 탭 신설(2026-07-18)**: `TBL_SALES_MST` 조회 전용(납품일자·출고장·발주번호·판매단가·출고량·매출액·원본파일 + 상단 요약). 기존 `/sales/selectSalesMst.do`를 `itemCd`로 호출 — 서버코드 무변경, 화면에서 품목 필터 이중 적용(재시작 전 대비). **판매가 탭은 자체 입력 이력 전용 유지가 사용자 확정 방침** — TBL_SALES_MST를 판매가 이력 조회에 UNION 연계했다가 같은 날 원복함(다시 섞지 말 것).
- **수불 내역 사업장 표시(2026-07-18)**: `selectStockLedgerList` — SHIPOUT 자동연동 행은 BIZ_CD가 NULL(품목·일자 합산이라)이므로 `TBL_SHIPOUT_MST`에서 같은 품목+출고일자(REF_NO)의 BIZ_NM을 STUFF/FOR XML로 콤마 연결해 표시(CUR_QTY>0 활성분). 화면(재고현황 `stkLedgerDetail`)은 여러 곳이면 첫 곳+`＋N` 클릭 펼침(`_bizCell`/`_bizToggle`, logistics_demo2.jsp).

## 매출 엑셀 업로드 (견적서관리 ▸ 매출 엑셀 업로드) — TBL_SALES_MST
출고장(평택/오산/왜관/용인)이 자기 시스템에서 뽑아주는 엑셀(생성기 `DataLudi`, 시트 `Sheet1`, 17컬럼)을 원본 보관.
- **★관점 뒤집기(가장 중요)**: 엑셀은 **출고장 기준**이다. 우리 기준으로 환산해 담는다 —
  `입고량→OUT_QTY(우리 출고량)` · `단가→SALE_PRICE(우리 판매단가)` · `매입금액→SALE_AMT(우리 매출액)` · `입고일자→OUT_DT(우리 출고일자)`.
  **엑셀의 '매입금액'은 우리 매입이 아니다.** 우리 매입가는 무관하게 `TBL_PROD_MST.IN_PRICE`/`TBL_PROD_INPRICE_HST`가 계속 담당.
  (근거: 평택 엑셀 단가 vs 매출마감 화면 대조 → 6건 중 5건이 **출고단가**와 정확히 일치, 매입단가 일치 0건. 남은 1건은 화면이 월 가중평균이라 월중 단가변경으로 설명)
- 낱알 = `ORD_NO`+`ORD_ITEM_NO` → **TBL_SHIPOUT_MST의 ORD_NO+ORD_ITEM_NO와 동일**(추후 조인 가능). 배치키 = (DLV_DT 납품일자 + DC_NM 출고장), JOB_SEQ 버전 + ACTION_YN — shipout과 같은 패턴.
- **TBL_SHIPOUT_MST에 안 붙인 이유**: 발주표는 재업로드 시 통째 이력화 → 단가를 얹으면 확정금액이 같이 사라짐. 원천·생명주기가 다름(발주표=물류지시 / 이 표=금액확정본).
- **엑셀 함정(실측)**: ①출고장은 파일 안에 없고 **파일명에만** 있음(`2026.07.11_평택.xlsx`, 구분자 `_`/공백) ②한 파일에 발주번호 여러 개(평택=3개) + **B열 병합셀(B3:B63)** → 빈칸이면 위 값 승계, 병합 밖 행은 자기 값 유지 ③수량 **소수·음수**(발주량 0.49/출고량 -0.49 반품행) → INT 금지, DECIMAL(18,3)/BigDecimal ④날짜는 **엑셀 serial**(46214=2026-07-11) ⑤**마지막 합계행** → 품목코드 없는 행으로 판별해 제외 ⑥매입금액=입고량×단가 (전 행 검산 일치)
- 납품일자는 엑셀 안에 있으므로 **엑셀 값을 쓴다**(파일명 날짜는 참고용). 출고장만 파일명에서 확보 → 화면에서 수정 가능.
- **판매단가 이력 자동반영(★매출마감과 연결)**: 저장 시 `mergeSalepriceFromSales`(MERGE)로 `TBL_PROD_SALEPRICE_HST` upsert — 키 `(PROD_CD + APPLY_DT)`, **APPLY_DT = DLV_DT(납품일자 = 발주일자)**. 매출마감이 `APPLY_DT <= DLV_DT 최신`으로 집으므로 출고단가가 `(마스터)` 폴백 → **`(이력)` 실제 확정가**로 바뀐다.
  - 같은 품목·같은 날 단가가 다르면 **넣지 않고 건너뜀**(추측 금지) → 응답 `skip`. MERGE 반환 0 = 품목코드가 TBL_PROD_MST에 없거나 이미 같은 단가.
  - **마스터 SALE_PRICE는 안 건드림**(과거 파일 업로드가 현재가를 덮는 사고 방지) → 상품관리 현재가와 이력이 다를 수 있음.
  - 실측 확인: 출고장 4곳 공통품목 25종 단가 **충돌 0** / 파일 내 중복품목 2종도 단가 동일 → 품목+적용일자 이력으로 표현 가능.
  - 이력 반영 실패가 매출 저장을 롤백하지 않도록 별도 try(로그만).
- 저장 응답 = JSON `{saved, price, none, skip}` (행수 / 이력반영 품목수 / 변화없음 / 충돌제외).
- **조회 검색 확장(2026-07-18)**: 조회 줄에 품목코드/품목명 검색란 추가 — `selectSalesMst`에 `itemCd` 파라미터, `ITEM_CD·ITEM_NM LIKE OR` 부분일치(비우면 전체).
- DDL `sql/sales_mst_ddl.sql`. 엔드포인트 `/sales/{saveSalesMst,selectSalesMst,selectSalesSrcFiles}.do`, SalesDTO.
- 이력: 처음 `TBL_PURCH_MST`(매입 관점)로 잘못 만들었다가 사용자 정정으로 전면 교체 — 그 테이블은 2026-07-17 삭제 완료(코드·DB 모두 흔적 없음).
- [대기] 견적서 작성/목록/출력, 판매단가 → `TBL_PROD_SALEPRICE_HST` 적재(APPLY_DT=출고일자) 여부

## 거래처 마스터 — TBL_VENDOR_MST (DDL `sql/vendor_mst_ddl.sql` / 초기적재 `sql/vendor_mst_insert.sql`)
원천 = 회계시스템이 뽑아주는 `거래처리스트.xls`. **확장자만 xls, 실제는 HTML 표**(POI 가 NotOLE2FileException 냄) — 40컬럼 × 477행.
- **★TBL_BIZI_MST 와 별개**(합치지 말 것): 코드체계가 다르고 **코드 교집합 0 / 이름 교집합 0(155건 전부)**. `TBL_BIZI_MST`=물류센터가 배송하는 **사업장(점포)** `A0386956`형 / `TBL_VENDOR_MST`=회계 **거래처** `0089`·`2-57`형.
- **원본 코드는 PK 불가**: 477행 중 45종 중복 — 같은 거래처가 **거래유형/담당자별로 여러 줄**인 비정규화(예: `00398 (주)카레타` 매출+매입, `3-2 아방뮤제` 담당 2명). → **코드기준 병합 432종**(매출 311 / 매입 98 / 매입&매출 23), 거래유형은 합집합. 담당자는 대표 1명만 남음(복수 필요 시 별도 테이블).
- **제외 컬럼**: 주민번호(개인정보·값 1건), 방문일(0%), 장비(전부 N), 회계잔액(현잔고·여신·발행율·최종매출일·최종수금일·마감일자·수금일자 — 회계가 원본이라 복사하면 낡음).
- **★DC_CD = 물류센터 ↔ 거래처 연결(이번에 밝혀짐)**: 발주현황표 출고장 7곳이 전부 **삼성웰스토리 지점 거래처**와 1:1 —
  `E100 용인=00273 / E200 왜관=00275 / E300 김해=00274 / E400 광주=00276 / E500 평택=00272 / E600 제주=00277 / E700 오산=00278`.
  즉 매출 엑셀의 출고장(파일명 '평택')↔`TBL_SALES_MST.DC_NM`↔`DC_CD='E500'`↔거래처 `00272` 로 이어진다.
- **TBL_PROD_SALEPRICE_HST 에 판매처 차원 추가됨(2026-07-18, DDL `sql/saleprice_vendor_alter.sql`)**: 삼성웰스토리 외 별도 판매처 판매가 요구로 `VENDOR_CD/VENDOR_NM` 추가.
  - **규칙: `VENDOR_CD IS NULL = 공통(기본)가`** — 기존 이력·매출 엑셀 확정가 전부 공통. 값 있으면 그 판매처 전용가.
  - **매출마감은 공통가만 집는다**(selectClosing 판매가 OUTER APPLY 에 `h.VENDOR_CD IS NULL` 가드) — 전용가가 물류센터 출고 마감에 안 섞임. `mergeSalepriceFromSales` ON 절에도 같은 가드.
  - **전용가는 마스터 SALE_PRICE 동기화 안 함**(UserServiceImpl.insertSaleprice 분기) — 기본가 오염 방지.
  - 화면: 상품관리 ▸ 판매가 탭에 판매처 콤보(매출 거래처 334종, 비우면 공통가). 이력 목록에 판매처 열(공통/판매처명).
- [완료] 매입처 자유입력 → 선택박스(prodmst.jsp `in_vendor`/`st_vendor`, `/vendor/selectVendorMst.do?gbFilter=매입` 121종). legacy 정리 불필요(기존 VENDOR_CD 전부 빈값 실측). **기존 버그 수정**: 재고입고 폼이 이름을 vendorCd 칸에 넣던 것 → 코드+이름 저장으로 통일.
- [완료] **매입/매출 거래처 화면** `mangr/vendorMng.jsp` (기준정보관리 ▸ 매입/매출 거래처, iframe `panel-vendor`) — CRUD·탭필터(매입/매출)·검색·엑셀출력 + **거래처리스트.xls 재업로드**(DOMParser 로 HTML 표 파싱→코드병합→`/vendor/uploadVendorMst.do` MERGE. 갱신·신규만, 삭제 안 함. 소프트삭제분은 재업로드 시 'Y' 복구). 삭제=ACTION_YN='N'. 기존 '거래처관리' 메뉴는 '거래처관리(사업장)'으로 개명.
- 주의: 사이드바 메뉴 이름이 비슷함 — **거래처관리(사업장)=TBL_BIZI_MST / 매입/매출 거래처=TBL_VENDOR_MST**

## 마감관리 (logistics_demo2.jsp 좌측 '마감관리 ★')
서브메뉴 4개 = **매출마감 / 매입마감 / 재고마감 / 마감현황(월계표)**. **월마감(YYYYMM)** 단위. 상단 매출/매입 업로드·출고데이타저장 버튼은 삭제됨.

### 공통 UX (매출·매입·재고 마감 3화면)
기간(마감월 선택→시작/종료일자 자동세팅, 직접조정 가능) + 그룹핑·소계·접기/펼치기(⊟전체토글) + **행 단위 페이징(25행/page, 페이지가 그룹 중간 시작 시 문맥 헤더 표시)** + 상단 **총합계**(teal, 흰글자).

### 매출마감 (출고 기준)
- 원천 `TBL_SHIPOUT_MST`(기간 귀속은 SHPOUT_DT) × **발주일자(DLV_DT) 시점 유효단가**(SALEPRICE_HST/INPRICE_HST `APPLY_DT ≤ DLV_DT` 최신, 없으면 TBL_PROD_MST 폴백, saleSrc/inSrc='이력'/'마스터' 표기)
- **★단가 기준일 = 발주일자(DLV_DT), 출고일자 아님** (2026-07-17 변경). 이유: **먼 지역은 발주분을 하루 당겨 출고**한다 — 실측으로 발주 20260708 → 출고 20260707 인 행이 15건. 출고일자로 맞추면 `적용일자(발주일) > 출고일자`가 되어 그 발주건의 확정단가가 영영 안 걸린다. 매출 엑셀 판매단가도 `APPLY_DT=납품일자(=발주일자)`로 적재하므로 기준을 통일. **기간 귀속은 종전대로 SHPOUT_DT**(WHERE 절 불변).
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
- ~~[확정 방침 2026-07-05] 출고→재고 미연동~~ → **이후 A안으로 구현됨(현재 코드 기준)**: 출고 저장 시 원장에 'O'행 자동연동 — `insertShipoutLedger`/`deleteShipoutLedger`(SHPOUT_DT별 삭제 후 재삽입, REF_GB='SHIPOUT', REF_NO=출고일자, ITEM_CD=PROD_CD 매칭, 품목·일자 합산이라 BIZ_CD는 NULL). 재고현황(`selectStockMstList`)·재고마감도 원장 단일소스 집계라 출고가 차감됨(입고 없이 출고만 있으면 음수 = 입고누락 신호). 매출/매입마감은 각각 SHIPOUT/입고 원천 그대로.
- [대기] 마감 출고 잠금(확정월 shipout 저장 차단), 매출/매입/재고 화면 '🔒 마감 확정' 버튼(현재 플레이스홀더) 연동, 마감 엑셀 출력, 일마감(안함 — 월마감만)

## 참고 이력 (이 프로젝트에서 겪은 것)
- Eclipse 빨간X = WTP 검증기 오탐(대용량 인라인 JS). 미사용 JSTL taglib 제거로 일부 해소.
- 사이드바 메뉴 대거 삭제(창고/입고등록/재고현황/재고위치/주문/발주리스트/출고지시/출고내역) — 데모 패널은 잔존(도달불가·display:none·무해).
