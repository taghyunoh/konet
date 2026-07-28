<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
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

  /* 전체 셸: 좌측 사이드바 + 우측 콘텐츠 */
  .logi-wrap { display:flex; min-height:100vh; background:#fff; font-weight:700; }
  /* 전역 글자 진하게: 기본 700, 강조 800~900 */
  .logi-wrap, .logi-wrap input, .logi-wrap select, .logi-wrap button, .logi-wrap table,
  .logi-wrap a.mi, .logi-wrap td, .logi-wrap .sub, .logi-wrap .wh-meta,
  .logi-wrap .note, .logi-wrap label, .logi-wrap .chip { font-weight:700; }
  .logi-wrap b, .logi-wrap strong, .logi-wrap th, .logi-wrap .wh-nm, .logi-wrap .loc,
  .logi-wrap .lc-code, .logi-wrap h2, .logi-wrap h3, .logi-wrap .k-val,
  .logi-wrap a.mi.on, .logi-wrap .side-tit { font-weight:900; }

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
  /* 메뉴 간격 — 그룹이 6개로 늘어 세로가 길어져 촘촘하게 줄였다(2026-07-25 요청) */
  .logi-side .grp { padding:9px 20px 3px; font-size:11px; letter-spacing:.5px; color:#7d8b9c; }
  .logi-side a.mi { display:flex; align-items:center; gap:8px; padding:6px 20px; color:#cdd6e0; text-decoration:none; font-size:13.5px; border-left:3px solid transparent; cursor:pointer; }
  .logi-side a.mi:hover { background:#28333f; color:#fff; }
  .logi-side a.mi.on { background:var(--logi-teal); color:#fff; border-left:5px solid #0b5a52; padding-left:16px; font-weight:800; box-shadow:inset -3px 0 0 rgba(255,255,255,.18); }
  .logi-side a.mi.on .ic, .logi-side a.mi.on .caret { color:#fff; }
  .logi-side .sub-menu a.mi.on { padding-left:30px; }
  .logi-side a.mi .ic { width:18px; text-align:center; }
  .logi-side a.mi.core { color:#aef0e7; }


  /* 우측 콘텐츠 */
  .logi-main { flex:1; padding:22px 14px; background:var(--logi-bg); overflow:auto; }
  .logi-head { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
  .logi-head h2 { margin:0; font-size:20px; font-weight:700; color:#1f2a37; }
  .logi-head .sub { font-size:13px; color:#6b7a89; margin-top:4px; }
  .logi-head .actions { display:flex; gap:8px; }
  .btn-teal { background:var(--logi-teal); color:#fff; border:none; border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; }
  .btn-teal:hover { background:var(--logi-teal-dark); }
  .btn-line { background:#fff; color:#37475a; border:1px solid var(--logi-border); border-radius:6px; padding:8px 14px; font-size:13px; cursor:pointer; }
  .btn-line:hover { background:#eef3f2; }
  .btn-teal:disabled, .btn-line:disabled { opacity:.42; cursor:not-allowed; }
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
  table.logi-tb thead th { background:#eef3f2; color:#37475a; }
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
  .panel { display:none; }
  .panel.show { display:block; }

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
  #ssPvOverlay .box { width:min(1600px,96vw); }   /* 발주현황표 미리보기: 좌측 목록 + 우측 일자컬럼까지 보이도록 넓게 */
  /* 반영 확인(ssConfirm) — 화면 정중앙 + 다른 오버레이(미리보기·저장·패널·풀스크린)보다 항상 위 (2026-07-24 요청) */
  #ssConfirmOv.on { align-items:center; }
  #ssConfirmOv .box { margin-top:0; width:min(440px,92vw); }
  #ssConfirmOv { z-index:100000; }
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
  table.ss-pv { border-collapse:collapse; font-size:11.5px; }
  table.ss-pv td, table.ss-pv th { border:1px solid #e3e9e7; padding:3px 7px; white-space:nowrap; max-width:170px; overflow:hidden; text-overflow:ellipsis; }
  table.ss-pv tr.hdr td { background:#eef3f2; font-weight:700; color:#178074; position:sticky; top:0; }
  table.ss-pv td.hl { background:#fff7cc; }
  table.ss-pv td.dlv { background:#e1efff; font-weight:700; color:#1257a8; }   /* 납기일자 컬럼 구분 */
  table.ss-pv td.rn { background:#f4f8f7; color:#9aa7b3; text-align:right; position:sticky; left:0; }
  table.ss-pv tr.badrow td { background:#fdecea; }                                  /* 값이 빠진 행 — 오류내역과 같이 본다 */
  table.ss-pv tr.badrow td.rn { background:#f8d7d3; color:#c0392b; font-weight:700; }
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
    document.querySelectorAll('.logi-main .panel').forEach(function(p){ p.classList.remove('show'); });
    var t = document.getElementById('panel-'+key);
    if (t) t.classList.add('show');
    var m = document.querySelector('.logi-main'); if (m) m.scrollTop = 0;
    // 출고장 변경 알림 바: 활성 화면(대시보드1/2)에 맞춰 갱신 (그 외 화면은 자동 숨김)
    if (typeof konetAsqRender === 'function') konetAsqRender();
    if (typeof closePeriodInit === 'function') closePeriodInit();   // 마감 패널 진입 시 마감월 기본값
  }
  // 자체완결 화면(회사/사용자·공통코드)을 우측 iframe 패널에 로드 (사이드메뉴 종속)
  function logiFrame(key, url, el){
    logiGo(key, el);
    var f = document.getElementById('if-'+key);
    if (f) {
      var cur = f.getAttribute('src') || '';
      if (!cur || cur === 'about:blank') { f.src = url; }   // 비어있으면(최초/재진입) 로드 — 이미 로드됐으면 상태 유지
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
  // 주메뉴(기준정보관리 등) 접기/펼치기 토글
  function logiToggleSub(sub, el){
    var box = document.getElementById('sub-'+sub);
    if (!box) return;
    var open = box.classList.toggle('open');
    if (el) el.classList.toggle('open', open);
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
  function swAlert(msg, icon){ if(window.Swal) return Swal.fire({html:msg, icon:icon||'info', confirmButtonText:'확인', confirmButtonColor:'#137a6c'}); alert((''+msg).replace(/<br\s*\/?>/gi,'\n')); }
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
  function inboundListGo(p){ _inbPage=p; inboundListRender(); }
  function inboundListRender(){
    var wrap=document.getElementById('inbWrap'), sum=document.getElementById('inbSum'), pg=document.getElementById('inbPager');
    var thead='<thead><tr><th>입고일</th><th>매입처</th><th>품목코드</th><th>품목명</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>비고</th></tr></thead>';
    var tQ=0,tA=0; _inbRows.forEach(function(r){ tQ+=(+r.qty||0); tA+=(+r.amt||0); });
    if(!_inbRows.length){ sum.textContent='입고 내역이 없습니다. (상품관리 ▸ 재고 탭에서 입고 등록 시 표시)'; wrap.innerHTML=''; pg.innerHTML=''; return; }
    sum.innerHTML='총 <b>'+_inbRows.length.toLocaleString()+'</b>건 · 수량합 <b>'+_cnum(tQ)+'</b> · 금액합 <b>'+_cnum(tA)+'</b>';
    var totalRow='<tr class="close-total"><td colspan="4" style="text-align:left">■ 총합계</td><td style="text-align:right">'+_cnum(tQ)+'</td><td></td><td style="text-align:right">'+_cnum(tA)+'</td><td></td></tr>';
    var pages=Math.max(1,Math.ceil(_inbRows.length/INB_PAGE)); if(_inbPage>pages)_inbPage=pages;
    var pr=_inbRows.slice((_inbPage-1)*INB_PAGE, (_inbPage-1)*INB_PAGE+INB_PAGE);
    var body=pr.map(function(r){
      return '<tr><td>'+_fmtYmd(r.trxDt)+'</td><td>'+_cesc(r.vendorCd||'-')+'</td><td>'+_cesc(r.prodCd)+'</td><td class="txt-l">'+_cesc(r.prodNm)+'</td>'
        +'<td style="text-align:right">'+_cnum(r.qty)+'</td><td style="text-align:right">'+_cnum(r.unitPrice)+'</td>'
        +'<td style="text-align:right">'+_cnum(r.amt)+'</td><td>'+_cesc(r.remark)+'</td></tr>';
    }).join('');
    wrap.innerHTML='<table class="logi-tb">'+thead+'<tbody>'+totalRow+body+'</tbody></table>';
    if(pages<=1){ pg.innerHTML=''; return; }
    var h='<button '+(_inbPage<=1?'disabled':'')+' onclick="inboundListGo('+(_inbPage-1)+')">‹</button>';
    var from=Math.max(1,_inbPage-3), to=Math.min(pages,_inbPage+3);
    if(from>1) h+='<button onclick="inboundListGo(1)">1</button>'+(from>2?'<span style="padding:0 4px;color:#9aa7b3">…</span>':'');
    for(var p=from;p<=to;p++) h+='<button class="'+(p===_inbPage?'on':'')+'" onclick="inboundListGo('+p+')">'+p+'</button>';
    if(to<pages) h+=(to<pages-1?'<span style="padding:0 4px;color:#9aa7b3">…</span>':'')+'<button onclick="inboundListGo('+pages+')">'+pages+'</button>';
    h+='<button '+(_inbPage>=pages?'disabled':'')+' onclick="inboundListGo('+(_inbPage+1)+')">›</button>'; pg.innerHTML=h;
  }
  // ── 재고현황 (전체 품목 현재고) ──
  // 한 번에 보여줄 행수 10 — 이 표만 예외다(공통 18 아님). 아래 ②수불 내역까지 한 화면에 들어와야 해서(2026-07-25 요청).
  var _stkRows=[], STK_PAGE=10;
  function _fmtYmd(s){ s=(''+(s||'')); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
  function stkStatusLoad(){
    var q=(document.getElementById('stkSrch')||{}).value||'', ctx='${pageContext.request.contextPath}';
    var asOf=(document.getElementById('stkAsOf')||{}).value||'';
    var lbl=document.getElementById('stkAsOfLbl'); if(lbl) lbl.textContent = asOf ? ('기준일 '+asOf+' 까지 (기말)') : '전체 (현재고)';
    fetch(ctx+'/prod/stockStatusList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'findData='+encodeURIComponent(q)+'&asOfDt='+encodeURIComponent(asOf) })
      .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ swAlert('재고현황 응답 오류','error'); return; } _stkRows=(j&&j.data)||[]; stkStatusRender();
        var st=document.getElementById('stkStamp'); if(st) st.textContent=_now2(); })
      .catch(function(e){ swAlert('통신오류: '+e.message,'error'); });
  }
  function _now2(){ var d=new Date(), p=function(n){return ('0'+n).slice(-2);}; return d.getFullYear()+'-'+p(d.getMonth()+1)+'-'+p(d.getDate())+' '+p(d.getHours())+':'+p(d.getMinutes())+':'+p(d.getSeconds()); }
  function stkAsOfClear(){ var el=document.getElementById('stkAsOf'); if(el) el.value=''; stkStatusLoad(); }
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
        swConfirm('전체 <b>출고(SHIPOUT)</b>를 재고 수불원장에 반영하고 현재고를 다시 계산합니다.<br>'+excl+'<br>진행할까요?','🔄 출고반영 재집계').then(function(ok){ if(!ok) return;
          fetch(ctx+'/prod/stockRebuild.do', { method:'POST', credentials:'same-origin' })
            .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
            .then(function(r){ if(!r.ok){ swAlert('재집계 실패: '+((r.t||'').trim()),'error'); return; } swAlert('출고반영 재집계 완료 · 출고일자 <b>'+(r.t||'0')+'</b>건 반영','success'); stkStatusLoad(); })
            .catch(function(e){ swAlert('통신오류: '+e.message,'error'); });
        });
      });
  }
  // 재고현황 행 클릭 → 그 품목의 수불 내역(근거)을 하단 ② 그리드에 표시
  var _IOGB={I:'입고',O:'출고',R:'반품',A:'조정'};
  // 사업장 셀: 여러 곳이면 첫 곳 + [＋N] 만 표시 — 클릭하면 전체 펼침/접기
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
  function stkLedgerDetail(prodSeq, el){
    // 선택행 하이라이트
    var wrap=document.getElementById('stkStatusWrap'); if(wrap){ var trs=wrap.querySelectorAll('tbody tr'); for(var k=0;k<trs.length;k++) trs[k].style.background=''; }
    if(el){ el.style.background='#e6f4f1'; }
    if(!prodSeq){ document.getElementById('stkLedgerHead').innerHTML='<span style="color:#c0392b">이 품목은 수불원장 키가 없어 내역을 조회할 수 없습니다.</span>'; document.getElementById('stkLedgerBody').innerHTML=''; return; }
    var ctx='${pageContext.request.contextPath}', row=null;
    for(var i=0;i<_stkRows.length;i++){ if((_stkRows[i].prodSeq||0)==prodSeq){ row=_stkRows[i]; break; } }
    document.getElementById('stkLedgerHead').innerHTML='<span style="color:#9aa7b3">불러오는 중…</span>';
    fetch(ctx+'/prod/stockList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'prodSeq='+encodeURIComponent(prodSeq) })
      .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ swAlert('수불 내역 응답 오류','error'); return; }
        var rows=(j&&j.data)||[];
        var tIn=0,tOut=0,tAmt=0; rows.forEach(function(l){ var q=+l.qty||0; if(l.ioGb==='O') tOut+=q; else tIn+=q; tAmt+=(+l.amt||0); });
        var neg=(row&&+row.curQty<0);
        var head='<div style="display:flex;justify-content:space-between;align-items:baseline;gap:12px;flex-wrap:wrap;margin:2px 0 8px">'
               +   '<div style="font-weight:800;font-size:15px">'+_cesc(row?row.prodCd:'')+' <span style="font-weight:400;color:#37475a">'+_cesc(row?row.prodNm:'')+'</span></div>'
               +   '<div style="color:#37475a;font-size:12.5px;white-space:nowrap">'
               +     '입고계 <b style="color:#137a6c">'+_cnum(tIn)+'</b> · 출고계 <b style="color:#b06a00">'+_cnum(tOut)+'</b> · 현재고 <b style="color:'+(neg?'#c0392b':'#137a6c')+'">'+_cnum(row?row.curQty:(tIn-tOut))+'</b>'
               +     ' · 이동평균단가 '+_cnum(row?row.avgInPrice:0)+' · 재고금액 '+_cnum(row?row.stockAmt:0)+' · 총 <b>'+rows.length+'</b>건</div>'
               +   '</div>';
        var thead='<thead><tr><th>일자</th><th>품목코드</th><th>구분</th><th style="text-align:right">수량</th><th style="text-align:right">단가</th><th style="text-align:right">금액</th><th>매입처</th><th>사업장</th><th>근거구분</th><th>근거번호</th><th>비고</th><th>등록일시</th><th>등록자</th></tr></thead>';
        var body= rows.length ? rows.map(function(l){
            var io=_IOGB[l.ioGb]||l.ioGb, isOut=(l.ioGb==='O');
            return '<tr><td>'+_fmtYmd(l.trxDt)+'</td>'
              +'<td style="color:#37475a">'+_cesc(l.prodCd||'')+'</td>'
              +'<td style="font-weight:700;color:'+(isOut?'#b06a00':'#137a6c')+'">'+io+'</td>'
              +'<td style="text-align:right">'+_cnum(l.qty)+'</td>'
              +'<td style="text-align:right">'+_cnum(l.unitPrice)+'</td>'
              +'<td style="text-align:right">'+_cnum(l.amt)+'</td>'
              +'<td>'+_cesc(l.vendorCd||'')+'</td>'
              +'<td>'+_bizCell(l.bizCd)+'</td>'
              +'<td>'+_cesc(l.refGb||'')+'</td>'
              +'<td>'+_cesc(l.refNo||'')+'</td>'
              +'<td>'+_cesc(l.remark||'')+'</td>'
              +'<td style="color:#9aa7b3">'+_cesc(l.regDttm||'')+'</td>'
              +'<td style="color:#9aa7b3">'+_cesc(l.regUser||'')+'</td></tr>';
          }).join('') : '<tr><td colspan="13" style="text-align:center;color:#9aa7b3;padding:20px">수불 내역이 없습니다. (이 품목은 입고/출고 원장 기록이 없음)</td></tr>';
        document.getElementById('stkLedgerHead').innerHTML=head;
        document.getElementById('stkLedgerBody').innerHTML='<table class="logi-tb">'+thead+'<tbody>'+body+'</tbody></table>';
      }).catch(function(e){ swAlert('통신오류: '+e.message,'error'); });
  }
  /* ①품목별 현재고 — 10행씩 + 자동 스크롤(2026-07-25 요청).
       아래에 ②수불 내역 패널이 붙어 있어 이 표는 10행이면 한 화면에 둘 다 들어온다.
       페이지 버튼(1 2 3 … 20)은 없앴다 — 스크롤이 바닥에 닿으면 다음 10행이 저절로 붙는다(lzMount). */
  function stkStatusRender(){
    var wrap=document.getElementById('stkStatusWrap'), sum=document.getElementById('stkStatusSum'), pg=document.getElementById('stkStatusPager');
    var thead='<thead><tr><th>품목코드</th><th>품목명</th><th style="text-align:right">입고</th><th style="text-align:right">출고</th><th style="text-align:right">현재고</th><th style="text-align:right">이동평균단가</th><th style="text-align:right">재고금액</th><th>최근입고</th><th>최근출고</th></tr></thead>';
    var tI=0,tO=0,tQ=0,tA=0; _stkRows.forEach(function(r){ tI+=(+r.inQty||0); tO+=(+r.outQty||0); tQ+=(+r.curQty||0); tA+=(+r.stockAmt||0); });
    if(!_stkRows.length){ sum.textContent='현재고 데이터가 없습니다. (입고 수불 등록 또는 출고(SHIPOUT) 발생 시 표시)'; wrap.innerHTML=''; wrap._lz=null; pg.innerHTML=''; return; }
    sum.innerHTML='총 <b>'+_stkRows.length.toLocaleString()+'</b>품목 · 입고합 <b>'+_cnum(tI)+'</b> · 출고합 <b>'+_cnum(tO)+'</b> · 현재고합 <b>'+_cnum(tQ)+'</b> · 재고금액합 <b>'+_cnum(tA)+'</b>';
    var totalRow='<tr class="close-total"><td colspan="2" style="text-align:left">■ 총합계</td><td style="text-align:right">'+_cnum(tI)+'</td><td style="text-align:right">'+_cnum(tO)+'</td><td style="text-align:right">'+_cnum(tQ)+'</td><td></td><td style="text-align:right">'+_cnum(tA)+'</td><td></td><td></td></tr>';
    var stkRow=function(r){ var neg=(+r.curQty||0)<0;
      return '<tr style="cursor:pointer" onclick="stkLedgerDetail('+(r.prodSeq||0)+', this)" title="클릭 → 아래 ② 수불 내역(근거) 표시"><td>'+_cesc(r.prodCd)+'</td><td class="txt-l">'+_cesc(r.prodNm)+'</td>'
        +'<td style="text-align:right;color:#137a6c">'+_cnum(r.inQty)+'</td>'
        +'<td style="text-align:right;color:#b06a00">'+_cnum(r.outQty)+'</td>'
        +'<td style="text-align:right;font-weight:700;color:'+(neg?'#c0392b':'#137a6c')+'">'+_cnum(r.curQty)+'</td>'
        +'<td style="text-align:right">'+_cnum(r.avgInPrice)+'</td><td style="text-align:right">'+_cnum(r.stockAmt)+'</td>'
        +'<td>'+_fmtYmd(r.lastInDt)+'</td><td>'+_fmtYmd(r.lastOutDt)+'</td></tr>';
    };
    lzMount({ wrap:wrap, pager:'stkStatusPager', rows:STK_PAGE, capTop:300,
              head:'<table class="logi-tb">'+thead+'<tbody>'+totalRow,
              list:_stkRows, rowFn:stkRow });
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
<script type="text/javascript">
  /* ===================================================================
     출고현황표 — 발주현황표(엑셀) 업로드 → 출고량/재고량 자동작성
     · 원천: 발주현황표 노란칸 [품목명 · 사업장명 · 존(출고장) · 수량]
     · 출고장 = 입고장 기준 존 그룹 (1→A존 / 2→C존 / 3→D존 / 4→F존)
     · 업로드 없이도 시연되도록 실제 2026.06.19 발주 127행을 내장
     =================================================================== */
  var SHIP_DATA = [{"code":"1000800551","item":"(PAZAC)박스대,제이투팩,11.2KG(400EA/BOX)","biz":"new파작(종로점) [A0403307]","bizCode":"A0403307","inb":"3","zone":"D7","qty":2},{"code":"1000800551","item":"(PAZAC)박스대,제이투팩,11.2KG(400EA/BOX)","biz":"new파작(여의도점) [A0405159]","bizCode":"A0405159","inb":"3","zone":"D8","qty":1},{"code":"1000800552","item":"(PAZAC)박스소,제이투팩,8.4KG(400EA/BOX)","biz":"new파작(종로점) [A0403307]","bizCode":"A0403307","inb":"3","zone":"D7","qty":1},{"code":"1000797636","item":"(PAZAC)홀더,대승씨엔씨,7.35KG(1,000EA/BOX)","biz":"new파작(여의도점) [A0405159]","bizCode":"A0405159","inb":"3","zone":"D8","qty":1},{"code":"1000781893","item":"(뜨돈)195파이용기뚜껑,검정,구형,PP,300EA/BOX","biz":"뜨돈 수원 영통점 [A0361355]","bizCode":"A0361355","inb":"1","zone":"A3","qty":1},{"code":"1000781893","item":"(뜨돈)195파이용기뚜껑,검정,구형,PP,300EA/BOX","biz":"뜨돈 동탄 성공 본점 [A0361331]","bizCode":"A0361331","inb":"2","zone":"C2","qty":1},{"code":"1000781894","item":"(뜨돈)195파이용기몸체,소,검정,구형,PP,300EA/BOX","biz":"뜨돈 수원 영통점 [A0361355]","bizCode":"A0361355","inb":"1","zone":"A3","qty":1},{"code":"1000781894","item":"(뜨돈)195파이용기몸체,소,검정,구형,PP,300EA/BOX","biz":"뜨돈 동탄 성공 본점 [A0361331]","bizCode":"A0361331","inb":"2","zone":"C2","qty":1},{"code":"1000782041","item":"(뜨돈)5칸돈가스도시락세트,검정,240*180*35MM,몸체PP,뚜껑PE","biz":"뜨돈 시흥 배곧점 [A0361335]","bizCode":"A0361335","inb":"3","zone":"D7","qty":1},{"code":"1000779754","item":"(뜨돈)각대봉투,소,120*60*220MM,무지크라프트,1000EA/BO","biz":"뜨돈 시흥 배곧점 [A0361335]","bizCode":"A0361335","inb":"3","zone":"D7","qty":1},{"code":"1000779736","item":"(뜨돈)소스용기뚜껑,95파이,PP,1000EA/BOX","biz":"뜨돈 동탄 카림애비뉴점 [A0361421]","bizCode":"A0361421","inb":"2","zone":"C2","qty":1},{"code":"1000736180","item":"(런던&레이&하이)74Ø3.25온스,크림치즈용,소,용기,740*500*3","biz":"성수CC [A0370886]","bizCode":"A0370886","inb":"3","zone":"D2","qty":3},{"code":"1000736181","item":"(런던&레이&하이)F74Ø크림치즈용,소,무타공뚜껑,F74Ø(무타공)뚜껑,","biz":"성수CC [A0370886]","bizCode":"A0370886","inb":"3","zone":"D2","qty":2},{"code":"1000730573","item":"(런던&레이&하이)노루지코팅깔개,소,130*100MM,10000EA/BO","biz":"런베잠실_홀1층 [A0307398]","bizCode":"A0307398","inb":"2","zone":"C5","qty":1},{"code":"1000736204","item":"(런던&레이&하이)보냉팩,소,180*240MM+50MM,600EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000736204","item":"(런던&레이&하이)보냉팩,소,180*240MM+50MM,600EA/BOX","biz":"런베도산 [A0276902]","bizCode":"A0276902","inb":"4","zone":"F2","qty":1},{"code":"1000736213","item":"(런던&레이&하이)보냉팩,중,240*350MM+40MM,400EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"레이안국 [A0329858]","bizCode":"A0329858","inb":"4","zone":"F1","qty":1},{"code":"1000730576","item":"(런던&레이&하이)줄무늬크라프트유산지,350*250MM,3000EA/BO","biz":"런베수원_홀 [A0331220]","bizCode":"A0331220","inb":"4","zone":"F7","qty":1},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베잠실_홀1층 [A0307398]","bizCode":"A0307398","inb":"2","zone":"C5","qty":1},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":2},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":3},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베도산 [A0276902]","bizCode":"A0276902","inb":"4","zone":"F2","qty":1},{"code":"1000731259","item":"(런던베이글)샌드위치펄프용기,일체형,182*130*50MM,600ML,5","biz":"런베수원_홀 [A0331220]","bizCode":"A0331220","inb":"4","zone":"F7","qty":3},{"code":"1000792544","item":"(런던베이글)아돌이종이컵,16온스,2도인쇄,1000EA/BOX","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":1},{"code":"1000730686","item":"(런던베이글)칵테일냅킨,W230mm,L230mm,1도인쇄,10000EA/","biz":"런베여의도_창고-B6층 [A0347927]","bizCode":"A0347927","inb":"2","zone":"C7","qty":1},{"code":"1000792545","item":"(런던베이글)필로소피종이컵,16온스,1도인쇄,1000EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000718241","item":"(레이어드)친환경종이컵,16OZ,무지,1000EA/BOX","biz":"런베잠실_홀2층 [A0307878]","bizCode":"A0307878","inb":"2","zone":"C5","qty":1},{"code":"1000719149","item":"(레이어드)하이웨스트&베이글박스,소,130*100*115MM,200EA/","biz":"하웨판교 [A0326700]","bizCode":"A0326700","inb":"4","zone":"F5","qty":1},{"code":"1000715525","item":"(명동피자)물티슈,1도인쇄,1000EA/BOX,D-2","biz":"명동피자(명동본점-창고) [A0316597]","bizCode":"A0316597","inb":"3","zone":"D3","qty":2},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(세종아름점)25년 [A0376445]","bizCode":"A0376445","inb":"1","zone":"A8","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(신관점) [A0359235]","bizCode":"A0359235","inb":"1","zone":"A9","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(오산시청점) [A0343969]","bizCode":"A0343969","inb":"2","zone":"C1","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(봉천) [A0273035]","bizCode":"A0273035","inb":"3","zone":"D1","qty":2},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈 덮밥이 마포점(26) [A0400921]","bizCode":"A0400921","inb":"3","zone":"D1","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(분당수내)25 [A0370059]","bizCode":"A0370059","inb":"","zone":"","qty":0},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(세종보람점)26 [A0401387]","bizCode":"A0401387","inb":"3","zone":"D6","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(세종조치원25년) [A0367700]","bizCode":"A0367700","inb":"3","zone":"D6","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"파스타입니다(왕십리점) [A0278710]","bizCode":"A0278710","inb":"3","zone":"D7","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"배고픈덮밥이(길동점) [A0294143]","bizCode":"A0294143","inb":"4","zone":"F2","qty":1},{"code":"1000736040","item":"(배고픈덮밥이)덮밥용기,뚜껑,160Ǿ,PP,300EA/BOX","biz":"파스타입니다(수유점) [A0383456]","bizCode":"A0383456","inb":"4","zone":"F8","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(세종아름점)25년 [A0376445]","bizCode":"A0376445","inb":"1","zone":"A8","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(신관점) [A0359235]","bizCode":"A0359235","inb":"1","zone":"A9","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(오산시청점) [A0343969]","bizCode":"A0343969","inb":"2","zone":"C1","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(봉천) [A0273035]","bizCode":"A0273035","inb":"3","zone":"D1","qty":2},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈 덮밥이 마포점(26) [A0400921]","bizCode":"A0400921","inb":"3","zone":"D1","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(세종조치원25년) [A0367700]","bizCode":"A0367700","inb":"3","zone":"D6","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"파스타입니다(왕십리점) [A0278710]","bizCode":"A0278710","inb":"3","zone":"D7","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"배고픈덮밥이(길동점) [A0294143]","bizCode":"A0294143","inb":"4","zone":"F2","qty":1},{"code":"1000736038","item":"(배고픈덮밥이)덮밥용기,몸체,1290CC,160*88MM,300EA/BO","biz":"파스타입니다(수유점) [A0383456]","bizCode":"A0383456","inb":"4","zone":"F8","qty":1},{"code":"1000791735","item":"(스프링롤명가)WL-F800SET(흰색),198*116*53MM,150S","biz":"스프링롤 명가_수원영통점 [A0368222]","bizCode":"A0368222","inb":"1","zone":"A7","qty":1},{"code":"1000791735","item":"(스프링롤명가)WL-F800SET(흰색),198*116*53MM,150S","biz":"스프링롤 명가_답십리 [A0381705]","bizCode":"A0381705","inb":"3","zone":"D7","qty":2},{"code":"1000795136","item":"(아벡쉐리)컵홀더,12/16/20,SC합지인쇄,코네트,9.62KG(100","biz":"아벡쉐리 한남점(홀) [A0383277]","bizCode":"A0383277","inb":"4","zone":"F7","qty":2},{"code":"1000793901","item":"(아임도넛)각대봉투,피앤텍,8KG(1000EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":1},{"code":"1000793900","item":"(아임도넛)슬리브인박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000793900","item":"(아임도넛)슬리브인박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":3},{"code":"1000793899","item":"(아임도넛)슬리브터널형,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000793899","item":"(아임도넛)슬리브터널형,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":2},{"code":"1000802403","item":"(아임도넛)에스파콜라보박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000802403","item":"(아임도넛)에스파콜라보박스,선피앤피,8KG(200EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":2},{"code":"1000802405","item":"(아임도넛)옐로우비닐,그린팩코리아,11.8KG(500EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000802405","item":"(아임도넛)옐로우비닐,그린팩코리아,11.8KG(500EA/BOX)","biz":"아임도넛(성수점) [A0379537]","bizCode":"A0379537","inb":"2","zone":"C5","qty":2},{"code":"1000804387","item":"(아임도넛)원형간지,325MM,대영전산,10KG(3000EA/BOX)","biz":"아임도넛(홍대점) [A0400202]","bizCode":"A0400202","inb":"2","zone":"C4","qty":2},{"code":"1000768163","item":"(오베이글)각대봉투,대,흰색,180*110*430MM,2도,1000EA/","biz":"오베이글(카페) [A0339710]","bizCode":"A0339710","inb":"2","zone":"C4","qty":1},{"code":"1000758525","item":"(주니아)랩지,크라프트,330*330MM,코팅,1도,1000EA/BOX","biz":"주니아_약수점 [A0372844]","bizCode":"A0372844","inb":"2","zone":"C5","qty":1},{"code":"1000755871","item":"(주니아)아이스컵,뚜껑,돔리드,DIA92MM,1000EA/BOX","biz":"주니아_판교IT센터점 [A0358217]","bizCode":"A0358217","inb":"2","zone":"C5","qty":1},{"code":"1000755863","item":"(주니아)파니니용기,크라프트,도시락2호,600EA/BOX","biz":"주니아_판교IT센터점 [A0358217]","bizCode":"A0358217","inb":"2","zone":"C5","qty":1},{"code":"1000757230","item":"(주니아)포켓(반)봉투,200*240MM,무지,코팅,1000EA/BOX","biz":"주니아_길음역점 [A0343453]","bizCode":"A0343453","inb":"3","zone":"D2","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(중랑상봉점) [A0356265]","bizCode":"A0356265","inb":"1","zone":"A9","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(송파점_신) [A0381595]","bizCode":"A0381595","inb":"2","zone":"C5","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(서울역점) [A0346656]","bizCode":"A0346656","inb":"3","zone":"D3","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(분당점) [A0357188]","bizCode":"A0357188","inb":"3","zone":"D5","qty":1},{"code":"1000767819","item":"(파스타예요)사각죽용기뚜껑,130*180MM,PP,500EA/BOX","biz":"파스타예요(성남점_新) [A0383113]","bizCode":"A0383113","inb":"4","zone":"F4","qty":1},{"code":"1000767816","item":"(포엠)사각죽용기몸체,대,180*130*H65MM,1000ML,PP,50","biz":"파스타예요(분당점) [A0357188]","bizCode":"A0357188","inb":"3","zone":"D5","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(중랑상봉점) [A0356265]","bizCode":"A0356265","inb":"1","zone":"A9","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(서울역점) [A0346656]","bizCode":"A0346656","inb":"3","zone":"D3","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(강서본점) [A0383157]","bizCode":"A0383157","inb":"4","zone":"F4","qty":1},{"code":"1000767817","item":"(포엠)사각죽용기몸체,중,180*130*H55MM,850ML,PP,500","biz":"파스타예요(성남점_新) [A0383113]","bizCode":"A0383113","inb":"4","zone":"F4","qty":1},{"code":"1000771713","item":"(포케올데이)랩샌드위치노루지,30*30CM,1도인쇄,코팅40G,1000E","biz":"POKE 분당야탑점 [A0354014]","bizCode":"A0354014","inb":"3","zone":"D5","qty":1},{"code":"1000767985","item":"(포케올데이)스프용기뚜껑,330CC,100파이*15MM,두겹,무지,500","biz":"POKE 안암점 [A0349142]","bizCode":"A0349142","inb":"4","zone":"F7","qty":1},{"code":"1000758813","item":"(프로티너)냅킨,흰색,115*115MM,크라프트,삼양앤컴퍼니,10000E","biz":"잠실방이점_프로티너 [A0406254]","bizCode":"A0406254","inb":"3","zone":"D8","qty":1},{"code":"1000758814","item":"(프로티너)물티슈,무지,100*70MM(포장지),200*130MM(속지)","biz":"잠실방이점_프로티너 [A0406254]","bizCode":"A0406254","inb":"3","zone":"D8","qty":1},{"code":"1000759547","item":"(프로티너)소스컵뚜껑,1OZ,45파이,무타공,평리드,DIA45MM,PET","biz":"홍대입구역점_프로티너 [A0395443]","bizCode":"A0395443","inb":"4","zone":"F7","qty":1},{"code":"1000759544","item":"(프로티너)소스컵뚜껑,2OZ,62파이,무타공,평리드,DIA62MM,PET","biz":"홍대입구역점_프로티너 [A0395443]","bizCode":"A0395443","inb":"4","zone":"F7","qty":1},{"code":"1000759541","item":"(프로티너)소스컵몸체,2OZ,62파이,DIA62MM,PET,2000EA/","biz":"홍대입구역점_프로티너 [A0395443]","bizCode":"A0395443","inb":"4","zone":"F7","qty":1},{"code":"1000759549","item":"(프로티너)펄프용기뚜껑,PET,500EA/BOX","biz":"판교역점_프로티너 [A0401308]","bizCode":"A0401308","inb":"3","zone":"D8","qty":1},{"code":"1000759548","item":"(프로티너)펄프용기몸체,1칸,210X130X70MM,1000ML,500E","biz":"판교역점_프로티너 [A0401308]","bizCode":"A0401308","inb":"3","zone":"D8","qty":1},{"code":"1000794792","item":"(허그런치)1350CC컵지용기,300EA/BOX,180*155*73MM","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":3},{"code":"1000794793","item":"(허그런치)180ǾPET뚜껑,300EA/BOX","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":3},{"code":"1000773313","item":"(허그런치)대나무젓가락,현대산업,개별포장,인쇄,2000EA/BOX","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":7},{"code":"1000773313","item":"(허그런치)대나무젓가락,현대산업,개별포장,인쇄,2000EA/BOX","biz":"허그런치(성남) [A0338096]","bizCode":"A0338096","inb":"3","zone":"D5","qty":2},{"code":"1000774531","item":"(허그런치)일회용숟가락,개별포장,백색,L175MM,1500EA/BOX","biz":"허그런치(시흥) [A0280723]","bizCode":"A0280723","inb":"2","zone":"C3","qty":8},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 강서점) [A0396385]","bizCode":"A0396385","inb":"3","zone":"D6","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울역삼점) [A0345675]","bizCode":"A0345675","inb":"3","zone":"D7","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(수원 영통점) [A0376534]","bizCode":"A0376534","inb":"3","zone":"D8","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(화성 동탄점) [A0403097]","bizCode":"A0403097","inb":"3","zone":"D8","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000773357","item":"(호호솥밥)먹는법스티커,100MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 서대문점) [A0401568]","bizCode":"A0401568","inb":"4","zone":"F7","qty":1},{"code":"1000783957","item":"(호호솥밥)비닐쇼핑백,중,그린팩,37(M16*2)*50MM,2도,500E","biz":"호호솥밥(안양 만안점) [A0403098]","bizCode":"A0403098","inb":"3","zone":"D8","qty":1},{"code":"1000783957","item":"(호호솥밥)비닐쇼핑백,중,그린팩,37(M16*2)*50MM,2도,500E","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(분당 판교점) [A0366132]","bizCode":"A0366132","inb":"2","zone":"C5","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(경기 안산점) [A0403069]","bizCode":"A0403069","inb":"3","zone":"D7","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(서울역삼점) [A0345675]","bizCode":"A0345675","inb":"3","zone":"D7","qty":2},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(서울 송파점) [A0398066]","bizCode":"A0398066","inb":"3","zone":"D8","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(화성 동탄점) [A0403097]","bizCode":"A0403097","inb":"3","zone":"D8","qty":1},{"code":"1000771764","item":"(호호솥밥)솥밥용기/뚜껑/PET,160파이,300EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(분당 판교점) [A0366132]","bizCode":"A0366132","inb":"2","zone":"C5","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(경기 안산점) [A0403069]","bizCode":"A0403069","inb":"3","zone":"D7","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(서울역삼점) [A0345675]","bizCode":"A0345675","inb":"3","zone":"D7","qty":2},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(서울 송파점) [A0398066]","bizCode":"A0398066","inb":"3","zone":"D8","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(화성 동탄점) [A0403097]","bizCode":"A0403097","inb":"3","zone":"D8","qty":1},{"code":"1000771760","item":"(호호솥밥)솥밥용기/용기/크라프트,160파이/900ML,300EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771765","item":"(호호솥밥)원형스티커,80MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 강서점) [A0396385]","bizCode":"A0396385","inb":"3","zone":"D6","qty":1},{"code":"1000771765","item":"(호호솥밥)원형스티커,80MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000771765","item":"(호호솥밥)원형스티커,80MM/아트/코팅,1000EA/BOX","biz":"호호솥밥(서울 서대문점) [A0401568]","bizCode":"A0401568","inb":"4","zone":"F7","qty":1},{"code":"1000775934","item":"(화계전통)타원찜용기,소,뚜껑,100EA/BOX","biz":"화계전통_서울시립대점 [A0359892]","bizCode":"A0359892","inb":"2","zone":"C3","qty":1},{"code":"1000775933","item":"(화계전통)타원찜용기,소,몸체,100EA/BOX","biz":"화계전통_서울시립대점 [A0359892]","bizCode":"A0359892","inb":"2","zone":"C3","qty":1},{"code":"1000743500","item":"냉면용기뚜껑,중,DIA200MM,PP,200EA/BOX","biz":"헬키푸키 석촌점 [A0302818]","bizCode":"A0302818","inb":"2","zone":"C3","qty":1},{"code":"1000743500","item":"냉면용기뚜껑,중,DIA200MM,PP,200EA/BOX","biz":"혜준당_보문점 [A0404129]","bizCode":"A0404129","inb":"3","zone":"D8","qty":1},{"code":"1000743499","item":"냉면용기몸체,중,DIA200MM*H70MM,PP,200EA/BOX","biz":"헬키푸키 석촌점 [A0302818]","bizCode":"A0302818","inb":"2","zone":"C3","qty":1},{"code":"1000743499","item":"냉면용기몸체,중,DIA200MM*H70MM,PP,200EA/BOX","biz":"혜준당_보문점 [A0404129]","bizCode":"A0404129","inb":"3","zone":"D8","qty":1},{"code":"1000765857","item":"수저세트,무지,검정,숟가락(L170MM,PP),젓가락(L180MM,대나무","biz":"뜨돈 시흥 배곧점 [A0361335]","bizCode":"A0361335","inb":"3","zone":"D7","qty":1},{"code":"1000765857","item":"수저세트,무지,검정,숟가락(L170MM,PP),젓가락(L180MM,대나무","biz":"호호솥밥(평택 비전점) [A0402426]","bizCode":"A0402426","inb":"4","zone":"F2","qty":1},{"code":"1000455371","item":"종이컵,10OZ,로앤그린,친환경,DIA85*H95MM,1000EA/BOX","biz":"블루엘리펀트 성수 [A0388469]","bizCode":"A0388469","inb":"1","zone":"A9","qty":1},{"code":"1000756544","item":"종이컵,92파이,20OZ,대크린상,DIA92MM,1000EA/BOX","biz":"블루엘리펀트 성수 [A0388469]","bizCode":"A0388469","inb":"1","zone":"A9","qty":1}];

  function ssBrand(item){ var m=/^\(([^)]+)\)/.exec(item||''); return m?m[1]:'기타·공통'; }
  // 행 분류(묶음): 사업장코드가 TBL_BIZI_MST(ssBiziMap)에 있으면 그 사업장명으로, 없으면 품목명 () 접두어로
  function ssRowBrand(r){
    var bc=(''+((r&&r.bizCode)||'')).trim();
    var m=window.ssBiziMap||{};
    if(bc && m[bc]) return m[bc];
    return ssBrand(r&&r.item);
  }
  // TBL_BIZI_MST 조회 → ssBiziMap{사업장코드:사업장명}. 분류 직전 항상 최신화(수정 즉시 반영)
  function ssLoadBiziMst(cb){
    fetch('${pageContext.request.contextPath}/shipout/selectBiziMst.do', { method:'POST', credentials:'same-origin' })
    .then(function(res){ return res.text(); })
    .then(function(txt){
      try{ var j=JSON.parse(txt); var m={}; (j.data||[]).forEach(function(o){ var c=(''+(o.bizCd||'')).trim(); if(c) m[c]=(''+(o.bizNm||'')).trim(); }); window.ssBiziMap=m; }
      catch(e){ if(!window.ssBiziMap) window.ssBiziMap={}; }
      if(cb) cb();
    })
    .catch(function(){ if(!window.ssBiziMap) window.ssBiziMap={}; if(cb) cb(); });
  }
  // 품목명에서 앞쪽 (사업장/브랜드) 접두 제거 — 상단 그룹헤더와 중복 방지
  function ssShortName(item){ return (''+(item||'')).trim(); }   // 품목명 () 접두 포함해서 그대로 표시
  function ssHash(s){ var h=5381,i; for(i=0;i<s.length;i++) h=((h<<5)+h+s.charCodeAt(i))>>>0; return h; }
  function ssNum(n){ return (Math.round(n||0)).toLocaleString(); }
  function ssSet(id,html){ var e=document.getElementById(id); if(e) e.innerHTML=html; }

  // 발주현황표 → 집계 (출고장=행, 품목=열 / 품목코드 매칭 / 선택일=당일 필터)
  function ssAggregate(){
    var from=(document.getElementById('ssDateFrom')||{}).value||'';
    var to=(document.getElementById('ssDateTo')||{}).value||'';
    var zoneTot={}, zoneInb={}, items={}, bizSet={}, matrix={}, zoneSet={}, unassigned=0, totQty=0, unassignedList=[], unMatrix={}, unCnt={}, unNames=[], unTot=0;
    var brandCodes={}, brandBiz={};   // 브랜드(열 묶음) → 사업장코드/사업장명 집합
    SHIP_DATA.forEach(function(r){
      var d=r.date||SS_TODAY;
      if(from && d<from) return;          // ★ 시작일자 이전 제외
      if(to && d>to) return;              // ★ 종료일자 이후 제외
      var q = +r.qty||0;
      if(r.biz) bizSet[r.biz]=1;
      // 브랜드별 사업장코드/사업장명 수집(존 지정·미지정 모두 포함)
      var _br0=ssRowBrand(r), _bc0=(''+(r.bizCode||'')).trim();
      if(_bc0){ (brandCodes[_br0]=brandCodes[_br0]||{})[_bc0]=1; }
      if(r.biz){ (brandBiz[_br0]=brandBiz[_br0]||{})[r.biz]=1; }
      if(!r.zone){                         // 존 미지정 → 미배정 집계
        var sn=ssShortName(r.item);
        unassigned++; unassignedList.push((r.biz||'')+' · '+sn);
        var uk=(''+(r.code||'')).trim() ? (''+(r.code||'')).trim() : ('NM:'+r.item);
        unMatrix[uk]=(unMatrix[uk]||0)+q; unCnt[uk]=(unCnt[uk]||0)+1; unTot+=q;
        if(unNames.indexOf(sn)<0) unNames.push(sn);
        return;
      }
      totQty += q;
      var code=(''+(r.code||'')).trim();
      var key = code ? code : ('NM:'+r.item);   // ★ 품목코드로 매칭
      var br=ssRowBrand(r);
      if(!items[key]) items[key]={code:code, name:r.item, brand:br, qty:0};
      items[key].qty+=q;
      zoneSet[r.zone]=1; zoneTot[r.zone]=(zoneTot[r.zone]||0)+q; zoneInb[r.zone]=(r.inb||'');
      matrix[r.zone]=matrix[r.zone]||{};
      matrix[r.zone][key]=(matrix[r.zone][key]||0)+q;
    });
    // 직접 추가한 품목을 빈 열로 포함(데이터 없어도 열 표시)
    (ssExtraItems||[]).forEach(function(e){ if(!items[e.key]) items[e.key]={code:e.code||'', name:e.name, brand:ssBrand(e.name), qty:0}; });
    // 직접 추가한 존을 빈 행으로 포함
    (ssExtraZones||[]).forEach(function(z){ z=(''+z).trim().toUpperCase(); if(!z) return; zoneSet[z]=1; if(!(z in zoneTot)) zoneTot[z]=0; if(!zoneInb[z]) zoneInb[z]=({A:'1',C:'2',D:'3',F:'4'})[z.charAt(0)]||''; });
    return {items:items,matrix:matrix,zoneTot:zoneTot,zoneInb:zoneInb,zoneSet:zoneSet,bizSet:bizSet,brandCodes:brandCodes,brandBiz:brandBiz,unassigned:unassigned,unassignedList:unassignedList,unMatrix:unMatrix,unCnt:unCnt,unNames:unNames,unTot:unTot,totQty:totQty};
  }

  var SS_MONTHS=['5월','4월','3월','2월','1월'];  // 데모용 과거 월

  // 화면 표시용 물류센터 그룹/순서 (데시보드2와 동일 — 특정 코드는 오산센터로 묶고 지정순서로). DB 저장 무관
  var SS_DCGROUP={ 'E200':'오산센터','E400':'오산센터','E300':'오산센터','E600':'오산센터','E700':'오산센터' };   // E600=제주
  var SS_ZONEORDER=['E200','E400','E300','E600','E700'];
  function ssRender(){
    var tbl=document.getElementById('ssWideTbl'); if(!tbl) return;
    var ag=ssAggregate();
    var _cb=document.getElementById('ssSumFront'); ssSumFront=!!(_cb&&_cb.checked);
    // 합계 셀을 맨앞/끝 위치에 맞춰 배치
    function wrapSum(stickHtml, dataCells, sumCell){ return stickHtml + (ssSumFront?sumCell:'') + dataCells + (ssSumFront?'':sumCell); }
    // 칸 직접수정 → 해당 (일자·존·품목) 데이터 재작성 → 합계 자동 재계산
    window.ssEditKey=function(e,td){ if(e.key==='Enter'){ e.preventDefault(); td.blur(); } };
    window.ssEditCell=function(td){
      var z=td.getAttribute('data-z'), k=td.getAttribute('data-k');
      var v=parseFloat((td.textContent||'').replace(/[^0-9.\-]/g,''))||0; if(v<0) v=0;
      var d=(document.getElementById('ssDateFrom')||{}).value||SS_TODAY;
      var meta=ssItemMeta[k]||{name:k,code:''};
      var inb=({A:'1',C:'2',D:'3',F:'4'})[(z.charAt(0)||'').toUpperCase()]||'';
      SHIP_DATA=SHIP_DATA.filter(function(r){
        var rk=(''+(r.code||'')).trim()?(''+(r.code||'')).trim():('NM:'+r.item);
        return !(((r.date||SS_TODAY)===d) && r.zone===z && rk===k);
      });
      if(v>0) SHIP_DATA.push({code:(meta.code||''), item:meta.name, biz:'', inb:inb, zone:z, qty:v, date:d});
      ssRender();
    };

    // ── KPI (당일=선택일 기준) — 컴팩트 숫자
    ssSet('ssKpiItem', ssNum(Object.keys(ag.items).length));
    ssSet('ssKpiQty',  ssNum(ag.totQty));
    ssSet('ssKpiZone', ssNum(Object.keys(ag.zoneTot).length));
    // 사업장 = 헤더 그룹과 동일(브랜드 묶음) 기준
    var _brs={}; Object.keys(ag.items).forEach(function(k){ _brs[ag.items[k].brand]=1; });
    ssSet('ssKpiBiz',  ssNum(Object.keys(_brs).length));

    // ── 기간 정보 밴드
    var from=(document.getElementById('ssDateFrom')||{}).value||'';
    var to=(document.getElementById('ssDateTo')||{}).value||'';
    var dts=ssAllDates(); var hasData=(ag.totQty>0 || Object.keys(ag.items).length>0);
    var prefix = (from && from===to) ? (from===SS_TODAY?'당일':'선택일') : '기간';
    ssSet('ssKpiPrefix', prefix);
    // 당일/당월 버튼 선택 표시 + 활성 규칙
    var single = !!(from && from===to);
    var ym2=SS_TODAY.slice(0,7), monFrom=ym2+'-01';
    var _md=new Date(); var monLast=ym2+'-'+ssPad(new Date(_md.getFullYear(), _md.getMonth()+1, 0).getDate());
    var isToday = single && from===SS_TODAY;
    var isMonth = (from===monFrom && to===monLast);
    var bt=document.getElementById('ssBtnToday'); if(bt) bt.className = isToday?'btn-teal':'btn-line';
    var bm=document.getElementById('ssBtnMonth'); if(bm) bm.className = isMonth?'btn-teal':'btn-line';
    // 매출·매입/저장 버튼: 일자별(시작=종료 단일 일자)일 때만 활성 — 당월·기간(시작≠종료) 모드면 비활성
    ['ssBtnSales','ssBtnCost','ssBtnSave'].forEach(function(id){
      var b=document.getElementById(id); if(!b) return;
      b.disabled=!single; b.title = single ? '' : '일자별(시작=종료 단일 일자) 조건에서만 가능합니다';
    });
    // 발주현황표 업로드는 조회 기간과 무관하게 항상 활성 (출고일자는 미리보기에서 지정)
    var bu=document.getElementById('ssBtnUpload'); if(bu){ bu.disabled=false; bu.title=''; }
    var bd=document.getElementById('ssBtnDownload'); if(bd){ bd.disabled=false; bd.title=''; }
    var range = (from && from===to) ? (from + (from===SS_TODAY?' <b>(금일)</b>':'')) : (from||'~')+' ~ '+(to||'~');
    var info='<span class="ss-srcbadge'+(window.ssSrcUp?' up':'')+'">'+(window.ssSrcInfo||'내장 샘플')+'</span> 📅 '+range
      + (hasData ? '' : ' &nbsp;|&nbsp; <span style="color:#c0392b">해당 기간 데이터 없음</span>')
      + (dts.length>1 ? ' &nbsp;|&nbsp; 파일 출고일자 '+dts.length+'개: '+dts.map(function(x){return x.d+'('+x.n+')';}).join(', ') : '')
      + (ag.unassigned>0 ? ' &nbsp;|&nbsp; <span style="color:#c0392b; cursor:help" title="출고장 미지정 발주 — 출고장이 비어 집계 제외&#10;'+(ag.unassignedList||[]).join('&#10;').replace(/"/g,'&quot;')+'">미배정 '+ag.unassigned+'건 ⓘ</span>' : '');
    ssSet('ssDateInfo', info);

    // ── 사업장(브랜드) 선택 옵션
    var brands={}; Object.keys(ag.items).forEach(function(k){ brands[ag.items[k].brand]=1; });
    var brandList=Object.keys(brands).sort(function(a,b){ return a.localeCompare(b,'ko'); });
    var sel=document.getElementById('ssBizSel');
    var keep = sel.value || '__ALL__';
    if(sel.options.length !== brandList.length+1){
      sel.innerHTML='<option value="__ALL__">전체 ('+brandList.length+' 사업장)</option>'
        + brandList.map(function(b){ return '<option value="'+b+'">'+b+'</option>'; }).join('');
      sel.value = brandList.indexOf(keep)>=0 ? keep : '__ALL__';
    }
    // 사업장 찾기 자동완성 목록 동기화
    var dl=document.getElementById('ssBizFindList');
    if(dl){ dl.innerHTML = brandList.map(function(b){ return '<option value="'+b.replace(/"/g,'&quot;')+'">'; }).join(''); }
    var pick=sel.value;

    // ── 품목(열) 순서: 사업장 → 품목명
    var keys=Object.keys(ag.items);
    if(pick && pick!=='__ALL__') keys=keys.filter(function(k){ return ag.items[k].brand===pick; });
    keys.sort(function(a,b){
      var A=ag.items[a],B=ag.items[b];
      return A.brand.localeCompare(B.brand,'ko') || A.name.localeCompare(B.name,'ko');
    });
    keys=keys.filter(function(k){ return !ssBizHidden[ag.items[k].brand]; });  // 숨긴 사업장 제외
    // 숨긴 사업장 복원 바
    var hb=document.getElementById('ssHiddenBar');
    if(hb){ var hd=Object.keys(ssBizHidden).filter(function(b){return ssBizHidden[b];});
      if(hd.length){ hb.style.display='flex';
        hb.innerHTML='<span class="hb-lbl">🙈 숨긴 사업장:</span>'
          + hd.map(function(b){ return '<span class="hb-chip" data-br="'+b.replace(/"/g,'&quot;')+'" onclick="ssBizShowName(this.getAttribute(\'data-br\'))">'+b+' ↩</span>'; }).join('')
          + '<button class="btn-line" style="padding:3px 11px; margin-left:4px" onclick="ssBizShowAll()">전체 펼치기</button>';
      } else { hb.style.display='none'; hb.innerHTML=''; }
    }
    var zones=Object.keys(ag.zoneSet).sort();
    window.ssZoneList=zones.slice();
    var INB={'1':'1입고장','2':'2입고장','3':'3입고장','4':'4입고장'};
    var ncol=keys.length+2;

    if(!keys.length){ tbl.innerHTML='<tbody><tr><td style="padding:24px;color:#9aa7b3">표시할 품목이 없습니다.</td></tr></tbody>'; return; }

    // 사업장(브랜드) 그룹의 첫 열 = 구분선 위치
    var gstartKeys={}, groupIdxOf={}, _pb=null, _giSeq=-1;
    keys.forEach(function(k){ var br=ag.items[k].brand; if(br!==_pb){ gstartKeys[k]=true; _pb=br; _giSeq++; } groupIdxOf[k]=_giSeq; });
    function gs(k){ return (gstartKeys[k]?' gstart':'')+' bg'+groupIdxOf[k]; }
    // 직접 수정용 메타 + 편집가능 여부(당일 모드만)
    ssItemMeta={}; keys.forEach(function(k){ ssItemMeta[k]={name:ag.items[k].name, code:ag.items[k].code}; });
    var _bl={}; keys.forEach(function(k){ _bl[ag.items[k].brand]=1; }); window.ssBrandList=Object.keys(_bl).sort();
    window.ssItemList=keys.map(function(k){ return {name:ssShortName(ag.items[k].name), full:ag.items[k].name, code:ag.items[k].code||'', brand:ag.items[k].brand}; });
    var ssEditable = single;   // 시작=종료(당일)일 때만 칸 직접수정

    // ── thead : 1행 사업장 / 2행 품목명(코드)
    var _itemCnt=keys.length, _brSet={}; keys.forEach(function(k){ _brSet[ag.items[k].brand]=1; }); var _brCnt=Object.keys(_brSet).length;
    var sumTh='<th class="colsum" rowspan="2">합계<span class="sumcnt">사업장 '+_brCnt+'<br>품목 '+_itemCnt+'</span></th>';
    var th1='<tr><th class="stick" rowspan="2">출고장 \\ 품목</th>'+(ssSumFront?sumTh:'');
    var th2='<tr>';
    var groupsArr=[];   // 그룹별 열 수 (배너행 구분선용)
    var i=0;
    while(i<keys.length){
      var br=ag.items[keys[i]].brand, j=i;
      while(j<keys.length && ag.items[keys[j]].brand===br) j++;
      groupsArr.push(j-i);
      // 브랜드 헤더에 사업장코드 표시 (여러 개면 앞 3개 + '외 N', 전체는 툴팁)
      var _codes=Object.keys((ag.brandCodes||{})[br]||{}).sort();
      var _bizs=Object.keys((ag.brandBiz||{})[br]||{}).sort();
      var _codeHtml = _codes.length ? ('<span class="bizcode">['+_codes.slice(0,3).join(', ')+(_codes.length>3?(' 외 '+(_codes.length-3)):'')+']</span>') : '';
      var _ttl = _codes.length ? ('사업장코드 '+_codes.length+'개\n'+_bizs.join('\n')+'\n(클릭 시 이 사업장 열 숨기기)') : '클릭 시 이 사업장 열 숨기기';
      th1+='<th class="bizh gstart bg'+groupIdxOf[keys[i]]+'" colspan="'+(j-i)+'" data-br="'+br.replace(/"/g,'&quot;')+'" onclick="ssBizHideName(this.getAttribute(\'data-br\'))" title="'+_ttl.replace(/"/g,'&quot;')+'">'+br+_codeHtml+' <span class="bx">✕</span></th>';
      for(var p=i;p<j;p++){ var it=ag.items[keys[p]];
        var _isEx=(ssExtraItems||[]).some(function(e){return e.key===keys[p];}), _q0=((it.qty||0)===0);
        var _delx=(_isEx&&_q0)?'<span class="delx" data-dk="'+(''+keys[p]).replace(/"/g,'&quot;')+'" onclick="ssDelItem(event,this)" title="추가 품목 삭제(수량 없음)">✕</span>':'';
        th2+='<th class="prodh'+gs(keys[p])+'" title="'+it.name.replace(/"/g,'&quot;')+'">'+ssShortName(it.name)+'<span class="pc">'+(it.code||'-')+'</span>'+_delx+'</th>';
      }
      i=j;
    }
    th1+=(ssSumFront?'':sumTh)+'</tr>'; th2+='</tr>';
    // 배너행(머리줄/구분줄): 그룹 경계마다 구분선이 지나가도록 분할 셀 생성
    function ssBannerCells(descHtml){
      var h='';
      groupsArr.forEach(function(sz,gi){
        h+='<td colspan="'+sz+'"'+(gi>0?' class="gstart"':'')+(gi===0?' style="text-align:left"':'')+'>'+(gi===0?descHtml:'')+'</td>';
      });
      return h;
    }

    // ── tbody : 출고장(존) 행 — A존~F존(영문) 그룹별 + 그룹 합계
    var LETTER_INB={'A':'1입고장','B':'','C':'2입고장','D':'3입고장','E':'','F':'4입고장'};
    // 출고장→물류센터코드 맵 + 그룹키(오산센터 묶음)·정렬순서 (데시보드2와 동일 규칙)
    var ssZoneDcCd={};
    (SHIP_DATA||[]).forEach(function(r){ if(r&&r.zone&&r.dcCd && !ssZoneDcCd[r.zone]) ssZoneDcCd[r.zone]=r.dcCd; });
    function ssGrpKey(z){ var cd=ssZoneDcCd[z]||''; if(SS_DCGROUP[cd] || /제주/.test(z)) return 'OSAN'; return (z.charAt(0)||'').toUpperCase(); }
    function ssZoneRank(z){ var cd=ssZoneDcCd[z]||''; var i=SS_ZONEORDER.indexOf(cd); if(i<0 && /제주/.test(z)) i=SS_ZONEORDER.indexOf('E600'); return i<0?999:i; }
    var byL={}, letters=[];
    zones.forEach(function(z){ var L=ssGrpKey(z); if(!byL[L]){ byL[L]=[]; letters.push(L); } byL[L].push(z); });
    // 그룹 내 정렬: 오산센터는 지정순서(E200·E400·E300·제주·E700), 그 외는 이름순
    Object.keys(byL).forEach(function(L){ byL[L].sort(function(a,b){ var ra=ssZoneRank(a), rb=ssZoneRank(b); if(ra!==rb) return ra-rb; return a.localeCompare(b,'ko'); }); });
    // 그룹키(L) → 표시라벨(물류센터명) 매핑 — 데시보드2와 공유하는 순서 기준(라벨)
    window.ssGroupLabels={};
    letters.forEach(function(L){ if(L==='OSAN'){ window.ssGroupLabels[L]='오산센터'; return; } var _n=(''+(byL[L][0]||'')).replace(/\s*\d+\s*$/,'').trim(); window.ssGroupLabels[L]=(_n.length>1)?_n:(L+'출고장'); });
    ssGroupOrder=ssGordLoad();   // 최신 공유 순서 반영(데시보드2에서 바꾼 것도 즉시 적용)
    // 그룹 순서: 저장된 사용자 지정 순서(물류센터명 기준) 우선, 미지정 그룹은 ㄱㄴㄷ순 뒤에 (데시보드2와 동일 규칙)
    letters.sort(function(a,b){
      var la=window.ssGroupLabels[a], lb=window.ssGroupLabels[b];
      var ia=ssGroupOrder.indexOf(la), ib=ssGroupOrder.indexOf(lb);
      if(ia>=0 && ib>=0) return ia-ib;
      if(ia>=0) return -1;
      if(ib>=0) return 1;
      return la.localeCompare(lb,'ko');
    });
    window.ssLetters=letters.slice();
    ssGordRenderPop(letters);
    // 출고장별 발주일자(납기일자) — 출고일자와 같든 다르든 항상 표시
    var zoneDlv={};
    (SHIP_DATA||[]).forEach(function(r){ if(!r||!r.zone) return; var d=(''+(r.dlvDt||'')).trim(); if(!d) return; (zoneDlv[r.zone]=zoneDlv[r.zone]||{})[d]=1; });
    function zoneDlvNote(z){
      var a=Object.keys(zoneDlv[z]||{}).filter(function(d){ return !!d; }).sort();
      return a.length ? ' <span class="sub2" style="color:#c47f17;font-weight:700">(발주일자 '+a.join(', ')+')</span>' : '';
    }
    var colTot={}, grand=0, tb='';
    letters.forEach(function(L){
      var col; if(L in ssZoneCollapsed){ col=!!ssZoneCollapsed[L]; } else { col=ssZoneDefaultCollapsed; ssZoneCollapsed[L]=col; }   // 기본=펼침
      // 그룹 라벨: OSAN→'오산센터', 그 외는 출고장명 끝 숫자 떼어 물류센터명 (ssGroupLabels 재사용)
      var _glabel=window.ssGroupLabels[L] || ((''+(byL[L][0]||'')).replace(/\s*\d+\s*$/,'').trim() || (L+'출고장'));
      var lgDesc=byL[L].length+'개 출고장'+(col?' <span style="color:#9aa7b3">— 접힘(클릭하여 펼치기)</span>':'');
      tb+='<tr class="lgrp" onclick="ssToggleZone(\''+L+'\')">'
        + wrapSum('<td class="stick"><span class="zcaret" id="zc_'+L+'">'+(col?'▶':'▼')+'</span> '+_glabel+'</td>', ssBannerCells(lgDesc), '<td class="colsum"></td>') + '</tr>';
      var lCol={}, lSum=0;
      byL[L].forEach(function(z){
        var rowSum=0, cells='';
        keys.forEach(function(k){
          var v=(ag.matrix[z]&&ag.matrix[z][k])||0; rowSum+=v; colTot[k]=(colTot[k]||0)+v; lCol[k]=(lCol[k]||0)+v;
          if(ssEditable){
            cells+='<td class="num edit'+gs(k)+(v>0?'':' zero')+'" contenteditable="true" data-z="'+z+'" data-k="'+(''+k).replace(/"/g,'&quot;')+'" onblur="ssEditCell(this)" onkeydown="ssEditKey(event,this)">'+(v>0?ssNum(v):'')+'</td>';
          } else {
            cells+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>';
          }
        });
        grand+=rowSum; lSum+=rowSum;
        var _isExZ=(ssExtraZones||[]).indexOf(z)>=0, _zdelx=(_isExZ&&rowSum===0)?' <span class="delx" data-dz="'+z+'" onclick="ssDelZone(event,this)" title="추가 출고장 삭제(수량 없음)">✕</span>':'';
        tb+='<tr class="zg_'+L+'"'+(col?' style="display:none"':'')+'>'+wrapSum('<td class="stick">&nbsp;&nbsp;'+z+' 출고장'+zoneDlvNote(z)+_zdelx+'</td>', cells, '<td class="num colsum">'+ssNum(rowSum)+'</td>')+'</tr>';
      });
      var lc=''; keys.forEach(function(k){ lc+='<td class="num'+gs(k)+'">'+ssNum(lCol[k]||0)+'</td>'; });
      tb+='<tr class="lsub">'+wrapSum('<td class="stick">'+_glabel+' 합계</td>', lc, '<td class="num colsum">'+ssNum(lSum)+'</td>')+'</tr>';
    });
    // 전체 출고장 합계
    var ztc=''; keys.forEach(function(k){ ztc+='<td class="num'+gs(k)+'">'+ssNum(colTot[k]||0)+'</td>'; });
    tb+='<tr class="ztot">'+wrapSum('<td class="stick">전체 출고장 합계</td>', ztc, '<td class="num colsum">'+ssNum(grand)+'</td>')+'</tr>';
    // 미배정(존 미지정) 행 — 존이 비어 집계에서 빠진 발주
    if(ag.unassigned>0){
      var uTitle=('출고장 미지정 발주\n'+(ag.unassignedList||[]).join('\n')).replace(/"/g,'&quot;');
      var uLbl='⚠ 미배정 '+ag.unassigned+'건';
      var uc=''; keys.forEach(function(k){ var c=ag.unCnt[k]||0, v=ag.unMatrix[k]||0; uc+= c>0?'<td class="num uhl'+gs(k)+'" title="미배정 '+c+'건 (출고장·수량 미지정)">'+(v>0?ssNum(v):'0')+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
      tb+='<tr class="unrow">'+wrapSum('<td class="stick" title="'+uTitle+'">'+uLbl+'</td>', uc, '<td class="num colsum">'+ssNum(ag.unTot)+'</td>')+'</tr>';
    }

    // ── 하단 출고내역 · 재고량
    tb+='<tr class="sec">'+wrapSum('<td class="stick">📦 출고내역·재고</td>', ssBannerCells('<span style="font-weight:400;color:#aef0e7">선택일=선택기간 출고 / 당월=이번달 전체 / 월별·재고량 데모값</span>'), '<td class="colsum"></td>')+'</tr>';
    // 재고량(기초)
    var sc='',st=0;
    keys.forEach(function(k){ var it=ag.items[k]; var base=30+(ssHash(it.code||it.name)%150); it._base=base; st+=base; sc+='<td class="num'+gs(k)+'">'+ssNum(base)+'</td>'; });
    tb+='<tr class="r-stock">'+wrapSum('<td class="stick">재고량(기초)</td>', sc, '<td class="num colsum">'+ssNum(st)+'</td>')+'</tr>';
    // ★ 선택일(당일/기간) 출고 = 현재 선택 범위 집계 (colTot) — 강조
    var selLbl=(from&&from===to)?(from===SS_TODAY?'당일 출고':'선택일 출고'):'기간 출고';
    var nc='',nt=0;
    keys.forEach(function(k){ var v=colTot[k]||0; nt+=v; nc+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    tb+='<tr class="r-sel">'+wrapSum('<td class="stick">▶ '+selLbl+'</td>', nc, '<td class="num colsum">'+ssNum(nt)+'</td>')+'</tr>';
    // ★ 매출액(납품매출액) — 출고량 바로 아래. 매입단가 엑셀의 품목코드별 매입금액 합
    var hasSales=Object.keys(ssSalesMap).length>0;
    var vc='', vt=0;
    keys.forEach(function(k){ var code=(''+(ag.items[k].code||'')).trim(); var v=(code&&ssSalesMap[code])||0; vt+=v; vc+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    var salesLbl='💰 매출액'+(hasSales?'':' <span style="font-weight:400;color:#a85700">(매출금액 업로드 시 표시)</span>');
    tb+='<tr class="r-sales" title="'+(ssSalesSrc?('출처: '+ssSalesSrc).replace(/"/g,'&quot;'):'매출금액 엑셀을 업로드하세요')+'">'+wrapSum('<td class="stick">'+salesLbl+'</td>', vc, '<td class="num colsum">'+ssNum(vt)+'</td>')+'</tr>';
    // ★ 매입액 — 매출액 바로 아래. 매입금액 엑셀의 품목코드별 매입금액 합
    var hasCost=Object.keys(ssCostMap).length>0;
    var cc2='', ct2=0;
    keys.forEach(function(k){ var code=(''+(ag.items[k].code||'')).trim(); var v=(code&&ssCostMap[code])||0; ct2+=v; cc2+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    var costLbl='🧾 매입액'+(hasCost?'':' <span style="font-weight:400;color:#5b6775">(매입금액 업로드 시 표시)</span>');
    tb+='<tr class="r-cost" title="'+(ssCostSrc?('출처: '+ssCostSrc).replace(/"/g,'&quot;'):'매입금액 엑셀을 업로드하세요')+'">'+wrapSum('<td class="stick">'+costLbl+'</td>', cc2, '<td class="num colsum">'+ssNum(ct2)+'</td>')+'</tr>';
    // ★ 마진 = 매출액 − 매입액 (품목별, 합계) — 매입액 없으면 0으로 보고 마진=매출액 표시
    var gc='', gt=0;
    keys.forEach(function(k){ var code=(''+(ag.items[k].code||'')).trim(); var sv=(code&&ssSalesMap[code])||0, cv2=(code&&ssCostMap[code])||0; var mg=sv-cv2; gt+=mg;
      gc+= (sv||cv2)?('<td class="num'+(mg<0?' neg':'')+gs(k)+'">'+ssNum(mg)+'</td>'):('<td class="num zero'+gs(k)+'">·</td>'); });
    var marginLbl='📊 마진(매출−매입)'+(hasCost?'':' <span style="font-weight:400;color:#5b6775">(매입 미반영 — 매출액 기준)</span>');
    tb+='<tr class="r-margin">'+wrapSum('<td class="stick">'+marginLbl+'</td>', gc, '<td class="num colsum'+(gt<0?' neg':'')+'">'+ssNum(gt)+'</td>')+'</tr>';
    // 당월 출고 = 이번달 전체(선택범위와 무관, 월 기준)
    var ym=SS_TODAY.slice(0,7), mTot={};
    SHIP_DATA.forEach(function(r){ if(!r.zone) return; var d=(''+(r.date||SS_TODAY)); if(d.slice(0,7)!==ym) return; var c=(''+(r.code||'')).trim(), kk=c?c:('NM:'+r.item); mTot[kk]=(mTot[kk]||0)+(+r.qty||0); });
    var mc2='', mAll=0;
    keys.forEach(function(k){ var v=mTot[k]||0; mAll+=v; mc2+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
    tb+='<tr class="r-now">'+wrapSum('<td class="stick">당월 출고('+ym+')</td>', mc2, '<td class="num colsum">'+ssNum(mAll)+'</td>')+'</tr>';
    // 현재고 = 기초 - 선택일 출고
    var cc='',ct=0;
    keys.forEach(function(k){ var it=ag.items[k]; var cur=(it._base||0)-(colTot[k]||0); ct+=cur; cc+='<td class="num'+(cur<0?' neg':'')+gs(k)+'">'+ssNum(cur)+'</td>'; });
    tb+='<tr class="r-stock">'+wrapSum('<td class="stick">현재고</td>', cc, '<td class="num colsum">'+ssNum(ct)+'</td>')+'</tr>';
    // 월별(데모) — 접기/펼치기 가능 (헤더 클릭 토글)
    var _mcol=ssMonthCollapsed;
    tb+='<tr class="lgrp" onclick="ssToggleMonth()">'
      + wrapSum('<td class="stick"><span class="zcaret" id="zc_month">'+(_mcol?'▶':'▼')+'</span> 월별 출고(데모)'+(_mcol?' <span style="color:#9aa7b3">— 접힘(클릭하여 펼치기)</span>':'')+'</td>', ssBannerCells(SS_MONTHS.length+'개월'), '<td class="colsum"></td>') + '</tr>';
    SS_MONTHS.forEach(function(mn){
      var mc='',mt=0;
      keys.forEach(function(k){ var it=ag.items[k]; var v=ssHash((it.code||it.name)+mn)%9; mt+=v; mc+= v>0?'<td class="num'+gs(k)+'">'+ssNum(v)+'</td>':'<td class="num zero'+gs(k)+'">·</td>'; });
      tb+='<tr class="r-month"'+(_mcol?' style="display:none"':'')+'>'+wrapSum('<td class="stick">'+mn+' 출고</td>', mc, '<td class="num colsum">'+ssNum(mt)+'</td>')+'</tr>';
    });

    tbl.innerHTML='<thead>'+th1+th2+'</thead><tbody>'+tb+'</tbody>';
    tbl.classList.toggle('sumfront', ssSumFront);   // 맨앞이면 합계를 출고장 옆 좌측고정
    if(ssSumFront){ var swc=tbl.querySelector('thead th.stick'); if(swc) tbl.style.setProperty('--stickw', swc.offsetWidth+'px'); }
    if(ssBizAnim){ tbl.classList.add('ssc-on'); _ssAnimFocus(); }   // 재렌더 후 현재 사업장 초점 복원
  }

  // ── 사업장 찾기 — 전체는 그대로 보이면서, 찾은 사업장 헤더를 강조 + 그 위치로 스크롤 ──
  //  exactOnly=true : 정확히 일치하는 사업장명일 때만 동작(타이핑 중 과도한 동작 방지)
  function ssBizFind(q, exactOnly){
    q=(q||'').trim(); if(!q) return;
    var sel=document.getElementById('ssBizSel'); if(!sel) return;
    var name=null, part=null;
    for(var i=0;i<sel.options.length;i++){
      var v=sel.options[i].value; if(v==='__ALL__') continue;
      if(v===q){ name=v; break; }
      if(!part && v.indexOf(q)>=0){ part=v; }
    }
    if(!name && !exactOnly) name=part;
    if(!name){ if(!exactOnly) ssToast('🔎 "'+q+'" 사업장을 찾을 수 없습니다.'); return; }
    // 전체가 보이도록 보장 — 필터 해제 + 해당 사업장 숨김 해제 (변경 있을 때만 재렌더)
    var need=false;
    if(sel.value!=='__ALL__'){ sel.value='__ALL__'; need=true; }
    if(ssBizHidden[name]){ delete ssBizHidden[name]; need=true; }
    if(need) ssRender();
    _ssHighlightBiz(name);
  }
  // 찾은 사업장 헤더 강조 + 가운데로 수평 스크롤
  function _ssHighlightBiz(name){
    var box=_ssScrollBox(), tbl=document.getElementById('ssWideTbl');
    if(!box||!tbl) return;
    var ths=tbl.querySelectorAll('thead th.bizh'), hit=null;
    for(var i=0;i<ths.length;i++){
      ths[i].classList.remove('ss-find-hit','ss-find-pulse');
      if(ths[i].getAttribute('data-br')===name) hit=ths[i];
    }
    if(!hit){ return; }
    hit.classList.add('ss-find-hit');
    // 가운데로 수평 스크롤
    var rb=box.getBoundingClientRect(), rt=hit.getBoundingClientRect();
    box.scrollLeft += (rt.left + rt.width/2) - (rb.left + box.clientWidth/2);
    // 펄스 강조(잠깐 깜빡)
    void hit.offsetWidth; hit.classList.add('ss-find-pulse');
  }
  function ssBizFindClear(){
    var inp=document.getElementById('ssBizFind'); if(inp) inp.value='';
    var tbl=document.getElementById('ssWideTbl');
    if(tbl){ var ths=tbl.querySelectorAll('thead th.bizh.ss-find-hit'); for(var i=0;i<ths.length;i++) ths[i].classList.remove('ss-find-hit','ss-find-pulse'); }
    var sel=document.getElementById('ssBizSel'); if(sel && sel.value!=='__ALL__'){ sel.value='__ALL__'; ssRender(); }
  }

  // ── 확대/축소(줌) — 기본화면·전체화면 양쪽에서 표 영역(.ss-scroll) 확대·축소 ──
  var ssZoom=1;
  function _ssApplyZoom(){
    var b=_ssScrollBox(); if(b) b.style.zoom=ssZoom;
    var l=document.getElementById('ssZoomLbl'); if(l) l.textContent=Math.round(ssZoom*100)+'%';
  }
  // 현재 모드(전체화면 vs 기본화면) 선택표시 갱신
  function _ssUpdateModeBtns(){
    var c=_ssFsCard();
    var on = !!(c && (c.classList.contains('ss-fullscreen') || document.fullscreenElement===c));
    var bf=document.getElementById('ssBtnFull'), bb=document.getElementById('ssBtnBasic');
    if(bf) bf.classList.toggle('seg-on', on);
    if(bb) bb.classList.toggle('seg-on', !on);
  }
  function ssZoomIn(){ ssZoom=Math.min(2.5, Math.round((ssZoom+0.1)*10)/10); _ssApplyZoom(); }
  function ssZoomOut(){ ssZoom=Math.max(0.5, Math.round((ssZoom-0.1)*10)/10); _ssApplyZoom(); }
  function ssZoomReset(){ ssZoom=1; _ssApplyZoom(); }

  // ── 전체화면(출고현황표가 화면 전체를 덮음) / 기본화면(복귀) ──
  function _ssFsCard(){ return document.getElementById('ssCard'); }
  function ssFullExpand(){
    var c=_ssFsCard(); if(!c) return;
    // 브라우저 Fullscreen API 우선(진짜 전체화면), 막히면 CSS 오버레이로 화면 덮기
    if(c.requestFullscreen){ c.requestFullscreen().then(function(){ c.classList.add('ss-fullscreen'); _ssUpdateModeBtns(); }).catch(function(){ _ssCoverOn(c); }); }
    else { _ssCoverOn(c); }
  }
  function ssFullExit(){
    if(document.fullscreenElement){ if(document.exitFullscreen) document.exitFullscreen(); }
    _ssCoverOff();
    ssZoomReset();   // 기본화면 = 전체화면 해제 + 원래 크기로
  }
  function _ssCoverOn(c){ c.classList.add('ss-fullscreen'); document.body.style.overflow='hidden'; _ssUpdateModeBtns(); }
  function _ssCoverOff(){ var c=_ssFsCard(); if(c) c.classList.remove('ss-fullscreen'); document.body.style.overflow=''; _ssUpdateModeBtns(); }
  document.addEventListener('fullscreenchange', function(){
    var c=_ssFsCard(); if(!c) return;
    if(document.fullscreenElement===c){ c.classList.add('ss-fullscreen'); }
    else { c.classList.remove('ss-fullscreen'); document.body.style.overflow=''; }
    _ssUpdateModeBtns();
  });

  // ── 사업장 회전 캐러셀 (옵션 체크 시: 사업장을 가운데로 두고 5초마다 좌→우, 끝나면 우→좌로 왕복) ──
  var ssBizAnim=false, _ssAnimTimer=null, _ssAnimIdx=-1, _ssAnimDir=1;
  function _ssScrollBox(){ var t=document.getElementById('ssWideTbl'); return t ? t.closest('.ss-scroll') : null; }
  // 각 사업장(bizh) 그룹을 가시영역 '가운데'로 보내는 스크롤 위치(그룹 순서대로)
  function _ssGroupCenters(){
    var box=_ssScrollBox(), tbl=document.getElementById('ssWideTbl');
    if(!box||!tbl) return [];
    var max=box.scrollWidth-box.clientWidth; if(max<=1) return [];
    var stickW=0;   // 좌측 고정열 폭 — 가운데 계산 시 가시영역에서 제외
    var sc=tbl.querySelector('thead th.stick'); if(sc) stickW+=sc.offsetWidth;
    if(tbl.classList.contains('sumfront')){ var cs=tbl.querySelector('thead th.colsum'); if(cs) stickW+=cs.offsetWidth; }
    var viewCenter=stickW+(box.clientWidth-stickW)/2;
    var arr=[];
    tbl.querySelectorAll('thead th.bizh').forEach(function(th){
      var center=th.offsetLeft+th.offsetWidth/2;
      var left=Math.round(center-viewCenter); if(left<0) left=0; if(left>max) left=max;
      arr.push(left);
    });
    return arr;   // index = 사업장 그룹 인덱스(좌→우)
  }
  // 현재 _ssAnimIdx 사업장만 또렷하게(초점), 나머지는 흐리게
  function _ssAnimFocus(){
    var tbl=document.getElementById('ssWideTbl'); if(!tbl) return;
    tbl.querySelectorAll('.ssc-focus').forEach(function(c){ c.classList.remove('ssc-focus'); });
    if(_ssAnimIdx<0) return;
    tbl.querySelectorAll('.bg'+_ssAnimIdx).forEach(function(c){ c.classList.add('ssc-focus'); });
  }
  function _ssAnimStep(){
    var box=_ssScrollBox(); if(!box) return;
    var centers=_ssGroupCenters(); var n=centers.length; if(n<=0) return;
    if(_ssAnimIdx<0 || _ssAnimIdx>=n){ _ssAnimIdx=0; _ssAnimDir=1; }   // 시작 → 맨 좌측에서 우측으로
    else if(n>1){
      if(_ssAnimIdx+_ssAnimDir>n-1 || _ssAnimIdx+_ssAnimDir<0) _ssAnimDir=-_ssAnimDir;   // 끝 도달 → 방향 반전(왕복)
      _ssAnimIdx+=_ssAnimDir;
    }
    box.scrollTo({left:centers[_ssAnimIdx], behavior:'smooth'});
    _ssAnimFocus();
  }
  function ssToggleBizAnim(){
    var cb=document.getElementById('ssBizAnim'); ssBizAnim=!!(cb&&cb.checked);
    if(_ssAnimTimer){ clearInterval(_ssAnimTimer); _ssAnimTimer=null; }
    var tbl=document.getElementById('ssWideTbl');
    _ssAnimIdx=-1; _ssAnimDir=1;
    if(ssBizAnim){
      if(tbl) tbl.classList.add('ssc-on');
      var centers=_ssGroupCenters();   // 시작은 맨 좌측 사업장에서 우측으로
      if(centers.length){ _ssAnimIdx=0; var box=_ssScrollBox(); if(box) box.scrollTo({left:centers[_ssAnimIdx], behavior:'smooth'}); _ssAnimFocus(); }
      _ssAnimTimer=setInterval(_ssAnimStep, 5000);
    } else {
      if(tbl){ tbl.classList.remove('ssc-on'); tbl.querySelectorAll('.ssc-focus').forEach(function(c){ c.classList.remove('ssc-focus'); }); }
    }
  }

  // 합계 열 위치 (기본=끝)
  var ssSumFront=true;   // 합계 맨앞 기본 체크
  // 매출금액(매입단가 엑셀) — 품목코드별 매출액(매입금액 합)
  //   구조: ssSalesMap[품목코드] = 금액합
  var ssSalesMap={}, ssSalesCnt=0, ssSalesSrc='';
  // 매입금액 — 품목코드별 매입액 합 (엑셀 나중 제공). 마진 = 매출액 − 매입액
  var ssCostMap={}, ssCostCnt=0, ssCostSrc='';
  // 직접 수정용 품목 메타(키→이름/코드)
  var ssItemMeta={};
  // 직접 추가한 사업장·품목(빈 열) / 존(빈 행)
  var ssExtraItems=[];
  var ssExtraZones=[];

  // 사업장(열 그룹) 숨기기/보이기 — 헤더 클릭으로 숨김, 복원바로 펼침
  var ssBizHidden={};
  function ssBizHideName(b){ if(b){ ssBizHidden[b]=true; ssRender(); } }
  function ssBizShowName(b){ if(b){ delete ssBizHidden[b]; ssRender(); } }
  function ssBizShowAll(){ ssBizHidden={}; ssRender(); }

  // 월별(데모) 출고 접기/펼치기 — 상태 유지(재렌더에도 보존)
  var ssMonthCollapsed=true;   // 기본 접힘
  function ssToggleMonth(){
    ssMonthCollapsed=!ssMonthCollapsed;
    var rows=document.querySelectorAll('#ssWideTbl tr.r-month');
    for(var i=0;i<rows.length;i++) rows[i].style.display = ssMonthCollapsed?'none':'';
    var c=document.getElementById('zc_month'); if(c) c.textContent = ssMonthCollapsed?'▶':'▼';
  }
  // 존 그룹(A존~F존) 접기/펼치기 — 상태 유지(재렌더에도 보존)
  var ssZoneCollapsed={}, ssZoneDefaultCollapsed=false;   // 출고장 기본 펼침
  function ssToggleZone(L){
    ssZoneCollapsed[L]=!ssZoneCollapsed[L];
    var col=ssZoneCollapsed[L];
    var rows=document.querySelectorAll('#ssWideTbl tr.zg_'+L);
    for(var i=0;i<rows.length;i++) rows[i].style.display = col?'none':'';
    var c=document.getElementById('zc_'+L); if(c) c.textContent = col?'▶':'▼';
  }
  function ssAllZones(collapse){
    (window.ssLetters||[]).forEach(function(L){
      ssZoneCollapsed[L]=collapse;
      var rows=document.querySelectorAll('#ssWideTbl tr.zg_'+L);
      for(var i=0;i<rows.length;i++) rows[i].style.display = collapse?'none':'';
      var c=document.getElementById('zc_'+L); if(c) c.textContent = collapse?'▶':'▼';
    });
  }
  // 출고장 전체 펼치기/접기 — 단일 토글 버튼
  var ssAllCollapsed=false;   // 기본 펼침 상태와 동기화
  function ssToggleAllZones(){
    ssAllCollapsed=!ssAllCollapsed;
    ssAllZones(ssAllCollapsed);
    var b=document.getElementById('ssBtnZoneToggle');
    if(b) b.textContent = ssAllCollapsed ? '＋ 출고장 펼치기' : '－ 출고장 접기';
  }

  // ── 출고장 그룹(물류센터) 순서 설정 — 데시보드2와 공유(localStorage 'logiGroupOrder', 물류센터명 배열)
  var ssGroupOrder=[];
  function ssGordLoad(){ try{ ssGroupOrder=JSON.parse(localStorage.getItem('logiGroupOrder')||'[]')||[]; }catch(e){ ssGroupOrder=[]; } return ssGroupOrder; }
  function ssGordSave(){ try{ localStorage.setItem('logiGroupOrder', JSON.stringify(ssGroupOrder)); }catch(e){} }
  ssGordLoad();
  function ssGordOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('ssGordPop'); if(p) p.classList.toggle('open'); }
  function ssGordMove(L, dir){
    var lettersNow=(window.ssLetters||[]).slice();   // 현재 화면 표시 순서 기준으로 스왑
    var i=lettersNow.indexOf(L), j=i+dir;
    if(i<0 || j<0 || j>=lettersNow.length) return;
    var tmp=lettersNow[i]; lettersNow[i]=lettersNow[j]; lettersNow[j]=tmp;
    // 저장은 물류센터명(라벨) 배열로 — 데시보드2와 공유
    var lbl=window.ssGroupLabels||{};
    ssGroupOrder=lettersNow.map(function(x){ return lbl[x]||x; });
    ssGordSave(); ssRender();
  }
  function ssGordReset(){ ssGroupOrder=[]; ssGordSave(); ssRender(); }
  // 데시보드2(iframe)에서 순서를 바꾸면 즉시 반영 (같은 출처 localStorage 공유)
  window.addEventListener('storage', function(e){ if(e.key==='logiGroupOrder'){ ssGordLoad(); ssRender(); } });
  function ssGordRenderPop(letters){
    var pop=document.getElementById('ssGordPop'); if(!pop) return;
    var lbl=window.ssGroupLabels||{};
    var h=letters.map(function(L,ix){
      return '<div class="go-row"><span>'+(ix+1)+'. '+(lbl[L]||L)+'</span>'
        +'<span class="go-btns">'
        +'<button class="btn-line" style="padding:1px 8px" data-l="'+(''+L).replace(/"/g,'&quot;')+'" onclick="event.stopPropagation(); ssGordMove(this.getAttribute(\'data-l\'),-1)" title="위로">▲</button>'
        +'<button class="btn-line" style="padding:1px 8px" data-l="'+(''+L).replace(/"/g,'&quot;')+'" onclick="event.stopPropagation(); ssGordMove(this.getAttribute(\'data-l\'),1)" title="아래로">▼</button>'
        +'</span></div>';
    }).join('');
    h+='<div class="go-foot"><button class="btn-line" style="padding:3px 12px" onclick="event.stopPropagation(); ssGordReset()">↺ 순서 초기화 (ㄱㄴㄷ순)</button></div>';
    pop.innerHTML=h;
  }
  // 팝업 바깥 클릭 시 닫기
  document.addEventListener('click', function(e){
    var w=document.getElementById('ssGordWrap'), p=document.getElementById('ssGordPop');
    if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
  });

  // 토스트
  function ssToast(msg){
    var t=document.getElementById('ssToast');
    if(!t){ t=document.createElement('div'); t.id='ssToast'; t.className='ss-toast'; document.body.appendChild(t); }
    t.innerHTML=msg; t.classList.add('on');
    clearTimeout(t._tm); t._tm=setTimeout(function(){ t.classList.remove('on'); }, 3200);
  }

  // ── 발주현황표 업로드: 파일선택 → 미리보기 모달(시트선택) → 작성
  var ssPvWb=null, ssPvName='';

  // 엑셀 읽기 — 일부 ERP(코네트 등)가 생성한 비표준 xlsx 보정
  //   · sharedStrings.xml 의 <si > (꼬리 공백) → <si> 로 교정해야 SheetJS 가 문자열 셀(품목코드·품목명·헤더)을 읽음
  //   · JSZip 있으면 보정 후 읽고, 없으면(차단 등) 일반 읽기로 폴백
  function ssReadXlsx(arrayBuffer, onWb, onErr){
    function direct(){ try{ onWb(XLSX.read(new Uint8Array(arrayBuffer), {type:'array', cellDates:true})); }catch(e){ if(onErr) onErr(e); } }
    if(typeof JSZip==='undefined'){ direct(); return; }
    JSZip.loadAsync(arrayBuffer).then(function(zip){
      var f=zip.file('xl/sharedStrings.xml');
      if(!f){ direct(); return null; }
      return f.async('string').then(function(ss){
        if(ss.indexOf('<si ')<0 && ss.indexOf('</si ')<0){ direct(); return null; }  // 정상 파일은 그대로
        ss=ss.replace(/<si(\s+)>/g,'<si>').replace(/<\/si(\s+)>/g,'</si>');
        zip.file('xl/sharedStrings.xml', ss);
        return zip.generateAsync({type:'arraybuffer'}).then(function(buf){
          onWb(XLSX.read(new Uint8Array(buf), {type:'array', cellDates:true}));
        });
      });
    }).catch(function(){ direct(); });
  }

  // ── 업로드 자료 폴더 (File System Access API · Chrome/Edge). 폴더 지정 → 그 폴더의 xlsx 를 좌측에 나열, 클릭 → 우측 미리보기 ──
  var ssDirHandle=null, ssDirFiles=[], ssAutoPick=false;   // 모달 재오픈 시 최신 파일 자동선택
  function ssHistEsc(s){ return (''+(s==null?'':s)).replace(/[&<>"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c];}); }
  function ssFmtSize(n){ return n>=1048576 ? (n/1048576).toFixed(1)+'MB' : Math.max(1,Math.round(n/1024))+'KB'; }
  function ssFmtTime(ms){ var d=new Date(ms),p=function(n){return(n<10?'0':'')+n;}; return d.getFullYear()+'-'+p(d.getMonth()+1)+'-'+p(d.getDate())+' '+p(d.getHours())+':'+p(d.getMinutes()); }
  // 지정 폴더를 IndexedDB에 기억 → 다음 실행 때 경로 유지(권한만 재허용)
  function ssIdb(){ return new Promise(function(res,rej){ var r=indexedDB.open('ss_fs',1); r.onupgradeneeded=function(){ try{ r.result.createObjectStore('h'); }catch(e){} }; r.onsuccess=function(){ res(r.result); }; r.onerror=function(){ rej(r.error); }; }); }
  function ssIdbPut(h){ return ssIdb().then(function(db){ return new Promise(function(res){ var t=db.transaction('h','readwrite'); t.objectStore('h').put(h,'dir'); t.oncomplete=function(){ res(); }; t.onerror=function(){ res(); }; }); }).catch(function(){}); }
  function ssIdbGet(){ return ssIdb().then(function(db){ return new Promise(function(res){ var t=db.transaction('h','readonly'); var g=t.objectStore('h').get('dir'); g.onsuccess=function(){ res(g.result||null); }; g.onerror=function(){ res(null); }; }); }).catch(function(){ return null; }); }

  function ssPickDir(){
    if(!window.showDirectoryPicker){
      ssToast('⚠️ 이 접속에서는 폴더 지정을 쓸 수 없습니다(https/localhost 필요). <b>📄 파일 선택</b>으로 진행하세요.');
      return;
    }
    var p;
    // startIn:'downloads' = 다운로드에서 열림 / id = 지정한 폴더를 다음부터 기억(같은 위치에서 열림)
    //  ★다운로드 '루트' 는 브라우저가 막는다(시스템 폴더 취급) → 그 안에 전용 하위폴더를 만들어 지정해야 한다
    try{ p=window.showDirectoryPicker({mode:'readwrite', startIn:'downloads', id:'ssOrderDir'}); }
    catch(e){ ssToast('⚠️ 폴더 지정 오류: '+ssHistEsc(e&&e.message||'')); return; }
    p.then(function(h){ ssDirHandle=h; ssIdbPut(h); ssAutoPick=true; ssDirList(); })   // readwrite = 목록 + 삭제
     .catch(function(e){ if(e && e.name==='AbortError') return;   // 취소는 무시
       ssToast('⚠️ 폴더 지정 실패: '+ssHistEsc((e&&(e.name+': '+e.message))||'')
         +'<br><b>다운로드 폴더 자체</b>는 브라우저가 막습니다. 그 안에 <b>「코네트_발주현황표」</b> 같은 하위폴더를 만들어 지정하세요.'); });
  }
  function ssDirRestore(){ if(ssDirHandle) return Promise.resolve(); return ssIdbGet().then(function(h){ if(h) ssDirHandle=h; }); }
  // 목록 표시 — 권한 확인은 queryPermission(제스처 불필요)만. 권한 없으면 '이 폴더 열기' 버튼 표시.
  function ssDirList(){
    var box=document.getElementById('ssPvHist'), nm=document.getElementById('ssPvDirName'); if(!box) return;
    if(!window.showDirectoryPicker){ if(nm) nm.textContent=''; box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px;line-height:1.6">이 브라우저는 폴더 지정을<br>지원하지 않습니다.<br>위쪽 <b>📄 파일 선택</b>으로 진행하세요.<br>(Chrome/Edge 권장)</div>'; return; }
    if(!ssDirHandle){ if(nm) nm.textContent='';
      box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px;line-height:1.6">위쪽 <b>📂 폴더 지정</b>을 눌러<br>자료 폴더를 선택하면<br>파일이 여기 표시됩니다.<br><span style="color:#b6c0c9">자세한 설명은 위쪽 <b>ℹ️ 도움말</b>.</span>'
        +'<div style="margin-top:10px;padding:8px 9px;background:#fdf6e8;border:1px solid #f0dfb8;border-radius:5px;color:#8a6414">'
        +'⚠️ <b>다운로드 폴더 자체는 지정할 수 없습니다</b>(브라우저가 시스템 폴더로 막음).<br>'
        +'다운로드 안에 <b>「코네트_발주현황표」</b> 같은 <u>하위폴더</u>를 만들고 받은 파일을 그리로 옮긴 뒤, 그 폴더를 지정하세요.<br>'
        +'<span style="color:#a58a52">개인 자료가 섞인 폴더를 통째로 열지 않게 됩니다.</span><br>'
        +'<span style="color:#8a6414">받는 위치까지 그 폴더로 바꾸려면 위쪽 <b>ℹ️ 도움말</b> ▸ <b>⚙️ 크롬 다운로드 위치 바꾸기</b>.</span></div></div>'; return; }
    if(nm) nm.textContent='📂 '+ssDirHandle.name;
    ssDirHandle.queryPermission({mode:'readwrite'}).then(function(p){
      if(p==='granted'){ box.innerHTML='<div style="padding:10px;color:#9aa7b3;font-size:13px">불러오는 중…</div>'; ssDirScan(); }
      else { box.innerHTML='<div style="padding:12px;color:#b3760f;font-size:13px;line-height:1.6">저장된 폴더(<b>'+ssHistEsc(ssDirHandle.name)+'</b>)를<br>다시 사용하려면 권한이 필요합니다.<br><button class="btn-teal" style="margin-top:8px;padding:4px 12px" onclick="ssGrantDir()">📂 이 폴더 열기</button></div>'; }
    }).catch(function(e){ box.innerHTML='<div style="padding:12px;color:#c0392b;font-size:12px">폴더 오류: '+ssHistEsc(e&&e.message||'')+'</div>'; });
  }
  // 사용자 클릭(제스처) 안에서만 권한 요청 — requestPermission 을 즉시 호출해야 'User activation' 오류가 안 남
  function ssGrantDir(){
    if(!ssDirHandle) return;
    ssDirHandle.requestPermission({mode:'readwrite'}).then(function(p){ if(p==='granted') ssDirList(); else ssToast('폴더 접근이 거부되었습니다. [폴더 지정]으로 다시 선택하세요.'); }).catch(function(){});
  }
  // 발주 파일: 'YYYY.MM.DD_HH.MM.SS' 날짜시각으로 시작하는 xlsx — 뒤에 붙는 이름은 무엇이든 상관없음(2026-07-26 사용자).
  //   포함: 2026.07.04_13.25.10.xlsx , … - 복사본.xlsx , … (1).xlsx(같은 파일 재다운로드) , …(출고장).xlsx
  //   제외: 매출장·메인웰스토리 등 한글로 시작하는 것(앞 날짜시각이 없음)
  //   ※ 종전엔 '(' 가 든 이름을 통째로 뺐는데, 재다운로드분 ' (1)' 까지 목록에서 사라져 제거함
  var SS_NAME_RE=/^\d{4}\.\d{2}\.\d{2}_\d{2}\.\d{2}\.\d{2}/;
  function ssDirScan(){
    var autoPick=ssAutoPick; ssAutoPick=false;   // 이번 스캔에서만 소비(삭제/새로고침 스캔엔 자동선택 안 함)
    ssDirFiles=[];
    var it=ssDirHandle.values(), tasks=[];
    function step(){ return it.next().then(function(res){
      if(res.done) return;
      var h=res.value;
      if(h.kind==='file' && /\.xlsx?$/i.test(h.name) && SS_NAME_RE.test(h.name)){
        tasks.push(h.getFile().then(function(f){ ssDirFiles.push({name:h.name, time:f.lastModified, size:f.size, handle:h}); }));
      }
      return step();
    }); }
    step().then(function(){ return Promise.all(tasks); }).then(function(){
      ssDirFiles.sort(function(a,b){ return b.time-a.time; });   // 최신순
      ssHistRenderList();
      // 재오픈 시 최신 파일을 우측에 자동 표시(이미 그 파일이 열려 있으면 재파싱 생략)
      if(autoPick && ssDirFiles.length && ssDirFiles[0].name!==ssPvName) ssDirOpen(0);
    }).catch(function(){ ssHistRenderList(); });
  }
  function ssHistRenderList(){
    var box=document.getElementById('ssPvHist'); if(!box) return;
    if(!ssDirFiles.length){ box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px">폴더에 엑셀(xlsx) 파일이<br>없습니다.</div>'; return; }
    box.innerHTML=ssDirFiles.map(function(x,i){
      var cur=(x.name===ssPvName), m=ssDirMetaGet(x) || (i>=SS_DIRMETA_MAX ? {skip:1} : null);
      return '<div onclick="ssDirOpen('+i+')" title="'+ssHistEsc(x.name)+ssDirMetaTip(m)+'&#10;클릭하면 우측에 표시" '
        +'style="padding:5px 9px 6px;border-bottom:1px solid #eef3f1;cursor:pointer;font-size:13px'+(cur?';background:#e7f3ef':'')+'">'
        +'<div style="display:flex;align-items:center;gap:8px">'
          +'<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;'+(cur?'font-weight:700;color:#137a6c':'color:#28323c')+'">📄 '+ssHistEsc(x.name)+'</span>'
          +'<span style="flex:0 0 auto;color:#9aa7b3;white-space:nowrap;font-size:12px">'+ssFmtTime(x.time)+' · <b style="color:#6b7a89">'+ssFmtSize(x.size)+'</b></span>'
          +'<span onclick="event.stopPropagation();ssDirDelete('+i+')" title="이 파일 삭제" style="flex:0 0 auto;cursor:pointer;color:#c0392b;font-size:14px;padding:0 2px">🗑</span>'
        +'</div>'
        // 2행 = 파일을 실제로 읽어 뽑은 출고장 묶음(아래 '올린 이력'과 같은 형식)
        +'<div id="ssDirMeta'+i+'" style="display:flex;align-items:center;gap:5px;color:#9aa7b3;font-size:11.5px;margin-top:1px">'+ssDirMetaHtml(m)+'</div>'
      +'</div>';
    }).join('');
    ssDirMetaScan();     // 아직 안 읽은 파일은 뒤에서 하나씩 열어 출고장을 채운다
  }
  /* ══ 폴더 엑셀의 출고장 미리읽기 (2026-07-27 사용자 지시) ═════════════════════════════
       아래 '올린 이력'처럼 위 목록에도 출고장을 보여 달라는 요청. 서버엔 아직 없는 자료라
       파일을 직접 읽어야 한다 → 목록을 먼저 그린 뒤 백그라운드로 한 파일씩 파싱해 2행을 채운다.
        · 캐시키 = 파일명|수정시각|크기 → localStorage 보관(같은 파일을 다시 파싱하지 않는다).
          파일이 바뀌면 수정시각·크기가 달라져 자동으로 다시 읽는다.
        · 파싱은 무겁다(1건 수십~수백ms) → 순차 + setTimeout 으로 UI를 막지 않고,
          목록이 아주 길면 최신 SS_DIRMETA_MAX 개까지만 읽는다(나머지는 '—' 로 둔다).       */
  var ssDirMeta=(function(){ try{ return JSON.parse(localStorage.getItem('ssDirMeta')||'{}')||{}; }catch(e){ return {}; } })();
  var ssDirMetaBusy=false;
  var SS_DIRMETA_MAX=60;
  function ssDirMetaKey(x){ return x.name+'|'+x.time+'|'+x.size; }
  function ssDirMetaGet(x){ return ssDirMeta[ssDirMetaKey(x)]||null; }
  function ssDirMetaSave(){
    try{
      var ks=Object.keys(ssDirMeta);
      if(ks.length>300){ var d={}; ks.slice(-300).forEach(function(k){ d[k]=ssDirMeta[k]; }); ssDirMeta=d; }
      localStorage.setItem('ssDirMeta', JSON.stringify(ssDirMeta));
    }catch(e){}
  }
  // 워크북 → {dcs:[출고장], dcRow:{출고장:행수}, cnt:행수, dlvMin, dlvMax}
  function ssDirMetaOf(wb){
    var ws=wb.Sheets[(wb.SheetNames||[])[0]];
    var aoa=ws?XLSX.utils.sheet_to_json(ws,{header:1,defval:''}):[];
    var m=ssMapCols(aoa);
    if(!m) return { bad:1 };                                  // 발주현황표 양식이 아님
    var rows=ssExtractRows(aoa,m);
    var o={ dcs:[], dcRow:{}, cnt:rows.length, dlvMin:'', dlvMax:'' }, seen={};
    rows.forEach(function(r){
      // '용인물류센터1' → '용인' / 예전 2행헤더 양식은 존이 코드('E100')로 들어와 그것도 이름으로 바꾼다
      var dc=konetDcNmOf({ dcCd:r.zone, dcNm:r.zone })||'미기재';
      if(!seen[dc]){ seen[dc]=1; o.dcs.push(dc); }
      o.dcRow[dc]=(o.dcRow[dc]||0)+1;
      var d=(''+(r.dlvDt||'')).replace(/-/g,'');
      if(d){ if(!o.dlvMin||d<o.dlvMin) o.dlvMin=d; if(!o.dlvMax||d>o.dlvMax) o.dlvMax=d; }
    });
    return o;
  }
  function ssDirMetaHtml(m){
    if(!m)     return '<span style="flex:1;color:#b6c0c9">출고장 확인 중…</span>';
    if(m.skip) return '<span style="flex:1;color:#b6c0c9">—</span>';
    if(m.bad)  return '<span style="flex:1;color:#c0392b">발주현황표 양식이 아닙니다</span>';
    if(m.err)  return '<span style="flex:1;color:#c0392b">파일을 읽지 못했습니다</span>';
    var dcTxt=(m.dcs&&m.dcs.length) ? (m.dcs.length+'곳 · '+m.dcs.join('·')) : '미기재';
    var dl = m.dlvMin ? (m.dlvMin===m.dlvMax ? ssUpHistMd(m.dlvMin) : (ssUpHistMd(m.dlvMin)+'~'+ssUpHistMd(m.dlvMax).slice(3))) : '-';
    // 행수도 함께 — 아래 '올린 이력'의 '147행' 과 같은 표기(2026-07-27 사용자)
    return '<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">출고장 '+ssHistEsc(dcTxt)+'</span>'
         + '<span style="flex:0 0 auto;color:#6b7a89"><b>'+(+m.cnt||0).toLocaleString()+'</b>행</span>'
         + '<span style="flex:0 0 auto">납기 '+dl+'</span>';
  }
  // 툴팁은 두 갈래 — 처음 그릴 때는 HTML 속성(&#10;), 나중에 JS 로 title 을 갈아끼울 때는 생문자(\n).
  //   JS 로 '&#10;' 를 넣으면 글자 그대로 보인다(속성 파싱이 아니라 프로퍼티 대입이라서).
  function ssDirMetaTipTxt(m){
    if(!m || m.skip || m.bad || m.err) return '';
    var det=(m.dcs||[]).map(function(d){ return d+' '+(m.dcRow[d]||0); }).join(' · ');
    return '\n출고장 '+det+' (행)\n데이터 '+(+m.cnt||0).toLocaleString()+'건';
  }
  function ssDirMetaTip(m){ return ssHistEsc(ssDirMetaTipTxt(m)).replace(/\n/g,'&#10;'); }
  function ssDirMetaScan(){
    if(ssDirMetaBusy || typeof XLSX==='undefined') return;
    var todo=[];
    ssDirFiles.forEach(function(x,i){
      if(ssDirMetaGet(x) || i>=SS_DIRMETA_MAX) return;   // 이미 읽음 / 너무 많으면 최신것만(skip 은 캐시에 남기지 않는다)
      todo.push({x:x, i:i});
    });
    if(!todo.length) return;
    ssDirMetaBusy=true;
    var n=0;
    var put=function(t,m){
      ssDirMeta[ssDirMetaKey(t.x)]=m;
      var el=document.getElementById('ssDirMeta'+t.i);
      if(el) el.innerHTML=ssDirMetaHtml(m);
      var row=el&&el.parentNode; if(row) row.title=t.x.name+ssDirMetaTipTxt(m)+'\n클릭하면 우측에 표시';
      setTimeout(step, 0);
    };
    var step=function(){
      if(n>=todo.length){ ssDirMetaBusy=false; ssDirMetaSave(); return; }
      var t=todo[n++];
      t.x.handle.getFile().then(function(f){ return f.arrayBuffer(); }).then(function(buf){
        ssReadXlsx(buf, function(wb){ var m; try{ m=ssDirMetaOf(wb); }catch(e){ m={err:1}; } put(t,m); },
                        function(){ put(t,{err:1}); });
      }).catch(function(){ put(t,{err:1}); });
    };
    setTimeout(step, 300);  // 목록·자동펼침(최신 파일 미리보기)이 먼저 끝난 뒤 시작
  }
  // 목록의 파일을 '_삭제됨' 하위폴더로 이동(소프트 삭제 — 복구 가능). readwrite 권한 필요
  var SS_TRASH='_삭제됨';
  function ssDirDelete(i){
    var x=ssDirFiles[i]; if(!x || !ssDirHandle) return;
    ssConfirm('「'+SS_TRASH+'」 폴더로 이동합니다 <span style="color:#9aa7b3">(복구 가능)</span><br><b style="word-break:break-all">'+ssHistEsc(x.name)+'</b>',
      function(){
        ssDirHandle.requestPermission({mode:'readwrite'}).then(function(p){
          if(p!=='granted'){ ssToast('삭제하려면 쓰기 권한이 필요합니다. [폴더 지정]으로 다시 선택하세요.'); return; }
          return ssMoveToTrash(x);
        }).catch(function(e){ ssToast('⚠️ 이동 실패: '+ssHistEsc(e&&e.message||'')); });
      }, {title:'🗑 파일 이동', yes:'이동'});
  }
  // 원본 읽기 → 대상 하위폴더에 쓰기 → 원본 제거 (= 이동). dest 없으면 _삭제됨
  function ssMoveToTrash(x, dest, icon){
    var dir=dest||SS_TRASH, ic=icon||'🗑';
    return x.handle.getFile().then(function(f){ return f.arrayBuffer(); }).then(function(buf){
      return ssDirHandle.getDirectoryHandle(dir, {create:true}).then(function(trash){
        return ssTrashName(trash, x.name).then(function(finalName){
          return trash.getFileHandle(finalName, {create:true}).then(function(fh){
            return fh.createWritable().then(function(w){ return w.write(buf).then(function(){ return w.close(); }); });
          });
        });
      });
    }).then(function(){
      return ssDirHandle.removeEntry(x.name);   // 원본 제거(복사본은 대상 폴더에 남음)
    }).then(function(){ ssToast(ic+' 「'+dir+'」 폴더로 이동: '+x.name); ssDirList(); })
      .catch(function(e){ ssToast('⚠️ 이동 실패: '+ssHistEsc(e&&e.message||'')); });
  }
  /* ══ 작성(대시보드 반영) 성공 → 그 엑셀을 상단 목록에서 치운다 (2026-07-27 사용자 지시) ══════
       "반영하면 위에서 없어지고 아래 이력에 최신으로 올라오게" — 이미 올린 파일이 목록에 남아
       또 올리는 일을 막는 것이 목적이다.
        ★브라우저는 지정 폴더의 <상위>(다운로드)로는 못 옮긴다 — 우리가 가진 건 지정 폴더 핸들뿐이고
          File System Access API 는 부모 디렉터리 접근을 주지 않는다. 그래서 지정 폴더 안의
          「_반영됨」 하위폴더로 옮긴다(파일은 그대로 남아 되찾을 수 있다).
        · 📄 파일 선택으로 연 폴더 밖 파일은 핸들이 없어 건너뛴다(조용히).
        · 쓰기 권한이 없으면 반영은 그대로 두고 이동만 못 했다고 알린다(제스처 없이 요청 불가).      */
  var SS_DONE='_반영됨';
  function ssArchiveApplied(fileName){
    if(!fileName || !ssDirHandle) return;
    var x=null;
    for(var k=0;k<ssDirFiles.length;k++){ if(ssDirFiles[k].name===fileName){ x=ssDirFiles[k]; break; } }
    if(!x) return;                                     // 폴더 밖 파일(📄 파일 선택) → 옮길 게 없다
    ssDirHandle.queryPermission({mode:'readwrite'}).then(function(p){
      if(p!=='granted'){ ssToast('반영은 끝났습니다. 다만 파일 이동은 <b>쓰기 권한</b>이 없어 못 했습니다 — 위쪽 <b>📂 폴더 지정</b>으로 폴더를 다시 골라 주세요.'); return; }
      return ssMoveToTrash(x, SS_DONE, '📦');          // 이동 후 ssDirList() 로 상단 목록 갱신
    }).catch(function(){});
  }
  // 대상 폴더에 같은 이름 있으면 시각 접미사 붙여 충돌 방지
  function ssTrashName(trash, name){
    return trash.getFileHandle(name).then(function(){
      var dot=name.lastIndexOf('.'), base=dot>0?name.slice(0,dot):name, ext=dot>0?name.slice(dot):'';
      return base+'_'+ssFmtTime(+new Date()).replace(/[^0-9]/g,'')+ext;
    }, function(){ return name; });
  }
  // 큰 파일도 그대로 수용(수가업로드처럼 대용량 가능). 파싱 중엔 "불러오는 중" 표시로 멈춘 듯 안 보이게
  function ssBusy(on, msg){
    var el=document.getElementById('ssBusyOv');
    if(on){
      if(!el){ el=document.createElement('div'); el.id='ssBusyOv';
        el.style.cssText='position:fixed;inset:0;z-index:99999;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.35)';
        el.innerHTML='<div style="background:#fff;padding:18px 26px;border-radius:10px;box-shadow:0 8px 30px rgba(0,0,0,.3);font-size:15px;font-weight:600;color:#137a6c;max-width:80vw;text-align:center">⏳ <span id="ssBusyMsg"></span></div>';
        document.body.appendChild(el);
      }
      document.getElementById('ssBusyMsg').textContent=msg||'불러오는 중…';
      el.style.display='flex';
    } else if(el){ el.style.display='none'; }
  }
  function ssDirOpen(i){
    var x=ssDirFiles[i]; if(!x) return;
    ssBusy(true,'엑셀 불러오는 중…');
    x.handle.getFile().then(function(f){ return f.arrayBuffer(); }).then(function(buf){ ssLoadWorkbookBuf(buf, x.name, true); }).catch(function(){ ssBusy(false); ssToast('⚠️ 파일 열기 실패'); });
  }
  // 모달 열릴 때 저장된 폴더 복원 + 목록 갱신
  function ssHistRefresh(){ ssDirRestore().then(function(){ ssDirList(); }); }

  /* ══ 좌측 하단 : 서버 업로드 이력 (기본=오늘 · 최신이 위) — 2026-07-27 사용자 요청 ═══════
       좌측을 위/아래 반반으로 나눠 위=폴더의 엑셀, 아래=서버(TBL_SHIPOUT_MST)에 실제로
       반영된 배치를 업로드 시각 최신순으로 보여준다. 기본은 '오늘 올린 것'(3일 전환 가능).
        · 엔드포인트는 업로드이력 화면(shipoutHist)과 같은 것을 재사용 → 서버 수정 없음
          /shipout/selectShipoutUploadHist.do  (배치 1건 = SHPOUT_DT+DLV_DT+DC_CD+JOB_SEQ 그룹)
        · ★그 SQL은 '출고일자' 범위만 걸 수 있고 '업로드 시각'으로는 못 거른다 → 출고일자 ±120일을
          읽어 화면에서 업로드 날짜로 거른다. 하루에 두 달 전 출고일자(예: 07-26에 출고 05-30)까지
          같이 올리는 일이 있어 창을 넉넉히 잡았다. 그보다 먼 자료는 목록에 안 뜬다(정확히 하려면
          User_SQL 에 UPLOAD_DTTM 조건 추가 필요 = 재배포).
        · 지금 펼쳐 둔 파일과 같은 파일명은 초록 강조 — 이미 올린 자료를 또 올리는 것을 막는다.
        · 줄을 누르면 그 파일을 다시 펼친다(지정 폴더에 남아 있을 때).                      */
  var ssUpHistDays=1;       // 1=오늘만(기본) / 3=최근 3일 (2026-07-27 사용자: 7일→3일)
  var ssUpHist=null;        // 조회 결과 캐시(모달 열 때·저장 후 1회)
  var ssUpHistView=[];      // 화면에 그린 순서(줄 클릭 → 인덱스로 되찾기)
  function ssUpHistSetDays(n){ ssUpHistDays=n; ssUpHistRender(); }   // 조회는 그대로 두고 화면에서만 거른다
  function ssUpHistYmd(shift){ var d=new Date(); d.setDate(d.getDate()+(shift||0)); return d.getFullYear()+'-'+ssPad(d.getMonth()+1)+'-'+ssPad(d.getDate()); }
  function ssUpHistMd(v){    // 'yyyymmdd' 또는 'yyyy-mm-dd' → 'MM-DD'
    var s=(''+(v==null?'':v)).replace(/-/g,'');
    return /^\d{8}$/.test(s) ? (s.slice(4,6)+'-'+s.slice(6,8)) : (s||'-');
  }
  function ssUpHistDayLab(d){
    var W=['일','월','화','수','목','금','토'];
    var m=/^(\d{4})-(\d{2})-(\d{2})$/.exec(d); if(!m) return d;
    var w=W[new Date(+m[1],+m[2]-1,+m[3]).getDay()];
    var tag = (d===ssUpHistYmd(0)) ? ' <span style="color:#137a6c;font-weight:700">오늘</span>'
            : (d===ssUpHistYmd(-1) ? ' <span style="color:#6b7a89">어제</span>' : '');
    return m[2]+'-'+m[3]+'('+w+')'+tag;
  }
  function ssUpHistLoad(){
    var box=document.getElementById('ssPvUpHist'); if(!box) return;
    box.innerHTML='<div style="padding:10px;color:#9aa7b3;font-size:13px">업로드 이력 불러오는 중…</div>';
    fetch('${pageContext.request.contextPath}/shipout/selectShipoutUploadHist.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin',
      body:'shpoutDtFrom='+encodeURIComponent(ssUpHistYmd(-120))+'&shpoutDtTo='+encodeURIComponent(ssUpHistYmd(120))
    })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){
      if(!r.ok){ box.innerHTML='<div style="padding:10px;color:#c0392b;font-size:13px">업로드 이력 조회 실패 (HTTP '+r.status+')</div>'; return; }
      var j; try{ j=JSON.parse(r.t); }catch(e){ box.innerHTML='<div style="padding:10px;color:#c0392b;font-size:13px">업로드 이력 응답형식 오류(로그인 만료일 수 있습니다)</div>'; return; }
      ssUpHist=(j&&j.data)||[];
      ssUpHistRender();
    })
    .catch(function(){ box.innerHTML='<div style="padding:10px;color:#c0392b;font-size:13px">업로드 이력 통신오류 — ↻ 로 다시 시도하세요.</div>'; });
  }
  function ssUpHistRender(){
    if(window.ssBackMsgUpd) ssBackMsgUpd();     // 이력이 늦게 도착해도 하단 알림이 맞게(모달 열자마자 파일이 펼쳐지는 경우)
    var box=document.getElementById('ssPvUpHist'); if(!box || ssUpHist==null) return;
    var only1=(ssUpHistDays===1);
    var lim=ssUpHistYmd(-(ssUpHistDays-1));                         // 오늘 포함 N일
    var rows=(ssUpHist||[]).filter(function(o){ var u=(''+(o.uploadDttm||'')).slice(0,10); return u && u>=lim; });
    rows.sort(function(a,b){ return (''+(b.uploadDttm||'')).localeCompare(''+(a.uploadDttm||'')); });   // 최근이 위
    // 머리글 — 제목·건수·기간 전환 링크
    var titEl=document.getElementById('ssPvUpHistTit'); if(titEl) titEl.textContent = only1 ? '오늘' : '최근 3일';
    var tabEl=document.getElementById('ssPvUpHistTab');
    if(tabEl) tabEl.innerHTML = only1
      ? '<span onclick="ssUpHistSetDays(3)" title="최근 3일치를 날짜별로 봅니다(오늘·어제·그저께)" style="cursor:pointer;text-decoration:underline">3일</span>'
      : '<span onclick="ssUpHistSetDays(1)" title="오늘 올린 것만 봅니다" style="cursor:pointer;text-decoration:underline">오늘만</span>';
    // ★한 번에 올린 것은 한 줄로 — 출고장 묶음 (2026-07-27 사용자 지시)
    var ups=ssUpHistPack(rows);
    var cntEl=document.getElementById('ssPvUpHistCnt');
    if(cntEl){ var tot=0; ups.forEach(function(g){ tot+=g.rowCnt; });
      cntEl.textContent = ups.length ? (ups.length+'회 · '+tot.toLocaleString()+'행') : ''; }
    if(!rows.length){
      ssUpHistView=[];
      box.innerHTML='<div style="padding:12px;color:#9aa7b3;font-size:13px;line-height:1.6">'
        +(only1?'오늘':'최근 3일 안에')+' 서버에 반영한<br>자료가 없습니다.<br>'
        +'<span style="color:#b6c0c9">파일을 열어 <b>✔ 작성</b>을 누르면 여기에 쌓입니다.'
        +(only1?'<br>지난 자료는 위 <b>3일</b>을 누르세요.':'')+'</span></div>';
      return;
    }
    ssUpHistView=[]; var out=[];
    if(only1){
      // 오늘만 — 날짜 머리글 없이 시각순으로 쭉 (같은 날이라 머리글이 군더더기)
      ups.forEach(function(g){ out.push(ssUpHistRowHtml(g, ssUpHistView.length)); ssUpHistView.push(g); });
    } else {
      // 업로드 날짜로 묶기 (ups 가 이미 내림차순이라 그룹 순서도 최신일부터)
      var days={}, order=[];
      ups.forEach(function(g){ if(!days[g.day]){ days[g.day]=[]; order.push(g.day); } days[g.day].push(g); });
      order.forEach(function(d){
        var gs=days[d], cnt=0; gs.forEach(function(g){ cnt+=g.rowCnt; });
        out.push('<div style="display:flex;align-items:center;gap:6px;padding:4px 9px;background:#eef4f3;border-bottom:1px solid #e2ebe8;font-size:12.5px;position:sticky;top:0">'
          +'<span style="flex:1;font-weight:700;color:#37475a">'+ssUpHistDayLab(d)+'</span>'
          +'<span style="color:#9aa7b3">'+gs.length+'회 · '+cnt.toLocaleString()+'행</span></div>');
        gs.forEach(function(g){ out.push(ssUpHistRowHtml(g, ssUpHistView.length)); ssUpHistView.push(g); });
      });
    }
    box.innerHTML=out.join('');
  }
  /* 배치(출고장×납기일자×버전) → '업로드 1회' 로 묶기.
       발주현황표 한 장에 물류센터 7곳이 들어 있어 저장하면 배치가 출고장별로 갈린다.
       그대로 늘어놓으면 한 번 올린 것이 7줄(7일치 605줄)이 되어 읽을 수 없다.
       묶음키 = 파일명 + 업로드시각(분). 같은 분에 다른 파일을 올렸으면 파일별로 나뉜다.  */
  function ssUpHistPack(rows){
    var map={}, order=[];
    rows.forEach(function(o){
      var up=(''+(o.uploadDttm||''));
      var file=(''+(o.srcFile||'')).trim();
      var key=file+'|'+up.slice(0,16);
      var g=map[key];
      if(!g){ g={ file:file, up:up, day:up.slice(0,10), hm:up.slice(11,16), user:(''+(o.regUser||'')).trim(),
                  n:0, nHist:0, rowCnt:0, qtySum:0, dcs:[], _seen:{}, dcRow:{}, sdMin:'', sdMax:'' };
              map[key]=g; order.push(g); }
      var dc=konetDcShort(o.dcNm||'')||(''+(o.dcCd||'')).trim()||'미기재';   // '평택물류센터'→'평택'
      if(!g._seen[dc]){ g._seen[dc]=1; g.dcs.push(dc); }
      g.dcRow[dc]=(g.dcRow[dc]||0)+(+o.rowCnt||0);
      g.n++; g.rowCnt+=(+o.rowCnt||0); g.qtySum+=(+o.qtySum||0);
      if((''+(o.actionYn||'')).toUpperCase()==='N') g.nHist++;
      var sd=(''+(o.shpoutDt||'')).replace(/-/g,'');
      if(sd){ if(!g.sdMin||sd<g.sdMin) g.sdMin=sd; if(!g.sdMax||sd>g.sdMax) g.sdMax=sd; }
      if(up>g.up) g.up=up;
    });
    return order;   // rows 가 업로드시각 내림차순이라 그룹 순서도 최신부터
  }
  function ssUpHistRowHtml(g, i){
    var cur = !!(ssPvName && g.file===ssPvName);                    // 지금 펼쳐 둔 파일
    var dcTxt = g.dcs.length ? (g.dcs.length+'곳 · '+g.dcs.join('·')) : '출고장 미기재';
    var sdTxt = g.sdMin ? (g.sdMin===g.sdMax ? ssUpHistMd(g.sdMin) : (ssUpHistMd(g.sdMin)+'~'+ssUpHistMd(g.sdMax).slice(3))) : '-';
    var histTag = g.nHist===0 ? '' : (g.nHist===g.n ? '이력' : '일부 이력');
    var dcDetail = g.dcs.map(function(d){ return d+' '+(g.dcRow[d]||0); }).join(' · ');
    return '<div onclick="ssUpHistPick('+i+')" title="'+ssHistEsc(g.file||'(파일명 없음)')+'&#10;업로드 '+ssHistEsc(g.up)+(g.user?(' · '+ssHistEsc(g.user)):'')
      +'&#10;출고장 '+ssHistEsc(dcDetail)+' (행)'
      +'&#10;출고일자 '+sdTxt+' · 합계 '+g.rowCnt.toLocaleString()+'행 · 수량 '+g.qtySum.toLocaleString()
      +(histTag?('&#10;※ '+(g.nHist===g.n?'이 업로드는 뒤에 올린 자료로 덮여 이력으로 남았습니다':'일부 출고장이 뒤에 올린 자료로 덮였습니다')):'')
      +'&#10;클릭하면 이 파일을 다시 펼칩니다(지정 폴더에 있을 때)" '
      +'style="padding:5px 9px 6px;border-bottom:1px solid #eef3f1;cursor:pointer;font-size:12.5px'+(cur?';background:#e7f3ef':'')+'">'
      +'<div style="display:flex;align-items:center;gap:5px">'
        +'<span style="flex:0 0 auto;color:#9aa7b3">'+g.hm+'</span>'
        +'<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-weight:700;color:'+(cur?'#137a6c':'#37475a')+'">'+ssHistEsc(g.file||'(파일명 없음)')+'</span>'
        +(histTag?'<span style="flex:0 0 auto;color:#9aa7b3;border:1px solid #e0e6ea;border-radius:3px;padding:0 3px;font-size:11px">'+histTag+'</span>':'')
        +'<span style="flex:0 0 auto;color:#6b7a89"><b>'+g.rowCnt.toLocaleString()+'</b>행</span>'
      +'</div>'
      +'<div style="display:flex;align-items:center;gap:5px;color:#9aa7b3;font-size:11.5px;margin-top:1px">'
        +'<span style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">출고장 '+ssHistEsc(dcTxt)+'</span>'
        +'<span style="flex:0 0 auto">출고 '+sdTxt+'</span>'
      +'</div></div>';
  }
  // 이력 줄 클릭 → 같은 이름의 파일이 지정 폴더에 있으면 우측에 다시 펼친다
  function ssUpHistPick(i){
    var g=ssUpHistView[i]; if(!g) return;
    var file=(''+(g.file||'')).trim();
    if(!file){ ssToast('이 업로드에는 파일명이 기록되어 있지 않습니다.'); return; }
    for(var k=0;k<ssDirFiles.length;k++){ if(ssDirFiles[k].name===file){ ssDirOpen(k); return; } }
    ssToast('📄 <b>'+ssHistEsc(file)+'</b> — 지정 폴더에 없습니다<br><span style="font-size:11px">이미 옮겼거나 다른 PC에서 올린 자료입니다.</span>');
  }

  /* ══ 역순 업로드 알림 — 올리려는 자료가 '마지막에 올린 자료'보다 이전이면 알린다 (2026-07-27 사용자 요청) ══
       · ★막지 않는다. 알리고 그대로 진행한다 — 지난 날짜를 뒤늦게 올리는 정상 업무가 있다.
       · 비교기준 = 출고일자(SHPOUT_DT). '마지막에 올린 자료' = ssUpHist 중 업로드시각이 가장 늦은 묶음
         (묶음키는 목록과 같은 ssUpHistPack = 파일명+업로드시각(분) → 한 번에 올린 7개 출고장이 한 건).
       · ssUpHist 는 모달 열 때 1회 조회분(출고일자 ±120일). 아직 안 왔거나 창 밖이면 조용히 넘어간다(헛경고 방지). */
  function ssBackNorm(v){ var s=(''+(v==null?'':v)).replace(/-/g,''); return /^\d{8}$/.test(s)?s:''; }
  function ssLastUpGrp(){
    var rows=(ssUpHist||[]).filter(function(o){ return (''+(o.uploadDttm||'')).length>=10; });
    if(!rows.length) return null;
    rows=rows.slice().sort(function(a,b){ return (''+(b.uploadDttm||'')).localeCompare(''+(a.uploadDttm||'')); });
    var ups=ssUpHistPack(rows);
    return ups.length ? ups[0] : null;     // 업로드시각 내림차순이라 맨 앞 = 마지막에 올린 묶음
  }
  // null = 알릴 것 없음 / {cur,prev,g} = 이전 자료
  function ssBackChk(shpDt){
    var cur=ssBackNorm(shpDt); if(!cur) return null;
    var g=ssLastUpGrp(); if(!g || !g.sdMax) return null;
    if(cur>=g.sdMax) return null;
    return { cur:cur, prev:g.sdMax, g:g };
  }
  function ssBackTxt(c){
    return '이전 자료입니다 — 마지막 업로드(<b>'+ssHistEsc((c.g.day||'').slice(5))+' '+ssHistEsc(c.g.hm||'')+'</b> · '
         + ssHistEsc(c.g.file||'파일명 없음')+')의 출고일자 <b>'+ssUpHistMd(c.prev)+'</b> 보다 <b>'+ssUpHistMd(c.cur)+'</b> 가 이전입니다.';
  }
  // 깜박임 다시 시작 — 클래스를 뗐다 붙이면 애니메이션이 처음부터 돈다(reflow 강제 필요)
  function ssBlinkOn(el){ if(!el) return; el.classList.remove('ss-blink'); void el.offsetWidth; el.classList.add('ss-blink'); }
  // 미리보기 하단 알림 — 파일을 펼쳤을 때·출고일자를 고쳤을 때·이력이 늦게 도착했을 때 갱신
  function ssBackMsgUpd(){
    var el=document.getElementById('ssPvBackMsg'); if(!el) return;
    var dt=document.getElementById('ssPvShpoutDt');
    var c=(ssPvCur&&ssPvCur.map) ? ssBackChk((dt&&dt.value)||'') : null;
    if(!c){ el.style.display='none'; el.innerHTML=''; el.classList.remove('ss-blink'); return; }
    var h='⚠️ '+ssBackTxt(c)+' <span style="font-weight:400;color:#8a6b6b">— 그대로 진행할 수 있습니다</span>';
    var same=(el.innerHTML===h && el.style.display!=='none');
    el.style.display=''; el.innerHTML=h;
    if(!same) ssBlinkOn(el);        // 내용이 바뀔 때만 다시 깜박(이력 재렌더마다 재시작 방지)
  }
  // 반영 확인창 안의 알림 — 확인창에서 출고일자를 고치면 즉시 다시 판정한다
  function ssConfirmBackUpd(){
    var box=document.getElementById('ssConfirmBack'); if(!box) return;
    var dt=document.getElementById('ssConfirmShpDt');
    var c=ssBackChk((dt&&dt.value)||'');
    var h = c ? ('<div class="ss-blink" style="margin-top:12px;padding:9px 11px;border:1px solid #f3c9c3;background:#fff6f5;border-radius:6px;'
        +'font-size:12.5px;color:#c0392b;font-weight:700;line-height:1.55;text-align:left">⚠️ '+ssBackTxt(c)
        +'<br><span style="color:#8a6b6b;font-weight:400">그래도 반영하려면 <b>반영</b>을 누르세요 — 막지 않습니다.</span></div>') : '';
    if(box.innerHTML!==h) box.innerHTML=h;   // 같은 내용이면 그대로 둔다(깜박임이 처음부터 다시 돌지 않게)
  }

  // ArrayBuffer(엑셀) → 미리보기 모달에 로드 (수동선택·폴더선택 공용). 이후 작성/저장은 기존 ssPvApply 재사용
  function ssLoadWorkbookBuf(buf, fileName, skipHist){
    if(typeof XLSX==='undefined'){ ssBusy(false); ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); return; }
    ssPvName=fileName;
    ssBusy(true,'엑셀 불러오는 중… ('+fileName+')');
    // 스피너를 먼저 화면에 그린 뒤 무거운 동기 파싱 실행(대용량도 멈춘 듯 안 보이게)
    setTimeout(function(){
    ssReadXlsx(buf, function(wb){
    try{
      ssPvWb=wb;
      var names=ssPvWb.SheetNames||[];
      document.getElementById('ssPvFile').textContent=fileName;
      var sel=document.getElementById('ssPvSheet');
      sel.innerHTML=names.map(function(n,i){ return '<option value="'+i+'">'+n+'</option>'; }).join('');
      sel.value='0';
      document.getElementById('ssPvSheetWrap').style.display = names.length>1 ? '' : 'none';
      ssPvRender();
      ssPvOpen(true);
      ssHistRenderList();   // 현재 파일 강조 갱신(폴더 목록)
      ssUpHistRender();     // 현재 파일 강조 갱신(업로드 이력 — 이미 올린 파일인지 바로 보이게)
    }catch(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); }
    ssBusy(false);
    }, function(err){ ssBusy(false); ssToast('⚠️ 엑셀 처리 오류: '+err.message); });
    }, 30);
  }

  // 수동 파일 선택(<input type=file>) — 폴더 접근이 안 되는 환경용 fallback
  function ssUpload(input){
    var f=input.files && input.files[0]; if(!f) return;
    ssBusy(true,'파일 읽는 중… ('+f.name+')');
    var rd=new FileReader();
    rd.onload=function(e){ ssLoadWorkbookBuf(e.target.result, f.name); input.value=''; };
    rd.onerror=function(){ ssBusy(false); ssToast('⚠️ 파일 읽기 실패'); input.value=''; };
    rd.readAsArrayBuffer(f);
  }

  // ── 매출금액 업로드 (발주현황표 업로드와 동일 UX: 파일선택 → 미리보기 모달 → 작성/반영)
  //   매입단가 엑셀(품목코드·입고일자·입고량·단가·매입금액) → 품목코드별 매출액(매입금액 합)
  var ssSalesPvWb=null, ssSalesPvName='', ssSalesPvCur=null;

  function ssSalesUpload(input){
    var f=input.files && input.files[0]; if(!f) return;
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); input.value=''; return; }
    ssSalesPvName=f.name;
    var rd=new FileReader();
    rd.onload=function(e){
      ssReadXlsx(e.target.result, function(wb){
      try{
        ssSalesPvWb=wb;
        var names=ssSalesPvWb.SheetNames||[];
        document.getElementById('ssSalesPvFile').textContent=f.name;
        var sel=document.getElementById('ssSalesPvSheet');
        sel.innerHTML=names.map(function(n,i){ return '<option value="'+i+'">'+n+'</option>'; }).join('');
        sel.value='0';
        document.getElementById('ssSalesPvSheetWrap').style.display = names.length>1 ? '' : 'none';
        ssSalesPvRender();
        ssSalesPvOpen(true);
      }catch(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); }
      }, function(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); });
      input.value='';
    };
    rd.readAsArrayBuffer(f);
  }
  function ssSalesPvOpen(show){ document.getElementById('ssSalesPvOverlay').classList.toggle('on', !!show); }

  // 선택 시트의 2차원 배열
  function ssSalesPvAoa(){
    var idx=+(document.getElementById('ssSalesPvSheet').value||0);
    var ws=ssSalesPvWb.Sheets[ssSalesPvWb.SheetNames[idx]];
    return ws ? XLSX.utils.sheet_to_json(ws,{header:1,defval:''}) : [];
  }

  // 매입단가 엑셀 컬럼 자동 인식 (단일행 헤더)
  function ssSalesMapCols(aoa){
    function findIn(arr,name){ for(var k=0;k<arr.length;k++){ if((''+arr[k]).trim()===name) return k; } return -1; }
    for(var i=0;i<Math.min(aoa.length,8);i++){
      var h=(aoa[i]||[]).map(function(s){return (''+s).trim();});
      var cCode=findIn(h,'품목코드'), cDate=findIn(h,'입고일자');
      var cAmt=findIn(h,'매입금액'), cPrice=findIn(h,'단가'), cInQty=findIn(h,'입고량');
      if(cCode>=0 && (cAmt>=0 || cPrice>=0)){
        return { h:i, cCode:cCode, cName:findIn(h,'품목명'), cDate:cDate, cAmt:cAmt, cPrice:cPrice, cInQty:cInQty };
      }
    }
    return null;
  }

  // 추출: 품목코드별 매출액(매입금액 합) — 금액 = 매입금액(없으면 입고량×단가)
  function ssSalesExtract(aoa,m){
    var map={}, cnt=0, sum=0, dset={};
    for(var r=m.h+1; r<aoa.length; r++){
      var row=aoa[r]||[];
      var code=(''+(m.cCode>=0?row[m.cCode]:'')).trim(); if(!code) continue;
      var amt=m.cAmt>=0 ? (+(''+(row[m.cAmt]||'')).replace(/[^0-9.\-]/g,'')||0) : 0;
      if(!amt && m.cPrice>=0){
        var price=+(''+(row[m.cPrice]||'')).replace(/[^0-9.\-]/g,'')||0;
        var inq=m.cInQty>=0 ? (+(''+(row[m.cInQty]||'')).replace(/[^0-9.\-]/g,'')||0) : 1;
        amt=price*(inq||1);
      }
      if(!amt) continue;
      map[code]=(map[code]||0)+amt; cnt++; sum+=amt;
      var d=m.cDate>=0?ssFmtDate(row[m.cDate]):''; if(d) dset[d]=1;
    }
    return { map:map, cnt:cnt, sum:sum, dates:Object.keys(dset).sort() };
  }

  // 미리보기 렌더 (엑셀 내용 그대로 + 인식컬럼 하이라이트) — 발주현황표 미리보기와 동일 스타일
  function ssSalesPvRender(){
    var aoa=ssSalesPvAoa();
    var m=ssSalesMapCols(aoa);
    ssSalesPvCur={aoa:aoa, map:m};
    var info=document.getElementById('ssSalesPvInfo');
    var btn=document.getElementById('ssSalesPvApplyBtn');
    var hlCols={};
    if(m){
      [m.cCode,m.cName,m.cDate,m.cInQty,m.cPrice,m.cAmt].forEach(function(c){ if(c>=0) hlCols[c]=1; });
      var ex=ssSalesExtract(aoa,m);
      info.className='ss-pvinfo';
      info.innerHTML='✅ 인식 완료 — <span class="tag">품목코드</span>'
        + (m.cDate>=0?'<span class="tag">입고일자</span>':'')
        + (m.cInQty>=0?'<span class="tag">입고량</span>':'')
        + (m.cPrice>=0?'<span class="tag">단가</span>':'')
        + (m.cAmt>=0?'<span class="tag">매입금액</span>':'')
        + ' · 품목 <b>'+Object.keys(ex.map).length+'</b>종 · 매출액 합 <b>'+ssNum(ex.sum)+'</b>원 (노란 칸이 반영 대상)';
      btn.removeAttribute('disabled'); btn.style.opacity='1';
    } else {
      info.className='ss-pvinfo warn';
      info.innerHTML='⚠️ 매입단가 형식이 아닙니다 — 헤더에 <b>품목코드</b> 와 <b>매입금액(또는 단가)</b> 이 있어야 합니다. 시트를 바꿔 보세요.';
      btn.setAttribute('disabled','disabled'); btn.style.opacity='.5';
    }
    var maxR=Math.min(aoa.length,30), maxC=0;
    for(var i=0;i<maxR;i++) maxC=Math.max(maxC,(aoa[i]||[]).length);
    maxC=Math.min(maxC,40);
    var html='';
    for(var r=0;r<maxR;r++){
      var isHdr = m && (r===m.h);
      html+= isHdr ? '<tr class="hdr">' : '<tr>';
      html+='<td class="rn">'+(r+1)+'</td>';
      for(var c=0;c<maxC;c++){
        var v=ssCellDisp(aoa[r]&&aoa[r][c]);
        html+='<td'+(hlCols[c]?' class="hl"':'')+' title="'+v.replace(/"/g,'&quot;')+'">'+v+'</td>';
      }
      html+='</tr>';
    }
    if(aoa.length>30) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">이하 '+(aoa.length-30)+'행 생략 (작성 시 전체 반영)</td></tr>';
    document.getElementById('ssSalesPvTbl').innerHTML=html;
  }

  // 작성(반영): 확인 메시지 후 실행
  function ssSalesPvApply(){
    if(!ssSalesPvCur || !ssSalesPvCur.map){ ssToast('⚠️ 인식 가능한 매입단가 표가 아닙니다.'); return; }
    var ex=ssSalesExtract(ssSalesPvCur.aoa, ssSalesPvCur.map);
    if(!ex.cnt){ ssToast('⚠️ 매출금액 데이터 행이 없습니다.'); return; }
    var sheetNm=ssSalesPvWb.SheetNames[+(document.getElementById('ssSalesPvSheet').value||0)];
    var items=Object.keys(ex.map).length;
    ssConfirm('파일 <b>'+ssSalesPvName+'</b> · 시트 "<b>'+sheetNm+'</b>"<br>품목 <b style="color:#137a6c">'+items+'</b>종 · 매출액 합 <b style="color:#137a6c">'+ssNum(ex.sum)+'</b>원을 출고현황표에 반영하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 품목코드 기준으로 매칭되어 ‘매출액’ 행에 표시됩니다. 기존 매출금액은 이 파일로 교체됩니다.</span>',
      function(){
        ssSalesMap=ex.map; ssSalesCnt=ex.cnt;
        ssSalesSrc=ssSalesPvName+' · 품목 '+items+'종 · '+ssNum(ex.sum)+'원'+(ex.dates.length?(' · 입고일자 '+ex.dates[0]+(ex.dates.length>1?(' ~ '+ex.dates[ex.dates.length-1]):'')):'');
        ssSalesPvOpen(false);
        ssRender(); ssFlash();
        ssToast('💰 <b>'+ssSalesPvName+'</b> · 시트["'+sheetNm+'"] — 품목 '+items+'종 · 매출액 '+ssNum(ex.sum)+'원 <b>반영</b> 완료');
      });
  }

  // ── 매입금액 업로드 (매출금액 업로드와 동일 UX — 엑셀은 추후 제공) → 품목코드별 매입액
  var ssCostPvWb=null, ssCostPvName='', ssCostPvCur=null;
  function ssCostUpload(input){
    var f=input.files && input.files[0]; if(!f) return;
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); input.value=''; return; }
    ssCostPvName=f.name;
    var rd=new FileReader();
    rd.onload=function(e){
      ssReadXlsx(e.target.result, function(wb){
      try{
        ssCostPvWb=wb;
        var names=ssCostPvWb.SheetNames||[];
        document.getElementById('ssCostPvFile').textContent=f.name;
        var sel=document.getElementById('ssCostPvSheet');
        sel.innerHTML=names.map(function(n,i){ return '<option value="'+i+'">'+n+'</option>'; }).join('');
        sel.value='0';
        document.getElementById('ssCostPvSheetWrap').style.display = names.length>1 ? '' : 'none';
        ssCostPvRender();
        ssCostPvOpen(true);
      }catch(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); }
      }, function(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); });
      input.value='';
    };
    rd.readAsArrayBuffer(f);
  }
  function ssCostPvOpen(show){ document.getElementById('ssCostPvOverlay').classList.toggle('on', !!show); }
  function ssCostPvAoa(){
    var idx=+(document.getElementById('ssCostPvSheet').value||0);
    var ws=ssCostPvWb.Sheets[ssCostPvWb.SheetNames[idx]];
    return ws ? XLSX.utils.sheet_to_json(ws,{header:1,defval:''}) : [];
  }
  function ssCostPvRender(){
    var aoa=ssCostPvAoa();
    var m=ssSalesMapCols(aoa);   // 동일 컬럼 인식(품목코드·매입금액/단가)
    ssCostPvCur={aoa:aoa, map:m};
    var info=document.getElementById('ssCostPvInfo');
    var btn=document.getElementById('ssCostPvApplyBtn');
    var hlCols={};
    if(m){
      [m.cCode,m.cName,m.cDate,m.cInQty,m.cPrice,m.cAmt].forEach(function(c){ if(c>=0) hlCols[c]=1; });
      var ex=ssSalesExtract(aoa,m);
      info.className='ss-pvinfo';
      info.innerHTML='✅ 인식 완료 — <span class="tag">품목코드</span>'
        + (m.cInQty>=0?'<span class="tag">입고량</span>':'')
        + (m.cPrice>=0?'<span class="tag">단가</span>':'')
        + (m.cAmt>=0?'<span class="tag">매입금액</span>':'')
        + ' · 품목 <b>'+Object.keys(ex.map).length+'</b>종 · 매입액 합 <b>'+ssNum(ex.sum)+'</b>원 (노란 칸이 반영 대상)';
      btn.removeAttribute('disabled'); btn.style.opacity='1';
    } else {
      info.className='ss-pvinfo warn';
      info.innerHTML='⚠️ 매입금액 형식이 아닙니다 — 헤더에 <b>품목코드</b> 와 <b>매입금액(또는 단가)</b> 이 있어야 합니다. 시트를 바꿔 보세요.';
      btn.setAttribute('disabled','disabled'); btn.style.opacity='.5';
    }
    var maxR=Math.min(aoa.length,30), maxC=0;
    for(var i=0;i<maxR;i++) maxC=Math.max(maxC,(aoa[i]||[]).length);
    maxC=Math.min(maxC,40);
    var html='';
    for(var r=0;r<maxR;r++){
      var isHdr = m && (r===m.h);
      html+= isHdr ? '<tr class="hdr">' : '<tr>';
      html+='<td class="rn">'+(r+1)+'</td>';
      for(var c=0;c<maxC;c++){
        var v=ssCellDisp(aoa[r]&&aoa[r][c]);
        html+='<td'+(hlCols[c]?' class="hl"':'')+' title="'+v.replace(/"/g,'&quot;')+'">'+v+'</td>';
      }
      html+='</tr>';
    }
    if(aoa.length>30) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">이하 '+(aoa.length-30)+'행 생략 (작성 시 전체 반영)</td></tr>';
    document.getElementById('ssCostPvTbl').innerHTML=html;
  }
  function ssCostPvApply(){
    if(!ssCostPvCur || !ssCostPvCur.map){ ssToast('⚠️ 인식 가능한 매입금액 표가 아닙니다.'); return; }
    var ex=ssSalesExtract(ssCostPvCur.aoa, ssCostPvCur.map);
    if(!ex.cnt){ ssToast('⚠️ 매입금액 데이터 행이 없습니다.'); return; }
    var sheetNm=ssCostPvWb.SheetNames[+(document.getElementById('ssCostPvSheet').value||0)];
    var items=Object.keys(ex.map).length;
    ssConfirm('파일 <b>'+ssCostPvName+'</b> · 시트 "<b>'+sheetNm+'</b>"<br>품목 <b style="color:#137a6c">'+items+'</b>종 · 매입액 합 <b style="color:#137a6c">'+ssNum(ex.sum)+'</b>원을 출고현황표에 반영하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 품목코드 기준으로 ‘매입액’ 행에 표시되고 마진(매출−매입)이 자동 계산됩니다. 기존 매입금액은 이 파일로 교체됩니다.</span>',
      function(){
        ssCostMap=ex.map; ssCostCnt=ex.cnt;
        ssCostSrc=ssCostPvName+' · 품목 '+items+'종 · '+ssNum(ex.sum)+'원';
        ssCostPvOpen(false);
        ssRender(); ssFlash();
        ssToast('🧾 <b>'+ssCostPvName+'</b> · 시트["'+sheetNm+'"] — 품목 '+items+'종 · 매입액 '+ssNum(ex.sum)+'원 <b>반영</b> 완료');
      });
  }

  // 선택 시트의 2차원 배열
  function ssPvAoa(){
    var idx=+(document.getElementById('ssPvSheet').value||0);
    var ws=ssPvWb.Sheets[ssPvWb.SheetNames[idx]];
    return ws ? XLSX.utils.sheet_to_json(ws,{header:1,defval:''}) : [];
  }

  // ── 김해·제주 조기출고 규칙 (2026-07-26) ──
  //   김해·제주는 먼 지역이라 납기일자보다 2일 앞당겨 출고한다 → 그 행의 출고일자(SHPOUT_DT)= 납기일자 - 2일.
  //   그 외 출고장은 프리뷰에서 확정한 출고일자(baseDt)를 그대로 쓴다.
  function ssIsEarlyZone(name){ return /김해|제주/.test(''+(name==null?'':name)); }
  function ssShiftYmd(ymd, days){   // 'yyyy-mm-dd' (+days) → 'yyyy-mm-dd'
    var m=/^(\d{4})-(\d{2})-(\d{2})/.exec(''+(ymd==null?'':ymd)); if(!m) return (''+(ymd==null?'':ymd));
    var d=new Date(+m[1], +m[2]-1, +m[3]); d.setDate(d.getDate()+days);
    return d.getFullYear()+'-'+ssPad(d.getMonth()+1)+'-'+ssPad(d.getDate());
  }
  // 행의 확정 출고일자: 김해·제주면 납기일자-2일, 아니면 baseDt. 납기일자가 없으면 baseDt.
  function ssRowShpoutDt(zoneOrCenter, dlvDt, baseDt){
    return (ssIsEarlyZone(zoneOrCenter) && dlvDt) ? ssShiftYmd(dlvDt, -2) : baseDt;
  }

  // 컬럼 자동 인식 — 매핑화면 없이 내부 처리
  //  · (신규) 코네트 발주현황표: 단일 헤더행. 출고장=물류센터명, 사업장=품목명 () 접두,
  //    품목코드=품목코드, 출고량=현 발주
  //  · (기존) 2행 헤더 발주현황표: 출고장=존, 수량=수량
  function ssMapCols(aoa){
    function findEq(arr,name){ for(var k=0;k<arr.length;k++){ if((''+arr[k]).trim()===name) return k; } return -1; }
    // ── (신규) 코네트 발주현황표(출고장): 헤더 2줄
    //    1행=물류센터명/품목명/품목코드/사업장명 , 2행=입고장/존/수량
    //    · 출고장 = 물류센터명 + 입고장(1~4)  예) 평택물류센터1
    //    · 사업장 = 품목명의 () 접두 , 품목명 = () 뒤 , 출고량 = 수량
    for(var i=0;i<Math.min(aoa.length,8);i++){
      var r1=(aoa[i]||[]).map(function(c){return (''+c).trim();});
      if(findEq(r1,'물류센터명')>=0 && findEq(r1,'품목명')>=0){
        var r2=(aoa[i+1]||[]).map(function(c){return (''+c).trim();});
        function pick(n){ var k=findEq(r2,n); return k>=0?k:findEq(r1,n); }
        var cInb=pick('입고장');
        var cQk=pick('수량'); if(cQk<0){ cQk=pick('현 발주'); if(cQk<0) cQk=pick('현발주'); }
        if(cInb>=0){   // 입고장 컬럼이 있어야 코네트 출고장 양식으로 확정
          return { fmt:'konet', h:i, dataRow:i+2, zoneJoin:true,
                   cItem:findEq(r1,'품목명'), cCode:findEq(r1,'품목코드'),
                   cBiz:findEq(r1,'사업장명'), cBizCode:findEq(r1,'사업장코드'),
                   cCenter:findEq(r1,'물류센터명'), cInb:cInb, cQty:cQk,
                   cZone:findEq(r1,'물류센터명'),
                   cDate:findEq(r1,'납기일자'), cDlv:findEq(r1,'납기일자') };
        }
      }
    }
    // ── (기존) 2행 헤더 발주현황표
    var h=-1;
    for(var i=0;i<Math.min(aoa.length,6);i++){
      var row=(aoa[i]||[]).map(function(c){return (''+c).trim();});
      if(row.indexOf('품목명')>=0 && row.indexOf('사업장명')>=0){ h=i; break; }
    }
    if(h<0) return null;
    var h1=(aoa[h]||[]).map(function(s){return (''+s).trim();});
    var h2=(aoa[h+1]||[]).map(function(s){return (''+s).trim();});
    function findIn(arr,name){ for(var k=0;k<arr.length;k++){ if(arr[k]===name) return k; } return -1; }
    var cInb=findIn(h2,'입고장'), cZone=findIn(h2,'존'), cQty=findIn(h2,'수량');
    if(cZone<0){ cInb=findIn(h1,'입고장'); cZone=findIn(h1,'존'); cQty=findIn(h1,'수량'); }
    // 출고일자 = 엑셀의 '18차 가마감 일시'(처리일) 우선, 없으면 '납기일자'
    var cDate=findIn(h1,'18차 가마감 일시'); if(cDate<0) cDate=findIn(h1,'납기일자'); if(cDate<0) cDate=findIn(h2,'18차 가마감 일시');
    var cDlv=findIn(h1,'납기일자'); if(cDlv<0) cDlv=findIn(h2,'납기일자');
    return { fmt:'old', h:h, dataRow:h+2, cItem:findIn(h1,'품목명'), cBiz:findIn(h1,'사업장명'), cBizCode:findIn(h1,'사업장코드'), cCode:findIn(h1,'품목코드'), cInb:cInb, cZone:cZone, cQty:cQty, cDate:cDate, cDlv:cDlv };
  }

  function ssExtractRows(aoa,m){
    var rows=[];
    var _start = (m.dataRow!=null) ? m.dataRow : (m.h+2);   // 코네트=단일헤더(h+1) / 기존=2행헤더(h+2)
    for(var r=_start; r<aoa.length; r++){
      var row=aoa[r]||[]; var nm=(''+(row[m.cItem]||'')).trim(); if(!nm) continue;
      var bizNm=(''+(m.cBiz>=0?row[m.cBiz]:'')).trim();
      var bizCd=(''+(m.cBizCode>=0?row[m.cBizCode]:'')).trim();
      // 사업장 명칭에 사업장코드 부가: "사업장명 [코드]"
      var bizLbl = bizCd ? (bizNm ? (bizNm+' ['+bizCd+']') : ('['+bizCd+']')) : bizNm;
      var inbVal=(''+(m.cInb>=0?row[m.cInb]:'')).trim();
      // 출고장: 코네트 = 물류센터명 + 입고장(예: 평택물류센터1) / 기존 = 존 값 그대로
      var zoneVal;
      if(m.zoneJoin){
        // 출고장(행) = 물류센터명 + 입고장 (예: 평택물류센터1~4) — 묶음(그룹)은 물류센터명으로 표시
        var ctr=(''+(m.cCenter>=0?row[m.cCenter]:'')).trim();
        zoneVal=(ctr+inbVal).trim();
      } else {
        zoneVal=(''+(row[m.cZone]||'')).trim();
      }
      rows.push({
        ln:r+1,                                   // 엑셀 행번호(오류내역 표시용)
        code:(''+(m.cCode>=0?row[m.cCode]:'')).trim(),
        item:nm,
        biz:bizLbl,
        bizName:bizNm,
        bizCode:bizCd,
        inb:inbVal,
        zone:zoneVal,
        qty:(+(''+(row[m.cQty]||'')).replace(/[^0-9.\-]/g,''))||0,
        dlvDt:(m.cDlv>=0?ssFmtDate(row[m.cDlv]):''),
        date:(m.cDate>=0?ssFmtDate(row[m.cDate]):'') || SS_TODAY
      });
    }
    return rows;
  }

  var ssPvCur=null, ssPvBadFile=null;

  /* ══ 업로드 오류내역 (발주현황표) — 2026-07-26 요청 ══════════════════════════
       종전에는 양식이 다르면 "형식이 맞지 않는 자료입니다" 한 줄만 떴다 → 어디가 다른지 알 수 없었다.
       이제 두 가지를 나눠 보여준다.
         ① 양식 대조 : 기대 컬럼 중 무엇이 없는지 · 이 파일에 실제로 있는 머리글은 무엇인지
         ② 행 대조   : 양식은 맞지만 값이 빠져 집계가 어긋날 행(출고장·수량·품목코드·사업장·납기일자)
       ②는 저장을 막지 않는다(경고) — 막으면 정상 자료 대부분이 함께 걸리기 때문. 빨간 행으로 함께 표시.  */
  var SS_FMT_SPEC=[
    { key:'konet', name:'코네트 발주현황표(출고장)', req:['물류센터명','품목명','입고장'], qty:['수량','현 발주','현발주'],
      opt:['품목코드','사업장명','사업장코드','납기일자'] },
    { key:'old',   name:'기존 발주현황표(2행 헤더)', req:['품목명','사업장명','존'],       qty:['수량'],
      opt:['품목코드','사업장코드','납기일자','18차 가마감 일시'] }
  ];
  // 앞쪽 몇 행에서 머리글 후보(짧은 문자열)를 모은다 — 파일에 뭐가 들었는지 보여주려는 것
  function ssHdrCells(aoa, maxRow){
    var set={}, list=[];
    for(var i=0;i<Math.min(aoa.length, maxRow||8);i++){
      (aoa[i]||[]).forEach(function(c){
        var s=(''+(c==null?'':c)).trim();
        if(s && s.length<=20 && !set[s]){ set[s]=1; list.push(s); }
      });
    }
    // has() = 실제 파서(findIn)와 같은 부분일치. '수량(EA)' 같은 머리글을 '없다'고 잘못 적지 않으려는 것
    var has=function(n){
      if(set[n]) return true;
      for(var i=0;i<list.length;i++){ if(list[i].indexOf(n)>=0) return true; }
      return false;
    };
    return { set:set, list:list, has:has };
  }
  // 양식별 대조 — 맞은 개수가 많은 쪽을 '가장 가까운 양식'으로 앞에 놓는다
  function ssFmtDiag(aoa){
    var hd=ssHdrCells(aoa,8);
    var cand=SS_FMT_SPEC.map(function(sp){
      var miss=sp.req.filter(function(n){ return !hd.has(n); });
      if(!sp.qty.some(function(n){ return hd.has(n); })) miss=miss.concat([sp.qty[0]]);
      return { spec:sp, miss:miss, optMiss:sp.opt.filter(function(n){ return !hd.has(n); }), hit:(sp.req.length+1)-miss.length };
    });
    cand.sort(function(a,b){ return b.hit-a.hit; });
    return { hdr:hd, cand:cand };
  }
  // 양식 자체가 안 맞을 때의 오류내역 HTML
  function ssFmtErrHtml(aoa){
    var h='<div class="ss-pverr"><div class="eh">⚠️ 오류내역 — 이 엑셀은 <b>발주현황표 양식</b>이 아닙니다</div><ol>';
    if(!aoa.length){
      h+='<li>선택한 시트가 <b class="bad">비어 있습니다</b> (읽은 행 0). 다른 시트를 골라 보세요.</li>';
    } else {
      var d=ssFmtDiag(aoa);
      d.cand.forEach(function(c,i){
        h+='<li>'+(i===0?'<b>[가장 가까운 양식]</b> ':'')+'<b>'+_cesc(c.spec.name)+'</b> 기준 — '
          + (c.miss.length ? '없는 컬럼 <b class="bad">'+c.miss.map(_cesc).join(' · ')+'</b>'
                           : '<span class="ok">필수 컬럼은 모두 있음</span>')
          + (c.optMiss.length ? ' <span class="dim">(선택 컬럼 없음: '+c.optMiss.map(_cesc).join(' · ')+')</span>' : '')
          + '</li>';
      });
      h+='<li>이 시트에서 찾은 머리글 <span class="dim">'
        + (d.hdr.list.length ? _cesc(d.hdr.list.slice(0,25).join(' · '))+(d.hdr.list.length>25?(' … 외 '+(d.hdr.list.length-25)+'개'):'') : '없음')
        + '</span></li>';
      h+='<li class="dim">시트가 여러 개면 위 <b>시트</b> 선택을 바꿔 보고, 그래도 같으면 출고장에서 받은 <b>원본 파일</b>이 맞는지 확인하세요.</li>';
    }
    return h+'</ol></div>';
  }
  // 양식은 맞을 때 — 값이 빠진 행 찾기. 반환 bad = { 엑셀행index0 : 1 } (미리보기 빨간 행)
  function ssRowDiag(aoa, m){
    var _start=(m.dataRow!=null)?m.dataRow:(m.h+2);
    var d={ skip:[], zone:[], qty:[], code:[], biz:[], dlv:[], bad:{}, n:0 };
    for(var r=_start;r<aoa.length;r++){
      var row=aoa[r]||[];
      var nm=(''+(row[m.cItem]||'')).trim();
      if(!nm){
        // 품목명이 빈 행 — 완전 빈 행은 무시, 다른 칸에 값이 있으면 '반영 안 되는 행'(합계행 등)
        var any=false;
        for(var c=0;c<row.length;c++){ if((''+(row[c]==null?'':row[c])).trim()!==''){ any=true; break; } }
        if(any){ d.skip.push(r+1); d.bad[r]=1; }
        continue;
      }
      d.n++;
      var zone;
      if(m.zoneJoin) zone=((''+(m.cCenter>=0?row[m.cCenter]:'')).trim()+(''+(m.cInb>=0?row[m.cInb]:'')).trim()).trim();
      else zone=(''+(row[m.cZone]||'')).trim();
      var qraw=(''+(m.cQty>=0?(row[m.cQty]==null?'':row[m.cQty]):'')).trim();
      var qok=(qraw!=='' && !isNaN(+qraw.replace(/[^0-9.\-]/g,'')) && qraw.replace(/[^0-9.\-]/g,'')!=='');
      if(!zone){ d.zone.push(r+1); d.bad[r]=1; }
      if(!qok){ d.qty.push(r+1); d.bad[r]=1; }
      if(m.cCode>=0 && !(''+(row[m.cCode]||'')).trim()) d.code.push(r+1);
      if(m.cBiz >=0 && !(''+(row[m.cBiz ]||'')).trim()) d.biz.push(r+1);
      if(m.cDlv >=0 && !ssFmtDate(row[m.cDlv]))         d.dlv.push(r+1);
    }
    return d;
  }
  // 행번호 목록을 짧게 — "12, 13, 14 … 외 20행"
  function ssLnList(arr, max){
    max=max||8;
    var s=arr.slice(0,max).join(', ');
    return '<span class="ln">엑셀 '+s+(arr.length>max?(' … 외 '+(arr.length-max)+'행'):'')+' 행</span>';
  }
  // 행 오류내역 HTML — 없으면 빈 문자열
  function ssRowErrHtml(d){
    var e=[], w=[];
    if(d.zone.length) e.push({t:'<b class="bad">출고장이 비어 있음</b> — 이 행은 집계·저장에서 빠집니다', a:d.zone});
    if(d.qty.length)  e.push({t:'<b class="bad">수량이 비었거나 숫자가 아님</b> — 0 으로 저장됩니다',      a:d.qty});
    if(d.skip.length) w.push({t:'품목명이 없어 <b>반영되지 않는 행</b> (합계행·소계행일 수 있음)',          a:d.skip});
    if(d.code.length) w.push({t:'품목코드 없음 — 품목명으로만 매칭됩니다',                                  a:d.code});
    if(d.biz.length)  w.push({t:'사업장명 없음 — 사업장별 집계에서 빠집니다',                               a:d.biz});
    if(d.dlv.length)  w.push({t:'납기일자를 날짜로 못 읽음 — 출고일자 자동계산에서 빠집니다',               a:d.dlv});
    if(!e.length && !w.length) return '';
    var cls=e.length?'ss-pverr':'ss-pverr warn';
    var tot=e.reduce(function(s,x){return s+x.a.length;},0), wtot=w.reduce(function(s,x){return s+x.a.length;},0);
    var h='<div class="'+cls+'"><div class="eh">⚠️ 오류내역 — 데이터 '+d.n.toLocaleString()+'행 중 '
        + (tot?('<b>오류 '+tot.toLocaleString()+'행</b>'):'')+(tot&&wtot?' · ':'')+(wtot?('주의 '+wtot.toLocaleString()+'행'):'')
        + ' <span class="dim">(미리보기에서 <b>빨간 행</b>)</span></div><ul>';
    e.concat(w).forEach(function(x){ h+='<li>'+x.t+' '+ssLnList(x.a)+'</li>'; });
    return h+'</ul></div>';
  }

  // 도움말의 chrome://settings/downloads 복사 — 설정 주소는 링크로 못 열어(브라우저가 막음) 복사해서 주소창에 붙여넣게 한다.
  //   navigator.clipboard 는 https/localhost 에서만 되므로 execCommand 폴백을 함께 둔다(사내 http 접속 대비).
  function ssCopyTxt(txt, btn){
    function done(ok){
      if(btn){ var _o=btn.innerHTML; btn.innerHTML = ok?'✔ 복사됨':'복사 실패'; setTimeout(function(){ btn.innerHTML=_o; }, 1500); }
      ssToast(ok ? '📋 복사했습니다 — 크롬 <b>주소창</b>에 붙여넣고 Enter: <b>'+ssHistEsc(txt)+'</b>'
                 : '⚠️ 복사가 막혔습니다. 주소창에 직접 입력하세요: <b>'+ssHistEsc(txt)+'</b>');
    }
    try{
      if(navigator.clipboard && navigator.clipboard.writeText){
        navigator.clipboard.writeText(txt).then(function(){ done(true); }, function(){ done(ssCopyFallback(txt)); });
        return;
      }
    }catch(e){}
    done(ssCopyFallback(txt));
  }
  function ssCopyFallback(txt){
    try{
      var ta=document.createElement('textarea'); ta.value=txt;
      ta.style.cssText='position:fixed;left:-9999px;top:0'; document.body.appendChild(ta);
      ta.select(); var ok=document.execCommand('copy'); document.body.removeChild(ta); return ok;
    }catch(e){ return false; }
  }

  // 상단 [ℹ️ 도움말] 토글 — 기본 접힘. 접힘 상태를 브라우저에 기억(한번 읽은 사람은 계속 접힌 채로)
  function ssPvHelp(force){
    var box=document.getElementById('ssPvHelpBox'), btn=document.getElementById('ssPvHelpBtn'); if(!box) return;
    var on = (force===undefined) ? (box.style.display==='none') : !!force;
    box.style.display = on ? '' : 'none';
    if(btn) btn.innerHTML = on ? '✕ 도움말 닫기' : 'ℹ️ 도움말';
    if(force===undefined){ try{ localStorage.setItem('ssPvHelpOpen', on?'1':'0'); }catch(e){} }
  }

  function ssPvOpen(show){
    var ov=document.getElementById('ssPvOverlay'); if(!ov) return;
    var wasOpen=ov.classList.contains('on');
    ov.classList.toggle('on', !!show);
    if(show && !wasOpen){
      // 아직 아무 파일도 안 읽은 상태로 열릴 수 있다(버튼이 곧바로 이 모달을 연다) → 우측 빈칸 대신 안내
      if(!ssPvWb){
        var _i=document.getElementById('ssPvInfo'), _t=document.getElementById('ssPvTbl'), _f=document.getElementById('ssPvFile');
        var _e=document.getElementById('ssPvErr'); if(_e) _e.innerHTML='';
        if(_f) _f.textContent='-';
        if(_t) _t.innerHTML='';
        if(_i){ _i.className='ss-pvinfo';
          _i.innerHTML='📂 왼쪽 <b>업로드 파일</b> 목록에서 파일을 누르면 내용이 여기 표시됩니다. '
            +'<span style="color:#6b7a89">폴더를 아직 지정하지 않았다면 위쪽 <b>📂 폴더 지정</b>, 폴더 밖 파일이면 <b>📄 파일 선택</b>. 자세한 설명은 <b>ℹ️ 도움말</b>.</span>'; }
      }
      try{ ssPvHelp(localStorage.getItem('ssPvHelpOpen')==='1'); }catch(e){ ssPvHelp(false); }   // 도움말은 기본 접힘(지난번 펼쳐 뒀으면 그대로)
      ssAutoPick=true; ssHistRefresh();   // 열 때만 폴더 목록 로드 + 최신 파일 자동선택(파일 클릭마다 재스캔 방지)
      ssUpHistLoad();                     // 좌측 하단 업로드 이력(오늘·3일)도 열 때 1회 갱신
    }
  }

  // 셀 표시값 — 날짜는 엑셀처럼 YYYY-MM-DD(시간 있으면 포함)
  function ssCellDisp(v){
    if(v instanceof Date && !isNaN(v)){
      var Y=v.getFullYear(), M=ssPad(v.getMonth()+1), D=ssPad(v.getDate());
      var h=v.getHours(), m=v.getMinutes(), s=v.getSeconds();
      return (h||m||s) ? (Y+'-'+M+'-'+D+' '+ssPad(h)+':'+ssPad(m)+':'+ssPad(s)) : (Y+'-'+M+'-'+D);
    }
    return (v==null?'':(''+v));
  }
  // 미리보기 렌더 (엑셀 내용 그대로 + 인식컬럼 하이라이트)
  function ssPvRender(){
    var aoa=ssPvAoa();
    var m=ssMapCols(aoa);
    ssPvCur={aoa:aoa, map:m};
    var info=document.getElementById('ssPvInfo');
    var errBox=document.getElementById('ssPvErr');
    var btn=document.getElementById('ssPvApplyBtn');
    var hlCols={}, dlvCol=-1, badRows={};
    if(errBox) errBox.innerHTML='';
    var _earlyElReset=document.getElementById('ssPvEarlyMsg'); if(_earlyElReset){ _earlyElReset.style.display='none'; _earlyElReset.innerHTML=''; }
    if(m){
      [m.cItem,m.cBiz,m.cBizCode,m.cZone,m.cQty,m.cCode,m.cInb,m.cCenter].forEach(function(c){ if(c>=0) hlCols[c]=1; });
      if(m.cDate>=0){ dlvCol=m.cDate; }   // 납기일자 컬럼(구분 표시)
      var _exRows=ssExtractRows(aoa,m);
      var cnt=_exRows.length;
      // 김해·제주 조기출고 안내 — 해당 출고장이 파일에 있으면 출고일자 좌측에 메시지 표시
      var _earlyEl=document.getElementById('ssPvEarlyMsg');
      if(_earlyEl){
        var _earlyZ={}; _exRows.forEach(function(r){ if(ssIsEarlyZone(r.zone)){ var _n=(/김해/.test(r.zone)?'김해':'제주'); _earlyZ[_n]=1; } });
        var _ez=Object.keys(_earlyZ);
        if(_ez.length){
          _earlyEl.style.display='';
          _earlyEl.innerHTML='⚠️ '+_ez.join('·')+'는 출고일자가 <u>납기일자 2일 전</u>으로 저장됩니다 (조기출고)';
        } else { _earlyEl.style.display='none'; _earlyEl.innerHTML=''; }
      }
      // 출고일자 기본값 = 엑셀 계산값(18차 가마감 일시 우선, 없으면 납기일자) — 사용자가 고치지 않았으면 채움
      //  ★김해·제주 행은 조기출고라 여기서도 납기일자 2일 전을 반영(파일이 김해/제주 단일센터면 필드가 곧 2일전으로 뜬다)
      var shpEl=document.getElementById('ssPvShpoutDt');
      if(shpEl){
        if(shpEl.getAttribute('data-file')!==ssPvName){ shpEl.removeAttribute('data-touched'); shpEl.setAttribute('data-file', ssPvName||''); }
        if(shpEl.getAttribute('data-touched')!=='1'){
          var _ds=_exRows.map(function(r){ return ssRowShpoutDt(r.zone, r.dlvDt, r.date); }).filter(Boolean).sort();
          shpEl.value = _ds.length ? _ds[_ds.length-1] : SS_TODAY;
        }
      }
      info.className='ss-pvinfo';
      if(m.fmt==='konet'){
        info.innerHTML='✅ 인식 완료 (코네트 발주현황표·출고장) — '
          + '<span class="tag">물류센터명+입고장 → 출고장</span>'
          + '<span class="tag">품목명() → 사업장</span>'
          + (m.cCode>=0?'<span class="tag">품목코드</span>':'')
          + '<span class="tag">수량 → 출고량</span>'
          + ' · 데이터 <b>'+cnt+'</b>건 (노란 칸이 반영 대상)';
      } else {
        info.innerHTML='✅ 인식 완료 — <span class="tag">품목명</span><span class="tag">사업장명</span>'
          + (m.cBizCode>=0?'<span class="tag">사업장코드</span>':'')
          + '<span class="tag">존(출고장)</span><span class="tag">수량</span>'
          + (m.cCode>=0?'<span class="tag">품목코드</span>':'')
          + ' · 데이터 <b>'+cnt+'</b>건 (노란 칸이 반영 대상)';
      }
      // 양식은 맞아도 값이 빠진 행이 있으면 오류내역을 함께 (저장은 막지 않음)
      var _rd=ssRowDiag(aoa,m); badRows=_rd.bad;
      var _rh=ssRowErrHtml(_rd);
      if(errBox) errBox.innerHTML=_rh;
      if(_rh && (_rd.zone.length||_rd.qty.length) && ssPvBadFile!==ssPvName){
        ssPvBadFile=ssPvName;
        ssToast('⚠️ 오류내역 있음 — 출고장/수량이 빠진 행 '+(_rd.zone.length+_rd.qty.length)+'행 (미리보기 위쪽 확인)');
      }
      btn.removeAttribute('disabled'); btn.style.opacity='1';
    } else {
      info.className='ss-pvinfo warn';
      info.innerHTML='⚠️ <b>형식이 맞지 않는 자료입니다</b> — 발주현황표(출고) 양식이 아닙니다.<br>'
        + '헤더에 <b>물류센터명·품목명·현 발주</b>(코네트) 또는 <b>품목명·사업장명·존·수량</b> 이 있어야 합니다. 시트를 바꿔 보세요.';
      if(errBox) errBox.innerHTML=ssFmtErrHtml(aoa);   // 무엇이 다른지 목록으로
      btn.setAttribute('disabled','disabled'); btn.style.opacity='.5';
      // 같은 파일엔 한 번만 팝업(시트 바꿀 때마다 반복 방지)
      if(ssPvBadFile!==ssPvName){ ssPvBadFile=ssPvName; ssToast('⚠️ 형식이 맞지 않는 자료입니다 — 오류내역을 확인하세요'); }
    }
    // ※ ssPvBadFile 은 '이 파일로 이미 알렸다' 표시 — 오류가 없을 때만 푼다(있으면 시트 바꿔도 재알림 안 함)
    if(m && !Object.keys(badRows).length) ssPvBadFile=null;
    // 미리보기 표 (전체 행 표시 — 모달 내 스크롤)
    var maxR=Math.min(aoa.length,2000), maxC=0;
    for(var i=0;i<maxR;i++) maxC=Math.max(maxC,(aoa[i]||[]).length);
    maxC=Math.min(maxC,40);
    var html='';
    for(var r=0;r<maxR;r++){
      var isHdr = m && (r===m.h || r===m.h+1);
      html+= isHdr ? '<tr class="hdr">' : (badRows[r] ? '<tr class="badrow">' : '<tr>');
      html+='<td class="rn">'+(r+1)+'</td>';
      for(var c=0;c<maxC;c++){
        var v=ssCellDisp(aoa[r]&&aoa[r][c]);
        var cls = (c===dlvCol) ? 'dlv' : (hlCols[c] ? 'hl' : '');   // 납기일자=파란, 반영대상=노랑
        html+='<td'+(cls?' class="'+cls+'"':'')+' title="'+v.replace(/"/g,'&quot;')+'">'+v+'</td>';
      }
      html+='</tr>';
    }
    if(aoa.length>2000) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">이하 '+(aoa.length-2000)+'행 생략 (작성 시 전체 반영)</td></tr>';
    document.getElementById('ssPvTbl').innerHTML=html;
    ssBackMsgUpd();   // 마지막에 올린 자료보다 이전 출고일자면 하단에 알림(막지는 않음)
  }

  // 앱 스타일 확인 메시지 박스 (native confirm 대체)
  function ssConfirm(html, onYes, opts){
    opts=opts||{};
    var ov=document.getElementById('ssConfirmOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='ssConfirmOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(440px,90vw)">'
        +'<div class="mh"><h4 id="ssConfirmTitle">📋 반영 확인</h4><button class="x" onclick="ssConfirmClose()">&times;</button></div>'
        +'<div class="mbody" id="ssConfirmMsg" style="font-size:14px; line-height:1.6; color:#37475a"></div>'
        +'<div class="mfoot"><button class="btn-line" onclick="ssConfirmClose()">취소</button>'
        +'<button class="btn-teal" id="ssConfirmYes">반영</button></div></div>';
      document.body.appendChild(ov);
    }
    document.getElementById('ssConfirmTitle').textContent = opts.title || '📋 반영 확인';
    document.getElementById('ssConfirmMsg').innerHTML=html;
    var yes=document.getElementById('ssConfirmYes'); yes.textContent = opts.yes || '반영';
    yes.onclick=function(){ ssConfirmClose(); if(onYes) onYes(); };
    ov.classList.add('on');
  }
  function ssConfirmClose(){ var ov=document.getElementById('ssConfirmOv'); if(ov) ov.classList.remove('on'); }

  // 사업장·품목 직접 추가 (새 열 생성 → 칸에서 수량 입력)
  function ssAddItem(){
    var ov=document.getElementById('ssAddOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='ssAddOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(440px,92vw)">'
        +'<div class="mh"><h4>＋ 사업장·품목 추가</h4><button class="x" onclick="ssAddClose()">&times;</button></div>'
        +'<div class="mbody" style="font-size:13px">'
        +'<div style="margin-bottom:9px"><label style="display:block;color:#6b7a89;margin-bottom:3px">사업장(브랜드) — 기존 선택 또는 신규 입력</label><input id="ssAddBiz" list="ssAddBizDL" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="기존 사업장 선택 또는 새 이름(비우면 기타·공통)"><datalist id="ssAddBizDL"></datalist></div>'
        +'<div style="margin-bottom:9px"><label style="display:block;color:#6b7a89;margin-bottom:3px">품목명 * — 기존 검색 또는 신규 입력</label><input id="ssAddName" list="ssAddNameDL" oninput="ssAddNamePick(this.value)" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="품목명 검색 또는 새 품목명"><datalist id="ssAddNameDL"></datalist></div>'
        +'<div><label style="display:block;color:#6b7a89;margin-bottom:3px">품목코드(선택)</label><input id="ssAddCode" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="없으면 품목명으로 매칭"></div>'
        +'<div style="margin-top:8px;color:#9aa7b3;font-size:12px">추가하면 새 열이 생기고, 당일 모드에서 칸에 수량을 입력하면 합계에 자동 합산됩니다.</div>'
        +'</div>'
        +'<div class="mfoot"><button class="btn-line" onclick="ssAddClose()">취소</button><button class="btn-teal" onclick="ssAddSave()">추가</button></div></div>';
      document.body.appendChild(ov);
    }
    document.getElementById('ssAddBiz').value=''; document.getElementById('ssAddName').value=''; document.getElementById('ssAddCode').value='';
    document.getElementById('ssAddBizDL').innerHTML=(window.ssBrandList||[]).map(function(b){ return '<option value="'+(''+b).replace(/"/g,'&quot;')+'">'; }).join('');
    document.getElementById('ssAddNameDL').innerHTML=(window.ssItemList||[]).map(function(it){ return '<option value="'+(''+it.name).replace(/"/g,'&quot;')+'">'+(it.brand||'')+(it.code?(' · '+it.code):'')+'</option>'; }).join('');
    ov.classList.add('on');
  }
  // 품목명 검색 선택 시 코드·사업장 자동 채움
  function ssAddNamePick(v){
    v=(v||'').trim(); if(!v) return;
    var hit=(window.ssItemList||[]).filter(function(it){ return it.name===v || it.full===v; })[0];
    if(hit){ document.getElementById('ssAddCode').value=hit.code||''; document.getElementById('ssAddBiz').value=hit.brand||''; }
  }
  function ssAddClose(){ var ov=document.getElementById('ssAddOv'); if(ov) ov.classList.remove('on'); }
  function ssAddSave(){
    var biz=(document.getElementById('ssAddBiz').value||'').trim();
    var name=(document.getElementById('ssAddName').value||'').trim();
    var code=(document.getElementById('ssAddCode').value||'').trim();
    if(!name){ ssToast('⚠️ 품목명을 입력하세요.'); return; }
    var fullName = (biz && !/^\(/.test(name)) ? ('('+biz+')'+name) : name;   // 브랜드 접두로 그룹 매칭
    var key = code ? code : ('NM:'+fullName);
    // 중복 체크 — 품목코드(있으면) / 없으면 품목명 기준
    var dup = (window.ssItemList||[]).some(function(it){ return code ? (it.code===code && code!=='') : (it.full===fullName); })
            || ssExtraItems.some(function(e){ return e.key===key; });
    if(dup){ ssToast('⚠️ 이미 등록된 품목입니다'+(code?(' (품목코드 '+code+')'):' (품목명 동일)')); return; }
    ssExtraItems.push({name:fullName, code:code, key:key});
    ssAddClose(); ssRender();
    ssToast('＋ 품목 추가: '+name+(biz?(' ['+biz+']'):'')+' — 칸에 수량을 입력하세요(당일 모드)');
  }

  // 존(출고장) 직접 추가
  function ssAddZone(){
    var ov=document.getElementById('ssZoneOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='ssZoneOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(400px,92vw)">'
        +'<div class="mh"><h4>＋ 출고장 추가</h4><button class="x" onclick="ssZoneClose()">&times;</button></div>'
        +'<div class="mbody" style="font-size:13px"><label style="display:block;color:#6b7a89;margin-bottom:3px">출고장 코드</label>'
        +'<input id="ssZoneCode" style="width:100%;height:34px;border:1px solid #dfe6e3;border-radius:6px;padding:0 10px;box-sizing:border-box" placeholder="예) A5, B1, F9 (앞 글자=입고장 그룹)">'
        +'<div style="margin-top:8px;color:#9aa7b3;font-size:12px">앞 글자(A·C·D·F)로 입고장 그룹에 들어갑니다. 당일 모드에서 칸에 수량 입력 → 합계 자동 합산.</div></div>'
        +'<div class="mfoot"><button class="btn-line" onclick="ssZoneClose()">취소</button><button class="btn-teal" onclick="ssZoneSave()">추가</button></div></div>';
      document.body.appendChild(ov);
    }
    document.getElementById('ssZoneCode').value='';
    ov.classList.add('on');
  }
  function ssZoneClose(){ var ov=document.getElementById('ssZoneOv'); if(ov) ov.classList.remove('on'); }
  // 추가 품목/존 삭제 (수량 없을 때만 ✕ 노출됨)
  function ssDelItem(e, el){ if(e){e.stopPropagation();e.preventDefault();} var k=el.getAttribute('data-dk'); ssExtraItems=(ssExtraItems||[]).filter(function(x){return x.key!==k;}); ssRender(); ssToast('🗑 추가 품목 삭제'); }
  function ssDelZone(e, el){ if(e){e.stopPropagation();e.preventDefault();} var z=el.getAttribute('data-dz'); ssExtraZones=(ssExtraZones||[]).filter(function(x){return x!==z;}); ssRender(); ssToast('🗑 추가 출고장 삭제: '+z); }
  // 출고장 그룹 삭제 — 그룹(앞글자 기준)에 속한 모든 출고장 데이터 제거
  function ssDelZoneGroup(e, el){
    if(e){e.stopPropagation();e.preventDefault();}
    var L=el.getAttribute('data-dgl'); if(!L) return;
    ssConfirm('<b>'+L+'출고장</b> 그룹 전체를 삭제하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 이 그룹에 속한 모든 출고장이 삭제됩니다. 다른 그룹은 유지됩니다.</span>',
      function(){
        SHIP_DATA=SHIP_DATA.filter(function(r){ return ((''+(r.zone||'')).charAt(0)||'').toUpperCase()!==L; });
        ssExtraZones=(ssExtraZones||[]).filter(function(x){ return ((''+x).charAt(0)||'').toUpperCase()!==L; });
        delete ssZoneCollapsed[L];
        ssRender();
        ssToast('🗑 출고장 그룹 삭제: '+L+'출고장');
      });
  }
  // 개별 출고장 삭제 — 해당 출고장의 데이터만 제거(다른 출고장은 유지)
  function ssDelZoneData(e, el){
    if(e){e.stopPropagation();e.preventDefault();}
    var z=el.getAttribute('data-dz'); if(!z) return;
    ssConfirm('출고장 <b>'+z+'</b> 을(를) 삭제하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 이 출고장 행만 삭제되고, 다른 출고장은 그대로 유지됩니다.</span>',
      function(){
        SHIP_DATA=SHIP_DATA.filter(function(r){ return (''+(r.zone||''))!==z; });
        ssExtraZones=(ssExtraZones||[]).filter(function(x){ return x!==z; });
        ssRender();
        ssToast('🗑 출고장 삭제: '+z);
      });
  }
  // 출고장 초기화 — 화면의 모든 데이터(샘플/업로드) 비우기
  function ssClearAll(){
    ssConfirm('출고장을 <b>초기화</b> 하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ 화면의 모든 출고장·품목 데이터(샘플·업로드 포함)가 비워집니다. 이후 엑셀 업로드로 출고장을 새로 채울 수 있습니다.</span>',
      function(){
        SHIP_DATA=[];
        ssExtraItems=[]; ssExtraZones=[];
        ssZoneCollapsed={};
        window.ssSrcUp=false; window.ssSrcInfo='';
        ssRender();
        ssToast('🔄 출고장 초기화 — 데이터를 모두 비웠습니다.');
      });
  }
  function ssZoneSave(){
    var z=(document.getElementById('ssZoneCode').value||'').trim().toUpperCase();
    if(!z){ ssToast('⚠️ 출고장 코드를 입력하세요.'); return; }
    if((window.ssZoneList||[]).indexOf(z)>=0 || ssExtraZones.indexOf(z)>=0){ ssToast('⚠️ 이미 있는 출고장입니다: '+z); return; }
    ssExtraZones.push(z);
    ssZoneClose(); ssRender();
    ssToast('＋ 출고장 추가: '+z+' — 칸에 수량을 입력하세요(당일 모드)');
  }

  // 작성(반영): 확인 메시지 후 실행
  function ssPvApply(){
    // 파일을 아직 안 고른 채로 열릴 수 있다(버튼이 곧바로 모달을 연다) → '형식 오류'와 구분해서 안내
    if(!ssPvWb){ ssToast('⚠️ 먼저 왼쪽 목록에서 파일을 고르거나 <b>📄 파일 선택</b>으로 엑셀을 여세요.'); return; }
    if(!ssPvCur || !ssPvCur.map){ ssToast('⚠️ 형식이 맞지 않는 자료입니다 — 발주현황표(출고) 양식이 아니라 서버(TBL_SHIPOUT_MST)에 반영할 수 없습니다.'); return; }
    var rows=ssExtractRows(ssPvCur.aoa, ssPvCur.map);
    if(!rows.length){ ssToast('⚠️ 데이터 행이 없습니다.'); return; }
    var sheetNm=ssPvWb.SheetNames[+(document.getElementById('ssPvSheet').value||0)];
    var _upZ={}; rows.forEach(function(r){ if(r.zone) _upZ[r.zone]=1; }); var _zc=Object.keys(_upZ).length;
    // 김해·제주 조기출고 안내 (있으면 확인창에서 예외 문구 표시)
    var _earlyZ={}; rows.forEach(function(r){ if(ssIsEarlyZone(r.zone)) _earlyZ[/김해/.test(r.zone)?'김해':'제주']=1; });
    var _earlyList=Object.keys(_earlyZ);
    var _earlyNote = _earlyList.length ? ('<span style="color:#c0392b">기본값은 <b>'+_earlyList.join('·')+'</b>의 <u>납기일자 2일 전</u>입니다(조기출고). 위 날짜를 직접 바꾸면 <b>'+_earlyList.join('·')+'</b>도 그 값으로 저장됩니다.</span>') : '';
    // 출고일자 — 비어있으면 막는다(반영 확인창 하단에 이 값을 함께 표시)
    var _shpEl=document.getElementById('ssPvShpoutDt'); var _shp=(_shpEl&&_shpEl.value)||'';
    if(!_shp){ ssToast('⚠️ 출고일자를 입력하세요.'); if(_shpEl) _shpEl.focus(); return; }
    var _shpTouched = !!(_shpEl && _shpEl.getAttribute('data-touched')==='1');   // 프리뷰 필드를 직접 수정했는지
    // 반영 확인(단일) — 예전 1단계 '출고일자' 별도 창은 제거하고, 이 창 하단에 출고일자를 명시(2026-07-24 요청)
    ssConfirm('파일 <b>'+ssPvName+'</b> · 시트 "<b>'+sheetNm+'</b>"<br>발주 <b style="color:#137a6c">'+rows.length+'</b>건 · 출고장 <b style="color:#137a6c">'+_zc+'</b>곳을 반영하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ <b>기존 화면 자료를 초기화한 뒤</b> 이 파일로 새로 생성하고, <b>서버(TBL_SHIPOUT_MST)에 저장</b>됩니다. (같은 <b>납품일자·출고장</b>의 기존 저장분은 <b>출고일자가 달라도</b> 이력으로 남고 새 버전이 활성화됩니다.)</span>'
      +'<div style="text-align:center;margin-top:14px;padding-top:12px;border-top:1px solid #e6ecf0">출고일자 '
      +'<input type="date" id="ssConfirmShpDt" value="'+_shp+'" oninput="ssConfirmBackUpd()" style="font-size:18px;font-weight:700;color:#137a6c;text-align:center;border:1px solid #cdd7dd;border-radius:6px;padding:4px 8px">'
      +'<div style="font-size:11.5px;color:#9aa7b3;margin-top:5px">이 날짜로 저장됩니다 — 필요하면 여기서 바로 수정하세요<br>'+_earlyNote+'</div>'
      +'<div id="ssConfirmBack"></div></div>',   // 마지막에 올린 자료보다 이전이면 여기 경고가 채워진다(ssConfirmBackUpd)
      function(){
        var _ce=document.getElementById('ssConfirmShpDt');
        var _nv=(_ce&&_ce.value)||_shp;                                   // 확인창에서 수정한 값 우선, 비었으면 원래 값
        // ★출고일자를 사용자가 직접 지정했으면(프리뷰 필드 수정 or 확인창에서 값 변경) 김해·제주도 그 값으로 저장(수정값 우선).
        //   손대지 않았으면 김해·제주는 납기일자 2일 전 규칙 적용.
        window._ssShpOverride = _shpTouched || (_nv !== _shp);
        var _pv=document.getElementById('ssPvShpoutDt'); if(_pv) _pv.value=_nv;   // ssDoApply 가 여기서 읽음
        ssDoApply(rows, sheetNm);
      });
    ssConfirmBackUpd();   // 확인창을 그린 뒤 '이전 자료' 여부 판정(내용은 위 #ssConfirmBack 에 채워진다)
  }

  // 실제 반영 처리 — ★ 기존화면 자료 초기화 후 생성 (업로드 파일로 전체 교체) + 서버 저장
  function ssDoApply(rows, sheetNm){
    var upZones={}; rows.forEach(function(r){ if(r.zone) upZones[r.zone]=1; });
    var zoneList=Object.keys(upZones);
    // ★ 기존화면 자료 초기화 후 생성 (병합 아님)
    ssExtraItems=[]; ssExtraZones=[]; ssZoneCollapsed={};
    SHIP_DATA = rows.slice();
    var st=document.getElementById('ssBizSel'); if(st) st.value='__ALL__';
    // 출고일자(SHPOUT_DT): 프리뷰에서 확정한 값(엑셀기준·수정가능) 우선, 없으면 엑셀 계산값
    var upD=rows.map(function(r){ return r.date; }).filter(Boolean).sort();
    var _shpEl=document.getElementById('ssPvShpoutDt');
    var theDay = (_shpEl && _shpEl.value) ? _shpEl.value : (upD.length ? upD[upD.length-1] : SS_TODAY);
    // 화면 표시·날짜필터 기준을 출고일자로 통일 (엑셀엔 납기일자만 있어 r.date=납기일자로 채워지므로 덮어씀)
    //  ★김해·제주는 납기일자 2일 전(조기출고)이라 출고일자가 갈린다 → 행별로 확정하고, 갈리면 기간(min~max)으로 조회해 모두 보이게 한다.
    //   단, 사용자가 출고일자를 직접 지정(_ssShpOverride)했으면 김해·제주도 그 값(theDay)으로 통일한다(수정값 우선).
    var _ov = !!window._ssShpOverride;
    var _minD=theDay, _maxD=theDay;
    SHIP_DATA.forEach(function(r){ r.date = _ov ? theDay : ssRowShpoutDt(r.zone, r.dlvDt, theDay); if(r.date<_minD)_minD=r.date; if(r.date>_maxD)_maxD=r.date; });
    ssSetVal('ssDateFrom', _minD); ssSetVal('ssDateTo', _maxD);
    window.ssSrcUp=true;
    window.ssSrcInfo='✅ 업로드(초기화 후 생성): '+ssPvName+' · 출고장 '+zoneList.length+'곳 · '+rows.length+'건';
    ssRender();
    ssFlash();
    ssPvOpen(false);
    // ★ 서버 저장(TBL_SHIPOUT_MST) — 원본 전체컬럼, 기존 활성배치 이력마감 후 신규배치 INSERT
    ssSaveShipoutToDB(ssPvCur.aoa, theDay);
    // ★ 품목명 앞 () 없는 행의 사업장(코드→명)을 TBL_BIZI_MST 에 자동등록(없을때만) 후 분류 갱신
    ssSaveBiziFromRows(rows);
    ssToast('✅ <b>'+ssPvName+'</b> — 초기화 후 <b>'+rows.length+'</b>건 생성 (출고장 '+zoneList.length+'곳)');
  }

  // 업로드 행 중 "품목명 앞 () 없는" 사업장만 distinct 수집 → 서버 자동등록(insert if absent) → 분류 최신화
  function ssSaveBiziFromRows(rows){
    var seen={}, list=[];
    (rows||[]).forEach(function(r){
      var item=(''+(r.item||'')).trim(); if(!item) return;
      if(/^\(/.test(item)) return;                       // 괄호有 제외
      var bc=(''+(r.bizCode||'')).trim(); if(!bc || seen[bc]) return;
      seen[bc]=1; list.push({ bizCd:bc, bizNm:(''+(r.bizName||'')).trim() });
    });
    if(!list.length){ ssLoadBiziMst(function(){ ssRender(); }); return; }
    fetch('${pageContext.request.contextPath}/shipout/saveBiziAuto.do', {
      method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
      body: JSON.stringify(list)
    })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
    .then(function(r){
      if(r.ok && (+r.t)>0) ssToast('🏢 신규 사업장 <b>'+r.t+'</b>곳 자동등록 (TBL_BIZI_MST)');
      ssLoadBiziMst(function(){ ssRender(); });        // 등록 반영해 재분류
    })
    .catch(function(){ ssLoadBiziMst(function(){ ssRender(); }); });
  }

  // ── 발주현황표(코네트 출고장) 원본 전체컬럼을 서버 TBL_SHIPOUT_MST 에 저장
  //    헤더 2행(1행=메인/2행=현발주 하위) → 컬럼 매핑 후 /shipout/saveShipoutMst.do POST
  //    복합키 = (DLV_DT 납품일자 + DC_CD 물류센터코드). 서버에서 조합별 그룹·버전관리
  //    ★출고일자(SHPOUT_DT)는 키에서 제외(2026-07-27) — 같은 납품일자·출고장을 다른 출고일자로 다시 올려도 기존 자료를 대체한다
  function ssBuildShipoutRows(aoa){
    function eq(arr,name){ for(var k=0;k<arr.length;k++){ if((''+arr[k]).trim()===name) return k; } return -1; }
    // 헤더행 탐색 (1행에 물류센터명+품목명)
    var h=-1, r1=[], r2=[];
    for(var i=0;i<Math.min(aoa.length,8);i++){
      var rr=(aoa[i]||[]).map(function(c){return (''+c).trim();});
      if(eq(rr,'물류센터명')>=0 && eq(rr,'품목명')>=0){ h=i; r1=rr; r2=(aoa[i+1]||[]).map(function(c){return (''+c).trim();}); break; }
    }
    if(h<0) return [];
    // 헤더명 → 컬럼인덱스 (1행 우선, 없으면 2행=현발주 하위)
    function idx(name){ var k=eq(r1,name); return k>=0?k:eq(r2,name); }
    var MAP={
      rowNo:'No', inrsvYn:'입고예약', labelPrtGb:'라벨발행구분', dcCd:'물류센터코드', dcNm:'물류센터명',
      vendorCd:'협력업체코드', vendorNm:'협력업체명', itemCd:'품목코드', itemNm:'품목명', fsfdGb:'FS/FD 구분',
      dlvDt:'납기일자', statYn:'상황여부', prodKind:'상품종류', tempGb:'온도구분', ordGb:'발주구분',
      bizCd:'사업장코드', bizNm:'사업장명', boxQty:'Box입수량', labelQty:'라벨수량', unpaidLabelQty:'미납라벨수량',
      inwh:'입고장', zone:'존', busNo:'버스번호', rtSeq:'RT순번', curQty:'수량', dlvGb:'배송구분', remark:'특기사항',
      unit:'단위', indivId:'개체식별번호', ordNo:'발주번호', ordItemNo:'발주ITEM번호', jumunNo:'주문번호',
      jumunItemNo:'주문ITEM번호', sorter:'소터'
    };
    var COL={}; for(var f in MAP){ COL[f]=idx(MAP[f]); }
    var NUM={rowNo:1,boxQty:1,labelQty:1,unpaidLabelQty:1,curQty:1}, DT={dlvDt:1};
    function num(v){ var s=(''+(v==null?'':v)).replace(/[^0-9.\-]/g,''); return s===''?null:(parseInt(s,10)||0); }
    var out=[];
    for(var r=h+2; r<aoa.length; r++){
      var row=aoa[r]||[];
      var nm=(''+(COL.itemNm>=0?row[COL.itemNm]:'')).trim(); if(!nm) continue;   // 품목명 없으면 데이터 끝
      var obj={};
      for(var fld in COL){
        var c=COL[fld]; var cell=(c>=0)?row[c]:'';
        if(NUM[fld]) obj[fld]=num(cell);
        else if(DT[fld]) obj[fld]=ssFmtDate(cell);            // yyyy-mm-dd (서버에서 '-' 제거 저장)
        else obj[fld]=(''+(cell==null?'':cell)).trim();
      }
      out.push(obj);
    }
    return out;
  }
  /* 발주현황표 서버저장 진행바 — 정산엑셀(slsProg)과 동일 원리: 업로드 실측(0~25%) → 서버추정(25~95%) → 완료(100%).
       이 저장은 프리뷰 모달이 닫힌 뒤 백그라운드로 도므로, 전용 중앙 오버레이로 표시한다(자체 <style> 포함·독립). */
  var SHP_PROG_UP=25, SHP_PROG_CEIL=95;
  var _shpProgTimer=null, _shpProgSrvStart=0, _shpProgTau=3000;
  function _shpProgEnsure(){
    var ov=document.getElementById('shpProgOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='shpProgOv';
      ov.style.cssText='display:none;position:fixed;inset:0;z-index:100001;background:rgba(15,23,32,.35);align-items:center;justify-content:center';
      ov.innerHTML='<style>@keyframes shpProgFlow{0%{background-position:0 0}100%{background-position:34px 0}}'
        +'.shp-prog-indet{background-image:repeating-linear-gradient(45deg,rgba(255,255,255,.28) 0 9px,rgba(255,255,255,0) 9px 17px),linear-gradient(90deg,#17a589,#137a6c)!important;background-size:34px 34px,100% 100%!important;animation:shpProgFlow .7s linear infinite}</style>'
        +'<div style="background:#fff;width:min(420px,92vw);border-radius:12px;box-shadow:0 12px 40px rgba(0,0,0,.3);overflow:hidden">'
        +'<div style="background:linear-gradient(135deg,#1f9b8e,#137a6c);color:#fff;padding:12px 18px;font-size:15px;font-weight:600">💾 발주현황표 저장</div>'
        +'<div style="padding:18px 20px 20px">'
        +'<div style="display:flex;justify-content:space-between;font-size:12px;color:#5a6b7a;margin-bottom:6px"><span id="shpProgLab">저장 준비 중…</span><span id="shpProgPct" style="font-weight:700;color:#137a6c"></span></div>'
        +'<div style="height:11px;background:#e6ecf0;border-radius:6px;overflow:hidden"><div id="shpProgFill" style="height:100%;width:0%;background:linear-gradient(90deg,#17a589,#137a6c);border-radius:6px;transition:width .2s ease"></div></div>'
        +'</div></div>';
      document.body.appendChild(ov);
    }
    return ov;
  }
  function _shpProgWidth(pct, stripe){
    pct=Math.max(0,Math.min(100,pct));
    var f=document.getElementById('shpProgFill'), p=document.getElementById('shpProgPct');
    if(f){ f.style.width=pct+'%'; if(stripe) f.classList.add('shp-prog-indet'); else f.classList.remove('shp-prog-indet'); }
    if(p) p.textContent=Math.round(pct)+'%';
  }
  function _shpProgLab(t){ var l=document.getElementById('shpProgLab'); if(l && t!=null) l.textContent=t; }
  function shpProgShow(lab){ _shpProgEnsure().style.display='flex'; _shpProgWidth(0,false); _shpProgLab(lab||'저장 준비 중…'); }
  function shpProgUpload(frac, lab){ _shpProgWidth((+frac||0)*SHP_PROG_UP, false); _shpProgLab(lab); }
  function shpProgServerStart(rows){
    _shpProgTau=Math.max(1500, (+rows||0)*7);
    _shpProgSrvStart=Date.now();
    _shpProgWidth(SHP_PROG_UP, true);
    _shpProgLab('서버 반영 중… (이력마감·배치 저장)');
    if(_shpProgTimer) clearInterval(_shpProgTimer);
    _shpProgTimer=setInterval(function(){
      var t=Date.now()-_shpProgSrvStart;
      _shpProgWidth(SHP_PROG_UP + (SHP_PROG_CEIL-SHP_PROG_UP)*(t/(t+_shpProgTau)), true);
    }, 150);
  }
  function _shpProgStop(){ if(_shpProgTimer){ clearInterval(_shpProgTimer); _shpProgTimer=null; } }
  function shpProgDone(){ _shpProgStop(); _shpProgWidth(100,false); _shpProgLab('완료'); }
  function shpProgHide(){ _shpProgStop(); var ov=document.getElementById('shpProgOv'); if(ov) ov.style.display='none'; var f=document.getElementById('shpProgFill'); if(f){ f.classList.remove('shp-prog-indet'); f.style.width='0%'; } }
  function ssSaveShipoutToDB(aoa, baseDt){
    var rows=ssBuildShipoutRows(aoa);
    if(!rows.length) return;
    var srcFile=ssPvName;
    // 복합키=(납품일자 DLV_DT 행별) + (물류센터 DC_CD 행별). 출고일자·사업장은 키 아님(출고일자는 값으로만 저장).
    //  ★김해·제주는 납기일자 2일 전으로 출고일자 저장(조기출고), 그 외는 baseDt(프리뷰 확정값)
    //   단, 사용자가 출고일자를 직접 지정(_ssShpOverride)했으면 김해·제주도 baseDt 로 통일(수정값 우선).
    var _ov = !!window._ssShpOverride;
    rows.forEach(function(o){ if(!o.dlvDt) o.dlvDt=baseDt; o.shpoutDt = _ov ? baseDt : ssRowShpoutDt(o.dcNm||o.zone, o.dlvDt, baseDt); o.srcFile=srcFile; });
    var body=JSON.stringify(rows), nRows=rows.length;
    shpProgShow('업로드 중… (0 / '+nRows.toLocaleString()+'건)');
    var xhr=new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/shipout/saveShipoutMst.do', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.withCredentials=true;
    // 1) 업로드 진행 — 실제 전송 바이트로 0~25% (건수는 근사표기)
    xhr.upload.onprogress=function(ev){
      if(!ev.lengthComputable) return;
      var frac=ev.loaded/ev.total;
      shpProgUpload(frac, '업로드 중… ('+Math.round(frac*nRows).toLocaleString()+' / '+nRows.toLocaleString()+'건)');
    };
    // 2) 업로드 완료 → 서버 반영 구간: 경과시간 추정 %로 25→95% 전진
    xhr.upload.onload=function(){ shpProgServerStart(nRows); };
    xhr.onload=function(){
      shpProgDone();                 // 실제 응답 → 100% 스냅
      setTimeout(shpProgHide, 500);
      var ok=(xhr.status>=200 && xhr.status<300), t=xhr.responseText;
      if(ok){
        ssToast('💾 서버 저장 완료 — 출고일자 '+baseDt+' · <b>'+t+'</b>건 (기존 자료 초기화 후 생성)');
        if(window.ssLoadShipoutFromDB) ssLoadShipoutFromDB();   // 저장 끝나면 출고일자로 DB 조회 1회 자동 실행
        if(window.ssUpHistLoad) ssUpHistLoad();                 // 방금 올린 배치가 좌측 '올린 이력' 맨 위로 올라오게
        if(window.ssArchiveApplied) ssArchiveApplied(srcFile);  // 반영 끝난 엑셀은 상단 목록에서 「_반영됨」으로 치운다
      }
      else ssToast('⚠️ 서버 저장 실패: '+(t||('HTTP '+xhr.status)));
    };
    xhr.onerror=function(){ shpProgHide(); ssToast('⚠️ 서버 저장 통신오류 — 네트워크를 확인하세요.'); };
    xhr.ontimeout=function(){ shpProgHide(); ssToast('⚠️ 저장 시간 초과 — 잠시 후 다시 시도하세요.'); };
    xhr.send(body);
  }

  // 일자별(단일 일자) 조건인지
  function ssIsSingleDay(){
    var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
    return !!(f && f===t) ? f : '';
  }

  // 해당일자 출고데이터 저장 (일자별 조건에서만)
  function ssSaveData(){
    var d=ssIsSingleDay();
    if(!d){ ssToast('⚠️ 출고데이타저장은 일자별(시작=종료) 조건에서만 가능합니다.'); return; }
    var ag=ssAggregate();
    if(!(ag.totQty>0)){ ssToast('⚠️ '+d+' 출고 데이터가 없습니다.'); return; }
    var items=Object.keys(ag.items).length;
    ssConfirm('<b>'+d+'</b> 출고데이터를 저장하시겠습니까?<br>품목 <b style="color:#137a6c">'+items+'</b>종 · 출고 <b style="color:#137a6c">'+ssNum(ag.totQty)+'</b> BOX'
      +'<br><br><span style="color:#9aa7b3">※ 데모: 브라우저에 저장됩니다. 실제 운영 시 서버 출고테이블에 저장됩니다.</span>',
      function(){
        try{ localStorage.setItem('ssSaved_'+d, JSON.stringify({date:d, qty:ag.totQty, items:items})); }catch(e){}
        ssToast('💾 <b>'+d+'</b> 출고데이터 저장 완료 (품목 '+items+'종 · '+ssNum(ag.totQty)+' BOX)');
      });
  }

  // 출고현황표 → 엑셀(.xlsx) : 데이터 모델에서 깔끔한 숫자표로 재구성(날짜 오인 방지) + 상단 출고일자
  function ssDownload(){
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
    var ag=ssAggregate();
    var keys=Object.keys(ag.items).sort(function(a,b){ var A=ag.items[a],B=ag.items[b]; return A.brand.localeCompare(B.brand,'ko')||A.name.localeCompare(B.name,'ko'); });
    if(!keys.length){ ssToast('⚠️ 출력할 데이터가 없습니다.'); return; }
    var zones=Object.keys(ag.zoneSet).sort();
    var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
    var dlab=(f&&f===t)?f:(f+' ~ '+t);
    var colTot={}; zones.forEach(function(z){ keys.forEach(function(k){ colTot[k]=(colTot[k]||0)+((ag.matrix[z]&&ag.matrix[z][k])||0); }); });
    function cv(v){ return v?v:''; }                 // 0은 공백(숫자형 유지)
    function row(label, getv){
      var cells=[], sum=0;
      keys.forEach(function(k){ var v=getv(k)||0; sum+=v; cells.push(cv(v)); });
      return ssSumFront ? [label, sum].concat(cells) : [label].concat(cells, [sum]);
    }
    var aoa=[];
    aoa.push(['출고현황표']);
    aoa.push(['출고일자', dlab]);
    aoa.push([]);
    // 헤더 2행 (사업장 / 품목(코드))
    var h1=ssSumFront?['출고장 \\ 품목','합계']:['출고장 \\ 품목'];
    var h2=ssSumFront?['','']:[''];
    for(var i=0;i<keys.length;){
      var br=ag.items[keys[i]].brand, j=i; while(j<keys.length && ag.items[keys[j]].brand===br) j++;
      h1.push(br); for(var x=i+1;x<j;x++) h1.push('');
      for(var p=i;p<j;p++){ var it=ag.items[keys[p]]; h2.push(ssShortName(it.name)+(it.code?(' ('+it.code+')'):'')); }
      i=j;
    }
    if(!ssSumFront){ h1.push('합계'); h2.push(''); }
    aoa.push(h1); aoa.push(h2);
    // 출고장 그룹별 (그룹순서 설정 반영 — 물류센터명 기준, 데시보드2와 공유)
    var byL={}, letters=[]; zones.forEach(function(z){ var L=(z.charAt(0)||'').toUpperCase(); if(!byL[L]){ byL[L]=[]; letters.push(L); } byL[L].push(z); });
    function _lblOf(L){ var _n=(''+(byL[L][0]||'')).replace(/\s*\d+\s*$/,'').trim(); return (_n.length>1)?_n:(L+'출고장'); }
    letters.sort(function(a,b){ var la=_lblOf(a), lb=_lblOf(b); var ia=ssGroupOrder.indexOf(la), ib=ssGroupOrder.indexOf(lb); if(ia>=0&&ib>=0) return ia-ib; if(ia>=0) return -1; if(ib>=0) return 1; return la.localeCompare(lb,'ko'); });
    letters.forEach(function(L){
      aoa.push([L+'출고장']);
      byL[L].forEach(function(z){ aoa.push(row(z+' 출고장', function(k){ return (ag.matrix[z]&&ag.matrix[z][k])||0; })); });
      aoa.push(row(L+'출고장 합계', function(k){ var s=0; byL[L].forEach(function(z){ s+=(ag.matrix[z]&&ag.matrix[z][k])||0; }); return s; }));
    });
    aoa.push(row('전체 출고장 합계', function(k){ return colTot[k]||0; }));
    if(ag.unassigned>0) aoa.push(row('미배정('+ag.unassigned+'건)', function(k){ return ag.unMatrix[k]||0; }));
    aoa.push([]);
    aoa.push(['■ 출고내역 · 재고량']);
    var base={}; keys.forEach(function(k){ var it=ag.items[k]; base[k]=30+(ssHash(it.code||it.name)%150); });
    aoa.push(row('재고량(기초)', function(k){ return base[k]; }));
    var selLbl=(f&&f===t)?(f===SS_TODAY?'당일 출고':'선택일 출고'):'기간 출고';
    aoa.push(row(selLbl, function(k){ return colTot[k]||0; }));
    var ym=SS_TODAY.slice(0,7), mTot={};
    SHIP_DATA.forEach(function(r){ if(!r.zone) return; if((''+(r.date||SS_TODAY)).slice(0,7)!==ym) return; var c=(''+(r.code||'')).trim(), kk=c?c:('NM:'+r.item); mTot[kk]=(mTot[kk]||0)+(+r.qty||0); });
    aoa.push(row('당월 출고('+ym+')', function(k){ return mTot[k]||0; }));
    aoa.push(row('현재고', function(k){ return base[k]-(colTot[k]||0); }));
    SS_MONTHS.forEach(function(mn){ aoa.push(row(mn+' 출고', function(k){ var it=ag.items[k]; return ssHash((it.code||it.name)+mn)%9; })); });

    var ws=XLSX.utils.aoa_to_sheet(aoa);
    ws['!cols']=[{wch:16}].concat(keys.map(function(){ return {wch:11}; })).concat([{wch:9}]);
    if(ssSumFront) ws['!cols'].splice(1,0,{wch:9});
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '출고현황표');
    XLSX.writeFile(wb, '출고현황표_'+(f||'')+((t&&t!==f)?'~'+t:'')+'.xlsx');
    ssToast('📥 출고현황표 엑셀 저장 완료 (출고일자 '+dlab+')');
  }

  // xlsx-js-style(무료·MIT, SheetJS 스타일 지원 포크) 지연 로드 — 색·테두리 엑셀 전용.
  //   · 로컬(폐쇄망 대비) 우선 → 실패 시 CDN 순으로 시도
  //   · 읽기용 원본 XLSX 는 건드리지 않도록, 로드 후 window.XLSX 를 즉시 원복하고 스타일본만 캐시
  var _XLSXStyle=null;
  var _XLSXStyleSrcs=[
    '${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js',
    'https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js'
  ];
  function ssLoadStyleXlsx(cb){
    if(_XLSXStyle){ cb(_XLSXStyle); return; }
    var prev=window.XLSX, i=0;
    (function tryNext(){
      if(i>=_XLSXStyleSrcs.length){ window.XLSX=prev; cb(null); return; }
      var s=document.createElement('script');
      s.src=_XLSXStyleSrcs[i++];
      s.onload=function(){ _XLSXStyle=window.XLSX; window.XLSX=prev; cb(_XLSXStyle); };
      s.onerror=function(){ window.XLSX=prev; tryNext(); };   // 다음 소스로 폴백
      document.head.appendChild(s);
    })();
  }

  // 출고장별 엑셀(.xlsx) : ★ 한 장(시트 1개)에 출고장을 위→아래로 구분해 쌓음 + 색/테두리(출고장 화면 스타일)
  //   · 각 출고장 블록에는 그 출고장에 '출고량이 있는 품목만' 나열(상품 없는 품목 제외)
  //   · 물건 없는 출고장은 블록 자체를 생략, 출고장 사이는 빈 줄로 구분
  function ssDownloadByZone(){
    ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || window.XLSX;               // 스타일본 실패 시 원본(무색)으로라도 저장
      var styled = !!XLSXS;
      if(!LIB){ ssToast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var ag=ssAggregate();
      var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
      var dlab=(f&&f===t)?f:(f+' ~ '+t);
      // 매트릭스 key → 품목명/사업장/코드 (미배정 key 도 안전 처리)
      function kName(k){ return (ag.items[k]&&ag.items[k].name) || (String(k).indexOf('NM:')===0? String(k).slice(3): k); }
      function kBrand(k){ return (ag.items[k]&&ag.items[k].brand) || ''; }
      function kCode(k){ return (ag.items[k]&&ag.items[k].code) || (String(k).indexOf('NM:')===0? '': k); }
      function srt(a,b){ return kBrand(a).localeCompare(kBrand(b),'ko')||kName(a).localeCompare(kName(b),'ko'); }

      var COLS=5;                 // No | 사업장 | 품목명 | 품목코드 | 출고수량
      var aoa=[], merges=[], meta=[];   // meta[r] = 행 유형(스타일 적용용)
      function mergeRow(ri, e){ merges.push({s:{r:ri,c:0}, e:{r:ri,c:(e==null?COLS-1:e)}}); }
      function push(row, ty, mEnd){ aoa.push(row); meta.push(ty); if(mEnd!=null) mergeRow(aoa.length-1, mEnd); }
      // 상단 제목
      push(['출고장별 출고현황'], 'title', COLS-1);
      push(['출고일자  '+dlab], 'date', COLS-1);
      push([], 'blank');

      // 출고장별 발주일자(납기일자) 집계 — SHIP_DATA 행에서 zone → 발주일자 distinct
      var zoneDlv={};
      (SHIP_DATA||[]).forEach(function(r){ if(!r||!r.zone) return; var d=(''+(r.dlvDt||'')).trim(); if(!d) return; (zoneDlv[r.zone]=zoneDlv[r.zone]||{})[d]=1; });
      function dlvLabelOf(z){ var a=Object.keys(zoneDlv[z]||{}).sort(); return a.length?('발주일자 '+a.join(', ')):''; }

      // 출고장 1개 블록을 아래로 이어붙임
      function block(zoneLabel, keys, get, extra){
        var tot=0; keys.forEach(function(k){ tot+=(get(k)||0); });
        push(['▣ '+zoneLabel+'   (품목 '+keys.length+'종 · 출고 '+ssNum(tot)+(extra?(' · '+extra):'')+')'], 'zone', COLS-1);   // 출고장 제목줄
        push(['No','사업장','품목명','품목코드','출고수량'], 'head');                                    // 컬럼 헤더
        keys.forEach(function(k,ix){ push([ix+1, kBrand(k), kName(k), kCode(k), get(k)||0], 'item'); }); // 품목행(수량>0만, 출고장별 1번부터)
        push(['소계','','','',tot], 'sub', COLS-2);                                                     // 소계(라벨 병합)
        push([], 'blank');                                                                              // 출고장 구분 빈 줄
      }

      // 출고장 정렬 — 그룹(물류센터명) 순서설정 반영 후, 그룹 내 이름순 (데시보드2와 공유)
      function _gidx(z){ var lbl=(''+z).replace(/\s*\d+\s*$/,'').trim(); var i=ssGroupOrder.indexOf(lbl); return i>=0?i:9999; }
      var zones=Object.keys(ag.zoneSet).sort(function(a,b){ var d=_gidx(a)-_gidx(b); return d!==0?d:a.localeCompare(b,'ko'); });
      var made=0, skipped=0, grand=0;
      zones.forEach(function(z){
        var mz=ag.matrix[z]||{};
        var keys=Object.keys(mz).filter(function(k){ return (mz[k]||0)>0; }); // 상품 없는(0) 품목 제외
        if(!keys.length){ skipped++; return; }                                // 물건 없는 출고장은 생략
        keys.sort(srt);
        keys.forEach(function(k){ grand+=(mz[k]||0); });
        block(z+' 출고장', keys, function(k){ return mz[k]||0; }, dlvLabelOf(z));
        made++;
      });
      // 미배정(출고장 미지정) 품목도 블록으로 (있을 때만)
      if(ag.unassigned>0){
        var uk=Object.keys(ag.unMatrix).filter(function(k){ return (ag.unMatrix[k]||0)>0; });
        if(uk.length){ uk.sort(srt); uk.forEach(function(k){ grand+=(ag.unMatrix[k]||0); }); block('미배정 · 출고장 미지정', uk, function(k){ return ag.unMatrix[k]||0; }); }
      }
      if(!made){ ssToast('⚠️ 출고량이 있는 출고장이 없습니다.'); return; }
      push(['전체 합계','','','',grand], 'grand', COLS-2);

      var ws=LIB.utils.aoa_to_sheet(aoa);
      ws['!cols']=[{wch:5},{wch:18},{wch:44},{wch:18},{wch:11}];
      ws['!merges']=merges;

      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'DFE6E3'}};
        var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          title:{ fill:{fgColor:{rgb:'178074'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          date:{ font:{color:{rgb:'1F2A37'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          zone:{ fill:{fgColor:{rgb:'1F9B8E'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          head:{ fill:{fgColor:{rgb:'E3F4EF'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          itemC:{ font:{color:{rgb:'6B7A89'}}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemCB:{ font:{color:{rgb:'000000'}}, alignment:{horizontal:'center',vertical:'center'}, border:box }, // No·품목코드(검정)
          itemN:{ font:{color:{rgb:'1F2A37'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box }, // 출고수량 조금 크게
          subL:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'37475A'},bold:true}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          subN:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'137A6C'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box }, // 소계 값 크게
          grandL:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grandN:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:14}, alignment:{horizontal:'right',vertical:'center'} } // 전체합계 값 크게
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rows=[];
        meta.forEach(function(ty,r){
          var h=null;
          if(ty==='title'){ put(r,0,S.title); h=26; }
          else if(ty==='date'){ put(r,0,S.date); h=24; }
          else if(ty==='zone'){ put(r,0,S.zone); h=22; }
          else if(ty==='head'){ for(var c=0;c<COLS;c++) put(r,c,S.head); h=20; }
          else if(ty==='item'){ put(r,0,S.itemCB); put(r,1,S.itemL); put(r,2,S.itemL); put(r,3,S.itemCB); put(r,4,S.itemN); } // 0=No, 3=품목코드 → 검정 가운데
          else if(ty==='sub'){ for(var c2=0;c2<COLS-1;c2++) put(r,c2,S.subL); put(r,COLS-1,S.subN); h=19; }
          else if(ty==='grand'){ for(var c3=0;c3<COLS-1;c3++) put(r,c3,S.grandL); put(r,COLS-1,S.grandN); h=22; }
          rows.push(h!=null?{hpt:h}:{});
        });
        ws['!rows']=rows;
      }

      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, '출고장별');
      LIB.writeFile(wb, '출고장별_'+(f||'')+((t&&t!==f)?'~'+t:'')+'.xlsx');
      ssToast('📥 출고장별 엑셀(한 장'+(styled?', 색구분':'')+') 저장 완료 · 출고장 '+made+'개'+(skipped?(' (물건없는 '+skipped+'개 제외)'):'')+' · 출고일자 '+dlab);
    });
  }

  // 출고현황표 → PDF 파일 저장 (jsPDF + html2canvas, 한글 안전)
  function ssPdf(){
    var jsPDF = window.jspdf && window.jspdf.jsPDF;
    if(!jsPDF || !window.html2canvas){ ssToast('⚠️ PDF 라이브러리 로딩 중입니다(인터넷 필요). 잠시 후 다시 시도하세요.'); return; }
    var tbl=document.getElementById('ssWideTbl'); if(!tbl){ ssToast('⚠️ 표가 없습니다.'); return; }
    var f=(document.getElementById('ssDateFrom')||{}).value||'', t=(document.getElementById('ssDateTo')||{}).value||'';
    var dlab=(f&&f===t)?f:(f+' ~ '+t);
    var clone=tbl.cloneNode(true);
    [].slice.call(clone.querySelectorAll('tr')).forEach(function(tr){ if(tr.style && tr.style.display==='none' && tr.parentNode) tr.parentNode.removeChild(tr); });
    [].slice.call(clone.querySelectorAll('.bx,.caret,.zcaret,.delx')).forEach(function(e){ if(e.parentNode) e.parentNode.removeChild(e); });
    [].slice.call(clone.querySelectorAll('[contenteditable]')).forEach(function(e){ e.removeAttribute('contenteditable'); });
    [].slice.call(clone.querySelectorAll('td,th')).forEach(function(c){ c.style.position='static'; });   // sticky 해제(캡처 정확)
    clone.style.width='auto';
    var wrap=document.createElement('div');
    wrap.style.cssText='position:fixed;left:-100000px;top:0;background:#fff;padding:14px;font-family:\"Malgun Gothic\",sans-serif;';
    wrap.innerHTML='<div style="font-size:18px;font-weight:700;margin-bottom:4px">출고현황표</div>'
      +'<div style="font-size:12px;color:#555;margin-bottom:8px">출고일자 : '+dlab+'</div>';
    wrap.appendChild(clone);
    document.body.appendChild(wrap);
    ssToast('📄 PDF 생성 중…');
    window.html2canvas(wrap, {scale:2, backgroundColor:'#ffffff'}).then(function(canvas){
      if(wrap.parentNode) wrap.parentNode.removeChild(wrap);
      var pdf=new jsPDF('l','mm','a4');
      var mg=8, pw=pdf.internal.pageSize.getWidth()-mg*2, ph=pdf.internal.pageSize.getHeight()-mg*2;
      var iw=pw, ih=canvas.height*iw/canvas.width;
      if(ih<=ph){
        pdf.addImage(canvas.toDataURL('image/png'),'PNG',mg,mg,iw,ih);
      } else {
        // 세로로 페이지 분할
        var sliceHpx=Math.floor(canvas.width*ph/pw), y=0, page=0;
        while(y<canvas.height){
          var hpx=Math.min(sliceHpx, canvas.height-y);
          var c2=document.createElement('canvas'); c2.width=canvas.width; c2.height=hpx;
          c2.getContext('2d').drawImage(canvas,0,y,canvas.width,hpx,0,0,canvas.width,hpx);
          if(page>0) pdf.addPage();
          pdf.addImage(c2.toDataURL('image/png'),'PNG',mg,mg,iw,hpx*iw/canvas.width);
          y+=hpx; page++;
        }
      }
      pdf.save('출고현황표_'+(f||'')+((t&&t!==f)?'~'+t:'')+'.pdf');
      ssToast('📄 PDF 저장 완료 (출고일자 '+dlab+')');
    }).catch(function(e){ if(wrap.parentNode) wrap.parentNode.removeChild(wrap); ssToast('⚠️ PDF 생성 오류: '+e.message); });
  }

  // ── 날짜 유틸 / 당일 기준
  function ssPad(n){ return (n<10?'0':'')+n; }
  function ssFmtDate(v){
    if(v instanceof Date && !isNaN(v)) return v.getFullYear()+'-'+ssPad(v.getMonth()+1)+'-'+ssPad(v.getDate());
    var s=''+(v==null?'':v); var m=s.match(/(\d{4})[-.\/](\d{1,2})[-.\/](\d{1,2})/);
    return m ? (m[1]+'-'+ssPad(+m[2])+'-'+ssPad(+m[3])) : '';
  }
  var SS_TODAY=(function(){ var d=new Date(); return d.getFullYear()+'-'+ssPad(d.getMonth()+1)+'-'+ssPad(d.getDate()); })();
  function ssAllDates(){
    var f={}; SHIP_DATA.forEach(function(r){ var d=r.date||SS_TODAY; f[d]=(f[d]||0)+1; });
    return Object.keys(f).sort().map(function(d){ return {d:d, n:f[d]}; });
  }
  // 날짜 입력 클릭 시 달력 팝업 즉시 열기 (지원 브라우저)
  function ssOpenCal(el){ try{ if(el && el.showPicker) el.showPicker(); }catch(e){} }
  // 적용 시 KPI 깜빡임(갱신 알림)
  function ssFlash(){ var s=document.querySelector('#panel-shipstatus .tb-stats'); if(s){ s.classList.remove('ss-flash'); void s.offsetWidth; s.classList.add('ss-flash'); } }
  function ssSetVal(id,v){ var e=document.getElementById(id); if(e) e.value=v; }
  function ssToday(){ ssSetVal('ssDateFrom',SS_TODAY); ssSetVal('ssDateTo',SS_TODAY); ssLoadShipoutFromDB(); }
  function ssThisMonth(){
    var d=new Date(), y=d.getFullYear(), m=d.getMonth(), last=new Date(y,m+1,0).getDate();
    ssSetVal('ssDateFrom', y+'-'+ssPad(m+1)+'-01');
    ssSetVal('ssDateTo',   y+'-'+ssPad(m+1)+'-'+ssPad(last));
    ssLoadShipoutFromDB();   // 당월=기간 합산 조회
  }

  // ── 출고현황표 DB 조회: 선택한 출고일자(단일)의 활성배치를 읽어와 표시. 없으면 빈 화면 ──
  //    DB행 → 화면 SHIP_DATA 매핑은 ssExtractRows(konet 포맷)와 동일:
  //      · 출고장(zone) = 물류센터명(DC_NM) + 입고장(INWH)  예) "평택물류센터1"
  //      · 사업장(biz)  = 사업장명 [사업장코드]
  // ── 대시보드1↔2 출고일자 조건 동기화 (localStorage 'logiShipDate' 공유 + storage 이벤트) ──
  var _ssDateSyncing=false;
  function ssSaveSharedDate(){
    try{ localStorage.setItem('logiShipDate', JSON.stringify({
      from:(document.getElementById('ssDateFrom')||{}).value||'',
      to:(document.getElementById('ssDateTo')||{}).value||'' })); }catch(e){}
  }
  function ssApplySharedDate(){   // 저장된 공유 날짜 적용(있으면 true)
    try{ var d=JSON.parse(localStorage.getItem('logiShipDate')||'null'); if(!d) return false;
      if(d.from!=null) ssSetVal('ssDateFrom', d.from); if(d.to!=null) ssSetVal('ssDateTo', d.to); return true;
    }catch(e){ return false; }
  }
  window.addEventListener('storage', function(e){   // 대시보드2에서 날짜 바꾸면 따라가기
    if(e.key!=='logiShipDate') return;
    try{ var d=JSON.parse(e.newValue||'null'); if(!d) return;
      var f=document.getElementById('ssDateFrom'), t=document.getElementById('ssDateTo'); if(!f||!t) return;
      if(f.value===(d.from||'') && t.value===(d.to||'')) return;
      _ssDateSyncing=true; f.value=d.from||''; t.value=d.to||''; ssLoadShipoutFromDB(); _ssDateSyncing=false;
    }catch(_){}
  });
  function ssLoadShipoutFromDB(){ if(!_ssDateSyncing) ssSaveSharedDate(); ssLoadBiziMst(function(){ _ssLoadShipoutInner(); }); }   // 조회 직전 분류표 최신화 + 날짜 공유 저장
  function _ssLoadShipoutInner(){
    var f=(document.getElementById('ssDateFrom')||{}).value||'';
    var t=(document.getElementById('ssDateTo')||{}).value||'';
    // 단일일자=단일조회 / 기간(시작≠종료)=기간 전체 합산 조회 (둘 다 있어야 조회)
    if(!f || !t){ ssRender(); if(typeof konetAsqSetDash1==='function') konetAsqSetDash1({hide:true}); return; }
    var _single=(f===t);
    fetch('${pageContext.request.contextPath}/shipout/selectShipoutMst.do', {
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
      credentials:'same-origin',
      body: _single ? ('shpoutDt='+encodeURIComponent(f))
                    : ('shpoutDtFrom='+encodeURIComponent(f)+'&shpoutDtTo='+encodeURIComponent(t))
    })
    .then(function(res){ return res.text().then(function(txt){ return {status:res.status, ok:res.ok, txt:txt}; }); })
    .then(function(r){
      // HTTP 오류(404=엔드포인트 미배포 / 500=서버오류 등) — 상태·본문을 그대로 노출
      if(!r.ok){
        window.ssSrcInfo='⚠️ DB 조회 HTTP '+r.status; SHIP_DATA=[]; ssRender();
        if(window.ssToast) ssToast('⚠️ 출고 조회 실패 (HTTP '+r.status+')<br><span style="font-size:11px">'+(r.txt||'').replace(/[<>]/g,'').slice(0,300)+'</span>');
        return;
      }
      // 본문이 JSON 이 아니면(로그인 HTML 리다이렉트 등) 파싱 실패 — 본문 노출
      var j; try{ j=JSON.parse(r.txt); }catch(e){
        window.ssSrcInfo='⚠️ 응답형식 오류'; SHIP_DATA=[]; ssRender();
        if(window.ssToast) ssToast('⚠️ 조회 응답이 JSON이 아닙니다<br><span style="font-size:11px">'+(r.txt||'').replace(/[<>]/g,'').slice(0,300)+'</span>');
        return;
      }
      var rows=(j&&j.data)||[];
      SHIP_DATA = rows.map(function(o){
        var dcNm=(''+(o.dcNm||'')).trim(), inwh=(''+(o.inwh||'')).trim();
        var zone = dcNm ? (dcNm+inwh) : (''+(o.zone||'')).trim();
        var bizNm=(''+(o.bizNm||'')).trim(), bizCd=(''+(o.bizCd||'')).trim();
        var bizLbl = bizCd ? (bizNm ? (bizNm+' ['+bizCd+']') : ('['+bizCd+']')) : bizNm;
        var _dlv=(''+(o.dlvDt||'')).trim(); if(/^\d{8}$/.test(_dlv)) _dlv=_dlv.slice(0,4)+'-'+_dlv.slice(4,6)+'-'+_dlv.slice(6,8);
        var _sd=(''+(o.shpoutDt||'')).trim(); if(/^\d{8}$/.test(_sd)) _sd=_sd.slice(0,4)+'-'+_sd.slice(4,6)+'-'+_sd.slice(6,8);
        return { code:(''+(o.itemCd||'')).trim(), item:(''+(o.itemNm||'')).trim(),
                 biz:bizLbl, bizCode:bizCd, inb:inwh, zone:zone, dcCd:(''+(o.dcCd||'')).trim(),
                 qty:(+o.curQty||0), dlvDt:_dlv, date:(_sd||f) };   // 실제 출고일자(기간 합산 시 범위 필터·집계용) / dcCd=오산센터 그룹 판정용
      });
      window.ssSrcUp   = rows.length>0;
      var _lab=_single?f:(f+'~'+t+' 합산');
      window.ssSrcInfo = rows.length>0 ? ('🗄️ DB 조회 '+_lab+' · '+rows.length+'건') : ('🗄️ DB '+_lab+' — 데이터 없음');
      ssRender();
      if(_single) ssLoadAsqBar();   // 직전배치 대조 알림바는 단일일자만
      else if(typeof konetAsqSetDash1==='function') konetAsqSetDash1({hide:true});
    })
    .catch(function(e){ window.ssSrcInfo='⚠️ DB 통신오류'; SHIP_DATA=[]; ssRender(); if(typeof konetAsqSetDash1==='function') konetAsqSetDash1({hide:true}); if(window.ssToast) ssToast('⚠️ 출고 조회 통신오류: '+e.message); });
  }

  // ── 하단 알림 바(대시보드1 자체) — 현재 SHIP_DATA vs 직전 배치 대조 요약 ──
  function _ssAsqEsc(s){ return (''+(s==null?'':s)).replace(/[&<>"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c];}); }
  function _ssAsqNormCur(r){   // 현재 화면 데이터(SHIP_DATA) 정규화
    return { zone:(''+(r.zone||'')).trim(), biz:(''+(r.bizCode||'')).trim(),
             key:((''+(r.code||'')).trim()||('NM:'+(''+(r.item||'')).trim())), qty:+r.qty||0 };
  }
  function _ssAsqNormPrev(o){   // 직전 배치 DB행 정규화(현재와 동일 키 규칙: 사업장코드+품목)
    var dc=(''+(o.dcNm||'')).trim(), iw=(''+(o.inwh||'')).trim(); var zn=dc?(dc+iw):(''+(o.zone||'')).trim();
    var c=(''+(o.itemCd||'')).trim();
    return { zone:zn, biz:(''+(o.bizCd||'')).trim(), key:(c||('NM:'+(''+(o.itemNm||'')).trim())), qty:+o.curQty||0 };
  }
  function _ssAsqGroup(list){   // zone → { (사업장|품목) : 수량합 }
    var z={};
    (list||[]).forEach(function(n){ if(n.qty<=0) return; var kk=n.biz+'|'+n.key; (z[n.zone]=z[n.zone]||{}); z[n.zone][kk]=(z[n.zone][kk]||0)+n.qty; });
    return z;
  }
  function ssBuildAsqSummary(curNorm, prevNorm){
    var cur=_ssAsqGroup(curNorm), prev=_ssAsqGroup(prevNorm);
    var zones=Object.keys(cur); Object.keys(prev).forEach(function(zn){ if(zones.indexOf(zn)<0) zones.push(zn); });
    zones.sort(function(a,b){ return (''+a).localeCompare(''+b,'ko'); });
    var items=[];
    zones.forEach(function(zn){
      var p=prev[zn];
      // ★ 직전 배치 없는 출고장(최초 업로드) = 신규/삭제 판정 보류 (대시보드1 line 1299와 동일).
      //   없으면 최초 배치 전량이 '신규'로 오탐됨 (예: 김해물류센터1 단일 배치 → 신규 37).
      if(!p) return;
      var c=cur[zn]||{}, nw=0,up=0,dn=0,dl=0;
      Object.keys(c).forEach(function(k){ if(!(k in p)) nw++; else if(c[k]!==p[k]){ (c[k]>p[k]?up++:dn++); } });
      Object.keys(p).forEach(function(k){ if(!(k in c)) dl++; });
      if(nw+up+dn+dl===0) return;
      var parts=[];
      if(nw) parts.push('<span class="tk-new">신규 '+nw+'</span>');
      if(up) parts.push('<span class="tk-up">▲증가 '+up+'</span>');
      if(dn) parts.push('<span class="tk-dn">▼감소 '+dn+'</span>');
      if(dl) parts.push('<span class="tk-del">삭제 '+dl+'</span>');
      items.push('<span class="tk-item" data-zone="'+_ssAsqEsc(zn)+'"><span class="z">'+_ssAsqEsc(zn)+'</span> '+parts.join(' · ')+'</span>');
    });
    if(!items.length) items.push('<span class="tk-item">✓ 직전 업로드 대비 변경 없음</span>');
    return { hide:false, html:'<span class="tk-spacer"></span>'+items.join('<span class="tk-sep">|</span>') };
  }
  // 현재+직전 배치를 모두 새로 조회해 요약 생성 → 셸 바로 전달 (그리드 SHIP_DATA는 건드리지 않음 → 리프레시에도 안전)
  function ssLoadAsqBar(){
    if(typeof konetAsqSetDash1!=='function') return;   // 셸 바 없으면(단독 접근) 스킵
    var f=(document.getElementById('ssDateFrom')||{}).value||'';
    var t=(document.getElementById('ssDateTo')||{}).value||'';
    if(!(f && f===t)){ konetAsqSetDash1({hide:true}); return; }   // 기간모드 제외
    var CTX='${pageContext.request.contextPath}';
    var opt={ method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin', body:'shpoutDt='+encodeURIComponent(f) };
    Promise.all([
      fetch(CTX+'/shipout/selectShipoutMst.do', opt).then(function(r){ return r.ok?r.text():''; }),
      fetch(CTX+'/shipout/selectShipoutPrev.do', opt).then(function(r){ return r.ok?r.text():''; })
    ]).then(function(txts){
      function pj(x){ try{ var j=JSON.parse(x); return (j&&j.data)||[]; }catch(e){ return []; } }
      // 현재·직전 모두 DB 원본행 → 동일 정규화(_ssAsqNormPrev) 적용
      konetAsqSetDash1(ssBuildAsqSummary(pj(txts[0]).map(_ssAsqNormPrev), pj(txts[1]).map(_ssAsqNormPrev)));
    }).catch(function(){ konetAsqSetDash1({hide:true}); });
  }

  // 초기 렌더 (AJAX 주입/직접 접근 모두 대응) — 내장 데이터는 금일자로 간주
  function ssInit(){
    if(!document.getElementById('ssWideTbl')) return;
    if(!window.ssSrcInfo){ window.ssSrcInfo='내장 샘플 데이터 (당일 기준)'; window.ssSrcUp=false; }
    SHIP_DATA.forEach(function(r){ if(!r.date) r.date=SS_TODAY; });
    var f=document.getElementById('ssDateFrom'), t=document.getElementById('ssDateTo');
    // 진입(로그인) 시엔 항상 당일로 시작 — 이전 날짜 기억 안 함. (두 대시보드 동시 사용 중엔 아래 storage 이벤트로 실시간 동기화)
    if(f) f.value=SS_TODAY;
    if(t) t.value=SS_TODAY;
    ssLoadShipoutFromDB();   // 진입 시 = 당일 → DB에서 조회
    // 기본 화면 = 대시보드2 → iframe 자동 로드(한 번만). 직접/AJAX 로드 모두 커버
    var _if2=document.getElementById('if-shipstatus2');
    if(_if2){ var _c2=_if2.getAttribute('src')||''; if(!_c2 || _c2==='about:blank'){ _if2.src='${pageContext.request.contextPath}/admin/logistics_demo1.do'; } _if2.setAttribute('data-loaded','1'); }
  }
  /* ══════════════════════════════════════════════════════════════════════════
     매출(판매) 확정내역 업로드 — 출고장 제공 엑셀 → TBL_SALES_MST
      ★엑셀은 '출고장 기준'으로 쓰여 있어 우리 기준으로 뒤집어 담는다
          엑셀 '입고량'=우리 출고량 / '단가'=우리 판매단가 / '매입금액'=우리 매출액 / '입고일자'=우리 출고일자
      · 출고장(평택 등)은 엑셀 안에 없고 파일명에만 있다 → 파일명에서 뽑아 화면에서 확인·수정
      · 납품일자는 엑셀 안에 있으므로 엑셀 값을 쓴다(파일명 날짜는 참고용)
      · 파일 1개 = 1배치(납품일자+출고장). 재업로드 시 서버가 기존 배치 이력마감 후 신규 적재
     ══════════════════════════════════════════════════════════════════════════ */
  var _slsFiles=[];   // [{name, dcNm, rows:[...], err}]
  var _slsDone={};    // 이미 반영된 파일명 → {uploadDttm, dcNm}

  /* ══════════════════════════════════════════════════════════════════════════
     출고장(물류센터) 코드 ↔ 지역명 — 이 화면들의 단일 원천 (2026-07-22 통합)
       근거 = TBL_SHIPOUT_MST 실데이터의 DC_CD ↔ DC_NM
       거래처(TBL_VENDOR_MST) 대응 = E100:00273 E200:00275 E300:00274 E400:00276
                                     E500:00272 E600:00277 E700:00278

     ★센터가 추가·변경되면 아래 KONET_DC 한 곳만 고치면 된다.
       (종전에는 이름→코드 / 코드→이름 두 표와 정규화 로직이 따로 있어,
        한쪽만 고치면 조용히 어긋났다)
     ※ 대시보드·매출마감의 '오산센터 묶음'(CLOSE_DCGROUP / SS_DCGROUP)은
       성격이 다른 표(물류 동선용 그룹)이므로 여기와 합치지 않는다.
     ══════════════════════════════════════════════════════════════════════════ */
  var KONET_DC = { E100:'용인', E200:'왜관', E300:'김해', E400:'광주', E500:'평택', E600:'제주', E700:'오산' };
  var KONET_DC_R = (function(){ var r={}; for(var c in KONET_DC){ r[KONET_DC[c]]=c; } return r; })();   // 지역명→코드 (자동 생성)

  // 표기 통일 : '평택물류센터'·'평택 1'·'평택출고장' → '평택'
  //   두 표가 서로 다르게 적는다 — 정산서는 파일명 유래 '평택', 발주현황표는 '평택물류센터'
  function konetDcShort(s){
    var v=(''+(s==null?'':s)).replace(/\s+/g,'');
    return v.replace(/\d+$/,'').replace(/(물류)?센터$/,'').replace(/출고장$/,'').replace(/\d+$/,'');
  }
  // 이름 → 코드. ①정규화 후 정확 매칭 우선 → ②실패 시 LIKE(지역명 포함) 매칭
  //   파일명이 규칙에서 벗어나(예: 날짜 누락 '2026.07._광주.xlsx') 출고장 칸에 통째로 들어와도
  //   그 안에 지역명(광주 등)이 있으면 해당 센터코드로 잡는다.
  function konetDcCd(nm){
    var hit=KONET_DC_R[konetDcShort(nm)];
    if(hit) return hit;                                              // ① 정확 매칭
    var v=(''+(nm==null?'':nm)).replace(/\s+/g,'');
    for(var region in KONET_DC_R){ if(region && v.indexOf(region)>=0) return KONET_DC_R[region]; }  // ② LIKE
    return '';
  }
  function konetDcNmOf(r){                                                     // 행 → 지역명 (DC_CD 우선)
    var cd=(''+((r&&r.dcCd)||'')).trim().toUpperCase();
    return KONET_DC[cd] || konetDcShort(r&&r.dcNm);
  }

  // 아래 3개는 기존 호출부 유지를 위한 얇은 별칭 — 실제 규칙은 위 4개 함수에만 있다
  function slsDcCd(nm){ return konetDcCd(nm); }     // 정산 엑셀 저장 시 DC_CD 채우기
  function _ohDc(s){ return konetDcShort(s); }      // 이름만 정규화
  function _ohDcOf(r){ return konetDcNmOf(r); }     // 대사 출고장키
  // 지역명 → 대시보드 물류센터 묶음 라벨 (매출마감 CLOSE_DCGROUP 재사용). 매출내역 4탭 공통(2026-07-22)
  function _ohDcGrp(dc){ return CLOSE_DCGROUP[KONET_DC_R[dc]||''] || dc; }

  /* 출고장 다중선택 드롭다운 — 데시보드1(D2_DCSEL/.dc-pop)과 같은 방식(2026-07-22).
     자유 입력이면 '평택물류센터'처럼 잘못 적어 0건이 나와도 이유를 모른다.
     1단 = 대표출고장(묶음) / 2단 = 개별 출고장. 둘 다 체크 가능하고, 아무것도 안 고르면 전체.
     ★목록은 KONET_DC 가 아니라 '조회된 자료에 실제로 있는 출고장'으로 만든다 —
       없는 곳을 고르면 0건이 나와 혼란스럽기 때문(대시보드도 dcAll 로 같은 방식). */
  var _ohDcSel={};   // { '오산센터':1, '평택':1 } — 비어 있으면 전체
  function ohDcOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('ohDcPop'); if(p) p.classList.toggle('open'); }
  function ohDcToggle(k){ if(_ohDcSel[k]) delete _ohDcSel[k]; else _ohDcSel[k]=1; ohDcApply(); }
  function ohDcAll(){ _ohDcSel={}; ohDcApply(); }
  /* 선택을 화면에 반영 — 서버 재조회 없이 즉시. 원본(_ohSalesAll/_ohShipAll)은 그대로 두고
     걸러낸 결과만 _ohSales/_ohShip 에 담는다(집계 함수들이 이 둘을 본다). */
  function ohDcApply(){
    _ohSales=(_ohSalesAll||[]).filter(function(r){ return _ohDcHit(_ohDcOf(r)); });
    _ohShip =(_ohShipAll ||[]).filter(function(r){ return _ohDcHit(_ohDcOf(r)); });
    ohDcSync(); ohRender();
  }
  document.addEventListener('click', function(e){
    var w=document.getElementById('ohDcWrap'), p=document.getElementById('ohDcPop');
    if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
  });
  // 조회 자료에서 (묶음 → 개별) 목록을 뽑아 드롭다운·라벨을 다시 그린다
  function ohDcSync(){
    var pop=document.getElementById('ohDcPop'), lbl=document.getElementById('ohDcLbl');
    if(!pop) return;
    var grp={}, ord=[];
    // ★목록은 '선택 전 원본'으로 만든다 — 걸러진 결과로 만들면 한 곳을 고른 순간 나머지가 사라져 되돌릴 수 없다
    (_ohSalesAll||[]).concat(_ohShipAll||[]).forEach(function(r){
      var dc=_ohDcOf(r); if(!dc) return;
      var g=_ohDcGrp(dc);
      if(!grp[g]){ grp[g]={}; ord.push(g); }
      grp[g][dc]=1;
    });
    ord.sort(function(a,b){ return a.localeCompare(b,'ko'); });
    // 사라진 선택은 정리 (기간을 바꿔 그 출고장이 없어졌을 때)
    var live={}; ord.forEach(function(g){ live[g]=1; Object.keys(grp[g]).forEach(function(k){ live[k]=1; }); });
    Object.keys(_ohDcSel).forEach(function(k){ if(!live[k]) delete _ohDcSel[k]; });
    var n=Object.keys(_ohDcSel).length;
    if(lbl) lbl.textContent = n===0 ? '전체' : (n===1 ? Object.keys(_ohDcSel)[0] : n+'곳 선택');
    var h='<label class="all'+(n===0?' on':'')+'"><input type="checkbox"'+(n===0?' checked':'')
        + ' onchange="ohDcAll()"><span>전체 ('+ord.length+'개 물류센터)</span></label>';
    ord.forEach(function(g){
      var kids=Object.keys(grp[g]).sort(function(a,b){ return a.localeCompare(b,'ko'); });
      var on=!!_ohDcSel[g];
      h+='<label class="'+(on?'on':'')+'"><input type="checkbox"'+(on?' checked':'')
       + ' data-k="'+_cesc(g)+'" onchange="ohDcToggle(this.getAttribute(\'data-k\'))">'
       + '<span>🗂️ '+_cesc(g)+(kids.length>1?' <span style="color:#9aa7b3">('+kids.length+'곳)</span>':'')+'</span></label>';
      if(kids.length<2) return;                       // 혼자면 하위를 또 보여줄 필요 없다
      kids.forEach(function(k){
        var kon=!!_ohDcSel[k];
        h+='<label class="kid'+(kon?' on':'')+'"><input type="checkbox"'+(kon?' checked':'')
         + ' data-k="'+_cesc(k)+'" onchange="ohDcToggle(this.getAttribute(\'data-k\'))"><span>'+_cesc(k)+'</span></label>';
      });
    });
    pop.innerHTML=h;
  }
  /* ══ 출고장 표시이름 + 정정 (2026-07-27) ═══════════════════════════════════════════
       표시이름 : 7곳으로 인식되는 이름은 통일키(용인·평택…), 인식 안 되는 이름은 <원표기 그대로>.
         konetDcShort 가 끝 숫자를 떼기 때문에('평택물류센터1'→'평택') 잘못 저장된 이름은
         DB 값이 '15.24.51' 인데도 화면엔 '15.24.' 로 잘려 보였다(사용자 지적). 정정하려면 원표기가 보여야 한다.
       정정 : 저장된 DC_NM 을 7곳 중 하나로 바꾼다 → /sales/renameSalesDc.do
         ★UPDATE 대상은 정규화된 라벨이 아니라 <원표기(raw)> 다 — 라벨로 찾으면 한 건도 못 고친다.
         원표기가 여러 개 섞인 줄은 무엇을 고칠지 모호해 버튼을 내지 않는다(각 원표기가 각자 줄로 나올 때만).
         이미 7곳으로 인식되는 줄에도 내지 않는다(오조작 방지).                                */
  function _ohDcLabel(g){
    if(KONET_DC_R[g.dc]) return g.dc;                     // 용인·왜관·김해·광주·평택·제주·오산
    var raws=Object.keys(g.raw||{});
    return raws.length ? raws.join(' / ') : g.label;
  }
  function ohDcFixBtn(g){
    if(KONET_DC_R[g.dc]) return '';                       // 정상 인식되는 출고장은 버튼 없음
    var raws=Object.keys(g.raw||{});
    if(raws.length!==1) return '';                        // 원표기가 여러 개면 대상이 모호
    return ' <span onclick="event.stopPropagation();ohDcFix(\''+encodeURIComponent(raws[0])+'\')"'
      +' title="저장된 출고장 이름이 잘못됐습니다 — 눌러서 바로잡기"'
      +' style="cursor:pointer;color:#c0392b;font-weight:700;font-size:11.5px;border:1px solid #f0c9c2;border-radius:4px;padding:1px 6px;background:#fff;margin-left:6px">✏️ 출고장 고치기</span>';
  }
  function ohDcFix(rawEnc){
    var raw=decodeURIComponent(rawEnc);
    var f=(document.getElementById('slsFrom')||{}).value||'', t=(document.getElementById('slsTo')||{}).value||'';
    var names=[]; for(var cd in KONET_DC){ if(KONET_DC.hasOwnProperty(cd)) names.push(KONET_DC[cd]); }
    var sel='<select id="ohDcFixSel" style="height:34px;font-size:15px;font-weight:700;color:#137a6c;border:1px solid #cdd7dd;border-radius:6px;padding:0 10px">'
      +'<option value="">선택하세요</option>'
      +names.map(function(n){ return '<option value="'+_cesc(n)+'">'+_cesc(n)+'</option>'; }).join('')+'</select>';
    ssConfirm('저장된 <b>출고장 이름</b>을 바로잡습니다.<br><br>'
      +'현재 <b style="color:#c0392b;word-break:break-all">'+_cesc(raw)+'</b> &nbsp;→&nbsp; 바꿀 출고장 '+sel
      +'<div style="margin-top:12px;font-size:12px;color:#6b7a89;line-height:1.7">'
      +'대상 = 조회 기간 <b>'+_cesc(f||'전체')+' ~ '+_cesc(t||'전체')+'</b> 의 이 출고장 자료 전부(활성분 + 이력분)<br>'
      +'행수·수량·금액은 그대로이고 <b>출고장 이름·센터코드만</b> 바뀝니다.<br>'
      +'<span style="color:#a85700">같은 납품일자에 그 출고장 자료가 이미 있으면 정정하지 않습니다</span>(매출이 두 번 잡히므로).</div>',
      function(){
        var v=((document.getElementById('ohDcFixSel')||{}).value||'').trim();
        if(!v){ ssToast('⚠️ 바꿀 출고장을 고르세요.'); return; }
        fetch('${pageContext.request.contextPath}/sales/renameSalesDc.do', {
          method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin',
          body:'dcNm='+encodeURIComponent(raw)+'&newDcNm='+encodeURIComponent(v)+'&newDcCd='+encodeURIComponent(konetDcCd(v)||'')
              +'&dlvDtFrom='+encodeURIComponent(f)+'&dlvDtTo='+encodeURIComponent(t)
        })
        .then(function(r){ return r.json(); })
        .then(function(j){
          if(j && j.ok){ ssToast('✏️ 출고장 정정 — <b>'+_cesc(raw)+'</b> → <b>'+_cesc(v)+'</b> ('+(+j.rows||0).toLocaleString()+'행)'); ohQuery(); return; }
          if(j && j.conflict){ ssToast('⚠️ 정정하지 않았습니다 — 같은 납품일자에 <b>'+_cesc(v)+'</b> 자료가 이미 있습니다.<br><span style="font-size:11px">이 경우는 이름 정정이 아니라 잘못 올린 자료를 지워야 합니다.</span>'); return; }
          ssToast('⚠️ 정정 실패: '+_cesc((j&&j.msg)||'알 수 없는 오류'));
        })
        .catch(function(){ ssToast('⚠️ 정정 통신오류 — 잠시 후 다시 시도하세요.'); });
      }, {title:'✏️ 출고장 정정', yes:'정정'});
  }

  // 이 행이 현재 선택에 걸리는가 — 묶음명·개별명 어느 쪽으로 체크했든 통한다
  function _ohDcHit(dc){
    if(!Object.keys(_ohDcSel).length) return true;    // 선택 없음 = 전체
    return !!(_ohDcSel[dc] || _ohDcSel[_ohDcGrp(dc)]);
  }

  // '2026.07.11_평택.xlsx' / '2026.07.11 오산.xlsx' → 출고장명
  function slsParseName(fname){
    var base=(''+fname).replace(/\.[^.]+$/,'');
    var m=base.match(/(\d{4})[.\-\/](\d{1,2})[.\-\/](\d{1,2})[\s_\-]*(.*)$/);
    if(m) return { dt:m[1]+'-'+ssPad(+m[2])+'-'+ssPad(+m[3]), dc:(m[4]||'').trim() };
    // 날짜가 불완전한 파일명(일 누락 등)도 앞 날짜류 접두어를 걷어내고 지역명만 취한다.
    //   예: '2026.07._광주' → 날짜 인식 실패 → dc='광주' (통째로 남지 않게)
    var d=base.replace(/^\s*\d{4}[.\-\/]\d{1,2}(?:[.\-\/]\d{0,2})?[\s._\-]*/,'').trim();
    return { dt:'', dc:(d||base.trim()) };
  }
  function slsStr(v){ return (''+(v==null?'':v)).trim(); }
  function slsNum(v){
    if(v==null||v==='') return null;
    var s=(''+v).replace(/,/g,'').trim(); if(s==='') return null;
    var n=Number(s); return isNaN(n)?null:n;
  }
  // 엑셀 시트(2차원) → 우리 관점 행 목록
  function slsBuildRows(aoa){
    function eq(arr,name){ for(var k=0;k<arr.length;k++){ if(slsStr(arr[k])===name) return k; } return -1; }
    var h=-1, hr=[];
    for(var i=0;i<Math.min(aoa.length,10);i++){
      var rr=(aoa[i]||[]).map(slsStr);
      if(eq(rr,'발주번호')>=0 && eq(rr,'품목코드')>=0){ h=i; hr=rr; break; }
    }
    if(h<0) return { rows:[], err:'헤더(발주번호·품목코드)를 찾지 못했습니다.' };
    var C={ rowNo:eq(hr,'No'), ordNo:eq(hr,'발주번호'), ordItemNo:eq(hr,'발주항번'),
            itemCd:eq(hr,'품목코드'), itemNm:eq(hr,'품목명'), spec:eq(hr,'규격'), unit:eq(hr,'단위'),
            ordQty:eq(hr,'발주량'), settleQty:eq(hr,'정산수량'), settleAmt:eq(hr,'정산금액'),
            dlvDt:eq(hr,'납품일자'), outDt:eq(hr,'입고일자'), outQty:eq(hr,'입고량'),
            salePrice:eq(hr,'단가'), saleAmt:eq(hr,'매입금액'), dlvType:eq(hr,'납품유형'),
            taxGb:eq(hr,'면과세 구분') };
    if(C.taxGb<0) C.taxGb=eq(hr,'면과세구분');
    var g=function(row,i){ return i>=0 ? row[i] : ''; };
    var out=[], lastOrd='';
    /* ★오류 행은 아예 담지 않는다(2026-07-26 사용자 확정) — 담아서 경고만 하던 것을 '저장 안 함'으로 바꿨다.
         사유는 화면에 길게 늘어놓지 않고 확인창에 '오류 N행 제외 (사유 개수)' 한 줄로만 알린다.
         · 담기지 않으므로 파일 목록의 행수·출고량·매출액 = 실제로 저장될 값이 된다(어긋날 여지 없음). */
    var nBad=0, badWhy={};
    var _mark=function(w){ nBad++; badWhy[w]=(badWhy[w]||0)+1; };
    for(var r=h+1;r<aoa.length;r++){
      var row=aoa[r]||[];
      var cd=slsStr(g(row,C.itemCd));
      if(!cd) continue;                       // 품목코드 없는 행 = 합계행/빈행 → 제외(오류 아님)
      var ono=slsStr(g(row,C.ordNo));
      if(ono) lastOrd=ono; else ono=lastOrd;  // 발주번호 병합셀(B3:B63) → 위 값 승계
      var _dlv=ssFmtDate(g(row,C.dlvDt));
      var _rq=slsStr(g(row,C.outQty)), _ra=slsStr(g(row,C.saleAmt));
      var _q=slsNum(g(row,C.outQty)), _p=slsNum(g(row,C.salePrice)), _a=slsNum(g(row,C.saleAmt));
      if(!_dlv){                    _mark('납품일자'); continue; }   // 배치키(납품일자+출고장)가 안 섬
      if(!ono){                     _mark('발주번호'); continue; }   // 위에도 값이 없어 승계 실패
      if(_rq==='' || _q===null){    _mark('입고량');   continue; }
      if(_ra==='' || _a===null){    _mark('매입금액'); continue; }
      if(_p!==null && Math.abs(_a - _q*_p) > 1){ _mark('매입금액≠입고량×단가'); continue; }   // 원본 검산
      out.push({
        rowNo:slsNum(g(row,C.rowNo)), ordNo:ono, ordItemNo:slsStr(g(row,C.ordItemNo)),
        itemCd:cd, itemNm:slsStr(g(row,C.itemNm)), spec:slsStr(g(row,C.spec)), unit:slsStr(g(row,C.unit)),
        ordQty:slsNum(g(row,C.ordQty)), settleQty:slsNum(g(row,C.settleQty)), settleAmt:slsNum(g(row,C.settleAmt)),
        dlvDt:ssFmtDate(g(row,C.dlvDt)), outDt:ssFmtDate(g(row,C.outDt)),
        outQty:slsNum(g(row,C.outQty)), salePrice:slsNum(g(row,C.salePrice)), saleAmt:slsNum(g(row,C.saleAmt)),
        dlvType:slsStr(g(row,C.dlvType)), taxGb:slsStr(g(row,C.taxGb))
      });
    }
    // 한 행도 못 담았으면 이유를 err 로 — 목록 상태칸에 그대로 뜬다(문구는 종전처럼 한 줄)
    var e0 = out.length ? ''
           : (nBad ? ('모든 행에 오류가 있어 저장할 수 없습니다 ('+nBad.toLocaleString()+'행)')
                   : '품목코드가 있는 데이터행이 없습니다.');
    return { rows:out, err:e0, nBad:nBad, badWhy:badWhy };
  }
  // 오류 행 사유 요약 한 줄 — "매입금액 12 · 납품일자 3" (확인창·상태칸용, 목록으로 늘어놓지 않는다)
  function slsBadWhy(f){
    var w=(f&&f.badWhy)||{}, a=[];
    for(var k in w){ if(w.hasOwnProperty(k)) a.push({k:k, n:w[k]}); }
    a.sort(function(x,y){ return y.n-x.n; });
    return a.map(function(x){ return x.k+' '+x.n.toLocaleString(); }).join(' · ');
  }
  /* ★이 파일이 저장에서 빠지는 이유 — 없으면 ''. 목록 상태칸(slsRender)과 저장(slsSave)이 같은 판정을 쓰도록 한 곳에 둔다.
       여기 걸린 파일만 제외되고 나머지는 저장된다(2026-07-26 'A안' — 종전에는 하나만 걸려도 전체가 막혔다). */
  function slsSkipWhy(f){
    if(!f) return '';
    if(!f.rows.length)        return f.err || '저장할 행 없음';   // 오류 행은 이미 rows 에서 빠져 있다
    var _dc=(f.dcNm||'').trim();
    if(!_dc)                  return '출고장이 비어 있음';
    /* ★출고장을 물류센터로 알아보지 못한 파일도 저장하지 않는다 (2026-07-27 사용자 지시).
         종전에는 '미확인'이어도 DC_CD 를 빈값으로 두고 저장했다 → 그 자료는 출고장으로 묶이지 않아
         대사·출고장별 집계에서 통째로 빠지고, 파일명에서 잘못 딴 값(예: '09.49.30')이 그대로 남았다.
         형식오류와 같은 급으로 막고, 출고장 칸을 고치면 곧바로 저장 가능해진다(입력값으로 재판정). */
    if(!slsDcCd(_dc))         return '출고장 미확인 — 용인·왜관·김해·광주·평택·제주·오산 중 선택';
    return '';
  }
  // 이미 반영된 파일명 목록 (재업로드=기존배치 대체 임을 화면에 알림)
  function slsLoadDone(){
    fetch('${pageContext.request.contextPath}/sales/selectSalesSrcFiles.do', { method:'POST', credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(j){ _slsDone={}; ((j&&j.data)||[]).forEach(function(o){ _slsDone[o.srcFile]={uploadDttm:o.uploadDttm, dcNm:o.dcNm}; }); slsRender(); })
      .catch(function(){});
  }
  function slsUpload(input){
    var fs=input.files; if(!fs||!fs.length) return;
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); input.value=''; return; }
    var list=Array.prototype.slice.call(fs), done=0;
    var fin=function(){ if(++done===list.length){ slsRender(); slsSyncDates(); slsLoadDone(); slsUpOpen(); } };   // 고르면 확인·저장 팝업을 연다
    list.forEach(function(f){
      var rd=new FileReader();
      rd.onload=function(e){
        ssReadXlsx(e.target.result, function(wb){
          try{
            var ws=wb.Sheets[wb.SheetNames[0]];
            var aoa=ws?XLSX.utils.sheet_to_json(ws,{header:1,defval:''}):[];
            var b=slsBuildRows(aoa);
            _slsFiles=_slsFiles.filter(function(x){ return x.name!==f.name; });   // 같은 파일 다시 고르면 교체
            _slsFiles.push({ name:f.name, dcNm:slsParseName(f.name).dc, rows:b.rows, err:b.err, nBad:b.nBad, badWhy:b.badWhy });
          }catch(err){ _slsFiles.push({ name:f.name, dcNm:'', rows:[], err:err.message }); }
          fin();
        }, function(err){ _slsFiles.push({ name:f.name, dcNm:'', rows:[], err:err.message }); fin(); });
      };
      rd.readAsArrayBuffer(f);
    });
    input.value='';
  }
  function slsSetDc(i, v){ if(_slsFiles[i]) _slsFiles[i].dcNm=(''+v).trim(); }
  function slsDrop(i){ _slsFiles.splice(i,1); slsRender(); }
  function slsClear(){ _slsFiles=[]; slsRender(); slsUpClose(); }
  function slsDates(f){   // 파일 안 납품일자 distinct
    var s={}, o=[]; f.rows.forEach(function(r){ if(r.dlvDt && !s[r.dlvDt]){ s[r.dlvDt]=1; o.push(r.dlvDt); } }); return o.sort();
  }
  /* 파일 목록·미리보기·저장은 전부 팝업(ss-modal)으로 — 본 화면에는 안 깔린다(2026-07-22 요청).
     미리보기는 <details> 로 접어두어 필요할 때만 펼친다. */
  function _slsUpEnsure(){
    var ov=document.getElementById('slsUpOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='slsUpOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(1150px,90vw)">'
        +'<style>@keyframes slsProgFlow{0%{background-position:0 0}100%{background-position:34px 0}}'
        +'.sls-prog-indet{background-image:repeating-linear-gradient(45deg,rgba(255,255,255,.28) 0 9px,rgba(255,255,255,0) 9px 17px),linear-gradient(90deg,#17a589,#137a6c)!important;background-size:34px 34px,100% 100%!important;animation:slsProgFlow .7s linear infinite}</style>'
        +'<div class="mh"><h4>📥 정산 엑셀 저장</h4><button class="x" onclick="slsUpClose()">&times;</button></div>'
        +'<div class="mbar"><span id="slsUpSum"></span></div>'
        +'<div class="mbody" id="slsUpWrap"></div>'
        +'<div id="slsProg" style="display:none;padding:8px 16px 2px">'
        +'  <div style="display:flex;justify-content:space-between;font-size:12px;color:#5a6b7a;margin-bottom:5px">'
        +'    <span id="slsProgLab">저장 중…</span><span id="slsProgPct" style="font-weight:700;color:#137a6c"></span></div>'
        +'  <div style="height:11px;background:#e6ecf0;border-radius:6px;overflow:hidden">'
        +'    <div id="slsProgFill" style="height:100%;width:0%;background:linear-gradient(90deg,#17a589,#137a6c);border-radius:6px;transition:width .2s ease"></div>'
        +'  </div></div>'
        +'<div class="mfoot">'
        +'<button class="btn-line" style="margin-right:auto" onclick="document.getElementById(\'slsFile\').click()">📁 파일 추가</button>'
        +'<button class="btn-line" onclick="slsClear()">🧹 비우기</button>'
        +'<button class="btn-line" onclick="slsUpClose()">닫기</button>'
        +'<button class="btn-teal" id="slsSaveBtn" onclick="slsSave()">💾 저장</button>'
        +'</div></div>';
      document.body.appendChild(ov);
      // ※ 바깥 클릭으로는 안 닫는다(요청 2026-07-22) — 고른 파일이 실수로 날아가는 걸 막기 위함.
      //    닫으려면 ✕ / [닫기] 를 눌러야 한다.
    }
    return ov;
  }
  function slsUpOpen(){ _slsUpEnsure().classList.add('on'); slsRender(); }
  function slsUpClose(){ var ov=document.getElementById('slsUpOv'); if(ov) ov.classList.remove('on'); }
  // 본 화면 버튼: 대기 파일이 있을 때만 보인다 (닫아도 다시 열 수 있게)
  function _slsUpChip(){
    var c=document.getElementById('slsUpChip'); if(!c) return;
    if(!_slsFiles.length){ c.style.display='none'; return; }
    c.style.display=''; c.innerHTML='📄 대기 <b>'+_slsFiles.length+'</b>개 — 저장하기';
  }
  function slsRender(){
    _slsUpEnsure();
    var wrap=document.getElementById('slsUpWrap'), sum=document.getElementById('slsUpSum');
    _slsUpChip();
    if(!wrap) return;
    if(!_slsFiles.length){ sum.textContent=''; wrap.innerHTML='<div style="padding:24px;text-align:center;color:#9aa7b3">고른 파일이 없습니다. <b>📁 파일 추가</b> 로 정산 엑셀을 선택하세요.</div>'; return; }
    var tQ=0, tA=0, tR=0;
    _slsFiles.forEach(function(f){ f.rows.forEach(function(r){ tR++; tQ+=(+r.outQty||0); tA+=(+r.saleAmt||0); }); });
    var tB=_slsFiles.reduce(function(s,f){ return s+(+f.nBad||0); }, 0);       // 오류로 빠진 행(rows 에 이미 없음)
    sum.innerHTML='파일 <b>'+_slsFiles.length+'</b>개 · 행 <b>'+tR.toLocaleString()+'</b> · 출고량 <b>'+_cnum(tQ)+'</b> · 매출액 <b style="color:#137a6c">'+_cnum(tA)+'</b>'
      + (tB?(' · <span style="color:#c0392b">오류 <b>'+tB.toLocaleString()+'</b>행 제외</span>'):'');
    var h='<table class="logi-tb sls-ftb"><thead><tr><th>파일명</th><th>출고장</th><th>센터코드</th><th>납품일자</th>'
        + '<th style="text-align:right">행</th><th style="text-align:right">출고량</th><th style="text-align:right">매출액</th><th>상태</th><th></th></tr></thead><tbody>';
    _slsFiles.forEach(function(f,i){
      var q=0,a=0; f.rows.forEach(function(r){ q+=(+r.outQty||0); a+=(+r.saleAmt||0); });
      var ds=slsDates(f), dlab=ds.length?(ds[0]+(ds.length>1?(' 외 '+(ds.length-1)+'일'):'')):'<span style="color:#c0392b">없음</span>';
      // 저장에서 빠지는 파일은 이유를 한 줄로 — 나머지 파일은 그대로 저장된다(전체가 막히지 않음)
      var _sw=slsSkipWhy(f), st;
      if(_sw) st='<span style="color:#c0392b">⚠ '+_cesc(_sw)+'</span>';
      else {
        st = _slsDone[f.name] ? '<span style="color:#a85700">↻ 이미 반영됨 ('+_cesc(_slsDone[f.name].uploadDttm||'')+') — 저장 시 대체</span>'
                              : '<span style="color:#137a6c">신규</span>';
        if(+f.nBad) st+=' <span style="color:#c0392b">· 오류 '+(+f.nBad).toLocaleString()+'행 제외</span>';
      }
      h+='<tr><td class="txt-l">'+_cesc(f.name)+'</td>'
        // 출고장을 고치면 칸을 벗어날 때(onchange) 다시 그려 센터코드·상태를 즉시 재판정한다.
        //   oninput 마다 재그리면 입력 중 포커스가 날아가므로 값 갱신만 한다.
        +'<td><input class="cq" style="width:120px;height:26px'+(slsDcCd(f.dcNm)?'':';border-color:#c0392b')+'" value="'+_cesc(f.dcNm)+'" oninput="slsSetDc('+i+',this.value)" onchange="slsSetDc('+i+',this.value);slsRender()" placeholder="예: 평택"></td>'
        +'<td>'+(slsDcCd(f.dcNm)
                 ? '<b style="color:#137a6c">'+slsDcCd(f.dcNm)+'</b>'
                 : '<span style="color:#c0392b" title="출고장명으로 물류센터코드를 찾지 못했습니다. 용인·왜관·김해·광주·평택·제주·오산 중 하나로 적어주세요.&#10;★이 파일은 저장되지 않습니다 — 출고장 칸을 고치면 곧바로 저장 대상이 됩니다.">미확인</span>')+'</td>'
        +'<td>'+dlab+'</td>'
        +'<td style="text-align:right">'+f.rows.length.toLocaleString()+'</td>'
        +'<td style="text-align:right">'+_cnum(q)+'</td>'
        +'<td style="text-align:right;font-weight:700;color:#137a6c">'+_cnum(a)+'</td>'
        +'<td>'+st+'</td>'
        +'<td><button class="btn-line" style="height:26px;padding:0 8px" onclick="slsDrop('+i+')">제거</button></td></tr>';
    });
    h+='</tbody></table>';
    // 미리보기(첫 파일 최대 15행) — 기본 접힘. 확인이 필요할 때만 펼친다
    var f0=_slsFiles[0];
    if(f0 && f0.rows.length){
      h+='<details style="margin-top:12px"><summary style="cursor:pointer;font-size:12.5px;font-weight:700;color:#5a6b7a;padding:6px 0">'
        +'🔎 미리보기 — '+_cesc(f0.name)+' <span style="font-weight:400;color:#9aa7b3">(앞 15행 / 총 '+f0.rows.length.toLocaleString()+'행)</span></summary>'
        +'<table class="logi-tb"><thead><tr><th>No</th><th>발주번호</th><th>항번</th><th>품목코드</th><th>품목명</th>'
        +'<th style="text-align:right">발주량</th><th style="text-align:right">출고량</th>'
        +'<th style="text-align:right">판매단가</th><th style="text-align:right">매출액</th><th>납품일자</th><th>출고일자</th></tr></thead><tbody>';
      f0.rows.slice(0,15).forEach(function(r){
        h+='<tr><td>'+(r.rowNo==null?'':r.rowNo)+'</td><td>'+_cesc(r.ordNo)+'</td><td>'+_cesc(r.ordItemNo)+'</td>'
          +'<td>'+_cesc(r.itemCd)+'</td><td class="txt-l">'+_cesc(r.itemNm)+'</td>'
          +'<td style="text-align:right">'+(r.ordQty==null?'':r.ordQty)+'</td>'
          +'<td style="text-align:right;'+((+r.outQty||0)<0?'color:#c0392b':'')+'">'+(r.outQty==null?'':r.outQty)+'</td>'
          +'<td style="text-align:right">'+_cnum(r.salePrice)+'</td>'
          +'<td style="text-align:right;font-weight:700;color:#137a6c">'+_cnum(r.saleAmt)+'</td>'
          +'<td>'+_cesc(r.dlvDt)+'</td><td>'+_cesc(r.outDt)+'</td></tr>';
      });
      h+='</tbody></table></details>';
    }
    wrap.innerHTML=h;
  }
  /* 저장 진행바 — 업로드(실측 바이트 0~25%) → 서버 반영(경과시간 추정 25~95%) → 완료(100%)
       서버가 진행률을 안 알려주므로 서버 구간은 경과시간으로 %를 계산한다.
         p = UP + (CEIL-UP) * t/(t+tau)   (tau=행수 기반 예상시간)
       추정이 빗나가도 상한(CEIL)에 점근할 뿐 넘지 않고, 실제 응답이 오면 100%로 스냅 → 거짓 완료 없음. */
  var SLS_PROG_UP=25, SLS_PROG_CEIL=95;
  var _slsProgTimer=null, _slsProgSrvStart=0, _slsProgTau=3000;
  function _slsProgWidth(pct, stripe){
    pct=Math.max(0,Math.min(100,pct));
    var f=document.getElementById('slsProgFill'), p=document.getElementById('slsProgPct');
    if(f){ f.style.width=pct+'%'; if(stripe) f.classList.add('sls-prog-indet'); else f.classList.remove('sls-prog-indet'); }
    if(p) p.textContent=Math.round(pct)+'%';
  }
  function _slsProgLab(t){ var l=document.getElementById('slsProgLab'); if(l && t!=null) l.textContent=t; }
  function slsProgShow(lab){ var b=document.getElementById('slsProg'); if(b) b.style.display=''; _slsProgWidth(0,false); _slsProgLab(lab||'저장 준비 중…'); }
  // 업로드 실측 — bytes 비율(0~1) → 0~UP%
  function slsProgUpload(frac, lab){ _slsProgWidth((+frac||0)*SLS_PROG_UP, false); _slsProgLab(lab); }
  // 서버 반영 — 경과시간 추정 %로 계속 전진(줄무늬 애니메이션 병행)
  function slsProgServerStart(rows){
    _slsProgTau=Math.max(1500, (+rows||0)*7);          // 대략 행당 7ms 가정(느린 편 — 빗나가도 자기보정)
    _slsProgSrvStart=Date.now();
    _slsProgWidth(SLS_PROG_UP, true);
    _slsProgLab('서버 반영 중… (이력마감·단가이력 처리)');
    if(_slsProgTimer) clearInterval(_slsProgTimer);
    _slsProgTimer=setInterval(function(){
      var t=Date.now()-_slsProgSrvStart;
      _slsProgWidth(SLS_PROG_UP + (SLS_PROG_CEIL-SLS_PROG_UP)*(t/(t+_slsProgTau)), true);
    }, 150);
  }
  function _slsProgStop(){ if(_slsProgTimer){ clearInterval(_slsProgTimer); _slsProgTimer=null; } }
  function slsProgDone(){ _slsProgStop(); _slsProgWidth(100, false); _slsProgLab('완료'); }
  function slsProgHide(){ _slsProgStop(); var b=document.getElementById('slsProg'), f=document.getElementById('slsProgFill'); if(b) b.style.display='none'; if(f){ f.classList.remove('sls-prog-indet'); f.style.width='0%'; } }
  function slsSaveBtnBusy(on){ var b=document.getElementById('slsSaveBtn'); if(b){ b.disabled=!!on; b.style.opacity=on?'0.55':''; b.style.pointerEvents=on?'none':''; } }
  /* 저장 뒤 정리 — 저장에 들어간 파일만 목록에서 빼고, 제외된 파일은 남겨 고쳐서 다시 저장할 수 있게 한다.
       남은 게 없으면 종전대로 팝업을 닫는다. 반환 = 목록에 남은(제외된) 파일 수. */
  function _slsAfterSave(savedNames){
    _slsFiles=_slsFiles.filter(function(f){ return !savedNames[f.name]; });
    var left=_slsFiles.length;
    slsLoadDone();                       // 반영 파일 목록 갱신(내부에서 slsRender)
    slsQuery();
    if(left) slsRender(); else slsUpClose();
    return left;
  }
  function slsSave(){
    if(!_slsFiles.length){ ssToast('⚠️ 업로드된 파일이 없습니다.'); return; }
    /* ★저장 가능한 파일만 저장한다(2026-07-26 요청) — 종전에는 한 파일이라도 문제가 있으면 전체가 막혔다.
         문제 파일은 payload 에서 빼고 `bad` 에 사유를 남겨 확인창에 보여준 뒤, 저장 후에도 목록에 남긴다. */
    var payload=[], bad=[], okFiles=[];
    _slsFiles.forEach(function(f){
      var why=slsSkipWhy(f);
      if(why){ bad.push(f.name+' — '+why); return; }
      var dc=(f.dcNm||'').trim(), dcc=slsDcCd(dc);   // 물류센터코드 — 여기 온 파일은 slsSkipWhy 를 통과했으므로 항상 값이 있다
      f.rows.forEach(function(o){          // rows 에는 오류 행이 이미 없다(slsBuildRows 에서 제외)
        payload.push({ srcFile:f.name, dcNm:dc, dcCd:dcc,
          rowNo:o.rowNo, ordNo:o.ordNo, ordItemNo:o.ordItemNo, itemCd:o.itemCd, itemNm:o.itemNm,
          spec:o.spec, unit:o.unit, ordQty:o.ordQty, settleQty:o.settleQty, settleAmt:o.settleAmt,
          dlvDt:o.dlvDt, outDt:o.outDt, outQty:o.outQty, salePrice:o.salePrice, saleAmt:o.saleAmt,
          dlvType:o.dlvType, taxGb:o.taxGb });
      });
      okFiles.push(f);
    });
    if(!payload.length){ ssToast('⚠️ 저장할 수 있는 파일이 없습니다.'+(bad.length?('<br>'+bad.map(_cesc).join('<br>')):'')); return; }
    var q=0,a=0; payload.forEach(function(r){ q+=(+r.outQty||0); a+=(+r.saleAmt||0); });
    var dup=okFiles.filter(function(f){ return _slsDone[f.name]; }).length;
    var savedNames={}; okFiles.forEach(function(f){ savedNames[f.name]=1; });   // 저장 뒤 목록에서 뺄 파일
    // 오류 행은 파싱 단계에서 이미 빠져 있다 → 몇 행이 왜 빠졌는지만 한 줄로 알린다
    var nBad=okFiles.reduce(function(s,f){ return s+(+f.nBad||0); }, 0);
    var whys={}; okFiles.forEach(function(f){ for(var k in (f.badWhy||{})) whys[k]=(whys[k]||0)+f.badWhy[k]; });
    var whyTxt=slsBadWhy({badWhy:whys});
    ssConfirm('매출 확정내역 <b>'+payload.length.toLocaleString()+'</b>행을 저장하시겠습니까?<br>'
      +'파일 <b>'+okFiles.length+'</b>개 · 출고장 <b>'+_cesc(okFiles.map(function(f){return f.dcNm;}).join(', '))+'</b>'
      +' · 출고량 <b style="color:#137a6c">'+_cnum(q)+'</b> · 매출액 <b style="color:#137a6c">'+_cnum(a)+'</b>'
      +(nBad?('<br><span style="color:#c0392b">※ 오류 '+nBad.toLocaleString()+'행은 저장하지 않습니다'+(whyTxt?(' ('+_cesc(whyTxt)+')'):'')+'.</span>'):'')
      +(dup?('<br><span style="color:#a85700">※ 이미 반영된 파일 '+dup+'개 — 같은 (납품일자+출고장) 기존 자료는 이력마감 후 새로 적재됩니다.</span>'):'')
      +(bad.length?('<br><span style="color:#c0392b">※ '+bad.length+'개 파일은 저장 제외 — '+bad.map(_cesc).join(' / ')+'</span>'):''),
      function(){
        var body=JSON.stringify(payload);
        var nRows=payload.length;
        slsSaveBtnBusy(true);
        slsProgShow('업로드 중… (0 / '+nRows.toLocaleString()+'행)');
        var xhr=new XMLHttpRequest();
        xhr.open('POST', '${pageContext.request.contextPath}/sales/saveSalesMst.do', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.withCredentials=true;
        // 1) 업로드 진행 — 실제 전송 바이트로 0~25% (행수는 근사표기)
        xhr.upload.onprogress=function(ev){
          if(!ev.lengthComputable) return;
          var frac=ev.loaded/ev.total;
          slsProgUpload(frac, '업로드 중… ('+Math.round(frac*nRows).toLocaleString()+' / '+nRows.toLocaleString()+'행)');
        };
        // 2) 업로드 완료 → 서버 반영 구간: 경과시간 추정 %로 25→95% 전진
        xhr.upload.onload=function(){ slsProgServerStart(nRows); };
        xhr.onload=function(){
          slsProgDone();                 // 실제 응답 → 100% 스냅
          setTimeout(slsProgHide, 500);
          slsSaveBtnBusy(false);
          var ok=(xhr.status>=200 && xhr.status<300), t=xhr.responseText;
          if(!ok){ ssToast('⚠️ 저장 실패: '+(t||('HTTP '+xhr.status))); return; }
          // 응답 = {saved:행수, price:판매단가 이력 반영 품목수, none:변화없음, skip:단가 충돌로 제외}
          //  · 문자열로 한 번 더 감싸져 오면(서버가 String 으로 반환하면) 풀어준다 — 안 그러면 전부 0으로 보임
          var j=null; try{ j=JSON.parse(t); }catch(e){}
          if(typeof j==='string'){ try{ j=JSON.parse(j); }catch(e){ j=null; } }
          // 저장된 파일만 목록에서 빠지고, 제외된 파일은 남는다 → 남은 수를 알림에 덧붙인다
          var _leftMsg=function(n){ return n?(' · <span style="color:#c0392b">제외 '+n+'개 파일은 목록에 남김</span>'):''; };
          if(!j || typeof j!=='object'){ var l0=_slsAfterSave(savedNames); ssToast('💾 저장 완료 — <b>'+_cesc(t)+'</b>'+_leftMsg(l0)); return; }
          var msg='💾 저장 완료 — <b>'+(+j.saved||0).toLocaleString()+'</b>행 · 판매단가 이력 <b>'+(+j.price||0)+'</b>종 반영';
          if(+j.none)  msg+=' · <span style="color:#9aa7b3">변화없음 '+j.none+'종</span>';
          if(+j.skip)  msg+=' · <span style="color:#a85700">단가충돌 '+j.skip+'종 제외</span>';
          msg+=_leftMsg(_slsAfterSave(savedNames));
          ssToast(msg);
        };
        xhr.onerror=function(){ slsProgHide(); slsSaveBtnBusy(false); ssToast('⚠️ 통신오류 — 네트워크를 확인하세요.'); };
        xhr.ontimeout=function(){ slsProgHide(); slsSaveBtnBusy(false); ssToast('⚠️ 저장 시간 초과 — 잠시 후 다시 시도하세요.'); };
        xhr.send(body);
      });
  }
  /* ══════════════════════════════════════════════════════════════════════════
     출고내역 (매입·재고관리 ▸ 출고내역) — 정산서 × 출고내역 대사
       · 정산서   = TBL_SALES_MST   (출고장이 준 엑셀. 출고장에 들어간 물품값 = 우리가 받을 금액)
       · 출고내역 = TBL_SHIPOUT_MST (발주현황표 업로드분. 실제 나간 수량)
       · 짝 맞추기 = 발주번호(ORD_NO) + 발주항번(ORD_ITEM_NO)  ← 두 표가 같은 값을 쓴다
       · 기간 기준 = 납품일자(=발주일자 DLV_DT). 출고내역은 SHPOUT_DT 로만 조회되는데
         먼 지역은 발주분을 하루 당겨 출고하므로 ±7일 넉넉히 읽어 DLV_DT 로 다시 거른다.
     ══════════════════════════════════════════════════════════════════════════ */
  /* 매출내역 4탭 표시 방식 — 한 번에 18행(KONET_GRID_ROWS)씩, 나머지는 스크롤로 자동 이어붙임 — 2026-07-25 요청.
       "한 화면 18행으로 하되 페이지 버튼으로 넘기지 말고 자동 스크롤"
       · 2026-07-24 의 'OH_ROWS 를 크게 잡아 전체 행 표시'를 대체한다. 전체 렌더는 4천행에서 표가 무거웠고,
         그 전의 페이저는 페이지를 넘겨가며 봐야 했다. 둘 다 없애는 방식이 이것이다.
       · 화면 아래로 넘치지 않게 표 높이는 18행으로 맞추되, 창이 낮으면 뷰포트에서 자른다(_ohFit).
       · 입고내역 INB_PAGE·재고현황 STK_PAGE 등 다른 화면의 페이징에는 영향 없음. */
  var _ohSales=[], _ohShip=[], _ohTab='dc', _ohCol={}, _ohAllCol=false, OH_ROWS=KONET_GRID_ROWS;
  var _ohSalesAll=[], _ohShipAll=[];   // 출고장 선택 전 원본 — 선택은 화면에서만 거르므로 재조회 없이 되돌릴 수 있다

  function _ohQ(v){   // 수량 — 소수·음수 보존(반품행 0.49/-0.49)
    var n=Number(v); if(!isFinite(n)) return '';
    return (Math.abs(n%1)<1e-9) ? n.toLocaleString() : n.toLocaleString(undefined,{maximumFractionDigits:3});
  }
  function _ohYmd(s){ return (''+(s==null?'':s)).replace(/-/g,'').trim(); }         // '2026-07-11'|'20260711' → '20260711'
  /* 출고장 통일키(_ohDc / _ohDcOf)는 위쪽 KONET_DC 블록에 있다 — 여기 있던 중복 정의 제거(2026-07-22).
     ※ DC_CD 는 정산서에 2026-07-22부터 저장되므로 그 전 자료는 이름으로 잡힌다 — 둘 다 '평택'으로 수렴한다. */
  /* ★대사키 = 발주일자 + 출고장 + 품목코드 (2026-07-22 사용자 확정)
       발주번호+항번을 쓰다가 바꿨다. 이유:
         · 발주현황표의 ORD_NO 가 절반(1145행 중 573행) 비어 있어 그만큼 영영 대사 불가였다
           (병합셀 아님 — ORD_NO·ORD_ITEM_NO 가 함께 비고 JUMUN_NO 만 100% 차 있다. 원본이 그렇다)
         · 정산서에는 주문번호 칸이 없어(엑셀 17컬럼 실측) 주문번호로도 못 잇는다
         · 이 세 칸은 양쪽 다 100% 채워져 있다 → 빠지는 행이 없다
       성격: 행 대 행이 아니라 **합계 대 합계**.
         정산서 105행 → 103키 / 출고 1145행 → 888키 (출고는 사업장이 자동 합산된다) */
  function _ohKey(o){
    /* 판매전표(직접판매)는 대사 대상이 아니다 — 출고장 발주현황표에 짝이 있을 수 없다.
       키를 안 만들어야 '출고미상'(정산엔 있는데 출고가 없음)으로 오분류되지 않는다(2026-07-25). */
    if(o && o.trxYn==='Y') return '';
    var d=_ohYmd(o&&o.dlvDt), dc=_ohDcOf(o), it=(''+((o&&o.itemCd)||'')).trim();
    return (d&&dc&&it) ? (d+'|'+dc+'|'+it) : '';   // 셋 중 하나라도 비면 키가 안 선다(실측 0건)
  }
  function _ohShift(d, days){   // 'yyyy-mm-dd' ± n일
    if(!d) return '';
    var p=d.split('-'); if(p.length<3) return '';
    var t=new Date(+p[0], +p[1]-1, +p[2]+days);
    return t.getFullYear()+'-'+ssPad(t.getMonth()+1)+'-'+ssPad(t.getDate());
  }

  function ohEnter(){   // 메뉴 진입 — 기간 기본값 → 첫 진입이면 자동 조회
    slsInit();
    if(!_ohSales.length && !_ohShip.length){ slsLoadDone(); ohQuery(); }
  }
  function ohTab(t){
    _ohTab=t;
    document.querySelectorAll('#ohTabs .ctab').forEach(function(b){ b.classList.toggle('on', b.getAttribute('data-t')===t); });
    ohRender();
  }
  // ①탭 출고장 줄 클릭 → ②(품목)탭으로 드릴다운. 그 출고장만 펼치고 나머지는 접는다
  //   — '차이'가 어느 품목 때문인지 한 클릭에 보이게(2026-07-22 요청).
  //   출고장이 7곳뿐이라 접힌 머리행이 전부 1페이지에 들어와 대상이 항상 바로 보인다.
  function ohDrill(k){
    k=decodeURIComponent(k);
    _ohAllCol=true; _ohCol={}; _ohCol['i:'+k]=false;
    ohTab('item');
  }
  function ohToggleAll(){
    _ohAllCol=!_ohAllCol; _ohCol={}; _ohUpdAllBtn(); ohRender();   // 표시행이 통째로 바뀌므로 처음 18행부터 다시
  }
  function _ohUpdAllBtn(){ var b=document.getElementById('ohAllBtn'); if(b) b.innerHTML=_ohAllCol?'⊞ 전체 펼치기':'⊟ 전체 접기'; }
  // 접기/펼치기 — 키에 탭 접두사를 붙여 ②(i:)와 ④(s:/b:)가 서로 간섭하지 않게 한다
  function _ohIsCol2(k, def){ return (k in _ohCol) ? _ohCol[k] : def; }
  function ohGrp(k){
    k=decodeURIComponent(k);
    var def = (k==='dtsec')         ? true            // ①탭 일자별 구획 = 기본 접힘
            : (k.indexOf('gq:')===0)? true            // ⑤탭 품목 하위(출고 원본행) = 기본 접힘
            : (k.indexOf('b:')===0) ? true            // 사업장 하위(원본행) = 기본 접힘
            : (/^d\d*:/.test(k))    ? false           // 물류센터 묶음(d:①/d2:②/d3:③/d4:④) = 기본 펼침 (_ohAllCol 영향 안 받음)
            : _ohAllCol;
    _ohCol[k] = !_ohIsCol2(k, def);
    _ohKeepScroll(ohRender);   // ★접기/펼치기 후 화면이 맨 위로 튀지 않게 (2026-07-27 지적)
  }
  /* 접기/펼치기는 표를 innerHTML 로 통째로 다시 그린다(lzMount) → #ohWrap 의 scrollTop 이 0으로 초기화되면서
     보고 있던 줄이 화면 밖으로 사라진다. 그래서 위치를 저장했다가 되돌린다.
      · 다시 그리면 앞 N행만 붙고 나머지는 스크롤할 때 채워지므로(lzFill), 저장한 위치가 보일 만큼 먼저 채운다.
      · 페이지 자체 스크롤(window)도 함께 되돌린다 — 표 높이가 바뀌면 페이지가 밀릴 수 있다. */
  function _ohKeepScroll(fn){
    var w=document.getElementById('ohWrap');
    var top=w?w.scrollTop:0, winY=(window.pageYOffset||document.documentElement.scrollTop||0);
    fn();
    w=document.getElementById('ohWrap');
    if(w){
      for(var g=0; w._lz && w._lz.from<w._lz.list.length && w.scrollHeight < top+w.clientHeight && g<400; g++) lzFill(w);
      w.scrollTop=top;
    }
    if(winY) window.scrollTo(0, winY);
  }
  function _ohIsCol(k){ return _ohIsCol2('i:'+k, _ohAllCol); }

  // 정산(TBL_SALES_MST) + 출고내역(TBL_SHIPOUT_MST) 동시 조회
  function ohQuery(){
    var f=(document.getElementById('slsFrom')||{}).value||'', t=(document.getElementById('slsTo')||{}).value||'';
    var ic=((document.getElementById('slsItemCd')||{}).value||'').trim();
    var sum=document.getElementById('ohSum'); if(sum) sum.textContent='조회 중…';
    qBusy('ohWrap','ohPager','정산서와 출고내역을 맞춰 보는 중입니다…');
    var post=function(url, body){
      return fetch('${pageContext.request.contextPath}'+url, { method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:body })
        .then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||[]; });
    };
    /* 출고장은 서버에 넘기지 않고 화면에서 거른다 —
       ①묶음('G:오산센터')은 서버가 모르는 개념이고
       ②DC_NM 표기가 두 표에서 다르다('평택' vs '평택물류센터'). 양쪽을 같은 규칙(_ohDcHit)으로 걸러야 어긋나지 않는다. */
    var pSales=post('/sales/selectSalesMst.do',
      'dlvDtFrom='+encodeURIComponent(f)+'&dlvDtTo='+encodeURIComponent(t)+'&itemCd='+encodeURIComponent(ic));
    /* 출고내역은 SHPOUT_DT 로만 조회되므로 넉넉히 읽어 아래에서 DLV_DT 로 재필터한다.
       ★창 밖으로 벗어난 행은 '경고 없이' 빠지고 화면은 그대로 '일치'로 보인다 —
         이 화면에서 가장 나쁜 실패 방식이라, 감지 로직을 붙이는 대신 창을 한 달로 넓혔다(2026-07-22).
         실측 편차는 0일(1,312행)·-1일(41행)뿐이지만 여유를 크게 두는 쪽이 안전하다.
       (자료가 몇 년치 쌓여 응답이 무거워지면 서버에서 DLV_DT 로 거르도록 바꿔야 한다 — WAR 재빌드) */
    var OH_WIN=31;
    var pShip = (f && t)
      ? post('/shipout/selectShipoutMst.do', 'shpoutDtFrom='+encodeURIComponent(_ohShift(f,-OH_WIN))+'&shpoutDtTo='+encodeURIComponent(_ohShift(t,OH_WIN)))
      : post('/shipout/selectShipoutMst.do', '');
    /* 판매전표(직접판매) — 정산서 밖에서 직접 판 건. 서버가 정산서 행과 같은 모양으로 준다(2026-07-25 요청).
       출고장이 아니라 '직접판매(전표)' 라는 별도 묶음으로 서고, trxYn='Y' 표시가 붙어 온다.
       그 표시가 있으면 _ohKey 가 대사키를 만들지 않는다 — 출고 자료에 짝이 있을 수 없어서
       그냥 넣으면 전부 '출고미상'(빨간 경고)으로 잡히기 때문. */
    var pTrx=post('/mangr/salesTrxHist.do',
      'fromDt='+encodeURIComponent(f)+'&toDt='+encodeURIComponent(t)+'&findData='+encodeURIComponent(ic))
      .catch(function(){ return []; });
    Promise.all([pSales, pShip, pTrx]).then(function(a){
      var fY=_ohYmd(f), tY=_ohYmd(t), icQ=ic.toLowerCase();
      _ohSalesAll=(a[0]||[]).concat(a[2]||[]);
      _ohShipAll=(a[1]||[]).filter(function(r){
        var d=_ohYmd(r.dlvDt)||_ohYmd(r.shpoutDt);
        if(fY && tY && (d<fY || d>tY)) return false;
        if(icQ && (''+(r.itemCd||'')).toLowerCase().indexOf(icQ)<0
               && (''+(r.itemNm||'')).toLowerCase().indexOf(icQ)<0) return false;
        return true;
      });
      ohDcApply();   // 출고장 선택 반영 + 드롭다운 목록 갱신 + 렌더
    }).catch(function(e){ qFail('ohWrap','조회 오류 — '+_cesc(e.message)); ssToast('⚠️ 조회 오류: '+e.message); });
  }
  function slsQuery(){ ohQuery(); }   // 저장 직후 재조회 (기존 호출부 유지)

  // 출고장 → {정산 합계, 출고 합계} 로 접어 담기 (탭 공통 소스)
  function _ohRoll(){
    var m={}, ord=[];
    var pick=function(r0, nm){
      var k=_ohDcOf(r0)||'(출고장 미지정)';
      // 라벨은 통일키(평택), 원래 표기(평택/평택물류센터)는 hover 로 남긴다
      // sKeys/oKeys = 대사키 집합. 수량 합계만 보면 '정산에만 5개 + 출고에만 5개'가 상쇄돼
      //               차이 0 = 일치 로 오진하므로, 짝 없는 키를 따로 센다.
      if(!m[k]){ m[k]={ dc:k, label:k, raw:{}, sRows:0, sQty:0, sAmt:0, oRows:0, oQty:0, eQty:0, eAmt:0,
                        items:{}, itemOrd:[], sKeys:{}, oKeys:{}, sOnly:0, oOnly:0 }; ord.push(k); }
      if(nm) m[k].raw[nm]=1;
      return m[k];
    };
    var item=function(g, cd, nm){
      var k=cd||'(품목코드 없음)';
      if(!g.items[k]){ g.items[k]={ itemCd:k, itemNm:nm||'', sQty:0, sAmt:0, oQty:0, eQty:0, eAmt:0, price:null }; g.itemOrd.push(k); }
      var it=g.items[k]; if(!it.itemNm && nm) it.itemNm=nm; return it;
    };
    _ohSales.forEach(function(r){
      var g=pick(r, r.dcNm); g.sRows++; g.sQty+=(+r.outQty||0); g.sAmt+=(+r.saleAmt||0);
      if(r.trxYn==="Y") g.trx=true;   // 직접판매 묶음 표시 — 대사 대상이 아니라는 뜻
      var kk=_ohKey(r); if(kk) g.sKeys[kk]=1;
      var it=item(g, r.itemCd, r.itemNm); it.sQty+=(+r.outQty||0); it.sAmt+=(+r.saleAmt||0);
      it.sRows=(it.sRows||0)+1;   // [⑤차이탭] '정산서가 온 품목'인지 판정용 — 수량이 0인 정산행도 온 것으로 본다
      if(it.price==null && r.salePrice!=null) it.price=+r.salePrice;
    });
    /* ★정산서가 아직 안 온 출고의 매출금액 — 마감관리와 같은 방식으로 채운다(2026-07-25 요청).
         · 대상 = 대사키가 정산서에 없는 출고행(= 미정산). 키가 아예 안 서는 행(일자·출고장·품목 중 빈칸)도 포함.
         · 금액 = 출고수량 × saleUnit. saleUnit 은 서버가 selectClosing 과 똑같은 규칙으로 붙여 준다
           (판매단가 이력 APPLY_DT ≤ 납품일자 공통가 최신 → 없으면 상품마스터 SALE_PRICE).
         · 정산서가 온 건은 손대지 않는다 — 그건 실제 '받을 금액'이고 이건 추정이다. 구분은 상태 칸(미정산 뱃지).
       ※ 위 _ohSales 루프가 먼저 돌아 g.sKeys 가 이미 다 차 있으므로 여기서 바로 판정할 수 있다. */
    _ohShip.forEach(function(r){
      var g=pick(r, r.dcNm); g.oRows++; g.oQty+=(+r.curQty||0);
      var kk=_ohKey(r); if(kk) g.oKeys[kk]=1;
      var it=item(g, r.itemCd, r.itemNm), q=(+r.curQty||0);
      it.oQty+=q;
      if(!kk || !g.sKeys[kk]){
        var u=(+r.saleUnit||0), amt=q*u;
        g.eQty+=q; g.eAmt+=amt; it.eQty+=q; it.eAmt+=amt;
        if(it.price==null && u) it.price=u;   // 정산단가가 없으면 추정단가라도 보여준다
      }
    });
    // 짝 없는 대사키 집계 — oOnly=보냈는데 청구 안 됨(미정산) / sOnly=보낸 적 없는데 청구됨(출고미상)
    ord.forEach(function(k){
      var g=m[k];
      Object.keys(g.sKeys).forEach(function(x){ if(!g.oKeys[x]) g.sOnly++; });
      Object.keys(g.oKeys).forEach(function(x){ if(!g.sKeys[x]) g.oOnly++; });
    });
    return ord.sort(function(a,b){ return a.localeCompare(b,'ko'); }).map(function(k){ return m[k]; });
  }
  function _ohDateFmt(d){ d=''+(d==null?'':d); return d.length===8 ? d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8) : d; }
  /* 일자(납품일자 DLV_DT) → 출고장 로 접어 담기 — ①탭 '일자별' 구획 소스.
       _ohRoll 과 같은 규칙(대사키 date|dc|item 이 이미 날짜 포함)이라 날짜로 한 겹 더 나눠도 미정산/출고미상이 일관.
       ※ 납품일자 없는 행(키없음)은 날짜 배치가 안 되므로 이 구획에서 빠진다 → 일자합 총합 ≤ 총합계(정상). */
  function _ohRollByDate(){
    var dm={};
    var pick=function(r0, nm){
      var d=_ohYmd(r0 && r0.dlvDt) || '';
      var k=_ohDcOf(r0)||'(출고장 미지정)';
      if(!dm[d]) dm[d]={ date:d, m:{}, ord:[] };
      var D=dm[d];
      if(!D.m[k]){ D.m[k]={ dc:k, label:k, raw:{}, sRows:0,sQty:0,sAmt:0, oRows:0,oQty:0, eQty:0,eAmt:0, sKeys:{}, oKeys:{}, sOnly:0, oOnly:0 }; D.ord.push(k); }
      if(nm) D.m[k].raw[nm]=1;
      return D.m[k];
    };
    _ohSales.forEach(function(r){ var g=pick(r, r.dcNm); g.sRows++; g.sQty+=(+r.outQty||0); g.sAmt+=(+r.saleAmt||0);
      if(r.trxYn==='Y') g.trx=true; var kk=_ohKey(r); if(kk) g.sKeys[kk]=1; });
    _ohShip.forEach(function(r){ var g=pick(r, r.dcNm); g.oRows++; g.oQty+=(+r.curQty||0); var kk=_ohKey(r); if(kk) g.oKeys[kk]=1;
      if(!kk || !g.sKeys[kk]){ var q=(+r.curQty||0); g.eQty+=q; g.eAmt+=q*(+r.saleUnit||0); }   // 미정산 = 추정매출(위 _ohRoll 과 같은 규칙)
    });
    var dates=Object.keys(dm).filter(function(d){ return d; }).sort().reverse();   // YYYYMMDD 최근순
    return dates.map(function(d){
      var D=dm[d];
      var kids=D.ord.sort(function(a,b){ return a.localeCompare(b,'ko'); }).map(function(k){
        var g=D.m[k];
        Object.keys(g.sKeys).forEach(function(x){ if(!g.oKeys[x]) g.sOnly++; });
        Object.keys(g.oKeys).forEach(function(x){ if(!g.sKeys[x]) g.oOnly++; });
        return g;
      });
      var tot={ oRows:0,oQty:0,sRows:0,sQty:0,sAmt:0,eQty:0,eAmt:0,sOnly:0,oOnly:0 };
      kids.forEach(function(g){ tot.oRows+=g.oRows; tot.oQty+=g.oQty; tot.sRows+=g.sRows; tot.sQty+=g.sQty; tot.sAmt+=g.sAmt; tot.eQty+=g.eQty; tot.eAmt+=g.eAmt; tot.sOnly+=g.sOnly; tot.oOnly+=g.oOnly; });
      return { date:d, kids:kids, tot:tot };
    });
  }
  // 발주번호+항번 → 상대편 행 (상세 2탭의 대사 열). a=정산금액(정산서 인덱스일 때만 값이 있다)
  function _ohIndex(rows, qtyField){
    var m={}; rows.forEach(function(r){
      var k=_ohKey(r); if(!k) return;
      var e=m[k] || (m[k]={n:0,q:0,a:0,r:r});
      e.n++; e.q+=(+r[qtyField]||0); e.a+=(+r.saleAmt||0);
    });
    return m;
  }
  /* 출고장 ▸ 사업장 ▸ 출고원본행 3단 — ③탭 전용. 출고수량만 다루고 금액은 얹지 않는다.
       ★사업장별 정산금액은 만들지 않는다(2026-07-22 사용자 확정).
         정산서는 '발주' 단위, 출고는 '발주 × 사업장' 단위라 1:N —
         실측 572행이 발주번호+항번 352개(정산서는 105행=105키 1:1).
         정산서에 사업장 칸이 없으니 사업장으로 쪼개면 어떤 방식이든 추정이 된다.
         → 금액은 ①②(출고장·품목 단위)에서만 보고, 여기서는 '대사 상태'만 사실로 표시. */
  function _ohRollBiz(){
    var idx=_ohIndex(_ohSales,'outQty'), m={}, ord=[];
    _ohShip.forEach(function(r){
      var dk=_ohDcOf(r)||'(출고장 미지정)';
      var g=m[dk]; if(!g){ g=m[dk]={ dc:dk, label:dk, oRows:0, oQty:0, hit:0, noKey:0, unpaid:0, bizOrd:[], biz:{} }; ord.push(dk); }
      var bnm=(''+(r.bizNm||'')).trim()||'(사업장 미지정)', bk=(''+(r.bizCd||''))+'|'+bnm;
      var b=g.biz[bk]; if(!b){ b=g.biz[bk]={ key:bk, bizCd:r.bizCd||'', bizNm:bnm, rows:[], oQty:0, hit:0, noKey:0, unpaid:0 }; g.bizOrd.push(bk); }
      var k=_ohKey(r), hit=k?!!idx[k]:false, oq=(+r.curQty||0);
      b.rows.push({ r:r, hit:hit, k:k });
      b.oQty+=oq; g.oQty+=oq; g.oRows++;
      if(hit){ b.hit++; g.hit++; } else if(!k){ b.noKey++; g.noKey++; } else { b.unpaid++; g.unpaid++; }
    });
    ord.sort(function(a,b){ return a.localeCompare(b,'ko'); });
    ord.forEach(function(k){ m[k].bizOrd.sort(function(a,b){ return m[k].biz[a].bizNm.localeCompare(m[k].biz[b].bizNm,'ko'); }); });
    return ord.map(function(k){ return m[k]; });
  }
  
  // 대사 상태 요약 — 건수만(금액 아님). noKey 는 세 칸 중 하나가 빈 이상행(실측 0건)
  function _ohStat(o){
    return (o.hit  ? ' <span style="font-weight:700;color:#137a6c">대사 '+o.hit+'</span>' : '')
         + (o.unpaid ? ' <span style="font-weight:700;color:#c0392b">· 미정산 '+o.unpaid+'</span>' : '')
         + (o.noKey  ? ' <span style="font-weight:600;color:#9aa7b3">· 키없음 '+o.noKey+'</span>' : '');
  }

  /* 탭별 원천 — 요약줄 맨 앞에 칩으로 붙인다(전용 줄을 두면 상단이 무거워짐. 자세한 건 탭 버튼 hover).
     ①②는 정산서 기준이 아니라 양쪽 합집합이다(한쪽만 있어도 줄이 생겨야 '정산 미도착'을 잡는다). */
  var OH_DESC={ dc:'정산서 ∪ 출고내역', item:'정산서 ∪ 출고내역 · 품목축', gap:'정산서 온 품목 · 수량 불일치만', ship:'출고내역 · 사업장축', settle:'정산서 단독' };
  function _ohSrcChip(){
    return '<span style="display:inline-block;padding:1px 8px;margin-right:6px;border-radius:999px;background:#eaf3f1;color:#137a6c;font-size:11.5px;font-weight:700"'
      + ' title="이 탭이 어느 표에서 줄을 가져오는지. 자세한 설명은 탭 이름에 마우스를 올려 보세요.">'+(OH_DESC[_ohTab]||'')+'</span>';
  }
  /* 같은 대사키에 '단가가 다른 정산서 행'이 섞였는지 감지 (2026-07-25 요청).
       대사키는 납품일자+출고장+품목이라 그 안에 발주가 여러 건 들어올 수 있다. 발주별 단가가 같으면
       마감의 사업장별 안분(출고수량 비율)이 발주 단위로 나눈 것과 똑같아서 문제가 없다.
       단가가 다른 순간부터 안분이 틀어지므로, 그 조건이 생기면 알려만 준다.
       ※ 2026-07 실측 = 0건. 발주키로 대사를 바꾸는 대신 이 감지를 두기로 확정
         (발주번호는 출고 자료의 10%가 비어 있어 대사키로 쓰면 매칭률이 88%→82%로 떨어진다). */
  function _ohPriceMix(){
    var m={}, hit=[], amt=0;
    _ohSales.forEach(function(r){
      var k=_ohKey(r); if(!k) return;
      var e=m[k] || (m[k]={ p:{}, amt:0, r:r });
      e.p[''+(+r.salePrice||0)]=1; e.amt+=(+r.saleAmt||0);
    });
    Object.keys(m).forEach(function(k){
      var e=m[k]; if(Object.keys(e.p).length<2) return;
      hit.push({ k:k, r:e.r, amt:e.amt, prices:Object.keys(e.p) }); amt+=e.amt;
    });
    hit.sort(function(a,b){ return b.amt-a.amt; });
    return { n:hit.length, amt:amt, list:hit };
  }
  function _ohMixNote(){
    var x=_ohPriceMix(); if(!x.n) return '';
    var tip='같은 대사키(납품일자+출고장+품목)에 단가가 서로 다른 정산서 행이 섞였습니다.\n'
      +'이 경우 매출마감의 사업장별 안분(출고수량 비율)이 발주 단위로 나눈 값과 달라집니다.\n'
      +'총액·출고장별 금액은 영향이 없고, 사업장별 배분만 어긋납니다.\n\n금액 큰 순:\n';
    x.list.slice(0,5).forEach(function(o){
      var p=o.k.split('|');
      tip += '· '+_ohDateFmt(p[0])+' '+p[1]+' '+(o.r.itemNm||p[2])+' — 단가 '+o.prices.join(' / ')+' · '+_cnum(o.amt)+'원\n';
    });
    if(x.n>5) tip += '… 외 '+(x.n-5)+'건';
    return ' · <span style="color:#c47f17;font-weight:700" title="'+_cesc(tip)+'">⚠ 키당 단가 혼재 '+x.n+'건 · '+_cnum(x.amt)+'원</span>';
  }
  function ohRender(){
    var wrap=document.getElementById('ohWrap'), sum=document.getElementById('ohSum'), pg=document.getElementById('ohPager');
    if(!wrap) return;
    // ⊟ 전체 접기 — 그룹이 있는 탭에서만. ④(settle)도 출고장별 묶음이 생겼으므로 포함(2026-07-22)
    //   빠뜨리면 그룹은 접힌 채인데 펼칠 수단이 없어진다
    // 접기 버튼은 트리가 있는 탭에서만 — ①(1단만)·⑤(평면 목록)에는 접을 것이 없다
    var btn=document.getElementById('ohAllBtn'); if(btn) btn.style.display=(_ohTab==='dc'||_ohTab==='gap')?'none':'';
    _ohUpdAllBtn();   // 라벨(접기/펼치기)이 현재 상태와 어긋나지 않게 매 렌더마다 맞춘다
    if(!_ohSales.length && !_ohShip.length){
      sum.innerHTML=_ohSrcChip()+'조회된 자료가 없습니다. (정산 엑셀 저장분·발주현황표 출고 모두 없음)';
      wrap.innerHTML=''; wrap._lz=null; if(pg) pg.innerHTML=''; return;   // 남아있던 '더 붙일 행'도 함께 버린다
    }
    /* sQ/sA = 정산수량·정산금액(직접판매 포함).
       tQ/tA = 그중 직접판매(전표)분. 수량차이는 대사 대상만 봐야 하므로 sQ 에서 tQ 를 뺀 값으로 잰다
       — 안 그러면 전표를 넣는 순간 없던 '수량차이'가 생긴 것처럼 보인다(2026-07-25). */
    var sQ=0,sA=0,oQ=0,noKey=0,tQ=0,tA=0,tRows=0;
    _ohSales.forEach(function(r){
      sQ+=(+r.outQty||0); sA+=(+r.saleAmt||0);
      if(r.trxYn==='Y'){ tQ+=(+r.outQty||0); tA+=(+r.saleAmt||0); tRows++; }
    });
    _ohShip.forEach(function(r){ oQ+=(+r.curQty||0); if(!_ohKey(r)) noKey++; });
    var gapQ = oQ - (sQ - tQ);   // 대사용 수량차이 — 직접판매는 빼고 잰다
    var G=_ohRoll();
    var eA=0; G.forEach(function(g){ eA+=(+g.eAmt||0); });   // 정산서 안 온 출고의 추정매출 합
    sum.innerHTML=_ohSrcChip()+'출고장 <b>'+G.length+'</b>곳 · 출고내역 <b>'+_ohShip.length.toLocaleString()+'</b>행/<b>'+_ohQ(oQ)+'</b>'
      +' · 정산 <b>'+_ohSales.length.toLocaleString()+'</b>행/<b>'+_ohQ(sQ)+'</b>'
      +' · <span style="color:#137a6c">정산금액 <b>'+_cnum(sA+eA)+'</b></span>'
      +(eA?' <span style="color:#a85700" title="정산서가 아직 안 온 출고를 판매단가(마감관리와 같은 규칙)로 채운 금액입니다.">(정산 '+_cnum(sA)+' + 추정 '+_cnum(eA)+')</span>':'')
      +(tRows ? ' · <span style="color:#1a73c7;font-weight:700" title="판매등록으로 직접 입력한 매출. 출고장 대사 대상이 아니라 수량차이 계산에서 빠집니다.">직접판매 '+tRows.toLocaleString()+'행/'+_cnum(tA)+'</span>' : '')
      +(Math.abs(gapQ)>1e-6 ? ' · <span class="oh-gap">수량차이 '+_ohQ(gapQ)+'</span>' : ' · <span class="oh-ok">수량 일치</span>')
      // 짝 없는 대사키 — 수량이 상쇄돼 '일치'로 보일 수 있으므로 건수를 따로 띄운다
      +(function(){ var so=0,oo=0; G.forEach(function(g){ so+=g.sOnly; oo+=g.oOnly; });
          return (oo?' · <span style="color:#c0392b;font-weight:700" title="보냈는데 정산서에 없는 품목(청구 누락 후보)">미정산 '+oo+'품목</span>':'')
               + (so?' · <span style="color:#a85700;font-weight:700" title="정산서에는 있는데 출고내역에 없는 품목">출고미상 '+so+'품목</span>':'')
               + ((!oo&&!so&&_ohSales.length&&_ohShip.length)?' · <span class="oh-ok">품목 전건 대사</span>':''); })()
      +(noKey ? ' · <span style="color:#c47f17;font-weight:700" title="발주일자·출고장·품목코드 중 빈 칸이 있어 대사키가 서지 않는 출고행입니다.">키 없는 출고 '+noKey.toLocaleString()+'행</span>' : '')
      +(!_ohShip.length && _ohSales.length ? ' · <span style="color:#c47f17;font-weight:700">이 기간 출고내역(발주현황표) 자료가 없습니다</span>' : '')
      +_ohMixNote();
    if(_ohTab==='dc')          _ohRenderDc(G, wrap, oQ, sQ, sA);
    else if(_ohTab==='item')   _ohRenderItem(G, wrap, oQ, sQ, sA);
    else if(_ohTab==='gap')    _ohRenderGap(G, wrap);
    else if(_ohTab==='settle') _ohRenderSettle(wrap, sQ, sA);
    else                       _ohRenderShip(wrap, oQ);
  }

  /* ⑤ 수량차이 품목 (2026-07-27 요청) — "정산서 온 것 기준으로, 출고수량과 정산수량이 다른 품목".
       ①②의 트리에 필터를 걸면 소계가 필터 전/후로 갈려 읽기 나빠지므로, 별도 탭에 평면 목록으로 뽑는다.
       ★대상 기준 = <정산서에 온 품목>(it.sRows>0). "정산서 온 것만 대사" (2026-07-27 사용자 확정).
         · 정산서에 아예 없는 품목은 대사 대상이 아니다 → 목록에 넣지 않는다.
           (그건 '차이'가 아니라 청구가 안 된 것 = 미정산. ①탭 상태 칸에서 본다.)
         · 다만 몇 건이 그렇게 빠졌는지는 총합계 줄에 숫자로만 알려 준다 — 조용히 빠지면 다 본 줄 알기 때문.
       정렬 = 차이 절대값 큰 순. 부호로 방향을 구분한다.
         · +  출고 > 정산 = 보냈는데 청구가 덜 됐다(청구 누락 후보)
         · −  정산 > 출고 = 청구가 더 됐다(과청구·출고기록 누락 후보)                          */
  /* ★[미정산 같이 보기] (2026-07-28 요청) — 기본은 끔.
       켜면 <정산서에 없는 품목>(=미정산)까지 같은 표에 회색·호박색으로 섞어 보여 준다.
       · 이때는 **정산서가 통째로 안 온 출고장**까지 훑는다 — 미정산은 거기 몰려 있기 때문이다.
       · 미정산 줄은 '차이'가 아니므로 (정산 많음 · 출고 많음) 건수에는 넣지 않는다. 따로 센다.
       · 제외 건수(skipNB)는 켜고 끄고에 상관없이 **항상 전체 기준**으로 센다 — 안 그러면 같은 화면에서
         숫자가 오락가락한다(종전엔 정산서 온 출고장 안에서만 세어 실제보다 적게 나왔다). */
  var _ohGapNB=false;
  function ohGapNB(){ _ohGapNB=!_ohGapNB; ohRender(); }

  function _ohRenderGap(G, wrap){
    /* ★수량차이 = <정산수량 − 출고수량> (2026-07-27 사용자 확정). 정산서 기준 탭이라 정산서를 앞에 둔다.
         ①②③탭은 반대(출고−정산)라 부호가 뒤집혀 보인다 — 이 탭은 정산서 기준이라는 뜻이므로 헷갈리지 않게
         컬럼도 '정산수량 → 출고수량' 순으로 놓고, 머리글·툴팁에 계산식을 적어 둔다.
           +  정산 > 출고 = 청구가 더 됐다(과청구·출고기록 누락 후보)
           −  출고 > 정산 = 보냈는데 청구가 덜 됐다(청구 누락 후보) */
    var rows=[], tO=0, tS=0, sMore=0, oMore=0, skipNB=0, dcN=0, nbN=0;
    G.forEach(function(g){
      var hasS=(g.sRows>0);                                        // 이 출고장에 정산서가 왔는가
      if(hasS) dcN++;
      g.itemOrd.forEach(function(k){
        var it=g.items[k];
        var d=(+it.sQty||0)-(+it.oQty||0);                         // 정산수량 − 출고수량
        if(Math.abs(d)<=0.0001) return;                            // 수량이 맞는 품목 제외
        if(!(it.sRows>0)){                                         // 정산서에 없는 품목 = 미정산(대사 대상 아님)
          skipNB++;                                                //   전체 기준으로 항상 센다
          if(!_ohGapNB) return;                                    //   [미정산 같이 보기] 꺼져 있으면 여기까지
          nbN++;
          rows.push({ dc:g.label, it:it, d:d, nb:true });
          tO+=(+it.oQty||0); tS+=(+it.sQty||0);
          return;
        }
        if(!hasS) return;                                          // 방어 — 정산행이 있으면 hasS 가 참이어야 한다
        rows.push({ dc:g.label, it:it, d:d });
        tO+=(+it.oQty||0); tS+=(+it.sQty||0);
        if(d>0) sMore++; else oMore++;
      });
    });
    /* [통합해서 본 것도 표시] 총합계(전체) → 출고장별 소계 → 그 출고장의 차이 품목.
         차이가 큰 출고장부터, 그 안에서도 차이가 큰 품목부터 나온다. */
    var gm={}, gs=[];
    rows.forEach(function(r){
      var e=gm[r.dc];
      if(!e){ e=gm[r.dc]={ dc:r.dc, its:[], oQty:0, sQty:0, d:0, nb:0 }; gs.push(e); }
      e.its.push(r); e.oQty+=(+r.it.oQty||0); e.sQty+=(+r.it.sQty||0); e.d+=r.d;
      if(r.nb) e.nb++;
    });
    gs.forEach(function(e){ e.its.sort(function(a,b){ return Math.abs(b.d)-Math.abs(a.d); }); });
    gs.sort(function(a,b){ return Math.abs(b.d)-Math.abs(a.d) || String(a.dc).localeCompare(String(b.dc),'ko'); });
    /* 품목 줄을 누르면 그 아래에 <출고 원본행>을 펼친다(다시 누르면 접힘) — 눈으로 대사하기 위한 것.
         같은 주문번호(JUMUN_NO)가 출고일자 두 곳에 걸쳐 있으면 재저장 후보라 배지로 표시한다.
         출고 조회가 이미 ordNo·jumunNo·zone·inwh·bizCd·srcFile 을 주므로 서버 변경 없이 만들 수 있다. */
    var list=[];
    gs.forEach(function(e){
      list.push({ t:'g', e:e });
      e.its.forEach(function(r){
        var key='gq:'+r.dc+'|'+r.it.itemCd;
        var col=_ohIsCol2(key, true);
        list.push({ t:'it', r:r, key:key, col:col });
        if(col) return;
        // 정산서 원본행 먼저 — 발주일자(DLV_DT)·출고일자(OUT_DT)를 보여 출고 쪽 날짜와 나란히 대사한다(2026-07-27 요청)
        var sraw=_ohSales.filter(function(x){ return (_ohDcOf(x)||'(출고장 미지정)')===r.dc && (''+(x.itemCd||''))===r.it.itemCd; });
        sraw.sort(function(a,b){ return String(a.dlvDt||'').localeCompare(String(b.dlvDt||'')) || String(a.ordNo||'').localeCompare(String(b.ordNo||'')); });
        sraw.forEach(function(x){ list.push({ t:'sraw', x:x }); });
        var raw=_ohShip.filter(function(x){ return (_ohDcOf(x)||'(출고장 미지정)')===r.dc && (''+(x.itemCd||''))===r.it.itemCd; });
        raw.sort(function(a,b){ return String(a.shpoutDt||'').localeCompare(String(b.shpoutDt||'')) || String(a.zone||'').localeCompare(String(b.zone||'')); });
        var jm={};   // 주문번호별 출고일자 집합 — 2개 이상이면 재저장 후보
        raw.forEach(function(x){ var j=(''+(x.jumunNo||'')).trim(); if(!j) return; (jm[j]=jm[j]||{})[(''+(x.shpoutDt||''))]=1; });
        raw.forEach(function(x){
          var j=(''+(x.jumunNo||'')).trim();
          list.push({ t:'raw', x:x, dup:!!(j && Object.keys(jm[j]||{}).length>1) });
        });
        if(!raw.length) list.push({ t:'none' });
      });
    });

    var RED='color:#c0392b;font-weight:800';
    var h='<table class="logi-tb"><thead><tr><th>출고장</th><th>품목코드</th><th>품목명</th>'
        +'<th style="text-align:right">정산수량</th><th style="text-align:right">출고수량</th>'
        +'<th style="text-align:right" title="정산수량 − 출고수량&#10;+ 정산이 많음 = 청구가 더 됨(과청구·출고기록 누락 후보)&#10;− 출고가 많음 = 보냈는데 청구가 덜 됨(청구 누락 후보)">수량차이<br><span style="font-weight:400;font-size:10.5px">정산−출고</span></th>'
        +'<th style="text-align:right">판매단가</th>'
        +'<th style="text-align:right" title="정산서 금액 + 정산서가 안 온 출고의 추정매출(판매단가).">정산금액</th></tr></thead><tbody>';
    /* [미정산 같이 보기] 스위치 — 합계줄 안에 둔다(표 밖에 두면 페이저가 다시 그릴 때 사라진다) */
    var nbBtn = '<span onclick="ohGapNB()" title="'
      + (_ohGapNB ? '미정산 품목을 숨기고 수량차이만 봅니다'
                  : '정산서에 없는 품목(미정산)까지 같은 표에 섞어 봅니다 — 정산서가 아예 안 온 출고장도 포함')
      + '" style="cursor:pointer;user-select:none;font-weight:700;font-size:11.5px;'
      + 'border:1px solid rgba(255,255,255,.55);border-radius:6px;padding:1px 8px;margin-left:8px;'
      + (_ohGapNB ? 'background:#ffe9c9;color:#7a4b0a' : 'color:#ffe9c9') + '">'
      + (_ohGapNB ? '☑' : '☐') + ' 미정산 같이 보기'+(skipNB?(' '+skipNB+'건'):'')+'</span>';
    h+='<tr class="close-total"><td colspan="3">■ 차이 품목 '+(rows.length-nbN).toLocaleString()+'건'
      +((rows.length-nbN)?(' <span style="font-weight:600">(정산 많음 '+sMore+' · 출고 많음 '+oMore+' · 출고장 '+gs.length+'곳)</span>'):'')
      +(nbN?(' <span style="font-weight:700;font-size:11.5px;color:#ffe9c9">+ 미정산 '+nbN+'건</span>'):'')
      +' <span style="font-weight:600;font-size:11.5px">— 정산서 온 출고장 '+dcN+'곳'+(_ohGapNB?'':' · 정산서에 있는 품목만 대사')+'</span>'
      + nbBtn
      +(skipNB && !_ohGapNB ?('<br><span style="font-weight:600;font-size:11.5px;color:#ffe9c9">※ 정산서에 없는 품목 '+skipNB+'건은 대사 대상이 아니라 제외 — 위 [미정산 같이 보기] 또는 ①탭 상태 칸의 <b>미정산</b>에서 확인</span>'):'')
      +'</td>'
      +'<td style="text-align:right">'+_ohQ(tS)+'</td><td style="text-align:right">'+_ohQ(tO)+'</td>'
      +'<td style="text-align:right">'+_ohQ(tS-tO)+'</td><td></td><td></td></tr>';
    if(!rows.length){
      _ohMount(wrap, h+_ohEmptyRow(8, (dcN ? '수량이 어긋난 품목이 없습니다' : '이 기간 정산서 자료가 없습니다'),
        (dcN
          ? '정산서가 온 출고장 <b>'+dcN+'곳</b>에서 정산서에 있는 품목은 <b>출고수량과 정산수량이 모두 일치</b>합니다.'
            +(skipNB?('<br>정산서에 없는 품목 <b>'+skipNB+'건</b>은 대사 대상이 아니라 제외했습니다 — 위 <b>[미정산 같이 보기]</b>를 누르면 여기 같이 나옵니다(①탭 <b>미정산</b>과 같은 것).'):'')
          : '비교할 정산서가 없어 차이를 낼 수 없습니다.<br>정산 엑셀을 올린 뒤 다시 조회하거나, 정산서가 안 온 건은 ①탭 상태 칸에서 <b>미정산</b>으로 확인하세요.')), [], _ohIdent);
      return;
    }
    // 출고장 소계(통합) 줄 — 빨간색은 품목 줄에만 쓴다(2026-07-27 요청). 소계는 기본 색.
    var gRow=function(e){
      var up=e.d>0;
      return '<tr class="close-grp" style="cursor:default"><td colspan="3">🏭 '+_cesc(e.dc)
        +' <span style="font-weight:600;color:#5a6b7a">(차이 '+(e.its.length-e.nb)+'품목'
        +(e.nb?(' · <span style="color:#c47f17">미정산 '+e.nb+'품목</span>'):'')+')</span></td>'
        +'<td style="text-align:right">'+_ohQ(e.sQty)+'</td><td style="text-align:right">'+_ohQ(e.oQty)+'</td>'
        +'<td style="text-align:right">'+(up?'+':'')+_ohQ(e.d)+'</td><td></td><td></td></tr>';
    };
    // 품목 줄 — 여기만 빨간색. 누르면 아래에 출고 원본행이 펼쳐진다.
    var itRow=function(r, key, col){
      var it=r.it, up=r.d>0;
      /* ★미정산 줄은 **빨강이 아니라 호박색**으로 — '수량이 어긋난 것'과 '아직 청구가 안 된 것'은
           성격이 달라 같은 빨강으로 두면 대사할 것이 뒤섞여 보인다(2026-07-28). */
      var nb=!!r.nb, CLR=nb?'color:#c47f17;font-weight:700':RED;
      // ★펼치기/접기는 <화살표를 눌렀을 때만> 동작한다(2026-07-27 요청) — 줄 전체 클릭은 쓰지 않는다.
      //   품목명·수치를 마우스로 긁어 복사할 때 표가 접히거나 펼쳐지는 것을 막기 위한 것.
      return '<tr'+(nb?' style="background:#fffaf1"':'')+' title="'
        + (nb?'정산서에 이 품목이 없습니다 — 아직 청구가 안 된 것(미정산). 수량차이가 아닙니다'
            : up?'정산이 출고보다 많음 — 과청구·출고기록 누락 여부 확인':'출고가 정산보다 많음 — 청구 누락 여부 확인')+'">'
        + '<td class="txt-l" style="color:#8a95a1">'+_cesc(r.dc)+'</td>'
        + '<td style="'+CLR+'">'
        +   '<span onclick="event.stopPropagation();ohGrp(\''+encodeURIComponent(key)+'\')"'
        +   ' title="'+(col?'출고 원본행 펼치기':'출고 원본행 접기')+'"'
        +   ' style="'+(nb?'color:#c47f17':'color:#c0392b')+';cursor:pointer;display:inline-block;width:20px;text-align:center;'
        +   'user-select:none;-webkit-user-select:none">'+(col?'▶':'▼')+'</span> '
        +   _cesc(it.itemCd)+'</td>'
        // '펼치기/접기' 글자 배지는 제거(2026-07-27 요청) — 줄을 클릭하면 되고, 상태는 왼쪽 캐럿(▶/▼)으로 보인다
        + '<td class="txt-l" style="'+CLR+'">'
        +   (nb?'<span style="font-size:10.5px;border:1px solid #e3c08a;background:#fdf5e6;color:#7a4b0a;'
        +       'border-radius:9px;padding:1px 6px;margin-right:5px;font-weight:700">미정산</span> ':'')
        +   _cesc(it.itemNm)+'</td>'
        + '<td style="text-align:right">'+_ohQ(it.sQty)+'</td>'
        + '<td style="text-align:right">'+_ohQ(it.oQty)+'</td>'
        + '<td style="text-align:right;'+CLR+'">'+(up?'+':'')+_ohQ(r.d)+'</td>'
        + '<td style="text-align:right">'+(it.price==null?'':_cnum(it.price))+'</td>'
        + _ohAmtCell(it)+'</tr>';
    };
    /* 정산서 원본행.
         ★대사는 <납품일자>만 비교한다(2026-07-27 사용자 확정). 출고일자는 정산서와 출고장이 서로 다를 수 있다
           — 김해·제주는 조기출고(납기보다 앞당겨 출고)라 다른 것이 정상이다. 그래서 출고일자는 참고로만
           회색·괄호로 두고, '날짜 다름' 같은 경고 표시는 붙이지 않는다(정상을 오류로 보이게 하므로).
         수량은 <정산수량 칸>에 놓아(출고행은 출고수량 칸) 어느 쪽 자료인지 위치로 구분된다.
         ※ 정산서에는 사업장·주문번호 칸이 없다(출고 자료에만 있음). */
    var srawRow=function(x){
      var ord=(''+(x.ordNo||'')).trim();
      return '<tr style="background:#f4fbf8">'
        + '<td></td>'
        + '<td colspan="2" class="txt-l" style="padding-left:26px;color:#137a6c;font-size:12.5px">'
        //   출고일자도 읽히게 진하게 둔다(2026-07-27) — 대사 기준은 아니지만 조기출고 확인에 자주 본다.
        +   '↳ <b>정산서</b> · 납품일자 <b>'+_cesc(_ohDateFmt(x.dlvDt))+'</b>'
        +   ' <span style="color:#5a6b7a">(출고일자 <b>'+_cesc(_ohDateFmt(x.outDt))+'</b>)</span>'
        + '</td>'
        + '<td style="text-align:right;color:#137a6c;font-weight:700">'+_ohQ(x.outQty)+'</td>'
        + '<td></td>'
        + '<td colspan="3" class="txt-l" style="color:#9aa7b3;font-size:11.5px">'
        +   '발주 '+(ord?_cesc(ord):'<span style="color:#c47f17">없음</span>')
        +   (x.ordItemNo?('-'+_cesc(x.ordItemNo)):'')
        +   (x.ordQty!=null?(' · 발주량 '+_ohQ(x.ordQty)):'')
        +   (x.srcFile?(' · '+_cesc(x.srcFile)):'')
        + '</td></tr>';
    };
    /* 출고 원본행 — 무엇 때문에 차이가 났는지 눈으로 대사하는 줄.
         출고일자·차수 / 입고장·존·사업장 / 수량 / 발주번호·주문번호·원본파일.
         같은 주문번호가 출고일자 두 곳에 있으면 '중복 합산' 배지 — 이게 이중계상의 정체다.
         (날짜를 비교해서 붙이는 게 아니다 — 출고일자 차이는 조기출고라 정상이다.) */
    var rawRow=function(x, dup){
      var inwh=(''+(x.inwh||'')).trim(), zone=(''+(x.zone||'')).trim();
      var biz=(''+(x.bizNm||x.bizCd||'')).trim();
      var ord=(''+(x.ordNo||'')).trim(), jum=(''+(x.jumunNo||'')).trim();
      return '<tr style="background:#fcfdfe">'
        + '<td></td>'
        + '<td colspan="2" class="txt-l" style="padding-left:26px;color:#5a6b7a;font-size:12.5px">'
        //   ★대사 기준은 납품일자뿐이다. 출고일자는 참고 — 코네트에서 김해·제주는 멀어서 미리 출고하므로
        //     정산서의 출고일자와 다른 것이 정상이다(경고로 보이지 않게 회색 괄호로 둔다).
        +   '↳ <b>출고내역</b> · 납품일자 <b>'+_cesc(_ohDateFmt(x.dlvDt))+'</b>'
        +   ' <span style="color:#5a6b7a">(출고일자 <b>'+_cesc(_ohDateFmt(x.shpoutDt))+'</b>'+(x.jobSeq?(' '+x.jobSeq+'차'):'')+')</span>'
        +   (inwh?(' · 입고장 '+_cesc(inwh)):'')+(zone?(' · 존 '+_cesc(zone)):'')+(biz?(' · '+_cesc(biz)):'')
        /* ★배지 문구 주의(2026-07-27) — '재저장 의심'이라고 쓰니 "출고일자가 달라서 오류"로 읽혔다.
             출고일자 차이는 정상이다(김해·제주는 멀어서 미리 출고). 이 배지가 뜻하는 것은
             <같은 주문번호가 서로 다른 배치에 활성으로 남아 출고수량이 두 번 더해졌다>는 것뿐이다.
             그래서 날짜를 가리키지 않는 말('중복 합산')로 바꾸고, 툴팁에 이유를 적는다. */
        +   (dup?' <span title="같은 주문번호가 서로 다른 배치에 활성으로 남아 있어 출고수량이 두 번 더해졌습니다.&#10;'
                 +'※ 출고일자가 다른 것 자체는 정상입니다(김해·제주는 멀어서 미리 출고). 문제는 같은 주문이 두 번 저장된 것입니다."'
                 +' style="font-size:11px;font-weight:700;color:#c0392b;border:1px solid #f0c9c2;background:#fff7f6;border-radius:4px;padding:0 5px;cursor:help">중복 합산</span>':'')
        + '</td>'
        + '<td></td>'
        + '<td style="text-align:right;color:#37475a">'+_ohQ(x.curQty)+'</td>'
        + '<td colspan="3" class="txt-l" style="color:#9aa7b3;font-size:11.5px">'
        +   '발주 '+(ord?_cesc(ord):'<span style="color:#c47f17">없음</span>')
        +   (x.ordItemNo?('-'+_cesc(x.ordItemNo)):'')
        +   ' · 주문 '+(jum?_cesc(jum):'-')
        +   (x.srcFile?(' · '+_cesc(x.srcFile)):'')
        + '</td></tr>';
    };
    _ohMount(wrap, h, list, function(x){
      return x.t==='g'    ? gRow(x.e)
           : x.t==='it'   ? itRow(x.r, x.key, x.col)
           : x.t==='sraw' ? srawRow(x.x)
           : x.t==='raw'  ? rawRow(x.x, x.dup)
           : '<tr style="background:#fcfdfe"><td></td><td colspan="7" class="txt-l" style="padding-left:26px;color:#9aa7b3;font-size:12px">↳ 이 기간 출고 원본행이 없습니다(정산서만 온 건).</td></tr>';
    });
  }

  // 개별 출고장 상태 뱃지 — ①탭 1·2단 공용
  function _ohStBadge(g){
    /* 직접판매(판매등록 전표)는 출고장 발주현황표와 맞출 대상이 아니다.
       출고내역이 없는 게 정상이라 '출고내역 없음'·'출고미상' 을 띄우면 오해를 부른다(2026-07-25). */
    if(g.trx) return '<span class="badge b-done" title="판매등록으로 직접 입력한 매출입니다.&#10;출고장 발주현황표와 대사하는 대상이 아니라 수량차이·출고미상이 잡히지 않습니다.">전표</span>';
    var gap=g.oQty-g.sQty, ok=Math.abs(gap)<1e-6;
    // ★수량 합계만 보면 안 된다 — '정산에만 5개 + 출고에만 5개' 가 상쇄돼 차이 0 이 될 수 있다.
    //   짝 없는 대사키가 하나라도 있으면 '일치'로 부르지 않는다.
    var clean = ok && !g.sOnly && !g.oOnly;
    var st = (!g.sRows) ? '<span class="badge b-wait">정산 미도착</span>'
           : (!g.oRows) ? '<span class="badge b-wait">출고내역 없음</span>'
           : (clean ? '<span class="badge b-done">일치</span>' : '<span class="badge b-ship">차이</span>');
    if(g.oOnly) st+=' <span style="color:#c0392b;font-weight:700;font-size:11.5px" title="보냈는데 정산서에 없는 품목 수(발주일자+출고장+품목코드 기준).&#10;청구 누락 후보입니다. ②탭에서 정산수량이 0인 품목을 보세요.">미정산 '+g.oOnly+'</span>';
    if(g.sOnly) st+=' <span style="color:#a85700;font-weight:700;font-size:11.5px" title="정산서에는 있는데 출고내역에 없는 품목 수.&#10;보낸 적 없는데 청구된 건일 수 있으니 확인이 필요합니다. ②탭에서 출고수량이 0인 품목을 보세요.">출고미상 '+g.sOnly+'</span>';
    return st;
  }
  /* 상태 칸(td) — 여기만 클릭하면 ②탭 드릴다운. 줄 전체를 클릭 대상으로 두면
     숫자를 드래그해 확인하려다 실수로 탭이 바뀌어서, 클릭 영역을 이 칸으로 좁혔다(2026-07-22 요청). */
  function _ohStCell(g){
    return '<td class="oh-st" onclick="ohDrill(\''+encodeURIComponent(g.dc)+'\')"'
      + ' title="클릭 → ② 출고장 ▸ 품목 탭에서 '+_cesc(g.label)+'만 펼쳐 어느 품목이 어긋났는지 봅니다">'
      + _ohStBadge(g)+'</td>';
  }
  // 묶음/일자 머리행의 상태칸 — 표시 전용. 클릭 미적용(접기·드릴 모두 없음).
  //   줄 전체가 접기 토글이라, 이 칸 클릭이 접기로 이어지지 않게 stopPropagation 만 건다.
  function _ohStCellGrp(gg){
    return '<td onclick="event.stopPropagation()" style="cursor:default"'
      + ' title="묶음 합계 상태 (이 칸은 클릭·접기 없음)">'
      + _ohStBadge(gg)+'</td>';
  }
  /* 매출금액 = 정산금액(정산서) + 추정매출(정산서가 안 온 출고 × 판매단가).
     둘을 한 칸에 합쳐 보여준다 — 구분은 상태 칸 뱃지(정산 미도착·미정산 N)로 이미 되고 있다(2026-07-25 요청).
     hover 하면 얼마가 확정이고 얼마가 추정인지 나온다. */
  function _ohAmt(o){ return (+o.sAmt||0) + (+o.eAmt||0); }
  function _ohAmtQ(o){ return (+o.sQty||0) + (+o.eQty||0); }   // 평균단가 분모 — 금액이 잡힌 수량만
  function _ohAmtCell(o, bold){
    var s=(+o.sAmt||0), e=(+o.eAmt||0);
    var tip = e ? ('정산서 '+_cnum(s)+' + 추정 '+_cnum(e)+'&#10;추정 = 정산서가 안 온 출고 × 판매단가(마감관리와 같은 단가)')
                : ('정산서 기준 실제 받을 금액');
    return '<td style="text-align:right;'+(bold?'font-weight:800;':'font-weight:700;')+'color:#137a6c" title="'+tip+'">'
      +_cnum(s+e)+(e?' <span style="color:#a85700;font-weight:600;font-size:11px">추정</span>':'')+'</td>';
  }
  // 숫자 칸 8개(출고건수~정산금액) — ①탭 1·2단 공용
  function _ohDcCells(o){
    var gap=o.oQty-o.sQty, ok=Math.abs(gap)<1e-6, aq=_ohAmtQ(o);
    // 직접판매는 출고 짝이 없는 게 정상 — 수량차이를 숫자로 띄우면 어긋난 것처럼 보인다
    var gapCell = o.trx
      ? '<td style="text-align:right;color:#9aa7b3" title="직접판매 전표라 대사 대상이 아닙니다">—</td>'
      : '<td style="text-align:right" class="'+(ok?'oh-ok':'oh-gap')+'">'+_ohQ(gap)+'</td>';
    return '<td style="text-align:right">'+o.oRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(o.oQty)+'</td>'
      +'<td style="text-align:right">'+o.sRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(o.sQty)+'</td>'
      +gapCell
      +'<td style="text-align:right">'+(aq?_cnum(_ohAmt(o)/aq):'')+'</td>'
      +_ohAmtCell(o,true);
  }
  /* ① 출고장별 합계 — 대시보드처럼 2단 (2026-07-22 사용자 요청)
       1단 = 물류센터 묶음(CLOSE_DCGROUP: 왜관·김해·광주·제주·오산 → 오산센터. 매출마감과 동일 규칙)
       2단 = 개별 출고장 (정산서·거래처가 출고장별이므로 돈은 여기가 기준 — 클릭하면 ②품목 드릴다운)
       묶음이 실제로 생기는 그룹(2곳 이상)만 머리행을 만들고, 용인·평택처럼 혼자인 곳은 그냥 한 줄.
       접기키 'd:' + 그룹라벨, 기본 = 펼침(개별 출고장·상태가 바로 보이는 게 이 표의 목적이라). */
  function _ohRenderDc(G, wrap, oQ, sQ, sA){
    // 출고장 칸 넓히기(2026-07-27) — 머리글(th)은 그대로 두고 자료칸(tbody td)에만 최소폭을 준다.
    //   테이블 클래스 oh-dc 로 이 표만 겨냥한다(.logi-tb 는 다른 표와 공용이라 전역으로 주면 안 된다).
    var h='<table class="logi-tb oh-dc"><thead><tr><th>출고장</th>'
        +'<th style="text-align:right">출고건수</th><th style="text-align:right">출고수량</th>'
        +'<th style="text-align:right">정산행수</th><th style="text-align:right">정산수량</th>'
        +'<th style="text-align:right">수량차이</th><th style="text-align:right">평균단가</th>'
        +'<th style="text-align:right" title="정산서 금액 + 정산서가 안 온 출고의 추정매출(판매단가). 추정이 섞인 줄에는 &quot;추정&quot; 표시가 붙습니다.">정산금액(받을 금액)</th><th>상태</th></tr></thead><tbody>';
    var T={ sAmt:0, eAmt:0, sQty:sQ, eQty:0 };   // 총합계 줄도 개별 줄과 같은 셀 함수를 쓴다
    var tQ2=0;                                    // 직접판매 정산수량 — 총합계 수량차이에서 뺀다
    G.forEach(function(g){ T.sAmt+=(+g.sAmt||0); T.eAmt+=(+g.eAmt||0); T.eQty+=(+g.eQty||0); if(g.trx) tQ2+=(+g.sQty||0); });
    h+='<tr class="close-total"><td>■ 총합계</td>'
      +'<td style="text-align:right">'+_ohShip.length.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(oQ)+'</td>'
      +'<td style="text-align:right">'+_ohSales.length.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(sQ)+'</td>'
      +'<td style="text-align:right">'+_ohQ(oQ-(sQ-tQ2))+'</td>'
      +'<td style="text-align:right">'+(_ohAmtQ(T)?_cnum(_ohAmt(T)/_ohAmtQ(T)):'')+'</td>'
      +_ohAmtCell(T,true)+'<td></td></tr>';
    // 지역명 → 대시보드 그룹 (KONET_DC_R 로 코드 환원 후 CLOSE_DCGROUP 조회 — 매핑 원천 재사용)
    //   ②③④와 같이 표시행을 배열(R)에 모은다 — 18행씩 자동 스크롤로 붙이려면 행이 낱개로 있어야 한다
    var R=[], GM={}, GL=[];
    G.forEach(function(g){
      var lbl = _ohDcGrp(g.dc);
      // eQty/eAmt(추정분)도 반드시 같이 더한다 — 빠뜨리면 묶음 머리행만 정산분으로 표시돼 하위 합과 안 맞는다
      var gg=GM[lbl]; if(!gg){ gg=GM[lbl]={ label:lbl, kids:[], oRows:0, oQty:0, sRows:0, sQty:0, sAmt:0, eQty:0, eAmt:0, sOnly:0, oOnly:0 }; GL.push(gg); }
      gg.kids.push(g); gg.oRows+=g.oRows; gg.oQty+=g.oQty; gg.sRows+=g.sRows; gg.sQty+=g.sQty; gg.sAmt+=g.sAmt;
      gg.eQty+=(+g.eQty||0); gg.eAmt+=(+g.eAmt||0); gg.sOnly+=g.sOnly; gg.oOnly+=g.oOnly;
      if(g.trx) gg.trx=true;   // 묶음 머리행도 '전표' 로 — 하위가 직접판매면 대사 대상이 아니다
    });
    GL.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    // 줄 전체가 아니라 '상태' 칸을 눌렀을 때만 ②탭으로 이동한다(2026-07-22 요청) — 실수 이동 방지
    var kidRow=function(g, indent){
      return '<tr title="원표기: '+_cesc(Object.keys(g.raw).join(' / '))+'">'
        +'<td class="txt-l"'+(indent?' style="padding-left:26px"':'')+'><b>'+_cesc(_ohDcLabel(g))+'</b>'+ohDcFixBtn(g)+'</td>'
        +_ohDcCells(g)+_ohStCell(g)+'</tr>';
    };
    GL.forEach(function(gg){
      if(gg.kids.length<2){ R.push(kidRow(gg.kids[0], false)); return; }   // 혼자인 곳은 묶음 머리 없이 한 줄
      var col=_ohIsCol2('d:'+gg.label, false);   // 기본 펼침
      // 묶음 머리행은 클릭=접기/펼치기. 상태 칸은 그 자체가 클릭 대상이 아니므로 뱃지만 표시
      R.push('<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d:'+gg.label)+'\')" title="클릭 → 소속 출고장 '+gg.kids.length+'곳 접기/펼치기">'
        +'<td><span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(gg.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+gg.kids.length+'곳)</span></td>'
        +_ohDcCells(gg)+_ohStCellGrp(gg)+'</tr>');
      if(!col) gg.kids.forEach(function(g){ R.push(kidRow(g, true)); });
    });
    // ── 일자별 (최근순) 구획 — 원래 기간합(위) 다음에 배치. 기본 접힘, 캐럿으로 펼치기(2026-07-24 요청)
    //     날짜 머리행 = 접기/펼치기(캐럿). 상태 칸은 클릭 미적용(_ohStCellGrp). 개별 출고장은 드릴 가능(_ohStCell).
    var DBYD=_ohRollByDate();
    if(DBYD.length){
      var dsecCol=_ohIsCol2('dtsec', true);   // 구획 전체 = 기본 접힘
      R.push('<tr class="close-grp" onclick="ohGrp(\'dtsec\')" title="클릭 → 일자별 구획 접기/펼치기">'
        +'<td colspan="9"><span class="ccar">'+(dsecCol?'▶':'▼')+'</span> 📅 <b>일자별 합계</b>'
        +' <span style="font-weight:600;color:#5a6b7a">(최근순 · '+DBYD.length+'일 · 납품일자 기준'+(dsecCol?' · 접힘, 클릭해 펼치기':'')+')</span></td></tr>');
      if(!dsecCol) DBYD.forEach(function(D){
        var dk='dt:'+D.date, dCol=_ohIsCol2(dk, false), dgap=D.tot.oQty-D.tot.sQty;
        R.push('<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent(dk)+'\')" title="클릭 → '+_ohDateFmt(D.date)+' 소속 출고장 접기/펼치기">'
          +'<td style="padding-left:22px"><span class="ccar">'+(dCol?'▶':'▼')+'</span> 🗓️ '+_ohDateFmt(D.date)
          +' <span style="font-weight:600;color:#5a6b7a">('+D.kids.length+'곳)</span></td>'
          +'<td style="text-align:right">'+D.tot.oRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(D.tot.oQty)+'</td>'
          +'<td style="text-align:right">'+D.tot.sRows.toLocaleString()+'</td><td style="text-align:right">'+_ohQ(D.tot.sQty)+'</td>'
          +'<td style="text-align:right" class="'+(Math.abs(dgap)<1e-6?'oh-ok':'oh-gap')+'">'+_ohQ(dgap)+'</td>'
          +'<td style="text-align:right">'+(_ohAmtQ(D.tot)?_cnum(_ohAmt(D.tot)/_ohAmtQ(D.tot)):'')+'</td>'
          +_ohAmtCell(D.tot,true)
          +_ohStCellGrp(D.tot)+'</tr>');
        if(!dCol) D.kids.forEach(function(g){
          R.push('<tr title="원표기: '+_cesc(Object.keys(g.raw).join(' / '))+'">'
            +'<td class="txt-l" style="padding-left:40px"><b>'+_cesc(_ohDcLabel(g))+'</b></td>'
            +_ohDcCells(g)+_ohStCell(g)+'</tr>');
        });
      });
    }
    _ohMount(wrap, h, R, _ohIdent);
  }

  /* ② 출고장 ▸ 품목 (그룹 접기/펼치기 + 소계)
     표시행을 평평하게(list) 늘어놓고 _ohMount 에 넘긴다 — 18행씩 이어붙이는 일은 거기서.
     ※ 예전 페이저 때 있던 '페이지가 그룹 중간에서 시작하면 소속 헤더를 문맥으로 먼저 찍기'는 뺐다.
       이어붙이기는 끊김 없이 연속이라 머리행이 이미 위에 있다(중복으로 두 번 찍히는 문제만 생긴다). */
  function _ohRenderItem(G, wrap, oQ, sQ, sA){
    var h='<table class="logi-tb"><thead><tr><th>품목코드</th><th>품목명</th>'
        +'<th style="text-align:right">출고수량</th><th style="text-align:right">정산수량</th>'
        +'<th style="text-align:right">수량차이</th><th style="text-align:right">판매단가</th>'
        +'<th style="text-align:right" title="정산서 금액 + 정산서가 안 온 출고의 추정매출(판매단가).">정산금액</th></tr></thead><tbody>';
    var T={ sAmt:0, eAmt:0, sQty:sQ, eQty:0 };
    G.forEach(function(g){ T.sAmt+=(+g.sAmt||0); T.eAmt+=(+g.eAmt||0); T.eQty+=(+g.eQty||0); });
    h+='<tr class="close-total"><td colspan="2">■ 총합계</td>'
      +'<td style="text-align:right">'+_ohQ(oQ)+'</td><td style="text-align:right">'+_ohQ(sQ)+'</td>'
      +'<td style="text-align:right">'+_ohQ(oQ-sQ)+'</td><td></td>'
      +_ohAmtCell(T,true)+'</tr>';
    // 표시행 평면화 (접힘 반영) — 1단 물류센터 묶음(d2:) → 2단 출고장(i:) → 품목. 묶음이 2곳 이상일 때만 머리행
    var L0s=[], lm={};
    G.forEach(function(g,gi){
      var lbl=_ohDcGrp(g.dc);
      var e=lm[lbl]; if(!e){ e=lm[lbl]={ label:lbl, gis:[], oQty:0, sQty:0, sAmt:0, eQty:0, eAmt:0, items:0 }; L0s.push(e); }
      e.gis.push(gi); e.oQty+=g.oQty; e.sQty+=g.sQty; e.sAmt+=g.sAmt; e.eQty+=g.eQty; e.eAmt+=g.eAmt; e.items+=g.itemOrd.length;
    });
    L0s.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    var sorted=[], list=[];
    L0s.forEach(function(e){
      var multi=e.gis.length>1;
      if(multi){ list.push({t:'G',e:e}); if(_ohIsCol2('d2:'+e.label,false)) return; }
      e.gis.forEach(function(gi){
        var g=G[gi];
        sorted[gi]=g.itemOrd.slice().sort(function(a,b){ return a.localeCompare(b,'ko'); });
        list.push({t:'g',gi:gi,e:multi?e:null});
        if(_ohIsCol(g.dc)) return;
        sorted[gi].forEach(function(k){ list.push({t:'it',gi:gi,k:k,e:multi?e:null}); });
      });
    });
    var L0Row=function(e){
      var col=_ohIsCol2('d2:'+e.label,false), gap=e.oQty-e.sQty;
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d2:'+e.label)+'\')"><td colspan="2">'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(e.label)+' <span style="font-weight:600;color:#5a6b7a">('+e.gis.length+'곳 · '+e.items+'품목)</span></td>'
        +'<td style="text-align:right">'+_ohQ(e.oQty)+'</td><td style="text-align:right">'+_ohQ(e.sQty)+'</td>'
        +'<td style="text-align:right" class="'+(Math.abs(gap)<1e-6?'oh-ok':'oh-gap')+'">'+_ohQ(gap)+'</td><td></td>'
        +_ohAmtCell(e)+'</tr>';
    };
    var grpRow=function(gi, ind){
      var g=G[gi], col=_ohIsCol(g.dc), gap=g.oQty-g.sQty;
      return '<tr class="close-sub" style="cursor:pointer" onclick="ohGrp(\''+encodeURIComponent('i:'+g.dc)+'\')"><td colspan="2"'+(ind?' style="padding-left:24px"':'')+'>'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🏭 '+_cesc(g.label)+' <span style="font-weight:600;color:#5a6b7a">('+g.itemOrd.length+'품목)</span></td>'
        +'<td style="text-align:right">'+_ohQ(g.oQty)+'</td><td style="text-align:right">'+_ohQ(g.sQty)+'</td>'
        +'<td style="text-align:right" class="'+(Math.abs(gap)<1e-6?'oh-ok':'oh-gap')+'">'+_ohQ(gap)+'</td><td></td>'
        +_ohAmtCell(g)+'</tr>';
    };
    var itRow=function(gi,k){
      var it=G[gi].items[k], d=it.oQty-it.sQty, dok=Math.abs(d)<1e-6;
      return '<tr><td>'+_cesc(it.itemCd)+'</td><td class="txt-l">'+_cesc(it.itemNm)+'</td>'
        +'<td style="text-align:right">'+_ohQ(it.oQty)+'</td>'
        +'<td style="text-align:right;'+(it.sQty<0?'color:#c0392b':'')+'">'+_ohQ(it.sQty)+'</td>'
        +'<td style="text-align:right" class="'+(dok?'':'oh-gap')+'">'+(dok?'':_ohQ(d))+'</td>'
        +'<td style="text-align:right">'+(it.price==null?'':_cnum(it.price))+'</td>'
        +_ohAmtCell(it)+'</tr>';
    };
    _ohMount(wrap, h, list, function(r){
      return (r.t==='G') ? L0Row(r.e) : (r.t==='g') ? grpRow(r.gi, !!r.e) : itRow(r.gi,r.k);
    });
  }

  // 한쪽 원천이 통째로 없을 때 — 빈 표 대신 왜 비었는지 알려준다
  function _ohEmptyRow(cols, title, desc){
    return '<tr><td colspan="'+cols+'" style="padding:34px 16px;text-align:center;color:#5a6b7a;background:#fbfcfc">'
      +'<div style="font-size:13.5px;font-weight:800;color:#c47f17;margin-bottom:6px">'+title+'</div>'
      +'<div style="font-size:12.5px;line-height:1.7">'+desc+'</div></td></tr>';
  }
  /* ④ 정산서 원본(엑셀) — 출고장별로 묶고 접기/펼치기 + 소계 (②③과 동일한 방식)
       ★출고수량 소계는 '행별 값의 합'이 아니라 '대사키 distinct 합'이다.
         정산서 2행이 같은 (발주일자·출고장·품목)이면 두 행 모두 같은 출고합계를 표시하므로
         그대로 더하면 이중계상된다. used 로 키당 1회만 더한다. */
  function _ohRenderSettle(wrap, sQ, sA){
    var idx=_ohIndex(_ohShip,'curQty');
    var h='<table class="logi-tb"><thead><tr><th>납품일자</th><th>출고장</th><th>발주번호</th><th>항번</th><th>품목코드</th><th>품목명</th>'
        +'<th style="text-align:right">발주량</th><th style="text-align:right">정산수량</th>'
        +'<th style="text-align:right">출고수량</th>'
        +'<th style="text-align:right">판매단가</th><th style="text-align:right">정산금액</th><th>원본파일</th></tr></thead><tbody>';
    if(!_ohSales.length){
      h+='<tr class="close-total"><td colspan="6">■ 총합계</td><td></td>'
        +'<td style="text-align:right">'+_ohQ(sQ)+'</td><td></td><td></td>'
        +'<td style="text-align:right">'+_cnum(sA)+'</td><td></td></tr>';
      _ohMount(wrap, h+_ohEmptyRow(12, '이 기간 정산서(엑셀) 자료가 없습니다',
        '이 탭은 <b>출고장이 보내준 정산 엑셀의 원본 행</b>을 그대로 보여줍니다.<br>'
        +'조회기간에 저장된 정산서가 없어 띄울 행이 없습니다'
        +(_ohShip.length ? ' — 출고는 <b>'+_ohShip.length.toLocaleString()+'행</b> 있으니 <b>정산서가 아직 안 온 날</b>입니다.' : '.')
        +'<br>위 <b>📥 정산 엑셀</b> 로 해당 날짜 파일을 올리면 여기에 채워집니다.'), [], _ohIdent);
      return;
    }
    // 출고장별로 묶기
    var S=[], sm={}, tO=0, tUsed={};
    _ohSales.forEach(function(r){
      var k=_ohDcOf(r)||'(출고장 미지정)';
      var g=sm[k]; if(!g){ g=sm[k]={ dc:k, label:k, rows:[], sQty:0, sAmt:0, oQty:0, miss:0, used:{} }; S.push(g); }
      g.rows.push(r); g.sQty+=(+r.outQty||0); g.sAmt+=(+r.saleAmt||0);
      var kk=_ohKey(r), hit=kk?idx[kk]:null;
      if(hit){
        if(!g.used[kk]){ g.used[kk]=1; g.oQty+=hit.q; }
        if(!tUsed[kk]){ tUsed[kk]=1; tO+=hit.q; }
      } else g.miss++;
    });
    S.sort(function(a,b){ return a.dc.localeCompare(b.dc,'ko'); });
    h+='<tr class="close-total"><td colspan="6">■ 총합계</td><td></td>'
      +'<td style="text-align:right">'+_ohQ(sQ)+'</td>'
      +'<td style="text-align:right">'+_ohQ(tO)+'</td><td></td>'
      +'<td style="text-align:right">'+_cnum(sA)+'</td><td></td></tr>';
    // 표시행 평면화 (3단: 물류센터 묶음(d4:) → 출고장(t:) → 정산행. 접힘 반영. 묶음이 2곳 이상일 때만 머리행)
    var L0s=[], lm={};
    S.forEach(function(g,gi){
      var lbl=_ohDcGrp(g.dc);
      var e=lm[lbl]; if(!e){ e=lm[lbl]={ label:lbl, gis:[], rowsN:0, sQty:0, sAmt:0, oQty:0, miss:0 }; L0s.push(e); }
      e.gis.push(gi); e.rowsN+=g.rows.length; e.sQty+=g.sQty; e.sAmt+=g.sAmt; e.oQty+=g.oQty; e.miss+=g.miss;
    });
    L0s.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    var list=[];
    L0s.forEach(function(e){
      var multi=e.gis.length>1;
      if(multi){ list.push({t:'G',e:e}); if(_ohIsCol2('d4:'+e.label,false)) return; }
      e.gis.forEach(function(gi){
        var g=S[gi];
        list.push({t:'g',gi:gi,e:multi?e:null});
        if(_ohIsCol2('t:'+g.dc, _ohAllCol)) return;
        g.rows.forEach(function(r,ri){ list.push({t:'r',gi:gi,ri:ri,e:multi?e:null}); });
      });
    });
    var L0Row=function(e){
      var col=_ohIsCol2('d4:'+e.label,false);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d4:'+e.label)+'\')"><td colspan="6">'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(e.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+e.gis.length+'곳 · '+e.rowsN.toLocaleString()+'행)</span>'
        +(e.miss?' <span style="font-weight:700;color:#c0392b">· 출고미상 '+e.miss+'</span>':'')+'</td>'
        +'<td></td><td style="text-align:right">'+_ohQ(e.sQty)+'</td>'
        +'<td style="text-align:right">'+_ohQ(e.oQty)+'</td><td></td>'
        +'<td style="text-align:right">'+_cnum(e.sAmt)+'</td><td></td></tr>';
    };
    var grpRow=function(gi, ind){
      var g=S[gi], col=_ohIsCol2('t:'+g.dc, _ohAllCol);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('t:'+g.dc)+'\')"><td colspan="6"'+(ind?' style="padding-left:24px"':'')+'>'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🏭 '+_cesc(g.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+g.rows.length.toLocaleString()+'행)</span>'
        +(g.miss?' <span style="font-weight:700;color:#c0392b" title="출고내역에 짝이 없는 정산행(보낸 적 없는데 청구된 건일 수 있음)">· 출고미상 '+g.miss+'</span>':'')+'</td>'
        +'<td></td><td style="text-align:right">'+_ohQ(g.sQty)+'</td>'
        +'<td style="text-align:right">'+_ohQ(g.oQty)+'</td><td></td>'
        +'<td style="text-align:right">'+_cnum(g.sAmt)+'</td><td></td></tr>';
    };
    var detRow=function(gi,ri){
      var r=S[gi].rows[ri], k=_ohKey(r), m=k?idx[k]:null, oq=m?m.q:null;
      return '<tr><td>'+_cesc(r.dlvDt)+'</td><td>'+_cesc(r.dcNm)+'</td><td>'+_cesc(r.ordNo)+'</td><td>'+_cesc(r.ordItemNo)+'</td>'
        +'<td>'+_cesc(r.itemCd)+'</td><td class="txt-l">'+_cesc(r.itemNm)+'</td>'
        +'<td style="text-align:right">'+(r.ordQty==null?'':_ohQ(r.ordQty))+'</td>'
        +'<td style="text-align:right;'+((+r.outQty||0)<0?'color:#c0392b':'')+'">'+(r.outQty==null?'':_ohQ(r.outQty))+'</td>'
        +'<td style="text-align:right" title="같은 발주일자·출고장·품목코드의 출고 합계입니다(사업장 여러 곳이면 합쳐진 값).">'
        +(oq==null?'<span style="color:#c0392b">출고미상</span>':_ohQ(oq))+'</td>'
        +'<td style="text-align:right">'+_cnum(r.salePrice)+'</td>'
        +'<td style="text-align:right;font-weight:700;color:#137a6c">'+_cnum(r.saleAmt)+'</td>'
        +'<td class="txt-l" style="color:#9aa7b3">'+_cesc(r.srcFile)+'</td></tr>';
    };
    _ohMount(wrap, h, list, function(x){
      return (x.t==='G') ? L0Row(x.e) : (x.t==='g') ? grpRow(x.gi, !!x.e) : detRow(x.gi,x.ri);
    });
  }


  /* ④ 출고장 ▸ 사업장 — ②(품목축)와 겹치지 않는 유일한 축.
     정산서에 없는 '어느 점포로 나갔나'를 세우고, 사업장을 펼치면 출고 원본행이 나온다. */
  function _ohRenderShip(wrap, oQ){
    var h='<table class="logi-tb"><thead><tr><th>사업장 / 품목</th><th>품목코드</th><th>발주번호</th><th>항번</th><th>출고일자</th>'
        +'<th style="text-align:right">출고수량</th><th>정산 대사</th></tr></thead><tbody>';
    if(!_ohShip.length){
      _ohMount(wrap, h+_ohEmptyRow(7, '이 기간 출고내역(발주현황표) 자료가 없습니다',
        '이 탭은 출고를 <b>출고장 ▸ 사업장(점포)</b> 으로 묶어, 어느 점포로 얼마나 나갔는지 보여줍니다.<br>'
        +'조회기간에 저장된 출고가 없어 띄울 행이 없습니다'
        +(_ohSales.length ? ' — 정산서는 <b>'+_ohSales.length.toLocaleString()+'행</b> 있으니 <b>발주현황표가 아직 안 올라온 날</b>입니다.' : '.')
        +'<br>기간은 <b>납품일자(=발주일자)</b> 기준입니다.'), [], _ohIdent);
      return;
    }
    var B=_ohRollBiz(), tT={hit:0,unpaid:0,noKey:0};
    B.forEach(function(g){ tT.hit+=g.hit; tT.unpaid+=g.unpaid; tT.noKey+=g.noKey; });
    h+='<tr class="close-total"><td colspan="5">■ 총합계 <span style="font-weight:600" title="사업장별 정산금액은 만들지 않습니다. 정산서는 발주 단위, 출고는 발주×사업장 단위라 쪼개면 추정이 됩니다. 금액은 ①②탭에서 보세요.">(출고수량 전용 · 금액은 ①②탭)</span></td>'
      +'<td style="text-align:right">'+_ohQ(oQ)+'</td><td>'+_ohStat(tT)+'</td></tr>';
    // 표시행 평면화 (4단: 물류센터 묶음(d3:) → 출고장(s:) → 사업장(b:) → 출고 원본행. 접힘 반영. 묶음이 2곳 이상일 때만 머리행)
    var L0s=[], lm={};
    B.forEach(function(g,gi){
      var lbl=_ohDcGrp(g.dc);
      var e=lm[lbl]; if(!e){ e=lm[lbl]={ label:lbl, gis:[], oRows:0, oQty:0, hit:0, unpaid:0, noKey:0, bizN:0 }; L0s.push(e); }
      e.gis.push(gi); e.oRows+=g.oRows; e.oQty+=g.oQty; e.hit+=g.hit; e.unpaid+=g.unpaid; e.noKey+=g.noKey; e.bizN+=g.bizOrd.length;
    });
    L0s.sort(function(a,b){ return a.label.localeCompare(b.label,'ko'); });
    var list=[];
    L0s.forEach(function(e){
      var multi=e.gis.length>1;
      if(multi){ list.push({t:'G',e:e}); if(_ohIsCol2('d3:'+e.label,false)) return; }
      e.gis.forEach(function(gi){
        var g=B[gi];
        list.push({t:'g',gi:gi,e:multi?e:null});
        if(_ohIsCol2('s:'+g.dc, _ohAllCol)) return;
        g.bizOrd.forEach(function(bk,bi){
          list.push({t:'b',gi:gi,bi:bi,e:multi?e:null});
          if(_ohIsCol2('b:'+g.dc+'|'+bk, true)) return;          // 사업장 하위(원본행)는 기본 접힘
          g.biz[bk].rows.forEach(function(x,xi){ list.push({t:'r',gi:gi,bi:bi,xi:xi,e:multi?e:null}); });
        });
      });
    });
    var L0Row=function(e){
      var col=_ohIsCol2('d3:'+e.label,false);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent('d3:'+e.label)+'\')"><td colspan="5">'
        +'<span class="ccar">'+(col?'▶':'▼')+'</span> 🗂️ '+_cesc(e.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+e.gis.length+'곳 · '+e.bizN+'개 사업장 · '+e.oRows.toLocaleString()+'행)</span></td>'
        +'<td style="text-align:right">'+_ohQ(e.oQty)+'</td><td>'+_ohStat(e)+'</td></tr>';
    };
    var grpRow=function(gi, ind){
      var g=B[gi], gk='s:'+g.dc, gcol=_ohIsCol2(gk, _ohAllCol);
      return '<tr class="close-grp" onclick="ohGrp(\''+encodeURIComponent(gk)+'\')"><td colspan="5"'+(ind?' style="padding-left:24px"':'')+'>'
        +'<span class="ccar">'+(gcol?'▶':'▼')+'</span> 🏭 '+_cesc(g.label)
        +' <span style="font-weight:600;color:#5a6b7a">('+g.bizOrd.length+'개 사업장 · '+g.oRows.toLocaleString()+'행)</span></td>'
        +'<td style="text-align:right">'+_ohQ(g.oQty)+'</td><td>'+_ohStat(g)+'</td></tr>';
    };
    var bizRow=function(gi,bi,ind){
      var g=B[gi], bk=g.bizOrd[bi], b=g.biz[bk], bcol=_ohIsCol2('b:'+g.dc+'|'+bk, true);
      return '<tr class="close-sub" style="cursor:pointer" onclick="ohGrp(\''+encodeURIComponent('b:'+g.dc+'|'+bk)+'\')">'
        +'<td class="txt-l" style="padding-left:'+(ind?44:24)+'px"><span class="ccar">'+(bcol?'▶':'▼')+'</span> 🏢 '+_cesc(b.bizNm)
        +' <span style="font-weight:600;color:#5a6b7a">('+b.rows.length+'행)</span></td>'
        +'<td colspan="4" style="color:#9aa7b3">'+_cesc(b.bizCd)+'</td>'
        +'<td style="text-align:right">'+_ohQ(b.oQty)+'</td><td>'+_ohStat(b)+'</td></tr>';
    };
    var detRow=function(gi,bi,xi,ind){
      var g=B[gi], x=g.biz[g.bizOrd[bi]].rows[xi], r=x.r;
      // 이 행의 (발주일자·출고장·품목코드)가 정산서에 있느냐 — 사실만 표시(사업장별 금액 배분은 하지 않는다)
      var st = x.hit ? '<span style="color:#137a6c;font-weight:700" title="이 행의 발주일자·출고장·품목코드가 정산서에 있습니다.&#10;금액은 품목 합계 단위라 ①②탭에서 보세요.">대사됨</span>'
                     : (x.k ? '<span style="color:#c0392b;font-weight:700" title="보냈는데 정산서에 이 발주일자·출고장·품목이 없습니다 — 청구 누락 후보.">미정산</span>'
                            : '<span style="color:#9aa7b3" title="발주일자·출고장·품목코드 중 빈 칸이 있어 키가 서지 않습니다(정상 자료에는 없습니다).">키없음</span>');
      return '<tr><td class="txt-l" style="padding-left:'+(ind?66:46)+'px">'+_cesc(r.itemNm)+'</td>'
        +'<td>'+_cesc(r.itemCd)+'</td>'
        +'<td>'+(_cesc(r.ordNo)||'<span style="color:#c9d2d0">—</span>')+'</td><td>'+_cesc(r.ordItemNo)+'</td>'
        +'<td>'+_cesc(r.shpoutDt)+(_ohYmd(r.shpoutDt)!==_ohYmd(r.dlvDt)?' <span style="color:#c47f17" title="발주일자 '+_cesc(r.dlvDt)+' — 먼 지역은 하루 당겨 출고합니다">*</span>':'')+'</td>'
        +'<td style="text-align:right">'+_ohQ(r.curQty)+'</td>'
        +'<td>'+st+'</td></tr>';
    };
    _ohMount(wrap, h, list, function(r2){
      return (r2.t==='G') ? L0Row(r2.e)
           : (r2.t==='g') ? grpRow(r2.gi, !!r2.e)
           : (r2.t==='b') ? bizRow(r2.gi,r2.bi, !!r2.e)
           : detRow(r2.gi,r2.bi,r2.xi, !!r2.e);
    });
  }

  /* ══ 표 공통 — N행씩 보여주고 나머지는 스크롤로 자동 이어붙이기(무한 스크롤) ══════════
       쓰는 곳 : 매출내역 4탭(18행) · 재고현황 ①품목별 현재고(10행)
       화면 쪽에서는 '표시행 목록(list)'과 '행 하나를 HTML 로 만드는 함수(rowFn)'만 넘긴다.
       행을 만드는 규칙(그룹 머리행·소계·접기 등)은 화면마다 그대로 두고, 자르고 이어붙이는 일만 여기서 한다.
         lzMount : 머리 N행을 찍고 스크롤 감시를 건다
         lzFill  : 다음 N행을 tbody 에 이어붙인다 (바닥 가까이 오면 자동 호출)
         lzFit   : 표 높이를 N행에 맞춘다 (창이 낮으면 뷰포트에서 자름 — 페이지 스크롤이 생기면 안 된다)
       ※ 페이지 버튼은 없앴다. 대신 하단에 '몇 행까지 나왔는지'와 [모두 표시]를 둔다
         (Ctrl+F 검색·전체 드래그 복사에는 전부 펼쳐야 하므로 수단은 남겨 둔다).
       ※ 상태(_lz)는 표 컨테이너에 붙여 둔다 — 화면마다 표가 따로 살아 있어야 하므로 전역 하나로는 안 된다. */
  function lzIdent(s){ return s; }   // list 가 이미 행 HTML 문자열인 표(①탭·재고현황)용
  function lzMount(o){               // {wrap, pager, head, list, rowFn, rows, capTop}
    var wrap=(typeof o.wrap==='string')?document.getElementById(o.wrap):o.wrap; if(!wrap) return;
    var rows=o.rows||KONET_GRID_ROWS, list=o.list||[], rowFn=o.rowFn||lzIdent;
    var n=Math.min(rows, list.length), body='';
    for(var i=0;i<n;i++) body+=rowFn(list[i]);
    wrap.innerHTML=o.head+body+'</tbody></table>';
    wrap._lz={ list:list, from:n, rowFn:rowFn, rows:rows, pager:o.pager||'', capTop:o.capTop||214 };
    lzFit(wrap); lzBind(wrap);
    // N행이 표 높이보다 짧으면(행이 얇거나 창이 큰 경우) 스크롤이 안 생겨 영영 안 채워진다 — 찰 때까지 미리 붙인다
    for(var g=0; wrap._lz.from<list.length && wrap.scrollHeight<=wrap.clientHeight+2 && g<200; g++) lzFill(wrap);
    lzInfo(wrap);
  }
  function lzFit(wrap){
    var z=wrap._lz; if(!z) return;
    var cap=Math.max(240, window.innerHeight-z.capTop);   // 창을 벗어나면 안 됨
    var tb=wrap.querySelector('table');
    if(!tb){ wrap.style.maxHeight=cap+'px'; return; }
    // 행 높이가 종류마다 달라(그룹 머리행·설명행) 계산하지 않고 실측한다. +1 = 맨 위 '■ 총합계' 줄
    var px=(tb.tHead?tb.tHead.offsetHeight:0), rs=(tb.tBodies[0]?tb.tBodies[0].rows:[]);
    for(var i=0;i<rs.length && i<=z.rows;i++) px+=rs[i].offsetHeight;
    wrap.style.maxHeight=Math.min(px+2, cap)+'px';
  }
  function lzFill(wrap){
    var z=wrap&&wrap._lz; if(!z || z.from>=z.list.length) return;
    var tb=wrap.querySelector('tbody'); if(!tb){ wrap._lz=null; return; }
    var to=Math.min(z.from+z.rows, z.list.length), s='';
    for(var i=z.from;i<to;i++) s+=z.rowFn(z.list[i]);
    tb.insertAdjacentHTML('beforeend', s);
    z.from=to; lzInfo(wrap);
  }
  function lzShowAll(id){   // [모두 표시] — 남은 행을 한 번에 (검색·복사용)
    var wrap=document.getElementById(id), z=wrap&&wrap._lz; if(!z || z.from>=z.list.length) return;
    var tb=wrap.querySelector('tbody'); if(!tb) return;
    var s=''; for(var i=z.from;i<z.list.length;i++) s+=z.rowFn(z.list[i]);
    tb.insertAdjacentHTML('beforeend', s); z.from=z.list.length; lzInfo(wrap);
  }
  function lzBind(wrap){
    if(wrap._lzBound) return; wrap._lzBound=1;   // 컨테이너는 그대로 있고 안쪽만 갈리므로 한 번만 건다
    wrap.addEventListener('scroll', function(){
      var z=wrap._lz; if(!z || z.from>=z.list.length) return;
      if(wrap.scrollTop+wrap.clientHeight >= wrap.scrollHeight-60) lzFill(wrap);   // 바닥 60px 전에 미리 채운다
    });
    window.addEventListener('resize', function(){ if(wrap._lz && wrap.querySelector('table')) lzFit(wrap); });
  }
  function lzInfo(wrap){
    var z=wrap._lz; if(!z || !z.pager) return;
    var pg=document.getElementById(z.pager); if(!pg) return;
    var tot=z.list.length, shown=Math.min(z.from, tot);
    if(z.from>=tot){ pg.innerHTML = tot>z.rows
        ? '<span style="color:#9aa7b3;font-size:12px">총 '+tot.toLocaleString()+'행 — 모두 표시됨</span>' : '';
      return; }
    pg.innerHTML='<span style="color:#5a6b7a;font-size:12px">'+shown.toLocaleString()+' / <b>'+tot.toLocaleString()+'</b>행'
      +' <span style="color:#9aa7b3">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
      +' <button type="button" onclick="lzShowAll(\''+wrap.id+'\')" style="margin-left:8px" title="남은 행을 한 번에 펼칩니다(검색·복사용)">모두 표시</button>';
  }
  // 매출내역 4탭 — 위 공통 표에 얹기 (호출부는 list/rowFn 만 넘긴다)
  function _ohIdent(s){ return s; }
  function _ohMount(wrap, head, list, rowFn){
    lzMount({ wrap:wrap, pager:'ohPager', head:head, list:list, rowFn:rowFn, rows:OH_ROWS, capTop:214 });
  }
  /* ══ 매출내역 기간 빠른 선택 (2026-07-27 요청) ═══════════════════════════════
     당일 / 1주일(오늘 포함 최근 7일) / 해당월(1일~오늘, 말일 아님) / 직접 입력.
     · 프리셋 3개는 누르는 즉시 조회, '직접 입력'은 날짜만 열어 두고 [조회]를 기다린다.
     · 모드는 `_ohRg` 에 담되 **날짜칸 값과 어긋나면 자동으로 '직접 입력'으로 내려간다**
       (`ohRangeSync`) — 손으로 날짜를 고치거나 업로드가 기간을 바꿔도(slsSyncDates)
       버튼 표시가 실제 조회기간과 거짓말하지 않게. ★버튼 색만 바꾸고 조회는 안 한다. */
  var _ohRg='d';                                   // 진입 기본 = 당일 (2026-07-27 사용자 요청, 종전 '해당월')
  function _ohDayShift(n){ var d=new Date(); d.setDate(d.getDate()+n); return d.getFullYear()+'-'+ssPad(d.getMonth()+1)+'-'+ssPad(d.getDate()); }
  function _ohRgRange(m){
    if(m==='d') return [SS_TODAY, SS_TODAY];
    if(m==='w') return [_ohDayShift(-6), SS_TODAY];            // 오늘 포함 7일
    if(m==='m') return [SS_TODAY.slice(0,7)+'-01', SS_TODAY];  // 이번 달 1일 ~ 오늘
    return null;                                               // 'c' = 직접 입력
  }
  function ohRangeSync(){
    var fe=document.getElementById('slsFrom'), te=document.getElementById('slsTo');
    if(!fe || !te) return;   // ★head 로드 시점엔 패널이 아직 없다 — 빈 값으로 비교하면 기본(당일)이 '직접 입력'으로 내려간다
    var f=fe.value||'', t=te.value||'';
    var r=_ohRgRange(_ohRg);
    if(r && (f!==r[0] || t!==r[1])) _ohRg='c';                 // 칸을 손대면 직접 입력으로
    [['d','ohRgD'],['w','ohRgW'],['m','ohRgM'],['c','ohRgC']].forEach(function(p){
      var b=document.getElementById(p[1]); if(b) b.className=(p[0]===_ohRg)?'btn-teal':'btn-line';
    });
  }
  function ohRange(m){
    _ohRg=m;
    var r=_ohRgRange(m);
    if(!r){ ohRangeSync(); var e=document.getElementById('slsFrom');   // 직접 입력 — 시작일 칸으로 넘긴다
            if(e){ e.focus(); if(e.showPicker){ try{ e.showPicker(); }catch(x){} } } return; }
    var a=document.getElementById('slsFrom'), b=document.getElementById('slsTo');
    if(a) a.value=r[0];
    if(b) b.value=r[1];
    ohRangeSync();
    ohQuery();                                                 // 프리셋은 누르는 즉시 조회
  }
  // 진입 기본값 = 당일(오늘 하루) — 기본 모드 `_ohRg='d'` 와 반드시 같아야 한다
  //  (어긋나면 ohRangeSync 가 곧바로 '직접 입력'으로 내려버린다)
  function slsInit(){
    var f=document.getElementById('slsFrom'), t=document.getElementById('slsTo');
    if(f && !f.value) f.value=SS_TODAY;
    if(t && !t.value) t.value=SS_TODAY;
    ohRangeSync();
  }
  // 업로드 후 = 엑셀 납품일자가 속한 '달 전체'(1일~말일)로 조회기간 셋팅
  //  · 여러 달이 섞이면 가장 이른 달 1일 ~ 가장 늦은 달 말일
  function slsSyncDates(){
    var all=[];
    _slsFiles.forEach(function(f){ f.rows.forEach(function(r){ if(r.dlvDt) all.push(r.dlvDt); }); });
    if(!all.length) return;
    all.sort();
    var a=all[0], z=all[all.length-1];
    var y1=+a.slice(0,4), m1=+a.slice(5,7);
    var y2=+z.slice(0,4), m2=+z.slice(5,7);
    var last=new Date(y2, m2, 0).getDate();
    var f=document.getElementById('slsFrom'), t=document.getElementById('slsTo');
    if(f) f.value=y1+'-'+ssPad(m1)+'-01';
    if(t) t.value=y2+'-'+ssPad(m2)+'-'+ssPad(last);
    ohRangeSync();   // 업로드가 기간을 바꿨으니 기간 버튼 표시도 맞춘다(대개 '직접 입력'으로 내려감)
  }
  document.addEventListener('DOMContentLoaded', function(){ ssInit(); slsInit(); });
  (function(){ ssInit(); slsInit(); })();
</script>
</head>
<body>
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

    <div class="grp">조회·대시보드관리 ★</div>
    <a class="mi core on" data-key="shipstatus2" onclick="logiShipView('zone', this)"><span class="ic">🗂️</span>출고현황표(대시보드)</a>
     <%-- 출고세부조회: 출고장별 품목·사업장별·품목별을 한 화면 3탭으로 통합(2026-07-24).
          서브메뉴 3개 → 단일 메뉴. 탭 전환은 iframe(logistics_demo1) 상단 뷰버튼(zoneitem/biz/item). --%>
     <a class="mi" data-key="shipstatus2" onclick="logiShipView('zoneitem', this)"><span class="ic">🚚</span>출고세부조회</a>
     <%-- 출고현황이력조회(2026-07-25 요청) — 발주현황표 엑셀을 언제·누가·몇 차로 올렸는지와 그 발생내역.
          업로드가 배치(출고일자+출고장+차수)로 남으므로 그 흐름을 일자별로 보여준다. --%>
     <a class="mi" data-key="shipouthist" onclick="logiFrame('shipouthist','${pageContext.request.contextPath}/shipout/shipoutHist.do', this)"><span class="ic">🗂️</span>출고현황이력조회</a>

    <%-- 메뉴 배열 = 홀세일닥터 구조에 맞춤(2026-07-25 요청).
         업무 단위(매출/매입/재고)로 묶고 그 안에 등록·정산·마감을 함께 둔다.
         대시보드는 기존대로 맨 위 고정. 화면(패널)과 동작은 그대로이고 배치만 바꿨다. --%>

    <div class="grp">매출 관리</div>
    <a class="mi has-sub" data-sub="salesmng" onclick="logiToggleSub('salesmng', this)"><span class="ic">💰</span>매출 관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-salesmng">
      <a class="mi" data-key="outHist" onclick="logiGo('outHist', this); ohEnter();"><span class="ic">📤</span>매출내역</a>
      <a class="mi" data-key="salesreg" onclick="logiFrame('salesreg','${pageContext.request.contextPath}/mangr/salesReg.do', this)"><span class="ic">🧾</span>판매 등록</a>
      <a class="mi" data-key="rcvreg" onclick="logiFrame('rcvreg','${pageContext.request.contextPath}/mangr/rcvReg.do', this)"><span class="ic">🧾</span>수금 등록</a>
      <%-- 수금 / 미수금(월 단위, TBL_RECEIVE_MST) 메뉴 내림 : 2026-07-25.
           '수금 등록'(건별 전표)이 같은 일을 하고 원장의 [월 계] 로 월 합계까지 나온다.
           두 군데 입력하면 잔고가 갈라져서 뺐다. 실사용 0건이라 잃는 데이터 없음.
           화면(receiveMng.jsp)·컨트롤러·패널은 그대로 두었다. 되돌리려면
           logiFrame('receive', <컨텍스트>+'/mangr/receiveMng.do', this) 메뉴 한 줄만 다시 넣으면 된다.
           (EL 표기는 JSP 주석 안에서도 파서를 건드릴 수 있어 일부러 풀어 적었다) --%>
      <a class="mi" data-key="closeSales" onclick="logiGo('closeSales', this)"><span class="ic">📒</span>매출마감</a>
      <%-- 매출 그래프 2종 — 원래 '정보 현황' 에 있던 것을 2026-07-26 요청으로 매출 관리로 옮김.
           금액 정의는 마감현황(selectClosing)과 같게 맞춰 두었다(실측 202607 = 254,850,543 일치).
           월별/일자별을 따로 두는 이유 : 합치면 월별이 일자 단위 자료를 받아 무거워지고 '기간'의 뜻도 달라진다. --%>
      <a class="mi" data-key="saleschart" onclick="logiFrame('saleschart','${pageContext.request.contextPath}/shipout/salesChart.do', this)"><span class="ic">📈</span>매출 그래프(월별)</a>
      <a class="mi" data-key="saleschartday" onclick="logiFrame('saleschartday','${pageContext.request.contextPath}/shipout/salesChartDay.do', this)"><span class="ic">🗓️</span>매출 그래프(일자별)</a>
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
    <a class="mi" data-key="prodmst" onclick="logiFrame('prodmst','${pageContext.request.contextPath}/prod/prodmst.do', this)"><span class="ic">📦</span>상품(품목)관리</a>
    <a class="mi has-sub" data-sub="baseinfo" onclick="logiToggleSub('baseinfo', this)"><span class="ic">📂</span>기준정보관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-baseinfo">
      <a class="mi" data-key="vendor"  onclick="logiFrame('vendor','${pageContext.request.contextPath}/mangr/vendorMng.do', this)"><span class="ic">🧾</span>매입/매출 거래처</a>
      <a class="mi" data-key="client"  onclick="logiFrame('client','${pageContext.request.contextPath}/mangr/clientMng.do', this)"><span class="ic">🤝</span>거래처관리(사업장)</a>
      <a class="mi" data-key="compcd" onclick="logiFrame('compcd','${pageContext.request.contextPath}/mangr/compcd.do', this)"><span class="ic">🏢</span>회사/사용자 관리</a>
      <a class="mi" data-key="codecd" onclick="logiFrame('codecd','${pageContext.request.contextPath}/base/commcd.do', this)"><span class="ic">🧩</span>공통코드 관리</a>
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
  </nav>

  <!-- ───────────── 우측 콘텐츠 ───────────── -->
  <main class="logi-main">

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
      #ohDcBtn{ width:100%; height:34px; display:flex; align-items:center; justify-content:space-between; gap:6px; text-align:left; }
      #ohDcBtn .arr{ margin-left:auto; flex:0 0 auto; color:#178074; }
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
      .close-pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin:12px 0 4px; flex-wrap:wrap; }
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
        <div><h2 style="margin:0">매출내역 <span class="badge b-done">정산</span>
          <span style="font-size:12px;font-weight:400;color:#9aa7b3;margin-left:6px">정산서(받을 금액) × 발주현황표 출고내역</span></h2></div>
        <div class="actions">
          <!-- 파일을 고르면 목록·저장은 전부 팝업에서. 본 화면에는 버튼 하나만 남긴다 -->
          <button class="btn-line" id="slsUpChip" onclick="slsUpOpen()" style="display:none" title="저장 대기 중인 파일이 있습니다. 눌러서 확인·저장하세요."></button>
          <button class="btn-teal" onclick="document.getElementById('slsFile').click()" title="출고장이 준 정산 엑셀을 고릅니다(여러 개 가능).&#10;고르면 확인·저장 창이 열립니다.&#10;출고장은 파일명에서 인식합니다 — 2026.07.11_평택.xlsx → 평택">📥 정산 엑셀</button>
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
            <span class="tipx" title="[관점 환산] 엑셀은 출고장 기준이라 우리 기준으로 뒤집어 담습니다.&#10;  입고량→우리 출고량 · 단가→우리 판매단가 · 매입금액→우리 매출액 · 입고일자→우리 출고일자&#10;  ※ 엑셀의 '매입금액'은 우리 매입이 아닙니다(우리 매입가는 상품관리가 담당).&#10;&#10;[읽는 규칙] 품목코드 없는 행(합계행)은 제외 · 발주번호 병합셀은 위 값 승계 · 수량은 소수/음수 보존 · 납품일자는 엑셀 값, 출고장만 파일명에서 인식.&#10;&#10;[저장 단위] (납품일자+출고장) 1배치. 같은 배치를 다시 올리면 기존 자료를 이력마감한 뒤 새로 적재(이전 자료는 이력으로 남음).&#10;&#10;[판매단가 이력] 저장 시 판매가 이력에도 반영(적용일자=납품일자=발주일자) → 매출마감 출고단가가 (마스터) 대신 (이력) 확정가로 잡힘. 같은 품목·같은 날 단가가 다르면 건너뜀.&#10;&#10;[조회기간] 진입 시=당일(오늘 하루) / 엑셀 업로드 시=납품일자가 속한 달 전체.&#10;  · 기간 버튼 — 당일 / 1주일(오늘 포함 최근 7일) / 해당월(1일~오늘, 말일 아님)&#10;  · 누르는 즉시 조회합니다. 그 밖의 기간은 날짜칸을 직접 고른 뒤 [조회]를 누르세요(버튼 강조가 자동으로 풀립니다).&#10;&#10;[기간 기준] 납품일자(=발주일자)로 양쪽을 맞춥니다. 출고내역은 출고일자로만 조회되는데 먼 지역이 하루 당겨 출고하므로, 앞뒤 한 달을 넉넉히 읽어 발주일자로 다시 걸러 정산과 같은 기간으로 맞춥니다.&#10;&#10;[대사 규칙] ★발주일자 + 출고장 + 품목코드 로 짝을 맞춥니다(합계 대 합계).&#10;  · 출고는 사업장이 여럿이면 자동으로 합쳐집니다(정산서에 사업장 칸이 없음).&#10;  · 짝 없는 출고 = 미정산(보냈는데 청구 안 됨) / 짝 없는 정산 = 출고미상(보낸 적 없는데 청구됨).&#10;  · 발주번호는 키로 쓰지 않습니다(참고 표시만) — 발주현황표에 비어 있는 행이 있고(2026-07 실측 4,184행 중 424행),&#10;    발주번호로 대사하면 매칭률이 88%→82%로 오히려 떨어집니다. 발주번호로만 짝이 맞는 금액은 0원이었습니다.">ℹ️ 도움말</span>
          </div>
        </div>
        <div class="close-tabs" id="ohTabs" style="margin:6px 0 0">
          <button type="button" class="ctab on" data-t="dc"     onclick="ohTab('dc')" title="원천: 정산서 ∪ 출고내역(합집합) — 한쪽만 있어도 줄이 생깁니다.&#10;한 줄 = 출고장 1곳. 왼쪽 「출고건수·출고수량」=발주현황표 / 오른쪽 「정산행수·정산수량·평균단가·정산금액」=정산서.&#10;&#10;★출고장 줄을 클릭하면 ② 품목 탭으로 넘어가 그 출고장만 펼쳐 보여줍니다 — 차이가 난 품목을 바로 찾을 때.">🏭 출고장별 합계</button>
          <button type="button" class="ctab"    data-t="item"   onclick="ohTab('item')" title="원천: 정산서 ∪ 출고내역(합집합) · 품목축&#10;①에서 난 차이가 어느 품목 때문인지 찾습니다. 출고장 머리행을 눌러 접기/펼치기.">🧾 출고장 ▸ 품목</button>
          <button type="button" class="ctab ctab-red" data-t="gap" onclick="ohTab('gap')" title="정산서가 왔는데 출고수량과 정산수량이 다른 품목만 모아 봅니다(2026-07-27 요청).&#10;· 정산서가 아직 안 온 건은 '차이'가 아니라 미정산이라 여기 안 나옵니다 — ①탭 상태 칸에서 보세요.&#10;· 차이가 큰 것부터 정렬되고, 출고장 소계(통합)도 함께 나옵니다.&#10;· 수량차이 = <b>정산수량 − 출고수량</b>  ( + 정산이 많음 = 과청구·출고기록 누락 후보 / − 출고가 많음 = 청구 누락 후보 )&#10;  ※ ①②③탭의 수량차이는 반대 방향(출고−정산)입니다.&#10;· 품목코드 앞 화살표(▶)를 누르면 <b>정산서 원본행 + 출고 원본행</b>이 펼쳐집니다.&#10;★대사는 <b>납품일자</b>만 비교합니다. 출고일자는 정산서와 출고장이 다를 수 있어 비교하지 않습니다&#10;   — 코네트에서 <b>김해·제주는 멀어서 미리 출고</b>하기 때문입니다(정상). 화면에서도 참고용(회색 괄호)으로만 보여 줍니다.">⚠️ 수량차이 품목</button>
          <button type="button" class="ctab"    data-t="ship"   onclick="ohTab('ship')" title="원천: 출고내역(발주현황표) · 사업장축 · 출고수량 전용&#10;어느 점포로 얼마나 나갔나. 사업장 줄을 누르면 출고 원본행이 펼쳐집니다.&#10;&#10;※ 사업장별 정산금액은 만들지 않습니다.&#10;   정산서에 사업장 칸이 없어 쪼개면 추정이 되기 때문입니다.&#10;   금액은 ①출고장별 합계 · ②출고장▸품목 에서 보세요.&#10;&#10;맨 오른쪽 「정산 대사」는 배분이 아니라 사실입니다 —&#10;   대사됨: 이 행의 발주일자·출고장·품목코드가 정산서에 있음&#10;   미정산: 보냈는데 정산서에 없음(청구 누락 후보)">🏢 출고장 ▸ 사업장</button>
          <button type="button" class="ctab"    data-t="settle" onclick="ohTab('settle')" title="원천: 정산서(TBL_SALES_MST) 단독&#10;출고장이 보낸 엑셀 원본 행 그대로. 「출고수량」 한 열만 대사로 붙였습니다.">📋 정산서 원본(엑셀)</button>
          <span style="margin-left:auto"></span>
          <button type="button" class="btn-line" id="ohAllBtn" style="height:30px;margin-bottom:2px" onclick="ohToggleAll()">⊟ 전체 접기</button>
        </div>
        <div class="close-summary" id="ohSum" style="margin:3px 0 2px; line-height:1.35">기간·출고장을 지정하고 [조회]를 누르세요. (비우면 전체)</div>
        <div id="ohWrap"></div>
        <div class="close-pager" id="ohPager"></div>
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

      <div class="g-sec">
        <h3>1. 조회·대시보드</h3>
        <table><tbody>
          <tr><td class="m">출고현황표(대시보드)</td><td>발주현황표 엑셀을 올려 <b>출고장·사업장·품목별 출고량</b>을 작성합니다. 매출마감·재고차감의 원천.
            <div style="margin-top:4px;color:#5a6b7a"><b>· 대체 규칙</b> <b style="color:#c0392b">출고장 + 납품일자</b>가 같으면 기존 자료를 대체(출고일자는 보지 않음). 예전 것은 이력으로 내려가니 <b>잘못 올렸으면 다시 올리면</b> 됩니다.<br>
            <b>· [📤 …보기 / 업로드]</b> = 탐색기가 아니라 <b>미리보기</b>가 열려 지정 폴더 파일을 최신순으로 보여줍니다(최근 파일 자동 펼침). 상단에 📂폴더 지정 · 📄파일 선택 · ↻새로고침 · ℹ️도움말.<br>
            <b>· 김해·제주</b>는 조기출고라 출고일자가 <b>납기일자 2일 전</b>으로 저장됩니다.<br>
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
            <b>· 짝 맞추기</b> 발주일자+출고장+품목코드(합계 대 합계). 짝 없는 출고=<b style="color:#c0392b">미정산</b>(청구 누락 후보), 짝 없는 정산=<b style="color:#c0392b">출고미상</b>.</div></td></tr>
          <tr><td class="m">판매 등록 / 수금 등록</td><td>정산서 밖의 <b>직접 판매</b> 전표와 <b>수금</b> 전표. 오른쪽에 그 거래처 원장이 함께 뜹니다.</td></tr>
          <tr><td class="m">매출마감</td><td>출고 × <b>발주일자 시점 단가</b> → 매출·매입·순마진. 출고장별(오산센터 등 2단)·사업장별·품목별 3탭, 품목 검색 공통.</td></tr>
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
          <tr><td class="m">기준정보관리</td><td><b>매입/매출 거래처</b>(회계 거래처 · 거래처리스트.xls 재업로드) · <b>거래처관리(사업장)</b>(배송 점포, 발주 업로드 시 자동등록) · 회사/사용자 · 공통코드.</td></tr>
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
      <div class="card" style="padding-top:12px">
        <div class="form-row" style="margin-bottom:0; align-items:flex-end">
          <div class="fld" style="flex:0 0 300px"><label>검색(품목코드/품목명)</label><input id="stkSrch" placeholder="검색어 입력" onkeyup="if(event.keyCode===13)stkStatusLoad()"></div>
          <div class="fld" style="flex:0 0 170px"><label>기준일 <span style="color:#9aa7b3;font-weight:400">(비우면 전체)</span></label><input type="date" id="stkAsOf" onchange="stkStatusLoad()"></div>
          <div class="fld" style="flex:0 0 70px"><button class="btn-line" style="width:100%" onclick="stkAsOfClear()">전체</button></div>
          <div class="fld" style="flex:0 0 90px"><button class="btn-teal" style="width:100%" onclick="stkStatusLoad()">조회</button></div>
          <div class="fld" style="flex:0 0 auto; margin-left:auto">
            <span class="tipx" title="[현재고] = 입고(I·R·A) − 출고(O). 수불원장(TBL_STOCK_LEDGER) 단일 소스라 재고마감과 같은 값입니다.&#10;출고는 발주현황표 저장 시 원장에 자동 기록되므로 따로 넣지 않아도 됩니다.&#10;&#10;[기준일] 비우면 전체(=지금 현재고) / 날짜를 넣으면 그날까지의 기말.&#10;  → 마감월 말일로 맞추면 재고마감 기말과 대사됩니다.&#10;&#10;[음수 현재고] 입고 없이 출고만 있다는 뜻 = 입고 누락 신호입니다(오류가 아니라 알림).&#10;&#10;[② 수불 내역] ① 표에서 품목 행을 클릭하면 그 품목을 이루는 개별 입·출고 거래가 아래에 나옵니다.">ℹ️ 도움말</span>
          </div>
        </div>
        <!-- ① 제목 · 요약 · 상태를 한 줄에. stkStatusSum 은 JS가 통째로 덮어쓰므로 형제로 분리해 둔다 -->
        <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin:10px 0 4px">
          <span style="font-weight:800;font-size:13.5px;color:#1f2a37;border-left:4px solid var(--logi-teal);padding-left:9px;white-space:nowrap">① 품목별 현재고</span>
          <span class="close-summary" id="stkStatusSum" style="margin:0">[조회] 또는 [새로고침]을 누르세요.</span>
          <span style="margin-left:auto;font-size:11.5px;color:#9aa7b3;white-space:nowrap">
            <b id="stkAsOfLbl" style="color:#178074">전체 (현재고)</b> · 집계 <b id="stkStamp" style="color:#178074">—</b> · 행 클릭 → ② 수불내역
          </span>
        </div>
        <div id="stkStatusWrap" style="max-height:46vh; overflow:auto"></div>
        <div class="close-pager" id="stkStatusPager"></div>
      </div>
      <div class="card" style="margin-top:10px">
        <div style="font-weight:800;font-size:13.5px;color:#1f2a37;margin:2px 0 4px;border-left:4px solid #b06a00;padding-left:9px">② 선택 품목 수불 내역 <span class="badge b-done" style="margin-left:4px">근거</span> <span style="font-weight:400;font-size:11.5px;color:#9aa7b3;margin-left:6px" title="TBL_STOCK_LEDGER — 이 품목을 이루는 개별 입·출고 거래">현재고의 근거</span></div>
        <div id="stkLedgerHead" style="color:#6b7a89;padding:8px 2px 10px">위 ① 표에서 <b>품목을 클릭</b>하면 그 품목의 수불 내역이 여기에 표시됩니다.</div>
        <div id="stkLedgerBody" style="max-height:210px; overflow:auto"></div>
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
                <span style="color:#c0392b">※ <b>김해·제주</b>는 조기출고라 <b>납기일자 2일 전</b>으로 저장됩니다</span> — 출고일자를 직접 바꾸면 그 값으로 통일됩니다.<br>
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
            <div style="width:400px; flex:0 0 400px; border:1px solid var(--logi-border); border-radius:7px; display:flex; flex-direction:column; height:60vh">
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
            <!-- 우측: 기존 미리보기 표 -->
            <div style="flex:1; min-width:0">
              <div id="ssPvInfo"></div>
              <%-- 오류내역 — 양식이 다르거나 값이 빠진 행이 있을 때만 채워진다(ssPvRender) --%>
              <div id="ssPvErr"></div>
              <div style="max-height:56vh; overflow:auto; border:1px solid var(--logi-border); border-radius:7px">
                <table class="ss-pv" id="ssPvTbl"></table>
              </div>
            </div>
          </div>
          <div class="mfoot" style="align-items:center">
            <%-- 좌측 알림 두 줄: 조기출고(김해·제주) / 역순 업로드(마지막에 올린 자료보다 이전) --%>
            <span style="margin-right:auto;min-width:0;display:flex;flex-direction:column;gap:2px">
              <span id="ssPvEarlyMsg" style="font-size:12.5px;font-weight:700;color:#c0392b;display:none"></span>
              <%-- 이전 자료 알림 — 빨강 + 살짝 깜박(.ss-blink, ssBackMsgUpd 가 붙였다 뗀다) --%>
              <span id="ssPvBackMsg" style="font-size:12.5px;font-weight:700;color:#c0392b;display:none"></span>
            </span>
            <span style="font-size:16px;font-weight:700;color:#37475a;margin-right:10px">출고일자
              <input type="date" id="ssPvShpoutDt" oninput="this.setAttribute('data-touched','1');ssBackMsgUpd()"
                     style="height:38px;border:1px solid var(--logi-border);border-radius:6px;padding:0 10px;font-size:16px;font-weight:700;margin:0 4px"
                     title="엑셀 기준 출고일자 — 수정 가능. 이 날짜로 전체 행이 저장되고 조회됩니다">
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
        <div class="close-summary" id="inbSum" style="margin:10px 0 4px">[조회] 또는 [새로고침]을 누르세요.</div>
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

    <!-- ===== 매출 그래프 — 월별 / 일자별 (2026-07-25) ===== -->
    <section id="panel-saleschart" class="panel" style="padding:0;">
      <iframe id="if-saleschart" src="" title="매출 그래프(월별)" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>
    <section id="panel-saleschartday" class="panel" style="padding:0;">
      <iframe id="if-saleschartday" src="" title="매출 그래프(일자별)" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

    <!-- ===== 거래처별 받을금액·지급할금액 (2026-07-26) — logiFrame 은 #panel-<key> + #if-<key> 를 함께 찾는다 ===== -->
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
