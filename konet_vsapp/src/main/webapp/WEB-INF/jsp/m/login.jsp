<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 로그인 — /m/login.do (MobileController). 로그인 처리는 PC 와 같은 /user/loginChk.do. --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 로그인</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<style>
  :root{ --teal:#137a6c; --teal-d:#0e6657; --bd:#d5e0dd; --ink:#1f2a37; --mute:#6b7785; --bg:#f4f7f6; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; background:var(--bg); color:var(--ink);
    font-family:"Pretendard Variable",Pretendard,"Malgun Gothic",sans-serif; -webkit-text-size-adjust:100%; }
  /* 뒤배경 — 옅은 청록 번짐 두 곳(오른쪽 위·왼쪽 아래) + 잔 점무늬. 이미지 없이 CSS 만 */
  body{ min-height:100vh; min-height:100dvh;
    background:
      radial-gradient(rgba(19,122,108,.07) 1px, transparent 1.6px) 0 0/18px 18px,
      radial-gradient(460px 460px at 108% -8%, rgba(19,122,108,.24), transparent 70%),
      radial-gradient(420px 420px at -12% 108%, rgba(19,122,108,.18), transparent 70%),
      linear-gradient(180deg,#f4f7f6 0%,#e6efec 100%); }
  .wrap{ min-height:100vh; min-height:100dvh; display:flex; flex-direction:column; justify-content:center;
    padding:24px 20px calc(24px + env(safe-area-inset-bottom)); max-width:440px; margin:0 auto; }
  .brand{ display:flex; align-items:center; gap:12px; margin-bottom:28px; }
  .brand img{ width:52px; height:52px; border-radius:13px; }
  .brand h1{ margin:0; font-size:28px; color:var(--teal-d); }
  .brand p{ margin:2px 0 0; font-size:16px; color:var(--mute); }
  label{ display:block; font-size:16px; font-weight:600; color:var(--mute); margin:14px 0 6px; }
  input[type=text],input[type=password]{ width:100%; height:50px; border:1px solid var(--bd); border-radius:10px;
    padding:0 14px; font-size:19px; font-family:inherit; background:#fff; color:var(--ink); }
  input:focus{ outline:none; border-color:var(--teal); box-shadow:0 0 0 3px rgba(19,122,108,.18); }
  .save{ display:flex; align-items:center; gap:8px; margin:14px 0 0; font-size:17px; color:var(--ink); }
  .save input{ width:20px; height:20px; accent-color:var(--teal); }
  button{ width:100%; height:52px; margin-top:22px; border:0; border-radius:10px; background:var(--teal);
    color:#fff; font-size:20px; font-weight:700; font-family:inherit; }
  button:disabled{ opacity:.6; }
</style>
</head>
<body>
<div class="wrap">
  <div class="brand">
    <img src="<%=request.getContextPath()%>/m/icons/icon-192.png" alt="">
    <div><h1>코네트</h1><p>물류·매출 (모바일)</p></div>
  </div>
  <form id="f" autocomplete="on" onsubmit="mLogin(); return false;">
    <label for="compCd">회사코드</label>
    <input type="text" id="compCd" autocomplete="organization" autocapitalize="characters">
    <label for="userId">아이디</label>
    <input type="text" id="userId" autocomplete="username" autocapitalize="off">
    <label for="passWd">비밀번호</label>
    <input type="password" id="passWd" autocomplete="current-password">
    <div class="save"><input type="checkbox" id="saveId"><label for="saveId" style="margin:0;font-weight:500;color:var(--ink)">회사코드·아이디 저장</label></div>
    <button type="submit" id="btn">로그인</button>
  </form>
</div>
<script>
var CTX = '<%=request.getContextPath()%>';
if (typeof window._alertBox !== 'function') { window._alertBox = function(m){ alert(String(m).replace(/<[^>]*>/g,'')); }; }
var K_COMP='konetM.compCd', K_ID='konetM.userId';
/* 커서 = «비어 있는 첫 칸» — 회사코드·아이디가 차 있으면 비밀번호로 간다.
   저장값(localStorage)만 보던 것을 칸의 실제 값·브라우저 자동완성까지 보게 했다(2026-09-12 「회사코드 아이디가 있으면 비밀번호로」). */
var _mFocusDone=false;
function mFilled(el){
  if(el.value) return true;
  try{ if(el.matches(':autofill')) return true; }catch(e){}
  try{ if(el.matches(':-webkit-autofill')) return true; }catch(e){}
  return false;
}
function mFocusFirst(){
  if(_mFocusDone) return;
  var ids=['compCd','userId','passWd'], el=null;
  for(var i=0;i<ids.length;i++){ var x=document.getElementById(ids[i]); if(!mFilled(x)){ el=x; break; } }
  el=el||document.getElementById('passWd');   // 셋 다 차 있으면(자동완성) 비밀번호 — 그대로 Enter 면 로그인
  if(document.activeElement!==el){ try{ el.focus({preventScroll:true}); }catch(e){ el.focus(); } }
}
(function(){
  try{
    var c=localStorage.getItem(K_COMP), u=localStorage.getItem(K_ID);
    if(c){ document.getElementById('compCd').value=c; }
    if(u){ document.getElementById('userId').value=u; document.getElementById('saveId').checked=true; }
  }catch(e){}
  mFocusFirst();
  /* 브라우저 자동완성은 화면을 그린 «뒤에» 칸을 채우고, 뒤로가기(bfcache)로 돌아오면 이 스크립트가 다시 돌지 않는다 → 몇 번 더 맞춘다.
     단 사람이 한 번이라도 누르거나 치면 그 뒤로는 커서를 옮기지 않는다(치는 도중에 칸이 바뀌면 안 된다). */
  ['pointerdown','touchstart','keydown'].forEach(function(t){ document.addEventListener(t,function(){ _mFocusDone=true; },true); });
  window.addEventListener('load',function(){ mFocusFirst(); setTimeout(mFocusFirst,300); setTimeout(mFocusFirst,900); });
  window.addEventListener('pageshow',function(e){ if(e.persisted){ _mFocusDone=false; mFocusFirst(); } });
  window.addEventListener('focus',mFocusFirst);
})();
function mLogin(){
  var comp=document.getElementById('compCd').value.trim(),
      id=document.getElementById('userId').value.trim(),
      pw=document.getElementById('passWd').value;
  if(!comp){ _alertBox('회사코드를 입력하세요.',{icon:'⚠️'}); return; }
  if(!id){ _alertBox('아이디를 입력하세요.',{icon:'⚠️'}); return; }
  if(!pw){ _alertBox('비밀번호를 입력하세요.',{icon:'⚠️'}); return; }
  var btn=document.getElementById('btn'); btn.disabled=true; btn.textContent='확인 중…';
  fetch(CTX+'/user/loginChk.do',{ method:'POST', credentials:'same-origin',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'compCd='+encodeURIComponent(comp)+'&userId='+encodeURIComponent(id)+'&passWd='+encodeURIComponent(pw) })
  .then(function(r){ return r.json(); })
  .then(function(d){
    if(d.error_code!=='00000'){ throw new Error(d.error_mess||'로그인 실패'); }
    try{
      if(document.getElementById('saveId').checked){ localStorage.setItem(K_COMP,comp); localStorage.setItem(K_ID,id); }
      else { localStorage.removeItem(K_COMP); localStorage.removeItem(K_ID); }
    }catch(e){}
    /* 판매·수금·재고 주소에서 로그인 화면이 떴으면(서버가 넘기지 않고 그 자리에서 보여 준다) 그 화면으로 되돌아간다 */
    var here=location.pathname.replace(/^.*\/m\//,'');
    location.replace(/^(sales|settle|stock)\.do$/.test(here) ? location.pathname+location.search : CTX+'/m/index.do');
  })
  .catch(function(e){
    btn.disabled=false; btn.textContent='로그인';
    _alertBox(e.message||'로그인 요청 중 오류가 발생했습니다.',{icon:'❌',okColor:'red'});
  });
}
if('serviceWorker' in navigator){ navigator.serviceWorker.register(CTX+'/m/sw.js',{scope:CTX+'/m/'}).catch(function(){}); }
</script>
</body>
</html>
