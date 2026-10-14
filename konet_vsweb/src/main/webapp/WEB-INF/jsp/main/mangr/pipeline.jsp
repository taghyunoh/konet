<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>진행 현황</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<!--
  진행 현황 (2026-10-06 신설 — 사용자 「①발주리스트등록·발주서등록·매입전환 ②견적 등록·제출·채택·판매등록, 두 가지 진행 상황 볼 수 있게」
             → 「정보현황 메뉴에 추가해서 구현」) — 정보 현황 ▸ 진행 현황. 셸 iframe(logiFrame).
  · 두 흐름을 단계 띠로 나란히 보여 주고, 단계를 누르면 아래에 그 단계의 목록이 뜬다. 줄을 누르면 그 일을 하는 화면으로 간다.
      ① 발주 : 발주목록 등록(대시보드 [📋 발주목록 실행] → TBL_PO_REQ) → 발주서 등록(발주서 관리) → 매입전환(발주서 [📦 매입전환])
      ② 견적 : 작성 중 → 제출완료 → 채택 → 판매등록(판매 등록 [📄 견적서] 로 이어진 판매전표)
  · 발주는 기간을 걸지 않는다 — 미등록·미입고는 «밀린 일»이라 기간으로 가리면 안 보인다. 견적은 견적일 기간(기본 최근 3개월).
  · 세는 식은 다른 화면과 같다(서버 selectPipeline* 주석) — 발주 잔량 = 재고현황 「입고예정」 · 견적 = 마지막 판만.
  · 0 건인 단계도 숨기지 않는다 — 「밀린 일이 없다」와 「안 쓰고 있다」가 둘 다 0 으로 보여야 가를 수 있다.
  · [2026-10-14] 맨 위 「📌 업무 진행 상황」(사용자 「경영자가 보아야 할 내용 위주로」 → 「업무 진행 상황 위주로」) — 출고·매출정산·수금·월 마감·영업 후속의
    밀린 일·확인할 일. 늘 오늘 기준(견적 기간과 무관). 자료 /mangr/pipelineWork.do · 셈은 서비스 selectPipelineWork 머리말.
  자료 /mangr/pipelineStat.do(집계 둘) · /mangr/pipelineList.do?stage=…(단계 목록)
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amb:#b06a00; --ink:#1f2a37; --sub:#6b7a89; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:var(--ink); background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; }   /* 설명 줄을 뺀 만큼 아래 여백만 조금(2026-10-14) */
  .sub{ color:var(--sub); margin-bottom:12px; font-size:12.5px; line-height:1.6; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .bar .lbl{ font-size:12.5px; color:#37475a; font-weight:700; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .stamp{ margin-left:auto; color:#8a98a8; font-size:12px; }

  /* 흐름 카드 — 한 줄 = 한 흐름. 단계는 화살표로 이어진 칸 */
  .flow{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:12px 14px; margin-bottom:12px; }
  .flow .hd{ display:flex; align-items:baseline; gap:10px; margin-bottom:10px; flex-wrap:wrap; }
  .flow .hd b{ font-size:15.5px; }
  .flow .hd .note{ font-size:12px; color:var(--sub); }
  .steps{ display:flex; align-items:stretch; gap:0; flex-wrap:wrap; }
  .step{ flex:1 1 170px; min-width:150px; border:1px solid var(--bd); border-radius:9px; padding:10px 12px; cursor:pointer; background:#fbfcfd; position:relative; }
  .step:hover{ border-color:var(--teal); background:#f4faf8; }
  .step.on{ border-color:var(--teal); box-shadow:0 0 0 2px rgba(19,122,108,.18) inset; background:#eef7f4; }
  .step .no{ font-size:11.5px; color:var(--sub); font-weight:700; }
  .step .nm{ font-size:13.5px; font-weight:800; margin:2px 0 4px; }
  .step .v{ font-size:24px; font-weight:800; font-variant-numeric:tabular-nums; line-height:1.15; }
  .step .v small{ font-size:12px; color:var(--sub); font-weight:700; margin-left:2px; }
  .step .x{ font-size:12px; color:var(--sub); margin-top:3px; min-height:16px; }
  .step.zero .v{ color:#b8c2cc; }
  .step.wait .v{ color:var(--amb); }
  .step.done .v{ color:var(--teal); }
  .step.bad  .v{ color:var(--red); }
  .arrow{ flex:0 0 22px; display:flex; align-items:center; justify-content:center; color:#b8c2cc; font-size:18px; }
  .side{ display:flex; gap:8px; margin-top:8px; flex-wrap:wrap; }
  .side .chip{ border:1px solid var(--bd); border-radius:14px; padding:3px 11px; font-size:12.5px; background:#fff; cursor:pointer; color:#37475a; }
  .side .chip:hover{ border-color:var(--teal); }
  .side .chip.on{ border-color:var(--teal); background:#eef7f4; }
  .side .chip b{ margin-left:3px; }
  .err{ color:var(--red); font-size:12.5px; margin-top:6px; }

  /* 업무 진행 상황 (2026-10-14 「경영자가 보아야 할 내용 위주로」 → 「업무 진행 상황 위주로」) — 묶음 다섯(출고·매출정산·수금·월 마감·영업 후속), 칸을 누르면 그 일을 하는 화면 */
  .work{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:12px 14px; margin-bottom:12px; }
  .work .whd{ display:flex; align-items:baseline; gap:10px; flex-wrap:wrap; margin-bottom:10px; }
  .work .whd b{ font-size:15.5px; }
  .work .whd .note{ font-size:12px; color:var(--sub); }
  /* 접기·펼치기 단추 — 아이콘 + 색 (2026-10-14 사용자 「체크 아이콘 추가 색깔 표시」 : 흰 글자 단추가 눈에 안 띄었다). 펼쳐진 동안은 테두리 청록, 접힌 동안은 청록 칠 */
  .work .whd .fold{ margin-left:auto; height:28px; border:1px solid var(--teal); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:12.5px; font-weight:700; color:var(--teal); font-family:inherit; }
  .work .whd .fold:hover{ background:#eef7f4; }
  .work.folded .whd .fold{ background:var(--teal); color:#fff; }
  .work.folded .wgrid{ display:none; }
  .wgrid{ display:grid; grid-template-columns:repeat(auto-fit, minmax(220px, 1fr)); gap:10px; }
  .wgrp{ border:1px solid #e3e8ee; border-radius:9px; padding:8px; background:#fbfcfd; display:flex; flex-direction:column; gap:6px; }
  .wgrp .gt{ font-size:13px; font-weight:800; color:#37475a; padding:0 2px 2px; }
  .wt{ border:1px solid var(--bd); border-left:4px solid #b8c2cc; border-radius:7px; background:#fff; padding:6px 9px; cursor:pointer; }
  .wt:hover{ border-color:var(--teal); border-left-color:var(--teal); }
  .wt .lb{ font-size:12px; color:#5a6b7a; font-weight:700; }
  .wt .vv{ font-size:19px; font-weight:800; font-variant-numeric:tabular-nums; line-height:1.25; }
  .wt .vv small{ font-size:12px; color:var(--sub); font-weight:700; margin-left:2px; }
  .wt .sb{ font-size:11.5px; color:var(--sub); min-height:14px; }
  .wt.ok{ border-left-color:#7cc5b2; } .wt.ok .vv{ color:#1f7a5a; font-size:15px; }
  .wt.info{ border-left-color:#7ea3e0; } .wt.info .vv{ color:#2f4f9a; }
  .wt.warn{ border-left-color:#e2a33b; background:#fffaf0; } .wt.warn .vv{ color:var(--amb); }
  .wt.bad{ border-left-color:var(--red); background:#fff6f5; } .wt.bad .vv{ color:var(--red); }
  .wt.off .vv{ color:#9aa7b3; font-size:15px; }
  .wt.err .vv{ color:#9aa7b3; font-size:13px; }

  /* 단계 목록 */
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; max-height:calc(100vh - 470px); min-height:160px; }
  .lhd{ display:flex; align-items:center; gap:10px; margin:2px 2px 8px; flex-wrap:wrap; }
  .lhd b{ font-size:14.5px; }
  .lhd .cnt{ margin-left:auto; color:#37475a; font-size:13px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:4px 12px; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:8px 9px; text-align:center; position:sticky; top:0; z-index:1; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:6px 9px; text-align:center; vertical-align:middle; }
  table.g th:last-child, table.g td:last-child{ border-right:none; }
  table.g td.l{ text-align:left; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g tr.go{ cursor:pointer; }
  table.g tr.go:hover td{ background:#f4faf8; }
  .tag{ display:inline-block; font-size:11.5px; font-weight:800; border-radius:6px; padding:2px 8px; white-space:nowrap; }
  .tag.W{ background:#eef2f5; color:#5b6b7b; } .tag.S{ background:#e8eefb; color:#2f4f9a; } .tag.A{ background:#e3f7df; color:#1f7a34; }
  .tag.R{ background:#fdecec; color:#c0392b; } .tag.H{ background:#fff3c4; color:#8a5a00; } .tag.SALE{ background:#e3f4ef; color:#0e6657; }
  .empty{ padding:36px; text-align:center; color:#8a98a8; line-height:1.7; }
</style>
</head>
<body>
<div class="wrap">
  <%-- 제목 아래 두 줄 설명은 뺐다 (2026-10-14 사용자 「설명 제거 공간 확보를 위해」) — 그 내용은 제목 툴팁과 흐름 카드의 작은 글씨(발주목록 등록 → … / 작성 → …)에 남아 있다 --%>
  <h2 title="발주 = 발주목록 등록 → 발주서 등록 → 매입전환 · 견적 = 작성 → 제출 → 채택 → 판매등록.&#10;단계를 누르면 아래에 그 목록이 뜨고, 줄을 누르면 그 일을 하는 화면으로 갑니다.&#10;발주는 기간 없이 지금 열린 일 전부(밀린 일이 기간에 가려지지 않게) · 견적은 견적일 기간으로 셉니다.">🔄 진행 현황</h2>
  <%-- 업무 진행 상황 (2026-10-14) — 밀린 일·확인할 일. 자료 /mangr/pipelineWork.do (서비스 selectPipelineWork) --%>
  <div class="work" id="work">
    <div class="whd"><b>📌 업무 진행 상황</b><span class="note" id="wNote">오늘 기준 · 칸을 누르면 그 일을 하는 화면으로 갑니다</span>
      <button class="fold" id="wFold" onclick="workFold()" title="업무 진행 상황을 접거나 펼칩니다 (이 PC 에 기억)">▲ 접기</button></div>
    <div class="wgrid" id="wGrid"><div class="wgrp"><div class="gt">불러오는 중…</div></div></div>
  </div>

  <div class="bar">
    <span class="lbl">견적 기간</span>
    <input type="date" id="fr"> <span style="color:#8a98a8">~</span> <input type="date" id="to">
    <button class="btn" onclick="setRange(1)">1개월</button>
    <button class="btn" onclick="setRange(3)">3개월</button>
    <button class="btn" onclick="setRange(12)">1년</button>
    <button class="btn btn-teal" onclick="load()">🔍 조회</button>
    <span class="stamp" id="stamp"></span>
  </div>

  <div class="flow">
    <div class="hd"><b>📋 발주</b><span class="note" id="poNote">발주목록 등록 → 발주서 등록 → 매입전환</span></div>
    <div class="steps" id="poSteps"></div>
    <div class="err" id="poErr"></div>
  </div>

  <div class="flow">
    <div class="hd"><b>📄 견적</b><span class="note" id="qtNote">작성 → 제출 → 채택 → 판매등록</span></div>
    <div class="steps" id="qtSteps"></div>
    <div class="side" id="qtSide"></div>
    <div class="err" id="qtErr"></div>
  </div>

  <div class="lhd"><b id="lTitle">단계를 누르면 그 목록이 여기에 뜹니다</b><span class="cnt" id="lCnt">—</span></div>
  <div class="card"><table class="g"><thead id="lHead"></thead><tbody id="lBody"><tr><td class="empty">위의 단계 하나를 눌러 보세요.</td></tr></tbody></table></div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _stat=null, _stage='';
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body:body||'' }); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function setRange(m){ var t=new Date(), f=new Date(t.getFullYear(), t.getMonth()-m, t.getDate()); document.getElementById('fr').value=ymd(f); document.getElementById('to').value=ymd(t); load(); }

/* ── 단계 정의 — 이름·뜻·색 규칙. kind : wait(밀린 일, 주황) / done(끝난 일, 초록) / mid(가운데) ── */
var PO_STEPS=[
  { key:'REQ',   no:'①', nm:'발주목록 등록',  kind:'wait', tip:'대시보드(납기현황표) [📋 발주목록 실행]이 쌓은 적정재고 미달 품목 중, 아직 발주서에 안 담은 것' },
  { key:'PO',    no:'②', nm:'발주서 등록',    kind:'wait', tip:'발주서에 담아 보냈는데 아직 다 안 들어온 것(잔량이 남은 발주서) — 재고현황 「입고예정」과 같은 셈' },
  { key:'PURCH', no:'③', nm:'매입전환',       kind:'done', tip:'발주서 [📦 매입전환]으로 매입전표가 만들어진 발주서(부분입고면 ②에도 함께 셉니다)' }
];
var QT_STEPS=[
  { key:'W',    no:'①', nm:'작성 중',   kind:'mid',  tip:'견적서 관리에 올렸지만 아직 제출하지 않은 견적' },
  { key:'S',    no:'②', nm:'제출완료',  kind:'wait', tip:'고객에게 냈고 답을 기다리는 견적' },
  { key:'A',    no:'③', nm:'채택',      kind:'wait', tip:'채택됐지만 아직 판매로 이어지지 않은 것도 여기 셉니다 — 판매까지 간 것은 ④에도 셉니다' },
  { key:'SALE', no:'④', nm:'판매등록',  kind:'done', tip:'판매 등록 [📄 견적서]로 이 견적에서 나온 판매전표가 있는 것' }
];
var QT_SIDE=[ { key:'R', nm:'거절' }, { key:'H', nm:'보류' } ];

/* ── 업무 진행 상황 (2026-10-14 사용자 「이 화면에 경영자가 보아야 할 내용 위주로 추가」 → 「업무 진행 상황 위주로」) ──
     밀린 일·확인할 일을 묶음 다섯으로 : 🚚 납기 · 🧾 매출·정산 · 💰 수금 · 🗓 월 마감 · 📄 영업 후속.
     숫자는 그 일을 하는 화면과 같은 셈(서버 selectPipelineWork 머리말). 칸을 누르면 그 화면 메뉴를 그대로 누른다(openMenu).
     색 : 빨강 = 늦었거나 마감을 막는 일 · 주황 = 손봐야 할 일 · 파랑 = 오늘 할 양(문제 아님) · 초록 = 밀린 것 없음.
     기간 칸(견적 기간)과는 무관하다 — 늘 «오늘» 기준. */
var _work=null, _workShip=null, _workSeq=0;
/* 두 요청을 «동시에» 보낸다 (같은 날 「속도가 너무 느립니다」) — 출고 칸(대시보드 조회, 약 1초)은 /mangr/pipelineWorkShip.do 로 따로.
   먼저 온 쪽부터 그린다. 늦게 온 옛 응답(그사이 다시 조회)은 버린다. */
function workLoad(){
  var my=++_workSeq; _work=null; _workShip=null; workRender();
  post('/mangr/pipelineWork.do','').then(function(r){ return r.json(); })
    .then(function(j){ if(my!==_workSeq) return; _work=j||{}; workRender(); })
    .catch(function(e){ if(my!==_workSeq) return; _work={ error:'조회 오류 — '+e.message }; workRender(); });
  post('/mangr/pipelineWorkShip.do','').then(function(r){ return r.json(); })
    .then(function(j){ if(my!==_workSeq) return; _workShip=j||{}; workRender(); })
    .catch(function(e){ if(my!==_workSeq) return; _workShip={ shipErr:e.message }; workRender(); });
}
function workFold(){
  var w=document.getElementById('work'), on=!w.classList.contains('folded');
  w.classList.toggle('folded', on); document.getElementById('wFold').textContent=on?'▼ 펼치기':'▲ 접기';
  try{ localStorage.setItem('plWorkFold', on?'1':'0'); }catch(e){}
}
function ymLbl(ym, base){ ym=String(ym||''); if(ym.length<6) return ym; return (base && ym.slice(0,4)===String(base).slice(0,4)) ? (+ym.slice(4,6))+'월' : ym.slice(0,4)+'-'+ym.slice(4,6); }
/* 이어진 달은 「2~9월」처럼 묶는다 */
function ymRanges(list, base){
  var out=[], i=0, nx=function(y){ var a=+y.slice(0,4), m=+y.slice(4,6)+1; if(m>12){ a++; m=1; } return a+('0'+m).slice(-2); };
  while(i<list.length){ var s=list[i], e=s; while(i+1<list.length && list[i+1]===nx(e)){ i++; e=list[i]; } i++;
    out.push(s===e ? ymLbl(s,base) : (s.slice(0,4)===e.slice(0,4) && s.slice(0,4)===String(base).slice(0,4) ? (+s.slice(4,6))+'~'+(+e.slice(4,6))+'월' : ymLbl(s,base)+' ~ '+ymLbl(e,base))); }
  return out.join(', ');
}
/* 칸 하나 — o = { lv:'ok'|'info'|'warn'|'bad'|'off'|'err', lb, v, unit, sb, go(메뉴 key), tip } */
function wt(o){
  return '<div class="wt '+o.lv+'" onclick="openMenu(\''+o.go+'\')" title="'+esc(o.tip||'')+'">'
    +'<div class="lb">'+esc(o.lb)+'</div><div class="vv">'+o.v+(o.unit?'<small>'+o.unit+'</small>':'')+'</div><div class="sb">'+(o.sb||'')+'</div></div>';
}
function qFmt(x){ return Math.round(x)===x ? fmt(x) : x.toLocaleString(undefined,{ maximumFractionDigits:1 }); }   /* 납기수량 — 정산 배분이면 소수 1자리 */
function wErr(lb, go){ return wt({ lv:'err', lb:lb, v:'읽지 못했습니다', go:go, tip:'잠시 뒤 [🔍 조회]를 다시 눌러 보세요' }); }
function workRender(){
  var g=document.getElementById('wGrid'), W=_work||{}, WS=_workShip;
  if(!_work && !WS){ g.innerHTML='<div class="wgrp"><div class="gt">불러오는 중…</div></div>'; return; }
  if(W.error){ g.innerHTML='<div class="wgrp"><div class="gt" style="color:var(--red)">'+esc(W.error)+'</div></div>'; return; }
  var today=String(W.today||(WS&&WS.today)||''), lastYm=String(W.lastYm||''), thisYm=String(W.thisYm||'');
  document.getElementById('wNote').textContent='오늘 '+d10(today)+' 기준 · 칸을 누르면 그 일을 하는 화면으로 갑니다';
  var ship={}; ((WS&&WS.ship)||[]).forEach(function(r){ ship[String(r.dt)]=r; });
  var h='';
  /* 🚚 납기 — 대시보드(납기현황표) 「납기수량(BOX)」과 같은 셈(서버 selectPipelineWork 머리말).
       (같은 날 사용자 「택배 미출력 표시 제외하고 출고 줄이 아닌 대시보드에 있는 납기수량으로」 — 종전 「n줄 · 사업장 · 박스」와 택배 칸을 바꿨다) */
  /* 이름 (같은 날 사용자 「오늘 출고를 이전 출고로, 내일을 당일로」 · 「당일 출고」) — 대시보드가 내일 출고일자를 «당일»로 연다 */
  h+='<div class="wgrp"><div class="gt">🚚 출고</div>';
  if(!WS) h+=wt({ lv:'off', lb:'이전 출고 · 당일 출고', v:'불러오는 중…', go:'shipstatus2' });
  else if(WS.shipErr || WS.error) h+=wErr('이전·당일 출고','shipstatus2');
  /* 이전 출고 = 당일 전 마지막으로 출고가 있는 날(같은 날 「당일 이전 중 출고일자 있는 것 기준으로」) — 서버 prevDt. 주말·공휴일 뒤면 오늘이 아니다 */
  else [['이전 출고', String(WS.prevDt||WS.today||'')], ['당일 출고', String(WS.tomorrow||'')]].forEach(function(a){
    var r=ship[a[1]]||{}, q=n(r.qty);
    h+=wt({ lv:q?'info':'off', lb:a[0]+' ('+d10(a[1]).slice(5)+')', v:q?qFmt(q):'없음', unit:q?'BOX':'', go:'shipstatus2',
            sb:q?'품목 '+fmt(r.items)+' · 출고장 '+fmt(r.zones):'', tip:(a[0]==='이전 출고'?'당일 전 마지막으로 출고가 있는 날 · ':'대시보드가 «당일»로 여는 내일 출고일자 · ')+'납기현황표(대시보드)의 「납기수량(BOX)」과 같은 셈 — 그 날 정산서가 있으면 정산 수량' }); });
  h+='</div>';
  if(!_work){ h+='<div class="wgrp"><div class="gt">불러오는 중…</div></div>'; g.innerHTML=h; return; }
  /* 🧾 매출·정산 */
  h+='<div class="wgrp"><div class="gt">🧾 매출·정산</div>';
  if(W.unmatchedErr) h+=wErr('출고미상','closeSales');
  else { var um=W.unmatched||{};
    [['last', lastYm], ['this', thisYm]].forEach(function(a){
      var x=um[a[0]]||{}, c=n(x.cnt);
      h+=wt({ lv:c?(a[0]==='last'?'bad':'warn'):'ok', lb:'정산서 출고미상 · '+ymLbl(a[1], today), v:c?fmt(c):'없음', unit:c?'건':'', go:'closeSales',
              sb:c?fmt(x.amt)+'원이 매출마감에서 빠집니다':'정산서가 모두 출고와 맞음',
              tip:'정산서에는 있는데 출고 자료에 짝이 없는 줄(매출마감 경고와 같은 셈) — 마감 확정 전에 맞춰야 합니다' }); }); }
  if(W.miscErr) h+=wErr('품목코드 미매핑','xrefAudit');
  else { var um2=n((W.misc||{}).unmapped);
    h+=wt({ lv:um2?'warn':'ok', lb:'품목코드 미매핑 (최근 30일 출고)', v:um2?fmt(um2):'없음', unit:um2?'품목':'', go:'xrefAudit',
            sb:um2?'재고·매출에 안 잡힙니다':'', tip:'출고 자료의 품목코드가 우리 상품에 연결되지 않은 것(품목코드(매핑) 점검 ①)' }); }
  h+='</div>';
  /* 💰 수금 */
  h+='<div class="wgrp"><div class="gt">💰 수금</div>';
  if(W.recvErr) h+=wErr('미수 경과','custbal');
  else { var rv=W.recv||{}, bc=n(rv.badCnt), wc=n(rv.warnCnt);
    h+=wt({ lv:bc?'bad':'ok', lb:'미수 '+n(rv.bad)+'일 넘음', v:bc?fmt(bc):'없음', unit:bc?'곳':'', go:'custbal',
            sb:bc?fmt(rv.badAmt)+'원':'', tip:'마지막 수금일(없으면 마지막 매출일)부터 '+n(rv.bad)+'일 넘게 지난 받을 돈(거래처별 채권·채무 「미수 경과」와 같은 셈, 기준은 회사 설정)' });
    h+=wt({ lv:wc>bc?'warn':'ok', lb:'미수 '+n(rv.warn)+'일 넘음 (위 포함)', v:wc?fmt(wc):'없음', unit:wc?'곳':'', go:'custbal',
            sb:wc?fmt(rv.warnAmt)+'원 — 독촉 목록':'', tip:'거래처별 채권·채무 ▸ 「'+n(rv.warn)+'일 넘긴 것만」과 같은 목록' });
    h+=wt({ lv:n(rv.recvCnt)?'info':'off', lb:'받을 돈 있는 거래처', v:n(rv.recvCnt)?fmt(rv.recvCnt):'없음', unit:n(rv.recvCnt)?'곳':'', go:'custbal',
            sb:n(rv.recvCnt)?'합계 '+fmt(rv.recvAmt)+'원':'', tip:'거래처별 채권·채무의 받을금액 합(오늘까지)' }); }
  h+='</div>';
  /* 🗓 월 마감 */
  h+='<div class="wgrp"><div class="gt">🗓 월 마감</div>';
  if(W.closingErr) h+=wErr('월 마감','closeStatus');
  else { var cl=W.closing||{}, open=cl.open||[];
    h+=wt({ lv:cl.lastClosed?'ok':'bad', lb:ymLbl(lastYm, today)+' 매출 마감', v:cl.lastClosed?'✓ 확정':'미확정', go:'closeStatus',
            sb:cl.lastClosed?'':'마감현황(월계표)에서 [확정]', tip:'마감현황(월계표)의 월 마감 확정(매출·매입·재고가 한 번에 굳습니다)' });
    var older=open.filter(function(y){ return y!==lastYm; });
    h+=wt({ lv:older.length?'warn':'ok', lb:'그전 미확정 달', v:older.length?fmt(older.length):'없음', unit:older.length?'개월':'', go:'closeStatus',
            sb:older.length?ymRanges(older, today):'', tip:'정산서 자료가 있는 첫 달부터 지난달 전까지 마감 확정이 안 된 달' });
    h+=wt({ lv:cl.rcvUsed?(cl.lastRcvClosed?'ok':'warn'):'off', lb:ymLbl(lastYm, today)+' 수금 마감', v:cl.lastRcvClosed?'✓ 확정':(cl.rcvUsed?'미확정':'안 씀'), go:'custbal',
            sb:cl.rcvUsed?'':'채권·채무 「이 달 마감 확정」을 아직 한 번도 안 썼습니다', tip:'거래처별 채권·채무 ▸ [🔒 이 달 마감 확정](거래처별 이월·매출·수금을 굳힘)' }); }
  h+='</div>';
  /* 📄 영업 후속 */
  h+='<div class="wgrp"><div class="gt">📄 영업 후속</div>';
  if(W.miscErr) h+=wErr('견적 후속','quoteMng');
  else { var ms=W.misc||{}, qo=n(ms.qtOld), qa=n(ms.qtAdoptWait);
    h+=wt({ lv:qo?'warn':'ok', lb:'제출 후 14일 넘게 답 없는 견적', v:qo?fmt(qo):'없음', unit:qo?'건':'', go:'quoteMng',
            sb:qo?'채택·거절·보류를 받아 적으세요':'', tip:'제출완료 상태로 제출일부터 14일이 넘은 견적(기간과 무관, 마지막 판만)' });
    h+=wt({ lv:qa?'warn':'ok', lb:'채택됐는데 판매 전', v:qa?fmt(qa):'없음', unit:qa?'건':'', go:'salesreg',
            sb:qa?'판매 등록 ▸ [📄 견적서]로 가져오세요':'', tip:'채택된 견적 중 아직 판매전표로 이어지지 않은 것(기간과 무관)' }); }
  h+='</div>';
  g.innerHTML=h;
}
(function(){ try{ if(localStorage.getItem('plWorkFold')==='1'){ document.getElementById('work').classList.add('folded'); document.getElementById('wFold').textContent='▼ 펼치기'; } }catch(e){} })();

function load(){
  workLoad();   /* 업무 진행 상황(맨 위)도 같이 — 기간과 무관하게 오늘 기준 */
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  post('/mangr/pipelineStat.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(j){ _stat=j||{}; render(); if(_stage) list(_stage); adoptLoad();
      var d=new Date(); document.getElementById('stamp').textContent='집계 '+ymd(d)+' '+('0'+d.getHours()).slice(-2)+':'+('0'+d.getMinutes()).slice(-2); })
    .catch(function(e){ document.getElementById('poErr').textContent='조회 오류 — '+e.message; });
}
function qtMap(){ var m={}; ((_stat&&_stat.quote)||[]).forEach(function(r){ m[r.statGb]=r; }); return m; }
/* ── 제출 → 채택 걸린 기간 (2026-10-13 「채택한 경우 제출해서 채택까지 걸리는 기간 체크 그리고 평균」) ──
     한 건 = 채택일 − 제출일(날짜 차, 같은 날이면 0일 = 당일). 두 일자가 다 있어야 센다 —
     제출을 건너뛰고 바로 채택한 견적(제출일 없음)은 평균에서 빼고 따로 센다(지어 넣지 않는다).
     ★카드의 평균은 ③ 채택 목록(pipelineList stage=A)을 그대로 받아 센다 — 목록과 카드가 같은 줄을 본다. 서버 무변경. */
var _adopt=null, _adoptSeq=0;
function dUtc(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? Date.UTC(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8)) : null; }
function adoptDays(r){
  var a=dUtc(r&&r.submitDt), b=dUtc(r&&r.adoptDt);
  if(a==null||b==null) return null;
  var d=Math.round((b-a)/86400000);
  return d<0 ? null : d;          // 채택일이 제출일보다 앞이면 잘못 적힌 것 — 평균에서 뺀다
}
function adoptStat(rows){
  var s={ cnt:0, sum:0, min:null, max:null, noSub:0, bad:0 };
  (rows||[]).forEach(function(r){
    if(!dUtc(r.adoptDt)) return;
    if(!dUtc(r.submitDt)){ s.noSub++; return; }
    var d=adoptDays(r); if(d==null){ s.bad++; return; }
    s.cnt++; s.sum+=d; s.min=(s.min==null?d:Math.min(s.min,d)); s.max=(s.max==null?d:Math.max(s.max,d));
  });
  s.avg = s.cnt ? Math.round(s.sum/s.cnt*10)/10 : null;
  return s;
}
function daysTxt(d){ return d===0 ? '당일' : d+'일'; }
function adoptLine(s){
  if(!s) return '';
  if(!s.cnt) return s.noSub ? '<span style="color:#8a98a8" title="제출일 없이 바로 채택한 견적은 기간을 셀 수 없습니다 — 견적서 관리에서 제출일을 넣으면 셉니다">제출→채택 — (제출일 없음 '+s.noSub+'건)</span>' : '';
  return '<span title="채택일 − 제출일 · '+s.cnt+'건 기준'+(s.cnt>1?' · 가장 짧게 '+daysTxt(s.min)+' · 가장 길게 '+daysTxt(s.max):'')
    +(s.noSub?' · 제출일 없는 '+s.noSub+'건은 뺐습니다':'')+'">제출→채택 평균 <b>'+s.avg+'일</b>'
    +' <span style="color:#8a98a8">('+s.cnt+'건'+(s.noSub?' · 제출일 없음 '+s.noSub:'')+')</span></span>';
}
/* 목록 칸 — 채택된 줄만. 제출일이 없으면 「제출일 없음」(누르면 견적서 관리로 가서 넣는다 — 줄 클릭이 이미 그 화면이다) */
function adoptCell(r){
  if(!dUtc(r.adoptDt)) return '<span style="color:#b8c2cc">—</span>';
  if(!dUtc(r.submitDt)) return '<span style="color:#8a98a8;font-size:12px" title="제출일 없이 바로 채택 — 견적서 관리 ▸ 상태에서 제출일을 넣으면 셉니다">제출일 없음</span>';
  var d=adoptDays(r);
  if(d==null) return '<span style="color:var(--red)" title="채택일이 제출일보다 앞입니다 — 일자를 확인하세요">확인</span>';
  return '<b>'+daysTxt(d)+'</b>';
}
function adoptLoad(){
  var my=++_adoptSeq, q=qtMap();
  if(!n((q.A||{}).cnt)){ _adopt=null; render(); return; }
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  post('/mangr/pipelineList.do','stage=A&frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(j){ if(my!==_adoptSeq) return; _adopt=adoptStat((j&&j.data)||[]); render(); })
    .catch(function(){ if(my===_adoptSeq){ _adopt=null; render(); } });
}
function stepHtml(s, val, unit, sub, extraCls){
  var cls='step '+(val>0 ? s.kind : 'zero')+(_stage===s.key?' on':'')+(extraCls||'');
  return '<div class="'+cls+'" onclick="list(\''+s.key+'\')" title="'+esc(s.tip)+'">'
    +'<div class="no">'+s.no+'</div><div class="nm">'+esc(s.nm)+'</div>'
    +'<div class="v">'+fmt(val)+'<small>'+unit+'</small></div><div class="x">'+(sub||'')+'</div></div>';
}
function render(){
  var po=(_stat&&_stat.po)||null;
  /* 발주 */
  var h='';
  if(po){
    h+=stepHtml(PO_STEPS[0], n(po.reqCnt), '건', n(po.reqQty)>0 ? '발주할 수량 '+fmt(po.reqQty) : '');
    h+='<div class="arrow">▸</div>';
    h+=stepHtml(PO_STEPS[1], n(po.poCnt), '장', n(po.poRemainQty)>0 ? '미입고 '+fmt(po.poRemainQty) : '');
    h+='<div class="arrow">▸</div>';
    h+=stepHtml(PO_STEPS[2], n(po.purchCnt), '장', '발주서 전체 '+fmt(po.poAllCnt)+'장');
  }
  document.getElementById('poSteps').innerHTML=h;
  document.getElementById('poErr').textContent = (_stat&&_stat.poErr)
    ? '발주 집계를 못 읽었습니다 — 발주목록 표(TBL_PO_REQ)가 아직 없을 수 있습니다(docs/sql/20261002_po_req.sql).' : '';
  /* 견적 — ③ 채택의 아래 줄에 「판매 전 n건」 = 채택됐는데 아직 판매로 안 이어진 것 */
  var q=qtMap(), cnt=function(k){ return n((q[k]||{}).cnt); }, amt=function(k){ return n((q[k]||{}).amt); };
  var saleCnt=0, saleAmt=0; Object.keys(q).forEach(function(k){ saleCnt+=n(q[k].saleCnt); saleAmt+=n(q[k].saleAmt); });
  var aSold=n((q.A||{}).saleCnt), aWait=Math.max(0, cnt('A')-aSold);
  var g='';
  g+=stepHtml(QT_STEPS[0], cnt('W'), '건', amt('W') ? '공급가 '+fmt(amt('W')) : '');
  g+='<div class="arrow">▸</div>';
  g+=stepHtml(QT_STEPS[1], cnt('S'), '건', amt('S') ? '공급가 '+fmt(amt('S')) : '');
  g+='<div class="arrow">▸</div>';
  var aLine=adoptLine(_adopt);
  g+=stepHtml(QT_STEPS[2], cnt('A'), '건', cnt('A') ? (aWait ? '<span style="color:var(--amb);font-weight:700">판매 전 '+aWait+'건</span>' : '전부 판매로 이어짐')+(aLine?'<br>'+aLine:'') : '');
  g+='<div class="arrow">▸</div>';
  g+=stepHtml(QT_STEPS[3], saleCnt, '건', saleAmt ? '판매 '+fmt(saleAmt)+'원' : '');
  document.getElementById('qtSteps').innerHTML=g;
  document.getElementById('qtSide').innerHTML = QT_SIDE.map(function(s){
    return '<span class="chip'+(_stage===s.key?' on':'')+'" onclick="list(\''+s.key+'\')">'+s.nm+'<b>'+fmt(cnt(s.key))+'</b></span>'; }).join('');
  document.getElementById('qtErr').textContent = (_stat&&_stat.quoteErr)
    ? '견적 집계를 못 읽었습니다 — 판매 연결 칸이 아직 없을 수 있습니다(docs/sql/20261006_quote_sale_link.sql 을 먼저 실행).' : '';
}

/* ── 단계 목록 ── */
var PO_KEYS={ REQ:1, PO:1, PURCH:1 };
function stageName(k){ var all=PO_STEPS.concat(QT_STEPS).concat(QT_SIDE); for(var i=0;i<all.length;i++) if(all[i].key===k) return all[i].nm; return k; }
function list(k){
  _stage=k; render();
  var isPo=!!PO_KEYS[k];
  document.getElementById('lTitle').innerHTML=(isPo?'📋 발주 ▸ ':'📄 견적 ▸ ')+esc(stageName(k));
  document.getElementById('lCnt').textContent='조회 중…';
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  post('/mangr/pipelineList.do','stage='+encodeURIComponent(k)+'&frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(j){ var rows=(j&&j.data)||[]; if(_stage!==k) return;   // 그사이 다른 단계를 눌렀으면 옛 응답은 버린다
      if(isPo) drawPo(k, rows); else drawQt(k, rows); })
    .catch(function(e){ document.getElementById('lBody').innerHTML='<tr><td class="empty" style="color:var(--red)">조회 오류 — '+esc(e.message)+'</td></tr>'; document.getElementById('lCnt').textContent='—'; });
}
function emptyMsg(k){
  return { REQ:'미등록 발주목록이 없습니다.<br><span style="font-size:12px">대시보드(납기현황표) [📋 발주목록 실행]이 적정재고 미달 품목을 여기에 쌓습니다.</span>',
           PO:'다 안 들어온 발주서가 없습니다.',
           PURCH:'아직 매입전환된 발주서가 없습니다.<br><span style="font-size:12px">발주서 관리에서 발주서를 고르고 [📦 매입전환]을 누르면 여기에 쌓입니다.</span>',
           SALE:'견적에서 이어진 판매가 없습니다.<br><span style="font-size:12px">판매 등록 ▸ [📄 견적서]로 채택된 견적을 가져와 저장하면 여기에 셉니다.</span>' }[k]
      || '이 단계의 견적이 없습니다.';
}
function drawPo(k, rows){
  var unitNm={ REQ:'발주할 수량', PO:'미입고(잔량)', PURCH:'매입수량' }[k], q2Nm={ REQ:'부족', PO:'발주수량', PURCH:'발주수량' }[k];
  document.getElementById('lHead').innerHTML='<tr><th style="width:96px">일자</th><th style="width:110px">상품코드</th><th>상품명</th><th style="width:130px">규격</th>'
    +'<th style="width:150px">거래처</th><th style="width:96px">'+unitNm+'</th><th style="width:86px">'+q2Nm+'</th><th style="width:90px">발주번호</th><th style="width:120px">비고</th></tr>';
  document.getElementById('lCnt').innerHTML='<b>'+rows.length+'</b>줄'+(rows.length>=500?' (500줄까지)':'');
  if(!rows.length){ document.getElementById('lBody').innerHTML='<tr><td colspan="9" class="empty">'+emptyMsg(k)+'</td></tr>'; return; }
  var go={ REQ:'poReg', PO:'poReg', PURCH:'purchase' }[k];
  document.getElementById('lBody').innerHTML=rows.map(function(r){
    return '<tr class="go" onclick="openMenu(\''+go+'\')" title="눌러서 '+(go==='poReg'?'발주서 관리':'매입 등록')+' 화면으로 갑니다">'
      +'<td>'+d10(r.dt)+'</td><td>'+esc(r.prodCd)+'</td><td class="l">'+esc(r.prodNm)+'</td><td class="l">'+esc(r.spec)+'</td>'
      +'<td class="l">'+(r.partyNm?esc(r.partyNm):'<span style="color:#8a98a8">미정</span>')+'</td>'
      +'<td class="r"><b>'+fmt(r.qty)+'</b></td><td class="r">'+fmt(r.qty2)+'</td><td>'+esc(r.docNo)+'</td><td class="l">'+esc(r.note)+'</td></tr>';
  }).join('');
}
var ST_NM={ W:'작성 중', S:'제출완료', A:'채택', R:'거절', H:'보류' };
function drawQt(k, rows){
  document.getElementById('lHead').innerHTML='<tr><th style="width:96px">견적일</th><th style="width:140px">문서번호</th><th>수신</th><th style="width:110px">담당</th>'
    +'<th style="width:110px">공급가</th><th style="width:120px">상태</th><th style="width:96px">제출</th><th style="width:96px">채택</th>'
    +'<th style="width:96px" title="채택일 − 제출일 (같은 날이면 당일)">제출→채택</th><th style="width:150px">판매</th></tr>';
  var as=adoptStat(rows), aTxt=adoptLine(as);
  document.getElementById('lCnt').innerHTML='<b>'+rows.length+'</b>건'+(rows.length>=500?' (500건까지)':'')+(aTxt?' · '+aTxt:'');
  if(!rows.length){ document.getElementById('lBody').innerHTML='<tr><td colspan="10" class="empty">'+emptyMsg(k)+'</td></tr>'; return; }
  document.getElementById('lBody').innerHTML=rows.map(function(r){
    var g=r.statGb||'W', sold=n(r.saleCnt);
    var sale = sold ? '<span class="tag SALE" title="마지막 판매 '+d10(r.saleLastDt)+'">💰 '+sold+'건 · '+fmt(r.saleAmt)+'</span>'
                    : (g==='A' ? '<span style="color:var(--amb);font-weight:700">판매 전</span>' : '<span style="color:#b8c2cc">—</span>');
    var memo=r.statMemo ? ' title="'+esc(r.statMemo)+'"' : '';
    return '<tr class="go" onclick="openMenu(\''+(k==='A'&&!sold?'salesreg':'quoteMng')+'\')" title="'+(k==='A'&&!sold?'눌러서 판매 등록 화면으로 갑니다 — [📄 견적서]에서 이 견적을 가져오세요':'눌러서 견적서 관리 화면으로 갑니다')+'">'
      +'<td>'+d10(r.quoteDt)+'</td><td><b>'+esc(r.docNo)+'</b></td><td class="l">'+esc(r.recvNm)+'</td><td>'+esc(r.mgrNm)+'</td>'
      +'<td class="r">'+fmt(r.amt)+'</td><td><span class="tag '+g+'"'+memo+'>'+ST_NM[g]+'</span></td>'
      +'<td>'+d10(r.submitDt)+'</td><td>'+d10(r.adoptDt)+'</td><td>'+adoptCell(r)+'</td><td>'+sale+'</td></tr>';
  }).join('');
}
/* 그 일을 하는 화면으로 — 셸(부모)의 메뉴를 그대로 누른다(메뉴 강조·iframe 로드·다시 보일 때 알림이 메뉴와 똑같이 돈다) */
function openMenu(key){
  try{
    var a=window.parent && window.parent.document.querySelector('a.mi[data-key="'+key+'"]');
    if(a){ a.click(); return; }
  }catch(e){}
  _alertBox('그 화면을 메뉴에서 찾지 못했습니다. 왼쪽 메뉴에서 직접 열어 주세요.',{icon:'ℹ️'});
}
/* 셸이 이 화면을 다시 보여 줄 때(메뉴를 다시 눌렀을 때) 숫자를 새로 센다 — 다른 화면에서 발주·판매를 했을 수 있다 */
window.konetShown=function(){ load(); };
setRange(3);
</script>
</body>
</html>
