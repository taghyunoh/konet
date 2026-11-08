<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>직원 업무일지</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 📥 엑셀 (전역 XLSX · 없으면 CSV 로 물러선다) --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>   <%-- 날짜 칸 공용 달력 — 넣기만 하면 모든 type=date 에 붙는다(기간은 data-range-to 로 한 달력) --%>
<%--
  직원 업무일지 (2026-11-08 신설 — 사용자 「직원업무일지를 메신저로 보고 있는데, 직원별 업무일지를 한눈에 볼 수 있게」)
    · 셸 「직원관리」 ▸ 직원 메신저 밑 메뉴(logiFrame('empWorkLog')) · 읽기 전용 — 메신저 화면·글은 손대지 않는다.
    · 원천 = 직원 메신저 글(TBL_EMP_MSG, /emp/workLogList.do — 내가 든 방의 글(T)만, 기간은 「보낸 때」 기준). 서버는 글 원문만 주고
      날짜 묶음 나누기는 여기 parseWorkLog() 한 곳이 한다 :
        날짜 줄 = ^\s*(\d{4}[./-])?(\d{1,2})[./-](\d{1,2})\s*(\([^)]{1,4}\))?\s*$   (「11/6」「11.06」「2026-11-06」「11/6(목)」)
          연도가 없으면 보낸 날짜의 연도. 단 보낸 달과 6달 넘게 어긋나면 해를 넘긴 것(12월에 쓴 「1/3」 = 다음 해 · 1월에 쓴 「12/30」 = 지난 해).
        항목 줄 = 날짜 줄 다음부터 다음 날짜 줄·글 끝까지의 빈 줄 아닌 줄 — 머리 번호(「1.」「1)」「1,」「3 」「- 」「• 」, 「3.평택」처럼 공백 없어도)는 떼고 번호는 다시 센다.
        날짜 줄이 하나도 없는 글 = 보낸 날짜 한 묶음. 같은 직원·같은 날짜가 여러 글에 있으면 합친다(나중 글이 뒤에 · 원문은 둘 다 보인다).
    · 조회 기간 = 일지 날짜(묶음의 날짜) 기준. 서버에는 보낸 때를 앞뒤 14일 넓혀 묻는다(캡처처럼 11/6 에 11/8 일지를 미리 쓰는 경우) — 그 뒤 날짜로 거른다.
    · 격자 = 열 직원 · 행 날짜(최근이 위) · 칸 = 번호 줄 목록 + 「n건」. 칸을 누르면 아래 상세(원문·보낸 때·방). [👤 직원별] 탭 = 한 명의 일지를 날짜 순으로 · 🖨 인쇄(새 창 — iframe 이라 window.print 금지) · 📥 엑셀.
    · ⛔[✏ 작성] 탭은 같은 날 사용자 「작성은 기존대로 메신저에 — 여기 작성은 일단 비활성화」로 숨겼다(WRITE_ON=false · 단추 숨김 + tab('write') 거부, 코드는 그대로). 아래는 켰을 때의 동작.
    · [✏ 작성] 탭(2026-11-08 같은 날 사용자 「직원별 업무일지 작성화면도」) = ★새 표 없이 <메신저 글>로 저장 — 날짜(기본 오늘) + 한 줄에 하나씩 적으면 「11/8\n1. …\n2. …」 꼴 글 하나를 고른 방(내가 든 방)에
      기존 /emp/msgSend.do 로 보낸다(권한·4,000자 한도는 그 서비스 그대로). 그래서 메신저에서도 그대로 보이고 위 parseWorkLog 가 그대로 읽는다 — 원천 하나. 날짜 묶음을 여럿(오늘 한 것·내일 할 것) 붙일 수 있다.
      ⚠고치기·지우기는 없다 — 같은 날짜를 다시 쓰면 <새 글로 덧붙고>(격자는 합쳐 보인다), 지우려면 직원 메신저의 내 글 지우기(안내 문구로 알린다). 보낸 뒤 격자를 다시 읽어 그 칸을 바로 연다.
--%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css">
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --dim:#6b7a89; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; }
  body{ font-family:'Pretendard Variable',Pretendard,'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 12px; height:100vh; display:flex; flex-direction:column; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:var(--dim); margin-bottom:10px; font-size:12.5px; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:8px; }
  .bar input[type=text], .bar select, .bar input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13.5px; background:#fff; font-family:inherit; }
  .bar input[type=text]{ width:220px; }
  .bar select{ max-width:260px; }
  .bar .lb{ color:#37475a; font-size:13px; font-weight:700; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn.qb{ height:29px; padding:0 10px; font-size:12.5px; }
  .btn.qb.on{ background:#e3f2ee; color:#0f6b5e; border-color:#bcd9d1; }
  .btn:disabled{ opacity:.5; cursor:default; }
  .tabs{ display:flex; gap:4px; margin-left:auto; }
  .tabs .tb{ height:34px; padding:0 14px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .tabs .tb.on{ background:#e3f2ee; color:#0f6b5e; border-color:#bcd9d1; }
  /* 요약 카드 */
  .kpis{ display:flex; gap:8px; margin-bottom:8px; flex-wrap:wrap; }
  .kpi{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:8px 14px; min-width:120px; }
  .kpi .k{ color:var(--dim); font-size:12px; }
  .kpi .v{ font-size:20px; font-weight:800; color:var(--teal); font-variant-numeric:tabular-nums; white-space:nowrap; }
  .kpi .v small{ font-size:12px; color:var(--dim); font-weight:600; margin-left:3px; }
  .cols{ display:flex; flex-direction:column; gap:10px; flex:1; min-height:0; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  #gridWrap{ flex:1; min-height:160px; }
  /* 상세 칸 높이 — 2026-11-08 사용자 「하단 업무일지 이력은 전부 안 보여주네요」 : 38% 는 글 두 건이면 잘렸다 → 기본 60%,
     머리줄 [⛶ 크게] 를 켜면(.big · localStorage konetWlDtlBig) 격자를 최소(120px)로 줄이고 상세가 나머지 전부(제 안에서 스크롤) */
  #dtl{ flex:0 0 auto; max-height:60%; display:none; }
  #dtl.on{ display:block; }
  .cols.big #dtl{ max-height:none; flex:0 1 auto; }
  .cols.big #gridWrap{ min-height:120px; }
  .dh .bg{ cursor:pointer; color:var(--dim); font-size:12.5px; padding:2px 8px; border:1px solid var(--bd); border-radius:6px; background:#fff; }
  .dh .bg:hover{ color:var(--teal); border-color:#bcd9d1; }
  /* 격자 */
  table.g{ border-collapse:separate; border-spacing:0; min-width:100%; font-size:13px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 8px; text-align:center; position:sticky; top:0; z-index:3; white-space:nowrap; }
  table.g th.dt{ left:0; z-index:4; min-width:112px; }
  table.g th small{ display:block; color:#4e7f75; font-weight:500; font-size:11px; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:0; vertical-align:top; min-width:210px; }
  table.g td.dt{ position:sticky; left:0; background:#f7faf9; z-index:2; text-align:center; font-weight:700; padding:8px 6px; min-width:112px; white-space:nowrap; font-variant-numeric:tabular-nums; }
  table.g td.dt small{ display:block; color:var(--dim); font-weight:500; font-size:11px; }
  table.g td.dt.sat{ color:#1f5fbf; }  table.g td.dt.sun{ color:#c0392b; }
  table.g td.empty{ color:var(--dim); padding:30px 0; text-align:center; }
  .cell{ padding:6px 8px 7px; cursor:pointer; min-height:34px; }
  .cell:hover{ background:#f3f8f6; }
  .cell.on{ background:#e6f3f0; box-shadow:inset 3px 0 0 var(--teal); }
  .cell .n{ display:inline-block; font-size:11px; font-weight:800; color:#0f6b5e; background:#e3f2ee; border:1px solid #bcd9d1; border-radius:9px; padding:0 7px; margin-bottom:3px; }
  .cell .n.z{ color:#9aa5b1; background:#f2f4f6; border-color:#e1e6eb; }
  .cell ol{ margin:0; padding-left:20px; line-height:1.45; }
  .cell ol li{ white-space:normal; word-break:break-word; }
  .cell ol li.hit{ background:#fff3c4; }
  .cell .more{ color:var(--teal); font-size:12px; margin-left:20px; }
  /* 상세 */
  .dh{ display:flex; gap:10px; align-items:center; padding:9px 14px; border-bottom:1px solid var(--bd); background:#fafbfc; position:sticky; top:0; }
  .dh b{ color:var(--teal); font-size:15px; }
  .dh .x{ margin-left:auto; cursor:pointer; color:var(--dim); font-size:16px; padding:0 6px; }
  .dh .x:hover{ color:var(--red); }
  .src{ padding:10px 14px; border-bottom:1px dashed #e3e8ee; display:flex; gap:14px; }
  .src .meta{ flex:0 0 190px; color:var(--dim); font-size:12.5px; line-height:1.6; }
  .src .meta b{ color:#37475a; display:block; font-size:13px; }
  .src pre{ margin:0; flex:1; white-space:pre-wrap; word-break:break-word; font-family:inherit; font-size:13.5px; line-height:1.55; }
  .src pre .dl{ background:#e3f2ee; color:#0f6b5e; font-weight:800; border-radius:4px; padding:0 4px; }
  /* 직원별 보기 */
  table.e{ border-collapse:collapse; width:100%; font-size:13.5px; }
  table.e th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 8px; text-align:center; position:sticky; top:0; z-index:2; white-space:nowrap; }
  table.e th:last-child, table.e td:last-child{ border-right:none; }
  table.e td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:6px 8px; vertical-align:top; }
  table.e td.c{ text-align:center; white-space:nowrap; font-variant-numeric:tabular-nums; }
  table.e td.r{ text-align:right; white-space:nowrap; font-variant-numeric:tabular-nums; }
  table.e td.sat{ color:#1f5fbf; } table.e td.sun{ color:#c0392b; }
  table.e tr.d0 td{ border-top:2px solid #cfe0da; }
  table.e td.empty{ color:var(--dim); padding:30px 0; text-align:center; }
  table.e td.meta{ color:var(--dim); font-size:12px; white-space:nowrap; }
  .hint{ color:var(--dim); font-size:12px; margin-left:4px; }
  /* 작성 탭 */
  .wbody{ padding:12px 14px 14px; display:flex; flex-direction:column; gap:10px; max-width:980px; }
  .wrow{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .wrow .lb{ color:#37475a; font-size:13px; font-weight:700; min-width:58px; }
  .wrow select, .wrow input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13.5px; background:#fff; font-family:inherit; }
  .wrow select{ max-width:420px; }
  .wblk{ border:1px solid var(--bd); border-radius:9px; padding:10px 12px; background:#fafcfb; }
  .wblk .x{ cursor:pointer; color:var(--dim); font-size:15px; padding:0 6px; margin-left:auto; }
  .wblk .x:hover{ color:var(--red); }
  .wblk textarea{ width:100%; min-height:132px; margin-top:8px; border:1px solid var(--bd); border-radius:7px; padding:9px 10px; font-size:14px; line-height:1.6; font-family:inherit; resize:vertical; }
  .wblk .has{ color:#b06a00; font-size:12px; }
  .wprev{ margin:0; background:#f3f6f8; border:1px dashed #cfd8e0; border-radius:8px; padding:10px 12px; font-family:inherit; font-size:13.5px; line-height:1.55; white-space:pre-wrap; min-height:60px; color:#37475a; }
  .wprev.e{ color:var(--dim); }
  .wnote{ color:var(--dim); font-size:12.5px; line-height:1.5; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📋 직원 업무일지 <span class="hint" title="직원 메신저에 올린 글을 읽기만 합니다 — 고치거나 지우는 것은 메신저에서">메신저 글 기준 · 읽기 전용</span></h2>
  <div class="sub">직원 메신저(그룹방)에 올린 업무일지 — <b>「11/6」 날짜 줄 + 「1. …」 번호 줄</b> — 를 <b>직원 × 날짜</b>로 모아 봅니다. 내가 든 방의 글만 · 날짜 줄이 없는 글은 보낸 날짜로 묶습니다. <b>작성은 직원 메신저에서</b> 하던 대로.</div>
  <div class="bar">
    <span class="lb">기간</span>
    <input type="date" id="frDt" data-range-to="toDt" onchange="rgSync()"> <span class="lb">~</span> <input type="date" id="toDt" onchange="rgSync()">
    <button class="btn qb" id="rgD" onclick="rg('d')" title="오늘 하루">당일</button>
    <button class="btn qb" id="rgW" onclick="rg('w')" title="오늘 포함 최근 7일">1주일</button>
    <button class="btn qb" id="rgM" onclick="rg('m')" title="이번 달 1일 ~ 오늘">해당월</button>
    <span class="lb" style="margin-left:6px">방</span>
    <select id="room" onchange="load()"><option value="0">전체 방</option></select>
    <span class="lb">직원</span>
    <select id="emp" onchange="render()"><option value="">전체</option></select>
    <input type="text" id="q" placeholder="🔎 항목 글자 거르기" oninput="render()" onkeydown="if(event.key==='Escape'){ this.value=''; render(); }">
    <button class="btn btn-teal" onclick="load()">조회</button>
    <div class="tabs">
      <button class="tb on" id="tbGrid" onclick="tab('grid')">📊 격자</button>
      <button class="tb" id="tbEmp" onclick="tab('emp')">👤 직원별</button>
      <button class="tb" id="tbWrite" onclick="tab('write')" title="내 업무일지를 적어 고른 방에 메신저 글로 보냅니다">✏ 작성</button>
    </div>
  </div>
  <div class="kpis">
    <div class="kpi"><div class="k">일지 올린 직원</div><div class="v" id="kEmp">—</div></div>
    <div class="kpi"><div class="k">날짜</div><div class="v" id="kDay">—</div></div>
    <div class="kpi"><div class="k">항목</div><div class="v" id="kItem">—</div></div>
    <div class="kpi"><div class="k">글(메신저)</div><div class="v" id="kMsg">—</div></div>
    <div class="kpi" id="kNote" style="min-width:0;flex:1;display:none"><div class="k">거르기</div><div class="v" id="kNoteV" style="font-size:13px;color:#37475a"></div></div>
  </div>
  <div class="cols">
    <div class="card" id="gridWrap">
      <table class="g"><thead id="gHead"></thead><tbody id="gBody"><tr><td class="empty">조회 중…</td></tr></tbody></table>
    </div>
    <div class="card" id="dtl"></div>
    <div class="card" id="empWrap" style="display:none; flex:1;">
      <div class="dh"><b id="eTitle">—</b><span class="hint" id="eSub"></span>
        <button class="btn qb" onclick="ePrint()">🖨 인쇄</button><button class="btn qb" onclick="eExcel()">📥 엑셀</button>
      </div>
      <table class="e"><thead><tr><th style="width:110px">날짜</th><th style="width:44px">요일</th><th style="width:44px">번호</th><th>항목</th><th style="width:150px">보낸 때</th><th style="width:160px">방</th></tr></thead><tbody id="eBody"></tbody></table>
    </div>
    <div class="card" id="writeWrap" style="display:none; flex:1;">
      <div class="dh"><b>✏ 업무일지 작성</b><span class="hint">저장하면 고른 방에 <b>메신저 글</b>로 올라갑니다 — 메신저에서도 그대로 보이고 이 격자에도 바로 잡힙니다.</span></div>
      <div class="wbody">
        <div class="wrow"><span class="lb">보낼 방</span><select id="wRoom" onchange="wRoomKeep()"></select><span class="hint">내가 든 방 — 그룹방이 앞에</span></div>
        <div id="wBlocks"></div>
        <div class="wrow"><button class="btn qb" onclick="wAddBlock()">＋ 다음 날짜 묶음</button><span class="hint">한 글에 날짜 여럿(오늘 한 것 · 내일 할 것)을 함께 보낼 때 — 메신저에 「11/6 … 11/7 …」 꼴로 올라갑니다</span></div>
        <div class="wrow"><span class="lb">미리보기</span><span class="hint" id="wCnt"></span></div>
        <pre id="wPrev" class="wprev e">날짜와 항목을 적으면 보낼 글이 여기 보입니다.</pre>
        <div class="wrow"><button class="btn btn-teal" id="wSendBtn" onclick="wSend()">💬 메신저로 보내기</button><button class="btn" onclick="wReset()">비우기</button></div>
        <div class="wnote">⚠ 보낸 글은 여기서 고치거나 지울 수 없습니다 — <b>직원 메신저</b>에서 내 글을 지운 뒤 다시 쓰세요. 같은 날짜를 다시 보내면 <b>새 글로 덧붙고</b> 격자에서는 합쳐 보입니다. 한 번에 4,000자까지.</div>
      </div>
    </div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var MSGS=[], ROOMS={}, GROUPS=[], EMPS=[], LOAD_REQ=0, _rg='m', _loadedAt=0, _todayAt='', TAB='grid', SEL=null, ME='', _afterLoad=null, _empAuto='';
var WRITE_ON=false;   /* ★[✏ 작성] 탭 — 2026-11-08 사용자 「작성은 기존대로 메신저에 · 여기 작성은 일단 비활성화」. 다시 켜려면 true (단추·탭 전환·마크업·함수는 그대로 남겨 두었다) */
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/json'}, body: JSON.stringify(body||{}) }).then(function(r){ return r.json(); }); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function fail(j){ if(j && j.login==='N'){ err(j.message||'로그인이 끊겼습니다.'); return true; } if(!j || j.result!=='OK'){ err((j&&j.message)||'처리하지 못했습니다.'); return true; } return false; }
function pad2(n){ return (n<10?'0':'')+n; }
function iso(d){ return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate()); }
function dOf(s){ var p=(s||'').split('-'); return p.length===3 ? new Date(+p[0], +p[1]-1, +p[2]) : null; }
function addDays(s, n){ var d=dOf(s); d.setDate(d.getDate()+n); return iso(d); }
function todayIso(){ return iso(new Date()); }
var WD=['일','월','화','수','목','금','토'];
function wday(s){ var d=dOf(s); return d ? WD[d.getDay()] : ''; }
function wcls(s){ var d=dOf(s); return !d ? '' : d.getDay()===0 ? 'sun' : d.getDay()===6 ? 'sat' : ''; }
function md(s){ return s ? (+s.slice(5,7))+'/'+(+s.slice(8,10)) : ''; }

/* ── 기간 빠른 단추 — 당일 / 1주일(오늘 포함 7일) / 해당월(1일~오늘). 날짜칸을 손으로 고치면 단추 색이 꺼진다(rgSync) ── */
function rg(k){
  var t=todayIso();
  if(k==='d'){ document.getElementById('frDt').value=t; document.getElementById('toDt').value=t; }
  else if(k==='w'){ document.getElementById('frDt').value=addDays(t,-6); document.getElementById('toDt').value=t; }
  else { document.getElementById('frDt').value=t.slice(0,8)+'01'; document.getElementById('toDt').value=t; }
  _rg=k; rgPaint(); load();
}
function rgSync(){ var t=todayIso(), f=document.getElementById('frDt').value, e=document.getElementById('toDt').value;
  _rg = (f===t && e===t) ? 'd' : (f===addDays(t,-6) && e===t) ? 'w' : (f===t.slice(0,8)+'01' && e===t) ? 'm' : ''; rgPaint(); }
function rgPaint(){ ['d','w','m'].forEach(function(k){ document.getElementById('rg'+k.toUpperCase()).className='btn qb'+(_rg===k?' on':''); }); }

/* ══════════════════════════════════════════════════════════════════════════
   parseWorkLog(msg, sentDttm) — 글 하나 → [{date:'YYYY-MM-DD', items:[...], hasDate}] (파싱 규칙은 파일 머리 주석)
   ══════════════════════════════════════════════════════════════════════════ */
var DATE_RE=/^\s*(\d{4}[./-])?(\d{1,2})[./-](\d{1,2})\s*(\([^)]{1,4}\))?\s*$/;
var ITEM_RE=/^\s*(?:\d{1,3}\s*[.),]|\d{1,2}\s+|[-•·*▪▶]\s*)\s*/;   /* 「1.」「1)」「1,」(실제 글에 쉼표도 있다)「3 창고정리」「- 」「• 」 */
function dateOf(m, sent){   /* m = DATE_RE 결과, sent = 'YYYY-MM-DD…' 보낸 때 */
  var y = m[1] ? parseInt(m[1],10) : parseInt(sent.slice(0,4),10), mo=parseInt(m[2],10), d=parseInt(m[3],10);
  if(!(mo>=1 && mo<=12 && d>=1 && d<=31)) return null;
  if(!m[1]){ var sm=parseInt(sent.slice(5,7),10); var diff=mo-sm; if(diff<=-6) y++; else if(diff>=6) y--; }   /* 12월에 「1/3」 = 다음 해 · 1월에 「12/30」 = 지난 해 */
  var dt=new Date(y, mo-1, d); if(dt.getMonth()!==mo-1) return null;   /* 2/30 같은 것 */
  return iso(dt);
}
function parseWorkLog(msg, sentDttm){
  var sent=(sentDttm||'').slice(0,10), lines=(''+(msg||'')).replace(/\r\n?/g,'\n').split('\n');
  var out=[], cur=null, hasDate=false;
  for(var i=0;i<lines.length;i++){
    var ln=lines[i], m=DATE_RE.exec(ln);
    if(m){ var dt=dateOf(m, sent); if(dt){ hasDate=true; cur={ date:dt, items:[], hasDate:true }; out.push(cur); continue; } }
    var t=ln.replace(ITEM_RE,'').trim();
    if(!t) continue;
    if(!cur){ cur={ date:sent, items:[], hasDate:false }; out.push(cur); }
    cur.items.push(t);
  }
  return out.filter(function(g){ return g.items.length>0 || g.hasDate; });
}

/* ── 자료 ── */
function load(){
  var f=document.getElementById('frDt').value, e=document.getElementById('toDt').value;
  if(!f || !e){ _alertBox('기간을 넣어 주세요.',{icon:'⚠️'}); return; }
  if(f>e){ var t=f; f=e; e=t; document.getElementById('frDt').value=f; document.getElementById('toDt').value=e; }
  var my=++LOAD_REQ;
  document.getElementById('gBody').innerHTML='<tr><td class="empty">조회 중…</td></tr>';
  /* 보낸 때는 앞뒤 14일 넓혀 묻는다 — 11/6 에 11/8 일지를 미리 쓰는 글. 날짜 거르기는 build() 가 한다 */
  post('/emp/workLogList.do',{ frDt:addDays(f,-14), toDt:addDays(e,14), roomSeq:+document.getElementById('room').value||0 }).then(function(j){
    if(my!==LOAD_REQ) return;
    if(fail(j)){ document.getElementById('gBody').innerHTML='<tr><td class="empty">조회하지 못했습니다.</td></tr>'; return; }
    MSGS=j.list||[]; _loadedAt=Date.now(); _todayAt=todayIso(); ME=j.me||ME;
    roomsFill(j.rooms||[]);
    build(); render();
    if(TAB==='write') wRoomsFill();
    if(_afterLoad){ var cb=_afterLoad; _afterLoad=null; cb(); }
  }).catch(function(){ if(my!==LOAD_REQ) return; err('서버에서 답이 오지 않았습니다.'); document.getElementById('gBody').innerHTML='<tr><td class="empty">조회하지 못했습니다.</td></tr>'; });
}
function roomsFill(rooms){
  ROOMS={}; var sel=document.getElementById('room'), cur=sel.value;
  var h='<option value="0">전체 방</option>';
  rooms.forEach(function(r){ ROOMS[r.roomSeq]=r; h+='<option value="'+r.roomSeq+'">'+esc((r.roomGb==='D'?'1:1 · ':'')+(r.dispNm||r.roomNm||('방 '+r.roomSeq)))+'</option>'; });
  sel.innerHTML=h; sel.value=cur; if(sel.value!==cur) sel.value='0';
}
function roomNm(seq){ var r=ROOMS[seq]; return r ? ((r.roomGb==='D'?'1:1 · ':'')+(r.dispNm||r.roomNm||('방 '+seq))) : ('방 '+seq); }

/* build — 글 → 직원×날짜 묶음(GROUPS) + 직원 목록(EMPS). 같은 직원·같은 날짜는 합친다(원문은 srcs 에 전부).
   ★이어 붙이는 차례 = 최근 보낸 글부터(2026-11-08 사용자 캡처 「이 경우 하단이 정리된 것 같은데」 — 상세는 최근 글부터인데 격자는 오래된 글부터라 어긋났다).
   서버는 REG_DTTM 오름차순으로 주므로 여기서 뒤집는다. 격자 칸·직원별·엑셀·인쇄가 전부 이 차례를 쓴다 */
function build(){
  var f=document.getElementById('frDt').value, e=document.getElementById('toDt').value;
  var map={}, emps={};
  MSGS.slice().sort(function(a,b){ return a.regDttm<b.regDttm?1:a.regDttm>b.regDttm?-1:(b.msgSeq||0)-(a.msgSeq||0); }).forEach(function(m){
    var gs=parseWorkLog(m.msgTxt, m.regDttm);
    gs.forEach(function(g){
      if(g.date<f || g.date>e) return;
      var k=m.userId+'|'+g.date, o=map[k];
      if(!o){ o=map[k]={ userId:m.userId, userNm:m.userNm, date:g.date, items:[], srcs:[] }; }
      g.items.forEach(function(t){ o.items.push({ t:t, msgSeq:m.msgSeq }); });
      if(!o.srcs.some(function(s){ return s.msgSeq===m.msgSeq; })) o.srcs.push({ msgSeq:m.msgSeq, regDttm:m.regDttm, roomSeq:m.roomSeq, text:m.msgTxt, hasDate:g.hasDate });
      emps[m.userId]=m.userNm;
    });
  });
  GROUPS=Object.keys(map).map(function(k){ return map[k]; });
  EMPS=Object.keys(emps).map(function(id){ return { userId:id, userNm:emps[id] }; }).sort(function(a,b){ return a.userNm<b.userNm?-1:a.userNm>b.userNm?1:0; });
  var sel=document.getElementById('emp'), cur=sel.value, h='<option value="">전체</option>';
  EMPS.forEach(function(u){ h+='<option value="'+esc(u.userId)+'">'+esc(u.userNm)+'</option>'; });
  sel.innerHTML=h; sel.value=cur; if(sel.value!==cur) sel.value='';
  SEL=null;
}
function qOf(){ return (document.getElementById('q').value||'').trim().toLowerCase(); }
function hit(t, q){ return !q || (t||'').toLowerCase().indexOf(q)>=0; }
/* 거른 묶음 — 직원·글자. 글자가 있으면 걸린 항목만 남긴다(한 항목도 안 걸리면 그 칸은 비운다) */
function view(){
  var q=qOf(), emp=document.getElementById('emp').value;
  return GROUPS.map(function(g){
    if(emp && g.userId!==emp) return null;
    var items=q ? g.items.filter(function(x){ return hit(x.t,q); }) : g.items;
    if(q && !items.length) return null;
    return { userId:g.userId, userNm:g.userNm, date:g.date, items:items, all:g.items.length, srcs:g.srcs };
  }).filter(Boolean);
}

/* ── 격자 ── */
function render(){
  var V=view(), q=qOf(), emp=document.getElementById('emp').value;
  var days={}, cols={}, nItem=0, msgs={};
  V.forEach(function(g){ days[g.date]=1; cols[g.userId]=g.userNm; nItem+=g.items.length; g.srcs.forEach(function(s){ msgs[s.msgSeq]=1; }); });
  var dayList=Object.keys(days).sort().reverse();
  var colList=EMPS.filter(function(u){ return cols[u.userId]; });
  document.getElementById('kEmp').innerHTML=colList.length+'<small>명</small>';
  document.getElementById('kDay').innerHTML=dayList.length+'<small>일</small>';
  document.getElementById('kItem').innerHTML=nItem+'<small>건</small>';
  document.getElementById('kMsg').innerHTML=Object.keys(msgs).length+'<small>건</small>';
  var note=[]; if(emp){ var u=EMPS.filter(function(x){ return x.userId===emp; })[0]; note.push('직원 '+(u?u.userNm:emp)); } if(q) note.push('「'+q+'」 든 항목만');
  document.getElementById('kNote').style.display=note.length?'':'none'; document.getElementById('kNoteV').textContent=note.join(' · ');
  if(TAB==='emp'){ renderEmp(V); return; }
  if(TAB==='write'){ wPrevUpd(); return; }
  var head='<tr><th class="dt">날짜</th>';
  colList.forEach(function(u){ var n=V.filter(function(g){ return g.userId===u.userId; }).reduce(function(a,g){ return a+g.items.length; },0); head+='<th>'+esc(u.userNm)+'<small>'+n+'건</small></th>'; });
  head+='</tr>';
  document.getElementById('gHead').innerHTML=head;
  if(!dayList.length){ document.getElementById('gBody').innerHTML='<tr><td class="empty" colspan="'+(colList.length+1)+'">'+(MSGS.length?'이 조건에 맞는 일지가 없습니다.':'기간 안에 메신저 글이 없습니다.')+'</td></tr>'; return; }
  var by={}; V.forEach(function(g){ by[g.userId+'|'+g.date]=g; });
  var h='';
  dayList.forEach(function(d){
    h+='<tr><td class="dt '+wcls(d)+'">'+esc(d)+'<small>'+wday(d)+'요일</small></td>';
    colList.forEach(function(u){
      var g=by[u.userId+'|'+d];
      if(!g){ h+='<td></td>'; return; }
      var on = SEL && SEL.userId===u.userId && SEL.date===d;
      h+='<td><div class="cell'+(on?' on':'')+'" onclick="pick(\''+esc(u.userId)+'\',\''+d+'\')" title="누르면 원문이 아래에"><span class="n">'+g.items.length+'건'+(g.all>g.items.length?' / '+g.all:'')+'</span><ol>';
      g.items.forEach(function(x){ h+='<li'+(q&&hit(x.t,q)?' class="hit"':'')+'>'+esc(x.t)+'</li>'; });
      h+='</ol></div></td>';
    });
    h+='</tr>';
  });
  document.getElementById('gBody').innerHTML=h;
}
/* 칸을 누르면 아래 상세 — 그 직원·그 날짜의 원문 글 전부(날짜 줄은 강조). ★글은 최근 보낸 것부터(2026-11-08 사용자 「최근일자 부터」 — 글 안의 날짜 차례는 원문 그대로) */
function pick(userId, date){
  var g=GROUPS.filter(function(x){ return x.userId===userId && x.date===date; })[0];
  if(!g) return;
  SEL={ userId:userId, date:date };
  var h='<div class="dh"><b>'+esc(g.userNm)+'</b> '+esc(date)+' ('+wday(date)+') · 항목 '+g.items.length+'건 · 글 '+g.srcs.length+'건'+(g.srcs.length>1?' <small style="color:var(--dim)">(최근 글부터)</small>':'')+'<span class="bg" onclick="dtlBig()" id="dtlBg" title="상세를 크게 — 격자를 최소로 줄이고 이 칸이 나머지를 다 씁니다 (다시 누르면 원래대로)">⛶ 크게</span><span class="x" onclick="dtlClose()" title="닫기">✕</span></div>';
  g.srcs.slice().sort(function(a,b){ return a.regDttm<b.regDttm?1:a.regDttm>b.regDttm?-1:0; }).forEach(function(s){
    var body=esc(s.text).replace(/\r\n?/g,'\n').split('\n').map(function(ln){ return DATE_RE.test(ln) ? '<span class="dl">'+ln+'</span>' : ln; }).join('\n');
    h+='<div class="src"><div class="meta"><b>'+esc(s.regDttm)+'</b>'+esc(roomNm(s.roomSeq))+(s.hasDate?'':'<br><span style="color:#b06a00">날짜 줄 없음 — 보낸 날짜로</span>')+'</div><pre>'+body+'</pre></div>';
  });
  var d=document.getElementById('dtl'); d.innerHTML=h; d.className='card on'; d.scrollTop=0; dtlBigPaint();
  var cells=document.querySelectorAll('#gBody .cell.on'); for(var i=0;i<cells.length;i++) cells[i].classList.remove('on');
  render();
}
function dtlClose(){ SEL=null; document.getElementById('dtl').className='card'; render(); }
/* [⛶ 크게] — .cols.big 토글, localStorage 기억(konetWlDtlBig). 처음 상태는 작게 */
function dtlBigOn(){ try{ return localStorage.getItem('konetWlDtlBig')==='1'; }catch(e){ return false; } }
function dtlBig(){ var on=!dtlBigOn(); try{ localStorage.setItem('konetWlDtlBig', on?'1':'0'); }catch(e){} dtlBigPaint(); }
function dtlBigPaint(){ var on=dtlBigOn(); var c=document.querySelector('.cols'); if(c) c.classList.toggle('big', on); var b=document.getElementById('dtlBg'); if(b) b.textContent=on?'⛶ 작게':'⛶ 크게'; }

/* ── 직원별 보기 — 한 명을 고르면 날짜 순 목록(★최근 날짜가 위 — 2026-11-08 사용자 「직원별 최근것부터」, 처음 판은 오래된 것부터). 직원 칸이 「전체」면 첫 직원. 인쇄·엑셀도 eRows 를 써 같은 차례 ── */
function tab(t){
  if(t==='write' && !WRITE_ON) return;   /* 작성 탭 숨김(2026-11-08) — 메신저에서 쓴다 */
  TAB=t;
  document.getElementById('tbGrid').className='tb'+(t==='grid'?' on':''); document.getElementById('tbEmp').className='tb'+(t==='emp'?' on':''); document.getElementById('tbWrite').className='tb'+(t==='write'?' on':'');
  document.getElementById('gridWrap').style.display = t==='grid' ? '' : 'none';
  document.getElementById('dtl').style.display = t==='grid' && SEL ? 'block' : 'none';
  document.getElementById('empWrap').style.display = t==='emp' ? '' : 'none';
  document.getElementById('writeWrap').style.display = t==='write' ? '' : 'none';
  if(t==='write'){ wInit(); return; }

  /* 직원별 탭이 「전체」를 첫 직원으로 바꾼 것은 그 탭 안에서만 — 격자로 돌아오면 「전체」로 되돌린다(손으로 고른 직원은 그대로). 2026-11-08 왕복 지적 */
  var es=document.getElementById('emp');
  if(t==='emp'){ if(!es.value && EMPS.length){ es.value=EMPS[0].userId; _empAuto=es.value; } }
  else { if(_empAuto && es.value===_empAuto) es.value=''; _empAuto=''; }
  render();
}
function eRows(V){
  var emp=document.getElementById('emp').value;
  return V.filter(function(g){ return g.userId===emp; }).sort(function(a,b){ return a.date<b.date?1:a.date>b.date?-1:0; });   /* 최근이 위 */
}
function renderEmp(V){
  var emp=document.getElementById('emp').value, u=EMPS.filter(function(x){ return x.userId===emp; })[0];
  var rows=eRows(V);
  document.getElementById('eTitle').textContent = u ? u.userNm : '직원을 고르세요';
  document.getElementById('eSub').textContent = document.getElementById('frDt').value+' ~ '+document.getElementById('toDt').value+' · '+rows.length+'일 · '+rows.reduce(function(a,g){ return a+g.items.length; },0)+'건';
  if(!u){ document.getElementById('eBody').innerHTML='<tr><td class="empty" colspan="6">위 「직원」에서 한 명을 고르세요.</td></tr>'; return; }
  if(!rows.length){ document.getElementById('eBody').innerHTML='<tr><td class="empty" colspan="6">이 기간에 '+esc(u.userNm)+'의 일지가 없습니다.</td></tr>'; return; }
  var h='';
  rows.forEach(function(g){
    g.items.forEach(function(x, i){
      var s=g.srcs.filter(function(z){ return z.msgSeq===x.msgSeq; })[0]||{};
      h+='<tr'+(i===0?' class="d0"':'')+'>';
      if(i===0) h+='<td class="c '+wcls(g.date)+'" rowspan="'+g.items.length+'">'+esc(g.date)+'</td><td class="c '+wcls(g.date)+'" rowspan="'+g.items.length+'">'+wday(g.date)+'</td>';
      h+='<td class="r">'+(i+1)+'</td><td>'+esc(x.t)+'</td><td class="meta">'+esc(s.regDttm||'')+'</td><td class="meta">'+esc(roomNm(s.roomSeq))+'</td></tr>';
    });
  });
  document.getElementById('eBody').innerHTML=h;
}
/* 엑셀 — 날짜·요일·번호·항목·보낸 때·방 (XLSX 가 없으면 CSV) */
function eData(){
  var V=view(), rows=eRows(V), out=[];
  rows.forEach(function(g){ g.items.forEach(function(x,i){ var s=g.srcs.filter(function(z){ return z.msgSeq===x.msgSeq; })[0]||{}; out.push([g.date, wday(g.date), i+1, x.t, s.regDttm||'', roomNm(s.roomSeq)]); }); });
  return out;
}
function fnSafe(s){ return (s||'').replace(/[\\/:*?"<>|]/g,'_'); }
function eExcel(){
  var emp=document.getElementById('emp').value, u=EMPS.filter(function(x){ return x.userId===emp; })[0];
  if(!u){ _alertBox('위 「직원」에서 한 명을 고르세요.',{icon:'⚠️'}); return; }
  var data=eData(); if(!data.length){ _alertBox('내려받을 일지가 없습니다.',{icon:'⚠️'}); return; }
  var tag=document.getElementById('frDt').value+'~'+document.getElementById('toDt').value;
  var aoa=[['직원 업무일지 — '+u.userNm+' · '+tag], [], ['날짜','요일','번호','항목','보낸 때','방']].concat(data);
  if(window.XLSX && XLSX.utils){
    var ws=XLSX.utils.aoa_to_sheet(aoa);
    ws['!cols']=[{wch:12},{wch:5},{wch:5},{wch:60},{wch:20},{wch:30}];
    ws['!merges']=[{ s:{r:0,c:0}, e:{r:0,c:5} }];
    var TH={ font:{ bold:true, color:{ rgb:'FFFFFF' } }, fill:{ patternType:'solid', fgColor:{ rgb:'137A6C' } }, alignment:{ horizontal:'center' } };
    for(var c=0;c<6;c++){ var ref=XLSX.utils.encode_cell({ r:2, c:c }); if(ws[ref]) ws[ref].s=TH; }
    var t0=XLSX.utils.encode_cell({ r:0, c:0 }); if(ws[t0]) ws[t0].s={ font:{ bold:true, sz:14 } };
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, fnSafe('업무일지_'+u.userNm).slice(0,31));
    XLSX.writeFile(wb, fnSafe('직원 업무일지 '+u.userNm+' '+tag)+'.xlsx');
  } else {
    var csv='﻿'+aoa.map(function(r){ return r.map(function(v){ return '"'+(''+(v==null?'':v)).replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var a=document.createElement('a'); a.href=URL.createObjectURL(new Blob([csv],{type:'text/csv;charset=utf-8'})); a.download=fnSafe('직원 업무일지 '+u.userNm+' '+tag)+'.csv'; document.body.appendChild(a); a.click(); document.body.removeChild(a);
  }
  _toast('엑셀을 내려받습니다.','ok');
}
/* 인쇄 — ★새 창에 그린다. 이 화면은 셸 iframe 이라 여기서 window.print() 를 부르면 셸이 찍힌다 */
function ePrint(){
  var emp=document.getElementById('emp').value, u=EMPS.filter(function(x){ return x.userId===emp; })[0];
  if(!u){ _alertBox('위 「직원」에서 한 명을 고르세요.',{icon:'⚠️'}); return; }
  var rows=eRows(view()); if(!rows.length){ _alertBox('인쇄할 일지가 없습니다.',{icon:'⚠️'}); return; }
  var tag=document.getElementById('frDt').value+' ~ '+document.getElementById('toDt').value, b='';
  rows.forEach(function(g){ b+='<h3>'+esc(g.date)+' ('+wday(g.date)+')</h3><ol>'; g.items.forEach(function(x){ b+='<li>'+esc(x.t)+'</li>'; }); b+='</ol>'; });
  var html='<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><title>직원 업무일지 — '+esc(u.userNm)+'</title><style>@page{margin:0}body{font-family:"맑은 고딕",sans-serif;padding:14mm 12mm;font-size:13px;color:#1f2a37}h2{margin:0 0 2px;font-size:19px}.s{color:#6b7a89;font-size:12px;margin-bottom:12px}h3{margin:12px 0 3px;font-size:14px;color:#137a6c;border-bottom:1px solid #cfe0da;padding-bottom:2px}ol{margin:0 0 4px;padding-left:22px;line-height:1.5}</style></head><body><h2>📋 직원 업무일지 — '+esc(u.userNm)+'</h2><div class="s">'+esc(tag)+' · '+rows.length+'일 · '+rows.reduce(function(a,g){ return a+g.items.length; },0)+'건 · 직원 메신저 글 기준</div>'+b+'<script>window.onload=function(){ setTimeout(function(){ window.print(); },250); }; window.onafterprint=function(){ window.close(); };<\/script></body></html>';
  var w=window.open('','_blank'); if(!w){ _alertBox('팝업이 차단됐습니다. 이 사이트의 팝업을 허용해 주세요.',{icon:'⚠️'}); return; }
  w.document.open(); w.document.write(html); w.document.close();
}

/* ══════════════════════════════════════════════════════════════════════════
   ✏ 작성 — 날짜 묶음(WB = [{date, text}]) → 「M/D\n1. …\n2. …」 글 하나 → 기존 /emp/msgSend.do (파일 머리 주석)
   ══════════════════════════════════════════════════════════════════════════ */
var WB=[];
function wInit(){ if(!WB.length) WB=[{ date:todayIso(), text:'' }]; wRoomsFill(); wRender(); }
function wRoomsFill(){
  var sel=document.getElementById('wRoom'), cur=sel.value; try{ if(!cur) cur=localStorage.getItem('konetWorkLogRoom')||''; }catch(e){}
  var list=Object.keys(ROOMS).map(function(k){ return ROOMS[k]; }).sort(function(a,b){ return (a.roomGb==='D')-(b.roomGb==='D'); });   /* 그룹방 먼저 */
  var h=''; list.forEach(function(r){ h+='<option value="'+r.roomSeq+'">'+esc(roomNm(r.roomSeq))+'</option>'; });
  sel.innerHTML = h || '<option value="0">들어 있는 방이 없습니다 — 직원 메신저에서 먼저 대화를 여세요</option>';
  if(h){ if(cur) sel.value=cur; if(!cur || sel.value!==cur) sel.value=''+list[0].roomSeq; }   /* 기억한 방이 없거나 이제 안 든 방이면 첫 방 */
}
function wRoomKeep(){ try{ localStorage.setItem('konetWorkLogRoom', document.getElementById('wRoom').value); }catch(e){} wPrevUpd(); }
function wRender(){
  var h='';
  WB.forEach(function(b,i){
    h+='<div class="wblk" data-i="'+i+'"><div class="wrow"><span class="lb">날짜</span><input type="date" class="wDt" data-norange="1" value="'+esc(b.date)+'" onchange="wPrevUpd()"><span class="has" id="wHas'+i+'"></span>'+(WB.length>1?'<span class="x" onclick="wDelBlock('+i+')" title="이 날짜 묶음 빼기">✕</span>':'')+'</div>'
      +'<textarea class="wTx" placeholder="한 줄에 하나 — Enter 로 다음 줄 (번호는 저절로 붙습니다)" oninput="wPrevUpd()">'+esc(b.text)+'</textarea></div>';
  });
  document.getElementById('wBlocks').innerHTML=h;
  wPrevUpd();
}
function wRead(){ var bl=document.querySelectorAll('#wBlocks .wblk'); WB=[]; for(var i=0;i<bl.length;i++) WB.push({ date:bl[i].querySelector('.wDt').value, text:bl[i].querySelector('.wTx').value }); return WB; }
function wItems(text){ return (''+(text||'')).replace(/\r\n?/g,'\n').split('\n').map(function(l){ return l.replace(ITEM_RE,'').trim(); }).filter(Boolean); }   /* 사람이 「1. 」을 붙여 적어도 두 번 안 붙게 뗀다 */
function wBlocks(){ return wRead().map(function(b){ return { date:b.date, items:wItems(b.text) }; }); }
function wText(){ return wBlocks().filter(function(b){ return b.date && b.items.length; }).map(function(b){ return md(b.date)+'\n'+b.items.map(function(t,i){ return (i+1)+'. '+t; }).join('\n'); }).join('\n\n'); }
function wPrevUpd(){
  if(TAB!=='write') return;
  var bs=wBlocks(), txt=wText(), n=bs.reduce(function(a,b){ return a+b.items.length; },0), p=document.getElementById('wPrev');
  p.textContent = txt || '날짜와 항목을 적으면 보낼 글이 여기 보입니다.'; p.className='wprev'+(txt?'':' e');
  document.getElementById('wCnt').textContent = txt ? ('날짜 '+bs.filter(function(b){ return b.date && b.items.length; }).length+'개 · 항목 '+n+'건 · '+txt.length+'자'+(txt.length>4000?' — 4,000자를 넘었습니다':'')) : '';
  bs.forEach(function(b,i){ var el=document.getElementById('wHas'+i); if(!el) return; var mine=ME ? GROUPS.filter(function(g){ return g.userId===ME && g.date===b.date; })[0] : null;
    el.textContent = mine ? ('이 날짜에 이미 내 일지 '+mine.items.length+'건 — 보내면 새 글로 덧붙습니다') : ''; });
}
function wAddBlock(){ wRead(); var last=WB[WB.length-1]; WB.push({ date: last && last.date ? addDays(last.date,1) : todayIso(), text:'' }); wRender(); var tx=document.querySelectorAll('#wBlocks .wTx'); if(tx.length) tx[tx.length-1].focus(); }
function wDelBlock(i){ wRead(); if(WB.length<=1) return; WB.splice(i,1); wRender(); }
function wReset(){ WB=[{ date:todayIso(), text:'' }]; wRender(); }
function wSend(){
  var room=+document.getElementById('wRoom').value||0, bs=wBlocks();
  if(!room){ _alertBox('보낼 방이 없습니다 — 직원 메신저에서 먼저 대화를 여세요.',{icon:'⚠️'}); return; }
  for(var i=0;i<bs.length;i++){ if(!bs[i].date){ _alertBox('날짜가 빈 묶음이 있습니다.',{icon:'⚠️'}); return; } if(!bs[i].items.length){ _alertBox(md(bs[i].date)+' 묶음에 항목이 없습니다 — 적거나 ✕ 로 빼 주세요.',{icon:'⚠️'}); return; } }
  var txt=wText(); if(!txt){ _alertBox('보낼 항목이 없습니다.',{icon:'⚠️'}); return; }
  if(txt.length>4000){ _alertBox('한 번에 4,000자까지 보낼 수 있습니다 — 날짜 묶음을 나눠 보내 주세요.',{icon:'⚠️'}); return; }
  var n=bs.reduce(function(a,b){ return a+b.items.length; },0), dates=bs.map(function(b){ return md(b.date); }).join(' · ');
  _confirmBox({ msg:'<b>'+esc(roomNm(room))+'</b> 방에 메신저 글로 보냅니다.<br>'+esc(dates)+' · 항목 '+n+'건<br><small>보낸 뒤에는 여기서 못 고칩니다(메신저에서 내 글 지우기).</small>', icon:'💬', okText:'보내기', okColor:'blue', onOk:function(){
    var btn=document.getElementById('wSendBtn'); btn.disabled=true;
    post('/emp/msgSend.do',{ roomSeq:room, text:txt }).then(function(j){
      btn.disabled=false; if(fail(j)) return;
      _toast('업무일지를 메신저로 보냈습니다.','ok');
      try{ if(parent && typeof parent.konetEmpBadge==='function') parent.konetEmpBadge(); }catch(e){}
      var first=bs[0].date, fr=document.getElementById('frDt'), to=document.getElementById('toDt');   /* 기간 밖 날짜를 썼으면 기간을 그 날짜까지 넓힌다 */
      bs.forEach(function(b){ if(b.date<fr.value) fr.value=b.date; if(b.date>to.value) to.value=b.date; }); rgSync();
      WB=[{ date:todayIso(), text:'' }]; wRender();
      _afterLoad=function(){ tab('grid'); if(ME) pick(ME, first); };
      load();
    }).catch(function(){ btn.disabled=false; err('서버에서 답이 오지 않았습니다 — 메신저에서 글이 올라갔는지 확인한 뒤 다시 보내세요.'); });
  } });
}

/* 셸이 이 화면을 다시 보일 때(logiFrame) — 날이 바뀌어 끝날짜가 어제 「오늘」에 머물러 있으면 오늘로 옮기고 다시 읽는다. 3초 안 재호출은 한 번만 */
window.konetShown=function(){
  if(Date.now()-_loadedAt<3000) return;
  var t=todayIso(), e=document.getElementById('toDt');
  if(_todayAt && t!==_todayAt && e.value===_todayAt){ e.value=t; if(_rg==='d') document.getElementById('frDt').value=t; else if(_rg==='w') document.getElementById('frDt').value=addDays(t,-6); else if(_rg==='m') document.getElementById('frDt').value=t.slice(0,8)+'01'; }
  load();
};
if(!WRITE_ON) document.getElementById('tbWrite').style.display='none';   /* 작성 탭 단추 숨김 — 위 WRITE_ON */
rg('m');
</script>
</body>
</html>
