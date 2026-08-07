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
    · ★매입액·순마진 추가 (2026-07-26 요청) — 매입액도 마감(selectClosing)과 같은 규칙이다 :
        출고수량 × 매입단가(INPRICE_HST 중 납기일자 이전 최신, 없으면 상품마스터 IN_PRICE).
        정산서만 있고 출고 자료가 없는 건(출고미상)은 정산수량으로, 직접판매는 판매수량으로 계산한다.
        순마진 = 매출액 − 매입액 이므로 그래프에서 두 값을 쌓으면 막대 높이가 곧 매출액이다.
      ※ 매입단가가 없는 품목은 매입액 0으로 잡혀 마진이 부풀어 보인다(마감 화면의 '매입가없음'과 같은 한계).
-->
<style>
  :root{ --sc-bd:#dbe2ea; --sc-teal:#137a6c; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고.
     body margin 0 + wrap padding-top 14px = 모든 화면 제목이 같은 높이(약 1cm)에서 시작 */
  html,body{ margin:0; padding:0; }
  .sc-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
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
  /* ★nowrap 필수 — 없으면 '2026-06 ~ 2026-07' 처럼 긴 값이 두 줄로 접혀 카드만 키가 커진다(2026-07-26 지적) */
  .kpi b{ display:block; font-size:19px; color:#137a6c; margin-top:2px; white-space:nowrap; }
  .kpi span{ font-size:12px; color:#1f2a37; font-weight:700; }
  /* 기간 표시 칸 — 금액보다 글자가 길어 글자만 줄이고 칸은 넓게 잡는다 */
  .kpi div.rng{ flex:1 1 200px; }
  .kpi div.rng b{ font-size:15px; padding-top:3px; }
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
  table.sc-tb th{ background:#b9ded4; color:#0b4f43; font-weight:800; box-shadow:inset 0 -2px 0 #0e6657; border:1px solid var(--sc-bd); padding:6px 8px; }
  table.sc-tb td{ border:1px solid var(--sc-bd); padding:6px 8px; text-align:right; }
  table.sc-tb td.txt{ text-align:left; }
  table.sc-tb tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
</style>

<div class="sc-wrap">
  <h2>📈 매출 그래프</h2>
  <div class="sc-sub">출고장별·월별 <b>매출액 · 매입액 · 순마진</b>입니다. 하루 단위는 <b>매출 그래프(일자별)</b> 메뉴에서 봅니다. 금액 기준은 <b>마감현황(월계표)과 같습니다</b> — 매출=정산서 + 정산서가 안 온 출고의 추정 + 직접판매 / 매입=나간 수량 × 매입단가.</div>

  <div class="sc-card">
    <div class="sc-row">
      <%-- 보기 전환 (2026-08-02 요청) — 정산 그래프처럼 제목 아래 조회줄 맨 앞. --%>
      <div class="sc-fld" style="flex:0 0 auto"><label>보기</label>
        <div style="display:flex; gap:4px">
          <button type="button" class="sc-btn" onclick="try{ parent.scTabGo('d'); }catch(e){ location.href='${pageContext.request.contextPath}/shipout/salesChartDay.do'; }">일자별</button>
          <button type="button" class="sc-btn teal">월별</button>
        </div>
      </div>
      <div class="sc-fld" style="flex:0 0 150px"><label>기간(시작월)</label><input type="month" id="scFrom"></div>
      <div class="sc-fld" style="flex:0 0 150px"><label>기간(종료월)</label><input type="month" id="scTo"></div>
      <button class="sc-btn teal" onclick="scLoad()">조회</button>
      <button class="sc-btn" onclick="scYear()">올해</button>
      <button class="sc-btn" onclick="scQuick(6)">최근 6개월</button>
      <button class="sc-btn" onclick="scQuick(12)">최근 12개월</button>
      <button class="sc-btn" onclick="scQuick(0)">전체</button>
      <div class="sc-fld" style="flex:0 0 210px; margin-left:8px"><label>그래프 보기</label>
        <select id="scMode" onchange="scRender()">
          <option value="pl">매입액 · 순마진 (쌓으면 매출액)</option>
          <option value="mix">매출 구성 (정산서·추정·직접판매)</option>
          <option value="sum">매출액만</option>
        </select>
      </div>
      <button class="sc-btn" id="scHelpBtn" onclick="scHelp()" style="margin-left:auto">ℹ️ 도움말</button>
    </div>
    <div class="kpi">
      <div><span>매출액 합계</span><b id="kSale">0</b></div>
      <div><span>매입액(원가)</span><b id="kCost">0</b></div>
      <div><span>순마진</span><b id="kMargin">0</b></div>
      <div><span>마진율</span><b id="kRate">0</b></div>
      <div><span>정산서 확정</span><b id="kStl">0</b></div>
      <div><span>추정(정산서 미도착)</span><b id="kEst">0</b></div>
      <div><span>직접판매(전표)</span><b id="kTrx">0</b></div>
      <div class="rng"><span>자료 있는 달</span><b id="kRange">—</b></div>
    </div>
  </div>

  <%-- 도움말 — 기본은 접혀 있다. 화면이 이미 빽빽해 상시 노출하면 그래프가 아래로 밀린다(2026-07-26 요청) --%>
  <div class="sc-card" id="scHelpBox" style="display:none; border-color:#9fcfc5; background:#f6fbfa">
    <div class="sc-tit" style="justify-content:space-between">
      <span>ℹ️ 이 화면 보는 법</span>
      <button class="sc-btn" onclick="scHelp(false)">닫기 ✕</button>
    </div>
    <div class="sc-note">
      <b style="color:#137a6c">■ 무엇을 보여주나</b><br>
      선택한 기간의 <b>매출액 · 매입액 · 순마진</b>을 <b>출고장별</b>(왼쪽)과 <b>월별</b>(오른쪽)로 나눠 봅니다.
      하루 단위는 <b>매출 그래프(일자별)</b> 메뉴에서 봅니다.
      금액 기준은 <b>마감현황(월계표)과 같습니다</b> — 두 화면 숫자가 서로 맞습니다.<br><br>

      <b style="color:#137a6c">■ 금액이 어떻게 계산되나</b><br>
      <b>매출액</b> = ① 정산서 확정 + ② 추정 + ③ 직접판매<br>
      &nbsp;&nbsp;· <b>정산서 확정</b> — 출고장이 준 정산서의 실제 청구금액. <b>받을 돈이 확정된 부분</b>입니다.<br>
      &nbsp;&nbsp;· <b>추정(정산서 미도착)</b> — 물건은 나갔는데 정산서가 아직 안 온 건. 우리 판매단가(이력 우선, 없으면 상품마스터)로 계산했습니다.
      정산서가 도착하면 확정으로 옮겨가고 <b>금액이 조금 달라질 수 있습니다</b>.<br>
      &nbsp;&nbsp;· <b>직접판매(전표)</b> — 판매등록으로 직접 입력한 매출. 출고장을 거치지 않아 따로 섭니다.<br>
      <b>매입액(원가)</b> = 나간 수량 × 매입단가 (매입가 이력 중 <b>납기일자 이전 최신</b> → 없으면 상품마스터 매입가)<br>
      <b>순마진</b> = 매출액 − 매입액 &nbsp;/&nbsp; <b>마진율</b> = 순마진 ÷ 매출액<br><br>

      <b style="color:#137a6c">■ 그래프 보기 3가지</b><br>
      &nbsp;&nbsp;· <b>매입액 · 순마진</b> — 아래 회색이 매입액, 위 청록이 순마진. 둘을 쌓으므로 <b>막대 전체 높이가 매출액</b>입니다.<br>
      &nbsp;&nbsp;· <b>매출 구성</b> — 매출을 정산서·추정·직접판매 세 층으로 쪼갭니다(원가 없이 매출만).<br>
      &nbsp;&nbsp;· <b>매출액만</b> — 한 덩어리 막대.<br>
      막대에 마우스를 올리면 각 값과 매출액·마진율이 함께 뜹니다. 정확한 숫자는 그래프 아래 표에서 봅니다.<br><br>

      <b style="color:#137a6c">■ 기간</b><br>
      <b>납품일자(=납기일자)</b> 기준입니다. 매출내역·마감과 같은 기준이라 월 경계에서 어긋나지 않습니다.
      기간 버튼은 조건만 채우므로 <b>[조회]</b>를 눌러야 반영됩니다. 선택한 기간에 자료가 없는 달도 0으로 세워 축을 그대로 보여줍니다.<br>
      <b>월별 그래프와 표는 최근 달이 앞(왼쪽·첫 줄)</b>에 옵니다. 출고장별은 <b>금액 큰 순</b>입니다.<br><br>

      <b style="color:#b45309">■ 읽을 때 주의</b><br>
      &nbsp;&nbsp;· <b>매입가가 등록되지 않은 품목</b>은 매입액이 0으로 잡혀 <b>마진이 실제보다 커 보입니다</b>(마감 화면의 '매입가없음'과 같은 한계).<br>
      &nbsp;&nbsp;· <b>추정 비중이 큰 기간</b>은 순마진·마진율도 그만큼 추정입니다. 정산서가 다 들어온 달로 보는 것이 정확합니다.<br>
      &nbsp;&nbsp;· 반품이 상쇄돼 매출이 0인 칸은 마진율을 낼 수 없어 <b>—</b> 로 둡니다.
    </div>
  </div>

  <div class="sc-two">
    <div class="sc-card">
      <div class="sc-tit">🏬 출고장별 <small id="tiDc">선택 기간 합계</small></div>
      <div class="sc-canvas"><canvas id="cDc"></canvas></div>
      <div id="mDc" class="sc-msg" style="display:none">자료가 없습니다.</div>
      <table class="sc-tb" id="tDc"></table>
    </div>
    <div class="sc-card">
      <div class="sc-tit">📅 월별 <small id="tiYm">납품일자 기준</small></div>
      <div class="sc-canvas"><canvas id="cYm"></canvas></div>
      <div id="mYm" class="sc-msg" style="display:none">자료가 없습니다.</div>
      <table class="sc-tb" id="tYm"></table>
    </div>
  </div>

  <div class="sc-note" style="padding:0 2px 6px">
    막대 = <b style="color:#F5A623">■</b> 매입액 + <b style="color:#2E9E4F">■</b> 순마진 (합계 = 매출액) ·
    금액 기준은 마감현황과 같습니다 · 자세한 설명은 위 <b>ℹ️ 도움말</b>.
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
  ['kSale','kCost','kMargin','kRate','kStl','kEst','kTrx'].forEach(function(id){ document.getElementById(id).textContent='—'; });
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

/* 빈 집계 한 칸 — 필드가 늘 때 여기만 고치면 된다(누락되면 NaN 으로 샌다) */
function scZero(k){ return { label:k, s:0, st:0, es:0, tx:0, c:0 }; }

function scRender(){
  if(!_rows.length){ scIdle(); return; }   // 아직 조회 전이면 보기를 바꿔도 그대로 둔다
  var mode = document.getElementById('scMode').value;
  /* 서버는 (월 × 출고장) 한 단위로 준다. 여기서 출고장별·월별 두 갈래로 접는다
     — 한 번 읽은 자료로 두 그래프를 다 그리므로 옵션을 바꿔도 재조회가 없다. */
  var tS=0,tT=0,tE=0,tX=0,tC=0, dcM={}, dcO=[], ymM={};
  _rows.forEach(function(r){
    var s=n(r.saleAmt), st=n(r.stlAmt), es=n(r.estAmt), tx=n(r.trxAmt), c=n(r.costAmt);
    tS+=s; tT+=st; tE+=es; tX+=tx; tC+=c;
    var dk=(r.dcNm||'(미지정)');
    if(!dcM[dk]){ dcM[dk]=scZero(dk); dcO.push(dk); }
    dcM[dk].s+=s; dcM[dk].st+=st; dcM[dk].es+=es; dcM[dk].tx+=tx; dcM[dk].c+=c;
    var yk=r.ym||'';
    if(!ymM[yk]){ ymM[yk]=scZero(yk); }
    ymM[yk].s+=s; ymM[yk].st+=st; ymM[yk].es+=es; ymM[yk].tx+=tx; ymM[yk].c+=c;
  });
  var ymO = Object.keys(ymM);
  document.getElementById('kSale').textContent   = fmt(tS);
  document.getElementById('kCost').textContent   = fmt(tC);
  document.getElementById('kMargin').textContent = fmt(tS-tC);
  document.getElementById('kRate').textContent   = rate(tS-tC, tS);
  document.getElementById('kStl').textContent  = fmt(tT);
  document.getElementById('kEst').textContent  = fmt(tE);
  document.getElementById('kTrx').textContent  = fmt(tX);
  document.getElementById('kRange').textContent = ymO.length
    ? (ymLbl(ymO.slice().sort()[0])+' ~ '+ymLbl(ymO.slice().sort()[ymO.length-1]))
    : '자료 없음';

  var tit = (mode==='pl') ? '매입액 · 순마진 (합=매출액)' : (mode==='mix' ? '매출 구성' : '매출액');
  document.getElementById('tiDc').textContent = tit+' · 선택 기간 합계';
  document.getElementById('tiYm').textContent = tit+' · 납품일자 기준 · 최근 달부터';

  // 출고장별 — 금액 큰 순
  var dcL = dcO.map(function(k){ return dcM[k]; }).sort(function(a,b){ return b.s-a.s; });
  /* 월별 — ★최근 달이 앞(왼쪽)에 온다 (2026-07-26 요청). 관심은 늘 최근이라 스크롤·눈이 덜 간다.
     scMonths() 는 오름차순이므로 뒤집어 쓴다. 아래 표도 같은 배열을 받아 최근부터 나온다.
     ★자료가 있는 달만 그리면 '2025-08~2026-07'을 골랐는데 막대가 2개만 나와
     기간이 안 먹은 것처럼 보인다. 선택한 기간의 빈 달도 0으로 채워 축을 그대로 보여준다. */
  var ymL = scMonths().map(function(k){ return ymM[k] || scZero(k); }).reverse();

  scBar('cDc','mDc', dcL, mode, null);
  scBar('cYm','mYm', ymL, mode, ymLbl);
  scTable('tDc', dcL, '출고장', null);
  scTable('tYm', ymL, '월',     ymLbl);
}

/* 마진율 — 매출이 0이면 나눌 수 없다(반품만 있는 달 등). '—' 로 둔다 */
function rate(m, s){ return n(s)===0 ? '—' : (m/s*100).toFixed(1)+'%'; }

/* 도움말 열고닫기 — 인자 없이 부르면 토글, false 면 닫기 */
function scHelp(on){
  var box=document.getElementById('scHelpBox');
  var show = (on===undefined) ? (box.style.display==='none') : !!on;
  box.style.display = show ? '' : 'none';
  document.getElementById('scHelpBtn').textContent = show ? 'ℹ️ 도움말 닫기' : 'ℹ️ 도움말';
  if(show) box.scrollIntoView({ block:'nearest' });
}

/* ── 막대 안 값 라벨 (2026-08-02 요청 스타일) ──────────────────────────────
   chartjs-plugin-datalabels 같은 외부 플러그인을 쓰지 않는다 — 이 화면은 CDN 없이
   프로젝트 안 Chart.js 2.7.2 만 쓰기로 되어 있어(파일 머리 주석), 인라인 플러그인으로 직접 그린다.
   ★안 그리는 경우를 둔 이유
     · 값 0        : 빈 칸에 '0' 이 찍히면 막대가 있는 것처럼 보인다
     · 높이 < 18px : 글자가 세그먼트 밖으로 삐져나와 옆 조각과 겹친다
     · 폭  < 26px  : 일자별처럼 막대가 많으면 숫자가 서로 붙어 못 읽는다
   → 안 보이는 것보다 겹쳐 보이는 게 나쁘다. 정확한 값은 아래 표에 있다. */
var scBarLabel = {
  afterDatasetsDraw: function(chart){
    var ctx = chart.ctx;
    ctx.save();
    ctx.font = '700 12px "맑은 고딕",Malgun Gothic,sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.fillStyle = '#1f2a37';
    chart.data.datasets.forEach(function(ds, di){
      var meta = chart.getDatasetMeta(di);
      if (meta.hidden) return;                       // 범례에서 끈 항목
      meta.data.forEach(function(el, i){
        var v = n(ds.data[i]); if (!v) return;
        var m = el._model, h = Math.abs(m.base - m.y);
        if (h < 18 || (m.width && m.width < 26)) return;
        ctx.fillText(shortAmt(v), m.x, (m.base + m.y) / 2);
      });
    });
    ctx.restore();
  }
};

/* Chart.js 2.7.2 — 보기(mode) 세 가지
     pl  : 매입액 + 순마진 누적 → 막대 전체 높이가 매출액이 된다(둘을 한 눈에)
     mix : 정산서·추정·직접판매 누적(매출 구성)
     sum : 매출액 한 덩어리
   ★다시 그릴 때 이전 인스턴스를 destroy 하지 않으면 캔버스에 겹쳐 그려지고 툴팁이 두 번 뜬다. */
function scBar(cid, mid, list, mode, lblFn){
  var box=document.getElementById(cid), msg=document.getElementById(mid);
  if(_chart[cid]){ _chart[cid].destroy(); _chart[cid]=null; }
  if(!list.length){ box.style.display='none'; msg.style.display='block'; return; }
  box.style.display=''; msg.style.display='none';

  var stack = (mode!=='sum');
  var labels = list.map(function(o){ return lblFn ? lblFn(o.label) : o.label; });
  var ds;
  if(mode==='pl'){
    /* 매입액을 아래, 순마진을 위에 쌓는다 — 매입액+순마진=매출액 이라 총 높이가 매출액.
       매입가가 없는 품목은 매입액 0이라 막대가 통째로 마진색이 된다(설명은 하단 안내에). */
    ds = [ { label:'매입액', backgroundColor:'#F5A623', data:list.map(function(o){ return Math.round(o.c); }) },
           { label:'순마진', backgroundColor:'#2E9E4F', data:list.map(function(o){ return Math.round(o.s-o.c); }) } ];
  } else if(mode==='mix'){
    ds = [ { label:'정산서 확정', backgroundColor:'#2E9E4F', data:list.map(function(o){ return Math.round(o.st); }) },
           { label:'추정',        backgroundColor:'#7ECB84', data:list.map(function(o){ return Math.round(o.es); }) },
           { label:'직접판매',    backgroundColor:'#F5A623', data:list.map(function(o){ return Math.round(o.tx); }) } ];
  } else {
    ds = [ { label:'매출액',      backgroundColor:'#2E9E4F', data:list.map(function(o){ return Math.round(o.s); }) } ];
  }

  var ch = new Chart(box.getContext('2d'), {
    type:'bar',
    plugins:[scBarLabel],                       // 막대 안 값 라벨 (아래 정의)
    data:{ labels:labels, datasets:ds },
    options:{
      responsive:true, maintainAspectRatio:false,
      layout:{ padding:{ top:10 } },            // 맨 위 막대의 라벨이 잘리지 않게
      legend:{ display:stack, position:'bottom', labels:{ usePointStyle:true, boxWidth:8, padding:14, fontSize:12, fontColor:'#1f2a37', fontStyle:'700' } },
      tooltips:{
        mode:'index', intersect:false,
        callbacks:{
          label:function(ti, d){ return d.datasets[ti.datasetIndex].label+' : '+fmt(ti.yLabel)+'원'; },
          /* pl 보기의 합계는 곧 매출액이다 — 마진율까지 같이 보여 준다 */
          footer:function(tis){
            var s=0; tis.forEach(function(t){ s+=n(t.yLabel); });
            if(mode!=='pl') return '합계 : '+fmt(s)+'원';
            var o=list[tis[0].index];
            return '매출액 : '+fmt(o.s)+'원  (마진율 '+rate(o.s-o.c, o.s)+')';
          }
        }
      },
      /* ★세로축(금액 눈금)을 없앴다 — 2026-08-02 요청 스타일(참조 화면)에 맞춘 것.
           값은 막대 안에 직접 찍고, 정확한 숫자는 아래 표에서 본다.
           눈금을 도로 켜려면 yAxes 의 display:false 만 지우면 된다. */
      scales:{
        xAxes:[{ stacked:stack, barPercentage:0.62, categoryPercentage:0.9,
                 gridLines:{ display:false, drawBorder:true, color:'#1f2a37' },
                 ticks:{ fontSize:12, fontColor:'#2b3a48', fontStyle:'700', autoSkip:false, maxRotation:40 } }],
        yAxes:[{ stacked:stack, display:false, gridLines:{ display:false }, ticks:{ beginAtZero:true } }]
      }
    }
  });
  _chart[cid]=ch;
}

/* 그래프만 있으면 정확한 값을 못 읽는다 — 같은 자료를 표로도 붙인다 */
function scTable(tid, list, head, lblFn){
  var el=document.getElementById(tid);
  if(!list.length){ el.innerHTML=''; return; }
  var t={s:0,st:0,es:0,tx:0,c:0};
  list.forEach(function(o){ t.s+=o.s; t.st+=o.st; t.es+=o.es; t.tx+=o.tx; t.c+=o.c; });
  var h='<thead><tr><th>'+head+'</th><th>매출액</th><th>매입액</th><th>순마진</th><th>마진율</th>'
      + '<th>정산서</th><th>추정</th><th>직접판매</th><th>비중</th></tr></thead><tbody>';
  h+='<tr class="tot"><td class="txt">■ 합계</td><td>'+fmt(t.s)+'</td><td>'+fmt(t.c)+'</td><td>'+fmt(t.s-t.c)+'</td>'
   + '<td>'+rate(t.s-t.c, t.s)+'</td>'
   + '<td>'+fmt(t.st)+'</td><td>'+fmt(t.es)+'</td><td>'+fmt(t.tx)+'</td><td>100%</td></tr>';
  list.forEach(function(o){
    h+='<tr><td class="txt">'+esc(lblFn?lblFn(o.label):o.label)+'</td><td>'+fmt(o.s)+'</td>'
     + '<td>'+fmt(o.c)+'</td><td>'+fmt(o.s-o.c)+'</td><td>'+rate(o.s-o.c, o.s)+'</td>'
     + '<td>'+fmt(o.st)+'</td><td>'+fmt(o.es)+'</td><td>'+fmt(o.tx)+'</td>'
     + '<td>'+(t.s? (o.s/t.s*100).toFixed(1) : '0.0')+'%</td></tr>';
  });
  el.innerHTML = h+'</tbody>';
}
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
