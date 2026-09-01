<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 메시지는 프로젝트 공통 컴포넌트(로그인 화면과 동일) --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- ★날짜 칸에 [◀][▶][오늘] 을 자동으로 붙인다 (2026-08-17 요청) — 화면 수정 0.
     브라우저 기본 달력의 ↑↓ 는 앞/뒤가 안 읽혀 엉뚱한 달로 넘어가는 일이 잦았다.
     빼려면 그 칸에 data-nonav="1" --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<!--
  출고현황이력조회 — 발주현황표 엑셀 업로드 이력 (2026-07-25 사용자 요청)
    · 대시보드에서 엑셀을 올릴 때마다 '배치'가 생긴다. 배치키 = 출고일자 + 출고장 + 차수(JOB_SEQ)
    · 같은 (출고일자,출고장)을 다시 올리면 기존 배치는 ACTION_YN 'Y'→'N' 으로 내려가고
      JOB_SEQ+1 로 새 배치가 선다. 그래서 '지금 쓰이는 자료'는 활성 배치 하나뿐이다.
    · 상단 = 일자별 업로드 이력(언제·누가·어느 파일·몇 건) / 줄 클릭 → 하단 = 그 배치의 발생내역
    · 조회 전용. 여기서 지우거나 고치지 않는다(원본은 업로드 자체).
-->
<style>
  :root{ --sh-bd:#dbe2ea; --sh-teal:#137a6c; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  .sh-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .sh-wrap h2{ margin:0 0 4px; font-size:20px; }
  .sh-sub{ color:#6b7a89; margin-bottom:12px; font-size:12.5px; }
  .sh-card{ background:#fff; border:1px solid var(--sh-bd); border-radius:10px; padding:12px; margin-bottom:12px; }
  .sh-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; margin-bottom:10px; }
  .sh-fld{ display:flex; flex-direction:column; gap:3px; }
  .sh-fld label{ font-size:11px; font-weight:700; color:#6b7a89; }
  .sh-fld input, .sh-fld select{ height:32px; border:1px solid var(--sh-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .sh-btn{ height:32px; border:1px solid var(--sh-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .sh-btn:hover{ border-color:var(--sh-teal); }
  .sh-btn.teal{ background:var(--sh-teal); color:#fff; border-color:var(--sh-teal); }
  /* 목록 — 자동 스크롤(매출내역과 같은 방식).
     ★높이 = max(340px, 44vh) (2026-08-28 「글자 축소시 하단 빈공간」) — 340px 고정이라
       글자를 축소해 화면(안쪽 뷰포트)이 커져도 표가 안 늘어나 아래가 통째로 비었다.
       100% 에서는 종전 340px 그대로, 축소할수록 vh 쪽이 커져 화면을 채운다.
       이 화면은 iframe 이라 vh 에 --kz 나눗셈이 필요 없다(상자 역보정이 뷰포트를 키움 — CLAUDE.md). */
  .sh-list{ max-height:max(340px, 44vh); overflow:auto; border:1px solid var(--sh-bd); border-radius:8px; }
  .sh-list table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sh-list th{ background:#b9ded4; color:#0b4f43; font-weight:800; box-shadow:inset 0 -2px 0 #0e6657; border:1px solid var(--sh-bd); padding:7px 8px; position:sticky; top:0; z-index:2; }
  .sh-list td{ border:1px solid var(--sh-bd); padding:6px 8px; text-align:center; }
  .sh-list td.num{ text-align:right; }
  .sh-list td.txt{ text-align:left; }
  /* 업로드 일시 = 날짜(작게·흐리게) 위 / 시각(굵게) 아래. 줄높이를 줄여 목록 행 높이는 그대로 둔다 */
  .sh-list .up-d{ display:block; font-size:11px; color:#8b98a5; line-height:1.15; font-weight:400; }
  .sh-list .up-t{ display:block; line-height:1.15; }
  .sh-list tbody tr{ cursor:pointer; }
  .sh-list tbody tr:hover td{ background:#f3f8f6; }
  .sh-list tr.on td{ background:#fdeef0; font-weight:700; }
  .sh-list tr.dgrp td{ background:#e8f6ec; font-weight:800; cursor:default; text-align:left; }
  /* 같은 시각 업로드 묶음 머리줄 (2026-07-27) — 발주현황표 한 장이 출고장별 배치로 갈리므로 한 줄로 접는다 */
  .sh-list tr.ugrp td{ background:#f2f7f5; font-weight:700; cursor:pointer; }
  .sh-list tr.ugrp:hover td{ background:#e7f0ec; }
  .sh-list tr.ugrp .car{ display:inline-block; width:13px; color:#1f9b8e; }
  .sh-list tr.ukid td:first-child{ padding-left:22px; }
  .sh-dtl{ max-height:max(300px, 36vh); overflow:auto; border:1px solid var(--sh-bd); border-radius:8px; }  /* 위 .sh-list 주석 참고 */
  .sh-dtl table{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  .sh-dtl th{ background:#b9ded4; color:#0b4f43; font-weight:800; box-shadow:inset 0 -2px 0 #0e6657; border:1px solid var(--sh-bd); padding:6px 8px; position:sticky; top:0; z-index:2; }
  .sh-dtl td{ border:1px solid var(--sh-bd); padding:5px 8px; text-align:center; }
  .sh-dtl td.num{ text-align:right; }
  .sh-dtl td.txt{ text-align:left; }
  .sh-msg{ padding:12px; color:#9aa7b3; text-align:center; font-size:12.5px; }
  .badge{ display:inline-block; padding:1px 7px; border-radius:10px; font-size:11.5px; font-weight:700; color:#fff; }
  .b-live{ background:#137a6c; }   /* 지금 쓰이는 배치 */
  .b-old{ background:#9aa7b3; }    /* 지난 이력 */
  .b-re{ background:#c47f17; }     /* 재업로드(2차 이상) */
  /* 출고장 다중선택 드롭다운 — 대시보드(.ohdc-pop)와 같은 규격.
     ★고정폭 + nowrap 이 필수다. 부모(.sh-fld)에 눌리면 글자가 세로로 접힌다. */
  .shdc-wrap{ position:relative; display:block; }
  .shdc-pop{ display:none; position:absolute; top:36px; left:0; z-index:60; background:#fff; border:1px solid var(--sh-bd);
             border-radius:8px; box-shadow:0 6px 18px rgba(31,42,55,.18); padding:8px 6px;
             width:250px; max-height:340px; overflow-y:auto; overflow-x:hidden; box-sizing:border-box; }
  .shdc-pop.open{ display:block; }
  .shdc-pop label{ display:flex; align-items:center; gap:8px; padding:6px 10px; font-size:12.5px; color:#37475a;
                   cursor:pointer; border-radius:6px; white-space:nowrap; }
  .shdc-pop label:hover{ background:#eef3f2; }
  /* 체크박스가 flex 아이템이라 늘어나는 것을 막는다 */
  .shdc-pop label input[type=checkbox]{ flex:0 0 auto; width:14px; height:14px; margin:0; }
  .shdc-pop label > span{ flex:1 1 auto; overflow:hidden; text-overflow:ellipsis; }
  .shdc-pop label.all{ color:#178074; font-weight:700; border-bottom:1px dashed var(--sh-bd); border-radius:6px 6px 0 0; margin-bottom:4px; }
  .shdc-pop label.on{ color:#0e6657; background:#e3f4ef; }
  .kpi{ display:flex; gap:10px; flex-wrap:wrap; margin-bottom:10px; }
  .kpi div{ flex:1 1 150px; border:1px solid var(--sh-bd); border-radius:8px; padding:8px 12px; background:#fbfdfc; }
  .kpi b{ display:block; font-size:19px; color:#137a6c; margin-top:2px; }
  .kpi span{ font-size:11.5px; color:#6b7a89; }
</style>

<div class="sh-wrap">
  <h2>🗂️ 출고현황이력조회</h2>
  <div class="sh-sub">대시보드에서 올린 <b>발주현황표 엑셀</b>의 업로드 이력입니다. 줄을 누르면 그 업로드가 담았던 발생내역이 아래에 펼쳐집니다.</div>

  <div class="sh-card">
    <div class="sh-row">
      <div class="sh-fld" style="flex:0 0 150px"><label>출고일자(시작)</label><input type="date" id="shFrom"></div>
      <div class="sh-fld" style="flex:0 0 150px"><label>출고일자(종료)</label><input type="date" id="shTo"></div>
      <%-- 출고장 = 체크박스 다중선택. 대시보드·매출내역과 같은 방식(2026-07-25 요청).
           단일 select 는 '평택만' 같은 한 곳밖에 못 봐서 여러 센터를 견줄 수가 없다.
           선택은 서버로 안 보내고 화면에서 거른다 — 조회 왕복 없이 즉시 바뀐다. --%>
      <div class="sh-fld" style="flex:0 0 200px"><label>출고장</label>
        <div class="shdc-wrap" id="shDcWrap">
          <button type="button" class="sh-btn" id="shDcBtn" onclick="shDcOpen(event)"
                  style="width:100%; display:flex; align-items:center; justify-content:space-between; gap:6px; text-align:left"
                  title="출고장을 하나 이상 고르세요. 아무것도 안 고르면 전체입니다.">
            <span>🏬</span><span style="margin-left:auto; color:#178074"><b id="shDcLbl">전체</b> ▾</span></button>
          <div class="shdc-pop" id="shDcPop"></div>
        </div>
      </div>
      <div class="sh-fld" style="flex:0 0 220px"><label>검색(출고장명·파일명)</label><input type="text" id="shFind" placeholder="예) 평택 · 2026.07"></div>
      <button class="sh-btn teal" onclick="shLoad()">조회</button>
      <button class="sh-btn" onclick="shQuick(7)">최근 7일</button>
      <button class="sh-btn" onclick="shQuick(30)">최근 30일</button>
      <button class="sh-btn" onclick="shQuick(0)">전체</button>
      <label style="align-self:center; font-size:12.5px; cursor:pointer; margin-left:6px">
        <input type="checkbox" id="shLiveOnly" onchange="shRender()"> 현재 반영분만
      </label>
    </div>

    <div class="kpi">
      <div><span>업로드 배치</span><b id="kBatch">0</b></div>
      <div><span>재업로드(2차 이상)</span><b id="kRe">0</b></div>
      <div><span>출고일자</span><b id="kDate">0</b></div>
      <div><span>행 수</span><b id="kRow">0</b></div>
      <div><span>수량 합계</span><b id="kQty">0</b></div>
    </div>

    <div id="shSum" style="margin-bottom:8px; font-size:12.5px; color:#5a6b7a"></div>
    <div class="sh-list" id="shWrap">
      <table>
        <thead><tr>
          <th style="width:110px">출고일자</th><th style="width:110px">납기일자</th><th style="width:150px">출고장</th>
          <th style="width:60px">차수</th><th style="width:90px">상태</th>
          <th style="width:150px">업로드 일시</th><th style="width:90px">올린 사람</th>
          <th style="width:80px">행 수</th><th style="width:80px">사업장</th><th style="width:80px">품목</th>
          <th style="width:90px">수량</th><th>원본 파일</th>
        </tr></thead>
        <tbody id="shBody"><tr><td colspan="12" class="sh-msg">[조회]를 누르세요.</td></tr></tbody>
      </table>
    </div>
    <div id="shPager" style="padding:6px 2px; text-align:center; min-height:24px"></div>
  </div>

  <div class="sh-card">
    <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
      <b>발생내역</b>
      <span id="shDtlHdr" style="color:#6b7a89; font-size:12.5px">위 목록에서 업로드 줄을 선택하세요.</span>
    </div>
    <div class="sh-dtl" id="shDtlWrap">
      <table>
        <thead><tr>
          <th style="width:60px">No</th><th style="width:110px">사업장코드</th><th>사업장</th>
          <th style="width:120px">품목코드</th><th>품목명</th>
          <th style="width:70px">단위</th><th style="width:80px">수량</th><th style="width:80px">BOX</th>
          <th style="width:130px">발주번호</th><th style="width:90px">입고장</th>
        </tr></thead>
        <tbody id="shDtlBody"><tr><td colspan="10" class="sh-msg">—</td></tr></tbody>
      </table>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
/* 목록 페이징 상태 — ★선언이 init 아래에 있으면 첫 렌더 때 undefined 가 된다(2026-07-25 매입/판매등록에서 겪음) */
var LIST_ROWS = 15, _shown = 0, _bound = false;
var _all = [], _view = [], _cur = null;

function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function fmtDt(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
/* 업로드 일시 — '2026-08-02 16:45:18' 을 날짜(흐리게)+시각 두 줄로. 시각만 보이면 출고일자 머리줄(▣)의
   날짜와 같은 날인 줄 오해한다(2026-08-03 요청). 실제로 8/2 에 올린 자료가 8/3 머리줄 아래 있다. */
function fmtUp(s){
  s=String(s||''); if(!s) return '';
  // 시각은 받은 만큼 그대로 — 묶음 머리줄은 분까지(16자), 출고장 줄은 초까지(19자) 넘어온다
  var d=s.slice(0,10), t=s.slice(11);
  return t ? '<span class="up-d">'+esc(d)+'</span><span class="up-t">'+esc(t)+'</span>' : esc(s);
}
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function shift(days){ var d=new Date(); d.setDate(d.getDate()+days);
  return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function post(url, body){
  return fetch(CTX+url, { method:'POST', credentials:'same-origin',
    headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body })
    .then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||[]; });
}
function swErr(msg){ if(window._alertBox) return _alertBox(msg,{icon:'❌',okColor:'red'}); alert(msg); }

(function init(){
  document.getElementById('shFrom').value = shift(-30);
  document.getElementById('shTo').value = today();
  shLoad();
})();

function shQuick(days){
  document.getElementById('shFrom').value = days ? shift(-days) : '';
  document.getElementById('shTo').value   = days ? today() : '';
  shLoad();
}

function shLoad(){
  var b = 'shpoutDtFrom='+encodeURIComponent(document.getElementById('shFrom').value)
        + '&shpoutDtTo='+encodeURIComponent(document.getElementById('shTo').value)
        // 출고장은 서버로 안 보낸다 — 목록을 조회 결과에서 만들어야 해서 전부 읽고 화면에서 거른다
        + '&findData='+encodeURIComponent(document.getElementById('shFind').value);
  document.getElementById('shBody').innerHTML='<tr><td colspan="12" class="sh-msg">조회 중…</td></tr>';
  post('/shipout/selectShipoutUploadHist.do', b).then(function(l){
    _all = l||[];
    shFillDc();
    shRender();
  }).catch(function(e){
    document.getElementById('shBody').innerHTML='<tr><td colspan="12" class="sh-msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>';
  });
}

/* 출고장 다중선택 — 대시보드·매출내역과 같은 방식(2026-07-25).
   목록은 KONET_DC 같은 마스터가 아니라 '조회된 자료에 실제로 있는 출고장'으로 만든다.
   없는 곳을 고르면 0건이 나와 이유를 모르기 때문. 비어 있으면 전체다. */
var _dcSel = {};   // { 'E500':1, ... } — 비어 있으면 전체
function shDcOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('shDcPop'); if(p) p.classList.toggle('open'); }
function shDcToggle(k){ if(_dcSel[k]) delete _dcSel[k]; else _dcSel[k]=1; shFillDc(); shRender(); }
function shDcAll(){ _dcSel={}; shFillDc(); shRender(); }
document.addEventListener('click', function(e){
  var w=document.getElementById('shDcWrap'), p=document.getElementById('shDcPop');
  if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
});
function shDcHit(o){
  if(!Object.keys(_dcSel).length) return true;      // 선택 없음 = 전체
  return !!_dcSel[o.dcCd||''];
}
function shFillDc(){
  var pop=document.getElementById('shDcPop'), lbl=document.getElementById('shDcLbl');
  if(!pop) return;
  var m={};
  _all.forEach(function(o){ m[o.dcCd||''] = o.dcNm||o.dcCd||'(출고장 미지정)'; });
  var ks=Object.keys(m).sort(function(a,b){ return String(m[a]).localeCompare(String(m[b]),'ko'); });
  // 기간을 바꿔 사라진 출고장의 선택은 정리한다 — 안 그러면 0건인데 이유를 알 수 없다
  Object.keys(_dcSel).forEach(function(k){ if(ks.indexOf(k)<0) delete _dcSel[k]; });
  var n=Object.keys(_dcSel).length;
  if(lbl) lbl.textContent = n===0 ? '전체' : (n===1 ? (m[Object.keys(_dcSel)[0]]||'1곳') : (n+'곳 선택'));
  var h='<label class="all'+(n===0?' on':'')+'"><input type="checkbox"'+(n===0?' checked':'')
      + ' onchange="shDcAll()"><span>전체 ('+ks.length+'개 출고장)</span></label>';
  ks.forEach(function(k){
    var on=!!_dcSel[k], cnt=_all.filter(function(o){ return (o.dcCd||'')===k; }).length;
    h+='<label class="'+(on?'on':'')+'"><input type="checkbox"'+(on?' checked':'')
     + ' data-k="'+esc(k)+'" onchange="shDcToggle(this.getAttribute(\'data-k\'))">'
     + '<span>🏬 '+esc(m[k])+' <span style="color:#9aa7b3">('+cnt+'건)</span></span></label>';
  });
  pop.innerHTML=h;
}

function shRender(){
  var liveOnly = document.getElementById('shLiveOnly').checked;
  _view = _all.filter(function(o){ return shDcHit(o) && (!liveOnly || o.actionYn==='Y'); });

  var re=0, dates={}, rows=0, qty=0;
  _view.forEach(function(o){
    if(n(o.jobSeq)>1) re++;
    dates[o.shpoutDt]=1; rows+=n(o.rowCnt); qty+=n(o.qtySum);
  });
  document.getElementById('kBatch').textContent = _view.length.toLocaleString();
  document.getElementById('kRe').textContent    = re.toLocaleString();
  document.getElementById('kDate').textContent  = Object.keys(dates).length.toLocaleString();
  document.getElementById('kRow').textContent   = fmt(rows);
  document.getElementById('kQty').textContent   = fmt(qty);
  document.getElementById('shSum').innerHTML = _view.length
    ? '<b>📦 줄</b> = 같은 시각에 올린 한 번의 업로드(출고장별로 갈린 배치를 묶음) — <b>클릭하면 출고장별로 펼쳐집니다</b>'
      + ' · 배지 — <span class="badge b-live">반영중</span> 지금 쓰이는 자료 · <span class="badge b-old">이력</span> 재업로드로 밀려난 지난 자료 · <span class="badge b-re">N차</span> 같은 날 다시 올린 횟수'
    : '';

  var tb=document.getElementById('shBody');
  if(!_view.length){ tb.innerHTML='<tr><td colspan="12" class="sh-msg">해당 조건의 업로드 이력이 없습니다.</td></tr>'; _shown=0; shPager(); return; }
  shUpBuild();                                  // [묶음] 같은 시각 업로드끼리 인접하도록 재정렬 + 묶음 집계
  _shown = Math.min(LIST_ROWS, _view.length);
  tb.innerHTML = shRows(0, _shown);
  shBind(); shPager(); shFillView();
}

/* 묶음이 접히면 배치 15건이 화면상 2~3줄로 줄어 스크롤이 생기지 않고, 그러면 스크롤 더보기가
   영영 안 걸려 나머지 자료에 닿을 수 없다 → 스크롤이 생길 때까지(또는 전부 실릴 때까지) 미리 채운다. */
function shFillView(){
  var w=document.getElementById('shWrap'); if(!w) return;
  var guard=0;
  while(_shown<_view.length && w.scrollHeight<=w.clientHeight+10 && guard++<60) shMore();
}

/* ══ 같은 시각 업로드 묶음 (2026-07-27 사용자 지시) ═══════════════════════════════════
     발주현황표 한 장을 저장하면 배치가 출고장별로 갈려 같은 업로드가 6~7줄로 늘어난다.
     화면에서 한 줄로 접고, 펼치면 종전처럼 출고장별 줄이 나와 발생내역을 볼 수 있게 한다.
      · 묶음키 = 원본파일 + 업로드일시(분 단위). 초 단위는 배치마다 몇 초 흔들릴 수 있어 분으로 자른다.
      · ★서버 정렬이 (출고일자 DESC, DC_CD, 납기일자, 차수 DESC)라 같은 시각 행이 떨어져 있다
        → 묶음이 붙어 나오도록 화면에서 (출고일자 DESC, 업로드분 DESC, 파일, DC_CD)로 재정렬한다.
      · _view 인덱스로 발생내역을 조회하므로(shPick) 정렬은 렌더 전에 끝내고 이후 인덱스는 건드리지 않는다. */
var _upMap = {}, _upCol = {};                   // 묶음 집계 / 접힘상태(기본 접힘)
function shUpKey(o){ return String(o.srcFile||'')+'|'+String(o.uploadDttm||'').slice(0,16); }
function shUpIsCol(k){ return _upCol[k]!==false; }
function shUpToggle(kEnc){
  var k = decodeURIComponent(kEnc);            // 머리줄 onclick 에 실려 오는 값은 인코딩되어 있다
  _upCol[k] = shUpIsCol(k) ? false : true;
  document.getElementById('shBody').innerHTML = shRows(0, _shown);   // 접힘만 바뀌므로 현재 분량 그대로 다시 그린다
  shFillView();                                                      // 접어서 줄이 줄었으면 스크롤이 생길 만큼 더 채운다
}
function shUpBuild(){
  _view.sort(function(a,b){
    return String(b.shpoutDt||'').localeCompare(String(a.shpoutDt||''))
        || String(b.uploadDttm||'').slice(0,16).localeCompare(String(a.uploadDttm||'').slice(0,16))
        || String(a.srcFile||'').localeCompare(String(b.srcFile||''))
        || String(a.dcCd||'').localeCompare(String(b.dcCd||''));
  });
  _upMap = {};
  _view.forEach(function(o){
    var k=shUpKey(o), g=_upMap[k];
    if(!g){ g=_upMap[k]={ n:0, live:0, hist:0, rowCnt:0, qtySum:0, jobMax:0, dcs:[], _seen:{},
                          // 날짜+분까지 — 출고일자 머리줄(▣)과 업로드 날짜가 다를 수 있어 시각만으로는 헷갈린다(2026-08-03)
                          file:String(o.srcFile||''), hm:String(o.uploadDttm||'').slice(0,16) }; }
    var dc=String(o.dcNm||o.dcCd||'미지정').replace(/\s+/g,'').replace(/(물류)?센터$/,'');   // '용인물류센터'→'용인'
    if(!g._seen[dc]){ g._seen[dc]=1; g.dcs.push(dc); }
    g.n++; g.rowCnt+=n(o.rowCnt); g.qtySum+=n(o.qtySum);
    if(o.actionYn==='Y') g.live++; else g.hist++;
    if(n(o.jobSeq)>g.jobMax) g.jobMax=n(o.jobSeq);
  });
}
// 묶음 머리줄 — 접힘/펼침 캐럿 + 출고장 묶음 + 합계. 상태는 묶음 안이 섞이면 '일부 반영중'으로.
function shUpRow(k){
  var g=_upMap[k]; if(!g) return '';
  var col=shUpIsCol(k);
  var st = g.hist===0 ? '<span class="badge b-live">반영중</span>'
         : (g.live===0 ? '<span class="badge b-old">이력</span>'
                       : '<span class="badge b-live">반영중</span> <span class="badge b-old">일부 이력</span>');
  if(g.jobMax>1) st += ' <span class="badge b-re">'+g.jobMax+'차</span>';
  return '<tr class="ugrp" onclick="shUpToggle(\''+esc(encodeURIComponent(k))+'\')"'
       + ' title="클릭 → 이 업로드의 출고장 '+g.n+'건 접기/펼치기">'
       + '<td colspan="4"><span class="car">'+(col?'▶':'▼')+'</span> 📦 출고장 <b>'+g.dcs.length+'곳</b>'
       + ' <span style="color:#5a6b7a;font-weight:600">'+esc(g.dcs.join('·'))+'</span></td>'
       + '<td>'+st+'</td>'
       + '<td>'+fmtUp(g.hm)+'</td><td></td>'
       + '<td class="num">'+fmt(g.rowCnt)+'</td><td class="num"></td><td class="num"></td>'
       + '<td class="num">'+fmt(g.qtySum)+'</td>'
       + '<td class="txt" style="color:#6b7a89">'+esc(g.file)+'</td></tr>';
}

/* 같은 출고일자끼리 머리줄로 묶고(▣), 그 안에서 같은 시각 업로드끼리 다시 묶는다(📦).
   묶음이 접혀 있으면 하위 출고장 줄은 건너뛴다 — 스크롤 더보기(shMore)로 이어 그릴 때도
   직전 줄에서 출고일자·묶음키를 되살려 머리줄이 중복/누락되지 않게 한다. */
function shRows(from, to){
  var h='', prev = from>0 ? _view[from-1].shpoutDt : null;
  var prevK = from>0 ? shUpKey(_view[from-1]) : null;
  for(var i=from;i<to;i++){
    var o=_view[i];
    if(o.shpoutDt!==prev){
      var same=_view.filter(function(x){ return x.shpoutDt===o.shpoutDt; });
      var cnt=same.length, r=same.filter(function(x){ return n(x.jobSeq)>1; }).length;
      var ups={}; same.forEach(function(x){ ups[shUpKey(x)]=1; });   // 그날 실제 '업로드 횟수'(묶음 수)
      h += '<tr class="dgrp"><td colspan="12">▣ '+esc(fmtDt(o.shpoutDt))+' — 업로드 '+Object.keys(ups).length+'회'
         + ' <span style="color:#6b7a89;font-weight:600">(배치 '+cnt+'건)</span>'
         + (r?(' <span style="color:#c47f17">· 재업로드 '+r+'건</span>'):'')+'</td></tr>';
      prev=o.shpoutDt; prevK=null;
    }
    var k=shUpKey(o);
    if(k!==prevK){ h += shUpRow(k); prevK=k; }
    if(shUpIsCol(k)) continue;                 // 접힌 묶음의 하위 줄은 그리지 않는다
    var st = (o.actionYn==='Y') ? '<span class="badge b-live">반영중</span>' : '<span class="badge b-old">이력</span>';
    if(n(o.jobSeq)>1) st += ' <span class="badge b-re">'+n(o.jobSeq)+'차</span>';
    h += '<tr class="ukid" onclick="shPick('+i+')">'
      + '<td>'+esc(fmtDt(o.shpoutDt))+'</td><td>'+esc(fmtDt(o.dlvDt))+'</td>'
      + '<td class="txt">'+esc(o.dcNm||'(미지정)')+(o.dcCd?(' <span style="color:#9aa7b3">'+esc(o.dcCd)+'</span>'):'')+'</td>'
      + '<td>'+n(o.jobSeq)+'</td><td>'+st+'</td>'
      + '<td>'+fmtUp(o.uploadDttm)+'</td><td>'+esc(o.regUser)+'</td>'
      + '<td class="num">'+fmt(o.rowCnt)+'</td><td class="num">'+fmt(o.bizCnt)+'</td><td class="num">'+fmt(o.itemCnt)+'</td>'
      + '<td class="num">'+fmt(o.qtySum)+'</td>'
      + '<td class="txt" style="color:#6b7a89">'+esc(o.srcFile)+'</td></tr>';
  }
  return h;
}
function shMore(cnt){
  if(_shown>=_view.length) return;
  var to=Math.min(_shown+(cnt||LIST_ROWS), _view.length);
  document.getElementById('shBody').insertAdjacentHTML('beforeend', shRows(_shown, to));
  _shown=to; shPager();
}
function shBind(){
  var w=document.getElementById('shWrap'); if(!w||_bound) return; _bound=true;
  w.addEventListener('scroll', function(){
    if(_shown>=_view.length) return;
    if(w.scrollTop+w.clientHeight >= w.scrollHeight-30) shMore();
  });
}
function shPager(){
  var el=document.getElementById('shPager');
  if(_shown>=_view.length){
    el.innerHTML = _view.length>LIST_ROWS ? '<span style="color:#9aa7b3;font-size:12.5px">총 '+_view.length+'건 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a;font-size:12.5px">'+_shown+' / <b>'+_view.length+'</b>건'
    + ' <span style="color:#9aa7b3">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="sh-btn" style="height:24px;margin-left:8px;font-size:12px" onclick="shMore('+_view.length+')">모두 표시</button>';
}

function shPick(i){
  var o=_view[i]; if(!o) return;
  _cur=o;
  Array.prototype.forEach.call(document.querySelectorAll('#shBody tr'), function(tr){ tr.classList.remove('on'); });
  var rows=document.querySelectorAll('#shBody tr[onclick]');
  Array.prototype.forEach.call(rows, function(tr){
    if(tr.getAttribute('onclick')==='shPick('+i+')') tr.classList.add('on');
  });
  document.getElementById('shDtlHdr').innerHTML =
    esc(fmtDt(o.shpoutDt))+' · '+esc(o.dcNm||'')+' · '+n(o.jobSeq)+'차'
    + ' <span style="color:#9aa7b3">('+esc(o.uploadDttm)+' · '+esc(o.srcFile)+')</span>';
  var tb=document.getElementById('shDtlBody');
  tb.innerHTML='<tr><td colspan="10" class="sh-msg">불러오는 중…</td></tr>';
  post('/shipout/selectShipoutUploadDtl.do',
       'shpoutDt='+encodeURIComponent(o.shpoutDt)+'&dlvDt='+encodeURIComponent(o.dlvDt||'')
       +'&dcCd='+encodeURIComponent(o.dcCd||'')+'&jobSeq='+n(o.jobSeq))
    .then(function(l){
      if(!l.length){ tb.innerHTML='<tr><td colspan="10" class="sh-msg">이 업로드의 내역이 없습니다.</td></tr>'; return; }
      tb.innerHTML = l.map(function(d,k){
        return '<tr><td>'+(k+1)+'</td><td>'+esc(d.bizCd)+'</td><td class="txt">'+esc(d.bizNm)+'</td>'
          + '<td>'+esc(d.itemCd)+'</td><td class="txt">'+esc(d.itemNm)+'</td>'
          /* ★수량 = 라벨수량(LABEL_QTY) (2026-09-01 「수량은 라벨수량을 출고수량으로」) — 없는 옛 행만 CUR_QTY 폴백 */
          + '<td>'+esc(d.unit)+'</td><td class="num">'+fmt((d.labelQty!=null&&d.labelQty!=='')?d.labelQty:d.curQty)+'</td><td class="num">'+fmt(d.boxQty)+'</td>'
          + '<td>'+esc(d.ordNo)+'</td><td>'+esc(d.inwh)+'</td></tr>';
      }).join('');
    })
    .catch(function(e){ tb.innerHTML='<tr><td colspan="10" class="sh-msg" style="color:#c0392b">내역 조회 오류</td></tr>'; });
}
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
<%-- ★공통 UI 보정 (2026-08-21) — 단추 글자 두 줄 접힘 방지 + [글자 축소/확대] 단추 모양.
     화면 크기와 무관하게 늘 적용된다(위 konet-notebook.css 는 노트북 전용 @media 라 큰 화면에서는 안 걸린다). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
