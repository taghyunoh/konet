<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  출고현황표(데시보드2) — 사이드바 iframe 패널로 로드되는 단독 화면 (logistics_demo.jsp 의 logiFrame 패턴)
  · 상단: 데시보드1과 공통 — 제목 + 액션버튼(엑셀업로드/매출·매입 업로드/출고데이타저장/출고장별 출력, 클릭 시 데시보드1로 전환하여 실행)
          + 조회바(출고일자/조회/당일/당월) + KPI
  · 툴바: 데시보드1과 공통 — 사업장 찾기 / 줌 / 전체화면·기본화면 / 출고장 접기·펼치기 / 품목·출고장 추가·초기화(데시보드1로 위임) / 사업장 보기
          — 합계맨앞 체크박스는 두지 않음(합계·소계는 항상 앞쪽(상단) 고정 배열)
  · 본문: 좌측 출고장 + 우측 내용(사업장·품목명·품목코드·출고수량)을 한 그리드(단일 표)로 표시
          — 맨 위 전체 합계 행, 출고장 블록마다 소계 행을 상단에 표시. 출고장 셀/소계행 클릭으로 개별 접기·펼치기
  · 하단 출고내역·재고(당월출고 이하 데모행)는 표시하지 않음
  · 데이터: /shipout/selectShipoutMst.do (단일 출고일자 활성배치) — 데시보드1과 동일 소스
--%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>출고현황표(데시보드2)</title>
<style>
  :root { --teal:#1f9b8e; --teal-dk:#178074; --bd:#dfe6e3; --bg:#f4f8f7; }
  * { box-sizing:border-box; }
  html, body { height:100%; }
  body { margin:0; background:var(--bg); font-family:"Malgun Gothic","맑은 고딕",sans-serif; color:#10161d; font-weight:700; }
  b, th, h2 { font-weight:900; }

  /* 화면(iframe) 높이를 세로로 꽉 채움 — 그리드가 남는 공간을 모두 차지(해상도 커져도 하단 빈공간 없음) */
  .d2-wrap { padding:18px 24px 12px; height:100vh; display:flex; flex-direction:column; }
  .d2-head, .d2-topbar { flex:0 0 auto; }
  .d2-head { display:flex; align-items:center; justify-content:space-between; gap:10px; flex-wrap:wrap; margin-bottom:14px; }
  .d2-head h2 { margin:0; font-size:20px; color:#1f2a37; }
  .d2-head .sub { font-size:13px; color:#37475a; margin-top:4px; }
  .d2-head .actions { display:flex; gap:8px; flex-wrap:wrap; }
  .badge { display:inline-block; background:#e3f4ef; color:#137a6c; border:1px solid #b9e6dd; border-radius:11px; padding:1px 10px; font-size:11.5px; vertical-align:middle; }

  .btn-teal { background:var(--teal); color:#fff; border:none; border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; font-weight:700; }
  .btn-teal:hover { background:var(--teal-dk); }
  .btn-line { background:#fff; color:#37475a; border:1px solid var(--bd); border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; font-weight:700; }
  .btn-line:hover { background:#eef3f2; }

  /* 상단 조회바 + KPI (데시보드1 동일 스타일) */
  .d2-topbar { display:flex; align-items:center; justify-content:space-between; gap:14px; flex-wrap:wrap;
               background:#fff; border:1px solid var(--bd); border-left:4px solid var(--teal); border-radius:10px; padding:10px 16px; margin-bottom:14px; }
  .d2-topbar .tb-left { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
  .d2-topbar label { font-size:13px; color:#37475a; }
  .d2-topbar input[type=date] { height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 10px; font-size:13px; cursor:pointer; background:#fff; font-weight:700; }
  .d2-topbar input[type=date]:hover { border-color:var(--teal); }
  .d2-topbar .btn-teal, .d2-topbar .btn-line { padding:5px 14px; }
  .d2-info { font-size:12px; color:#6b7a89; flex:1 1 200px; min-width:160px; line-height:1.4; }
  .d2-srcbadge { display:inline-block; background:#eef3f2; color:#37475a; border:1px solid var(--bd); border-radius:11px; padding:1px 10px; font-size:11.5px; margin-right:6px; }
  .d2-srcbadge.up { background:#e3f4ef; color:#137a6c; border-color:#b9e6dd; }
  .tb-stats { display:flex; gap:8px; flex-wrap:wrap; }
  .tb-stats .st { background:var(--bg); border:1px solid var(--bd); border-radius:8px; padding:5px 14px; text-align:center; min-width:92px; }
  .tb-stats .st-l { display:block; font-size:11px; color:#6b7a89; }
  .tb-stats .st-v { display:block; font-size:18px; font-weight:800; color:#1f2a37; line-height:1.25; }

  /* 툴바 (데시보드1 공통) */
  /* 좌→우로 채우되 폭 부족 시 다음 줄로 내려감(데시보드1처럼). overflow:visible 이라야 드롭다운이 잘리지 않고 제자리에 뜸 */
  .d2-toolbar { display:flex; align-items:center; justify-content:flex-start; gap:8px; flex-wrap:wrap; overflow:visible; margin-bottom:12px; }
  .d2-toolbar .tl, .d2-toolbar .tr { display:flex; gap:6px; align-items:center; flex-wrap:nowrap; flex:0 0 auto; }
  .d2-toolbar .tm { margin:0; flex:0 0 auto; }
  .d2-toolbar > * { flex:0 0 auto; }
  /* 대표출고장(물류센터) 다중선택 콤보 — 드롭다운 체크박스(하나 이상 선택 조회) */
  .d2-toolbar .tm { position:relative; display:flex; align-items:center; }
  #d2DcBtn { min-width:150px; display:flex; align-items:center; justify-content:space-between; gap:6px; text-align:left; }
  #d2DcBtn .arr { margin-left:auto; flex:0 0 auto; color:#178074; }
  .dc-pop { display:none; position:absolute; top:38px; left:0; z-index:60; background:#fff; border:1px solid var(--bd);
            border-radius:8px; box-shadow:0 6px 18px rgba(31,42,55,.18); padding:8px 6px; min-width:220px; max-height:320px; overflow-y:auto; }
  .dc-pop.open { display:block; }
  .dc-pop label { display:flex; align-items:center; gap:7px; padding:6px 10px; font-size:12.5px; color:#37475a; cursor:pointer; border-radius:6px; }
  .dc-pop label:hover { background:#eef3f2; }
  .dc-pop label.all { color:#178074; border-bottom:1px dashed var(--bd); border-radius:6px 6px 0 0; margin-bottom:4px; }
  .dc-pop label.on { color:#0e6657; background:#e3f4ef; }
  .d2-toolbar label { font-size:13px; color:#37475a; font-weight:700; }
  .d2-toolbar input[type=text] { height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; width:130px; font-weight:700; }
  .d2-toolbar select { height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; font-weight:700; max-width:150px; }
  .d2-toolbar .btn-teal, .d2-toolbar .btn-line { padding:5px 11px; font-size:13px; }
  .d2-toolbar .zoomlbl { min-width:42px; text-align:center; font-size:13px; color:var(--teal-dk); font-weight:700; }
  .d2-toolbar .sep { padding-left:8px; margin-left:2px; border-left:1px solid var(--bd); display:inline-flex; gap:6px; align-items:center; }
  /* 접기/펼치기 라벨 길이가 달라도 폭 고정 — 줄바꿈 위치가 밀려 버튼이 이동하는 현상 방지 */
  #d2BtnZoneToggle { min-width:112px; text-align:center; }

  /* 본문: 출고장 + 내용 한 그리드 — 남는 세로 공간을 모두 차지(flex 채움) */
  .card { background:#fff; border:1px solid var(--bd); border-radius:10px; padding:14px 16px; flex:1 1 auto; display:flex; flex-direction:column; min-height:0; }
  .card .d2-toolbar { flex:0 0 auto; }
  .card.d2-full { position:fixed; inset:0; z-index:999; border-radius:0; overflow:auto; }
  .card.d2-full .d2-scroll { flex:1 1 auto; }
  /* 그리드 스크롤 영역 = 남는 높이 전부. 데이터가 적으면 표가 그만큼만 차지(하단 빈공간은 카드 배경으로 채워짐) */
  .d2-scroll { flex:1 1 auto; min-height:0; overflow:auto; border:1px solid var(--bd); border-radius:8px; }
  /* 그리드 글자체 — 기준 13px, 그룹 12.5px, 출고장명 weight 600 */
  table.d2-tb { width:100%; border-collapse:separate; border-spacing:0; font-size:13px; }
  table.d2-tb th, table.d2-tb td { border-bottom:1px solid var(--bd); border-right:1px solid var(--bd); padding:6px 8px; text-align:center; background:#fff; }
  table.d2-tb th:first-child, table.d2-tb td:first-child { border-left:none; }
  table.d2-tb thead th { position:sticky; top:0; z-index:3; background:var(--teal); color:#fff; font-weight:800; font-size:13px; border-bottom:2px solid var(--teal-dk); }
  table.d2-tb td.txt-l { text-align:left; }
  table.d2-tb td.num { text-align:right; }
  /* 출고장 셀(좌측 rowspan) — 데시보드1의 td.stick 속성(#f4f8f7 / teal / weight 600) + 클릭으로 접기/펼치기 */
  table.d2-tb td.zone { background:#f4f8f7; color:#178074; font-weight:600; text-align:left; vertical-align:top; min-width:170px; position:sticky; left:0; z-index:2; cursor:pointer; }
  table.d2-tb td.zone:hover { background:#eef3f2; }
  table.d2-tb td.zone .zcaret { display:inline-block; width:12px; color:#1f9b8e; font-size:10px; }
  table.d2-tb td.zone .z-dlv { color:#c47f17; font-weight:700; font-size:inherit; margin-left:4px; }
  /* 전체 합계(맨 위) — 데시보드1 tr.ztot 속성 */
  table.d2-tb tr.tot td { background:#11161d; color:#fff; font-weight:700; border-bottom:2px solid #0e1620; }
  /* 물류센터 대표그룹 행 — 데시보드1 tr.lgrp 속성 (▼ 그룹 헤더): 11.5px / weight 700 / teal */
  table.d2-tb tr.grp { cursor:pointer; }
  table.d2-tb tr.grp td { background:#eef3f2; color:#178074; font-weight:700; font-size:12.5px; text-align:left; }
  table.d2-tb tr.grp td:first-child { background:#e3efec; position:sticky; left:0; z-index:2; }
  table.d2-tb tr.grp:hover td { background:#dcefe9; }
  table.d2-tb tr.grp td .zcaret { display:inline-block; width:12px; color:#1f9b8e; font-size:10px; }
  /* 물류센터 합계 행 — 데시보드1 tr.lsub 속성 */
  table.d2-tb tr.gsub td { background:#eaf5f2; color:#137a6c; font-weight:700; text-align:left; }
  table.d2-tb tr.gsub td:first-child { background:#dcefe9; position:sticky; left:0; z-index:2; }
  table.d2-tb tr.gsub td.num { text-align:right; }
  /* 출고장 소계(블록 상단) */
  table.d2-tb tr.sub td { background:#eef3f2; font-weight:700; color:#0e6657; }
  table.d2-tb tbody tr.item:nth-child(even) td { background:#fbfdfc; }
  table.d2-tb tbody tr.item td.zone, table.d2-tb tr.sub td.zone { background:#e9f5f2; }
  /* 사업장·품목명 — 데시보드1과 동일한 본문 글자체(weight 600) */
  table.d2-tb tr.item td.txt-l { font-weight:600; color:#1f2a37; }
  .d2-empty { padding:38px 20px; text-align:center; color:#6b7a89; font-size:13.5px; }
  .note { font-size:12px; color:#6b7a89; margin-top:8px; }

  /* 토스트 */
  .d2-toast { position:fixed; left:50%; bottom:28px; transform:translateX(-50%); background:#1f2a37; color:#fff; border-radius:8px; padding:10px 18px; font-size:13px; z-index:9999; display:none; max-width:80vw; }
</style>
</head>
<body>
<div class="d2-wrap">

  <!-- 상단 공통 (데시보드1과 동일 구성 — 버튼은 데시보드1로 전환하여 실행) -->
  <div class="d2-head">
    <div>
      <h2>출고현황표 <span class="badge">데시보드2 · 출고장별 보기</span></h2>
      <div class="sub">발주현황표(엑셀)를 업로드하면 <b>사업장·품목별 출고량</b> 과 <b>출고장별 수량</b> 이 자동 작성됩니다.</div>
    </div>
    <div class="actions">
      <button class="btn-teal" onclick="d2Go('upload')" title="데시보드1로 이동하여 발주현황표 엑셀을 업로드합니다">📤 발주현황표 엑셀 업로드</button>
      <button class="btn-line" onclick="d2Go('sales')" title="데시보드1로 이동하여 매출금액 엑셀을 업로드합니다">💰 매출금액 업로드</button>
      <button class="btn-line" onclick="d2Go('cost')" title="데시보드1로 이동하여 매입금액 엑셀을 업로드합니다">🧾 매입금액 업로드</button>
      <button class="btn-line" onclick="d2Go('save')" title="데시보드1로 이동하여 출고데이타를 저장합니다">💾 출고데이타저장</button>
      <button class="btn-line" onclick="d2Go('zoneprint')" title="데시보드1로 이동하여 출고장별 엑셀을 출력합니다">🏷️ 출고장별 출력</button>
    </div>
  </div>

  <!-- 조회바 + KPI (데시보드1 유지) -->
  <div class="d2-topbar">
    <div class="tb-left">
      <span style="font-size:20px">📅</span>
      <label>출고일자</label>
      <input type="date" id="d2DateFrom" onchange="d2Load()" onclick="d2OpenCal(this)" onfocus="d2OpenCal(this)" title="클릭하여 달력 선택">
      <span style="color:#9aa7b3">~</span>
      <input type="date" id="d2DateTo" onchange="d2Load()" onclick="d2OpenCal(this)" onfocus="d2OpenCal(this)" title="클릭하여 달력 선택">
      <button class="btn-teal" onclick="d2Load()" title="선택한 출고일자의 데이터를 DB에서 다시 조회합니다">🔍 조회</button>
      <button class="btn-line" id="d2BtnToday" onclick="d2Today()">당일</button>
      <button class="btn-line" id="d2BtnMonth" onclick="d2Month()">당월</button>
    </div>
    <span id="d2Info" class="d2-info"></span>
    <div class="tb-stats">
      <div class="st"><span class="st-l"><span id="d2KpiPrefix">당일</span> 출고품목</span><span class="st-v" id="d2KpiItem">0</span></div>
      <div class="st"><span class="st-l">출고수량(BOX)</span><span class="st-v" id="d2KpiQty">0</span></div>
      <div class="st"><span class="st-l">출고장 수</span><span class="st-v" id="d2KpiZone">0</span></div>
      <div class="st"><span class="st-l">사업장</span><span class="st-v" id="d2KpiBiz">0</span></div>
    </div>
  </div>

  <!-- 출고장 + 내용 한 그리드 (맨 위 전체 합계, 출고장별 소계 상단) -->
  <div class="card" id="d2Card">
    <!-- 툴바 (데시보드1 공통 — 합계맨앞 없음) -->
    <div class="d2-toolbar">
      <div class="tl">
        <label>🔎 사업장 찾기</label>
        <input id="d2BizFind" type="text" list="d2BizFindList" placeholder="사업장명 입력"
               oninput="d2BizFindSet(this.value)" onkeydown="if(event.keyCode===13){d2BizFindSet(this.value);}">
        <datalist id="d2BizFindList"></datalist>
        <label>📦 품목 찾기</label>
        <input id="d2ItemFind" type="text" placeholder="품목명/품목코드/사업장" autocomplete="off" title="사업장명·품목명·품목코드 전체에서 부분일치(LIKE)로 찾습니다. 공백으로 여러 단어 입력 시 모두 포함된 행만 표시"
               oninput="d2ItemFindSet(this.value)" onkeydown="if(event.keyCode===13){d2ItemFindSet(this.value);}">
        <button class="btn-line" onclick="d2FindClear()" title="사업장/품목 찾기 해제(전체 보기)">전체</button>
        <span class="sep">
          <button class="btn-line" onclick="d2ZoomOut()" title="축소">🔍－</button>
          <span class="zoomlbl" id="d2ZoomLbl">100%</span>
          <button class="btn-line" onclick="d2ZoomIn()" title="확대">🔍＋</button>
          <button class="btn-line" id="d2BtnFull" onclick="d2FullExpand()" title="출고현황표를 화면 전체로 덮기">⛶ 전체화면</button>
          <button class="btn-line" id="d2BtnBasic" onclick="d2FullExit()" title="기본 화면 + 원래 크기로">⟲ 기본화면</button>
        </span>
      </div>
      <!-- 대표출고장(물류센터) 다중선택 콤보 — 드롭다운에서 하나 이상 체크 조회 -->
      <div class="tm" id="d2DcWrap">
        <button class="btn-line" id="d2DcBtn" onclick="d2DcOpen(event)" title="대표출고장(물류센터)을 하나 이상 선택하여 조회합니다"><span>🏬 대표출고장:</span><span class="arr"><b id="d2DcLbl" style="color:#178074">전체</b> ▾</span></button>
        <div class="dc-pop" id="d2DcPop"></div>
      </div>
      <div class="tr">
        <button class="btn-line" id="d2BtnZoneToggle" onclick="d2ToggleAllZones()">－ 출고장 접기</button>
        <span style="position:relative" id="d2GordWrap">
          <button class="btn-line" onclick="d2GordOpen(event)" title="출고장 그룹(물류센터) 표시 순서를 지정합니다. 브라우저에 저장되어 수정하지 않는 한 유지됩니다">⚙ 그룹순서</button>
          <div class="dc-pop" id="d2GordPop" style="left:auto; right:0; min-width:260px"></div>
        </span>
        <%-- [제외 2026-07-02] 품목 추가/출고장 추가/출고장 초기화 — 편집 기능은 데시보드1에서만. 재노출 시 주석 해제
        <button class="btn-teal" onclick="d2Go('additem')" title="데시보드1로 이동하여 품목을 추가합니다">＋ 품목 추가</button>
        <button class="btn-line" onclick="d2Go('addzone')" title="데시보드1로 이동하여 출고장을 추가합니다">＋ 출고장 추가</button>
        <button class="btn-line" style="color:#c0392b; border-color:#e3b4ae" onclick="d2Go('clear')" title="데시보드1로 이동하여 출고장 데이터를 초기화합니다">🔄 출고장 초기화</button>
        --%>
        <label style="margin-left:6px">사업장 보기</label>
        <select id="d2BizSel" onchange="d2Render()"></select>
      </div>
    </div>
    <div class="d2-scroll">
      <table class="d2-tb" id="d2Tbl"></table>
    </div>
    <%-- [제외 2026-07-02] 하단 안내문 — 재노출 시 주석 해제
    <div class="note">※ 좌측 <b>출고장</b> 칸(또는 소계 행)을 클릭하면 해당 출고장을 접거나 펼칩니다. 맨 위 행은 <b>전체 출고장 합계</b>, 각 출고장 첫 행은 해당 출고장 <b>소계</b>입니다.</div>
    --%>
  </div>

</div>
<div class="d2-toast" id="d2Toast"></div>

<script type="text/javascript">
  var CTX='${pageContext.request.contextPath}';
  var D2_DATA=[];            // {code,item,biz,bizCode,dc,zone,qty,dlvDt,date}
  var D2_BIZI={};            // TBL_BIZI_MST {사업장코드:대표사업장명} — 사업장 유니크 카운트용(데시보드1 ssBiziMap 동일)
  var D2_SRC='', D2_UP=false;
  var D2_COLL={};            // 접힌 출고장 { zone:1 }
  var D2_GCOLL={};           // 접힌 물류센터 그룹 { dc:1 }
  var D2_ZOOM=100;
  var D2_FIND='';            // 사업장 찾기(부분일치)
  var D2_IFIND='';           // 품목 찾기(품목명/품목코드 부분일치)
  var D2_DCSEL={};           // 선택된 대표출고장(물류센터) { dc:1 } — 비어있으면 전체
  // 출고장 그룹(물류센터) 표시 순서 — 데시보드1과 공유(localStorage 'logiGroupOrder', 물류센터명 배열).
  // 한쪽에서 정한 순서가 다른 쪽에도 동일 적용. 미지정 그룹은 ㄱㄴㄷ순 뒤에 붙음
  var D2_GORD=[];
  function d2GordLoad(){ try{ D2_GORD=JSON.parse(localStorage.getItem('logiGroupOrder')||'[]')||[]; }catch(e){ D2_GORD=[]; } return D2_GORD; }
  function d2GordSave(){ try{ localStorage.setItem('logiGroupOrder', JSON.stringify(D2_GORD)); }catch(e){} }
  d2GordLoad();

  function d2Pad(n){ return (n<10?'0':'')+n; }
  var D2_TODAY=(function(){ var d=new Date(); return d.getFullYear()+'-'+d2Pad(d.getMonth()+1)+'-'+d2Pad(d.getDate()); })();
  function d2Num(n){ return (Math.round(n||0)).toLocaleString(); }
  function d2Esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function d2Set(id,html){ var e=document.getElementById(id); if(e) e.innerHTML=html; }
  function d2OpenCal(el){ try{ if(el && el.showPicker) el.showPicker(); }catch(e){} }
  function d2Toast(html){
    var t=document.getElementById('d2Toast'); if(!t) return;
    t.innerHTML=html; t.style.display='block';
    clearTimeout(t._tm); t._tm=setTimeout(function(){ t.style.display='none'; }, 3200);
  }

  // ── 상단/툴바 액션버튼: 데시보드1 기능을 화면 전환 없이 그 자리에서 실행 (동일 출처 iframe)
  //    · 미리보기 모달(ssPvOverlay 등)은 숨겨진 데시보드1 패널 안에 있어 부모 body 로 옮겨서 표시(fixed 오버레이라 화면은 데시보드2 유지)
  //    · 실행 전 데시보드1의 출고일자를 데시보드2 선택일자와 동기화(단일 일자일 때)
  function d2Go(act){
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.logiGo) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    try{
      var f=(document.getElementById('d2DateFrom')||{}).value||'';
      var t=(document.getElementById('d2DateTo')||{}).value||'';
      if(f && f===t){
        var df=p.document.getElementById('ssDateFrom'), dt=p.document.getElementById('ssDateTo');
        if(df && dt && (df.value!==f || dt.value!==f)){ df.value=f; dt.value=f; if(p.ssLoadShipoutFromDB) p.ssLoadShipoutFromDB(); }
      }
    }catch(e){}
    function lift(id){ try{ var el=p.document.getElementById(id); if(el && el.parentNode!==p.document.body) p.document.body.appendChild(el); }catch(e){} }
    try{
      if(act==='upload'){ lift('ssPvOverlay'); var e=p.document.getElementById('ssFile'); if(e) e.click(); }
      else if(act==='sales'){ lift('ssSalesPvOverlay'); var e2=p.document.getElementById('ssSalesFile'); if(e2) e2.click(); }
      else if(act==='cost'){ lift('ssCostPvOverlay'); var e3=p.document.getElementById('ssCostFile'); if(e3) e3.click(); }
      else if(act==='save' && p.ssSaveData) p.ssSaveData();
      else if(act==='zoneprint') d2DownloadByZone();
      else if(act==='additem' && p.ssAddItem) p.ssAddItem();
      else if(act==='addzone' && p.ssAddZone) p.ssAddZone();
      else if(act==='clear' && p.ssClearAll) p.ssClearAll();
    }catch(e){}
  }
  // ── 출고장별 엑셀 출력 — 데시보드2 그리드 그대로 출력 (TBL_BIZI_MST 무시, 사업장명[코드] 표시, 현재 필터 반영)
  //    엑셀 라이브러리는 부모(데시보드1)의 ssLoadStyleXlsx/XLSX 재사용. 레이아웃·색상은 데시보드1 출고장별 출력과 동일
  function d2DownloadByZone(){
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.ssLoadStyleXlsx) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    p.ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || p.XLSX;
      var styled = !!XLSXS;
      if(!LIB){ d2Toast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var ag=d2Aggregate();
      var from=(document.getElementById('d2DateFrom')||{}).value||'';
      var to=(document.getElementById('d2DateTo')||{}).value||'';
      var dlab=(from&&from===to)?from:(from+' ~ '+to);

      var COLS=5, aoa=[], merges=[], meta=[];
      function mergeRow(ri,e){ merges.push({s:{r:ri,c:0}, e:{r:ri,c:(e==null?COLS-1:e)}}); }
      function push(row,ty,mEnd){ aoa.push(row); meta.push(ty); if(mEnd!=null) mergeRow(aoa.length-1,mEnd); }
      push(['출고장별 출고현황'],'title',COLS-1);
      push(['출고일자  '+dlab],'date',COLS-1);
      push([],'blank');

      // 그리드와 동일한 순서: 물류센터(ko) → 출고장(ko), 출고량 있는 품목만
      var zonesSorted=ag.zoneOrder.slice().sort(function(a,b){ return a.localeCompare(b,'ko'); });
      var zonesWithItems=zonesSorted.filter(function(zn){ return Object.keys(ag.zones[zn].rows).length>0; });
      var made=0, grand=0;
      zonesWithItems.forEach(function(zn){
        var z=ag.zones[zn];
        var keys=Object.keys(z.rows).sort(function(a,b){
          var A=z.rows[a],B=z.rows[b];
          return A.biz.localeCompare(B.biz,'ko')||A.name.localeCompare(B.name,'ko');
        });
        var dla=Object.keys(z.dlv).sort().filter(function(d){ return from && d!==from; });
        var dl=dla.length?('발주일자 '+dla.join(', ')):'';
        push(['▣ '+zn+' 출고장   (품목 '+keys.length+'종 · 출고 '+d2Num(z.tot)+(dl?(' · '+dl):'')+')'],'zone',COLS-1);
        push(['No','사업장','품목명','품목코드','출고수량'],'head');
        keys.forEach(function(k,ix){ var r=z.rows[k]; push([ix+1, r.biz, r.name, r.code, r.qty],'item'); });
        push(['소계','','','',z.tot],'sub',COLS-2);
        push([],'blank');
        grand+=z.tot; made++;
      });
      if(!made){ d2Toast('⚠️ 출고량이 있는 출고장이 없습니다.'); return; }
      push(['전체 합계','','','',grand],'grand',COLS-2);

      var ws=LIB.utils.aoa_to_sheet(aoa);
      ws['!cols']=[{wch:5},{wch:26},{wch:44},{wch:14},{wch:11}];
      ws['!merges']=merges;

      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'A9B7B1'}};   // 셀 구분선 — 살짝 진하게
        var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          title:{ fill:{fgColor:{rgb:'178074'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          date:{ font:{color:{rgb:'1F2A37'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          zone:{ fill:{fgColor:{rgb:'1F9B8E'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          head:{ fill:{fgColor:{rgb:'E3F4EF'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          itemCB:{ font:{color:{rgb:'000000'}}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemN:{ font:{color:{rgb:'1F2A37'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          subL:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'37475A'},bold:true}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          subN:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'137A6C'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          grandL:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grandN:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:14}, alignment:{horizontal:'right',vertical:'center'} }
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rows=[];
        meta.forEach(function(ty,r){
          var h=null;
          if(ty==='title'){ put(r,0,S.title); h=26; }
          else if(ty==='date'){ put(r,0,S.date); h=24; }
          else if(ty==='zone'){ put(r,0,S.zone); h=22; }
          else if(ty==='head'){ for(var c=0;c<COLS;c++) put(r,c,S.head); h=20; }
          else if(ty==='item'){ put(r,0,S.itemCB); put(r,1,S.itemL); put(r,2,S.itemL); put(r,3,S.itemCB); put(r,4,S.itemN); }
          else if(ty==='sub'){ for(var c2=0;c2<COLS-1;c2++) put(r,c2,S.subL); put(r,COLS-1,S.subN); h=19; }
          else if(ty==='grand'){ for(var c3=0;c3<COLS-1;c3++) put(r,c3,S.grandL); put(r,COLS-1,S.grandN); h=22; }
          rows.push(h!=null?{hpt:h}:{});
        });
        ws['!rows']=rows;
      }

      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, '출고장별');
      LIB.writeFile(wb, '출고장별_'+(from||'')+((to&&to!==from)?'~'+to:'')+'.xlsx');
      d2Toast('📥 출고장별 엑셀 저장 완료 · 출고장 '+made+'개 · 출고일자 '+dlab);
    });
  }

  // 업로드/저장 후 데시보드2로 돌아와 클릭하면(포커스 복귀) 자동 재조회 — 최신 데이터 반영 (3초 스로틀)
  var _d2FocusTm=0;
  window.addEventListener('focus', function(){
    var now=new Date().getTime();
    if(now-_d2FocusTm<3000) return;
    _d2FocusTm=now;
    if(D2_UP || D2_SRC) d2Load();
  });

  // ── 대표출고장(물류센터) 다중선택 콤보 — 체크 토글, 전체 클릭 시 선택 해제
  function d2DcToggle(g){ if(D2_DCSEL[g]) delete D2_DCSEL[g]; else D2_DCSEL[g]=1; d2Render(); }
  function d2DcAllSel(){ D2_DCSEL={}; d2Render(); }
  function d2DcOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('d2DcPop'); if(p) p.classList.toggle('open'); }
  document.addEventListener('click', function(e){
    [['d2DcWrap','d2DcPop'],['d2GordWrap','d2GordPop']].forEach(function(pair){
      var w=document.getElementById(pair[0]), p=document.getElementById(pair[1]);
      if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
    });
  });

  // ── 출고장 그룹(물류센터) 순서 설정 — ▲▼로 이동, localStorage 저장(수정 전까지 고정)
  function d2GordOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('d2GordPop'); if(p) p.classList.toggle('open'); }
  function d2GordMove(g, dir){
    var base=(window._d2GOrderNow||[]).slice();     // 현재 화면 표시 순서 기준으로 스왑
    var i=base.indexOf(g), j=i+dir;
    if(i<0 || j<0 || j>=base.length) return;
    var tmp=base[i]; base[i]=base[j]; base[j]=tmp;
    D2_GORD=base; d2GordSave(); d2Render();
  }
  function d2GordReset(){ D2_GORD=[]; d2GordSave(); d2Render(); }
  // 데시보드1(부모)에서 순서를 바꾸면 즉시 반영 (같은 출처 localStorage 공유)
  window.addEventListener('storage', function(e){ if(e.key==='logiGroupOrder'){ d2GordLoad(); d2Render(); } });

  // ── 사업장/품목 찾기 / 줌 / 전체화면
  function d2BizFindSet(v){ D2_FIND=(''+(v||'')).trim(); d2Render(); }
  function d2ItemFindSet(v){ D2_IFIND=(''+(v||'')).trim(); d2Render(); }
  function d2FindClear(){
    D2_FIND=''; D2_IFIND='';
    var e=document.getElementById('d2BizFind'); if(e) e.value='';
    var e2=document.getElementById('d2ItemFind'); if(e2) e2.value='';
    d2Render();
  }
  function d2ApplyZoom(){ var t=document.getElementById('d2Tbl'); if(t) t.style.zoom=(D2_ZOOM/100); d2Set('d2ZoomLbl', D2_ZOOM+'%'); }
  function d2ZoomIn(){ if(D2_ZOOM<200) D2_ZOOM+=10; d2ApplyZoom(); }
  function d2ZoomOut(){ if(D2_ZOOM>40) D2_ZOOM-=10; d2ApplyZoom(); }
  function d2FullExpand(){ document.getElementById('d2Card').classList.add('d2-full'); }
  function d2FullExit(){ document.getElementById('d2Card').classList.remove('d2-full'); D2_ZOOM=100; d2ApplyZoom(); }

  // ── 출고장 접기/펼치기 (개별 + 물류센터 그룹 + 전체)
  function d2ToggleZone(zn){ if(D2_COLL[zn]) delete D2_COLL[zn]; else D2_COLL[zn]=1; d2Render(); }
  function d2ToggleGroup(g){ if(D2_GCOLL[g]) delete D2_GCOLL[g]; else D2_GCOLL[g]=1; d2Render(); }
  function d2ToggleAllZones(){
    var ag=d2Aggregate();
    var zs=ag.zoneOrder.filter(function(zn){ return Object.keys(ag.zones[zn].rows).length>0; });
    var allColl = zs.length>0 && zs.every(function(zn){ return !!D2_COLL[zn]; });
    D2_COLL={}; D2_GCOLL={};
    if(!allColl) zs.forEach(function(zn){ D2_COLL[zn]=1; });
    d2Render();
  }

  function d2Today(){ document.getElementById('d2DateFrom').value=D2_TODAY; document.getElementById('d2DateTo').value=D2_TODAY; d2Load(); }
  function d2Month(){
    var d=new Date(), y=d.getFullYear(), m=d.getMonth(), last=new Date(y,m+1,0).getDate();
    document.getElementById('d2DateFrom').value=y+'-'+d2Pad(m+1)+'-01';
    document.getElementById('d2DateTo').value=y+'-'+d2Pad(m+1)+'-'+d2Pad(last);
    d2Render();   // 당월=기간 모드 — 단일일자 DB조회 대상 아님(현재 데이터 렌더)
  }

  // ── 대표사업장 판정 (데시보드1 ssRowBrand 동일): 사업장코드→TBL_BIZI_MST 매핑, 없으면 품목명 () 접두어
  function d2Brand(r){
    var bc=(''+((r&&r.bizCode)||'')).trim();
    if(bc && D2_BIZI[bc]) return D2_BIZI[bc];
    var m=/^\(([^)]+)\)/.exec((r&&r.item)||'');
    return m?m[1]:'기타·공통';
  }
  // TBL_BIZI_MST 조회 → D2_BIZI{사업장코드:대표사업장명}
  function d2LoadBizi(cb){
    fetch(CTX+'/shipout/selectBiziMst.do', { method:'POST', credentials:'same-origin' })
    .then(function(res){ return res.text(); })
    .then(function(txt){
      try{ var j=JSON.parse(txt); var m={}; (j.data||[]).forEach(function(o){ var c=(''+(o.bizCd||'')).trim(); if(c) m[c]=(''+(o.bizNm||'')).trim(); }); D2_BIZI=m; }
      catch(e){}
      if(cb) cb();
    })
    .catch(function(){ if(cb) cb(); });
  }

  // ── DB 조회: 단일 일자(시작=종료)만 조회. 기간 모드는 현재 데이터로 렌더만. (데시보드1과 동일 규칙)
  function d2Load(){ d2LoadBizi(function(){ _d2LoadInner(); }); }   // 조회 직전 분류표 최신화(데시보드1과 동일)
  function _d2LoadInner(){
    var f=(document.getElementById('d2DateFrom')||{}).value||'';
    var t=(document.getElementById('d2DateTo')||{}).value||'';
    if(!(f && f===t)){ d2Render(); return; }
    fetch(CTX+'/shipout/selectShipoutMst.do', {
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
      credentials:'same-origin',
      body:'shpoutDt='+encodeURIComponent(f)
    })
    .then(function(res){ return res.text().then(function(txt){ return {status:res.status, ok:res.ok, txt:txt}; }); })
    .then(function(r){
      if(!r.ok){ D2_SRC='⚠️ DB 조회 HTTP '+r.status; D2_UP=false; D2_DATA=[]; d2Render();
        d2Toast('⚠️ 출고 조회 실패 (HTTP '+r.status+')'); return; }
      var j; try{ j=JSON.parse(r.txt); }catch(e){ D2_SRC='⚠️ 응답형식 오류'; D2_UP=false; D2_DATA=[]; d2Render();
        d2Toast('⚠️ 조회 응답이 JSON이 아닙니다'); return; }
      var rows=(j&&j.data)||[];
      D2_DATA = rows.map(function(o){
        var dcNm=(''+(o.dcNm||'')).trim(), inwh=(''+(o.inwh||'')).trim();
        var zone = dcNm ? (dcNm+inwh) : (''+(o.zone||'')).trim();
        var bizNm=(''+(o.bizNm||'')).trim(), bizCd=(''+(o.bizCd||'')).trim();
        var bizLbl = bizCd ? (bizNm ? (bizNm+' ['+bizCd+']') : ('['+bizCd+']')) : bizNm;
        var _dlv=(''+(o.dlvDt||'')).trim(); if(/^\d{8}$/.test(_dlv)) _dlv=_dlv.slice(0,4)+'-'+_dlv.slice(4,6)+'-'+_dlv.slice(6,8);
        return { code:(''+(o.itemCd||'')).trim(), item:(''+(o.itemNm||'')).trim(),
                 biz:bizLbl, bizCode:bizCd, dc:dcNm, zone:zone, qty:(+o.curQty||0), dlvDt:_dlv, date:f };
      });
      D2_UP = rows.length>0;
      D2_SRC = rows.length>0 ? ('🗄️ DB 조회 '+f+' · '+rows.length+'건') : ('🗄️ DB '+f+' — 데이터 없음');
      D2_COLL={};
      d2Render();
    })
    .catch(function(e){ D2_SRC='⚠️ DB 통신오류'; D2_UP=false; D2_DATA=[]; d2Render(); d2Toast('⚠️ 출고 조회 통신오류: '+e.message); });
  }

  // ── 집계: 출고장별 (사업장+품목) 행 — 출고량 있는 품목만. 사업장 찾기/보기 필터 반영
  function d2Aggregate(){
    d2GordLoad();   // 그룹순서 최신값 반영(데시보드1에서 바꾼 것도 즉시 적용)
    var from=(document.getElementById('d2DateFrom')||{}).value||'';
    var to=(document.getElementById('d2DateTo')||{}).value||'';
    var selEl=document.getElementById('d2BizSel');
    var bizSel=(selEl && selEl.value) ? selEl.value : '__ALL__';
    var findLc=D2_FIND.toLowerCase();
    var ifindTk=D2_IFIND.toLowerCase().split(/\s+/).filter(function(s){ return s; });
    var dcAny=Object.keys(D2_DCSEL).length>0;
    var zones={}, zoneOrder=[], itemSet={}, bizSet={}, bizAll={}, dcAll={}, totQty=0;
    D2_DATA.forEach(function(r){
      var d=r.date||D2_TODAY;
      if(from && d<from) return;
      if(to && d>to) return;
      var dcg=r.dc||r.zone||'미배정';
      dcAll[dcg]=1;                                            // 필터 무관 전체 대표출고장(콤보 목록용)
      if(r.biz) bizAll[r.biz]=1;                               // 필터 무관 전체 사업장(옵션용)
      if(dcAny && !D2_DCSEL[dcg]) return;                      // 대표출고장 다중선택(선택 없으면 전체)
      if(bizSel!=='__ALL__' && r.biz!==bizSel) return;         // 사업장 보기(정확일치)
      if(findLc && (r.biz||'').toLowerCase().indexOf(findLc)<0) return;   // 사업장 찾기(부분일치)
      if(ifindTk.length){                                      // 품목 찾기 — 행 전체 LIKE(사업장명+품목명+품목코드), 공백 구분 다중 키워드 AND
        var hay=((r.biz||'')+' '+(r.item||'')+' '+(r.code||'')).toLowerCase();
        for(var ti=0; ti<ifindTk.length; ti++){ if(hay.indexOf(ifindTk[ti])<0) return; }
      }
      var q=+r.qty||0;
      var zn=r.zone||'미배정';
      var z=zones[zn];
      if(!z){ z=zones[zn]={dc:(r.dc||''), tot:0, dlv:{}, rows:{}}; zoneOrder.push(zn); }
      if(r.dlvDt) z.dlv[r.dlvDt]=1;
      if(q<=0) return;                     // 출고량 있는 품목만 표시(출고장별 출력과 동일)
      z.tot+=q; totQty+=q;
      bizSet[d2Brand(r)]=1;                // 사업장 = 대표사업장(브랜드) 기준 유니크 (데시보드1 KPI와 동일)
      var ik=(r.code?r.code:('NM:'+r.item));
      itemSet[ik]=1;
      var rk=(r.biz||'')+'|'+ik;
      var row=z.rows[rk];
      if(!row) row=z.rows[rk]={biz:(r.biz||''), name:r.item, code:r.code, qty:0};
      row.qty+=q;
    });
    return {zones:zones, zoneOrder:zoneOrder, itemCnt:Object.keys(itemSet).length,
            bizCnt:Object.keys(bizSet).length, bizAll:Object.keys(bizAll).sort(function(a,b){ return a.localeCompare(b,'ko'); }),
            dcAll:Object.keys(dcAll).sort(function(a,b){
              var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);   // 그룹순서 설정 반영, 미지정은 ㄱㄴㄷ순 뒤에
              if(ia>=0 && ib>=0) return ia-ib;
              if(ia>=0) return -1;
              if(ib>=0) return 1;
              return a.localeCompare(b,'ko');
            }),
            totQty:totQty};
  }

  function d2Render(){
    var ag=d2Aggregate();
    var from=(document.getElementById('d2DateFrom')||{}).value||'';
    var to=(document.getElementById('d2DateTo')||{}).value||'';

    // KPI
    var single=!!(from && from===to);
    d2Set('d2KpiPrefix', single ? (from===D2_TODAY?'당일':'선택일') : '기간');
    var zoneCnt=0; ag.zoneOrder.forEach(function(zn){ if(ag.zones[zn].tot>0) zoneCnt++; });
    d2Set('d2KpiItem', d2Num(ag.itemCnt));
    d2Set('d2KpiQty',  d2Num(ag.totQty));
    d2Set('d2KpiZone', d2Num(zoneCnt));
    d2Set('d2KpiBiz',  d2Num(ag.bizCnt));

    // 당일/당월 버튼 상태
    var ym=D2_TODAY.slice(0,7);
    var _d=new Date(); var monLast=ym+'-'+d2Pad(new Date(_d.getFullYear(), _d.getMonth()+1, 0).getDate());
    var bt=document.getElementById('d2BtnToday'); if(bt) bt.className=(single && from===D2_TODAY)?'btn-teal':'btn-line';
    var bm=document.getElementById('d2BtnMonth'); if(bm) bm.className=(from===ym+'-01' && to===monLast)?'btn-teal':'btn-line';

    // 조회 정보
    var range=single ? (from+(from===D2_TODAY?' <b>(금일)</b>':'')) : ((from||'~')+' ~ '+(to||'~'));
    d2Set('d2Info', '<span class="d2-srcbadge'+(D2_UP?' up':'')+'">'+(D2_SRC||'조회 전')+'</span> 📅 '+range
      + (ag.totQty>0 ? '' : ' &nbsp;|&nbsp; <span style="color:#c0392b">해당 기간 데이터 없음</span>')
      + (Object.keys(D2_DCSEL).length>0 ? ' &nbsp;|&nbsp; <span style="color:#178074">대표출고장 '+Object.keys(D2_DCSEL).length+'곳 선택</span>' : '')
      + (D2_FIND ? ' &nbsp;|&nbsp; <span style="color:#178074">사업장 찾기: '+d2Esc(D2_FIND)+'</span>' : '')
      + (D2_IFIND ? ' &nbsp;|&nbsp; <span style="color:#178074">품목 찾기: '+d2Esc(D2_IFIND)+'</span>' : ''));

    // 대표출고장(물류센터) 다중선택 콤보 — 버튼 라벨 + 드롭다운 체크박스 (열림 상태 유지)
    var dcSelCnt=Object.keys(D2_DCSEL).length;
    d2Set('d2DcLbl', dcSelCnt===0 ? '전체' : (dcSelCnt===1 ? Object.keys(D2_DCSEL)[0] : dcSelCnt+'곳 선택'));
    d2Set('d2DcPop',
      '<label class="all'+(dcSelCnt===0?' on':'')+'">'
      +'<input type="checkbox"'+(dcSelCnt===0?' checked':'')+' onchange="d2DcAllSel()"> 전체 ('+ag.dcAll.length+'개 물류센터)</label>'
      + ag.dcAll.map(function(g){
          var on=!!D2_DCSEL[g];
          return '<label class="'+(on?'on':'')+'">'
            +'<input type="checkbox"'+(on?' checked':'')+' data-g="'+d2Esc(g)+'" '
            +'onchange="d2DcToggle(this.getAttribute(\'data-g\'))"> '+d2Esc(g)+'</label>';
        }).join(''));

    // 사업장 찾기 datalist + 사업장 보기 select (전체 사업장 기준, 선택 유지)
    d2Set('d2BizFindList', ag.bizAll.map(function(bz){ return '<option value="'+d2Esc(bz)+'"></option>'; }).join(''));
    var sel=document.getElementById('d2BizSel');
    if(sel){
      var keep=sel.value||'__ALL__';
      sel.innerHTML='<option value="__ALL__">전체 ('+ag.bizAll.length+' 사업장)</option>'
        + ag.bizAll.map(function(bz){ return '<option value="'+d2Esc(bz)+'">'+d2Esc(bz)+'</option>'; }).join('');
      sel.value = (keep!=='__ALL__' && ag.bizAll.indexOf(keep)>=0) ? keep : '__ALL__';
    }

    // ── 한 그리드: 출고장(좌) + 내용(우), 맨 위 전체 합계 + 출고장별 소계(블록 상단)
    var zonesSorted=ag.zoneOrder.slice().sort(function(a,b){ return a.localeCompare(b,'ko'); });
    var zonesWithItems=zonesSorted.filter(function(zn){ return Object.keys(ag.zones[zn].rows).length>0; });
    function dlvLabel(z){
      var a=Object.keys(z.dlv).sort();
      var oth=a.filter(function(d){ return from && d!==from; });
      return oth.length ? ('발주일자 '+oth.join(', ')) : '';
    }
    var h='<thead><tr>'
      +'<th style="min-width:170px">출고장</th><th style="width:52px">No</th>'
      +'<th style="min-width:200px">사업장</th><th>품목명</th>'
      +'<th style="width:130px">품목코드</th><th style="width:100px">출고수량</th>'
      +'</tr></thead><tbody>';
    // 전체 합계 (상단)
    h+='<tr class="tot"><td class="txt-l">전체 출고장 합계</td><td></td>'
      +'<td class="txt-l">출고장 '+d2Num(zonesWithItems.length)+'곳</td>'
      +'<td class="txt-l">품목 '+d2Num(ag.itemCnt)+'종 · 사업장 '+d2Num(ag.bizCnt)+'곳</td>'
      +'<td></td><td class="num">'+d2Num(ag.totQty)+'</td></tr>';

    // 물류센터(대표그룹) 단위로 묶기 — 데시보드1의 ▼ 그룹과 동일 개념 (그룹 = DC_NM, 없으면 출고장명)
    var groups={}, gOrder=[];
    zonesWithItems.forEach(function(zn){
      var g=ag.zones[zn].dc || zn;
      if(!groups[g]){ groups[g]=[]; gOrder.push(g); }
      groups[g].push(zn);
    });
    // 그룹 순서: 저장된 사용자 지정 순서(D2_GORD) 우선, 미지정 그룹은 ㄱㄴㄷ순 뒤에
    gOrder.sort(function(a,b){
      var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);
      if(ia>=0 && ib>=0) return ia-ib;
      if(ia>=0) return -1;
      if(ib>=0) return 1;
      return a.localeCompare(b,'ko');
    });
    window._d2GOrderNow=gOrder.slice();   // 순서설정 팝업의 이동 기준

    // 그룹순서 설정 팝업 내용 (현재 표시 순서 + ▲▼ 이동 + 초기화)
    d2Set('d2GordPop',
      gOrder.map(function(g,ix){
        return '<label style="justify-content:space-between; cursor:default">'
          +'<span>'+(ix+1)+'. '+d2Esc(g)+'</span>'
          +'<span style="display:inline-flex; gap:3px">'
          +'<button class="btn-line" style="padding:1px 8px" data-g="'+d2Esc(g)+'" onclick="event.stopPropagation(); d2GordMove(this.getAttribute(\'data-g\'),-1)" title="위로">▲</button>'
          +'<button class="btn-line" style="padding:1px 8px" data-g="'+d2Esc(g)+'" onclick="event.stopPropagation(); d2GordMove(this.getAttribute(\'data-g\'),1)" title="아래로">▼</button>'
          +'</span></label>';
      }).join('')
      +'<label class="all" style="border-bottom:none; border-top:1px dashed var(--bd); margin-top:4px; border-radius:0 0 6px 6px; justify-content:center">'
      +'<button class="btn-line" style="padding:3px 12px" onclick="event.stopPropagation(); d2GordReset()">↺ 순서 초기화 (ㄱㄴㄷ순)</button></label>');

    gOrder.forEach(function(g){
      var zs=groups[g];
      var gTot=0;
      zs.forEach(function(zn){ gTot+=ag.zones[zn].tot; });
      var gColl=!!D2_GCOLL[g];
      // ▼ 대표그룹 헤더 (데시보드1 lgrp 형태: "▼ 광주물류센터" + "1개 출고장") — 클릭 시 그룹 접기/펼치기
      h+='<tr class="grp" data-g="'+d2Esc(g)+'" onclick="d2ToggleGroup(this.getAttribute(\'data-g\'))" title="클릭하여 그룹 접기/펼치기">'
        +'<td><span class="zcaret">'+(gColl?'▶':'▼')+'</span> '+d2Esc(g)+'</td>'
        +'<td colspan="4">'+zs.length+'개 출고장'+(gColl?' <span style="color:#9aa7b3">— 접힘(클릭하여 펼치기)</span>':'')+'</td>'
        +'<td></td></tr>';

      if(!gColl){
        zs.forEach(function(zn){
          var z=ag.zones[zn];
          var keys=Object.keys(z.rows).sort(function(a,b){
            var A=z.rows[a],B=z.rows[b];
            return A.biz.localeCompare(B.biz,'ko')||A.name.localeCompare(B.name,'ko');
          });
          var coll=!!D2_COLL[zn];
          var dl=dlvLabel(z);
          var zoneCell='<td class="zone" rowspan="'+(coll?1:(keys.length+1))+'" data-z="'+d2Esc(zn)+'" '
            +'onclick="d2ToggleZone(this.getAttribute(\'data-z\'))" title="클릭하여 접기/펼치기">'
            +'<span class="zcaret">'+(coll?'▶':'▼')+'</span>'+d2Esc(zn)+' 출고장'
            +(dl?'<span class="z-dlv">('+d2Esc(dl)+')</span>':'')+'</td>';
          // 출고장 소계(블록 상단 = 항상 앞쪽 배열)
          h+='<tr class="sub">'+zoneCell+'<td></td><td class="txt-l" colspan="3" data-z="'+d2Esc(zn)+'" '
            +'onclick="d2ToggleZone(this.getAttribute(\'data-z\'))" style="cursor:pointer" title="클릭하여 접기/펼치기">소계 '
            +'<span style="color:#9aa7b3">(품목 '+keys.length+'종'+(coll?' — 접힘':'')+')</span>'
            +'</td><td class="num">'+d2Num(z.tot)+'</td></tr>';
          if(!coll){
            keys.forEach(function(k,ix){
              var r=z.rows[k];
              h+='<tr class="item"><td>'+(ix+1)+'</td><td class="txt-l">'+d2Esc(r.biz)+'</td>'
                +'<td class="txt-l">'+d2Esc(r.name)+'</td><td>'+d2Esc(r.code)+'</td>'
                +'<td class="num">'+d2Num(r.qty)+'</td></tr>';
            });
          }
        });
      }
      // 물류센터 합계 행 (데시보드1 lsub 형태: "광주물류센터 합계")
      h+='<tr class="gsub"><td>'+d2Esc(g)+' 합계</td><td></td><td colspan="3"></td>'
        +'<td class="num">'+d2Num(gTot)+'</td></tr>';
    });
    h+='</tbody>';
    if(!zonesWithItems.length){
      h='<tbody><tr><td><div class="d2-empty">표시할 출고 데이터가 없습니다. 출고일자를 선택 후 <b>조회</b>하세요.</div></td></tr></tbody>';
    }
    document.getElementById('d2Tbl').innerHTML=h;
    d2ApplyZoom();

    // 접기 전체 토글 버튼 라벨
    var allColl = zonesWithItems.length>0 && zonesWithItems.every(function(zn){ return !!D2_COLL[zn]; });
    var zt=document.getElementById('d2BtnZoneToggle'); if(zt) zt.innerHTML = allColl ? '＋ 출고장 펼치기' : '－ 출고장 접기';
  }

  // 초기: 당일로 조회
  (function(){
    document.getElementById('d2DateFrom').value=D2_TODAY;
    document.getElementById('d2DateTo').value=D2_TODAY;
    d2Load();
  })();
</script>
</body>
</html>
