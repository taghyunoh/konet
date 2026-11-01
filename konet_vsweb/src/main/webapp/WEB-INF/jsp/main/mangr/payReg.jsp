<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 메시지는 프로젝트 공통 컴포넌트(로그인 화면과 동일) --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- ★날짜 칸에 [◀][▶][오늘] 을 자동으로 붙인다 (2026-08-17 요청) — 화면 수정 0.
     브라우저 기본 달력의 ↑↓ 는 앞/뒤가 안 읽혀 엉뚱한 달로 넘어가는 일이 잦았다.
     빼려면 그 칸에 data-nonav="1" --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<%-- 거래처 입력검색 — 거래처 칸에 직접 쳐서 고른다(2026-08-01). [거래처] 팝업은 그대로 둔다. --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260917"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js?v=20260911"></script>
<%-- 표 높이 막대 (2026-09-10 「수금등록 지급등록도 높이 막대」) — 판매·매입·발주서와 같은 공용 파일(asset/js/ui-gridgrip.js).
     전표 목록(지급계 줄 밑) · 원장(합계 줄 밑) · 매입등록 내역 — 세 표에 하나씩, 높이는 표마다 따로 기억한다.
     아래로 끌면 늘고 위로 끌면 준다 · [▲ 줄이기][▼ 늘리기] · 더블클릭 = 원래 모양(원장의 inline max-height 도 되살린다). --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20261014"></script>
<%-- 팝업 창 끌어 옮기기 (2026-09-10 「수금등록 지급등록 팝업도 움직이게」) — 판매·매입·발주서와 같은 공용 파일(asset/js/ui-popdrag.js).
     거래처 선택 창 : 제목줄을 잡고 끈다(검색칸 위는 제외) · 자리 기억 · 더블클릭 = 처음 자리 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-popdrag.js?v=20260910b"></script>
<script type="text/javascript">konetPopDrag('.sv-pop');</script>
<script type="text/javascript">konetGridGrip('svListWrap', 'svSumBox', 'payRegList'); konetGridGrip('lgWrap', 'lgFootWrap', 'payRegLedger'); konetGridGrip('pdWrap', 'pdWrap', 'payRegPd');</script>
<!--
  지급등록 — 홀세일닥터 '지급 등록' 이관 (2026-07-25 신설)
    · 원천 : TBL_SETTLE_TRX (TRX_GB='PAY'). 수금등록과 같은 테이블·같은 쿼리를 쓴다
    · 우측 원장은 매입전표 + 지급전표를 합쳐 일자별 잔고를 낸다
    · 설계 근거 : docs/매입등록_설계안.md §4-2
-->
<style>
  :root{ --sv-bd:#dbe2ea; --sv-teal:#137a6c; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  .sv-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .sv-wrap h2{ margin:0 0 4px; font-size:20px; }
  .sv-sub{ color:#1f2a37; margin-bottom:8px; font-size:12.5px; font-weight:600; }
  .sv-card{ background:#fff; border:1px solid var(--sv-bd); border-radius:10px; padding:10px; margin-bottom:10px; }
  .sv-btn{ height:32px; border:1px solid var(--sv-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .sv-btn:hover{ border-color:var(--sv-teal); }
  .sv-btn.teal{ background:var(--sv-teal); color:#fff; border-color:var(--sv-teal); }
  .sv-btn.red{ color:#c0392b; border-color:#e3b4ae; }
  /* 입력 표 — 원본처럼 라벨/값 2열 */
  .sv-form{ width:100%; border-collapse:collapse; font-size:13.5px; }
  .sv-form th{ background:#eef3f2; border:1px solid var(--sv-bd); padding:6px 10px; width:90px; text-align:center; font-weight:700; }
  .sv-form td{ border:1px solid var(--sv-bd); padding:5px 8px; }
  .sv-form input, .sv-form select{ height:29px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .sv-form input.num{ text-align:right; }
  .sv-form input[readonly]{ background:#f5f7f9; }
  .sv-lbl{ color:#1f2a37; margin:0 4px 0 8px; font-size:12.5px; font-weight:700; white-space:nowrap; }
  .sv-bal{ font-weight:800; font-size:15px; color:#c0392b; }
  /* 목록 — 5행 고정 + 자동 스크롤(매출내역과 같은 방식) */
  .sv-list{ max-height:196px; overflow:auto; border:1px solid var(--sv-bd); border-radius:8px; }
  /* ★본문 목록만 max(…, vh) — 판매등록(salesReg #saListWrap)과 같은 이유·같은 날(2026-08-28) */
  #svListWrap{ max-height:max(196px, 30vh); }
  /* ↑ 전표 목록·원장·매입등록 내역 세 표 모두 높이 막대(ui-gridgrip.js, 2026-09-10) — 고르면 그 높이로 고정되고 max-height 가 풀린다 · 더블클릭 = 원래 모양 */
  .sv-list table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sv-list th{ background:#b9ded4; color:#0b4f43; font-weight:800; box-shadow:inset 0 -2px 0 #0e6657; border:1px solid var(--sv-bd); padding:7px 8px; position:sticky; top:0; z-index:2; }
  .sv-list td{ border:1px solid var(--sv-bd); padding:6px 8px; text-align:center; }
  .sv-list td.num{ text-align:right; }
  .sv-list tr{ cursor:pointer; }
  /* 우측 카드 탭 — 원장 / 미지급 현황 (2026-11-01, 수금등록 미수 현황과 같은 모양) */
  .sv-tabs{ display:flex; gap:6px; align-items:center; margin-bottom:8px; }
  .sv-tab{ height:30px; padding:0 12px; border:1px solid var(--sv-bd); border-radius:7px; background:#fff; font-size:13px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
  .sv-tab.on{ background:#137a6c; border-color:#137a6c; color:#fff; }
  #apQ{ height:30px; width:200px; border:1px solid var(--sv-bd); border-radius:7px; padding:0 10px; font-size:13px; font-family:inherit; }
  #apList tr.on td{ background:#e3f2ee; }
  #apList td.nm{ text-align:left; }
  .ap-due{ display:inline-block; padding:1px 7px; border-radius:10px; font-size:11.5px; font-weight:800; }
  .ap-due.ok{ background:#e3f2ee; color:#0f6b5e; } .ap-due.w{ background:#fff3cd; color:#8a4c0d; } .ap-due.b{ background:#fde2e2; color:#b42318; }
  .sv-list tr:hover td{ background:#f3f8f6; }
  .sv-list tr.on td{ background:#fdeef0; font-weight:700; }
  .sv-sum{ display:flex; border:1px solid var(--sv-bd); border-top:0; border-radius:0 0 8px 8px; overflow:hidden; }
  .sv-sum div{ flex:1; padding:8px 10px; font-size:13.5px; }
  .sv-sum div.k{ background:#eef3f2; font-weight:700; flex:0 0 90px; text-align:center; }
  .sv-sum div.v{ text-align:right; font-weight:700; }
  /* 팝업 */
  .sv-pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:200; }
  .sv-pop.on{ display:block; }
  .sv-pop .box{ background:#fff; width:min(680px,94vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.3); }
  .sv-pop .hd{ padding:12px 16px; border-bottom:1px solid var(--sv-bd); font-weight:800; display:flex; gap:8px; align-items:center; }
  .sv-pop .bd{ padding:12px 16px; overflow:auto; }
  .sv-pop .ft{ padding:10px 16px; border-top:1px solid var(--sv-bd); text-align:right; }
  .sv-pop table{ width:100%; border-collapse:collapse; font-size:13px; }
  .sv-pop th{ background:#eef3f2; border:1px solid var(--sv-bd); padding:6px 8px; }
  .sv-pop td{ border:1px solid var(--sv-bd); padding:6px 8px; text-align:center; }
  .sv-pop tr.pick{ cursor:pointer; }
  .sv-pop tr.pick:hover td{ background:#f3f8f6; }
  .sv-msg{ padding:10px; color:#5a6b7a; text-align:center; font-size:12.5px; }
  /* 원장 합계 — 스크롤 영역 밖에 고정 */
  .sv-lgfoot{ overflow:hidden; border:1px solid var(--sv-bd); border-top:0; border-radius:0 0 8px 8px; }
  .sv-lgfoot table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sv-lgfoot td{ border:1px solid var(--sv-bd); padding:7px 8px; text-align:right; background:#d9f0e0; font-weight:800; }
  .sv-lgfoot td:first-child{ text-align:center; }
  /* ★「거래처 매출장·마감」 그리드 모양으로 (2026-10-21 사용자 「매입관리, 입고내역도」 — 품목별재고현황과 같게)
       머리줄 하늘(#d9edf7)+회청 테두리(#9fb6c3) · 칸 테두리 #c9d3dc · 합계 줄 크림(#fcf8e3). 그 밖의 줄 색·배지·입력칸은 그대로 */
  .sv-list th{ background:#d9edf7 !important; color:#1f2a37 !important; font-weight:700; border:1px solid #9fb6c3 !important; box-shadow:inset 0 -1px 0 #9fb6c3, inset 0 1px 0 #9fb6c3 !important; }
  .sv-list td{ border:1px solid #c9d3dc; }
</style>

<div class="sv-wrap">
  <h2>💸 지급등록</h2>
  <div class="sv-sub">매입처에 지급한 금액을 건 단위로 기록합니다. 우측 원장에 매입·지급·잔고가 함께 쌓입니다.</div>

  <%-- 좌우 2단 : 왼쪽에 입력+목록, 오른쪽 원장은 ★맨 위부터 시작한다(2026-07-25 요청).
       전에는 원장이 하단 목록과 같은 줄에서 시작해 화면 오른쪽 위가 비어 보였다.
       ★2026-08-01 : 좌우 비중을 수금등록과 같게 맞춘다(요청). 종전엔 원장이 470px 고정이라
         화면이 넓어져도 원장만 그대로였고 좌측만 늘어났다 → '좌측이 조금 더 넓은 반반' 비율로.
         좁은 화면에서는 wrap 으로 원장이 아래로 내려간다. --%>
  <div style="display:flex; gap:12px; align-items:flex-start; flex-wrap:wrap">
  <div style="flex:1.25 1 720px; min-width:0">

  <!-- ===== 입력 ===== -->
  <div class="sv-card">
    <table class="sv-form">
      <tr>
        <th>지급일자</th>
        <td>
          <input type="date" id="svDt" onchange="svNextNo()">
          <span class="sv-lbl">번호</span><input type="text" id="svNo" readonly tabindex="-1" style="width:70px">
          <span class="sv-lbl">구분</span>
          <select id="svPayGb"><option>무통장지급</option><option>현금</option><option>카드</option><option>계좌이체</option><option>어음</option></select>
          <span class="sv-lbl">지급계좌</span>
          <select id="svAcct" style="min-width:250px">
            <option value="">(선택 안 함)</option>
            <option>국민은행 / 699237-01-004560 / (주)코네트</option>
            <option>우리은행 / 1005-201-931176 / (주)코네트</option>
          </select>
        </td>
      </tr>
      <tr>
        <th>거래처</th>
        <td>
          <%-- 거래처 = 직접 입력검색(거래처명·코드·별칭·대표·담당 부분일치). 목록을 훑어보려면 [거래처] 버튼. --%>
          <input type="text" id="svCustNm" placeholder="매입처명 입력 또는 [거래처]" style="width:230px" title="거래처명·코드·별칭·대표자·담당자로 검색합니다. ↑↓ 로 고르고 Enter.">
          <%-- 거래처 코드 (2026-10-19 「매입처 코드도 추가」와 같은 식) — 같은 이름이 두 코드일 때 구분. svCustNm 의 data-cd 를 따라간다(svCustCdWatch) --%>
          <input type="text" id="svCustCd" readonly tabindex="-1" style="width:64px; background:#f5f7f9; color:#5a6b7a; text-align:center" title="거래처 코드 — 같은 이름이 두 코드로 있을 때 구분합니다" placeholder="코드">
          <button class="sv-btn teal" tabindex="-1" onclick="svCustOpen()">거래처</button>
          <span class="sv-lbl">담당자</span><input type="text" id="svMgrNm" readonly tabindex="-1" style="width:110px">
          <span class="sv-lbl">현잔고</span><span class="sv-bal" id="svBal">0</span>
          <%-- 남은 미지급을 그대로 새 지급 전표로 올린다(2026-08-01, 수금등록과 동일). 잔고가 있을 때만 보인다. --%>
          <button class="sv-btn teal" id="svBalBtn" tabindex="-1" style="display:none; margin-left:10px" onclick="svBalTake()"
                  title="이 거래처의 남은 미지급을 새 지급 전표로 올립니다. 금액·일자를 확인한 뒤 [저장]을 누르세요.">잔고 지급</button>
        </td>
      </tr>
      <tr>
        <th>금액</th>
        <td>
          <span class="sv-lbl" style="margin-left:0">지급액</span><input type="text" class="num" id="svAmt" value="0" style="width:150px" oninput="svCalc()" onkeydown="svKey(event)">
          <span class="sv-lbl">할인액</span><input type="text" class="num" id="svDc" value="0" style="width:130px" oninput="svCalc()" onkeydown="svKey(event)">
          <span class="sv-lbl">합계금액</span><input type="text" class="num" id="svTot" value="0" readonly tabindex="-1" style="width:150px">
        </td>
      </tr>
      <tr><th>메모</th><td><input type="text" id="svRemark" style="width:100%" onkeydown="svKey(event)"></td></tr>
    </table>
    <%-- 작업 버튼은 입력 칸 아래 — 판매등록·매입등록과 같은 자리(2026-08-01 요청).
         종전에는 이 카드 맨 위에 있어 네 화면의 버튼 위치가 서로 달랐다. --%>
    <div style="display:flex; gap:6px; margin-top:10px; flex-wrap:wrap">
      <button class="sv-btn teal" onclick="svNew()">＋ 지급등록</button>
      <button class="sv-btn" onclick="svSave()">💾 저장</button>
      <button class="sv-btn" onclick="svReload()">🔄 새로고침</button>
      <button class="sv-btn red" onclick="svDelete()">✖ 삭제하기</button>
      <span id="svState" style="margin-left:8px; align-self:center; color:#3d4d5c; font-size:12.5px"></span>
      <span style="margin-left:auto; align-self:center; color:#8a97a4; font-size:11.5px"
            title="거래처 칸에 쳐서 ↑↓·Enter 로 고르면 금액칸으로 넘어갑니다. 금액칸에서 Enter 로 저장.">⌨ 거래처 입력검색 · 금액칸 Enter 저장 · Ctrl+S 저장 · Alt+N 신규</span>
    </div>
  </div>

  <!-- ===== 목록 ===== -->
    <div class="sv-card">
      <%-- 검색줄은 한 줄로 붙인다(2026-07-25 요청) — flex-wrap:wrap 이면 창이 좁을 때 접혀
           [리스트조회] 만 아랫줄로 떨어져 보기 나쁘다. 넘치면 이 줄만 가로 스크롤한다. --%>
      <div style="display:flex; gap:6px; align-items:center; flex-wrap:nowrap; overflow-x:auto; margin-bottom:8px">
        <span style="font-weight:700; align-self:center">Total : <span id="svTotal">0</span></span>
        <span class="sv-lbl">검색기간</span>
        <input type="date" id="svFrom" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px">
        <span>~</span>
        <input type="date" id="svTo" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px">
        <span class="sv-lbl">구분</span>
        <select id="svFPayGb" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px">
          <option value="">전체</option><option>무통장지급</option><option>현금</option><option>카드</option><option>계좌이체</option><option>어음</option>
        </select>
        <span class="sv-lbl">거래처</span>
        <input type="text" id="svFind" placeholder="거래처명" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px; width:150px">
        <button class="sv-btn teal" onclick="svLoad()">리스트조회</button>
      </div>
      <div class="sv-list" id="svListWrap">
        <table>
          <%-- 행 클릭 = 그 '거래처'를 고른다(신규 전표 상태 유지). 지난 전표를 고치려면 [수정] 버튼.
               2026-08-01 사용자 확정 — 수금등록과 같은 규칙. --%>
          <thead><tr>
            <th style="width:56px">수정</th>
            <th style="width:150px">지급일자</th><th style="width:70px">번호</th><th style="width:70px" title="거래처 코드 — 같은 이름이 두 코드로 있을 때 구분합니다 (2026-10-19)">코드</th><th>거래처명</th>
            <th style="width:90px">담당자</th><th style="width:100px">구분</th>
            <th style="width:120px">지급액</th><th style="width:100px">할인액</th>
            <th style="width:90px">등록자</th><th style="width:150px">비고</th>
          </tr></thead>
          <tbody id="svListBody"><tr><td colspan="11" class="sv-msg">[리스트조회]를 누르세요.</td></tr></tbody>
        </table>
      </div>
      <div id="svPager" style="padding:6px 2px; text-align:center; min-height:26px"></div>
      <div class="sv-sum" id="svSumBox">
        <div class="k">지급계</div><div class="v" id="sPay">0</div>
        <div class="k">할인계</div><div class="v" id="sDc">0</div>
      </div>
    </div>

    </div><!-- /좌측 열 -->

    <%-- 거래처 원장 — 우측 열, 화면 맨 위부터. 폭은 수금등록과 같은 비율(고정 470px 아님).
         ★2026-08-01 : 원장 아래에 [매입등록 내역] 카드를 붙였다(원장 줄 클릭 → 그 날 매입전표 명세).
           그래서 우측을 세로 2단으로 감싼다 — 감싸지 않으면 새 카드가 flex 3번째 칸이 되어 옆으로 붙는다. --%>
    <div style="flex:1 1 620px; min-width:520px; display:flex; flex-direction:column">
    <div class="sv-card">
      <%-- 탭 2개 (2026-11-01 「지급등록에도 수금등록 미수현황처럼 원장 옆에 지급현황」) — 매입은 있는데 지급이 덜 된 매입처를 거래처별로 · 검색 --%>
      <div class="sv-tabs">
        <button type="button" class="sv-tab on" id="svTabLg" onclick="svRTab('lg')">📒 원장</button>
        <button type="button" class="sv-tab" id="svTabAp" onclick="svRTab('ap')" title="매입(매입전표)은 있는데 지급이 덜 된 매입처를 한눈에 — 줄을 누르면 그 매입처가 왼쪽 전표에 올라갑니다">💰 미지급 현황</button>
        <span style="margin-left:auto; font-size:11.5px; color:#5a6b7a" id="svRTabHint">* 매출&amp;매입 거래처는 최종 잔고만 표시됩니다.</span>
      </div>
      <div id="svRLg">
      <div style="border:1px solid var(--sv-bd); border-radius:6px; padding:6px 8px; margin-bottom:6px; font-size:13px">
        <b>거래처명</b> <span id="lgCust" style="margin-left:8px">—</span>
      </div>
      <%-- 원장 스크롤 : 머리글은 위에 고정(sticky), 합계는 스크롤 영역 밖에 두어 항상 보이게 한다.
           두 표의 열 너비는 같은 colgroup 으로 맞춘다(2026-07-25 요청). --%>
      <div class="sv-list" id="lgWrap" style="max-height:max(440px, 52vh); border-radius:8px 8px 0 0">
        <table>
          <%-- 열 너비 = 비율(2026-08-01 요청, 수금등록과 동일). 종전에는 '매출'만 너비가 없어
                 남는 폭을 전부 먹어 혼자 두 배 넓고 나머지가 눌렸다. 짝을 이루는 열끼리 같은 폭 —
                 매출·매입 14% / 수금·지급 12% / DC·할인 9% / 잔고 16%(누계라 가장 큼) / 일자 14%. --%>
          <colgroup><col style="width:14%"><col style="width:14%"><col style="width:9%"><col style="width:12%"><col style="width:14%"><col style="width:12%"><col style="width:9%"><col style="width:16%"></colgroup>
          <thead><tr><th>일자</th><th>매출</th><th>DC</th><th>수금</th><th>매입</th><th>지급</th><th>할인</th><th>잔고</th></tr></thead>
          <tbody id="lgBody"><tr><td colspan="8" class="sv-msg">거래처를 선택하세요.</td></tr></tbody>
        </table>
      </div>
      <div class="sv-lgfoot" id="lgFootWrap">
        <table>
          <%-- 열 너비 = 비율(2026-08-01 요청, 수금등록과 동일). 종전에는 '매출'만 너비가 없어
                 남는 폭을 전부 먹어 혼자 두 배 넓고 나머지가 눌렸다. 짝을 이루는 열끼리 같은 폭 —
                 매출·매입 14% / 수금·지급 12% / DC·할인 9% / 잔고 16%(누계라 가장 큼) / 일자 14%. --%>
          <colgroup><col style="width:14%"><col style="width:14%"><col style="width:9%"><col style="width:12%"><col style="width:14%"><col style="width:12%"><col style="width:9%"><col style="width:16%"></colgroup>
          <tbody id="lgFoot"></tbody>
        </table>
      </div>
      </div>
      <%-- 미지급 현황 — 원천 = 거래처별 채권·채무와 같은 selectCustBalance(전 거래처 × 월 누계). 지급할금액 = (매입 − 매입할인) − 지급 · 화면에서 거래처로 접는다 --%>
      <div id="svRAp" style="display:none">
        <div style="display:flex; gap:8px; align-items:center; margin-bottom:6px; flex-wrap:wrap">
          <input type="search" id="apQ" placeholder="🔎 매입처명 / 코드" title="매입처명·코드 부분일치(영타로 쳐도 한글로 봅니다). Esc = 지우기" oninput="apRender()" onkeydown="if(event.key==='Escape'){ this.value=''; apRender(); }">
          <label style="font-size:12.5px; display:flex; align-items:center; gap:4px"><input type="checkbox" id="apOnly" checked onchange="apRender()"> 미지급 있는 곳만</label>
          <button type="button" class="sv-btn" style="height:30px; padding:0 10px; font-size:12.5px" onclick="apLoad(true)" title="서버에서 다시 읽습니다(저장·삭제 뒤에는 저절로 다시 읽습니다)">🔄</button>
          <span id="apInfo" style="margin-left:auto; font-size:12.5px; color:#5a6b7a"></span>
        </div>
        <div class="sv-list" id="apWrap" style="max-height:max(440px, 52vh)">
          <table>
            <colgroup><col style="width:30%"><col style="width:15%"><col style="width:15%"><col style="width:16%"><col style="width:12%"><col style="width:12%"></colgroup>
            <thead><tr><th>매입처</th><th>매입</th><th>지급</th><th>미지급(잔고)</th><th>마지막 지급</th><th>경과</th></tr></thead>
            <tbody id="apList"><tr><td colspan="6" class="sv-msg">읽는 중…</td></tr></tbody>
          </table>
        </div>
        <div style="font-size:11.5px; color:#5a6b7a; margin-top:6px">※ 매입 = 매입전표 − 매입할인 · 지급 = 지급 전표(할인 포함) · 미지급 = 매입 − 지급 (거래처별 채권·채무 화면과 같은 식). 마지막 지급 = 지급이 있던 마지막 달 · 경과 = 그 매입처의 마지막 거래일부터 오늘까지.</div>
      </div>
    </div>

    <%-- 매입등록 내역 — 원장의 일자 줄을 누르면 그 날 매입전표(TBL_PURCHASE_MST/DTL) 명세를 편다(2026-08-01 요청).
         조회 전용. 서버는 거래처별 채권·채무와 같은 selectCustDayDetail 을 쓰고 화면에서 gb='PURCH' 만 거른다. --%>
    <div class="sv-card" id="pdCard">
      <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
        <b>매입등록 내역</b>
        <span id="pdSub" style="font-size:12px; color:#5a6b7a">원장에서 일자 줄을 누르세요.</span>
        <span style="margin-left:auto; font-size:11.5px; color:#5a6b7a">* 전표 헤더 할인이 있으면 명세 합계와 원장 매입액이 다를 수 있습니다.</span>
      </div>
      <div class="sv-list" id="pdWrap" style="max-height:max(300px, 34vh)">
        <table>
          <colgroup><col style="width:16%"><col style="width:14%"><col style="width:28%"><col style="width:10%"><col style="width:12%"><col style="width:14%"><col></colgroup>
          <thead><tr><th>전표번호</th><th>품목코드</th><th>품목명</th><th>수량</th><th>단가</th><th>금액</th><th>비고</th></tr></thead>
          <tbody id="pdBody"><tr><td colspan="7" class="sv-msg">원장에서 일자 줄을 누르면 그 날 매입등록 내역이 나옵니다.</td></tr></tbody>
        </table>
      </div>
    </div>

    </div><!-- /우측 열 -->
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="sv-pop" id="svCustPop">
  <div class="box">
    <div class="hd">거래처 선택
      <input type="text" id="svCustQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:30px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px" oninput="svCustRender()">
      <%-- 매입 거래처만 (2026-10-19 사용자 「지급등록 원장에 7월 자료만」 — 같은 이름이 매출·매입 두 코드로 있어 매출 쪽을 골랐었다). 매입등록과 같은 규칙. [전체]로 끄면 모두 --%>
      <button class="sv-btn" id="svVenAllBtn" onclick="svVenAll(!_venAll)" title="평소엔 거래유형이 매입(또는 미지정)인 거래처만 보입니다 — 누르면 매출 거래처까지 전부" style="margin-left:6px">전체</button>
    </div>
    <div class="bd"><table><thead><tr><th style="width:90px">코드</th><th>거래처명</th><th style="width:84px">거래유형</th><th style="width:130px">별칭</th><th style="width:100px">대표자</th><th style="width:90px">담당사원</th></tr></thead>
      <tbody id="svCustBody"></tbody></table></div>
    <div class="ft"><button class="sv-btn" onclick="svCustClose()">닫기</button></div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var GB = 'PAY';            // 이 화면은 지급. 수금 화면은 'RCV' 만 다르다
var _list = [], _vendors = [], _cur = null, _curNet = 0, _balNow = 0;   // _balNow = 현잔고(미지급) — [잔고 지급]용

function n(v){ var x = Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x) ? x : 0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function fmtDt(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function post(url, body, isJson){
  return fetch(CTX+url, { method:'POST', credentials:'same-origin',
    headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded'},
    body: isJson ? JSON.stringify(body) : body });
}
/* 메시지 — 로그인 화면과 같은 공통 컴포넌트(asset/js/ui-message.js) */
function swOk(m){ if(window._alertBox) return _alertBox(m,{icon:'✅'}); alert(m); }
function swErr(m){ if(window._alertBox) return _alertBox(m,{icon:'❌',okColor:'red'}); alert(m); }
function swConfirm(m, okText){
  return new Promise(function(res){
    if(!window._confirmBox){ res(confirm(String(m).replace(/<br\s*\/?>/gi,'\n'))); return; }
    _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', onOk:function(){res(true);}, onCancel:function(){res(false);} });
  });
}

(function init(){
  document.getElementById('svDt').value = today();
  var d = new Date(); d.setMonth(d.getMonth()-2);
  document.getElementById('svFrom').value = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01';
  document.getElementById('svTo').value = today();
  svLoadMasters();
  svNew(); svLoad();
  /* 거래처 칸 입력검색 — 고르는 동작은 팝업과 같은 svCustPick() 을 그대로 탄다(잔고·원장·담당자 갱신 포함).
     _vendors 는 위 조회가 나중에 채우므로 배열이 아니라 '함수'로 넘긴다. */
  _vendorPick(document.getElementById('svCustNm'), {
    list   : function(){ return _vendors; },
    onPick : function(o){ svCustPick(o.vendorCd); },
    onClear: function(){ document.getElementById('svMgrNm').value=''; document.getElementById('svMgrNm').dataset.cd=''; svBal(''); svLedger(''); }
  });
})();

/* ── 입력 ── */
function svNew(){
  _cur = null; _curNet = 0;
  document.getElementById('svCustNm').value=''; document.getElementById('svCustNm').dataset.cd='';
  document.getElementById('svMgrNm').value=''; document.getElementById('svMgrNm').dataset.cd='';
  document.getElementById('svAmt').value='0'; document.getElementById('svDc').value='0';
  document.getElementById('svRemark').value='';
  _balNow = 0;
  document.getElementById('svBal').textContent='0';
  document.getElementById('svState').textContent='신규 전표';
  svCalc(); svNextNo(); svLedger(''); svBalBtnUpd();
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr){ tr.classList.remove('on'); });
  svFocusCust();                     // 신규는 거래처부터(2026-08-04)
}
function svNextNo(){
  var dt = document.getElementById('svDt').value;
  if (!dt || _cur) return;
  post('/mangr/settleNextNo.do','trxGb='+GB+'&trxDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){ document.getElementById('svNo').value=(j&&j.data)||'0001'; })
    .catch(function(){ document.getElementById('svNo').value='0001'; });
}
function svCalc(){
  var a = n(document.getElementById('svAmt').value), d = n(document.getElementById('svDc').value);
  document.getElementById('svTot').value = fmt(a + d);
}
/* 저장 뒤 화면 — 거래처와 원장은 그대로 두고 입력만 비운다 (2026-08-01, 수금등록과 동일).
   종전에는 svNew() 가 거래처까지 지워서, 방금 넣은 지급이 잔고·원장에 어떻게 반영됐는지
   보려면 목록에서 그 전표를 다시 눌러야 했고 그러면 '수정 중' 으로 들어가 버렸다. */
function svNewKeep(){
  var c = document.getElementById('svCustNm'), cd = c.dataset.cd || '';
  if(!cd){ svNew(); return; }
  _cur = null; _curNet = 0;
  document.getElementById('svAmt').value='0'; document.getElementById('svDc').value='0';
  document.getElementById('svRemark').value='';
  document.getElementById('svState').textContent='신규 전표 — '+c.value;
  svCalc(); svNextNo();
  svBal(cd); svLedger(cd);          // 방금 저장분이 반영된 잔고·원장을 다시 읽는다
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr){ tr.classList.remove('on'); });
  svFocusAmt();                     // 같은 거래처로 이어 넣으니 금액칸으로(2026-08-04)
}
function svSave(){
  var cd = document.getElementById('svCustNm').dataset.cd||'';
  if (!cd) { swErr('거래처를 선택하세요.'); return; }
  var a = n(document.getElementById('svAmt').value), d = n(document.getElementById('svDc').value);
  if (a === 0 && d === 0) { swErr('지급액이나 할인액을 입력하세요.'); return; }
  var dto = {
    trxSeq: _cur ? _cur.trxSeq : null, trxGb: GB,
    trxDt: document.getElementById('svDt').value, trxNo: document.getElementById('svNo').value,
    payGb: document.getElementById('svPayGb').value,
    acctNm: document.getElementById('svAcct').value, acctCd: '',
    custCd: cd, custNm: document.getElementById('svCustNm').value,
    mgrCd: document.getElementById('svMgrNm').dataset.cd||'', mgrNm: document.getElementById('svMgrNm').value,
    amt: a, dcAmt: d, saleDcAmt: 0, totAmt: a + d,
    remark: document.getElementById('svRemark').value
  };
  /* ★ 목록에서 지난 전표를 누르면 화면이 '수정 중' 이 된다 — 그 상태로 저장하면
       새 지급이 아니라 그 전표를 덮어쓴다. 눈에 잘 안 띄는 차이라 저장 전에 한 번 묻는다. */
  var ask = _cur
    ? swConfirm('지난 전표를 <b>수정</b>합니다 — '+fmtDt(_cur.trxDt)+' / '+_cur.trxNo
              + '<br><span style="font-size:13px;color:#3d4d5c">새 지급이 아니라 이 전표를 덮어씁니다.</span>', '수정')
    : Promise.resolve(true);
  ask.then(function(ok){
    if(!ok) return;
    var edit = !!_cur;
    post('/mangr/settleSave.do', dto, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(){
        /* 무엇이 저장됐는지 분명히 — '저장했습니다' 만으로는 신규인지 수정인지 알 수 없다 */
        swOk(edit ? ('전표를 수정했습니다 — '+dto.trxDt+' / '+dto.trxNo)
                  : ('새 지급 전표로 저장했습니다 — '+dto.trxDt+' / '+dto.trxNo));
        svNewKeep(); svLoad(); apLoad(true);
      })
      .catch(function(e){ swErr('저장에 실패했습니다.<br><span style="font-size:13px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
  });
}
function svDelete(){
  /* 행 클릭은 '거래처 선택'이라 _cur 가 안 잡힌다 — 삭제할 전표는 [수정] 으로 불러와야 한다 */
  if (!_cur) { swErr('삭제할 전표를 먼저 불러오세요.<br><span style="font-size:13px;color:#3d4d5c">아래 목록에서 그 줄의 [수정] 버튼을 누르세요.</span>'); return; }
  swConfirm('이 지급 전표를 삭제할까요?', '삭제').then(function(ok){
    if(!ok) return;
    post('/mangr/settleDelete.do', { trxSeq:_cur.trxSeq }, true)
      .then(function(r){ if(!r.ok) return r.text().then(function(t){ throw new Error(t); }); swOk('삭제했습니다.'); svNewKeep(); svLoad(); apLoad(true); })
      .catch(function(e){ swErr('삭제에 실패했습니다.<br><span style="font-size:13px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
  });
}
function svReload(){ svLoadMasters(); svLoad(); var cd=document.getElementById('svCustNm').dataset.cd||''; if(cd){ svBal(cd); } }   // 거래처 목록도 새로(2026-09-13)
/* ★거래처 목록을 «다시 보일 때»·창을 열 때 새로 읽는다 (2026-09-13 「수금·지급·발주서 등록도 같게」 — 매입·판매등록과 같은 규칙)
     셸 iframe 은 로그아웃 전까지 그대로라, 화면을 열 때 한 번만 읽으면 다른 화면에서 고친 거래처(이름·담당자…)가 안 보였다.
     읽는 때 = 화면을 열 때 · 🔄 새로고침 · 거래처 창을 열 때 · 셸이 이 화면을 다시 보여 줄 때(konetShown, 3초 안 중복은 한 번만).
     도착하면 열려 있는 거래처 창을 그 자리에서 다시 그린다. 이미 고른 거래처·입력 중인 전표는 건드리지 않는다. */
function svLoadMasters(){
  post('/vendor/selectVendorMst.do','').then(function(r){return r.json();}).then(function(j){ _vendors=(j&&j.data)||[]; svCustRefreshed(); }).catch(function(){});
}
var _svMastersAt=0;
window.konetShown=function(){
  if(Date.now()-_svMastersAt<3000) return;
  _svMastersAt=Date.now();
  svLoadMasters();
};

/* ── 목록 (5행 고정 + 자동 스크롤) ── */
var LIST_ROWS = 5, _lShown = 0, _lBound = false;
function svLoad(){
  var b = 'trxGb='+GB
        + '&fromDt='+encodeURIComponent(document.getElementById('svFrom').value)
        + '&toDt='+encodeURIComponent(document.getElementById('svTo').value)
        + '&payGb='+encodeURIComponent(document.getElementById('svFPayGb').value)
        + '&findData='+encodeURIComponent(document.getElementById('svFind').value);
  document.getElementById('svListBody').innerHTML='<tr><td colspan="11" class="sv-msg">조회 중…</td></tr>';
  post('/mangr/settleList.do', b).then(function(r){return r.json();}).then(function(j){
    _list=(j&&j.data)||[]; svListRender();
  }).catch(function(e){ document.getElementById('svListBody').innerHTML='<tr><td colspan="11" class="sv-msg" style="color:#c0392b">조회 오류</td></tr>'; });
}
function svRowHtml(o,i){
  return '<tr onclick="svPickCust('+i+')" title="클릭 → 이 거래처를 골라 새 지급 전표로">'
    + '<td><button class="sv-btn" style="height:24px;padding:0 8px;font-size:12px" title="이 전표를 불러와 고칩니다"'
    +   ' onclick="event.stopPropagation();svEdit('+i+')">수정</button></td>'
    + '<td>'+esc(fmtDt(o.trxDt))+' '+esc(String(o.regDttm||'').slice(11,16))+'</td>'
    + '<td>'+esc(o.trxNo)+'</td><td style="color:#5a6b7a; font-size:12.5px">'+esc(o.custCd)+'</td><td style="text-align:left">'+esc(o.custNm)+'</td><td>'+esc(o.mgrNm)+'</td>'   /* 거래처 코드 (2026-10-19) */
    + '<td>'+esc(o.payGb)+'</td><td class="num">'+fmt(o.amt)+'</td><td class="num">'+fmt(o.dcAmt)+'</td>'
    + '<td>'+esc(o.regUser)+'</td><td style="text-align:left">'+esc(o.remark)+'</td></tr>';
}
function svListRender(){
  document.getElementById('svTotal').textContent = _list.length;
  var tb = document.getElementById('svListBody');
  if(!_list.length){ tb.innerHTML='<tr><td colspan="11" class="sv-msg">전표가 없습니다.</td></tr>'; _lShown=0; svPager(); svSum(); return; }
  _lShown = Math.min(LIST_ROWS, _list.length);
  tb.innerHTML = _list.slice(0,_lShown).map(function(o,i){ return svRowHtml(o,i); }).join('');
  svBind(); svPager(); svSum();
}
function svMore(cnt){
  if(_lShown >= _list.length) return;
  var to = Math.min(_lShown + (cnt||LIST_ROWS), _list.length), h='';
  for(var i=_lShown;i<to;i++) h += svRowHtml(_list[i], i);
  document.getElementById('svListBody').insertAdjacentHTML('beforeend', h);
  _lShown = to; svPager();
}
function svBind(){
  var w = document.getElementById('svListWrap'); if(!w||_lBound) return; _lBound=true;
  w.addEventListener('scroll', function(){
    if(_lShown >= _list.length) return;
    if(w.scrollTop + w.clientHeight >= w.scrollHeight - 30) svMore();
  });
}
function svPager(){
  var el = document.getElementById('svPager');
  if(_lShown >= _list.length){
    el.innerHTML = _list.length > LIST_ROWS ? '<span style="color:#5a6b7a;font-size:12.5px">총 '+_list.length+'건 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a;font-size:12.5px">'+_lShown+' / <b>'+_list.length+'</b>건'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="sv-btn" style="height:24px;margin-left:8px;font-size:12px" onclick="svMore('+_list.length+')">모두 표시</button>';
}
function svSum(){
  var p=0,d=0; _list.forEach(function(o){ p+=n(o.amt); d+=n(o.dcAmt); });
  document.getElementById('sPay').textContent=fmt(p);
  document.getElementById('sDc').textContent=fmt(d);
}
/* 목록 행 클릭 = '이 거래처를 고른다' (2026-08-01 사용자 확정, 수금등록과 같은 규칙).
   거래처·담당자만 가져오고 화면은 신규 전표 상태를 지킨다 — 지급일자는 오늘, 금액은 0.
   우측 원장·현잔고가 그 거래처로 바뀌므로, 잔고가 있으면 [잔고 지급] 으로 바로 이어진다.
   ★지난 전표를 고치는 것은 행 안의 [수정] 버튼(svEdit) 으로만 — 실수로 덮어쓰지 않게 갈라 놓았다. */
function svPickCust(i){
  var o=_list[i]; if(!o) return;
  _cur = null; _curNet = 0;
  var c=document.getElementById('svCustNm'); c.value=o.custNm||''; c.dataset.cd=o.custCd||'';
  var m=document.getElementById('svMgrNm'); m.value=o.mgrNm||''; m.dataset.cd=o.mgrCd||'';
  document.getElementById('svDt').value = today();
  document.getElementById('svAmt').value='0'; document.getElementById('svDc').value='0';
  document.getElementById('svRemark').value='';
  document.getElementById('svState').textContent='신규 전표 — '+(o.custNm||'');
  svCalc(); svNextNo(); svBal(o.custCd); svLedger(o.custCd);
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr,k){ tr.classList.toggle('on', k===i); });
}
/* 지난 전표 수정 — 종전의 행 클릭 동작. 이제는 [수정] 버튼으로만 들어온다. */
function svEdit(i){
  var o=_list[i]; if(!o) return;
  _cur = o; _curNet = n(o.amt) + n(o.dcAmt);
  document.getElementById('svDt').value = fmtDt(o.trxDt);
  document.getElementById('svNo').value = o.trxNo;
  document.getElementById('svPayGb').value = o.payGb||'무통장지급';
  document.getElementById('svAcct').value = o.acctNm||'';
  var c=document.getElementById('svCustNm'); c.value=o.custNm||''; c.dataset.cd=o.custCd||'';
  var m=document.getElementById('svMgrNm'); m.value=o.mgrNm||''; m.dataset.cd=o.mgrCd||'';
  document.getElementById('svAmt').value = n(o.amt);
  document.getElementById('svDc').value = n(o.dcAmt);
  document.getElementById('svRemark').value = o.remark||'';
  document.getElementById('svState').textContent = '수정 중 — '+fmtDt(o.trxDt)+' / '+o.trxNo;
  svCalc(); svBal(o.custCd); svLedger(o.custCd);
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr,k){ tr.classList.toggle('on', k===i); });
}

/* ── 거래처 ── */
/* 거래처 코드 칸 — svCustNm 의 data-cd 가 바뀔 때마다(고르기·목록 클릭·수정·새로고침 어느 길이든) 따라 적는다 (2026-10-19) */
(function svCustCdWatch(){
  var v=document.getElementById('svCustNm'), c=document.getElementById('svCustCd'); if(!v||!c) return;
  var sync=function(){ c.value=v.dataset.cd||''; };
  if(window.MutationObserver) new MutationObserver(sync).observe(v, { attributes:true, attributeFilter:['data-cd'] });
  v.addEventListener('input', function(){ setTimeout(sync, 0); }); sync();
})();
function svCustOpen(){ document.getElementById('svCustPop').classList.add('on'); document.getElementById('svCustQ').value=''; svCustRender(); svLoadMasters(); }
function svCustClose(){ document.getElementById('svCustPop').classList.remove('on'); }
/* 새로 읽은 거래처 목록이 도착했을 때 — 창이 열려 있으면 그 자리에서 다시 그린다(닫혀 있으면 아무 일 없음) */
function svCustRefreshed(){ var p=document.getElementById('svCustPop'); if(p && p.classList.contains('on')) svCustRender(); }
/* 거래처 고르기 — 매입(또는 미지정) 거래처만 보이고, 같은 이름이 둘 이상이면 ⚠ 를 붙인다 (2026-10-19)
     제이투팩(주)가 매출 001586 · 매입 001595 두 코드로 있어 지급을 매출 쪽에 걸었고, 원장이 그 코드의 7월 자료만 보였다.
     거래유형이 비어 있는 예전 거래처는 그대로 보여 준다(매입등록과 같은 규칙). [전체]를 켜면 모두 보인다. */
var _venAll=false;
function svVenAll(on){ _venAll=!!on; var b=document.getElementById('svVenAllBtn'); if(b){ b.textContent=_venAll?'전체 ✔':'전체'; b.style.background=_venAll?'#137a6c':''; b.style.color=_venAll?'#fff':''; } svCustRender(); }
function svVenFit(o){ if(_venAll) return true; var g=String((o&&o.vendorGb)||''); return !g || g.indexOf('매입')>=0; }
function svCustRender(){
  var q=(document.getElementById('svCustQ').value||'').toLowerCase();
  var cnt={}; _vendors.forEach(function(o){ var k=String(o.vendorNm||'').trim(); cnt[k]=(cnt[k]||0)+1; });
  var l=_vendors.filter(function(o){ if(!svVenFit(o)) return false; if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; }); }).slice(0,200);
  document.getElementById('svCustBody').innerHTML = l.length ? l.map(function(o){
    var gb=String(o.vendorGb||''), dup=(cnt[String(o.vendorNm||'').trim()]||0)>1;
    return '<tr class="pick" onclick="svCustPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td>'
         + '<td style="text-align:left">'+esc(o.vendorNm)+(dup?' <span style="font-size:11px; font-weight:800; color:#9a4b00; background:#fff1e0; border:1px solid #f0c9a4; border-radius:6px; padding:0 5px" title="같은 이름의 거래처가 '+cnt[String(o.vendorNm||'').trim()]+'개 있습니다 — 코드·거래유형을 보고 고르세요">⚠ 같은 이름 '+cnt[String(o.vendorNm||'').trim()]+'개</span>':'')+'</td>'
         + '<td><span style="display:inline-block; padding:1px 7px; border-radius:10px; font-size:11.5px; font-weight:800; '+(gb?(gb.indexOf('&')>=0?'background:#eef0ff; color:#3f43a8':(gb.indexOf('매입')>=0?'background:#e6f4f1; color:#137a6c':'background:#fdecec; color:#c0392b')):'background:#f2f4f6; color:#8a97a4')+'">'+esc(gb||'미지정')+'</span></td>'
         + '<td>'+esc(o.alias)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="6" class="sv-msg">'+(_venAll?'검색 결과가 없습니다.':'매입 거래처 중에는 없습니다 — [전체]를 켜면 매출 거래처까지 보입니다.')+'</td></tr>';
}
function svCustPick(cd){
  var o=_vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0]; if(!o) return;
  var c=document.getElementById('svCustNm'); c.value=o.vendorNm||''; c.dataset.cd=o.vendorCd||'';
  var m=document.getElementById('svMgrNm'); m.value=o.mgrNm||''; m.dataset.cd=o.mgrCd||'';
  svCustClose(); svBal(o.vendorCd); svLedger(o.vendorCd);
  svFocusAmt();                     // 거래처를 고르면 곧바로 금액 입력으로(2026-08-04)
}
/* 현잔고 = 매입 − 지급 − 할인 누계 (미지급 잔액) */
function svBal(cd){
  if(!cd){ _balNow=0; document.getElementById('svBal').textContent='0'; svBalBtnUpd(); return; }
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l=(j&&j.data)||[], bal=0;
    l.forEach(function(o){ bal += n(o.purchAmt) - n(o.payAmt) - n(o.discAmt); });
    _balNow = bal;
    document.getElementById('svBal').textContent = fmt(bal);
    svBalBtnUpd();
  }).catch(function(){});
}

/* ── 잔고 지급 (2026-08-01 요청, 수금등록의 [잔고 수금]과 같은 동작) ──
     줄 돈이 남아 있으면 그 금액을 그대로 지급하는 것이 보통이다. 종전에는
     [지급등록] → 거래처를 다시 찾기 → 금액 입력 순서라 손이 많이 갔다.
     ★저장까지 하지는 않는다 — 금액·일자·구분을 확인하고 [저장]을 누르는 것은 사용자 몫. */
function svBalBtnUpd(){
  var b = document.getElementById('svBalBtn'); if(!b) return;
  var cd = document.getElementById('svCustNm').dataset.cd || '';
  var on = !!cd && _balNow > 0;                    // 선지급(음수)·0 이면 숨긴다
  b.style.display = on ? '' : 'none';
  b.textContent = on ? ('잔고 지급 ' + fmt(_balNow)) : '잔고 지급';
}
function svBalTake(){
  var c = document.getElementById('svCustNm'), cd = c.dataset.cd || '';
  if(!cd){ swErr('거래처를 먼저 선택하세요.'); return; }
  if(!(_balNow > 0)){ swErr('남은 미지급 잔고가 없습니다.'); return; }
  var bal = _balNow;
  /* 거래처·담당자는 그대로 두고 '새 전표'로 바꾼다 — 목록에서 고른 지난 전표를
     고치는 것이 아니다. _cur 을 먼저 비워야 svNextNo() 가 새 번호를 받아 온다. */
  _cur = null; _curNet = 0;
  document.getElementById('svDt').value = today();
  document.getElementById('svAmt').value = bal;
  document.getElementById('svDc').value = '0';
  document.getElementById('svRemark').value = '';
  document.getElementById('svState').textContent = '잔고 지급 — ' + fmt(bal) + ' 원 · 내용 확인 후 [저장]';
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr){ tr.classList.remove('on'); });
  svNextNo(); svCalc();
  var a = document.getElementById('svAmt'); a.focus(); a.select();   // 일부만 주는 경우 바로 고칠 수 있게
}

/* ── 원장 ── */
/* 합계 줄 열 맞춤 — 원장이 길어져 세로 스크롤바가 생기면 스크롤 영역 안의 표만 그만큼 좁아진다.
   합계(.sv-lgfoot)는 스크롤 영역 '밖'이라 그대로 두면 열이 스크롤바 폭만큼 어긋난다.
   열 너비가 비율(%)이라 어긋남이 전 열에 퍼지므로 반드시 맞춰 준다. 수금등록과 같은 처리. */
function lgFootPad(){
  var w = document.getElementById('lgWrap'), f = document.getElementById('lgFootWrap');
  if(!w || !f) return;
  f.style.paddingRight = Math.max(0, w.offsetWidth - w.clientWidth) + 'px';
}
window.addEventListener('resize', lgFootPad);

function svLedger(cd){
  var tb=document.getElementById('lgBody');
  _lgCd = cd || '';                 // 아래 [매입등록 내역]이 쓸 거래처
  svPurchClear();                   // 거래처가 바뀌면 명세는 지운다(옛 거래처 것이 남으면 오해)
  document.getElementById('lgCust').textContent = cd ? (document.getElementById('svCustNm').value||cd) : '—';
  if(!cd){ tb.innerHTML='<tr><td colspan="8" class="sv-msg">거래처를 선택하세요.</td></tr>'; document.getElementById('lgFoot').innerHTML=''; return; }
  tb.innerHTML='<tr><td colspan="8" class="sv-msg">불러오는 중…</td></tr>';
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l=(j&&j.data)||[];
    if(!l.length){ tb.innerHTML='<tr><td colspan="8" class="sv-msg">거래 내역이 없습니다.</td></tr>'; return; }
    var h='', bal=0, mm=null, m=z(), t=z();
    function z(){ return {s:0,d:0,r:0,p:0,y:0,c:0}; }
    function monthRow(){
      if(mm===null) return '';
      return '<tr style="background:#e8f6ec"><td>[월 계]</td><td class="num">'+fmt(m.s)+'</td><td class="num">'+fmt(m.d)
           + '</td><td class="num">'+fmt(m.r)+'</td><td class="num">'+fmt(m.p)+'</td><td class="num">'+fmt(m.y)
           + '</td><td class="num">'+fmt(m.c)+'</td><td></td></tr>';
    }
    l.forEach(function(o){
      var dt=String(o.dt||''), ym=dt.slice(0,6);
      var s=n(o.saleAmt), d=n(o.dcAmt), r=n(o.rcvAmt), p=n(o.purchAmt), y=n(o.payAmt), c=n(o.discAmt);
      if(mm!==null && ym!==mm){ h+=monthRow(); m=z(); }
      mm=ym;
      bal += p - y - c;                        // 매입처 잔고 = 매입 − 지급 − 할인
      m.s+=s;m.d+=d;m.r+=r;m.p+=p;m.y+=y;m.c+=c;
      t.s+=s;t.d+=d;t.r+=r;t.p+=p;t.y+=y;t.c+=c;
      // 일자 줄 클릭 → 아래 [매입등록 내역] ([월 계]·합계 줄은 클릭 대상이 아니다)
      h += '<tr class="lgrow" data-dt="'+esc(dt)+'" onclick="svPurchDtl(\''+esc(dt)+'\', this)">'
         + '<td>'+esc(fmtDt(dt))+'</td><td class="num">'+fmt(s)+'</td><td class="num">'+fmt(d)+'</td><td class="num">'+fmt(r)
         + '</td><td class="num">'+fmt(p)+'</td><td class="num">'+fmt(y)+'</td><td class="num">'+fmt(c)
         + '</td><td class="num"><b>'+fmt(bal)+'</b></td></tr>';
    });
    h += monthRow();
    tb.innerHTML = h;
    /* 합계는 스크롤 영역 밖에 — 아무리 내려도 항상 보인다 */
    document.getElementById('lgFoot').innerHTML =
      '<tr><td>합 계</td><td>'+fmt(t.s)+'</td><td>'+fmt(t.d)+'</td><td>'+fmt(t.r)+'</td><td>'+fmt(t.p)
      + '</td><td>'+fmt(t.y)+'</td><td>'+fmt(t.c)+'</td><td>'+fmt(bal)+'</td></tr>';
    lgFootPad();
  }).catch(function(){ tb.innerHTML='<tr><td colspan="8" class="sv-msg" style="color:#c0392b">원장 조회 오류</td></tr>'; });
}

/* ── 매입등록 내역 (원장 줄 클릭) ── 2026-08-01 요청
   원장은 일자별 합계라 '이 매입액이 무슨 물건이었는지'를 알 수 없었다. 줄을 누르면 그 날 매입전표 명세를 편다.
   ★서버는 거래처별 채권·채무(custBalance)와 같은 /mangr/selectCustDayDetail.do 를 그대로 쓴다(출고·매입·입금·출금을
     한 번에 주므로 여기서 gb='PURCH' 만 거른다) — 지급등록 전용 쿼리를 새로 만들면 두 화면 숫자가 갈라진다.
   ★조회 전용이다. 고치려면 매입등록 화면으로. */
var _lgCd = '', _pdKey = '';
function svPurchClear(){
  _pdKey='';
  var b=document.getElementById('pdBody'), s=document.getElementById('pdSub');
  if(s) s.textContent='원장에서 일자 줄을 누르세요.';
  if(b) b.innerHTML='<tr><td colspan="7" class="sv-msg">원장에서 일자 줄을 누르면 그 날 매입등록 내역이 나옵니다.</td></tr>';
}
function svPurchDtl(dt, tr){
  if(!_lgCd || !dt) return;
  var body=document.getElementById('lgBody');
  if(body) Array.prototype.forEach.call(body.querySelectorAll('tr.on'), function(r){ r.classList.remove('on'); });
  if(tr) tr.classList.add('on');
  var sub=document.getElementById('pdSub'), tb=document.getElementById('pdBody');
  sub.textContent=(document.getElementById('svCustNm').value||_lgCd)+' · '+fmtDt(dt)+' 하루';
  tb.innerHTML='<tr><td colspan="7" class="sv-msg">불러오는 중…</td></tr>';
  var key=_lgCd+'|'+dt; _pdKey=key;
  post('/mangr/selectCustDayDetail.do','custCd='+encodeURIComponent(_lgCd)+'&trxDt='+encodeURIComponent(dt))
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(_pdKey!==key) return;                       // 그 사이 다른 줄을 눌렀으면 버린다
      var l=((j&&j.data)||[]).filter(function(o){ return String(o.gb||'')==='PURCH'; });
      if(!l.length){ tb.innerHTML='<tr><td colspan="7" class="sv-msg">이 날짜의 매입등록 내역이 없습니다.</td></tr>'; return; }
      var h='', tq=0, ta=0;
      l.forEach(function(o){
        var q=n(o.qty), p=n(o.price), a=n(o.amt); tq+=q; ta+=a;
        h+='<tr><td>'+esc(o.docNo||'')+'</td><td>'+esc(o.itemCd||'')+'</td>'
          +'<td style="text-align:left">'+esc(o.itemNm||'')+'</td>'
          +'<td class="num">'+fmt(q)+'</td><td class="num">'+fmt(p)+'</td><td class="num"><b>'+fmt(a)+'</b></td>'
          +'<td style="text-align:left">'+esc(o.remark||'')+'</td></tr>';
      });
      h+='<tr style="background:#d9f0e0;font-weight:800"><td colspan="3">합 계 ('+l.length+'건)</td>'
        +'<td class="num">'+fmt(tq)+'</td><td></td><td class="num">'+fmt(ta)+'</td><td></td></tr>';
      tb.innerHTML=h;
    })
    .catch(function(e){
      if(_pdKey!==key) return;
      tb.innerHTML='<tr><td colspan="7" class="sv-msg" style="color:#c0392b">매입내역 조회 오류 — '+esc(e.message)+'</td></tr>';
    });
}

/* ══════════════════════════════════════════════════════════════════════
   키보드 편의 (2026-08-04) — 수금등록(rcvReg)과 같은 방식. 명세 그리드가 없는 단순 폼이라
   네이티브 Tab 이 그대로 통한다. 표시 전용 칸을 Tab 에서 빼고(tabindex=-1) 손이 덜 가게만 했다.
     · 신규/진입 → 거래처 칸에 커서. 거래처를 고르면(입력검색·팝업 공용) 금액칸으로 넘어간다.
     · 지급액·할인칸·메모칸에서 Enter = 저장. Ctrl+S = 저장, Alt+N = 신규.
   (함수 선언은 hoisting 되므로 init 의 svNew() 보다 뒤에 있어도 안전하다) */
function svFocusCust(){ var c=document.getElementById('svCustNm'); if(c){ c.focus(); if(c.select) c.select(); } }
function svFocusAmt(){ var a=document.getElementById('svAmt'); if(a){ a.focus(); if(a.select) a.select(); } }
function svKey(e){ if(e.key==='Enter'){ e.preventDefault(); svSave(); } }   // 금액·메모칸 Enter=저장
document.addEventListener('keydown', function(e){
  if((e.ctrlKey||e.metaKey) && (e.key==='s'||e.key==='S')){ e.preventDefault(); svSave(); }
  else if(e.altKey && (e.key==='n'||e.key==='N')){ e.preventDefault(); svNew(); }
});

/* ── 💰 미지급 현황 탭 (2026-11-01 「지급등록에도 수금등록 미수현황처럼 원장 옆에 지급현황」) ──
     원천 = /mangr/selectCustBalance.do (거래처별 채권·채무 화면과 같은 조회 · 전 거래처 × 월 누계 · 기간을 안 건다 = 전 기간 누계가 곧 잔액).
     화면에서 거래처로 접는다 : 매입 = purchAmt − purchDcAmt · 지급 = payAmt · 미지급 = 매입 − 지급. 서버 무변경.
     마지막 지급 = payAmt > 0 인 마지막 달(ym — 조회가 월 낟알이라 날짜까지는 없다) · 경과 = lastDt(그 매입처의 마지막 거래일)부터 오늘까지.
     탭을 처음 열 때 한 번 읽고, 저장·삭제 뒤(apLoad(true))와 [🔄] 로 다시 읽는다. 줄을 누르면 svCustPick(기존) 으로 왼쪽 전표에 매입처가 올라간다(탭은 그대로). */
var _ap=[], _apLoaded=false, _apBusy=false, _apTab='lg';
function svRTab(t){
  _apTab=t;
  document.getElementById('svTabLg').classList.toggle('on', t==='lg'); document.getElementById('svTabAp').classList.toggle('on', t==='ap');
  document.getElementById('svRLg').style.display=(t==='lg')?'':'none'; document.getElementById('svRAp').style.display=(t==='ap')?'':'none';
  var pd=document.getElementById('pdCard'); if(pd) pd.style.display=(t==='lg')?'':'none';   // [매입등록 내역]은 원장 일자 클릭용 — 미지급 탭에선 숨긴다(2026-11-01 「관계없으면 제거」)
  var h=document.getElementById('svRTabHint'); if(h) h.textContent=(t==='lg')?'* 매출&매입 거래처는 최종 잔고만 표시됩니다.':'* 줄을 누르면 그 매입처가 왼쪽 전표에 올라갑니다.';
  if(t==='ap'){ if(!_apLoaded) apLoad(false); else apRender(); var q=document.getElementById('apQ'); if(q) q.focus(); }
}
function apLoad(force){
  if(_apBusy) return; if(_apLoaded && !force && _apTab!=='ap') return;
  _apBusy=true; if(!_apLoaded){ var tb=document.getElementById('apList'); if(tb) tb.innerHTML='<tr><td colspan="6" class="sv-msg">읽는 중…</td></tr>'; }
  post('/mangr/selectCustBalance.do','').then(function(r){ return r.json(); }).then(function(j){
    _ap=apFold((j&&j.data)||[]); _apLoaded=true; _apBusy=false; if(_apTab==='ap') apRender();
  }).catch(function(e){ _apBusy=false; var tb=document.getElementById('apList'); if(tb) tb.innerHTML='<tr><td colspan="6" class="sv-msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
/* 거래처로 접기 — custBalance.jsp cbFold 의 지급 쪽과 같은 식(이월·당월 구분 없이 전부 누계) */
function apFold(rows){
  var m={}, ord=[];
  rows.forEach(function(r){ var k=String(r.custCd||''); if(!k) return;
    var o=m[k]; if(!o){ o=m[k]={ custCd:k, custNm:r.custNm||k, purch:0, pay:0, owe:0, lastDt:'', lastPayYm:'' }; ord.push(k); }
    var purch=n(r.purchAmt)-n(r.purchDcAmt), pay=n(r.payAmt);
    o.purch+=purch; o.pay+=pay; o.owe+=purch-pay;
    if(String(r.lastDt||'')>o.lastDt) o.lastDt=String(r.lastDt||'');
    if(pay!==0 && String(r.ym||'')>o.lastPayYm) o.lastPayYm=String(r.ym||'');
  });
  return ord.map(function(k){ return m[k]; }).filter(function(o){ return o.purch!==0 || o.pay!==0; });   // 매입·지급이 둘 다 0 인 곳(매출 거래처)은 뺀다
}
function apDtLbl(d){ d=String(d||'').replace(/-/g,''); return d.length===8 ? (d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6)) : (d.length===6 ? (d.slice(0,4)+'-'+d.slice(4)) : ''); }
function apDueDays(o){
  if(Math.round(o.owe)<=0) return null; var d=String(o.lastDt||'').replace(/-/g,''); if(d.length!==8) return null;
  var b=new Date(+d.slice(0,4), +d.slice(4,6)-1, +d.slice(6)), t=new Date(); t=new Date(t.getFullYear(), t.getMonth(), t.getDate());
  return Math.max(0, Math.round((t-b)/86400000));
}
/* 경과 기준일 = 회사 설정 dueWarn(⚠, 기본 30)·dueBad(⛔, 기본 60) — 수금등록 미수 현황과 같은 값 */
function apDueWarn(){ var v=Number(window.konetSet ? konetSet.f('dueWarn') : 0); return (isFinite(v)&&v>0)?v:30; }
function apDueBad(){ var v=Number(window.konetSet ? konetSet.f('dueBad') : 0); return (isFinite(v)&&v>0)?Math.max(v,apDueWarn()):Math.max(60,apDueWarn()); }
function apNorm(s){ return String(s||'').toLowerCase().replace(/\s+/g,''); }
function apView(){
  var q=apNorm((document.getElementById('apQ')||{}).value), only=!!(document.getElementById('apOnly')||{}).checked, qs=[q];
  if(q && typeof engToKor==='function'){ try{ var k=apNorm(engToKor(q)); if(k && k!==q) qs.push(k); }catch(e){} }
  return _ap.filter(function(o){
    if(only && Math.round(o.owe)<=0) return false;
    if(!q) return true;
    var nm=apNorm(o.custNm), cd=apNorm(o.custCd);
    return qs.some(function(x){ return nm.indexOf(x)>=0 || cd.indexOf(x)>=0; });
  }).sort(function(a,b){ return b.owe-a.owe; });
}
function apRender(){
  var tb=document.getElementById('apList'), info=document.getElementById('apInfo'); if(!tb) return;
  if(!_apLoaded){ tb.innerHTML='<tr><td colspan="6" class="sv-msg">읽는 중…</td></tr>'; return; }
  var v=apView(), cur=String((document.getElementById('svCustNm')||{}).dataset ? (document.getElementById('svCustNm').dataset.cd||'') : ''), sum=0;
  if(!v.length){ tb.innerHTML='<tr><td colspan="6" class="sv-msg">'+(_ap.length?'맞는 매입처가 없습니다 — 검색어를 지우거나 「미지급 있는 곳만」을 끄세요.':'매입 자료가 없습니다.')+'</td></tr>'; if(info) info.textContent=''; return; }
  tb.innerHTML=v.map(function(o){ sum+=o.owe; var d=apDueDays(o), lv=(d==null)?'':(d>=apDueBad()?'b':(d>=apDueWarn()?'w':'ok'));
    return '<tr data-cd="'+esc(o.custCd)+'"'+(o.custCd===cur?' class="on"':'')+' onclick="apPick(\''+esc(o.custCd)+'\')" title="누르면 이 매입처가 왼쪽 전표에 올라갑니다">'
      +'<td class="nm"><b>'+esc(o.custNm)+'</b> <span style="color:#5a6b7a;font-size:12px">'+esc(o.custCd)+'</span></td>'
      +'<td class="num">'+fmt(o.purch)+'</td><td class="num">'+fmt(o.pay)+'</td>'
      +'<td class="num" style="font-weight:800;color:'+(Math.round(o.owe)>0?'#c0392b':(Math.round(o.owe)<0?'#1b5fb3':'#37475a'))+'">'+fmt(o.owe)+'</td>'
      +'<td>'+(o.lastPayYm?apDtLbl(o.lastPayYm):'<span style="color:#9aa6b2">없음</span>')+'</td>'
      +'<td>'+(d==null?'':('<span class="ap-due '+lv+'" title="마지막 거래 '+(o.lastDt?apDtLbl(o.lastDt):'없음')+' · 마지막 지급 '+(o.lastPayYm?apDtLbl(o.lastPayYm):'없음')+'">'+d+'일</span>'))+'</td></tr>';
  }).join('');
  if(info) info.innerHTML='<b>'+v.length+'</b>곳'+(v.length<_ap.length?' / '+_ap.length:'')+' · 미지급 합계 <b style="color:#c0392b">'+fmt(sum)+'</b>';
}
/* 줄 클릭 → 기존 svCustPick(거래처 칸·담당자·현잔고·원장·금액칸 커서). 거래처 마스터에 없는 코드(옛 거래처)면 이름만 넣는다 */
function apPick(cd){
  var o=_ap.filter(function(x){ return x.custCd===String(cd); })[0]; if(!o) return;
  if(_cur) svNewKeep();                                   // 저장된 전표를 보고 있었으면 새 전표로(엉뚱한 전표에 거래처가 덮이지 않게)
  if(_vendors.some(function(x){ return String(x.vendorCd)===o.custCd; })) svCustPick(o.custCd);
  else { var c=document.getElementById('svCustNm'); c.value=o.custNm; c.dataset.cd=o.custCd; svBal(o.custCd); svLedger(o.custCd); svFocusAmt(); }
  Array.prototype.forEach.call(document.querySelectorAll('#apList tr'), function(tr){ tr.classList.toggle('on', tr.getAttribute('data-cd')===o.custCd); });
}
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
<%-- ★공통 UI 보정 (2026-08-21) — 단추 글자 두 줄 접힘 방지 + [글자 축소/확대] 단추 모양.
     화면 크기와 무관하게 늘 적용된다(위 konet-notebook.css 는 노트북 전용 @media 라 큰 화면에서는 안 걸린다). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
