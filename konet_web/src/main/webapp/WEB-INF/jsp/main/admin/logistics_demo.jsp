<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
<meta charset="UTF-8">

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
  .logi-side .sub-menu a.mi { padding-left:34px; font-size:13px; }
  .logi-side .side-tit { padding:18px 20px; font-size:17px; font-weight:700; color:#fff; border-bottom:1px solid #2c3a4a; }
  .logi-side .side-tit small { display:block; font-size:11px; font-weight:400; color:#8a98a8; margin-top:3px; }
  .logi-side .grp { padding:14px 20px 6px; font-size:11px; letter-spacing:.5px; color:#7d8b9c; }
  .logi-side a.mi { display:flex; align-items:center; gap:9px; padding:9px 20px; color:#cdd6e0; text-decoration:none; font-size:13.5px; border-left:3px solid transparent; cursor:pointer; }
  .logi-side a.mi:hover { background:#28333f; color:#fff; }
  .logi-side a.mi.on { background:#28333f; color:#fff; border-left-color:var(--logi-teal); font-weight:600; }
  .logi-side a.mi .ic { width:18px; text-align:center; }
  .logi-side a.mi.core { color:#aef0e7; }


  /* 우측 콘텐츠 */
  .logi-main { flex:1; padding:22px 28px; background:var(--logi-bg); overflow:auto; }
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
  table.sswide th, table.sswide td { border:1px solid var(--logi-border); padding:6px 7px; text-align:center; white-space:nowrap; font-size:12px; }
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
  table.sswide tr.lgrp td { background:#eef3f2; color:#178074; font-weight:700; font-size:11.5px; }
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

  /* 발주현황표 미리보기 모달 */
  .ss-modal { display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:9998; }
  .ss-modal.on { display:flex; align-items:flex-start; justify-content:center; }
  .ss-modal .box { background:#fff; width:min(1120px,95vw); margin-top:4vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:90vh; display:flex; flex-direction:column; }
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
  table.ss-pv td.rn { background:#f4f8f7; color:#9aa7b3; text-align:right; position:sticky; left:0; }
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
  }
  // 자체완결 화면(회사/사용자·공통코드)을 우측 iframe 패널에 로드 (사이드메뉴 종속)
  function logiFrame(key, url, el){
    logiGo(key, el);
    var f = document.getElementById('if-'+key);
    if (f && !f.getAttribute('data-loaded')) { f.src = url; f.setAttribute('data-loaded','1'); }
  }
  // 주메뉴(기준정보관리 등) 접기/펼치기 토글
  function logiToggleSub(sub, el){
    var box = document.getElementById('sub-'+sub);
    if (!box) return;
    var open = box.classList.toggle('open');
    if (el) el.classList.toggle('open', open);
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

<!-- 엑셀 파서 (xlsx) — CDN 지연/차단 시에도 화면이 먼저 뜨도록 defer -->
<script defer src="https://cdn.sheetjs.com/xlsx-0.20.3/package/dist/xlsx.full.min.js"></script>
<!-- ZIP 처리 (일부 ERP가 생성한 비표준 xlsx의 sharedStrings 보정용) -->
<script defer src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<!-- PDF 출력 (jsPDF + html2canvas, 한글 안전 이미지 캡처) -->
<script defer src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script defer src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
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
  function ssShortName(item){ var s=(''+(item||'')).replace(/^\([^)]*\)\s*/,''); return s||(item||''); }
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
    // 업로드/매출·매입/저장 버튼: 일자별(시작=종료 단일 일자)일 때만 활성 — 당월·기간(시작≠종료) 모드면 비활성
    ['ssBtnUpload','ssBtnSales','ssBtnCost','ssBtnSave'].forEach(function(id){
      var b=document.getElementById(id); if(!b) return;
      b.disabled=!single; b.title = single ? '' : '일자별(시작=종료 단일 일자) 조건에서만 가능합니다';
    });
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
    var byL={}, letters=[];
    zones.forEach(function(z){ var L=(z.charAt(0)||'').toUpperCase(); if(!byL[L]){ byL[L]=[]; letters.push(L); } byL[L].push(z); });
    letters.sort();
    window.ssLetters=letters.slice();
    var colTot={}, grand=0, tb='';
    letters.forEach(function(L){
      var col; if(L in ssZoneCollapsed){ col=!!ssZoneCollapsed[L]; } else { col=ssZoneDefaultCollapsed; ssZoneCollapsed[L]=col; }   // 기본=펼침
      // 그룹 라벨: 출고장명 끝의 입고장 숫자를 떼어 물류센터명으로 표시(예: 평택물류센터1 → 평택물류센터), 없으면 기존 'L출고장'
      var _gname=(''+(byL[L][0]||'')).replace(/\s*\d+\s*$/,'').trim();
      var _glabel=(_gname.length>1)?_gname:(L+'출고장');
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
        tb+='<tr class="zg_'+L+'"'+(col?' style="display:none"':'')+'>'+wrapSum('<td class="stick">&nbsp;&nbsp;'+z+' 출고장'+_zdelx+'</td>', cells, '<td class="num colsum">'+ssNum(rowSum)+'</td>')+'</tr>';
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

  function ssUpload(input){
    var f=input.files && input.files[0]; if(!f) return;
    if(typeof XLSX==='undefined'){ ssToast('⚠️ 엑셀 파서를 불러오지 못했습니다(인터넷 필요).'); input.value=''; return; }
    ssPvName=f.name;
    var rd=new FileReader();
    rd.onload=function(e){
      ssReadXlsx(e.target.result, function(wb){
      try{
        ssPvWb=wb;
        var names=ssPvWb.SheetNames||[];
        document.getElementById('ssPvFile').textContent=f.name;
        var sel=document.getElementById('ssPvSheet');
        sel.innerHTML=names.map(function(n,i){ return '<option value="'+i+'">'+n+'</option>'; }).join('');
        sel.value='0';
        document.getElementById('ssPvSheetWrap').style.display = names.length>1 ? '' : 'none';
        ssPvRender();
        ssPvOpen(true);
      }catch(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); }
      }, function(err){ ssToast('⚠️ 엑셀 처리 오류: '+err.message); });
      input.value='';
    };
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
                   cDate:findEq(r1,'납기일자') };
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
    return { fmt:'old', h:h, dataRow:h+2, cItem:findIn(h1,'품목명'), cBiz:findIn(h1,'사업장명'), cBizCode:findIn(h1,'사업장코드'), cCode:findIn(h1,'품목코드'), cInb:cInb, cZone:cZone, cQty:cQty, cDate:cDate };
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
        code:(''+(m.cCode>=0?row[m.cCode]:'')).trim(),
        item:nm,
        biz:bizLbl,
        bizName:bizNm,
        bizCode:bizCd,
        inb:inbVal,
        zone:zoneVal,
        qty:(+(''+(row[m.cQty]||'')).replace(/[^0-9.\-]/g,''))||0,
        date:(m.cDate>=0?ssFmtDate(row[m.cDate]):'') || SS_TODAY
      });
    }
    return rows;
  }

  var ssPvCur=null;

  function ssPvOpen(show){ document.getElementById('ssPvOverlay').classList.toggle('on', !!show); }

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
    var btn=document.getElementById('ssPvApplyBtn');
    var hlCols={};
    if(m){
      [m.cItem,m.cBiz,m.cBizCode,m.cZone,m.cQty,m.cCode,m.cInb,m.cCenter].forEach(function(c){ if(c>=0) hlCols[c]=1; });
      var cnt=ssExtractRows(aoa,m).length;
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
      btn.removeAttribute('disabled'); btn.style.opacity='1';
    } else {
      info.className='ss-pvinfo warn';
      info.innerHTML='⚠️ 발주현황표 형식이 아닙니다 — 헤더에 <b>물류센터명·품목명·현 발주</b>(코네트) 또는 <b>품목명·사업장명·존·수량</b> 가 있어야 합니다. 시트를 바꿔 보세요.';
      btn.setAttribute('disabled','disabled'); btn.style.opacity='.5';
    }
    // 미리보기 표 (전체 행 표시 — 모달 내 스크롤)
    var maxR=Math.min(aoa.length,2000), maxC=0;
    for(var i=0;i<maxR;i++) maxC=Math.max(maxC,(aoa[i]||[]).length);
    maxC=Math.min(maxC,40);
    var html='';
    for(var r=0;r<maxR;r++){
      var isHdr = m && (r===m.h || r===m.h+1);
      html+= isHdr ? '<tr class="hdr">' : '<tr>';
      html+='<td class="rn">'+(r+1)+'</td>';
      for(var c=0;c<maxC;c++){
        var v=ssCellDisp(aoa[r]&&aoa[r][c]);
        html+='<td'+(hlCols[c]?' class="hl"':'')+' title="'+v.replace(/"/g,'&quot;')+'">'+v+'</td>';
      }
      html+='</tr>';
    }
    if(aoa.length>2000) html+='<tr><td class="rn">…</td><td colspan="'+maxC+'" style="color:#9aa7b3">이하 '+(aoa.length-2000)+'행 생략 (작성 시 전체 반영)</td></tr>';
    document.getElementById('ssPvTbl').innerHTML=html;
  }

  // 앱 스타일 확인 메시지 박스 (native confirm 대체)
  function ssConfirm(html, onYes){
    var ov=document.getElementById('ssConfirmOv');
    if(!ov){
      ov=document.createElement('div'); ov.id='ssConfirmOv'; ov.className='ss-modal';
      ov.innerHTML='<div class="box" style="width:min(480px,92vw)">'
        +'<div class="mh"><h4>📋 반영 확인</h4><button class="x" onclick="ssConfirmClose()">&times;</button></div>'
        +'<div class="mbody" id="ssConfirmMsg" style="font-size:14px; line-height:1.65; color:#37475a"></div>'
        +'<div class="mfoot"><button class="btn-line" onclick="ssConfirmClose()">취소</button>'
        +'<button class="btn-teal" id="ssConfirmYes">반영</button></div></div>';
      document.body.appendChild(ov);
    }
    document.getElementById('ssConfirmMsg').innerHTML=html;
    document.getElementById('ssConfirmYes').onclick=function(){ ssConfirmClose(); if(onYes) onYes(); };
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
    if(!ssPvCur || !ssPvCur.map){ ssToast('⚠️ 인식 가능한 발주현황표가 아닙니다.'); return; }
    var rows=ssExtractRows(ssPvCur.aoa, ssPvCur.map);
    if(!rows.length){ ssToast('⚠️ 데이터 행이 없습니다.'); return; }
    var sheetNm=ssPvWb.SheetNames[+(document.getElementById('ssPvSheet').value||0)];
    var _upZ={}; rows.forEach(function(r){ if(r.zone) _upZ[r.zone]=1; }); var _zc=Object.keys(_upZ).length;
    ssConfirm('파일 <b>'+ssPvName+'</b> · 시트 "<b>'+sheetNm+'</b>"<br>발주 <b style="color:#137a6c">'+rows.length+'</b>건 · 출고장 <b style="color:#137a6c">'+_zc+'</b>곳을 반영하시겠습니까?'
      +'<br><br><span style="color:#b3760f">※ <b>기존 화면 자료를 초기화한 뒤</b> 이 파일로 새로 생성하고, <b>서버(TBL_SHIPOUT_MST)에 저장</b>됩니다. (같은 출고장·기준일의 기존 저장분은 이력으로 남고 새 버전이 활성화됩니다.)</span>',
      function(){ ssDoApply(rows, sheetNm); });
  }

  // 실제 반영 처리 — ★ 기존화면 자료 초기화 후 생성 (업로드 파일로 전체 교체) + 서버 저장
  function ssDoApply(rows, sheetNm){
    var upZones={}; rows.forEach(function(r){ if(r.zone) upZones[r.zone]=1; });
    var zoneList=Object.keys(upZones);
    // ★ 기존화면 자료 초기화 후 생성 (병합 아님)
    ssExtraItems=[]; ssExtraZones=[]; ssZoneCollapsed={};
    SHIP_DATA = rows.slice();
    var st=document.getElementById('ssBizSel'); if(st) st.value='__ALL__';
    // 출고일자: 업로드한 발주현황표의 해당일자로 시작일=종료일(같은 단일 일자) 설정
    var upD=rows.map(function(r){ return r.date; }).filter(Boolean).sort();
    var theDay = upD.length ? upD[upD.length-1] : SS_TODAY;
    ssSetVal('ssDateFrom', theDay); ssSetVal('ssDateTo', theDay);
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
  //    논리키 = DLV_DT(납기일자). 납기일자별로 서버에서 그룹·버전관리
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
  function ssSaveShipoutToDB(aoa, baseDt){
    var rows=ssBuildShipoutRows(aoa);
    if(!rows.length) return;
    var srcFile=ssPvName;
    // 논리키=납기일자(DLV_DT, 행별). 비어있으면 대표일자로 보정. 물류센터/사업장은 키 아님(서버에서 납기일자별 그룹·버전)
    rows.forEach(function(o){ if(!o.dlvDt) o.dlvDt=baseDt; o.srcFile=srcFile; });
    fetch('${pageContext.request.contextPath}/shipout/saveShipoutMst.do', {
      method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
      body: JSON.stringify(rows)
    })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
    .then(function(r){
      if(r.ok) ssToast('💾 서버 저장 완료 — 납기일 '+baseDt+' · <b>'+r.t+'</b>건 (기존 자료 초기화 후 생성)');
      else     ssToast('⚠️ 서버 저장 실패: '+(r.t||'오류'));
    })
    .catch(function(e){ ssToast('⚠️ 서버 저장 통신오류: '+e.message); });
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
    // 출고장 그룹별
    var byL={}, letters=[]; zones.forEach(function(z){ var L=(z.charAt(0)||'').toUpperCase(); if(!byL[L]){ byL[L]=[]; letters.push(L); } byL[L].push(z); }); letters.sort();
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
    ssRender();   // 당월=기간 모드 — 단일일자 DB조회 대상 아님(현재 데이터 렌더)
  }

  // ── 출고현황표 DB 조회: 선택한 출고일자(단일)의 활성배치를 읽어와 표시. 없으면 빈 화면 ──
  //    DB행 → 화면 SHIP_DATA 매핑은 ssExtractRows(konet 포맷)와 동일:
  //      · 출고장(zone) = 물류센터명(DC_NM) + 입고장(INWH)  예) "평택물류센터1"
  //      · 사업장(biz)  = 사업장명 [사업장코드]
  function ssLoadShipoutFromDB(){ ssLoadBiziMst(function(){ _ssLoadShipoutInner(); }); }   // 조회 직전 분류표 최신화
  function _ssLoadShipoutInner(){
    var f=(document.getElementById('ssDateFrom')||{}).value||'';
    var t=(document.getElementById('ssDateTo')||{}).value||'';
    // 단일 일자(시작=종료)만 DB 조회. 기간 모드는 현재 데이터로 렌더만.
    if(!(f && f===t)){ ssRender(); return; }
    fetch('${pageContext.request.contextPath}/shipout/selectShipoutMst.do', {
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
      credentials:'same-origin',
      body:'dlvDt='+encodeURIComponent(f)
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
        return { code:(''+(o.itemCd||'')).trim(), item:(''+(o.itemNm||'')).trim(),
                 biz:bizLbl, bizCode:bizCd, inb:inwh, zone:zone,
                 qty:(+o.curQty||0), date:f };
      });
      window.ssSrcUp   = rows.length>0;
      window.ssSrcInfo = rows.length>0 ? ('🗄️ DB 조회 '+f+' · '+rows.length+'건') : ('🗄️ DB '+f+' — 데이터 없음');
      ssRender();
    })
    .catch(function(e){ window.ssSrcInfo='⚠️ DB 통신오류'; SHIP_DATA=[]; ssRender(); if(window.ssToast) ssToast('⚠️ 출고 조회 통신오류: '+e.message); });
  }

  // 초기 렌더 (AJAX 주입/직접 접근 모두 대응) — 내장 데이터는 금일자로 간주
  function ssInit(){
    if(!document.getElementById('ssWideTbl')) return;
    if(!window.ssSrcInfo){ window.ssSrcInfo='내장 샘플 데이터 (당일 기준)'; window.ssSrcUp=false; }
    SHIP_DATA.forEach(function(r){ if(!r.date) r.date=SS_TODAY; });
    var f=document.getElementById('ssDateFrom'), t=document.getElementById('ssDateTo');
    if(f && !f.value) f.value=SS_TODAY;
    if(t && !t.value) t.value=SS_TODAY;
    ssLoadShipoutFromDB();   // 진입 시 = 당일(단일) → DB에서 해당일자 조회(없으면 빈 화면)
  }
  document.addEventListener('DOMContentLoaded', ssInit);
  (function(){ ssInit(); })();
</script>
</head>
<body>
<div class="logi-wrap">

  <!-- ───────────── 좌측 사이드바 ───────────── -->
  <nav class="logi-side">
    <div class="side-tit">📦 물류관리<small>도매유통 · 입고/재고/발주/출고</small></div>

    <div class="grp">출고관리 ★</div>
    <a class="mi core on" data-key="shipstatus" onclick="logiGo('shipstatus', this)"><span class="ic">📋</span>출고현황표(데시보드)</a>

    <div class="grp">기준정보</div>
    <a class="mi" data-key="client"  onclick="logiGo('client', this)"><span class="ic">🤝</span>거래처관리</a>
    <a class="mi" data-key="item"    onclick="logiGo('item', this)"><span class="ic">📦</span>상품(품목)관리</a>
    <a class="mi" data-key="base"    onclick="logiGo('base', this)"><span class="ic">🏬</span>창고/로케이션</a>

    <div class="grp">매입 · 입고</div>
    <a class="mi core" data-key="inbound"     onclick="logiGo('inbound', this)"><span class="ic">📥</span>입고등록 (창고선정)</a>
    <a class="mi"      data-key="inboundList" onclick="logiGo('inboundList', this)"><span class="ic">📄</span>입고내역</a>

    <div class="grp">재고</div>
    <a class="mi" data-key="stock"  onclick="logiGo('stock', this)"><span class="ic">📊</span>창고별 재고현황</a>
    <a class="mi" data-key="locate" onclick="logiGo('locate', this)"><span class="ic">🔎</span>재고/위치 조회</a>

    <div class="grp">발주 · 주문</div>
    <a class="mi"      data-key="order"     onclick="logiGo('order', this)"><span class="ic">📝</span>주문(발주)등록</a>
    <a class="mi core" data-key="orderList" onclick="logiGo('orderList', this)"><span class="ic">⬇️</span>발주리스트 (엑셀)</a>

    <div class="grp">출고</div>
    <a class="mi core" data-key="outbound"     onclick="logiGo('outbound', this)"><span class="ic">📤</span>출고지시 (위치→출고)</a>
    <a class="mi"      data-key="outboundList" onclick="logiGo('outboundList', this)"><span class="ic">📄</span>출고내역 / 거래명세서</a>

    <div class="grp">매출 · 정산</div>
    <a class="mi" data-key="sales"   onclick="logiGo('sales', this)"><span class="ic">💰</span>매출현황</a>
    <a class="mi" data-key="receive" onclick="logiGo('receive', this)"><span class="ic">🧾</span>수금 / 미수금</a>

    <div class="grp">시스템관리</div>
    <a class="mi has-sub" data-sub="baseinfo" onclick="logiToggleSub('baseinfo', this)"><span class="ic">📂</span>기준정보관리<span class="caret">▶</span></a>
    <div class="sub-menu" id="sub-baseinfo">
      <a class="mi" data-key="compcd" onclick="logiFrame('compcd','${pageContext.request.contextPath}/mangr/compcd.do', this)"><span class="ic">🏢</span>회사/사용자 관리</a>
      <a class="mi" data-key="codecd" onclick="logiFrame('codecd','${pageContext.request.contextPath}/base/commcd.do', this)"><span class="ic">🧩</span>공통코드 관리</a>
      <a class="mi" data-key="bizimst" onclick="logiFrame('bizimst','${pageContext.request.contextPath}/mangr/bizimst.do', this)"><span class="ic">🏷️</span>사업장 분류 관리</a>
    </div>
  </nav>

  <!-- ───────────── 우측 콘텐츠 ───────────── -->
  <main class="logi-main">

    <!-- ===== ★ 출고현황표 (엑셀 업로드 → 출고량 자동작성) ===== -->
    <section id="panel-shipstatus" class="panel show">
      <div class="logi-head">
        <div><h2>출고현황표 <span class="badge b-done">핵심</span></h2>
          <div class="sub">발주현황표(엑셀)를 업로드하면 <b>사업장·품목별 출고량</b> 과 <b>출고장별 수량</b> 이 자동 작성됩니다. 기준일자 <b id="ssDate">2026.06.19</b></div></div>
        <div class="actions">
          <button class="btn-teal" id="ssBtnUpload" onclick="document.getElementById('ssFile').click()">📤 발주현황표 엑셀 업로드</button>
          <button class="btn-line" id="ssBtnSales" onclick="document.getElementById('ssSalesFile').click()" title="매입단가 엑셀(품목코드·입고일자·입고량·단가·매입금액)을 업로드하면 출고량 아래에 매출액 행이 표시됩니다">💰 매출금액 업로드</button>
          <button class="btn-line" id="ssBtnCost" onclick="document.getElementById('ssCostFile').click()" title="매입금액 엑셀(품목코드·매입금액/단가)을 업로드하면 매출액 아래에 매입액 행과 마진(매출−매입)이 표시됩니다 — 엑셀은 추후 제공">🧾 매입금액 업로드</button>
          <button class="btn-line" id="ssBtnSave" onclick="ssSaveData()">💾 출고데이타저장</button>
          <button class="btn-line" id="ssBtnDownload" onclick="ssDownload()">📥 출고현황표 다운로드</button>
          <button class="btn-line" id="ssBtnPdf" onclick="ssPdf()">📄 PDF 출력</button>
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
          <div class="mbar">
            <span>파일 <b id="ssPvFile">-</b></span>
            <span id="ssPvSheetWrap" style="display:none">시트
              <select id="ssPvSheet" onchange="ssPvRender()"></select>
            </span>
            <span style="margin-left:auto; color:#6b7a89">아래 내용이 맞으면 <b>작성(반영)</b> 을 누르세요</span>
          </div>
          <div class="mbody">
            <div id="ssPvInfo"></div>
            <div style="max-height:56vh; overflow:auto; border:1px solid var(--logi-border); border-radius:7px">
              <table class="ss-pv" id="ssPvTbl"></table>
            </div>
          </div>
          <div class="mfoot">
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
        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:12px; flex-wrap:wrap; gap:8px">
          <div style="display:flex; gap:6px; align-items:center">
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
          <div style="display:flex; gap:6px; align-items:center">
            <button class="btn-line" id="ssBtnZoneToggle" style="padding:5px 11px" onclick="ssToggleAllZones()">－ 출고장 접기</button>
            <button class="btn-teal" style="padding:5px 11px" onclick="ssAddItem()">＋ 품목 추가</button>
            <button class="btn-line" style="padding:5px 11px" onclick="ssAddZone()">＋ 출고장 추가</button>
            <button class="btn-line" style="padding:5px 11px; color:#c0392b; border-color:#e3b4ae" onclick="ssClearAll()" title="모든 출고장 데이터를 비웁니다(샘플 포함). 이후 엑셀 업로드로 새로 채울 수 있습니다.">🔄 출고장 초기화</button>
            <label style="font-size:12px; color:#37475a; margin-left:6px; cursor:pointer"><input type="checkbox" id="ssSumFront" onchange="ssRender()" style="vertical-align:-1px" checked> 합계 맨앞</label>
            <label style="font-size:12px; color:#178074; margin-left:6px; cursor:pointer" title="사업장을 가운데로 두고 우측→좌측으로 5초마다 회전(원통 캐러셀). 활성 사업장만 또렷, 끝나면 반복"><input type="checkbox" id="ssBizAnim" onchange="ssToggleBizAnim()" style="vertical-align:-1px"> 사업장 회전</label>
            <label style="font-size:12px; color:#6b7a89; margin-left:6px">사업장 보기</label>
            <select id="ssBizSel" onchange="ssRender()" style="height:32px; border:1px solid var(--logi-border); border-radius:6px; padding:0 8px; font-size:12.5px"></select>
          </div>
        </div>
        <div id="ssHiddenBar" class="ss-hidden-bar" style="display:none"></div>
        <div class="ss-scroll">
          <table class="ss-tb sswide" id="ssWideTbl"></table>
        </div>
        <div class="note">※ <b>당일</b> 모드에서 출고장 행의 노란 칸을 클릭해 수량을 직접 입력하면(엔터/포커스아웃) <b>합계가 자동 재계산</b>됩니다. 사업장 헤더(뜨돈 등) 클릭 시 그 열 숨김(위 바에서 펼치기). 품목 많으면 가로 스크롤. 하단 월별/재고량은 데모용 가정값.</div>
      </div>

    </section>

    <!-- ===== 기준정보 : 거래처 ===== -->
    <section id="panel-client" class="panel">
      <div class="logi-head"><div><h2>거래처관리</h2><div class="sub">매입처 · 매출처(거래처) 마스터</div></div>
        <div class="actions"><button class="btn-teal">거래처 등록</button></div></div>
      <div class="card">
        <div class="form-row">
          <div class="fld"><label>구분</label><select><option>전체</option><option>매입처</option><option>매출처</option></select></div>
          <div class="fld"><label>거래처명/사업자번호</label><input placeholder="검색어"></div>
          <div class="fld" style="flex:0 0 100px;align-self:flex-end"><button class="btn-line" style="width:100%">조회</button></div>
        </div>
        <table class="logi-tb">
          <thead><tr><th>거래처코드</th><th>거래처명</th><th>구분</th><th>사업자번호</th><th>대표자</th><th>연락처</th><th>미수금</th></tr></thead>
          <tbody>
            <tr><td>C-001</td><td class="txt-l">OO마트</td><td>매출처</td><td>123-45-67890</td><td>김유통</td><td>02-1234-5678</td><td>1,200,000</td></tr>
            <tr><td>C-002</td><td class="txt-l">△△유통</td><td>매출처</td><td>234-56-78901</td><td>박상사</td><td>031-222-3333</td><td>0</td></tr>
            <tr><td>S-101</td><td class="txt-l">광동(매입)</td><td>매입처</td><td>345-67-89012</td><td>이매입</td><td>02-9999-0000</td><td>-</td></tr>
          </tbody>
        </table>
      </div>
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
      <div class="logi-head"><div><h2>입고내역</h2><div class="sub">입고 처리된 내역 조회</div></div>
        <div class="actions"><button class="btn-line">엑셀</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>입고일</th><th>매입처</th><th>상품코드</th><th>상품명</th><th>수량</th><th>창고</th><th>로케이션</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>2026-06-18</td><td>광동</td><td>ITM-1001</td><td class="txt-l">샘플 품목 A</td><td>120</td><td>제1창고</td><td class="loc">A-02-03</td><td><span class="badge b-done">완료</span></td></tr>
            <tr><td>2026-06-18</td><td>제주삼다수</td><td>ITM-1042</td><td class="txt-l">샘플 품목 B</td><td>50</td><td>제2창고</td><td class="loc">B-01-05</td><td><span class="badge b-done">완료</span></td></tr>
            <tr><td>2026-06-17</td><td>롯데</td><td>ITM-1108</td><td class="txt-l">샘플 품목 C</td><td>300</td><td>제3창고</td><td class="loc">C-04-01</td><td><span class="badge b-done">완료</span></td></tr>
          </tbody>
        </table>
        <div class="note">※ 데모용 더미 데이터입니다. 실제 테이블/조회 로직은 추후 연동.</div>
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

    <!-- ===== 수금 / 미수금 ===== -->
    <section id="panel-receive" class="panel">
      <div class="logi-head"><div><h2>수금 / 미수금</h2><div class="sub">거래처별 미수금 및 수금 처리</div></div>
        <div class="actions"><button class="btn-teal">수금 등록</button></div></div>
      <div class="card">
        <table class="logi-tb">
          <thead><tr><th>거래처</th><th>전월이월</th><th>당월매출</th><th>당월수금</th><th>미수잔액</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td class="txt-l">OO마트</td><td>0</td><td>5,200,000</td><td>4,000,000</td><td>1,200,000</td><td><span class="badge b-due">미수</span></td></tr>
            <tr><td class="txt-l">△△유통</td><td>0</td><td>7,250,000</td><td>7,250,000</td><td>0</td><td><span class="badge b-done">완납</span></td></tr>
          </tbody>
        </table>
        <div class="note">※ 전자세금계산서 · 카드결제 연동은 추후 단계.</div>
      </div>
    </section>

    <!-- 시스템관리 — 자체완결 화면을 iframe으로 사이드메뉴 우측에 종속 -->
    <section id="panel-compcd" class="panel" style="padding:0;">
      <iframe id="if-compcd" src="" title="회사/사용자 관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>
    <section id="panel-codecd" class="panel" style="padding:0;">
      <iframe id="if-codecd" src="" title="공통코드 관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>
    <section id="panel-bizimst" class="panel" style="padding:0;">
      <iframe id="if-bizimst" src="" title="사업장 분류 관리" style="width:100%; height:calc(100vh - 70px); border:0; display:block;"></iframe>
    </section>

  </main>
</div>
</body>
</html>
