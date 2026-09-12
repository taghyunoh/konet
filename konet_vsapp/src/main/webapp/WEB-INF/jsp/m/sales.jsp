<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 판매등록 — /m/sales.do (MobileController, 로그인 필수). 2026-09-11 신설.
     ★저장은 PC 판매등록과 **같은 엔드포인트·같은 모양**(/mangr/salesTrxSave.do, JSON) — 재고 원장·단가 이력이 PC 와 똑같이 남는다.
     ★계산은 PC saCalcRow / saCalc 를 그대로 옮겼다 — PC 쪽 규칙이 바뀌면 여기도 같이 :
       · 합계수량 = BOX × 입수 + EA (입수 0·빈값이면 1)
       · 금액 = 합계 × 단가 − 줄할인 · 부가세 = 거래처 VAT_GB(별도·포함·면세) × 품목 과세여부
       · 반품 = 수량·금액은 양수, trxGb='반품' 으로만 표시(합계에서 −) — 음수로 저장하면 부호가 두 번 뒤집힌다
       · 거래후잔고 = 현잔고 − (이 전표가 이미 반영한 금액) + (합계 − 입금 − 할인)
     ★새 전표는 saleNo 를 비워 보낸다 — 서버가 번호를 매긴다(두 사람이 같은 번호를 받을 틈을 줄인다).
     ★저장된 전표를 고칠 때는 판매일자를 잠근다 — 서버가 옛 재고 원장을 «새 일자+번호»로 지우므로 일자를 바꾸면 옛 행이 남는다. --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 판매등록</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/m/m.css?v=20260912a">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<script src="<%=request.getContextPath()%>/m/m.js?v=20260911d"></script>
<style>
  .it{ border:1px solid #e3ebe8; border-radius:12px; padding:10px 11px; margin-bottom:8px; background:#fbfdfc; }
  .it.ret{ background:#fff7f7; border-color:#f0d3d3; }
  .it .t1{ display:flex; align-items:flex-start; gap:8px; }
  .it .nm{ flex:1; min-width:0; font-size:18px; font-weight:700; line-height:1.3; word-break:break-all; }
  .it .nm small{ display:block; font-size:15px; font-weight:500; color:var(--mute); margin-top:2px; }
  .it .del{ border:0; background:#f1f3f5; color:#666; border-radius:8px; width:32px; height:32px; font-size:15.5px; flex:none; }
  .it .g{ display:grid; grid-template-columns:1fr .8fr 1fr 1.3fr; gap:6px; margin-top:8px; }
  .it .g label{ display:block; font-size:14.5px; font-weight:700; color:var(--mute); margin-bottom:3px; }
  .it .g .inp{ height:42px; padding:0 10px; }
  /* 입수 = 상품마스터 값(PC 판매등록과 같이 읽기 전용) — 합계 = BOX × 입수 + EA */
  .it .g .pk{ height:42px; display:flex; align-items:center; justify-content:center; border-radius:10px;
    background:var(--teal-l); color:var(--teal-d); font-size:17.5px; font-weight:800; font-variant-numeric:tabular-nums; }
  .it .fx{ font-size:15px; color:var(--mute); font-variant-numeric:tabular-nums; }
  .it .t3{ display:flex; align-items:center; gap:8px; margin-top:8px; font-size:16px; color:var(--mute); }
  .it .t3 .amt{ margin-left:auto; font-size:17.5px; font-weight:800; color:var(--ink); font-variant-numeric:tabular-nums; }
  .it.ret .t3 .amt{ color:var(--red); }
  .gb{ display:inline-flex; border:1px solid var(--bd); border-radius:8px; overflow:hidden; }
  .gb button{ border:0; background:#fff; height:30px; padding:0 11px; font-size:14.5px; font-weight:700; color:var(--mute); }
  .gb button.on{ background:var(--teal-l); color:var(--teal-d); }
  .gb button.on.r{ background:#fdecec; color:var(--red); }
  .vat{ font-size:14.5px; font-weight:700; padding:2px 7px; border-radius:10px; background:#eef1f3; color:#546e7a; white-space:nowrap; }
  .sumtb{ width:100%; border-collapse:collapse; font-size:17px; }
  .sumtb td{ padding:6px 2px; border-bottom:1px solid #edf2f0; }
  .sumtb td:last-child{ text-align:right; font-weight:700; font-variant-numeric:tabular-nums; }
  .sumtb tr.big td{ font-size:17.5px; font-weight:800; }
  .state{ font-size:15.5px; font-weight:700; color:var(--amber); margin:0 0 10px; display:flex; align-items:center; gap:8px; }
  .state.new{ color:var(--teal-d); }
  .filt{ display:grid; grid-template-columns:1fr 1fr; gap:6px; }
  .filt .full{ grid-column:1 / -1; }
  @media (min-width:768px){
    .filt{ grid-template-columns:180px 180px minmax(0,1fr) 120px; }
    .filt .full{ grid-column:auto; }
    /* 품목 카드 : 태블릿 오른쪽 단은 넓어서 입력칸이 늘어지지 않게 */
    .it .g{ grid-template-columns:1fr .7fr 1fr 1.3fr; }
  }
</style>
</head>
<body>
<header>
  <div class="hd1">
    <h1>판매등록</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="M.logout()">로그아웃</button>
  </div>
  <div class="seg" role="tablist">
    <button type="button" id="tabEdit" class="on" onclick="showTab('edit')">전표 입력</button>
    <button type="button" id="tabList" onclick="showTab('list')">전표 목록</button>
  </div>
</header>

<%-- 폰 = 전표 → 품목 → 결제 → 합계 한 줄 / 태블릿 = 왼쪽(전표·결제·합계) | 오른쪽(품목) — m.css .cols --%>
<main id="pEdit" class="has-savebar cols">
 <div class="colL">
  <section class="card o1">
    <p class="state new" id="state">새 전표</p>
    <div class="frm">
      <label for="saleDt">판매일자</label>
      <input class="inp" type="date" id="saleDt">
      <label>거래처</label>
      <button type="button" class="pick" id="venBtn" onclick="pickVen()"><span class="ph">거래처를 고르세요</span></button>
    </div>
    <div class="tiles" id="balBox" style="margin-top:10px" hidden>
      <div class="tile"><span>현잔고 (받을금액)</span><b id="balNow">—</b></div>
      <div class="tile"><span>거래후잔고</span><b id="balAfter" class="teal">—</b></div>
    </div>
  </section>

  <section class="card o3">
    <h2>결제 · 메모</h2>
    <div class="frm">
      <label for="payGb">결제구분</label>
      <select class="inp" id="payGb"><option>외상</option><option>현금</option><option>카드</option><option>계좌이체</option></select>
      <label for="payAmt">입금액</label>
      <div class="inrow"><input class="inp num" id="payAmt" inputmode="numeric" autocomplete="off" placeholder="0"><button type="button" class="btn sm ghost" onclick="payFill()">전액</button></div>
      <label for="dcAmt">할인</label>
      <div class="inrow"><input class="inp num" id="dcAmt" inputmode="numeric" autocomplete="off" placeholder="0"><button type="button" class="btn sm ghost" onclick="dcFill()" title="합계 − 입금액을 할인으로">털기</button></div>
      <label for="remark">비고</label>
      <textarea class="inp" id="remark" rows="2" maxlength="500"></textarea>
    </div>
  </section>

  <section class="card o4">
    <h2>합계</h2>
    <table class="sumtb">
      <tr><td>합계수량</td><td id="tQty">—</td></tr>
      <tr><td>공급가액</td><td id="tSup">—</td></tr>
      <tr><td>부가세</td><td id="tVat">—</td></tr>
      <tr class="big"><td>합계금액</td><td id="tTot">0</td></tr>
    </table>
    <div class="btnrow" id="editBtns" hidden>
      <button type="button" class="btn ghost" onclick="newSlip(true)">＋ 새 전표</button>
      <button type="button" class="btn danger" onclick="delSlip()">✖ 삭제</button>
    </div>
  </section>
 </div>
 <div class="colR">
  <section class="card o2">
    <h2>품목 <small id="itCnt"></small><span class="rt"><button type="button" class="btn sm fill" onclick="pickProd()">＋ 품목 추가</button></span></h2>
    <div id="items"></div>
  </section>
 </div>
</main>

<main id="pList" hidden>
  <section class="card">
    <div class="filt">
      <input class="inp" type="date" id="fFrom">
      <input class="inp" type="date" id="fTo">
      <input class="inp full" type="search" id="fNm" placeholder="거래처명으로 거르기" onkeydown="if(event.key==='Enter'){ this.blur(); loadList(); }">
      <button type="button" class="btn full" onclick="loadList()">조회</button>
    </div>
  </section>
  <section class="card"><h2>전표 <small id="lCnt"></small></h2><div id="lBody" class="loading">불러오는 중…</div></section>
</main>

<div class="savebar" id="saveBar">
  <div class="in">
    <div class="sum">합계금액<b id="sbTot">0</b><span id="sbSub"></span></div>
    <button type="button" class="btn fill" id="saveBtn" onclick="saveSlip()">저장</button>
  </div>
</div>

<script>
var $=M.$, n=M.n, esc=M.esc;
var _prods=[], _prodBy={}, _xref={}, _ven=null, _venVat='별도', _rows=[], _cur=null, _curNet=0, _balNow=0, _balSt='', _busy=false;

/* ---------- 탭 ---------- */
function showTab(t){
  $('pEdit').hidden = t!=='edit'; $('pList').hidden = t!=='list'; $('saveBar').hidden = t!=='edit';
  $('tabEdit').classList.toggle('on', t==='edit'); $('tabList').classList.toggle('on', t==='list');
  if(t==='list' && !_listLoaded) loadList();
  window.scrollTo(0,0);
}

/* ---------- 상품 마스터 (PC 와 같은 /prod/prodList.do — 한 번만 읽는다) ---------- */
function loadProds(){
  return M.form('/prod/prodList.do',{ findData:'' }).then(function(res){
    var seen={};
    _prods=[]; _prodBy={};
    (res.data||[]).forEach(function(p){        // 이력형이라 같은 코드가 여러 줄 올 수 있다 — 큰 PROD_SEQ 하나만
      var k=String(p.prodCd||''); if(!k) return;
      if(seen[k]!=null){ if(n(p.prodSeq)>n(_prods[seen[k]].prodSeq)) _prods[seen[k]]=p; return; }
      seen[k]=_prods.length; _prods.push(p);
    });
    _prods.forEach(function(p){ _prodBy[String(p.prodCd)]=p; });
  });
}
/* 거래처가 부르는 품명(TBL_PROD_XREF) — PC saNmFor 와 같다. 표기가 없으면 우리 품명. */
function nmFor(prodCd){ var p=_prodBy[prodCd]; return _xref[prodCd] || (p ? p.prodNm : ''); }
function loadXref(cd){
  _xref={};
  if(!cd) return Promise.resolve();
  return M.form('/prod/xrefNames.do',{ vendorCd:cd }).then(function(res){
    (res.data||[]).forEach(function(x){ if(x.prodCd && x.extItemNm) _xref[String(x.prodCd)]=x.extItemNm; });
  }).catch(function(){});
}

/* ---------- 거래처 ---------- */
function pickVen(){
  M.pickVendor({ gb:'매출', title:'판매 거래처' }, function(v){ setVen(v, true); });
}
function setVen(v, fresh){
  _ven=v; _venVat=(v && v.vatGb) || '별도';
  $('venBtn').innerHTML = v ? '<b>'+esc(v.vendorNm)+'</b><span class="vat">부가세 '+esc(_venVat)+'</span>' : '<span class="ph">거래처를 고르세요</span>';
  $('balBox').hidden = !v;
  if(!v) return;
  _rows.forEach(calcRow);                           // 거래처가 바뀌면 부가세가 달라진다(PC saVenVat)
  loadXref(v.vendorCd).then(function(){
    if(fresh && !_cur) _rows.forEach(function(o){ o.prodNm=nmFor(o.prodCd); });   // 새 전표만 — 저장된 품명은 그 전표의 사실
    render();
  });
  _balNow=0; _balSt='load'; $('balNow').textContent='…'; $('balAfter').textContent='…';
  M.balance(v.vendorCd).then(function(b){ if(_ven!==v) return; _balNow=b.recv; _balSt='ok'; calc(); })
    .catch(function(){ if(_ven!==v) return; _balSt='err'; $('balNow').textContent='?'; $('balAfter').textContent='?'; });
  render();
}

/* ---------- 품목 ---------- */
function prodScore(p, toks, q){
  var cd=M.norm(p.prodCd);
  if(cd===q) return 0;
  if(cd.indexOf(q)===0) return 1;
  var hay=M.norm(p.prodNm)+'|'+M.norm(p.spec)+'|'+cd+'|'+M.norm(_xref[p.prodCd]);
  for(var i=0;i<toks.length;i++){ if(hay.indexOf(toks[i])<0) return -1; }
  return M.norm(p.prodNm).indexOf(toks[0])===0 ? 2 : 3;
}
function pickProd(){
  if(!_prods.length){ _toast('상품 목록을 불러오는 중입니다…','info'); return; }
  M.sheet({
    title:'품목 추가', placeholder:'상품코드 · 품명 · 규격 (띄어쓰기로 여러 낱말)',
    list:function(q){
      var qn=M.norm(q), toks=q.toLowerCase().split(/\s+/).filter(Boolean).map(M.norm);
      if(!qn) return [];
      var out=[];
      _prods.forEach(function(p){ var s=prodScore(p,toks,qn); if(s>=0) out.push({s:s,p:p}); });
      out.sort(function(a,b){ return a.s-b.s || String(a.p.prodCd).localeCompare(String(b.p.prodCd)); });
      return out.slice(0,60).map(function(o){ var p=o.p, stop=p.stopYn==='Y';
        return { v:p, dis:stop, html:'<div class="k">'+esc(nmFor(p.prodCd))+'<small>'+esc(p.prodCd)+(p.spec?' · '+esc(p.spec):'')
          +' · <b style="color:#0e6657">입수 '+(n(p.packQty)||1)+'</b>'+(stop?' · <b style="color:#546e7a">거래중지</b>':'')+'</small></div>'
          +'<div class="v">'+M.fmtP(p.salePrice)+'<small>판매가</small></div>' };
      });
    },
    emptyMsg:function(q){ return q ? '「'+esc(q)+'」 상품이 없습니다.' : '상품코드나 품명을 입력하세요.'; },
    onPick:addProd
  });
}
function addProd(p){
  var o={ prodSeq:p.prodSeq, prodCd:p.prodCd, prodNm:nmFor(p.prodCd), spec:p.spec||'', packQty:n(p.packQty)||1,
          boxQty:1, eaQty:0, qty:0, unitPrice:n(p.salePrice), amt:0, dcAmt:0, supplyAmt:0, vatAmt:0, totAmt:0,
          serviceQty:0, remark:'', eventYn:'N', trxGb:'판매', taxGb:(p.taxGb==='면세'?'면세':'과세'), extCd:null };
  calcRow(o); _rows.push(o); render();
  var idx=_rows.length-1;
  setTimeout(function(){ var el=document.querySelector('#items [data-i="'+idx+'"] input[data-f="boxQty"]'); if(el){ el.scrollIntoView({block:'center'}); el.focus(); } }, 60);
  /* 그 거래처 최근 판매단가 — PC saProdPick 과 같다(vendorCd 는 remark 칸으로 보낸다) */
  if(_ven){
    M.form('/mangr/salesLastPrice.do',{ prodCd:p.prodCd, remark:_ven.vendorCd }).then(function(res){
      if(res && res.data!=null && _rows[idx]===o && !o._pe){ o.unitPrice=n(res.data); calcRow(o); render(true); }
    }).catch(function(){});
  }
}

/* PC saCalcRow 그대로 */
function calcRow(o){
  o.boxQty=Math.abs(n(o.boxQty)); o.eaQty=Math.abs(n(o.eaQty));
  o.qty=n(o.boxQty)*(n(o.packQty)||1)+n(o.eaQty);
  o.amt=Math.round(o.qty*n(o.unitPrice))-n(o.dcAmt);
  var vg=_venVat||'별도', tax=(o.taxGb!=='면세')&&(vg!=='면세');
  if(!tax){ o.supplyAmt=o.amt; o.vatAmt=0; }
  else if(vg==='포함'){ o.supplyAmt=Math.round(o.amt/1.1); o.vatAmt=o.amt-o.supplyAmt; }
  else { o.supplyAmt=o.amt; o.vatAmt=Math.round(o.amt*0.1); }
  o.totAmt=o.supplyAmt+o.vatAmt;
}
/* PC saCalc 그대로 (반품 줄은 −) */
function calc(){
  var t={box:0,ea:0,qty:0,sup:0,vat:0,tot:0};
  _rows.forEach(function(o){
    var s=(o.trxGb==='반품')?-1:1;
    t.box+=n(o.boxQty)*s; t.ea+=n(o.eaQty)*s; t.qty+=n(o.qty)*s; t.sup+=n(o.supplyAmt)*s; t.vat+=n(o.vatAmt)*s; t.tot+=n(o.totAmt)*s;
  });
  $('tQty').textContent=M.fmtQ(t.qty); $('tSup').textContent=M.fmt(t.sup); $('tVat').textContent=M.fmt(t.vat);
  $('tTot').textContent=M.fmt0(t.tot); $('sbTot').textContent=M.fmt0(t.tot);
  $('sbSub').textContent=_rows.length ? '품목 '+_rows.length+' · 수량 '+M.fmtQ(t.qty) : '품목을 추가하세요';
  var net=t.tot-n($('payAmt').value)-n($('dcAmt').value);
  if(_ven && _balSt==='ok'){ $('balNow').textContent=M.fmt0(_balNow); var af=_balNow-_curNet+net; $('balAfter').textContent=M.fmt0(af); $('balAfter').className=af<0?'red':'teal'; }
  $('saveBtn').disabled = _busy || !_ven || !_rows.length;
  return t;
}
function render(keepFocus){
  var box=$('items');
  if(keepFocus){   // 단가만 바뀐 경우 — 입력 중인 칸을 다시 그리지 않고 금액만 고친다
    _rows.forEach(function(o,i){ var el=box.querySelector('[data-i="'+i+'"]'); if(!el) return;
      var pr=el.querySelector('input[data-f="unitPrice"]'); if(pr && document.activeElement!==pr) M.setNum(pr,o.unitPrice,2);
      el.querySelector('.amt').textContent=(o.trxGb==='반품'?'−':'')+M.fmt0(o.totAmt);
      el.querySelector('.qt').textContent=M.fmtQ(o.qty); el.querySelector('.fx').textContent=fx(o); });
    $('itCnt').textContent=_rows.length?_rows.length+'줄':''; calc(); return;
  }
  $('itCnt').textContent=_rows.length?_rows.length+'줄':'';
  if(!_rows.length){ box.innerHTML='<div class="empty">[＋ 품목 추가] 로 상품을 담으세요.</div>'; calc(); return; }
  box.innerHTML=_rows.map(function(o,i){ var r=o.trxGb==='반품';
    return '<div class="it'+(r?' ret':'')+'" data-i="'+i+'">'
      +'<div class="t1"><div class="nm">'+esc(o.prodNm||o.prodCd)+'<small>'+esc(o.prodCd)+(o.spec?' · '+esc(o.spec):'')
      +(o.taxGb==='면세'?' · 면세':'')+'</small></div>'
      +'<button type="button" class="del" onclick="delRow('+i+')" aria-label="줄 삭제">✕</button></div>'
      +'<div class="g">'
      +'<div><label>BOX</label><input class="inp num" data-f="boxQty" inputmode="numeric" autocomplete="off" value="'+(n(o.boxQty)?M.fmt0(o.boxQty):'')+'" placeholder="0"></div>'
      +'<div><label>입수</label><div class="pk" title="상품마스터 입수수량 — 합계 = BOX × 입수 + EA">'+M.fmt0(n(o.packQty)||1)+'</div></div>'
      +'<div><label>EA</label><input class="inp num" data-f="eaQty" inputmode="numeric" autocomplete="off" value="'+(n(o.eaQty)?M.fmt0(o.eaQty):'')+'" placeholder="0"></div>'
      +'<div><label>단가</label><input class="inp num" data-f="unitPrice" inputmode="decimal" autocomplete="off" value="'+(n(o.unitPrice)?n(o.unitPrice).toLocaleString('ko-KR',{maximumFractionDigits:2}):'')+'" placeholder="0"></div>'
      +'</div>'
      +'<div class="t3"><span class="gb"><button type="button" class="'+(r?'':'on')+'" onclick="setGb('+i+',\'판매\')">판매</button>'
      +'<button type="button" class="r'+(r?' on':'')+'" onclick="setGb('+i+',\'반품\')">반품</button></span>'
      +'<span>합계 <b class="qt">'+M.fmtQ(o.qty)+'</b> <span class="fx">'+fx(o)+'</span></span><span class="amt">'+(r?'−':'')+M.fmt0(o.totAmt)+'</span></div>'
      +'</div>';
  }).join('');
  box.querySelectorAll('input[data-f]').forEach(function(el){
    var i=+el.closest('[data-i]').getAttribute('data-i'), f=el.getAttribute('data-f');
    M.numIn(el, function(v){ var o=_rows[i]; if(!o) return; o[f]=Math.abs(v); if(f==='unitPrice') o._pe=1; calcRow(o); render(true); }, f==='unitPrice'?2:0);
    el.addEventListener('keydown', function(e){ if(e.key==='Enter'){ e.preventDefault(); el.blur(); } });
  });
  calc();
}
/* 합계수량 식 — (BOX×입수+EA). BOX 가 없으면 식을 안 붙인다(EA 만이면 합계 = EA) */
function fx(o){ var b=n(o.boxQty), e=n(o.eaQty), p=n(o.packQty)||1; return b ? '('+M.fmt0(b)+'×'+M.fmt0(p)+(e?'+'+M.fmt0(e):'')+')' : ''; }
function setGb(i, gb){ var o=_rows[i]; if(!o) return; o.trxGb=gb; calcRow(o); render(); }
function delRow(i){
  var o=_rows[i]; if(!o) return;
  _confirmBox({ msg:'<b>'+esc(o.prodNm||o.prodCd)+'</b><br>이 줄을 뺄까요?', icon:'🗑', okText:'빼기', onOk:function(){ _rows.splice(i,1); render(); } });
}
function payFill(){ M.setNum($('payAmt'), n($('tTot').textContent)); calc(); }
function dcFill(){ var rest=n($('tTot').textContent)-n($('payAmt').value); M.setNum($('dcAmt'), rest>0?rest:0); calc(); }

/* ---------- 새 전표 / 불러오기 ---------- */
function newSlip(ask){
  var go=function(){
    _cur=null; _curNet=0; _rows=[]; _xref={};
    $('saleDt').value=M.ymd(); $('saleDt').disabled=false;
    $('payGb').value='외상'; $('payAmt').value=''; $('dcAmt').value=''; $('remark').value='';
    $('state').textContent='새 전표'; $('state').className='state new'; $('editBtns').hidden=true;
    setVen(null); render(); window.scrollTo(0,0);
  };
  if(ask && (_rows.length || _ven) && !_cur){ _confirmBox({ msg:'입력 중인 내용을 지우고 새 전표를 시작할까요?', icon:'📝', okText:'새 전표', okColor:'blue', onOk:go }); return; }
  go();
}
function openSlip(saleSeq){
  M.form('/mangr/salesTrxDetail.do',{ saleSeq:saleSeq }).then(function(res){
    var d=res && res.data; if(!d){ _alertBox('전표를 찾지 못했습니다.',{icon:'❌',okColor:'red'}); return; }
    _cur=d; _curNet=n(d.totAmt)-n(d.payAmt)-n(d.dcAmt);
    $('saleDt').value=M.d10(d.saleDt); $('saleDt').disabled=true;          // 고칠 때 일자 잠금(재고 원장 짝이 일자+번호)
    $('payGb').value=d.payGb||'외상'; M.setNum($('payAmt'),d.payAmt); M.setNum($('dcAmt'),d.dcAmt); $('remark').value=d.remark||'';
    _rows=(d.items||[]).map(function(x){
      var p=_prodBy[String(x.prodCd)]; x.taxGb=(p && p.taxGb==='면세')?'면세':'과세';
      /* PC saApply 와 같은 옛 전표 보정 — ①음수 줄 → 반품+양수 ②합계 ≠ BOX×입수+EA 인 옛 규칙 줄 → BOX 0 · EA = 저장 합계 */
      if(n(x.qty)<0||n(x.boxQty)<0||n(x.eaQty)<0){ x.trxGb='반품'; ['boxQty','eaQty','qty','amt','supplyAmt','vatAmt','totAmt'].forEach(function(k){ x[k]=Math.abs(n(x[k])); }); }
      if(n(x.qty)!==n(x.boxQty)*(n(x.packQty)||1)+n(x.eaQty)){ x.boxQty=0; x.eaQty=n(x.qty); }
      return x;
    });
    var v=null;
    M.vendors().catch(function(){ return []; }).then(function(list){
      v=list.filter(function(x){ return String(x.vendorCd)===String(d.custCd||''); })[0] || { vendorCd:d.custCd, vendorNm:d.custNm, mgrCd:d.mgrCd, mgrNm:d.mgrNm, vatGb:'별도' };
      /* 저장된 줄 금액은 그대로 둔다(고친 줄만 다시 계산) — setVen 이 전부 다시 계산하지 않게 _rows 를 잠시 비운다 */
      var keep=_rows; _rows=[]; setVen(v, false); _rows=keep; render();
    });
    $('state').innerHTML='수정 중 — '+esc(M.d10(d.saleDt))+' / '+esc(d.saleNo)+' <span class="badge gray">일자 고정</span>'; $('state').className='state';
    $('editBtns').hidden=false;
    showTab('edit');
  }).catch(function(e){ _alertBox('전표를 불러오지 못했습니다.<br>'+esc(M.errMsg(e)),{icon:'❌',okColor:'red'}); });
}

/* ---------- 저장 / 삭제 ---------- */
function saveSlip(){
  if(_busy) return;
  if(!_ven){ _alertBox('거래처를 고르세요.',{icon:'⚠️'}); return; }
  if(!_rows.length){ _alertBox('품목을 한 줄 이상 담으세요.',{icon:'⚠️'}); return; }
  var zero=_rows.filter(function(o){ return !n(o.qty); });
  if(zero.length){ _alertBox('수량이 0 인 줄이 있습니다.<br><b>'+esc(zero[0].prodNm||zero[0].prodCd)+'</b>',{icon:'⚠️'}); return; }
  var saleDt=$('saleDt').value; if(!saleDt){ _alertBox('판매일자를 고르세요.',{icon:'⚠️'}); return; }
  var t=calc();
  var dto={
    saleSeq: _cur ? _cur.saleSeq : null,
    saleDt: saleDt,
    dlvDt: _cur && _cur.dlvDt ? M.d10(_cur.dlvDt) : '',
    saleNo: _cur ? _cur.saleNo : '',                    // 새 전표는 서버가 번호를 매긴다
    custCd: _ven.vendorCd, custNm: _ven.vendorNm,
    mgrCd: _cur ? (_cur.mgrCd||'') : (_ven.mgrCd||''), mgrNm: _cur ? (_cur.mgrNm||'') : (_ven.mgrNm||''),
    whCd:'', whNm: _cur ? (_cur.whNm||'물류창고') : '물류창고',
    totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty,
    supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:n($('dcAmt').value),
    payGb:$('payGb').value, payAmt:n($('payAmt').value), taxGb:'과세',
    remark:$('remark').value,
    items:_rows.map(function(o){ var x={}; for(var k in o){ if(k.charAt(0)!=='_') x[k]=o[k]; } return x; })
  };
  var go=function(){
    _busy=true; var b=$('saveBtn'); b.textContent='저장 중…'; calc();
    M.session().then(function(){ return M.json('/mangr/salesTrxSave.do', dto); }).then(function(r){
      var no=(r && r.saleNo) || dto.saleNo;
      _alertBox('저장했습니다.'+(no?'<br><b>'+esc(saleDt)+' / '+esc(no)+'</b>':''),{icon:'✅',okColor:'blue'});
      _listLoaded=false; newSlip(false);
    }).catch(function(e){
      if(e && e.message==='login') return;             // 로그인 화면으로 가는 중
      _alertBox('저장하지 못했습니다.<br><span style="font-size:14.5px">'+esc(M.errMsg(e))+'</span>',{icon:'❌',okColor:'red'});
    }).then(function(){ _busy=false; b.textContent='저장'; calc(); });
  };
  _confirmBox({ msg:'<b>'+esc(_ven.vendorNm)+'</b><br>'+_rows.length+'줄 · 합계 <b>'+M.fmt0(t.tot)+'</b>원<br>'+(_cur?'이 전표를 고쳐 저장할까요?':'저장할까요?'),
    icon:'💾', okText:'저장', okColor:'blue', onOk:go });
}
function delSlip(){
  if(!_cur) return;
  _confirmBox({ msg:'이 전표를 삭제할까요?<br><span style="font-size:14.5px;color:#3d4d5c">재고에서 빠졌던 출고도 함께 되돌아옵니다.</span>', icon:'🗑', okText:'삭제',
    onOk:function(){
      M.session().then(function(){ return M.json('/mangr/salesTrxDelete.do',{ saleSeq:_cur.saleSeq, saleDt:_cur.saleDt, saleNo:_cur.saleNo }); })
        .then(function(){ _toast('삭제했습니다.','ok'); _listLoaded=false; newSlip(false); showTab('list'); })
        .catch(function(e){ if(e && e.message==='login') return; _alertBox('삭제하지 못했습니다.<br>'+esc(M.errMsg(e)),{icon:'❌',okColor:'red'}); });
    } });
}

/* ---------- 전표 목록 (PC 와 같은 /mangr/salesTrxList.do) ---------- */
var _listLoaded=false;
function loadList(){
  _listLoaded=true;
  var el=$('lBody'); el.innerHTML='<div class="loading">불러오는 중…</div>';
  M.form('/mangr/salesTrxList.do',{ fromDt:$('fFrom').value, toDt:$('fTo').value, findData:$('fNm').value.trim() }).then(function(res){
    var list=res.data||[];
    $('lCnt').textContent=list.length?list.length+'건 · 합계 '+M.fmt0(list.reduce(function(s,o){ return s+n(o.totAmt); },0)):'';
    if(!list.length){ el.innerHTML='<div class="empty">이 기간에 판매전표가 없습니다.</div>'; return; }
    el.innerHTML='<div class="list cols2" style="margin-top:0">'+list.map(function(o){
      return '<div class="row tap" onclick="openSlip('+n(o.saleSeq)+')"><div class="k">'+esc(o.custNm)
        +'<small>'+esc(M.d10(o.saleDt))+' / '+esc(o.saleNo)+' · '+n(o.prodCnt)+'품목'+(o.payGb&&o.payGb!=='외상'?' · '+esc(o.payGb):'')+'</small></div>'
        +'<div class="v">'+M.fmt0(o.totAmt)+'</div></div>';
    }).join('')+'</div>';
  }).catch(function(e){ el.innerHTML='<div class="err">불러오지 못했습니다. '+esc(M.errMsg(e))+'<button type="button" onclick="loadList()">다시</button></div>'; });
}

/* ---------- 시작 ---------- */
M.tabbar('sales');
M.numIn($('payAmt'), calc); M.numIn($('dcAmt'), calc);
(function(){ var t=M.ymd(); $('fTo').value=t; $('fFrom').value=t.slice(0,8)+'01'; })();
newSlip(false);
M.session().then(function(){
  return Promise.all([ loadProds(), M.vendors() ]);
}).catch(function(e){ if(e && e.message!=='login') _alertBox('기초 자료를 불러오지 못했습니다.<br>'+esc(M.errMsg(e)),{icon:'❌',okColor:'red'}); });
window.addEventListener('beforeunload', function(e){ if(_rows.length && !_busy && !_cur){ e.preventDefault(); e.returnValue=''; } });
</script>
</body>
</html>
