<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- ★날짜 칸에 [◀][▶][오늘] 을 자동으로 붙인다 (2026-08-17 요청) — 화면 수정 0.
     브라우저 기본 달력의 ↑↓ 는 앞/뒤가 안 읽혀 엉뚱한 달로 넘어가는 일이 잦았다.
     빼려면 그 칸에 data-nonav="1" --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
<title>출금 / 미지급 (TBL_PAYMENT_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  .swal2-popup:not(.swal2-toast){ width:440px!important; padding:1.1em 1em 1.2em!important; font-size:14px; }
  .swal2-popup:not(.swal2-toast) .swal2-icon{ width:3em; height:3em; margin:.6em auto .3em; }
  .swal2-popup:not(.swal2-toast) .swal2-title{ font-size:18px; padding:.4em 1em 0; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input,.bar select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; }
  .bar input.search{ width:220px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:auto; color:#6b7a89; font-size:12.5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  table{ width:100%; border-collapse:collapse; font-size:12.5px; white-space:nowrap; }
  thead th{ background:#b9ded4; color:#0b4f43; font-weight:800; font-size:14px; box-shadow:inset 0 -2px 0 #0e6657; padding:9px 10px; text-align:left; position:sticky; top:0; z-index:1; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:6px 10px; }
  tbody tr:hover td{ background:#f3f8f6; }
  td.num{ text-align:right; }
  td.nm{ white-space:normal; min-width:160px; }
  .badge{ display:inline-block; padding:1px 9px; border-radius:10px; font-size:11px; font-weight:800; color:#fff; }
  .act .btn{ height:26px; padding:0 9px; font-size:11.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  .sumrow td{ background:#f1f5f4; font-weight:800; }
  .pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin-top:14px; flex-wrap:wrap; }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  #ov .box{ background:#fff; width:min(620px,94vw); margin-top:5vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; } #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:16px 18px; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px; }
  #ov .fld{ display:flex; flex-direction:column; gap:4px; } #ov .fld.full{ grid-column:1 / -1; }
  #ov label{ font-size:12px; font-weight:700; color:#37475a; }
  #ov input,#ov select,#ov textarea{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; font-family:inherit; }
  #ov textarea{ height:auto; padding:6px 8px; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
</style>
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
</head>
<body>
<div class="wrap">
  <h2>💸 출금 / 미지급 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(TBL_PAYMENT_MST)</span></h2>
  <div class="sub">매입처별 월 미지급금 현황 · 출금 등록/수정/삭제 · 엑셀 업로드/다운로드</div>

  <div class="bar">
    <label>귀속월 <input type="month" id="ym"></label>
    <input type="text" class="search" id="q" placeholder="매입처 검색" onkeyup="if(event.keyCode===13)payLoad()">
    <button class="btn" onclick="payLoad()">↻ 조회</button>
    <button class="btn" id="btnCarry" onclick="payCarry()" title="전월 미지급잔액을 이번 달 전월이월로 가져옵니다">🔄 전월이월 가져오기</button>
    <button class="btn btn-teal" id="btnAdd" onclick="payOpen()">＋ 출금 추가</button>
    <button class="btn" id="btnUp" onclick="document.getElementById('xlsFile').click()">📤 엑셀 업로드</button>
    <button class="btn" onclick="payExcel()">📥 엑셀 출력</button>
    <button class="btn" id="btnLock" onclick="payLockToggle()">🔒 마감 확정</button>
    <input type="file" id="xlsFile" accept=".xlsx,.xls" style="display:none" onchange="payUpload(this)">
    <span class="cnt" id="cnt">0건</span>
  </div>
  <div id="lockBar" style="display:none; margin:-4px 0 12px; padding:8px 12px; border-radius:8px; background:#fdecea; border:1px solid #f5c6c0; color:#a3372b; font-weight:700; font-size:12.5px;">🔒 <span id="lockTxt"></span></div>

  <div class="card">
    <table>
      <thead><tr>
        <th>귀속월</th><th>매입처코드</th><th>매입처명</th>
        <th style="text-align:right">전월이월</th><th style="text-align:right">당월매입</th><th style="text-align:right">당월출금</th><th style="text-align:right">미지급잔액</th><th>상태</th><th style="width:110px">관리</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="9" class="empty">조회하세요.</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
  <div class="sub" style="margin-top:8px">※ 미지급잔액 = 전월이월 + 당월매입 − 당월출금. 엑셀업로드는 <b>선택한 귀속월</b>에 (매입처코드+명+전월이월+당월매입+당월출금) 헤더로 반영됩니다.</div>
</div>

<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">출금 추가</b><button class="x" onclick="payClose()">&times;</button></div>
    <div class="mb">
      <input type="hidden" id="f_seq">
      <div class="fld"><label>귀속월 *</label><input type="month" id="f_ym"></div>
      <div class="fld"><label>매입처코드 *</label><input id="f_bizcd"></div>
      <div class="fld full"><label>매입처명</label><input id="f_biznm"></div>
      <div class="fld"><label>전월이월</label><input type="number" id="f_prev" value="0"></div>
      <div class="fld"><label>당월매입</label><input type="number" id="f_purch" value="0"></div>
      <div class="fld"><label>당월출금</label><input type="number" id="f_payout" value="0"></div>
      <div class="fld"><label>지급방법</label><select id="f_pay"><option value="">-</option><option>현금</option><option>계좌이체</option><option>카드</option><option>어음</option></select></div>
      <div class="fld"><label>출금일자</label><input type="date" id="f_pdt"></div>
      <div class="fld full"><label>비고</label><textarea id="f_remark" rows="2"></textarea></div>
    </div>
    <div class="mf"><button class="btn" onclick="payClose()">취소</button><button class="btn btn-teal" onclick="paySave()">💾 저장</button></div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var LIST=[], _view=[], _page=1, PAGE=20, _byseq={}, _locked=false;
function toast(s){ if(window.Swal) Swal.fire({toast:true,position:'top-end',html:s,showConfirmButton:false,timer:2500,timerProgressBar:true}); }
function swConfirm(m,t){ if(window.Swal) return Swal.fire({title:t||'확인',html:m,icon:'question',showCancelButton:true,confirmButtonText:'확인',cancelButtonText:'취소',confirmButtonColor:'#137a6c',cancelButtonColor:'#94a3b8'}).then(function(r){return r.isConfirmed;}); return Promise.resolve(confirm(m)); }
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function num(v){ return (v==null||v==='')?'0':Math.round(Number(v)).toLocaleString(); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function gnum(id){ var v=gv(id); return v===''?null:Number(v); }
function fmtYm(s){ s=(''+(s||'')); return s.length===6?s.slice(0,4)+'-'+s.slice(4,6):s; }

(function(){ var d=new Date(); document.getElementById('ym').value=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2); })();

function payLoad(){
  var ym=gv('ym'), q=gv('q');
  payCloseChk();
  fetch(CTX+'/mangr/paymentList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'payYm='+encodeURIComponent(ym)+'&findData='+encodeURIComponent(q) })
    .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ toast('⚠️ 응답 오류'); return; }
      LIST=(j&&j.data)||[]; _byseq={}; LIST.forEach(function(o){ _byseq[o.paySeq]=o; }); _view=LIST.slice(); _page=1; payRender();
    }).catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
// ── 마감 상태 조회/표시 ──
function payCloseChk(){
  var ym=gv('ym'); if(!ym){ return; }
  fetch(CTX+'/mangr/paymentCloseStatus.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({payYm:ym}) })
    .then(function(r){ return r.json(); }).then(function(j){ _locked=!!(j&&j.closed); payLockRender(j||{}); }).catch(function(){});
}
function payLockRender(j){
  var lock=document.getElementById('btnLock'), bar=document.getElementById('lockBar');
  ['btnCarry','btnAdd','btnUp'].forEach(function(id){ var b=document.getElementById(id); if(b){ b.disabled=_locked; b.style.opacity=_locked?'.45':''; b.style.cursor=_locked?'not-allowed':'pointer'; } });
  if(_locked){
    lock.textContent='🔓 마감 해제'; lock.style.background='#c0392b'; lock.style.color='#fff'; lock.style.borderColor='#c0392b';
    bar.style.display='block'; document.getElementById('lockTxt').textContent=fmtYm(gv('ym'))+' 마감 확정됨 — 수정/삭제/업로드/이월이 잠겼습니다.'+(j.confirmDttm?(' (확정: '+j.confirmDttm+(j.confirmUser?' / '+j.confirmUser:'')+')'):'');
  } else {
    lock.textContent='🔒 마감 확정'; lock.style.background=''; lock.style.color=''; lock.style.borderColor='';
    bar.style.display='none';
  }
}
function payLockToggle(){
  var ym=gv('ym'); if(!ym){ toast('⚠️ 귀속월을 먼저 선택하세요.'); return; }
  if(_locked){
    swConfirm('<b>'+fmtYm(ym)+'</b> 마감을 <b>해제</b>하시겠습니까?<br>해제하면 다시 수정할 수 있습니다.','🔓 마감 해제').then(function(ok){ if(!ok) return;
      fetch(CTX+'/mangr/paymentCancel.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({payYm:ym}) })
        .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
        .then(function(r){ if(!r.ok){ toast('⚠️ 해제 실패: '+((r.t||'').trim())); return; } toast('🔓 마감 해제'); payLoad(); });
    });
  } else {
    swConfirm('<b>'+fmtYm(ym)+'</b> 월을 <b>마감 확정</b>하시겠습니까?<br>확정 후 이 달은 수정 잠금 + 미지급잔액이 다음 달 전월이월로 자동 반영됩니다.','🔒 마감 확정').then(function(ok){ if(!ok) return;
      fetch(CTX+'/mangr/paymentConfirm.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({payYm:ym}) })
        .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
        .then(function(r){ if(!r.ok){ toast('⚠️ 확정 실패: '+((r.t||'').trim())); return; } toast('🔒 '+fmtYm(ym)+' 마감 확정 완료'); payLoad(); });
    });
  }
}
function _due(o){ return (+o.prevAmt||0)+(+o.purchAmt||0)-(+o.payoutAmt||0); }
function payRender(){
  var tot=_view.length, pages=Math.max(1,Math.ceil(tot/PAGE)); if(_page>pages)_page=pages;
  document.getElementById('cnt').textContent=tot.toLocaleString()+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="9" class="empty">데이터가 없습니다.</td></tr>'; _pager(0,1); return; }
  var rows=_view.slice((_page-1)*PAGE,(_page-1)*PAGE+PAGE);
  var tP=0,tU=0,tO=0,tD=0;
  var html=rows.map(function(o){
    var due=_due(o); tP+=(+o.prevAmt||0); tU+=(+o.purchAmt||0); tO+=(+o.payoutAmt||0); tD+=due;
    var bd = due>0 ? '<span class="badge" style="background:#c0392b">미지급</span>' : '<span class="badge" style="background:#137a6c">완납</span>';
    return '<tr><td>'+fmtYm(o.payYm)+'</td><td>'+esc(o.bizCd)+'</td><td class="nm">'+esc(o.bizNm)+'</td>'
      +'<td class="num">'+num(o.prevAmt)+'</td><td class="num">'+num(o.purchAmt)+'</td><td class="num">'+num(o.payoutAmt)+'</td>'
      +'<td class="num" style="font-weight:700;color:'+(due>0?'#c0392b':'#137a6c')+'">'+num(due)+'</td><td>'+bd+'</td>'
      +'<td class="act"><button class="btn" onclick="payOpen('+o.paySeq+')">수정</button> <button class="btn btn-danger" onclick="payDel('+o.paySeq+')">삭제</button></td></tr>';
  }).join('');
  html+='<tr class="sumrow"><td colspan="3">합계</td><td class="num">'+num(tP)+'</td><td class="num">'+num(tU)+'</td><td class="num">'+num(tO)+'</td><td class="num">'+num(tD)+'</td><td colspan="2"></td></tr>';
  tb.innerHTML=html; _pager(pages,_page);
}
function _go(p){ _page=p; payRender(); }
function _pager(pages,cur){ var el=document.getElementById('pager'); if(pages<=1){ el.innerHTML=''; return; }
  var h='<button '+(cur<=1?'disabled':'')+' onclick="_go('+(cur-1)+')">‹</button>';
  var from=Math.max(1,cur-3), to=Math.min(pages,cur+3);
  if(from>1){ h+='<button onclick="_go(1)">1</button>'; if(from>2)h+='<span class="ell">…</span>'; }
  for(var p=from;p<=to;p++) h+='<button class="'+(p===cur?'on':'')+'" onclick="_go('+p+')">'+p+'</button>';
  if(to<pages){ if(to<pages-1)h+='<span class="ell">…</span>'; h+='<button onclick="_go('+pages+')">'+pages+'</button>'; }
  h+='<button '+(cur>=pages?'disabled':'')+' onclick="_go('+(cur+1)+')">›</button>'; el.innerHTML=h;
}
function _set(id,v){ document.getElementById(id).value=(v==null?'':v); }
function payOpen(seq){
  if(_locked){ toast('🔒 마감된 월입니다. 마감을 해제한 뒤 수정하세요.'); return; }
  var o=seq!=null?_byseq[seq]:null;
  document.getElementById('ovTit').textContent=o?'출금 수정':'출금 추가';
  _set('f_seq',o?o.paySeq:''); _set('f_ym',o?fmtYm(o.payYm):gv('ym'));
  _set('f_bizcd',o?o.bizCd:''); document.getElementById('f_bizcd').readOnly=!!o;
  _set('f_biznm',o?o.bizNm:''); _set('f_prev',o?(o.prevAmt||0):0); _set('f_purch',o?(o.purchAmt||0):0); _set('f_payout',o?(o.payoutAmt||0):0);
  _set('f_pay',o?o.payGb:''); _set('f_pdt',o?(o.payoutDt&&o.payoutDt.length===8?o.payoutDt.slice(0,4)+'-'+o.payoutDt.slice(4,6)+'-'+o.payoutDt.slice(6,8):''):''); _set('f_remark',o?o.remark:'');
  document.getElementById('ov').classList.add('on');
}
function payClose(){ document.getElementById('ov').classList.remove('on'); }
function paySave(){
  var seq=gv('f_seq'), ym=gv('f_ym'), cd=gv('f_bizcd');
  if(!ym){ toast('⚠️ 귀속월을 선택하세요.'); return; }
  if(!cd){ toast('⚠️ 매입처코드를 입력하세요.'); return; }
  var dto={ payYm:ym, bizCd:cd, bizNm:gv('f_biznm')||null, prevAmt:gnum('f_prev'), purchAmt:gnum('f_purch'), payoutAmt:gnum('f_payout'),
    payGb:gv('f_pay')||null, payoutDt:gv('f_pdt')||null, remark:gv('f_remark')||null };
  var isEdit=!!seq; if(isEdit) dto.paySeq=Number(seq);
  fetch(CTX+(isEdit?'/mangr/paymentUpdate.do':'/mangr/paymentInsert.do'), { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('⚠️ '+((r.t||'').trim()||'저장 실패')); return; } payClose(); toast(isEdit?'💾 수정 완료':'＋ 등록 완료'); payLoad(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function payDel(seq){ var o=_byseq[seq]; if(!o) return;
  if(_locked){ toast('🔒 마감된 월입니다. 마감을 해제한 뒤 삭제하세요.'); return; }
  swConfirm(fmtYm(o.payYm)+' · ['+esc(o.bizCd)+'] '+esc(o.bizNm||'')+'<br>삭제하시겠습니까?','출금 삭제').then(function(ok){ if(!ok) return;
    fetch(CTX+'/mangr/paymentDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({paySeq:Number(seq),payYm:o.payYm}) })
      .then(function(res){ return res.text(); }).then(function(){ toast('🗑️ 삭제 완료'); payLoad(); });
  });
}
// ── 전월이월 자동이월 (전월 미지급잔액 → 당월 전월이월) ──
function payCarry(){
  if(_locked){ toast('🔒 마감된 월입니다. 마감을 해제한 뒤 이월하세요.'); return; }
  var ym=gv('ym'); if(!ym){ toast('⚠️ 귀속월을 먼저 선택하세요.'); return; }
  var d=new Date(ym+'-01'); d.setMonth(d.getMonth()-1); var pm=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2);
  swConfirm('<b>'+pm+'</b> 미지급잔액을 <b>'+ym+'</b> 전월이월로 가져옵니다.<br>(기존 '+ym+' 전월이월 값은 덮어씁니다) 진행할까요?','전월이월 가져오기').then(function(ok){ if(!ok) return;
    fetch(CTX+'/mangr/paymentCarryForward.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({payYm:ym}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
      .then(function(r){ if(!r.ok){ toast('⚠️ 이월 실패: '+((r.t||'').trim())); return; } toast('🔄 '+r.t+'개 매입처 전월이월 반영'); payLoad(); });
  });
}
// ── 엑셀 업로드 (매입처코드/매입처명/전월이월/당월매입/당월출금 → 선택 귀속월에 upsert) ──
function payUpload(inp){
  var f=inp.files&&inp.files[0]; inp.value=''; if(!f) return;
  if(_locked){ toast('🔒 마감된 월입니다. 마감을 해제한 뒤 업로드하세요.'); return; }
  var ym=gv('ym'); if(!ym){ toast('⚠️ 귀속월을 먼저 선택하세요.'); return; }
  var rd=new FileReader();
  rd.onload=function(e){
    try{
      var wb=XLSX.read(new Uint8Array(e.target.result),{type:'array'});
      var ws=wb.Sheets[wb.SheetNames[0]], aoa=XLSX.utils.sheet_to_json(ws,{header:1,defval:''});
      if(!aoa.length){ toast('⚠️ 빈 파일'); return; }
      var h=aoa[0].map(function(x){ return (''+x).replace(/\s/g,''); });
      function col(){ for(var i=0;i<arguments.length;i++){ var k=arguments[i]; for(var c=0;c<h.length;c++){ if(h[c].indexOf(k)>=0) return c; } } return -1; }
      var cCd=col('매입처코드','거래처코드','코드'), cNm=col('매입처명','거래처명','거래처'), cP=col('전월이월'), cU=col('당월매입','매입'), cO=col('당월출금','출금','지급');
      if(cCd<0){ toast('⚠️ 헤더에 "매입처코드"가 필요합니다.'); return; }
      var rows=[];
      for(var r=1;r<aoa.length;r++){ var a=aoa[r]; var bc=(''+(a[cCd]||'')).trim(); if(!bc) continue;
        rows.push({ payYm:ym, bizCd:bc, bizNm:cNm>=0?(''+(a[cNm]||'')).trim():null,
          prevAmt:cP>=0?Number((''+a[cP]).replace(/[^0-9.-]/g,''))||0:0,
          purchAmt:cU>=0?Number((''+a[cU]).replace(/[^0-9.-]/g,''))||0:0,
          payoutAmt:cO>=0?Number((''+a[cO]).replace(/[^0-9.-]/g,''))||0:0 }); }
      if(!rows.length){ toast('⚠️ 데이터 행이 없습니다.'); return; }
      swConfirm(fmtYm(ym)+' 귀속월에 <b>'+rows.length+'</b>건을 업로드(덮어쓰기)하시겠습니까?','엑셀 업로드').then(function(ok){ if(!ok) return;
        fetch(CTX+'/mangr/paymentUpload.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(rows) })
          .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
          .then(function(r){ if(!r.ok){ toast('⚠️ 업로드 실패: '+((r.t||'').trim())); return; } toast('📤 '+r.t+'건 반영 완료'); payLoad(); });
      });
    }catch(err){ toast('⚠️ 엑셀 파싱 오류: '+err.message); }
  };
  rd.readAsArrayBuffer(f);
}
function payExcel(){
  var list=_view; if(!list.length){ toast('⚠️ 출력할 데이터가 없습니다.'); return; }
  var head=['귀속월','매입처코드','매입처명','전월이월','당월매입','당월출금','미지급잔액','상태','지급방법','출금일자','비고'];
  var aoa=[head].concat(list.map(function(o){ var due=_due(o); return [fmtYm(o.payYm),o.bizCd,o.bizNm,o.prevAmt,o.purchAmt,o.payoutAmt,due,(due>0?'미지급':'완납'),o.payGb,o.payoutDt,o.remark]; }));
  var ws=XLSX.utils.aoa_to_sheet(aoa), wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb,ws,'출금미지급'); XLSX.writeFile(wb,'출금미지급.xlsx'); toast('📥 엑셀 저장 완료 · '+list.length+'건');
}
payLoad();
</script>
</body>
</html>
