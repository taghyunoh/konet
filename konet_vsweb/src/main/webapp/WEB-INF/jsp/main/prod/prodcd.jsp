<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- 알림·확인은 프로젝트 공통 표준(ui-message.js) — Swal 신규 사용 금지 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<title>상품코드 등록 (TBL_PROD_MST)</title>
<%-- 상품코드 등록 (2026-08-01 신설)
     ★같은 마스터(TBL_PROD_MST)를 보는 '등록 전용' 화면이다 — 상품(품목)관리와 데이터·엔드포인트가 같다.
       상품(품목)관리는 하단 이력/재고 4탭이 붙은 무거운 화면이라, 코드만 빠르게 넣고 훑는 용도로 이 화면을 나눴다.
     ★서식은 매입/매출 거래처 관리(vendorMng.jsp)와 동일 : 추가·수정·삭제 버튼을 상단 공통 줄에 두고,
       그리드에는 행별 [수정]·[삭제] 버튼을 두지 않는다(행 클릭 = 선택, 더블클릭 = 수정). --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  body{ margin:0; font-family:'맑은 고딕',Malgun Gothic,sans-serif; color:#1f2a37; background:var(--bg); font-size:13px; }
  /* ★목록을 화면 아래까지 채운다(2026-08-01 요청) — [고정 머리(제목·검색줄·탭)] + [남는 공간 전부 = 목록] + [하단 페이지줄] 3층.
     페이지 안 행이 화면보다 많으면 목록 칸 안에서만 스크롤된다(머리글은 sticky 로 붙어 있음).
     종전에는 페이지 전체가 흐르는 구조라 목록 아래가 통째로 비어 보였다. */
  html,body{ height:100%; overflow:hidden; }
  .wrap{ padding:18px 20px 10px; height:100%; display:flex; flex-direction:column; min-height:0; }
  .wrap > h2, .wrap > .sub, .wrap > .bar, .wrap > .tabs, .wrap > .pager{ flex:0 0 auto; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:280px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:8px; color:#6b7a89; font-size:12.5px; }
  .tabs{ display:flex; gap:4px; margin-bottom:10px; border-bottom:2px solid #e2e8e6; }
  .tabs .t{ height:32px; padding:0 14px; border:1px solid #dfe6e3; border-bottom:none; background:#f1f5f4; border-radius:8px 8px 0 0; cursor:pointer; font-size:13px; font-weight:700; color:#5a6b7a; }
  .tabs .t.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  /* 남는 세로 공간을 목록이 다 먹는다 — 넘치는 행은 여기서만 스크롤(페이지 버튼은 항상 아래에 보인다) */
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; flex:1 1 auto; min-height:120px; }
  /* 스크롤해도 머리글은 남아야 한다. z-index 없으면 행이 머리글 위로 그려진다 */
  .card thead th{ position:sticky; top:0; z-index:3; }
  table{ width:100%; border-collapse:collapse; font-size:13px; font-weight:700; white-space:nowrap; }
  thead th{ background:#1f2a37; color:#fff; font-weight:700; padding:9px 10px; text-align:left; position:sticky; top:0; z-index:1; }
  thead th.r{ text-align:right; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:6px 10px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  tbody tr{ cursor:pointer; }
  tbody tr.sel td{ background:#dcefe9 !important; }
  td.code{ font-family:Consolas,monospace; }
  td.nm{ white-space:normal; min-width:220px; max-width:340px; }
  td.num{ text-align:right; }
  .tx{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; color:#fff; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  .pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin-top:14px; flex-wrap:wrap; }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  /* 하단 줄 — 보고 있는 범위·전체 건수 + [전체 펼치기/접기] */
  .pager .pinfo{ margin-right:10px; color:#5a6b7a; font-size:12.5px; }
  .pager .pinfo b{ color:#1f2a37; }
  .pager .pmore{ margin-left:10px; min-width:0; padding:0 12px; color:var(--teal); border-color:#a9d5cd; font-size:12.5px; }
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  #ov .box{ background:#fff; width:min(820px,94vw); margin-top:4vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:92vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:16px 18px; overflow:auto; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px; }
  #ov .fld{ display:flex; flex-direction:column; gap:4px; }
  #ov .fld.full{ grid-column:1 / -1; }
  #ov label{ font-size:13px; font-weight:500; color:#333; background:linear-gradient(135deg,#b3ddf0 0%,#d4ecf7 100%); border-radius:3px; padding:4px 10px; display:inline-flex; align-items:center; justify-content:flex-start; align-self:flex-start; min-width:104px; min-height:26px; white-space:nowrap; }
  #ov input, #ov select{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:14px; font-family:inherit; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
  /* ───────── 거래처 매칭코드 — 하단 도킹 패널 (상품(품목)관리의 이력/재고 패널과 같은 방식) ─────────
     높이는 한 곳(--mc-h)에서만 정한다. .wrap 높이와 어긋나면 목록 끝이 패널에 가린다. */
  :root{ --mc-h:34vh; }
  #mc{ position:fixed; left:0; right:0; bottom:0; height:var(--mc-h); min-height:250px; z-index:45; }
  #mc.min{ height:44px; min-height:0; }
  #mc .box{ background:#fff; width:100%; height:100%; border-radius:12px 12px 0 0; box-shadow:0 -10px 34px rgba(0,0,0,.18);
            border-top:2px solid var(--teal); display:flex; flex-direction:column; }
  #mc.min .mb2{ display:none; }
  #mc .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:8px 16px; border-radius:12px 12px 0 0;
           display:flex; align-items:center; gap:10px; }
  #mc .mh b{ font-size:14.5px; flex:0 0 auto; }
  #mc .mh .pick{ flex:1 1 auto; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
                 background:rgba(255,255,255,.16); border-radius:6px; padding:4px 10px; font-size:12.5px; }
  #mc .mh .x{ background:none; border:none; color:#fff; font-size:20px; cursor:pointer; flex:0 0 auto; }
  #mc .mb2{ flex:1 1 auto; min-height:0; display:flex; flex-direction:column; }
  #mc .tbwrap{ flex:1 1 auto; min-height:60px; overflow:auto; }
  #mc table{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  #mc thead th{ background:#eef3f2; color:#1f2a37; border:1px solid var(--bd); padding:7px 10px; text-align:left;
                position:sticky; top:0; z-index:3; font-size:12.5px; }
  #mc thead th.r{ text-align:right; }
  #mc tbody td{ border:1px solid var(--bd); padding:6px 10px; color:#10161d; }
  #mc tbody td.num{ text-align:right; }
  #mc tbody td.code{ font-family:Consolas,monospace; font-weight:700; }
  #mc .empty{ padding:18px; text-align:center; color:#9aa7b3; }
  /* 등록 줄 — 구두·문서로 받은 내용을 그대로 받아 적는 자리 */
  #mc .addbar{ flex:0 0 auto; border-top:1px solid var(--bd); background:#fafbfc; padding:9px 12px;
               display:flex; gap:6px; flex-wrap:wrap; align-items:flex-end; }
  #mc .addbar .f{ display:flex; flex-direction:column; gap:3px; }
  #mc .addbar label{ font-size:11px; font-weight:700; color:#6b7a89; }
  #mc .addbar input, #mc .addbar select{ height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; }
  #mc .addbar .grow{ flex:1 1 220px; }
  #mc .addbar .grow input{ width:100%; }
  #mc .addbar .btn{ height:32px; }
  /* 하단 패널 높이만큼 본문(스크롤 목록)이 짧아진다 — padding 이 아니라 높이로 뺀다 */
  .wrap{ height:calc(100% - var(--mc-h)); }
  .tag{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; background:#eef4ff; color:#274b8f; border:1px solid #c9d9f5; }
  .tag-n{ color:#9aa7b3; background:#f4f6f8; border-color:#e4e9ee; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🏷️ 상품코드 등록 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(상품마스터 · TBL_PROD_MST)</span></h2>
  <div class="sub">상품코드 조회 · 추가 · 수정 · 삭제 · 엑셀 — 상품(품목)관리와 같은 마스터입니다.
    매입가·판매가 이력과 재고(수불)는 <b>상품(품목)관리</b> 화면에서 봅니다.</div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·상품명·규격·제조사·유형·바코드 검색" onkeyup="pcFilter()">
    <button class="btn" onclick="pcLoad()">↻ 조회</button>
    <%-- 매칭 여부로 좁혀 보기 — 미매칭 목록이 곧 '그 코드로 오면 미매핑이 될 상품들' 이다 --%>
    <select id="fMc" onchange="pcFilter()" style="height:34px;border:1px solid var(--bd);border-radius:7px;padding:0 8px;font-size:13px;font-weight:700;color:#37475a"
            title="거래처 매칭코드를 붙여 둔 상품만 / 아직 안 붙인 상품만">
      <option value="">전체 (매칭 무관)</option>
      <option value="Y">매칭된 것만</option>
      <option value="N">미매칭만</option>
    </select>
    <button class="btn btn-teal" style="margin-left:auto" onclick="pcOpen()">＋ 상품코드 추가</button>
    <button class="btn" onclick="pcEditSel()">✎ 수정</button>
    <button class="btn btn-danger" onclick="pcDelSel()">🗑 삭제</button>
    <button class="btn" onclick="pcExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="tabs" id="taxTabs">
    <button class="t on" data-g=""     onclick="pcTab('')">전체</button>
    <button class="t"    data-g="과세" onclick="pcTab('과세')">과세</button>
    <button class="t"    data-g="면세" onclick="pcTab('면세')">면세</button>
  </div>

  <div class="card">
    <table>
      <thead><tr>
        <th>코드</th><th>상품명</th><th>규격</th><th>제조사</th><th>유형</th><th>과세</th>
        <th class="r">입수</th><th class="r">입고가</th><th class="r">판매가</th><th class="r">도매가</th>
        <th class="r">적정재고</th><th class="r">기본수량</th><th>낱개BC</th><th>박스BC</th><th>매칭</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="15" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
</div>

<%-- ───────── 거래처 매칭코드 — 하단 도킹 패널 (2026-08-01 요청) ─────────
     거래처(삼성 등)가 **구두·문서로** 알려 주는 품목코드·품목명을 그 상품에 붙여 둔다.
     ★진입은 언제나 '우리 상품이 먼저' 다 — 위에서 상품 줄을 고르고 여기에 받아 적는다.
       (자료가 엑셀로 오지 않으므로 대량 붙여넣기는 두지 않았다.)
     ★등록해 두면 발주현황표 업로드가 이 코드를 읽어 그 상품으로 해석한다 → 미매핑으로 안 잡힌다.
       등록이 없으면 종전과 완전히 같다 — 미매핑으로 남고 품목코드(매핑)·업로드 [연결](TBL_PROD_XREF)로 처리.
     ★여기 등록해도 상품이 새로 생기지 않는다. 있는 상품에 '이름표'를 더 붙이는 것이다. --%>
<div id="mc">
  <div class="box">
    <div class="mh">
      <b>🔖 거래처 매칭코드</b>
      <span class="pick" id="mcPick">위 목록에서 상품을 고르세요.</span>
      <%-- 전체 보기 — 고른 상품 것만이 아니라 등록된 매칭코드 전부를 상품코드·상품명과 함께 본다 --%>
      <button class="btn" id="mcAllBtn" style="height:26px;padding:0 10px;font-size:12px" onclick="mcAllToggle()"
              title="등록된 매칭코드를 전부 봅니다(상품코드·상품명 포함). 줄을 누르면 그 상품으로 갑니다.">📋 전체 보기</button>
      <button class="x" id="mcToggleBtn" onclick="mcToggle()" title="접기/펼치기">&#9662;</button>
    </div>
    <div class="mb2">
      <div class="tbwrap">
        <table>
          <thead id="mth"></thead>
          <tbody id="mtb"><tr><td colspan="8" class="empty">위 목록에서 상품 줄을 고르세요.</td></tr></tbody>
        </table>
      </div>
      <div class="addbar">
        <%-- 거래처를 고르지 않으면 빈 값으로 저장되고 목록에는 '신규코드'로 표시된다(어느 거래처에도 매이지 않는 코드) --%>
        <div class="f"><label>거래처</label><select id="a_ven" style="width:170px"><option value="">(해당없음)</option></select></div>
        <div class="f"><label>품목코드 *</label><input id="a_cd" style="width:130px" onkeydown="if(event.keyCode===13)mcAdd()"></div>
        <div class="f grow"><label>품목명</label><input id="a_nm" onkeydown="if(event.keyCode===13)mcAdd()"></div>
        <div class="f"><label>규격</label><input id="a_spec" style="width:110px"></div>
        <div class="f"><label>단위</label><input id="a_unit" style="width:70px" placeholder="BOX"></div>
        <div class="f"><label>단가</label><input id="a_price" type="number" step="0.01" style="width:100px"></div>
        <div class="f"><label>받은날</label><input id="a_noti" type="date" style="width:140px"></div>
        <div class="f"><label>비고</label><input id="a_remark" style="width:150px" placeholder="예) 담당자 구두통보"></div>
        <button class="btn btn-teal" id="a_addBtn" onclick="mcAdd()">＋ 등록</button>
        <span id="a_msg" style="align-self:center; font-size:12px; color:#6b7a89">상품을 고른 뒤 코드를 입력하세요.</span>
      </div>
    </div>
  </div>
</div>

<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">상품코드 추가</b><button class="x" onclick="pcClose()">&times;</button></div>
    <div class="mb">
      <input type="hidden" id="f_seq">
      <div class="fld"><label>상품코드 *</label><input id="f_cd" placeholder="예: 1000455367"></div>
      <div class="fld"><label>과세</label><select id="f_tax"><option value="과세">과세</option><option value="면세">면세</option></select></div>
      <div class="fld full"><label>상품명 *</label><input id="f_nm" placeholder="상품명"></div>
      <div class="fld full"><label>규격</label><input id="f_spec" placeholder="규격"></div>
      <div class="fld"><label>제조사명</label><input id="f_maker"></div>
      <div class="fld"><label>유형명</label><input id="f_type"></div>
      <div class="fld"><label>입수수량</label><input id="f_pack" type="number" value="1"></div>
      <div class="fld"><label>조회순서</label><input id="f_sort" type="number" value="999999"></div>
      <div class="fld"><label>입고단가</label><input id="f_in" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>판매단가</label><input id="f_sale" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>도매단가</label><input id="f_whole" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>적정재고</label><input id="f_safe" type="number" value="0"></div>
      <div class="fld"><label>판매기본수량</label><input id="f_base" type="number" value="0"></div>
      <div class="fld"><label>낱개바코드</label><input id="f_ubc"></div>
      <div class="fld"><label>박스바코드</label><input id="f_bbc"></div>
    </div>
    <div class="mf">
      <button class="btn" onclick="pcClose()">취소</button>
      <button class="btn btn-teal" onclick="pcSave()">💾 저장</button>
    </div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
/* 한 페이지 50행 — 목록이 화면 아래까지 늘어난 만큼 담는 양도 늘렸다(2026-08-01).
   화면보다 많으면 목록 칸 안에서 스크롤되고, 다 보고 나면 아래 페이지 버튼으로 넘어간다. */
var LIST=[], _view=[], _page=1, PAGE=50, _byseq={}, _tax='', _sel=null, _all=false;   // _all = 전체 펼침

function toast(s,t){ if(window._toast) window._toast(s, t||'info'); }
function confirmBox(msg, onOk){
  if(window._confirmBox){ window._confirmBox({ msg:msg, icon:'🗑️', okText:'삭제', onOk:onOk }); return; }
  if(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))) onOk();
}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function num(v){ return (v==null||v==='')?'':Number(v).toLocaleString(); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function gnum(id){ var v=gv(id); return v===''?null:Number(v); }

function pcLoad(){
  fetch(CTX+'/prod/prodList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.text(); })
    .then(function(txt){ var j; try{ j=JSON.parse(txt); }catch(e){ toast('목록 응답 오류','err'); return; }
      LIST=(j&&j.data)||[]; _byseq={}; LIST.forEach(function(o){ _byseq[o.prodSeq]=o; }); pcFilter();
    })
    .catch(function(e){ toast('통신오류: '+e.message,'err'); });
}
function pcTab(g){
  _tax=g;
  Array.prototype.forEach.call(document.querySelectorAll('#taxTabs .t'), function(b){ b.classList.toggle('on', b.getAttribute('data-g')===g); });
  pcFilter();
}
function pcFilter(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  var mc=(document.getElementById('fMc')||{}).value||'';
  _view=LIST.filter(function(o){
    if(_tax && (''+(o.taxGb||''))!==_tax) return false;
    // 매칭 필터 — _mcCnt 는 하단 [거래처 매칭코드] 를 읽을 때 채워진다(상품별 건수)
    if(mc==='Y' && !_mcCnt[o.prodSeq]) return false;
    if(mc==='N' &&  _mcCnt[o.prodSeq]) return false;
    if(!q) return true;
    return [o.prodCd,o.prodNm,o.spec,o.makerNm,o.typeNm,o.unitBarcode,o.boxBarcode]
      .some(function(v){ return (''+(v||'')).toLowerCase().indexOf(q)>=0; });
  });
  _page=1; pcRender();
}
function pcRender(){
  var tot=_view.length, pages=Math.max(1,Math.ceil(tot/PAGE)); if(_page>pages)_page=pages;
  document.getElementById('cnt').textContent=tot.toLocaleString()+'건 / 전체 '+LIST.length.toLocaleString()+'건';
  // ★_sel 은 지우지 않는다 — 매칭코드 등록 후 목록을 다시 그려도 고른 상품이 풀리면 안 된다
  //   (그 행이 이번 화면에 없으면 아래 복원에서 자연히 표시만 안 된다)
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="15" class="empty">데이터가 없습니다.</td></tr>'; _pager(0,1,0); return; }
  // 펼침(_all)이면 조회된 전 건을 한 번에 — 페이지 버튼 대신 목록 스크롤로 훑는다
  var from = _all ? 0 : (_page-1)*PAGE, to = _all ? tot : Math.min(from+PAGE, tot);
  tb.innerHTML=_view.slice(from,to).map(function(o){
    var c=(o.taxGb==='면세')?'#2e7d32':'#5a6b7a';
    return '<tr data-seq="'+o.prodSeq+'" onclick="pcSel(this,'+o.prodSeq+')" ondblclick="pcOpen('+o.prodSeq+')">'
      +'<td class="code">'+esc(o.prodCd)+'</td><td class="nm">'+esc(o.prodNm)+'</td>'
      +'<td>'+esc(o.spec)+'</td><td>'+esc(o.makerNm)+'</td><td>'+esc(o.typeNm)+'</td>'
      +'<td><span class="tx" style="background:'+c+'">'+esc(o.taxGb||'-')+'</span></td>'
      +'<td class="num">'+num(o.packQty)+'</td><td class="num">'+num(o.inPrice)+'</td>'
      +'<td class="num">'+num(o.salePrice)+'</td><td class="num">'+num(o.wholePrice)+'</td>'
      +'<td class="num">'+num(o.safeStock)+'</td><td class="num">'+num(o.saleBaseQty)+'</td>'
      +'<td>'+esc(o.unitBarcode)+'</td><td>'+esc(o.boxBarcode)+'</td>'
      // 매칭 = 이 상품에 붙여 둔 거래처 코드 수. 0이면 그 코드로 오는 자료는 미매핑이 된다
      +'<td>'+(_mcCnt[o.prodSeq] ? ('<span class="tag">'+_mcCnt[o.prodSeq]+'</span>') : '<span class="tag tag-n">0</span>')+'</td>'
    +'</tr>';
  }).join('');
  // 선택행 하이라이트 복원 — 매칭코드를 등록하면 목록을 다시 그리는데, 고른 상품 표시가 풀리면 안 된다
  if(_sel!=null){ var sr=tb.querySelector('tr[data-seq="'+_sel+'"]'); if(sr) sr.classList.add('sel'); }
  _pager(pages,_page,tot,from,to);
}
/* 페이지를 넘기면 목록 맨 위로 — 스크롤이 중간에 있던 채로 다음 장이 그려지면 첫 줄을 놓친다 */
function _go(p){ _page=p; pcRender(); var c=document.querySelector('.card'); if(c) c.scrollTop=0; }
function pcSel(tr,seq){
  var tb=document.getElementById('tb');
  Array.prototype.forEach.call(tb.querySelectorAll('tr.sel'),function(r){ r.classList.remove('sel'); });
  tr.classList.add('sel'); _sel=seq;
  mcPickProd(seq);           // 아래 [거래처 매칭코드] 패널을 이 상품으로 맞춘다
}
function pcEditSel(){ if(_sel==null){ toast('수정할 행을 먼저 선택하세요.','warn'); return; } pcOpen(_sel); }
function pcDelSel(){ if(_sel==null){ toast('삭제할 행을 먼저 선택하세요.','warn'); return; } pcDel(_sel); }
/* 하단 줄 = [보고 있는 범위 · 전체 건수] + [페이지 버튼] + [펼치기/접기] (2026-08-01 요청)
   펼치기 = 조회된 전 건을 한 화면에 붙여 스크롤로 훑는다(Ctrl+F 검색·전체 복사에도 쓴다). */
function _pager(pages,cur,tot,from,to){
  var el=document.getElementById('pager');
  if(!tot){ el.innerHTML=''; return; }
  var info = _all
    ? '<span class="pinfo">전체 <b>'+tot.toLocaleString()+'</b>건 펼침 — 목록을 스크롤하세요</span>'
    : '<span class="pinfo">'+(from+1).toLocaleString()+'~'+to.toLocaleString()+' / <b>'+tot.toLocaleString()+'</b>건</span>';
  var h='';
  if(!_all && pages>1){
    h+='<button '+(cur<=1?'disabled':'')+' onclick="_go('+(cur-1)+')">‹</button>';
    var f=Math.max(1,cur-3), t=Math.min(pages,cur+3);
    if(f>1){ h+='<button onclick="_go(1)">1</button>'; if(f>2)h+='<span class="ell">…</span>'; }
    for(var p=f;p<=t;p++) h+='<button class="'+(p===cur?'on':'')+'" onclick="_go('+p+')">'+p+'</button>';
    if(t<pages){ if(t<pages-1)h+='<span class="ell">…</span>'; h+='<button onclick="_go('+pages+')">'+pages+'</button>'; }
    h+='<button '+(cur>=pages?'disabled':'')+' onclick="_go('+(cur+1)+')">›</button>';
  }
  var btn = _all
    ? '<button class="pmore" onclick="pcCollapse()" title="한 페이지씩 보기로 돌아갑니다">▲ 접기</button>'
    : (tot>PAGE ? '<button class="pmore" onclick="pcExpand()" title="조회된 '+tot.toLocaleString()+'건을 한 번에 펼쳐 스크롤로 봅니다">▼ 전체 펼치기</button>' : '');
  el.innerHTML = info + h + btn;
}
function pcExpand(){ _all=true; pcRender(); var c=document.querySelector('.card'); if(c) c.scrollTop=0; }
function pcCollapse(){ _all=false; _page=1; pcRender(); var c=document.querySelector('.card'); if(c) c.scrollTop=0; }
function _set(id,v){ document.getElementById(id).value=(v==null?'':v); }
function pcOpen(seq){
  var o=(seq!=null)?_byseq[seq]:null;
  document.getElementById('ovTit').textContent=o?('상품코드 수정 — '+o.prodCd):'상품코드 추가';
  _set('f_seq', o?o.prodSeq:'');
  _set('f_cd', o?o.prodCd:''); document.getElementById('f_cd').readOnly=!!o;   // 수정 시 코드는 잠금
  _set('f_nm', o?o.prodNm:''); _set('f_spec', o?o.spec:'');
  _set('f_maker', o?o.makerNm:''); _set('f_type', o?o.typeNm:'');
  _set('f_tax', o?(o.taxGb||'과세'):'과세');
  _set('f_pack', o?(o.packQty!=null?o.packQty:1):1);
  _set('f_sort', o?(o.sortOrd!=null?o.sortOrd:999999):999999);
  _set('f_in', o?(o.inPrice!=null?o.inPrice:0):0);
  _set('f_sale', o?(o.salePrice!=null?o.salePrice:0):0);
  _set('f_whole', o?(o.wholePrice!=null?o.wholePrice:0):0);
  _set('f_safe', o?(o.safeStock!=null?o.safeStock:0):0);
  _set('f_base', o?(o.saleBaseQty!=null?o.saleBaseQty:0):0);
  _set('f_ubc', o?o.unitBarcode:''); _set('f_bbc', o?o.boxBarcode:'');
  document.getElementById('ov').classList.add('on');
}
function pcClose(){ document.getElementById('ov').classList.remove('on'); }
function pcSave(){
  var seq=gv('f_seq'), cd=gv('f_cd'), nm=gv('f_nm');
  if(!cd){ toast('상품코드를 입력하세요.','warn'); return; }
  if(!nm){ toast('상품명을 입력하세요.','warn'); return; }
  var dto={ prodCd:cd, prodNm:nm, spec:gv('f_spec')||null, makerNm:gv('f_maker')||null, typeNm:gv('f_type')||null,
    taxGb:gv('f_tax')||null, packQty:gnum('f_pack'), sortOrd:gnum('f_sort'),
    inPrice:gnum('f_in'), salePrice:gnum('f_sale'), wholePrice:gnum('f_whole'),
    safeStock:gnum('f_safe'), saleBaseQty:gnum('f_base'),
    unitBarcode:gv('f_ubc')||null, boxBarcode:gv('f_bbc')||null };
  var url, okmsg;
  if(seq){ dto.prodSeq=Number(seq); url='/prod/prodUpdate.do'; okmsg='💾 수정 완료'; }
  else   { url='/prod/prodInsert.do'; okmsg='＋ 등록 완료'; }
  fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('실패 (HTTP '+r.status+'): '+(r.t||'').slice(0,120),'err'); return; }
      pcClose(); toast(okmsg,'ok'); pcLoad(); })
    .catch(function(e){ toast('통신오류: '+e.message,'err'); });
}
function pcDel(seq){
  var o=_byseq[seq]; if(!o) return;
  confirmBox('['+esc(o.prodCd)+'] '+esc(o.prodNm||'')+'<br>삭제하시겠습니까? (이력 보존)', function(){
    fetch(CTX+'/prod/prodDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({prodSeq:Number(seq)}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
      .then(function(r){ if(!r.ok){ toast((r.t||'').trim() || ('삭제 실패 (HTTP '+r.status+')'), 'err'); return; }
        toast('🗑️ 삭제 완료','ok'); pcLoad(); })
      .catch(function(e){ toast('통신오류: '+e.message,'err'); });
  });
}

function pcExcel(){
  var list=_view; if(!list.length){ toast('출력할 데이터가 없습니다.','warn'); return; }
  var head=['코드','상품명','규격','제조사','유형','과세','입수수량','입고단가','판매단가','도매단가','적정재고','판매기본수량','낱개바코드','박스바코드','조회순서'];
  var aoa=[head].concat(list.map(function(o){ return [o.prodCd,o.prodNm,o.spec,o.makerNm,o.typeNm,o.taxGb,o.packQty,o.inPrice,o.salePrice,o.wholePrice,o.safeStock,o.saleBaseQty,o.unitBarcode,o.boxBarcode,o.sortOrd]; }));
  var P=window.parent;
  function byLib(LIB){
    var ws=LIB.utils.aoa_to_sheet(aoa);
    ws['!cols']=[{wch:14},{wch:44},{wch:16},{wch:14},{wch:16},{wch:6},{wch:8},{wch:11},{wch:11},{wch:11},{wch:9},{wch:9},{wch:16},{wch:16},{wch:9}];
    var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'상품코드'); LIB.writeFile(wb,'상품코드.xlsx');
    toast('📥 엑셀 저장 완료 · '+list.length+'건','ok');
  }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csv(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csv();
  function csv(){ var c=aoa.map(function(r){ return r.map(function(x){ x=(x==null?'':(''+x)); return '"'+x.replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var b=new Blob(['﻿'+c],{type:'text/csv;charset=utf-8'}), a=document.createElement('a');
    a.href=URL.createObjectURL(b); a.download='상품코드.csv'; document.body.appendChild(a); a.click(); a.remove();
    toast('📥 CSV 저장 완료','ok'); }
}
/* ==================== 거래처 매칭코드 (하단 패널) ====================
   거래처가 구두·문서로 알려 주는 코드·품명을 '고른 상품'에 붙인다.
   ★서버 표는 TBL_EXT_ITEM_MST. 업로드 해석이 이 표를 읽는다(XREF → 이 표 → 코드직결).
     붙여 둔 게 없으면 종전과 같다 — 미매핑으로 남고 품목코드(매핑)에서 연결. */
var MC=[], VEN=[], _mcCnt={}, _mcCur=null, _mcAll=false;   // _mcAll = 전체 보기 모드

function mcVendors(){
  fetch(CTX+'/vendor/selectVendorMst.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){ VEN=(j&&j.data)||[];
      document.getElementById('a_ven').innerHTML='<option value="">(해당없음)</option>'
        + VEN.map(function(v){ return '<option value="'+esc(v.vendorCd)+'">'+esc(v.vendorNm)+'</option>'; }).join('');
    }).catch(function(){});
}
function mcVenNm(cd){ for(var i=0;i<VEN.length;i++){ if(VEN[i].vendorCd===cd) return VEN[i].vendorNm; } return ''; }
function mcFmtDt(s){ s=(''+(s||'')); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function mcToday(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }

/* 전 건을 한 번에 읽는다 — 상품 목록의 [매칭] 개수에 필요하고 양이 작다 */
function mcLoad(keepList){
  fetch(CTX+'/prod/extItemList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){
      MC=(j&&j.data)||[]; _mcCnt={};
      MC.forEach(function(o){ if(o.prodSeq!=null) _mcCnt[o.prodSeq]=(_mcCnt[o.prodSeq]||0)+1; });
      if(!keepList){
        // 매칭 필터가 걸려 있으면 목록 자체가 바뀌므로 다시 거른다(그 외에는 보던 페이지 유지)
        if((document.getElementById('fMc')||{}).value) pcFilter(); else pcRender();
      }
      mcRender();
    })
    .catch(function(e){ toast('매칭코드 조회 오류: '+e.message,'err'); });
}
function mcPickProd(seq){
  _mcCur=_byseq[seq]||null;
  var el=document.getElementById('mcPick');
  if(!_mcCur){ el.textContent='위 목록에서 상품을 고르세요.'; mcRender(); return; }
  el.innerHTML='<b>'+esc(_mcCur.prodCd)+'</b> '+esc(_mcCur.prodNm||'')
    + (_mcCur.spec?(' · '+esc(_mcCur.spec)):'');
  document.getElementById('a_msg').textContent='이 상품에 거래처 코드를 붙입니다.';
  if(!gv('a_noti')) document.getElementById('a_noti').value=mcToday();
  if(document.getElementById('mc').classList.contains('min')) mcToggle();   // 접혀 있으면 펼친다
  mcRender();
}
/* 목록 그리기 — 모드 둘
     ① 이 상품만(기본) : 위에서 고른 상품에 붙여 둔 코드
     ② 전체 보기       : 등록된 매칭코드 전부 + 어느 상품인지(상품코드·상품명). 줄을 누르면 그 상품으로 간다.
   ★머리글이 모드마다 달라 thead(#mth)도 여기서 그린다 — 정적 thead 를 두면 칸 수가 어긋난다. */
function mcRender(){
  var th=document.getElementById('mth'), tb=document.getElementById('mtb');
  var HEAD_ONE='<tr><th style="width:150px">거래처</th><th style="width:130px">품목코드</th><th>품목명</th>'
    +'<th style="width:120px">규격</th><th class="r" style="width:90px">단가</th>'
    +'<th style="width:100px">받은날</th><th style="width:150px">비고</th><th style="width:64px">관리</th></tr>';
  var HEAD_ALL='<tr><th style="width:120px">상품코드</th><th style="width:230px">상품명</th>'
    +'<th style="width:150px">거래처</th><th style="width:130px">품목코드</th><th>품목명</th>'
    +'<th style="width:120px">규격</th><th class="r" style="width:90px">단가</th>'
    +'<th style="width:100px">받은날</th><th style="width:64px">관리</th></tr>';
  function row(o, all){
    // 거래처를 안 고른 줄 = 어느 거래처에도 매이지 않은 코드 → '신규코드'로 표시(값은 빈 값으로 저장)
    //   ★esc() 로 감싸면 태그가 글자로 보인다 — 태그는 밖에 두고 값만 esc 한다
    var vn=o.vendorNm||mcVenNm(o.vendorCd)||o.vendorCd||'';
    var h='<tr'+(all?(' style="cursor:pointer" onclick="mcGoProd('+o.prodSeq+')"'):'')+'>';
    if(all){ var p=_byseq[o.prodSeq]||{};
             h+='<td class="code">'+esc(o.prodCd||p.prodCd||'')+'</td><td>'+esc(p.prodNm||'')+'</td>'; }
    h+='<td>'+(vn ? esc(vn) : '<span style="color:#9aa7b3">신규코드</span>')+'</td>'
      +'<td class="code">'+esc(o.extItemCd)+'</td><td>'+esc(o.extItemNm)+'</td>'
      +'<td>'+esc(o.extSpec)+'</td><td class="num">'+num(o.extPrice)+'</td>'
      +'<td>'+esc(mcFmtDt(o.notiDt))+'</td>';
    if(!all) h+='<td>'+esc(o.remark)+'</td>';
    h+='<td><button class="btn btn-danger" style="height:26px;padding:0 9px;font-size:11.5px"'
      +' onclick="event.stopPropagation();mcDel('+o.extSeq+')">삭제</button></td></tr>';
    return h;
  }
  if(_mcAll){
    th.innerHTML=HEAD_ALL;
    tb.innerHTML = MC.length ? MC.map(function(o){ return row(o,true); }).join('')
                             : '<tr><td colspan="9" class="empty">등록된 매칭코드가 없습니다.</td></tr>';
    return;
  }
  th.innerHTML=HEAD_ONE;
  if(!_mcCur){ tb.innerHTML='<tr><td colspan="8" class="empty">위 목록에서 상품 줄을 고르세요.'
    +' <span style="color:#5a6b7a">— 등록된 것을 다 보려면 [📋 전체 보기]</span></td></tr>'; return; }
  var l=MC.filter(function(o){ return String(o.prodSeq)===String(_mcCur.prodSeq); });
  if(!l.length){ tb.innerHTML='<tr><td colspan="8" class="empty">이 상품에 붙여 둔 거래처 코드가 없습니다 — 아래에서 등록하세요.'
    +' <span style="color:#c0392b">(없으면 그 코드로 오는 자료는 미매핑이 됩니다)</span></td></tr>'; return; }
  tb.innerHTML=l.map(function(o){ return row(o,false); }).join('');
}
/* 전체 보기 토글 — 켜도 아래 등록 줄은 그대로 '고른 상품'에 붙는다(등록 대상이 바뀌지 않는다) */
function mcAllToggle(){
  _mcAll=!_mcAll;
  var b=document.getElementById('mcAllBtn');
  b.textContent=_mcAll?'📌 이 상품만':'📋 전체 보기';
  document.getElementById('mcPick').innerHTML=_mcAll
    ? '전체 <b>'+MC.length.toLocaleString()+'</b>건 — 줄을 누르면 그 상품으로 갑니다'
    : (_mcCur ? ('<b>'+esc(_mcCur.prodCd)+'</b> '+esc(_mcCur.prodNm||'')) : '위 목록에서 상품을 고르세요.');
  if(_mcAll && document.getElementById('mc').classList.contains('min')) mcToggle();
  mcRender();
}
/* 전체 보기에서 줄을 누르면 그 상품으로 — 위 목록의 선택 상태까지 맞춘다 */
function mcGoProd(seq){
  if(seq==null) return;
  _mcAll=false; document.getElementById('mcAllBtn').textContent='📋 전체 보기';
  _sel=seq; mcPickProd(seq);
  var sr=document.querySelector('#tb tr[data-seq="'+seq+'"]');
  if(sr){ Array.prototype.forEach.call(document.querySelectorAll('#tb tr.sel'),function(r){ r.classList.remove('sel'); });
          sr.classList.add('sel'); sr.scrollIntoView({block:'center'}); }
  else toast('이 상품은 지금 보고 있는 목록(페이지·필터) 밖에 있습니다.','warn');
}
/* ★두 번 눌리는 것을 막는다 (2026-08-01 증상: "이미 저장됐다고 뜨는데 조금 뒤 보면 등록돼 있음")
     저장은 과거 업로드분 소급 반영·재고 재계산까지 하느라 응답이 늦다. 그 사이 [등록]을 다시 누르거나
     Enter 를 또 치면 두 번째 요청이 **이미 저장된 코드**를 만나 409(이미 등록된 품목코드)로 튕겼다.
     첫 요청은 정상 저장되므로 잠시 뒤 목록에 나타난다 — 오류가 아니라 중복 제출이었다. */
var _mcSaving=false;
function _mcBusy(on){
  _mcSaving=on;
  var b=document.getElementById('a_addBtn');
  if(b){ b.disabled=on; b.textContent=on?'저장 중…':'＋ 등록'; b.style.opacity=on?'.6':''; }
}
function mcAdd(){
  if(_mcSaving) return;                      // 저장이 끝날 때까지는 받지 않는다
  if(!_mcCur){ toast('먼저 위 목록에서 상품을 고르세요.','warn'); return; }
  var cd=gv('a_cd');
  if(!cd){ toast('거래처가 부르는 품목코드를 입력하세요.','warn'); document.getElementById('a_cd').focus(); return; }
  var ven=gv('a_ven');
  var dto={ extItemCd:cd, extItemNm:gv('a_nm')||null, extSpec:gv('a_spec')||null, extUnit:gv('a_unit')||null,
    extPrice:gv('a_price')?Number(gv('a_price')):null,
    vendorCd:ven||null, vendorNm:ven?mcVenNm(ven):null,
    notiDt:gv('a_noti')||null, statGb:'신규', remark:gv('a_remark')||null,
    prodSeq:_mcCur.prodSeq, prodCd:_mcCur.prodCd };
  _mcBusy(true);
  fetch(CTX+'/prod/extItemSave.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){
      _mcBusy(false);
      if(!r.ok){ toast((r.t||'').trim()||('등록 실패 (HTTP '+r.status+')'),'err'); return; }
      // 연달아 받아 적는 흐름 — 코드·품명·규격·단가만 비우고 거래처·받은날은 남긴다
      _set('a_cd',''); _set('a_nm',''); _set('a_spec',''); _set('a_price','');
      toast('＋ 매칭코드 등록 — '+esc(cd),'ok');
      document.getElementById('a_cd').focus();
      mcLoad();
    })
    .catch(function(e){ _mcBusy(false); toast('통신오류: '+e.message,'err'); });
}
function mcDel(seq){
  var o=null; for(var i=0;i<MC.length;i++){ if(String(MC[i].extSeq)===String(seq)){ o=MC[i]; break; } }
  if(!o) return;
  confirmBox('['+esc(o.extItemCd)+'] '+esc(o.extItemNm||'')+'<br>이 매칭코드를 지우시겠습니까?'
    +'<br><span style="color:#9aa7b3;font-size:12px">지우면 이 코드로 오는 자료는 다시 미매핑이 됩니다.</span>', function(){
    fetch(CTX+'/prod/extItemDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({extSeq:Number(seq)}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
      .then(function(r){ if(!r.ok){ toast((r.t||'').trim()||'삭제 실패','err'); return; } toast('🗑️ 삭제 완료','ok'); mcLoad(); })
      .catch(function(e){ toast('통신오류: '+e.message,'err'); });
  });
}
/* 접기/펼치기 — 목록을 넓게 보고 싶을 때. 접으면 그만큼 위 목록이 늘어난다 */
function mcToggle(){
  var el=document.getElementById('mc'), min=el.classList.toggle('min');
  document.documentElement.style.setProperty('--mc-h', min ? '44px' : '34vh');
  document.getElementById('mcToggleBtn').innerHTML = min ? '&#9652;' : '&#9662;';
}

pcLoad(); mcVendors(); mcLoad(true);
</script>
</body>
</html>
