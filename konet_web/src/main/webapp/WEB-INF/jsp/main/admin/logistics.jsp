<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
<style>
  :root { --logi-teal:#1f9b8e; --logi-teal-dark:#178074; --logi-border:#dfe6e3; --logi-bg:#f4f8f7; }

  /* 전체 셸: 좌측 사이드바 + 우측 콘텐츠 */
  .logi-wrap { display:flex; min-height:calc(100vh - 70px); background:#fff; }

  /* 좌측 사이드바 */
  .logi-side { width:236px; flex:0 0 236px; background:#1f2a37; color:#cdd6e0; padding:0 0 30px; }
  .logi-side .side-tit { padding:18px 20px; font-size:17px; font-weight:700; color:#fff; border-bottom:1px solid #2c3a4a; }
  .logi-side .side-tit small { display:block; font-size:11px; font-weight:400; color:#8a98a8; margin-top:3px; }
  .logi-side .grp { padding:14px 20px 6px; font-size:11px; letter-spacing:.5px; color:#7d8b9c; }
  .logi-side a.mi { display:flex; align-items:center; gap:9px; padding:9px 20px; color:#cdd6e0; text-decoration:none; font-size:13.5px; border-left:3px solid transparent; cursor:pointer; }
  .logi-side a.mi:hover { background:#28333f; color:#fff; }
  .logi-side a.mi.on { background:#28333f; color:#fff; border-left-color:var(--logi-teal); font-weight:600; }
  .logi-side a.mi .ic { width:18px; text-align:center; }
  .logi-side a.mi.core { color:#aef0e7; }

  /* 우측 콘텐츠 */
  .logi-main { flex:1; padding:22px 28px; background:var(--logi-bg); overflow:auto; }
  .logi-head { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
  .logi-head h2 { margin:0; font-size:20px; font-weight:700; color:#1f2a37; }
  .logi-head .sub { font-size:13px; color:#6b7a89; margin-top:4px; }
  .logi-head .actions { display:flex; gap:8px; }
  .btn-teal { background:var(--logi-teal); color:#fff; border:none; border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; }
  .btn-teal:hover { background:var(--logi-teal-dark); }
  .btn-line { background:#fff; color:#37475a; border:1px solid var(--logi-border); border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; }
  .btn-line:hover { background:#eef3f2; }

  /* 핵심 업무 흐름 띠 */
  .flow { display:flex; align-items:center; gap:8px; background:#fff; border:1px solid var(--logi-border); border-radius:10px; padding:12px 16px; margin-bottom:16px; font-size:13px; }
  .flow .step { display:flex; align-items:center; gap:6px; color:#37475a; }
  .flow .step b { color:var(--logi-teal-dark); }
  .flow .arr { color:#b9c5c1; font-size:16px; }

  .card { background:#fff; border:1px solid var(--logi-border); border-radius:10px; padding:18px 20px; margin-bottom:16px; }
  .card h3 { margin:0 0 12px; font-size:15px; color:#1f2a37; }

  /* 창고 3개 카드 */
  .wh-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; }
  .wh-card { border:2px solid var(--logi-border); border-radius:10px; padding:18px; text-align:center; cursor:pointer; transition:.15s; background:#fff; }
  .wh-card:hover { border-color:var(--logi-teal); box-shadow:0 4px 14px rgba(31,155,142,.15); }
  .wh-card.sel { border-color:var(--logi-teal); background:var(--logi-bg); }
  .wh-card .wh-ic { font-size:34px; }
  .wh-card .wh-nm { font-size:16px; font-weight:700; color:#1f2a37; margin:8px 0 4px; }
  .wh-card .wh-meta { font-size:12px; color:#6b7a89; }
  .wh-card .wh-rate { margin-top:8px; height:6px; border-radius:3px; background:#e7edeb; overflow:hidden; }
  .wh-card .wh-rate > i { display:block; height:100%; background:var(--logi-teal); }

  /* 세부 로케이션 맵 / 창고 상태 / 위치 안내 */
  .wh-detail { margin-top:18px; border-top:1px dashed var(--logi-border); padding-top:16px; }
  .wh-status { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
  .wh-status .chip { background:var(--logi-bg); border:1px solid var(--logi-border); border-radius:8px; padding:8px 14px; font-size:13px; color:#37475a; }
  .wh-status .chip b { color:#1f2a37; }
  .guide { display:flex; align-items:center; gap:10px; background:#eafaf6; border:1px solid #b9e6dd; color:#137a6c; border-radius:8px; padding:11px 14px; font-size:13.5px; margin-bottom:14px; }
  .guide .g-ic { font-size:18px; }
  .guide b { color:#0e6657; }
  .guide.warn { background:#fff4e0; border-color:#f0d9a8; color:#b3760f; }
  .loc-legend { display:flex; gap:16px; font-size:12px; color:#6b7a89; margin-bottom:10px; }
  .loc-legend span { display:flex; align-items:center; gap:5px; }
  .loc-legend i { width:13px; height:13px; border-radius:3px; display:inline-block; }
  .loc-map { display:grid; grid-template-columns:repeat(4,1fr); gap:9px; }
  .loc-cell { border:1px solid var(--logi-border); border-radius:8px; padding:11px 6px; text-align:center; font-size:12.5px; cursor:pointer; background:#fff; position:relative; transition:.12s; }
  .loc-cell .lc-code { font-weight:700; color:#1f2a37; }
  .loc-cell .lc-st { font-size:11px; margin-top:3px; }
  .loc-cell.st-empty { background:#eafaf3; border-color:#8fd6c2; }
  .loc-cell.st-empty .lc-st { color:var(--logi-teal-dark); }
  .loc-cell.st-use .lc-st { color:#c47f17; }
  .loc-cell.st-full { background:#f1f3f4; border-color:#e0e3e5; color:#aab2b8; cursor:not-allowed; }
  .loc-cell.st-full .lc-st { color:#b6bdc2; }
  .loc-cell:not(.st-full):hover { border-color:var(--logi-teal); }
  .loc-cell.sel { outline:2px solid var(--logi-teal); outline-offset:-1px; box-shadow:0 0 0 3px rgba(31,155,142,.15); }
  .loc-cell.rec { border-color:var(--logi-teal); }
  .loc-cell .rec-badge { position:absolute; top:-9px; right:-6px; background:var(--logi-teal); color:#fff; font-size:10px; padding:1px 7px; border-radius:9px; }

  /* 더미 테이블 */
  table.logi-tb { width:100%; border-collapse:collapse; font-size:13px; }
  table.logi-tb th, table.logi-tb td { border:1px solid var(--logi-border); padding:9px 10px; text-align:center; }
  table.logi-tb thead th { background:#eef3f2; color:#37475a; }
  table.logi-tb .loc { font-weight:700; color:var(--logi-teal); }
  table.logi-tb .txt-l { text-align:left; }

  .form-row { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:12px; }
  .form-row .fld { flex:1; min-width:150px; }
  .form-row label { display:block; font-size:12px; color:#6b7a89; margin-bottom:5px; }
  .form-row input, .form-row select { width:100%; height:36px; border:1px solid var(--logi-border); border-radius:6px; padding:0 10px; font-size:13px; box-sizing:border-box; }

  /* 요약 카드 */
  .kpi-row { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:16px; }
  .kpi { background:#fff; border:1px solid var(--logi-border); border-radius:10px; padding:16px 18px; }
  .kpi .k-lbl { font-size:12px; color:#6b7a89; }
  .kpi .k-val { font-size:24px; font-weight:800; color:#1f2a37; margin-top:6px; }
  .kpi .k-val small { font-size:13px; font-weight:600; color:#6b7a89; }

  .badge { display:inline-block; padding:2px 9px; border-radius:11px; font-size:11px; font-weight:600; }
  .b-wait { background:#fff4e0; color:#c47f17; }
  .b-done { background:#e3f4ef; color:var(--logi-teal-dark); }
  .b-ship { background:#e8effc; color:#3b6fd1; }
  .b-due  { background:#fde8e8; color:#c0392b; }
  .note { font-size:12px; color:#9aa7b3; margin-top:6px; }
  .panel { display:none; }
  .panel.show { display:block; }
</style>
<script type="text/javascript">
  // 사이드바 메뉴 → 우측 패널 전환 (시연용, 데이터/테이블은 추후)
  function logiGo(key, el){
    document.querySelectorAll('.logi-side a.mi').forEach(function(a){ a.classList.remove('on'); });
    if (el) el.classList.add('on');
    document.querySelectorAll('.logi-main .panel').forEach(function(p){ p.classList.remove('show'); });
    var t = document.getElementById('panel-'+key);
    if (t) t.classList.add('show');
    var m = document.querySelector('.logi-main'); if (m) m.scrollTop = 0;
  }
  // 창고별 세부 로케이션 더미 데이터 (s: empty=빈자리, use=사용중, full=만재)
  var WH_DATA = {
    WH1:{nm:'제1창고',type:'상온',zone:'A구역',rate:62,locs:[
      {c:'A-01-01',s:'use'}, {c:'A-01-02',s:'use'}, {c:'A-01-03',s:'empty'},{c:'A-01-04',s:'full'},
      {c:'A-02-01',s:'use'}, {c:'A-02-02',s:'use'}, {c:'A-02-03',s:'empty'},{c:'A-02-04',s:'empty'},
      {c:'B-01-01',s:'full'},{c:'B-01-02',s:'use'}, {c:'B-01-03',s:'empty'},{c:'B-01-04',s:'use'} ]},
    WH2:{nm:'제2창고',type:'냉장',zone:'B구역',rate:38,locs:[
      {c:'R-01-01',s:'empty'},{c:'R-01-02',s:'use'}, {c:'R-01-03',s:'empty'},{c:'R-01-04',s:'empty'},
      {c:'R-02-01',s:'use'}, {c:'R-02-02',s:'empty'},{c:'R-02-03',s:'empty'},{c:'R-02-04',s:'empty'},
      {c:'R-03-01',s:'use'}, {c:'R-03-02',s:'empty'},{c:'R-03-03',s:'empty'},{c:'R-03-04',s:'empty'} ]},
    WH3:{nm:'제3창고',type:'외부',zone:'C구역',rate:85,locs:[
      {c:'C-01-01',s:'full'},{c:'C-01-02',s:'full'},{c:'C-01-03',s:'use'}, {c:'C-01-04',s:'full'},
      {c:'C-02-01',s:'full'},{c:'C-02-02',s:'use'}, {c:'C-02-03',s:'full'},{c:'C-02-04',s:'empty'},
      {c:'C-03-01',s:'full'},{c:'C-03-02',s:'full'},{c:'C-03-03',s:'use'}, {c:'C-03-04',s:'full'} ]}
  };
  var ST_LBL = { empty:'빈자리', use:'사용중', full:'만재' };

  // 상품별 현재고 위치 (입고 동일위치 알림 + 발주리스트 위치 자동선별 공용)
  //  · loc 값은 위 WH_DATA 의 '사용중' 칸과 일치시킴
  var ITEM_STOCK = {
    'ITM-1001':[ {whc:'WH1',wh:'제1창고',loc:'A-02-01',qty:120}, {whc:'WH3',wh:'제3창고',loc:'C-02-02',qty:40} ],
    'ITM-1042':[ {whc:'WH2',wh:'제2창고',loc:'R-01-02',qty:50} ],
    'ITM-1108':[ {whc:'WH3',wh:'제3창고',loc:'C-01-03',qty:300} ]
  };
  var WH_ORDER = ['WH1','WH2','WH3'];

  // 창고 선택 → 세부 로케이션/상태/위치추천 렌더 (입고등록)
  function whSelect(el, code){
    document.querySelectorAll('.wh-card').forEach(function(c){ c.classList.remove('sel'); });
    el.classList.add('sel');
    renderWhDetail(code);
  }

  function renderWhDetail(code){
    var w = WH_DATA[code]; if(!w) return;
    var empties = w.locs.filter(function(l){ return l.s==='empty'; });
    var uses    = w.locs.filter(function(l){ return l.s==='use'; });
    var rec = empties.length ? empties[0] : (uses.length ? uses[0] : null);

    // ① 창고 상태 요약
    var sh = '';
    sh += '<div class="chip">유형 <b>'+w.type+' · '+w.zone+'</b></div>';
    sh += '<div class="chip">적재율 <b>'+w.rate+'%</b></div>';
    sh += '<div class="chip">빈자리 <b>'+empties.length+'</b> / 전체 '+w.locs.length+'</div>';
    document.getElementById('whStatus').innerHTML = sh;

    // ② 위치선정 안내
    var g = document.getElementById('whGuide');
    if(rec){
      g.className = 'guide';
      var lbl = (rec.s==='empty') ? '빈 자리' : '여유 있는 자리';
      g.innerHTML = '<span class="g-ic">📍</span><div>이번 입고 물품은 <b>'+w.nm+' '+rec.c+'</b> ('+lbl+') 에 적재 추천합니다.'
                  + ' <span style="color:#6b7a89">— 빈자리 우선, 적재율 낮은 위치</span></div>';
    } else {
      g.className = 'guide warn';
      g.innerHTML = '<span class="g-ic">⚠️</span><div><b>'+w.nm+'</b> 는 빈 자리가 없습니다(적재율 '+w.rate+'%). 다른 창고를 선택하세요.</div>';
    }

    // ③ 로케이션 맵
    var html='';
    w.locs.forEach(function(l){
      var cls = 'loc-cell st-'+l.s;
      var isRec = rec && (l.c===rec.c);
      if(isRec) cls += ' rec sel';
      var click = (l.s==='full') ? '' : 'onclick="pickLoc(\''+l.c+'\',this)"';
      html += '<div class="'+cls+'" data-code="'+l.c+'" '+click+'>'
            + (isRec ? '<span class="rec-badge">추천</span>' : '')
            + '<div class="lc-code">'+l.c+'</div><div class="lc-st">'+ST_LBL[l.s]+'</div></div>';
    });
    document.getElementById('locMap').innerHTML = html;

    // ④ 선택 로케이션 input (추천값 기본 입력)
    document.getElementById('locInput').value = rec ? rec.c : '';
    document.getElementById('whDetail').style.display = 'block';
  }

  // 맵에서 위치 클릭 → 선택 변경
  function pickLoc(loc, el){
    document.querySelectorAll('#locMap .loc-cell').forEach(function(c){ c.classList.remove('sel'); });
    el.classList.add('sel');
    document.getElementById('locInput').value = loc;
  }

  // [입고] 상품코드 입력 → 기존 재고 위치 있으면 동일위치 알림
  function checkExistingStock(code){
    var box = document.getElementById('inStockAlert'); if(!box) return;
    code = (code||'').trim().toUpperCase();
    var stk = ITEM_STOCK[code];
    if(code && stk && stk.length){
      var parts = stk.map(function(s){ return '<b>'+s.wh+' '+s.loc+'</b>('+s.qty+')'; }).join(', ');
      var f = stk[0];
      box.className = 'guide'; box.style.display = 'flex';
      box.innerHTML = '<span class="g-ic">🔔</span><div>이 상품은 이미 '+parts+' 에 재고가 있습니다. <b>동일 위치 적재 권장</b>'
        + ' <button class="btn-teal" style="padding:4px 11px;margin-left:8px;font-size:12px" '
        + 'onclick="selectSameLoc(\''+f.whc+'\',\''+f.loc+'\')">동일위치로 선택</button></div>';
    } else if(code){
      box.className = 'guide warn'; box.style.display = 'flex';
      box.innerHTML = '<span class="g-ic">🆕</span><div>신규 상품입니다. 빈 자리 기준으로 위치를 추천합니다.</div>';
    } else {
      box.style.display = 'none';
    }
  }

  // [입고] 동일위치로 선택 → 해당 창고 카드 선택 + 맵에서 그 위치 지정
  function selectSameLoc(whc, loc){
    var idx = WH_ORDER.indexOf(whc);
    var cards = document.querySelectorAll('#panel-inbound .wh-card');
    if(idx>=0 && cards[idx]) whSelect(cards[idx], whc);
    var cell = document.querySelector('#locMap .loc-cell[data-code="'+loc+'"]');
    if(cell){
      document.querySelectorAll('#locMap .loc-cell').forEach(function(c){ c.classList.remove('sel'); });
      cell.classList.add('sel');
    }
    document.getElementById('locInput').value = loc;
    var g = document.getElementById('whGuide');
    if(g) g.innerHTML = '<span class="g-ic">📍</span><div>기존 재고와 <b>동일 위치 '+loc+'</b> 에 합산 적재합니다.</div>';
  }

  // [발주리스트] 발주 상품을 재고와 매칭 → 창고위치 자동선별
  function autoLocateOrders(){
    var rows = document.querySelectorAll('#orderBody tr'); var matched=0;
    rows.forEach(function(r){
      var item = r.getAttribute('data-item');
      var cell = r.querySelector('.oloc');
      var stk = ITEM_STOCK[item];
      if(stk && stk.length){
        var best = stk.slice().sort(function(a,b){ return b.qty-a.qty; })[0];
        var extra = stk.length>1 ? ' <span style="color:#6b7a89;font-weight:400">(외 '+(stk.length-1)+'곳)</span>' : '';
        cell.innerHTML = best.wh+' '+best.loc+extra; cell.className='loc oloc'; matched++;
      } else {
        cell.innerHTML = '<span style="color:#c0392b">재고없음</span>'; cell.className='oloc';
      }
    });
    var n = document.getElementById('orderMatchNote');
    if(n) n.innerHTML = '✔ '+matched+'건 위치 자동선별 완료 — 재고 보유량이 많은 창고 우선 배정.';
  }

  // [발주리스트] 엑셀(CSV) 다운로드 — 위치 자동선별 후 내보내기
  function downloadOrderExcel(){
    autoLocateOrders();
    var rows = document.querySelectorAll('#orderBody tr');
    var lines = ['발주일,발주처,상품코드,상품명,수량,적재위치,상태'];
    rows.forEach(function(r){
      var cols = [];
      r.querySelectorAll('td').forEach(function(td){ cols.push('"'+td.textContent.trim().replace(/"/g,'""')+'"'); });
      lines.push(cols.join(','));
    });
    var blob = new Blob(['﻿'+lines.join('\r\n')], {type:'text/csv;charset=utf-8;'});
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a'); a.href=url; a.download='발주리스트_위치포함.csv';
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  }

  // 최초 진입(기본 선택=제1창고) 상세 렌더
  //  · AJAX 주입 시: 아래 즉시실행이 동작(요소 이미 삽입됨)
  //  · 직접 접근 시: DOMContentLoaded 로 처리
  function _logiInit(){ var t=document.getElementById('whDetail'); if(t) renderWhDetail('WH1'); }
  document.addEventListener('DOMContentLoaded', _logiInit);
  (function(){ _logiInit(); })();
</script>
</head>
<body>
<div class="logi-wrap">

  <!-- ───────────── 좌측 사이드바 ───────────── -->
  <nav class="logi-side">
    <div class="side-tit">📦 물류관리<small>도매유통 · 입고/재고/발주/출고</small></div>

    <div class="grp">기준정보</div>
    <a class="mi" data-key="client"  onclick="logiGo('client', this)"><span class="ic">🤝</span>거래처관리</a>
    <a class="mi" data-key="item"    onclick="logiGo('item', this)"><span class="ic">📦</span>상품(품목)관리</a>
    <a class="mi" data-key="base"    onclick="logiGo('base', this)"><span class="ic">🏬</span>창고/로케이션</a>

    <div class="grp">매입 · 입고</div>
    <a class="mi core on" data-key="inbound"     onclick="logiGo('inbound', this)"><span class="ic">📥</span>입고등록 (창고선정)</a>
    <a class="mi"      data-key="inboundList" onclick="logiGo('inboundList', this)"><span class="ic">📄</span>입고내역</a>

    <div class="grp">재고</div>
    <a class="mi" data-key="stock"  onclick="logiGo('stock', this)"><span class="ic">📊</span>창고별 재고현황</a>
    <a class="mi" data-key="locate" onclick="logiGo('locate', this)"><span class="ic">🔎</span>재고/위치 조회</a>

    <div class="grp">발주 · 주문</div>
    <a class="mi"      data-key="order"     onclick="logiGo('order', this)"><span class="ic">📝</span>주문(발주)등록</a>
    <a class="mi core" data-key="orderList" onclick="logiGo('orderList', this)"><span class="ic">⬇️</span>발주리스트 (엑셀)</a>

    <div class="grp">출고</div>
    <a class="mi core" data-key="outbound"     onclick="logiGo('outbound', this)"><span class="ic">📤</span>출고지시 (위치→출고)</a>
    <a class="mi"      data-key="outboundList" onclick="logiGo('outboundList', this)"><span class="ic">📄</span>출고내역 / 거래명세서</a>

    <div class="grp">매출 · 정산</div>
    <a class="mi" data-key="sales"   onclick="logiGo('sales', this)"><span class="ic">💰</span>매출현황</a>
    <a class="mi" data-key="receive" onclick="logiGo('receive', this)"><span class="ic">🧾</span>수금 / 미수금</a>
  </nav>

  <!-- ───────────── 우측 콘텐츠 ───────────── -->
  <main class="logi-main">

    <!-- 핵심 업무 흐름 띠 (모든 화면 공통 안내) -->
    <div class="flow">
      <span style="font-weight:700;color:#1f2a37;margin-right:4px;">핵심 흐름</span>
      <span class="step"><b>①</b> 입고 시 <b>3개 창고 중 위치 선정</b></span>
      <span class="arr">→</span>
      <span class="step"><b>②</b> <b>발주리스트 엑셀</b> 다운로드</span>
      <span class="arr">→</span>
      <span class="step"><b>③</b> 발주내용 <b>위치 찾아 정확히 출고</b></span>
    </div>

    <!-- ===== 기준정보 : 거래처 ===== -->
    <section id="panel-client" class="panel">
      <div class="logi-head"><div><h2>거래처관리</h2><div class="sub">매입처 · 매출처(거래처) 마스터</div></div>
        <div class="actions"><button class="btn-teal">거래처 등록</button></div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>구분</label><select><option>전체</option><option>매입처</option><option>매출처</option></select></div>
          <div class="fld"><label>거래처명/사업자번호</label><input placeholder="검색어"></div>
          <div class="fld" style="flex:0 0 100px;align-self:flex-end"><button class="btn-line" style="width:100%">조회</button></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>거래처코드</th><th>거래처명</th><th>구분</th><th>사업자번호</th><th>대표자</th><th>연락처</th><th>미수금</th></tr></thead>
          <tbody>
            <tr><td>C-001</td><td class="txt-l">OO마트</td><td>매출처</td><td>123-45-67890</td><td>김유통</td><td>02-1234-5678</td><td>1,200,000</td></tr>
            <tr><td>C-002</td><td class="txt-l">△△유통</td><td>매출처</td><td>234-56-78901</td><td>박상사</td><td>031-222-3333</td><td>0</td></tr>
            <tr><td>S-101</td><td class="txt-l">광동(매입)</td><td>매입처</td><td>345-67-89012</td><td>이매입</td><td>02-9999-0000</td><td>-</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 기준정보 : 상품 ===== -->
    <section id="panel-item" class="panel">
      <div class="logi-head"><div><h2>상품(품목)관리</h2><div class="sub">상품 마스터 · 바코드 · 단가</div></div>
        <div class="actions"><button class="btn-line">엑셀 업로드</button><button class="btn-teal">상품 등록</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>상품코드</th><th>상품명</th><th>바코드</th><th>규격/단위</th><th>매입가</th><th>판매가</th><th>현재고</th></tr></thead>
          <tbody>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>8801234500011</td><td>500ml / EA</td><td>800</td><td>1,200</td><td>160</td></tr>
            <tr><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>8801234500042</td><td>1L / BOX</td><td>5,000</td><td>7,500</td><td>50</td></tr>
            <tr><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>8801234501108</td><td>2kg / EA</td><td>3,200</td><td>4,800</td><td>320</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 기준정보 : 창고/로케이션 ===== -->
    <section id="panel-base" class="panel">
      <div class="logi-head"><div><h2>창고 / 로케이션</h2><div class="sub">창고 3개 + 로케이션(랙-단-칸) 마스터</div></div>
        <div class="actions"><button class="btn-teal">로케이션 등록</button></div></div>
      <div class="card">
        <h3>창고 (3)</h3>
        <table class="logi-tb">
          <thead><tr><th>창고코드</th><th>창고명</th><th>유형</th><th>구역</th><th>적재율</th></tr></thead>
          <tbody>
            <tr><td>WH1</td><td class="txt-l">제1창고</td><td>상온</td><td>A구역</td><td>62%</td></tr>
            <tr><td>WH2</td><td class="txt-l">제2창고</td><td>냉장</td><td>B구역</td><td>38%</td></tr>
            <tr><td>WH3</td><td class="txt-l">제3창고</td><td>외부</td><td>C구역</td><td>85%</td></tr>
          </tbody>
        </table>
        <div class="note">※ 로케이션 코드 체계: [창고]-[랙]-[단]-[칸] 예) WH1-A-02-03</div>
      </div>
    </section>

    <!-- ===== ① 입고등록 : 3개 창고 위치선정 (핵심) ===== -->
    <section id="panel-inbound" class="panel show">
      <div class="logi-head">
        <div><h2>입고등록 <span class="badge b-done">핵심</span></h2>
          <div class="sub">입고 물품을 어느 창고에 적재할지 위치를 선정합니다. (창고 3개)</div></div>
        <div class="actions"><button class="btn-line">초기화</button><button class="btn-teal">입고 확정</button></div>
      </div>
      <div class="card">
        <h3>① 매입처 / 품목 / 수량</h3>
        <div class="form-row">
          <div class="fld"><label>매입처</label><select><option>광동(매입)</option><option>제주삼다수</option></select></div>
          <div class="fld"><label>상품코드 <span style="color:#9aa7b3">(ITM-1001 입력 시 동일위치 알림)</span></label>
            <input id="inItemCode" list="itemList" placeholder="예) ITM-1001" onchange="checkExistingStock(this.value)" onkeyup="if(event.keyCode==13)checkExistingStock(this.value)">
            <datalist id="itemList"><option value="ITM-1001"><option value="ITM-1042"><option value="ITM-1108"><option value="ITM-2001"></datalist>
          </div>
          <div class="fld"><label>상품명</label><input placeholder="상품명"></div>
          <div class="fld"><label>입고수량</label><input type="number" placeholder="0"></div>
          <div class="fld"><label>입고일자</label><input type="date"></div>
        </div>
        <div class="guide" id="inStockAlert" style="display:none"></div>
      </div>
      <div class="card">
        <h3>② 적재 창고 선정 <span class="note">(클릭하여 선택)</span></h3>
        <div class="wh-grid">
          <div class="wh-card sel" onclick="whSelect(this,'WH1')">
            <div class="wh-ic">🏬</div><div class="wh-nm">제1창고</div>
            <div class="wh-meta">상온 · A구역</div>
            <div class="wh-rate"><i style="width:62%"></i></div>
            <div class="wh-meta" style="margin-top:5px">적재율 62%</div>
          </div>
          <div class="wh-card" onclick="whSelect(this,'WH2')">
            <div class="wh-ic">🏬</div><div class="wh-nm">제2창고</div>
            <div class="wh-meta">냉장 · B구역</div>
            <div class="wh-rate"><i style="width:38%"></i></div>
            <div class="wh-meta" style="margin-top:5px">적재율 38%</div>
          </div>
          <div class="wh-card" onclick="whSelect(this,'WH3')">
            <div class="wh-ic">🏬</div><div class="wh-nm">제3창고</div>
            <div class="wh-meta">외부 · C구역</div>
            <div class="wh-rate"><i style="width:85%"></i></div>
            <div class="wh-meta" style="margin-top:5px">적재율 85%</div>
          </div>
        </div>

        <!-- 선택 창고의 세부 로케이션 맵 + 상태 + 위치선정 안내 (창고 클릭 시 표시) -->
        <div class="wh-detail" id="whDetail" style="display:none">
          <div class="wh-status" id="whStatus"></div>
          <div class="guide" id="whGuide"></div>
          <div class="loc-legend">
            <span><i style="background:#eafaf3;border:1px solid #8fd6c2"></i>빈자리</span>
            <span><i style="background:#fff;border:1px solid #dfe6e3"></i>사용중(여유)</span>
            <span><i style="background:#f1f3f4;border:1px solid #e0e3e5"></i>만재</span>
          </div>
          <div class="loc-map" id="locMap"></div>
          <div class="form-row" style="margin-top:16px">
            <div class="fld"><label>선택된 세부 로케이션</label><input id="locInput" placeholder="맵에서 위치를 클릭하세요"></div>
            <div class="fld"><label>비고</label><input placeholder="메모"></div>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== 입고내역 ===== -->
    <section id="panel-inboundList" class="panel">
      <div class="logi-head"><div><h2>입고내역</h2><div class="sub">입고 처리된 내역 조회</div></div>
        <div class="actions"><button class="btn-line">엑셀</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>입고일</th><th>매입처</th><th>상품코드</th><th>상품명</th><th>수량</th><th>창고</th><th>로케이션</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>2026-06-18</td><td>광동</td><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>120</td><td>제1창고</td><td class="loc">A-02-03</td><td><span class="badge b-done">완료</span></td></tr>
            <tr><td>2026-06-18</td><td>제주삼다수</td><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>50</td><td>제2창고</td><td class="loc">B-01-05</td><td><span class="badge b-done">완료</span></td></tr>
            <tr><td>2026-06-17</td><td>롯데</td><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>300</td><td>제3창고</td><td class="loc">C-04-01</td><td><span class="badge b-done">완료</span></td></tr>
          </tbody>
        </table>
        <div class="note">※ 데모용 더미 데이터입니다. 실제 테이블/조회 로직은 추후 연동.</div>
      </div>
    </section>

    <!-- ===== 창고별 재고현황 ===== -->
    <section id="panel-stock" class="panel">
      <div class="logi-head"><div><h2>창고별 재고현황</h2><div class="sub">3개 창고의 상품별 재고 수량</div></div></div>
      <div class="kpi-row">
        <div class="kpi"><div class="k-lbl">총 재고품목</div><div class="k-val">3 <small>종</small></div></div>
        <div class="kpi"><div class="k-lbl">제1창고</div><div class="k-val">140 <small>EA</small></div></div>
        <div class="kpi"><div class="k-lbl">제2창고</div><div class="k-val">50 <small>EA</small></div></div>
        <div class="kpi"><div class="k-lbl">제3창고</div><div class="k-val">340 <small>EA</small></div></div>
      </div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>상품코드</th><th>상품명</th><th>제1창고</th><th>제2창고</th><th>제3창고</th><th>합계</th></tr></thead>
          <tbody>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>120</td><td>0</td><td>40</td><td><b>160</b></td></tr>
            <tr><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>0</td><td>50</td><td>0</td><td><b>50</b></td></tr>
            <tr><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>20</td><td>0</td><td>300</td><td><b>320</b></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 재고/위치 조회 (어디있는지 찾기) ===== -->
    <section id="panel-locate" class="panel">
      <div class="logi-head"><div><h2>재고 / 위치 조회</h2><div class="sub">상품이 어느 창고 · 어느 로케이션에 있는지 검색</div></div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>상품코드/상품명/바코드</label><input placeholder="검색어 입력 또는 바코드 스캔"></div>
          <div class="fld" style="flex:0 0 120px; align-self:flex-end"><button class="btn-teal" style="width:100%">조회</button></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>상품코드</th><th>상품명</th><th>창고</th><th>로케이션</th><th>재고수량</th></tr></thead>
          <tbody>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>제1창고</td><td class="loc">A-02-03</td><td>120</td></tr>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>제3창고</td><td class="loc">C-04-01</td><td>40</td></tr>
          </tbody>
        </table>
        <div class="note">※ 동일 상품이 여러 창고/로케이션에 분산된 경우 모두 표시 → 출고 시 위치 확인.</div>
      </div>
    </section>

    <!-- ===== 주문(발주)등록 ===== -->
    <section id="panel-order" class="panel">
      <div class="logi-head"><div><h2>주문(발주)등록</h2><div class="sub">매출처로부터 받은 주문(발주) 등록</div></div>
        <div class="actions"><button class="btn-teal">발주 추가</button></div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>매출처(발주처)</label><select><option>OO마트</option><option>△△유통</option></select></div>
          <div class="fld"><label>상품코드</label><input placeholder="ITM-"></div>
          <div class="fld"><label>발주수량</label><input type="number" placeholder="0"></div>
          <div class="fld"><label>희망납기</label><input type="date"></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>발주처</th><th>상품코드</th><th>상품명</th><th>수량</th><th>납기</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>OO마트</td><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>80</td><td>2026-06-20</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr><td>△△유통</td><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>150</td><td>2026-06-21</td><td><span class="badge b-wait">대기</span></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== ② 발주리스트 (엑셀 다운로드) ===== -->
    <section id="panel-orderList" class="panel">
      <div class="logi-head"><div><h2>발주리스트 <span class="badge b-done">핵심</span></h2>
        <div class="sub">발주 상품을 재고와 매칭해 창고위치 자동선별 → 엑셀 다운로드</div></div>
        <div class="actions">
          <button class="btn-line" onclick="autoLocateOrders()">📍 창고위치 자동선별</button>
          <button class="btn-teal" onclick="downloadOrderExcel()">⬇ 엑셀 다운로드</button>
        </div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>발주기간(시작)</label><input type="date"></div>
          <div class="fld"><label>발주기간(종료)</label><input type="date"></div>
          <div class="fld"><label>상태</label><select><option>전체</option><option>대기</option><option>출고완료</option></select></div>
          <div class="fld" style="flex:0 0 100px; align-self:flex-end"><button class="btn-line" style="width:100%">조회</button></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>발주일</th><th>발주처</th><th>상품코드</th><th>상품명</th><th>수량</th><th>적재위치 (자동선별)</th><th>상태</th></tr></thead>
          <tbody id="orderBody">
            <tr data-item="ITM-1001"><td>2026-06-18</td><td>OO마트</td><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>80</td><td class="oloc" style="color:#9aa7b3">미매칭</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr data-item="ITM-1108"><td>2026-06-18</td><td>△△유통</td><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>150</td><td class="oloc" style="color:#9aa7b3">미매칭</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr data-item="ITM-1042"><td>2026-06-18</td><td>□□상사</td><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>30</td><td class="oloc" style="color:#9aa7b3">미매칭</td><td><span class="badge b-wait">대기</span></td></tr>
          </tbody>
        </table>
        <div class="note" id="orderMatchNote">※ "창고위치 자동선별" 을 누르면 발주 상품의 현재고 위치를 찾아 적재위치를 채웁니다. (엑셀 다운로드 시 자동 매칭 후 위치 포함)</div>
      </div>
    </section>

    <!-- ===== ③ 출고지시 (발주내용 → 위치 찾아 출고) ===== -->
    <section id="panel-outbound" class="panel">
      <div class="logi-head"><div><h2>출고지시 <span class="badge b-done">핵심</span></h2>
        <div class="sub">발주건을 선택하면 적재위치를 찾아 정확히 출고를 처리합니다.</div></div>
        <div class="actions"><button class="btn-teal">출고 확정</button></div></div>
      <div class="card">
        <h3>출고 대상 발주</h3>
        <table class="logi-tb">
          <thead><tr><th>선택</th><th>발주처</th><th>상품</th><th>수량</th><th>찾을 위치 (피킹)</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td><input type="checkbox"></td><td>OO마트</td><td class="txt-l">샘플 품목 A</td><td>80</td><td class="loc">제1창고 A-02-03</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr><td><input type="checkbox"></td><td>△△유통</td><td class="txt-l">샘플 품목 C</td><td>150</td><td class="loc">제3창고 C-04-01</td><td><span class="badge b-ship">피킹중</span></td></tr>
          </tbody>
        </table>
        <div class="note">※ "찾을 위치" 를 보고 창고에서 정확히 피킹 → 출고 확정 → 재고 차감 + 거래명세서 발행.</div>
      </div>
    </section>

    <!-- ===== 출고내역 / 거래명세서 ===== -->
    <section id="panel-outboundList" class="panel">
      <div class="logi-head"><div><h2>출고내역 / 거래명세서</h2><div class="sub">출고 완료 내역 및 거래명세서</div></div>
        <div class="actions"><button class="btn-line">거래명세서 출력</button><button class="btn-line">엑셀</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>출고일</th><th>발주처</th><th>상품</th><th>수량</th><th>출고위치</th><th>금액</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>2026-06-17</td><td>□□상사</td><td class="txt-l">샘플 품목 B</td><td>30</td><td class="loc">제2창고 B-01-05</td><td>225,000</td><td><span class="badge b-done">출고완료</span></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 매출현황 ===== -->
    <section id="panel-sales" class="panel">
      <div class="logi-head"><div><h2>매출현황</h2><div class="sub">기간별 · 거래처별 매출 집계</div></div>
        <div class="actions"><button class="btn-line">엑셀</button></div></div>
      <div class="kpi-row">
        <div class="kpi"><div class="k-lbl">당월 매출</div><div class="k-val">12,450,000 <small>원</small></div></div>
        <div class="kpi"><div class="k-lbl">출고 건수</div><div class="k-val">38 <small>건</small></div></div>
        <div class="kpi"><div class="k-lbl">미수금</div><div class="k-val" style="color:#c0392b">1,200,000 <small>원</small></div></div>
        <div class="kpi"><div class="k-lbl">거래처</div><div class="k-val">12 <small>곳</small></div></div>
      </div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>거래처</th><th>출고건수</th><th>매출액</th><th>수금액</th><th>미수금</th></tr></thead>
          <tbody>
            <tr><td class="txt-l">OO마트</td><td>15</td><td>5,200,000</td><td>4,000,000</td><td>1,200,000</td></tr>
            <tr><td class="txt-l">△△유통</td><td>23</td><td>7,250,000</td><td>7,250,000</td><td>0</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 수금 / 미수금 ===== -->
    <section id="panel-receive" class="panel">
      <div class="logi-head"><div><h2>수금 / 미수금</h2><div class="sub">거래처별 미수금 및 수금 처리</div></div>
        <div class="actions"><button class="btn-teal">수금 등록</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>거래처</th><th>전월이월</th><th>당월매출</th><th>당월수금</th><th>미수잔액</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td class="txt-l">OO마트</td><td>0</td><td>5,200,000</td><td>4,000,000</td><td>1,200,000</td><td><span class="badge b-due">미수</span></td></tr>
            <tr><td class="txt-l">△△유통</td><td>0</td><td>7,250,000</td><td>7,250,000</td><td>0</td><td><span class="badge b-done">완납</span></td></tr>
          </tbody>
        </table>
        <div class="note">※ 전자세금계산서 · 카드결제 연동은 추후 단계.</div>
      </div>
    </section>

  </main>
</div>
</body>
</html>
