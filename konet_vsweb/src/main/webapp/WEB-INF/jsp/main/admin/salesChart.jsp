<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- 차트는 프로젝트에 이미 들어와 있는 Chart.js 2.7.2 를 쓴다(외부 CDN 안 씀) --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/Chart.min.js"></script>
<!--
  매출 그래프(월별) — 출고장별 / 월별 매출액 (2026-07-25 사용자 요청)
    · 일자별은 salesChartDay.jsp 로 따로 둔다 — 합치면 이 화면이 일자 단위 자료를 받아 무거워지고
      기간의 뜻도 달라져 서로 발목을 잡는다(2026-07-25 사용자 지시).
    · ★금액 정의는 마감현황(selectClosing)과 같다 — 두 화면 숫자가 다르면 설명이 안 된다.
        매출 = 정산서 + 정산서 없는 출고의 추정(판매단가) + 직접판매(판매전표)
      실측 202607 = 254,850,543 으로 마감현황과 일치함을 확인했다(2026-07-25).
    · 서버는 (일자 × 출고장) 한 단위로 준다. 화면에서 세 갈래로 접어 그래프 셋을 만든다 —
      한 번 읽은 자료라 옵션·달을 바꿔도 재조회가 없다.
    · 기간 귀속은 납품일자(없으면 출고일자/판매일자) — 매출내역·마감과 같은 기준.
-->
<style>
  :root{ --sc-bd:#dbe2ea; --sc-teal:#137a6c; }
  *{ box-sizing:border-box; }
  .sc-wrap{ padding:16px 18px; font-family:'맑은 고딕',Malgun Gothic,sans-serif; font-size:14px; color:#1f2a37; }
  .sc-wrap h2{ margin:0 0 4px; font-size:20px; }
  .sc-sub{ color:#1f2a37; margin-bottom:12px; font-size:12.5px; font-weight:600; }
  .sc-card{ background:#fff; border:1px solid var(--sc-bd); border-radius:10px; padding:12px 14px; margin-bottom:12px; }
  .sc-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; }
  .sc-fld{ display:flex; flex-direction:column; gap:3px; }
  .sc-fld label{ font-size:12px; font-weight:700; color:#1f2a37; }
  .sc-fld input, .sc-fld select{ height:32px; border:1px solid var(--sc-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .sc-btn{ height:32px; border:1px solid var(--sc-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .sc-btn:hover{ border-color:var(--sc-teal); }
  .sc-btn.teal{ background:var(--sc-teal); color:#fff; border-color:var(--sc-teal); }
  .kpi{ display:flex; gap:10px; flex-wrap:wrap; margin:10px 0 0; }
  .kpi div{ flex:1 1 170px; border:1px solid var(--sc-bd); border-radius:8px; padding:8px 12px; background:#fbfdfc; }
  .kpi b{ display:block; font-size:19px; color:#137a6c; margin-top:2px; }
  .kpi span{ font-size:12px; color:#1f2a37; font-weight:700; }
  .sc-tit{ display:flex; align-items:center; gap:8px; margin-bottom:8px; font-weight:800; }
  .sc-tit small{ font-weight:600; color:#2b3a48; font-size:12px; }
  /* 캔버스는 부모 폭에 맞춰 늘어난다. 높이는 고정해야 그래프가 세로로 무한정 늘어나지 않는다 */
  .sc-canvas{ position:relative; height:320px; }
  .sc-two{ display:flex; gap:12px; flex-wrap:wrap; }
  .sc-two > div{ flex:1 1 460px; min-width:0; }
  .sc-msg{ padding:26px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  .sc-note{ margin-top:8px; font-size:12.5px; color:#1f2a37; line-height:1.7; font-weight:600; }
  .sc-note b{ color:#37475a; }
  table.sc-tb{ width:100%; border-collapse:collapse; font-size:13px; margin-top:10px; }
  table.sc-tb th{ background:#eef3f2; border:1px solid var(--sc-bd); padding:6px 8px; }
  table.sc-tb td{ border:1px solid var(--sc-bd); padding:6px 8px; text-align:right; }
  table.sc-tb td.txt{ text-align:left; }
  table.sc-tb tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
</style>

<div class="sc-wrap">
  <h2>📈 매출 그래프</h2>
  <div class="sc-sub">출고장별·월별 매출액입니다. 하루 단위는 <b>매출 그래프(일자별)</b> 메뉴에서 봅니다. 금액 기준은 <b>마감현황(월계표)과 같습니다</b> — 정산서 + 정산서가 안 온 출고의 추정 + 직접판매.</div>

  <div class="sc-card">
    <div class="sc-row">
      <div class="sc-fld" style="flex:0 0 150px"><label>기간(시작월)</label><input type="month" id="scFrom"></div>
      <div class="sc-fld" style="flex:0 0 150px"><label>기간(종료월)</label><input type="month" id="scTo"></div>
      <button class="sc-btn teal" onclick="scLoad()">조회</button>
      <button class="sc-btn" onclick="scYear()">올해</button>
      <button class="sc-btn" onclick="scQuick(6)">최근 6개월</button>
      <button class="sc-btn" onclick="scQuick(12)">최근 12개월</button>
      <button class="sc-btn" onclick="scQuick(0)">전체</button>
      <label style="align-self:center; font-size:12.5px; cursor:pointer; margin-left:8px">
        <input type="checkbox" id="scStack" checked onchange="scRender()"> 확정·추정 나눠 보기
      </label>
    </div>
    <div class="kpi">
      <div><span>매출액 합계</span><b id="kSale">0</b></div>
      <div><span>정산서 확정</span><b id="kStl">0</b></div>
      <div><span>추정(정산서 미도착)</span><b id="kEst">0</b></div>
      <div><span>직접판매(전표)</span><b id="kTrx">0</b></div>
      <div><span>자료 있는 달</span><b id="kRange">—</b></div>
    </div>
  </div>

  <div class="sc-two">
    <div class="sc-card">
      <div class="sc-tit">🏬 출고장별 매출액 <small>선택 기간 합계</small></div>
      <div class="sc-canvas"><canvas id="cDc"></canvas></div>
      <div id="mDc" class="sc-msg" style="display:none">자료가 없습니다.</div>
      <table class="sc-tb" id="tDc"></table>
    </div>
    <div class="sc-card">
      <div class="sc-tit">📅 월별 매출액 <small>납품일자 기준</small></div>
      <div class="sc-canvas"><canvas id="cYm"></canvas></div>
      <div id="mYm" class="sc-msg" style="display:none">자료가 없습니다.</div>
      <table class="sc-tb" id="tYm"></table>
    </div>
  </div>

  <div class="sc-card">
    <div class="sc-note">
      <b>정산서 확정</b> — 출고장이 준 정산서의 실제 청구금액입니다. 이 금액이 받을 돈입니다.<br>
      <b>추정</b> — 물건은 나갔는데 정산서가 아직 안 온 건입니다. 판매단가(이력 우선, 없으면 상품마스터)로 계산했습니다.
      정산서가 도착하면 확정으로 옮겨가며 금액이 조금 달라질 수 있습니다.<br>
      <b>직접판매(전표)</b> — 판매등록으로 직접 입력한 매출입니다. 출고장을 거치지 않아 별도로 섭니다.
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
/* 차트 글자색 — Chart.js 기본값이 #666 이라 축·범례가 흐리다. 화면 글자와 같은 톤으로 올린다(2026-07-25 요청) */
if(window.Chart){ Chart.defaults.global.defaultFontColor = '#1f2a37'; Chart.defaults.global.defaultFontSize = 12; }
var _rows = [];
/* Chart 인스턴스를 캔버스 id 로 들고 있는다 — 다시 그릴 때 destroy 하지 않으면
   같은 캔버스에 겹쳐 그려지고 툴팁이 두 번 뜬다. */
var _chart = {};

function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function ymLbl(s){ s=String(s||''); return s.length===6 ? s.slice(0,4)+'-'+s.slice(4,6) : s; }
/* 억/만 단위로 줄여 축을 읽기 쉽게 — 원 단위 그대로면 자릿수가 길어 축이 뭉갠다 */
function shortAmt(v){
  v=n(v); var a=Math.abs(v);
  if(a>=100000000) return (v/100000000).toFixed(1)+'억';
  if(a>=10000)     return Math.round(v/10000).toLocaleString()+'만';
  return fmt(v);
}
function thisMonth(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2); }
function janThisYear(){ return (new Date()).getFullYear()+'-01'; }
/* ★날짜가 아니라 '연·월 숫자'로 계산한다.
   new Date() 에 setMonth 를 쓰면 말일에 달을 건너뛴다 — 8월 31일에 -1 하면 7월 31일이 없어
   6월 31일 → 7월 1일로 밀려 '7월'이 아니라 엉뚱한 달이 나온다. 그 함정을 피한다(2026-07-25). */
function shiftMonth(k){
  var d=new Date(), m=d.getFullYear()*12 + d.getMonth() + k;
  return Math.floor(m/12)+'-'+('0'+(m%12+1)).slice(-2);
}

/* 화면에 들어와도 바로 조회하지 않는다 — [조회]를 눌러야 돈다(2026-07-25 요청).
   기간만 기본값(올해 1월~이번 달)으로 채워 둔다. 최근 12개월로 두면 자료가 없는
   작년까지 잡혀 '2025년'이 시작월로 떠서 잘못 나온 것처럼 보인다(같은 날 지적). */
(function init(){
  document.getElementById('scFrom').value = janThisYear();
  document.getElementById('scTo').value   = thisMonth();
  scIdle();
})();

/* 조회 전 상태 — 빈 그래프 대신 무엇을 해야 하는지 알려 준다 */
function scIdle(){
  ['kSale','kStl','kEst','kTrx'].forEach(function(id){ document.getElementById(id).textContent='—'; });
  document.getElementById('kRange').textContent='조회 전';
  ['cDc','cYm'].forEach(function(id){ document.getElementById(id).style.display='none'; });
  ['mDc','mYm'].forEach(function(id){
    var e=document.getElementById(id); e.style.display='block'; e.textContent='기간을 고르고 [조회]를 누르세요.';
  });
  ['tDc','tYm'].forEach(function(id){ document.getElementById(id).innerHTML=''; });
}

/* 기간 버튼은 '조건만' 채운다 — 조회는 [조회] 를 눌러야 돈다(2026-07-25 요청) */
function scYear(){
  document.getElementById('scFrom').value = janThisYear();
  document.getElementById('scTo').value   = thisMonth();
}
function scQuick(m){
  document.getElementById('scFrom').value = m ? shiftMonth(-(m-1)) : '';
  document.getElementById('scTo').value   = m ? thisMonth() : '';
}

function scLoad(){
  var f=document.getElementById('scFrom').value, t=document.getElementById('scTo').value;
  var b='fromDt='+encodeURIComponent(f)+'&toDt='+encodeURIComponent(t);
  document.getElementById('kRange').textContent='조회 중…';
  fetch(CTX+'/shipout/selectSalesChart.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:b })
    .then(function(r){ return r.json(); })
    .then(function(j){ _rows=(j&&j.data)||[]; scRender(); })
    .catch(function(e){
      document.getElementById('kRange').textContent='오류';
      if(window._alertBox) _alertBox('조회에 실패했습니다.<br><span style="font-size:13px;color:#2b3a48">'+esc(e.message)+'</span>', {icon:'❌', okColor:'red'});
    });
}

/* 월별 그래프의 가로축 — 선택한 기간의 모든 달('yyyymm').
   기간을 비우고 '전체'로 봤다면 자료에 있는 달만 쓴다(끝없이 늘어나면 안 되므로). */
function scMonths(){
  var f=(document.getElementById('scFrom').value||'').replace('-',''),
      t=(document.getElementById('scTo').value||'').replace('-','');
  if(!f || !t){
    var ks={}; _rows.forEach(function(r){ if(r.ym) ks[r.ym]=1; });
    return Object.keys(ks).sort();
  }
  var a=+f.slice(0,4)*12 + (+f.slice(4,6)-1), b=+t.slice(0,4)*12 + (+t.slice(4,6)-1), out=[];
  if(b<a){ var s=a; a=b; b=s; }
  if(b-a > 60) a = b-60;                       // 너무 넓게 잡으면 축이 뭉갠다 — 최대 61개월
  for(var m=a; m<=b; m++) out.push(Math.floor(m/12)+('0'+(m%12+1)).slice(-2));
  return out;
}

function scRender(){
  if(!_rows.length){ scIdle(); return; }   // 아직 조회 전이면 체크박스를 눌러도 그대로 둔다
  var stack = document.getElementById('scStack').checked;
  /* 서버는 (월 × 출고장) 한 단위로 준다. 여기서 출고장별·월별 두 갈래로 접는다
     — 한 번 읽은 자료로 두 그래프를 다 그리므로 옵션을 바꿔도 재조회가 없다. */
  var tS=0,tT=0,tE=0,tX=0, dcM={}, dcO=[], ymM={};
  _rows.forEach(function(r){
    var s=n(r.saleAmt), st=n(r.stlAmt), es=n(r.estAmt), tx=n(r.trxAmt);
    tS+=s; tT+=st; tE+=es; tX+=tx;
    var dk=(r.dcNm||'(미지정)');
    if(!dcM[dk]){ dcM[dk]={ label:dk, s:0, st:0, es:0, tx:0 }; dcO.push(dk); }
    dcM[dk].s+=s; dcM[dk].st+=st; dcM[dk].es+=es; dcM[dk].tx+=tx;
    var yk=r.ym||'';
    if(!ymM[yk]){ ymM[yk]={ label:yk, s:0, st:0, es:0, tx:0 }; }
    ymM[yk].s+=s; ymM[yk].st+=st; ymM[yk].es+=es; ymM[yk].tx+=tx;
  });
  var ymO = Object.keys(ymM);
  document.getElementById('kSale').textContent = fmt(tS);
  document.getElementById('kStl').textContent  = fmt(tT);
  document.getElementById('kEst').textContent  = fmt(tE);
  document.getElementById('kTrx').textContent  = fmt(tX);
  document.getElementById('kRange').textContent = ymO.length
    ? (ymLbl(ymO.slice().sort()[0])+' ~ '+ymLbl(ymO.slice().sort()[ymO.length-1]))
    : '자료 없음';

  // 출고장별 — 금액 큰 순
  var dcL = dcO.map(function(k){ return dcM[k]; }).sort(function(a,b){ return b.s-a.s; });
  /* 월별 — 시간 순. ★자료가 있는 달만 그리면 '2025-08~2026-07'을 골랐는데 막대가 2개만 나와
     기간이 안 먹은 것처럼 보인다. 선택한 기간의 빈 달도 0으로 채워 축을 그대로 보여준다. */
  var ymL = scMonths().map(function(k){ return ymM[k] || { label:k, s:0, st:0, es:0, tx:0 }; });

  scBar('cDc','mDc', dcL, stack, null);
  scBar('cYm','mYm', ymL, stack, ymLbl);
  scTable('tDc', dcL, '출고장', null);
  scTable('tYm', ymL, '월',     ymLbl);
}

/* Chart.js 2.7.2 — 누적 막대. stack=false 면 매출액 한 덩어리로 그린다.
   ★다시 그릴 때 이전 인스턴스를 destroy 하지 않으면 캔버스에 겹쳐 그려지고 툴팁이 두 번 뜬다. */
function scBar(cid, mid, list, stack, lblFn){
  var box=document.getElementById(cid), msg=document.getElementById(mid);
  if(_chart[cid]){ _chart[cid].destroy(); _chart[cid]=null; }
  if(!list.length){ box.style.display='none'; msg.style.display='block'; return; }
  box.style.display=''; msg.style.display='none';

  var labels = list.map(function(o){ return lblFn ? lblFn(o.label) : o.label; });
  var ds = stack
    ? [ { label:'정산서 확정', backgroundColor:'#137a6c', data:list.map(function(o){ return Math.round(o.st); }) },
        { label:'추정',        backgroundColor:'#7fc4b6', data:list.map(function(o){ return Math.round(o.es); }) },
        { label:'직접판매',    backgroundColor:'#c47f17', data:list.map(function(o){ return Math.round(o.tx); }) } ]
    : [ { label:'매출액',      backgroundColor:'#137a6c', data:list.map(function(o){ return Math.round(o.s); }) } ];

  var ch = new Chart(box.getContext('2d'), {
    type:'bar',
    data:{ labels:labels, datasets:ds },
    options:{
      responsive:true, maintainAspectRatio:false,
      legend:{ display:stack, position:'bottom', labels:{ boxWidth:12, fontSize:12, fontColor:'#1f2a37', fontStyle:'700' } },
      tooltips:{
        mode:'index', intersect:false,
        callbacks:{
          label:function(ti, d){ return d.datasets[ti.datasetIndex].label+' : '+fmt(ti.yLabel)+'원'; },
          footer:function(tis){ var s=0; tis.forEach(function(t){ s+=n(t.yLabel); }); return '합계 : '+fmt(s)+'원'; }
        }
      },
      scales:{
        xAxes:[{ stacked:stack, gridLines:{ display:false }, ticks:{ fontSize:12, fontColor:'#2b3a48', fontStyle:'700', autoSkip:false, maxRotation:40 } }],
        yAxes:[{ stacked:stack, ticks:{ beginAtZero:true, fontSize:12, fontColor:'#2b3a48', callback:function(v){ return shortAmt(v); } } }]
      }
    }
  });
  _chart[cid]=ch;
}

/* 그래프만 있으면 정확한 값을 못 읽는다 — 같은 자료를 표로도 붙인다 */
function scTable(tid, list, head, lblFn){
  var el=document.getElementById(tid);
  if(!list.length){ el.innerHTML=''; return; }
  var t={s:0,st:0,es:0,tx:0};
  list.forEach(function(o){ t.s+=o.s; t.st+=o.st; t.es+=o.es; t.tx+=o.tx; });
  var h='<thead><tr><th>'+head+'</th><th>매출액</th><th>정산서</th><th>추정</th><th>직접판매</th><th>비중</th></tr></thead><tbody>';
  h+='<tr class="tot"><td class="txt">■ 합계</td><td>'+fmt(t.s)+'</td><td>'+fmt(t.st)+'</td><td>'+fmt(t.es)+'</td><td>'+fmt(t.tx)+'</td><td>100%</td></tr>';
  list.forEach(function(o){
    h+='<tr><td class="txt">'+esc(lblFn?lblFn(o.label):o.label)+'</td><td>'+fmt(o.s)+'</td><td>'+fmt(o.st)
     + '</td><td>'+fmt(o.es)+'</td><td>'+fmt(o.tx)+'</td>'
     + '<td>'+(t.s? (o.s/t.s*100).toFixed(1) : '0.0')+'%</td></tr>';
  });
  el.innerHTML = h+'</tbody>';
}
</script>
