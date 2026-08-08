<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
  
<meta charset="UTF-8">
<%-- defer(2026-07-31 속도): CDN 스크립트가 head 에서 첫 렌더를 막지 않게. swAlert/swConfirm 은 window.Swal 가드가 있어 안전 --%>
<script defer src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%-- 공통 알림/확인 표준(_alertBox/_confirmBox/_toast — 로그인 화면과 동일 스타일). 새 알림·확인은 이걸 쓸 것 --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<style>
  /* SWAL 확인/알림 모달 축소 (토스트 제외) */
  .swal2-popup:not(.swal2-toast){ width:440px!important; padding:1.1em 1em 1.2em!important; font-size:14px; }
  /* ★아이콘 크기를 줄이지 않는다 (2026-08-07 수정) —
     SweetAlert 의 X·느낌표 선은 기본 5em 아이콘에 맞춰 em 값으로 박혀 있어,
     3em 으로 줄이면 선이 엉뷱한 데 놓여 ✖ 가 깨져 보인다(사용자 지적).
     여백만 좀 줄이고 크기는 기본값을 그대로 둔다. */
  .swal2-popup:not(.swal2-toast) .swal2-icon{ margin:.6em auto .3em; }
  /* ★오류 아이콘 — 동그라미 테두리를 없애고 ✖ 만 굵게 (2026-08-07, 로그인 화면 스타일에 맞춤).
     SweetAlert 기본은 '원 안에 X' 인데, 앱의 다른 메시지는 테두리 없는 굵은 X 다. */
  .swal2-popup:not(.swal2-toast) .swal2-icon.swal2-error{ border:0; }
  .swal2-popup:not(.swal2-toast) .swal2-icon.swal2-error [class^='swal2-x-mark-line']{ height:.42em; border-radius:.21em; }
  .swal2-popup:not(.swal2-toast) .swal2-title{ font-size:1.2em; padding:.2em 1em 0; }
  .swal2-popup:not(.swal2-toast) .swal2-html-container{ font-size:.95em; margin:.5em 1em 0; }
  .swal2-popup:not(.swal2-toast) .swal2-actions{ margin-top:1em; }
  /* 확인 버튼은 앱의 다른 메시지처럼 넓게 — 좀았던 버튼이 한눈에 달라 보였다 */
  .swal2-popup:not(.swal2-toast) .swal2-styled{ padding:.62em 2em; font-size:1em; min-width:210px; border-radius:.4em; }
</style>
<style>
  

  :root { --logi-teal:#1f9b8e; --logi-teal-dark:#178074; --logi-border:#dfe6e3; --logi-bg:#f4f8f7; }
  /* 흐린 회색 글자를 진한 색으로 (또렷하게) */
  .logi-wrap .sub, .logi-wrap .wh-meta, .logi-wrap .note,
  .logi-wrap .form-row label, .logi-wrap .kpi .k-lbl,
  .logi-wrap .loc-legend, .logi-wrap table.logi-tb thead th,
  .logi-wrap .grp, .logi-wrap .flow .step, .logi-wrap .lc-st { color:#1f2a37 !important; }
  /* 본문 기본 글자색을 거의 검정으로 */
  .logi-wrap, .logi-wrap a.mi, .logi-wrap table.logi-tb td,
  .logi-wrap input, .logi-wrap select, .logi-wrap .chip { color:#10161d; }
  /* 입력값 placeholder 도 또렷하게 */
  .logi-wrap ::placeholder { color:#5b6775; opacity:1; }

  /* ★화면 글꼴 통일 (2026-08-03) — 셸·모든 iframe 화면이 같은 글꼴/기본 크기를 쓴다.
     기준: '맑은 고딕' 13.5px. 표·버튼 등 자체 크기를 지정한 곳은 그대로 유지된다. */
  .logi-wrap { font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; }
  .logi-wrap input, .logi-wrap select, .logi-wrap button, .logi-wrap textarea { font-family:inherit; }

  /* 전체 셸: 좌측 사이드바 + 우측 콘텐츠 */
  .logi-wrap { display:flex; min-height:100vh; background:#fff; font-weight:700; }
  /* 전역 글자 진하게: 기본 700, 강조 800~900 */
  .logi-wrap, .logi-wrap input, .logi-wrap select, .logi-wrap button, .logi-wrap table,
  .logi-wrap a.mi, .logi-wrap td, .logi-wrap .sub, .logi-wrap .wh-meta,
  .logi-wrap .note, .logi-wrap label, .logi-wrap .chip { font-weight:700; }
  .logi-wrap b, .logi-wrap strong, .logi-wrap th, .logi-wrap .wh-nm, .logi-wrap .loc,
  .logi-wrap .lc-code, .logi-wrap h2, .logi-wrap h3, .logi-wrap .k-val,
  .logi-wrap a.mi.on, .logi-wrap .side-tit { font-weight:900; }

  /* ★셸을 <화면 높이에 고정>한다 (2026-08-05 요청) — 스크롤은 <좌측 메뉴 안>과 <본문 안>에서만 일어난다.
       종전 : 문서(body)가 통째로 스크롤됐다. .logi-main 은 overflow:auto 라 sticky 의 기준 상자가
              되지만, 높이가 내용을 따라 늘어나 <자기 안에서는 스크롤이 없었다> → 상단
              <자주 쓰는 메뉴> 줄의 sticky 가 걸리지 않고 목록이 긴 화면에서 위로 밀려 사라졌다.
              (iframe 화면은 안쪽에서만 스크롤돼 안 밀리니 '화면마다 다르게' 보였다)
              좌측 메뉴도 같이 밀려 올라가 로그아웃까지 내리려면 본문이 함께 움직였다.
       이제 : .logi-wrap 을 100vh 로 잘라 문서는 아예 스크롤되지 않는다.
              좌측 메뉴는 자기 안에서(overflow-y:auto), 본문은 .logi-main 안에서 스크롤한다.
       ※ body 기본 여백 8px 을 없앤다 — 남겨 두면 그만큼 문서가 또 스크롤돼 위 두 개가 다시 밀린다.
       ※ box-sizing 이 없으면 .logi-side 의 아래 여백 30px 이 100vh 밖으로 나가 [로그아웃]이 잘린다.
       ※ logiGo 의 `.logi-main.scrollTop=0`(화면 바꾸면 맨 위로)도 이제야 실제로 동작한다. */
  html, body { margin:0; padding:0; }
  .logi-wrap { height:100vh; overflow:hidden; }
  .logi-side, .logi-main { box-sizing:border-box; }

  /* 좌측 사이드바 */
  .logi-side { width:236px; flex:0 0 236px; background:#1f2a37; color:#cdd6e0; padding:0 0 30px;
               height:100vh; position:sticky; top:0; overflow-y:auto; overflow-x:hidden; }
  /* 사이드메뉴 스크롤바 (화면 확장/항목 많을 때) */
  .logi-side::-webkit-scrollbar { width:8px; }
  .logi-side::-webkit-scrollbar-thumb { background:#3a4a5c; border-radius:4px; }
  .logi-side::-webkit-scrollbar-track { background:#1f2a37; }
  /* 주메뉴(접기/펼치기) + 서브메뉴 */
  .logi-side a.mi.has-sub { justify-content:flex-start; }
  .logi-side a.mi.has-sub .caret { margin-left:auto; font-size:10px; transition:transform .15s; }
  .logi-side a.mi.has-sub.open .caret { transform:rotate(90deg); }
  .logi-side .sub-menu { display:none; background:#1a232e; }
  .logi-side .sub-menu.open { display:block; }
  .logi-side .sub-menu a.mi { padding-left:34px; font-size:12.5px; padding-top:5px; padding-bottom:5px; }
  .logi-side .side-tit { padding:18px 20px; font-size:17px; font-weight:700; color:#fff; border-bottom:1px solid #2c3a4a; }
  .logi-side .side-tit small { display:block; font-size:11px; font-weight:400; color:#8a98a8; margin-top:3px; }
  /* 로그인 회사명 — 대시보드 메뉴 위, 물류관리 제목과 같은 17px (2026-07-31 요청) */
  .logi-side .side-comp { padding:12px 20px 6px; font-size:17px; font-weight:700; color:#ffd98a; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  /* 메뉴 간격 — 그룹이 6개로 늘어 세로가 길어져 촘촘하게 줄였다(2026-07-25 요청) */
  .logi-side .grp { padding:9px 20px 3px; font-size:11px; letter-spacing:.5px; color:#7d8b9c; }
  .logi-side a.mi { display:flex; align-items:center; gap:8px; padding:6px 20px; color:#cdd6e0; text-decoration:none; font-size:13.5px; border-left:3px solid transparent; cursor:pointer; }
  .logi-side a.mi:hover { background:#28333f; color:#fff; }
  .logi-side a.mi.on { background:var(--logi-teal); color:#fff; border-left:5px solid #0b5a52; padding-left:16px; font-weight:800; box-shadow:inset -3px 0 0 rgba(255,255,255,.18); }
  .logi-side a.mi.on .ic, .logi-side a.mi.on .caret { color:#fff; }
  .logi-side .sub-menu a.mi.on { padding-left:30px; }
  .logi-side a.mi .ic { width:18px; text-align:center; }
  .logi-side a.mi.core { color:#aef0e7; }
  /* ── 자주 쓰는 메뉴(최대 5개) ─────────────────────
       메뉴에 마우스를 올리면 오른쪽 끝에 ☆ 가 나온다. 담긴 메뉴는 ★(노랑)로 항상 보인다. */
  /* ☆ 는 평소 아주 흐리게라도 보여 둔다 — 완전히 감춰 두면 기능이 있는 줄 모른다(2026-08-04) */
  .logi-side a.mi .fav { margin-left:auto; padding:0 2px; font-size:12px; color:#5d6b7c; opacity:.35; transition:opacity .12s, color .12s; }
  .logi-side a.mi:hover .fav { opacity:1; }
  .logi-side a.mi .fav.on { opacity:1; color:#ffd15c; }
  .logi-side a.mi .fav:hover { color:#ffd15c; }
  .logi-side a.mi.has-sub .fav { display:none; }        /* 펼침 메뉴는 화살표 자리라 제외 */
  /* ── 상단 공통 영역 : 자주 쓰는 메뉴 줄 ─────────────────────
       우측 본문 맨 위에 고정. 어느 화면을 열어도 같은 자리에 있고, 내려도 따라온다. */
  #favBar { position:sticky; top:0; z-index:60; display:flex; align-items:center; gap:6px; flex-wrap:wrap;
            margin:-22px 0 12px; padding:8px 14px; background:#fff; border-bottom:1px solid #e2e8e6;
            box-shadow:0 1px 4px rgba(31,42,55,.06); }
  #favBar .ft { font-size:13.5px; font-weight:800; color:#8a7526; white-space:nowrap; }
  #favBar #favCnt { color:#a9b3bd; font-weight:600; }
  #favBar #favList { display:flex; align-items:center; gap:6px; flex-wrap:wrap; }
  /* 글자 12.5 → 14px (2026-08-04 요청) — 10개까지 늘어 한 줄을 넘길 수 있으므로 위 flex-wrap 으로 접힌다 */
  #favBar a.favmi { display:inline-flex; align-items:center; gap:6px; padding:5px 14px; border-radius:18px;
                    border:1px solid #e6d29a; background:#fffbef; color:#5a4b13; font-size:14px; font-weight:700;
                    text-decoration:none; cursor:pointer; white-space:nowrap; }
  #favBar a.favmi:hover { background:#fff3d0; border-color:#e0be6a; }
  #favBar a.favmi.on { background:var(--logi-teal); border-color:var(--logi-teal); color:#fff; }
  #favBar a.favmi .pin { font-size:11px; opacity:.85; }
  #favBar a.favmi .x { color:#b9a45f; font-weight:800; padding-left:3px; font-size:13px; }
  #favBar a.favmi .x:hover { color:#c0392b; }
  #favBar a.favmi.on .x { color:#cfeee8; }
  #favBar #favHint { font-size:13px; color:#9aa7b3; }
  #favBar #favHint b { color:#d8a92a; }
  #favBar #favClearBtn { margin-left:auto; font-size:12px; color:#9aa7b3; cursor:pointer; white-space:nowrap; }
  #favBar #favClearBtn:hover { color:#c0392b; }

  /* ★그 줄을 화면 맨 위에 <딱> 붙인다 (2026-08-05 요청) —
       sticky 는 스크롤 상자의 <안쪽 위 여백(padding-top)> 아래에서 멈춘다. 본문 위 여백이 남아 있으면
       그 틈(12~22px)으로 스크롤되는 내용이 줄 위를 비쳐 지나간다. 그래서 본문의 <위> 여백을 0 으로 두고
       그 자리를 favBar 가 직접 갖는다 — 종전 '패딩 22 + 마진 -22' 상쇄와 화면 결과는 같다.
       ※ 태블릿(≤1100px)은 제외 : 거기 위 여백 46px 은 ☰ 버튼 자리다.
       ※ konet-notebook.css 가 뒤에 로드되며 padding 을 다시 넣으므로 특이성을 한 단계 올렸다(body …). */
  @media screen and (min-width:1101px){
    body .logi-wrap .logi-main { padding-top:0; }
    body #favBar { margin-top:0; }
  }

  /* ── 좌측 메뉴 접기 · 펼치기 (2026-08-05 요청) ─────────────────────
       왜 : 위 <자주 쓰는 메뉴> 줄로 자주 보는 화면은 메뉴 없이도 갈 수 있게 되어,
            236px 짜리 좌측 메뉴를 접고 본문을 넓게 쓸 수 있다(표가 한 화면에 더 들어온다).
       버튼 : <자주 쓰는 메뉴> 줄 맨 앞 <하나>뿐이다 — 접으나 펴나 같은 자리라 잃어버리지 않는다.
       ★태블릿(폭 ≤1100px)에는 걸지 않는다 — 거기서는 이미 메뉴가 화면 밖에 서 있고
         ☰(konet-notebook.css / konetSideToggle)로 꺼내 쓴다. 두 벌이 겹치면 메뉴가 아예 안 나온다. */
  #favBar #sideFoldBtn { display:inline-flex; align-items:center; gap:5px; margin-right:4px; padding:5px 10px;
                         border:1px solid #cfd8dd; border-radius:8px; background:#f3f6f8; color:#3d4b59;
                         font-family:inherit; font-size:12.5px; font-weight:700; cursor:pointer; white-space:nowrap; }
  #favBar #sideFoldBtn:hover { background:#e7eef2; border-color:#9fb0bd; color:#1f2a37; }
  #favBar #sideFoldBtn .fi { font-size:13px; }
  @media screen and (min-width:1101px){
    /* 폭만 줄인다 — 메뉴는 DOM 에 그대로 있어야 한다(자주 쓰는 메뉴 칩이 원래 메뉴의 onclick 을 부른다) */
    .logi-wrap .logi-side { transition:width .16s ease-out, flex-basis .16s ease-out; }
    body.logi-side-fold .logi-wrap .logi-side { width:0; flex-basis:0; padding:0; overflow:hidden; }
  }
  @media screen and (max-width:1100px){ #favBar #sideFoldBtn { display:none; } }


  /* 우측 콘텐츠
     ★좌우 여백은 셸이 갖지 않는다 (2026-08-03) — iframe 화면은 여기 좌우 여백 위에 자기 여백을 또
       얹어 화면마다 좌우가 달라졌다. 좌우 0.3cm(11px)은 각 화면(.panel / iframe 안 wrap)이 가진다. */
  .logi-main { flex:1; padding:22px 0; background:var(--logi-bg); overflow:auto; }
  .logi-head { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
  .logi-head h2 { margin:0; font-size:20px; font-weight:700; color:#1f2a37; }
  .logi-head .sub { font-size:13px; color:#6b7a89; margin-top:4px; }
  .logi-head .actions { display:flex; gap:8px; }
  .btn-teal { background:var(--logi-teal); color:#fff; border:none; border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; }
  .btn-teal:hover { background:var(--logi-teal-dark); }
  .btn-line { background:#fff; color:#37475a; border:1px solid var(--logi-border); border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; }
  .btn-line:hover { background:#eef3f2; }
  .btn-teal:disabled, .btn-line:disabled { opacity:.42; cursor:not-allowed; }
  /* 재고현황 ① 선택행 — 클래스 하나로 표시한다(2026-08-06).
     행마다 인라인 style 을 지우고 다시 넣으면 그때마다 화면이 다시 계산돼 껌벅인다. */
  /* 선택행 — 옅은 색이라 어느 줄을 골랐는지 눈에 안 들어왔다(2026-08-07 지적).
     배경을 진하게 하고 왼쪽에 굵은 세로선을 둬 한눈에 잡히게 한다. */
  #stkStatusWrap tbody tr.stk-on td { background:#cfeae3 !important; font-weight:700; }
  #stkStatusWrap tbody tr.stk-on td:first-child { box-shadow: inset 4px 0 0 #137a6c; }
  #stkStatusWrap tbody tr { cursor:pointer; }
  #stkLedgerBody { will-change:opacity; }
  /* ★입·출고 나누어보기 — 표 머리줄 고정 (2026-08-07 요청).
     출고는 수백 줄이라 내리다 보면 어느 칸이 무엇인지 알 수 없게 된다.
     border-collapse 표는 sticky th 의 테두리가 같이 안 따라와 줄이 사라지므로
     box-shadow 로 위·아래 선을 그려 준다(거래처 목록에서 쓴 것과 같은 수법). */
  #stkSplitBody table thead th{
    position:sticky; top:0; z-index:3; background:#eef3f2;
    box-shadow:inset 0 1px 0 var(--logi-border), inset 0 -1px 0 var(--logi-border);
  }
  #stkSplitBody table tbody td{ position:relative; z-index:1; }
  /* ★표 머리줄 색 구분 (2026-08-07 요청)
       머리줄이 세 표 모두 같은 회색이라, 스크롤하면 지금 보는 게 입고인지 출고인지
       제목을 다시 올려다봐야 알 수 있었다. 제목에 이미 쓰는 색(입고 청록 / 출고 주황)을
       머리줄에도 그대로 입혀 색만 보고 구분되게 한다.
     ※ #stkSplitBody 쪽은 위 sticky 규칙이 background 를 이미 잡고 있어 더 구체적으로 덮어쓴다.
     ※ 처음엔 색을 옅게 뒀는데 머리줄과 자료가 구분이 안 됐다(2026-08-07 재지적) →
        배경을 한 단계 진하게, 글자는 굵게, 아래에 굵은 밑줄을 둬 경계를 분명히 한다. */
  #stkSplitBody table.sp-top thead th,
  #stkSplitBody table.sp-in  thead th,
  #stkSplitBody table.sp-out thead th,
  #stkLedgerBody table thead th,
  #stkStatusWrap table thead th{ font-weight:800; }
  /* 팝업 맨 위 '◆ 선택 품목' 요약표 — 입고/출고 어느 쪽도 아닌 머리말이라
     상단 ①현재고와 같은 회청색으로 둔다(2026-08-07 지적으로 추가). */
  #stkSplitBody table.sp-top thead th{ background:#c8d5e2; color:#1f2a37; border-color:#a8bacb;
                                       box-shadow:inset 0 -2px 0 #5a7a9a; }
  #stkSplitBody table.sp-in  thead th{ background:#b9ded4; color:#0b4f43; border-color:#93c7b9;
                                       box-shadow:inset 0 -2px 0 #0e6657; }
  #stkSplitBody table.sp-out thead th{ background:#f4dcbc; color:#6f4200; border-color:#dfbe8e;
                                       box-shadow:inset 0 -2px 0 #b06a00; }
  /* ②수불 내역(하단) = 입·출고가 섞인 표. 상단 ①과 헷갈리지 않게 청록 계열 */
  #stkLedgerBody table thead th{ background:#b9ded4; color:#0b4f43; border-color:#93c7b9;
                                 box-shadow:inset 0 -2px 0 #0e6657; }
  /* ①품목별 현재고(상단) — 아래 표들과 구분되게 회청색 */
  #stkStatusWrap table thead th{ background:#c8d5e2; color:#1f2a37; border-color:#a8bacb;
                                 box-shadow:inset 0 -2px 0 #5a7a9a; }
  /* 품목코드(매핑) 점검표 머리글 (2026-08-07 요청) — 글자를 한 단계 키우고 색을 진하게.
     자료 줄이 12.5px 라 머리글이 같은 크기·연한 색이면 어디까지가 머리인지 안 갈린다.
     색은 ①품목별 현재고와 같은 회청색 계열로 맞춰 화면끼리 따로 놀지 않게 한다. */
  /* 줄 높이도 한 단계 — 머리글이 자료 줄과 같은 높이면 표 위에 얹힌 띠처럼 안 보인다(2026-08-07) */
  #xaWrap table thead th{ background:#c8d5e2; color:#1f2a37; font-size:14.5px; font-weight:800;
                          padding:10px 8px; line-height:1.35;
                          box-shadow:inset 0 -2px 0 #5a7a9a; }
  /* 고른 줄 표시 (2026-08-07 요청) — 재고현황 ②수불 내역의 선택행과 같은 초록으로 맞춘다.
     ★!important — ① 미매핑 줄은 인라인으로 분홍(#fff6f6)이 칠해져 있어 그냥은 안 덮인다. */
  #xaBody tr{ cursor:pointer; }
  #xaBody tr.xa-on td{ background:#cfeae3 !important; font-weight:700; }
  #xaBody tr.xa-on td:first-child{ box-shadow: inset 4px 0 0 #137a6c; }
  .btn-teal:disabled:hover { background:var(--logi-teal); }
  .btn-line:disabled:hover { background:#fff; }

  /* 핵심 업무 흐름 띠 */
  .flow { display:flex; align-items:center; gap:8px; background:#fff; border:1px solid var(--logi-border); border-radius:10px; padding:12px 16px; margin-bottom:16px; font-size:13px; }
  .flow .step { display:flex; align-items:center; gap:6px; color:#37475a; }
  .flow .step b { color:var(--logi-teal-dark); }
  .flow .arr { color:#b9c5c1; font-size:16px; }

  .card { background:#fff; border:1px solid var(--logi-border); border-radius:10px; padding:18px 20px; margin-bottom:16px; }
  .card h3 { margin:0 0 12px; font-size:15px; color:#1f2a37; }

  /* 창고 3개 카드 */
  .wh-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; }
  .wh-card { border:2px solid var(--logi-border); border-radius:10px; padding:18px; text-align:center; cursor:pointer; transition:.15s; background:#fff; }
  .wh-card:hover { border-color:var(--logi-teal); box-shadow:0 4px 14px rgba(31,155,142,.15); }
  .wh-card.sel { border-color:var(--logi-teal); background:var(--logi-bg); }
  .wh-card .wh-ic { font-size:34px; }
  .wh-card .wh-nm { font-size:16px; font-weight:700; color:#1f2a37; margin:8px 0 4px; }
  .wh-card .wh-meta { font-size:12px; color:#6b7a89; }
  .wh-card .wh-rate { margin-top:8px; height:6px; border-radius:3px; background:#e7edeb; overflow:hidden; }
  .wh-card .wh-rate > i { display:block; height:100%; background:var(--logi-teal); }

  /* 세부 로케이션 맵 / 창고 상태 / 위치 안내 */
  .wh-detail { margin-top:18px; border-top:1px dashed var(--logi-border); padding-top:16px; }
  .wh-status { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
  .wh-status .chip { background:var(--logi-bg); border:1px solid var(--logi-border); border-radius:8px; padding:8px 14px; font-size:13px; color:#37475a; }
  .wh-status .chip b { color:#1f2a37; }
  .guide { display:flex; align-items:center; gap:10px; background:#eafaf6; border:1px solid #b9e6dd; color:#137a6c; border-radius:8px; padding:11px 14px; font-size:13.5px; margin-bottom:14px; }
  .guide .g-ic { font-size:18px; }
  .guide b { color:#0e6657; }
  .guide.warn { background:#fff4e0; border-color:#f0d9a8; color:#b3760f; }
  .loc-legend { display:flex; gap:16px; font-size:12px; color:#6b7a89; margin-bottom:10px; }
  .loc-legend span { display:flex; align-items:center; gap:5px; }
  .loc-legend i { width:13px; height:13px; border-radius:3px; display:inline-block; }
  .loc-map { display:grid; grid-template-columns:repeat(4,1fr); gap:9px; }
  .loc-cell { border:1px solid var(--logi-border); border-radius:8px; padding:11px 6px; text-align:center; font-size:12.5px; cursor:pointer; background:#fff; position:relative; transition:.12s; }
  .loc-cell .lc-code { font-weight:700; color:#1f2a37; }
  .loc-cell .lc-st { font-size:11px; margin-top:3px; }
  .loc-cell.st-empty { background:#eafaf3; border-color:#8fd6c2; }
  .loc-cell.st-empty .lc-st { color:var(--logi-teal-dark); }
  .loc-cell.st-use .lc-st { color:#c47f17; }
  .loc-cell.st-full { background:#f1f3f4; border-color:#e0e3e5; color:#aab2b8; cursor:not-allowed; }
  .loc-cell.st-full .lc-st { color:#b6bdc2; }
  .loc-cell:not(.st-full):hover { border-color:var(--logi-teal); }
  .loc-cell.sel { outline:2px solid var(--logi-teal); outline-offset:-1px; box-shadow:0 0 0 3px rgba(31,155,142,.15); }
  .loc-cell.rec { border-color:var(--logi-teal); }
  .loc-cell .rec-badge { position:absolute; top:-9px; right:-6px; background:var(--logi-teal); color:#fff; font-size:10px; padding:1px 7px; border-radius:9px; }

  /* 더미 테이블 */
  table.logi-tb { width:100%; border-collapse:collapse; font-size:13px; }
  table.logi-tb th, table.logi-tb td { border:1px solid var(--logi-border); padding:9px 10px; text-align:center; }
  /* 이 화면의 <기본> 머리글 (2026-08-07) — 매출내역·마감현황처럼 따로 색을 안 준 표들이 쓴다.
     재고현황·나누어보기처럼 id/클래스로 색을 지정한 표는 그쪽이 이긴다(특이도가 높다). */
  table.logi-tb thead th { background:#b9ded4; color:#0b4f43; font-weight:800; font-size:14px;
                           box-shadow:inset 0 -2px 0 #0e6657; }
  table.logi-tb .loc { font-weight:700; color:var(--logi-teal); }
  table.logi-tb .txt-l { text-align:left; }

  .form-row { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:12px; }
  .form-row .fld { flex:1; min-width:150px; }
  .form-row label { display:block; font-size:12px; color:#6b7a89; margin-bottom:5px; }
  .form-row input, .form-row select { width:100%; height:36px; border:1px solid var(--logi-border); border-radius:6px; padding:0 10px; font-size:13px; box-sizing:border-box; }

  /* 요약 카드 */
  .kpi-row { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:16px; }
  .kpi { background:#fff; border:1px solid var(--logi-border); border-radius:10px; padding:16px 18px; }
  .kpi .k-lbl { font-size:12px; color:#6b7a89; }
  .kpi .k-val { font-size:24px; font-weight:800; color:#1f2a37; margin-top:6px; }
  .kpi .k-val small { font-size:13px; font-weight:600; color:#6b7a89; }

  .badge { display:inline-block; padding:2px 9px; border-radius:11px; font-size:11px; font-weight:600; }
  .b-wait { background:#fff4e0; color:#c47f17; }
  .b-done { background:#e3f4ef; color:var(--logi-teal-dark); }
  .b-ship { background:#e8effc; color:#3b6fd1; }
  .b-due  { background:#fde8e8; color:#c0392b; }
  .note { font-size:12px; color:#9aa7b3; margin-top:6px; }
  /* ★화면 여백 통일 (2026-08-03) — 좌측 메뉴를 눌러 바뀌는 모든 화면이 같은 자리에서 시작한다.
       · 위   : 제목줄이 우측 영역 위에서 36px(약 1cm)  = .logi-main 22px + 화면 14px
       · 좌우 : 11px(약 0.3cm)                        = .logi-main 0    + 화면 11px
       · 셸 자체 화면(inline panel) 은 아래 .panel 이, iframe 화면은 각 화면 JSP 의 wrap 이 그 값을 가진다.
     iframe 패널은 style="padding:0" 이라 이 padding 이 안 먹는다 — 그래서 값이 화면 쪽에 있다.
     ※ 값을 바꾸려면 여기(14px/11px)와 각 iframe 화면의 wrap padding 을 함께 고칠 것. */
  .panel { display:none; padding:14px 11px 0; }
  .panel.show { display:block; }
  /* 제목줄(.logi-head)은 패널 맨 위에 붙는다 — 위 여백은 .panel 이 갖는다 */
  .panel > .logi-head:first-child { margin-top:0; }
  /* 대시보드(출고현황표) iframe 최초 로딩 안내 — 로그인 직후 흰 화면이 잠깐 보이는 것을 덮는다.
     iframe 의 load 이벤트에서 해제(해제 후에는 iframe 안 자체 '조회 중' 안내가 이어서 표시됨) */
  #panel-shipstatus2 { position:relative; }
  #d2FrameLoading { position:absolute; inset:0; background:#fff; z-index:50; display:flex; align-items:center; justify-content:center; }
  #d2FrameLoading.off { display:none; }
  #d2FrameLoading .box { display:flex; align-items:center; gap:12px; font-size:14px; font-weight:800; color:#137a6c; }
  #d2FrameLoading .sp { width:20px; height:20px; border:3px solid #d7ece7; border-top-color:#137a6c; border-radius:50%; animation:konetFrmSpin .8s linear infinite; flex:0 0 auto; }
  @keyframes konetFrmSpin { to { transform:rotate(360deg); } }

  /* ===== 출고현황표 전용 ===== */
  .ss-upload { display:flex; align-items:center; gap:12px; background:#eafaf6; border:1px dashed #8fd6c2; border-radius:10px; padding:14px 16px; margin-bottom:16px; }
  .ss-upload .u-ic { font-size:26px; }
  .ss-upload .u-txt { flex:1; font-size:13px; color:#137a6c; }
  .ss-upload .u-txt b { color:#0e6657; }
  .ss-upload .u-txt small { display:block; color:#3a8f81; margin-top:2px; }
  .ss-file { display:none; }

  .ss-topbar { display:flex; align-items:center; justify-content:space-between; gap:14px; flex-wrap:wrap;
               background:#fff; border:1px solid var(--logi-border); border-left:4px solid var(--logi-teal); border-radius:9px; padding:9px 16px; margin-bottom:6px; }
  .ss-topbar .tb-left { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
  .ss-topbar .db-ic { font-size:20px; }
  .ss-topbar label { font-size:13px; color:#37475a; font-weight:600; }
  .ss-topbar input[type=date] { height:34px; border:1px solid var(--logi-border); border-radius:6px; padding:0 10px; font-size:13px; cursor:pointer; background:#fff; }
  .ss-topbar input[type=date]:hover { border-color:var(--logi-teal); }
  .ss-topbar input[type=date]::-webkit-calendar-picker-indicator { cursor:pointer; opacity:.75; }
  .ss-topbar input[type=date]:hover::-webkit-calendar-picker-indicator { opacity:1; }
  .ss-topbar .tb-stats { display:flex; gap:8px; flex-wrap:wrap; }
  .ss-topbar .st { background:var(--logi-bg); border:1px solid var(--logi-border); border-radius:8px; padding:5px 14px; text-align:center; min-width:92px; }
  .ss-topbar .st-l { display:block; font-size:11px; color:#6b7a89; }
  .ss-topbar .st-v { display:block; font-size:18px; font-weight:800; color:#1f2a37; line-height:1.25; }
  .ss-dateinfo { font-size:12px; color:#6b7a89; margin:0; flex:1 1 220px; min-width:180px; line-height:1.4; }
  .ss-dateinfo b { color:#137a6c; }
  .ss-srcbadge { display:inline-block; background:#eef3f2; color:#37475a; border:1px solid var(--logi-border); border-radius:11px; padding:1px 10px; font-size:11.5px; font-weight:700; margin-right:6px; }
  .ss-srcbadge.up { background:#e3f4ef; color:#137a6c; border-color:#b9e6dd; }
  .tb-stats.ss-flash { animation:ssKpiFlash 1.2s ease; }
  @keyframes ssKpiFlash { 0%{ box-shadow:0 0 0 3px rgba(31,155,142,.55); } 60%{ box-shadow:0 0 0 3px rgba(31,155,142,.25); } 100%{ box-shadow:0 0 0 0 rgba(31,155,142,0); } }

  table.ss-tb { width:100%; border-collapse:collapse; font-size:12.5px; }
  table.ss-tb th, table.ss-tb td { border:1px solid var(--logi-border); padding:7px 8px; text-align:center; white-space:nowrap; }
  table.ss-tb thead th { background:#1f9b8e; color:#fff; position:sticky; top:0; z-index:1; }
  table.ss-tb thead th.sub { background:#34a99d; font-weight:600; }
  table.ss-tb td.itnm { text-align:left; max-width:380px; white-space:normal; word-break:break-all; }
  table.ss-tb tr.grp td { background:#eef3f2; text-align:left; font-weight:700; color:#178074; cursor:pointer; user-select:none; }
  table.ss-tb tr.grp:hover td { background:#e3efec; }
  table.ss-tb tr.grp td .cnt { float:right; font-weight:400; color:#6b7a89; font-size:11px; }
  table.ss-tb tr.grp td .caret { display:inline-block; width:14px; color:#1f9b8e; font-size:10px; }
  table.ss-tb td.code { font-family:Consolas,monospace; font-size:11.5px; color:#6b7a89; }
  table.ss-tb td.itnm .ic { display:block; font-family:Consolas,monospace; font-size:11px; color:#9aa7b3; margin-top:2px; }
  table.ss-tb td.num { text-align:right; font-variant-numeric:tabular-nums; }
  table.ss-tb td.zero { color:#cdd6e0; }
  table.ss-tb td.sum { font-weight:700; background:#f4f8f7; color:#1f2a37; }
  table.ss-tb tr.subtot td { background:#fbfdfc; font-weight:600; color:#37475a; }
  table.ss-tb tr.gtot td { background:#1f2a37; color:#fff; font-weight:700; }
  table.ss-tb tr.gtot td.zero { color:#8a98a8; }
  .ss-scroll { max-height:74vh; overflow:auto; border:1px solid var(--logi-border); border-radius:8px; }
  /* 현재 선택(활성) 버튼 표시 */
  .btn-line.seg-on { background:#178074 !important; color:#fff !important; border-color:#178074 !important; font-weight:700; }
  /* 확대 — 출고현황표 카드가 전체 화면을 덮음 */
  #ssCard.ss-fullscreen { position:fixed; inset:0; z-index:9999; margin:0; border-radius:0; background:#fff; padding:14px 18px; overflow:auto; box-shadow:none; }
  #ssCard.ss-fullscreen .ss-scroll { max-height:calc(100vh - 130px); }

  /* 전치형(품목=열, 출고장=행) 와이드 표 */
  table.sswide { width:auto; min-width:100%; }
  table.sswide th, table.sswide td { border:1px solid var(--logi-border); padding:6px 7px; text-align:center; white-space:nowrap; font-size:13px; }
  table.sswide thead th { background:#1f9b8e; color:#fff; position:sticky; top:0; z-index:3; }
  table.sswide thead th.bizh { background:#137a6c; border-bottom:1px solid #0e6657; cursor:pointer; user-select:none; }
  table.sswide thead th.bizh:hover { background:#0e6657; }
  table.sswide thead th.bizh .bx { opacity:.55; font-size:10px; }
  table.sswide thead th.bizh:hover .bx { opacity:1; }
  table.sswide thead th.bizh .bizcode { display:inline-block; margin-left:5px; font-size:10px; font-weight:600; color:#cdeee8; font-family:Consolas,monospace; letter-spacing:.2px; }
  /* 사업장 찾기 — 선택(찾은) 사업장 강조 */
  table.sswide thead th.bizh.ss-find-hit { background:#f59e0b !important; color:#3a2600 !important; box-shadow: inset 0 0 0 3px #b45309; }
  table.sswide thead th.bizh.ss-find-hit .bizcode { color:#3a2600; }
  @keyframes ssFindPulse { 0%{ box-shadow: inset 0 0 0 3px #b45309, 0 0 0 0 rgba(245,158,11,.7);} 100%{ box-shadow: inset 0 0 0 3px #b45309, 0 0 0 12px rgba(245,158,11,0);} }
  table.sswide thead th.bizh.ss-find-hit.ss-find-pulse { animation: ssFindPulse .7s ease-out 2; }
  .ss-hidden-bar { display:flex; align-items:center; flex-wrap:wrap; gap:6px; margin-bottom:8px; font-size:12.5px; }
  .ss-hidden-bar .hb-lbl { color:#6b7a89; font-weight:600; }
  .ss-hidden-bar .hb-chip { background:#eef3f2; border:1px solid var(--logi-border); color:#37475a; border-radius:13px; padding:3px 11px; cursor:pointer; font-weight:600; }
  .ss-hidden-bar .hb-chip:hover { background:#e3efec; border-color:var(--logi-teal); color:#137a6c; }
  table.sswide thead th.prodh { background:#34a99d; font-weight:600; white-space:normal; word-break:break-all; min-width:84px; max-width:96px; font-size:10.5px; line-height:1.25; vertical-align:bottom; top:31px; }
  table.sswide thead th.prodh .pc { display:block; font-family:Consolas,monospace; font-size:9.5px; color:#dff5f1; margin-top:2px; }
  /* 좌측 고정 열(출고장) */
  table.sswide .stick { position:sticky; left:0; z-index:2; min-width:118px; text-align:left; }
  table.sswide thead th.stick { z-index:5; background:#178074; }
  table.sswide tbody td.stick { background:#f4f8f7; font-weight:600; color:#178074; }
  table.sswide tbody td.stick .sub2 { font-weight:400; color:#9aa7b3; font-size:10.5px; }
  table.sswide td.num { text-align:right; font-variant-numeric:tabular-nums; }
  /* 추가 항목 삭제 ✕ */
  table.sswide .delx { display:inline-block; margin-left:4px; color:#ffd9d9; cursor:pointer; font-size:11px; font-weight:700; }
  table.sswide .delx:hover { color:#fff; background:#c0392b; border-radius:8px; padding:0 4px; }
  table.sswide tbody .delx { color:#c0392b; }
  /* 직접 수정 칸 */
  table.sswide td.edit { cursor:text; background:#fffdf0; }
  table.sswide td.edit:hover { background:#fff8d8; }
  table.sswide td.edit:focus { outline:2px solid #1f9b8e; background:#fff; color:#1f2a37; }
  /* 사업장(브랜드) 그룹 구분선 — 헤더부터 끝까지 진하게 이어짐 */
  table.sswide td.gstart, table.sswide th.gstart { border-left:2px solid #0e6657; }
  table.sswide thead th.bizh.gstart, table.sswide thead th.prodh.gstart { border-left:2px solid #0e6657; }
  table.sswide tr.sec td.gstart { border-left:2px solid #5fae9f; }
  table.sswide td.zero { color:#cdd6e0; }
  table.sswide td.colsum, table.sswide th.colsum { background:#eef3f2; font-weight:700; color:#1f2a37; min-width:60px; max-width:80px; width:70px; }
  table.sswide thead th.colsum .sumcnt { display:block; font-size:9px; font-weight:600; color:#dff5f1; margin-top:2px; white-space:normal; line-height:1.15; }
  /* 합계 맨뒤(끝)일 때는 고정 안 함 — 표와 함께 스크롤 */
  /* 합계 맨앞: 출고장 바로 옆에 좌측 고정 */
  table.sswide.sumfront td.colsum, table.sswide.sumfront th.colsum { position:sticky; left:var(--stickw,120px); z-index:2; }
  table.sswide.sumfront thead th.colsum { z-index:4; }
  table.sswide tr.ztot td.colsum { background:#1f2a37; }
  table.sswide tr.sec td.colsum { background:#1f2a37; }
  table.sswide tr.r-now td.colsum { background:#fffaf0; }
  table.sswide tr.r-sel td.colsum { background:#e3f4ef; }
  table.sswide tr.unrow td.colsum { background:#ffe0b0; }
  table.sswide tr.lgrp { cursor:pointer; }
  table.sswide tr.lgrp td { background:#eef3f2; color:#178074; font-weight:700; font-size:12.5px; }
  table.sswide tr.lgrp td.stick { background:#e3efec; }
  table.sswide tr.lgrp:hover td { background:#dcefe9; }
  table.sswide tr.lgrp .zcaret { display:inline-block; width:12px; color:#1f9b8e; font-size:10px; }
  table.sswide tr.lsub td { background:#eaf5f2; font-weight:700; color:#137a6c; }
  table.sswide tr.lsub td.stick { background:#dcefe9; }
  table.sswide tr.ztot td { background:#1f2a37; font-weight:700; color:#fff; }
  table.sswide tr.ztot td.stick { background:#11161d; color:#fff; }
  table.sswide tr.ztot td.zero { color:#8a98a8; }
  table.sswide tr.unrow td { background:#fff1d6; color:#b3760f; font-weight:600; }
  table.sswide tr.unrow td.stick { background:#ffd9a8; color:#a85700; cursor:help; border-left:3px solid #e8941f; white-space:nowrap; }
  table.sswide tr.unrow td.uhl { background:#ffe0e0; color:#c0392b; font-weight:800; }
  table.sswide tr.unrow td.colsum { background:#ffe0b0; color:#a85700; }
  table.sswide tr.sec td { background:#1f2a37; color:#fff; text-align:left; font-weight:700; }
  table.sswide tr.sec td.stick { position:sticky; left:0; background:#1f2a37; }
  table.sswide tr.r-stock td.num { color:#178074; }
  table.sswide tr.r-month td.num { color:#6b7a89; }
  table.sswide tr.r-now td { background:#fffaf0; }
  table.sswide tr.r-now td.num { color:#c47f17; font-weight:700; }
  table.sswide tr.r-sel td { background:#e3f4ef; }
  table.sswide tr.r-sel td.num { color:#137a6c; font-weight:800; }
  table.sswide tr.r-sel td.stick { background:#cdebe2; color:#137a6c; font-weight:800; border-left:3px solid #1f9b8e; }
  /* 매출액(납품매출액) 행 — 출고량 바로 아래 */
  table.sswide tr.r-sales td { background:#fff7e8; }
  table.sswide tr.r-sales td.num { color:#b3760f; font-weight:700; }
  table.sswide tr.r-sales td.stick { background:#ffeccb; color:#a85700; font-weight:800; border-left:3px solid #e8941f; }
  table.sswide tr.r-sales td.colsum { background:#a85700; color:#fff; }
  /* 매입액 행 */
  table.sswide tr.r-cost td { background:#f0f4f8; }
  table.sswide tr.r-cost td.num { color:#37475a; font-weight:700; }
  table.sswide tr.r-cost td.stick { background:#e4ebf2; color:#37475a; font-weight:800; border-left:3px solid #8a98a8; }
  table.sswide tr.r-cost td.colsum { background:#5b6775; color:#fff; }
  /* 마진 행 (매출−매입) */
  table.sswide tr.r-margin td { background:#eafaf3; }
  table.sswide tr.r-margin td.num { color:#137a6c; font-weight:800; }
  table.sswide tr.r-margin td.num.neg { color:#c0392b; }
  table.sswide tr.r-margin td.stick { background:#d6f0e7; color:#0e6657; font-weight:800; border-left:3px solid #1f9b8e; }
  table.sswide tr.r-margin td.colsum { background:#137a6c; color:#fff; }
  table.sswide tr.r-margin td.colsum.neg { background:#c0392b; }
  table.sswide td.neg { color:#c0392b; font-weight:700; }

  /* 사업장 회전 캐러셀(원통) — 활성 사업장만 또렷+앞으로 돌출, 나머지는 흐리게 뒤로 물러남 */
  table.sswide.ssc-on td:not(.stick):not(.colsum),
  table.sswide.ssc-on thead th.bizh,
  table.sswide.ssc-on thead th.prodh {
    opacity:.34; filter:saturate(.55) blur(.4px);
    transform-origin:center center;
    transition:opacity .7s cubic-bezier(.34,1.56,.64,1), filter .7s ease, box-shadow .7s ease, color .7s ease, transform .7s cubic-bezier(.34,1.56,.64,1);
  }
  /* 초점 사업장: 또렷 + 살짝 크게 앞으로 돌출 */
  table.sswide.ssc-on .ssc-focus {
    opacity:1 !important; filter:none !important;
    position:relative; z-index:6;
    transform:scale(1.06);
    box-shadow:0 6px 16px rgba(20,122,108,.30);
  }
  /* 헤더는 더 크게 돌출시켜 '표시'가 앞으로 튀어나오는 느낌 */
  table.sswide.ssc-on thead th.bizh.ssc-focus {
    background:#0e6657 !important; color:#fff !important; z-index:8;
    transform:translateY(-4px) scale(1.12);
    box-shadow:inset 0 0 0 2px #aef0e7, 0 12px 26px rgba(20,122,108,.5);
  }
  table.sswide.ssc-on thead th.prodh.ssc-focus {
    background:#1f9b8e !important; color:#fff !important; z-index:7;
    transform:translateY(-2px) scale(1.08);
    box-shadow:0 8px 18px rgba(20,122,108,.4);
  }

  /* 존(출고장)별 막대 */
  .zone-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(150px,1fr)); gap:9px; }
  .zone-bar { border:1px solid var(--logi-border); border-radius:8px; padding:9px 11px; background:#fff; }
  .zone-bar .zb-top { display:flex; justify-content:space-between; font-size:12.5px; margin-bottom:6px; }
  .zone-bar .zb-code { font-weight:700; color:var(--logi-teal-dark); }
  .zone-bar .zb-qty { font-weight:700; color:#1f2a37; }
  .zone-bar .zb-track { height:7px; border-radius:4px; background:#e7edeb; overflow:hidden; }
  .zone-bar .zb-track > i { display:block; height:100%; background:linear-gradient(90deg,#34a99d,#1f9b8e); }
  .zone-bar .zb-inb { font-size:10.5px; color:#9aa7b3; margin-top:4px; }

  /* 재고량/출고량 상태 */
  table.ss-tb td.st-ok { color:var(--logi-teal-dark); }
  table.ss-tb td.st-low { color:#c47f17; font-weight:700; }
  table.ss-tb td.st-neg { color:#c0392b; font-weight:700; }
  .ss-toast { position:fixed; left:50%; top:50%; background:#1f2a37; color:#fff; padding:15px 22px; border-radius:9px; font-size:14px; text-align:center; box-shadow:0 8px 30px rgba(0,0,0,.3); opacity:0; transform:translate(-50%,-50%) scale(.96); transition:.2s; z-index:9999; pointer-events:none; max-width:80vw; }
  .ss-toast.on { opacity:1; transform:translate(-50%,-50%) scale(1); }
  .ss-toast b { color:#aef0e7; }

  /* 출고장 그룹(물류센터) 순서 설정 팝업 */
  .ss-gord-wrap { position:relative; display:inline-flex; }
  .ss-gord-pop { display:none; position:absolute; top:36px; right:0; z-index:60; background:#fff; border:1px solid var(--logi-border);
                 border-radius:8px; box-shadow:0 6px 18px rgba(31,42,55,.18); padding:8px 6px; min-width:260px; max-height:340px; overflow-y:auto; }
  .ss-gord-pop.open { display:block; }
  .ss-gord-pop .go-row { display:flex; align-items:center; justify-content:space-between; gap:8px; padding:6px 10px; font-size:12.5px; color:#37475a; border-radius:6px; }
  .ss-gord-pop .go-row:hover { background:#eef3f2; }
  .ss-gord-pop .go-row .go-btns { display:inline-flex; gap:3px; }
  .ss-gord-pop .go-foot { border-top:1px dashed var(--logi-border); margin-top:4px; padding-top:6px; text-align:center; }

  /* 발주현황표 미리보기 모달 */
  .ss-modal { display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:9998; }
  .ss-modal.on { display:flex; align-items:flex-start; justify-content:center; }
  .ss-modal .box { background:#fff; width:min(1120px,95vw); margin-top:4vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:90vh; display:flex; flex-direction:column; }
  /* 발주현황표 미리보기: 좌측 목록 + 우측 일자컬럼까지 보이도록 넓게.
     ★위로 조금 올리고 세로도 늘린다(2026-08-01 요청) — 품목코드 연결 표가 생기면서
       모달이 길어져 아래쪽 [작성] 줄이 화면 밖으로 밀리기 쉬웠다. */
  #ssPvOverlay .box { width:min(1600px,96vw); margin-top:1.5vh; max-height:96vh; }
  /* 반영 확인(ssConfirm) — 화면 정중앙 + 다른 오버레이(미리보기·저장·패널·풀스크린)보다 항상 위 (2026-07-24 요청) */
  #ssConfirmOv.on { align-items:center; }
  #ssConfirmOv .box { margin-top:0; width:min(440px,92vw); }
  #ssConfirmOv { z-index:100000; }
  /* 품목 연결 팝업 — 미리보기 모달 '위'에 뜨므로 z-index 를 더 높인다.
     ★공용 알림(_alertBox, 340px 컴팩트)을 쓰지 않는다 — 코드·품명·규격을 나란히 봐야 고를 수 있는데
       좁으면 품명이 세 줄로 접히고 가로 스크롤이 생긴다(2026-08-01 지적). 여기만 넓게. */
  #ssXrefPop { z-index:100001; }
  #ssXrefPop.on { align-items:center; }
  #ssXrefPop .box { margin-top:0; width:min(980px,96vw); }
  #ssXrefPop .xr-row { display:flex; gap:10px; align-items:center; padding:6px 4px; border-top:1px solid #eef2f1; }
  #ssXrefPop .xr-cd  { flex:0 0 110px; color:#137a6c; font-weight:700; }
  #ssXrefPop .xr-nm  { flex:1 1 auto; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  #ssXrefPop .xr-sp  { flex:0 0 160px; color:#6b7a89; font-size:12px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  /* 단가·현재고·최근출고 — 비슷한 후보를 가르는 실제 판단 근거라 숫자는 오른쪽 정렬 */
  #ssXrefPop .xr-n   { flex:0 0 70px; text-align:right; color:#37475a; font-size:12px; white-space:nowrap; }
  #ssXrefPop .xr-wy  { flex:0 0 100px; color:#b3760f; font-size:12px; font-weight:600; }
  /* [연결] 버튼 — 열이 늘면서 눌려 '연/결' 로 두 줄이 됐다(2026-08-01).
     ★button 은 브라우저 기본이 border-box 라 52px 로는 좌우 padding(20px)·테두리를 빼면
       글자 자리가 30px 남짓이라 아슬아슬했다. 넉넉히 잡고 줄바꿈을 막는다. */
  #ssXrefPop .xr-row .ss-btn { flex:0 0 64px; white-space:nowrap; word-break:keep-all; text-align:center; }
  .ss-modal .mh { background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:14px 20px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  .ss-modal .mh h4 { margin:0; font-size:16px; font-weight:600; }
  .ss-modal .mh .x { cursor:pointer; font-size:22px; line-height:1; color:#fff; opacity:.9; background:none; border:none; }
  .ss-modal .mbar { padding:11px 20px; border-bottom:1px solid var(--logi-border); display:flex; gap:14px; align-items:center; flex-wrap:wrap; font-size:13px; }
  .ss-modal .mbar b { color:#1f2a37; }
  .ss-modal .mbar select { height:32px; border:1px solid var(--logi-border); border-radius:6px; padding:0 8px; font-size:12.5px; }
  .ss-modal .mbody { padding:14px 20px; overflow:auto; }
  .ss-modal .mfoot { padding:12px 20px; border-top:1px solid var(--logi-border); display:flex; justify-content:flex-end; gap:8px; }
  .ss-pvinfo { font-size:12.5px; color:#137a6c; background:#eafaf6; border:1px solid #b9e6dd; border-radius:7px; padding:7px 12px; margin-bottom:10px; }
  .ss-pvinfo.warn { color:#b3760f; background:#fff4e0; border-color:#f0d9a8; }
  .ss-pvinfo .tag { display:inline-block; background:#fff7cc; border:1px solid #e8d894; border-radius:4px; padding:1px 6px; margin:0 2px; font-size:11px; color:#7a6310; }
  /* ★[초기화] — 올린 엑셀을 화면에서 내린다 (2026-08-01 요청). [작성] 하지 않고 닫으면 다음에
     열 때 그 파일이 그대로 남아 있는데, 그건 '이어서 보려고' 일부러 남기는 것이라 지우는 길이
     따로 있어야 한다. 인식결과 줄 오른쪽 끝 — '지금 무슨 파일이 올라와 있나' 를 말하는 자리다. */
  .ss-pvinfo .ss-pvrst { float:right; margin-left:10px; font-size:12px; font-weight:700; color:#8a6b6b;
                         background:#fff; border:1px solid #e0cfcb; border-radius:5px;
                         padding:1px 8px; cursor:pointer; }
  .ss-pvinfo .ss-pvrst:hover { color:#c0392b; border-color:#c0392b; }
  table.ss-pv { border-collapse:collapse; font-size:11.5px; }
  table.ss-pv td, table.ss-pv th { border:1px solid #e3e9e7; padding:3px 7px; white-space:nowrap; max-width:170px; overflow:hidden; text-overflow:ellipsis; }
  table.ss-pv tr.hdr td { background:#eef3f2; font-weight:700; color:#178074; position:sticky; top:0; }
  table.ss-pv td.hl { background:#fff7cc; }
  table.ss-pv td.dlv { background:#e1efff; font-weight:700; color:#1257a8; }   /* 납기일자 컬럼 구분 */
  table.ss-pv td.rn { background:#f4f8f7; color:#9aa7b3; text-align:right; position:sticky; left:0; }
  table.ss-pv tr.badrow td { background:#fdecea; }                                  /* 값이 빠진 행 — 오류내역과 같이 본다 */
  table.ss-pv tr.badrow td.rn { background:#f8d7d3; color:#c0392b; font-weight:700; }
  /* ★품목코드 칸에서 바로 연결 (2026-08-01) — 별도 목록 상자를 없애고 이 표 안에서 끝낸다.
     미연결이면 빨강+밑줄(누를 수 있다는 신호), 연결 예정이면 초록. */
  table.ss-pv td.xrbad { background:#fdecea; color:#c0392b; font-weight:700; cursor:pointer;
                         text-decoration:underline; text-underline-offset:2px; }
  table.ss-pv td.xrbad:hover { background:#fbd9d4; }
  table.ss-pv td.xrpend { background:#e6f7f0; color:#137a6c; font-weight:700; cursor:pointer; }
  table.ss-pv td.xrlnk { color:#137a6c; cursor:pointer; }                          /* 이미 연결된 코드 — 수정·해제하러 들어갈 수 있다 */
  /* 거래처 매칭코드로 풀리는 코드 — 여기서는 못 고친다(상품코드등록 화면이 주인) → 커서·밑줄 없이 색만 */
  table.ss-pv td.xrext { color:#274b8f; }
  /* ★품목코드 앞의 상태 딱지 (2026-08-01 요청) — 색만으로는 "연결이 된 건지" 를 말해 주지 못한다.
     빨강/초록을 못 가르는 눈에도, 흑백으로 뽑아도 읽힌다. */
  table.ss-pv .xrchip { display:inline-block; font-size:10px; font-weight:700; line-height:14px;
                        padding:0 4px; border-radius:3px; margin-right:4px; vertical-align:1px;
                        border:1px solid currentColor; text-decoration:none; }
  /* 딱지가 붙는 만큼 칸이 좁으면 코드가 잘린다 — 이 칸만 폭 제한을 푼다 */
  table.ss-pv td.xrbad, table.ss-pv td.xrpend, table.ss-pv td.xrlnk { max-width:none; }
  /* ★펼친 후보 줄은 원본 자료보다 진하게 (2026-08-01 지적) — 흰 바탕에 가까우면 엑셀 행과
       구분이 안 돼 어디까지가 후보인지 눈에 안 들어온다. 바탕을 한 단계 낮추고 왼쪽에 굵은
       띠를 둘러 '이 묶음은 원본이 아니라 후보' 임을 보이게 한다. */
  table.ss-pv tr.xrsub td { background:#dff0ee !important; white-space:nowrap; max-width:none;
                            text-align:left; padding:5px 10px; color:#2b4a46;
                            border-color:#c2ddd9; border-left:3px solid #4fa295; }
  table.ss-pv tr.xrsub td.rn { border-left:0; background:#cfe6e2 !important; }
  table.ss-pv tr.xrsub .sx-c { display:inline-block; overflow:hidden; text-overflow:ellipsis;
                               white-space:nowrap; vertical-align:bottom; }
  table.ss-pv tr.xrsub .xr-b { display:inline-block; height:21px; line-height:19px; padding:0 8px;
                               font-size:11.5px; border:1px solid var(--logi-border); border-radius:5px;
                               background:#fff; cursor:pointer; }
  table.ss-pv tr.xrsub .xr-b:hover { border-color:#137a6c; }
  /* 업로드 오류내역 — 양식이 다르거나 값이 빠졌을 때 '무엇이 어떻게 다른지'를 목록으로 (2026-07-26) */
  .ss-pverr { font-size:12.5px; background:#fff6f5; border:1px solid #f3c9c3; border-radius:7px; padding:8px 12px; margin-bottom:10px; color:#7a3b34; }
  .ss-pverr .eh { font-weight:700; color:#c0392b; margin-bottom:5px; }
  .ss-pverr ol, .ss-pverr ul { margin:0; padding-left:18px; }
  .ss-pverr li { line-height:1.65; }
  .ss-pverr .bad { color:#c0392b; }
  .ss-pverr .ok  { color:#137a6c; }
  .ss-pverr .dim { color:#8a9199; }
  .ss-pverr .ln  { color:#6b7a89; font-size:11.5px; }
  .ss-pverr.warn { background:#fff9ec; border-color:#f0dcae; color:#7a6310; }
  .ss-pverr.warn .eh { color:#b3760f; }
  /* 이상 없음(초록) — 기본형이 빨간 오류상자라 '문제 없음' 을 그대로 쓰면 경고로 읽힌다.
     품목코드 매핑 점검처럼 '검사했고 괜찮다' 를 알릴 때 쓴다(2026-08-01) */
  .ss-pverr.good { background:#f2faf7; border-color:#cfe8de; color:#1f6f5c; }
  /* 거래처 코드 점검 툴바 — 셀렉트·입력·버튼 높이를 맞춘다(2026-08-01 지적).
     각자 기본 높이가 달라 들쭉날쭉했다. 이 패널에만 적용해 다른 화면은 건드리지 않는다. */
  #panel-xrefAudit .actions { display:flex; align-items:center; gap:6px; }
  #panel-xrefAudit .actions select,
  #panel-xrefAudit .actions input,
  #panel-xrefAudit .actions button { height:30px; line-height:28px; font-size:12.5px;
     box-sizing:border-box; padding:0 12px; margin:0; }
  #panel-xrefAudit .actions select { padding:0 6px; }
  /* 거래처 코드 점검 — 행마다 바로 처리하는 작은 버튼 */
  .xa-b { display:inline-block; height:21px; line-height:19px; padding:0 8px; font-size:11.5px;
          border:1px solid var(--logi-border); border-radius:5px; background:#fff; cursor:pointer;
          white-space:nowrap; color:#37475a; }
  .xa-b:hover { border-color:#137a6c; background:#f3faf8; }
  /* ※ 업로드 프리뷰의 '품목코드 연결' 전용 그리드(.xr-tb/.xr-wrap)는 없앴다 (2026-08-01 요청) —
       같은 품목코드를 위·아래 두 표에서 두 번 보게 되어 번거로웠다. 이제 미리보기 표의
       품목코드 칸에서 바로 연결한다(.ss-pv td.xrbad/.xrpend/.xrlnk, tr.xrsub 참조).
       .xr-b(작은 버튼)는 펼침 줄에서 계속 쓰므로 남긴다. */
  /* '이전 자료' 알림 — 살짝 깜박(2026-07-27 사용자 요청). 10회(약 10초) 뒤엔 빨강 그대로 남는다(계속 깜박이면 눈에 거슬림) */
  @keyframes ssBlink { 0%,100%{ opacity:1 } 50%{ opacity:.28 } }
  .ss-blink { animation: ssBlink 1s ease-in-out 0s 10 both; }

  /* 출고장 변경 알림 — 화면 하단 독립 고정 바 (데시보드2 iframe에서 postMessage 수신, 위너넷 알림바 스타일) */
  #konetAsqBar { position:fixed; bottom:0; left:0; width:100%; height:36px; color:#fff; display:none; align-items:center;
    z-index:10000; overflow:hidden; font-size:13px; font-weight:700; box-shadow:0 -2px 8px rgba(0,0,0,.15);
    background:linear-gradient(135deg,#1e3a5f 0%,#2c5282 100%); }
  body.konet-asqbar-on #if-shipstatus2 { height:calc(100vh - 44px - 36px) !important; }   /* 바 높이만큼 iframe 축소(가림 방지) */
  #konetAsqBar .ka-lbl { flex-shrink:0; height:100%; display:flex; align-items:center; gap:6px; padding:0 14px; background:#e67e22; white-space:nowrap; }
  #konetAsqBar .ka-view { flex:1; height:100%; overflow:hidden; display:flex; align-items:center; }
  #konetAsqBar .ka-track { display:flex; align-items:center; white-space:nowrap; animation:kaMarquee 60s linear infinite; }
  #konetAsqBar .ka-track:hover { animation-play-state:paused; }
  #konetAsqBar .tk-spacer { display:inline-block; flex-shrink:0; width:100vw; }
  @keyframes kaMarquee { 0%{ transform:translateX(0); } 100%{ transform:translateX(-100%); } }
  #konetAsqBar .tk-item { display:inline-block; padding:0 6px; }
  #konetAsqBar .tk-item .z { color:#ffd700; font-weight:800; }
  #konetAsqBar .tk-sep { color:#4a7ab5; margin:0 14px; }
  #konetAsqBar .tk-new{ color:#68d391; } #konetAsqBar .tk-up{ color:#9ae6b4; } #konetAsqBar .tk-dn{ color:#fbd38d; } #konetAsqBar .tk-del{ color:#feb2b2; }
  #konetAsqBar .ka-toggle { flex-shrink:0; margin:0 8px; padding:3px 10px; border-radius:4px; cursor:pointer; font-size:11px; color:#fff;
    white-space:nowrap; background:rgba(255,255,255,.15); border:1px solid rgba(255,255,255,.3); transition:background .2s; }
  #konetAsqBar .ka-toggle:hover { background:rgba(255,255,255,.25); }
  #konetAsqBar .ka-refresh { flex-shrink:0; height:22px; margin-left:8px; border-radius:4px; cursor:pointer; font-size:11px;
    color:#fff; background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.3); }
  #konetAsqBar .ka-refresh option { color:#1a202c; }
  #konetAsqBar .ka-refresh-btn { flex-shrink:0; margin-left:6px; padding:2px 8px; border-radius:4px; cursor:pointer; font-size:12px;
    color:#fff; background:rgba(255,255,255,.15); border:1px solid rgba(255,255,255,.3); }
  #konetAsqBar .ka-refresh-btn:hover { background:rgba(255,255,255,.25); }
  #konetAsqBar.clickable .tk-item[data-zone] { cursor:pointer; }   /* 클릭 이동은 대시보드2에서만 */
  #konetAsqBar.clickable .tk-item[data-zone]:hover { text-decoration:underline; text-underline-offset:2px; }
</style>

<script type="text/javascript">
  // 사이드바 메뉴 → 우측 패널 전환 (시연용, 데이터/테이블은 추후)
  function logiGo(key, el){
    document.querySelectorAll('.logi-side a.mi').forEach(function(a){ a.classList.remove('on'); });
    if (el) el.classList.add('on');
    /* ★메뉴를 열 때마다 사용 횟수를 센다 — 상단 <자주 쓰는 메뉴>가 저절로 쌓이는 근거다.
         logiFrame·logiShipView 도 결국 여기를 지나므로 이 한 곳이면 전부 잡힌다.
         (상단 줄에서 눌러 들어온 경우도 같은 메뉴를 세는 것이라 그대로 둔다) */
    if (typeof favUseBump==='function' && el) favUseBump(favLabel(el));
    if (typeof favRender==='function') favRender();
    document.querySelectorAll('.logi-main .panel').forEach(function(p){ p.classList.remove('show'); });
    var t = document.getElementById('panel-'+key);
    if (t) t.classList.add('show');
    var m = document.querySelector('.logi-main'); if (m) m.scrollTop = 0;
    // 출고장 변경 알림 바: 활성 화면(대시보드1/2)에 맞춰 갱신 (그 외 화면은 자동 숨김)
    if (typeof konetAsqRender === 'function') konetAsqRender();
    if (typeof closePeriodInit === 'function') closePeriodInit();   // 마감 패널 진입 시 마감월 기본값
  }
  /* ══ 자주 쓰는 메뉴 (최대 5개 · 한 번 담기면 고정) — 2026-08-04 요청 ═══════════════
       · 담는 법 : 메뉴를 열면 <빈 자리에> 저절로 담긴다. 손으로 담으려면 사이드바 메뉴 오른쪽 끝 ☆.
       · 내리는 법 : 상단 칩의 ✕ <하나뿐이다>. 자동으로 밀려나는 일은 없다(2026-08-05).
       · 보관   : localStorage (브라우저별). 서버·세션이 아니라 로그인 없이도 남는다.
       · 실행   : 원래 메뉴의 onclick 을 <그대로> 부른다 — 화면 여는 방법이 두 벌이 되면
                  나중에 한쪽만 고쳐져 어긋난다(logiGo/logiFrame/logiShipView 가 제각각이다).
       · 식별   : data-key 는 겹치는 것이 있어(출고현황표·출고세부조회 모두 shipstatus2)
                  <메뉴 이름>으로 찾는다. 이름이 바뀌면 그 즐겨찾기는 조용히 사라진다(무해). */
  /* [이력] v2 (2026-08-04) — 처음 판에서 담긴 이름에 아이콘이 섞여 있어("📤매출내역") 키를 갈았다.
       그때 두었던 '손댔음' 표시(FAV_TOUCH)는 기본값 자동주입 여부를 가리는 용도였는데,
       아래에서 자동주입 자체를 없앴으므로 지금은 <고정 목록을 저장한 적이 있는가>만 뜻한다. */
  /* ★보관 키 판을 한 번 더 올린다 (2026-08-05) —
       쓰던 브라우저에는 <옛 기본 7개>(매출내역·판매 등록…)가 이미 저장돼 있다. 아래 새 규칙에서는
       자리를 자동으로 갈아치우지 않으므로, 그 7개가 자리를 다 차지한 채 <영영 안 빠진다>.
       키를 갈아 옛 값을 무시한다 — 다들 빈 줄에서 자기 메뉴로 새로 채우게 된다. */
  var FAV_KEY='konetLogiFav3', FAV_TOUCH='konetLogiFav3Set', FAV_USE='konetLogiFavUse',
      /* ★7 → 5 (2026-08-07 요청). 줄이면 이미 7개를 담아 둔 브라우저는 다음 저장 때
           뒤 2개가 조용히 잘려 나간다(favLoad·favSave 가 다 slice 로 자른다) — 그대로 둔다.
           지금 당장 5개로 보이게 하려면 칩의 ✕ 로 내리면 된다. */
      FAV_ORDER='konetLogiFavOrder2', FAV_MAX=5;
  /* ★★초기 자동셋팅은 하지 않는다 (2026-08-05 요청 "초기 시작은 자동셋팅 무시").
       종전에는 첫 진입에 기본 7개(매출내역·판매 등록…)를 미리 담아 두었다. 그러면 정작 내가 쓰는
       메뉴가 들어올 자리가 <처음부터 다 차 있어> 한 칸도 남지 않는다 — 아래 '자리는 대체하지 않는다'
       규칙과 겹치면 기본값이 영영 안 빠지는 셈이 된다. 그래서 <빈 줄>로 시작하고,
       쓰는 메뉴가 순서대로 5칸을 채우게 둔다. 안내문(#favHint)이 빈 줄의 뜻을 알려 준다. */
  var FAV_DEFAULT=[];
  /* ── 사용 횟수 ────────────────────────────
       메뉴를 열 때마다 센다. 담기는 <쓰면 저절로> 이지만(2026-08-04 "추가 업무가 뒤에 안 붙네요"),
       ★2026-08-05 부터 이 숫자는 <누구를 들이고 뺄지>를 정하지 않는다 — 칩 툴팁 표시용일 뿐. */
  function favUseLoad(){ try{ var v=JSON.parse(localStorage.getItem(FAV_USE)||'{}'); return (v&&typeof v==='object')?v:{}; }catch(e){ return {}; } }
  function favUseSave(u){ try{ localStorage.setItem(FAV_USE, JSON.stringify(u)); }catch(e){} }

  /* ── 화면에 보이는 <자리>는 고정이다 (2026-08-04 "다른 게 선택되는 것처럼") ──────
       ★쓸 때마다 많이 쓴 순으로 다시 줄 세우면, 누르는 순간 칩들이 자리를 바꿔 버린다.
         내가 누른 자리에 다른 메뉴가 와서 <엉뚱한 게 선택된 것처럼> 보인다.
       그래서 <표시 순서(FAV_ORDER)>를 따로 저장하고 한 번 잡힌 자리는 움직이지 않는다.
       ★이 목록이 화면에 보이는 그 자체다 — 7칸을 채우고 나면 ✕ 로 내리기 전까지 그대로다. */
  function favOrderLoad(){
    try{ var v=JSON.parse(localStorage.getItem(FAV_ORDER)||'null'); return Array.isArray(v)?v:null; }
    catch(e){ return null; }
  }
  function favOrderSave(l){ try{ localStorage.setItem(FAV_ORDER, JSON.stringify(l.slice(0,FAV_MAX))); }catch(e){} }

  function favLoad(){
    var o=favOrderLoad();
    if(o===null){ o=FAV_DEFAULT.filter(favFind).slice(0,FAV_MAX); favOrderSave(o); }   // 첫 진입 = 빈 줄(자동셋팅 없음)
    return o.filter(favFind).slice(0,FAV_MAX);          // 사라진 메뉴는 조용히 걸러 낸다
  }
  /* ★★자리는 <대체하지 않는다> (2026-08-05 요청 "삭제 하지 않으면 7개 고정 · 다른 내용이 대체가 아니구").
       메뉴를 열 때 — 횟수를 세고, 목록에 없으면 <빈 자리에만> 새로 넣는다.
       7칸이 다 차면 그것으로 끝이다. 아무리 많이 써도 남의 자리를 밀어내지 않는다.
       자리를 바꾸려면 사용자가 칩의 ✕(favDrop)로 <직접 내려야> 한다.
       왜 : 종전에는 가장 적게 쓴 자리를 자동으로 갈아치웠다. 그러면 잠깐 다른 화면을 몇 번 들락거린 것만으로
            늘 쓰던 메뉴가 소리 없이 사라져, 있던 자리에 손이 갔다가 엉뚱한 화면이 열린다.
            사용 횟수(FAV_USE)는 이제 <몇 번 썼는지 보여 주는 용도>로만 남는다. */
  function favUseBump(nm){
    if(!nm) return;
    var u=favUseLoad();
    u[nm]=(u[nm]||0)+1;
    favUseSave(u);

    var o=favOrderLoad(); if(o===null){ favLoad(); o=favOrderLoad()||[]; }
    if(o.indexOf(nm)>=0) return;                        // 이미 있다 — 자리 그대로
    if(o.length>=FAV_MAX) return;                       // ★다 찼으면 그대로 둔다(대체 없음)
    o.push(nm); favOrderSave(o);
  }
  /* 손으로 고정한 목록(★) — 종전의 저장 구조를 그대로 쓴다 */
  function favPins(){
    try{
      if(localStorage.getItem(FAV_TOUCH)!=='1') return [];
      var v=JSON.parse(localStorage.getItem(FAV_KEY)||'[]');
      return Array.isArray(v)?v.slice(0,FAV_MAX):[];
    }catch(e){ return []; }
  }
  function favSave(l){
    try{
      localStorage.setItem(FAV_KEY, JSON.stringify(l.slice(0,FAV_MAX)));
      localStorage.setItem(FAV_TOUCH, '1');                                // 이제부터는 사용자 목록
    }catch(e){}
  }
  /* ★메뉴 이름은 <글자 노드만> 모아 만든다 (2026-08-04 수정).
       종전엔 textContent 를 썼는데, 그러면 아이콘(<span class="ic">📤</span>)과
       뒤에 붙인 ☆ 까지 이름에 섞여 "📤매출내역☆" 가 된다. 담을 때 붙인 이름과
       나중에 찾을 때 만든 이름이 서로 달라 <아무 일도 안 일어난 것처럼> 보였다. */
  function favLabel(a){
    var s='';
    for(var i=0;i<a.childNodes.length;i++){
      var c=a.childNodes[i];
      if(c.nodeType===3) s+=c.nodeValue;           // 글자 노드만 — 아이콘·☆·캐럿 제외
    }
    return s.replace(/\s+/g,' ').trim();
  }
  /* 사이드바의 <실제 메뉴> 중 이름이 같은 것 (즐겨찾기 목록 자신은 뺀다) */
  function favFind(nm){
    var hit=null;
    document.querySelectorAll('.logi-side a.mi').forEach(function(a){
      if(hit) return;
      if(favLabel(a)===nm) hit=a;
    });
    return hit;
  }
  /* ☆ = 담기/빼기. (자리 대체가 없어진 뒤로 '고정'은 📌 표시 + 담는 통로 구실만 한다)
       ★고정해도 <자리는 그대로>다 — 앞으로 끌어올리면 그것도 화면이 출렁이는 원인이 된다.
       ★★7칸이 다 차 있으면 <넣지 않고 알린다> (2026-08-05) — 여기서 남의 자리를 갈아치우면
         'favUseBump 는 대체 안 하는데 ☆ 는 대체한다' 가 되어 규칙이 두 벌이 된다.
         내리는 길은 오직 하나, 칩의 ✕ 다. */
  function favToggle(ev, nm){
    ev.preventDefault(); ev.stopPropagation();        // 메뉴 자체가 열리지 않게
    var l=favPins(), i=l.indexOf(nm);
    if(i>=0) l.splice(i,1);
    else{
      var o=favLoad().slice();
      if(o.indexOf(nm)<0){
        if(o.length>=FAV_MAX){
          var msg='⭐ 자주 쓰는 메뉴는 '+FAV_MAX+'개까지입니다. 위 줄에서 ✕ 로 하나를 내린 뒤 담아 주세요.';
          if(typeof ssToast==='function') ssToast(msg); else alert(msg);
          return;
        }
        o.push(nm); favOrderSave(o);                  // 빈 자리에만 들어간다
      }
      l.push(nm);
    }
    favSave(l); favRender();
  }
  /* 상단 줄의 ✕ = 그 메뉴만 자리에서 내린다 — 고정을 풀고 사용 횟수도 0 으로 되돌린다.
     ★자리를 비우는 길은 이것 하나뿐이다(자동 대체 없음). 비운 칸은 <다음에 여는 메뉴>가 채운다 —
       내리자마자 저절로 다른 게 들어오지는 않는다(그 메뉴를 실제로 열어야 들어온다). */
  function favDrop(ev, nm){
    if(ev){ ev.preventDefault(); ev.stopPropagation(); }
    favSave(favPins().filter(function(x){ return x!==nm; }));
    favOrderSave(favLoad().filter(function(x){ return x!==nm; }));
    var u=favUseLoad(); delete u[nm]; favUseSave(u);
    favRender();
  }
  /* 비우기 = 7칸을 통째로 비운다(고정·사용횟수까지). 다시 쓰는 메뉴부터 순서대로 채워진다 */
  function favClear(){
    favSave([]); favOrderSave([]); favUseSave({});
    favRender();
  }
  function favRun(nm){
    var a=favFind(nm); if(!a) { favOrderSave(favLoad().filter(function(x){return x!==nm;})); favRender(); return; }
    /* 접혀 있는 펼침메뉴 안에 있으면 그 묶음을 펼쳐 준다(어디서 왔는지 보이게) */
    var sub=a.closest('.sub-menu');
    if(sub && !sub.classList.contains('open')){
      sub.classList.add('open');
      var head=sub.previousElementSibling;
      if(head && head.classList.contains('has-sub')) head.classList.add('open');
    }
    a.click();
  }
  function favRender(){
    var l=favLoad(), list=document.getElementById('favList');
    if(!list) return;
    /* 비어 있어도 줄은 남긴다 — 담긴 게 생기면 안내를 감춘다 */
    var hint=document.getElementById('favHint'), clr=document.getElementById('favClearBtn');
    if(hint) hint.style.display = l.length ? 'none' : '';
    if(clr)  clr.style.display  = l.length ? '' : 'none';
    /* ★가득 찼으면 그렇다고 적어 둔다 — 자동 대체가 없어졌으므로, 새 메뉴가 안 올라오는 것이
         고장이 아니라 <자리가 없어서>임을 이 한 마디로 알 수 있어야 한다 */
    var cnt=document.getElementById('favCnt');
    cnt.textContent = l.length ? '('+l.length+'/'+FAV_MAX+(l.length>=FAV_MAX?' · 가득 참':'')+')' : '';
    cnt.title = l.length>=FAV_MAX ? '자리가 다 찼습니다 — ✕ 로 하나를 내리면 그 자리에 다음에 여는 메뉴가 들어옵니다' : '';
    /* 지금 열려 있는 화면과 같은 이름이면 켜 준다 */
    var curNm=''; var onMi=document.querySelector('.logi-side a.mi.on'); if(onMi) curNm=favLabel(onMi);
    var pin=favPins(), u=favUseLoad();
    list.innerHTML = l.map(function(nm){
      var a=favFind(nm), ic='⭐';
      if(a){ var s=a.querySelector('.ic'); if(s) ic=s.textContent; }
      var q=String(nm).replace(/'/g,"\\'"), isPin=pin.indexOf(nm)>=0;
      return '<a class="favmi'+(nm===curNm?' on':'')+'" onclick="favRun(\''+q+'\')"'
           +   ' title="'+nm+(isPin?' — 고정됨':(u[nm]?' — '+u[nm]+'번 사용':''))+'">'
           +   (isPin?'<span class="pin" title="고정됨">📌</span>':'')
           +   '<span>'+ic+'</span>'+nm
           +   '<span class="x" title="이 메뉴 내리기" onclick="favDrop(event,\''+q+'\')">✕</span>'
           + '</a>';
    }).join('');
    /* 사이드바 메뉴의 ☆/★ = <고정 여부>를 나타낸다(목록에 있는지가 아니라) */
    var full = l.length>=FAV_MAX;
    document.querySelectorAll('.logi-side a.mi').forEach(function(a){
      var st=a.querySelector('.fav'); if(!st) return;
      var on = pin.indexOf(favLabel(a))>=0;
      st.textContent = on ? '★' : '☆';
      st.classList.toggle('on', on);
      st.title = on ? '고정 해제'
                    : (full ? '자주 쓰는 메뉴가 '+FAV_MAX+'개로 가득 찼습니다 — 위 줄에서 ✕ 로 하나를 내려 주세요'
                            : '자주 쓰는 메뉴에 담기 (최대 '+FAV_MAX+'개)');
    });
  }
  /* 메뉴마다 ☆ 를 달아 둔다 — 펼침메뉴(has-sub)는 화살표 자리라 뺀다 */
  function favInit(){
    document.querySelectorAll('.logi-side a.mi').forEach(function(a){
      if(a.classList.contains('has-sub') || a.querySelector('.fav')) return;
      var nm=favLabel(a); if(!nm) return;
      var s=document.createElement('span');
      s.className='fav'; s.textContent='☆';
      s.setAttribute('onclick', "favToggle(event,'"+nm.replace(/'/g,"\\'")+"')");
      a.appendChild(s);
    });
    favRender();
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', favInit);
  else favInit();

  // 자체완결 화면(회사/사용자·공통코드)을 우측 iframe 패널에 로드 (사이드메뉴 종속)
  function logiFrame(key, url, el){
    logiGo(key, el);
    var f = document.getElementById('if-'+key);
    if (f) {
      var cur = f.getAttribute('src') || '';
      if (!cur || cur === 'about:blank') { f.src = url; }   // 비어있으면(최초/재진입) 로드 — 이미 로드됐으면 상태 유지
      /* ★세션이 끊긴 채 눌러 '로그인 화면'이 들어가 있으면 다시 부른다 (2026-08-06).
           컨트롤러가 세션 없을 때 로그인 뷰를 돌려주는데, 위 규칙(이미 로드면 유지) 때문에
           재로그인 뒤 메뉴를 다시 눌러도 그 빈 화면이 그대로 남아 "화면이 안 뜬다"가 된다.
           같은 출처라 안쪽 문서를 볼 수 있다 — 로그인 입력칸이 보이면 새로 로드. */
      else {
        try {
          var d = f.contentDocument;
          if (d && d.getElementById('userId')) { f.src = url; }
        } catch(e) {}
      }
      f.setAttribute('data-loaded','1');
    }
  }
  // 출고업무관리 서브메뉴 → 대시보드2 패널 표시 + 보기모드(출고장별/사업장별/품목별) 전환 요청
  function logiShipView(view, el){
    logiFrame('shipstatus2','${pageContext.request.contextPath}/admin/logistics_demo1.do', el);   // 패널 표시·로드·메뉴 활성
    var f = document.getElementById('if-shipstatus2');
    var send = function(){ try{ if (f && f.contentWindow) f.contentWindow.postMessage({type:'d2view', view:view}, '*'); }catch(e){} };
    send(); setTimeout(send, 350);   // 방금 로드된 경우 대비 재전송
  }
  /* 태블릿 메뉴 열고 닫기 (2026-08-02) — 폭 ≤1100px 에서만 CSS 가 사이드바를 화면 밖에 세워 둔다.
     여기서는 body 클래스만 켜고 끈다(위치·애니메이션은 전부 konet-notebook.css). */
  function konetSideToggle(force){
    var on = (force===undefined) ? !document.body.classList.contains('konet-side-open') : !!force;
    document.body.classList.toggle('konet-side-open', on);
  }
  /* 메뉴를 고르면 닫는다 — 안 닫으면 고른 화면이 오버레이에 가려 안 보인다.
     ★서브메뉴 펼치기(has-sub)는 예외 — 그건 하위 항목을 보려고 누른 것이라 닫으면 안 된다. */
  document.addEventListener('click', function(e){
    if(!document.body.classList.contains('konet-side-open')) return;
    var t = e.target, a = null;
    while(t && t !== document){ if(t.classList && t.classList.contains('mi')){ a = t; break; } t = t.parentNode; }
    if(a && !a.classList.contains('has-sub')) konetSideToggle(false);
  });
  // 주메뉴(기준정보관리 등) 접기/펼치기 토글
  function logiToggleSub(sub, el){
    var box = document.getElementById('sub-'+sub);
    if (!box) return;
    var open = box.classList.toggle('open');
    if (el) el.classList.toggle('open', open);
  }
  // 로그아웃 — 사이드바 맨 하단 메뉴 (2026-07-31). 확인 후 세션 종료(/user/loginOutAct.do → 로그인 화면)
  //  ★확인창은 공통 표준 _confirmBox(ui-message.js) — ssConfirm(발주 반영 확인 전용 teal 모달)을 쓰지 말 것(제목 '반영 확인'이 어긋남).
  function logiLogout(){
    _confirmBox({
      msg: '로그아웃 하시겠습니까?', icon: '🚪', okText: '로그아웃', okColor: 'blue',
      onOk: function(){ location.href='${pageContext.request.contextPath}/user/loginOutAct.do'; }
    });
  }
  // 마감관리 기간(년월) 기본값 = 현재월. 각 마감 패널 진입 시 표시용
  function closePeriodInit(){
    try{
      var d=new Date(), ym=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2);
      ['closeSalesYm','closeCostYm','closeStockYm','closeStatusYm'].forEach(function(id){ var e=document.getElementById(id); if(e && !e.value) e.value=ym; });
      var sf=document.getElementById('closeSalesFrom'); if(sf && !sf.value) salesYmSync();   // 매출마감 시작/종료 = 마감월 전체
      var cf=document.getElementById('closeCostFrom'); if(cf && !cf.value) costYmSync();     // 매입마감 시작/종료 = 마감월 전체
      var kf=document.getElementById('closeStockFrom'); if(kf && !kf.value) stockYmSync();   // 재고마감 시작/종료 = 마감월 전체
    }catch(e){}
  }
  // 마감월 → 시작일자(1일)·종료일자(말일) 자동 세팅
  function salesYmSync(){
    var ym=(document.getElementById('closeSalesYm')||{}).value||''; if(!ym) return;
    var y=+ym.slice(0,4), m=+ym.slice(5,7);
    var last=new Date(y, m, 0).getDate();
    var f=document.getElementById('closeSalesFrom'), t=document.getElementById('closeSalesTo');
    if(f) f.value=ym+'-01';
    if(t) t.value=ym+'-'+('0'+last).slice(-2);
  }
  /* 그리드 한 페이지 행수 — 공통(2026-07-22 요청).
     25행이면 표가 화면 아래로 넘어가 페이지를 스크롤해야 했다. 18행이 한 화면 기준(2026-07-22 사용자 확정).
     쓰는 곳 : 매출내역 4탭(OH_ROWS) · 입고내역(INB_PAGE)
              ※ 재고현황 STK_PAGE 는 10으로 빠졌다 — 아래 ②수불 내역과 한 화면에 같이 놔야 해서(2026-07-25)
              · 마감관리 — 매출마감 품목탭(SALES_PAGE)·출고장탭(행단위) / 매입마감(COST_ROWS)
                / 재고마감(STOCK_ROWS) / 마감현황(STAT_ROWS)
     ※ 2026-07-25: 매출마감 사업장탭의 SALES_PAGE_G(그룹 12개 단위) 예외는 없앴다 — 전부 '행 18개' 단위로 통일.
       (표들이 페이지 버튼 대신 lzMount 자동 스크롤로 바뀌면서 그룹 단위로 자를 이유가 사라졌다) */
  var KONET_GRID_ROWS = 18;

  // ── 마감 집계: 출고(TBL_SHIPOUT_MST) × 단가이력/마스터 → 화면별 재집계 ──
  function _cnum(v){ return (v==null||v==='')?'0':Math.round(Number(v)).toLocaleString(); }
  function _cesc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  /* 금액 근거 배지 — 매출액이 어디서 왔는지.
       정산 / 정산안분 = 정산서(출고장이 준 실제 청구금액). 안분은 그 키에 사업장이 여러 곳이라 수량비율로 나눈 것.
       이력 / 마스터   = 정산서가 아직 안 와서 판매단가로 계산한 추정치. */
  function _srcBadge(map){
    var keys=Object.keys(map||{}); if(!keys.length) return '';
    var txt=(keys.indexOf('마스터')>=0 && keys.indexOf('이력')>=0) ? '이력+마스터' : keys[0];
    var col= (txt==='출고미상' || txt==='매입가없음') ? '#c0392b'
           : (txt.indexOf('정산')===0) ? '#1a73c7'
           : txt==='전표' ? '#1a73c7'
           : txt==='이력' ? '#137a6c' : (txt==='마스터' ? '#a85700' : '#7f8c9a');
    var tip= (txt==='정산')     ? '정산서 금액 그대로'
           : (txt==='정산안분') ? '정산서 금액을 사업장별 출고수량 비율로 안분'
           : (txt==='출고미상') ? '정산서에는 있는데 출고 자료가 없는 건 — 수량·매입액은 정산서 기준 추정입니다. 발주현황표를 올리면 정상 줄로 흡수됩니다.'
           : (txt==='전표')     ? '판매등록으로 직접 입력한 매출(정산서 밖 직접판매)'
           /* 매입단가를 어디서도 못 찾은 건 — 종전엔 '마스터'로 뭉뚱그려져 값을 찾은 것처럼 보였다.
              매입액이 0으로 잡혀 마진율이 100%로 뜨므로 반드시 눈에 띄어야 한다(2026-07-25). */
           : (txt==='매입가없음') ? '이 품목의 매입단가가 상품마스터에도 이력에도 없습니다.\n매입액이 0으로 잡혀 순마진·마진율이 실제보다 크게 나옵니다. 매입등록을 하거나 상품마스터 매입가를 채워 주세요.'
           : (txt==='추정')     ? '출고 자료가 없어 정산수량 × 매입단가로 추정한 매입액'
           : '정산서 미도착 — 판매단가로 계산한 추정치';
    return ' <span style="font-size:11px;font-weight:700;color:'+col+'" title="'+tip+'">('+txt+')</span>';
  }
  function _closeAgg(rows, keyFn){
    var m={}, order=[];
    rows.forEach(function(r){
      var k=keyFn(r);
      if(!m[k]){ m[k]={ s:r, outQty:0, salesAmt:0, costAmt:0, marginAmt:0, saleSrc:{}, inSrc:{} }; order.push(k); }
      var o=m[k];
      o.outQty+=(+r.outQty||0); o.salesAmt+=(+r.salesAmt||0); o.costAmt+=(+r.costAmt||0); o.marginAmt+=(+r.marginAmt||0);
      if(r.saleSrc) o.saleSrc[r.saleSrc]=1; if(r.inSrc) o.inSrc[r.inSrc]=1;
    });
    return order.map(function(k){ return m[k]; });
  }
  /* 조회 진행바 — 표 자리에 띄운다. 응답이 오면 렌더가 통째로 덮으므로 따로 지울 필요가 없다.
       wrap 안에 그리므로 화면 마크업은 손대지 않는다. 진행률을 알 수 없어 무한 바(퍼센트 없음). */
  function qBusy(wrapId, pagerId, msg){
    var w=document.getElementById(wrapId);
    if(w){ w._lz=null; w.style.maxHeight=''; w.innerHTML='<div class="qprog"><i></i></div><div class="qmsg">'+(msg||'조회 중…')+'</div>'; }
    var p=pagerId&&document.getElementById(pagerId); if(p) p.innerHTML='';
  }
  function qFail(wrapId, msg){
    var w=document.getElementById(wrapId);
    if(w) w.innerHTML='<div class="qmsg" style="color:#c0392b">'+(msg||'조회에 실패했습니다.')+'</div>';
  }
  var CLOSE_UI={ sales:['closeSalesWrap','closeSalesPager'], cost:['closeCostWrap','closeCostPager'],
                 stock:['closeStockWrap','closeStockPager'], status:['closeStatusWrap','closeStatusPager'] };
  function closeLoad(kind){
    var ymId={sales:'closeSalesYm',cost:'closeCostYm',stock:'closeStockYm',status:'closeStatusYm'}[kind];
    var ymEl=document.getElementById(ymId);
    var ym=ymEl?ymEl.value:''; if(!ym){ swAlert('마감월을 선택하세요.','warning'); return; }
    var ctx='${pageContext.request.contextPath}';
    var url = kind==='stock' ? '/shipout/selectStockClosing.do'
            : kind==='cost'  ? '/shipout/selectInboundClosing.do'
            : '/shipout/selectClosing.do';
    var body='ym='+encodeURIComponent(ym);
    if(kind==='sales'){   // 매출마감 = 기간(시작~종료일자) 우선
      var f=(document.getElementById('closeSalesFrom')||{}).value||'', to=(document.getElementById('closeSalesTo')||{}).value||'';
      if(f && to) body+='&fromDt='+encodeURIComponent(f)+'&toDt='+encodeURIComponent(to);
    }
    if(kind==='cost'){    // 매입마감 = 기간(시작~종료일자) 우선
      var cf=(document.getElementById('closeCostFrom')||{}).value||'', ct=(document.getElementById('closeCostTo')||{}).value||'';
      if(cf && ct) body+='&fromDt='+encodeURIComponent(cf)+'&toDt='+encodeURIComponent(ct);
    }
    if(kind==='stock'){   // 재고마감 = 기간(시작~종료일자) 우선
      var kf=(document.getElementById('closeStockFrom')||{}).value||'', kt=(document.getElementById('closeStockTo')||{}).value||'';
      if(kf && kt) body+='&fromDt='+encodeURIComponent(kf)+'&toDt='+encodeURIComponent(kt);
    }
    var ui=CLOSE_UI[kind]||[];
    qBusy(ui[0], ui[1], '집계 중입니다… (정산서 대사 포함이라 자료가 많으면 몇 초 걸립니다)');
    fetch(ctx+url, { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:body })
      .then(function(r){ return r.text(); })
      .then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ qFail(ui[0],'마감 응답 오류'); swAlert('마감 응답 오류','error'); return; }
        var rows=(j&&j.data)||[];
        if(kind==='sales'){ _salesRows=rows; _salesCollapsed={}; _salesAllCollapsed=false; _salesUpdAllBtn(); salesRenderTab(); salesLoadUnmatched(body); }
        else if(kind==='cost'){ _costRows=rows; _costCollapsed={}; _costAllCollapsed=false; costUpdAllBtn(); costRender(); }
        else if(kind==='stock') closeRenderStock(rows);
        else closeRenderStatus(rows);
        if(kind==='sales'||kind==='cost'||kind==='stock') closeStatusScreen(kind);   // 화면별 확정상태 버튼 반영
      })
      .catch(function(e){ qFail(ui[0], '통신오류 — '+_cesc(e.message)); swAlert('통신오류: '+e.message,'error'); });
  }
  // ── 재고마감: 2탭(매입처별/품목) + 소계·접기펼치기 + 행 페이징 ──
  var _stockRows=[], _stockTab='vendor', STOCK_ROWS=KONET_GRID_ROWS, _stockCollapsed={}, _stockAllCollapsed=false;
  function stockYmSync(){
    var ym=(document.getElementById('closeStockYm')||{}).value||''; if(!ym) return;
    var y=+ym.slice(0,4), m=+ym.slice(5,7), last=new Date(y,m,0).getDate();
    var f=document.getElementById('closeStockFrom'), t=document.getElementById('closeStockTo');
    if(f) f.value=ym+'-01'; if(t) t.value=ym+'-'+('0'+last).slice(-2);
  }
  function stockTab(t){
    _stockTab=t;
    Array.prototype.forEach.call(document.querySelectorAll('#stockTabs .ctab'), function(b){ b.classList.toggle('on', b.getAttribute('data-t')===t); });
    document.getElementById('stockAllBtn').style.display = (t==='vendor')?'':'none';
    stockRender();
  }
  function stockToggleKey(k){ _stockCollapsed[k]=!_stockCollapsed[k]; stockRender(); }
  function stockUpdAllBtn(){ var b=document.getElementById('stockAllBtn'); if(b) b.innerHTML=_stockAllCollapsed?'⊞ 전체 펼치기':'⊟ 전체 접기'; }
  function stockToggleAll(){
    if(_stockAllCollapsed){ _stockCollapsed={}; _stockAllCollapsed=false; }
    else { var seen={}, gi=0; _stockRows.forEach(function(r){ var gk=r.vendorCd||'(미지정)'; if(!(gk in seen)){ seen[gk]=gi; _stockCollapsed['k#'+gi]=true; gi++; } }); _stockAllCollapsed=true; }
    stockUpdAllBtn(); stockRender();
  }
  function closeRenderStock(rows){ _stockRows=rows; _stockCollapsed={}; _stockAllCollapsed=false; stockUpdAllBtn(); stockRender(); }
  // 재고 숫자셀 7개(기초·입고·출고·조정·기말·평균·재고금액) — showAvg=false면 평균 공란
  function _stkCells(beg,inq,out,adj,end,avg,amt,showAvg){
    return '<td style="text-align:right">'+_cnum(beg)+'</td><td style="text-align:right">'+_cnum(inq)+'</td>'
      +'<td style="text-align:right">'+_cnum(out)+'</td><td style="text-align:right">'+_cnum(adj)+'</td>'
      +'<td style="text-align:right;font-weight:700">'+_cnum(end)+'</td>'
      +'<td style="text-align:right">'+(showAvg?_cnum(avg):'')+'</td><td style="text-align:right">'+_cnum(amt)+'</td>';
  }
  function stockRender(){
    var wrap=document.getElementById('closeStockWrap'), sum=document.getElementById('closeStockSum'), pg=document.getElementById('closeStockPager');
    var thead='<thead><tr><th>품목코드</th><th>품목명</th><th style="text-align:right">기초</th><th style="text-align:right">입고</th><th style="text-align:right">출고</th><th style="text-align:right">조정</th><th style="text-align:right">기말</th><th style="text-align:right">이동평균단가</th><th style="text-align:right">재고금액</th></tr></thead>';
    var g={b:0,i:0,o:0,a:0,e:0,amt:0};
    _stockRows.forEach(function(r){ g.b+=(+r.beginQty||0); g.i+=(+r.inQty||0); g.o+=(+r.outQty||0); g.a+=(+r.adjQty||0); g.e+=(+r.endQty||0); g.amt+=((+r.endQty||0)*(+r.avgInPrice||0)); });
    if(!_stockRows.length){ sum.textContent='해당 기간 재고 수불 내역이 없습니다.'; wrap.innerHTML=''; wrap._lz=null; pg.innerHTML=''; return; }
    var totalRow='<tr class="close-total"><td colspan="2" style="text-align:left">■ 총합계</td>'+_stkCells(g.b,g.i,g.o,g.a,g.e,0,g.amt,false)+'</tr>';
    var _iRow=function(r){ var amt=(+r.endQty||0)*(+r.avgInPrice||0);
      return '<tr><td>'+_cesc(r.prodCd)+'</td><td class="txt-l">'+_cesc(r.prodNm)+'</td>'+_stkCells(+r.beginQty||0,+r.inQty||0,+r.outQty||0,+r.adjQty||0,+r.endQty||0,+r.avgInPrice||0,amt,true)+'</tr>'; };

    var head='<table class="logi-tb">'+thead+'<tbody>'+totalRow;
    if(_stockTab==='item'){
      sum.innerHTML='총 <b>'+_stockRows.length.toLocaleString()+'</b>품목 · 기말 <b>'+_cnum(g.e)+'</b> · 재고금액 <b>'+_cnum(g.amt)+'</b>';
      lzMount({ wrap:wrap, pager:'closeStockPager', head:head, list:_stockRows, rowFn:_iRow, rows:STOCK_ROWS, capTop:320 });
      return;
    }
    // 매입처별
    var groups=[], gmap={};
    _stockRows.forEach(function(r){ var gk=r.vendorCd||'(미지정)'; var gg=gmap[gk]; if(!gg){ gg=gmap[gk]={label:gk, items:[], b:0,i:0,o:0,a:0,e:0,amt:0}; groups.push(gg); } gg.items.push(r); gg.b+=(+r.beginQty||0); gg.i+=(+r.inQty||0); gg.o+=(+r.outQty||0); gg.a+=(+r.adjQty||0); gg.e+=(+r.endQty||0); gg.amt+=((+r.endQty||0)*(+r.avgInPrice||0)); });
    sum.innerHTML='총 <b>'+groups.length+'</b>매입처 · 기말 <b>'+_cnum(g.e)+'</b> · 재고금액 <b>'+_cnum(g.amt)+'</b>';
    var _gRow=function(gi){ var gg=groups[gi], c=!!_stockCollapsed['k#'+gi], car=c?'▶':'▼';
      return '<tr class="close-grp" onclick="stockToggleKey(\'k#'+gi+'\')"><td colspan="2" style="text-align:left"><span class="ccar">'+car+'</span><b>'+_cesc(gg.label)+'</b> <span style="color:#5b6b7a;font-weight:600">(품목 '+gg.items.length+'종)</span></td>'+_stkCells(gg.b,gg.i,gg.o,gg.a,gg.e,0,gg.amt,false)+'</tr>'; };
    var rowsD=[];
    groups.forEach(function(gg,gi){ rowsD.push({t:'g',gi:gi}); if(!_stockCollapsed['k#'+gi]) gg.items.forEach(function(o){ rowsD.push({t:'i',gi:gi,o:o}); }); });
    lzMount({ wrap:wrap, pager:'closeStockPager', head:head, list:rowsD, rows:STOCK_ROWS, capTop:320,
              rowFn:function(r){ return (r.t==='g')?_gRow(r.gi):_iRow(r.o); } });
  }
  // ── 매출마감: 3탭(출고장별/사업장별/품목) + 총합계·소계·접기펼치기·페이징 ──
  var _salesRows=[], _salesTab='zone', SALES_PAGE=KONET_GRID_ROWS, _salesCollapsed={};
  var CLOSE_DCGROUP={ 'E200':'오산센터','E400':'오산센터','E300':'오산센터','E600':'오산센터','E700':'오산센터' };   // 대시보드1과 동일
  function _zoneGroup(r){   // 출고장(대표) = 물류센터 그룹 (대시보드1 참조)
    var dcCd=(''+(r.dcCd||'')).trim(), dcNm=(''+(r.dcNm||'')).trim();
    return CLOSE_DCGROUP[dcCd] || (/제주/.test(dcNm) ? '오산센터' : (dcNm||'(출고장 미지정)'));
  }
  var _salesQ='';
  function _salesView(){   // 품목코드/품목명 검색 필터 (3탭 공통 — 집계 전 원천 행에 적용)
    if(!_salesQ) return _salesRows;
    return _salesRows.filter(function(r){
      return (''+(r.itemCd||'')).toLowerCase().indexOf(_salesQ)>=0 || (''+(r.itemNm||'')).toLowerCase().indexOf(_salesQ)>=0;
    });
  }
  function _salesQNote(){ return _salesQ ? ' · <span style="color:#137a6c">🔎 \''+_cesc(_salesQ)+'\' 검색중</span>' : ''; }
  /* 출고미상 경고 — 정산서에는 있는데 출고 자료에 짝이 없어 이 마감에서 통째로 빠진 금액.
       마감은 출고 테이블에서 출발하므로 구조상 못 잡는다. 확정 전에 눈에 띄게 띄운다(2026-07-25).
       실측 2026-07: 113건 16,640,146원 — 금액의 2/3가 '품목 자체가 출고에 없는' 발주현황표 누락 의심분. */
  var _salesUnmatched=[];
  function salesLoadUnmatched(body){
    _salesUnmatched=[];
    fetch('${pageContext.request.contextPath}/shipout/selectClosingUnmatched.do', { method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:body })
      .then(function(r){ return r.json(); })
      .then(function(j){ _salesUnmatched=(j&&j.data)||[]; salesRenderTab(); })
      .catch(function(){});   // 경고 표시용 부가 조회 — 실패해도 마감 화면은 그대로 쓴다
  }
  function _salesUnNote(){
    if(!_salesUnmatched.length) return '';
    var n=_salesUnmatched.length, amt=0; _salesUnmatched.forEach(function(r){ amt+=(+r.salesAmt||0); });
    var tip='정산서에는 있는데 출고 자료가 없는 건입니다. 매출에는 포함했지만(매출내역과 같은 기준)\n출고 자료가 비어 있으니 발주현황표를 확인해 주세요.\n대사키 = 납품일자 + 출고장 + 품목코드\n\n금액 큰 순:\n';
    _salesUnmatched.slice(0,5).forEach(function(r){
      tip += '· '+_ohDateFmt(r.dlvDt)+' '+(r.dcNm||'')+' '+(r.itemNm||r.itemCd||'')+' — '+_cnum(r.salesAmt)+'원\n';
    });
    if(n>5) tip += '… 외 '+(n-5)+'건';
    return ' · <span style="color:#c0392b;font-weight:800;cursor:pointer;text-decoration:underline" onclick="salesUnmatchedGo()"'
      + ' title="'+_cesc(tip)+'">⚠ 출고미상 '+n.toLocaleString()+'건 · '+_cnum(amt)+'원 포함</span>';
  }
  function _salesNote(){ return _salesQNote()+_salesUnNote(); }
  // 경고 클릭 → 매출내역 ④ 정산서 원본 탭으로. 기간은 마감 조회기간 그대로 넘긴다
  function salesUnmatchedGo(){
    var f=(document.getElementById('closeSalesFrom')||{}).value||'', t=(document.getElementById('closeSalesTo')||{}).value||'';
    var mi=document.querySelector('.mi[data-key="outHist"]');
    if(typeof logiGo==='function') logiGo('outHist', mi);
    var sf=document.getElementById('slsFrom'), stt=document.getElementById('slsTo');
    if(sf&&f) sf.value=f; if(stt&&t) stt.value=t;
    ohTab('settle');
    ohQuery();
  }
  function salesSearch(){
    var el=document.getElementById('salesQ');
    _salesQ=((el&&el.value)||'').trim().toLowerCase();
    _salesCollapsed={}; _salesAllCollapsed=false; _salesUpdAllBtn();
    salesRenderTab();
  }
  function salesTab(t){
    _salesTab=t; _salesAllCollapsed=false; _salesUpdAllBtn();
    Array.prototype.forEach.call(document.querySelectorAll('#salesTabs .ctab'), function(b){ b.classList.toggle('on', b.getAttribute('data-t')===t); });
    salesRenderTab();
  }
  var _salesAllCollapsed=false;
  function _salesUpdAllBtn(){ var b=document.getElementById('salesAllBtn'); if(b) b.innerHTML=_salesAllCollapsed?'⊞ 전체 펼치기':'⊟ 전체 접기'; }
  function salesToggleAll(){
    if(_salesAllCollapsed){ salesExpandAll(); _salesAllCollapsed=false; }
    else { salesCollapseAll(); _salesAllCollapsed=true; }
    _salesUpdAllBtn();
  }
  function salesExpandAll(){ _salesCollapsed={}; salesRenderTab(); }
  function salesCollapseAll(){   // 현재 탭 전체 그룹 접기 (렌더와 동일 순서로 키 재계산)
    var tab=_salesTab; if(tab==='item') return;
    if(tab==='zone'){
      var az=_closeAgg(_salesView(), function(r){ return _zoneGroup(r)+'~'+(r.dcCd||'')+'~'+r.itemCd; });
      var L1=[], l1m={};
      az.forEach(function(o){ var k1=_zoneGroup(o.s); var g1=l1m[k1]; if(!g1){ g1=l1m[k1]={l2:[],l2m:{}}; L1.push(g1); } var k2=(o.s.dcCd||'')+'|'+(o.s.dcNm||''); if(!g1.l2m[k2]){ g1.l2m[k2]=1; g1.l2.push(k2); } });
      L1.forEach(function(g1,i1){ _salesCollapsed['z1#'+i1]=true; g1.l2.forEach(function(_,i2){ _salesCollapsed['z2#'+i1+'.'+i2]=true; }); });
    } else {
      var ab=_closeAgg(_salesView(), function(r){ return (r.bizNm||'(미지정)')+'~'+r.itemCd; });
      var seen={}, gi=0;
      ab.forEach(function(o){ var gk=o.s.bizNm||'(미지정)'; if(!(gk in seen)){ seen[gk]=gi; _salesCollapsed['biz#'+gi]=true; gi++; } });
    }
    salesRenderTab();
  }
  function salesToggleKey(k){ _salesCollapsed[k]=!_salesCollapsed[k]; salesRenderTab(); }
  function salesToggle(idx){ var k=_salesTab+'#'+idx; _salesCollapsed[k]=!_salesCollapsed[k]; salesRenderTab(); }
  function _salesItemRow(o, indent){   // 품목 상세행 — indent 만큼 앞 빈칸(들여쓰기)
    var inU=o.outQty?o.costAmt/o.outQty:0, saU=o.outQty?o.salesAmt/o.outQty:0, pad='';
    for(var i=0;i<indent;i++) pad+='<td></td>';
    return '<tr>'+pad+'<td>'+_cesc(o.s.itemCd)+'</td><td class="txt-l">'+_cesc(o.s.itemNm)+'</td>'
      +'<td style="text-align:right">'+_cnum(o.outQty)+'</td>'
      +'<td style="text-align:right">'+_cnum(inU)+_srcBadge(o.inSrc)+'</td>'
      +'<td style="text-align:right">'+_cnum(saU)+_srcBadge(o.saleSrc)+'</td>'
      +'<td style="text-align:right">'+_cnum(o.salesAmt)+'</td><td style="text-align:right">'+_cnum(o.costAmt)+'</td>'
      +'<td style="text-align:right;font-weight:700;color:'+(o.marginAmt<0?'#c0392b':'#137a6c')+'">'+_cnum(o.marginAmt)+'</td></tr>';
  }
  // 숫자셀 6개(수량·매입단가·출고단가·매출·매입·순마진) — showUnit=false면 단가 2칸 공란(합계/소계용)
  function _salesNumCells(q,inAmt,saAmt,sAmt,cAmt,mAmt,showUnit){
    var inU=q?cAmt/q:0, saU=q?sAmt/q:0;
    return '<td style="text-align:right">'+_cnum(q)+'</td>'
      +'<td style="text-align:right">'+(showUnit?_cnum(inU):'')+'</td>'
      +'<td style="text-align:right">'+(showUnit?_cnum(saU):'')+'</td>'
      +'<td style="text-align:right">'+_cnum(sAmt)+'</td>'
      +'<td style="text-align:right">'+_cnum(cAmt)+'</td>'
      +'<td style="text-align:right;color:'+(mAmt<0?'#c0392b':'#137a6c')+'">'+_cnum(mAmt)+'</td>';
  }
  function salesRenderTab(){
    var wrap=document.getElementById('closeSalesWrap'), sum=document.getElementById('closeSalesSum'), pg=document.getElementById('closeSalesPager');
    var tab=_salesTab;
    var headCols = tab==='zone' ? ['출고장','품목코드','품목명'] : (tab==='biz' ? ['사업장','품목코드','품목명'] : ['품목코드','품목명']);
    var lead0=headCols.length;
    var priceCols='<th style="text-align:right">출고수량</th><th style="text-align:right">매입단가</th><th style="text-align:right">출고단가</th><th style="text-align:right">매출액</th><th style="text-align:right">매입액</th><th style="text-align:right">순마진액</th>';
    var thead='<thead><tr>'+headCols.map(function(h){ return '<th>'+h+'</th>'; }).join('')+priceCols+'</tr></thead>';
    var rows=_salesView();   // 검색 적용 행 — 합계·소계·페이징 모두 이 기준
    // 전체 합계 (원천 finest 행 기준)
    var gQ=0,gS=0,gC=0,gM=0; rows.forEach(function(r){ gQ+=(+r.outQty||0); gS+=(+r.salesAmt||0); gC+=(+r.costAmt||0); gM+=(+r.marginAmt||0); });
    if(!rows.length){ sum.textContent=(_salesRows.length&&_salesQ)?('\''+_salesQ+'\' 검색 결과가 없습니다. (품목코드/품목명)'):'해당 기간 출고 자료가 없습니다.'; wrap.innerHTML=''; wrap._lz=null; pg.innerHTML=''; return; }
    var totalRow='<tr class="close-total"><td colspan="'+lead0+'" style="text-align:left">■ 총합계</td>'+_salesNumCells(gQ,0,0,gS,gC,gM,false)+'</tr>';

    var head='<table class="logi-tb">'+thead+'<tbody>'+totalRow;
    if(tab==='item'){
      // 품목 탭 = 평면 (총합계 상단) + 18행씩 자동 스크롤
      var agg=_closeAgg(rows, function(r){ return r.itemCd; });
      sum.innerHTML='총 <b>'+agg.length.toLocaleString()+'</b>품목 · 매출 <b>'+_cnum(gS)+'</b> · 매입 <b>'+_cnum(gC)+'</b> · 순마진 <b style="color:'+(gM<0?'#c0392b':'#137a6c')+'">'+_cnum(gM)+'</b>'+_salesNote();
      lzMount({ wrap:wrap, pager:'closeSalesPager', head:head, list:agg, rows:SALES_PAGE, capTop:320,
                rowFn:function(o){ return _salesItemRow(o,0); } });
      return;
    }

    if(tab==='zone'){   // 출고장별 = 2단 트리(대표 오산센터 묶음 → 개별 물류센터 출고장 → 품목)
      var itemAggZ=_closeAgg(rows, function(r){ return _zoneGroup(r)+'~'+(r.dcCd||'')+'~'+r.itemCd; });
      var L1=[], l1m={};
      itemAggZ.forEach(function(o){
        var k1=_zoneGroup(o.s);
        var g1=l1m[k1]; if(!g1){ g1=l1m[k1]={ label:k1, l2:[], l2m:{}, q:0,s:0,c:0,m:0 }; L1.push(g1); }
        g1.q+=o.outQty; g1.s+=o.salesAmt; g1.c+=o.costAmt; g1.m+=o.marginAmt;
        var k2=(o.s.dcCd||'')+'|'+(o.s.dcNm||'');
        var g2=g1.l2m[k2]; if(!g2){ g2=g1.l2m[k2]={ label:(o.s.dcNm||'(미지정)')+(o.s.dcCd?(' ('+o.s.dcCd+')'):''), items:[], q:0,s:0,c:0,m:0 }; g1.l2.push(g2); }
        g2.q+=o.outQty; g2.s+=o.salesAmt; g2.c+=o.costAmt; g2.m+=o.marginAmt; g2.items.push(o);
      });
      sum.innerHTML='총 <b>'+L1.length+'</b>대표출고장 · 매출 <b>'+_cnum(gS)+'</b> · 매입 <b>'+_cnum(gC)+'</b> · 순마진 <b style="color:'+(gM<0?'#c0392b':'#137a6c')+'">'+_cnum(gM)+'</b>'+_salesNote();
      // 표시행(rows) = 대표헤더 + 개별출고장헤더 + 품목행 (접힘 반영). 품목행 포함 '행 단위'로 18행씩
      var rowsZ=[];
      L1.forEach(function(g1,i1){
        rowsZ.push({t:'l1',i1:i1});
        if(_salesCollapsed['z1#'+i1]) return;
        g1.l2.forEach(function(g2,i2){
          rowsZ.push({t:'l2',i1:i1,i2:i2});
          if(_salesCollapsed['z2#'+i1+'.'+i2]) return;
          g2.items.forEach(function(o){ rowsZ.push({t:'it',i1:i1,i2:i2,o:o}); });
        });
      });
      var _l1Row=function(i1){ var g1=L1[i1], c1=!!_salesCollapsed['z1#'+i1], car=c1?'▶':'▼';
        return '<tr class="close-grp" onclick="salesToggleKey(\'z1#'+i1+'\')"><td colspan="'+lead0+'"><span class="ccar">'+car+'</span><b>'+_cesc(g1.label)+'</b> <span style="color:#5b6b7a;font-weight:600">('+g1.l2.length+'개 출고장)</span></td>'+_salesNumCells(g1.q,0,0,g1.s,g1.c,g1.m,false)+'</tr>'; };
      var _l2Row=function(i1,i2){ var g2=L1[i1].l2[i2], c2=!!_salesCollapsed['z2#'+i1+'.'+i2], car=c2?'▶':'▼';
        return '<tr class="close-sub" onclick="salesToggleKey(\'z2#'+i1+'.'+i2+'\')" style="cursor:pointer"><td colspan="'+lead0+'" style="padding-left:24px"><span class="ccar">'+car+'</span>'+_cesc(g2.label)+' <span style="color:#5b6b7a;font-weight:600">(품목 '+g2.items.length+'종)</span></td>'+_salesNumCells(g2.q,0,0,g2.s,g2.c,g2.m,false)+'</tr>'; };
      lzMount({ wrap:wrap, pager:'closeSalesPager', head:head, list:rowsZ, rows:SALES_PAGE, capTop:320,
                rowFn:function(r){ return (r.t==='l1') ? _l1Row(r.i1)
                                        : (r.t==='l2') ? _l2Row(r.i1,r.i2)
                                        : _salesItemRow(r.o,1); } });
      return;
    }

    /* 사업장별 = 그룹(소계·접기펼치기). 종전에는 '그룹 12개' 단위로 페이지를 나눴는데(SALES_PAGE_G),
       접힌 정도에 따라 한 페이지 행수가 들쭉날쭉했다. 다른 표와 같이 '행 18개' 단위로 통일했다(2026-07-25). */
    var groupKeyOf = tab==='zone' ? function(r){ return _zoneGroup(r); } : function(r){ return r.bizNm||'(미지정)'; };
    var itemAgg=_closeAgg(rows, function(r){ return groupKeyOf(r)+''+r.itemCd; });
    var groups=[], gmap={};
    itemAgg.forEach(function(o){
      var gk=groupKeyOf(o.s);
      if(!gmap[gk]){ gmap[gk]={ label:gk, items:[], q:0,s:0,c:0,m:0 }; groups.push(gmap[gk]); }
      var g=gmap[gk]; g.items.push(o); g.q+=o.outQty; g.s+=o.salesAmt; g.c+=o.costAmt; g.m+=o.marginAmt;
    });
    sum.innerHTML='총 <b>'+groups.length.toLocaleString()+'</b>'+(tab==='zone'?'출고장':'사업장')+' · 매출 <b>'+_cnum(gS)+'</b> · 매입 <b>'+_cnum(gC)+'</b> · 순마진 <b style="color:'+(gM<0?'#c0392b':'#137a6c')+'">'+_cnum(gM)+'</b>'+_salesNote();
    var _gRowB=function(gi){
      var g=groups[gi], collapsed=!!_salesCollapsed[tab+'#'+gi];
      return '<tr class="close-grp" onclick="salesToggle('+gi+')"><td colspan="'+lead0+'"><span class="ccar">'+(collapsed?'▶':'▼')+'</span>'+_cesc(g.label)+' <span style="color:#5b6b7a;font-weight:600">(품목 '+g.items.length+'종)</span></td>'
        +_salesNumCells(g.q,0,0,g.s,g.c,g.m,false)+'</tr>';
    };
    var rowsB=[];
    groups.forEach(function(g,gi){ rowsB.push({t:'g',gi:gi}); if(!_salesCollapsed[tab+'#'+gi]) g.items.forEach(function(o){ rowsB.push({t:'it',o:o}); }); });
    lzMount({ wrap:wrap, pager:'closeSalesPager', head:head, list:rowsB, rows:SALES_PAGE, capTop:320,
              rowFn:function(r){ return (r.t==='g') ? _gRowB(r.gi) : _salesItemRow(r.o,1); } });
  }
  // ── 매입(입고)마감: 매입처 그룹 + 소계·접기펼치기 + 행 페이징 ──
  var _costRows=[], COST_ROWS=KONET_GRID_ROWS, _costCollapsed={}, _costAllCollapsed=false;
  function costYmSync(){
    var ym=(document.getElementById('closeCostYm')||{}).value||''; if(!ym) return;
    var y=+ym.slice(0,4), m=+ym.slice(5,7), last=new Date(y,m,0).getDate();
    var f=document.getElementById('closeCostFrom'), t=document.getElementById('closeCostTo');
    if(f) f.value=ym+'-01'; if(t) t.value=ym+'-'+('0'+last).slice(-2);
  }
  function costToggleKey(k){ _costCollapsed[k]=!_costCollapsed[k]; costRender(); }
  function costUpdAllBtn(){ var b=document.getElementById('costAllBtn'); if(b) b.innerHTML=_costAllCollapsed?'⊞ 전체 펼치기':'⊟ 전체 접기'; }
  function costToggleAll(){
    if(_costAllCollapsed){ _costCollapsed={}; _costAllCollapsed=false; }
    else { var seen={}, gi=0; _costRows.forEach(function(r){ var gk=r.vendorCd||'(미지정)'; if(!(gk in seen)){ seen[gk]=gi; _costCollapsed['c#'+gi]=true; gi++; } }); _costAllCollapsed=true; }
    costUpdAllBtn(); costRender();
  }
  function closeRenderCost(rows){ _costRows=rows; _costCollapsed={}; _costAllCollapsed=false; costUpdAllBtn(); costRender(); }
  function costRender(){
    var wrap=document.getElementById('closeCostWrap'), sum=document.getElementById('closeCostSum'), pg=document.getElementById('closeCostPager');
    var gQ=0,gA=0; _costRows.forEach(function(r){ gQ+=(+r.inQty||0); gA+=(+r.inAmt||0); });
    if(!_costRows.length){ sum.textContent='해당 기간 입고(수불) 내역이 없습니다.'; wrap.innerHTML=''; wrap._lz=null; pg.innerHTML=''; return; }
    // 매입처 그룹
    var groups=[], gmap={};
    _costRows.forEach(function(r){ var gk=r.vendorCd||'(미지정)'; var g=gmap[gk]; if(!g){ g=gmap[gk]={label:gk, items:[], q:0, amt:0}; groups.push(g); } g.items.push(r); g.q+=(+r.inQty||0); g.amt+=(+r.inAmt||0); });
    sum.innerHTML='총 <b>'+groups.length+'</b>매입처 · 입고 <b>'+_cnum(gQ)+'</b> · 매입액 <b>'+_cnum(gA)+'</b>';
    var thead='<thead><tr><th>매입처</th><th>품목코드</th><th>품목명</th><th style="text-align:right">입고수량</th><th style="text-align:right">매입단가</th><th style="text-align:right">매입액</th></tr></thead>';
    var totalRow='<tr class="close-total"><td colspan="3" style="text-align:left">■ 총합계</td><td style="text-align:right">'+_cnum(gQ)+'</td><td></td><td style="text-align:right">'+_cnum(gA)+'</td></tr>';
    var _gRow=function(gi){ var g=groups[gi], c=!!_costCollapsed['c#'+gi], car=c?'▶':'▼';
      return '<tr class="close-grp" onclick="costToggleKey(\'c#'+gi+'\')"><td colspan="3" style="text-align:left"><span class="ccar">'+car+'</span><b>'+_cesc(g.label)+'</b> <span style="color:#5b6b7a;font-weight:600">(품목 '+g.items.length+'종)</span></td><td style="text-align:right">'+_cnum(g.q)+'</td><td></td><td style="text-align:right">'+_cnum(g.amt)+'</td></tr>'; };
    var _iRow=function(o){
      return '<tr><td></td><td>'+_cesc(o.prodCd)+'</td><td class="txt-l">'+_cesc(o.prodNm)+'</td><td style="text-align:right">'+_cnum(o.inQty)+'</td><td style="text-align:right">'+_cnum(o.avgInPrice)+'</td><td style="text-align:right">'+_cnum(o.inAmt)+'</td></tr>'; };
    // 표시행(접힘 반영) → 18행씩 자동 스크롤
    var rowsD=[];
    groups.forEach(function(g,gi){ rowsD.push({t:'g',gi:gi}); if(!_costCollapsed['c#'+gi]) g.items.forEach(function(o){ rowsD.push({t:'i',gi:gi,o:o}); }); });
    lzMount({ wrap:wrap, pager:'closeCostPager', head:'<table class="logi-tb">'+thead+'<tbody>'+totalRow,
              list:rowsD, rows:COST_ROWS, capTop:320,
              rowFn:function(r){ return (r.t==='g') ? _gRow(r.gi) : _iRow(r.o); } });
  }
  // ── 마감현황(월계표): 3탭(출고장별 2단트리/사업장별/품목별) + 접기·페이징 ──
  var _statRows=[], _statTab='zone', STAT_ROWS=KONET_GRID_ROWS, _statCollapsed={}, _statAllCollapsed=false;
  function _statCells(q,s,c,m){ var rate=s?(m/s*100):0;
    return '<td style="text-align:right">'+_cnum(q)+'</td><td style="text-align:right">'+_cnum(s)+'</td><td style="text-align:right">'+_cnum(c)+'</td>'
      +'<td style="text-align:right;font-weight:700;color:'+(m<0?'#c0392b':'#137a6c')+'">'+_cnum(m)+'</td><td style="text-align:right">'+rate.toFixed(1)+'%</td>'; }
  function _statItemRow(o,pad){ var p=''; for(var i=0;i<pad;i++)p+='<td></td>';
    return '<tr>'+p+'<td>'+_cesc(o.s.itemCd)+'</td><td class="txt-l">'+_cesc(o.s.itemNm)+'</td>'+_statCells(o.outQty,o.salesAmt,o.costAmt,o.marginAmt)+'</tr>'; }
  function statTab(t){
    _statTab=t;
    Array.prototype.forEach.call(document.querySelectorAll('#statTabs .ctab'), function(b){ b.classList.toggle('on', b.getAttribute('data-t')===t); });
    document.getElementById('statAllBtn').style.display=(t==='item')?'none':'';
    statRenderTab();
  }
  function statToggleKey(k){ _statCollapsed[k]=!_statCollapsed[k]; statRenderTab(); }
  function statUpdAllBtn(){ var b=document.getElementById('statAllBtn'); if(b) b.innerHTML=_statAllCollapsed?'⊞ 전체 펼치기':'⊟ 전체 접기'; }
  function statToggleAll(){
    if(_statAllCollapsed){ _statCollapsed={}; _statAllCollapsed=false; }
    else if(_statTab==='zone'){
      var az=_closeAgg(_statRows, function(r){ return _zoneGroup(r)+'~'+(r.dcCd||'')+'~'+r.itemCd; }), L1=[],l1m={};
      az.forEach(function(o){ var k1=_zoneGroup(o.s); var g1=l1m[k1]; if(!g1){g1=l1m[k1]={l2:[],l2m:{}};L1.push(g1);} var k2=(o.s.dcCd||'')+'|'+(o.s.dcNm||''); if(!g1.l2m[k2]){g1.l2m[k2]=1;g1.l2.push(k2);} });
      L1.forEach(function(g1,i1){ _statCollapsed['z1#'+i1]=true; g1.l2.forEach(function(_,i2){ _statCollapsed['z2#'+i1+'.'+i2]=true; }); });
      _statAllCollapsed=true;
    } else {
      var ab=_closeAgg(_statRows, function(r){ return (r.bizNm||'(미지정)')+'~'+r.itemCd; }), seen={}, gi=0;
      ab.forEach(function(o){ var gk=o.s.bizNm||'(미지정)'; if(!(gk in seen)){ seen[gk]=gi; _statCollapsed['b#'+gi]=true; gi++; } });
      _statAllCollapsed=true;
    }
    statUpdAllBtn(); statRenderTab();
  }
  function closeRenderStatus(rows){
    _statRows=rows||[]; _statCollapsed={}; _statAllCollapsed=false; statUpdAllBtn();
    var s=0,c=0,m=0; _statRows.forEach(function(r){ s+=(+r.salesAmt||0); c+=(+r.costAmt||0); m+=(+r.marginAmt||0); });
    document.getElementById('stKpiSales').innerHTML=_cnum(s)+' <small>원</small>';
    document.getElementById('stKpiCost').innerHTML=_cnum(c)+' <small>원</small>';
    document.getElementById('stKpiMargin').innerHTML=_cnum(m)+' <small>원</small>';
    document.getElementById('stKpiRate').textContent=(s?(m/s*100).toFixed(1):'0.0')+'%';
    statRenderTab();
    closeStatusChk();
  }
  function statRenderTab(){
    var wrap=document.getElementById('closeStatusWrap'), sum=document.getElementById('closeStatusSum'), pg=document.getElementById('closeStatusPager');
    var tab=_statTab;
    var headCols = tab==='zone'?['출고장','품목코드','품목명']:(tab==='biz'?['사업장','품목코드','품목명']:['품목코드','품목명']);
    var lead0=headCols.length;
    var priceCols='<th style="text-align:right">출고수량</th><th style="text-align:right">매출액</th><th style="text-align:right">매입액</th><th style="text-align:right">순마진액</th><th style="text-align:right">마진율</th>';
    var thead='<thead><tr>'+headCols.map(function(h){return '<th>'+h+'</th>';}).join('')+priceCols+'</tr></thead>';
    var gQ=0,gS=0,gC=0,gM=0; _statRows.forEach(function(r){ gQ+=+r.outQty||0; gS+=+r.salesAmt||0; gC+=+r.costAmt||0; gM+=+r.marginAmt||0; });
    if(!_statRows.length){ sum.textContent='해당 기간 출고 자료가 없습니다.'; wrap.innerHTML=''; wrap._lz=null; pg.innerHTML=''; return; }
    var totalRow='<tr class="close-total"><td colspan="'+lead0+'" style="text-align:left">■ 총합계</td>'+_statCells(gQ,gS,gC,gM)+'</tr>';

    var head='<table class="logi-tb">'+thead+'<tbody>'+totalRow;
    if(tab==='item'){
      var agg=_closeAgg(_statRows, function(r){ return r.itemCd; });
      sum.innerHTML='총 <b>'+agg.length.toLocaleString()+'</b>품목 · 매출 <b>'+_cnum(gS)+'</b> · 순마진 <b>'+_cnum(gM)+'</b>';
      lzMount({ wrap:wrap, pager:'closeStatusPager', head:head, list:agg, rows:STAT_ROWS, capTop:320,
                rowFn:function(o){ return _statItemRow(o,0); } });
      return;
    }

    var rowsD=[], _hdr;
    if(tab==='zone'){
      var az=_closeAgg(_statRows, function(r){ return _zoneGroup(r)+'~'+(r.dcCd||'')+'~'+r.itemCd; }), L1=[],l1m={};
      az.forEach(function(o){ var k1=_zoneGroup(o.s); var g1=l1m[k1]; if(!g1){g1=l1m[k1]={label:k1,l2:[],l2m:{},q:0,s:0,c:0,m:0};L1.push(g1);} g1.q+=o.outQty;g1.s+=o.salesAmt;g1.c+=o.costAmt;g1.m+=o.marginAmt;
        var k2=(o.s.dcCd||'')+'|'+(o.s.dcNm||''); var g2=g1.l2m[k2]; if(!g2){g2=g1.l2m[k2]={label:(o.s.dcNm||'(미지정)')+(o.s.dcCd?(' ('+o.s.dcCd+')'):''),items:[],q:0,s:0,c:0,m:0};g1.l2.push(g2);} g2.q+=o.outQty;g2.s+=o.salesAmt;g2.c+=o.costAmt;g2.m+=o.marginAmt;g2.items.push(o); });
      sum.innerHTML='총 <b>'+L1.length+'</b>대표출고장 · 매출 <b>'+_cnum(gS)+'</b> · 순마진 <b>'+_cnum(gM)+'</b>';
      L1.forEach(function(g1,i1){ rowsD.push({t:'l1',g:g1,i1:i1}); if(!_statCollapsed['z1#'+i1]) g1.l2.forEach(function(g2,i2){ rowsD.push({t:'l2',g:g2,i1:i1,i2:i2}); if(!_statCollapsed['z2#'+i1+'.'+i2]) g2.items.forEach(function(o){ rowsD.push({t:'it',o:o}); }); }); });
      _hdr=function(r){
        if(r.t==='l1'){ var c1=!!_statCollapsed['z1#'+r.i1]; return '<tr class="close-grp" onclick="statToggleKey(\'z1#'+r.i1+'\')"><td colspan="'+lead0+'" style="text-align:left"><span class="ccar">'+(c1?'▶':'▼')+'</span><b>'+_cesc(r.g.label)+'</b> <span style="color:#5b6b7a;font-weight:600">('+r.g.l2.length+'개 출고장)</span></td>'+_statCells(r.g.q,r.g.s,r.g.c,r.g.m)+'</tr>'; }
        var c2=!!_statCollapsed['z2#'+r.i1+'.'+r.i2]; return '<tr class="close-sub" onclick="statToggleKey(\'z2#'+r.i1+'.'+r.i2+'\')" style="cursor:pointer"><td colspan="'+lead0+'" style="text-align:left;padding-left:24px"><span class="ccar">'+(c2?'▶':'▼')+'</span>'+_cesc(r.g.label)+' <span style="color:#5b6b7a;font-weight:600">(품목 '+r.g.items.length+'종)</span></td>'+_statCells(r.g.q,r.g.s,r.g.c,r.g.m)+'</tr>';
      };
    } else {
      var ab=_closeAgg(_statRows, function(r){ return (r.bizNm||'(미지정)')+'~'+r.itemCd; }), groups=[],gm={};
      ab.forEach(function(o){ var gk=o.s.bizNm||'(미지정)'; var g=gm[gk]; if(!g){g=gm[gk]={label:gk,items:[],q:0,s:0,c:0,m:0};groups.push(g);} g.items.push(o);g.q+=o.outQty;g.s+=o.salesAmt;g.c+=o.costAmt;g.m+=o.marginAmt; });
      sum.innerHTML='총 <b>'+groups.length+'</b>사업장 · 매출 <b>'+_cnum(gS)+'</b> · 순마진 <b>'+_cnum(gM)+'</b>';
      groups.forEach(function(g,gi){ rowsD.push({t:'g',g:g,gi:gi}); if(!_statCollapsed['b#'+gi]) g.items.forEach(function(o){ rowsD.push({t:'it',o:o}); }); });
      _hdr=function(r){ var c=!!_statCollapsed['b#'+r.gi]; return '<tr class="close-grp" onclick="statToggleKey(\'b#'+r.gi+'\')"><td colspan="'+lead0+'" style="text-align:left"><span class="ccar">'+(c?'▶':'▼')+'</span><b>'+_cesc(r.g.label)+'</b> <span style="color:#5b6b7a;font-weight:600">(품목 '+r.g.items.length+'종)</span></td>'+_statCells(r.g.q,r.g.s,r.g.c,r.g.m)+'</tr>'; };
    }
    lzMount({ wrap:wrap, pager:'closeStatusPager', head:head, list:rowsD, rows:STAT_ROWS, capTop:320,
              rowFn:function(r){ return (r.t==='it') ? _statItemRow(r.o,1) : _hdr(r); } });
  }
  // ── SWAL 공용(프로젝트 표준 SweetAlert2) ──
  /* ★경고·오류는 앱 공통 스타일(SweetAlert 기본 = 빨간 아이콘 + 빨간 확인버튼)을 그대로 쓴다.
       (2026-08-07 지적 — 이 화면만 확인버튼을 초록으로 덮어써서 다른 화면과 달라 보였다)
     성공·안내(success/info)는 화면 색과 맞춰 초록을 유지한다. */
  function swAlert(msg, icon){
    if(window.Swal){
      var o = {html:msg, icon:icon||'info', confirmButtonText:'확인'};
      /* ★색을 반드시 박아 둔다 — SweetAlert 기본 확인버튼은 보라(#7066e0)라
         생략하면 앱의 다른 메시지(빨간 버튼)와 달라 보인다(2026-08-07 지적). */
      o.confirmButtonColor = (icon==='error' || icon==='warning') ? '#e0342c' : '#137a6c';
      return Swal.fire(o);
    }
    alert((''+msg).replace(/<br\s*\/?>/gi,'\n'));
  }
  function swConfirm(msg, title){ if(window.Swal) return Swal.fire({title:title||'확인', html:msg, icon:'question', showCancelButton:true, confirmButtonText:'확인', cancelButtonText:'취소', confirmButtonColor:'#137a6c', cancelButtonColor:'#94a3b8'}).then(function(r){ return r.isConfirmed; }); return Promise.resolve(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))); }
  // ── 마감 확정/해제/상태 ──
  function _closeAction(mode, ym, after){   // mode='confirm'|'cancel'
    var isC = mode==='confirm';
    swConfirm(ym+(isC?' 월을 마감 확정하시겠습니까?<br>확정 후 해당 월 재고 수불(입/출고)이 잠깁니다.':' 월 마감 확정을 해제하시겠습니까?<br>(재고 수불 잠금이 풀립니다)'), isC?'🔒 마감 확정':'🔓 확정 해제').then(function(ok){
      if(!ok) return;
      var ctx='${pageContext.request.contextPath}';
      fetch(ctx+'/shipout/'+(isC?'confirmClosing':'cancelClosing')+'.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({ym:ym}) })
        .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
        .then(function(r){ if(!r.ok){ swAlert((isC?'확정':'해제')+' 실패: '+((r.t||'').trim()),'error'); return; } swAlert(isC?('🔒 '+ym+' 마감 확정 완료'):('🔓 '+ym+' 확정 해제 완료'),'success'); if(after) after(); });
    });
  }
  function closeStatusChk(){
    var ym=(document.getElementById('closeStatusYm')||{}).value||''; if(!ym) return;
    var ctx='${pageContext.request.contextPath}';
    fetch(ctx+'/shipout/selectClosingStatus.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'ym='+encodeURIComponent(ym) })
      .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ j=null; }
        var d=(j&&j.data)||null, bar=document.getElementById('stStatusBar');
        var confirmed = d && d.status==='C';
        if(confirmed){ bar.innerHTML='🔒 <span style="color:#137a6c">마감 확정됨</span> — 확정일시 '+(d.confirmDttm||'')+' / 확정자 '+(d.confirmUser||'')+' · 기말재고금액 '+_cnum(d.stockAmt); }
        else { bar.innerHTML='마감 상태: <span style="color:#a85700">미확정</span>'; }
        document.getElementById('stConfirmBtn').style.display = confirmed?'none':'';
        document.getElementById('stCancelBtn').style.display  = confirmed?'':'none';
      });
  }
  function closeConfirm(){ var ym=(document.getElementById('closeStatusYm')||{}).value||''; if(!ym){ swAlert('마감월을 선택하세요.','warning'); return; } _closeAction('confirm', ym, closeStatusChk); }
  function closeCancel(){  var ym=(document.getElementById('closeStatusYm')||{}).value||''; if(!ym){ swAlert('마감월을 선택하세요.','warning'); return; } _closeAction('cancel',  ym, closeStatusChk); }
  // ── 화면별(매출/매입/재고) 마감 확정/해제 — 각 화면의 마감월 기준 ──
  var CLOSE_YMID={sales:'closeSalesYm',cost:'closeCostYm',stock:'closeStockYm'};
  function _closeYmOf(kind){ var e=document.getElementById(CLOSE_YMID[kind]); return e?e.value:''; }
  function closeConfirmScreen(kind){ var ym=_closeYmOf(kind); if(!ym){ swAlert('마감월을 선택하세요.','warning'); return; } _closeAction('confirm', ym, function(){ closeStatusScreen(kind); }); }
  function closeCancelScreen(kind){  var ym=_closeYmOf(kind); if(!ym){ swAlert('마감월을 선택하세요.','warning'); return; } _closeAction('cancel',  ym, function(){ closeStatusScreen(kind); }); }
  function closeStatusScreen(kind){
    var ym=_closeYmOf(kind), cb=document.getElementById('confBtn_'+kind), xb=document.getElementById('canBtn_'+kind);
    if(!ym){ if(cb)cb.style.display=''; if(xb)xb.style.display='none'; return; }
    var ctx='${pageContext.request.contextPath}';
    fetch(ctx+'/shipout/selectClosingStatus.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'ym='+encodeURIComponent(ym) })
      .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ j=null; }
        var confirmed=!!(j&&j.data&&j.data.status==='C');
        if(cb) cb.style.display=confirmed?'none':''; if(xb) xb.style.display=confirmed?'':'none'; });
  }
  // ── 월별 마감이력 ──
  var _histRows=[];
  function closeHistLoad(){
    var ctx='${pageContext.request.contextPath}';
    fetch(ctx+'/shipout/selectClosingList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
      .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ swAlert('마감이력 응답 오류','error'); return; }
        _histRows=(j&&j.data)||[];
        var yrs={}; _histRows.forEach(function(r){ yrs[(''+(r.closeYm||'')).slice(0,4)]=1; });
        var sel=document.getElementById('closeHistYear'), cur=sel.value;
        sel.innerHTML='<option value="">전체</option>'+Object.keys(yrs).sort().reverse().map(function(y){ return '<option value="'+y+'">'+y+'년</option>'; }).join('');
        sel.value=cur||'';
        closeHistRender();
      }).catch(function(e){ swAlert('통신오류: '+e.message,'error'); });
  }
  function _histYm(s){ s=(''+(s||'')); return s.length===6? s.slice(0,4)+'-'+s.slice(4,6):s; }
  function closeHistRender(){
    var wrap=document.getElementById('closeHistWrap'), sum=document.getElementById('closeHistSum');
    var yr=(document.getElementById('closeHistYear')||{}).value||'';
    var rows=yr? _histRows.filter(function(r){ return (''+(r.closeYm||'')).slice(0,4)===yr; }) : _histRows;
    var thead='<thead><tr><th>마감월</th><th style="text-align:right">매출액</th><th style="text-align:right">매출원가</th><th style="text-align:right">순마진</th><th style="text-align:right">마진율</th><th style="text-align:right">매입액</th><th style="text-align:right">기말재고금액</th><th>확정일시</th></tr></thead>';
    if(!rows.length){ sum.textContent='확정된 마감 이력이 없습니다.'; wrap.innerHTML='<table class="logi-tb">'+thead+'<tbody><tr><td colspan="8" style="text-align:center;color:#9aa7b3;padding:22px">확정된 달이 없습니다. (마감현황에서 🔒 마감 확정 시 여기에 쌓입니다)</td></tr></tbody></table>'; return; }
    var tS=0,tG=0,tM=0,tP=0,tK=0;
    var body=rows.map(function(r){
      var s=+r.salesAmt||0, g=+r.cogsAmt||0, m=+r.marginAmt||0, p=+r.purchaseAmt||0, k=+r.stockAmt||0, rate=s?(m/s*100):0;
      tS+=s;tG+=g;tM+=m;tP+=p;tK+=k;
      return '<tr class="prow" style="cursor:pointer" onclick="closeHistGo(\''+_histYm(r.closeYm)+'\')"><td><b>'+_histYm(r.closeYm)+'</b></td>'
        +'<td style="text-align:right">'+_cnum(s)+'</td><td style="text-align:right">'+_cnum(g)+'</td>'
        +'<td style="text-align:right;font-weight:700;color:'+(m<0?'#c0392b':'#137a6c')+'">'+_cnum(m)+'</td>'
        +'<td style="text-align:right">'+rate.toFixed(1)+'%</td><td style="text-align:right">'+_cnum(p)+'</td>'
        +'<td style="text-align:right">'+_cnum(k)+'</td><td>'+_cesc(r.confirmDttm)+'</td></tr>';
    }).join('');
    var total='<tr class="close-total"><td style="text-align:left">■ 합계('+rows.length+'개월)</td><td style="text-align:right">'+_cnum(tS)+'</td><td style="text-align:right">'+_cnum(tG)+'</td><td style="text-align:right">'+_cnum(tM)+'</td><td style="text-align:right">'+(tS?(tM/tS*100).toFixed(1):'0.0')+'%</td><td style="text-align:right">'+_cnum(tP)+'</td><td style="text-align:right">'+_cnum(tK)+'</td><td></td></tr>';
    sum.innerHTML='총 <b>'+rows.length+'</b>개월 · 매출 <b>'+_cnum(tS)+'</b> · 순마진 <b>'+_cnum(tM)+'</b>';
    wrap.innerHTML='<table class="logi-tb">'+thead+'<tbody>'+total+body+'</tbody></table>';
  }
  function closeHistGo(ym){   // 행 클릭 → 마감현황 그 달로
    var menu=document.querySelector('.logi-side a.mi[data-key="closeStatus"]'); if(menu) logiGo('closeStatus', menu);
    var e=document.getElementById('closeStatusYm'); if(e) e.value=ym;
    if(typeof closeLoad==='function') closeLoad('status');
  }
  // ── 입고내역 (전체 입고 거래) ──
  var _inbRows=[], _inbPage=1, INB_PAGE=KONET_GRID_ROWS;
  function inbInit(){   // 진입 시 기본 기간 = 이번 달 1일 ~ 오늘 (비어있을 때만)
    var f=document.getElementById('inbFrom'), t=document.getElementById('inbTo'), d=new Date();
    var ym=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2);
    if(f && !f.value) f.value=ym+'-01';
    if(t && !t.value) t.value=ym+'-'+('0'+d.getDate()).slice(-2);
  }
  function inboundListLoad(){
    var f=(document.getElementById('inbFrom')||{}).value||'', t=(document.getElementById('inbTo')||{}).value||'', q=(document.getElementById('inbSrch')||{}).value||'';
    var ctx='${pageContext.request.contextPath}', body='findData='+encodeURIComponent(q);
    if(f&&t) body+='&fromDt='+encodeURIComponent(f)+'&toDt='+encodeURIComponent(t);
    fetch(ctx+'/prod/inboundList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:body })
      .then(function(r){ return r.text(); }).then(function(t2){ var j; try{ j=JSON.parse(t2); }catch(e){ swAlert('입고내역 응답 오류','error'); return; } _inbRows=(j&&j.data)||[]; _inbPage=1; inboundListRender(); })
      .catch(function(e){ swAlert('통신오류: '+e.message,'error'); });
  }
  /* ── 입고내역 = 2단 묶음(소계) + 접기/펼치기 + 스크롤 이어보기 (2026-08-04 요청)
       · 묶음 : [일자 ▸ 매입처] 또는 [매입처 ▸ 일자] — 위 버튼으로 바꾼다.
       · 각 묶음 줄에 <수량·금액 소계>를 달고, 줄을 누르면 접힌다(매출내역 출고장별 합계와 같은 규칙).
       · 표는 화면 바닥까지 채우고(lzMount fill), 아래로 내리면 다음 행이 이어 붙는다. */
  var _inbGrpBy='dt';                 // 'dt' = 일자▸매입처 / 'ven' = 매입처▸일자
  var _inbCollapsed={};               // 접힌 묶음 키
  var _inbFolded=false;               // 지금 '모두 접힘' 상태인지
  /* ★묶음 기준은 <버튼 2개 그대로> (2026-08-04 확정) — 지금 무엇으로 묶였는지 두 기준을
       나란히 놓고 봐야 알기 쉽다. 접기/펼치기만 <토글 하나>로 둔다. */
  function inbGrpBy(v){ _inbGrpBy=v; _inbCollapsed={}; _inbFolded=false; inboundListRender(); }
  function inbToggle(k){ _inbCollapsed[k]=!_inbCollapsed[k]; inboundListRender(); }
  function inbFoldToggle(){
    _inbFolded=!_inbFolded;
    _inbCollapsed={};
    if(_inbFolded) inbBuild().L1.forEach(function(g1,i1){ _inbCollapsed['1#'+i1]=true; });   // 1단만 남긴다
    inboundListRender();
  }
  /* 자료 → 2단 묶음 구조 */
  function inbBuild(){
    var L1=[], m1={};
    _inbRows.forEach(function(r){
      var k1 = (_inbGrpBy==='dt') ? _fmtYmd(r.trxDt) : (r.vendorNm||'(미지정)');
      var k2 = (_inbGrpBy==='dt') ? (r.vendorNm||'(미지정)') : _fmtYmd(r.trxDt);
      var g1=m1[k1]; if(!g1){ g1=m1[k1]={ label:k1, l2:[], m2:{}, q:0, a:0, cnt:0 }; L1.push(g1); }
      g1.q+=(+r.qty||0); g1.a+=(+r.amt||0); g1.cnt++;
      var g2=g1.m2[k2]; if(!g2){ g2=g1.m2[k2]={ label:k2, items:[], q:0, a:0 }; g1.l2.push(g2); }
      g2.q+=(+r.qty||0); g2.a+=(+r.amt||0); g2.items.push(r);
    });
    return { L1:L1 };
  }
  function inboundListRender(){
    var wrap=document.getElementById('inbWrap'), sum=document.getElementById('inbSum'), pg=document.getElementById('inbPager');
    // 매입처는 코드 + 이름 두 칸 (2026-08-01 요청) — 총합계 colspan 은 아래에서 같이 5로 맞춰 둔다
    var thead='<thead><tr><th>입고일</th><th>매입처</th><th>매입처명</th><th>품목코드</th><th>품목명</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>비고</th></tr></thead>';
    var tQ=0,tA=0; _inbRows.forEach(function(r){ tQ+=(+r.qty||0); tA+=(+r.amt||0); });
    if(!_inbRows.length){ sum.textContent='입고 내역이 없습니다. (상품관리 ▸ 재고 탭에서 입고 등록 시 표시)'; wrap.innerHTML=''; pg.innerHTML=''; return; }
    var b=inbBuild(), L1=b.L1;
    sum.innerHTML='총 <b>'+_inbRows.length.toLocaleString()+'</b>건 · 수량합 <b>'+_cnum(tQ)+'</b> · 금액합 <b>'+_cnum(tA)+'</b>'
      +' <span style="margin-left:10px;color:#5a6b7a">묶음</span>'
      +' <button type="button" class="'+(_inbGrpBy==='dt'?'on':'')+'" onclick="inbGrpBy(\'dt\')">일자 ▸ 매입처</button>'
      +' <button type="button" class="'+(_inbGrpBy==='ven'?'on':'')+'" onclick="inbGrpBy(\'ven\')">매입처 ▸ 일자</button>'
      +' <button type="button" style="margin-left:6px" onclick="inbFoldToggle()"'
      +   ' title="누르면 접기 ↔ 펼치기가 바뀝니다 (접으면 1단 묶음만 남습니다)">'
      +   (_inbFolded ? '⊞ 모두 펼치기' : '⊟ 모두 접기')+'</button>';
    var totalRow='<tr class="close-total"><td colspan="5" style="text-align:left">■ 총합계 ('+L1.length.toLocaleString()+(_inbGrpBy==='dt'?'일':'개 매입처')+')</td><td style="text-align:right">'+_cnum(tQ)+'</td><td></td><td style="text-align:right">'+_cnum(tA)+'</td><td></td></tr>';

    /* 표시행 목록 — 접힘을 반영해 <행 단위>로 만든다(스크롤 이어보기가 행 수로 자른다) */
    var list=[];
    L1.forEach(function(g1,i1){
      list.push({t:'1',i1:i1});
      if(_inbCollapsed['1#'+i1]) return;
      g1.l2.forEach(function(g2,i2){
        list.push({t:'2',i1:i1,i2:i2});
        if(_inbCollapsed['2#'+i1+'.'+i2]) return;
        g2.items.forEach(function(r){ list.push({t:'d',r:r}); });
      });
    });

    var g1Row=function(i1){
      var g=L1[i1], c=!!_inbCollapsed['1#'+i1];
      return '<tr class="close-grp" onclick="inbToggle(\'1#'+i1+'\')" style="cursor:pointer">'
        +'<td colspan="5" style="text-align:left"><span class="ccar">'+(c?'▶':'▼')+'</span><b>'+_cesc(g.label)+'</b>'
        +' <span style="color:#5b6b7a;font-weight:600">('+g.l2.length+(_inbGrpBy==='dt'?'개 매입처':'일')+' · '+g.cnt+'건)</span></td>'
        +'<td style="text-align:right">'+_cnum(g.q)+'</td><td></td><td style="text-align:right">'+_cnum(g.a)+'</td><td></td></tr>';
    };
    var g2Row=function(i1,i2){
      var g=L1[i1].l2[i2], c=!!_inbCollapsed['2#'+i1+'.'+i2];
      return '<tr class="close-sub" onclick="inbToggle(\'2#'+i1+'.'+i2+'\')" style="cursor:pointer">'
        +'<td colspan="5" style="text-align:left; padding-left:26px"><span class="ccar">'+(c?'▶':'▼')+'</span>'+_cesc(g.label)
        +' <span style="color:#5b6b7a;font-weight:600">(품목 '+g.items.length+'건)</span></td>'
        +'<td style="text-align:right">'+_cnum(g.q)+'</td><td></td><td style="text-align:right">'+_cnum(g.a)+'</td><td></td></tr>';
    };
    var dRow=function(r){
      return '<tr><td>'+_fmtYmd(r.trxDt)+'</td><td>'+_cesc(r.vendorCd||'-')+'</td><td class="txt-l">'+_cesc(r.vendorNm||'-')+'</td><td>'+_cesc(r.prodCd)+'</td><td class="txt-l">'+_cesc(r.prodNm)+'</td>'
        +'<td style="text-align:right">'+_cnum(r.qty)+'</td><td style="text-align:right">'+_cnum(r.unitPrice)+'</td>'
        +'<td style="text-align:right">'+_cnum(r.amt)+'</td><td>'+_cesc(r.remark)+'</td></tr>';
    };
    lzMount({ wrap:wrap, pager:'inbPager', head:'<table class="logi-tb">'+thead+'<tbody>'+totalRow,
              list:list, rows:INB_PAGE, capTop:214, fill:true,
              rowFn:function(x){ return (x.t==='1') ? g1Row(x.i1) : (x.t==='2') ? g2Row(x.i1,x.i2) : dRow(x.r); } });
    wrap.scrollTop=0;
  }
  // ── 재고현황 (전체 품목 현재고) ──
  // 한 번에 보여줄 행수 10 — 이 표만 예외다(공통 18 아님). 아래 ②수불 내역까지 한 화면에 들어와야 해서(2026-07-25 요청).
  /* 상단 재고 그리드 행수 — 10 → 7 (2026-08-07 요청).
     10 → 7 로 줄였다가, 조회줄 라벨을 빼 자리가 남아 11 로 늘렸다(2026-08-07 요청).
     하단 ②는 남은 화면 높이를 자동으로 채우므로(_stkLedFit) 이 값만 바꾸면 된다. */
  var _stkRows=[], STK_PAGE=11;
  /* 매칭코드 하위 행 접기 상태 (2026-08-07 요청)
       _stkExpAll = 전체 기본값(true=펼침) · _stkExp[코드] = 그 줄만 뒤집기
     토글하면 stkStatusRender() 로 다시 그린다 — DOM 을 뒤지는 것보다 단순하고,
     스크롤로 행이 이어붙어도 상태가 어긋나지 않는다. */
  var _stkExpAll = true, _stkExp = {};
  function stkExpOn(cd){ var v=_stkExp[cd]; return (v===undefined) ? _stkExpAll : v; }
  function stkExpToggle(cd, ev){ if(ev) ev.stopPropagation(); _stkExp[cd] = !stkExpOn(cd); stkStatusRender(); }
  /* 접기·펼치기 버튼의 모양을 상태에 맞춰 칠한다 (2026-08-07).
       on=기본(펼침) 이면 수수하게, off=접은 상태면 주황으로 채워 '지금 접어 놨다' 를 알린다.
     같은 규칙을 ①표·②수불 내역이 함께 쓰므로 한 군데에 둔다. */
  function _stkExpBtnPaint(b, on, onTxt, offTxt){
    if(!b) return;
    b.innerHTML = on ? onTxt : offTxt;
    /* ②의 [아래로 펼치기]와 같은 규칙 — 두 쪽 다 칠하되 색을 갈라 둔다(2026-08-07).
       접기(펼쳐져 있는 상태) = 초록 / 펼치기(접혀 있는 상태) = 주황. */
    b.style.color='#fff'; b.style.fontWeight='800';
    b.style.background = on ? '#137a6c' : '#b06a00';
    b.style.borderColor = on ? '#137a6c' : '#b06a00';
  }
  function stkExpToggleAll(){
    _stkExpAll = !_stkExpAll; _stkExp = {};   /* 개별 설정은 초기화 — 안 그러면 버튼과 화면이 어긋난다 */
    /* ★펼친 상태와 접은 상태를 색으로 갈라 둔다 (2026-08-07 요청 "펼치기 접기 구분되게") —
         글자만 바뀌면 ▼/▶ 를 읽어야 지금 어느 쪽인지 알 수 있었다.
       펼침(기본) = 흐린 테두리 / 접힘(손댄 상태) = 주황 채움. 매칭줄 색과 같은 계열이다. */
    var b=document.getElementById("stkExpBtn");
    if(b) _stkExpBtnPaint(b, _stkExpAll, "▼ 매칭 접기", "▶ 매칭 펼치기");
    stkStatusRender();
  }
  function _fmtYmd(s){ s=(''+(s||'')); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
  /* 매칭코드로 찾아 대표코드로 바꾸었을 때, 원래 친 매칭코드를 기억해 요약줄에 알린다 */
  var _stkSrchVia = '';
  function stkStatusLoad(){
    stkSrchTog();
    _stkLedCache={};   // 새로 조회하면 수불내역 캐시도 버린다(출고 반영분을 놓치지 않게)
    var q=(document.getElementById('stkSrch')||{}).value||'', ctx='${pageContext.request.contextPath}';
    /* ★매칭코드로 찾으면 대표코드로 바꿔 찾는다 (2026-08-07 — "검색이 안됨").
         재고표(TBL_STOCK_MST)는 대표코드로만 쌓인다. 매칭코드는 그 밑에 달린 이름일 뿐이라
         그대로 서버에 보내면 언제나 '자료가 없습니다' 가 된다(↳ 줄의 돋보기를 눌러도 마찬가지).
       역방향 표(_stkAliasRev)가 이미 화면에 있으므로 보내기 전에 바꿔 준다.
       ★검색어 칸은 그대로 둔다 — 친 글자가 임의로 바뀌면 "내가 친 게 아닌데?" 가 된다.
         대신 아래 요약줄에 "…의 대표코드로 찾았습니다" 를 적어 둔다. */
    _stkSrchVia = '';
    var _qq=String(q).trim();
    if(_qq && _stkAliasRev && (_stkAliasRev[_qq]||[]).length){
      _stkSrchVia = _qq;                       // 사용자가 넣은 매칭코드
      q = _stkAliasRev[_qq][0].cd;             // 실제로 찾을 대표코드
    }
    var asOf=(document.getElementById('stkAsOf')||{}).value||'';
    var lbl=document.getElementById('stkAsOfLbl'); if(lbl) lbl.textContent = asOf ? ('기준일 '+asOf+' 까지 (기말)') : '전체 (현재고)';
    fetch(ctx+'/prod/stockStatusList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'findData='+encodeURIComponent(q)+'&asOfDt='+encodeURIComponent(asOf) })
      .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ swAlert('재고현황 응답 오류','error'); return; } _stkRows=(j&&j.data)||[]; stkStatusRender();
        /* 거래처코드 칸 — 조회할 때마다 다시 읽는다(재고 조회를 기다리게 하지 않고, 도착하면 표만 다시 그린다).
           ★한 번만 읽고 캐시하면 방금 등록한 매칭코드가 재로그인 전까지 안 보인다(2026-08-01 지적). */
        stkAliasLoad(function(){ stkStatusRender(); });
        var st=document.getElementById('stkStamp'); if(st) st.textContent=_now2(); })
      .catch(function(e){ swAlert('통신오류: '+e.message,'error'); });
  }
  function _now2(){ var d=new Date(), p=function(n){return ('0'+n).slice(-2);}; return d.getFullYear()+'-'+p(d.getMonth()+1)+'-'+p(d.getDate())+' '+p(d.getHours())+':'+p(d.getMinutes())+':'+p(d.getSeconds()); }
  function stkAsOfClear(){ var el=document.getElementById('stkAsOf'); if(el) el.value=''; stkStatusLoad(); }
  /* 기준일 빠른 선택 — 0=오늘, -1=전월 말일(new Date(y,m,0) 이 전달 마지막 날이다) */
  function stkAsOfSet(kind){
    var el=document.getElementById('stkAsOf'); if(!el) return;
    var d=new Date();
    if(kind===-1) d=new Date(d.getFullYear(), d.getMonth(), 0);
    el.value = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2);
    stkStatusLoad();
  }
  // (A) 출고반영 재집계 — 전체 SHIPOUT을 원장 O행으로 재동기화 + 현재고 재계산
  function _fmtYm6(m){ m=(''+(m||'')); return m.length===6 ? m.slice(0,4)+'-'+m.slice(4,6) : m; }
  function stkRebuild(){
    var ctx='${pageContext.request.contextPath}';
    // 1) 마감 확정월 조회 → 팝업에 '제외되는 마감월' 명시
    fetch(ctx+'/prod/closedMonths.do', { method:'POST', credentials:'same-origin' })
      .then(function(r){ return r.json(); }).catch(function(){ return {months:[]}; })
      .then(function(j){
        var ms=(j&&j.months)||[];
        var excl = ms.length ? ('제외되는 <b style="color:#c0392b">마감 확정월: '+ms.map(_fmtYm6).join(', ')+'</b>') : '제외할 마감 확정월 없음 — <b>전체 기간 반영</b>';
        swConfirm('전체 <b>출고(SHIPOUT)</b>를 재고 수불원장에 반영하고 현재고를 다시 계산합니다.<br>'+excl
                 +'<br><span style="font-size:12.5px;color:#5a6b7a">여러 번 눌러도 안전합니다 — 지우고 다시 만드는 방식이라 결과가 같습니다.</span>'
                 +'<br>진행할까요?','🔄 출고반영 재집계').then(function(ok){ if(!ok) return;
          /* ★진행바 = 서버가 알려주는 '실제' 진행률 (2026-08-01).
               재집계는 출고일자 수만큼 원장을 다시 만들어 자료가 쌓이면 수십 초가 걸리는데,
               요청이 POST 하나라 화면이 멈춘 것처럼 보였다.
               서버(RebuildProgress)가 '몇 개 중 몇 개'를 적어 두고 여기서 짧게 물어본다 —
               시간으로 늘어나는 가짜 막대를 쓰지 않는 이유다. */
          shpProgShow('시작하는 중…', '🔄 출고반영 재집계');
          _shpProgIndet('시작하는 중…');                 // 총량을 받기 전 — 꽉 찬 줄무늬로 '살아있음'을 보인다
          var _t0 = Date.now();
          function _tick(){
            fetch(ctx+'/prod/stockRebuildProgress.do', { method:'POST', credentials:'same-origin' })
              .then(function(r){ return r.json(); })
              .then(function(p){
                var el = Math.round((Date.now()-_t0)/1000) + '초';
                if(!p || !p.running){                   // 시작 전이거나 이미 끝남 — POST 응답이 마무리한다
                  _shpProgIndet('진행 중… (경과 '+el+')'); return;
                }
                if(p.total > 0){
                  /* 마지막 '현재고 집계' 단계가 남아 있으므로 95% 에서 멈춰 둔다 */
                  _shpProgWidth(Math.min(95, p.done * 95 / p.total), false);
                  _shpProgLab(p.phase + '  ('+p.done+' / '+p.total+' · 경과 '+el+')');
                } else {
                  _shpProgIndet((p.phase||'준비 중…')+'  (경과 '+el+')');
                }
              })
              .catch(function(){                        // 폴링 실패해도 멈춘 것처럼 보이지 않게
                _shpProgIndet('진행 중… (경과 '+Math.round((Date.now()-_t0)/1000)+'초)');
              });
          }
          _tick();                                      // 첫 조회를 기다리지 않는다(첫 단계가 길 수 있다)
          var poll = setInterval(_tick, 500);
          function stop(){ clearInterval(poll); shpProgHide(); }
          fetch(ctx+'/prod/stockRebuild.do', { method:'POST', credentials:'same-origin' })
            .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
            .then(function(r){
              clearInterval(poll);
              if(!r.ok){ shpProgHide(); swAlert('재집계 실패: '+((r.t||'').trim()),'error'); return; }
              shpProgDone();
              setTimeout(function(){ shpProgHide();
                swAlert('출고반영 재집계 완료 · 출고일자 <b>'+(r.t||'0')+'</b>건 반영','success'); stkStatusLoad();
              }, 350);
            })
            .catch(function(e){ stop(); swAlert('통신오류: '+e.message,'error'); });
        });
      });
  }
  // 재고현황 행 클릭 → 그 품목의 수불 내역(근거)을 하단 ② 그리드에 표시
  var _IOGB={I:'입고',O:'출고',R:'반품',A:'조정'};
  // 사업장 셀: 여러 곳이면 첫 곳 + [＋N] 만 표시 — 클릭하면 전체 펼침/접기
  /* 대체출고 표시 — 품목코드 칸 아래에 '실제로 나간 매칭코드(수량)' 를 한 줄에 하나씩 붙인다.
       재고는 대표코드(주코드) 하나로 떨어지지만 실제 출고는 거래처 매칭코드다.
       서버(selectStockLedgerList.extCds)가 '코드(수량), 코드(수량)' 으로 주고,
       대체가 없는 줄은 빈 값이라 평소 화면은 대표코드 한 줄만 보인다.
     ★한 줄에 하나씩 : 콤마로 이어 붙이면 두 개만 돼도 줄이 접혀 읽기 어렵다(2026-08-07 요청).
     수불 내역·입출고 나누어보기 세 곳이 같이 쓰므로 함수로 뺐다. */
  /* ②수불 내역 표 높이를 '화면에 남은 만큼' 으로 맞춘다 (2026-08-07).
       종전엔 max-height 가 210px 로 박혀 있어, 검색으로 상단 그리드가 짧아지면
       아래에 큰 빈 공간이 남고 정작 수불 내역은 좁은 칸에서 스크롤해야 했다.
     · 상단 그리드 행수(STK_PAGE)가 바뀌어도 알아서 따라온다.
     · 창 크기가 바뀔 때도 다시 잡는다(아래 resize). 최소 180px 는 지켜 너무 납작해지지 않게. */
  function _stkLedFit(){
    var b=document.getElementById('stkLedgerBody'); if(!b) return;
    var top=b.getBoundingClientRect().top;
    if(!top) return;                       // 아직 안 그려졌으면 건너뛴다
    b.style.maxHeight=Math.max(180, Math.floor(window.innerHeight - top - 20))+'px';
  }
  window.addEventListener('resize', function(){ _stkLedFit(); });

  /* 서버 형식 '코드(수량)~사업장들|코드(수량)~사업장들' → [{cd,qty,biz}, …] */
  function _extParse(v){
    if(!v) return [];
    return String(v).split('|').map(function(seg){
      var t=seg.split('~'), head=t[0]||'', biz=t.slice(1).join('~')||'';
      var m=head.match(/^(.*)\((\-?[\d.]+)\)$/);
      return m ? { cd:m[1], qty:m[2], biz:biz } : { cd:head, qty:'', biz:biz };
    });
  }
  /* ★매칭코드를 고르면 그 코드분만 남긴 '가짜 원장 줄' 을 만든다 (2026-08-07 수정)
       종전에는 날짜 줄을 통째로 남겨서
         · 수량은 대표 전체(그 날 나간 모든 코드 합)로 잡히고
         · 하위 행에는 고르지 않은 코드까지 그대로 나왔다
       그래서 "매칭 1000455376 만" 인데 총계·하위가 안 맞았다(사용자 지적).
     → 수량·사업장·extCds 를 그 코드 것으로 갈아 끼운 사본을 돌려준다.
       그 코드가 없는 날짜 줄은 null → 걸러진다. 금액은 원장이 코드별로 안 나뉘어 0. */
  function _extPick(l, cd){
    /* ★매칭이 '섞인 날'만 서버가 extCds 를 채운다(그 날만 코드별로 갈라야 하니까).
         매칭이 하나도 없는 날은 빈 값이고, 그 날 출고는 전부 대표코드 몫이다.
         그 줄까지 버리면 대표코드를 골랐을 때 수량이 확 줄어 ①표와 안 맞는다
         (실측 1000455376 : ①55 인데 ②6 만 — 55 = 혼재일 6 + 매칭없는날 49, 2026-08-07).
       그래서 '대표코드를 고른 경우' 에 한해 빈 줄은 통째로 살린다. */
    if(!l.extCds && cd===l.prodCd) return l;
    var e=_extParse(l.extCds).filter(function(x){ return x.cd===cd; })[0];
    if(!e) return null;
    var o={}; for(var k in l) o[k]=l[k];
    /* ★품목코드 칸도 고른 코드로 바꾼다 (2026-08-07 요청 "매칭선택시에는 자기것만 나와야 합니다").
         재고가 빠지는 건 대표코드지만, 이 표는 지금 그 매칭코드로 나간 내역만 보고 있다.
         칸에 대표코드가 남아 있으면 줄마다 고른 코드와 다른 코드가 적혀 있어 딴 걸 보는 듯하다. */
    o.prodCd = cd;
    /* 품명도 그 코드의 거래처 품명으로 맞춘다(등록이 없으면 대표 품명 그대로 둔다). */
    o.prodNm = _extNmOf(l.prodCd, cd) || l.prodNm;
    o.qty = +e.qty || 0;
    o.amt = 0; o.unitPrice = 0;
    o.bizCd = e.biz || '';
    o.extCds = cd+'('+e.qty+')~'+(e.biz||'');
    return o;
  }
  /* 매칭코드의 '거래처 품명' — 대체출고 줄의 품명 칸에 쓴다(2026-08-07 요청).
     매칭표(_stkAlias)는 주코드로 걸려 있고 그 안에 {cd, nm} 이 들어 있다.
     대표코드 자신이거나 이름이 없으면 빈 문자열 — 억지로 대표 품명을 넣지 않는다.
     (같은 코드인데 이름만 다르면 "다른 물건인가" 하고 헷갈린다) */
  function _extNmOf(prodCd, extCd){
    if(!_stkAlias || !extCd) return '';
    var l=_stkAlias[String(prodCd||'').trim()]||[];
    for(var i=0;i<l.length;i++) if(l[i].cd===extCd) return l[i].nm||'';
    return '';
  }
  function _bizCell(v){
    v=(''+(v||'')).trim(); if(!v) return '';
    var a=v.split(', ');
    if(a.length<2) return _cesc(v);
    return '<span class="bizshort">'+_cesc(a[0])
      +' <a href="javascript:void(0)" style="color:#137a6c;font-weight:800;text-decoration:none;white-space:nowrap" onclick="_bizToggle(this,event)" title="사업장 '+a.length+'곳 모두 보기">＋'+(a.length-1)+'</a></span>'
      +'<span class="bizfull" style="display:none">'+_cesc(v)
      +' <a href="javascript:void(0)" style="color:#9aa7b3;font-weight:800;text-decoration:none;white-space:nowrap" onclick="_bizToggle(this,event)" title="접기">－</a></span>';
  }
  function _bizToggle(el, e){
    if(e){ e.stopPropagation(); }
    var td=el.parentNode; while(td && td.tagName!=='TD') td=td.parentNode; if(!td) return;
    var s=td.querySelector('.bizshort'), f=td.querySelector('.bizfull'); if(!s||!f) return;
    var open=(f.style.display==='none');
    f.style.display=open?'':'none'; s.style.display=open?'none':'';
  }
  /* 하단 ②수불내역을 부를 때마다 1 씩 올린다 — 늦게 도착한 옛 응답이 새 선택을
     덮어써서 '엉뚱한 품목이 잠깐 보이는' 현상을 막는다. */
  var _stkLedSeq = 0;
  /* extCd 를 주면 그 매칭코드로 나간 줄만 아래 ②에 보여 준다 (2026-08-07 요청).
     ①표의 ↳ 매칭코드 줄을 눌렀을 때 쓴다. 서버는 그대로 두고 화면에서 거른다 —
     원장은 대표코드 하루 한 줄이고, 매칭코드별 내역은 extCds 안에 이미 들어 있다. */
  /* ★고른 품목을 ①그리드 맨 위로 올리고, ②를 화면 끝까지 펴 준다 (2026-08-07 요청).
       종전에는 목록 한가운데를 누르면 그 줄이 중간에 걸리고, ②는 화면 밖으로 밀려
       한 뼘밖에 안 보였다. 둘은 늘 같이 움직여야 뜻이 산다 — 위에서 고른 것을 아래에서 보니까.
     1) ①안쪽 스크롤 : 고른 줄이 얼어 있는 머리(머리줄+총합계) 바로 밑에 서게 한다.
        ↳ 매칭 줄을 눌렀어도 <대표코드 줄>을 올린다 — 대표가 위, 매칭이 그 아래여야 순서가 맞다.
     2) 바깥(.logi-main) 스크롤 : ②가 화면 아래로 잘려 있으면 그만큼 끌어올린다.
     3) _stkLedFit : 남은 높이를 ②가 다 쓰게 한다.
     ※ 줄이 스크롤에 따라 이어 붙는 목록(lzMount)이라, 다음 프레임에 한 번 더 잡는다. */
  function _stkScrollTop(wrap, el){
    var run=function(){
      var top=el;
      while(top && !top.getAttribute('data-main')) top=top.previousElementSibling;
      if(!top) top=el;
      var frozen=0;
      var _th=wrap.querySelector('table thead');          if(_th) frozen+=_th.offsetHeight;
      var _tt=wrap.querySelector('tbody tr.close-total'); if(_tt) frozen+=_tt.offsetHeight;
      wrap.scrollTop += top.getBoundingClientRect().top - wrap.getBoundingClientRect().top - frozen;
      /* ②를 화면 끝까지 — 카드가 아래로 잘려 있으면 바깥 스크롤을 그만큼 내린다 */
      var main=document.querySelector('.logi-main'), bd=document.getElementById('stkLedgerBody');
      if(main && bd){
        var need = bd.getBoundingClientRect().top + 180 + 20 - window.innerHeight;
        if(need > 0) main.scrollTop += need;
      }
      _stkLedFit();
    };
    run();
    if(window.requestAnimationFrame) requestAnimationFrame(run);
  }
  var _stkSelSeq = 0;   /* 지금 고른 품목 — 표를 다시 그려도 선택을 되살리는 데 쓴다(2026-08-07) */
  function stkLedgerDetail(prodSeq, el, extCd){
    _stkLedExt = extCd || "";   /* ①의 ↳ 매칭 줄을 눌렀으면 그 코드, 대표 줄이면 빈 값 */
    _stkSelSeq = prodSeq || 0;
    /* 선택행 하이라이트 — 전 행을 돌며 인라인 style 을 지우면 그때마다 화면이 다시 계산돼
       행이 많을수록 눈에 띄게 껌벅인다. 직전 선택 하나만 벗긴다(2026-08-06 지적). */
    var wrap=document.getElementById('stkStatusWrap');
    /* ★querySelector 는 첫 줄 하나만 반환한다 — 선택 표시가 둘 이상일 때
       하나만 벗겨져 이전 것이 남았다(2026-08-07 지적: 대표 줄 + ↳ 줄이 동시에 초록).
       표시는 .stk-on 이 붙은 줄뿐이라 전부 벗겨도 부담이 없다(대개 1~2개). */
    if(wrap){
      var _prevs=wrap.querySelectorAll('tbody tr.stk-on');
      for(var _p=0;_p<_prevs.length;_p++){ _prevs[_p].classList.remove('stk-on'); _prevs[_p].style.background=''; }
    }
    /* 배경은 위 CSS(.stk-on)가 준다 — 인라인으로 또 칠하면 CSS 를 고쳐도 안 바뀐다(2026-08-07) */
    if(el){ el.classList.add('stk-on'); }
    /* ★고른 품목을 그리드 맨 위로 올린다 (2026-08-07 요청).
         목록 한가운데를 누르면 그 줄과 딸린 ↳ 매칭 줄이 화면 중간에 걸려,
         아래 ②와 견주려면 눈이 위아래로 왔다 갔다 해야 했다.
       · ↳ 줄을 눌렀어도 <대표코드 줄>을 올린다 — 대표가 위, 매칭이 그 아래로 서야 순서가 맞다.
       · 얼어 있는 머리(표 머리줄 + 총합계 줄) 높이만큼 빼야 그 바로 밑에 붙는다. */
    /* ★줄을 눌렀다고 목록을 움직이지 않는다 (2026-08-07 "상단 클릭시 무조건 상단으로 가는데").
         맨 위로 올리는 건 [▲ 아래로 펼치기] 를 눌렀을 때뿐이고, [▼ 접기] 면 있던 자리로 돌아온다.
         펼쳐 놓은 채로 다른 줄을 고르면 그 줄에 맞춰 다시 잡아 준다. */
    if(_stkLedMax && el && wrap){ _stkTopFitSel(true); _stkScrollTop(wrap, el); }
    if(!prodSeq){ document.getElementById('stkLedgerHead').innerHTML='<span style="color:#c0392b">이 품목은 수불원장 키가 없어 내역을 조회할 수 없습니다.</span>'; document.getElementById('stkLedgerBody').innerHTML=''; return; }
    var ctx='${pageContext.request.contextPath}', row=null;
    for(var i=0;i<_stkRows.length;i++){ if((_stkRows[i].prodSeq||0)==prodSeq){ row=_stkRows[i]; break; } }
    var myTurn = ++_stkLedSeq;
    /* ★껌벅임 해결 (2026-08-06 지적) —
       종전엔 머리줄을 '불러오는 중…' 한 줄로 갈아치웠다. 그래서 누를 때마다 제목이
       사라졌다 나타나고, 응답이 오면 표가 훌쩍 뛰었다.
       이제 : ① 제목·품명은 이미 손에 있는 상단 행 자료로 **즉시** 그린다(기다릴 이유가 없다)
              ② 본문은 지우지 않고 살짝 흐리게만 — 자리가 그대로라 표가 안 뛴다
              ③ 응답이 오면 흐림만 풀고 본문을 바꾼다 */
    var hd=document.getElementById('stkLedgerHead'), bd=document.getElementById('stkLedgerBody');
    hd.innerHTML='<div style="font-weight:800;font-size:14px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">'+_cesc(row?row.prodCd:'')+' <span style="font-weight:400;color:#37475a">'+_cesc(row?row.prodNm:'')+'</span></div>'
      + '<div style="color:#9aa7b3;font-size:13px;white-space:nowrap;margin-left:14px">불러오는 중…</div>';
    /* ★한 번 본 품목은 다시 부르지 않는다 (2026-08-06 속도 확인) —
         ↑↓ 로 목록을 훑을 때 같은 줄을 오가는 일이 잦은데, 그때마다 서버를 부르면
         50~200ms 씩 기다린다. 캐시가 있으면 그리기만 하므로 눈에 띄게 빨라진다.
       ★캐시는 [조회]·[새로고침] 때 비운다(stkStatusLoad) — 출고가 반영되면 옛 값이 남으면 안 된다. */
    if(_stkLedCache[prodSeq]){
      _stkLedRaw=_stkLedCache[prodSeq]; _stkLedRow=row;
      if(bd) bd.style.opacity='1';
      var _t0=(window.performance&&performance.now)?performance.now():0;
      _stkLedPaint();
      _stkLedLog(prodSeq, -1, _t0);
      return;
    }
    if(bd){ bd.style.transition='opacity .12s'; bd.style.opacity='.45'; }
    var _tReq=(window.performance&&performance.now)?performance.now():0;
    fetch(ctx+'/prod/stockList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'prodSeq='+encodeURIComponent(prodSeq) })
      .then(function(r){ return r.text(); }).then(function(t){
        if(myTurn!==_stkLedSeq) return;                 // 그새 다른 행을 눌렀다 — 이 응답은 버린다
        var _tGot=(window.performance&&performance.now)?performance.now():0;
        if(bd) bd.style.opacity='1';
        var j; try{ j=JSON.parse(t); }catch(e){ swAlert('수불 내역 응답 오류','error'); return; }
        /* 서버는 전 기간을 한 번에 준다. 받은 것을 그대로 들고 있다가 화면에서 기간만 잘라 쓴다
           — 기간 버튼(1/2/3/6개월·전체)을 눌러도 다시 조회하지 않아 즉시 바뀐다(2026-08-06 요청). */
        _stkLedRaw = (j&&j.data)||[];
        _stkLedCache[prodSeq] = _stkLedRaw;
        _stkLedRow = row;
        _stkLedPaint();
        _stkLedLog(prodSeq, _tGot-_tReq, _tGot);
      }).catch(function(e){
        if(myTurn!==_stkLedSeq) return;
        if(bd) bd.style.opacity='1';
        swAlert('통신오류: '+e.message,'error');
      });
  }

  /* ── ②수불내역 기간 (2026-08-06 요청) ────────────────────────────────
       기본 1개월. 오래된 품목은 수백 건이 한꺼번에 나와 최근 흐름이 안 보였다.
       ★서버 재조회 없이 화면에서만 자른다 — 버튼을 눌러도 기다림이 없다. */
  /* _stkLedMon : 몇 개월치를 보여 줄지. **0 = 전체**
       기본값 변경 이력(2026-08-06) : 1개월 → 2개월 → 12개월 → **전체**(최종).
       인덱스 추가로 서버가 100ms 안쪽으로 빨라져 전체를 봐도 느리지 않다. */
  var _stkLedRaw=[], _stkLedRow=null, _stkLedMon=0;
  /* ②수불 내역 대체출고 하위 행 펼침 상태 (2026-08-07 요청) */
  var _ledExpAll = true;
  /* ①에서 고른 매칭코드 — 빈 문자열이면 그 품목 전체(2026-08-07) */
  var _stkLedExt = "";
  function ledExpToggle(){ _ledExpAll = !_ledExpAll; _stkLedPaint(); }

  /* ★②를 화면 위까지 끌어올리기 (2026-08-07 요청 — "하단 내용을 위까지 올리는 것").
       종전에 넣은 [매칭 접기] 는 하위 줄을 접는 것이라 뜻이 달랐다.
       여기서는 ①카드를 통째로 접어, 남는 자리를 ②가 다 쓰게 한다(높이는 _stkLedFit 이 알아서).
     · 조회 조건·상단 그리드는 접힐 뿐 지워지지 않는다 — 다시 누르면 그대로 돌아온다.
     · ESC 로도 풀 수 있게 해 둔다(넓혀 놓고 버튼을 못 찾는 일을 막는다). */
  var _stkLedMax = false;
  /* ★①은 그대로 두고 ②만 아래로 편다 (2026-08-07 "상단내용 밑으로 펼쳐져야 함").
       처음에는 ①카드를 감춰 ②를 끌어올렸는데, 그러면 위에서 무엇을 골랐는지가 안 보이고
       되돌릴 때 화면이 튀었다("접기하면 반대로"). 위는 자리를 지키고, 아래가 길어지는 게 맞다.
     펼침 = ②의 높이 제한을 풀어 <모든 줄>을 그대로 늘어놓는다(스크롤은 바깥 화면이 맡는다).
     접힘 = 종전처럼 남은 화면 높이에 맞춘 상자 안에서 스크롤(_stkLedFit). */
  /* 펼칠 때 ①을 <고른 줄과 그 매칭 줄들> 높이로만 줄인다 (2026-08-07 "매칭코드있으면 그밑으로 까지").
       ①을 통째로 감추면 무엇을 고른 건지 안 보이고, 그대로 두면 ②가 커질 자리가 없다.
       고른 줄 묶음만 남기면 위는 뜻을 잃지 않고 아래는 화면 끝까지 쓴다.
     접을 때는 lzFit 이 잡아 둔 높이를 도로 넣는다(직접 계산하지 않는다 — 규칙이 두 벌이 되면 어긋난다). */
  function _stkTopFitSel(on){
    var w=document.getElementById('stkStatusWrap'); if(!w) return;
    var main=document.querySelector('.logi-main');
    if(!on){
      /* ★접으면 <있던 자리로> 되돌린다 (2026-08-07 요청 "원위치 하면 원복") —
           높이만 되돌리고 스크롤을 그대로 두면, 보던 줄이 아닌 엉뚱한 데서 다시 시작한다. */
      if(w._savedMax!=null){ w.style.maxHeight=w._savedMax; w._savedMax=null; }
      if(w._savedTop!=null){ w.scrollTop=w._savedTop;       w._savedTop=null; }
      if(main && w._savedMainTop!=null){ main.scrollTop=w._savedMainTop; w._savedMainTop=null; }
      return;
    }
    var sel=_stkSelSeq ? w.querySelector('tbody tr[data-seq="'+_stkSelSeq+'"]') : null;
    if(!sel) return;
    if(w._savedMax==null){
      w._savedMax=w.style.maxHeight;
      w._savedTop=w.scrollTop;
      if(main) w._savedMainTop=main.scrollTop;
    }
    var h=0;
    var th=w.querySelector('table thead');          if(th) h+=th.offsetHeight;
    var tt=w.querySelector('tbody tr.close-total'); if(tt) h+=tt.offsetHeight;
    h+=sel.offsetHeight;
    /* 다음 품목 줄(data-main) 이 나오기 전까지가 이 줄에 딸린 ↳ 매칭 줄들이다 */
    var n=sel.nextElementSibling;
    while(n && !n.getAttribute('data-main')){ h+=n.offsetHeight; n=n.nextElementSibling; }
    w.style.maxHeight=(h+2)+'px';
  }
  function stkLedMaxToggle(){
    _stkLedMax = !_stkLedMax;
    _stkLedPaint();          // 버튼 글자를 바꾸기 위해 머리를 다시 그린다
    _stkTopFitSel(_stkLedMax);
    if(_stkLedMax){
      /* 펼칠 때<만> 고른 묶음을 맨 위로 올린다 — 줄만 눌렀을 땐 목록이 움직이지 않는다
         (2026-08-07 "펼치기 할때 가게, 원위치 하면 원위치로"). */
      var w=document.getElementById('stkStatusWrap');
      var sel = (w && _stkSelSeq) ? w.querySelector('tbody tr[data-seq="'+_stkSelSeq+'"]') : null;
      if(w && sel) _stkScrollTop(w, sel);
      else _stkLedFit();
    }else{
      _stkLedFit();   // 자리는 _stkTopFitSel 이 이미 되돌렸다
    }
  }
  document.addEventListener('keydown', function(e){
    if(e.keyCode===27 && _stkLedMax) stkLedMaxToggle();
  });
  /* 매칭코드 선택 해제 — 그 품목 전체 내역으로 되돌린다 */
  function stkLedExtClear(){ _stkLedExt=""; _stkLedPaint(); }
  /* 품목별 수불내역 캐시 — [조회]·[새로고침] 때 비운다(stkStatusLoad) */
  var _stkLedCache={};
  /* 속도 확인용 로그 (2026-08-06) — F12 콘솔에 찍힌다.
       서버 : 응답까지 걸린 시간 (캐시면 '캐시')
       그리기 : 받은 뒤 화면에 뿌리는 데 걸린 시간
     둘 중 어느 쪽이 느린지 이걸로 가른다 — 느리다는 느낌만으로는 고칠 곳을 몸른다. */
  function _stkLedLog(prodSeq, ms, t0){
    if(!window.console||!console.log) return;
    var t1=(window.performance&&performance.now)?performance.now():0;
    var draw=(t0&&t1)?Math.round(t1-t0):0;
    console.log('[수불내역] prodSeq='+prodSeq
      +' · 서버 '+(ms<0?'캐시(0ms)':Math.round(ms)+'ms')
      +' · 그리기 '+draw+'ms'
      +' · 전체 '+_stkLedRaw.length+'건');
  }
  function stkLedMon(m){
    _stkLedMon = m;
    var box=document.getElementById('stkLedMonBox');
    if(box){ var b=box.querySelectorAll('button');
      for(var i=0;i<b.length;i++) b[i].className = (String(b[i].getAttribute('data-m'))===String(m)) ? 'btn-teal' : 'btn-line'; }
    _stkLedPaint();
  }
  /* 기준일 = 오늘에서 m개월 전 (YYYYMMDD 문자열로 비교 — trxDt 가 그 형식이다) */
  function _stkLedCut(){
    if(!_stkLedMon) return '';
    var d=new Date(); d.setMonth(d.getMonth()-_stkLedMon);
    return d.getFullYear()+('0'+(d.getMonth()+1)).slice(-2)+('0'+d.getDate()).slice(-2);
  }
  function _stkLedPaint(){
    var row=_stkLedRow, hd=document.getElementById('stkLedgerHead'), bd=document.getElementById('stkLedgerBody');
    if(!hd||!bd) return;
    var cut=_stkLedCut();
    var rows = cut ? _stkLedRaw.filter(function(l){ return String(l.trxDt||'').replace(/-/g,'') >= cut; }) : _stkLedRaw;
    /* ①에서 ↳ 매칭 줄을 눌러 들어온 경우 — 그 코드가 섞인 날짜 줄만 남긴다(2026-08-07). */
    if(_stkLedExt) rows = rows.map(function(l){ return (l.ioGb==='O') ? _extPick(l, _stkLedExt) : null; }).filter(Boolean);
    /* 걸러 보는 중에는 '출고'만 남는다 — 매칭코드는 출고에만 붙기 때문(입고는 주코드로 들어온다).
       그래서 입고·조정 줄이 통째로 빠지고 수량도 그 코드 몫만 남아, 표만 보면 값이 틀린 줄 안다
       (2026-08-07 "표시 주는 값이 이상함" 지적). 무엇을 보고 있는지 머리말에 숫자로 밝혀 둔다. */
    var _extSum=0, _extDays=0;
    if(_stkLedExt){ rows.forEach(function(l){ _extSum += (+l.qty||0); _extDays++; }); }
    {
        /* ★요약(입고계·출고계·현재고…)은 뺐다 (2026-08-07 요청) —
             같은 수치가 위 ①표의 그 품목 줄에 이미 있고,
             [입·출고 나누어보기] 창 상단 그리드에도 또 있다. 세 군데는 과하다.
           ★머리는 바깥 div 없이 한 조각만 넣는다 — stkLedgerHead 자체가 이미
             제목과 같은 줄에 서 있는 flex 줄이다(2026-08-06 한 줄 통합). */
        /* 대체출고 하위 행 접기/펼치기 (2026-08-07 요청) — ①표와 같은 방식.
           매칭이 섞인 날은 한 날짜가 여러 줄이 되어 훑기 어렵다. 여기서 한꺼번에 접는다. */
        var head=  '<div style="display:flex;align-items:center;gap:8px;min-width:0">'
                 + '<span style="font-weight:800;font-size:14px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">'+_cesc(row?row.prodCd:'')+' <span style="font-weight:400;color:#37475a">'+_cesc(row?row.prodNm:'')+'</span></span>'
                 /* ★[위로 넓히기] — ①카드를 접어 이 표가 화면 위까지 올라오게 한다(2026-08-07 요청).
                      종전 자리에 있던 [매칭 접기] 는 뜻이 달라 뺐다("이 기능 제외하고" 지적). */
                 /* ★두 상태 다 채움색으로 두되 색을 갈라 둔다 (2026-08-07 "접기처럼 색깔") —
                      한쪽만 칠해 두면 안 칠해진 쪽이 눌리지 않는 글자처럼 보였다.
                    펼치기 = 주황(매칭줄 계열) / 접기 = 초록(이 화면의 기본색). 화살표도 뒤집었다. */
                 + '<button class="btn-line" onclick="stkLedMaxToggle()" style="height:22px;padding:0 8px;font-size:11.5px;white-space:nowrap;flex:0 0 auto'
                 + ';color:#fff;font-weight:800'
                 + (_stkLedMax ? ';background:#137a6c;border-color:#137a6c' : ';background:#b06a00;border-color:#b06a00')+'"'
                 + ' title="'+(_stkLedMax?'위 ① 목록을 원래 높이로 되돌립니다. (ESC 로도 됩니다)'
                                        :'위 ①은 고른 줄과 그 매칭 줄만 남기고, 이 표를 위로 끌어올려 화면 끝까지 폅니다.')+'">'
                 /* 글자와 화살표를 맞춘다 — ①이 줄면서 이 표가 <위로> 올라오는 동작이다(2026-08-07) */
                 + (_stkLedMax?'▼ 접기':'▲ 위로 펼치기')+'</button>'
                 /* 매칭코드로 걸러 보는 중이면 그 사실과 푸는 길을 함께 보여 준다(2026-08-07) */
                 + (_stkLedExt ? ' <span style="color:#b06a00;font-weight:800;font-size:12px;white-space:nowrap"'
                               + ' title="매칭코드는 출고에만 붙습니다(입고는 대표코드로 들어옴). 그래서 이 상태에서는 출고 줄만 보이고, 수량도 이 코드로 나간 몫만 나옵니다.">'
                               + '· '+_cesc(_stkLedExt)+' 출고만 &nbsp;<span style="color:#137a6c">'+_cnum(_extSum)+'</span>'
                               + ' <span style="font-weight:400;color:#5a6b7a">('+_extDays+'일)</span></span>'
                               + ' <a href="javascript:void(0)" onclick="stkLedExtClear()" style="font-size:11.5px;color:#137a6c;font-weight:800;text-decoration:none;white-space:nowrap" title="이 품목 전체로 되돌립니다">✕ 전체</a>' : '')
                 + '</div>';
        var thead='<thead><tr><th>일자</th><th>품목코드</th><th>구분</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>매입처</th><th>사업장</th><th>근거구분</th><th>근거번호</th><th>비고</th><th>등록일시</th><th>등록자</th></tr></thead>';
        var body= rows.length ? rows.map(function(l){
            var io=_IOGB[l.ioGb]||l.ioGb, isOut=(l.ioGb==='O');
            return '<tr><td>'+_fmtYmd(l.trxDt)+'</td>'
              /* 품목코드 = 재고가 떨어진 '대표코드(주코드)'. 대체출고분은 아래에 하위 행으로 편다. */
              +'<td style="color:#37475a">'+_cesc(l.prodCd||'')+'</td>'
              +'<td style="font-weight:700;color:'+(isOut?'#b06a00':'#137a6c')+'">'+io+'</td>'
              +'<td style="text-align:right">'+_cnum(l.qty)+'</td>'
              +'<td style="text-align:right">'+_cnum(l.unitPrice)+'</td>'
              +'<td style="text-align:right">'+_cnum(l.amt)+'</td>'
              /* 매입처는 '코드', 사업장은 '이름' — 둘 다 이름으로 두면 같은 값이 두 번 나온다(2026-08-01 지적).
                 코드 칸에는 이름을 hover 로 붙여 둔다. */
              +'<td title="'+_cesc(l.vendorNm||'')+'">'+_cesc(l.vendorCd||'')+'</td>'
              /* 사업장 — 출고(SHIPOUT)만 원장에 사업장이 남는다. 전표(SALE·PURCH)는 사업장 대신
                 거래처로 관리하므로, 비어 있으면 그 거래처명을 대신 보여 준다(빈칸으로 두면 '누락'처럼 보인다). */
              +'<td>'+(l.bizCd ? _bizCell(l.bizCd)
                               : (l.vendorNm ? '<span style="color:#5a6b7a">'+_cesc(l.vendorNm)+'</span>' : ''))+'</td>'
              +'<td>'+_cesc(l.refGb||'')+'</td>'
              +'<td>'+_cesc(l.refNo||'')+'</td>'
              +'<td>'+_cesc(l.remark||'')+'</td>'
              +'<td style="color:#9aa7b3">'+_cesc(l.regDttm||'')+'</td>'
              +'<td style="color:#9aa7b3">'+_cesc(l.regUser||'')+'</td></tr>'
              /* ★대체출고 하위 행 (2026-08-07 요청) — 대표 줄 아래에 매칭코드마다 한 줄.
                   품목코드·수량·사업장을 대표 줄과 '같은 칸' 에 세워 바로 견줄 수 있게 한다.
                   대체가 없는 날은 서버가 빈 값을 줘 하위 행이 아예 안 생긴다.
                   수량의 합 = 대표 줄 수량. 사업장도 코드별로 갈라 담아 온다. */
              /* ★쪼갤 게 없으면 안 그린다 (2026-08-07 지적) — ①표의 split 규칙과 같다.
                   · 코드를 골라 보는 중(_stkLedExt) 이면 표 전체가 이미 그 코드분이다.
                     줄마다 ↳ 를 또 달면 바로 위 줄과 수량·사업장이 똑같은 줄이 하나씩 더 생긴다.
                     '어느 코드를 보고 있나' 는 머리말 배지에 이미 적혀 있다.
                   · 안 걸렀더라도 그 날이 '대표코드 하나' 뿐이면 마찬가지로 되풀이다.
                     (단, 대표와 다른 코드 하나뿐인 날은 남긴다 — 대표코드 줄만 봐서는
                      실제로 어떤 코드로 나갔는지 알 수 없으니 그건 뜻이 있다.) */
              + ((_ledExpAll && !_stkLedExt) ? _extParse(l.extCds) : []).filter(function(e, i, a){
                  return !(a.length===1 && e.cd===l.prodCd);
                }).map(function(e){
                  return '<tr style="background:#fffaf3">'
                    +'<td></td>'
                    +'<td style="text-align:right;padding-right:14px;color:#b06a00;font-weight:700;white-space:nowrap" title="대체출고 — 재고는 대표코드로 빠지고 실제로는 이 매칭코드로 나갔습니다.">↳ '+_cesc(e.cd)+'</td>'
                    +'<td></td>'
                    +'<td style="text-align:right;color:#b06a00;font-weight:700">'+_cnum(e.qty)+'</td>'
                    +'<td></td><td></td><td></td>'
                    +'<td>'+(e.biz ? _bizCell(e.biz) : '')+'</td>'
                    +'<td></td><td></td><td></td><td></td><td></td></tr>';
                }).join('');
          }).join('')
          /* 기간을 좁혀 비었을 때와, 원장 자체가 없을 때를 구분해 안내한다 —
             똑같이 '없습니다' 라고만 하면 기간 탓인 줄 모르고 자료가 없다고 오해한다. */
          : (_stkLedRaw.length
              ? '<tr><td colspan="13" style="text-align:center;color:#9aa7b3;padding:20px">최근 <b>'+_stkLedMon+'개월</b> 안에는 수불 내역이 없습니다. (전체 <b>'+_stkLedRaw.length+'</b>건 — 위 기간 버튼을 넓혀 보세요)</td></tr>'
              : '<tr><td colspan="13" style="text-align:center;color:#9aa7b3;padding:20px">수불 내역이 없습니다. (이 품목은 입고/출고 원장 기록이 없음)</td></tr>');
        hd.innerHTML=head;
        bd.innerHTML='<table class="logi-tb">'+thead+'<tbody>'+body+'</tbody></table>';
        _stkLedFit();   // 남은 화면 높이만큼 표를 늘린다(아래 여백 방지)
    }
  }
  /* ①품목별 현재고 — 10행씩 + 자동 스크롤(2026-07-25 요청).
       아래에 ②수불 내역 패널이 붙어 있어 이 표는 10행이면 한 화면에 둘 다 들어온다.
       페이지 버튼(1 2 3 … 20)은 없앴다 — 스크롤이 바닥에 닿으면 다음 10행이 저절로 붙는다(lzMount). */
  /* ── 우리 코드 → 거래처 코드들 (재고현황 '거래처코드' 칸) ─────────────────────────
       재고는 우리 코드 하나로 합산된다. 그러면 "이 수량이 어느 거래처 코드로 들어온 건지" 를 볼 수 없어
       두 표를 우리 코드 기준으로 모아 둔다(2026-08-01 요청).
         · 매칭코드 = 상품코드등록 화면에서 붙인 것 (TBL_EXT_ITEM_MST)
         · 연결     = 업로드 미리보기·품목코드(매핑)에서 이은 것 (TBL_PROD_XREF)
       ★코드 직결(거래처 코드 = 우리 코드)은 여기 안 나온다 — 별칭이 아니라 같은 코드라 보여 줄 것이 없다. */
  var _stkAlias=null;      // { 우리코드 : [{cd, nm, via:'매칭'|'연결'}] }
  /* ★역방향 (2026-08-02 요청) — { 거래처코드 : [{cd:주코드, nm:주코드 품목명, via}] }
       매칭·연결 전에 들어온 출고는 거래처 코드 그대로 재고가 잡혀 있어서, 그 행의 '품목코드'가
       사실은 매칭코드다(예: 1000800225 · 현재고 -18). 그때 "이건 어느 주코드에 붙는 코드인지"를
       같은 칸에 보여 주지 않으면, 조회한 사람이 상품코드등록 화면까지 가서 찾아봐야 한다. */
  var _stkAliasRev=null;
  function stkAliasLoad(cb){
    var ctx='${pageContext.request.contextPath}', m={}, rv={}, left=2;
    function put(prodCd, prodNm, cd, nm, via){
      var k=String(prodCd||'').trim(), c=String(cd||'').trim(); if(!k||!c) return;
      (m[k]=m[k]||[]).push({cd:c, nm:nm||'', via:via});
      (rv[c]=rv[c]||[]).push({cd:k, nm:prodNm||'', via:via});
    }
    function done(){ if(--left===0){ _stkAlias=m; _stkAliasRev=rv; if(cb) cb(); } }
    fetch(ctx+'/prod/extItemList.do', { method:'POST', credentials:'same-origin',
             headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
      .then(function(r){ return r.json(); })
      .then(function(j){ ((j&&j.data)||[]).forEach(function(o){ put(o.prodCd, o.prodNm, o.extItemCd, o.extItemNm, '매칭'); }); done(); })
      .catch(function(){ done(); });
    fetch(ctx+'/prod/xrefList.do', { method:'POST', credentials:'same-origin',
             headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
      .then(function(r){ return r.json(); })
      .then(function(j){ ((j&&j.data)||[]).forEach(function(o){ put(o.prodCd, o.prodNm, o.extItemCd, o.extItemNm, '연결'); }); done(); })
      .catch(function(){ done(); });
  }
  /* 주코드를 눌러 그 코드로 바로 다시 조회 — 행 클릭(②수불내역)과 겹치므로 stopPropagation 필수 */
  /* 검색어 유무에 따라 지우개를 켜고 끈다 (2026-08-07) */
  function stkSrchTog(){
    var i=document.getElementById('stkSrch'), b=document.getElementById('stkSrchClr');
    if(i&&b) b.style.display = (i.value||'').trim() ? '' : 'none';
  }
  function stkSrchClear(){
    var i=document.getElementById('stkSrch'); if(i) i.value='';
    stkSrchTog(); stkStatusLoad();
  }
  function stkSrchGo(cd, e){
    if(e){ e.stopPropagation(); }
    var el=document.getElementById('stkSrch'); if(el) el.value=cd||'';
    stkSrchTog();
    stkStatusLoad();
  }
  /* ── 키보드로 목록 넘기기 (2026-08-06 요청) ─────────────────────────
       마우스 휠로만 움직이던 두 표를 키보드로도 다룰 수 있게 한다.
       · ①재고현황 : ↑↓ = 한 줄씩 **선택** 이동(아래 ②수불내역도 따라 바뀐다)
                     PageUp/PageDown/Home/End = 화면 단위 스크롤
       · ②수불내역 : 방향키·Page·Home/End 모두 브라우저 기본 스크롤
       ★div 는 tabindex 가 없으면 키를 못 받는다 — 위 마크업에 tabindex=0 을 넣은 이유.
       ★행을 눌렀을 때 그 표에 초점을 줘야 곧바로 방향키가 먹는다(안 그러면 한 번 더 눌러야 한다). */
  function _stkKeyBind(){
    var w=document.getElementById('stkStatusWrap');
    if(!w || w._keyBound) return;
    w._keyBound=true;

    /* 행을 누르면 그 표에 초점 — 클릭 직후 바로 ↑↓ 로 이어 갈 수 있게 */
    w.addEventListener('click', function(){ try{ w.focus({preventScroll:true}); }catch(e){ w.focus(); } });

    w.addEventListener('keydown', function(e){
      var k=e.key;
      if(k!=='ArrowDown' && k!=='ArrowUp' && k!=='Enter') return;   // Page/Home/End 는 브라우저에 맡긴다
      var rows=w.querySelectorAll('tbody tr[onclick]');
      if(!rows.length) return;
      var cur=-1;
      for(var i=0;i<rows.length;i++){ if(rows[i].classList.contains('stk-on')){ cur=i; break; } }
      if(k==='Enter'){ if(cur>=0) rows[cur].click(); return; }
      e.preventDefault();                       // 표 안에서 움직일 때 페이지가 같이 스크롤되지 않게
      var next = (cur<0) ? 0 : cur + (k==='ArrowDown' ? 1 : -1);
      if(next<0) next=0;
      if(next>rows.length-1){
        /* 마지막 줄에서 더 내리면 — 아직 안 그린 다음 묶음이 있으면 스크롤을 바닥으로 밀어
           lzMount 가 이어 그리게 하고, 이번 키는 흘려보낸다(다음 키부터 새 줄로 간다). */
        w.scrollTop = w.scrollHeight;
        next = rows.length-1;
      }
      var tr=rows[next]; if(!tr) return;
      tr.click();                                // 선택 표시 + ②수불내역 갱신은 기존 경로 그대로
      if(tr.scrollIntoView) tr.scrollIntoView({block:'nearest'});
    });

    /* ②수불내역도 키보드로 — 여기는 선택 개념이 없어 브라우저 기본 스크롤이면 충분하다.
       클릭하면 초점만 준다. */
    var b=document.getElementById('stkLedgerBody');
    if(b && !b._keyBound){ b._keyBound=true;
      b.addEventListener('click', function(){ try{ b.focus({preventScroll:true}); }catch(e){ b.focus(); } });
    }
  }
  /* 이 품목에 매칭코드가 붙어 있나 (2026-08-06 요청 — 상단 [매칭코드 있는 것만] 체크용).
       두 방향을 다 본다 : 이 코드에 매칭코드가 달린 경우(정방향) + 이 코드 자체가
       남의 매칭코드인 경우(역방향, 화면에 '주코드 …' 로 뜨는 행). 화면에서 매칭코드 칸이
       '-' 가 아닌 행 = 여기서 true 인 행이라, 눈에 보이는 것과 결과가 어긋나지 않는다. */
  function _stkHasAlias(prodCd){
    var k=String(prodCd||'').trim();
    if(_stkAlias && (_stkAlias[k]||[]).length) return true;
    if(_stkAliasRev && (_stkAliasRev[k]||[]).length) return true;
    return false;
  }
  /* ── 입·출고 나눠보기 (2026-08-07 요청) ──────────────────────────────
       ② 수불내역과 **같은 자료·같은 기간**을 쓰되 방향으로만 갈라 그린다.
       ★서버를 다시 부르지 않는다 — _stkLedRaw 를 그대로 쓴다(즉시 열림).
       ★'기타(반품·조정)' 칸을 따로 두는 이유 : 원장에는 I·O 말고 R(반품)·A(조정)도 올 수 있다.
         입고·출고 둘로만 나누면 그런 줄이 **조용히 사라져** 합이 안 맞는다. 있을 때만 보여 준다. */
  /* 팝업에서 고른 매칭코드 — 빈 문자열이면 그 품목 전체(2026-08-07 요청) */
  var _splitExt = '';
  function stkSplitExt(cd){ _splitExt = (_splitExt===cd) ? '' : cd; stkSplitOpen(); }   // 같은 줄을 다시 누르면 해제
  function stkSplitExtClear(){ _splitExt=''; stkSplitOpen(); }
  function stkSplitOpen(){
    /* 메시지는 앱 공통 스타일(빨간 아이콘 + 빨간 확인버튼)로 — 2026-08-07 지정.
       순서 안내라 'warning' 이 맞고, 버튼 색은 swAlert 가 공통 스타일로 맞춰 준다. */
    if(!_stkLedRow || !_stkLedRaw.length){ swAlert('위 ① <b>품목별 현재고</b> 표에서 품목을 먼저 고르세요.','error'); return; }
    var cut=_stkLedCut();
    var rows = cut ? _stkLedRaw.filter(function(l){ return String(l.trxDt||'').replace(/-/g,'') >= cut; }) : _stkLedRaw;
    /* 요약표의 ↳ 매칭코드 줄을 누르면 그 코드가 섞인 날짜만 남긴다(2026-08-07 요청).
       입고는 언제나 대표코드라 매칭을 고르면 입고내역은 자연히 비게 된다 — 맞는 동작이다. */
    /* ★위 [선택 품목] 요약표는 '거르기 전' 값으로 둔다 (2026-08-07 지적).
         종전에는 코드를 고르면 요약표의 하위 줄까지 그 코드 하나만 남아,
         다른 코드로 갈아타려면 매번 '전체보기' 로 되돌아가야 했다.
       요약표 = 이 품목의 전체 그림이자 코드를 갈아 끼우는 스위치,
       아래 입고·출고 내역 = 고른 코드분. 이렇게 역할을 갈라 둔다. */
    var rowsAll=rows;
    if(_splitExt){
      /* 그 코드분만 남긴 사본으로 갈아 끼운다 — 수량·사업장·하위 행이 모두 그 코드 기준이 된다.
         입고는 대표코드로만 들어오므로 자연히 0건이 된다(맞는 결과). */
      rows = rows.map(function(l){ return (l.ioGb==='O') ? _extPick(l, _splitExt) : null; }).filter(Boolean);
    }
    var inA=[], outA=[];
    rowsAll.forEach(function(l){ if(l.ioGb==='O') outA.push(l); else if(l.ioGb==='I') inA.push(l); });
    var inR=[], outR=[], etcR=[];
    rows.forEach(function(l){ if(l.ioGb==='O') outR.push(l); else if(l.ioGb==='I') inR.push(l); else etcR.push(l); });

    var r=_stkLedRow;
    document.getElementById('stkSplitTit').innerHTML =
      '<b>'+_cesc(r.prodCd||'')+'</b> <span style="color:#37475a">'+_cesc(r.prodNm||'')+'</span>'
      + ' <span style="color:#9aa7b3;font-size:12.5px">('+(_stkLedMon?('최근 '+_stkLedMon+'개월'):'전체 기간')+')</span>'
      /* 매칭코드로 걸러 보는 중이면 그 사실과 푸는 길을 함께 보여 준다 */
      + (_splitExt ? ' <span style="color:#b06a00;font-weight:800;font-size:12.5px"'
                   + ' title="매칭코드는 출고에만 붙습니다(입고는 대표코드로 들어옴). 그래서 입고는 0건이 되고, 출고 수량도 이 코드 몫만 나옵니다.">'
                   + '· 매칭코드 '+_cesc(_splitExt)+' 출고만 &nbsp;<span style="color:#137a6c">'
                   + _cnum(outR.reduce(function(a,l){ return a+(+l.qty||0); },0))+'</span></span>'
                   + ' <a href="javascript:void(0)" onclick="stkSplitExtClear()" style="font-size:12px;color:#137a6c;font-weight:800;text-decoration:none" title="이 품목 전체로 되돌립니다">✕ 전체보기</a>' : '');
    var sum=function(a){ var q=0,m=0; a.forEach(function(l){ q+=(+l.qty||0); m+=(+l.amt||0); }); return {q:q,m:m}; };
    /* 오른쪽 위 요약도 '거르기 전' 값이다 — 아래 요약표와 같은 뜻이어야 한다.
       코드를 골랐을 때 여기만 걸러진 값이면 입고 0 · 차 -55 처럼 읽혀 장부가 깨진 듯 보인다.
       고른 코드분은 아래 '출고내역' 머리에 따로 적힌다(2026-08-07). */
    var si=sum(inA), so=sum(outA);
    document.getElementById('stkSplitSum').innerHTML =
        '입고 <b style="color:#137a6c">'+_cnum(si.q)+'</b>'
      + ' · 출고 <b style="color:#b06a00">'+_cnum(so.q)+'</b>'
      + ' · 차 <b style="color:'+((si.q-so.q)<0?'#c0392b':'#137a6c')+'">'+_cnum(si.q-so.q)+'</b>'
      + ' <span style="color:#9aa7b3">|</span> 현재고 <b>'+_cnum(r.curQty)+'</b>';

    /* 상단도 그리드로 (2026-08-07 확정) — 그리드 3개 : 선택품목 / 입고 / 출고 */
    document.getElementById('stkSplitBody').innerHTML =
        _stkSplitTop(r, si, so)
      /* ★표별 높이를 따로 준다 (2026-08-07 요청) — 입고는 보통 몇 줄이고
         출고는 수십~수백 줄이라, 둘을 같은 높이로 두면 출고만 답답해진다. */
      /* ★입고는 대개 몇 줄이라 '줄 수만큼'만 차지하게 하고(최대 18vh),
         남는 자리를 출고에 몰아준다(2026-08-07 '출고 좀 더 많이'). */
      + _stkSplitTb('⬇️ 입고내역', inR,  '#137a6c', true,  '18vh')
      /* 한 줄 ≈ 31px — 두 줄만큼 줄인다(2026-08-07 요청). 다시 늘리려면 62px 를 빼면 된다. */
      + _stkSplitTb('⬆️ 출고내역', outR, '#b06a00', false, 'calc(58vh - 62px)')
      + (etcR.length ? _stkSplitTb('◇ 기타(반품·조정)', etcR, '#5a6b7a', true, '16vh') : '');
    document.getElementById('stkSplitPop').classList.add('on');
  }
  function stkSplitClose(){ document.getElementById('stkSplitPop').classList.remove('on'); }

  /* 상단 — 고른 품목 한 줄을 ①재고현황과 같은 칸으로 보여 준다.
     ★입고·출고 칸은 '이 창에서 보고 있는 기간' 합계다(아래 두 표의 합과 같다).
       현재고·이동평균단가·재고금액은 기간과 무관한 전체 기준이라 칸 바탕을 달리 둔다 —
       섞여 있으면 "기간을 줄였는데 현재고가 왜 그대로지?" 가 된다. */
  function _stkSplitTop(r, si, so){
    var neg=(+r.curQty||0)<0;
    return '<div style="display:flex;align-items:baseline;gap:10px;margin:2px 0 5px">'
         +   '<b style="font-size:16.5px;color:#1f2a37">◆ 선택 품목</b>'
         +   '<span style="color:#9aa7b3;font-size:12.5px">입고·출고 = 이 창에서 보는 기간 합계 · 현재고부터는 전체 기준</span></div>'
         + '<div style="border:1px solid var(--logi-border);border-radius:8px;overflow:auto">'
         + '<table class="logi-tb sp-top"><thead><tr>'
         /* 매칭코드 열을 없애고 품목코드 밑에 붙인다 (2026-08-07 요청) —
            ①표·②수불 내역과 같은 모양으로 통일. 세 표가 제각각이면 같은 값인데도 다르게 읽힌다. */
         +   '<th>품목코드</th><th>품목명</th>'
         +   '<th style="text-align:right">입고</th><th style="text-align:right">출고</th>'
         +   '<th style="text-align:right">현재고</th><th style="text-align:right">이동평균단가</th>'
         +   '<th style="text-align:right">재고금액</th>'
         + '</tr></thead><tbody><tr>'
         +   '<td>'+_cesc(r.prodCd||'')+'</td><td class="txt-l">'+_cesc(r.prodNm||'')+'</td>'
         +   '<td style="text-align:right;color:#137a6c;font-weight:700">'+_cnum(si.q)+'</td>'
         +   '<td style="text-align:right;color:#b06a00;font-weight:700">'+_cnum(so.q)+'</td>'
         +   '<td style="text-align:right;font-weight:800;background:#f7fafc;color:'+(neg?'#c0392b':'#137a6c')+'">'+_cnum(r.curQty)+'</td>'
         +   '<td style="text-align:right;background:#f7fafc">'+_cnum(r.avgInPrice)+'</td>'
         +   '<td style="text-align:right;background:#f7fafc">'+_cnum(r.stockAmt)+'</td>'
         + '</tr>'
         /* 매칭코드 하위 행 — 7열, 품목코드=0번 칸, 출고=3번 칸.
            ★코드를 골라도 줄은 다 남긴다 — 고른 줄에만 표시를 넣는다(2026-08-07 지적).
              줄이 하나만 남으면 다른 코드로 갈아타는 길이 막혀 '전체보기' 를 거쳐야 했다.
              위 출고 칸도 거르기 전 값이라 하위 합과 그대로 맞는다. */
         + stkAliasRows(r.prodCd, r.extQtys, 7, 0, 3,
                        function(cd){ return "stkSplitExt('"+cd+"')"; }, _splitExt)
         + '</tbody></table></div>';
  }

  /* 한 방향짜리 표 하나. 입고는 매입처·단가가 뜻이 있고, 출고는 사업장이 뜻이 있어
     칸 구성을 조금 다르게 둔다(빈 칸을 늘어놓으면 읽기만 나빠진다). */
  function _stkSplitTb(title, rows, color, isIn, maxH){
    var q=0,m=0; rows.forEach(function(l){ q+=(+l.qty||0); m+=(+l.amt||0); });
    /* 글자 확대 (2026-08-07 요청) — 이 줄이 각 표의 '결론'이라
       본문보다 크게 두어야 훑을 때 눈에 먼저 들어온다. */
    var head = '<div style="display:flex;align-items:baseline;gap:10px;margin:12px 0 6px">'
             +   '<b style="font-size:16.5px;color:'+color+'">'+title+'</b>'
             +   '<span style="color:#37475a;font-size:14px;font-weight:600">수량 <b>'+_cnum(q)+'</b>'
             +   ' · 금액 <b>'+_cnum(m)+'</b>'
             +   ' · <b>'+rows.length+'</b>건</span></div>';
    if(!rows.length) return head + '<div style="padding:14px;text-align:center;color:#9aa7b3;border:1px solid var(--logi-border);border-radius:8px">내역이 없습니다.</div>';
    /* 품목코드·품목명 추가 (2026-08-07 요청) — 한 품목짜리 창이라 값은 다 같지만,
         표를 긁거나 내려받았을 때 무슨 품목인지 알 수 있어야 한다.
       ★원장에 품목명이 비어 있는 줄이 있어(서버가 prodNm 을 안 채운다)
         고른 품목의 이름(_stkLedRow.prodNm)을 대신 쓴다. */
    /* 맨 앞 순번 (2026-08-07 요청) — "몇 번째 줄까지 봤는지" 를 잡기 위해.
       저장 자료가 아니라 보이는 순서만 매긴다(기간을 바꾸면 다시 1부터). */
    var th = isIn
      ? '<thead><tr><th style="width:44px">No</th><th>일자</th><th>품목코드</th><th>품목명</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>매입처</th><th>근거구분</th><th>근거번호</th><th>비고</th></tr></thead>'
      : '<thead><tr><th style="width:44px">No</th><th>일자</th><th>품목코드</th><th>품목명</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>사업장</th><th>근거구분</th><th>근거번호</th><th>비고</th></tr></thead>';
    /* 매칭코드를 골라 보는 중이면 품명도 그 코드의 거래처 품명으로 — 코드는 매칭인데
       품명만 대표 것이면 짝이 안 맞는다(2026-08-07). 등록된 품명이 없으면 대표 품명 그대로. */
    var _nm = (_splitExt && _stkLedRow ? _extNmOf(_stkLedRow.prodCd, _splitExt) : '')
              || (_stkLedRow && _stkLedRow.prodNm) || '';
    /* 대체출고 하위 행 — 수불 내역과 같은 규격(2026-08-07 요청).
       이 표는 열이 11개라 앞 4칸(No·일자·품목코드·품목명) 뒤에 수량, 그 다음이 사업장이다. */
    var _sub = function(l){
      /* 안 갈린 날은 하위 줄을 안 그린다 — 위 ②수불 내역과 같은 규칙(2026-08-07).
         코드를 골라 보는 중이면 목록 전체가 그 코드분이라 ↳ 줄은 전부 되풀이다. */
      return (_splitExt ? [] : _extParse(l.extCds)).filter(function(e, i, a){
        return !(a.length===1 && e.cd===l.prodCd);
      }).map(function(e){
        return '<tr style="background:#fffaf3">'
          +'<td></td><td></td>'
          +'<td style="text-align:right;padding-right:14px;color:#b06a00;font-weight:700;white-space:nowrap" title="대체출고 — 재고는 대표코드로 빠지고 실제로는 이 매칭코드로 나갔습니다.">↳ '+_cesc(e.cd)+'</td>'
          /* 품명 — 그 매칭코드의 거래처 품명(2026-08-07 요청). 비어 있으면 그냥 빈 칸으로 둔다. */
          +'<td class="txt-l" style="color:#8a5200" title="거래처 품명">'+_cesc(_extNmOf(l.prodCd, e.cd))+'</td>'
          +'<td style="text-align:right;color:#b06a00;font-weight:700">'+_cnum(e.qty)+'</td>'
          +'<td></td><td></td>'
          +'<td>'+(e.biz ? _bizCell(e.biz) : '')+'</td>'
          +'<td></td><td></td><td></td></tr>';
      }).join('');
    };
    var body = rows.map(function(l, _i){
      var no='<td style="text-align:center;color:#8a97a4;font-weight:700;background:#fbfcfd">'+(_i+1)+'</td>';
      return isIn
        ? '<tr>'+no+'<td>'+_fmtYmd(l.trxDt)+'</td>'
          +'<td>'+_cesc(l.prodCd||'')+'</td>'
          +'<td class="txt-l">'+_cesc(l.prodNm||_nm)+'</td>'
          +'<td style="text-align:right;font-weight:700;color:#137a6c">'+_cnum(l.qty)+'</td>'
          +'<td style="text-align:right">'+_cnum(l.unitPrice)+'</td><td style="text-align:right">'+_cnum(l.amt)+'</td>'
          +'<td title="'+_cesc(l.vendorNm||'')+'">'+_cesc(l.vendorCd||'')+(l.vendorNm?(' <span style="color:#5a6b7a">'+_cesc(l.vendorNm)+'</span>'):'')+'</td>'
          +'<td>'+_cesc(l.refGb||'')+'</td><td>'+_cesc(l.refNo||'')+'</td><td>'+_cesc(l.remark||'')+'</td></tr>'+_sub(l)
        : '<tr>'+no+'<td>'+_fmtYmd(l.trxDt)+'</td>'
          +'<td>'+_cesc(l.prodCd||'')+'</td>'
          +'<td class="txt-l">'+_cesc(l.prodNm||_nm)+'</td>'
          +'<td style="text-align:right;font-weight:700;color:#b06a00">'+_cnum(l.qty)+'</td>'
          /* ★출고의 단가·금액은 대부분 0 이다 (2026-08-07 요청으로 칸을 넣음) —
             출고(SHIPOUT) 자동연동 줄은 수량만 남기고 금액은 정산서·판매전표 쪽에서 잡히기 때문.
             0 을 그대로 보이면 '빠졌나?' 가 되므로 흐리게 둔다. */
          +'<td style="text-align:right'+((+l.unitPrice||0)?'':';color:#c8ced4')+'">'+_cnum(l.unitPrice)+'</td>'
          +'<td style="text-align:right'+((+l.amt||0)?'':';color:#c8ced4')+'">'+_cnum(l.amt)+'</td>'
          +'<td>'+(l.bizCd ? _bizCell(l.bizCd) : (l.vendorNm ? '<span style="color:#5a6b7a">'+_cesc(l.vendorNm)+'</span>' : ''))+'</td>'
          +'<td>'+_cesc(l.refGb||'')+'</td><td>'+_cesc(l.refNo||'')+'</td><td>'+_cesc(l.remark||'')+'</td></tr>'+_sub(l);
    }).join('');
    /* 표가 길어도 창이 무한정 늘어나지 않게 각 표에 높이 상한을 둔다 */
    return head + '<div style="max-height:'+(maxH||'34vh')+';overflow:auto;border:1px solid var(--logi-border);border-radius:8px">'
                + '<table class="logi-tb '+(isIn?'sp-in':'sp-out')+'">'+th+'<tbody>'+body+'</tbody></table></div>';
  }
  /* ①표 품목코드 칸 아래에 붙일 매칭코드 — 한 줄에 하나씩 (2026-08-07 요청).
       종전에는 '매칭코드' 열을 따로 뒀는데, ②수불 내역이 이미 품목코드 밑에 ↳ 로
       보여주고 있어 두 표의 모양이 달랐다. 열을 없애고 아래 규칙으로 통일한다.
     · 이 행에 붙은 매칭코드가 있으면  ↳ 코드
     · 반대로 이 행의 코드가 남의 매칭코드이면  🔖 주코드 xxxx
     · 아무것도 없으면 빈 값 — '없음' 을 줄마다 찍으면 표가 시끄럽다.
     자세한 내용(거래처 품명·출처)은 종전처럼 hover 툴팁에 담는다. */
  /* 매칭코드를 '하위 행' 으로 편다 — ②수불 내역과 같은 모양(2026-08-07 요청).
       칸 안에 (수량) 을 괄호로 붙이면 대표 줄의 숫자와 세로로 안 맞아 견주기 어렵다.
       행을 따로 세우면 출고 칸이 정확히 대표 줄 출고 아래에 선다.
     · nCol = 그 표의 전체 열 수, iCd/iOut = 품목코드·출고 칸의 자리(0부터).
       ①표(9열: 코드·품명·입고·출고·현재고·단가·금액·최근입고·최근출고)와
       팝업 요약표(7열: 코드·품명·입고·출고·현재고·단가·금액)가 자리가 달라 인자로 받는다.
     · ★입고 칸은 비워 둔다 — 매입은 언제나 '대표코드로' 들어오기 때문이다(2026-08-07 확인).
       매칭코드는 거래처가 주문서에 쓰는 코드라 출고에만 나타난다. 그래서 하위 행에는
       출고수량만 붙고 입고·현재고·단가·금액은 대표 줄의 합산 하나만 있는 게 맞다.
       출고수량은 서버가 '코드:수량|코드:수량' 으로 준다. */
  /* selCd = 지금 골라 놓은 매칭코드(없으면 빈 값). 그 줄만 배경·왼쪽 띠로 표시한다.
     ①표는 _stkLedExt, 팝업은 _splitExt 를 넘긴다 — 어느 줄을 보고 있는지 표에서 바로 알게. */
  /* withSrch : ↳ 코드 옆에 돋보기를 붙일지 (2026-08-07 요청).
       ①표에서만 켜다 — [입·출고 나누어보기] 창은 이미 한 품목만 보는 자리라 검색할 일이 없다. */
  function stkAliasRows(prodCd, extQtys, nCol, iCd, iOut, mkClick, selCd, withSrch){
    /* 돋보기 한 개 — 줄 클릭(②를 그 코드로 거르기)과 섞이지 않게
       stopPropagation 은 stkSrchGo 안에서 한다. 간격을 넓게 두어 잘못 누르는 일을 줄인다. */
    var _sIcon=function(cd){
      if(!withSrch) return '';
      var a=String(cd).replace(/'/g,'');
      return ' <a href="javascript:void(0)" onclick="stkSrchGo(\''+a+'\', event)"'
           + ' title="이 코드로 ① 목록을 다시 조회합니다"'
           + ' style="margin-left:10px;padding:0 4px;color:#137a6c;text-decoration:none;font-size:12.5px">🔍</a>';
    };
    if(!_stkAlias) return '';
    var key=String(prodCd||'').trim();
    var qm={};
    String(extQtys||'').split('|').forEach(function(s){
      var t=s.split(':'); if(t.length===2 && t[0]) qm[t[0]]=t[1];
    });
    /* ★두 줄은 뜻이 반대라 배경까지 갈라 둔다 (2026-08-07 요청)
         ↳ 매칭코드  = 이 품목(대표)에 딸린 거래처 코드      → 주황 계열
         🔖 주코드   = 반대로 이 품목이 남의 매칭코드일 때   → 파랑 계열
       색이 같으면 "내 아래 딸린 것" 과 "나를 거느린 것" 이 뒤집혀 읽힌다. */
    /* 하위 행도 '눌러서 고를 수 있게' 한다 (2026-08-07 요청) —
         매칭코드 줄을 누르면 아래 ②수불 내역이 그 코드분만 걸러서 나온다.
         품목(prodSeq)은 대표와 같고, extCd 만 넘겨 화면에서 거른다.
       ※ 경계선은 넣었다가 도로 뺐다(같은 날) — 배경색만으로도 묶음이 읽힌다. */
    var mk=function(cells, bg, onclick, on){
      /* 고른 줄은 ②수불 내역의 선택행(.stk-on)과 같은 초록으로 맞춘다 —
         위아래가 다른 색이면 같은 걸 골랐는데도 딴 줄처럼 보인다(2026-08-07). */
      var h='<tr style="background:'+(on?'#cfeae3':(bg||'#fffaf3'))+(onclick?';cursor:pointer':'')+'"'
          + (onclick?(' onclick="'+onclick+'" title="'+(on?'다시 누르면 전체로 되돌립니다':'이 매칭코드로 나간 내역만 아래에 봅니다')+'"'):'')+'>';
      for(var i=0;i<nCol;i++){
        var c=(cells[i]!=null ? cells[i] : '<td></td>');
        /* 첫 칸에 왼쪽 띠 — 어느 줄이 골라져 있는지 한눈에.
           이미 style 이 있으면 그 앞에 끼워 넣고, 없으면 새로 단다(속성이 두 번 붙으면 뒤엣것이 죽는다). */
        if(on && i===0){
          c = /<td[^>]*\sstyle="/.test(c)
                ? c.replace(/(<td[^>]*\sstyle=")/, '$1box-shadow:inset 4px 0 0 #137a6c;')
                : c.replace(/^<td/, '<td style="box-shadow:inset 4px 0 0 #137a6c"');
        }
        h += c;
      }
      return h+'</tr>';
    };
    /* ★하위 행은 '등록된 매칭코드' 가 아니라 '실제로 출고된 코드' 로 그린다 (2026-08-07 수정)
         종전에는 _stkAlias(등록표)만 돌아서, 대표코드 자신으로 나간 분이 빠졌다.
         실측 1000778869 : 출고 172 = 매칭 1000772461(161) + 대표 1000778869(11)
         인데 161 만 보여 11 이 사라진 것처럼 됐다(사용자 지적).
       → 서버가 준 출고분(qm)을 기준으로 돌면 하위 합이 언제나 대표 줄 출고와 맞는다.
         등록만 되고 아직 출고가 없는 매칭코드는 뒤에 수량 없이 덧붙인다. */
    var nmOf={}; (_stkAlias[key]||[]).forEach(function(o){ nmOf[o.cd]=o.nm||''; });
    var ship=Object.keys(qm).sort(function(a,b){ return (+qm[b]||0)-(+qm[a]||0); });
    var restAlias=(_stkAlias[key]||[]).filter(function(o){ return qm[o.cd]==null; });
    /* ★하위 행은 '출고가 실제로 갈렸을 때' 만 편다 (2026-08-07 요청)
         하위 행의 존재 이유는 "대표코드 출고가 어떤 코드로 나갔는지" 를 쪼개 보여주는 것뿐이다.
         · 출고가 없는 줄(입고만 있는 품목) — 입고는 언제나 대표코드로 들어오므로 쪼갤 게 없다.
           그런데도 🔖 주코드 줄이 떠서 "입고인데 매칭이 보인다" 가 됐다(사용자 지적).
         · 출고가 대표코드 하나뿐인 줄 — '↳ 1000455368 (대표) 14' 처럼 바로 위 줄과
           같은 코드·같은 수량을 되풀이할 뿐이라 군더더기다.
       두 경우 모두 아무것도 그리지 않는다. */
    var split = ship.length > 1 || (ship.length === 1 && ship[0] !== key);
    if(!split) return '';
    if(ship.length || restAlias.length){
      var rows=[];
      var out=ship.map(function(cd){
        var self=(cd===key);       // 대표코드 자신으로 나간 분
        var nm=self?'':(nmOf[cd]||'');
        var tip=(self ? '대표코드로 바로 나간 출고입니다(매칭코드 없이 주문된 건).'
                      : (cd+(nm?(' · '+nm):'')+'\n이 코드로 나간 출고 '+qm[cd])).replace(/"/g,'&quot;').replace(/\n/g,'&#10;');
        var c={};
        c[iCd]='<td style="text-align:right;padding-right:14px; color:'+(self?'#5a6b7a':'#b06a00')+';font-weight:700;white-space:nowrap" title="'+tip+'">'
             + '↳ '+_cesc(cd)+_sIcon(cd)+'</td>';
        /* '(대표)' 는 코드 뒤가 아니라 품명 칸 앞에 붙인다 (2026-08-07 요청) —
           코드 옆에 두면 그 줄만 길어져 다른 매칭코드 줄과 세로로 안 맞는다.
           코드는 코드끼리 같은 자리에 서야 견주기 쉽다. */
        c[iCd+1]='<td class="txt-l" style="color:#8a5200" title="'+(self?'대표코드로 바로 나간 출고':'거래처 품명')+'">'
               + (self?'<span style="color:#5a6b7a;font-weight:700">(대표코드 직접출고)</span>':_cesc(nm))+'</td>';
        c[iOut]='<td style="text-align:right;color:'+(self?'#5a6b7a':'#b06a00')+';font-weight:700">'+_cnum(qm[cd])+'</td>';
        return { c:c, bg:(self?"#f6f8fa":"#fff6ea"), cd:cd };
      });
      // 등록은 됐는데 아직 그 코드로 나간 적이 없는 매칭코드
      out=out.concat(restAlias.map(function(o){
        var tip=(o.cd+(o.nm?(' · '+o.nm):'')+' ('+o.via+')\n아직 이 코드로 나간 출고가 없습니다.').replace(/"/g,'&quot;').replace(/\n/g,'&#10;');
        var c={};
        c[iCd]='<td style="text-align:right;padding-right:14px; color:#b06a00;font-weight:700;white-space:nowrap;opacity:.65" title="'+tip+'">↳ '+_cesc(o.cd)+_sIcon(o.cd)+'</td>';
        if(o.nm) c[iCd+1]='<td class="txt-l" style="color:#8a5200;opacity:.65" title="거래처 품명">'+_cesc(o.nm)+'</td>';
        return { c:c, bg:'#fff6ea', cd:o.cd };
      }));
      return out.map(function(o){
        /* onclick 은 부르는 쪽이 정한다 — ①표는 안 걸고(접기/펼치기로 정리),
           [입·출고 나누어보기] 팝업은 그 코드만 보도록 건다(2026-08-07 요청). */
        return mk(o.c, o.bg, mkClick ? mkClick(o.cd) : null, !!selCd && o.cd===selCd);
      }).join('');
    }
    var rl=(_stkAliasRev&&_stkAliasRev[key])||[];
    if(rl.length){
      return rl.map(function(o){
        var tip=('이 코드는 '+o.cd+(o.nm?(' · '+o.nm):'')+' 의 매칭코드로 등록되어 있습니다.').replace(/"/g,'&quot;');
        var c={};
        c[iCd]='<td style="text-align:right;padding-right:14px; color:#274b8f;font-weight:800;white-space:nowrap" title="'+tip+'">🔖 주코드 '+_cesc(o.cd)+'</td>';
        if(o.nm) c[iCd+1]='<td class="txt-l" style="color:#274b8f">'+_cesc(o.nm)+'</td>';
        return { c:c, bg:'#eef3fb' };
      }).map(function(o){ return mk(o.c, o.bg, null); }).join('');
    }
    return '';
  }
  function stkAliasCell(prodCd){
    var BSQ="\\'";   // onclick 안 따옴표 이스케이프용(역슬래시+홈따옴표)
    if(!_stkAlias) return '<span style="color:#8a97a4">…</span>';   // 아직 매칭표를 못 읽음
    var key=String(prodCd||'').trim();
    var l=_stkAlias[key]||[];
    if(l.length){
      // 두 개까지만 칸에 쓰고 나머지는 +N — 툴팁에는 전부(코드 · 거래처 품명 · 출처)
      var tip=l.map(function(o){ return o.cd+(o.nm?(' · '+o.nm):'')+' ('+o.via+')'; }).join('&#10;');
      /* 매칭코드마다 돋보기를 붙인다 — 그 코드로 목록을 다시 조회한다(2026-08-06 요청).
           ★코드 글자 자체는 링크가 아니다 — 칸이 넓어 행을 고르려다 눈릀 검색되는 일을 막기 위해,
             주코드 칸과 같은 규칙으로 '돋보기만' 누르게 했다. */
      /* ★돋보기(이 코드로 재조회)를 뻐다 (2026-08-07, 두 번째 지적) —
           글자 바로 옆이라 행을 고르려고 누를 때 번번이 걸려,
           검색어 칸에 코드가 박히고 목록이 한 줄로 줄어들었다.
           코드로 찾을 때는 왼쪽 [검색어] 칸에 직접 넣으면 된다(바로 위에 있다).
         되살리려면 아래 map 에서 stkSrchGo 링크를 다시 붙이면 된다(함수는 남겨 둔다). */
      var show=l.slice(0,2).map(function(o){ return _cesc(o.cd); }).join(', ');
      return '<span title="'+tip.replace(/"/g,'&quot;')+'" style="cursor:help">'+show
        + (l.length>2 ? (' <b style="color:#274b8f">+'+(l.length-2)+'</b>') : '') + '</span>';
    }
    /* 매칭코드가 아예 없는 행 — 이 행의 품목코드 자체가 남의 '매칭코드'인지 되짚어 본다(역방향).
       ★같은 코드가 여러 주코드에 붙어 있을 수 있어 첫 건만 칸에 쓰고 나머지는 +N(툴팁에 전부). */
    var rl=(_stkAliasRev&&_stkAliasRev[key])||[];
    if(rl.length){
      var tipR='이 코드는 아래 주코드의 매칭코드로 등록되어 있습니다.&#10;'
             + rl.map(function(o){ return '　' + o.cd + (o.nm?(' · '+o.nm):'') + ' ('+o.via+')'; }).join('&#10;');
      var one=rl[0];
      var arg=_cesc(one.cd).replace(/'/g,"\\'").replace(/"/g,'&quot;');
      /* ★글자는 '표시'일 뿐 — 누르면 다른 칸과 똑같이 그 행이 선택된다(②수불내역 표시). (2026-08-06 지적)
           종전에는 '주코드 9900112233' 글자 전체가 재조회 링크였다. 칸이 넓어서 행을 고르려고
           누를 때 번번이 걸려, 검색어 칸에 코드가 박히고 목록이 통째로 바뀌어
           '내가 검색한 적 없는데 검색된' 상태가 됐다. 재조회는 뒤의 돋보기 아이콘만 한다. */
      return '<span title="'+tipR.replace(/"/g,'&quot;')+'"'
        +    ' style="color:#274b8f;font-weight:800">🔖 주코드 '+_cesc(one.cd)+'</span>'
        + (rl.length>1 ? (' <b style="color:#274b8f">+'+(rl.length-1)+'</b>') : '');
    }
    /* 매칭코드가 없는 품목 — 종전 색(#c8ced4)이 너무 옅어 '칸이 비었다' 로 보였다(2026-08-07 지적) */
    return '<span style="color:#8a97a4" title="이 품목에 등록된 매칭코드가 없습니다.">없음</span>';
  }

  /* 바깥을 누르거나 Esc 로도 닫히게 — 닫기 버튼만 두면 창에 갇힌 느낌이 든다 */
  (function(){
    document.addEventListener('click', function(e){
      var p=document.getElementById('stkSplitPop');
      if(p && p.classList.contains('on') && e.target===p) stkSplitClose();
    });
    document.addEventListener('keydown', function(e){
      if(e.key!=='Escape') return;
      var p=document.getElementById('stkSplitPop');
      if(p && p.classList.contains('on')) stkSplitClose();
    });
  })();
  function stkStatusRender(){
    _stkKeyBind();   // 표를 그릴 때마다 확인(내부에서 한 번만 건다)
    var wrap=document.getElementById('stkStatusWrap'), sum=document.getElementById('stkStatusSum'), pg=document.getElementById('stkStatusPager');
    /* '거래처코드' 칸 = 이 재고가 어떤 거래처 코드들로 합쳐진 것인지 (2026-08-01 요청).
       재고는 언제나 우리 코드 하나로 합산되는데, 그러면 "이 수량이 어느 코드로 들어온 건지" 를 볼 수가 없다.
       매칭코드(TBL_EXT_ITEM_MST)와 연결(TBL_PROD_XREF)을 우리 코드 기준으로 모아 보여 준다. */
    /* ★칸 이름은 '매칭코드' — '거래처코드' 라고 하면 아래 수불내역의 매입처(00272 같은 거래처 코드)와 헷갈린다(2026-08-01 지적) */
    /* ★칸 폭 160px — '🔖 주코드 9904013265' 가 한 줄에 들어가야 한다(2026-08-02) */
    var thead='<thead><tr><th>품목코드</th><th>품목명</th><th style="text-align:right">입고</th><th style="text-align:right">출고</th><th style="text-align:right">현재고</th><th style="text-align:right">이동평균단가</th><th style="text-align:right">재고금액</th><th>최근입고</th><th>최근출고</th></tr></thead>';
    /* [매칭코드 있는 것만] 체크 (2026-08-06 요청) — 합계·건수도 걸러 낸 것만 센다.
       ★매칭코드 자료(_stkAlias)는 목록보다 늦게 도착한다. 아직 없으면 거르지 않는다 —
         안 그러면 화면이 잠깐 텅 비어 '자료가 없다'로 오해하게 된다. */
    var _onlyA = (function(){ var c=document.getElementById('stkOnlyAlias'); return !!(c && c.checked); })();
    var _aliasReady = !!_stkAlias;
    var view = (_onlyA && _aliasReady) ? _stkRows.filter(function(r){ return _stkHasAlias(r.prodCd); }) : _stkRows;
    var tI=0,tO=0,tQ=0,tA=0; view.forEach(function(r){ tI+=(+r.inQty||0); tO+=(+r.outQty||0); tQ+=(+r.curQty||0); tA+=(+r.stockAmt||0); });
    if(_onlyA && _aliasReady && !view.length){
      sum.innerHTML='<b style="color:#b06a00">매칭코드가 등록된 품목이 없습니다.</b> (체크를 풀면 전체가 보입니다)';
      wrap.innerHTML=''; if(pg) pg.innerHTML=''; return;
    }
    if(!_stkRows.length && _stkSrchVia){
      sum.innerHTML='<b style="color:#b06a00">'+_cesc(_stkSrchVia)+'</b> 는 매칭코드입니다. 대표코드로 바꿔 찾았으나 재고가 없습니다.';
      wrap.innerHTML=''; if(pg) pg.innerHTML=''; return;
    }
    if(!_stkRows.length){ sum.textContent='현재고 데이터가 없습니다. (입고 수불 등록 또는 출고(SHIPOUT) 발생 시 표시)'; wrap.innerHTML=''; wrap._lz=null; pg.innerHTML=''; return; }
    sum.innerHTML=(_onlyA ? (_aliasReady ? '<b style="color:#b06a00">매칭코드 있는 것만</b> · '
                                        : '<span style="color:#9aa7b3">매칭코드 불러오는 중…</span> · ') : '')
      +(_stkSrchVia ? ('<b style="color:#b06a00">'+_cesc(_stkSrchVia)+'</b><span style="color:#9aa7b3">는 매칭코드 — 대표코드로 찾았습니다</span> · ') : '')
      +'총 <b>'+view.length.toLocaleString()+'</b>품목 · 입고합 <b>'+_cnum(tI)+'</b> · 출고합 <b>'+_cnum(tO)+'</b> · 현재고합 <b>'+_cnum(tQ)+'</b> · 재고금액합 <b>'+_cnum(tA)+'</b>';
    var totalRow='<tr class="close-total"><td colspan="2" style="text-align:left">■ 총합계</td><td style="text-align:right">'+_cnum(tI)+'</td><td style="text-align:right">'+_cnum(tO)+'</td><td style="text-align:right">'+_cnum(tQ)+'</td><td></td><td style="text-align:right">'+_cnum(tA)+'</td><td></td><td></td></tr>';
    var stkRow=function(r){ var neg=(+r.curQty||0)<0;
      /* 하위 행이 붙는 줄은 대표 줄 위에도 선을 그어 '한 덩어리' 로 보이게 한다(2026-08-07 요청).
         하위가 없으면 선도 없어 평소 표는 그대로다. */
      /* ↳ 매칭 줄도 눌러서 고를 수 있다 — 아래 ②가 그 코드로 나간 날짜만 보여 준다(2026-08-07 요청).
         품목(prodSeq)은 대표와 같고 세 번째 인자로 코드를 넘긴다. */
      var _ps=(r.prodSeq||0);
      var sub=stkAliasRows(r.prodCd, r.extQtys, 9, 0, 3, function(cd){
        return 'stkLedgerDetail('+_ps+", this, '"+String(cd).replace(/'/g,'')+"')";
      /* 지금 ②에서 걸러 보고 있는 코드가 이 품목의 것일 때만 표시한다 —
         다른 품목 줄까지 초록이 되면 어느 줄을 보고 있는지 되레 헷갈린다. */
      }, (_stkLedRow && _stkLedRow.prodCd===r.prodCd) ? _stkLedExt : '', true);   /* true = ↳ 옆 돋보기 켜기 */
      /* 접혀 있으면 하위 행을 아예 안 그린다. 대신 품목코드 앞에 ▼/▶ 를 붙여
         "펼칠 게 있다" 는 것과 몇 개인지를 알린다(2026-08-07 요청). */
      var open=stkExpOn(r.prodCd), nSub=sub ? (sub.match(/<tr/g)||[]).length : 0;
      var caret = sub
        ? '<a href="javascript:void(0)" onclick="stkExpToggle(\''+_cesc(r.prodCd)+'\',event)"'
          + ' style="color:#b06a00;font-weight:800;text-decoration:none;margin-right:4px" title="매칭코드 '+nSub+'줄 접기/펼치기">'
          + (open?'▼':'▶')+'</a>' : '';
      if(!open) sub='';
      /* data-main : 이 줄이 '품목 줄' 이라는 표시. 하위 ↳ 줄을 눌렀을 때 그 줄이 딸린
         품목 줄을 거슬러 찾아 맨 위로 올리는 데 쓴다(2026-08-07 요청). */
      return '<tr class="'+(nSub?'stk-grp':'')+'" data-main="1" data-seq="'+(r.prodSeq||0)+'" style="cursor:pointer" onclick="stkLedgerDetail('+(r.prodSeq||0)+', this)" title="클릭 → 아래 ② 수불 내역(근거) 표시"><td>'+caret+_cesc(r.prodCd)+(nSub&&!open?' <span style="color:#b06a00;font-size:11px;font-weight:700">+'+nSub+'</span>':'')+'</td><td class="txt-l">'+_cesc(r.prodNm)+'</td>'
        +'<td style="text-align:right;color:#137a6c">'+_cnum(r.inQty)+'</td>'
        +'<td style="text-align:right;color:#b06a00">'+_cnum(r.outQty)+'</td>'
        +'<td style="text-align:right;font-weight:700;color:'+(neg?'#c0392b':'#137a6c')+'">'+_cnum(r.curQty)+'</td>'
        +'<td style="text-align:right">'+_cnum(r.avgInPrice)+'</td><td style="text-align:right">'+_cnum(r.stockAmt)+'</td>'
        +'<td>'+_fmtYmd(r.lastInDt)+'</td><td>'+_fmtYmd(r.lastOutDt)+'</td></tr>'
        /* 매칭코드 하위 행 — 9열, 품목코드=0번 칸, 출고=3번 칸.
           lzMount 는 rowFn 이 돌려준 문자열을 그대로 이어 붙이므로 <tr> 을 여러 개 줘도 된다. */
        + sub;
    };
    lzMount({ wrap:wrap, pager:'stkStatusPager', rows:STK_PAGE, capTop:300,
              head:'<table class="logi-tb">'+thead+'<tbody>'+totalRow,
              list:view, rowFn:stkRow });
    /* ★다시 그려도 고른 줄을 그대로 둔다 (2026-08-07).
         lzMount 는 innerHTML 을 통째로 갈아 끼운다 — 그래서 매칭 접기/펼치기나 조회를 하면
         선택 표시(.stk-on)가 사라지고 스크롤도 맨 위로 튀었다. 같은 줄을 찾아 도로 표시하고
         맨 위로 올린다. 아직 안 붙은(스크롤로 이어 붙는) 줄이면 조용히 건너뛴다. */
    /* 버튼 색은 처음 그릴 때부터 상태를 따르게 한다 — 눌러야 색이 붙으면 첫 화면만 딴판이 된다 */
    _stkExpBtnPaint(document.getElementById('stkExpBtn'), _stkExpAll, '▼ 매칭 접기', '▶ 매칭 펼치기');
    if(_stkSelSeq){
      var _sel=wrap.querySelector('tbody tr[data-seq="'+_stkSelSeq+'"]');
      /* 표시는 언제나 되살리고, 자리를 옮기는 건 펼쳐 놓았을 때만 */
      if(_sel){ _sel.classList.add('stk-on'); if(_stkLedMax){ _stkTopFitSel(true); _stkScrollTop(wrap, _sel); } }
    }
    _stkLedFit();   // 상단 그리드 높이가 바뀌면 아래 수불 표도 다시 맞춘다(검색으로 행수가 줄 때)
  }
  // 창고별 세부 로케이션 더미 데이터 (s: empty=빈자리, use=사용중, full=만재)
  var WH_DATA = {
    WH1:{nm:'제1창고',type:'상온',zone:'A구역',rate:62,locs:[
      {c:'A-01-01',s:'use'}, {c:'A-01-02',s:'use'}, {c:'A-01-03',s:'empty'},{c:'A-01-04',s:'full'},
      {c:'A-02-01',s:'use'}, {c:'A-02-02',s:'use'}, {c:'A-02-03',s:'empty'},{c:'A-02-04',s:'empty'},
      {c:'B-01-01',s:'full'},{c:'B-01-02',s:'use'}, {c:'B-01-03',s:'empty'},{c:'B-01-04',s:'use'} ]},
    WH2:{nm:'제2창고',type:'냉장',zone:'B구역',rate:38,locs:[
      {c:'R-01-01',s:'empty'},{c:'R-01-02',s:'use'}, {c:'R-01-03',s:'empty'},{c:'R-01-04',s:'empty'},
      {c:'R-02-01',s:'use'}, {c:'R-02-02',s:'empty'},{c:'R-02-03',s:'empty'},{c:'R-02-04',s:'empty'},
      {c:'R-03-01',s:'use'}, {c:'R-03-02',s:'empty'},{c:'R-03-03',s:'empty'},{c:'R-03-04',s:'empty'} ]},
    WH3:{nm:'제3창고',type:'외부',zone:'C구역',rate:85,locs:[
      {c:'C-01-01',s:'full'},{c:'C-01-02',s:'full'},{c:'C-01-03',s:'use'}, {c:'C-01-04',s:'full'},
      {c:'C-02-01',s:'full'},{c:'C-02-02',s:'use'}, {c:'C-02-03',s:'full'},{c:'C-02-04',s:'empty'},
      {c:'C-03-01',s:'full'},{c:'C-03-02',s:'full'},{c:'C-03-03',s:'use'}, {c:'C-03-04',s:'full'} ]}
  };
  var ST_LBL = { empty:'빈자리', use:'사용중', full:'만재' };

  // 상품별 현재고 위치 (입고 동일위치 알림 + 발주리스트 위치 자동선별 공용)
  //  · loc 값은 위 WH_DATA 의 '사용중' 칸과 일치시킴
  var ITEM_STOCK = {
    'ITM-1001':[ {whc:'WH1',wh:'제1창고',loc:'A-02-01',qty:120}, {whc:'WH3',wh:'제3창고',loc:'C-02-02',qty:40} ],
    'ITM-1042':[ {whc:'WH2',wh:'제2창고',loc:'R-01-02',qty:50} ],
    'ITM-1108':[ {whc:'WH3',wh:'제3창고',loc:'C-01-03',qty:300} ]
  };
  var WH_ORDER = ['WH1','WH2','WH3'];

  // 창고 선택 → 세부 로케이션/상태/위치추천 렌더 (입고등록)
  function whSelect(el, code){
    document.querySelectorAll('.wh-card').forEach(function(c){ c.classList.remove('sel'); });
    el.classList.add('sel');
    renderWhDetail(code);
  }

  function renderWhDetail(code){
    var w = WH_DATA[code]; if(!w) return;
    var empties = w.locs.filter(function(l){ return l.s==='empty'; });
    var uses    = w.locs.filter(function(l){ return l.s==='use'; });
    var rec = empties.length ? empties[0] : (uses.length ? uses[0] : null);

    // ① 창고 상태 요약
    var sh = '';
    sh += '<div class="chip">유형 <b>'+w.type+' · '+w.zone+'</b></div>';
    sh += '<div class="chip">적재율 <b>'+w.rate+'%</b></div>';
    sh += '<div class="chip">빈자리 <b>'+empties.length+'</b> / 전체 '+w.locs.length+'</div>';
    document.getElementById('whStatus').innerHTML = sh;

    // ② 위치선정 안내
    var g = document.getElementById('whGuide');
    if(rec){
      g.className = 'guide';
      var lbl = (rec.s==='empty') ? '빈 자리' : '여유 있는 자리';
      g.innerHTML = '<span class="g-ic">📍</span><div>이번 입고 물품은 <b>'+w.nm+' '+rec.c+'</b> ('+lbl+') 에 적재 추천합니다.'
                  + ' <span style="color:#6b7a89">— 빈자리 우선, 적재율 낮은 위치</span></div>';
    } else {
      g.className = 'guide warn';
      g.innerHTML = '<span class="g-ic">⚠️</span><div><b>'+w.nm+'</b> 는 빈 자리가 없습니다(적재율 '+w.rate+'%). 다른 창고를 선택하세요.</div>';
    }

    // ③ 로케이션 맵
    var html='';
    w.locs.forEach(function(l){
      var cls = 'loc-cell st-'+l.s;
      var isRec = rec && (l.c===rec.c);
      if(isRec) cls += ' rec sel';
      var click = (l.s==='full') ? '' : 'onclick="pickLoc(\''+l.c+'\',this)"';
      html += '<div class="'+cls+'" data-code="'+l.c+'" '+click+'>'
            + (isRec ? '<span class="rec-badge">추천</span>' : '')
            + '<div class="lc-code">'+l.c+'</div><div class="lc-st">'+ST_LBL[l.s]+'</div></div>';
    });
    document.getElementById('locMap').innerHTML = html;

    // ④ 선택 로케이션 input (추천값 기본 입력)
    document.getElementById('locInput').value = rec ? rec.c : '';
    document.getElementById('whDetail').style.display = 'block';
  }

  // 맵에서 위치 클릭 → 선택 변경
  function pickLoc(loc, el){
    document.querySelectorAll('#locMap .loc-cell').forEach(function(c){ c.classList.remove('sel'); });
    el.classList.add('sel');
    document.getElementById('locInput').value = loc;
  }

  // [입고] 상품코드 입력 → 기존 재고 위치 있으면 동일위치 알림
  function checkExistingStock(code){
    var box = document.getElementById('inStockAlert'); if(!box) return;
    code = (code||'').trim().toUpperCase();
    var stk = ITEM_STOCK[code];
    if(code && stk && stk.length){
      var parts = stk.map(function(s){ return '<b>'+s.wh+' '+s.loc+'</b>('+s.qty+')'; }).join(', ');
      var f = stk[0];
      box.className = 'guide'; box.style.display = 'flex';
      box.innerHTML = '<span class="g-ic">🔔</span><div>이 상품은 이미 '+parts+' 에 재고가 있습니다. <b>동일 위치 적재 권장</b>'
        + ' <button class="btn-teal" style="padding:4px 11px;margin-left:8px;font-size:12px" '
        + 'onclick="selectSameLoc(\''+f.whc+'\',\''+f.loc+'\')">동일위치로 선택</button></div>';
    } else if(code){
      box.className = 'guide warn'; box.style.display = 'flex';
      box.innerHTML = '<span class="g-ic">🆕</span><div>신규 상품입니다. 빈 자리 기준으로 위치를 추천합니다.</div>';
    } else {
      box.style.display = 'none';
    }
  }

  // [입고] 동일위치로 선택 → 해당 창고 카드 선택 + 맵에서 그 위치 지정
  function selectSameLoc(whc, loc){
    var idx = WH_ORDER.indexOf(whc);
    var cards = document.querySelectorAll('#panel-inbound .wh-card');
    if(idx>=0 && cards[idx]) whSelect(cards[idx], whc);
    var cell = document.querySelector('#locMap .loc-cell[data-code="'+loc+'"]');
    if(cell){
      document.querySelectorAll('#locMap .loc-cell').forEach(function(c){ c.classList.remove('sel'); });
      cell.classList.add('sel');
    }
    document.getElementById('locInput').value = loc;
    var g = document.getElementById('whGuide');
    if(g) g.innerHTML = '<span class="g-ic">📍</span><div>기존 재고와 <b>동일 위치 '+loc+'</b> 에 합산 적재합니다.</div>';
  }

  // [발주리스트] 발주 상품을 재고와 매칭 → 창고위치 자동선별
  function autoLocateOrders(){
    var rows = document.querySelectorAll('#orderBody tr'); var matched=0;
    rows.forEach(function(r){
      var item = r.getAttribute('data-item');
      var cell = r.querySelector('.oloc');
      var stk = ITEM_STOCK[item];
      if(stk && stk.length){
        var best = stk.slice().sort(function(a,b){ return b.qty-a.qty; })[0];
        var extra = stk.length>1 ? ' <span style="color:#6b7a89;font-weight:400">(외 '+(stk.length-1)+'곳)</span>' : '';
        cell.innerHTML = best.wh+' '+best.loc+extra; cell.className='loc oloc'; matched++;
      } else {
        cell.innerHTML = '<span style="color:#c0392b">재고없음</span>'; cell.className='oloc';
      }
    });
    var n = document.getElementById('orderMatchNote');
    if(n) n.innerHTML = '✔ '+matched+'건 위치 자동선별 완료 — 재고 보유량이 많은 창고 우선 배정.';
  }

  // [발주리스트] 엑셀(CSV) 다운로드 — 위치 자동선별 후 내보내기
  function downloadOrderExcel(){
    autoLocateOrders();
    var rows = document.querySelectorAll('#orderBody tr');
    var lines = ['발주일,발주처,상품코드,상품명,수량,적재위치,상태'];
    rows.forEach(function(r){
      var cols = [];
      r.querySelectorAll('td').forEach(function(td){ cols.push('"'+td.textContent.trim().replace(/"/g,'""')+'"'); });
      lines.push(cols.join(','));
    });
    var blob = new Blob(['﻿'+lines.join('\r\n')], {type:'text/csv;charset=utf-8;'});
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a'); a.href=url; a.download='발주리스트_위치포함.csv';
    document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
  }

  // 최초 진입(기본 선택=제1창고) 상세 렌더
  //  · AJAX 주입 시: 아래 즉시실행이 동작(요소 이미 삽입됨)
  //  · 직접 접근 시: DOMContentLoaded 로 처리
  function _logiInit(){ var t=document.getElementById('whDetail'); if(t) renderWhDetail('WH1'); }
  document.addEventListener('DOMContentLoaded', _logiInit);
  (function(){ _logiInit(); })();
</script>

<!-- 로컬(폐쇄망) 우선 로드 → 로컬 파일 누락 시에만 CDN 폴백. defer 로 화면 먼저 렌더 -->
<script>
  // 로컬 스크립트 로드 실패 시 지정 CDN 으로 폴백 (인터넷 있을 때만 의미)
  function ssCdnFallback(el, url){ el.onerror=null; var s=document.createElement('script'); s.defer=true; s.src=url; (document.head||document.documentElement).appendChild(s); }
</script>
<!-- 엑셀 파서 (xlsx) -->
<script defer src="${pageContext.request.contextPath}/assets/vendor/sheetjs/xlsx.full.min.js"
        onerror="ssCdnFallback(this,'https://cdn.sheetjs.com/xlsx-0.20.3/package/dist/xlsx.full.min.js')"></script>
<!-- ZIP 처리 (일부 ERP가 생성한 비표준 xlsx의 sharedStrings 보정용) -->
<script defer src="${pageContext.request.contextPath}/assets/vendor/jszip/jszip.min.js"
        onerror="ssCdnFallback(this,'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js')"></script>
<!-- PDF 출력 (jsPDF + html2canvas, 한글 안전 이미지 캡처) -->
<script defer src="${pageContext.request.contextPath}/assets/vendor/html2canvas/html2canvas.min.js"
        onerror="ssCdnFallback(this,'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js')"></script>
<script defer src="${pageContext.request.contextPath}/assets/vendor/jspdf/jspdf.umd.min.js"
        onerror="ssCdnFallback(this,'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js')"></script>
<%-- ══════════════════════════════════════════════════════════════════════════
     ★2026-08-02 : 여기 있던 화면 스크립트(38만 자)를 /js/winct/logi-oh.js 로 옮겼다.

     왜  : JSP 는 정적 텍스트가 전부 _jspService() **한 메서드**로 들어간다.
           자바 메서드 상한이 65,535 바이트라, 이 JS 가 여기 있는 동안 상한을 넘겨
           "The code of method _jspService(...) is exceeding the 65535 bytes limit" 로
           JSP 컴파일이 통째로 실패했다 — 증상은 **로그인 후 빈 화면**(HTTP 500)이었다.
     주의 : ★여기에 JS 를 다시 붙이지 말 것. 몇 KB만 늘어도 같은 오류가 재발한다.
            새 스크립트는 logi-oh.js 에 넣는다.
            ★src 로 부르는 자리는 원래 인라인 블록이 있던 그 자리다 — defer/async 를 붙이면
              실행 순서가 바뀌어 앞 블록에서 만든 전역을 못 찾는다. 붙이지 말 것.
     ══════════════════════════════════════════════════════════════════════════ --%>
<%-- ★캐시 무효화는 **파일 수정시각**으로 한다 (2026-08-02).
       고정 문자열(?v=20260802)을 쓰면 JS 를 고쳐도 브라우저가 옛 파일을 그대로 써서
       "화면에 반영이 안 된다"가 된다 — 실제로 겪었다(칸 순서를 바꿨는데 옛 순서가 계속 보임).
       lastModified 를 붙이면 파일이 바뀔 때만 주소가 바뀌므로, 안 바뀐 동안은 캐시가 그대로 살아 빠르다. --%>
<%
  long _ohJsVer = 0L;
  try { _ohJsVer = new java.io.File(application.getRealPath("/js/winct/logi-oh.js")).lastModified(); } catch (Exception _e) { }
%>
<script>var KONET_CTX = '${pageContext.request.contextPath}';</script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winct/logi-oh.js?v=<%=_ohJsVer%>"></script>
<%-- 노트북(1366×768·1440×900) 대응 — 2026-08-02 추가.
     viewport 는 이 화면이 tiles 를 안 거치는 .raw 페이지라 여기에 직접 둔다(셸 = 최상위 문서).
     CSS 는 이 한 줄만 빼면 종전 데스크탑 화면 그대로다. --%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
</head>
<body>
<%-- 좌측 메뉴 접힘 상태를 <그리기 전에> 입힌다 (2026-08-05) —
     DOMContentLoaded 까지 기다리면 메뉴가 폈다가 접히는 게 한 번 보인다(깜빡임).
     실제 접기/펼치기 동작은 logi-oh.js 의 logiSideFold* 가 맡는다. --%>
<script>try{ if(localStorage.getItem('konetLogiSideFold')==='1') document.body.classList.add('logi-side-fold'); }catch(e){}</script>
<%-- 태블릿(폭 ≤1100px) 메뉴 열기 버튼 + 뒷막 — 2026-08-02.
     데스크탑·노트북에서는 konet-notebook.css 가 display:none 으로 숨겨 없는 것과 같다.
     ★버튼을 .logi-wrap 안(사이드바 앞)에 두는 이유 = position:fixed 라 위치는 무관하지만,
       메뉴와 한 덩어리로 읽히게 두는 편이 다음 사람이 찾기 쉽다. --%>
<button id="konetSideBtn" type="button" onclick="konetSideToggle()" title="메뉴 열기/닫기" aria-label="메뉴 열기">☰</button>
<div id="konetSideBack" onclick="konetSideToggle(false)"></div>

<div class="logi-wrap">

  <!-- ───────────── 좌측 사이드바 ───────────── -->
  <!-- ───── 개발자용 테이블 정보 오버레이 (Ctrl+Alt+T 토글) · 익숙해지면 안 켜면 됨 ───── -->
  <style>
    #tblinfoPanel{ display:none; position:fixed; top:0; right:0; width:min(460px,96vw); height:100vh; z-index:9999;
      background:#0f2b3a; color:#cdeae3; box-shadow:-8px 0 30px rgba(0,0,0,.4); overflow-y:auto; font-size:12.5px; line-height:1.55; }
    #tblinfoPanel.on{ display:block; }
    #tblinfoPanel .tih{ position:sticky; top:0; background:#0b2230; padding:12px 16px; display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #214a44; }
    #tblinfoPanel .tih b{ font-size:14px; color:#8fe0d2; } #tblinfoPanel .tih small{ color:#7fa49c; }
    #tblinfoPanel .tih button{ background:none; border:none; color:#cdeae3; font-size:20px; cursor:pointer; }
    #tblinfoPanel .grp{ margin:14px 16px 4px; color:#5fd0bd; font-weight:800; font-size:11.5px; letter-spacing:.5px; text-transform:uppercase; }
    #tblinfoPanel .row{ margin:0 16px 8px; padding:8px 10px; background:#123a34; border-radius:7px; }
    #tblinfoPanel .row .nm{ font-weight:800; color:#e7fbf5; margin-bottom:2px; }
    #tblinfoPanel code{ background:#0b2a25; padding:1px 5px; border-radius:4px; color:#9fe8da; font-size:11.5px; }
    #tblinfoTip{ display:none; position:fixed; right:14px; bottom:14px; z-index:9998; background:#137a6c; color:#fff; padding:6px 11px; border-radius:8px; font-size:11.5px; box-shadow:0 6px 18px rgba(0,0,0,.25); }
  </style>
  <div id="tblinfoTip">🛈 <b>Ctrl+Alt+T</b> : 테이블 정보</div>
  <div id="tblinfoPanel">
    <div class="tih"><span><b>🛈 화면 ↔ DB 테이블 맵</b> <small>개발자 참조</small></span><button onclick="document.getElementById('tblinfoPanel').classList.remove('on')">&times;</button></div>

    <div class="grp">조회·대시보드관리</div>
    <div class="row"><div class="nm">출고현황표 1·2 / 출고세부조회</div>출고 원천 <code>TBL_SHIPOUT_MST</code>. 배치키=납품<code>DLV_DT</code>+출고장<code>DC_CD</code>, 버전 <code>JOB_SEQ</code>·활성 <code>ACTION_YN='Y'</code>(재업로드 시 이전 배치 'N'). <b>출고일<code>SHPOUT_DT</code>은 배치키가 아니다</b>(2026-07-27 — 출고일을 바꿔 다시 올려도 같은 납품일자·출고장이면 대체된다. 조회 기준으로는 계속 사용). 품목=<code>ITEM_CD</code>, 수량=<code>CUR_QTY</code>.</div>

    <div class="grp">매입·재고관리</div>
    <div class="row"><div class="nm">입고내역</div><code>TBL_STOCK_LEDGER</code> 중 <code>IO_GB='I'</code>(입고). 매입처=<code>VENDOR_CD</code>.</div>
    <div class="row"><div class="nm">매출내역</div>정산서 <code>TBL_SALES_MST</code>(출고장 제공 엑셀, 배치키=<code>DLV_DT</code>+<code>DC_NM</code>·<code>JOB_SEQ</code>·<code>ACTION_YN</code>) × 출고 <code>TBL_SHIPOUT_MST</code>(수량 <code>CUR_QTY</code>). <b>대사키=<code>DLV_DT</code>+<code>DC_CD</code>(없으면 DC_NM)+<code>ITEM_CD</code></b> — 합계 대 합계. 기간=<code>DLV_DT</code>. 저장 시 <code>TBL_PROD_SALEPRICE_HST</code> MERGE(<code>APPLY_DT=DLV_DT</code>).<br>
      ⚠ 실측: <code>ORD_NO</code>는 출고 쪽 <b>절반이 빈값</b>이라 <b>키로 쓰지 않음</b>(참고 표시만). <code>DC_NM</code> 표기가 다름(<code>평택</code> vs <code>평택물류센터</code>) → 코드 우선, 없으면 접미사 제거 후 매칭. 정산서 105행→103키 / 출고 1145행→888키(사업장 합산).</div>
    <div class="row"><div class="nm">재고현황</div>수불원장 <code>TBL_STOCK_LEDGER</code> 집계 + 현재고 캐시 <code>TBL_STOCK_MST</code>. 현재고=입고(I·R·A)−출고(O). 출고는 <code>TBL_SHIPOUT_MST</code>→원장 <code>O</code>행 자동연동(<code>REF_GB='SHIPOUT'</code>). 행 클릭=그 품목 수불 내역.</div>
    <div class="row"><div class="nm">상품(품목)관리</div>마스터 <code>TBL_PROD_MST</code>. 이력=<code>TBL_PROD_INPRICE_HST</code>/<code>TBL_PROD_SALEPRICE_HST</code>. 재고=<code>TBL_STOCK_LEDGER</code>/<code>TBL_STOCK_MST</code>.</div>

    <div class="grp">마감관리</div>
    <div class="row"><div class="nm">매출마감</div><code>TBL_SHIPOUT_MST</code> × 유효단가(<code>SALEPRICE_HST</code>/<code>INPRICE_HST</code>, 없으면 <code>TBL_PROD_MST</code>).</div>
    <div class="row"><div class="nm">매입마감</div><code>TBL_STOCK_LEDGER</code> 입고(<code>IO_GB='I'</code>) × 매입처(<code>VENDOR_CD</code>).</div>
    <div class="row"><div class="nm">재고마감</div><code>TBL_STOCK_LEDGER</code> 기간집계(기초+입−출±조정=기말) + 이월 스냅샷 <code>TBL_CLOSING_STOCK</code>.</div>
    <div class="row"><div class="nm">마감현황 / 월별 마감이력</div>확정 헤더 <code>TBL_CLOSING_MST</code>(+<code>TBL_CLOSING_STOCK</code>). 잠금=<code>STATUS='C'</code>.</div>
    <div class="row"><div class="nm">매출 그래프(월별/일자별)</div>집계 전용 조회 <code>selectSalesChart</code>/<code>selectSalesChartDaily</code> — 정산서 <code>TBL_SALES_MST</code> + 출고 <code>TBL_SHIPOUT_MST</code> + 전표 <code>TBL_SALES_TRX_MST/DTL</code>. 매입액=출고수량×<code>TBL_PROD_INPRICE_HST</code>(APPLY_DT≤<code>DLV_DT</code> 최신, 없으면 <code>TBL_PROD_MST.IN_PRICE</code>), 순마진=매출−매입. <b>금액 정의는 <code>selectClosing</code>과 동일</b>.</div>

    <div class="grp">정산관리</div>
    <div class="row"><div class="nm">거래처별 채권·채무</div>조회 전용 <code>selectCustBalance</code> — 정산서 <code>TBL_SALES_MST</code>(거래처마스터 <code>DC_CD</code>로 연결) + 판매전표 <code>TBL_SALES_TRX_MST</code> + 매입전표 <code>TBL_PURCHASE_MST</code> + 수금·지급 <code>TBL_SETTLE_TRX</code>. 거래처명·구분은 <code>TBL_VENDOR_MST</code>. <b>전 거래처 × 월</b>을 한 번에 내려 화면에서 누계·이력으로 접음(기간 파라미터 없음 — 잔액이 누계라서).</div>
    <div class="row"><div class="nm">일계장</div>조회 전용 <code>selectDayBook</code> — 원천은 <code>selectCustBalance</code>와 동일(정산서·판매전표·매입전표·<code>TBL_SETTLE_TRX</code>), 낟알만 <b>일자</b>. 한 쿼리로 <b>당일 발생 + 전일까지 누계</b>(<code>dt='00000000'</code> 행)를 함께 반환.</div>
    <div class="row"><div class="nm">수금 / 미수금</div><code>TBL_RECEIVE_MST</code>(거래처×귀속월). 월마감 <code>TBL_SETTLE_CLOSE_MST</code>(<code>SETTLE_GB='RCV'</code>). <b style="color:#c0392b">※ 메뉴 내림(2026-07-25)</b> — 실제 잔액은 위 전표 원장 기준.</div>
    <div class="row"><div class="nm">출금 / 미지급</div><code>TBL_PAYMENT_MST</code>(매입처×귀속월). 월마감 <code>TBL_SETTLE_CLOSE_MST</code>(<code>SETTLE_GB='PAY'</code>).</div>

    <div class="grp">시스템관리</div>
    <div class="row"><div class="nm">거래처관리</div><code>TBL_BIZI_MST</code>(사업장/거래처).</div>
    <div class="row"><div class="nm">회사·사용자 / 공통코드</div>회사·사용자 관리, 공통코드 관리 테이블.</div>

    <div class="grp">부가·예정 (미구현)</div>
    <div class="row"><div class="nm">물품동선·견적서·카카오톡문자</div>데모/예정 — 실제 테이블 없음(협의 후 신설). 견적서관리의 '매출 엑셀 업로드'는 <b>매입·재고관리 ▸ 출고내역</b>으로 이동.</div>
  </div>
  <script>
    (function(){ document.addEventListener('keydown', function(e){
      if(e.ctrlKey && e.altKey && e.code==='KeyT'){ e.preventDefault();
        document.getElementById('tblinfoPanel').classList.toggle('on'); }
    }); })();
  </script>

  <nav class="logi-side">
    <div class="side-tit">📦 물류관리<small>도매유통 · 입고/재고/발주/출고</small></div>
    <%-- 로그인 회사명 — compLogin 이 세션에 심는 s_comp_nm (다중회사: 어느 회사로 들어왔는지 상시 표시).
         대시보드 메뉴 위, 물류관리 제목과 같은 폰트크기 (2026-07-31 요청) --%>
    <% String _compNm = (String)session.getAttribute("s_comp_nm");
       if (_compNm != null && !_compNm.trim().isEmpty()) { %>
    <div class="side-comp" title="로그인 회사">🏢 <%= _compNm.trim() %></div>
    <% } %>

    <div class="grp">조회·대시보드관리 ★</div>
    <a class="mi core on" data-key="shipstatus2" onclick="logiShipView('zone', this)"><span class="ic">🗂️</span>출고현황표(대시보드)</a>
     <%-- 출고세부조회: 출고장별 품목·사업장별·품목별을 한 화면 3탭으로 통합(2026-07-24).
          서브메뉴 3개 → 단일 메뉴. 탭 전환은 iframe(logistics_demo1) 상단 뷰버튼(zoneitem/biz/item). --%>
     <a class="mi" data-key="shipstatus2" onclick="logiShipView('zoneitem', this)"><span class="ic">🚚</span>출고세부조회</a>
     <%-- 출고현황이력조회(2026-07-25 요청) — 발주현황표 엑셀을 언제·누가·몇 차로 올렸는지와 그 발생내역.
          업로드가 배치(출고일자+출고장+차수)로 남으므로 그 흐름을 일자별로 보여준다. --%>
     <a class="mi" data-key="shipouthist" onclick="logiFrame('shipouthist','${pageContext.request.contextPath}/shipout/shipoutHist.do', this)"><span class="ic">🗂️</span>출고현황이력조회</a>
     <%-- 택배출고관리(2026-08-06 신설) — 출고일자의 직송(ZONE='직송')을 택배 발송 엑셀로.
          주소·운임은 사업장(TBL_BIZI_MST)의 택배 정보를 쓰고, 그 화면에서 바로 채워 저장할 수 있다. --%>
     <a class="mi" data-key="parcelout" onclick="logiFrame('parcelout','${pageContext.request.contextPath}/shipout/parcelOut.do', this)"><span class="ic">🚛</span>택배출고관리</a>

    <%-- 메뉴 배열 = 홀세일닥터 구조에 맞춤(2026-07-25 요청).
         업무 단위(매출/매입/재고)로 묶고 그 안에 등록·정산·마감을 함께 둔다.
         대시보드는 기존대로 맨 위 고정. 화면(패널)과 동작은 그대로이고 배치만 바꿨다. --%>

    <div class="grp">매출 관리</div>
    <a class="mi has-sub" data-sub="salesmng" onclick="logiToggleSub('salesmng', this)"><span class="ic">💰</span>매출 관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-salesmng">
      <a class="mi" data-key="outHist" onclick="logiGo('outHist', this); ohEnter();"><span class="ic">📤</span>매출내역</a>
      <%-- 정산실적 (2026-08-02 요청) — 매출내역 바로 아래. 정산서 원본을 일자별·품목별로 편다. --%>
      <a class="mi" data-key="settlePerf" onclick="logiGo('settlePerf', this); spEnter();"><span class="ic">🧾</span>정산실적</a>
      <a class="mi" data-key="salesreg" onclick="logiFrame('salesreg','${pageContext.request.contextPath}/mangr/salesReg.do', this)"><span class="ic">🧾</span>판매 등록</a>
      <a class="mi" data-key="rcvreg" onclick="logiFrame('rcvreg','${pageContext.request.contextPath}/mangr/rcvReg.do', this)"><span class="ic">🧾</span>수금 등록</a>
      <%-- 수금 / 미수금(월 단위, TBL_RECEIVE_MST) 메뉴 내림 : 2026-07-25.
           '수금 등록'(건별 전표)이 같은 일을 하고 원장의 [월 계] 로 월 합계까지 나온다.
           두 군데 입력하면 잔고가 갈라져서 뺐다. 실사용 0건이라 잃는 데이터 없음.
           화면(receiveMng.jsp)·컨트롤러·패널은 그대로 두었다. 되돌리려면
           logiFrame('receive', <컨텍스트>+'/mangr/receiveMng.do', this) 메뉴 한 줄만 다시 넣으면 된다.
           (EL 표기는 JSP 주석 안에서도 파서를 건드릴 수 있어 일부러 풀어 적었다) --%>
      <a class="mi" data-key="closeSales" onclick="logiGo('closeSales', this)"><span class="ic">📒</span>매출마감</a>
      <%-- 매출 그래프 — 월별/일자별 화면 2개를 탭 하나로 통합(2026-08-02 요청).
           화면 자체(salesChart(Day).jsp)는 그대로 두고, 셸에서 iframe 을 탭으로 갈아끼운다.
           '월별이 일자 자료를 받아 무거워진다' 던 분리 사유는 iframe 탭이라 그대로 유효하다(각자 따로 조회). --%>
      <a class="mi" data-key="salesChartTab" onclick="logiGo('salesChartTab', this); scTabEnter();"><span class="ic">📈</span>매출 그래프</a>
      <%-- 정산 그래프 — 정산서(TBL_SALES_MST)+직접판매를 일자별/월별 탭으로. JS 는 전부 logi-oh.js(sg*) — 이 JSP 에 스크립트 금지(65535).
           ★순서 확정 이력: 처음엔 매출 그래프 위(2026-08-02 오전 지정) → 같은 날 매출 그래프 아래로 재지정. --%>
      <a class="mi" data-key="settleChart" onclick="logiGo('settleChart', this); sgEnter();"><span class="ic">📊</span>정산 그래프</a>
    </div>

    <div class="grp">매입 관리</div>
    <a class="mi has-sub" data-sub="purchmng" onclick="logiToggleSub('purchmng', this)"><span class="ic">🛒</span>매입 관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-purchmng">
      <a class="mi" data-key="purchase" onclick="logiFrame('purchase','${pageContext.request.contextPath}/mangr/purchaseReg.do', this)"><span class="ic">🧾</span>매입 등록</a>
      <a class="mi" data-key="payreg" onclick="logiFrame('payreg','${pageContext.request.contextPath}/mangr/payReg.do', this)"><span class="ic">💸</span>지급 등록</a>
      <%-- 출금 / 미지급(월 단위, TBL_PAYMENT_MST) 메뉴 내림 : 2026-07-25. 위 '수금 / 미수금' 과 같은 이유.
           '지급 등록'(건별 전표)이 대신하고, 월 합계는 원장의 [월 계] 로 나온다. 실사용 0건.
           되돌리려면 logiFrame('payment', <컨텍스트>+'/mangr/paymentMng.do', this) 메뉴 한 줄만 다시 넣는다. --%>
      <a class="mi" data-key="inboundList" onclick="logiGo('inboundList', this); inbInit(); inboundListLoad();"><span class="ic">📄</span>입고내역</a>
      <a class="mi" data-key="closeCost" onclick="logiGo('closeCost', this)"><span class="ic">📒</span>매입마감</a>
    </div>

    <div class="grp">재고 관리</div>
    <a class="mi has-sub" data-sub="stockmng" onclick="logiToggleSub('stockmng', this)"><span class="ic">📦</span>재고 관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-stockmng">
      <a class="mi" data-key="stockStatus" onclick="logiGo('stockStatus', this); stkStatusLoad();"><span class="ic">📊</span>재고현황</a>
      <a class="mi" data-key="closeStock" onclick="logiGo('closeStock', this)"><span class="ic">📒</span>재고마감</a>
      <%-- 품목코드(매핑) — 기준정보에 있다가 재고 관리 맨 아래로 옮김(2026-08-01 요청).
           매핑이 안 되면 그 품목이 재고에서 빠지므로, 재고를 보다가 바로 갈 수 있는 자리가 맞다. --%>
      <a class="mi" data-key="xrefAudit" onclick="logiGo('xrefAudit', this); xaLoad();"><span class="ic">🔗</span>품목코드(매핑)</a>
    </div>

    <div class="grp">정보 현황</div>
    <a class="mi has-sub" data-sub="infomng" onclick="logiToggleSub('infomng', this)"><span class="ic">📈</span>정보 현황<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-infomng">
      <a class="mi" data-key="closeStatus" onclick="logiGo('closeStatus', this)"><span class="ic">📊</span>마감현황(월계표)</a>
      <a class="mi" data-key="closeHist"   onclick="logiGo('closeHist', this); closeHistLoad();"><span class="ic">📅</span>월별 마감이력</a>
    </div>

    <%-- 원장관리 (2026-07-26 요청) — 정보 현황 안에 있던 두 화면을 별도 그룹으로 분리.
         둘 다 '전표(TBL_SETTLE_TRX·매입/판매 전표) + 정산서' 라는 같은 원천을 보는 짝이라 묶어 둔다.
         거래처별 채권·채무 = 잔액(누계) / 일계장 = 하루치 발생 + 전일잔액.
         ※ 이름은 처음 '채권·채무 관리' → 사용자 제안으로 '원장관리'. 재고의 수불원장(TBL_STOCK_LEDGER)과는 다른 뜻이니
           이 그룹에 재고 관련 화면을 넣지 말 것(여기는 거래처 금액 장부). --%>
    <div class="grp">원장관리</div>
    <a class="mi has-sub" data-sub="ledgermng" onclick="logiToggleSub('ledgermng', this)"><span class="ic">📚</span>원장관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-ledgermng">
      <a class="mi" data-key="daybook" onclick="logiFrame('daybook','${pageContext.request.contextPath}/mangr/dayBook.do', this)"><span class="ic">📒</span>일계장</a>
      <a class="mi" data-key="custbal" onclick="logiFrame('custbal','${pageContext.request.contextPath}/mangr/custBalance.do', this)"><span class="ic">💳</span>거래처별 채권·채무</a>
    </div>

    <div class="grp">기준정보</div>
    <%-- 상품코드등록 (2026-08-01 요청) — 상품(품목)관리와 같은 마스터(TBL_PROD_MST)를 보는 등록 전용 화면.
         이력/재고 패널 없이 목록+등록만. 서식은 매입/매출 거래처 관리와 동일(버튼 상단 공통 · 그리드에 수정/삭제 없음).
         ★2026-08-02 사용자 요청으로 상품(품목)관리보다 위로 — 코드 등록·정리가 먼저 들어가는 화면이다. --%>
    <a class="mi" data-key="prodcd" onclick="logiFrame('prodcd','${pageContext.request.contextPath}/prod/prodcd.do', this)"><span class="ic">🏷️</span>상품코드등록</a>
    <a class="mi" data-key="prodmst" onclick="logiFrame('prodmst','${pageContext.request.contextPath}/prod/prodmst.do', this)"><span class="ic">📦</span>상품(품목)관리</a>
    <%-- 거래처 매칭코드는 별도 메뉴로 두지 않는다(2026-08-01 확정) — 상품코드등록 화면 하단에 붙였다.
         자료가 구두·문서로 오고 진입이 언제나 '우리 상품이 먼저' 라, 상품을 고른 자리에서 바로 붙이는 게 맞다. --%>
    <%-- 품목코드(매핑)은 재고 관리 그룹으로 옮겼다(2026-08-01) — 여기 있던 자리 --%>
    <a class="mi has-sub" data-sub="baseinfo" onclick="logiToggleSub('baseinfo', this)"><span class="ic">📂</span>기준정보관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-baseinfo">
      <a class="mi" data-key="vendor"  onclick="logiFrame('vendor','${pageContext.request.contextPath}/mangr/vendorMng.do', this)"><span class="ic">🧾</span>매입/매출 거래처</a>
      <a class="mi" data-key="client"  onclick="logiFrame('client','${pageContext.request.contextPath}/mangr/clientMng.do', this)"><span class="ic">🤝</span>거래처관리(사업장)</a>
      <%-- 회사/사용자 관리 + 공통코드 관리 = 관리자 회사(TBL_COMP_MST.COMMST_YN='Y')만 노출 (2026-07-31).
           서버측도 /mangr/compcd.do · /base/commcd.do 에서 s_admin_yn 가드로 직접 URL 접근 차단. --%>
      <% if ("Y".equals(session.getAttribute("s_admin_yn"))) { %>
      <a class="mi" data-key="compcd" onclick="logiFrame('compcd','${pageContext.request.contextPath}/mangr/compcd.do', this)"><span class="ic">🏢</span>회사/사용자 관리</a>
      <a class="mi" data-key="codecd" onclick="logiFrame('codecd','${pageContext.request.contextPath}/base/commcd.do', this)"><span class="ic">🧩</span>공통코드 관리</a>
      <% } %>
    </div>

    <div class="grp">부가·예정관리</div>
    <a class="mi has-sub" data-sub="goods" onclick="logiToggleSub('goods', this)"><span class="ic">🚚</span>물품동선관리 <span style="font-size:10px;color:#9aa7b3">(예정·데모)</span><span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-goods">
      <a class="mi" data-key="base"     onclick="logiGo('base', this)"><span class="ic">🏬</span>창고 / 로케이션</a>
      <a class="mi" data-key="inbound"  onclick="logiGo('inbound', this)"><span class="ic">📥</span>입고등록 (창고선정)</a>
      <a class="mi" data-key="stock"    onclick="logiGo('stock', this)"><span class="ic">📊</span>창고별 재고현황</a>
      <a class="mi" data-key="locate"   onclick="logiGo('locate', this)"><span class="ic">🔎</span>재고 / 위치 조회</a>
      <a class="mi" data-key="outbound" onclick="logiGo('outbound', this)"><span class="ic">📤</span>출고지시 (위치→출고)</a>
    </div>
    <a class="mi has-sub" data-sub="quote" onclick="logiToggleSub('quote', this)"><span class="ic">📝</span>견적서관리 <span style="font-size:10px;color:#9aa7b3">(예정)</span><span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-quote">
      <a class="mi" onclick="swAlert('견적서 작성은 향후 추진 예정입니다.','info')"><span class="ic">🧾</span>견적서 작성</a>
      <a class="mi" onclick="swAlert('견적서 목록/조회는 향후 추진 예정입니다.','info')"><span class="ic">📋</span>견적서 목록/조회</a>
      <a class="mi" onclick="swAlert('견적서 출력(PDF/엑셀)은 향후 추진 예정입니다.','info')"><span class="ic">🖨️</span>견적서 출력</a>
    </div>
    <a class="mi has-sub" data-sub="kakao" onclick="logiToggleSub('kakao', this)"><span class="ic">💬</span>카카오톡관리 <span style="font-size:10px;color:#9aa7b3">(협의후 예정)</span><span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-kakao">
      <a class="mi" onclick="swAlert('카카오톡/문자 발송은 협의 후 추진 예정입니다.','info')"><span class="ic">📨</span>메시지 발송</a>
      <a class="mi" onclick="swAlert('발송 이력 조회는 협의 후 추진 예정입니다.','info')"><span class="ic">📜</span>발송 이력</a>
      <a class="mi" onclick="swAlert('문자 템플릿 관리는 협의 후 추진 예정입니다.','info')"><span class="ic">🧩</span>문자 템플릿 관리</a>
    </div>

    <div class="grp">도움말</div>
    <a class="mi" data-key="guide" onclick="logiGo('guide', this)"><span class="ic">📖</span>업무 설명서</a>

    <%-- 로그아웃 — 메뉴 맨 하단 (2026-07-31 요청, 같은 날 "조금 아래로" 요청으로 위 여백 추가).
         확인 후 /user/loginOutAct.do(세션 invalidate → 로그인 화면) --%>
    <a class="mi" style="margin-top:26px" onclick="logiLogout()"><span class="ic">🚪</span>로그아웃</a>
  </nav>

  <!-- ───────────── 우측 콘텐츠 ───────────── -->
  <main class="logi-main">

    <%-- ══ 상단 공통 영역 — 자주 쓰는 메뉴 (2026-08-04 요청) ═══════════════════
         · 어느 화면을 열어도 항상 같은 자리(맨 위)에 있다. 화면을 내려도 따라온다(sticky).
         · 쌓이는 법 : 메뉴를 여는 대로 <빈 자리에> 차곡차곡 담긴다. 최대 7개.
         · ★7개가 차면 그대로 고정 — 새 메뉴가 옛 메뉴를 밀어내지 않는다(2026-08-05 요청).
                       바꾸려면 칩의 ✕ 로 <직접> 내려야 한다. 첫 진입 기본값(자동셋팅)도 없다 — 빈 줄로 시작.
         · 실행      : 원래 메뉴의 onclick 을 그대로 부른다 — 화면 여는 방법이 두 벌이 되지 않게. --%>
    <div id="favBar">
      <%-- 좌측 메뉴 접기·펼치기 (2026-08-05 요청) — 글자·아이콘은 logiSideFoldSet 이 상태에 맞춰 바꾼다.
           이 줄에 두는 이유 : 어느 화면에서도 늘 같은 자리(맨 위·맨 앞)에 있어 접어 둔 뒤에도 찾기 쉽다. --%>
      <button id="sideFoldBtn" type="button" onclick="logiSideFoldToggle()"
              title="좌측 메뉴를 접어 본문을 넓게 씁니다"><span class="fi">◀</span>메뉴 접기</button>
      <span class="ft">⭐ 자주 쓰는 메뉴 <span id="favCnt"></span></span>
      <div id="favList"></div>
      <span id="favHint">메뉴를 쓰시면 여기에 <b>쓴 순서대로</b> 쌓입니다 — 최대 7개 (한 번 담기면 <b>✕ 로 내리기 전까지 고정</b>)</span>
      <span id="favClearBtn" title="전부 비웁니다" onclick="favClear()">✕ 비우기</span>
    </div>


    <style>
      .close-tabs{ display:flex; gap:4px; margin:6px 0 10px; border-bottom:2px solid #e2e8e6; }
      .close-tabs .ctab{ height:34px; padding:0 14px; border:1px solid #dfe6e3; border-bottom:none; background:#f1f5f4; border-radius:8px 8px 0 0; cursor:pointer; font-size:13px; font-weight:700; color:#5a6b7a; }
      .close-tabs .ctab.on{ background:#137a6c; color:#fff; border-color:#137a6c; }
      /* 긴 안내문 대신 쓰는 툴팁 칩 — 자세한 내용은 title(hover)로 */
      .tipx{ display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border:1px solid #dfe6e3; border-radius:999px;
             background:#f1f5f4; color:#5a6b7a; font-weight:700; font-size:12px; cursor:help; white-space:nowrap; }
      .tipx:hover{ border-color:#137a6c; color:#137a6c; background:#eaf5f3; }
      /* 목록 그리드 — 헤더 고정 + 화면 높이에 맞춰 스크롤(위쪽 카드가 커져도 그리드가 안 밀림).
         실제 높이는 렌더 때 _ohFit 이 인라인으로 다시 잡는다(18행 ↔ 뷰포트 중 작은 쪽). 여기 값은 그 전/빈 표일 때의 기본. */
      #ohWrap{ max-height:calc(100vh - 214px); min-height:240px; overflow:auto; }
      /* 표를 위로 끌어올리려고 탭·요약줄을 최소 높이로(2026-07-22 요청) — 이 화면에만 적용.
         단 탭 바의 2px 경계선에 요약줄 글자가 붙어 겹쳐 보이므로, 여백은 '탭 아래쪽'에 준다
         (요약줄 위 여백으로 주면 칩 배경이 경계선에 닿아 여전히 붙어 보인다) */
      #ohTabs{ margin:4px 0 12px !important; }
      #ohSum{ margin:0 0 6px !important; padding-top:2px; font-size:12.5px; line-height:1.35; }
      #ohTabs .ctab{ height:30px; padding:0 12px; font-size:12.5px; }
      /* ⑤ 수량차이 품목 탭만 빨간색 — 눈에 먼저 걸리게(2026-07-27 요청) */
      #ohTabs .ctab.ctab-red{ color:#c0392b; border-color:#f0c9c2; background:#fff7f6; }
      #ohTabs .ctab.ctab-red:hover{ background:#ffeeec; }
      #ohTabs .ctab.ctab-red.on{ background:#c0392b; color:#fff; border-color:#c0392b; }
      #ohTabs .btn-line{ height:26px !important; margin-bottom:2px; }
      #ohWrap table.logi-tb thead th{ position:sticky; top:0; z-index:2; box-shadow:inset 0 -1px 0 var(--logi-border); }
      /* ①출고장별 합계 — 출고장 이름이 잘려 보인다는 지적(2026-07-27). 머리글은 그대로, 자료칸만 넓힌다.
         auto layout 이라 자료칸 최소폭이 곧 그 열의 폭이 된다(머리글도 따라 넓어지지만 th 규격은 손대지 않음). */
      table.logi-tb.oh-dc tbody td:first-child{ min-width:320px; }
      /* 정산 엑셀 저장 팝업의 파일 목록 — 칸이 줄바꿈되면 읽기 나쁘므로 한 줄로 고정, 넘치면 가로 스크롤 */
      #slsUpWrap .sls-ftb th, #slsUpWrap .sls-ftb td{ white-space:nowrap; }
      #slsUpWrap{ overflow:auto; }
      /* 출고장 다중선택 드롭다운 — 대시보드(데시보드1 .dc-pop)와 같은 형태 */
      .ohdc-wrap{ position:relative; display:block; }
      <%-- ★id 선택자라 새 화면 버튼(#spDcBtn)에는 안 먹어서 아이콘과 글자가 겹쳤다 — 같이 걸어 준다(2026-08-02) --%>
      #ohDcBtn, #spDcBtn{ width:100%; height:34px; display:flex; align-items:center; justify-content:space-between; gap:6px; text-align:left; }
      #ohDcBtn .arr, #spDcBtn .arr{ margin-left:auto; flex:0 0 auto; color:#178074; }
      /* ★width:230px 을 min-width 로 주면 부모(.fld 190px)에 눌려 글자가 세로로 접힌다 — 고정폭 + nowrap 필수 */
      .ohdc-pop{ display:none; position:absolute; top:38px; left:0; z-index:60; background:#fff; border:1px solid var(--logi-border);
                 border-radius:8px; box-shadow:0 6px 18px rgba(31,42,55,.18); padding:8px 6px;
                 width:250px; max-height:340px; overflow-y:auto; overflow-x:hidden; box-sizing:border-box; }
      .ohdc-pop.open{ display:block; }
      .ohdc-pop label{ display:flex; align-items:center; gap:8px; padding:6px 10px; font-size:12.5px; color:#37475a;
                       cursor:pointer; border-radius:6px; white-space:nowrap; }
      .ohdc-pop label:hover{ background:#eef3f2; }
      /* 체크박스가 flex 아이템이라 늘어나는 것을 막는다(캡처의 거대 체크박스 원인) */
      .ohdc-pop label input[type=checkbox]{ flex:0 0 auto; width:14px; height:14px; margin:0; }
      .ohdc-pop label > span{ flex:1 1 auto; overflow:hidden; text-overflow:ellipsis; }
      .ohdc-pop label.all{ color:#178074; font-weight:700; border-bottom:1px dashed var(--logi-border); border-radius:6px 6px 0 0; margin-bottom:4px; }
      .ohdc-pop label.on{ color:#0e6657; background:#e3f4ef; }
      .ohdc-pop label.kid{ padding-left:28px; font-size:12px; }        /* 묶음 하위 개별 출고장 */
      /* ①탭 상태 칸 — 여기만 눌러야 ②탭으로 넘어간다(줄 전체 클릭 금지). 눌리는 칸임을 배경·커서로 알린다 */
      .oh-st{ cursor:pointer; }
      .oh-st:hover{ background:#eaf3f1; box-shadow:inset 0 0 0 1px #b9d9d1; }
      .oh-st .badge{ cursor:pointer; }
      /* 대사(합계) 열 — 정산이 없는 출고, 출고가 없는 정산을 눈에 띄게 */
      .oh-gap{ color:#c0392b; font-weight:800; }
      .oh-ok{ color:#137a6c; font-weight:800; }
      .close-tabs .cq{ height:30px; width:210px; margin-bottom:2px; padding:0 10px; border:1px solid #dfe6e3; border-radius:6px; font-size:12.5px; color:#37475a; background:#fff; }
      .close-tabs .cq:focus{ outline:none; border-color:#137a6c; box-shadow:0 0 0 2px rgba(19,122,108,.15); }
      .close-summary{ margin:6px 0; font-size:13px; color:#37475a; font-weight:600; }
      /* ①표와 ②수불내역 사이가 넓어 보여 여백을 줄였다(2026-08-07 요청) — 12/4 → 5/2 */
      .close-pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin:5px 0 2px; flex-wrap:wrap; }
      .close-pager button{ min-width:30px; height:30px; border:1px solid #dfe6e3; background:#fff; border-radius:6px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
      .close-pager button.on{ background:#137a6c; color:#fff; border-color:#137a6c; }
      .close-pager button:disabled{ opacity:.45; cursor:default; }
      table.logi-tb tr.close-total td{ background:#137a6c; color:#fff !important; font-weight:800; }
      table.logi-tb tr.close-grp td{ background:#eaf3f1; color:#137a6c; font-weight:800; cursor:pointer; }
      table.logi-tb tr.close-grp:hover td{ background:#dcefe9; }
      table.logi-tb tr.close-grp .ccar{ display:inline-block; width:13px; color:#1f9b8e; }
      table.logi-tb tr.close-sub td{ background:#f1f5f4; font-weight:800; }
      table.logi-tb tr.close-total td:first-child, table.logi-tb tr.close-grp td:first-child, table.logi-tb tr.close-sub td:first-child{ text-align:left; }
      /* 재고현황 ① 그리드: 스크롤해도 헤더 + 총합계 행 고정 */
      #stkStatusWrap table.logi-tb thead th{ position:sticky; top:0; z-index:4; box-shadow:inset 0 -1px 0 var(--logi-border); }
      /* 입고내역 — 스크롤 목록(lzMount)이 되면서 필요해진 규칙(2026-08-04)
           ★overflow 가 없으면 스크롤 자체가 안 생겨 '이어서 나옴'이 동작하지 않는다(정산서 원본 탭에서 겪은 것과 같음).
             실제 높이는 lzFit(fill)이 인라인 maxHeight 로 화면 바닥까지 잡는다. */
      #inbWrap{ overflow:auto; min-height:240px; }
      #inbWrap table.logi-tb thead th{ position:sticky; top:0; z-index:4; box-shadow:inset 0 -1px 0 var(--logi-border); }
      #inbWrap table.logi-tb tr.close-total td{ position:sticky; top:37px; z-index:3; }
      /* 묶음 토글 — 매출내역(출고장별 합계)과 같은 색. 조회줄을 가리지 않게 작게 */
      #inbSum button{ flex:0 0 auto; border:1px solid var(--logi-border); background:#fff; border-radius:14px;
                      padding:3px 11px; font-size:12px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
      #inbSum button:hover{ border-color:#137a6c; color:#137a6c; }
      #inbSum button.on{ background:#137a6c; color:#fff; border-color:#137a6c; }
      #inbSum button.on:hover{ background:#0f6b5c; color:#fff; }
      #stkStatusWrap table.logi-tb tbody tr.close-total td{ position:sticky; top:34px; z-index:3; box-shadow:inset 0 -1px 0 rgba(255,255,255,.3); }
      /* 조회 진행바 — 정산서 대사가 붙으면서 마감·매출내역 조회가 무거워졌다(2026-07-25).
         응답이 올 때까지 표 자리에 띄운다. 진행률을 알 수 없는 조회라 좌우로 흐르는 무한 바. */
      .qprog{ height:3px; background:#e8efed; border-radius:2px; overflow:hidden; margin:2px 0 8px; }
      .qprog > i{ display:block; height:100%; width:34%; border-radius:2px;
                  background:linear-gradient(90deg,#0f6b5f,#3fbfae); animation:qslide 1.05s infinite ease-in-out; }
      @keyframes qslide{ 0%{ margin-left:-34%; } 100%{ margin-left:100%; } }
      .qmsg{ padding:10px 2px 4px; color:#5a6b7a; font-size:12.5px; }
      /* 재고현황 ② 수불내역: 5행 초과 스크롤 + 헤더 고정 */
      #stkLedgerBody table.logi-tb thead th{ position:sticky; top:0; z-index:2; box-shadow:inset 0 -1px 0 var(--logi-border); }
      /* 마감관리 4그리드(매출·매입·재고마감·마감현황) — 매출내역과 같이 18행씩 + 자동 스크롤(2026-07-25).
         높이는 렌더 때 lzFit 이 인라인으로 잡는다. 여기서는 스크롤 상자로 만들고 머리글·총합계만 고정한다. */
      #closeSalesWrap, #closeCostWrap, #closeStockWrap, #closeStatusWrap{ overflow:auto; }
      #closeSalesWrap table.logi-tb thead th, #closeCostWrap table.logi-tb thead th,
      #closeStockWrap table.logi-tb thead th, #closeStatusWrap table.logi-tb thead th{
        position:sticky; top:0; z-index:4; box-shadow:inset 0 -1px 0 var(--logi-border); }
      #closeSalesWrap table.logi-tb tbody tr.close-total td, #closeCostWrap table.logi-tb tbody tr.close-total td,
      #closeStockWrap table.logi-tb tbody tr.close-total td, #closeStatusWrap table.logi-tb tbody tr.close-total td{
        position:sticky; top:34px; z-index:3; box-shadow:inset 0 -1px 0 rgba(255,255,255,.3); }
    </style>
    <!-- ===== 출고내역 (출고장 정산 엑셀 TBL_SALES_MST + 발주현황표 출고 TBL_SHIPOUT_MST 통합) ===== -->
    <section id="panel-outHist" class="panel">
      <!-- 상단은 한 줄로 — 제목줄 + 조회줄 + 탭줄만. 설명은 전부 hover(title)로 뺐다 -->
      <div class="logi-head" style="margin-bottom:8px">
        <%-- 화면 제목 = 일자별/품목별 납품실적 조회 (2026-08-02 요청).
             좌측 메뉴 라벨은 '매출내역' 그대로 둔다 — 메뉴 폭과 익숙한 이름을 건드리지 않기 위해서다. --%>
        <div><h2 style="margin:0">일자별/품목별 납품실적 조회 <span class="badge b-done">정산</span>
          <span style="font-size:12px;font-weight:400;color:#9aa7b3;margin-left:6px">정산서(받을 금액) × 발주현황표 출고내역</span></h2></div>
        <%-- [📥 정산 엑셀] 버튼은 판매등록 화면으로 옮겼다(2026-08-01 요청) — 매출을 넣는 자리에서 같이 올리도록.
             파일 input(#slsFile)과 확인·저장 팝업은 여기 그대로 두고, 판매등록이 konetSlsExcelPick() 로 부른다.
             저장 대기 칩은 남긴다 — 저장 안 하고 닫은 파일을 이 화면에서 이어서 처리할 수 있어야 한다. --%>
        <div class="actions">
          <button class="btn-line" id="slsUpChip" onclick="slsUpOpen()" style="display:none" title="저장 대기 중인 파일이 있습니다. 눌러서 확인·저장하세요."></button>
          <span style="font-size:12px;color:#9aa7b3">정산서 가져오기는 <b>매출 관리 ▸ 판매 등록</b> 화면에 있습니다</span>
        </div>
      </div>
      <div class="card" style="padding-top:10px; padding-bottom:10px">
        <input type="file" id="slsFile" accept=".xlsx,.xls" multiple style="display:none" onchange="slsUpload(this)">
        <div class="form-row" style="margin-bottom:0; align-items:flex-end">
          <div class="fld" style="flex:0 0 150px"><label>납품일자(시작)</label><input type="date" id="slsFrom" onchange="ohRangeSync()"></div>
          <div class="fld" style="flex:0 0 150px"><label>납품일자(종료)</label><input type="date" id="slsTo" onchange="ohRangeSync()"></div>
          <%-- 기간 빠른 선택 (2026-07-27) — 당일 / 1주일 / 해당월(1일~오늘).
               ★'직접 입력' 버튼은 제거했다(2026-07-27 요청) — 날짜칸을 마우스로 고르면 되고,
                 고치는 순간 ohRangeSync 가 자동으로 직접입력 모드('c')로 내려 버튼 강조를 푼다. --%>
          <div class="fld" style="flex:0 0 auto"><label>기간</label>
            <div style="display:flex; gap:4px">
              <button type="button" class="btn-line" id="ohRgD" style="height:36px; padding:0 12px" onclick="ohRange('d')" title="오늘 하루만 (납품일자 = 오늘). 진입 시 기본값입니다. 누르면 바로 조회합니다.">당일</button>
              <button type="button" class="btn-line" id="ohRgW" style="height:36px; padding:0 12px" onclick="ohRange('w')" title="오늘 포함 최근 7일 (오늘−6일 ~ 오늘). 누르면 바로 조회합니다.">1주일</button>
              <button type="button" class="btn-line" id="ohRgM" style="height:36px; padding:0 12px" onclick="ohRange('m')" title="이번 달 1일 ~ 오늘 (말일까지가 아니라 오늘까지). 누르면 바로 조회합니다.">해당월</button>
            </div>
          </div>
          <div class="fld" style="flex:0 0 190px"><label>출고장</label>
            <!-- 대시보드(데시보드1)와 같은 드롭다운 체크박스 다중선택. 묶음(오산센터)·개별 둘 다 고를 수 있다 -->
            <div class="ohdc-wrap" id="ohDcWrap">
              <button type="button" class="btn-line" id="ohDcBtn" onclick="ohDcOpen(event)" title="출고장을 하나 이상 선택하여 조회합니다. 아무것도 안 고르면 전체입니다.">
                <span>🏬</span><span class="arr"><b id="ohDcLbl">전체</b> ▾</span></button>
              <div class="ohdc-pop" id="ohDcPop"></div>
            </div>
          </div>
          <div class="fld" style="flex:0 0 170px"><label>품목코드/품목명</label><input type="text" id="slsItemCd" placeholder="전체 (부분검색)"></div>
          <div class="fld" style="flex:0 0 90px"><button class="btn-teal" style="width:100%" onclick="ohQuery()">조회</button></div>
          <div class="fld" style="flex:0 0 auto; margin-left:auto">
            <span class="tipx" title="[관점 환산] 엑셀은 출고장 기준이라 우리 기준으로 뒤집어 담습니다.&#10;  입고량→우리 출고량 · 단가→우리 판매단가 · 매입금액→우리 매출액 · 입고일자→우리 출고일자&#10;  ※ 엑셀의 '매입금액'은 우리 매입이 아닙니다(우리 매입가는 상품관리가 담당).&#10;&#10;[읽는 규칙] 품목코드 없는 행(합계행)은 제외 · 발주번호 병합셀은 위 값 승계 · 수량은 소수/음수 보존 · 납품일자는 엑셀 값, 출고장만 파일명에서 인식.&#10;&#10;[저장 단위] (납품일자+출고장) 1배치. 같은 배치를 다시 올리면 기존 자료를 이력마감한 뒤 새로 적재(이전 자료는 이력으로 남음).&#10;&#10;[판매단가 이력] 저장 시 판매가 이력에도 반영(적용일자=납품일자=납기일자) → 매출마감 출고단가가 (마스터) 대신 (이력) 확정가로 잡힘. 같은 품목·같은 날 단가가 다르면 건너뜀.&#10;&#10;[조회기간] 진입 시=당일(오늘 하루) / 엑셀 업로드 시=납품일자가 속한 달 전체.&#10;  · 기간 버튼 — 당일 / 1주일(오늘 포함 최근 7일) / 해당월(1일~오늘, 말일 아님)&#10;  · 누르는 즉시 조회합니다. 그 밖의 기간은 날짜칸을 직접 고른 뒤 [조회]를 누르세요(버튼 강조가 자동으로 풀립니다).&#10;&#10;[기간 기준] 납품일자(=납기일자)로 양쪽을 맞춥니다. 출고내역은 출고일자로만 조회되는데 먼 지역이 하루 당겨 출고하므로, 앞뒤 한 달을 넉넉히 읽어 납기일자로 다시 걸러 정산과 같은 기간으로 맞춥니다.&#10;&#10;[대사 규칙] ★납기일자 + 출고장 + 품목코드 로 짝을 맞춥니다(합계 대 합계).&#10;  · 출고는 사업장이 여럿이면 자동으로 합쳐집니다(정산서에 사업장 칸이 없음).&#10;  · 짝 없는 출고 = 미정산(보냈는데 청구 안 됨) / 짝 없는 정산 = 출고미상(보낸 적 없는데 청구됨).&#10;  · 발주번호는 키로 쓰지 않습니다(참고 표시만) — 발주현황표에 비어 있는 행이 있고(2026-07 실측 4,184행 중 424행),&#10;    발주번호로 대사하면 매칭률이 88%→82%로 오히려 떨어집니다. 발주번호로만 짝이 맞는 금액은 0원이었습니다.">ℹ️ 도움말</span>
          </div>
        </div>
        <div class="close-tabs" id="ohTabs" style="margin:6px 0 0">
          <button type="button" class="ctab on" data-t="dc"     onclick="ohTab('dc')" title="원천: 정산서 ∪ 출고내역(합집합) — 한쪽만 있어도 줄이 생깁니다.&#10;한 줄 = 출고장 1곳. 왼쪽 「출고건수·출고수량」=발주현황표 / 오른쪽 「정산행수·정산수량·평균단가·정산금액」=정산서.&#10;&#10;★출고장 줄을 클릭하면 ② 품목 탭으로 넘어가 그 출고장만 펼쳐 보여줍니다 — 차이가 난 품목을 바로 찾을 때.">🏭 출고장별 합계</button>
          <button type="button" class="ctab"    data-t="item"   onclick="ohTab('item')" title="원천: 정산서 ∪ 출고내역(합집합) · 품목축&#10;①에서 난 차이가 어느 품목 때문인지 찾습니다. 출고장 머리행을 눌러 접기/펼치기.">🧾 출고장 ▸ 품목</button>
          <button type="button" class="ctab ctab-red" data-t="gap" onclick="ohTab('gap')" title="정산서가 왔는데 출고수량과 정산수량이 다른 품목만 모아 봅니다(2026-07-27 요청).&#10;· 정산서가 아직 안 온 건은 '차이'가 아니라 미정산이라 여기 안 나옵니다 — ①탭 상태 칸에서 보세요.&#10;· 차이가 큰 것부터 정렬되고, 출고장 소계(통합)도 함께 나옵니다.&#10;· 수량차이 = <b>정산수량 − 출고수량</b>  ( + 정산이 많음 = 과청구·출고기록 누락 후보 / − 출고가 많음 = 청구 누락 후보 )&#10;  ※ ①②③탭의 수량차이는 반대 방향(출고−정산)입니다.&#10;· 품목코드 앞 화살표(▶)를 누르면 <b>정산서 원본행 + 출고 원본행</b>이 펼쳐집니다.&#10;★대사는 <b>납품일자</b>만 비교합니다. 출고일자는 정산서와 출고장이 다를 수 있어 비교하지 않습니다&#10;   — 코네트에서 <b>김해·제주는 멀어서 미리 출고</b>하기 때문입니다(정상). 화면에서도 참고용(회색 괄호)으로만 보여 줍니다.">⚠️ 수량차이 품목</button>
          <button type="button" class="ctab"    data-t="ship"   onclick="ohTab('ship')" title="원천: 출고내역(발주현황표) · 사업장축 · 출고수량 전용&#10;어느 점포로 얼마나 나갔나. 사업장 줄을 누르면 출고 원본행이 펼쳐집니다.&#10;&#10;※ 사업장별 정산금액은 만들지 않습니다.&#10;   정산서에 사업장 칸이 없어 쪼개면 추정이 되기 때문입니다.&#10;   금액은 ①출고장별 합계 · ②출고장▸품목 에서 보세요.&#10;&#10;맨 오른쪽 「정산 대사」는 배분이 아니라 사실입니다 —&#10;   대사됨: 이 행의 납기일자·출고장·품목코드가 정산서에 있음&#10;   미정산: 보냈는데 정산서에 없음(청구 누락 후보)">🏢 출고장 ▸ 사업장</button>
          <button type="button" class="ctab"    data-t="settle" onclick="ohTab('settle')" title="원천: 정산서(TBL_SALES_MST) 단독&#10;출고장이 보낸 엑셀 원본 행 그대로. 「출고수량」 한 열만 대사로 붙였습니다.">📋 정산서 원본(엑셀)</button>
          <span style="margin-left:auto"></span>
          <button type="button" class="btn-line" id="ohAllBtn" style="height:30px;margin-bottom:2px" onclick="ohToggleAll()">⊟ 전체 접기</button>
        </div>
        <div class="close-summary" id="ohSum" style="margin:3px 0 2px; line-height:1.35">기간·출고장을 지정하고 [조회]를 누르세요. (비우면 전체)</div>
        <div id="ohWrap"></div>
        <div class="close-pager" id="ohPager"></div>
      </div>
    </section>


    <%-- ===== 정산실적 (2026-08-02 요청) =====================================
         출고장이 준 정산서 원본(TBL_SALES_MST)을 일자별·품목별로 그대로 펴서 보는 화면.
         ★JS 는 전부 /js/winct/logi-oh.js 에 있다 — 이 JSP 에 스크립트를 넣지 말 것.
           이 파일은 _jspService() 65,535 바이트 한계에 걸려 한 번 죽은 적이 있다(2026-08-02).
         ★조회는 selectSalesMst 하나만 쓴다(발주량·입고량·정산수량·납품유형이 이미 그 안에 있다). --%>
    <section id="panel-settlePerf" class="panel">
      <div class="logi-head" style="margin-bottom:8px">
        <%-- 제목은 거래처(웰스토리) 화면과 같은 문구로 맞춘다(2026-08-02 요청) — 담당자끼리 같은 이름으로 부르게. --%>
        <div><h2 style="margin:0">일자별/품목별 납품실적조회(발주번호) <span class="badge b-done">정산서 원본</span>
          <span style="font-size:12px;font-weight:400;color:#9aa7b3;margin-left:6px">발주량 · 입고량 · 정산수량 · 납품유형 · 매입금액</span></h2></div>
      </div>
      <div class="card" style="padding-top:10px; padding-bottom:10px">
        <div class="form-row" style="margin-bottom:0; align-items:flex-end">
          <div class="fld" style="flex:0 0 150px"><label>납품일자(시작)</label><input type="date" id="spFrom"></div>
          <div class="fld" style="flex:0 0 150px"><label>납품일자(종료)</label><input type="date" id="spTo"></div>
          <div class="fld" style="flex:0 0 auto"><label>기간</label>
            <div style="display:flex; gap:4px">
              <button type="button" class="btn-line" style="height:36px; padding:0 12px" onclick="spRange('d')">당일</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 12px" onclick="spRange('w')">1주일</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 12px" onclick="spRange('m')">해당월</button>
            </div>
          </div>
          <%-- 출고장 다중선택 — 대시보드·매출내역과 같은 드롭다운 체크박스(묶음/개별 둘 다 선택).
               ★스타일(.ohdc-wrap/.ohdc-pop)은 매출내역 것을 그대로 쓰고, 동작만 이 화면 전용(spDc*)이다.
                 상태를 공유하면 한 화면의 선택이 다른 화면 조회까지 바꾼다. --%>
          <div class="fld" style="flex:0 0 205px"><label>출고장</label>
            <div class="ohdc-wrap" id="spDcWrap">
              <button type="button" class="btn-line" id="spDcBtn" onclick="spDcOpen(event)" title="출고장을 하나 이상 골라 거릅니다. 아무것도 안 고르면 전체입니다.">
                <span>🏬</span><span class="arr"><b id="spDcLbl">전체</b> ▾</span></button>
              <div class="ohdc-pop" id="spDcPop"></div>
            </div>
          </div>
          <div class="fld" style="flex:0 0 200px"><label>품목코드/품목명</label>
            <input type="text" id="spItem" placeholder="전체 (부분검색)" onkeydown="if(event.keyCode===13)spLoad()"></div>
          <div class="fld" style="flex:0 0 130px"><label>납품유형</label>
            <select id="spType" onchange="spRender()">
              <option value="">전체</option><option value="납품">납품</option><option value="반품">반품</option>
            </select></div>
          <div class="fld" style="flex:0 0 90px"><button class="btn-teal" style="width:100%" onclick="spLoad()">조회</button></div>
        </div>
      </div>
      <%-- 머리글이 두 줄로 접히지 않게 — 칸이 17개라 규격·품목명이 길면 헤더가 밀려 두 줄이 된다.
           긴 값은 말줄임(…)으로 자르고 전체 내용은 hover 로 본다(2026-08-02 요청). --%>
      <style>
        /* ★스크롤 컨테이너 — 이게 없으면 lzMount 의 '스크롤하면 이어서 나옴'이 동작하지 않는다.
             lzMount 는 wrap 에 scroll 이벤트를 걸고 wrap.scrollTop 으로 판단하는데,
             overflow 가 없으면 스크롤이 아예 안 생겨 안내만 뜨고 다음 행이 영영 안 붙는다(2026-08-02 지적).
             값은 매출내역 #ohWrap 과 같게 맞춘다. */
        #spWrap{ max-height:calc(100vh - 214px); min-height:240px; overflow:auto; }
        /* 스크롤해도 머리글은 남아야 한다 — 매출내역 #ohWrap 과 같은 규칙 */
        #spWrap table.logi-tb thead th{ white-space:nowrap; position:sticky; top:0; z-index:2;
                                        box-shadow:inset 0 -1px 0 var(--logi-border); }
        /* 자료줄도 한 줄로 — 날짜(2026-07-30)·출고장(광주)이 칸이 좁아 두 줄로 접히던 것을 막는다(2026-08-02).
           품목명·규격만 아래에서 폭을 제한하고 말줄임 처리한다. */
        #spWrap table.logi-tb tbody td{ white-space:nowrap; }
        #spWrap table.logi-tb td.sp-spec{ max-width:120px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        #spWrap table.logi-tb td.sp-nm{ max-width:240px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
      </style>
      <div class="card">
        <%-- [전체 접기/펼치기] 는 매출내역(#ohAllBtn)과 **같은 자리** — 요약줄 오른쪽 끝(2026-08-02 요청).
             종전에는 총합계 줄 안에 넣었는데, 화면마다 위치가 다르면 찾느라 헤맨다. --%>
        <div style="display:flex; align-items:center; gap:10px">
          <span class="close-summary" id="spSum" style="margin:0">[조회]를 누르세요.</span>
          <span style="margin-left:auto"></span>
          <button type="button" class="btn-line" id="spAllBtn" style="height:30px" onclick="spAllToggle()">⊟ 전체 접기</button>
        </div>
        <div id="spWrap" style="margin-top:6px"></div>
        <div class="close-pager" id="spPager"></div>
      </div>
    </section>
    <!-- ===== 마감관리 : 매출마감 ===== -->
    <section id="panel-closeSales" class="panel">
      <div class="logi-head">
        <div><h2>매출마감 <span class="badge b-done">마감관리</span></h2>
          <div class="sub">출고(매출) 자료 기준 월 매출을 품목·사업장별로 집계·확정합니다.</div></div>
        <div class="actions">
          <button class="btn-teal" onclick="closeLoad('sales')">🧮 매출 집계(조회)</button>
          <button class="btn-line" id="confBtn_sales" onclick="closeConfirmScreen('sales')">🔒 마감 확정</button>
          <button class="btn-line" id="canBtn_sales" onclick="closeCancelScreen('sales')" style="display:none">🔓 확정 해제</button>
        </div>
      </div>
      <div class="card">
        <div class="form-row">
          <div class="fld" style="flex:0 0 150px"><label>마감월</label><input type="month" id="closeSalesYm" onchange="salesYmSync()"></div>
          <div class="fld" style="flex:0 0 160px"><label>시작일자</label><input type="date" id="closeSalesFrom"></div>
          <div class="fld" style="flex:0 0 160px"><label>종료일자</label><input type="date" id="closeSalesTo"></div>
          <div class="fld" style="flex:0 0 110px; align-self:flex-end"><button class="btn-teal" style="width:100%" onclick="closeLoad('sales')">조회</button></div>
          <div class="fld" style="align-self:flex-end; margin-left:auto">
            <span class="tipx" title="[매출액 계산] 정산서(출고장이 준 청구금액) 우선 → 정산서가 아직 안 온 건만 판매단가로 계산합니다.&#10;총 매출액이 매출내역 화면과 항상 일치합니다(같은 기간으로 조회했을 때).&#10;&#10;[근거 배지 — 매출액이 어디서 왔나]&#10;  · 정산      = 정산서 금액이 이 줄 하나로 통째로 들어감. 표시 단가는 매출액÷출고수량 역산값&#10;                (정산수량과 출고수량이 다르면 정산서 단가와 달라 보입니다)  ★★★ 확정&#10;  · 정산안분  = 그 키의 출고가 여러 줄로 나뉘어(주로 사업장이 여러 곳) 정산금액을 출고수량 비율로 배분.&#10;                정산서엔 사업장 칸이 없어(발주 단위) 불가피합니다. 출고장별 탭에서는 합쳐져 정산서 금액과 일치.&#10;                출고수량 합이 0인 키(반품 상쇄)는 행수로 균등 배분.  ★★☆ 확정(배분)&#10;  · 이력      = 정산서 미도착. 판매단가 이력(적용일 ≤ 납품일자 중 최신, 공통가만)으로 계산한 추정  ★☆☆&#10;  · 마스터    = 정산서도 단가 이력도 없음 → 상품마스터 판매가. 마스터에도 없으면 0원  ☆☆☆ 가장 약함&#10;  · 출고미상  = 정산서엔 있는데 출고 자료가 없는 건. 매출액은 정산서 확정, 수량은 정산서 OUT_QTY,&#10;                매입액만 추정(정산수량×매입단가). 발주현황표를 올리면 정상 줄로 흡수됩니다&#10;&#10;[매입단가 배지] 대상이 매입가라 별개입니다 — 이력 / 마스터 / 추정(출고미상 줄). 매입엔 '정산'이 없습니다.&#10;&#10;[기간 귀속] 납품일자(DLV_DT) 기준 — 매출내역과 동일합니다. 정산서에는 출고일자가 없어 출고일자로 귀속하면 월 경계에서 어긋납니다.&#10;&#10;[출고장] 대시보드1 물류센터 그룹(왜관·김해·광주·제주·오산 → 오산센터).&#10;&#10;[검색] 품목코드/품목명 검색은 3탭 공통이며 합계·소계도 검색 결과 기준으로 다시 집계됩니다.">ℹ️ 도움말</span>
          </div>
        </div>
        <div class="close-tabs" id="salesTabs">
          <button type="button" class="ctab on" data-t="zone" onclick="salesTab('zone')">🗂️ 출고장별 품목코드</button>
          <button type="button" class="ctab"    data-t="biz"  onclick="salesTab('biz')">🏢 사업장별 품목코드</button>
          <button type="button" class="ctab"    data-t="item" onclick="salesTab('item')">📦 품목코드</button>
          <span style="margin-left:auto"></span>
          <input type="search" class="cq" id="salesQ" placeholder="🔎 품목코드 / 품목명 검색" title="세 탭(출고장별·사업장별·품목코드) 모두에 적용됩니다. Esc = 검색 해제" oninput="salesSearch()" onkeydown="if(event.key==='Escape'){ this.value=''; salesSearch(); }">
          <button type="button" class="btn-line" id="salesAllBtn" style="height:30px;margin-bottom:2px" onclick="salesToggleAll()">⊟ 전체 접기</button>
        </div>
        <div class="close-summary" id="closeSalesSum">마감월/기간을 선택하고 [조회]를 누르세요.</div>
        <div id="closeSalesWrap"></div>
        <div class="close-pager" id="closeSalesPager"></div>
        <div class="note">※ 매출마감 매출액 = <b>정산서(출고장이 준 청구금액) 우선</b>, 정산서가 아직 안 온 건만 <b>판매단가</b>(이력 우선·없으면 상품마스터)로 계산합니다. 근거는 각 행에 <b>(정산)</b>·<b>(정산안분)</b>·<b>(이력)</b>·<b>(마스터)</b> 로 표시됩니다. 정산서에는 사업장이 없어(발주 단위) 사업장별 탭의 정산금액은 출고수량 비율로 <b>안분</b>한 값입니다 — 출고장별 탭에서는 다시 합쳐져 정산서 금액과 일치합니다. 정산서에는 있는데 <b>출고 자료가 없는 건</b>도 매출에 포함하며(<b>(출고미상)</b> 표시, 수량·매입액은 정산서 기준 추정), 그래서 <b>총 매출액이 매출내역 화면과 항상 일치</b>합니다. 기간 귀속은 <b>납품일자(DLV_DT)</b> 기준이며 매출내역과 동일합니다. 출고장=대시보드1 물류센터 그룹(오산센터 등). 품목코드/품목명 검색은 3탭 공통이며 합계·소계도 검색 결과 기준으로 다시 집계됩니다.</div>
      </div>
    </section>

    <!-- ===== 마감관리 : 매입마감 ===== -->
    <section id="panel-closeCost" class="panel">
      <div class="logi-head">
        <div><h2>매입마감 <span class="badge b-done">마감관리</span></h2>
          <div class="sub">입고(수불) 자료 기준 당월 입고를 품목별로 집계·확정합니다. (상품관리 ▸ 재고 탭 입고 등록분)</div></div>
        <div class="actions">
          <button class="btn-teal" onclick="closeLoad('cost')">🧮 입고 집계(조회)</button>
          <button class="btn-line" id="confBtn_cost" onclick="closeConfirmScreen('cost')">🔒 마감 확정</button>
          <button class="btn-line" id="canBtn_cost" onclick="closeCancelScreen('cost')" style="display:none">🔓 확정 해제</button>
        </div>
      </div>
      <div class="card">
        <div class="form-row">
          <div class="fld" style="flex:0 0 150px"><label>마감월</label><input type="month" id="closeCostYm" onchange="costYmSync()"></div>
          <div class="fld" style="flex:0 0 160px"><label>시작일자</label><input type="date" id="closeCostFrom"></div>
          <div class="fld" style="flex:0 0 160px"><label>종료일자</label><input type="date" id="closeCostTo"></div>
          <div class="fld" style="flex:0 0 110px; align-self:flex-end"><button class="btn-teal" style="width:100%" onclick="closeLoad('cost')">조회</button></div>
          <div class="fld" style="margin-left:auto; align-self:flex-end"><button class="btn-line" id="costAllBtn" style="height:34px" onclick="costToggleAll()">⊟ 전체 접기</button></div>
        </div>
        <div class="close-summary" id="closeCostSum">마감월/기간을 선택하고 [조회]를 누르세요.</div>
        <div id="closeCostWrap"></div>
        <div class="close-pager" id="closeCostPager"></div>
        <div class="note">※ 매입(입고)마감: 입고 수불원장(TBL_STOCK_LEDGER, 입고)을 매입처·품목별로 집계. 매입단가=매입액÷입고수량(가중평균).</div>
      </div>
    </section>

    <!-- ===== 마감관리 : 재고마감 ===== -->
    <section id="panel-closeStock" class="panel">
      <div class="logi-head">
        <div><h2>재고마감 <span class="badge b-done">마감관리</span></h2>
          <div class="sub">재고 수불원장(TBL_STOCK_LEDGER) 기준 기초+입고−출고±조정=기말 및 이동평균 재고금액.</div></div>
        <div class="actions">
          <button class="btn-teal" onclick="closeLoad('stock')">🧮 재고 집계(조회)</button>
          <button class="btn-line" id="confBtn_stock" onclick="closeConfirmScreen('stock')">🔒 마감 확정</button>
          <button class="btn-line" id="canBtn_stock" onclick="closeCancelScreen('stock')" style="display:none">🔓 확정 해제</button>
        </div>
      </div>
      <div class="card">
        <div class="form-row">
          <div class="fld" style="flex:0 0 150px"><label>마감월</label><input type="month" id="closeStockYm" onchange="stockYmSync()"></div>
          <div class="fld" style="flex:0 0 160px"><label>시작일자</label><input type="date" id="closeStockFrom"></div>
          <div class="fld" style="flex:0 0 160px"><label>종료일자</label><input type="date" id="closeStockTo"></div>
          <div class="fld" style="flex:0 0 110px; align-self:flex-end"><button class="btn-teal" style="width:100%" onclick="closeLoad('stock')">조회</button></div>
        </div>
        <div class="close-tabs" id="stockTabs">
          <button type="button" class="ctab on" data-t="vendor" onclick="stockTab('vendor')">🧾 매입처별 품목코드</button>
          <button type="button" class="ctab"    data-t="item"   onclick="stockTab('item')">📦 품목코드</button>
          <span style="margin-left:auto"></span>
          <button type="button" class="btn-line" id="stockAllBtn" style="height:30px;margin-bottom:2px" onclick="stockToggleAll()">⊟ 전체 접기</button>
        </div>
        <div class="close-summary" id="closeStockSum">마감월/기간을 선택하고 [조회]를 누르세요.</div>
        <div id="closeStockWrap"></div>
        <div class="close-pager" id="closeStockPager"></div>
        <div class="note">※ 재고마감: 기말 = 기초 + 입고(+반품) − 출고 + 조정. <b>기초 = 직전 확정월 기말 이월</b>(직전월 미확정 시 원장 재계산). 재고금액 = 기말 × 이동평균 매입단가. 매입처=해당 기간 최근 입고처.</div>
      </div>
    </section>

    <!-- ===== 마감관리 : 마감현황(월계표) ===== -->
    <section id="panel-closeStatus" class="panel">
      <div class="logi-head">
        <div><h2>마감현황 <span class="badge b-done">월계표</span></h2>
          <div class="sub">월별 매출·매입·마진 요약 + 월 마감 확정/해제(확정 시 해당 월 재고 수불 잠금·기말재고 이월).</div></div>
        <div class="actions">
          <button class="btn-teal" onclick="closeLoad('status')">🧮 집계(조회)</button>
          <button class="btn-line" id="stConfirmBtn" onclick="closeConfirm()">🔒 마감 확정</button>
          <button class="btn-line" id="stCancelBtn" onclick="closeCancel()" style="display:none">🔓 확정 해제</button>
        </div>
      </div>
      <div class="card">
        <div class="form-row">
          <div class="fld" style="flex:0 0 180px"><label>조회월</label><input type="month" id="closeStatusYm" onchange="closeStatusChk()"></div>
          <div class="fld" style="flex:0 0 120px; align-self:flex-end"><button class="btn-teal" style="width:100%" onclick="closeLoad('status')">조회</button></div>
        </div>
        <div id="stStatusBar" style="margin:2px 0 12px;font-size:13px;font-weight:700;color:#6b7a89">마감 상태: 미확정</div>
        <div class="kpi-row">
          <div class="kpi"><div class="k-lbl">매출액</div><div class="k-val" id="stKpiSales">- <small>원</small></div></div>
          <div class="kpi"><div class="k-lbl">매입액</div><div class="k-val" id="stKpiCost">- <small>원</small></div></div>
          <div class="kpi"><div class="k-lbl">순마진(매출-매입)</div><div class="k-val" id="stKpiMargin">- <small>원</small></div></div>
          <div class="kpi"><div class="k-lbl">마진율</div><div class="k-val" id="stKpiRate" style="font-size:20px">-</div></div>
        </div>
        <div class="close-tabs" id="statTabs">
          <button type="button" class="ctab on" data-t="zone" onclick="statTab('zone')">🗂️ 출고장별</button>
          <button type="button" class="ctab"    data-t="biz"  onclick="statTab('biz')">🏢 사업장별</button>
          <button type="button" class="ctab"    data-t="item" onclick="statTab('item')">📦 품목별</button>
          <span style="margin-left:auto"></span>
          <button type="button" class="btn-line" id="statAllBtn" style="height:30px;margin-bottom:2px" onclick="statToggleAll()">⊟ 전체 접기</button>
        </div>
        <div class="close-summary" id="closeStatusSum">조회월을 선택하고 [조회]를 누르세요.</div>
        <div id="closeStatusWrap"></div>
        <div class="close-pager" id="closeStatusPager"></div>
        <div class="note">※ 마감현황: 선택 월 출고 자료 기준 매출·매입·순마진·마진율. 출고장별=물류센터 그룹(오산센터 등) 2단, 사업장별=사업장 그룹. 접기/펼치기·페이징 지원.</div>
      </div>
    </section>

    <!-- ===== 업무 설명서 ===== -->
    <section id="panel-guide" class="panel">
      <div class="logi-head"><div><h2>📖 업무 설명서 <span class="badge b-done">도움말</span></h2>
        <div class="sub">좌측 메뉴 순서대로 한 줄씩. 화면별 자세한 규칙은 각 화면의 <b>ℹ️ 도움말</b>에 있습니다.</div></div></div>

      <style>
        #panel-guide .g-sec{ background:#fff; border:1px solid var(--logi-border,#dfe6e3); border-radius:10px; padding:14px 18px; margin-bottom:14px; }
        #panel-guide .g-sec h3{ margin:0 0 4px; font-size:15px; color:#137a6c; }
        #panel-guide .g-sec .gd{ color:#5b6b7a; font-size:12.5px; margin-bottom:10px; }
        #panel-guide table{ width:100%; border-collapse:collapse; font-size:12.5px; }
        #panel-guide th{ background:#f1f5f4; text-align:left; padding:7px 10px; color:#37475a; white-space:nowrap; }
        #panel-guide td{ border-bottom:1px solid #eef1f5; padding:7px 10px; vertical-align:top; }
        #panel-guide td.m{ font-weight:700; color:#1f2a37; white-space:nowrap; }
        /* ★display:block 필수 — 전역 .flow 는 flex(가로 배치)라 여기서 쓰면
           <br> 이 먹지 않고 각 단계가 좌우로 늘어서며 글자가 세로로 접힌다(2026-07-22 수정) */
        #panel-guide .flow{ display:block !important; background:#eef7f4; border-left:4px solid #1f9b8e; border-radius:6px;
                            padding:12px 16px; font-size:12.5px; color:#1f2a37; margin-bottom:14px; line-height:2.1; }
        #panel-guide .flow .fl{ display:block; padding:2px 0; }
        #panel-guide .flow .fl .n{ display:inline-block; min-width:26px; font-weight:800; color:#137a6c; }
      </style>

      <div class="flow"><b>기본 흐름</b> &nbsp;①상품·거래처 등록 → ②입고 등록 → ③발주현황표 업로드(출고) → ④정산서 업로드·대사 → ⑤월말 마감 → ⑥마감 확정(잠금)</div>

      <div class="g-sec">
        <h3>0. 자료가 흐르는 길</h3>
        <div class="gd">입고·출고가 <b>수불원장</b>에 모이고, 재고현황·재고마감은 그 원장 하나만 읽습니다. 마감 확정 때만 그 달 값이 스냅샷으로 굳습니다.</div>
        <div class="flow">
          <span class="fl"><span class="n">[1]</span> <b>입고</b>(상품관리▸재고탭) → 수불원장(입) → <b>현재고▲ · 이동평균단가</b></span>
          <span class="fl"><span class="n">[2]</span> <b>출고</b>(발주현황표 업로드) → 출고자료 → 수불원장(출) → <b>현재고▼</b></span>
          <span class="fl"><span class="n">[3]</span> <b>정산서</b>(출고장이 준 엑셀) → 매출·판매단가 이력 → <b>매출내역에서 [2]와 대사</b></span>
          <span class="fl"><span class="n">[4]</span> <b>재고현황 · 재고마감</b> ← 같은 원장 <span style="color:#5a6b7a">(재고현황 기준일 = 마감월 말일이면 재고마감 기말과 일치)</span></span>
          <span class="fl"><span class="n">[5]</span> 🔒 <b>마감 확정</b> → 기말재고 스냅샷 저장 + 그 달 수불 잠금 <span style="color:#5a6b7a">(다음 달 기초로 이월)</span></span>
        </div>
      </div>

      <%-- ★모든 화면 맨 위에 늘 있는 줄이라 설명서에도 맨 앞에 둔다.
             규칙(7개·대체 없음·자동셋팅 없음)을 고치면 이 칸도 같이 고칠 것. --%>
      <div class="g-sec">
        <h3>0-1. 화면 맨 위 공통 줄</h3>
        <table><tbody>
          <tr><td class="m">⭐ 자주 쓰는 메뉴</td><td>어느 화면에서든 <b>맨 위에 따라다니는</b> 바로가기 줄. 메뉴를 열면 <b>빈 자리에 저절로 담깁니다</b>(최대 <b>7개</b>).
            <div style="margin-top:4px;color:#5a6b7a"><b>· 한 번 담기면 그대로</b> — 7개가 차면 <b style="color:#c0392b">새 메뉴가 옛 메뉴를 밀어내지 않습니다.</b> 바꾸려면 칩의 <b>✕</b>로 직접 내리고, 그 빈자리는 다음에 여는 메뉴가 채웁니다.<br>
            <b>· 처음에는 비어 있습니다</b> — 기본값을 미리 넣어 두지 않습니다(자리가 처음부터 차 있으면 내 메뉴가 들어갈 곳이 없어서).<br>
            <b>· ☆</b> 사이드바 메뉴 오른쪽 끝 별표로 직접 담을 수도 있습니다(담긴 것은 📌). <b>✕ 비우기</b>는 7칸을 통째로 비웁니다.<br>
            <b>· 브라우저에 저장</b>됩니다 — PC·브라우저마다 따로이고, 로그인 계정과는 무관합니다.</div></td></tr>
          <tr><td class="m">◀ 메뉴 접기</td><td>왼쪽 메뉴를 접어 <b>본문을 넓게</b> 씁니다(표가 한 화면에 더 들어옵니다). 접어도 위 <b>자주 쓰는 메뉴</b>로 이동할 수 있습니다. 버튼은 접으나 펴나 <b>같은 자리</b>.</td></tr>
        </tbody></table>
      </div>

      <div class="g-sec">
        <h3>1. 조회·대시보드</h3>
        <table><tbody>
          <tr><td class="m">출고현황표(대시보드)</td><td>발주현황표 엑셀을 올려 <b>출고장·사업장·품목별 출고량</b>을 작성합니다. 매출마감·재고차감의 원천.
            <div style="margin-top:4px;color:#5a6b7a"><b>· 대체 규칙</b> <b style="color:#c0392b">출고장 + 납품일자</b>가 같으면 기존 자료를 대체(출고일자는 보지 않음). 예전 것은 이력으로 내려가니 <b>잘못 올렸으면 다시 올리면</b> 됩니다.<br>
            <b>· [📤 …보기 / 업로드]</b> = 탐색기가 아니라 <b>미리보기</b>가 열려 지정 폴더 파일을 최신순으로 보여줍니다(최근 파일 자동 펼침). 상단에 📂폴더 지정 · 📄파일 선택 · ↻새로고침 · ℹ️도움말.<br>
            <b>· 출고일자</b>는 <b>엑셀의 납기일자</b> 그대로 — <b>출고장(김해·제주 포함) 구분 없이</b> 전 행이 같은 날짜로 저장됩니다(작성 전 화면에서 수정 가능).<br>
            <b>· 김해·제주 알림</b> 파일에 김해·제주 출고장이 있으면 반영 확인창에서 <b>출고일자 변경 여부</b>를 물어봅니다(자동 변경은 안 함 — 필요 시 확인창에서 직접 수정).<br>
            <b>· 이전 자료 알림</b> 마지막에 올린 것보다 출고일자가 앞서면 알려만 주고 <b>막지 않습니다</b>.</div></td></tr>
          <tr><td class="m">출고세부조회</td><td>저장된 출고를 <b>3탭</b>(출고장▸품목 · 사업장별 · 품목별)으로 전환하며 조회.</td></tr>
          <tr><td class="m">출고현황이력조회</td><td>발주현황표를 <b>언제·몇 차로</b> 올렸는지와 그 발생내역을 일자별로.</td></tr>
        </tbody></table>
      </div>

      <div class="g-sec">
        <h3>2. 매출 관리</h3>
        <table><tbody>
          <tr><td class="m">매출내역</td><td><b>출고장이 준 정산서(엑셀)</b> = 우리가 <b>받을 금액</b>. 우리 출고와 나란히 놓고 <b>빠진 게 없는지 대사</b>합니다. 엑셀은 출고장 기준이라 뒤집어 담습니다(<b>입고량→출고량 · 단가→판매단가 · 매입금액→매출액</b>). 저장하면 판매가 이력에도 들어가 매출마감 단가가 <b>실제 확정가</b>가 됩니다.
            <div style="margin-top:4px;color:#5a6b7a"><b>· 4탭</b> ①출고장별 합계(받을 금액·차이·상태) ②출고장▸품목 ③출고장▸사업장(수량만) ④정산서 원본. 모두 물류센터로 묶고 펼치면 개별 출고장.<br>
            <b>· 기간 버튼</b> 당일(기본)·1주일(최근 7일)·해당월(1일~오늘) 은 누르면 바로 조회, 그 밖은 날짜를 고르고 [조회].<br>
            <b>· 짝 맞추기</b> 납기일자+출고장+품목코드(합계 대 합계). 짝 없는 출고=<b style="color:#c0392b">미정산</b>(청구 누락 후보), 짝 없는 정산=<b style="color:#c0392b">출고미상</b>.</div></td></tr>
          <tr><td class="m">판매 등록 / 수금 등록</td><td>정산서 밖의 <b>직접 판매</b> 전표와 <b>수금</b> 전표. 오른쪽에 그 거래처 원장이 함께 뜹니다.</td></tr>
          <tr><td class="m">매출마감</td><td>출고 × <b>납기일자 시점 단가</b> → 매출·매입·순마진. 출고장별(오산센터 등 2단)·사업장별·품목별 3탭, 품목 검색 공통.</td></tr>
          <tr><td class="m">매출 그래프(월별/일자별)</td><td>매출액·매입액·순마진 그래프+표. <b>금액 기준은 마감현황과 동일</b>(매출 = 정산서 + 정산서 없는 출고의 추정 + 직접판매). <b>최근이 왼쪽</b>. <span style="color:#b45309">매입가 미등록 품목은 매입액 0이라 마진이 커 보입니다.</span></td></tr>
        </tbody></table>
      </div>

      <div class="g-sec">
        <h3>3. 매입 · 재고 관리</h3>
        <table><tbody>
          <tr><td class="m">매입 등록 / 지급 등록</td><td>매입 전표와 <b>지급</b> 전표. 오른쪽에 그 거래처 원장이 함께 뜹니다.</td></tr>
          <tr><td class="m">입고내역</td><td>전체 품목 <b>입고 거래 목록</b> — 기간·검색·페이징·합계.</td></tr>
          <tr><td class="m">매입마감</td><td><b>입고 기준</b> 당월 매입을 매입처·품목별로 집계(매입단가 = 가중평균).</td></tr>
          <tr><td class="m">재고현황</td><td>실시간 현재고 = <b>입고 − 출고</b>(수불원장 하나만 봄). <b>기준일</b> 비움=현재고 / 날짜=그날까지 기말 → 마감월 말일로 맞추면 재고마감과 대사. <b>음수</b>면 입고 누락 신호. 품목 행 클릭 → 아래 <b>수불내역</b>(근거). <b>🔄 출고반영 재집계</b>는 과거 보정용으로만.</td></tr>
          <tr><td class="m">재고마감</td><td>기초+입고−출고±조정=<b>기말</b>, 재고금액=기말×이동평균. 기초는 <b>직전 확정월 기말에서 이월</b>.</td></tr>
        </tbody></table>
      </div>

      <div class="g-sec">
        <h3>4. 정보 현황 · 원장관리</h3>
        <table><tbody>
          <tr><td class="m">마감현황(월계표)</td><td>선택 월 매출·매입·순마진 요약(KPI) + <b>🔒 확정 / 🔓 해제</b>. 확정 = 3종 통합 저장 + 기말재고 스냅샷 + 그 달 수불 잠금.</td></tr>
          <tr><td class="m">월별 마감이력</td><td>확정한 달들의 매출·원가·마진·매입·기말재고금액. 행 클릭 → 그 달 마감현황.</td></tr>
          <tr><td class="m">거래처별 채권·채무</td><td>거래처마다 <b>받을금액</b>[(매출−할인)−수금]과 <b>지급할금액</b>[(매입−할인)−지급]. <b>이월 + 당월매출 − 당월수금 = 남은금액</b>, 오른쪽 끝에 <b>특정일자 발생</b> 4칸(그 하루의 매출·수금·매입·지급). 줄 클릭 → 월별 이력 + 아래 <b>건별 내역</b> 4탭.
            <div style="margin-top:4px;color:#5a6b7a">잔액은 <b>전 기간 누계</b>라 기간이 아니라 <b>기준월</b>로 봅니다. <b>특정일자</b>는 발생 4칸과 아래 건별 내역 전용이라 위 잔액을 바꾸지 않습니다 — 누계와 하루를 나란히 두는 것이라 숫자가 다른 게 정상. <b>구분(매입·매출)은 실제 거래로 판정</b>해 등록값과 다르면 별표가 붙습니다(수정은 거래처관리에서). <b>조회 전용.</b></div></td></tr>
          <tr><td class="m">일계장</td><td>고른 <b>하루</b>의 매출·매입·수금·지급을 거래처별로. <b>전일잔액 + 당일매출 − 당일수금 = 잔액</b>. 기본은 그날 움직인 곳만. 인쇄는 화면의 <b>🖨 인쇄</b> 버튼(A4 세로).</td></tr>
        </tbody></table>
      </div>

      <div class="g-sec">
        <h3>5. 기준정보 · 예정 기능</h3>
        <table><tbody>
          <tr><td class="m">상품(품목)관리</td><td>품목 등록/수정. 행 클릭 → 아래 <b>이력/재고</b> 4탭에서 <b>매입가·판매가 이력</b>과 <b>재고 수불(입·출고·조정·반품)</b> 등록.</td></tr>
          <tr><td class="m">기준정보관리</td><td><b>매입/매출 거래처</b>(회계 거래처 · 거래처리스트.xls 재업로드) · <b>거래처관리(사업장)</b>(배송 점포, 발주 업로드 시 자동등록) · 회사/사용자 · 공통코드. <span style="color:#5a6b7a">회사/사용자·공통코드 관리는 <b>관리자 회사</b>(코네트)에만 보입니다.</span></td></tr>
          <tr><td class="m">예정 기능 <span style="color:#9aa7b3;font-size:11px">(데모)</span></td><td>물품동선관리(창고·위치·피킹) · 견적서관리 · 카카오톡관리 — 향후 추진.</td></tr>
        </tbody></table>
      </div>

      <div class="g-sec" style="background:#fff8ee;border-color:#f0d9b5">
        <h3 style="color:#b45309">💡 헷갈리기 쉬운 것</h3>
        <table><tbody>
          <tr><td class="m">출고 자료 대체</td><td><b>출고장 + 납품일자</b>만 같으면 대체됩니다 — <b>출고일자는 기준이 아닙니다.</b></td></tr>
          <tr><td class="m">현재고 vs 기말재고</td><td>재고현황 = 지금 잔량(실시간) / 재고마감 기말 = 그 달 말 시점.</td></tr>
          <tr><td class="m">단가 근거</td><td>단가 <b>이력</b> 우선, 없으면 상품마스터 단가. 각 행에 (이력/마스터) 표시.</td></tr>
          <tr><td class="m">매출 금액이 화면마다 다름</td><td>매출 그래프·마감현황은 <b>정산서 미도착 출고분(추정)</b>까지 포함, <b>채권·채무는 청구 확정분만</b>. 그래서 더 작은 게 정상입니다.</td></tr>
          <tr><td class="m">마감 잠금</td><td>확정된 달은 수불 등록·삭제 차단. 고치려면 <b>확정 해제</b> 먼저.</td></tr>
        </tbody></table>
      </div>
    </section>

    <!-- ===== 마감관리 : 월별 마감이력 ===== -->
    <section id="panel-closeHist" class="panel">
      <div class="logi-head">
        <div><h2>월별 마감이력 <span class="badge b-done">마감관리</span></h2>
          <div class="sub">확정된 월들의 매출·매출원가·순마진·매입·기말재고금액 목록(TBL_CLOSING_MST). 행 클릭 시 그 달 마감현황으로 이동.</div></div>
        <div class="actions"><button class="btn-teal" onclick="closeHistLoad()">↻ 새로고침</button></div>
      </div>
      <div class="card">
        <div class="form-row">
          <div class="fld" style="flex:0 0 140px"><label>년도</label><select id="closeHistYear" onchange="closeHistRender()"><option value="">전체</option></select></div>
        </div>
        <div class="close-summary" id="closeHistSum">[새로고침]을 누르세요.</div>
        <div id="closeHistWrap"></div>
        <div class="note">※ 월별 마감이력: 확정한 달만 나옵니다. 확정 해제한 달은 목록에서 제외됩니다.</div>
      </div>
    </section>

    <!-- ===== 재고현황 (전체 품목 현재고) ===== -->
    <%-- ===== 거래처 코드 점검 (2026-08-01) =====================================================
         코네트 품목은 하나, 거래처 요청 표기는 TBL_PROD_XREF 에 N건. 매핑이 틀리면 반드시 티가 난다 —
         그 신호 네 가지를 한 화면에 모은다. 이 화면은 '보여주기' 전용이고, 고치는 것은
         상품관리 ▸ [🔗 거래처 코드] 탭 또는 업로드 프리뷰의 [연결] 이다. ===================== --%>
    <section id="panel-xrefAudit" class="panel">
      <div class="logi-head" style="margin-bottom:8px">
        <div><h2 style="margin:0">품목코드(매핑) <span class="badge b-done">점검</span>
          <span style="font-size:12px;font-weight:400;color:#9aa7b3;margin-left:6px">거래처가 다른 코드·다른 품명으로 보낸 것이 우리 품목에 제대로 붙었는지</span></h2></div>
        <div class="actions">
          <%-- 구분별 조회 — 한 번에 수백 건이라 '무엇부터 볼지' 를 고를 수 있어야 한다(2026-08-01 요청).
               서버를 다시 부르지 않고 받아 둔 자료에서 거른다. --%>
          <select id="xaGb" onchange="xaDraw()" style="border:1px solid var(--logi-border);border-radius:6px">
            <option value="">구분 전체</option>
            <option value="① 미매핑">① 미매핑 (상품마스터에 없음)</option><option value="① 재집계">① 재집계 대기 (코드는 있음)</option><option value="②">② 단가 이탈</option>
            <option value="③">③ 연결 처리됨</option><option value="④">④ 재고 음수</option>
          </select>
          <input id="xaFind" placeholder="코드·품명 검색" oninput="xaDraw()" autocomplete="off"
                 style="width:170px;border:1px solid var(--logi-border);border-radius:6px">
          <select id="xaDays" onchange="xaLoad()" style="border:1px solid var(--logi-border);border-radius:6px">
            <option value="7">최근 7일</option><option value="30" selected>최근 30일</option><option value="90">최근 90일</option><option value="3650">전체</option>
          </select>
          <button class="btn-line" onclick="xaCollapseAll()" title="펼쳐 놓은 후보 목록을 모두 접습니다">⌃ 모두 접기</button>
          <button class="btn-line" id="xaHelpBtn" onclick="xaHelp()">ℹ️ 도움말</button>
          <button class="btn-teal" onclick="xaLoad()">↻ 새로고침</button>
        </div>
      </div>
      <div class="card" style="padding-top:12px">
        <%-- 긴 설명은 도움말로 접어 둔다(2026-08-01) — 본문에 문단이 쌓이면 오히려 헷갈린다는 지적.
             화면에는 한 줄만 두고, 자세한 것은 ℹ️ 도움말. --%>
        <div style="font-size:12.5px;color:#5a6b7a;margin-bottom:6px">
          <b style="color:#c0392b">① 미매핑</b> → <b>[연결 ▾]</b> →
          <b style="color:#137a6c">③ 연결 처리됨</b> <span style="color:#9aa7b3">(재고 정상)</span> → <b>[확인]</b> → 목록에서 빠짐
          <span style="color:#9aa7b3;margin-left:10px">자세한 설명은 <b>ℹ️ 도움말</b></span>
        </div>
        <div id="xaHelp" style="display:none; margin-bottom:8px; padding:11px 14px; background:#f4f8f7;
             border:1px solid #d5e6e2; border-radius:8px; font-size:12.5px; line-height:1.75; color:#37475a">
          <div style="font-weight:700; color:#137a6c; margin-bottom:3px">🔗 품목코드 매핑은 어디서 하나 — 세 군데</div>
          <table style="width:100%; border-collapse:collapse; font-size:12.5px; margin-bottom:9px">
            <thead><tr style="color:#6b7a89">
              <th style="text-align:left; padding:3px 6px; border-bottom:1px solid #d5e6e2; width:230px">화면</th>
              <th style="text-align:left; padding:3px 6px; border-bottom:1px solid #d5e6e2">할 수 있는 일</th>
              <th style="text-align:left; padding:3px 6px; border-bottom:1px solid #d5e6e2; width:150px">저장 시점</th>
            </tr></thead>
            <tbody>
              <tr><td style="padding:3px 6px"><b>여기</b> (품목코드 매핑)</td>
                  <td style="padding:3px 6px">연결 · 확인 · 수정 · 해제 — 행 밑에 후보가 펼쳐집니다</td>
                  <td style="padding:3px 6px"><b>즉시</b></td></tr>
              <tr><td style="padding:3px 6px">상품(품목)관리 ▸ [🔗 거래처 코드]</td>
                  <td style="padding:3px 6px">그 상품에 붙은 표기 관리 · [📥 미매핑에서 고르기]</td>
                  <td style="padding:3px 6px"><b>즉시</b></td></tr>
              <tr><td style="padding:3px 6px">발주현황표 업로드 미리보기</td>
                  <td style="padding:3px 6px">그 파일에서 처음 보는 코드를 그 자리에서 연결</td>
                  <td style="padding:3px 6px"><b>[작성] 누를 때</b><br><span style="color:#9aa7b3">([취소]면 사라짐)</span></td></tr>
            </tbody>
          </table>
          <div style="font-weight:700; color:#137a6c; margin-bottom:3px">구분이 뜻하는 것</div>
          <div><b style="color:#c0392b">① 미매핑</b> 우리 품목을 못 찾음 → <b style="color:#c0392b">재고에서 빠져 있습니다</b>. 가장 급합니다.</div>
          <div><b style="color:#137a6c">③ 연결 처리됨</b> ①을 <b>연결한 결과</b>입니다. 재고도 정상이고, 규격·단가 대조만 남았습니다 — 급하지 않습니다.</div>
          <div><b>② 단가 이탈</b> 정산 단가가 우리 판매가와 10% 이상 차이 — <b>다른 품목에 걸었을 가능성</b>이 있으니 [수정]으로 확인하세요.</div>
          <div><b>④ 재고 음수</b> 매핑 탓일 수도, <b>입고 자료가 없어서</b>일 수도 있습니다. 그래서 여기서는 버튼을 주지 않습니다.</div>
          <div style="margin-top:8px; padding-top:7px; border-top:1px solid #d5e6e2; color:#5a6b7a">
            ⚠️ 거래처는 <b>품명도 자기 식으로</b> 보냅니다 — 후보를 고를 때 이름이 아니라 <b>단가·규격·현재고</b>로 확인하세요.
            재고도 거래도 없는 후보는 흐리게 표시됩니다(예전에 만든 가상코드일 가능성).
          </div>
        </div>
        <div id="xaSum" style="font-size:13px;font-weight:700;margin-bottom:6px">-</div>
        <%-- 화면 아래까지 쓴다 — 종전 56vh 는 표가 짧고 그 아래가 통째로 비었다(2026-08-01 요청).
             머리글은 sticky, 바닥에 닿으면 다음 묶음을 이어붙인다(수백 건을 한 번에 그리면 느리다). --%>
        <%-- 표와 '더 보기' 줄을 한 상자로 묶는다(2026-08-01 요청) — 상자 밖에 떠 있으면
             표와 별개인 것처럼 보이고, 그 사이 여백만큼 화면도 낭비된다. --%>
        <div style="border:1px solid var(--logi-border); border-radius:7px; overflow:hidden">
          <div id="xaWrap" style="height:calc(100vh - 246px); min-height:300px; overflow:auto">
            <table class="tbl" style="width:100%;border-collapse:collapse;font-size:12.5px;white-space:nowrap">
              <%-- 머리글 색·크기는 위 CSS(#xaWrap table thead th)가 준다 — 여기 인라인으로 또 칠하면 안 먹는다 --%>
              <thead><tr style="position:sticky;top:0;z-index:1">
                <th style="width:110px">구분</th><th style="width:120px">거래처 코드</th><th>거래처 품명</th>
                <th style="width:100px">우리 코드</th><th>우리 품명</th>
                <th style="width:100px">출고장</th><th style="width:90px">최근</th><th style="width:70px">건수</th><th>메모</th><th style="width:132px">작업</th>
              </tr></thead>
              <tbody id="xaBody"><tr><td colspan="10" style="text-align:center;color:#8a97a3;padding:14px">[새로고침]을 누르세요.</td></tr></tbody>
            </table>
          </div>
          <div id="xaPager" style="padding:6px 8px; text-align:center; min-height:22px; font-size:12.5px; color:#5a6b7a; background:#fafcfd; border-top:1px solid var(--logi-border)"></div>
        </div>
      </div>
    </section>

    <section id="panel-stockStatus" class="panel">
      <!-- 상단은 제목줄 + 조회줄 2줄만. 설명·경고는 전부 hover(title)로 뺐다 -->
      <div class="logi-head" style="margin-bottom:8px">
        <div><h2 style="margin:0">재고현황 <span class="badge b-done">현재고</span>
          <span style="font-size:12px;font-weight:400;color:#9aa7b3;margin-left:6px">입고(수불원장) − 출고(SHIPOUT) · 실시간 자동갱신</span></h2></div>
        <div class="actions">
          <button class="btn-line" onclick="stkRebuild()" title="※ 평소에는 누를 필요가 없습니다.&#10;수불/출고 등록 시 실시간으로 자동집계되기 때문입니다.&#10;&#10;과거 SHIPOUT 최초 반영·보정 등 부득이한 경우에만 실행하세요.&#10;(마감 확정된 달은 제외됩니다)">🔄 출고반영 재집계</button>
          <button class="btn-teal" onclick="stkStatusLoad()">↻ 새로고침</button>
        </div>
      </div>
      <%-- ★조회줄 라벨을 뺐다 (2026-08-07 요청) — 칸마다 무슨 값인지는 placeholder·툴팁으로 알 수 있고,
             라벨 한 줄이 사라진 만큼 아래 ①표가 위로 올라와 자료가 더 보인다.
             라벨이 없어져도 뜻이 흐려지지 않게 placeholder 를 '검색어' → '품목코드/품목명 검색' 으로 늘렸다. --%>
      <%-- id 는 ②의 [위로 넓히기] 가 이 카드를 통째로 접기 위해 쓴다 (2026-08-07) --%>
      <div class="card" id="stkTopCard" style="padding-top:8px">
        <div class="form-row" style="margin-bottom:0; align-items:center">
          <div class="fld" style="flex:0 0 300px"><div style="position:relative">
              <input id="stkSrch" placeholder="품목코드/품목명 검색" title="품목코드 또는 품목명으로 찾습니다. Enter 로 조회." onkeyup="if(event.keyCode===13)stkStatusLoad()" oninput="stkSrchTog()" style="width:100%;padding-right:30px">
              <%-- 검색어가 걸려 있을 때만 뜨는 지우개. "일부만 보이는 상태"에서 전체로 돌아오는 길을
                   한 번에 만들어 준다 — 칸을 손으로 비우고 다시 [조회]를 누르는 건 두 단계다. --%>
              <button type="button" id="stkSrchClr" onclick="stkSrchClear()" title="검색어를 지우고 전체를 다시 봅니다"
                      style="display:none;position:absolute;right:5px;top:50%;transform:translateY(-50%);
                             width:22px;height:22px;line-height:20px;padding:0;border:1px solid #cfd8e3;border-radius:11px;
                             background:#fff;color:#8a97a4;cursor:pointer;font-size:13px;font-weight:800">✕</button>
            </div></div>
          <div class="fld" style="flex:0 0 170px"><input type="date" id="stkAsOf" onchange="stkStatusLoad()" title="기준일 — 비우면 지금 현재고, 날짜를 넣으면 그날까지의 기말 재고"></div>
          <%-- 날짜를 매번 달력에서 고르는 게 번거로워 빠른 선택을 붙였다(2026-08-01).
               [전체]=비움(지금 현재고) · [오늘]·[전월말]=그 시점 재고 --%>
          <%-- ★버튼 폭을 flex:1 로 나눠 주면 '전월말' 이 세 글자라 칸이 모자라 글자가 세로로 쪼개진다(2026-08-01 지적).
                 내용만큼만 차지하게 두고 white-space:nowrap 으로 줄바꿈을 막는다. --%>
          <div class="fld" style="flex:0 0 auto">
            <%-- ★체크와 버튼을 같은 flex 줄에 둔다 (2026-08-06 지적) — 따로 .fld 로 두면
                   글자 높이가 달라 체크만 살짝 위로 떠 보인다. 같은 줄이면 어긋날 수가 없다.
                 매칭코드 체크는 다시 조회하지 않는다 — 받아 둔 목록을 화면에서 거를 뿐이라 즉시 바뀐다. --%>
            <div style="display:flex; gap:4px; align-items:center">
              <label style="display:flex;align-items:center;gap:5px;height:34px;margin-right:8px;white-space:nowrap;cursor:pointer;font-size:13px;font-weight:700;color:#37475a"
                     title="매칭코드(또는 주코드)가 등록된 품목만 보여 줍니다. 조회를 다시 하지 않고 화면에서만 거릅니다.">
                <input type="checkbox" id="stkOnlyAlias" onchange="stkStatusRender()" style="width:15px;height:15px;cursor:pointer">
                매칭코드 있는 것만
              </label>
              <button class="btn-line" style="white-space:nowrap; padding:0 12px" onclick="stkAsOfClear()" title="기준일을 비웁니다 — 지금 이 순간의 재고">전체</button>
              <button class="btn-line" style="white-space:nowrap; padding:0 12px" onclick="stkAsOfSet(0)" title="오늘 자정까지 반영된 재고">오늘</button>
              <button class="btn-line" style="white-space:nowrap; padding:0 12px" onclick="stkAsOfSet(-1)" title="지난달 말일 기준 재고 — 월말 재고 확인용">전월말</button>
            </div>
          </div>
          <div class="fld" style="flex:0 0 90px"><button class="btn-teal" style="width:100%" onclick="stkStatusLoad()">조회</button></div>
          <div class="fld" style="flex:0 0 auto; margin-left:auto">
            <span class="tipx" title="[현재고] = 입고(I·R·A) − 출고(O). 수불원장(TBL_STOCK_LEDGER) 단일 소스라 재고마감과 같은 값입니다.&#10;출고는 발주현황표 저장 시 원장에 자동 기록되므로 따로 넣지 않아도 됩니다.&#10;&#10;[기준일] 비우면 전체(=지금 현재고) / 날짜를 넣으면 그날까지의 기말.&#10;  → 마감월 말일로 맞추면 재고마감 기말과 대사됩니다.&#10;&#10;[음수 현재고] 입고 없이 출고만 있다는 뜻 = 입고 누락 신호입니다(오류가 아니라 알림).&#10;&#10;[② 수불 내역] ① 표에서 품목 행을 클릭하면 그 품목을 이루는 개별 입·출고 거래가 아래에 나옵니다.">ℹ️ 도움말</span>
          </div>
        </div>
        <!-- ① 제목 · 요약 · 상태를 한 줄에. stkStatusSum 은 JS가 통째로 덮어쓰므로 형제로 분리해 둔다 -->
        <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin:10px 0 4px">
          <span style="font-weight:800;font-size:13.5px;color:#1f2a37;border-left:4px solid var(--logi-teal);padding-left:9px;white-space:nowrap">① 품목별 현재고</span>
          <%-- ★기준일 표시를 제목 바로 옆으로 (2026-08-01 지적) — 오른쪽 끝에 두니 화면이 좁을 때
               잘려서, 지금 보고 있는 게 '현재고'인지 '과거 어느 시점'인지 알 수 없었다. --%>
          <b id="stkAsOfLbl" style="font-size:12.5px;color:#178074;white-space:nowrap">전체 (현재고)</b>
          <span class="close-summary" id="stkStatusSum" style="margin:0">[조회] 또는 [새로고침]을 누르세요.</span>
          <%-- 매칭코드 하위 행 일괄 접기/펼치기 (2026-08-07 요청) — 매칭이 여럿인 품목은
               한 줄이 다섯 줄까지 늘어나 목록을 훑기 어렵다. 줄마다 ▼ 로도 접을 수 있다. --%>
          <button class="btn-line" id="stkExpBtn" onclick="stkExpToggleAll()" style="height:24px;padding:0 9px;font-size:12px;white-space:nowrap"
                  title="매칭코드 하위 줄을 한꺼번에 접거나 펼칩니다. 줄마다 있는 ▼ 로 하나씩도 됩니다.">▼ 매칭 접기</button>
          <span style="margin-left:auto;font-size:11.5px;color:#9aa7b3;white-space:nowrap">
            집계 <b id="stkStamp" style="color:#178074">—</b> · 행 클릭 → ② 수불내역
          </span>
        </div>
        <%-- ★높이를 두 줄만큼 줄였다 (2026-08-06 요청) — 그만큼 아래 ②수불내역이 올라온다.
               한 줄 ≈ 34px 라 68px 를 미리 뺀다. 줄 수가 아니라 높이만 줄이므로
               목록 자체는 그대로고 스크롤로 이어서 본다. 되돌리려면 calc 를 빼고 46vh 로. --%>
        <div id="stkStatusWrap" tabindex="0" style="max-height:calc(46vh - 68px); overflow:auto; outline:none"></div>
        <div class="close-pager" id="stkStatusPager"></div>
      </div>
      <%-- ★머리를 한 줄로 (2026-08-06 요청) — 종전에는 [제목] / [품목명] / [요약] 이
           서로 다른 줄에 있어 세 줄을 잡아먹고 그만큼 표가 아래로 밀렸다.
           한 줄에 모아 그만큼 표를 위로 올린다(카드 여백도 10→6px). --%>
      <div class="card" style="margin-top:2px">
        <div style="display:flex; align-items:baseline; gap:10px; flex-wrap:wrap; margin:0 0 6px">
          <div style="font-weight:800;font-size:13.5px;color:#1f2a37;border-left:4px solid #b06a00;padding-left:9px;white-space:nowrap">② 선택 품목 수불 내역 <span class="badge b-done" style="margin-left:4px">근거</span></div>
          <%-- 제목과 같은 줄에 서야 하므로 flex 로 둘을 양 끝으로 밀어 놓는다 --%>
          <div id="stkLedgerHead" style="flex:1 1 auto; min-width:0; display:flex; justify-content:space-between; align-items:baseline; gap:12px; color:#6b7a89"><%-- ★반드시 한 덩어리(span)로 감싼다 — 이 div 는 justify-content:space-between 인
              flex 줄이라, 글자와 <b> 를 낱개로 두면 조각들이 좌우 끝으로 밀려 버린다(2026-08-07 목격). --%><span>위 ① 표에서 <b>품목을 클릭</b>하면 그 품목의 수불 내역이 여기에 표시됩니다.</span></div>
          <%-- 기간 (2026-08-06 요청) — 기본 1개월. 오래된 품목은 수백 건이 한꺼번에 나와
                 최근 흐름이 안 보였다. ★서버 재조회 없이 화면에서만 자르므로 즉시 바뀐다. --%>
          <%-- 입고와 출고를 갈라 보는 별도 창 (2026-08-07 요청) —
                 ② 표는 입·출고가 한 줄로 섞여 있어 "얼마 들어와서 얼마 나갔나" 를 눈으로 세야 했다. --%>
          <%-- 큰 버튼·색 입힌다 (2026-08-07 요청) — 기간 버튼 틈에 섮여 안 보였다.
               기간 버튼은 '보기 설정'이고 이건 '다른 화면을 여는' 일이라 가중치가 다르다. --%>
          <button class="btn-teal" onclick="stkSplitExtClear()"
                  style="padding:0 14px;height:31px;font-size:13.5px;font-weight:800;white-space:nowrap;margin-right:10px;
                         background:#b06a00;border-color:#b06a00;box-shadow:0 1px 4px rgba(176,106,0,.35)"
                  title="선택한 품목의 입고내역과 출고내역을 따로 나눠 봅니다">⬇️⬆️ 입·출고 나누어보기</button>
          <div id="stkLedMonBox" style="display:flex; gap:3px; white-space:nowrap">
            <%-- ★처음 누렸던 상태(btn-teal)는 위 _stkLedMon 기본값과 반드시 같아야 한다 —
                   어긋나면 다른 버튼이 눌린 듯 보이는데 실제로는 다른 기간이 나온다 --%>
            <button class="btn-line" data-m="1"  style="padding:0 9px;height:26px;font-size:12px" onclick="stkLedMon(1)">1개월</button>
            <button class="btn-line" data-m="2"  style="padding:0 9px;height:26px;font-size:12px" onclick="stkLedMon(2)">2개월</button>
            <button class="btn-line" data-m="3"  style="padding:0 9px;height:26px;font-size:12px" onclick="stkLedMon(3)">3개월</button>
            <button class="btn-line" data-m="6"  style="padding:0 9px;height:26px;font-size:12px" onclick="stkLedMon(6)">6개월</button>
            <button class="btn-line" data-m="12" style="padding:0 9px;height:26px;font-size:12px" onclick="stkLedMon(12)">12개월</button>
            <button class="btn-teal" data-m="0"  style="padding:0 9px;height:26px;font-size:12px" onclick="stkLedMon(0)" title="이 품목의 전 기간 수불 내역">전체</button>
          </div>
        </div>
        <div id="stkLedgerBody" tabindex="0" style="max-height:210px; overflow:auto; outline:none"></div>
      </div>

      <%-- 입·출고 나눠보기 창 — 서버를 다시 부르지 않는다. ② 가 이미 받아 둔
           _stkLedRaw 를 그대로 갈라 그리므로 즉시 열린다. --%>
      <div class="ss-modal" id="stkSplitPop">
        <div class="box" style="width:min(1500px,96vw); margin-top:1.5vh; max-height:97vh">
          <div style="padding:11px 16px; border-bottom:1px solid var(--logi-border); display:flex; align-items:baseline; gap:12px; flex-wrap:wrap">
            <b style="font-size:15px; white-space:nowrap">⬇️⬆️ 입·출고 나누어보기</b>
            <span id="stkSplitTit" style="color:#37475a; overflow:hidden; text-overflow:ellipsis; white-space:nowrap"></span>
            <span id="stkSplitSum" style="margin-left:auto; color:#37475a; font-size:13.5px; white-space:nowrap"></span>
            <%-- 닫기를 크게 (2026-08-07 요청) — 화면을 거의 다 덮는 창이라
                   빠져나오는 길이 한눈에 보여야 한다. --%>
            <button class="btn-line" onclick="stkSplitClose()"
                    style="padding:0 18px;height:36px;font-size:14.5px;font-weight:800;white-space:nowrap;
                           border-width:2px;border-color:#b06a00;color:#b06a00">닫기 ✕</button>
          </div>
          <%-- 창 안 표는 목록 화면보다 한 단계 크게 — 보려고 여는 창이라 여백이 있다 --%>
          <div id="stkSplitBody" style="padding:12px 16px; overflow:auto; font-size:13.5px"></div>
        </div>
      </div>
    </section>

    <!-- ===== ★ 출고현황표 (엑셀 업로드 → 출고량 자동작성) ===== -->
    <section id="panel-shipstatus" class="panel">
      <div class="logi-head">
        <div><h2>출고현황표 <span class="badge b-done">핵심</span></h2>
          <div class="sub">발주현황표(엑셀)를 업로드하면 <b>사업장·품목별 출고량</b> 과 <b>출고장별 수량</b> 이 자동 작성됩니다. 기준일자 <b id="ssDate">2026.06.19</b></div></div>
        <div class="actions">
          <%-- 2026-07-26 사용자: 탐색기(파일 선택창)를 먼저 띄우지 않는다 → 미리보기 모달을 열어
               지정 폴더의 자료를 최신순으로 보여주고, 최신 파일 내용을 바로 펼친다. --%>
          <button class="btn-teal" id="ssBtnUpload" onclick="ssPvOpen(true)" title="지정한 자료 폴더의 발주현황표를 최신순으로 보여줍니다 (탐색기는 모달 안 [📄 파일 선택])">📤 발주현황표 엑셀 보기 / 업로드</button>
          <%-- [삭제 2026-07-05] 매출금액/매입금액 업로드·출고데이타저장 버튼 제거 → 좌측 '마감관리' 전용 메뉴(매출마감/매입마감/마감현황)로 대체 --%>
          <%-- [제외 2026-07-02] 출고현황표 다운로드 버튼 — 재노출 시 주석 해제 (ssDownload 함수는 유지)
          <button class="btn-line" id="ssBtnDownload" onclick="ssDownload()">📥 출고현황표 다운로드</button>
          --%>
          <button class="btn-line" id="ssBtnDownloadZone" onclick="ssDownloadByZone()" title="한 장(시트 1개)에 출고장을 위→아래로 색·테두리로 구분해 출력합니다. 각 출고장에는 실제 출고된 품목만 표시(상품 없는 품목·물건 없는 출고장 제외). 현장에서 출고장별 물건 확인·인쇄용">🏷️ 출고장별 출력</button>
          <%-- [제외 2026-07-02] PDF 출력 버튼 — 재노출 시 주석 해제 (ssPdf 함수는 유지)
          <button class="btn-line" id="ssBtnPdf" onclick="ssPdf()">📄 PDF 출력</button>
          --%>
        </div>
      </div>
      <input type="file" id="ssFile" class="ss-file" accept=".xlsx,.xls" onchange="ssUpload(this)">
      <input type="file" id="ssSalesFile" class="ss-file" accept=".xlsx,.xls" onchange="ssSalesUpload(this)">
      <input type="file" id="ssCostFile" class="ss-file" accept=".xlsx,.xls" onchange="ssCostUpload(this)">

      <!-- 발주현황표 미리보기 모달 (파일선택 → 내용확인 → 시트선택 → 작성) -->
      <div class="ss-modal" id="ssPvOverlay">
        <div class="box">
          <div class="mh">
            <h4>📋 발주현황표 미리보기 — 내용 확인 후 작성</h4>
            <button class="x" onclick="ssPvOpen(false)">&times;</button>
          </div>
          <%-- 2026-07-26 사용자: [폴더 지정]·[파일 선택]·[도움말]을 좌측 목록 머리에서 <b>모달 상단</b>으로 올림.
               자료를 여는 두 가지 방법이 화면 맨 위에 나란히 보이게 하고, 긴 설명은 도움말 카드로 접어 둔다. --%>
          <div class="mbar">
            <button class="btn-teal" style="padding:4px 12px; font-size:12.5px" onclick="ssPickDir()"
                    title="자료가 있는 폴더를 지정하면 그 안의 발주현황표가 좌측에 최신순으로 나열됩니다(다음부터 기억).&#10;※ 다운로드 폴더 자체는 브라우저가 막습니다 — 그 안에 전용 하위폴더를 만들어 지정하세요.">📂 폴더 지정</button>
            <button class="btn-line" style="padding:4px 12px; font-size:12.5px" onclick="document.getElementById('ssFile').click()"
                    title="탐색기에서 엑셀 파일을 직접 하나 엽니다(폴더 밖 파일용)">📄 파일 선택</button>
            <button class="btn-line" style="padding:4px 10px; font-size:12.5px" onclick="ssDirList()" title="지정한 폴더의 목록을 다시 읽습니다">↻ 새로고침</button>
            <span style="flex:0 0 1px; width:1px; height:20px; background:var(--logi-border)"></span>
            <span>파일 <b id="ssPvFile">-</b></span>
            <span id="ssPvSheetWrap" style="display:none">시트
              <select id="ssPvSheet" onchange="ssPvRender()"></select>
            </span>
            <button class="btn-line" id="ssPvHelpBtn" style="margin-left:auto; padding:4px 12px; font-size:12.5px" onclick="ssPvHelp()"
                    title="이 화면 사용법 — 데이터 연계(출고장+납품일자가 같으면 대체) / 폴더 지정 / 파일 선택 / 출고일자">ℹ️ 도움말</button>
          </div>
          <%-- 도움말: 기본 접힘(화면이 빽빽해 상시 노출하면 미리보기 표가 밀림 — 매출 그래프 도움말과 같은 방식).
               ★2026-07-27 사용자: "도움말이 너무 방대" → 한 줄 요약형으로 줄임. 세부 설명은 각 버튼·아이콘의 hover 툴팁에 있다.
                 다시 늘리자는 얘기가 나오면 이 이력부터 확인할 것. --%>
          <div id="ssPvHelpBox" style="display:none; flex:0 0 auto; margin:12px 20px 0; padding:11px 14px; background:#f4f8f7; border:1px solid #d5e6e2; border-radius:8px; font-size:12.5px; line-height:1.7; color:#37475a">
            <%-- ① 데이터 연계 = 기존자료가 있을 때 어떻게 되나 (2026-07-27 요청) — 이 화면에서 가장 헷갈리는 규칙이라 맨 위·단독 카드.
                 구현: UserController.saveShipoutMst(그룹키) · User_SQL markShipoutHistory / getShipoutNextJobSeq.
                 ★규칙을 고치면 이 카드도 같이 고칠 것. --%>
            <div style="padding:9px 12px; background:#fff; border:1px solid #bcd6d0; border-left:4px solid #1f9b8e; border-radius:7px; margin-bottom:10px">
              <div style="font-weight:700; color:#137a6c; margin-bottom:3px">🔗 데이터 연계 <span style="font-weight:400; color:#9aa7b3; font-size:11.5px">— 이미 올린 자료가 있을 때</span></div>
              <div><b style="color:#c0392b">출고장 + 납품일자</b> 가 같으면 <b>기존 자료를 대체</b>합니다. <b>출고일자는 보지 않습니다.</b><br>
                기존 자료는 지워지지 않고 <b>이력으로 내려가고</b> 새로 올린 것이 활성이 됩니다 — <b>잘못 올렸으면 바른 파일을 그냥 다시 올리면</b> 됩니다.<br>
                <span style="color:#6b7a89">다른 출고장·다른 납품일자 자료는 그대로 남습니다(한 파일에 물류센터가 여러 곳이면 조합마다 따로 판정). 화면은 이 파일로 <b>통째 교체</b>되고, 재고는 출고일자별로 다시 계산됩니다.</span></div>
            </div>
            <div style="display:flex; gap:16px; flex-wrap:wrap">
              <div style="flex:1 1 300px; min-width:270px">
                <b style="color:#137a6c">📂 폴더 지정</b> — 자료 폴더를 <b>한 번만</b> 지정하면 그 안의 파일이 좌측에 최신순으로 나열되고 최근 파일이 자동으로 펼쳐집니다.<br>
                <span style="color:#8a6414">⚠️ 다운로드 폴더 <b>자체</b>는 안 됩니다 — 그 안에 하위폴더를 만들어 지정하세요(Chrome·Edge 전용).</span><br>
                <b style="color:#137a6c">📄 파일 선택</b> — 폴더 밖 파일 하나를 직접 엽니다.
              </div>
              <div style="flex:1 1 300px; min-width:270px">
                <b style="color:#137a6c">파일 목록</b> — <code>2026.07.11_13.25.10</code> 처럼 <b>날짜로 시작하는 xlsx</b>만 나옵니다. <b>🗑</b>=「_삭제됨」, <b>작성 후</b>=「_반영됨」 하위폴더로 이동(복구 가능).<br>
                <b style="color:#137a6c">🕘 올린 이력</b> — 좌측 아래, <b>서버에 실제 반영한</b> 것이 최신순. <b style="color:#137a6c">초록 줄</b>=지금 펼친 파일(이미 올린 자료).
              </div>
              <div style="flex:1 1 300px; min-width:270px">
                <b style="color:#137a6c">✔ 작성 전에</b> — 내용을 확인하고 아래 <b>출고일자</b>를 확인·수정한 뒤 누르세요. 미리보기의 <b>노란 칸</b>이 반영되는 컬럼입니다.<br>
                <span style="color:#137a6c">※ <b>출고일자</b>는 <b>엑셀의 납기일자</b>가 그대로 들어옵니다 — <b>출고장(김해·제주 포함) 구분 없이</b> 전 행이 이 날짜로 저장됩니다.</span><br>
                <span style="color:#6b7a89">오류가 있어도 저장은 진행됩니다(알림만). 새 사업장은 자동 등록됩니다.</span>
              </div>
            </div>
            <%-- 브라우저 다운로드 위치를 전용 폴더로 바꿔 두면 '받기 → 옮기기'가 사라진다.
                 ★chrome:// 주소는 링크 클릭으로 못 연다(브라우저가 막음) → 복사해서 주소창에 붙여넣게 안내 + [복사] 버튼. --%>
            <div style="margin-top:10px; padding:8px 12px; background:#fff; border:1px dashed #bcd6d0; border-radius:7px">
              <div style="font-weight:700; color:#137a6c; margin-bottom:3px">⚙️ 받은 파일이 바로 그 폴더에 쌓이게 하기 <span style="font-weight:400; color:#9aa7b3; font-size:11.5px">— 크롬 다운로드 위치 바꾸기(한 번만)</span></div>
              <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap">
                <span><b>①</b> 주소창에 붙여넣고 Enter</span>
                <code id="ssPvChromeUrl" style="background:#eef4f3; border:1px solid #d5e6e2; border-radius:4px; padding:2px 7px; font-size:12.5px; color:#1f2a37">chrome://settings/downloads</code>
                <button class="btn-line" style="padding:2px 9px; font-size:11.5px" onclick="ssCopyTxt('chrome://settings/downloads', this)" title="주소를 복사합니다. 크롬 주소창에 붙여넣고 Enter 를 누르세요.&#10;※ 눌러서는 안 열립니다 — 브라우저가 설정 페이지로의 링크 이동을 막습니다.">📋 복사</button>
                <span style="color:#9aa7b3; font-size:11.5px">(엣지 <code style="background:#eef4f3;border:1px solid #d5e6e2;border-radius:4px;padding:1px 5px">edge://settings/downloads</code>
                  <button class="btn-line" style="padding:1px 7px; font-size:11px" onclick="ssCopyTxt('edge://settings/downloads', this)">📋</button>)</span>
              </div>
              <div style="margin-top:3px"><b>②</b> <b>「다운로드 위치」 → [변경]</b> → 새 하위폴더 지정 &nbsp;<b>③</b> 이 화면 <b>📂 폴더 지정</b> 에서 <b>같은 폴더</b> 선택
                <span style="color:#8a6414; font-size:11.5px">— 위 주소는 눌러도 안 열립니다. 꼭 <b>복사해서 주소창에</b> 붙여넣으세요.</span></div>
            </div>
          </div>
          <div class="mbody" style="display:flex; gap:12px; align-items:flex-start">
            <!-- 좌측: 지정한 자료 폴더의 파일 목록. 클릭하면 우측 미리보기에 표시 -->
            <%-- ★좌우 높이를 같은 값으로 '고정'한다 (2026-08-01 요청)
                 종전에는 우측이 내용만큼 늘어나서, 품목코드 연결 표가 생기면 모달이 통째로 커지고
                 파일을 고를 때마다 화면이 출렁였다. 이제 파일 선택 전·후 높이가 같고,
                 연결 표가 생기면 아래 미리보기 표 영역만 그만큼 줄어든다.
                 기본 높이도 60vh → 72vh 로 키웠다(처음부터 넓게 보이게). --%>
            <div style="width:400px; flex:0 0 400px; border:1px solid var(--logi-border); border-radius:7px; display:flex; flex-direction:column; height:72vh">
              <%-- 폴더 지정·파일 선택·새로고침 버튼은 모달 상단(mbar)으로 이동(2026-07-26). 여기는 제목만. --%>
              <div style="padding:7px 9px; border-bottom:1px solid var(--logi-border); background:#f4f8f7; flex:0 0 auto">
                <div style="display:flex; align-items:center; gap:6px">
                  <%-- 2026-07-27: 아래 '업로드 이력'과 이름이 겹쳐 헷갈린다 → 위는 '폴더의 엑셀'로 명시 --%>
                  <span style="flex:1; font-weight:700; color:#37475a; font-size:14px">📁 폴더의 엑셀 <span style="font-weight:400;font-size:12px;color:#9aa7b3" title="지정한 폴더에 있는 발주현황표 파일입니다(아직 서버에 올린 것과는 무관).&#10;파일 수정시각 기준 내림차순 — 맨 위가 가장 최근 자료이고, 모달을 열면 그 파일이 자동으로 펼쳐집니다">(최신순)</span></span>
                </div>
              </div>
              <div id="ssPvDirName" style="padding:4px 9px; font-size:12px; color:#137a6c; border-bottom:1px solid #eef3f1; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; flex:0 0 auto"></div>
              <%-- ★위/아래를 반반으로 고정(2026-07-27) — flex:1 1 0 이라 한쪽 내용이 많아도 다른 쪽이 찌그러지지 않는다.
                   종전 flex:0 1 auto 는 아래 이력이 수백 건이면 위 파일 목록이 0으로 밀렸다. --%>
              <div id="ssPvHist" style="overflow-y:auto; flex:1 1 0; min-height:96px"></div>
              <%-- 좌측 하단: 서버에 실제 반영된 업로드 이력 (기본 = 오늘 올린 것) — 2026-07-27 사용자 요청 --%>
              <div style="display:flex; align-items:center; gap:6px; padding:6px 9px; background:#f4f8f7; border-top:2px solid var(--logi-border); border-bottom:1px solid var(--logi-border); flex:0 0 auto">
                <span style="flex:1; min-width:0; font-weight:700; color:#37475a; font-size:14px">🕘 <span id="ssPvUpHistTit">오늘</span> 올린 이력
                  <span style="font-weight:400; font-size:12px; color:#9aa7b3"
                        title="서버(TBL_SHIPOUT_MST)에 실제로 반영된 배치입니다. 업로드한 시각 기준 최신이 맨 위에 옵니다.&#10;· 초록 줄 = 지금 펼쳐 둔 파일 (이미 올린 자료)&#10;· 이력 = 뒤에 올린 자료로 덮인 예전 배치&#10;· 줄을 누르면 그 파일을 다시 펼칩니다(지정 폴더에 있을 때)">(최신순)</span>
                  <b id="ssPvUpHistCnt" style="font-weight:700; font-size:12px; color:#137a6c; margin-left:2px"></b>
                </span>
                <%-- 기본은 '오늘'. 지난 자료 확인용으로 '3일' 전환 링크만 둔다(2026-07-27: 7일→3일) --%>
                <span id="ssPvUpHistTab" style="flex:0 0 auto; font-size:12px; color:#9aa7b3"></span>
                <span onclick="ssUpHistLoad()" title="업로드 이력 다시 읽기" style="flex:0 0 auto; cursor:pointer; color:#137a6c; font-size:14px">↻</span>
              </div>
              <div id="ssPvUpHist" style="overflow-y:auto; flex:1 1 0; min-height:96px"></div>
            </div>
            <!-- 우측: 기존 미리보기 표. 좌측과 같은 고정 높이(72vh)의 세로 flex —
                 위쪽(인식결과·오류·연결표)이 늘어나면 아래 표가 그만큼 줄고, 바깥 높이는 안 변한다. -->
            <div style="flex:1; min-width:0; height:72vh; display:flex; flex-direction:column">
              <div id="ssPvInfo" style="flex:0 0 auto"></div>
              <%-- 오류내역 — 양식이 다르거나 값이 빠진 행이 있을 때만 채워진다(ssPvRender) --%>
              <div id="ssPvErr" style="flex:0 0 auto"></div>
              <%-- 미매핑 — 우리 품목으로 해석되지 않는 품목코드가 있을 때만 나온다(ssXrefRender, 2026-08-01).
                   ★저장을 막지 않는다. 원본은 그대로 저장되고 그 행만 재고 반영이 보류된다.
                     여기서 연결하면 서버가 과거분까지 소급으로 채운다. --%>
              <div id="ssPvXref" style="flex:0 0 auto"></div>
              <%-- ★max-height 가 아니라 flex 로 남는 높이를 차지한다. min-height:0 이 없으면
                   flex 항목이 내용만큼 부풀어 스크롤이 안 생긴다(세로 flex 의 고전적 함정). --%>
              <div id="ssPvWrap" style="flex:1 1 auto; min-height:0; overflow:auto; border:1px solid var(--logi-border); border-radius:7px">
                <table class="ss-pv" id="ssPvTbl"></table>
              </div>
            </div>
          </div>
          <div class="mfoot" style="align-items:center">
            <%-- 좌측 알림: 역순 업로드(마지막에 올린 자료보다 이전)
                 ※ 조기출고(김해·제주) 알림줄은 2026-07-29 규칙 폐지로 제거 --%>
            <span style="margin-right:auto;min-width:0;display:flex;flex-direction:column;gap:2px">
              <%-- 이전 자료 알림 — 빨강 + 살짝 깜박(.ss-blink, ssBackMsgUpd 가 붙였다 뗀다) --%>
              <span id="ssPvBackMsg" style="font-size:12.5px;font-weight:700;color:#c0392b;display:none"></span>
            </span>
            <span style="font-size:16px;font-weight:700;color:#37475a;margin-right:10px">출고일자
              <input type="date" id="ssPvShpoutDt" oninput="this.setAttribute('data-touched','1');ssBackMsgUpd()"
                     style="height:38px;border:1px solid var(--logi-border);border-radius:6px;padding:0 10px;font-size:16px;font-weight:700;margin:0 4px"
                     title="엑셀의 납기일자가 그대로 들어옵니다 — 수정 가능.&#10;출고장(김해·제주 포함) 구분 없이 이 날짜로 전체 행이 저장되고 조회됩니다">
            </span>
            <button class="btn-line" onclick="ssPvOpen(false)">취소</button>
            <button class="btn-teal" id="ssPvApplyBtn" onclick="ssPvApply()">✔ 작성 (대시보드 반영)</button>
          </div>
        </div>
      </div>

      <!-- 매출금액(매입단가) 미리보기 모달 — 발주현황표 미리보기와 동일 스타일 -->
      <div class="ss-modal" id="ssSalesPvOverlay">
        <div class="box">
          <div class="mh">
            <h4>💰 매출금액(매입단가) 미리보기 — 내용 확인 후 작성</h4>
            <button class="x" onclick="ssSalesPvOpen(false)">&times;</button>
          </div>
          <div class="mbar">
            <span>파일 <b id="ssSalesPvFile">-</b></span>
            <span id="ssSalesPvSheetWrap" style="display:none">시트
              <select id="ssSalesPvSheet" onchange="ssSalesPvRender()"></select>
            </span>
            <span style="margin-left:auto; color:#6b7a89">품목코드별 <b>매출액(매입금액)</b> 으로 반영됩니다</span>
          </div>
          <div class="mbody">
            <div id="ssSalesPvInfo"></div>
            <div style="max-height:56vh; overflow:auto; border:1px solid var(--logi-border); border-radius:7px">
              <table class="ss-pv" id="ssSalesPvTbl"></table>
            </div>
          </div>
          <div class="mfoot">
            <button class="btn-line" onclick="ssSalesPvOpen(false)">취소</button>
            <button class="btn-teal" id="ssSalesPvApplyBtn" onclick="ssSalesPvApply()">✔ 작성 (매출액 반영)</button>
          </div>
        </div>
      </div>

      <!-- 매입금액 미리보기 모달 — 매출금액 미리보기와 동일 스타일 -->
      <div class="ss-modal" id="ssCostPvOverlay">
        <div class="box">
          <div class="mh">
            <h4>🧾 매입금액 미리보기 — 내용 확인 후 작성</h4>
            <button class="x" onclick="ssCostPvOpen(false)">&times;</button>
          </div>
          <div class="mbar">
            <span>파일 <b id="ssCostPvFile">-</b></span>
            <span id="ssCostPvSheetWrap" style="display:none">시트
              <select id="ssCostPvSheet" onchange="ssCostPvRender()"></select>
            </span>
            <span style="margin-left:auto; color:#6b7a89">품목코드별 <b>매입액</b> 으로 반영 · 마진(매출−매입) 자동계산</span>
          </div>
          <div class="mbody">
            <div id="ssCostPvInfo"></div>
            <div style="max-height:56vh; overflow:auto; border:1px solid var(--logi-border); border-radius:7px">
              <table class="ss-pv" id="ssCostPvTbl"></table>
            </div>
          </div>
          <div class="mfoot">
            <button class="btn-line" onclick="ssCostPvOpen(false)">취소</button>
            <button class="btn-teal" id="ssCostPvApplyBtn" onclick="ssCostPvApply()">✔ 작성 (매입액 반영)</button>
          </div>
        </div>
      </div>

      <!-- 출고일자 기간 + 요약(KPI) 한 줄 컴팩트 바 -->
      <div class="ss-topbar">
        <div class="tb-left">
          <span class="db-ic">📅</span>
          <label>출고일자</label>
          <input type="date" id="ssDateFrom" class="ss-datepick" onchange="ssLoadShipoutFromDB()" onclick="ssOpenCal(this)" onfocus="ssOpenCal(this)" title="클릭하여 달력 선택">
          <span style="color:#9aa7b3; font-weight:600">~</span>
          <input type="date" id="ssDateTo" class="ss-datepick" onchange="ssLoadShipoutFromDB()" onclick="ssOpenCal(this)" onfocus="ssOpenCal(this)" title="클릭하여 달력 선택">
          <button class="btn-teal" id="ssBtnSearch" style="padding:5px 14px" onclick="ssLoadShipoutFromDB()" title="선택한 출고일자의 데이터를 DB에서 다시 조회합니다">🔍 조회</button>
          <button class="btn-line" style="padding:5px 10px" onclick="ssOpenCal(document.getElementById('ssDateFrom'))" title="시작일 달력">📅</button>
          <button class="btn-line" id="ssBtnToday" style="padding:5px 14px" onclick="ssToday()">당일</button>
          <button class="btn-line" id="ssBtnMonth" style="padding:5px 12px" onclick="ssThisMonth()">당월</button>
        </div>
        <span id="ssDateInfo" class="ss-dateinfo"></span>
        <div class="tb-stats">
          <div class="st"><span class="st-l"><span id="ssKpiPrefix">당일</span> 출고품목</span><span class="st-v" id="ssKpiItem">0</span></div>
          <div class="st"><span class="st-l">출고수량(BOX)</span><span class="st-v" id="ssKpiQty">0</span></div>
          <div class="st"><span class="st-l">출고장 수</span><span class="st-v" id="ssKpiZone">0</span></div>
          <div class="st"><span class="st-l">사업장</span><span class="st-v" id="ssKpiBiz">0</span></div>
        </div>
      </div>

      <!-- 메인 출고현황표 (상단: 사업장·품목명 / 좌측: 출고장 행 / 하단: 출고내역·재고) -->
      <div class="card" id="ssCard">
        <div style="display:flex; align-items:center; justify-content:flex-start; margin-bottom:12px; flex-wrap:wrap; gap:8px">
          <div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap">
            <label style="font-size:12px; color:#37475a; font-weight:700">🔎 사업장 찾기</label>
            <input id="ssBizFind" type="text" list="ssBizFindList" placeholder="사업장명 입력" oninput="ssBizFind(this.value, true)" onkeydown="if(event.keyCode===13){ssBizFind(this.value, false);}" style="height:32px; border:1px solid var(--logi-border); border-radius:6px; padding:0 8px; font-size:12.5px; width:160px">
            <datalist id="ssBizFindList"></datalist>
            <button class="btn-line" style="padding:5px 9px" onclick="ssBizFindClear()" title="찾기 해제(전체 보기)">전체</button>
            <span style="display:inline-flex; gap:4px; align-items:center; margin-left:6px; padding-left:8px; border-left:1px solid var(--logi-border)">
              <button class="btn-line" style="padding:5px 9px" onclick="ssZoomOut()" title="축소">🔍－</button>
              <span id="ssZoomLbl" style="min-width:42px; text-align:center; font-size:12px; font-weight:700; color:#178074">100%</span>
              <button class="btn-line" style="padding:5px 9px" onclick="ssZoomIn()" title="확대">🔍＋</button>
              <button class="btn-line" id="ssBtnFull" style="padding:5px 11px" onclick="ssFullExpand()" title="출고현황표를 화면 전체로 덮기">⛶ 전체화면</button>
              <button class="btn-line seg-on" id="ssBtnBasic" style="padding:5px 11px" onclick="ssFullExit()" title="기본 화면 + 원래 크기로">⟲ 기본화면</button>
            </span>
          </div>
          <div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap">
            <button class="btn-line" id="ssBtnZoneToggle" style="padding:5px 11px; min-width:112px; text-align:center" onclick="ssToggleAllZones()">－ 출고장 접기</button>
            <span class="ss-gord-wrap" id="ssGordWrap">
              <button class="btn-line" style="padding:5px 11px" onclick="ssGordOpen(event)" title="출고장 그룹(물류센터) 표시 순서를 지정합니다. 브라우저에 저장되어 수정하지 않는 한 유지됩니다">⚙ 그룹순서</button>
              <div class="ss-gord-pop" id="ssGordPop"></div>
            </span>
            <button class="btn-teal" style="padding:5px 11px" onclick="ssAddItem()">＋ 품목 추가</button>
            <button class="btn-line" style="padding:5px 11px" onclick="ssAddZone()">＋ 출고장 추가</button>
            <%-- [제외 2026-07-02] 출고장 초기화 버튼 — 재노출 시 주석 해제 (ssClearAll 함수는 유지)
            <button class="btn-line" style="padding:5px 11px; color:#c0392b; border-color:#e3b4ae" onclick="ssClearAll()" title="모든 출고장 데이터를 비웁니다(샘플 포함). 이후 엑셀 업로드로 새로 채울 수 있습니다.">🔄 출고장 초기화</button>
            --%>
            <label style="font-size:12px; color:#37475a; margin-left:6px; cursor:pointer"><input type="checkbox" id="ssSumFront" onchange="ssRender()" style="vertical-align:-1px" checked> 합계 맨앞</label>
            <%-- [제외 2026-07-02] 사업장 회전 체크박스 — 재노출 시 주석 해제 (ssToggleBizAnim 함수는 유지)
            <label style="font-size:12px; color:#178074; margin-left:6px; cursor:pointer" title="사업장을 가운데로 두고 우측→좌측으로 5초마다 회전(원통 캐러셀). 활성 사업장만 또렷, 끝나면 반복"><input type="checkbox" id="ssBizAnim" onchange="ssToggleBizAnim()" style="vertical-align:-1px"> 사업장 회전</label>
            --%>
            <label style="font-size:12px; color:#6b7a89; margin-left:6px">사업장 보기</label>
            <select id="ssBizSel" onchange="ssRender()" style="height:32px; border:1px solid var(--logi-border); border-radius:6px; padding:0 8px; font-size:12.5px"></select>
          </div>
        </div>
        <div id="ssHiddenBar" class="ss-hidden-bar" style="display:none"></div>
        <div class="ss-scroll">
          <table class="ss-tb sswide" id="ssWideTbl"></table>
        </div>
        <%-- [제외 2026-07-02] 하단 안내문 숨김 — 재노출 시 주석 해제
        <div class="note">※ <b>당일</b> 모드에서 출고장 행의 노란 칸을 클릭해 수량을 직접 입력하면(엔터/포커스아웃) <b>합계가 자동 재계산</b>됩니다. 사업장 헤더(뜨돈 등) 클릭 시 그 열 숨김(위 바에서 펼치기). 품목 많으면 가로 스크롤. 하단 월별/재고량은 데모용 가정값.</div>
        --%>
      </div>

    </section>

    <!-- ===== 기준정보 : 거래처(사업장) ===== -->
    <section id="panel-client" class="panel" style="padding:0;">
      <iframe id="if-client" src="" title="거래처관리(사업장)" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 기준정보 : 매입/매출 거래처 (TBL_VENDOR_MST) ===== -->
    <section id="panel-vendor" class="panel" style="padding:0;">
      <iframe id="if-vendor" src="" title="매입/매출 거래처" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 기준정보 : 상품 ===== -->
    <section id="panel-item" class="panel">
      <div class="logi-head"><div><h2>상품(품목)관리</h2><div class="sub">상품 마스터 · 바코드 · 단가</div></div>
        <div class="actions"><button class="btn-line">엑셀 업로드</button><button class="btn-teal">상품 등록</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>상품코드</th><th>상품명</th><th>바코드</th><th>규격/단위</th><th>매입가</th><th>판매가</th><th>현재고</th></tr></thead>
          <tbody>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>8801234500011</td><td>500ml / EA</td><td>800</td><td>1,200</td><td>160</td></tr>
            <tr><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>8801234500042</td><td>1L / BOX</td><td>5,000</td><td>7,500</td><td>50</td></tr>
            <tr><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>8801234501108</td><td>2kg / EA</td><td>3,200</td><td>4,800</td><td>320</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 기준정보 : 창고/로케이션 ===== -->
    <section id="panel-base" class="panel">
      <div class="logi-head"><div><h2>창고 / 로케이션</h2><div class="sub">창고 3개 + 로케이션(랙-단-칸) 마스터</div></div>
        <div class="actions"><button class="btn-teal">로케이션 등록</button></div></div>
      <div class="card">
        <h3>창고 (3)</h3>
        <table class="logi-tb">
          <thead><tr><th>창고코드</th><th>창고명</th><th>유형</th><th>구역</th><th>적재율</th></tr></thead>
          <tbody>
            <tr><td>WH1</td><td class="txt-l">제1창고</td><td>상온</td><td>A구역</td><td>62%</td></tr>
            <tr><td>WH2</td><td class="txt-l">제2창고</td><td>냉장</td><td>B구역</td><td>38%</td></tr>
            <tr><td>WH3</td><td class="txt-l">제3창고</td><td>외부</td><td>C구역</td><td>85%</td></tr>
          </tbody>
        </table>
        <div class="note">※ 로케이션 코드 체계: [창고]-[랙]-[단]-[칸] 예) WH1-A-02-03</div>
      </div>
    </section>

    <!-- ===== ① 입고등록 : 3개 창고 위치선정 (핵심) ===== -->
    <section id="panel-inbound" class="panel">
      <div class="logi-head">
        <div><h2>입고등록 <span class="badge b-done">핵심</span></h2>
          <div class="sub">입고 물품을 어느 창고에 적재할지 위치를 선정합니다. (창고 3개)</div></div>
        <div class="actions"><button class="btn-line">초기화</button><button class="btn-teal">입고 확정</button></div>
      </div>
      <div class="card">
        <h3>① 매입처 / 품목 / 수량</h3>
        <div class="form-row">
          <div class="fld"><label>매입처</label><select><option>광동(매입)</option><option>제주삼다수</option></select></div>
          <div class="fld"><label>상품코드 <span style="color:#9aa7b3">(ITM-1001 입력 시 동일위치 알림)</span></label>
            <input id="inItemCode" list="itemList" placeholder="예) ITM-1001" onchange="checkExistingStock(this.value)" onkeyup="if(event.keyCode==13)checkExistingStock(this.value)">
            <datalist id="itemList"><option value="ITM-1001"><option value="ITM-1042"><option value="ITM-1108"><option value="ITM-2001"></datalist>
          </div>
          <div class="fld"><label>상품명</label><input placeholder="상품명"></div>
          <div class="fld"><label>입고수량</label><input type="number" placeholder="0"></div>
          <div class="fld"><label>입고일자</label><input type="date"></div>
        </div>
        <div class="guide" id="inStockAlert" style="display:none"></div>
      </div>
      <div class="card">
        <h3>② 적재 창고 선정 <span class="note">(클릭하여 선택)</span></h3>
        <div class="wh-grid">
          <div class="wh-card sel" onclick="whSelect(this,'WH1')">
            <div class="wh-ic">🏬</div><div class="wh-nm">제1창고</div>
            <div class="wh-meta">상온 · A구역</div>
            <div class="wh-rate"><i style="width:62%"></i></div>
            <div class="wh-meta" style="margin-top:5px">적재율 62%</div>
          </div>
          <div class="wh-card" onclick="whSelect(this,'WH2')">
            <div class="wh-ic">🏬</div><div class="wh-nm">제2창고</div>
            <div class="wh-meta">냉장 · B구역</div>
            <div class="wh-rate"><i style="width:38%"></i></div>
            <div class="wh-meta" style="margin-top:5px">적재율 38%</div>
          </div>
          <div class="wh-card" onclick="whSelect(this,'WH3')">
            <div class="wh-ic">🏬</div><div class="wh-nm">제3창고</div>
            <div class="wh-meta">외부 · C구역</div>
            <div class="wh-rate"><i style="width:85%"></i></div>
            <div class="wh-meta" style="margin-top:5px">적재율 85%</div>
          </div>
        </div>

        <!-- 선택 창고의 세부 로케이션 맵 + 상태 + 위치선정 안내 (창고 클릭 시 표시) -->
        <div class="wh-detail" id="whDetail" style="display:none">
          <div class="wh-status" id="whStatus"></div>
          <div class="guide" id="whGuide"></div>
          <div class="loc-legend">
            <span><i style="background:#eafaf3;border:1px solid #8fd6c2"></i>빈자리</span>
            <span><i style="background:#fff;border:1px solid #dfe6e3"></i>사용중(여유)</span>
            <span><i style="background:#f1f3f4;border:1px solid #e0e3e5"></i>만재</span>
          </div>
          <div class="loc-map" id="locMap"></div>
          <div class="form-row" style="margin-top:16px">
            <div class="fld"><label>선택된 세부 로케이션</label><input id="locInput" placeholder="맵에서 위치를 클릭하세요"></div>
            <div class="fld"><label>비고</label><input placeholder="메모"></div>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== 입고내역 ===== -->
    <section id="panel-inboundList" class="panel">
      <!-- 상단은 제목줄 + 조회줄 2줄만. 설명은 hover(title)로 뺐다 -->
      <div class="logi-head" style="margin-bottom:8px">
        <div><h2 style="margin:0">입고내역 <span class="badge b-done">수불</span>
          <span style="font-size:12px;font-weight:400;color:#9aa7b3;margin-left:6px">전체 품목 입고(수불) 거래 · 최신순</span></h2></div>
        <div class="actions"><button class="btn-teal" onclick="inboundListLoad()">↻ 새로고침</button></div>
      </div>
      <div class="card" style="padding-top:12px">
        <div class="form-row" style="margin-bottom:0; align-items:flex-end">
          <div class="fld" style="flex:0 0 150px"><label>시작일자</label><input type="date" id="inbFrom"></div>
          <div class="fld" style="flex:0 0 150px"><label>종료일자</label><input type="date" id="inbTo"></div>
          <div class="fld" style="flex:0 0 250px"><label>검색(품목/매입처)</label><input id="inbSrch" placeholder="검색어" onkeyup="if(event.keyCode===13)inboundListLoad()"></div>
          <div class="fld" style="flex:0 0 90px"><button class="btn-teal" style="width:100%" onclick="inboundListLoad()">조회</button></div>
          <div class="fld" style="flex:0 0 auto; margin-left:auto">
            <span class="tipx" title="[원천] 재고 수불원장(TBL_STOCK_LEDGER) 중 입고(IO_GB='I') 거래만 최신순으로.&#10;&#10;[등록하는 곳] 상품(품목)관리 ▸ 품목 행 클릭 ▸ 하단 재고 탭에서 입고를 등록하면 여기에 나옵니다.&#10;  (이 화면은 조회 전용입니다)&#10;&#10;[기간] 비우면 전체입니다.&#10;&#10;[출고는 안 나옵니다] 출고는 발주현황표에서 자동 기록되며 재고현황·매출내역에서 봅니다.">ℹ️ 도움말</span>
          </div>
        </div>
        <%-- 요약 + 묶음 토글. 위 조회줄과 겹치지 않게 한 줄로 흐르되 넘치면 자연스럽게 접힌다 --%>
        <div class="close-summary" id="inbSum" style="margin:10px 0 4px; display:flex; align-items:center; flex-wrap:wrap; gap:6px">[조회] 또는 [새로고침]을 누르세요.</div>
        <div id="inbWrap"></div>
        <div class="close-pager" id="inbPager"></div>
      </div>
    </section>

    <!-- ===== 창고별 재고현황 ===== -->
    <section id="panel-stock" class="panel">
      <div class="logi-head"><div><h2>창고별 재고현황</h2><div class="sub">3개 창고의 상품별 재고 수량</div></div></div>
      <div class="kpi-row">
        <div class="kpi"><div class="k-lbl">총 재고품목</div><div class="k-val">3 <small>종</small></div></div>
        <div class="kpi"><div class="k-lbl">제1창고</div><div class="k-val">140 <small>EA</small></div></div>
        <div class="kpi"><div class="k-lbl">제2창고</div><div class="k-val">50 <small>EA</small></div></div>
        <div class="kpi"><div class="k-lbl">제3창고</div><div class="k-val">340 <small>EA</small></div></div>
      </div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>상품코드</th><th>상품명</th><th>제1창고</th><th>제2창고</th><th>제3창고</th><th>합계</th></tr></thead>
          <tbody>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>120</td><td>0</td><td>40</td><td><b>160</b></td></tr>
            <tr><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>0</td><td>50</td><td>0</td><td><b>50</b></td></tr>
            <tr><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>20</td><td>0</td><td>300</td><td><b>320</b></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 재고/위치 조회 (어디있는지 찾기) ===== -->
    <section id="panel-locate" class="panel">
      <div class="logi-head"><div><h2>재고 / 위치 조회</h2><div class="sub">상품이 어느 창고 · 어느 로케이션에 있는지 검색</div></div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>상품코드/상품명/바코드</label><input placeholder="검색어 입력 또는 바코드 스캔"></div>
          <div class="fld" style="flex:0 0 120px; align-self:flex-end"><button class="btn-teal" style="width:100%">조회</button></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>상품코드</th><th>상품명</th><th>창고</th><th>로케이션</th><th>재고수량</th></tr></thead>
          <tbody>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>제1창고</td><td class="loc">A-02-03</td><td>120</td></tr>
            <tr><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>제3창고</td><td class="loc">C-04-01</td><td>40</td></tr>
          </tbody>
        </table>
        <div class="note">※ 동일 상품이 여러 창고/로케이션에 분산된 경우 모두 표시 → 출고 시 위치 확인.</div>
      </div>
    </section>

    <!-- ===== 주문(발주)등록 ===== -->
    <section id="panel-order" class="panel">
      <div class="logi-head"><div><h2>주문(발주)등록</h2><div class="sub">매출처로부터 받은 주문(발주) 등록</div></div>
        <div class="actions"><button class="btn-teal">발주 추가</button></div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>매출처(발주처)</label><select><option>OO마트</option><option>△△유통</option></select></div>
          <div class="fld"><label>상품코드</label><input placeholder="ITM-"></div>
          <div class="fld"><label>발주수량</label><input type="number" placeholder="0"></div>
          <div class="fld"><label>희망납기</label><input type="date"></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>발주처</th><th>상품코드</th><th>상품명</th><th>수량</th><th>납기</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>OO마트</td><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>80</td><td>2026-06-20</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr><td>△△유통</td><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>150</td><td>2026-06-21</td><td><span class="badge b-wait">대기</span></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== ② 발주리스트 (엑셀 다운로드) ===== -->
    <section id="panel-orderList" class="panel">
      <div class="logi-head"><div><h2>발주리스트 <span class="badge b-done">핵심</span></h2>
        <div class="sub">발주 상품을 재고와 매칭해 창고위치 자동선별 → 엑셀 다운로드</div></div>
        <div class="actions">
          <button class="btn-line" onclick="autoLocateOrders()">📍 창고위치 자동선별</button>
          <button class="btn-teal" onclick="downloadOrderExcel()">⬇ 엑셀 다운로드</button>
        </div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>발주기간(시작)</label><input type="date"></div>
          <div class="fld"><label>발주기간(종료)</label><input type="date"></div>
          <div class="fld"><label>상태</label><select><option>전체</option><option>대기</option><option>출고완료</option></select></div>
          <div class="fld" style="flex:0 0 100px; align-self:flex-end"><button class="btn-line" style="width:100%">조회</button></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>발주일</th><th>발주처</th><th>상품코드</th><th>상품명</th><th>수량</th><th>적재위치 (자동선별)</th><th>상태</th></tr></thead>
          <tbody id="orderBody">
            <tr data-item="ITM-1001"><td>2026-06-18</td><td>OO마트</td><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>80</td><td class="oloc" style="color:#9aa7b3">미매칭</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr data-item="ITM-1108"><td>2026-06-18</td><td>△△유통</td><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>150</td><td class="oloc" style="color:#9aa7b3">미매칭</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr data-item="ITM-1042"><td>2026-06-18</td><td>□□상사</td><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>30</td><td class="oloc" style="color:#9aa7b3">미매칭</td><td><span class="badge b-wait">대기</span></td></tr>
          </tbody>
        </table>
        <div class="note" id="orderMatchNote">※ "창고위치 자동선별" 을 누르면 발주 상품의 현재고 위치를 찾아 적재위치를 채웁니다. (엑셀 다운로드 시 자동 매칭 후 위치 포함)</div>
      </div>
    </section>

    <!-- ===== ③ 출고지시 (발주내용 → 위치 찾아 출고) ===== -->
    <section id="panel-outbound" class="panel">
      <div class="logi-head"><div><h2>출고지시 <span class="badge b-done">핵심</span></h2>
        <div class="sub">발주건을 선택하면 적재위치를 찾아 정확히 출고를 처리합니다.</div></div>
        <div class="actions"><button class="btn-teal">출고 확정</button></div></div>
      <div class="card">
        <h3>출고 대상 발주</h3>
        <table class="logi-tb">
          <thead><tr><th>선택</th><th>발주처</th><th>상품</th><th>수량</th><th>찾을 위치 (피킹)</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td><input type="checkbox"></td><td>OO마트</td><td class="txt-l">샘플 품목 A</td><td>80</td><td class="loc">제1창고 A-02-03</td><td><span class="badge b-wait">대기</span></td></tr>
            <tr><td><input type="checkbox"></td><td>△△유통</td><td class="txt-l">샘플 품목 C</td><td>150</td><td class="loc">제3창고 C-04-01</td><td><span class="badge b-ship">피킹중</span></td></tr>
          </tbody>
        </table>
        <div class="note">※ "찾을 위치" 를 보고 창고에서 정확히 피킹 → 출고 확정 → 재고 차감 + 거래명세서 발행.</div>
      </div>
    </section>

    <!-- ===== 출고내역 / 거래명세서 ===== -->
    <section id="panel-outboundList" class="panel">
      <div class="logi-head"><div><h2>출고내역 / 거래명세서</h2><div class="sub">출고 완료 내역 및 거래명세서</div></div>
        <div class="actions"><button class="btn-line">거래명세서 출력</button><button class="btn-line">엑셀</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>출고일</th><th>발주처</th><th>상품</th><th>수량</th><th>출고위치</th><th>금액</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>2026-06-17</td><td>□□상사</td><td class="txt-l">샘플 품목 B</td><td>30</td><td class="loc">제2창고 B-01-05</td><td>225,000</td><td><span class="badge b-done">출고완료</span></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 매출현황 ===== -->
    <section id="panel-sales" class="panel">
      <div class="logi-head"><div><h2>매출현황</h2><div class="sub">기간별 · 거래처별 매출 집계</div></div>
        <div class="actions"><button class="btn-line">엑셀</button></div></div>
      <div class="kpi-row">
        <div class="kpi"><div class="k-lbl">당월 매출</div><div class="k-val">12,450,000 <small>원</small></div></div>
        <div class="kpi"><div class="k-lbl">출고 건수</div><div class="k-val">38 <small>건</small></div></div>
        <div class="kpi"><div class="k-lbl">미수금</div><div class="k-val" style="color:#c0392b">1,200,000 <small>원</small></div></div>
        <div class="kpi"><div class="k-lbl">거래처</div><div class="k-val">12 <small>곳</small></div></div>
      </div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>거래처</th><th>출고건수</th><th>매출액</th><th>수금액</th><th>미수금</th></tr></thead>
          <tbody>
            <tr><td class="txt-l">OO마트</td><td>15</td><td>5,200,000</td><td>4,000,000</td><td>1,200,000</td></tr>
            <tr><td class="txt-l">△△유통</td><td>23</td><td>7,250,000</td><td>7,250,000</td><td>0</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ===== 출금 / 미지급 ===== -->
    <section id="panel-payment" class="panel" style="padding:0;">
      <iframe id="if-payment" src="" title="출금/미지급" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 수금 / 미수금 ===== -->
    <section id="panel-receive" class="panel" style="padding:0;">
      <iframe id="if-receive" src="" title="수금/미수금" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 매입등록 (2026-07-25) — logiGo 는 #panel-<key>, logiFrame 은 #if-<key> 를 찾는다.
             메뉴만 추가하고 이 두 요소를 안 만들면 화면이 빈 채로 뜬다. ===== -->
    <section id="panel-purchase" class="panel" style="padding:0;">
      <iframe id="if-purchase" src="" title="매입등록" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 지급등록 (2026-07-25) ===== -->
    <section id="panel-payreg" class="panel" style="padding:0;">
      <iframe id="if-payreg" src="" title="지급등록" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 수금등록 (2026-07-25) ===== -->
    <section id="panel-rcvreg" class="panel" style="padding:0;">
      <iframe id="if-rcvreg" src="" title="수금등록" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 판매등록 (2026-07-25) ===== -->
    <section id="panel-salesreg" class="panel" style="padding:0;">
      <iframe id="if-salesreg" src="" title="판매등록" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 출고현황이력조회 (2026-07-25) ===== -->
    <section id="panel-shipouthist" class="panel" style="padding:0;">
      <iframe id="if-shipouthist" src="" title="출고현황이력조회" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <%-- ===== 택배출고관리 (2026-08-06) — 출고일자의 직송(ZONE='직송')을 택배 발송 엑셀로.
         ★메뉴(logiFrame('parcelout',…))만 넣고 이 패널을 빠뜨리면 눌러도 아무 일이 없다
           (if-<key> iframe 이 없어 src 를 넣을 곳이 없다). 새 iframe 화면은 메뉴+패널을 짝으로 넣을 것. --%>
    <section id="panel-parcelout" class="panel" style="padding:0;">
      <iframe id="if-parcelout" src="" title="택배출고관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <%-- ===== 정산 그래프 (2026-08-02) — 정산서 금액을 일자별/월별로. JS=logi-oh.js sg* ===== --%>
    <%-- 좌우 11px = 매출 그래프 iframe 안(.sd-wrap/.sc-wrap)과 같은 안쪽 여백 —
         탭을 오갈 때 두 화면의 좌우 시작선이 같아야 한다(2026-08-02 요청, 2026-08-03 공통값 0.3cm 로) --%>
    <section id="panel-settleChart" class="panel" style="padding:14px 11px 16px">
      <div class="logi-head" style="margin-bottom:8px">
        <div><h2 style="margin:0">정산 그래프 <span class="badge b-done">정산서+직접판매</span>
          <span style="font-size:12px;font-weight:400;color:#9aa7b3;margin-left:6px">정산서 금액(매입금액) + 직접판매(전표) · 매입원가 · 마진 · 추정 미포함</span></h2></div>
      </div>
      <div class="card" style="padding-top:10px; padding-bottom:10px">
        <div class="form-row" style="margin-bottom:0; align-items:flex-end">
          <div class="fld" style="flex:0 0 auto"><label>보기</label>
            <div style="display:flex; gap:4px">
              <button type="button" class="btn-line" id="sgTabD" style="height:36px; padding:0 14px" onclick="sgTab('d')">일자별</button>
              <button type="button" class="btn-line" id="sgTabM" style="height:36px; padding:0 14px" onclick="sgTab('m')">월별</button>
            </div>
          </div>
          <div class="fld" style="flex:0 0 150px" id="sgFromWrap"><label>납품일자(시작)</label><input type="date" id="sgFrom"></div>
          <div class="fld" style="flex:0 0 150px" id="sgToWrap"><label>납품일자(종료)</label><input type="date" id="sgTo"></div>
          <%-- [조회]는 종료일자 옆(2026-08-02 요청). 탭마다 조건 묶음이 달라 일자별/월별 각자 버튼을 두고 같이 숨긴다 --%>
          <div class="fld" style="flex:0 0 auto; min-width:0" id="sgBtnDWrap"><label>&nbsp;</label><button class="btn-teal" style="padding:0 18px; height:36px" onclick="sgLoad()">조회</button></div>
          <%-- 기간 빠른 선택 — 매출 그래프(일자별)와 같은 구성(2026-08-02 요청). 다만 여기는 누르면 바로 조회한다. --%>
          <div class="fld" style="flex:0 0 auto; min-width:0" id="sgQuickWrap"><label>&nbsp;</label>
            <div style="display:flex; gap:4px">
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgQuick(7)">최근 1주</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgQuick(14)">최근 2주</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgQuick(30)">최근 30일</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgMonth()">이번 달</button>
            </div>
          </div>
          <%-- 월별 탭 조건 — 매출 그래프(월별)와 같은 구성(2026-08-02 요청): 시작월~종료월 + 올해/최근6·12개월/전체 --%>
          <div class="fld" style="flex:0 0 140px; display:none" id="sgMFromWrap"><label>기간(시작월)</label><input type="month" id="sgMFrom"></div>
          <div class="fld" style="flex:0 0 140px; display:none" id="sgMToWrap"><label>기간(종료월)</label><input type="month" id="sgMTo"></div>
          <div class="fld" style="flex:0 0 auto; min-width:0; display:none" id="sgBtnMWrap"><label>&nbsp;</label><button class="btn-teal" style="padding:0 18px; height:36px" onclick="sgLoad()">조회</button></div>
          <div class="fld" style="flex:0 0 auto; min-width:0; display:none" id="sgMQuickWrap"><label>&nbsp;</label>
            <div style="display:flex; gap:4px">
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgMYear()">올해</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgMQuick(6)">최근 6개월</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgMQuick(12)">최근 12개월</button>
              <button type="button" class="btn-line" style="height:36px; padding:0 11px" onclick="sgMQuick(0)">전체</button>
            </div>
          </div>
        </div>
      </div>
      <%-- KPI 카드 — 매출 그래프(일자별)의 카드 줄을 정산 용어로 맞춘 것(2026-08-02 요청). 값은 sgRender 가 채운다. --%>
      <style>
        /* 카드 10개를 **한 줄**에 (2026-08-02 요청) — wrap 을 끄고 카드가 폭을 나눠 갖는다.
             좁은 화면에서 넘치면 카드가 줄어들다가, 그래도 모자라면 이 줄만 좌우 스크롤(줄바꿈보다 낫다). */
        #sgKpi{ display:flex; gap:8px; flex-wrap:nowrap; overflow-x:auto; margin-bottom:10px; padding-bottom:2px; }
        #sgKpi .k{ flex:1 1 0; min-width:96px; border:1px solid var(--logi-border); border-radius:8px; padding:7px 10px; background:#fbfdfc; }
        #sgKpi .k span{ display:block; font-size:11.5px; color:#1f2a37; font-weight:700; white-space:nowrap; }
        #sgKpi .k b{ display:block; font-size:16px; color:#137a6c; margin-top:2px; white-space:nowrap; }
        #sgKpi .k b.warn{ color:#c0392b; }
        #sgKpi .k b.amber{ color:#a85700; }
        /* 하단 표 — 매출 그래프(일자별)처럼 안에서 스크롤 + 머리글 고정 (2026-08-02 요청) */
        #sgTbl table.logi-tb thead th, #sgDcTbl table.logi-tb thead th{ position:sticky; top:0; z-index:2; box-shadow:inset 0 -1px 0 var(--logi-border); }
        #sgTbl tr.sg-we td{ background:#fdf4ea; }                 /* 주말 줄 배경 */
      </style>
      <div class="card">
        <div id="sgKpi"></div>
        <span class="close-summary" id="sgSum">[조회]를 누르세요.</span>
      </div>
      <%-- 월별 탭 = 매출 그래프(월별)처럼 [출고장별 | 월별] 두 블록 나란히(2026-08-02 요청).
           일자별 탭에서는 출고장별 카드를 숨겨 본 카드가 전폭을 쓴다(sgTab 이 토글). --%>
      <div style="display:flex; gap:12px; flex-wrap:wrap; align-items:stretch">
        <div class="card" id="sgDcCard" style="flex:1 1 480px; min-width:420px; display:none">
          <div style="font-weight:800; font-size:13.5px; color:#1f2a37; margin-bottom:4px">📊 출고장별 매입원가·마진 <span style="font-weight:400; color:#9aa7b3">(합=매출) · 선택 기간 합계</span></div>
          <div style="position:relative; height:34vh; min-height:260px"><canvas id="sgDcCanvas"></canvas></div>
          <div id="sgDcTbl" style="margin-top:10px; max-height:30vh; overflow:auto"></div>
        </div>
        <div class="card" style="flex:1 1 480px; min-width:420px">
          <div id="sgMainTit" style="font-weight:800; font-size:13.5px; color:#1f2a37; margin-bottom:4px">🗓️ 일자별 매입원가·마진 <span style="font-weight:400; color:#9aa7b3">(합=매출)</span></div>
          <div style="position:relative; height:34vh; min-height:260px"><canvas id="sgCanvas"></canvas></div>
          <div id="sgTbl" style="margin-top:10px; max-height:30vh; overflow:auto"></div>
        </div>
      </div>
    </section>

    <%-- ===== 매출 그래프 — 일자별/월별 탭 통합 (2026-08-02, 종전 화면 2개는 그대로 iframe 재사용) ===== --%>
    <%-- 탭 버튼은 셸이 아니라 **각 화면의 조회줄 맨 앞**에 있다(2026-08-02, 정산 그래프와 같은 자리).
         셸은 iframe 갈아끼우기(scTabGo)만 맡는다 — 화면 안 버튼이 parent.scTabGo 를 부른다. --%>
    <section id="panel-salesChartTab" class="panel" style="padding:0;">
      <iframe id="if-saleschartday" src="" title="매출 그래프(일자별)" style="width:100%; height:calc(100vh - 70px); border:0; display:none;"></iframe>
      <iframe id="if-saleschart" src="" title="매출 그래프(월별)" style="width:100%; height:calc(100vh - 70px); border:0; display:none;"></iframe>
    </section>

    <!-- ===== 거래처별 받을금액·지급할금액 (2026-07-26) — logiFrame 은 #panel-<key> + #if-<key> 를 함께 찾는다 ===== -->
    <%-- ★2026-08-03: 이 패널만 위로 끌어올리던 margin-top:-14px 해제 — 화면 시작 위치를 전 화면 공통(36px)으로
           맞추기 위해서다(위 .panel 주석 참고). 대신 custBalance.jsp 의 .cb-wrap padding-top 을 14px 로 통일. --%>
    <section id="panel-custbal" class="panel" style="padding:0;">
      <iframe id="if-custbal" src="" title="거래처별 채권·채무 현황" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 일계장 (2026-07-26) ===== -->
    <section id="panel-daybook" class="panel" style="padding:0;">
      <iframe id="if-daybook" src="" title="일계장" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- 시스템관리 — 자체완결 화면을 iframe으로 사이드메뉴 우측에 종속 -->
    <!-- 출고현황표(데시보드2) — 별도 JSP(logistics_demo1.jsp)를 /admin/logistics_demo1.do 로 iframe 로드 (사이드바 종속)
         iframe 높이를 main 상하패딩(44px)만 뺀 값으로 잡아 세로를 거의 꽉 채움 -->
    <section id="panel-shipstatus2" class="panel show" style="padding:0;">
      <iframe id="if-shipstatus2" src="" title="출고현황표(데시보드2)" style="width:100%; height:calc(100vh - 44px); border:0; display:block;"></iframe>
      <%-- iframe 이 뜰 때까지의 흰 화면 대체 안내 (아래 스크립트에서 load 시 해제) --%>
      <div id="d2FrameLoading"><div class="box"><span class="sp"></span><span>대시보드를 불러오는 중입니다…</span></div></div>
    </section>

    <section id="panel-compcd" class="panel" style="padding:0;">
      <iframe id="if-compcd" src="" title="회사/사용자 관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>
    <section id="panel-codecd" class="panel" style="padding:0;">
      <iframe id="if-codecd" src="" title="공통코드 관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>
    <section id="panel-bizimst" class="panel" style="padding:0;">
      <iframe id="if-bizimst" src="" title="사업장 분류 관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <section id="panel-prodmst" class="panel" style="padding:0;">
      <iframe id="if-prodmst" src="" title="상품(품목) 관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <section id="panel-prodcd" class="panel" style="padding:0;">
      <iframe id="if-prodcd" src="" title="상품코드 등록" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>


  </main>
</div>

<!-- 출고장 변경 알림 — 화면 하단 독립 고정 바 (데시보드2 iframe이 postMessage로 요약을 올림) -->
<div id="konetAsqBar">
  <div class="ka-lbl">🔔 알림</div>
  <div class="ka-view"><div class="ka-track" id="konetAsqTrack"></div></div>
  <select class="ka-refresh" id="konetAsqRefresh" onchange="konetAsqSetRefresh(this.value)" title="자동 새로고침 주기">
    <option value="0">수동</option>
    <option value="30">30초</option>
    <option value="60">1분</option>
    <option value="120">2분</option>
    <option value="180">3분</option>
    <option value="300">5분</option>
  </select>
  <button class="ka-refresh-btn" onclick="konetAsqDoRefresh()" title="지금 새로고침">⟳</button>
  <button class="ka-toggle" id="konetAsqToggle" onclick="konetAsqToggle()" title="알림 멈춤/재생">끄기</button>
</div>
<script type="text/javascript">
  /* ── 대시보드(출고현황표) iframe 로딩 안내 해제 ──
     src 는 ssInit()/logiFrame() 이 나중에 넣는다. src 가 빈 상태(about:blank)로 뜨는 최초 load 는 무시.
     load 가 끝내 오지 않는 경우 대비 15초 후 강제 해제 */
  (function(){
    var f=document.getElementById('if-shipstatus2'), o=document.getElementById('d2FrameLoading');
    if(!f || !o) return;
    var hide=function(){ o.classList.add('off'); };
    f.addEventListener('load', function(){ var s=f.getAttribute('src')||''; if(s && s!=='about:blank') hide(); });
    setTimeout(hide, 15000);
  })();

  // ── 하단 알림 바 — 대시보드1(자체 데이터)·대시보드2(iframe) 요약을 활성 화면에 맞춰 표시 ──
  window._konetAsqDash1=null;   // {hide, html} — 대시보드1이 직접 생성
  window._konetAsqDash2=null;   // {hide, html} — 대시보드2 iframe postMessage
  function konetAsqRender(){
    var bar=document.getElementById('konetAsqBar'), track=document.getElementById('konetAsqTrack');
    if(!bar||!track) return;
    var onD2=!!document.querySelector('#panel-shipstatus2.show');
    var onD1=!!document.querySelector('#panel-shipstatus.show');
    var d1=window._konetAsqDash1, d2=window._konetAsqDash2;
    function _kaOk(x){ return x && !x.hide && x.html; }   // 실제 표시할 내용이 있는(숨김 아님) 요약
    // 현재 화면 요약을 우선 쓰되, 없거나 숨김이면 반드시 상대 화면(대시보드1↔2) 요약으로 폴백.
    //  → 한쪽이 hide:true(예: 대시보드2를 그룹뷰로 봤다 온 경우)여도 다른 쪽 요약으로 바를 유지.
    var src = onD2 ? (_kaOk(d2) ? d2 : (_kaOk(d1) ? d1 : null))
                   : (onD1 ? (_kaOk(d1) ? d1 : (_kaOk(d2) ? d2 : null)) : null);
    if(!src){ bar.style.display='none'; track.innerHTML=''; document.body.classList.remove('konet-asqbar-on'); bar.classList.remove('clickable'); return; }
    track.innerHTML=src.html||'';
    bar.style.display='flex'; document.body.classList.add('konet-asqbar-on');
    var dur=Math.max(35, Math.round(track.scrollWidth/45));   // 천천히 흐르게(초당 ~45px, 최소 35s)
    track.style.animationDuration=dur+'s';
    track.style.animationPlayState = window._konetAsqOff ? 'paused' : 'running';
    track.style.opacity = window._konetAsqOff ? '0.35' : '1';
    bar.classList.add('clickable');   // 대시보드1/2 모두 클릭 가능(대시보드1은 클릭 시 대시보드2로 전환 후 이동)
  }
  // 대시보드1(같은 문서)이 자체 요약을 넘김
  window.konetAsqSetDash1=function(payload){ window._konetAsqDash1=payload||{hide:true}; konetAsqRender(); };
  // 대시보드2 iframe 요약 수신
  window.addEventListener('message', function(e){
    var d=e.data; if(!d || d.type!=='konetAsq') return;
    window._konetAsqDash2=d; konetAsqRender();
  });
  // 멈춤/재생(위너넷 끄기와 동일 — 정지+흐림, 라벨 토글)
  function konetAsqToggle(){
    var track=document.getElementById('konetAsqTrack'), btn=document.getElementById('konetAsqToggle');
    if(!track) return;
    window._konetAsqOff = !window._konetAsqOff;
    track.style.animationPlayState = window._konetAsqOff ? 'paused' : 'running';
    track.style.opacity = window._konetAsqOff ? '0.35' : '1';
    if(btn) btn.textContent = window._konetAsqOff ? '켜기' : '끄기';
  }
  // 알림 항목 클릭 → 데시보드2 iframe에 해당 출고장 이동 요청 (대시보드2 활성일 때만)
  (function(){
    var bar=document.getElementById('konetAsqBar');
    if(!bar) return;
    bar.addEventListener('click', function(e){
      var it=e.target.closest ? e.target.closest('.tk-item[data-zone]') : null;
      if(!it) return;
      var zone=it.getAttribute('data-zone');
      var d2=document.getElementById('panel-shipstatus2');
      var onD2=!!(d2 && d2.classList.contains('show'));
      if(!onD2){   // 대시보드1 등에서 클릭 → 대시보드2 메뉴로 전환
        var menu=document.querySelector('.logi-side a.mi[data-key="shipstatus2"]');
        if(menu) menu.click();
      }
      var send=function(){ var f=document.getElementById('if-shipstatus2'); if(f && f.contentWindow) f.contentWindow.postMessage({type:'konetAsqGoto', zone:zone}, '*'); };
      if(onD2) send(); else setTimeout(send, 300);   // 전환 후 iframe 반영 여유
    });
  })();
  // 알림 데이터 준비 — 대시보드2 iframe을 백그라운드로 미리 로드(숨김 상태로 변경요약만 수집 → 대시보드1에서도 바 노출)
  (function(){
    var f=document.getElementById('if-shipstatus2');
    if(f){ var _c=f.getAttribute('src')||''; if(!_c || _c==='about:blank'){ f.src='${pageContext.request.contextPath}/admin/logistics_demo1.do'; } f.setAttribute('data-loaded','1'); }
  })();

  // ── 자동 새로고침 주기 설정(수동/1·5·10·30분) — 대시보드2 iframe에 재조회 요청 ──
  window._konetAsqTimer=null;
  function konetAsqDoRefresh(){   // 지금 새로고침 — 대시보드1(자체)·대시보드2(iframe) 모두 재조회
    if(typeof ssLoadAsqBar==='function') ssLoadAsqBar();                                       // 대시보드1
    var f=document.getElementById('if-shipstatus2');
    if(f && f.contentWindow) f.contentWindow.postMessage({type:'konetAsqRefresh'}, '*');       // 대시보드2
  }
  function konetAsqSetRefresh(sec){   // 값 = 초 단위(0=수동)
    sec=parseInt(sec,10)||0;
    try{ localStorage.setItem('konet_asq_refresh_sec', String(sec)); }catch(e){}
    if(window._konetAsqTimer){ clearInterval(window._konetAsqTimer); window._konetAsqTimer=null; }
    if(sec>0){ window._konetAsqTimer=setInterval(konetAsqDoRefresh, sec*1000); }
  }
  (function(){   // 저장된 주기 복원 + select 반영
    var sec=0; try{ sec=parseInt(localStorage.getItem('konet_asq_refresh_sec')||'0',10)||0; }catch(e){}
    var sel=document.getElementById('konetAsqRefresh'); if(sel) sel.value=String(sec);
    konetAsqSetRefresh(sec);
  })();
  
</script>
</body>
</html>
