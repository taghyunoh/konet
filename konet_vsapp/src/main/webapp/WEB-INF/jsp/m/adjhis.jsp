<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 재고조정 내역 — /m/adjhis.do (MobileController, 로그인 필수). 2026-09-14 신설. 조회 전용.
     사용자 요청 「재고조정 내용 담당자별로 모바일에 — 최근 것부터 누가 무엇을 어떻게 수정했는지 대표자가 보려 함」.
     · 자료 = /prod/stockAdjHisList.do — PC 재고 일괄조정 [조정 이력]·상품코드등록 이력과 같은 조회(TBL_STOCK_ADJ_HIS).
       모바일만 넘기는 조건 : inclCancel=Y(되돌린 묶음도 — 누가 언제 되돌렸나) · regFrom(«고친 날» 기준 기간).
     · 저장 한 번(BATCH_NO) = 카드 한 장 · 최근 저장부터 · 날짜마다 구분선. 담당자 칩으로 거른다(화면에서 — 서버를 다시 안 부른다).
     · 등록자 「기록 없음」 = 로그인이 끊긴 채 저장된 옛 조정(2026-09-14 부터 서버가 막는다 — UserController ADJ_LOGIN_MSG).
     · 새 조정 알림(앱 안) : 이 화면을 보면 «본 번호»(localStorage konetAdjSeen)를 올린다 → 아래 탭의 빨간 숫자가 사라진다(m.js M.adjBadge). --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 재고조정 내역</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/m/m.css?v=20260914a">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<script src="<%=request.getContextPath()%>/m/m.js?v=20260914a"></script>
<style>
  .chips{ display:flex; gap:6px; overflow-x:auto; padding:2px 2px 8px; -webkit-overflow-scrolling:touch; scrollbar-width:none; }
  .chips::-webkit-scrollbar{ display:none; }
  .chip{ flex:0 0 auto; height:36px; padding:0 13px; border:1px solid var(--bd); border-radius:18px; background:#fff; color:var(--ink);
    font-size:16px; font-weight:700; white-space:nowrap; }
  .chip small{ font-weight:600; color:var(--mute); margin-left:5px; font-variant-numeric:tabular-nums; }
  .chip.on{ background:var(--teal); border-color:var(--teal); color:#fff; } .chip.on small{ color:#d9efe9; }
  .chip.none{ color:var(--amber); }
  .optl{ display:flex; align-items:center; gap:6px; font-size:15.5px; color:var(--mute); }
  .optl input{ width:18px; height:18px; accent-color:var(--teal); }
  .dsep{ margin:16px 4px 8px; font-size:15.5px; font-weight:800; color:var(--mute); }
  .adj .ah{ display:flex; align-items:flex-start; gap:10px; }
  .adj .aw{ flex:1; min-width:0; font-size:18.5px; font-weight:800; line-height:1.3; }
  .adj .aw small{ display:block; font-size:14px; font-weight:500; color:var(--mute); }
  .adj .at{ text-align:right; font-size:17px; font-weight:800; font-variant-numeric:tabular-nums; white-space:nowrap; }
  .adj .at small{ display:block; font-size:14px; font-weight:500; color:var(--mute); }
  .adj .ar{ margin-top:6px; font-size:15.5px; color:#3d4d5c; }
  .adj .ar b{ font-variant-numeric:tabular-nums; }
  .adj .list{ margin-top:8px; }
  .adj .row{ align-items:flex-start; }
  .adj .row .k{ white-space:normal; word-break:break-all; font-size:16.5px; line-height:1.35; }
  .adj .ba{ font-size:17px; }
  .adj .be{ margin-top:1px; }
  .up{ color:var(--blue) !important; } .dn{ color:var(--red) !important; }
  .adj.cancel{ opacity:.62; } .adj.cancel .ba{ text-decoration:line-through; }
  .cxl{ margin-top:6px; font-size:15px; font-weight:700; color:var(--amber); background:#fff4e0; border-radius:8px; padding:5px 9px; }
  .adj.new{ border-color:var(--teal); box-shadow:0 0 0 2px rgba(19,122,108,.18); }
  .newb{ font-size:13px; font-weight:800; color:#fff; background:var(--red); border-radius:10px; padding:1px 7px; margin-left:6px; vertical-align:2px; }
  .nouser{ color:var(--amber); }
  .more{ margin-top:8px; }
</style>
</head>
<body data-page="adjhis">
<header>
  <div class="hd1">
    <h1>재고조정 내역</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="M.logout()">로그아웃</button>
  </div>
  <div class="seg" id="seg">
    <button type="button" data-p="0">오늘</button><button type="button" data-p="7" class="on">7일</button><button type="button" data-p="30">30일</button><button type="button" data-p="all">전체</button>
  </div>
</header>

<main>
  <section class="card">
    <h2>담당자 <small id="sum"></small><button type="button" class="btn sm ghost rt" onclick="load()">새로고침</button></h2>
    <div class="chips" id="chips"></div>
    <label class="optl"><input type="checkbox" id="inclX" checked onchange="render()">되돌린 조정도 보기</label>
  </section>
  <div id="body"><div class="loading">불러오는 중…</div></div>
  <p class="note">누가 · 언제 · 어떤 품목을 몇 개에서 몇 개로 고쳤는지 최근 저장부터 보여 줍니다. 저장 한 번이 카드 한 장입니다.<br>
    <span class="nouser">기록 없음</span> = 로그인이 끊긴 채 저장된 옛 조정입니다(이제는 서버가 막습니다).</p>
</main>

<script>
var $=M.$, n=M.n, esc=M.esc;
var _rows=null, _period='7', _who='*', _prevSeen=0, _open={}, _loadedAt=0;
var MAX_BATCH=60, SHOW_ROWS=6, _limit=MAX_BATCH;

/* 기간 = «고친 날» 기준. 7일 = 오늘 포함 7일(오늘−6 ~ 오늘) */
function periodFrom(p){ return p==='all' ? '' : M.addDay(M.ymd(), p==='0' ? 0 : -(+p-1)); }
function myId(){ return String((M.user && M.user.userId) || ''); }
function who(r){ return r.regUser ? String(r.regUser) : ''; }
function whoNm(r){ return r.regUser ? (r.regUserNm || r.regUser) : '기록 없음'; }
function sgn(v){ v=Math.round(n(v)); return v>0 ? '+'+M.fmt0(v) : v<0 ? '−'+M.fmt0(-v) : '0'; }
function boxEa(b,e){ b=n(b); e=n(e); return ((b?M.fmt0(b)+'BOX':'')+(b&&e?' ':'')+(e?M.fmt0(e)+'EA':'')) || '0'; }
function fmtDt(s){ s=String(s||''); return s.length>=16 ? (+s.slice(5,7))+'/'+(+s.slice(8,10))+' '+s.slice(11,16) : (s||'—'); }

function load(){
  var el=$('body'); el.innerHTML='<div class="loading">불러오는 중…</div>';
  var q={ inclCancel:'Y' }, f=periodFrom(_period); if(f) q.regFrom=f;
  return M.form('/prod/stockAdjHisList.do', q).then(function(res){
    _rows=res.data||[]; _loadedAt=Date.now();
    /* 알림 : 이 화면을 본 것 = 지금까지의 조정을 다 본 것. «새» 표시는 올리기 전 번호로 가른다 */
    _prevSeen=M.adjSeen();
    var mx=_prevSeen; _rows.forEach(function(r){ mx=Math.max(mx, n(r.adjSeq)); });
    if(mx>_prevSeen) M.adjSeen(mx);
    M.adjBadgeSet(0); try{ sessionStorage.setItem('konetAdjToast','0'); }catch(e){}
    _limit=MAX_BATCH; render();
  }).catch(function(e){ el.innerHTML='<div class="err">불러오지 못했습니다. '+esc(M.errMsg(e))+'<button type="button" onclick="load()">다시</button></div>'; });
}

function render(){
  if(!_rows) return;
  var inclX=$('inclX').checked;
  var rows=_rows.filter(function(r){ return inclX || r.actionYn!=='N'; });
  /* 담당자 칩 — «저장 묶음» 수로 센다(품목 줄 수가 아니라) */
  var cnt={}, nm={}, seenB={};
  rows.forEach(function(r){ var k=who(r), bk=k+'|'+r.batchNo; if(seenB[bk]) return; seenB[bk]=1; cnt[k]=(cnt[k]||0)+1; nm[k]=whoNm(r); });
  var keys=Object.keys(cnt).sort(function(a,b){ return (a==='')-(b==='') || cnt[b]-cnt[a] || String(nm[a]).localeCompare(String(nm[b])); });
  if(_who!=='*' && !cnt[_who]) _who='*';
  $('chips').innerHTML='<button type="button" class="chip'+(_who==='*'?' on':'')+'" data-w="*">전체<small>'+Object.keys(seenB).length+'</small></button>'
    + keys.map(function(k){ return '<button type="button" class="chip'+(k===_who?' on':'')+(k===''?' none':'')+'" data-w="'+esc(k)+'">'+esc(nm[k])+'<small>'+cnt[k]+'</small></button>'; }).join('');

  /* 저장 묶음으로 접기 — 서버가 최근 순으로 준다(첫 줄 순서 그대로) */
  var groups=[], by={};
  rows.forEach(function(r){
    if(_who!=='*' && who(r)!==_who) return;
    var g=by[r.batchNo]; if(!g){ g=by[r.batchNo]={ b:r.batchNo, r0:r, rows:[], mx:0 }; groups.push(g); }
    g.rows.push(r); g.mx=Math.max(g.mx, n(r.adjSeq));
  });
  $('sum').textContent = groups.length ? '저장 '+groups.length+'번 · '+keys.length+'명' : '';
  if(!groups.length){ $('body').innerHTML='<section class="card"><div class="empty">이 기간에 재고조정이 없습니다.</div></section>'; return; }
  var html='', lastDay='';
  groups.slice(0,_limit).forEach(function(g){
    var day=String(g.r0.regDttm||'').slice(0,10);
    if(day!==lastDay){ html+='<div class="dsep">'+esc(day ? M.lblDay(day) : '날짜 없음')+'</div>'; lastDay=day; }
    html+=card(g);
  });
  if(groups.length>_limit) html+='<button type="button" class="btn block ghost more" onclick="_limit+=MAX_BATCH; render()">더 보기 ('+(groups.length-_limit)+'번 남음)</button>';
  $('body').innerHTML=html;
}

function card(g){
  var r0=g.r0, cx=r0.actionYn==='N';
  var isNew=!cx && _prevSeen>0 && g.mx>_prevSeen && who(r0)!==myId();
  var tot=0; g.rows.forEach(function(r){ tot+=n(r.diffQty); });
  var t=String(r0.regDttm||''), base=M.d10(r0.baseDt);
  var baseLbl=(base && base!==t.slice(0,10)) ? '기준일 '+(+base.slice(5,7))+'/'+(+base.slice(8,10)) : '';
  var name = r0.regUser
    ? esc(r0.regUserNm || r0.regUser)+(isNew?'<span class="newb">새</span>':'')+(r0.regUserNm ? '<small>'+esc(r0.regUser)+'</small>' : '')
    : '<span class="nouser">기록 없음</span>'+(isNew?'<span class="newb">새</span>':'')+'<small>로그인이 끊긴 채 저장됨</small>';
  var open=!!_open[g.b], list=open ? g.rows : g.rows.slice(0,SHOW_ROWS);
  return '<section class="card adj'+(cx?' cancel':'')+(isNew?' new':'')+'">'
    +'<div class="ah"><div class="aw">'+name+'</div><div class="at">'+esc(t.slice(11,16)||'—')+(baseLbl?'<small>'+esc(baseLbl)+'</small>':'')+'</div></div>'
    +'<div class="ar">'+esc(r0.remark||'사유 없음')+' · <b>'+g.rows.length+'</b>품목 · 합계 <b class="'+(tot>0?'up':tot<0?'dn':'')+'">'+sgn(tot)+'</b></div>'
    +(cx ? '<div class="cxl">↩ 되돌림 · '+esc(r0.updUser ? (r0.updUserNm||r0.updUser) : '기록 없음')+' · '+esc(fmtDt(r0.updDttm))+'</div>' : '')
    +'<div class="list">'+list.map(line).join('')+'</div>'
    +(g.rows.length>SHOW_ROWS ? '<button type="button" class="btn sm ghost more" data-b="'+esc(g.b)+'">'+(open ? '접기' : '나머지 '+(g.rows.length-SHOW_ROWS)+'품목 더 보기')+'</button>' : '')
    +'</section>';
}
function line(r){
  var d=n(r.diffQty), pk=n(r.packQty);
  var be = pk>1 ? boxEa(r.befBox,r.befEa)+' → '+boxEa(r.aftBox,r.aftEa)+' · 입수 '+pk : '';
  return '<div class="row"><div class="k">'+esc(r.prodNm||'(상품명 없음)')
    +'<small>'+esc(r.prodCd||'')+(r.spec?' · '+esc(r.spec):'')+'</small>'
    +(be?'<small class="be">'+esc(be)+'</small>':'')+'</div>'
    +'<div class="v"><span class="ba">'+M.fmt0(r.befQty)+' → '+M.fmt0(r.aftQty)+'</span><small class="'+(d>0?'up':'dn')+'">'+sgn(d)+'</small></div></div>';
}

/* ---------- 조작 ---------- */
$('seg').onclick=function(e){
  var b=e.target.closest('[data-p]'); if(!b) return;
  _period=b.getAttribute('data-p');
  [].forEach.call(this.children, function(x){ x.classList.toggle('on', x===b); });
  load();
};
$('chips').onclick=function(e){ var b=e.target.closest('[data-w]'); if(!b) return; _who=b.getAttribute('data-w'); render(); };
$('body').onclick=function(e){ var b=e.target.closest('[data-b]'); if(!b) return; var k=b.getAttribute('data-b'); _open[k]=!_open[k]; render(); };
/* 앱으로 돌아왔을 때 1분 넘게 지났으면 새로 읽는다 */
document.addEventListener('visibilitychange', function(){ if(!document.hidden && _loadedAt && Date.now()-_loadedAt>60000) load(); });

/* ---------- 시작 ---------- */
M.tabbar('adjhis');
M.session().then(function(){ load(); }).catch(function(){});
</script>
</body>
</html>
