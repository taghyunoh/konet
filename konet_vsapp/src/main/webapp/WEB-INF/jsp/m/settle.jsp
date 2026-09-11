<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 수금·지급 등록 — /m/settle.do?gb=RCV|PAY (MobileController, 로그인 필수). 2026-09-11 신설.
     ★저장은 PC 수금등록(rcvReg)·지급등록(payReg)과 **같은 엔드포인트·같은 모양**(/mangr/settleSave.do, JSON).
     · 결제구분·계좌는 PC 화면의 선택지를 그대로 옮겼다(글자 그대로 저장된다 — 코드표가 없다). PC 쪽을 바꾸면 여기도 같이.
     · 매출할인(saleDcAmt)은 수금에만 있다. totAmt = 금액 + 할인(매출할인은 안 넣는다 — PC 와 같다).
     · 잔고 = custLedger 누계(M.balance). 처리 후 잔고 = 현잔고 + (고치는 전표가 이미 뺀 금액) − 이번 금액.
     · 새 전표는 trxNo 를 비워 보낸다 — 서버가 번호를 매긴다. --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 수금·지급</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/m/m.css?v=20260911d">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<script src="<%=request.getContextPath()%>/m/m.js?v=20260911d"></script>
<style>
  .state{ font-size:14px; font-weight:700; color:var(--amber); margin:0 0 10px; display:flex; align-items:center; gap:8px; }
  .state.new{ color:var(--teal-d); }
  .filt{ display:grid; grid-template-columns:1fr 1fr; gap:6px; }
  .filt .btn{ grid-column:1 / -1; }
  @media (min-width:1024px){ .filt{ grid-template-columns:1fr 1fr 96px; } .filt .btn{ grid-column:auto; } }
  .rcv-only{ }
  body.pay .rcv-only{ display:none !important; }
</style>
</head>
<body>
<header>
  <div class="hd1">
    <h1 id="ttl">수금·지급</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="M.logout()">로그아웃</button>
  </div>
  <div class="seg" role="tablist">
    <button type="button" id="gbRCV" onclick="setGb('RCV')">💰 수금 (받은 돈)</button>
    <button type="button" id="gbPAY" onclick="setGb('PAY')">💸 지급 (준 돈)</button>
  </div>
</header>

<%-- 폰 = 입력 → 목록 한 줄 / 태블릿 = 왼쪽(입력) | 오른쪽(목록) — m.css .cols --%>
<main class="has-savebar cols even">
 <div class="colL">
  <section class="card o1">
    <p class="state new" id="state">새 전표</p>
    <div class="frm">
      <label for="trxDt">일자</label>
      <input class="inp" type="date" id="trxDt">
      <label>거래처</label>
      <button type="button" class="pick" id="venBtn" onclick="pickVen()"><span class="ph">거래처를 고르세요</span></button>
    </div>
    <div class="tiles" id="balBox" style="margin-top:10px" hidden>
      <div class="tile"><span id="balLbl">현잔고</span><b id="balNow">—</b></div>
      <div class="tile"><span id="balLbl2">처리 후 잔고</span><b id="balAfter" class="teal">—</b></div>
    </div>
  </section>

  <section class="card o2">
    <div class="frm">
      <label for="amt" id="amtLbl">금액</label>
      <div class="inrow"><input class="inp num" id="amt" inputmode="numeric" autocomplete="off" placeholder="0"><button type="button" class="btn sm ghost" id="fillBtn" onclick="fillBal()" hidden>잔고 전액</button></div>
      <label for="payGb">결제구분</label>
      <select class="inp" id="payGb"></select>
      <label for="acctNm">계좌</label>
      <select class="inp" id="acctNm">
        <option value="">(선택 안 함)</option>
        <option>국민은행 / 699237-01-004560 / (주)코네트</option>
        <option>우리은행 / 1005-201-931176 / (주)코네트</option>
      </select>
      <label for="dcAmt">할인</label>
      <input class="inp num" id="dcAmt" inputmode="numeric" autocomplete="off" placeholder="0">
      <label for="saleDcAmt" class="rcv-only">매출할인</label>
      <input class="inp num rcv-only" id="saleDcAmt" inputmode="numeric" autocomplete="off" placeholder="0">
      <label for="remark">비고</label>
      <textarea class="inp" id="remark" rows="2" maxlength="500"></textarea>
    </div>
    <div class="btnrow" id="editBtns" hidden>
      <button type="button" class="btn ghost" onclick="newSlip()">＋ 새 전표</button>
      <button type="button" class="btn danger" onclick="delSlip()">✖ 삭제</button>
    </div>
  </section>
 </div>
 <div class="colR">
  <section class="card o3">
    <h2 id="lTtl">최근 전표 <small id="lCnt"></small></h2>
    <div class="filt">
      <input class="inp" type="date" id="fFrom">
      <input class="inp" type="date" id="fTo">
      <button type="button" class="btn" onclick="loadList()">조회</button>
    </div>
    <div id="lBody" class="loading">불러오는 중…</div>
  </section>
 </div>
</main>

<div class="savebar">
  <div class="in">
    <div class="sum"><span id="sbLbl">수금 합계</span><b id="sbTot">0</b><span id="sbSub"></span></div>
    <button type="button" class="btn fill" id="saveBtn" onclick="saveSlip()">저장</button>
  </div>
</div>

<script>
var $=M.$, n=M.n, esc=M.esc;
var GB='RCV', _ven=null, _cur=null, _balNow=0, _balSt='', _busy=false;
var PAYGB = { RCV:['무통장입금','현금','카드','계좌이체','어음'], PAY:['무통장지급','현금','카드','계좌이체','어음'] };
var NM = { RCV:'수금', PAY:'지급' };

function setGb(g, keep){
  GB=(g==='PAY')?'PAY':'RCV';
  document.body.classList.toggle('pay', GB==='PAY');
  $('gbRCV').classList.toggle('on', GB==='RCV'); $('gbPAY').classList.toggle('on', GB==='PAY');
  $('ttl').textContent=NM[GB]+'등록'; document.title='코네트 '+NM[GB]+'등록';
  $('amtLbl').textContent=NM[GB]+'금액'; $('sbLbl').textContent=NM[GB]+' 합계';
  $('balLbl').textContent= GB==='RCV' ? '현잔고 (받을금액)' : '현잔고 (지급할금액)';
  $('balLbl2').textContent= NM[GB]+' 후 잔고';
  $('lTtl').firstChild.nodeValue='최근 '+NM[GB]+' ';
  $('payGb').innerHTML=PAYGB[GB].map(function(x){ return '<option>'+x+'</option>'; }).join('');
  try{ history.replaceState(null,'','?gb='+GB); }catch(e){}
  if(!keep){ newSlip(); loadList(); }
}

/* ---------- 거래처 ---------- */
function pickVen(){
  M.pickVendor({ gb: GB==='RCV'?'매출':'매입', title: NM[GB]+' 거래처' }, function(v){ setVen(v); });
}
function setVen(v){
  _ven=v;
  $('venBtn').innerHTML = v ? '<b>'+esc(v.vendorNm)+'</b><small>'+esc(v.vendorCd)+'</small>' : '<span class="ph">거래처를 고르세요</span>';
  $('balBox').hidden=!v; $('fillBtn').hidden=true; _balNow=0; _balSt='';
  if(!v){ calc(); return; }
  _balSt='load'; $('balNow').textContent='…'; $('balAfter').textContent='…';
  M.balance(v.vendorCd).then(function(b){
    if(_ven!==v) return;
    _balNow = GB==='RCV' ? b.recv : b.pay; _balSt='ok';
    calc();
  }).catch(function(){ if(_ven!==v) return; _balSt='err'; $('balNow').textContent='?'; $('balAfter').textContent='?'; });
  calc();
}

/* ---------- 계산 ---------- */
function curAmt(){ return n($('amt').value)+n($('dcAmt').value)+(GB==='RCV'?n($('saleDcAmt').value):0); }
function curNet(){ return _cur ? n(_cur.amt)+n(_cur.dcAmt)+(GB==='RCV'?n(_cur.saleDcAmt):0) : 0; }
function calc(){
  var a=n($('amt').value), d=n($('dcAmt').value), s=GB==='RCV'?n($('saleDcAmt').value):0;
  $('sbTot').textContent=M.fmt0(a);
  $('sbSub').textContent=(d||s) ? '할인 '+M.fmt0(d)+(s?' · 매출할인 '+M.fmt0(s):'') : '';
  if(_ven && _balSt==='ok'){
    var base=_balNow+curNet();                          // 고치는 전표가 이미 뺀 금액은 되돌려 놓고 본다
    $('balNow').textContent=M.fmt0(_balNow);
    var af=base-curAmt(); $('balAfter').textContent=M.fmt0(af); $('balAfter').className=af<0?'red':'teal';
    $('fillBtn').hidden = !(base>0);
  }
  $('saveBtn').disabled = _busy || !_ven || !(a||d||s);
}
function fillBal(){ var base=_balNow+curNet()-n($('dcAmt').value)-(GB==='RCV'?n($('saleDcAmt').value):0); M.setNum($('amt'), base>0?base:0); calc(); }

/* ---------- 새 전표 / 불러오기 ---------- */
function newSlip(){
  _cur=null;
  $('trxDt').value=M.ymd(); $('payGb').value=PAYGB[GB][0]; $('acctNm').value='';
  ['amt','dcAmt','saleDcAmt'].forEach(function(id){ $(id).value=''; }); $('remark').value='';
  $('state').textContent='새 '+NM[GB]+' 전표'; $('state').className='state new'; $('editBtns').hidden=true;
  setVen(null);
}
function openSlip(o){
  _cur=o;
  $('trxDt').value=M.d10(o.trxDt);
  $('payGb').value=o.payGb||PAYGB[GB][0]; if($('payGb').value!==(o.payGb||PAYGB[GB][0])){ $('payGb').insertAdjacentHTML('beforeend','<option>'+esc(o.payGb)+'</option>'); $('payGb').value=o.payGb; }
  $('acctNm').value=o.acctNm||''; if($('acctNm').value!==(o.acctNm||'')){ $('acctNm').insertAdjacentHTML('beforeend','<option>'+esc(o.acctNm)+'</option>'); $('acctNm').value=o.acctNm; }
  M.setNum($('amt'),o.amt); M.setNum($('dcAmt'),o.dcAmt); M.setNum($('saleDcAmt'),o.saleDcAmt); $('remark').value=o.remark||'';
  $('state').innerHTML='수정 중 — '+esc(M.d10(o.trxDt))+' / '+esc(o.trxNo); $('state').className='state';
  $('editBtns').hidden=false;
  M.vendors().catch(function(){ return []; }).then(function(list){
    var v=list.filter(function(x){ return String(x.vendorCd)===String(o.custCd||''); })[0] || { vendorCd:o.custCd, vendorNm:o.custNm, mgrCd:o.mgrCd, mgrNm:o.mgrNm };
    setVen(v);
  });
  window.scrollTo(0,0);
}

/* ---------- 저장 / 삭제 ---------- */
function saveSlip(){
  if(_busy) return;
  if(!_ven){ _alertBox('거래처를 고르세요.',{icon:'⚠️'}); return; }
  var a=n($('amt').value), d=n($('dcAmt').value), s=GB==='RCV'?n($('saleDcAmt').value):0;
  if(!(a||d||s)){ _alertBox(NM[GB]+'금액을 넣으세요.',{icon:'⚠️'}); return; }
  if(!$('trxDt').value){ _alertBox('일자를 고르세요.',{icon:'⚠️'}); return; }
  var dto={
    trxSeq: _cur ? _cur.trxSeq : null, trxGb: GB,
    trxDt: $('trxDt').value, trxNo: _cur ? _cur.trxNo : '',
    payGb: $('payGb').value, acctNm: $('acctNm').value, acctCd:'',
    custCd: _ven.vendorCd, custNm: _ven.vendorNm,
    mgrCd: _cur ? (_cur.mgrCd||'') : (_ven.mgrCd||''), mgrNm: _cur ? (_cur.mgrNm||'') : (_ven.mgrNm||''),
    amt:a, dcAmt:d, saleDcAmt:s, totAmt:a+d,
    remark: $('remark').value
  };
  var go=function(){
    _busy=true; var b=$('saveBtn'); b.textContent='저장 중…'; calc();
    M.session().then(function(){ return M.json('/mangr/settleSave.do', dto); }).then(function(r){
      var no=(r && r.trxNo) || dto.trxNo;
      _toast(NM[GB]+' 저장했습니다'+(no?' ('+esc(no)+')':''),'ok');
      newSlip(); loadList();
    }).catch(function(e){
      if(e && e.message==='login') return;
      _alertBox('저장하지 못했습니다.<br><span style="font-size:14.5px">'+esc(M.errMsg(e))+'</span>',{icon:'❌',okColor:'red'});
    }).then(function(){ _busy=false; b.textContent='저장'; calc(); });
  };
  _confirmBox({ msg:'<b>'+esc(_ven.vendorNm)+'</b><br>'+NM[GB]+' <b>'+M.fmt0(a)+'</b>원'+((d||s)?' (할인 '+M.fmt0(d+s)+')':'')+'<br>'+esc($('payGb').value)+' · '+esc($('trxDt').value)+'<br>'+(_cur?'이 전표를 고쳐 저장할까요?':'저장할까요?'),
    icon:'💾', okText:'저장', okColor:'blue', onOk:go });
}
function delSlip(){
  if(!_cur) return;
  _confirmBox({ msg:'이 '+NM[GB]+' 전표를 삭제할까요?<br><b>'+esc(_cur.custNm)+' · '+M.fmt0(_cur.amt)+'원</b>', icon:'🗑', okText:'삭제',
    onOk:function(){
      M.session().then(function(){ return M.json('/mangr/settleDelete.do',{ trxSeq:_cur.trxSeq }); })
        .then(function(){ _toast('삭제했습니다.','ok'); newSlip(); loadList(); })
        .catch(function(e){ if(e && e.message==='login') return; _alertBox('삭제하지 못했습니다.<br>'+esc(M.errMsg(e)),{icon:'❌',okColor:'red'}); });
    } });
}

/* ---------- 목록 (PC 와 같은 /mangr/settleList.do) ---------- */
var _list=[];
function loadList(){
  var el=$('lBody'); el.innerHTML='<div class="loading">불러오는 중…</div>';
  var g=GB;
  M.form('/mangr/settleList.do',{ trxGb:g, fromDt:$('fFrom').value, toDt:$('fTo').value, payGb:'', findData:'' }).then(function(res){
    if(g!==GB) return;
    _list=res.data||[];
    $('lCnt').textContent=_list.length?_list.length+'건 · '+M.fmt0(_list.reduce(function(s,o){ return s+n(o.amt); },0)):'';
    if(!_list.length){ el.innerHTML='<div class="empty">이 기간에 '+NM[GB]+' 전표가 없습니다.</div>'; return; }
    el.innerHTML='<div class="list">'+_list.map(function(o,i){
      var dc=n(o.dcAmt)+n(o.saleDcAmt);
      return '<div class="row tap" onclick="openSlip(_list['+i+'])"><div class="k">'+esc(o.custNm)
        +'<small>'+esc(M.d10(o.trxDt))+' / '+esc(o.trxNo)+' · '+esc(o.payGb||'')+(o.remark?' · '+esc(o.remark):'')+'</small></div>'
        +'<div class="v">'+M.fmt0(o.amt)+(dc?'<small>할인 '+M.fmt0(dc)+'</small>':'')+'</div></div>';
    }).join('')+'</div>';
  }).catch(function(e){ el.innerHTML='<div class="err">불러오지 못했습니다. '+esc(M.errMsg(e))+'<button type="button" onclick="loadList()">다시</button></div>'; });
}

/* ---------- 시작 ---------- */
M.tabbar('settle');
['amt','dcAmt','saleDcAmt'].forEach(function(id){ M.numIn($(id), calc); });
(function(){ var t=M.ymd(); $('fTo').value=t; $('fFrom').value=t.slice(0,8)+'01'; })();
setGb(new URLSearchParams(location.search).get('gb')||'RCV', true);
newSlip();
M.session().then(function(){ loadList(); M.vendors().catch(function(){}); }).catch(function(){});
</script>
</body>
</html>
