<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>종합 실적</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 쓰기 (전역 XLSX, 서식 포함) — 매출장과 같은 번들 --%>
<!--
  종합실적 (2026-11-11 신설 — 사용자 「홀세일에 있는 종합실적을 코네트 정보현황 메뉴 진행상황 밑에 추가」) — 정보 현황 ▸ 종합실적. 셸 iframe(logiFrame).
  홀세일 화면 그대로 : ① 조회줄(검색일자·담당사원·창고·상품) ② 구분 × 기간계/일계 표(매출·수금·수금할인·매입·지급·지급할인·지출 + 이익)
                       ③ 사원별 현황(기간별/일별) ④ [상세보기] 를 누르면 맨 아래에 그 구분의 전표 목록(일자마다 「일 계」 줄).
  · 자료는 /mangr/perfData.do 한 번 — 전표 낱줄(gb=SALE/RCV/PURCH/PAY) + 시작일 이전 사원별 누계(P_*) + 지출(월/일).
    기간계·일계·사원별·상세는 전부 이 화면이 그 줄들을 접어 만든다(서버 매퍼 selectPerfRows 머리말). 집계가 한 곳이라 표끼리 어긋나지 않는다.
  · 일계 = 검색 종료일 하루치. 시작일=종료일로 조회하면 기간계와 같다(홀세일과 같음).
  · 금액은 모두 <부가세 포함>(홀세일 판매금액과 같은 잣대) — 판매·매입 전표 TOT_AMT, 토더 = 부가세 포함 판매가, 정산서 = 정산서 금액 그대로.
    공급가·부가세는 전표에 적힌 값, 정산서·토더는 전표에 없어 합계 ÷ 1.1 로 환산(ROUND)해 보인다(psNorm). 상세보기의 공급가·부가세 칸·일계·합계에만(위 표는 합계만 — 2026-11-11).
  · 지출 = 월 비용(TBL_EXPENSE_TRX)의 일할(expSum 주석). [상세보기] = 귀속월 × 항목 줄에 월 비용·기간 일수·일할 반영액(psDtlExp), 날짜 적힌 내역은 참고로만. 이익금 = 매출 − 입고액(매입) − 지출액 − 수금할인.  사원별 전잔고 = 시작일 이전 (매출−매출DC) − (수금+매출할인), 현잔고 = 전잔고 + 기간분.
  · 돈 규칙은 일계장·거래처별 채권·채무와 같다 — 정산서·토더·판매전표·매입전표·수금/지급전표. 지출은 비용등록(월) 과 비용 내역(일).
  · 엑셀 = xlsx-js-style — 매출장(salesLedger.jsp ledgerSheet)과 같은 서식(제목·조회기간·하늘 머리글·테두리·크림 합계). 상단 단추는 종합실적·사원별 현황(+열린 상세), 상세 카드 단추는 그 목록만.
  · 인쇄 = 이 문서의 window.print() (iframe 안이라 Ctrl+P 는 바깥이 찍힌다). 서식은 엑셀과 같게(표마다 [제목]+조회기간, 하늘 머리글·검정 테두리·크림 합계), 상세는 새 쪽.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --ink:#1f2a37; --sub:#6b7a89; --sky:#d9edf7; --cream:#fcf8e3; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:var(--ink); background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  .hd{ display:flex; align-items:center; gap:10px; margin-bottom:8px; }
  .hd h2{ margin:0; font-size:20px; }
  .hd .sp{ flex:1; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; background:#fff; border:1px solid var(--bd); border-radius:10px; padding:9px 12px; }
  .bar .lbl{ font-size:12.5px; color:#37475a; font-weight:700; white-space:nowrap; }
  .bar input, .bar select{ height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .bar input[type=date]{ width:140px; }
  .btn{ height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-org{ background:#e8762b; color:#fff; border-color:#e8762b; }
  .btn-red{ background:#d9534f; color:#fff; border-color:#d9534f; }
  .btn-sm{ height:24px; padding:0 9px; font-size:12px; border-radius:5px; }
  .btn-blue{ background:#2f6fb3; color:#fff; border-color:#2f6fb3; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:11px 13px; margin-bottom:12px; }
  .card .tit{ display:flex; align-items:center; gap:8px; font-weight:800; margin-bottom:8px; }
  .card .tit small{ font-weight:600; color:var(--sub); font-size:12px; }
  .card .tit .sp{ flex:1; }
  table.g{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  table.g th{ background:var(--sky); color:var(--ink); font-weight:700; border:1px solid #9fb6c3; padding:6px 8px; text-align:center; }
  table.g td{ border:1px solid #c9d3dc; padding:5px 8px; text-align:right; }
  table.g td.lbl{ background:#eef3f6; text-align:center; font-weight:700; width:130px; }
  table.g td.txt{ text-align:left; }
  table.g td.ctr{ text-align:center; }
  table.g tr.tot td{ background:var(--cream); font-weight:800; }
  table.g tr.dsum td{ background:#f4f7fa; font-weight:700; color:#37475a; }
  table.g td.big{ font-size:14.5px; font-weight:700; }
  table.g td.neg, .neg{ color:var(--red); }
  table.g td.act{ text-align:left; width:1%; }
  .sumcell{ display:flex; align-items:center; gap:8px; justify-content:flex-end; }
  .sumcell b{ font-size:14.5px; min-width:150px; text-align:right; }
  .vat{ font-size:11.5px; color:#5a6b7a; font-weight:600; text-align:right; margin-top:1px; }
  .mini{ width:100%; border-collapse:collapse; }
  .mini th{ background:var(--sky); border:1px solid #9fb6c3; padding:4px 6px; font-size:12.5px; }
  .mini td{ border:1px solid #c9d3dc; padding:4px 6px; text-align:right; font-size:13px; }
  .tbwrap{ overflow:auto; border:1px solid var(--bd); border-radius:8px; }
  .tbwrap.dtl{ max-height:520px; }
  .tbwrap.dtl thead th{ position:sticky; top:0; z-index:2; }
  .msg{ padding:22px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  .note{ font-size:12px; color:var(--sub); line-height:1.7; margin-top:6px; }
  .pick{ position:fixed; z-index:50; background:#fff; border:1px solid var(--bd); border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,.18); width:560px; max-height:380px; overflow:auto; display:none; }
  .pick table{ width:100%; border-collapse:collapse; font-size:12.5px; }
  .pick th{ background:#eef3f6; padding:5px 7px; border-bottom:1px solid var(--bd); text-align:left; position:sticky; top:0; }
  .pick td{ padding:5px 7px; border-bottom:1px solid #eef1f4; cursor:pointer; white-space:nowrap; }
  .pick tr:hover td{ background:#f1f7f5; }
  .prn{ display:none; }   /* 인쇄용 머리(표마다) — 화면에서는 숨긴다 */
  @media print{
    /* ★margin:0 — 페이지 여백이 0이라야 브라우저가 제 머리글/바닥글(URL·쪽수)을 안 찍는다(일계장과 같음). 여백은 본문 padding 으로 */
    @page{ size:A4 landscape; margin:0; }
    body{ background:#fff; font-family:'굴림','Gulim','맑은 고딕',sans-serif; }
    .wrap{ padding:10mm 9mm; font-size:11px; }
    .noprint{ display:none !important; }
    .prn{ display:block; margin:0 0 6px; }
    .prn .t{ text-align:center; font-size:17pt; font-weight:800; margin:0 0 6px; }
    .prn .p{ font-size:9pt; border-bottom:1px solid #000; padding-bottom:2px; }
    .card{ border:0; padding:0; margin:0 0 14px; border-radius:0; background:#fff; }
    .card.pb{ page-break-before:always; }
    .tbwrap{ max-height:none !important; overflow:visible; border:0; border-radius:0; }
    table.g, .mini{ font-size:9pt; border-collapse:collapse; }
    table.g th, .mini th{ background:#D9EDF7 !important; border:1px solid #000 !important; color:#000; -webkit-print-color-adjust:exact; print-color-adjust:exact; position:static !important; }
    table.g td, .mini td{ border:1px solid #000 !important; color:#000; }
    table.g td.lbl{ background:#fff !important; }
    table.g tr.tot td{ background:#FCF8E3 !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    table.g tr.dsum td{ background:#F2F2F2 !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    table.g td.neg, .neg{ color:#C0392B !important; }
    .sumcell b{ font-size:9pt; min-width:0; }
    table.g td.big{ font-size:9pt; }
    tr{ page-break-inside:avoid; }
    thead{ display:table-header-group; }
  }
</style>
</head>
<body>
<div class="wrap">
  <div class="hd noprint">
    <h2>📊 종합 실적</h2>
    <span class="sp"></span>
    <button class="btn btn-red" onclick="psXls('all')">엑셀 다운로드</button>
    <button class="btn btn-org" onclick="psPrint()">인쇄</button>
  </div>

  <div class="bar noprint">
    <span class="lbl">검색일자 :</span>
    <input type="date" id="psFr"> <span class="lbl">~</span> <input type="date" id="psTo">
    <span class="lbl">담당사원 :</span>
    <select id="psMgr"><option value="">전체</option></select>
    <span class="lbl">창고 :</span>
    <select id="psWh"><option value="">선택</option></select>
    <span class="lbl">상품 :</span>
    <input type="text" id="psProd" placeholder="상품코드·상품명" style="width:150px" title="상품코드 그대로, 또는 이름 일부를 넣고 [상품]">
    <span id="psProdNm" style="font-size:12.5px; color:var(--sub); max-width:220px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap"></span>
    <button class="btn btn-teal" onclick="psProdPick()">상품</button>
    <button class="btn btn-org" onclick="psLoad()">리스트조회</button>
    <button class="btn" onclick="psQuick('m')" title="이번 달 1일 ~ 오늘">이번달</button>
    <button class="btn" onclick="psQuick('d')" title="오늘 하루">오늘</button>
    <button class="btn" onclick="psQuick('y')" title="올해 1월 1일 ~ 오늘">올해</button>
    <span id="psStamp" style="margin-left:auto; color:#8a98a8; font-size:12px"></span>
  </div>

  <div class="card">
    <div class="prn" id="prn1"></div>
    <div class="tbwrap"><table class="g" id="psSum"></table></div>
    <div class="note noprint">· 금액은 모두 <b>부가세 포함</b>(판매·매입 전표 합계, 토더 포함가, 정산서 금액). 공급가·부가세는 [상세보기] 목록에서 — 정산서·토더는 전표에 세액이 없어 ÷1.1 환산값 · 일계 = 검색 종료일 하루치(시작일=종료일이면 기간계와 같음) · 지출 = 비용등록의 월 비용을 일할(그 달 금액 ÷ 일수 × 기간 일수, 한 달 전체면 월 금액 그대로) · 이익금 = 매출 − 입고액(매입) − 지출액 − 수금할인
      · 창고를 고르면 창고가 적힌 판매·매입 전표만 그 창고로, 정산서·토더·창고 없는 전표는 기본 창고로 봅니다(수금·지급은 창고와 무관)
      · 상품을 고르면 판매·매입은 그 상품 줄의 금액만, 수금·지급·지출은 비웁니다.</div>
  </div>

  <div class="card">
    <div class="prn" id="prn2"></div>
    <div class="tit noprint">※ 사원별 현황 <small>(서비스 금액기준 : 상품 판매단가 · DC = 매출DC + 수금 시 매출할인 · 전잔고 = 검색 시작일 전 받을금액 · 현잔고 = 종료일 현재)</small></div>
    <div class="tbwrap"><table class="g" id="psEmp"></table></div>
  </div>

  <div class="card pb" id="psDtlCard" style="display:none">
    <div class="prn" id="prn3"></div>
    <div class="tit noprint"><span id="psDtlTit">상세</span><span class="sp"></span>
      <button class="btn btn-red btn-sm" onclick="psXls('dtl')">엑셀 다운로드</button>
      <button class="btn btn-org btn-sm" onclick="psPrint()">인쇄</button>
      <button class="btn btn-sm" onclick="psDtlClose()">닫기</button></div>
    <div class="tbwrap dtl"><table class="g" id="psDtl"></table></div>
  </div>
</div>

<div class="pick" id="psPick"></div>

<script>
var CTX='${pageContext.request.contextPath}';
var _rows=[], _expM=[], _expD=[], _dtlGb='', _fr8='', _to8='', _mgrs=[], _whs=[];
var _agg=null, _emp=null;   /* 마지막 집계(기간·일계·지출) · 사원별 목록 — 화면 표와 엑셀이 같은 값을 쓴다 */

function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ v=Math.round(n(v)); return v.toLocaleString(); }
function fc(v){ v=Math.round(n(v)); return '<td'+(v<0?' class="neg"':'')+'>'+v.toLocaleString()+'</td>'; }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d8(s){ return String(s||'').replace(/-/g,''); }
function dl(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function gv(id){ return document.getElementById(id).value||''; }
function post(url, body){
  return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body||'' })
    .then(function(r){ return r.json(); })
    .then(function(j){ if(j && j.error) throw new Error(j.error); return j; });
}
function alertBox(msg, opt){ if(window._alertBox) _alertBox(msg, opt||{icon:'ℹ️'}); else alert(msg.replace(/<[^>]+>/g,'')); }

/* ───────── 초기화 — 올해 1/1 ~ 오늘, 담당사원·창고 목록 ───────── */
(function init(){
  var t=new Date(); document.getElementById('psTo').value=ymd(t);
  document.getElementById('psFr').value=t.getFullYear()+'-01-01';
  document.getElementById('psSum').innerHTML='<tbody><tr><td class="msg">조회 조건을 고르고 [리스트조회]를 누르세요.</td></tr></tbody>';
  document.getElementById('psEmp').innerHTML='';
  post('/mangr/perfInit.do').then(function(j){
    _mgrs=j.mgrs||[]; _whs=j.whs||[];
    var s=document.getElementById('psMgr'), h='<option value="">전체</option>';
    /* 직원(로그인 계정)이 기준 — 전표에 남은 옛 거래처 담당자코드(001 김동근 …)는 「옛 코드」로 뒤에 (2026-11-11) */
    _mgrs.forEach(function(m){ h+='<option value="'+esc(m.mgrCd)+'">'+esc(m.mgrCd)+' : '+esc(m.mgrNm)+(m.kind==='O'?' (옛 코드)':'')+'</option>'; }); s.innerHTML=h;
    var w=document.getElementById('psWh'), hw='<option value="">선택</option>';
    _whs.forEach(function(x){ hw+='<option value="'+esc(x.whCd)+'">'+esc(x.whNm)+(x.defaultYn==='Y'?' (기본)':'')+'</option>'; }); w.innerHTML=hw;
    psLoad();
  }).catch(function(e){ alertBox('목록을 불러오지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>', {icon:'❌', okColor:'red'}); });
  document.getElementById('psProd').addEventListener('keydown', function(e){ if(e.key==='Enter'){ e.preventDefault(); psProdPick(); } });
  document.getElementById('psProd').addEventListener('input', function(){ document.getElementById('psProdNm').textContent=''; });
  document.addEventListener('click', function(e){ var p=document.getElementById('psPick'); if(p.style.display==='block' && !p.contains(e.target) && e.target.id!=='psProd') p.style.display='none'; });
  ['psFr','psTo'].forEach(function(id){ document.getElementById(id).addEventListener('keydown', function(e){ if(e.key==='Enter') psLoad(); }); });
})();
function psQuick(k){
  var t=new Date(), fr=new Date(t);
  if(k==='m') fr=new Date(t.getFullYear(), t.getMonth(), 1);
  else if(k==='y') fr=new Date(t.getFullYear(), 0, 1);
  document.getElementById('psFr').value=ymd(fr); document.getElementById('psTo').value=ymd(t); psLoad();
}

/* ───────── 상품 고르기 — 코드 그대로면 바로, 아니면 이름 검색 목록 ───────── */
function psProdPick(){
  var q=gv('psProd').trim(), box=document.getElementById('psPick');
  if(!q){ document.getElementById('psProdNm').textContent=''; box.style.display='none'; return; }
  post('/prod/prodList.do', 'findData='+encodeURIComponent(q)).then(function(j){
    var list=(j&&j.data)||[];
    list=list.filter(function(p){ var c=String(p.prodCd||''), nm=String(p.prodNm||''); return c.indexOf(q)>=0 || nm.toLowerCase().indexOf(q.toLowerCase())>=0; });
    var exact=list.filter(function(p){ return String(p.prodCd||'')===q; });
    if(exact.length===1){ psProdSet(exact[0]); return; }
    if(!list.length){ alertBox('「'+esc(q)+'」 에 맞는 상품이 없습니다.'); return; }
    var h='<table><thead><tr><th>상품코드</th><th>상품명</th><th>규격</th></tr></thead><tbody>';
    list.slice(0,200).forEach(function(p,i){ h+='<tr data-i="'+i+'"><td>'+esc(p.prodCd)+'</td><td>'+esc(p.prodNm)+'</td><td>'+esc(p.spec||'')+'</td></tr>'; });
    box.innerHTML=h+'</tbody></table>'; box._list=list.slice(0,200);
    var r=document.getElementById('psProd').getBoundingClientRect();
    box.style.left=Math.max(8, Math.min(r.left, window.innerWidth-575))+'px'; box.style.top=(r.bottom+4)+'px'; box.style.display='block';
    box.querySelectorAll('tr[data-i]').forEach(function(tr){ tr.onclick=function(){ psProdSet(box._list[+tr.getAttribute('data-i')]); box.style.display='none'; }; });
  }).catch(function(e){ alertBox('상품 검색 실패<br>'+esc(e.message), {icon:'❌', okColor:'red'}); });
}
function psProdSet(p){ document.getElementById('psProd').value=p.prodCd||''; document.getElementById('psProdNm').textContent=(p.prodNm||'')+(p.spec?' / '+p.spec:''); }

/* ───────── 조회 ───────── */
function psLoad(){
  var fr=gv('psFr'), to=gv('psTo');
  if(!fr||!to){ alertBox('검색일자를 넣으세요.'); return; }
  if(fr>to){ alertBox('시작일이 종료일보다 늦습니다.'); return; }
  var prod=gv('psProd').trim();
  /* 이름만 쳐 두고 조회를 누른 경우 — 먼저 상품을 고르게 한다(코드 꼴이면 그대로 조회) */
  if(prod && !document.getElementById('psProdNm').textContent && !/^\d{6,}$/.test(prod)){ psProdPick(); return; }
  document.getElementById('psStamp').textContent='조회 중…';
  post('/mangr/perfData.do', 'frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)+'&mgrCd='+encodeURIComponent(gv('psMgr'))
       +'&whCd='+encodeURIComponent(gv('psWh'))+'&prodCd='+encodeURIComponent(prod))
    .then(function(j){
      _rows=(j.rows||[]).map(psNorm); _expM=j.expM||[]; _expD=j.expD||[]; _fr8=d8(fr); _to8=d8(to);
      psRender(); if(_dtlGb) psDtl(_dtlGb, true);
      document.getElementById('psStamp').textContent='조회 '+ymd(new Date())+' · 전표 '+_rows.filter(function(r){ return r.src!=='PREV'; }).length.toLocaleString()+'줄';
    })
    .catch(function(e){ document.getElementById('psStamp').textContent='오류'; alertBox('조회에 실패했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>', {icon:'❌', okColor:'red'}); });
}

/* 정산서·토더 줄은 전표에 공급가·부가세가 없다 → 합계(부가세 포함) ÷ 1.1 환산. 전표 줄은 적힌 값 그대로 */
function psNorm(r){
  if((r.src==='STMT'||r.src==='TD') && (r.gb==='SALE'||r.gb==='PURCH')){ var a=n(r.amt), sup=Math.round(a/1.1); r.supplyAmt=sup; r.vatAmt=a-sup; r.vatCalc=true; }
  return r;
}
/* 수금/지급 방법 → 현금·무통장·카드·기타 */
function payKind(g){ g=String(g||''); if(g.indexOf('현금')>=0) return 'cash'; if(g.indexOf('카드')>=0) return 'card'; if(g.indexOf('무통장')>=0||g.indexOf('계좌')>=0) return 'bank'; return 'etc'; }

/* 한 묶음(기간 또는 하루)의 합 */
function sumOf(rows){
  var s={ sale:0, saleDc:0, svc:0, saleSup:0, saleVat:0, rcv:0, rcvDc:0, rcvSaleDc:0, purch:0, purchDc:0, purchSup:0, purchVat:0, pay:0, payDc:0, cash:0, bank:0, card:0, etc:0, pcash:0, pbank:0, pcard:0, petc:0 };
  rows.forEach(function(r){
    var a=n(r.amt), dc=n(r.dcAmt);
    if(r.gb==='SALE'){ s.sale+=a; s.saleDc+=dc; s.svc+=n(r.svcAmt); s.saleSup+=n(r.supplyAmt); s.saleVat+=n(r.vatAmt); }
    else if(r.gb==='RCV'){ s.rcv+=a; s.rcvDc+=dc; s.rcvSaleDc+=n(r.saleDcAmt); s[payKind(r.payGb)]+=a; }
    else if(r.gb==='PURCH'){ s.purch+=a; s.purchDc+=dc; s.purchSup+=n(r.supplyAmt); s.purchVat+=n(r.vatAmt); }
    else if(r.gb==='PAY'){ s.pay+=a; s.payDc+=dc; s['p'+payKind(r.payGb)]+=a; }
  });
  return s;
}
/* 지출 = 월 비용(비용등록)을 <일할>로 (2026-11-11 사용자 「표시부분 차이」 — 하루 조회에 기간계는 한 달치 75,137,108, 일계는 0 으로 갈렸다).
   비용은 월 단위 자료라 날짜가 없다 → 그 달 금액 ÷ 그 달 일수 × 기간에 든 일수. 한 달 전체면 월 금액 그대로, 하루면 1/일수.
   일계도 같은 식(종료일이 든 달의 1일분)이라 시작일=종료일이면 기간계와 같다. 비용 내역(_expD)의 날짜는 쓰지 않는다 — 9월분이 01-01 로 남는 등 날짜가 믿을 만하지 않다. */
function dim(ym){ return new Date(+ym.slice(0,4), +ym.slice(4,6), 0).getDate(); }
function expSum(day){
  var t=0;
  if(day){ var ym=_to8.slice(0,6); _expM.forEach(function(e){ if(String(e.ym||'')===ym) t+=n(e.amt)/dim(ym); }); return Math.round(t); }
  _expM.forEach(function(e){ var ym=String(e.ym||''), D=dim(ym), a=ym+'01', b=ym+('0'+D).slice(-2);
    var lo=(_fr8>a?_fr8:a), hi=(_to8<b?_to8:b); if(lo>hi) return;
    var days=Math.round((new Date(+hi.slice(0,4),+hi.slice(4,6)-1,+hi.slice(6,8))-new Date(+lo.slice(0,4),+lo.slice(4,6)-1,+lo.slice(6,8)))/86400000)+1;
    t+=n(e.amt)*days/D; });
  return Math.round(t);
}

function psRender(){
  var P=_rows.filter(function(r){ return r.src!=='PREV'; }), D=P.filter(function(r){ return String(r.dt||'')===_to8; });
  var p=sumOf(P), d=sumOf(D), pe=expSum(false), de=expSum(true);
  _agg={ p:p, d:d, pe:pe, de:de };
  var same=(_fr8===_to8);
  function dtlBtn(gb){ return '<button class="btn btn-blue btn-sm noprint" onclick="psDtl(\''+gb+'\')">상세보기</button>'; }
  function sub(sv){ return sv ? '<div class="vat">공급가 '+fmt(sv[0])+' · 부가세 '+fmt(sv[1])+'</div>' : ''; }
  function cell(v, gb, sv){ return '<td><div class="sumcell"><b'+(Math.round(v)<0?' class="neg"':'')+'>'+fmt(v)+'</b>'+(gb?dtlBtn(gb):'')+'</div>'+sub(sv)+'</td>'; }
  function cellR(v, sv){ return '<td class="big'+(Math.round(v)<0?' neg':'')+'">'+fmt(v)+sub(sv)+'</td>'; }
  var h='<thead><tr><th style="width:130px">구분</th><th>기간계 <small style="font-weight:600">('+dl(_fr8)+' ~ '+dl(_to8)+' · 부가세 포함)</small></th><th>일계 <small style="font-weight:600">('+dl(_to8)+(same?' · 기간계와 같음':'')+' · 부가세 포함)</small></th></tr></thead><tbody>';
  var rows=[ ['매 출', p.sale, d.sale, 'SALE', [p.saleSup,p.saleVat], [d.saleSup,d.saleVat]], ['수 금', p.rcv, d.rcv, 'RCV'], ['수금할인', p.rcvDc, d.rcvDc, ''],
             ['매 입', p.purch, d.purch, 'PURCH', [p.purchSup,p.purchVat], [d.purchSup,d.purchVat]], ['지 급', p.pay, d.pay, 'PAY'], ['지급할인', p.payDc, d.payDc, ''], ['지 출', pe, de, 'EXP'] ];
  /* 공급가·부가세는 [상세보기] 목록(줄·일계·합계)에 있으니 여기엔 합계만 (2026-11-11 사용자 「위에 공급가 부가세 표시 제거」) */
  rows.forEach(function(r){ h+='<tr><td class="lbl">'+r[0]+'</td>'+cell(r[1], r[3])+cellR(r[2])+'</tr>'; });
  function profit(s, e){ return s.sale - s.purch - e - s.rcvDc; }
  function miniTb(s, e){
    return '<table class="mini"><thead><tr><th>매출</th><th>입고액</th><th>지출액</th><th>수금할인</th><th>이익금</th></tr></thead><tbody><tr>'
         + fc(s.sale)+fc(s.purch)+fc(e)+fc(s.rcvDc)+fc(profit(s,e)).replace('<td','<td style="font-weight:800"')+'</tr></tbody></table>';
  }
  h+='<tr><td class="lbl">이 익</td><td style="padding:4px">'+miniTb(p,pe)+'</td><td style="padding:4px">'+miniTb(d,de)+'</td></tr>';
  document.getElementById('psSum').innerHTML=h+'</tbody>';
  prnHead('prn1','종합 실적'); prnHead('prn2','사원별 현황');
  psRenderEmp(P, D);
}

/* ───────── 사원별 현황 — 기간별 / 일별(종료일) ───────── */
function psRenderEmp(P, D){
  var M={}, ord=[];
  /* 담당자코드가 빈 줄은 전부 「(담당 없음)」 한 줄로 (2026-11-11 사용자 「이정호 확인」 — 코드 없이 이름만 적힌 거래처(이정호·김연태 과장)와 담당자 없는 거래처(토더·동원·모두상사)가
     같은 빈 코드 묶음인데 첫 줄 이름(이정호)으로 보여 그 사람 매출처럼 읽혔다). 이름들은 말풍선에 모아 보인다 */
  function get(cd, nm){ var k=String(cd||''); if(!M[k]){ M[k]={ cd:k, nm:(k? (nm||k) : '(담당 없음)'), nms:{}, p:null, d:null, prev:0, pr:[], dr:[] }; ord.push(k); } if(nm) M[k].nms[nm]=1; return M[k]; }
  _rows.forEach(function(r){
    var o=get(r.mgrCd, r.mgrNm);
    if(r.src==='PREV'){
      if(r.gb==='P_SALE') o.prev += n(r.amt)-n(r.dcAmt);
      else if(r.gb==='P_RCV') o.prev -= n(r.amt)+n(r.saleDcAmt);
    } else { o.pr.push(r); if(String(r.dt||'')===_to8) o.dr.push(r); }
  });
  _mgrs.forEach(function(m){ if(M[m.mgrCd]) M[m.mgrCd].nm=m.mgrNm||M[m.mgrCd].nm; });
  var list=ord.map(function(k){ var o=M[k]; o.p=sumOf(o.pr); o.d=sumOf(o.dr);
    o.cur = o.prev + (o.p.sale - o.p.saleDc) - (o.p.rcv + o.p.rcvSaleDc); return o; });
  list.sort(function(a,b){ return (a.cd||'~~').localeCompare(b.cd||'~~'); });   /* 빈 코드(담당 없음)는 맨 뒤 */
  var T={ p:sumOf(P), d:sumOf(D), prev:0, cur:0 }; list.forEach(function(o){ T.prev+=o.prev; T.cur+=o.cur; });
  _emp={ list:list, T:T };
  function seg(s, bal, isCur){ return fc(s.sale)+fc(s.svc)+fc(s.saleDc+s.rcvSaleDc)+fc(s.rcv)+fc(s.cash)+fc(s.bank)+fc(s.card)+fc(s.etc)+fc(s.rcvDc)+fc(bal).replace('<td','<td style="font-weight:700"'); }
  var h='<thead><tr><th rowspan="2" style="width:110px">담당사원</th><th colspan="10">기간별</th><th colspan="10">일별 <small style="font-weight:600">('+dl(_to8)+')</small></th></tr>'
       +'<tr><th>매출</th><th>서비스</th><th>DC</th><th>수금합계</th><th>현금</th><th>무통장</th><th>카드</th><th>기타</th><th>할인</th><th>전잔고</th>'
       +'<th>매출</th><th>서비스</th><th>DC</th><th>수금합계</th><th>현금</th><th>무통장</th><th>카드</th><th>기타</th><th>할인</th><th>현잔고</th></tr></thead><tbody>';
  if(!list.length) h+='<tr><td class="msg" colspan="21">자료가 없습니다.</td></tr>';
  list.forEach(function(o){ var tip=o.cd? o.cd : ('담당자코드가 없는 전표 — 거래처 관리에서 담당자를 고르면 그 직원 줄로 갑니다'+(Object.keys(o.nms).length?' · 이름만 적힌 것: '+Object.keys(o.nms).join(', '):'')); h+='<tr><td class="ctr" title="'+esc(tip)+'"'+(o.cd?'':' style="color:#8a98a8"')+'>'+esc(o.nm)+'</td>'+seg(o.p, o.prev)+seg(o.d, o.cur, true)+'</tr>'; });
  h+='<tr class="tot"><td class="ctr">합 계</td>'+seg(T.p, T.prev)+seg(T.d, T.cur, true)+'</tr>';
  document.getElementById('psEmp').innerHTML=h+'</tbody>';
}

/* ───────── 상세보기 — 그 구분의 전표 목록, 일자마다 「일 계」 ───────── */
var GBL={ SALE:'매출', RCV:'수금', PURCH:'매입', PAY:'지급', EXP:'지출' };
/* 지출 상세 재료 — 귀속월 × 항목 줄에 일할을 붙인다(기간 일수·그 달 일수·반영액). 종료일 하루분(일계)도 같이 */
function expRows(){
  return _expM.map(function(e){ var ym=String(e.ym||''), D=dim(ym), a=ym+'01', b=ym+('0'+D).slice(-2);
    var lo=(_fr8>a?_fr8:a), hi=(_to8<b?_to8:b), days=lo>hi?0:Math.round((new Date(+hi.slice(0,4),+hi.slice(4,6)-1,+hi.slice(6,8))-new Date(+lo.slice(0,4),+lo.slice(4,6)-1,+lo.slice(6,8)))/86400000)+1;
    return { ym:ym, itemCd:e.itemCd, itemNm:e.itemNm||e.itemCd, itemGb:e.itemGb||'', amt:n(e.amt), remark:e.remark||'', D:D, days:days, per:Math.round(n(e.amt)*days/D), day:(ym===_to8.slice(0,6)?Math.round(n(e.amt)/D):0) }; });
}
function psDtlExp(keep){
  var rows=expRows(), h='<thead><tr><th>귀속월</th><th>항목</th><th>구분</th><th>월 비용</th><th>기간 일수 / 월 일수</th><th>기간 반영액(일할)</th><th>일계('+dl(_to8)+')</th><th>비고</th></tr></thead><tbody>';
  var cur='', ms={a:0,per:0,day:0}, T={a:0,per:0,day:0}, cnt=0;
  function ml(){ return '<tr class="dsum"><td class="txt" colspan="3">월 계</td>'+fc(ms.a)+'<td></td>'+fc(ms.per)+fc(ms.day)+'<td></td></tr>'; }
  rows.forEach(function(r){
    if(cur && r.ym!==cur){ h+=ml(); ms={a:0,per:0,day:0}; }
    cur=r.ym; cnt++; ms.a+=r.amt; ms.per+=r.per; ms.day+=r.day; T.a+=r.amt; T.per+=r.per; T.day+=r.day;
    h+='<tr><td class="ctr">'+r.ym.slice(0,4)+'-'+r.ym.slice(4,6)+'</td><td class="txt">'+esc(r.itemNm)+'</td><td class="ctr">'+(r.itemGb==='FIX'?'고정':(r.itemGb==='VAR'?'변동':esc(r.itemGb)))+'</td>'+fc(r.amt)+'<td class="ctr">'+r.days+' / '+r.D+'</td>'+fc(r.per)+fc(r.day)+'<td class="txt">'+esc(r.remark)+'</td></tr>';
  });
  if(cur) h+=ml();
  h+='<tr class="tot"><td class="txt" colspan="3">합 계 ('+cnt+'줄)</td>'+fc(T.a)+'<td></td>'+fc(T.per)+fc(T.day)+'<td></td></tr>';
  if(!rows.length) h+='<tr><td class="msg" colspan="8">이 기간에 걸친 달의 비용등록이 없습니다.</td></tr>';
  /* 참고 — 기간 안 날짜가 적힌 비용 내역(귀속월이 그 날짜의 달인 줄만). 집계엔 안 쓰고 보기만 */
  var dl2=_expD.filter(function(e){ return String(e.dt||'')>=_fr8 && String(e.dt||'')<=_to8; });
  if(dl2.length){
    h+='<tr class="dsum"><td class="txt" colspan="8">참고 · 기간 안 날짜가 적힌 비용 내역 '+dl2.length+'줄 (집계는 위 일할 기준 — 내역은 보기만)</td></tr>';
    var dt=0; dl2.forEach(function(e){ dt+=n(e.amt); h+='<tr><td class="ctr">'+dl(e.dt)+'</td><td class="txt">'+esc(e.itemNm||e.itemCd)+'</td><td class="ctr">'+(e.chkYn==='Y'?'확인':'')+'</td><td class="txt" colspan="2">'+esc(e.title)+'</td>'+fc(n(e.amt))+'<td></td><td class="txt">'+esc(e.remark)+'</td></tr>'; });
    h+='<tr class="dsum"><td class="txt" colspan="5">내역 합</td>'+fc(dt)+'<td></td><td></td></tr>';
  }
  document.getElementById('psDtl').innerHTML=h+'</tbody>';
  document.getElementById('psDtlTit').textContent='📋 지출 상세 · '+dl(_fr8)+' ~ '+dl(_to8)+' · 월 비용 '+cnt+'줄';
  prnHead('prn3', '지출 상세');
  var card=document.getElementById('psDtlCard'); card.style.display='block';
  if(!keep) card.scrollIntoView({behavior:'smooth', block:'start'});
}
function psDtl(gb, keep){
  _dtlGb=gb;
  if(gb==='EXP'){ psDtlExp(keep); return; }
  var rows=_rows.filter(function(r){ return r.gb===gb; });
  rows.sort(function(a,b){ return (a.dt+a.custCd+a.trxNo).localeCompare(b.dt+b.custCd+b.trxNo); });
  var money=(gb==='RCV'||gb==='PAY');
  var dtLbl={SALE:'매출일자', RCV:'수금일자', PURCH:'매입일자', PAY:'지급일자'}[gb];
  var cols = money ? [dtLbl,'코드','거래처코드','거래처명','담당사원','현금', gb==='RCV'?'무통장입금':'무통장지급','카드','기타','할인','합계']
                   : [dtLbl,'코드','거래처코드','거래처명','담당사원','공급가','부가세','합계','DC'];
  var h='<thead><tr>'+cols.map(function(c){ return '<th>'+c+'</th>'; }).join('')+'</tr></thead><tbody>';
  var cur='', cnt=0, dayRows=[];
  function line(r){ var s=sumOf([r]); return money ? fc(s.cash+s.pcash)+fc(s.bank+s.pbank)+fc(s.card+s.pcard)+fc(s.etc+s.petc)+fc(s.rcvDc+s.payDc)+fc(n(r.amt))
                                                   : fc(n(r.supplyAmt)).replace('<td', r.vatCalc?'<td title="정산서·토더는 전표에 세액이 없어 합계 ÷ 1.1 로 환산한 값" style="color:#6b7a89"':'<td')+fc(n(r.vatAmt)).replace('<td', r.vatCalc?'<td title="환산값" style="color:#6b7a89"':'<td')+fc(n(r.amt))+fc(n(r.dcAmt)); }
  function sumLine(s, lbl, cls){ return '<tr class="'+cls+'"><td class="txt" colspan="5">'+lbl+'</td>'
      +(money ? fc(s.cash+s.pcash)+fc(s.bank+s.pbank)+fc(s.card+s.pcard)+fc(s.etc+s.petc)+fc(s.rcvDc+s.payDc)+fc(gb==='RCV'?s.rcv:s.pay)
              : fc(gb==='SALE'?s.saleSup:s.purchSup)+fc(gb==='SALE'?s.saleVat:s.purchVat)+fc(gb==='SALE'?s.sale:s.purch)+fc(gb==='SALE'?s.saleDc:s.purchDc))+'</tr>'; }
  rows.forEach(function(r){
    if(cur && r.dt!==cur){ h+=sumLine(sumOf(dayRows), '일 계', 'dsum'); dayRows=[]; }
    cur=r.dt; dayRows.push(r); cnt++;
    h+='<tr><td class="ctr">'+dl(r.dt)+'</td><td class="ctr">'+esc(r.trxNo)+(r.payGb?' <small style="color:#6b7a89">'+esc(r.payGb)+'</small>':'')+'</td><td class="ctr">'+esc(r.custCd)+'</td><td class="txt">'+esc(r.custNm)+'</td><td class="ctr">'+esc(r.mgrNm)+'</td>'+line(r)+'</tr>';
  });
  if(cur) h+=sumLine(sumOf(dayRows), '일 계', 'dsum');
  h+=sumLine(sumOf(rows), '합 계 ('+cnt.toLocaleString()+'건)', 'tot');
  if(!rows.length) h+='<tr><td class="msg" colspan="'+cols.length+'">'+GBL[gb]+' 전표가 없습니다.</td></tr>';
  document.getElementById('psDtl').innerHTML=h+'</tbody>';
  document.getElementById('psDtlTit').textContent='📋 '+GBL[gb]+' 상세 · '+dl(_fr8)+' ~ '+dl(_to8)+' · '+cnt.toLocaleString()+'건';
  prnHead('prn3', GBL[gb]+' 상세');
  var card=document.getElementById('psDtlCard'); card.style.display='block';
  if(!keep) card.scrollIntoView({behavior:'smooth', block:'start'});
}
function psDtlClose(){ _dtlGb=''; document.getElementById('psDtlCard').style.display='none'; }

/* ───────── 엑셀 — 매출장(salesLedger.jsp ledgerSheet)과 같은 서식 : 굴림 9 · 제목 17 굵게 가운데(2줄 병합) · 조회기간 줄(밑줄) · 머리글 하늘 · 본문 테두리 · 일계 연회색 · 합계 크림 ───────── */
function xE(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; }
function xW(s){ var w=0; String(s||'').split('').forEach(function(ch){ w+=(ch.charCodeAt(0)>255?1.8:1); }); return w; }
/* aoa + kinds('t'제목 'b'빈줄 'p'기간 'h'머리 'row' 'dsum' 'tot') → 서식 입힌 시트. numCols = 숫자(#,##0) 칸 번호, merges 추가분 */
function xSheet(aoa, kinds, ncol, numCols, merges, cols){
  var bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd }, ws=XLSX.utils.aoa_to_sheet(aoa);
  for(var r=0;r<aoa.length;r++){ var k=kinds[r];
    for(var cc=0;cc<ncol;cc++){ var ref=XLSX.utils.encode_cell({ r:r, c:cc }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'굴림', sz:17, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='b'){ }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else {
        st.border=box; st.fill={ fgColor:{ rgb:(k==='tot'?'FCF8E3':(k==='dsum'?'F2F2F2':'FFFFFF')) } };
        if(k!=='row') st.font.bold=true;
        st.alignment.horizontal = numCols.indexOf(cc)>=0 ? 'right' : (k!=='row' && cc===0 ? 'center' : 'left');
        if(ws[ref].t==='n' && numCols.indexOf(cc)>=0) ws[ref].z='#,##0';
        if(ws[ref].t==='n' && ws[ref].v<0) st.font.color={ rgb:'C0392B' };
      }
      ws[ref].s=st; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:ncol-1 } }, { s:{ r:2, c:0 }, e:{ r:2, c:ncol-1 } } ].concat(merges||[]);
  ws['!cols']=cols.map(function(w){ return { wch:w }; });
  ws['!rows']=aoa.map(function(a,i){ return { hpt:(i<2?18.75:16.5) }; });
  return ws;
}
function xPeriod(){ return '조회기간 : '+dl(_fr8)+' ~ '+dl(_to8)+(gv('psMgr')?'   담당사원 : '+document.getElementById('psMgr').selectedOptions[0].textContent:'')+(gv('psWh')?'   창고 : '+document.getElementById('psWh').selectedOptions[0].textContent:'')+(gv('psProd')?'   상품 : '+gv('psProd')+' '+document.getElementById('psProdNm').textContent:''); }
function xHead(title, ncol){ return { aoa:[ ['['+title+']'].concat(xE(ncol-1)), xE(ncol), [xPeriod()].concat(xE(ncol-1)) ], kinds:['t','t','p'] }; }
/* 인쇄 머리 — 표마다 「[제목]」 + 조회기간 (엑셀 시트 1~3행과 같은 모양) */
function prnHead(id, title){ document.getElementById(id).innerHTML='<div class="t">['+esc(title)+']</div><div class="p">'+esc(xPeriod())+'</div>'; }
/* ① 종합실적 — 구분 × 기간계/일계 + 이익 표 */
function xsSummary(){
  var A=_agg, H=xHead('종합 실적', 6), aoa=H.aoa, kinds=H.kinds;
  aoa.push(['구분','기간계 ('+dl(_fr8)+' ~ '+dl(_to8)+')','일계 ('+dl(_to8)+')','','','']); kinds.push('h');
  [['매출 (부가세 포함)',A.p.sale,A.d.sale,'dsum'],['수금',A.p.rcv,A.d.rcv,'dsum'],['수금할인',A.p.rcvDc,A.d.rcvDc,'dsum'],
   ['매입 (부가세 포함)',A.p.purch,A.d.purch,'dsum'],['지급',A.p.pay,A.d.pay,'dsum'],['지급할인',A.p.payDc,A.d.payDc,'dsum'],['지출',A.pe,A.de,'dsum']]
    .forEach(function(r){ aoa.push([r[0],r[1],r[2],'','','']); kinds.push(r[3]); });
  aoa.push(xE(6)); kinds.push('b');
  aoa.push(['이익','매출','입고액','지출액','수금할인','이익금']); kinds.push('h');
  aoa.push(['기간계',A.p.sale,A.p.purch,A.pe,A.p.rcvDc,A.p.sale-A.p.purch-A.pe-A.p.rcvDc]); kinds.push('row');
  aoa.push(['일계',A.d.sale,A.d.purch,A.de,A.d.rcvDc,A.d.sale-A.d.purch-A.de-A.d.rcvDc]); kinds.push('tot');
  var mg=[]; for(var r=3;r<11;r++){ mg.push({ s:{ r:r, c:2 }, e:{ r:r, c:5 } }); }
  return xSheet(aoa, kinds, 6, [1,2,3,4,5], mg, [18,22,14,14,14,14]);
}
/* ② 사원별 현황 — 머리 2줄(기간별/일별 병합) */
function xsEmp(){
  var E=_emp, H=xHead('사원별 현황', 21), aoa=H.aoa, kinds=H.kinds;
  aoa.push(['담당사원','기간별'].concat(xE(9)).concat(['일별 ('+dl(_to8)+')']).concat(xE(9))); kinds.push('h');
  var c=['매출','서비스','DC','수금합계','현금','무통장','카드','기타','할인'];
  aoa.push([''].concat(c,['전잔고'],c,['현잔고'])); kinds.push('h');
  function seg(s,bal){ return [s.sale,s.svc,s.saleDc+s.rcvSaleDc,s.rcv,s.cash,s.bank,s.card,s.etc,s.rcvDc,bal]; }
  E.list.forEach(function(o){ aoa.push([o.nm||'(담당 없음)'].concat(seg(o.p,o.prev),seg(o.d,o.cur))); kinds.push('row'); });
  aoa.push(['합 계'].concat(seg(E.T.p,E.T.prev),seg(E.T.d,E.T.cur))); kinds.push('tot');
  var nums=[]; for(var i=1;i<21;i++) nums.push(i);
  var mg=[ { s:{ r:3, c:0 }, e:{ r:4, c:0 } }, { s:{ r:3, c:1 }, e:{ r:3, c:10 } }, { s:{ r:3, c:11 }, e:{ r:3, c:20 } } ];
  var cols=[11]; for(var j=0;j<20;j++) cols.push(12);
  return xSheet(aoa, kinds, 21, nums, mg, cols);
}
/* ③ 상세 — 화면의 상세보기와 같은 줄(일계·합계 포함) */
/* 지출 상세 시트 — 화면 psDtlExp 와 같은 줄 */
function xsDtlExp(){
  var rows=expRows(), H=xHead('지출 상세', 8), aoa=H.aoa, kinds=H.kinds;
  aoa.push(['귀속월','항목','구분','월 비용','기간 일수','월 일수','기간 반영액(일할)','일계('+dl(_to8)+')']); kinds.push('h');
  var cur='', ms={a:0,per:0,day:0}, T={a:0,per:0,day:0};
  function ml(){ aoa.push(['월 계','','',ms.a,'','',ms.per,ms.day]); kinds.push('dsum'); }
  rows.forEach(function(r){ if(cur && r.ym!==cur){ ml(); ms={a:0,per:0,day:0}; } cur=r.ym; ms.a+=r.amt; ms.per+=r.per; ms.day+=r.day; T.a+=r.amt; T.per+=r.per; T.day+=r.day;
    aoa.push([r.ym.slice(0,4)+'-'+r.ym.slice(4,6), r.itemNm, r.itemGb==='FIX'?'고정':(r.itemGb==='VAR'?'변동':r.itemGb), r.amt, r.days, r.D, r.per, r.day]); kinds.push('row'); });
  if(cur) ml();
  aoa.push(['합 계','','',T.a,'','',T.per,T.day]); kinds.push('tot');
  var mg=[]; kinds.forEach(function(k,i){ if(k==='dsum'||k==='tot') mg.push({ s:{ r:i, c:0 }, e:{ r:i, c:2 } }); });
  return xSheet(aoa, kinds, 8, [3,4,5,6,7], mg, [10,16,7,13,9,8,15,13]);
}
function xsDtl(gb){
  if(gb==='EXP') return xsDtlExp();
  var rows=_rows.filter(function(r){ return r.gb===gb; });
  rows.sort(function(a,b){ return (a.dt+a.custCd+a.trxNo).localeCompare(b.dt+b.custCd+b.trxNo); });
  var money=(gb==='RCV'||gb==='PAY'), dtLbl={SALE:'매출일자', RCV:'수금일자', PURCH:'매입일자', PAY:'지급일자'}[gb];
  var cols = money ? [dtLbl,'코드','거래처코드','거래처명','담당사원','구분','현금', gb==='RCV'?'무통장입금':'무통장지급','카드','기타','할인','합계']
                   : [dtLbl,'코드','거래처코드','거래처명','담당사원','공급가','부가세','합계','DC'];
  var ncol=cols.length, H=xHead(GBL[gb]+' 상세', ncol), aoa=H.aoa, kinds=H.kinds, nmW=14;
  aoa.push(cols); kinds.push('h');
  function vals(s, r){ return money ? [s.cash+s.pcash, s.bank+s.pbank, s.card+s.pcard, s.etc+s.petc, s.rcvDc+s.payDc, gb==='RCV'?s.rcv:s.pay]
                                    : [gb==='SALE'?s.saleSup:s.purchSup, gb==='SALE'?s.saleVat:s.purchVat, gb==='SALE'?s.sale:s.purch, gb==='SALE'?s.saleDc:s.purchDc]; }
  var cur='', day=[], cnt=0;
  function sumLine(list, lbl, k){ var s=sumOf(list); aoa.push([lbl,'','','','',''].slice(0, money?6:5).concat(vals(s, null))); kinds.push(k); }
  rows.forEach(function(r){
    if(cur && r.dt!==cur){ sumLine(day, '일 계', 'dsum'); day=[]; }
    cur=r.dt; day.push(r); cnt++; nmW=Math.max(nmW, Math.min(40, xW(r.custNm)+2));
    var s=sumOf([r]);
    aoa.push([dl(r.dt), r.trxNo, r.custCd, r.custNm, r.mgrNm].concat(money?[r.payGb]:[]).concat(vals(s, r))); kinds.push('row');
  });
  if(cur) sumLine(day, '일 계', 'dsum');
  sumLine(rows, '합 계 ('+cnt+'건)', 'tot');
  var nums=[]; for(var i=(money?6:5); i<ncol; i++) nums.push(i);
  var mg=[]; kinds.forEach(function(k,i){ if(k==='dsum'||k==='tot') mg.push({ s:{ r:i, c:0 }, e:{ r:i, c:(money?5:4) } }); });
  var w = money ? [11,8,10,nmW,9,10,12,12,12,12,10,13] : [11,8,10,nmW,9,13,12,13,10];
  return xSheet(aoa, kinds, ncol, nums, mg, w);
}
function psXls(what){
  if(!_agg){ alertBox('먼저 [리스트조회]를 눌러 자료를 띄우세요.'); return; }
  if(typeof XLSX==='undefined'){ alertBox('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.', {icon:'❌', okColor:'red'}); return; }
  if(what==='dtl' && !_dtlGb){ alertBox('먼저 [상세보기]를 눌러 목록을 띄우세요.'); return; }
  var wb=XLSX.utils.book_new(), tag=_fr8+'~'+_to8;
  if(what==='all'){
    XLSX.utils.book_append_sheet(wb, xsSummary(), '종합 실적');
    XLSX.utils.book_append_sheet(wb, xsEmp(), '사원별현황');
  }
  if(_dtlGb) XLSX.utils.book_append_sheet(wb, xsDtl(_dtlGb), GBL[_dtlGb]+' 상세');
  XLSX.writeFile(wb, (what==='dtl' ? GBL[_dtlGb]+' 상세 ' : '종합 실적 ')+tag+'.xlsx');
  if(window._toast) _toast('📥 엑셀 저장 — '+(what==='dtl'?GBL[_dtlGb]+' 상세':'종합 실적·사원별 현황'+(_dtlGb?'·'+GBL[_dtlGb]+' 상세':'')), 'ok');
}
function psPrint(){ if(!_rows.length && !_expM.length){ alertBox('먼저 [리스트조회]를 눌러 자료를 띄운 뒤 인쇄하세요.'); return; } window.focus(); window.print(); }
</script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
</body>
</html>
