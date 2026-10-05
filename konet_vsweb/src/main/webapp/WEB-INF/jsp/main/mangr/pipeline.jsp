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
  자료 /mangr/pipelineStat.do(집계 둘) · /mangr/pipelineList.do?stage=…(단계 목록)
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amb:#b06a00; --ink:#1f2a37; --sub:#6b7a89; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:var(--ink); background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
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
  <h2>🔄 진행 현황</h2>
  <div class="sub">
    <b style="color:var(--teal)">발주</b> = 발주목록 등록 → 발주서 등록 → 매입전환 · <b style="color:var(--teal)">견적</b> = 작성 → 제출 → 채택 → 판매등록.
    단계를 누르면 아래에 그 목록이 뜨고, 줄을 누르면 그 일을 하는 화면으로 갑니다.<br>
    발주는 <b>기간 없이 지금 열린 일 전부</b>를 셉니다(밀린 일이 기간에 가려지지 않게) · 견적은 <b>견적일 기간</b>으로 셉니다.
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

function load(){
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  post('/mangr/pipelineStat.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(j){ _stat=j||{}; render(); if(_stage) list(_stage);
      var d=new Date(); document.getElementById('stamp').textContent='집계 '+ymd(d)+' '+('0'+d.getHours()).slice(-2)+':'+('0'+d.getMinutes()).slice(-2); })
    .catch(function(e){ document.getElementById('poErr').textContent='조회 오류 — '+e.message; });
}
function qtMap(){ var m={}; ((_stat&&_stat.quote)||[]).forEach(function(r){ m[r.statGb]=r; }); return m; }
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
  g+=stepHtml(QT_STEPS[2], cnt('A'), '건', cnt('A') ? (aWait ? '<span style="color:var(--amb);font-weight:700">판매 전 '+aWait+'건</span>' : '전부 판매로 이어짐') : '');
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
    +'<th style="width:110px">공급가</th><th style="width:120px">상태</th><th style="width:96px">제출</th><th style="width:96px">채택</th><th style="width:150px">판매</th></tr>';
  document.getElementById('lCnt').innerHTML='<b>'+rows.length+'</b>건'+(rows.length>=500?' (500건까지)':'');
  if(!rows.length){ document.getElementById('lBody').innerHTML='<tr><td colspan="9" class="empty">'+emptyMsg(k)+'</td></tr>'; return; }
  document.getElementById('lBody').innerHTML=rows.map(function(r){
    var g=r.statGb||'W', sold=n(r.saleCnt);
    var sale = sold ? '<span class="tag SALE" title="마지막 판매 '+d10(r.saleLastDt)+'">💰 '+sold+'건 · '+fmt(r.saleAmt)+'</span>'
                    : (g==='A' ? '<span style="color:var(--amb);font-weight:700">판매 전</span>' : '<span style="color:#b8c2cc">—</span>');
    var memo=r.statMemo ? ' title="'+esc(r.statMemo)+'"' : '';
    return '<tr class="go" onclick="openMenu(\''+(k==='A'&&!sold?'salesreg':'quoteMng')+'\')" title="'+(k==='A'&&!sold?'눌러서 판매 등록 화면으로 갑니다 — [📄 견적서]에서 이 견적을 가져오세요':'눌러서 견적서 관리 화면으로 갑니다')+'">'
      +'<td>'+d10(r.quoteDt)+'</td><td><b>'+esc(r.docNo)+'</b></td><td class="l">'+esc(r.recvNm)+'</td><td>'+esc(r.mgrNm)+'</td>'
      +'<td class="r">'+fmt(r.amt)+'</td><td><span class="tag '+g+'"'+memo+'>'+ST_NM[g]+'</span></td>'
      +'<td>'+d10(r.submitDt)+'</td><td>'+d10(r.adoptDt)+'</td><td>'+sale+'</td></tr>';
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
