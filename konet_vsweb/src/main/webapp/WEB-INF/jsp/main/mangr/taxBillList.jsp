<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20260910b"></script>
<script type="text/javascript">konetGridGrip('tlListWrap', 'tlListWrap', 'taxList'); konetGridGrip('tlViewWrap', 'tlViewWrap', 'taxListView');</script>
<%--
  매출·매입 계산서 확정 · 전자세금계산서 발행 · 발행 내역 (2026-11-27 사용자 「홀세일처럼 매출계산서, 매입계산서」 → 「화면부터 먼저」)
    주소 = /tax/billList.do?mode=cfm|issue|hist&gb=S|P|A — 한 화면을 메뉴마다 다른 첫 값으로 연다(셸 메뉴마다 제 패널).
      cfm   = 확정   : 작성·확정 상태 · [확정] [확정 취소] [삭제] [인쇄]
      issue = 발행   : 확정 상태 · [전자 발행](중계업체 계약 뒤) [확정 취소] [인쇄]
      hist  = 내역   : 전부(삭제 포함 고를 수 있음) · [인쇄] [엑셀]      gb=A 면 매출·매입 함께
    · 상태 : 작성(W) → 확정(C) → 발행(I, 국세청 전송 — 다음 단계). 삭제는 작성 상태만(표에는 남고 ACTION_YN N).
    · 확정은 사업자번호가 10자리인 것만 — 서버가 다시 본다(전자 발행이 안 되는 계산서를 발행 대상에 올리지 않게).
    · 줄을 누르면 아래에 세금계산서 양식으로 보이고, 작성 상태면 작성일자·청구/영수·이메일·비고를 고칠 수 있다.
    · 인쇄 = 고른 계산서를 세금계산서 양식으로(공급자 보관용 빨강 / 공급받는자 보관용 파랑). iframe 안이라 반드시 화면의 [🖨 인쇄] 단추로.
    ⚠이 파일에 mybatis 식 해시-중괄호 글자와 자바스크립트 템플릿 문자열의 달러-중괄호를 쓰지 말 것(JSP EL).
--%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --red:#c0392b; --blue:#1f6fb2; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; background:#f4f6f9; }
  .tl-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .tl-head{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:8px; }
  .tl-head h2{ margin:0 6px 0 0; font-size:21px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:11px 13px; margin-bottom:11px; }
  .row{ display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
  .row label.l{ font-weight:700; color:#37475a; }
  input.t, select.t{ height:30px; border:1px solid #c7d0d9; border-radius:5px; padding:0 7px; font-size:13px; background:#fff; }
  input[type=date].t{ width:140px; }
  .btn{ height:30px; border:1px solid #c7d0d9; background:#fff; border-radius:6px; padding:0 11px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn.teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn.blue{ background:#2a6db0; color:#fff; border-color:#2a6db0; }
  .btn.red{ background:#fff; color:var(--red); border-color:#e5a29a; }
  .btn.green{ background:#5cb85c; color:#fff; border-color:#4a9d5b; }
  .btn:disabled{ opacity:.45; cursor:not-allowed; }
  .chk{ display:inline-flex; align-items:center; gap:5px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
  .banner{ display:none; margin:0 0 10px; padding:9px 12px; border-radius:8px; font-size:13px; font-weight:700; }
  .banner.warn{ background:#fff4e5; border:1px solid #f0c27a; color:#8a5300; }
  .banner.info{ background:#eef6fd; border:1px solid #b6d4ee; color:#1f4f7a; }
  .kpi{ display:flex; gap:10px; flex-wrap:wrap; margin-top:10px; }
  .kpi div{ flex:1 1 140px; border:1px solid var(--bd); border-radius:8px; padding:7px 12px; background:#fbfdfc; }
  .kpi b{ display:block; font-size:17px; color:var(--teal); margin-top:2px; white-space:nowrap; }
  .kpi span{ font-size:12px; font-weight:700; }
  .tbwrap{ overflow:auto; border:1px solid var(--bd); border-radius:8px; background:#fff; }
  #tlListWrap{ max-height:max(240px, 40vh); }
  #tlViewWrap{ max-height:max(300px, 46vh); min-height:120px; padding:10px; }
  table.g{ width:100%; border-collapse:collapse; font-size:12.5px; white-space:nowrap; }
  table.g th{ background:#d9edf7; color:#1f2a37; font-weight:700; border:1px solid #9fb6c3; padding:6px 6px; position:sticky; top:0; z-index:2; }
  table.g td{ border:1px solid #c9d3dc; padding:4px 6px; text-align:right; }
  table.g td.txt{ text-align:left; }
  table.g td.ctr{ text-align:center; }
  table.g tr.tot td{ background:#fcf8e3; font-weight:800; position:sticky; top:29px; z-index:1; }
  table.g tbody tr.pk{ cursor:pointer; }
  table.g tbody tr.pk:hover td{ background:#f3f8f6; }
  table.g tbody tr.pk.on td{ background:#dff0eb; font-weight:700; }
  table.g tbody tr.pk.on td:first-child{ box-shadow:inset 3px 0 0 var(--teal); }
  table.g tbody tr.del td{ color:#9aa6b2; text-decoration:line-through; }
  .st{ display:inline-block; font-size:11px; padding:1px 7px; border-radius:9px; font-weight:800; }
  .st.W{ background:#eef1f4; color:#37475a; }
  .st.C{ background:#e5f4ee; color:#0e6657; }
  .st.I{ background:#e8f1fb; color:var(--blue); }
  .st.X{ background:#fdecea; color:var(--red); }
  .tag{ display:inline-block; font-size:11px; padding:1px 6px; border-radius:9px; font-weight:700; }
  .tag.bad{ background:#fdecea; color:var(--red); }
  .tag.free{ background:#f3ecfb; color:#6b3fa0; }
  .msg{ padding:24px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  .foot{ display:flex; align-items:center; gap:7px; flex-wrap:wrap; margin-top:10px; }
  .foot .sum{ font-weight:700; color:#37475a; }
  .foot .sum b{ color:var(--teal); }
  .foot .right{ margin-left:auto; display:flex; gap:7px; align-items:center; flex-wrap:wrap; }
  .tit{ display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:7px; font-weight:800; flex-wrap:wrap; }
  .edit{ display:none; margin-bottom:10px; padding:8px 10px; border:1px dashed #b6c6d3; border-radius:8px; background:#fafcfe; }

  /* ── 세금계산서 양식 ── */
  .tf{ width:760px; max-width:100%; margin:0 auto 14px; font-size:11.5px; color:var(--c); --c:#c0392b; background:#fff; }
  .tf.R{ --c:#1f5fa8; }
  .tf table{ width:100%; border-collapse:collapse; table-layout:fixed; }
  .tf td, .tf th{ border:1px solid var(--c); padding:3px 4px; font-weight:400; }
  .tf th{ font-weight:700; text-align:center; }
  .tf .v{ text-align:left; color:#111; word-break:break-all; }
  .tf .n{ text-align:right; color:#111; }
  .tf .c{ text-align:center; color:#111; }
  .tf .ttl{ font-size:20px; font-weight:800; letter-spacing:8px; text-align:center; padding:6px 0; }
  .tf .ttl small{ font-size:12px; letter-spacing:0; font-weight:700; }
  .tf .vert{ width:22px; line-height:1.25; }
  .tf .outer{ border:2px solid var(--c); }
  .tf .gap{ height:4px; }
  .tf .foot2 td{ height:26px; }

  .print-area{ display:none; }
  @media print{
    @page{ size:A4 portrait; margin:0; }
    body{ background:#fff; }
    .tl-wrap{ display:none !important; }
    .print-area{ display:block; padding:10mm 9mm; }
    .print-area .tf{ width:100%; margin:0 0 7mm; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    .print-area .pg{ page-break-after:always; }
    .print-area .pg:last-child{ page-break-after:auto; }
  }
</style>

<div class="tl-wrap">
  <div class="tl-head"><h2 id="tlTitle">계산서</h2><span id="tlHeadBtns"></span></div>
  <div class="banner warn" id="tlNoTable">⚠ 계산서 표가 아직 없습니다 — <b>docs/sql/20261127_taxbill.sql</b> 을 운영 DB 에서 먼저 실행해 주세요.</div>
  <div class="banner info" id="tlIssueInfo">ℹ <b>전자세금계산서(국세청 전송)는 중계업체 연동 계약 뒤에 열립니다.</b> 지금은 확정된 계산서를 확인·인쇄할 수 있습니다. 계약 정보가 정해지면 [전자 발행] 단추가 국세청으로 보냅니다.</div>

  <div class="card">
    <div class="row">
      <label class="l">작성일자</label><input type="date" class="t" id="tlFr"> ~ <input type="date" class="t" id="tlTo">
      <button class="btn" onclick="tlMonth(0)">이번 달</button><button class="btn" onclick="tlMonth(-1)">지난 달</button>
      <select class="t" id="tlGb" style="display:none" onchange="tlLoad()"><option value="">매출+매입</option><option value="S">매출</option><option value="P">매입</option></select>
      <label class="l" style="margin-left:6px">상태</label>
      <label class="chk"><input type="checkbox" class="stc" value="W"> 작성</label>
      <label class="chk"><input type="checkbox" class="stc" value="C"> 확정</label>
      <label class="chk"><input type="checkbox" class="stc" value="I"> 발행</label>
      <label class="chk" id="tlDelLbl"><input type="checkbox" id="tlDel"> 삭제 포함</label>
      <input class="t" id="tlKw" placeholder="거래처명·코드·사업자번호" style="width:190px" onkeydown="if(event.key==='Enter')tlLoad()">
      <button class="btn blue" onclick="tlLoad()">조회하기</button>
    </div>
    <div class="kpi">
      <div><span>계산서</span><b id="kCnt">—</b></div>
      <div><span>공급가액</span><b id="kSup">—</b></div>
      <div><span>세액</span><b id="kVat">—</b></div>
      <div><span>합계</span><b id="kTot">—</b></div>
      <div><span>작성 / 확정 / 발행</span><b id="kSt">—</b></div>
    </div>
  </div>

  <div class="card">
    <div class="tbwrap" id="tlListWrap"><table class="g" id="tlList"><thead></thead><tbody><tr><td class="msg">불러오는 중…</td></tr></tbody></table></div>
    <div class="foot">
      <button class="btn" onclick="tlSelAll(true)">전체선택</button>
      <button class="btn" onclick="tlSelAll(false)">전체취소</button>
      <span class="sum">선택 개수 : <b id="tlSelCnt">0</b> &nbsp; 금액 : <b id="tlSelAmt">0</b></span>
      <div class="right" id="tlBtns"></div>
    </div>
  </div>

  <div class="card">
    <div class="tit"><span>📄 <span id="tlViewSub">줄을 누르면 세금계산서 양식으로 여기 보입니다</span></span></div>
    <div class="edit" id="tlEdit">
      <div class="row">
        <b style="color:#37475a">작성 상태 고치기</b>
        <label class="l">작성일자</label><input type="date" class="t" id="eWd">
        <select class="t" id="ePur"><option value="청구">청구</option><option value="영수">영수</option></select>
        <label class="l">받는 이메일</label><input class="t" id="eEmail" style="width:210px">
        <label class="l">비고</label><input class="t" id="eRmk" style="width:220px" maxlength="300">
        <button class="btn teal" onclick="tlSaveHead()">저장</button>
      </div>
    </div>
    <div class="tbwrap" id="tlViewWrap"><div class="msg">위 표에서 줄을 누르세요.</div></div>
  </div>
</div>
<div class="print-area" id="tlPrint"></div>

<script type="text/javascript">
var CTX = '${pageContext.request.contextPath}';
var Q = (function(){ var o = {}; location.search.replace(/^\?/, '').split('&').forEach(function(kv){ var p = kv.split('='); if (p[0]) o[p[0]] = decodeURIComponent(p[1] || ''); }); return o; })();
var MODE = /^(cfm|issue|hist)$/.test(Q.mode) ? Q.mode : 'cfm';
var GB = /^(S|P|A)$/.test(Q.gb) ? Q.gb : 'S';
var _rows = [], _pick = 0, _cur = null, _req = 0, _vreq = 0;
var ST_NM = { W:'작성', C:'확정', I:'발행' };
var MK_NM = { SUM:'합계', DOC:'건별', ITEM:'상품별' };

function esc(s){ return String(s == null ? '' : s).replace(/[&<>"']/g, function(c){ return { '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' }[c]; }); }
function num(v){ var x = Number(v); return isFinite(x) ? x : 0; }
function fmt(v){ return Math.round(num(v)).toLocaleString('ko-KR'); }
function fmtQ(v){ if (v == null || v === '') return ''; var x = num(v); return x === 0 ? '' : (Math.round(x * 100) / 100).toLocaleString('ko-KR'); }
function d8(s){ return String(s || '').replace(/-/g, ''); }
function dIso(s){ s = d8(s); return s.length === 8 ? s.substr(0,4) + '-' + s.substr(4,2) + '-' + s.substr(6,2) : ''; }
function ymd(d){ return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
function bizOk(b){ return /^\d{10}$/.test(String(b || '').replace(/[-\s]/g, '')); }
function bizFmt(b){ b = String(b || '').replace(/[-\s]/g, ''); return /^\d{10}$/.test(b) ? b.substr(0,3) + '-' + b.substr(3,2) + '-' + b.substr(5) : b; }
function pj(url, body){
  return fetch(CTX + url, { method:'POST', credentials:'same-origin', headers:{ 'Content-Type':'application/json;charset=UTF-8' }, body:JSON.stringify(body || {}) })
    .then(function(r){ if (r.status === 401) throw new Error('로그인이 끊겼습니다 — 다시 로그인한 뒤 해 주세요.'); return r.json(); });
}
var IC = { info:'ℹ️', warning:'⚠️', error:'❌', success:'✅', question:'🧾' };
function alertBox(m, ic){ if (window._alertBox) _alertBox(m, { icon: IC[ic || 'info'] || ic }); }
function gbNm(g){ return g === 'P' ? '매입' : '매출'; }

function tlInit(){
  var nm = GB === 'P' ? '매입' : '매출';
  var title = MODE === 'cfm' ? nm + ' 계산서 확정' : (MODE === 'issue' ? '전자세금계산서 발행' : (GB === 'A' ? '매출&매입 계산서 발행 조회' : '전자세금계산서 발행 내역'));
  document.getElementById('tlTitle').textContent = title; document.title = title;
  if (GB === 'A') document.getElementById('tlGb').style.display = '';
  var def = MODE === 'cfm' ? { W:1, C:1 } : (MODE === 'issue' ? { C:1 } : { W:1, C:1, I:1 });
  [].forEach.call(document.querySelectorAll('.stc'), function(c){ c.checked = !!def[c.value]; c.addEventListener('change', tlLoad); });
  document.getElementById('tlDelLbl').style.display = MODE === 'hist' ? '' : 'none';
  document.getElementById('tlDel').addEventListener('change', tlLoad);
  document.getElementById('tlIssueInfo').style.display = MODE === 'issue' ? 'block' : 'none';
  var mk = GB === 'P' ? 'taxMakeP' : 'taxMakeS';
  if (MODE !== 'hist') document.getElementById('tlHeadBtns').innerHTML = '<button class="btn green" onclick="tlGo(\'' + mk + '\',\'/tax/billMake.do?gb=' + (GB === 'P' ? 'P' : 'S') + '\')">← ' + nm + ' 계산서 생성</button>';
  var b = '';
  if (MODE === 'cfm') b = '<button class="btn teal" onclick="tlAct(\'cfm\')">✔ 확정</button><button class="btn" onclick="tlAct(\'uncfm\')">확정 취소</button><button class="btn red" onclick="tlAct(\'del\')">🗑 삭제</button>';
  if (MODE === 'issue') b = '<button class="btn blue" onclick="tlIssue()">📨 전자 발행</button><button class="btn" onclick="tlAct(\'uncfm\')">확정 취소</button>';
  b += '<select class="t" id="tlCopy" title="인쇄할 양식"><option value="SR">공급자+공급받는자 보관용</option><option value="S">공급자 보관용</option><option value="R">공급받는자 보관용</option></select>'
     + '<button class="btn" onclick="tlPrint()">🖨 인쇄</button>';
  if (MODE === 'hist') b += '<button class="btn" onclick="tlExcel()">📥 엑셀</button>';
  document.getElementById('tlBtns').innerHTML = b;
  var t = new Date();
  document.getElementById('tlFr').value = ymd(new Date(t.getFullYear(), t.getMonth() - (MODE === 'hist' ? 0 : 2), 1));
  document.getElementById('tlTo').value = ymd(new Date(t.getFullYear(), t.getMonth() + 1, 0));
}
function tlMonth(off){
  var t = new Date();
  document.getElementById('tlFr').value = ymd(new Date(t.getFullYear(), t.getMonth() + off, 1));
  document.getElementById('tlTo').value = ymd(new Date(t.getFullYear(), t.getMonth() + off + 1, 0));
  tlLoad();
}
function tlGo(key, path){
  if (window.parent && parent !== window){ var a = parent.document.querySelector('a.mi[data-key="' + key + '"]'); if (a){ a.click(); return; } }
  location.href = CTX + path;
}

/* ── 목록 ── */
function tlLoad(){
  var st = [].filter.call(document.querySelectorAll('.stc'), function(c){ return c.checked; }).map(function(c){ return c.value; });
  var gb = GB === 'A' ? document.getElementById('tlGb').value : GB;
  var my = ++_req;
  document.querySelector('#tlList tbody').innerHTML = '<tr><td class="msg">불러오는 중…</td></tr>';
  pj('/tax/list.do', { gb:gb, frDt:d8(document.getElementById('tlFr').value), toDt:d8(document.getElementById('tlTo').value), status:st,
                       inclDel: MODE === 'hist' && document.getElementById('tlDel').checked ? 'Y' : 'N', kw:document.getElementById('tlKw').value.trim() })
    .then(function(j){
      if (my !== _req) return;
      if (!j || !j.ok){ document.querySelector('#tlList tbody').innerHTML = '<tr><td class="msg">' + esc((j && j.msg) || '조회 실패') + '</td></tr>'; return; }
      document.getElementById('tlNoTable').style.display = j.noTable ? 'block' : 'none';
      _rows = (j.rows || []).map(function(r){ r.sel = false; return r; });
      if (_pick && !_rows.some(function(r){ return r.billSeq === _pick; })) _pick = 0;
      tlRender(); tlView();
    }).catch(function(e){ if (my === _req) document.querySelector('#tlList tbody').innerHTML = '<tr><td class="msg">' + esc(e.message) + '</td></tr>'; });
}
function tlRender(){
  var thead = document.querySelector('#tlList thead'), tb = document.querySelector('#tlList tbody');
  thead.innerHTML = '<tr><th style="width:44px">선택</th><th>작성일자</th>' + (GB === 'A' ? '<th>구분</th>' : '') + '<th>상태</th><th>생성</th><th>거래처코드</th><th>거래처명(상호)</th><th>사업자번호</th><th>대표자</th><th>품목</th>'
    + '<th>공급가액</th><th>세액</th><th>합계금액</th><th>청구/영수</th><th>기간</th><th>만든 사람·때</th>' + (MODE !== 'cfm' ? '<th>확정</th>' : '') + '</tr>';
  var n = 0, s = 0, v = 0, cnt = { W:0, C:0, I:0 };
  _rows.forEach(function(r){ if (r.actionYn === 'N') return; n++; s += num(r.supplyAmt); v += num(r.vatAmt); cnt[r.status] = (cnt[r.status] || 0) + 1; });
  document.getElementById('kCnt').textContent = n + '장';
  document.getElementById('kSup').textContent = fmt(s);
  document.getElementById('kVat').textContent = fmt(v);
  document.getElementById('kTot').textContent = fmt(s + v);
  document.getElementById('kSt').textContent = cnt.W + ' / ' + cnt.C + ' / ' + cnt.I;
  var nc = 15 + (GB === 'A' ? 1 : 0) + (MODE !== 'cfm' ? 1 : 0);
  if (!_rows.length){ tb.innerHTML = '<tr><td class="msg" colspan="' + nc + '">등록된 DATA가 없습니다.</td></tr>'; tlSelPaint(); return; }
  var h = '<tr class="tot"><td class="ctr" colspan="' + (GB === 'A' ? 9 : 8) + '">합계 ' + n + '장</td><td></td><td>' + fmt(s) + '</td><td>' + fmt(v) + '</td><td>' + fmt(s + v) + '</td><td colspan="' + (MODE !== 'cfm' ? 4 : 3) + '"></td></tr>';
  _rows.forEach(function(r, i){
    var del = r.actionYn === 'N';
    h += '<tr class="pk' + (r.billSeq === _pick ? ' on' : '') + (del ? ' del' : '') + '" data-i="' + i + '">'
       + '<td class="ctr"><input type="checkbox" class="sel" data-i="' + i + '"' + (r.sel ? ' checked' : '') + (del ? ' disabled' : '') + '></td>'
       + '<td class="ctr">' + dIso(r.writeDt) + '</td>'
       + (GB === 'A' ? '<td class="ctr">' + gbNm(r.billGb) + '</td>' : '')
       + '<td class="ctr">' + (del ? '<span class="st X">삭제</span>' : '<span class="st ' + r.status + '">' + (ST_NM[r.status] || r.status) + '</span>') + '</td>'
       + '<td class="ctr">' + esc(MK_NM[r.makeGb] || r.makeGb) + (r.basisGb === 'CASH' ? '·' + (r.billGb === 'P' ? '지급' : '수금') : '') + '</td>'
       + '<td class="txt">' + esc(r.custCd) + '</td>'
       + '<td class="txt">' + esc(r.fullNm || r.custNm) + (r.taxGb === '면세' ? ' <span class="tag free">면세</span>' : '') + '</td>'
       + '<td class="ctr">' + esc(bizFmt(r.bizno)) + (bizOk(r.bizno) ? '' : ' <span class="tag bad" title="사업자번호가 10자리가 아닙니다 — 확정이 안 됩니다">확인</span>') + '</td>'
       + '<td class="txt">' + esc(r.ceoNm) + '</td>'
       + '<td class="txt">' + esc(r.firstNm + (num(r.lineCnt) > 1 ? ' 외 ' + (num(r.lineCnt) - 1) + '줄' : '')) + '</td>'
       + '<td>' + fmt(r.supplyAmt) + '</td><td>' + fmt(r.vatAmt) + '</td><td>' + fmt(r.totAmt) + '</td>'
       + '<td class="ctr">' + esc(r.purposeGb) + '</td>'
       + '<td class="ctr">' + (r.frDt ? dIso(r.frDt).substr(5) + '~' + dIso(r.toDt).substr(5) : '') + '</td>'
       + '<td class="txt">' + esc(r.regUser) + ' ' + esc(String(r.regDttm || '').substr(5)) + '</td>'
       + (MODE !== 'cfm' ? '<td class="txt">' + esc(r.cfmUser) + ' ' + esc(String(r.cfmDttm || '').substr(5)) + '</td>' : '')
       + '</tr>';
  });
  tb.innerHTML = h;
  tlSelPaint();
}
document.addEventListener('click', function(e){
  var cb = e.target.closest && e.target.closest('#tlList input.sel');
  if (cb){ var r = _rows[+cb.getAttribute('data-i')]; if (r) r.sel = cb.checked; tlSelPaint(); return; }
  var tr = e.target.closest && e.target.closest('#tlList tbody tr.pk');
  if (tr){ var r2 = _rows[+tr.getAttribute('data-i')]; if (!r2) return; _pick = r2.billSeq;
    [].forEach.call(document.querySelectorAll('#tlList tbody tr.pk'), function(x){ x.classList.toggle('on', x === tr); });
    tlView(); }
});
function tlSelAll(on){ _rows.forEach(function(r){ if (r.actionYn !== 'N') r.sel = on; }); [].forEach.call(document.querySelectorAll('#tlList input.sel'), function(c){ if (!c.disabled) c.checked = on; }); tlSelPaint(); }
function tlSelPaint(){
  var n = 0, t = 0; _rows.forEach(function(r){ if (r.sel){ n++; t += num(r.totAmt); } });
  document.getElementById('tlSelCnt').textContent = n; document.getElementById('tlSelAmt').textContent = fmt(t);
}
function tlSel(){ return _rows.filter(function(r){ return r.sel && r.actionYn !== 'N'; }); }

/* ── 확정 · 확정 취소 · 삭제 ── */
function tlAct(act){
  var sel = tlSel();
  if (!sel.length){ alertBox('계산서를 고르세요(왼쪽 체크).'); return; }
  var need = act === 'cfm' ? 'W' : (act === 'uncfm' ? 'C' : 'W');
  var ok = sel.filter(function(r){ return r.status === need; });
  var nm = act === 'cfm' ? '확정' : (act === 'uncfm' ? '확정 취소' : '삭제');
  if (!ok.length){ alertBox(nm + '할 수 있는 계산서가 없습니다 — ' + (need === 'W' ? '작성' : '확정') + ' 상태만 ' + nm + '됩니다.'); return; }
  var t = 0; ok.forEach(function(r){ t += num(r.totAmt); });
  var msg = '<b>' + ok.length + '장</b>을 ' + nm + '합니다 (합계 ' + fmt(t) + '원)';
  if (ok.length < sel.length) msg += '<br><span style="color:#8a5300">상태가 맞지 않는 ' + (sel.length - ok.length) + '장은 건너뜁니다.</span>';
  if (act === 'cfm'){ var bad = ok.filter(function(r){ return !bizOk(r.bizno); }).length; if (bad) msg += '<br><span style="color:#c0392b">사업자번호가 맞지 않는 ' + bad + '장은 확정되지 않습니다.</span>'; }
  if (act === 'del') msg += '<br>지운 계산서는 「발행 내역」에서 「삭제 포함」으로 볼 수 있습니다.';
  _confirmBox({ msg:msg, icon: act === 'del' ? IC.warning : IC.question, okText:nm, okColor: act === 'del' ? 'red' : 'blue', onOk:function(){
    pj('/tax/status.do', { act:act, seqs: ok.map(function(r){ return r.billSeq; }) }).then(function(j){
      if (!j || !j.ok){ alertBox((j && j.msg) || '처리 실패', 'error'); return; }
      var m = nm + ' ' + j.cnt + '장';
      if (j.bad && j.bad.length) m += '<br><span style="color:#c0392b">사업자번호 문제로 확정 안 됨 ' + j.bad.length + '장 : ' + j.bad.slice(0, 5).map(function(b){ return esc(b.custNm) + '(' + esc(b.bizno || '없음') + ')'; }).join(', ') + (j.bad.length > 5 ? ' …' : '') + '</span><br>거래처 마스터에서 사업자번호를 고친 뒤 계산서를 지우고 다시 만드세요.';
      if (j.bad && j.bad.length) alertBox(m, 'warning'); else if (window._toast) _toast(m + ' 완료', 'ok');
      tlLoad();
    }).catch(function(e){ alertBox(e.message, 'error'); });
  } });
}
function tlIssue(){
  alertBox('<b>전자세금계산서 발행(국세청 전송)은 아직 연결 전입니다.</b><br>중계업체(바로빌·팝빌 등) 연동 계약 정보가 정해지면 이 단추가 고른 계산서를 국세청으로 보냅니다.<br>지금은 확정된 계산서를 확인·인쇄할 수 있습니다.', 'info');
}

/* ── 아래 : 한 장 보기 + 작성 상태 고치기 ── */
function tlView(){
  var box = document.getElementById('tlViewWrap'), ed = document.getElementById('tlEdit');
  if (!_pick){ box.innerHTML = '<div class="msg">위 표에서 줄을 누르세요.</div>'; ed.style.display = 'none'; document.getElementById('tlViewSub').textContent = '줄을 누르면 세금계산서 양식으로 여기 보입니다'; _cur = null; return; }
  var my = ++_vreq;
  box.innerHTML = '<div class="msg">불러오는 중…</div>';
  pj('/tax/get.do', { billSeq:_pick }).then(function(j){
    if (my !== _vreq) return;
    if (!j || !j.ok){ box.innerHTML = '<div class="msg">' + esc((j && j.msg) || '조회 실패') + '</div>'; return; }
    _cur = j;
    var h = j.head;
    document.getElementById('tlViewSub').textContent = gbNm(h.billGb) + ' 계산서 #' + h.billSeq + ' — ' + (h.fullNm || h.custNm) + ' · ' + (h.actionYn === 'N' ? '삭제됨' : (ST_NM[h.status] || h.status)) + (h.ntsNo ? ' · 승인번호 ' + h.ntsNo : '');
    var w = h.status === 'W' && h.actionYn === 'Y';
    ed.style.display = w ? 'block' : 'none';
    if (w){ document.getElementById('eWd').value = dIso(h.writeDt); document.getElementById('ePur').value = h.purposeGb || '청구'; document.getElementById('eEmail').value = h.email || ''; document.getElementById('eRmk').value = h.remark || ''; }
    box.innerHTML = tfHtml(j, h.billGb === 'P' ? 'R' : 'S');
  }).catch(function(e){ if (my === _vreq) box.innerHTML = '<div class="msg">' + esc(e.message) + '</div>'; });
}
function tlSaveHead(){
  if (!_cur) return;
  pj('/tax/saveHead.do', { billSeq:_cur.head.billSeq, writeDt:d8(document.getElementById('eWd').value), purposeGb:document.getElementById('ePur').value,
                           email:document.getElementById('eEmail').value.trim(), remark:document.getElementById('eRmk').value.trim() })
    .then(function(j){ if (!j || !j.ok){ alertBox((j && j.msg) || '저장 실패', 'error'); return; } if (window._toast) _toast('저장했습니다', 'ok'); tlLoad(); })
    .catch(function(e){ alertBox(e.message, 'error'); });
}

/* ── 세금계산서 양식 — copy 'S' 공급자 보관용(빨강) / 'R' 공급받는자 보관용(파랑) ──
     매출 = 공급자 우리 회사 · 공급받는자 거래처 / 매입 = 공급자 거래처 · 공급받는자 우리 회사 */
function tfHtml(j, copy){
  var h = j.head, c = j.comp || {}, L = j.lines || [];
  var us = { bizno:c.bizno, nm:c.compNm, ceo:c.ceoNm, addr:c.addr, cond:c.bizCond, item:c.bizItem, email:c.email };
  var th = { bizno:h.bizno, nm:h.fullNm || h.custNm, ceo:h.ceoNm, addr:h.addr, cond:h.bizCond, item:h.bizItem, email:h.email };
  var sup = h.billGb === 'P' ? th : us, rcv = h.billGb === 'P' ? us : th;
  var free = h.taxGb === '면세';
  var title = free ? '계 산 서' : '세 금 계 산 서';
  var wd = d8(h.writeDt);
  function party(lbl, p){
    return '<td class="vert" rowspan="5">' + lbl + '</td>'
      + '<th style="width:58px">등록번호</th><td class="v" colspan="3" style="font-size:13px;font-weight:700;letter-spacing:1px">' + esc(bizFmt(p.bizno)) + '</td>';
  }
  function partyRows(p){
    return [ '<th>상호<br>(법인명)</th><td class="v">' + esc(p.nm) + '</td><th style="width:34px">성명</th><td class="v">' + esc(p.ceo) + '</td>',
             '<th>사업장<br>주소</th><td class="v" colspan="3">' + esc(p.addr) + '</td>',
             '<th>업태</th><td class="v">' + esc(p.cond) + '</td><th>종목</th><td class="v">' + esc(p.item) + '</td>',
             '<th>이메일</th><td class="v" colspan="3">' + esc(p.email) + '</td>' ];
  }
  var a = partyRows(sup), b = partyRows(rcv);
  var x = '<div class="tf ' + copy + '"><div class="outer">'
    + '<table><tr><td class="ttl" style="border:0">' + title + ' <small>(' + (copy === 'S' ? '공급자 보관용' : '공급받는자 보관용') + ')</small></td>'
    + '<td style="width:150px;border-top:0;border-right:0;border-bottom:0" class="c">일련번호 ' + esc(h.billSeq) + (h.ntsNo ? '<br>승인번호 ' + esc(h.ntsNo) : '') + '</td></tr></table>'
    + '<table><colgroup><col style="width:22px"><col style="width:58px"><col><col style="width:34px"><col><col style="width:22px"><col style="width:58px"><col><col style="width:34px"><col></colgroup>'
    + '<tr>' + party('공<br>급<br>자', sup) + party('공<br>급<br>받<br>는<br>자', rcv) + '</tr>';
  for (var i = 0; i < 4; i++) x += '<tr>' + a[i] + b[i] + '</tr>';
  x += '</table>'
    + '<table><tr><th style="width:130px">작성 년월일</th><th>공급가액</th>' + (free ? '' : '<th>세액</th>') + '<th>비고</th></tr>'
    + '<tr><td class="c">' + (wd ? wd.substr(0,4) + '년 ' + wd.substr(4,2) + '월 ' + wd.substr(6,2) + '일' : '') + '</td><td class="n" style="font-weight:700">' + fmt(h.supplyAmt) + '</td>'
    + (free ? '' : '<td class="n" style="font-weight:700">' + fmt(h.vatAmt) + '</td>') + '<td class="v">' + esc(h.remark) + '</td></tr></table>'
    + '<table><colgroup><col style="width:30px"><col style="width:30px"><col><col style="width:80px"><col style="width:60px"><col style="width:80px"><col style="width:95px">' + (free ? '' : '<col style="width:85px">') + '<col style="width:90px"></colgroup>'
    + '<tr><th>월</th><th>일</th><th>품목</th><th>규격</th><th>수량</th><th>단가</th><th>공급가액</th>' + (free ? '' : '<th>세액</th>') + '<th>비고</th></tr>';
  var rows = L.slice(); while (rows.length < 4) rows.push(null);   /* 종이 양식처럼 품목 칸은 최소 4줄 (new Array 는 빈 칸을 forEach 가 건너뛴다) */
  rows.forEach(function(l){
    if (!l){ x += '<tr><td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td><td></td>' + (free ? '' : '<td></td>') + '<td></td></tr>'; return; }
    var dt = d8(l.itemDt);
    x += '<tr><td class="c">' + (dt ? dt.substr(4,2) : '') + '</td><td class="c">' + (dt ? dt.substr(6,2) : '') + '</td><td class="v">' + esc(l.itemNm) + '</td><td class="v">' + esc(l.spec) + '</td>'
       + '<td class="n">' + fmtQ(l.qty) + '</td><td class="n">' + fmtQ(l.price) + '</td><td class="n">' + fmt(l.supplyAmt) + '</td>' + (free ? '' : '<td class="n">' + fmt(l.vatAmt) + '</td>') + '<td class="v">' + esc(l.remark) + '</td></tr>';
  });
  var tot = num(h.totAmt), cash = h.purposeGb === '영수';
  x += '</table>'
    + '<table class="foot2"><tr><th>합계금액</th><th>현금</th><th>수표</th><th>어음</th><th>외상미수금</th><td rowspan="2" class="c" style="width:170px;font-size:13px">이 금액을 <b>' + esc(h.purposeGb || '청구') + '</b> 함</td></tr>'
    + '<tr><td class="n" style="font-weight:800">' + fmt(tot) + '</td><td class="n">' + (cash ? fmt(tot) : '') + '</td><td></td><td></td><td class="n">' + (cash ? '' : fmt(tot)) + '</td></tr></table>'
    + '</div></div>';
  return x;
}

/* ── 인쇄 — 고른 계산서(없으면 아래에 열어 둔 한 장) ── */
function tlPrint(){
  var sel = tlSel().map(function(r){ return r.billSeq; });
  if (!sel.length && _pick) sel = [_pick];
  if (!sel.length){ alertBox('인쇄할 계산서를 고르세요(체크하거나 줄을 누르세요).'); return; }
  if (sel.length > 60){ alertBox('한 번에 60장까지 인쇄합니다.'); return; }
  var copy = document.getElementById('tlCopy').value;
  if (window._toast) _toast(sel.length + '장 불러오는 중…', 'info');
  Promise.all(sel.map(function(s){ return pj('/tax/get.do', { billSeq:s }); })).then(function(list){
    var h = '';
    list.forEach(function(j){
      if (!j || !j.ok) return;
      var pg = '';
      if (copy.indexOf('S') >= 0) pg += tfHtml(j, 'S');
      if (copy.indexOf('R') >= 0) pg += tfHtml(j, 'R');
      h += '<div class="pg">' + pg + '</div>';
    });
    document.getElementById('tlPrint').innerHTML = h;
    setTimeout(function(){ window.print(); }, 60);
  }).catch(function(e){ alertBox(e.message, 'error'); });
}

/* ── 엑셀(발행 내역) — 보이는 목록 그대로 ── */
function tlExcel(){
  if (!_rows.length){ alertBox('내보낼 자료가 없습니다.'); return; }
  var hd = ['작성일자','구분','상태','생성','거래처코드','거래처명','사업자번호','대표자','품목','공급가액','세액','합계금액','청구/영수','기간','승인번호','이메일','비고'];
  var t = '<table border="1"><tr>' + hd.map(function(x){ return '<th>' + x + '</th>'; }).join('') + '</tr>';
  _rows.forEach(function(r){
    var c = [dIso(r.writeDt), gbNm(r.billGb), r.actionYn === 'N' ? '삭제' : (ST_NM[r.status] || r.status), MK_NM[r.makeGb] || r.makeGb, r.custCd, r.fullNm || r.custNm,
             bizFmt(r.bizno), r.ceoNm, r.firstNm + (num(r.lineCnt) > 1 ? ' 외 ' + (num(r.lineCnt) - 1) + '줄' : ''), num(r.supplyAmt), num(r.vatAmt), num(r.totAmt), r.purposeGb,
             r.frDt ? dIso(r.frDt) + '~' + dIso(r.toDt) : '', r.ntsNo, r.email, r.remark];
    t += '<tr>' + c.map(function(v, i){ return '<td' + (i === 4 || i === 6 ? ' style="mso-number-format:\'\\@\'"' : '') + '>' + esc(v) + '</td>'; }).join('') + '</tr>';
  });
  t += '</table>';
  var blob = new Blob(['\ufeff<html><head><meta charset="utf-8"></head><body>' + t + '</body></html>'], { type:'application/vnd.ms-excel;charset=utf-8' });
  var a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = '계산서_발행내역_' + d8(document.getElementById('tlFr').value) + '_' + d8(document.getElementById('tlTo').value) + '.xls';
  document.body.appendChild(a); a.click(); setTimeout(function(){ URL.revokeObjectURL(a.href); a.remove(); }, 500);
}

/* 셸이 이 화면을 다시 보여 줄 때(다른 메뉴에서 계산서를 만들거나 확정한 뒤) 목록을 새로 읽는다 */
window.konetShown = function(){ tlLoad(); };

tlInit();
tlLoad();
</script>
