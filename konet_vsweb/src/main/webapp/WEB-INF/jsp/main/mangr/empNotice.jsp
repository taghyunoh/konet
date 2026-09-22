<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>직원 공지사항</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<!--
  직원 공지사항 (2026-09-22 신설) — 셸 「직원 소통」 ▸ 직원 공지사항. 사이드바 iframe(logiFrame) 화면.
  · 관리자(총괄관리자 MAIN_GU 1 · 부관리자 2)만 쓰고·고치고·지운다. 읽기는 회사 직원 전원. 권한은 서버(/emp/noticeSave·noticeDel)가 다시 본다 — 화면의 단추 숨김은 편의.
  · 글만(파일·사진 없음). 본문은 줄바꿈 그대로(pre-wrap). 상단 고정(📌)은 목록 맨 위.
  · 왼쪽 = 목록(안 읽은 것은 굵게 · 읽은 사람 수) / 오른쪽 = 본문. 열면 읽음으로 남고(TBL_EMP_NOTICE_READ) 셸 배지(parent.konetEmpBadge)를 바로 갱신한다.
  · 자료 : /emp/noticeList.do · noticeGet.do · noticeSave.do · noticeDel.do — 전부 POST JSON.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --dim:#6b7a89; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 12px; height:100vh; display:flex; flex-direction:column; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:var(--dim); margin-bottom:10px; font-size:12.5px; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:10px; }
  .bar input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13.5px; background:#fff; width:260px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ background:#fff; color:var(--red); border-color:#e8b4ae; }
  .btn:disabled{ opacity:.5; cursor:default; }
  .cnt{ margin-left:auto; color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; white-space:nowrap; }
  .cnt b{ color:var(--teal); font-weight:800; }
  .cols{ display:flex; gap:12px; flex:1; min-height:0; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  .left{ width:46%; min-width:380px; }
  .right{ flex:1; min-width:0; display:flex; flex-direction:column; }
  table.g{ border-collapse:collapse; width:100%; font-size:13.5px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:8px 8px; text-align:center; position:sticky; top:0; z-index:2; white-space:nowrap; }
  table.g th:last-child{ border-right:none; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:7px 8px; vertical-align:middle; text-align:center; white-space:nowrap; }
  table.g td:last-child{ border-right:none; }
  table.g td.l{ text-align:left; white-space:normal; }
  table.g tr{ cursor:pointer; }
  table.g tr:hover td{ background:#f7faf9; }
  table.g tr.on td{ background:#e6f3f0; }
  table.g tr.unread td.l{ font-weight:800; }
  table.g td.empty{ color:var(--dim); padding:30px 0; text-align:center; }
  .pin{ color:#b06a00; }
  .readmk{ color:var(--teal); font-weight:800; }
  .readno{ color:#b8c2cc; }
  /* 본문 */
  .dhead{ padding:14px 16px 10px; border-bottom:1px solid var(--bd); }
  .dhead h3{ margin:0 0 6px; font-size:18px; line-height:1.35; word-break:break-all; }
  .dmeta{ color:var(--dim); font-size:12.5px; display:flex; gap:12px; flex-wrap:wrap; align-items:center; }
  .dmeta .act{ margin-left:auto; display:flex; gap:6px; }
  .dbody{ padding:16px; white-space:pre-wrap; word-break:break-word; line-height:1.7; font-size:14.5px; flex:1; overflow:auto; }
  .dreaders{ border-top:1px solid var(--bd); padding:10px 16px; font-size:12.5px; color:#37475a; background:#fafbfc; }
  .dreaders b{ color:var(--teal); }
  .dreaders .who{ color:var(--dim); margin-top:3px; line-height:1.6; }
  .dempty{ color:var(--dim); text-align:center; padding:60px 0; font-size:14px; }
  /* 편집 */
  .ed{ padding:14px 16px; display:flex; flex-direction:column; gap:10px; flex:1; min-height:0; }
  .ed input[type=text]{ height:38px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:15px; font-weight:700; width:100%; }
  .ed textarea{ flex:1; min-height:240px; border:1px solid var(--bd); border-radius:7px; padding:10px; font-size:14px; line-height:1.6; font-family:inherit; resize:vertical; }
  .ed label.ck{ display:flex; align-items:center; gap:6px; font-size:13px; color:#37475a; cursor:pointer; }
  .ed .row{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .ed .row .sp{ margin-left:auto; color:var(--dim); font-size:12px; }
  /* 게시 기간 (2026-09-22) */
  .tag{ display:inline-block; font-size:11px; font-weight:800; border-radius:9px; padding:1px 7px; margin-left:5px; vertical-align:1px; white-space:nowrap; }
  .tag.e{ background:#eef0f3; color:#6b7a89; border:1px solid #d8dde3; }
  .tag.s{ background:#e8f0fb; color:#2f5f9e; border:1px solid #c9dbf2; }
  .till{ color:var(--dim); font-size:11.5px; margin-left:5px; white-space:nowrap; }
  table.g tr.exp td{ color:#9aa5b1; }
  table.g tr.exp td.l{ font-weight:400; }
  .period{ display:flex; gap:6px; align-items:center; flex-wrap:wrap; font-size:13px; color:#37475a; }
  .period input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; font-family:inherit; }
  .period .qb{ height:30px; padding:0 10px; font-size:12.5px; }
  .ck{ display:inline-flex; align-items:center; gap:5px; font-size:13px; color:#37475a; cursor:pointer; white-space:nowrap; }
  .onlyadmin{ display:none; }
  body.admin .onlyadmin{ display:inline-flex; align-items:center; justify-content:center; line-height:1; }   /* 세로 가운데 — 없으면 아이콘·글자가 한 줄에 안 앉는다(2026-09-22 지적) */
  @media (max-width:900px){ .cols{ flex-direction:column; } .left{ width:auto; min-width:0; max-height:45%; } }
</style>
</head>
<body>
<div class="wrap">
  <h2>📢 직원 공지사항</h2>
  <div class="sub">관리자(총괄·부관리자)가 쓰고 직원 전원이 읽습니다. 열면 <b>읽음</b>으로 남고, 읽은 사람 수가 목록에 보입니다. 📌 은 상단 고정.</div>
  <div class="bar">
    <input type="text" id="q" placeholder="제목·본문·작성자 찾기" onkeydown="if(event.key==='Enter') load()">
    <button class="btn" onclick="load()">🔍 조회</button>
    <button class="btn btn-teal onlyadmin" onclick="editNew()">📝 새 공지</button>
    <label class="ck onlyadmin" title="게시 기간이 지났거나 아직 시작 전인 공지도 목록에 보입니다(관리자만). 끄면 직원이 보는 목록과 같습니다."><input type="checkbox" id="inclExp" checked onchange="load()"> 기간 지남·예정도 보기</label>
    <span class="cnt">공지 <b id="tot">0</b>건 · 안 읽음 <b id="unreadCnt">0</b>건</span>
  </div>
  <div class="cols">
    <div class="card left">
      <table class="g">
        <thead><tr><th style="width:34px">📌</th><th>제목</th><th style="width:80px">작성자</th><th style="width:110px">작성일</th><th style="width:44px" title="내가 읽었나">읽음</th><th style="width:60px" title="읽은 사람 수">읽은 수</th></tr></thead>
        <tbody id="lsBody"><tr><td colspan="6" class="empty">조회 중…</td></tr></tbody>
      </table>
    </div>
    <div class="card right" id="detail">
      <div class="dempty">왼쪽 목록에서 공지를 고르세요.</div>
    </div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var LIST=[], ME='', ME_NM='', ADMIN=false, CUR=0, EDIT=null, LOAD_REQ=0;
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/json'}, body: JSON.stringify(body||{}) }).then(function(r){ return r.json(); }); }
function ok(m){ _alertBox(m,{icon:'✅'}); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function ask(m, okText, okColor){ return new Promise(function(res){ _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', okColor:okColor||'blue', onOk:function(){res(true);}, onCancel:function(){res(false);} }); }); }
function fail(j){ if(j && j.login==='N'){ err(j.message||'로그인이 끊겼습니다.'); return true; } if(!j || j.result!=='OK'){ err((j&&j.message)||'처리하지 못했습니다.'); return true; } return false; }
function badge(){ try{ if(parent && typeof parent.konetEmpBadge==='function') parent.konetEmpBadge(); }catch(e){} }

/* ── 게시 기간 (2026-09-22) — 서버는 'YYYYMMDD', 화면 날짜칸은 'YYYY-MM-DD' ── */
function ymd(s){ s=(s||'').replace(/[^0-9]/g,''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function md(s){ s=(s||'').replace(/[^0-9]/g,''); return s.length===8 ? (+s.slice(4,6))+'/'+(+s.slice(6,8)) : ''; }
function todayIso(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function statTag(n){ return n.stat==='E' ? '<span class="tag e" title="게시 기간이 지나 직원에게 안 보입니다">기간 지남</span>'
                          : n.stat==='S' ? '<span class="tag s" title="게시 시작일 전이라 직원에게 아직 안 보입니다">게시 예정</span>' : ''; }
function periodTxt(n){
  var s=ymd(n.startDt), e=ymd(n.endDt);
  if(!s && !e) return '무기한';
  return (s||'처음부터')+' ~ '+(e||'계속');
}
/* 「게시일부터 며칠간」(2026-09-22 「개시한 날부터 며칠까지」) — 게시일도 하루로 센다 : 7일간 = 게시일 + 6일까지.
   일수를 넣으면 종료일을 세고, 종료일을 고르면 일수를 센다. 일수가 비면(0) 무기한. 저장은 시작일·종료일 그대로 */
function isoOf(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function dOf(iso){ var p=(iso||'').split('-'); return p.length===3 ? new Date(+p[0], +p[1]-1, +p[2]) : null; }
function daysLeft(endDt){ var e=dOf(ymd(endDt)); if(!e) return null; var t=dOf(todayIso()); return Math.round((e-t)/86400000); }
function periodFromDays(){
  var st=document.getElementById('edStart'), dy=document.getElementById('edDays'), en=document.getElementById('edEnd');
  var n=parseInt(dy.value,10);
  if(!(n>0)){ en.value=''; return; }                 /* 비었거나 0 = 무기한 */
  if(!st.value) st.value=todayIso();
  var d=dOf(st.value); d.setDate(d.getDate()+n-1); en.value=isoOf(d);
}
function periodToDays(){
  var st=document.getElementById('edStart'), dy=document.getElementById('edDays'), en=document.getElementById('edEnd');
  if(!en.value){ dy.value=''; return; }
  if(!st.value) st.value=todayIso();
  var n=Math.round((dOf(en.value)-dOf(st.value))/86400000)+1;
  dy.value = n>0 ? n : '';
}
function periodDays(n){ document.getElementById('edDays').value = n>0 ? n : ''; periodFromDays(); }
function inclExp(){ var c=document.getElementById('inclExp'); return (ADMIN && c && c.checked) ? 'Y' : 'N'; }

/* ── 목록 ── */
function load(keep){
  var my=++LOAD_REQ;
  post('/emp/noticeList.do',{findData:document.getElementById('q').value, inclExp:inclExp()}).then(function(j){
    if(my!==LOAD_REQ) return;                       /* 더 새 조회가 나갔으면 옛 응답은 버린다 */
    var firstAdmin=(!ADMIN && j && j.admin==='Y');   /* 첫 조회는 ADMIN 을 몰라 게시 중인 것만 왔다 — 관리자면 한 번 더(기간 지남·예정 포함) */
    if(fail(j)) return;
    ME=j.me||''; ME_NM=j.meNm||''; ADMIN=(j.admin==='Y');
    document.body.classList.toggle('admin', ADMIN);
    LIST=j.list||[];
    render();
    if(firstAdmin && inclExp()==='Y'){ load(keep); return; }
    if(!keep && CUR && !LIST.some(function(n){ return n.noticeSeq===CUR; })){ CUR=0; showEmpty(); }
  }).catch(function(){ if(my===LOAD_REQ) err('목록을 읽지 못했습니다.'); });
}
function render(){
  var tb=document.getElementById('lsBody'), h='', unread=0;
  LIST.forEach(function(n){
    var un=(n.readYn!=='Y'); if(un && !n.stat) unread++;          /* 안 읽음 = 게시 중인 것만 센다 */
    h+='<tr data-seq="'+n.noticeSeq+'" class="'+(un&&!n.stat?'unread':'')+(n.stat?' exp':'')+(n.noticeSeq===CUR?' on':'')+'" onclick="open_('+n.noticeSeq+')">'
      +'<td>'+(n.pinYn==='Y'?'<span class="pin" title="상단 고정">📌</span>':'')+'</td>'
      +'<td class="l">'+esc(n.title)+statTag(n)+(n.endDt && !n.stat?'<span class="till" title="게시 종료일 — 이 날까지 보입니다">~'+md(n.endDt)+' · '+(daysLeft(n.endDt)>0?'남은 '+daysLeft(n.endDt)+'일':'오늘까지')+'</span>':'')+'</td>'
      +'<td>'+esc(n.regNm)+'</td>'
      +'<td>'+esc((n.regDttm||'').slice(0,16))+'</td>'
      +'<td>'+(un?'<span class="readno">—</span>':'<span class="readmk">✔</span>')+'</td>'
      +'<td>'+esc(n.readCnt)+'</td></tr>';
  });
  tb.innerHTML=h||'<tr><td colspan="6" class="empty">'+(document.getElementById('q').value?'찾은 공지가 없습니다.':'등록된 공지가 없습니다.'+(ADMIN?' [📝 새 공지]로 첫 공지를 쓰세요.':''))+'</td></tr>';
  document.getElementById('tot').textContent=LIST.length;
  document.getElementById('unreadCnt').textContent=unread;
}
function showEmpty(){ document.getElementById('detail').innerHTML='<div class="dempty">왼쪽 목록에서 공지를 고르세요.</div>'; }

/* ── 본문 ── */
function open_(seq){
  if(EDIT && !confirmLeaveEdit()) return;
  post('/emp/noticeGet.do',{noticeSeq:seq}).then(function(j){
    if(fail(j)){ if(j&&j.result!=='OK') load(true); return; }
    EDIT=null; CUR=seq;
    var n=j.notice; ADMIN=(j.admin==='Y');
    var row=LIST.filter(function(x){ return x.noticeSeq===seq; })[0];
    if(row && row.readYn!=='Y'){ row.readYn='Y'; row.readCnt=(Number(row.readCnt)||0)+1; badge(); }
    render();
    var readers=n.readers||[];
    var who=readers.map(function(r){ return esc(r.userNm)+' <small>'+esc((r.readDttm||'').slice(5,16))+'</small>'; }).join(' · ');
    document.getElementById('detail').innerHTML=
      '<div class="dhead"><h3>'+(n.pinYn==='Y'?'<span class="pin">📌</span> ':'')+esc(n.title)+statTag(n)+'</h3>'
      +'<div class="dmeta"><span>✍ '+esc(n.regNm||n.regUser)+'</span><span>🕒 '+esc(n.regDttm)+(n.updDttm?' <span title="고친 때">(고침 '+esc(n.updDttm)+')</span>':'')+'</span>'
      +'<span title="이 기간에만 직원에게 보입니다">📅 게시 '+esc(periodTxt(n))+'</span>'
      +(ADMIN?'<span class="act"><button class="btn" onclick="editCur()">📝 수정</button><button class="btn btn-red" onclick="delCur()">🗑 삭제</button></span>':'')
      +'</div></div>'
      +'<div class="dbody">'+esc(n.content)+'</div>'
      +'<div class="dreaders">읽은 사람 <b>'+readers.length+'</b>명'+(ADMIN&&readers.length?'<div class="who">'+who+'</div>':'')+'</div>';
  }).catch(function(){ err('공지를 읽지 못했습니다.'); });
}

/* ── 쓰기·고치기·지우기 (관리자) ── */
function editForm(n){
  EDIT={ noticeSeq:n?n.noticeSeq:0 };
  document.getElementById('detail').innerHTML=
    '<div class="ed">'
    +'<div class="row"><b style="font-size:15px">'+(n?'📝 공지 수정':'📝 새 공지')+'</b><span class="sp">작성자 '+esc(ME_NM||ME)+'</span></div>'
    +'<input type="text" id="edTitle" maxlength="200" placeholder="제목 (200자까지)" value="'+esc(n?n.title:'')+'">'
    +'<textarea id="edBody" placeholder="본문 — 줄바꿈 그대로 보입니다. 파일·사진은 넣을 수 없습니다.">'+esc(n?n.content:'')+'</textarea>'
    +'<div class="period" title="이 기간에만 직원 목록·하단 흐름 띠·우측 패널·안 읽음 배지에 보입니다. 종료일을 비우면 무기한.">'
    +'<b>📅 게시일</b> <input type="date" id="edStart" value="'+esc(n?(ymd(n.startDt)||ymd((n.regDttm||'').slice(0,10))):todayIso())+'" onchange="periodFromDays()"> 부터 '
    +'<input type="number" id="edDays" min="1" max="3650" style="width:70px;height:34px;border:1px solid var(--bd);border-radius:7px;padding:0 8px;font-size:13.5px;text-align:right" placeholder="무기한" oninput="periodFromDays()"> 일간'
    +' → 종료 <input type="date" id="edEnd" value="'+esc(n?ymd(n.endDt):'')+'" onchange="periodToDays()">'
    +'<button type="button" class="btn qb" onclick="periodDays(7)">7일</button><button type="button" class="btn qb" onclick="periodDays(30)">30일</button>'
    +'<button type="button" class="btn qb" onclick="periodDays(90)">90일</button><button type="button" class="btn qb" onclick="periodDays(0)">무기한</button>'
    +'<span style="color:var(--dim);font-size:12px">게시일도 하루로 셉니다 · 비우면 무기한</span></div>'
    +'<div class="row"><label class="ck"><input type="checkbox" id="edPin" '+(n&&n.pinYn==='Y'?'checked':'')+'> 📌 상단 고정</label>'
    +'<span style="color:var(--dim);font-size:12px">새 공지가 올라와도 목록·하단 흐름 띠 맨 위에 둡니다 (게시 기간이 끝나면 함께 사라짐)</span>'
    +'<span class="sp"></span><button class="btn btn-teal" id="edSave" onclick="save()">💾 저장</button><button class="btn" onclick="cancelEdit()">취소</button></div>'
    +'</div>';
  periodToDays();                                   /* 저장된 시작·종료일 → 「며칠간」 칸 */
  document.getElementById('edTitle').focus();
}
function editNew(){ if(!ADMIN) return; if(EDIT && !confirmLeaveEdit()) return; CUR=0; render(); editForm(null); }
function editCur(){
  if(!ADMIN||!CUR) return;
  post('/emp/noticeGet.do',{noticeSeq:CUR}).then(function(j){ if(fail(j)) return; editForm(j.notice); }).catch(function(){ err('공지를 읽지 못했습니다.'); });
}
function confirmLeaveEdit(){
  var t=document.getElementById('edTitle'), b=document.getElementById('edBody');
  if(!t||!b) { EDIT=null; return true; }
  if(!t.value.trim() && !b.value.trim()){ EDIT=null; return true; }
  /* 입력한 것이 있으면 조용히 버리지 않는다 — 다른 공지를 열려면 먼저 취소를 누르게 */
  _alertBox('쓰던 공지가 있습니다. 먼저 [저장] 또는 [취소]를 눌러 주세요.',{icon:'⚠️'});
  return false;
}
function cancelEdit(){ EDIT=null; if(CUR) open_(CUR); else showEmpty(); }
function save(){
  var t=document.getElementById('edTitle').value.trim(), b=document.getElementById('edBody').value;
  if(!t){ _alertBox('제목을 입력하세요.',{icon:'⚠️'}); document.getElementById('edTitle').focus(); return; }
  if(!b.trim()){ _alertBox('본문을 입력하세요.',{icon:'⚠️'}); document.getElementById('edBody').focus(); return; }
  var sd=document.getElementById('edStart').value, ed=document.getElementById('edEnd').value;
  if(sd && ed && ed<sd){ _alertBox('게시 종료일이 시작일보다 앞입니다.',{icon:'⚠️'}); document.getElementById('edEnd').focus(); return; }
  var btn=document.getElementById('edSave'); btn.disabled=true;
  post('/emp/noticeSave.do',{ noticeSeq:EDIT?EDIT.noticeSeq:0, title:t, content:b, pinYn:document.getElementById('edPin').checked?'Y':'N', startDt:sd, endDt:ed }).then(function(j){
    btn.disabled=false;
    if(fail(j)) return;
    _toast('공지를 저장했습니다.','ok');
    EDIT=null; CUR=j.noticeSeq||CUR;
    var my=++LOAD_REQ;
    post('/emp/noticeList.do',{findData:document.getElementById('q').value, inclExp:inclExp()}).then(function(k){ if(my!==LOAD_REQ||fail(k)) return; LIST=k.list||[]; render(); open_(CUR); badge(); });
  }).catch(function(){ btn.disabled=false; err('저장하지 못했습니다.'); });
}
function delCur(){
  if(!ADMIN||!CUR) return;
  var row=LIST.filter(function(x){ return x.noticeSeq===CUR; })[0];
  ask('이 공지를 지울까요?<br><b>'+esc(row?row.title:'')+'</b><br><small>지운 공지는 목록에서 사라집니다.</small>','삭제','red').then(function(y){
    if(!y) return;
    post('/emp/noticeDel.do',{noticeSeq:CUR}).then(function(j){ if(fail(j)) return; _toast('지웠습니다.','ok'); CUR=0; showEmpty(); load(); badge(); }).catch(function(){ err('지우지 못했습니다.'); });
  });
}

/* 셸이 이 화면을 다시 보일 때 부른다(logiFrame) — 새 공지가 있으면 목록에 나오게 */
window.konetShown=function(){ if(!EDIT) load(true); };
/* 60초마다 조용히 목록만 — 다른 관리자가 올린 공지 */
setInterval(function(){ if(!document.hidden && !EDIT) load(true); }, 60000);
load();
</script>
</body>
</html>
