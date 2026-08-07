<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 메시지는 프로젝트 공통 컴포넌트를 쓴다 — 로그인 화면(base_login.jsp)과 같은 모양.
     SweetAlert 가 아니라 이 파일이 표준이다(_alertBox / _confirmBox / _toast). --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- 거래처 입력검색 — 거래처 칸에 직접 쳐서 고른다(2026-08-01). [거래처] 팝업은 그대로 둔다. --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js?v=20260805"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-quick.js"></script>
<!--
  판매등록 (2026-07-25 신설) — 매입등록 화면과 대칭. 같은 조작감으로 쓰도록 구조를 그대로 맞췄다.
    · 상단 = 전표 입력(헤더 + 명세 그리드) / 하단 좌 = 기간 전표 목록 / 하단 우 = 거래처 원장
    · 저장하면 TBL_SALES_TRX_MST/DTL + 파생 TBL_STOCK_LEDGER(출고 'O') 가 함께 쌓인다
    · ★ 정산서(TBL_SALES_MST)와 다른 표다. 그쪽은 출고장이 준 엑셀 적재표라 같은
      (납품일자+출고장)을 재업로드하면 기존 행이 죽는다. 여기는 정산서 밖에서 직접 판 건이다.
    · 원장·현잔고는 수금등록과 같은 쿼리(/mangr/custLedger.do)를 쓴다 — 두 화면 잔고가 어긋나면 안 된다.
    · DDL : sql/sales_trx_ddl.sql
-->
<style>
  :root{ --sa-bd:#dbe2ea; --sa-teal:#137a6c; --sa-bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  /* 글자 크기 한 단계 키움(2026-07-25 요청) — 기준 13 → 14px. 이 14px 이 전 화면 공통 기준이 됐다(2026-08-03) */
  .sa-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .sa-wrap h2{ margin:0 0 4px; font-size:20px; }
  .sa-sub{ color:#1f2a37; margin-bottom:12px; font-size:12.5px; font-weight:600; }
  .sa-card{ background:#fff; border:1px solid var(--sa-bd); border-radius:10px; padding:12px; margin-bottom:12px; }
  /* 검색·조건줄은 한 줄로 붙인다(2026-07-25 요청). 넘치면 이 줄만 가로 스크롤 */
  .sa-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:nowrap; overflow-x:auto; margin-bottom:8px; }
  .sa-fld{ display:flex; flex-direction:column; gap:3px; }
  .sa-fld label{ font-size:12px; font-weight:700; color:#1f2a37; white-space:nowrap; }
  .sa-fld input, .sa-fld select{ height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .sa-btn{ height:32px; border:1px solid var(--sa-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .sa-btn:hover{ border-color:var(--sa-teal); }
  .sa-btn.teal{ background:var(--sa-teal); color:#fff; border-color:var(--sa-teal); }
  .sa-btn.red{ color:#c0392b; border-color:#e3b4ae; }
  .sa-bal{ margin-left:auto; display:flex; gap:14px; align-items:center; font-size:12.5px; }
  .sa-bal b{ font-size:15px; color:#c0392b; }
  /* 명세 그리드 */
  /* 상단 명세 그리드 — 기본 높이 210px, ★아래 모서리를 끌어 늘리고 줄일 수 있다(2026-08-04 요청).
     resize 는 overflow 있는 요소에서만 동작한다. 합계줄은 별도 표라 그리드만 늘어난다. */
  .sa-grid{ height:210px; min-height:112px; max-height:70vh; resize:vertical;
            overflow:auto; scrollbar-gutter:stable; border:1px solid var(--sa-bd); border-radius:8px 8px 0 0; }
  /* 합계 — 그리드 바로 밑 고정. 가로 스크롤은 JS 가 그리드와 맞춘다 */
  .sa-foot{ overflow:hidden; scrollbar-gutter:stable; border:1px solid var(--sa-bd); border-top:0; border-radius:0 0 8px 8px; }
  /* ★그리드 표와 합계 표의 칸 맞춤(2026-08-04) :
       · 두 표 모두 table-layout:fixed + 같은 colgroup + 같은 min-width(colgroup 합 1740px).
       · 화면이 그보다 넓으면 width:100% 로 <우측 끝까지> 늘어난다 — 남는 폭은 두 표가
         같은 비율로 나눠 갖고, scrollbar-gutter 로 세로 스크롤바 자리도 똑같이 예약하므로
         어느 쪽도 밀리지 않는다(종전엔 그리드만 스크롤바만큼 좁아져 칸이 어긋났다). */
  .sa-foot table{ width:100%; min-width:1740px; table-layout:fixed; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-foot td{ border:1px solid var(--sa-bd); padding:6px 4px; text-align:center; background:#137a6c; color:#fff; font-weight:800; }
  .sa-foot td.num{ text-align:right; }
  .sa-grid table{ width:100%; min-width:1740px; table-layout:fixed; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-grid th{ background:#f4dcbc; color:#6f4200; font-weight:800; box-shadow:inset 0 -2px 0 #b06a00; border:1px solid var(--sa-bd); padding:7px 6px; position:sticky; top:0; z-index:2; }
  /* 컬럼 폭 조절 손잡이 — 머리글 오른쪽 경계를 끌면 그 칼럼이 늘고 줄어든다(2026-08-04 요청).
     합계줄 colgroup 도 같이 움직여 칸 맞춤이 유지된다(saColResize). */
  .sa-colrz{ position:absolute; top:0; right:-4px; width:8px; height:100%; cursor:col-resize; z-index:4; }
  .sa-colrz:hover{ background:rgba(19,122,108,.25); }
  .sa-grid td{ border:1px solid var(--sa-bd); padding:2px 4px; text-align:center;
               overflow:hidden; text-overflow:ellipsis; }   /* 고정 폭이라 긴 품명은 …로 줄인다(전체는 hover 안내) */
  .sa-grid td.num{ text-align:right; }
  .sa-grid td.txt{ text-align:left; }
  .sa-grid input{ width:100%; border:0; background:transparent; font-size:13.5px; padding:4px 2px; text-align:right; }
  .sa-grid input:focus{ outline:2px solid #bfe3dc; border-radius:3px; }
  .sa-grid input.txt{ text-align:left; }
  .sa-grid tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
  .sa-grid .lnk{ color:#137a6c; text-decoration:underline; cursor:pointer; }
  .sa-grid .del{ color:#c0392b; cursor:pointer; font-weight:700; }
  /* 행 조작(삽입·위·아래) — 주문 받은 순서 그대로 입력하기 위한 열(2026-07-31) */
  /* 거래처 부가세 설정 표시 — 계산이 왜 그렇게 나왔는지 화면에서 바로 보이게(2026-08-03) */
  /* 거래처 목록의 거래유형 — 이 화면(매출)에는 그 유형 + '매입&매출' + 유형 미지정이 함께 보인다.
     섞여 있어도 한눈에 갈리게 색을 준다(2026-08-03 요청) */
  .vp-gb{ display:inline-block; white-space:nowrap; padding:1px 7px; border-radius:10px; font-size:11.5px; font-weight:800;
          background:#e9f4f1; color:#137a6c; border:1px solid #b9ded4; }
  .vp-gb.both{ background:#eef0ff; color:#3f43a8; border-color:#c9cdf3; }
  .vp-gb.none{ background:#f2f4f6; color:#8a97a4; border-color:#dde3e9; }
  .vat-tag{ display:inline-block; white-space:nowrap; margin-left:6px; padding:2px 8px; border-radius:10px; font-size:12.5px;
            font-weight:800; background:#eef3f2; color:#37475a; border:1px solid #cfd8e3; vertical-align:middle; }
  .vat-tag.inc { background:#eaf3ff; color:#1a56a8; border-color:#b9d3f2; }
  .vat-tag.free{ background:#fff1e8; color:#b45309; border-color:#f0c9a4; }
  .sa-grid td.no{ text-align:center; color:#8a97a4; font-weight:700; background:#fbfcfd; }
  /* 반품 줄 — 글자를 전부 빨강으로. 안쪽 input·select 까지 물려야 줄 전체가 빨갛게 보인다.
     배경까지 칠하면 입력칸이 묻혀 읽기 어려워, 아주 옅은 분홍만 깐다. */
  .sa-grid tr.ret td{ color:#c0392b; background:#fff5f4; }
  .sa-grid tr.ret td.no{ background:#ffe9e6; color:#c0392b; }
  .sa-grid tr.ret input, .sa-grid tr.ret select, .sa-grid tr.ret .lnk{ color:#c0392b; font-weight:700; }
  .sa-grid td.ops{ white-space:nowrap; padding:2px 1px; }
  .sa-grid td.ops span{ display:inline-block; width:20px; height:20px; line-height:19px; margin:0 1px;
                        border:1px solid var(--sa-bd); border-radius:4px; cursor:pointer; font-size:11px; color:#37475a; background:#fff; }
  .sa-grid td.ops span:hover{ border-color:var(--sa-teal); color:var(--sa-teal); }
  .sa-grid .hist{ cursor:pointer; font-size:13px; }
  .sa-grid .hist:hover{ filter:brightness(1.3); }
  /* 하단 목록 */
  /* 하단 목록 — 5행 고정 + 자동 스크롤(매출내역과 같은 방식) */
  .sa-list{ max-height:196px; overflow:auto; border:1px solid var(--sa-bd); border-radius:8px; }
  .sa-list table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-list th{ background:#f4dcbc; color:#6f4200; font-weight:800; box-shadow:inset 0 -2px 0 #b06a00; border:1px solid var(--sa-bd); padding:7px 8px; position:sticky; top:0; z-index:2; }
  .sa-list td{ border:1px solid var(--sa-bd); padding:6px 8px; text-align:center; }
  .sa-list td.num{ text-align:right; }
  .sa-list tr{ cursor:pointer; }
  .sa-list tr:hover td{ background:#f3f8f6; }
  .sa-list tr.on td{ background:#fdeef0; font-weight:700; }
  .sa-sum{ display:flex; gap:0; border:1px solid var(--sa-bd); border-top:0; border-radius:0 0 8px 8px; overflow:hidden; }
  .sa-sum div{ flex:1; padding:8px 10px; font-size:13.5px; }
  .sa-sum div.k{ background:#eef3f2; font-weight:700; flex:0 0 90px; text-align:center; }
  .sa-sum div.v{ text-align:right; font-weight:700; }
  /* 팝업 */
  .sa-pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:200; }
  .sa-pop.on{ display:block; }
  .sa-pop .box{ background:#fff; width:min(940px,96vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.3); }
  .sa-pop .hd{ padding:12px 16px; border-bottom:1px solid var(--sa-bd); font-weight:800; display:flex; align-items:center; gap:8px; }
  /* ★padding-top 을 0 으로 (2026-08-03) — sticky 머리글은 이 영역의 '패딩 안쪽' 맨 위에 서기 때문에
     위쪽 여백 12px 구간으로 지나가는 줄이 머리글 위에 비쳐 보였다.
     표가 제목줄(.hd) 밑선에 딱 붙게 되는데, .hd 에 아래 테두리가 있어 그대로 깔끔하다. */
  .sa-pop .bd{ padding:0 16px 12px; overflow:auto; }
  .sa-pop .ft{ padding:10px 16px; border-top:1px solid var(--sa-bd); text-align:right; }
  .sa-pop table{ width:100%; border-collapse:collapse; font-size:12.5px; }
  /* ★머리글 고정 (2026-08-03 요청) — 목록을 내리면 어느 칸이 무엇인지 알 수 없었다.
     border-collapse 표에서는 sticky th 의 테두리가 같이 안 따라와 줄이 사라지므로
     box-shadow 로 아래·위 선을 그려 준다. */
  .sa-pop thead th{ background:#eef3f2; border:1px solid var(--sa-bd); padding:6px 8px;
                 position:sticky; top:0; z-index:5;
                 box-shadow:inset 0 1px 0 var(--sa-bd), inset 0 -1px 0 var(--sa-bd); }
  .sa-pop tbody td{ position:relative; z-index:1; }   /* 줄이 머리글을 덮지 않게 */
  .sa-pop td{ border:1px solid var(--sa-bd); padding:6px 8px; text-align:center; }
  .sa-pop td .vat-tag{ margin-left:0; }
  .sa-pop td.num{ text-align:right; }
  .sa-pop tr.pick{ cursor:pointer; }
  .sa-pop tr.pick:hover td{ background:#f3f8f6; }
  /* 매칭코드 줄 — 원코드 줄과 '같은 칸'에 맞춰 그리되(코드는 코드 칸, 품명은 품명 칸),
     그 상품에 딸린 줄임을 알 수 있게 파란 계열 + 왼쪽 띠만 다르게 둔다 */
  .sa-pop tr.sa-exrow td{ color:#274b8f; background:#f7faff; }
  .sa-pop tr.sa-exrow td:first-child{ box-shadow:inset 3px 0 0 #c9d9f5; }
  .sa-pop tr.sa-exrow:hover td{ background:#eef4ff; }
  .sa-msg{ padding:10px; color:#5a6b7a; text-align:center; font-size:12.5px; }
  /* 원장 합계 — 스크롤 영역 밖에 고정 */
  .sa-lgfoot{ overflow:hidden; border:1px solid var(--sa-bd); border-top:0; border-radius:0 0 8px 8px; }
  .sa-lgfoot table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-lgfoot td{ border:1px solid var(--sa-bd); padding:7px 8px; text-align:right; background:#d9f0e0; font-weight:800; }
  .sa-lgfoot td:first-child{ text-align:center; }
</style>

<div class="sa-wrap">
  <%-- 제목줄 = 제목 + (우측) 정산 엑셀 올리기. 정산 엑셀 버튼은 매출내역 화면에서 이 자리로 옮겨왔다(2026-08-01 요청)
       — 매출을 넣는 화면에서 정산서도 같이 올리도록. 실제 파일 선택·확인·저장은 부모(물류관리 셸)의 기존 흐름 그대로다. --%>
  <div style="display:flex; align-items:flex-start; gap:12px">
    <div style="flex:1 1 auto; min-width:0">
      <h2>🧾 판매등록</h2>
      <div class="sa-sub">정산서 밖에서 <b>직접 판 건</b>을 입력합니다. 저장 시 <b>재고가 출고</b>로 빠지고 거래처 원장의 매출·미수에 잡힙니다.</div>
    </div>
    <%-- 설명은 버튼 '앞(왼쪽)' — 버튼 아래에 두면 아래 입력카드와 붙어 읽기 나빴다(2026-08-01 요청) --%>
    <div style="flex:0 0 auto; display:flex; align-items:center; gap:10px">
      <span style="font-size:11.5px; color:#5a6b7a; line-height:1.5; text-align:right">
        출고장이 보내준 <b>정산서(받을 금액)</b> 엑셀을 가져옵니다.<br>
        가져온 내용은 <b>매출내역</b> 화면에서 출고와 대사됩니다.
      </span>
      <button class="sa-btn teal" onclick="saSlsExcel()"
              title="출고장이 준 정산 엑셀을 고릅니다(여러 개 가능).&#10;고르면 확인·저장 창이 열립니다.&#10;출고장은 파일명에서 인식합니다 — 2026.07.11_평택.xlsx → 평택">📥 정산서 가져오기</button>
    </div>
  </div>

  <!-- ========== 전표 입력 ========== -->
  <div class="sa-card">
    <div class="sa-row">
      <div class="sa-fld" style="flex:0 0 140px"><label>판매일자</label><input type="date" id="saDt" onchange="saNextNo()"></div>
      <div class="sa-fld" style="flex:0 0 90px"><label>전표번호</label><input type="text" id="saNo" readonly style="background:#f5f7f9"></div>
      <%-- 거래처 = 직접 입력검색(거래처명·코드·별칭·대표·담당 부분일치). 목록을 훑어보려면 [거래처] 버튼. --%>
      <div class="sa-fld" style="flex:0 0 220px"><label>거래처</label><input type="text" id="saVenNm" placeholder="거래처명 입력 또는 [거래처]" title="거래처명·코드·별칭·대표자·담당자로 검색합니다. ↑↓ 로 고르고 Enter."><span id="saVatTag" class="vat-tag" style="display:none"></span></div>
      <button class="sa-btn teal" onclick="saVenOpen()">거래처</button>
      <button class="sa-btn" onclick="saVenNew()" title="없는 거래처를 이 자리에서 바로 등록합니다">＋신규</button>
      <%-- 납품분 = 그 거래처에 이미 나간 품목(판매전표+정산서)을 중복 없이 모아 보여준다.
           체크한 순서 그대로 명세에 담긴다 — 주문 받은 순서대로 입력하기 위한 장치(2026-07-31). --%>
      <button class="sa-btn teal" onclick="saDlvOpen()" title="이 거래처가 받아 온 품목 목록에서 골라 담기">납품분</button>
      <div class="sa-fld" style="flex:0 0 120px"><label>담당자</label><input type="text" id="saMgrNm" readonly style="background:#f5f7f9"></div>
      <div class="sa-fld" style="flex:0 0 130px"><label>창고</label><input type="text" id="saWhNm" value="물류창고"></div>
      <%-- 일괄등록 (2026-08-06 — 매입등록과 동일) — 거래처는 그대로 두고 일자만 바꿔 여러 상품을 일자별 전표로 저장 --%>
      <button class="sa-btn teal" onclick="saBatchOpen()" title="거래처가 선택된 상태에서 일자만 바꿔 여러 상품을 일자별 전표로 저장합니다">일괄등록</button>
      <%-- 납품일자 = 원장에 잡히는 날. 비우면 판매일자를 그대로 쓴다.
           정산서(TBL_SALES_MST)가 DLV_DT 로 귀속되는 것과 같은 규칙이라 두 매출이 같은 기준에 선다. --%>
      <div class="sa-fld" style="flex:0 0 140px"><label>납품일자(비우면 판매일)</label><input type="date" id="saDlvDt"></div>
      <div class="sa-bal">
        <span>현잔고(미수) <b id="saBalNow">0</b></span>
        <span>거래후잔고 <b id="saBalAfter">0</b></span>
      </div>
    </div>

    <%-- 합계는 스크롤 영역 밖(그리드 바로 밑)에 둔다 — 안에 두면 행이 적을 때 빈 공간 위에 떠서
         그리드 중간에 걸린 것처럼 보인다(2026-07-25 요청). 두 표의 열 너비는 같은 colgroup 으로 맞추고
         가로 스크롤은 JS 로 동기화한다. --%>
    <div class="sa-grid" id="saGridWrap">
      <table>
        <colgroup><col style="width:38px"><col style="width:82px"><col style="width:110px"><col style="width:320px"><col style="width:140px"><col style="width:70px"><col style="width:70px"><col style="width:80px"><col style="width:85px"><col style="width:95px"><col style="width:70px"><col style="width:95px"><col style="width:85px"><col style="width:100px"><col style="width:60px"><col style="width:110px"><col style="width:50px"><col style="width:80px"></colgroup>
        <thead><tr>
          <th>No</th><th>행(＋삽입/▲▼)</th><th>상품코드</th><th>품명(단가이력조회)</th>
          <th>[입수량]규격</th><th>BOX수량</th><th>EA수량</th>
          <th>합계수량</th><th>단가</th><th>금액</th>
          <th>DC</th><th>공급가</th><th>부가세</th>
          <th>판매금액</th><th>서비스</th><th>비고</th>
          <th>행사</th><th>거래구분</th>
        </tr></thead>
        <tbody id="saBody"></tbody>
      </table>
    </div>
    <div id="saGridPager" style="padding:5px 2px 0; text-align:center; min-height:22px"></div>
    <div class="sa-foot" id="saFootWrap">
      <table>
        <colgroup><col style="width:38px"><col style="width:82px"><col style="width:110px"><col style="width:320px"><col style="width:140px"><col style="width:70px"><col style="width:70px"><col style="width:80px"><col style="width:85px"><col style="width:95px"><col style="width:70px"><col style="width:95px"><col style="width:85px"><col style="width:100px"><col style="width:60px"><col style="width:110px"><col style="width:50px"><col style="width:80px"></colgroup>
        <tbody><tr class="tot">
          <td colspan="5">■ 합계</td>
          <td class="num" id="tBox">0</td><td class="num" id="tEa">0</td><td class="num" id="tQty">0</td>
          <td></td><td class="num" id="tAmt">0</td><td class="num" id="tDc">0</td>
          <td class="num" id="tSup">0</td><td class="num" id="tVat">0</td><td class="num" id="tTot">0</td>
          <td class="num" id="tSvc">0</td><td colspan="3"></td>
        </tr></tbody>
      </table>
    </div>

    <div class="sa-row" style="margin-top:10px">
      <div class="sa-fld" style="flex:1 1 320px"><label>판매메모</label><input type="text" id="saRemark" style="width:100%"></div>
      <div class="sa-fld" style="flex:0 0 110px"><label>수금구분</label>
        <select id="saPayGb"><option>현금</option><option>카드</option><option selected>외상</option><option>계좌이체</option></select>
      </div>
      <div class="sa-fld" style="flex:0 0 120px"><label>수금액</label><input type="text" id="saPayAmt" value="0" style="text-align:right" oninput="saCalc()"></div>
      <button class="sa-btn" onclick="saPayFill()">판매액</button>
      <div class="sa-fld" style="flex:0 0 120px"><label>할인액</label><input type="text" id="saDcAmt" value="0" style="text-align:right" oninput="saCalc()"></div>
      <button class="sa-btn" onclick="saDcFill()">털기</button>
    </div>

    <div class="sa-row" style="margin-top:4px">
      <button class="sa-btn teal" onclick="saNew()">＋ 신규등록</button>
      <button class="sa-btn" onclick="saSave()">💾 저장</button>
      <button class="sa-btn" onclick="saReload()">🔄 새로고침</button>
      <button class="sa-btn red" onclick="saDelete()">✖ 삭제하기</button>
      <span id="saState" style="margin-left:8px; color:#3d4d5c; font-size:12.5px"></span>
      <span style="margin-left:auto; color:#8a97a4; font-size:11.5px"
            title="상품칸에 바로 입력해 ↑↓·Enter 로 고르고, Enter 로 다음 칸/다음 줄, ↑↓ 로 줄을 오갑니다">⌨ 상품칸 입력검색 · Enter 다음칸 · ↑↓ 줄이동 · Ctrl+S 저장 · Alt+N 신규</span>
    </div>
  </div>

  <!-- ========== 하단 : 좌 전표목록 / 우 거래처 원장 ========== -->
  <div style="display:flex; gap:12px; align-items:flex-start">
  <div class="sa-card" style="flex:1 1 auto; min-width:0">
    <div class="sa-row">
      <span style="font-weight:700">Total : <span id="saTotal">0</span></span>
      <div class="sa-fld" style="flex:0 0 140px"><label>검색기간</label><input type="date" id="saFrom"></div>
      <div class="sa-fld" style="flex:0 0 140px"><label>&nbsp;</label><input type="date" id="saTo"></div>
      <div class="sa-fld" style="flex:0 0 200px"><label>거래처</label><input type="text" id="saFindNm" placeholder="거래처명"></div>
      <button class="sa-btn teal" onclick="saLoad()">리스트조회</button>
    </div>
    <div class="sa-list" id="saListWrap">
      <table>
        <thead><tr>
          <th style="width:70px">복사저장</th><th style="width:110px">판매일시</th><th style="width:64px">번호</th>
          <%-- 거래처명은 폭을 지정해 줄인다(2026-08-04) — 자동 폭이면 남는 자리를 혼자 다 먹었다 --%>
          <th style="width:220px">거래처명</th><th style="width:84px">담당사원</th><th style="width:64px">상품수</th>
          <th style="width:110px">금액</th><th style="width:84px">창고</th><th style="width:84px">등록자</th>
        </tr></thead>
        <tbody id="saListBody"><tr><td colspan="9" class="sa-msg">[리스트조회]를 누르세요.</td></tr></tbody>
      </table>
    </div>
    <div id="saPager" style="padding:6px 2px; text-align:center; min-height:26px"></div>
    <div class="sa-sum">
      <div class="k">판매계</div><div class="v" id="sPurch">0</div>
      <div class="k">반품계</div><div class="v" id="sRet">0</div>
      <div class="k">수금계</div><div class="v" id="sPay">0</div>
      <div class="k">할인계</div><div class="v" id="sDc">0</div>
      <div class="k">미수금</div><div class="v" id="sUnpaid">0</div>
    </div>
  </div>

  <!-- 거래처 원장(분개장) — 거래처를 고르면 그 거래처의 일자별 매출·수금·잔고.
       수금등록과 같은 쿼리(/mangr/custLedger.do)라 두 화면의 잔고가 항상 같다.
       460→560→680px (2026-08-04 "원장 좌측으로 확대") — 왼쪽 목록은 그만큼 자동으로 줄어든다. -->
  <div class="sa-card" style="flex:0 0 680px">
    <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
      <b>원장</b>
      <span style="margin-left:auto; font-size:11.5px; color:#5a6b7a">* 일자를 클릭하면 그 날 매출품목이 보입니다.</span>
    </div>
    <div style="border:1px solid var(--sa-bd); border-radius:6px; padding:6px 8px; margin-bottom:6px; font-size:12.5px">
      <b>거래처명</b> <span id="lgVen" style="margin-left:8px">—</span>
    </div>
    <%-- 원장 스크롤 : 머리글 고정 + 합계는 스크롤 영역 밖(항상 보임). 지급등록 화면과 같은 규격 --%>
    <div class="sa-list" id="lgWrap" style="max-height:300px; border-radius:8px 8px 0 0">
      <table>
        <%-- 균형 배분(2026-08-04) — 매출만 넓고 나머지가 좁아 한쪽으로 쏠려 보였다.
             금액 4칸(매출·수금·잔고 + DC·할인)을 고르게 나눈다. --%>
        <colgroup><col style="width:96px"><col><col style="width:88px"><col style="width:112px"><col style="width:88px"><col style="width:122px"></colgroup>
        <thead><tr><th>일자</th><th>매출</th><th>DC</th><th>수금</th><th>할인</th><th>잔고</th></tr></thead>
        <tbody id="lgBody"><tr><td colspan="6" class="sa-msg">거래처를 선택하세요.</td></tr></tbody>
      </table>
    </div>
    <div class="sa-lgfoot">
      <table>
        <%-- 균형 배분(2026-08-04) — 매출만 넓고 나머지가 좁아 한쪽으로 쏠려 보였다.
             금액 4칸(매출·수금·잔고 + DC·할인)을 고르게 나눈다. --%>
        <colgroup><col style="width:96px"><col><col style="width:88px"><col style="width:112px"><col style="width:88px"><col style="width:122px"></colgroup>
        <tbody id="lgFoot"></tbody>
      </table>
    </div>
  </div>
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="sa-pop" id="saVenPop">
  <div class="box" style="width:min(1140px,96vw)"><%-- 총판매·총매입 칼럼이 늘어 기본(940)보다 넓게 --%>
    <div class="hd">거래처 선택
      <input type="text" id="saVenQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px" oninput="saVenRender()">
    </div>
    <%-- 총판매·총매입 표시(2026-08-04) — 정렬(총판매 순)의 근거가 화면에 보이게 --%>
    <div class="bd"><table><thead><tr><th style="width:78px">코드</th><th>거래처명</th><th style="width:96px">거래유형</th><th style="width:74px">부가세</th><th style="width:108px" title="정산서 매출 + 판매전표를 모두 더한 금액입니다. 숫자에 마우스를 올리면 내역이 보입니다.">총판매</th><th style="width:108px">총매입</th><th style="width:110px">별칭</th><th style="width:92px">대표자</th><th style="width:88px">담당사원</th></tr></thead>
      <tbody id="saVenBody"></tbody></table></div>
    <div class="ft" style="justify-content:space-between"><span style="display:flex;gap:6px"><button class="sa-btn" id="saVenAllBtn" onclick="saVenAll(!_venAll)" title="끄면 매출 거래처(+유형 미지정)만 보입니다">전체</button><button class="sa-btn teal" onclick="saVenNew()">＋ 신규 거래처</button></span><button class="sa-btn" onclick="saVenClose()">닫기</button></div>
  </div>
</div>

<!-- 상품 선택 팝업 -->
<div class="sa-pop" id="saProdPop">
  <div class="box">
    <div class="hd">상품 선택
      <input type="text" id="saProdQ" placeholder="상품코드·상품명 — 거래처가 준 품목코드로도 찾습니다" style="flex:1; height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px" oninput="saProdRender()">
    </div>
    <%-- 거래처 통보품목으로 찾기 (2026-08-01 통화 확정)
         거래처가 준 코드로 입력할 때, 원 상품코드를 골라 둔 통보분이면 그대로 우리 상품이 잡히고,
         안 골라 둔 것(미연결)은 그 자리에서 알려 준다 — 몰래 다른 상품으로 넣지 않는다. --%>
    <div class="bd" id="saExtWrap" style="display:none; padding-bottom:0">
      <div style="font-size:12px; font-weight:800; color:#37475a; margin-bottom:4px">🔖 거래처 매칭코드</div>
      <table><thead><tr><th style="width:110px">거래처 코드</th><th>거래처가 부르는 품목명</th><th style="width:110px">규격</th><th style="width:150px">우리 상품코드</th></tr></thead>
        <tbody id="saExtBody"></tbody></table>
    </div>
    <%-- ✔칸으로 여러 상품을 체크해 한꺼번에 담을 수 있다(2026-08-06 요청, 매입등록·납품분 팝업과 같은 방식).
         줄 클릭 = 종전 그대로 한 건 즉시 담기. 🔖 매칭코드 줄은 종전대로 클릭으로만 담는다. --%>
    <div class="bd"><table><thead><tr><th style="width:44px" title="체크한 순서대로 한꺼번에 담습니다">✔</th><th style="width:110px">상품코드</th><th>상품명</th><th style="width:110px">규격</th><th style="width:60px">입수</th><th style="width:90px">판매가</th></tr></thead>
      <tbody id="saProdBody"></tbody></table></div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span id="saPickInfo" style="font-size:12.5px; color:#137a6c; font-weight:700"></span>
      <span style="margin-left:auto"></span>
      <button class="sa-btn teal" onclick="saProdMultiApply()" title="체크한 상품을 순서대로 명세에 담습니다. BOX수량은 1로 채워집니다">확인 — 선택 담기</button>
      <button class="sa-btn" onclick="saProdClose()">닫기</button>
    </div>
  </div>
</div>

<!-- 일괄등록 팝업 (2026-08-06 — 매입등록과 동일) —————————————————————
     좌 = 담을 내용(전표 미리보기, BOX·EA·단가 수정 가능) / 우 = [상품코드]·[최근 판매내역] 두 탭.
     체크하는 순간의 '판매일자'가 그 줄의 등록일자 — 일자를 바꿔 체크하면 일자별 전표로 나뉘고
     [일괄저장]이 일자마다 전표 한 장씩 바로 저장한다(팝업 유지, 명세 그리드는 건드리지 않음). -->
<div class="sa-pop" id="saBatchPop">
  <div class="box" style="width:min(1600px,97vw)">
<%-- 머리줄 글자·버튼 높이 30px 통일 — 한 선상 정렬(2026-08-06 요청, 매입등록과 동일) --%>
    <div class="hd" style="align-items:center">일괄등록 — <span id="btVen" style="color:#137a6c">—</span>
      <span class="sa-btn" style="pointer-events:none; background:#f1f5f4; height:30px; line-height:28px; padding:0 10px">판매일자</span>
      <input type="date" id="btDt" style="height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13px" onchange="saBatchDtHint();saBatchRender()">
      <span id="btDtHint" style="font-size:12px; font-weight:700; color:#c0392b; line-height:30px"></span>
      <%-- 담을 내용 비우기 — [전체 초기화]만 여기에. 일자별 삭제는 왼쪽 일자 머리줄의 ✖ 로 --%>
      <button class="sa-btn red" style="height:30px; line-height:1; padding:0 10px" onclick="saBatchDelAll()" title="담을 내용을 모두 비웁니다">전체 초기화</button>
      <%-- [일괄저장]은 상단 우측(✕ 옆) 배치 (2026-08-06 확정 — 판매·매입 동일). 누르면 확인창이 먼저 뜬다 --%>
      <span style="margin-left:auto; display:flex; align-items:center; gap:8px">
        <%-- 버튼 너비(112px)만큼 왼쪽으로 — ✕ 와 붙어 잘못 누르는 것 방지(2026-08-06 요청) --%>
        <button class="sa-btn teal" style="min-width:112px; height:30px; line-height:1; margin-right:112px" onclick="saBatchApply()" title="담을 내용을 일자별 전표로 한 장씩 바로 저장합니다 (확인창이 먼저 뜹니다)">💾 일괄저장</button>
        <span class="sa-btn" style="border:0;background:transparent;font-size:18px" onclick="saBatchClose()">✕</span>
      </span>
    </div>
    <div class="bd">
      <div style="display:flex; gap:12px; align-items:flex-start; margin-top:10px">
        <div style="flex:1 1 58%; min-width:0">
          <div style="font-size:12.5px; font-weight:800; color:#37475a; margin:0 0 4px">⤒ 담을 내용
            <span style="font-weight:600; color:#8a97a4">— 오른쪽 목록에서 체크한 상품이 순서대로 쌓입니다. 확인 후 [일괄저장]</span></div>
          <div style="height:60vh; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
            <table>
              <%-- 순서(▲▼)는 코드 앞 (2026-08-06 요청 — 명세 그리드의 행 조작 열과 같은 자리) --%>
              <thead><tr><th style="width:36px">#</th><th style="width:52px" title="▲▼ 순서 조정(같은 일자 안)">순서</th><th style="width:106px">상품코드</th><th>상품명</th>
                <th style="width:104px">[입수량]규격</th><th style="width:58px">BOX</th><th style="width:58px">EA</th><th style="width:64px">합계</th><th style="width:82px">단가</th><th style="width:92px">금액</th><th style="width:34px"></th></tr></thead>
              <tbody id="btSelBody"><tr><td colspan="11" class="sa-msg">오른쪽 목록에서 체크하면 여기에 순서대로 담깁니다.</td></tr></tbody>
            </table>
          </div>
        </div>
        <div style="flex:1 1 42%; min-width:0">
          <div style="display:flex; gap:6px; margin:0 0 6px">
            <button class="sa-btn" id="btTab1" onclick="saBatchTab(1)">상품코드</button>
            <button class="sa-btn" id="btTab2" onclick="saBatchTab(2)">최근 판매내역</button>
            <input type="text" id="btQ" placeholder="상품코드·상품명" style="flex:1; height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="saBatchRender()">
          </div>
          <div style="height:56vh; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
            <table>
              <thead id="btHead"></thead>
              <tbody id="btBody"></tbody>
            </table>
          </div>
          <div style="margin-top:6px; font-size:12px; color:#3d4d5c">
            체크하면 위 <b>판매일자</b>로 담깁니다 — <b>일자를 바꿔 체크하면 일자별 전표로 나뉘고</b>, [일괄저장]이 전표를 일자마다 한 장씩 저장합니다.
            상품코드 탭은 BOX수량 1(=EA 1), 최근 판매내역 탭은 그때의 수량·단가 그대로. 담긴 줄은 왼쪽에서 고치거나 ✖ 로 뺍니다.
          </div>
        </div>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="font-size:12.5px; color:#137a6c; font-weight:700" id="btCnt"></span>
      <span style="margin-left:auto"></span>
      <button class="sa-btn" style="min-width:112px" onclick="saBatchClose()">닫기</button>
    </div>
  </div>
</div>

<!-- 납품분 검색 팝업 (2026-07-31) —————————————————————————————
     그 거래처에 이미 나간 품목을 중복 없이 모아 보여준다(판매전표 + 정산서).
       · 체크한 '순서'가 곧 명세 줄 순서다. 체크 칸에 1,2,3… 이 찍혀 순서를 눈으로 확인한다.
       · [납품분제외] = 앞으로 이 목록에 안 나오게 한다(거래처별). 판매 이력은 그대로 둔다.
       · [제외이력보기] 에서 되돌릴 수 있다. -->
<div class="sa-pop" id="saDlvPop">
  <div class="box" style="width:min(980px,96vw)">
    <div class="hd">납품분 검색
      <select id="dvPeriod" style="height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 6px; font-size:12.5px" onchange="saDlvLoad()">
        <option value="1">최근 1년</option><option value="3">최근 3년</option><option value="">전체</option>
      </select>
      <select id="dvSrc" style="height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 6px; font-size:12.5px" onchange="saDlvLoad()">
        <option value="">전체(전표+정산서)</option><option value="TRX">판매전표만</option><option value="MST">정산서만</option>
      </select>
      <button class="sa-btn" id="dvExclBtn" onclick="saDlvToggleExcl()">📋 제외이력보기</button>
      <span style="margin-left:auto"><span class="sa-btn" style="border:0;background:transparent;font-size:18px" onclick="saDlvClose()">✕</span></span>
    </div>
    <div class="bd">
      <div style="display:flex; gap:6px; margin-bottom:8px">
        <input type="text" id="dvQ" placeholder="상품코드·상품명·규격·제조사" style="flex:1; height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="saDlvRender()">
        <button class="sa-btn" onclick="saDlvRender()">🔍</button>
      </div>
      <div style="max-height:420px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table>
          <thead><tr>
            <th style="width:46px"><input type="checkbox" id="dvAll" onchange="saDlvAll(this.checked)"></th>
            <th style="width:110px">상품코드</th><th>상품명</th><th style="width:110px">규격</th>
            <th style="width:110px">제조사</th><th style="width:90px">단가</th><th style="width:90px">현재고</th>
            <th style="width:96px">최근거래</th><th style="width:66px">원천</th>
          </tr></thead>
          <tbody id="dvBody"><tr><td colspan="9" class="sa-msg">거래처를 먼저 선택하세요.</td></tr></tbody>
        </table>
      </div>
      <div style="margin-top:8px; font-size:12.5px; color:#3d4d5c">
        체크한 <b>순서대로</b> 명세에 담깁니다. <span id="dvPickInfo" style="color:#137a6c; font-weight:700"></span>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="font-size:12.5px; color:#5a6b7a" id="dvCnt">0건</span>
      <span style="margin-left:auto"></span>
      <button class="sa-btn red" id="dvExclSave" onclick="saDlvExclSave()">🚫 납품분제외</button>
      <button class="sa-btn teal" id="dvOk" onclick="saDlvApply()">확인 — 순서대로 담기</button>
    </div>
  </div>
</div>

<!-- 원장 일자 클릭 → 그 날 매출품목 (2026-07-31) —————————————
     정산서 매출과 판매전표를 함께 보여준다(원장 금액과 같은 원천 selectCustDayDetail).
     [불러오기] 는 '새 전표'로 올린다 — 그 날 전표를 고치는 게 아니다.
     이미 저장된 판매전표를 다시 담아 저장하면 매출이 두 번 잡히므로 확인을 받는다. -->
<div class="sa-pop" id="saDayPop">
  <div class="box" style="width:min(900px,96vw)">
    <div class="hd">원장 — <span id="dyTitle">일자별 매출품목</span>
      <span style="margin-left:auto"><span class="sa-btn" style="border:0;background:transparent;font-size:18px" onclick="saDayClose()">✕</span></span>
    </div>
    <div class="bd">
      <div style="max-height:380px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table>
          <thead><tr>
            <th style="width:90px">구분</th><th style="width:130px">전표·발주</th><th style="width:110px">품목코드</th>
            <th>품목명</th><th style="width:80px">수량</th><th style="width:90px">단가</th><th style="width:100px">금액</th>
          </tr></thead>
          <tbody id="dyBody"><tr><td colspan="7" class="sa-msg">불러오는 중…</td></tr></tbody>
        </table>
      </div>
      <div style="margin-top:8px; font-size:12.5px; color:#3d4d5c">
        <b>합계</b> <span id="dySum" style="color:#c0392b; font-weight:700">0</span>
        <span style="margin-left:12px">* [불러오기] 는 이 품목들을 <b>새 전표</b>로 올립니다. 그대로 저장하면 매출이 한 번 더 잡힙니다.</span>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="margin-left:auto"></span>
      <button class="sa-btn teal" onclick="saDayApply()">⤓ 불러오기</button>
      <button class="sa-btn" onclick="saDayClose()">닫기</button>
    </div>
  </div>
</div>

<!-- 복사저장 설정 팝업 — 지난 전표의 명세를 '다른 일자·다른 거래처'로 복제할 때 쓴다 -->
<div class="sa-pop" id="saCopyPop">
  <div class="box" style="width:min(620px,94vw)">
    <div class="hd">복사저장 설정 <span style="margin-left:auto"><span class="sa-btn" style="border:0;background:transparent;font-size:18px" onclick="saCopyClose()">✕</span></span></div>
    <div class="bd">
      <div style="display:flex; align-items:center; gap:10px; margin-bottom:12px">
        <span class="sa-btn" style="pointer-events:none; background:#f1f5f4">판매일자선택</span>
        <input type="date" id="cpDt" style="height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px">
      </div>
      <div style="font-weight:700; margin-bottom:6px">거래처선택</div>
      <div style="display:flex; gap:6px; margin-bottom:8px">
        <input type="text" id="cpQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="saCopyRender()">
        <button class="sa-btn" onclick="saCopyRender()">🔍</button>
      </div>
      <div style="max-height:280px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table><thead><tr><th style="width:90px">거래처코드</th><th>거래처명</th><th style="width:120px">별칭</th><th style="width:100px">대표자</th><th style="width:90px">담당사원</th></tr></thead>
          <tbody id="cpBody"></tbody></table>
      </div>
      <div style="margin-top:8px; color:#3d4d5c; font-size:12.5px">거래처를 클릭하면 그 거래처·일자로 <b>새 전표</b>가 만들어집니다. 내용을 확인한 뒤 [저장]을 누르세요.</div>
    </div>
    <div class="ft"><button class="sa-btn" onclick="saCopyClose()">닫기</button></div>
  </div>
</div>

<!-- 판매단가 이력 팝업 -->
<div class="sa-pop" id="saHistPop">
  <div class="box">
    <div class="hd">거래처 상품 판매 단가 이력</div>
    <div class="bd">
      <%-- 상단 정보는 상품마스터에서 그대로 보여준다(서버 왕복 없음) --%>
      <table style="margin-bottom:10px">
        <tr><th style="width:110px">거래처</th><td class="txt" style="text-align:left" colspan="3" id="hvVen">—</td></tr>
        <tr><th>상품명</th><td class="txt" style="text-align:left" colspan="3" id="hvNm">—</td></tr>
        <tr><th>바코드</th><td id="hvBc">—</td><th style="width:110px">박스 바코드</th><td id="hvBox">—</td></tr>
        <tr><th>매입 단가</th><td class="num" id="hvIn">0</td><th>판매 단가</th><td class="num" id="hvSale">0</td></tr>
        <tr><th>도매 단가</th><td class="num" id="hvWhole">0</td><th></th><td></td></tr>
      </table>
      <div style="display:flex; align-items:center; margin:8px 0 6px; font-size:12.5px">
        <span id="hvCnt" style="font-weight:700">[ 조회 건 수: 0/0 ]</span>
        <span style="margin-left:auto; color:#3d4d5c">최대 3년 전 단가 이력까지 볼 수 있습니다.</span>
      </div>
      <div style="max-height:300px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table><thead><tr>
          <th style="width:34px">#</th><th style="width:100px">거래 일자</th><th>거래처</th>
          <th style="width:80px">단가</th><th style="width:70px">Box 수량</th><th style="width:70px">낱개 수량</th>
          <th style="width:80px">전체 수량</th><th style="width:100px">금액</th><th style="width:50px">행사</th><th style="width:50px">반품</th>
        </tr></thead><tbody id="saHistBody"></tbody></table>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center">
      <label style="font-size:12.5px; cursor:pointer"><input type="checkbox" id="hvEvtOnly" onchange="saHistRender()"> 행사만 보기</label>
      <span style="margin-left:auto"><button class="sa-btn" onclick="saHistClose()">✕ 닫기</button></span>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
/* 명세 그리드 페이징 상태 — ★선언이 init() 아래에 있으면 첫 렌더 때 undefined 가 된다.
     init() → puNew()/saNew() → 렌더가 '동기'로 돌아 이 줄보다 먼저 실행되기 때문.
     실제로 합계 아래 표시가 'undefined / 5행' 으로 나왔다(2026-07-25 수정). */
var PU_ROWS = 8, _pShown = 0, _pBound = false;
var _rows = [];        // 명세 행
var _list = [];        // 전표 목록
var _vendors = [];     // 거래처 마스터
var _venSum = {};      // 거래처별 총판매·총매입 {s,p} — 팝업에 표시하고 총판매 순으로 정렬(2026-08-04)
/* 고른 거래처의 부가세 설정 '별도'|'포함'|'면세' (TBL_VENDOR_MST.VAT_GB).
   비어 있으면 '별도' 로 본다 — 예전 자료는 이 칸이 비어 있는데, 지금까지의 동작이 별도였다. */
var _venVat = '별도';
var _prods = [];       // 상품 마스터
var _extItems = [];    // 거래처 통보품목(TBL_EXT_ITEM_MST) — 거래처가 준 코드로 찾기용
var _cur = null;       // 선택된 전표(수정 모드)
/* 수정 중인 전표가 '저장된 상태로' 현잔고에 이미 반영해 놓은 금액(판매금액 − 수금액 − 할인액).
   현잔고는 그 전표를 포함해 계산되므로, 거래후잔고를 낼 때 이 값을 빼지 않으면 이중으로 더해진다.
   신규 전표는 0. (2026-07-25 수정 — 전표를 고르면 거래후잔고가 두 배로 뜨던 문제) */
var _curNet = 0;
var _prodTargetRow = -1;

function n(v){ var x = Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x) ? x : 0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
/* 단가 표시용 — 소수점을 살린다(소수 2자리, 2026-08-05 요청·매입등록과 동일). fmt 는 반올림이라 230.5 가 231 로 보였다.
   금액(합계)은 종전대로 정수 반올림(fmt) — DB 도 DECIMAL(18,2)라 소수 2자리까지 저장된다. */
function fmtP(v){ v = Math.round(n(v)*100)/100; return v.toLocaleString(undefined, {maximumFractionDigits:2}); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
/* 메시지 — 프로젝트 공통 컴포넌트(asset/js/ui-message.js). 로그인 화면이 쓰는 그것과 같다.
     _alertBox(msg, {icon, okColor:'red', onOk})  ·  _confirmBox({msg, icon, okText, onOk, onCancel})
   SweetAlert 로 흉내 내려다 아이콘이 깨졌었다 — 표준 컴포넌트를 그대로 쓴다(2026-07-25). */
function swOk(msg){
  if (window._alertBox) return _alertBox(msg, { icon:'✅' });
  alert(String(msg).replace(/<br\s*\/?>/gi,'\n'));
}
function swErr(msg){
  if (window._alertBox) return _alertBox(msg, { icon:'❌', okColor:'red' });
  alert(String(msg).replace(/<br\s*\/?>/gi,'\n'));
}
function swAlert(msg){
  if (window._alertBox) return _alertBox(msg, { icon:'ℹ️' });
  alert(String(msg).replace(/<br\s*\/?>/gi,'\n'));
}
/* 📥 정산 엑셀 — 매출내역 화면에 있던 버튼을 이 화면으로 옮겼다(2026-08-01 요청).
   ★기능 자체는 옮기지 않았다. 파일 선택·미리보기·저장은 부모(물류관리 셸 logistics_demo2)의 기존 흐름을 그대로 부른다
     — 파서·출고장 인식·중복 파일 판정이 거기 다 있어서, 여기로 복사하면 두 벌이 되어 갈라진다.
   ★확인·저장 창은 화면 전체를 덮는 오버레이라 이 화면 위에 그대로 뜬다. */
function saSlsExcel(){
  try{
    if (window.parent && window.parent !== window && typeof window.parent.konetSlsExcelPick === 'function'){
      if (window.parent.konetSlsExcelPick()) return;
    }
  }catch(e){}   // 부모 접근 불가(단독 창으로 연 경우 등)
  swAlert('정산 엑셀은 <b>물류관리</b> 화면 안에서만 올릴 수 있습니다.<br>왼쪽 메뉴로 들어와 <b>매출 관리 ▸ 판매 등록</b> 에서 다시 눌러 주세요.');
}
function swConfirm(msg, title, okText){
  return new Promise(function(resolve){
    if (!window._confirmBox) { resolve(confirm(String(msg).replace(/<br\s*\/?>/gi,'\n'))); return; }
    _confirmBox({ msg:msg, icon:'❓', okText:okText||'확인',
                  onOk:function(){ resolve(true); }, onCancel:function(){ resolve(false); } });
  });
}
function post(url, body, isJson){
  return fetch(CTX+url, { method:'POST', credentials:'same-origin',
    headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded'},
    body: isJson ? JSON.stringify(body) : body });
}

/* ── 초기화 ───────────────────────────────────────────── */
(function init(){
  document.getElementById('saDt').value = today();
  var d = new Date(); d.setMonth(d.getMonth()-1);
  document.getElementById('saFrom').value = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01';
  document.getElementById('saTo').value = today();
  saNew();
  saLoadMasters();
  saLoad();
  /* 거래처 칸 입력검색 — 고르는 동작은 팝업과 같은 saVenPick() 을 그대로 탄다(잔고·원장·담당자 갱신 포함).
     _vendors 는 saLoadMasters() 가 나중에 채우므로 배열이 아니라 '함수'로 넘긴다. */
  _vendorPick(document.getElementById('saVenNm'), {
    list   : function(){ return _vendors.filter(saVenFit); },   // 거래유형 필터(＋신규/전체 버튼과 같은 기준)
    rank   : function(o){ return (_venSum[o.vendorCd]||{}).s||0; },   // 총판매(정산서+판매전표) 많은 순 — [거래처] 팝업과 같은 기준(2026-08-05)
    onPick : function(o){ saVenPick(o.vendorCd); },
    onClear: function(){ saVenVat(null); document.getElementById('saMgrNm').value=''; document.getElementById('saMgrNm').dataset.cd=''; saVenBal(''); saXrefLoad(''); }
  });
})();

/* 합계 표는 그리드 밖에 있으므로 가로 스크롤을 따라가게 맞춘다 */
(function bindFootScroll(){
  var g = document.getElementById('saGridWrap'), f = document.getElementById('saFootWrap');
  if (g && f) g.addEventListener('scroll', function(){ f.scrollLeft = g.scrollLeft; });
})();

/* 컬럼 폭 조절(2026-08-04 요청) — 머리글 오른쪽 경계를 끌면 그 칼럼이 늘고 준다.
   ★그리드와 합계 표의 colgroup 을 <같이> 바꾼다 — 한쪽만 바꾸면 칸 맞춤이 깨진다.
   ★끌고 나면 두 표의 min-width 를 칼럼 합으로 다시 잡는다 — 안 잡으면 넓힌 만큼
     다른 칼럼이 눌려 전체 폭이 그대로가 된다(table-layout:fixed 의 배분 규칙). */
(function bindColResize(){
  var gw = document.getElementById('saGridWrap'), fw = document.getElementById('saFootWrap');
  if (!gw || !fw) return;
  var gc = gw.querySelectorAll('colgroup col'), fc = fw.querySelectorAll('colgroup col');
  var gt = gw.querySelector('table'), ft = fw.querySelector('table');
  var ths = gw.querySelectorAll('thead th');

  function applyMin(){
    var sum = 0;
    for (var i = 0; i < gc.length; i++) sum += parseInt(gc[i].style.width, 10) || 0;
    gt.style.minWidth = sum + 'px';
    ft.style.minWidth = sum + 'px';
  }
  ths.forEach(function(th, i){
    if (i >= gc.length) return;
    var h = document.createElement('span');
    h.className = 'sa-colrz';
    h.title = '끌어서 칼럼 폭 조절';
    th.appendChild(h);
    h.addEventListener('mousedown', function(e){
      e.preventDefault(); e.stopPropagation();
      var sx = e.clientX, w0 = th.offsetWidth;
      function mv(ev){
        var w = Math.max(36, w0 + (ev.clientX - sx));
        gc[i].style.width = w + 'px';
        fc[i].style.width = w + 'px';
        applyMin();
      }
      function up(){
        document.removeEventListener('mousemove', mv);
        document.removeEventListener('mouseup', up);
        document.body.style.cursor = '';
      }
      document.body.style.cursor = 'col-resize';
      document.addEventListener('mousemove', mv);
      document.addEventListener('mouseup', up);
    });
    /* 더블클릭 = 처음 폭으로 */
    var w0px = gc[i].style.width;
    h.addEventListener('dblclick', function(){
      gc[i].style.width = w0px; fc[i].style.width = w0px; applyMin();
    });
  });
})();

/* 등록내용 새로고침 — 지금 보고 있는 전표를 서버에서 다시 읽는다.
   목록·원장·잔고도 같이 갱신한다. 신규 작성 중이면 목록만 새로 읽는다(입력분은 보존). */
function saReload(){
  var seq = _cur ? _cur.saleSeq : null;
  saLoad();
  if (seq) {
    post('/mangr/salesTrxDetail.do','saleSeq='+seq).then(function(r){return r.json();}).then(function(j){
      var d = j&&j.data; if(!d){ saNew(); return; }
      saApply(d);
    }).catch(function(){});
  } else {
    var cd = document.getElementById('saVenNm').dataset.cd||'';
    if (cd) saVenBal(cd);
  }
}

/* ★기준자료(상품·거래처·매칭코드)는 화면을 열 때 한 번만 읽으면 안 된다 (2026-08-01 지적:
     "상품 등록하고 다시 로그인하지 않으면 상품검색이 이전 것으로 나온다").
     이 화면은 물류관리 셸 안의 iframe 이라 한 번 뜨면 다시 로드되지 않는다 —
     다른 화면에서 상품·매칭코드를 등록해도 여기 목록은 옛것 그대로였다.
     그래서 상품 선택 팝업을 열 때마다 다시 읽고, 도착하면 열려 있는 목록을 그 자리에서 다시 그린다. */
function saLoadMasters(){
  post('/vendor/selectVendorMst.do','').then(function(r){return r.json();}).then(function(j){ _vendors=(j&&j.data)||[]; }).catch(function(){});
  /* 거래처 팝업용 — 거래처별 총판매·총매입(2026-08-04). 표시 + 총판매 순 정렬에 쓴다.
     못 받아와도 팝업은 이름순·금액 0 으로 그대로 뜬다. */
  post('/vendor/vendorTrxSum.do','').then(function(r){return r.json();}).then(function(j){
    _venSum = {};
    ((j&&j.data)||[]).forEach(function(o){
      /* 총판매 = 정산서(settleAmt) + 판매전표(trxAmt) — 내역은 칸에 마우스를 올리면 보인다 */
      _venSum[o.vendorCd] = { s:n(o.saleAmt), p:n(o.purchAmt), st:n(o.settleAmt), tx:n(o.trxAmt) };
    });
    }).catch(function(){});
  post('/prod/prodList.do','findData=').then(function(r){return r.json();}).then(function(j){ _prods=(j&&j.data)||[]; saProdRefreshed(); }).catch(function(){});
  /* 거래처 매칭코드 — 상품 선택 팝업에서 '거래처가 준 코드'로도 찾기 위한 목록 (2026-08-01) */
  post('/prod/extItemList.do','').then(function(r){return r.json();}).then(function(j){ _extItems=(j&&j.data)||[]; saProdRefreshed(); }).catch(function(){});
}
/* 새로 읽은 목록이 도착했을 때 — 팝업이 열려 있으면 그 자리에서 다시 그린다(닫혀 있으면 아무 일 없음) */
function saProdRefreshed(){
  var p=document.getElementById('saProdPop');
  if(p && p.classList.contains('on')) saProdRender();
}

/* ── 전표 입력 ────────────────────────────────────────── */
function saNew(){
  _cur = null; _curNet = 0; _rows = [];
  _xrefNm = {};                       // 거래처가 비워지므로 그 거래처 표기표도 비운다
  document.getElementById('saVenNm').value=''; document.getElementById('saVenNm').dataset.cd='';
  document.getElementById('saMgrNm').value=''; document.getElementById('saMgrNm').dataset.cd='';
  document.getElementById('saRemark').value=''; document.getElementById('saPayAmt').value='0'; document.getElementById('saDcAmt').value='0';
  document.getElementById('saDlvDt').value='';
  document.getElementById('saState').textContent = '신규 전표';
  for (var i=0;i<5;i++) _rows.push(emptyRow());
  saRender(); saNextNo();
  Array.prototype.forEach.call(document.querySelectorAll('#saListBody tr'), function(tr){ tr.classList.remove('on'); });
  saFocusFirstProd();                    // 진입 즉시 첫 상품칸에 커서(2026-08-04)
}
function emptyRow(){ return { prodCd:'', prodNm:'', spec:'', packQty:1, boxQty:0, eaQty:0, qty:0, unitPrice:0, amt:0, dcAmt:0,
                              supplyAmt:0, vatAmt:0, totAmt:0, serviceQty:0, remark:'', eventYn:'N', trxGb:'판매', taxGb:'과세' }; }
function saNextNo(){
  var dt = document.getElementById('saDt').value;
  if (!dt || _cur) return;
  post('/mangr/salesTrxNextNo.do','saleDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){ document.getElementById('saNo').value = (j&&j.data)||'0001'; })
    .catch(function(){ document.getElementById('saNo').value='0001'; });
}
/* 명세 그리드도 매출내역과 같은 방식 — 8행씩 보여주고 스크롤하면 이어붙인다(2026-07-25 요청).
     · 화면에 안 그려진 행도 _rows 에 그대로 있어 저장에는 전부 들어간다(입력값 보존).
     · 편집으로 다시 그릴 때 이미 펼친 만큼(_pShown)은 유지한다 — 안 그러면 보던 줄이 접힌다. */
// (PU_ROWS·_pShown·_pBound 선언은 파일 위 전역 블록으로 옮겼다 — init() 보다 먼저 값이 있어야 한다)
function saGridMore(cnt){
  if (_pShown >= _rows.length) return;
  _pShown = Math.min(_pShown + (cnt||PU_ROWS), _rows.length);
  saRender();
}
function saGridBind(){
  var g = document.getElementById('saGridWrap');
  if (!g || _pBound) return; _pBound = true;
  g.addEventListener('scroll', function(){
    if (_pShown >= _rows.length) return;
    if (g.scrollTop + g.clientHeight >= g.scrollHeight - 30) saGridMore();
  });
}
function saGridPager(){
  var el = document.getElementById('saGridPager');
  if (_pShown >= _rows.length) {
    el.innerHTML = _rows.length > PU_ROWS
      ? '<span style="color:#5a6b7a; font-size:12.5px">총 '+_rows.length+'행 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a; font-size:12.5px">'+_pShown+' / <b>'+_rows.length+'</b>행'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="sa-btn" style="height:22px;margin-left:8px;font-size:12px" onclick="saGridMore('+_rows.length+')">모두 표시</button>';
}
function saRender(){
  var _keep = saCaptureFocus();          // 다시 그려도 커서가 있던 칸을 유지(2026-08-04 키보드 입력)
  var h = '';
  if (_pShown < PU_ROWS) _pShown = PU_ROWS;
  if (_pShown > _rows.length) _pShown = _rows.length;
  _rows.slice(0, _pShown).forEach(function(o,i){
    /* 반품 줄은 **줄 전체를 빨간색**으로 (2026-08-03 요청) — 거래구분 칸만 봐서는
         여러 줄 중 어느 것이 반품인지 눈에 안 들어온다. 글자색은 CSS(tr.ret)에서 준다. */
    h += '<tr'+(o.trxGb==='반품' ? ' class="ret"' : '')+'>'
      /* 맨 앞 순번 — 화면에 보이는 줄 번호(1부터). 저장 자료가 아니라 표시용이라
         줄을 지우거나 순서를 바꾸면 자동으로 다시 매겨진다. */
      + '<td class="no">'+(i+1)+'</td>'
      /* 행 조작 — 주문 받은 순서대로 넣기 위한 열(2026-07-31).
           ＋ = 이 줄 '위'에 빈 줄 삽입 / ▲▼ = 순서 바꾸기.
         (예전 ＋ 는 상품선택이었다. 상품선택은 아래 상품코드 칸을 눌러 그대로 쓴다) */
      + '<td class="ops">'
      +   '<span title="이 줄 위에 새 줄 삽입" onclick="saInsRow('+i+')">＋</span>'
      +   '<span title="한 줄 위로" onclick="saMoveRow('+i+',-1)">▲</span>'
      +   '<span title="한 줄 아래로" onclick="saMoveRow('+i+',1)">▼</span>'
      + '</td>'
      /* 상품코드 = 우리 코드. 그 아래 작게 '거래처가 부르는 코드'(매칭코드)를 함께 보여 준다(2026-08-01).
         수동 판매는 주문서에 적힌 대로 넣고 확인해야 해서, 우리 코드만 보이면 대조가 안 된다.
         ★빈 줄은 '상품코드 칸에 직접 입력검색'(2026-08-04) — 칸에 쳐서 ↑↓·Enter 로 고른다(saPin*).
           고르면 그 행에 담기고 커서가 EA수량 칸으로 넘어간다. [🔍]는 종전 상품 선택 팝업. */
      + (o.prodCd
          ? '<td><span class="lnk" title="클릭 → 다른 상품으로 바꾸기" onclick="saProdOpen('+i+')">'+esc(o.prodCd)+'</span>'
              /* 매칭으로 골라 넣은 행만 그 코드를 보여 준다 — 원코드로 넣었으면 표시가 없다(구별) */
              + (o.extCd ? '<div style="font-size:11px;color:#274b8f;margin-top:1px" title="거래처가 부르는 품목코드 (매칭코드)로 넣었습니다">🔖 '+esc(o.extCd)+'</div>' : '')
              + '</td>'
          : '<td class="txt" style="padding:2px 3px"><div style="display:flex;align-items:center;gap:2px">'
              + '<input class="saPin" data-r="'+i+'" data-f="prod" placeholder="상품검색" autocomplete="off"'
              +   ' oninput="saPinInput(this)" onkeydown="saPinKey(this,event)" onblur="saPinBlur()"'
              +   ' style="width:100%;border:0;background:transparent;font-size:13.5px;text-align:left;padding:4px 2px">'
              + '<span class="lnk" title="상품 선택 팝업으로 찾기" style="font-size:12px" onclick="saProdOpen('+i+')">🔍</span>'
              + '</div></td>')
      /* 품명 클릭 = 그 거래처의 판매단가 이력. 찾기 쉽게 📈 아이콘을 붙였다(2026-07-25)
         ★거래처 표기로 바뀐 품명은 🔗 로 표시하고 우리 품명은 hover 로 함께 보여 준다(2026-08-01).
           출고는 요청한 이름으로 나가야 하지만, 우리가 무엇을 파는지도 화면에서 잃으면 안 된다. */
      + '<td class="txt">'+ (function(){
            if(!o.prodNm) return '';
            var our = saOurNm(o.prodCd), alias = (our && our !== o.prodNm);
            return '<span class="lnk" onclick="saHistOpen('+i+')" title="'
              + (alias ? '거래처가 요청한 품명입니다 (우리 품명: '+esc(our)+')&#10;' : '')
              + '클릭 → 이 거래처의 판매단가 이력(최대 3년)">'+esc(o.prodNm)+'</span>'
              + (alias ? ' <span title="거래처 요청 품명 — 이 이름으로 출고됩니다 (우리 품명: '+esc(our)+')" style="cursor:help">🔗</span>' : '')
              + ' <span class="hist" onclick="saHistOpen('+i+')" title="판매단가 이력 보기">📈</span>';
          })() +'</td>'
      + '<td class="txt">'+ (o.packQty?('['+fmt(o.packQty)+']'):'') + esc(o.spec) +'</td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="boxQty" value="'+n(o.boxQty)+'" onchange="saSet('+i+',\'boxQty\',this.value)"></td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="eaQty" value="'+n(o.eaQty)+'" onchange="saSet('+i+',\'eaQty\',this.value)"></td>'
      + '<td class="num">'+fmt(o.qty)+'</td>'
      /* 단가·DC 는 천단위 콤마로 보여 준다(2026-08-04 "단가 단위구분") — n() 이 콤마를 지우므로 계산은 그대로다 */
      + '<td><input inputmode="decimal" data-r="'+i+'" data-f="unitPrice" value="'+fmtP(o.unitPrice)+'" onchange="saSet('+i+',\'unitPrice\',this.value)"></td>'
      + '<td class="num">'+fmt(o.amt)+'</td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="dcAmt" value="'+fmt(o.dcAmt)+'" onchange="saSet('+i+',\'dcAmt\',this.value)"></td>'
      + '<td class="num">'+fmt(o.supplyAmt)+'</td>'
      + '<td class="num">'+fmt(o.vatAmt)+'</td>'
      + '<td class="num">'+fmt(o.totAmt)+'</td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="serviceQty" value="'+n(o.serviceQty)+'" onchange="saSet('+i+',\'serviceQty\',this.value)"></td>'
      + '<td><input class="txt" data-r="'+i+'" data-f="remark" value="'+esc(o.remark)+'" onchange="saSet('+i+',\'remark\',this.value)"></td>'
      + '<td><input type="checkbox" '+(o.eventYn==='Y'?'checked':'')+' onchange="saSet('+i+',\'eventYn\',this.checked?\'Y\':\'N\')"></td>'
      + '<td><select onchange="saSet('+i+',\'trxGb\',this.value)" style="border:0;background:transparent;font-size:12.5px">'
      +   '<option '+(o.trxGb==='판매'?'selected':'')+'>판매</option><option '+(o.trxGb==='반품'?'selected':'')+'>반품</option></select>'
      +   ' <span class="del" onclick="saDelRow('+i+')">✖</span></td>'
      + '</tr>';
  });
  document.getElementById('saBody').innerHTML = h;
  saGridBind(); saGridPager();
  saCalc();
  saRestoreFocus(_keep);                 // _focusNext 가 있으면 그 칸으로, 없으면 있던 칸 그대로
}
function saSet(i, k, v){
  var o = _rows[i]; if(!o) return;
  o[k] = (k==='remark'||k==='eventYn'||k==='trxGb') ? v : n(v);
  /* ★BOX수량을 치면 EA수량이 '친 대로' 따라온다 (2026-08-01 확정 — 입수로 환산하지 않는다).
       입수 48짜리에 BOX 1 → EA 1 · 합계 1. 합계수량은 EA 를 따라가고 화면에서 고칠 수 없다(계산 전용). */
  if (k==='boxQty') o.eaQty = n(o.boxQty);
  saCalcRow(o);
  if (i === _rows.length-1 && o.prodCd) saEnsureTail();   // 마지막 줄을 쓰면 새 줄 자동 추가(그 줄이 보이게)
  saRender();
}
function saCalcRow(o){
  /* 합계수량 = EA수량 그대로 (2026-08-01 확정 — 입수로 환산하지 않는다).
     BOX 1 치면 EA 1 · 합계 1. 입수([48])는 규격 칸에 참고로 보일 뿐 수량 계산에 쓰지 않는다. */
  o.qty = n(o.eaQty);
  o.amt = Math.round(o.qty * n(o.unitPrice)) - n(o.dcAmt);
  /* 부가세 = ① 거래처 설정(TBL_VENDOR_MST.VAT_GB) × ② 품목 과세여부 (2026-08-03 요청)
       · 별도(기본) : 공급가 = 금액,        부가세 = 금액의 10%   → 합계 = 금액 + 부가세
       · 포함       : 공급가 = 금액 ÷ 1.1,  부가세 = 금액 − 공급가 → 합계 = 금액 (그대로)
       · 면세       : 부가세 0
     ★품목이 면세면 거래처가 무엇이든 면세다(면세 품목에 세금을 붙일 수는 없다).
     ★거래처를 바꾸면 담긴 줄을 전부 다시 계산한다(saVenVat 참고). */
  var vg = _venVat || '별도';
  var tax = (o.taxGb !== '면세') && (vg !== '면세');
  if (!tax)                 { o.supplyAmt = o.amt;                        o.vatAmt = 0; }
  else if (vg === '포함')   { o.supplyAmt = Math.round(o.amt / 1.1);      o.vatAmt = o.amt - o.supplyAmt; }
  else                      { o.supplyAmt = o.amt;                        o.vatAmt = Math.round(o.amt * 0.1); }
  o.totAmt = o.supplyAmt + o.vatAmt;
}
/* 거래처의 부가세 설정을 화면에 반영 — 담긴 줄 전부 재계산 + 거래처 칸 옆 표시 */
function saVenVat(o){
  _venVat = (o && o.vatGb) || '별도';
  var b = document.getElementById('saVatTag');
  if (b) {
    b.textContent = '부가세 ' + _venVat;
    b.style.display = '';
    b.className = 'vat-tag' + (_venVat === '면세' ? ' free' : (_venVat === '포함' ? ' inc' : ''));
  }
  /* 담긴 줄을 다시 계산하고 화면·합계까지 갱신 — 거래처를 바꾸면 부가세가 그 자리에서 달라져야 한다 */
  _rows.forEach(saCalcRow); saRender();
}
function saDelRow(i){ _rows.splice(i,1); saTail(); saRender(); }
/* ── 행 순서 (2026-07-31) ───────────────────────────────
     거래처가 불러 준 순서 그대로 명세가 서야 한다. 저장할 때 화면 순서가 그대로
     ROW_NO 1,2,3… 이 되므로(saveSalesTrx), 여기서 줄을 옮기면 전표에도 그 순서로 남는다.
     · saInsRow(i) : i번째 줄 '위'에 빈 줄을 끼운다 — 빠뜨린 품목을 사이에 넣을 때
     · saMoveRow(i,d) : 한 줄 위/아래로. 맨 끝의 빈 줄과는 자리를 바꾸지 않는다
       (빈 줄은 항상 맨 아래에 있어야 '마지막 줄을 쓰면 새 줄 추가' 규칙이 깨지지 않는다) */
/* 맨 아래 빈 줄은 항상 하나 있어야 한다 — '마지막 줄을 쓰면 새 줄이 붙는' 규칙(saSet)이
   거기에 걸려 있다. 줄을 끼우거나 옮기거나 지운 뒤 이걸 불러 모양을 되돌린다. */
/* 마지막 줄에 상품이 들어오면 그 뒤에 빈 줄('선택')을 하나 남겨 둔다 (2026-08-03 요청).
   ★_pShown 까지 같이 늘려야 한다 — 줄을 배열에 넣기만 하고 '보여 줄 줄 수'를 안 늘리면
     줄은 생겼는데 화면에는 안 나온다(상품을 골라 담을 때 실제로 그랬다). */
function saEnsureTail(){
  var last = _rows[_rows.length-1];
  if (!last || last.prodCd) { _rows.push(emptyRow()); }
  if (_pShown < _rows.length) _pShown = _rows.length;
  saScrollTail();
}
/* 새로 생긴 빈 줄이 화면에 보이게 그리드를 끝까지 내린다 (2026-08-03 요청).
   그리드는 높이가 고정(210px)이라 줄이 늘면 아래로 밀려 나가는데, 지금까지는
   오른쪽 스크롤막대를 손으로 내려야 그 줄이 보였다.
   ★다시 그린 뒤라야 높이가 반영되므로 setTimeout 으로 한 박자 늦춘다. */
function saScrollTail(){
  setTimeout(function(){
    var w = document.getElementById('saGridWrap');
    if (!w) return;
    /* 사용자가 위쪽 줄을 보려고 일부러 올려 둔 경우까지 끌어내리지는 않는다 —
       마지막 줄 근처(두 줄 높이 안)에 있을 때만 따라 내린다. */
    var gap = w.scrollHeight - w.scrollTop - w.clientHeight;
    if (gap <= 74) w.scrollTop = w.scrollHeight;
  }, 0);
}
function saTail(){
  if (!_rows.length) { _rows.push(emptyRow()); return; }
  if (_rows[_rows.length-1].prodCd) _rows.push(emptyRow());
}
function saInsRow(i){
  _rows.splice(i, 0, emptyRow());
  saTail();
  _pShown = Math.min(_rows.length, Math.max(_pShown + 1, i + 2));   // 끼운 줄이 화면에 보이게
  saRender();
}
function saMoveRow(i, d){
  var j = i + d;
  if (j < 0 || j >= _rows.length) return;
  if (!_rows[i].prodCd && !_rows[j].prodCd) return;                 // 빈 줄끼리는 의미 없음
  var t = _rows[i]; _rows[i] = _rows[j]; _rows[j] = t;
  saTail();                                                          // 맨 끝 빈 줄을 끌어내렸으면 되돌린다
  if (_pShown < j + 1) _pShown = Math.min(j + 1, _rows.length);
  saRender();
}
function saCalc(){
  var t = {box:0, ea:0, qty:0, amt:0, dc:0, sup:0, vat:0, tot:0, svc:0};
  _rows.forEach(function(o){
    if(!o.prodCd) return;
    var sign = (o.trxGb==='반품') ? -1 : 1;
    t.box += n(o.boxQty)*sign; t.ea += n(o.eaQty)*sign; t.qty += n(o.qty)*sign;
    t.amt += n(o.amt)*sign; t.dc += n(o.dcAmt); t.sup += n(o.supplyAmt)*sign;
    t.vat += n(o.vatAmt)*sign; t.tot += n(o.totAmt)*sign; t.svc += n(o.serviceQty);
  });
  document.getElementById('tBox').textContent=fmt(t.box); document.getElementById('tEa').textContent=fmt(t.ea);
  document.getElementById('tQty').textContent=fmt(t.qty); document.getElementById('tAmt').textContent=fmt(t.amt);
  document.getElementById('tDc').textContent=fmt(t.dc);   document.getElementById('tSup').textContent=fmt(t.sup);
  document.getElementById('tVat').textContent=fmt(t.vat); document.getElementById('tTot').textContent=fmt(t.tot);
  document.getElementById('tSvc').textContent=fmt(t.svc);
  /* 거래후잔고 = 현잔고 − (이 전표가 이미 반영해 둔 금액) + (지금 화면 금액)
       · 신규     : _curNet = 0 → 현잔고 + 이번 전표
       · 수정 중  : 고친 만큼만 움직인다. 아무것도 안 고치면 현잔고와 같다
       · 삭제     : 저장 후 목록·잔고를 다시 읽으므로 그만큼 빠진다 */
  var now = n(document.getElementById('saBalNow').textContent);
  var net = t.tot - n(document.getElementById('saPayAmt').value) - n(document.getElementById('saDcAmt').value);
  document.getElementById('saBalAfter').textContent = fmt(now - _curNet + net);
  return t;
}
function saPayFill(){ document.getElementById('saPayAmt').value = n(document.getElementById('tTot').textContent); saCalc(); }
function saDcFill(){   // 털기 — 판매금액에서 수금액을 뺀 잔돈을 할인으로
  var rest = n(document.getElementById('tTot').textContent) - n(document.getElementById('saPayAmt').value);
  document.getElementById('saDcAmt').value = rest > 0 ? rest : 0; saCalc();
}

/* ── 저장 / 삭제 ──────────────────────────────────────── */
function saSave(){
  var venCd = document.getElementById('saVenNm').dataset.cd || '';
  if (!venCd) { swErr('거래처를 선택하세요.'); return; }
  var items = _rows.filter(function(o){ return o.prodCd; });
  if (!items.length) { swErr('상품을 한 줄 이상 입력하세요.'); return; }
  var t = saCalc();
  var dto = {
    saleSeq: _cur ? _cur.saleSeq : null,
    saleDt: document.getElementById('saDt').value,
    dlvDt: document.getElementById('saDlvDt').value,
    saleNo: document.getElementById('saNo').value,
    custCd: venCd, custNm: document.getElementById('saVenNm').value,
    mgrCd: document.getElementById('saMgrNm').dataset.cd||'', mgrNm: document.getElementById('saMgrNm').value,
    whCd:'', whNm: document.getElementById('saWhNm').value,
    totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty,
    supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:n(document.getElementById('saDcAmt').value),
    payGb: document.getElementById('saPayGb').value, payAmt:n(document.getElementById('saPayAmt').value),
    taxGb: '과세',
    remark: document.getElementById('saRemark').value,
    items: items
  };
  post('/mangr/salesTrxSave.do', dto, true).then(function(r){
    return r.text().then(function(t2){ if(!r.ok) throw new Error(t2); return t2; });
  }).then(function(){ swOk('저장했습니다.'); saNew(); saLoad(); })
    .catch(function(e){ swErr('저장에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
}
function saDelete(){
  if (!_cur) { swErr('목록에서 전표를 먼저 선택하세요.'); return; }
  swConfirm('이 전표를 삭제할까요?<br><span style="font-size:13px;color:#3d4d5c">재고(수불원장)에서 빠졌던 출고도 함께 되돌아옵니다.</span>', null, '삭제')
    .then(function(ok){
      if(!ok) return;
      post('/mangr/salesTrxDelete.do', { saleSeq:_cur.saleSeq, saleDt:_cur.saleDt, saleNo:_cur.saleNo }, true)
        .then(function(r){ if(!r.ok) return r.text().then(function(t){ throw new Error(t); }); swOk('삭제했습니다.'); saNew(); saLoad(); })
        .catch(function(e){ swErr('삭제에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
    });
}

/* ── 전표 목록 ────────────────────────────────────────── */
function saLoad(){
  var b = 'fromDt='+encodeURIComponent(document.getElementById('saFrom').value)
        + '&toDt='+encodeURIComponent(document.getElementById('saTo').value)
        + '&findData='+encodeURIComponent(document.getElementById('saFindNm').value);
  document.getElementById('saListBody').innerHTML = '<tr><td colspan="9" class="sa-msg">조회 중…</td></tr>';
  post('/mangr/salesTrxList.do', b).then(function(r){return r.json();}).then(function(j){
    _list = (j&&j.data)||[]; saListRender();
  }).catch(function(e){ document.getElementById('saListBody').innerHTML='<tr><td colspan="9" class="sa-msg" style="color:#c0392b">조회 오류 : '+esc(e.message)+'</td></tr>'; });
}
/* 하단 목록 — 5행만 보여주고 스크롤이 바닥에 닿으면 다음 5행을 이어붙인다(매출내역과 같은 방식).
     행수에 따라 화면 높이가 들쑥날쑥하던 것을 막는다(2026-07-25 요청).
     페이지 버튼 대신 아래에 '몇 건까지 나왔는지'와 [모두 표시]를 둔다. */
var LIST_ROWS = 5, _lShown = 0, _lBound = false;
function saRowHtml(o, i){
  return '<tr onclick="saPick('+i+')">'
    + '<td><button class="sa-btn" style="height:24px;padding:0 8px;font-size:12px" onclick="event.stopPropagation();saCopy('+i+')">복사저장</button></td>'
    + '<td>'+esc(fmtDt(o.saleDt))+'</td><td>'+esc(o.saleNo)+'</td>'
    + '<td class="txt" style="text-align:left">'+esc(o.custNm)+'</td><td>'+esc(o.mgrNm)+'</td>'
    + '<td>'+n(o.prodCnt)+'</td><td class="num">'+fmt(o.totAmt)+'</td>'
    + '<td>'+esc(o.whNm)+'</td><td>'+esc(o.regUser)+'</td></tr>';
}
function saListRender(){
  document.getElementById('saTotal').textContent = _list.length;
  var tb = document.getElementById('saListBody');
  if (!_list.length) { tb.innerHTML='<tr><td colspan="9" class="sa-msg">전표가 없습니다.</td></tr>'; _lShown=0; saPagerRender(); saSumRender(); return; }
  _lShown = Math.min(LIST_ROWS, _list.length);
  tb.innerHTML = _list.slice(0,_lShown).map(function(o,i){ return saRowHtml(o,i); }).join('');
  saListBind();
  saPagerRender(); saSumRender();
}
function saListMore(cnt){
  if (_lShown >= _list.length) return;
  var to = Math.min(_lShown + (cnt||LIST_ROWS), _list.length), h='';
  for (var i=_lShown; i<to; i++) h += saRowHtml(_list[i], i);
  document.getElementById('saListBody').insertAdjacentHTML('beforeend', h);
  _lShown = to; saPagerRender();
}
function saListBind(){
  var w = document.getElementById('saListWrap');
  if (!w || _lBound) return; _lBound = true;
  w.addEventListener('scroll', function(){
    if (_lShown >= _list.length) return;
    if (w.scrollTop + w.clientHeight >= w.scrollHeight - 30) saListMore();   // 바닥 30px 전에 미리
  });
}
function saPagerRender(){
  var el = document.getElementById('saPager');
  if (_lShown >= _list.length) {
    el.innerHTML = _list.length > LIST_ROWS
      ? '<span style="color:#5a6b7a; font-size:12.5px">총 '+_list.length+'건 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a; font-size:12.5px">'+_lShown+' / <b>'+_list.length+'</b>건'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="sa-btn" style="height:24px;margin-left:8px;font-size:12px" onclick="saListMore('+_list.length+')">모두 표시</button>';
}
function fmtDt(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function saSumRender(){
  var p=0, r=0, pay=0, dc=0;
  _list.forEach(function(o){ var a=n(o.totAmt); if(a<0) r+=a; else p+=a; pay+=n(o.payAmt); dc+=n(o.dcAmt); });
  document.getElementById('sPurch').textContent=fmt(p);
  document.getElementById('sRet').textContent=fmt(r);
  document.getElementById('sPay').textContent=fmt(pay);
  document.getElementById('sDc').textContent=fmt(dc);
  document.getElementById('sUnpaid').textContent=fmt(p+r-pay-dc);
}
function saPick(i){
  var o = _list[i]; if(!o) return;
  post('/mangr/salesTrxDetail.do','saleSeq='+o.saleSeq).then(function(r){return r.json();}).then(function(j){
    var d = j&&j.data; if(!d) return;
    saApply(d);
    Array.prototype.forEach.call(document.querySelectorAll('#saListBody tr'), function(tr,k){ tr.classList.toggle('on', k===i); });
  });
}
/* 서버에서 읽은 전표 1건을 상단 입력 영역에 그대로 얹는다 (선택·새로고침 공용) */
function saApply(d){
  _cur = d;
  _curNet = n(d.totAmt) - n(d.payAmt) - n(d.dcAmt);   // 이 전표가 현잔고에 이미 반영해 둔 금액
  document.getElementById('saDt').value = fmtDt(d.saleDt);
  document.getElementById('saNo').value = d.saleNo;
  var v = document.getElementById('saVenNm'); v.value = d.custNm||''; v.dataset.cd = d.custCd||'';
  var m = document.getElementById('saMgrNm'); m.value = d.mgrNm||''; m.dataset.cd = d.mgrCd||'';
  /* 저장된 전표를 열 때도 그 거래처의 부가세 설정을 적용한다 —
     안 하면 직전에 보던 거래처의 설정이 남아 금액이 달리 보인다. */
  saVenVat(_vendors.filter(function(x){ return String(x.vendorCd)===String(d.custCd||''); })[0]);
  document.getElementById('saWhNm').value = d.whNm||'물류창고';
  document.getElementById('saDlvDt').value = d.dlvDt ? fmtDt(d.dlvDt) : '';
  document.getElementById('saRemark').value = d.remark||'';
  document.getElementById('saPayGb').value = d.payGb||'외상';
  document.getElementById('saPayAmt').value = n(d.payAmt);
  document.getElementById('saDcAmt').value = n(d.dcAmt);
  /* 매칭판매 표기(extCd)는 이제 DB(TBL_SALES_TRX_DTL.EXT_CD)에서 그대로 온다 (2026-08-06 신설) —
     품명 추정 방식은 통보명=마스터명인 상품에서 오판해 폐기. EXT_CD 칼럼 추가 이전의 옛 전표는 표시가 없다(정확). */
  _rows = (d.items||[]).map(function(x){ x.taxGb='과세'; return x; });
  _rows.push(emptyRow());
  /* 저장된 품명은 그대로 둔다(그 전표의 사실). 표기표는 이후 '품목 추가' 에만 쓴다. */
  saXrefLoad(d.custCd||'', false);
  document.getElementById('saState').textContent = '수정 중 — '+fmtDt(d.saleDt)+' / '+d.saleNo;
  saRender(); saVenBal(d.custCd);
}
/* ── 복사저장 ─────────────────────────────────────────
     지난 전표의 명세를 그대로 두고 '판매일자'와 '거래처'만 바꿔 새 전표로 만든다.
     같은 물건을 다른 거래처에도 팔거나, 같은 거래처에 반복 판매할 때 쓴다.
     팝업에서 일자·거래처를 고르면 그 조건으로 상단에 복사본이 올라온다(저장은 아직 안 함). */
var _cpSrc = -1;
function saCopy(i){
  _cpSrc = i;
  var o = _list[i];
  document.getElementById('cpDt').value = o ? fmtDt(o.saleDt) : today();
  document.getElementById('cpQ').value = '';
  saCopyRender();
  document.getElementById('saCopyPop').classList.add('on');
}
function saCopyClose(){ document.getElementById('saCopyPop').classList.remove('on'); }
/* 거래처 팝업 공통 정렬 — <총판매금액 많은 순>, 같거나 없으면 이름순(2026-08-04 요청) */
function saVenSort(l){
  l.sort(function(a,b){
    var d = ((_venSum[b.vendorCd]||{}).s||0) - ((_venSum[a.vendorCd]||{}).s||0);
    return d || String(a.vendorNm||'').localeCompare(String(b.vendorNm||''), 'ko');
  });
  return l;
}
function saCopyRender(){
  var q = (document.getElementById('cpQ').value||'').toLowerCase();
  var l = saVenSort(_vendors.filter(function(o){
    if(!saVenFit(o)) return false;
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  })).slice(0,200);
  document.getElementById('cpBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="saCopyPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td>'
         + '<td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td><td>'+esc(o.alias)+'</td>'
         + '<td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="7" class="sa-msg">검색 결과가 없습니다.</td></tr>';
}
function saCopyPick(cd){
  var src = _list[_cpSrc]; if(!src) { saCopyClose(); return; }
  var ven = _vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0];
  var dt  = document.getElementById('cpDt').value || today();
  saCopyClose();
  post('/mangr/salesTrxDetail.do','saleSeq='+src.saleSeq).then(function(r){return r.json();}).then(function(j){
    var d = j&&j.data; if(!d) return;
    saApply(d);                       // 명세를 그대로 올린 뒤
    _cur = null; _curNet = 0;         // 새 전표로 돌린다 — 현잔고에 반영된 게 없다
    document.getElementById('saDt').value = dt;
    if (ven) {
      var v = document.getElementById('saVenNm'); v.value = ven.vendorNm||''; v.dataset.cd = ven.vendorCd||'';
      var m = document.getElementById('saMgrNm'); m.value = ven.mgrNm||''; m.dataset.cd = ven.mgrCd||'';
      saVenBal(ven.vendorCd);         // 바뀐 거래처의 현잔고·원장으로 갱신
    }
    document.getElementById('saState').textContent =
      '복사본 — ' + dt + ' / ' + (ven?ven.vendorNm:'') + ' · 내용 확인 후 [저장]';
    saNextNo();
    Array.prototype.forEach.call(document.querySelectorAll('#saListBody tr'), function(tr){ tr.classList.remove('on'); });
  }).catch(function(e){ swErr('복사에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
}

/* ── 거래처 / 상품 / 단가이력 팝업 ───────────────────── */
/* ── 거래처 거래유형 필터 (2026-08-03 요청) ─────────────────────────
     이 화면은 '매출' 화면이라 매출 거래처만 보여 주는 게 맞다(거래처가 400여 종이라
     반대편 거래처가 섞이면 고르기 어렵다). 다만 —
     · '매입&매출' 은 양쪽 다 보인다.
     · **거래유형이 안 적힌 예전 거래처는 그대로 보여 준다** — 안 그러면 분류를 안 해 둔
       거래처가 화면에서 통째로 사라져 "거래처가 없어졌다" 가 된다.
     · [전체] 로 끄면 모두 보인다(오분류를 찾을 때 필요). */
  var _venAll = false;
  function saVenFit(o){
    if (_venAll) return true;
    var g = String((o && o.vendorGb) || '');
    return !g || g.indexOf('매출') >= 0;
  }
  function saVenAll(on){
    _venAll = !!on;
    var b = document.getElementById('saVenAllBtn');
    if (b) { b.textContent = _venAll ? '전체 ✔' : '전체'; b.classList.toggle('teal', _venAll); }
    saVenRender();
  }
  /* 없는 거래처를 이 자리에서 등록 — 저장되면 목록에 넣고 곧바로 고른 상태로 만든다 */
  function saVenNew(){
    var box = document.getElementById('saVenNm');
    var typed = (box && box.value || '').trim();
    /* 팝업 검색칸에 친 글자가 있으면 그걸 우선 쓴다(대개 거기서 못 찾아 누른다) */
    var q = document.getElementById('saVenQ');
    if (q && document.getElementById('saVenPop').classList.contains('on') && (q.value||'').trim()) typed = q.value.trim();
    _vendorQuickOpen({
      gb: '매출', ctx: CTX, name: typed,
      list: function(){ return _vendors; },
      onDone: function(o){
        _vendors.push(o);
        saVenClose();
        if (box) { box.value = o.vendorNm; box.dataset.cd = o.vendorCd; }
        saVenPick(o.vendorCd);
        swOk('거래처를 등록했습니다 — '+o.vendorNm+' ('+o.vendorCd+')');
      }
    });
  }
  function saVenOpen(){ document.getElementById('saVenPop').classList.add('on'); document.getElementById('saVenQ').value=''; saVenRender(); }
function saVenClose(){ document.getElementById('saVenPop').classList.remove('on'); }
function saVenRender(){
  var q = (document.getElementById('saVenQ').value||'').toLowerCase();
  var l = saVenSort(_vendors.filter(function(o){
    if(!saVenFit(o)) return false;
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  })).slice(0,200);
  document.getElementById('saVenBody').innerHTML = l.length ? l.map(function(o){
    var gb = String(o.vendorGb||''), vt = String(o.vatGb||'') || '별도';
    var sum = _venSum[o.vendorCd] || {};
    return '<tr class="pick" onclick="saVenPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td><td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td>'
         /* 거래유형·부가세도 같이 보여 준다 (2026-08-03 요청) — 고르기 전에 성격을 알 수 있게.
            부가세가 비어 있는 예전 거래처는 '별도*' 로 — 계산도 별도로 하고 있음을 별표로 알린다. */
         + '<td>'+(gb ? '<span class="vp-gb'+(gb.indexOf('&')>=0?' both':'')+'">'+esc(gb)+'</span>'
                      : '<span class="vp-gb none">미지정</span>')+'</td>'
         + '<td><span class="vat-tag'+(vt==='면세'?' free':(vt==='포함'?' inc':''))+'">'+esc(vt)+(o.vatGb?'':'*')+'</span></td>'
         /* 총판매·총매입 — 0 이면 빈칸(숫자 소음을 줄인다). 이 목록의 정렬 기준이 총판매다.
            ★총판매에는 <정산서 매출과 판매전표가 모두> 들어간다 — hover 로 내역을 보여 준다(2026-08-04). */
         + '<td class="num"'+(sum.s ? ' title="정산서 '+fmt(sum.st)+' + 판매전표 '+fmt(sum.tx)+' = '+fmt(sum.s)+'"' : '')+'>'
         +   (sum.s ? fmt(sum.s) : '')+'</td>'
         + '<td class="num">'+(sum.p ? fmt(sum.p) : '')+'</td>'
         + '<td>'+esc(o.alias)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="9" class="sa-msg">검색 결과가 없습니다.</td></tr>';
}
function saVenPick(cd){
  var o = _vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0]; if(!o) return;
  var v = document.getElementById('saVenNm'); v.value = o.vendorNm||''; v.dataset.cd = o.vendorCd||'';
  var m = document.getElementById('saMgrNm'); m.value = o.mgrNm||''; m.dataset.cd = o.mgrCd||'';
  saVenVat(o);
  saVenClose(); saVenBal(o.vendorCd); saXrefLoad(o.vendorCd);
}

/* ── 거래처 표기(품명) ────────────────────────────────────
     ★출고는 '거래처가 요청한 품목명' 으로 나가야 한다 (2026-08-01).
     코네트 품목은 하나지만 거래처는 같은 물건을 자기 이름으로 부른다. 그 이름을 명세 품명에
     채워 저장하면 TBL_SALES_TRX_DTL.PROD_NM 에 그대로 남아 명세서·조회에 그 이름으로 보인다.
     · 표기가 없는 품목은 우리 PROD_NM 을 그대로 쓴다(_xrefNm 에 없으면 원래 동작).
     · 품명 칸은 입력칸이 아니라 표시 전용이라, 거래처를 바꾸면 담긴 행도 다시 맞춰도 안전하다
       (사람이 손으로 고쳐 둔 값을 덮어쓸 여지가 없다).
     · 우리 품명은 사라지지 않는다 — 셀 hover(title)로 함께 보여 준다. */
var _xrefNm = {};        // 우리 prodCd → 그 거래처 표기(EXT_ITEM_NM)
/* 우리 품명은 '상품마스터(_prods)' 에서 직접 읽는다 (2026-08-01).
   ★행에 찍힌 prodNm 을 우리 이름으로 기억해 두면 안 된다 — 저장된 전표를 불러올 때 거기 찍힌 것은
     이미 '거래처 표기' 라, 그걸 우리 이름으로 잘못 기억하면 다른 거래처로 바꿀 때 옛 거래처 이름이 남는다. */
var _ourNmMap = null;
function saOurNm(cd){
  if(!cd) return '';
  var n0 = (_prods||[]).length;
  if(!_ourNmMap || _ourNmMap.__n !== n0){       // 마스터가 늦게 도착하므로 건수가 바뀌면 다시 만든다
    _ourNmMap = { __n: n0 };
    (_prods||[]).forEach(function(p){ if(p.prodCd) _ourNmMap[p.prodCd] = p.prodNm; });
  }
  return _ourNmMap[cd] || '';
}
/* apply=false 로 부르면 표기표만 받아 두고 담긴 행은 건드리지 않는다.
   ★저장된 전표를 불러올 때가 그 경우다 — 그때 찍힌 이름이 그 전표의 사실이므로,
     지금 매핑이 바뀌었다고 과거 전표의 품명을 조용히 갈아치우면 안 된다. */
function saXrefLoad(cd, apply){
  if(apply === undefined) apply = true;
  _xrefNm = {};
  if(!cd){ if(apply) saXrefApply(); return; }
  post('/prod/xrefNames.do','vendorCd='+encodeURIComponent(cd))
    .then(function(r){return r.json();})
    .then(function(j){
      ((j&&j.data)||[]).forEach(function(x){ if(x.prodCd && x.extItemNm) _xrefNm[x.prodCd]=x.extItemNm; });
      if(apply) saXrefApply();
    })
    .catch(function(){ if(apply) saXrefApply(); });   // 실패해도 우리 품명으로 그냥 간다
}
/* 그 거래처 표기로 품명을 맞춘다(표기 없으면 우리 품명으로 되돌린다) */
function saXrefApply(){
  var changed = false;
  _rows.forEach(function(o){
    if(!o.prodCd) return;
    var want = _xrefNm[o.prodCd] || saOurNm(o.prodCd) || o.prodNm;
    if(want && want !== o.prodNm){ o.prodNm = want; changed = true; }
  });
  if(changed) saRender();
}
/* 품목을 담을 때 쓸 이름 — 그 거래처 표기 우선 */
function saNmFor(prodCd, ourNm){
  return (prodCd && _xrefNm[prodCd]) ? _xrefNm[prodCd] : ourNm;
}
/* 현잔고 = 그 거래처의 미수 누계 = 매출 − DC − 수금 − 할인.
   수금등록(rcvReg)과 같은 쿼리·같은 식이라 두 화면 잔고가 어긋나지 않는다.
   여기 매출에는 정산서(TBL_SALES_MST)와 판매전표가 함께 들어간다. */
function saVenBal(cd){
  if(!cd){ document.getElementById('saBalNow').textContent='0'; saCalc(); saLedger(''); return; }
  /* ★원장 조회 한 번으로 현잔고까지 계산한다(2026-08-04 "깜박거림") —
       종전엔 같은 custLedger.do 를 잔고용·원장용으로 <두 번> 불러 화면이 두 번 출렁였다.
       잔고 = 원장 마지막 누계와 같은 식이라 saLedger 안에서 함께 채운다. */
  saLedger(cd);
}

/* ── 거래처 원장(분개장) ──────────────────────────────
     서버는 일자별 매출·DC·수금·할인만 준다. 잔고 누계와 [월 계]·[합 계] 는 여기서 만든다
     (원본 화면과 같은 형태 — 월이 바뀌는 자리에 월계 줄을 끼워 넣는다). */
/* ★ 원장을 그린 거래처를 따로 들고 있는다 (2026-07-31).
     저장 후 saNew() 는 상단 거래처를 비우지만 원장은 그대로 남는다. 그 상태에서
     원장 일자를 눌렀을 때 상단 거래처(빈 값)를 보면 아무 일도 안 일어난 것처럼 죽는다.
     원장에 보이는 것이 곧 이 거래처이므로, 일자 클릭은 이 값을 기준으로 삼는다. */
var _lgCd = '', _lgSeq = 0;
function saLedger(cd){
  _lgCd = cd || '';
  var tb = document.getElementById('lgBody'), wrap = document.getElementById('lgWrap');
  var seq = ++_lgSeq;                     /* 행을 연달아 눌러도 <마지막 요청>만 화면에 남는다 */
  document.getElementById('lgVen').textContent = cd ? (document.getElementById('saVenNm').value||cd) : '—';
  if(!cd){ tb.innerHTML='<tr><td colspan="6" class="sa-msg">거래처를 선택하세요.</td></tr>'; document.getElementById('lgFoot').innerHTML=''; return; }
  /* ★깜박임 방지(2026-08-04) — 표를 지우지 않는다. 종전엔 '불러오는 중…' 으로 비웠다가
       다시 그려서 행을 누를 때마다 원장이 하얗게 번쩍였다. 기존 내용을 살짝 흐리게만 두고
       새 자료가 오면 통째로 갈아끼운다. */
  wrap.style.transition = 'opacity .15s'; wrap.style.opacity = '.55';
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    if (seq !== _lgSeq) return;           /* 더 새 요청이 이미 나갔다 — 이 응답은 버린다 */
    wrap.style.opacity = '';
    var l = (j&&j.data)||[];
    if(!l.length){
      tb.innerHTML='<tr><td colspan="6" class="sa-msg">거래 내역이 없습니다.</td></tr>';
      document.getElementById('lgFoot').innerHTML='';
      document.getElementById('saBalNow').textContent='0'; saCalc();
      return;
    }
    var h='', bal=0, mm=null, m={p:0,d:0,y:0,c:0}, t={p:0,d:0,y:0,c:0};
    function monthRow(){
      if(mm===null) return '';
      return '<tr style="background:#e8f6ec"><td>[월 계]</td><td class="num">'+fmt(m.p)+'</td><td class="num">'+fmt(m.d)
           + '</td><td class="num">'+fmt(m.y)+'</td><td class="num">'+fmt(m.c)+'</td><td></td></tr>';
    }
    l.forEach(function(o){
      var dt = String(o.dt||''), ym = dt.slice(0,6);
      var p=n(o.saleAmt), d=n(o.dcAmt), y=n(o.rcvAmt), c=n(o.discAmt);
      if(mm!==null && ym!==mm){ h+=monthRow(); m={p:0,d:0,y:0,c:0}; }
      mm = ym;
      bal += p - d - y - c;
      m.p+=p; m.d+=d; m.y+=y; m.c+=c;
      t.p+=p; t.d+=d; t.y+=y; t.c+=c;
      /* 일자 줄 클릭 → 그 날 매출품목 팝업(2026-07-31). [월 계]·[합 계] 줄은 클릭 대상이 아니다 */
      h += '<tr onclick="saDayOpen(\''+dt+'\')" title="클릭 → 이 날 매출품목 보기">'
         + '<td>'+esc(fmtDt(dt))+'</td><td class="num">'+fmt(p)+'</td><td class="num">'+fmt(d)
         + '</td><td class="num">'+fmt(y)+'</td><td class="num">'+fmt(c)+'</td><td class="num"><b>'+fmt(bal)+'</b></td></tr>';
    });
    h += monthRow();
    tb.innerHTML = h;
    /* 합계는 스크롤 영역 밖에 — 아무리 내려도 항상 보인다 */
    document.getElementById('lgFoot').innerHTML =
      '<tr><td>합 계</td><td>'+fmt(t.p)+'</td><td>'+fmt(t.d)+'</td><td>'+fmt(t.y)+'</td><td>'+fmt(t.c)+'</td><td>'+fmt(bal)+'</td></tr>';
    /* 현잔고 = 원장 마지막 누계 — 같은 응답으로 함께 채운다(별도 조회 없음) */
    document.getElementById('saBalNow').textContent = fmt(bal); saCalc();
  }).catch(function(e){
    if (seq !== _lgSeq) return;
    wrap.style.opacity = '';
    tb.innerHTML='<tr><td colspan="6" class="sa-msg" style="color:#c0392b">원장 조회 오류</td></tr>';
  });
}

/* 열 때마다 기준자료를 다시 읽는다 — 방금 등록한 상품·매칭코드가 바로 보여야 한다(재로그인 없이).
   먼저 들고 있던 목록으로 즉시 그리고, 새 목록이 도착하면 saProdRefreshed 가 다시 그린다(기다리게 하지 않는다). */
function saProdOpen(i){
  _prodTargetRow=i;
  document.getElementById('saProdPop').classList.add('on');
  var q=document.getElementById('saProdQ'); q.value='';
  _ppPick = [];                          // 다중선택은 열 때마다 새로 시작
  saProdRender();
  saLoadMasters();
  /* 열리면 바로 검색칸에 커서 — 마우스로 칸을 다시 누를 필요 없이 즉시 친다(2026-08-05 요청, 매입등록과 동일) */
  setTimeout(function(){ q.focus(); }, 0);
}
function saProdClose(){ document.getElementById('saProdPop').classList.remove('on'); }
function saProdRender(){
  var q = (document.getElementById('saProdQ').value||'').toLowerCase();
  /* ★검색은 매칭코드까지 훑는다 (2026-08-01) — 주문서에 적힌 '거래처 코드·거래처 품명' 으로 쳐도
       우리 상품이 나와야 한다. 그 코드로 걸린 상품코드 집합을 먼저 만들어 아래 필터에서 함께 본다. */
  var byExt={};
  if(q) _extItems.forEach(function(e){
    if(!e.prodCd) return;
    if([e.extItemCd,e.extItemNm,e.extSpec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; }))
      byExt[String(e.prodCd)]=1;
  });
  /* 코드로 검색하면 장부 넘겨 보듯 — 걸린 상품(우리 코드·매칭코드, 코드순)을 앞에 두고, 그 뒤에
     **찾은 코드 다음 코드의 상품들을 이어서** 보여 준다(2026-08-05 요청·매입등록과 동일 —
     걸린 것만 나오면 이웃 상품을 못 고른다). 걸린 상품은 코드를 굵은 초록으로 구분. 이름·규격 매치는 맨 뒤. */
  var l, hit = {};
  if(!q){ l = _prods.slice(0,200); }
  else{
    var byCd=[], byNm=[];
    _prods.forEach(function(o){
      if(String(o.prodCd||'').toLowerCase().indexOf(q)>=0 || byExt[String(o.prodCd)]) byCd.push(o);
      else if([o.prodNm,o.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) byNm.push(o);
    });
    var byCode = function(a,b){ return String(a.prodCd||'').localeCompare(String(b.prodCd||'')); };
    byCd.sort(byCode);
    if(byCd.length){
      byCd.forEach(function(o){ hit[String(o.prodCd)]=1; });
      var first = String(byCd[0].prodCd||'');
      var after = _prods.filter(function(o){ return !hit[String(o.prodCd)] && String(o.prodCd||'') > first; }).sort(byCode);
      l = byCd.concat(after).concat(byNm).slice(0,200);
    }else l = byNm.slice(0,200);
  }
  document.getElementById('saProdBody').innerHTML = l.length ? l.map(function(o){
    /* ★한 상품에 매칭코드가 여럿일 수 있다 — 전부 보여 주고 **무엇으로 넣을지 골라 누르게** 한다(2026-08-01).
         · 줄(상품코드·상품명) 클릭 = 우리 원코드·우리 품명으로 넣기
         · 🔖 줄 클릭            = 그 거래처 코드·그 품명으로 넣기(주문서에 적힌 대로)
       종전에는 매칭 하나만 골라 보여 주고 자동으로 그 품명을 썼다 — 어느 것으로 들어갔는지 알 수 없었다. */
    var exl=saExtListFor(o.prodCd);
    /* ✔칸 — 체크하면 순번(1,2,3…)이 찍히고 그 순서대로 담긴다. 체크박스 클릭이 줄 클릭(한 건 담기)으로
       번지지 않게 td 에서 끊는다(매입등록과 동일). */
    var k = _ppPick.indexOf(String(o.prodCd));
    /* 원코드 줄 — 누르면 우리 코드·우리 품명으로 넣는다 */
    var h='<tr class="pick" onclick="saProdPick(\''+esc(o.prodCd)+'\')" title="이 줄을 누르면 우리 원코드로 넣습니다">'
         + '<td style="cursor:pointer" onclick="event.stopPropagation();saProdToggle(\''+esc(o.prodCd)+'\')">'
         +   (k>=0 ? '<b style="color:#137a6c">'+(k+1)+'</b>' : '<input type="checkbox" style="pointer-events:none">')
         + '</td>'
         + '<td>'+(hit[String(o.prodCd)] ? '<b style="color:#137a6c">'+esc(o.prodCd)+'</b>' : esc(o.prodCd))+'</td>'
         + '<td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
         + '<td>'+esc(o.spec)+'</td><td class="num">'+n(o.packQty)+'</td><td class="num">'+fmt(o.salePrice)+'</td></tr>';
    /* 매칭코드 줄 — ★같은 칸(코드는 코드 칸, 품명은 품명 칸)에 맞춰 별도 줄로 둔다(2026-08-01 지적).
       품명 칸에 코드까지 몰아넣으니 어느 것이 코드인지 읽히지 않았다.
       🔖 줄도 ✔ 체크로 다중선택된다(2026-08-06 요청) — 담기면 그 거래처 코드·품명으로 들어간다. */
    h += exl.map(function(e){
      var ek = _ppPick.indexOf('ext:'+String(e.extSeq));
      return '<tr class="pick sa-exrow" onclick="saExtPick('+e.extSeq+')"'
        + ' title="이 거래처 코드·품명으로 넣습니다'+(e.vendorNm?(' — '+esc(e.vendorNm)):'')+'">'
        + '<td style="cursor:pointer" onclick="event.stopPropagation();saExtToggle('+e.extSeq+')">'
        +   (ek>=0 ? '<b style="color:#137a6c">'+(ek+1)+'</b>' : '<input type="checkbox" style="pointer-events:none">')
        + '</td>'
        + '<td>🔖 '+esc(e.extItemCd)+'</td>'
        + '<td class="txt" style="text-align:left">'+esc(e.extItemNm||'')
        +   (e.vendorNm?(' <span style="color:#8a97a3">('+esc(e.vendorNm)+')</span>'):'')+'</td>'
        + '<td>'+esc(e.extSpec||'')+'</td><td class="num"></td>'
        + '<td class="num">'+(e.extPrice!=null?fmt(e.extPrice):'')+'</td></tr>';
    }).join('');
    return h;
  }).join('') : '<tr><td colspan="6" class="sa-msg">검색 결과가 없습니다.</td></tr>';
  saPickInfo();
  saExtRender(q);
}
/* ── 상품 다중선택 담기 (2026-08-06 요청, 매입등록과 동일) ─────────────────
     ✔를 체크한 순서대로 명세에 한꺼번에 담는다. 담긴 줄의 BOX수량은 기본 1 —
     이 화면 규칙(BOX 치면 EA 가 친 대로 따라온다, saSet 참고)대로 EA수량도 1 로 채운다.
     줄 클릭(한 건 즉시 담기)·🔖 매칭코드 줄은 종전 그대로다. */
var _ppPick = [];   // 원코드는 상품코드 그대로, 🔖 매칭코드 줄은 'ext:extSeq' 로 섞여 들어간다(체크 순서 유지)
function saProdToggle(cd){
  cd = String(cd);
  var k = _ppPick.indexOf(cd);
  if (k >= 0) _ppPick.splice(k,1); else _ppPick.push(cd);   // 뺀 자리는 뒤 번호가 당겨진다
  saProdRender();
}
function saExtToggle(seq){
  var tk = 'ext:'+String(seq);
  var k = _ppPick.indexOf(tk);
  if (k >= 0) _ppPick.splice(k,1); else _ppPick.push(tk);
  saProdRender();
}
function saPickInfo(){
  var el = document.getElementById('saPickInfo');
  if (el) el.textContent = _ppPick.length ? ('선택 '+_ppPick.length+'건 — 체크한 순서대로 담깁니다 (BOX수량 1)') : '';
}
function saProdMultiApply(){
  if (!_ppPick.length) { swErr('담을 상품을 체크하세요.<br><span style="font-size:12.5px;color:#3d4d5c">한 건만 담을 때는 줄을 바로 클릭하면 됩니다.</span>'); return; }
  var ven = document.getElementById('saVenNm').dataset.cd || '';
  var rows = _rows.filter(function(o){ return o.prodCd; });
  var added = [], dup = [];
  _ppPick.forEach(function(tk){
    /* 🔖 매칭코드 줄('ext:extSeq')이면 연결된 우리 상품을 찾아 그 거래처 코드·품명으로 담는다(saExtPick 과 같은 규칙) */
    var ext = null, cd = String(tk);
    if (cd.indexOf('ext:') === 0){
      ext = _extItems.filter(function(x){ return String(x.extSeq)===cd.slice(4); })[0];
      if (!ext || !ext.prodCd) return;
      cd = String(ext.prodCd);
    }
    var p = _prods.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!p) return;
    if (rows.some(function(o){ return String(o.prodCd)===String(cd); })) { dup.push(ext?ext.extItemCd:cd); return; }
    var o = emptyRow();
    o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=saNmFor(p.prodCd, p.prodNm); o.spec=p.spec||'';
    o.extCd=null; o.extNm=null;                   // 원코드 기본 — 매칭 체크면 바로 아래에서 덮는다
    if (ext){ o.extCd=ext.extItemCd; o.extNm=ext.extItemNm||''; if(ext.extItemNm) o.prodNm=ext.extItemNm; }
    o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
    o.unitPrice=n(p.salePrice);
    o.boxQty=1; o.eaQty=1;                        // BOX수량 기본 1 → EA 1 (2026-08-06 요청)
    saCalcRow(o);
    rows.push(o); added.push(o);
  });
  rows.push(emptyRow());
  _rows = rows; _pShown = _rows.length;
  saRender(); saProdClose();
  /* 그 거래처의 최근 판매단가가 있으면 그 값으로 덮는다 — 한 건 담기(saProdPick)와 같은 규칙 */
  added.forEach(function(o){
    post('/mangr/salesLastPrice.do','prodCd='+encodeURIComponent(o.prodCd)+'&remark='+encodeURIComponent(ven))
      .then(function(r){return r.json();}).then(function(j){ if(j&&j.data){ o.unitPrice=n(j.data); saCalcRow(o); saRender(); } })
      .catch(function(){});
  });
  if (dup.length) swAlert(added.length+'건을 담았습니다.<br><span style="font-size:12.5px;color:#3d4d5c">이미 명세에 있는 '+dup.length+'건은 건너뛰었습니다 — '+esc(dup.join(', '))+'</span>');
}
/* 거래처 통보품목으로 찾기 (2026-08-01 통화 확정)
     · 원 상품코드를 골라 둔 통보분 → 누르면 그 우리 상품이 그대로 잡힌다(품명은 거래처 통보명으로).
     · 안 골라 둔 것(미연결) → 누르면 알려만 준다. 임의로 다른 상품에 붙이지 않는다.
   현재 거래처의 통보분을 위로 올린다(거래처를 안 가린 공통 통보도 함께). */
/* 우리 상품코드 → 그 거래처가 부르는 코드(매칭코드) 하나 찾기.
   같은 상품에 코드가 여럿이면 ① 지금 고른 거래처 것 ② 거래처를 안 가린 것(신규코드) 순으로 고른다. */
function saExtCdFor(prodCd){
  var l=saExtListFor(prodCd); return l.length?l[0]:null;
}
/* 그 상품에 붙어 있는 매칭코드 전부 — 지금 고른 거래처 것을 앞에, 거래처를 안 가린 것(신규코드)을 뒤에 */
function saExtListFor(prodCd){
  if(!prodCd || !_extItems.length) return [];
  var ven=document.getElementById('saVenNm').dataset.cd||'';
  var l=_extItems.filter(function(o){ return String(o.prodCd||'')===String(prodCd); });
  l.sort(function(a,b){
    var av=(ven&&a.vendorCd===ven)?0:(a.vendorCd?2:1), bv=(ven&&b.vendorCd===ven)?0:(b.vendorCd?2:1);
    return av-bv;
  });
  return l;
}
function saExtRender(q){
  var wrap=document.getElementById('saExtWrap'), body=document.getElementById('saExtBody');
  if(!wrap||!body) return;
  if(!_extItems.length){ wrap.style.display='none'; body.innerHTML=''; return; }
  var ven=document.getElementById('saVenNm').dataset.cd||'';
  /* 검색어가 없어도 '지금 고른 거래처의 매칭코드'는 먼저 펼쳐 둔다(2026-08-01) —
     수동 판매는 주문서의 거래처 코드로 찾는 일이 잦아, 매번 쳐야 하면 이 목록이 없는 것과 같다. */
  var l;
  if(q){
    l=_extItems.filter(function(o){
      return [o.extItemCd,o.extItemNm,o.extSpec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
    });
  }else{
    if(!ven){ wrap.style.display='none'; body.innerHTML=''; return; }   // 거래처도 검색어도 없으면 접어 둔다
    l=_extItems.filter(function(o){ return o.vendorCd===ven; });
  }
  if(ven) l.sort(function(a,b){ return ((b.vendorCd===ven)?1:0)-((a.vendorCd===ven)?1:0); });
  l=l.slice(0,30);
  if(!l.length){ wrap.style.display='none'; body.innerHTML=''; return; }
  body.innerHTML=l.map(function(o){
    var linked=!!o.prodCd;
    return '<tr class="pick" onclick="saExtPick('+o.extSeq+')">'
      + '<td>'+esc(o.extItemCd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.extItemNm||'')
      +   (o.vendorNm?(' <span style="color:#9aa7b3;font-size:11.5px">'+esc(o.vendorNm)+'</span>'):'')+'</td>'
      + '<td>'+esc(o.extSpec||'')+'</td>'
      + '<td>'+(linked ? ('<b style="color:#137a6c">'+esc(o.prodCd)+'</b>')
                       : '<span style="color:#c0392b;font-weight:700">미연결</span>')+'</td></tr>';
  }).join('');
  wrap.style.display='';
}
function saExtPick(seq){
  var o=null; for(var i=0;i<_extItems.length;i++){ if(String(_extItems[i].extSeq)===String(seq)){ o=_extItems[i]; break; } }
  if(!o) return;
  if(!o.prodCd){
    swAlert('<b>'+esc(o.extItemCd)+'</b> 은 아직 우리 상품과 <b>연결되지 않았습니다</b>.<br>'
      + '기준정보 ▸ <b>상품코드등록</b> 화면에서 상품을 고른 뒤 하단 <b>거래처 매칭코드</b> 에 등록해 주세요.<br>'
      + '<span style="color:#5a6b7a;font-size:12.5px">연결 전에는 아래 목록에서 상품을 직접 고르셔도 됩니다.</span>');
    return;
  }
  saProdPick(o.prodCd);
  /* 매칭으로 고른 것 — 코드·품명을 그 표기로 바꿔 두고, 어느 매칭으로 넣었는지 행에 남긴다.
     (saProdPick 이 extCd 를 지우므로 반드시 그 뒤에) */
  var r=_rows[_prodTargetRow];
  if(r){ r.extCd=o.extItemCd; r.extNm=o.extItemNm||''; if(o.extItemNm) r.prodNm=o.extItemNm; saRender(); }
}
function saProdPick(cd){
  var p = _prods.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!p) return;
  var o = _rows[_prodTargetRow]; if(!o) return;
  /* 품명 = 그 거래처가 요청한 이름(있으면). 없으면 우리 품명 그대로 */
  o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=saNmFor(p.prodCd, p.prodNm); o.spec=p.spec||'';
  /* ★매칭 품명을 여기서 자동으로 씌우지 않는다 (2026-08-01) — 매칭으로 넣으려면 팝업에서 🔖 줄을 고른다.
       자동으로 바꾸면 '원코드로 넣었는지 매칭으로 넣었는지' 를 화면에서 구별할 수 없다.
       원코드로 고르면 이 행의 매칭 표시(extCd)도 지운다. */
  o.extCd=null; o.extNm=null;
  o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
  o.unitPrice=n(p.salePrice);   // 기본값 = 상품마스터 판매가 (매입 화면은 inPrice 를 쓴다)
  /* 수량이 빈 줄이면 BOX수량 기본 1 → EA 1 (2026-08-06 요청 — 🔖 매칭코드·인라인 검색 담기 포함).
     이미 수량이 있는 줄(다른 상품으로 바꾸기)은 건드리지 않는다. */
  if (!n(o.boxQty) && !n(o.eaQty)) { o.boxQty = 1; o.eaQty = 1; }
  saProdClose();
  // 그 거래처의 최근 판매단가가 있으면 그 값으로 덮는다
  var ven = document.getElementById('saVenNm').dataset.cd||'';
  post('/mangr/salesLastPrice.do','prodCd='+encodeURIComponent(p.prodCd)+'&remark='+encodeURIComponent(ven))
    .then(function(r){return r.json();}).then(function(j){ if(j&&j.data) o.unitPrice=n(j.data); })
    .catch(function(){}).then(function(){
      saCalcRow(o);
      if (_prodTargetRow === _rows.length-1) saEnsureTail();
      saRender();
    });
}

/* ── 일괄등록 (2026-08-06 — 매입등록(puBatch*)과 동일 구조, 판매 규칙으로 치환) ─────
     · 탭1 [상품코드]      : 상품마스터 코드순(이웃검색) — 담으면 BOX 1 → EA 1(판매 합계=EA 규칙).
     · 탭2 [최근 판매내역] : 원장(custLedger)에서 매출 있던 일자(최근 15일치) → selectCustDayDetail
       의 SALE·STRX 줄. 일자 머리줄 ✔=그 날 전체선택. 수량은 BOX=EA=|수량| 그대로(원장 불러오기와 동일).
     · 체크 순간의 판매일자(dt)로 담기고, [일괄저장]이 일자마다 전표 한 장씩 저장(팝업 유지). */
var _btTab = 1, _btDays = null;
var _btSel = [];
function btDtVal(){ return document.getElementById('btDt').value || today(); }
function btSelIdx1(cd){ var d=btDtVal(); for (var i=0;i<_btSel.length;i++){ var s=_btSel[i]; if (s.t===1 && !s.ext && String(s.cd)===String(cd) && s.dt===d) return i; } return -1; }
/* 🔖 매칭코드 줄로 체크한 항목 — 원코드 체크와 따로 센다 */
function btSelIdx1e(seq){ var d=btDtVal(); for (var i=0;i<_btSel.length;i++){ var s=_btSel[i]; if (s.t===1 && String(s.ext||'')===String(seq) && s.dt===d) return i; } return -1; }
function btSelIdx2(di,ii){ var d=btDtVal(); for (var i=0;i<_btSel.length;i++){ var s=_btSel[i]; if (s.t===2 && s.di===di && s.ii===ii && s.dt===d) return i; } return -1; }
function btOrderOf(k){ if (k<0) return 0; var d=_btSel[k].dt, c=0; for (var i=0;i<=k;i++){ if (_btSel[i].dt===d) c++; } return c; }

function saBatchOpen(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _btTab = 1; _btSel = []; _btDays = null;
  document.getElementById('btVen').textContent = document.getElementById('saVenNm').value || cd;
  document.getElementById('btDt').value = document.getElementById('saDt').value || today();
  document.getElementById('btQ').value = '';
  document.getElementById('saBatchPop').classList.add('on');
  saBatchTab(1);
  saBatchSelRender();
  saBatchDtHint();
}
function saBatchClose(){ document.getElementById('saBatchPop').classList.remove('on'); }
/* 판매일자를 바꾸면 그 날 이 거래처 판매전표가 이미 있는지 옆에 알려 준다(저장은 막지 않는다) */
var _btDtSeq = 0;
function saBatchDtHint(){
  var el = document.getElementById('btDtHint');
  var venNm = document.getElementById('saVenNm').value || '';
  var dt = document.getElementById('btDt').value;
  if (!el) return;
  el.textContent = '';
  if (!venNm || !dt) return;
  var seq = ++_btDtSeq;
  post('/mangr/salesTrxList.do','fromDt='+encodeURIComponent(dt)+'&toDt='+encodeURIComponent(dt)+'&findData='+encodeURIComponent(venNm))
    .then(function(r){return r.json();}).then(function(j){
      if (seq !== _btDtSeq) return;
      var ex = ((j&&j.data)||[]).filter(function(o){ return String(o.custNm||'')===venNm; });
      el.textContent = ex.length ? ('⚠ 이 일자에 전표 '+ex.length+'건 있음') : '';
    }).catch(function(){});
}
function saBatchTab(t){
  _btTab = t;
  document.getElementById('btTab1').classList.toggle('teal', t===1);
  document.getElementById('btTab2').classList.toggle('teal', t===2);
  if (t===2 && _btDays === null) { saBatchLoad2(); return; }
  saBatchRender();
}
/* 탭2 자료 — 원장에서 매출이 있던 일자를 최근 것부터 15일치 골라, 날짜별 매출 줄을 병렬로 읽는다 */
function saBatchLoad2(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  document.getElementById('btHead').innerHTML = '';
  document.getElementById('btBody').innerHTML = '<tr><td class="sa-msg">최근 판매내역을 불러오는 중…</td></tr>';
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var dts = [];
    ((j&&j.data)||[]).forEach(function(o){ if (n(o.saleAmt)) dts.push(String(o.dt||'')); });
    dts = dts.filter(function(d,i){ return d && dts.indexOf(d)===i; }).sort().reverse().slice(0,15);
    if (!dts.length) { _btDays = []; saBatchRender(); return; }
    return Promise.all(dts.map(function(dt){
      return post('/mangr/selectCustDayDetail.do','custCd='+encodeURIComponent(cd)+'&trxDt='+encodeURIComponent(dt))
        .then(function(r){return r.json();})
        /* 직접판매(판매전표 STRX)만 (2026-08-06 확정) — 정산서(SALE) 매출은 일자별 목록에서 제외 */
        .then(function(j2){ return { dt:dt, items:((j2&&j2.data)||[]).filter(function(o){ return o.gb==='STRX'; }) }; })
        .catch(function(){ return { dt:dt, items:[] }; });
    })).then(function(gs){ _btDays = gs.filter(function(g){ return g.items.length; }); saBatchRender(); });
  }).catch(function(){
    _btDays = [];
    document.getElementById('btBody').innerHTML = '<tr><td class="sa-msg" style="color:#c0392b">최근 판매내역 조회 오류</td></tr>';
  });
}
function saBatchRender(){ if (_btTab===1) saBatchRender1(); else saBatchRender2(); }
function saBatchRender1(){
  var q = (document.getElementById('btQ').value||'').toLowerCase();
  document.getElementById('btHead').innerHTML =
    '<tr><th style="width:44px" title="체크한 순서대로 담깁니다">✔</th><th style="width:110px">상품코드</th><th>상품명</th>'
    + '<th style="width:110px">규격</th><th style="width:60px">입수</th><th style="width:90px">판매가</th></tr>';
  /* 검색은 매입과 같은 장부식(걸린 코드 + 다음 코드 이웃) + 거래처 매칭코드로도 찾는다.
     🔖 매칭코드 줄도 체크 가능 — 담긴 줄에는 '주코드'가 보이고 매칭코드는 그 밑에 작게 붙는다(2026-08-06). */
  var byExt = {};
  if(q) _extItems.forEach(function(e){
    if(!e.prodCd) return;
    if([e.extItemCd,e.extItemNm,e.extSpec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; }))
      byExt[String(e.prodCd)]=1;
  });
  var byCode = function(a,b){ return String(a.prodCd||'').localeCompare(String(b.prodCd||'')); };
  var l, hit = {};
  if(!q){ l = _prods.slice().sort(byCode).slice(0,300); }
  else{
    var byCd=[], byNm=[];
    _prods.forEach(function(o){
      if(String(o.prodCd||'').toLowerCase().indexOf(q)>=0 || byExt[String(o.prodCd)]) byCd.push(o);
      else if([o.prodNm,o.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) byNm.push(o);
    });
    byCd.sort(byCode);
    if(byCd.length){
      byCd.forEach(function(o){ hit[String(o.prodCd)]=1; });
      var first = String(byCd[0].prodCd||'');
      var after = _prods.filter(function(o){ return !hit[String(o.prodCd)] && String(o.prodCd||'') > first; }).sort(byCode);
      l = byCd.concat(after).concat(byNm).slice(0,300);
    }else l = byNm.slice(0,300);
  }
  document.getElementById('btBody').innerHTML = l.length ? l.map(function(o){
    var k = btSelIdx1(o.prodCd);
    var cd = hit[String(o.prodCd)] ? '<b style="color:#137a6c">'+esc(o.prodCd)+'</b>' : esc(o.prodCd);
    var h = '<tr class="pick" onclick="saBatchTgl1(\''+esc(o.prodCd)+'\')">'
      + '<td>'+(k>=0 ? '<b style="color:#137a6c">'+btOrderOf(k)+'</b>' : '<input type="checkbox" style="pointer-events:none">')+'</td>'
      + '<td>'+cd+'</td><td class="txt" style="text-align:left;max-width:210px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="'+esc(o.prodNm)+'">'+esc(o.prodNm)+'</td>'
      + '<td>'+esc(o.spec)+'</td><td class="num">'+n(o.packQty)+'</td><td class="num">'+fmt(o.salePrice)+'</td></tr>';
    /* 🔖 매칭코드 줄 — 체크하면 담을 내용에 주코드 + 매칭코드(작게)로 표시된다 */
    h += saExtListFor(o.prodCd).map(function(e){
      var ek = btSelIdx1e(e.extSeq);
      return '<tr class="pick sa-exrow" onclick="saBatchTglE('+e.extSeq+',\''+esc(o.prodCd)+'\')"'
        + ' title="이 거래처 코드·품명으로 담깁니다'+(e.vendorNm?(' — '+esc(e.vendorNm)):'')+'">'
        + '<td>'+(ek>=0 ? '<b style="color:#137a6c">'+btOrderOf(ek)+'</b>' : '<input type="checkbox" style="pointer-events:none">')+'</td>'
        + '<td>🔖 '+esc(e.extItemCd)+'</td>'
        + '<td class="txt" style="text-align:left;max-width:210px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="'+esc(e.extItemNm||'')+'">'+esc(e.extItemNm||'')
        +   (e.vendorNm?(' <span style="color:#8a97a3">('+esc(e.vendorNm)+')</span>'):'')+'</td>'
        + '<td>'+esc(e.extSpec||'')+'</td><td class="num"></td>'
        + '<td class="num">'+(e.extPrice!=null?fmt(e.extPrice):'')+'</td></tr>';
    }).join('');
    return h;
  }).join('') : '<tr><td colspan="6" class="sa-msg">검색 결과가 없습니다.</td></tr>';
  saBatchInfo();
}
function saBatchRender2(){
  document.getElementById('btHead').innerHTML =
    '<tr><th style="width:44px">✔</th><th style="width:106px">상품코드</th><th>상품명</th>'
    + '<th style="width:66px">수량</th><th style="width:84px">단가</th><th style="width:96px">금액</th></tr>';
  if (_btDays === null) return;
  var q = (document.getElementById('btQ').value||'').toLowerCase();
  var h = '';
  _btDays.forEach(function(g, di){
    var idx = [];
    g.items.forEach(function(o, ii){
      if (!q || [o.itemCd,o.itemNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) idx.push(ii);
    });
    if (!idx.length) return;
    var all = idx.every(function(ii){ return btSelIdx2(di,ii) >= 0; });
    var sum = 0, dns = [];
    idx.forEach(function(ii){ sum += n(g.items[ii].amt);
      var dn = String(g.items[ii].docNo||''); if (dn && dns.indexOf(dn)<0) dns.push(dn); });
    h += '<tr style="background:#e8f6ec; cursor:pointer" onclick="saBatchDayAll('+di+','+(all?'false':'true')+')" title="클릭 → 이 날 전체선택/해제">'
      + '<td><input type="checkbox" style="pointer-events:none"'+(all?' checked':'')+'></td>'
      + '<td colspan="2" class="txt" style="text-align:left"><b>'+esc(fmtDt(g.dt))+'</b> — '+idx.length+'건'
      +   (dns.length ? ' <span style="color:#137a6c;font-weight:700">전표 '+esc(dns.join(', '))+'</span>' : '')
      +   ' <span style="color:#5a6b7a">(일자별 전체선택)</span></td>'
      + '<td></td><td></td><td class="num"><b>'+fmt(sum)+'</b></td></tr>';
    idx.forEach(function(ii){
      var o = g.items[ii], on = btSelIdx2(di,ii) >= 0;
      /* '매칭코드로 판매했는지'는 저장된 EXT_CD 로 판별 (2026-08-06 신설 — selectCustDayDetail 이 extCd 를 준다).
         원코드 판매·옛 전표(EXT_CD 없음)에는 안 붙는다. 표기는 본 명세 그리드와 동일: 주코드 위, 🔖 매칭코드 아래 */
      h += '<tr class="pick" onclick="saBatchTgl2('+di+','+ii+')">'
        + '<td><input type="checkbox" style="pointer-events:none"'+(on?' checked':'')+'></td>'
        + '<td>'+esc(o.itemCd)
        +   (o.extCd ? '<div style="font-size:11px;color:#274b8f;margin-top:1px;white-space:nowrap" title="매칭코드로 판매한 건입니다">🔖 '+esc(o.extCd)+'</div>' : '')
        + '</td>'
        + '<td class="txt" style="text-align:left;max-width:210px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="'+esc(o.itemNm)+'">'+esc(o.itemNm)+'</td>'
        + '<td class="num">'+fmt(o.qty)+'</td><td class="num">'+fmtP(o.price)+'</td><td class="num">'+fmt(o.amt)+'</td></tr>';
    });
  });
  document.getElementById('btBody').innerHTML = h || '<tr><td colspan="6" class="sa-msg">'
    + (q ? '검색 결과가 없습니다.' : '이 거래처의 최근 판매내역이 없습니다.') + '</td></tr>';
  saBatchInfo();
}
function saBatchTgl1(cd){
  var k = btSelIdx1(cd);
  if (k>=0) _btSel.splice(k,1); else _btSel.push({ t:1, cd:String(cd), dt:btDtVal() });
  saBatchRender1(); saBatchSelRender();
}
/* 🔖 매칭코드 줄 체크 — 주코드로 담기되 매칭 표기(extCd·품명)를 행에 남긴다 */
function saBatchTglE(seq, cd){
  var k = btSelIdx1e(seq);
  if (k>=0) _btSel.splice(k,1); else _btSel.push({ t:1, cd:String(cd), ext:String(seq), dt:btDtVal() });
  saBatchRender1(); saBatchSelRender();
}
function saBatchTgl2(di, ii){
  var k = btSelIdx2(di, ii);
  if (k>=0) _btSel.splice(k,1); else _btSel.push({ t:2, di:di, ii:ii, dt:btDtVal() });
  saBatchRender2(); saBatchSelRender();
}
function saBatchDayAll(di, on){
  var q = (document.getElementById('btQ').value||'').toLowerCase();
  var g = _btDays[di]; if(!g) return;
  g.items.forEach(function(o, ii){
    if (q && ![o.itemCd,o.itemNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) return;
    var k = btSelIdx2(di, ii);
    if (on) { if (k<0) _btSel.push({ t:2, di:di, ii:ii, dt:btDtVal() }); }
    else if (k>=0) _btSel.splice(k,1);
  });
  saBatchRender2(); saBatchSelRender();
}
function saBatchInfo(){
  document.getElementById('btCnt').textContent = _btSel.length ? ('담을 내용 '+_btSel.length+'건') : '';
}
/* 체크 하나 → 명세 행 하나 (미리보기·저장 공용) */
function saBatchRowFor(s){
  if (s.t===1){
    var p = _prods.filter(function(x){ return String(x.prodCd)===String(s.cd); })[0]; if(!p) return null;
    var o = emptyRow();
    o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=saNmFor(p.prodCd, p.prodNm); o.spec=p.spec||'';
    o.extCd=null; o.extNm=null;
    /* 🔖 매칭코드로 체크한 줄 — 주코드는 그대로, 매칭 코드·품명을 행에 남긴다(saExtPick 과 같은 규칙) */
    if (s.ext){
      var e = _extItems.filter(function(x){ return String(x.extSeq)===String(s.ext); })[0];
      if (e){ o.extCd=e.extItemCd; o.extNm=e.extItemNm||''; if(e.extItemNm) o.prodNm=e.extItemNm; }
    }
    o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
    o.unitPrice=n(p.salePrice);
    o.boxQty=1; o.eaQty=1;                            /* BOX 1 → EA 1 (판매 합계=EA 규칙) */
    saCalcRow(o);
    return btSelOverride(s, o);
  }
  var g = (_btDays||[])[s.di], it = g && g.items[s.ii]; if(!it) return null;
  var p2 = _prods.filter(function(x){ return String(x.prodCd)===String(it.itemCd); })[0] || {};
  var r = emptyRow();
  r.prodSeq = p2.prodSeq; r.prodCd = it.itemCd; r.prodNm = it.itemNm || p2.prodNm || '';
  r.spec = p2.spec || ''; r.packQty = n(p2.packQty)||1; r.taxGb = p2.taxGb || '과세';
  r.unitPrice = n(it.price);
  /* 매칭판매였던 줄은 저장된 EXT_CD 를 그대로 잇는다 — 미리보기·재저장에 🔖 유지 (2026-08-06) */
  if (it.extCd){ r.extCd = it.extCd; r.extNm = it.itemNm || ''; }
  /* 저장된 수량 그대로 — 입수로 쪼개지 않는다(원장 [불러오기]와 동일, 합계=EA 규칙) */
  var qv = n(it.qty), aq = Math.abs(qv);
  r.boxQty = aq; r.eaQty = aq;
  if (qv < 0) r.trxGb = '반품';
  saCalcRow(r);
  return btSelOverride(s, r);
}
/* 미리보기에서 고친 값(BOX·EA·단가)은 체크 항목(s)에 남겨 두었다가 매번 덮어씌운다.
   판매 규칙대로 BOX 를 고치면 EA 가 친 대로 따라온다(saSet 과 동일) — EA 를 따로 고치면 그 값 우선. */
function btSelOverride(s, o){
  if (s.boxQty != null) { o.boxQty = n(s.boxQty); o.eaQty = n(s.boxQty); }
  if (s.eaQty  != null) o.eaQty = n(s.eaQty);
  if (s.unitPrice != null) o.unitPrice = n(s.unitPrice);
  if (s.boxQty != null || s.eaQty != null || s.unitPrice != null) saCalcRow(o);
  return o;
}
function saBatchSelSet(i, k, v){
  var s = _btSel[i]; if(!s) return;
  s[k] = n(v);
  saBatchSelRender();
}
/* 좌측 '담을 내용' — 등록일자(dt)별 머리줄 + 일자마다 순번 1부터. BOX·EA·단가는 입력칸 */
function saBatchSelRender(){
  var tb = document.getElementById('btSelBody');
  if (!_btSel.length){
    tb.innerHTML = '<tr><td colspan="11" class="sa-msg">오른쪽 목록에서 체크하면 여기에 담깁니다. 일자를 바꿔 체크하면 일자별 전표로 나뉩니다.</td></tr>';
    saBatchInfo(); return;
  }
  var perDt = {};
  _btSel.forEach(function(s){ perDt[s.dt] = (perDt[s.dt]||0) + 1; });
  var inp = 'style="width:100%;border:0;background:transparent;font-size:13px;text-align:right;padding:2px"';
  var h = '', tot = 0, cnt = 0, num = 0, lastDt = null;
  _btSel.forEach(function(s, i){
    var o = saBatchRowFor(s); if(!o) return;
    if (s.dt !== lastDt){
      lastDt = s.dt; num = 0;
      h += '<tr style="background:#e8f6ec"><td colspan="10" class="txt" style="text-align:left"><b>📅 '+esc(s.dt)+'</b> 전표 — '+perDt[s.dt]+'건 <span style="color:#5a6b7a">— 이 일자로 저장됩니다</span></td>'
        + '<td><span style="color:#c0392b;cursor:pointer;font-weight:700;white-space:nowrap" title="'+esc(s.dt)+' 전표로 담은 줄 모두 빼기" onclick="saBatchDelDtOf(\''+esc(s.dt)+'\')">✖</span></td></tr>';
    }
    num++; cnt++; tot += n(o.totAmt) * (o.trxGb==='반품' ? -1 : 1);
    /* 매칭코드로 담은 줄 — 주코드를 보여주고 매칭코드는 그 밑에 작게(명세 그리드와 같은 표기, 2026-08-06 요청) */
    h += '<tr'+(o.trxGb==='반품' ? ' style="color:#c0392b"' : '')+'><td>'+num+'</td>'
      /* ▲▼ 순서 조정 — 코드 앞 (2026-08-06 요청). 같은 일자(전표) 안에서만 움직인다 */
      + '<td style="white-space:nowrap">'
      +   '<span style="cursor:pointer;color:#37475a" title="한 줄 위로" onclick="saBatchSelMove('+i+',-1)">▲</span>'
      +   '<span style="cursor:pointer;color:#37475a" title="한 줄 아래로" onclick="saBatchSelMove('+i+',1)">▼</span></td>'
      /* 상품코드 표기는 본 명세 그리드와 동일 (2026-08-06 확정) — 주코드 위, 매칭코드는 아래 작게 🔖 */
      + '<td>'+esc(o.prodCd)
      +   (o.extCd ? '<div style="font-size:11px;color:#274b8f;margin-top:1px;white-space:nowrap" title="거래처가 부르는 품목코드 (매칭코드)로 넣었습니다">🔖 '+esc(o.extCd)+'</div>' : '')
      + '</td><td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
      + '<td class="txt">'+ (o.packQty?('['+fmt(o.packQty)+']'):'') + esc(o.spec||'') +'</td>'
      + '<td><input inputmode="numeric" '+inp+' value="'+n(o.boxQty)+'" onchange="saBatchSelSet('+i+',\'boxQty\',this.value)"></td>'
      + '<td><input inputmode="numeric" '+inp+' value="'+n(o.eaQty)+'" onchange="saBatchSelSet('+i+',\'eaQty\',this.value)"></td>'
      + '<td class="num">'+fmt(o.qty)+'</td>'
      + '<td><input inputmode="decimal" '+inp+' value="'+fmtP(o.unitPrice)+'" onchange="saBatchSelSet('+i+',\'unitPrice\',this.value)"></td>'
      + '<td class="num">'+fmt(o.totAmt)+'</td>'
      + '<td><span style="color:#c0392b;cursor:pointer;font-weight:700" title="빼기" onclick="saBatchSelDel('+i+')">✖</span></td></tr>';
  });
  h += '<tr style="background:#137a6c;color:#fff;font-weight:800"><td colspan="9">■ 합계 '+cnt+'건 · 전표 '+Object.keys(perDt).length+'장</td><td class="num">'+fmt(tot)+'</td><td></td></tr>';
  tb.innerHTML = h;
  saBatchInfo();
}
function saBatchSelDel(i){
  _btSel.splice(i,1);
  saBatchRender(); saBatchSelRender();
}
/* ▲▼ 순서 조정 — 같은 일자(전표) 안에서만 옮긴다 */
function saBatchSelMove(i, d){
  var j = i + d;
  if (j < 0 || j >= _btSel.length) return;
  if (_btSel[i].dt !== _btSel[j].dt) return;
  var t = _btSel[i]; _btSel[i] = _btSel[j]; _btSel[j] = t;
  saBatchRender(); saBatchSelRender();
}
function saBatchDelDtOf(d){
  _btSel = _btSel.filter(function(s){ return s.dt!==d; });
  saBatchRender(); saBatchSelRender();
}
function saBatchDelAll(){
  if (!_btSel.length) { swAlert('담은 내용이 없습니다.'); return; }
  swConfirm('담을 내용 '+_btSel.length+'건을 모두 비울까요?', null, '전체 초기화').then(function(ok){
    if(!ok) return;
    _btSel = [];
    saBatchRender(); saBatchSelRender();
  });
}
/* [일괄저장] — 등록일자별로 전표 한 장씩 바로 저장. 팝업 유지, 명세 그리드는 건드리지 않는다 */
function saBatchApply(){
  var venCd = document.getElementById('saVenNm').dataset.cd || '';
  if (!venCd) { swErr('거래처를 먼저 선택하세요.'); return; }
  var venNm = document.getElementById('saVenNm').value || '';
  var entries = _btSel.map(function(s){ var r = saBatchRowFor(s); return r ? { s:s, row:r } : null; }).filter(Boolean);
  if (!entries.length) { swErr('담을 상품을 체크하세요.'); return; }
  var dts = [], byDt = {};
  entries.forEach(function(e){
    if (dts.indexOf(e.s.dt) < 0) dts.push(e.s.dt);
    (byDt[e.s.dt] = byDt[e.s.dt] || []).push(e);
  });
  /* [같은 일자 전표에 합치기]는 2026-08-06 사용자 요청으로 제거 — 항상 별도 전표로 추가한다.
     (같은 일괄저장 안의 같은 일자 체크분은 어차피 한 전표로 묶인다) */
  Promise.all(dts.map(function(d){
    return post('/mangr/salesTrxList.do','fromDt='+encodeURIComponent(d)+'&toDt='+encodeURIComponent(d)+'&findData='+encodeURIComponent(venNm))
      .then(function(r){return r.json();})
      .then(function(j){
        var ex = ((j&&j.data)||[]).filter(function(o){ return String(o.custNm||'')===venNm; });
        if (!ex.length) return '';
        var sum = 0; ex.forEach(function(o){ sum += n(o.totAmt); });
        return '<br><span style="font-size:13px;color:#c0392b">⚠ '+d+' 에 이미 전표 '+ex.length+'건 ('+fmt(sum)+'원) — 별도 전표로 추가됩니다.</span>';
      }).catch(function(){ return ''; });
  })).then(function(exArr){
    var brk = dts.map(function(d){ return d+' '+byDt[d].length+'건'; }).join(' · ');
    var msg = '총 '+entries.length+'건을 <b>일자별 전표 '+dts.length+'장</b>으로 바로 저장할까요?'
      + '<br><span style="font-size:13px;color:#3d4d5c">'+esc(brk)+'</span>' + exArr.join('');
    return swConfirm(msg, null, '일괄저장');
  }).then(function(ok){
    if(!ok) return;
    var jobs = [];
    entries.forEach(function(e){
      if (e.s.t !== 1) return;
      if (e.s.unitPrice != null) return;   /* 단가를 직접 고친 줄은 그 값 그대로 */
      jobs.push(post('/mangr/salesLastPrice.do','prodCd='+encodeURIComponent(e.row.prodCd)+'&remark='+encodeURIComponent(venCd))
        .then(function(r){return r.json();}).then(function(j){ if(j&&j.data){ e.row.unitPrice=n(j.data); saCalcRow(e.row); } })
        .catch(function(){}));
    });
    var made = [];                       /* 저장된 전표 [일자 · 번호] — 완료 알림에 보여 준다 */
    function saveOne(k){
      if (k >= dts.length) return Promise.resolve();
      var d = dts[k], grp = byDt[d].map(function(e){ return e.row; });
      return post('/mangr/salesTrxNextNo.do','saleDt='+encodeURIComponent(d))
        .then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||'0001'; })
        .catch(function(){ return '0001'; })
        .then(function(no){
          var t = {box:0, ea:0, qty:0, sup:0, vat:0, tot:0, svc:0};
          grp.forEach(function(o){
            var sg = (o.trxGb==='반품') ? -1 : 1;
            t.box+=n(o.boxQty)*sg; t.ea+=n(o.eaQty)*sg; t.qty+=n(o.qty)*sg;
            t.sup+=n(o.supplyAmt)*sg; t.vat+=n(o.vatAmt)*sg; t.tot+=n(o.totAmt)*sg; t.svc+=n(o.serviceQty);
          });
          var dto = {
            saleSeq:null, saleDt:d, dlvDt:d, saleNo:no,
            custCd:venCd, custNm:venNm,
            mgrCd: document.getElementById('saMgrNm').dataset.cd||'', mgrNm: document.getElementById('saMgrNm').value||'',
            whCd:'', whNm: document.getElementById('saWhNm').value||'물류창고',
            totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty,
            supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:0,
            payGb: document.getElementById('saPayGb').value||'외상', payAmt:0,
            taxGb:'과세', remark:'', items: grp
          };
          return post('/mangr/salesTrxSave.do', dto, true)
            .then(function(r){ return r.text().then(function(t2){ if(!r.ok) throw new Error(d+' — '+t2); made.push(d+' · 전표 '+no+' ('+grp.length+'건)'); }); });
        })
        .then(function(){ return saveOne(k+1); });
    }
    Promise.all(jobs).then(function(){ return saveOne(0); }).then(function(){
      swOk('일자별 전표 '+dts.length+'장, 총 '+entries.length+'건을 저장했습니다.'
        + '<br><span style="font-size:12.5px;color:#3d4d5c">'+made.join('<br>')+'</span>');
      _btSel = []; _btDays = null;
      if (_btTab === 2) saBatchLoad2(); else saBatchRender();
      saBatchSelRender(); saBatchDtHint();
      saLoad(); saVenBal(venCd);            /* 하단 목록·현잔고·원장 갱신 — 명세 그리드는 건드리지 않는다 */
    }).catch(function(e){
      swErr('저장 중 오류가 났습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)
        + '<br>이미 저장된 일자 전표는 하단 목록에서 확인하세요.</span>');
      saLoad();
    });
  });
}

/* 거래처 상품 판매 단가 이력 — 품명을 클릭하면 뜬다.
     상단(거래처·상품·바코드·단가)은 이미 받아둔 상품마스터에서 채우고,
     아래 이력만 서버에서 읽는다(그 거래처 × 그 상품, 최대 3년). */
var _hist = [];
function saHistOpen(i){
  var o=_rows[i]; if(!o||!o.prodCd) return;
  var ven = document.getElementById('saVenNm').dataset.cd||'';
  var p = _prods.filter(function(x){ return String(x.prodCd)===String(o.prodCd); })[0] || {};
  document.getElementById('hvVen').textContent   = document.getElementById('saVenNm').value || '(전체 거래처)';
  document.getElementById('hvNm').textContent    = o.prodNm || p.prodNm || '';
  document.getElementById('hvBc').textContent    = p.unitBarcode || '—';
  document.getElementById('hvBox').textContent   = p.boxBarcode || '—';
  document.getElementById('hvIn').textContent    = fmt(p.inPrice);
  document.getElementById('hvSale').textContent  = fmt(p.salePrice);
  document.getElementById('hvWhole').textContent = fmt(p.wholePrice);
  document.getElementById('hvEvtOnly').checked   = false;
  _hist = [];
  document.getElementById('saHistBody').innerHTML = '<tr><td colspan="10" class="sa-msg">불러오는 중…</td></tr>';
  document.getElementById('saHistPop').classList.add('on');
  post('/mangr/salesPriceHist.do','prodCd='+encodeURIComponent(o.prodCd)+'&remark='+encodeURIComponent(ven))
    .then(function(r){return r.json();}).then(function(j){ _hist=(j&&j.data)||[]; saHistRender(); })
    .catch(function(){ document.getElementById('saHistBody').innerHTML='<tr><td colspan="10" class="sa-msg">조회 오류</td></tr>'; });
}
function saHistRender(){
  var only = document.getElementById('hvEvtOnly').checked;
  var l = only ? _hist.filter(function(x){ return x.eventYn==='Y'; }) : _hist;
  document.getElementById('hvCnt').textContent = '[ 조회 건 수: '+l.length+'/'+_hist.length+' ]';
  document.getElementById('saHistBody').innerHTML = l.length ? l.map(function(x,k){
    return '<tr><td>'+(k+1)+'</td><td>'+esc(fmtDt(x.spec))+'</td><td class="txt" style="text-align:left">'+esc(x.prodNm)+'</td>'
         + '<td class="num">'+fmtP(x.unitPrice)+'</td><td class="num">'+n(x.boxQty)+'</td><td class="num">'+n(x.eaQty)+'</td>'
         + '<td class="num">'+n(x.qty)+'</td><td class="num">'+fmt(x.amt)+'</td>'
         + '<td>'+(x.eventYn==='Y'?'●':'')+'</td><td>'+(x.trxGb==='반품'?'●':'')+'</td></tr>';
  }).join('') : '<tr><td colspan="10" class="sa-msg">'+(only?'행사 판매 이력이 없습니다.':'이 상품의 판매 이력이 아직 없습니다.')+'</td></tr>';
}
function saHistClose(){ document.getElementById('saHistPop').classList.remove('on'); }

/* ── 납품분 (2026-07-31) ────────────────────────────────
     [납품분] = 그 거래처에 이미 나간 품목을 중복 없이 모은 목록(판매전표 + 정산서).
     상품마스터 전체에서 찾지 않고 '이 거래처가 늘 받는 것' 중에서 고른다.

     ★ 핵심은 '순서' — 거래처가 불러 준 순서대로 체크하면 그 순서 그대로 명세에 담긴다.
       체크 순서를 _dvPick(상품코드 배열)에 쌓고, 체크 칸에 1,2,3… 을 찍어 눈으로 확인한다.
       (체크박스를 다시 누르면 그 자리만 빠지고 뒤 번호가 당겨진다)
     ★ [납품분제외] = 앞으로 이 목록에 안 나오게 한다. 거래처별이고, 판매 이력은 손대지 않는다.
       되돌리려면 [제외이력보기] → [해제]. 서버는 TBL_SALES_DLV_EXCL 한 줄을 ACTION_YN 으로 뒤집는다. */
var _dlv = [];          // 서버에서 받은 납품분(또는 제외이력) 목록
var _dvPick = [];       // 체크한 상품코드 — ★배열 순서 = 담길 순서
var _dvExclMode = false;// true 면 제외이력 보기

function saDlvOpen(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _dvPick = []; _dvExclMode = false;
  document.getElementById('dvQ').value = '';
  document.getElementById('dvAll').checked = false;
  document.getElementById('saDlvPop').classList.add('on');
  saDlvLoad();
}
function saDlvClose(){ document.getElementById('saDlvPop').classList.remove('on'); }
function saDlvToggleExcl(){ _dvExclMode = !_dvExclMode; _dvPick = []; saDlvLoad(); }
function saDlvLoad(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  if (!cd) return;
  var yrs = document.getElementById('dvPeriod').value;
  var from = '';
  if (yrs) { var d = new Date(); d.setFullYear(d.getFullYear() - Number(yrs)); from = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
  var url = _dvExclMode ? '/mangr/salesDlvExclList.do' : '/mangr/salesDlvList.do';
  var body = 'custCd='+encodeURIComponent(cd)
           + '&fromDt='+encodeURIComponent(_dvExclMode ? '' : from)
           + '&srcFilter='+encodeURIComponent(_dvExclMode ? '' : document.getElementById('dvSrc').value);
  document.getElementById('dvBody').innerHTML = '<tr><td colspan="9" class="sa-msg">불러오는 중…</td></tr>';
  document.getElementById('dvExclBtn').textContent = _dvExclMode ? '↩ 납품분으로' : '📋 제외이력보기';
  document.getElementById('dvExclSave').textContent = _dvExclMode ? '↩ 제외해제' : '🚫 납품분제외';
  document.getElementById('dvOk').style.display = _dvExclMode ? 'none' : '';
  document.getElementById('dvPeriod').disabled = _dvExclMode;
  document.getElementById('dvSrc').disabled = _dvExclMode;
  post(url, body).then(function(r){return r.json();}).then(function(j){
    _dlv = (j&&j.data)||[]; saDlvRender();
  }).catch(function(e){
    document.getElementById('dvBody').innerHTML =
      '<tr><td colspan="9" class="sa-msg" style="color:#c0392b">조회 오류 — 납품분제외 표(TBL_SALES_DLV_EXCL)가 없으면 sql/sales_dlv_excl_ddl.sql 을 먼저 실행하세요.</td></tr>';
  });
}
function saDlvFiltered(){
  var q = (document.getElementById('dvQ').value||'').toLowerCase();
  return _dlv.filter(function(o){
    if(!q) return true;
    return [o.prodCd,o.prodNm,o.spec,o.makerNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  });
}
function saDlvRender(){
  var l = saDlvFiltered();
  document.getElementById('dvCnt').textContent = l.length + '건'
    + (l.length !== _dlv.length ? ' (전체 '+_dlv.length+'건 중)' : '');
  document.getElementById('dvBody').innerHTML = l.length ? l.map(function(o){
    var cd = String(o.prodCd||'');
    var k  = _dvPick.indexOf(cd);
    var st = n(o.curQty);
    return '<tr class="pick" onclick="saDlvPick(\''+esc(cd)+'\')">'
      + '<td>' + (k>=0
          ? '<b style="color:#137a6c">'+(k+1)+'</b>'
          : '<input type="checkbox" onclick="event.stopPropagation();saDlvPick(\''+esc(cd)+'\')">') + '</td>'
      + '<td>'+esc(cd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
      + '<td>'+esc(o.spec)+'</td><td>'+esc(o.makerNm)+'</td>'
      + '<td class="num">'+fmtP(o.unitPrice)+'</td>'
      + '<td class="num"'+(st<0?' style="color:#c0392b;font-weight:700"':'')+'>'+fmt(st)+'</td>'
      + '<td>'+esc(_dvExclMode ? String(o.regDttm||'').slice(0,10) : fmtDt(o.lastDt))+'</td>'
      + '<td>'+esc(_dvExclMode ? '제외' : (o.srcGb||''))+'</td></tr>';
  }).join('') : '<tr><td colspan="9" class="sa-msg">'
      + (_dvExclMode ? '제외해 둔 품목이 없습니다.' : '이 거래처에 나간 품목이 아직 없습니다.') + '</td></tr>';
  saDlvInfo();
}
function saDlvPick(cd){
  var k = _dvPick.indexOf(cd);
  if (k >= 0) _dvPick.splice(k,1); else _dvPick.push(cd);   // 뺀 자리는 뒤 번호가 당겨진다
  saDlvRender();
}
function saDlvAll(on){
  _dvPick = on ? saDlvFiltered().map(function(o){ return String(o.prodCd||''); }) : [];
  saDlvRender();
}
function saDlvInfo(){
  var el = document.getElementById('dvPickInfo');
  el.textContent = _dvPick.length ? ('선택 '+_dvPick.length+'건 — '+_dvPick.join(' → ')) : '';
}
/* [확인] — 체크한 순서대로 명세에 담는다.
     이미 입력된 줄 뒤에 붙이고, 화면에 있던 빈 줄은 걷어낸 뒤 맨 끝에 하나만 다시 둔다. */
function saDlvApply(){
  if (!_dvPick.length) { swErr('담을 품목을 체크하세요.'); return; }
  var rows = _rows.filter(function(o){ return o.prodCd; });
  var added = 0, dup = [];
  _dvPick.forEach(function(cd){
    var s = _dlv.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!s) return;
    if (rows.some(function(o){ return String(o.prodCd)===String(cd); })) { dup.push(cd); return; }
    var o = emptyRow();
    o.prodSeq  = s.prodSeq;  o.prodCd = s.prodCd; o.prodNm = saNmFor(s.prodCd, s.prodNm); o.spec = s.spec||'';
    o.packQty  = n(s.packQty)||1;
    o.taxGb    = s.taxGb || '과세';
    o.unitPrice= n(s.unitPrice);      // 그 거래처의 최근 거래단가
    saCalcRow(o);
    rows.push(o); added++;
  });
  rows.push(emptyRow());
  _rows = rows; _pShown = _rows.length;
  saRender();
  saDlvClose();
  if (dup.length) swAlert(added+'건을 담았습니다.<br><span style="font-size:12.5px;color:#3d4d5c">이미 명세에 있는 '+dup.length+'건은 건너뛰었습니다 — '+esc(dup.join(', '))+'</span>');
}
/* [납품분제외] / [제외해제] — 체크한 품목을 거래처별로 넣거나 뺀다 */
function saDlvExclSave(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  if (!_dvPick.length) { swErr('품목을 체크하세요.'); return; }
  var on = !_dvExclMode;   // 납품분 목록에서 누르면 제외, 제외이력에서 누르면 해제
  var msg = on
    ? '체크한 '+_dvPick.length+'건을 <b>납품분에서 제외</b>할까요?<br><span style="font-size:13px;color:#3d4d5c">'
      + document.getElementById('saVenNm').value + ' 거래처의 납품분 목록에만 안 나옵니다. 지난 판매 자료는 그대로입니다.</span>'
    : '체크한 '+_dvPick.length+'건의 <b>제외를 해제</b>할까요?<br><span style="font-size:13px;color:#3d4d5c">다시 납품분 목록에 나옵니다.</span>';
  swConfirm(msg, null, on?'제외':'해제').then(function(ok){
    if(!ok) return;
    var one = (_dvPick.length===1) ? (_dlv.filter(function(x){ return String(x.prodCd)===String(_dvPick[0]); })[0]||{}) : {};
    var body = 'custCd='+encodeURIComponent(cd)
             + '&actionYn='+(on?'Y':'N')
             + '&prodNm='+encodeURIComponent(one.prodNm||'')
             + '&prodCds='+encodeURIComponent(_dvPick.join(','));
    post('/mangr/salesDlvExclSave.do', body).then(function(r){
      return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; });
    }).then(function(){
      _dvPick = [];
      document.getElementById('dvAll').checked = false;
      saDlvLoad();
      swOk(on ? '납품분에서 제외했습니다.' : '제외를 해제했습니다.');
    }).catch(function(e){ swErr('처리에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
  });
}

/* ── 원장 일자 클릭 → 그 날 매출품목 (2026-07-31) ────────
     원장 금액과 같은 원천(selectCustDayDetail)에서 그 날 것만 읽어
     정산서 매출(SALE)과 판매전표(STRX)만 골라 보여준다. 매입·수금 줄은 여기 관심사가 아니다.
     [불러오기] 는 그 품목들을 '새 전표'로 올린다 — 그 날 전표를 여는 게 아니다.
     판매전표에서 온 줄이 섞여 있으면 그대로 저장할 때 매출이 두 번 잡히므로 미리 알린다. */
var _day = [], _dayDt = '';
function saDayOpen(dt){
  /* 기준은 '원장에 보이는 거래처'(_lgCd) — 상단이 비어 있어도(신규 전표) 원장은 살아 있다 */
  var cd = _lgCd || document.getElementById('saVenNm').dataset.cd || '';
  if (!dt) return;
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _dayDt = dt; _day = [];
  var nm = (_lgCd && _lgCd === (document.getElementById('saVenNm').dataset.cd||''))
             ? document.getElementById('saVenNm').value
             : (document.getElementById('lgVen').textContent||cd);
  document.getElementById('dyTitle').textContent = fmtDt(dt) + ' · ' + (nm||cd);
  document.getElementById('dyBody').innerHTML = '<tr><td colspan="7" class="sa-msg">불러오는 중…</td></tr>';
  document.getElementById('dySum').textContent = '0';
  document.getElementById('saDayPop').classList.add('on');
  post('/mangr/selectCustDayDetail.do','custCd='+encodeURIComponent(cd)+'&trxDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){
      _day = ((j&&j.data)||[]).filter(function(o){ return o.gb==='SALE' || o.gb==='STRX'; });
      saDayRender();
    }).catch(function(e){
      document.getElementById('dyBody').innerHTML = '<tr><td colspan="7" class="sa-msg" style="color:#c0392b">조회 오류</td></tr>';
    });
}
function saDayClose(){ document.getElementById('saDayPop').classList.remove('on'); }
function saDayRender(){
  var sum = 0;
  document.getElementById('dyBody').innerHTML = _day.length ? _day.map(function(o){
    sum += n(o.amt);
    return '<tr><td>'+esc(o.gbNm)+'</td><td>'+esc(o.docNo)+'</td><td>'+esc(o.itemCd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.itemNm)+'</td>'
      + '<td class="num">'+fmt(o.qty)+'</td><td class="num">'+fmt(o.price)+'</td><td class="num">'+fmt(o.amt)+'</td></tr>';
  }).join('') : '<tr><td colspan="7" class="sa-msg">이 날 매출품목이 없습니다.</td></tr>';
  document.getElementById('dySum').textContent = fmt(sum);
}
function saDayApply(){
  if (!_day.length) { swErr('불러올 품목이 없습니다.'); return; }
  var hasTrx = _day.some(function(o){ return o.gb==='STRX'; });
  var msg = fmtDt(_dayDt)+' 매출품목 '+_day.length+'건을 <b>새 전표</b>로 올릴까요?'
    + (hasTrx ? '<br><span style="font-size:13px;color:#c0392b">이 날 이미 저장된 판매전표가 섞여 있습니다. 그대로 저장하면 매출이 한 번 더 잡힙니다.</span>' : '')
    + '<br><span style="font-size:13px;color:#3d4d5c">지금 입력 중인 명세는 지워집니다.</span>';
  swConfirm(msg, null, '불러오기').then(function(ok){
    if(!ok) return;
    /* 거래처는 원장 기준(_lgCd). 상단이 비어 있거나 다른 거래처면 거래처마스터에서 채워 넣는다 */
    var cur = document.getElementById('saVenNm').dataset.cd||'';
    var ven;
    if (_lgCd && _lgCd !== cur) {
      var v0 = _vendors.filter(function(x){ return String(x.vendorCd)===String(_lgCd); })[0] || {};
      ven = { cd:_lgCd, nm: v0.vendorNm || document.getElementById('lgVen').textContent || _lgCd,
              mgrCd: v0.mgrCd||'', mgrNm: v0.mgrNm||'' };
    } else {
      ven = { cd: cur, nm: document.getElementById('saVenNm').value||'',
              mgrCd: document.getElementById('saMgrNm').dataset.cd||'', mgrNm: document.getElementById('saMgrNm').value||'' };
    }
    saNew();                                   // 새 전표로 시작(수정 중이던 전표는 놓아준다)
    var v = document.getElementById('saVenNm'); v.value = ven.nm; v.dataset.cd = ven.cd;
    var m = document.getElementById('saMgrNm'); m.value = ven.mgrNm; m.dataset.cd = ven.mgrCd;
    document.getElementById('saDt').value = fmtDt(_dayDt);
    var rows = [];
    _day.forEach(function(o){
      var p = _prods.filter(function(x){ return String(x.prodCd)===String(o.itemCd); })[0] || {};
      var r = emptyRow();
      r.prodSeq = p.prodSeq; r.prodCd = o.itemCd; r.prodNm = o.itemNm || p.prodNm || '';
      r.spec = p.spec || ''; r.packQty = n(p.packQty)||1; r.taxGb = p.taxGb || '과세';
      r.unitPrice = n(o.price);
      /* 저장된 수량을 그대로 되돌린다 — 입수로 쪼개지 않는다(합계 = EA 규칙과 같은 모양). */
      var q = n(o.qty), aq = Math.abs(q);
      r.boxQty = aq; r.eaQty = aq;
      if (q < 0) r.trxGb = '반품';
      saCalcRow(r);
      rows.push(r);
    });
    rows.push(emptyRow());
    _rows = rows; _pShown = _rows.length;
    document.getElementById('saState').textContent = '원장에서 불러옴 — '+fmtDt(_dayDt)+' · 내용 확인 후 [저장]';
    saRender(); saNextNo(); saVenBal(ven.cd);
    saDayClose();
  });
}

/* ══════════════════════════════════════════════════════════════════════
   명세 그리드 키보드 입력 (2026-08-04) — 현장/영업 중 사장이 노트북으로 빠르게 친다.
     ① 빈 줄 '상품코드' 칸에 직접 쳐서 ↑↓·Enter 로 상품을 고른다(saPin*) — 팝업을 안 열어도 된다.
     ② 칸에서 Enter = 다음 칸, 줄 끝이면 다음 줄로. ↑↓ = 같은 칸으로 윗줄/아랫줄.
     ③ 진입하면 첫 상품칸에 커서. Ctrl+S = 저장, Alt+N = 신규.
   ★그리드는 값이 바뀔 때마다 통째로 다시 그린다(saRender). 그래서 커서가 튀지 않게
     '다시 그리기 전에 어느 칸에 있었는지'를 잡아 두었다가(saCaptureFocus) 다시 그린 뒤 되돌린다.
     다음 칸으로 옮길 때는 _focusNext 에 목표 칸을 적어 두면 saRestoreFocus 가 그쪽을 먼저 본다.
   기존 동작(최근단가 자동채움·부가세·반품·납품분·복사저장)은 그대로다 — 위에 얹기만 했다. */
var _focusNext = null;                     // 다음에 커서를 둘 칸 {r,f,sel} — saRender 가 소비하고 비운다

function saCaptureFocus(){
  var a = document.activeElement;
  if (!a || !a.dataset || a.dataset.r == null) return null;      // 그리드 입력칸이 아니면 신경쓰지 않는다
  if (!a.closest || !a.closest('#saBody')) return null;
  var s = null, e = null;
  try { s = a.selectionStart; e = a.selectionEnd; } catch(_){}    // 텍스트칸이면 캐럿 위치 보존
  return { r:a.dataset.r, f:a.dataset.f, s:s, e:e };
}
function saRestoreFocus(keep){
  var t = _focusNext; _focusNext = null;   // 이동 목표가 있으면 그쪽이 먼저
  if (t) { saFocusCell(t); return; }
  if (keep) saFocusCell(keep);             // 없으면 있던 칸 그대로(단순 재계산 재렌더)
}
function saFocusCell(t){
  if (!t) return false;
  var el = document.querySelector('#saBody [data-r="'+t.r+'"][data-f="'+t.f+'"]');
  if (!el && t.f === 'prod') el = document.querySelector('#saBody [data-r="'+t.r+'"][data-f="eaQty"]');
  if (!el) return false;                   // 그 줄이 아직 없거나(꼬리줄 대기) 페이징 밖이면 실패
  try {
    el.focus();
    if (t.sel === 'all' || t.s == null) { if (el.select) el.select(); }
    else el.setSelectionRange(t.s, t.e);
  } catch(_){}
  return true;
}
function saFocusFirstProd(){
  setTimeout(function(){
    var el = document.querySelector('#saBody input.saPin[data-f="prod"]');
    if (el) el.focus();
  }, 0);
}

/* 칸 사이 이동 — Enter 는 '상품 → EA수량 → 단가 → (다음 줄)'. 그 밖의 칸은 다음 줄로 넘어간다.
   중간 줄이면 다음 줄이 이미 차 있으니 그 줄 EA수량으로, 맨 끝 줄이면 새 빈 줄의 상품칸으로 간다. */
function saNextEnter(r, f){
  if (f === 'prod') return { r:r, f:'eaQty' };
  if (f === 'boxQty' || f === 'eaQty') return { r:r, f:'unitPrice' };
  var nr = r + 1;
  if (_rows[nr] && _rows[nr].prodCd) return { r:nr, f:'eaQty' };
  return { r:nr, f:'prod' };
}
/* #saBody 에 위임 — 숫자·비고 칸의 Enter/↑/↓. 상품 입력칸(saPin)은 자체 처리하므로 건너뛴다. */
function saGridKey(e){
  var t = e.target;
  if (!t || !t.dataset || t.dataset.r == null) return;
  if (t.classList && t.classList.contains('saPin')) return;
  var r = +t.dataset.r, f = t.dataset.f;
  if (e.key === 'Enter') {
    e.preventDefault();
    var nx = saNextEnter(r, f);
    _focusNext = nx ? { r:nx.r, f:nx.f, sel:'all' } : null;
    t.blur();                              // 값 확정(onchange→saSet→saRender→_focusNext 로 이동)
    if (_focusNext) {                      // 값이 안 바뀌어 재렌더가 없었던 경우
      if (!saFocusCell(_focusNext)) {      // 갈 줄이 아직 없으면 꼬리 빈 줄을 만들어 그린다
        saTail(); if (_pShown < _rows.length) _pShown = _rows.length; saRender();
      } else { _focusNext = null; }
    }
  } else if (e.key === 'ArrowDown') { e.preventDefault(); saStepRow(t, 1); }
  else if (e.key === 'ArrowUp')     { e.preventDefault(); saStepRow(t, -1); }
}
function saStepRow(t, dr){
  var r = +t.dataset.r, f = t.dataset.f, nr = r + dr;
  if (nr < 0 || nr >= _rows.length) return;
  _focusNext = { r:nr, f:f, sel:'all' };
  t.blur();
  if (_focusNext) { saFocusCell(_focusNext); _focusNext = null; }
}

/* 상품코드 칸 입력검색 — vendor-pick 과 같은 조작감(↑↓·Enter·Esc)을 상품에 준다.
     이미 화면에 들고 있는 상품마스터(_prods)·매칭코드(_extItems)만 훑어 서버를 부르지 않는다.
     · 우리 코드/품명/규격 + 거래처 매칭코드(🔖, 연결된 것만)로 찾는다.
     · 고르면 그 행에 담기고(saProdPick / saExtPick 재사용) 커서가 EA수량으로 넘어간다.
   드롭다운은 그리드가 overflow 라 잘리므로 body 에 position:fixed 로 띄운다. */
var _pinInp = null, _pinRow = -1, _pinList = [], _pinIdx = -1, _pinDrop = null;
function _pinHit(q){ return function(x){ return String(x==null?'':x).toLowerCase().indexOf(q) >= 0; }; }
function saPinCands(q){
  var out = [], ven = (document.getElementById('saVenNm').dataset.cd) || '';
  var ext = _extItems.filter(function(x){ return x.prodCd && [x.extItemCd,x.extItemNm,x.extSpec].some(_pinHit(q)); });
  ext.sort(function(a,b){ return ((b.vendorCd===ven)?1:0) - ((a.vendorCd===ven)?1:0); });   // 지금 거래처 것 먼저
  ext.slice(0,5).forEach(function(x){
    out.push({ k:'ext', seq:x.extSeq, code:x.extItemCd, nm:x.extItemNm||'', spec:x.extSpec||'', price:x.extPrice, vendorNm:x.vendorNm });
  });
  for (var i=0; i<_prods.length && out.length<12; i++){
    var p = _prods[i]; if (!p.prodCd) continue;
    if (![p.prodCd,p.prodNm,p.spec].some(_pinHit(q))) continue;
    out.push({ k:'prod', code:p.prodCd, nm:p.prodNm, spec:p.spec, price:p.salePrice, prodCd:p.prodCd });
  }
  return out.slice(0,12);
}
function saPinInput(inp){
  _pinInp = inp; _pinRow = +inp.dataset.r;
  var q = String(inp.value||'').trim().toLowerCase();
  if (!q) { saPinClose(); return; }
  _pinList = saPinCands(q); _pinIdx = _pinList.length ? 0 : -1;
  saPinDraw(inp);
}
function saPinDraw(inp){
  if (!_pinDrop) {
    _pinDrop = document.createElement('div');
    _pinDrop.id = 'saPinDrop';
    _pinDrop.style.cssText = 'position:fixed;z-index:400;background:#fff;border:1px solid #cfd8e3;border-radius:8px;box-shadow:0 10px 30px rgba(0,0,0,.18);font-size:12.5px;max-height:260px;overflow:auto';
    document.body.appendChild(_pinDrop);
  }
  if (!_pinList.length) { saPinClose(); return; }
  var rc = inp.getBoundingClientRect();
  _pinDrop.style.left = rc.left + 'px';
  _pinDrop.style.top = (rc.bottom + 2) + 'px';
  _pinDrop.style.minWidth = Math.max(380, rc.width) + 'px';
  _pinDrop.innerHTML = _pinList.map(function(it,k){
    var on = (k === _pinIdx);
    var badge = (it.k === 'ext') ? '<span style="color:#274b8f">🔖 </span>' : '';
    return '<div data-k="'+k+'" onmousedown="saPinPickMd(event,'+k+')"'
      + ' style="display:flex;gap:8px;padding:6px 10px;cursor:pointer;white-space:nowrap;'+(on?'background:#e9f4f1;':'')+'">'
      + '<b style="min-width:100px;color:#137a6c">'+badge+esc(it.code)+'</b>'
      + '<span style="flex:1;text-align:left;color:#1f2a37">'+esc(it.nm)+'</span>'
      + '<span style="min-width:96px;color:#8a97a4">'+esc(it.spec||'')+'</span>'
      + '<span style="min-width:66px;text-align:right;color:#37475a">'+(it.price!=null&&it.price!==''?fmt(it.price):'')+'</span>'
      + (it.vendorNm ? '<span style="color:#9aa7b3">('+esc(it.vendorNm)+')</span>' : '')
      + '</div>';
  }).join('');
  _pinDrop.style.display = 'block';
}
function saPinKey(inp, e){
  if (e.key === 'ArrowDown') { e.preventDefault(); if (_pinList.length){ _pinIdx = Math.min(_pinList.length-1, _pinIdx+1); saPinDraw(inp); } }
  else if (e.key === 'ArrowUp') { e.preventDefault(); if (_pinList.length){ _pinIdx = Math.max(0, _pinIdx-1); saPinDraw(inp); } }
  else if (e.key === 'Enter') {
    e.preventDefault();
    if (_pinList.length && _pinIdx >= 0) saPinPick(_pinIdx);
    else saProdOpen(+inp.dataset.r);       // 후보가 없으면 상품 선택 팝업으로
  }
  else if (e.key === 'Escape') { saPinClose(); }
}
function saPinPickMd(e, k){ e.preventDefault(); saPinPick(k); }   // mousedown 이라 input blur 보다 먼저
function saPinPick(k){
  var it = _pinList[k]; if (!it) { saPinClose(); return; }
  var row = _pinRow;
  saPinClose();
  _prodTargetRow = row;
  _focusNext = { r:row, f:'eaQty', sel:'all' };   // 담긴 뒤 커서는 EA수량으로
  if (it.k === 'ext') saExtPick(it.seq); else saProdPick(it.prodCd);   // 기존 담기 로직 재사용
}
function saPinClose(){ if (_pinDrop) _pinDrop.style.display = 'none'; _pinList = []; _pinIdx = -1; }
function saPinBlur(){ setTimeout(saPinClose, 150); }

/* 전역 리스너 — 그리드 키 위임, 스크롤 시 드롭다운 닫기, 저장/신규 단축키.
   (함수 선언은 hoisting 되므로 init 보다 뒤에 있어도 안전하다) */
(function saKbdBind(){
  var b = document.getElementById('saBody');
  if (b) b.addEventListener('keydown', saGridKey);
  var g = document.getElementById('saGridWrap');
  if (g) g.addEventListener('scroll', saPinClose);
  window.addEventListener('resize', saPinClose);
  document.addEventListener('keydown', function(e){
    if ((e.ctrlKey || e.metaKey) && (e.key === 's' || e.key === 'S')) { e.preventDefault(); saSave(); }
    else if (e.altKey && (e.key === 'n' || e.key === 'N')) { e.preventDefault(); saNew(); }
    /* ESC = 상품 선택 팝업 닫기(2026-08-05 요청, 매입등록과 동일) — 한글 조합 중 ESC 는 IME 취소라 건드리지 않는다 */
    else if (e.key === 'Escape' && !e.isComposing){
      var p = document.getElementById('saProdPop');
      if (p && p.classList.contains('on')) { e.preventDefault(); saProdClose(); }
      var b = document.getElementById('saBatchPop');
      if (b && b.classList.contains('on')) { e.preventDefault(); saBatchClose(); }
    }
  });
})();
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
