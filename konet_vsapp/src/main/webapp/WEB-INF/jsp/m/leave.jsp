<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 휴가자 조회 — /m/leave.do (MobileController, 로그인 필수). 2026-10-21 신설. 조회 전용.
     사용자 요청 「KONET_VSAPP 에서 당월 휴가자 볼 수 있게」 → 「버튼 추가 휴가자조회 로, 우측 끝에」(요약 바로 가기 넷째 칸).
     · 자료 = /mangr/leaveList.do(그 달 범위) + /mangr/leaveInfo.do(구분 색) — PC 웹 「직원관리 ▸ 직원 휴가 관리」와 같은 표(TBL_LEAVE_MST)·같은 구분 색(회사 설정 'leave').
     · 달 넘기기 ◀ ▶ · 위 타일 = 오늘 휴가 / 이번 달 건수·인원·일수 · 날짜별 줄(이름 + 구분 칩, 점선 = 승인 대기, 반려 제외) · 직원별 일수.
     · 사유는 안 보인다(개인 사정). 등록·수정·승인은 PC 웹에서. --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 휴가자 조회</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/m/m.css?v=20260914a">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<script src="<%=request.getContextPath()%>/m/m.js?v=20260914a"></script>
<style>
  .mnav{ display:flex; align-items:center; gap:8px; }
  .mnav button{ height:38px; min-width:44px; padding:0 12px; border:1px solid rgba(255,255,255,.45); border-radius:8px; background:rgba(255,255,255,.12); color:#fff; font:inherit; font-size:16px; font-weight:800; }
  .mnav .ym{ flex:1; text-align:center; font-size:19px; font-weight:800; color:#fff; }
  .lvchip{ display:inline-block; font-size:15px; font-weight:800; line-height:1.4; padding:2px 9px; border-radius:8px; color:#fff; background:#5a6b7a; margin:2px 5px 2px 0; white-space:nowrap; }
  .lvchip.pend{ opacity:.75; outline:2px dashed rgba(0,0,0,.3); outline-offset:-2px; }
  .lvday{ flex:0 0 82px; font-weight:800; color:var(--teal-d); font-size:16.5px; } .lvday.today{ color:var(--red); }
  .row.lv{ align-items:flex-start; } .row.lv .k{ white-space:normal; }
  .legend{ display:flex; flex-wrap:wrap; gap:8px 12px; font-size:14.5px; color:var(--mute); margin-top:8px; align-items:center; }
  .legend i{ display:inline-block; width:12px; height:12px; border-radius:3px; margin-right:4px; vertical-align:-1px; }
  .chips{ display:flex; gap:6px; overflow-x:auto; padding:2px 2px 8px; scrollbar-width:none; } .chips::-webkit-scrollbar{ display:none; }
  .chip{ flex:0 0 auto; height:36px; padding:0 13px; border:1px solid var(--bd); border-radius:18px; background:#fff; color:var(--ink); font-size:16px; font-weight:700; white-space:nowrap; }
  .chip small{ font-weight:600; color:var(--mute); margin-left:5px; } .chip.on{ background:var(--teal); border-color:var(--teal); color:#fff; } .chip.on small{ color:#d9efe9; }
</style>
</head>
<body data-page="leave">
<header>
  <div class="hd1">
    <h1>휴가자 조회</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="M.logout()">로그아웃</button>
  </div>
  <div class="mnav"><button type="button" onclick="mv(-1)">◀</button><span class="ym" id="ym">—</span><button type="button" onclick="mv(1)">▶</button><button type="button" onclick="today()">이번 달</button></div>
</header>

<main>
  <section class="card">
    <h2>🏖 이번 달 휴가자 <small id="lbl"></small><span class="badge ok" id="bg" hidden></span></h2>
    <div class="chips" id="chips"></div>
    <div id="body"><div class="loading">불러오는 중…</div></div>
  </section>
  <section class="card" id="byCard" hidden><h2>👤 직원별 <small>이 달 일수 · 반려 제외</small></h2><div id="byBody"></div></section>
  <p class="note">점선 칩 = 승인 대기(신청). 반려된 휴가는 보이지 않습니다. 등록·수정·승인은 PC 웹 「직원관리 ▸ 직원 휴가 관리」에서 합니다.</p>
</main>

<script>
var $=M.$, n=M.n, esc=M.esc, ymd=M.ymd, lblMon=M.lblMon, post=M.form;
var _ym=new Date(); _ym=new Date(_ym.getFullYear(), _ym.getMonth(), 1);
var _gbs=null, _rows=[], _me='', _who='', _loadedAt=0;
function color(g){ var x=(_gbs||[]).filter(function(o){ return o.nm===g; })[0]; return x?x.color:'#5a6b7a'; }
function shortGb(g){ return String(g||'').replace('(오전)','AM').replace('(오후)','PM'); }
function fmtD(v){ return (Math.round(n(v)*10)/10).toLocaleString('ko-KR'); }
function mv(k){ _ym=new Date(_ym.getFullYear(), _ym.getMonth()+k, 1); load(); }
function today(){ var t=new Date(); _ym=new Date(t.getFullYear(), t.getMonth(), 1); load(); }
function load(){
  _loadedAt=Date.now();
  var y=_ym.getFullYear(), m=_ym.getMonth()+1, a=ymd(new Date(y, m-1, 1)), b=ymd(new Date(y, m, 0));
  $('ym').textContent=y+'년 '+m+'월'; $('lbl').textContent=lblMon(a); $('bg').hidden=true;
  $('body').innerHTML='<div class="loading">불러오는 중…</div>';
  var gbP=_gbs ? Promise.resolve(_gbs) : post('/mangr/leaveInfo.do',{}).then(function(r){ _gbs=(r&&r.gbs)||[]; _me=r.userId||''; return _gbs; }).catch(function(){ _gbs=[]; return _gbs; });
  gbP.then(function(){ return post('/mangr/leaveList.do',{ frDt:a, toDt:b }); }).then(function(res){
    if(res&&res.error) throw new Error(res.error);
    _rows=(res.data||[]).filter(function(o){ return o.status!=='반려'; }); render();
  }).catch(function(e){ $('body').innerHTML='<div class="err">'+esc(e&&e.message||'불러오지 못했습니다.')+'<button type="button" onclick="load()">다시</button></div>'; });
}
function render(){
  var y=_ym.getFullYear(), m=_ym.getMonth()+1, tk=ymd(new Date()).replace(/-/g,''), rows=_rows;
  /* 직원 칩 — 이 달에 휴가가 있는 사람만 */
  var ppl={}, order=[]; rows.forEach(function(o){ if(!ppl[o.userId]){ ppl[o.userId]={ nm:o.userNm, c:0, d:0 }; order.push(o.userId); } ppl[o.userId].c++; ppl[o.userId].d+=n(o.days); });
  $('chips').innerHTML='<button type="button" class="chip'+(!_who?' on':'')+'" data-w="">전체<small>'+order.length+'명</small></button>'+order.map(function(id){ return '<button type="button" class="chip'+(_who===id?' on':'')+'" data-w="'+esc(id)+'">'+esc(ppl[id].nm)+'<small>'+ppl[id].c+'</small></button>'; }).join('');
  if(_who && !ppl[_who]) _who='';
  var list=_who ? rows.filter(function(o){ return o.userId===_who; }) : rows;
  $('bg').textContent=order.length+'명'; $('bg').hidden=!order.length;
  if(!list.length){ $('body').innerHTML='<p class="note" style="margin:0">'+y+'년 '+m+'월에 등록된 휴가가 없습니다.</p>'; $('byCard').hidden=true; return; }
  var todayL=list.filter(function(o){ return String(o.fromDt)<=tk && String(o.toDt)>=tk; });
  var h='<div class="tiles"><div class="tile"><span>오늘 휴가</span><b class="'+(todayL.length?'red':'')+'">'+(todayL.length?todayL.map(function(o){ return esc(o.userNm); }).join(', '):'없음')+'</b><em>'+(todayL.length?todayL.map(function(o){ return shortGb(o.leaveGb); }).join(' · '):M.lblDay(ymd(new Date())))+'</em></div>'
    +'<div class="tile"><span>이번 달</span><b class="teal">'+list.length+'건</b><em>'+fmtD(list.reduce(function(t,o){ return t+n(o.days); },0))+'일'+(_who?'':' · '+order.length+'명')+'</em></div></div>';
  var W=['일','월','화','수','목','금','토'], d=new Date(y, m-1, 1), days=[];
  while(d.getMonth()===m-1){ var k=ymd(d).replace(/-/g,''); var l=list.filter(function(o){ return String(o.fromDt)<=k && String(o.toDt)>=k; }); if(l.length) days.push({ k:k, w:W[d.getDay()], l:l }); d.setDate(d.getDate()+1); }
  h+='<div class="list">'+days.map(function(x){ return '<div class="row lv"><div class="lvday'+(x.k===tk?' today':'')+'">'+(+x.k.slice(4,6))+'/'+(+x.k.slice(6,8))+' ('+x.w+')</div><div class="k">'
      +x.l.map(function(o){ return '<span class="lvchip'+(o.status==='신청'?' pend':'')+'" style="background:'+color(o.leaveGb)+'">'+esc(o.userNm)+' '+esc(shortGb(o.leaveGb))+(n(o.days)!==1&&n(o.days)!==0.5?' '+fmtD(o.days)+'일':'')+(o.status==='신청'?' (신청)':'')+'</span>'; }).join('')+'</div></div>'; }).join('')+'</div>';
  var seen={}; h+='<div class="legend">'+(_gbs||[]).filter(function(g){ if(g.use===false) return false; var k=g.nm.replace(/\(.*\)$/,''); if(seen[k]) return false; seen[k]=1; return true; }).map(function(g){ return '<span><i style="background:'+g.color+'"></i>'+esc(g.nm.replace(/\(.*\)$/,''))+'</span>'; }).join('')+'</div>';
  $('body').innerHTML=h;
  $('byCard').hidden=false;
  $('byBody').innerHTML='<div class="list">'+order.map(function(id){ var p=ppl[id]; return '<div class="row tap'+(id===_me?' me':'')+'" data-w="'+esc(id)+'"><div class="k"><b>'+esc(p.nm)+'</b></div><div class="v">'+p.c+'건 · '+fmtD(p.d)+'일</div></div>'; }).join('')+'</div>';
}
$('chips').onclick=function(e){ var b=e.target.closest('[data-w]'); if(!b) return; _who=b.getAttribute('data-w'); render(); };
$('byBody').onclick=function(e){ var b=e.target.closest('[data-w]'); if(!b) return; var id=b.getAttribute('data-w'); _who=(_who===id?'':id); render(); window.scrollTo({ top:0, behavior:'smooth' }); };
document.addEventListener('visibilitychange', function(){ if(!document.hidden && _loadedAt && Date.now()-_loadedAt>60000) load(); });

/* ---------- 시작 ---------- */
M.tabbar('index');
M.session().then(function(){ load(); }).catch(function(){});
</script>
</body>
</html>
