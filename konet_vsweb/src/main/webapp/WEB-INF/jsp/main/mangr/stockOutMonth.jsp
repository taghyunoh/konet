<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>월별 출고현황</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox) — 브라우저 alert 대신 (2026-09-03 요청) --%>
<script src="${pageContext.request.contextPath}/asset/js/stock-chk-act.js?v=20261126b"></script>   <%-- [재고 미적용]/[재고 적용] 단추 — 품목별재고현황과 같이 쓰는 공용 (2026-11-26) --%>
<%-- 기간 = 납기현황표와 같은 우리 달력(ui-datenav.js) — 시작·종료가 달력 두 개로 한 번에 뜬다. 2026-09-03 「이런 형태로」 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<script src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20260910b"></script>   <%-- 표 높이 막대 — 판매·매입등록과 같은 공용 (2026-10-26) --%>
<!--
  월별 출고현황 (2026-09-03 신설, 처음 이름 「출고재고현황」→ 같은 날 「월별 출고현황」으로 바꿈) — 재고 관리 > 품목별재고현황 밑 메뉴. 사이드바 iframe(logiFrame) 화면.
  · 행 = 년월(최근월부터 내림차순) · 열 = 사업장 ▸ 품목 (납기현황표 가로표와 같은 2단 머리) · 값 = 그 달 출고량 · 맨 위 줄 = 품목 현재고
  · 원천 규칙(사용자 확정 2026-09-03) = <납기일자> 기준으로 그 날 정산서가 있으면 정산서, 없으면 발주현황표(라벨수량). 원장(품목별재고현황)과 같은 규칙.
    정산서엔 사업장이 없어 같은 발주라인의 사업장에 발주수량 비율로 «정수로» 나눈다(SQL selectStockOutByMonth — 2026-11-24, 나머지는 소수 몫이 큰 사업장부터 1개씩). 현재고 줄은 원장(TBL_STOCK_MST).
  · ★[2026-10-26] 원장이 세는 출고를 전부 센다 — 정산서 · 발주현황표(정산서 없는 날, DC 발주 포함) · 토더·대상 발주(정산서 날에도 늘) · 판매전표(판매일자 · 판매 줄 · 거래처가 사업장 자리, 이름 뒤 「(판매전표)」).
  · 사업장 이름 = 거래처관리 매칭명(MATCH_NM)이 있으면 그것, 없으면 원래 사업장명 (납기현황표 가로표와 같은 규칙, SQL에서 묶음)
  · 열 차례 = 출고 많은 사업장이 왼쪽, 사업장 안에서도 많이 나간 품목이 왼쪽. 출고장은 넣지 않는다(요청).
  · 현재고는 품목 잔량이라 사업장과 무관 — 같은 품목이 여러 사업장에 있으면 같은 값이 되풀이되고, 합계는 품목 하나당 한 번만 더한다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:12px; font-size:12.5px; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input[type=date], .bar input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .cnt{ margin-left:10px; color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; white-space:nowrap; }
  .cnt b{ color:var(--teal); font-weight:800; }
  /* 재집계는 툴바 맨 오른쪽 (2026-09-03 「재집계 위치 이동」) — 조회·거르기·엑셀과 떨어뜨려 실수로 누르지 않게 */
  .bar .rb-btn{ margin-left:auto; border-color:#cfe0da; color:#137a6c; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  /* 가로표(납기현황표)와 같은 감각 — 첫 두 칸·머리 2줄 고정, 값 없는 칸 회색, 사업장 경계는 굵은 세로선 */
  /* ★table-layout:fixed (2026-09-04 속도) — 자동 레이아웃은 2,415열×3만 셀의 내용 폭을 여러 번 재서
       레이아웃만 884ms 걸렸다. 열 폭을 colgroup 으로 못 박으면 한 번에 계산한다(품목 열은 112px 균일). */
  table.mx{ border-collapse:separate; border-spacing:0; font-size:14px; --h1:40px; table-layout:fixed; }
  table.mx th, table.mx td{ border:1px solid var(--bd); padding:6px 9px; white-space:nowrap; text-align:center; background:#fff; }
  table.mx .gs{ border-left:2px solid #9fb6cc; }
  table.mx .cn{ position:sticky; left:0; z-index:2; text-align:left; font-weight:700; width:150px; min-width:150px; max-width:150px; background:#fff; }
  table.mx td.cn small.src{ display:block; font-size:11px; font-weight:400; color:#6b7a89; line-height:1.2; }
  table.mx .rt{ position:sticky; left:150px; z-index:2; width:90px; min-width:90px; max-width:90px; background:#fff2cc; font-weight:800; }
  /* ★머리 고정은 <thead 한 덩어리>로 (2026-09-04 속도) — 종전 `thead th{position:sticky}` 는 머리 칸 2,415개가 저마다 sticky 라
       브라우저가 칸마다 합성 레이어를 만들어(스크롤 상자 안 sticky 는 레이어로 승격) 그리기·스크롤·화면 전환이 통째로 무거웠다.
       thead 하나를 sticky 로 두면 두 줄이 함께 붙고 레이어는 1개다. 2단 머리의 top(--h1) 계산도 필요 없다. */
  table.mx thead{ position:sticky; top:0; z-index:3; }
  table.mx thead th{ background:#dfeaf5; color:#1f2a37; font-size:14px; }
  table.mx thead th.cn, table.mx thead th.rt{ z-index:4; }
  /* 1단 = 사업장(매칭명) · 2단 = 품목. 2단은 1단 높이(--h1, 그릴 때 잰다)만큼 내려 붙인다 */
  table.mx thead th.gh{ background:#cfe0f3; font-size:14px; font-weight:800; color:#123c63; white-space:nowrap; line-height:1.3; min-width:96px; text-align:left; overflow:clip; }
  /* 사업장 이름은 칸 안에서 sticky — 40품목짜리 사업장은 칸이 수천 px 라 가운데 두면 이름이 화면 밖에 간다. 고정칸(150+90) 바로 뒤에 붙인다
     ★[2026-09-13 「겹쳐나옴」] 1~2품목 사업장은 칸이 좁아 긴 이름이 옆 칸 위로 넘쳤다 → 칸 폭에서 끊고 「…」(전체 이름은 th 의 title 툴팁).
     ⚠th 에 overflow:hidden 을 쓰면 th 가 스크롤 상자가 되어 이름 sticky 가 풀린다 — 그래서 th 는 clip, 끊기는 .gl 이 한다. */
  table.mx thead th.gh .gl{ position:sticky; left:250px; display:inline-block; max-width:100%; overflow:hidden; text-overflow:ellipsis; vertical-align:top; }
  table.mx thead th.gh small{ display:block; font-size:11.5px; font-weight:600; color:#4c6a8a; overflow:hidden; text-overflow:ellipsis; }
  /* ★[2026-09-13 「헤더 확장 가능하게」] [↕ 머리글 펼치기] = #card.hx — 사업장 이름을 칸 안에서 여러 줄로 다 보인다(「…」로 안 끊음).
       표를 다시 그리지 않고 #card 의 class 만 바꾼다(표는 #card 안에서 innerHTML 로 갈아 끼워지므로 class 는 그대로 남는다). 기억 = localStorage konetSomHx */
  #card.hx table.mx thead th.gh{ white-space:normal; vertical-align:top; }
  #card.hx table.mx thead th.gh .gl, #card.hx table.mx thead th.gh small{ white-space:normal; overflow:visible; text-overflow:clip; word-break:keep-all; overflow-wrap:anywhere; }
  table.mx thead th.it{ background:#eef4fa; white-space:normal; min-width:96px; max-width:128px; line-height:1.35; font-size:12px; font-weight:600; padding:6px 6px; word-break:break-all; }   /* 2026-09-03 「품목명 조금 좁게」 118→96px */
  table.mx thead th.it .cd{ display:block; font-weight:800; color:#1f2a37; }
  table.mx thead th.it .nm{ color:#5a6b7a; font-weight:400; }
  table.mx td.none{ background:#f1f3f5; }
  table.mx th.sp, table.mx td.sp{ background:#f1f3f5; border-left:0; border-right:0; padding:0; }   /* 가상화 빈 칸(안 그린 열들의 자리) */
  table.mx td.n{ font-weight:700; }
  /* ■ 품목 합계 묶음 (2026-11-16) — 사업장과 상관없이 품목마다 기간 출고를 모은 맨 앞 열들 */
  table.mx th.al{ background:#e3f2ee !important; color:#0f6b5e !important; }
  table.mx td.al{ background:#f2f9f7; }
  table.mx td.al.n{ color:#0f6b5e; }
  table.mx tr.stk td{ background:#fff4e6; font-weight:800; color:#137a6c; }
  table.mx tr.stk td.cn, table.mx tr.stk td.rt{ background:#fde9cc; }
  table.mx tr.stk td.neg{ color:#c0392b; }
  table.mx tr.sum td{ background:#e2efda; font-weight:800; color:#375623; }
  table.mx tr.sum td.cn, table.mx tr.sum td.rt{ background:#d5e8c6; }
  table.mx tbody td{ height:30px; }
  .empty{ padding:30px; text-align:center; color:#9aa7b3; }
  /* 재집계 진행 창 — 서버(RebuildProgress)가 알려주는 실제 진행률. 총량을 모르는 단계는 흐르는 바(qprog) */
  .rb{ position:fixed; inset:0; background:rgba(15,23,32,.35); z-index:9998; display:none; align-items:center; justify-content:center; }
  .rb.on{ display:flex; }
  .rb .bx{ background:#fff; width:min(440px,92vw); border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); padding:18px 22px 16px; }
  .rb .tt{ font-weight:800; font-size:15px; color:#137a6c; margin-bottom:12px; }
  .rb .bar{ height:10px; background:#e8efed; border-radius:6px; overflow:hidden; }
  .rb .bar > i{ display:block; height:100%; width:0; background:linear-gradient(90deg,#0f6b5f,#3fbfae); border-radius:6px; transition:width .3s; }
  .rb .bar.ind > i{ width:34%; animation:qslide 1.05s infinite ease-in-out; }
  .rb .lb{ margin-top:10px; font-size:13px; color:#5a6b7a; min-height:18px; }
  /* 조회 진행바 — 물류관리 다른 화면(마감·매출내역·재고현황)의 .qprog 와 같은 것 (2026-09-03 「불러오는 중을 진행바로」).
     진행률을 알 수 없는 조회라 좌우로 흐르는 무한 바 + 한 줄 안내 */
  .qprog{ height:3px; background:#e8efed; border-radius:2px; overflow:hidden; margin:2px 0 8px; }
  .qprog > i{ display:block; height:100%; width:34%; border-radius:2px; background:linear-gradient(90deg,#0f6b5f,#3fbfae); animation:qslide 1.05s infinite ease-in-out; }
  @keyframes qslide{ 0%{ margin-left:-34%; } 100%{ margin-left:100%; } }
  .qmsg{ padding:10px 2px 4px; color:#5a6b7a; font-size:12.5px; }
  .qwrap{ padding:14px 16px 10px; }
  /* 셀을 누르면 하단에 그 (년월·사업장·품목)의 출고내역·입고내역 (2026-09-03 요청) */
  table.mx td[data-cd]{ cursor:pointer; }
  table.mx td[data-cd]:hover{ outline:2px solid #137a6c; outline-offset:-2px; }
  table.mx td.pick{ outline:2px solid #e0871a; outline-offset:-2px; background:#fff7e6 !important; }
  .dtl{ margin-top:12px; background:#fff; border:1px solid var(--bd); border-radius:10px; display:none; }
  .dtl .dh{ display:flex; align-items:center; gap:10px; padding:9px 12px; border-bottom:1px solid var(--bd); background:#f4f8f7; font-size:14px; flex-wrap:wrap; }
  .dtl .dh b{ color:var(--teal); }
  .dtl .dh .x{ margin-left:auto; cursor:pointer; border:1px solid var(--bd); background:#fff; border-radius:6px; padding:3px 9px; font-size:12.5px; }
  .dtl .cols{ display:flex; gap:0; }
  .dtl .col{ flex:1 1 50%; min-width:0; border-right:1px solid var(--bd); }
  .dtl .col:last-child{ border-right:0; }
  /* 출고내역 | 입고내역 사이 좌우 조절 막대 (2026-11-24 사용자 「좌우 조정가능하게」) — 끌면 왼쪽 폭이 바뀌고 브라우저에 기억 · 두 번 누르면 반반 */
  .dtl .vsp{ flex:0 0 8px; cursor:col-resize; background:#eef2f5; border-left:1px solid var(--bd); border-right:1px solid var(--bd); position:relative; user-select:none; }
  .dtl .vsp:hover, .dtl .vsp.on{ background:#cfe6e1; }
  .dtl .vsp::after{ content:''; position:absolute; left:2px; top:50%; width:2px; height:34px; margin-top:-17px; border-radius:2px; background:#9fb3c2; }
  .dtl .cols.dragging{ user-select:none; cursor:col-resize; }
  .dtl .col.lft{ border-right:0; }
  .dtl .ct{ padding:7px 12px; font-weight:800; font-size:13.5px; background:#fafcfb; border-bottom:1px solid var(--bd); }
  .dtl .ct span{ font-weight:600; color:#6b7a89; margin-left:6px; }
  .dtl .tb{ max-height:40vh; overflow:auto; }
  .dtl table{ border-collapse:collapse; width:100%; font-size:13px; }
  .dtl th, .dtl td{ border-bottom:1px solid #eef1f4; padding:5px 9px; white-space:nowrap; text-align:center; }
  .dtl th{ position:sticky; top:0; background:#eef4fa; font-weight:700; z-index:2; }
  /* ★출고내역 표(table.fx) — 옆으로 밀 때 납기일자·사업장 두 칸은 왼쪽에 고정 (2026-11-22 사용자 그림 「우측스크롤시 사업장까지 고정이고 스크롤되게」).
       둘째 칸의 left = 첫 칸 폭(--c1w — 그린 뒤 재서 넣는다, somDetailRender). 고정 칸은 배경을 칠해야 밑으로 지나가는 칸이 안 비친다.
       collapse 표의 테두리는 고정 칸을 안 따라오므로 밑줄·오른쪽 경계는 box-shadow 로 그린다. 머리글 두 칸은 위·왼쪽 둘 다 고정이라 z-index 가 가장 높다.
       사업장 이름이 아주 길면 280px 에서 …(전체 이름은 말풍선) — 고정 칸이 화면 절반을 먹지 않게 */
  .dtl table.fx th:nth-child(-n+2), .dtl table.fx td:nth-child(-n+2){ position:sticky; left:0; }
  .dtl table.fx th:nth-child(2), .dtl table.fx td:nth-child(2){ left:var(--c1w, 94px); max-width:280px; overflow:hidden; text-overflow:ellipsis; }
  .dtl table.fx td:nth-child(-n+2){ background:#fff; z-index:1; box-shadow:inset 0 -1px 0 #eef1f4; }
  .dtl table.fx td:nth-child(2){ box-shadow:inset 0 -1px 0 #eef1f4, inset -2px 0 0 #d5dee6; }
  .dtl table.fx th:nth-child(-n+2){ z-index:3; }
  .dtl table.fx th:nth-child(2){ box-shadow:inset -2px 0 0 #c3d0db; }
  .dtl td.l{ text-align:left; } .dtl td.r{ text-align:right; font-weight:700; }
  .dtl td.src-s{ color:#1f6fb3; } .dtl td.src-o{ color:#6b7a89; } .dtl td.src-t{ color:#8a4c0d; font-weight:600; } .dtl td.src-d{ color:#6b3fa0; font-weight:600; }
  /* 출고코드(거래처 매칭코드) — 품목별재고현황의 ↳ 줄과 같은 주황 */
  .dtl td .xc{ color:#c8741a; font-weight:700; } .dtl td .xn{ color:#a06a2c; font-size:12px; }
  .dtl .none{ padding:18px; text-align:center; color:#9aa7b3; }
  /* ★「거래처 매출장·마감」 그리드 모양으로 (2026-10-21 사용자 「월별 출고현황도」 — 품목별재고현황·매출내역·마감 표와 같게)
       머리줄 하늘(#d9edf7)+회청 테두리(#9fb6c3) · 칸 테두리 #c9d3dc · 합계 줄 크림(#fcf8e3). 사업장 묶음 머리(gh)·품목 머리(it)·현재고 줄(stk)·고정칸 동작은 그대로 */
  table.mx th, table.mx td{ border:1px solid #c9d3dc; }
  table.mx thead th{ background:#d9edf7; border:1px solid #9fb6c3; }
  table.mx thead th.cn, table.mx thead th.rt{ background:#d9edf7; }
  table.mx tr.sum td{ background:#fcf8e3; color:#1f2a37; font-weight:800; }
  table.mx tr.sum td.cn, table.mx tr.sum td.rt{ background:#fcf8e3; }
  /* 품목 머리글 클릭 → 상품 정보 창 (2026-11-05) */
  table.mx th.it[data-pcd]{ cursor:pointer; } table.mx th.it[data-pcd]:hover .cd{ text-decoration:underline; }
  #somProdPop{ position:fixed; z-index:9000; width:400px; background:#fff; border:1px solid #9fc9c0; border-radius:8px; box-shadow:0 12px 32px rgba(15,23,32,.28); font-size:13px; color:#1f2a37; display:none; }
  #somProdPop .spi-hd{ display:flex; align-items:center; gap:8px; padding:9px 12px; background:#e6f1ee; color:#125a4e; font-weight:800; border-radius:8px 8px 0 0; font-size:13.5px; }
  #somProdPop .spi-x{ margin-left:auto; cursor:pointer; font-size:16px; line-height:1; color:#5a6b7a; } #somProdPop .spi-x:hover{ color:#c0392b; }
  #somProdPop table.spi{ width:100%; border-collapse:collapse; } #somProdPop table.spi th{ width:118px; text-align:left; padding:4px 10px; background:#f6f9f8; color:#37475a; font-weight:700; border-bottom:1px solid #eef1f4; white-space:nowrap; }
  #somProdPop table.spi td{ padding:4px 10px; border-bottom:1px solid #eef1f4; word-break:break-all; } #somProdPop table.spi td.r{ font-variant-numeric:tabular-nums; }
  #somProdPop .spi-ft{ display:flex; align-items:center; gap:10px; padding:8px 12px; white-space:nowrap; } #somProdPop .spi-ft .btn{ white-space:nowrap; flex:0 0 auto; height:30px; padding:0 12px; } #somProdPop .dim{ color:#8a97a4; }   /* 단추 한 줄로 (2026-11-05) */
  /* 정산서만 오고 발주현황표가 없는 날 (2026-11-24) — 표 위 알림 줄. 통째로 빠진 날 = 노랑(굵게) · 품목만 빠진 날 = 연한 회색 요약(누르면 펼침) */
  /* 한 줄 띠 (2026-11-24 사용자 「이 공간 너무 차지함」) — 평소엔 한 줄 요약, [자세히]를 누르면 날짜·센터 목록과 설명을 펼친다 */
  .npo{ background:#fff8e1; border:1px solid #f0d98a; color:#6b4510; border-radius:7px; padding:3px 10px; margin:0 0 6px; font-size:12.5px; line-height:1.5; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .npo.open{ white-space:normal; }
  .npo b.d{ color:#b03a2e; }
  .npo .lk{ color:#1d6fb8; cursor:pointer; text-decoration:underline; font-weight:700; margin-left:6px; }
  .npo .more{ margin-top:4px; color:#7b6a4a; font-size:12px; }
  .npo .lst{ margin-top:4px; max-height:120px; overflow:auto; background:#fff; border:1px solid #efe2b8; border-radius:6px; padding:3px 8px; font-size:12px; color:#4a5866; }
  .npo.lite{ background:#f6f8fa; border-color:#dbe2ea; color:#4a5866; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📦 월별 출고현황</h2>
  <div class="sub"><b>사업장</b> ▸ <b>품목</b>별 <b>월 출고량</b>과 <b>현재고</b>를 한 표로 봅니다 — 행은 년월(최근월부터), 맨 위 줄이 품목 현재고(사업장과 무관한 품목 잔량)입니다. 출고량은 <b>납기일자</b> 기준으로 그 날 <b>그 물류센터 정산서가 있으면 정산서</b>, 없으면 발주현황표(라벨수량)를 읽고, <b>토더·대상 발주</b>는 정산서가 있는 날에도 세고, <b>판매전표</b>(판매등록)는 판매일자 기준으로 거래처를 사업장 자리에 「(판매전표)」로 보입니다 — 품목별재고현황(재고 원장)과 같은 규칙. 사업장은 거래처관리 매칭명으로 묶습니다.</div>
  <div class="bar">
    <label style="font-weight:700">기간</label>
    <input type="date" id="frDt" data-range-to="toDt" onchange="somLoad()" title="클릭하여 달력 선택 — 시작·종료를 한 번에 고릅니다"> <span style="color:#8a98a8">~</span> <input type="date" id="toDt" onchange="somLoad()" title="클릭하여 달력 선택 — 시작·종료를 한 번에 고릅니다">
    <button class="btn btn-teal" id="somBtn" onclick="somLoad()">🔍 조회</button>
    <input type="text" id="q" placeholder="사업장/품목코드/품목명 거르기" oninput="somFindLater()" onkeydown="if(event.key==='Enter'){ somFindNow(); }" title="치는 동안 기다렸다가 멈추면 거릅니다 — Enter 를 누르면 바로" style="width:220px">
    <button class="btn" onclick="somExcel()">📥 엑셀 출력</button>
    <button class="btn" id="hxBtn" onclick="somHx()" title="사업장 이름이 길어 「…」로 잘릴 때 — 누르면 머리글을 여러 줄로 펼쳐 전체 이름을 봅니다. 다시 누르면 한 줄로 줄입니다(다음에 들어와도 기억).">↕ 머리글 펼치기</button>
    <span class="cnt" id="cnt">-</span>
    <button class="btn rb-btn" onclick="somRebuild()" title="전체 출고를 재고 원장에 다시 반영하고 현재고를 다시 계산합니다 (품목별재고현황의 재집계와 같은 것).&#10;정산서가 있는 납기일자는 정산서, 없는 날은 발주현황표 기준. 마감 확정월은 제외.">🔄 출고반영 재집계</button>
  </div>
  <div class="npo" id="npo" hidden></div>   <%-- 정산서만 오고 발주현황표가 없는 날 (2026-11-24) --%>
  <div class="card" id="card"><div class="empty">기간을 고르고 [조회]를 누르세요.</div></div>
  <div class="dtl" id="dtl">
    <div class="dh" id="dtlHead"></div>
    <div class="cols">
      <div class="col"><div class="ct">📤 출고내역 <span id="dtlOutSum"></span></div><div class="tb" id="dtlOut"></div></div>
      <div class="vsp" id="dtlSplit" title="끌어서 출고내역 · 입고내역 폭 조절 — 두 번 누르면 반반"></div>
      <div class="col"><div class="ct">📥 입고내역 <span id="dtlInSum"></span></div><div class="tb" id="dtlIn"></div></div>
    </div>
  </div>
  <div class="rb" id="rb"><div class="bx"><div class="tt">🔄 출고반영 재집계</div><div class="bar ind" id="rbBar"><i></i></div><div class="lb" id="rbLb">시작하는 중…</div></div></div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var RAW=null;   // {months:[{ym,bizKey,bizNm,prodCd,prodNm,outQty}], stock:[{prodCd,curQty}], srcDays:[{ym,days,sDays}]}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
/* [↕ 머리글 펼치기] (2026-09-13 「헤더 확장 가능하게」) — 1~2품목 사업장은 칸이 좁아 이름이 「…」로 잘린다. 켜면 여러 줄로 다 보인다.
   #card 의 class(hx) 만 바꾼다 — 표를 다시 그리지 않으므로 즉시 바뀌고, 다시 조회해도 그대로다. */
var _somHx=(function(){ try{ return localStorage.getItem('konetSomHx')==='1'; }catch(e){ return false; } })();
function somHxPaint(){
  var c=document.getElementById('card'), b=document.getElementById('hxBtn');
  if(c) c.classList.toggle('hx', _somHx);
  if(b){ b.innerHTML=_somHx?'↕ 머리글 줄이기':'↕ 머리글 펼치기';
         b.style.background=_somHx?'#c3e2d8':''; b.style.color=_somHx?'#0b5246':''; b.style.fontWeight=_somHx?'800':''; }
}
function somHx(){
  _somHx=!_somHx;
  try{ localStorage.setItem('konetSomHx', _somHx?'1':'0'); }catch(e){}
  somHxPaint();
  if(typeof somFit==='function' && typeof _somM!=='undefined' && _somM) somFit();   // 머리글 높이가 바뀌므로 표 높이를 다시 맞춘다
}
somHxPaint();
function num(v){ return Math.round(Number(v)||0).toLocaleString(); }   // 정산서 배분은 정수(2026-11-24) — 정산수량 자체가 소수인 줄만 소수가 남는다 → 표시는 반올림
/* 조회 진행바(다른 화면 .qprog 와 같은 모양) */
function qprog(msg, id){ return '<div class="qwrap"><div class="qprog"><i></i></div><div class="qmsg"'+(id?' id="'+id+'"':'')+'>'+esc(msg||'조회 중…')+'</div></div>'; }
/* ★조회 중 표시 다듬기 (2026-11-24 사용자 「월별 출고현황도 진행바 확인해줘」 — 정산서 누락 조회와 같게)
     ① 걸린 초를 0.5초마다 ② [조회] 단추 잠금 ③ 서버 응답 뒤 «표를 그리는 중»으로 글을 바꾸고 한 박자 쉰 뒤 그린다 —
        그리기(3만 칸 · 1~2초)는 화면을 멈추게 해서, 바꾸지 않으면 진행바가 «조회 중»에서 굳은 듯 보였다 ④ 늦게 온 옛 응답은 버린다(_somSeq). */
var _somSeq=0, _somBusyT=null;
function somBusy(on){
  if(_somBusyT){ clearInterval(_somBusyT); _somBusyT=null; }
  var b=document.getElementById('somBtn'); if(b){ b.disabled=!!on; b.style.opacity=on?'.6':''; }
  if(!on) return;
  var t0=Date.now(), el=document.getElementById('somQmsg'), base=el?el.textContent:'';
  _somBusyT=setInterval(function(){ var m=document.getElementById('somQmsg'); if(!m){ clearInterval(_somBusyT); _somBusyT=null; return; }
    var sec=Math.floor((Date.now()-t0)/1000); if(sec>=1) m.textContent=(m.getAttribute('data-base')||base)+' · '+sec+'초'; }, 500);
}
function ymLabel(ym){ ym=''+ym; return ym.length===6 ? (ym.slice(0,4)+'-'+ym.slice(4,6)) : ym; }
/* 알림 = 프로젝트 공통 _alertBox(ui-message.js, 재집계 확인창과 같은 모양). 없으면 브라우저 alert 폴백 (2026-09-03 요청) */
function toast(s, icon){ if(window._alertBox) return _alertBox(s, {icon:icon||'ℹ️'}); alert(s.replace(/<[^>]*>/g,'')); }
/* 기본 기간 = <해당년도 1월 1일> ~ 오늘 (2026-09-03 사용자 확정. 종전 「12개월 전 1일」)
   ★기간이 곧 표의 열 수다 — 지금은 자료가 2026-01 부터라 12개월 기본과 결과가 같지만
     (열 2,415 · DOM 셀 29,811 · 렌더 실측 1.5초), 해가 바뀌면 12개월 기본은 지난해까지 끌어와
     열이 배로 늘어난다. 올해분으로 끊으면 그 일이 없다. 더 보려면 시작일만 내리면 된다. */
(function(){
  function d10(x){ return x.getFullYear()+'-'+('0'+(x.getMonth()+1)).slice(-2)+'-'+('0'+x.getDate()).slice(-2); }
  var d=new Date(), to=d10(d);
  var fr=d.getFullYear()+'-01-01';
  document.getElementById('frDt').value=fr; document.getElementById('toDt').value=to;

})();
function somLoad(){
  _somAlias=null;   /* 매칭코드 표도 조회마다 새로(2026-09-17 「다른 화면에서 고친 것이 로그아웃 전엔 안 보임」 점검) — 아래 somAliasLoad 가 다시 받는다 */
  var fr=document.getElementById('frDt').value, to=document.getElementById('toDt').value;
  if(!fr||!to){ toast('기간을 고르세요.'); return; }
  if(fr>to){ var t=fr; fr=to; to=t; document.getElementById('frDt').value=fr; document.getElementById('toDt').value=to; }
  var my=++_somSeq;
  document.getElementById('card').innerHTML=qprog('월별 출고량을 조회하는 중… (기간 '+fr+' ~ '+to+')', 'somQmsg');
  somBusy(true);
  /* 걸린 시간을 조회 결과 줄에 같이 적는다(2026-09-04 「조회 자체 느림」 — 서버·그리기 어느 쪽인지 사용자가 바로 보게) */
  somAliasLoad();          /* 매칭코드 → 주코드 표 (한 번만 · 조회를 기다리게 하지 않는다) */
  var t0=performance.now(), tFetch=0;
  _dtlCache={};   /* 새로 조회하면 셀별 내역 보관도 비운다 (2026-11-05) */
  fetch(CTX+'/prod/stockOutMonthList.do', { method:'POST', credentials:'same-origin',
         headers:{'Content-Type':'application/x-www-form-urlencoded'},
         body:'frDt='+encodeURIComponent(fr.replace(/-/g,''))+'&toDt='+encodeURIComponent(to.replace(/-/g,'')) })
    .then(function(r){ return r.json(); })
    .then(function(j){ if(my!==_somSeq) return; tFetch=performance.now()-t0; RAW=j||{months:[],stock:[]};
      /* 그리기 전에 글을 바꾸고 한 박자 쉰다 — 그리는 동안 화면이 멈춰도 무엇을 하는 중인지 보이게 */
      var qm=document.getElementById('somQmsg'); if(qm){ var nt='표를 그리는 중… (자료 '+((RAW.months||[]).length).toLocaleString()+'줄)'; qm.setAttribute('data-base', nt); qm.textContent=nt; }
      setTimeout(function(){ if(my!==_somSeq) return;
        var t1=performance.now(); somRender(); void document.body.offsetHeight; somBusy(false);
        _somTiming='  ⏱ 서버 '+(tFetch/1000).toFixed(1)+'초 · 그리기 '+((performance.now()-t1)/1000).toFixed(1)+'초';
        var c=document.getElementById('cnt'); if(c && c.innerHTML.indexOf('⏱')<0) c.innerHTML+='<span style="color:#8a98a8;font-weight:600">'+_somTiming+'</span>'; }, 30); })
    .catch(function(e){ if(my!==_somSeq) return; somBusy(false); document.getElementById('card').innerHTML='<div class="empty">조회 실패: '+esc(e.message)+'</div>'; });
}
/* 품목명 앞의 (브랜드) 가 사업장 이름과 겹치면 뺀다 — 납기현황표 엑셀과 같은 규칙(공백 무시 · 2자 이상 · 서로 포함) */
function shortNm(nm, biz){
  var m=/^\s*\(([^)]*)\)\s*(.*)$/.exec(nm||''); if(!m) return nm||'';
  var a=m[1].replace(/\s+/g,''), b=(biz||'').replace(/\s+/g,'');
  if(a.length>=2 && b.length>=2 && (a.indexOf(b)>=0 || b.indexOf(a)>=0)) return m[2]||nm;
  return nm||'';
}
/* ★★서브코드(매칭코드)로 쳐도 «주코드»로 찾는다 (2026-09-10 요청 「대시보드처럼 1000791735 → 9904013072 로만 검색」)
     출고·재고는 **주코드로만** 쌓인다. 서브코드는 거래처가 쓰는 «남의 코드»라 그대로 거르면
     열이 하나도 안 걸려 「검색이 안 된다」가 된다(재고현황에서 2026-08-07 에 똑같이 겪었고, 거기서는 이미 이렇게 고쳤다).
   ★친 글자는 그대로 둔다 — 내가 친 것이 임의로 바뀌면 「내가 친 게 아닌데?」가 된다.
     대신 아래 요약줄에 「…의 주코드로 찾았습니다」를 적는다.
   ★표는 한 번만 읽어 둔다(_somAlias). 늦게 도착해도 그때 한 번 다시 그린다. */
var _somAlias=null, _somAliasBusy=false, _somVia='';
function somAliasLoad(){
  if(_somAlias || _somAliasBusy) return;
  _somAliasBusy=true;
  var m={}, left=2, ok=true;
  var done=function(bad){ if(bad) ok=false; if(--left) return; _somAliasBusy=false;
    if(!ok){ _somAlias=null; return; }            /* 실패하면 굳히지 않는다 — 다음 조회에서 다시 */
    _somAlias=m;
    if((document.getElementById('q').value||'').trim()) somRender();   /* 이미 친 글자가 있으면 다시 걸러 준다 */
  };
  ['/prod/extItemList.do','/prod/xrefList.do'].forEach(function(u){
    fetch(CTX+u, { method:'POST', credentials:'same-origin',
            headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
      .then(function(r){ return r.json(); })
      .then(function(j){ ((j&&j.data)||[]).forEach(function(o){
              var e=(''+(o.extItemCd||'')).trim(), p=(''+(o.prodCd||'')).trim();
              if(e && p && e!==p && !m[e]) m[e]=p; }); done(); })
      .catch(function(){ done(true); });
  });
}
/* 친 글자가 «서브코드 그 자체»면 주코드로 바꾼다. 이름·부분검색은 건드리지 않는다(코드 한 개일 때만). */
function somQuery(){
  var raw=(document.getElementById('q').value||'').trim();
  _somVia='';
  if(!raw || !_somAlias) return raw.toLowerCase();
  var main=_somAlias[raw];
  if(main){ _somVia=raw+' → 주코드 '+main; return main.toLowerCase(); }
  return raw.toLowerCase();
}
/* 자료를 년월 × (사업장 ▸ 품목) 격자로 편다 */
function somBuild(){
  var q=somQuery();
  var stock={}; (RAW.stock||[]).forEach(function(s){ stock[''+s.prodCd]=Number(s.curQty)||0; });
  var grp={}, gord=[], yms={}, yord=[], cell={}, pset={};
  (RAW.months||[]).forEach(function(r){
    var cd=''+(r.prodCd||''), ym=''+(r.ym||''), q0=Number(r.outQty)||0;
    var gn=(''+(r.bizNm||'')).trim()||'(사업장없음)', gk=''+(r.bizKey||''); if(!gk) gk='~'+gn;
    if(!cd||!ym) return;
    if(q && (gn+' '+cd+' '+(r.prodNm||'')).toLowerCase().indexOf(q)<0) return;
    var g=grp[gk]; if(!g){ g=grp[gk]={key:gk, nm:gn, tot:0, newTot:0, items:{}, iord:[]}; gord.push(gk); }
    var it=g.items[cd]; if(!it){ it=g.items[cd]={cd:cd, nm:(r.prodNm||''), seq:(r.prodSeq||''), tot:0}; g.iord.push(cd); }
    it.tot+=q0; g.tot+=q0; g.newTot+=(Number(r.newQty)||0); pset[cd]=1;
    if(!(ym in yms)){ yms[ym]=0; yord.push(ym); }   /* «있나»는 in 으로 (2026-11-24) — 합계가 0 인 달 첫 줄에서 같은 달이 다시 들어가지 않게 */
    yms[ym]+=q0;
    var k=ym+'|'+gk+'|'+cd; cell[k]=(cell[k]||0)+q0;
  });
  /* ★열 차례 (2026-10-26 「기존 것 유지하고 발생내역을 맨 뒤로」) — 종전 원천(정산서·발주현황표) 사업장은 종전처럼 «종전 원천 출고량» 큰 순으로 왼쪽,
     토더·대상·판매전표만으로 생긴 사업장(거래처)은 그 뒤에 따로(그 안에서는 출고량 큰 순). newQty 가 없는 옛 서버 응답이면 종전 정렬 그대로. */
  function _old(g){ return g.tot-(g.newTot||0); } function _isNew(g){ return (g.newTot||0)>0 && _old(g)<=0; }
  gord.sort(function(a,b){ var A=grp[a], B=grp[b], na=_isNew(A)?1:0, nb=_isNew(B)?1:0; if(na!==nb) return na-nb;
    var ta=na?A.tot:_old(A), tb=nb?B.tot:_old(B); return tb-ta || A.nm.localeCompare(B.nm); });   // 많이 나간 사업장이 왼쪽
  gord.forEach(function(gk){ var g=grp[gk]; g.iord.sort(function(a,b){ return g.items[b].tot-g.items[a].tot || a.localeCompare(b); }); });
  yord.sort(function(a,b){ return b.localeCompare(a); });                                              // 최근월부터
  /* ★■ 품목 합계 묶음 (2026-11-16 사용자 「품목별 합계 열 추가」) — 같은 품목이 사업장 묶음(거래처관리 매칭코드)마다 다른 열에 나뉘어
       「11-02~11-16 출고 31개인데 23개」로 읽혔다(공용 23 · 레이어드 3 · 아티스트 5). 사업장과 상관없이 품목마다 모은 열을 맨 앞에 둔다.
       열쇠 '#ALL' — 셀을 누르면 사업장 조건 없이 그 품목 전체 내역(somDetail). 사업장 수·엑셀 기간 합계에는 넣지 않는다. */
  if(gord.length){
    var ALL={key:'#ALL', nm:'■ 품목 합계 (사업장 전체)', tot:0, newTot:0, items:{}, iord:[], all:true};
    gord.forEach(function(gk){ var g=grp[gk]; g.iord.forEach(function(cd){ var s=g.items[cd], a=ALL.items[cd];
      if(!a){ a=ALL.items[cd]={cd:cd, nm:s.nm, seq:s.seq, tot:0}; ALL.iord.push(cd); }
      a.tot+=s.tot; ALL.tot+=s.tot; }); });
    yord.forEach(function(ym){ gord.forEach(function(gk){ grp[gk].iord.forEach(function(cd){ var v=cell[ym+'|'+gk+'|'+cd]; if(v){ var kk=ym+'|#ALL|'+cd; cell[kk]=(cell[kk]||0)+v; } }); }); });
    ALL.iord.sort(function(a,b){ return ALL.items[b].tot-ALL.items[a].tot || a.localeCompare(b); });
    grp['#ALL']=ALL; gord.unshift('#ALL');
  }
  var cols=[]; gord.forEach(function(gk){ grp[gk].iord.forEach(function(cd,i){ cols.push({g:gk, cd:cd, first:i===0}); }); });
  return { stock:stock, grp:grp, gord:gord, cols:cols, yms:yms, yord:yord, cell:cell, nprod:Object.keys(pset).length };
}
/* 년월 칸 밑줄 — 그 달 납기일자 중 정산서로 읽은 날수 / 발주현황표로 읽은 날수 */
/* (2026-09-03 「표시 빼줘」) 년월 칸의 정산/발주 일수 표시는 뺐다 — 함수는 남겨 두고 호출만 안 한다 */
function srcBadge(ym){
  var d=null; (RAW.srcDays||[]).forEach(function(r){ if((''+r.ym)===(''+ym)) d=r; });
  if(!d) return ''; var s=Number(d.sDays)||0, o=(Number(d.days)||0)-s;
  return '<small class="src">'+(s?('📄 정산 '+s+'일'+(o?' · ':'')):'')+(o?('발주 '+o+'일'):'')+'</small>';
}
/* ★거르기 칸은 <치는 동안> 다시 그리지 않는다 (2026-09-03 속도점검)
     종전 oninput="somRender()" 는 글자 하나마다 표를 통째로 다시 만들었다 —
     12개월(열 2,415 · DOM 셀 29,811) 기준 실측 1,496ms(레이아웃만 884ms)라
     한 글자에 1.5초씩 멈췄고, 한글은 조합 중에도 event 가 떠서 더 잦았다.
     ⇒ 마지막 입력 뒤 300ms 조용할 때 한 번만 그린다. Enter 는 즉시. */
var _somFindT=null;
function somFindLater(){ if(_somFindT) clearTimeout(_somFindT); _somFindT=setTimeout(function(){ _somFindT=null; somRender(); }, 300); }
function somFindNow(){ if(_somFindT){ clearTimeout(_somFindT); _somFindT=null; } somRender(); }
/* 화면에 그려진 격자 — 셀 클릭·엑셀이 다시 만들지 않고 이걸 쓴다(실측 somBuild 84ms).
   지금 표에 보이는 것과 같은 격자라 오히려 어긋날 일이 없다. */
var _somM=null, _somTiming='', _somPick='';
/* ★★열 가상화 (2026-09-04 「그린 다음에도 한참 있다가 클릭됨」) —
     열 2,415 × 줄 11 = 셀 26,000 을 한꺼번에 DOM 에 두면 그리기(1.2초)보다 <그 뒤>가 문제였다 : 브라우저가 접근성 트리·
     확장 프로그램 스캔·합성 레이어를 3만 셀에 대해 마저 처리하는 동안 화면이 몇 초씩 안 눌렸다(사용자 크롬 실측 — 내장 브라우저엔 없음).
     ⇒ DOM 에는 <보이는 열 + 좌우 여유 BUF 열>만 두고, 나머지 폭은 빈 칸(spacer) 하나로 채운다. 표 전체 폭·스크롤바는 종전과 같고
       옆으로 밀면 scroll 이벤트에서 창을 옮겨 다시 그린다(셀 ~700개라 수 ms). 고정칸(년월·합계)·2단 머리·클릭·엑셀 동작은 그대로. */
var COLW=112, BUF=20, _somRS=-1, _somRE=-1;
/* ── 정산서만 오고 발주현황표가 없는 날 (2026-11-24 사용자 「정산서만 오고 발주현황표 누락이네요」 → 「메시지 처리」) ──
     서버 selectSettleNoPoDays = 정산서 줄 중 같은 납기일자·같은 품목의 발주현황표 줄(같은 발주번호 또는 같은 출고장)이 없는 것 — 이 표의 「(정산서·발주없음)」 줄과 같은 규칙.
     · dayMissing='Y' = 그날 그 물류센터 발주현황표가 «통째로» 없다 → 굵게, 날짜별로 센터를 모아 적는다(2026-09-21 평택·용인·오산…). 발주현황표를 올리면 점포로 나뉜다.
     · 'N' = 발주현황표는 있는데 그 품목만 없다(거의 날마다 한두 줄) → 건수만 요약하고 [펼치기]로 목록.
     옛 서버(noPoDays 없음)면 아무것도 안 띄운다. 검색어가 있으면 표에 보이는 품목만(같은 날 이어서). */
var _npoOpen=false;
/* ★「그 품목만 없는」 줄·목록은 뺐다 (2026-11-24 사용자 「발주현황표 대비 정산서 누락 조회화면 구성 · 이미지 화면처럼은 제거」) —
     대부분 같은 삼성 품목이 두 자료에서 다른 상품코드로 저장된 것이라(올해 432줄 중 407) 여기서 날짜만 늘어놓아서는 쓸모가 없었다.
     그 일은 새 화면 「정산서 누락 조회」(매출 관리)가 원인별로 맡는다. 여기는 «발주현황표가 통째로 없는 날» 한 줄만 + 그 화면으로 가는 링크. */
function npoPaint(list){
  var box=document.getElementById('npo'); if(!box) return;
  list=list||[];
  var q=((document.getElementById('q')||{}).value||'').trim(), byQ=!!q;
  if(byQ){ var vis={}; ((_somM&&_somM.cols)||[]).forEach(function(c){ vis[String(c.cd)]=1; }); list=list.filter(function(r){ return vis[String(r.prodCd)]; }); }
  var agg={}, Y=[]; list.forEach(function(r){ if(r.dayMissing!=='Y') return; var k=r.dlvDt+'|'+r.dcCd; var x=agg[k]; if(!x){ x=agg[k]={ dlvDt:r.dlvDt, dcCd:r.dcCd, dcNm:r.dcNm, lineCnt:0, qty:0 }; Y.push(x); } x.lineCnt+=Number(r.lineCnt)||0; x.qty+=Number(r.qty)||0; });
  if(!Y.length){ box.hidden=true; box.innerHTML=''; return; }
  var d10=function(v){ v=String(v||''); return v.length===8 ? v.slice(0,4)+'-'+v.slice(4,6)+'-'+v.slice(6,8) : v; };
  var md=function(v){ v=String(v||''); return v.length===8 ? (+v.slice(4,6))+'/'+(+v.slice(6,8)) : v; };
  var nf=function(v){ var x=Number(v)||0; return (Math.round(x*10)/10).toLocaleString(); };
  var sum=function(a,k){ return a.reduce(function(t,r){ return t+(Number(r[k])||0); },0); };
  var by={}, ord=[]; Y.forEach(function(r){ var k=String(r.dlvDt); if(!by[k]){ by[k]=[]; ord.push(k); } by[k].push(r.dcNm||r.dcCd); });
  var h='⚠️ <b>발주현황표가 없는 날 '+Y.length+'곳</b> ('+esc(md(Y[0].dlvDt)+' '+(Y[0].dcNm||Y[0].dcCd))+(Y.length>1?' 외':'')+') — 그날 정산서는 점포를 몰라 「(정산서·발주없음)」';
  if(byQ) h+=' <span style="color:#8a7a5a">(검색 품목 기준)</span>';
  /* [자세히]·[정산서 누락 조회 →] 링크는 뺐다 (2026-11-24 사용자 「여기에서는 제거」 — 정산서 누락 조회가 매출 관리의 별도 메뉴가 됐다).
     날짜·센터 목록은 마우스를 올리면(title) 보인다. npoGo 는 쓰는 곳이 없지만 링크를 되살릴 때를 위해 남겨 둔다. */
  box.className='npo'; box.innerHTML=h; box.hidden=false;
  box.title=ord.map(function(k){ return d10(k)+' '+by[k].join('·'); }).join(String.fromCharCode(10))+String.fromCharCode(10)+'— 정산서 '+sum(Y,'lineCnt').toLocaleString()+'줄 · 수량 '+nf(sum(Y,'qty'))+'. 그날 그 센터 발주현황표를 올리면 점포로 나뉩니다(재고 수량은 이미 맞음).';
}
/* 「정산서 누락 조회 →」 — 셸의 그 메뉴를 누르고, 이 화면의 기간을 넘긴다(그 화면이 열리며 받아 간다) */
function npoGo(){
  var P=window.parent; if(!P || P===window){ return; }
  try{ P.konetSettleGapRange={ fr:((document.getElementById('frDt')||{}).value||'').replace(/-/g,''), to:((document.getElementById('toDt')||{}).value||'').replace(/-/g,''), tab:'S' }; }catch(e){}
  var a=P.document.querySelector('a.mi[data-key="settleGap"]'); if(a) a.click();
  try{ var f=P.document.getElementById('if-settleGap'); if(f && f.contentWindow && typeof f.contentWindow.konetShown==='function') f.contentWindow.konetShown(); }catch(e){}
}
function somRender(){
  if(!RAW) return;
  var m=_somM=somBuild(), card=document.getElementById('card');
  _somRS=-1; _somRE=-1;
  if(!m.cols.length){ card.innerHTML='<div class="empty">해당 기간에 출고가 없습니다.</div>'; document.getElementById('cnt').textContent='-'; npoPaint(RAW.noPoDays); return; }
  var grand=0; m.yord.forEach(function(ym){ grand+=m.yms[ym]; }); m.grand=grand;
  var stkTot=0, seen={}; m.cols.forEach(function(c){ var v=m.stock[c.cd]; if(v!=null && !seen[c.cd]){ seen[c.cd]=1; stkTot+=v; } }); m.stkTot=stkTot; m.stkAny=Object.keys(seen).length>0;
  somPaint(true);
  document.getElementById('cnt').innerHTML='사업장 <b>'+num(m.gord.filter(function(k){ return k!=='#ALL'; }).length)+'</b>곳 · 품목 <b>'+num(m.nprod)+'</b>종 · <b>'+num(m.yord.length)+'</b>개월 · 기간 출고 <b>'+num(grand)+'</b>'
    /* 서브코드로 쳤을 때 «무엇으로 찾았는지» 밝힌다 — 친 글자는 그대로 두므로 이 줄이 없으면 사람이 알 길이 없다 */
    + (_somVia ? ' · <span style="color:#0e6657;font-weight:700">'+esc(_somVia)+'</span> <span style="color:#8a98a8">로 찾았습니다(매칭코드)</span>' : '');
  somFit();
  npoPaint(RAW.noPoDays);   /* 알림 줄도 표와 같은 품목으로 (2026-11-24 「검색한 품목에 해당하는 날만」) */
}
/* 지금 보이는 열 범위 [vs,ve) — 고정칸 240px 뒤부터 */
function somVis(){
  var card=document.getElementById('card'), n=_somM.cols.length;
  var sl=card.scrollLeft, w=card.clientWidth||1200;
  var vs=Math.max(0, Math.floor((sl-240)/COLW)), ve=Math.min(n, Math.ceil((sl+w-240)/COLW)+1);
  return {vs:vs, ve:Math.max(ve, Math.min(n, vs+1))};
}
/* 창 [rs,re) 를 그린다 — force 가 아니면 보이는 범위가 그려진 창 안에 있을 때 건너뛴다 */
function somPaint(force){
  var m=_somM; if(!m || !m.cols.length) return;
  var card=document.getElementById('card'), n=m.cols.length, v=somVis();
  if(!force && v.vs>=_somRS && v.ve<=_somRE) return;
  var rs=Math.max(0, v.vs-BUF), re=Math.min(n, v.ve+BUF);
  _somRS=rs; _somRE=re;
  var cols=m.cols.slice(rs, re), lw=rs*COLW, rw=(n-re)*COLW;
  var spL = lw>0, spR = rw>0;
  /* ★표 폭을 명시해야 table-layout:fixed 가 살아 colgroup 폭(빈 칸 포함)이 그대로 먹는다 — width:auto 면 자동 레이아웃으로 돌아가 빈 칸이 0 이 된다 */
  var h='<table class="mx" style="width:'+(240+n*COLW)+'px"><colgroup><col style="width:150px"><col style="width:90px">'+(spL?'<col style="width:'+lw+'px">':'')
       +new Array(cols.length+1).join('<col style="width:'+COLW+'px">')+(spR?'<col style="width:'+rw+'px">':'')+'</colgroup>';
  /* 머리 1단 = 사업장(창 안에 든 열 수만큼 colspan) */
  h+='<thead><tr class="r1"><th class="cn">년월 / 사업장</th><th class="rt">합계</th>'+(spL?'<th class="sp"></th>':'');
  var i=0; while(i<cols.length){ var gk=cols[i].g, j=i; while(j<cols.length && cols[j].g===gk) j++; var g=m.grp[gk];
    h+='<th class="gh'+(cols[i].first?' gs':'')+(gk==='#ALL'?' al':'')+'" colspan="'+(j-i)+'" title="'+esc(g.nm)+'"><span class="gl">'+esc(g.nm)+'<small>'+num(g.iord.length)+'품목 · '+num(g.tot)+'</small></span></th>'; i=j; }
  h+=(spR?'<th class="sp"></th>':'')+'</tr><tr class="r2"><th class="cn">품목</th><th class="rt"></th>'+(spL?'<th class="sp"></th>':'');
  cols.forEach(function(c){ var it=m.grp[c.g].items[c.cd];
    h+='<th class="it'+(c.first?' gs':'')+(c.g==='#ALL'?' al':'')+'" data-pcd="'+esc(c.cd)+'" title="'+esc(c.cd+' '+it.nm)+' — 누르면 상품 정보"><span class="cd">'+esc(c.cd)+'</span><span class="nm">'+esc(shortNm(it.nm, m.grp[c.g].nm))+'</span></th>'; });   /* data-pcd = 상품 정보 창 (2026-11-05) */
  h+=(spR?'<th class="sp"></th>':'')+'</tr></thead><tbody>';
  var L=spL?'<td class="sp"></td>':'', R=spR?'<td class="sp"></td>':'';
  function cell(cls, ym, c, txt){ var k=ym+'|'+c.g+'|'+c.cd; return '<td class="'+cls+(c.first?' gs':'')+(c.g==='#ALL'?' al':'')+(_somPick===k?' pick':'')+'" data-ym="'+esc(ym)+'" data-g="'+esc(c.g)+'" data-cd="'+esc(c.cd)+'">'+txt+'</td>'; }
  /* ① 현재고 */
  /* 현재고 = 끝날짜가 지난 날짜면 그날까지(2026-11-04 — 이름에 그 날짜를 붙인다) · 오늘이거나 그 뒤면 «지금 재고»(원장 전체, 2026-11-22 「재고가 없는데 1로 나옴」
       — 내일 납기분이 이미 올라와 재고에서 빠져 있는데 «오늘까지»로 세면 품목별재고현황과 숫자가 달랐다). 어느 쪽인지는 서버가 stockAsOf 로 알려 준다
       (그날까지면 yyyymmdd · 지금 재고면 빈 글자 · 옛 서버면 칸이 없다 = 종전 이름표) */
  var _stkTo=((document.getElementById('toDt')||{}).value||'').slice(5);   // mm-dd
  var _stkAs=(RAW && RAW.stockAsOf!==undefined) ? String(RAW.stockAsOf||'') : null;
  if(_stkAs!==null) _stkTo=_stkAs ? (_stkAs.slice(4,6)+'-'+_stkAs.slice(6,8)) : '';
  var _stkLab=(_stkAs==='') ? '지금' : (_stkTo ? (_stkTo+' 기준') : '품목');
  var _stkTip=(_stkAs==='') ? '지금 재고 — 원장 전체(품목별재고현황과 같은 숫자). 내일 이후 납기분도 이미 올라와 있으면 빠져 있습니다. 끝날짜를 지난 날짜로 고르면 그날까지의 재고'
                            : '기간 끝날짜(납기일자)까지 반영한 품목 재고 — 그 뒤 날짜의 출고는 빼지 않습니다. 끝날짜가 오늘이거나 그 뒤면 지금 재고';
  h+='<tr class="stk"><td class="cn" title="'+_stkTip+'">현재고 <small style="font-weight:400;color:#6b7a89">('+_stkLab+')</small></td><td class="rt">'+(m.stkAny?num(m.stkTot):'')+'</td>'+L;
  cols.forEach(function(c){ var v=m.stock[c.cd]; h+= (v==null) ? '<td class="none'+(c.first?' gs':'')+'"></td>' : cell(v<0?'neg':'', '', c, num(v)); });
  h+=R+'</tr>';
  /* ② 년월 줄 */
  m.yord.forEach(function(ym){
    h+='<tr><td class="cn">'+ymLabel(ym)+'</td><td class="rt">'+num(m.yms[ym])+'</td>'+L;
    cols.forEach(function(c){ var v=m.cell[ym+'|'+c.g+'|'+c.cd]; h+= (v>0) ? cell('n', ym, c, num(v)) : '<td class="none'+(c.first?' gs':'')+'"></td>'; });
    h+=R+'</tr>';
  });
  /* ③ 기간 합계 */
  h+='<tr class="sum"><td class="cn">기간 합계</td><td class="rt">'+num(m.grand)+'</td>'+L;
  cols.forEach(function(c){ h+=cell('', '', c, num(m.grp[c.g].items[c.cd].tot)); });
  h+=R+'</tr></tbody></table>';
  var sl=card.scrollLeft, st=card.scrollTop;
  card.innerHTML=h;
  if(card.scrollLeft!==sl) card.scrollLeft=sl; if(card.scrollTop!==st) card.scrollTop=st;   /* innerHTML 교체로 스크롤이 튀지 않게 */
}
/* 옆으로 밀면 창을 옮긴다 — 한 프레임에 한 번 */
(function(){ var card=document.getElementById('card'), t=null;
  card.addEventListener('scroll', function(){ if(t) return; t=requestAnimationFrame(function(){ t=null; somPaint(false); }); });
  window.addEventListener('resize', function(){ if(_somM) somPaint(false); });
})();
/* ── 셀 클릭 → 하단 출고내역·입고내역 (2026-09-03 요청) ──
   · 월 셀 = 그 달, 현재고·기간합계 셀 = 조회 기간 전체. 사업장은 그 열의 사업장(매칭명) 하나.
   · 출고내역 = /prod/stockOutDetail.do (통합 원천: 정산서 있는 날은 정산서, 없으면 발주현황표(DC 발주 포함) + 토더·대상 발주(늘) + 판매전표 — 표와 같은 규칙, 2026-10-26)
   · 입고내역 = 같은 응답의 수불원장(ledger)에서 출고(O)가 아닌 행(입고 I·반품 R·조정 A)을 년월로 걸러 보여 준다 */
/* ── 품목 머리글 클릭 → 상품 정보 창 (2026-11-05) ──
   상품코드등록으로 건너가지 않고 여기서 본다 : 코드·상품명·규격·제조사·유형·과세·입수·입고가·판매가·도매가·적정재고·거래처·바코드·거래중지·매칭코드·현재고.
   자료 = /prod/prodList.do (findData=코드, 정확히 같은 코드만) — 한 번 받은 코드는 보관. 매칭코드 = 이 화면의 별칭표(_somAlias)를 거꾸로 */
var _spiCache={}, _spiCd='';
function spiN(v){ return Number(String(v==null?'':v).replace(/,/g,''))||0; }
function spiD8(d){ d=''+(d||''); return /^\d{8}$/.test(d)?(d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8)):d; }
function somProdInfo(cd, anchor){
  cd=String(cd||''); if(!cd) return;
  var pop=document.getElementById('somProdPop'); if(!pop){ pop=document.createElement('div'); pop.id='somProdPop'; document.body.appendChild(pop); }
  var r=anchor?anchor.getBoundingClientRect():{left:200,bottom:120,right:300};
  var left=Math.min(Math.max(8, r.left), window.innerWidth-420), top=Math.min(r.bottom+6, window.innerHeight-320);
  pop.style.left=left+'px'; pop.style.top=top+'px'; pop.style.display='block'; _spiCd=cd;
  var paint=function(p){
    if(_spiCd!==cd) return;
    var stk=null; ((RAW&&RAW.stock)||[]).forEach(function(s){ if(String(s.prodCd)===cd) stk=s.curQty; });
    var exts=[]; if(_somAlias){ for(var k in _somAlias){ if(String(_somAlias[k])===cd) exts.push(k); } }
    var row=function(l,v,cls){ return '<tr><th>'+l+'</th><td'+(cls?' class="'+cls+'"':'')+'>'+(v==null||v===''?'<span class="dim">—</span>':v)+'</td></tr>'; };
    var h='<div class="spi-hd"><b>'+esc(cd)+'</b> '+(p?esc(p.prodNm||''):'<span style="color:#a6241c">상품마스터에 없는 코드</span>')+'<span class="spi-x" onclick="somProdClose()" title="닫기">✕</span></div>';
    if(p){
      h+='<table class="spi">'
        +row('규격', esc(p.spec||''))+row('제조사', esc(p.makerNm||''))+row('유형', esc(p.typeNm||''))+row('과세', esc(p.taxGb||''))
        +row('입수', spiN(p.packQty)?num(p.packQty):'')+row('입고가 / 판매가 / 도매가', (spiN(p.inPrice)?num(p.inPrice):'—')+' / '+(spiN(p.salePrice)?num(p.salePrice):'—')+' / '+(spiN(p.wholePrice)?num(p.wholePrice):'—'),'r')
        +row('현재고 / 적정', (stk==null?'—':num(stk))+' / '+(spiN(p.safeStock)?num(p.safeStock):'—')+(stk!=null&&spiN(p.safeStock)&&spiN(stk)<spiN(p.safeStock)?' <b style="color:#a6241c">적정 미달</b>':''),'r')
        +row('거래처', esc(p.vendorNm||''))+row('바코드', esc([p.unitBarcode,p.boxBarcode].filter(Boolean).join(' / ')))
        +row('거래중지', p.stopYn==='Y'?('<b style="color:#a6241c">중지</b> '+esc(spiD8(p.stopFrDt)||'')+(p.stopMemo?' · '+esc(p.stopMemo):'')):'정상')
        +row('매칭코드 '+(exts.length?exts.length+'개':''), exts.length?exts.map(esc).join(', '):'')
        +'</table>';
    }
    h+='<div class="spi-ft"><button class="btn" onclick="somProdGo(\''+esc(cd)+'\')" title="상품코드등록 화면을 엽니다(코드는 복사해 둡니다)">상품코드등록 열기</button><span class="dim" style="font-size:11.5px">다른 머리글 누르면 바뀜 · ESC 닫기</span></div>';
    pop.innerHTML=h;
  };
  if(_spiCache[cd]!==undefined){ paint(_spiCache[cd]); return; }
  pop.innerHTML='<div class="spi-hd"><b>'+esc(cd)+'</b> <span class="dim">상품 정보 조회 중…</span><span class="spi-x" onclick="somProdClose()">✕</span></div>';
  fetch(CTX+'/prod/prodList.do', { method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'findData='+encodeURIComponent(cd) })
    .then(function(r){ return r.json(); })
    .then(function(j){ var p=null; ((j&&j.data)||[]).forEach(function(o){ if(String(o.prodCd)===cd) p=o; }); _spiCache[cd]=p; paint(p); })
    .catch(function(e){ pop.innerHTML='<div class="spi-hd"><b>'+esc(cd)+'</b> <span style="color:#a6241c">조회 실패 : '+esc(e.message)+'</span><span class="spi-x" onclick="somProdClose()">✕</span></div>'; });
}
function somProdClose(){ var pop=document.getElementById('somProdPop'); if(pop) pop.style.display='none'; _spiCd=''; }
/* [상품코드등록 열기] — 그 코드로 검색된 채 연다 (2026-11-05 「해당 코드 자동 가져가서 검색되게」) :
   처음 뜨는 화면은 localStorage(konetProdcdQ)로, 이미 떠 있는 화면은 postMessage(konetProdcdFind)로 넘긴다(prodcd.jsp pcTakeQ) */
function somProdGo(cd){ somProdClose();
  try{ localStorage.setItem('konetProdcdQ', cd); }catch(e){}
  try{ var a=parent.document.querySelector('.logi-side a.mi[data-key="prodcd"]'); if(a){ a.click();
      var f=parent.document.getElementById('if-prodcd'); if(f&&f.contentWindow){ var send=function(){ try{ f.contentWindow.postMessage({type:'konetProdcdFind', q:cd}, '*'); }catch(e){} }; send(); setTimeout(send, 800); }
      return; } }catch(e){}
  window.open(CTX+'/prod/prodcd.do','_blank'); }
document.addEventListener('keydown', function(e){ if(e.key==='Escape') somProdClose(); });
document.addEventListener('mousedown', function(e){ var pop=document.getElementById('somProdPop'); if(!pop||pop.style.display!=='block') return; if(pop.contains(e.target)) return; if(e.target.closest&&e.target.closest('th.it[data-pcd]')) return; somProdClose(); });
var DTL_LAST=null, _dtlCache={};   /* 셀별 출고·입고내역 응답 보관 (2026-11-05 속도) */
document.getElementById('card').addEventListener('click', function(ev){
  var th=ev.target.closest ? ev.target.closest('th.it[data-pcd]') : null; if(th){ somProdInfo(th.getAttribute('data-pcd'), th); return; }   /* 품목 머리글 → 상품 정보 창 (2026-11-05) */
  var td=ev.target.closest ? ev.target.closest('td[data-cd]') : null; if(!td || !RAW) return;
  var m=_somM||somBuild(), g=m.grp[td.getAttribute('data-g')]; if(!g) return;
  var it=g.items[td.getAttribute('data-cd')]; if(!it) return;
  var prev=document.querySelector('table.mx td.pick'); if(prev) prev.classList.remove('pick'); td.classList.add('pick');
  _somPick=(td.getAttribute('data-ym')||'')+'|'+td.getAttribute('data-g')+'|'+td.getAttribute('data-cd');
  somDetail({ ym:td.getAttribute('data-ym')||'', g:g, it:it });
});
function somDetail(sel){
  DTL_LAST=sel;
  var fr=document.getElementById('frDt').value.replace(/-/g,''), to=document.getElementById('toDt').value.replace(/-/g,'');
  var box=document.getElementById('dtl'); box.style.display='block';
  document.getElementById('dtlHead').innerHTML='② <b>'+(sel.ym?ymLabel(sel.ym):(dt8(fr)+' ~ '+dt8(to)))+'</b> · 사업장 <b>'+esc(sel.g.nm)+'</b>'+(sel.g.key.charAt(0)==='~'?'':' <span style="color:#6b7a89;font-weight:600">'+(sel.g.key.indexOf('STRX:')===0?'[판매전표 거래처 '+esc(sel.g.key.slice(5))+']':'[매칭코드 '+esc(sel.g.key)+']')+'</span>')+' · 품목 <b>'+esc(sel.it.cd)+'</b> '+esc(sel.it.nm)
    +'<button class="x" onclick="somDetailClose()">✕ 닫기</button>';
  document.getElementById('dtlOut').innerHTML=qprog('출고내역을 조회하는 중…'); document.getElementById('dtlIn').innerHTML=qprog('입고내역을 조회하는 중…');
  document.getElementById('dtlOutSum').textContent=''; document.getElementById('dtlInSum').textContent='';
  var gk=sel.g.key, body='ym='+encodeURIComponent(sel.ym)+'&frDt='+fr+'&toDt='+to+'&prodCd='+encodeURIComponent(sel.it.cd)+'&prodSeq='+encodeURIComponent(sel.it.seq||'')
    +(gk==='#ALL' ? '' : (gk.charAt(0)==='~' ? '&bizNm='+encodeURIComponent(sel.g.nm) : '&bizKey='+encodeURIComponent(gk)));   /* ■ 품목 합계 = 사업장 조건 없이 (2026-11-16) */
  /* ★같은 셀을 다시 누르면 서버에 안 묻고 바로 (2026-11-05 속도) — 조회 버튼을 누르면 비운다(somDetailCache). 응답은 그대로 두고 그리기만 다시 */
  var ck=body; if(_dtlCache[ck]){ var jc=_dtlCache[ck]; somDetailRender(sel, jc, fr, to); somFit(); box.scrollIntoView({behavior:'smooth', block:'nearest'}); return; }
  fetch(CTX+'/prod/stockOutDetail.do', { method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:body })
    .then(function(r){ return r.json(); })
    .then(function(j){ _dtlCache[ck]=j||{}; if(DTL_LAST!==sel) return; somDetailRender(sel, j||{}, fr, to); somFit(); box.scrollIntoView({behavior:'smooth', block:'nearest'}); })
    .catch(function(e){ document.getElementById('dtlOut').innerHTML='<div class="none">조회 실패: '+esc(e.message)+'</div>'; });
}
function somDetailClose(){ DTL_LAST=null; _somPick=''; document.getElementById('dtl').style.display='none'; var p=document.querySelector('table.mx td.pick'); if(p) p.classList.remove('pick'); somFit(); }
function dt8(d){ d=''+(d||''); return /^\d{8}$/.test(d) ? (d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8)) : d; }
/* 원천 칸 색·표 (2026-10-26) — 정산서 📄 파랑 · 판매전표 🧾 갈색 · 토더·대상 발주 🏷 보라 · 발주현황표/DC 발주 회색 */
function srcCls(s){ return s==='정산서'?'src-s':((''+s).indexOf('판매전표')===0?'src-t':((s==='토더 발주'||s==='대상 발주')?'src-d':'src-o')); }   // 「판매전표(대상)」도 판매전표 색
function srcIco(s){ return s==='정산서'?'📄 ':((''+s).indexOf('판매전표')===0?'🧾 ':((s==='토더 발주'||s==='대상 발주')?'🏷 ':'')); }
/* ★입고내역 맨 위 «승인 대기» 줄 (2026-11-22 사용자 「월별 출고현황 입고내역에도 승인 대기 줄 보이게 해줘」 — 품목별재고현황 ② 수불 내역(logi-oh.js stkLedPend)과 같은 규칙).
     직원이 재고 일괄조정에서 저장한 것은 관리자가 승인해야 원장에 조정 줄이 생긴다 — 그 사이 대기 중인 요청(/prod/stockAdjReqList.do pendOnly=Y)에서
     이 품목의 줄을 꺼내 입고내역 표 맨 위에 보인다. 요청의 조정 줄(payload JSON)은 화면이 푼다 · 품목 = prodSeq 또는 품목코드 · 증감 0 은 뺀다.
     · 30초 동안은 받아 둔 것을 쓰고, 내용이 달라졌을 때만 열려 있는 내역을 다시 그린다. 못 읽으면(옛 서버·로그인 끊김) 줄 없이 종전 화면 — 60초 뒤 다시.
     · ★원장 줄이 아니다 — 머리의 「n건 · 합」과 위 표의 현재고에 안 들어간다(머리에 「승인 대기 n건」만 덧붙인다). 고른 달과 상관없이 보인다(지금 걸려 있는 요청이라서). */
var _somPend={ t:0, list:null, busy:false, sig:'[]' }, _somDtlArgs=null;
function somPendLoad(){
  if(_somPend.busy) return;
  if(_somPend.list && (Date.now()-_somPend.t) < 30000) return;
  _somPend.busy=true;
  var done=function(list, wait){
    var sig=JSON.stringify(list.map(function(q){ return [q.reqSeq, q.payload]; })), chg=(sig!==_somPend.sig);
    _somPend.list=list; _somPend.sig=sig; _somPend.busy=false; _somPend.t=Date.now()+(wait ? 30000 : 0);
    var a=_somDtlArgs; if(chg && a && DTL_LAST===a.sel){ try{ somDetailRender(a.sel, a.j, a.fr, a.to); somFit(); }catch(e){} }
  };
  try{
    fetch(CTX+'/prod/stockAdjReqList.do', { method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'pendOnly=Y' })
      .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
      .then(function(d){ if(!d || d.result!=='OK') throw new Error('x'); done((d.data||[]).filter(function(q){ return q && q.statGb==='P'; }), false); })
      .catch(function(){ done([], true); });
  }catch(e){ done([], true); }
}
function somPendRows(it){
  var o={ h:'', n:0 }; if(!it) return o;
  somPendLoad();
  (_somPend.list||[]).forEach(function(q){
    var its=[]; try{ its=JSON.parse(q.payload||'[]')||[]; }catch(e){ its=[]; }
    its.forEach(function(x){
      if(!x) return;
      var same=(it.seq && x.prodSeq!=null && String(x.prodSeq)===String(it.seq)) || (it.cd && String(x.prodCd||'')===String(it.cd));
      if(!same) return;
      var pk=(+x.packQty||0) < 1 ? 1 : (+x.packQty), bef=Math.round(+x.befQty||0), aft=Math.round((+x.aftBox||0)*pk+(+x.aftEa||0)), d=aft-bef;
      if(!d) return;
      var bg='background:#fff8e6;border-top:1px dashed #e0b24a;border-bottom:1px dashed #e0b24a';
      o.n++;
      o.h+='<tr class="pend" data-req="'+esc(q.reqSeq)+'" title="승인 대기 중인 재고 조정 요청 #'+esc(q.reqSeq)+' — 총괄관리자·부관리자가 승인하면 재고에 반영됩니다. 지금 현재고와 합계에는 들어 있지 않습니다.">'
        +'<td style="'+bg+'">'+dt8(String(q.baseDt||'').replace(/[^0-9]/g,''))+'</td>'
        +'<td style="'+bg+'"><span style="display:inline-block;padding:0 7px;border-radius:9px;background:#f6c453;color:#5c3d00;font-size:11.5px;font-weight:800;white-space:nowrap">⏳ 승인 대기</span></td>'
        +'<td class="r" style="'+bg+';color:#8a5a00;white-space:nowrap"><span style="display:inline-block;margin-right:8px;padding:0 7px;border-radius:9px;background:#fdecc4;color:#8a5a00;font-size:11.5px;font-weight:700;white-space:nowrap">전 '+num(bef)+' → 후 '+num(aft)+'</span>'
        +  '<span style="white-space:nowrap">(증감 '+(d>0?'+':'')+num(d)+')</span></td>'
        +'<td class="l" style="'+bg+'">'+esc(q.reqUserNm||q.reqUser||'')+'</td>'
        +'<td style="'+bg+'">요청 #'+esc(q.reqSeq)+'</td>'
        +'<td class="l" style="'+bg+'">'+esc(q.remark||'')+' <span style="color:#b06a00;font-weight:700;white-space:nowrap">· 아직 재고에 반영 안 됨</span></td></tr>';
    });
  });
  return o;
}
/* ★입고내역의 «삭제된 입고» 줄 — 지운 매입전표의 입고 (2026-11-25 사용자 그림 「여기도 삭제 표현해줘」 · 품목별재고현황 stkLedDel 과 같은 자료·같은 뜻).
     지운 전표의 입고는 원장에서 흔적 없이 빠진다 — 「조정으로 맞춘 재고가 왜 줄었나」를 이 화면으로는 알 수 없었다(1000736038 : 11-18 수정재고 412 뒤 11-22 에 250 입고 전표 삭제).
     자료 = /prod/prodDelPurchList.do (품목 하나 · 60초 캐시 · 내용이 달라졌을 때만 열려 있는 내역을 다시 그림 · 실패·옛 서버면 줄 없음).
     보이는 조건 = 고른 달(없으면 조회 기간)에 «매입일자» 또는 «지운 날»이 드는 것 — 11월 칸에서 11-22 에 지운 9월 전표가 보인다.
     ★원장 줄이 아니다 — 머리의 「n건 · 합」·현재고에 안 든다(머리에 「삭제된 입고 n건」만 덧붙인다). 승인 대기 줄 바로 밑에 그린다(6칸).
     최근 조정 «뒤에» 지운 것(삭제 시각 > 조정 저장 시각 · 매입일자 ≤ 조정 일자)은 빨간 「조정 뒤 삭제 — 그때 맞춘 재고가 n 줄었습니다」. 규칙을 바꾸면 logi-oh.js stkLedDel 과 같이. */
var _somDel={};   /* 품목코드 → { t, list, busy, sig } */
function somDelLoad(cd){
  var c=_somDel[cd] || (_somDel[cd]={ t:0, list:null, busy:false, sig:'[]' });
  if(c.busy) return;
  if(c.list && (Date.now()-c.t) < 60000) return;
  c.busy=true;
  var done=function(list, wait, sales, off){
    sales=sales||[];   /* 지운 판매전표의 출고 줄 (2026-11-25) — 같은 응답의 sales */
    off=off||[];       /* 살아 있는 전표인데 «재고 미적용»한 줄 (2026-11-26) — 같은 응답의 off */
    var sig=JSON.stringify(list.map(function(x){ return [x.purchSeq, x.qty, x.delDttm, x.keepYn]; }).concat(sales.map(function(x){ return ['S', x.saleSeq, x.qty, x.delDttm, x.keepYn]; })).concat(off.map(function(x){ return ['X', x.ledgerSeq, x.qty]; }))), chg=(sig!==c.sig) || !!c.cfChg; c.cfChg=false;   /* cfChg = 단추를 보일지(관리자) · 전표 전체 미적용 목록이 달라졌다 */
    c.list=list; c.sales=sales; c.off=off; c.sig=sig; c.busy=false; c.t=Date.now()+(wait ? 60000 : 0);
    var a=_somDtlArgs; if(chg && a && DTL_LAST===a.sel){ try{ somDetailRender(a.sel, a.j, a.fr, a.to); somFit(); }catch(e){} }
  };
  try{
    fetch(CTX+'/prod/prodDelPurchList.do', { method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'prodCd='+encodeURIComponent(cd) })
      .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
      .then(function(d){ if(typeof d==='string'){ d=JSON.parse(d); } if(!d || d.result!=='OK') throw new Error('x'); c.cfChg=somChkCfgSet(d); done(d.data||[], false, d.sales||[], d.off||[]); })
      .catch(function(){ done([], true); });
  }catch(e){ done([], true); }
}
/* ★이 화면에서 바로 [재고 미적용]/[재고 적용] (2026-11-26 사용자 「여기에서 품목별재고현황/월별출고현황 재고 적용, 재고미적용 기능 추가해줘(여기서하면 직관적 일듯」 — 품목별재고현황(logi-oh.js stkLedAct)과 같은 규칙).
     단추·사유 창·처리 = 공용 /asset/js/stock-chk-act.js · 처리 = 재고 변동 확인과 같은 /prod/stockChkAct.do · 관리자에게만 보인다(prodDelPurchList 응답의 admin — 서버도 막는다).
     · 맨 위 「🗑 삭제된 입고·판매전표」 줄 = [재고 미적용] ↔ [재고 적용] · 회색 「재고 미적용」 줄(살아 있는 전표) = [재고 적용]
     · 입고내역의 손으로 넣은 전표 줄(PURCH · 판매 반품 SALE) · 출고내역의 판매전표 줄 = [재고 미적용] · 지운 전표를 되살려 둔 줄 = [재고 적용]
     · 그 품목만. 전표 전체를 미적용해 둔 전표는 [재고 적용] 도 전표 전체로. 끝나면 받아 둔 것을 버리고 표와 열려 있는 내역을 다시 조회한다. */
function somChkCfgSet(d){
  if(typeof window==='undefined') return false;
  var cf=window.stkChkCfg || (window.stkChkCfg={ ctx:'', admin:false, after:null });
  var was=(cf.admin ? 'A' : '')+JSON.stringify(cf.whole||[]);
  cf.admin=!!(d && d.admin==='Y'); cf.whole=(d && d.whole) || [];
  return was!==((cf.admin ? 'A' : '')+JSON.stringify(cf.whole));
}
function somChkB(o){ return (typeof window!=='undefined' && typeof window.stkChkBtn==='function') ? window.stkChkBtn(o) : ''; }
function somChkW(gb, seq){ return (typeof window!=='undefined' && typeof window.stkChkWhole==='function') ? window.stkChkWhole(gb, seq) : false; }
function somInAct(r, cd){   /* 입고내역의 원장 줄 */
  var g=''+(r.refGb||''), n=''+(r.refNo||''), q=(r.ioGb==='O') ? -(Number(r.qty)||0) : (Number(r.qty)||0);
  if(g==='PURCH' || g==='SALE') return somChkB({ act:'X', gb:g, no:n, cd:cd, q:q, nm:n });
  if(somKeepRow(r)){ var b=g.slice(0,g.length-1), i=n.indexOf('#'), sq=(i>0) ? n.slice(i+1) : '';
    return somChkB({ act:'U', gb:b, no:n, cd:(somChkW(b, sq) ? '' : cd), del:1, q:q, nm:(i>0 ? n.slice(0,i) : n) }); }
  return '';
}
function somOutAct(r, cd){  /* 출고내역의 판매전표 줄 — 근거번호는 ordNo(「일자-번호」) */
  var s=''+(r.src||''); if(s.indexOf('판매전표')!==0) return '';
  var n=''+(r.ordNo||''), q=-(Number(r.qty)||0); if(!n) return '';
  if(s.indexOf('삭제')<0) return somChkB({ act:'X', gb:'SALE', no:n, cd:cd, q:q, nm:n });
  var hit=null; ((_somDel[cd] && _somDel[cd].sales) || []).forEach(function(x){ if(!hit && x.keepYn==='Y' && (String(x.saleDt||'').replace(/[^0-9]/g,'').slice(0,8)+'-'+(x.saleNo||''))===n) hit=x; });
  return hit ? somChkB({ act:'U', gb:'SALE', seq:hit.saleSeq, cd:(somChkW('SALE', hit.saleSeq) ? '' : cd), del:1, q:q, nm:n }) : '';
}
(function(){ if(typeof window==='undefined') return; var cf=window.stkChkCfg || (window.stkChkCfg={ ctx:'', admin:false, after:null }); cf.ctx=CTX;
  cf.after=function(){ _somDel={}; _somRun={}; var s=DTL_LAST; try{ somLoad(); }catch(e){} if(s){ try{ somDetail(s); }catch(e){} } }; })();
function somDelRows(sel, fr, to, ledger){
  var o={ h:'', n:0 }, it=sel && sel.it; if(!it || !it.cd) return o;
  var cd=String(it.cd).trim(); somDelLoad(cd);
  var L=(_somDel[cd] && _somDel[cd].list) || []; if(!L.length) return o;
  var lastA=null; (ledger||[]).some(function(x){ if(x && x.ioGb==='A' && x.adjBef!=null && x.adjAft!=null){ lastA=x; return true; } return false; });
  var adjAt=(lastA && lastA.regDttm) ? String(lastA.regDttm) : '', adjDt=lastA ? String(lastA.trxDt||'').replace(/[^0-9]/g,'').slice(0,8) : '', fx=!!(lastA && lastA.adjFixYn==='Y');   /* fx = 최근 조정이 고정(🔒 · 2026-11-25) — 그 앞 날짜 전표를 지워도 현재고는 그대로 */
  var ym=String((sel && sel.ym)||''), inP=function(d8){ return !!d8 && (ym ? d8.slice(0,6)===ym : (d8>=fr && d8<=to)); };
  var bg='background:#f4f5f7;border-top:1px dashed #b9c0c9;border-bottom:1px dashed #b9c0c9;color:#6b7683';
  L.forEach(function(x){
    var q=Number(x.qty)||0; if(!q) return;
    var pd8=String(x.purchDt||'').replace(/[^0-9]/g,'').slice(0,8), del=String(x.delDttm||''), del8=del.replace(/[^0-9]/g,'').slice(0,8);
    if(!(inP(pd8) || inP(del8))) return;
    /* 재고 미적용(삭제를 재고에 적용 안 함 — 재고 변동 확인)이면 이 수량은 재고에 그대로 있다 : 파란 표 + 「재고에 그대로」 · 빨간 꼬리 없음 (2026-11-26 「재고미적용이면 표시도 틀려야함 월별재고도 마찬가지」) */
    var keep=(x.keepYn==='Y');
    var after=!keep && !!(adjAt && del && del > adjAt && adjDt && pd8 && pd8 <= adjDt && !(fx && pd8 < adjDt)), who=x.delUserNm || x.delUser || '';
    o.n++;
    o.h+='<tr class="del" data-purch="'+esc(x.purchSeq)+'" title="지운 매입전표 '+esc(dt8(pd8))+'-'+esc(x.purchNo||'')+' 의 입고 '+num(q)+' — '+esc(del.slice(0,16))+(keep ? ' 에 삭제됐지만 «재고 미적용»이라 재고에 그대로 있습니다(아래 그 날짜 입고 줄). 바꾸려면 재고 관리 ▸ 재고 변동 확인.' : ' 에 삭제돼 재고에서 빠졌습니다. 지금 현재고와 합계에는 들어 있지 않습니다.')
      +(after ? ' 최근 재고조정('+esc(adjAt.slice(0,16))+') 뒤에 지워, 그때 맞춘 재고가 '+num(q)+' 줄었습니다 — 재고 일괄조정으로 다시 맞추세요.' : '')+'">'
      +'<td style="'+bg+';white-space:nowrap">'+dt8(pd8)+'</td>'
      +'<td style="'+bg+'"><span style="display:inline-block;padding:0 7px;border-radius:9px;background:#e3e6ea;color:#55606c;font-size:11.5px;font-weight:800;white-space:nowrap">🗑 삭제된 입고</span>'+(keep ? '<span class="led-keep" style="display:inline-block;margin-left:3px;margin-right:4px;padding:0 6px;border-radius:9px;background:#e8f1fb;color:#1b4f86;border:1px solid #b9d2ee;font-size:11px;font-weight:800;white-space:nowrap">재고 미적용</span>' : '')+'</td>'
      +'<td class="r" style="'+bg+';white-space:nowrap">'+num(q)+'</td>'
      +'<td class="l" style="'+bg+'">'+esc(x.vendorNm||'')+'</td>'
      +'<td style="'+bg+'">PURCH '+esc(pd8+'-'+(x.purchNo||''))+'</td>'
      +'<td class="l" style="'+bg+'">'+esc(del.slice(5,16))+(who ? ' '+esc(who) : '')+(keep ? ' 삭제 — <b style="color:#1b4f86">재고 미적용 · 재고에 그대로</b>' : ' 삭제 — 재고에서 빠짐')
      +  (after ? ' <span class="led-delw" style="color:#c0392b;font-weight:700;white-space:nowrap">· 조정 뒤 삭제 — 그때 맞춘 재고가 '+num(q)+' 줄었습니다</span>' : '')
      +  somChkB({ act:(keep ? 'U' : 'X'), gb:'PURCH', seq:x.purchSeq, cd:((keep && somChkW('PURCH', x.purchSeq)) ? '' : cd), del:1, q:q, nm:pd8+'-'+(x.purchNo||'') })+'</td></tr>';
  });
  return o;
}
/* ★출고내역의 «삭제된 판매전표» 줄 (2026-11-25 사용자 「품목별재고, 월별재고에 판매등록 삭제는 상관없나요」 — logi-oh.js stkLedDel 의 판매 줄과 같은 자료·같은 뜻).
     판매전표를 지우면 그 출고가 원장에서 빠져 재고가 그만큼 «는다». 자료는 somDelLoad 가 받아 둔 같은 응답의 sales(품목 하나).
     보이는 조건 = 고른 달(없으면 조회 기간)에 «판매일자» 또는 «지운 날»이 드는 것 + 고른 사업장이 「품목 합계」이거나 그 거래처의 판매전표 열(STRX:거래처코드)일 때.
     ★원장 줄이 아니다 — 머리 합계·현재고에 안 든다(머리에 「삭제된 판매전표 n건」만). 출고내역 표 맨 위 8칸. */
function somDelSalesRows(sel, fr, to, ledger){
  var o={ h:'', n:0 }, it=sel && sel.it; if(!it || !it.cd) return o;
  var cd=String(it.cd).trim(); somDelLoad(cd);
  var L=(_somDel[cd] && _somDel[cd].sales) || []; if(!L.length) return o;
  var gk=String((sel.g && sel.g.key)||'#ALL');
  var lastA=null; (ledger||[]).some(function(x){ if(x && x.ioGb==='A' && x.adjBef!=null && x.adjAft!=null){ lastA=x; return true; } return false; });
  var adjAt=(lastA && lastA.regDttm) ? String(lastA.regDttm) : '', adjDt=lastA ? String(lastA.trxDt||'').replace(/[^0-9]/g,'').slice(0,8) : '', fx=!!(lastA && lastA.adjFixYn==='Y');   /* fx = 최근 조정이 고정(🔒 · 2026-11-25) — 그 앞 날짜 전표를 지워도 현재고는 그대로 */
  var ym=String((sel && sel.ym)||''), inP=function(d8){ return !!d8 && (ym ? d8.slice(0,6)===ym : (d8>=fr && d8<=to)); };
  var bg='background:#f4f5f7;border-top:1px dashed #b9c0c9;border-bottom:1px dashed #b9c0c9;color:#6b7683';
  L.forEach(function(x){
    var q=Number(x.qty)||0; if(!q) return;
    if(gk!=='#ALL' && gk!==('STRX:'+String(x.custCd||''))) return;
    var sd=String(x.saleDt||'').replace(/[^0-9]/g,'').slice(0,8), del=String(x.delDttm||''), del8=del.replace(/[^0-9]/g,'').slice(0,8);
    if(!(inP(sd) || inP(del8))) return;
    var keep=(x.keepYn==='Y');   /* 재고 미적용 — 지웠지만 출고(반품)가 재고에 그대로 (2026-11-26) */
    var back=q>0, aq=Math.abs(q), after=!keep && !!(adjAt && del && del > adjAt && adjDt && sd && sd <= adjDt && !(fx && sd < adjDt)), who=x.delUserNm || x.delUser || '';
    var eff=back ? '재고로 되돌아옴' : '재고에서 다시 빠짐', effN=back ? '늘었습니다' : '줄었습니다';
    o.n++;
    o.h+='<tr class="del" data-sale="'+esc(x.saleSeq)+'" title="지운 판매전표 '+esc(dt8(sd))+'-'+esc(x.saleNo||'')+' 의 '+(back?'출고 ':'반품 ')+num(aq)+' — '+esc(del.slice(0,16))+' 에 삭제돼 '+eff+'. 지금 현재고와 합계에는 들어 있지 않습니다.'
      +(after ? ' 최근 재고조정('+esc(adjAt.slice(0,16))+') 뒤에 지워, 그때 맞춘 재고가 '+num(aq)+' '+effN+' — 재고 일괄조정으로 다시 맞추세요.' : '')+'">'
      +'<td style="'+bg+';white-space:nowrap">'+dt8(sd)+'</td>'
      +'<td class="l" style="'+bg+'">'+esc(x.custNm||'')+' (판매전표)</td>'
      +'<td style="'+bg+'"></td>'
      +'<td class="l" style="'+bg+'">판매전표 '+esc(sd+'-'+(x.saleNo||''))+(keep ? (' 삭제 — <b style="color:#1b4f86">재고 미적용 · '+(back?'출고 그대로':'반품 그대로')+'</b>') : (' 삭제 — '+eff))
      +  (after ? ' <span class="led-delw" style="color:#c0392b;font-weight:700;white-space:nowrap">· 조정 뒤 삭제 — 그때 맞춘 재고가 '+num(aq)+' '+effN+'</span>' : '')
      +  somChkB({ act:(keep ? 'U' : 'X'), gb:'SALE', seq:x.saleSeq, cd:((keep && somChkW('SALE', x.saleSeq)) ? '' : cd), del:1, q:-q, nm:sd+'-'+(x.saleNo||'') })+'</td>'
      +'<td style="'+bg+'"><span style="display:inline-block;padding:0 7px;border-radius:9px;background:#e3e6ea;color:#55606c;font-size:11.5px;font-weight:800;white-space:nowrap">🗑 삭제된 '+(back?'출고':'반품')+'</span>'+(keep ? '<span class="led-keep" style="display:inline-block;margin-left:3px;margin-right:4px;padding:0 6px;border-radius:9px;background:#e8f1fb;color:#1b4f86;border:1px solid #b9d2ee;font-size:11px;font-weight:800;white-space:nowrap">재고 미적용</span>' : '')+'</td>'
      +'<td class="r" style="'+bg+';white-space:nowrap">'+num(aq)+'</td>'
      +'<td style="'+bg+';white-space:nowrap">'+esc(del.slice(0,19))+'</td>'
      +'<td style="'+bg+';white-space:nowrap">'+esc(who)+'</td></tr>';
  });
  return o;
}
/* ★살아 있는 전표인데 «재고 미적용»한 줄 (2026-11-26 사용자 「재고미적용이면 표시도 틀려야함 월별재고도 마찬가지 적용미적용에 따라」 — logi-oh.js stkLedDel 의 off 줄과 같은 자료).
     재고 변동 확인에서 재고 미적용한 전표의 줄은 원장에서 빠져(X) 아래 내역에 안 나온다 — 「전표는 있는데 재고엔 안 들어간」 줄임을 회색 줄로 보인다(합계·현재고에 안 든다).
     매입전표 줄 → 입고내역 맨 위(6칸) · 판매전표 줄 → 출고내역 맨 위(8칸 · 「품목 합계」 열일 때만). 고른 달(없으면 조회 기간)의 전표 일자 것만. 자료는 somDelLoad 가 받아 둔 off */
function somOffRows(sel, fr, to){
  var o={ inH:'', outH:'', nIn:0, nOut:0 }, it=sel && sel.it; if(!it || !it.cd) return o;
  var cd=String(it.cd).trim(); somDelLoad(cd);
  var L=(_somDel[cd] && _somDel[cd].off) || []; if(!L.length) return o;
  var ym=String((sel && sel.ym)||''), inP=function(d8){ return !!d8 && (ym ? d8.slice(0,6)===ym : (d8>=fr && d8<=to)); };
  var gk=String((sel.g && sel.g.key)||'#ALL');
  var bg='background:#f4f5f7;border-top:1px dashed #b9c0c9;border-bottom:1px dashed #b9c0c9;color:#6b7683';
  var tag='<span class="led-keep" style="display:inline-block;margin-left:3px;margin-right:4px;padding:0 6px;border-radius:9px;background:#e8f1fb;color:#1b4f86;border:1px solid #b9d2ee;font-size:11px;font-weight:800;white-space:nowrap">재고 미적용</span>';
  L.forEach(function(x){
    var d8=String(x.trxDt||'').replace(/[^0-9]/g,'').slice(0,8); if(!inP(d8)) return;
    var q=Math.abs(Number(x.qty)||0), io=String(x.ioGb||''), who=x.chkUserNm || x.chkUser || '', memo=x.memo ? esc(x.memo) : '재고에 들어 있지 않음';
    var onB=somChkB({ act:'U', gb:String(x.refGb||''), seq:(x.refSeq==null ? '' : x.refSeq), no:String(x.refNo||''), cd:(somChkW(String(x.refGb||''), x.refSeq) ? '' : cd), q:((io==='O') ? -(Number(x.qty)||0) : (Number(x.qty)||0)), nm:String(x.refNo||'') });   /* [재고 적용] — 확인 글의 재고 영향은 부호 그대로(매입 반품은 음수) */
    if(String(x.refGb||'')==='SALE'){
      if(gk!=='#ALL') return;
      o.nOut++;
      o.outH+='<tr class="del off" data-led="'+esc(x.ledgerSeq)+'" title="판매전표 '+esc(x.refNo||'')+' — 전표는 살아 있지만 재고 미적용이라 출고·합계에 들어 있지 않습니다. 바꾸려면 재고 관리 ▸ 재고 변동 확인.">'
        +'<td style="'+bg+';white-space:nowrap">'+dt8(d8)+'</td><td class="l" style="'+bg+'">'+esc(x.custNm||'')+' (판매전표)</td><td style="'+bg+'"></td>'
        +'<td class="l" style="'+bg+'">판매전표 '+esc(x.refNo||'')+' — <b style="color:#1b4f86">'+memo+'</b>'+onB+'</td>'
        +'<td style="'+bg+'">'+(io==='R'?'반품':'출고')+tag+'</td>'
        +'<td class="r" style="'+bg+';white-space:nowrap;text-decoration:line-through">'+num(q)+'</td>'
        +'<td style="'+bg+';white-space:nowrap">'+esc(String(x.chkDttm||'').slice(0,19))+'</td><td style="'+bg+';white-space:nowrap">'+esc(who)+'</td></tr>';
    } else {
      o.nIn++;
      o.inH+='<tr class="del off" data-led="'+esc(x.ledgerSeq)+'" title="매입전표 '+esc(x.refNo||'')+' — 전표는 살아 있지만 재고 미적용이라 입고·합계에 들어 있지 않습니다. 바꾸려면 재고 관리 ▸ 재고 변동 확인.">'
        +'<td style="'+bg+';white-space:nowrap">'+dt8(d8)+'</td><td style="'+bg+'">'+(io==='R'?'반품':'입고')+tag+'</td>'
        +'<td class="r" style="'+bg+';white-space:nowrap;text-decoration:line-through">'+num(q)+'</td>'
        +'<td class="l" style="'+bg+'">'+esc(x.custNm||'')+'</td><td style="'+bg+'">'+esc(x.refGb||'')+' '+esc(x.refNo||'')+'</td>'
        +'<td class="l" style="'+bg+'"><b style="color:#1b4f86">'+memo+'</b>'+(who ? ' · '+esc(String(x.chkDttm||'').slice(5,16))+' '+esc(who) : '')+onB+'</td></tr>';
    }
  });
  return o;
}
/* 입고내역 줄의 근거·비고 — 지운 전표인데 «재고 미적용»이라 되살려 둔 원장 줄(근거구분 PURCHK·SALEK · 번호 뒤 #전표키)을 사람 말로 (2026-11-26) */
function somKeepRow(r){ var g=''+((r && r.refGb)||''); return g==='PURCHK' || g==='SALEK'; }
function somRef(r){ var g=''+(r.refGb||''), n=''+(r.refNo||''); if(somKeepRow(r)){ g=g.slice(0,g.length-1); var i=n.indexOf('#'); if(i>0) n=n.slice(0,i); } return esc(g)+(n?(' '+esc(n)):''); }
function somKeepTag(r){ return somKeepRow(r) ? '<span class="led-keep" style="display:inline-block;margin-right:4px;padding:0 6px;border-radius:9px;background:#e8f1fb;color:#1b4f86;border:1px solid #b9d2ee;font-size:11px;font-weight:800;white-space:nowrap" title="지운 전표의 줄입니다 — «재고 미적용»(삭제를 재고에 적용하지 않음)이라 재고에 그대로 들어 있습니다. 바꾸려면 재고 관리 ▸ 재고 변동 확인">삭제 전표 · 재고 미적용</span>' : ''; }
/* ★최근 조정 뒤 «그때 재고» + 조정 줄 「변동 ±d → n」 (2026-11-25 사용자 「월별 출고현황에도 같은 방식으로 해줘」 — 품목별재고현황 ② 수불 내역(logi-oh.js stkLedRunMap·stkLedRun)과 같은 셈).
     이 화면의 내역은 «고른 달 · 고른 사업장»뿐이라 그것만으로는 재고를 셀 수 없다 ⇒ 품목별재고현황과 같은 주소(/prod/stockList.do · 그 품목의 원장 전체)를 한 번 더 읽어 센다
     (품목마다 60초 캐시 · 내용이 달라졌을 때만 열려 있는 내역을 다시 그림 · 못 읽으면 표시 없이 종전 화면).
     · 최근 조정 = 원장 전체에서 전·후 값이 있는 첫 조정 줄(최근 일자부터). 그 위 줄 가운데 「수정재고에 포함」(처음 올린 때 가 조정 저장 전)이 아닌 것만 센다.
     · base = 원장 전체 합 − 조정 뒤 새로 반영된 입출고 합 = 지금 원장 기준 «조정 직후 재고». 수정재고와 다르면 조정 줄에 빨간 「변동 ±d → n」.
     · 입고내역 = 원장 줄이라 줄마다(ledgerSeq) 「재고 n」. 출고내역 = 사업장마다 줄이 나뉘어 있어 **그 납기일자의 첫 줄에 «그 날까지 반영한 재고»** 하나(품목 전체 — 사업장을 골라 봐도 같은 숫자).
     · 조정 줄 아래(옛 줄) · 조정이 없는 품목 · 최근 조정이 고른 달보다 뒤인 경우에는 표시가 없다. 맨 위(가장 최근) 값 = 지금 현재고.
     규칙을 바꾸면 logi-oh.js 의 두 함수와 같이(두 벌 — 이 화면은 iframe 이라 logi-oh.js 를 안 싣는다). */
var _somRun={};   /* 품목번호 → { t, m, busy, sig } */
function somRunCalc(raw){
  raw=raw||[]; var L=-1, i;
  for(i=0;i<raw.length;i++){ var a=raw[i]; if(a && a.ioGb==='A' && a.adjBef!=null && a.adjAft!=null){ L=i; break; } }
  if(L<0) return null;
  var A=raw[L], sg=function(x){ return x ? ((x.ioGb==='O') ? -(Number(x.qty)||0) : (Number(x.qty)||0)) : 0; }, d8=function(v){ return (''+(v||'')).replace(/[^0-9]/g,'').slice(0,8); };
  var pre=[], tot=0, post=0; raw.forEach(function(x){ tot+=sg(x); });
  for(i=0;i<L;i++){ var x=raw[i]; pre[i]=!!(x && x.ioGb==='O' && x.srcDttm && A.regDttm && (''+x.srcDttm) < (''+A.regDttm)); if(!pre[i]) post+=sg(x); }
  var m={ base:Math.round(tot-post), tot:Math.round(tot), aft:Math.round(Number(A.adjAft)||0), bef:Math.round(Number(A.adjBef)||0), adjSeq:(A.ledgerSeq!=null ? String(A.ledgerSeq) : ''), seq:{}, day:{} }, acc=tot-post;
  for(i=L-1;i>=0;i--){ var y=raw[i]; if(!y || pre[i]) continue; acc+=sg(y); if(y.ledgerSeq!=null) m.seq[String(y.ledgerSeq)]=Math.round(acc); m.day[d8(y.trxDt)]=Math.round(acc); }   /* 옛 줄부터 올라오므로 day 에는 그 날의 마지막(맨 위) 값이 남는다 */
  return m;
}
function somRunMap(it){
  var seq=it && it.seq ? String(it.seq) : ''; if(!seq) return null;
  var c=_somRun[seq] || (_somRun[seq]={ t:0, m:null, busy:false, sig:'' });
  if(!c.busy && !(c.t && (Date.now()-c.t) < 60000)){
    c.busy=true;
    var done=function(m, wait){
      var sig=m ? JSON.stringify([m.base, m.tot, m.aft, m.adjSeq, Object.keys(m.seq).length, Object.keys(m.day).length]) : '', chg=(sig!==c.sig);
      c.m=m; c.sig=sig; c.busy=false; c.t=Date.now()+(wait ? 60000 : 0);
      var a=_somDtlArgs; if(chg && a && DTL_LAST===a.sel){ try{ somDetailRender(a.sel, a.j, a.fr, a.to); somFit(); }catch(e){} }
    };
    try{
      fetch(CTX+'/prod/stockList.do', { method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'prodSeq='+encodeURIComponent(seq) })
        .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
        .then(function(d){ if(typeof d==='string'){ d=JSON.parse(d); } done(somRunCalc((d && d.data) || []), false); })
        .catch(function(){ done(null, true); });
    }catch(e){ done(null, true); }
  }
  return c.m;
}
/* ⚠줄 자체에 붙이던 빨간 「조정 뒤 등록」 표와 말풍선의 「바뀐 줄(추정)」 한 줄은 둘 다 뺐다 (2026-11-25 「그럼 빨간 표는 빼줘」 → 「말풍선의 바뀐 줄(추정)도 빼줘」) — 품목별재고현황과 같은 까닭(그때 수량이 달랐다는 뜻으로 읽혔다). */
/* 「재고 n」 알약 — day=true 면 출고내역(그 날까지 반영한 재고), 아니면 입고내역(그 줄까지) */
function somRunPill(m, v, day){
  if(!m || v==null) return '';
  return '<span class="led-run" style="display:inline-block;cursor:help;margin-right:6px;padding:0 6px;border-radius:9px;background:'+(v<0 ? '#fdecea' : '#fff6dd')+';color:'+(v<0 ? '#a6241c' : '#7a5200')+';border:1px solid '+(v<0 ? '#e7a9a3' : '#e3c26a')+';font-size:11px;font-weight:700;white-space:nowrap"'
       +' title="'+(day ? '이 날까지 반영한 재고입니다 (품목 전체).' : '이 줄까지 반영한 재고입니다.')+'&#10;'
       +'최근 조정(수정재고 '+num(m.aft)+(m.base!==m.aft ? ' · 지금 기준 '+num(m.base) : '')+')에서 그 뒤 입고·출고를 차례로 더하고 뺀 값 — 가장 최근 날짜가 지금 현재고('+num(m.tot)+')입니다">재고 '+num(v)+'</span>';
}
function somDetailRender(sel, j, fr, to){
  _somDtlArgs={ sel:sel, j:j, fr:fr, to:to };
  var RM=somRunMap(sel.it), runDay={};   /* 최근 조정 뒤 재고 (2026-11-25) — 아직 못 읽었으면 null, 오면 다시 그린다 */   /* 승인 대기 목록이 늦게 오면 이 값으로 다시 그린다 */
  /* 출고내역 — 납기일자별·원래 사업장별. 거래처 매칭코드 칸은 주코드와 다를 때만(재고현황 ↳ 줄과 같은 규칙, 2026-09-03 「주코드이면 보여주지 마세요」) */
  /* ★출고 줄마다 «올라온 때» + 「수정재고에 포함」 (2026-11-22 사용자 그림 「여기도 마찬가지로 시간표시」 — 품목별재고현황 수불 내역(logi-oh.js stkLedPre)과 같은 규칙).
       올라온 때(srcDttm) = 그 납기일자의 발주현황표(지나간 차수 포함)·정산서가 처음 등록된 시각(서버 #SOD_F). 원장 일자는 납기일자라, 납기 하루 전에 올라온 출고는
       조정한 날보다 뒤 일자여도 조정할 때 이미 재고에서 빠져 있다 — 올라온 때 < 최근 조정을 저장한 때(LA.regDttm) 이고 납기일자 ≥ 조정 일자면 회색 「수정재고에 포함」.
       최근 조정 = 받아 온 입고내역(j.ledger)의 첫 조정 줄(전·후 값 있음) — 고른 달에 조정이 없으면 표는 안 붙고 시각만 보인다. 판매전표 줄은 근거가 없어 빈 칸. */
  var LA=null; (j.ledger||[]).some(function(x){ if(x && x.ioGb==='A' && x.adjBef!=null && x.adjAft!=null){ LA=x; return true; } return false; });
  var LAd=LA ? (''+(LA.trxDt||'')).replace(/-/g,'') : '';
  /* ★자리 = 품목별재고현황 수불 내역과 같게 (2026-11-22 사용자 그림 「뒤에 올린시간표시 품목별재고현황처럼」) — 「올린 시간」은 줄 맨 뒤 칸(그 화면의 등록일시 자리 · 회색 · 연-월-일 시:분:초),
       「수정재고에 포함」 표는 수량 앞(그 화면 stkLedPre 와 같은 자리). 처음 판은 원천과 수량 사이 한 칸에 「월-일 시:분 + 표」를 같이 두었다. */
  /* 맨 뒤 칸 — 처음 올린 시간 + 「↻ 다시 만든 때」 (2026-11-22 사용자 「월별재고현황에도」 — 품목별재고현황 ② 등록일시 칸(logi-oh.js stkLedReg)과 같은 모양·같은 값).
       ledDttm = 그 납기일자의 재고 줄(원장 출고)이 다시 만들어진 때(정산서 도착 · 출고반영 재집계 — 서버 #SOD_L). 올린 시간보다 늦을 때만(분 단위) 뒤에 작게 붙인다.
       올린 시간이 없고 다시 만든 때만 있으면 그것만(품목별재고현황의 종전 글자와 같다). */
  var tmOf=function(r){
    var t=''+(r.srcDttm||''), g=''+(r.ledDttm||'');
    if(!t) return g ? '<span style="color:#9aa7b3;white-space:nowrap">'+esc(g.slice(0,19))+'</span>' : '';
    var h='<span class="led-src" style="color:#48606f;font-weight:600;white-space:nowrap" title="이 출고의 발주현황표·정산서를 처음 올린 시간 '+esc(t)+' — 재고에서는 이때부터 빠져 있었습니다">'+esc(t.slice(0,19))+'</span>';
    if(g && t.slice(0,16) < g.slice(0,16)) h+=' <span class="led-re" style="color:#9aa7b3;font-size:11px;white-space:nowrap" title="이 재고 줄이 다시 만들어진 때 '+esc(g)+' (정산서 도착 · 출고반영 재집계) — 출고가 이때 나간 것이 아닙니다">↻ '+esc(g.slice(5,16))+'</span>';
    return h;
  };
  /* 맨 뒤 「등록자」 칸 — 처음 올린 사람 + 「↻ 재고 줄을 다시 만든 사람」 (2026-11-22 사용자 「월별재고현황도 같은 스타일로」 — 품목별재고현황 ② 등록자 칸(logi-oh.js stkLedUser)과 같은 모양·같은 값).
       두 사람이 같거나 한쪽만 알면 이름 하나 · 둘 다 모르면(옛 서버 · 판매전표 줄) 빈 칸. 규칙을 바꾸면 그 함수와 같이 */
  var userOf=function(r){
    var su=(''+(r.srcUser||'')).trim(), lu=(''+(r.ledUser||'')).trim(), sn=r.srcUserNm||su, ln=r.ledUserNm||lu;
    if(!su && !lu) return '';
    if(!su || !lu || su===lu) return '<span style="color:#9aa7b3;white-space:nowrap" title="'+esc(su||lu)+'">'+esc(su?sn:ln)+'</span>';
    return '<span class="led-src" style="color:#48606f;font-weight:600;white-space:nowrap" title="이 출고의 발주현황표·정산서를 처음 올린 사람 ('+esc(su)+')">'+esc(sn)+'</span>'
         +' <span class="led-re" style="color:#9aa7b3;font-size:11px;white-space:nowrap" title="이 재고 줄을 다시 만든 사람 ('+esc(lu)+') — 정산서를 올렸거나 출고반영 재집계를 돌린 사람">↻ '+esc(ln)+'</span>';
  };
  var preOf=function(r){  /* 수량 앞 — 조정할 때 이미 올라와 있던 출고 */
    var t=''+(r.srcDttm||''); if(!t) return '';
    if(!(LA && LA.regDttm && t < (''+LA.regDttm) && (''+(r.dlvDt||'')).replace(/-/g,'') >= LAd)) return '';
    return '<span class="led-pre" style="display:inline-block;margin-right:5px;padding:0 5px;border-radius:9px;background:#eef1f4;color:#5a6b7a;border:1px solid #cfd8e3;font-size:10.5px;font-weight:700;white-space:nowrap"'
         +' title="이 출고는 '+esc(t.slice(0,16))+' 에 이미 올라와 있었습니다 — 최근 조정('+esc((''+LA.regDttm).slice(0,16))+') 전이라, 그때 맞춘 수정재고에 이미 들어 있습니다. 재고를 셀 때 다시 빼지 않습니다.">수정재고에 포함</span>';
  };
  /* 부분출고 설명 (2026-11-24 사용자 「홍대 0 으로 나오면 사용자 물어볼텐데」) — 정산서 줄인데 그 발주가 다 안 나간 경우만 수량 앞에 붙인다.
       예) 발주 성수 4 · 강남 3 · 홍대 1 = 8 인데 정산서 출고 2 → 성수 1 · 강남 1 · 홍대 0 — 각 줄에 「발주 n → k (전체 8 → 2)」(같은 날 「문구 조금 더 짧게」·「좀더 간단하게」로 두 번 줄임 — 풀이는 말풍선).
       정산서엔 사업장이 없어 수량은 발주 비율로 «정수로» 나눈 값이다(서버 selectStockOutDetail). 서버가 세 칸(ordQty·lineOrdQty·lineOutQty)을 안 주면(옛 서버) 아무것도 안 붙인다 */
  var partOf=function(r){
    if((''+(r.src||''))!=='정산서' || r.lineOrdQty==null || r.lineOutQty==null || r.ordQty==null) return '';
    var lo=Number(r.lineOrdQty)||0, lv=Number(r.lineOutQty)||0, oq=Number(r.ordQty)||0, q=Number(r.qty)||0;
    if(!(lo>0) || !(lv<lo) || lv<0) return '';
    return '<span class="led-part" style="display:inline-block;margin-right:5px;padding:0 5px;border-radius:9px;background:#fff4e5;color:#9a5a00;border:1px solid #f0cf9a;font-size:10.5px;font-weight:700;white-space:nowrap"'
         +' title="정산서에 이 발주는 '+num(lo)+'개 중 '+num(lv)+'개만 출고된 것으로 왔습니다. 정산서에는 사업장별 수량이 없어, 출고된 '+num(lv)+'개를 발주 비율로 나눈 값입니다(이 사업장 발주 '+num(oq)+' → '+num(q)+'). 실제로 어느 사업장이 받았는지는 정산서로는 알 수 없습니다.">발주 '+num(oq)+' → '+num(q)+' (전체 '+num(lo)+' → '+num(lv)+')</span>';   /* 글자 = 문장으로 (2026-11-24 사용자 「이렇게 하면 사용자는 무슨말인지 잘모름」 — 종전 「발주 4 · 8개 중 2개 출고」는 매장 발주와 전체 발주가 한 줄에 섞여 읽히지 않았다) */
  };
  var out=j.out||[], os=0, h='', ds=somDelSalesRows(sel, fr, to, j.ledger), of=somOffRows(sel, fr, to);   /* ds = 삭제된 판매전표 줄 · of = 재고 미적용 줄(둘 다 맨 위 · 합계에는 안 든다) */
  if(!out.length && !ds.n && !of.nOut) h='<div class="none">출고가 없습니다.</div>';
  else { h='<table class="fx"><thead><tr><th>납기일자</th><th>사업장 [사업장코드]</th><th>물류센터</th><th>거래처 매칭코드 · 품목명</th><th>원천</th><th>수량</th><th title="그 납기일자의 발주현황표·정산서를 처음 올린 시간 · 뒤의 ↻ = 그 재고 줄이 다시 만들어진 때(정산서 도착·재집계) — 최근 조정보다 먼저 올린 출고는 수량 앞에 「수정재고에 포함」">올린 시간</th><th title="앞 = 그 납기일자의 발주현황표·정산서를 처음 올린 사람 · 뒤의 ↻ = 그 재고 줄을 다시 만든 사람(정산서를 올렸거나 재집계를 돌린 사람)">등록자</th></tr></thead><tbody>'+of.outH+ds.h;
    out.forEach(function(r){ var q=Number(r.qty)||0; os+=q; var s=(''+(r.src||''));
      h+='<tr><td>'+dt8(r.dlvDt)+'</td><td class="l" title="'+esc(r.bizNm||r.mtNm)+((r.mtNm && r.bizNm && (''+r.mtNm)!==(''+r.bizNm))?(' · '+esc(r.mtNm)):'')+'">'+esc(r.bizNm||r.mtNm)+'</td><td>'+esc(r.dcNm)+'</td><td class="l">'+((r.itemCd && (''+r.itemCd)!==(''+sel.it.cd))?('<span class="xc">↳ '+esc(r.itemCd)+'</span> <span class="xn">'+esc(r.itemNm||'')+'</span>'):'')+'</td><td class="'+srcCls(s)+'">'+srcIco(s)+esc(s)+somOutAct(r, String(sel.it.cd).trim())+'</td><td class="r" style="white-space:nowrap">'+preOf(r)+(function(){ var k=(''+(r.dlvDt||'')).replace(/[^0-9]/g,'').slice(0,8); if(!RM || RM.day[k]==null || runDay[k]) return ''; runDay[k]=1; return somRunPill(RM, RM.day[k], true); })()+partOf(r)+num(q)+'</td><td style="white-space:nowrap">'+tmOf(r)+'</td><td style="white-space:nowrap">'+userOf(r)+'</td></tr>'; });
    h+='</tbody></table>'; }
  document.getElementById('dtlOut').innerHTML=h; document.getElementById('dtlOutSum').textContent=(out.length?(out.length+'건 · '+num(os)):'')+(ds.n?((out.length?' · ':'')+'삭제된 판매전표 '+ds.n+'건'):'')+(of.nOut?(((out.length||ds.n)?' · ':'')+'재고 미적용 '+of.nOut+'건'):'');
  /* 고정 칸 — 둘째 칸(사업장)이 설 자리 = 첫 칸(납기일자)의 실제 폭. 못 재면(숨은 화면·시뮬) CSS 기본값 94px */
  try{ var fxT=document.getElementById('dtlOut').querySelector('table.fx'), fxW=fxT && fxT.rows[0] && fxT.rows[0].cells[0].offsetWidth; if(fxW>0) fxT.style.setProperty('--c1w', fxW+'px'); }catch(e){}
  /* 입고내역 — 원장에서 출고(O) 뺀 행, 년월로 거른다 */
  var led=(j.ledger||[]).filter(function(r){ var d=''+(r.trxDt||''), y6=d.replace(/-/g,'').slice(0,6);
    if((''+(r.ioGb||''))==='O') return false; var d8=d.replace(/-/g,'').slice(0,8); return (d8>=fr && d8<=to) && (!sel.ym || y6===sel.ym); });
  var gb={I:'입고',R:'반품입고',A:'조정'}, is=0, h2='', pd=somPendRows(sel.it), dl=somDelRows(sel, fr, to, j.ledger);   /* pd = 승인 대기 줄 · dl = 삭제된 입고 줄(둘 다 맨 위 · 합계에는 안 든다) */
  if(!led.length && !pd.n && !dl.n && !of.nIn) h2='<div class="none">입고가 없습니다.</div>';
  else { h2='<table><thead><tr><th>일자</th><th>구분</th><th style="width:1%;min-width:96px;white-space:nowrap;padding-left:14px">수량</th><th>매입처/사업장</th><th>근거</th><th>비고</th></tr></thead><tbody>'+pd.h+of.inH+dl.h;
    /* 조정 줄은 수량 앞에 «전 → 후» (2026-11-22 「여기도 조정내역 보여줘」) — 조정 줄의 수량은 입력한 수량이 아니라 증감이다(30 을 31 로 맞추면 1).
       서버가 조정 이력의 전·후 재고(adjBef·adjAft)를 줄 때만 「30 → 31」 알약 + 부호 붙은 증감, 없으면(옛 서버·다른 구분) 종전 숫자 그대로 */
    /* 가장 최근 조정 줄에는 「최근 재고」 표 (2026-11-22 「조정에서 최근 것을 최근재고 표시」 — 품목별재고현황 stkLedQty 와 같은 규칙).
       최근 = 받아 온 원장(j.ledger · 최근 일자부터)에서 전·후 값이 있는 첫 조정 줄 — 고른 달로 걸러 그 줄이 안 보이면 표도 없다 */
    var lastA=null; (j.ledger||[]).some(function(x){ if(x && x.ioGb==='A' && x.adjBef!=null && x.adjAft!=null){ lastA=x; return true; } return false; });
    var adjQ=function(r, q){ if(r.ioGb!=='A' || r.adjBef==null || r.adjAft==null){ var rv=(RM && r.ledgerSeq!=null) ? RM.seq[String(r.ledgerSeq)] : null; return (rv!=null) ? ('<span style="white-space:nowrap">'+somRunPill(RM, rv, false)+num(q)+'</span>') : num(q); }
      var top=(r===lastA);
      return '<span style="white-space:nowrap;padding-left:10px">'+(top ? '<span class="led-last" style="display:inline-block;margin-right:3px;padding:0 5px;border-radius:9px;background:#137a6c;color:#fff;font-size:10.5px;font-weight:800;white-space:nowrap" title="최근에 수정한 현재고 '+num(r.adjAft)+' — 이 조정 뒤에 «등록된» 입고·출고를 더하고 빼면 지금 현재고입니다 (일자가 조정일보다 뒤여도 조정할 때 이미 올라와 있던 출고는 「전」 재고에 들어 있습니다)">최근재고</span>' : '')
           +'<span style="display:inline-block;margin-right:4px;padding:0 5px;border-radius:9px;'+(top ? 'background:#d9efe9;color:#0f6b5e;border:1px solid #137a6c' : 'background:#eef4fb;color:#2f5f9e')+';font-size:11.5px;font-weight:700;white-space:nowrap"'
           +' title="조정 전 재고 '+num(r.adjBef)+' → 수정재고(조정 후 재고) '+num(r.adjAft)+' (화면에 넣은 수량 = '+num(r.adjAft)+' · 오른쪽 숫자는 그 차이)">전 '+num(r.adjBef)+' → 수정재고 '+num(r.adjAft)+'</span>'+(r.adjFixYn==='Y' ? '<span class="led-fix" style="cursor:help;margin-right:3px" title="이 수정재고는 기준으로 고정됩니다.&#10;현재고 = 수정재고 + 조정한 날짜부터의 입고·출고.&#10;조정한 날짜보다 앞 날짜의 전표를 지우거나 고쳐도 현재고는 그대로입니다.">🔒</span>' : '')+'<span style="white-space:nowrap">(증감 '+(q>0?'+':'')+num(q)+')</span>'
           +(function(){   /* 조정 뒤에 그 앞 자료가 달라졌으면 「변동 ±d → n」 — 품목별재고현황과 같은 글자·같은 말풍선 (2026-11-25) */
               if(!RM || RM.base===RM.aft || r.adjFixYn==='Y' || r.ledgerSeq==null || String(r.ledgerSeq)!==RM.adjSeq) return '';
               var df=RM.base-RM.aft;
               return ' <span class="led-now" style="display:inline-block;cursor:help;margin-left:3px;padding:0 5px;border-radius:9px;background:#fdecea;color:#a6241c;border:1px solid #e7a9a3;font-size:11px;font-weight:800;white-space:nowrap"'
                    +' title="재고조정으로 '+num(r.adjAft)+' 에 맞췄는데, 지금은 '+num(RM.base)+' 입니다 (재고가 '+num(Math.abs(df))+(df<0 ? ' 줄었습니다' : ' 늘었습니다')+').&#10;'
                    +'조정한 뒤에 그 앞 날짜의 입고·출고가 바뀐 것입니다.&#10;'
                    +'실물과 다르면 재고 일괄조정으로 다시 맞추세요.">변동 '+(df>0?'+':'')+num(df)+' → '+num(RM.base)+'</span>'; })()
           +'</span>'; };
    led.forEach(function(r){ var q=Number(r.qty)||0; is+=q;
      var rt=(r.ioGb==='A' && r.regDttm) ? (''+r.regDttm) : '';   /* 조정을 저장한 때 — 일자(기준일자)와 날이 다르면 날짜까지 */
      var rtx=rt ? (' <span style="color:#7b8b97;font-size:12px;white-space:nowrap" title="이 조정을 저장한 때 '+esc(rt)+'">'+esc(rt.slice(0,10).replace(/-/g,'')===(''+r.trxDt).replace(/-/g,'') ? rt.slice(11,16) : rt.slice(5,16))+'</span>') : '';
      h2+='<tr><td style="white-space:nowrap">'+dt8(r.trxDt)+rtx+'</td><td>'+((r.ioGb==='I'&&q<0)?'<span style="color:#c0392b;font-weight:700" title="매입 반품 — 음수 수량 입고">반품</span>':esc(gb[r.ioGb]||r.ioGb))+'</td><td class="r">'+adjQ(r, q)+'</td><td class="l">'+esc(r.vendorNm||r.bizCd||'')+'</td><td>'+somRef(r)+'</td><td class="l">'+somKeepTag(r)+esc(r.remark||'')+somInAct(r, String(sel.it.cd).trim())+'</td></tr>'; });
    h2+='</tbody></table>'; }
  /* ★머리 합계 뒤에 «수정재고» (2026-11-22 사용자 「월별 출고현황에도 수정재고 표시해줘」 — 품목별재고현황 달 합계 줄(logi-oh.js stkLedMonHead adjOf)과 같은 글자).
       「1건 · 58」만 있으면 58 이 재고처럼 읽힌다 ⇒ 보이는 조정 줄(전·후 값 있는 것)의 증감 합 + 「(전 -53 → 수정재고 5)」, 여럿이면 「(n회 · 마지막 수정재고 b)」.
       led 는 최근 일자부터라 [0] 이 마지막 조정. 수정재고 = 그 조정을 저장한 순간의 재고. 전·후 값이 안 오면(옛 서버) 종전 글자 그대로 */
  var aj=led.filter(function(r){ return r.ioGb==='A' && r.adjBef!=null && r.adjAft!=null; }), ajs=0; aj.forEach(function(r){ ajs+=Number(r.qty)||0; });
  var ajT=aj.length ? (' · 조정 '+(ajs>0?'+':'')+num(ajs)+' ('+(aj.length>1 ? (aj.length+'회 · 마지막 수정재고 '+num(aj[0].adjAft)) : ('전 '+num(aj[0].adjBef)+' → 수정재고 '+num(aj[0].adjAft)))+')') : '';
  document.getElementById('dtlIn').innerHTML=h2; document.getElementById('dtlInSum').textContent=(led.length?(led.length+'건 · '+num(is)+ajT):'')+(pd.n?((led.length?' · ':'')+'승인 대기 '+pd.n+'건'):'')+(dl.n?(((led.length||pd.n)?' · ':'')+'삭제된 입고 '+dl.n+'건'):'');
}
/* ── 🔄 출고반영 재집계 — 품목별재고현황의 stkRebuild 와 같은 동작(같은 서버 API) (2026-09-03 요청) ──
   확인창(공통 _confirmBox) → /prod/stockRebuild.do POST, 그동안 /prod/stockRebuildProgress.do 를 0.5초마다 물어 실제 진행률을 그린다.
   끝나면 표를 다시 조회한다. 규칙: 정산서 있는 납기일자는 정산서, 없는 날은 발주현황표 · 마감 확정월 제외 */
function somRebuild(){
  fetch(CTX+'/prod/closedMonths.do', { method:'POST', credentials:'same-origin' })
    .then(function(r){ return r.json(); }).catch(function(){ return {months:[]}; })
    .then(function(j){
      var ms=(j&&j.months)||[], excl = ms.length ? ('<br>제외 : <b style="color:#c0392b">마감 확정월 '+ms.map(function(m){ m=''+m; return m.length===6?(m.slice(0,4)+'-'+m.slice(4)):m; }).join(', ')+'</b>') : '';
      var msg='<div style="font-weight:800;color:#137a6c;margin-bottom:6px">🔄 출고반영 재집계</div>전체 출고를 재고 원장에 반영하고 <b>현재고를 다시 계산</b>합니다.'+excl+'<br>진행할까요?';
      if(!window._confirmBox){ if(!confirm(msg.replace(/<[^>]*>/g,''))) return; return somRebuildRun(); }
      _confirmBox({ msg:msg, icon:'❓', okText:'확인', okColor:'blue', onOk:somRebuildRun });
    });
}
function somRebuildRun(){
  var rb=document.getElementById('rb'), bar=document.getElementById('rbBar'), lb=document.getElementById('rbLb');
  function ind(t){ bar.classList.add('ind'); bar.firstChild.style.width=''; lb.textContent=t; }
  function det(p,t){ bar.classList.remove('ind'); bar.firstChild.style.width=p+'%'; lb.textContent=t; }
  rb.classList.add('on'); ind('시작하는 중…');
  var t0=Date.now();
  function tick(){
    fetch(CTX+'/prod/stockRebuildProgress.do', { method:'POST', credentials:'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(p){ var el=Math.round((Date.now()-t0)/1000)+'초';
        if(!p || !p.running){ ind('진행 중… (경과 '+el+')'); return; }
        if(p.total>0) det(Math.min(95, p.done*95/p.total), p.phase+'  ('+p.done+' / '+p.total+' · 경과 '+el+')');   /* 마지막 현재고 집계가 남아 95% 에서 멈춘다 */
        else ind((p.phase||'준비 중…')+'  (경과 '+el+')'); })
      .catch(function(){ ind('진행 중… (경과 '+Math.round((Date.now()-t0)/1000)+'초)'); });
  }
  tick(); var poll=setInterval(tick, 500);
  fetch(CTX+'/prod/stockRebuild.do', { method:'POST', credentials:'same-origin' })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
    .then(function(r){ clearInterval(poll);
      if(!r.ok){ rb.classList.remove('on'); toast('재집계 실패: '+esc((r.t||'').trim()), '⚠️'); return; }
      det(100, '완료'); setTimeout(function(){ rb.classList.remove('on'); toast('출고반영 재집계 완료 · 납기일자 <b>'+esc(r.t||'0')+'</b>건 반영', '✅'); somLoad(); }, 400); })
    .catch(function(e){ clearInterval(poll); rb.classList.remove('on'); toast('통신오류: '+esc(e.message), '⚠️'); });
}
/* ★★다른 메뉴로 가면 표를 <비운다> — 돌아오면 다시 그린다 (2026-09-04 「월별 출고현황 이후 다른 메뉴 이동 시 엄청 느림·잔상」)
     셸(logistics_demo2)은 메뉴를 바꿔도 이 iframe 을 display:none 으로 <살려 둔다>(상태 유지 설계). 그래서 3만 셀짜리 표가
     숨은 채로 문서에 남아 셸의 스타일 계산·GC 를 매번 끌었고, 메뉴를 누르면 옛 화면이 잔상으로 남았다.
     · 판정 = 부모의 <iframe> 요소 크기(window.frameElement.getBoundingClientRect) 가 0 — 아래 hidden() 참고.
       ⚠IntersectionObserver·requestAnimationFrame 은 못 쓴다 — display:none 문서는 「그려지지 않는 문서」라 그 콜백이 아예 안 온다
         (처음 IO 로 만들었다가 안 깨어나 1초 타이머로 바꿈). setTimeout 은 숨어도 돈다.
     · 숨은 지 2초(0.5초 간격 네 번 연속 0)가 되면 표 DOM 만 지운다(RAW·조건·스크롤 위치는 남긴다). 그 안에 돌아오면 아무 일도 없다.
     · 다시 보이면 RAW 로 그대로 다시 그린다(서버 조회 없음, fixed 레이아웃이라 예전보다 빠르다). 스크롤 자리도 되돌린다. */
var _somSleptScroll=null, _somHidN=0;
(function(){
  var card=document.getElementById('card');
  function sleep(){
    if(!RAW || !card.querySelector('table.mx')) return;
    _somSleptScroll={ l:card.scrollLeft, t:card.scrollTop };
    card.innerHTML='<div class="empty">다른 화면을 보는 동안 표를 접어 두었습니다 — 돌아오면 다시 그립니다.</div>'; }
  function wake(){
    if(!_somSleptScroll || !RAW) return;
    var sc=_somSleptScroll; _somSleptScroll=null;
    somRender();
    card.scrollLeft=sc.l; card.scrollTop=sc.t; }
  /* ⚠innerWidth 는 못 쓴다 — display:none 이 되어도 Chrome 은 마지막 폭(1177 등)을 그대로 돌려준다(2026-09-04 하네스 실측).
       같은 출처라 부모의 <iframe> 요소를 직접 본다 : 숨은 상자는 폭·높이 0. */
  function hidden(){ try{ var fe=window.frameElement; if(!fe) return false; var r=fe.getBoundingClientRect(); return !(r.width>0 && r.height>0); }catch(e){ return false; } }
  setInterval(function(){
    var hid = hidden();
    if(hid){ _somHidN++; if(_somHidN===4) sleep(); }      /* 0.5초 × 4 = 숨은 지 2초 */
    else { _somHidN=0; if(_somSleptScroll) wake(); }        /* 돌아오면 0.5초 안에 다시 그린다 */
  }, 500);
})();
/* ★막대로 고른 높이(ui-gridgrip, localStorage konetGridH.stockOutMonth)가 있으면 그 높이가 이긴다 — 자동 맞춤(아래)은 건너뛴다.
     막대 더블클릭(= 처음 높이)이 저장값을 지우고 inline 높이를 되살리므로 그때 다시 자동으로 맞춘다(아래 dblclick 리스너). 2026-10-26 「표시부분도 막대로 줄였다 늘렸다」 */
function somGripH(){ try{ var v=parseFloat(localStorage.getItem('konetGridH.stockOutMonth')); return v>0?v:0; }catch(e){ return 0; } }
function somFit(){ var c=document.getElementById('card'); if(!c) return;
  if(somGripH()>0) return;   // 사람이 막대로 정한 높이 — 하단 내역이 열려도 안 줄인다
  /* 하단 내역 패널이 열려 있으면 표는 화면 절반만 쓴다 */
  var d=document.getElementById('dtl'), open=!!(d && d.style.display==='block');
  var top=c.getBoundingClientRect().top+(window.pageYOffset||0);
  c.style.maxHeight=Math.max(220, Math.round((window.innerHeight-top-16)*(open?0.5:1)))+'px'; }
window.addEventListener('resize', somFit);
/* ── 출고내역 | 입고내역 좌우 조절 (2026-11-24 「좌우 조정가능하게」) — 왼쪽 칸 폭을 %로(20~85) · localStorage konetSomDtlSplit · 두 번 누르면 반반 ── */
(function(){
  var sp=document.getElementById('dtlSplit'); if(!sp) return;
  var cols=sp.parentNode, lft=sp.previousElementSibling, rgt=sp.nextElementSibling; if(!lft || !rgt) return;
  lft.classList.add('lft');
  function apply(p){ p=Math.max(20, Math.min(85, +p||50)); lft.style.flex='0 0 calc('+p+'% - 4px)'; rgt.style.flex='1 1 0'; return p; }
  window.somDtlSplit=apply;
  var saved=50; try{ var v=parseFloat(localStorage.getItem('konetSomDtlSplit')); if(v>0) saved=v; }catch(e){}
  apply(saved);
  var drag=false, cur=saved;
  function move(x){ var r=cols.getBoundingClientRect(); if(!(r.width>0)) return; cur=apply((x-r.left)/r.width*100); }
  function end(){ if(!drag) return; drag=false; sp.classList.remove('on'); cols.classList.remove('dragging'); try{ localStorage.setItem('konetSomDtlSplit', String(Math.round(cur*10)/10)); }catch(e){} }
  sp.addEventListener('mousedown', function(e){ drag=true; sp.classList.add('on'); cols.classList.add('dragging'); e.preventDefault(); });
  document.addEventListener('mousemove', function(e){ if(drag) move(e.clientX); });
  document.addEventListener('mouseup', end);
  window.addEventListener('blur', end);
  sp.addEventListener('touchstart', function(e){ drag=true; sp.classList.add('on'); e.preventDefault(); }, { passive:false });
  document.addEventListener('touchmove', function(e){ if(drag && e.touches[0]) move(e.touches[0].clientX); }, { passive:true });
  document.addEventListener('touchend', end);
  sp.addEventListener('dblclick', function(){ cur=apply(50); try{ localStorage.removeItem('konetSomDtlSplit'); }catch(e){} });
})();
konetGridGrip('card', 'card', 'stockOutMonth');   // 표 상자 바로 밑에 막대(합계줄이 표 안이라 발주서와 같은 꼴) · 보관 konetGridH.stockOutMonth
document.addEventListener('dblclick', function(e){ if(e.target && e.target.closest && e.target.closest('.kgg')) setTimeout(somFit, 0); });   // 처음 높이로 = 자동 맞춤 복귀
/* 엑셀 — 화면 표 그대로(머리 2줄: 사업장 병합 + 품목, 현재고 줄 포함). 부모의 xlsx 라이브러리를 빌려 쓴다(택배납기관리와 같은 방식) */
function somExcel(){
  if(!RAW){ toast('먼저 조회하세요.'); return; }
  var m=_somM||somBuild(); if(!m.cols.length){ toast('출력할 자료가 없습니다.'); return; }
  var aoa=[], h1=['년월 / 사업장 ▸ 품목','합계'], h2=['',''];
  var merges=[{s:{r:0,c:0},e:{r:1,c:0}},{s:{r:0,c:1},e:{r:1,c:1}}], ci=2;
  m.gord.forEach(function(gk){ var g=m.grp[gk], n=g.iord.length;
    h1.push(g.nm); for(var i=1;i<n;i++) h1.push('');
    if(n>1) merges.push({s:{r:0,c:ci},e:{r:0,c:ci+n-1}});
    g.iord.forEach(function(cd){ h2.push(cd+' '+shortNm(g.items[cd].nm, g.nm)); }); ci+=n; });
  aoa.push(h1); aoa.push(h2);
  var sr=['현재고',''], st=0, any=false, seen={};
  m.cols.forEach(function(c){ var v=m.stock[c.cd]; if(v==null){ sr.push(''); return; } any=true; if(!seen[c.cd]){ seen[c.cd]=1; st+=v; } sr.push(v); });
  sr[1]=any?st:''; aoa.push(sr);
  m.yord.forEach(function(ym){ var r=[ymLabel(ym), m.yms[ym]]; m.cols.forEach(function(c){ var v=m.cell[ym+'|'+c.g+'|'+c.cd]; r.push(v>0?v:''); }); aoa.push(r); });
  var tr=['기간 합계',0], g0=0; m.cols.forEach(function(c){ var t=m.grp[c.g].items[c.cd].tot; tr.push(t); if(c.g!=='#ALL') g0+=t; });   /* 품목 합계 열은 두 번 더하지 않는다 */ tr[1]=g0; aoa.push(tr);
  var P=window.parent, fn='월별출고현황_'+document.getElementById('frDt').value.replace(/-/g,'')+'-'+document.getElementById('toDt').value.replace(/-/g,'')+'.xlsx';
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); ws['!cols']=[{wch:16},{wch:10}].concat(m.cols.map(function(){ return {wch:16}; }));
    ws['!merges']=merges;
    ws['!freeze']={xSplit:2, ySplit:2, topLeftCell:'C3', activePane:'bottomRight', state:'frozen'};
    var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'월별 출고현황'); LIB.writeFile(wb,fn); toast('<b>'+esc(fn)+'</b><br>엑셀 파일을 내려받았습니다.', '📥'); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB) byLib(LIB); else toast('엑셀 모듈을 못 불러왔습니다.'); }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  toast('엑셀 모듈은 물류관리 메인 안에서만 씁니다.');
}
somLoad();
/* 셸 메뉴로 다시 들어올 때 — 품목코드(매핑)에서 바꾼 매칭코드를 다음 검색에 쓰게 표만 비운다(목록은 [조회]로) */
window.konetShown=function(){ _somAlias=null; };
</script>
</body>
</html>
