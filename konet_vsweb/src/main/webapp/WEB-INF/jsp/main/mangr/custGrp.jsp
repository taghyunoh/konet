<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>거래처 통합(수금 묶음)</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<%--
  거래처 통합(수금 묶음) — 2026-11-05 신설. 사용자 「판매등록은 우리푸드·샐러드 플러스 따로, 입금은 통합으로 들어옴.
      우리푸드로 통합하고 우측(수금등록 미수 현황)도 통합해서 보여 주고 아래에 지금처럼 분리 내용, 기준정보 설정으로」
    · 저장 = 회사 설정(TBL_COMP_SET.SET_JSON) 키 'custGrp' = { groups:[ { mainCd, mainNm, members:[ {cd, nm}, … ] }, … ] }
      → /user/compSetPatch.do(key custGrp). 다른 화면은 comp-set.js 의 konetSet._raw.custGrp 로 읽는다(셸이 화면을 다시 보여 줄 때 다시 읽음).
    · 쓰는 곳 = 수금등록(rcvReg.jsp) : 미수 현황에 대표 거래처 줄(통합 합계) + 그 밑에 소속 거래처 줄(분리), 현잔고·잔고 수금·전표 목록도 통합.
      판매·매출장·채권채무 등 다른 화면은 종전대로 거래처마다 따로(바꾸지 않았다).
    · 규칙 : 한 거래처는 한 묶음에만 · 대표는 소속에 못 들어감 · 대표만 있고 소속이 없는 묶음은 저장 때 뺀다 · 매출 거래처만(거래유형에 「매출」 또는 빈 값)
    · 2026-11-05 「조금 복잡함, 간결하게 · 설명도 간결하게」 — 검색칸 + 콤보 두 줄이던 것을 글자를 치면 바로 목록이 뜨는 입력칸 하나로, 설명은 한 줄.
--%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --gray:#5a6b7a; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; background:#fff; }
  .wrap{ padding:14px 14px 18px; max-width:860px; }
  .head{ display:flex; align-items:baseline; gap:10px; flex-wrap:wrap; margin-bottom:2px; }
  .head h2{ margin:0; font-size:19px; font-weight:800; }
  .desc{ font-size:12.5px; color:var(--gray); }
  .bar{ display:flex; align-items:center; gap:6px; margin:10px 0; }
  .btn{ height:32px; padding:0 12px; border:1px solid var(--bd); border-radius:7px; background:#fff; font-size:13px; font-weight:700; cursor:pointer; color:#2a3b4c; }
  .btn:hover{ border-color:var(--teal); color:var(--teal); }
  .btn.teal{ background:var(--teal); border-color:var(--teal); color:#fff; } .btn.teal:hover{ background:#0f6457; color:#fff; }
  .grp{ border:1px solid var(--bd); border-radius:10px; padding:10px 12px; margin-bottom:8px; background:#fff; }
  .row{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin:3px 0; }
  .row label{ flex:0 0 74px; font-size:13px; font-weight:700; color:#3d4d5c; }
  .pick{ position:relative; }
  .pick input{ height:32px; width:260px; border:1px solid var(--bd); border-radius:7px; padding:0 9px; font-size:13.5px; font-family:inherit; }
  .pick input:focus{ outline:none; border-color:var(--teal); }
  .pick input.main{ font-weight:800; color:#8a4c0d; background:#fff8e6; }
  .dd{ position:absolute; left:0; top:34px; z-index:5; min-width:260px; max-height:240px; overflow:auto; background:#fff; border:1px solid var(--bd); border-radius:8px; box-shadow:0 6px 18px rgba(0,0,0,.12); display:none; }
  .dd div{ padding:6px 10px; font-size:13px; cursor:pointer; white-space:nowrap; } .dd div:hover, .dd div.on{ background:#e6f4f1; }
  .dd div small{ color:var(--gray); margin-left:6px; } .dd div.no{ color:var(--gray); cursor:default; } .dd div.no:hover{ background:none; }
  .chip{ display:inline-flex; align-items:center; gap:6px; padding:4px 8px 4px 10px; border-radius:14px; background:#e6f4f1; color:#0f6457; font-size:13px; font-weight:700; }
  .chip small{ font-weight:400; color:var(--gray); } .chip b{ cursor:pointer; color:var(--red); }
  .x{ margin-left:auto; height:26px; padding:0 8px; border:1px solid var(--bd); border-radius:6px; background:#fff; font-size:12px; cursor:pointer; color:var(--red); }
  .hint{ font-size:12px; color:var(--gray); }
  .empty{ padding:22px; text-align:center; color:var(--gray); border:1px dashed var(--bd); border-radius:10px; }
</style>
</head>
<body>
<div class="wrap">
  <div class="head"><h2>🔗 거래처 통합(수금 묶음)</h2><span class="desc">입금이 한 회사로 같이 들어오는 거래처를 대표 아래에 묶습니다. 수금등록에서 통합으로 보입니다.</span></div>
  <div class="bar">
    <button class="btn" onclick="addGrp()">＋ 묶음 추가</button>
    <button class="btn teal" onclick="save()">💾 저장</button>
    <span class="hint" id="info"></span>
  </div>
  <div id="list"></div>
  <div class="hint">이름이나 코드를 치면 목록이 뜨고, 누르면 들어갑니다.</div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _ven=[], _groups=[];
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){
  return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{ 'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded' }, body: json?JSON.stringify(body):(body||'') })
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t||('HTTP '+r.status)); try{ return JSON.parse(t); }catch(e){ return t; } }); });
}
function swErr(m){ if(window._alertBox) _alertBox(m,{icon:'❌', okColor:'red'}); else alert(m); }
function toast(m){ if(window._toast) _toast(m,'ok'); }
function venNm(cd){ var o=_ven.filter(function(v){ return String(v.vendorCd)===String(cd); })[0]; return o?o.vendorNm:cd; }
function venSale(o){ var g=String(o.vendorGb||''); return !g || g.indexOf('매출')>=0; }   /* 매출 거래처만 — 수금등록의 거래처 고르기와 같은 기준 */
function usedCds(exceptGi){ var u={}; _groups.forEach(function(g,i){ if(i===exceptGi) return; if(g.mainCd) u[g.mainCd]=1; (g.members||[]).forEach(function(m){ u[m.cd]=1; }); }); return u; }
function load(){
  Promise.all([ post('/vendor/selectVendorMst.do',''), post('/user/compSetGet.do','') ]).then(function(r){
    window._venAllRaw=(r[0]&&r[0].data)||[];
    _ven=window._venAllRaw.filter(venSale).sort(function(a,b){ return String(a.vendorNm).localeCompare(String(b.vendorNm),'ko'); });
    var raw={}; try{ raw=(r[1]&&r[1].setJson)?JSON.parse(r[1].setJson):{}; }catch(e){ raw={}; }
    _groups=((raw.custGrp&&raw.custGrp.groups)||[]).map(function(g){ return { mainCd:String(g.mainCd||''), members:(g.members||[]).map(function(m){ return { cd:String(m.cd||m), nm:m.nm||venNm(m.cd||m) }; }) }; });
    render();
  }).catch(function(e){ swErr('읽지 못했습니다 — '+e.message); });
}
function render(){
  var box=document.getElementById('list');
  if(!_groups.length){ box.innerHTML='<div class="empty">묶음이 없습니다 — [＋ 묶음 추가] 를 누르세요.</div>'; document.getElementById('info').textContent=''; return; }
  box.innerHTML=_groups.map(function(g,i){
    return '<div class="grp">'
      +'<div class="row"><label>대표 거래처</label><span class="pick"><input type="text" class="main" id="mainIn'+i+'" value="'+esc(g.mainCd?venNm(g.mainCd)+' '+g.mainCd:'')+'" placeholder="이름/코드 입력" autocomplete="off" oninput="dd('+i+',\'main\',this.value)" onfocus="dd('+i+',\'main\',\'\')" onblur="ddHide(this)"><div class="dd" id="ddMain'+i+'"></div></span>'
      +'<button class="x" onclick="delGrp('+i+')">✕ 묶음 삭제</button></div>'
      +'<div class="row"><label>소속 거래처</label><span class="pick"><input type="text" id="memIn'+i+'" placeholder="이름/코드 입력 → 목록에서 선택" autocomplete="off" oninput="dd('+i+',\'mem\',this.value)" onfocus="dd('+i+',\'mem\',this.value)" onblur="ddHide(this)" onkeydown="ddKey(event,'+i+')"><div class="dd" id="ddMem'+i+'"></div></span>'
      +g.members.map(function(m,j){ return '<span class="chip">└ '+esc(m.nm||venNm(m.cd))+' <small>'+esc(m.cd)+'</small> <b onclick="delMem('+i+','+j+')" title="빼기">✕</b></span>'; }).join('')
      +'</div></div>'; }).join('');
  document.getElementById('info').textContent=_groups.length+'묶음 · 소속 '+_groups.reduce(function(a,g){ return a+g.members.length; },0)+'곳';
}
/* 입력칸 밑 목록 — 글자가 든 거래처(이름·코드) 최대 20곳. kind main = 대표 고르기, mem = 소속 넣기 */
function hit(v, q){ q=String(q||'').toLowerCase().replace(/\s+/g,''); if(!q) return true; return String(v.vendorNm||'').toLowerCase().replace(/\s+/g,'').indexOf(q)>=0 || String(v.vendorCd||'').toLowerCase().indexOf(q)>=0; }
function dd(i, kind, q){
  var g=_groups[i], used=usedCds(i), box=document.getElementById(kind==='main'?'ddMain'+i:'ddMem'+i);
  var l=_ven.filter(function(v){ if(!hit(v,q)) return false;
    if(kind==='main') return !used[v.vendorCd] || v.vendorCd===g.mainCd;
    return v.vendorCd!==g.mainCd && !used[v.vendorCd] && !g.members.some(function(m){ return m.cd===v.vendorCd; }); });
  var h=l.slice(0,20).map(function(v,k){ return '<div'+(k===0?' class="on"':'')+' data-cd="'+esc(v.vendorCd)+'" onmousedown="pick('+i+',\''+kind+'\',\''+esc(v.vendorCd)+'\')">'+esc(v.vendorNm)+'<small>'+esc(v.vendorCd)+'</small></div>'; }).join('');
  if(!l.length){ h='<div class="no">'+esc(why(i, q))+'</div>'; }
  else if(l.length>20) h+='<div class="no">… '+(l.length-20)+'곳 더 — 글자를 더 치세요</div>';
  box.innerHTML=h; box.style.display='block';   /* CSS 기본이 none 이라 빈 값으로 두면 안 보인다 */
}
function why(i, q){ var g=_groups[i], used=usedCds(i), v=_ven.filter(function(x){ return hit(x,q); })[0];
  if(v){ if(g.members.some(function(m){ return m.cd===v.vendorCd; })) return v.vendorNm+' — 이미 이 묶음의 소속';
         if(v.vendorCd===g.mainCd) return v.vendorNm+' — 이 묶음의 대표';
         if(used[v.vendorCd]) return v.vendorNm+' — 다른 묶음에 있음'; }
  if((window._venAllRaw||[]).some(function(x){ return hit(x,q) && !venSale(x); })) return '매입 전용 거래처 — 매출 거래처만 넣을 수 있음';
  return '맞는 거래처 없음'; }
function ddHide(inp){ var box=inp.parentNode.querySelector('.dd'); setTimeout(function(){ box.style.display='none'; if(inp.classList.contains('main')){ var i=+inp.id.replace('mainIn',''), g=_groups[i]; if(g) inp.value=g.mainCd?venNm(g.mainCd)+' '+g.mainCd:''; } }, 150); }
function ddKey(e, i){ var box=document.getElementById('ddMem'+i); if(e.key==='Enter'){ var on=box.querySelector('div.on[data-cd]'); if(on){ pick(i,'mem',on.getAttribute('data-cd')); } e.preventDefault(); }
  else if(e.key==='ArrowDown'||e.key==='ArrowUp'){ var l=Array.prototype.slice.call(box.querySelectorAll('div[data-cd]')), k=l.findIndex(function(d){ return d.classList.contains('on'); }); if(!l.length) return; l.forEach(function(d){ d.classList.remove('on'); }); k=(k+(e.key==='ArrowDown'?1:-1)+l.length)%l.length; l[k].classList.add('on'); l[k].scrollIntoView({ block:'nearest' }); e.preventDefault(); } }
function pick(i, kind, cd){
  if(kind==='main'){ _groups[i].mainCd=cd; _groups[i].members=_groups[i].members.filter(function(m){ return m.cd!==cd; }); render(); }
  else { _groups[i].members.push({ cd:cd, nm:venNm(cd) }); render(); var inp=document.getElementById('memIn'+i); if(inp) inp.focus(); }
}
function addGrp(){ _groups.push({ mainCd:'', members:[] }); render(); var inp=document.getElementById('mainIn'+(_groups.length-1)); if(inp) inp.focus(); }
function delGrp(i){ var g=_groups[i]; var go=function(){ _groups.splice(i,1); render(); };
  if(window._confirmBox) _confirmBox({ msg:'<b>'+esc(g.mainCd?venNm(g.mainCd):'(대표 없음)')+'</b> 묶음을 뺄까요?<br><small>저장을 눌러야 반영됩니다.</small>', icon:'🗑', okText:'빼기', okColor:'red', onOk:go }); else if(confirm('뺄까요?')) go(); }
function delMem(i,j){ _groups[i].members.splice(j,1); render(); }
function save(){
  var out=[], seen={};
  for(var i=0;i<_groups.length;i++){ var g=_groups[i];
    if(!g.mainCd){ if(g.members.length){ swErr((i+1)+'번째 묶음에 대표 거래처가 없습니다.'); return; } continue; }
    if(!g.members.length) continue;   /* 소속이 없는 묶음은 뺀다 */
    var cds=[g.mainCd].concat(g.members.map(function(m){ return m.cd; }));
    for(var k=0;k<cds.length;k++){ if(seen[cds[k]]){ swErr(venNm(cds[k])+' 은(는) 두 묶음에 들어 있습니다 — 한 묶음에만 넣으세요.'); return; } seen[cds[k]]=1; }
    out.push({ mainCd:g.mainCd, mainNm:venNm(g.mainCd), members:g.members.map(function(m){ return { cd:m.cd, nm:venNm(m.cd) }; }) }); }
  post('/user/compSetPatch.do', { key:'custGrp', val:{ groups:out } }, true).then(function(){ toast('저장했습니다'); try{ if(parent && typeof parent.konetSetReload==='function') parent.konetSetReload(); }catch(e){} load(); }).catch(function(e){ swErr(e.message); });
}
window.konetShown=load;
load();
</script>
</body>
</html>
