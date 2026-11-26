<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 📷 사진 올리기 — /m/photo.do (MobileController, 로그인 필수). 2026-11-26 신설.
     사용자 「모바일에서 여러 장 찍은 사진을 카톡으로 하나씩 보내 PC 에서 받던 일 — 한꺼번에 PC 에서 보게」 → 「날짜별 모음 · 줄인 사진만」 · 「보관 1개월로」.
     · 사진첩에서 «여러 장 한 번에» 고르거나 카메라로 몇 장이고 찍어 담은 뒤 [올리기] — 한 번 올리기 = 묶음 하나(오늘 날짜 + 한 줄 이름).
     · ★폰에서 줄여서 보낸다 — 긴 변 1600px JPEG(품질 0.82, 크면 더 줄임) + 목록용 작은 그림 360px. 원본은 안 보낸다(장당 4~8MB → 0.2~0.5MB).
     · ★한 장씩 보낸다(/photo/upload.do) — 운영 nginx 본문 한도(1MB)를 넘지 않게 · 중간에 끊겨도 올라간 것은 남고 실패한 것만 다시.
     · PC 웹 「정보 현황 ▸ 사진함」에서 날짜별로 모아 보고 ZIP 으로 내려받는다. 서버 = PhotoController(두 앱 같은 파일) · 표 = konet_vsweb/docs/sql/20261126_photo.sql --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 사진 올리기</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/m/m.css?v=20261126a">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<script src="<%=request.getContextPath()%>/m/m.js?v=20261126a"></script>
<style>
  .pbtns{ display:flex; gap:8px; margin-top:10px; }
  .pbtns label{ flex:1; display:flex; align-items:center; justify-content:center; gap:6px; height:54px; border-radius:12px; font-size:17px; font-weight:800; cursor:pointer; user-select:none; }
  .pbtns .cam{ background:var(--teal); color:#fff; }
  .pbtns .gal{ background:#fff; color:var(--teal-d); border:2px solid var(--teal); }
  .pbtns input{ display:none; }
  .ttl{ width:100%; height:46px; border:1px solid var(--bd); border-radius:10px; padding:0 12px; font:inherit; font-size:16.5px; }
  .qgrid{ display:grid; grid-template-columns:repeat(4, 1fr); gap:6px; margin-top:12px; }
  .qgrid .q{ position:relative; aspect-ratio:1/1; border-radius:8px; overflow:hidden; background:#eef2f4; }
  .qgrid .q img{ width:100%; height:100%; object-fit:cover; display:block; }
  .qgrid .q .x{ position:absolute; right:3px; top:3px; width:26px; height:26px; border:0; border-radius:13px; background:rgba(0,0,0,.6); color:#fff; font-size:15px; line-height:26px; padding:0; }
  .qgrid .q.ok::after{ content:'✓'; position:absolute; inset:0; display:flex; align-items:center; justify-content:center; background:rgba(19,122,108,.55); color:#fff; font-size:30px; font-weight:900; }
  .qgrid .q.bad{ outline:3px solid var(--red); outline-offset:-3px; }
  .qgrid .q.run::after{ content:'⏳'; position:absolute; inset:0; display:flex; align-items:center; justify-content:center; background:rgba(255,255,255,.55); font-size:26px; }
  .up{ width:100%; height:56px; margin-top:12px; border:0; border-radius:12px; background:#1f6fb8; color:#fff; font:inherit; font-size:18px; font-weight:800; }
  .up:disabled{ background:#aab6c2; }
  .pg{ height:10px; background:#e6ecef; border-radius:6px; overflow:hidden; margin-top:10px; } .pg i{ display:block; height:100%; width:0; background:linear-gradient(90deg,#0f6b5f,#3fbfae); transition:width .25s; }
  .pgl{ margin-top:6px; font-size:15px; color:var(--mute); text-align:center; }
  .rg{ padding:10px 0; border-top:1px solid #eef1f3; } .rg:first-child{ border-top:0; }
  .rg .h{ display:flex; justify-content:space-between; gap:8px; font-size:15.5px; } .rg .h b{ color:var(--teal-d); } .rg .h small{ color:var(--mute); white-space:nowrap; }
  .rg .th{ display:flex; gap:5px; overflow-x:auto; margin-top:7px; scrollbar-width:none; } .rg .th::-webkit-scrollbar{ display:none; }
  .rg .th img{ flex:0 0 64px; width:64px; height:64px; object-fit:cover; border-radius:6px; background:#eef2f4; }
  .big{ position:fixed; inset:0; z-index:60; background:rgba(0,0,0,.92); display:flex; align-items:center; justify-content:center; }
  .big[hidden]{ display:none; } .big img{ max-width:100%; max-height:100%; object-fit:contain; }
</style>
</head>
<body data-page="photo">
<header>
  <div class="hd1">
    <h1>사진 올리기</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="M.logout()">로그아웃</button>
  </div>
</header>

<main>
  <section class="card">
    <h2>📷 사진 담기 <small id="qLbl">담은 사진 0장</small></h2>
    <input class="ttl" id="ttl" maxlength="100" placeholder="묶음 이름 (예: 선피앤피 입고 검수) — 비워도 됩니다">
    <div class="pbtns">
      <label class="cam">📷 찍기<input type="file" id="fCam" accept="image/*" capture="environment"></label>
      <label class="gal">🖼 사진첩에서 고르기<input type="file" id="fGal" accept="image/*" multiple></label>
    </div>
    <div class="qgrid" id="qgrid"></div>
    <button type="button" class="up" id="upBtn" onclick="upload()" disabled>⬆ 올리기</button>
    <div id="pgBox" hidden><div class="pg"><i id="pgBar"></i></div><div class="pgl" id="pgLbl"></div></div>
  </section>
  <section class="card">
    <h2>🕘 최근 올린 사진 <small>최근 7일</small></h2>
    <div id="recent"><div class="loading">불러오는 중…</div></div>
  </section>
  <p class="note">찍기를 여러 번 누르면 계속 담깁니다. 사진은 폰에서 줄여서(장당 약 0.3MB) 올라갑니다.<br>
    PC 웹 「정보 현황 ▸ 사진함」에서 날짜별로 모아 보고 여러 장을 ZIP 으로 내려받습니다. <b>1개월 보관</b> 뒤 자동으로 지워집니다.</p>
</main>
<div class="big" id="big" hidden onclick="this.hidden=true; this.querySelector('img').removeAttribute('src')"><img alt=""></div>

<script>
var $=M.$, esc=M.esc, CTX=M.CTX;
var Q=[], _grp=0, _busy=false;   // Q = [{file, url, st:''|'run'|'ok'|'bad', msg}]
function pad(x){ return (x<10?'0':'')+x; }
function dttm(ms){ if(!ms) return ''; var d=new Date(ms); return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate())+' '+pad(d.getHours())+':'+pad(d.getMinutes())+':'+pad(d.getSeconds()); }

function addFiles(list){
  Array.prototype.forEach.call(list||[], function(f){
    if(!/^image\//.test(f.type||'') && !/\.(jpe?g|png|heic|heif|webp)$/i.test(f.name||'')) return;
    Q.push({ file:f, url:URL.createObjectURL(f), st:'' });
  });
  draw();
}
$('fCam').onchange=function(){ addFiles(this.files); this.value=''; };
$('fGal').onchange=function(){ addFiles(this.files); this.value=''; };
function draw(){
  var left=Q.filter(function(q){ return q.st!=='ok'; }).length;
  $('qLbl').textContent='담은 사진 '+Q.length+'장'+(Q.length&&left<Q.length?' · 올림 '+(Q.length-left):'');
  $('qgrid').innerHTML=Q.map(function(q,i){
    return '<div class="q '+q.st+'"><img src="'+q.url+'" alt="">'+(q.st==='ok'||_busy?'':'<button type="button" class="x" onclick="rm('+i+')">✕</button>')+'</div>'; }).join('');
  $('upBtn').disabled=_busy || !left;
  $('upBtn').textContent=_busy ? '올리는 중…' : ('⬆ 올리기'+(left?' ('+left+'장)':''));
}
function rm(i){ if(_busy) return; var q=Q[i]; if(q) URL.revokeObjectURL(q.url); Q.splice(i,1); draw(); }

/* 줄이기 — 긴 변 max px · JPEG. 결과 base64 가 너무 크면(850KB↑) 품질·크기를 낮춰 다시 */
function loadImg(file){
  return new Promise(function(res, rej){ var u=URL.createObjectURL(file), im=new Image();
    im.onload=function(){ res({ im:im, u:u }); }; im.onerror=function(){ URL.revokeObjectURL(u); rej(new Error('이 사진 형식을 읽지 못했습니다')); }; im.src=u; });
}
function shrink(im, max, q){
  var w=im.naturalWidth, h=im.naturalHeight, r=Math.min(1, max/Math.max(w,h)), cw=Math.max(1,Math.round(w*r)), ch=Math.max(1,Math.round(h*r));
  var c=document.createElement('canvas'); c.width=cw; c.height=ch;
  var g=c.getContext('2d'); g.fillStyle='#fff'; g.fillRect(0,0,cw,ch); g.drawImage(im,0,0,cw,ch);
  return { data:c.toDataURL('image/jpeg', q), w:cw, h:ch };
}
function prep(file){
  return loadImg(file).then(function(o){
    var t=[[1600,0.82],[1600,0.7],[1280,0.7],[1024,0.65]], big=null;
    for(var i=0;i<t.length;i++){ big=shrink(o.im, t[i][0], t[i][1]); if(big.data.length<850000) break;   /* 본문 1MB(운영 nginx 기본 한도) 안에 그림+작은 그림이 들어가게 */ }
    var th=shrink(o.im, 360, 0.7);
    URL.revokeObjectURL(o.u);
    return { img:big.data, w:big.w, h:big.h, thumb:th.data };
  });
}

function prog(done, tot, msg){ $('pgBox').hidden=false; $('pgBar').style.width=(tot?Math.round(done*100/tot):0)+'%'; $('pgLbl').textContent=msg; }
function upload(){
  if(_busy) return;
  var todo=Q.map(function(q,i){ return i; }).filter(function(i){ return Q[i].st!=='ok'; });
  if(!todo.length) return;
  _busy=true; draw();
  window.onbeforeunload=function(){ return '사진을 올리는 중입니다.'; };
  var ok=0, bad=0, k=0, tot=todo.length;
  var start = _grp ? Promise.resolve(_grp)
    : M.json('/photo/grpNew.do', { title:$('ttl').value.trim() }).then(function(j){ if(!j || !j.ok) throw new Error((j&&j.msg)||'묶음을 만들지 못했습니다'); _grp=j.grpSeq; return _grp; });
  start.then(function(){
    return new Promise(function(done){
      (function next(){
        if(k>=todo.length){ done(); return; }
        var i=todo[k++], q=Q[i]; q.st='run'; draw(); prog(k-1, tot, (k)+' / '+tot+' 장 올리는 중…');
        prep(q.file).then(function(p){
          return M.json('/photo/upload.do', { grpSeq:_grp, sortNo:i, fileNm:q.file.name||'', shotDttm:dttm(q.file.lastModified), w:p.w, h:p.h, img:p.img, thumb:p.thumb });
        }).then(function(j){ if(j && j.ok){ q.st='ok'; ok++; } else { q.st='bad'; q.msg=(j&&j.msg)||'실패'; bad++; } })
          .catch(function(e){ q.st='bad'; q.msg=M.errMsg(e); bad++; })
          .then(function(){ draw(); prog(k, tot, k+' / '+tot+' 장'); next(); });
      })();
    });
  }).then(function(){
    _busy=false; window.onbeforeunload=null; draw();
    if(!bad){
      prog(tot, tot, '✅ '+ok+'장 올렸습니다');
      _toast('✅ 사진 <b>'+ok+'</b>장을 올렸습니다 — PC 「사진함」에서 볼 수 있습니다', 'success');
      Q.forEach(function(q){ URL.revokeObjectURL(q.url); }); Q=[]; _grp=0; $('ttl').value=''; draw();
      setTimeout(function(){ $('pgBox').hidden=true; }, 2500);
    } else {
      var why=Q.filter(function(q){ return q.st==='bad'; }).map(function(q){ return q.msg; })[0]||'';
      prog(tot, tot, ok+'장 올림 · '+bad+'장 실패');
      _alertBox('<b>'+ok+'</b>장 올렸고 <b style="color:#c0392b">'+bad+'</b>장은 못 올렸습니다.<br><small>'+esc(why)+'</small><br>빨간 테두리 사진만 [올리기]를 다시 누르면 같은 묶음에 이어 올립니다.', {icon:'⚠️'});
    }
    loadRecent();
  }).catch(function(e){
    _busy=false; window.onbeforeunload=null; Q.forEach(function(q){ if(q.st==='run') q.st=''; }); draw();
    $('pgBox').hidden=true;
    _alertBox('올리지 못했습니다.<br><small>'+esc(M.errMsg(e))+'</small>', {icon:'❌', okColor:'red'});
  });
}

function loadRecent(){
  var to=M.ymd(), fr=M.addDay(to,-6);
  M.form('/photo/list.do', { frDt:fr.replace(/-/g,''), toDt:to.replace(/-/g,'') }).then(function(j){
    var byG={}; (j.photos||[]).forEach(function(p){ (byG[p.grpSeq]=byG[p.grpSeq]||[]).push(p); });
    var gs=(j.groups||[]).slice(0,30);
    $('recent').innerHTML = gs.length ? gs.map(function(g){
      var ps=byG[g.grpSeq]||[];
      return '<div class="rg"><div class="h"><span><b>'+esc(M.lblDay(g.grpDt))+'</b> '+esc(g.title||'(이름 없음)')+'</span><small>'+ps.length+'장 · '+esc(g.regNm||g.regUser)+'</small></div>'
        +'<div class="th">'+ps.slice(0,20).map(function(p){ return '<img loading="lazy" src="'+CTX+'/photo/img.do?thumb=1&seq='+p.photoSeq+'" data-seq="'+p.photoSeq+'" alt="">'; }).join('')+'</div></div>';
    }).join('') : '<div class="empty">최근 7일 동안 올린 사진이 없습니다.</div>';
  }).catch(function(e){ $('recent').innerHTML='<div class="empty">불러오지 못했습니다 — '+esc(M.errMsg(e))+'</div>'; });
}
$('recent').addEventListener('click', function(e){ var im=e.target.closest('img[data-seq]'); if(!im) return;
  var b=$('big'); b.querySelector('img').src=CTX+'/photo/img.do?seq='+im.getAttribute('data-seq'); b.hidden=false; });

M.tabbar('photo');
M.session().then(function(){ draw(); loadRecent(); }).catch(function(){});
</script>
</body>
</html>
