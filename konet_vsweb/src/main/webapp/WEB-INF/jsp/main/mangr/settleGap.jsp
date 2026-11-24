<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>정산서 누락 조회</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀(색·병합) --%>
<!--
  정산서 누락 조회 (2026-11-24 신설 — 사용자 「발주현황표 대비 정산서 누락 조회화면 구성해줘」) — 매출 관리 ▸ 정산서 누락 조회. 셸 iframe(logiFrame).
  자료 /mangr/settleGapList.do → selectSettleGap — 발주현황표와 정산서를 납기일자·물류센터·품목으로 맞춰 «짝이 안 맞는 줄»만.
    · 정산서만 있음(S) — 월별 출고현황의 「(정산서·발주없음)」 이 되는 줄. 원인 = 발주현황표 미업로드(DAY) · 상품코드 다름(CODE) · 발주현황표에 없는 발주(ITEM)
    · 발주현황표만 있음(O) — 그날 정산서는 왔는데 이 발주 줄의 짝이 정산서에 없다. 원인 = 상품코드 다름 · 정산서에 없는 발주(ITEM)
    ★원인 이름 (2026-11-24 사용자 「발주현황표 없는 날과 품목 없음이 차이가 없는데」 → 「이름 바꾸는 걸로」) — 줄 하나로는 둘 다 「짝이 발주현황표에 없다」라 같아 보인다. 다른 것은 «고치는 길» :
      발주현황표 없는 날 → 「발주현황표 미업로드」(그날 그 센터를 우리가 안 올림 — 올리면 풀린다) · 품목 없음 → 「발주현황표에 없는 발주」(올렸는데 삼성 자료에 그 발주가 없다).
      ITEM 은 탭마다 뜻이 반대라 이름도 갈린다(발주현황표만 탭 = 「정산서에 없는 발주」) — rsNm(reason, 탭). 서버 코드값(DAY·ITEM)은 그대로.
    · 정산서 안 온 날(N) — 그날 그 센터 정산서가 아예 없다(아직 안 왔거나 안 올림)
  ★「상품코드 다름」 = 같은 삼성 품목코드인데 두 자료가 우리 상품코드를 다르게 저장한 것(매칭코드 등록 시점 차이) — 실측 올해 정산서만 있음 571줄 중 407줄.
  ★[2026-11-24 사용자 「주코드 매칭한 것은 제외된 것 맞나요」 → 「1·2번 같이」] 거래처 매칭코드(TBL_EXT_ITEM_MST)로 묶인 하위 코드는 같은 품목으로 보고 짝을 맞춘다(서버 조각 extMainMap) —
    그 407줄이 거의 전부 이것이라 「상품코드 다름」은 0 이 됐다. 이제 남는 것은 매칭코드에 묶이지 않은 다른 코드뿐. 월별 출고현황의 짝 찾기도 같은 기준이다.
  ★재고 수량은 이 표와 상관없이 맞다 — 정산서 수량으로 이미 빠져 있다. 이 화면은 «어느 점포 것인지 못 붙은 것»과 «정산서가 빠진 것»을 찾는 곳.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:12px 11px 12px; height:100vh; display:flex; flex-direction:column; }
  .wrap > *{ flex:0 0 auto; }
  h2{ margin:0 0 8px; font-size:20px; }
  .bar{ display:flex; gap:7px; align-items:center; flex-wrap:wrap; margin-bottom:8px; }
  .bar input[type=text], .bar input[type=date], .bar select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .bar .lab{ font-size:13px; color:#37475a; font-weight:700; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn.sm{ height:30px; padding:0 10px; font-size:12.5px; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .dim{ color:#8a97a4; }
  .cnt{ margin-left:auto; color:#37475a; font-size:13px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 12px; white-space:nowrap; }
  .sumbox{ display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); gap:8px; margin-bottom:8px; }
  .sumbox.n3{ grid-template-columns:repeat(3, minmax(0,1fr)); }   /* 상품코드 다름 칸이 없을 때(0건) */
  .kpi{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:8px 12px; cursor:pointer; }
  .kpi.on{ border-color:var(--teal); box-shadow:0 0 0 2px rgba(19,122,108,.15); }
  .kpi .k{ font-size:12.5px; color:#5b6b7a; font-weight:700; }
  .kpi .v{ font-size:19px; font-weight:800; margin-top:2px; font-variant-numeric:tabular-nums; }
  .kpi .s{ font-size:12px; color:#8a97a4; margin-top:2px; }
  .kpi.s1 .v{ color:#b03a2e; } .kpi.s2 .v{ color:#b0560f; } .kpi.s3 .v{ color:#1d6fb8; }
  .tabs{ display:flex; gap:4px; align-items:center; margin-bottom:6px; flex-wrap:wrap; }
  .tabs .t{ height:32px; padding:0 14px; border:1px solid var(--bd); background:#fff; border-radius:16px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .tabs .t.on{ background:var(--teal); border-color:var(--teal); color:#fff; }
  .help{ font-size:12.5px; color:#5b6b7a; margin:0 0 6px; line-height:1.6; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; flex:1 1 auto !important; min-height:150px; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g thead{ position:sticky; top:0; z-index:2; }
  table.g th{ background:#d9edf7; color:#1f2a37; font-weight:700; font-size:12.5px; border:1px solid #9fb6c3; padding:6px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border:1px solid #c9d3dc; padding:5px 7px; text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap; }
  table.g td.l{ text-align:left; white-space:normal; word-break:break-all; }
  table.g td.c{ text-align:center; }
  table.g tbody tr:hover{ background:#eef6f4; }
  table.g tr.tot td{ position:sticky; bottom:0; background:#fcf8e3; font-weight:800; z-index:1; box-shadow:inset 0 1px 0 #9fb6c3; }
  .rs{ display:inline-block; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:800; white-space:nowrap; }
  .rs.DAY{ background:#fdecea; color:#b03a2e; } .rs.CODE{ background:#fff1dc; color:#a3570a; } .rs.ITEM{ background:#eceff1; color:#4a5866; } .rs.NOSETTLE{ background:#e3eefb; color:#1b4f86; }
  .cd{ font-family:Consolas,monospace; font-size:12.5px; }
  .cd.diff{ color:#a3570a; font-weight:700; }
  .empty{ text-align:center; color:#8a97a4; padding:26px 10px; }
  @media (max-width:900px){ .sumbox, .sumbox.n3{ grid-template-columns:repeat(2, minmax(0,1fr)); } }
</style>
</head>
<body data-comp="<c:out value='${sessionScope.s_comp_nm}'/>">
<div class="wrap">
  <h2>정산서 누락 조회 <span class="dim" style="font-size:13px;font-weight:400">— 발주현황표와 정산서를 납기일자 · 물류센터 · 품목으로 맞춰 짝이 안 맞는 줄만 봅니다</span></h2>
  <div class="bar">
    <span class="lab">납기일자</span>
    <input type="date" id="frDt"> <span class="dim">~</span> <input type="date" id="toDt">
    <button class="btn sm" onclick="setRange('m0')">이번 달</button>
    <button class="btn sm" onclick="setRange('m1')">지난 달</button>
    <button class="btn sm" onclick="setRange('y0')">올해</button>
    <span class="lab" style="margin-left:6px">물류센터</span>
    <select id="dc" onchange="render()"><option value="">전체</option></select>
    <span class="lab">원인</span>
    <select id="rs" onchange="render()"><option value="">전체</option><option value="DAY">발주현황표 미업로드</option><option value="CODE">상품코드 다름</option><option value="ITEM">발주현황표에 없는 발주</option></select>
    <input type="text" id="q" placeholder="품목코드 · 품목명 · 발주번호 · 사업장" style="width:210px" oninput="render()">
    <button class="btn btn-teal" onclick="load()">리스트조회</button>
    <button class="btn" onclick="excel()">📥 엑셀 다운로드</button>
    <span class="cnt" id="cnt">—</span>
  </div>
  <div class="sumbox" id="sumbox"></div>
  <div class="tabs" id="tabs">
    <button class="t on" data-v="S" onclick="tabGo('S')">정산서만 있음</button>
    <button class="t" data-v="O" onclick="tabGo('O')">발주현황표만 있음 (정산서 누락)</button>
    <button class="t" data-v="N" onclick="tabGo('N')">정산서 안 온 날</button>
  </div>
  <div class="help" id="help"></div>
  <div class="card"><table class="g"><thead id="head"></thead><tbody id="body"><tr><td class="empty">불러오는 중…</td></tr></tbody></table></div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var ROWS=[], VIEW='S', _loadSeq=0, _shownAt=0;
var RS_NM={ DAY:'발주현황표 미업로드', CODE:'상품코드 다름', ITEM:'발주현황표에 없는 발주', NOSETTLE:'정산서 안 옴' };
/* ITEM 은 탭마다 뜻이 반대 — 정산서만 탭 = 발주현황표에 없는 발주 · 발주현황표만 탭 = 정산서에 없는 발주 (2026-11-24) */
function rsNm(reason, gb){ return (reason==='ITEM' && gb==='O') ? '정산서에 없는 발주' : (RS_NM[reason]||reason); }
var HELP={
  S:'정산서에는 있는데 같은 날 발주현황표에서 짝을 못 찾은 줄입니다 — 정산서엔 점포 이름이 없어 이 줄은 <b>어느 점포 것인지 모릅니다</b>(월별 출고현황의 「(정산서·발주없음)」). '
   +'<span class="rs DAY">발주현황표 미업로드</span> 그날 그 센터 발주현황표를 <b>안 올린</b> 것 — 올리면 그날 줄이 한 번에 풀립니다 · '
   +'<span class="rs CODE">상품코드 다름</span> 같은 삼성 품목코드인데 두 자료의 우리 상품코드가 다르고 매칭코드로도 묶여 있지 않습니다 — 거래처 매칭코드에 묶으면 짝이 맞습니다 · '
   +'<span class="rs ITEM">발주현황표에 없는 발주</span> 그날 발주현황표는 올렸는데 <b>삼성 자료에 이 발주가 없습니다</b>(마감 뒤 추가 발주·대체 출고 등) — 그 발주가 실린 발주현황표를 받아야 풀립니다. 재고 수량은 이미 맞게 빠져 있습니다. <span class="dim">※ 매칭코드로 묶인 하위 코드(예 1000455370 → 9904013345)는 같은 품목으로 보고 짝을 맞춥니다.</span>',
  O:'그날 그 센터 정산서는 왔는데, 이 발주 줄의 짝이 정산서에 없습니다 — <b>정산서가 빠진 줄</b>입니다. '
   +'<span class="rs CODE">상품코드 다름</span> 정산서엔 같은 삼성 품목이 다른 상품코드로 들어와 있습니다(옆 칸 코드) · '
   +'<span class="rs ITEM">정산서에 없는 발주</span> 정산서에 그 발주 품목이 없습니다 — 실제로 안 나갔거나(결품·취소) 정산서가 덜 왔을 수 있습니다.',
  N:'발주현황표는 있는데 <b>그날 그 센터 정산서가 아직 한 줄도 없는</b> 날입니다 — 정산서가 아직 안 왔거나 올리지 않았습니다. 정산서를 올리면 이 목록에서 빠집니다.'
};
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmtq(v){ return (Math.round(n(v)*100)/100).toLocaleString(); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function gv(id){ return (document.getElementById(id)||{}).value||''; }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function dcLbl(r){ return r.dcNm || r.dcCd || '(센터 없음)'; }

function setRange(k){
  var t=new Date(), f, e;
  if(k==='m1'){ f=new Date(t.getFullYear(), t.getMonth()-1, 1); e=new Date(t.getFullYear(), t.getMonth(), 0); }
  else if(k==='y0'){ f=new Date(t.getFullYear(), 0, 1); e=t; }
  else { f=new Date(t.getFullYear(), t.getMonth(), 1); e=t; }
  document.getElementById('frDt').value=ymd(f); document.getElementById('toDt').value=ymd(e);
  load();
}
function load(){
  var my=++_loadSeq;   /* 늦게 온 옛 응답이 새 목록을 덮지 않게 */
  document.getElementById('cnt').textContent='조회 중…';
  document.getElementById('body').innerHTML='<tr><td class="empty">발주현황표와 정산서를 맞춰 보는 중…</td></tr>';
  fetch(CTX+'/mangr/settleGapList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin',
      body:'frDt='+encodeURIComponent(gv('frDt'))+'&toDt='+encodeURIComponent(gv('toDt')) })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(my!==_loadSeq) return;
      if(!j || j.result!=='OK'){ ROWS=[]; render(); _alertBox((j&&j.login==='N')?'로그인이 끊겼습니다. 다시 로그인해 주세요.':'목록을 불러오지 못했습니다.',{icon:'⚠️'}); return; }
      if(j.frDt) document.getElementById('frDt').value=d10(j.frDt);
      if(j.toDt) document.getElementById('toDt').value=d10(j.toDt);
      ROWS=j.data||[]; dcFill(); render();
    })
    .catch(function(e){ if(my!==_loadSeq) return; ROWS=[]; render(); _alertBox('조회 오류 — '+esc(e.message),{icon:'⚠️'}); });
}
function dcFill(){
  var s=document.getElementById('dc'), cur=s.value, seen={}, l=[];
  ROWS.forEach(function(r){ var k=r.dcCd||''; if(seen[k]) return; seen[k]=1; l.push({cd:k, nm:dcLbl(r)}); });
  l.sort(function(a,b){ return String(a.cd).localeCompare(String(b.cd)); });
  s.innerHTML='<option value="">전체</option>'+l.map(function(o){ return '<option value="'+esc(o.cd)+'">'+esc(o.nm)+'</option>'; }).join('');
  if(cur && seen[cur]) s.value=cur;
}
/* 거르기 — 표·요약·엑셀이 모두 이 함수를 쓴다 */
function picked(gb){
  var dc=gv('dc'), rs=gv('rs'), q=gv('q').trim().toLowerCase();
  return ROWS.filter(function(r){
    if(gb && r.gb!==gb) return false;
    if(dc && (r.dcCd||'')!==dc) return false;
    if(rs && r.gb!=='N' && r.reason!==rs) return false;
    if(q && [r.itemCd,r.prodCd,r.otherProdCd,r.itemNm,r.ordNo,r.bizNm].join(' ').toLowerCase().indexOf(q)<0) return false;
    return true;
  });
}
function tabGo(v){ VIEW=v; Array.prototype.forEach.call(document.querySelectorAll('#tabs .t'), function(b){ b.classList.toggle('on', b.getAttribute('data-v')===v); }); render(); }
function sum(a,k){ return a.reduce(function(t,r){ return t+n(r[k]); },0); }
function render(){
  var oi=document.querySelector('#rs option[value="ITEM"]'); if(oi) oi.textContent=rsNm('ITEM', VIEW);   /* 탭마다 이름이 다르다(2026-11-24) */
  var S=picked('S'), O=picked('O'), N=picked('N');
  var cS=function(r){ return S.filter(function(x){ return x.reason===r; }).length; }, cO=function(r){ return O.filter(function(x){ return x.reason===r; }).length; };
  var kp=function(cls,v,k,val,s){ return '<div class="kpi '+cls+(VIEW===v?' on':'')+'" onclick="tabGo(\''+v+'\')"><div class="k">'+k+'</div><div class="v">'+val+'</div><div class="s">'+s+'</div></div>'; };
  document.getElementById('sumbox').innerHTML=
      kp('s1','S','정산서만 있음 (점포를 못 붙임)', S.length.toLocaleString()+'줄', '수량 '+fmtq(sum(S,'qty'))+' · 미업로드 '+cS('DAY')+' · 코드 다름 '+cS('CODE')+' · 발주현황표에 없는 발주 '+cS('ITEM'))
    + kp('s2','O','발주현황표만 있음 (정산서 누락)', O.length.toLocaleString()+'줄', '수량 '+fmtq(sum(O,'qty'))+' · 코드 다름 '+cO('CODE')+' · 정산서에 없는 발주 '+cO('ITEM'))
    + kp('s3','N','정산서 안 온 날', N.length.toLocaleString()+'곳', '발주 '+sum(N,'lineCnt').toLocaleString()+'줄 · 수량 '+fmtq(sum(N,'qty')))
    /* 「상품코드 다름」 칸은 있을 때만 (2026-11-24 사용자 「0건 표시는」) — 주코드 매칭을 같은 품목으로 본 뒤로 늘 0 이라 자리만 차지했다. 0 이면 세 칸이 줄을 채운다 */
    + ((cS('CODE')+cO('CODE')) ? kp('','S','상품코드 다름 (양쪽)', (cS('CODE')+cO('CODE')).toLocaleString()+'건', '같은 삼성 품목인데 매칭코드로 안 묶인 다른 상품코드 — 매칭코드에 묶으면 짝이 맞습니다') : '');
  document.getElementById('sumbox').classList.toggle('n3', !(cS('CODE')+cO('CODE')));
  document.getElementById('cnt').innerHTML=d10(gv('frDt'))+' ~ '+d10(gv('toDt'));
  document.getElementById('help').innerHTML=HELP[VIEW];
  document.getElementById('rs').disabled=(VIEW==='N');
  var head=document.getElementById('head'), body=document.getElementById('body');
  var list=VIEW==='S'?S:(VIEW==='O'?O:N), h='';
  if(VIEW==='N'){
    head.innerHTML='<tr><th style="width:110px">납기일자</th><th style="width:110px">물류센터</th><th style="width:100px">발주번호 수</th><th style="width:90px">발주 줄</th><th style="width:100px">수량</th><th>안내</th></tr>';
    if(!list.length){ body.innerHTML='<tr><td colspan="6" class="empty">정산서가 안 온 날이 없습니다.</td></tr>'; return; }
    list.forEach(function(r){ h+='<tr><td class="c">'+d10(r.dlvDt)+'</td><td class="c">'+esc(dcLbl(r))+'</td><td>'+n(r.bizCnt).toLocaleString()+'</td><td>'+n(r.lineCnt).toLocaleString()+'</td><td>'+fmtq(r.qty)+'</td>'
      +'<td class="l dim">그날 '+esc(dcLbl(r))+' 정산서가 아직 없습니다</td></tr>'; });
    h+='<tr class="tot"><td class="c" colspan="2">합계 '+list.length+'곳</td><td></td><td>'+sum(list,'lineCnt').toLocaleString()+'</td><td>'+fmtq(sum(list,'qty'))+'</td><td></td></tr>';
    body.innerHTML=h; return;
  }
  var mine=VIEW==='S'?'상품코드 (정산서)':'상품코드 (발주현황표)', other=VIEW==='S'?'발주현황표 상품코드':'정산서 상품코드';
  head.innerHTML='<tr><th style="width:120px">원인</th><th style="width:96px">납기일자</th><th style="width:76px">물류센터</th><th style="width:104px">발주번호</th><th style="width:104px">삼성 품목코드</th>'
    +'<th style="width:110px">'+mine+'</th><th style="width:120px">'+other+'</th><th style="min-width:220px">품목명</th>'+(VIEW==='O'?'<th style="min-width:160px">사업장</th>':'')+'<th style="width:80px">수량</th></tr>';
  var cols=VIEW==='O'?10:9;
  if(!list.length){ body.innerHTML='<tr><td colspan="'+cols+'" class="empty">짝이 안 맞는 줄이 없습니다.</td></tr>'; return; }
  list.forEach(function(r){
    var oth=r.reason==='CODE' ? '<span class="cd diff" title="같은 삼성 품목('+esc(r.itemCd)+')이 반대쪽에는 이 상품코드로 저장돼 있습니다">'+esc(r.otherProdCd)+'</span>' : (r.reason==='DAY'?'<span class="dim">발주현황표 없음</span>':'<span class="dim">—</span>');
    h+='<tr><td class="c"><span class="rs '+r.reason+'">'+rsNm(r.reason, r.gb)+'</span></td><td class="c">'+d10(r.dlvDt)+'</td><td class="c">'+esc(dcLbl(r))+'</td><td class="c cd">'+esc(r.ordNo||'')+'</td>'
      +'<td class="c cd">'+esc(r.itemCd||'')+'</td><td class="c cd'+(r.reason==='CODE'?' diff':'')+'">'+esc(r.prodCd||'')+'</td><td class="c">'+oth+'</td><td class="l">'+esc(r.itemNm||'')+'</td>'
      +(VIEW==='O'?'<td class="l">'+esc(r.bizNm||'')+(n(r.bizCnt)>1?' <span class="dim">외 '+(n(r.bizCnt)-1)+'곳</span>':'')+'</td>':'')
      +'<td>'+fmtq(r.qty)+'</td></tr>';
  });
  h+='<tr class="tot"><td class="c" colspan="'+(cols-1)+'">합계 '+list.length.toLocaleString()+'줄</td><td>'+fmtq(sum(list,'qty'))+'</td></tr>';
  body.innerHTML=h;
}
/* 엑셀 — 지금 탭·지금 거르기 그대로. 제목·조회기간·하늘색 머리·노란 합계(매입/판매 등록현황과 같은 꾸밈) */
function excel(){
  if(!ROWS.length){ if(window._toast) _toast('먼저 조회하세요.','warning'); return; }
  var X=window.XLSX; if(!X || !X.utils){ _alertBox('엑셀 도구를 불러오지 못했습니다. 새로고침 뒤 다시 눌러 주세요.',{icon:'⚠️'}); return; }
  var list=picked(VIEW), tnm={ S:'정산서만 있음', O:'발주현황표만 있음(정산서 누락)', N:'정산서 안 온 날' }[VIEW], hd, rows;
  if(VIEW==='N'){ hd=['납기일자','물류센터','발주번호 수','발주 줄','수량']; rows=list.map(function(r){ return [d10(r.dlvDt), dcLbl(r), n(r.bizCnt), n(r.lineCnt), n(r.qty)]; }); rows.push(['합계 '+list.length+'곳','','',sum(list,'lineCnt'),sum(list,'qty')]); }
  else { hd=['원인','납기일자','물류센터','발주번호','삼성 품목코드', VIEW==='S'?'상품코드(정산서)':'상품코드(발주현황표)', VIEW==='S'?'발주현황표 상품코드':'정산서 상품코드','품목명'].concat(VIEW==='O'?['사업장']:[]).concat(['수량']);
         rows=list.map(function(r){ return [rsNm(r.reason, r.gb), d10(r.dlvDt), dcLbl(r), r.ordNo||'', r.itemCd||'', r.prodCd||'', r.reason==='CODE'?(r.otherProdCd||''):'', r.itemNm||''].concat(VIEW==='O'?[(r.bizNm||'')+(n(r.bizCnt)>1?' 외 '+(n(r.bizCnt)-1)+'곳':'')]:[]).concat([n(r.qty)]); });
         var t=new Array(hd.length).fill(''); t[0]='합계 '+list.length+'줄'; t[hd.length-1]=sum(list,'qty'); rows.push(t); }
  var cond=[gv('dc')?('물류센터 '+document.getElementById('dc').options[document.getElementById('dc').selectedIndex].text):'', (gv('rs')&&VIEW!=='N')?('원인 '+rsNm(gv('rs'), VIEW)):'', gv('q').trim()?('찾기 「'+gv('q').trim()+'」'):''].filter(Boolean);
  var aoa=[['정산서 누락 조회 — '+tnm],[],['납기일자 : '+d10(gv('frDt'))+' ~ '+d10(gv('toDt'))+(cond.length?'   (조건 : '+cond.join(' · ')+')':'')+'   · 출력 '+ymd(new Date())+(document.body.getAttribute('data-comp')?'   · '+document.body.getAttribute('data-comp'):'')],hd].concat(rows);
  var ws=X.utils.aoa_to_sheet(aoa), nC=hd.length;
  ws['!merges']=[{s:{r:0,c:0},e:{r:0,c:nC-1}},{s:{r:2,c:0},e:{r:2,c:nC-1}}];
  ws['!cols']=hd.map(function(h){ return {wch: /품목명/.test(h)?44:(/사업장/.test(h)?30:(/원인/.test(h)?16:13))}; });
  var line={ style:'thin', color:{ rgb:'9AA5B1' } }, B={ top:line, bottom:line, left:line, right:line };
  var put=function(r,c,st){ var a=X.utils.encode_cell({r:r,c:c}); if(!ws[a]) ws[a]={t:'s',v:''}; ws[a].s=st; };
  put(0,0,{ font:{ bold:true, sz:16 }, alignment:{ horizontal:'center' } });
  for(var c=0;c<nC;c++) put(3,c,{ font:{ bold:true }, fill:{ patternType:'solid', fgColor:{ rgb:'DDEBF7' } }, border:B, alignment:{ horizontal:'center' } });
  for(var r=4;r<aoa.length;r++){ var tot=(r===aoa.length-1);
    for(c=0;c<nC;c++){ var v=aoa[r][c], st={ border:B, alignment:{ horizontal: typeof v==='number'?'right':(/품목명|사업장/.test(hd[c])?'left':'center'), wrapText:/품목명|사업장/.test(hd[c]) } };
      if(typeof v==='number') st.numFmt=(Math.round(v)!==v)?'#,##0.##':'#,##0';
      if(tot){ st.font={ bold:true }; st.fill={ patternType:'solid', fgColor:{ rgb:'FFE699' } }; }
      put(r,c,st); } }
  var wb=X.utils.book_new(); X.utils.book_append_sheet(wb, ws, tnm.replace(/[()]/g,'').slice(0,28));
  X.writeFile(wb, '정산서누락조회_'+{S:'정산서만',O:'발주현황표만',N:'정산서안온날'}[VIEW]+'_'+gv('frDt').replace(/-/g,'')+'-'+gv('toDt').replace(/-/g,'')+'.xlsx');
}
/* 다른 화면이 「이 날을 보라」고 넘기면(월별 출고현황 알림 줄 등) — 그 기간으로 연다 (window.parent.konetSettleGapRange = {fr,to,tab}) */
function takeRange(){
  var P=null; try{ P=window.parent; }catch(e){}
  var x=null; try{ x=P && P.konetSettleGapRange; if(x) P.konetSettleGapRange=null; }catch(e){}
  if(!x) return false;
  if(x.fr) document.getElementById('frDt').value=d10(x.fr);
  if(x.to) document.getElementById('toDt').value=d10(x.to);
  if(x.tab) tabGo(x.tab);
  load(); return true;
}
window.konetShown=function(){ if(takeRange()) return; if(Date.now()-_shownAt<3000) return; _shownAt=Date.now(); load(); };
document.getElementById('q').addEventListener('keydown', function(e){ if(e.key==='Escape'){ this.value=''; render(); } });
if(!takeRange()) setRange('m0');
</script>
</body>
</html>
