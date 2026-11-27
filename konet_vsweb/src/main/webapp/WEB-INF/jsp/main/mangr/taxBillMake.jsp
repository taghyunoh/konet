<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260917c"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20260910b"></script>
<script type="text/javascript">konetGridGrip('tmListWrap', 'tmListWrap', 'taxMakeList'); konetGridGrip('tmDtlWrap', 'tmDtlWrap', 'taxMakeDtl');</script>
<%--
  매출·매입 계산서 생성 (2026-11-27 사용자 「홀세일처럼 매출계산서, 매입계산서 (전자세금계산서 연동)」 → 「화면부터 먼저」)
    주소 = /tax/billMake.do?gb=S(매출) | P(매입). 셸 메뉴 「세금계산서」 묶음.
    · 생성 방식 3가지(홀세일과 같은 이름) : [합계] 거래처마다 한 장 · 한 줄 / [건별] 전표(정산서·토더는 일자)마다 한 장 / [상품별] 거래처마다 한 장 · 상품별 줄
    · 원천 = 서버 /tax/srcData.do 의 낱줄(정산서·토더·판매전표 / 매입전표 + 할인). 금액 규칙은 일계장·거래처별 채권·채무와 같다.
      정산서·토더는 전표에 세액이 없어 합계 ÷ 1.1 로 나눈다(종합실적 psNorm 과 같은 규칙). 판매·매입전표는 적힌 공급가·세액 그대로.
    · 기준 : 매출(매입)기준 = 전표 금액 / 수금(지급)기준 = 그 기간 수금(지급)액 — 회사 정보의 「기본 발행 기준」이 첫 값.
    · 「매출합계에서 수금할인액 제외」 = 수금전표의 매출할인을 (−) 줄로 넣는다(홀세일과 같은 칸).
    · 만든 계산서는 「작성」 상태 — 확정 화면에서 확정해야 발행 대상이 된다. 국세청 전송은 중계업체 계약 뒤.
    · 줄을 누르면 아래에 그 계산서에 들어갈 품목(과 원천 전표 낱줄)이 보인다. 두 표 밑 막대로 높이 조정.
    ⚠이 파일에 mybatis 식 해시-중괄호 글자를 쓰지 말 것(JSP Deferred EL 로 읽혀 빈 화면). 자바스크립트 템플릿 문자열의 달러-중괄호도 JSP EL 이라 안 쓴다.
--%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --red:#c0392b; --blue:#1f6fb2; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; background:#f4f6f9; }
  .tm-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .tm-head{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:8px; }
  .tm-head h2{ margin:0 6px 0 0; font-size:21px; }
  .mode{ height:32px; border:1px solid #2a6db0; background:#fff; color:#1f5f9e; border-radius:6px; padding:0 13px; font-size:13px; font-weight:700; cursor:pointer; }
  .mode.on{ background:#2a6db0; color:#fff; }
  .go{ height:32px; border:1px solid #4a9d5b; background:#5cb85c; color:#fff; border-radius:6px; padding:0 12px; font-size:13px; font-weight:700; cursor:pointer; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:11px 13px; margin-bottom:11px; }
  table.cond{ width:100%; border-collapse:collapse; font-size:13px; }
  table.cond th{ width:130px; background:#eef1f4; border:1px solid var(--bd); padding:6px 8px; font-weight:800; text-align:center; }
  table.cond td{ border:1px solid var(--bd); padding:5px 8px; }
  .row{ display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
  .row label.l{ font-weight:700; color:#37475a; }
  input.t, select.t{ height:30px; border:1px solid #c7d0d9; border-radius:5px; padding:0 7px; font-size:13px; background:#fff; }
  input[type=date].t{ width:140px; }
  .btn{ height:30px; border:1px solid #c7d0d9; background:#fff; border-radius:6px; padding:0 11px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn.teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn.blue{ background:#2a6db0; color:#fff; border-color:#2a6db0; }
  .btn:disabled{ opacity:.45; cursor:not-allowed; }
  .chk{ display:inline-flex; align-items:center; gap:5px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
  .banner{ display:none; margin:0 0 10px; padding:9px 12px; border-radius:8px; font-size:13px; font-weight:700; }
  .banner.warn{ background:#fff4e5; border:1px solid #f0c27a; color:#8a5300; }
  .tbwrap{ overflow:auto; border:1px solid var(--bd); border-radius:8px; background:#fff; }
  #tmListWrap{ max-height:max(240px, 40vh); }
  #tmDtlWrap{ max-height:max(200px, 28vh); min-height:100px; }
  table.g{ width:100%; border-collapse:collapse; font-size:12.5px; white-space:nowrap; }
  table.g th{ background:#d9edf7; color:#1f2a37; font-weight:700; border:1px solid #9fb6c3; padding:6px 6px; position:sticky; top:0; z-index:2; cursor:pointer; user-select:none; }
  table.g th.ns{ cursor:default; }
  table.g th .ar{ color:#7b8d9c; font-size:10px; margin-left:3px; }
  table.g td{ border:1px solid #c9d3dc; padding:4px 6px; text-align:right; }
  table.g td.txt{ text-align:left; }
  table.g td.ctr{ text-align:center; }
  table.g tr.tot td{ background:#fcf8e3; font-weight:800; position:sticky; top:29px; z-index:1; }
  table.g tbody tr.pk{ cursor:pointer; }
  table.g tbody tr.pk:hover td{ background:#f3f8f6; }
  table.g tbody tr.pk.on td{ background:#dff0eb; font-weight:700; }
  table.g tbody tr.pk.on td:first-child{ box-shadow:inset 3px 0 0 var(--teal); }
  table.g tbody tr.dis td{ color:#9aa6b2; }
  table.g td.neg{ color:var(--red); }
  .tag{ display:inline-block; font-size:11px; padding:1px 6px; border-radius:9px; font-weight:700; margin-right:3px; }
  .tag.ex{ background:#e8f1fb; color:var(--blue); }
  .tag.bad{ background:#fdecea; color:var(--red); }
  .tag.gray{ background:#eef1f4; color:#5a6b7a; }
  .tag.free{ background:#f3ecfb; color:#6b3fa0; }
  .msg{ padding:24px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  .foot{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-top:10px; }
  .foot .sum{ font-weight:700; color:#37475a; }
  .foot .sum b{ color:var(--teal); }
  .foot .issue{ margin-left:auto; display:flex; align-items:center; gap:7px; }
  .foot .issue .lb{ font-size:18px; font-weight:700; }
  .foot .issue input{ height:34px; font-size:16px; width:160px; }
  .foot .issue .btn.make{ height:34px; font-size:16px; padding:0 14px; }
  .tabs{ display:flex; gap:5px; }
  .tab{ border:1px solid var(--bd); background:#fff; border-radius:7px; padding:4px 11px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; }
  .tab.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .tit{ display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:7px; font-weight:800; flex-wrap:wrap; }
  .note{ font-size:12px; color:#5a6b7a; font-weight:600; line-height:1.7; margin-top:6px; }
</style>

<div class="tm-wrap">
  <div class="tm-head">
    <h2 id="tmTitle">매출 계산서 생성(합계)</h2>
    <button class="mode" data-m="SUM" onclick="tmMode('SUM')">계산서 생성(합계)</button>
    <button class="mode" data-m="DOC" onclick="tmMode('DOC')">계산서 생성(건별)</button>
    <button class="mode" data-m="ITEM" onclick="tmMode('ITEM')">계산서 생성(상품별)</button>
    <button class="go" onclick="tmGoCfm()" title="만든 계산서를 확인하고 확정하는 화면">확정 화면으로 →</button>
  </div>
  <div class="banner warn" id="tmNoTable">⚠ 계산서 표가 아직 없습니다 — <b>docs/sql/20261127_taxbill.sql</b> 을 운영 DB 에서 먼저 실행해 주세요. 그 전에는 조회만 되고 [생성하기]는 막힙니다.</div>

  <div class="card">
    <table class="cond">
      <tr>
        <th>합계기간</th>
        <td><div class="row">
          <input type="date" class="t" id="tmFr"> ~ <input type="date" class="t" id="tmTo">
          <button class="btn" onclick="tmMonth(0)">이번 달</button>
          <button class="btn" onclick="tmMonth(-1)" title="지난 달 1일~말일, 발행일자 = 지난 달 말일">지난 달</button>
        </div></td>
        <th>구분</th>
        <td><div class="row">
          <select class="t" id="tmNew" onchange="tmRender()" title="신규 = 이 기간에 아직 계산서를 만들지 않은 것만"><option value="N">신규</option><option value="A">전체</option></select>
          <select class="t" id="tmTax" onchange="tmRender()"><option value="과세">과세</option><option value="면세">면세</option><option value="">과세+면세</option></select>
          <select class="t" id="tmBasis" onchange="tmBasisChg()"><option value="TRX">매출기준</option><option value="CASH">수금기준</option></select>
          <label class="chk" id="tmDcLbl"><input type="checkbox" id="tmDc" onchange="tmBuild(); tmRender()"> <span id="tmDcTxt">매출합계에서 수금할인액 제외</span></label>
        </div></td>
      </tr>
      <tr>
        <th>거래처조회조건</th>
        <td colspan="3"><div class="row">
          <label class="l">사원 :</label><select class="t" id="tmMgr" onchange="tmRender()"><option value="">전체</option></select>
          <label class="l">거래처 유형 :</label><select class="t" id="tmVgb" onchange="tmRender()"><option value="">전체</option></select>
          <input class="t" id="tmKw" placeholder="거래처명·코드·사업자번호" style="width:200px" oninput="tmRender()">
          <label class="chk" title="거래처 마스터의 계산서 구분이 「미발행」인 거래처도 보입니다"><input type="checkbox" id="tmInclNo" onchange="tmRender()"> 계산서 미발행 거래처 포함</label>
          <button class="btn blue" onclick="tmLoad()">조회하기</button>
        </div></td>
      </tr>
    </table>
  </div>

  <div class="card">
    <div class="tit"><span id="tmListTit">거래처별 합계</span><span class="note" id="tmListInfo" style="margin:0"></span></div>
    <div class="tbwrap" id="tmListWrap"><table class="g" id="tmList"><thead></thead><tbody><tr><td class="msg">기간을 고르고 [조회하기]를 누르세요.</td></tr></tbody></table></div>
    <div class="foot">
      <button class="btn" onclick="tmSelAll(true)">전체선택</button>
      <button class="btn" onclick="tmSelAll(false)">전체취소</button>
      <span class="sum">선택 개수 : <b id="tmSelCnt">0</b> &nbsp; 금액 : <b id="tmSelAmt">0</b></span>
      <div class="issue">
        <select class="t" id="tmPurpose" title="이 금액을 청구 / 영수 함"><option value="청구">청구</option><option value="영수">영수</option></select>
        <span class="lb">발행일자 :</span><input type="date" class="t" id="tmWriteDt">
        <button class="btn blue make" id="tmMakeBtn" onclick="tmCreate()">생성하기</button>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="tit">
      <span>📄 <span id="tmDtlSub">줄을 누르면 그 계산서에 들어갈 품목이 여기 보입니다</span></span>
      <span class="tabs"><span class="tab on" data-t="BILL" onclick="tmDtlTab('BILL')">계산서 품목 <span id="tmCntBill"></span></span><span class="tab" data-t="SRC" onclick="tmDtlTab('SRC')">원천 전표 낱줄 <span id="tmCntSrc"></span></span></span>
    </div>
    <div class="tbwrap" id="tmDtlWrap"><table class="g" id="tmDtl"><thead></thead><tbody></tbody></table></div>
    <div class="note">
      · 정산서·토더 발주는 전표에 세액이 없어 <b>합계 ÷ 1.1</b>(반올림)을 공급가로 봅니다(종합 실적과 같은 규칙). 판매·매입 전표는 적힌 공급가·세액 그대로입니다.<br>
      · 전자세금계산서는 한 장에 품목 <b>99줄</b>까지 — 넘으면 99번째 줄에 나머지를 「기타 N품목」으로 묶습니다.<br>
      · 사업자번호가 없거나 10자리가 아닌 거래처는 만들 수는 있지만 <b>확정이 안 됩니다</b>(거래처 마스터에서 고친 뒤 다시 만드세요).
    </div>
  </div>
</div>

<script type="text/javascript">
var CTX = '${pageContext.request.contextPath}';
var GB = (function(){ var m = /[?&]gb=([SP])/.exec(location.search); return m ? m[1] : 'S'; })();
var KS = window.konetSet || { func:{} };
var TAX_ITEM_NM = String((KS.func && KS.func.taxItemNm) || '').trim();
var _src = null;          /* 서버 원천 { lines, vendors, existing, noTable } */
var _ven = {};            /* custCd → 거래처 */
var _rows = [];           /* 접은 줄(= 계산서 후보) */
var _view = [];           /* 거른 뒤 보이는 줄 */
var _mode = 'SUM', _pick = '', _dtlTab = 'BILL', _sort = { k:'', d:1 };
var _req = 0;

function esc(s){ return String(s == null ? '' : s).replace(/[&<>"']/g, function(c){ return { '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' }[c]; }); }
function num(v){ var x = Number(v); return isFinite(x) ? x : 0; }
function fmt(v){ return Math.round(num(v)).toLocaleString('ko-KR'); }
function fmtQ(v){ var x = num(v); return x === 0 ? '' : (Math.round(x * 100) / 100).toLocaleString('ko-KR'); }
function d8(s){ return String(s || '').replace(/-/g, ''); }
function dIso(s){ s = d8(s); return s.length === 8 ? s.substr(0,4) + '-' + s.substr(4,2) + '-' + s.substr(6,2) : ''; }
function dMd(s){ s = d8(s); return s.length === 8 ? s.substr(4,2) + '/' + s.substr(6,2) : ''; }
function ymd(d){ return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
function bizOk(b){ return /^\d{10}$/.test(String(b || '').replace(/[-\s]/g, '')); }
function bizFmt(b){ b = String(b || '').replace(/[-\s]/g, ''); return /^\d{10}$/.test(b) ? b.substr(0,3) + '-' + b.substr(3,2) + '-' + b.substr(5) : b; }
function pj(url, body){
  return fetch(CTX + url, { method:'POST', credentials:'same-origin', headers:{ 'Content-Type':'application/json;charset=UTF-8' }, body:JSON.stringify(body || {}) })
    .then(function(r){ if (r.status === 401) throw new Error('로그인이 끊겼습니다 — 다시 로그인한 뒤 해 주세요.'); return r.json(); });
}
var IC = { info:'ℹ️', warning:'⚠️', error:'❌', success:'✅', question:'🧾' };
function alertBox(m, ic){ if (window._alertBox) _alertBox(m, { icon: IC[ic || 'info'] || ic }); }

/* ── 매출/매입 낱말 ── */
var W = GB === 'P'
  ? { name:'매입', basisTrx:'매입기준', basisCash:'지급기준', dc:'매입합계에서 지급할인액 제외', trxSrc:{ PURCH:1, PURCHDC:1 }, dcSrc:'PAYDC', srcNm:{ PURCH:'매입전표', PURCHDC:'매입 할인', PAYDC:'지급할인', CASH:'지급' } }
  : { name:'매출', basisTrx:'매출기준', basisCash:'수금기준', dc:'매출합계에서 수금할인액 제외', trxSrc:{ STMT:1, TD:1, STRX:1, STRXDC:1 }, dcSrc:'RCVDC', srcNm:{ STMT:'정산서', TD:'토더 발주', STRX:'판매전표', STRXDC:'판매 할인', RCVDC:'수금할인', CASH:'수금' } };
var MODE_NM = { SUM:'합계', DOC:'건별', ITEM:'상품별' };

function tmInit(){
  document.title = W.name + ' 계산서 생성';
  document.getElementById('tmBasis').options[0].text = W.basisTrx;
  document.getElementById('tmBasis').options[1].text = W.basisCash;
  document.getElementById('tmDcTxt').textContent = W.dc;
  var ig = String((KS.func && KS.func.taxIssueGb) || '');
  if (/수금|지급/.test(ig)) document.getElementById('tmBasis').value = 'CASH';
  var mm = null; try { mm = localStorage.getItem('konetTaxMakeMode.' + GB); } catch (e) {}
  if (mm && MODE_NM[mm]) _mode = mm;
  tmMonth(0, true);
  tmModePaint();
  tmBasisChg(true);
}
function tmMonth(off, silent){
  var t = new Date(), f, e, w;
  if (off === 0){ f = new Date(t.getFullYear(), t.getMonth(), 1); e = t; w = t; }
  else { f = new Date(t.getFullYear(), t.getMonth() + off, 1); e = new Date(t.getFullYear(), t.getMonth() + off + 1, 0); w = e; }
  document.getElementById('tmFr').value = ymd(f);
  document.getElementById('tmTo').value = ymd(e);
  document.getElementById('tmWriteDt').value = ymd(w);
  if (!silent) tmLoad();
}
function tmModePaint(){
  [].forEach.call(document.querySelectorAll('.mode'), function(b){ b.classList.toggle('on', b.getAttribute('data-m') === _mode); });
  document.getElementById('tmTitle').textContent = W.name + ' 계산서 생성(' + MODE_NM[_mode] + ')';
  document.getElementById('tmListTit').textContent = _mode === 'DOC' ? '전표별 (한 줄 = 계산서 한 장)' : (_mode === 'ITEM' ? '거래처별 — 상품별 품목 줄' : '거래처별 합계 (한 줄 = 계산서 한 장)');
}
function tmMode(m){
  if (m === 'ITEM' && document.getElementById('tmBasis').value === 'CASH'){ alertBox(W.basisCash + '은 상품이 없어 상품별로 만들 수 없습니다. 합계나 건별을 쓰세요.'); return; }
  _mode = m; _pick = ''; try { localStorage.setItem('konetTaxMakeMode.' + GB, m); } catch (e) {}
  tmModePaint(); tmBuild(); tmRender();
}
function tmBasisChg(silent){
  var cash = document.getElementById('tmBasis').value === 'CASH';
  document.getElementById('tmDcLbl').style.display = cash ? 'none' : '';
  if (cash && _mode === 'ITEM'){ _mode = 'SUM'; tmModePaint(); }
  if (!silent){ _pick = ''; tmBuild(); tmRender(); }
}
function tmGoCfm(){
  var url = CTX + '/tax/billList.do?mode=cfm&gb=' + GB;
  if (window.parent && parent !== window && parent.logiFrame){
    var key = GB === 'P' ? 'taxCfmP' : 'taxCfmS';
    var a = parent.document.querySelector('a.mi[data-key="' + key + '"]');
    if (a){ a.click(); return; }
  }
  location.href = url;
}

/* ── 조회 ── */
function tmLoad(){
  var fr = d8(document.getElementById('tmFr').value), to = d8(document.getElementById('tmTo').value);
  if (fr.length !== 8 || to.length !== 8){ alertBox('기간을 넣어 주세요.'); return; }
  if (fr > to){ alertBox('시작일이 종료일보다 뒤입니다.'); return; }
  var my = ++_req;
  document.querySelector('#tmList tbody').innerHTML = '<tr><td class="msg">불러오는 중… (한 달이면 5~10초 걸립니다)</td></tr>';
  pj('/tax/srcData.do', { gb:GB, frDt:fr, toDt:to }).then(function(j){
    if (my !== _req) return;
    if (!j || !j.ok){ document.querySelector('#tmList tbody').innerHTML = '<tr><td class="msg">' + esc((j && j.msg) || '조회 실패') + '</td></tr>'; return; }
    _src = j; _src.fr = fr; _src.to = to;
    _ven = {};
    (j.vendors || []).forEach(function(v){ _ven[v.custCd] = v; });
    document.getElementById('tmNoTable').style.display = j.noTable ? 'block' : 'none';
    document.getElementById('tmMakeBtn').disabled = !!j.noTable;
    tmFillFilters();
    tmBuild(); tmRender();
  }).catch(function(e){ if (my === _req) document.querySelector('#tmList tbody').innerHTML = '<tr><td class="msg">' + esc(e.message) + '</td></tr>'; });
}
function tmFillFilters(){
  var mg = {}, vg = {};
  (_src.vendors || []).forEach(function(v){ if (v.mgrCd) mg[v.mgrCd] = v.mgrNm || v.mgrCd; if (v.vendorGb) vg[v.vendorGb] = 1; });
  var s1 = document.getElementById('tmMgr'), k1 = s1.value, s2 = document.getElementById('tmVgb'), k2 = s2.value;
  s1.innerHTML = '<option value="">전체</option>' + Object.keys(mg).sort().map(function(k){ return '<option value="' + esc(k) + '">' + esc(mg[k]) + '</option>'; }).join('');
  s2.innerHTML = '<option value="">전체</option>' + Object.keys(vg).sort().map(function(k){ return '<option>' + esc(k) + '</option>'; }).join('');
  s1.value = k1; s2.value = k2;
}

/* ── 낱줄 정리 : 공급가·세액 채우기 + 과세/면세 ── */
function tmNorm(l){
  var v = _ven[l.custCd] || {};
  var free = l.taxGb === '면세' || v.vatGb === '면세';
  var amt = num(l.amt), sup, vat;
  if (free){ sup = amt; vat = 0; }
  else if (l.supplyAmt == null){ sup = Math.round(amt / 1.1); vat = amt - sup; }
  else { sup = num(l.supplyAmt); vat = num(l.vatAmt); }
  return { src:l.src, custCd:l.custCd, dt:l.dt, docKey:l.docKey, docNo:l.docNo, itemCd:l.itemCd || '', itemNm:l.itemNm || '', spec:l.spec || '',
           qty:num(l.qty), price:num(l.price), amt:amt, sup:sup, vat:vat, taxGb: free ? '면세' : '과세', calc: l.supplyAmt == null && !free };
}

/* ── 접기 : 모드·기준에 따라 계산서 후보 줄을 만든다 ── */
function tmBuild(){
  _rows = [];
  if (!_src) return;
  var cash = document.getElementById('tmBasis').value === 'CASH';
  var withDc = !cash && document.getElementById('tmDc').checked;
  var map = {};
  (_src.lines || []).forEach(function(l0){
    var ok = cash ? l0.src === 'CASH' : (W.trxSrc[l0.src] || (withDc && l0.src === W.dcSrc));
    if (!ok) return;
    var l = tmNorm(l0);
    if (l.amt === 0) return;
    var key = l.custCd + '|' + l.taxGb + (_mode === 'DOC' ? '|' + l.docKey : '');
    var r = map[key];
    if (!r){
      var v = _ven[l.custCd];
      r = map[key] = { key:key, custCd:l.custCd, taxGb:l.taxGb, docKey: _mode === 'DOC' ? l.docKey : '', docNo:l.docNo, src:l.src, dt:l.dt, dt2:l.dt,
                       v:v || null, lines:[], sup:0, vat:0, docs:{}, items:{} };
      _rows.push(r);
    }
    r.lines.push(l); r.sup += l.sup; r.vat += l.vat;
    r.docs[l.docKey] = 1;
    if (l.itemNm && l.amt > 0) r.items[l.itemCd + '|' + l.itemNm] = 1;
    if (l.dt < r.dt) r.dt = l.dt;
    if (l.dt > r.dt2) r.dt2 = l.dt;
  });
  _rows.forEach(function(r){
    r.tot = r.sup + r.vat;
    r.docCnt = Object.keys(r.docs).length;
    r.itemCnt = Object.keys(r.items).length;
    r.custNm = r.v ? r.v.custNm : '(마스터 없음)';
    r.fullNm = r.v ? (r.v.fullNm || r.v.custNm) : '';
    r.bizno = r.v ? r.v.bizno : '';
    r.ceoNm = r.v ? r.v.ceoNm : '';
    r.exist = tmExist(r);
    r.firstNm = '';
    for (var i = 0; i < r.lines.length; i++){ if (r.lines[i].amt > 0 && r.lines[i].itemNm){ r.firstNm = r.lines[i].itemNm; break; } }
    r.dis = !r.v ? '거래처 마스터에 없는 거래처' : (r.tot <= 0 ? '합계가 0 이하(할인·반품만)' : '');
    r.sel = false;
  });
}
/* 이 기간에 이미 만든 계산서 — 건별은 같은 전표, 합계·상품별은 같은 거래처·과세 구분 */
function tmExist(r){
  return (_src.existing || []).filter(function(e){
    if (e.custCd !== r.custCd) return false;
    if (_mode === 'DOC') return e.srcKey === r.docKey;
    return (e.taxGb || '과세') === r.taxGb;
  });
}

/* ── 계산서 품목 줄 만들기 (미리보기 · 생성 공용) ── */
function tmBillLines(r, writeDt){
  var wd = d8(writeDt), out = [];
  var cash = document.getElementById('tmBasis').value === 'CASH';
  if (_mode === 'SUM'){
    var nm;
    if (cash) nm = TAX_ITEM_NM || '물품대금';
    else nm = TAX_ITEM_NM || ((r.firstNm || '물품') + (r.itemCnt > 1 ? ' 외 ' + (r.itemCnt - 1) + '건' : ''));
    out.push({ itemDt:wd, itemCd:'', itemNm:nm, spec:'', qty:null, price:null, supplyAmt:r.sup, vatAmt:r.vat,
               remark: dMd(r.dt) + (r.dt2 !== r.dt ? '~' + dMd(r.dt2) : '') });
    return out;
  }
  if (_mode === 'DOC'){
    r.lines.forEach(function(l){
      out.push({ itemDt:l.dt, itemCd:l.itemCd, itemNm:l.itemNm, spec:l.spec, qty:l.qty || null,
                 price: l.qty ? Math.round(l.sup / l.qty * 100) / 100 : null, supplyAmt:l.sup, vatAmt:l.vat, remark:'' });
    });
    return tmCap(out, wd);
  }
  /* 상품별 — 같은 상품(코드+이름+규격)을 한 줄로 */
  var m = {}, ord = [];
  r.lines.forEach(function(l){
    var k = l.itemCd + '|' + l.itemNm + '|' + l.spec;
    var x = m[k];
    if (!x){ x = m[k] = { itemDt:wd, itemCd:l.itemCd, itemNm:l.itemNm, spec:l.spec, qty:0, price:null, supplyAmt:0, vatAmt:0, remark:'' }; ord.push(x); }
    x.qty += l.qty; x.supplyAmt += l.sup; x.vatAmt += l.vat;
  });
  ord.forEach(function(x){ x.price = x.qty ? Math.round(x.supplyAmt / x.qty * 100) / 100 : null; if (!x.qty) x.qty = null; });
  return tmCap(ord, wd);
}
/* 99줄 상한 — 98줄 + 「기타 N품목」 */
function tmCap(a, wd){
  if (a.length <= 99) return a;
  var head = a.slice(0, 98), rest = a.slice(98), s = 0, v = 0;
  rest.forEach(function(x){ s += x.supplyAmt; v += x.vatAmt; });
  head.push({ itemDt:wd, itemCd:'', itemNm:'기타 ' + rest.length + '품목', spec:'', qty:null, price:null, supplyAmt:s, vatAmt:v, remark:'' });
  return head;
}

/* ── 그리기 ── */
var COLS = {
  SUM:  [ ['custCd','거래처코드','txt'], ['bizno','거래처사업자번호','ctr'], ['custNm','거래처명','txt'], ['fullNm','정식명칭','txt'], ['ceoNm','대표자명','txt'],
          ['docCnt','전표','ctr'], ['sup','공급가액',''], ['vat','부가세',''], ['tot','합계금액',''], ['st','상태','txt'] ],
  DOC:  [ ['dt','일자','ctr'], ['custCd','거래처코드','txt'], ['custNm','거래처명','txt'], ['bizno','사업자번호','ctr'], ['docNo','전표','txt'], ['firstNm','품목','txt'],
          ['sup','공급가액',''], ['vat','부가세',''], ['tot','합계금액',''], ['st','상태','txt'] ],
  ITEM: [ ['custCd','거래처코드','txt'], ['bizno','거래처사업자번호','ctr'], ['custNm','거래처명','txt'], ['fullNm','정식명칭','txt'], ['ceoNm','대표자명','txt'],
          ['itemCnt','품목 수','ctr'], ['sup','공급가액',''], ['vat','부가세',''], ['tot','합계금액',''], ['st','상태','txt'] ]
};
function tmFilter(){
  var onlyNew = document.getElementById('tmNew').value === 'N';
  var tax = document.getElementById('tmTax').value, mgr = document.getElementById('tmMgr').value, vgb = document.getElementById('tmVgb').value;
  var inclNo = document.getElementById('tmInclNo').checked;
  var kw = document.getElementById('tmKw').value.trim().toLowerCase().replace(/-/g, '');
  return _rows.filter(function(r){
    if (onlyNew && r.exist.length) return false;
    if (tax && r.taxGb !== tax) return false;
    var v = r.v || {};
    if (mgr && v.mgrCd !== mgr) return false;
    if (vgb && v.vendorGb !== vgb) return false;
    if (!inclNo && v.taxbillGb === '미발행') return false;
    if (kw){ var h = (r.custCd + ' ' + r.custNm + ' ' + r.fullNm + ' ' + String(r.bizno || '').replace(/-/g, '')).toLowerCase(); if (h.indexOf(kw) < 0) return false; }
    return true;
  });
}
function tmStatus(r){
  var h = '';
  if (r.dis) h += '<span class="tag gray">' + esc(r.dis) + '</span>';
  if (r.exist.length){
    var t = 0, st = {};
    r.exist.forEach(function(e){ t += num(e.totAmt); st[e.status] = 1; });
    h += '<span class="tag ex" title="이 기간에 이미 만든 계산서 ' + r.exist.length + '장 · 합계 ' + fmt(t) + '">생성됨 ' + r.exist.length + '장' + (st.I ? '·발행' : (st.C ? '·확정' : '')) + '</span>';
  }
  if (r.v && !bizOk(r.bizno)) h += '<span class="tag bad" title="사업자번호가 없거나 10자리가 아닙니다 — 만들 수는 있지만 확정이 안 됩니다">사업자번호 확인</span>';
  if (r.taxGb === '면세') h += '<span class="tag free">면세(계산서)</span>';
  if (r.v && r.v.taxbillGb === '미발행') h += '<span class="tag gray">미발행 거래처</span>';
  if (r.lines.some(function(l){ return l.calc; })) h += '<span class="tag gray" title="정산서·토더는 합계 ÷ 1.1 로 공급가를 나눴습니다">÷1.1</span>';
  return h;
}
function tmRender(){
  var thead = document.querySelector('#tmList thead'), tb = document.querySelector('#tmList tbody');
  var cols = COLS[_mode];
  if (!_src){ return; }
  _view = tmFilter();
  if (_sort.k){
    var k = _sort.k, d = _sort.d;
    _view.sort(function(a, b){ var x = a[k], y = b[k]; if (typeof x === 'number' || typeof y === 'number') return (num(x) - num(y)) * d; return String(x || '').localeCompare(String(y || ''), 'ko') * d; });
  }
  thead.innerHTML = '<tr><th class="ns" style="width:44px">선택</th>' + cols.map(function(c){
    var ar = _sort.k === c[0] ? (_sort.d > 0 ? '▲' : '▼') : '◆';
    return '<th' + (c[0] === 'st' ? ' class="ns"' : ' onclick="tmSort(\'' + c[0] + '\')"') + '>' + c[1] + (c[0] === 'st' ? '' : '<span class="ar">' + ar + '</span>') + '</th>';
  }).join('') + '</tr>';
  if (!_view.length){
    tb.innerHTML = '<tr><td class="msg" colspan="' + (cols.length + 1) + '">등록된 DATA가 없습니다.' + (_rows.length ? ' (조건에 맞는 것이 없습니다 — 「구분」을 전체로 바꾸거나 거래처 조건을 확인하세요)' : '') + '</td></tr>';
    document.getElementById('tmListInfo').textContent = '';
    if (_pick){ _pick = ''; } tmDtlRender(); tmSelPaint(); return;
  }
  var ts = 0, tv = 0;
  _view.forEach(function(r){ ts += r.sup; tv += r.vat; });
  var h = '<tr class="tot"><td class="ctr">합계</td>' + cols.map(function(c){
    if (c[0] === 'sup') return '<td>' + fmt(ts) + '</td>';
    if (c[0] === 'vat') return '<td>' + fmt(tv) + '</td>';
    if (c[0] === 'tot') return '<td>' + fmt(ts + tv) + '</td>';
    if (c[0] === 'custCd' || c[0] === 'dt') return '<td class="ctr">' + _view.length + '장</td>';
    return '<td></td>';
  }).join('') + '</tr>';
  _view.forEach(function(r, i){
    h += '<tr class="pk' + (r.key === _pick ? ' on' : '') + (r.dis ? ' dis' : '') + '" data-i="' + i + '">'
       + '<td class="ctr"><input type="checkbox" class="sel" data-i="' + i + '"' + (r.sel ? ' checked' : '') + (r.dis ? ' disabled' : '') + '></td>'
       + cols.map(function(c){
           var k = c[0], v = r[k];
           if (k === 'st') return '<td class="txt">' + tmStatus(r) + '</td>';
           if (k === 'sup' || k === 'vat' || k === 'tot') return '<td' + (num(v) < 0 ? ' class="neg"' : '') + '>' + fmt(v) + '</td>';
           if (k === 'bizno') return '<td class="ctr">' + esc(bizFmt(v)) + '</td>';
           if (k === 'dt') return '<td class="ctr">' + esc(dIso(v)) + '</td>';
           if (k === 'docNo') return '<td class="txt">' + esc((W.srcNm[r.src] || r.src) + ' ' + (r.src === 'STMT' || r.src === 'TD' ? dMd(r.dt) + ' (' + r.lines.length + '줄)' : v)) + '</td>';
           if (k === 'firstNm') return '<td class="txt">' + esc(v + (r.itemCnt > 1 ? ' 외 ' + (r.itemCnt - 1) + '건' : '')) + '</td>';
           return '<td class="' + c[2] + '">' + esc(v) + '</td>';
         }).join('') + '</tr>';
  });
  tb.innerHTML = h;
  var nEx = _rows.filter(function(r){ return r.exist.length; }).length;
  document.getElementById('tmListInfo').textContent = '원천 ' + _src.fr.substr(0,4) + '-' + _src.fr.substr(4,2) + '-' + _src.fr.substr(6) + ' ~ ' + dIso(_src.to)
    + ' · ' + MODE_NM[_mode] + ' ' + _rows.length + '장 후보' + (nEx ? ' · 이미 만든 것 ' + nEx : '');
  if (_pick && !_view.some(function(r){ return r.key === _pick; })) _pick = '';
  tmDtlRender(); tmSelPaint();
}
function tmSort(k){ if (_sort.k === k) _sort.d = -_sort.d; else { _sort.k = k; _sort.d = (k === 'sup' || k === 'vat' || k === 'tot') ? -1 : 1; } tmRender(); }

document.addEventListener('click', function(e){
  var cb = e.target.closest && e.target.closest('#tmList input.sel');
  if (cb){ var r = _view[+cb.getAttribute('data-i')]; if (r) r.sel = cb.checked; tmSelPaint(); return; }
  var tr = e.target.closest && e.target.closest('#tmList tbody tr.pk');
  if (tr){ var r2 = _view[+tr.getAttribute('data-i')]; if (!r2) return; _pick = r2.key;
    [].forEach.call(document.querySelectorAll('#tmList tbody tr.pk'), function(x){ x.classList.toggle('on', x === tr); });
    tmDtlRender(); }
});
function tmSelAll(on){ _view.forEach(function(r){ if (!r.dis) r.sel = on; }); [].forEach.call(document.querySelectorAll('#tmList input.sel'), function(c){ if (!c.disabled) c.checked = on; }); tmSelPaint(); }
function tmSelPaint(){
  var n = 0, t = 0;
  _view.forEach(function(r){ if (r.sel && !r.dis){ n++; t += r.tot; } });
  document.getElementById('tmSelCnt').textContent = n;
  document.getElementById('tmSelAmt').textContent = fmt(t);
}

/* ── 하단 : 계산서 품목 / 원천 낱줄 ── */
function tmDtlTab(t){ _dtlTab = t; [].forEach.call(document.querySelectorAll('.tab'), function(x){ x.classList.toggle('on', x.getAttribute('data-t') === t); }); tmDtlRender(); }
function tmDtlRender(){
  var thead = document.querySelector('#tmDtl thead'), tb = document.querySelector('#tmDtl tbody');
  var r = null; for (var i = 0; i < _view.length; i++) if (_view[i].key === _pick){ r = _view[i]; break; }
  if (!r){
    thead.innerHTML = ''; tb.innerHTML = '<tr><td class="msg">위 표에서 줄을 누르세요.</td></tr>';
    document.getElementById('tmDtlSub').textContent = '줄을 누르면 그 계산서에 들어갈 품목이 여기 보입니다';
    document.getElementById('tmCntBill').textContent = ''; document.getElementById('tmCntSrc').textContent = '';
    return;
  }
  var bl = tmBillLines(r, document.getElementById('tmWriteDt').value);
  document.getElementById('tmDtlSub').textContent = r.custNm + ' [' + r.custCd + ']' + (r.docKey ? ' · ' + (W.srcNm[r.src] || r.src) + ' ' + (r.src === 'STMT' || r.src === 'TD' ? dIso(r.dt) : r.docNo) : '') + ' — ' + r.taxGb + ' · 합계 ' + fmt(r.tot);
  document.getElementById('tmCntBill').textContent = '(' + bl.length + ')';
  document.getElementById('tmCntSrc').textContent = '(' + r.lines.length + ')';
  var h = '';
  if (_dtlTab === 'BILL'){
    thead.innerHTML = '<tr><th class="ns">#</th><th class="ns">월/일</th><th class="ns">품목</th><th class="ns">규격</th><th class="ns">수량</th><th class="ns">단가(공급가)</th><th class="ns">공급가액</th><th class="ns">세액</th><th class="ns">비고</th></tr>';
    var s = 0, v = 0; bl.forEach(function(x){ s += x.supplyAmt; v += x.vatAmt; });
    h = '<tr class="tot"><td class="ctr" colspan="6">합계 (' + bl.length + '줄)</td><td>' + fmt(s) + '</td><td>' + fmt(v) + '</td><td class="txt">' + fmt(s + v) + '</td></tr>';
    bl.forEach(function(x, i){
      h += '<tr><td class="ctr">' + (i + 1) + '</td><td class="ctr">' + dMd(x.itemDt) + '</td><td class="txt">' + esc(x.itemNm) + '</td><td class="txt">' + esc(x.spec) + '</td>'
         + '<td>' + fmtQ(x.qty) + '</td><td>' + fmtQ(x.price) + '</td><td' + (x.supplyAmt < 0 ? ' class="neg"' : '') + '>' + fmt(x.supplyAmt) + '</td><td' + (x.vatAmt < 0 ? ' class="neg"' : '') + '>' + fmt(x.vatAmt) + '</td><td class="txt">' + esc(x.remark) + '</td></tr>';
    });
  } else {
    thead.innerHTML = '<tr><th class="ns">구분</th><th class="ns">일자</th><th class="ns">전표</th><th class="ns">코드</th><th class="ns">품목</th><th class="ns">규격</th><th class="ns">수량</th><th class="ns">단가</th><th class="ns">금액(부가세 포함)</th><th class="ns">공급가</th><th class="ns">세액</th></tr>';
    var a = 0, s2 = 0, v2 = 0; r.lines.forEach(function(l){ a += l.amt; s2 += l.sup; v2 += l.vat; });
    h = '<tr class="tot"><td class="ctr" colspan="8">합계 (' + r.lines.length + '줄)</td><td>' + fmt(a) + '</td><td>' + fmt(s2) + '</td><td>' + fmt(v2) + '</td></tr>';
    r.lines.forEach(function(l){
      h += '<tr><td class="ctr">' + esc(W.srcNm[l.src] || l.src) + '</td><td class="ctr">' + esc(dIso(l.dt)) + '</td><td class="txt">' + esc(l.docNo) + '</td><td class="txt">' + esc(l.itemCd) + '</td><td class="txt">' + esc(l.itemNm) + '</td><td class="txt">' + esc(l.spec) + '</td>'
         + '<td>' + fmtQ(l.qty) + '</td><td>' + fmtQ(l.price) + '</td><td' + (l.amt < 0 ? ' class="neg"' : '') + '>' + fmt(l.amt) + '</td>'
         + '<td' + (l.calc ? ' title="합계 ÷ 1.1 환산" style="color:#6b7a89"' : '') + '>' + fmt(l.sup) + '</td><td' + (l.calc ? ' style="color:#6b7a89"' : '') + '>' + fmt(l.vat) + '</td></tr>';
    });
  }
  tb.innerHTML = h;
}
document.getElementById('tmWriteDt').addEventListener('change', function(){ tmDtlRender(); });

/* ── 생성하기 ── */
function tmCreate(){
  if (!_src){ alertBox('먼저 [조회하기]를 누르세요.'); return; }
  if (_src.noTable){ alertBox('계산서 표가 아직 없습니다 — docs/sql/20261127_taxbill.sql 을 먼저 실행해 주세요.', 'warning'); return; }
  var sel = _view.filter(function(r){ return r.sel && !r.dis; });
  if (!sel.length){ alertBox('계산서를 만들 줄을 고르세요(왼쪽 체크).'); return; }
  if (sel.length > 500){ alertBox('한 번에 500장까지 만들 수 있습니다. 거래처 조건으로 나눠 주세요.'); return; }
  var wd = d8(document.getElementById('tmWriteDt').value);
  if (wd.length !== 8){ alertBox('발행일자를 넣어 주세요.'); return; }
  var dup = sel.filter(function(r){ return r.exist.length; }).length;
  var badBiz = sel.filter(function(r){ return !bizOk(r.bizno); }).length;
  var tot = 0; sel.forEach(function(r){ tot += r.tot; });
  var msg = '<b>' + W.name + ' 계산서 ' + sel.length + '장</b>을 만듭니다 (' + MODE_NM[_mode] + ' · ' + (document.getElementById('tmBasis').value === 'CASH' ? W.basisCash : W.basisTrx) + ')<br>'
          + '발행일자 ' + dIso(wd) + ' · 합계 ' + fmt(tot) + '원';
  if (wd < _src.to) msg += '<br><span style="color:#c0392b">⚠ 발행일자가 합계기간 끝(' + dIso(_src.to) + ')보다 앞입니다.</span>';
  if (dup) msg += '<br><span style="color:#c0392b">⚠ ' + dup + '장은 이 기간에 이미 만든 계산서가 있습니다 — 겹쳐 만들어집니다.</span>';
  if (badBiz) msg += '<br><span style="color:#8a5300">사업자번호 확인 ' + badBiz + '장은 만들어지지만 확정이 안 됩니다.</span>';
  msg += '<br>만든 계산서는 「작성」 상태입니다 — 확정 화면에서 확정합니다.';
  _confirmBox({ msg:msg, icon:IC.question, okText:'생성하기', okColor:'blue', onOk:function(){
    var fr = _src.fr, to = _src.to;
    var body = { gb:GB, makeGb:_mode, basisGb:document.getElementById('tmBasis').value, frDt:fr, toDt:to, writeDt:wd,
                 purposeGb:document.getElementById('tmPurpose').value,
                 bills: sel.map(function(r){ return { custCd:r.custCd, taxGb:r.taxGb, srcKey:r.docKey || '', lines:tmBillLines(r, wd) }; }) };
    var b = document.getElementById('tmMakeBtn'); b.disabled = true; b.textContent = '만드는 중…';
    pj('/tax/create.do', body).then(function(j){
      b.disabled = false; b.textContent = '생성하기';
      if (!j || !j.ok){ alertBox((j && j.msg) || '저장 실패', 'error'); return; }
      _confirmBox({ msg:'<b>계산서 ' + j.cnt + '장</b>을 만들었습니다 (합계 ' + fmt(j.totAmt) + '원).<br>확정 화면으로 갈까요?', icon:IC.success, okText:'확정 화면으로', okColor:'blue', onOk:tmGoCfm });
      tmLoad();
    }).catch(function(e){ b.disabled = false; b.textContent = '생성하기'; alertBox(e.message, 'error'); });
  } });
}

tmInit();
tmLoad();
</script>
