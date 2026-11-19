<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 쓰기 (전역 XLSX, 서식 포함) — 매출 반품내역과 같은 도구 (2026-11-19) --%>
<title>재고흐름조회</title>
<%-- 재고흐름조회 (2026-11-19 신설 — 사용자 「재고관리에서 재고흐름이 이상한 것 확인해서 조회할 수 있게 재고흐름조회 메뉴 추가로」)
     재고 관리 ▸ 재고흐름조회. 셸 iframe(logiFrame 'stockFlow'). 조회 전용 — 아무것도 바꾸지 않는다.

     무엇을 보나 : 수불원장(TBL_STOCK_LEDGER)을 품목마다 기준일자까지 훑어 «흐름이 이상한 품목»을 찾는다.
       서버(/prod/stockFlowList.do)는 숫자만 주고 유형 판정은 여기(flagsOf)에서 한다 — 기준을 고치기 쉽게.
     유형 (위에서부터 급한 순서) :
       🔴 neg   현재고 음수          : 지금 재고가 0 밑. 입고가 빠졌거나 출고가 겹쳤다.
       🟠 noin  입고 없이 출고       : 입고·조정이 한 번도 없는데 출고만 있다(입고 등록 누락 · 다른 코드로 입고).
       🟠 ret   반품이 입고보다 많음 : 매입 반품(음수 입고) 합이 입고 합보다 크다.
       🟡 past  최근 음수(지금은 회복): 최근 30일(기본) 안에 잔고가 0 밑이었다 — 입고를 늦게 적었거나 조정으로 맞춘 흔적. (2026-11-19 「최근 30일 것만」 — 처음엔 기간 없이 547품목)
       🟡 adj   조정 잦음            : 조정이 3번 이상(기본) — 실사가 자주 어긋나는 품목.
       ⚪ dead  장기 무출고 재고     : 재고가 있는데 N일(기본 90일) 넘게 출고가 없다.
       ⚪ price 단가 없는 입고       : 단가 0 으로 들어온 입고가 있다 — 재고금액·이동평균이 틀어진다.
     ★잔고는 «하루 단위»로 쌓는다 — 같은 날 안에서는 출고가 입고보다 먼저 적혔을 수 있어, 줄 단위로 쌓으면 가짜 음수가 생긴다(서버 SQL · 아래 상세 둘 다).
     줄을 누르면 아래에 그 품목의 수불 줄이 날짜순으로 나오고 잔고를 쌓아 보여 준다 — 음수가 된 날은 빨갛게, 첫 음수 날로 스크롤.
     운영 DB 실측(2026-11-19) : 1,002 품목 · 현재고 음수 130 · 입고 없이 출고 117 · 과거 음수 547 · 조정 3회↑ 186 · 장기 무출고(90일) 220 · 단가 없는 입고 6. --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#b23b3b; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; overflow:hidden; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:6px 11px 8px; height:100%; display:flex; flex-direction:column; min-height:0; }
  .hd{ display:flex; align-items:baseline; gap:10px; margin:2px 2px 6px; }
  .hd h2{ margin:0; font-size:19px; } .hd small{ color:#6b7a89; font-size:12.5px; }
  .bar{ display:flex; flex-wrap:wrap; align-items:center; gap:5px 8px; padding:6px 10px; background:#fff; border:1px solid var(--bd); border-radius:8px; margin-bottom:6px; }
  .bar label{ font-size:13px; color:#48606f; font-weight:600; }
  .bar input[type=text], .bar input[type=date], .bar input[type=number], .bar input[type=search]{ height:30px; border:1px solid #cbd5e1; border-radius:5px; padding:0 8px; font-size:13px; font-family:inherit; }
  .bar .sp{ flex:1; }
  .btn{ height:30px; border:1px solid var(--teal); background:var(--teal); color:#fff; border-radius:5px; padding:0 14px; font-size:13px; font-weight:700; cursor:pointer; }
  .btn.ghost{ background:#fff; color:var(--teal); }
  /* 유형 칩 — 누르면 그 유형만. 건수는 지금 조회한 자료 기준 */
  .chips{ display:flex; flex-wrap:wrap; gap:6px; margin-bottom:6px; }
  .chip{ display:inline-flex; align-items:center; gap:6px; height:30px; padding:0 11px; border:1px solid var(--bd); border-radius:16px; background:#fff; font-size:13px; font-weight:700; color:#37475a; cursor:pointer; user-select:none; white-space:nowrap; }
  .chip b{ font-variant-numeric:tabular-nums; color:#0f6b5e; }
  .chip:hover{ border-color:#7fbfae; }
  .chip.on{ background:#137a6c; border-color:#137a6c; color:#fff; } .chip.on b{ color:#fff; }
  .chip.zero{ opacity:.5; }
  .grid{ flex:1 1 0; min-height:120px; overflow:auto; background:#fff; border:1px solid var(--bd); border-radius:8px; }
  table{ border-collapse:collapse; width:100%; font-size:13px; }
  thead th{ position:sticky; top:0; z-index:2; background:#d9edf7; color:#1f2a37; font-weight:700; padding:6px 7px; border:1px solid #9fb6c3; white-space:nowrap; cursor:pointer; user-select:none; }
  thead th.nosort{ cursor:default; }
  thead th .ar{ font-size:10px; color:#0f6b5e; margin-left:3px; }
  tbody td{ padding:4px 7px; border:1px solid #e3e8ee; white-space:nowrap; }
  td.r{ text-align:right; font-variant-numeric:tabular-nums; } td.c{ text-align:center; } td.l{ text-align:left; }
  td.nm{ white-space:normal; min-width:200px; }
  td.neg, b.neg{ color:var(--red); font-weight:800; }
  td.dim, span.dim{ color:#9aa7b3; }
  tr.pick{ cursor:pointer; } tr.pick:hover td{ background:#f1f9f7; } tr.pick.on td{ background:#dff0eb; }
  .fl{ display:inline-block; padding:1px 7px; border-radius:10px; font-size:11.5px; font-weight:800; margin-right:3px; white-space:nowrap; }
  .fl.neg{ background:#fde8e8; color:#a12b2b; } .fl.noin, .fl.ret{ background:#ffe9d2; color:#8a4a00; }
  .fl.past, .fl.adj{ background:#fff6cf; color:#7a5c00; }
  .fl.sub{ background:#efe6fb; color:#5b3a99; } .fl.subok{ background:#e3f4ef; color:#0e6657; }   /* 서브코드에 재고 (2026-11-19) — 초록 = 합치면 음수가 풀린다 */
  .subtag{ display:inline-block; padding:0 5px; border-radius:8px; background:#efe6fb; color:#5b3a99; font-size:10.5px; font-weight:800; }
  /* 주코드 밑 서브코드 줄 (2026-11-19) */
  .gofix{ height:20px; padding:0 8px; margin-left:4px; border:1px solid #8a6fc0; border-radius:10px; background:#fff; color:#5b3a99; font-size:11.5px; font-weight:800; cursor:pointer; white-space:nowrap; vertical-align:middle; }
  .gofix:hover{ background:#5b3a99; color:#fff; }   /* 서브코드 재고 정리로 가기 (2026-11-19) */
  .maintag{ display:inline-block; padding:0 5px; border-radius:8px; background:#137a6c; color:#fff; font-size:10.5px; font-weight:800; }
  .kar{ color:#8a6fc0; font-weight:800; margin:0 4px 0 6px; }
  tr.kid td{ background:#fbf8ff; color:#4a3f66; } tr.kid.pick:hover td{ background:#f1eafc; } tr.kid.pick.on td{ background:#e6daf8; }
  tr.kid.none td{ font-size:12px; }
  tr.hasKid td{ border-bottom-color:#d9cdf0; } .fl.dead, .fl.price{ background:#eef1f4; color:#4a5a6a; }
  .foot{ flex:0 0 auto; display:flex; align-items:center; gap:12px; padding:5px 10px; margin-top:6px; background:#fff; border:1px solid var(--bd); border-radius:8px; font-size:13px; color:#48606f; }
  .foot b{ color:var(--teal); }
  /* 아래 상세 — 고른 품목의 수불 줄 + 잔고 */
  .dtl{ flex:0 0 auto; margin-top:6px; background:#fff; border:1px solid var(--bd); border-radius:8px; display:none; flex-direction:column; min-height:0; }
  .dtl.on{ display:flex; }
  .dtl .dh{ display:flex; align-items:center; gap:10px; padding:6px 10px; border-bottom:1px solid var(--bd); font-size:13px; }
  .dtl .dh b.t{ color:#0b4f43; font-size:14px; }
  .dtl .dh .why{ color:#8a2b2b; font-weight:700; }
  .dtl .dh .x{ margin-left:auto; cursor:pointer; color:#8a98a8; font-size:16px; }
  .dtl .dg{ max-height:34vh; min-height:120px; overflow:auto; }
  /* 높이 막대 (2026-11-19) — 재고 일괄조정(.agrip)과 같은 모양 */
  .fgrip{ position:relative; height:16px; display:flex; align-items:center; justify-content:center; cursor:ns-resize; user-select:none; background:#f3f6f8; border-radius:8px 8px 0 0; border-bottom:1px solid var(--bd); }
  .fgrip:hover, .fgrip.on{ background:#dff0eb; }
  .fgrip i{ display:block; width:64px; height:4px; border-radius:2px; background:#b9c6d2; pointer-events:none; }
  .fgrip:hover i, .fgrip.on i{ background:#137a6c; }
  .fgrip .bt{ position:absolute; right:4px; top:0; display:flex; gap:4px; }
  .fgrip .bt b{ height:16px; line-height:14px; padding:0 7px; font-size:11px; font-weight:700; color:#37475a; background:#fff; border:1px solid #cfd8e3; border-radius:4px; cursor:pointer; white-space:nowrap; }
  .fgrip .bt b:hover{ border-color:#137a6c; color:#137a6c; }
  .dtl tr.ng td{ background:#fff1f0; } .dtl tr.first td{ box-shadow:inset 0 2px 0 #c0392b; }
  .dtl tr.day td{ border-top:2px solid #cfd8e3; }
  .io{ font-weight:800; } .io.I{ color:#137a6c; } .io.O{ color:#b06a00; } .io.R{ color:#c0392b; } .io.A{ color:#5a6b7a; }
  .busy{ position:fixed; inset:0; background:rgba(255,255,255,.55); display:none; align-items:center; justify-content:center; z-index:50; font-weight:700; color:#0f6b5e; }
  .busy.on{ display:flex; }
  .help{ font-size:12.5px; color:#5a6b7a; background:#f3faf7; border:1px solid #cfe3dc; border-radius:8px; padding:7px 10px; margin-bottom:6px; display:none; line-height:1.6; }
  .help.on{ display:block; }
  /* ── 인쇄 (2026-11-19 사용자 「엑셀출력 및 인쇄 매출반품내역 스타일로」) — 매출 반품내역(salesReturn.jsp)과 같은 요령 : 조회줄·단추는 빼고 제목 + 표만.
       화면은 높이를 창에 묶어 표 안에서 스크롤하지만(html,body overflow:hidden) 인쇄는 전부 펼친다. 칸이 많아 A4 가로 ── */
  .ptitle{ display:none; }
  @page{ size:A4 landscape; margin:9mm; }
  @media print{
    html, body{ height:auto !important; overflow:visible !important; background:#fff; }
    .wrap{ display:block; height:auto; padding:0; }
    .noprint, .busy, .fgrip, .dtl .dh .x{ display:none !important; }
    .ptitle{ display:block; margin:0 0 6px; } .ptitle b{ font-size:17px; } .ptitle span{ font-size:12px; color:#333; margin-left:10px; }
    .grid, .dtl .dg{ overflow:visible !important; max-height:none !important; height:auto !important; min-height:0 !important; border:0; flex:none; }
    .dtl{ border:0; margin-top:10px; } .dtl .dh{ padding:4px 0; border:0; }
    table{ font-size:10.5px; } thead th{ position:static; padding:3px 4px; } tbody td{ padding:2px 4px; }
    thead{ display:table-header-group; } tr{ page-break-inside:avoid; }
    tr.pick.on td{ background:transparent; } .fl{ border:1px solid #999; }
    *{ -webkit-print-color-adjust:exact; print-color-adjust:exact; }
  }
</style>
</head>
<body>
<div class="wrap">
  <div class="ptitle" id="ptitle"></div>
  <div class="hd noprint"><h2>🔎 재고흐름조회</h2><small>수불원장을 품목마다 훑어 흐름이 이상한 품목을 찾습니다 — 조회 전용(아무것도 바뀌지 않습니다)</small>
    <button type="button" class="btn ghost" style="margin-left:auto;height:26px" onclick="document.getElementById('help').classList.toggle('on')">ℹ 유형 설명</button></div>
  <div class="help noprint" id="help">
    <b>🔴 현재고 음수</b> — 지금 재고가 0 밑입니다. 입고 등록이 빠졌거나 출고가 겹쳤습니다. &nbsp;
    <b>🟠 입고 없이 출고</b> — 입고·조정이 한 번도 없는데 출고만 있습니다(입고 누락 · 다른 코드로 입고). &nbsp;
    <b>🟠 반품 &gt; 입고</b> — 매입 반품이 입고보다 많습니다.<br>
    <b>🟡 최근 음수(회복)</b> — 지금은 회복됐지만 최근 30일(「최근 음수 기준」 칸) 안에 재고가 0 밑이었습니다. 입고를 늦게 적었거나 조정으로 맞춘 흔적입니다. &nbsp;
    <b>🟡 조정 잦음</b> — 조정이 3번 이상입니다. &nbsp;
    <b>⚪ 장기 무출고</b> — 재고가 있는데 정한 일수 넘게 출고가 없습니다. &nbsp;
    <b>⚪ 단가 없는 입고</b> — 단가 0 으로 들어온 입고가 있어 재고금액이 틀어집니다. &nbsp;
    <b>🟣 서브코드에 재고</b> — 재고가 서브코드(매칭코드) 쪽에 갈라져 있습니다. 계산은 코드마다 따로 하고 표시만 답니다 — 초록 「합치면 …」은 주코드가 음수여도 실제 부족이 아니라는 뜻입니다(서브코드 재고 정리에서 합칩니다).<br>
    잔고는 <b>하루 단위</b>로 쌓습니다 — 같은 날 출고가 입고보다 먼저 적혀 생기는 가짜 음수는 세지 않습니다. 줄을 누르면 아래에 그 품목의 수불 줄과 잔고가 나옵니다.
  </div>
  <div class="bar noprint">
    <label>기준일자</label><input type="date" id="asOf">
    <button type="button" class="btn" onclick="load()">조회</button>
    <label style="margin-left:10px" title="재고가 있는데 이 일수 넘게 출고가 없으면 「장기 무출고」">무출고 기준</label><input type="number" id="deadDays" value="90" min="7" max="999" style="width:64px;text-align:right" onchange="render()"> <span class="dim" style="font-size:12.5px">일</span>
    <label style="margin-left:6px" title="지금은 회복됐지만 최근 이 일수 안에 재고가 0 밑이었던 품목을 「최근 음수(회복)」 유형으로 잡습니다. 「현재고 음수」 목록과 표의 「음수 일수」 칸에는 영향이 없습니다">최근 음수 기준</label><input type="number" id="pastDays" value="30" min="1" max="999" style="width:58px;text-align:right" onchange="render()"> <span class="dim" style="font-size:12.5px">일</span>
    <label style="margin-left:6px" title="조정이 이 횟수 이상이면 「조정 잦음」">조정 기준</label><input type="number" id="adjMin" value="3" min="1" max="99" style="width:52px;text-align:right" onchange="render()"> <span class="dim" style="font-size:12.5px">회</span>
    <span class="sp"></span>
    <input type="search" id="q" placeholder="🔎 품목코드 / 품목명 / 매입처" style="width:260px" oninput="render()" onkeydown="if(event.key==='Escape'){ this.value=''; render(); }">
    <button type="button" class="btn ghost" onclick="xls()" title="지금 보는 유형·검색 그대로 엑셀 파일로 — 아래 수불 내역이 열려 있으면 둘째 시트로 함께">📥 엑셀</button>
    <button type="button" class="btn ghost" onclick="window.print()" title="지금 보는 목록(과 열려 있는 수불 내역)을 인쇄합니다 — A4 가로">🖨 인쇄</button>
  </div>
  <div class="chips noprint" id="chips"></div>
  <div class="grid" id="grid"><table><thead id="head"></thead><tbody id="body"><tr><td class="c dim" style="padding:26px">불러오는 중…</td></tr></tbody></table></div>
  <div class="foot noprint"><span id="cnt"></span><span class="sp" style="flex:1"></span><span class="dim">줄을 누르면 아래에 수불 내역과 잔고가 나옵니다 · 머리글을 누르면 정렬</span></div>
  <div class="dtl" id="dtl">
    <%-- 목록 ↔ 상세 높이 막대 (2026-11-19 사용자 「표시부분 막대로 늘리고 축소 가능하게」) — 상세가 열려 있을 때만 보인다.
         위로 끌면 아래 수불 상세가 커지고(목록이 줄고), 아래로 끌면 목록이 커진다. 재고 일괄조정의 목록↔이력 막대와 같은 손맛. 높이는 localStorage(konetFlowDtlH) --%>
    <div class="fgrip" id="fgrip" title="잡고 위로 끌면 아래 수불 내역이 커지고, 아래로 끌면 위 목록이 커집니다 · 더블클릭 = 처음 높이"><i></i><span class="bt"><b data-d="-1" title="목록을 줄이고 아래 수불 내역을 늘립니다">▲ 줄이기</b><b data-d="1" title="목록을 늘리고 아래 수불 내역을 줄입니다">▼ 늘리기</b></span></div>
    <div class="dh"><b class="t" id="dTit"></b><span id="dSum" class="dim"></span><span class="why" id="dWhy"></span><span id="dFix"></span><span class="x" onclick="dtlClose()" title="닫기">✕</span></div>
    <div class="dg" id="dGrid"><table><thead><tr><th class="nosort" style="width:96px">일자</th><th class="nosort" style="width:56px">구분</th><th class="nosort" style="width:80px">수량</th><th class="nosort" style="width:90px">잔고</th><th class="nosort" style="width:80px">단가</th><th class="nosort">거래처</th><th class="nosort" style="width:90px">근거</th><th class="nosort" style="width:130px">근거번호</th><th class="nosort">비고</th><th class="nosort" style="width:140px">등록일시</th></tr></thead><tbody id="dBody"></tbody></table></div>
  </div>
</div>
<div class="busy" id="busy">⏳ 재고 흐름을 훑는 중입니다…</div>

<script type="text/javascript">
var CTX='${pageContext.request.contextPath}';
var ROWS=[], _type='neg', _sort={ k:'', d:1 }, _pick='', _asOf='';
function gel(id){ return document.getElementById(id); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(v); return isFinite(x)?x:0; }
function fmt(v){ var x=n(v); return (Math.round(x*100)/100).toLocaleString('ko-KR'); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function dms(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? new Date(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8)).getTime() : 0; }
function busy(on){ gel('busy').classList.toggle('on', !!on); }
function alertBox(m){ if(window._alertBox) _alertBox(m,{icon:'⚠️'}); else alert(String(m).replace(/<[^>]*>/g,'')); }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body })
  .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); }).then(function(j){ if(!j || j.result!=='OK') throw new Error((j&&j.message)||'조회하지 못했습니다'); return j; }); }

/* 유형 정의 — 급한 순서. test(r, opt) 가 참이면 그 유형 */
var TYPES=[
  { k:'neg',   ic:'🔴', nm:'현재고 음수',        test:function(r){ return r.curQty<0; } },
  { k:'noin',  ic:'🟠', nm:'입고 없이 출고',     test:function(r){ return r.outQty>0 && r.inQty===0 && r.adjAbs===0 && r.saleRetQty===0; } },
  { k:'ret',   ic:'🟠', nm:'반품 > 입고',        test:function(r){ return r.retQty>r.inQty; } },
  /* ★과거 음수 = «최근 N일(기본 30일) 안에» 음수였던 것만 (2026-11-19 사용자 「과거 음수는 최근 30일 것만 보이게」) —
       처음엔 한 번이라도 음수였으면 다 잡아 547품목이 나왔다(연초에 입고를 늦게 적은 흔적까지). 지금 볼 것은 «요즘도 어긋나는» 품목이다.
       negAgo = 마지막으로 음수였던 날부터 기준일자까지 일수(load 가 낸다). 일수는 조회줄의 「최근 음수 기준」 칸에서 바꾼다(2026-11-19 이름 변경 — 표의 「음수 일수」 칸과 헷갈려서) */
  { k:'past',  ic:'🟡', nm:'최근 음수(회복)',    test:function(r,o){ return r.curQty>=0 && r.minBal<0 && r.lastNegDt!=='' && r.negAgo<=o.past; } },
  { k:'adj',   ic:'🟡', nm:'조정 잦음',          test:function(r,o){ return r.adjCnt>=o.adjMin; } },
  { k:'dead',  ic:'⚪', nm:'장기 무출고',        test:function(r,o){ return r.curQty>0 && r.idle>=o.dead; } },
  { k:'price', ic:'⚪', nm:'단가 없는 입고',     test:function(r){ return r.noPriceCnt>0; } },
  /* ★서브코드에 재고 (2026-11-19 사용자 「주코드 연계해서 재고흐름 한 건지 확인」 → 「표시만 다는 쪽으로」) —
       계산은 원장의 품목코드 한 줄씩 그대로 둔다(주코드로 합치지 않는다). 대신 재고가 서브코드(매칭코드) 쪽에 갈라져 있는 줄에 표시를 단다 :
       · 주코드 줄 : 그 서브코드에 재고가 남아 있다 → 「서브 재고 +14 · 합치면 +3」. 주코드가 음수인데 합치면 0 이상이면 초록(실제 부족이 아니다)
       · 서브코드 줄 : 제 재고가 0 이 아니다 → 「주코드 9904013463」
       합치는 일은 재고 관리 ▸ 서브코드 재고 정리에서 한다. 운영 실측 2026-11-19 : 연결 313 · 원장에 있는 서브코드 127 · 재고 남은 서브 6 · 합치면 풀리는 주코드 음수 3 */
  { k:'sub',   ic:'🟣', nm:'서브코드에 재고',    test:function(r){ return (r.subs&&r.subs.length>0) || (!!r.mainCd && r.curQty!==0); } }
];
function opt(){ return { dead:Math.max(1, n(gel('deadDays').value)||90), adjMin:Math.max(1, n(gel('adjMin').value)||3), past:Math.max(1, n(gel('pastDays').value)||30) }; }
function flagsOf(r, o){ var f=[]; TYPES.forEach(function(t){ if(t.test(r,o)) f.push(t.k); }); return f; }

/* 서브코드 → 주코드 지도 — 셸 재고현황(stkAliasLoad)과 같은 두 원천 : 상품코드등록의 매칭코드(extItemList) · 품목코드(매핑)의 연결(xrefList).
   못 읽어도(권한·옛 서버) 조회는 그대로 된다 — 표시만 안 붙는다. 한 번 읽으면 화면을 닫을 때까지 쓴다 */
var _sub2main=null, _subNm={}, _mainSubs={};   /* _subNm = 서브코드 이름(상품코드등록의 거래처 품명) · _mainSubs = 주코드 → [서브코드…] (2026-11-19 주코드 밑에 서브 줄) */
function mapLoad(){
  if(_sub2main) return Promise.resolve();
  var m={};
  function get(u){ return fetch(CTX+u,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
    .then(function(r){ return r.json(); }).then(function(j){ ((j&&j.data)||[]).forEach(function(o){ var sub=String(o.extItemCd||'').trim(), main=String(o.prodCd||'').trim(); if(sub && main && sub!==main && !m[sub]){ m[sub]=main; _subNm[sub]=String(o.extItemNm||''); (_mainSubs[main]=_mainSubs[main]||[]).push(sub); } }); })
    .catch(function(){}); }
  return Promise.all([get('/prod/extItemList.do'), get('/prod/xrefList.do')]).then(function(){ _sub2main=m; });
}
/* 줄마다 주코드·서브코드 재고를 붙인다 — mainCd(이 줄이 서브코드면 그 주코드) · subs(이 줄이 주코드면 재고가 남은 서브코드들) · subQty · famQty(합친 재고) */
function link(){
  var by={}; ROWS.forEach(function(r){ by[r.prodCd]=r; r.mainCd=''; r.subs=[]; r.subQty=0; });
  ROWS.forEach(function(r){ var m=_sub2main && _sub2main[r.prodCd]; if(!m || m===r.prodCd) return; r.mainCd=m;
    var M=by[m]; if(M && r.curQty!==0){ M.subs.push({ cd:r.prodCd, q:r.curQty }); M.subQty+=r.curQty; } });
  ROWS.forEach(function(r){ r.famQty=r.curQty+r.subQty;
    /* kids = 이 주코드에 딸린 서브코드 전부 — row 가 있으면 수불이 있는 코드(숫자를 보인다), 없으면 이름만 */
    r.kids=(_mainSubs[r.prodCd]||[]).map(function(cd){ return { cd:cd, nm:_subNm[cd]||'', row:by[cd]||null }; }); });
}
function sgn(v){ return (v>0?'+':'')+fmt(v); }
/* ★서브코드 재고 정리로 가기 (2026-11-19 사용자 「서브코드 재고 정리로 가기 단추 넣어줘요」) —
   셸(부모 창)의 왼쪽 메뉴 「서브코드 재고 정리」를 그대로 누른다(자주 쓰는 메뉴·메뉴 검색과 같은 길 — 화면 여는 방법이 두 벌이 되지 않게).
   어느 서브코드를 보다 갔는지는 sessionStorage('konetSubFixFocus')에 남긴다 — 그 화면이 목록을 그린 뒤 그 줄로 스크롤하고 잠깐 노랗게 표시한다.
   메뉴가 없으면(권한) 안내만 한다. 여기서는 아무것도 바꾸지 않는다 — 합치는 일은 그 화면에서 사람이 누른다 */
function goSubFix(cd, ev){
  if(ev){ ev.stopPropagation(); ev.preventDefault(); }
  try{ sessionStorage.setItem('konetSubFixFocus', String(cd||'')); }catch(e){}
  var P=null, a=null; try{ P=window.parent; a=P && P!==window && P.document.querySelector('.logi-side a.mi[data-key="subStockFix"]'); }catch(e){}
  if(!a){ alertBox('「서브코드 재고 정리」 메뉴를 찾지 못했습니다.<br>왼쪽 메뉴 재고 관리 ▸ 서브코드 재고 정리에서 직접 열어 주세요.'); return; }
  var sub=a.closest('.sub-menu'); while(sub){ if(!sub.classList.contains('open')){ sub.classList.add('open'); var head=sub.previousElementSibling; if(head && head.classList.contains('has-sub')) head.classList.add('open'); } sub=sub.parentElement ? sub.parentElement.closest('.sub-menu') : null; }
  a.click();
}
function fixBtn(cd){ return ' <button type="button" class="gofix noprint" onclick="goSubFix(\''+esc(cd).replace(/'/g,'')+'\', event)" title="서브코드 재고 정리 화면으로 갑니다 — 거기서 [0으로 조정]으로 주코드에 합칩니다(이 화면은 조회만)">정리로 가기 →</button>'; }
/* 「서브코드에 재고」 표시 글 — 주코드 줄 / 서브코드 줄 */
function subBadge(r){
  if(r.subs && r.subs.length){ var ok=(r.curQty<0 && r.famQty>=0);
    return '<span class="fl '+(ok?'subok':'sub')+'" title="서브코드에 남은 재고 : '+esc(r.subs.map(function(x){ return x.cd+' ('+sgn(x.q)+')'; }).join(', '))+' · 주코드 '+fmt(r.curQty)+' 와 합치면 '+fmt(r.famQty)
      +(ok?' — 실제 부족이 아닙니다. 재고 관리 ▸ 서브코드 재고 정리에서 합치면 음수가 풀립니다':' — 서브코드 재고 정리에서 합칠 수 있습니다')+'">서브 재고 '+sgn(r.subQty)+' · 합치면 '+fmt(r.famQty)+'</span>'+fixBtn(r.subs[0].cd); }
  return '<span class="fl sub" title="이 코드는 주코드 '+esc(r.mainCd)+' 의 서브코드(매칭코드)인데 재고가 '+fmt(r.curQty)+' 남아 있습니다 — 서브코드 재고 정리에서 주코드로 합칠 수 있습니다">주코드 '+esc(r.mainCd)+'</span>'+fixBtn(r.prodCd);
}
function load(){
  var d=gel('asOf').value||''; busy(true);
  Promise.all([post('/prod/stockFlowList.do','asOfDt='+encodeURIComponent(d)), mapLoad()]).then(function(got){ var j=got[0];
    _asOf=String(j.asOfDt||d.replace(/-/g,'')); var base=dms(_asOf);
    ROWS=(j.data||[]).map(function(r){
      var o={ prodCd:String(r.prodCd||''), prodNm:String(r.prodNm||''), vendorCd:String(r.vendorCd||''), vendorNm:String(r.vendorNm||''),
        inQty:n(r.inQty), retQty:n(r.retQty), saleRetQty:n(r.saleRetQty), outQty:n(r.outQty), adjQty:n(r.adjQty), adjAbs:n(r.adjAbs), adjCnt:n(r.adjCnt), curQty:n(r.curQty),
        minBal:n(r.minBal), negDays:n(r.negDays), negCal:n(r.negCalDays), firstNegDt:String(r.firstNegDt||''), lastNegDt:String(r.lastNegDt||''),
        lastInDt:String(r.lastInDt||''), lastOutDt:String(r.lastOutDt||''), firstDt:String(r.firstDt||''), noPriceCnt:n(r.noPriceCnt), trxCnt:n(r.trxCnt) };
      /* 무출고 일수 — 마지막 출고(없으면 첫 수불일)부터 기준일자까지 */
      var last=dms(o.lastOutDt)||dms(o.firstDt); o.idle = last ? Math.floor((base-last)/86400000) : 0;
      var ln=dms(o.lastNegDt); o.negAgo = ln ? Math.floor((base-ln)/86400000) : 99999;   /* 마지막 음수일부터 며칠 지났나 */
      return o; });
    link(); busy(false); dtlClose(); render();
  }).catch(function(e){ busy(false); gel('body').innerHTML='<tr><td class="c" style="padding:26px;color:#b23b3b">'+esc(e.message)+'</td></tr>'; });
}

function view(){
  var o=opt(), q=(gel('q').value||'').trim().toLowerCase();
  ROWS.forEach(function(r){ r.f=flagsOf(r,o); });
  var cnt={ all:0, any:0 }; TYPES.forEach(function(t){ cnt[t.k]=0; });
  var base=ROWS.filter(function(r){ if(!q) return true; return r.prodCd.toLowerCase().indexOf(q)>=0 || r.prodNm.toLowerCase().indexOf(q)>=0 || r.vendorNm.toLowerCase().indexOf(q)>=0 || r.vendorCd.toLowerCase().indexOf(q)>=0; });
  base.forEach(function(r){ cnt.all++; if(r.f.length) cnt.any++; r.f.forEach(function(k){ cnt[k]++; }); });
  var list=base.filter(function(r){ return _type==='all' ? true : (_type==='any' ? r.f.length>0 : r.f.indexOf(_type)>=0); });
  return { list:list, cnt:cnt };
}
var COLS=[
  { k:'prodCd', t:'품목코드', w:104 }, { k:'prodNm', t:'품목명' }, { k:'vendorNm', t:'매입처', w:130 },
  { k:'inQty', t:'입고', r:1, w:70 }, { k:'retQty', t:'반품', r:1, w:60 }, { k:'outQty', t:'출고', r:1, w:70 }, { k:'adjQty', t:'조정', r:1, w:86, tip:'조정 합(건수)' },
  { k:'curQty', t:'현재고', r:1, w:76 }, { k:'minBal', t:'최저 잔고', r:1, w:80, tip:'날짜순으로 쌓은 재고가 가장 낮았을 때' },
  /* 음수 일수 = 달력 일수 (2026-11-19 사용자 「음수 일수를 달력 기준 일수로」 — 처음엔 수불이 있던 날만 세어 드문 품목이 작게 나왔다). 수불일 수는 말풍선에 */
  { k:'negCal', t:'음수 일수', r:1, w:74, tip:'재고가 0 밑이었던 달력 일수 — 기준일자까지. 칸에 마우스를 올리면 그중 수불이 있던 날 수' }, { k:'firstNegDt', t:'음수 기간', w:176, tip:'처음 음수가 된 날 ~ 마지막으로 음수였던 날' },
  { k:'lastInDt', t:'최근 입고', w:92 }, { k:'lastOutDt', t:'최근 출고', w:92 }, { k:'idle', t:'무출고', r:1, w:64, tip:'마지막 출고부터 기준일자까지 일수' },
  { k:'f', t:'이상 유형', nosort:1 }
];
/* ★주코드 밑에 서브코드 줄 (2026-11-19 사용자 「여기에 주코드 서브코드 보여주게」) — 품목별재고현황의 [주]/[서브] 줄과 같은 생각.
   주코드 줄 = 품목코드 앞에 「주」 · 바로 밑에 ↳ 「서브」 줄(그 코드 자신의 입고·출고·현재고…). 수불이 없는 서브코드는 한 줄에 이름만 모아 흐리게.
   서브 줄은 검색·유형에 안 걸려도 주코드가 나오면 함께 나온다(관계를 보려는 것이라). 주코드가 목록에 있으면 그 서브 줄은 따로 한 번 더 그리지 않는다.
   숫자는 코드마다 제 것 그대로 — 합치지 않는다. 합친 값은 주코드 줄의 「서브 재고 … · 합치면 …」 표시에 있다 */
function rowHtml(r, NM, kid){
  var hasKid=!kid && r.kids && r.kids.length>0;
  var cdCell = kid ? '<span class="kar">↳</span><span class="subtag" title="위 주코드의 서브코드(매칭코드)">서브</span> '+esc(r.prodCd)
                   : (hasKid?'<span class="maintag" title="서브코드(매칭코드) '+r.kids.length+'개가 딸린 주코드">주</span> ':'')+esc(r.prodCd)+(r.mainCd?' <span class="subtag" title="주코드 '+esc(r.mainCd)+' 의 서브코드(매칭코드)">서브</span>':'');
  var flags = r.f.map(function(x){
    if(x!=='sub') return '<span class="fl '+x+'">'+esc(NM[x])+'</span>';
    return kid ? '<span class="fl sub" title="이 서브코드에 재고가 남아 있습니다 — 서브코드 재고 정리에서 주코드로 합칠 수 있습니다">재고 '+sgn(r.curQty)+' 남음</span>'+fixBtn(r.prodCd) : subBadge(r); }).join('');
  return '<tr class="pick'+(kid?' kid':'')+(hasKid?' hasKid':'')+(r.prodCd===_pick?' on':'')+'" data-cd="'+esc(r.prodCd)+'" onclick="dtlOpen(\''+esc(r.prodCd).replace(/'/g,'')+'\')">'
    +'<td>'+cdCell+'</td><td class="nm">'+esc(r.prodNm||_subNm[r.prodCd]||'')+'</td><td class="l" title="'+esc(r.vendorCd)+'">'+esc(r.vendorNm||r.vendorCd)+'</td>'
    +'<td class="r">'+fmt(r.inQty)+'</td><td class="r'+(r.retQty>r.inQty?' neg':'')+'">'+(r.retQty?fmt(r.retQty):'')+'</td><td class="r">'+fmt(r.outQty)+'</td>'
    +'<td class="r">'+(r.adjCnt?fmt(r.adjQty)+' <span class="dim">('+r.adjCnt+')</span>':'')+'</td>'
    +'<td class="r'+(r.curQty<0?' neg':'')+'"><b>'+fmt(r.curQty)+'</b></td>'
    +'<td class="r'+(r.minBal<0?' neg':'')+'">'+fmt(r.minBal)+'</td>'
    +'<td class="r"'+(r.negCal?' title="음수였던 달력 일수 '+r.negCal.toLocaleString()+'일 · 그중 수불이 있던 날 '+r.negDays+'일"':'')+'>'+(r.negCal?r.negCal.toLocaleString()+'일':'')+'</td>'
    +'<td class="c">'+(r.firstNegDt?d10(r.firstNegDt)+(r.lastNegDt&&r.lastNegDt!==r.firstNegDt?' ~ '+d10(r.lastNegDt).slice(5):''):'')+'</td>'
    +'<td class="c">'+d10(r.lastInDt)+'</td><td class="c">'+d10(r.lastOutDt)+'</td><td class="r'+(r.f.indexOf('dead')>=0?' neg':'')+'">'+(r.curQty>0||r.outQty>0?r.idle+'일':'')+'</td>'
    +'<td class="l">'+flags+'</td></tr>';
}
function kidsHtml(r, NM){
  if(!r.kids || !r.kids.length) return '';
  var h='', none=[];
  r.kids.forEach(function(k){ if(k.row) h+=rowHtml(k.row, NM, true); else none.push(k); });
  if(none.length){ var show=none.slice(0,6).map(function(k){ return esc(k.cd)+(k.nm?' <span class="dim">'+esc(k.nm)+'</span>':''); }).join(' · ');
    h+='<tr class="kid none"><td><span class="kar">↳</span><span class="subtag">서브</span></td><td class="nm" colspan="'+(COLS.length-1)+'" title="'+esc(none.map(function(k){ return k.cd+' '+k.nm; }).join('\n'))+'"><span class="dim">수불 없는 서브코드 '+none.length+'개 : </span>'+show+(none.length>6?' <span class="dim">외 '+(none.length-6)+'개</span>':'')+'</td></tr>'; }
  return h;
}
function sortBy(k){ if(_sort.k===k) _sort.d=-_sort.d; else { _sort.k=k; _sort.d=(k==='prodCd'||k==='prodNm'||k==='vendorNm')?1:-1; } render(); }
function typeGo(k){ _type=k; render(); gel('grid').scrollTop=0; }
function render(){
  var v=view(), list=v.list, c=v.cnt;
  /* 칩 */
  gel('chips').innerHTML=TYPES.map(function(t){ return '<span class="chip'+(_type===t.k?' on':'')+(c[t.k]?'':' zero')+'" onclick="typeGo(\''+t.k+'\')">'+t.ic+' '+esc(t.nm)+' <b>'+c[t.k].toLocaleString()+'</b></span>'; }).join('')
    +'<span class="chip'+(_type==='any'?' on':'')+'" onclick="typeGo(\'any\')" title="위 유형 중 하나라도 걸린 품목">이상 있는 품목 <b>'+c.any.toLocaleString()+'</b></span>'
    +'<span class="chip'+(_type==='all'?' on':'')+'" onclick="typeGo(\'all\')">전체 <b>'+c.all.toLocaleString()+'</b></span>';
  /* 정렬 — 기본 : 현재고 음수는 재고 낮은 순, 그 밖은 품목코드 */
  var k=_sort.k, d=_sort.d;
  if(!k){ if(_type==='neg'){ k='curQty'; d=1; } else if(_type==='past'){ k='minBal'; d=1; } else if(_type==='dead'){ k='idle'; d=-1; } else if(_type==='adj'){ k='adjCnt'; d=-1; } else { k='prodCd'; d=1; } }
  list.sort(function(a,b){ var x=a[k], y=b[k]; if(typeof x==='number'&&typeof y==='number') return (x-y)*d || (a.prodCd<b.prodCd?-1:1); x=String(x||''); y=String(y||''); return x<y?-d:(x>y?d:0); });
  gel('head').innerHTML='<tr>'+COLS.map(function(col){ return '<th'+(col.nosort?' class="nosort"':' onclick="sortBy(\''+col.k+'\')"')+(col.w?' style="width:'+col.w+'px"':'')+(col.tip?' title="'+esc(col.tip)+'"':'')+'>'+esc(col.t)+(_sort.k===col.k?'<span class="ar">'+(_sort.d>0?'▲':'▼')+'</span>':'')+'</th>'; }).join('')+'</tr>';
  var NM={}; TYPES.forEach(function(t){ NM[t.k]=t.nm; });
  /* 주코드가 목록에 있으면 그 서브 줄은 주코드 밑에 붙으므로 따로 그리지 않는다 (2026-11-19) */
  var inList={}; list.forEach(function(r){ inList[r.prodCd]=1; });
  var top=list.filter(function(r){ return !(r.mainCd && inList[r.mainCd]); });
  var MAX=1500, cut=top.length>MAX ? top.length-MAX : 0;
  gel('body').innerHTML = top.length ? top.slice(0,MAX).map(function(r){ return rowHtml(r, NM, false)+kidsHtml(r, NM); }).join('')
    : '<tr><td colspan="'+COLS.length+'" class="c dim" style="padding:26px">'+(ROWS.length?'이 유형에 해당하는 품목이 없습니다.':'수불 내역이 없습니다.')+'</td></tr>';
  var tn=_type==='all'?'전체':(_type==='any'?'이상 있는 품목':NM[_type]);
  gel('cnt').innerHTML='기준일자 <b>'+d10(_asOf)+'</b> · '+esc(tn)+' <b>'+list.length.toLocaleString()+'</b>품목'+(cut?' <span class="dim">(앞 '+MAX+'줄만 표시 — 검색으로 좁히세요)</span>':'')+' · 전체 '+c.all.toLocaleString()+'품목 중 이상 '+c.any.toLocaleString()+'품목';
  window._view=list; window._viewNm=tn;
  var q=(gel('q').value||'').trim();
  gel('ptitle').innerHTML='<b>[재고흐름조회 — '+esc(tn)+']</b><span>기준일자 '+d10(_asOf)+' · '+list.length.toLocaleString()+'품목'+(q?' · 검색 「'+esc(q)+'」':'')+'</span>';
}

/* ── 상세 : 고른 품목의 수불 줄 + 하루 단위 잔고 ── */
var IO={ I:'입고', O:'출고', R:'반품', A:'조정' };
function dtlClose(){ _pick=''; window._dtl=null; gel('dtl').classList.remove('on'); var on=document.querySelector('#body tr.on'); if(on) on.classList.remove('on'); }
function dtlOpen(cd){
  _pick=cd; var r=ROWS.filter(function(x){ return x.prodCd===cd; })[0]; if(!r) return;
  [].forEach.call(document.querySelectorAll('#body tr.on'), function(t){ t.classList.remove('on'); });
  [].forEach.call(document.querySelectorAll('#body tr.pick'), function(t){ if(t.getAttribute('data-cd')===cd) t.classList.add('on'); });
  gel('dtl').classList.add('on'); fgApply(); gel('dTit').textContent=cd+'  '+r.prodNm; gel('dSum').textContent=''; gel('dWhy').textContent=''; gel('dFix').innerHTML='';
  gel('dBody').innerHTML='<tr><td colspan="10" class="c dim" style="padding:16px">불러오는 중…</td></tr>';
  post('/prod/stockFlowLedger.do','prodCd='+encodeURIComponent(cd)+'&asOfDt='+encodeURIComponent(_asOf)).then(function(j){
    if(_pick!==cd) return;
    var L=j.data||[], bal=0, firstNeg=-1, days={}, h='';
    /* 하루 끝 잔고를 먼저 낸다 — 그날의 줄들은 같은 «하루 끝 잔고»로 음수 여부를 가린다 */
    var end={}, run=0; L.forEach(function(x){ var q=n(x.qty), sq=(x.ioGb==='O')?-q:q; run+=sq; end[x.trxDt]=run; });
    var prevDt=''; window._dtl={ cd:cd, nm:r.prodNm, rows:[] };
    L.forEach(function(x,i){ var q=n(x.qty), sq=(x.ioGb==='O')?-q:q; bal+=sq;
      window._dtl.rows.push({ dt:x.trxDt, io:((x.ioGb==='I'&&q<0)?'반품':(IO[x.ioGb]||x.ioGb)), sq:sq, bal:bal, up:n(x.unitPrice), ven:String(x.vendorNm||x.vendorCd||''), ref:String(x.refGb||''), refNo:String(x.refNo||''), remark:String(x.remark||''), reg:String(x.regDttm||'').slice(0,16) });
      var ng=end[x.trxDt]<0, lastOfDay=(i===L.length-1 || L[i+1].trxDt!==x.trxDt), isRet=(x.ioGb==='I'&&q<0);
      if(ng && firstNeg<0) firstNeg=i;
      h+='<tr class="'+(ng?'ng':'')+(i===firstNeg?' first':'')+(x.trxDt!==prevDt?' day':'')+'" id="dr'+i+'">'
        +'<td class="c">'+(x.trxDt!==prevDt?d10(x.trxDt):'')+'</td>'
        +'<td class="c"><span class="io '+(isRet?'R':esc(x.ioGb))+'">'+(isRet?'반품':esc(IO[x.ioGb]||x.ioGb))+'</span></td>'
        +'<td class="r">'+(sq>0?'+':'')+fmt(sq)+'</td>'
        +'<td class="r'+(lastOfDay&&bal<0?' neg':'')+'">'+(lastOfDay?'<b>'+fmt(bal)+'</b>':'<span class="dim">'+fmt(bal)+'</span>')+'</td>'
        +'<td class="r">'+(n(x.unitPrice)?fmt(x.unitPrice):(x.ioGb==='I'&&q>0?'<span class="neg" title="단가 없이 들어온 입고">0</span>':''))+'</td>'
        +'<td class="l" title="'+esc(x.vendorCd)+'">'+esc(x.vendorNm||x.vendorCd)+'</td><td class="c">'+esc(x.refGb)+'</td><td class="l">'+esc(x.refNo)+'</td>'
        +'<td class="l">'+esc(x.remark)+'</td><td class="c dim">'+esc(String(x.regDttm||'').slice(0,16))+'</td></tr>';
      prevDt=x.trxDt; });
    gel('dBody').innerHTML=h||'<tr><td colspan="10" class="c dim" style="padding:16px">수불 줄이 없습니다.</td></tr>';
    gel('dSum').textContent=L.length+'줄 · 입고 '+fmt(r.inQty)+(r.retQty?' · 반품 '+fmt(r.retQty):'')+' · 출고 '+fmt(r.outQty)+(r.adjCnt?' · 조정 '+fmt(r.adjQty)+'('+r.adjCnt+'회)':'')+' → 현재고 '+fmt(r.curQty);
    gel('dWhy').textContent = (firstNeg>=0 ? ('⚠ '+d10(L[firstNeg].trxDt)+' 부터 재고가 0 밑으로 내려갔습니다 (그날 끝 잔고 '+fmt(end[L[firstNeg].trxDt])+')') : '');
    gel('dFix').innerHTML = (r.subs&&r.subs.length) ? fixBtn(r.subs[0].cd) : ((r.mainCd && r.curQty!==0) ? fixBtn(r.prodCd) : '');
    gel('dWhy').textContent += ''
      + ((r.subs&&r.subs.length) ? ('   🟣 서브코드 '+r.subs.map(function(x){ return x.cd+' 에 '+sgn(x.q); }).join(', ')+' — 합치면 '+fmt(r.famQty)) : (r.mainCd ? ('   🟣 주코드 '+r.mainCd+' 의 서브코드입니다') : ''));
    if(firstNeg>=0){ var tr=gel('dr'+firstNeg), g=gel('dGrid'); if(tr&&g) g.scrollTop=Math.max(0, tr.offsetTop-34); } else gel('dGrid').scrollTop=0;
  }).catch(function(e){ gel('dBody').innerHTML='<tr><td colspan="10" class="c" style="padding:16px;color:#b23b3b">'+esc(e.message)+'</td></tr>'; });
}

/* ── 목록 ↔ 상세 높이 막대 (2026-11-19 사용자 「표시부분 막대로 늘리고 축소 가능하게」) ──
   목록(.grid)은 남는 높이를 전부 쓰므로(flex:1) 막대는 «아래 상세 표(#dGrid)»의 높이를 바꾼다 : 위로 끌면 상세가 커지고 목록이 그만큼 준다.
   · [▲ 줄이기]·[▼ 늘리기] = 목록 기준 120px · 더블클릭 = 처음 높이(CSS 34vh) · 고른 높이는 localStorage('konetFlowDtlH')
   · 상세는 80px 아래로, 목록은 120px 아래로 안 줄어든다(창 높이에서 위쪽 조회줄·칩·머리줄 몫을 뺀 만큼이 상한) */
var FG_K='konetFlowDtlH', FG_STEP=120, FG_MIN=80;
function fgGet(){ try{ var v=parseInt(localStorage.getItem(FG_K),10); return v>0?v:0; }catch(e){ return 0; } }
function fgPut(v){ try{ if(v>0) localStorage.setItem(FG_K, String(Math.round(v))); else localStorage.removeItem(FG_K); }catch(e){} }
function fgMax(){ var g=gel('grid'), d=gel('dGrid'); return Math.max(FG_MIN, d.offsetHeight + g.offsetHeight - 120); }   /* 목록이 120px 남을 때까지 */
function fgSet(h){ var d=gel('dGrid'); if(!d || d.offsetParent===null) return 0; h=Math.round(Math.max(FG_MIN, Math.min(fgMax(), h)));
  d.style.height=h+'px'; d.style.maxHeight='none'; d.style.minHeight='0'; return h; }
function fgReset(){ var d=gel('dGrid'); d.style.height=''; d.style.maxHeight=''; d.style.minHeight=''; fgPut(0); }
function fgApply(){ var v=fgGet(); if(v) fgSet(v); }   /* 상세를 열 때 · 창 크기가 바뀔 때 */
(function(){ var bar=gel('fgrip'); if(!bar) return;
  bar.addEventListener('mousedown', function(e){ if(e.button!==0 || (e.target.closest && e.target.closest('b'))) return; e.preventDefault();
    var sy=e.clientY, h0=gel('dGrid').offsetHeight, last=0, moved=false; bar.classList.add('on'); document.body.style.cursor='ns-resize';
    function mv(ev){ if(!moved && Math.abs(ev.clientY-sy)<2) return; moved=true; last=fgSet(h0-(ev.clientY-sy)); }
    function up(){ document.removeEventListener('mousemove', mv); document.removeEventListener('mouseup', up); bar.classList.remove('on'); document.body.style.cursor=''; if(moved) fgPut(last); }
    document.addEventListener('mousemove', mv); document.addEventListener('mouseup', up); });
  bar.addEventListener('click', function(e){ var b=e.target.closest && e.target.closest('b[data-d]'); if(!b) return; fgPut(fgSet(gel('dGrid').offsetHeight - parseInt(b.getAttribute('data-d'),10)*FG_STEP)); });
  bar.addEventListener('dblclick', function(e){ if(e.target.closest && e.target.closest('b')) return; fgReset(); });
  window.addEventListener('resize', fgApply);
})();

/* ── 엑셀 (2026-11-19 사용자 「엑셀출력 및 인쇄 매출반품내역 스타일로」) — 매출 반품내역(salesReturn.jsp sheetOf)과 같은 서식 :
     굴림 9 · 제목 17 굵게(두 줄 병합) · 조건 줄(밑줄) · 머리글 하늘(D9EDF7) · 본문 테두리 · 합계 크림(FCF8E3). 숫자는 숫자로(엑셀에서 다시 더할 수 있게).
     시트 1 = 지금 보는 유형·검색 그대로의 목록 · 시트 2 = 아래에 열어 둔 품목의 수불 내역과 잔고(열려 있을 때만) ── */
function E(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; }
function wch(v){ var w=0; String(v==null?'':v).split('').forEach(function(ch){ w+=(ch.charCodeAt(0)>255?1.8:1); }); return w; }
function serial(d){ var q=String(d).split('-'); return (Date.UTC(+q[0],+q[1]-1,+q[2])-Date.UTC(1899,11,30))/86400000; }
function dser(v){ var d=d10(v); return d ? serial(d) : ''; }
/* 표 하나 → 시트. o = { date:[날짜 칸], num:{칸:서식}, left:[왼쪽 맞춤 칸], red:function(줄배열) → 빨강으로 칠할 칸 번호들 } */
function sheetOf(title, cond, head, body, tot, o){
  var N=head.length, bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var aoa=[ [title].concat(E(N-1)), E(N), [cond].concat(E(N-1)), head ], kinds=['t','t','p','h'], W=head.map(function(h){ return wch(h)+2; });
  body.forEach(function(r){ aoa.push(r); kinds.push('row'); r.forEach(function(v,i){ if(typeof v==='string') W[i]=Math.max(W[i], Math.min(48, wch(v)+2)); }); });
  if(tot){ aoa.push(tot); kinds.push('tot'); }
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  for(var r=0;r<aoa.length;r++){ var k=kinds[r], reds=(k==='row' && o.red) ? o.red(aoa[r]) : [];
    for(var c=0;c<N;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'굴림', sz:17, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else {
        var bgc=(k==='row' && o.bg) ? o.bg(aoa[r]) : null;   /* 줄 바탕 — 서브코드 줄은 연보라 (2026-11-19) */
        st.border=box; st.fill={ fgColor:{ rgb:(k==='tot'?'FCF8E3':(bgc||'FFFFFF')) } }; if(k==='tot') st.font.bold=true;
        st.alignment.horizontal = (o.num && o.num[c]) ? 'right' : ((o.left||[]).indexOf(c)>=0 ? 'left' : 'center');
        if(k==='row' && (o.date||[]).indexOf(c)>=0 && ws[ref].t==='n') ws[ref].z='yyyy-mm-dd';
        if(ws[ref].t==='n' && o.num && o.num[c]) ws[ref].z=o.num[c];
        if(reds.indexOf(c)>=0){ st.font.color={ rgb:'C0392B' }; st.font.bold=true; }
      }
      ws[ref].s=st; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:N-1 } }, { s:{ r:2, c:0 }, e:{ r:2, c:N-1 } } ];
  ws['!cols']=W.map(function(w,i){ return { wch:((o.date||[]).indexOf(i)>=0 ? 11 : (o.num && o.num[i] ? Math.max(w, 9) : w)) }; });
  ws['!rows']=aoa.map(function(x,i){ return { hpt:(i<2?18.75:16.5) }; });
  return ws;
}
function xls(){
  if(!window.XLSX || !XLSX.utils){ alertBox('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  var list=window._view||[]; if(!list.length){ alertBox('내보낼 품목이 없습니다.'); return; }
  var NM={}; TYPES.forEach(function(t){ NM[t.k]=t.nm; });
  var tn=window._viewNm||'', q=(gel('q').value||'').trim(), o=opt(), QF='#,##0.##';
  var cond='기준일자 : '+d10(_asOf)+'   (유형 '+tn+(q?' · 검색 「'+q+'」':'')+' · 무출고 기준 '+o.dead+'일 · 최근 음수 기준 '+o.past+'일 · 조정 기준 '+o.adjMin+'회)';
  var T={ i:0, r:0, o:0, a:0, c:0 };
  /* ★화면과 같은 차례로 — 주코드 줄 다음에 그 서브코드 줄들 (2026-11-19 사용자 「엑셀에도 서브코드 줄 나오게」).
       · 맨 끝 「구분」 칸 = 주 / 서브 / 서브(수불 없음). 서브 줄은 품목코드 앞에 ↳ 를 붙이고 줄 바탕을 연보라로, 「주코드」 칸에 그 주코드.
       · 합계는 종전대로 «유형·검색에 걸린 품목»만 더한다 — 주코드 밑에 딸려 나온 서브 줄은 합계·품목 수에 넣지 않는다(화면의 건수와 같은 셈) */
  list.forEach(function(r){ T.i+=r.inQty; T.r+=r.retQty; T.o+=r.outQty; T.a+=r.adjQty; T.c+=r.curQty; });
  function line(r, kid){ var hasKid=!kid && r.kids && r.kids.length>0;
    return [(kid?'↳ ':'')+r.prodCd, (r.prodNm||_subNm[r.prodCd]||''), r.vendorNm||r.vendorCd, r.inQty, (r.retQty||''), r.outQty, (r.adjCnt?r.adjQty:''), (r.adjCnt||''), r.curQty, r.minBal, (r.negCal||''), dser(r.firstNegDt), dser(r.lastNegDt), dser(r.lastInDt), dser(r.lastOutDt), ((r.curQty>0||r.outQty>0)?r.idle:''),
            r.f.map(function(x){ return NM[x]; }).join(', '), ((r.subs&&r.subs.length)?r.subQty:''), ((r.subs&&r.subs.length)?r.famQty:''), (r.mainCd||''), (kid?'서브':(hasKid?'주':(r.mainCd?'서브':'')))]; }
  var inList={}; list.forEach(function(r){ inList[r.prodCd]=1; });
  var body=[], nKid=0;
  list.filter(function(r){ return !(r.mainCd && inList[r.mainCd]); }).forEach(function(r){
    body.push(line(r, false));
    (r.kids||[]).forEach(function(k){ nKid++;
      if(k.row) body.push(line(k.row, true));
      else body.push(['↳ '+k.cd, k.nm||'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', r.prodCd, '서브(수불 없음)']); }); });
  var ws=sheetOf('[재고흐름조회 — '+tn+']', cond,
    ['품목코드','품목명','매입처','입고','반품','출고','조정','조정 횟수','현재고','최저 잔고','음수 일수(달력)','첫 음수일','마지막 음수일','최근 입고','최근 출고','무출고(일)','이상 유형','서브코드 재고','합친 재고','주코드','구분'], body,
    ['합 계', list.length.toLocaleString()+'품목'+(nKid?' (서브코드 줄 '+nKid+'개는 합계 제외)':''), '', T.i, (T.r||''), T.o, T.a, '', T.c, '', '', '', '', '', '', '', '', '', '', '', ''],
    { date:[11,12,13,14], num:{ 3:QF, 4:QF, 5:QF, 6:QF, 7:'#,##0', 8:QF, 9:QF, 10:'#,##0', 15:'#,##0', 17:QF, 18:QF }, left:[1,2,16],
      red:function(a){ var c=[]; if(typeof a[8]==='number' && a[8]<0) c.push(8); if(typeof a[9]==='number' && a[9]<0) c.push(9); return c; },
      bg:function(a){ return String(a[20]||'').indexOf('서브')===0 && String(a[0]).indexOf('↳')===0 ? 'F3ECFB' : null; } });
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '재고흐름');
  /* 둘째 시트 — 열어 둔 품목의 수불 내역 + 잔고 */
  var D=window._dtl;
  if(D && D.rows && D.rows.length){
    var ws2=sheetOf('[수불 내역 — '+D.cd+' '+D.nm+']', '기준일자 : '+d10(_asOf)+'   (잔고는 줄마다 쌓은 값 — 음수는 빨강)',
      ['일자','구분','수량','잔고','단가','거래처','근거','근거번호','비고','등록일시'],
      D.rows.map(function(x){ return [dser(x.dt), x.io, x.sq, x.bal, (x.up||''), x.ven, x.ref, x.refNo, x.remark, x.reg]; }), null,
      { date:[0], num:{ 2:QF, 3:QF, 4:QF }, left:[5,7,8], red:function(a){ return (typeof a[3]==='number' && a[3]<0) ? [3] : []; } });
    XLSX.utils.book_append_sheet(wb, ws2, ('수불_'+D.cd).slice(0,31));
  }
  XLSX.writeFile(wb, '재고흐름조회_'+tn.replace(/[\\/:*?"<>|()> ]/g,'')+'_'+_asOf+'.xlsx');
  if(window._toast) _toast('📥 '+list.length.toLocaleString()+'품목'+(nKid?'(+서브코드 줄 '+nKid+')':'')+'을 엑셀로 저장했습니다'+(D&&D.rows&&D.rows.length?' (수불 내역 시트 포함)':''),'success');
}

(function(){ var t=new Date(), p2=function(v){ return ('0'+v).slice(-2); }; gel('asOf').value=t.getFullYear()+'-'+p2(t.getMonth()+1)+'-'+p2(t.getDate()); load(); })();
/* 셸에서 이 화면을 다시 보여도 저절로 다시 읽지 않는다 — 보던 유형·정렬·아래 상세가 그대로 있어야 한다. 새로 보려면 [조회] */
</script>
</body>
</html>
