<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<!--
  거래처별 채권·채무 (2026-07-26 요청 신설)
    · 메뉴 이름은 "거래처별 채권·채무"(사용자 유지 요청), 화면 표기는 쉬운 말로 — 받을금액 / 지급할금액 / 이월 / 남은금액.
      한번 회계용어(매출채권·미수금 …)로 바꿨다가 "너무 딱딱하다"는 지적으로 되돌렸다. 다시 바꾸자는 얘기가 나오면 이 이력을 먼저 확인할 것.
    · 왼쪽 = 거래처별 남은금액 한 줄씩 / 오른쪽 = 그 거래처의 월별 이력(최근부터)
    · 원천은 수금등록·지급등록 화면의 원장(selectCustLedger)과 같다. 다만 '한 거래처 × 일자'가 아니라
      '전 거래처 × 월' 로 넓혀 한 번에 받는다(selectCustBalance).

    ★잔액은 '전 기간 누계'다 — 기초잔액 테이블이 없고 전표가 곧 원장이라 그렇다.
      그래서 조회에 기간을 걸지 않는다. 대신 [기준월]까지만 누적해 '그 달 말 시점 잔액'을 만든다.
      기간(from~to)을 걸면 그 사이 증감만 남아 잔액이 아니게 된다 — 이 화면에서 가장 위험한 오해라
      화면에도 도움말에도 같은 말을 적어 둔다.

    ★받을금액이 0으로 보이는 거래처가 많은 게 정상이다.
      정산서(TBL_SALES_MST)에는 거래처코드가 없어 거래처마스터의 DC_CD(출고장코드)로만 이어진다.
      DC_CD 가 있는 거래처는 삼성웰스토리 지점 7곳뿐이고 나머지는 매입처라 매출이 없다.
-->
<style>
  :root{ --cb-bd:#dbe2ea; --cb-teal:#137a6c; --cb-red:#c0392b; }
  *{ box-sizing:border-box; }
  .cb-wrap{ padding:14px 16px; font-family:'맑은 고딕',Malgun Gothic,sans-serif; font-size:14px; color:#1f2a37; }
  .cb-wrap h2{ margin:0 0 3px; font-size:19px; }
  .cb-sub{ color:#1f2a37; margin-bottom:10px; font-size:12.5px; font-weight:600; }
  .cb-card{ background:#fff; border:1px solid var(--cb-bd); border-radius:10px; padding:11px 13px; margin-bottom:11px; }
  .cb-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; }
  .cb-fld{ display:flex; flex-direction:column; gap:3px; }
  .cb-fld label{ font-size:12px; font-weight:700; color:#1f2a37; }
  .cb-fld input, .cb-fld select{ height:32px; border:1px solid var(--cb-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .cb-btn{ height:32px; border:1px solid var(--cb-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .cb-btn:hover{ border-color:var(--cb-teal); }
  .cb-btn.teal{ background:var(--cb-teal); color:#fff; border-color:var(--cb-teal); }
  /* 체크박스도 버튼과 같은 높이·같은 바닥선에 세운다 — align-self:center 로 두면 혼자 떠 보인다(2026-07-26) */
  .cb-chk{ display:inline-flex; align-items:center; gap:6px; align-self:flex-end;
           height:32px; padding:0 10px; border:1px solid var(--cb-bd); border-radius:7px; background:#fff;
           font-size:13px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
  .cb-chk input{ margin:0; }
  .kpi{ display:flex; gap:10px; flex-wrap:wrap; margin:10px 0 0; }
  .kpi div{ flex:1 1 170px; border:1px solid var(--cb-bd); border-radius:8px; padding:8px 12px; background:#fbfdfc; }
  .kpi b{ display:block; font-size:19px; color:var(--cb-teal); margin-top:2px; white-space:nowrap; }
  .kpi b.red{ color:var(--cb-red); }
  .kpi span{ font-size:12px; color:#1f2a37; font-weight:700; }
  .cb-two{ display:flex; gap:11px; align-items:flex-start; flex-wrap:wrap; }
  .cb-two > .l{ flex:2 1 520px; min-width:0; }
  .cb-two > .r{ flex:1 1 420px; min-width:0; }
  .cb-tit{ display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:7px; font-weight:800; }
  .cb-tit small{ font-weight:600; color:#2b3a48; font-size:12px; }
  .cb-tbwrap{ max-height:calc(100vh - 330px); min-height:220px; overflow:auto; border:1px solid var(--cb-bd); border-radius:8px; }
  table.cb-tb{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  table.cb-tb th{ background:#eef3f2; border:1px solid var(--cb-bd); padding:6px 8px; position:sticky; top:0; z-index:2; }
  /* ★머리글이 2줄이라 둘째 줄과 합계줄의 sticky 위치를 손으로 내려 준다(안 하면 겹쳐서 가린다) */
  table.cb-tb thead tr:nth-child(2) th{ top:28px; }
  table.cb-tb th.grp{ background:#e3edea; }
  table.cb-tb th.sortable{ cursor:pointer; }
  table.cb-tb th.sortable:hover{ color:var(--cb-teal); }
  table.cb-tb td{ border:1px solid var(--cb-bd); padding:6px 8px; text-align:right; }
  table.cb-tb td.txt{ text-align:left; }
  table.cb-tb td.ctr{ text-align:center; }
  table.cb-tb tr.tot td{ background:var(--cb-teal); color:#fff; font-weight:800; position:sticky; top:56px; z-index:1; }
  table.cb-tb tbody tr.pick{ cursor:pointer; }
  table.cb-tb tbody tr.pick:hover td{ background:#f3f8f6; }
  table.cb-tb tbody tr.on td{ background:#fdeef0; font-weight:700; }
  table.cb-tb tr.mtot td{ background:#eef3f2; font-weight:800; }
  /* 출고장 묶음 머리행 — 대시보드와 같은 2단 트리 */
  table.cb-tb tr.grow td{ background:#e9f1ef; font-weight:800; border-top:2px solid #cfe0db; }
  table.cb-tb tr.grow td .cnt{ font-size:11px; font-weight:600; color:#5a6b7a; }
  /* 접기 버튼 — 머리행 전체가 아니라 이 화살표만 눌린다(2026-07-26 요청) */
  table.cb-tb tr.grow td .tg{ display:inline-block; width:18px; text-align:center; cursor:pointer;
                              border-radius:4px; color:#37475a; user-select:none; }
  table.cb-tb tr.grow td .tg:hover{ background:#cfe0db; color:#0f5f54; }
  table.cb-tb td.ind{ padding-left:22px; }
  .amt-r{ color:var(--cb-teal); font-weight:700; }   /* 받을금액 */
  .amt-p{ color:var(--cb-red);  font-weight:700; }   /* 지급할금액 */
  .gb{ font-size:11px; padding:1px 6px; border-radius:9px; background:#eef3f2; color:#37475a; font-weight:700; }
  .cb-msg{ padding:24px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  .cb-note{ font-size:12.5px; color:#1f2a37; line-height:1.75; font-weight:600; }
  .cb-note b{ color:#37475a; }
</style>

<div class="cb-wrap">
  <h2>💳 거래처별 채권·채무 <span style="font-size:13px; font-weight:600; color:#5a6b7a">— 받을금액 · 지급할금액</span></h2>
  <div class="cb-sub">거래처별 <b>받을금액</b>과 <b>지급할금액</b>입니다 — <b>이월 + 당월 − 당월수금 = 남은금액</b>. 줄을 누르면 오른쪽에 <b>월별 이력</b>이 펼쳐집니다.</div>

  <div class="cb-card">
    <div class="cb-row">
      <div class="cb-fld" style="flex:0 0 150px"><label>기준월 (이 달 말 기준 잔액)</label><input type="month" id="cbYm"></div>
      <div class="cb-fld" style="flex:0 0 170px"><label>보기</label>
        <select id="cbFilter" onchange="cbRender()">
          <option value="bal">잔액 있는 거래처만</option>
          <option value="recv">받을금액 있는 곳만</option>
          <option value="pay">지급할금액 있는 곳만</option>
          <option value="all">전체(거래 있는 곳)</option>
        </select>
      </div>
      <div class="cb-fld" style="flex:0 0 200px"><label>거래처 검색(코드·이름)</label>
        <input type="text" id="cbFind" placeholder="예: 대양 / 00272" onkeyup="if(event.keyCode===13) cbRender()">
      </div>
      <button class="cb-btn teal" onclick="cbLoad()">조회</button>
      <button class="cb-btn" onclick="cbThisMonth()">이번 달</button>
      <%-- 출고장 묶음(대시보드와 같은 규칙) — 기본 켬. 끄면 거래처만 평평하게 나온다 --%>
      <label class="cb-chk"><input type="checkbox" id="cbGroup" checked onchange="cbRender()"> 출고장 묶음</label>
      <button class="cb-btn" onclick="cbToggleAll()" title="묶음 전체 접기/펼치기">⊟ 접기</button>
      <button class="cb-btn" onclick="cbHelp()" id="cbHelpBtn" style="margin-left:auto">ℹ️ 도움말</button>
    </div>
    <div class="kpi">
      <div><span>받을금액 합계</span><b id="kRecv">—</b></div>
      <div><span>지급할금액 합계</span><b id="kPay" class="red">—</b></div>
      <div><span>순액 (받을−지급)</span><b id="kNet">—</b></div>
      <div><span>받을 거래처</span><b id="kRecvCnt">—</b></div>
      <div><span>지급 거래처</span><b id="kPayCnt">—</b></div>
      <div><span>자료 있는 달</span><b id="kRange" style="font-size:15px; padding-top:3px">조회 전</b></div>
    </div>
  </div>

  <%-- 도움말 — 기본 접힘(다른 화면과 같은 방식) --%>
  <div class="cb-card" id="cbHelpBox" style="display:none; border-color:#9fcfc5; background:#f6fbfa">
    <div class="cb-tit"><span>ℹ️ 이 화면 보는 법</span><button class="cb-btn" onclick="cbHelp(false)">닫기 ✕</button></div>
    <div class="cb-note">
      <b style="color:#137a6c">■ 금액이 어떻게 나오나</b><br>
      <b>받을금액</b> = (매출액 − 매출할인) − 수금액 &nbsp;/&nbsp; <b>지급할금액</b> = (매입액 − 매입할인) − 지급액<br>
      &nbsp;&nbsp;· <b>매출액</b> = 출고장 정산서 + 판매등록 전표 &nbsp;· <b>수금액</b> = 수금등록 전표(+판매전표의 즉시수금)<br>
      &nbsp;&nbsp;· <b>매입액</b> = 매입등록 전표 &nbsp;· <b>지급액</b> = 지급등록 전표(+매입전표의 즉시지급)<br>
      &nbsp;&nbsp;· <b>순액</b> = 받을금액 − 지급할금액 (상계 처리는 하지 않고 참고로만 보여줍니다)<br>
      수금등록·지급등록 화면의 <b>거래처 원장과 같은 원천</b>이라 두 화면 숫자가 맞습니다.<br>
      <span style="color:#b45309"><b>★매출 그래프·마감현황보다 매출이 작게 나옵니다 — 의도된 차이입니다.</b></span>
      그 화면들은 <b>정산서가 아직 안 온 출고분(추정)</b>까지 매출로 잡지만,
      여기 받을금액은 <b>청구가 확정된 것만</b>(정산서 + 직접 판 전표) 셉니다. 아직 청구서가 없는 건은 받을 돈으로 세지 않습니다.<br><br>

      <b style="color:#137a6c">■ 기준월 · 이월 · 당월</b><br>
      <b style="color:#137a6c">이월 + 당월매출 − 당월수금 = 남은금액</b> (지급 쪽도 같은 구조: 이월 + 당월매입 − 당월지급 = 남은금액)<br>
      &nbsp;&nbsp;· <b>이월</b> — 기준월 <b>앞달 말</b>의 잔액. 여러 달 밀린 못 받은·못 준 돈이 전부 여기 쌓입니다.<br>
      &nbsp;&nbsp;· <b>당월</b> — 기준월 <b>그 달에만</b> 생긴 매출·수금(매입·지급).<br>
      &nbsp;&nbsp;· <b>남은금액</b> — 처음부터 그 달 말까지 쌓인 금액 = 지금 실제로 받을(줄) 돈.<br>
      기준월을 과거로 옮기면 <b>그 시점</b> 기준으로 이월·당월·잔액이 다시 계산됩니다. 기본값은 이번 달.<br>
      <span style="color:#b45309">이 화면에 '기간(부터~까지)'이 없는 이유 — 기간으로 자르면 그 사이 증감만 남아 잔액이 아니게 됩니다.</span><br><br>

      <b style="color:#137a6c">■ 출고장 묶음</b><br>
      물류센터 거래처(삼성웰스토리 지점)는 <b>대시보드·매출마감과 같은 규칙</b>으로 묶입니다 —
      <b>오산센터</b>(왜관·김해·광주·제주·오산), <b>용인</b>, <b>평택</b>은 각각 따로. 그 밖의 거래처는 <b>기타 거래처</b>로 모입니다.
      묶음 줄을 누르면 접히고, <b>⊟ 접기</b>로 전체를 한 번에 여닫습니다. 묶음 없이 보려면 <b>출고장 묶음</b> 체크를 끄면 됩니다.<br><br>

      <b style="color:#137a6c">■ 오른쪽 월별 이력</b><br>
      왼쪽에서 거래처 줄을 누르면 그 거래처의 <b>달마다 이월 · 매출 · 수금 · 남은금액</b>이 나옵니다(최근 달부터).
      각 줄도 <b>이월 + 매출 − 수금 = 남은금액</b>이 그대로 맞고, 그 달 남은금액이 다음 달 이월이 됩니다.
      맨 위 <b>누계</b> 줄은 기준월까지의 발생 합계입니다.<br><br>

      <b style="color:#b45309">■ 읽을 때 주의</b><br>
      &nbsp;&nbsp;· <b>받을금액이 0인 거래처가 대부분인 것은 정상</b>입니다. 정산서에는 거래처코드가 없어
      거래처마스터의 <b>출고장코드(DC_CD)</b>로만 매출이 이어지는데, 그 코드가 있는 곳은 <b>삼성웰스토리 지점 7곳</b>뿐입니다.
      나머지는 매입처라 매출이 없습니다.<br>
      &nbsp;&nbsp;· <b>매입·매출을 같이 하는 거래처</b>는 한 줄에 양쪽 금액이 다 뜹니다. <b>상계(서로 빼기)는 하지 않고</b> 순액 칸으로만 보여줍니다.<br>
      &nbsp;&nbsp;· 여기서 <b>수정은 안 됩니다</b>. 금액을 바꾸려면 판매·매입·수금·지급 <b>등록 화면에서 전표를 고쳐야</b> 합니다.<br>
      &nbsp;&nbsp;· 사업장(거래처관리(사업장), TBL_BIZI_MST)과는 <b>다른 모집단</b>입니다. 여기 나오는 건 회계 거래처입니다.
    </div>
  </div>

  <div class="cb-two">
    <div class="l">
      <div class="cb-card">
        <div class="cb-tit"><span>🏢 거래처별 잔액 <small id="cbListSub">기준월 말 기준</small></span>
          <span style="font-size:12px; font-weight:600; color:#5a6b7a">머리글을 누르면 정렬</span></div>
        <div class="cb-tbwrap"><table class="cb-tb" id="cbList"></table></div>
      </div>
    </div>
    <div class="r">
      <div class="cb-card">
        <div class="cb-tit"><span>📅 월별 이력 <small id="cbHistSub">거래처를 고르세요</small></span></div>
        <div class="cb-tbwrap"><table class="cb-tb" id="cbHist"></table></div>
      </div>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var _rows = [];        // 서버 원본 (거래처 × 월)
var _list = [];        // 화면용 거래처별 집계
var _pick = null;      // 선택한 거래처코드
var _sort = { key:'recv', desc:true };
var _col  = {};        // 접힌 묶음 { 묶음이름: true }

/* ★출고장 묶음 — 대시보드1·매출마감과 같은 규칙(2026-07-26 요청).
     오산센터 = 왜관·김해·광주·제주·오산 / 용인·평택은 단독.
     거래처마스터의 DC_CD 가 출고장코드라 그걸로 묶는다(삼성웰스토리 지점 7곳).
     DC_CD 가 없는 거래처(매입처 등)는 '기타 거래처'로 모은다. */
var CB_DC       = { E100:'용인', E200:'왜관', E300:'김해', E400:'광주', E500:'평택', E600:'제주', E700:'오산' };
var CB_DCGROUP  = { E200:'오산센터', E300:'오산센터', E400:'오산센터', E600:'오산센터', E700:'오산센터' };
var CB_ETC      = '기타 거래처';
/* 출고장코드 판정 — ①거래처마스터 DC_CD 우선 ②없으면 거래처명으로 환원.
   ★②가 필요한 이유 : DC_CD 는 나중에 추가한 컬럼이라 WAR 재빌드 전에는 응답에 없고,
     마스터에 DC_CD 를 안 넣은 지점이 생겨도 이름으로는 잡힌다.
   ★오탐 방지 : '웰스토리' 가 들어간 거래처만 이름으로 본다.
     그냥 지역명만 보면 '광주○○상사' 같은 매입처가 광주 출고장으로 끌려온다. */
function cbDcCdOf(o){
  var cd=(''+(o.dcCd||'')).trim().toUpperCase();
  if(cd) return cd;
  var nm=(''+(o.custNm||'')).replace(/\s+/g,'');
  if(nm.indexOf('웰스토리') < 0) return '';
  for(var c in CB_DC){ if(nm.indexOf(CB_DC[c]) >= 0) return c; }
  return '';
}
function cbGrpOf(o){
  var cd=cbDcCdOf(o);
  if(!cd) return CB_ETC;
  return CB_DCGROUP[cd] || (CB_DC[cd] || CB_ETC);
}
function cbDcNm(o){ return CB_DC[cbDcCdOf(o)] || ''; }

function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ v=Math.round(n(v)); return v===0 ? '-' : v.toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function ymLbl(s){ s=String(s||''); return s.length===6 ? s.slice(0,4)+'-'+s.slice(4,6) : s; }
function dtLbl(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : (s||'-'); }
function thisMonth(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2); }

(function init(){
  document.getElementById('cbYm').value = thisMonth();
  document.getElementById('cbList').innerHTML =
    '<tbody><tr><td class="cb-msg">[조회]를 누르면 거래처별 잔액이 나옵니다.</td></tr></tbody>';
  document.getElementById('cbHist').innerHTML = '';
})();

function cbThisMonth(){ document.getElementById('cbYm').value = thisMonth(); cbRender(); }

/* ★서버는 '전 기간 × 전 거래처'를 한 번에 준다 — 잔액이 누계라 기간을 걸 수 없기 때문이다.
     한 번 받아두면 기준월·필터·검색을 바꿔도 재조회가 없다(매출 그래프 일자별과 같은 방식). */
function cbLoad(){
  document.getElementById('kRange').textContent='조회 중…';
  fetch(CTX+'/mangr/selectCustBalance.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){ _rows=(j&&j.data)||[]; _pick=null; cbRender(); })
    .catch(function(e){
      document.getElementById('kRange').textContent='오류';
      if(window._alertBox) _alertBox('조회에 실패했습니다.<br><span style="font-size:13px;color:#2b3a48">'+esc(e.message)+'</span>', {icon:'❌', okColor:'red'});
    });
}

/* 거래처별로 접는다. 기준월(ymTo) 이후 달은 잔액에서 뺀다 — '그 시점 잔액'을 보기 위함.
   ★이월 / 당월 분리 (2026-07-26 요청) : 기준월보다 앞선 달 = 이월, 기준월 = 당월.
     이월 + 당월매출 − 당월수금 = 남은금액  (지급 쪽도 같은 구조)
     기준월을 비워 두면 당월이 없어 전부 이월로 잡힌다. */
function cbFold(){
  var ymTo=(document.getElementById('cbYm').value||'').replace('-','');
  var m={}, ord=[];
  _rows.forEach(function(r){
    var ym=String(r.ym||'');
    if(ymTo && ym > ymTo) return;                 // 기준월 이후는 아직 안 일어난 일로 본다
    var k=String(r.custCd||'');
    if(!m[k]){ m[k]={ custCd:k, custNm:r.custNm||k, gb:r.vendorGb||'', mgrNm:r.mgrNm||'', tel:r.tel||'', dcCd:r.dcCd||'',
                      recv:0, pay:0, sale:0, rcv:0, purch:0, payout:0,
                      prevRecv:0, prevPay:0, curSale:0, curRcv:0, curPurch:0, curPay:0,
                      lastDt:'', months:[] }; ord.push(k); }
    var o=m[k];
    var sale=n(r.saleAmt)-n(r.saleDcAmt), rcv=n(r.rcvAmt),
        purch=n(r.purchAmt)-n(r.purchDcAmt), payout=n(r.payAmt);
    o.sale+=sale; o.rcv+=rcv; o.purch+=purch; o.payout+=payout;
    o.recv += sale-rcv;        // 받을금액 = 매출(할인 후) - 수금
    o.pay  += purch-payout;    // 지급할금액 = 매입(할인 후) - 지급
    if(ymTo && ym === ymTo){ o.curSale+=sale; o.curRcv+=rcv; o.curPurch+=purch; o.curPay+=payout; }
    else { o.prevRecv += sale-rcv; o.prevPay += purch-payout; }
    if(String(r.lastDt||'') > o.lastDt) o.lastDt=String(r.lastDt||'');
    o.months.push({ ym:ym, sale:n(r.saleAmt), saleDc:n(r.saleDcAmt), rcv:rcv,
                    purch:n(r.purchAmt), purchDc:n(r.purchDcAmt), pay:payout });
  });
  return ord.map(function(k){ return m[k]; });
}

function cbRender(){
  if(!_rows.length){
    document.getElementById('cbList').innerHTML =
      '<tbody><tr><td class="cb-msg">[조회]를 누르면 거래처별 잔액이 나옵니다.</td></tr></tbody>';
    return;
  }
  var f=document.getElementById('cbFilter').value;
  var q=(document.getElementById('cbFind').value||'').trim().toLowerCase();

  _list = cbFold().filter(function(o){
    if(f==='recv' && Math.round(o.recv)===0) return false;
    if(f==='pay'  && Math.round(o.pay)===0)  return false;
    if(f==='bal'  && Math.round(o.recv)===0 && Math.round(o.pay)===0) return false;
    if(q && (o.custNm||'').toLowerCase().indexOf(q)<0 && (o.custCd||'').toLowerCase().indexOf(q)<0) return false;
    return true;
  });

  var tR=0,tP=0,cR=0,cP=0;
  _list.forEach(function(o){
    tR+=o.recv; tP+=o.pay;
    if(Math.round(o.recv)!==0) cR++;
    if(Math.round(o.pay)!==0)  cP++;
  });
  document.getElementById('kRecv').textContent    = fmt(tR)==='-' ? '0' : fmt(tR);
  document.getElementById('kPay').textContent     = fmt(tP)==='-' ? '0' : fmt(tP);
  document.getElementById('kNet').textContent     = (Math.round(tR-tP)).toLocaleString();
  document.getElementById('kRecvCnt').textContent = cR.toLocaleString()+' 곳';
  document.getElementById('kPayCnt').textContent  = cP.toLocaleString()+' 곳';

  var yms={}; _rows.forEach(function(r){ if(r.ym) yms[r.ym]=1; });
  var yk=Object.keys(yms).sort();
  document.getElementById('kRange').textContent = yk.length ? (ymLbl(yk[0])+' ~ '+ymLbl(yk[yk.length-1])) : '자료 없음';
  document.getElementById('cbListSub').textContent =
      (document.getElementById('cbYm').value||'전체') + ' 말 기준 누계 · ' + _list.length.toLocaleString() + '곳';

  cbSortList();
  cbListRender(tR, tP);
  /* 선택했던 거래처가 필터에서 빠지면 이력을 비운다 */
  if(_pick && !_list.some(function(o){ return o.custCd===_pick; })) { _pick=null; cbHistRender(); }
  else cbHistRender();
}

function cbSortList(){
  var k=_sort.key, d=_sort.desc?-1:1;
  _list.sort(function(a,b){
    var x,y;
    if(k==='nm'){ x=(a.custNm||''); y=(b.custNm||''); return x<y?d*-1:(x>y?d:0); }
    if(k==='dt'){ x=a.lastDt||''; y=b.lastDt||''; return x<y?d*-1:(x>y?d:0); }
    if(k==='net'){ x=a.recv-a.pay; y=b.recv-b.pay; }
    else { x=a[k]; y=b[k]; }
    return x===y ? 0 : (x<y?d*-1:d);
  });
}
function cbSort(key){
  if(_sort.key===key) _sort.desc=!_sort.desc;
  else { _sort.key=key; _sort.desc=true; }
  cbSortList(); cbListRender();
}
function _arrow(k){ return _sort.key===k ? (_sort.desc?' ▼':' ▲') : ''; }

function cbListRender(tR, tP){
  var el=document.getElementById('cbList');
  if(!_list.length){
    el.innerHTML='<tbody><tr><td class="cb-msg">조건에 맞는 거래처가 없습니다. (보기를 <b>전체</b>로 바꿔 보세요)</td></tr></tbody>';
    return;
  }
  if(tR===undefined){ tR=0; tP=0; _list.forEach(function(o){ tR+=o.recv; tP+=o.pay; }); }
  /* 합계줄의 이월·당월도 같이 낸다 — 잔액만 합치면 '이월+당월=잔액' 이 합계줄에서 안 맞아 보인다 */
  var s={pr:0,cs:0,cr:0,pp:0,cp:0,cy:0};
  _list.forEach(function(o){ s.pr+=o.prevRecv; s.cs+=o.curSale; s.cr+=o.curRcv;
                             s.pp+=o.prevPay;  s.cp+=o.curPurch; s.cy+=o.curPay; });
  /* ★머리글 2줄 — 받을금액·지급할금액을 각각 [이월·당월·남은금액] 으로 편다(2026-07-26 요청).
       이월 = 기준월 앞달 말 잔액 · 당월 = 기준월에 생긴 것 · 남은금액 = 이월+당월매출−당월수금 */
  var h='<thead><tr>'
      + '<th rowspan="2" class="sortable" onclick="cbSort(\'nm\')">거래처'+_arrow('nm')+'</th>'
      + '<th rowspan="2">구분</th>'
      + '<th colspan="4" class="grp">받을금액</th>'
      + '<th colspan="4" class="grp">지급할금액</th>'
      + '<th rowspan="2" class="sortable" onclick="cbSort(\'net\')">순액'+_arrow('net')+'</th>'
      + '<th rowspan="2" class="sortable" onclick="cbSort(\'dt\')">최근거래일'+_arrow('dt')+'</th>'
      + '</tr><tr>'
      + '<th>이월</th><th>당월매출</th><th>당월수금</th>'
      + '<th class="sortable" onclick="cbSort(\'recv\')">남은금액'+_arrow('recv')+'</th>'
      + '<th>이월</th><th>당월매입</th><th>당월지급</th>'
      + '<th class="sortable" onclick="cbSort(\'pay\')">남은금액'+_arrow('pay')+'</th>'
      + '</tr></thead><tbody>';
  h+='<tr class="tot"><td class="txt">■ 합계 ('+_list.length.toLocaleString()+'곳)</td><td></td>'
   + '<td>'+fmt(s.pr)+'</td><td>'+fmt(s.cs)+'</td><td>'+fmt(s.cr)+'</td><td>'+fmt(tR)+'</td>'
   + '<td>'+fmt(s.pp)+'</td><td>'+fmt(s.cp)+'</td><td>'+fmt(s.cy)+'</td><td>'+fmt(tP)+'</td>'
   + '<td>'+(Math.round(tR-tP)).toLocaleString()+'</td><td></td></tr>';

  if(!document.getElementById('cbGroup').checked){
    _list.forEach(function(o){ h+=cbRowHtml(o, false); });
    el.innerHTML=h+'</tbody>';
    return;
  }

  /* ★출고장 묶음 2단 (대시보드1·매출마감과 같은 규칙) — 묶음 머리행 + 소계, 클릭하면 접힌다.
       묶음 순서는 소계(받을금액) 큰 순. '기타 거래처'(출고장 없는 매입처 등)는 항상 맨 아래. */
  var gm={}, gord=[];
  _list.forEach(function(o){
    var g=cbGrpOf(o);
    if(!gm[g]){ gm[g]={ nm:g, rows:[], recv:0, pay:0, pr:0, cs:0, cr:0, pp:0, cp:0, cy:0, lastDt:'' }; gord.push(g); }
    var t=gm[g];
    t.rows.push(o);
    t.recv+=o.recv; t.pay+=o.pay;
    t.pr+=o.prevRecv; t.cs+=o.curSale; t.cr+=o.curRcv;
    t.pp+=o.prevPay;  t.cp+=o.curPurch; t.cy+=o.curPay;
    if((o.lastDt||'') > t.lastDt) t.lastDt=o.lastDt||'';
  });
  gord.sort(function(a,b){
    if(a===CB_ETC) return 1;
    if(b===CB_ETC) return -1;
    return gm[b].recv - gm[a].recv;
  });

  gord.forEach(function(g){
    var t=gm[g], off=!!_col[g], net=t.recv-t.pay;
    /* 묶음이 한 곳뿐이면 머리행을 만들지 않는다(용인·평택은 혼자다) — 매출내역 4탭과 같은 규칙 */
    if(t.rows.length === 1 && g !== CB_ETC){ h+=cbRowHtml(t.rows[0], false); return; }
    /* ★접기는 ▼ 화살표를 눌렀을 때만 (2026-07-26 요청).
         종전엔 머리행 전체가 onclick 이라 소계 숫자를 짚어 보려고 눌러도 접혔다. */
    h+='<tr class="grow">'
     + '<td class="txt"><span class="tg" onclick="cbToggle(\''+esc(g).replace(/'/g,"\\'")+'\')" title="'+(off?'펼치기':'접기')+'">'+(off?'▶':'▼')+'</span> '
     +   esc(g)+' <span class="cnt">'+t.rows.length+'곳</span></td><td></td>'
     + '<td>'+fmt(t.pr)+'</td><td>'+fmt(t.cs)+'</td><td>'+fmt(t.cr)+'</td><td class="amt-r">'+fmt(t.recv)+'</td>'
     + '<td>'+fmt(t.pp)+'</td><td>'+fmt(t.cp)+'</td><td>'+fmt(t.cy)+'</td><td class="amt-p">'+fmt(t.pay)+'</td>'
     + '<td>'+(Math.round(net)===0?'-':Math.round(net).toLocaleString())+'</td>'
     + '<td class="ctr">'+dtLbl(t.lastDt)+'</td></tr>';
    if(off) return;
    t.rows.forEach(function(o){ h+=cbRowHtml(o, true); });
  });
  el.innerHTML=h+'</tbody>';
}

/* 거래처 한 줄. sub=true 면 묶음 아래 들여쓰기 */
function cbRowHtml(o, sub){
  var net=o.recv-o.pay, dc=cbDcNm(o);
  return '<tr class="pick'+(_pick===o.custCd?' on':'')+'" onclick="cbPick(\''+esc(o.custCd).replace(/'/g,"\\'")+'\')">'
   + '<td class="txt'+(sub?' ind':'')+'" title="'+esc(o.custCd)+(o.mgrNm?' · 담당 '+esc(o.mgrNm):'')+(o.tel?' · '+esc(o.tel):'')+'">'
   +   esc(o.custNm)+(dc?' <span class="gb">'+esc(dc)+'</span>':'')+'</td>'
   + '<td class="ctr">'+(o.gb?'<span class="gb">'+esc(o.gb)+'</span>':'')+'</td>'
   + '<td>'+fmt(o.prevRecv)+'</td><td>'+fmt(o.curSale)+'</td><td>'+fmt(o.curRcv)+'</td>'
   + '<td class="amt-r">'+fmt(o.recv)+'</td>'
   + '<td>'+fmt(o.prevPay)+'</td><td>'+fmt(o.curPurch)+'</td><td>'+fmt(o.curPay)+'</td>'
   + '<td class="amt-p">'+fmt(o.pay)+'</td>'
   + '<td>'+(Math.round(net)===0?'-':Math.round(net).toLocaleString())+'</td>'
   + '<td class="ctr">'+dtLbl(o.lastDt)+'</td></tr>';
}

function cbToggle(g){ _col[g]=!_col[g]; cbListRender(); }
function cbToggleAll(){
  /* 하나라도 펼쳐져 있으면 전부 접고, 다 접혀 있으면 전부 펼친다 */
  var gs={}; _list.forEach(function(o){ gs[cbGrpOf(o)]=1; });
  var ks=Object.keys(gs), anyOpen=ks.some(function(g){ return !_col[g]; });
  ks.forEach(function(g){ _col[g]=anyOpen; });
  cbListRender();
}

function cbPick(cd){ _pick=cd; cbListRender(); cbHistRender(); }

/* 월별 이력 — 잔액은 오래된 달부터 누적해서 만들고, 화면에는 최근 달부터 보여준다 */
function cbHistRender(){
  var el=document.getElementById('cbHist'), sub=document.getElementById('cbHistSub');
  var o=null;
  _list.some(function(x){ if(x.custCd===_pick){ o=x; return true; } return false; });
  if(!o){
    sub.textContent='거래처를 고르세요';
    el.innerHTML='';
    return;
  }
  sub.textContent=o.custNm+' ('+o.custCd+')';

  // 같은 달이 여러 줄로 들어올 일은 없지만(서버가 월로 묶어 준다) 방어적으로 합친다
  var mm={}, ord=[];
  o.months.forEach(function(r){
    if(!mm[r.ym]){ mm[r.ym]={ ym:r.ym, sale:0, saleDc:0, rcv:0, purch:0, purchDc:0, pay:0 }; ord.push(r.ym); }
    var t=mm[r.ym];
    t.sale+=r.sale; t.saleDc+=r.saleDc; t.rcv+=r.rcv; t.purch+=r.purch; t.purchDc+=r.purchDc; t.pay+=r.pay;
  });
  /* 달마다 '그 달 시작 시점의 잔액(=이월)' 을 같이 들고 간다.
     이월 + 그달매출 − 그달수금 = 그달 잔액 이 한 줄에서 딱 떨어지게 하려는 것(2026-07-26 요청). */
  var asc=ord.sort(), bR=0, bP=0, list=[];
  asc.forEach(function(k){
    var t=mm[k], pR=bR, pP=bP;
    bR += (t.sale-t.saleDc) - t.rcv;
    bP += (t.purch-t.purchDc) - t.pay;
    list.push({ ym:k, prevR:pR, sale:t.sale-t.saleDc, rcv:t.rcv, balR:bR,
                      prevP:pP, purch:t.purch-t.purchDc, pay:t.pay, balP:bP });
  });
  list.reverse();     // ★최근 달이 맨 위 (2026-07-26 방침 — 다른 화면과 같다)

  var h='<thead><tr><th rowspan="2">월</th>'
      + '<th colspan="4" class="grp">받을금액</th>'
      + '<th colspan="4" class="grp">지급할금액</th></tr>'
      + '<tr><th>이월</th><th>매출</th><th>수금</th><th>남은금액</th>'
      + '<th>이월</th><th>매입</th><th>지급</th><th>남은금액</th></tr></thead><tbody>';
  h+='<tr class="mtot"><td class="ctr">누계</td>'
   + '<td>-</td><td>'+fmt(o.sale)+'</td><td>'+fmt(o.rcv)+'</td><td class="amt-r">'+fmt(o.recv)+'</td>'
   + '<td>-</td><td>'+fmt(o.purch)+'</td><td>'+fmt(o.payout)+'</td><td class="amt-p">'+fmt(o.pay)+'</td></tr>';
  list.forEach(function(r){
    h+='<tr><td class="ctr">'+ymLbl(r.ym)+'</td>'
     + '<td>'+fmt(r.prevR)+'</td><td>'+fmt(r.sale)+'</td><td>'+fmt(r.rcv)+'</td><td class="amt-r">'+fmt(r.balR)+'</td>'
     + '<td>'+fmt(r.prevP)+'</td><td>'+fmt(r.purch)+'</td><td>'+fmt(r.pay)+'</td><td class="amt-p">'+fmt(r.balP)+'</td></tr>';
  });
  el.innerHTML=h+'</tbody>';
}

/* 도움말 열고닫기 — 인자 없이 부르면 토글, false 면 닫기 */
function cbHelp(on){
  var box=document.getElementById('cbHelpBox');
  var show = (on===undefined) ? (box.style.display==='none') : !!on;
  box.style.display = show ? '' : 'none';
  document.getElementById('cbHelpBtn').textContent = show ? 'ℹ️ 도움말 닫기' : 'ℹ️ 도움말';
}
</script>
