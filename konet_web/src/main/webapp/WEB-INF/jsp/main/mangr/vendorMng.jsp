<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<title>매입/매출 거래처 관리 (TBL_VENDOR_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  body{ margin:0; font-family:'맑은 고딕',Malgun Gothic,sans-serif; color:#1f2a37; background:var(--bg); font-size:13px; }
  .wrap{ padding:18px 20px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:280px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:auto; color:#6b7a89; font-size:12.5px; }
  .tabs{ display:flex; gap:4px; margin-bottom:10px; border-bottom:2px solid #e2e8e6; }
  .tabs .t{ height:32px; padding:0 14px; border:1px solid #dfe6e3; border-bottom:none; background:#f1f5f4; border-radius:8px 8px 0 0; cursor:pointer; font-size:13px; font-weight:700; color:#5a6b7a; }
  .tabs .t.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  table{ width:100%; border-collapse:collapse; font-size:12.5px; white-space:nowrap; }
  thead th{ background:#1f2a37; color:#fff; font-weight:700; padding:9px 10px; text-align:left; position:sticky; top:0; z-index:1; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:6px 10px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  td.code{ font-family:Consolas,monospace; }
  td.nm{ white-space:normal; min-width:160px; max-width:260px; }
  .gb{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; color:#fff; }
  .dc{ display:inline-block; padding:1px 7px; border-radius:8px; font-size:11px; font-weight:700; background:#eef4ff; color:#274b8f; border:1px solid #c9d9f5; }
  .act .btn{ height:26px; padding:0 9px; font-size:11.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  .pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin-top:14px; flex-wrap:wrap; }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  #ov .box{ background:#fff; width:min(820px,94vw); margin-top:3vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:93vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:16px 18px; overflow:auto; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px; }
  #ov .fld{ display:flex; flex-direction:column; gap:4px; }
  #ov .fld.full{ grid-column:1 / -1; }
  #ov label{ font-size:12px; font-weight:700; color:#37475a; }
  #ov input, #ov select, #ov textarea{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; font-family:inherit; }
  #ov textarea{ height:auto; padding:6px 8px; resize:vertical; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🧾 매입/매출 거래처 관리 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(회계 거래처 · TBL_VENDOR_MST)</span></h2>
  <div class="sub">회계 거래처 조회 · 추가 · 수정 · 삭제 · 엑셀 — 사업장(TBL_BIZI_MST, 배송 점포)과는 별개 마스터입니다.
    매입가·재고입고 화면의 매입처 선택은 여기의 <b>매입</b> 거래처를 씁니다.</div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·거래처명·정식명칭·별칭·사업자번호·대표자 검색" onkeyup="vmFilter()">
    <button class="btn" onclick="vmLoad()">↻ 조회</button>
    <button class="btn btn-teal" onclick="vmOpen()">＋ 거래처 추가</button>
    <button class="btn" onclick="document.getElementById('upFile').click()" title="회계시스템의 거래처리스트.xls 를 다시 올리면 코드 기준으로 갱신·추가됩니다(있으면 갱신, 없으면 신규). 삭제는 하지 않습니다.">📤 거래처리스트 재업로드</button>
    <input type="file" id="upFile" accept=".xls,.xlsx,.html,.htm" style="display:none" onchange="vmUpload(this)">
    <button class="btn" onclick="vmExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="tabs" id="gbTabs">
    <button class="t on" data-g=""      onclick="vmTab('')">전체</button>
    <button class="t"    data-g="매입"  onclick="vmTab('매입')">매입처</button>
    <button class="t"    data-g="매출"  onclick="vmTab('매출')">매출처</button>
  </div>

  <div class="card">
    <table>
      <thead><tr>
        <th>코드</th><th>거래처명</th><th>별칭</th><th>거래유형</th><th>사업자번호</th><th>대표자</th>
        <th>담당자</th><th>연락처</th><th>전화</th><th>부가세</th><th>물류센터</th><th style="width:110px">관리</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="12" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
</div>

<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">거래처 추가</b><button class="x" onclick="vmClose()">&times;</button></div>
    <div class="mb">
      <div class="fld"><label>거래처코드 *</label><input id="f_cd" placeholder="예: 0089"></div>
      <div class="fld"><label>거래유형 *</label><select id="f_gb"><option value="매입">매입</option><option value="매출">매출</option><option value="매입&매출">매입&매출</option></select></div>
      <div class="fld full"><label>거래처명 *</label><input id="f_nm"></div>
      <div class="fld"><label>정식명칭</label><input id="f_full"></div>
      <div class="fld"><label>별칭</label><input id="f_alias"></div>
      <div class="fld"><label>사업자등록번호</label><input id="f_bizno"></div>
      <div class="fld"><label>대표자</label><input id="f_ceo"></div>
      <div class="fld"><label>업태</label><input id="f_cond"></div>
      <div class="fld"><label>종목</label><input id="f_item"></div>
      <div class="fld"><label>담당자코드</label><input id="f_mgrcd"></div>
      <div class="fld"><label>담당자명</label><input id="f_mgrnm"></div>
      <div class="fld"><label>우편번호</label><input id="f_zip"></div>
      <div class="fld"><label>물류센터코드 <span style="color:#9aa7b3;font-weight:400">(삼성웰스토리 지점만, 예: E500)</span></label><input id="f_dc" placeholder="비워두면 일반 거래처"></div>
      <div class="fld full"><label>주소</label><input id="f_addr"></div>
      <div class="fld full"><label>상세주소</label><input id="f_addr2"></div>
      <div class="fld"><label>연락처(휴대폰)</label><input id="f_hp"></div>
      <div class="fld"><label>전화</label><input id="f_tel"></div>
      <div class="fld"><label>팩스</label><input id="f_fax"></div>
      <div class="fld"><label>이메일</label><input id="f_email"></div>
      <div class="fld"><label>계산서발행</label><select id="f_taxbill"><option value="">-</option><option value="발행">발행</option><option value="미발행">미발행</option></select></div>
      <div class="fld"><label>부가세</label><select id="f_vat"><option value="">-</option><option value="포함">포함</option><option value="별도">별도</option></select></div>
      <div class="fld full"><label>계좌</label><input id="f_acct" placeholder="예: 우리은행/1005-…((주)코네트)"></div>
      <div class="fld full"><label>비고</label><textarea id="f_remark" rows="2"></textarea></div>
    </div>
    <div class="mf">
      <button class="btn" onclick="vmClose()">취소</button>
      <button class="btn btn-teal" onclick="vmSave()">💾 저장</button>
    </div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var LIST=[], _view=[], _page=1, PAGE=20, _bycd={}, _gb='';
/* 물류센터 ↔ 삼성웰스토리 지점 거래처 (발주현황표 DC_CD 와 1:1 — 재업로드 시 자동 부여) */
var DC_MAP={ '00273':'E100', '00275':'E200', '00274':'E300', '00276':'E400', '00272':'E500', '00277':'E600', '00278':'E700' };

function toast(s){ if(window.Swal){ Swal.fire({toast:true,position:'top-end',html:s,showConfirmButton:false,timer:3000,timerProgressBar:true}); } }
function swConfirm(msg,title){ if(window.Swal) return Swal.fire({title:title||'확인',html:msg,icon:'question',showCancelButton:true,confirmButtonText:'확인',cancelButtonText:'취소',confirmButtonColor:'#137a6c',cancelButtonColor:'#94a3b8'}).then(function(r){return r.isConfirmed;}); return Promise.resolve(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))); }
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }

function vmLoad(){
  fetch(CTX+'/vendor/selectVendorMst.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){ LIST=(j&&j.data)||[]; _bycd={}; LIST.forEach(function(o){ _bycd[o.vendorCd]=o; }); vmFilter(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function vmTab(g){
  _gb=g;
  Array.prototype.forEach.call(document.querySelectorAll('#gbTabs .t'), function(b){ b.classList.toggle('on', b.getAttribute('data-g')===g); });
  vmFilter();
}
function vmFilter(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  _view=LIST.filter(function(o){
    if(_gb && (''+(o.vendorGb||'')).indexOf(_gb)<0) return false;
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.fullNm,o.alias,o.bizno,o.ceoNm].some(function(v){ return (''+(v||'')).toLowerCase().indexOf(q)>=0; });
  });
  _page=1; vmRender();
}
function vmRender(){
  var tot=_view.length, pages=Math.max(1,Math.ceil(tot/PAGE)); if(_page>pages)_page=pages;
  document.getElementById('cnt').textContent=tot.toLocaleString()+'건 / 전체 '+LIST.length.toLocaleString()+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="12" class="empty">데이터가 없습니다.</td></tr>'; _pager(0,1); return; }
  var GB_COLOR={ '매입':'#a85700', '매출':'#2e7d32', '매입&매출':'#137a6c' };
  tb.innerHTML=_view.slice((_page-1)*PAGE,(_page-1)*PAGE+PAGE).map(function(o){
    var c=GB_COLOR[o.vendorGb]||'#5a6b7a';
    return '<tr>'
      +'<td class="code">'+esc(o.vendorCd)+'</td><td class="nm">'+esc(o.vendorNm)+'</td><td>'+esc(o.alias)+'</td>'
      +'<td><span class="gb" style="background:'+c+'">'+esc(o.vendorGb||'-')+'</span></td>'
      +'<td>'+esc(o.bizno)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td>'
      +'<td>'+esc(o.hp)+'</td><td>'+esc(o.tel)+'</td><td>'+esc(o.vatGb)+'</td>'
      +'<td>'+(o.dcCd?('<span class="dc">'+esc(o.dcCd)+'</span>'):'')+'</td>'
      +'<td class="act"><button class="btn" onclick="vmOpen(\''+esc(o.vendorCd)+'\')">수정</button> <button class="btn btn-danger" onclick="vmDel(\''+esc(o.vendorCd)+'\')">삭제</button></td>'
    +'</tr>';
  }).join('');
  _pager(pages,_page);
}
function _go(p){ _page=p; vmRender(); }
function _pager(pages,cur){
  var el=document.getElementById('pager'); if(pages<=1){ el.innerHTML=''; return; }
  var h='<button '+(cur<=1?'disabled':'')+' onclick="_go('+(cur-1)+')">‹</button>';
  var from=Math.max(1,cur-3), to=Math.min(pages,cur+3);
  if(from>1){ h+='<button onclick="_go(1)">1</button>'; if(from>2)h+='<span class="ell">…</span>'; }
  for(var p=from;p<=to;p++) h+='<button class="'+(p===cur?'on':'')+'" onclick="_go('+p+')">'+p+'</button>';
  if(to<pages){ if(to<pages-1)h+='<span class="ell">…</span>'; h+='<button onclick="_go('+pages+')">'+pages+'</button>'; }
  h+='<button '+(cur>=pages?'disabled':'')+' onclick="_go('+(cur+1)+')">›</button>';
  el.innerHTML=h;
}
function _set(id,v){ document.getElementById(id).value=(v==null?'':v); }
function vmOpen(cd){
  var o=cd?_bycd[cd]:null;
  document.getElementById('ovTit').textContent=o?('거래처 수정 — '+o.vendorCd):'거래처 추가';
  _set('f_cd',o?o.vendorCd:''); document.getElementById('f_cd').readOnly=!!o;
  _set('f_gb',o?(o.vendorGb||'매입'):'매입');
  _set('f_nm',o?o.vendorNm:''); _set('f_full',o?o.fullNm:''); _set('f_alias',o?o.alias:'');
  _set('f_bizno',o?o.bizno:''); _set('f_ceo',o?o.ceoNm:''); _set('f_cond',o?o.bizCond:''); _set('f_item',o?o.bizItem:'');
  _set('f_mgrcd',o?o.mgrCd:''); _set('f_mgrnm',o?o.mgrNm:''); _set('f_zip',o?o.zipcd:''); _set('f_dc',o?o.dcCd:'');
  _set('f_addr',o?o.addr:''); _set('f_addr2',o?o.addr2:'');
  _set('f_hp',o?o.hp:''); _set('f_tel',o?o.tel:''); _set('f_fax',o?o.fax:''); _set('f_email',o?o.email:'');
  _set('f_taxbill',o?(o.taxbillGb||''):''); _set('f_vat',o?(o.vatGb||''):''); _set('f_acct',o?o.bankAcct:''); _set('f_remark',o?o.remark:'');
  document.getElementById('ov').classList.add('on');
}
function vmClose(){ document.getElementById('ov').classList.remove('on'); }
function vmDto(){
  return { vendorCd:gv('f_cd'), vendorNm:gv('f_nm')||null, fullNm:gv('f_full')||null, alias:gv('f_alias')||null,
    vendorGb:gv('f_gb')||null, bizno:gv('f_bizno')||null, ceoNm:gv('f_ceo')||null,
    bizCond:gv('f_cond')||null, bizItem:gv('f_item')||null, mgrCd:gv('f_mgrcd')||null, mgrNm:gv('f_mgrnm')||null,
    zipcd:gv('f_zip')||null, dcCd:gv('f_dc')||null, addr:gv('f_addr')||null, addr2:gv('f_addr2')||null,
    hp:gv('f_hp')||null, tel:gv('f_tel')||null, fax:gv('f_fax')||null, email:gv('f_email')||null,
    taxbillGb:gv('f_taxbill')||null, vatGb:gv('f_vat')||null, bankAcct:gv('f_acct')||null, remark:gv('f_remark')||null };
}
function vmSave(){
  var dto=vmDto();
  if(!dto.vendorCd){ toast('⚠️ 거래처코드를 입력하세요.'); return; }
  if(!dto.vendorNm){ toast('⚠️ 거래처명을 입력하세요.'); return; }
  var isEdit=document.getElementById('f_cd').readOnly;
  fetch(CTX+(isEdit?'/vendor/updateVendorMst.do':'/vendor/insertVendorMst.do'),
    { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('⚠️ '+((r.t||'').trim()||'저장 실패')); return; } vmClose(); toast(isEdit?'💾 수정 완료':'＋ 등록 완료'); vmLoad(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function vmDel(cd){
  var o=_bycd[cd]; if(!o) return;
  swConfirm('['+esc(o.vendorCd)+'] '+esc(o.vendorNm||'')+'<br>삭제(미사용 처리)하시겠습니까?<br><span style="color:#9aa7b3;font-size:12px">완전 삭제가 아니라 미사용(ACTION_YN=N) 처리라 이력은 남습니다.</span>','거래처 삭제')
  .then(function(ok){ if(!ok) return;
    fetch(CTX+'/vendor/deleteVendorMst.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({vendorCd:cd}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
      .then(function(r){ if(!r.ok){ toast('⚠️ 삭제 실패'); return; } toast('🗑️ 삭제(미사용) 완료'); vmLoad(); });
  });
}

/* ---- 거래처리스트.xls 재업로드 ----
   · 이 파일은 확장자만 .xls 이고 실제로는 HTML 표(40컬럼)다. DOMParser 로 읽는다.
   · 같은 코드가 거래유형/담당자별로 여러 줄인 비정규화 → 코드 기준 병합(거래유형은 합집합, 나머지는 첫 값)
   · 서버에서 코드별 MERGE upsert (있으면 갱신, 없으면 신규. 삭제는 안 함) */
function vmUpload(input){
  var f=input.files && input.files[0]; if(!f) return;
  var rd=new FileReader();
  rd.onload=function(e){
    try{
      var doc=new DOMParser().parseFromString(e.target.result,'text/html');
      var tables=doc.querySelectorAll('table'), target=null, hi={};
      Array.prototype.forEach.call(tables, function(tb){
        if(target) return;
        var tr0=tb.querySelector('tr'); if(!tr0) return;
        var heads=Array.prototype.map.call(tr0.querySelectorAll('td,th'), function(c){ return (c.textContent||'').replace(/\s+/g,' ').trim(); });
        if(heads.indexOf('코드')>=0 && heads.indexOf('거래처명')>=0){ target=tb; heads.forEach(function(h,i){ hi[h]=i; }); }
      });
      if(!target){ toast('⚠️ 거래처 표(코드·거래처명 헤더)를 찾지 못했습니다.'); input.value=''; return; }
      function cell(tds,name){ var i=hi[name]; if(i==null||!tds[i]) return ''; return (tds[i].textContent||'').replace(/\s+/g,' ').trim(); }
      var raw=[];
      Array.prototype.slice.call(target.querySelectorAll('tr'),1).forEach(function(tr){
        var tds=tr.querySelectorAll('td'); if(tds.length<10) return;
        var cd=cell(tds,'코드'); if(!cd) return;
        raw.push({ cd:cd, nm:cell(tds,'거래처명'), full:cell(tds,'정식명칭'), alias:cell(tds,'별칭'),
          ceo:cell(tds,'대표자명'), gb:cell(tds,'거래유형'), cond:cell(tds,'업태'), item:cell(tds,'종목'),
          mgrCd:cell(tds,'담당자코드'), mgrNm:cell(tds,'담당자명'), typeCd:cell(tds,'유형코드'), typeNm:cell(tds,'유형명'),
          areaCd:cell(tds,'지역코드'), areaNm:cell(tds,'지역명'), zip:cell(tds,'우편번호'),
          addr:cell(tds,'주소'), addr2:cell(tds,'상세주소'), email:cell(tds,'이메일'),
          hp:cell(tds,'연락처'), tel:cell(tds,'전화'), fax:cell(tds,'팩스'),
          taxbill:cell(tds,'계산서발행'), vat:cell(tds,'부가세'), acct:cell(tds,'계좌'),
          bizno:cell(tds,'사업자번호'), regDt:cell(tds,'등록일'),
          rm:[cell(tds,'비고1'),cell(tds,'비고2'),cell(tds,'비고3')].filter(function(x){return x;}).join(' / ') });
      });
      if(!raw.length){ toast('⚠️ 데이터 행이 없습니다.'); input.value=''; return; }
      // 코드 기준 병합 — 거래유형은 합집합, 나머지는 비어있지 않은 첫 값
      var g={}, order=[];
      raw.forEach(function(r){ if(!g[r.cd]){ g[r.cd]=[]; order.push(r.cd); } g[r.cd].push(r); });
      function pick(L,k){ for(var i=0;i<L.length;i++){ if(L[i][k]) return L[i][k]; } return null; }
      var rows=order.map(function(cd){
        var L=g[cd], s={};
        L.forEach(function(r){ (r.gb||'').split('&').forEach(function(x){ x=x.trim(); if(x) s[x]=1; }); });
        var gb=Object.keys(s).length>1?'매입&매출':(Object.keys(s)[0]||null);
        var rd8=(pick(L,'regDt')||'').replace(/[^0-9]/g,'').slice(0,8);
        return { vendorCd:cd, vendorNm:pick(L,'nm'), fullNm:pick(L,'full'), alias:pick(L,'alias'), ceoNm:pick(L,'ceo'),
          vendorGb:gb, bizCond:pick(L,'cond'), bizItem:pick(L,'item'), mgrCd:pick(L,'mgrCd'), mgrNm:pick(L,'mgrNm'),
          typeCd:pick(L,'typeCd'), typeNm:pick(L,'typeNm'), areaCd:pick(L,'areaCd'), areaNm:pick(L,'areaNm'),
          zipcd:pick(L,'zip'), addr:pick(L,'addr'), addr2:pick(L,'addr2'), email:pick(L,'email'),
          hp:pick(L,'hp'), tel:pick(L,'tel'), fax:pick(L,'fax'), bizno:pick(L,'bizno'), bankAcct:pick(L,'acct'),
          taxbillGb:pick(L,'taxbill'), vatGb:pick(L,'vat'), regDt:(rd8.length===8?rd8:null),
          dcCd:DC_MAP[cd]||null, remark:pick(L,'rm') };
      });
      swConfirm('거래처 <b>'+rows.length+'</b>종을 반영하시겠습니까?<br>(원본 '+raw.length+'행 → 코드 기준 병합)<br>'
        +'<span style="color:#9aa7b3;font-size:12px">이미 있는 코드는 갱신, 없는 코드는 신규 등록됩니다. 삭제는 하지 않습니다.</span>','거래처리스트 재업로드')
      .then(function(ok){ if(!ok){ input.value=''; return; }
        fetch(CTX+'/vendor/uploadVendorMst.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(rows) })
          .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
          .then(function(r){ if(!r.ok){ toast('⚠️ 업로드 실패: '+(r.t||'')); return; } toast('📤 재업로드 완료 — <b>'+r.t+'</b>종 반영'); vmLoad(); })
          .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
        input.value='';
      });
    }catch(err){ toast('⚠️ 파일 처리 오류: '+err.message); input.value=''; }
  };
  rd.readAsText(f,'UTF-8');   // 파일이 UTF-8 HTML 임을 확인함 (charset=utf-8 선언)
}

function vmExcel(){
  var list=_view; if(!list.length){ toast('⚠️ 출력할 데이터가 없습니다.'); return; }
  var head=['코드','거래처명','정식명칭','별칭','거래유형','사업자번호','대표자','업태','종목','담당자','연락처','전화','팩스','이메일','우편번호','주소','상세주소','계산서발행','부가세','계좌','물류센터','비고'];
  var aoa=[head].concat(list.map(function(o){ return [o.vendorCd,o.vendorNm,o.fullNm,o.alias,o.vendorGb,o.bizno,o.ceoNm,o.bizCond,o.bizItem,o.mgrNm,o.hp,o.tel,o.fax,o.email,o.zipcd,o.addr,o.addr2,o.taxbillGb,o.vatGb,o.bankAcct,o.dcCd,o.remark]; }));
  var P=window.parent;
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'거래처'); LIB.writeFile(wb,'매입매출거래처.xlsx'); toast('📥 엑셀 저장 완료 · '+list.length+'건'); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csv(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csv();
  function csv(){ var c=aoa.map(function(r){ return r.map(function(x){ x=(x==null?'':(''+x)); return '"'+x.replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var b=new Blob(['﻿'+c],{type:'text/csv;charset=utf-8'}), a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download='매입매출거래처.csv'; document.body.appendChild(a); a.click(); a.remove(); toast('📥 CSV 저장 완료'); }
}
vmLoad();
</script>
</body>
</html>
