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
  .wrap{ padding:8px 11px 10px; height:100%; display:flex; flex-direction:column; min-height:0; }

  .bar{ display:flex; flex-wrap:wrap; align-items:center; gap:6px 10px; padding:8px 10px;
        background:#fff; border:1px solid var(--bd); border-radius:8px; margin-bottom:8px; }
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
  .diff{ font-weight:800; }
  .diff.up{ color:#1f7a4b; }
  .diff.dn{ color:#b23b3b; }

  .foot{ display:flex; align-items:center; gap:12px; padding:7px 10px; margin-top:8px;
         background:#fff; border:1px solid var(--bd); border-radius:8px; font-size:13px; }
  .foot b{ color:var(--teal); }
  /* ── 하단 조정 이력 ─────────────────────────────────────────── */
  .hist{ margin-top:8px; background:#fff; border:1px solid var(--bd); border-radius:8px;
         display:flex; flex-direction:column; min-height:0; }
  .hist.off .hgrid{ display:none; }
  .htab{ display:flex; align-items:center; gap:6px 10px; padding:6px 10px; border-bottom:1px solid var(--bd); }
  .htab .tb{ height:26px; border:1px solid var(--teal); background:#fff; color:var(--teal);
             border-radius:5px; padding:0 12px; font-size:13px; font-weight:700; cursor:pointer; }
  .htab .tb.on{ background:var(--teal); color:#fff; }
  .htab label{ font-size:13px; color:#48606f; font-weight:600; }
  .htab input{ height:26px; border:1px solid #cbd5e1; border-radius:4px; padding:0 7px;
               font-size:13px; font-family:inherit; }
  .hgrid{ max-height:28vh; overflow:auto; }
  .hgrid table{ font-size:12.5px; }
  .hgrid thead th{ background:#f4f7f8; }
  .undo{ height:22px; border:1px solid #b23b3b; background:#fff; color:#b23b3b;
         border-radius:4px; padding:0 8px; font-size:11.5px; font-weight:700; cursor:pointer; }
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
           oninput="liveFind();" onkeydown="if(event.keyCode===13){ clearTimeout(FIND_T); load(); }">
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
          <th class="r" style="width:90px">BOX재고</th>
          <th class="r" style="width:80px">EA재고</th>
          <th class="r" style="width:95px">합계재고</th>
          <th class="c" style="width:95px">수정BOX재고</th>
          <th class="c" style="width:95px">수정EA재고</th>
          <th class="r" style="width:90px">증감</th>
        </tr>
      </thead>
      <tbody id="body">
        <tr><td colspan="11" class="c dim" style="padding:26px">[리스트조회] 를 눌러 주세요.</td></tr>
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

<script type="text/javascript">
var CTX  = '${pageContext.request.contextPath}';
var ROWS = [];        /* 마지막으로 불러온 목록 */

function gel(id){ return document.getElementById(id); }
function esc(s){ return String(s == null ? '' : s)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function nvl(v){ return (v == null || v === '') ? 0 : Number(v); }
function alertBox(msg, icon){
  if (window._alertBox) window._alertBox(msg, { icon: icon || 'ℹ️' });
  else alert(String(msg).replace(/<[^>]+>/g,''));
}
function toast(msg){ if (window._toast) window._toast(msg); }

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
  FIND_T = setTimeout(function(){
    var v = gel('findData').value.trim();
    if (v.length === 1) return;           /* 한 글자는 기다린다 */
    load();
  }, 350);
}

/* 드롭다운·체크·날짜는 바꾸는 즉시 조회 */
(function(){
  ['sortGb','typeNm','makerNm','baseDt'].forEach(function(id){
    var el = gel(id); if (el) el.onchange = function(){ if (ROWS.length || id === 'baseDt') load(); };
  });
  var z = gel('zeroExc'); if (z) z.onchange = function(){ load(); };
})();
/* ── 목록 ────────────────────────────────────────────────────────── */
function load(){
  var p = new URLSearchParams();
  p.append('asOfDt',    gel('baseDt').value || '');
  p.append('findData',  gel('findData').value.trim());
  p.append('typeNm',    gel('typeNm').value);
  p.append('makerNm',   gel('makerNm').value);
  p.append('sortGb',    gel('sortGb').value);
  p.append('zeroExcYn', gel('zeroExc').checked ? 'Y' : 'N');

  gel('body').innerHTML = '<tr><td colspan="11" class="c dim" style="padding:26px">불러오는 중…</td></tr>';

  fetch(CTX + '/prod/stockAdjList.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body: p.toString() })
    .then(function(r){ return r.json(); })
    .then(function(d){ ROWS = (d && d.data) || []; render(); fillFilters(); })
    .catch(function(){ alertBox('목록을 불러오지 못했습니다.', '⚠️'); });
}

function render(){
  if (!ROWS.length){
    gel('body').innerHTML = '<tr><td colspan="11" class="c dim" style="padding:26px">자료가 없습니다.</td></tr>';
    gel('cnt').textContent = '0건';
    gel('chgCnt').textContent = '0';
    return;
  }
  gel('body').innerHTML = ROWS.map(function(r, i){
    var cur = nvl(r.curQty);
    return '<tr id="tr'+i+'">'
      + '<td>' + esc(r.prodCd) + '</td>'
      + '<td>' + esc(r.prodNm) + '</td>'
      + '<td>' + esc(r.spec) + '</td>'
      + '<td class="c"><input class="ed pk" id="pk'+i+'" value="' + nvl(r.packQty) + '"'
      +     ' title="입수수량(BOX당 EA) — 엔터를 치거나 칸을 벗어나면 BOX/EA 가 다시 나뉩니다"'
      +     ' onkeydown="if(event.keyCode===13){ packChg(' + i + '); this.blur(); }"'
      +     ' onchange="packChg(' + i + ')"></td>'
      + '<td>' + esc(r.typeNm) + '</td>'
      + '<td class="r" id="vb'+i+'">' + nvl(r.boxQty) + '</td>'
      + '<td class="r" id="ve'+i+'">' + nvl(r.eaQty) + '</td>'
      + '<td class="r' + (cur < 0 ? ' neg' : '') + '">' + cur + '</td>'
      + '<td class="c"><input class="ed" id="bx'+i+'" value="' + nvl(r.boxQty) + '"'
      +     ' oninput="chg(' + i + ')"></td>'
      + '<td class="c"><input class="ed" id="ea'+i+'" value="' + nvl(r.eaQty) + '"'
      +     ' oninput="chg(' + i + ')"></td>'
      + '<td class="r" id="df'+i+'"></td>'
      + '</tr>';
  }).join('');
  gel('cnt').textContent = ROWS.length + '건';
  for (var i = 0; i < ROWS.length; i++) chg(i, true);
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
    ROWS.forEach(function(r){
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

  fetch(CTX + '/prod/stockAdjHisList.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body: p.toString() })
    .then(function(r){ return r.json(); })
    .then(function(d){
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
    .catch(function(){ alertBox('이력을 불러오지 못했습니다.', '⚠️'); });
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
