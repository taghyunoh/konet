<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 메시지는 프로젝트 공통 컴포넌트(로그인 화면과 동일) --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- 거래처 입력검색 — 거래처 칸에 직접 쳐서 고른다(2026-08-01). [거래처] 팝업은 그대로 둔다. --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js"></script>
<!--
  지급등록 — 홀세일닥터 '지급 등록' 이관 (2026-07-25 신설)
    · 원천 : TBL_SETTLE_TRX (TRX_GB='PAY'). 수금등록과 같은 테이블·같은 쿼리를 쓴다
    · 우측 원장은 매입전표 + 지급전표를 합쳐 일자별 잔고를 낸다
    · 설계 근거 : docs/매입등록_설계안.md §4-2
-->
<style>
  :root{ --sv-bd:#dbe2ea; --sv-teal:#137a6c; }
  *{ box-sizing:border-box; }
  .sv-wrap{ padding:12px 14px; font-family:'맑은 고딕',Malgun Gothic,sans-serif; font-size:14px; color:#1f2a37; }
  .sv-wrap h2{ margin:0 0 2px; font-size:18px; }
  .sv-sub{ color:#1f2a37; margin-bottom:8px; font-size:12.5px; font-weight:600; }
  .sv-card{ background:#fff; border:1px solid var(--sv-bd); border-radius:10px; padding:10px; margin-bottom:10px; }
  .sv-btn{ height:32px; border:1px solid var(--sv-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .sv-btn:hover{ border-color:var(--sv-teal); }
  .sv-btn.teal{ background:var(--sv-teal); color:#fff; border-color:var(--sv-teal); }
  .sv-btn.red{ color:#c0392b; border-color:#e3b4ae; }
  /* 입력 표 — 원본처럼 라벨/값 2열 */
  .sv-form{ width:100%; border-collapse:collapse; font-size:13.5px; }
  .sv-form th{ background:#eef3f2; border:1px solid var(--sv-bd); padding:6px 10px; width:90px; text-align:center; font-weight:700; }
  .sv-form td{ border:1px solid var(--sv-bd); padding:5px 8px; }
  .sv-form input, .sv-form select{ height:29px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .sv-form input.num{ text-align:right; }
  .sv-form input[readonly]{ background:#f5f7f9; }
  .sv-lbl{ color:#1f2a37; margin:0 4px 0 8px; font-size:12.5px; font-weight:700; white-space:nowrap; }
  .sv-bal{ font-weight:800; font-size:15px; color:#c0392b; }
  /* 목록 — 5행 고정 + 자동 스크롤(매출내역과 같은 방식) */
  .sv-list{ max-height:196px; overflow:auto; border:1px solid var(--sv-bd); border-radius:8px; }
  .sv-list table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sv-list th{ background:#eef3f2; border:1px solid var(--sv-bd); padding:7px 8px; position:sticky; top:0; z-index:2; }
  .sv-list td{ border:1px solid var(--sv-bd); padding:6px 8px; text-align:center; }
  .sv-list td.num{ text-align:right; }
  .sv-list tr{ cursor:pointer; }
  .sv-list tr:hover td{ background:#f3f8f6; }
  .sv-list tr.on td{ background:#fdeef0; font-weight:700; }
  .sv-sum{ display:flex; border:1px solid var(--sv-bd); border-top:0; border-radius:0 0 8px 8px; overflow:hidden; }
  .sv-sum div{ flex:1; padding:8px 10px; font-size:13.5px; }
  .sv-sum div.k{ background:#eef3f2; font-weight:700; flex:0 0 90px; text-align:center; }
  .sv-sum div.v{ text-align:right; font-weight:700; }
  /* 팝업 */
  .sv-pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:200; }
  .sv-pop.on{ display:block; }
  .sv-pop .box{ background:#fff; width:min(680px,94vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.3); }
  .sv-pop .hd{ padding:12px 16px; border-bottom:1px solid var(--sv-bd); font-weight:800; display:flex; gap:8px; align-items:center; }
  .sv-pop .bd{ padding:12px 16px; overflow:auto; }
  .sv-pop .ft{ padding:10px 16px; border-top:1px solid var(--sv-bd); text-align:right; }
  .sv-pop table{ width:100%; border-collapse:collapse; font-size:13px; }
  .sv-pop th{ background:#eef3f2; border:1px solid var(--sv-bd); padding:6px 8px; }
  .sv-pop td{ border:1px solid var(--sv-bd); padding:6px 8px; text-align:center; }
  .sv-pop tr.pick{ cursor:pointer; }
  .sv-pop tr.pick:hover td{ background:#f3f8f6; }
  .sv-msg{ padding:10px; color:#5a6b7a; text-align:center; font-size:12.5px; }
  /* 원장 합계 — 스크롤 영역 밖에 고정 */
  .sv-lgfoot{ overflow:hidden; border:1px solid var(--sv-bd); border-top:0; border-radius:0 0 8px 8px; }
  .sv-lgfoot table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sv-lgfoot td{ border:1px solid var(--sv-bd); padding:7px 8px; text-align:right; background:#d9f0e0; font-weight:800; }
  .sv-lgfoot td:first-child{ text-align:center; }
</style>

<div class="sv-wrap">
  <h2>💸 지급등록</h2>
  <div class="sv-sub">매입처에 지급한 금액을 건 단위로 기록합니다. 우측 원장에 매입·지급·잔고가 함께 쌓입니다.</div>

  <%-- 좌우 2단 : 왼쪽에 입력+목록, 오른쪽 원장은 ★맨 위부터 시작한다(2026-07-25 요청).
       전에는 원장이 하단 목록과 같은 줄에서 시작해 화면 오른쪽 위가 비어 보였다.
       ★2026-08-01 : 좌우 비중을 수금등록과 같게 맞춘다(요청). 종전엔 원장이 470px 고정이라
         화면이 넓어져도 원장만 그대로였고 좌측만 늘어났다 → '좌측이 조금 더 넓은 반반' 비율로.
         좁은 화면에서는 wrap 으로 원장이 아래로 내려간다. --%>
  <div style="display:flex; gap:12px; align-items:flex-start; flex-wrap:wrap">
  <div style="flex:1.25 1 720px; min-width:0">

  <!-- ===== 입력 ===== -->
  <div class="sv-card">
    <table class="sv-form">
      <tr>
        <th>지급일자</th>
        <td>
          <input type="date" id="svDt" onchange="svNextNo()">
          <span class="sv-lbl">번호</span><input type="text" id="svNo" readonly style="width:70px">
          <span class="sv-lbl">구분</span>
          <select id="svPayGb"><option>무통장지급</option><option>현금</option><option>카드</option><option>계좌이체</option><option>어음</option></select>
          <span class="sv-lbl">지급계좌</span>
          <select id="svAcct" style="min-width:250px">
            <option value="">(선택 안 함)</option>
            <option>국민은행 / 699237-01-004560 / (주)코네트</option>
            <option>우리은행 / 1005-201-931176 / (주)코네트</option>
          </select>
        </td>
      </tr>
      <tr>
        <th>거래처</th>
        <td>
          <%-- 거래처 = 직접 입력검색(거래처명·코드·별칭·대표·담당 부분일치). 목록을 훑어보려면 [거래처] 버튼. --%>
          <input type="text" id="svCustNm" placeholder="매입처명 입력 또는 [거래처]" style="width:230px" title="거래처명·코드·별칭·대표자·담당자로 검색합니다. ↑↓ 로 고르고 Enter.">
          <button class="sv-btn teal" onclick="svCustOpen()">거래처</button>
          <span class="sv-lbl">담당자</span><input type="text" id="svMgrNm" readonly style="width:110px">
          <span class="sv-lbl">현잔고</span><span class="sv-bal" id="svBal">0</span>
          <%-- 남은 미지급을 그대로 새 지급 전표로 올린다(2026-08-01, 수금등록과 동일). 잔고가 있을 때만 보인다. --%>
          <button class="sv-btn teal" id="svBalBtn" style="display:none; margin-left:10px" onclick="svBalTake()"
                  title="이 거래처의 남은 미지급을 새 지급 전표로 올립니다. 금액·일자를 확인한 뒤 [저장]을 누르세요.">잔고 지급</button>
        </td>
      </tr>
      <tr>
        <th>금액</th>
        <td>
          <span class="sv-lbl" style="margin-left:0">지급액</span><input type="text" class="num" id="svAmt" value="0" style="width:150px" oninput="svCalc()">
          <span class="sv-lbl">할인액</span><input type="text" class="num" id="svDc" value="0" style="width:130px" oninput="svCalc()">
          <span class="sv-lbl">합계금액</span><input type="text" class="num" id="svTot" value="0" readonly style="width:150px">
        </td>
      </tr>
      <tr><th>메모</th><td><input type="text" id="svRemark" style="width:100%"></td></tr>
    </table>
    <%-- 작업 버튼은 입력 칸 아래 — 판매등록·매입등록과 같은 자리(2026-08-01 요청).
         종전에는 이 카드 맨 위에 있어 네 화면의 버튼 위치가 서로 달랐다. --%>
    <div style="display:flex; gap:6px; margin-top:10px">
      <button class="sv-btn teal" onclick="svNew()">＋ 지급등록</button>
      <button class="sv-btn" onclick="svSave()">💾 저장</button>
      <button class="sv-btn" onclick="svReload()">🔄 새로고침</button>
      <button class="sv-btn red" onclick="svDelete()">✖ 삭제하기</button>
      <span id="svState" style="margin-left:8px; align-self:center; color:#3d4d5c; font-size:12.5px"></span>
    </div>
  </div>

  <!-- ===== 목록 ===== -->
    <div class="sv-card">
      <%-- 검색줄은 한 줄로 붙인다(2026-07-25 요청) — flex-wrap:wrap 이면 창이 좁을 때 접혀
           [리스트조회] 만 아랫줄로 떨어져 보기 나쁘다. 넘치면 이 줄만 가로 스크롤한다. --%>
      <div style="display:flex; gap:6px; align-items:center; flex-wrap:nowrap; overflow-x:auto; margin-bottom:8px">
        <span style="font-weight:700; align-self:center">Total : <span id="svTotal">0</span></span>
        <span class="sv-lbl">검색기간</span>
        <input type="date" id="svFrom" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px">
        <span>~</span>
        <input type="date" id="svTo" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px">
        <span class="sv-lbl">구분</span>
        <select id="svFPayGb" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px">
          <option value="">전체</option><option>무통장지급</option><option>현금</option><option>카드</option><option>계좌이체</option><option>어음</option>
        </select>
        <span class="sv-lbl">거래처</span>
        <input type="text" id="svFind" placeholder="거래처명" style="height:32px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px; width:150px">
        <button class="sv-btn teal" onclick="svLoad()">리스트조회</button>
      </div>
      <div class="sv-list" id="svListWrap">
        <table>
          <%-- 행 클릭 = 그 '거래처'를 고른다(신규 전표 상태 유지). 지난 전표를 고치려면 [수정] 버튼.
               2026-08-01 사용자 확정 — 수금등록과 같은 규칙. --%>
          <thead><tr>
            <th style="width:56px">수정</th>
            <th style="width:150px">지급일자</th><th style="width:70px">번호</th><th>거래처명</th>
            <th style="width:90px">담당자</th><th style="width:100px">구분</th>
            <th style="width:120px">지급액</th><th style="width:100px">할인액</th>
            <th style="width:90px">등록자</th><th style="width:150px">비고</th>
          </tr></thead>
          <tbody id="svListBody"><tr><td colspan="10" class="sv-msg">[리스트조회]를 누르세요.</td></tr></tbody>
        </table>
      </div>
      <div id="svPager" style="padding:6px 2px; text-align:center; min-height:26px"></div>
      <div class="sv-sum">
        <div class="k">지급계</div><div class="v" id="sPay">0</div>
        <div class="k">할인계</div><div class="v" id="sDc">0</div>
      </div>
    </div>

    </div><!-- /좌측 열 -->

    <!-- 거래처 원장 — 우측 열, 화면 맨 위부터. 폭은 수금등록과 같은 비율(고정 470px 아님) -->
    <div class="sv-card" style="flex:1 1 620px; min-width:520px">
      <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
        <b>원장</b>
        <span style="margin-left:auto; font-size:11.5px; color:#5a6b7a">* 매출&amp;매입 거래처는 최종 잔고만 표시됩니다.</span>
      </div>
      <div style="border:1px solid var(--sv-bd); border-radius:6px; padding:6px 8px; margin-bottom:6px; font-size:13px">
        <b>거래처명</b> <span id="lgCust" style="margin-left:8px">—</span>
      </div>
      <%-- 원장 스크롤 : 머리글은 위에 고정(sticky), 합계는 스크롤 영역 밖에 두어 항상 보이게 한다.
           두 표의 열 너비는 같은 colgroup 으로 맞춘다(2026-07-25 요청). --%>
      <div class="sv-list" id="lgWrap" style="max-height:440px; border-radius:8px 8px 0 0">
        <table>
          <%-- 열 너비 = 비율(2026-08-01 요청, 수금등록과 동일). 종전에는 '매출'만 너비가 없어
                 남는 폭을 전부 먹어 혼자 두 배 넓고 나머지가 눌렸다. 짝을 이루는 열끼리 같은 폭 —
                 매출·매입 14% / 수금·지급 12% / DC·할인 9% / 잔고 16%(누계라 가장 큼) / 일자 14%. --%>
          <colgroup><col style="width:14%"><col style="width:14%"><col style="width:9%"><col style="width:12%"><col style="width:14%"><col style="width:12%"><col style="width:9%"><col style="width:16%"></colgroup>
          <thead><tr><th>일자</th><th>매출</th><th>DC</th><th>수금</th><th>매입</th><th>지급</th><th>할인</th><th>잔고</th></tr></thead>
          <tbody id="lgBody"><tr><td colspan="8" class="sv-msg">거래처를 선택하세요.</td></tr></tbody>
        </table>
      </div>
      <div class="sv-lgfoot" id="lgFootWrap">
        <table>
          <%-- 열 너비 = 비율(2026-08-01 요청, 수금등록과 동일). 종전에는 '매출'만 너비가 없어
                 남는 폭을 전부 먹어 혼자 두 배 넓고 나머지가 눌렸다. 짝을 이루는 열끼리 같은 폭 —
                 매출·매입 14% / 수금·지급 12% / DC·할인 9% / 잔고 16%(누계라 가장 큼) / 일자 14%. --%>
          <colgroup><col style="width:14%"><col style="width:14%"><col style="width:9%"><col style="width:12%"><col style="width:14%"><col style="width:12%"><col style="width:9%"><col style="width:16%"></colgroup>
          <tbody id="lgFoot"></tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="sv-pop" id="svCustPop">
  <div class="box">
    <div class="hd">거래처 선택
      <input type="text" id="svCustQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:30px; border:1px solid var(--sv-bd); border-radius:6px; padding:0 8px" oninput="svCustRender()">
    </div>
    <div class="bd"><table><thead><tr><th style="width:90px">코드</th><th>거래처명</th><th style="width:130px">별칭</th><th style="width:100px">대표자</th><th style="width:90px">담당사원</th></tr></thead>
      <tbody id="svCustBody"></tbody></table></div>
    <div class="ft"><button class="sv-btn" onclick="svCustClose()">닫기</button></div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var GB = 'PAY';            // 이 화면은 지급. 수금 화면은 'RCV' 만 다르다
var _list = [], _vendors = [], _cur = null, _curNet = 0, _balNow = 0;   // _balNow = 현잔고(미지급) — [잔고 지급]용

function n(v){ var x = Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x) ? x : 0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function fmtDt(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function post(url, body, isJson){
  return fetch(CTX+url, { method:'POST', credentials:'same-origin',
    headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded'},
    body: isJson ? JSON.stringify(body) : body });
}
/* 메시지 — 로그인 화면과 같은 공통 컴포넌트(asset/js/ui-message.js) */
function swOk(m){ if(window._alertBox) return _alertBox(m,{icon:'✅'}); alert(m); }
function swErr(m){ if(window._alertBox) return _alertBox(m,{icon:'❌',okColor:'red'}); alert(m); }
function swConfirm(m, okText){
  return new Promise(function(res){
    if(!window._confirmBox){ res(confirm(String(m).replace(/<br\s*\/?>/gi,'\n'))); return; }
    _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', onOk:function(){res(true);}, onCancel:function(){res(false);} });
  });
}

(function init(){
  document.getElementById('svDt').value = today();
  var d = new Date(); d.setMonth(d.getMonth()-2);
  document.getElementById('svFrom').value = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01';
  document.getElementById('svTo').value = today();
  post('/vendor/selectVendorMst.do','').then(function(r){return r.json();}).then(function(j){ _vendors=(j&&j.data)||[]; }).catch(function(){});
  svNew(); svLoad();
  /* 거래처 칸 입력검색 — 고르는 동작은 팝업과 같은 svCustPick() 을 그대로 탄다(잔고·원장·담당자 갱신 포함).
     _vendors 는 위 조회가 나중에 채우므로 배열이 아니라 '함수'로 넘긴다. */
  _vendorPick(document.getElementById('svCustNm'), {
    list   : function(){ return _vendors; },
    onPick : function(o){ svCustPick(o.vendorCd); },
    onClear: function(){ document.getElementById('svMgrNm').value=''; document.getElementById('svMgrNm').dataset.cd=''; svBal(''); svLedger(''); }
  });
})();

/* ── 입력 ── */
function svNew(){
  _cur = null; _curNet = 0;
  document.getElementById('svCustNm').value=''; document.getElementById('svCustNm').dataset.cd='';
  document.getElementById('svMgrNm').value=''; document.getElementById('svMgrNm').dataset.cd='';
  document.getElementById('svAmt').value='0'; document.getElementById('svDc').value='0';
  document.getElementById('svRemark').value='';
  _balNow = 0;
  document.getElementById('svBal').textContent='0';
  document.getElementById('svState').textContent='신규 전표';
  svCalc(); svNextNo(); svLedger(''); svBalBtnUpd();
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr){ tr.classList.remove('on'); });
}
function svNextNo(){
  var dt = document.getElementById('svDt').value;
  if (!dt || _cur) return;
  post('/mangr/settleNextNo.do','trxGb='+GB+'&trxDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){ document.getElementById('svNo').value=(j&&j.data)||'0001'; })
    .catch(function(){ document.getElementById('svNo').value='0001'; });
}
function svCalc(){
  var a = n(document.getElementById('svAmt').value), d = n(document.getElementById('svDc').value);
  document.getElementById('svTot').value = fmt(a + d);
}
/* 저장 뒤 화면 — 거래처와 원장은 그대로 두고 입력만 비운다 (2026-08-01, 수금등록과 동일).
   종전에는 svNew() 가 거래처까지 지워서, 방금 넣은 지급이 잔고·원장에 어떻게 반영됐는지
   보려면 목록에서 그 전표를 다시 눌러야 했고 그러면 '수정 중' 으로 들어가 버렸다. */
function svNewKeep(){
  var c = document.getElementById('svCustNm'), cd = c.dataset.cd || '';
  if(!cd){ svNew(); return; }
  _cur = null; _curNet = 0;
  document.getElementById('svAmt').value='0'; document.getElementById('svDc').value='0';
  document.getElementById('svRemark').value='';
  document.getElementById('svState').textContent='신규 전표 — '+c.value;
  svCalc(); svNextNo();
  svBal(cd); svLedger(cd);          // 방금 저장분이 반영된 잔고·원장을 다시 읽는다
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr){ tr.classList.remove('on'); });
}
function svSave(){
  var cd = document.getElementById('svCustNm').dataset.cd||'';
  if (!cd) { swErr('거래처를 선택하세요.'); return; }
  var a = n(document.getElementById('svAmt').value), d = n(document.getElementById('svDc').value);
  if (a === 0 && d === 0) { swErr('지급액이나 할인액을 입력하세요.'); return; }
  var dto = {
    trxSeq: _cur ? _cur.trxSeq : null, trxGb: GB,
    trxDt: document.getElementById('svDt').value, trxNo: document.getElementById('svNo').value,
    payGb: document.getElementById('svPayGb').value,
    acctNm: document.getElementById('svAcct').value, acctCd: '',
    custCd: cd, custNm: document.getElementById('svCustNm').value,
    mgrCd: document.getElementById('svMgrNm').dataset.cd||'', mgrNm: document.getElementById('svMgrNm').value,
    amt: a, dcAmt: d, saleDcAmt: 0, totAmt: a + d,
    remark: document.getElementById('svRemark').value
  };
  /* ★ 목록에서 지난 전표를 누르면 화면이 '수정 중' 이 된다 — 그 상태로 저장하면
       새 지급이 아니라 그 전표를 덮어쓴다. 눈에 잘 안 띄는 차이라 저장 전에 한 번 묻는다. */
  var ask = _cur
    ? swConfirm('지난 전표를 <b>수정</b>합니다 — '+fmtDt(_cur.trxDt)+' / '+_cur.trxNo
              + '<br><span style="font-size:13px;color:#3d4d5c">새 지급이 아니라 이 전표를 덮어씁니다.</span>', '수정')
    : Promise.resolve(true);
  ask.then(function(ok){
    if(!ok) return;
    var edit = !!_cur;
    post('/mangr/settleSave.do', dto, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(){
        /* 무엇이 저장됐는지 분명히 — '저장했습니다' 만으로는 신규인지 수정인지 알 수 없다 */
        swOk(edit ? ('전표를 수정했습니다 — '+dto.trxDt+' / '+dto.trxNo)
                  : ('새 지급 전표로 저장했습니다 — '+dto.trxDt+' / '+dto.trxNo));
        svNewKeep(); svLoad();
      })
      .catch(function(e){ swErr('저장에 실패했습니다.<br><span style="font-size:13px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
  });
}
function svDelete(){
  /* 행 클릭은 '거래처 선택'이라 _cur 가 안 잡힌다 — 삭제할 전표는 [수정] 으로 불러와야 한다 */
  if (!_cur) { swErr('삭제할 전표를 먼저 불러오세요.<br><span style="font-size:13px;color:#3d4d5c">아래 목록에서 그 줄의 [수정] 버튼을 누르세요.</span>'); return; }
  swConfirm('이 지급 전표를 삭제할까요?', '삭제').then(function(ok){
    if(!ok) return;
    post('/mangr/settleDelete.do', { trxSeq:_cur.trxSeq }, true)
      .then(function(r){ if(!r.ok) return r.text().then(function(t){ throw new Error(t); }); swOk('삭제했습니다.'); svNewKeep(); svLoad(); })
      .catch(function(e){ swErr('삭제에 실패했습니다.<br><span style="font-size:13px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
  });
}
function svReload(){ svLoad(); var cd=document.getElementById('svCustNm').dataset.cd||''; if(cd){ svBal(cd); } }

/* ── 목록 (5행 고정 + 자동 스크롤) ── */
var LIST_ROWS = 5, _lShown = 0, _lBound = false;
function svLoad(){
  var b = 'trxGb='+GB
        + '&fromDt='+encodeURIComponent(document.getElementById('svFrom').value)
        + '&toDt='+encodeURIComponent(document.getElementById('svTo').value)
        + '&payGb='+encodeURIComponent(document.getElementById('svFPayGb').value)
        + '&findData='+encodeURIComponent(document.getElementById('svFind').value);
  document.getElementById('svListBody').innerHTML='<tr><td colspan="10" class="sv-msg">조회 중…</td></tr>';
  post('/mangr/settleList.do', b).then(function(r){return r.json();}).then(function(j){
    _list=(j&&j.data)||[]; svListRender();
  }).catch(function(e){ document.getElementById('svListBody').innerHTML='<tr><td colspan="10" class="sv-msg" style="color:#c0392b">조회 오류</td></tr>'; });
}
function svRowHtml(o,i){
  return '<tr onclick="svPickCust('+i+')" title="클릭 → 이 거래처를 골라 새 지급 전표로">'
    + '<td><button class="sv-btn" style="height:24px;padding:0 8px;font-size:12px" title="이 전표를 불러와 고칩니다"'
    +   ' onclick="event.stopPropagation();svEdit('+i+')">수정</button></td>'
    + '<td>'+esc(fmtDt(o.trxDt))+' '+esc(String(o.regDttm||'').slice(11,16))+'</td>'
    + '<td>'+esc(o.trxNo)+'</td><td style="text-align:left">'+esc(o.custNm)+'</td><td>'+esc(o.mgrNm)+'</td>'
    + '<td>'+esc(o.payGb)+'</td><td class="num">'+fmt(o.amt)+'</td><td class="num">'+fmt(o.dcAmt)+'</td>'
    + '<td>'+esc(o.regUser)+'</td><td style="text-align:left">'+esc(o.remark)+'</td></tr>';
}
function svListRender(){
  document.getElementById('svTotal').textContent = _list.length;
  var tb = document.getElementById('svListBody');
  if(!_list.length){ tb.innerHTML='<tr><td colspan="10" class="sv-msg">전표가 없습니다.</td></tr>'; _lShown=0; svPager(); svSum(); return; }
  _lShown = Math.min(LIST_ROWS, _list.length);
  tb.innerHTML = _list.slice(0,_lShown).map(function(o,i){ return svRowHtml(o,i); }).join('');
  svBind(); svPager(); svSum();
}
function svMore(cnt){
  if(_lShown >= _list.length) return;
  var to = Math.min(_lShown + (cnt||LIST_ROWS), _list.length), h='';
  for(var i=_lShown;i<to;i++) h += svRowHtml(_list[i], i);
  document.getElementById('svListBody').insertAdjacentHTML('beforeend', h);
  _lShown = to; svPager();
}
function svBind(){
  var w = document.getElementById('svListWrap'); if(!w||_lBound) return; _lBound=true;
  w.addEventListener('scroll', function(){
    if(_lShown >= _list.length) return;
    if(w.scrollTop + w.clientHeight >= w.scrollHeight - 30) svMore();
  });
}
function svPager(){
  var el = document.getElementById('svPager');
  if(_lShown >= _list.length){
    el.innerHTML = _list.length > LIST_ROWS ? '<span style="color:#5a6b7a;font-size:12.5px">총 '+_list.length+'건 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a;font-size:12.5px">'+_lShown+' / <b>'+_list.length+'</b>건'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="sv-btn" style="height:24px;margin-left:8px;font-size:12px" onclick="svMore('+_list.length+')">모두 표시</button>';
}
function svSum(){
  var p=0,d=0; _list.forEach(function(o){ p+=n(o.amt); d+=n(o.dcAmt); });
  document.getElementById('sPay').textContent=fmt(p);
  document.getElementById('sDc').textContent=fmt(d);
}
/* 목록 행 클릭 = '이 거래처를 고른다' (2026-08-01 사용자 확정, 수금등록과 같은 규칙).
   거래처·담당자만 가져오고 화면은 신규 전표 상태를 지킨다 — 지급일자는 오늘, 금액은 0.
   우측 원장·현잔고가 그 거래처로 바뀌므로, 잔고가 있으면 [잔고 지급] 으로 바로 이어진다.
   ★지난 전표를 고치는 것은 행 안의 [수정] 버튼(svEdit) 으로만 — 실수로 덮어쓰지 않게 갈라 놓았다. */
function svPickCust(i){
  var o=_list[i]; if(!o) return;
  _cur = null; _curNet = 0;
  var c=document.getElementById('svCustNm'); c.value=o.custNm||''; c.dataset.cd=o.custCd||'';
  var m=document.getElementById('svMgrNm'); m.value=o.mgrNm||''; m.dataset.cd=o.mgrCd||'';
  document.getElementById('svDt').value = today();
  document.getElementById('svAmt').value='0'; document.getElementById('svDc').value='0';
  document.getElementById('svRemark').value='';
  document.getElementById('svState').textContent='신규 전표 — '+(o.custNm||'');
  svCalc(); svNextNo(); svBal(o.custCd); svLedger(o.custCd);
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr,k){ tr.classList.toggle('on', k===i); });
}
/* 지난 전표 수정 — 종전의 행 클릭 동작. 이제는 [수정] 버튼으로만 들어온다. */
function svEdit(i){
  var o=_list[i]; if(!o) return;
  _cur = o; _curNet = n(o.amt) + n(o.dcAmt);
  document.getElementById('svDt').value = fmtDt(o.trxDt);
  document.getElementById('svNo').value = o.trxNo;
  document.getElementById('svPayGb').value = o.payGb||'무통장지급';
  document.getElementById('svAcct').value = o.acctNm||'';
  var c=document.getElementById('svCustNm'); c.value=o.custNm||''; c.dataset.cd=o.custCd||'';
  var m=document.getElementById('svMgrNm'); m.value=o.mgrNm||''; m.dataset.cd=o.mgrCd||'';
  document.getElementById('svAmt').value = n(o.amt);
  document.getElementById('svDc').value = n(o.dcAmt);
  document.getElementById('svRemark').value = o.remark||'';
  document.getElementById('svState').textContent = '수정 중 — '+fmtDt(o.trxDt)+' / '+o.trxNo;
  svCalc(); svBal(o.custCd); svLedger(o.custCd);
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr,k){ tr.classList.toggle('on', k===i); });
}

/* ── 거래처 ── */
function svCustOpen(){ document.getElementById('svCustPop').classList.add('on'); document.getElementById('svCustQ').value=''; svCustRender(); }
function svCustClose(){ document.getElementById('svCustPop').classList.remove('on'); }
function svCustRender(){
  var q=(document.getElementById('svCustQ').value||'').toLowerCase();
  var l=_vendors.filter(function(o){ if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; }); }).slice(0,200);
  document.getElementById('svCustBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="svCustPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td>'
         + '<td style="text-align:left">'+esc(o.vendorNm)+'</td><td>'+esc(o.alias)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="5" class="sv-msg">검색 결과가 없습니다.</td></tr>';
}
function svCustPick(cd){
  var o=_vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0]; if(!o) return;
  var c=document.getElementById('svCustNm'); c.value=o.vendorNm||''; c.dataset.cd=o.vendorCd||'';
  var m=document.getElementById('svMgrNm'); m.value=o.mgrNm||''; m.dataset.cd=o.mgrCd||'';
  svCustClose(); svBal(o.vendorCd); svLedger(o.vendorCd);
}
/* 현잔고 = 매입 − 지급 − 할인 누계 (미지급 잔액) */
function svBal(cd){
  if(!cd){ _balNow=0; document.getElementById('svBal').textContent='0'; svBalBtnUpd(); return; }
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l=(j&&j.data)||[], bal=0;
    l.forEach(function(o){ bal += n(o.purchAmt) - n(o.payAmt) - n(o.discAmt); });
    _balNow = bal;
    document.getElementById('svBal').textContent = fmt(bal);
    svBalBtnUpd();
  }).catch(function(){});
}

/* ── 잔고 지급 (2026-08-01 요청, 수금등록의 [잔고 수금]과 같은 동작) ──
     줄 돈이 남아 있으면 그 금액을 그대로 지급하는 것이 보통이다. 종전에는
     [지급등록] → 거래처를 다시 찾기 → 금액 입력 순서라 손이 많이 갔다.
     ★저장까지 하지는 않는다 — 금액·일자·구분을 확인하고 [저장]을 누르는 것은 사용자 몫. */
function svBalBtnUpd(){
  var b = document.getElementById('svBalBtn'); if(!b) return;
  var cd = document.getElementById('svCustNm').dataset.cd || '';
  var on = !!cd && _balNow > 0;                    // 선지급(음수)·0 이면 숨긴다
  b.style.display = on ? '' : 'none';
  b.textContent = on ? ('잔고 지급 ' + fmt(_balNow)) : '잔고 지급';
}
function svBalTake(){
  var c = document.getElementById('svCustNm'), cd = c.dataset.cd || '';
  if(!cd){ swErr('거래처를 먼저 선택하세요.'); return; }
  if(!(_balNow > 0)){ swErr('남은 미지급 잔고가 없습니다.'); return; }
  var bal = _balNow;
  /* 거래처·담당자는 그대로 두고 '새 전표'로 바꾼다 — 목록에서 고른 지난 전표를
     고치는 것이 아니다. _cur 을 먼저 비워야 svNextNo() 가 새 번호를 받아 온다. */
  _cur = null; _curNet = 0;
  document.getElementById('svDt').value = today();
  document.getElementById('svAmt').value = bal;
  document.getElementById('svDc').value = '0';
  document.getElementById('svRemark').value = '';
  document.getElementById('svState').textContent = '잔고 지급 — ' + fmt(bal) + ' 원 · 내용 확인 후 [저장]';
  Array.prototype.forEach.call(document.querySelectorAll('#svListBody tr'), function(tr){ tr.classList.remove('on'); });
  svNextNo(); svCalc();
  var a = document.getElementById('svAmt'); a.focus(); a.select();   // 일부만 주는 경우 바로 고칠 수 있게
}

/* ── 원장 ── */
/* 합계 줄 열 맞춤 — 원장이 길어져 세로 스크롤바가 생기면 스크롤 영역 안의 표만 그만큼 좁아진다.
   합계(.sv-lgfoot)는 스크롤 영역 '밖'이라 그대로 두면 열이 스크롤바 폭만큼 어긋난다.
   열 너비가 비율(%)이라 어긋남이 전 열에 퍼지므로 반드시 맞춰 준다. 수금등록과 같은 처리. */
function lgFootPad(){
  var w = document.getElementById('lgWrap'), f = document.getElementById('lgFootWrap');
  if(!w || !f) return;
  f.style.paddingRight = Math.max(0, w.offsetWidth - w.clientWidth) + 'px';
}
window.addEventListener('resize', lgFootPad);

function svLedger(cd){
  var tb=document.getElementById('lgBody');
  document.getElementById('lgCust').textContent = cd ? (document.getElementById('svCustNm').value||cd) : '—';
  if(!cd){ tb.innerHTML='<tr><td colspan="8" class="sv-msg">거래처를 선택하세요.</td></tr>'; document.getElementById('lgFoot').innerHTML=''; return; }
  tb.innerHTML='<tr><td colspan="8" class="sv-msg">불러오는 중…</td></tr>';
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l=(j&&j.data)||[];
    if(!l.length){ tb.innerHTML='<tr><td colspan="8" class="sv-msg">거래 내역이 없습니다.</td></tr>'; return; }
    var h='', bal=0, mm=null, m=z(), t=z();
    function z(){ return {s:0,d:0,r:0,p:0,y:0,c:0}; }
    function monthRow(){
      if(mm===null) return '';
      return '<tr style="background:#e8f6ec"><td>[월 계]</td><td class="num">'+fmt(m.s)+'</td><td class="num">'+fmt(m.d)
           + '</td><td class="num">'+fmt(m.r)+'</td><td class="num">'+fmt(m.p)+'</td><td class="num">'+fmt(m.y)
           + '</td><td class="num">'+fmt(m.c)+'</td><td></td></tr>';
    }
    l.forEach(function(o){
      var dt=String(o.dt||''), ym=dt.slice(0,6);
      var s=n(o.saleAmt), d=n(o.dcAmt), r=n(o.rcvAmt), p=n(o.purchAmt), y=n(o.payAmt), c=n(o.discAmt);
      if(mm!==null && ym!==mm){ h+=monthRow(); m=z(); }
      mm=ym;
      bal += p - y - c;                        // 매입처 잔고 = 매입 − 지급 − 할인
      m.s+=s;m.d+=d;m.r+=r;m.p+=p;m.y+=y;m.c+=c;
      t.s+=s;t.d+=d;t.r+=r;t.p+=p;t.y+=y;t.c+=c;
      h += '<tr><td>'+esc(fmtDt(dt))+'</td><td class="num">'+fmt(s)+'</td><td class="num">'+fmt(d)+'</td><td class="num">'+fmt(r)
         + '</td><td class="num">'+fmt(p)+'</td><td class="num">'+fmt(y)+'</td><td class="num">'+fmt(c)
         + '</td><td class="num"><b>'+fmt(bal)+'</b></td></tr>';
    });
    h += monthRow();
    tb.innerHTML = h;
    /* 합계는 스크롤 영역 밖에 — 아무리 내려도 항상 보인다 */
    document.getElementById('lgFoot').innerHTML =
      '<tr><td>합 계</td><td>'+fmt(t.s)+'</td><td>'+fmt(t.d)+'</td><td>'+fmt(t.r)+'</td><td>'+fmt(t.p)
      + '</td><td>'+fmt(t.y)+'</td><td>'+fmt(t.c)+'</td><td>'+fmt(bal)+'</td></tr>';
    lgFootPad();
  }).catch(function(){ tb.innerHTML='<tr><td colspan="8" class="sv-msg" style="color:#c0392b">원장 조회 오류</td></tr>'; });
}
</script>
