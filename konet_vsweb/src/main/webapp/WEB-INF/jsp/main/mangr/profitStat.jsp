<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>이익현황</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_toast) — 브라우저 alert 금지 --%>
<!--
  이익현황 (2026-09-28 신설) — 정보 현황 ▸ 이익현황. 사이드바 iframe(logiFrame) 화면. 자료 /mangr/profitStatList.do → selectProfitStat
  ★세 화면(거래처별 이익 · 상품별 이익 · 거래처별 상품별 이익)이 <한 자료>를 접어서 쓴다.
    서버가 주는 알갱이 = 거래처 × 상품 한 줄. 화면이 거래처로 접거나(①) 상품으로 접거나(②) 그대로 쓴다(③).
    ⇒ 탭을 옮겨도 합계가 늘 같다. 「탭마다 조회를 따로」 만들지 말 것 — 그 순간 숫자가 갈린다.
  ★금액 정의 = 마감(selectClosing)·매출 그래프와 <똑같다>(사용자 확정 2026-09-28 「전부 — 마감·매출그래프와 같은 숫자」) :
    정산서 + 정산서 없는 출고의 추정 + 판매전표 + 토더 발주. 그래서 [회사전체이익]이 마감현황과 맞는다.
  ★셈은 한 곳(calcRow)에서만 한다 : 실판매액 = 판매액 − 반품액 · 이익금 = 실판매액 − 입고액 · 이익율 = 이익금 ÷ 실판매액.
  ★사업장(점포)을 고르면 — 정산서는 발주행 사업장에 발주수량 비율로 나눈 몫만, 출고는 그 사업장 것만 센다.
    ★★판매전표는 <빠지지 않는다>(2026-09-28 사용자 확정 「사업장 골라도 빼지 말 것 · 판매전표는 이렇게 들어간 대로」) —
      판매전표엔 사업장 칸이 아예 없어 나눌 수가 없다. 거래처는 <전표에 들어간 그대로>(선식당(세종점)·풍풍플라워 미금점처럼) 쓰고 그 점포 것이든 아니든 함께 잡힌다.
      수금액·할인액도 같은 성격(거래처 단위)이라 그대로 둔다. ⚠그래서 사업장을 고르면 노란 띠로 「판매전표는 거래처 기준 전체가 함께 잡힌다」고 적어 둔다.
  ⚠인쇄는 <새 창>이다 — 이 화면은 셸 안 iframe 이라 여기서 window.print() 를 부르면 셸이 찍힌다(일계장에서 겪은 함정).
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --blue:#1d6fb8; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  /* ★표를 화면 바닥까지 채운다 (2026-09-28 「표시부분 조금만 아래까지」) — 종전 `.card{max-height:calc(100vh-300px)}` 는
     머리 칸 높이를 손으로 어림한 값이라 아래가 80px 남았고, 사업장을 골라 노란 띠가 뜨면 반대로 넘쳤다.
     ⇒ 위 칸(제목·조회줄·노란 띠·요약)은 제 높이만 쓰고(flex:0 0 auto) 표가 <남은 높이를 전부> 가져간다 — 어느 화면이든 늘 딱 맞는다.
     ⚠이 화면은 셸 iframe 이라 100vh 가 곧 iframe 높이다(셸이 상자를 배율·하단 띠만큼 줄여 준다) — 인라인 패널의 `--kz` 나눗셈은 필요 없다. */
  .wrap{ padding:12px 11px 12px; height:100vh; display:flex; flex-direction:column; }
  .wrap > h2, .wrap > .bar, .wrap > .note, .wrap > .sum{ flex:0 0 auto; }
  h2{ margin:0 0 8px; font-size:20px; }
  .tabs{ display:flex; gap:6px; margin-bottom:10px; flex-wrap:wrap; }
  .tab{ height:34px; padding:0 16px; border:1px solid var(--bd); background:#fff; border-radius:8px 8px 0 0; cursor:pointer; font-size:13.5px; font-weight:700; color:#5b6b7b; }
  .tab.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:10px; }
  .bar input[type=text], .bar input[type=date], .bar select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .bar .lab{ font-size:13px; color:#37475a; font-weight:700; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ background:#e05c4a; color:#fff; border-color:#e05c4a; }
  .sum{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:10px 12px; margin-bottom:10px; }
  .sum .ttl{ font-size:13.5px; font-weight:800; color:#125a4e; margin-bottom:6px; }
  table.s{ border-collapse:collapse; width:100%; font-size:13.5px; }
  table.s th{ background:#eaf2f0; color:#125a4e; font-weight:700; border:1px solid #cfe0da; padding:6px 8px; text-align:center; white-space:nowrap; }
  table.s td{ border:1px solid #e3eae7; padding:7px 9px; text-align:right; font-variant-numeric:tabular-nums; font-weight:700; }
  /* 남은 높이를 전부 — min-height:0 이 있어야 flex 안에서 실제로 줄어들며 제 안에 스크롤이 생긴다(없으면 내용만큼 부풀어 페이지가 스크롤된다) */
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; flex:1 1 auto; min-height:150px; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:6px 7px; text-align:center; position:sticky; top:0; z-index:2; white-space:nowrap; cursor:pointer; }
  table.g th:last-child{ border-right:none; }
  table.g th.nos{ cursor:default; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:5px 7px; text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap; }
  table.g td.l{ text-align:left; white-space:normal; word-break:break-all; }
  table.g td.c{ text-align:center; }
  table.g tbody tr:nth-child(even){ background:#fbfcfd; }
  table.g tbody tr:hover{ background:#eef6f4; }
  table.g tr.tot td{ position:sticky; bottom:0; background:#eef4f2; font-weight:800; border-top:2px solid var(--teal); z-index:1; }
  .neg{ color:var(--red); } .dim{ color:#8a97a4; }
  .cnt{ margin-left:auto; color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; white-space:nowrap; }
  .cnt b{ color:var(--teal); font-weight:800; }
  .note{ background:#fff8e1; border:1px solid #f0d98a; color:#8a5a12; border-radius:8px; padding:7px 10px; font-size:12.5px; margin-bottom:10px; }
  .empty{ text-align:center; color:#8a97a4; padding:26px 10px; }
</style>
</head>
<body>
<div class="wrap">
  <%-- ★탭이 아니라 <메뉴 3개>다 (2026-09-28 사용자 「탭으로 하지 말고 메뉴로 추가」) — gb 로 어느 표인지 정한다.
       화면(셈·엑셀·인쇄)은 하나로 두었다 : 세 화면이 같은 자료·같은 식을 써야 합계가 어긋나지 않는다. --%>
  <h2 id="ttl">이익현황</h2>
  <div class="bar">
    <span class="lab">검색일자</span>
    <input type="date" id="frDt"> <span class="dim">~</span> <input type="date" id="toDt">
    <button class="btn btn-teal" onclick="load()">리스트조회</button>
    <span class="lab" style="margin-left:8px">사업장</span>
    <select id="bizCd" style="min-width:230px" title="사업장(점포)을 고르면 정산서는 발주행 사업장에 나눈 몫, 출고는 그 사업장 것만 봅니다. 판매전표는 사업장 칸이 없어 거래처에 들어간 그대로 함께 잡힙니다"><option value="">전체</option></select>
    <span class="lab" style="margin-left:8px" id="mkLab" hidden>제조사</span>
    <select id="mkSel" style="min-width:130px" onchange="render()" hidden><option value="">전체</option></select>
    <input type="text" id="q" placeholder="거래처 · 상품 이름으로 거르기" style="width:210px" oninput="render()">
    <button class="btn" onclick="excel()">📥 엑셀 다운로드</button>
    <button class="btn btn-red" onclick="printIt()">🖨 인쇄</button>
    <span class="cnt" id="cnt">—</span>
  </div>
  <div class="note" id="bizNote" hidden></div>

  <div class="sum">
    <div class="ttl">[회사전체이익] <span class="dim" style="font-weight:400">— 마감현황·매출 그래프와 같은 기준입니다 (정산서 + 정산서 없는 출고의 추정 + 판매전표 + 토더)</span></div>
    <table class="s">
      <thead><tr><th>판매액</th><th>반품액</th><th>실판매액</th><th>반품율</th><th>입고액</th><th>이익금</th><th>이익율</th></tr></thead>
      <tbody><tr id="sumRow"><td colspan="7" class="dim" style="text-align:center;font-weight:400">조회하세요.</td></tr></tbody>
    </table>
  </div>

  <div class="card"><table class="g"><thead id="head"></thead><tbody id="body"></tbody></table></div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var _rows=[], _recv={}, _tab=1, _sortKey='', _sortAsc=false, _biz=false;

function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function fmtq(v){ var x=n(v); return (Math.round(x*100)/100).toLocaleString(); }
function pct(v){ return (Math.round(n(v)*1000)/10).toLocaleString()+'%'; }
function toast(m,i){ if(window._toast) _toast(m,'warning'); else if(window._alertBox) _alertBox(m,{icon:i||'ℹ️'}); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }

/* ★셈은 여기 한 곳 — 세 탭·요약·엑셀·인쇄가 모두 이 함수를 쓴다 (어긋날 수 없게) */
function calcRow(o){
  var saleAmt=n(o.saleAmt), rtnAmt=n(o.rtnAmt), costAmt=n(o.costAmt);
  var saleQty=n(o.saleQty), rtnQty=n(o.rtnQty);
  var realAmt=saleAmt-rtnAmt, realQty=saleQty-rtnQty, profit=realAmt-costAmt;
  return { saleAmt:saleAmt, rtnAmt:rtnAmt, realAmt:realAmt, costAmt:costAmt, profit:profit,
           saleQty:saleQty, rtnQty:rtnQty, realQty:realQty,
           rate: realAmt? profit/realAmt : 0, rtnRate: saleAmt? rtnAmt/saleAmt : 0 };
}
function addUp(a, b){ ['saleAmt','rtnAmt','costAmt','saleQty','rtnQty'].forEach(function(k){ a[k]=n(a[k])+n(b[k]); }); return a; }
/* 입수로 BOX·EA 나누기 — 상품별 이익 표. 입수가 없거나 1이면 전부 EA */
function boxOf(qty, pack){ var p=n(pack); if(p<=1) return { bx:0, ea:n(qty) }; var q=n(qty), s=q<0?-1:1; q=Math.abs(q);
  var bx=Math.floor(q/p); return { bx:s*bx, ea:s*(q-bx*p) }; }

/* ── 사업장 목록 ── */
function bizLoad(){
  fetch(CTX+'/mangr/biziList.do',{method:'POST',credentials:'same-origin'}).then(function(r){ return r.json(); })
   .then(function(j){
      var l=(j&&j.data)||[], s=document.getElementById('bizCd');
      var seen={}, out=[];
      l.forEach(function(b){ var cd=b.bizCd||b.BIZ_CD||'', nm=b.bizNm||b.BIZ_NM||''; if(!cd||seen[cd]) return; seen[cd]=1; out.push({cd:cd,nm:nm}); });
      out.sort(function(a,b){ return String(a.nm).localeCompare(String(b.nm)); });
      s.innerHTML='<option value="">전체</option>'+out.map(function(b){ return '<option value="'+esc(b.cd)+'">'+esc(b.nm)+' ('+esc(b.cd)+')</option>'; }).join('');
   }).catch(function(){});
}

/* ── 조회 ── */
function load(){
  var fr=document.getElementById('frDt').value, to=document.getElementById('toDt').value;
  if(!fr||!to){ toast('검색일자를 고르세요.','⚠️'); return; }
  if(fr>to){ toast('시작일이 종료일보다 늦습니다.','⚠️'); return; }
  var biz=document.getElementById('bizCd').value;
  document.getElementById('cnt').textContent='불러오는 중…';
  document.getElementById('body').innerHTML='<tr><td colspan="20" class="empty">불러오는 중…</td></tr>';
  var b='frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)+'&bizCd='+encodeURIComponent(biz);
  fetch(CTX+'/mangr/profitStatList.do',{ method:'POST', credentials:'same-origin',
        headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body:b })
   .then(function(r){ return r.json(); })
   .then(function(j){
      if(j&&j.login==='N'){ _alertBox('로그인이 끊겼습니다 — 다시 로그인한 뒤 조회해 주세요.',{icon:'⚠️'}); return; }
      _rows=(j&&j.data)||[]; _biz=!!biz;
      _recv={}; ((j&&j.recv)||[]).forEach(function(r2){ _recv[r2.venCd]={ rcvAmt:n(r2.rcvAmt), dcAmt:n(r2.dcAmt) }; });
      var nt=document.getElementById('bizNote');
      /* ★사업장을 골라도 판매전표는 <빠지지 않는다>(2026-09-28 사용자 확정 「사업장 골라도 빼지 말 것 · 판매전표는 이렇게 들어간 대로」) —
         판매전표엔 사업장 칸이 아예 없어 나눌 수가 없다. 그래서 정산서·출고만 그 점포 몫으로 줄고 판매전표·수금액·할인액은 거래처 기준 그대로 남는다.
         ⚠그 점포와 상관없는 직거래 매출이 함께 잡히므로 <그렇다고 화면에 적어 둔다> — 안 적으면 숫자를 오해한다. */
      if(_biz){ nt.hidden=false; nt.innerHTML='사업장을 골랐습니다 — <b>정산서</b>는 그 점포로 간 몫만(발주수량 비율로 나눔), <b>출고</b>는 그 점포 것만 셉니다. '
                 +'<b>판매전표(직접판매)는 사업장 칸이 없어 거래처에 들어간 그대로 전부 함께 잡힙니다</b>(수금액·할인액도 거래처 기준 전체).'; }
      else nt.hidden=true;
      mkFill(); render();
   })
   .catch(function(e){ document.getElementById('cnt').textContent='—';
      document.getElementById('body').innerHTML='<tr><td colspan="20" class="empty">불러오지 못했습니다 — '+esc(e.message)+'</td></tr>'; });
}
function mkFill(){
  var s=document.getElementById('mkSel'), cur=s.value, seen={}, l=[];
  _rows.forEach(function(o){ var m=(o.makerNm||'').trim(); if(!m||seen[m]) return; seen[m]=1; l.push(m); });
  l.sort(function(a,b){ return a.localeCompare(b); });
  s.innerHTML='<option value="">전체</option>'+l.map(function(m){ return '<option value="'+esc(m)+'">'+esc(m)+'</option>'; }).join('');
  if(cur && seen[cur]) s.value=cur;
}

/* ── 어느 표인가 — 메뉴가 준 gb (1 거래처별 · 2 상품별 · 3 거래처별 상품별) ── */
function tab(i){
  _tab=i; _sortKey=''; _sortAsc=false;
  document.getElementById('ttl').textContent=tabTitle();
  try{ document.title=tabTitle(); }catch(e){}
  var on=(i!==1);   /* 제조사 고르기는 상품이 보이는 표에서만 */
  document.getElementById('mkSel').hidden=!on; document.getElementById('mkLab').hidden=!on;
  render();
}
function tabTitle(){ return _tab===1?'거래처별 이익':(_tab===2?'상품별 이익':'거래처별 상품별 이익'); }

/* ── 거르기 ── */
function filtered(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  var mk=document.getElementById('mkSel').value;
  return _rows.filter(function(o){
    if(_tab!==1 && mk && (o.makerNm||'')!==mk) return false;
    if(!q) return true;
    return [o.venNm,o.prodNm,o.prodCd,o.spec,o.makerNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  });
}
/* 접기 — ①거래처 ②상품 ③그대로 */
function grouped(){
  var l=filtered();
  if(_tab===3) return l.map(function(o){ return Object.assign({}, o); });
  var key=(_tab===1)? function(o){ return o.venCd; } : function(o){ return o.prodCd+'|'+(o.prodNm||''); };
  var m={}, out=[];
  l.forEach(function(o){
    var k=key(o), g=m[k];
    if(!g){ g=m[k]=Object.assign({}, o, {saleAmt:0,rtnAmt:0,costAmt:0,saleQty:0,rtnQty:0}); out.push(g); }
    addUp(g, o);
  });
  return out;
}
function sortRows(l){
  if(!_sortKey) return l;
  var k=_sortKey, asc=_sortAsc;
  return l.slice().sort(function(a,b){
    var x=k==='nm'? String(_tab===2?a.prodNm:a.venNm||'') : n(calcRow(a)[k]);
    var y=k==='nm'? String(_tab===2?b.prodNm:b.venNm||'') : n(calcRow(b)[k]);
    if(k==='nm') return asc? x.localeCompare(y) : y.localeCompare(x);
    return asc? x-y : y-x;
  });
}
function sortBy(k){ if(_sortKey===k) _sortAsc=!_sortAsc; else { _sortKey=k; _sortAsc=false; } render(); }

/* ── 표 ── */
function cols(){
  /* 수금액·할인액은 사업장을 골라도 그대로 보인다(거래처 단위 값 — 2026-09-28 확정) */
  if(_tab===1) return [{t:'#',c:'nos'},{t:'거래처',k:'nm'},{t:'담당자',c:'nos'},{t:'판매액',k:'saleAmt'},{t:'반품액',k:'rtnAmt'},{t:'실판매액',k:'realAmt'},{t:'반품율',k:'rtnRate'},
                       {t:'입고액',k:'costAmt'},{t:'이익금',k:'profit'},{t:'이익율',k:'rate'},{t:'수금액',c:'nos'},{t:'할인액',c:'nos'}];
  if(_tab===2) return [{t:'#',c:'nos'},{t:'상품',k:'nm'},{t:'규격',c:'nos'},{t:'제조사',c:'nos'},
                       {t:'판매BOX',c:'nos'},{t:'판매EA',c:'nos'},{t:'판매합계',c:'nos'},{t:'판매금액',k:'saleAmt'},
                       {t:'반품BOX',c:'nos'},{t:'반품EA',c:'nos'},{t:'반품합계',c:'nos'},{t:'반품금액',k:'rtnAmt'},
                       {t:'실판매BOX',c:'nos'},{t:'실판매EA',c:'nos'},{t:'실판매합계',c:'nos'},{t:'실판매금액',k:'realAmt'},
                       {t:'입고액',k:'costAmt'},{t:'이익금',k:'profit'},{t:'이익율',k:'rate'}];
  return [{t:'#',c:'nos'},{t:'담당자',c:'nos'},{t:'거래처',k:'nm'},{t:'상품',c:'nos'},{t:'규격',c:'nos'},
          {t:'판매액',k:'saleAmt'},{t:'판매수량',c:'nos'},{t:'반품액',k:'rtnAmt'},{t:'반품수량',c:'nos'},
          {t:'실판매액',k:'realAmt'},{t:'실판매수량',c:'nos'},{t:'반품율',k:'rtnRate'},{t:'입고액',k:'costAmt'},{t:'이익금',k:'profit'},{t:'이익율',k:'rate'}];
}
function cellsOf(o, i){
  var r=calcRow(o), neg=function(v){ return n(v)<0?' class="neg"':''; };
  if(_tab===1){
    var rc=_recv[o.venCd]||{rcvAmt:0,dcAmt:0};
    return '<td class="c">'+(i+1)+'</td><td class="l">'+esc(o.venNm||'')+'</td><td class="c">'+esc(o.mgrNm||'')+'</td>'
      +'<td>'+fmt(r.saleAmt)+'</td><td>'+fmt(r.rtnAmt)+'</td><td>'+fmt(r.realAmt)+'</td><td>'+pct(r.rtnRate)+'</td>'
      +'<td>'+fmt(r.costAmt)+'</td><td'+neg(r.profit)+'>'+fmt(r.profit)+'</td><td'+neg(r.profit)+'>'+pct(r.rate)+'</td>'
      +'<td>'+fmt(rc.rcvAmt)+'</td><td>'+fmt(rc.dcAmt)+'</td>';
  }
  if(_tab===2){
    var bs=boxOf(r.saleQty,o.packQty), br=boxOf(r.rtnQty,o.packQty), be=boxOf(r.realQty,o.packQty);
    return '<td class="c">'+(i+1)+'</td><td class="l">'+esc(o.prodNm||'')+'</td><td class="l">'+esc(o.spec||'')+'</td><td class="c">'+esc(o.makerNm||'')+'</td>'
      +'<td>'+fmtq(bs.bx)+'</td><td>'+fmtq(bs.ea)+'</td><td>'+fmtq(r.saleQty)+'</td><td>'+fmt(r.saleAmt)+'</td>'
      +'<td>'+fmtq(br.bx)+'</td><td>'+fmtq(br.ea)+'</td><td>'+fmtq(r.rtnQty)+'</td><td>'+fmt(r.rtnAmt)+'</td>'
      +'<td>'+fmtq(be.bx)+'</td><td>'+fmtq(be.ea)+'</td><td>'+fmtq(r.realQty)+'</td><td>'+fmt(r.realAmt)+'</td>'
      +'<td>'+fmt(r.costAmt)+'</td><td'+neg(r.profit)+'>'+fmt(r.profit)+'</td><td'+neg(r.profit)+'>'+pct(r.rate)+'</td>';
  }
  return '<td class="c">'+(i+1)+'</td><td class="c">'+esc(o.mgrNm||'')+'</td><td class="l">'+esc(o.venNm||'')+'</td>'
    +'<td class="l">'+esc(o.prodNm||'')+'</td><td class="l">'+esc(o.spec||'')+'</td>'
    +'<td>'+fmt(r.saleAmt)+'</td><td>'+fmtq(r.saleQty)+'</td><td>'+fmt(r.rtnAmt)+'</td><td>'+fmtq(r.rtnQty)+'</td>'
    +'<td>'+fmt(r.realAmt)+'</td><td>'+fmtq(r.realQty)+'</td><td>'+pct(r.rtnRate)+'</td>'
    +'<td>'+fmt(r.costAmt)+'</td><td'+neg(r.profit)+'>'+fmt(r.profit)+'</td><td'+neg(r.profit)+'>'+pct(r.rate)+'</td>';
}
function totCells(t, cnt){
  var r=calcRow(t);
  if(_tab===1) return '<td class="c">Total</td><td class="l">'+cnt+'곳</td><td></td>'
      +'<td>'+fmt(r.saleAmt)+'</td><td>'+fmt(r.rtnAmt)+'</td><td>'+fmt(r.realAmt)+'</td><td>'+pct(r.rtnRate)+'</td>'
      +'<td>'+fmt(r.costAmt)+'</td><td>'+fmt(r.profit)+'</td><td>'+pct(r.rate)+'</td>'
      +'<td>'+fmt(totRecv())+'</td><td>'+fmt(totDc())+'</td>';
  if(_tab===2){
    var bs=boxOf(r.saleQty,0), br=boxOf(r.rtnQty,0), be=boxOf(r.realQty,0);   /* 합계는 상품이 섞여 입수가 다르므로 BOX 로 안 나눈다 */
    return '<td class="c">Total</td><td class="l">'+cnt+'품목</td><td></td><td></td>'
      +'<td class="dim">—</td><td class="dim">—</td><td>'+fmtq(r.saleQty)+'</td><td>'+fmt(r.saleAmt)+'</td>'
      +'<td class="dim">—</td><td class="dim">—</td><td>'+fmtq(r.rtnQty)+'</td><td>'+fmt(r.rtnAmt)+'</td>'
      +'<td class="dim">—</td><td class="dim">—</td><td>'+fmtq(r.realQty)+'</td><td>'+fmt(r.realAmt)+'</td>'
      +'<td>'+fmt(r.costAmt)+'</td><td>'+fmt(r.profit)+'</td><td>'+pct(r.rate)+'</td>';
  }
  return '<td class="c">Total</td><td></td><td class="l">'+cnt+'줄</td><td></td><td></td>'
    +'<td>'+fmt(r.saleAmt)+'</td><td>'+fmtq(r.saleQty)+'</td><td>'+fmt(r.rtnAmt)+'</td><td>'+fmtq(r.rtnQty)+'</td>'
    +'<td>'+fmt(r.realAmt)+'</td><td>'+fmtq(r.realQty)+'</td><td>'+pct(r.rtnRate)+'</td>'
    +'<td>'+fmt(r.costAmt)+'</td><td>'+fmt(r.profit)+'</td><td>'+pct(r.rate)+'</td>';
}
function totRecv(){ var s=0, seen={}; grouped().forEach(function(o){ if(_tab!==1||seen[o.venCd]) return; seen[o.venCd]=1; s+=(_recv[o.venCd]||{}).rcvAmt||0; }); return s; }
function totDc(){ var s=0, seen={}; grouped().forEach(function(o){ if(_tab!==1||seen[o.venCd]) return; seen[o.venCd]=1; s+=(_recv[o.venCd]||{}).dcAmt||0; }); return s; }

function render(){
  var l=sortRows(grouped()), C=cols();
  document.getElementById('head').innerHTML='<tr>'+C.map(function(c){
    var on=(c.k&&_sortKey===c.k);
    return '<th'+(c.c==='nos'?' class="nos"':' onclick="sortBy(\''+c.k+'\')"')+'>'+esc(c.t)+(on?(_sortAsc?' ▲':' ▼'):'')+'</th>'; }).join('')+'</tr>';
  var tb=document.getElementById('body');
  if(!l.length){ tb.innerHTML='<tr><td colspan="'+C.length+'" class="empty">자료가 없습니다.</td></tr>'; document.getElementById('cnt').textContent='0건'; sumPaint([]); return; }
  var tot={saleAmt:0,rtnAmt:0,costAmt:0,saleQty:0,rtnQty:0};
  l.forEach(function(o){ addUp(tot,o); });
  tb.innerHTML=l.map(function(o,i){ return '<tr>'+cellsOf(o,i)+'</tr>'; }).join('')
    +'<tr class="tot">'+totCells(tot, l.length)+'</tr>';
  document.getElementById('cnt').innerHTML='<b>'+l.length+'</b>건';
  sumPaint(_rows);   /* ★요약은 <거른 것과 무관하게> 그 기간 회사 전체 — 「회사전체이익」이라는 말과 맞아야 한다 */
}
function sumPaint(all){
  var t={saleAmt:0,rtnAmt:0,costAmt:0,saleQty:0,rtnQty:0};
  (all||[]).forEach(function(o){ addUp(t,o); });
  var r=calcRow(t), row=document.getElementById('sumRow');
  if(!(all||[]).length){ row.innerHTML='<td colspan="7" class="dim" style="text-align:center;font-weight:400">자료가 없습니다.</td>'; return; }
  row.innerHTML='<td>'+fmt(r.saleAmt)+'</td><td>'+fmt(r.rtnAmt)+'</td><td>'+fmt(r.realAmt)+'</td><td>'+pct(r.rtnRate)+'</td>'
    +'<td>'+fmt(r.costAmt)+'</td><td'+(r.profit<0?' class="neg"':'')+'>'+fmt(r.profit)+'</td><td'+(r.profit<0?' class="neg"':'')+'>'+pct(r.rate)+'</td>';
}

/* ── 엑셀 ── ★화면과 <같은 목록·같은 셈>이어야 한다 — grouped()·cols() 를 그대로 쓴다 */
function aoaOf(){
  var l=sortRows(grouped()), C=cols(), aoa=[C.map(function(c){ return c.t; })];
  l.forEach(function(o,i){
    var r=calcRow(o), rc=_recv[o.venCd]||{rcvAmt:0,dcAmt:0};
    if(_tab===1) aoa.push([i+1,o.venNm||'',o.mgrNm||'',r.saleAmt,r.rtnAmt,r.realAmt,r.rtnRate,r.costAmt,r.profit,r.rate].concat([rc.rcvAmt,rc.dcAmt]));
    else if(_tab===2){ var bs=boxOf(r.saleQty,o.packQty), br=boxOf(r.rtnQty,o.packQty), be=boxOf(r.realQty,o.packQty);
      aoa.push([i+1,o.prodNm||'',o.spec||'',o.makerNm||'',bs.bx,bs.ea,r.saleQty,r.saleAmt,br.bx,br.ea,r.rtnQty,r.rtnAmt,be.bx,be.ea,r.realQty,r.realAmt,r.costAmt,r.profit,r.rate]); }
    else aoa.push([i+1,o.mgrNm||'',o.venNm||'',o.prodNm||'',o.spec||'',r.saleAmt,r.saleQty,r.rtnAmt,r.rtnQty,r.realAmt,r.realQty,r.rtnRate,r.costAmt,r.profit,r.rate]);
  });
  return aoa;
}
function tabNm(){ return _tab===1?'거래처별이익':(_tab===2?'상품별이익':'거래처별상품별이익'); }
function excel(){
  if(!_rows.length){ toast('먼저 조회하세요.','⚠️'); return; }
  var LIB=(window.parent&&window.parent.XLSX)||window.XLSX;
  var aoa=aoaOf();
  if(!LIB){   /* 엑셀 도구가 없으면 CSV 로 (상품코드등록과 같은 물러서기) */
    var csv=aoa.map(function(r){ return r.map(function(c){ var s=String(c==null?'':c); return /[",\n]/.test(s)?'"'+s.replace(/"/g,'""')+'"':s; }).join(','); }).join('\r\n');
    var a=document.createElement('a'); a.href=URL.createObjectURL(new Blob(['﻿'+csv],{type:'text/csv;charset=utf-8'}));
    a.download=tabNm()+'_'+gv('frDt').replace(/-/g,'')+'-'+gv('toDt').replace(/-/g,'')+'.csv'; a.click(); return;
  }
  var ws=LIB.utils.aoa_to_sheet(aoa), wb=LIB.utils.book_new();
  LIB.utils.book_append_sheet(wb, ws, tabNm());
  LIB.writeFile(wb, tabNm()+'_'+gv('frDt').replace(/-/g,'')+'-'+gv('toDt').replace(/-/g,'')+'.xlsx');
}
function gv(id){ return document.getElementById(id).value||''; }

/* ── 인쇄 ──
   ⚠이 화면은 셸 안 iframe 이라 여기서 window.print() 를 부르면 <판매 화면이 아니라 셸>이 찍힌다(일계장에서 겪은 함정).
     새 창에 표만 그리고 그 창이 제 print() 를 부른다. 팝업이 막히면 안내한다. */
function printIt(){
  if(!_rows.length){ toast('먼저 조회하세요.','⚠️'); return; }
  var l=sortRows(grouped()), C=cols();
  var tot={saleAmt:0,rtnAmt:0,costAmt:0,saleQty:0,rtnQty:0}; l.forEach(function(o){ addUp(tot,o); });
  var st=calcRow((function(){ var t={saleAmt:0,rtnAmt:0,costAmt:0,saleQty:0,rtnQty:0}; _rows.forEach(function(o){ addUp(t,o); }); return t; })());
  var biz=document.getElementById('bizCd');
  var h='<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><title>'+esc(tabNm())+'</title><style>'
    +'body{font-family:"맑은 고딕",sans-serif;margin:0;padding:10mm 8mm;color:#111;font-size:11px}'
    +'h1{font-size:17px;margin:0 0 4px;text-align:center}'
    +'.hd{font-size:11px;color:#333;margin-bottom:8px;text-align:center}'
    +'table{border-collapse:collapse;width:100%}'
    +'th,td{border:1px solid #444;padding:3px 4px;text-align:right;white-space:nowrap}'
    +'th{background:#eee;text-align:center;font-size:10.5px}'
    +'td.l{text-align:left;white-space:normal}td.c{text-align:center}'
    +'tr.tot td{font-weight:800;background:#f2f2f2}'
    +'table.s{margin-bottom:8px}table.s td{font-weight:700}'
    +'@page{size:A4 landscape;margin:0}thead{display:table-header-group}'
    +'</style></head><body>'
    +'<h1>'+esc(tabNm().replace(/별/g,'별 '))+'</h1>'
    +'<div class="hd">'+esc(gv('frDt'))+' ~ '+esc(gv('toDt'))
    +(biz.value?(' · 사업장 '+esc(biz.options[biz.selectedIndex].text)):'')
    +' · 출력 '+new Date().toLocaleString('ko-KR')+'</div>'
    +'<table class="s"><thead><tr><th>판매액</th><th>반품액</th><th>실판매액</th><th>반품율</th><th>입고액</th><th>이익금</th><th>이익율</th></tr></thead>'
    +'<tbody><tr><td>'+fmt(st.saleAmt)+'</td><td>'+fmt(st.rtnAmt)+'</td><td>'+fmt(st.realAmt)+'</td><td>'+pct(st.rtnRate)+'</td><td>'+fmt(st.costAmt)+'</td><td>'+fmt(st.profit)+'</td><td>'+pct(st.rate)+'</td></tr></tbody></table>'
    +'<table><thead><tr>'+C.map(function(c){ return '<th>'+esc(c.t)+'</th>'; }).join('')+'</tr></thead><tbody>'
    +l.map(function(o,i){ return '<tr>'+cellsOf(o,i)+'</tr>'; }).join('')
    +'<tr class="tot">'+totCells(tot, l.length)+'</tr>'
    +'</tbody></table></body></html>';
  var w=window.open('', '_blank');
  if(!w){ _alertBox('팝업이 막혀 인쇄 창을 열지 못했습니다.<br><span style="font-size:13px;color:#3d4d5c">주소창 오른쪽의 팝업 차단을 풀고 다시 눌러 주세요.</span>',{icon:'⚠️'}); return; }
  w.document.write(h); w.document.close();
  w.onload=function(){ setTimeout(function(){ w.print(); }, 300); };
}

/* ── 처음 ── */
(function(){
  var t=new Date(), p=function(x){ return ('0'+x).slice(-2); };
  var to=t.getFullYear()+'-'+p(t.getMonth()+1)+'-'+p(t.getDate());
  var fr=t.getFullYear()+'-'+p(t.getMonth()+1)+'-01';
  document.getElementById('frDt').value=fr; document.getElementById('toDt').value=to;
  var m=/[?&]gb=([123])/.exec(location.search);   /* 메뉴가 준 값 — 없으면 거래처별 */
  tab(m? +m[1] : 1);
  bizLoad(); load();
})();
/* 다시 보일 때 다시 읽기 — 셸 iframe 은 로그아웃 전까지 그대로라 다른 화면에서 고친 것을 모른다(3초 안 중복 호출은 한 번만) */
var _shownAt=0;
window.konetShown=function(){ if(Date.now()-_shownAt<3000) return; _shownAt=Date.now(); load(); };
</script>
</body>
</html>
