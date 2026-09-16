<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>비용 등록</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<!--
  비용 등록 (2026-09-16 신설, P2-e — 프로그램 목적 ⑤「정산서 → 정확한 매출액 → 순마진」) — 마감관리 ▸ 비용 등록. 셸 iframe(logiFrame) 화면.
  · 지금까지 「순마진」은 매출 − 매출원가(=매출총이익)였다. 여기서 달마다 비용을 넣으면 마감현황·월별 마감이력의 순마진 = 매출총이익 − 비용 이 된다.
  · 한 줄 = 비용 항목(TBL_EXPENSE_ITEM). 금액은 달 × 항목 한 줄(TBL_EXPENSE_TRX, upsert). 실제 나간 돈(세포함) — 매출·원가와 같은 잣대.
  · ★직송 택배 운임(AUTO_SRC='PARCEL')은 **읽기 전용** — 그 달 직송 출고(택배출고관리 엑셀 줄과 같은 단위: 출고일자×사업장×품목) × 사업장 운임
    (없으면 회사 설정 「기본 택배 운임」)으로 서버(selectParcelFeeAuto)가 센다. 고치려면 택배출고관리에서 사업장 운임을 고친다.
  · 마감 확정된 달에 저장하면 막지 않고 확인창만(수금 마감과 같은 방침) — 순마진에 반영하려면 마감현황에서 다시 확정해야 한다.
  · 자료 /mangr/expenseMonth.do(ym) · 저장 /mangr/expenseSave.do · 항목 /mangr/expenseItemSave.do
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:12px; font-size:12.5px; line-height:1.6; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input[type=month], .bar input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .chip{ display:inline-flex; align-items:center; gap:6px; color:#37475a; font-size:13px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 12px; white-space:nowrap; }
  .chip.lock{ background:#fdf0d5; border-color:#f0d29a; color:#6b4f0a; }
  .chip b{ color:var(--teal); font-weight:800; }
  .tot{ margin-left:auto; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  table.g{ border-collapse:collapse; width:100%; font-size:13.5px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:8px 9px; text-align:center; white-space:nowrap; }
  table.g th:last-child, table.g td:last-child{ border-right:none; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:5px 9px; vertical-align:middle; text-align:center; }
  table.g td.l{ text-align:left; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g tr:hover td{ background:#f7faf9; }
  table.g tr.auto td{ background:#f6fbfa; }
  table.g tr.sum td{ background:#eef4f2; font-weight:800; }
  table.g input[type=text], table.g input[type=number]{ height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 7px; font-size:13.5px; width:100%; }
  table.g input.amt{ text-align:right; font-variant-numeric:tabular-nums; font-weight:700; }
  table.g input.chg{ background:#fffbe6; border-color:#e3c08a; }
  table.g select{ height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 5px; font-size:13px; background:#fff; }
  .gb{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .gb.FIX{ background:#e8eef7; color:#2b4a7a; }
  .gb.VAR{ background:#fdf0d5; color:#9a5b05; }
  .auto{ font-size:11.5px; font-weight:800; color:var(--teal); }
  .dim{ color:#8a98a8; }
  .off td{ opacity:.55; }
  .empty{ padding:36px; text-align:center; color:#8a98a8; }
  .note{ font-size:12.5px; color:#5a6b7a; line-height:1.7; padding:8px 12px; }
  .note b{ color:#37475a; }
</style>
</head>
<body>
<div class="wrap">
  <h2>💸 비용 등록</h2>
  <div class="sub">달마다 <b>비용</b>을 넣으면 마감현황·월별 마감이력의 <b>순마진 = 매출총이익(매출 − 매출원가) − 비용</b> 이 됩니다.
    <b>직송 택배 운임</b>은 택배출고관리의 직송 출고 × 사업장 운임으로 <b>자동</b>으로 세고(읽기 전용), 나머지는 실제 나간 돈(세포함)을 적습니다.</div>
  <div class="bar">
    <input type="month" id="ym" onchange="load()">
    <button class="btn" onclick="ymMove(-1)" title="지난 달">◀</button>
    <button class="btn" onclick="ymMove(1)" title="다음 달">▶</button>
    <button class="btn btn-teal" onclick="load()">🔍 조회</button>
    <button class="btn" onclick="copyPrev()" title="지난 달 수기 금액을 이 달 칸에 채웁니다(저장은 따로)">📋 전월 복사</button>
    <button class="btn btn-teal" id="saveBtn" onclick="save()">💾 저장</button>
    <span class="chip" id="stChip">—</span>
    <span class="chip tot" id="totChip">비용 합계 <b>—</b></span>
  </div>

  <div class="card">
    <div class="hd">📅 <span id="ymTit">이 달 비용</span> <small>— 금액을 고치면 노란색, [💾 저장]으로 굳힙니다</small></div>
    <table class="g" id="grid">
      <thead><tr>
        <th style="width:190px">항목</th><th style="width:70px">구분</th><th style="width:170px">금액</th>
        <th style="min-width:260px">비고 / 근거</th><th style="width:150px">마지막 수정</th>
      </tr></thead>
      <tbody id="body"><tr><td colspan="5" class="empty">조회 중…</td></tr></tbody>
    </table>
  </div>

  <div class="card">
    <div class="hd">🧾 비용 항목 <small>— 무엇을 비용으로 셀지. 코드는 한 번 만들면 못 바꿉니다(금액이 코드에 매달립니다). 안 쓰는 항목은 「사용」을 끕니다</small></div>
    <table class="g" id="itemGrid">
      <thead><tr>
        <th style="width:130px">코드</th><th style="min-width:200px">이름</th><th style="width:110px">구분</th>
        <th style="width:90px">자동</th><th style="width:80px">차례</th><th style="width:70px">사용</th><th style="width:90px"></th>
      </tr></thead>
      <tbody id="itemBody"></tbody>
    </table>
    <div class="note">· <b>고정</b> = 달마다 비슷하게 나가는 것(인건비·임차료) · <b>변동</b> = 달마다 다른 것(운임·기타). 구분은 표시용이라 계산엔 영향 없습니다.<br>
      · <b>자동 = PARCEL</b> 항목은 금액을 손으로 못 넣습니다 — 사업장 운임(택배출고관리)이나 회사 정보 수정 ▸ 기능 ▸ <b>기본 택배 운임</b>을 고치면 따라옵니다.</div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _items=[], _trx={}, _auto=null, _feeDef=4500, _closed=false, _ym='';
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function ymNow(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2); }
function ymVal(){ return document.getElementById('ym').value||''; }
function ymMove(off){ var v=ymVal()||ymNow(); var d=new Date(Number(v.slice(0,4)), Number(v.slice(5,7))-1+off, 1);
  document.getElementById('ym').value=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2); load(); }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin',
  headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }
function ok(m){ if(window._toast) _toast(m,'success'); else _alertBox(m,{icon:'✅'}); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function ask(m, okText){ return new Promise(function(res){ _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', onOk:function(){res(true);}, onCancel:function(){res(false);} }); }); }

/* ── 조회 ── */
function load(){
  var ym=ymVal(); if(!ym){ document.getElementById('ym').value=ymNow(); ym=ymVal(); }
  _ym=ym;
  document.getElementById('ymTit').textContent=ym+' 비용';
  document.getElementById('body').innerHTML='<tr><td colspan="5" class="empty">조회 중…</td></tr>';
  post('/mangr/expenseMonth.do','ym='+encodeURIComponent(ym))
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return JSON.parse(t); }); })
    .then(function(j){
      if(ymVal()!==ym) return;                       // 그 사이 달을 또 바꿨으면 버린다
      _items=(j&&j.items)||[]; _auto=(j&&j.auto)||null; _feeDef=n(j&&j.feeDef)||4500;
      _trx={}; ((j&&j.trx)||[]).forEach(function(r){ _trx[String(r.itemCd||'')]=r; });
      render(); renderItems(); closedChk(ym);
    })
    .catch(function(e){ document.getElementById('body').innerHTML='<tr><td colspan="5" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
/* 마감 확정 여부 — 마감현황(TBL_CLOSING_MST)과 같은 조회. 확정된 달이면 🔒 (저장은 막지 않는다) */
function closedChk(ym){
  _closed=false; var c=document.getElementById('stChip'); c.className='chip'; c.textContent='마감 미확정';
  post('/shipout/selectClosingStatus.do','ym='+encodeURIComponent(ym)).then(function(r){ return r.json(); })
    .then(function(j){ if(ymVal()!==ym) return; var d=j&&j.data; if(d && d.status==='C'){ _closed=true; c.className='chip lock'; c.textContent='🔒 '+ym+' 마감 확정 — 비용을 고치면 마감현황에서 다시 확정해야 순마진에 반영'; } })
    .catch(function(){});
}

/* ── 이 달 비용 표 ── */
function autoAmt(){ return _auto ? n(_auto.amt) : 0; }
function autoCnt(){ return _auto ? n(_auto.cnt) : 0; }
function rowAmt(it){ if(it.autoSrc==='PARCEL') return autoAmt(); var el=document.querySelector('input.amt[data-cd="'+it.itemCd+'"]'); return el ? n(el.value) : n((_trx[it.itemCd]||{}).amt); }
function total(){ var t=0; _items.forEach(function(it){ if(it.useYn==='Y') t+=rowAmt(it); }); return t; }
function render(){
  var tb=document.getElementById('body');
  var use=_items.filter(function(it){ return it.useYn==='Y'; });
  if(!use.length){ tb.innerHTML='<tr><td colspan="5" class="empty">사용 중인 비용 항목이 없습니다 — 아래 「비용 항목」에서 만드세요.</td></tr>'; sumChip(); return; }
  tb.innerHTML=use.map(function(it){
    var t=_trx[it.itemCd]||{};
    if(it.autoSrc==='PARCEL'){
      var cnt=autoCnt(), amt=autoAmt();
      return '<tr class="auto"><td class="l"><b>'+esc(it.itemNm)+'</b> <span class="auto">자동</span></td><td><span class="gb '+esc(it.itemGb)+'">'+(it.itemGb==='FIX'?'고정':'변동')+'</span></td>'
        +'<td class="r"><b>'+fmt(amt)+'</b></td>'
        +'<td class="l">'+(cnt?('직송 택배 <b>'+cnt.toLocaleString()+'건</b> × 평균 '+fmt(amt/cnt)+'원 (사업장 운임, 없으면 기본 '+fmt(_feeDef)+'원) '):'이 달 직송 출고 없음 ')
        +'<button class="btn" style="height:26px;padding:0 8px;font-size:12px" onclick="goParcel()">택배출고관리 →</button></td>'
        +'<td class="dim">집계값</td></tr>';
    }
    return '<tr><td class="l"><b>'+esc(it.itemNm)+'</b></td><td><span class="gb '+esc(it.itemGb)+'">'+(it.itemGb==='FIX'?'고정':'변동')+'</span></td>'
      +'<td><input type="text" class="amt" data-cd="'+esc(it.itemCd)+'" value="'+(n(t.amt)?fmt(t.amt):'')+'" data-org="'+Math.round(n(t.amt))+'" placeholder="0" onfocus="this.select()" oninput="chg(this)" onblur="fmtIn(this)"></td>'
      +'<td><input type="text" class="rmk" data-cd="'+esc(it.itemCd)+'" value="'+esc(t.remark||'')+'" data-org="'+esc(t.remark||'')+'" placeholder="근거·메모" oninput="chg(this)"></td>'
      +'<td class="dim">'+esc(((t.updDttm||t.regDttm)||'').slice(0,16))+'</td></tr>';
  }).join('')
  +'<tr class="sum"><td class="l">■ 비용 합계</td><td></td><td class="r" id="sumCell">'+fmt(total())+'</td><td class="l dim">마감현황의 순마진 = 매출총이익 − 이 합계</td><td></td></tr>';
  sumChip();
}
function sumChip(){ var t=total(); document.getElementById('totChip').innerHTML='비용 합계 <b>'+fmt(t)+'</b> 원'; var s=document.getElementById('sumCell'); if(s) s.textContent=fmt(t); }
function chg(el){ var org=el.getAttribute('data-org')||''; var cur=el.classList.contains('amt') ? String(Math.round(n(el.value))) : el.value; el.classList.toggle('chg', cur!==org); if(el.classList.contains('amt')) sumChip(); }
function fmtIn(el){ var v=n(el.value); el.value = v ? fmt(v) : ''; }
function dirtyRows(){
  var rows=[];
  _items.forEach(function(it){ if(it.autoSrc==='PARCEL' || it.useYn!=='Y') return;
    var a=document.querySelector('input.amt[data-cd="'+it.itemCd+'"]'), r=document.querySelector('input.rmk[data-cd="'+it.itemCd+'"]'); if(!a) return;
    var amt=Math.round(n(a.value)), rmk=r?r.value:'';
    if(String(amt)!==(a.getAttribute('data-org')||'0') || rmk!==(r?r.getAttribute('data-org')||'':'')) rows.push({ itemCd:it.itemCd, amt:amt, remark:rmk });
  });
  return rows;
}
function save(){
  var rows=dirtyRows();
  if(!rows.length){ _alertBox('바꾼 금액이 없습니다.', {icon:'ℹ️'}); return; }
  var go = _closed
    ? ask('<b>'+_ym+'</b> 은 <b>마감 확정</b>된 달입니다.<br><span style="font-size:13px;color:#3d4d5c">비용을 저장해도 확정된 순마진은 그대로입니다 — 마감현황에서 <b>다시 확정</b>해야 반영됩니다.</span>', '그래도 저장')
    : Promise.resolve(true);
  go.then(function(y){ if(!y) return;
    var b=document.getElementById('saveBtn'); b.disabled=true;
    post('/mangr/expenseSave.do', { ym:_ym, rows:rows }, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(){ ok(_ym+' 비용 '+rows.length+'줄을 저장했습니다'); load(); })
      .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
      .then(function(){ b.disabled=false; });
  });
}
/* 전월 복사 — 지난 달 수기 금액을 이 달 칸에 채운다(비고까지). 자동 항목은 건너뛴다. 저장은 [저장]으로 */
function copyPrev(){
  var v=_ym||ymVal(); var d=new Date(Number(v.slice(0,4)), Number(v.slice(5,7))-2, 1);
  var pym=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2);
  post('/mangr/expenseMonth.do','ym='+encodeURIComponent(pym)).then(function(r){ return r.json(); })
    .then(function(j){
      var cnt=0; ((j&&j.trx)||[]).forEach(function(t){
        var a=document.querySelector('input.amt[data-cd="'+t.itemCd+'"]'); if(!a) return;
        a.value=n(t.amt)?fmt(t.amt):''; chg(a);
        var r=document.querySelector('input.rmk[data-cd="'+t.itemCd+'"]'); if(r && !r.value){ r.value=t.remark||''; chg(r); }
        cnt++;
      });
      if(window._toast) _toast(cnt ? (pym+' 금액 '+cnt+'줄을 채웠습니다 — [저장]을 누르세요') : (pym+' 에 저장된 비용이 없습니다'), cnt?'success':'warning');
    })
    .catch(function(e){ err('지난 달을 읽지 못했습니다.<br>'+esc(e.message)); });
}
/* 택배출고관리로 — 셸 메뉴를 그대로 누른다(자주 쓰는 메뉴 칩과 같은 길) */
function goParcel(){
  try{ var m=window.parent.document.querySelector('a.mi[data-key="parcelout"]'); if(m){ m.click(); return; } }catch(e){}
  _alertBox('셸 메뉴 「택배출고관리」에서 그 달의 직송 출고를 보세요.', {icon:'ℹ️'});
}

/* ── 비용 항목 ── */
function renderItems(){
  var tb=document.getElementById('itemBody');
  tb.innerHTML=_items.map(function(it){
    var au=(it.autoSrc==='PARCEL');
    return '<tr class="'+(it.useYn==='Y'?'':'off')+'" data-cd="'+esc(it.itemCd)+'"><td><b>'+esc(it.itemCd)+'</b></td>'
      +'<td><input type="text" class="inm" value="'+esc(it.itemNm)+'"></td>'
      +'<td><select class="igb"><option value="FIX"'+(it.itemGb==='FIX'?' selected':'')+'>고정</option><option value="VAR"'+(it.itemGb==='VAR'?' selected':'')+'>변동</option></select></td>'
      +'<td>'+(au?'<span class="auto">PARCEL</span>':'<span class="dim">—</span>')+'</td>'
      +'<td><input type="number" class="iso" value="'+n(it.sortOrd)+'" style="text-align:right"></td>'
      +'<td><select class="iuse"><option value="Y"'+(it.useYn==='Y'?' selected':'')+'>예</option><option value="N"'+(it.useYn!=='Y'?' selected':'')+'>아니오</option></select></td>'
      +'<td><button class="btn" style="height:28px;padding:0 10px;font-size:12px" onclick="itemSave(this)">저장</button></td></tr>';
  }).join('')
  +'<tr data-new="1"><td><input type="text" class="icd" placeholder="새 코드 (영문·숫자)" style="text-transform:uppercase"></td>'
  +'<td><input type="text" class="inm" placeholder="새 항목 이름"></td>'
  +'<td><select class="igb"><option value="FIX">고정</option><option value="VAR">변동</option></select></td><td><span class="dim">—</span></td>'
  +'<td><input type="number" class="iso" value="50" style="text-align:right"></td><td><select class="iuse"><option value="Y">예</option><option value="N">아니오</option></select></td>'
  +'<td><button class="btn btn-teal" style="height:28px;padding:0 10px;font-size:12px" onclick="itemSave(this)">＋ 추가</button></td></tr>';
}
function itemSave(btn){
  var tr=btn.closest('tr'), isNew=!!tr.getAttribute('data-new');
  var cd=isNew ? String((tr.querySelector('.icd')||{}).value||'').trim().toUpperCase() : tr.getAttribute('data-cd');
  var p={ itemCd:cd, itemNm:(tr.querySelector('.inm')||{}).value||'', itemGb:(tr.querySelector('.igb')||{}).value||'FIX',
          sortOrd:n((tr.querySelector('.iso')||{}).value), useYn:(tr.querySelector('.iuse')||{}).value||'Y' };
  if(!/^[A-Z0-9_]{1,20}$/.test(cd)){ _alertBox('코드는 영문 대문자·숫자·_ 1~20자입니다.', {icon:'⚠️'}); return; }
  if(!p.itemNm.trim()){ _alertBox('항목 이름을 넣으세요.', {icon:'⚠️'}); return; }
  if(isNew && _items.some(function(it){ return it.itemCd===cd; })){ _alertBox('이미 있는 코드입니다 — '+cd, {icon:'⚠️'}); return; }
  btn.disabled=true;
  post('/mangr/expenseItemSave.do', p, true)
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
    .then(function(){ ok((isNew?'항목을 추가했습니다 — ':'항목을 저장했습니다 — ')+cd); load(); })
    .catch(function(e){ btn.disabled=false; err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}

/* 셸이 이 화면을 다시 보여 줄 때 — 다른 화면(택배출고관리 운임·마감 확정)이 바뀌었을 수 있어 다시 읽는다 */
window.konetShown=function(){ if(!dirtyRows().length) load(); };
document.getElementById('ym').value=ymNow();
load();
</script>
</body>
</html>
