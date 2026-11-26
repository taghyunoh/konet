<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>사진함</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<%--
  사진함 (2026-11-26 신설 — 사용자 「모바일에서 여러 장 찍은 사진을 카톡으로 하나씩 보내 PC 에서 받던 일 — 한꺼번에 PC 에서 보게」
          → 「날짜별 모음 · 줄인 사진만」 · 「보관 1개월로(그때그때 정리하면 되니까)」)
    · 셸 「정보 현황」 맨 아래 ▸ 사진함(logiFrame('photoBox') · 같은 날 직원관리에서 옮김). 사진은 모바일 앱(konetapp ▸ 📷 사진)에서 올린다 — 이 화면은 보고·내려받고·지운다.
    · 서버 = PhotoController(/photo/list.do · img.do · zip.do · del.do · title.do) · 표 = docs/sql/20261126_photo.sql.
    · 왼쪽 = 보관 기간(1개월) 안의 날짜 목록(묶음 수·사진 수) · 가운데 = 고른 기간의 묶음마다 작은 그림 격자.
      그림을 누르면 크게(← → 넘김 · Esc 닫기) · 체크해서 여러 장 ZIP · 지우기는 올린 사람이나 관리자만(서버가 다시 본다).
    · 그림은 목록에 안 실린다 — 작은 그림(thumb=1)·큰 그림을 img 태그가 따로 부른다(loading=lazy, 같은 번호는 브라우저가 기억).
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
  .bar input[type=text], .bar input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13.5px; background:#fff; font-family:inherit; }
  .bar input[type=text]{ width:220px; }
  .btn{ height:34px; padding:0 13px; border:1px solid var(--bd); border-radius:7px; background:#fff; cursor:pointer; font-size:13.5px; font-weight:700; color:#33414f; font-family:inherit; white-space:nowrap; }
  .btn:hover{ background:#eef3f6; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-teal:hover{ background:#0f6b5f; }
  .btn-red{ color:var(--red); border-color:#f0c7c2; }
  .btn:disabled{ opacity:.45; cursor:default; }
  .cnt{ color:var(--dim); font-size:12.5px; }
  .body{ flex:1; min-height:0; display:flex; gap:10px; }
  .days{ width:190px; flex:0 0 190px; background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  .days .dh{ padding:9px 11px; font-weight:800; font-size:12.5px; color:var(--dim); border-bottom:1px solid #edf1f4; position:sticky; top:0; background:#fff; }
  .days .d{ padding:8px 11px; border-bottom:1px solid #f1f4f6; cursor:pointer; display:flex; justify-content:space-between; align-items:center; gap:6px; }
  .days .d:hover{ background:#f3f8f6; }
  .days .d.on{ background:#e3f4ef; font-weight:800; color:#0b5246; }
  .days .d small{ color:var(--dim); font-size:11.5px; font-weight:600; white-space:nowrap; }
  .days .d.today b::after{ content:' 오늘'; color:var(--teal); font-size:11px; }
  .main{ flex:1; min-width:0; overflow:auto; background:#fff; border:1px solid var(--bd); border-radius:10px; padding:4px 12px 14px; }
  .empty{ padding:50px 10px; text-align:center; color:var(--dim); line-height:1.8; }
  .grp{ margin-top:12px; }
  .gh{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:7px 4px; border-bottom:2px solid #e3ece9; position:sticky; top:-4px; background:#fff; z-index:2; }
  .gh .dt{ font-weight:800; color:#0b5246; }
  .gh .tt{ font-weight:800; font-size:15px; }
  .gh .tt.none{ color:#9aa6b2; font-weight:600; }
  .gh .meta{ color:var(--dim); font-size:12.5px; }
  .gh .sp{ flex:1; }
  .gh .lk{ border:0; background:none; color:#1d6fb8; cursor:pointer; font-size:12.5px; font-weight:700; padding:2px 5px; font-family:inherit; }
  .gh .lk.del{ color:var(--red); }
  .grid{ display:grid; grid-template-columns:repeat(auto-fill, minmax(150px, 1fr)); gap:8px; padding-top:8px; }
  .ph{ position:relative; border:1px solid #e3e8ed; border-radius:8px; overflow:hidden; background:#f1f3f5; aspect-ratio:1/1; cursor:zoom-in; }
  .ph img{ width:100%; height:100%; object-fit:cover; display:block; }
  .ph .ck{ position:absolute; left:6px; top:6px; width:22px; height:22px; border-radius:6px; background:rgba(255,255,255,.92); border:1.5px solid #9fb0bf; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:14px; color:#fff; }
  .ph.sel{ outline:3px solid var(--teal); outline-offset:-3px; }
  .ph.sel .ck{ background:var(--teal); border-color:var(--teal); }
  .ph .no{ position:absolute; right:6px; bottom:6px; background:rgba(0,0,0,.55); color:#fff; font-size:11px; padding:1px 6px; border-radius:9px; }
  /* 크게 보기 */
  .vw{ position:fixed; inset:0; background:rgba(12,18,24,.92); z-index:9000; display:flex; flex-direction:column; }
  .vw[hidden]{ display:none; }
  .vw .top{ display:flex; align-items:center; gap:8px; padding:10px 14px; color:#e9eef2; }
  .vw .top .cap{ flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-weight:700; }
  .vw .top .btn{ background:rgba(255,255,255,.1); color:#fff; border-color:rgba(255,255,255,.25); }
  .vw .top .btn-red{ color:#ffb4ab; }
  .vw .stage{ flex:1; min-height:0; display:flex; align-items:center; justify-content:center; position:relative; }
  .vw .stage img{ max-width:96%; max-height:100%; object-fit:contain; box-shadow:0 8px 30px rgba(0,0,0,.5); background:#222; }
  .vw .nav{ position:absolute; top:50%; transform:translateY(-50%); width:52px; height:80px; border:0; border-radius:10px; background:rgba(255,255,255,.12); color:#fff; font-size:28px; cursor:pointer; }
  .vw .nav:hover{ background:rgba(255,255,255,.22); }
  .vw .nav.l{ left:14px; } .vw .nav.r{ right:14px; }
  .vw .bot{ padding:8px 14px 12px; color:#aeb9c3; font-size:12px; text-align:center; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🖼 사진함</h2>
  <div class="sub">모바일 앱 <b>📷 사진</b>에서 올린 사진을 <b>날짜별</b>로 모아 봅니다 — 누르면 크게(← → 로 넘김), 체크해서 <b>여러 장 ZIP</b>으로 내려받습니다.
    사진은 <b>1개월 보관</b> 후 자동으로 지워집니다(<span id="cutLab">-</span> 이전) — 남길 사진은 그 전에 내려받으세요.</div>
  <div class="bar">
    <label style="font-weight:700">기간</label>
    <input type="date" id="frDt" data-range-to="toDt"> <span style="color:#8a98a8">~</span> <input type="date" id="toDt">
    <button class="btn btn-teal" id="pbBtn" onclick="pbLoad()">🔍 조회</button>
    <input type="text" id="q" placeholder="묶음 이름 · 올린 사람 거르기" oninput="pbDraw()">
    <button class="btn" id="selAllBtn" onclick="pbSelAll()">☑ 전체 선택</button>
    <button class="btn" id="zipBtn" onclick="pbZip()" disabled>📦 고른 사진 ZIP</button>
    <button class="btn btn-red" id="delBtn" onclick="pbDelSel()" disabled>🗑 고른 사진 지우기</button>
    <span class="cnt" id="cnt">-</span>
  </div>
  <div class="body">
    <div class="days" id="days"><div class="dh">날짜 (보관 기간)</div></div>
    <div class="main" id="main"><div class="empty">불러오는 중…</div></div>
  </div>
</div>
<div class="vw" id="vw" hidden>
  <div class="top"><span class="cap" id="vwCap"></span>
    <button class="btn" onclick="pbVwDl()">⬇ 내려받기</button>
    <button class="btn btn-red" id="vwDel" onclick="pbVwDel()">🗑 지우기</button>
    <button class="btn" onclick="pbVwClose()">✕ 닫기 (Esc)</button></div>
  <div class="stage"><button class="nav l" onclick="pbVwGo(-1)" title="이전 (←)">‹</button><img id="vwImg" alt=""><button class="nav r" onclick="pbVwGo(1)" title="다음 (→)">›</button></div>
  <div class="bot" id="vwBot"></div>
</div>
<iframe name="pbDlFrame" style="display:none"></iframe>
<script>
var CTX='${pageContext.request.contextPath}';
var D=null, SEL={}, VW=-1, FLAT=[], _seq=0;
function esc(s){ return String(s==null?'':s).replace(/[&<>"']/g,function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }
function pad(n){ return (n<10?'0':'')+n; }
function d10(d){ return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); }
function dlab(s){ s=String(s||''); if(s.length!==8) return s; var d=new Date(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8)); return (d.getMonth()+1)+'/'+d.getDate()+' ('+'일월화수목금토'.charAt(d.getDay())+')'; }
function dfull(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function ask(msg, ok, okText){ if(window._confirmBox) _confirmBox({ msg:msg, icon:'🗑', okText:okText||'지우기', okColor:'red', onOk:ok }); else if(confirm(msg.replace(/<[^>]*>/g,''))) ok(); }
function say(msg, icon){ if(window._alertBox) _alertBox(msg, {icon:icon||'ℹ️'}); else alert(msg.replace(/<[^>]*>/g,'')); }
function toast(msg){ if(window._toast) _toast(msg); }
function post(url, body, json){
  return fetch(CTX+url, { method:'POST', credentials:'same-origin', headers:{'Content-Type': json ? 'application/json' : 'application/x-www-form-urlencoded'},
    body: json ? JSON.stringify(body) : Object.keys(body).map(function(k){ return encodeURIComponent(k)+'='+encodeURIComponent(body[k]); }).join('&') })
    .then(function(r){ return r.text().then(function(t){ var v=null; try{ v=JSON.parse(t); }catch(e){} if(!r.ok) throw new Error((v&&v.msg)||t||('HTTP '+r.status)); return v||{}; }); });
}
/* 기본 기간 = 최근 7일 */
(function(){ var t=new Date(), f=new Date(); f.setDate(f.getDate()-6); document.getElementById('frDt').value=d10(f); document.getElementById('toDt').value=d10(t); })();
function pbLoad(){
  var fr=document.getElementById('frDt').value, to=document.getElementById('toDt').value, my=++_seq;
  document.getElementById('pbBtn').disabled=true;
  document.getElementById('main').innerHTML='<div class="empty">불러오는 중…</div>';
  post('/photo/list.do', { frDt:fr.replace(/-/g,''), toDt:to.replace(/-/g,'') })
    .then(function(j){ if(my!==_seq) return; D=j; SEL={}; pbDays(); pbDraw();
      document.getElementById('cutLab').textContent=dfull(j.cutDt); })
    .catch(function(e){ if(my!==_seq) return; document.getElementById('main').innerHTML='<div class="empty">불러오지 못했습니다: '+esc(e.message)+'<br>사진함 표(docs/sql/20261126_photo.sql)가 아직 없으면 먼저 만들어야 합니다.</div>'; })
    .then(function(){ if(my===_seq) document.getElementById('pbBtn').disabled=false; });
}
function pbDays(){
  var el=document.getElementById('days'), fr=(D.frDt||''), to=(D.toDt||''), today=d10(new Date()).replace(/-/g,'');
  var h='<div class="dh">날짜 (보관 기간 '+esc(D.keepMonths||1)+'개월)</div>';
  if(!(D.days||[]).length) h+='<div class="empty" style="padding:24px 8px">올린 사진이 없습니다.</div>';
  (D.days||[]).forEach(function(d){ var on=(fr===d.grpDt && to===d.grpDt);
    h+='<div class="d'+(on?' on':'')+(d.grpDt===today?' today':'')+'" onclick="pbDay(\''+esc(d.grpDt)+'\')"><b>'+esc(dlab(d.grpDt))+'</b><small>'+esc(d.grpCnt)+'묶음 · '+esc(d.photoCnt)+'장</small></div>'; });
  el.innerHTML=h;
}
function pbDay(dt){ var v=dfull(dt); document.getElementById('frDt').value=v; document.getElementById('toDt').value=v; pbLoad(); }
function pbVisible(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase(), byG={};
  (D.photos||[]).forEach(function(p){ (byG[p.grpSeq]=byG[p.grpSeq]||[]).push(p); });
  return (D.groups||[]).filter(function(g){ return !q || (String(g.title)+' '+String(g.regNm)+' '+String(g.regUser)).toLowerCase().indexOf(q)>=0; })
    .map(function(g){ return { g:g, ps:byG[g.grpSeq]||[] }; }).filter(function(x){ return x.ps.length; });
}
function canDel(g){ return D && (D.admin || String(g.regUser)===String(D.me)); }
function pbDraw(){
  if(!D) return;
  var V=pbVisible(), h='', n=0; FLAT=[];
  V.forEach(function(x){ var g=x.g;
    h+='<div class="grp"><div class="gh"><span class="dt">'+esc(dlab(g.grpDt))+'</span>'
      +'<span class="tt'+(g.title?'':' none')+'">'+esc(g.title||'(이름 없음)')+'</span>'
      +'<span class="meta">'+x.ps.length+'장 · '+esc(g.regNm||g.regUser)+' · '+esc(String(g.regDttm||'').slice(11,16))+'</span><span class="sp"></span>'
      +'<button class="lk" onclick="pbSelGrp('+g.grpSeq+')">☑ 이 묶음 선택</button>'
      +'<button class="lk" onclick="pbZipGrp('+g.grpSeq+')">📦 ZIP</button>'
      +(canDel(g)?'<button class="lk" onclick="pbTitle('+g.grpSeq+')">✏ 이름</button><button class="lk del" onclick="pbDelGrp('+g.grpSeq+')">🗑 묶음 지우기</button>':'')
      +'</div><div class="grid">';
    x.ps.forEach(function(p, i){ var k=FLAT.length; FLAT.push({ p:p, g:g, i:i, n:x.ps.length }); n++;
      h+='<div class="ph'+(SEL[p.photoSeq]?' sel':'')+'" data-k="'+k+'" onclick="pbVwOpen('+k+')">'
        +'<img loading="lazy" src="'+CTX+'/photo/img.do?thumb=1&seq='+p.photoSeq+'" alt="">'
        +'<span class="ck" onclick="event.stopPropagation(); pbTog('+p.photoSeq+')">'+(SEL[p.photoSeq]?'✓':'')+'</span>'
        +'<span class="no">'+(i+1)+'</span></div>'; });
    h+='</div></div>'; });
  document.getElementById('main').innerHTML = h || '<div class="empty">이 기간에 올린 사진이 없습니다.<br>모바일 앱의 <b>📷 사진</b>에서 올리면 여기 날짜별로 모입니다.</div>';
  pbCnt(V.length, n);
}
function pbCnt(gN, pN){
  var s=Object.keys(SEL).length;
  if(gN!=null) document.getElementById('cnt').textContent='묶음 '+gN+' · 사진 '+pN+'장'+(s?' · 고른 '+s+'장':'');
  else { var c=document.getElementById('cnt'); c.textContent=c.textContent.replace(/ · 고른 \d+장$/,'')+(s?' · 고른 '+s+'장':''); }
  document.getElementById('zipBtn').disabled=!s; document.getElementById('delBtn').disabled=!s;
  document.getElementById('zipBtn').textContent='📦 고른 사진 ZIP'+(s?' ('+s+')':'');
}
function pbPaintSel(){ document.querySelectorAll('.ph').forEach(function(el){ var f=FLAT[+el.getAttribute('data-k')]; var on=!!(f && SEL[f.p.photoSeq]); el.classList.toggle('sel', on); el.querySelector('.ck').textContent=on?'✓':''; }); pbCnt(); }
function pbTog(seq){ if(SEL[seq]) delete SEL[seq]; else SEL[seq]=1; pbPaintSel(); }
function pbSelGrp(gs){ var ps=FLAT.filter(function(f){ return f.g.grpSeq===gs; }), all=ps.every(function(f){ return SEL[f.p.photoSeq]; });
  ps.forEach(function(f){ if(all) delete SEL[f.p.photoSeq]; else SEL[f.p.photoSeq]=1; }); pbPaintSel(); }
function pbSelAll(){ var all=FLAT.length && FLAT.every(function(f){ return SEL[f.p.photoSeq]; }); SEL={}; if(!all) FLAT.forEach(function(f){ SEL[f.p.photoSeq]=1; }); pbPaintSel(); }
/* ZIP — 숨은 iframe 으로 폼 POST (내려받기라 화면은 그대로) */
function pbZipSeqs(seqs){
  if(!seqs.length) return;
  if(seqs.length>300){ say('한 번에 300장까지 묶을 수 있습니다. 나눠서 내려받아 주세요.','⚠️'); return; }
  var f=document.createElement('form'); f.method='POST'; f.action=CTX+'/photo/zip.do'; f.target='pbDlFrame';
  var i=document.createElement('input'); i.type='hidden'; i.name='seqs'; i.value=seqs.join(','); f.appendChild(i);
  document.body.appendChild(f); f.submit(); f.remove(); toast('📦 '+seqs.length+'장을 ZIP 으로 내려받습니다');
}
function pbZip(){ pbZipSeqs(FLAT.filter(function(f){ return SEL[f.p.photoSeq]; }).map(function(f){ return f.p.photoSeq; })); }
function pbZipGrp(gs){ pbZipSeqs(FLAT.filter(function(f){ return f.g.grpSeq===gs; }).map(function(f){ return f.p.photoSeq; })); }
/* 지우기 — 차례로(한 장씩 서버가 권한을 본다) */
function pbDelSeqs(seqs, done){
  var ok=0, bad=[], i=0;
  (function next(){ if(i>=seqs.length){ done(ok, bad); return; }
    var s=seqs[i++]; post('/photo/del.do', { photoSeq:s }, true).then(function(j){ if(j.ok) ok++; else bad.push(j.msg||'실패'); }).catch(function(e){ bad.push(e.message); }).then(next); })();
}
function pbDelSel(){
  var fs=FLAT.filter(function(f){ return SEL[f.p.photoSeq]; }), mine=fs.filter(function(f){ return canDel(f.g); });
  if(!fs.length) return;
  if(!mine.length){ say('고른 사진은 모두 다른 사람이 올린 것입니다.<br>지우기는 <b>올린 사람이나 관리자</b>만 할 수 있습니다.','⚠️'); return; }
  ask('고른 사진 <b>'+mine.length+'장</b>을 지울까요?'+(mine.length<fs.length?'<br><small>(다른 사람이 올린 '+(fs.length-mine.length)+'장은 빼고)</small>':'')+'<br><small style="color:#c0392b">지우면 되돌릴 수 없습니다.</small>', function(){
    pbDelSeqs(mine.map(function(f){ return f.p.photoSeq; }), function(ok, bad){ toast('🗑 '+ok+'장 지웠습니다'+(bad.length?' · '+bad.length+'장 실패':'')); pbLoad(); });
  });
}
function pbDelGrp(gs){
  var g=(D.groups||[]).filter(function(x){ return x.grpSeq===gs; })[0]; if(!g) return;
  ask('묶음 「<b>'+esc(g.title||dlab(g.grpDt))+'</b>」 사진 <b>'+esc(g.photoCnt)+'장</b>을 모두 지울까요?<br><small style="color:#c0392b">지우면 되돌릴 수 없습니다.</small>', function(){
    post('/photo/del.do', { grpSeq:gs }, true).then(function(j){ if(!j.ok){ say(esc(j.msg||'지우지 못했습니다.'),'❌'); return; } toast('🗑 묶음을 지웠습니다'); pbLoad(); })
      .catch(function(e){ say(esc(e.message),'❌'); });
  });
}
function pbTitle(gs){
  var g=(D.groups||[]).filter(function(x){ return x.grpSeq===gs; })[0]; if(!g) return;
  /* 입력칸은 확인창(ui-message) 본문에 넣는다 — 브라우저 prompt 금지(konet 알림 표준) */
  var go=function(t){ post('/photo/title.do', { grpSeq:gs, title:t }, true).then(function(j){ if(!j.ok){ say(esc(j.msg||'고치지 못했습니다.'),'❌'); return; } g.title=t.trim().slice(0,100); pbDraw(); })
    .catch(function(e){ say(esc(e.message),'❌'); }); };
  if(!window._confirmBox){ var t0=prompt('묶음 이름', g.title||''); if(t0!=null) go(t0); return; }
  _confirmBox({ icon:'✏', okText:'저장', okColor:'blue',
    msg:'<div style="font-weight:800;margin-bottom:8px">묶음 이름</div><input id="pbTitleIn" maxlength="100" value="'+esc(g.title||'')+'" style="width:100%;height:36px;border:1px solid #c9d3dc;border-radius:7px;padding:0 10px;font-size:14px;font-family:inherit">',
    onOk:function(){ var el=document.getElementById('pbTitleIn'); go(el ? el.value : ''); } });
  setTimeout(function(){ var el=document.getElementById('pbTitleIn'); if(el){ el.focus(); el.select(); } }, 60);
}
/* 크게 보기 */
function pbVwOpen(k){ VW=k; pbVwShow(); document.getElementById('vw').hidden=false; }
function pbVwShow(){
  var f=FLAT[VW]; if(!f){ pbVwClose(); return; }
  document.getElementById('vwImg').src=CTX+'/photo/img.do?seq='+f.p.photoSeq;
  document.getElementById('vwCap').textContent=dlab(f.g.grpDt)+'  ·  '+(f.g.title||'(이름 없음)')+'  ·  '+(f.i+1)+' / '+f.n;
  document.getElementById('vwBot').textContent=(f.g.regNm||f.g.regUser)+' 올림 '+String(f.g.regDttm||'').slice(0,16)+(f.p.shotDttm?' · 찍은 때 '+String(f.p.shotDttm).slice(0,16):'')+(f.p.imgW?' · '+f.p.imgW+'×'+f.p.imgH:'')+'  ·  전체 '+(VW+1)+' / '+FLAT.length+'  (← → 넘김 · Esc 닫기)';
  document.getElementById('vwDel').style.display=canDel(f.g)?'':'none';
}
function pbVwGo(d){ if(!FLAT.length) return; VW=(VW+d+FLAT.length)%FLAT.length; pbVwShow(); }
function pbVwClose(){ document.getElementById('vw').hidden=true; VW=-1; document.getElementById('vwImg').removeAttribute('src'); }
function pbVwDl(){ var f=FLAT[VW]; if(!f) return; var a=document.createElement('a'); a.href=CTX+'/photo/img.do?dl=1&seq='+f.p.photoSeq; a.target='pbDlFrame'; document.body.appendChild(a); a.click(); a.remove(); }
function pbVwDel(){ var f=FLAT[VW]; if(!f) return;
  ask('이 사진을 지울까요?<br><small style="color:#c0392b">지우면 되돌릴 수 없습니다.</small>', function(){
    post('/photo/del.do', { photoSeq:f.p.photoSeq }, true).then(function(j){ if(!j.ok){ say(esc(j.msg||'지우지 못했습니다.'),'❌'); return; } pbVwClose(); toast('🗑 지웠습니다'); pbLoad(); })
      .catch(function(e){ say(esc(e.message),'❌'); });
  });
}
document.addEventListener('keydown', function(e){
  if(document.getElementById('vw').hidden) return;
  if(e.key==='ArrowLeft'){ pbVwGo(-1); e.preventDefault(); } else if(e.key==='ArrowRight'){ pbVwGo(1); e.preventDefault(); } else if(e.key==='Escape'){ pbVwClose(); }
});
/* 메뉴로 다시 열 때(셸이 부른다) · 다른 탭에서 돌아올 때 새로 */
window.konetShown=function(){ pbLoad(); };
pbLoad();
</script>
</body>
</html>
