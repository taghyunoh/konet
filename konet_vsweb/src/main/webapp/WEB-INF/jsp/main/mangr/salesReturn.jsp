<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><c:choose><c:when test="${kind == 'P'}">매입 반품내역</c:when><c:otherwise>매출 반품내역</c:otherwise></c:choose></title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 쓰기 (전역 XLSX, 서식 포함) --%>
<%-- 우리 달력 — 기간칸 srFrom ~ srTo 를 짝으로 묶어 두 달을 나란히 띄운다(xxFrom/xxTo 이름 규칙). 기간을 다 고르면 종료칸 change 한 번 → dateChg() 로 조회 --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<%--
  매출 반품내역 (2026-11-18 신설 — 처음 이름 「반품내역」, 같은 날 매입 반품내역이 생기며 「매출관리에 반품내역도 매출반품내역 으로」) — 매출 관리 ▸ 매출 반품내역. 셸 iframe(logiFrame) 화면. 조회만 한다(저장 없음).
  · 사용자 「매출관리에서 반품내역 조회기능 구성해줘요」.
  · 반품이 쌓이는 곳 셋을 한 목록으로 본다 — 서버 /mangr/salesReturnList.do (매퍼 selectSalesReturnList) 가 src 로 갈라 준다 :
      STL 정산서     = 정산서의 반품 줄(납품유형 X). 일자 = 납품일자. ★발주 단위라 사업장이 없다 — 출고장까지만.
      TRX 판매전표   = 판매 등록의 거래구분 「반품」·「불량반품」 줄. 일자 = 판매일자. 번호 = 그 날의 전표 번호.
      PO  거래처 발주 = 토더·대상·동원홈푸드 등록의 거래구분 「반품」 줄. 일자 = 납기(배송)일자.
    수량·금액은 양수(반품 수량 · 반품액)로 온다. 금액 기준 = 매출내역과 같다(정산서 판매금액 · 전표 합계 · 발주 수량×판매가−DC).
  · 거르기(원천 · 출고장/거래처 · 검색)는 화면에서 한다 — 줄 수가 적다(한 해 400줄 안팎). 기간만 서버로 간다.
  · 탭 ① 내역(줄) ② 품목별 ③ 출고장·거래처별 ④ 월별 — ②~④ 는 줄을 누르면 그 묶음의 내역이 펼쳐진다.
    품목별은 우리 주코드(prodCd)로 묶는다 — 정산서 품목코드는 삼성 코드(서브)라 그대로 묶으면 같은 물건이 둘로 갈린다.
    수량 합계는 품목별에만 둔다(출고장·월별은 BOX 와 EA 가 섞여 뜻이 없다).
  · 엑셀 = 지금 보는 탭 · 지금 거른 대로. 서식은 거래처 매출장(salesLedger.jsp)과 같다.
  · ★★매입 꼴 (같은 날 「매입에 대한 반품내용조회도 구성해줘」) — 이 JSP 하나가 두 메뉴를 그린다 : 매출 관리 ▸ 반품내역(kind 없음 = S) · 매입 관리 ▸ 매입 반품내역(kind=P).
    kind 는 주소가 아니라 서버(/mangr/purchReturn.do)가 요청 속성으로 준다. 다른 것은 CFG 한 곳 : 조회 주소(/mangr/purchReturnList.do) · 원천(PUR 매입전표 하나 — 원천 고르기·원천별 카드를 숨긴다) ·
    곳 = 매입처 · 분모 = 매입액 · 내역 칸(공급가·부가세·담당·창고가 더 있다 — lineTrP) · 엑셀(xlsP) · 탭 기억 열쇠.
    매입 반품 줄은 수량·금액이 <저장된 부호 그대로> 온다 — 음수면 「반품을 되돌린 줄」(반품 취소 배지). 거래구분 매입인데 수량이 음수였던 옛 줄은 서버가 양수 반품으로 뒤집어 gb '매입(음수)' 로 준다.
    undoYn=Y = 그 반품을 원위치한 매입 줄이 있다(원위치 배지). ⚠매출 꼴에서 보이는 것은 바꾸지 말 것 — 묶음·거르기·율 계산은 두 꼴이 같은 함수를 쓴다.
  · ★반품율 (같은 날 「반품율도 추가해줘」) = 반품액 ÷ 판매액. 분모(판매액) = 같은 기간 · 같은 원천의 「반품 줄을 뺀 판매 줄」 합 — 응답의 base
    (매퍼 selectSalesReturnBase : 원천 × 월 × 곳 × 품목. 품목은 그 기간에 반품이 있는 것만 코드로 오고 나머지는 cd '' 로 접혀 온다).
    원천·곳 거르기는 분모에도 같이 건다. 검색 중이면 「거른 반품에 나온 품목」의 판매액만 분모로 쓴다(검색어가 품목을 좁힌 것으로 본다).
    정산서가 아직 안 온 출고의 추정 매출은 분모에 없다 — 이익현황의 반품율(추정 포함)과 조금 다를 수 있다. base 가 안 오면(옛 서버·조회 실패) 율 칸은 「-」.
--%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; background:#fff; border:1px solid var(--bd); border-radius:10px; padding:9px 12px; margin-bottom:10px; }
  .bar label{ font-size:12.5px; font-weight:700; color:#37475a; }
  .bar .sep{ width:1px; height:22px; background:#e3e8ee; margin:0 4px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; font-family:inherit; }
  .btn:hover{ border-color:var(--teal); } .btn:disabled{ opacity:.5; cursor:default; }
  .btn.sm{ height:28px; padding:0 10px; font-size:12.5px; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-xls{ background:#e8f5ec; color:#1d6f42; border-color:#a9d6b8; } .btn-xls:hover{ background:#d5eddd; border-color:#6fba88; }
  input[type=date], select, input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; font-family:inherit; background:#fff; }
  select{ font-weight:700; max-width:230px; }
  #srFind{ width:230px; }
  /* 요약 카드 */
  .cards{ display:grid; grid-template-columns:repeat(4, minmax(130px, 200px)) 1fr; gap:10px; margin-bottom:10px; }
  .kc{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:10px 14px; }
  .kc .t{ font-size:12px; font-weight:700; color:#6b7a89; }
  .kc .v{ font-size:22px; font-weight:800; margin-top:2px; font-variant-numeric:tabular-nums; }
  .kc .v small{ font-size:12.5px; font-weight:700; color:#6b7a89; margin-left:2px; }
  .kc.red .v{ color:var(--red); }
  .kc .s{ font-size:11.5px; color:#8a98a8; margin-top:1px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  table.lg td.rate{ font-weight:700; }
  .kc .srcs{ display:flex; gap:6px; flex-wrap:wrap; margin-top:6px; }
  .tag{ display:inline-flex; align-items:center; height:22px; padding:0 8px; border-radius:11px; font-size:12px; font-weight:700; white-space:nowrap; }
  .tag.STL{ background:#e3f0fb; color:#1c5d99; } .tag.TRX{ background:#eef8f5; color:#125a4e; } .tag.PO{ background:#fff3d6; color:#8a5a00; }
  .tag.bad{ background:#fde8e6; color:var(--red); }
  .srcs .tag{ height:26px; padding:0 10px; cursor:pointer; border:1px solid transparent; }
  .srcs .tag:hover{ border-color:#9fb6c3; } .srcs .tag b{ margin:0 4px; }
  /* 탭 — 다른 화면과 같은 모양 : 고른 탭 = 청록 칠 + ✓ */
  .tabs{ display:flex; gap:4px; align-items:flex-end; flex-wrap:wrap; border-bottom:2px solid #d5e3df; margin-bottom:10px; }
  .tab{ height:36px; padding:0 16px; border:1px solid #d5e3df; border-bottom:none; border-radius:8px 8px 0 0; background:#f1f5f4; cursor:pointer; font-size:14px; font-weight:700; color:#5a6b7a; font-family:inherit; margin-bottom:-2px; }
  .tab:hover{ color:var(--teal); } .tab.on{ background:var(--teal); color:#fff; border-color:var(--teal); } .tab.on::before{ content:'✓ '; }
  .tabs .info{ font-size:12.5px; color:#3d4d5c; margin-left:6px; padding-bottom:8px; }
  .tabs .act{ margin-left:auto; display:flex; gap:6px; padding-bottom:5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:10px 12px 12px; }
  .tw{ overflow:auto; max-height:calc(100vh - 318px); min-height:180px; }
  table.lg{ border-collapse:collapse; width:100%; font-size:12.5px; }
  table.lg th{ background:#d9edf7; font-weight:700; border:1px solid #9fb6c3; padding:6px 6px; white-space:nowrap; text-align:center; position:sticky; top:0; z-index:2; }
  table.lg th.srt{ cursor:pointer; user-select:none; } table.lg th.srt:hover{ background:#c6e2f1; }
  table.lg td{ border:1px solid #c9d3dc; padding:4px 6px; text-align:center; white-space:nowrap; }
  table.lg td.l{ text-align:left; } table.lg td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.lg td.nm{ white-space:normal; min-width:220px; text-align:left; overflow-wrap:anywhere; }
  table.lg td.amt{ color:var(--red); font-weight:700; }
  table.lg td.sp{ white-space:normal; text-align:left; min-width:110px; overflow-wrap:anywhere; }   /* 규격·비고 — 줄을 접어 가로 스크롤을 없앤다(정산서 규격이 길다 · 매입 꼴은 칸이 15개) */
  table.lg td.mut{ color:#9aa7b3; }
  table.lg tr.lg-tot td{ background:#fcf8e3; font-weight:700; position:sticky; bottom:0; }
  table.lg tr.grp{ cursor:pointer; } table.lg tr.grp:hover td{ background:#f3f9fc; } table.lg tr.grp.open td{ background:#eaf4fa; font-weight:700; }
  table.lg tr.det > td{ padding:6px 8px 10px 26px; background:#fafcfd; text-align:left; white-space:normal; }
  table.lg tr.det table.lg{ font-size:12px; } table.lg tr.det table.lg th{ position:static; background:#eef3f6; border-color:#c9d3dc; }
  .car{ display:inline-block; width:14px; color:#5a6b7a; }
  .sub{ font-size:11.5px; color:#8a98a8; margin-left:4px; }
  .pct{ display:inline-block; min-width:42px; }
  .bar2{ display:inline-block; height:8px; background:#f1b4ad; border-radius:4px; vertical-align:middle; margin-right:5px; }
  .msg{ padding:26px; text-align:center; color:#8a98a8; }
  .note{ font-size:12px; color:#6b7a89; margin-top:8px; line-height:1.6; }
  @media (max-width:1000px){ .cards{ grid-template-columns:1fr 1fr; } }
  @media print{
    body{ background:#fff; } .noprint{ display:none !important; } .wrap{ padding:0; }
    .tw{ max-height:none !important; overflow:visible; } table.lg th, table.lg tr.lg-tot td{ position:static; }
    .card{ border:0; padding:0; } .tab:not(.on){ display:none; }
  }
</style>
</head>
<body>
<span id="compNm" style="display:none"><c:out value="${sessionScope.s_comp_nm}"/></span>
<div class="wrap">
  <c:choose><c:when test="${kind == 'P'}"><h2>↩️ 매입 반품내역 <small>매입 등록(매입전표)의 반품 줄을 모아 봅니다 (조회 전용)</small></h2></c:when>
  <c:otherwise><h2>↩️ 매출 반품내역 <small>정산서 반품 · 판매 등록 반품 · 거래처 발주 반품을 한 목록으로 봅니다 (조회 전용)</small></h2></c:otherwise></c:choose>

  <div class="bar noprint">
    <label>기간</label>
    <input type="date" id="srFrom" onchange="dateChg()"> ~ <input type="date" id="srTo" onchange="dateChg()">
    <button class="btn sm" onclick="setRange('m0')">이번 달</button>
    <button class="btn sm" onclick="setRange('m1')">지난달</button>
    <button class="btn sm" onclick="setRange('m3')">최근 3개월</button>
    <button class="btn sm" onclick="setRange('y')">올해</button>
    <span class="sep"></span>
    <span id="srSrcWrap" style="display:inline-flex;gap:8px;align-items:center"><label>원천</label>
    <select id="srSrc" onchange="render()" title="반품이 어디에 적힌 것인지">
      <option value="">전체</option><option value="STL">정산서</option><option value="TRX">판매전표</option><option value="PO">거래처 발주</option>
    </select></span>
    <label id="lbPlace">출고장·거래처</label>
    <select id="srPlace" onchange="render()"><option value="">전체</option></select>
    <input type="text" id="srFind" placeholder="품목코드 · 품명 · 발주번호 · 비고" oninput="findChg()" onkeydown="if(event.key==='Escape'){ this.value=''; render(); }">
    <span class="sep"></span>
    <button class="btn btn-teal" onclick="load()">🔍 조회</button>
  </div>

  <div class="cards">
    <div class="kc"><div class="t">반품 건수</div><div class="v" id="kCnt">-</div></div>
    <div class="kc"><div class="t">반품 품목</div><div class="v" id="kItem">-</div></div>
    <div class="kc red"><div class="t">반품액</div><div class="v" id="kAmt">-</div></div>
    <div class="kc" id="kRateCard" title="반품율 = 반품액 ÷ 판매액. 판매액 = 같은 기간 · 같은 원천의 반품 줄을 뺀 판매 줄의 합입니다. 원천·출고장/거래처를 고르면 그 몫만 견줍니다"><div class="t">반품율 <span style="font-weight:600" id="lbRateSub">· 반품액 ÷ 판매액</span></div><div class="v" id="kRate">-</div><div class="s" id="kSale"></div></div>
    <div class="kc" id="kSrcCard"><div class="t">원천별 <span style="font-weight:600">· 누르면 그 원천만 봅니다</span></div><div class="srcs" id="kSrc"><span style="color:#9aa7b3;font-size:12.5px">조회하면 나옵니다</span></div></div>
  </div>

  <div class="tabs">
    <button class="tab on" id="tab-d" onclick="tab('d')">📄 내역</button>
    <button class="tab" id="tab-i" onclick="tab('i')">📦 품목별</button>
    <button class="tab" id="tab-p" onclick="tab('p')">🏬 출고장·거래처별</button>
    <button class="tab" id="tab-m" onclick="tab('m')">📅 월별</button>
    <span class="info" id="info"></span>
    <span class="act noprint">
      <button class="btn btn-xls" onclick="xls()" title="지금 보는 탭을 지금 거른 대로 엑셀 파일로 만듭니다">📥 엑셀</button>
      <button class="btn" onclick="window.print()" title="지금 보는 탭을 인쇄합니다">🖨 인쇄</button>
    </span>
  </div>

  <div class="card">
    <div class="tw" id="pane"><div class="msg">불러오는 중…</div></div>
    <c:choose><c:when test="${kind == 'P'}"><div class="note">
      · <b>매입 등록</b>에서 거래구분을 「반품」·「불량반품」으로 넣은 줄입니다. 일자 = 매입일자 · 번호 = 그 날의 전표 번호(뒤 숫자는 줄 번호). 반품액 = 합계(부가세 포함).<br>
      · <span class="tag bad">반품 취소</span> = 수량이 음수인 반품 줄 — 반품을 되돌린 줄이라 반품 수량·금액에서 그만큼 빠집니다. &nbsp;<span class="tag PO">원위치</span> = 그 반품을 다시 매입으로 되돌린 줄이 있습니다(매입 등록의 원위치).<br>
      · 구분 「매입(음수)」 = 예전에 거래구분은 매입으로 두고 수량을 음수로 넣은 줄 — 반품으로 보고 함께 보여 줍니다.<br>
      · <b>반품율</b> = 반품액 ÷ 매입액. 매입액은 <b>같은 기간</b>의 반품 아닌 매입 줄 합계(부가세 포함)입니다. 매입처를 고르면 그 매입처 몫만, 검색 중에는 거른 반품에 나온 품목의 매입액만 견줍니다.
    </div></c:when><c:otherwise><div class="note">
      · <b>정산서</b> 반품은 출고장이 준 정산서의 반품 줄입니다 — 발주 단위라 <b>사업장은 알 수 없고 출고장까지만</b> 나옵니다. 일자 = 납품일자.<br>
      · <b>판매전표</b>는 판매 등록에서 거래구분을 「반품」·「불량반품」으로 넣은 줄(일자 = 판매일자 · 번호 = 그 날의 전표 번호), <b>거래처 발주</b>는 토더·대상·동원홈푸드 등록의 반품 줄입니다.<br>
      · 반품액은 매출내역에서 빠지는 금액과 같습니다 — 정산서 = 판매금액 · 판매전표 = 합계(부가세 포함) · 거래처 발주 = 수량 × 판매가 − DC.<br>
      · <b>반품율</b> = 반품액 ÷ 판매액. 판매액은 <b>같은 기간 · 같은 원천</b>의 반품 줄을 뺀 판매 줄의 합입니다(정산서가 아직 안 온 출고는 넣지 않습니다). 검색 중에는 거른 반품에 나온 품목의 판매액만 견줍니다.
    </div></c:otherwise></c:choose>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:(body||'') }); }
function err(m){ _alertBox(m,{icon:'⚠️'}); }
function el(id){ return document.getElementById(id); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(v); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString('ko-KR'); }
function fq(v){ var x=n(v); return Math.round(x)===x ? x.toLocaleString('ko-KR') : x.toLocaleString('ko-KR',{ maximumFractionDigits:3 }); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function nkey(s){ return String(s||'').replace(/\s+/g,'').toLowerCase(); }
function lsGet(k){ try{ return localStorage.getItem(k); }catch(e){ return null; } }
function lsSet(k,v){ try{ localStorage.setItem(k,v); }catch(e){} }

/* 꼴 — S = 매출 관리 ▸ 반품내역(원천 셋) · P = 매입 관리 ▸ 매입 반품내역(매입전표 하나). 서버가 요청 속성 kind 로 정한다 */
var KIND=('${kind}'==='P') ? 'P' : 'S';
var CFG = KIND==='P'
  ? { url:'/mangr/purchReturnList.do', SRC:{ PUR:'매입전표' }, ORD:['PUR'], place:'매입처', sale:'매입액', tt:'매입 반품내역', nm:'매입반품내역', tabKey:'prTab', none:'이 기간에 매입 반품이 없습니다.' }
  : { url:'/mangr/salesReturnList.do', SRC:{ STL:'정산서', TRX:'판매전표', PO:'거래처 발주' }, ORD:['STL','TRX','PO'], place:'출고장·거래처', sale:'판매액', tt:'매출 반품내역', nm:'매출반품내역', tabKey:'srTab', none:'이 기간에 반품이 없습니다.' };
var SRC=CFG.SRC, SRC_ORD=CFG.ORD;
function fp(v){ return n(v).toLocaleString('ko-KR',{ maximumFractionDigits:2 }); }   /* 매입 단가 — 소수 둘째 자리까지(49.33 같은 단가가 있다) */
var _rows=null, _base=null, _q=null, _tab='d', _open={}, _sort={ k:'dt', d:-1 }, _gsort='amt', _seq=0;

/* 그 줄의 「곳」 — 정산서 = 출고장(사업장을 모른다) · 판매전표 = 거래처 · 거래처 발주 = 거래처(없으면 출고장 이름) */
function place(r){ return r.src==='STL' ? String(r.dcNm||'') : (String(r.custNm||'') || String(r.dcNm||'')); }
/* 우리 품목코드 — 정산서 품목코드(삼성 코드)가 주코드와 다르면 주코드로 묶는다 */
function code(r){ return String(r.prodCd||r.itemCd||''); }
function isBad(r){ return /불량/.test(String(r.gb||'')); }

/* ── 기간 ── */
function setRange(k){
  var t=new Date(), a, b=t;
  if(k==='m0'){ a=new Date(t.getFullYear(), t.getMonth(), 1); }
  else if(k==='m1'){ a=new Date(t.getFullYear(), t.getMonth()-1, 1); b=new Date(t.getFullYear(), t.getMonth(), 0); }
  else if(k==='m3'){ a=new Date(t.getFullYear(), t.getMonth()-2, 1); }
  else { a=new Date(t.getFullYear(), 0, 1); }
  el('srFrom').value=ymd(a); el('srTo').value=ymd(b); load();
}
/* 날짜 칸이 바뀌면 조회 — 기간이 뒤집혔거나 빈 칸이면 조용히 기다린다 */
function dateChg(){ var fr=el('srFrom').value, to=el('srTo').value; if(fr && to && fr<=to) load(); }
var _findT=null;
function findChg(){ clearTimeout(_findT); _findT=setTimeout(render, 180); }

/* ── 조회 — 기간만 서버로. 더 새 조회가 나갔으면 옛 응답은 버린다 ── */
function load(){
  var fr=el('srFrom').value, to=el('srTo').value;
  if(!fr || !to){ err('조회 기간을 넣으세요.'); return; }
  if(fr>to){ err('시작일이 끝일보다 늦습니다.'); return; }
  var my=++_seq;
  el('pane').innerHTML='<div class="msg">불러오는 중…</div>'; el('info').textContent='';
  post(CFG.url,'frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(my!==_seq) return;
      if(j && j.error){ throw new Error(j.error); }
      _rows=(j&&j.data)||[]; _base=(j && j.base) ? j.base : null; _q={ fr:fr, to:to }; _open={};
      placeFill(); render();
    })
    .catch(function(e){ if(my!==_seq) return; _rows=null; _base=null; _q=null; el('pane').innerHTML='<div class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</div>'; cards([]); });
}
/* 출고장·거래처 고르기 — 받은 줄에 있는 곳만(반품액 큰 차례). 고르던 곳이 새 기간에 없으면 전체로 */
function placeFill(){
  var s=el('srPlace'), keep=s.value, m={}, L=[];
  (_rows||[]).forEach(function(r){ var p=place(r); if(!p) return; if(!m[p]){ m[p]={ p:p, amt:0, cnt:0 }; L.push(m[p]); } m[p].amt+=n(r.amt); m[p].cnt++; });
  L.sort(function(a,b){ return b.amt-a.amt; });
  s.innerHTML='<option value="">전체</option>'+L.map(function(o){ return '<option value="'+esc(o.p)+'">'+esc(o.p)+' ('+o.cnt+')</option>'; }).join('');
  s.value = m[keep] ? keep : '';
}
function view(){
  var s=el('srSrc').value, p=el('srPlace').value, q=nkey(el('srFind').value);
  return (_rows||[]).filter(function(r){
    if(s && r.src!==s) return false;
    if(p && place(r)!==p) return false;
    if(q && nkey([r.itemCd,r.prodCd,r.itemNm,r.spec,r.dcNm,r.custNm,r.rcvNm,r.docNo,r.remark,r.gb].join('|')).indexOf(q)<0) return false;
    return true; });
}

/* ── 반품율의 분모 — _base(원천 × 월 × 곳 × 품목 판매액)를 반품 줄과 같은 조건으로 거른다.
     V = 지금 거른 반품 줄 · noSrc = 원천 고르기를 무시(원천별 칩용). 검색 중이면 V 에 나온 품목(cd)의 판매액만 — cd '' (반품 없는 품목 묶음)는 빠진다.
     base 가 없으면 null → 율 「-」 ── */
function baseView(V, noSrc){
  if(!_base) return null;
  var s=noSrc?'':el('srSrc').value, p=el('srPlace').value, q=nkey(el('srFind').value), items=null;
  if(q){ items={}; V.forEach(function(r){ items[code(r)]=1; }); }
  return _base.filter(function(b){
    if(s && b.src!==s) return false;
    if(p && String(b.place||'')!==p) return false;
    if(items && !(b.cd && items[b.cd])) return false;
    return true; });
}
function saleSum(B, f){ if(!B) return null; var t=0; B.forEach(function(b){ if(!f || f(b)) t+=n(b.saleAmt); }); return t; }
function rateOf(ret, sale){ return (sale!=null && sale>0) ? ret/sale*100 : null; }
function rateTxt(ret, sale){ var x=rateOf(ret, sale); return x==null ? '-' : x.toFixed(2)+'%'; }
function saleTxt(sale){ return sale==null ? '-' : fmt(sale); }

/* ── 요약 카드 — 원천별 칸은 원천 고르기와 무관하게 「기간·곳·검색」까지만 거른 값(눌러서 원천을 바꾸는 자리라) ── */
function cards(V){
  var amt=0, items={};
  V.forEach(function(r){ amt+=n(r.amt); items[code(r)]=1; });
  el('kCnt').innerHTML=_q ? V.length.toLocaleString('ko-KR')+'<small>건</small>' : '-';
  el('kItem').innerHTML=_q ? Object.keys(items).length.toLocaleString('ko-KR')+'<small>종</small>' : '-';
  el('kAmt').innerHTML=_q ? fmt(amt)+'<small>원</small>' : '-';
  var sale=_q ? saleSum(baseView(V)) : null;
  el('kRate').textContent=_q ? rateTxt(amt, sale) : '-';
  el('kSale').textContent=(_q && sale!=null) ? (el('srFind').value.trim()?'거른 품목 ':'')+CFG.sale+' '+fmt(sale)+'원 대비' : (_q?CFG.sale+'을 받지 못했습니다':'');
  el('kSale').title=el('kSale').textContent;
  if(!_q){ el('kSrc').innerHTML='<span style="color:#9aa7b3;font-size:12.5px">조회하면 나옵니다</span>'; return; }
  var cur=el('srSrc').value, keepSrc=cur; el('srSrc').value=''; var all=view(); el('srSrc').value=keepSrc;
  var by={}; all.forEach(function(r){ var o=by[r.src]||(by[r.src]={ c:0, a:0 }); o.c++; o.a+=n(r.amt); });
  var BA=baseView(all, true), bs={}; if(BA) BA.forEach(function(b){ bs[b.src]=(bs[b.src]||0)+n(b.saleAmt); });
  el('kSrc').innerHTML=SRC_ORD.map(function(k){ var o=by[k]||{ c:0, a:0 };
      return '<span class="tag '+k+'" style="'+(cur && cur!==k?'opacity:.45':'')+(cur===k?';border-color:#5a6b7a':'')+'" title="누르면 '+SRC[k]+'만 봅니다 · 다시 누르면 전체" onclick="srcPick(\''+k+'\')">'+SRC[k]+'<b>'+o.c+'</b>건 · '+fmt(o.a)+'원'+(BA && o.c?' · '+rateTxt(o.a, bs[k]||0):'')+'</span>'; }).join('');
}
function srcPick(k){ var s=el('srSrc'); s.value=(s.value===k?'':k); render(); }

/* ── 줄 칸 (내역 탭 · 펼친 묶음이 같이 쓴다) ── */
var HEAD = KIND==='P'
  ? [['dt','일자'],['place','매입처'],['docNo','전표번호'],['code','품목코드'],['itemNm','품명'],['spec','규격'],['gb','구분'],['qty','수량'],['price','단가'],['supplyAmt','공급가'],['vatAmt','부가세'],['amt','반품액'],['mgrNm','담당'],['whNm','창고'],['remark','비고']]
  : [['dt','일자'],['src','원천'],['place','출고장·거래처'],['docNo','발주·전표번호'],['code','품목코드'],['itemNm','품명'],['spec','규격'],['gb','구분'],['qty','수량'],['price','단가'],['amt','반품액'],['remark','비고']];
function placeHtml(r){
  var p=place(r), x='';
  if(r.src==='PO'){ if(r.rcvNm) x=' <span class="sub">'+esc(r.rcvNm)+'</span>'; if(r.dcNm && r.dcNm!==p) x+=' <span class="sub">'+esc(r.dcNm)+'</span>'; }
  return p ? esc(p)+x : '<span class="sub" style="margin:0">-</span>';
}
function codeHtml(r){
  var c=code(r), i=String(r.itemCd||'');
  return esc(c)+((i && i!==c)?' <span class="sub" title="정산서에 적힌 품목코드(삼성 코드)">'+esc(i)+'</span>':'');
}
/* 매입 꼴의 구분 칸 — 불량반품 · 매입(음수) · 반품 취소(음수 반품 줄) · 원위치 */
function gbHtmlP(r){
  var g=String(r.gb||'반품'), neg=n(r.qty)<0 || n(r.amt)<0;
  return (isBad(r) ? '<span class="tag bad">'+esc(g)+'</span>' : /음수/.test(g) ? '<span title="거래구분은 매입인데 수량을 음수로 넣은 줄 — 반품으로 봅니다">'+esc(g)+'</span>' : esc(g))
    +(neg?' <span class="tag bad" title="수량이 음수인 반품 줄 — 반품을 되돌린 줄입니다(매입액·재고가 그만큼 다시 늘어납니다)">반품 취소</span>':'')
    +(r.undoYn==='Y'?' <span class="tag PO" title="이 반품을 원위치한 매입 줄이 있습니다 (비고 「반품 … 원위치」)">원위치</span>':'');
}
function lineTrP(r){
  return '<tr><td>'+esc(d10(r.dt))+'</td><td class="l">'+esc(place(r))+(r.custCd?' <span class="sub">'+esc(r.custCd)+'</span>':'')+'</td>'
    +'<td>'+esc(r.docNo)+(r.rowNo?'<span class="sub">-'+esc(r.rowNo)+'</span>':'')+'</td><td class="l">'+esc(code(r))+'</td><td class="nm">'+esc(r.itemNm)+'</td><td class="sp">'+esc(r.spec)+'</td>'
    +'<td>'+gbHtmlP(r)+'</td><td class="r">'+fq(r.qty)+'</td><td class="r">'+fp(r.price)+'</td><td class="r">'+fmt(r.supplyAmt)+'</td><td class="r">'+fmt(r.vatAmt)+'</td><td class="r amt">'+fmt(r.amt)+'</td>'
    +'<td>'+esc(r.mgrNm)+'</td><td>'+esc(r.whNm)+'</td><td class="sp">'+esc(r.remark)+'</td></tr>';
}
function lineTr(r){
  if(KIND==='P') return lineTrP(r);
  return '<tr><td>'+esc(d10(r.dt))+'</td><td><span class="tag '+esc(r.src)+'">'+esc(SRC[r.src]||r.src)+'</span></td><td class="sp">'+placeHtml(r)+'</td>'
    +'<td>'+esc(r.docNo)+(r.src==='TRX' && r.rowNo?'<span class="sub">-'+esc(r.rowNo)+'</span>':'')+'</td><td class="l">'+codeHtml(r)+'</td><td class="nm">'+esc(r.itemNm)+'</td><td class="sp">'+esc(r.spec)+'</td>'
    +'<td>'+(isBad(r)?'<span class="tag bad">'+esc(r.gb)+'</span>':esc(r.gb||'반품'))+'</td>'
    +'<td class="r">'+fq(r.qty)+(r.unit?' <span class="sub" style="margin:0">'+esc(r.unit)+'</span>':'')+'</td><td class="r">'+fmt(r.price)+'</td><td class="r amt">'+fmt(r.amt)+'</td><td class="sp">'+esc(r.remark)+'</td></tr>';
}
function sortVal(r,k){ return k==='place'?place(r) : k==='code'?code(r) : (k==='qty'||k==='price'||k==='amt'||k==='supplyAmt'||k==='vatAmt')?n(r[k]) : String(r[k]==null?'':r[k]); }
function sorted(V){
  var k=_sort.k, d=_sort.d;
  return V.slice().sort(function(a,b){ var x=sortVal(a,k), y=sortVal(b,k); if(x<y) return -d; if(x>y) return d;
    return String(a.dt)<String(b.dt)?1:(String(a.dt)>String(b.dt)?-1:0); });
}
function sortBy(k){ if(_sort.k===k) _sort.d=-_sort.d; else _sort={ k:k, d:(k==='dt'||k==='qty'||k==='price'||k==='amt'||k==='supplyAmt'||k==='vatAmt')?-1:1 }; render(); }
function lineHead(sortable){
  return '<thead><tr>'+HEAD.map(function(h){ var on=sortable && _sort.k===h[0];
    return '<th'+(sortable?' class="srt" onclick="sortBy(\''+h[0]+'\')" title="누르면 이 칸으로 정렬"':'')+'>'+h[1]+(on?(_sort.d>0?' ▲':' ▼'):'')+'</th>'; }).join('')+'</tr></thead>';
}
function totOf(V){ var t={ cnt:V.length, amt:0, sup:0, vat:0 }; V.forEach(function(r){ t.amt+=n(r.amt); t.sup+=n(r.supplyAmt); t.vat+=n(r.vatAmt); }); return t; }

/* ── ① 내역 ── */
function renderDetail(V){
  if(!V.length) return '<div class="msg">'+(_rows && _rows.length?'거른 조건에 맞는 반품이 없습니다.':CFG.none)+'</div>';
  var t=totOf(V), sale=saleSum(baseView(V)), ai=0; HEAD.forEach(function(h, i){ if(h[0]==='amt') ai=i; });
  return '<table class="lg">'+lineHead(true)+'<tbody>'+sorted(V).map(lineTr).join('')
    +'<tr class="lg-tot"><td>합 계</td><td colspan="'+(KIND==='P'?ai-3:ai-1)+'">'+t.cnt.toLocaleString('ko-KR')+'건'+(sale!=null?' · 반품율 '+rateTxt(t.amt, sale)+' <span class="sub">'+CFG.sale+' '+fmt(sale)+'원 대비</span>':'')+'</td>'
    +(KIND==='P'?'<td class="r">'+fmt(t.sup)+'</td><td class="r">'+fmt(t.vat)+'</td>':'')+'<td class="r amt">'+fmt(t.amt)+'</td><td colspan="'+(HEAD.length-ai-1)+'"></td></tr></tbody></table>';
}

/* ── ②③④ 묶음 — i 품목별(주코드) · p 출고장·거래처별(원천마다 따로) · m 월별. 줄을 누르면 그 묶음의 내역 ── */
function groups(kind, V){
  var m={}, L=[];
  V.forEach(function(r){
    var k = kind==='i' ? code(r) : kind==='p' ? r.src+'|'+place(r) : String(r.dt||'').slice(0,6);
    var g=m[k]; if(!g){ g=m[k]={ k:k, r0:r, rows:[], cnt:0, qty:0, amt:0, last:'', items:{}, by:{} }; L.push(g); }
    g.rows.push(r); g.cnt++; g.qty+=n(r.qty); g.amt+=n(r.amt); if(String(r.dt)>g.last) g.last=String(r.dt);
    g.items[code(r)]=1; g.by[r.src]=(g.by[r.src]||0)+n(r.amt);
  });
  /* 묶음마다 판매액(분모)·반품율 — base 를 한 번 훑어 같은 열쇠로 모은다. 품목 열쇠가 빈 값이면(코드 없는 반품) 견줄 판매액을 모른다 */
  var B=baseView(V), sm={};
  if(B) B.forEach(function(b){ var k = kind==='i' ? String(b.cd||'') : kind==='p' ? b.src+'|'+String(b.place||'') : String(b.ym||''); sm[k]=(sm[k]||0)+n(b.saleAmt); });
  L.forEach(function(g){ g.sale = (!B || (kind==='i' && !g.k)) ? null : (sm[g.k]||0); g.rate=rateOf(g.amt, g.sale); });
  if(kind==='m') L.sort(function(a,b){ return a.k<b.k?1:(a.k>b.k?-1:0); });
  else L.sort(function(a,b){ var x = _gsort==='rate' ? ((b.rate==null?-1:b.rate)-(a.rate==null?-1:a.rate)) : _gsort==='sale' ? (n(b.sale)-n(a.sale)) : _gsort==='cnt' ? (b.cnt-a.cnt) : 0;
    return x || (b.amt-a.amt) || (b.cnt-a.cnt); });
  return L;
}
/* 품목별 · 출고장·거래처별 — 머리글(건수·반품액·판매액·반품율)을 누르면 그 칸 큰 차례. 월별은 늘 최근 달 먼저 */
function gsortBy(k){ _gsort=k; render(); }
function pctHtml(a, tot, max){ var p=tot?a/tot*100:0, w=max?Math.round(a/max*60):0;
  return '<span class="bar2" style="width:'+w+'px"></span><span class="pct">'+p.toFixed(1)+'%</span>'; }
function grpHead(kind){
  var one1=SRC_ORD.length<2;   /* 원천이 하나뿐(매입 꼴)이면 원천 칸을 두지 않는다 */
  var h = kind==='i' ? ['품목코드','품명','규격','건수','수량','반품액',CFG.sale,'반품율','비중','최근 반품일']
        : kind==='p' ? (one1?[]:['원천']).concat([CFG.place,'건수','품목','반품액',CFG.sale,'반품율','비중','최근 반품일'])
        : ['월','건수','품목','반품액',CFG.sale,'반품율','비중'].concat(one1?[]:SRC_ORD.map(function(k){ return SRC[k]; }));
  return h;
}
function grpCells(kind, g, tot, max){
  var r=g.r0, sr='<td class="r'+(g.sale?'':' mut')+'">'+saleTxt(g.sale)+'</td><td class="r rate'+(g.rate==null?' mut':'')+'"'+(g.rate==null && g.sale!=null?' title="이 기간에 견줄 판매액이 없습니다"':'')+'>'+rateTxt(g.amt, g.sale)+'</td>';
  if(kind==='i') return ['<td class="l">'+esc(g.k)+'</td>','<td class="nm">'+esc(r.itemNm)+'</td>','<td class="l">'+esc(r.spec)+'</td>','<td class="r">'+g.cnt+'</td>',
    '<td class="r">'+fq(g.qty)+(r.unit?' <span class="sub" style="margin:0">'+esc(r.unit)+'</span>':'')+'</td>','<td class="r amt">'+fmt(g.amt)+'</td>',sr,'<td class="l">'+pctHtml(g.amt,tot,max)+'</td>','<td>'+esc(d10(g.last))+'</td>'];
  if(kind==='p') return (SRC_ORD.length<2?[]:['<td><span class="tag '+esc(r.src)+'">'+esc(SRC[r.src]||r.src)+'</span></td>']).concat(['<td class="l">'+(place(r)?esc(place(r)):'<span class="sub" style="margin:0">(이름 없음)</span>')+'</td>','<td class="r">'+g.cnt+'</td>',
    '<td class="r">'+Object.keys(g.items).length+'</td>','<td class="r amt">'+fmt(g.amt)+'</td>',sr,'<td class="l">'+pctHtml(g.amt,tot,max)+'</td>','<td>'+esc(d10(g.last))+'</td>']);
  return ['<td>'+esc(g.k.slice(0,4)+'-'+g.k.slice(4,6))+'</td>','<td class="r">'+g.cnt+'</td>','<td class="r">'+Object.keys(g.items).length+'</td>','<td class="r amt">'+fmt(g.amt)+'</td>',sr,'<td class="l">'+pctHtml(g.amt,tot,max)+'</td>']
    .concat(SRC_ORD.length<2?[]:SRC_ORD.map(function(s){ return '<td class="r'+(g.by[s]?'':' mut')+'">'+(g.by[s]?fmt(g.by[s]):'-')+'</td>'; }));
}
function renderGroups(kind, V){
  if(!V.length) return '<div class="msg">'+(_rows && _rows.length?'거른 조건에 맞는 반품이 없습니다.':CFG.none)+'</div>';
  var G=groups(kind, V), t=totOf(V), max=0, H=grpHead(kind), sale=saleSum(baseView(V)); G.forEach(function(g){ if(g.amt>max) max=g.amt; });
  var SR='<td class="r" title="이 기간 '+CFG.sale+' 전체 — 반품이 없는 품목·곳까지 더한 값입니다">'+saleTxt(sale)+'</td><td class="r rate">'+rateTxt(t.amt, sale)+'</td>';
  var GS={ '건수':'cnt', '반품액':'amt', '반품율':'rate' }; GS[CFG.sale]='sale';
  var body=G.map(function(g){
    var ok=kind+'#'+g.k, op=!!_open[ok], c=grpCells(kind, g, t.amt, max);
    c[0]=c[0].replace(/^<td([^>]*)>/, '<td$1><span class="car">'+(op?'▼':'▶')+'</span>');
    var tr='<tr class="grp'+(op?' open':'')+'" data-k="'+esc(ok)+'" onclick="grpToggle(this.getAttribute(\'data-k\'))" title="누르면 이 묶음의 반품 내역을 펼치거나 접습니다">'+c.join('')+'</tr>';
    if(op) tr+='<tr class="det"><td colspan="'+H.length+'"><table class="lg">'+lineHead(false)+'<tbody>'+g.rows.map(lineTr).join('')+'</tbody></table></td></tr>';
    return tr; }).join('');
  var totTr;
  if(kind==='i') totTr='<td>합 계</td><td colspan="2">'+G.length.toLocaleString('ko-KR')+'종</td><td class="r">'+t.cnt+'</td><td></td><td class="r amt">'+fmt(t.amt)+'</td>'+SR+'<td></td><td></td>';
  else if(kind==='p') totTr=(SRC_ORD.length<2 ? '<td>합 계 <span class="sub">'+G.length.toLocaleString('ko-KR')+'곳</span></td>' : '<td>합 계</td><td>'+G.length.toLocaleString('ko-KR')+'곳</td>')+'<td class="r">'+t.cnt+'</td><td></td><td class="r amt">'+fmt(t.amt)+'</td>'+SR+'<td></td><td></td>';
  else { var by={}; V.forEach(function(r){ by[r.src]=(by[r.src]||0)+n(r.amt); });
    totTr='<td>합 계</td><td class="r">'+t.cnt+'</td><td></td><td class="r amt">'+fmt(t.amt)+'</td>'+SR+'<td></td>'+(SRC_ORD.length<2?'':SRC_ORD.map(function(s){ return '<td class="r">'+(by[s]?fmt(by[s]):'-')+'</td>'; }).join('')); }
  return '<table class="lg"><thead><tr>'+H.map(function(h){ var k=(kind!=='m') ? GS[h] : null;
      return k ? '<th class="srt" onclick="gsortBy(\''+k+'\')" title="누르면 이 칸이 큰 차례로">'+h+(_gsort===k?' ▼':'')+'</th>' : '<th>'+h+'</th>'; }).join('')
    +'</tr></thead><tbody>'+body+'<tr class="lg-tot">'+totTr+'</tr></tbody></table>';
}
/* 표 높이 = 창 높이 − 표 위쪽 − 아래 설명 — 조회줄이 접히거나 창이 바뀌어도 바깥 스크롤이 안 생기게 실측한다. 숨은 채(높이 0)면 최소 높이 */
function fit(){ var p=el('pane'), nt=document.querySelector('.note'); if(!p) return;
  p.style.maxHeight=Math.max(180, window.innerHeight - p.getBoundingClientRect().top - (nt?nt.offsetHeight:0) - 40)+'px'; }
window.addEventListener('resize', function(){ fit(); setTimeout(fit, 200); });   /* 한 번 더 — 창이 줄며 조회줄·카드가 접힌 뒤의 자리로 다시 잰다(바로 재면 접히기 전 값이 남았다) */
function grpToggle(k){ if(_open[k]) delete _open[k]; else _open[k]=1; var p=el('pane'), st=p.scrollTop; render(); p.scrollTop=st; }

function render(){
  var V=_q ? view() : [];
  cards(V); fit();
  if(!_q){ return; }
  el('pane').innerHTML = _tab==='d' ? renderDetail(V) : renderGroups(_tab, V);
  var all=(_rows||[]).length;
  el('info').innerHTML=esc(_q.fr)+' ~ '+esc(_q.to)+' · <b>'+V.length+'</b>건'+(V.length!==all?' <span style="color:#b45309">(전체 '+all+'건 중 거른 것)</span>':'');
}
function tab(t){
  _tab=t; lsSet(CFG.tabKey, t);
  ['d','i','p','m'].forEach(function(x){ el('tab-'+x).classList.toggle('on', x===t); });
  if(_q) render();
}

/* ── 엑셀 — 지금 보는 탭 · 지금 거른 대로. 거래처 매출장(ledgerSheet)과 같은 서식 : 굴림 9 · 제목 17 굵게(2줄 병합) · 조회기간 줄(밑줄) · 머리글 하늘 · 본문 테두리 · 합계 크림 ── */
function E(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; }
function serial(d){ var p=String(d).split('-'); return (Date.UTC(+p[0],+p[1]-1,+p[2])-Date.UTC(1899,11,30))/86400000; }
function wch(s){ var w=0; String(s||'').split('').forEach(function(ch){ w+=(ch.charCodeAt(0)>255?1.8:1); }); return w; }
function f8(d){ return String(d).replace(/-/g,''); }
function condTxt(){ var a=[]; if(el('srSrc').value) a.push('원천 '+SRC[el('srSrc').value]); if(el('srPlace').value) a.push(el('srPlace').value); if(el('srFind').value.trim()) a.push('검색 「'+el('srFind').value.trim()+'」'); return a.length?'   ('+a.join(' · ')+')':''; }
/* 표 하나 → 시트. head = 머리글 · body = 줄 배열 · tot = 합계 줄 · o = { date:[날짜 칸], num:{칸:서식}, left:[왼쪽 맞춤 칸] } */
function sheetOf(title, head, body, tot, o){
  var N=head.length, bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var aoa=[ [title].concat(E(N-1)), E(N), ['조회기간 : '+_q.fr+' ~ '+_q.to+condTxt()].concat(E(N-1)), head ], kinds=['t','t','p','h'], W=head.map(function(h){ return wch(h)+2; });
  body.forEach(function(a){ aoa.push(a); kinds.push('row'); a.forEach(function(v,i){ if(typeof v==='string') W[i]=Math.max(W[i], Math.min(48, wch(v)+2)); }); });
  aoa.push(tot); kinds.push('tot');
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  for(var r=0;r<aoa.length;r++){ var k=kinds[r];
    for(var c=0;c<N;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'굴림', sz:17, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else {
        st.border=box; st.fill={ fgColor:{ rgb:(k==='tot'?'FCF8E3':'FFFFFF') } }; if(k==='tot') st.font.bold=true;
        st.alignment.horizontal = (o.num && o.num[c]) ? 'right' : ((o.left||[]).indexOf(c)>=0 ? 'left' : 'center');
        if(k==='row' && (o.date||[]).indexOf(c)>=0 && ws[ref].t==='n') ws[ref].z='yyyy-mm-dd';
        if(ws[ref].t==='n' && o.num && o.num[c]) ws[ref].z=o.num[c];
      }
      ws[ref].s=st; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:N-1 } }, { s:{ r:2, c:0 }, e:{ r:2, c:N-1 } } ];
  ws['!cols']=W.map(function(w,i){ return { wch:((o.date||[]).indexOf(i)>=0 ? 11 : (o.num && o.num[i] ? Math.max(w, 10) : w)) }; });
  ws['!rows']=aoa.map(function(a,i){ return { hpt:(i<2?18.75:16.5) }; });
  return ws;
}
function dser(v){ var d=d10(v); return d ? serial(d) : ''; }
function xls(){
  if(!window.XLSX){ err('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  if(!_q){ err('먼저 조회하세요.'); return; }
  var V=view(); if(!V.length){ err('엑셀로 낼 반품이 없습니다.'); return; }
  var t=totOf(V), ws, nm, QF='#,##0.###', AF='#,##0', RF='0.00', sale=saleSum(baseView(V));
  var rv=function(a, sl){ var x=rateOf(a, sl); return x==null ? '' : Math.round(x*100)/100; }, sv=function(sl){ return sl==null ? '' : sl; };
  if(KIND==='P'){   /* 매입 꼴 — 칸이 다르다(공급가·부가세·담당·창고 · 원천 칸 없음) */
    var pc=function(a){ return t.amt ? Math.round(a/t.amt*1000)/10 : 0; }, G2=(_tab==='d') ? null : groups(_tab, V), FP='#,##0.##';
    if(_tab==='d'){
      ws=sheetOf('[매입 반품내역]', ['일자','매입처','매입처코드','전표번호','품목코드','품명','규격','구분','수량','단가','공급가','부가세','반품액','담당','창고','비고'],
        sorted(V).map(function(r){ return [dser(r.dt), place(r), String(r.custCd||''), String(r.docNo||'')+(r.rowNo?'-'+r.rowNo:''), code(r), String(r.itemNm||''), String(r.spec||''),
          String(r.gb||'반품')+((n(r.qty)<0||n(r.amt)<0)?' (반품 취소)':'')+(r.undoYn==='Y'?' (원위치)':''), n(r.qty), n(r.price), n(r.supplyAmt), n(r.vatAmt), n(r.amt), String(r.mgrNm||''), String(r.whNm||''), String(r.remark||'')]; }),
        ['합 계', t.cnt+'건'+(rateOf(t.amt, sale)!=null?' · 반품율 '+rateTxt(t.amt, sale):''),'','','','','','','','', t.sup, t.vat, t.amt,'','',''], { date:[0], num:{ 8:QF, 9:FP, 10:AF, 11:AF, 12:AF }, left:[1,5,6,15] });
      nm=CFG.nm;
    } else if(_tab==='i'){
      ws=sheetOf('[매입 반품내역 — 품목별]', ['품목코드','품명','규격','건수','수량','반품액','매입액','반품율(%)','비중(%)','최근 반품일'],
        G2.map(function(g){ return [g.k, String(g.r0.itemNm||''), String(g.r0.spec||''), g.cnt, g.qty, g.amt, sv(g.sale), rv(g.amt, g.sale), pc(g.amt), dser(g.last)]; }),
        ['합 계', G2.length+'종','', t.cnt,'', t.amt, sv(sale), rv(t.amt, sale),'',''], { date:[9], num:{ 3:AF, 4:QF, 5:AF, 6:AF, 7:RF, 8:'0.0' }, left:[1,2] });
      nm=CFG.nm+'_품목별';
    } else if(_tab==='p'){
      ws=sheetOf('[매입 반품내역 — 매입처별]', ['매입처','건수','품목','반품액','매입액','반품율(%)','비중(%)','최근 반품일'],
        G2.map(function(g){ return [place(g.r0), g.cnt, Object.keys(g.items).length, g.amt, sv(g.sale), rv(g.amt, g.sale), pc(g.amt), dser(g.last)]; }),
        ['합 계 '+G2.length+'곳', t.cnt,'', t.amt, sv(sale), rv(t.amt, sale),'',''], { date:[7], num:{ 1:AF, 2:AF, 3:AF, 4:AF, 5:RF, 6:'0.0' }, left:[0] });
      nm=CFG.nm+'_매입처별';
    } else {
      ws=sheetOf('[매입 반품내역 — 월별]', ['월','건수','품목','반품액','매입액','반품율(%)','비중(%)'],
        G2.map(function(g){ return [g.k.slice(0,4)+'-'+g.k.slice(4,6), g.cnt, Object.keys(g.items).length, g.amt, sv(g.sale), rv(g.amt, g.sale), pc(g.amt)]; }),
        ['합 계', t.cnt,'', t.amt, sv(sale), rv(t.amt, sale),''], { num:{ 1:AF, 2:AF, 3:AF, 4:AF, 5:RF, 6:'0.0' } });
      nm=CFG.nm+'_월별';
    }
  } else
  if(_tab==='d'){
    ws=sheetOf('[매출 반품내역]', ['일자','원천','출고장','거래처·받는 곳','발주·전표번호','품목코드','정산서 코드','품명','규격','구분','수량','단위','단가','반품액','비고'],
      sorted(V).map(function(r){ var c=code(r), i=String(r.itemCd||'');
        return [dser(r.dt), SRC[r.src]||r.src, String(r.dcNm||''), [r.custNm, r.rcvNm].filter(function(x){ return x; }).join(' / '), String(r.docNo||'')+(r.src==='TRX' && r.rowNo?'-'+r.rowNo:''), c, (i && i!==c ? i : ''),
                String(r.itemNm||''), String(r.spec||''), String(r.gb||'반품'), n(r.qty), String(r.unit||''), n(r.price), n(r.amt), String(r.remark||'')]; }),
      ['합 계', t.cnt+'건'+(sale!=null && rateOf(t.amt, sale)!=null?' · 반품율 '+rateTxt(t.amt, sale):''),'','','','','','','','','','','', t.amt, ''], { date:[0], num:{ 10:QF, 12:'#,##0.##', 13:AF }, left:[2,3,7,8,14] });
    nm=CFG.nm;
  } else {
    var G=groups(_tab, V);
    if(_tab==='i'){
      ws=sheetOf('[매출 반품내역 — 품목별]', ['품목코드','품명','규격','건수','수량','단위','반품액','판매액','반품율(%)','비중(%)','최근 반품일'],
        G.map(function(g){ return [g.k, String(g.r0.itemNm||''), String(g.r0.spec||''), g.cnt, g.qty, String(g.r0.unit||''), g.amt, sv(g.sale), rv(g.amt, g.sale), (t.amt?Math.round(g.amt/t.amt*1000)/10:0), dser(g.last)]; }),
        ['합 계', G.length+'종','', t.cnt,'','', t.amt, sv(sale), rv(t.amt, sale),'',''], { date:[10], num:{ 3:AF, 4:QF, 6:AF, 7:AF, 8:RF, 9:'0.0' }, left:[1,2] });
      nm=CFG.nm+'_품목별';
    } else if(_tab==='p'){
      ws=sheetOf('[매출 반품내역 — 출고장·거래처별]', ['원천','출고장·거래처','건수','품목','반품액','판매액','반품율(%)','비중(%)','최근 반품일'],
        G.map(function(g){ return [SRC[g.r0.src]||g.r0.src, place(g.r0), g.cnt, Object.keys(g.items).length, g.amt, sv(g.sale), rv(g.amt, g.sale), (t.amt?Math.round(g.amt/t.amt*1000)/10:0), dser(g.last)]; }),
        ['합 계', G.length+'곳', t.cnt,'', t.amt, sv(sale), rv(t.amt, sale),'',''], { date:[8], num:{ 2:AF, 3:AF, 4:AF, 5:AF, 6:RF, 7:'0.0' }, left:[1] });
      nm=CFG.nm+'_출고장거래처별';
    } else {
      var by={}; V.forEach(function(r){ by[r.src]=(by[r.src]||0)+n(r.amt); });
      ws=sheetOf('[매출 반품내역 — 월별]', ['월','건수','품목','반품액','판매액','반품율(%)','비중(%)','정산서','판매전표','거래처 발주'],
        G.map(function(g){ return [g.k.slice(0,4)+'-'+g.k.slice(4,6), g.cnt, Object.keys(g.items).length, g.amt, sv(g.sale), rv(g.amt, g.sale), (t.amt?Math.round(g.amt/t.amt*1000)/10:0), n(g.by.STL), n(g.by.TRX), n(g.by.PO)]; }),
        ['합 계', t.cnt,'', t.amt, sv(sale), rv(t.amt, sale),'', n(by.STL), n(by.TRX), n(by.PO)], { num:{ 1:AF, 2:AF, 3:AF, 4:AF, 5:RF, 6:'0.0', 7:AF, 8:AF, 9:AF } });
      nm=CFG.nm+'_월별';
    }
  }
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, nm.slice(0,31));
  XLSX.writeFile(wb, nm+'_'+f8(_q.fr)+'~'+f8(_q.to)+'.xlsx');
  if(window._toast) _toast('📥 '+nm.replace(/_/g,' · ')+' — '+t.cnt+'건 · 반품액 '+fmt(t.amt)+'원'+(rateOf(t.amt, sale)!=null?' · 반품율 '+rateTxt(t.amt, sale):''),'ok');
}

/* ── 다시 보일 때 (셸 logiFrame) — 다른 화면에서 반품을 넣었을 수 있으니 같은 기간으로 다시 읽는다. 3초 안 재호출은 건너뛴다 ── */
var _shownAt=0;
window.konetShown=function(){ fit(); var t=Date.now(); if(t-_shownAt<3000) return; _shownAt=t; if(_q) load(); };

/* ── 시작 — 처음 기간 = 최근 3개월(이번 달 포함). 반품은 드물어 한 달로는 거의 비어 보인다 ── */
(function(){
  if(KIND==='P'){   /* 매입 꼴 — 원천은 하나라 고르기·원천별 카드를 숨기고 이름을 매입 말로 */
    el('srSrcWrap').style.display='none'; el('kSrcCard').style.display='none'; document.querySelector('.cards').style.gridTemplateColumns='repeat(4, minmax(130px, 200px))';
    el('lbPlace').textContent=CFG.place; el('srFind').placeholder='품목코드 · 품명 · 전표번호 · 비고'; el('tab-p').textContent='🏬 매입처별'; el('lbRateSub').textContent='· 반품액 ÷ 매입액';
    el('kRateCard').title='반품율 = 반품액 ÷ 매입액. 매입액 = 같은 기간의 반품 아닌 매입 줄 합계(부가세 포함)입니다. 매입처를 고르면 그 몫만 견줍니다';
  }
  var t=lsGet(CFG.tabKey); tab((t==='i'||t==='p'||t==='m')?t:'d');
  _shownAt=Date.now();
  setRange('m3');
})();
</script>
</body>
</html>
