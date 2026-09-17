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
  · ★비용 내역 (2026-09-17 「기타경비 여기에서 등록 · 추가 발생 시 해당 월 목록에 추가 · 체크」) — 수기 항목마다 [＋ 내역]을 열면
    그 달 그 항목 아래 여러 줄(일자·내용·금액·비고·확인 체크)을 적는다(TBL_EXPENSE_DTL). 내역이 한 줄이라도 있으면 그 항목 금액 칸은
    <내역 합계>로 읽기 전용이 되고, 서버가 TBL_EXPENSE_TRX.AMT 를 그 합계로 굳힌다 — 마감 확정은 TRX 만 읽으므로 순마진까지 맞는다.
    「확인」 체크 = 지급·처리 표시(합계엔 영향 없음). 내역은 항목마다 [💾 내역 저장]으로 따로 굳힌다(위 [💾 저장]은 수기 금액·비고용).
    표가 아직 없으면(docs/sql/20260917_expense_dtl.sql 미실행) 내역 칸만 안내가 뜨고 나머지는 종전대로.
  · 자료 /mangr/expenseMonth.do(ym) · 저장 /mangr/expenseSave.do · 내역 /mangr/expenseDtlSave.do · 항목 /mangr/expenseItemSave.do
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
  table.g input.amt[readonly]{ background:#f3f6f8; color:#37475a; cursor:default; }
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
  /* ── 비용 내역(2026-09-17) — 항목 줄 아래 접히는 작은 표 ── */
  .lnk{ height:26px; padding:0 8px; font-size:12px; margin-left:6px; }
  .lnk.on{ background:#eef4f2; border-color:#9fc9bf; color:var(--teal); }
  table.g tr.dtlrow td{ background:#fbfcfd; padding:6px 9px 8px 26px; border-right:none; }
  table.g tr.dtlrow:hover td{ background:#fbfcfd; }
  table.d{ border-collapse:collapse; width:100%; max-width:980px; font-size:13px; }
  table.d th{ background:#f1f5f8; color:#37475a; font-weight:600; font-size:12px; padding:5px 7px; border-bottom:1px solid #dde4ec; border-right:none; text-align:center; white-space:nowrap; }
  table.d td{ padding:3px 5px; border-bottom:1px solid #eef1f5; border-right:none; text-align:center; }
  table.d input[type=text], table.d input[type=date]{ height:28px; font-size:13px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; width:100%; }
  table.d input.dam{ text-align:right; font-weight:700; font-variant-numeric:tabular-nums; }
  table.d input.chg{ background:#fffbe6; border-color:#e3c08a; }
  table.d input[type=checkbox]{ width:16px; height:16px; accent-color:var(--teal); cursor:pointer; }
  table.d tr.done td{ background:#f3faf7; }
  table.d tr.done input.dtt{ color:#7c8a98; text-decoration:line-through; }
  table.d tr[data-del="1"]{ display:none; }
  .dbar{ display:flex; gap:8px; align-items:center; margin:7px 0 0; font-size:12.5px; color:#5a6b7a; }
  .dbar .btn{ height:28px; padding:0 10px; font-size:12px; }
  .dbar b{ color:var(--teal); }
  .dwarn{ color:var(--amber); font-size:12.5px; }
</style>
</head>
<body>
<div class="wrap">
  <h2>💸 비용 등록</h2>
  <div class="sub">달마다 <b>비용</b>을 넣으면 마감현황·월별 마감이력의 <b>순마진 = 매출총이익(매출 − 매출원가) − 비용</b> 이 됩니다.
    <b>직송 택배 운임</b>은 택배출고관리의 직송 출고 × 사업장 운임으로 <b>자동</b>으로 세고(읽기 전용), 나머지는 실제 나간 돈(세포함)을 적습니다.
    <b>기타 경비</b>처럼 건건이 생기는 비용은 항목 옆 <b>[＋ 내역]</b>을 열어 일자·내용·금액을 줄로 적고, 추가로 생기면 그 달 목록에 줄을 더합니다.</div>
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
    <div class="hd">📅 <span id="ymTit">이 달 비용</span> <small>— 금액을 고치면 노란색, [💾 저장]으로 굳힙니다 · 내역은 항목마다 [💾 내역 저장]</small></div>
    <table class="g" id="grid">
      <thead><tr>
        <th style="width:230px">항목</th><th style="width:70px">구분</th><th style="width:170px">금액</th>
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
      · <b>자동 = PARCEL</b> 항목은 금액을 손으로 못 넣습니다 — 사업장 운임(택배출고관리)이나 회사 정보 수정 ▸ 기능 ▸ <b>기본 택배 운임</b>을 고치면 따라옵니다.<br>
      · <b>내역</b>이 있는 항목의 금액 = 내역 합계(읽기 전용). 내역의 <b>확인</b> 체크는 지급·처리 표시일 뿐 합계엔 영향 없습니다.</div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _items=[], _trx={}, _auto=null, _feeDef=4500, _closed=false, _ym='';
var _dtl={}, _dtlReady=true, _dtlOpen={};      // 비용 내역(2026-09-17) — itemCd → [줄], 표 준비 여부, 항목별 펼침
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
  var ymChanged = (ym!==_ym);
  _ym=ym;
  document.getElementById('ymTit').textContent=ym+' 비용';
  document.getElementById('body').innerHTML='<tr><td colspan="5" class="empty">조회 중…</td></tr>';
  post('/mangr/expenseMonth.do','ym='+encodeURIComponent(ym))
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return JSON.parse(t); }); })
    .then(function(j){
      if(ymVal()!==ym) return;                       // 그 사이 달을 또 바꿨으면 버린다
      _items=(j&&j.items)||[]; _auto=(j&&j.auto)||null; _feeDef=n(j&&j.feeDef)||4500;
      _trx={}; ((j&&j.trx)||[]).forEach(function(r){ _trx[String(r.itemCd||'')]=r; });
      _dtl={}; _dtlReady = !(j && j.dtlReady===false);
      ((j&&j.dtl)||[]).forEach(function(d){ var k=String(d.itemCd||''); (_dtl[k]=_dtl[k]||[]).push(d); });
      if(ymChanged){ _dtlOpen={}; for(var k in _dtl){ if(_dtl[k].length) _dtlOpen[k]=true; } }   // 내역이 있는 항목은 펼쳐서 시작
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
function dtlOf(cd){ return _dtl[cd]||[]; }
function dtlSum(ls){ var s=0; ls.forEach(function(d){ s+=n(d.amt); }); return s; }
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
    /* 수기 항목 — 내역이 있으면 금액 칸 = 내역 합계(읽기 전용). [＋ 내역]/[▼ 내역 n건] 으로 아래 표를 펼친다 */
    var ls=dtlOf(it.itemCd), has=ls.length>0, open=!!_dtlOpen[it.itemCd], dsum=dtlSum(ls);
    var amtCell = has
      ? '<input type="text" class="amt" data-cd="'+esc(it.itemCd)+'" value="'+fmt(dsum)+'" data-org="'+Math.round(dsum)+'" readonly title="내역 '+ls.length+'건의 합계입니다 — 금액은 아래 내역에서 고칩니다">'
      : '<input type="text" class="amt" data-cd="'+esc(it.itemCd)+'" value="'+(n(t.amt)?fmt(t.amt):'')+'" data-org="'+Math.round(n(t.amt))+'" placeholder="0" onfocus="this.select()" oninput="chg(this)" onblur="fmtIn(this)">';
    return '<tr id="row_'+esc(it.itemCd)+'"><td class="l"><b>'+esc(it.itemNm)+'</b>'
      +'<button class="btn lnk'+(open?' on':'')+'" id="dbtn_'+esc(it.itemCd)+'" onclick="dtlToggle(\''+esc(it.itemCd)+'\')" title="이 달 이 항목의 건별 내역(일자·내용·금액)">'+dtlBtnText(it.itemCd)+'</button></td>'
      +'<td><span class="gb '+esc(it.itemGb)+'">'+(it.itemGb==='FIX'?'고정':'변동')+'</span></td>'
      +'<td>'+amtCell+'</td>'
      +'<td><input type="text" class="rmk" data-cd="'+esc(it.itemCd)+'" value="'+esc(t.remark||'')+'" data-org="'+esc(t.remark||'')+'" placeholder="근거·메모" oninput="chg(this)"></td>'
      +'<td class="dim">'+esc(((t.updDttm||t.regDttm)||'').slice(0,16))+'</td></tr>'
      + dtlBlock(it, ls, open);
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
  if(!rows.length){ _alertBox('바꾼 금액이 없습니다.'+(dtlDirtyCds().length?'<br><span style="font-size:13px;color:#3d4d5c">내역은 항목 아래 <b>[💾 내역 저장]</b>으로 따로 굳힙니다.</span>':''), {icon:'ℹ️'}); return; }
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
/* 전월 복사 — 지난 달 수기 금액을 이 달 칸에 채운다(비고까지). 자동 항목·내역 있는 항목(읽기 전용)은 건너뛴다. 저장은 [저장]으로 */
function copyPrev(){
  var v=_ym||ymVal(); var d=new Date(Number(v.slice(0,4)), Number(v.slice(5,7))-2, 1);
  var pym=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2);
  post('/mangr/expenseMonth.do','ym='+encodeURIComponent(pym)).then(function(r){ return r.json(); })
    .then(function(j){
      var cnt=0; ((j&&j.trx)||[]).forEach(function(t){
        var a=document.querySelector('input.amt[data-cd="'+t.itemCd+'"]'); if(!a || a.readOnly) return;
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

/* ── 비용 내역 (2026-09-17) — 항목 줄 아래 접히는 표. 줄마다 일자·내용·금액·비고·확인 체크·✕.
     펼침/접기는 DOM 만 숨기고 보인다(다시 그리지 않는다 — 다른 칸에 적던 것이 안 날아가게).
     저장은 항목마다 [💾 내역 저장] — 그 달 그 항목의 줄을 통째로 보내고(새 줄·고친 줄·지운 줄), 서버가 금액 칸을 내역 합계로 굳힌다. */
function dtlBtnText(cd){ var ls=dtlOf(cd), open=!!_dtlOpen[cd]; return open ? '▲ 내역 접기' : (ls.length ? '▼ 내역 '+ls.length+'건' : '＋ 내역'); }
function dtlBlock(it, ls, open){
  var cd=esc(it.itemCd);
  if(!_dtlReady) return '<tr class="dtlrow" data-item="'+cd+'"'+(open?'':' hidden')+'><td colspan="5" class="l"><span class="dwarn">⚠ 내역 표(TBL_EXPENSE_DTL)가 아직 없습니다 — <b>docs/sql/20260917_expense_dtl.sql</b> 을 운영 DB에서 실행하면 열립니다. 그 전엔 금액을 위 칸에 한 줄로 적으세요.</span></td></tr>';
  return '<tr class="dtlrow" data-item="'+cd+'"'+(open?'':' hidden')+'><td colspan="5" class="l">'
    +'<table class="d"><thead><tr><th style="width:140px">일자</th><th style="min-width:200px">내용</th><th style="width:140px">금액</th><th style="min-width:180px">비고</th><th style="width:56px" title="지급·처리했으면 체크 (합계엔 영향 없음)">확인</th><th style="width:44px"></th></tr></thead>'
    +'<tbody id="dtb_'+cd+'">'+ls.map(dtlLine).join('')+'</tbody></table>'
    +'<div class="dbar"><button class="btn" onclick="dtlAdd(\''+cd+'\')">＋ 줄 추가</button>'
    +'<button class="btn btn-teal" onclick="dtlSave(\''+cd+'\')">💾 내역 저장</button>'
    +'<span id="dinf_'+cd+'">'+dtlInfoHtml(cd)+'</span></div></td></tr>';
}
function dtlLine(d){
  var raw=String(d.expDt||'').replace(/-/g,''), dt=raw.length===8 ? raw.slice(0,4)+'-'+raw.slice(4,6)+'-'+raw.slice(6,8) : '';
  return '<tr data-seq="'+n(d.dtlSeq)+'" class="'+(d.chkYn==='Y'?'done':'')+'">'
    +'<td><input type="date" class="ddt" value="'+dt+'" data-org="'+dt+'" onchange="dtlChg(this)"></td>'
    +'<td><input type="text" class="dtt" value="'+esc(d.title||'')+'" data-org="'+esc(d.title||'')+'" placeholder="내용 (예: 소모품 · 식대 · 수리비)" oninput="dtlChg(this)"></td>'
    +'<td><input type="text" class="dam" value="'+(n(d.amt)?fmt(d.amt):'')+'" data-org="'+Math.round(n(d.amt))+'" placeholder="0" onfocus="this.select()" oninput="dtlChg(this)" onblur="fmtIn(this)"></td>'
    +'<td><input type="text" class="drm" value="'+esc(d.remark||'')+'" data-org="'+esc(d.remark||'')+'" placeholder="근거·메모" oninput="dtlChg(this)"></td>'
    +'<td><input type="checkbox" class="dchk"'+(d.chkYn==='Y'?' checked':'')+' data-org="'+(d.chkYn==='Y'?'Y':'N')+'" onchange="dtlChk(this)" title="확인(지급·처리) 표시"></td>'
    +'<td><button class="btn lnk" style="margin:0" title="이 줄 지우기" onclick="dtlDel(this)">✕</button></td></tr>';
}
function dtlRowsLive(cd){   /* 화면에 있는 줄(지운 줄 제외) */
  var tb=document.getElementById('dtb_'+cd); if(!tb) return [];
  return Array.prototype.filter.call(tb.querySelectorAll('tr'), function(tr){ return tr.getAttribute('data-del')!=='1'; });
}
function dtlInfoHtml(cd){
  var trs=dtlRowsLive(cd), s=0, c=0;
  if(!trs.length){ var ls=dtlOf(cd); ls.forEach(function(d){ s+=n(d.amt); if(d.chkYn==='Y') c++; }); return ls.length ? (ls.length+'건 · 합계 <b>'+fmt(s)+'</b>원 · 확인 '+c+'/'+ls.length) : '아직 줄이 없습니다 — [＋ 줄 추가]'; }
  trs.forEach(function(tr){ s+=n((tr.querySelector('.dam')||{}).value); if((tr.querySelector('.dchk')||{}).checked) c++; });
  return trs.length+'건 · 합계 <b>'+fmt(s)+'</b>원 · 확인 '+c+'/'+trs.length+(dtlDirty(cd)?' <span style="color:#b45309">· 저장 안 됨</span>':'');
}
function dtlInfoRefresh(cd){ var e=document.getElementById('dinf_'+cd); if(e) e.innerHTML=dtlInfoHtml(cd); }
function dtlToggle(cd){
  _dtlOpen[cd]=!_dtlOpen[cd];
  var tr=document.querySelector('tr.dtlrow[data-item="'+cd+'"]'); if(tr) tr.hidden=!_dtlOpen[cd];
  var b=document.getElementById('dbtn_'+cd); if(b){ b.textContent=dtlBtnText(cd); b.classList.toggle('on', !!_dtlOpen[cd]); }
  if(_dtlOpen[cd] && !dtlRowsLive(cd).length && _dtlReady) dtlAdd(cd);   // 처음 여는 빈 내역이면 줄 하나를 바로 준다
}
function dtlChg(el){
  var org=el.getAttribute('data-org')||''; var cur=el.classList.contains('dam') ? String(Math.round(n(el.value))) : el.value;
  el.classList.toggle('chg', cur!==org);
  dtlInfoRefresh(el.closest('tr.dtlrow').getAttribute('data-item'));
}
function dtlChk(el){ var tr=el.closest('tr'); tr.classList.toggle('done', el.checked); el.classList.toggle('chg', (el.checked?'Y':'N')!==(el.getAttribute('data-org')||'N')); dtlInfoRefresh(el.closest('tr.dtlrow').getAttribute('data-item')); }
function dtlDel(btn){
  var tr=btn.closest('tr'), cd=btn.closest('tr.dtlrow').getAttribute('data-item');
  if(n(tr.getAttribute('data-seq'))>0) tr.setAttribute('data-del','1'); else tr.parentNode.removeChild(tr);   // 저장된 줄은 숨겨 두었다가 저장 때 지운다
  dtlInfoRefresh(cd);
}
function dtlAdd(cd){
  var tb=document.getElementById('dtb_'+cd); if(!tb) return;
  var today=new Date(), ty=today.getFullYear()+'-'+('0'+(today.getMonth()+1)).slice(-2);
  var dt = (ty===_ym) ? (ty+'-'+('0'+today.getDate()).slice(-2)) : (_ym+'-01');     // 이 달이면 오늘, 아니면 그 달 1일
  var tmp=document.createElement('tbody'); tmp.innerHTML=dtlLine({ dtlSeq:0, expDt:dt.replace(/-/g,''), title:'', amt:0, remark:'', chkYn:'N' });
  var tr=tmp.firstChild; tr.querySelector('.ddt').setAttribute('data-org',''); tr.querySelector('.ddt').classList.add('chg');
  tb.appendChild(tr); dtlInfoRefresh(cd);
  var f=tr.querySelector('.dtt'); if(f) f.focus();
}
function dtlDirty(cd){
  var tb=document.getElementById('dtb_'+cd); if(!tb) return false;
  if(tb.querySelector('tr[data-del="1"]')) return true;
  return !!tb.querySelector('.chg') || !!tb.querySelector('tr[data-seq="0"]');
}
function dtlDirtyCds(){ var a=[]; for(var cd in _dtl){ if(dtlDirty(cd)) a.push(cd); } _items.forEach(function(it){ if(a.indexOf(it.itemCd)<0 && dtlDirty(it.itemCd)) a.push(it.itemCd); }); return a; }
function dtlSave(cd){
  var tb=document.getElementById('dtb_'+cd); if(!tb) return;
  var rows=[], bad=0;
  Array.prototype.forEach.call(tb.querySelectorAll('tr'), function(tr){
    var seq=n(tr.getAttribute('data-seq'));
    if(tr.getAttribute('data-del')==='1'){ if(seq>0) rows.push({ dtlSeq:seq, del:'Y' }); return; }
    var dt=(tr.querySelector('.ddt')||{}).value||'', tt=((tr.querySelector('.dtt')||{}).value||'').trim(), am=Math.round(n((tr.querySelector('.dam')||{}).value)), rm=((tr.querySelector('.drm')||{}).value||'').trim(), ck=(tr.querySelector('.dchk')||{}).checked?'Y':'N';
    if(!seq && !tt && !am && !rm) return;                      // 아무것도 안 적은 새 줄은 보내지 않는다
    if(!tt && !am){ bad++; return; }
    rows.push({ dtlSeq:seq, expDt:dt, title:tt, amt:am, remark:rm, chkYn:ck });
  });
  if(bad){ _alertBox('내용이나 금액이 비어 있는 줄이 '+bad+'개 있습니다 — 채우거나 ✕ 로 지우세요.', {icon:'⚠️'}); return; }
  if(!rows.length){ _alertBox('저장할 내역이 없습니다.', {icon:'ℹ️'}); return; }
  var go = _closed
    ? ask('<b>'+_ym+'</b> 은 <b>마감 확정</b>된 달입니다.<br><span style="font-size:13px;color:#3d4d5c">내역을 저장해도 확정된 순마진은 그대로입니다 — 마감현황에서 <b>다시 확정</b>해야 반영됩니다.</span>', '그래도 저장')
    : Promise.resolve(true);
  go.then(function(y){ if(!y) return;
    post('/mangr/expenseDtlSave.do', { ym:_ym, itemCd:cd, rows:rows }, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(){ ok(cd+' 내역 '+rows.length+'줄을 저장했습니다 — 금액 칸이 내역 합계로 맞춰집니다'); _dtlOpen[cd]=true; load(); })
      .catch(function(e){ err('내역을 저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
  });
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

/* 셸이 이 화면을 다시 보여 줄 때 — 다른 화면(택배출고관리 운임·마감 확정)이 바뀌었을 수 있어 다시 읽는다. 적다 만 것(금액·내역)이 있으면 안 읽는다 */
window.konetShown=function(){ if(!dirtyRows().length && !dtlDirtyCds().length) load(); };
document.getElementById('ym').value=ymNow();
load();
</script>
</body>
</html>
