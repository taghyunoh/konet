<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- 알림·확인은 프로젝트 공통 표준(ui-message.js) — Swal 신규 사용 금지 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<title>재고 일괄조정</title>
<%-- 재고 일괄조정 (2026-08-19 신설)
     기존화면(거래처 시스템)의 [리스트조회] + [수정저장] 을 우리 구조로 옮긴 것.

     ★재고의 주인은 수불원장(TBL_STOCK_LEDGER) 하나다.
       수정값으로 덮어쓰지 않고 **차이만큼 조정행(IO_GB='A')** 을 더한다.
       덮어쓰면 과거 이력이 사라지고, 같은 날 두 번 저장하면 값이 겹쳐 어긋난다.
     ★매입등록(단가 0)으로 맞추지 않는다 — 이동평균 분모에 들어가 재고금액이 낮아진다.
       조정행은 단가를 안 넣어 그 문제가 없다.
     ★BOX/EA 는 화면 표기일 뿐이다. 원장에는 EA 로 환산해 담는다(EA = BOX × 입수수량 + EA).
     ★창고는 아직 나누지 않는다 — 원장에 창고 칸이 없다. 드롭다운은 자리만 잡아 둔다. --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; overflow:hidden; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  /* ★[2026-08-19 요청 「상단을 조금 줄이고 조정이력을 위로 확대」] 위쪽 여백·조회줄 패딩을 한 단계씩 줄였다 */
  .wrap{ padding:4px 11px 8px; height:100%; display:flex; flex-direction:column; min-height:0; }

  .bar{ display:flex; flex-wrap:wrap; align-items:center; gap:4px 8px; padding:5px 10px;
        background:#fff; border:1px solid var(--bd); border-radius:8px; margin-bottom:6px; }
  .bar label{ font-size:13px; color:#48606f; font-weight:600; }
  .bar select, .bar input[type=text], .bar input[type=date]{
        height:30px; border:1px solid #cbd5e1; border-radius:5px; padding:0 8px; font-size:13px;
        font-family:inherit; }
  .bar .sp{ flex:1; }

  .btn{ height:30px; border:1px solid var(--teal); background:var(--teal); color:#fff;
        border-radius:5px; padding:0 14px; font-size:13px; font-weight:700; cursor:pointer; }
  .btn.ghost{ background:#fff; color:var(--teal); }
  .btn.warn{ background:#fff; color:#b23b3b; border-color:#b23b3b; }
  .btn[disabled]{ background:#b9c8d2; border-color:#b9c8d2; color:#fff; cursor:not-allowed; }

  /* 목록이 남는 공간을 전부 쓰고, 넘치면 이 안에서만 스크롤된다(머리글은 sticky).
     ★flex-basis 를 0 으로 두어야 아래 [사유줄]·[이력]이 커져도 목록이 밀리지 않는다. */
  .grid{ flex:1 1 0; min-height:0; overflow:auto; background:#fff; border:1px solid var(--bd); border-radius:8px; }
  .foot, .hist{ flex:0 0 auto; }
  /* ★목록 ↔ 조정 이력 높이 막대 (2026-11-18 사용자 「막대 표시로 줄이고 늘리고 기능」) — 목록 표 바로 밑.
     목록은 «남는 높이 전부»(flex:1)라 막대는 아래 [조정 이력] 표의 높이를 거꾸로 바꾼다 : 아래로 끌면 이력이 줄고 목록이 그만큼 는다.
     모양은 판매·매입 등록의 공용 막대(ui-gridgrip.js .kgg)와 같다. 그 파일을 안 쓴 까닭 = 그쪽은 «잡은 표의 높이»를 늘리는 한 방향뿐이다. */
  .agrip{ flex:0 0 auto; position:relative; height:16px; margin-top:3px; display:flex; align-items:center; justify-content:center;
          cursor:ns-resize; user-select:none; border-radius:6px; background:#f3f6f8; }
  .agrip:hover, .agrip.on{ background:#dff0eb; }
  .agrip i{ display:block; width:64px; height:4px; border-radius:2px; background:#b9c6d2; pointer-events:none; }
  .agrip:hover i, .agrip.on i{ background:#137a6c; }
  .agrip .bt{ position:absolute; right:4px; top:0; display:flex; gap:4px; }
  .agrip .bt b{ height:16px; line-height:14px; padding:0 7px; font-size:11px; font-weight:700; color:#37475a; background:#fff;
                border:1px solid #cfd8e3; border-radius:4px; cursor:pointer; white-space:nowrap; }
  .agrip .bt b:hover{ border-color:#137a6c; color:#137a6c; }
  table{ width:100%; min-width:1240px; border-collapse:collapse; font-size:13px; }
  thead th{ position:sticky; top:0; z-index:2; background:#eef2f5; border-bottom:1px solid #c8d4dd;
            padding:7px 8px; font-weight:700; color:#3a4a53; white-space:nowrap; }
  tbody td{ border-bottom:1px solid #eef1f4; padding:5px 8px; white-space:nowrap; }
  tbody tr:hover{ background:#f7fbfa; }
  td.r, th.r{ text-align:right; }
  td.c, th.c{ text-align:center; }
  .dim{ color:#9aa8b2; }
  .neg{ color:#b23b3b; font-weight:700; }          /* 음수 재고 = 입고 누락 신호 */

  input.ed{ width:78px; height:26px; border:1px solid #cbd5e1; border-radius:4px;
            padding:0 6px; font-size:13px; text-align:right; font-family:inherit; }
  input.ed:focus{ outline:none; border-color:var(--teal); }
  tr.chg{ background:#fff8e8; }                     /* 고친 줄 */
  tr.chg:hover{ background:#fff3d8; }
  /* ★[2026-08-19 요청] 상품코드등록과 같은 표시 — 거래중지 상품은 줄 전체 빨간색.
     ⚠chg(고친 줄)보다 뒤에 둔다 — 중지 표시가 누런 배경에 묻히면 안 된다. */
  tr.stopped, tr.stopped:hover, tr.stopped.chg{ background:#fff4f3; }
  /* ★!important — 음수(.neg) 등 칸에 박은 색을 이기고 줄 전체가 빨강이 되게(2026-08-19 재지적 「중지된 코드는 빨간색」) */
  tr.stopped td{ color:#c0392b !important; }
  /* 서브 배지·주코드 링크·마스터 상품명 — 상품코드등록(prodcd.jsp)과 같은 모양 */
  .subbdg{ display:inline-block; padding:0 5px; border-radius:8px; background:#fdecea; color:#c0392b;
           font-size:12px; font-weight:700; }
  /* 주코드 배지 — 상품코드등록과 같은 청록(2026-09-23) */
  .mainbdg{ display:inline-block; padding:0 5px; border-radius:8px; background:#e3f2ee; color:#0f6b5e;
            font-size:12px; font-weight:700; }
  /* ★[2026-08-19 확정 「여기서는 주코드 보여주는 것」] 주코드는 **표시 전용** —
     처음엔 링크(검색 이동 → 스크롤 이동)를 달았다가 액션 자체를 걷어냈다.
     이 화면은 재고를 고치는 곳이지 코드를 다루는 곳이 아니다 — 코드 정리는 상품코드등록에서.
     다시 달자는 얘기가 나오면 이 이력부터 확인할 것. */
  .subgo{ font-size:12.5px; color:#1f7a4d; font-weight:700; }
  .subgo.stop{ color:#c0392b; }              /* 주코드가 중지면 빨강 */
  .mstnm{ font-size:11.5px; color:#8a97a3; margin-bottom:2px; white-space:normal; }   /* 2026-10-01 — 마스터 이름이 위로 올라가 여백도 아래쪽으로 */
  .stopbdg{ display:inline-block; padding:0 5px; border-radius:8px; background:#eceff1; color:#546e7a;
            font-size:11px; font-weight:700; }
  .diff{ font-weight:800; }
  .diff.up{ color:#1f7a4b; }
  .diff.dn{ color:#b23b3b; }
  b.aft{ font-weight:800; color:#125a4e; } b.aft.neg{ color:#b23b3b; }   /* 조정 후 재고 (2026-11-19) */

  .foot{ display:flex; align-items:center; gap:12px; padding:5px 10px; margin-top:6px;
         background:#fff; border:1px solid var(--bd); border-radius:8px; font-size:13px; }
  .foot b{ color:var(--teal); }
  /* ── 하단 조정 이력 ─────────────────────────────────────────── */
  .hist{ margin-top:6px; background:#fff; border:1px solid var(--bd); border-radius:8px;
         display:flex; flex-direction:column; min-height:0; }
  .hist.off .hgrid{ display:none; }
  /* ── 승인 요청 (2026-11-18) — 조정 이력과 같은 상자 모양. 대기가 없으면 표를 접어 자리를 안 먹는다 ── */
  #reqBox .hgrid{ min-height:0; max-height:26vh; }
  /* [바꿈 2026-11-19 사용자 「이 상태에서 (높이 막대) 작동 안 함」] 종전 = 요청이 없으면 표를 숨겼다(display:none) → 탭으로 묶은 뒤로는 승인 요청 탭이 기본인데
     숨은 표라 높이 막대가 늘리고 줄일 대상이 없어 눌러도 아무 일이 없었다. ⇒ 비어 있어도 표를 보이고(머리줄 + 「승인 대기 중인 요청이 없습니다」 한 줄) 막대로 늘릴 수 있게 한다. */
  #reqBox.none .hgrid{ min-height:0; }
  #reqBody td.rq-empty{ text-align:center; color:#8a98a8; padding:14px 8px; }
  /* 내 요청 결과 띠 (2026-11-18 「요청한 직원에게도 승인/반려 결과 알림 표시」) — 승인·반려됐는데 아직 [확인했습니다] 안 한 내 요청 */
  #reqMine{ margin:0 8px 8px; border:1px solid #cfe3dc; background:#f3faf7; border-radius:8px; padding:7px 10px; font-size:13px; }
  #reqMine.rej{ border-color:#f0c9c9; background:#fff6f5; }
  #reqMine .rm-hd{ display:flex; align-items:center; gap:10px; margin-bottom:3px; }
  #reqMine .rm-hd b{ color:#0f6b5e; } #reqMine.rej .rm-hd b{ color:#a12b2b; }
  /* ★결과는 «표(그리드)» 로 — 상품 한 줄에 한 칸씩, 요청마다 번호·결과·처리 칸을 세로로 묶는다(rowspan). 내용이 많으면 이 상자 안에서 스크롤
     (2026-11-18 사용자 「어떤 상품이 반려 승인 됐는지 표시」 → 「내용이 많을 때는 복잡한 — 그리드 형태로 · 스크롤되게」. 처음 판은 글자를 한 줄로 늘어놓았다). */
  #reqMine .rm-grid{ max-height:min(26vh, 200px); overflow:auto; border:1px solid #d5e3dd; border-radius:6px; background:#fff; }
  #reqMine.rej .rm-grid{ border-color:#ecd2d2; }
  #reqMine .rm-grid table{ min-width:0; width:100%; font-size:12.5px; }
  #reqMine .rm-grid thead th{ background:#e6f2ee; padding:5px 8px; }
  #reqMine.rej .rm-grid thead th{ background:#f8e9e7; }
  #reqMine .rm-grid tbody td{ padding:4px 8px; border-right:1px solid #eef1f4; vertical-align:middle; }
  #reqMine .rm-grid tbody td.wr{ white-space:normal; min-width:120px; }
  #reqMine .rm-grid tr.rm-first td{ border-top:2px solid #cfdcd6; }
  #reqMine .rm-grid tbody tr:first-child td{ border-top:0; }
  #reqMine .rm-grid .st{ font-weight:800; white-space:nowrap; }
  #reqMine .rm-grid tr.A .st, #reqMine .rm-grid td.A .st{ color:#137a6c; }
  #reqMine .rm-grid td.R .st, #reqMine .rm-grid td.C .st{ color:#b23b3b; }
  #reqMine .rm-grid .why{ color:#b23b3b; font-weight:700; }
  #reqMine .rm-grid td.nm{ font-weight:700; text-align:left; white-space:normal; min-width:160px; }
  #reqBox .htab .tb.pend{ background:#b06a00; border-color:#b06a00; color:#fff; }
  #histBox .htab .tb.pend{ border-color:#b06a00; color:#8a5200; background:#fff6e5; }   /* 조정 이력을 보는 중에도 «승인 대기 있음»이 보이게 (2026-11-19 탭) */
  .rq-st{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11.5px; font-weight:800; white-space:nowrap; }
  .rq-st.P{ background:#fff3d6; color:#8a5a00; } .rq-st.A{ background:#e3f4ef; color:#0e6657; }
  .rq-st.R{ background:#fde8e8; color:#b23b3b; } .rq-st.C{ background:#eef1f4; color:#6b7a89; }
  /* ★승인 요청 표도 «상품이 보이는 그리드» (2026-11-18 사용자 「승인 입장도 이런 형태로 보여줘요」 — 요청한 직원의 「내 요청 결과」 표와 같은 꼴).
     요청마다 상품 한 줄씩(rq-h = 그 요청의 첫 줄 · rq-i = 나머지 상품 줄), 요청 칸(번호·상태·사유·요청·처리·작업)은 상품 수만큼 세로로 묶는다(rowspan).
     종전 = 요청 한 줄 + 줄을 눌러야 품목이 펼쳐졌다(rq-d) — 승인하는 사람이 무엇을 승인하는지 한 번 더 눌러야 보였다. */
  tr.rq-h > td{ border-top:2px solid #d3dee6; }
  #reqBody tr:first-child > td{ border-top:0; }
  tr.rq-h.P td, tr.rq-i.P td{ background:#fffdf5; }
  #reqBody td{ border-right:1px solid #eef1f4; vertical-align:middle; }
  #reqBody td.nm{ font-weight:700; text-align:left; white-space:normal; min-width:170px; }
  #reqBody td.wr{ white-space:normal; min-width:110px; }
  #reqBody .rq-sum{ display:block; margin-top:2px; font-size:11.5px; color:#6b7a89; white-space:nowrap; }
  /* [승인][반려] 칸은 오른쪽에 붙여 둔다 — 창이 좁아 표를 가로로 밀어야 할 때도 단추가 늘 보인다 */
  #reqWrap th.rq-act, #reqBody td.rq-act{ position:sticky; right:0; box-shadow:-2px 0 4px rgba(30,50,70,.08); }
  #reqWrap th.rq-act{ z-index:3; }
  #reqBody td.rq-act{ background:#fff; border-right:0; }
  #reqBody tr.P td.rq-act{ background:#fffdf5; }
  .rq-ok, .rq-no, .rq-cx{ height:23px; border-radius:4px; padding:0 9px; font-size:11.5px; font-weight:800; cursor:pointer; margin:0 2px; white-space:nowrap; }
  .rq-ok{ border:1px solid var(--teal); background:var(--teal); color:#fff; }
  .rq-no{ border:1px solid #b23b3b; background:#fff; color:#b23b3b; }
  .rq-cx{ border:1px solid #9aa8b2; background:#fff; color:#5b6b7a; }
  .htab{ display:flex; align-items:center; gap:6px 10px; padding:6px 10px; border-bottom:1px solid var(--bd); }
  .htab .tb{ height:26px; border:1px solid var(--teal); background:#fff; color:var(--teal);
             border-radius:5px; padding:0 12px; font-size:13px; font-weight:700; cursor:pointer; }
  .htab .tb.on{ background:var(--teal); color:#fff; }
  .htab label{ font-size:13px; color:#48606f; font-weight:600; }
  .htab input{ height:26px; border:1px solid #cbd5e1; border-radius:4px; padding:0 7px;
               font-size:13px; font-family:inherit; }
  /* ★이력이 높아진 만큼 위 목록(.grid, flex:1)이 자연히 줍어든다 — 28vh → 40vh (2026-08-19 요청)
     ★min-height 추가 (2026-08-20 요청 「하단을 조금 위로 확대」) — 내용이 없어도(이력조회 전)
       이만큼 자리를 잡아 하단이 납작하게 붙지 않고, 위 목록이 그만큼 올라간다. */
  .hgrid{ min-height:24vh; max-height:46vh; overflow:auto; }
  .hgrid table{ font-size:12.5px; }
  .hgrid thead th{ background:#f4f7f8; }
  .undo{ height:22px; border:1px solid #b23b3b; background:#fff; color:#b23b3b;
         border-radius:4px; padding:0 8px; font-size:11.5px; font-weight:700; cursor:pointer; }
  /* ★[2026-08-19 요청 「모래시계」] 조회 중 오버레이 — 진짜 작업 중이라 클릭을 막는다
     (조회가 도는 사이 [수정저장]·재조회가 겹치면 안 된다 — shpProgOv 와 같은 원칙). */
  .busy{ position:fixed; inset:0; background:rgba(255,255,255,.45); display:none; z-index:999;
         align-items:center; justify-content:center; cursor:progress; }
  .busy.on{ display:flex; }
  .busy .bx{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:13px 24px;
             font-size:14.5px; font-weight:700; color:var(--teal); box-shadow:0 8px 26px rgba(0,0,0,.18); }
  .busy .hg{ display:inline-block; animation:hgFlip 1.2s linear infinite; margin-right:6px; }
  @keyframes hgFlip{ 0%,80%{ transform:rotate(0) } 90%,100%{ transform:rotate(180deg) } }
  /* ★「거래처 매출장·마감」 그리드 모양으로 (2026-10-21 사용자 「메뉴 3개 내용도 수정해줘」 — 품목별재고현황과 같게)
       머리줄 하늘(#d9edf7)+회청 테두리(#9fb6c3) · 칸 테두리 #c9d3dc. 고친 줄(노랑)·음수 재고(빨강)·입력칸은 그대로 */
  table{ font-size:12.5px; }
  thead th{ background:#d9edf7 !important; color:#1f2a37 !important; border:1px solid #9fb6c3 !important; padding:6px 6px; box-shadow:inset 0 -1px 0 #9fb6c3, inset 0 1px 0 #9fb6c3 !important; }   /* !important : 공용 ui-concept.css(.card thead th) 가 덮어서 */
  tbody td{ border:1px solid #c9d3dc; padding:4px 6px; }
  .hgrid thead th{ background:#d9edf7 !important; }
</style>
<%-- ★[2026-08-20] 화면 콘셉 공통 — 표 형식 입력 · 세로선 격자 · Pretendard.
     반드시 이 화면의 <style>·다른 CSS **뒤에** 걸어야 옛 규칙을 덮는다.
     이 두 줄만 빼면 이 화면만 예전 모습으로 돌아간다. 규칙 설명은 CSS 파일 머리말. --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/ui-concept.css?v=20260820">
<%-- ★공통 UI 보정 (2026-08-21) — 단추 글자 두 줄 접힘 방지 + [글자 축소/확대] 단추 모양 --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
</head>
<body>
<div class="wrap">

  <div class="bar">
    <label>창고</label>
    <select id="whCd" title="원장에 창고 구분이 없어 지금은 하나입니다">
      <option value="">물류창고</option>
    </select>

    <label>정렬</label>
    <select id="sortGb">
      <option value="CD">코드</option>
      <option value="NM">상품명</option>
      <option value="QTY">재고</option>
    </select>

    <label><input type="checkbox" id="zeroExc"> 재고 0 제외</label>

    <%-- ★[2026-09-23 요청] 상품 검색칸 ↔ 창고 자리 맞바꿈 — 검색은 앞(기준일자 앞), 창고는 뒤(유형 앞) --%>
    <label>상품</label>
    <%-- ★「치면 바로 조회」 폐지 (2026-08-20 요청) — 목록을 아직 안 읽은 상태에서 글자를 치면
         현재고 집계(원장 합계) 조회가 바로 돌아 느렸다. 이제 **Enter 나 [리스트조회]를 눌러야** 검색된다. --%>
    <input type="text" id="findData" placeholder="코드 · 상품명 · 규격 — 입력 후 Enter" style="width:210px"
           onkeydown="if(event.keyCode===13){ load(); }">
    <label>기준일자</label>
    <input type="date" id="baseDt" title="오늘(또는 그 뒤) = 지금 현재고 전체(품목별재고현황과 같은 숫자 — 내일 납기로 이미 나간 출고까지 뺀 값)&#10;지난 날짜 = 그날까지의 누계 재고. 조정행도 이 날짜로 남습니다.">

    <%-- ★한 번 읽었으면 화면에서 거른다 — 누를 때마다 현재고 집계(느린 조회)가 돌지 않게(2026-08-20).
         서버를 다시 읽는 길 = 기준일자 변경 · 저장 직후 자동 재조회. --%>
    <button type="button" class="btn ghost" onclick="load();"
            title="이미 읽어 둔 목록에서 검색·필터를 겁니다. 서버에서 다시 읽으려면 기준일자를 바꾸세요.">리스트조회</button>
    <button type="button" class="btn" id="btnSave" onclick="save();">수정저장</button>
    <button type="button" class="btn ghost" onclick="packAuto();"
            title="상품명 끝의 1000EA/BOX · 300EA · 2000매 같은 숫자를 읽어 입수수량에 채웁니다">입수수량 자동채우기</button>
    <%-- 📥 엑셀 (2026-09-23 요청) — 지금 조건(검색·유형·제조사·재고0제외·정렬)으로 걸러진 **전체**(화면 200줄 상한 밖까지). 고치던 수정칸 값도 함께 --%>
    <button type="button" class="btn ghost" onclick="adjExcel();"
            title="지금 조건으로 걸러진 목록 전체를 엑셀로 (화면에 안 보이는 줄까지). 수정BOX/EA·증감은 화면에 보이는 줄만 값이 들어갑니다">📥 엑셀출력</button>

    <span class="sp"></span>

    <%-- 창고 (2026-09-16 P3) — 조정은 창고마다. 목록의 현재고도 그 창고 것. 비면 전 창고 합계라 저장을 막는다 --%>
    <label>창고</label>
    <select id="adjWh" title="조정할 창고 — 목록의 현재고가 그 창고 재고로 바뀝니다" onchange="load()"></select>
    <label>유형</label>
    <select id="typeNm"><option value="">전체</option></select>
    <label>제조사</label>
    <select id="makerNm"><option value="">전체</option></select>
  </div>

  <%-- ★[2026-08-20] 화면 콘셉 통일 — 목록 표를 다른 화면과 같은 격자로.
       공통 CSS(ui-concept)는 「card」 안의 표에만 걸리므로 **class 에 card 를 더한다**(HTML 한 낱말).
       이 화면은 부트스트랩을 안 쓰므로 card 라는 이름이 다른 모양을 끌고 오지 않는다. --%>
  <div class="grid card" id="adjGrid">
    <table>
      <thead>
        <tr>
          <th style="width:110px">상품코드</th>
          <th>상품명</th>
          <th style="width:170px">규격</th>
          <th class="r" style="width:80px">입수수량</th>
          <th style="width:130px">유형</th>
          <%-- ★[2026-08-19 요청] 상품코드등록처럼 중지일도 보여 준다 --%>
          <th class="c" style="width:95px" title="거래중지 시작일 — 이 날짜부터 매입·판매에서 막힙니다">중지일</th>
          <th class="r" style="width:90px">BOX재고</th>
          <th class="r" style="width:80px">EA재고</th>
          <th class="r" style="width:95px">합계재고</th>
          <th class="c" style="width:95px">수정BOX재고</th>
          <th class="c" style="width:95px">수정EA재고</th>
          <th class="r" style="width:90px">증감</th>
          <%-- 조정 후 재고 (2026-11-19 사용자 「수정수량 하면 증감이 나오는데 실제 현재고가 얼마다 표시했으면」) — 수정BOX × 입수 + 수정EA. 고친 줄에만 숫자가 나온다 --%>
          <th class="r" style="width:100px" title="저장(승인)하면 되는 재고 = 수정BOX재고 × 입수수량 + 수정EA재고. 수량을 고친 줄에만 나옵니다">조정 후 재고</th>
        </tr>
      </thead>
      <tbody id="body">
        <tr><td colspan="13" class="c dim" style="padding:26px">[리스트조회] 를 눌러 주세요.</td></tr>
      </tbody>
    </table>
  </div>

  <div class="foot">
    <span id="cnt" class="dim">—</span>
    <span>고친 줄 <b id="chgCnt">0</b></span>
    <span class="sp" style="flex:1"></span>
    <label>사유</label>
    <input type="text" id="remark" placeholder="재고 일괄조정 (이력에 남습니다)" style="width:280px; height:26px;
           border:1px solid #cbd5e1; border-radius:4px; padding:0 7px; font-size:13px; font-family:inherit;">
  </div>


  <%-- ── 하단 : 조정 이력 ─────────────────────────────────────────────
       원장에는 차이만 남는다. 여기서는 '전 → 후' 와 저장 묶음을 보여준다.
       묶음(BATCH_NO) 단위로 되돌릴 수 있다 — 원장 조정행도 함께 내려간다. --%>
  <%-- ── 승인 요청 (2026-11-18 「총괄관리자 및 부관리자가 승인해야 저장되게」) ──
       직원의 [승인 요청]은 재고를 바꾸지 않고 여기 쌓인다. 총괄관리자·부관리자가 [✔ 승인]하면 그때 재고(조정행 · 조정 이력)에 반영된다.
       관리자가 직접 누른 [수정저장]은 종전대로 바로 반영된다. 서버가 요청 목록을 못 주면(옛 서버 · 표 없음) 이 상자는 안 보인다. --%>
  <div class="hist none" id="reqBox" style="display:none">
    <div class="htab">
      <%-- ★탭 두 개 (2026-11-19 사용자 「탭 두 개로 승인요청 · 조정이력으로 구성 — 기본은 승인요청 탭」) — 종전엔 두 상자가 위아래로 쌓여 목록 자리를 둘이 나눠 먹었다.
           한 번에 한 상자만 보인다(tabGo). 켜진 탭을 다시 누르면 종전처럼 접기/펼치기. 두 상자 머리줄에 같은 탭 두 개를 둔다 — 어느 쪽이 보여도 탭 자리가 같다. --%>
      <button type="button" class="tb on" id="reqTab" onclick="tabGo('req');" title="승인 요청 — 켜진 탭을 다시 누르면 접기/펼치기">⏳ 승인 요청 <b id="reqCnt"></b></button>
      <button type="button" class="tb" onclick="tabGo('his');" title="조정 이력 보기">📜 조정 이력</button>
      <span id="reqHint" class="dim" style="font-size:12.5px"></span>
      <span class="sp" style="flex:1"></span>
      <label style="cursor:pointer"><input type="checkbox" id="reqAll" onchange="reqLoad();" style="height:auto;vertical-align:-2px"> 끝난 요청도 (최근 60일)</label>
      <button type="button" class="btn ghost" onclick="reqLoad(true);">새로고침</button>
    </div>
    <div id="reqMine" style="display:none"></div>
    <div class="hgrid card" id="reqWrap">
      <table>
        <thead>
          <tr>
            <th style="width:54px">번호</th>
            <th style="width:104px">상태</th>
            <th style="width:112px">상품코드</th>
            <th>상품명</th>
            <th class="r" style="width:76px">전</th>
            <th class="r" style="width:76px">후</th>
            <th class="r" style="width:76px">증감</th>
            <th>사유</th>
            <th style="width:150px">기준일자 · 창고</th>
            <th style="width:150px">요청</th>
            <th style="width:210px">처리</th>
            <th class="c rq-act" style="width:150px">작업</th>
          </tr>
        </thead>
        <tbody id="reqBody"></tbody>
      </table>
    </div>
  </div>

  <div class="hist" id="histBox" style="display:none">
    <div class="htab">
      <button type="button" class="tb" id="reqTab2" onclick="tabGo('req');" title="승인 요청 보기">⏳ 승인 요청 <b id="reqCnt2"></b></button>
      <button type="button" class="tb on" onclick="tabGo('his');" id="hisTab" title="조정 이력 — 켜진 탭을 다시 누르면 접기/펼치기">📜 조정 이력</button>
      <%-- 상품코드로 찾기 (2026-11-19 사용자 「여기에서 코드로 찾고 재고조정값 취소기능도」) — 읽어 온 이력을 화면에서 거른다(서버에 다시 묻지 않음). 띄어 쓰면 낱말이 모두 든 줄 --%>
      <input type="search" id="hQ" style="width:230px; margin-left:8px" placeholder="🔎 상품코드 / 상품명으로 찾기" oninput="hisPaint();" title="조정 이력을 상품코드·상품명으로 찾습니다 — 찾은 줄의 [이 줄만 취소]로 그 상품의 조정만 물릴 수 있습니다">
      <span class="dim" id="hQCnt" style="font-size:12px"></span>
      <span class="sp" style="flex:1"></span>
      <label>기간</label>
      <input type="date" id="hFrom"> ~ <input type="date" id="hTo">
      <label>등록자</label>
      <input type="text" id="hUser" style="width:110px" placeholder="아이디">
      <button type="button" class="btn ghost" onclick="hisLoad();">이력조회</button>
    </div>
    <div class="hgrid card" id="hisWrap">
      <table>
        <thead>
          <tr>
            <th style="width:150px">저장묶음</th>
            <th style="width:95px">기준일자</th>
            <th style="width:110px">상품코드</th>
            <th>상품명</th>
            <th class="r" style="width:90px">전</th>
            <th class="r" style="width:90px">후</th>
            <th class="r" style="width:80px">증감</th>
            <th style="width:150px">사유</th>
            <th style="width:100px">등록자</th>
            <th style="width:140px">등록일시</th>
            <th class="c" style="width:168px">되돌리기 / 취소</th>
          </tr>
        </thead>
        <tbody id="hisBody">
          <tr><td colspan="11" class="c dim" style="padding:18px">[이력조회] 를 눌러 주세요.</td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%-- ★조회 중 모래시계 (2026-08-19 요청) --%>
<div class="busy" id="busyOv"><div class="bx"><span class="hg">⏳</span><span class="tx">목록을 조회하는 중입니다…</span></div></div>

<script type="text/javascript">
var CTX  = '${pageContext.request.contextPath}';
var ROWS = [];        /* 화면에 보이는 목록(= _ALL 을 검색·필터·정렬한 결과) */
/* ★[2026-09-17 지적 「상품코드에서 수정하고 다시 조회하면 적용이 안 됨 — 로그아웃해야 함」]
     [조회] 단추와 검색칸 Enter 는 <항상> 서버를 다시 부른다(load). 종전엔 첫 조회 뒤로는 받아 둔 _ALL 만 다시 걸러(applyFilter)
     상품코드관리에서 고친 이름·입수·중지가 로그아웃(=셸 새로 로드) 전엔 안 보였다. 글자 칠 때·유형/제조사/재고0제외/정렬은 종전대로 화면에서만 거른다. */
var _ALL = [];        /* ★[2026-08-19 요청 「조회가 느림」] 서버에서 받은 전 품목 —
                          서버는 **기준일자가 바뀔 때만** 부른고(재고 누계가 그 날짜 기준이라),
                          검색어·유형·제조사·재고0제외·정렬은 applyFilter 가 화면에서 바로 건다.
                          종전에는 글자 칠 때마다 원장 집계 쿼리가 돌아 느렸다. */

function gel(id){ return document.getElementById(id); }
function esc(s){ return String(s == null ? '' : s)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function nvl(v){ return (v == null || v === '') ? 0 : Number(v); }
function alertBox(msg, icon){
  if (window._alertBox) window._alertBox(msg, { icon: icon || 'ℹ️' });
  else alert(String(msg).replace(/<[^>]+>/g,''));
}
function toast(msg){ if (window._toast) window._toast(msg); }
/* 모래시계 — 서버 조회 동안만 켜진다. ⚠끄는 것은 반드시 응답 도착 지점 모두에서(then·catch) —
   한 곳이라도 빠지면 '진행 중'으로 영영 남는다(RebuildProgress 전례). */
function busy(on, msg){
  var b=gel('busyOv'); if(!b) return;
  if(msg){ var t=b.querySelector('.tx'); if(t) t.textContent=msg; }
  b.classList.toggle('on', !!on);
}

/* ★[2026-08-19 요청] 상품코드등록(prodcd.jsp)과 같은 표시를 이 화면에도 —
     · 서브코드면 빨간 「서브」 배지 + → 주코드 + 마스터 상품명
     · 거래중지면 줄 전체 빨강 + 중지일 칸
   ★서버 SQL(selectStockAdjList)은 안 고친다 — 이미 있는 두 조회(prodList·extItemList)를
     한 번씩 받아 화면에서 짝을 맞춨다. **JSP만 바꿔 WAR 재빌드가 없다.**
   ★늘게 도착해도 맞는다 — 보조자료가 오면 목록이 이미 떠 있을 때만 다시 그린다. */
var _pm = {}, _subOf = {}, _auxOk = false;   /* _pm = prodSeq→상품줄(중지·이름) / _subOf = 서브코드→통보줄 */
function fmtDt8(v){ v=String(v||'').replace(/-/g,''); return v.length===8 ? v.slice(0,4)+'-'+v.slice(4,6)+'-'+v.slice(6,8) : v; }
/* ★보조자료(상품 마스터 · 매칭코드)는 <조회할 때마다> 다시 받는다 (2026-09-17 지적 「상품코드에서 수정하고 다시 조회하면 적용이 안 됨, 로그아웃해야 함」).
     종전엔 화면이 처음 뜰 때 한 번만 받았고, 셸이 iframe 을 살려 두므로 상품코드관리에서 고친 중지·매칭·마스터명이
     로그아웃(=셸 새로 로드) 전엔 여기 안 보였다. 목록(stockAdjList)은 원래 조회마다 새로 받는다. */
function loadAux(){
  function post(u){ return fetch(CTX+u, { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
                                          credentials:'same-origin', body:'' }).then(function(r){ return r.json(); }); }
  return Promise.all([ post('/prod/prodList.do'), post('/prod/extItemList.do') ])
    .then(function(a){
      var pm={}, sub={};
      ((a[0]&&a[0].data)||[]).forEach(function(o){ pm[o.prodSeq]=o; });
      /* 서브 판정은 prodcd.jsp 와 같은 규칙 — 통보 코드와 주코드가 다를 때만 서브다 */
      ((a[1]&&a[1].data)||[]).forEach(function(o){
        if(o.prodCd && o.extItemCd && String(o.extItemCd)!==String(o.prodCd)) sub[String(o.extItemCd)]=o;
      });
      _pm=pm; _subOf=sub;                /* 통째로 바꿔 끼운다 — 지운 매칭·풀린 중지도 사라지게 */
      _auxOk=true;
      if(ROWS.length) render();          /* 목록이 먼저 떠 있으면 표시만 덧그린다 */
    })
    .catch(function(){ /* 보조표시만 빠질 뿐 조정 자체는 동작한다 — 조용히 넘어간다 */ });
}
loadAux();
/* 셸 메뉴로 다시 들어올 때 — 다른 화면(상품코드관리)에서 고친 것을 반영. 적다 만 조정 수량이 있을 수 있어 목록은 안 건드리고 보조자료만 새로 받아 덧그린다(목록은 [조회]로) */
window.konetShown=function(){ loadAux(); if(typeof reqLoad==='function') reqLoad(); };   /* 승인 요청도 다시(2026-11-18) */

/* 오늘 날짜를 기본값으로 */
(function(){
  var d = new Date();
  gel('baseDt').value = d.getFullYear() + '-'
      + ('0'+(d.getMonth()+1)).slice(-2) + '-' + ('0'+d.getDate()).slice(-2);
})();


/* ── 검색 = Enter 또는 [리스트조회] (2026-08-20 요청 — 「치는 대로 조회」 폐지) ─────
   글자를 칠 때마다 그리면 ①목록 미조회 상태에선 현재고 집계(원장 합계) 조회까지 돌아 느리고
   ②읽은 뒤에도 2,000행 재그리기가 반복돼 순간순간 늦었다.
   이제 검색칸은 아무것도 하지 않는다 — Enter(위 onkeydown) 나 [리스트조회] 를 눌러야 걸린다.
   되살리자는 얘기가 나오면 이 이력부터 확인할 것. */

/* 드롭다운·체크·날짜는 바꾸는 즉시 조회 */
(function(){
  /* ★기준일자만 서버 재조회(재고 누계가 그 날짜 기준) — 나머지는 화면 필터만 재적용(2026-08-19) */
  ['sortGb','typeNm','makerNm'].forEach(function(id){
    var el = gel(id); if (el) el.onchange = function(){ if (_ALL.length) applyFilter(); };
  });
  var b = gel('baseDt'); if (b) b.onchange = function(){ load(); };
  var z = gel('zeroExc'); if (z) z.onchange = function(){ if (_ALL.length) applyFilter(); };
})();

/* ★검색·필터·정렬을 _ALL 에 걸어 ROWS 를 만든다 — 서버 SQL 과 같은 규칙
   (검색 = 코드·상품명·규격 부분일치 / 유형·제조사 일치 / 재고 0 제외 / 정렬 CD·NM·QTY).
   ⚠규칙을 바꾸면 selectStockAdjList 쪽 필터도 같이 볼 것 — 이 화면은 이제 안 타지만
   SQL 에는 그대로 남아 있다(다른 호출부가 쓸 수 있어 안 지웠다). */
var _fltSig = '';   /* 마지막으로 그린 조건 — 같으면 재렌더 생략(2026-08-19 「순간순간 늦다」) */
var _hitCnt = null; /* 검색으로 실제 걸린 건수 — 건수칸에 같이 적어 '검색됐다'를 보이게 */
/* ★한 번에 그리는 줄 수 상한 (2026-08-20 「속도가 많이 늦다」)
     행마다 입력칸이 3개라 1,943행이면 5,800개다 — 그리는 것만으로 화면이 굳는다.
     실제 사용은 '찾아서 몇 품목 고치기'라 전 품목을 펼쳐 둘 일이 없다.
     ★넘친 줄은 조용히 버리지 않는다 — 건수칸에 몇 건이 안 보이는지 적는다. */
var LIST_MAX = 200;
var _FLT = [];        /* 걸러진 전체 목록(상한 자르기 전) — 엑셀용 */
var _cut     = 0;   /* 상한에 걸려 화면에서 빠진 줄 수 */
var _allVer = 0;    /* load() 가 새 자료를 받을 때마다 올린다 — 같은 조건이라도 새 자료면 다시 그린다 */
function applyFilter(){
  var q  = gel('findData').value.trim().toLowerCase();
  var ty = gel('typeNm').value, mk = gel('makerNm').value, z0 = gel('zeroExc').checked;
  var sig = [q, ty, mk, z0?1:0, gel('sortGb').value, _allVer].join('|');
  if (sig === _fltSig) return;   /* 조건이 그대로면 또 그리지 않는다(수정 중이던 값도 안 날린다) */
  _fltSig = sig;

  /* ★★검색 = 상품코드등록(prodcd.jsp pcFilter) 과 같은 규칙 (2026-08-20 요청)
       「걸린 것만」 보여 준다 — 이웃도, 장부식도 없다.
       거쳐 온 세 방식(걸린 것 맨 위 / 뒤쪽 이웃 100줄 / 앞뒤 이웃)은 모두 같은 문제를 낳았다 —
       걸린 것이 이웃에 묻혀 "검색이 안 된다"로 보이거나, 걸린 줄을 위로 올려 코드 순서가 깨졌다.
     ★검색 칸도 상품코드등록과 같다 — 코드·상품명·규격·제조사·유형.
     ★정렬은 검색 중에도 그대로 먹는다(종전엔 장부식이라 무시했다). */
  var base = _ALL.filter(function(r){
    if (z0 && nvl(r.curQty) === 0) return false;
    if (ty && String(r.typeNm||'')  !== ty) return false;
    if (mk && String(r.makerNm||'') !== mk) return false;
    if (!q) return true;
    return [r.prodCd, r.prodNm, r.spec, r.makerNm, r.typeNm]
             .some(function(v){ return String(v||'').toLowerCase().indexOf(q) >= 0; });
  });

  var sg = gel('sortGb').value;
  base.sort(function(a,b){
    if (sg === 'QTY'){ var d = nvl(b.curQty) - nvl(a.curQty); if (d) return d; }
    else if (sg === 'NM'){ var n = String(a.prodNm||'').localeCompare(String(b.prodNm||''),'ko'); if (n) return n; }
    return String(a.prodCd||'') < String(b.prodCd||'') ? -1 : (String(a.prodCd||'') > String(b.prodCd||'') ? 1 : 0);
  });

  /* 한 번에 그리는 줄 상한 — 행마다 입력칸이 3개라 전 품목을 펼치면 화면이 굳는다.
     넘친 줄은 조용히 버리지 않고 건수칸에 적는다. */
  _FLT = base;   /* 엑셀은 화면 상한(LIST_MAX) 전의 전체 걸러진 목록을 쓴다 (2026-09-23) */
  _cut = 0;
  if (base.length > LIST_MAX){ _cut = base.length - LIST_MAX; base = base.slice(0, LIST_MAX); }
  ROWS = base;
  _hitCnt = q ? (ROWS.length + _cut) : null;
  render();
}
/* ── 목록 ────────────────────────────────────────────────────────── */
function load(){
  /* ★서버에는 **기준일자만** 보낸다(2026-08-19) — 전 품목을 받아 두고
     검색·필터·정렬은 applyFilter 가 화면에서 건다 — 글자 칠 때마다
     원장 집계 쿼리가 도는 것이 느린 원인이었다. */
  var p = new URLSearchParams();
  /* ★[2026-09-13 「두 화면 맞추기」] 기준일자가 <오늘 이후>면 날짜로 자르지 않는다 = 품목별재고현황과 같은 «전체 현재고».
       원장 출고의 날짜는 <납기일자>라, 내일 납기분(이미 창고에서 나간 것)이 오늘 기준으로는 빠져 두 화면이 달랐다
       (9904013376 : 재고 일괄조정 983 / 품목별재고현황 977 — 9/14 납기 6개 차이). 조정 저장은 화면의 이 숫자를 조정 전 수량으로 쓴다.
       지난 날짜를 고르면 종전대로 그날까지의 누계. */
  var _bd = gel('baseDt').value || '', _nw = new Date(),
      _td = _nw.getFullYear() + '-' + ('0'+(_nw.getMonth()+1)).slice(-2) + '-' + ('0'+_nw.getDate()).slice(-2);
  p.append('asOfDt',    (_bd && _bd < _td) ? _bd : '');
  p.append('whCd',      gel('adjWh').value || '');          /* 창고(2026-09-16 P3) — 비면 전 창고 합계 */

  gel('body').innerHTML = '<tr><td colspan="13" class="c dim" style="padding:26px">불러오는 중…</td></tr>';

  busy(true, '목록을 조회하는 중입니다…');           /* ★모래시계 — 문구는 '조회'(2026-08-19 지적: 재고집계 아님) */
  loadAux();                                         /* 보조자료(중지·매칭·마스터명)도 새로 — 2026-09-17 */
  fetch(CTX + '/prod/stockAdjList.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body: p.toString() })
    .then(function(r){ return r.json(); })
    /* ★busy 는 applyFilter(=2,000행 그리기) 뒤에 끈다 — 그리기도 체감 대기시간이다.
       applyFilter 가 터져도 아래 catch 가 받아 busy(false) 를 불러 안 남는다. */
    .then(function(d){ _ALL = (d && d.data) || []; _allVer++; fillFilters(); applyFilter(); busy(false); })
    .catch(function(){ busy(false); alertBox('목록을 불러오지 못했습니다.', '⚠️'); });
}

function render(){
  if (!ROWS.length){
    gel('body').innerHTML = '<tr><td colspan="13" class="c dim" style="padding:26px">자료가 없습니다.</td></tr>';
    gel('cnt').textContent = '0건';
    gel('chgCnt').textContent = '0';
    return;
  }
  gel('body').innerHTML = ROWS.map(function(r, i){
    var cur = nvl(r.curQty);
    /* ★상품코드등록과 같은 표시(2026-08-19) — 주코드 · 서브 배지 + 마스터 상품명 / 중지행 빨강 */
    var st=_pm[r.prodSeq]||{}, stopped=(st.stopYn==='Y');
    var sb=_subOf[String(r.prodCd)], cdCell=esc(r.prodCd), mstNm='';
    /* 검색에 걸린 코드는 굵은 초록 — 그 아래로는 다음 코드들이 이어진 것(장부식, 판매·매입 검색과 동일) */
    if(r._hit) cdCell='<b style="color:#1f7a4d">'+cdCell+'</b>';
    if(stopped) cdCell='<span style="white-space:nowrap">'+cdCell+' <span class="stopbdg">중지</span></span>';
    if(sb){
      var mp=_pm[sb.prodSeq]||{};
      /* ★주코드가 중지된 상품이면 빨강 + (중지) — 한눈에 알아보게(2026-08-19) */
      var mStop=(mp.stopYn==='Y');
      /* ★[2026-09-23 요청 「상품코드등록처럼 주코드를 위에」] 상품코드등록(prodcd.jsp)과 **같은 차례** —
           위 = [주] 주코드 · 아래 = [서브] 이 줄 자신의 코드(검색 강조·중지 배지 그대로).
           종전엔 제 코드가 위, 「서브 → 주코드」가 아래였다. 정렬·검색·저장은 여전히 이 줄 자신의 코드(r.prodCd)로 한다.
         ★주코드는 여기서 **보여주기만** 한다(2026-08-19 확정) — 누르는 자리 아님.
           이 화면은 재고를 고치는 곳이지 코드를 다루는 곳이 아니다 — 코드 정리는 상품코드등록에서. */
      var ownCd = cdCell;
      cdCell = '<div><span class="mainbdg">주</span>'
             +  ' <span class="subgo'+(mStop?' stop':'')+'"'
             +  ' title="이 줄의 코드 '+esc(r.prodCd)+' 는 주코드 '+esc(sb.prodCd)+' 의 매칭코드입니다'+(mStop?' (거래중지된 상품)':'')+'">'
             +  esc(sb.prodCd)+(mStop?' (중지)':'')+'</span></div>'
             +  '<div style="margin-top:2px"><span class="subbdg">서브</span> '+ownCd+'</div>';
      if(mp.prodNm) mstNm='<div class="mstnm">마스터 : '+esc(mp.prodNm)+'</div>';
    }
    return '<tr id="tr'+i+'"'+(stopped?' class="stopped"':'')+'>'
      + '<td>' + cdCell + '</td>'
      /* ★상품명도 코드와 «같은 차례»로 (2026-10-01 「주코드·서브코드 명칭 오류 수정(순서 오류)」) — 코드 칸이 위 = [주] · 아래 = [서브] 이므로
           이름도 위 = 마스터(주코드) 이름 · 아래 = 이 줄(서브) 이름. 종전엔 제 이름이 위라 주코드 옆에 서브의 이름이 놓였다(상품코드등록과 같이 고침) */
      + '<td class="nm" style="white-space:normal">' + mstNm + esc(r.prodNm) + '</td>'
      + '<td>' + esc(r.spec) + '</td>'
      + '<td class="c"><input class="ed pk" id="pk'+i+'" value="' + nvl(r.packQty) + '"'
      +     ' title="입수수량(BOX당 EA) — 엔터를 치거나 칸을 벗어나면 BOX/EA 가 다시 나뉩니다"'
      +     ' onkeydown="if(event.keyCode===13){ packChg(' + i + '); this.blur(); }"'
      +     ' onchange="packChg(' + i + ')"></td>'
      + '<td>' + esc(r.typeNm) + '</td>'
      /* 중지일 — 중지된 상품만 적힌다(2026-08-19) */
      + '<td class="c">' + (stopped ? esc(fmtDt8(st.stopFrDt)) : '') + '</td>'
      + '<td class="r" id="vb'+i+'">' + nvl(r.boxQty) + '</td>'
      + '<td class="r" id="ve'+i+'">' + nvl(r.eaQty) + '</td>'
      + '<td class="r' + (cur < 0 ? ' neg' : '') + '">' + cur + '</td>'
      + '<td class="c"><input class="ed" id="bx'+i+'" value="' + nvl(r.boxQty) + '"'
      +     ' oninput="chg(' + i + ')"></td>'
      + '<td class="c"><input class="ed" id="ea'+i+'" value="' + nvl(r.eaQty) + '"'
      +     ' oninput="chg(' + i + ')"></td>'
      + '<td class="r" id="df'+i+'"><span class="dim">-</span></td>'
      + '<td class="r" id="af'+i+'"><span class="dim">-</span></td>'   /* 조정 후 재고 — 고치면 chg() 가 채운다 (2026-11-19) */
      + '</tr>';
  }).join('');
  gel('cnt').textContent = ROWS.length + '건'
    + (_hitCnt != null ? ' (검색 ' + _hitCnt + '건 · 앞뒤 이웃 포함)' : '')
    + (_cut ? ' · ' + _cut + '건은 안 보임 — 검색해서 좁히세요' : '');
  /* ★[2026-08-19 「순간순간 늦다」] 종전에는 여기서 전 행에 chg() 를 돌렸다(2,000행×DOM 조회 5회 ≈ 1만 회).
     그린 직후에는 수정칸 = 현재값이라 **증감이 전부 0** — 증감 칸은 HTML 에 '-' 로 바로 박고
     건수만 0 으로 맞춘다. 값을 손대면 그때 chg(i) 가 그 한 줄만 다시 계산한다. */
  gel('chgCnt').textContent = '0';
}


/* ── 📥 엑셀 (2026-09-23 요청 「표시부분에 엑셀출력」) ─────────────────────────────
   화면 표와 같은 칸 + 구분/주코드/제조사 — 상품코드등록 pcExcel 과 같은 방식(셸의 SheetJS 를 빌려 쓰고 없으면 CSV).
   ★대상 = 지금 조건으로 걸러진 **전체**(_FLT) — 화면은 200줄 상한이라 「58건은 안 보임」이 엑셀에는 다 들어간다.
   수정BOX/EA·증감은 화면에 그려진 줄(ROWS)의 입력칸 값을 읽는다 — 상한 밖 줄은 빈 칸. */
function adjExcel(){
  var list=_FLT.length?_FLT:ROWS; if(!list.length){ alertBox("출력할 자료가 없습니다 — 먼저 [리스트조회]를 누르세요.","⚠️"); return; }
  var idx={}; ROWS.forEach(function(r,i){ idx[String(r.prodSeq)+"|"+String(r.prodCd)]=i; });
  var head=["상품코드","구분","주코드","상품명","규격","입수수량","유형","제조사","중지일","BOX재고","EA재고","합계재고","수정BOX재고","수정EA재고","증감","조정 후 재고"];
  var aoa=[head].concat(list.map(function(r){
    var st=_pm[r.prodSeq]||{}, sb=_subOf[String(r.prodCd)], i=idx[String(r.prodSeq)+"|"+String(r.prodCd)];
    var bx="", ea="", df="", af="";
    if(i!=null && gel("bx"+i)){ bx=nvl(gel("bx"+i).value); ea=nvl(gel("ea"+i).value); var pk=nvl(gel("pk"+i)?gel("pk"+i).value:r.packQty)||1;
      df=(bx*pk+ea)-nvl(r.curQty); af=bx*pk+ea; }
    return [r.prodCd, sb?"서브":"", sb?sb.prodCd:"", r.prodNm, r.spec, nvl(r.packQty), r.typeNm||"", r.makerNm||"",
            st.stopYn==="Y"?fmtDt8(st.stopFrDt):"", nvl(r.boxQty), nvl(r.eaQty), nvl(r.curQty), bx, ea, df, af];
  }));
  var wh=gel("adjWh"), whNm=wh&&wh.options[wh.selectedIndex]?wh.options[wh.selectedIndex].text:"전체", bd=gel("baseDt").value||"";
  var fn="재고일괄조정_"+(bd||"전체")+(whNm&&whNm!=="전체"?"_"+whNm:"")+".xlsx";
  var P=window.parent;
  function byLib(LIB){
    var ws=LIB.utils.aoa_to_sheet(aoa);
    ws["!cols"]=[{wch:14},{wch:6},{wch:14},{wch:44},{wch:22},{wch:9},{wch:16},{wch:14},{wch:11},{wch:9},{wch:9},{wch:9},{wch:11},{wch:11},{wch:8},{wch:12}];
    /* ★머리글 고정 + 색 (2026-09-23 「헤더 고정으로 하고 색깔 틀리게」) — 첫 줄을 화면 표 머리글과 같은 청록 칠·흰 글자·굵게, 스크롤해도 남게 고정.
       색은 스타일본(xlsx-js-style)일 때만 먹고 원본 SheetJS 면 조용히 무시된다(s 칸을 안 읽는다). 수정BOX/EA 두 칸은 입력칸이라 노랑으로 갈라 둔다 */
    ws["!freeze"]={xSplit:0, ySplit:1, topLeftCell:"A2", activePane:"bottomLeft", state:"frozen"};
    ws["!autofilter"]={ref:"A1:O"+aoa.length};
    var bd={style:"thin",color:{rgb:"B7C9C3"}}, BD={top:bd,bottom:bd,left:bd,right:bd};
    var HS={fill:{fgColor:{rgb:"137A6C"}},font:{bold:true,color:{rgb:"FFFFFF"}},alignment:{horizontal:"center",vertical:"center"},border:BD};
    var HE={fill:{fgColor:{rgb:"E9A23B"}},font:{bold:true,color:{rgb:"FFFFFF"}},alignment:{horizontal:"center",vertical:"center"},border:BD};
    for(var c=0;c<head.length;c++){ var a=LIB.utils.encode_cell({r:0,c:c}); if(ws[a]) ws[a].s=(c===12||c===13)?HE:HS; }
    ws["!rows"]=[{hpt:22}];
    var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,"재고일괄조정"); LIB.writeFile(wb,fn);
    toast("📥 엑셀 저장 완료 · "+list.length+"건"+(list.length>ROWS.length?" (화면 밖 "+(list.length-ROWS.length)+"건 포함)":"")); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csv(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csv();
  function csv(){ var c=aoa.map(function(r){ return r.map(function(x){ x=(x==null?"":(""+x)); return "\""+x.replace(/"/g,"\"\"")+"\""; }).join(","); }).join("\r\n");
    var b=new Blob(["\ufeff"+c],{type:"text/csv;charset=utf-8"}), a=document.createElement("a");
    a.href=URL.createObjectURL(b); a.download=fn.replace(/\.xlsx$/,".csv"); document.body.appendChild(a); a.click(); a.remove();
    toast("📥 CSV 저장 완료 · "+list.length+"건"); }
}
/* ── 입수수량 자동채우기 ─────────────────────────────────────────────
   상품명 끝에 적힌 포장 단위를 읽어 입수수량 칸에 넣는다.

     크라프트사각용기몸체,…,300EA           → 300
     OPP봉투,20*25CM,2000EA/BOX             → 2000
     (25입)수제샌드위치…,300EA               → 300
     1883 시럽 1.0L*6ea묶음                  → 6
     자스민8/9oz 컵(백색)/1000매(AFP)        → 1000
     8KG(200EA/BOX)                          → 200

   ★규칙 : 숫자 바로 뒤에 EA·매·장·입·PCS 가 붙은 것만 잡는다.
     치수(MM·CM)·용량(OZ·KG·L)은 단위가 달라 걸리지 않는다.
   ★여러 개면 **마지막 것**을 쓴다 — 포장 단위는 이름 끝에 붙는다.
   ★바로 저장하지 않는다. 칸에 채워만 두니 눈으로 보고 고친 뒤 [수정저장] 을 누르면 된다. */
var PACK_RE = /([0-9][0-9,]*)\s*(EA|PCS|매|장|입)(?![A-Za-z0-9])/gi;

function packOf(nm){
  if (!nm) return 0;
  var m, last = 0;
  PACK_RE.lastIndex = 0;
  while ((m = PACK_RE.exec(nm)) !== null){
    var v = parseInt(String(m[1]).replace(/,/g,''), 10);
    if (v > 0 && v <= 1000000) last = v;      /* 터무니없는 값은 버린다 */
  }
  return last;
}

function packAuto(){
  if (!ROWS.length){ alertBox('먼저 목록을 조회해 주세요.', '⚠️'); return; }

  var hit = 0, skip = 0, same = 0;
  for (var i = 0; i < ROWS.length; i++){
    var v = packOf(ROWS[i].prodNm);
    if (!v){ skip++; continue; }               /* 이름에 포장 단위가 없다 */
    if (v === curPack(i)){ same++; continue; } /* 이미 같은 값 */
    gel('pk'+i).value = v;
    packChg(i);                                /* BOX/EA 표시도 다시 나눈다 */
    hit++;
  }

  var msg = '<div style="text-align:left; line-height:1.8">'
          + '<b>' + hit + '건</b> 을 채웠습니다.<br>'
          + '<span style="color:#7b8b97">이미 맞음 ' + same + '건 · 이름에 단위 없음 ' + skip + '건</span><br>'
          + '<b>아직 저장 전입니다.</b> 값을 확인하신 뒤 [수정저장] 을 눌러 주세요.</div>';
  alertBox(msg, hit ? '✅' : 'ℹ️');
}
/* 화면에 적힌 입수수량 (비었거나 1 미만이면 1) */
function curPack(i){
  var v = nvl(gel('pk'+i) ? gel('pk'+i).value : 0);
  return v < 1 ? 1 : v;
}


/* 입수수량을 고쳤을 때 — 재고를 새 기준으로 다시 나눠 보여준다.
   ★수정칸도 같이 맞춰 준다. 안 그러면 BOX칸의 옛 숫자가 새 입수수량으로 곱해져
     건드리지도 않은 재고가 크게 바뀐 것처럼 잡힌다(2026-08-19 지적).
   ★재고 자체는 안 바뀐다 — 나누는 기준만 바뀐다. */
function packChg(i){
  var r    = ROWS[i];
  var pack = curPack(i);
  var cur  = nvl(r.curQty);
  var sign = cur < 0 ? -1 : 1;
  var box  = sign * Math.floor(Math.abs(cur) / pack);
  var ea   = sign * (Math.abs(cur) % pack);

  gel('vb'+i).textContent = box;      // 표시 BOX재고
  gel('ve'+i).textContent = ea;       // 표시 EA재고
  gel('bx'+i).value = box;            // 수정칸도 같은 값으로 — 증감 0 이 된다
  gel('ea'+i).value = ea;

  chg(i);
}
/* 한 줄의 증감 계산 — 고친 줄만 표시가 바뀐다 */
function chg(i, quiet){
  var r    = ROWS[i];
  var pack = curPack(i);                       /* 화면에서 고친 입수수량을 쓴다 */
  var aft  = nvl(gel('bx'+i).value) * pack + nvl(gel('ea'+i).value);
  var diff = aft - nvl(r.curQty);

  var td = gel('df'+i), tr = gel('tr'+i), af = gel('af'+i);
  /* 조정 후 재고 (2026-11-19) — 증감만으로는 «그래서 재고가 얼마가 되나»를 암산해야 했다. 고친 줄에만 굵게, 음수면 빨강 */
  if (af) af.innerHTML = (diff === 0) ? '<span class="dim">-</span>'
       : '<b class="aft' + (aft < 0 ? ' neg' : '') + '" title="조정 후 재고 = 수정BOX ' + nvl(gel('bx'+i).value) + ' × 입수 ' + pack + ' + 수정EA ' + nvl(gel('ea'+i).value) + ' (지금 ' + nvl(r.curQty) + ')">' + aft + '</b>';
  if (diff === 0){
    td.innerHTML = '<span class="dim">-</span>';
    tr.classList.remove('chg');
  } else {
    td.innerHTML = '<span class="diff ' + (diff > 0 ? 'up' : 'dn') + '">'
                 + (diff > 0 ? '+' : '') + diff + '</span>';
    tr.classList.add('chg');
  }
  if (!quiet) countChg();
  else if (i === ROWS.length - 1) countChg();
}

function countChg(){
  var n = 0;
  for (var i = 0; i < ROWS.length; i++){
    var pack = curPack(i);
    var aft  = nvl(gel('bx'+i).value) * pack + nvl(gel('ea'+i).value);
    if (aft - nvl(ROWS[i].curQty) !== 0) n++;
  }
  gel('chgCnt').textContent = n;
  return n;
}

/* 유형·제조사 드롭다운은 불러온 자료에서 만든다 */
function fillFilters(){
  ['typeNm','makerNm'].forEach(function(k){
    var sel = gel(k), keep = sel.value, seen = {}, opts = ['<option value="">전체</option>'];
    _ALL.forEach(function(r){                 /* ★걸러진 ROWS 가 아니라 전 품목 — 고를수록 선택지가 줄면 안 된다 */
      var v = r[k];
      if (v && !seen[v]){ seen[v] = 1; opts.push('<option value="'+esc(v)+'">'+esc(v)+'</option>'); }
    });
    sel.innerHTML = opts.join('');
    sel.value = keep;
  });
}

/* ── 저장 ────────────────────────────────────────────────────────────
   두 가지를 함께 저장한다.
     ① 입수수량  — 고친 것만. 재고는 안 건드리고 환산 기준만 바뀐다.
     ② 재고 조정 — 차이만큼 조정행(A) + 이력.
   ★입수수량을 먼저 저장한다. 나중에 하면 조정 이력에 옛 입수수량이 박힌다. */
function save(){
  if (!ROWS.length){ alertBox('먼저 목록을 조회해 주세요.', '⚠️'); return; }
  if (!gel('adjWh').value){ alertBox('조정할 창고를 고르세요 — 전 창고 합계로는 조정할 수 없습니다.', '⚠️'); return; }   /* 2026-09-16 P3 */

  var packs = [], rows = [];
  for (var i = 0; i < ROWS.length; i++){
    var r    = ROWS[i];
    var pack = curPack(i);
    var aBox = nvl(gel('bx'+i).value), aEa = nvl(gel('ea'+i).value);

    // ① 입수수량이 바뀐 줄
    if (pack !== (nvl(r.packQty) < 1 ? 1 : nvl(r.packQty)))
      packs.push({ prodSeq:r.prodSeq, packQty:pack });

    // ② 재고가 바뀐 줄 — 안 고쳤으면 보내지 않는다
    if (aBox * pack + aEa - nvl(r.curQty) === 0) continue;
    rows.push({ prodSeq:r.prodSeq, prodCd:r.prodCd, prodNm:(r.prodNm||''), packQty:pack,   /* prodNm = 승인 요청 목록 표시용(서버 저장은 안 쓴다) */
                befQty:nvl(r.curQty), befBox:nvl(r.boxQty), befEa:nvl(r.eaQty),
                aftBox:aBox, aftEa:aEa });
  }

  if (!packs.length && !rows.length){ alertBox('고친 줄이 없습니다.', 'ℹ️'); return; }

  var post = function(url, body){
    return fetch(CTX + url, { method:'POST', headers:{'Content-Type':'application/json'},
                              credentials:'same-origin', body: JSON.stringify(body) })
             .then(function(r){ return r.json(); });
  };

  var go = function(){
    gel('btnSave').disabled = true;
    busy(true, '저장하는 중입니다…');            /* ★모래시계 (2026-08-19) — load() 가 이어서 제 문구로 갈아끼운다 */

    // 입수수량 먼저 → 그 다음 재고 조정
    var step1 = packs.length ? post('/prod/packQtySave.do', { rows: packs })
                             : Promise.resolve({ result:'OK', cnt:0 });

    step1.then(function(d1){
      if (!d1 || d1.result !== 'OK') throw new Error((d1 && d1.message) || '입수수량 저장 실패');
      if (!rows.length) return { result:'OK', cnt:0, _skip:true };
      return post('/prod/stockAdjSave.do',
                  { baseDt: gel('baseDt').value, remark: gel('remark').value.trim(), whCd: gel('adjWh').value || '', src:'stockAdj', rows: rows });
    })
    .then(function(d2){
      gel('btnSave').disabled = false;
      /* ★REQ = 승인 요청으로 쌓였다(관리자가 아닌 직원 · 2026-11-18) — 재고는 아직 그대로다 */
      if (!d2 || (d2.result !== 'OK' && d2.result !== 'REQ')) throw new Error((d2 && d2.message) || '재고 조정 실패');
      var msg = [];
      if (packs.length) msg.push('입수수량 ' + packs.length + '건 저장');
      if (d2.result === 'REQ'){
        msg.push('재고 ' + (d2.cnt || 0) + '건 <b>승인 요청</b>');
        busy(false);
        alertBox(msg.join(' · ') + '<br><span style="font-size:13px;color:#5b6b7a">총괄관리자·부관리자가 승인하면 재고에 반영됩니다.<br>재고는 아직 바뀌지 않았습니다 — 아래 [⏳ 승인 요청]에서 진행을 볼 수 있습니다.</span>', '⏳');
      } else {
        if (rows.length) msg.push('재고 ' + (d2.cnt || 0) + '건 저장');
        toast(msg.join(' · ').replace(/ 저장/g, '') + ' 저장했습니다.');
      }
      load();                                   /* 바뀐 값으로 다시 그린다 */
      reqLoad(); reqBadge();
    })
    .catch(function(e){
      gel('btnSave').disabled = false;
      busy(false);
      alertBox('저장하지 못했습니다.<br>' + esc(e && e.message ? e.message : ''), '⚠️');
    });
  };

  /* ★★서브코드 줄은 저장하지 않는다 (2026-09-10 신설) ─────────────────────────────
       서브코드(거래처 매칭코드)는 «남의 코드»라 **재고의 주인이 아니다.** 그 줄로 조정하면
       같은 물건의 재고가 주코드와 서브코드로 갈라진다 :
         실측 2026-09-10 14:15 — 조정 +157 이 서브코드 1000791735 로 들어가고
         주코드 9904013072 는 −145 그대로였다. 고친 사람은 고쳤다고 믿는다.
       ⚠**[출고반영 재집계]로도 안 고쳐진다** — 그 버튼은 출고 원천(발주현황표·정산서)만 다시 만든다.
     ★막는 곳은 서버(stockAdjSave)다 — 여기는 «저장 전에 먼저 알려 주는» 편의다(매입과 같은 꼴).
     ★바꿔 주지 않는다 — 조정은 <앞수량·뒷수량>이 짝이라 코드만 옮기면 주코드 현재고와 어긋난다.
       대신 주코드를 알려 주고, 그 줄을 화면에서 찾아 준다(검색칸에 넣어 준다). */
  var subBad = [];
  rows.forEach(function(r){
    var sb = _subOf[String(r.prodCd)];
    if (sb && sb.prodCd && String(sb.prodCd) !== String(r.prodCd)) subBad.push({ sub:r.prodCd, main:sb.prodCd, nm:(sb.prodNm||sb.extItemNm||'') });
  });
  if (subBad.length){
    var h = subBad.map(function(s){
      return '<div style="margin:4px 0"><b style="color:#c0392b">' + esc(s.sub) + '</b> (서브)'
           + ' &nbsp;→&nbsp; 주코드 <b style="color:#1f7a4d">' + esc(s.main) + '</b>'
           + (s.nm ? ' <span style="color:#5b6b7a;font-size:12.5px">' + esc(s.nm) + '</span>' : '') + '</div>';
    }).join('');
    var one = subBad[0];
    if (window._confirmBox){
      window._confirmBox({
        icon: '⚠️',
        msg: '<div style="text-align:left; line-height:1.6">서브코드 줄은 <b>재고조정을 할 수 없습니다.</b>'
           + '<div style="margin:8px 0;font-size:12.5px;color:#5b6b7a">서브코드로 조정하면 같은 물건의 재고가 <b>두 코드로 갈라집니다</b>'
           + ' — 조정한 수량이 주코드 재고에는 안 잡힙니다.</div>' + h
           + '<div style="margin-top:8px;font-size:12.5px;color:#5b6b7a">주코드 줄에서 다시 조정해 주세요.</div></div>',
        okText: '주코드 찾기',
        /* [주코드 찾기] — 검색칸에 주코드를 넣고 그 줄만 불러 준다(목록을 다시 뒤지지 않게) */
        onOk: function(){ var s=gel('findData'); if(s){ s.value=one.main; load(); s.focus(); } }
      });
    } else {
      alertBox('서브코드 줄은 재고조정을 할 수 없습니다 — 주코드 ' + esc(one.main) + ' 줄에서 조정하세요.', '⚠️');
    }
    return;                                   /* 저장하지 않는다 */
  }

  var lines = [];
  if (packs.length) lines.push('입수수량 <b>' + packs.length + '건</b> — 환산 기준만 바뀝니다(재고 그대로).');
  var needAppr = (_req.ready && !_req.admin);        /* 직원 = 승인 요청 (서버가 최종 판정 — 화면은 문구만 맞춘다) */
  if (rows.length)  lines.push('재고 <b>' + rows.length + '건</b> 을 <b>'
                             + esc(gel('baseDt').value) + '</b> 자로 ' + (needAppr ? '조정하도록 <b style="color:#8a5a00">승인 요청</b>합니다.' : '조정합니다.'));
  if (rows.length && needAppr) lines.push('<span style="font-size:12.5px;color:#5b6b7a">총괄관리자·부관리자가 승인해야 재고에 반영됩니다(그 전엔 재고 그대로).</span>');
  /* 이미 승인 대기 중인 품목을 또 올리면, 둘 다 승인될 때 증감이 두 번 들어간다 — 미리 알린다 */
  var dupP = rows.filter(function(r){ return _req.pend[String(r.prodSeq)]; });
  if (dupP.length) lines.push('<span style="font-size:12.5px;color:#b23b3b">⚠ 이미 <b>승인 대기 중</b>인 품목 ' + dupP.length + '개 ('
                             + dupP.slice(0,3).map(function(r){ return esc(r.prodCd); }).join(', ') + (dupP.length>3 ? ' …' : '')
                             + ') — 둘 다 승인되면 증감이 <b>두 번</b> 반영됩니다. 앞 요청을 취소·반려한 뒤 올리는 것이 안전합니다.</span>');

  if (window._confirmBox){
    window._confirmBox({
      icon: '❓',
      msg: '<div style="text-align:left; line-height:1.7">' + lines.join('<br>') + '</div>',
      okText: (rows.length && needAppr) ? '승인 요청' : '저장',
      onOk: go
    });
  } else go();
}

/* ══ 승인 요청 (2026-11-18 사용자 「총괄관리자 및 부관리자가 승인해야 저장되게 — 작성 후 승인이 돼야 저장」) ══════════
   · 직원이 [승인 요청]을 누르면 서버(stockAdjSave)가 재고를 바꾸지 않고 요청으로 쌓는다(result 'REQ').
   · 총괄관리자·부관리자는 여기서 [✔ 승인] → 그때 종전 저장이 그대로 돈다(조정행 + 조정 이력 · 등록자 = 요청한 사람 · 사유 끝에 「(승인 ○○)」).
     [✖ 반려]는 사유를 적는다. 요청한 본인은 대기 중인 제 요청을 [요청 취소] 할 수 있다.
   · 관리자가 직접 누른 [수정저장]은 요청을 거치지 않고 바로 반영된다.
   · 반영되는 것은 요청 때의 «전 → 후 차이(증감)» 다 — 요청과 승인 사이에 출고가 더 나가도 증감은 같다(줄을 펼치면 보인다).
   · 누가 관리자인지는 서버가 준다(_req.admin) — 화면은 단추·문구만 맞추고, 막는 것은 전부 서버다.
   · 요청 목록을 못 받으면(옛 서버 · 표 없음) 상자를 숨기고 종전 화면 그대로 둔다. */
var _req = { ready:false, admin:false, me:'', list:[], open:{}, pend:{}, fold:false };
function reqItems(q){ try{ var a = JSON.parse(q.payload || '[]'); return (a && a.length) ? a : []; }catch(e){ return []; } }
function reqAft(it){ var p = nvl(it.packQty) < 1 ? 1 : nvl(it.packQty); return nvl(it.aftBox) * p + nvl(it.aftEa); }
function reqLoad(say){
  var all = gel('reqAll') && gel('reqAll').checked;
  fetch(CTX + '/prod/stockAdjReqList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
        credentials:'same-origin', body:'pendOnly=' + (all ? '' : 'Y') })
    .then(function(r){ if(!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(function(d){
      if (!d || d.result !== 'OK') throw new Error((d && d.message) || '');
      _req.ready = true; _req.admin = (d.admin === 'Y'); _req.me = String(d.me || ''); _req.list = d.data || []; _req.mine = d.mine || [];
      _req.pend = {};
      _req.list.forEach(function(q){ if (q.statGb === 'P') reqItems(q).forEach(function(it){ if (reqAft(it) - nvl(it.befQty) !== 0) _req.pend[String(it.prodSeq)] = 1; }); });
      reqRender();
      if (say) toast('승인 요청 목록을 다시 읽었습니다.');
    })
    .catch(function(){ _req.ready = false; tabPaint(); reqRole(); });   /* 승인 요청을 못 받으면 조정 이력만 (tabPaint) */
}
/* 역할에 맞춰 저장 단추 이름을 바꾼다 — 직원 = 「승인 요청」 */
function reqRole(){
  var b = gel('btnSave'); if (!b) return;
  var need = (_req.ready && !_req.admin);
  b.textContent = need ? '승인 요청' : '수정저장';
  b.title = need ? '고친 줄을 승인 요청으로 올립니다 — 총괄관리자·부관리자가 승인하면 재고에 반영됩니다(입수수량은 바로 저장).'
                 : (_req.ready ? '고친 줄을 바로 저장합니다(관리자). 직원이 올린 요청은 아래 [⏳ 승인 요청]에서 승인합니다.' : '');
}
function reqFold(){ _req.fold = !_req.fold; reqRender(); }
/* ── 탭 (2026-11-19 사용자 「탭 두 개로 승인요청 · 조정이력 — 기본은 승인요청 탭」) ──
   _tab = 'req'(승인 요청 — 기본) | 'his'(조정 이력). 화면을 열 때마다 승인 요청부터(기억하지 않는다 — 사용자가 정한 기본).
   · 다른 탭을 누르면 그 상자로 바꾸고, 켜진 탭을 다시 누르면 종전의 접기/펼치기(reqFold · hisToggle).
   · 조정 이력은 처음 열 때 한 번 저절로 조회한다(종전엔 [이력조회]를 눌러야 했다).
   · 서버가 승인 요청을 못 주면(옛 서버 · 표 없음 — _req.ready=false) 조정 이력만 보이고 승인 요청 탭은 감춘다.
   · 높이 막대(adjGrip)는 «지금 보이는 탭의 표»를 늘리고 줄인다 — tabWrap()/tabBox(). */
var _tab = 'req';
function tabNow(){ return _req.ready ? _tab : 'his'; }
function tabBox(){ return gel(tabNow() === 'req' ? 'reqBox' : 'histBox'); }
function tabWrap(){ return gel(tabNow() === 'req' ? 'reqWrap' : 'hisWrap'); }
function tabPaint(){
  var rq = gel('reqBox'), hs = gel('histBox'); if (!rq || !hs) return;
  var t = tabNow();
  rq.style.display = (t === 'req') ? '' : 'none';
  hs.style.display = (t === 'his') ? '' : 'none';
  var r2 = gel('reqTab2'); if (r2) r2.style.display = _req.ready ? '' : 'none';
  if (t === 'his' && !hs.classList.contains('off') && gel('hisBody').children.length <= 1 && !tabPaint._his){ tabPaint._his = true; hisLoad(); }   /* 처음 열 때 한 번 */
}
function tabGo(t){
  if (t === tabNow()){ if (t === 'req') reqFold(); else hisToggle(); return; }   /* 켜진 탭 = 접기/펼치기 */
  _tab = t; tabPaint();
  var v = (typeof adjGripGet === 'function') ? adjGripGet() : 0; if (v && typeof adjGripSet === 'function') setTimeout(function(){ adjGripSet(v, true); }, 0);   /* 고른 높이를 새 탭 표에도 */
}
/* ── 내 요청 결과 띠 (2026-11-18 「요청한 직원에게도 승인/반려 결과 알림 표시」) ──
   내가 올린 요청 중 승인·반려됐는데 아직 [확인했습니다]를 안 누른 것. 표(대기 목록)와 따로 늘 보인다 — 「끝난 요청도」를 안 켜도.
   [확인했습니다] = /prod/stockAdjReqSeen.do → 띠와 메뉴 배지가 사라진다(요청 기록은 「끝난 요청도」에 그대로 남는다). */
function reqMineRender(){
  var el = gel('reqMine'); if (!el) return;
  var M = _req.mine || [];
  if (!M.length){ el.style.display = 'none'; el.innerHTML = ''; return; }
  var rej = M.filter(function(q){ return q.statGb !== 'A'; }).length, nIt = 0;
  var body = M.map(function(q){
    /* 그 요청에 든 상품 — 실제로 바뀌는 줄만(증감 0 은 뺀다). 승인 = 그만큼 재고에 반영된 상품 · 반려/취소 = 반영 안 된 상품 */
    var its = reqItems(q).filter(function(it){ return reqAft(it) - nvl(it.befQty) !== 0; });
    var n = Math.max(1, its.length), rs = n > 1 ? ' rowspan="' + n + '"' : ''; nIt += its.length;
    var st = (q.statGb === 'A') ? '✅ 승인' : (q.statGb === 'R' ? '↩ 반려' : '✖ 취소(관리자)');
    var who = esc(q.apprUserNm || q.apprUser) + ' <span class="dim">' + esc(String(q.apprDttm || '').slice(5, 16)) + '</span>';
    var note = (q.statGb === 'A') ? ('재고 반영' + (q.batchNo ? ' <span class="dim" title="조정 이력의 저장묶음 번호">' + esc(q.batchNo) + '</span>' : ''))
             : ((q.apprMemo ? '<span class="why">' + esc(q.apprMemo) + '</span>' : '<span class="dim">(사유 없음)</span>') + ' <span class="dim">· 재고 반영 안 됨</span>');
    function prod(it){
      if (!it) return '<td class="dim">—</td><td class="nm dim">(상품 내역 없음)</td><td class="r">—</td><td class="r">—</td><td class="r">—</td>';
      var bef = nvl(it.befQty), aft = reqAft(it), df = aft - bef;
      return '<td>' + esc(it.prodCd) + '</td><td class="nm">' + esc(it.prodNm || '') + '</td><td class="r">' + bef + '</td><td class="r">' + aft + '</td>'
           + '<td class="r"><span class="diff ' + (df > 0 ? 'up' : 'dn') + '">' + (df > 0 ? '+' : '') + df + '</span></td>';
    }
    var h = '<tr class="rm-first ' + esc(q.statGb) + '"><td class="c"' + rs + '>#' + esc(q.reqSeq) + '</td><td class="c ' + esc(q.statGb) + '"' + rs + '><span class="st">' + st + '</span></td>'
          + prod(its[0])
          + '<td class="wr"' + rs + '>' + esc(q.remark) + '</td><td' + rs + '>' + who + '</td><td class="wr"' + rs + '>' + note + '</td></tr>';
    for (var i = 1; i < its.length; i++) h += '<tr class="' + esc(q.statGb) + '">' + prod(its[i]) + '</tr>';
    return h;
  }).join('');
  el.className = rej ? 'rej' : ''; el.style.display = '';
  el.innerHTML = '<div class="rm-hd"><b>📬 내 요청 결과 ' + M.length + '건</b>'
    + '<span class="dim" style="font-size:12px">' + (nIt ? '상품 ' + nIt + '개 · ' : '') + (rej ? '반려된 요청은 사유를 보고 고쳐서 다시 올려 주세요.' : '승인된 요청은 재고에 반영됐습니다.') + '</span>'
    + '<span style="flex:1"></span><button type="button" class="btn ghost" style="height:26px" onclick="reqSeen();" title="확인하면 이 알림과 메뉴의 배지가 사라집니다(요청 기록은 「끝난 요청도」에서 계속 볼 수 있습니다)">확인했습니다</button></div>'
    + '<div class="rm-grid"><table><thead><tr><th style="width:52px">번호</th><th style="width:96px">결과</th><th style="width:110px">상품코드</th><th>상품명</th>'
    + '<th class="r" style="width:74px">전</th><th class="r" style="width:74px">후</th><th class="r" style="width:74px">증감</th>'
    + '<th>요청 사유</th><th style="width:140px">처리</th><th>반려 사유 · 반영</th></tr></thead><tbody>' + body + '</tbody></table></div>';
}
function reqSeen(){
  fetch(CTX + '/prod/stockAdjReqSeen.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (!d || d.result !== 'OK'){ alertBox('확인 처리하지 못했습니다.<br>' + esc((d && d.message) || ''), '⚠️'); return; }
      _req.mine = []; reqMineRender(); reqLoad(); reqBadge();
    })
    .catch(function(){ alertBox('확인 처리하지 못했습니다.', '⚠️'); });
}
/* 셸 메뉴의 빨간 배지(승인 대기 건수)를 바로 다시 — 요청·승인·반려·취소 직후 30초를 기다리지 않게 (2026-11-18) */
function reqBadge(){ try{ if (parent && parent !== window && typeof parent.konetEmpBadge === 'function') parent.konetEmpBadge(); }catch(e){} }
function reqRender(){
  var box = gel('reqBox'), body = gel('reqBody'); if (!box || !body) return;
  reqRole();
  var L = _req.list, nP = L.filter(function(q){ return q.statGb === 'P'; }).length;
  tabPaint();   /* 보일지는 탭이 정한다 (2026-11-19) — 종전엔 늘 보였다 */
  box.classList.toggle('none', !L.length);
  box.classList.toggle('off', _req.fold);
  gel('reqCnt').textContent = nP ? (' ' + nP + '건 대기') : '';
  gel('reqTab').classList.toggle('pend', nP > 0);
  var c2 = gel('reqCnt2'), t2 = gel('reqTab2'); if (c2) c2.textContent = nP ? (' ' + nP + '건 대기') : ''; if (t2) t2.classList.toggle('pend', nP > 0);   /* 조정 이력 탭을 보는 중에도 대기 건수 */
  gel('reqHint').innerHTML = !L.length ? '승인 대기 중인 요청이 없습니다.'
      : (_req.admin ? (nP ? '<b style="color:#8a5a00" title="요청 때의 「전 → 후」 차이입니다 — 그 뒤 출고가 더 나갔으면 승인 뒤 재고는 그만큼 다릅니다">승인하면 상품마다 <u>증감</u>만큼 재고에 반영됩니다</b>' : '대기 중인 요청이 없습니다.')
                    : '총괄관리자·부관리자가 승인하면 상품마다 증감만큼 재고에 반영됩니다.');
  var ST = { P:'승인 대기', A:'승인', R:'반려', C:'요청 취소' };
  reqMineRender();
  body.innerHTML = L.map(function(q){
    var k = String(q.reqSeq), d = nvl(q.diffSum), mine = (String(q.reqUser) === _req.me), sg = esc(q.statGb);
    var act = '';
    if (q.statGb === 'P'){
      if (_req.admin) act += '<button type="button" class="rq-ok" onclick="reqAct(' + k + ',\'A\')">✔ 승인</button>'
                           + '<button type="button" class="rq-no" onclick="reqAct(' + k + ',\'R\')">✖ 반려</button>';
      if (mine)       act += '<button type="button" class="rq-cx" onclick="reqAct(' + k + ',\'C\')">요청 취소</button>';
      if (!act)       act = '<span class="dim">승인 대기</span>';
    }
    var done = (q.statGb === 'P') ? '<span class="dim">—</span>'
             : esc(q.apprUserNm || q.apprUser) + ' <span class="dim">' + esc(String(q.apprDttm || '').slice(5, 16)) + '</span>'
               + (q.statGb === 'A' && q.batchNo ? ' <span class="dim" title="조정 이력의 저장묶음 번호">' + esc(q.batchNo) + '</span>' : '')
               + (q.apprMemo ? '<div style="color:#b23b3b;font-size:12px">' + esc(q.apprMemo) + '</div>' : '');
    /* 그 요청의 상품 — 실제로 바뀌는 줄만(증감 0 은 뺀다) */
    var its = reqItems(q).filter(function(it){ return reqAft(it) - nvl(it.befQty) !== 0; });
    var n = Math.max(1, its.length), rs = n > 1 ? ' rowspan="' + n + '"' : '';
    function prod(it){
      if (!it) return '<td class="dim">—</td><td class="nm dim">(상품 내역 없음)</td><td class="r">—</td><td class="r">—</td><td class="r">—</td>';
      var bef = nvl(it.befQty), aft = reqAft(it), df = aft - bef;
      return '<td>' + esc(it.prodCd) + '</td><td class="nm">' + esc(it.prodNm || '') + '</td><td class="r">' + bef + '</td><td class="r">' + aft + '</td>'
           + '<td class="r"><span class="diff ' + (df > 0 ? 'up' : 'dn') + '">' + (df > 0 ? '+' : '') + df + '</span></td>';
    }
    var h = '<tr class="rq-h ' + sg + '">'
      + '<td class="c"' + rs + '>#' + k + '</td>'
      + '<td class="c"' + rs + '><span class="rq-st ' + sg + '">' + (ST[q.statGb] || sg) + '</span>'
      +   '<span class="rq-sum" title="이 요청의 상품 수 · 증감 합">' + nvl(q.itemCnt) + '건 · 합 ' + (d > 0 ? '+' : '') + d + '</span></td>'
      + prod(its[0])
      + '<td class="wr"' + rs + '>' + esc(q.remark) + (q.src === 'prodcd' ? ' <span class="dim">(상품코드등록)</span>' : '') + '</td>'
      + '<td' + rs + '>' + esc(fmtDt8(q.baseDt)) + '<span class="rq-sum">' + esc(q.whNm || q.whCd || '(기본창고)') + '</span></td>'
      + '<td' + rs + '>' + esc(q.reqUserNm || q.reqUser) + '<span class="rq-sum">' + esc(String(q.reqDttm || '').slice(5, 16)) + '</span></td>'
      + '<td class="wr"' + rs + '>' + done + '</td>'
      + '<td class="c rq-act"' + rs + '>' + act + '</td></tr>';
    for (var i = 1; i < its.length; i++) h += '<tr class="rq-i ' + sg + '">' + prod(its[i]) + '</tr>';
    return h;
  }).join('') || '<tr><td colspan="12" class="rq-empty">승인 대기 중인 요청이 없습니다.</td></tr>';   /* 비어 있어도 표는 보인다 (2026-11-19) */
}
/* 사유를 받는 작은 창(반려) — 브라우저 prompt 는 쓰지 않는다 */
function reqAsk(title, ph, okText, cb){
  var w = document.createElement('div');
  w.style.cssText = 'position:fixed;inset:0;background:rgba(15,23,32,.35);display:flex;align-items:flex-start;justify-content:center;z-index:100000;padding-top:16vh';
  w.innerHTML = '<div style="background:#fff;width:min(460px,92vw);border-radius:12px;box-shadow:0 12px 40px rgba(0,0,0,.3);overflow:hidden">'
    + '<div style="padding:12px 14px;border-bottom:1px solid #eef1f5;font-weight:800">' + title + '</div>'
    + '<div style="padding:14px"><input type="text" id="_rqWhy" maxlength="190" placeholder="' + esc(ph) + '" style="width:100%;height:34px;border:1px solid #cbd5e1;border-radius:6px;padding:0 9px;font-size:13.5px;box-sizing:border-box;font-family:inherit"></div>'
    + '<div style="padding:10px 14px;border-top:1px solid #eef1f5;display:flex;gap:8px;justify-content:flex-end">'
    + '<button type="button" class="btn ghost" id="_rqNo">닫기</button><button type="button" class="btn" id="_rqOk">' + esc(okText) + '</button></div></div>';
  document.body.appendChild(w);
  var inp = w.querySelector('#_rqWhy'), close = function(){ try{ document.body.removeChild(w); }catch(e){} };
  var ok = function(){ var v = String(inp.value || '').trim(); if (!v){ inp.focus(); inp.style.borderColor = '#b23b3b'; return; } close(); cb(v); };
  w.querySelector('#_rqNo').onclick = close; w.querySelector('#_rqOk').onclick = ok;
  inp.onkeydown = function(e){ if (e.keyCode === 13) ok(); if (e.keyCode === 27) close(); };
  setTimeout(function(){ try{ inp.focus(); }catch(e){} }, 30);
}
function reqAct(k, act){
  var q = _req.list.filter(function(x){ return String(x.reqSeq) === String(k); })[0]; if (!q) return;
  var send = function(memo){
    busy(true, act === 'A' ? '승인하고 재고에 반영하는 중입니다…' : '처리하는 중입니다…');
    fetch(CTX + '/prod/stockAdjReqAct.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
          body: JSON.stringify({ reqSeq: Number(k), act: act, memo: memo || '' }) })
      .then(function(r){ return r.json(); })
      .then(function(d){
        busy(false);
        if (!d || d.result !== 'OK'){ alertBox('처리하지 못했습니다.<br>' + esc((d && d.message) || ''), '⚠️'); reqLoad(); return; }
        toast(act === 'A' ? ('승인했습니다 — 재고 ' + nvl(d.cnt) + '건 반영') : (act === 'R' ? '반려했습니다.' : '요청을 취소했습니다.'));
        reqLoad(); reqBadge();
        if (act === 'A'){ if (ROWS.length) load(); if (!gel('histBox').classList.contains('off') && gel('hisBody').children.length > 1) hisLoad(); }
      })
      .catch(function(e){ busy(false); alertBox('처리하지 못했습니다.<br>' + esc(e && e.message ? e.message : ''), '⚠️'); });
  };
  var d = nvl(q.diffSum), who = esc(q.reqUserNm || q.reqUser);
  var sumTxt = '요청 <b>#' + esc(k) + '</b> · ' + who + ' · 품목 <b>' + nvl(q.itemCnt) + '건</b> · 증감 합 <b>' + (d > 0 ? '+' : '') + d + '</b>';
  if (act === 'R'){ reqAsk('✖ 반려 — 요청 #' + esc(k) + ' (' + who + ')', '반려 사유 (요청한 사람에게 보입니다)', '반려', send); return; }
  if (!window._confirmBox){ send(''); return; }
  window._confirmBox({
    icon: act === 'A' ? '✔️' : '❓',
    msg: '<div style="text-align:left; line-height:1.7">' + sumTxt + '<br>'
       + (act === 'A' ? '<b>승인</b>하면 <b>' + esc(fmtDt8(q.baseDt)) + '</b> 자로 재고에 바로 반영됩니다.'
                        + '<br><span style="font-size:12.5px;color:#5b6b7a">반영되는 것은 요청 때의 증감입니다. 잘못 승인했으면 아래 [조정 이력]에서 그 묶음을 되돌릴 수 있습니다.</span>'
                      : '이 요청을 <b>취소</b>합니다(재고는 그대로).') + '</div>',
    okText: act === 'A' ? '승인' : '요청 취소',
    okColor: act === 'A' ? undefined : 'red',
    onOk: function(){ send(''); }
  });
}

/* ── 하단 조정 이력 ──────────────────────────────────────────────── */
function hisToggle(){
  var box = gel('histBox');
  box.classList.toggle('off');   /* 접어도 탭 색은 그대로 — on 은 이제 «켜진 탭» 뜻이다 (2026-11-19) */
  if (!box.classList.contains('off') && gel('hisBody').children.length <= 1) hisLoad();
}

function hisLoad(){
  var p = new URLSearchParams();
  p.append('dtFrom',  gel('hFrom').value || '');
  p.append('dtTo',    gel('hTo').value   || '');
  p.append('regUser', gel('hUser').value.trim());

  gel('hisBody').innerHTML = '<tr><td colspan="11" class="c dim" style="padding:18px">불러오는 중…</td></tr>';

  busy(true, '조정 이력을 불러오는 중입니다…');   /* ★모래시계 (2026-08-19) */
  fetch(CTX + '/prod/stockAdjHisList.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body: p.toString() })
    .then(function(r){ return r.json(); })
    .then(function(d){
      busy(false);
      _his = (d && d.data) || [];
      hisPaint();
    })
    .catch(function(){ busy(false); alertBox('이력을 불러오지 못했습니다.', '⚠️'); });
}

/* ★이력 그리기 (2026-11-19 사용자 「여기에서 코드로 찾고 재고조정값 취소기능도」) — 읽어 온 이력(_his)을 탭 옆 검색 칸(#hQ)으로 걸러 그린다.
   찾기 : 상품코드·상품명. 띄어 쓰면 낱말이 모두 든 줄. 서버에 다시 묻지 않는다.
   단추 : · 묶음에 줄이 하나뿐이면 [되돌리기] 하나(종전 그대로)
          · 한 번에 여러 품목을 저장한 묶음이면 줄마다 [이 줄만 취소], 그 묶음의 (보이는) 첫 줄에 [묶음 N건 되돌리기]도 —
            ★종전엔 묶음 첫 줄에만 [되돌리기]가 있어, 코드로 찾아 그 품목만 물리고 싶어도 묶음이 통째로 내려갔다.
   묶음의 줄 수는 «거르기 전 전체»에서 센다 — 검색으로 한 줄만 보여도 그 묶음이 몇 건짜리인지 단추에 적힌다 */
var _his = [];
function hisPaint(){
  var q = gel('hQ') ? gel('hQ').value.trim().toLowerCase() : '', toks = q ? q.split(/\s+/) : [];
  var size = {}; _his.forEach(function(h){ size[h.batchNo] = (size[h.batchNo] || 0) + 1; });
  var rows = toks.length ? _his.filter(function(h){ var t = (String(h.prodCd || '') + ' ' + String(h.prodNm || '')).toLowerCase(); return toks.every(function(k){ return t.indexOf(k) >= 0; }); }) : _his;
  if (gel('hQCnt')) gel('hQCnt').textContent = toks.length ? (rows.length + '건 / 전체 ' + _his.length + '건') : '';
  if (!rows.length){
    gel('hisBody').innerHTML = '<tr><td colspan="11" class="c dim" style="padding:18px">' + (_his.length ? '「' + esc(q) + '」에 맞는 조정 이력이 없습니다 — 기간을 넓혀 [이력조회] 해 보세요.' : '조정 이력이 없습니다.') + '</td></tr>';
    return;
  }
  var prev = null;
  gel('hisBody').innerHTML = rows.map(function(h){
    var head = (h.batchNo !== prev); prev = h.batchNo;
    var diff = nvl(h.diffQty), n = size[h.batchNo] || 1, bt = '';
    if (n <= 1) bt = '<button type="button" class="undo" onclick="hisCancel(\'' + esc(h.batchNo) + '\')">되돌리기</button>';
    else bt = '<button type="button" class="undo" onclick="hisCancelOne(' + Number(h.adjSeq) + ')" title="이 상품의 조정만 취소합니다 — 같은 묶음의 다른 줄은 그대로">이 줄만 취소</button>'
            + (head ? ' <button type="button" class="undo" onclick="hisCancel(\'' + esc(h.batchNo) + '\')" title="이 저장으로 만든 조정 ' + n + '건을 모두 되돌립니다">묶음 ' + n + '건</button>' : '');
    return '<tr>'
      + '<td>' + (head ? esc(h.batchNo) : '<span class="dim">〃</span>') + '</td>'
      + '<td>' + esc(h.baseDt) + '</td>'
      + '<td>' + esc(h.prodCd) + '</td>'
      + '<td>' + esc(h.prodNm) + '</td>'
      + '<td class="r">' + nvl(h.befQty) + '</td>'
      + '<td class="r">' + nvl(h.aftQty) + '</td>'
      + '<td class="r"><span class="diff ' + (diff > 0 ? 'up' : 'dn') + '">' + (diff > 0 ? '+' : '') + diff + '</span></td>'
      + '<td>' + esc(h.remark) + '</td>'
      /* 등록자 = 이름(아이디는 툴팁) · 빈 값 = 로그인이 끊긴 채 저장된 옛 조정 (2026-09-14) */
      + '<td title="' + esc(h.regUser || '로그인이 끊긴 채 저장됨') + '">' + (h.regUser ? esc(h.regUserNm || h.regUser) : '<span class="dim">(기록 없음)</span>') + '</td>'
      + '<td>' + esc(h.regDttm) + '</td>'
      + '<td class="c" style="white-space:nowrap">' + bt + '</td>'
      + '</tr>';
  }).join('');
}

/* 한 줄만 취소 (2026-11-19) — 그 상품의 조정 한 줄과 짝인 원장 조정행만 내린다. 같은 묶음의 다른 줄은 그대로 */
function hisCancelOne(adjSeq){
  var h = null; _his.forEach(function(x){ if (Number(x.adjSeq) === Number(adjSeq)) h = x; });
  if (!h) return;
  var diff = nvl(h.diffQty);
  var go = function(){
    fetch(CTX + '/prod/stockAdjCancel.do', {
        method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
        credentials:'same-origin', body: 'adjSeq=' + encodeURIComponent(adjSeq) })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || d.result !== 'OK'){ alertBox('취소하지 못했습니다.<br>' + esc((d && d.message) || ''), '⚠️'); return; }
        toast(esc(h.prodCd) + ' 조정 1건을 취소했습니다.');
        hisLoad();
        if (ROWS.length) load();      /* 위 목록도 바뀐 재고로 다시 그린다 */
      })
      .catch(function(){ alertBox('취소하지 못했습니다.', '⚠️'); });
  };
  if (window._confirmBox){
    window._confirmBox({
      icon: '⚠️',
      msg: '<div style="text-align:left; line-height:1.7">이 상품의 조정 <b>한 줄만</b> 취소합니다.<br>'
         + '<b>' + esc(h.prodCd) + '</b> ' + esc(h.prodNm) + '<br>'
         + '조정 : ' + nvl(h.befQty) + ' → ' + nvl(h.aftQty) + ' (<b>' + (diff > 0 ? '+' : '') + diff + '</b>) · 기준일자 ' + esc(h.baseDt) + '<br>'
         + '<span style="font-size:12.5px;color:#3d4d5c">이 조정행만 내려가 재고가 <b>' + (diff > 0 ? '-' : '+') + Math.abs(diff) + '</b> 만큼 돌아갑니다. 같은 묶음의 다른 줄은 그대로입니다.</span></div>',
      okText: '이 줄만 취소',
      onOk: go
    });
  } else if (confirm('이 상품의 조정 한 줄만 취소할까요?')) go();
}

/* 묶음 되돌리기 — 이력과 짝인 원장 조정행을 함께 내린다 */
function hisCancel(batchNo){
  var go = function(){
    fetch(CTX + '/prod/stockAdjCancel.do', {
        method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
        credentials:'same-origin', body: 'batchNo=' + encodeURIComponent(batchNo) })
      .then(function(r){ return r.json(); })
      .then(function(d){
        if (!d || d.result !== 'OK'){
          alertBox('되돌리지 못했습니다.<br>' + esc((d && d.message) || ''), '⚠️');
          return;
        }
        toast(d.cnt + '건 되돌렸습니다.');
        hisLoad();
        if (ROWS.length) load();      /* 위 목록도 바뀐 재고로 다시 그린다 */
      })
      .catch(function(){ alertBox('되돌리지 못했습니다.', '⚠️'); });
  };

  if (window._confirmBox){
    window._confirmBox({
      icon: '⚠️',
      msg: '<div style="text-align:left; line-height:1.7">'
         + '<b>' + esc(batchNo) + '</b> 묶음을 되돌립니다.<br>'
         + '이 저장으로 만들어진 <b>조정행' + (function(){ var n = 0; _his.forEach(function(x){ if (x.batchNo === batchNo) n++; }); return n > 1 ? ' ' + n + '건' : ''; })() + '이 모두 내려갑니다.</b></div>',
      okText: '되돌리기',
      onOk: go
    });
  } else if (confirm('되돌릴까요?')) go();
}

/* ── 진입하면 바로 목록을 읽는다 (2026-08-20 요청 「리스트조회 버튼 실행 없이」) ──────
   종전에는 [리스트조회]를 눌러야 읽었다. 그렇게 둔 이유가 **조회가 느려서**였는데
   ①원장 집계 인덱스(IX_STOCK_LEDGER_AGG) 를 운영 DB에 넣었고
   ②화면에 그리는 줄을 LIST_MAX 로 끊어 5,800개 입력칸을 한 번에 그리던 것을 없앴다.
   두 가지로 가벼워져 자동으로 돌려도 된다.
   ★[리스트조회] 버튼은 그대로 둔다 — 읽은 뒤에는 화면에서 거르는 용도(applyFilter)로 계속 쓴다.
   ★기준일자 기본값(위 IIFE)이 먼저 들어간 뒤라야 그 날짜로 읽는다 — 순서를 바꾸지 말 것. */
/* ★창고 목록을 먼저 채우고(기본창고 선택) 목록을 읽는다 (2026-09-16 P3). 못 받아오면 창고 없이(전 창고 합계) — 저장은 위 가드가 막는다 */
function adjWhInit(){
  fetch(CTX + '/prod/whList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'useOnly=Y' })
    .then(function(r){ return r.json(); })
    .then(function(j){ var e=gel('adjWh'), l=(j&&j.data)||[];
      e.innerHTML='<option value="">(전 창고 합계 — 조회만)</option>'+l.map(function(w){ return '<option value="'+w.whCd+'">'+w.whNm+'</option>'; }).join('');
      var d=l.filter(function(w){ return w.defaultYn==='Y'; })[0]||l[0]; if(d) e.value=d.whCd; })
    .catch(function(){})
    .then(function(){ load(); reqLoad(); });   /* 승인 요청 목록 · 역할(단추 이름) — 2026-11-18 */
}
/* ── 목록 ↔ 조정 이력 높이 막대 (2026-11-18 사용자 「막대 표시로 줄이고 늘리고 기능」) ─────────────────
   목록 표(#adjGrid) 바로 밑 막대. 목록은 남는 높이를 전부 쓰므로(flex:1) 막대는 [조정 이력] 표(#hisWrap) 높이를 바꾼다.
   · 아래로 끌면 목록이 늘고(이력이 줄고) 위로 끌면 목록이 준다 · [▲ 줄이기][▼ 늘리기] = 120px · 더블클릭 = 처음 높이(CSS 24vh~46vh)
   · 높이(이력 표 px)는 localStorage('konetAdjHisH') — 다음에 들어와도 그대로
   · 목록은 110px 아래로, 이력은 60px 아래로 안 줄어든다. 이력이 접혀 있으면(📜 탭) 막대를 건드릴 때 펼친다. */
var ADJ_GRIP_K = 'konetAdjHisH', ADJ_GRIP_STEP = 120, ADJ_LIST_MIN = 110, ADJ_HIS_MIN = 60;
function adjGripGet(){ try{ var v = parseInt(localStorage.getItem(ADJ_GRIP_K), 10); return v > 0 ? v : 0; }catch(e){ return 0; } }
function adjGripPut(v){ try{ if (v > 0) localStorage.setItem(ADJ_GRIP_K, String(Math.round(v))); else localStorage.removeItem(ADJ_GRIP_K); }catch(e){} }
/* 이력 표 높이를 h 로 건다. 목록이 ADJ_LIST_MIN 아래로 눌리거나 화면 밖으로 넘치면 그만큼 되돌린다. 돌려주는 값 = 실제로 건 높이 */
function adjGripSet(h, auto){
  var w = tabWrap(), g = gel('adjGrid'), wrap = g && g.parentNode; if (!w || !g) return 0;   /* 지금 보이는 탭의 표 (2026-11-19) */
  if (w.offsetParent === null) return 0;   /* 탭을 접어 표가 안 보이면 건드리지 않는다 */
  /* auto = 저장값을 저절로 다시 거는 호출(창 크기·탭 바꿈·처음). 승인 요청이 비어 있으면 빈 표를 키우지 않고 제 높이(머리줄 + 안내 한 줄)로 둔다 —
     손으로 막대를 움직인 호출(auto 없음)은 빈 표라도 그대로 따른다 (2026-11-19 「이 상태에서 작동 안 함」) */
  if (auto && tabNow() === 'req' && !(_req.list && _req.list.length)){ w.style.removeProperty('height'); w.style.removeProperty('min-height'); w.style.removeProperty('max-height'); return 0; }
  function put(v){ w.style.setProperty('height', v + 'px', 'important'); w.style.setProperty('min-height', '0', 'important'); w.style.setProperty('max-height', 'none', 'important'); }
  h = Math.max(ADJ_HIS_MIN, Math.round(h)); put(h);
  var lack = Math.max(0, ADJ_LIST_MIN - g.clientHeight) + Math.max(0, wrap.scrollHeight - wrap.clientHeight);
  if (lack > 0){ h = Math.max(ADJ_HIS_MIN, h - lack); put(h); }
  return h;
}
function adjGripReset(){ ['hisWrap','reqWrap'].forEach(function(id){ var w = gel(id); if (!w) return; w.style.removeProperty('height'); w.style.removeProperty('min-height'); w.style.removeProperty('max-height'); }); adjGripPut(0); }   /* 두 탭 표 모두 처음 높이로 */
(function(){
  var g = gel('adjGrid'); if (!g) return;
  var bar = document.createElement('div'); bar.className = 'agrip'; bar.id = 'adjGrip';
  bar.title = '잡고 아래로 끌면 목록이 늘고(아래 탭 표가 줄고), 위로 끌면 목록이 줄어듭니다 · 더블클릭 = 처음 높이';
  bar.innerHTML = '<i></i><span class="bt"><b data-d="-1" title="목록을 줄이고 조정 이력을 늘립니다">▲ 줄이기</b><b data-d="1" title="목록을 늘리고 조정 이력을 줄입니다">▼ 늘리기</b></span>';
  g.parentNode.insertBefore(bar, g.nextSibling);
  var drag = false;
  function hisOff(){ var b = tabBox(); return !!(b && b.classList.contains('off')); }       /* 지금 보이는 탭이 접혀 있나 */
  function hisH(){ var w = tabWrap(); return w ? w.offsetHeight : 0; }
  function hisToggle(){ if (tabNow() === 'req') reqFold(); else window.hisToggle(); }           /* 막대가 펼칠 때 — 보이는 탭 것을 */
  bar.addEventListener('mousedown', function(e){
    if (e.button !== 0 || (e.target.closest && e.target.closest('b'))) return;
    e.preventDefault();
    if (hisOff()) hisToggle();                      /* 접힌 이력은 막대를 건드리면 펼친다 */
    var sy = e.clientY, h0 = hisH(), last = 0, moved = false;
    drag = true; bar.classList.add('on'); document.body.style.cursor = 'ns-resize';
    function mv(ev){ if (!moved && Math.abs(ev.clientY - sy) < 2) return; moved = true; last = adjGripSet(h0 - (ev.clientY - sy)); }
    function up(){ document.removeEventListener('mousemove', mv); document.removeEventListener('mouseup', up);
                   bar.classList.remove('on'); document.body.style.cursor = ''; if (moved) adjGripPut(last); drag = false; }   /* 안 움직였으면 저장하지 않는다 */
    document.addEventListener('mousemove', mv); document.addEventListener('mouseup', up);
  });
  bar.addEventListener('click', function(e){
    var b = e.target.closest && e.target.closest('b[data-d]'); if (!b) return;
    var d = parseInt(b.getAttribute('data-d'), 10);
    if (hisOff()){ if (d < 0) hisToggle(); return; }   /* 접혀 있으면 목록이 이미 가장 크다 — [줄이기]만 이력을 펼친다 */
    adjGripPut(adjGripSet(hisH() - d * ADJ_GRIP_STEP));
  });
  bar.addEventListener('dblclick', function(e){ if (e.target.closest && e.target.closest('b')) return; adjGripReset(); });
  window.addEventListener('resize', function(){ var v = adjGripGet(); if (v) adjGripSet(v, true); });   /* 창이 작아지면 넘친 만큼만 줄여 보여 준다(저장값은 그대로) */
  var s0 = adjGripGet(); if (s0) setTimeout(function(){ adjGripSet(s0, true); }, 0);
  /* ★목록 높이가 «다른 까닭»으로 바뀌면(승인 요청 상자가 나타남 · 조회줄이 두 줄로 접힘 · 이력 접기) 고른 높이를 다시 맞춘다.
       화면을 열 때 승인 요청 상자는 목록보다 늦게 나타난다 — 그때 한 번만 맞추면 목록이 최소 높이 밑으로 눌린 채 남는다(시연 화면 실측 87px).
       끄는 동안에는 쉬고(저장값이 아직 옛 값이라 손과 싸운다), 표 크기를 바꾸는 일이라 다음 틱으로 미룬다. */
  try{ var pend = false;
       new ResizeObserver(function(){ if (drag || pend) return; pend = true;
         setTimeout(function(){ pend = false; var v = adjGripGet(); if (v && !drag) adjGripSet(v, true); }, 0); }).observe(g);
  }catch(e){}
})();

adjWhInit();
</script>
</body>
</html>
