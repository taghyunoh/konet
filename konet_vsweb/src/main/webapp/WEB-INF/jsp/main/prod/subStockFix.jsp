<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- 알림·확인은 프로젝트 공통 표준(ui-message.js) — Swal·alert() 금지 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<title>서브코드 재고 정리</title>
<%-- 서브코드 재고 정리 (2026-09-13 요청 「메인코드에 매칭된 서브코드 제품 모두 재고 수량을 0으로 조정」)
     서브코드 = 주코드에 매칭된 코드(매칭코드·추가 매칭코드)이면서 상품마스터에도 있는 코드.
     그 코드로 매입·재고조정이 잡히면 같은 물건의 재고가 주코드와 서브코드로 갈라진다(출고는 이미 주코드로 빠진다).
     ★표 하나 (2026-09-13 「두 개 그리드를 하나로」) — 서브코드 줄 바로 밑에 그 코드로 잡힌 매입 줄(↳)을 붙인다.
       · 매입 줄 : ★여기서 고치지 않는다. [매입등록에서 열기]로 그 전표를 매입등록에 띄워 거기서 주코드로 바꿔 저장
         (사용자 결정 「매입등록 변경은 매입등록에서 — 중복업무라서」). 돌아오면(셸이 konetShown 을 부른다) 목록을 새로 읽는다.
       · [0으로 조정] : 기본 = 같은 수량을 주코드에 더해 합침. 재고 일괄조정과 같은 조정행·이력 → 그 화면 [조정 이력]에서 묶음째 되돌리기.
       · 재고는 0 인데 매입이 서브코드로 남은 코드도 줄로 세운다 — 표가 하나라 그런 매입이 숨으면 안 된다. --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; overflow:hidden; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:6px 11px 8px; height:100%; display:flex; flex-direction:column; gap:6px; min-height:0; }
  .bar{ display:flex; flex-wrap:wrap; align-items:center; gap:4px 12px; padding:7px 10px;
        background:#fff; border:1px solid var(--bd); border-radius:8px; }
  .bar h2{ margin:0; font-size:16px; white-space:nowrap; }
  .hint{ font-size:12.5px; color:#5a6b7a; }
  .sp{ flex:1; }
  .btn{ height:30px; border:1px solid var(--teal); background:var(--teal); color:#fff; border-radius:5px;
        padding:0 14px; font-size:13px; font-weight:700; cursor:pointer; white-space:nowrap; }
  .btn.ghost{ background:#fff; color:var(--teal); }
  .btn.sm{ height:24px; padding:0 9px; font-size:12px; }
  .btn[disabled]{ background:#b9c8d2; border-color:#b9c8d2; color:#fff; cursor:not-allowed; }
  .sec{ flex:1 1 0; display:flex; flex-direction:column; min-height:0; background:#fff; border:1px solid var(--bd); border-radius:8px; }
  .st{ display:flex; flex-wrap:wrap; align-items:center; gap:4px 12px; padding:7px 10px; border-bottom:1px solid var(--bd); }
  .st label{ font-size:13px; font-weight:700; color:#0f6b5e; white-space:nowrap; cursor:pointer; }
  .grid{ flex:1 1 0; min-height:0; overflow:auto; }
  table{ width:100%; min-width:1180px; border-collapse:collapse; font-size:13px; }
  thead th{ position:sticky; top:0; z-index:2; background:#eef2f5; border-bottom:1px solid #c8d4dd;
            padding:7px 8px; font-weight:700; color:#3a4a53; white-space:nowrap; }
  tbody td{ border-bottom:1px solid #eef1f4; padding:5px 8px; white-space:nowrap; }
  td.r, th.r{ text-align:right; } td.c, th.c{ text-align:center; }
  td.nm{ white-space:normal; min-width:180px; max-width:340px; }
  .spec{ display:block; font-size:11.5px; color:#8a97a3; }
  .neg{ color:#b23b3b; font-weight:700; }
  .big{ font-weight:800; }
  .to{ color:#1f7a4d; font-weight:800; }
  .cr{ color:#b06a00; font-weight:800; text-decoration:none; margin-right:4px; cursor:pointer; }
  .tag{ display:inline-block; padding:1px 7px; border-radius:9px; font-size:11.5px; font-weight:700; white-space:nowrap; }
  .tag.w{ background:#fff4e0; color:#b06a00; cursor:pointer; }
  .tag.x{ background:#fdecea; color:#c0392b; }
  .tag.ok{ background:#e3f2ee; color:#0f6b5e; }
  /* 서브코드 줄 — 매입 줄이 딸리면 위에 선을 그어 한 덩어리로 */
  tr.sub td{ background:#fff; }
  tr.sub.grp td{ border-top:2px solid #d6e3ea; }
  tr.sub:hover td{ background:#f7fbfa; }
  tr.sub.on td{ background:#fff8e8; }
  tr.sub.blk td{ color:#9aa8b2; }
  /* 매입 줄(↳) — 한 칸에 가로로 늘어놓고 칸 폭을 고정해 줄끼리 자릿수가 맞게 */
  tr.pl td{ background:#fbfcfd; padding:3px 8px; font-size:12.5px; }
  .pline{ display:flex; align-items:center; gap:0 14px; padding-left:30px; }
  .pline > span{ white-space:nowrap; }
  .pline .ar{ color:#b06a00; font-weight:800; margin-left:-18px; }
  .pline .d{ width:86px; } .pline .no{ width:150px; } .pline .v{ width:170px; overflow:hidden; text-overflow:ellipsis; }
  .pline .q{ width:110px; text-align:right; } .pline .u{ width:110px; text-align:right; } .pline .a{ width:130px; text-align:right; }
  .pline .rm{ flex:1; min-width:60px; color:#6b7a89; overflow:hidden; text-overflow:ellipsis; }
  .pline small, .pline .lb{ color:#8a97a3; font-weight:400; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  .busy{ position:fixed; inset:0; background:rgba(255,255,255,.45); display:none; z-index:999;
         align-items:center; justify-content:center; cursor:progress; }
  .busy.on{ display:flex; }
  .busy .bx{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:13px 24px;
             font-size:14.5px; font-weight:700; color:var(--teal); box-shadow:0 8px 26px rgba(0,0,0,.18); }
</style>
<%-- 화면 콘셉 공통 + 공통 UI 보정 — 반드시 이 화면 <style> 뒤에 --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/ui-concept.css?v=20260820">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
</head>
<body>
<div class="wrap">

  <div class="bar">
    <h2>🧹 서브코드 재고 정리</h2>
    <span class="hint">주코드에 매칭된 <b>서브코드</b>에 남은 재고를 정리합니다 —
      서브코드 밑의 <b>매입 줄</b>은 [매입등록에서 열기]로 주코드로 바꾸고, 남은 재고는 체크해서 <b>0으로 조정</b>합니다.</span>
    <span class="sp"></span>
    <button class="btn ghost" onclick="load()">🔄 새로고침</button>
  </div>

  <div class="sec">
    <div class="st">
      <span class="hint" id="sum"></span>
      <button class="btn ghost sm" id="foldBtn" onclick="foldAll()" title="서브코드 밑의 매입 줄을 한꺼번에 접거나 펼칩니다">▲ 매입 줄 모두 접기</button>
      <span class="sp"></span>
      <label title="켜면 서브코드에서 뺀 수량을 같은 주코드에 더합니다(재고가 주코드로 옮겨감). 끄면 서브코드만 0 으로 만듭니다.">
        <input type="checkbox" id="merge" checked onchange="render()"> 주코드에 더해 합치기</label>
      <button class="btn" id="zeroBtn" onclick="zeroGo()" disabled>선택한 서브코드 재고 0으로 조정</button>
    </div>
    <div class="grid" id="g1"><div class="empty">불러오는 중…</div></div>
  </div>
</div>
<div class="busy" id="busy"><div class="bx">⏳ <span id="busyMsg">불러오는 중…</span></div></div>

<script>
var CTX = '${pageContext.request.contextPath}';
var SUBS = [], PUR = [], BYSUB = {};
var _fold = {}, _foldAll = false;   // _fold[서브코드] = true 면 매입 줄 접힘
var _chk = {};                      // 체크한 서브코드 — 접기/펼치기로 다시 그려도 남는다
function gel(id){ return document.getElementById(id); }
function esc(s){ return String(s == null ? '' : s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function jsq(s){ return String(s == null ? '' : s).replace(/['"\\<>]/g, ''); }
function num(v){ var n = Number(v); return isFinite(n) ? n : 0; }
function fmt(v){ return Math.round(num(v)).toLocaleString(); }
function qty(v, cls){ var n = num(v); return '<span class="' + (n < 0 ? 'neg ' : '') + (cls || '') + '">' + fmt(n) + '</span>'; }
function fmtDt(s){ s = String(s || ''); return s.length === 8 ? s.slice(0,4) + '-' + s.slice(4,6) + '-' + s.slice(6,8) : s; }
function busy(on, msg){ if (msg) gel('busyMsg').textContent = msg; gel('busy').classList.toggle('on', !!on); }

function load(){
  busy(true, '불러오는 중…');
  fetch(CTX + '/prod/subStockList.do', { method:'POST', credentials:'same-origin' })
    .then(function(r){ return r.json(); })
    .then(function(j){ SUBS = (j && j.subs) || []; PUR = (j && j.purch) || []; index(); render(); busy(false); })
    .catch(function(){ busy(false); _alertBox('목록을 불러오지 못했습니다.', { icon:'⚠️' }); });
}
/* 매입등록에서 돌아오면 셸(logiFrame)이 부른다 — 거기서 주코드로 바꾼 매입이 바로 빠져 보이게 */
window.konetShown = function(){ load(); };

/* 매입 줄을 서브코드별로 묶고, 재고는 0 인데 매입이 남은 서브코드도 줄로 세운다(표가 하나라 숨으면 안 된다) */
function index(){
  BYSUB = {};
  PUR.forEach(function(p){ (BYSUB[p.subCd] = BYSUB[p.subCd] || []).push(p); });
  var have = {}; SUBS.forEach(function(s){ have[s.subCd] = 1; });
  Object.keys(BYSUB).forEach(function(cd){
    if (have[cd]) return;
    var p = BYSUB[cd][0];
    SUBS.push({ subCd:cd, subNm:p.prodNm, subSpec:p.spec, mainCd:p.mainCd, mainNm:'', subCur:0, subPurch:0, subAdj:0, subEtc:0,
                mainCur:null, purchLines:BYSUB[cd].length, _zero:true });
  });
  var alive = {}; SUBS.forEach(function(s){ alive[s.subCd] = 1; });
  Object.keys(_chk).forEach(function(cd){ if (!alive[cd]) delete _chk[cd]; });   // 다시 읽고 사라진 코드는 체크도 뺀다
}
function isOpen(cd){ var v = _fold[cd]; return (v === undefined) ? !_foldAll : !v; }
function fold(cd){ _fold[cd] = isOpen(cd); render(); }
function foldAll(){ _foldAll = !_foldAll; _fold = {}; render(); }

/* 조정할 수 없는 줄 — 합칠 주코드가 하나로 안 정해지거나, 서브가 아닐 수 있는 코드 */
function blockWhy(s){
  if (s._zero) return '';
  if (num(s.mainCnt) > 1) return '주코드 ' + num(s.mainCnt) + '개에 매칭 — 상품코드등록에서 정리';
  if (num(s.alsoMain) > 0) return '다른 매칭코드의 주코드이기도 함 — 서브코드인지 확인';
  if (!num(s.subSeq)) return '상품마스터에 없음';
  if (!num(s.mainSeq)) return '주코드가 상품마스터에 없음';
  return '';
}
function purchRow(p){
  var lc = num(p.lineCnt);
  return '<tr class="pl"><td></td><td colspan="11"><div class="pline">'
    + '<span class="ar">↳</span>'
    + '<span class="d">' + fmtDt(p.purchDt) + '</span>'
    + '<span class="no"><span class="lb">전표</span> ' + esc(p.purchNo) + (lc > 1 ? ' <small>(' + lc + '줄 중 ' + num(p.rowNo) + '번)</small>' : '') + '</span>'
    + '<span class="v" title="' + esc(p.vendorNm) + '">' + esc(p.vendorNm) + '</span>'
    + '<span class="q"><span class="lb">수량</span> ' + qty(p.qty) + (p.trxGb && p.trxGb !== '매입' ? ' <span class="tag x">' + esc(p.trxGb) + '</span>' : '') + '</span>'
    + '<span class="u"><span class="lb">단가</span> ' + fmt(p.unitPrice) + '</span>'
    + '<span class="a"><span class="lb">금액</span> ' + fmt(p.totAmt) + '</span>'
    + '<span class="rm" title="' + esc(p.remark) + '">' + esc(p.remark) + '</span>'
    + '<button class="btn sm" onclick="openPurch(' + num(p.purchSeq) + ')" title="매입등록 화면에 이 전표를 띄웁니다 — 거기서 상품코드(파란 글씨)를 주코드로 바꿔 저장">📝 매입등록에서 열기</button>'
    + '</div></td></tr>';
}
function render(){
  var merge = gel('merge').checked, tS = 0, tP = 0, tA = 0, docs = {};
  PUR.forEach(function(p){ docs[p.purchSeq] = 1; });
  if (!SUBS.length){
    gel('g1').innerHTML = '<div class="empty">재고가 남은 서브코드가 없습니다. 👍</div>';
    gel('sum').textContent = ''; zeroBtnSync(); return;
  }
  var h = '<table><thead><tr><th class="c"><input type="checkbox" id="chkAll" onclick="chkAll(this)" title="조정할 수 있는 줄 전체"></th>'
        + '<th>서브코드</th><th>서브 상품명</th><th>→ 주코드</th><th>주코드 상품명</th>'
        + '<th class="r">서브 재고</th><th class="r" title="서브코드로 잡힌 매입 몫">매입분</th><th class="r" title="서브코드로 잡힌 재고조정 몫">조정분</th><th class="r">기타</th>'
        + '<th class="r">주코드 재고</th><th class="r" title="0 으로 조정한 뒤의 주코드 재고(합치기 켜짐이면 서브 재고를 더한 값)">조정 뒤 주코드</th><th>상태</th></tr></thead><tbody>';
  SUBS.forEach(function(s){
    var why = blockWhy(s), cur = num(s.subCur), mcur = num(s.mainCur), lines = BYSUB[s.subCd] || [], pl = lines.length, open = isOpen(s.subCd);
    var canChk = !why && !s._zero, on = canChk && !!_chk[s.subCd];
    if (!canChk) delete _chk[s.subCd];
    tS += cur; tP += num(s.subPurch); tA += num(s.subAdj);
    var caret = pl ? '<a class="cr" onclick="fold(\'' + jsq(s.subCd) + '\')" title="매입 ' + pl + '줄 접기/펼치기">' + (open ? '▼' : '▶') + '</a>' : '';
    var st = why ? '<span class="tag x">' + esc(why) + '</span>'
           : s._zero ? '<span class="tag w" onclick="fold(\'' + jsq(s.subCd) + '\')">재고 0 · 매입 ' + pl + '줄 — 매입등록에서 주코드로</span>'
           : pl > 0 ? '<span class="tag w" onclick="fold(\'' + jsq(s.subCd) + '\')" title="눌러서 밑의 매입 줄 접기/펼치기">매입 ' + pl + '줄 — 먼저 매입등록에서 주코드로</span>'
           : '<span class="tag ok" title="이 서브코드로 잡힌 매입 전표가 없습니다 — 남은 재고는 재고조정으로 들어간 몫이라 매입등록에서 고칠 것이 없고, 체크해서 바로 0으로 조정하면 됩니다.">매입 없음</span>';
    h += '<tr class="sub' + (pl ? ' grp' : '') + (why ? ' blk' : '') + (on ? ' on' : '') + '">'
      + '<td class="c">' + (canChk ? '<input type="checkbox" class="ck" data-cd="' + esc(s.subCd) + '"' + (on ? ' checked' : '') + ' onclick="rowChk(this)">' : '') + '</td>'
      + '<td class="big">' + caret + esc(s.subCd) + (pl && !open ? ' <span style="color:#b06a00;font-size:11px;font-weight:700">+' + pl + '</span>' : '') + '</td>'
      + '<td class="nm">' + esc(s.subNm) + (s.subSpec ? '<span class="spec">' + esc(s.subSpec) + '</span>' : '') + '</td>'
      + '<td class="to">' + esc(s.mainCd) + '</td>'
      + '<td class="nm">' + esc(s.mainNm) + (s.mainSpec ? '<span class="spec">' + esc(s.mainSpec) + '</span>' : '') + '</td>'
      + '<td class="r">' + qty(cur, 'big') + '</td><td class="r">' + qty(s.subPurch) + '</td><td class="r">' + qty(s.subAdj) + '</td><td class="r">' + qty(s.subEtc) + '</td>'
      + '<td class="r">' + (s.mainCur == null ? '' : qty(mcur)) + '</td>'
      + '<td class="r">' + (s.mainCur == null ? '' : qty(merge ? mcur + cur : mcur, 'big')) + '</td>'
      + '<td>' + st + '</td></tr>';
    if (open) lines.forEach(function(p){ h += purchRow(p); });
  });
  gel('g1').innerHTML = h + '</tbody></table>';
  gel('sum').innerHTML = '서브코드 <b>' + SUBS.length + '</b>개 · 재고 합 <b>' + fmt(tS) + '</b> (매입분 ' + fmt(tP) + ' · 조정분 ' + fmt(tA) + ')'
    + ' · 서브코드로 잡힌 매입 <b>' + PUR.length + '</b>줄(전표 ' + Object.keys(docs).length + '장)';
  gel('foldBtn').textContent = _foldAll ? '▼ 매입 줄 모두 펼치기' : '▲ 매입 줄 모두 접기';
  gel('foldBtn').style.display = PUR.length ? '' : 'none';
  zeroBtnSync();
}
function chkAll(el){
  Array.prototype.forEach.call(document.querySelectorAll('#g1 input.ck'), function(c){ c.checked = el.checked; rowChk(c, true); });
  zeroBtnSync();
}
function rowChk(c, quiet){
  var cd = c.getAttribute('data-cd');
  if (c.checked) _chk[cd] = 1; else delete _chk[cd];
  var tr = c.closest('tr'); if (tr) tr.classList.toggle('on', c.checked);
  if (!quiet) zeroBtnSync();
}
function picked(){ return SUBS.filter(function(s){ return !!_chk[s.subCd]; }); }
function zeroBtnSync(){
  var n = picked().length, b = gel('zeroBtn');
  b.disabled = !n;
  b.textContent = n ? ('선택한 서브코드 ' + n + '개 재고 0으로 조정') : '선택한 서브코드 재고 0으로 조정';
  var all = gel('chkAll'), cks = document.querySelectorAll('#g1 input.ck');
  if (all) all.checked = cks.length > 0 && n === cks.length;
}

/* 0 으로 조정 — 서버가 원장으로 수량을 다시 세서 조정행을 만든다(화면 숫자는 안내용) */
function zeroGo(){
  var sel = picked(); if (!sel.length) return;
  var merge = gel('merge').checked, tot = 0, withPur = [], mains = {}, adjOnly = [], adjOnlyQty = 0;
  sel.forEach(function(s){ tot += num(s.subCur); mains[s.mainCd] = 1; var pl = (BYSUB[s.subCd] || []).length; if (pl > 0) withPur.push(s.subCd + '(' + pl + '줄)');
    /* ★매입 없이 조정으로만 생긴 재고 (2026-09-17 지적 「매입없음 내용을 주코드에 더해 합쳤는데 상관없나요」) —
         그 수량이 실제 센 물건이면 합치는 게 맞고, 코드를 잘못 골라 넣은 착오면 합치면 주코드가 부풀어 오른다. 사람이 정해야 한다. */
    if (num(s.subCur) > 0 && num(s.subPurch) <= 0) { adjOnly.push(s.subCd + '(' + fmt(num(s.subCur)) + ')'); adjOnlyQty += num(s.subCur); } });
  var msg = '서브코드 <b>' + sel.length + '</b>개의 재고(합 <b>' + fmt(tot) + '</b>)를 <b>0</b>으로 조정합니다.'
    + (merge ? '<br>같은 수량을 주코드 <b>' + Object.keys(mains).length + '</b>개에 <b>더해 합칩니다</b>.' : '<br><b style="color:#b23b3b">주코드에는 더하지 않습니다</b>(서브코드만 0).')
    + (adjOnly.length ? '<br><br><span style="color:#b23b3b"><b>⚠ 매입 없이 조정으로만 생긴 재고 ' + adjOnly.length + '개(합 ' + fmt(adjOnlyQty) + ')</b> — ' + esc(adjOnly.join(', ')) + '</span>'
        + '<br><span style="font-size:12.5px;color:#3d4d5c">이 수량이 창고에서 <b>실제로 센 물건</b>이면 ' + (merge ? '이대로 합치는 것이 맞고' : '[주코드에 더해 합치기]를 켜야 장부에서 사라지지 않고')
        + ', 코드를 잘못 골라 넣은 <b>착오</b>라면 ' + (merge ? '[주코드에 더해 합치기]를 끄고 진행하세요(주코드가 부풀어 오릅니다).' : '이대로 0으로만 조정하면 됩니다.') + '</span>' : '')
    + (withPur.length ? '<br><br><span style="color:#b06a00">⚠ 아직 매입이 서브코드로 잡혀 있는 코드가 있습니다 — ' + esc(withPur.join(', ')) + '<br>'
        + '매입등록에서 먼저 주코드로 바꾸면 매입 이력(단가·거래처)도 주코드로 갑니다. 그래도 조정으로 맞출까요?</span>' : '')
    + '<br><br><span style="font-size:12.5px;color:#5a6b7a">조정 이력은 재고 일괄조정 ▸ [조정 이력]에서 보고 묶음째 되돌릴 수 있습니다.</span>';
  _confirmBox({ msg: msg, icon: adjOnly.length ? '⚠️' : '🧹', okText: merge ? (adjOnly.length ? '합쳐서 조정' : '조정') : '0으로만 조정', onOk: function(){
    busy(true, '조정하는 중…');
    fetch(CTX + '/prod/subStockZero.do', { method:'POST', credentials:'same-origin', headers:{ 'Content-Type':'application/json' },
        body: JSON.stringify({ subCds: sel.map(function(s){ return s.subCd; }), merge: merge }) })
      .then(function(r){ return r.json(); })
      .then(function(j){
        busy(false);
        if (!j || j.result !== 'OK'){ _alertBox(esc((j && j.message) || '조정하지 못했습니다.'), { icon:'⚠️' }); return; }
        _chk = {};
        _alertBox('서브코드 <b>' + num(j.subs) + '</b>개를 0으로 조정했습니다' + (merge ? ' — 주코드 <b>' + num(j.mains) + '</b>개에 합침' : '') + '.'
          + '<br><span style="font-size:12.5px;color:#5a6b7a">묶음번호 ' + esc(j.batchNo || '') + '</span>', { icon:'✅' });
        load();
      })
      .catch(function(e){ busy(false); _alertBox('통신오류: ' + esc(e.message), { icon:'⚠️' }); });
  }});
}

/* [매입등록에서 열기] — 셸의 매입등록 화면을 열고, 그 화면이 준비되면 전표를 얹는다.
   매입등록 자체의 함수(post·puApply)를 그대로 부른다 — 전표를 여기서 다시 그리지 않는다(같은 일을 두 곳에서 안 하게). */
function openPurch(seq){
  var P = window.parent;
  if (!P || P === window || typeof P.logiFrame !== 'function'){ _alertBox('물류관리 화면 안에서 열어 주세요.', { icon:'⚠️' }); return; }
  var a = P.document.querySelector('a.mi[data-key="purchase"]');
  P.logiFrame('purchase', CTX + '/mangr/purchaseReg.do', a);
  var t0 = Date.now();
  (function wait(){
    var f = P.document.getElementById('if-purchase'), w = f && f.contentWindow, ok = false;
    try {
      ok = w && typeof w.puApply === 'function' && typeof w.post === 'function' && w.document.readyState === 'complete'
           && w._prods && w._prods.length && w._vendors && w._vendors.length;
    } catch(e) { ok = false; }
    if (!ok && Date.now() - t0 < 12000){ setTimeout(wait, 200); return; }
    if (!(w && typeof w.puApply === 'function')){ _alertBox('매입등록 화면을 열지 못했습니다. 메뉴에서 매입등록을 연 뒤 다시 눌러 주세요.', { icon:'⚠️' }); return; }
    w.post('/mangr/purchaseDetail.do', 'purchSeq=' + seq)
      .then(function(r){ return r.json(); })
      .then(function(j){
        var d = j && j.data;
        if (!d){ _alertBox('전표를 찾지 못했습니다(지워졌을 수 있습니다).', { icon:'⚠️' }); return; }
        w.puApply(d);
      })
      .catch(function(){ _alertBox('전표를 불러오지 못했습니다.', { icon:'⚠️' }); });
  })();
}

load();
</script>
</body>
</html>
