<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>원가 관리</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 📥 엑셀 (전역 XLSX) --%>
<!--
  원가 관리 (2026-09-21 신설 — 「코네트 비용 등록까지 해서 원가계산 관리가 필요함 … 전체 원가관리를 이야기한 겁니다」) — 매출 관리 ▸ 원가 관리. 셸 iframe(logiFrame) 화면.
  ★총괄관리자(s_main_gu='1')만 — 메뉴 숨김 + 컨트롤러(/mangr/costMng.do·costBase.do) 차단. 비용 등록과 같은 규칙.
  · 회사 전체의 달별 원가 : 매출 − 매입원가 = 매출총이익, − 비용(비용 등록) = 순이익. 원가율·총이익률·비용률·순이익률을 같이 본다.
      매출·매입원가 = 매출 그래프·마감현황과 같은 규칙(selectSalesChart : 정산서 + 정산서 없는 출고 추정 + 직접판매 / 출고수량 × 매입단가).
      비용 = 마감과 같은 규칙(expenseSumOf : 사용 끈 항목 제외, 직송 택배 운임 자동 포함).
  · 아래 표 = 비용 항목 × 달(구성비 포함). 달을 누르면 비용 등록 메뉴로 간다(그 달 비용을 넣거나 고치는 곳).
  · 달을 누르면 그 달의 세부 (2026-09-21 「한 단계 세부적인 내용」) : 품목별 · 출고장별 · 매입처별 · 사업장별 매출·매입원가·총이익(마감현황과 같은 자료
      /shipout/selectClosing.do 를 화면에서 묶는다) + 비용 내역(비용 등록의 항목과 내역 줄, /mangr/expenseMonth.do). 자바·DB 변경 없음.
      줄을 누르면 그 안이 펼쳐진다 (2026-09-21 「매입처별·사업장별 볼 수 있게, 코드 없는 곳 찾기 위함도」) — 출고장·매입처·사업장 줄 = 그 안의 품목들,
      품목 줄 = 그 품목의 매입처·출고장. 「코드 없는 것만」 = 코드가 비었거나 이름이 (미지정)인 줄만(펼친 안쪽 줄의 빈 코드는 빨간 「코드 없음」).
      품목별은 주코드로 묶는다 (2026-09-21 「품목별은 주코드 매칭은 주코드 보여주고」) — 서브코드(거래처 통보 코드, /prod/extItemList.do 에서 통보 코드 ≠ 주코드인 것.
      재고 일괄조정·상품코드와 같은 규칙)로 나간 출고는 주코드 줄에 합치고 「주」 배지와 서브 수를 붙인다. 그 줄을 펼치면 원래 코드(주·서브)별로 나온다.
      매입처·사업장이 빈 줄은 출처별로 나눈다 (2026-09-21) — 마감 자료의 근거(saleSrc) : 「출고미상」 = 출고 짝 없는 정산서, 「전표」 = 직접판매 전표
      (그 매입처 칸은 판매 거래처다), 그 밖에 빈 것 = 출고 자료에 매입처·사업장이 없는 것. 회색 꼬리표로 표시.
      세부 합계는 출고 자료 기준이라, 정산서만 있고 출고 짝이 없는 건·직접판매 전표가 있으면 위 달별 표의 매출과 조금 다를 수 있다(차이를 표시한다).
  · 견적서관리 ▸ 원가·마진 계산(품목 하나의 견적 원가)과는 다른 화면이다 — 그쪽은 손대지 않는다.
  · DB 쓰기 없음. 자료 = /mangr/costBase.do {months, cur}.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; --blue:#2f4f9a; --pur:#6b4fb3; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:15px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:13.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:36px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:14px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  select{ height:36px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:14.5px; background:#fff; }
  .opt{ display:inline-flex; align-items:center; gap:6px; font-size:14px; border:1px solid var(--bd); border-radius:8px; padding:6px 12px; cursor:pointer; background:#fff; }
  .opt:has(input:checked){ border-color:#0f6b5e; background:#e3f2ee; }
  .opt input{ margin:0; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:15px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:13px; }
  .card .bd{ padding:12px; }
  .dim{ color:#8a98a8; }
  .note{ font-size:13px; color:#6b7a89; line-height:1.6; }
  .kpis{ display:grid; grid-template-columns:repeat(5, minmax(0,1fr)); gap:10px; margin-bottom:14px; }
  .kpi{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:12px 14px; }
  .kpi .k{ font-size:13px; color:#6b7a89; font-weight:700; }
  .kpi .v{ font-size:22px; font-weight:800; margin-top:4px; font-variant-numeric:tabular-nums; }
  .kpi .s{ font-size:13px; color:#37475a; margin-top:2px; font-weight:700; }
  .kpi.g .v{ color:var(--teal); } .kpi.e .v{ color:var(--pur); } .kpi.n .v{ color:var(--blue); } .kpi.neg .v{ color:var(--red); }
  @media (max-width:900px){ .kpis{ grid-template-columns:repeat(2, minmax(0,1fr)); } }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:14px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:700; font-size:13.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:8px 8px; text-align:center; white-space:nowrap; }
  table.g th.e{ background:#e3d9f5; color:#4a3590; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:7px 8px; text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap; }
  table.g td.c{ text-align:center; } table.g td.l{ text-align:left; }
  table.g td.r2{ color:#6b7a89; font-size:13px; }
  table.g td.e{ background:#f7f3fd; }
  table.g td.neg{ color:var(--red); }
  table.g tr.sum td{ background:#eef4f2; font-weight:800; border-top:2px solid #cfe0da; }
  table.g tr.pick{ cursor:pointer; } table.g tr.pick:hover td{ background:#f1f8f6; }
  table.g tr.on td{ background:#e3f2ee !important; }
  .tabs{ display:flex; gap:6px; flex-wrap:wrap; }
  .tab{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:8px; padding:0 14px; cursor:pointer; font-size:14px; font-weight:700; color:#37475a; }
  .tab.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .tab.e.on{ background:var(--pur); border-color:var(--pur); }
  table.g td.low{ color:var(--amber); font-weight:700; }
  table.g tr.dl td{ background:#fbf9fe; font-size:13.5px; color:#37475a; }
  table.g tr.grp{ cursor:pointer; } table.g tr.grp:hover td{ background:#f1f8f6; }
  table.g tr.grp.open td{ background:#e9f4f1; font-weight:700; }
  table.g tr.ch td{ background:#fafcfb; font-size:13.5px; color:#37475a; }
  .mainb{ display:inline-block; font-size:11.5px; font-weight:800; background:#e3f2ee; color:#0f6b5e; border-radius:5px; padding:1px 6px; margin-left:4px; }
  .subb{ display:inline-block; font-size:11.5px; font-weight:800; background:#eef2f5; color:#556; border-radius:5px; padding:1px 6px; margin-left:4px; }
  .srcb{ display:inline-block; font-size:11.5px; font-weight:800; background:#fdf0d5; color:#9a5b05; border-radius:5px; padding:1px 6px; margin-left:4px; }
  .nocd{ display:inline-block; font-size:11.5px; font-weight:800; background:#fdecec; color:var(--red); border-radius:5px; padding:1px 6px; }
  .q{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:14px; width:200px; }
  .barc{ display:inline-block; height:10px; border-radius:3px; background:var(--blue); vertical-align:middle; margin-left:6px; }
  .barc.neg{ background:var(--red); }
</style>
</head>
<body>
<div class="wrap">
  <h2>📊 원가 관리 <small>— 회사 전체의 달별 매출·매입원가·비용(비용 등록)·순이익. 총괄관리자 전용</small>
    <label class="opt" style="font-weight:600;margin-left:6px" title="켜면 가운데에 달 세부(출고장별·매입처별·사업장별·비용 내역)가 열린다 — 달별 표에서 달을 눌러 바꾼다. 끄면 달별 표와 비용 항목 표만"><input type="checkbox" id="dShow" onchange="dShowSet()"> 세부 내역 보기</label>
    <span class="bar" style="margin-left:auto">
      <select id="months" title="바꾼 뒤 [조회]를 눌러야 적용됩니다"><option value="6" selected>최근 6개월</option><option value="12">최근 12개월</option><option value="24">최근 24개월</option></select>
      <label class="opt" title="바꾼 뒤 [조회]를 눌러야 적용됩니다"><input type="checkbox" id="cur" checked> 이번 달 포함</label>
      <button class="btn btn-teal" onclick="load()">🔍 조회</button>
      <button class="btn" onclick="excel()">📥 엑셀</button>
      <button class="btn" onclick="goExpense()" title="매출 관리 ▸ 비용 등록으로">💸 비용 등록</button>
    </span>
  </h2>

  <div class="kpis" id="kpis"></div>

  <div class="card">
    <div class="hd">달별 원가·손익 <small id="rng"></small></div>
    <div class="tw" style="max-height:52vh"><table class="g">
      <thead><tr><th>월</th><th>매출</th><th>매입원가</th><th>원가율</th><th>매출총이익</th><th>총이익률</th><th class="e">비용</th><th class="e">비용률</th><th>순이익</th><th>순이익률</th></tr></thead>
      <tbody id="mBody"><tr><td colspan="10" class="c dim" style="padding:24px">기간을 고르고 [🔍 조회]를 누르세요.</td></tr></tbody>
    </table></div>
    <div class="bd note">· 매출총이익 = 매출 − 매입원가 · 순이익 = 매출총이익 − 비용 · 원가율·총이익률·비용률·순이익률은 모두 매출 대비 · 이번 달은 진행 중이라 매출이 덜 잡혀 있다</div>
  </div>

  <div class="card" id="dCard" style="display:none">
    <div class="hd"><span id="dTitle">세부</span> <small id="dSub"></small>
      <span class="bar" style="margin-left:auto">
        <button class="btn" onclick="dExcel()">📥 이 표 엑셀</button>
        <button class="btn" onclick="dClose()">닫기</button>
      </span>
    </div>
    <div class="bd" style="padding-bottom:6px">
      <div class="tabs">
        <button class="tab on" data-k="dc" onclick="dTab('dc')">출고장별</button>
        <button class="tab" data-k="vendor" onclick="dTab('vendor')">매입처별</button>
        <button class="tab" data-k="biz" onclick="dTab('biz')">사업장별</button>
        <button class="tab e" data-k="exp" onclick="dTab('exp')">비용 내역</button>
        <span class="bar" style="margin-left:18px">
          <input type="text" class="q" id="dQcd" placeholder="코드" style="width:130px" onkeydown="if(event.keyCode===13) dRender()">
          <input type="text" class="q" id="dQnm" placeholder="이름" style="width:190px" onkeydown="if(event.keyCode===13) dRender()">
          <label class="opt" title="코드가 비었거나 이름이 (미지정)인 줄만 — 코드 안 잡힌 매입처·사업장·출고장·품목 찾기"><input type="checkbox" id="dNoCd" onchange="dRender()"> 코드 없는 것만</label>
          <button class="btn btn-teal" onclick="dRender()">🔍 조회</button>
          <button class="btn" onclick="document.getElementById('dQcd').value=''; document.getElementById('dQnm').value=''; document.getElementById('dNoCd').checked=false; dRender()">지우기</button>
        </span>
      </div>
    </div>
    <div class="tw" style="max-height:60vh"><table class="g"><thead id="dHead"></thead><tbody id="dBody"></tbody></table></div>
    <div class="bd note" id="dNote"></div>
  </div>

  <div class="card">
    <div class="hd">비용 항목 × 달 <small>— 비용 등록에 넣은 항목별 금액(사용 끈 항목 제외, 직송 택배 운임은 자동 계산분)</small></div>
    <div class="tw" style="max-height:46vh"><table class="g"><thead id="iHead"></thead><tbody id="iBody"></tbody></table></div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
function n(v){ if(v==null) return 0; var x=parseFloat(String(v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v,d){ d=d==null?0:d; return n(v).toLocaleString('ko-KR',{minimumFractionDigits:d,maximumFractionDigits:d}); }
function pct(a,b){ return n(b)? fmt(n(a)/n(b)*100,1)+'%' : ''; }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function gv(id){ var e=document.getElementById(id); return e?e.value:''; }
function ymTxt(s){ s=String(s||''); return s.length===6? s.slice(0,4)+'-'+s.slice(4) : s; }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body||'' }); }
var _d=null;

function load(){
  document.getElementById('mBody').innerHTML='<tr><td colspan="10" class="c dim" style="padding:24px">불러오는 중…</td></tr>';
  post('/mangr/costBase.do','months='+encodeURIComponent(gv('months')||'6')+'&cur='+(document.getElementById('cur').checked?'Y':'N'))
    .then(function(r){ return r.json().then(function(j){ if(!r.ok) throw new Error((j&&j.error)||('HTTP '+r.status)); return j; }); })
    .then(function(j){ _d=j; render(); if(dShowOn()){ var ms=(j.months||[]), has=ms.some(function(m){ return m.ym===_dYm; }); if(ms.length) dOpen(has?_dYm:ms[ms.length-1].ym); } })
    .catch(function(e){ document.getElementById('mBody').innerHTML='<tr><td colspan="10" class="c neg" style="padding:24px">자료를 못 불러왔습니다 — '+esc(e.message)+'</td></tr>'; });
}
function render(){
  var j=_d, ms=j.months||[], sale=n(j.saleAmt), cost=n(j.costAmt), exp=n(j.expAmt), gross=sale-cost, net=gross-exp;
  document.getElementById('rng').textContent='— '+ymTxt(j.fromYm)+' 부터 '+ymTxt(j.toYm)+' 까지';
  document.getElementById('kpis').innerHTML=
      '<div class="kpi"><div class="k">매출</div><div class="v">'+fmt(sale)+'</div><div class="s">'+ms.length+'개월</div></div>'
     +'<div class="kpi"><div class="k">매입원가</div><div class="v">'+fmt(cost)+'</div><div class="s">원가율 '+pct(cost,sale)+'</div></div>'
     +'<div class="kpi g"><div class="k">매출총이익</div><div class="v">'+fmt(gross)+'</div><div class="s">총이익률 '+pct(gross,sale)+'</div></div>'
     +'<div class="kpi e"><div class="k">비용 (비용 등록)</div><div class="v">'+fmt(exp)+'</div><div class="s">비용률 '+pct(exp,sale)+'</div></div>'
     +'<div class="kpi n'+(net<0?' neg':'')+'"><div class="k">순이익</div><div class="v">'+fmt(net)+'</div><div class="s">순이익률 '+pct(net,sale)+'</div></div>';
  var maxAbs=ms.reduce(function(a,m){ return Math.max(a, Math.abs(n(m.saleAmt)-n(m.costAmt)-n(m.expAmt))); },0)||1;
  var rows=ms.slice().reverse().map(function(m){
    var s=n(m.saleAmt), c=n(m.costAmt), e=n(m.expAmt), g=s-c, t=g-e, w=Math.round(Math.abs(t)/maxAbs*70);
    return '<tr class="pick'+(_dYm===m.ym?' on':'')+'" onclick="dOpen(\''+m.ym+'\')"><td class="c"><b>'+ymTxt(m.ym)+'</b> <span class="dim">▸</span></td><td>'+fmt(s)+'</td><td>'+fmt(c)+'</td><td class="r2">'+pct(c,s)+'</td><td>'+fmt(g)+'</td><td class="r2">'+pct(g,s)+'</td>'
      +'<td class="e">'+(e?fmt(e):'<span class="dim">미등록</span>')+'</td><td class="e r2">'+pct(e,s)+'</td><td class="'+(t<0?'neg':'')+'"><b>'+fmt(t)+'</b><span class="barc'+(t<0?' neg':'')+'" style="width:'+w+'px"></span></td><td class="r2'+(t<0?' neg':'')+'">'+pct(t,s)+'</td></tr>';
  });
  rows.push('<tr class="sum"><td class="c">합계</td><td>'+fmt(sale)+'</td><td>'+fmt(cost)+'</td><td>'+pct(cost,sale)+'</td><td>'+fmt(gross)+'</td><td>'+pct(gross,sale)+'</td><td>'+fmt(exp)+'</td><td>'+pct(exp,sale)+'</td><td'+(net<0?' class="neg"':'')+'>'+fmt(net)+'</td><td'+(net<0?' class="neg"':'')+'>'+pct(net,sale)+'</td></tr>');
  document.getElementById('mBody').innerHTML=rows.join('');
  /* 비용 항목 × 달 */
  var items=j.items||[], yms=ms.map(function(m){ return m.ym; });
  document.getElementById('iHead').innerHTML='<tr><th>항목</th>'+yms.map(function(y){ return '<th class="e">'+ymTxt(y)+'</th>'; }).join('')+'<th>합계</th><th>구성비</th></tr>';
  if(!items.length){ document.getElementById('iBody').innerHTML='<tr><td colspan="'+(yms.length+3)+'" class="c dim" style="padding:20px">이 기간에 등록된 비용이 없습니다 — [💸 비용 등록]에서 달마다 넣으면 여기에 반영됩니다.</td></tr>'; return; }
  var body=items.map(function(it){
    return '<tr><td class="l"><b>'+esc(it.itemNm||it.itemCd)+'</b></td>'+ms.map(function(m){ var a=n((m.items||{})[it.itemCd]); return '<td class="e">'+(a?fmt(a):'')+'</td>'; }).join('')+'<td><b>'+fmt(it.amt)+'</b></td><td class="r2">'+pct(it.amt,exp)+'</td></tr>';
  });
  body.push('<tr class="sum"><td class="c">합계</td>'+ms.map(function(m){ return '<td>'+(n(m.expAmt)?fmt(m.expAmt):'')+'</td>'; }).join('')+'<td>'+fmt(exp)+'</td><td>100%</td></tr>');
  document.getElementById('iBody').innerHTML=body.join('');
}
/* ── 달 세부 (2026-09-21 「한 단계 세부적인 내용」) — 마감 자료(품목 × 사업장 × 출고장 × 매입처)를 화면에서 묶는다 ── */
var _dYm='', _dKind='dc', _dRows=[], _dExp=null, _dView=[], _dOpen={};   /* _dOpen = 펼친 줄 {kind|cd|nm: true} */
/* 서브코드 → 주코드 (재고 일괄조정 loadAux 와 같은 규칙 : 통보 코드와 주코드가 다를 때만 서브) · 주코드 → 상품명 */
var _mainOf={}, _pnm={};
function loadAux(){
  var p=function(u){ return post(u,'').then(function(r){ return r.json(); }); };
  return Promise.all([ p('/prod/prodList.do'), p('/prod/extItemList.do') ]).then(function(a){
    var pn={}, mo={};
    ((a[0]&&a[0].data)||[]).forEach(function(o){ if(o.prodCd) pn[String(o.prodCd)]=o.prodNm||''; });
    ((a[1]&&a[1].data)||[]).forEach(function(o){ if(o.prodCd && o.extItemCd && String(o.extItemCd)!==String(o.prodCd)) mo[String(o.extItemCd)]=String(o.prodCd); });
    _pnm=pn; _mainOf=mo; if(_dYm) dRender();
  }).catch(function(){});
}
function mainCd(cd){ cd=String(cd||''); return _mainOf[cd]||cd; }
/* 출고장·매입처·사업장 묶음의 코드·이름 — 빈 것은 출처별 이름으로 (마감 자료의 saleSrc : 출고미상 / 전표) */
function dKey(kind, r){
  var K=D_KEYS[kind], cd=String(r[K[0]]||''), nm=String(r[K[1]]||''), src=String(r.saleSrc||''), tag='';
  if(kind==='vendor'){ if(src==='출고미상'){ cd=''; nm='출고 짝 없는 정산서'; tag='정산서만'; } else if(src==='전표'){ nm=nm||'(거래처 미지정)'; tag='직접판매'; } else if(!cd && !nm){ nm='매입처 없음'; tag='출고 자료'; } }
  else if(kind==='biz'){ if(src==='출고미상'){ cd=''; nm='출고 짝 없는 정산서'; tag='정산서만'; } else if(src==='전표'){ cd=''; nm='직접판매(전표)'; tag='직접판매'; } else if(!cd && !nm){ nm='사업장 없음'; tag='출고 자료'; } }
  else if(kind==='dc'){ if(!cd && !nm){ nm='출고장 없음'; tag='출고 자료'; } }
  return { cd:cd, nm:nm||'(미지정)', tag:tag };
}
function noCd(cd,nm){ return !String(cd||'').trim() || String(nm||'')==='(미지정)' || !String(nm||'').trim(); }
function cdCell(cd){ return String(cd||'').trim()? esc(cd) : '<span class="nocd">코드 없음</span>'; }
var TAG_TIP={ '정산서만':'정산서에는 있는데 출고 자료에 짝이 없는 건 — 매입처·사업장을 알 수 없다', '직접판매':'판매등록 전표 — 이 칸의 이름은 매입처가 아니라 판매 거래처', '출고 자료':'출고 자료에 이 값이 비어 있다(예: 예전 DC 발주 등록분)' };
/* 펼친 안쪽 줄 — 출고장·매입처·사업장 줄이면 그 안의 품목, 품목 줄이면 그 품목의 매입처 × 출고장 */
function dChildren(kind, g){
  var K=D_KEYS[kind], map={}, out=[];
  _dRows.forEach(function(r){
    if(kind==='item'){ var oc=String(r.itemCd||''); if(g.cd){ if(mainCd(oc)!==g.cd) return; } else { if(oc || (String(r.itemNm||'')||'(미지정)')!==g.nm) return; } }
    else { var dk=dKey(kind,r); if(dk.cd!==g.cd || dk.nm!==g.nm) return; }
    var cd, nm;
    if(kind==='item' && g.mapped){ cd=String(r.itemCd||''); nm=(String(r.itemNm||'')||'(미지정)')+(cd!==g.cd?' 〔서브〕':' 〔주〕'); }
    else if(kind==='item'){ cd=String(r.vendorCd||''); nm=(String(r.vendorNm||'')||'(미지정)')+' · '+(String(r.dcNm||'')||'(출고장 미지정)'); }
    else { cd=mainCd(r.itemCd); nm=_pnm[cd]||String(r.itemNm||'')||'(미지정)'; }   /* 출고장·매입처·사업장 안의 품목도 주코드로 */
    var key=cd+'|'+nm, c=map[key]; if(!c){ c=map[key]={ cd:cd, nm:nm, qty:0, sale:0, cost:0 }; out.push(c); }
    c.qty+=n(r.outQty); c.sale+=n(r.salesAmt); c.cost+=n(r.costAmt); });
  out.sort(function(a,b){ return b.sale-a.sale; });
  return out;
}
function dToggle(i){ var g=_dView[i]; if(!g) return; var k=_dKind+'|'+g.cd+'|'+g.nm; if(_dOpen[k]) delete _dOpen[k]; else _dOpen[k]=true; dRender(); }
var D_KEYS={ item:['itemCd','itemNm','품목'], dc:['dcCd','dcNm','출고장'], vendor:['vendorCd','vendorNm','매입처'], biz:['bizCd','bizNm','사업장'] };
/* 「세부 내역 보기」 — 꺼져 있으면 가운데 영역을 닫아 두고 달을 눌러도 열지 않는다. 켜면 고른 달(없으면 가장 최근 달)을 연다 */
function dShowOn(){ var e=document.getElementById('dShow'); return !!(e&&e.checked); }
function dShowSet(){
  if(!dShowOn()){ dClose(); return; }
  if(!_d){ _toast('먼저 [🔍 조회]를 누르세요.'); return; }
  var ms=(_d.months||[]); if(!_dYm && ms.length) dOpen(ms[ms.length-1].ym);
}
function dOpen(ym){
  if(!dShowOn()) return;
  _dYm=ym; _dRows=[]; _dExp=null; _dOpen={}; document.getElementById('dCard').style.display='';
  document.getElementById('dTitle').textContent=ymTxt(ym)+' 세부'; document.getElementById('dSub').textContent='';
  document.getElementById('dHead').innerHTML=''; document.getElementById('dBody').innerHTML='<tr><td class="c dim" style="padding:22px">집계 중입니다… (정산서 대사 포함이라 몇 초 걸릴 수 있습니다)</td></tr>'; document.getElementById('dNote').textContent='';
  if(_d) render();   /* 고른 달 표시 */
  var y=ymTxt(ym);
  var p1=post('/shipout/selectClosing.do','ym='+encodeURIComponent(y)).then(function(r){ return r.json(); }).then(function(j){ _dRows=(j&&j.data)||[]; });
  var p2=post('/mangr/expenseMonth.do','ym='+encodeURIComponent(ym)).then(function(r){ return r.json(); }).then(function(j){ _dExp=j||null; }).catch(function(){ _dExp=null; });
  Promise.all([p1,p2]).then(function(){ if(_dYm===ym){ dRender(); document.getElementById('dCard').scrollIntoView({behavior:'smooth',block:'start'}); } })
    .catch(function(e){ document.getElementById('dBody').innerHTML='<tr><td class="c neg" style="padding:22px">세부를 못 불러왔습니다 — '+esc(e.message)+'</td></tr>'; });
}
function dClose(){ _dYm=''; document.getElementById('dCard').style.display='none'; var e=document.getElementById('dShow'); if(e) e.checked=false; if(_d) render(); }
function dTab(k){ _dKind=k; Array.prototype.forEach.call(document.querySelectorAll('.tab'), function(b){ b.classList.toggle('on', b.getAttribute('data-k')===k); }); dRender(); }
function dGroup(kind){
  var K=D_KEYS[kind], map={}, out=[];
  _dRows.forEach(function(r){ var cd=String(r[K[0]]||''), nm=String(r[K[1]]||''), key=cd+'|'+nm, org=cd, tag='';
    if(kind!=='item'){ var dk=dKey(kind,r); cd=dk.cd; nm=dk.nm; tag=dk.tag; key=cd+'|'+nm; }
    if(kind==='item'){ cd=mainCd(org); if(_pnm[cd]) nm=_pnm[cd]; key=cd? cd : ('|'+nm); }   /* 품목 = 주코드로 묶는다(코드가 비면 이름으로) */
    var g=map[key]; if(!g){ g=map[key]={ cd:cd, nm:nm||'(미지정)', tag:tag, qty:0, sale:0, cost:0, items:{}, orgs:{}, mapped:false }; out.push(g); }
    if(kind==='item'){ g.orgs[org]=1; if(org!==cd) g.mapped=true; }
    g.qty+=n(r.outQty); g.sale+=n(r.salesAmt); g.cost+=n(r.costAmt); if(kind!=='item') g.items[String(r.itemCd||'')]=1; });
  out.forEach(function(g){ g.cnt=Object.keys(g.items).length; g.subCnt=Object.keys(g.orgs).filter(function(o){ return o!==g.cd; }).length; });
  out.sort(function(a,b){ return b.sale-a.sale; });
  return out;
}
function dRender(){
  if(!_dYm) return;
  var qc=(gv('dQcd')||'').trim().toLowerCase(), qn=(gv('dQnm')||'').trim().toLowerCase(), q=qc||qn, head=document.getElementById('dHead'), body=document.getElementById('dBody'), note=document.getElementById('dNote');
  var mon=((_d&&_d.months)||[]).filter(function(m){ return m.ym===_dYm; })[0]||{};
  if(_dKind==='exp'){ dRenderExp(qn||qc, mon); return; }
  var K=D_KEYS[_dKind], rows=dGroup(_dKind), tSale=0, tCost=0, tQty=0;
  rows.forEach(function(g){ tSale+=g.sale; tCost+=g.cost; tQty+=g.qty; });
  var only=document.getElementById('dNoCd').checked;
  var view=rows.filter(function(g){ if(only && !noCd(g.cd,g.nm)) return false; if(qc && String(g.cd).toLowerCase().indexOf(qc)<0) return false; if(qn && String(g.nm).toLowerCase().indexOf(qn)<0) return false; return true; }); _dView=view;
  head.innerHTML='<tr><th>No</th><th>'+K[2]+'코드</th><th>'+K[2]+'</th>'+(_dKind==='item'?'':'<th>품목 수</th>')+'<th>출고수량</th><th>매출</th><th>매입원가</th><th>원가율</th><th>매출총이익</th><th>총이익률</th><th>매출 비중</th></tr>';
  var cols=_dKind==='item'?10:11;
  if(!view.length){ body.innerHTML='<tr><td colspan="'+cols+'" class="c dim" style="padding:22px">'+(rows.length?(only?'코드 없는 줄이 없습니다.':'거른 결과가 없습니다.'):'이 달의 출고 자료가 없습니다.')+'</td></tr>'; }
  else {
    var vS=0,vC=0,vQ=0, html=view.map(function(g,i){ var m=g.sale-g.cost, rt=g.sale? m/g.sale : 0, cls=m<0?'neg':(rt<0.1?'low':''); vS+=g.sale; vC+=g.cost; vQ+=g.qty;
      var open=!!_dOpen[_dKind+'|'+g.cd+'|'+g.nm];
      var row='<tr class="grp'+(open?' open':'')+'" onclick="dToggle('+i+')" title="누르면 안쪽('+(_dKind==='item'?(g.mapped?'원래 코드(주·서브)':'매입처 · 출고장'):'품목')+')이 펼쳐집니다"><td class="c">'+(i+1)+'</td><td class="c">'+cdCell(g.cd)+'</td><td class="l"><span class="dim">'+(open?'▾':'▸')+'</span> '+esc(g.nm)+(g.tag?'<span class="srcb">'+esc(g.tag)+'</span>':'')+((_dKind==='item'&&g.mapped)?'<span class="mainb">주</span><span class="subb">서브 '+g.subCnt+'</span>':'')+'</td>'+(_dKind==='item'?'':'<td>'+fmt(g.cnt)+'</td>')+'<td>'+fmt(g.qty)+'</td><td>'+fmt(g.sale)+'</td><td>'+fmt(g.cost)+'</td><td class="r2">'+pct(g.cost,g.sale)+'</td><td class="'+cls+'"><b>'+fmt(m)+'</b></td><td class="r2 '+cls+'">'+pct(m,g.sale)+'</td><td class="r2">'+pct(g.sale,tSale)+'</td></tr>';
      if(open) row+=dChildren(_dKind,g).map(function(c){ var cm=c.sale-c.cost, crt=c.sale? cm/c.sale : 0, ccls=cm<0?'neg':(crt<0.1?'low':'');
        return '<tr class="ch"><td></td><td class="c">'+cdCell(c.cd)+'</td><td class="l">　└ '+esc(c.nm)+'</td>'+(_dKind==='item'?'':'<td></td>')+'<td>'+fmt(c.qty)+'</td><td>'+fmt(c.sale)+'</td><td>'+fmt(c.cost)+'</td><td class="r2">'+pct(c.cost,c.sale)+'</td><td class="'+ccls+'">'+fmt(cm)+'</td><td class="r2 '+ccls+'">'+pct(cm,c.sale)+'</td><td class="r2">'+pct(c.sale,g.sale)+'</td></tr>'; }).join('');
      return row; });
    html.push('<tr class="sum"><td class="c" colspan="3">'+(q?'거른 합계':'합계')+' ('+view.length+'건)</td>'+(_dKind==='item'?'':'<td></td>')+'<td>'+fmt(vQ)+'</td><td>'+fmt(vS)+'</td><td>'+fmt(vC)+'</td><td>'+pct(vC,vS)+'</td><td>'+fmt(vS-vC)+'</td><td>'+pct(vS-vC,vS)+'</td><td>'+pct(vS,tSale)+'</td></tr>');
    body.innerHTML=html.join('');
  }
  var low=rows.filter(function(g){ var m=g.sale-g.cost; return g.sale && m/g.sale<0.1; }).length, neg=rows.filter(function(g){ return g.sale-g.cost<0; }).length;
  document.getElementById('dSub').textContent='— '+K[2]+' '+rows.length+'건 · 매출 '+fmt(tSale)+' · 매입원가 '+fmt(tCost)+' · 총이익 '+fmt(tSale-tCost)+' ('+pct(tSale-tCost,tSale)+')';
  var diff=Math.round(n(mon.saleAmt)-tSale);
  var nc=rows.filter(function(g){ return noCd(g.cd,g.nm); }).length;
  var tags={}; rows.forEach(function(g){ if(g.tag) tags[g.tag]=1; });
  var tagTxt=Object.keys(tags).map(function(t){ return '<span class="srcb" style="margin-left:0">'+esc(t)+'</span> '+esc(TAG_TIP[t]||''); }).join(' · ');
  note.innerHTML=(tagTxt? '· '+tagTxt+'<br>' : '')+'· <b>줄을 누르면 안쪽('+(_dKind==='item'?'「주」 줄은 원래 코드(주·서브)별, 그 외는 매입처 · 출고장':'품목(주코드 기준)')+')이 펼쳐진다</b>'+(_dKind==='item'?' · 서브코드로 나간 출고는 주코드 줄에 합쳤다('+rows.filter(function(g){ return g.mapped; }).length+'건)':'')+' · 코드 없는 '+K[2]+' '+nc+'건 · 주황 = 총이익률 10% 미만('+low+'건), 빨강 = 역마진('+neg+'건) · 매출 많은 순'
    +(Math.abs(diff)>1?' · 위 달별 표의 매출 '+fmt(mon.saleAmt)+' 과 '+fmt(Math.abs(diff))+'원 차이 — 세부는 출고 자료 기준이라 출고 짝이 없는 정산서·직접판매 전표는 여기에 안 들어간다':' · 위 달별 표의 매출과 일치');
}
function dRenderExp(q, mon){
  var head=document.getElementById('dHead'), body=document.getElementById('dBody'), note=document.getElementById('dNote'), e=_dExp||{};
  head.innerHTML='<tr><th class="e">항목</th><th class="e">구분</th><th class="e">일자</th><th class="e">내용</th><th class="e">금액</th><th class="e">구성비</th><th class="e">확인</th><th class="e">비고</th></tr>';
  var trx={}; (e.trx||[]).forEach(function(t){ trx[t.itemCd]=t; });
  var items=(e.items||[]).filter(function(it){ return String(it.useYn||'Y')==='Y'; }), tot=0, rows=[]; _dView=[];
  items.forEach(function(it){ var amt= String(it.autoSrc||'')==='PARCEL' ? n(e.auto&&e.auto.amt) : n((trx[it.itemCd]||{}).amt); it._amt=amt; tot+=amt; });
  items.forEach(function(it){
    var dl=(e.dtl||[]).filter(function(d){ return d.itemCd===it.itemCd; });
    if(q && (String(it.itemNm||'')+' '+dl.map(function(d){ return d.title; }).join(' ')).toLowerCase().indexOf(q)<0) return;
    var gb= String(it.autoSrc||'')==='PARCEL' ? '자동(택배)' : (String(it.itemGb||'')==='FIX'?'고정':'변동');
    rows.push('<tr><td class="l"><b>'+esc(it.itemNm||it.itemCd)+'</b></td><td class="c">'+gb+'</td><td></td><td class="l dim">'+(dl.length?('내역 '+dl.length+'줄'):'')+'</td><td class="e"><b>'+(it._amt?fmt(it._amt):'<span class="dim">미등록</span>')+'</b></td><td class="r2">'+pct(it._amt,tot)+'</td><td></td><td class="l">'+esc((trx[it.itemCd]||{}).remark||'')+'</td></tr>');
    _dView.push({ nm:it.itemNm||it.itemCd, gb:gb, dt:'', title:'', amt:it._amt, chk:'', rmk:(trx[it.itemCd]||{}).remark||'' });
    dl.forEach(function(d){ var dt=String(d.expDt||''); dt=dt.length===8? dt.slice(0,4)+'-'+dt.slice(4,6)+'-'+dt.slice(6) : dt;
      rows.push('<tr class="dl"><td></td><td></td><td class="c">'+esc(dt)+'</td><td class="l">└ '+esc(d.title)+'</td><td>'+fmt(d.amt)+'</td><td></td><td class="c">'+(String(d.chkYn)==='Y'?'✔':'')+'</td><td class="l">'+esc(d.remark)+'</td></tr>');
      _dView.push({ nm:'', gb:'', dt:dt, title:d.title, amt:n(d.amt), chk:String(d.chkYn)==='Y'?'Y':'', rmk:d.remark }); });
  });
  if(!rows.length) rows.push('<tr><td colspan="8" class="c dim" style="padding:22px">'+(items.length?'거른 결과가 없습니다.':'이 달에 등록된 비용 항목이 없습니다.')+'</td></tr>');
  else rows.push('<tr class="sum"><td class="c" colspan="4">비용 합계</td><td>'+fmt(tot)+'</td><td>100%</td><td></td><td></td></tr>');
  body.innerHTML=rows.join('');
  document.getElementById('dSub').textContent='— 비용 '+fmt(tot)+' · 매출 대비 '+pct(tot, mon.saleAmt);
  note.innerHTML='· 비용 등록 화면과 같은 자료(사용 끈 항목 제외, 직송 택배 운임은 자동 계산분) · 고치려면 <a href="javascript:goExpense()">💸 비용 등록</a>';
}
function dExcel(){
  if(typeof XLSX==='undefined'||!_dYm||!_dView.length){ _alertBox('엑셀로 낼 세부 자료가 없습니다.',{icon:'⚠️'}); return; }
  var aoa, nm;
  if(_dKind==='exp'){ nm='비용내역'; aoa=[['항목','구분','일자','내용','금액','확인','비고']].concat(_dView.map(function(r){ return [r.nm,r.gb,r.dt,r.title,r.amt,r.chk,r.rmk]; })); }
  else { var K=D_KEYS[_dKind]; nm=K[2]+'별'; aoa=[[K[2]+'코드',K[2],'출고수량','매출','매입원가','원가율','매출총이익','총이익률']]; _dView.forEach(function(g){ var m=g.sale-g.cost; aoa.push([g.cd,g.nm,g.qty,Math.round(g.sale),Math.round(g.cost),g.sale?+(g.cost/g.sale).toFixed(4):'',Math.round(m),g.sale?+(m/g.sale).toFixed(4):'']);
      if(_dOpen[_dKind+'|'+g.cd+'|'+g.nm]) dChildren(_dKind,g).forEach(function(c){ var cm=c.sale-c.cost; aoa.push([c.cd,'  └ '+c.nm,c.qty,Math.round(c.sale),Math.round(c.cost),c.sale?+(c.cost/c.sale).toFixed(4):'',Math.round(cm),c.sale?+(cm/c.sale).toFixed(4):'']); }); }); }
  var ws=XLSX.utils.aoa_to_sheet(aoa); ws['!cols']=aoa[0].map(function(_,i){ return { wch: i===1||i===3?28:13 }; });
  if(_dKind!=='exp') for(var r=1;r<aoa.length;r++){ ['C','D','E','G'].forEach(function(c){ var x=ws[c+(r+1)]; if(x&&x.t==='n') x.z='#,##0'; }); ['F','H'].forEach(function(c){ var x=ws[c+(r+1)]; if(x&&x.t==='n') x.z='0.0%'; }); }
  else for(var r2=1;r2<aoa.length;r2++){ var x2=ws['E'+(r2+1)]; if(x2&&x2.t==='n') x2.z='#,##0'; }
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, ymTxt(_dYm)+' '+nm);
  XLSX.writeFile(wb, '원가관리_'+_dYm+'_'+nm+'.xlsx');
}
function goExpense(){ try{ var a=parent.document.querySelector('.mi[data-key="expenseReg"]'); if(a){ a.click(); return; } }catch(e){} _alertBox('매출 관리 ▸ 비용 등록 메뉴에서 달별 비용을 넣습니다.',{icon:'ℹ️'}); }
function excel(){
  if(typeof XLSX==='undefined'||!_d){ _alertBox('엑셀로 낼 자료가 없습니다.',{icon:'⚠️'}); return; }
  var j=_d, ms=j.months||[], bd={ top:{style:'thin',color:{rgb:'B7C4D0'}}, bottom:{style:'thin',color:{rgb:'B7C4D0'}}, left:{style:'thin',color:{rgb:'B7C4D0'}}, right:{style:'thin',color:{rgb:'B7C4D0'}} };
  var sH={ font:{bold:true,sz:10}, fill:{fgColor:{rgb:'EAF2F0'}}, alignment:{horizontal:'center',vertical:'center'}, border:bd }, sT={ alignment:{vertical:'center'}, border:bd }, sN={ numFmt:'#,##0', border:bd }, sP={ numFmt:'0.0%', border:bd }, sB={ numFmt:'#,##0', font:{bold:true}, fill:{fgColor:{rgb:'EEF4F2'}}, border:bd }, sBP={ numFmt:'0.0%', font:{bold:true}, fill:{fgColor:{rgb:'EEF4F2'}}, border:bd };
  var t=function(v,s){ return { v:v==null?'':v, t:'s', s:s||sT }; }, num=function(v,s){ return { v:n(v), t:'n', s:s||sN }; }, rt=function(a,b,s){ return n(b)? { v:n(a)/n(b), t:'n', s:s||sP } : t('',s===sBP?sB:sT); };
  var a1=[ [ t('원가 관리 — 달별 원가·손익',{font:{bold:true,sz:14}}) ], [ t(ymTxt(j.fromYm)+' 부터 '+ymTxt(j.toYm)+' 까지 · 작성 '+new Date().toISOString().slice(0,10)) ], [] ];
  a1.push(['월','매출','매입원가','원가율','매출총이익','총이익률','비용','비용률','순이익','순이익률'].map(function(x){ return t(x,sH); }));
  ms.forEach(function(m){ var s=n(m.saleAmt), c=n(m.costAmt), e=n(m.expAmt), g=s-c; a1.push([ t(ymTxt(m.ym)), num(s), num(c), rt(c,s), num(g), rt(g,s), num(e), rt(e,s), num(g-e), rt(g-e,s) ]); });
  var S=n(j.saleAmt), C=n(j.costAmt), E=n(j.expAmt), G=S-C;
  a1.push([ t('합계',sB), num(S,sB), num(C,sB), rt(C,S,sBP), num(G,sB), rt(G,S,sBP), num(E,sB), rt(E,S,sBP), num(G-E,sB), rt(G-E,S,sBP) ]);
  var ws1=XLSX.utils.aoa_to_sheet(a1); ws1['!cols']=[{wch:10},{wch:15},{wch:15},{wch:9},{wch:15},{wch:9},{wch:14},{wch:9},{wch:15},{wch:9}];
  var a2=[ [ t('항목',sH) ].concat(ms.map(function(m){ return t(ymTxt(m.ym),sH); })).concat([ t('합계',sH), t('구성비',sH) ]) ];
  (j.items||[]).forEach(function(it){ a2.push([ t(it.itemNm||it.itemCd) ].concat(ms.map(function(m){ return num((m.items||{})[it.itemCd]); })).concat([ num(it.amt,sB), rt(it.amt,E) ])); });
  a2.push([ t('합계',sB) ].concat(ms.map(function(m){ return num(m.expAmt,sB); })).concat([ num(E,sB), t('100%',sB) ]));
  var ws2=XLSX.utils.aoa_to_sheet(a2); ws2['!cols']=[{wch:18}].concat(ms.map(function(){ return {wch:13}; })).concat([{wch:14},{wch:9}]);
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws1, '달별 원가손익'); XLSX.utils.book_append_sheet(wb, ws2, '비용 항목');
  XLSX.writeFile(wb, '원가관리_'+new Date().toISOString().slice(0,10).replace(/-/g,'')+'.xlsx');
}
loadAux();
window.konetShown=function(){ if(_d) load(); loadAux(); };   /* 한 번 조회한 뒤에만 다시 읽는다(비용 등록에서 고치고 돌아온 경우) */   /* 비용 등록에서 고치고 돌아오면 바로 새 값 */
</script>
</body>
</html>
