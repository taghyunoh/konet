<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 재고·상품 조회 — /m/stock.do (MobileController, 로그인 필수). 2026-09-11 신설. 조회 전용.
     · 목록 = /prod/stockAdjList.do (재고 일괄조정 화면과 같은 조회 — 규격·입수·BOX·EA 가 함께 온다).
       ★검색어가 있어야 부른다 — 빈 검색은 전 품목 원장 집계라 느리다(CLAUDE.md 「현재고 계산 때문에 조회가 느려지는」).
     · 판매가·매입가·과세·거래중지 = /prod/prodList.do (한 번만 읽어 코드로 붙인다).
     · ★서브코드(매칭코드)로 쳐도 주코드로 찾는다 — 재고는 주코드로만 쌓인다(월별 출고현황 somQuery 와 같은 규칙).
       /prod/extItemList.do 로 «매칭코드 → 주코드» 표를 처음 한 번 읽는다.
     · 상품을 누르면 최근 입출고 = /prod/stockList.do (prodSeq, 최근 순 — 화면에서 30줄만). --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 재고·상품</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/m/m.css?v=20260913a">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<script src="<%=request.getContextPath()%>/m/m.js?v=20260911d"></script>
<style>
  .sbar{ display:flex; gap:6px; max-width:560px; margin:10px auto 0; }
  .sbar input{ flex:1; height:42px; border:0; border-radius:10px; padding:0 12px; font-size:17.5px; min-width:0; color:var(--ink); }
  .sbar button{ height:42px; padding:0 16px; border:0; border-radius:10px; background:rgba(255,255,255,.18); color:#fff; font-size:16.5px; font-weight:700; }
  .opts{ display:flex; align-items:center; gap:14px; max-width:560px; margin:8px auto 0; font-size:16px; }
  .opts label{ display:flex; align-items:center; gap:6px; }
  .opts input{ width:17px; height:17px; accent-color:#fff; }
  .opts select{ height:32px; border:0; border-radius:8px; padding:0 8px; font-size:16px; }
  @media (min-width:768px){   /* 태블릿 — 검색줄을 제목 왼쪽 끝에 맞춘다(m.css 의 .datebar 와 같은 규칙) */
    .sbar,.opts{ margin-left:max(0px, calc((100% - var(--wmax)) / 2)); margin-right:auto; }
  }
  .pq{ font-size:15px; color:var(--mute); font-weight:500; }
  .neg{ color:var(--red) !important; }
  .dt{ display:grid; grid-template-columns:auto 1fr; gap:6px 12px; font-size:17px; }
  .dt dt{ color:var(--mute); font-weight:600; font-size:16px; }
  .dt dd{ margin:0; text-align:right; font-weight:700; font-variant-numeric:tabular-nums; word-break:break-all; }
  .io{ font-size:14.5px; font-weight:800; padding:1px 6px; border-radius:6px; margin-right:4px; }
  .io.I{ background:#e3f2ee; color:#0f6b5e; } .io.O{ background:#fdecec; color:var(--red); }
  .io.R{ background:#fff4e0; color:var(--amber); } .io.A{ background:#e8eefc; color:var(--blue); }
  .sub-hint{ font-size:15.5px; color:var(--teal-d); background:var(--teal-l); border-radius:8px; padding:7px 10px; margin-bottom:8px; }
</style>
</head>
<body>
<header>
  <div class="hd1">
    <h1>재고·상품</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="M.logout()">로그아웃</button>
  </div>
  <form class="sbar" onsubmit="search(); return false;">
    <input type="search" id="q" placeholder="상품코드 · 품명 · 규격" autocomplete="off" enterkeyhint="search">
    <button type="submit">조회</button>
  </form>
  <div class="opts">
    <label><input type="checkbox" id="zeroExc" onchange="if(_lastQ) search()">재고 있는 것만</label>
    <select id="sortGb" onchange="if(_lastQ) search()" aria-label="정렬">
      <option value="CD">코드순</option><option value="NM">이름순</option><option value="QTY">재고 많은 순</option>
    </select>
  </div>
</header>

<main>
  <section class="card"><h2>상품 <small id="cnt"></small></h2><div id="body"><div class="empty">상품코드나 품명을 넣고 [조회] 하세요.<br><span style="font-size:15px">서브코드(매칭코드)로 쳐도 주코드로 찾아 줍니다.</span></div></div></section>
</main>

<script>
var $=M.$, n=M.n, esc=M.esc;
var _prodBy={}, _alias=null, _list=[], _lastQ='';

function loadProds(){
  return M.form('/prod/prodList.do',{ findData:'' }).then(function(res){
    (res.data||[]).forEach(function(p){ var k=String(p.prodCd||''); if(!k) return;
      if(!_prodBy[k] || n(p.prodSeq)>n(_prodBy[k].prodSeq)) _prodBy[k]=p; });
  }).catch(function(){});
}
/* 매칭코드 → 주코드 (처음 한 번). 실패하면 굳히지 않는다 — 다음 조회에서 다시 */
function loadAlias(){
  if(_alias) return Promise.resolve(_alias);
  return M.form('/prod/extItemList.do',{}).then(function(res){
    var m={};
    (res.data||[]).forEach(function(o){ if(o.prodCd && o.extItemCd && String(o.extItemCd)!==String(o.prodCd)) m[M.norm(o.extItemCd)]={ main:String(o.prodCd), nm:o.extItemNm||'' }; });
    _alias=m; return m;
  }).catch(function(){ return {}; });
}

function search(){
  var q=$('q').value.trim(); $('q').blur();
  if(!q){ _alertBox('상품코드나 품명을 넣으세요.<br><span style="font-size:14.5px">전체 조회는 느려서 막아 두었습니다.</span>',{icon:'🔎'}); return; }
  _lastQ=q;
  var el=$('body'); el.innerHTML='<div class="loading">찾는 중…</div>'; $('cnt').textContent='';
  loadAlias().then(function(al){
    var hit=al[M.norm(q)], fq=hit ? hit.main : q;
    return M.form('/prod/stockAdjList.do',{ findData:fq, asOfDt:'', zeroExcYn:$('zeroExc').checked?'Y':'', sortGb:$('sortGb').value })
      .then(function(res){ return { rows:res.data||[], hit:hit }; });
  }).then(function(r){
    if(q!==_lastQ) return;
    _list=r.rows;
    $('cnt').textContent=_list.length?_list.length.toLocaleString()+'품목':'';
    var h=r.hit ? '<div class="sub-hint">🔖 <b>'+esc(q)+'</b> 는 서브코드입니다 → 주코드 <b>'+esc(r.hit.main)+'</b> 로 찾았습니다.</div>' : '';
    if(!_list.length){ el.innerHTML=h+'<div class="empty">「'+esc(q)+'」 상품이 없습니다.</div>'; return; }
    var shown=_list.slice(0,200);
    el.innerHTML=h+'<div class="list cols2" style="margin-top:0">'+shown.map(function(o,i){
      var p=_prodBy[String(o.prodCd)]||{}, neg=n(o.curQty)<0, stop=p.stopYn==='Y';
      return '<div class="row tap" onclick="detail('+i+')"><div class="k">'+esc(o.prodNm)
        +(stop?' <span class="badge gray" style="font-size:13.5px;padding:1px 6px">중지</span>':'')
        +'<small>'+esc(o.prodCd)+(o.spec?' · '+esc(o.spec):'')+' · <b style="color:#0e6657">입수 '+n(o.packQty)+'</b></small></div>'
        +'<div class="v'+(neg?' neg':'')+'">'+M.fmtQ(o.curQty)+'<small>'+boxEa(o)+'</small></div></div>';
    }).join('')+'</div>'+(_list.length>200?'<p class="note">앞 200품목만 보입니다(전체 '+_list.length.toLocaleString()+'). 검색어를 더 좁혀 주세요.</p>':'');
  }).catch(function(e){ el.innerHTML='<div class="err">조회하지 못했습니다. '+esc(M.errMsg(e))+'<button type="button" onclick="search()">다시</button></div>'; });
}
function boxEa(o){ var b=n(o.boxQty), e=n(o.eaQty); if(!b && !e) return '재고 없음'; return (b?M.fmt0(b)+'BOX':'')+(b&&e?' ':'')+(e?M.fmt0(e)+'EA':''); }

/* 상품 상세 + 최근 입출고 — 아래에서 올라오는 창에 그린다(검색칸 없이) */
var IO_NM={ I:'입고', O:'출고', R:'반품', A:'조정' }, REF_NM={ PURCH:'매입', SALE:'판매', SHIPOUT:'발주출고' };
function detail(i){
  var o=_list[i]; if(!o) return;
  var p=_prodBy[String(o.prodCd)]||{};
  var head='<div style="padding:4px 0 10px"><div style="font-size:17.5px;font-weight:800;line-height:1.35">'+esc(o.prodNm)+'</div>'
    +'<div class="pq">'+esc(o.prodCd)+(o.spec?' · '+esc(o.spec):'')+'</div></div>'
    +'<div class="tiles"><div class="tile"><span>현재고</span><b class="'+(n(o.curQty)<0?'red':'teal')+'">'+M.fmtQ(o.curQty)+'</b><em>'+boxEa(o)+'</em></div>'
    +'<div class="tile"><span>입수</span><b>'+n(o.packQty)+'</b><em>입고 '+M.fmtQ(o.inQty)+' · 출고 '+M.fmtQ(o.outQty)+'</em></div></div>'
    +'<dl class="dt" style="margin:12px 0 0">'
    +'<dt>판매가</dt><dd>'+M.fmtP(p.salePrice)+'</dd><dt>매입가</dt><dd>'+M.fmtP(p.inPrice)+'</dd>'
    +'<dt>과세</dt><dd>'+esc(p.taxGb||'—')+'</dd>'
    +(p.vendorNm?'<dt>매입처</dt><dd>'+esc(p.vendorNm)+'</dd>':'')
    +(o.makerNm?'<dt>제조사</dt><dd>'+esc(o.makerNm)+'</dd>':'')
    +(o.typeNm?'<dt>유형</dt><dd>'+esc(o.typeNm)+'</dd>':'')
    +(p.stopYn==='Y'?'<dt>거래중지</dt><dd class="red">'+esc(M.d10(p.stopFrDt)||'예')+'</dd>':'')
    +'</dl><h3 class="h3" style="margin-top:14px">최근 입출고</h3><div id="ioBox" class="loading">불러오는 중…</div>';
  M.sheetHtml('상품 상세', head);
  M.form('/prod/stockList.do',{ prodSeq:o.prodSeq }).then(function(res){
    var rows=(res.data||[]).slice(0,30), box=document.getElementById('ioBox'); if(!box) return;
    box.className='';
    if(!rows.length){ box.innerHTML='<div class="empty">입출고 기록이 없습니다.</div>'; return; }
    box.innerHTML='<div class="list" style="margin-top:6px">'+rows.map(function(r){
      var g=r.ioGb||'', sign=g==='O'?'−':'+';
      return '<div class="row"><div class="k"><span class="io '+esc(g)+'">'+(IO_NM[g]||esc(g))+'</span>'+esc(M.d10(r.trxDt))
        +'<small>'+esc(REF_NM[r.refGb]||(r.refGb?r.refGb:'수기'))+(r.vendorNm?' · '+esc(r.vendorNm):'')+(r.remark?' · '+esc(r.remark):'')+'</small></div>'
        +'<div class="v'+(g==='O'?' neg':'')+'">'+sign+M.fmtQ(Math.abs(n(r.qty)))+'</div></div>';
    }).join('')+'</div>'+((res.data||[]).length>30?'<p class="note">최근 30건만 보입니다.</p>':'');
  }).catch(function(e){ var box=document.getElementById('ioBox'); if(box) box.innerHTML='<div class="err">불러오지 못했습니다. '+esc(M.errMsg(e))+'</div>'; });
}

/* ---------- 시작 ---------- */
M.tabbar('stock');
M.session().then(function(){ loadProds(); }).catch(function(){});
</script>
</body>
</html>
