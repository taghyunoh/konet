<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>매입/판매 등록현황</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 원장 엑셀(색·병합·테두리) — 2026-11-24 --%>   <%-- 공통 알림창(_alertBox·_toast) — 브라우저 alert 금지 --%>
<!--
  매입/판매 등록현황 (2026-11-24 신설 — 사용자 「정보현황에 매입등록·판매등록을 통한 내용, 매입/판매등록현황 추가 (거래처별 일자별 판매·매입 내역)」)
  정보 현황 ▸ 매입/판매 등록현황. 셸 iframe(logiFrame). 자료 /mangr/trxStatList.do → selectTrxStat
  ★원천 = 매입등록·판매등록 <전표 머리> 한 줄씩 한 번만 읽고, 네 보기(거래처별 · 일자별 · 거래처×일자 · 전표별)는 화면이 접는다.
    ⇒ 보기를 바꿔도 합계가 늘 같다. 「보기마다 조회를 따로」 만들지 말 것(이익현황과 같은 원칙).
  ★금액 = 전표 머리의 공급가·부가세·합계 — 거래처별 채권·채무와 같은 칸. 합계는 반품을 뺀 순액이고, 반품액은 «얼마가 반품이었나»를 보여 주기만 한다.
  ★정산서(삼성 매출 엑셀)·발주현황표 출고는 넣지 않는다 — 이 화면은 «사람이 매입등록·판매등록으로 넣은 전표»를 보는 곳이다(회사 전체 매출은 마감현황·이익현황).
  ★거래처별·일자별·거래처×일자 = <위아래로 나눈다>(2026-11-24 사용자 「클릭하면 하단에 전표별 내용」·「상하단으로 구분되게」) — 위 줄을 누르면 탭은 그대로, 아래 칸에 그 전표(drawDtl).
    (「… 만 보는 중」 거르기와 [전표별 탭에서 보기]는 2026-11-24 걷어냈다 — 탭을 옮겨도 남아 일자별이 그날만 보였다.) 전표 줄을 누르면 그 전표를 매입등록/판매등록 화면에 연다(재고 서브코드 정리의 [매입등록에서 열기]와 같은 길).
  ★엑셀·인쇄 = 「출력」 선택에 따라 — 「이 탭」(기본) = 지금 보는 탭의 표 그대로(2026-11-24 사용자 「해당 탭에 맞게」) · 「상품별 원장」 = 상품 줄 원장(일계·소계·누계, 판매·매입 따로 — 견본 「[토더] 유형별 매출원장 전체조회」).
    둘 다 같은 틀(specSheet/printIt — 제목·조회기간·띠·하늘색 머리·줄 색)을 쓴다. 아래 「출력 틀 하나」 주석 참조.
  ⚠인쇄는 새 창 — 셸 안 iframe 이라 window.print() 를 부르면 셸이 찍힌다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --blue:#1d6fb8; --sale:#1d6fb8; --pur:#b0560f; }
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
  .btn-red{ background:#e05c4a; color:#fff; border-color:#e05c4a; }
  .dim{ color:#8a97a4; }
  .tabs{ display:flex; gap:4px; align-items:center; margin-bottom:8px; flex-wrap:wrap; }
  .tabs .t{ height:32px; padding:0 14px; border:1px solid var(--bd); background:#fff; border-radius:16px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .tabs .t.on{ background:var(--teal); border-color:var(--teal); color:#fff; }
  .sumbox{ display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); gap:8px; margin-bottom:8px; }
  .kpi{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:9px 12px; }
  .kpi .k{ font-size:12.5px; color:#5b6b7a; font-weight:700; }
  .kpi .v{ font-size:19px; font-weight:800; margin-top:2px; font-variant-numeric:tabular-nums; }
  .kpi .s{ font-size:12px; color:#8a97a4; margin-top:2px; }
  .kpi.sale .v{ color:var(--sale); } .kpi.pur .v{ color:var(--pur); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; flex:1 1 auto !important; min-height:150px; }
  /* ★위아래 나누기 (2026-11-24 사용자 「거래처별·일자별 상하단으로 구분되게」) — 위 = 요약 표(남는 높이) · 아래 = 고른 줄의 전표(높이는 막대로, 기억)
       전표별 탭에서는 아래 칸·막대를 숨긴다(.one) */
  .card.dtl{ flex:0 0 auto !important; height:var(--dtlH, 38vh); min-height:120px; }
  .wrap.one .card.dtl, .wrap.one .grip{ display:none; }
  .grip{ flex:0 0 auto; height:10px; margin:3px 0; cursor:row-resize; border-radius:5px; background:linear-gradient(#cfd8e0,#cfd8e0) center/60px 3px no-repeat; }
  .grip:hover{ background-color:#e6f2ef; }
  .dtlhd{ position:sticky; top:0; z-index:3; background:#fff; display:flex; align-items:center; gap:8px; padding:7px 10px; border-bottom:1px solid var(--bd); font-size:13px; font-weight:700; color:#37475a; }
  .dtlhd .btn{ height:28px; padding:0 10px; font-size:12px; }
  .card.dtl table.g thead{ top:41px; }   /* 제목 줄 밑에 머리글이 붙게 */
  table.g tbody tr.on td{ background:#fff3c4 !important; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  /* ★머리글은 thead 통째로 고정한다 (2026-11-24 사용자 캡처 「내용이 이렇게 보임」) — 종전엔 th 마다 sticky 를 걸고 둘째 줄 top 을 첫 줄 높이로 쟀는데,
       잰 칸이 두 줄을 합친(rowspan=2) 「거래처」 칸이라 둘째 줄이 한 줄만큼 아래에 붙어 첫 자료 줄을 덮었다. thead 를 붙이면 잴 것이 없다. */
  table.g thead{ position:sticky; top:0; z-index:2; }
  table.g th{ background:#d9edf7; color:#1f2a37; font-weight:700; font-size:12.5px; border:1px solid #9fb6c3; padding:6px 6px; text-align:center; white-space:nowrap; }
  table.g th.sale{ background:#e3eefb; color:#1b4f86; } table.g th.pur{ background:#fbeee2; color:#874309; }
  table.g td{ border:1px solid #c9d3dc; padding:5px 7px; text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap; }
  table.g td.l{ text-align:left; white-space:normal; word-break:break-all; }
  table.g td.c{ text-align:center; }
  table.g tbody tr:hover{ background:#eef6f4; }
  table.g tbody tr.go{ cursor:pointer; }
  table.g tr.grp td{ background:#f2f7f6; font-weight:800; }
  table.g tr.sub td:first-child{ padding-left:26px; }
  table.g tr.tot td{ position:sticky; bottom:0; background:#fcf8e3; font-weight:800; z-index:1; box-shadow:inset 0 1px 0 #9fb6c3; }
  .tag{ display:inline-block; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:800; }
  .tag.S{ background:#e3eefb; color:#1b4f86; } .tag.P{ background:#fbeee2; color:#874309; }
  .neg{ color:var(--red); }
  .tg{ display:inline-block; width:16px; color:#5b6b7a; font-weight:800; }
  .empty{ text-align:center; color:#8a97a4; padding:26px 10px; }
  .cnt{ margin-left:auto; color:#37475a; font-size:13px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 12px; white-space:nowrap; }
  .cnt b{ color:var(--teal); }
  @media (max-width:900px){ .sumbox{ grid-template-columns:repeat(2, minmax(0,1fr)); } }
</style>
</head>
<body data-comp="<c:out value='${sessionScope.s_comp_nm}'/>">   <%-- 원장 머리 오른쪽 회사 이름(견본의 (주)코네트) --%>
<div class="wrap one" id="wrap">
  <h2>매입/판매 등록현황 <span class="dim" style="font-size:13px;font-weight:400">— 매입등록·판매등록으로 넣은 전표</span></h2>
  <div class="bar">
    <span class="lab">일자</span>
    <input type="date" id="frDt"> <span class="dim">~</span> <input type="date" id="toDt">
    <button class="btn sm" onclick="setRange('m0')">이번 달</button>
    <button class="btn sm" onclick="setRange('m1')">지난 달</button>
    <button class="btn sm" onclick="setRange('y0')">올해</button>
    <span class="lab" style="margin-left:6px">구분</span>
    <select id="gb" onchange="render()"><option value="">판매·매입</option><option value="S">판매만</option><option value="P">매입만</option></select>
    <input type="text" id="q" placeholder="거래처 이름·코드 · 전표번호로 거르기" style="width:230px" oninput="render()">
    <button class="btn btn-teal" onclick="load()">리스트조회</button>
    <select id="outMode" title="엑셀·인쇄로 낼 것 — 「이 탭」 = 지금 보는 탭 표 그대로 · 「상품별 원장」 = 상품 줄 원장(일계·소계·누계, 판매·매입 따로)">   <%-- 2026-11-24 사용자 「엑셀출력이 한 양식으로만 나옴, 해당 탭에 맞게」 --%>
      <option value="tab">출력 : 이 탭</option><option value="ledger">출력 : 상품별 원장</option></select>
    <button class="btn" onclick="excel()">📥 엑셀 다운로드</button>
    <button class="btn btn-red" onclick="printIt()">🖨 인쇄</button>
    <span class="cnt" id="cnt">—</span>
  </div>
  <div class="tabs" id="tabs">
    <button class="t on" data-v="day" onclick="tabGo('day')">일자별</button>   <%-- 맨 앞 · 처음 보기 (2026-11-24 사용자 「일자별을 맨앞으로」 — 그 전엔 전표별이 맨 앞) --%>
    <button class="t" data-v="cust" onclick="tabGo('cust')">거래처별</button>
    <button class="t" data-v="cd" onclick="tabGo('cd')">거래처×일자</button>
    <button class="t" data-v="doc" onclick="tabGo('doc')">전표별</button>   <%-- 맨 뒤 (2026-11-24 사용자 「전표별을 맨뒤로」) --%>
    <button class="btn sm" id="foldAll" onclick="foldAll()" style="margin-left:auto" hidden>⊟ 전체 접기</button>
  </div>
  <div class="sumbox" id="sumbox"></div>
  <div class="card"><table class="g"><thead id="head"></thead><tbody id="body"><tr><td class="empty">불러오는 중…</td></tr></tbody></table></div>
  <%-- 아래 칸 — 위에서 고른 거래처·날짜의 전표 (2026-11-24 사용자 「클릭하면 하단에 전표별 내용」) --%>
  <div class="grip" id="dtlGrip" title="끌어서 위아래 크기 조절 · 두 번 누르면 처음 크기"></div>
  <div class="card dtl" id="dtlBox"><div class="dtlhd" id="dtlHd"></div><table class="g"><thead id="dHead"></thead><tbody id="dBody"></tbody></table></div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var ROWS=[], VIEW='day', SEL=null, FOLD={}, _loadSeq=0, _shownAt=0;

function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ var x=Math.round(n(v)); return (x<0?'<span class="neg">':'')+x.toLocaleString()+(x<0?'</span>':''); }
function fmtq(v){ return (Math.round(n(v)*100)/100).toLocaleString(); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function gv(id){ return (document.getElementById(id)||{}).value||''; }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function custKey(r){ return (r.custCd||'')+'|'+(r.custCd?'':(r.custNm||'')); }   /* 코드가 없는 전표는 이름으로 묶는다 */
function custLbl(r){ return (r.custNm||'(거래처 없음)')+(r.custCd?' <span class="dim">['+esc(r.custCd)+']</span>':''); }
function custTxt(r){ return (r.custNm||'(거래처 없음)')+(r.custCd?' ['+r.custCd+']':''); }

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
  var body='frDt='+encodeURIComponent(gv('frDt'))+'&toDt='+encodeURIComponent(gv('toDt'));
  fetch(CTX+'/mangr/trxStatList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:body })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(my!==_loadSeq) return;
      if(!j || j.result!=='OK'){ ROWS=[]; render(); if(window._alertBox) _alertBox((j&&j.login==='N')?'로그인이 끊겼습니다. 다시 로그인해 주세요.':'목록을 불러오지 못했습니다.',{icon:'⚠️'}); return; }
      if(j.frDt) document.getElementById('frDt').value=d10(j.frDt);   /* 서버가 기간을 고쳤으면(비었거나 3년 넘음) 그대로 맞춘다 */
      if(j.toDt) document.getElementById('toDt').value=d10(j.toDt);
      ROWS=j.data||[]; LINES=null; render();   /* 원장 줄(엑셀·인쇄)은 다음에 누를 때 새로 받는다 */
    })
    .catch(function(e){ if(my!==_loadSeq) return; ROWS=[]; render(); if(window._alertBox) _alertBox('조회 오류 — '+esc(e.message),{icon:'⚠️'}); });
}

/* ── 거르기 · 접기 — 네 보기·요약·엑셀·인쇄가 모두 이 두 함수를 쓴다(어긋날 수 없게) ── */
function picked(){
  var gb=gv('gb'), q=gv('q').trim().toLowerCase();
  return ROWS.filter(function(r){
    if(gb && r.gb!==gb) return false;
    if(q && [r.custNm,r.custCd,r.docNo].join(' ').toLowerCase().indexOf(q)<0) return false;
    return true;
  });
}
function z(){ return { S:{c:0,q:0,sup:0,vat:0,tot:0,rtn:0}, P:{c:0,q:0,sup:0,vat:0,tot:0,rtn:0} }; }
function add(a, r){ var s=a[r.gb]; if(!s) return; s.c++; s.q+=n(r.qty); s.sup+=n(r.supplyAmt); s.vat+=n(r.vatAmt); s.tot+=n(r.totAmt); s.rtn+=n(r.rtnAmt); }
function roll(list, keyFn, lblFn){
  var m={}, ord=[];
  list.forEach(function(r){ var k=keyFn(r); if(!m[k]){ m[k]={ key:k, lbl:lblFn(r), r:r, a:z(), kids:null }; ord.push(k); } add(m[k].a, r); });
  return ord.map(function(k){ return m[k]; });
}
function cols(){ var gb=gv('gb'); return gb ? [gb] : ['S','P']; }
var SIDE_NM={ S:'판매', P:'매입' };

function tabGo(v){ VIEW=v; SEL=null;   /* 탭을 바꾸면 아래 칸 고른 것은 푼다(거래처를 고른 채 일자별로 가면 뜻이 달라진다) */
  Array.prototype.forEach.call(document.querySelectorAll('#tabs .t'), function(b){ b.classList.toggle('on', b.getAttribute('data-v')===v); }); render(); }
function selDtl(cust, dt){ SEL={ cust:cust, dt:dt }; render(); }   /* 위 표 줄 누르기 → 아래 칸에 그 전표 (탭은 그대로) */
function selClear(){ SEL=null; render(); }
function selOn(cust, dt){ return !!SEL && SEL.cust===cust && SEL.dt===dt; }
function render(){
  var list=picked(), sides=cols();
  document.getElementById('foldAll').hidden=(VIEW!=='cd');
  document.getElementById('wrap').classList.toggle('one', VIEW==='doc');
  /* 요약 — 판매·매입·차이·반품 */
  var a=z(); list.forEach(function(r){ add(a, r); });
  var kp=function(cls,k,v,s){ return '<div class="kpi '+cls+'"><div class="k">'+k+'</div><div class="v">'+v+'</div><div class="s">'+s+'</div></div>'; };
  document.getElementById('sumbox').innerHTML=
      kp('sale','판매 합계', fmt(a.S.tot), a.S.c+'건 · 공급가 '+fmt(a.S.sup)+' · 부가세 '+fmt(a.S.vat))
    + kp('pur','매입 합계', fmt(a.P.tot), a.P.c+'건 · 공급가 '+fmt(a.P.sup)+' · 부가세 '+fmt(a.P.vat))
    + kp('','판매 − 매입', fmt(a.S.tot-a.P.tot), '합계(부가세 포함) 기준 — 이익이 아니라 금액 차이입니다')
    + kp('','반품', fmt(a.S.rtn+a.P.rtn), '판매 반품 '+fmt(a.S.rtn)+' · 매입 반품 '+fmt(a.P.rtn)+' (합계에서 이미 뺀 금액)');
  document.getElementById('cnt').innerHTML='전표 <b>'+list.length.toLocaleString()+'</b>건 · '+d10(gv('frDt'))+' ~ '+d10(gv('toDt'));
  var head=document.getElementById('head'), body=document.getElementById('body');
  if(VIEW==='doc'){ drawDoc(list, head, body); return; }
  var keyNm={ cust:'거래처', day:'일자', cd:'거래처 / 일자' }[VIEW];
  head.innerHTML='<tr><th rowspan="2" style="min-width:220px">'+keyNm+'</th>'+sides.map(function(s){ return '<th colspan="5" class="'+(s==='S'?'sale':'pur')+'">'+SIDE_NM[s]+'</th>'; }).join('')
    +(sides.length>1?'<th rowspan="2" title="판매 합계 − 매입 합계 (부가세 포함)">판매 − 매입</th>':'')+'</tr>'
    +'<tr>'+sides.map(function(s){ var c=(s==='S'?'sale':'pur'); return '<th class="'+c+'">건수</th><th class="'+c+'">공급가</th><th class="'+c+'">부가세</th><th class="'+c+'">합계</th><th class="'+c+'" title="그 전표들의 반품 줄 금액 — 합계에서 이미 뺐다">반품</th>'; }).join('')+'</tr>';
  if(!list.length){ body.innerHTML='<tr><td colspan="'+(1+sides.length*5+(sides.length>1?1:0))+'" class="empty">이 기간에 '+(gv('gb')?SIDE_NM[gv('gb')]+' ':'')+'전표가 없습니다.</td></tr>'; drawDtl(list); return; }
  var cells=function(a){ return sides.map(function(s){ var x=a[s]; return '<td>'+(x.c?x.c.toLocaleString():'<span class="dim">-</span>')+'</td><td>'+fmt(x.sup)+'</td><td>'+fmt(x.vat)+'</td><td><b>'+fmt(x.tot)+'</b></td><td>'+(x.rtn?fmt(x.rtn):'<span class="dim">-</span>')+'</td>'; }).join('')
    +(sides.length>1?'<td><b>'+fmt(a.S.tot-a.P.tot)+'</b></td>':''); };
  var h='';
  if(VIEW==='cust'){
    roll(list, custKey, custLbl).sort(byTot).forEach(function(g){
      h+='<tr class="go'+(selOn(g.key,null)?' on':'')+'" onclick="selDtl(\''+esc(jsq(g.key))+'\', null)" title="눌러서 이 거래처의 전표를 아래에 봅니다"><td class="l">'+g.lbl+'</td>'+cells(g.a)+'</tr>'; });
  } else if(VIEW==='day'){
    roll(list, function(r){ return String(r.dt); }, function(r){ return d10(r.dt); }).sort(function(x,y){ return x.key<y.key?1:-1; }).forEach(function(g){
      h+='<tr class="go'+(selOn(null,g.key)?' on':'')+'" onclick="selDtl(null, \''+esc(jsq(g.key))+'\')" title="눌러서 이 날의 전표를 아래에 봅니다"><td class="c">'+g.lbl+' <span class="dim">'+'일월화수목금토'.charAt(new Date(+g.key.slice(0,4), +g.key.slice(4,6)-1, +g.key.slice(6,8)).getDay())+'</span></td>'+cells(g.a)+'</tr>'; });
  } else {
    roll(list, custKey, custLbl).sort(byTot).forEach(function(g){
      var kids=roll(list.filter(function(r){ return custKey(r)===g.key; }), function(r){ return String(r.dt); }, function(r){ return d10(r.dt); }).sort(function(x,y){ return x.key<y.key?1:-1; });
      var fold=!!FOLD[g.key];
      h+='<tr class="grp go" onclick="foldOne(\''+esc(jsq(g.key))+'\')" title="눌러서 접기·펼치기"><td class="l"><span class="tg">'+(fold?'▸':'▾')+'</span>'+g.lbl+' <span class="dim" style="font-weight:400">('+kids.length+'일)</span></td>'+cells(g.a)+'</tr>';
      if(!fold) kids.forEach(function(k){ h+='<tr class="sub go'+(selOn(g.key,k.key)?' on':'')+'" onclick="selDtl(\''+esc(jsq(g.key))+'\', \''+esc(jsq(k.key))+'\')" title="눌러서 이 거래처·이 날의 전표를 아래에 봅니다"><td class="l">'+k.lbl+'</td>'+cells(k.a)+'</tr>'; });
    });
  }
  h+='<tr class="tot"><td class="c">합계</td>'+cells(a)+'</tr>';
  body.innerHTML=h;
  drawDtl(list);
  if(VIEW==='cd') document.getElementById('foldAll').textContent=(Object.keys(FOLD).length?'⊞ 전체 펼치기':'⊟ 전체 접기');
}
function byTot(x,y){ return (n(y.a.S.tot)+n(y.a.P.tot))-(n(x.a.S.tot)+n(x.a.P.tot)); }   /* 금액 큰 거래처부터 */
function jsq(s){ return String(s).replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }
function foldOne(k){ if(FOLD[k]) delete FOLD[k]; else FOLD[k]=1; render(); }
function foldAll(){
  if(Object.keys(FOLD).length){ FOLD={}; }
  else { FOLD={}; picked().forEach(function(r){ FOLD[custKey(r)]=1; }); }
  render();
}

/* ── 전표별 — 줄을 누르면 매입등록/판매등록에 그 전표를 연다 ── */
/* 아래 칸 — 위에서 고른 거래처·날짜의 전표(구분·찾기 조건은 위와 같이 걸린다). 전표 줄을 누르면 매입등록/판매등록에 연다(drawDoc 그대로) */
function drawDtl(list){
  var hd=document.getElementById('dtlHd'), dh=document.getElementById('dHead'), db=document.getElementById('dBody');
  if(!SEL){ hd.innerHTML='<span class="dim">▲ 위에서 '+({ cust:'거래처', day:'날짜', cd:'날짜 줄' }[VIEW])+'를 누르면 그 전표가 여기에 보입니다</span>'; dh.innerHTML=''; db.innerHTML=''; return; }
  var L=list.filter(function(r){ return (!SEL.cust || custKey(r)===SEL.cust) && (!SEL.dt || String(r.dt)===SEL.dt); });
  var nm=''; if(SEL.cust){ var r0=ROWS.filter(function(r){ return custKey(r)===SEL.cust; })[0]; nm=r0?custLbl(r0):esc(SEL.cust); }
  hd.innerHTML='📄 '+[nm, SEL.dt?d10(SEL.dt):''].filter(Boolean).join(' · ')+' 전표 <b style="color:var(--teal)">'+L.length+'</b>건'
    +' <span class="dim" style="font-weight:400">— 줄을 누르면 매입등록·판매등록에 그 전표가 열립니다</span>'
    +'<button class="btn" style="margin-left:auto" onclick="selClear()">✕ 닫기</button>';
  drawDoc(L, dh, db);
}
/* 가운데 막대 — 끌면 아래 칸 높이가 바뀌고 이 컴퓨터에 기억된다(localStorage konetTrxDtlH) · 두 번 누르면 처음 높이 */
(function(){
  var K='konetTrxDtlH', box=document.getElementById('dtlBox'), g=document.getElementById('dtlGrip');
  try{ var v=parseInt(localStorage.getItem(K),10); if(v>0) box.style.setProperty('--dtlH', v+'px'); }catch(e){}
  g.addEventListener('mousedown', function(e){
    e.preventDefault(); var y0=e.clientY, h0=box.offsetHeight, maxH=window.innerHeight-260;
    var mv=function(ev){ var h=Math.max(120, Math.min(maxH, h0+(y0-ev.clientY))); box.style.setProperty('--dtlH', h+'px'); };
    var up=function(){ document.removeEventListener('mousemove', mv); document.removeEventListener('mouseup', up); try{ localStorage.setItem(K, String(box.offsetHeight)); }catch(e){} };
    document.addEventListener('mousemove', mv); document.addEventListener('mouseup', up);
  });
  g.addEventListener('dblclick', function(){ box.style.removeProperty('--dtlH'); try{ localStorage.removeItem(K); }catch(e){} });
})();
function drawDoc(list, head, body){
  head.innerHTML='<tr><th style="width:62px">구분</th><th style="width:96px">일자</th><th style="width:120px">전표번호</th><th style="min-width:180px">거래처</th><th style="width:80px">담당</th>'
    +'<th style="width:54px">줄수</th><th style="width:80px">수량</th><th style="width:100px">공급가</th><th style="width:90px">부가세</th><th style="width:110px">합계</th>'
    +'<th style="width:90px" title="반품 줄 금액 — 합계에서 이미 뺐다">반품</th><th style="width:100px" title="전표에 적은 즉시 수금·지급">수금/지급</th><th style="min-width:120px">비고</th></tr>';
  if(!list.length){ body.innerHTML='<tr><td colspan="13" class="empty">조건에 맞는 전표가 없습니다.</td></tr>'; return; }
  var a=z(), h='';
  list.forEach(function(r){
    add(a, r);
    var tip=(r.gb==='S'?'판매 등록':'매입 등록')+' 화면에서 이 전표를 엽니다'+(r.gb==='S'&&r.dlvDt&&r.dlvDt!==r.dt?' · 납품일 '+d10(r.dlvDt):'');
    h+='<tr class="go" onclick="openDoc(\''+r.gb+'\','+n(r.seq)+')" title="'+esc(tip)+'">'
      +'<td class="c"><span class="tag '+r.gb+'">'+SIDE_NM[r.gb]+'</span></td><td class="c">'+d10(r.dt)+'</td><td class="c">'+esc(r.docNo)+'</td>'
      +'<td class="l">'+custLbl(r)+'</td><td class="c">'+esc(r.mgrNm)+'</td><td>'+n(r.lineCnt)+'</td><td>'+fmtq(r.qty)+'</td>'
      +'<td>'+fmt(r.supplyAmt)+'</td><td>'+fmt(r.vatAmt)+'</td><td><b>'+fmt(r.totAmt)+'</b></td><td>'+(n(r.rtnAmt)?fmt(r.rtnAmt):'<span class="dim">-</span>')+'</td>'
      +'<td>'+(n(r.payAmt)?fmt(r.payAmt)+(r.payGb?' <span class="dim">'+esc(r.payGb)+'</span>':''):'<span class="dim">-</span>')+'</td><td class="l">'+esc(r.remark)+'</td></tr>';
  });
  var q=a.S.q+a.P.q, sup=a.S.sup+a.P.sup, vat=a.S.vat+a.P.vat, tot=a.S.tot+a.P.tot, rtn=a.S.rtn+a.P.rtn;
  var mix=(a.S.c && a.P.c);   /* 판매·매입이 섞이면 더한 합계는 뜻이 없다 — 따로 적는다 */
  h+= mix ? '<tr class="tot"><td colspan="7" class="c">판매 '+a.S.c+'건 · 매입 '+a.P.c+'건</td><td colspan="6" class="l">판매 합계 '+fmt(a.S.tot)+' · 매입 합계 '+fmt(a.P.tot)+' · 판매 − 매입 '+fmt(a.S.tot-a.P.tot)+'</td></tr>'
          : '<tr class="tot"><td colspan="6" class="c">합계 '+list.length+'건</td><td>'+fmtq(q)+'</td><td>'+fmt(sup)+'</td><td>'+fmt(vat)+'</td><td>'+fmt(tot)+'</td><td>'+fmt(rtn)+'</td><td></td><td></td></tr>';
  body.innerHTML=h;
}
function openDoc(gb, seq){
  var P=window.parent;
  if(!P || P===window || typeof P.logiFrame!=='function'){ _alertBox('물류관리 화면 안에서 열어 주세요.',{icon:'⚠️'}); return; }
  var key=gb==='S'?'salesreg':'purchase', url=gb==='S'?'/mangr/salesReg.do':'/mangr/purchaseReg.do', ifr=gb==='S'?'if-salesreg':'if-purchase';
  var apply=gb==='S'?'saApply':'puApply', det=gb==='S'?'/mangr/salesTrxDetail.do':'/mangr/purchaseDetail.do', prm=(gb==='S'?'saleSeq=':'purchSeq=')+seq;
  P.logiFrame(key, CTX+url, P.document.querySelector('a.mi[data-key="'+key+'"]'));
  var t0=Date.now();
  (function wait(){   /* 그 화면이 상품·거래처 목록까지 받은 뒤에 전표를 얹는다(재고 서브코드 정리 openPurch 와 같은 기다림) */
    var f=P.document.getElementById(ifr), w=f&&f.contentWindow, ok=false;
    try{ ok=w && typeof w[apply]==='function' && typeof w.post==='function' && w.document.readyState==='complete' && w._prods && w._prods.length && w._vendors && w._vendors.length; }catch(e){ ok=false; }
    if(!ok && Date.now()-t0<12000){ setTimeout(wait, 200); return; }
    if(!(w && typeof w[apply]==='function')){ _alertBox((gb==='S'?'판매 등록':'매입 등록')+' 화면을 열지 못했습니다. 메뉴에서 연 뒤 다시 눌러 주세요.',{icon:'⚠️'}); return; }
    w.post(det, prm).then(function(r){ return r.json(); }).then(function(j){
      var d=j&&j.data; if(!d){ _alertBox('전표를 찾지 못했습니다(지워졌을 수 있습니다).',{icon:'⚠️'}); return; }
      w[apply](d);
    }).catch(function(){ _alertBox('전표를 불러오지 못했습니다.',{icon:'⚠️'}); });
  })();
}

/* ── 엑셀 · 인쇄 = 「원장」 (2026-11-24 사용자 「엑셀인쇄 이런 스타일로」 — [토더] 유형별 매출원장 전체조회 견본) ──
     상품 줄 단위 : 거래처 · 일자 · 번호(전표번호) · NO(줄) · 구분 · 상품명 · 수량 · 단가 · 금액(공급가) · 판매액/매입액(부가세 포함) · 계(누계).
     거래처마다 날짜별 「일계」(연두) · 거래처 「소계」(연보라) · 끝에 「합계」. 계 = 위에서부터 판매액(매입액) 누계 — 일계·소계 줄은 비운다(견본과 같다).
     ★판매와 매입은 <원장을 따로> — 한 원장에 섞으면 누계의 뜻이 없다. 엑셀은 시트 두 장, 인쇄는 쪽을 나눈다.
     ★조건(구분 · 거래처·날짜 거르기 · 찾기)은 화면과 같은 규칙(lineHit) — 화면에서 고른 만큼만 나간다.
     ★줄은 누를 때만 받는다(/mangr/trxStatLines.do) — 화면 목록은 전표 머리만 읽어 가볍게.
     ⚠원장 합계는 «줄» 합계다. 전표 머리 합계가 줄과 다른 옛 전표(2026-11-24 실측 : 매입 2026-08-27 0001 제이투팩(주) 1건 — 머리 부호 오류)는 화면 요약과 그만큼 다를 수 있다. */
var LINES=null, LINES_KEY='', SIDE_LG={ S:{ ttl:'매출원장', amt:'판매액', gbNm:'판매등록', row:'매출' }, P:{ ttl:'매입원장', amt:'매입액', gbNm:'매입등록', row:'매입' } };
function lineHit(r){
  var gb=gv('gb'), q=gv('q').trim().toLowerCase();
  if(gb && r.gb!==gb) return false;
  if(q && [r.custNm,r.custCd,r.docNo].join(' ').toLowerCase().indexOf(q)<0) return false;
  return true;
}
function linesGet(cb){
  var key=gv('frDt')+'|'+gv('toDt');
  if(LINES && LINES_KEY===key){ cb(LINES); return; }
  fetch(CTX+'/mangr/trxStatLines.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin',
      body:'frDt='+encodeURIComponent(gv('frDt'))+'&toDt='+encodeURIComponent(gv('toDt')) })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(!j || j.result!=='OK'){ _alertBox((j&&j.login==='N')?'로그인이 끊겼습니다. 다시 로그인해 주세요.':'원장 자료를 불러오지 못했습니다.',{icon:'⚠️'}); return; }
      LINES=j.data||[]; LINES_KEY=key; cb(LINES);
    })
    .catch(function(e){ _alertBox('원장 자료를 불러오지 못했습니다 — '+esc(e.message),{icon:'⚠️'}); });
}
function noOf(s){ var t=String(s==null?'':s).trim(); return /^\d+$/.test(t) ? Number(t) : t; }   /* '0006' → 6 (견본처럼) */
/* 한 쪽(판매 S / 매입 P)의 원장 줄 — { k:'line'|'day'|'sub'|'tot', c:[11칸] } */
function ledgerRows(list, gb){
  var L=list.filter(function(r){ return r.gb===gb; });
  if(!L.length) return [];
  var first={}, ord=[];   /* 거래처 차례 = 처음 나온 전표 차례(일자·번호) — 견본과 같다 */
  L.slice().sort(function(a,b){ return String(a.dt).localeCompare(String(b.dt)) || String(a.docNo).localeCompare(String(b.docNo)) || n(a.seq)-n(b.seq) || n(a.rowNo)-n(b.rowNo); })
   .forEach(function(r){ var k=custKey(r); if(!first[k]){ first[k]=[]; ord.push(k); } first[k].push(r); });
  var out=[], run=0, TS=0, TT=0, rowNm=SIDE_LG[gb].row;
  ord.forEach(function(k){
    var rs=first[k], cs=0, ct=0, dd=null, ds=0, dt=0, shown=false;
    var flushDay=function(){ if(dd===null) return; out.push({ k:'day', c:['','일계','','','','','','',ds,dt,''] }); ds=0; dt=0; };
    rs.forEach(function(r){
      if(dd!==null && String(r.dt)!==dd) flushDay();
      dd=String(r.dt);
      var sup=n(r.supplyAmt), tot=n(r.totAmt); run+=tot; ds+=sup; dt+=tot; cs+=sup; ct+=tot;
      out.push({ k:'line', c:[shown?'':custTxt(r), d10(r.dt), noOf(r.docNo), n(r.rowNo), (r.trxGb==='반품'?'반품':rowNm),
                              r.prodNm+(r.spec&&String(r.prodNm||'').indexOf(r.spec)<0?' '+r.spec:''), n(r.qty), n(r.unitPrice), sup, tot, run] });
      shown=true;
    });
    flushDay();
    out.push({ k:'sub', c:['소계','','','','','','','',cs,ct,''] }); TS+=cs; TT+=ct;
  });
  out.push({ k:'tot', c:['합계','','','','','','','',TS,TT,''] });
  return out;
}
/* ── 출력 틀 하나 (2026-11-24 사용자 「엑셀출력이 한 양식으로만 나옴, 해당 탭에 맞게」) ─────────────────
     모든 출력(탭 4개 + 상품별 원장)이 «같은 틀»을 쓴다 — 제목 · 조회기간 · 띠(기간·구분·등록 종류·출력일자·회사) · 하늘색 칸 머리(필요하면 두 줄) ·
     줄 종류별 색(일계 연두 · 소계 연보라 · 합계 노랑). 엑셀(xlsx-js-style)과 인쇄(새 창)가 «같은 spec» 을 그린다 — 두 출력이 어긋나지 않게.
     spec = { title, period, gbNm, sheet, file, cols:[칸 이름], head2:[{t,span,rows}] (두 줄 머리 — 없으면 한 줄), al:'lcr…'(칸마다 정렬), w:[폭],
              q:{칸번호:1}(수량 — 소수 있을 때만 소수), rows:[{k:'line'|'day'|'sub'|'tot', c:[…]}] } */
function OUTMODE(){ return gv('outMode')||'tab'; }
function headBase(){
  var comp=document.body.getAttribute('data-comp')||'', cond=[];
  if(gv('q').trim()) cond.push('찾기 「'+gv('q').trim()+'」');
  return { fr:d10(gv('frDt')), to:d10(gv('toDt')), comp:comp, period:'조회기간 : '+d10(gv('frDt'))+' ~ '+d10(gv('toDt'))+(cond.length?'   (조건 : '+cond.join(' · ')+')':'') };
}
function gbWord(){ var g=gv('gb'); return g==='S'?'판매':(g==='P'?'매입':'판매·매입'); }
function bandOf(sp, n){   /* 띠 줄 — 견본(11칸) = 기간 2 · 구분 2 · 등록 3 · 출력일자 3 · 회사 1. 칸 수가 달라도 같은 차례로 나눈다 */
  var b=headBase(), g=n>=10?2:1, r=n-2-g-1, x=Math.ceil(r/2), y=r-x;
  return [ {t:b.fr+' ~ '+b.to, s:2}, {t:'구분', s:g}, {t:sp.gbNm, s:x}, {t:'출력일자 : '+ymd(new Date()), s:y}, {t:b.comp, s:1} ].filter(function(o){ return o.s>0; });
}
var SIDE_COLS=['건수','공급가','부가세','합계','반품'];
function sideHead(keyNm, keyCols){   /* 거래처별·일자별·거래처×일자 — 판매·매입 두 묶음 머리 */
  var sides=cols(), h2=keyNm.map(function(k){ return {t:k, span:1, rows:2}; });
  sides.forEach(function(s){ h2.push({t:SIDE_NM[s], span:5}); }); if(sides.length>1) h2.push({t:'판매 − 매입', span:1, rows:2});
  var cs=keyNm.slice(); sides.forEach(function(){ cs=cs.concat(SIDE_COLS); }); if(sides.length>1) cs.push('판매 − 매입');
  return { h2:h2, cols:cs };
}
function sideVals(a){ var v=[], sides=cols(); sides.forEach(function(s){ var x=a[s]; v.push(x.c, Math.round(x.sup), Math.round(x.vat), Math.round(x.tot), Math.round(x.rtn)); }); if(sides.length>1) v.push(Math.round(a.S.tot-a.P.tot)); return v; }
function specTab(){
  var list=picked(), b=headBase(), sides=cols(), gw=gbWord();
  var base={ period:b.period, gbNm:(gv('gb')==='S'?'판매등록':(gv('gb')==='P'?'매입등록':'판매·매입등록')) };
  var stamp=gv('frDt').replace(/-/g,'')+'-'+gv('toDt').replace(/-/g,'');
  if(VIEW==='doc'){
    var a=z(), rows=list.map(function(r){ add(a, r);
      return { k:'line', c:[SIDE_NM[r.gb], d10(r.dt), r.docNo||'', custTxt(r), r.mgrNm||'', n(r.lineCnt), n(r.qty), n(r.supplyAmt), n(r.vatAmt), n(r.totAmt), n(r.rtnAmt), n(r.payAmt), r.payGb||'', r.remark||''] }; });
    var tr=function(lbl, x){ return ['','','',lbl+' '+x.c+'건','','',x.q,x.sup,x.vat,x.tot,x.rtn,'','','']; };
    if(a.S.c && a.P.c){ rows.push({ k:'sub', c:tr('판매 합계', a.S) }); rows.push({ k:'sub', c:tr('매입 합계', a.P) });
                        rows.push({ k:'tot', c:['','','','판매 − 매입','','','','','',a.S.tot-a.P.tot,'','','',''] }); }
    else { var x=a.S.c?a.S:a.P; rows.push({ k:'tot', c:tr('합계', x) }); }
    return Object.assign(base, { title:'['+gw+'] 전표별 등록현황', sheet:'전표별', file:'매입판매등록_전표별_'+stamp,
      cols:['구분','일자','전표번호','거래처','담당','줄수','수량','공급가','부가세','합계','반품','수금/지급','결제구분','비고'],
      al:'cccllrrrrrrrcl', w:[7,11,10,34,9,6,9,13,12,13,11,12,9,40], q:{6:1}, rows:rows });
  }
  var tot=z(); list.forEach(function(r){ add(tot, r); });
  if(VIEW==='cust' || VIEW==='day'){
    var hd=sideHead([VIEW==='cust'?'거래처':'일자']);
    var gs=VIEW==='cust' ? roll(list, custKey, custTxt).sort(byTot) : roll(list, function(r){ return String(r.dt); }, function(r){ return d10(r.dt); }).sort(function(x,y){ return x.key<y.key?1:-1; });
    var rows2=gs.map(function(g){ return { k:'line', c:[g.lbl].concat(sideVals(g.a)) }; }); rows2.push({ k:'tot', c:['합계'].concat(sideVals(tot)) });
    return Object.assign(base, { title:'['+gw+'] '+(VIEW==='cust'?'거래처별':'일자별')+' 등록현황', sheet:VIEW==='cust'?'거래처별':'일자별', file:'매입판매등록_'+(VIEW==='cust'?'거래처별':'일자별')+'_'+stamp,
      cols:hd.cols, head2:hd.h2, al:(VIEW==='cust'?'l':'c')+'r'.repeat(hd.cols.length-1), w:[VIEW==='cust'?34:12].concat(hd.cols.slice(1).map(function(c){ return c==='건수'?6:13; })), rows:rows2 });
  }
  /* 거래처×일자 — 거래처마다 날짜 줄, 끝에 소계(연보라) · 맨 끝 합계 (견본 원장과 같은 결) */
  var hd3=sideHead(['거래처','일자']), rows3=[];
  roll(list, custKey, custTxt).sort(byTot).forEach(function(g){
    var kids=roll(list.filter(function(r){ return custKey(r)===g.key; }), function(r){ return String(r.dt); }, function(r){ return d10(r.dt); }).sort(function(x,y){ return x.key<y.key?1:-1; });
    kids.forEach(function(k, i){ rows3.push({ k:'line', c:[i?'':g.lbl, k.lbl].concat(sideVals(k.a)) }); });
    rows3.push({ k:'sub', c:['소계', ''].concat(sideVals(g.a)) });
  });
  rows3.push({ k:'tot', c:['합계', ''].concat(sideVals(tot)) });
  return Object.assign(base, { title:'['+gw+'] 거래처×일자 등록현황', sheet:'거래처일자', file:'매입판매등록_거래처일자_'+stamp,
    cols:hd3.cols, head2:hd3.h2, al:'lc'+'r'.repeat(hd3.cols.length-2), w:[34,11].concat(hd3.cols.slice(2).map(function(c){ return c==='건수'?6:13; })), rows:rows3 });
}
function specLedger(gb, list){
  var s=SIDE_LG[gb], b=headBase();
  return { title:'['+(gb==='S'?'판매':'매입')+'] 거래처별 '+s.ttl+' 전체조회', period:b.period, gbNm:s.gbNm, sheet:s.ttl,
           cols:['거래처','일자','번호','NO','구분','상품명','수량','단가','금액',s.amt,'계'], al:'lccccl'+'rrrrr', w:[30,11,6,5,6,50,8,11,13,13,14], q:{6:1},
           rows:ledgerRows(list, gb) };
}
function sidesOut(list){ return cols().filter(function(g){ return list.some(function(r){ return r.gb===g; }); }); }
function ledgerFile(){ var g=gv('gb'); return (g==='S'?'매출원장':(g==='P'?'매입원장':'매입판매원장'))+'_'+gv('frDt').replace(/-/g,'')+'-'+gv('toDt').replace(/-/g,''); }
/* 출력할 spec 들 — 「이 탭」이면 한 장, 「상품별 원장」이면 판매·매입 따로 */
function specsGet(cb){
  if(OUTMODE()!=='ledger'){ if(!ROWS.length){ if(window._toast) _toast('먼저 조회하세요.','warning'); return; } var sp=specTab(); cb([sp], sp.file); return; }
  linesGet(function(all){
    var list=all.filter(lineHit), sides=sidesOut(list);
    if(!sides.length){ _alertBox('이 조건에 나갈 줄이 없습니다.',{icon:'ℹ️'}); return; }
    cb(sides.map(function(g){ return specLedger(g, list); }), ledgerFile());
  });
}

function excel(){
  specsGet(function(specs, file){
    var X=window.XLSX;   /* xlsx-js-style(색·병합·테두리) — 이 화면이 직접 싣는다 */
    if(!X || !X.utils){ _alertBox('엑셀 도구를 불러오지 못했습니다. 새로고침 뒤 다시 눌러 주세요.',{icon:'⚠️'}); return; }
    var wb=X.utils.book_new();
    specs.forEach(function(sp){ X.utils.book_append_sheet(wb, specSheet(X, sp), sp.sheet); });
    X.writeFile(wb, file+'.xlsx');
  });
}
var FILL={ hd:'DDEBF7', day:'F3F9C4', sub:'E9CDF5', tot:'FFE699' };
function specSheet(X, sp){
  var n=sp.cols.length, band=bandOf(sp, n), aoa=[[sp.title],[],[sp.period]], merges=[{s:{r:0,c:0},e:{r:0,c:n-1}}, {s:{r:2,c:0},e:{r:2,c:n-1}}];
  var bandRow=[], col=0; band.forEach(function(o){ bandRow[col]=o.t; for(var i=1;i<o.s;i++) bandRow[col+i]=''; if(o.s>1) merges.push({s:{r:3,c:col},e:{r:3,c:col+o.s-1}}); col+=o.s; });
  aoa.push(bandRow);
  var headRows=[];
  if(sp.head2){
    var r1=[], r2=sp.cols.slice(); col=0;
    sp.head2.forEach(function(o){ r1[col]=o.t; for(var i=1;i<o.span;i++) r1[col+i]='';
      if(o.span>1) merges.push({s:{r:4,c:col},e:{r:4,c:col+o.span-1}});
      if(o.rows===2){ r2[col]=''; merges.push({s:{r:4,c:col},e:{r:5,c:col}}); }
      col+=o.span; });
    aoa.push(r1); aoa.push(r2); headRows=[4,5];
  } else { aoa.push(sp.cols); headRows=[4]; }
  var top=aoa.length;
  sp.rows.forEach(function(r){ aoa.push(r.c); });
  var ws=X.utils.aoa_to_sheet(aoa);
  ws['!merges']=merges; ws['!cols']=sp.w.map(function(x){ return {wch:x}; }); ws['!rows']=[{hpt:30},{hpt:6}];
  var line={ style:'thin', color:{ rgb:'9AA5B1' } }, B={ top:line, bottom:line, left:line, right:line };
  var put=function(r,c,st){ var a=X.utils.encode_cell({r:r,c:c}); if(!ws[a]) ws[a]={ t:'s', v:'' }; ws[a].s=st; return ws[a]; };
  put(0,0,{ font:{ bold:true, sz:16 }, alignment:{ horizontal:'center', vertical:'center' } });
  put(2,0,{ font:{ sz:10 }, alignment:{ horizontal:'left' } });
  [3].concat(headRows).forEach(function(R){ for(var c=0;c<n;c++) put(R,c,{ font:{ bold:true }, fill:{ patternType:'solid', fgColor:{ rgb:FILL.hd } }, border:B, alignment:{ horizontal:'center', vertical:'center', wrapText:true } }); });
  var H={ l:'left', c:'center', r:'right' };
  sp.rows.forEach(function(row, i){
    var R=top+i, fill=FILL[row.k];
    for(var c=0;c<n;c++){
      var v=row.c[c], st={ border:B, alignment:{ vertical:'center', horizontal:H[sp.al.charAt(c)]||'right', wrapText:sp.al.charAt(c)==='l' } };
      if(fill) st.fill={ patternType:'solid', fgColor:{ rgb:fill } };
      if(row.k!=='line'){ st.font={ bold:true }; if(typeof v==='string' && v) st.alignment.horizontal='center'; }
      if(typeof v==='number') st.numFmt=(sp.q&&sp.q[c]&&Math.round(v)!==v)?'#,##0.##':'#,##0';   /* ★정수는 「1.」로 안 보이게(2026-11-24 캡처) */
      put(R,c,st);
    }
  });
  return ws;
}

function printIt(){
  specsGet(function(specs, file){
    var w=window.open('', '_blank'); if(!w){ _alertBox('팝업이 막혀 인쇄 창을 열지 못했습니다.',{icon:'⚠️'}); return; }
    var num=function(v,q){ return typeof v==='number' ? (q?(Math.round(v*100)/100):Math.round(v)).toLocaleString() : esc(v); };
    var CL={ l:'l', c:'c', r:'' };
    var body=specs.map(function(sp, gi){
      var n=sp.cols.length, band=bandOf(sp, n), th='';
      if(sp.head2){
        th='<tr>'+sp.head2.map(function(o){ return '<th'+(o.span>1?' colspan="'+o.span+'"':'')+(o.rows===2?' rowspan="2"':'')+'>'+esc(o.t)+'</th>'; }).join('')+'</tr><tr>';
        var col=0; sp.head2.forEach(function(o){ if(o.rows!==2){ for(var i=0;i<o.span;i++) th+='<th>'+esc(sp.cols[col+i])+'</th>'; } col+=o.span; });
        th+='</tr>';
      } else th='<tr>'+sp.cols.map(function(c){ return '<th>'+esc(c)+'</th>'; }).join('')+'</tr>';
      return '<section'+(gi?' class="pb"':'')+'><h1>'+esc(sp.title)+'</h1><div class="per">'+esc(sp.period)+'</div><table><thead>'
        +'<tr class="band">'+band.map(function(o){ return '<th'+(o.s>1?' colspan="'+o.s+'"':'')+'>'+esc(o.t)+'</th>'; }).join('')+'</tr>'+th+'</thead><tbody>'
        +sp.rows.map(function(r){ return '<tr class="'+r.k+'">'+r.c.map(function(v, c){ var a=sp.al.charAt(c); if(r.k!=='line' && typeof v==='string' && v) a='c';
            return '<td class="'+(CL[a]||'')+'">'+num(v, sp.q&&sp.q[c])+'</td>'; }).join('')+'</tr>'; }).join('')
        +'</tbody></table></section>';
    }).join('');
    w.document.write('<!DOCTYPE html><html><head><meta charset="UTF-8"><title>'+esc(file)+'</title><style>'
      +'@page{size:A4 landscape;margin:9mm}body{font-family:"맑은 고딕","Malgun Gothic",sans-serif;font-size:10.5px;margin:0;color:#111}'
      +'h1{text-align:center;font-size:18px;margin:2px 0 8px}.per{margin:0 0 4px;font-size:11px}'
      +'table{border-collapse:collapse;width:100%}th,td{border:1px solid #8c96a0;padding:2px 4px}td{text-align:right;white-space:nowrap}td.l{text-align:left;white-space:normal}td.c{text-align:center}'
      +'th{background:#ddebf7;font-weight:700}tr.band th{font-size:11.5px}thead{display:table-header-group}tr{page-break-inside:avoid}'
      +'tr.day td{background:#f3f9c4;font-weight:700}tr.sub td{background:#e9cdf5;font-weight:700}tr.tot td{background:#ffe699;font-weight:800}'
      +'.pb{page-break-before:always}*{-webkit-print-color-adjust:exact;print-color-adjust:exact}'
      +'</style></head><body>'+body+'</body></html>');
    w.document.close(); setTimeout(function(){ w.focus(); w.print(); }, 300);
  });
}

/* 셸이 이 화면을 다시 보여 줄 때 — 다른 화면에서 전표를 넣었을 수 있다(3초 안 중복은 한 번만) */
window.konetShown=function(){ if(Date.now()-_shownAt<3000) return; _shownAt=Date.now(); load(); };
document.getElementById('q').addEventListener('keydown', function(e){ if(e.key==='Escape'){ this.value=''; render(); } });
setRange('m0');
</script>
</body>
</html>
