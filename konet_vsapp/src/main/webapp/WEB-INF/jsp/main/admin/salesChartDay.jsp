<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- ★날짜 칸에 [◀][▶][오늘] 을 자동으로 붙인다 (2026-08-17 요청) — 화면 수정 0.
     브라우저 기본 달력의 ↑↓ 는 앞/뒤가 안 읽혀 엉뚱한 달로 넘어가는 일이 잦았다.
     빼려면 그 칸에 data-nonav="1" --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/Chart.min.js"></script>
<!--
  매출 그래프(일자별) — 2026-07-25 사용자 요청
    · 월별 화면(salesChart.jsp)과 ★따로 둔다. 하나로 합치면 월별이 일자 단위 자료를 받아
      무거워지고 '기간'의 뜻도 달라져 서로 발목을 잡는다(사용자 지시).
    · 기본 조회기간 = 일주일. 여기만 날짜(일) 단위로 받는다(월별은 월 단위).
    · 금액 정의는 월별·마감현황과 같다 : 정산서 + 정산서 없는 출고의 추정 + 직접판매.
      7월 전체 합 = 254,850,543 으로 월별과 일치함을 확인했다(2026-07-25).
    · 쿼리 selectSalesChartDaily 는 출고장으로 안 쪼갠다 — '하루에 얼마'가 궁금한 화면이라 합계면 된다.
    · ★매입액·순마진 추가 (2026-07-26 요청) — 월별 화면·마감과 같은 규칙(나간 수량 × 매입단가,
      단가는 매입가 이력 중 납기일자 이전 최신 → 없으면 상품마스터). 순마진 = 매출액 − 매입액.
      매입가가 없는 품목은 매입액 0으로 잡혀 마진이 부풀어 보인다(마감의 '매입가없음'과 같은 한계).
-->
<style>
  :root{ --sd-bd:#dbe2ea; --sd-teal:#137a6c; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  .sd-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
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
  /* ★nowrap 필수 — 없으면 긴 값이 두 줄로 접혀 그 카드만 키가 커진다(2026-07-26 지적) */
  .kpi b{ display:block; font-size:19px; color:#137a6c; margin-top:2px; white-space:nowrap; }
  .kpi span{ font-size:12px; color:#1f2a37; font-weight:700; }
  .sd-tit{ display:flex; align-items:center; gap:8px; margin-bottom:8px; font-weight:800; }
  .sd-tit small{ font-weight:600; color:#2b3a48; font-size:12px; }
  /* ★max(…, vh) — 월별(salesChart.jsp .sc-canvas)과 같은 이유·같은 날(2026-08-28). */
  .sd-canvas{ position:relative; height:max(330px, 38vh); }
  .sd-msg{ padding:26px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  table.sd-tb{ width:100%; border-collapse:collapse; font-size:13px; margin-top:10px; }
  table.sd-tb th{ background:#b9ded4; color:#0b4f43; font-weight:800; box-shadow:inset 0 -2px 0 #0e6657; border:1px solid var(--sd-bd); padding:6px 8px; position:sticky; top:0; }
  table.sd-tb td{ border:1px solid var(--sd-bd); padding:6px 8px; text-align:right; }
  table.sd-tb td.txt{ text-align:left; }
  table.sd-tb tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
  table.sd-tb tr.wk td{ background:#fdf3e8; }        /* 주말 */
  .sd-tbwrap{ max-height:max(300px, 34vh); overflow:auto; border:1px solid var(--sd-bd); border-radius:8px; margin-top:10px; }  /* max(…, vh) — 위 .sd-canvas 참고 */
  .sd-tbwrap table{ margin-top:0; }
  .sd-note{ font-size:12.5px; color:#1f2a37; line-height:1.7; font-weight:600; }
  .sd-note b{ color:#37475a; }
</style>

<div class="sd-wrap">
  <%-- 제목의 (일자별)은 뺐다(2026-08-02) — 보기[일자별|월별] 버튼이 바로 아래 있어 중복이다 --%>
  <h2>🗓️ 매출 그래프</h2>
  <div class="sd-sub">하루 단위 <b>매출액 · 매입액 · 순마진</b>입니다. 기본은 <b>최근 일주일</b>입니다. 금액 기준은 <b>마감현황·월별 그래프와 같습니다</b>.</div>

  <div class="sd-card">
    <div class="sd-row">
      <%-- 보기 전환 (2026-08-02 요청) — 정산 그래프처럼 제목 아래 조회줄 맨 앞.
           셸(iframe 탭) 안에서는 부모의 scTabGo 로 월별 화면과 갈아끼운다. 단독으로 열렸으면 직접 이동. --%>
      <div class="sd-fld" style="flex:0 0 auto"><label>보기</label>
        <div style="display:flex; gap:4px">
          <button type="button" class="sd-btn teal">일자별</button>
          <button type="button" class="sd-btn" onclick="try{ parent.scTabGo('m'); }catch(e){ location.href='${pageContext.request.contextPath}/shipout/salesChart.do'; }">월별</button>
        </div>
      </div>
      <div class="sd-fld" style="flex:0 0 160px"><label>조회기간(시작)</label><input type="date" id="sdFrom"></div>
      <div class="sd-fld" style="flex:0 0 160px"><label>조회기간(종료)</label><input type="date" id="sdTo"></div>
      <button class="sd-btn teal" onclick="sdLoad()">조회</button>
      <button class="sd-btn" onclick="sdQuick(7)">최근 1주</button>
      <button class="sd-btn" onclick="sdQuick(14)">최근 2주</button>
      <button class="sd-btn" onclick="sdQuick(30)">최근 30일</button>
      <button class="sd-btn" onclick="sdMonth()">이번 달</button>
      <div class="sd-fld" style="flex:0 0 210px; margin-left:8px"><label>그래프 보기</label>
        <select id="sdMode" onchange="sdRender()" style="height:32px; border:1px solid var(--sd-bd); border-radius:6px; padding:0 8px; font-size:13.5px">
          <option value="pl">매입액 · 순마진 (쌓으면 매출액)</option>
          <option value="mix">매출 구성 (정산서·추정·직접판매)</option>
          <option value="sum">매출액만</option>
        </select>
      </div>
      <button class="sd-btn" id="sdHelpBtn" onclick="sdHelp()" style="margin-left:auto">ℹ️ 도움말</button>
    </div>
    <div class="kpi">
      <div><span>매출액 합계</span><b id="kSale">0</b></div>
      <div><span>매입액(원가)</span><b id="kCost">0</b></div>
      <div><span>순마진</span><b id="kMargin">0</b></div>
      <div><span>마진율</span><b id="kRate">0</b></div>
      <div><span>정산서 확정</span><b id="kStl">0</b></div>
      <div><span>추정(정산서 미도착)</span><b id="kEst">0</b></div>
      <div><span>직접판매(전표)</span><b id="kTrx">0</b></div>
      <div><span>일평균 (매출 있는 날)</span><b id="kAvg">0</b></div>
      <div><span>최고 하루</span><b id="kMax">0</b></div>
    </div>
  </div>

  <%-- 도움말 — 기본은 접혀 있다(월별 화면과 같은 방식). 2026-07-26 요청 --%>
  <div class="sd-card" id="sdHelpBox" style="display:none; border-color:#9fcfc5; background:#f6fbfa">
    <div class="sd-tit" style="justify-content:space-between">
      <span>ℹ️ 이 화면 보는 법</span>
      <button class="sd-btn" onclick="sdHelp(false)">닫기 ✕</button>
    </div>
    <div class="sd-note">
      <b style="color:#137a6c">■ 무엇을 보여주나</b><br>
      <b>하루 단위</b>로 매출액 · 매입액 · 순마진을 봅니다. 기본은 최근 일주일이며, 출고장으로 쪼개지 않고 <b>그날 합계</b>만 보여줍니다
      (출고장별로 보려면 <b>매출 그래프(월별)</b> 메뉴). 금액 기준은 <b>월별 그래프·마감현황과 같습니다</b>.<br><br>

      <b style="color:#137a6c">■ 금액이 어떻게 계산되나</b><br>
      <b>매출액</b> = ① <b>정산서 확정</b>(출고장이 준 정산서의 실제 청구금액 — 받을 돈)
      + ② <b>추정</b>(물건은 나갔는데 정산서가 아직 안 온 건. 우리 판매단가로 계산 → 정산서가 오면 확정으로 옮겨가고 금액이 조금 달라질 수 있음)
      + ③ <b>직접판매(전표)</b>(판매등록으로 직접 입력한 매출)<br>
      <b>매입액(원가)</b> = 나간 수량 × 매입단가 (매입가 이력 중 <b>납기일자 이전 최신</b> → 없으면 상품마스터 매입가)<br>
      <b>순마진</b> = 매출액 − 매입액 &nbsp;/&nbsp; <b>마진율</b> = 순마진 ÷ 매출액<br><br>

      <b style="color:#137a6c">■ 그래프 보기 3가지</b><br>
      &nbsp;&nbsp;· <b>매입액 · 순마진</b> — 아래 회색이 매입액, 위 청록이 순마진. <b>막대 전체 높이가 매출액</b>입니다.<br>
      &nbsp;&nbsp;· <b>매출 구성</b> — 정산서·추정·직접판매 세 층. &nbsp;· <b>매출액만</b> — 한 덩어리 막대.<br><br>

      <b style="color:#137a6c">■ 기간</b><br>
      <b>납품일자(=납기일자)</b> 기준입니다. 기간 버튼은 조건만 채우므로 <b>[조회]</b>를 눌러야 반영됩니다.
      매출이 없는 날도 0으로 세웁니다(안 그러면 막대가 붙어 나와 매일 팔린 것처럼 보입니다). 표에서 주말은 색으로 구분됩니다.<br>
      <b>그래프와 표 모두 최근 날짜가 앞(왼쪽·첫 줄)</b>에 옵니다. 기간을 400일보다 넓게 잡으면 <b>최근 400일</b>만 그립니다(축이 뭉개져서).<br>
      <span style="color:#5a6b7a">※ 서버는 전 기간을 한 번에 주고 화면에서 기간만큼 잘라 씁니다 — 기간을 바꿔도 재조회가 없습니다.</span><br><br>

      <b style="color:#b45309">■ 읽을 때 주의</b><br>
      &nbsp;&nbsp;· <b>매입가가 등록되지 않은 품목</b>은 매입액이 0으로 잡혀 <b>마진이 실제보다 커 보입니다</b>.<br>
      &nbsp;&nbsp;· <b>추정 비중이 큰 기간</b>은 순마진·마진율도 그만큼 추정입니다.<br>
      &nbsp;&nbsp;· 반품이 상쇄돼 매출이 0인 날은 마진율을 낼 수 없어 <b>—</b> 로 둡니다.
    </div>
  </div>

  <div class="sd-card">
    <div class="sd-tit">📊 일자별 <small id="tiDay">납품일자 기준 · 매출이 없는 날도 0으로 세웁니다</small></div>
    <div class="sd-canvas"><canvas id="cDay"></canvas></div>
    <div id="mDay" class="sd-msg" style="display:none">해당 기간에 자료가 없습니다.</div>
    <div class="sd-tbwrap"><table class="sd-tb" id="tDay"></table></div>
    <div class="sd-note" style="margin-top:10px">
      막대 = <b style="color:#F5A623">■</b> 매입액 + <b style="color:#2E9E4F">■</b> 순마진 (합계 = 매출액) ·
      <span style="background:#fdf3e8; padding:0 5px; border-radius:3px">주말</span>은 표에서 색으로 구분 ·
      자세한 설명은 위 <b>ℹ️ 도움말</b>.
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
  ['kSale','kCost','kMargin','kRate','kStl','kEst','kTrx','kAvg','kMax'].forEach(function(id){ document.getElementById(id).textContent='—'; });
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

/* 조회기간의 모든 날을 세운다 — 자료 있는 날만 그리면 붙어 나와 '매일 팔린 것'처럼 보인다.
   여기서는 날짜 오름차순으로 만들고, 화면에 그릴 때 뒤집어 최근 날짜를 앞에 둔다(2026-07-26 요청). */
function sdDays(){
  var f=document.getElementById('sdFrom').value, t=document.getElementById('sdTo').value, out=[];
  if(!f || !t) return out;
  var a=new Date(f), b=new Date(t);
  if(b<a){ var s=a; a=b; b=s; }
  for(var d=new Date(a); d<=b; d.setDate(d.getDate()+1)){
    out.push({ key: ymd(d).replace(/-/g,''), wd: d.getDay() });
    if(out.length>3000) break;     // 실수로 몇 년을 잡아도 루프가 안 도망가게 하는 안전장치
  }
  /* 너무 넓게 잡으면 축이 뭉갠다 — 400일로 자르되 ★뒤쪽(최근)을 남긴다.
     앞에서 끊으면 최근을 보려고 넓게 잡은 사람에게 옛날 400일만 나온다. */
  return out.length>400 ? out.slice(-400) : out;
}

/* 마진율 — 매출이 0이면 나눌 수 없다(반품만 있는 날 등). '—' 로 둔다 */
function rate(m, s){ return n(s)===0 ? '—' : (m/s*100).toFixed(1)+'%'; }

/* 도움말 열고닫기 — 인자 없이 부르면 토글, false 면 닫기 */
function sdHelp(on){
  var box=document.getElementById('sdHelpBox');
  var show = (on===undefined) ? (box.style.display==='none') : !!on;
  box.style.display = show ? '' : 'none';
  document.getElementById('sdHelpBtn').textContent = show ? 'ℹ️ 도움말 닫기' : 'ℹ️ 도움말';
  if(show) box.scrollIntoView({ block:'nearest' });
}

function sdRender(){
  if(!_rows.length){ sdIdle(); return; }   // 아직 조회 전이면 보기를 바꿔도 그대로 둔다
  var mode=document.getElementById('sdMode').value;
  var m={};
  _rows.forEach(function(r){ if(r.dt) m[r.dt]=r; });

  /* ★최근 날짜가 앞(왼쪽·표 첫 줄)에 온다 (2026-07-26 요청). 그래프·표가 같은 배열을 쓰므로 순서도 같다. */
  var list = sdDays().map(function(o){
    var r=m[o.key]||{};
    return { key:o.key, wd:o.wd, s:n(r.saleAmt), st:n(r.stlAmt), es:n(r.estAmt), tx:n(r.trxAmt), c:n(r.costAmt) };
  }).reverse();

  var tS=0,tT=0,tE=0,tX=0,tC=0,mx=0,live=0;
  list.forEach(function(o){ tS+=o.s; tT+=o.st; tE+=o.es; tX+=o.tx; tC+=o.c; if(o.s>mx) mx=o.s; if(o.s!==0) live++; });
  document.getElementById('kSale').textContent   = fmt(tS);
  document.getElementById('kCost').textContent   = fmt(tC);
  document.getElementById('kMargin').textContent = fmt(tS-tC);
  document.getElementById('kRate').textContent   = rate(tS-tC, tS);
  document.getElementById('kStl').textContent  = fmt(tT);
  document.getElementById('kEst').textContent  = fmt(tE);
  document.getElementById('kTrx').textContent  = fmt(tX);
  document.getElementById('kAvg').textContent  = fmt(live ? tS/live : 0);
  document.getElementById('kMax').textContent  = fmt(mx);

  document.getElementById('tiDay').textContent =
      (mode==='pl' ? '매입액 · 순마진 (합=매출액)' : (mode==='mix' ? '매출 구성' : '매출액'))
    + ' · 납품일자 기준 · 최근 날짜부터 · 매출이 없는 날도 0으로 세웁니다';

  sdBar(list, mode);
  sdTable(list, tS, tT, tE, tX, tC);
}

/* 보기(mode) 세 가지 — 월별 화면과 같은 규칙
     pl : 매입액 아래 + 순마진 위 누적 → 막대 전체 높이가 매출액
     mix: 매출 구성(정산서·추정·직접판매) / sum: 매출액 한 덩어리 */
/* ── 막대 안 값 라벨 (2026-08-02 요청 스타일) ──────────────────────────────
   외부 플러그인(chartjs-plugin-datalabels)을 쓰지 않는다 — 이 화면은 CDN 없이
   프로젝트 안 Chart.js 2.7.2 만 쓰기로 되어 있어 인라인 플러그인으로 직접 그린다.
   ★안 그리는 경우 : 값 0 / 높이<18px / 폭<26px
     일자별은 막대가 31개까지 늘어 폭이 좁아진다 — 그때는 숫자가 서로 붙어 못 읽으므로
     아예 안 찍는다(겹쳐 보이는 게 안 보이는 것보다 나쁘다). 정확한 값은 아래 표에 있다. */
var sdBarLabel = {
  afterDatasetsDraw: function(chart){
    var ctx = chart.ctx;
    ctx.save();
    ctx.font = '700 12.5px "맑은 고딕",Malgun Gothic,sans-serif';   /* 한 단계 크게 (2026-08-02 요청) */
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

function sdBar(list, mode){
  var box=document.getElementById('cDay'), msg=document.getElementById('mDay');
  if(_chart){ _chart.destroy(); _chart=null; }      // 안 지우면 겹쳐 그려지고 툴팁이 두 번 뜬다
  if(!list.length){ box.style.display='none'; msg.style.display='block'; return; }
  box.style.display=''; msg.style.display='none';

  var stack = (mode!=='sum');
  // '2일(일)' 만으로는 월 경계에서 몇 월인지 안 갈린다(2026-08-02 지적) → '8/2(일)' 로 월까지
  var labels = list.map(function(o){ return o.key.slice(4,6)+'-'+o.key.slice(6,8)+'('+WD[o.wd]+')'; });
  var ds;
  if(mode==='pl'){
    ds = [ { label:'매입액', backgroundColor:'#F5A623', data:list.map(function(o){ return Math.round(o.c); }) },
           { label:'순마진', backgroundColor:'#2E9E4F', data:list.map(function(o){ return Math.round(o.s-o.c); }) } ];
  } else if(mode==='mix'){
    ds = [ { label:'정산서 확정', backgroundColor:'#2E9E4F', data:list.map(function(o){ return Math.round(o.st); }) },
           { label:'추정',        backgroundColor:'#7ECB84', data:list.map(function(o){ return Math.round(o.es); }) },
           { label:'직접판매',    backgroundColor:'#F5A623', data:list.map(function(o){ return Math.round(o.tx); }) } ];
  } else {
    ds = [ { label:'매출액',      backgroundColor:'#2E9E4F', data:list.map(function(o){ return Math.round(o.s); }) } ];
  }

  _chart = new Chart(box.getContext('2d'), {
    type:'bar',
    plugins:[sdBarLabel],                       // 막대 안 값 라벨 (아래 정의)
    data:{ labels:labels, datasets:ds },
    options:{
      responsive:true, maintainAspectRatio:false,
      layout:{ padding:{ top:10 } },            // 맨 위 막대의 라벨이 잘리지 않게
      legend:{ display:stack, position:'bottom', labels:{ usePointStyle:true, boxWidth:8, padding:14, fontSize:12, fontColor:'#1f2a37', fontStyle:'700' } },
      tooltips:{ mode:'index', intersect:false,
        callbacks:{
          title:function(tis){ var i=tis[0].index, o=list[i];
            return o.key.slice(0,4)+'-'+o.key.slice(4,6)+'-'+o.key.slice(6,8)+' ('+WD[o.wd]+')'; },
          label:function(ti,d){ return d.datasets[ti.datasetIndex].label+' : '+fmt(ti.yLabel)+'원'; },
          /* pl 보기의 합계는 곧 매출액이다 — 마진율까지 같이 보여 준다 */
          footer:function(tis){
            var s=0; tis.forEach(function(t){ s+=n(t.yLabel); });
            if(mode!=='pl') return '합계 : '+fmt(s)+'원';
            var o=list[tis[0].index];
            return '매출액 : '+fmt(o.s)+'원  (마진율 '+rate(o.s-o.c, o.s)+')';
          }
        } },
      /* ★세로축(금액 눈금)을 없앴다 — 2026-08-02 요청 스타일(참조 화면)에 맞춘 것.
           값은 막대 안에 직접 찍고, 정확한 숫자는 아래 표에서 본다.
           눈금을 도로 켜려면 yAxes 의 display:false 만 지우면 된다. */
      scales:{
        xAxes:[{ stacked:stack, barPercentage:0.66, categoryPercentage:0.9,
                 gridLines:{ display:false, drawBorder:true, color:'#1f2a37' },
                 ticks:{ fontSize:12, fontColor:'#2b3a48', fontStyle:'700', autoSkip:false, maxRotation:60 } }],
        yAxes:[{ stacked:stack, display:false, gridLines:{ display:false }, ticks:{ beginAtZero:true } }]
      }
    }
  });
}

function sdTable(list, tS, tT, tE, tX, tC){
  var el=document.getElementById('tDay');
  if(!list.length){ el.innerHTML=''; return; }
  var h='<thead><tr><th>일자</th><th>요일</th><th>매출액</th><th>매입액</th><th>순마진</th><th>마진율</th>'
      + '<th>정산서</th><th>추정</th><th>직접판매</th><th>비중</th></tr></thead><tbody>';
  h+='<tr class="tot"><td class="txt">■ 합계</td><td></td><td>'+fmt(tS)+'</td><td>'+fmt(tC)+'</td><td>'+fmt(tS-tC)+'</td>'
   + '<td>'+rate(tS-tC, tS)+'</td>'
   + '<td>'+fmt(tT)+'</td><td>'+fmt(tE)+'</td><td>'+fmt(tX)+'</td><td>100%</td></tr>';
  list.forEach(function(o){
    var wk=(o.wd===0||o.wd===6);
    h+='<tr'+(wk?' class="wk"':'')+'><td class="txt">'+o.key.slice(0,4)+'-'+o.key.slice(4,6)+'-'+o.key.slice(6,8)+'</td>'
     + '<td class="txt" style="text-align:center'+(o.wd===0?';color:#c0392b':'')+'">'+WD[o.wd]+'</td>'
     + '<td>'+fmt(o.s)+'</td><td>'+fmt(o.c)+'</td><td>'+fmt(o.s-o.c)+'</td><td>'+rate(o.s-o.c, o.s)+'</td>'
     + '<td>'+fmt(o.st)+'</td><td>'+fmt(o.es)+'</td><td>'+fmt(o.tx)+'</td>'
     + '<td>'+(tS? (o.s/tS*100).toFixed(1) : '0.0')+'%</td></tr>';
  });
  el.innerHTML = h+'</tbody>';
}
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
<%-- ★공통 UI 보정 (2026-08-21) — 단추 글자 두 줄 접힘 방지 + [글자 축소/확대] 단추 모양.
     화면 크기와 무관하게 늘 적용된다(위 konet-notebook.css 는 노트북 전용 @media 라 큰 화면에서는 안 걸린다). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
