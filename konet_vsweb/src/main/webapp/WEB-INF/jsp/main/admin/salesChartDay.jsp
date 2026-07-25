<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/Chart.min.js"></script>
<!--
  매출 그래프(일자별) — 2026-07-25 사용자 요청
    · 월별 화면(salesChart.jsp)과 ★따로 둔다. 하나로 합치면 월별이 일자 단위 자료를 받아
      무거워지고 '기간'의 뜻도 달라져 서로 발목을 잡는다(사용자 지시).
    · 기본 조회기간 = 일주일. 여기만 날짜(일) 단위로 받는다(월별은 월 단위).
    · 금액 정의는 월별·마감현황과 같다 : 정산서 + 정산서 없는 출고의 추정 + 직접판매.
      7월 전체 합 = 254,850,543 으로 월별과 일치함을 확인했다(2026-07-25).
    · 쿼리 selectSalesChartDaily 는 출고장으로 안 쪼갠다 — '하루에 얼마'가 궁금한 화면이라 합계면 된다.
-->
<style>
  :root{ --sd-bd:#dbe2ea; --sd-teal:#137a6c; }
  *{ box-sizing:border-box; }
  .sd-wrap{ padding:16px 18px; font-family:'맑은 고딕',Malgun Gothic,sans-serif; font-size:14px; color:#1f2a37; }
  .sd-wrap h2{ margin:0 0 4px; font-size:20px; }
  .sd-sub{ color:#1f2a37; margin-bottom:12px; font-size:12.5px; font-weight:600; }
  .sd-card{ background:#fff; border:1px solid var(--sd-bd); border-radius:10px; padding:12px 14px; margin-bottom:12px; }
  .sd-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; }
  .sd-fld{ display:flex; flex-direction:column; gap:3px; }
  .sd-fld label{ font-size:12px; font-weight:700; color:#1f2a37; }
  .sd-fld input{ height:32px; border:1px solid var(--sd-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .sd-btn{ height:32px; border:1px solid var(--sd-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .sd-btn:hover{ border-color:var(--sd-teal); }
  .sd-btn.teal{ background:var(--sd-teal); color:#fff; border-color:var(--sd-teal); }
  .kpi{ display:flex; gap:10px; flex-wrap:wrap; margin:10px 0 0; }
  .kpi div{ flex:1 1 160px; border:1px solid var(--sd-bd); border-radius:8px; padding:8px 12px; background:#fbfdfc; }
  .kpi b{ display:block; font-size:19px; color:#137a6c; margin-top:2px; }
  .kpi span{ font-size:12px; color:#1f2a37; font-weight:700; }
  .sd-tit{ display:flex; align-items:center; gap:8px; margin-bottom:8px; font-weight:800; }
  .sd-tit small{ font-weight:600; color:#2b3a48; font-size:12px; }
  .sd-canvas{ position:relative; height:330px; }
  .sd-msg{ padding:26px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  table.sd-tb{ width:100%; border-collapse:collapse; font-size:13px; margin-top:10px; }
  table.sd-tb th{ background:#eef3f2; border:1px solid var(--sd-bd); padding:6px 8px; position:sticky; top:0; }
  table.sd-tb td{ border:1px solid var(--sd-bd); padding:6px 8px; text-align:right; }
  table.sd-tb td.txt{ text-align:left; }
  table.sd-tb tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
  table.sd-tb tr.wk td{ background:#fdf3e8; }        /* 주말 */
  .sd-tbwrap{ max-height:300px; overflow:auto; border:1px solid var(--sd-bd); border-radius:8px; margin-top:10px; }
  .sd-tbwrap table{ margin-top:0; }
  .sd-note{ font-size:12.5px; color:#1f2a37; line-height:1.7; font-weight:600; }
  .sd-note b{ color:#37475a; }
</style>

<div class="sd-wrap">
  <h2>🗓️ 매출 그래프 (일자별)</h2>
  <div class="sd-sub">하루 단위 매출액입니다. 기본은 <b>최근 일주일</b>입니다. 금액 기준은 <b>마감현황·월별 그래프와 같습니다</b>.</div>

  <div class="sd-card">
    <div class="sd-row">
      <div class="sd-fld" style="flex:0 0 160px"><label>조회기간(시작)</label><input type="date" id="sdFrom"></div>
      <div class="sd-fld" style="flex:0 0 160px"><label>조회기간(종료)</label><input type="date" id="sdTo"></div>
      <button class="sd-btn teal" onclick="sdLoad()">조회</button>
      <button class="sd-btn" onclick="sdQuick(7)">최근 1주</button>
      <button class="sd-btn" onclick="sdQuick(14)">최근 2주</button>
      <button class="sd-btn" onclick="sdQuick(30)">최근 30일</button>
      <button class="sd-btn" onclick="sdMonth()">이번 달</button>
      <label style="align-self:center; font-size:12.5px; cursor:pointer; margin-left:8px">
        <input type="checkbox" id="sdStack" checked onchange="sdRender()"> 확정·추정 나눠 보기
      </label>
    </div>
    <div class="kpi">
      <div><span>매출액 합계</span><b id="kSale">0</b></div>
      <div><span>정산서 확정</span><b id="kStl">0</b></div>
      <div><span>추정(정산서 미도착)</span><b id="kEst">0</b></div>
      <div><span>직접판매(전표)</span><b id="kTrx">0</b></div>
      <div><span>일평균 (매출 있는 날)</span><b id="kAvg">0</b></div>
      <div><span>최고 하루</span><b id="kMax">0</b></div>
    </div>
  </div>

  <div class="sd-card">
    <div class="sd-tit">📊 일자별 매출액 <small>납품일자 기준 · 매출이 없는 날도 0으로 세웁니다</small></div>
    <div class="sd-canvas"><canvas id="cDay"></canvas></div>
    <div id="mDay" class="sd-msg" style="display:none">해당 기간에 자료가 없습니다.</div>
    <div class="sd-tbwrap"><table class="sd-tb" id="tDay"></table></div>
    <div class="sd-note" style="margin-top:10px">
      <b>정산서 확정</b> 출고장이 준 실제 청구금액 · <b>추정</b> 물건은 나갔는데 정산서가 아직 안 온 건(판매단가로 계산) ·
      <b>직접판매</b> 판매등록으로 직접 입력한 매출. 표에서 <span style="background:#fdf3e8; padding:0 5px; border-radius:3px">주말</span>은 색으로 구분됩니다.
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
/* 차트 글자색 — Chart.js 기본값이 #666 이라 축·범례가 흐리다. 화면 글자와 같은 톤으로 올린다(2026-07-25 요청) */
if(window.Chart){ Chart.defaults.global.defaultFontColor = '#1f2a37'; Chart.defaults.global.defaultFontSize = 12; }
var _rows = [], _chart = null;

function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function shortAmt(v){
  v=n(v); var a=Math.abs(v);
  if(a>=100000000) return (v/100000000).toFixed(1)+'억';
  if(a>=10000)     return Math.round(v/10000).toLocaleString()+'만';
  return fmt(v);
}
function today(){ var d=new Date(); return ymd(d); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function shiftDay(k){ var d=new Date(); d.setDate(d.getDate()+k); return ymd(d); }
var WD = ['일','월','화','수','목','금','토'];

/* 화면에 들어와도 바로 조회하지 않는다 — [조회]를 눌러야 돈다(2026-07-25 요청).
   조회기간만 기본값(최근 일주일)으로 채워 둔다. */
(function init(){
  document.getElementById('sdFrom').value = shiftDay(-6);
  document.getElementById('sdTo').value   = today();
  sdIdle();
})();

/* 조회 전 상태 */
function sdIdle(){
  ['kSale','kStl','kEst','kTrx','kAvg','kMax'].forEach(function(id){ document.getElementById(id).textContent='—'; });
  if(_chart){ _chart.destroy(); _chart=null; }
  document.getElementById('cDay').style.display='none';
  var m=document.getElementById('mDay'); m.style.display='block'; m.textContent='조회기간을 고르고 [조회]를 누르세요.';
  document.getElementById('tDay').innerHTML='';
}

/* 기간 버튼은 '조건만' 채운다 — 조회는 [조회] 를 눌러야 돈다 */
function sdQuick(days){
  document.getElementById('sdFrom').value = shiftDay(-(days-1));
  document.getElementById('sdTo').value   = today();
}
function sdMonth(){
  var d=new Date();
  document.getElementById('sdFrom').value = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01';
  document.getElementById('sdTo').value   = today();
}

/* ★서버는 '전 기간'을 준다. 조회기간은 화면에서 자른다 — 2026-07-25 실측으로 정한 방식.
     SQL 바깥 WHERE 에 기간을 걸었더니 계획이 바뀌어 30일 조회가 4.4초까지 갔다(전 기간은 80ms).
     결과가 하루 한 줄뿐이라 전부 받아도 가볍다. 덕분에 기간을 바꿔도 재조회가 없다. */
function sdLoad(){
  var f=document.getElementById('sdFrom').value, t=document.getElementById('sdTo').value;
  if(!f || !t){ if(window._alertBox) _alertBox('조회기간을 입력하세요.', {icon:'ℹ️'}); return; }
  if(_rows.length){ sdRender(); return; }        // 이미 받아둔 자료가 있으면 자르기만 한다
  document.getElementById('kAvg').textContent='…';
  fetch(CTX+'/shipout/selectSalesChartDaily.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){ _rows=(j&&j.data)||[]; sdRender(); })
    .catch(function(e){
      document.getElementById('kAvg').textContent='오류';
      if(window._alertBox) _alertBox('조회에 실패했습니다.<br><span style="font-size:13px;color:#2b3a48">'+esc(e.message)+'</span>', {icon:'❌', okColor:'red'});
    });
}

/* 조회기간의 모든 날을 세운다 — 자료 있는 날만 그리면 붙어 나와 '매일 팔린 것'처럼 보인다 */
function sdDays(){
  var f=document.getElementById('sdFrom').value, t=document.getElementById('sdTo').value, out=[];
  if(!f || !t) return out;
  var a=new Date(f), b=new Date(t);
  if(b<a){ var s=a; a=b; b=s; }
  for(var d=new Date(a); d<=b; d.setDate(d.getDate()+1)){
    out.push({ key: ymd(d).replace(/-/g,''), wd: d.getDay() });
    if(out.length>400) break;      // 너무 넓게 잡으면 축이 뭉갠다
  }
  return out;
}

function sdRender(){
  if(!_rows.length){ sdIdle(); return; }   // 아직 조회 전이면 체크박스를 눌러도 그대로 둔다
  var stack=document.getElementById('sdStack').checked;
  var m={};
  _rows.forEach(function(r){ if(r.dt) m[r.dt]=r; });

  var list = sdDays().map(function(o){
    var r=m[o.key]||{};
    return { key:o.key, wd:o.wd, s:n(r.saleAmt), st:n(r.stlAmt), es:n(r.estAmt), tx:n(r.trxAmt) };
  });

  var tS=0,tT=0,tE=0,tX=0,mx=0,live=0;
  list.forEach(function(o){ tS+=o.s; tT+=o.st; tE+=o.es; tX+=o.tx; if(o.s>mx) mx=o.s; if(o.s!==0) live++; });
  document.getElementById('kSale').textContent = fmt(tS);
  document.getElementById('kStl').textContent  = fmt(tT);
  document.getElementById('kEst').textContent  = fmt(tE);
  document.getElementById('kTrx').textContent  = fmt(tX);
  document.getElementById('kAvg').textContent  = fmt(live ? tS/live : 0);
  document.getElementById('kMax').textContent  = fmt(mx);

  sdBar(list, stack);
  sdTable(list, tS, tT, tE, tX);
}

function sdBar(list, stack){
  var box=document.getElementById('cDay'), msg=document.getElementById('mDay');
  if(_chart){ _chart.destroy(); _chart=null; }      // 안 지우면 겹쳐 그려지고 툴팁이 두 번 뜬다
  if(!list.length){ box.style.display='none'; msg.style.display='block'; return; }
  box.style.display=''; msg.style.display='none';

  var labels = list.map(function(o){ return (+o.key.slice(6,8))+'일('+WD[o.wd]+')'; });
  var ds = stack
    ? [ { label:'정산서 확정', backgroundColor:'#137a6c', data:list.map(function(o){ return Math.round(o.st); }) },
        { label:'추정',        backgroundColor:'#7fc4b6', data:list.map(function(o){ return Math.round(o.es); }) },
        { label:'직접판매',    backgroundColor:'#c47f17', data:list.map(function(o){ return Math.round(o.tx); }) } ]
    : [ { label:'매출액',      backgroundColor:'#137a6c', data:list.map(function(o){ return Math.round(o.s); }) } ];

  _chart = new Chart(box.getContext('2d'), {
    type:'bar',
    data:{ labels:labels, datasets:ds },
    options:{
      responsive:true, maintainAspectRatio:false,
      legend:{ display:stack, position:'bottom', labels:{ boxWidth:12, fontSize:12, fontColor:'#1f2a37', fontStyle:'700' } },
      tooltips:{ mode:'index', intersect:false,
        callbacks:{
          title:function(tis){ var i=tis[0].index, o=list[i];
            return o.key.slice(0,4)+'-'+o.key.slice(4,6)+'-'+o.key.slice(6,8)+' ('+WD[o.wd]+')'; },
          label:function(ti,d){ return d.datasets[ti.datasetIndex].label+' : '+fmt(ti.yLabel)+'원'; },
          footer:function(tis){ var s=0; tis.forEach(function(t){ s+=n(t.yLabel); }); return '합계 : '+fmt(s)+'원'; }
        } },
      scales:{
        xAxes:[{ stacked:stack, gridLines:{ display:false }, ticks:{ fontSize:11, fontColor:'#2b3a48', fontStyle:'700', autoSkip:false, maxRotation:60 } }],
        yAxes:[{ stacked:stack, ticks:{ beginAtZero:true, fontSize:12, fontColor:'#2b3a48', callback:function(v){ return shortAmt(v); } } }]
      }
    }
  });
}

function sdTable(list, tS, tT, tE, tX){
  var el=document.getElementById('tDay');
  if(!list.length){ el.innerHTML=''; return; }
  var h='<thead><tr><th>일자</th><th>요일</th><th>매출액</th><th>정산서</th><th>추정</th><th>직접판매</th><th>비중</th></tr></thead><tbody>';
  h+='<tr class="tot"><td class="txt">■ 합계</td><td></td><td>'+fmt(tS)+'</td><td>'+fmt(tT)+'</td><td>'+fmt(tE)+'</td><td>'+fmt(tX)+'</td><td>100%</td></tr>';
  list.forEach(function(o){
    var wk=(o.wd===0||o.wd===6);
    h+='<tr'+(wk?' class="wk"':'')+'><td class="txt">'+o.key.slice(0,4)+'-'+o.key.slice(4,6)+'-'+o.key.slice(6,8)+'</td>'
     + '<td class="txt" style="text-align:center'+(o.wd===0?';color:#c0392b':'')+'">'+WD[o.wd]+'</td>'
     + '<td>'+fmt(o.s)+'</td><td>'+fmt(o.st)+'</td><td>'+fmt(o.es)+'</td><td>'+fmt(o.tx)+'</td>'
     + '<td>'+(tS? (o.s/tS*100).toFixed(1) : '0.0')+'%</td></tr>';
  });
  el.innerHTML = h+'</tbody>';
}
</script>
