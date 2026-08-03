<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<title>거래처관리 (사업장 · TBL_BIZI_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:280px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:8px; color:#6b7a89; font-size:12.5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  table{ width:100%; border-collapse:collapse; font-size:13px; font-weight:700; white-space:nowrap; }
  thead th{ background:#1f2a37; color:#fff; font-weight:700; padding:9px 10px; text-align:left; position:sticky; top:0; z-index:1; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:6px 10px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  tbody tr{ cursor:pointer; }
  tbody tr.sel td{ background:#dcefe9 !important; }
  .btn:disabled{ opacity:.45; cursor:default; }
  td.code{ font-family:Consolas,monospace; }
  td.nm{ white-space:normal; min-width:180px; max-width:280px; }
  .gb{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; color:#fff; }
  .act .btn{ height:26px; padding:0 9px; font-size:11.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  .pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin-top:14px; flex-wrap:wrap; }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  #ov .box{ background:#fff; width:min(760px,94vw); margin-top:4vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:92vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:16px 18px; overflow:auto; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px; }
  #ov .fld{ display:flex; flex-direction:column; gap:4px; }
  #ov .fld.full{ grid-column:1 / -1; }
  #ov label{ font-size:13px; font-weight:500; color:#333; background:linear-gradient(135deg,#b3ddf0 0%,#d4ecf7 100%); border-radius:3px; padding:4px 10px; display:inline-flex; align-items:center; justify-content:flex-start; align-self:flex-start; min-width:104px; min-height:26px; white-space:nowrap; }
  #ov input, #ov select, #ov textarea{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:14px; font-family:inherit; }
  #ov textarea{ height:auto; padding:6px 8px; resize:vertical; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
</style>
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
</head>
<body>
<div class="wrap">
  <h2>🤝 거래처관리 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(사업장 · TBL_BIZI_MST)</span></h2>
  <div class="sub">사업장(거래처) 조회 · 추가 · 수정 · 삭제 · 엑셀출력</div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·사업장명·약칭·사업자번호·대표자 검색" onkeyup="if(event.keyCode===13)cliLoad()">
    <button class="btn" onclick="cliLoad()">↻ 조회</button>
    <button class="btn btn-teal" style="margin-left:auto" onclick="cliOpen()">＋ 거래처 추가</button>
    <button class="btn" id="btnEdit" onclick="cliEditSel()">✎ 수정</button>
    <button class="btn btn-danger" id="btnDel" onclick="cliDelSel()">🗑 삭제</button>
    <button class="btn" onclick="cliExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="card">
    <table>
      <thead><tr>
        <th>코드</th><th>사업장명</th><th>약칭</th><th>거래구분</th><th>사업자번호</th><th>대표자</th>
        <th>업태</th><th>종목</th><th>전화</th><th>휴대폰</th><th>담당자</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="11" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
</div>

<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">거래처 추가</b><button class="x" onclick="cliClose()">&times;</button></div>
    <div class="mb">
      <div class="fld"><label>사업장코드 *</label><input id="f_cd" placeholder="예: A0386956"></div>
      <div class="fld"><label>거래구분</label><select id="f_gb"><option value="">-</option><option value="매출">매출처</option><option value="매입">매입처</option><option value="both">매입+매출</option></select></div>
      <div class="fld full"><label>사업장명 *</label><input id="f_nm" placeholder="사업장명"></div>
      <div class="fld"><label>약칭</label><input id="f_snm" placeholder="약어 명칭"></div>
      <div class="fld"><label>사업자등록번호</label><input id="f_bizno"></div>
      <div class="fld"><label>대표자</label><input id="f_ceo"></div>
      <div class="fld"><label>담당자</label><input id="f_mgr"></div>
      <div class="fld"><label>업태</label><input id="f_cond"></div>
      <div class="fld"><label>종목</label><input id="f_item"></div>
      <div class="fld"><label>우편번호</label><input id="f_zip"></div>
      <div class="fld"><label>정렬순서</label><input id="f_sort" type="number" value="999999"></div>
      <div class="fld full"><label>주소</label><input id="f_addr"></div>
      <div class="fld full"><label>상세주소</label><input id="f_addr2"></div>
      <div class="fld"><label>전화</label><input id="f_tel"></div>
      <div class="fld"><label>팩스</label><input id="f_fax"></div>
      <div class="fld"><label>휴대폰</label><input id="f_hp"></div>
      <div class="fld"><label>이메일</label><input id="f_email"></div>
      <div class="fld full"><label>비고</label><textarea id="f_remark" rows="2"></textarea></div>
    </div>
    <div class="mf">
      <button class="btn" onclick="cliClose()">취소</button>
      <button class="btn btn-teal" onclick="cliSave()">💾 저장</button>
    </div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var LIST=[], _view=[], _page=1, PAGE=20, _bycd={};
var GB_MAP={ '매출':['매출처','#2e7d32'], '매입':['매입처','#a85700'], 'both':['매입+매출','#137a6c'] };

function toast(s){ if(window.Swal){ Swal.fire({toast:true,position:'top-end',html:s,showConfirmButton:false,timer:2500,timerProgressBar:true}); return; } }
function swConfirm(msg,title){ if(window.Swal) return Swal.fire({title:title||'확인',html:msg,icon:'question',showCancelButton:true,confirmButtonText:'확인',cancelButtonText:'취소',confirmButtonColor:'#137a6c',cancelButtonColor:'#94a3b8'}).then(function(r){return r.isConfirmed;}); return Promise.resolve(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))); }
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function gnum(id){ var v=gv(id); return v===''?null:Number(v); }

function cliLoad(){
  var q=(document.getElementById('q').value||'').trim();
  fetch(CTX+'/mangr/clientList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'findData='+encodeURIComponent(q) })
    .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ toast('⚠️ 목록 응답 오류'); return; }
      LIST=(j&&j.data)||[]; _bycd={}; LIST.forEach(function(o){ _bycd[o.bizCd]=o; }); _view=LIST.slice(); _page=1; cliRender();
    }).catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function cliRender(){
  _selReset();
  var tot=_view.length, pages=Math.max(1,Math.ceil(tot/PAGE)); if(_page>pages)_page=pages;
  document.getElementById('cnt').textContent=tot.toLocaleString()+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="11" class="empty">데이터가 없습니다.</td></tr>'; _pager(0,1); return; }
  var rows=_view.slice((_page-1)*PAGE,(_page-1)*PAGE+PAGE);
  tb.innerHTML=rows.map(function(o){
    var g=GB_MAP[o.bizGb], gb=g?'<span class="gb" style="background:'+g[1]+'">'+g[0]+'</span>':'';
    return '<tr data-cd="'+esc(o.bizCd)+'" onclick="cliSel(this,\''+esc(o.bizCd)+'\')" ondblclick="cliOpen(\''+esc(o.bizCd)+'\')">'
      +'<td class="code">'+esc(o.bizCd)+'</td><td class="nm">'+esc(o.bizNm)+'</td><td>'+esc(o.bizSmallNm)+'</td>'
      +'<td>'+gb+'</td><td>'+esc(o.bizno)+'</td><td>'+esc(o.ceoNm)+'</td>'
      +'<td>'+esc(o.bizCond)+'</td><td>'+esc(o.bizItem)+'</td><td>'+esc(o.tel)+'</td><td>'+esc(o.hp)+'</td><td>'+esc(o.manager)+'</td>'
    +'</tr>';
  }).join('');
  _pager(pages,_page);
}
function _go(p){ _page=p; cliRender(); }
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
function cliOpen(cd){
  var o=cd?_bycd[cd]:null;
  document.getElementById('ovTit').textContent=o?'거래처 수정':'거래처 추가';
  _set('f_cd',o?o.bizCd:''); document.getElementById('f_cd').readOnly=!!o;
  _set('f_gb',o?o.bizGb:''); _set('f_nm',o?o.bizNm:''); _set('f_snm',o?o.bizSmallNm:'');
  _set('f_bizno',o?o.bizno:''); _set('f_ceo',o?o.ceoNm:''); _set('f_mgr',o?o.manager:'');
  _set('f_cond',o?o.bizCond:''); _set('f_item',o?o.bizItem:''); _set('f_zip',o?o.zipcd:'');
  _set('f_sort',o?(o.sortOrd!=null?o.sortOrd:999999):999999); _set('f_addr',o?o.addr:''); _set('f_addr2',o?o.addr2:'');
  _set('f_tel',o?o.tel:''); _set('f_fax',o?o.fax:''); _set('f_hp',o?o.hp:''); _set('f_email',o?o.email:''); _set('f_remark',o?o.remark:'');
  document.getElementById('ov').classList.add('on');
}
function cliClose(){ document.getElementById('ov').classList.remove('on'); }
function cliSave(){
  var cd=gv('f_cd'), nm=gv('f_nm');
  if(!cd){ toast('⚠️ 사업장코드를 입력하세요.'); return; }
  if(!nm){ toast('⚠️ 사업장명을 입력하세요.'); return; }
  var dto={ bizCd:cd, bizNm:nm, bizSmallNm:gv('f_snm')||null, bizGb:gv('f_gb')||null, bizno:gv('f_bizno')||null,
    ceoNm:gv('f_ceo')||null, manager:gv('f_mgr')||null, bizCond:gv('f_cond')||null, bizItem:gv('f_item')||null,
    zipcd:gv('f_zip')||null, addr:gv('f_addr')||null, addr2:gv('f_addr2')||null, tel:gv('f_tel')||null, fax:gv('f_fax')||null,
    hp:gv('f_hp')||null, email:gv('f_email')||null, sortOrd:gnum('f_sort'), remark:gv('f_remark')||null };
  var isEdit=document.getElementById('f_cd').readOnly;
  var url=isEdit?'/mangr/clientUpdate.do':'/mangr/clientInsert.do';
  fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('⚠️ '+((r.t||'').trim()||'저장 실패')); return; } cliClose(); toast(isEdit?'💾 수정 완료':'＋ 등록 완료'); cliLoad(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function cliDel(cd){
  var o=_bycd[cd]; if(!o) return;
  swConfirm('['+esc(o.bizCd)+'] '+esc(o.bizNm||'')+'<br>삭제하시겠습니까?','거래처 삭제').then(function(ok){ if(!ok) return;
    fetch(CTX+'/mangr/clientDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({bizCd:cd}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
      .then(function(r){ if(!r.ok){ toast('⚠️ 삭제 실패'); return; } toast('🗑️ 삭제 완료'); cliLoad(); });
  });
}
var _sel=null;
function _selReset(){ _sel=null; }
function cliSel(tr,cd){
  var tb=document.getElementById('tb');
  Array.prototype.forEach.call(tb.querySelectorAll('tr.sel'),function(r){ r.classList.remove('sel'); });
  tr.classList.add('sel'); _sel=cd;
}
function cliEditSel(){ if(!_sel){ toast('⚠️ 수정할 행을 먼저 선택하세요.'); return; } cliOpen(_sel); }
function cliDelSel(){ if(!_sel){ toast('⚠️ 삭제할 행을 먼저 선택하세요.'); return; } cliDel(_sel); }
function cliExcel(){
  var list=_view; if(!list.length){ toast('⚠️ 출력할 데이터가 없습니다.'); return; }
  var head=['코드','사업장명','약칭','거래구분','사업자번호','대표자','업태','종목','우편번호','주소','상세주소','전화','팩스','휴대폰','이메일','담당자','정렬','비고'];
  var aoa=[head].concat(list.map(function(o){ return [o.bizCd,o.bizNm,o.bizSmallNm,o.bizGb,o.bizno,o.ceoNm,o.bizCond,o.bizItem,o.zipcd,o.addr,o.addr2,o.tel,o.fax,o.hp,o.email,o.manager,o.sortOrd,o.remark]; }));
  var P=window.parent;
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'거래처'); LIB.writeFile(wb,'거래처.xlsx'); toast('📥 엑셀 저장 완료 · '+list.length+'건'); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csv(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csv();
  function csv(){ var c=aoa.map(function(r){ return r.map(function(x){ x=(x==null?'':(''+x)); return '"'+x.replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var b=new Blob(['﻿'+c],{type:'text/csv;charset=utf-8'}), a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download='거래처.csv'; document.body.appendChild(a); a.click(); a.remove(); toast('📥 CSV 저장 완료'); }
}
cliLoad();
</script>
</body>
</html>
