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
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  /* 가로표(납기현황표)와 같은 감각 — 첫 두 칸·머리 2줄 고정, 값 없는 칸 회색, 사업장 경계는 굵은 세로선 */
  table.mx{ border-collapse:separate; border-spacing:0; font-size:14px; --h1:40px; }
  table.mx th, table.mx td{ border:1px solid var(--bd); padding:6px 9px; white-space:nowrap; text-align:center; background:#fff; }
  table.mx .gs{ border-left:2px solid #9fb6cc; }
  table.mx .cn{ position:sticky; left:0; z-index:2; text-align:left; font-weight:700; width:150px; min-width:150px; max-width:150px; background:#fff; }
  table.mx td.cn small.src{ display:block; font-size:11px; font-weight:400; color:#6b7a89; line-height:1.2; }
  table.mx .rt{ position:sticky; left:150px; z-index:2; width:90px; min-width:90px; max-width:90px; background:#fff2cc; font-weight:800; }
  table.mx thead th{ position:sticky; top:0; z-index:3; background:#dfeaf5; color:#1f2a37; font-size:14px; }
  table.mx thead th.cn, table.mx thead th.rt{ z-index:4; }
  /* 1단 = 사업장(매칭명) · 2단 = 품목. 2단은 1단 높이(--h1, 그릴 때 잰다)만큼 내려 붙인다 */
  table.mx thead th.gh{ background:#cfe0f3; font-size:14px; font-weight:800; color:#123c63; white-space:nowrap; line-height:1.3; min-width:118px; text-align:left; }
  /* 사업장 이름은 칸 안에서 sticky — 40품목짜리 사업장은 칸이 수천 px 라 가운데 두면 이름이 화면 밖에 간다. 고정칸(150+90) 바로 뒤에 붙인다 */
  table.mx thead th.gh .gl{ position:sticky; left:250px; display:inline-block; }
  table.mx thead th.gh small{ display:block; font-size:11.5px; font-weight:600; color:#4c6a8a; }
  table.mx thead tr.r2 th{ top:var(--h1); }
  table.mx thead th.it{ background:#eef4fa; white-space:normal; min-width:118px; max-width:170px; line-height:1.4; font-size:12.5px; font-weight:600; }
  table.mx thead th.it .cd{ display:block; font-weight:800; color:#1f2a37; }
  table.mx thead th.it .nm{ color:#5a6b7a; font-weight:400; }
  table.mx td.none{ background:#f1f3f5; }
  table.mx td.n{ font-weight:700; }
  table.mx tr.stk td{ background:#fff4e6; font-weight:800; color:#137a6c; }
  table.mx tr.stk td.cn, table.mx tr.stk td.rt{ background:#fde9cc; }
  table.mx tr.stk td.neg{ color:#c0392b; }
  table.mx tr.sum td{ background:#e2efda; font-weight:800; color:#375623; }
  table.mx tr.sum td.cn, table.mx tr.sum td.rt{ background:#d5e8c6; }
  table.mx tbody td{ height:30px; }
  .empty{ padding:30px; text-align:center; color:#9aa7b3; }
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
    <input type="text" id="q" placeholder="사업장/품목코드/품목명 거르기" oninput="somRender()" style="width:220px">
    <button class="btn" onclick="somExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">-</span>
  </div>
  <div class="card" id="card"><div class="empty">기간을 고르고 [조회]를 누르세요.</div></div>
  <div class="dtl" id="dtl">
    <div class="dh" id="dtlHead"></div>
    <div class="cols">
      <div class="col"><div class="ct">📤 출고내역 <span id="dtlOutSum"></span></div><div class="tb" id="dtlOut"></div></div>
      <div class="col"><div class="ct">📥 입고내역 <span id="dtlInSum"></span></div><div class="tb" id="dtlIn"></div></div>
    </div>
  </div>
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
/* 기본 기간 = 12개월 전 1일 ~ 오늘 (일자 단위, 2026-09-03 「일자까지 보여주는 형식으로」) */
(function(){
  function d10(x){ return x.getFullYear()+'-'+('0'+(x.getMonth()+1)).slice(-2)+'-'+('0'+x.getDate()).slice(-2); }
  var d=new Date(), to=d10(d);
  d.setMonth(d.getMonth()-12); d.setDate(1);
  var fr=d10(d);
  document.getElementById('frDt').value=fr; document.getElementById('toDt').value=to;

})();
function somLoad(){
  var fr=document.getElementById('frDt').value, to=document.getElementById('toDt').value;
  if(!fr||!to){ toast('기간을 고르세요.'); return; }
  if(fr>to){ var t=fr; fr=to; to=t; document.getElementById('frDt').value=fr; document.getElementById('toDt').value=to; }
  document.getElementById('card').innerHTML=qprog('월별 출고량을 조회하는 중… (기간 '+fr+' ~ '+to+')');
  fetch(CTX+'/prod/stockOutMonthList.do', { method:'POST', credentials:'same-origin',
         headers:{'Content-Type':'application/x-www-form-urlencoded'},
         body:'frDt='+encodeURIComponent(fr.replace(/-/g,''))+'&toDt='+encodeURIComponent(to.replace(/-/g,'')) })
    .then(function(r){ return r.json(); })
    .then(function(j){ RAW=j||{months:[],stock:[]}; somRender(); })
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
function somRender(){
  if(!RAW) return;
  var m=somBuild(), card=document.getElementById('card');
  if(!m.cols.length){ card.innerHTML='<div class="empty">해당 기간에 출고가 없습니다.</div>'; document.getElementById('cnt').textContent='-'; return; }
  /* 머리 1단 = 사업장(품목수 · 기간출고), 2단 = 품목 — 납기현황표 가로표와 같은 꼴 */
  var h='<table class="mx"><thead><tr class="r1"><th class="cn">년월 / 사업장</th><th class="rt">합계</th>';
  m.gord.forEach(function(gk){ var g=m.grp[gk];
    h+='<th class="gh gs" colspan="'+g.iord.length+'" title="'+esc(g.nm)+'"><span class="gl">'+esc(g.nm)+'<small>'+num(g.iord.length)+'품목 · '+num(g.tot)+'</small></span></th>'; });
  h+='</tr><tr class="r2"><th class="cn">품목</th><th class="rt"></th>';
  m.cols.forEach(function(c){ var it=m.grp[c.g].items[c.cd];
    h+='<th class="it'+(c.first?' gs':'')+'" title="'+esc(c.cd+' '+it.nm)+'"><span class="cd">'+esc(c.cd)+'</span><span class="nm">'+esc(shortNm(it.nm, m.grp[c.g].nm))+'</span></th>'; });
  h+='</tr></thead><tbody>';
  /* ① 맨 위 현재고 — 품목 잔량(사업장 무관). 같은 품목은 같은 값이 되풀이되고 합계는 품목당 한 번만. 값이 없으면 빈칸 */
  var stkTot=0, stkAny=false, stkCells='', seen={};
  m.cols.forEach(function(c){ var v=m.stock[c.cd], gs=c.first?' gs':'';
    if(v==null){ stkCells+='<td class="none'+gs+'"></td>'; return; }
    stkAny=true; if(!seen[c.cd]){ seen[c.cd]=1; stkTot+=v; }
    stkCells+='<td class="'+(v<0?'neg':'')+gs+'" data-ym="" data-g="'+esc(c.g)+'" data-cd="'+esc(c.cd)+'">'+num(v)+'</td>'; });
  h+='<tr class="stk"><td class="cn">현재고 <small style="font-weight:400;color:#6b7a89">(품목)</small></td><td class="rt">'+(stkAny?num(stkTot):'')+'</td>'+stkCells+'</tr>';
  /* ② 년월 줄 — 최근월부터 */
  var grand=0;
  m.yord.forEach(function(ym){
    h+='<tr><td class="cn">'+ymLabel(ym)+'</td><td class="rt">'+num(m.yms[ym])+'</td>'; grand+=m.yms[ym];
    m.cols.forEach(function(c){ var v=m.cell[ym+'|'+c.g+'|'+c.cd], gs=c.first?' gs':'';
      h+= (v>0) ? ('<td class="n'+gs+'" data-ym="'+esc(ym)+'" data-g="'+esc(c.g)+'" data-cd="'+esc(c.cd)+'">'+num(v)+'</td>') : ('<td class="none'+gs+'"></td>'); });
    h+='</tr>';
  });
  /* ③ 기간 합계 */
  h+='<tr class="sum"><td class="cn">기간 합계</td><td class="rt">'+num(grand)+'</td>';
  m.cols.forEach(function(c){ h+='<td class="'+(c.first?'gs':'')+'" data-ym="" data-g="'+esc(c.g)+'" data-cd="'+esc(c.cd)+'">'+num(m.grp[c.g].items[c.cd].tot)+'</td>'; });
  card.innerHTML=h+'</tr></tbody></table>';
  document.getElementById('cnt').innerHTML='사업장 <b>'+num(m.gord.length)+'</b>곳 · 품목 <b>'+num(m.nprod)+'</b>종 · <b>'+num(m.yord.length)+'</b>개월 · 기간 출고 <b>'+num(grand)+'</b>';
  somFit();
  /* 2단 머리의 고정 위치 = 1단 실제 높이 */
  var r1=card.querySelector('thead tr.r1'), tb=card.querySelector('table.mx');
  if(r1 && tb) tb.style.setProperty('--h1', Math.round(r1.getBoundingClientRect().height)+'px');
}
/* ── 셀 클릭 → 하단 출고내역·입고내역 (2026-09-03 요청) ──
   · 월 셀 = 그 달, 현재고·기간합계 셀 = 조회 기간 전체. 사업장은 그 열의 사업장(매칭명) 하나.
   · 출고내역 = /prod/stockOutDetail.do (통합 원천: 정산서 있는 날은 정산서, 없으면 발주현황표 — 표와 같은 규칙)
   · 입고내역 = 같은 응답의 수불원장(ledger)에서 출고(O)가 아닌 행(입고 I·반품 R·조정 A)을 년월로 걸러 보여 준다 */
var DTL_LAST=null;
document.getElementById('card').addEventListener('click', function(ev){
  var td=ev.target.closest ? ev.target.closest('td[data-cd]') : null; if(!td || !RAW) return;
  var m=somBuild(), g=m.grp[td.getAttribute('data-g')]; if(!g) return;
  var it=g.items[td.getAttribute('data-cd')]; if(!it) return;
  var prev=document.querySelector('table.mx td.pick'); if(prev) prev.classList.remove('pick'); td.classList.add('pick');
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
function somDetailClose(){ DTL_LAST=null; document.getElementById('dtl').style.display='none'; var p=document.querySelector('table.mx td.pick'); if(p) p.classList.remove('pick'); somFit(); }
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
function somFit(){ var c=document.getElementById('card'); if(!c) return;
  /* 하단 내역 패널이 열려 있으면 표는 화면 절반만 쓴다 */
  var d=document.getElementById('dtl'), open=!!(d && d.style.display==='block');
  var top=c.getBoundingClientRect().top+(window.pageYOffset||0);
  c.style.maxHeight=Math.max(220, Math.round((window.innerHeight-top-16)*(open?0.5:1)))+'px'; }
window.addEventListener('resize', somFit);
/* 엑셀 — 화면 표 그대로(머리 2줄: 사업장 병합 + 품목, 현재고 줄 포함). 부모의 xlsx 라이브러리를 빌려 쓴다(택배납기관리와 같은 방식) */
function somExcel(){
  if(!RAW){ toast('먼저 조회하세요.'); return; }
  var m=somBuild(); if(!m.cols.length){ toast('출력할 자료가 없습니다.'); return; }
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
