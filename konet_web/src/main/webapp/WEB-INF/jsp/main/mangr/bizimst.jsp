<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>사업장 분류 관리 (TBL_BIZI_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  body{ margin:0; font-family:'맑은 고딕',Malgun Gothic,sans-serif; color:#1f2a37; background:var(--bg); font-size:13.5px; }
  .wrap{ max-width:880px; margin:0 auto; padding:22px 20px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:16px; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:240px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-teal:hover{ filter:brightness(1.06); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:auto; color:#6b7a89; font-size:12.5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:hidden; }
  table{ width:100%; border-collapse:collapse; font-size:13px; }
  thead th{ background:#1f2a37; color:#fff; font-weight:700; padding:10px 12px; text-align:left; position:sticky; top:0; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:7px 12px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  td.code{ font-family:Consolas,monospace; white-space:nowrap; }
  td input.cd{ width:120px; height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-family:Consolas,monospace; }
  td input.nm{ width:100%; height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; }
  td input.nm.dirty{ border-color:#e8941f; background:#fff8ee; }
  td input.cd[readonly]{ background:#f2f4f7; color:#566; border-color:#eef1f5; }
  .act{ white-space:nowrap; }
  .act .btn{ height:28px; padding:0 10px; font-size:12px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  #msg{ position:fixed; left:50%; bottom:26px; transform:translateX(-50%); background:#1f2a37; color:#fff; padding:10px 18px; border-radius:9px; font-size:13px; opacity:0; transition:opacity .2s; pointer-events:none; z-index:50; }
  #msg.on{ opacity:1; }
  .note{ margin-top:12px; color:#8a98a8; font-size:12px; line-height:1.6; }
  .pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin-top:14px; flex-wrap:wrap; }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button:hover:not(:disabled){ border-color:var(--teal); }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
</style>
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<div class="wrap">
  <h2>🏢 사업장 분류 관리</h2>
  <div class="sub">출고현황표 업로드 시 <b>품목명 앞 ()가 없는</b> 품목은 이 표의 <b>사업장명</b>으로 묶음 분류됩니다. 사업장명을 바꾸면 <b>재조회·재업로드 시</b> 그 이름으로 묶입니다. (TBL_BIZI_MST)</div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="사업장코드/명 검색" oninput="biziFilter()">
    <button class="btn" onclick="biziLoad()">↻ 새로고침</button>
    <button class="btn btn-teal" onclick="biziAddRow()">＋ 사업장 추가</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="card">
    <table>
      <thead><tr><th style="width:160px">사업장코드</th><th>사업장명</th><th style="width:150px">관리</th></tr></thead>
      <tbody id="tb"><tr><td colspan="3" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>

  <div id="pager" class="pager"></div>

  <div class="note">
    · <b>저장</b>: 기존 사업장은 사업장명 수정, 신규 행은 등록(이미 있는 코드면 무시).<br>
    · <b>삭제</b>: 비활성화(ACTION_YN='N')되어 분류에서 제외됩니다.<br>
    · 업로드 자동등록은 "없을 때만" 신규 추가하며, 여기서 바꾼 사업장명은 덮어쓰지 않습니다.
  </div>
</div>
<div id="msg"></div>


<script>
var CTX = '${ctx}';
var BIZI = [];        // 원본 목록 캐시
var PAGE_SIZE = 15;   // 페이지당 건수
var _view = [];       // 현재 필터 적용된 목록
var _page = 1;        // 현재 페이지

function toast(s){ var m=document.getElementById('msg'); m.innerHTML=s; m.classList.add('on'); clearTimeout(m._t); m._t=setTimeout(function(){ m.classList.remove('on'); }, 2600); }
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function biziLoad(){
  fetch(CTX+'/mangr/biziList.do', { method:'POST', credentials:'same-origin' })
    .then(function(r){ return r.text(); })
    .then(function(txt){
      var j; try{ j=JSON.parse(txt); }catch(e){ toast('⚠️ 목록 응답 오류'); return; }
      BIZI = (j&&j.data)||[];
      biziRender(BIZI);
    })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}


function biziRender(list, keepPage){
  _view = list || [];
  if(!keepPage) _page = 1;
  var tot=_view.length, pages=Math.max(1, Math.ceil(tot/PAGE_SIZE));
  if(_page>pages) _page=pages;
  document.getElementById('cnt').textContent = tot+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="3" class="empty">등록된 사업장이 없습니다. ＋ 사업장 추가</td></tr>'; _renderPager(0,1); return; }
  var start=(_page-1)*PAGE_SIZE, rows=_view.slice(start, start+PAGE_SIZE);
  tb.innerHTML = rows.map(function(o){
    var cd=esc(o.bizCd), nm=esc(o.bizNm);
    return '<tr data-cd="'+cd+'">'
      + '<td class="code">'+cd+'</td>'
      + '<td><input class="nm" value="'+nm+'" data-orig="'+nm+'" oninput="biziDirty(this)"></td>'
      + '<td class="act">'
        + '<button class="btn btn-teal" onclick="biziSaveRow(this)">저장</button> '
        + '<button class="btn btn-danger" onclick="biziDelRow(this)">삭제</button>'
      + '</td></tr>';
  }).join('');
  _renderPager(pages, _page);
}


function _gotoPage(p){ _page=p; biziRender(_view, true); var c=document.querySelector('.wrap'); if(c) c.scrollIntoView({block:'start'}); }

function _renderPager(pages, cur){
  var el=document.getElementById('pager'); if(!el) return;
  if(pages<=1){ el.innerHTML=''; return; }
  var h='<button '+(cur<=1?'disabled':'')+' onclick="_gotoPage('+(cur-1)+')">‹</button>';
  var from=Math.max(1, cur-3), to=Math.min(pages, cur+3);
  if(from>1){ h+='<button onclick="_gotoPage(1)">1</button>'; if(from>2) h+='<span class="ell">…</span>'; }
  for(var p=from;p<=to;p++){ h+='<button class="'+(p===cur?'on':'')+'" onclick="_gotoPage('+p+')">'+p+'</button>'; }
  if(to<pages){ if(to<pages-1) h+='<span class="ell">…</span>'; h+='<button onclick="_gotoPage('+pages+')">'+pages+'</button>'; }
  h+='<button '+(cur>=pages?'disabled':'')+' onclick="_gotoPage('+(cur+1)+')">›</button>';
  el.innerHTML=h;
}

function biziDirty(inp){ inp.classList.toggle('dirty', inp.value !== inp.getAttribute('data-orig')); }

function biziFilter(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  if(!q){ biziRender(BIZI); return; }
  biziRender(BIZI.filter(function(o){ return ((''+o.bizCd).toLowerCase().indexOf(q)>=0)||((''+(o.bizNm||'')).toLowerCase().indexOf(q)>=0); }));
}

function biziAddRow(){
  var tb=document.getElementById('tb');
  if(tb.querySelector('.empty')) tb.innerHTML='';
  var tr=document.createElement('tr'); tr.className='neww';
  tr.innerHTML='<td><input class="cd" placeholder="A0000000"></td>'
    + '<td><input class="nm dirty" placeholder="사업장명"></td>'
    + '<td class="act"><button class="btn btn-teal" onclick="biziInsertRow(this)">등록</button> '
    + '<button class="btn" onclick="this.closest(\'tr\').remove()">취소</button></td>';
  tb.insertBefore(tr, tb.firstChild);
  tr.querySelector('.cd').focus();
}

function _post(url, payload, okMsg){
  return fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(payload) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){
      if(!r.ok){ toast('⚠️ 실패 (HTTP '+r.status+'): '+(r.t||'').slice(0,150)); return false; }
      toast(okMsg); return true;
    })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); return false; });
}

function biziSaveRow(btn){
  var tr=btn.closest('tr'), cd=tr.getAttribute('data-cd'), inp=tr.querySelector('.nm');
  var nm=(inp.value||'').trim();
  if(!nm){ toast('⚠️ 사업장명을 입력하세요.'); return; }
  _post('/mangr/biziUpdate.do', [{bizCd:cd, bizNm:nm}], '💾 저장됨: '+cd).then(function(ok){ if(ok){ inp.setAttribute('data-orig', nm); inp.classList.remove('dirty'); biziLoad(); } });
}

function biziInsertRow(btn){
  var tr=btn.closest('tr'), cd=(tr.querySelector('.cd').value||'').trim(), nm=(tr.querySelector('.nm').value||'').trim();
  if(!cd){ toast('⚠️ 사업장코드를 입력하세요.'); return; }
  if(!nm){ toast('⚠️ 사업장명을 입력하세요.'); return; }
  _post('/mangr/biziInsert.do', [{bizCd:cd, bizNm:nm}], '＋ 등록: '+cd).then(function(ok){ if(ok) biziLoad(); });
}

function biziDelRow(btn){
  var tr=btn.closest('tr'), cd=tr.getAttribute('data-cd');
  if(!confirm('['+cd+'] 사업장을 삭제(분류 제외)하시겠습니까?')) return;
  _post('/mangr/biziDelete.do', [{bizCd:cd}], '🗑️ 삭제됨: '+cd).then(function(ok){ if(ok) biziLoad(); });
}

biziLoad();
</script>
</body>
</html>
