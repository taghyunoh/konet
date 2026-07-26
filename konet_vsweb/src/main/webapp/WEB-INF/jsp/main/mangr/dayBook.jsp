<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<!--
  일계장 — 하루치 거래처별 매출·매입·수금·지급 (2026-07-26 요청 신설)
    · 금액 규칙은 **거래처별 채권·채무(selectCustBalance)와 같다**. 낟알만 월 → 일자로 내렸다.
      매출 = 정산서 + 판매전표 / 수금 = 수금전표(+판매전표 즉시수금) / 매입·지급도 같은 방식.
    · 서버가 두 종류를 한 번에 준다 — dt='00000000' 은 **조회일 이전까지의 누계(전일잔액)**.
      화면은 그 위에 그날 발생을 얹어 '잔액'을 만든다(전일잔액을 따로 조회하지 않는다).
    · **조회 전용·인쇄용**. 금액을 고치려면 판매·매입·수금·지급 등록 화면에서 전표를 고친다.
    · 인쇄는 브라우저 인쇄(A4 세로) — @media print 로 조회줄·버튼을 숨기고 표만 남긴다.
      ※ iframe 안에서 Ctrl+P 를 누르면 바깥 화면이 찍히므로, 반드시 화면의 [🖨 인쇄] 버튼을 쓴다
        (그 버튼이 이 문서 자신의 window.print() 를 부른다).
-->
<style>
  :root{ --db-bd:#dbe2ea; --db-teal:#137a6c; --db-red:#c0392b; }
  *{ box-sizing:border-box; }
  .db-wrap{ padding:14px 16px; font-family:'맑은 고딕',Malgun Gothic,sans-serif; font-size:14px; color:#1f2a37; }
  .db-wrap h2{ margin:0 0 3px; font-size:19px; }
  .db-sub{ color:#1f2a37; margin-bottom:10px; font-size:12.5px; font-weight:600; }
  .db-card{ background:#fff; border:1px solid var(--db-bd); border-radius:10px; padding:11px 13px; margin-bottom:11px; }
  .db-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; }
  .db-fld{ display:flex; flex-direction:column; gap:3px; }
  .db-fld label{ font-size:12px; font-weight:700; color:#1f2a37; }
  .db-fld input, .db-fld select{ height:32px; border:1px solid var(--db-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .db-btn{ height:32px; border:1px solid var(--db-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .db-btn:hover{ border-color:var(--db-teal); }
  .db-btn.teal{ background:var(--db-teal); color:#fff; border-color:var(--db-teal); }
  .db-chk{ display:inline-flex; align-items:center; gap:6px; align-self:flex-end; height:32px; padding:0 10px;
           border:1px solid var(--db-bd); border-radius:7px; background:#fff;
           font-size:13px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
  .db-chk input{ margin:0; }
  .kpi{ display:flex; gap:10px; flex-wrap:wrap; margin:10px 0 0; }
  .kpi div{ flex:1 1 150px; border:1px solid var(--db-bd); border-radius:8px; padding:8px 12px; background:#fbfdfc; }
  .kpi b{ display:block; font-size:18px; color:var(--db-teal); margin-top:2px; white-space:nowrap; }
  .kpi b.red{ color:var(--db-red); }
  .kpi span{ font-size:12px; color:#1f2a37; font-weight:700; }
  .db-tit{ display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:7px; font-weight:800; }
  .db-tbwrap{ max-height:calc(100vh - 300px); overflow:auto; border:1px solid var(--db-bd); border-radius:8px; }
  table.db-tb{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  table.db-tb th{ background:#eef3f2; border:1px solid var(--db-bd); padding:6px 8px; position:sticky; top:0; z-index:2; }
  table.db-tb thead tr:nth-child(2) th{ top:28px; }
  table.db-tb th.grp{ background:#e3edea; }
  table.db-tb td{ border:1px solid var(--db-bd); padding:6px 8px; text-align:right; }
  table.db-tb td.txt{ text-align:left; }
  table.db-tb td.ctr{ text-align:center; }
  table.db-tb tr.tot td{ background:var(--db-teal); color:#fff; font-weight:800; }
  table.db-tb tr.dsum td{ background:#e9f1ef; font-weight:800; border-top:2px solid #cfe0db; }
  .amt-r{ color:var(--db-teal); font-weight:700; }
  .amt-p{ color:var(--db-red);  font-weight:700; }
  .gb{ font-size:11px; padding:1px 6px; border-radius:9px; background:#eef3f2; color:#37475a; font-weight:700; }
  .db-msg{ padding:26px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  .db-note{ font-size:12.5px; color:#1f2a37; line-height:1.75; font-weight:600; }
  /* 인쇄용 머리글 — 화면에서는 숨기고 인쇄할 때만 보인다 */
  .db-print{ display:none; }

  @media print{
    /* ★margin:0 이 핵심 — 페이지 여백이 0이라야 브라우저가 자기 머리글/바닥글
         (좌상단 날짜·상단 URL·하단 페이지번호)을 찍지 않는다(2026-07-26 요청).
         여백은 대신 본문 padding 으로 준다. @page 에 여백을 두면 그 자리에 URL 이 박힌다. */
    @page{ size:A4 portrait; margin:0; }
    body{ background:#fff; }
    .db-wrap{ padding:12mm 10mm; font-size:11px; }
    .db-noprint{ display:none !important; }          /* 조회줄·버튼·안내 */
    .db-print{ display:block; margin-bottom:8px; }
    .db-print h1{ margin:0 0 2px; font-size:18px; letter-spacing:6px; text-align:center; }
    .db-print .meta{ display:flex; justify-content:space-between; font-size:11px; color:#333; }
    .db-card{ border:0; padding:0; margin:0; border-radius:0; }
    .db-tbwrap{ max-height:none; overflow:visible; border:0; border-radius:0; }
    table.db-tb{ font-size:10.5px; }
    table.db-tb th{ position:static; background:#eee !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    table.db-tb tr.tot td{ background:#ddd !important; color:#000 !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    table.db-tb tr.dsum td{ background:#f0f0f0 !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    .amt-r, .amt-p{ color:#000 !important; }
    tr{ page-break-inside:avoid; }
    thead{ display:table-header-group; }             /* 페이지마다 머리글 반복 */
  }
</style>

<div class="db-wrap">
  <div class="db-noprint">
    <h2>📒 일계장</h2>
    <div class="db-sub">고른 날짜 하루의 <b>매출 · 매입 · 수금 · 지급</b>을 거래처별로 봅니다 — <b>전일잔액 + 당일매출 − 당일수금 = 잔액</b>.</div>

    <div class="db-card">
      <div class="db-row">
        <div class="db-fld" style="flex:0 0 160px"><label>일자</label><input type="date" id="dbDt"></div>
        <button class="db-btn" onclick="dbMove(-1)" title="하루 전">◀ 전일</button>
        <button class="db-btn" onclick="dbMove(1)" title="하루 뒤">익일 ▶</button>
        <button class="db-btn teal" onclick="dbLoad()">조회</button>
        <button class="db-btn" onclick="dbToday()">오늘</button>
        <label class="db-chk" title="끄면 그날 매출·매입·수금·지급이 있었던 거래처만 나옵니다.&#10;켜면 그날 변동이 없어도 잔액이 남은 거래처까지 나옵니다(잔액도 0인 곳은 제외)."><input type="checkbox" id="dbZero" onchange="dbRender()"> 변동 없어도 잔액 남은 곳</label>
        <button class="db-btn" onclick="dbPrint()" style="margin-left:auto">🖨 인쇄</button>
      </div>
      <div class="kpi">
        <div><span>당일 매출</span><b id="kSale">—</b></div>
        <div><span>당일 수금</span><b id="kRcv">—</b></div>
        <div><span>당일 매입</span><b id="kPurch" class="red">—</b></div>
        <div><span>당일 지급</span><b id="kPay" class="red">—</b></div>
        <div><span>거래 거래처</span><b id="kCnt">—</b></div>
      </div>
    </div>
  </div>

  <%-- 인쇄할 때만 나오는 머리글 --%>
  <div class="db-print">
    <h1>일 계 장</h1>
    <div class="meta"><span id="pDt">-</span><span id="pAt">-</span></div>
  </div>

  <div class="db-card">
    <div class="db-tit db-noprint"><span>📋 거래처별 <small id="dbSub" style="font-weight:600; color:#2b3a48; font-size:12px">일자를 고르고 [조회]</small></span></div>
    <div class="db-tbwrap"><table class="db-tb" id="dbList"></table></div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var _rows = [];   // 서버 원본 (dt × 거래처). dt='00000000' 은 전일잔액(이월)

function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ v=Math.round(n(v)); return v===0 ? '-' : v.toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function dtLbl(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
var WD=['일','월','화','수','목','금','토'];

(function init(){
  document.getElementById('dbDt').value = ymd(new Date());
  document.getElementById('dbList').innerHTML =
    '<tbody><tr><td class="db-msg">일자를 고르고 [조회]를 누르세요.</td></tr></tbody>';
})();

function dbToday(){ document.getElementById('dbDt').value = ymd(new Date()); dbLoad(); }
/* 전일/익일 — 날짜만 옮기고 바로 조회한다(일계장은 날짜를 넘겨 가며 보는 화면이라) */
function dbMove(k){
  var v=document.getElementById('dbDt').value; if(!v) return;
  var d=new Date(v); d.setDate(d.getDate()+k);
  document.getElementById('dbDt').value = ymd(d);
  dbLoad();
}

/* ★일자가 바뀌면 반드시 다시 조회한다 — 전일잔액이 그 날짜 기준으로 서버에서 잘리기 때문.
     (채권·채무 화면처럼 '한 번 받아 화면에서 자르기'를 할 수 없다) */
function dbLoad(){
  var v=document.getElementById('dbDt').value;
  if(!v){ if(window._alertBox) _alertBox('일자를 선택하세요.', {icon:'ℹ️'}); return; }
  document.getElementById('dbSub').textContent='조회 중…';
  fetch(CTX+'/mangr/selectDayBook.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'fromDt='+encodeURIComponent(v)+'&toDt='+encodeURIComponent(v) })
    .then(function(r){ return r.json(); })
    .then(function(j){ _rows=(j&&j.data)||[]; dbRender(); })
    .catch(function(e){
      document.getElementById('dbSub').textContent='오류';
      if(window._alertBox) _alertBox('조회에 실패했습니다.<br><span style="font-size:13px;color:#2b3a48">'+esc(e.message)+'</span>', {icon:'❌', okColor:'red'});
    });
}

function dbRender(){
  var el=document.getElementById('dbList');
  var dtv=document.getElementById('dbDt').value||'';
  if(!_rows.length){
    el.innerHTML='<tbody><tr><td class="db-msg">'+(dtv? dtLbl(dtv.replace(/-/g,''))+' 자료가 없습니다.' : '일자를 고르고 [조회]를 누르세요.')+'</td></tr></tbody>';
    document.getElementById('dbSub').textContent = dtv||'';
    ['kSale','kRcv','kPurch','kPay','kCnt'].forEach(function(id){ document.getElementById(id).textContent='—'; });
    return;
  }
  var showZero=document.getElementById('dbZero').checked;

  /* 거래처별로 접는다. dt='00000000' → 전일잔액, 그 외 → 당일 발생 */
  var m={}, ord=[];
  _rows.forEach(function(r){
    var k=String(r.custCd||'');
    if(!m[k]){ m[k]={ custCd:k, custNm:r.custNm||k, gb:r.vendorGb||'',
                      prevR:0, prevP:0, sale:0, rcv:0, purch:0, pay:0, moved:false }; ord.push(k); }
    var o=m[k];
    var sale=n(r.saleAmt)-n(r.saleDcAmt), rcv=n(r.rcvAmt),
        purch=n(r.purchAmt)-n(r.purchDcAmt), pay=n(r.payAmt);
    if(String(r.dt||'')==='00000000'){ o.prevR += sale-rcv; o.prevP += purch-pay; }
    else { o.sale+=sale; o.rcv+=rcv; o.purch+=purch; o.pay+=pay;
           if(sale||rcv||purch||pay) o.moved=true; }
  });

  var list=ord.map(function(k){ var o=m[k];
    o.balR=o.prevR+o.sale-o.rcv; o.balP=o.prevP+o.purch-o.pay; return o; });
  /* 기본은 그날 움직인 거래처만 — 일계장은 '오늘 무슨 일이 있었나'를 보는 표다.
     체크하면 그날 변동이 없어도 **잔액이 남은** 거래처까지 나온다.
     ★잔액까지 0인 곳(완납·거래종료)은 켜도 뺀다 — 전부 '-' 인 빈 줄이라 볼 게 없다(2026-07-26). */
  list = list.filter(function(o){
    if(o.moved) return true;
    if(!showZero) return false;
    return Math.round(o.balR)!==0 || Math.round(o.balP)!==0;
  });
  list.sort(function(a,b){ return (b.sale+b.rcv+b.purch+b.pay)-(a.sale+a.rcv+a.purch+a.pay); });

  var t={prevR:0,sale:0,rcv:0,balR:0,prevP:0,purch:0,pay:0,balP:0};
  list.forEach(function(o){ t.prevR+=o.prevR; t.sale+=o.sale; t.rcv+=o.rcv; t.balR+=o.balR;
                            t.prevP+=o.prevP; t.purch+=o.purch; t.pay+=o.pay; t.balP+=o.balP; });

  document.getElementById('kSale').textContent  = fmt(t.sale)==='-'?'0':fmt(t.sale);
  document.getElementById('kRcv').textContent   = fmt(t.rcv)==='-'?'0':fmt(t.rcv);
  document.getElementById('kPurch').textContent = fmt(t.purch)==='-'?'0':fmt(t.purch);
  document.getElementById('kPay').textContent   = fmt(t.pay)==='-'?'0':fmt(t.pay);
  document.getElementById('kCnt').textContent   = list.filter(function(o){ return o.moved; }).length.toLocaleString()+' 곳';

  var d=new Date(dtv), lbl=dtLbl(dtv.replace(/-/g,''))+' ('+WD[d.getDay()]+')';
  document.getElementById('dbSub').textContent = lbl+' · '+list.length.toLocaleString()+'곳';
  document.getElementById('pDt').textContent   = '일자 : '+lbl;
  document.getElementById('pAt').textContent   = '출력 : '+ymd(new Date());

  var h='<thead><tr>'
      + '<th rowspan="2">거래처</th><th rowspan="2">구분</th>'
      + '<th colspan="4" class="grp">받을금액</th>'
      + '<th colspan="4" class="grp">지급할금액</th>'
      + '</tr><tr>'
      + '<th>전일잔액</th><th>당일매출</th><th>당일수금</th><th>잔액</th>'
      + '<th>전일잔액</th><th>당일매입</th><th>당일지급</th><th>잔액</th>'
      + '</tr></thead><tbody>';
  h+='<tr class="tot"><td class="txt">■ 합계 ('+list.length.toLocaleString()+'곳)</td><td></td>'
   + '<td>'+fmt(t.prevR)+'</td><td>'+fmt(t.sale)+'</td><td>'+fmt(t.rcv)+'</td><td>'+fmt(t.balR)+'</td>'
   + '<td>'+fmt(t.prevP)+'</td><td>'+fmt(t.purch)+'</td><td>'+fmt(t.pay)+'</td><td>'+fmt(t.balP)+'</td></tr>';
  if(!list.length){
    h+='<tr><td class="db-msg" colspan="10">'+lbl+' 에 움직인 거래처가 없습니다. '
     + '(<b>변동 없어도 잔액 남은 곳</b> 을 켜면 잔액이 남은 거래처까지 나옵니다)</td></tr>';
  }
  list.forEach(function(o){
    h+='<tr><td class="txt" title="'+esc(o.custCd)+'">'+esc(o.custNm)+'</td>'
     + '<td class="ctr">'+(o.gb?'<span class="gb">'+esc(o.gb)+'</span>':'')+'</td>'
     + '<td>'+fmt(o.prevR)+'</td><td>'+fmt(o.sale)+'</td><td>'+fmt(o.rcv)+'</td><td class="amt-r">'+fmt(o.balR)+'</td>'
     + '<td>'+fmt(o.prevP)+'</td><td>'+fmt(o.purch)+'</td><td>'+fmt(o.pay)+'</td><td class="amt-p">'+fmt(o.balP)+'</td></tr>';
  });
  el.innerHTML=h+'</tbody>';
}

/* ★iframe 안에서는 Ctrl+P 가 바깥(물류관리 셸)을 찍는다.
     이 버튼은 이 문서 자신의 window.print() 를 불러 일계장만 나오게 한다. */
function dbPrint(){
  if(!_rows.length){ if(window._alertBox) _alertBox('먼저 [조회]를 눌러 자료를 띄운 뒤 인쇄하세요.', {icon:'ℹ️'}); return; }
  window.focus();
  window.print();
}
</script>
