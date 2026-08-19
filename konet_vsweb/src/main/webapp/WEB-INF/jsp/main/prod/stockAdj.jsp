<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- 알림·확인은 프로젝트 공통 표준(ui-message.js) — Swal 신규 사용 금지 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<title>재고 일괄조정</title>
<%-- 재고 일괄조정 (2026-08-19 신설)
     기존화면(거래처 시스템)의 [리스트조회] + [수정저장] 을 우리 구조로 옮긴 것.

     ★재고의 주인은 수불원장(TBL_STOCK_LEDGER) 하나다.
       수정값으로 덮어쓰지 않고 **차이만큼 조정행(IO_GB='A')** 을 더한다.
       덮어쓰면 과거 이력이 사라지고, 같은 날 두 번 저장하면 값이 겹쳐 어긋난다.
     ★매입등록(단가 0)으로 맞추지 않는다 — 이동평균 분모에 들어가 재고금액이 낮아진다.
       조정행은 단가를 안 넣어 그 문제가 없다.
     ★BOX/EA 는 화면 표기일 뿐이다. 원장에는 EA 로 환산해 담는다(EA = BOX × 입수수량 + EA).
     ★창고는 아직 나누지 않는다 — 원장에 창고 칸이 없다. 드롭다운은 자리만 잡아 둔다. --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; overflow:hidden; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  /* ★[2026-08-19 요청 「상단을 조금 줄이고 조정이력을 위로 확대」] 위쪽 여백·조회줄 패딩을 한 단계씩 줄였다 */
  .wrap{ padding:4px 11px 8px; height:100%; display:flex; flex-direction:column; min-height:0; }

  .bar{ display:flex; flex-wrap:wrap; align-items:center; gap:4px 8px; padding:5px 10px;
        background:#fff; border:1px solid var(--bd); border-radius:8px; margin-bottom:6px; }
  .bar label{ font-size:13px; color:#48606f; font-weight:600; }
  .bar select, .bar input[type=text], .bar input[type=date]{
        height:30px; border:1px solid #cbd5e1; border-radius:5px; padding:0 8px; font-size:13px;
        font-family:inherit; }
  .bar .sp{ flex:1; }

  .btn{ height:30px; border:1px solid var(--teal); background:var(--teal); color:#fff;
        border-radius:5px; padding:0 14px; font-size:13px; font-weight:700; cursor:pointer; }
  .btn.ghost{ background:#fff; color:var(--teal); }
  .btn.warn{ background:#fff; color:#b23b3b; border-color:#b23b3b; }
  .btn[disabled]{ background:#b9c8d2; border-color:#b9c8d2; color:#fff; cursor:not-allowed; }

  /* 목록이 남는 공간을 전부 쓰고, 넘치면 이 안에서만 스크롤된다(머리글은 sticky).
     ★flex-basis 를 0 으로 두어야 아래 [사유줄]·[이력]이 커져도 목록이 밀리지 않는다. */
  .grid{ flex:1 1 0; min-height:0; overflow:auto; background:#fff; border:1px solid var(--bd); border-radius:8px; }
  .foot, .hist{ flex:0 0 auto; }
  table{ width:100%; min-width:1240px; border-collapse:collapse; font-size:13px; }
  thead th{ position:sticky; top:0; z-index:2; background:#eef2f5; border-bottom:1px solid #c8d4dd;
            padding:7px 8px; font-weight:700; color:#3a4a53; white-space:nowrap; }
  tbody td{ border-bottom:1px solid #eef1f4; padding:5px 8px; white-space:nowrap; }
  tbody tr:hover{ background:#f7fbfa; }
  td.r, th.r{ text-align:right; }
  td.c, th.c{ text-align:center; }
  .dim{ color:#9aa8b2; }
  .neg{ color:#b23b3b; font-weight:700; }          /* 음수 재고 = 입고 누락 신호 */

  input.ed{ width:78px; height:26px; border:1px solid #cbd5e1; border-radius:4px;
            padding:0 6px; font-size:13px; text-align:right; font-family:inherit; }
  input.ed:focus{ outline:none; border-color:var(--teal); }
  tr.chg{ background:#fff8e8; }                     /* 고친 줄 */
  tr.chg:hover{ background:#fff3d8; }
  /* ★[2026-08-19 요청] 상품코드등록과 같은 표시 — 거래중지 상품은 줄 전체 빨간색.
     ⚠chg(고친 줄)보다 뒤에 둔다 — 중지 표시가 누런 배경에 묻히면 안 된다. */
  tr.stopped, tr.stopped:hover, tr.stopped.chg{ background:#fff4f3; }
  /* ★!important — 음수(.neg) 등 칸에 박은 색을 이기고 줄 전체가 빨강이 되게(2026-08-19 재지적 「중지된 코드는 빨간색」) */
  tr.stopped td{ color:#c0392b !important; }
  /* 서브 배지·주코드 링크·마스터 상품명 — 상품코드등록(prodcd.jsp)과 같은 모양 */
  .subbdg{ display:inline-block; padding:0 5px; border-radius:8px; background:#fdecea; color:#c0392b;
           font-size:12px; font-weight:700; }
  /* ★[2026-08-19 확정 「여기서는 주코드 보여주는 것」] 주코드는 **표시 전용** —
     처음엔 링크(검색 이동 → 스크롤 이동)를 달았다가 액션 자체를 걷어냈다.
     이 화면은 재고를 고치는 곳이지 코드를 다루는 곳이 아니다 — 코드 정리는 상품코드등록에서.
     다시 달자는 얘기가 나오면 이 이력부터 확인할 것. */
  .subgo{ font-size:12.5px; color:#1f7a4d; font-weight:700; }
  .subgo.stop{ color:#c0392b; }              /* 주코드가 중지면 빨강 */
  .mstnm{ font-size:11.5px; color:#8a97a3; margin-top:2px; white-space:normal; }
  .stopbdg{ display:inline-block; padding:0 5px; border-radius:8px; background:#eceff1; color:#546e7a;
            font-size:11px; font-weight:700; }
  .diff{ font-weight:800; }
  .diff.up{ color:#1f7a4b; }
  .diff.dn{ color:#b23b3b; }

  .foot{ display:flex; align-items:center; gap:12px; padding:5px 10px; margin-top:6px;
         background:#fff; border:1px solid var(--bd); border-radius:8px; font-size:13px; }
  .foot b{ color:var(--teal); }
  /* ── 하단 조정 이력 ─────────────────────────────────────────── */
  .hist{ margin-top:6px; background:#fff; border:1px solid var(--bd); border-radius:8px;
         display:flex; flex-direction:column; min-height:0; }
  .hist.off .hgrid{ display:none; }
  .htab{ display:flex; align-items:center; gap:6px 10px; padding:6px 10px; border-bottom:1px solid var(--bd); }
  .htab .tb{ height:26px; border:1px solid var(--teal); background:#fff; color:var(--teal);
             border-radius:5px; padding:0 12px; font-size:13px; font-weight:700; cursor:pointer; }
  .htab .tb.on{ background:var(--teal); color:#fff; }
  .htab label{ font-size:13px; color:#48606f; font-weight:600; }
  .htab input{ height:26px; border:1px solid #cbd5e1; border-radius:4px; padding:0 7px;
               font-size:13px; font-family:inherit; }
  /* ★이력이 높아진 만큼 위 목록(.grid, flex:1)이 자연히 줍어든다 — 28vh → 40vh (2026-08-19 요청) */
  .hgrid{ max-height:40vh; overflow:auto; }
  .hgrid table{ font-size:12.5px; }
  .hgrid thead th{ background:#f4f7f8; }
  .undo{ height:22px; border:1px solid #b23b3b; background:#fff; color:#b23b3b;
         border-radius:4px; padding:0 8px; font-size:11.5px; font-weight:700; cursor:pointer; }
  /* ★[2026-08-19 요청 「모래시계」] 조회 중 오버레이 — 진짜 작업 중이라 클릭을 막는다
     (조회가 도는 사이 [수정저장]·재조회가 겹치면 안 된다 — shpProgOv 와 같은 원칙). */
  .busy{ position:fixed; inset:0; background:rgba(255,255,255,.45); display:none; z-index:999;
         align-items:center; justify-content:center; cursor:progress; }
  .busy.on{ display:flex; }
  .busy .bx{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:13px 24px;
             font-size:14.5px; font-weight:700; color:var(--teal); box-shadow:0 8px 26px rgba(0,0,0,.18); }
  .busy .hg{ display:inline-block; animation:hgFlip 1.2s linear infinite; margin-right:6px; }
  @keyframes hgFlip{ 0%,80%{ transform:rotate(0) } 90%,100%{ transform:rotate(180deg) } }
</style>
</head>
<body>
<div class="wrap">

  <div class="bar">
    <label>창고</label>
    <select id="whCd" title="원장에 창고 구분이 없어 지금은 하나입니다">
      <option value="">물류창고</option>
    </select>

    <label>정렬</label>
    <select id="sortGb">
      <option value="CD">코드</option>
      <option value="NM">상품명</option>
      <option value="QTY">재고</option>
    </select>

    <label><input type="checkbox" id="zeroExc"> 재고 0 제외</label>

    <label>기준일자</label>
    <input type="date" id="baseDt">

    <button type="button" class="btn ghost" onclick="load();">리스트조회</button>
    <button type="button" class="btn" id="btnSave" onclick="save();">수정저장</button>
    <button type="button" class="btn ghost" onclick="packAuto();"
            title="상품명 끝의 1000EA/BOX · 300EA · 2000매 같은 숫자를 읽어 입수수량에 채웁니다">입수수량 자동채우기</button>

    <span class="sp"></span>

    <label>상품</label>
    <input type="text" id="findData" placeholder="코드 · 상품명 · 규격 — 치면 바로 조회" style="width:210px"
           oninput="liveFind();" onkeydown="if(event.keyCode===13){ clearTimeout(FIND_T); _ALL.length?applyFilter():load(); }">
    <label>유형</label>
    <select id="typeNm"><option value="">전체</option></select>
    <label>제조사</label>
    <select id="makerNm"><option value="">전체</option></select>
  </div>

  <div class="grid">
    <table>
      <thead>
        <tr>
          <th style="width:110px">상품코드</th>
          <th>상품명</th>
          <th style="width:170px">규격</th>
          <th class="r" style="width:80px">입수수량</th>
          <th style="width:130px">유형</th>
          <%-- ★[2026-08-19 요청] 상품코드등록처럼 중지일도 보여 준다 --%>
          <th class="c" style="width:95px" title="거래중지 시작일 — 이 날짜부터 매입·판매에서 막힙니다">중지일</th>
          <th class="r" style="width:90px">BOX재고</th>
          <th class="r" style="width:80px">EA재고</th>
          <th class="r" style="width:95px">합계재고</th>
          <th class="c" style="width:95px">수정BOX재고</th>
          <th class="c" style="width:95px">수정EA재고</th>
          <th class="r" style="width:90px">증감</th>
        </tr>
      </thead>
      <tbody id="body">
        <tr><td colspan="12" class="c dim" style="padding:26px">[리스트조회] 를 눌러 주세요.</td></tr>
      </tbody>
    </table>
  </div>

  <div class="foot">
    <span id="cnt" class="dim">—</span>
    <span>고친 줄 <b id="chgCnt">0</b></span>
    <span class="sp" style="flex:1"></span>
    <label>사유</label>
    <input type="text" id="remark" placeholder="재고 일괄조정 (이력에 남습니다)" style="width:280px; height:26px;
           border:1px solid #cbd5e1; border-radius:4px; padding:0 7px; font-size:13px; font-family:inherit;">
  </div>


  <%-- ── 하단 : 조정 이력 ─────────────────────────────────────────────
       원장에는 차이만 남는다. 여기서는 '전 → 후' 와 저장 묶음을 보여준다.
       묶음(BATCH_NO) 단위로 되돌릴 수 있다 — 원장 조정행도 함께 내려간다. --%>
  <div class="hist" id="histBox">
    <div class="htab">
      <button type="button" class="tb on" onclick="hisToggle();" id="hisTab">📜 조정 이력</button>
      <span class="sp" style="flex:1"></span>
      <label>기간</label>
      <input type="date" id="hFrom"> ~ <input type="date" id="hTo">
      <label>등록자</label>
      <input type="text" id="hUser" style="width:110px" placeholder="아이디">
      <button type="button" class="btn ghost" onclick="hisLoad();">이력조회</button>
    </div>
    <div class="hgrid" id="hisWrap">
      <table>
        <thead>
          <tr>
            <th style="width:150px">저장묶음</th>
            <th style="width:95px">기준일자</th>
            <th style="width:110px">상품코드</th>
            <th>상품명</th>
            <th class="r" style="width:90px">전</th>
            <th class="r" style="width:90px">후</th>
            <th class="r" style="width:80px">증감</th>
            <th style="width:150px">사유</th>
            <th style="width:100px">등록자</th>
            <th style="width:140px">등록일시</th>
            <th class="c" style="width:80px">되돌리기</th>
          </tr>
        </thead>
        <tbody id="hisBody">
          <tr><td colspan="11" class="c dim" style="padding:18px">[이력조회] 를 눌러 주세요.</td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%-- ★조회 중 모래시계 (2026-08-19 요청) --%>
<div class="busy" id="busyOv"><div class="bx"><span class="hg">⏳</span><span class="tx">목록을 조회하는 중입니다…</span></div></div>

<script type="text/javascript">
var CTX  = '${pageContext.request.contextPath}';
var ROWS = [];        /* 화면에 보이는 목록(= _ALL 을 검색·필터·정렬한 결과) */
var _ALL = [];        /* ★[2026-08-19 요청 「조회가 느림」] 서버에서 받은 전 품목 —
                          서버는 **기준일자가 바뀔 때만** 부른고(재고 누계가 그 날짜 기준이라),
                          검색어·유형·제조사·재고0제외·정렬은 applyFilter 가 화면에서 바로 건다.
                          종전에는 글자 칠 때마다 원장 집계 쿼리가 돌아 느렸다. */

function gel(id){ return document.getElementById(id); }
function esc(s){ return String(s == null ? '' : s)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function nvl(v){ return (v == null || v === '') ? 0 : Number(v); }
function alertBox(msg, icon){
  if (window._alertBox) window._alertBox(msg, { icon: icon || 'ℹ️' });
  else alert(String(msg).replace(/<[^>]+>/g,''));
}
function toast(msg){ if (window._toast) window._toast(msg); }
/* 모래시계 — 서버 조회 동안만 켜진다. ⚠끄는 것은 반드시 응답 도착 지점 모두에서(then·catch) —
   한 곳이라도 빠지면 '진행 중'으로 영영 남는다(RebuildProgress 전례). */
function busy(on, msg){
  var b=gel('busyOv'); if(!b) return;
  if(msg){ var t=b.querySelector('.tx'); if(t) t.textContent=msg; }
  b.classList.toggle('on', !!on);
}

/* ★[2026-08-19 요청] 상품코드등록(prodcd.jsp)과 같은 표시를 이 화면에도 —
     · 서브코드면 빨간 「서브」 배지 + → 주코드 + 마스터 상품명
     · 거래중지면 줄 전체 빨강 + 중지일 칸
   ★서버 SQL(selectStockAdjList)은 안 고친다 — 이미 있는 두 조회(prodList·extItemList)를
     한 번씩 받아 화면에서 짝을 맞춨다. **JSP만 바꿔 WAR 재빌드가 없다.**
   ★늘게 도착해도 맞는다 — 보조자료가 오면 목록이 이미 떠 있을 때만 다시 그린다. */
var _pm = {}, _subOf = {}, _auxOk = false;   /* _pm = prodSeq→상품줄(중지·이름) / _subOf = 서브코드→통보줄 */
function fmtDt8(v){ v=String(v||'').replace(/-/g,''); return v.length===8 ? v.slice(0,4)+'-'+v.slice(4,6)+'-'+v.slice(6,8) : v; }
(function(){
  function post(u){ return fetch(CTX+u, { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
                                          credentials:'same-origin', body:'' }).then(function(r){ return r.json(); }); }
  Promise.all([ post('/prod/prodList.do'), post('/prod/extItemList.do') ])
    .then(function(a){
      ((a[0]&&a[0].data)||[]).forEach(function(o){ _pm[o.prodSeq]=o; });
      /* 서브 판정은 prodcd.jsp 와 같은 규칙 — 통보 코드와 주코드가 다를 때만 서브다 */
      ((a[1]&&a[1].data)||[]).forEach(function(o){
        if(o.prodCd && o.extItemCd && String(o.extItemCd)!==String(o.prodCd)) _subOf[String(o.extItemCd)]=o;
      });
      _auxOk=true;
      if(ROWS.length) render();          /* 목록이 먼저 떠 있으면 표시만 덧그린다 */
    })
    .catch(function(){ /* 보조표시만 빠질 뿐 조정 자체는 동작한다 — 조용히 넘어간다 */ });
})();

/* 오늘 날짜를 기본값으로 */
(function(){
  var d = new Date();
  gel('baseDt').value = d.getFullYear() + '-'
      + ('0'+(d.getMonth()+1)).slice(-2) + '-' + ('0'+d.getDate()).slice(-2);
})();


/* ── 치는 대로 조회 ──────────────────────────────────────────────────
   [리스트조회] 를 누르지 않아도 검색어를 치면 바로 나온다.
   ★글자마다 서버를 부르면 2,000품목 조회가 겹친다 — 350ms 쉬면 부른다(디바운스).
   ★한 글자는 결과가 너무 넓어 부르지 않는다. 두 글자부터, 또는 비우면(전체) 부른다. */
var FIND_T = null;
function liveFind(){
  clearTimeout(FIND_T);
  /* ★[2026-08-19] 서버가 아니라 _ALL 을 걸러 바로 그린다 — 왕33복이 없으니
     한 글자 제한도 필요 없고, 디바운스는 그리기 비용만 아끼는 150ms 로 줄였다. */
  FIND_T = setTimeout(function(){
    if (!_ALL.length){ load(); return; }  /* 아직 안 읽었으면 그때 한 번만 서버를 부른다 */
    applyFilter();
  }, 150);
}

/* 드롭다운·체크·날짜는 바꾸는 즉시 조회 */
(function(){
  /* ★기준일자만 서버 재조회(재고 누계가 그 날짜 기준) — 나머지는 화면 필터만 재적용(2026-08-19) */
  ['sortGb','typeNm','makerNm'].forEach(function(id){
    var el = gel(id); if (el) el.onchange = function(){ if (_ALL.length) applyFilter(); };
  });
  var b = gel('baseDt'); if (b) b.onchange = function(){ load(); };
  var z = gel('zeroExc'); if (z) z.onchange = function(){ if (_ALL.length) applyFilter(); };
})();

/* ★검색·필터·정렬을 _ALL 에 걸어 ROWS 를 만든다 — 서버 SQL 과 같은 규칙
   (검색 = 코드·상품명·규격 부분일치 / 유형·제조사 일치 / 재고 0 제외 / 정렬 CD·NM·QTY).
   ⚠규칙을 바꾸면 selectStockAdjList 쪽 필터도 같이 볼 것 — 이 화면은 이제 안 타지만
   SQL 에는 그대로 남아 있다(다른 호출부가 쓸 수 있어 안 지웠다). */
var _fltSig = '';   /* 마지막으로 그린 조건 — 같으면 재렌더 생략(2026-08-19 「순간순간 늦다」) */
var _allVer = 0;    /* load() 가 새 자료를 받을 때마다 올린다 — 같은 조건이라도 새 자료면 다시 그린다 */
function applyFilter(){
  var q  = gel('findData').value.trim().toLowerCase();
  var ty = gel('typeNm').value, mk = gel('makerNm').value, z0 = gel('zeroExc').checked;
  var sig = [q, ty, mk, z0?1:0, gel('sortGb').value, _allVer].join('|');
  if (sig === _fltSig) return;   /* 조건이 그대로면 2,000행을 또 그리지 않는다(수정 중이던 값도 안 날린다) */
  _fltSig = sig;
  ROWS = _ALL.filter(function(r){
    if (z0 && nvl(r.curQty) === 0) return false;
    if (ty && String(r.typeNm||'')  !== ty) return false;
    if (mk && String(r.makerNm||'') !== mk) return false;
    if (!q) return true;
    return [r.prodCd, r.prodNm, r.spec].some(function(v){
      return String(v||'').toLowerCase().indexOf(q) >= 0; });
  });
  var sg = gel('sortGb').value;
  ROWS.sort(function(a,b){
    if (sg === 'QTY'){ var d = nvl(b.curQty) - nvl(a.curQty); if (d) return d; }
    else if (sg === 'NM'){ var n = String(a.prodNm||'').localeCompare(String(b.prodNm||''),'ko'); if (n) return n; }
    return String(a.prodCd||'') < String(b.prodCd||'') ? -1 : (String(a.prodCd||'') > String(b.prodCd||'') ? 1 : 0);
  });
  render();
}
/* ── 목록 ────────────────────────────────────────────────────────── */
function load(){
  /* ★서버에는 **기준일자만** 보낸다(2026-08-19) — 전 품목을 받아 두고
     검색·필터·정렬은 applyFilter 가 화면에서 건다 — 글자 칠 때마다
     원장 집계 쿼리가 도는 것이 느린 원인이었다. */
  var p = new URLSearchParams();
  p.append('asOfDt',    gel('baseDt').value || '');

  gel('body').innerHTML = '<tr><td colspan="12" class="c dim" style="padding:26px">불러오는 중…</td></tr>';

  busy(true, '목록을 조회하는 중입니다…');           /* ★모래시계 — 문구는 '조회'(2026-08-19 지적: 재고집계 아님) */
  fetch(CTX + '/prod/stockAdjList.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body: p.toString() })
    .then(function(r){ return r.json(); })
    /* ★busy 는 applyFilter(=2,000행 그리기) 뒤에 끈다 — 그리기도 체감 대기시간이다.
       applyFilter 가 터져도 아래 catch 가 받아 busy(false) 를 불러 안 남는다. */
    .then(function(d){ _ALL = (d && d.data) || []; _allVer++; fillFilters(); applyFilter(); busy(false); })
    .catch(function(){ busy(false); alertBox('목록을 불러오지 못했습니다.', '⚠️'); });
}

function render(){
  if (!ROWS.length){
    gel('body').innerHTML = '<tr><td colspan="12" class="c dim" style="padding:26px">자료가 없습니다.</td></tr>';
    gel('cnt').textContent = '0건';
    gel('chgCnt').textContent = '0';
    return;
  }
  gel('body').innerHTML = ROWS.map(function(r, i){
    var cur = nvl(r.curQty);
    /* ★상품코드등록과 같은 표시(2026-08-19) — 서브 배지 + → 주코드 + 마스터 상품명 / 중지행 빨강 */
    var st=_pm[r.prodSeq]||{}, stopped=(st.stopYn==='Y');
    var sb=_subOf[String(r.prodCd)], cdCell=esc(r.prodCd), mstNm='';
    if(stopped) cdCell='<span style="white-space:nowrap">'+cdCell+' <span class="stopbdg">중지</span></span>';
    if(sb){
      var mp=_pm[sb.prodSeq]||{};
      /* ★주코드가 중지된 상품이면 링크도 빨강 + (중지) — 누르기 전에 알아보게(2026-08-19) */
      var mStop=(mp.stopYn==='Y');
      /* ★주코드는 여기서 **보여주기만** 한다(2026-08-19 확정) — 누르는 자리 아님 */
      cdCell += '<div style="margin-top:2px"><span class="subbdg">서브</span>'
             +  ' <span class="subgo'+(mStop?' stop':'')+'"'
             +  ' title="이 코드는 주코드 '+esc(sb.prodCd)+' 의 매칭코드입니다'+(mStop?' (거래중지된 상품)':'')+'">→ '
             +  esc(sb.prodCd)+(mStop?' (중지)':'')+'</span></div>';
      if(mp.prodNm) mstNm='<div class="mstnm">마스터 : '+esc(mp.prodNm)+'</div>';
    }
    return '<tr id="tr'+i+'"'+(stopped?' class="stopped"':'')+'>'
      + '<td>' + cdCell + '</td>'
      + '<td style="white-space:normal">' + esc(r.prodNm) + mstNm + '</td>'
      + '<td>' + esc(r.spec) + '</td>'
      + '<td class="c"><input class="ed pk" id="pk'+i+'" value="' + nvl(r.packQty) + '"'
      +     ' title="입수수량(BOX당 EA) — 엔터를 치거나 칸을 벗어나면 BOX/EA 가 다시 나뉩니다"'
      +     ' onkeydown="if(event.keyCode===13){ packChg(' + i + '); this.blur(); }"'
      +     ' onchange="packChg(' + i + ')"></td>'
      + '<td>' + esc(r.typeNm) + '</td>'
      /* 중지일 — 중지된 상품만 적힌다(2026-08-19) */
      + '<td class="c">' + (stopped ? esc(fmtDt8(st.stopFrDt)) : '') + '</td>'
      + '<td class="r" id="vb'+i+'">' + nvl(r.boxQty) + '</td>'
      + '<td class="r" id="ve'+i+'">' + nvl(r.eaQty) + '</td>'
      + '<td class="r' + (cur < 0 ? ' neg' : '') + '">' + cur + '</td>'
      + '<td class="c"><input class="ed" id="bx'+i+'" value="' + nvl(r.boxQty) + '"'
      +     ' oninput="chg(' + i + ')"></td>'
      + '<td class="c"><input class="ed" id="ea'+i+'" value="' + nvl(r.eaQty) + '"'
      +     ' oninput="chg(' + i + ')"></td>'
      + '<td class="r" id="df'+i+'"><span class="dim">-</span></td>'
      + '</tr>';
  }).join('');
  gel('cnt').textContent = ROWS.length + '건';
  /* ★[2026-08-19 「순간순간 늦다」] 종전에는 여기서 전 행에 chg() 를 돌렸다(2,000행×DOM 조회 5회 ≈ 1만 회).
     그린 직후에는 수정칸 = 현재값이라 **증감이 전부 0** — 증감 칸은 HTML 에 '-' 로 바로 박고
     건수만 0 으로 맞춘다. 값을 손대면 그때 chg(i) 가 그 한 줄만 다시 계산한다. */
  gel('chgCnt').textContent = '0';
}


/* ── 입수수량 자동채우기 ─────────────────────────────────────────────
   상품명 끝에 적힌 포장 단위를 읽어 입수수량 칸에 넣는다.

     크라프트사각용기몸체,…,300EA           → 300
     OPP봉투,20*25CM,2000EA/BOX             → 2000
     (25입)수제샌드위치…,300EA               → 300
     1883 시럽 1.0L*6ea묶음                  → 6
     자스민8/9oz 컵(백색)/1000매(AFP)        → 1000
     8KG(200EA/BOX)                          → 200

   ★규칙 : 숫자 바로 뒤에 EA·매·장·입·PCS 가 붙은 것만 잡는다.
     치수(MM·CM)·용량(OZ·KG·L)은 단위가 달라 걸리지 않는다.
   ★여러 개면 **마지막 것**을 쓴다 — 포장 단위는 이름 끝에 붙는다.
   ★바로 저장하지 않는다. 칸에 채워만 두니 눈으로 보고 고친 뒤 [수정저장] 을 누르면 된다. */
var PACK_RE = /([0-9][0-9,]*)\s*(EA|PCS|매|장|입)(?![A-Za-z0-9])/gi;

function packOf(nm){
  if (!nm) return 0;
  var m, last = 0;
  PACK_RE.lastIndex = 0;
  while ((m = PACK_RE.exec(nm)) !== null){
    var v = parseInt(String(m[1]).replace(/,/g,''), 10);
    if (v > 0 && v <= 1000000) last = v;      /* 터무니없는 값은 버린다 */
  }
  return last;
}

function packAuto(){
  if (!ROWS.length){ alertBox('먼저 목록을 조회해 주세요.', '⚠️'); return; }

  var hit = 0, skip = 0, same = 0;
  for (var i = 0; i < ROWS.length; i++){
    var v = packOf(ROWS[i].prodNm);
    if (!v){ skip++; continue; }               /* 이름에 포장 단위가 없다 */
    if (v === curPack(i)){ same++; continue; } /* 이미 같은 값 */
    gel('pk'+i).value = v;
    packChg(i);                                /* BOX/EA 표시도 다시 나눈다 */
    hit++;
  }

  var msg = '<div style="text-align:left; line-height:1.8">'
          + '<b>' + hit + '건</b> 을 채웠습니다.<br>'
          + '<span style="color:#7b8b97">이미 맞음 ' + same + '건 · 이름에 단위 없음 ' + skip + '건</span><br>'
          + '<b>아직 저장 전입니다.</b> 값을 확인하신 뒤 [수정저장] 을 눌러 주세요.</div>';
  alertBox(msg, hit ? '✅' : 'ℹ️');
}
/* 화면에 적힌 입수수량 (비었거나 1 미만이면 1) */
function curPack(i){
  var v = nvl(gel('pk'+i) ? gel('pk'+i).value : 0);
  return v < 1 ? 1 : v;
}


/* 입수수량을 고쳤을 때 — 재고를 새 기준으로 다시 나눠 보여준다.
   ★수정칸도 같이 맞춰 준다. 안 그러면 BOX칸의 옛 숫자가 새 입수수량으로 곱해져
     건드리지도 않은 재고가 크게 바뀐 것처럼 잡힌다(2026-08-19 지적).
   ★재고 자체는 안 바뀐다 — 나누는 기준만 바뀐다. */
function packChg(i){
  var r    = ROWS[i];
  var pack = curPack(i);
  var cur  = nvl(r.curQty);
  var sign = cur < 0 ? -1 : 1;
  var box  = sign * Math.floor(Math.abs(cur) / pack);
  var ea   = sign * (Math.abs(cur) % pack);

  gel('vb'+i).textContent = box;      // 표시 BOX재고
  gel('ve'+i).textContent = ea;       // 표시 EA재고
  gel('bx'+i).value = box;            // 수정칸도 같은 값으로 — 증감 0 이 된다
  gel('ea'+i).value = ea;

  chg(i);
}
/* 한 줄의 증감 계산 — 고친 줄만 표시가 바뀐다 */
function chg(i, quiet){
  var r    = ROWS[i];
  var pack = curPack(i);                       /* 화면에서 고친 입수수량을 쓴다 */
  var aft  = nvl(gel('bx'+i).value) * pack + nvl(gel('ea'+i).value);
  var diff = aft - nvl(r.curQty);

  var td = gel('df'+i), tr = gel('tr'+i);
  if (diff === 0){
    td.innerHTML = '<span class="dim">-</span>';
    tr.classList.remove('chg');
  } else {
    td.innerHTML = '<span class="diff ' + (diff > 0 ? 'up' : 'dn') + '">'
                 + (diff > 0 ? '+' : '') + diff + '</span>';
    tr.classList.add('chg');
  }
  if (!quiet) countChg();
  else if (i === ROWS.length - 1) countChg();
}

function countChg(){
  var n = 0;
  for (var i = 0; i < ROWS.length; i++){
    var pack = curPack(i);
    var aft  = nvl(gel('bx'+i).value) * pack + nvl(gel('ea'+i).value);
    if (aft - nvl(ROWS[i].curQty) !== 0) n++;
  }
  gel('chgCnt').textContent = n;
  return n;
}

/* 유형·제조사 드롭다운은 불러온 자료에서 만든다 */
function fillFilters(){
  ['typeNm','makerNm'].forEach(function(k){
    var sel = gel(k), keep = sel.value, seen = {}, opts = ['<option value="">전체</option>'];
    _ALL.forEach(function(r){                 /* ★걸러진 ROWS 가 아니라 전 품목 — 고를수록 선택지가 줄면 안 된다 */
      var v = r[k];
      if (v && !seen[v]){ seen[v] = 1; opts.push('<option value="'+esc(v)+'">'+esc(v)+'</option>'); }
    });
    sel.innerHTML = opts.join('');
    sel.value = keep;
  });
}

/* ── 저장 ────────────────────────────────────────────────────────────
   두 가지를 함께 저장한다.
     ① 입수수량  — 고친 것만. 재고는 안 건드리고 환산 기준만 바뀐다.
     ② 재고 조정 — 차이만큼 조정행(A) + 이력.
   ★입수수량을 먼저 저장한다. 나중에 하면 조정 이력에 옛 입수수량이 박힌다. */
function save(){
  if (!ROWS.length){ alertBox('먼저 목록을 조회해 주세요.', '⚠️'); return; }

  var packs = [], rows = [];
  for (var i = 0; i < ROWS.length; i++){
    var r    = ROWS[i];
    var pack = curPack(i);
    var aBox = nvl(gel('bx'+i).value), aEa = nvl(gel('ea'+i).value);

    // ① 입수수량이 바뀐 줄
    if (pack !== (nvl(r.packQty) < 1 ? 1 : nvl(r.packQty)))
      packs.push({ prodSeq:r.prodSeq, packQty:pack });

    // ② 재고가 바뀐 줄 — 안 고쳤으면 보내지 않는다
    if (aBox * pack + aEa - nvl(r.curQty) === 0) continue;
    rows.push({ prodSeq:r.prodSeq, prodCd:r.prodCd, packQty:pack,
                befQty:nvl(r.curQty), befBox:nvl(r.boxQty), befEa:nvl(r.eaQty),
                aftBox:aBox, aftEa:aEa });
  }

  if (!packs.length && !rows.length){ alertBox('고친 줄이 없습니다.', 'ℹ️'); return; }

  var post = function(url, body){
    return fetch(CTX + url, { method:'POST', headers:{'Content-Type':'application/json'},
                              credentials:'same-origin', body: JSON.stringify(body) })
             .then(function(r){ return r.json(); });
  };

  var go = function(){
    gel('btnSave').disabled = true;
    busy(true, '저장하는 중입니다…');            /* ★모래시계 (2026-08-19) — load() 가 이어서 제 문구로 갈아끼운다 */

    // 입수수량 먼저 → 그 다음 재고 조정
    var step1 = packs.length ? post('/prod/packQtySave.do', { rows: packs })
                             : Promise.resolve({ result:'OK', cnt:0 });

    step1.then(function(d1){
      if (!d1 || d1.result !== 'OK') throw new Error((d1 && d1.message) || '입수수량 저장 실패');
      if (!rows.length) return { result:'OK', cnt:0, _skip:true };
      return post('/prod/stockAdjSave.do',
                  { baseDt: gel('baseDt').value, remark: gel('remark').value.trim(), rows: rows });
    })
    .then(function(d2){
      gel('btnSave').disabled = false;
      if (!d2 || d2.result !== 'OK') throw new Error((d2 && d2.message) || '재고 조정 실패');
      var msg = [];
      if (packs.length) msg.push('입수수량 ' + packs.length + '건');
      if (rows.length)  msg.push('재고 ' + (d2.cnt || 0) + '건');
      toast(msg.join(' · ') + ' 저장했습니다.');
      load();                                   /* 바뀐 값으로 다시 그린다 */
    })
    .catch(function(e){
      gel('btnSave').disabled = false;
      busy(false);
      alertBox('저장하지 못했습니다.<br>' + esc(e && e.message ? e.message : ''), '⚠️');
    });
  };

  var lines = [];
  if (packs.length) lines.push('입수수량 <b>' + packs.length + '건</b> — 환산 기준만 바뀝니다(재고 그대로).');
  if (rows.length)  lines.push('재고 <b>' + rows.length + '건</b> 을 <b>'
                             + esc(gel('baseDt').value) + '</b> 자로 조정합니다.');

  if (window._confirmBox){
    window._confirmBox({
      icon: '❓',
      msg: '<div style="text-align:left; line-height:1.7">' + lines.join('<br>') + '</div>',
      okText: '저장',
      onOk: go
    });
  } else if (confirm('저장할까요?')) go();
}

/* ── 하단 조정 이력 ──────────────────────────────────────────────── */
function hisToggle(){
  var box = gel('histBox'), tab = gel('hisTab');
  box.classList.toggle('off');
  tab.classList.toggle('on', !box.classList.contains('off'));
  if (!box.classList.contains('off') && gel('hisBody').children.length <= 1) hisLoad();
}

function hisLoad(){
  var p = new URLSearchParams();
  p.append('dtFrom',  gel('hFrom').value || '');
  p.append('dtTo',    gel('hTo').value   || '');
  p.append('regUser', gel('hUser').value.trim());

  gel('hisBody').innerHTML = '<tr><td colspan="11" class="c dim" style="padding:18px">불러오는 중…</td></tr>';

  busy(true, '조정 이력을 불러오는 중입니다…');   /* ★모래시계 (2026-08-19) */
  fetch(CTX + '/prod/stockAdjHisList.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body: p.toString() })
    .then(function(r){ return r.json(); })
    .then(function(d){
      busy(false);
      var rows = (d && d.data) || [];
      if (!rows.length){
        gel('hisBody').innerHTML =
          '<tr><td colspan="11" class="c dim" style="padding:18px">조정 이력이 없습니다.</td></tr>';
        return;
      }
      /* 같은 묶음은 첫 줄에만 번호와 [되돌리기] 를 보여준다 — 한 번의 저장이 한 덩어리로 읽힌다 */
      var prev = null;
      gel('hisBody').innerHTML = rows.map(function(h){
        var head = (h.batchNo !== prev); prev = h.batchNo;
        var diff = nvl(h.diffQty);
        return '<tr>'
          + '<td>' + (head ? esc(h.batchNo) : '<span class="dim">〃</span>') + '</td>'
          + '<td>' + esc(h.baseDt) + '</td>'
          + '<td>' + esc(h.prodCd) + '</td>'
          + '<td>' + esc(h.prodNm) + '</td>'
          + '<td class="r">' + nvl(h.befQty) + '</td>'
          + '<td class="r">' + nvl(h.aftQty) + '</td>'
          + '<td class="r"><span class="diff ' + (diff > 0 ? 'up' : 'dn') + '">'
          +   (diff > 0 ? '+' : '') + diff + '</span></td>'
          + '<td>' + esc(h.remark) + '</td>'
          + '<td>' + esc(h.regUser) + '</td>'
          + '<td>' + esc(h.regDttm) + '</td>'
          + '<td class="c">' + (head
              ? '<button type="button" class="undo" onclick="hisCancel(\'' + esc(h.batchNo) + '\')">되돌리기</button>'
              : '') + '</td>'
          + '</tr>';
      }).join('');
    })
    .catch(function(){ busy(false); alertBox('이력을 불러오지 못했습니다.', '⚠️'); });
}

/* 묶음 되돌리기 — 이력과 짝인 원장 조정행을 함께 내린다 */
function hisCancel(batchNo){
  var go = function(){
    fetch(CTX + '/prod/stockAdjCancel.do', {
        method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
        credentials:'same-origin', body: 'batchNo=' + encodeURIComponent(batchNo) })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || d.result !== 'OK'){
          alertBox('되돌리지 못했습니다.<br>' + esc((d && d.message) || ''), '⚠️');
          return;
        }
        toast(d.cnt + '건 되돌렸습니다.');
        hisLoad();
        if (ROWS.length) load();      /* 위 목록도 바뀐 재고로 다시 그린다 */
      })
      .catch(function(){ alertBox('되돌리지 못했습니다.', '⚠️'); });
  };

  if (window._confirmBox){
    window._confirmBox({
      icon: '⚠️',
      msg: '<div style="text-align:left; line-height:1.7">'
         + '<b>' + esc(batchNo) + '</b> 묶음을 되돌립니다.<br>'
         + '이 저장으로 만들어진 <b>조정행이 모두 내려갑니다.</b></div>',
      okText: '되돌리기',
      onOk: go
    });
  } else if (confirm('되돌릴까요?')) go();
}
</script>
</body>
</html>
