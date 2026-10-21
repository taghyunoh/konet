<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>당월 휴가자</title>
<%--
  당월 휴가자 (2026-10-21 신설 — 사용자 「KONET_VSAPP 에서 당월 휴가자 볼 수 있게」) — 읽기 전용.
    · 웹(konet_vsweb) 직원관리 ▸ 직원 휴가 관리와 같은 표(TBL_LEAVE_MST)·같은 구분 색(회사 설정 'leave'). 등록·수정·승인은 웹에서.
    · 위 = 그 달 달력(휴가 칩, 점선 = 신청·승인 대기, 취소선 = 반려) · 아래 = 그 달 휴가 줄 목록 + 직원별 일수
    · 자바 /mangr/leaveMonth.do · /mangr/leaveInfo.do(구분·사용자) · /mangr/leaveList.do(기간)
--%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --gray:#5a6b7a; --red:#c0392b; }
  *{ box-sizing:border-box; } html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; background:#fff; }
  .wrap{ padding:12px 10px 16px; max-width:1100px; }
  .head{ display:flex; align-items:baseline; gap:10px; flex-wrap:wrap; margin-bottom:6px; }
  .head h2{ margin:0; font-size:18px; font-weight:800; } .head .desc{ font-size:12.5px; color:var(--gray); }
  .bar{ display:flex; align-items:center; gap:6px; flex-wrap:wrap; margin:6px 0 10px; }
  .btn{ height:32px; padding:0 12px; border:1px solid var(--bd); border-radius:7px; background:#fff; font-size:13px; font-weight:700; cursor:pointer; color:#1f2a37; }
  .btn:hover{ border-color:var(--teal); color:var(--teal); } .btn.on{ background:#e6f4f1; border-color:var(--teal); color:var(--teal); }
  .ym{ font-size:17px; font-weight:800; min-width:120px; text-align:center; }
  .bar select{ height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; }
  .cal{ width:100%; border-collapse:collapse; table-layout:fixed; }
  .cal th{ background:#b9ded4; color:#0b4f43; font-weight:800; padding:5px 0; border:1px solid var(--bd); font-size:12.5px; }
  .cal th.sun{ color:#c0392b; } .cal th.sat{ color:#2f4f9a; }
  .cal td{ border:1px solid var(--bd); vertical-align:top; height:74px; padding:2px 3px; background:#fff; }
  .cal td.out{ background:#fafbfc; } .cal td.wend{ background:#fcfcfd; } .cal td.today{ outline:2px solid var(--teal); outline-offset:-2px; background:#f1f9f7; }
  .cal .dn{ font-size:12.5px; font-weight:800; color:#3d4d5c; display:flex; justify-content:space-between; }
  .cal td.out .dn{ color:#b0bac4; } .cal .dn .sun{ color:#c0392b; } .cal .dn .sat{ color:#2f4f9a; } .cal .dn .cnt{ font-size:10.5px; color:var(--gray); }
  .chip{ display:block; font-size:11.5px; font-weight:700; line-height:1.35; padding:1px 4px; margin:1px 0; border-radius:5px; color:#fff; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; background:#5a6b7a; }
  .chip.pend{ opacity:.75; outline:2px dashed rgba(0,0,0,.25); outline-offset:-2px; } .chip.rej{ text-decoration:line-through; opacity:.45; }
  .legend{ display:flex; gap:10px; flex-wrap:wrap; font-size:12px; color:#3d4d5c; margin:6px 0 12px; align-items:center; }
  .box{ border:1px solid var(--bd); border-radius:8px; overflow:hidden; margin-top:10px; }
  .box .bh{ display:flex; align-items:center; gap:8px; padding:7px 10px; background:#eef5f3; border-bottom:1px solid var(--bd); font-weight:800; color:#0b4f43; font-size:13.5px; } .box .bh small{ font-weight:400; color:var(--gray); }
  table.grid{ width:100%; border-collapse:collapse; font-size:13px; }
  table.grid th{ background:#f3f6f8; color:#3d4d5c; font-weight:800; padding:5px 4px; border-bottom:1px solid var(--bd); white-space:nowrap; text-align:center; }
  table.grid td{ padding:4px 5px; border-bottom:1px solid #eef1f4; text-align:center; white-space:nowrap; } table.grid td.l{ text-align:left; } table.grid td.r{ text-align:right; }
  table.grid tr.me td{ background:#fffbea; } table.grid tr.tot td{ background:#eef5f3; font-weight:800; }
  .st{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .st.신청{ background:#fff1e0; color:#9a4b00; border:1px solid #f0c9a4; } .st.승인{ background:#e6f4f1; color:#137a6c; } .st.반려{ background:#fdecec; color:#c0392b; }
  .msg{ padding:14px; text-align:center; color:var(--gray); font-size:13px; }
  .two{ display:flex; gap:10px; align-items:flex-start; } .two > .box{ flex:1 1 0; margin-top:10px; }
  @media (max-width:720px){ .two{ flex-direction:column; } .cal td{ height:58px; } .chip{ font-size:10.5px; } }
</style>
<style id="gbCss"></style>
</head>
<body>
<div class="wrap">
  <div class="head"><h2>🏖 당월 휴가자</h2><span class="desc">이 달에 쉬는 직원을 달력과 목록으로 봅니다. 등록·수정·승인은 웹 「직원관리 ▸ 직원 휴가 관리」에서 합니다.</span></div>
  <div class="bar">
    <button class="btn" onclick="mv(-1)">◀</button><span class="ym" id="ym">—</span><button class="btn" onclick="mv(1)">▶</button><button class="btn" onclick="today()">오늘</button>
    <label style="font-size:12.5px; font-weight:700; margin-left:6px">직원</label><select id="fUser" onchange="render()"><option value="">전체</option></select>
    <label style="font-size:12.5px; font-weight:700">구분</label><select id="fGb" onchange="render()"><option value="">전체</option></select>
    <span style="margin-left:auto; font-size:12.5px; color:var(--gray)" id="cntAll"></span>
  </div>
  <table class="cal"><thead><tr><th class="sun">일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th class="sat">토</th></tr></thead><tbody id="calBody"></tbody></table>
  <div class="legend" id="legend"></div>
  <div class="two">
    <div class="box"><div class="bh">📋 <span id="listTitle">휴가 목록</span> <small id="listCnt"></small></div>
      <table class="grid"><thead><tr><th style="width:74px">직원</th><th style="width:80px">구분</th><th style="width:150px">기간</th><th style="width:44px">일수</th><th>사유</th><th style="width:56px">상태</th></tr></thead><tbody id="listBody"></tbody></table></div>
    <div class="box" style="flex:0 0 300px"><div class="bh">👤 직원별 <small>이 달 일수(반려 제외)</small></div>
      <table class="grid"><thead><tr><th>직원</th><th style="width:60px">건수</th><th style="width:60px">일수</th></tr></thead><tbody id="byBody"></tbody></table></div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _ym=new Date(); _ym=new Date(_ym.getFullYear(), _ym.getMonth(), 1);
var _gbs=[], _rows=[], _me='';
function n(v){ var x=parseFloat(String(v==null?'':v)); return isNaN(x)?0:x; }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body||'' }).then(function(r){ return r.json(); }).then(function(j){ if(j&&j.error) throw new Error(j.error); return j; }); }
function ymd(d){ return d.getFullYear()+('0'+(d.getMonth()+1)).slice(-2)+('0'+d.getDate()).slice(-2); }
function fmtDt(s){ s=String(s||'').replace(/-/g,''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function fmtD(v){ return (Math.round(n(v)*10)/10).toLocaleString('ko-KR'); }
function gbCls(g){ for(var i=0;i<_gbs.length;i++) if(_gbs[i].nm===g) return 'gb-'+i; return ''; }
function gbShort(g){ return String(g||'').replace('(오전)','AM').replace('(오후)','PM'); }
function init(){
  post('/mangr/leaveInfo.do','').then(function(j){ _gbs=j.gbs||[]; _me=j.userId||'';
    document.getElementById('gbCss').textContent=_gbs.map(function(g,i){ return '.chip.gb-'+i+'{ background:'+(g.color||'#5a6b7a')+'; }'; }).join('\n');
    var fg=document.getElementById('fGb'); _gbs.forEach(function(g){ if(g.use!==false) fg.insertAdjacentHTML('beforeend','<option>'+esc(g.nm)+'</option>'); });
    var seen={}; document.getElementById('legend').innerHTML=_gbs.filter(function(g){ if(g.use===false) return false; var k=g.nm.replace(/\(.*\)$/,''); if(seen[k]) return false; seen[k]=1; return true; }).map(function(g){ return '<span><i class="chip '+gbCls(g.nm)+'" style="display:inline-block; width:12px; height:12px; padding:0; vertical-align:-1px; margin-right:3px"></i>'+esc(g.nm.replace(/\(.*\)$/,''))+'</span>'; }).join('')
      +'<span class="chip pend" style="display:inline-block; background:#8a98a8; padding:0 6px; margin-left:6px">점선 = 신청(승인 대기)</span><span style="margin-left:auto; color:var(--gray)">칩에 마우스를 올리면 내용</span>';
    load(); }).catch(function(e){ document.getElementById('calBody').innerHTML='<tr><td colspan="7" class="msg" style="color:#c0392b">'+esc(e.message)+'</td></tr>'; });
}
function load(){
  var a=new Date(_ym.getFullYear(), _ym.getMonth(), 1), b=new Date(_ym.getFullYear(), _ym.getMonth()+1, 0);
  document.getElementById('ym').textContent=_ym.getFullYear()+'년 '+(_ym.getMonth()+1)+'월';
  post('/mangr/leaveList.do','frDt='+ymd(a)+'&toDt='+ymd(b)).then(function(j){ _rows=(j&&j.data)||[];
    var fu=document.getElementById('fUser'), v=fu.value, seen={}; fu.innerHTML='<option value="">전체</option>';
    _rows.forEach(function(o){ if(seen[o.userId]) return; seen[o.userId]=1; fu.insertAdjacentHTML('beforeend','<option value="'+esc(o.userId)+'">'+esc(o.userNm)+'</option>'); }); fu.value=v;
    render(); }).catch(function(e){ document.getElementById('calBody').innerHTML='<tr><td colspan="7" class="msg" style="color:#c0392b">'+esc(e.message)+'</td></tr>'; });
}
function mv(k){ _ym=new Date(_ym.getFullYear(), _ym.getMonth()+k, 1); load(); }
function today(){ var t=new Date(); _ym=new Date(t.getFullYear(), t.getMonth(), 1); load(); }
function filtered(){ var u=document.getElementById('fUser').value, g=document.getElementById('fGb').value; return _rows.filter(function(o){ return (!u||o.userId===u) && (!g||o.leaveGb===g); }); }
function render(){
  var rows=filtered(), y=_ym.getFullYear(), m=_ym.getMonth(), first=new Date(y,m,1), d=new Date(y,m,1-first.getDay()), tk=ymd(new Date()), h='';
  for(var w=0; w<6; w++){ h+='<tr>';
    for(var i=0;i<7;i++){ var k=ymd(d), out=(d.getMonth()!==m);
      var list=rows.filter(function(o){ return String(o.fromDt)<=k && String(o.toDt)>=k; });
      h+='<td class="'+(out?'out':'')+((i===0||i===6)?' wend':'')+(k===tk?' today':'')+'"><div class="dn"><span class="'+(i===0?'sun':(i===6?'sat':''))+'">'+d.getDate()+'</span>'+(list.length&&!out?'<span class="cnt">'+list.length+'명</span>':'')+'</div>'
        +(out?'':list.map(function(o){ return '<span class="chip '+gbCls(o.leaveGb)+(o.status==='신청'?' pend':'')+(o.status==='반려'?' rej':'')+'" title="'+esc(o.userNm+' · '+o.leaveGb+' · '+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+' · '+fmtD(o.days)+'일 · '+o.status+(o.remark?' · '+o.remark:''))+'">'+esc(o.userNm)+' '+esc(gbShort(o.leaveGb))+'</span>'; }).join(''))+'</td>';
      d.setDate(d.getDate()+1); }
    h+='</tr>'; if(d.getMonth()!==m && w>=3) break; }
  document.getElementById('calBody').innerHTML=h;
  var people={}; rows.forEach(function(o){ people[o.userId]=1; });
  document.getElementById('cntAll').textContent=rows.length?('이 달 휴가 '+rows.length+'건 · '+Object.keys(people).length+'명'):'이 달 휴가 없음';
  document.getElementById('listTitle').textContent=y+'년 '+(m+1)+'월 휴가 목록';
  document.getElementById('listCnt').textContent=rows.length+'건 · '+fmtD(rows.reduce(function(a,o){ return a+(o.status==='반려'?0:n(o.days)); },0))+'일';
  document.getElementById('listBody').innerHTML = rows.length ? rows.map(function(o){
    return '<tr class="'+(o.userId===_me?'me':'')+'"><td>'+esc(o.userNm)+'</td><td><span class="chip '+gbCls(o.leaveGb)+'" style="display:inline-block">'+esc(o.leaveGb)+'</span></td>'
      +'<td>'+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+'</td><td class="r">'+fmtD(o.days)+'</td><td class="l" style="white-space:normal">'+esc(o.remark)+'</td><td><span class="st '+esc(o.status)+'">'+esc(o.status)+'</span></td></tr>'; }).join('')
    : '<tr><td colspan="6" class="msg">이 달에 휴가가 없습니다.</td></tr>';
  var by={}, order=[]; rows.forEach(function(o){ if(!by[o.userId]){ by[o.userId]={ nm:o.userNm, c:0, d:0 }; order.push(o.userId); } by[o.userId].c++; if(o.status!=='반려') by[o.userId].d+=n(o.days); });
  var tc=0, td=0; document.getElementById('byBody').innerHTML = order.length ? order.map(function(id){ var x=by[id]; tc+=x.c; td+=x.d; return '<tr class="'+(id===_me?'me':'')+'"><td class="l"><b>'+esc(x.nm)+'</b></td><td>'+x.c+'</td><td>'+fmtD(x.d)+'</td></tr>'; }).join('')+'<tr class="tot"><td class="l">합계</td><td>'+tc+'</td><td>'+fmtD(td)+'</td></tr>'
    : '<tr><td colspan="3" class="msg">없음</td></tr>';
}
window.konetShown=function(){ load(); };
init();
</script>
</body>
</html>
