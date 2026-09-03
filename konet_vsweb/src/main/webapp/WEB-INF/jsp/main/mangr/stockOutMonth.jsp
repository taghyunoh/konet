<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>출고재고현황</title>
<!--
  출고재고현황 (2026-09-03 신설) — 재고 관리 > 재고현황 밑 메뉴. 사이드바 iframe(logiFrame) 화면.
  · 행 = 년월(최근월부터 내림차순) · 열 = 품목 · 값 = 그 달 출고량 · 맨 위 줄 = 현재고
  · 원천 = 수불원장 O행(발주현황표 파생 + 정산서 — 이중 차감 걸러진 값). 발주현황표 원본을 바로 세지 않는다.
  · 열 차례 = 기간 출고량 많은 품목이 왼쪽. 출고장은 넣지 않는다(요청).
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
  .bar input[type=month], .bar input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .cnt{ margin-left:10px; color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; white-space:nowrap; }
  .cnt b{ color:var(--teal); font-weight:800; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  /* 가로표(납기현황표)와 같은 감각 — 첫 두 칸·머리줄 고정, 값 없는 칸 회색 */
  table.mx{ border-collapse:separate; border-spacing:0; font-size:14px; }
  table.mx th, table.mx td{ border:1px solid var(--bd); padding:6px 9px; white-space:nowrap; text-align:center; background:#fff; }
  table.mx .cn{ position:sticky; left:0; z-index:2; text-align:left; font-weight:700; width:150px; min-width:150px; max-width:150px; box-sizing:border-box; background:#fff; }
  table.mx .rt{ position:sticky; left:150px; z-index:2; width:90px; min-width:90px; max-width:90px; box-sizing:border-box; background:#fff2cc; font-weight:800; }
  table.mx thead th{ position:sticky; top:0; z-index:3; background:#dfeaf5; color:#1f2a37; font-size:14px; }
  table.mx thead th.cn, table.mx thead th.rt{ z-index:4; }
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
</style>
</head>
<body>
<div class="wrap">
  <h2>📦 출고재고현황</h2>
  <div class="sub">품목별 <b>월 출고량</b>과 <b>현재고</b>를 한 표로 봅니다 — 행은 년월(최근월부터), 맨 위 줄이 현재고입니다. 출고량은 수불원장(발주현황표 + 정산서) 기준입니다.</div>
  <div class="bar">
    <label style="font-weight:700">기간</label>
    <input type="month" id="frYm"> <span style="color:#8a98a8">~</span> <input type="month" id="toYm">
    <button class="btn btn-teal" onclick="somLoad()">🔍 조회</button>
    <input type="text" id="q" placeholder="품목코드/품목명 거르기" oninput="somRender()" style="width:200px">
    <button class="btn" onclick="somExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">-</span>
  </div>
  <div class="card" id="card"><div class="empty">기간을 고르고 [조회]를 누르세요.</div></div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var RAW=null;   // {months:[{ym,prodSeq,prodCd,prodNm,outQty}], stock:[{prodCd,curQty}]}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function num(v){ return (Number(v)||0).toLocaleString(); }
function ymLabel(ym){ ym=''+ym; return ym.length===6 ? (ym.slice(0,4)+'-'+ym.slice(4,6)) : ym; }
function toast(s){ if(window._toast) return _toast(s.replace(/<[^>]*>/g,''),'info'); alert(s.replace(/<[^>]*>/g,'')); }
/* 기본 기간 = 최근 12개월 */
(function(){
  var d=new Date(), to=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2);
  d.setMonth(d.getMonth()-11);
  var fr=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2);
  document.getElementById('frYm').value=fr; document.getElementById('toYm').value=to;
})();
function somLoad(){
  var fr=document.getElementById('frYm').value, to=document.getElementById('toYm').value;
  if(!fr||!to){ toast('기간을 고르세요.'); return; }
  if(fr>to){ var t=fr; fr=to; to=t; document.getElementById('frYm').value=fr; document.getElementById('toYm').value=to; }
  document.getElementById('card').innerHTML='<div class="empty">불러오는 중…</div>';
  fetch(CTX+'/prod/stockOutMonthList.do', { method:'POST', credentials:'same-origin',
         headers:{'Content-Type':'application/x-www-form-urlencoded'},
         body:'frYm='+encodeURIComponent(fr.replace('-',''))+'&toYm='+encodeURIComponent(to.replace('-','')) })
    .then(function(r){ return r.json(); })
    .then(function(j){ RAW=j||{months:[],stock:[]}; somRender(); })
    .catch(function(e){ document.getElementById('card').innerHTML='<div class="empty">조회 실패: '+esc(e.message)+'</div>'; });
}
/* 자료를 년월 × 품목 격자로 편다 */
function somBuild(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  var stock={}; (RAW.stock||[]).forEach(function(s){ stock[''+s.prodCd]=Number(s.curQty)||0; });
  var prods={}, pord=[], yms={}, yord=[], cell={};
  (RAW.months||[]).forEach(function(r){
    var cd=''+(r.prodCd||''), ym=''+(r.ym||''), q0=Number(r.outQty)||0;
    if(!cd||!ym) return;
    if(q && (cd+' '+(r.prodNm||'')).toLowerCase().indexOf(q)<0) return;
    if(!prods[cd]){ prods[cd]={cd:cd, nm:(r.prodNm||''), tot:0}; pord.push(cd); }
    prods[cd].tot+=q0;
    if(!yms[ym]){ yms[ym]=0; yord.push(ym); }
    yms[ym]+=q0;
    cell[ym+'|'+cd]=(cell[ym+'|'+cd]||0)+q0;
  });
  pord.sort(function(a,b){ return prods[b].tot-prods[a].tot || a.localeCompare(b); });   // 많이 나간 품목이 왼쪽
  yord.sort(function(a,b){ return b.localeCompare(a); });                               // 최근월부터
  return { stock:stock, prods:prods, pord:pord, yms:yms, yord:yord, cell:cell };
}
function somRender(){
  if(!RAW) return;
  var m=somBuild(), card=document.getElementById('card');
  if(!m.pord.length){ card.innerHTML='<div class="empty">해당 기간에 출고가 없습니다.</div>'; document.getElementById('cnt').textContent='-'; return; }
  var h='<table class="mx"><thead><tr><th class="cn">년월 / 품목</th><th class="rt">합계</th>';
  m.pord.forEach(function(cd){ var p=m.prods[cd];
    h+='<th class="it" title="'+esc(cd+' '+p.nm)+'"><span class="cd">'+esc(cd)+'</span><span class="nm">'+esc(p.nm)+'</span></th>'; });
  h+='</tr></thead><tbody>';
  /* ① 맨 위 현재고 — 원장 누계. 값이 없으면 빈칸(0 은 "재고 없음"으로 읽힌다) */
  var stkTot=0, stkAny=false, stkCells='';
  m.pord.forEach(function(cd){ var v=m.stock[cd];
    if(v==null){ stkCells+='<td class="none"></td>'; return; }
    stkAny=true; stkTot+=v; stkCells+='<td class="'+(v<0?'neg':'')+'">'+num(v)+'</td>'; });
  h+='<tr class="stk"><td class="cn">현재고</td><td class="rt">'+(stkAny?num(stkTot):'')+'</td>'+stkCells+'</tr>';
  /* ② 년월 줄 — 최근월부터 */
  var grand=0;
  m.yord.forEach(function(ym){
    h+='<tr><td class="cn">'+ymLabel(ym)+'</td><td class="rt">'+num(m.yms[ym])+'</td>'; grand+=m.yms[ym];
    m.pord.forEach(function(cd){ var v=m.cell[ym+'|'+cd]; h+= (v>0) ? ('<td class="n">'+num(v)+'</td>') : '<td class="none"></td>'; });
    h+='</tr>';
  });
  /* ③ 기간 합계 */
  h+='<tr class="sum"><td class="cn">기간 합계</td><td class="rt">'+num(grand)+'</td>';
  m.pord.forEach(function(cd){ h+='<td>'+num(m.prods[cd].tot)+'</td>'; });
  card.innerHTML=h+'</tr></tbody></table>';
  document.getElementById('cnt').innerHTML='품목 <b>'+num(m.pord.length)+'</b>종 · <b>'+num(m.yord.length)+'</b>개월 · 기간 출고 <b>'+num(grand)+'</b>';
  somFit();
}
function somFit(){ var c=document.getElementById('card'); if(!c) return;
  var top=c.getBoundingClientRect().top+(window.pageYOffset||0);
  c.style.maxHeight=Math.max(220, window.innerHeight-top-16)+'px'; }
window.addEventListener('resize', somFit);
/* 엑셀 — 화면 표 그대로(현재고 줄 포함). 부모의 xlsx 라이브러리를 빌려 쓴다(택배납기관리와 같은 방식) */
function somExcel(){
  if(!RAW){ toast('먼저 조회하세요.'); return; }
  var m=somBuild(); if(!m.pord.length){ toast('출력할 자료가 없습니다.'); return; }
  var aoa=[], head=['년월 / 품목','합계']; m.pord.forEach(function(cd){ head.push(cd+' '+m.prods[cd].nm); }); aoa.push(head);
  var sr=['현재고',''], st=0, any=false;
  m.pord.forEach(function(cd){ var v=m.stock[cd]; if(v==null){ sr.push(''); return; } any=true; st+=v; sr.push(v); }); sr[1]=any?st:''; aoa.push(sr);
  m.yord.forEach(function(ym){ var r=[ymLabel(ym), m.yms[ym]]; m.pord.forEach(function(cd){ var v=m.cell[ym+'|'+cd]; r.push(v>0?v:''); }); aoa.push(r); });
  var tr=['기간 합계',0], g=0; m.pord.forEach(function(cd){ tr.push(m.prods[cd].tot); g+=m.prods[cd].tot; }); tr[1]=g; aoa.push(tr);
  var P=window.parent, fn='출고재고현황_'+document.getElementById('frYm').value.replace('-','')+'-'+document.getElementById('toYm').value.replace('-','')+'.xlsx';
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); ws['!cols']=[{wch:14},{wch:10}].concat(m.pord.map(function(){ return {wch:16}; }));
    ws['!freeze']={xSplit:2, ySplit:1, topLeftCell:'C2', activePane:'bottomRight', state:'frozen'};
    var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'출고재고현황'); LIB.writeFile(wb,fn); toast('📥 '+fn); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB) byLib(LIB); else toast('엑셀 모듈을 못 불러왔습니다.'); }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  toast('엑셀 모듈은 물류관리 메인 안에서만 씁니다.');
}
somLoad();
</script>
</body>
</html>
