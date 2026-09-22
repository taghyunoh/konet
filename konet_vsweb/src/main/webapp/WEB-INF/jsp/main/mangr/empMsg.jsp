<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>직원 메신저</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<!--
  직원 메신저 (2026-09-22 신설) — 셸 「직원 소통」 ▸ 직원 메신저. 사이드바 iframe(logiFrame) 화면.
  · 1:1 + 그룹방. 글만(파일·사진 없음). 같은 회사(COMP_CD) 직원끼리만.
  · 왼쪽 = 내 대화방(안 읽은 수·마지막 글) / 오른쪽 = 글(내 글은 오른쪽 청록, 남의 글은 왼쪽 흰색, 안내 글은 가운데 회색).
  · 새 글은 <묻기>로 받는다(폴링) — 보고 있는 방 4초 · 방 목록 15초 · 탭이 숨으면 쉼. 서버 푸시(웹소켓)는 안 쓴다(톰캣 8.5 + 셸 iframe 구조에 맞춤, 필요하면 그때).
  · 읽음 = 글을 받아 그린 순간 서버가 LAST_READ_SEQ 를 올린다(/emp/msgList.do). 셸 배지는 parent.konetEmpBadge() 로 바로 갱신.
  · Enter = 보내기 · Shift+Enter = 줄바꿈. 한글 조합 중(isComposing) Enter 는 무시.
  · 자료 : /emp/users.do · roomList.do · roomOpen.do · msgList.do · msgSend.do · roomLeave.do · roomInvite.do · roomRename.do — 전부 POST JSON.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --teal2:#e3f2ef; --bg:#f5f7f9; --red:#c0392b; --dim:#6b7a89; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:12px 11px 12px; height:100vh; display:flex; flex-direction:column; }
  .top{ display:flex; align-items:center; gap:10px; margin-bottom:10px; }
  .top h2{ margin:0; font-size:20px; }
  .top .sub{ color:var(--dim); font-size:12.5px; }
  .top .sub b{ color:var(--teal); }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ background:#fff; color:var(--red); border-color:#e8b4ae; }
  .btn-sm{ height:28px; padding:0 10px; font-size:12px; }
  .btn:disabled{ opacity:.5; cursor:default; }
  .cols{ display:flex; gap:12px; flex:1; min-height:0; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:hidden; display:flex; flex-direction:column; }
  .left{ width:300px; min-width:240px; }
  .right{ flex:1; min-width:0; }
  /* 방 목록 */
  .lhd{ padding:10px 12px; border-bottom:1px solid var(--bd); display:flex; align-items:center; gap:8px; }
  .lhd b{ font-size:14px; }
  .rooms{ overflow:auto; flex:1; }
  .room{ padding:10px 12px; border-bottom:1px solid #eef1f5; cursor:pointer; display:flex; gap:9px; align-items:center; }
  .room:hover{ background:#f7faf9; }
  .room.on{ background:var(--teal2); }
  .room .av{ width:36px; height:36px; border-radius:50%; background:#dfe8e5; color:var(--teal); font-weight:800; display:flex; align-items:center; justify-content:center; flex:none; font-size:14px; }
  .room .av.g{ background:#e9e2f5; color:#5b3fa0; }
  .room .bd{ flex:1; min-width:0; }
  .room .nm{ font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; font-size:13.5px; }
  .room .nm small{ color:var(--dim); font-weight:400; margin-left:4px; }
  .room .lt{ color:var(--dim); font-size:12px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; margin-top:2px; }
  .room .rt{ text-align:right; flex:none; }
  .room .tm{ color:#9aa7b3; font-size:11px; }
  .room .un{ display:inline-block; background:#e74c3c; color:#fff; font-size:11px; font-weight:800; border-radius:10px; padding:1px 7px; min-width:18px; text-align:center; margin-top:3px; }
  .room.unread .nm{ font-weight:900; color:#0f2b3a; }
  .room .rdel{ flex:none; width:28px; height:28px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; font-size:15px; opacity:0; background:#eef1f5; border:1px solid #dbe2ea; cursor:pointer; }   /* 대화 지우기 (2026-09-22) — 줄에 마우스를 올리면 보인다 */
  .room:hover .rdel{ opacity:.8; }
  .room .rdel:hover{ opacity:1; background:#fdecea; border-color:#e8b4ae; }
  .rempty{ color:var(--dim); text-align:center; padding:30px 12px; font-size:13px; line-height:1.7; }
  /* 대화 */
  .chd{ padding:10px 14px; border-bottom:1px solid var(--bd); display:flex; align-items:center; gap:8px; }
  .chd .t{ font-weight:800; font-size:15px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .chd .m{ color:var(--dim); font-size:12px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; flex:1; min-width:0; }
  .chd .act{ display:flex; gap:6px; margin-left:auto; }
  .msgs{ flex:1; overflow:auto; padding:12px 14px; background:#f8fafb; }
  .more{ text-align:center; margin-bottom:8px; }
  .day{ text-align:center; color:#8a98a8; font-size:11.5px; margin:10px 0 8px; }
  .day span{ background:#e6ebef; border-radius:10px; padding:2px 10px; }
  .sys{ text-align:center; color:#8a98a8; font-size:12px; margin:6px 0; }
  .m{ display:flex; margin:4px 0; align-items:flex-end; gap:6px; }
  .m.me{ flex-direction:row-reverse; }
  .m .bub{ max-width:100%; padding:8px 11px; border-radius:12px; background:#fff; border:1px solid var(--bd); white-space:pre-wrap; word-break:break-word; line-height:1.55; font-size:14px; }
  .m.me .bub{ background:var(--teal); color:#fff; border-color:var(--teal); border-bottom-right-radius:3px; }
  .m.other .bub{ border-bottom-left-radius:3px; }
  .m .who{ font-size:11.5px; color:var(--dim); margin:0 0 2px 2px; }
  .m .tm{ font-size:10.5px; color:#9aa7b3; white-space:nowrap; }
  .m .stack{ display:flex; flex-direction:column; max-width:68%; }   /* ★최대폭은 여기에 — 말풍선(.bub)에 %를 걸면 부모(.stack)가 내용 폭이라 서로 참조해 말풍선이 세로로 길어지고 오른쪽이 잘렸다(2026-09-22 캡처) */
  .m.me .stack{ align-items:flex-end; }
  /* 내 글 지우기 🗑 (2026-09-22) — 늘 흐리게 보이고(있는 줄 알게), 마우스를 올리면 또렷·빨강. 「너무 작다」 지적으로 12px → 20px 원 단추 */
  .m .del{ display:inline-flex; align-items:center; justify-content:center; width:32px; height:32px; border-radius:50%; font-size:20px; line-height:1; cursor:pointer; align-self:center; opacity:.35; background:#eef1f5; border:1px solid #dbe2ea; }
  .m.me:hover .del{ opacity:1; }
  .m .del:hover{ background:#fdecea; border-color:#e8b4ae; }
  .m .bub.deleted{ background:#eef1f5 !important; color:#8a98a8 !important; border:1px dashed #cfd8e0 !important; font-style:italic; }
  .cempty{ color:var(--dim); text-align:center; padding:60px 20px; font-size:14px; line-height:1.8; }
  .inp{ border-top:1px solid var(--bd); padding:10px 12px; display:flex; gap:8px; align-items:flex-end; }
  .inp textarea{ flex:1; min-height:44px; max-height:140px; border:1px solid var(--bd); border-radius:8px; padding:9px 10px; font-size:14px; font-family:inherit; resize:none; line-height:1.5; }
  .inp .hint{ font-size:11px; color:#9aa7b3; white-space:nowrap; }
  /* 상대 고르기 팝업 */
  .pop{ display:none; position:fixed; inset:0; background:rgba(15,43,58,.45); z-index:50; align-items:center; justify-content:center; }
  .pop.on{ display:flex; }
  .pop .box{ background:#fff; border-radius:14px; width:460px; max-width:94vw; max-height:88vh; display:flex; flex-direction:column; box-shadow:0 18px 50px rgba(0,0,0,.25); }
  .pop .hd{ padding:14px 16px; border-bottom:1px solid var(--bd); font-weight:800; font-size:15px; display:flex; align-items:center; }
  .pop .hd .x{ margin-left:auto; cursor:pointer; color:var(--dim); font-size:20px; line-height:1; }
  .pop .bd{ padding:12px 16px; overflow:auto; flex:1; }
  .pop input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13.5px; width:100%; }
  .pop .ulist{ margin-top:8px; border:1px solid var(--bd); border-radius:8px; max-height:300px; overflow:auto; }
  .pop .u{ display:flex; align-items:center; gap:9px; padding:8px 10px; border-bottom:1px solid #eef1f5; cursor:pointer; }
  .pop .u:hover{ background:#f7faf9; }
  .pop .u .nm{ font-weight:700; }
  .pop .u .id{ color:var(--dim); font-size:12px; }
  .pop .u .gu{ margin-left:auto; color:var(--teal); font-size:12px; }
  .pop .u.dis{ opacity:.45; cursor:default; }
  .pop .ft{ padding:12px 16px; border-top:1px solid var(--bd); display:flex; gap:8px; align-items:center; }
  .pop .ft .sel{ color:#37475a; font-size:13px; flex:1; }
  .pop .ft .sel b{ color:var(--teal); }
  .pop .gnm{ margin-top:10px; display:none; }
  .pop .gnm.on{ display:block; }
  .pop .gnm label{ font-size:12.5px; color:#37475a; display:block; margin-bottom:4px; }
  @media (max-width:820px){ .left{ width:220px; min-width:180px; } .m .bub{ max-width:84%; } }
</style>
</head>
<body>
<div class="wrap">
  <div class="top">
    <h2>💬 직원 메신저</h2>
    <span class="sub">같은 회사 직원끼리 <b>1:1</b> 또는 <b>그룹</b>으로. 글만 보낼 수 있습니다. Enter = 보내기 · Shift+Enter = 줄바꿈</span>
  </div>
  <div class="cols">
    <div class="card left">
      <div class="lhd"><b>대화방</b><span id="roomCnt" style="color:var(--dim);font-size:12px"></span><button class="btn btn-teal btn-sm" style="margin-left:auto" onclick="openPick('new')">✚ 새 대화</button></div>
      <div class="rooms" id="rooms"><div class="rempty">읽는 중…</div></div>
    </div>
    <div class="card right" id="chat">
      <div class="cempty">왼쪽에서 대화방을 고르거나<br><b>[✚ 새 대화]</b>로 직원을 골라 시작하세요.</div>
    </div>
  </div>
</div>

<!-- 상대 고르기 (새 대화 · 초대 공용) -->
<div class="pop" id="pick">
  <div class="box">
    <div class="hd"><span id="pickTitle">✚ 새 대화</span><span class="x" onclick="closePick()">&times;</span></div>
    <div class="bd">
      <input type="text" id="pickQ" placeholder="이름·아이디 찾기" oninput="pickRender()">
      <div class="ulist" id="pickList"></div>
      <div class="gnm" id="pickGnm"><label>그룹 대화방 이름 <small>(비우면 구성원 이름으로 보입니다)</small></label><input type="text" id="pickNm" maxlength="100" placeholder="예) 물류팀 · 9월 재고조사"></div>
    </div>
    <div class="ft"><span class="sel" id="pickSel">고른 사람 없음</span><button class="btn" onclick="closePick()">취소</button><button class="btn btn-teal" id="pickGo" onclick="pickGo()">대화 시작</button></div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var ME='', ME_NM='', USERS=[], ROOMS=[], CUR=0, CUR_ROOM=null, LAST_SEQ=0, FIRST_SEQ=0, MSG_REQ=0, ROOM_REQ=0, PICK_MODE='new', PICK_SEL={}, SENDING=false;
var DAY_SHOWN='';
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/json'}, body: JSON.stringify(body||{}) }).then(function(r){ return r.json(); }); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function ask(m, okText, okColor){ return new Promise(function(res){ _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', okColor:okColor||'blue', onOk:function(){res(true);}, onCancel:function(){res(false);} }); }); }
function fail(j){ if(j && j.login==='N'){ err(j.message||'로그인이 끊겼습니다.'); return true; } if(!j || j.result!=='OK'){ err((j&&j.message)||'처리하지 못했습니다.'); return true; } return false; }
function badge(){ try{ if(parent && typeof parent.konetEmpBadge==='function') parent.konetEmpBadge(); }catch(e){} }
function hhmm(s){ s=String(s||''); return s.length>=16 ? s.slice(11,16) : s; }
function ymd(s){ s=String(s||''); return s.slice(0,10); }
function dayLabel(d){ var t=new Date(); var today=t.getFullYear()+'-'+('0'+(t.getMonth()+1)).slice(-2)+'-'+('0'+t.getDate()).slice(-2); if(d===today) return '오늘'; var w=['일','월','화','수','목','금','토']; var x=new Date(d+'T00:00:00'); return d+(isNaN(x)?'':' ('+w[x.getDay()]+')'); }
function shortTm(s){ s=String(s||''); if(!s) return ''; var t=new Date(); var today=t.getFullYear()+'-'+('0'+(t.getMonth()+1)).slice(-2)+'-'+('0'+t.getDate()).slice(-2); return s.slice(0,10)===today ? s.slice(11,16) : s.slice(5,10); }
function initial(nm){ nm=String(nm||'').trim(); return nm ? nm.slice(0,1) : '?'; }

/* ── 직원 목록 ── */
function loadUsers(){
  return post('/emp/users.do').then(function(j){ if(fail(j)) return; ME=j.me||''; ME_NM=j.meNm||''; USERS=(j.list||[]).filter(function(u){ return u.userId!==ME; }); });
}

/* ── 방 목록 ── */
function loadRooms(){
  var my=++ROOM_REQ;
  return post('/emp/roomList.do').then(function(j){
    if(my!==ROOM_REQ) return;                       /* 더 새 조회가 나갔으면 옛 응답은 버린다 */
    if(fail(j)) return;
    ME=j.me||ME; ME_NM=j.meNm||ME_NM; ROOMS=j.list||[];
    renderRooms();
  }).catch(function(){});
}
function renderRooms(){
  var h='';
  ROOMS.forEach(function(r){
    var un=Number(r.unread)||0, g=(r.roomGb==='G');
    var mbrs=(r.members||[]).filter(function(m){ return m.leaveYn!=='Y'; }).length;
    h+='<div class="room'+(r.roomSeq===CUR?' on':'')+(un>0?' unread':'')+'" onclick="openRoom('+r.roomSeq+')">'
      +'<div class="av'+(g?' g':'')+'">'+(g?'👥':esc(initial(r.dispNm)))+'</div>'
      +'<div class="bd"><div class="nm">'+esc(r.dispNm)+(g?'<small>'+mbrs+'명</small>':'')+'</div><div class="lt">'+esc(r.lastTxt||'(글 없음)')+'</div></div>'
      +'<div class="rt"><div class="tm">'+esc(shortTm(r.lastDttm))+'</div>'+(un>0?'<div class="un">'+(un>99?'99+':un)+'</div>':'')+'</div>'
      +'<span class="rdel" title="이 대화 지우기 — 내 목록에서 사라집니다" onclick="event.stopPropagation(); delRoom('+r.roomSeq+')">🗑</span>'
      +'</div>';
  });
  document.getElementById('rooms').innerHTML=h||'<div class="rempty">아직 대화방이 없습니다.<br><b>[✚ 새 대화]</b>로 시작하세요.</div>';
  document.getElementById('roomCnt').textContent=ROOMS.length?ROOMS.length+'개':'';
}

/* ── 대화 열기 ── */
function openRoom(seq){
  if(!seq) return;
  CUR=seq; LAST_SEQ=0; FIRST_SEQ=0; DAY_SHOWN='';
  renderRooms();
  var my=++MSG_REQ;
  document.getElementById('chat').innerHTML='<div class="cempty">읽는 중…</div>';
  post('/emp/msgList.do',{roomSeq:seq,afterSeq:0,beforeSeq:0}).then(function(j){
    if(my!==MSG_REQ) return;
    if(fail(j)){ if(j&&j.result!=='OK'){ CUR=0; loadRooms(); showEmpty(); } return; }
    CUR_ROOM=j.room||{}; CUR_ROOM.dispNm=j.dispNm||''; CUR_ROOM.members=j.members||[];
    buildChat();
    var list=j.list||[];
    appendMsgs(list, false);
    FIRST_SEQ = list.length ? Number(list[0].msgSeq) : 0;
    document.getElementById('moreBtn').style.display = list.length>=100 ? '' : 'none';
    scrollBottom(true);
    markRoomRead(seq);
    badge();
    var ta=document.getElementById('ta'); if(ta) ta.focus();
  }).catch(function(){ if(my===MSG_REQ) err('글을 읽지 못했습니다.'); });
}
function showEmpty(){ document.getElementById('chat').innerHTML='<div class="cempty">왼쪽에서 대화방을 고르거나<br><b>[✚ 새 대화]</b>로 직원을 골라 시작하세요.</div>'; }
function markRoomRead(seq){ var r=ROOMS.filter(function(x){ return x.roomSeq===seq; })[0]; if(r && Number(r.unread)>0){ r.unread=0; renderRooms(); } }
function buildChat(){
  var g=(CUR_ROOM.roomGb==='G');
  var names=(CUR_ROOM.members||[]).filter(function(m){ return m.leaveYn!=='Y'; }).map(function(m){ return m.userNm+(m.userId===ME?'(나)':''); }).join(', ');
  document.getElementById('chat').innerHTML=
    '<div class="chd"><span class="t">'+(g?'👥 ':'')+esc(CUR_ROOM.dispNm)+'</span><span class="m" title="'+esc(names)+'">'+esc(names)+'</span>'
    +'<span class="act">'+(g?'<button class="btn btn-sm" onclick="openPick(\'invite\')">👥 초대</button><button class="btn btn-sm" onclick="rename()">✎ 이름</button>':'')
    +'<button class="btn btn-sm btn-red" onclick="leave()">🚪 나가기</button></span></div>'
    +'<div class="msgs" id="msgs"><div class="more"><button class="btn btn-sm" id="moreBtn" onclick="loadMore()" style="display:none">↑ 이전 글 더 보기</button></div></div>'
    +'<div class="inp"><textarea id="ta" placeholder="글을 입력하세요 (Enter 보내기 · Shift+Enter 줄바꿈)" onkeydown="taKey(event)" oninput="taGrow(this)"></textarea>'
    +'<button class="btn btn-teal" id="sendBtn" onclick="send()">보내기</button></div>';
}
function msgHtml(m){
  if(m.msgGb==='S') return '<div class="sys">'+esc(m.msgTxt)+'</div>';
  var me=(m.userId===ME), del=(m.msgGb==='X');   /* X = 지운 글 — 자리는 남고 「삭제된 글입니다」 */
  return '<div class="m '+(me?'me':'other')+'" data-seq="'+m.msgSeq+'"><div class="stack">'+(me?'':'<div class="who">'+esc(m.userNm)+'</div>')
    +(del?'<div class="bub deleted">삭제된 글입니다</div>':'<div class="bub">'+esc(m.msgTxt)+'</div>')+'</div><span class="tm" title="'+esc(m.regDttm)+'">'+esc(hhmm(m.regDttm))+'</span>'
    +(me&&!del?'<span class="del" title="이 글 지우기 — 자리에 「삭제된 글입니다」가 남습니다" onclick="delMsg('+Number(m.msgSeq)+')">🗑</span>':'')+'</div>';
}
function appendMsgs(list, prepend){
  var box=document.getElementById('msgs'); if(!box) return;
  var h='', day=prepend?'':DAY_SHOWN;
  list.forEach(function(m){
    var d=ymd(m.regDttm);
    if(d && d!==day){ h+='<div class="day"><span>'+esc(dayLabel(d))+'</span></div>'; day=d; }
    h+=msgHtml(m);
    var s=Number(m.msgSeq)||0; if(s>LAST_SEQ) LAST_SEQ=s;
  });
  if(prepend){
    var more=box.querySelector('.more'); var t=document.createElement('div'); t.innerHTML=h;
    while(t.firstChild) box.insertBefore(t.firstChild, more.nextSibling===null?null:more.nextSibling);
    /* 위에 붙였으니 처음 보이던 날짜 띠가 겹칠 수 있다 — 같은 날 띠가 연달아 오면 뒤 것을 뗀다 */
    var days=box.querySelectorAll('.day'); for(var i=1;i<days.length;i++){ if(days[i].textContent===days[i-1].textContent && !hasMsgBetween(days[i-1],days[i])) days[i].remove(); }
  } else {
    box.insertAdjacentHTML('beforeend', h);
    DAY_SHOWN=day;
  }
}
function hasMsgBetween(a,b){ var n=a.nextElementSibling; while(n && n!==b){ if(n.classList.contains('m')||n.classList.contains('sys')) return true; n=n.nextElementSibling; } return false; }
function scrollBottom(force){
  var box=document.getElementById('msgs'); if(!box) return;
  var near = box.scrollHeight - box.scrollTop - box.clientHeight < 80;
  if(force||near) box.scrollTop=box.scrollHeight;
}
function loadMore(){
  if(!CUR||!FIRST_SEQ) return;
  var box=document.getElementById('msgs'), h0=box.scrollHeight, my=MSG_REQ;
  post('/emp/msgList.do',{roomSeq:CUR,afterSeq:0,beforeSeq:FIRST_SEQ}).then(function(j){
    if(my!==MSG_REQ||fail(j)) return;
    var list=j.list||[];
    if(!list.length){ document.getElementById('moreBtn').style.display='none'; return; }
    /* 위에 붙인다 — 스크롤 자리를 그대로 지킨다 */
    var keepLast=LAST_SEQ; appendMsgs(list, true); LAST_SEQ=keepLast;
    FIRST_SEQ=Number(list[0].msgSeq);
    box.scrollTop = box.scrollTop + (box.scrollHeight - h0);
    if(list.length<100) document.getElementById('moreBtn').style.display='none';
  }).catch(function(){});
}
/* 새 글 묻기 — 보고 있는 방만 */
function pollNew(){
  if(!CUR||document.hidden||SENDING) return;
  var my=MSG_REQ, seq=CUR, after=LAST_SEQ;
  post('/emp/msgList.do',{roomSeq:seq,afterSeq:after,beforeSeq:0}).then(function(j){
    if(my!==MSG_REQ||CUR!==seq) return;
    if(!j||j.result!=='OK') return;
    var list=(j.list||[]).filter(function(m){ return Number(m.msgSeq)>LAST_SEQ; });
    if(!list.length) return;
    appendMsgs(list,false); scrollBottom(false);
    /* 목록의 마지막 글도 맞춘다 */
    var r=ROOMS.filter(function(x){ return x.roomSeq===seq; })[0]; if(r){ var l=list[list.length-1]; r.lastTxt=l.msgTxt; r.lastDttm=l.regDttm; r.unread=0; renderRooms(); }
    badge();
  }).catch(function(){});
}

/* ── 보내기 ── */
function taKey(e){
  if(e.key==='Enter' && !e.shiftKey && !e.isComposing && e.keyCode!==229){ e.preventDefault(); send(); }
}
function taGrow(ta){ ta.style.height='auto'; ta.style.height=Math.min(140, ta.scrollHeight)+'px'; }
function send(){
  var ta=document.getElementById('ta'); if(!ta||!CUR) return;
  var t=ta.value.replace(/\s+$/,''); if(!t.trim()) return;
  if(t.length>4000){ _alertBox('한 번에 4,000자까지 보낼 수 있습니다.',{icon:'⚠️'}); return; }
  SENDING=true; var btn=document.getElementById('sendBtn'); btn.disabled=true; var seq=CUR;
  post('/emp/msgSend.do',{roomSeq:seq,text:t}).then(function(j){
    SENDING=false; btn.disabled=false;
    if(fail(j)){ return; }
    ta.value=''; taGrow(ta); ta.focus();
    /* 내 글은 바로 붙인다(폴링을 기다리지 않는다) */
    var now=new Date(), pad=function(n){ return ('0'+n).slice(-2); };
    var dt=now.getFullYear()+'-'+pad(now.getMonth()+1)+'-'+pad(now.getDate())+' '+pad(now.getHours())+':'+pad(now.getMinutes())+':'+pad(now.getSeconds());
    if(CUR===seq){ appendMsgs([{msgSeq:j.msgSeq,userId:ME,userNm:ME_NM,msgTxt:t,msgGb:'T',regDttm:dt}],false); scrollBottom(true); }
    var r=ROOMS.filter(function(x){ return x.roomSeq===seq; })[0]; if(r){ r.lastTxt=t.replace(/\n/g,' '); r.lastDttm=dt; ROOMS.sort(function(a,b){ return (b.lastDttm||'')<(a.lastDttm||'')?-1:1; }); renderRooms(); }
  }).catch(function(){ SENDING=false; btn.disabled=false; err('보내지 못했습니다.'); });
}

/* ── 내 글 지우기 (2026-09-22) — 서버가 본인 것만 받는다. 지운 자리는 「삭제된 글입니다」로 남는다(상대는 다음에 방을 열 때 반영) */
function delMsg(seq){
  if(!CUR||!seq) return;
  ask('이 글을 지울까요?<br><small>지운 자리에는 「삭제된 글입니다」가 남습니다.</small>','지우기','red').then(function(y){
    if(!y) return;
    var room=CUR;
    post('/emp/msgDel.do',{roomSeq:room,msgSeq:seq}).then(function(j){
      if(fail(j)) return;
      var el=document.querySelector('#msgs .m[data-seq="'+seq+'"]');
      if(el){ var b=el.querySelector('.bub'); if(b){ b.className='bub deleted'; b.textContent='삭제된 글입니다'; } var d=el.querySelector('.del'); if(d) d.remove(); }
      var r=ROOMS.filter(function(x){ return x.roomSeq===room; })[0]; if(r && Number(r.lastMsgSeq)===Number(seq)){ r.lastTxt='삭제된 글입니다'; renderRooms(); }
      _toast('지웠습니다.','ok');
    }).catch(function(){ err('지우지 못했습니다.'); });
  });
}

/* ── 방 관리 ── */
/* 대화 지우기 (2026-09-22 「대화도 지울 수 있게」) — 서버는 나가기(roomLeave)와 같다 : LEAVE_YN Y + CLEAR_SEQ(지금까지 글 번호).
   내 목록에서 사라지고 그때까지의 글은 나에게 다시 안 보인다. 상대에게는 그대로. 같은 상대와 다시 시작하면 그 뒤 글만 보이는 새 대화처럼 열린다 */
function delRoom(seq){
  var r=ROOMS.filter(function(x){ return x.roomSeq===seq; })[0]; if(!r) return;
  ask('이 대화를 지울까요?<br><b>'+esc(r.dispNm)+'</b><br><small>내 대화 목록에서 사라지고 지금까지의 글은 다시 볼 수 없습니다.<br>상대에게는 그대로 남습니다.</small>','지우기','red').then(function(y){
    if(!y) return;
    post('/emp/roomLeave.do',{roomSeq:seq}).then(function(j){ if(fail(j)) return; _toast('대화를 지웠습니다.','ok'); if(CUR===seq){ CUR=0; CUR_ROOM=null; showEmpty(); } loadRooms(); badge(); }).catch(function(){ err('지우지 못했습니다.'); });
  });
}
function leave(){
  if(!CUR) return;
  var g=(CUR_ROOM.roomGb==='G');
  ask('이 대화방에서 나갈까요?<br><b>'+esc(CUR_ROOM.dispNm)+'</b><br><small>'+(g?'지금까지의 글은 다시 볼 수 없고, 다시 초대받으면 그 뒤 글만 보입니다.':'지금까지의 글은 다시 볼 수 없습니다. 같은 상대와 다시 시작하면 그 뒤 글만 보입니다.')+'</small>','나가기','red').then(function(y){
    if(!y) return;
    post('/emp/roomLeave.do',{roomSeq:CUR}).then(function(j){ if(fail(j)) return; _toast('대화방에서 나갔습니다.','ok'); CUR=0; CUR_ROOM=null; showEmpty(); loadRooms(); badge(); });
  });
}
function rename(){
  if(!CUR||CUR_ROOM.roomGb!=='G') return;
  var nm=prompt_('그룹 대화방 이름', CUR_ROOM.roomNm||'');
  nm.then(function(v){ if(v===null) return; post('/emp/roomRename.do',{roomSeq:CUR,roomNm:v}).then(function(j){ if(fail(j)) return; _toast('이름을 바꿨습니다.','ok'); loadRooms().then(function(){ openRoom(CUR); }); }); });
}
/* 입력칸 있는 확인창 — ui-message 에는 없어 그 .cfm-* 클래스를 빌려 같은 모양으로 (wnn_medcost joinReq _jrAsk 와 같은 요령) */
function prompt_(title, val){
  return new Promise(function(res){
    var wrap=document.createElement('div'); wrap.className='cfm-backdrop'; wrap.style.cssText='position:fixed;inset:0;background:rgba(0,0,0,.35);z-index:10000;display:flex;align-items:center;justify-content:center;';
    wrap.innerHTML='<div class="cfm-card" style="background:#fff;border-radius:16px;width:360px;max-width:92vw;padding:22px 20px 18px;box-shadow:0 18px 50px rgba(0,0,0,.25);text-align:center;font-family:inherit;">'
      +'<div style="font-size:30px;margin-bottom:6px">✎</div><div style="font-weight:800;font-size:15px;margin-bottom:12px">'+esc(title)+'</div>'
      +'<input type="text" id="prIn" maxlength="100" style="width:100%;height:36px;border:1px solid #dbe2ea;border-radius:7px;padding:0 10px;font-size:14px" value="'+esc(val)+'">'
      +'<div style="display:flex;gap:8px;margin-top:14px"><button id="prOk" style="flex:1;height:40px;border:0;border-radius:8px;background:#0d6efd;color:#fff;font-weight:800;font-size:14px;cursor:pointer">확인</button>'
      +'<button id="prNo" style="flex:1;height:40px;border:1px solid #dbe2ea;border-radius:8px;background:#fff;font-weight:700;font-size:14px;cursor:pointer">취소</button></div></div>';
    document.body.appendChild(wrap);
    var inp=wrap.querySelector('#prIn'); inp.focus(); inp.select();
    function done(v){ wrap.remove(); res(v); }
    wrap.querySelector('#prOk').onclick=function(){ done(inp.value); };
    wrap.querySelector('#prNo').onclick=function(){ done(null); };
    inp.onkeydown=function(e){ if(e.key==='Enter'&&!e.isComposing){ done(inp.value); } if(e.key==='Escape'){ done(null); } };
  });
}

/* ── 상대 고르기 (새 대화 · 초대) ── */
function openPick(mode){
  PICK_MODE=mode; PICK_SEL={};
  document.getElementById('pickTitle').textContent = mode==='invite' ? '👥 초대할 직원' : '✚ 새 대화';
  document.getElementById('pickGo').textContent = mode==='invite' ? '초대' : '대화 시작';
  document.getElementById('pickQ').value=''; document.getElementById('pickNm').value='';
  var p=document.getElementById('pick'); p.classList.add('on');
  (USERS.length?Promise.resolve():loadUsers()).then(function(){ pickRender(); document.getElementById('pickQ').focus(); });
}
function closePick(){ document.getElementById('pick').classList.remove('on'); }
function pickRender(){
  var q=document.getElementById('pickQ').value.trim().toLowerCase();
  var inRoom={}; if(PICK_MODE==='invite' && CUR_ROOM) (CUR_ROOM.members||[]).forEach(function(m){ if(m.leaveYn!=='Y') inRoom[m.userId]=1; });
  var h='';
  USERS.forEach(function(u){
    if(q && (u.userNm+' '+u.userId).toLowerCase().indexOf(q)<0) return;
    var dis=!!inRoom[u.userId];
    h+='<div class="u'+(dis?' dis':'')+'" onclick="'+(dis?'':'pickToggle(\''+esc(u.userId)+'\')')+'"><input type="checkbox" '+(PICK_SEL[u.userId]?'checked':'')+(dis?' disabled':'')+' onclick="event.stopPropagation(); pickToggle(\''+esc(u.userId)+'\')">'
      +'<span class="nm">'+esc(u.userNm)+'</span><span class="id">'+esc(u.userId)+'</span><span class="gu">'+esc(dis?'이미 참여':u.mainGuNm)+'</span></div>';
  });
  document.getElementById('pickList').innerHTML=h||'<div class="u dis">'+(USERS.length?'찾는 직원이 없습니다.':'같은 회사에 다른 직원 계정이 없습니다.')+'</div>';
  pickSelText();
}
function pickToggle(id){ if(PICK_SEL[id]) delete PICK_SEL[id]; else PICK_SEL[id]=1; pickRender(); }
function pickSelText(){
  var ids=Object.keys(PICK_SEL), nms=ids.map(function(id){ var u=USERS.filter(function(x){ return x.userId===id; })[0]; return u?u.userNm:id; });
  document.getElementById('pickSel').innerHTML = ids.length ? '<b>'+ids.length+'명</b> — '+esc(nms.join(', ')) : '고른 사람 없음';
  document.getElementById('pickGnm').classList.toggle('on', PICK_MODE==='new' && ids.length>=2);
  var go=document.getElementById('pickGo'); go.disabled=!ids.length;
  if(PICK_MODE==='new') go.textContent = ids.length>=2 ? '그룹 대화 시작' : '대화 시작';
}
function pickGo(){
  var ids=Object.keys(PICK_SEL); if(!ids.length) return;
  var go=document.getElementById('pickGo'); go.disabled=true;
  if(PICK_MODE==='invite'){
    post('/emp/roomInvite.do',{roomSeq:CUR,users:ids}).then(function(j){ go.disabled=false; if(fail(j)) return; closePick(); _toast(j.cnt+'명을 초대했습니다.','ok'); loadRooms().then(function(){ openRoom(CUR); }); }).catch(function(){ go.disabled=false; err('초대하지 못했습니다.'); });
    return;
  }
  post('/emp/roomOpen.do',{users:ids,roomNm:document.getElementById('pickNm').value}).then(function(j){
    go.disabled=false; if(fail(j)) return; closePick();
    loadRooms().then(function(){ openRoom(Number(j.roomSeq)); });
  }).catch(function(){ go.disabled=false; err('대화방을 열지 못했습니다.'); });
}
document.getElementById('pick').addEventListener('click', function(e){ if(e.target===this) closePick(); });
document.addEventListener('keydown', function(e){ if(e.key==='Escape' && document.getElementById('pick').classList.contains('on')) closePick(); });

/* ── 시작·폴링 ── */
window.konetShown=function(){ loadRooms(); if(CUR) pollNew(); };
setInterval(function(){ if(!document.hidden) loadRooms(); }, 15000);
setInterval(pollNew, 4000);
document.addEventListener('visibilitychange', function(){ if(!document.hidden){ loadRooms(); pollNew(); } });
loadUsers().then(loadRooms);
</script>
</body>
</html>
