<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>창고 관리</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창 — 브라우저 alert 금지 --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<!--
  창고 관리 · 창고 이동 (2026-09-16 신설, P3 창고별 재고 1단계 — 사용자 「창고는 3개 · 설정할 수 있게」) — 물품동선관리 ▸ 창고 관리. 셸 iframe(logiFrame).
  · 위 = 창고 목록(TBL_WH_MST) : 이름·기본창고·차례·사용 을 고치고 새 창고를 더한다. 코드는 한 번 만들면 못 바꾼다(원장 행이 코드에 매달린다).
    기본창고 = 출고 자동연동(발주현황표·정산서)과 창고를 안 고른 전표가 쓰는 창고. 회사마다 하나.
  · 아래 = 창고 이동 : 보내는 창고 −수량 · 받는 창고 +수량 을 원장(TBL_STOCK_LEDGER)에 A 행 한 쌍(REF_GB='MOVE')으로 남긴다.
    전체 재고는 안 변하고 창고별 숫자만 옮겨진다. 취소 = 그 쌍을 되돌린다(소프트 삭제).
  · 자료 /prod/whList.do · whSave.do · stockMoveList.do · stockMoveSave.do · stockMoveCancel.do
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:12px; font-size:12.5px; line-height:1.6; }
  .sub b{ color:var(--teal); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .bar{ display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; padding:10px 12px; border-bottom:1px solid #eef1f5; }
  .fld{ display:flex; flex-direction:column; gap:3px; position:relative; }
  .fld label{ font-size:11.5px; font-weight:700; color:#5a6b7a; }
  .fld input, .fld select{ height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13.5px; background:#fff; }
  .btn{ height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  table.g{ border-collapse:collapse; width:100%; font-size:13.5px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:8px 9px; text-align:center; white-space:nowrap; }
  table.g th:last-child, table.g td:last-child{ border-right:none; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:5px 9px; vertical-align:middle; text-align:center; }
  table.g td.l{ text-align:left; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g tr:hover td{ background:#f7faf9; }
  table.g input[type=text], table.g input[type=number]{ height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 7px; font-size:13.5px; width:100%; }
  table.g select{ height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 5px; font-size:13px; background:#fff; }
  .def{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; background:#e8f4f1; color:#137a6c; }
  .off td{ opacity:.55; }
  .dim{ color:#8a98a8; }
  .empty{ padding:30px; text-align:center; color:#8a98a8; }
  .note{ font-size:12.5px; color:#5a6b7a; line-height:1.7; padding:8px 12px; }
  .note b{ color:#37475a; }
  /* 품목명 표시는 칸 아래 떠 있게(absolute) — 칸 높이에 안 끼어야 품목코드 칸이 옆 칸들과 같은 선상에 선다(2026-09-16 사용자 지적) */
  .pnm{ position:absolute; top:100%; left:0; margin-top:2px; font-size:12px; color:var(--teal); font-weight:700; white-space:nowrap; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🏬 창고 관리</h2>
  <div class="sub"><b>기본창고</b> = 출고 자동연동(발주현황표·정산서)과 창고를 안 고른 전표가 쓰는 창고. 매입·판매 전표와 재고 일괄조정은 전표마다 창고를 고릅니다.
    창고 사이에 물건을 옮기면 아래 <b>창고 이동</b>으로 — 전체 재고는 그대로, 창고별 숫자만 옮겨집니다.</div>

  <div class="card">
    <div class="hd">🏬 창고 목록 <small>— 코드는 한 번 만들면 못 바꿉니다(원장이 코드에 매달립니다). 안 쓰는 창고는 「사용」을 끕니다(재고가 남아 있으면 못 끕니다)</small></div>
    <table class="g" id="whGrid">
      <thead><tr><th style="width:120px">코드</th><th style="min-width:200px">이름</th><th style="width:90px">기본창고</th><th style="width:80px">차례</th><th style="width:70px">사용</th><th style="width:110px">현재고 합계</th><th style="width:90px"></th></tr></thead>
      <tbody id="whBody"><tr><td colspan="7" class="empty">조회 중…</td></tr></tbody>
    </table>
  </div>

  <%-- 창고 2단계 (2026-09-16) — 출고장(삼성 센터) → 창고. 발주현황표·정산서 출고가 어느 창고에서 빠지는지. 비면 기본창고 --%>
  <div class="card">
    <div class="hd">🚚 출고장 → 창고 <small>— 그 센터로 나가는 물건이 어느 창고에서 빠지는지(발주현황표·정산서 출고 자동연동). 비우면 기본창고. 저장 뒤 업로드·재동기화되는 날짜부터 적용</small></div>
    <table class="g" id="dcGrid">
      <thead><tr><th style="width:90px">출고장</th><th style="min-width:160px">지역</th><th style="width:120px">묶음</th><th style="width:200px">출고 창고</th><th style="width:90px"></th></tr></thead>
      <tbody id="dcBody"><tr><td colspan="5" class="empty">조회 중…</td></tr></tbody>
    </table>
  </div>

  <div class="card">
    <div class="hd">🔁 창고 이동 <small>— 보내는 창고에서 빼고 받는 창고에 더합니다(원장 A 행 한 쌍, REF_GB=MOVE)</small></div>
    <div class="bar">
      <div class="fld"><label>이동일자</label><input type="date" id="mvDt"></div>
      <div class="fld"><label>보내는 창고</label><select id="mvFrom"></select></div>
      <div class="fld"><label>받는 창고</label><select id="mvTo"></select></div>
      <div class="fld" style="width:180px"><label>품목코드</label><input type="text" id="mvProd" placeholder="품목코드" onblur="prodLookup()" onkeydown="if(event.key==='Enter'){ prodLookup(); }"><div class="pnm" id="mvProdNm"></div></div>
      <div class="fld" style="width:110px"><label>수량(EA)</label><input type="number" id="mvQty" min="1" step="1" style="text-align:right"></div>
      <div class="fld" style="width:260px"><label>비고</label><input type="text" id="mvRmk" placeholder="사유·메모"></div>
      <button class="btn btn-teal" id="mvBtn" onclick="moveSave()">🔁 이동 등록</button>
      <span style="margin-left:auto"></span>
      <div class="fld"><label>이동 내역 기간</label><span><input type="date" id="mvFr"> ~ <input type="date" id="mvToDt"> <button class="btn" onclick="moveList()">조회</button></span></div>
    </div>
    <table class="g" id="mvGrid">
      <thead><tr><th style="width:100px">이동일자</th><th style="width:120px">품목코드</th><th style="min-width:200px">품목명</th><th style="width:120px">보내는 창고</th><th style="width:120px">받는 창고</th><th style="width:90px">수량</th><th style="min-width:180px">비고</th><th style="width:140px">등록</th><th style="width:70px"></th></tr></thead>
      <tbody id="mvBody"><tr><td colspan="9" class="empty">조회 중…</td></tr></tbody>
    </table>
    <div class="note">· 이동 수량은 <b>EA</b>(합계수량)입니다. 보내는 창고에 재고가 모자라도 막지 않고 <b>확인창</b>만 띄웁니다(창고별 숫자가 음수로 갈 수 있습니다 — 재고 일괄조정으로 맞추세요).<br>
      · 취소하면 그 이동의 두 줄이 되돌아갑니다. 마감 확정된 달(재고 수불 잠금)은 서버가 막습니다.</div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _wh=[], _whQty={};
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin',
  headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }
function ok(m){ if(window._toast) _toast(m,'success'); else _alertBox(m,{icon:'✅'}); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function ask(m, okText, red){ return new Promise(function(res){ var o={ msg:m, icon:'❓', okText:okText||'확인', onOk:function(){res(true);}, onCancel:function(){res(false);} }; if(red) o.okColor='red'; _confirmBox(o); }); }
function whNmOf(cd){ var w=_wh.filter(function(x){ return x.whCd===cd; })[0]; return w ? w.whNm : (cd||''); }

/* ── 창고 목록 ── */
function whLoad(){
  post('/prod/whList.do','').then(function(r){ return r.json(); })
    .then(function(j){ _wh=(j&&j.data)||[]; _whQty=(j&&j.qty)||{}; renderWh(); fillMoveSel(); dcLoad(); })
    .catch(function(e){ document.getElementById('whBody').innerHTML='<tr><td colspan="7" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function renderWh(){
  var tb=document.getElementById('whBody');
  tb.innerHTML=_wh.map(function(w){
    return '<tr class="'+(w.useYn==='Y'?'':'off')+'" data-cd="'+esc(w.whCd)+'"><td><b>'+esc(w.whCd)+'</b></td>'
      +'<td><input type="text" class="wnm" value="'+esc(w.whNm)+'"></td>'
      +'<td><select class="wdef"><option value="N"'+(w.defaultYn!=='Y'?' selected':'')+'>—</option><option value="Y"'+(w.defaultYn==='Y'?' selected':'')+'>기본</option></select></td>'
      +'<td><input type="number" class="wso" value="'+n(w.sortOrd)+'" style="text-align:right"></td>'
      +'<td><select class="wuse"><option value="Y"'+(w.useYn==='Y'?' selected':'')+'>예</option><option value="N"'+(w.useYn!=='Y'?' selected':'')+'>아니오</option></select></td>'
      +'<td class="r">'+fmt(_whQty[w.whCd]||0)+'</td>'
      +'<td><button class="btn" style="height:28px;padding:0 10px;font-size:12px" onclick="whSave(this)">저장</button></td></tr>';
  }).join('')
  +'<tr data-new="1"><td><input type="text" class="wcd" placeholder="새 코드 (영문·숫자)" style="text-transform:uppercase"></td>'
  +'<td><input type="text" class="wnm" placeholder="새 창고 이름"></td>'
  +'<td><select class="wdef"><option value="N">—</option><option value="Y">기본</option></select></td>'
  +'<td><input type="number" class="wso" value="50" style="text-align:right"></td><td><select class="wuse"><option value="Y">예</option><option value="N">아니오</option></select></td><td></td>'
  +'<td><button class="btn btn-teal" style="height:28px;padding:0 10px;font-size:12px" onclick="whSave(this)">＋ 추가</button></td></tr>';
}
function whSave(btn){
  var tr=btn.closest('tr'), isNew=!!tr.getAttribute('data-new');
  var cd=isNew ? String((tr.querySelector('.wcd')||{}).value||'').trim().toUpperCase() : tr.getAttribute('data-cd');
  var p={ whCd:cd, whNm:(tr.querySelector('.wnm')||{}).value||'', defaultYn:(tr.querySelector('.wdef')||{}).value||'N',
          sortOrd:n((tr.querySelector('.wso')||{}).value), useYn:(tr.querySelector('.wuse')||{}).value||'Y' };
  if(!/^[A-Z0-9_]{1,20}$/.test(cd)){ _alertBox('코드는 영문 대문자·숫자·_ 1~20자입니다.', {icon:'⚠️'}); return; }
  if(!p.whNm.trim()){ _alertBox('창고 이름을 넣으세요.', {icon:'⚠️'}); return; }
  if(isNew && _wh.some(function(w){ return w.whCd===cd; })){ _alertBox('이미 있는 코드입니다 — '+cd, {icon:'⚠️'}); return; }
  if(p.useYn==='N' && Math.round(n(_whQty[cd]||0))!==0){ _alertBox('<b>'+esc(cd)+'</b> 에 재고 '+fmt(_whQty[cd])+' 이 남아 있어 사용을 끌 수 없습니다.<br><span style="font-size:13px">먼저 창고 이동으로 옮기세요.</span>', {icon:'⚠️'}); return; }
  btn.disabled=true;
  post('/prod/whSave.do', p, true)
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
    .then(function(){ ok((isNew?'창고를 추가했습니다 — ':'창고를 저장했습니다 — ')+cd); whLoad(); })
    .catch(function(e){ btn.disabled=false; err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}

/* ── 출고장 → 창고 (2단계) ── */
function dcLoad(){
  post('/shipout/dcList.do','').then(function(r){ return r.json(); })
    .then(function(j){
      var rows=(j&&j.data)||[], tb=document.getElementById('dcBody');
      if(!rows.length){ tb.innerHTML='<tr><td colspan="5" class="empty">출고장 표(TBL_DC_MST)가 비어 있습니다 — docs/sql/20260916_parcel_print_dc.sql 씨앗을 확인하세요.</td></tr>'; return; }
      var use=_wh.filter(function(w){ return w.useYn==='Y'; });
      var def=(use.filter(function(w){ return w.defaultYn==='Y'; })[0]||{}).whNm||'기본창고';
      tb.innerHTML=rows.map(function(r){
        return '<tr data-cd="'+esc(r.cd)+'"><td><b>'+esc(r.cd)+'</b></td><td class="l">'+esc(r.nm)+'</td><td>'+(r.grp?esc(r.grp):'<span class="dim">단독</span>')+'</td>'
          +'<td><select class="dwh"><option value="">(기본창고 · '+esc(def)+')</option>'+use.map(function(w){ return '<option value="'+esc(w.whCd)+'"'+(w.whCd===r.whCd?' selected':'')+'>'+esc(w.whNm)+'</option>'; }).join('')+'</select></td>'
          +'<td><button class="btn" style="height:28px;padding:0 10px;font-size:12px" onclick="dcSave(this)">저장</button></td></tr>';
      }).join('');
    })
    .catch(function(e){ document.getElementById('dcBody').innerHTML='<tr><td colspan="5" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function dcSave(btn){
  var tr=btn.closest('tr'), cd=tr.getAttribute('data-cd'), wh=(tr.querySelector('.dwh')||{}).value||'';
  btn.disabled=true;
  post('/shipout/dcWhSave.do', { dcCd:cd, whCd:wh }, true)
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
    .then(function(){ ok(cd+' → '+(wh?whNmOf(wh):'기본창고')+' 저장'); btn.disabled=false; })
    .catch(function(e){ btn.disabled=false; err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}

/* ── 창고 이동 ── */
function fillMoveSel(){
  var use=_wh.filter(function(w){ return w.useYn==='Y'; });
  var opts=use.map(function(w){ return '<option value="'+esc(w.whCd)+'">'+esc(w.whNm)+' ('+esc(w.whCd)+')</option>'; }).join('');
  var f=document.getElementById('mvFrom'), t=document.getElementById('mvTo'), fv=f.value, tv=t.value;
  f.innerHTML=opts; t.innerHTML=opts;
  var def=(use.filter(function(w){ return w.defaultYn==='Y'; })[0]||use[0]||{}).whCd||'';
  f.value = fv||def; if(!f.value) f.value=def;
  t.value = tv||''; if(!t.value){ var other=use.filter(function(w){ return w.whCd!==f.value; })[0]; t.value = other ? other.whCd : def; }
}
var _prodNm='';
function prodLookup(){
  var cd=String(document.getElementById('mvProd').value||'').trim(); _prodNm='';
  var lb=document.getElementById('mvProdNm'); lb.textContent='';
  if(!cd) return;
  post('/prod/prodList.do','findData='+encodeURIComponent(cd)).then(function(r){ return r.json(); })
    .then(function(j){ var hit=((j&&j.data)||[]).filter(function(p){ return String(p.prodCd||'').toUpperCase()===cd.toUpperCase(); })[0];
      if(hit){ _prodNm=hit.prodNm||''; document.getElementById('mvProd').value=hit.prodCd; lb.textContent=_prodNm; lb.style.color='#137a6c'; }
      else { lb.textContent='없는 품목코드'; lb.style.color='#c0392b'; } })
    .catch(function(){});
}
function moveSave(){
  var dt=document.getElementById('mvDt').value, fr=document.getElementById('mvFrom').value, to=document.getElementById('mvTo').value,
      cd=String(document.getElementById('mvProd').value||'').trim(), qty=Math.round(n(document.getElementById('mvQty').value)), rmk=document.getElementById('mvRmk').value||'';
  if(!dt){ _alertBox('이동일자를 고르세요.', {icon:'⚠️'}); return; }
  if(!fr || !to){ _alertBox('창고를 고르세요.', {icon:'⚠️'}); return; }
  if(fr===to){ _alertBox('보내는 창고와 받는 창고가 같습니다.', {icon:'⚠️'}); return; }
  if(!cd){ _alertBox('품목코드를 넣으세요.', {icon:'⚠️'}); return; }
  if(qty<=0){ _alertBox('수량은 1 이상이어야 합니다.', {icon:'⚠️'}); return; }
  var b=document.getElementById('mvBtn'); b.disabled=true;
  /* 보내는 창고 재고를 먼저 물어 모자라면 확인창(막지 않는다) */
  post('/prod/whStockList.do','findData='+encodeURIComponent(cd)).then(function(r){ return r.json(); })
    .then(function(j){
      var have=0; ((j&&j.data)||[]).forEach(function(r){ if(String(r.prodCd).toUpperCase()===cd.toUpperCase() && r.whCd===fr) have+=n(r.curQty); });
      if(have < qty) return ask('<b>'+esc(whNmOf(fr))+'</b> 의 '+esc(cd)+' 재고는 <b>'+fmt(have)+'</b> 인데 '+fmt(qty)+' 을 옮깁니다.<br><span style="font-size:13px;color:#3d4d5c">그대로 옮기면 그 창고 재고가 음수가 됩니다.</span>', '그래도 이동', true);
      return true;
    })
    .then(function(go){ if(!go){ b.disabled=false; return; }
      return post('/prod/stockMoveSave.do', { trxDt:dt, fromWh:fr, toWh:to, prodCd:cd, qty:qty, remark:rmk }, true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(){ ok(esc(cd)+' '+fmt(qty)+' EA : '+whNmOf(fr)+' → '+whNmOf(to)); document.getElementById('mvQty').value=''; document.getElementById('mvRmk').value=''; b.disabled=false; whLoad(); moveList(); });
    })
    .catch(function(e){ b.disabled=false; err('이동하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}
function moveList(){
  var fr=document.getElementById('mvFr').value||'', to=document.getElementById('mvToDt').value||'';
  post('/prod/stockMoveList.do','fromDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)).then(function(r){ return r.json(); })
    .then(function(j){
      var rows=(j&&j.data)||[], tb=document.getElementById('mvBody');
      if(!rows.length){ tb.innerHTML='<tr><td colspan="9" class="empty">이 기간에 창고 이동이 없습니다.</td></tr>'; return; }
      tb.innerHTML=rows.map(function(r){ var d=String(r.trxDt||'');
        return '<tr><td>'+esc(d.length===8?d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8):d)+'</td><td><b>'+esc(r.prodCd)+'</b></td><td class="l">'+esc(r.prodNm||'')+'</td>'
          +'<td>'+esc(whNmOf(r.fromWh))+'</td><td>'+esc(whNmOf(r.toWh))+'</td><td class="r">'+fmt(r.qty)+'</td><td class="l">'+esc(r.remark||'')+'</td>'
          +'<td class="dim">'+esc(String(r.regDttm||'').slice(0,16))+' '+esc(r.regUser||'')+'</td>'
          +'<td><button class="btn" style="height:26px;padding:0 8px;font-size:12px" onclick="moveCancel(\''+esc(r.refNo)+'\')">취소</button></td></tr>'; }).join('');
    })
    .catch(function(e){ document.getElementById('mvBody').innerHTML='<tr><td colspan="9" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function moveCancel(refNo){
  ask('이 창고 이동을 취소할까요?<br><span style="font-size:13px;color:#3d4d5c">두 창고의 수량이 이동 전으로 되돌아갑니다.</span>', '취소', true).then(function(y){ if(!y) return;
    post('/prod/stockMoveCancel.do', { refNo:refNo }, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(){ ok('이동을 취소했습니다'); whLoad(); moveList(); })
      .catch(function(e){ err('취소하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
  });
}
window.konetShown=function(){ whLoad(); moveList(); };
(function init(){
  document.getElementById('mvDt').value=today();
  var d=new Date(); d.setMonth(d.getMonth()-1);
  document.getElementById('mvFr').value=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01';
  document.getElementById('mvToDt').value=today();
  whLoad(); moveList();
})();
</script>
</body>
</html>
