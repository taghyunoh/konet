<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style>
  /* SWAL 확인/알림 모달 축소 (토스트 제외) */
  .swal2-popup:not(.swal2-toast){ width:440px!important; padding:1.1em 1em 1.2em!important; font-size:14px; }
  .swal2-popup:not(.swal2-toast) .swal2-icon{ width:3em; height:3em; margin:.6em auto .3em; }
  .swal2-popup:not(.swal2-toast) .swal2-icon .swal2-icon-content{ font-size:1.8em; }
  .swal2-popup:not(.swal2-toast) .swal2-title{ font-size:1.2em; padding:.2em 1em 0; }
  .swal2-popup:not(.swal2-toast) .swal2-html-container{ font-size:.95em; margin:.5em 1em 0; }
  .swal2-popup:not(.swal2-toast) .swal2-actions{ margin-top:1em; }
  .swal2-popup:not(.swal2-toast) .swal2-styled{ padding:.5em 1.4em; font-size:.95em; }
</style>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>상품(품목) 관리 (TBL_PROD_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  body{ margin:0; font-family:'맑은 고딕',Malgun Gothic,sans-serif; color:#1f2a37; background:var(--bg); font-size:13px; }
  /* ★상단(제목·검색줄)은 고정, 목록만 스크롤(2026-07-22 요청).
     종전에는 페이지 전체가 스크롤돼서 내리면 검색창·＋상품 추가 버튼이 사라졌다.
     화면 = [고정 헤더] + [스크롤되는 목록] + [하단 도킹 패널] 3층 구조. */
  html,body{ height:100%; overflow:hidden; }
  .wrap{ padding:18px 20px 0; height:100%; box-sizing:border-box; display:flex; flex-direction:column; min-height:0; }
  .wrap > h2, .wrap > .sub, .wrap > .bar, .wrap > .pager{ flex:0 0 auto; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:260px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:auto; color:#6b7a89; font-size:12.5px; }
  /* 목록 카드 = 위(제목·검색줄)와 아래(이력/재고 패널) 사이를 채우고, 넘치는 행은 여기서만 스크롤.
     2026-07-25: 매출내역과 같이 18행씩 보여주고 스크롤하면 자동으로 이어붙인다(페이지 버튼 없음).
     그래서 flex 를 0 1 → 1 1 로 바꿨다 — 카드가 남는 공간을 다 차지해야 스크롤이 생기고 이어붙이기가 돈다. */
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; flex:1 1 auto; min-height:90px; }
  /* 이어붙이며 내려도 머리글은 남아야 한다(하단 패널 표와 동일 규칙). z-index 없으면 행이 머리글 위로 그려진다 */
  .card thead th{ position:sticky; top:0; z-index:3; }
  /* ★표 서식 = 매출내역(logistics_demo2 table.logi-tb)과 동일하게 맞춤(2026-07-22 요청)
       13px · 셀 padding 9px 10px · 실선 격자 · 가운데 정렬 · 연한 헤더(#eef3f2/진한 글자)
       숫자·상품명 등은 아래 개별 규칙으로 우/좌 정렬을 되돌린다 */
  table{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  thead th{ background:#eef3f2; color:#1f2a37; font-weight:700; border:1px solid var(--bd);
            padding:9px 10px; text-align:center; position:sticky; top:0; z-index:1; }
  tbody td{ border:1px solid var(--bd); padding:9px 10px; text-align:center; vertical-align:middle; color:#10161d; }
  tbody tr:hover td{ background:#f3f8f6; }
  tbody tr.prow{ cursor:pointer; }
  tbody tr.sel td{ background:#dcefe9 !important; box-shadow:inset 3px 0 0 var(--teal); }
  td.code{ font-family:Consolas,monospace; }
  td.num{ text-align:right; }
  td.nm{ white-space:normal; min-width:220px; max-width:340px; text-align:left; }
  td.txt-l, th.txt-l{ text-align:left; }
  .act .btn{ height:26px; padding:0 9px; font-size:11.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  #msg{ position:fixed; left:50%; bottom:26px; transform:translateX(-50%); background:#1f2a37; color:#fff; padding:10px 18px; border-radius:9px; font-size:13px; opacity:0; transition:opacity .2s; pointer-events:none; z-index:60; }
  #msg.on{ opacity:1; }
  .pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin:10px 0; flex-wrap:wrap; }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  /* 모달 */
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  #ov .box{ background:#fff; width:min(720px,94vw); margin-top:5vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:90vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:16px 18px; overflow:auto; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px; }
  #ov .fld{ display:flex; flex-direction:column; gap:4px; }
  #ov .fld.full{ grid-column:1 / -1; }
  #ov label{ font-size:12px; font-weight:700; color:#37475a; }
  #ov input, #ov select{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
  .btn-hist{ color:#137a6c; border-color:#a9d5cd; }
  /* 이력/재고 — 하단 상시 도킹 그리드(3탭 마스터-디테일) */
  /* 높이 = 한 곳에서만 정한다(#hv 와 .wrap 이 어긋나면 목록 끝이 패널에 가린다) — 2026-07-22 상향 34vh→48vh */
  :root{ --hv-h:48vh; }
  #hv{ position:fixed; left:0; right:0; bottom:0; height:var(--hv-h); min-height:330px; z-index:45; }
  #hv.min{ height:46px; min-height:0; }
  #hv .box{ background:#fff; width:100%; height:100%; border-radius:12px 12px 0 0; box-shadow:0 -10px 34px rgba(0,0,0,.22); border-top:2px solid var(--teal); display:flex; flex-direction:column; }
  #hv.min .tabs, #hv.min .mb2{ display:none; }
  #hv .mb2{ flex:1; }
  /* 하단 도킹 패널 높이만큼 본문(스크롤 목록)이 짧아진다 — padding 이 아니라 높이로 뺀다 */
  .wrap{ padding-bottom:0; height:calc(100% - var(--hv-h)); }
  /* 머리·탭 줄을 얇게 — 그만큼 실제 내용(입력줄+이력 목록)이 더 보인다 */
  #hv .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:9px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #hv .mh b{ font-size:14.5px; }
  #hv .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  /* 하단 패널에서 직접 품목 찾기 — 위 목록을 안 건드리고 대상 품목을 바꾼다 */
  #hv .mh .hvfind{ position:relative; margin-left:auto; margin-right:10px; }
  #hv .mh .hvfind input{ width:250px; height:30px; border:1px solid rgba(255,255,255,.45); border-radius:6px;
                         padding:0 10px; font-size:12.5px; background:rgba(255,255,255,.16); color:#fff; }
  #hv .mh .hvfind input::placeholder{ color:rgba(255,255,255,.75); }
  #hv .mh .hvfind input:focus{ outline:none; background:#fff; color:#1f2a37; border-color:#fff; }
  .hvfind-pop{ display:none; position:absolute; top:34px; right:0; width:460px; max-height:260px; overflow:auto; z-index:130;
               background:#fff; border:1px solid var(--bd); border-radius:8px; box-shadow:0 8px 24px rgba(31,42,55,.22); padding:4px; }
  .hvfind-pop.open{ display:block; }
  .hvfind-pop .it{ display:flex; gap:9px; align-items:center; padding:7px 10px; font-size:12.5px; color:#37475a;
                   cursor:pointer; border-radius:6px; white-space:nowrap; }
  .hvfind-pop .it:hover, .hvfind-pop .it.cur{ background:#e3f4ef; color:#0e6657; }
  .hvfind-pop .it .cd{ flex:0 0 auto; font-weight:700; color:#178074; }
  .hvfind-pop .it .nm{ flex:1 1 auto; overflow:hidden; text-overflow:ellipsis; }
  .hvfind-pop .none{ padding:12px; text-align:center; color:#9aa7b3; font-size:12.5px; }
  #hv .tabs{ display:flex; gap:4px; padding:6px 14px 0; border-bottom:1px solid var(--bd); }
  #hv .tab{ height:34px; padding:0 16px; border:1px solid var(--bd); border-bottom:none; background:#f1f5f4; border-radius:8px 8px 0 0; cursor:pointer; font-size:13px; font-weight:700; color:#5a6b7a; }
  #hv .tab.on{ background:#fff; color:var(--teal); border-color:var(--teal); border-bottom:2px solid #fff; margin-bottom:-1px; }
  /* ★목록만 스크롤하고 현재고 요약·입력줄·표 머리글은 항상 보이게(2026-07-22).
     종전에는 .mb2 통째로 스크롤돼서 스크롤 내리면 입력폼과 헤더가 같이 사라졌다. */
  #hv .mb2{ padding:10px 16px 14px; overflow:hidden; display:flex; flex-direction:column; min-height:0; }
  #hv .panel{ flex-direction:column; min-height:0; flex:1 1 auto; }   /* display 는 JS가 flex/none 으로 토글 */
  #hv .panel > .stockhdr, #hv .panel > .subbar{ flex:0 0 auto; }
  #hv .tbwrap{ flex:1 1 auto; min-height:110px; overflow:auto; }      /* 여기만 스크롤 */
  #hv .stockhdr{ display:flex; gap:18px; flex-wrap:wrap; background:#f3f8f6; border:1px solid #cfe4df; border-radius:8px; padding:10px 14px; margin-bottom:12px; font-size:13px; }
  #hv .stockhdr b{ font-size:17px; color:var(--teal); }
  #hv .subbar{ display:flex; gap:6px; align-items:flex-end; flex-wrap:wrap; background:#fafbfc; border:1px solid var(--bd); border-radius:8px; padding:10px; margin-bottom:10px; }
  #hv .subbar .fld{ display:flex; flex-direction:column; gap:3px; }
  #hv .subbar label{ font-size:11px; font-weight:700; color:#6b7a89; }
  #hv .subbar input, #hv .subbar select{ height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; }
  #hv table{ width:100%; border-collapse:collapse; font-size:13px; }
  /* 하단 패널 표도 매출내역과 같은 서식. z-index 없으면 스크롤된 행이 머리글 위로 그려져 '고정 안 된 것'처럼 보인다 */
  #hv thead th{ background:#eef3f2; color:#1f2a37; border:1px solid var(--bd); padding:9px 10px;
                text-align:center; position:sticky; top:0; z-index:3; }
  #hv tbody td{ border:1px solid var(--bd); padding:9px 10px; text-align:center; color:#10161d; }
  #hv td.num{ text-align:right; }
  #hv .badge{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; color:#fff; }
  #hv .empty{ padding:20px; text-align:center; color:#9aa7b3; }
  /* 거래처 콤보(선택 안에 찾기) — 버튼 클릭 → 드롭다운(검색창 + 목록) */
  .vsel{ position:relative; width:200px; }
  .vsel-btn{ width:100%; height:32px; border:1px solid #dbe2ea; border-radius:6px; background:#fff; text-align:left;
             padding:0 26px 0 10px; font-size:13px; color:#1f2a37; cursor:pointer; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; }
  .vsel-btn:after{ content:'▾'; position:absolute; right:9px; top:6px; color:#8a97a5; font-size:12px; }
  .vsel-btn.empty{ color:#9aa7b3; }
  /* 드롭다운은 fixed — 이력/재고 패널(.mb2 overflow:auto)에 잘리지 않게 뷰포트 기준으로 띄운다. 좌표는 JS 가 버튼 위치로 셋팅 */
  .vsel-dd{ display:none; position:fixed; z-index:120; width:280px;
            background:#fff; border:1px solid #cfd8e0; border-radius:8px; box-shadow:0 8px 24px rgba(20,35,50,.22); }
  .vsel-dd.on{ display:block; }
  .vsel-dd .q{ width:calc(100% - 16px); margin:8px; height:30px; border:1px solid #dbe2ea; border-radius:6px; padding:0 9px; font-size:12.5px; }
  .vsel-list{ max-height:280px; overflow:auto; border-top:1px solid #eef1f5; }
  .vsel-list .it{ padding:7px 11px; cursor:pointer; font-size:12.5px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .vsel-list .it:hover{ background:#f3f8f6; }
  .vsel-list .it.on{ background:#e6f2ef; font-weight:700; }
  .vsel-list .it .cd{ color:#9aa7b3; font-size:11px; margin-left:5px; }
  .vsel-list .none{ padding:12px; text-align:center; color:#9aa7b3; font-size:12px; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📦 상품(품목) 관리</h2>
  <div class="sub">상품마스터(TBL_PROD_MST) 조회 · 추가 · 수정 · 삭제 · 엑셀출력</div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·상품명·규격·제조사·유형 검색" oninput="prodFilter()">
    <button class="btn" onclick="prodLoad()">↻ 새로고침</button>
    <button class="btn btn-teal" onclick="prodOpen()">＋ 상품 추가</button>
    <button class="btn" onclick="prodExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="card">
    <table>
      <thead><tr>
        <th>코드</th><th>상품명</th><th>규격</th><th>제조사</th><th>유형</th><th>과세</th>
        <th style="text-align:right">입수</th><th style="text-align:right">입고가</th><th style="text-align:right">판매가</th><th style="text-align:right">도매가</th>
        <th style="text-align:right">적정재고</th><th style="text-align:right">기본수량</th><th>낱개BC</th><th>박스BC</th><th style="width:120px">관리</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="15" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
</div>
<div id="msg"></div>

<!-- 추가/수정 모달 -->
<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">상품 추가</b><button class="x" onclick="prodClose()">&times;</button></div>
    <div class="mb">
      <input type="hidden" id="f_seq">
      <div class="fld"><label>코드 *</label><input id="f_cd" placeholder="예: 1000455367"></div>
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
      <button class="btn" onclick="prodClose()">취소</button>
      <button class="btn btn-teal" onclick="prodSave()">💾 저장</button>
    </div>
  </div>
</div>

<!-- 이력/재고 모달 -->
<div id="hv">
  <div class="box">
    <div class="mh">
      <b id="hvTit">이력/재고 · <span style="font-weight:400">아래 <u>품목 찾기</u>에 입력하거나, 위 목록에서 품목 행을 클릭하세요</span></b>
      <!-- 하단에서 직접 품목을 찾아 바꿔 끼운다 — 위 목록을 스크롤/재조회하지 않아도 된다(2026-07-22) -->
      <div class="hvfind" id="hvFindWrap">
        <input id="hvFind" placeholder="🔎 품목 찾기 (코드·품목명)" autocomplete="off"
               onfocus="hvFindRun()" oninput="hvFindRun()" onkeydown="hvFindKey(event)"
               title="코드나 품목명 일부를 입력하면 아래에 후보가 뜹니다.&#10;↑↓ 이동 · Enter 선택 · Esc 닫기">
        <div class="hvfind-pop" id="hvFindPop"></div>
      </div>
      <button class="x" id="hvToggleBtn" onclick="hvToggle()" title="접기/펼치기">&#9662;</button>
    </div>
    <div class="tabs">
      <button class="tab on" id="tab_in"    onclick="hvTab('in')">💰 매입가</button>
      <button class="tab"    id="tab_sale"  onclick="hvTab('sale')">🏷️ 판매가</button>
      <button class="tab"    id="tab_sales" onclick="hvTab('sales')">🧾 매출단가(조회)</button>
      <button class="tab"    id="tab_stock" onclick="hvTab('stock')">📦 재고(수불)</button>
    </div>
    <div class="mb2">
      <!-- 매입가 -->
      <div class="panel" id="p_in">
        <div class="subbar">
          <div class="fld"><label>적용일</label><input type="date" id="in_dt"></div>
          <div class="fld"><label>매입처</label>
            <div class="vsel" id="in_vendor_box">
              <input type="hidden" id="in_vendor">
              <button type="button" class="vsel-btn empty" id="in_vendor_btn" onclick="vselOpen('in_vendor')" title="클릭 후 검색해서 선택 (거래처 마스터의 매입 거래처)">(선택)</button>
              <div class="vsel-dd" id="in_vendor_dd">
                <input type="text" class="q" id="in_vendor_q" placeholder="🔎 이름·코드 찾기" autocomplete="off" oninput="vselFilter('in_vendor')" onkeydown="vselKey(event,'in_vendor')">
                <div class="vsel-list" id="in_vendor_list"></div>
              </div>
            </div></div>
          <div class="fld"><label>매입단가</label><input type="number" id="in_price" step="0.01" style="width:110px" value="0"></div>
          <div class="fld"><label>비고</label><input type="text" id="in_remark" style="width:180px"></div>
          <button class="btn btn-teal" onclick="hvAddIn()">＋ 추가</button>
        </div>
        <div class="tbwrap">
        <table>
          <thead><tr><th>적용일</th><th>매입처</th><th style="text-align:right">매입단가</th><th style="text-align:right">직전가</th><th>비고</th><th>등록</th><th style="width:56px"></th></tr></thead>
          <tbody id="in_tb"><tr><td colspan="7" class="empty">-</td></tr></tbody>
        </table>
        </div>
      </div>
      <!-- 판매가 -->
      <div class="panel" id="p_sale" style="display:none">
        <div class="subbar">
          <div class="fld"><label>적용일</label><input type="date" id="sl_dt"></div>
          <div class="fld"><label>판매처 <span style="color:#9aa7b3;font-weight:400">(비우면 공통가)</span></label>
            <div class="vsel" id="sl_vendor_box">
              <input type="hidden" id="sl_vendor">
              <button type="button" class="vsel-btn empty" id="sl_vendor_btn" onclick="vselOpen('sl_vendor')" title="거래처 마스터의 매출 거래처 — 비우면 공통(기본) 판매가, 선택하면 그 판매처 전용가">(공통가)</button>
              <div class="vsel-dd" id="sl_vendor_dd">
                <input type="text" class="q" id="sl_vendor_q" placeholder="🔎 이름·코드 찾기" autocomplete="off" oninput="vselFilter('sl_vendor')" onkeydown="vselKey(event,'sl_vendor')">
                <div class="vsel-list" id="sl_vendor_list"></div>
              </div>
            </div></div>
          <div class="fld"><label>판매단가</label><input type="number" id="sl_price" step="0.01" style="width:110px" value="0"></div>
          <div class="fld"><label>도매단가</label><input type="number" id="sl_whole" step="0.01" style="width:110px" value="0"></div>
          <div class="fld"><label>비고</label><input type="text" id="sl_remark" style="width:180px"></div>
          <button class="btn btn-teal" onclick="hvAddSale()">＋ 추가</button>
        </div>
        <div class="tbwrap">
        <table>
          <thead><tr><th>적용일</th><th>판매처</th><th style="text-align:right">판매가</th><th style="text-align:right">도매가</th><th style="text-align:right">기준매입</th><th style="text-align:right">마진율</th><th>비고</th><th>등록</th><th style="width:56px"></th></tr></thead>
          <tbody id="sl_tb"><tr><td colspan="9" class="empty">-</td></tr></tbody>
        </table>
        </div>
      </div>
      <!-- 매출단가(조회) — 매출 확정내역(TBL_SALES_MST, 발주서 업로드분)의 실제 판매단가. 조회 전용 -->
      <div class="panel" id="p_sales" style="display:none">
        <div class="stockhdr" id="ss_hdr">매출 확정내역(발주서 업로드분)의 실제 판매단가 — 조회 전용. 입력·삭제는 견적서관리 ▸ 매출 엑셀 업로드에서.</div>
        <div class="tbwrap">
        <table>
          <thead><tr><th>납품일자</th><th>출고장</th><th>발주번호</th><th style="text-align:right">판매단가</th><th style="text-align:right">출고량</th><th style="text-align:right">매출액</th><th>원본파일</th></tr></thead>
          <tbody id="ss_tb"><tr><td colspan="7" class="empty">-</td></tr></tbody>
        </table>
        </div>
      </div>
      <!-- 재고 -->
      <div class="panel" id="p_stock" style="display:none">
        <div class="stockhdr" id="st_hdr">현재고 정보 없음</div>
        <div class="subbar">
          <div class="fld"><label>거래일</label><input type="date" id="st_dt"></div>
          <div class="fld"><label>구분</label>
            <select id="st_io" onchange="hvStockPrefill(true)">
              <option value="I">입고(+)</option><option value="O">출고(-)</option>
              <option value="R">반품(+)</option><option value="A">조정(±)</option>
            </select>
          </div>
          <div class="fld"><label>수량</label><input type="number" id="st_qty" style="width:90px" value="0" oninput="hvStockPrefill(false)"></div>
          <div class="fld"><label>단가 <span style="color:#9aa7b3;font-weight:400">(자동·수정가능)</span></label><input type="number" id="st_price" step="0.01" style="width:110px" value="0" title="품목 입고가 자동표시 · 수정 가능"></div>
          <div class="fld"><label>매입처</label>
            <div class="vsel" id="st_vendor_box">
              <input type="hidden" id="st_vendor">
              <button type="button" class="vsel-btn empty" id="st_vendor_btn" onclick="vselOpen('st_vendor')" title="클릭 후 검색해서 선택 (거래처 마스터의 매입 거래처 — 입고 시)">(선택)</button>
              <div class="vsel-dd" id="st_vendor_dd">
                <input type="text" class="q" id="st_vendor_q" placeholder="🔎 이름·코드 찾기" autocomplete="off" oninput="vselFilter('st_vendor')" onkeydown="vselKey(event,'st_vendor')">
                <div class="vsel-list" id="st_vendor_list"></div>
              </div>
            </div></div>
          <div class="fld"><label>비고</label><input type="text" id="st_remark" style="width:150px"></div>
          <button class="btn btn-teal" onclick="hvAddStock()">＋ 추가</button>
        </div>
        <div class="tbwrap">
        <table>
          <thead><tr><th>거래일</th><th>구분</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>매입처</th><th>비고</th><th>등록</th><th style="width:56px"></th></tr></thead>
          <tbody id="st_tb"><tr><td colspan="9" class="empty">-</td></tr></tbody>
        </table>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
/* 한 페이지 6행 — 하단 이력/재고 패널(48vh)과 나눠 쓰므로 목록은 짧게 두고 페이징으로 넘긴다(2026-07-22 요청) */
/* 목록 표시 — 한 번에 18행, 나머지는 스크롤이 바닥에 닿으면 자동으로 이어붙인다(2026-07-25 요청. 매출내역과 동일 방식).
   종전에는 6행씩 페이지 버튼(1 2 3 … 324)으로 넘겼다. _shown = 지금까지 붙인 행수. */
var PROD = [], _view = [], PAGE_SIZE = 18, _shown = 0, _byseq = {};

function toast(s){ if(window.Swal){ Swal.fire({toast:true, position:'top-end', html:s, showConfirmButton:false, timer:2600, timerProgressBar:true}); return; } var m=document.getElementById('msg'); m.innerHTML=s; m.classList.add('on'); clearTimeout(m._t); m._t=setTimeout(function(){ m.classList.remove('on'); }, 2600); }
function swConfirm(msg, title){ if(window.Swal) return Swal.fire({title:title||'확인', html:msg, icon:'question', showCancelButton:true, confirmButtonText:'확인', cancelButtonText:'취소', confirmButtonColor:'#137a6c', cancelButtonColor:'#94a3b8'}).then(function(r){ return r.isConfirmed; }); return Promise.resolve(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))); }
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function num(v){ return (v==null||v==='')?'':Number(v).toLocaleString(); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function gnum(id){ var v=gv(id); return v===''?null:Number(v); }

function prodLoad(){
  fetch(CTX+'/prod/prodList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.text(); })
    .then(function(txt){ var j; try{ j=JSON.parse(txt); }catch(e){ toast('⚠️ 목록 응답 오류'); return; }
      PROD=(j&&j.data)||[]; _byseq={}; PROD.forEach(function(o){ _byseq[o.prodSeq]=o; });
      prodFilter();
    })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function prodFilter(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  _view = !q ? PROD.slice() : PROD.filter(function(o){
    return [o.prodCd,o.prodNm,o.spec,o.makerNm,o.typeNm].some(function(x){ return (''+(x||'')).toLowerCase().indexOf(q)>=0; });
  });
  prodRender();
}
function _prow(o){
  return '<tr class="prow" onclick="hvOpen('+o.prodSeq+')" data-seq="'+o.prodSeq+'">'
    +'<td class="code">'+esc(o.prodCd)+'</td>'
    +'<td class="nm">'+esc(o.prodNm)+'</td>'
    +'<td>'+esc(o.spec)+'</td><td>'+esc(o.makerNm)+'</td><td>'+esc(o.typeNm)+'</td><td>'+esc(o.taxGb)+'</td>'
    +'<td class="num">'+num(o.packQty)+'</td><td class="num">'+num(o.inPrice)+'</td><td class="num">'+num(o.salePrice)+'</td><td class="num">'+num(o.wholePrice)+'</td>'
    +'<td class="num">'+num(o.safeStock)+'</td><td class="num">'+num(o.saleBaseQty)+'</td>'
    +'<td>'+esc(o.unitBarcode)+'</td><td>'+esc(o.boxBarcode)+'</td>'
    +'<td class="act"><button class="btn" onclick="event.stopPropagation();prodOpen('+o.prodSeq+')">수정</button> <button class="btn btn-danger" onclick="event.stopPropagation();prodDel('+o.prodSeq+')">삭제</button></td>'
  +'</tr>';
}
function _selKeep(){   // 선택행 하이라이트 유지 — 새로 붙인 행에 그 품목이 있을 수 있어 이어붙일 때마다 다시 건다
  if(typeof HVP==='undefined' || !HVP) return;
  var sr=document.querySelector('#tb tr.prow[data-seq="'+HVP.prodSeq+'"]'); if(sr) sr.classList.add('sel');
}
function prodRender(){
  var tot=_view.length;
  document.getElementById('cnt').textContent = tot.toLocaleString()+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="15" class="empty">데이터가 없습니다.</td></tr>'; _shown=0; _info(); return; }
  _shown=Math.min(PAGE_SIZE, tot);
  tb.innerHTML=_view.slice(0,_shown).map(_prow).join('');
  _selKeep(); _bindMore();
  _fillUntilScrollable();
  _info();
}
function _card(){ return document.querySelector('.card'); }
function _more(n){   // 다음 n행(기본 18) 이어붙이기
  var tot=_view.length; if(_shown>=tot) return;
  var to=Math.min(_shown+(n||PAGE_SIZE), tot), tb=document.getElementById('tb');
  if(!tb) return;
  tb.insertAdjacentHTML('beforeend', _view.slice(_shown,to).map(_prow).join(''));
  _shown=to; _selKeep(); _info();
}
// 18행이 카드 높이보다 짧으면 스크롤이 안 생겨 영영 안 채워진다 — 스크롤이 생길 때까지 미리 붙인다
function _fillUntilScrollable(){
  var c=_card(); if(!c) return;
  for(var g=0; _shown<_view.length && c.scrollHeight<=c.clientHeight+2 && g<300; g++) _more();
}
function _bindMore(){
  var c=_card(); if(!c || c._moreBound) return; c._moreBound=1;
  c.addEventListener('scroll', function(){
    if(_shown>=_view.length) return;
    if(c.scrollTop+c.clientHeight >= c.scrollHeight-60) _more();   // 바닥 60px 전에 미리 채운다
  });
  window.addEventListener('resize', _fillUntilScrollable);
}
function _showAll(){ _more(_view.length); }   // 남은 행 한 번에 (Ctrl+F 검색·전체 복사용)
function _info(){
  var el=document.getElementById('pager'), tot=_view.length;
  if(_shown>=tot){ el.innerHTML = tot>PAGE_SIZE
      ? '<span style="color:#9aa7b3;font-size:12px">총 '+tot.toLocaleString()+'건 — 모두 표시됨</span>' : '';
    return; }
  el.innerHTML='<span style="color:#5a6b7a;font-size:12px">'+_shown.toLocaleString()+' / <b>'+tot.toLocaleString()+'</b>건'
    +' <span style="color:#9aa7b3">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    +' <button class="btn" style="height:26px;margin-left:8px;font-size:12px" onclick="_showAll()" title="남은 행을 한 번에 펼칩니다(검색·복사용)">모두 표시</button>';
}

function prodOpen(seq){
  var o = seq!=null ? _byseq[seq] : null;
  document.getElementById('ovTit').textContent = o ? '상품 수정' : '상품 추가';
  document.getElementById('f_seq').value = o ? o.prodSeq : '';
  document.getElementById('f_cd').value = o ? (o.prodCd||'') : '';
  document.getElementById('f_cd').readOnly = !!o;   // 수정 시 코드는 잠금(원하면 해제 가능)
  document.getElementById('f_nm').value = o ? (o.prodNm||'') : '';
  document.getElementById('f_spec').value = o ? (o.spec||'') : '';
  document.getElementById('f_maker').value = o ? (o.makerNm||'') : '';
  document.getElementById('f_type').value = o ? (o.typeNm||'') : '';
  document.getElementById('f_tax').value = o ? (o.taxGb||'과세') : '과세';
  document.getElementById('f_pack').value = o ? (o.packQty!=null?o.packQty:1) : 1;
  document.getElementById('f_sort').value = o ? (o.sortOrd!=null?o.sortOrd:999999) : 999999;
  document.getElementById('f_in').value = o ? (o.inPrice!=null?o.inPrice:0) : 0;
  document.getElementById('f_sale').value = o ? (o.salePrice!=null?o.salePrice:0) : 0;
  document.getElementById('f_whole').value = o ? (o.wholePrice!=null?o.wholePrice:0) : 0;
  document.getElementById('f_safe').value = o ? (o.safeStock!=null?o.safeStock:0) : 0;
  document.getElementById('f_base').value = o ? (o.saleBaseQty!=null?o.saleBaseQty:0) : 0;
  document.getElementById('f_ubc').value = o ? (o.unitBarcode||'') : '';
  document.getElementById('f_bbc').value = o ? (o.boxBarcode||'') : '';
  document.getElementById('ov').classList.add('on');
}
function prodClose(){ document.getElementById('ov').classList.remove('on'); }

function prodSave(){
  var seq=gv('f_seq'), cd=gv('f_cd'), nm=gv('f_nm');
  if(!cd){ toast('⚠️ 코드를 입력하세요.'); return; }
  if(!nm){ toast('⚠️ 상품명을 입력하세요.'); return; }
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
    .then(function(r){ if(!r.ok){ toast('⚠️ 실패 (HTTP '+r.status+'): '+(r.t||'').slice(0,120)); return; } prodClose(); toast(okmsg); prodLoad(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function prodDel(seq){
  var o=_byseq[seq]; if(!o) return;
  swConfirm('['+esc(o.prodCd)+'] '+esc(o.prodNm||'')+'<br>삭제하시겠습니까? (이력 보존)','상품 삭제').then(function(ok){ if(!ok) return;
    fetch(CTX+'/prod/prodDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({prodSeq:Number(seq)}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
      .then(function(r){ if(!r.ok){ toast('⚠️ '+((r.t||'').trim() || ('삭제 실패 (HTTP '+r.status+')'))); return; } toast('🗑️ 삭제 완료'); prodLoad(); })
      .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
  });
}

function prodExcel(){
  var list=_view;
  if(!list.length){ toast('⚠️ 출력할 데이터가 없습니다.'); return; }
  var head=['코드','상품명','규격','제조사','유형','과세','입수수량','입고단가','판매단가','도매단가','적정재고','판매기본수량','낱개바코드','박스바코드','조회순서'];
  var aoa=[head].concat(list.map(function(o){ return [o.prodCd,o.prodNm,o.spec,o.makerNm,o.typeNm,o.taxGb,o.packQty,o.inPrice,o.salePrice,o.wholePrice,o.safeStock,o.saleBaseQty,o.unitBarcode,o.boxBarcode,o.sortOrd]; }));
  var P=window.parent;
  function byLib(LIB){
    var ws=LIB.utils.aoa_to_sheet(aoa);
    ws['!cols']=[{wch:14},{wch:44},{wch:16},{wch:14},{wch:16},{wch:6},{wch:8},{wch:11},{wch:11},{wch:11},{wch:9},{wch:9},{wch:16},{wch:16},{wch:9}];
    var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'상품마스터'); LIB.writeFile(wb,'상품마스터.xlsx'); toast('📥 엑셀 저장 완료 · '+list.length+'건');
  }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csvFallback(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csvFallback();
  function csvFallback(){
    var csv=aoa.map(function(r){ return r.map(function(c){ c=(c==null?'':(''+c)); return '"'+c.replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var blob=new Blob(['﻿'+csv],{type:'text/csv;charset=utf-8'}); var a=document.createElement('a');
    a.href=URL.createObjectURL(blob); a.download='상품마스터.csv'; document.body.appendChild(a); a.click(); a.remove();
    toast('📥 CSV 저장 완료 · '+list.length+'건');
  }
}

/* ==================== 이력/재고 모달 ==================== */
var HVP = null;        // 현재 선택 품목 {prodSeq, prodCd, prodNm}
var IO_MAP = { I:'입고', O:'출고', R:'반품', A:'조정' };
var IO_COLOR = { I:'#2e7d32', O:'#c0392b', R:'#8e44ad', A:'#7f8c9a' };

function today(){ var d=new Date(); var m=('0'+(d.getMonth()+1)).slice(-2), da=('0'+d.getDate()).slice(-2); return d.getFullYear()+'-'+m+'-'+da; }
function fmtDt(s){ s=(''+(s||'')); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }

function _post(url, dto){
  return fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); });
}
function _listPost(url, prodSeq){
  return fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'prodSeq='+encodeURIComponent(prodSeq) })
    .then(function(r){ return r.text(); }).then(function(t){ try{ return JSON.parse(t); }catch(e){ return null; } });
}

var HVT = 'in';   // 현재 선택된 탭(품목 바꿔도 유지)
function hvOpen(seq){
  HVP = _byseq[seq]; if(!HVP){ toast('⚠️ 품목 정보 없음'); return; }
  var el=document.getElementById('hv'); el.classList.remove('min');           // 접혀 있으면 펼침
  document.getElementById('hvToggleBtn').innerHTML='▾';
  document.getElementById('hvTit').innerHTML = '이력/재고 · <b style="font-weight:400">['+esc(HVP.prodCd)+'] '+esc(HVP.prodNm||'')+'</b>';
  document.getElementById('in_dt').value = today();
  document.getElementById('sl_dt').value = today();
  document.getElementById('st_dt').value = today();
  hvStockPrefill(true);   // 재고 입고 단가 = 품목마스터 입고가 자동채움
  Array.prototype.forEach.call(document.querySelectorAll('#tb tr.prow'), function(tr){   // 선택 행 하이라이트
    tr.classList.toggle('sel', tr.getAttribute('data-seq')===String(seq));
  });
  hvTab(HVT);
}
function hvToggle(){
  var el=document.getElementById('hv'); el.classList.toggle('min');
  document.getElementById('hvToggleBtn').innerHTML = el.classList.contains('min')?'▴':'▾';
}

/* ── 하단 패널에서 직접 품목 찾기 (2026-07-22) ─────────────────────────────
   종전에는 위 목록에서 행을 클릭해야만 대상이 바뀌어서, 다른 품목을 보려면
   목록을 다시 검색·페이지 이동해야 했다. 여기서 바로 찾아 바꿔 끼운다.
   · 검색 대상 = 이미 받아둔 PROD 전량(서버 재조회 없음)
   · 위 목록에 없는(다른 페이지) 품목도 잡히면 hvPick 이 그 페이지로 이동시킨다 */
var HVF=[], HVFI=-1;
function hvFindRun(){
  var q=(document.getElementById('hvFind').value||'').trim().toLowerCase();
  var pop=document.getElementById('hvFindPop');
  HVF = (PROD||[]).filter(function(o){
    if(!q) return true;
    return (''+(o.prodCd||'')).toLowerCase().indexOf(q)>=0 || (''+(o.prodNm||'')).toLowerCase().indexOf(q)>=0;
  }).slice(0,50);
  HVFI = HVF.length?0:-1;
  pop.innerHTML = HVF.length
    ? HVF.map(function(o,i){
        return '<div class="it'+(i===HVFI?' cur':'')+'" data-i="'+i+'" onclick="hvPick('+o.prodSeq+')">'
             + '<span class="cd">'+esc(o.prodCd)+'</span><span class="nm">'+esc(o.prodNm||'')+'</span></div>'; }).join('')
    : '<div class="none">일치하는 품목이 없습니다</div>';
  pop.classList.add('open');
}
function hvFindKey(e){
  var pop=document.getElementById('hvFindPop');
  if(e.key==='Escape'){ pop.classList.remove('open'); e.target.blur(); return; }
  if(!HVF.length) return;
  if(e.key==='ArrowDown'||e.key==='ArrowUp'){
    e.preventDefault();
    HVFI = (HVFI + (e.key==='ArrowDown'?1:-1) + HVF.length) % HVF.length;
    Array.prototype.forEach.call(pop.querySelectorAll('.it'), function(el){
      var on = +el.getAttribute('data-i')===HVFI; el.classList.toggle('cur', on); if(on) el.scrollIntoView({block:'nearest'});
    });
  } else if(e.key==='Enter'){ e.preventDefault(); if(HVF[HVFI]) hvPick(HVF[HVFI].prodSeq); }
}
function hvPick(seq){
  document.getElementById('hvFindPop').classList.remove('open');
  document.getElementById('hvFind').value='';
  /* 위 목록에서도 그 품목이 보이도록 그 행까지 이어붙인다 — 선택 하이라이트가 화면에 남게.
     ※ 상단 검색어 때문에 _view 에 없으면 건너뛴다.
        hvOpen 은 _byseq(PROD 전량)를 보므로 이력/재고는 정상 표시된다. */
  var idx=-1;
  for(var i=0;i<(_view||[]).length;i++){ if(_view[i].prodSeq===seq){ idx=i; break; } }
  if(idx>=_shown) _more(idx-_shown+PAGE_SIZE);   // 아직 안 붙은 뒤쪽이면 그 행이 나올 때까지
  hvOpen(seq);
  var tr=document.querySelector('#tb tr.prow[data-seq="'+seq+'"]');
  if(tr) tr.scrollIntoView({block:'center', behavior:'smooth'});
}
document.addEventListener('click', function(e){
  var w=document.getElementById('hvFindWrap'), p=document.getElementById('hvFindPop');
  if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
});
function hvTab(t){
  HVT=t;
  ['in','sale','sales','stock'].forEach(function(k){
    document.getElementById('tab_'+k).classList.toggle('on', k===t);
    document.getElementById('p_'+k).style.display = (k===t)?'flex':'none';   // flex = 표만 스크롤되는 세로 배치
  });
  if(!HVP) return;   // 품목 미선택 시 탭 하이라이트만
  if(t==='in') hvLoadIn(); else if(t==='sale') hvLoadSale(); else if(t==='sales') hvLoadSalesPrice(); else hvLoadStock();
}

/* ---- 매입가 ---- */
function hvLoadIn(){
  _listPost('/prod/inpriceList.do', HVP.prodSeq).then(function(j){
    var rows=(j&&j.data)||[], tb=document.getElementById('in_tb');
    if(!rows.length){ tb.innerHTML='<tr><td colspan="7" class="empty">이력이 없습니다.</td></tr>'; return; }
    tb.innerHTML = rows.map(function(o){
      return '<tr><td>'+fmtDt(o.applyDt)+'</td><td>'+esc(o.vendorNm)+'</td><td class="num">'+num(o.inPrice)+'</td>'
        +'<td class="num">'+num(o.prevPrice)+'</td><td>'+esc(o.remark)+'</td><td>'+esc(o.regDttm)+'</td>'
        +'<td><button class="btn btn-danger" onclick="hvDel(\'in\','+o.inpriceSeq+')">삭제</button></td></tr>';
    }).join('');
  });
}
/* ---- 매입처 = 거래처 마스터(TBL_VENDOR_MST) 의 '매입' 거래처 ----
   · 콤보(선택 안에 찾기): 버튼 클릭 → 드롭다운이 열리고 그 안의 검색창으로 좁혀서 클릭 선택.
     Enter=첫 후보 선택, Esc=닫기, 바깥 클릭=닫기. 값은 숨은 input(id)에 코드로 보관.
   · 예전엔 자유입력이라 매입가 폼은 이름만(vendorNm), 재고입고 폼은 이름을 코드칸(vendorCd)에 넣고 있었다.
     이제 마스터에서 골라 코드+이름을 함께 저장한다(목록 밖 값은 애초에 못 들어감). */
var VENDORS = [];    // 매입 거래처 (매입가·재고입고 폼)
var SVENDORS = [];   // 매출 거래처 (판매가 폼의 판매처)
function vendorLoad(){
  function one(gb, setter){
    return fetch('${pageContext.request.contextPath}/vendor/selectVendorMst.do', {
        method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
        credentials:'same-origin', body:'gbFilter=' + encodeURIComponent(gb) })
      .then(function(r){ return r.json(); })
      .then(function(j){ setter((j && j.data) || []); })
      .catch(function(){ /* 목록 실패해도 화면은 살려둔다 */ });
  }
  one('매입', function(d){ VENDORS=d; });
  one('매출', function(d){ SVENDORS=d; });
}
/* 콤보별 데이터 원천 — sl_vendor(판매처)=매출 거래처, 그 외(매입처)=매입 거래처 */
function _vdata(id){ return id==='sl_vendor' ? SVENDORS : VENDORS; }
function _vnmOf(id, cd){
  var L=_vdata(id);
  for(var i=0;i<L.length;i++) if(L[i].vendorCd===cd) return L[i].vendorNm;
  return null;
}
function vendorNmOf(cd){ return _vnmOf('in_vendor', cd); }   // 매입처 이름 (수불 이력 표시 등 기존 호출부용)
/* ── 콤보 위젯 (in_vendor / st_vendor / sl_vendor 공용) ── */
function _vq(id){ return ((document.getElementById(id+'_q')||{}).value||'').trim().toLowerCase(); }
function _vlist(id){
  var q=_vq(id), L=_vdata(id);
  return !q ? L : L.filter(function(v){
    return (''+(v.vendorNm||'')).toLowerCase().indexOf(q)>=0 || (''+(v.vendorCd||'')).toLowerCase().indexOf(q)>=0;
  });
}
function vselOpen(id){
  var dd=document.getElementById(id+'_dd'); if(!dd) return;
  var willOpen=!dd.classList.contains('on');
  vselCloseAll();
  if(!willOpen) return;
  // fixed 좌표 = 버튼 바로 아래(네이티브 select 처럼). 목록 높이는 남은 공간에 맞춰 줄여 잘리지 않게.
  // 아래가 극단적으로 좁을 때(<170px)만 위로.
  try{
    var btn=document.getElementById(id+'_btn'), lst=document.getElementById(id+'_list');
    if(btn && btn.getBoundingClientRect){
      var r=btn.getBoundingClientRect();
      var vh=(window.innerHeight||document.documentElement.clientHeight);
      dd.style.left=Math.round(r.left)+'px';
      dd.style.width=Math.max(280, Math.round(r.width))+'px';
      var below=vh-r.bottom-10;
      if(below>=170 || below>=r.top){   // 기본: 아래로
        dd.style.top=Math.round(r.bottom+3)+'px'; dd.style.bottom='auto';
        if(lst) lst.style.maxHeight=Math.max(120, Math.min(280, below-56))+'px';   // 56px ≈ 검색창 영역
      } else {                           // 예외: 위로
        dd.style.top='auto'; dd.style.bottom=Math.round(vh-r.top+3)+'px';
        if(lst) lst.style.maxHeight=Math.max(120, Math.min(280, r.top-66))+'px';
      }
    }
  }catch(e){}
  dd.classList.add('on');
  var q=document.getElementById(id+'_q'); if(q){ q.value=''; }
  vselFilter(id);
  if(q) setTimeout(function(){ q.focus(); },0);
}
function vselCloseAll(){
  Array.prototype.forEach.call(document.querySelectorAll('.vsel-dd.on'), function(d){ d.classList.remove('on'); });
}
function vselFilter(id){
  var box=document.getElementById(id+'_list'); if(!box) return;
  var cur=(document.getElementById(id)||{}).value||'';
  var list=_vlist(id);
  var noneLabel = id==='sl_vendor' ? '(공통가 — 판매처 없음)' : '(선택 안 함)';
  var h='<div class="it'+(cur===''?' on':'')+'" onclick="vselPick(\''+id+'\',\'\')">'+noneLabel+'</div>';
  if(!list.length) h+='<div class="none">검색 결과가 없습니다</div>';
  else h+=list.map(function(v){
    return '<div class="it'+(v.vendorCd===cur?' on':'')+'" onclick="vselPick(\''+id+'\',\''+esc(v.vendorCd)+'\')">'
         + esc(v.vendorNm)+'<span class="cd">['+esc(v.vendorCd)+']</span></div>';
  }).join('');
  box.innerHTML=h;
}
function vselPick(id, cd){
  var hid=document.getElementById(id), btn=document.getElementById(id+'_btn');
  if(hid) hid.value=cd||'';
  if(btn){
    var nm=cd?_vnmOf(id, cd):null;
    btn.textContent = cd ? ((nm||cd)+' ['+cd+']') : (id==='sl_vendor'?'(공통가)':'(선택)');
    btn.classList.toggle('empty', !cd);
  }
  vselCloseAll();
}
function vselKey(ev, id){
  if(ev.key==='Escape'){ vselCloseAll(); return; }
  if(ev.key==='Enter'){ ev.preventDefault(); var l=_vlist(id); if(l.length) vselPick(id, l[0].vendorCd); }
}
document.addEventListener('click', function(e){   // 바깥 클릭 시 닫기
  var t=e.target;
  while(t){ if(t.classList && t.classList.contains('vsel')) return; t=t.parentNode; }
  vselCloseAll();
});
// 패널/화면 스크롤 시 닫기 — fixed 드롭다운이 버튼과 어긋난 채 떠 있지 않게. (드롭다운 내부 목록 스크롤은 유지)
document.addEventListener('scroll', function(e){
  var t=e.target;
  while(t && t.classList){ if(t.classList.contains('vsel-dd')) return; t=t.parentNode; }
  vselCloseAll();
}, true);
function hvAddIn(){
  var price=gnum('in_price'); if(price==null){ toast('⚠️ 매입단가를 입력하세요.'); return; }
  var vcd=gv('in_vendor')||null;
  var dto={ prodSeq:HVP.prodSeq, prodCd:HVP.prodCd, applyDt:gv('in_dt')||today(),
    vendorCd:vcd, vendorNm:(vcd?vendorNmOf(vcd):null), inPrice:price, taxGb:HVP.taxGb||null, remark:gv('in_remark')||null };
  _post('/prod/inpriceInsert.do', dto).then(function(r){
    if(!r.ok){ toast('⚠️ 실패(HTTP '+r.status+'): '+(r.t||'').slice(0,120)); return; }
    document.getElementById('in_remark').value=''; toast('💰 매입가 등록 · 마스터 반영');
    hvLoadIn(); prodLoad();   // 마스터 IN_PRICE 동기화분 반영
  });
}

/* ---- 판매가 ---- */
function hvLoadSale(){
  _listPost('/prod/salepriceList.do', HVP.prodSeq).then(function(j){
    var rows=(j&&j.data)||[], tb=document.getElementById('sl_tb');
    if(!rows.length){ tb.innerHTML='<tr><td colspan="9" class="empty">이력이 없습니다.</td></tr>'; return; }
    tb.innerHTML = rows.map(function(o){
      var mr=(o.marginRt==null?'':Number(o.marginRt).toFixed(1)+'%');
      var vn = o.vendorCd ? esc(o.vendorNm||o.vendorCd) : '<span style="color:#9aa7b3">공통</span>';
      return '<tr><td>'+fmtDt(o.applyDt)+'</td><td>'+vn+'</td><td class="num">'+num(o.salePrice)+'</td><td class="num">'+num(o.wholePrice)+'</td>'
        +'<td class="num">'+num(o.baseInprice)+'</td><td class="num">'+mr+'</td><td>'+esc(o.remark)+'</td><td>'+esc(o.regDttm)+'</td>'
        +'<td><button class="btn btn-danger" onclick="hvDel(\'sale\','+o.salepriceSeq+')">삭제</button></td></tr>';
    }).join('');
  });
}
function hvAddSale(){
  var price=gnum('sl_price'); if(price==null){ toast('⚠️ 판매단가를 입력하세요.'); return; }
  var base=(HVP.inPrice!=null?Number(HVP.inPrice):null);
  var margin=(base!=null && price>0)? ((price-base)/price*100) : null;   // 마진율 = (판매-매입)/판매
  var vcd=gv('sl_vendor')||null;   // 비우면 공통(기본)가 — 마스터 동기화됨. 선택하면 그 판매처 전용가(마스터 안 건드림)
  var dto={ prodSeq:HVP.prodSeq, prodCd:HVP.prodCd, applyDt:gv('sl_dt')||today(),
    vendorCd:vcd, vendorNm:(vcd?_vnmOf('sl_vendor',vcd):null),
    salePrice:price, wholePrice:gnum('sl_whole'), baseInprice:base, marginRt:margin, remark:gv('sl_remark')||null };
  _post('/prod/salepriceInsert.do', dto).then(function(r){
    if(!r.ok){ toast('⚠️ 실패(HTTP '+r.status+'): '+(r.t||'').slice(0,120)); return; }
    document.getElementById('sl_remark').value='';
    toast(vcd ? ('🏷️ 판매처 전용가 등록 — '+esc(_vnmOf('sl_vendor',vcd)||vcd)+' <span style="color:#9aa7b3">(기본가는 그대로)</span>')
              : '🏷️ 판매가 등록 · 마스터 반영');
    hvLoadSale(); prodLoad();
  });
}

/* ---- 매출단가(조회) — 매출 확정내역(TBL_SALES_MST) 그대로. 조회 전용 ---- */
function hvLoadSalesPrice(){
  var tb=document.getElementById('ss_tb'), hd=document.getElementById('ss_hdr');
  tb.innerHTML='<tr><td colspan="7" class="empty">불러오는 중…</td></tr>';
  fetch(CTX+'/sales/selectSalesMst.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body:'dlvDtFrom=&dlvDtTo=&dcNm=&itemCd='+encodeURIComponent(HVP.prodCd||'') })
    .then(function(r){ return r.json(); })
    .then(function(j){
      // 서버 품목 필터가 아직 안 열렸을 수 있어(재시작 전) 클라이언트에서 한 번 더 거른다
      var rows=((j&&j.data)||[]).filter(function(r){ return (''+(r.itemCd||''))===(''+(HVP.prodCd||'')); });
      if(!rows.length){
        hd.innerHTML='매출 확정내역이 없습니다. (발주서 업로드분 기준 · 조회 전용)';
        tb.innerHTML='<tr><td colspan="7" class="empty">이 품목의 매출 확정내역이 없습니다.</td></tr>'; return;
      }
      var q=0,a=0,prices={}; rows.forEach(function(r){ q+=(+r.outQty||0); a+=(+r.saleAmt||0); if(r.salePrice!=null) prices[r.salePrice]=1; });
      hd.innerHTML='총 <b>'+rows.length.toLocaleString()+'</b>행 · 단가 <b>'+Object.keys(prices).length+'</b>종 · 출고량 <b>'+num(q)+'</b> · 매출액 <b>'+num(a)+'</b> <span style="color:#9aa7b3">— 조회 전용(원본: 견적서관리 ▸ 매출 엑셀 업로드)</span>';
      tb.innerHTML = rows.map(function(r){
        return '<tr><td>'+fmtDt(r.dlvDt)+'</td><td>'+esc(r.dcNm)+'</td><td>'+esc(r.ordNo)+'</td>'
          +'<td class="num">'+num(r.salePrice)+'</td><td class="num">'+num(r.outQty)+'</td><td class="num">'+num(r.saleAmt)+'</td>'
          +'<td style="color:#9aa7b3">'+esc(r.srcFile)+'</td></tr>';
      }).join('');
    })
    .catch(function(e){ tb.innerHTML='<tr><td colspan="7" class="empty">조회 오류: '+esc(e.message)+'</td></tr>'; });
}

/* ---- 재고(수불) ---- */
function hvLoadStock(){
  fetch(CTX+'/prod/stockList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'prodSeq='+encodeURIComponent(HVP.prodSeq) })
    .then(function(r){ return r.text(); }).then(function(t){
      var j; try{ j=JSON.parse(t); }catch(e){ j=null; }
      var rows=(j&&j.data)||[], st=(j&&j.stock)||null;
      var hdr=document.getElementById('st_hdr');
      if(st){
        hdr.innerHTML = '현재고 <b>'+num(st.curQty!=null?st.curQty:0)+'</b> &nbsp;·&nbsp; 평균매입가 '+num(st.avgInPrice)
          +' &nbsp;·&nbsp; 재고금액 '+num(st.stockAmt)+' &nbsp;·&nbsp; 최근입고 '+fmtDt(st.lastInDt)+' / 최근출고 '+fmtDt(st.lastOutDt);
      } else { hdr.innerHTML = '현재고 <b>0</b> &nbsp;·&nbsp; (수불 내역 없음)'; }
      var tb=document.getElementById('st_tb');
      if(!rows.length){ tb.innerHTML='<tr><td colspan="9" class="empty">수불 내역이 없습니다.</td></tr>'; return; }
      tb.innerHTML = rows.map(function(o){
        var bd='<span class="badge" style="background:'+(IO_COLOR[o.ioGb]||'#888')+'">'+(IO_MAP[o.ioGb]||o.ioGb)+'</span>';
        return '<tr><td>'+fmtDt(o.trxDt)+'</td><td>'+bd+'</td><td class="num">'+num(o.qty)+'</td><td class="num">'+num(o.unitPrice)+'</td>'
          +'<td class="num">'+num(o.amt)+'</td><td>'+esc(vendorNmOf(o.vendorCd)||o.vendorCd)+'</td><td>'+esc(o.remark)+'</td><td>'+esc(o.regDttm)+'</td>'
          +'<td><button class="btn btn-danger" onclick="hvDel(\'stock\','+o.ledgerSeq+')">삭제</button></td></tr>';
      }).join('');
    });
}
function hvStockPrefill(force){   // 단가 자동채움: 매입정보 없으면 품목마스터 금액(입고/반품=입고가, 출고=판매가, 조정=0)
  if(!HVP) return;
  var cur=gv('st_price');
  if(!force && cur!=='' && Number(cur)!==0) return;   // 수량 입력 시엔 수동 입력한 단가 보존
  var io=gv('st_io');
  var p = (io==='I'||io==='R') ? HVP.inPrice : (io==='O' ? HVP.salePrice : 0);
  document.getElementById('st_price').value = (p!=null ? p : 0);
}
function hvAddStock(){
  var qty=gnum('st_qty'); if(qty==null || qty===0){ toast('⚠️ 수량을 입력하세요.'); return; }
  var io=gv('st_io'), up=gnum('st_price');
  if((up==null || up===0) && (io==='I'||io==='R') && HVP.inPrice!=null){   // 추가 시 단가 없으면 품목마스터 입고가로
    up=Number(HVP.inPrice); document.getElementById('st_price').value=up;
  }
  var dto={ prodSeq:HVP.prodSeq, prodCd:HVP.prodCd, trxDt:gv('st_dt')||today(),
    ioGb:io, qty:qty, unitPrice:up, vendorCd:gv('st_vendor')||null, remark:gv('st_remark')||null };
  _post('/prod/stockInsert.do', dto).then(function(r){
    if(!r.ok){ toast('⚠️ 실패(HTTP '+r.status+'): '+(r.t||'').slice(0,120)); return; }
    document.getElementById('st_remark').value=''; vselPick('st_vendor',''); toast('📦 수불 등록 · 현재고 반영');
    hvLoadStock();
  });
}

/* ---- 공통 삭제 ---- */
function hvDel(kind, seq){
  swConfirm('이 내역을 삭제하시겠습니까?','삭제').then(function(ok){ if(!ok) return;
    var url, dto={};
    if(kind==='in'){ url='/prod/inpriceDelete.do'; dto={inpriceSeq:seq}; }
    else if(kind==='sale'){ url='/prod/salepriceDelete.do'; dto={salepriceSeq:seq}; }
    else { url='/prod/stockDelete.do'; dto={ledgerSeq:seq, prodSeq:HVP.prodSeq, prodCd:HVP.prodCd}; }  // 재고는 재집계 위해 prodSeq 동봉
    _post(url, dto).then(function(r){
      if(!r.ok){ toast('⚠️ 삭제 실패(HTTP '+r.status+')'); return; }
      toast('🗑️ 삭제 완료');
      if(kind==='in') hvLoadIn(); else if(kind==='sale') hvLoadSale(); else hvLoadStock();
    });
  });
}

prodLoad();
vendorLoad();   // 매입처 선택 목록 채우기 (거래처 마스터 '매입' 거래처 — 위 찾기 입력으로 좁히기)
// 진입 시 날짜 기본값 = 오늘 (품목 클릭 전에도 비어있지 않게. 품목 클릭 시 hvOpen 이 다시 오늘로 셋팅)
['in_dt','sl_dt','st_dt'].forEach(function(id){ var e=document.getElementById(id); if(e && !e.value) e.value=today(); });
</script>
</body>
</html>
