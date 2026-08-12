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

  /* 미매핑 코드 고르기 — 전용 모달.
     ★위 컴팩트 표준(440px!important)은 프로젝트 방침이라 그대로 두고, 표가 필요한 이 창만 따로 만든다.
       Swal 로 띄우면 440px 안에 눌려 가로 스크롤이 생긴다(2026-08-01 지적).
     ★바깥 클릭으로는 안 닫는다 — 고르는 중에 닫히면 처음부터 다시 해야 한다. */
  #xrPickOv{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.45); z-index:10050;
             align-items:center; justify-content:center; }
  #xrPickOv .xrp-box{ background:#fff; width:min(1080px,96vw); max-height:86vh; border-radius:12px;
             box-shadow:0 14px 44px rgba(0,0,0,.3); display:flex; flex-direction:column; overflow:hidden; }
  #xrPickOv .xrp-hd{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:12px 18px;
             font-size:15px; font-weight:600; display:flex; justify-content:space-between; align-items:center; }
  #xrPickOv .xrp-bar{ display:flex; gap:10px; align-items:center; padding:10px 18px 8px; }
  #xrPickOv .xrp-bar input{ flex:1; height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 10px; font-size:13px; }
  #xrPickOv .xrp-bar span{ color:#6b7a89; font-size:12.5px; white-space:nowrap; }
  #xrPickOv .xrp-bd{ flex:1 1 auto; min-height:0; overflow:auto; padding:0 18px; }
  #xrPickOv .xrp-ft{ padding:10px 18px 14px; text-align:right; border-top:1px solid var(--bd); }
  #xrPickOv .xrp-tb{ width:100%; border-collapse:collapse; font-size:12.5px; table-layout:fixed; }
  #xrPickOv .xrp-tb th{ background:#eef3f2; border:1px solid var(--bd); padding:6px 7px; color:#37475a;
             position:sticky; top:0; z-index:1; }
  #xrPickOv .xrp-tb td{ border:1px solid #e6ecf0; padding:5px 7px; text-align:center; color:#37475a;
             white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  #xrPickOv .xrp-tb td.l{ text-align:left; }
  #xrPickOv .xrp-tb tbody tr{ cursor:pointer; }
  #xrPickOv .xrp-tb tbody tr:hover td{ background:#eefaf6; }
</style>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>상품(품목) 관리 (TBL_PROD_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  /* ★상단(제목·검색줄)은 고정, 목록만 스크롤(2026-07-22 요청).
     종전에는 페이지 전체가 스크롤돼서 내리면 검색창·＋상품 추가 버튼이 사라졌다.
     화면 = [고정 헤더] + [스크롤되는 목록] + [하단 도킹 패널] 3층 구조. */
  html,body{ height:100%; overflow:hidden; }
  .wrap{ padding:14px 11px 0; height:100%; box-sizing:border-box; display:flex; flex-direction:column; min-height:0; }
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
  /* 머리글 — 색을 진하게, 글자도 한 단계 (2026-08-07 요청). 자료 줄(13px)과 같은 톤이라
     머리글이 표에 묻혀 보였다. 색은 재고현황 ①표·품목코드(매핑) 머리글과 같은 회청색 계열. */
  thead th{ background:#c8d5e2; color:#1f2a37; font-weight:800; font-size:14px; border:1px solid #a8bacb;
            box-shadow:inset 0 -2px 0 #5a7a9a;
            padding:10px 10px; text-align:center; position:sticky; top:0; z-index:1; }
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
  /* 「최종 코드」 안내 — 코드 칸 바로 아래 한 줄 (2026-08-12 요청). 추가할 때만 보인다.
     거래처 관리 화면(vendorMng.jsp)과 같은 모양 — 두 화면을 오갈 때 눈이 자리를 다시 잡지 않게. */
  #ov .lastcd{ flex-direction:row; align-items:center; gap:7px; flex-wrap:wrap;
               background:#f2f8f6; border:1px solid #cfe3dd; border-radius:7px; padding:6px 10px; font-size:13.5px; color:#37475a; }
  #ov .lastcd b{ font-family:Consolas,monospace; font-size:14.5px; color:#0e6657; }
  #ov .lastcd .nmx{ font-weight:700; color:#1f2a37; }   /* 코드와 함께 '무슨 상품이었나'가 보여야 한다 */
  #ov .lastcd .dim{ color:#8b98a5; }
  #ov .lastcd button{ height:26px; padding:0 11px; font-size:12.5px; font-weight:700; border:1px solid var(--teal);
                      background:#fff; color:var(--teal); border-radius:6px; cursor:pointer; }
  #ov .lastcd button:hover{ background:var(--teal); color:#fff; }
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
  /* 하단(이력/재고) 머리글은 청록 — 위 목록과 색을 갈라야 '여기부터 다른 표'라는 게 읽힌다.
     재고현황의 상단 회청 / 하단 청록 규칙과 같다(2026-08-07). */
  #hv thead th{ background:#b9ded4; color:#0b4f43; font-weight:800; font-size:14px;
                border:1px solid #93c7b9; box-shadow:inset 0 -2px 0 #0e6657; padding:10px 10px;
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
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
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
      <%-- 새 코드는 9번대(2026-08-12) — 원천 코드(1000…)와 부딪히지 않게. 원천 코드를 직접 넣는 것은 막지 않는다. --%>
      <div class="fld"><label>코드 *</label><input id="f_cd" placeholder="예: 9000000001 (새 코드는 9번대)" title="새로 만드는 상품코드는 9로 시작합니다. 아래 줄의 새 코드가 미리 들어가 있습니다."></div>
      <div class="fld"><label>과세</label><select id="f_tax"><option value="과세">과세</option><option value="면세">면세</option></select></div>
      <%-- 코드 칸 바로 아래 줄 = 마지막으로 등록한 상품코드·상품명 (2026-08-12). 추가할 때만 나온다. --%>
      <div class="fld full lastcd" id="lastCd" style="display:none"></div>
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
      <%-- 거래처 코드 — 같은 물건을 거래처가 자기 코드·자기 품명으로 요청할 때 여기에 등록한다(2026-08-01).
           ★가상코드(같은 물건을 상품마스터에 또 등록)는 이제 만들지 않는다 — 재고가 갈라진다.
             재고·원가의 주인은 언제나 이 품목 하나(PROD_SEQ)고, 여기 등록한 이름이 출고서에 찍힌다. --%>
      <button class="tab"    id="tab_xref"  onclick="hvTab('xref')">🔗 거래처 코드</button>
    </div>
    <div class="mb2">
      <%-- 매입가 — 조회 전용 (2026-07-25 변경)
           매입등록 전표를 저장하면 UserServiceImpl.savePurchase() 가 같은 경로
           (insertInprice + syncProdInPrice)로 이력을 쌓고 마스터 IN_PRICE 까지 맞춘다.
           여기서 수기로 또 넣으면 전표 없는 이력이 생겨 매입등록의 단가이력과 어긋나므로
           입력줄과 행별 삭제를 걷어냈다. 이력은 전표에서만 만들어진다.
           (변경 시점 기준 살아있는 66건 전부 '매입등록 전표'출처, 수기분 0건 — 잃은 데이터 없음)
           서버의 /prod/inpriceInsert.do · /prod/inpriceDelete.do 는 그대로 두었다.
           판매가는 반대다 : 정산서 밖에서 파는 건이 있어 수기 등록을 남긴다. --%>
      <div class="panel" id="p_in">
        <div class="subbar" style="color:#6b7a89; font-size:12.5px">
          🔒 매입단가는 <b>매입등록</b> 전표에서 자동으로 쌓입니다. 이 화면은 조회 전용입니다.
        </div>
        <div class="tbwrap">
        <table>
          <thead><tr><th>적용일</th><th>매입처</th><th style="text-align:right">매입단가</th><th style="text-align:right">직전가</th><th>비고</th><th>등록</th></tr></thead>
          <tbody id="in_tb"><tr><td colspan="6" class="empty">-</td></tr></tbody>
        </table>
        </div>
      </div>
      <%-- 판매가 — 조회 전용 (2026-07-25 변경. 매입가 탭과 같은 처리)
           판매등록 전표를 저장하면 saveSalesTrx() 가 판매단가 이력을 쌓는다(그 거래처 전용가).
           정산서(매출 엑셀) 업로드도 mergeSalepriceFromSales 로 이력을 쌓는다.
           수기로 또 넣으면 어느 값이 맞는지 알 수 없어 입력줄과 행별 삭제를 걷어냈다.
           ※ 종전에는 '정산서 밖 판매를 등록할 데가 없다'는 이유로 열어뒀는데,
              그 자리를 판매등록이 대신하게 되어 닫는다.
           서버의 /prod/salepriceInsert.do · /prod/salepriceDelete.do 는 그대로 두었다. --%>
      <div class="panel" id="p_sale" style="display:none">
        <div class="subbar" style="color:#6b7a89; font-size:12.5px">
          🔒 판매단가는 <b>판매등록</b> 전표와 <b>정산서 업로드</b>에서 자동으로 쌓입니다. 이 화면은 조회 전용입니다.
        </div>
        <div class="tbwrap">
        <table>
          <thead><tr><th>적용일</th><th>판매처</th><th style="text-align:right">판매가</th><th style="text-align:right">도매가</th><th style="text-align:right">기준매입</th><th style="text-align:right">마진율</th><th>비고</th><th>등록</th></tr></thead>
          <tbody id="sl_tb"><tr><td colspan="8" class="empty">-</td></tr></tbody>
        </table>
        </div>
      </div>
      <!-- 매출단가(조회) — 매출 확정내역(TBL_SALES_MST, 발주서 업로드분)의 실제 판매단가. 조회 전용 -->
      <div class="panel" id="p_sales" style="display:none">
        <div class="stockhdr" id="ss_hdr">매출 확정내역(발주서 업로드분)의 실제 판매단가 — 조회 전용</div>
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
        <%-- 수불 입력 = 조정(±) 전용 (2026-07-25 변경)
             입고·출고·반품은 전표가 만든다 : 매입등록 → REF_GB='PURCH'(I) / 판매등록 → 'SALE'(O)
             / 발주현황표 업로드 → 'SHIPOUT'(O). 여기서 또 넣으면 재고가 두 번 움직인다.
             조정만 남긴 이유 : 실사에서 장부와 실물이 어긋났을 때 맞출 전표가 따로 없다.
             (변경 시점 재고원장 : PURCH 5건 · SHIPOUT 2,220건 · 수기 0건 — 잃은 데이터 없음) --%>
        <div class="subbar">
          <div class="fld"><label>거래일</label><input type="date" id="st_dt"></div>
          <div class="fld"><label>구분</label>
            <select id="st_io" onchange="hvStockPrefill(true)">
              <option value="A">조정(±)</option>
            </select>
          </div>
          <div class="fld"><label>수량 <span style="color:#9aa7b3;font-weight:400">(늘리면 +, 줄이면 −)</span></label><input type="number" id="st_qty" style="width:110px" value="0" oninput="hvStockPrefill(false)"></div>
          <div class="fld"><label>단가 <span style="color:#9aa7b3;font-weight:400">(자동·수정가능)</span></label><input type="number" id="st_price" step="0.01" style="width:110px" value="0" title="품목 입고가 자동표시 · 수정 가능"></div>
          <div class="fld"><label>사유 <span style="color:#c0392b;font-weight:400">필수</span></label><input type="text" id="st_remark" style="width:230px" placeholder="예) 실사 차이 · 파손 폐기"></div>
          <input type="hidden" id="st_vendor">
          <button class="btn btn-teal" onclick="hvAddStock()">＋ 조정 추가</button>
          <span style="color:#6b7a89; font-size:12px; align-self:center">입고·출고·반품은 <b>매입등록·판매등록</b>에서 자동으로 쌓입니다.</span>
        </div>
        <div class="tbwrap">
        <table>
          <thead><tr><th>거래일</th><th>구분</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>매입처</th><th>출처</th><th>비고</th><th>등록</th><th style="width:56px"></th></tr></thead>
          <tbody id="st_tb"><tr><td colspan="10" class="empty">-</td></tr></tbody>
        </table>
        </div>
      </div>

      <%-- ===== 거래처 코드(교차참조) — TBL_PROD_XREF ==========================================
           · 거래처 품목코드는 **자유 입력이 아니라 실제로 들어온 코드 중에서 고른다**(미매핑 목록).
             오타로 있지도 않은 코드를 매핑하는 사고가 원천 차단된다.
           · ★품명은 거래처마다 제각각으로 들어온다 — 이름만 보고 판단하지 말 것.
             판정 근거는 **단가 · 규격**이고(정산서에만 있다), 최종 확인은 사람이 한다.
           · [확인] 을 눌러야 CONFIRM_YN='Y'. 자동 확정은 없다.
           ====================================================================================== --%>
      <div class="panel" id="p_xref" style="display:none">
        <div class="subbar">
          <div class="fld"><label>거래처</label>
            <input type="text" id="xr_venNm" list="xr_venList" style="width:200px" placeholder="비우면 모든 거래처 공통" title="이 거래처가 쓰는 표기입니다. 비우면 거래처 구분 없이 적용됩니다.">
            <datalist id="xr_venList"></datalist>
          </div>
          <div class="fld"><label>거래처 품목코드 <span style="color:#c0392b;font-weight:400">필수</span></label>
            <input type="text" id="xr_extCd" style="width:150px" placeholder="[불러오기]로 고르세요" title="실제로 업로드된 코드 중에서 고르는 것이 안전합니다.">
          </div>
          <button class="btn" onclick="xrPickOpen()" title="업로드된 자료 중 아직 우리 품목에 연결되지 않은 코드 목록">📥 미매핑에서 고르기</button>
          <div class="fld"><label>거래처 품목명 <span style="color:#9aa7b3;font-weight:400">(출고서에 찍히는 이름)</span></label>
            <input type="text" id="xr_extNm" style="width:260px">
          </div>
          <div class="fld"><label>규격</label><input type="text" id="xr_extSpec" style="width:130px"></div>
          <div class="fld"><label>단위</label><input type="text" id="xr_extUnit" style="width:70px" placeholder="BOX"></div>
          <div class="fld"><label>환산 <span style="color:#9aa7b3;font-weight:400">(거래처1=우리N)</span></label>
            <input type="number" id="xr_conv" step="0.001" style="width:80px" value="1" title="거래처가 박스로 세고 우리가 낱개로 셀 때만 바꿉니다. 보통 1.">
          </div>
          <div class="fld"><label>대표</label>
            <select id="xr_main" style="width:70px" title="그 거래처로 출고할 때 기본으로 쓸 표기"><option value="N">-</option><option value="Y">대표</option></select>
          </div>
          <button class="btn btn-teal" id="xr_saveBtn" onclick="xrSave()">＋ 연결</button>
          <button class="btn" id="xr_cancelBtn" onclick="xrEditCancel()" style="display:none">취소</button>
        </div>
        <%-- ★어느 품목에 붙일지는 여기서 정한다 (2026-08-01 요청 "선택 후 연결에서 기능 적용").
             [미매핑에서 고르기] 는 조회용 — 코드를 골라 위 칸에 채우기만 한다. 그 코드에 맞을 만한
             우리 품목은 규격·단가로 찾아 이 줄에 띄우고, 여기서 고른 것이 연결 대상이 된다.
             아무것도 안 고르면 위 목록에서 잡아 둔 품목(HVP)에 붙는다 — 종전 방식 그대로. --%>
        <div class="subbar" id="xr_tgtBar" style="padding-top:0; align-items:center; gap:8px; display:none"></div>
        <div class="subbar" style="color:#6b7a89; font-size:12.5px; padding-top:0">
          ⚠️ 거래처는 <b>품명도 자기 식으로</b> 보냅니다 — 이름만 보고 판단하지 마세요.
          같은 물건이면 <b>규격·단가</b>가 맞아야 합니다. 확인이 끝나면 <b>[확인]</b>을 눌러 확정하세요.
        </div>
        <div class="tbwrap">
        <table>
          <thead><tr>
            <th>거래처</th><th>거래처 품목코드</th><th>거래처 품목명(출고서 표기)</th>
            <th>규격</th><th>단위</th><th style="text-align:right">환산</th><th>대표</th><th>확인</th><th>등록</th><th style="width:96px"></th>
          </tr></thead>
          <tbody id="xr_tb"><tr><td colspan="10" class="empty">-</td></tr></tbody>
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

/* ── 신규등록 창 「최종 코드」 안내 (2026-08-12 요청) ─────────────────────────────
   새 상품코드를 붙이려면 '지금 어디까지 썼나'를 먼저 알아야 한다. 목록은 코드순이라
   ★맨 끝 줄이 최근 등록분이 아니다. 그래서 두 가지를 같이 낸다:
     ① 가장 최근 등록(REG_DTTM 기준 · 코드 + 상품명) ② ★9번대 최대 코드 → 다음 코드(아래 규칙).
   ★자릿수가 다른 코드는 한 줄에 세우지 않는다 — 섞이면 '가장 큰 코드'가 뜻을 잃는다.
   ★수정은 REG_DTTM 을 안 건드리므로(UPDATE 제자리) '최근 등록'이 실제 신규 등록순 그대로다.
   ★목록(PROD)은 이미 화면에 들어와 있으므로 서버를 부르지 않는다.
   거래처 관리 화면(vendorMng.jsp)에 같은 것이 있다 — 규칙을 고치면 그쪽도 함께. */
var _nextCd = '';
function _cdParse(cd){                       // 코드 → {pre, num, w} · 끝의 숫자 덩어리를 본다
  var m=/^(.*?)(\d+)$/.exec(String(cd==null?'':cd));
  if(!m || m[2].length>15) return null;      // 16자리 넘는 숫자는 Number 로 정확히 못 다룬다 → 아예 추천하지 않는다
  return { pre:m[1], num:m[2], w:m[2].length };
}
function _cdNext(cd){                        // 같은 접두·자릿수로 +1 (자릿수가 넘치면 그대로 늘어난다)
  var p=_cdParse(cd); if(!p) return '';
  var n=String(Number(p.num)+1);
  while(n.length<p.w) n='0'+n;
  return p.pre+n;
}
/* ── ★새 상품코드는 「9」로 시작한다 (2026-08-12 확정 · 상품코드등록 prodcd.jsp 와 같은 규칙) ──
   원천 코드(웰스토리 발주현황표)는 `1000…` 번대라, 우리가 붙이는 코드를 그 번호대에 끼우면
   뒤에 들어올 원천 코드와 부딪친다 → 신규 코드는 9번대만 쓴다. '다음 코드'도 9번대 최대값 +1.
   9가 아닌 코드도 등록은 막지 않는다(원천 코드를 손으로 넣어야 할 때가 있다). */
var NEW_PRE='9', NEW_W=10;
function _isNewCd(cd){ return /^9\d*$/.test(String(cd==null?'':cd)); }
function _nineInfo(list){                    // 9번대 최대코드 → 다음코드
  var nine=[], recent=null;
  list.forEach(function(o){
    if(!_isNewCd(o.prodCd)) return;
    nine.push(o);
    if(!recent || String(o.regDttm||'') > String(recent.regDttm||'')) recent=o;
  });
  if(!nine.length){                          // 9번대가 아직 하나도 없다 → 시작 코드를 만들어 준다
    var s='1'; while(s.length < NEW_W-1) s='0'+s;
    return { max:null, next:NEW_PRE+s };
  }
  var w=String(recent.prodCd).length, max=null, mx=-1;   // 자릿수가 섞여 있으면 최근 등록분의 형식만 센다
  nine.forEach(function(o){
    var c=String(o.prodCd); if(c.length!==w) return;
    if(Number(c) > mx){ mx=Number(c); max=c; }
  });
  return { max:max, next:max?_cdNext(max):'' };
}
function prodLastInfo(){
  var last=null;
  PROD.forEach(function(o){                  // REG_DTTM 은 'YYYY-MM-DD HH:MM:SS' 문자열이라 그대로 비교된다
    if(!o.regDttm) return;
    if(!last || String(o.regDttm) > String(last.regDttm)) last=o;
  });
  // 등록일시가 아예 없는 자료면 코드가 가장 큰 줄을 대신 잡는다
  if(!last) PROD.forEach(function(o){ if(!last || String(o.prodCd) > String(last.prodCd)) last=o; });
  var n=_nineInfo(PROD);
  return { last:last, max:n.max, next:n.next };   // 목록이 비어 있어도 시작 코드는 낸다
}
function prodLastCdShow(on){
  var el=document.getElementById('lastCd'); if(!el) return;
  _nextCd='';
  var i = on ? prodLastInfo() : null;
  if(!i){ el.style.display='none'; el.innerHTML=''; return; }
  var h='';
  if(i.last)                                 // 최근 등록은 9번대가 아니어도 그대로 보여 준다(무엇을 마지막에 넣었나)
    h+='🕘 <span class="dim">최근 등록</span> <b>'+esc(i.last.prodCd)+'</b> '
     + '<span class="nmx" title="'+esc(i.last.spec||'')+'">'+esc(i.last.prodNm||'(이름 없음)')+'</span>'
     + (i.last.regDttm ? ' <span class="dim">· '+esc(String(i.last.regDttm).slice(0,10))+'</span>' : '')
     + ' <span class="dim">·</span>';
  h+=' <span class="dim">9번대 마지막</span> '
   + (i.max ? '<b>'+esc(i.max)+'</b>' : '<span class="dim">아직 없음</span>');
  if(i.next){
    _nextCd=i.next;
    h+=' <span class="dim">→ 새 코드</span> <b>'+esc(i.next)+'</b>'
     + ' <button type="button" onclick="prodUseNext()" title="코드 칸에 넣습니다. 창을 열면 이미 들어가 있습니다 — 그대로 두거나 직접 쳐도 됩니다.">넣기</button>';
  }
  el.innerHTML=h; el.style.display='flex';
}
function prodUseNext(){
  if(!_nextCd) return;
  var el=document.getElementById('f_cd');
  el.value=_nextCd; el.focus();
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
  prodLastCdShow(!o);        // 추가일 때만 「최근 등록 코드·상품명」 줄을 낸다 (수정은 코드가 잠겨 있어 쓸모없다)
  // 추가는 9번대 새 코드를 미리 넣고 골라 둔다 — 그대로 쓰거나 그냥 쳐서 바꾸면 된다
  if(!o && _nextCd){
    var fc=document.getElementById('f_cd'); fc.value=_nextCd;
    setTimeout(function(){ fc.focus(); fc.select(); }, 0);
  }
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
  // sl_dt·in_dt 는 판매가·매입가 입력줄과 함께 없앴다(둘 다 조회 전용)
  document.getElementById('st_dt').value = today();
  hvStockPrefill(true);   // 재고 조정 단가 = 품목마스터 매입가 자동채움
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
  ['in','sale','sales','stock','xref'].forEach(function(k){
    document.getElementById('tab_'+k).classList.toggle('on', k===t);
    document.getElementById('p_'+k).style.display = (k===t)?'flex':'none';   // flex = 표만 스크롤되는 세로 배치
  });
  if(!HVP) return;   // 품목 미선택 시 탭 하이라이트만
  if(t==='in') hvLoadIn(); else if(t==='sale') hvLoadSale(); else if(t==='sales') hvLoadSalesPrice();
  else if(t==='xref') xrLoad(); else hvLoadStock();
}

/* ================= 거래처 코드(교차참조) — TBL_PROD_XREF (2026-08-01) =================
   같은 물건을 거래처가 자기 코드·자기 품명으로 요청할 때 여기에 등록한다.
   ★상품마스터에 '가상코드'를 또 만들지 않는다 — 그러면 재고가 원코드와 가상코드로 갈라진다.
     재고·원가의 주인은 이 품목 하나(PROD_SEQ)고, 여기 등록한 EXT_ITEM_NM 이 출고서에 찍힌다.
   ★거래처는 품명도 자기 식으로 보낸다. 이름으로 판단하지 말고 규격·단가로 확인할 것.
   ==================================================================================== */
function xrLoad(){
  if(!HVP) return;
  _listPost('/prod/xrefList.do', HVP.prodSeq).then(function(j){
    var rows=(j&&j.data)||[], tb=document.getElementById('xr_tb');
    if(!rows.length){
      tb.innerHTML='<tr><td colspan="10" class="empty">연결된 거래처 코드가 없습니다. 거래처가 다른 코드로 요청하면 여기에 등록하세요.</td></tr>';
      return;
    }
    tb.innerHTML = rows.map(function(o){
      /* 확인 전(CONFIRM_YN='N')은 눈에 띄게 — 재고는 이미 반영되지만 검증이 안 끝난 상태다 */
      var ok = (o.confirmYn==='Y');
      var badge = ok ? '<span style="color:#137a6c;font-weight:700" title="'+esc(o.confirmUser||'')+' '+esc(o.confirmDttm||'')+'">✔ 확인</span>'
                     /* '미확인' 은 문제처럼 읽힌다 — 연결도 됐고 재고도 정상이다(2026-08-01 지적).
                        남은 일이 무엇인지만 담백하게 적는다. */
                     : '<span style="color:#c07a02;font-weight:700" title="연결됐고 재고도 정상입니다. 규격·단가만 한 번 대조한 뒤 [확인]을 누르면 끝입니다.">확인 필요</span>';
      return '<tr>'
        + '<td>'+esc(o.vendorNm|| (o.vendorCd||'<span style="color:#9aa7b3">공통</span>'))+'</td>'
        + '<td><b>'+esc(o.extItemCd)+'</b></td>'
        + '<td style="text-align:left">'+esc(o.extItemNm)+'</td>'
        + '<td>'+esc(o.extSpec)+'</td><td>'+esc(o.extUnit)+'</td>'
        + '<td class="num">'+(o.convQty==null?'1':Number(o.convQty))+'</td>'
        + '<td>'+(o.mainYn==='Y'?'★':'')+'</td>'
        + '<td>'+badge+'</td>'
        + '<td>'+esc((o.regDttm||'').slice(0,10))+'</td>'
        /* ★[수정] 추가 (2026-08-01 요청) — 잘못 붙였을 때 지웠다 다시 거는 대신 이 줄을 위 입력줄로
             불러올린다. 저장할 때 옛 연결을 먼저 지우고 새로 건다(UNIQUE UX_PROD_XREF_EXT 때문). */
        + '<td style="white-space:nowrap">'
        +   (ok?'':'<button class="btn" style="height:22px;padding:0 6px;font-size:11.5px" onclick="xrConfirm('+o.xrefSeq+')">확인</button> ')
        +   '<button class="btn" style="height:22px;padding:0 6px;font-size:11.5px" onclick="xrEdit('+o.xrefSeq+')">수정</button> '
        +   '<button class="btn" style="height:22px;padding:0 6px;font-size:11.5px;color:#c0392b" onclick="xrDelete('+o.xrefSeq+')">해제</button>'
        + '</td></tr>';
    }).join('');
    window._xrList = rows;   // [수정] 이 그 줄을 되찾을 수 있게 들고 있는다
  });
}

/* 거래처 콤보 — 매출 거래처(SVENDORS)를 쓴다. 출고를 받는 쪽이라 매입처가 아니다. */
function xrVenFill(){
  var dl=document.getElementById('xr_venList'); if(!dl) return;
  dl.innerHTML = (SVENDORS||[]).map(function(v){ return '<option value="'+esc(v.vendorNm)+'">'+esc(v.vendorCd)+'</option>'; }).join('');
}
function xrVenCd(){
  var nm=gv('xr_venNm'); if(!nm) return '';
  var f=(SVENDORS||[]).filter(function(v){ return v.vendorNm===nm; })[0];
  return f? f.vendorCd : '';
}

/* ★[수정] — 그 줄을 위 입력줄로 불러올린다. 저장할 때 옛 연결을 지우고 새로 건다(`_xrEditSeq`). */
var _xrEditSeq=null;
function xrEdit(seq){
  var o=null, L=window._xrList||[];
  for(var i=0;i<L.length;i++) if(L[i].xrefSeq===seq) o=L[i];
  if(!o){ toast('⚠️ 그 줄을 못 찾았습니다 — 새로고침 해 보세요'); return; }
  _xrEditSeq = seq;
  document.getElementById('xr_venNm').value   = o.vendorNm||'';
  document.getElementById('xr_extCd').value   = o.extItemCd||'';
  document.getElementById('xr_extNm').value   = o.extItemNm||'';
  document.getElementById('xr_extSpec').value = o.extSpec||'';
  document.getElementById('xr_extUnit').value = o.extUnit||'';
  document.getElementById('xr_conv').value    = (o.convQty==null?1:o.convQty);
  document.getElementById('xr_main').value    = (o.mainYn==='Y'?'Y':'N');
  _xrTgt = HVP ? { prodSeq:HVP.prodSeq, prodCd:HVP.prodCd, prodNm:HVP.prodNm, extSpec:HVP.spec, salePrice:HVP.salePrice } : null;
  xrTgtLoad(o.extItemCd, o.extItemNm);        // 다른 품목으로 옮길 수 있게 후보도 같이 띄운다
  xrSaveBtn(true);
  toast('불러왔습니다 — 고친 뒤 <b>[✎ 수정 저장]</b>. 다른 품목으로 옮기려면 <b>연결 대상</b> 에서 고르세요');
}
function xrSaveBtn(edit){
  var b=document.getElementById('xr_saveBtn'); if(!b) return;
  b.textContent = edit ? '✎ 수정 저장' : '＋ 연결';
  var c=document.getElementById('xr_cancelBtn'); if(c) c.style.display = edit ? '' : 'none';
}
function xrEditCancel(){
  _xrEditSeq=null; xrTgtClear(); xrSaveBtn(false);
  ['xr_extCd','xr_extNm','xr_extSpec','xr_extUnit'].forEach(function(id){ document.getElementById(id).value=''; });
  document.getElementById('xr_conv').value='1'; document.getElementById('xr_main').value='N';
}
function xrSave(){
  var extCd = gv('xr_extCd');
  if(!extCd){ toast('⚠️ 거래처 품목코드를 고르세요'); return; }
  /* ★연결 대상 = 연결 줄에서 고른 후보 우선, 없으면 위 목록에서 잡아 둔 품목(HVP).
       둘 다 없으면 붙일 곳이 없다 — 후보가 떠 있는데 안 골랐을 수도 있으니 그것도 짚어 준다. */
  var T = _xrTgt || HVP;
  if(!T){
    var has=(_xrCandCache[extCd]||[]).length;
    toast(has ? '⚠️ 아래 <b>연결 대상</b> 에서 우리 품목을 고르세요'
              : '⚠️ 위 목록에서 우리 품목 행을 클릭해 잡으세요');
    return;
  }
  var nm = gv('xr_venNm');
  if(nm && !xrVenCd()){ toast('⚠️ 거래처를 목록에서 고르세요'); return; }
  var dto = {
    prodSeq: T.prodSeq, prodCd: T.prodCd,
    vendorCd: xrVenCd(), vendorNm: nm,
    extItemCd: extCd, extItemNm: gv('xr_extNm'), extSpec: gv('xr_extSpec'), extUnit: gv('xr_extUnit'),
    convQty: gnum('xr_conv')==null?1:gnum('xr_conv'),
    mainYn: gv('xr_main'),
    confirmYn: 'N'          // 연결 직후는 '확인 필요' — 규격·단가로 대조한 뒤 [확인]
  };
  /* ★수정 = 지우고 새로 걸기 — 같은 코드에 연결이 둘 생기면 UNIQUE(UX_PROD_XREF_EXT) 위반이다.
       순서도 중요하다: 먼저 지워야 서버(deleteXref)가 옛 연결분 재고를 되돌린 뒤 새로 반영한다. */
  var edit=_xrEditSeq;
  var first = edit ? _post('/prod/xrefDelete.do', { xrefSeq: edit }) : Promise.resolve({ok:true});
  first.then(function(r0){
    if(!r0.ok){ toast('⚠️ 옛 연결 해제 실패 — '+esc(r0.t||'')); return; }
    return _post('/prod/xrefSave.do', dto).then(function(r){
      if(!r.ok){ toast('⚠️ '+esc(r.t||'연결 실패')); return; }
      /* 저장하면 서버가 과거 업로드분까지 소급으로 해석하고 재고를 다시 만든다(saveXref) */
      toast((edit?'수정했습니다':'연결했습니다')+' — <b>'+esc(extCd)+'</b> → '+esc(T.prodCd)+'. 과거 업로드분도 이 품목으로 반영됩니다.');
      _xrEditSeq=null; xrSaveBtn(false);
      document.getElementById('xr_extCd').value=''; document.getElementById('xr_extNm').value='';
      document.getElementById('xr_extSpec').value=''; document.getElementById('xr_extUnit').value='';
      document.getElementById('xr_conv').value='1'; document.getElementById('xr_main').value='N';
      delete _xrCandCache[extCd];   // 이제 미매핑이 아니다 — 다음에 열면 다시 조회
      xrTgtClear();
      xrLoad();
    });
  });
}
function xrConfirm(seq){
  swConfirm('규격·단가를 확인하셨나요?<br><span style="font-size:12.5px;color:#6b7a89">품명이 달라도 규격·단가가 맞으면 같은 물건입니다.</span>', '대사 확인')
    .then(function(ok){
      if(!ok) return;
      _post('/prod/xrefConfirm.do', { xrefSeq: seq }).then(function(r){
        if(!r.ok){ toast('⚠️ '+esc(r.t||'실패')); return; }
        toast('확정했습니다.'); xrLoad();
      });
    });
}
function xrDelete(seq){
  /* 지우면 그 코드로 이미 반영된 재고까지 되돌린다(서버 deleteXref) — 되돌리기가 반쪽이면
     엉뚱한 품목의 재고가 그대로 굳는다. 그래서 무슨 일이 일어나는지 미리 알린다. */
  swConfirm('이 연결을 지울까요?<br><span style="font-size:12.5px;color:#6b7a89">이 코드로 <b>이미 반영된 출고·정산도 함께 되돌리고</b> 재고를 다시 계산합니다.<br>다른 매핑이나 같은 코드의 품목이 있으면 그쪽으로 다시 잡히고, 없으면 미매핑으로 남습니다.</span>', '삭제')
    .then(function(ok){
      if(!ok) return;
      _post('/prod/xrefDelete.do', { xrefSeq: seq }).then(function(r){
        if(!r.ok){ toast('⚠️ '+esc(r.t||'실패')); return; }
        toast('지웠습니다.'); xrLoad();
      });
    });
}

/* 미매핑에서 고르기 — ★거래처 코드를 손으로 치지 않게 하는 장치.
   업로드된 자료 중 아직 우리 품목으로 해석되지 않은 코드만 나온다. 있지도 않은 코드를
   오타로 매핑하는 사고가 원천 차단되고, 그 코드가 살아 있다는 것(최근 일자·건수)도 함께 보인다. */
/* 미매핑 코드 고르기 — 전용 모달.
   ★Swal 을 쓰면 안 된다: 이 프로젝트는 `.swal2-popup{width:440px!important}` 로 컴팩트 표준을
     걸어 두어 width 지정이 무시되고, 표가 440px 안에 눌려 가로 스크롤이 생긴다(2026-08-01 지적).
     그 표준은 프로젝트 방침이라 건드리지 않고 여기만 별도 모달을 쓴다. */
function _xrPickOv(){
  var ov=document.getElementById('xrPickOv');
  if(!ov){
    ov=document.createElement('div'); ov.id='xrPickOv';
    ov.innerHTML =
      '<div class="xrp-box">'
      + '<div class="xrp-hd"><span>📥 미매핑 코드에서 고르기 '
      +   '<span style="font-weight:400;font-size:12.5px;opacity:.85">— 업로드된 자료에 있는데 <b>상품마스터에 없는</b> 코드입니다 (그만큼 재고에서 빠져 있습니다). '
      +   '<b>줄을 누르면</b> 입력칸에 채워집니다 — 연결은 아래 <b>[＋ 연결]</b> 줄에서</span></span>'
      +   '<span style="cursor:pointer;font-size:18px" onclick="xrPickClose()" title="닫기">✕</span></div>'
      + '<div class="xrp-bar">'
      +   '<input id="xrPickQ" placeholder="거래처 · 코드 · 품목명으로 좁히기" oninput="xrPickDraw()" autocomplete="off">'
      +   '<button class="btn" id="xrPickAll" onclick="xrPickClear()" style="height:32px;white-space:nowrap"'
      +     ' title="검색어를 지우고 미매핑 전체를 봅니다">전체 보기</button>'
      +   '<span id="xrPickCnt"></span></div>'
      + '<div id="xrPickWhy" style="padding:0 18px 6px;font-size:12px;color:#8a97a3"></div>'
      + '<div class="xrp-bd" id="xrPickBd"></div>'
      + '<div class="xrp-ft"><button class="btn" onclick="xrPickClose()">닫기</button></div>'
      + '</div>';
    document.body.appendChild(ov);   // 바깥 클릭으로는 닫지 않는다(고르는 중 실수 방지)
  }
  return ov;
}
function xrPickClose(){ var ov=document.getElementById('xrPickOv'); if(ov) ov.style.display='none'; }
/* 걸러진 목록 — 그리기와 '열 때 좁혀 보기' 가 같은 규칙을 쓰도록 한곳에 둔다.
   ★띄어쓰기로 나눠 모두 만족하는 것만 남긴다 — 품명은 거래처마다 순서가 달라 통짜로 찾으면 못 찾는다. */
function xrPickRows(){
  var q=((document.getElementById('xrPickQ')||{}).value||'').trim().toLowerCase();
  var all=window._xrPick||[];
  if(!q) return all;
  var ws=q.split(/\s+/).filter(Boolean);
  return all.filter(function(o){
    var hay=[o.vendorNm,o.dcCd,o.extItemCd,o.extItemNm,o.extSpec].map(function(x){
      return String(x||'').toLowerCase(); }).join(' ');
    return ws.every(function(w){ return hay.indexOf(w)>=0; });
  });
}
function xrPickDraw(){
  var all=window._xrPick||[];
  var rows=xrPickRows();
  document.getElementById('xrPickCnt').textContent = rows.length + ' / ' + all.length + '종';
  document.getElementById('xrPickBd').innerHTML =
    '<table class="xrp-tb"><thead><tr>'
    + '<th style="width:120px">코드</th><th>품목명</th>'
    + '<th style="width:150px">규격</th><th style="width:56px">단위</th>'
    + '<th style="width:150px" title="이 코드가 들어온 출고장(여러 곳이면 콤마)">출고장</th>'
    + '<th style="width:76px" title="발주현황표(출고) / 정산서(정산) 중 어디서 들어왔나 — 정산서에만 규격·단가가 있다">원천</th>'
    + '<th style="width:86px">최근</th><th style="width:56px">건수</th></tr></thead><tbody>'
    + (rows.length ? rows.map(function(o){
        var i = all.indexOf(o);
        return '<tr onclick="xrPick('+i+')" title="누르면 위 입력칸에 채워지고, 맞을 만한 우리 품목을 찾아 [＋ 연결] 줄에 띄웁니다">'
          + '<td><b>'+esc(o.extItemCd)+'</b></td>'
          + '<td class="l" title="'+esc(o.extItemNm)+'">'+esc(o.extItemNm)+'</td>'
          + '<td class="l" title="'+esc(o.extSpec||'')+'">'+esc(o.extSpec||'')+'</td>'
          + '<td>'+esc(o.extUnit||'')+'</td>'
          + '<td class="l" title="'+esc(o.vendorNm||'')+'">'+esc(o.vendorNm||'')+'</td>'
          + '<td>'+esc(o.matchWhy||'')+'</td>'
          + '<td>'+fmtDt(o.lastDt)+'</td>'
          + '<td style="text-align:right">'+esc(o.useQty)+'</td></tr>';
      }).join('') : '<tr><td colspan="8" style="padding:14px;text-align:center;color:#8a97a3">'
        + '그 말로는 미매핑이 없습니다 — <b>전체 보기</b> 를 누르거나 검색어를 줄여 보세요.</td></tr>')
    + '</tbody></table>';
}
/* ★열 때 이미 좁혀서 보여 준다 (2026-08-01 지적 "검색 내용을 기준으로 검색해야 하지 않나요").
     종전에는 미매핑 전체를 그대로 늘어놓았다. 이 창은 '지금 보고 있는 품목에 거래처 코드를
     달아 주는' 자리인데, 무엇을 보고 있었는지를 버리고 24종을 다시 눈으로 훑게 했다.
     이제 품목코드(매핑) 화면처럼 **찾던 말**을 그대로 이어받는다.
       ① 위 검색칸(#q)에 뭔가 쳐 놨으면 그 말
       ② 아니면 아래 [이력/재고] 에 잡혀 있는 품목(HVP)의 품명 핵심조각
     걸러서 0건이면 자동으로 전체를 보여 준다 — 빈 화면을 주는 것보다 낫다.
     [전체 보기] 로 언제든 푼다. */
function _xrFrag(nm){
  var n=String(nm||'').replace(/\s/g,'');
  var p=n.indexOf(')');
  if(p>=1 && p<=11) n=n.substring(p+1);     // 앞의 (브랜드) 는 거래처마다 달라 대조에 방해된다
  n=n.replace(/^[,\-·]+/,'');
  var c=n.indexOf(',');                      // 첫 쉼표 앞이 품목의 본이름(뒤는 규격·색·수량)
  if(c>=2) n=n.substring(0,c);
  return n.substring(0,8);
}
/* ★무엇으로 좁힐지 — 순서가 중요하다 (2026-08-01 "상품코드와는 상관없네요").
     이 목록은 **거래처가 보낸 코드·거래처가 쓰는 품명**이다. 우리 상품코드와는 아무 관계가 없고
     (관계가 있으면 애초에 미매핑이 아니다), 품명도 거래처마다 제 식으로 적어 온다.
     그래서 우리 품명으로 좁히면 헛치기 쉽다. 실제로 맞는 것을 찾아 주는 근거는 **규격**이다
     — 이 프로젝트가 후보 추천에서 단가·규격을 1순위로 두는 것과 같은 이유다.
       ① 위 검색칸에 직접 친 말 (사람이 뜻을 갖고 넣은 것이니 최우선)
       ② 잡혀 있는 품목의 규격
       ③ 그래도 없으면 품명 핵심조각
     ②③은 걸어 보고 0건이면 다음으로 넘어가고, 다 없으면 전체를 보여 준다. */
function _xrTry(q){                     // 그 말로 몇 건이 남는지 (실제 그리기 규칙 그대로)
  var el=document.getElementById('xrPickQ'); if(!el) return 0;
  var keep=el.value; el.value=q;
  var n=xrPickRows().length; el.value=keep; return n;
}
function xrPickSeed(){
  var mq=((document.getElementById('q')||{}).value||'').trim();
  if(mq) return { q:mq, why:'위 <b>검색</b> 에 넣은 말로 좁혔습니다' };
  var P=(typeof HVP!=='undefined') ? HVP : null;
  if(P){
    var sp=String(P.spec||'').trim();
    if(sp && _xrTry(sp)) return { q:sp, why:'잡혀 있는 품목의 <b>규격 '+esc(sp)+'</b> 으로 좁혔습니다 <span style="color:#b3760f">(품명은 거래처마다 달라 규격이 더 정확합니다)</span>' };
    var f=_xrFrag(P.prodNm);
    if(f && _xrTry(f)) return { q:f, why:'잡혀 있는 품목 <b>['+esc(P.prodCd)+'] '+esc(P.prodNm)+'</b> 의 품명으로 좁혔습니다' };
  }
  return { q:'', why:'' };
}
function xrPickClear(){
  var q=document.getElementById('xrPickQ'); if(q){ q.value=''; q.focus(); }
  var w=document.getElementById('xrPickWhy'); if(w) w.innerHTML='';
  xrPickDraw();
}
function xrPickOpen(){
  fetch(CTX+'/prod/xrefUnmapped.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.text(); })
    .then(function(t){
      var j; try{ j=JSON.parse(t); }catch(e){ toast('⚠️ 조회 오류'); return; }
      var rows=(j&&j.data)||[];
      if(!rows.length){ toast('미매핑 코드가 없습니다.'); return; }
      window._xrPick = rows;
      _xrPickOv().style.display='flex';
      var q=document.getElementById('xrPickQ'); if(q) q.value='';
      var s=xrPickSeed();
      if(q) q.value=s.q;
      var w=document.getElementById('xrPickWhy');
      if(s.q && xrPickRows().length===0){       // ①(사람이 친 말)로 좁혔는데 없을 때 — 전체로 되돌린다
        if(q) q.value='';
        s={ q:'', why:'그 말로는 미매핑이 없어 <b>전체</b> 를 보여 줍니다' };
      }
      /* ★이 창은 조회용 — 고르면 닫히고, 무엇에 붙일지는 [＋ 연결] 줄에서 정한다(2026-08-01 결정).
           위 목록에서 품목을 미리 잡을 필요가 없다는 점은 여기서 분명히 해 둔다. */
      if(w) w.innerHTML = (s.why ? ('🔎 '+s.why+' — 다르면 <b>전체 보기</b>. ') : '')
        + '<span style="color:#b3760f">이 코드들은 <b>거래처가 보낸 코드·품명</b>이라 우리 상품코드와 겹치지 않습니다.'
        + ' 고르면 <b>[＋ 연결]</b> 줄에 규격·단가로 찾은 우리 품목 후보가 뜹니다 — 위 목록을 미리 고르지 않아도 됩니다.</span>';
      xrPickDraw();
      if(q){ q.focus(); q.select(); }
    })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
/* ★[미매핑에서 고르기] 는 조회용이다 — 코드를 골라 입력칸에 채우기만 한다 (2026-08-01 결정).
     연결 대상(우리 품목)은 아래 [＋ 연결] 줄에서 정한다.

     왜 이렇게 나눴나 :
       · 위 목록에서 우리 품목을 먼저 잡으라고 하면, **어느 품목인지 알려면 이미 매칭을 알아야 한다**
         — 모르니까 이 창을 여는 것이라 앞뒤가 맞지 않았다("그것도 모르고 일단 선택인가요").
       · 그렇다고 조회 창에서 바로 연결해 버리면, 이 창이 목록도 되고 저장도 하는 두 일을 하게 된다.
       · 그래서 창은 **고르기까지만**, 무엇에 붙일지는 저장 버튼이 있는 줄에서 — 손이 한 자리에 모인다.

     코드를 고르면 그 코드에 맞을 만한 우리 품목을 규격·단가로 찾아(`/prod/xrefCandidates.do`)
     연결 줄에 띄운다. 거기서 고른 것이 연결 대상이 되고, 아무것도 안 고르면 위 목록에서
     잡아 둔 품목(HVP)에 붙는다 — 종전 방식도 그대로 살아 있다. */
var _xrTgt=null;          // 연결 대상으로 고른 후보 {prodSeq, prodCd, prodNm}
var _xrCandCache={};      // 코드별 후보 (같은 코드를 다시 고를 때 서버를 또 부르지 않게)

function xrTgtClear(){ _xrTgt=null; var b=document.getElementById('xr_tgtBar'); if(b){ b.style.display='none'; b.innerHTML=''; } }
function xrTgtPick(k){
  var L=(_xrCandCache[gv('xr_extCd')]||[]);
  _xrTgt = (k<0) ? null : L[k];
  xrTgtDraw(L);
}
function _xrN(v){ return (v==null||v==='') ? '-' : Number(v).toLocaleString(); }
function xrTgtDraw(cands){
  var b=document.getElementById('xr_tgtBar'); if(!b) return;
  b.style.display='flex';
  var cd=gv('xr_extCd');
  if(cands===null){ b.innerHTML='<span style="color:#8a97a3;font-size:12.5px">🔎 <b>'+esc(cd)+'</b> 에 맞을 만한 우리 품목을 찾는 중…</span>'; return; }

  /* 고른 것이 있으면 그것만 크게 보여 준다 — 무엇에 붙는지가 [＋ 연결] 바로 위에 있어야 한다 */
  if(_xrTgt){
    b.innerHTML='<span style="font-size:12.5px;color:#5a6b7a">연결 대상</span>'
      + '<span style="background:#e6f7f0;border:1px solid #9ed6c6;border-radius:6px;padding:3px 10px;font-size:13px">'
      +   '<b style="color:#137a6c">'+esc(_xrTgt.prodCd)+'</b> '+esc(_xrTgt.prodNm)
      +   '<span style="color:#6b7a89;font-size:12px;margin-left:8px">'+esc(_xrTgt.extSpec||'')+'</span>'
      +   '<span style="color:#6b7a89;font-size:12px;margin-left:8px">판매가 '+_xrN(_xrTgt.salePrice)+' · 재고 '+_xrN(_xrTgt.curQty)+'</span>'
      + '</span>'
      + '<button class="btn" onclick="xrTgtPick(-1)" title="다시 고릅니다">↩ 다시</button>'
      + '<span style="color:#b3760f;font-size:12px">규격·단가가 맞는지 보고 <b>[＋ 연결]</b></span>';
    return;
  }
  /* ★후보가 마땅찮을 때 쓰는 [직접 찾기] — 매핑 화면과 같은 장치다(2026-08-01 요청).
       상품마스터는 이미 화면에 다 들어와 있으므로(PROD) 서버를 부르지 않고 그 자리에서 찾는다. */
  var findBtn = '<button class="btn" onclick="xrFindToggle()" title="상품마스터에서 직접 찾습니다">🔍 직접 찾기</button>'
    + '<span id="xr_findWrap" style="display:none;align-items:center;gap:6px">'
    +   '<input id="xr_findQ" placeholder="코드 · 상품명 · 규격" oninput="xrFindDraw()" autocomplete="off"'
    +     ' style="height:28px;border:1px solid var(--bd);border-radius:6px;padding:0 10px;width:240px">'
    + '</span>';

  if(!cands || !cands.length){
    b.innerHTML='<span style="font-size:12.5px;color:#c07a02;white-space:nowrap">⚠ <b>'+esc(cd)+'</b> 에 맞을 만한 우리 품목을 못 찾았습니다</span>'
      + findBtn
      + '<span style="font-size:12px;color:#6b7a89">또는 위 목록에서 품목 행을 클릭해 잡은 뒤 <b>[＋ 연결]</b>'
      + (HVP ? ' (지금 잡힌 품목: <b>'+esc(HVP.prodCd)+'</b> '+esc(HVP.prodNm||'')+')' : '')+'</span>'
      + '<div id="xr_findRes" style="flex-basis:100%;display:flex;flex-wrap:wrap;gap:6px"></div>';
    return;
  }
  /* 후보가 여럿이면 버튼으로 늘어놓는다 — 드롭다운은 규격·단가를 나란히 못 보여 준다 */
  b.innerHTML='<span style="font-size:12.5px;color:#5a6b7a;white-space:nowrap">연결 대상 고르기</span>'
    + '<div style="display:flex;flex-wrap:wrap;gap:6px;align-items:center">'
    + cands.map(function(c,k){
        var dead=(!c.curQty||Number(c.curQty)===0) && !c.lastOutDt;   // 재고도 거래도 없으면 옛 가상코드일 수 있다
        return '<button class="btn" onclick="xrTgtPick('+k+')" style="height:auto;padding:3px 10px;text-align:left;line-height:1.35'
          + (dead?';opacity:.6':'')+'" title="'+esc(c.prodNm)+'">'
          + '<b style="color:#137a6c">'+esc(c.prodCd)+'</b> '
          + '<span style="font-size:12px">'+esc(String(c.prodNm||'').substring(0,26))+'</span>'
          + '<span style="color:#6b7a89;font-size:11.5px;margin-left:6px">'+esc(c.extSpec||'')+'</span>'
          + '<span style="color:#6b7a89;font-size:11.5px;margin-left:6px">'+_xrN(c.salePrice)+'원 · 재고 '+_xrN(c.curQty)+'</span>'
          + '<span style="color:#b3760f;font-size:11.5px;margin-left:6px;font-weight:700">'+esc(c.matchWhy||'')+'</span>'
          + '</button>';
      }).join('')
    + findBtn
    + '</div><div id="xr_findRes" style="flex-basis:100%;display:flex;flex-wrap:wrap;gap:6px"></div>';
}
/* ---- 직접 찾기 (상품마스터에서 고르기) ---- */
function xrFindToggle(){
  var w=document.getElementById('xr_findWrap'); if(!w) return;
  var on = (w.style.display==='none');
  w.style.display = on ? 'inline-flex' : 'none';
  var q=document.getElementById('xr_findQ');
  if(on && q){
    /* 거래처 규격을 첫 검색어로 넣어 준다 — 이름은 거래처마다 달라도 규격은 같다 */
    if(!q.value) q.value = gv('xr_extSpec') || '';
    q.focus(); q.select(); xrFindDraw();
  } else { var r=document.getElementById('xr_findRes'); if(r) r.innerHTML=''; }
}
function xrFindDraw(){
  var r=document.getElementById('xr_findRes'); if(!r) return;
  var q=((document.getElementById('xr_findQ')||{}).value||'').trim().toLowerCase();
  if(!q){ r.innerHTML='<span style="color:#8a97a3;font-size:12px">코드·상품명·규격을 입력하세요</span>'; return; }
  var ws=q.split(/\s+/).filter(Boolean);
  var hit=PROD.filter(function(o){
    var hay=[o.prodCd,o.prodNm,o.spec,o.makerNm].map(function(x){ return String(x||'').toLowerCase(); }).join(' ');
    return ws.every(function(w){ return hay.indexOf(w)>=0; });
  }).slice(0,30);
  window._xrFind=hit;
  r.innerHTML = hit.length
    ? hit.map(function(o,k){
        return '<button class="btn" onclick="xrFindPick('+k+')" style="height:auto;padding:3px 10px;text-align:left;line-height:1.35" title="'+esc(o.prodNm)+'">'
          + '<b style="color:#137a6c">'+esc(o.prodCd)+'</b> '
          + '<span style="font-size:12px">'+esc(String(o.prodNm||'').substring(0,26))+'</span>'
          + '<span style="color:#6b7a89;font-size:11.5px;margin-left:6px">'+esc(o.spec||'')+'</span>'
          + '<span style="color:#6b7a89;font-size:11.5px;margin-left:6px">'+_xrN(o.salePrice)+'원</span>'
          + '</button>';
      }).join('') + (hit.length>=30 ? '<span style="color:#8a97a3;font-size:12px">…30개까지만</span>' : '')
    : '<span style="color:#c07a02;font-size:12px">찾는 품목이 없습니다 — 검색어를 줄여 보세요</span>';
}
function xrFindPick(k){
  var o=(window._xrFind||[])[k]; if(!o) return;
  _xrTgt={ prodSeq:o.prodSeq, prodCd:o.prodCd, prodNm:o.prodNm, extSpec:o.spec, salePrice:o.salePrice, curQty:null };
  xrTgtDraw(_xrCandCache[gv('xr_extCd')]||[]);
}
/* 코드가 정해지면 후보를 찾아 연결 줄에 띄운다 */
function xrTgtLoad(extCd, extNm){
  _xrTgt=null;
  if(!extCd){ xrTgtClear(); return; }
  if(_xrCandCache[extCd]){ xrTgtDraw(_xrCandCache[extCd]); return; }
  xrTgtDraw(null);
  fetch(CTX+'/prod/xrefCandidates.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'extItemCd='+encodeURIComponent(extCd)+'&extItemNm='+encodeURIComponent(extNm||'') })
    .then(function(r){ return r.json(); })
    .then(function(j){ var c=(j&&j.data)||[]; _xrCandCache[extCd]=c; xrTgtDraw(c); })
    .catch(function(){ _xrCandCache[extCd]=[]; xrTgtDraw([]); });
}
function xrPick(i){
  var o=(window._xrPick||[])[i]; if(!o) return;
  xrPickClose();
  document.getElementById('xr_extCd').value   = o.extItemCd||'';
  document.getElementById('xr_extNm').value   = o.extItemNm||'';
  document.getElementById('xr_extSpec').value = o.extSpec||'';
  document.getElementById('xr_extUnit').value = o.extUnit||'';
  if(o.vendorNm) document.getElementById('xr_venNm').value = o.vendorNm;
  xrTgtLoad(o.extItemCd, o.extItemNm);   // 그 코드에 맞을 만한 우리 품목을 연결 줄에 띄운다
  toast('채웠습니다 — 아래 <b>연결 대상</b> 에서 우리 품목을 고른 뒤 [＋ 연결]');
}

/* ---- 매입가 ---- */
function hvLoadIn(){
  _listPost('/prod/inpriceList.do', HVP.prodSeq).then(function(j){
    var rows=(j&&j.data)||[], tb=document.getElementById('in_tb');
    if(!rows.length){ tb.innerHTML='<tr><td colspan="6" class="empty">이력이 없습니다. 매입등록 전표를 저장하면 쌓입니다.</td></tr>'; return; }
    tb.innerHTML = rows.map(function(o){
      return '<tr><td>'+fmtDt(o.applyDt)+'</td><td>'+esc(o.vendorNm)+'</td><td class="num">'+num(o.inPrice)+'</td>'
        +'<td class="num">'+num(o.prevPrice)+'</td><td>'+esc(o.remark)+'</td><td>'+esc(o.regDttm)+'</td></tr>';
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
  one('매출', function(d){ SVENDORS=d; xrVenFill(); });   // 거래처 코드 탭 datalist 도 같이 채운다
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
/* hvAddIn() 제거 — 매입단가 수기 등록은 매입등록 전표로 일원화(2026-07-25).
   서버 /prod/inpriceInsert.do 는 남아 있으니 되살릴 일이 있으면 이 함수와 입력줄만 복구하면 된다. */

/* ---- 판매가 ---- */
function hvLoadSale(){
  _listPost('/prod/salepriceList.do', HVP.prodSeq).then(function(j){
    var rows=(j&&j.data)||[], tb=document.getElementById('sl_tb');
    if(!rows.length){ tb.innerHTML='<tr><td colspan="8" class="empty">이력이 없습니다. 판매등록 전표나 정산서 업로드에서 쌓입니다.</td></tr>'; return; }
    tb.innerHTML = rows.map(function(o){
      var mr=(o.marginRt==null?'':Number(o.marginRt).toFixed(1)+'%');
      var vn = o.vendorCd ? esc(o.vendorNm||o.vendorCd) : '<span style="color:#9aa7b3">공통</span>';
      return '<tr><td>'+fmtDt(o.applyDt)+'</td><td>'+vn+'</td><td class="num">'+num(o.salePrice)+'</td><td class="num">'+num(o.wholePrice)+'</td>'
        +'<td class="num">'+num(o.baseInprice)+'</td><td class="num">'+mr+'</td><td>'+esc(o.remark)+'</td><td>'+esc(o.regDttm)+'</td></tr>';
    }).join('');
  });
}
/* hvAddSale() 제거 — 판매단가 수기 등록은 판매등록 전표·정산서 업로드로 일원화(2026-07-25).
   서버 /prod/salepriceInsert.do 는 남아 있으니 되살릴 일이 있으면 이 함수와 입력줄만 복구하면 된다. */
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
      hd.innerHTML='총 <b>'+rows.length.toLocaleString()+'</b>행 · 단가 <b>'+Object.keys(prices).length+'</b>종 · 출고량 <b>'+num(q)+'</b> · 매출액 <b>'+num(a)+'</b>';   // 원본 안내('견적서관리 ▸ 매출 엑셀 업로드')는 없는 화면을 가리켜 걷어냈다(2026-07-25)
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
      if(!rows.length){ tb.innerHTML='<tr><td colspan="10" class="empty">수불 내역이 없습니다.</td></tr>'; return; }
      /* 출처 = 이 줄을 만든 전표. 전표에서 온 줄은 여기서 지우면 전표만 남고 재고가 틀어지므로
         삭제 버튼을 안 준다. 되돌리려면 그 전표를 고치거나 지워야 한다(2026-07-25). */
      var SRC={ PURCH:'매입등록', SALE:'판매등록', SHIPOUT:'발주현황표' };
      tb.innerHTML = rows.map(function(o){
        var bd='<span class="badge" style="background:'+(IO_COLOR[o.ioGb]||'#888')+'">'+(IO_MAP[o.ioGb]||o.ioGb)+'</span>';
        var g=o.refGb||'', src = g
              ? '<span title="'+esc((SRC[g]||g)+' '+(o.refNo||''))+'">'+esc(SRC[g]||g)+(o.refNo?(' <span style="color:#9aa7b3">'+esc(o.refNo)+'</span>'):'')+'</span>'
              : '<span style="color:#137a6c;font-weight:700">수기 조정</span>';
        var del = g ? '<span style="color:#c9d2da" title="전표에서 만들어진 줄입니다. '+esc(SRC[g]||g)+' 화면에서 고치거나 지우세요.">—</span>'
                    : '<button class="btn btn-danger" onclick="hvDel(\'stock\','+o.ledgerSeq+')">삭제</button>';
        return '<tr><td>'+fmtDt(o.trxDt)+'</td><td>'+bd+'</td><td class="num">'+num(o.qty)+'</td><td class="num">'+num(o.unitPrice)+'</td>'
          +'<td class="num">'+num(o.amt)+'</td><td>'+esc(vendorNmOf(o.vendorCd)||o.vendorCd)+'</td><td>'+src+'</td>'
          +'<td>'+esc(o.remark)+'</td><td>'+esc(o.regDttm)+'</td>'
          +'<td>'+del+'</td></tr>';
      }).join('');
    });
}
/* 조정 단가 자동채움 — 재고금액을 얼마로 움직일지의 기준이라 품목마스터 매입가를 쓴다.
   (입고/출고/반품 분기는 그 입력이 사라져 함께 걷어냈다 — 2026-07-25) */
function hvStockPrefill(force){
  if(!HVP) return;
  var cur=gv('st_price');
  if(!force && cur!=='' && Number(cur)!==0) return;   // 수량 입력 시엔 수동 입력한 단가 보존
  document.getElementById('st_price').value = (HVP.inPrice!=null ? HVP.inPrice : 0);
}
/* 수불 수기 입력 = 조정(A) 전용. 입고·출고·반품은 전표가 만든다(2026-07-25).
   ioGb 를 화면 값이 아니라 'A' 로 못박는다 — 드롭다운에 조정만 남겼지만
   개발자 도구로 값을 바꿔 넣는 길까지 막아 둔다. 사유(remark)는 필수 :
   조정은 왜 맞췄는지가 남아야 나중에 되짚을 수 있다. */
function hvAddStock(){
  var qty=gnum('st_qty'); if(qty==null || qty===0){ toast('⚠️ 조정 수량을 입력하세요. (늘리면 +, 줄이면 −)'); return; }
  var rm=(gv('st_remark')||'').trim();
  if(!rm){ toast('⚠️ 조정 사유를 적어 주세요. (예: 실사 차이 · 파손 폐기)'); return; }
  var up=gnum('st_price');
  var dto={ prodSeq:HVP.prodSeq, prodCd:HVP.prodCd, trxDt:gv('st_dt')||today(),
    ioGb:'A', qty:qty, unitPrice:up, vendorCd:null, remark:rm };
  _post('/prod/stockInsert.do', dto).then(function(r){
    if(!r.ok){ toast('⚠️ 실패(HTTP '+r.status+'): '+(r.t||'').slice(0,120)); return; }
    document.getElementById('st_remark').value=''; document.getElementById('st_qty').value='0';
    toast('📦 재고 조정 · 현재고 반영');
    hvLoadStock(); prodLoad();
  });
}

/* ---- 공통 삭제 ---- */
/* 남은 삭제 대상은 '재고 수기조정' 하나뿐이다(2026-07-25).
   매입가·판매가 이력은 전표가 만든 파생이라 여기서 지우면 전표와 어긋나 삭제 버튼을 뺐다.
   kind 인자는 호출부 호환을 위해 남겨 두었다. */
function hvDel(kind, seq){
  swConfirm('이 조정 내역을 삭제하시겠습니까?','삭제').then(function(ok){ if(!ok) return;
    var url='/prod/stockDelete.do';
    var dto={ledgerSeq:seq, prodSeq:HVP.prodSeq, prodCd:HVP.prodCd};   // 재고는 재집계 위해 prodSeq 동봉
    _post(url, dto).then(function(r){
      if(!r.ok){ toast('⚠️ 삭제 실패(HTTP '+r.status+')'); return; }
      toast('🗑️ 삭제 완료');
      hvLoadStock(); prodLoad();
    });
  });
}

prodLoad();
vendorLoad();   // 매입처 선택 목록 채우기 (거래처 마스터 '매입' 거래처 — 위 찾기 입력으로 좁히기)
// 진입 시 날짜 기본값 = 오늘 (품목 클릭 전에도 비어있지 않게. 품목 클릭 시 hvOpen 이 다시 오늘로 셋팅)
['st_dt'].forEach(function(id){ var e=document.getElementById(id); if(e && !e.value) e.value=today(); });
</script>
</body>
</html>
