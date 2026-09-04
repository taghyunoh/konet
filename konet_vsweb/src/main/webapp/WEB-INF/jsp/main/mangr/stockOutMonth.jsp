<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>월별 출고현황</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox) — 브라우저 alert 대신 (2026-09-03 요청) --%>
<%-- 기간 = 납기현황표와 같은 우리 달력(ui-datenav.js) — 시작·종료가 달력 두 개로 한 번에 뜬다. 2026-09-03 「이런 형태로」 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<!--
  월별 출고현황 (2026-09-03 신설, 처음 이름 「출고재고현황」→ 같은 날 「월별 출고현황」으로 바꿈) — 재고 관리 > 품목별재고현황 밑 메뉴. 사이드바 iframe(logiFrame) 화면.
  · 행 = 년월(최근월부터 내림차순) · 열 = 사업장 ▸ 품목 (납기현황표 가로표와 같은 2단 머리) · 값 = 그 달 출고량 · 맨 위 줄 = 품목 현재고
  · 원천 규칙(사용자 확정 2026-09-03) = <납기일자> 기준으로 그 날 정산서가 있으면 정산서, 없으면 발주현황표(라벨수량). 원장(품목별재고현황)과 같은 규칙.
    정산서엔 사업장이 없어 같은 발주라인의 사업장에 발주수량 비율로 나눈다(SQL selectStockOutByMonth). 현재고 줄은 원장(TBL_STOCK_MST).
  · 사업장 이름 = 거래처관리 매칭명(MATCH_NM)이 있으면 그것, 없으면 원래 사업장명 (납기현황표 가로표와 같은 규칙, SQL에서 묶음)
  · 열 차례 = 출고 많은 사업장이 왼쪽, 사업장 안에서도 많이 나간 품목이 왼쪽. 출고장은 넣지 않는다(요청).
  · 현재고는 품목 잔량이라 사업장과 무관 — 같은 품목이 여러 사업장에 있으면 같은 값이 되풀이되고, 합계는 품목 하나당 한 번만 더한다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:12px; font-size:12.5px; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input[type=date], .bar input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .cnt{ margin-left:10px; color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; white-space:nowrap; }
  .cnt b{ color:var(--teal); font-weight:800; }
  /* 재집계는 툴바 맨 오른쪽 (2026-09-03 「재집계 위치 이동」) — 조회·거르기·엑셀과 떨어뜨려 실수로 누르지 않게 */
  .bar .rb-btn{ margin-left:auto; border-color:#cfe0da; color:#137a6c; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  /* 가로표(납기현황표)와 같은 감각 — 첫 두 칸·머리 2줄 고정, 값 없는 칸 회색, 사업장 경계는 굵은 세로선 */
  /* ★table-layout:fixed (2026-09-04 속도) — 자동 레이아웃은 2,415열×3만 셀의 내용 폭을 여러 번 재서
       레이아웃만 884ms 걸렸다. 열 폭을 colgroup 으로 못 박으면 한 번에 계산한다(품목 열은 112px 균일). */
  table.mx{ border-collapse:separate; border-spacing:0; font-size:14px; --h1:40px; table-layout:fixed; }
  table.mx th, table.mx td{ border:1px solid var(--bd); padding:6px 9px; white-space:nowrap; text-align:center; background:#fff; }
  table.mx .gs{ border-left:2px solid #9fb6cc; }
  table.mx .cn{ position:sticky; left:0; z-index:2; text-align:left; font-weight:700; width:150px; min-width:150px; max-width:150px; background:#fff; }
  table.mx td.cn small.src{ display:block; font-size:11px; font-weight:400; color:#6b7a89; line-height:1.2; }
  table.mx .rt{ position:sticky; left:150px; z-index:2; width:90px; min-width:90px; max-width:90px; background:#fff2cc; font-weight:800; }
  /* ★머리 고정은 <thead 한 덩어리>로 (2026-09-04 속도) — 종전 `thead th{position:sticky}` 는 머리 칸 2,415개가 저마다 sticky 라
       브라우저가 칸마다 합성 레이어를 만들어(스크롤 상자 안 sticky 는 레이어로 승격) 그리기·스크롤·화면 전환이 통째로 무거웠다.
       thead 하나를 sticky 로 두면 두 줄이 함께 붙고 레이어는 1개다. 2단 머리의 top(--h1) 계산도 필요 없다. */
  table.mx thead{ position:sticky; top:0; z-index:3; }
  table.mx thead th{ background:#dfeaf5; color:#1f2a37; font-size:14px; }
  table.mx thead th.cn, table.mx thead th.rt{ z-index:4; }
  /* 1단 = 사업장(매칭명) · 2단 = 품목. 2단은 1단 높이(--h1, 그릴 때 잰다)만큼 내려 붙인다 */
  table.mx thead th.gh{ background:#cfe0f3; font-size:14px; font-weight:800; color:#123c63; white-space:nowrap; line-height:1.3; min-width:96px; text-align:left; }
  /* 사업장 이름은 칸 안에서 sticky — 40품목짜리 사업장은 칸이 수천 px 라 가운데 두면 이름이 화면 밖에 간다. 고정칸(150+90) 바로 뒤에 붙인다 */
  table.mx thead th.gh .gl{ position:sticky; left:250px; display:inline-block; }
  table.mx thead th.gh small{ display:block; font-size:11.5px; font-weight:600; color:#4c6a8a; }
  table.mx thead th.it{ background:#eef4fa; white-space:normal; min-width:96px; max-width:128px; line-height:1.35; font-size:12px; font-weight:600; padding:6px 6px; word-break:break-all; }   /* 2026-09-03 「품목명 조금 좁게」 118→96px */
  table.mx thead th.it .cd{ display:block; font-weight:800; color:#1f2a37; }
  table.mx thead th.it .nm{ color:#5a6b7a; font-weight:400; }
  table.mx td.none{ background:#f1f3f5; }
  table.mx th.sp, table.mx td.sp{ background:#f1f3f5; border-left:0; border-right:0; padding:0; }   /* 가상화 빈 칸(안 그린 열들의 자리) */
  table.mx td.n{ font-weight:700; }
  table.mx tr.stk td{ background:#fff4e6; font-weight:800; color:#137a6c; }
  table.mx tr.stk td.cn, table.mx tr.stk td.rt{ background:#fde9cc; }
  table.mx tr.stk td.neg{ color:#c0392b; }
  table.mx tr.sum td{ background:#e2efda; font-weight:800; color:#375623; }
  table.mx tr.sum td.cn, table.mx tr.sum td.rt{ background:#d5e8c6; }
  table.mx tbody td{ height:30px; }
  .empty{ padding:30px; text-align:center; color:#9aa7b3; }
  /* 재집계 진행 창 — 서버(RebuildProgress)가 알려주는 실제 진행률. 총량을 모르는 단계는 흐르는 바(qprog) */
  .rb{ position:fixed; inset:0; background:rgba(15,23,32,.35); z-index:9998; display:none; align-items:center; justify-content:center; }
  .rb.on{ display:flex; }
  .rb .bx{ background:#fff; width:min(440px,92vw); border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); padding:18px 22px 16px; }
  .rb .tt{ font-weight:800; font-size:15px; color:#137a6c; margin-bottom:12px; }
  .rb .bar{ height:10px; background:#e8efed; border-radius:6px; overflow:hidden; }
  .rb .bar > i{ display:block; height:100%; width:0; background:linear-gradient(90deg,#0f6b5f,#3fbfae); border-radius:6px; transition:width .3s; }
  .rb .bar.ind > i{ width:34%; animation:qslide 1.05s infinite ease-in-out; }
  .rb .lb{ margin-top:10px; font-size:13px; color:#5a6b7a; min-height:18px; }
  /* 조회 진행바 — 물류관리 다른 화면(마감·매출내역·재고현황)의 .qprog 와 같은 것 (2026-09-03 「불러오는 중을 진행바로」).
     진행률을 알 수 없는 조회라 좌우로 흐르는 무한 바 + 한 줄 안내 */
  .qprog{ height:3px; background:#e8efed; border-radius:2px; overflow:hidden; margin:2px 0 8px; }
  .qprog > i{ display:block; height:100%; width:34%; border-radius:2px; background:linear-gradient(90deg,#0f6b5f,#3fbfae); animation:qslide 1.05s infinite ease-in-out; }
  @keyframes qslide{ 0%{ margin-left:-34%; } 100%{ margin-left:100%; } }
  .qmsg{ padding:10px 2px 4px; color:#5a6b7a; font-size:12.5px; }
  .qwrap{ padding:14px 16px 10px; }
  /* 셀을 누르면 하단에 그 (년월·사업장·품목)의 출고내역·입고내역 (2026-09-03 요청) */
  table.mx td[data-cd]{ cursor:pointer; }
  table.mx td[data-cd]:hover{ outline:2px solid #137a6c; outline-offset:-2px; }
  table.mx td.pick{ outline:2px solid #e0871a; outline-offset:-2px; background:#fff7e6 !important; }
  .dtl{ margin-top:12px; background:#fff; border:1px solid var(--bd); border-radius:10px; display:none; }
  .dtl .dh{ display:flex; align-items:center; gap:10px; padding:9px 12px; border-bottom:1px solid var(--bd); background:#f4f8f7; font-size:14px; flex-wrap:wrap; }
  .dtl .dh b{ color:var(--teal); }
  .dtl .dh .x{ margin-left:auto; cursor:pointer; border:1px solid var(--bd); background:#fff; border-radius:6px; padding:3px 9px; font-size:12.5px; }
  .dtl .cols{ display:flex; gap:0; }
  .dtl .col{ flex:1 1 50%; min-width:0; border-right:1px solid var(--bd); }
  .dtl .col:last-child{ border-right:0; }
  .dtl .ct{ padding:7px 12px; font-weight:800; font-size:13.5px; background:#fafcfb; border-bottom:1px solid var(--bd); }
  .dtl .ct span{ font-weight:600; color:#6b7a89; margin-left:6px; }
  .dtl .tb{ max-height:40vh; overflow:auto; }
  .dtl table{ border-collapse:collapse; width:100%; font-size:13px; }
  .dtl th, .dtl td{ border-bottom:1px solid #eef1f4; padding:5px 9px; white-space:nowrap; text-align:center; }
  .dtl th{ position:sticky; top:0; background:#eef4fa; font-weight:700; }
  .dtl td.l{ text-align:left; } .dtl td.r{ text-align:right; font-weight:700; }
  .dtl td.src-s{ color:#1f6fb3; } .dtl td.src-o{ color:#6b7a89; }
  /* 출고코드(거래처 매칭코드) — 품목별재고현황의 ↳ 줄과 같은 주황 */
  .dtl td .xc{ color:#c8741a; font-weight:700; } .dtl td .xn{ color:#a06a2c; font-size:12px; }
  .dtl .none{ padding:18px; text-align:center; color:#9aa7b3; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📦 월별 출고현황</h2>
  <div class="sub"><b>사업장</b> ▸ <b>품목</b>별 <b>월 출고량</b>과 <b>현재고</b>를 한 표로 봅니다 — 행은 년월(최근월부터), 맨 위 줄이 품목 현재고(사업장과 무관한 품목 잔량)입니다. 출고량은 <b>납기일자</b> 기준으로 그 날 <b>정산서가 있으면 정산서</b>, 없으면 발주현황표(라벨수량)를 읽고(품목별재고현황과 같은 규칙), 사업장은 거래처관리 매칭명으로 묶습니다.</div>
  <div class="bar">
    <label style="font-weight:700">기간</label>
    <input type="date" id="frDt" data-range-to="toDt" onchange="somLoad()" title="클릭하여 달력 선택 — 시작·종료를 한 번에 고릅니다"> <span style="color:#8a98a8">~</span> <input type="date" id="toDt" onchange="somLoad()" title="클릭하여 달력 선택 — 시작·종료를 한 번에 고릅니다">
    <button class="btn btn-teal" onclick="somLoad()">🔍 조회</button>
    <input type="text" id="q" placeholder="사업장/품목코드/품목명 거르기" oninput="somFindLater()" onkeydown="if(event.key==='Enter'){ somFindNow(); }" title="치는 동안 기다렸다가 멈추면 거릅니다 — Enter 를 누르면 바로" style="width:220px">
    <button class="btn" onclick="somExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">-</span>
    <button class="btn rb-btn" onclick="somRebuild()" title="전체 출고를 재고 원장에 다시 반영하고 현재고를 다시 계산합니다 (품목별재고현황의 재집계와 같은 것).&#10;정산서가 있는 납기일자는 정산서, 없는 날은 발주현황표 기준. 마감 확정월은 제외.">🔄 출고반영 재집계</button>
  </div>
  <div class="card" id="card"><div class="empty">기간을 고르고 [조회]를 누르세요.</div></div>
  <div class="dtl" id="dtl">
    <div class="dh" id="dtlHead"></div>
    <div class="cols">
      <div class="col"><div class="ct">📤 출고내역 <span id="dtlOutSum"></span></div><div class="tb" id="dtlOut"></div></div>
      <div class="col"><div class="ct">📥 입고내역 <span id="dtlInSum"></span></div><div class="tb" id="dtlIn"></div></div>
    </div>
  </div>
  <div class="rb" id="rb"><div class="bx"><div class="tt">🔄 출고반영 재집계</div><div class="bar ind" id="rbBar"><i></i></div><div class="lb" id="rbLb">시작하는 중…</div></div></div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var RAW=null;   // {months:[{ym,bizKey,bizNm,prodCd,prodNm,outQty}], stock:[{prodCd,curQty}], srcDays:[{ym,days,sDays}]}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function num(v){ return Math.round(Number(v)||0).toLocaleString(); }   // 정산서 비율 배분은 소수가 나온다 → 표시는 반올림
/* 조회 진행바(다른 화면 .qprog 와 같은 모양) */
function qprog(msg){ return '<div class="qwrap"><div class="qprog"><i></i></div><div class="qmsg">'+esc(msg||'조회 중…')+'</div></div>'; }
function ymLabel(ym){ ym=''+ym; return ym.length===6 ? (ym.slice(0,4)+'-'+ym.slice(4,6)) : ym; }
/* 알림 = 프로젝트 공통 _alertBox(ui-message.js, 재집계 확인창과 같은 모양). 없으면 브라우저 alert 폴백 (2026-09-03 요청) */
function toast(s, icon){ if(window._alertBox) return _alertBox(s, {icon:icon||'ℹ️'}); alert(s.replace(/<[^>]*>/g,'')); }
/* 기본 기간 = <해당년도 1월 1일> ~ 오늘 (2026-09-03 사용자 확정. 종전 「12개월 전 1일」)
   ★기간이 곧 표의 열 수다 — 지금은 자료가 2026-01 부터라 12개월 기본과 결과가 같지만
     (열 2,415 · DOM 셀 29,811 · 렌더 실측 1.5초), 해가 바뀌면 12개월 기본은 지난해까지 끌어와
     열이 배로 늘어난다. 올해분으로 끊으면 그 일이 없다. 더 보려면 시작일만 내리면 된다. */
(function(){
  function d10(x){ return x.getFullYear()+'-'+('0'+(x.getMonth()+1)).slice(-2)+'-'+('0'+x.getDate()).slice(-2); }
  var d=new Date(), to=d10(d);
  var fr=d.getFullYear()+'-01-01';
  document.getElementById('frDt').value=fr; document.getElementById('toDt').value=to;

})();
function somLoad(){
  var fr=document.getElementById('frDt').value, to=document.getElementById('toDt').value;
  if(!fr||!to){ toast('기간을 고르세요.'); return; }
  if(fr>to){ var t=fr; fr=to; to=t; document.getElementById('frDt').value=fr; document.getElementById('toDt').value=to; }
  document.getElementById('card').innerHTML=qprog('월별 출고량을 조회하는 중… (기간 '+fr+' ~ '+to+')');
  /* 걸린 시간을 조회 결과 줄에 같이 적는다(2026-09-04 「조회 자체 느림」 — 서버·그리기 어느 쪽인지 사용자가 바로 보게) */
  var t0=performance.now(), tFetch=0;
  fetch(CTX+'/prod/stockOutMonthList.do', { method:'POST', credentials:'same-origin',
         headers:{'Content-Type':'application/x-www-form-urlencoded'},
         body:'frDt='+encodeURIComponent(fr.replace(/-/g,''))+'&toDt='+encodeURIComponent(to.replace(/-/g,'')) })
    .then(function(r){ return r.json(); })
    .then(function(j){ tFetch=performance.now()-t0; RAW=j||{months:[],stock:[]}; var t1=performance.now(); somRender(); void document.body.offsetHeight;
      _somTiming='  ⏱ 서버 '+(tFetch/1000).toFixed(1)+'초 · 그리기 '+((performance.now()-t1)/1000).toFixed(1)+'초';
      var c=document.getElementById('cnt'); if(c && c.innerHTML.indexOf('⏱')<0) c.innerHTML+='<span style="color:#8a98a8;font-weight:600">'+_somTiming+'</span>'; })
    .catch(function(e){ document.getElementById('card').innerHTML='<div class="empty">조회 실패: '+esc(e.message)+'</div>'; });
}
/* 품목명 앞의 (브랜드) 가 사업장 이름과 겹치면 뺀다 — 납기현황표 엑셀과 같은 규칙(공백 무시 · 2자 이상 · 서로 포함) */
function shortNm(nm, biz){
  var m=/^\s*\(([^)]*)\)\s*(.*)$/.exec(nm||''); if(!m) return nm||'';
  var a=m[1].replace(/\s+/g,''), b=(biz||'').replace(/\s+/g,'');
  if(a.length>=2 && b.length>=2 && (a.indexOf(b)>=0 || b.indexOf(a)>=0)) return m[2]||nm;
  return nm||'';
}
/* 자료를 년월 × (사업장 ▸ 품목) 격자로 편다 */
function somBuild(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  var stock={}; (RAW.stock||[]).forEach(function(s){ stock[''+s.prodCd]=Number(s.curQty)||0; });
  var grp={}, gord=[], yms={}, yord=[], cell={}, pset={};
  (RAW.months||[]).forEach(function(r){
    var cd=''+(r.prodCd||''), ym=''+(r.ym||''), q0=Number(r.outQty)||0;
    var gn=(''+(r.bizNm||'')).trim()||'(사업장없음)', gk=''+(r.bizKey||''); if(!gk) gk='~'+gn;
    if(!cd||!ym) return;
    if(q && (gn+' '+cd+' '+(r.prodNm||'')).toLowerCase().indexOf(q)<0) return;
    var g=grp[gk]; if(!g){ g=grp[gk]={key:gk, nm:gn, tot:0, items:{}, iord:[]}; gord.push(gk); }
    var it=g.items[cd]; if(!it){ it=g.items[cd]={cd:cd, nm:(r.prodNm||''), seq:(r.prodSeq||''), tot:0}; g.iord.push(cd); }
    it.tot+=q0; g.tot+=q0; pset[cd]=1;
    if(!yms[ym]){ yms[ym]=0; yord.push(ym); }
    yms[ym]+=q0;
    var k=ym+'|'+gk+'|'+cd; cell[k]=(cell[k]||0)+q0;
  });
  gord.sort(function(a,b){ return grp[b].tot-grp[a].tot || grp[a].nm.localeCompare(grp[b].nm); });   // 많이 나간 사업장이 왼쪽
  gord.forEach(function(gk){ var g=grp[gk]; g.iord.sort(function(a,b){ return g.items[b].tot-g.items[a].tot || a.localeCompare(b); }); });
  yord.sort(function(a,b){ return b.localeCompare(a); });                                              // 최근월부터
  var cols=[]; gord.forEach(function(gk){ grp[gk].iord.forEach(function(cd,i){ cols.push({g:gk, cd:cd, first:i===0}); }); });
  return { stock:stock, grp:grp, gord:gord, cols:cols, yms:yms, yord:yord, cell:cell, nprod:Object.keys(pset).length };
}
/* 년월 칸 밑줄 — 그 달 납기일자 중 정산서로 읽은 날수 / 발주현황표로 읽은 날수 */
/* (2026-09-03 「표시 빼줘」) 년월 칸의 정산/발주 일수 표시는 뺐다 — 함수는 남겨 두고 호출만 안 한다 */
function srcBadge(ym){
  var d=null; (RAW.srcDays||[]).forEach(function(r){ if((''+r.ym)===(''+ym)) d=r; });
  if(!d) return ''; var s=Number(d.sDays)||0, o=(Number(d.days)||0)-s;
  return '<small class="src">'+(s?('📄 정산 '+s+'일'+(o?' · ':'')):'')+(o?('발주 '+o+'일'):'')+'</small>';
}
/* ★거르기 칸은 <치는 동안> 다시 그리지 않는다 (2026-09-03 속도점검)
     종전 oninput="somRender()" 는 글자 하나마다 표를 통째로 다시 만들었다 —
     12개월(열 2,415 · DOM 셀 29,811) 기준 실측 1,496ms(레이아웃만 884ms)라
     한 글자에 1.5초씩 멈췄고, 한글은 조합 중에도 event 가 떠서 더 잦았다.
     ⇒ 마지막 입력 뒤 300ms 조용할 때 한 번만 그린다. Enter 는 즉시. */
var _somFindT=null;
function somFindLater(){ if(_somFindT) clearTimeout(_somFindT); _somFindT=setTimeout(function(){ _somFindT=null; somRender(); }, 300); }
function somFindNow(){ if(_somFindT){ clearTimeout(_somFindT); _somFindT=null; } somRender(); }
/* 화면에 그려진 격자 — 셀 클릭·엑셀이 다시 만들지 않고 이걸 쓴다(실측 somBuild 84ms).
   지금 표에 보이는 것과 같은 격자라 오히려 어긋날 일이 없다. */
var _somM=null, _somTiming='', _somPick='';
/* ★★열 가상화 (2026-09-04 「그린 다음에도 한참 있다가 클릭됨」) —
     열 2,415 × 줄 11 = 셀 26,000 을 한꺼번에 DOM 에 두면 그리기(1.2초)보다 <그 뒤>가 문제였다 : 브라우저가 접근성 트리·
     확장 프로그램 스캔·합성 레이어를 3만 셀에 대해 마저 처리하는 동안 화면이 몇 초씩 안 눌렸다(사용자 크롬 실측 — 내장 브라우저엔 없음).
     ⇒ DOM 에는 <보이는 열 + 좌우 여유 BUF 열>만 두고, 나머지 폭은 빈 칸(spacer) 하나로 채운다. 표 전체 폭·스크롤바는 종전과 같고
       옆으로 밀면 scroll 이벤트에서 창을 옮겨 다시 그린다(셀 ~700개라 수 ms). 고정칸(년월·합계)·2단 머리·클릭·엑셀 동작은 그대로. */
var COLW=112, BUF=20, _somRS=-1, _somRE=-1;
function somRender(){
  if(!RAW) return;
  var m=_somM=somBuild(), card=document.getElementById('card');
  _somRS=-1; _somRE=-1;
  if(!m.cols.length){ card.innerHTML='<div class="empty">해당 기간에 출고가 없습니다.</div>'; document.getElementById('cnt').textContent='-'; return; }
  var grand=0; m.yord.forEach(function(ym){ grand+=m.yms[ym]; }); m.grand=grand;
  var stkTot=0, seen={}; m.cols.forEach(function(c){ var v=m.stock[c.cd]; if(v!=null && !seen[c.cd]){ seen[c.cd]=1; stkTot+=v; } }); m.stkTot=stkTot; m.stkAny=Object.keys(seen).length>0;
  somPaint(true);
  document.getElementById('cnt').innerHTML='사업장 <b>'+num(m.gord.length)+'</b>곳 · 품목 <b>'+num(m.nprod)+'</b>종 · <b>'+num(m.yord.length)+'</b>개월 · 기간 출고 <b>'+num(grand)+'</b>';
  somFit();
}
/* 지금 보이는 열 범위 [vs,ve) — 고정칸 240px 뒤부터 */
function somVis(){
  var card=document.getElementById('card'), n=_somM.cols.length;
  var sl=card.scrollLeft, w=card.clientWidth||1200;
  var vs=Math.max(0, Math.floor((sl-240)/COLW)), ve=Math.min(n, Math.ceil((sl+w-240)/COLW)+1);
  return {vs:vs, ve:Math.max(ve, Math.min(n, vs+1))};
}
/* 창 [rs,re) 를 그린다 — force 가 아니면 보이는 범위가 그려진 창 안에 있을 때 건너뛴다 */
function somPaint(force){
  var m=_somM; if(!m || !m.cols.length) return;
  var card=document.getElementById('card'), n=m.cols.length, v=somVis();
  if(!force && v.vs>=_somRS && v.ve<=_somRE) return;
  var rs=Math.max(0, v.vs-BUF), re=Math.min(n, v.ve+BUF);
  _somRS=rs; _somRE=re;
  var cols=m.cols.slice(rs, re), lw=rs*COLW, rw=(n-re)*COLW;
  var spL = lw>0, spR = rw>0;
  /* ★표 폭을 명시해야 table-layout:fixed 가 살아 colgroup 폭(빈 칸 포함)이 그대로 먹는다 — width:auto 면 자동 레이아웃으로 돌아가 빈 칸이 0 이 된다 */
  var h='<table class="mx" style="width:'+(240+n*COLW)+'px"><colgroup><col style="width:150px"><col style="width:90px">'+(spL?'<col style="width:'+lw+'px">':'')
       +new Array(cols.length+1).join('<col style="width:'+COLW+'px">')+(spR?'<col style="width:'+rw+'px">':'')+'</colgroup>';
  /* 머리 1단 = 사업장(창 안에 든 열 수만큼 colspan) */
  h+='<thead><tr class="r1"><th class="cn">년월 / 사업장</th><th class="rt">합계</th>'+(spL?'<th class="sp"></th>':'');
  var i=0; while(i<cols.length){ var gk=cols[i].g, j=i; while(j<cols.length && cols[j].g===gk) j++; var g=m.grp[gk];
    h+='<th class="gh'+(cols[i].first?' gs':'')+'" colspan="'+(j-i)+'" title="'+esc(g.nm)+'"><span class="gl">'+esc(g.nm)+'<small>'+num(g.iord.length)+'품목 · '+num(g.tot)+'</small></span></th>'; i=j; }
  h+=(spR?'<th class="sp"></th>':'')+'</tr><tr class="r2"><th class="cn">품목</th><th class="rt"></th>'+(spL?'<th class="sp"></th>':'');
  cols.forEach(function(c){ var it=m.grp[c.g].items[c.cd];
    h+='<th class="it'+(c.first?' gs':'')+'" title="'+esc(c.cd+' '+it.nm)+'"><span class="cd">'+esc(c.cd)+'</span><span class="nm">'+esc(shortNm(it.nm, m.grp[c.g].nm))+'</span></th>'; });
  h+=(spR?'<th class="sp"></th>':'')+'</tr></thead><tbody>';
  var L=spL?'<td class="sp"></td>':'', R=spR?'<td class="sp"></td>':'';
  function cell(cls, ym, c, txt){ var k=ym+'|'+c.g+'|'+c.cd; return '<td class="'+cls+(c.first?' gs':'')+(_somPick===k?' pick':'')+'" data-ym="'+esc(ym)+'" data-g="'+esc(c.g)+'" data-cd="'+esc(c.cd)+'">'+txt+'</td>'; }
  /* ① 현재고 */
  h+='<tr class="stk"><td class="cn">현재고 <small style="font-weight:400;color:#6b7a89">(품목)</small></td><td class="rt">'+(m.stkAny?num(m.stkTot):'')+'</td>'+L;
  cols.forEach(function(c){ var v=m.stock[c.cd]; h+= (v==null) ? '<td class="none'+(c.first?' gs':'')+'"></td>' : cell(v<0?'neg':'', '', c, num(v)); });
  h+=R+'</tr>';
  /* ② 년월 줄 */
  m.yord.forEach(function(ym){
    h+='<tr><td class="cn">'+ymLabel(ym)+'</td><td class="rt">'+num(m.yms[ym])+'</td>'+L;
    cols.forEach(function(c){ var v=m.cell[ym+'|'+c.g+'|'+c.cd]; h+= (v>0) ? cell('n', ym, c, num(v)) : '<td class="none'+(c.first?' gs':'')+'"></td>'; });
    h+=R+'</tr>';
  });
  /* ③ 기간 합계 */
  h+='<tr class="sum"><td class="cn">기간 합계</td><td class="rt">'+num(m.grand)+'</td>'+L;
  cols.forEach(function(c){ h+=cell('', '', c, num(m.grp[c.g].items[c.cd].tot)); });
  h+=R+'</tr></tbody></table>';
  var sl=card.scrollLeft, st=card.scrollTop;
  card.innerHTML=h;
  if(card.scrollLeft!==sl) card.scrollLeft=sl; if(card.scrollTop!==st) card.scrollTop=st;   /* innerHTML 교체로 스크롤이 튀지 않게 */
}
/* 옆으로 밀면 창을 옮긴다 — 한 프레임에 한 번 */
(function(){ var card=document.getElementById('card'), t=null;
  card.addEventListener('scroll', function(){ if(t) return; t=requestAnimationFrame(function(){ t=null; somPaint(false); }); });
  window.addEventListener('resize', function(){ if(_somM) somPaint(false); });
})();
/* ── 셀 클릭 → 하단 출고내역·입고내역 (2026-09-03 요청) ──
   · 월 셀 = 그 달, 현재고·기간합계 셀 = 조회 기간 전체. 사업장은 그 열의 사업장(매칭명) 하나.
   · 출고내역 = /prod/stockOutDetail.do (통합 원천: 정산서 있는 날은 정산서, 없으면 발주현황표 — 표와 같은 규칙)
   · 입고내역 = 같은 응답의 수불원장(ledger)에서 출고(O)가 아닌 행(입고 I·반품 R·조정 A)을 년월로 걸러 보여 준다 */
var DTL_LAST=null;
document.getElementById('card').addEventListener('click', function(ev){
  var td=ev.target.closest ? ev.target.closest('td[data-cd]') : null; if(!td || !RAW) return;
  var m=_somM||somBuild(), g=m.grp[td.getAttribute('data-g')]; if(!g) return;
  var it=g.items[td.getAttribute('data-cd')]; if(!it) return;
  var prev=document.querySelector('table.mx td.pick'); if(prev) prev.classList.remove('pick'); td.classList.add('pick');
  _somPick=(td.getAttribute('data-ym')||'')+'|'+td.getAttribute('data-g')+'|'+td.getAttribute('data-cd');
  somDetail({ ym:td.getAttribute('data-ym')||'', g:g, it:it });
});
function somDetail(sel){
  DTL_LAST=sel;
  var fr=document.getElementById('frDt').value.replace(/-/g,''), to=document.getElementById('toDt').value.replace(/-/g,'');
  var box=document.getElementById('dtl'); box.style.display='block';
  document.getElementById('dtlHead').innerHTML='② <b>'+(sel.ym?ymLabel(sel.ym):(dt8(fr)+' ~ '+dt8(to)))+'</b> · 사업장 <b>'+esc(sel.g.nm)+'</b>'+(sel.g.key.charAt(0)==='~'?'':' <span style="color:#6b7a89;font-weight:600">[매칭코드 '+esc(sel.g.key)+']</span>')+' · 품목 <b>'+esc(sel.it.cd)+'</b> '+esc(sel.it.nm)
    +'<button class="x" onclick="somDetailClose()">✕ 닫기</button>';
  document.getElementById('dtlOut').innerHTML=qprog('출고내역을 조회하는 중…'); document.getElementById('dtlIn').innerHTML=qprog('입고내역을 조회하는 중…');
  document.getElementById('dtlOutSum').textContent=''; document.getElementById('dtlInSum').textContent='';
  var gk=sel.g.key, body='ym='+encodeURIComponent(sel.ym)+'&frDt='+fr+'&toDt='+to+'&prodCd='+encodeURIComponent(sel.it.cd)+'&prodSeq='+encodeURIComponent(sel.it.seq||'')
    +(gk.charAt(0)==='~' ? '&bizNm='+encodeURIComponent(sel.g.nm) : '&bizKey='+encodeURIComponent(gk));
  fetch(CTX+'/prod/stockOutDetail.do', { method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body })
    .then(function(r){ return r.json(); })
    .then(function(j){ if(DTL_LAST!==sel) return; somDetailRender(sel, j||{}, fr, to); somFit(); box.scrollIntoView({behavior:'smooth', block:'nearest'}); })
    .catch(function(e){ document.getElementById('dtlOut').innerHTML='<div class="none">조회 실패: '+esc(e.message)+'</div>'; });
}
function somDetailClose(){ DTL_LAST=null; _somPick=''; document.getElementById('dtl').style.display='none'; var p=document.querySelector('table.mx td.pick'); if(p) p.classList.remove('pick'); somFit(); }
function dt8(d){ d=''+(d||''); return /^\d{8}$/.test(d) ? (d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8)) : d; }
function somDetailRender(sel, j, fr, to){
  /* 출고내역 — 납기일자별·원래 사업장별. 거래처 매칭코드 칸은 주코드와 다를 때만(재고현황 ↳ 줄과 같은 규칙, 2026-09-03 「주코드이면 보여주지 마세요」) */
  var out=j.out||[], os=0, h='';
  if(!out.length) h='<div class="none">출고가 없습니다.</div>';
  else { h='<table><thead><tr><th>납기일자</th><th>사업장 [사업장코드]</th><th>물류센터</th><th>거래처 매칭코드 · 품목명</th><th>원천</th><th>수량</th></tr></thead><tbody>';
    out.forEach(function(r){ var q=Number(r.qty)||0; os+=q; var s=(''+(r.src||''));
      h+='<tr><td>'+dt8(r.dlvDt)+'</td><td class="l" title="'+esc(r.mtNm)+'">'+esc(r.bizNm||r.mtNm)+'</td><td>'+esc(r.dcNm)+'</td><td class="l">'+((r.itemCd && (''+r.itemCd)!==(''+sel.it.cd))?('<span class="xc">↳ '+esc(r.itemCd)+'</span> <span class="xn">'+esc(r.itemNm||'')+'</span>'):'')+'</td><td class="'+(s==='정산서'?'src-s':'src-o')+'">'+(s==='정산서'?'📄 ':'')+esc(s)+'</td><td class="r">'+num(q)+'</td></tr>'; });
    h+='</tbody></table>'; }
  document.getElementById('dtlOut').innerHTML=h; document.getElementById('dtlOutSum').textContent=out.length?(out.length+'건 · '+num(os)):'';
  /* 입고내역 — 원장에서 출고(O) 뺀 행, 년월로 거른다 */
  var led=(j.ledger||[]).filter(function(r){ var d=''+(r.trxDt||''), y6=d.replace(/-/g,'').slice(0,6);
    if((''+(r.ioGb||''))==='O') return false; var d8=d.replace(/-/g,'').slice(0,8); return (d8>=fr && d8<=to) && (!sel.ym || y6===sel.ym); });
  var gb={I:'입고',R:'반품입고',A:'조정'}, is=0, h2='';
  if(!led.length) h2='<div class="none">입고가 없습니다.</div>';
  else { h2='<table><thead><tr><th>일자</th><th>구분</th><th>수량</th><th>매입처/사업장</th><th>근거</th><th>비고</th></tr></thead><tbody>';
    led.forEach(function(r){ var q=Number(r.qty)||0; is+=q;
      h2+='<tr><td>'+dt8(r.trxDt)+'</td><td>'+esc(gb[r.ioGb]||r.ioGb)+'</td><td class="r">'+num(q)+'</td><td class="l">'+esc(r.vendorNm||r.bizCd||'')+'</td><td>'+esc(r.refGb||'')+(r.refNo?(' '+esc(r.refNo)):'')+'</td><td class="l">'+esc(r.remark||'')+'</td></tr>'; });
    h2+='</tbody></table>'; }
  document.getElementById('dtlIn').innerHTML=h2; document.getElementById('dtlInSum').textContent=led.length?(led.length+'건 · '+num(is)):'';
}
/* ── 🔄 출고반영 재집계 — 품목별재고현황의 stkRebuild 와 같은 동작(같은 서버 API) (2026-09-03 요청) ──
   확인창(공통 _confirmBox) → /prod/stockRebuild.do POST, 그동안 /prod/stockRebuildProgress.do 를 0.5초마다 물어 실제 진행률을 그린다.
   끝나면 표를 다시 조회한다. 규칙: 정산서 있는 납기일자는 정산서, 없는 날은 발주현황표 · 마감 확정월 제외 */
function somRebuild(){
  fetch(CTX+'/prod/closedMonths.do', { method:'POST', credentials:'same-origin' })
    .then(function(r){ return r.json(); }).catch(function(){ return {months:[]}; })
    .then(function(j){
      var ms=(j&&j.months)||[], excl = ms.length ? ('<br>제외 : <b style="color:#c0392b">마감 확정월 '+ms.map(function(m){ m=''+m; return m.length===6?(m.slice(0,4)+'-'+m.slice(4)):m; }).join(', ')+'</b>') : '';
      var msg='<div style="font-weight:800;color:#137a6c;margin-bottom:6px">🔄 출고반영 재집계</div>전체 출고를 재고 원장에 반영하고 <b>현재고를 다시 계산</b>합니다.'+excl+'<br>진행할까요?';
      if(!window._confirmBox){ if(!confirm(msg.replace(/<[^>]*>/g,''))) return; return somRebuildRun(); }
      _confirmBox({ msg:msg, icon:'❓', okText:'확인', okColor:'blue', onOk:somRebuildRun });
    });
}
function somRebuildRun(){
  var rb=document.getElementById('rb'), bar=document.getElementById('rbBar'), lb=document.getElementById('rbLb');
  function ind(t){ bar.classList.add('ind'); bar.firstChild.style.width=''; lb.textContent=t; }
  function det(p,t){ bar.classList.remove('ind'); bar.firstChild.style.width=p+'%'; lb.textContent=t; }
  rb.classList.add('on'); ind('시작하는 중…');
  var t0=Date.now();
  function tick(){
    fetch(CTX+'/prod/stockRebuildProgress.do', { method:'POST', credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(p){ var el=Math.round((Date.now()-t0)/1000)+'초';
        if(!p || !p.running){ ind('진행 중… (경과 '+el+')'); return; }
        if(p.total>0) det(Math.min(95, p.done*95/p.total), p.phase+'  ('+p.done+' / '+p.total+' · 경과 '+el+')');   /* 마지막 현재고 집계가 남아 95% 에서 멈춘다 */
        else ind((p.phase||'준비 중…')+'  (경과 '+el+')'); })
      .catch(function(){ ind('진행 중… (경과 '+Math.round((Date.now()-t0)/1000)+'초)'); });
  }
  tick(); var poll=setInterval(tick, 500);
  fetch(CTX+'/prod/stockRebuild.do', { method:'POST', credentials:'same-origin' })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
    .then(function(r){ clearInterval(poll);
      if(!r.ok){ rb.classList.remove('on'); toast('재집계 실패: '+esc((r.t||'').trim()), '⚠️'); return; }
      det(100, '완료'); setTimeout(function(){ rb.classList.remove('on'); toast('출고반영 재집계 완료 · 납기일자 <b>'+esc(r.t||'0')+'</b>건 반영', '✅'); somLoad(); }, 400); })
    .catch(function(e){ clearInterval(poll); rb.classList.remove('on'); toast('통신오류: '+esc(e.message), '⚠️'); });
}
/* ★★다른 메뉴로 가면 표를 <비운다> — 돌아오면 다시 그린다 (2026-09-04 「월별 출고현황 이후 다른 메뉴 이동 시 엄청 느림·잔상」)
     셸(logistics_demo2)은 메뉴를 바꿔도 이 iframe 을 display:none 으로 <살려 둔다>(상태 유지 설계). 그래서 3만 셀짜리 표가
     숨은 채로 문서에 남아 셸의 스타일 계산·GC 를 매번 끌었고, 메뉴를 누르면 옛 화면이 잔상으로 남았다.
     · 판정 = 부모의 <iframe> 요소 크기(window.frameElement.getBoundingClientRect) 가 0 — 아래 hidden() 참고.
       ⚠IntersectionObserver·requestAnimationFrame 은 못 쓴다 — display:none 문서는 「그려지지 않는 문서」라 그 콜백이 아예 안 온다
         (처음 IO 로 만들었다가 안 깨어나 1초 타이머로 바꿈). setTimeout 은 숨어도 돈다.
     · 숨은 지 2초(0.5초 간격 네 번 연속 0)가 되면 표 DOM 만 지운다(RAW·조건·스크롤 위치는 남긴다). 그 안에 돌아오면 아무 일도 없다.
     · 다시 보이면 RAW 로 그대로 다시 그린다(서버 조회 없음, fixed 레이아웃이라 예전보다 빠르다). 스크롤 자리도 되돌린다. */
var _somSleptScroll=null, _somHidN=0;
(function(){
  var card=document.getElementById('card');
  function sleep(){
    if(!RAW || !card.querySelector('table.mx')) return;
    _somSleptScroll={ l:card.scrollLeft, t:card.scrollTop };
    card.innerHTML='<div class="empty">다른 화면을 보는 동안 표를 접어 두었습니다 — 돌아오면 다시 그립니다.</div>'; }
  function wake(){
    if(!_somSleptScroll || !RAW) return;
    var sc=_somSleptScroll; _somSleptScroll=null;
    somRender();
    card.scrollLeft=sc.l; card.scrollTop=sc.t; }
  /* ⚠innerWidth 는 못 쓴다 — display:none 이 되어도 Chrome 은 마지막 폭(1177 등)을 그대로 돌려준다(2026-09-04 하네스 실측).
       같은 출처라 부모의 <iframe> 요소를 직접 본다 : 숨은 상자는 폭·높이 0. */
  function hidden(){ try{ var fe=window.frameElement; if(!fe) return false; var r=fe.getBoundingClientRect(); return !(r.width>0 && r.height>0); }catch(e){ return false; } }
  setInterval(function(){
    var hid = hidden();
    if(hid){ _somHidN++; if(_somHidN===4) sleep(); }      /* 0.5초 × 4 = 숨은 지 2초 */
    else { _somHidN=0; if(_somSleptScroll) wake(); }        /* 돌아오면 0.5초 안에 다시 그린다 */
  }, 500);
})();
function somFit(){ var c=document.getElementById('card'); if(!c) return;
  /* 하단 내역 패널이 열려 있으면 표는 화면 절반만 쓴다 */
  var d=document.getElementById('dtl'), open=!!(d && d.style.display==='block');
  var top=c.getBoundingClientRect().top+(window.pageYOffset||0);
  c.style.maxHeight=Math.max(220, Math.round((window.innerHeight-top-16)*(open?0.5:1)))+'px'; }
window.addEventListener('resize', somFit);
/* 엑셀 — 화면 표 그대로(머리 2줄: 사업장 병합 + 품목, 현재고 줄 포함). 부모의 xlsx 라이브러리를 빌려 쓴다(택배납기관리와 같은 방식) */
function somExcel(){
  if(!RAW){ toast('먼저 조회하세요.'); return; }
  var m=_somM||somBuild(); if(!m.cols.length){ toast('출력할 자료가 없습니다.'); return; }
  var aoa=[], h1=['년월 / 사업장 ▸ 품목','합계'], h2=['',''];
  var merges=[{s:{r:0,c:0},e:{r:1,c:0}},{s:{r:0,c:1},e:{r:1,c:1}}], ci=2;
  m.gord.forEach(function(gk){ var g=m.grp[gk], n=g.iord.length;
    h1.push(g.nm); for(var i=1;i<n;i++) h1.push('');
    if(n>1) merges.push({s:{r:0,c:ci},e:{r:0,c:ci+n-1}});
    g.iord.forEach(function(cd){ h2.push(cd+' '+shortNm(g.items[cd].nm, g.nm)); }); ci+=n; });
  aoa.push(h1); aoa.push(h2);
  var sr=['현재고',''], st=0, any=false, seen={};
  m.cols.forEach(function(c){ var v=m.stock[c.cd]; if(v==null){ sr.push(''); return; } any=true; if(!seen[c.cd]){ seen[c.cd]=1; st+=v; } sr.push(v); });
  sr[1]=any?st:''; aoa.push(sr);
  m.yord.forEach(function(ym){ var r=[ymLabel(ym), m.yms[ym]]; m.cols.forEach(function(c){ var v=m.cell[ym+'|'+c.g+'|'+c.cd]; r.push(v>0?v:''); }); aoa.push(r); });
  var tr=['기간 합계',0], g0=0; m.cols.forEach(function(c){ var t=m.grp[c.g].items[c.cd].tot; tr.push(t); g0+=t; }); tr[1]=g0; aoa.push(tr);
  var P=window.parent, fn='월별출고현황_'+document.getElementById('frDt').value.replace(/-/g,'')+'-'+document.getElementById('toDt').value.replace(/-/g,'')+'.xlsx';
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); ws['!cols']=[{wch:16},{wch:10}].concat(m.cols.map(function(){ return {wch:16}; }));
    ws['!merges']=merges;
    ws['!freeze']={xSplit:2, ySplit:2, topLeftCell:'C3', activePane:'bottomRight', state:'frozen'};
    var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'월별 출고현황'); LIB.writeFile(wb,fn); toast('<b>'+esc(fn)+'</b><br>엑셀 파일을 내려받았습니다.', '📥'); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB) byLib(LIB); else toast('엑셀 모듈을 못 불러왔습니다.'); }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  toast('엑셀 모듈은 물류관리 메인 안에서만 씁니다.');
}
somLoad();
</script>
</body>
</html>
