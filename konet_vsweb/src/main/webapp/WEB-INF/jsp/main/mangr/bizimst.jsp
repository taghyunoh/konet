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
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  /* ★max-width:880px + 가운데 정렬 해제 (2026-08-03) — 이 화면만 가운데로 몰려 있어 넓은 모니터에서
       좌우 여백이 다른 화면(0.3cm)과 크게 달라 보였다. 이제 다른 관리 화면과 같은 전체폭. */
  .wrap{ padding:14px 11px 16px; }
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
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
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
      <%-- 택배 정보(2026-08-06 신설) — 택배출고관리 엑셀이 쓰는 값. 주소는 택배주소 우선, 없으면 기본주소 --%>
      <thead><tr><th style="width:130px">사업장코드</th><th>사업장명</th>
        <th style="width:290px">택배주소</th><th style="width:130px">수령자</th><th style="width:120px">택배전화</th><th style="width:120px">택배휴대폰</th><th style="width:84px">기본운임</th>
        <th style="width:150px">관리</th></tr></thead>
      <tbody id="tb"><tr><td colspan="8" class="empty">불러오는 중…</td></tr></tbody>
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
  if(!tot){ tb.innerHTML='<tr><td colspan="8" class="empty">등록된 사업장이 없습니다. ＋ 사업장 추가</td></tr>'; _renderPager(0,1); return; }
  var start=(_page-1)*PAGE_SIZE, rows=_view.slice(start, start+PAGE_SIZE);
  tb.innerHTML = rows.map(function(o){
    var cd=esc(o.bizCd), nm=esc(o.bizNm);
    /* 택배주소가 비면 기본주소를 흐리게 안내(placeholder) — 실제 저장은 택배주소 칸 값만 */
    var pa=esc(o.parcelAddr||''), pt=esc(o.parcelTel||''), ph=esc(o.parcelHp||''), pf=(o.parcelFee==null?'':o.parcelFee);
    return '<tr data-cd="'+cd+'">'
      + '<td class="code">'+cd+'</td>'
      + '<td><input class="nm" value="'+nm+'" data-orig="'+nm+'" oninput="biziDirty(this)"></td>'
      + '<td><input class="nm pa" value="'+pa+'" placeholder="'+(esc(o.addr||'')||'택배주소')+'" title="비우면 기본주소를 씁니다"></td>'
      + '<td><input class="nm pn" value="'+esc(o.parcelNm||'')+'" placeholder="수령자"></td>'
      + '<td><input class="nm pt" value="'+pt+'" placeholder="'+(esc(o.tel||'')||'전화')+'"></td>'
      + '<td><input class="nm ph" value="'+ph+'" placeholder="'+(esc(o.hp||'')||'휴대폰')+'"></td>'
      + '<td><input class="nm pf" value="'+pf+'" placeholder="4500" inputmode="numeric" style="text-align:right"></td>'
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
    + '<td><input class="nm pa" placeholder="택배주소"></td>'
    + '<td><input class="nm pn" placeholder="수령자"></td>'
    + '<td><input class="nm pt" placeholder="전화"></td>'
    + '<td><input class="nm ph" placeholder="휴대폰"></td>'
    + '<td><input class="nm pf" placeholder="4500" inputmode="numeric" style="text-align:right"></td>'
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

/* 저장 = 사업장명(biziUpdate) + 택배정보(biziParcelUpdate) 함께 (2026-08-06) */
function biziSaveRow(btn){
  var tr=btn.closest('tr'), cd=tr.getAttribute('data-cd'), inp=tr.querySelector('.nm');
  var nm=(inp.value||'').trim();
  if(!nm){ toast('⚠️ 사업장명을 입력하세요.'); return; }
  var pa=(tr.querySelector('.pa').value||'').trim(), pt=(tr.querySelector('.pt').value||'').trim();
  var ph=(tr.querySelector('.ph').value||'').trim(), pfv=(tr.querySelector('.pf').value||'').trim();
  var pn=(tr.querySelector('.pn').value||'').trim();
  var pf=pfv===''?null:Number(pfv.replace(/,/g,''));
  _post('/mangr/biziUpdate.do', [{bizCd:cd, bizNm:nm}], '💾 저장됨: '+cd).then(function(ok){
    if(!ok) return;
    _post('/mangr/biziParcelUpdate.do', [{bizCd:cd, parcelAddr:pa, parcelNm:pn, parcelTel:pt, parcelHp:ph, parcelFee:pf}], '💾 저장됨: '+cd)
      .then(function(){ inp.setAttribute('data-orig', nm); inp.classList.remove('dirty'); biziLoad(); });
  });
}

function biziInsertRow(btn){
  var tr=btn.closest('tr'), cd=(tr.querySelector('.cd').value||'').trim(), nm=(tr.querySelector('.nm').value||'').trim();
  if(!cd){ toast('⚠️ 사업장코드를 입력하세요.'); return; }
  if(!nm){ toast('⚠️ 사업장명을 입력하세요.'); return; }
  var pa=(tr.querySelector('.pa').value||'').trim(), pt=(tr.querySelector('.pt').value||'').trim();
  var ph=(tr.querySelector('.ph').value||'').trim(), pfv=(tr.querySelector('.pf').value||'').trim();
  var pn=(tr.querySelector('.pn').value||'').trim();
  var pf=pfv===''?null:Number(pfv.replace(/,/g,''));
  _post('/mangr/biziInsert.do', [{bizCd:cd, bizNm:nm}], '＋ 등록: '+cd).then(function(ok){
    if(!ok) return;
    if(pa||pn||pt||ph||pf!=null){
      _post('/mangr/biziParcelUpdate.do', [{bizCd:cd, bizNm:nm, parcelAddr:pa, parcelNm:pn, parcelTel:pt, parcelHp:ph, parcelFee:pf}], '＋ 등록: '+cd)
        .then(function(){ biziLoad(); });
    } else biziLoad();
  });
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
