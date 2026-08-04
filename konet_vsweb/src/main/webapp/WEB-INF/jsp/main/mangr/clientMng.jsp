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
  /* 목록 높이는 cliFit() 이 창 크기에 맞춰 px 로 잡는다(매입/매출 거래처 화면과 같은 방식) */
  #listCard{ min-height:220px; }
  /* 스크롤해도 머리글은 남아야 한다. z-index 없으면 행이 머리글 위로 그려진다 */
  .card thead th{ position:sticky; top:0; z-index:3; }
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
  .pager{ display:flex; gap:8px; justify-content:center; align-items:center; margin-top:10px; flex-wrap:wrap; }
  .pgnote{ font-size:12.5px; color:#5a6b7a; font-weight:600; }
  .pgnote b{ color:var(--teal); }
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
  <%-- 라벨 = 진하게·가운데 정렬 (2026-08-04 요청, 다른 등록 창과 동일) --%>
  #ov label{ font-size:13px; font-weight:700; color:#1f2a37; background:linear-gradient(135deg,#b3ddf0 0%,#d4ecf7 100%); border-radius:3px; padding:4px 10px; display:inline-flex; align-items:center; justify-content:center; text-align:center; align-self:flex-start; min-width:104px; min-height:26px; white-space:nowrap; }
  #ov input, #ov select, #ov textarea{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:14px; font-family:inherit; }
  #ov textarea{ height:auto; padding:6px 8px; resize:vertical; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
  /* 취소·저장은 가로를 넉넉히 (2026-08-04 요청) */
  #ov .mf .btn{ min-width:104px; padding:0 22px; }
</style>
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
</head>
<body>
<div class="wrap">
  <h2>🤝 거래처관리 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(사업장 · TBL_BIZI_MST)</span></h2>
  <div class="sub">사업장(거래처) 조회 · 추가 · 수정 · 삭제 · 엑셀출력
    <%-- 키 안내 (2026-08-04) — 안 보이면 아무도 안 쓴다 --%>
    <div style="margin-top:3px;font-size:12px;color:#9aa7b3">⌨ <b>↑↓</b> 줄 이동 · <b>Enter</b> 수정 · <b>Alt+N</b> 추가
      &nbsp;|&nbsp; 창에서 <b>Enter</b> 다음 칸 · <b>Ctrl+S</b> 저장 · <b>Esc</b> 닫기</div></div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·사업장명·약칭·사업자번호·대표자 검색" onkeyup="if(event.keyCode===13)cliLoad()">
    <button class="btn" onclick="cliLoad()">↻ 조회</button>
    <button class="btn btn-teal" style="margin-left:auto" onclick="cliOpen()">＋ 거래처 추가</button>
    <button class="btn" id="btnEdit" onclick="cliEditSel()">✎ 수정</button>
    <button class="btn btn-danger" id="btnDel" onclick="cliDelSel()">🗑 삭제</button>
    <button class="btn" onclick="cliExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="card" id="listCard">
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
/* 목록은 페이지 버튼 없이 **스크롤로 이어서** 나온다 (2026-08-04 요청 — 매입/매출 거래처 화면과 같은 방식).
   _shown = 지금까지 그려 둔 줄 수. 바닥 가까이 내려가면 CHUNK 만큼 더 그린다.
   ★한 번에 전부 그리지 않는 이유 — 사업장이 1,300여 종이라 통째로 그리면 첫 표시가 눈에 띄게 느려진다.
   PAGE 는 고정값이 아니라 cliFit() 이 실제 창 높이에서 다시 잡는다(첫 화면이 꽉 차게). */
var LIST=[], _view=[], _shown=0, PAGE=20, CHUNK=40, _bycd={};
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
      LIST=(j&&j.data)||[]; _bycd={}; LIST.forEach(function(o){ _bycd[o.bizCd]=o; }); _view=LIST.slice();
      _shown=0; _selReset();      // 새로 읽어 온 목록이라 고른 줄은 푼다(지워진 줄일 수 있다)
      var c=document.getElementById('listCard'); if(c) c.scrollTop=0;   // 새로 조회한 목록은 맨 위부터 본다
      cliRender();
    }).catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function cliRender(){
  var tot=_view.length;
  if(_shown<PAGE) _shown=PAGE;
  if(_shown>tot) _shown=tot;
  document.getElementById('cnt').textContent=tot.toLocaleString()+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="11" class="empty">데이터가 없습니다.</td></tr>'; _selReset(); _info(0,0); cliFit(); return; }
  tb.innerHTML=_view.slice(0,_shown).map(function(o){
    var g=GB_MAP[o.bizGb], gb=g?'<span class="gb" style="background:'+g[1]+'">'+g[0]+'</span>':'';
    return '<tr data-cd="'+esc(o.bizCd)+'" onclick="cliSel(this,\''+esc(o.bizCd)+'\')" ondblclick="cliOpen(\''+esc(o.bizCd)+'\')">'
      +'<td class="code">'+esc(o.bizCd)+'</td><td class="nm">'+esc(o.bizNm)+'</td><td>'+esc(o.bizSmallNm)+'</td>'
      +'<td>'+gb+'</td><td>'+esc(o.bizno)+'</td><td>'+esc(o.ceoNm)+'</td>'
      +'<td>'+esc(o.bizCond)+'</td><td>'+esc(o.bizItem)+'</td><td>'+esc(o.tel)+'</td><td>'+esc(o.hp)+'</td><td>'+esc(o.manager)+'</td>'
    +'</tr>';
  }).join('');
  // ★고른 줄 표시를 되살린다 — 스크롤로 이어 그릴 때마다 선택이 풀리면
  //   줄을 고른 뒤 조금만 내려도 [수정]이 "행을 먼저 선택하세요"로 튕긴다.
  if(_sel!=null){ var sr=tb.querySelector('tr[data-cd="'+_sel+'"]'); if(sr) sr.classList.add('sel'); }
  _info(_shown, tot);
  cliFit();
}
/* 페이지 버튼을 없앤 자리 — 지금 몇 줄까지 보고 있는지와 [모두 표시]만 남긴다 */
function _info(shown, tot){
  var el=document.getElementById('pager'); if(!el) return;
  if(!tot){ el.innerHTML=''; return; }
  el.innerHTML = shown>=tot
    ? '<span class="pgnote">전체 <b>'+tot.toLocaleString()+'</b>건을 모두 보고 있습니다</span>'
    : '<span class="pgnote"><b>'+shown.toLocaleString()+'</b> / '+tot.toLocaleString()+'건 — 아래로 스크롤하면 이어서 나옵니다</span>'
      + '<button onclick="cliShowAll()">모두 표시</button>';
}
function cliShowAll(){ _shown=_view.length; cliRender(); }
/* ── 목록 높이 자동 맞춤 (매입/매출 거래처 화면 vmFit 과 같은 방식) ─────────
   ① 목록 카드를 창 아래(안내줄 위)까지 늘리고, 그 안에서 스크롤하게 한다.
   ② 늘어난 높이에 맞춰 첫 화면에 담는 줄 수(PAGE)도 다시 잡는다 — 높이만 늘리면 20줄 밑이 그대로 빈다.
   ★위치는 반드시 '문서 기준'(rect.top + scrollY)으로 잰다. 화면 기준으로 재면
     스크롤할 때마다 값이 달라져 높이가 계속 자라는 자가증식이 된다. */
var _fitting=false;
function cliFit(){
  if(_fitting) return; _fitting=true;
  try{
    var card=document.getElementById('listCard'), pg=document.getElementById('pager');
    if(!card) return;
    var top=card.getBoundingClientRect().top + (window.pageYOffset||0);
    var pgH=pg ? (pg.offsetHeight+10) : 0;
    var h=Math.max(220, Math.floor(window.innerHeight - top - pgH - 14));
    card.style.height=h+'px';
    // 한 줄 높이는 실제로 그려진 줄에서 잰다(글꼴·배율마다 다르다). 없으면 30px 로 본다
    var tr=card.querySelector('tbody tr'), th=card.querySelector('thead');
    var rowH=(tr&&tr.offsetHeight)||30, headH=(th&&th.offsetHeight)||34;
    var fit=Math.max(10, Math.floor((h-headH)/rowH));
    if(fit!==PAGE){ PAGE=fit; if(_shown<PAGE){ cliRender(); } }   // 가드가 되돌이를 막는다
    _bindScroll();
    // 창을 키워 목록이 스크롤 없이 다 들어오면 스크롤 이벤트가 안 오므로 여기서 더 채운다
    if(_shown<_view.length && card.scrollHeight<=card.clientHeight+4){
      _shown=Math.min(_shown+CHUNK, _view.length); cliRender();
    }
  } finally { _fitting=false; }
}
window.addEventListener('resize', function(){ clearTimeout(window._fitT); window._fitT=setTimeout(cliFit,120); });
/* 목록 바닥 가까이 내려가면 이어서 그린다 — 카드가 스크롤 영역이라 여기에 건다.
   ★목록을 다시 그려도 이벤트가 살아 있도록 카드(고정 요소)에 한 번만 건다. */
function _bindScroll(){
  var card=document.getElementById('listCard'); if(!card || card._bound) return;
  card._bound=true;
  card.addEventListener('scroll', function(){
    if(_shown>=_view.length) return;
    if(card.scrollTop + card.clientHeight >= card.scrollHeight - 80){
      _shown=Math.min(_shown+CHUNK, _view.length); cliRender();
    }
  });
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
  // 창을 열면 곧바로 칠 수 있게(2026-08-04) — 추가는 사업장코드부터, 수정은 코드가 잠겨 있으니 사업장명부터
  var first=document.getElementById(o?'f_nm':'f_cd');
  setTimeout(function(){ if(first){ first.focus(); if(first.select) first.select(); } }, 0);
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
/* ══════════════════════════════════════════════════════════════════════════
   키보드 편의 (2026-08-04 요청) — 매입/매출 거래처·상품코드 등록 화면과 같은 규칙
     목록 : 진입 시 검색칸 포커스 · ↑↓ 줄 이동 · Enter 수정 · Alt+N 추가
     창   : Enter 다음 칸(마지막 칸에서는 저장) · Ctrl+S 저장 · Esc 닫기
   ══════════════════════════════════════════════════════════════════════════ */
function cliOvOpen(){ return document.getElementById('ov').classList.contains('on'); }
/* 창 안 이동 순서 = 화면에 보이는 순서. 비고(textarea)는 줄바꿈이 필요해 뺀다 */
var CLI_FLOW=['f_cd','f_gb','f_nm','f_snm','f_bizno','f_ceo','f_mgr','f_cond','f_item','f_zip','f_sort',
              'f_addr','f_addr2','f_tel','f_fax','f_hp','f_email'];
function cliNext(id){
  var i=CLI_FLOW.indexOf(id); if(i<0) return null;
  for(var k=i+1;k<CLI_FLOW.length;k++){
    var el=document.getElementById(CLI_FLOW[k]);
    if(el && !el.readOnly && !el.disabled) return el;      // 수정 시 잠긴 사업장코드 같은 칸은 건너뛴다
  }
  return null;                                             // 마지막 칸 = 저장
}
document.getElementById('ov').addEventListener('keydown', function(e){
  if(e.key!=='Enter') return;
  var t=e.target; if(!t || CLI_FLOW.indexOf(t.id)<0) return;   // 비고는 여기 없어 줄바꿈이 그대로 된다
  e.preventDefault();
  var nx=cliNext(t.id);
  if(nx){ nx.focus(); if(nx.select) nx.select(); }
  else cliSave();                                          // 이메일 칸에서 Enter = 저장
});
document.addEventListener('keydown', function(e){
  if((e.ctrlKey||e.metaKey) && (e.key==='s'||e.key==='S')){
    if(cliOvOpen()){ e.preventDefault(); cliSave(); }
    return;
  }
  if(e.altKey && (e.key==='n'||e.key==='N')){ e.preventDefault(); cliOpen(); return; }
  if(e.key==='Escape' && cliOvOpen()){ e.preventDefault(); cliClose(); return; }
  if(cliOvOpen()) return;                                  // 창이 떠 있으면 아래 목록 조작은 안 한다

  var t=e.target, tag=(t&&t.tagName||'').toUpperCase();
  if((tag==='INPUT'||tag==='SELECT'||tag==='TEXTAREA') && t.id!=='q') return;
  // ★검색칸의 Enter 는 건드리지 않는다 — 이 화면은 서버로 다시 조회하는 검색이라 Enter 가 [조회]다
  if(e.key==='Enter' && t.id==='q') return;
  if(e.key==='ArrowDown'){ e.preventDefault(); cliRowMove(1); }
  else if(e.key==='ArrowUp'){ e.preventDefault(); cliRowMove(-1); }
  else if(e.key==='Enter'){
    if(!_sel){ cliRowMove(1); return; }                    // 아직 고른 줄이 없으면 첫 줄부터
    e.preventDefault(); cliOpen(_sel);
  }
});
/* ↑↓ 행 이동 — 스크롤로 이어 그리는 목록이라, 끝줄에서 더 내려가면 다음 묶음을 먼저 그린다 */
function cliRowMove(d){
  var tb=document.getElementById('tb');
  var rows=Array.prototype.slice.call(tb.querySelectorAll('tr[data-cd]'));
  if(!rows.length) return;
  var i=-1;
  if(_sel) for(var k=0;k<rows.length;k++){ if(rows[k].getAttribute('data-cd')===_sel){ i=k; break; } }
  var n=(i<0) ? (d>0?0:rows.length-1) : i+d;
  if(n>=rows.length){
    if(_shown<_view.length){
      _shown=Math.min(_shown+CHUNK, _view.length); cliRender();
      rows=Array.prototype.slice.call(tb.querySelectorAll('tr[data-cd]'));
    }
    if(n>=rows.length) n=rows.length-1;                    // 맨 끝이면 제자리
  }
  if(n<0) n=0;
  var tr=rows[n]; if(!tr) return;
  cliSel(tr, tr.getAttribute('data-cd'));
  if(tr.scrollIntoView) tr.scrollIntoView({block:'nearest'});
}

cliLoad();
/* 진입하면 검색칸에 커서 — 이름을 쳐서 찾는 것이 이 화면의 첫 동작이다 */
(function(){ var q=document.getElementById('q'); if(q) q.focus(); })();
</script>
</body>
</html>
