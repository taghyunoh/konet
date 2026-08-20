<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- 알림·확인은 프로젝트 공통 표준(ui-message.js) — Swal 신규 사용 금지 --%>
<%-- ★날짜 칸에 [◀][▶][오늘] 을 자동으로 붙인다 (2026-08-17 요청) — 화면 수정 0.
     브라우저 기본 달력의 ↑↓ 는 앞/뒤가 안 읽혀 엉뚱한 달로 넘어가는 일이 잦았다.
     빼려면 그 칸에 data-nonav="1" --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- ★[2026-08-20 요청 「글자체도」] 요즘 한국 업무화면에서 쓰는 **Pretendard**.
     맑은 고딕보다 획이 고르고 숫자 폭이 일정해 표에서 자릿수가 맞는다.
     ⚠외부 CDN 이라 못 받으면 **아래 font-family 의 맑은 고딕으로 조용히 내려간다**(화면이 깨지지 않는다).
       사내망에서 막히면 이 <link> 한 줄만 빼면 종전 글자체로 돌아간다. --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<title>상품코드 등록 (TBL_PROD_MST)</title>
<%-- 상품코드 등록 (2026-08-01 신설)
     ★같은 마스터(TBL_PROD_MST)를 보는 '등록 전용' 화면이다 — 상품(품목)관리와 데이터·엔드포인트가 같다.
       상품(품목)관리는 하단 이력/재고 4탭이 붙은 무거운 화면이라, 코드만 빠르게 넣고 훑는 용도로 이 화면을 나눴다.
     ★서식은 매입/매출 거래처 관리(vendorMng.jsp)와 동일 : 추가·수정·삭제 버튼을 상단 공통 줄에 두고,
       그리드에는 행별 [수정]·[삭제] 버튼을 두지 않는다(행 클릭 = 선택, 더블클릭 = 수정). --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  <%-- 글자체 : Pretendard → (못 받으면) 맑은 고딕. 숫자는 표에서 자릿수가 맞도록 폭을 고정한다. --%>
  body{ font-family:'Pretendard Variable',Pretendard,'맑은 고딕','Malgun Gothic',system-ui,sans-serif;
        color:#1f2a37; background:var(--bg); font-size:14px; -webkit-font-smoothing:antialiased; }
  input, select, textarea, button, table{ font-family:inherit; }
  /* ★목록을 화면 아래까지 채운다(2026-08-01 요청) — [고정 머리(제목·검색줄·탭)] + [남는 공간 전부 = 목록] + [하단 페이지줄] 3층.
     페이지 안 행이 화면보다 많으면 목록 칸 안에서만 스크롤된다(머리글은 sticky 로 붙어 있음).
     종전에는 페이지 전체가 흐르는 구조라 목록 아래가 통째로 비어 보였다. */
  html,body{ height:100%; overflow:hidden; }
  /* 위 여백을 줄여 목록을 조금 올렸다(2026-08-04 요청) — 설명줄을 뺀 만큼 표가 더 보인다 */
  .wrap{ padding:8px 11px 10px; height:100%; display:flex; flex-direction:column; min-height:0; }
  .wrap > h2, .wrap > .sub, .wrap > .bar, .wrap > .tabs, .wrap > .pager{ flex:0 0 auto; }
  h2{ margin:0 0 2px; font-size:20px; }
  .sub{ color:#9aa7b3; font-size:12px; margin-bottom:8px; }
  /* ★[2026-08-18 요청] 검색·단추 줄과 아래 탭 줄 사이 **간격을 준다**(12 → 18 → 24px) —
       두 줄이 붙어 있어 한 덩어리로 읽혔다. 여기 한 값만 고치면 된다. */
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:24px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:280px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:8px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:500; color:#37475a; }
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
  /* ★[2026-08-20 「다듬기」] 화면 규칙에 맞춘다(칸 순서·조작은 그대로) :
       ① 값은 보통 굵기 — 표 전체가 700 이라 어디가 중요한지 구분이 안 됐다(코드·금액만 500).
       ② 숫자는 자릿수 고정(tabular-nums) — 세로로 자릿수가 맞아 눈으로 검산된다.
       ③ 머리글은 한 겹 선으로 — 안쪽 그림자(inset)로 굵은 밑줄을 그리던 것을 뗀다. */
  <%-- ★★[2026-08-20 사용자 지정 콘셉] **그리드는 세로선이 있는 격자** —
       머리글 가운데 정렬 · 칸마다 세로 구분선 · 금액은 오른쪽 + 자릿수 고정 · 고른 줄은 옅게 강조.
       (앞서 「표는 가로선만」으로 뒀던 것은 이 결정으로 대체된다.) --%>
  table{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  thead th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; letter-spacing:.02em;
            border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1;
            padding:9px 10px; text-align:center; position:sticky; top:0; z-index:1; }
  thead th:last-child{ border-right:none; }
  thead th.r{ text-align:right; }
  tbody td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5;
            padding:7px 10px; vertical-align:middle; text-align:center; }
  tbody td:last-child{ border-right:none; }
  tbody td.num, thead th.r{ font-variant-numeric:tabular-nums; }
  /* 긴 글자는 왼쪽 — 가운데 정렬은 짧은 값(코드·수량·상태)에만 어울린다 */
  tbody td.nm{ text-align:left; }
  tbody td.code{ font-weight:500; }
  tbody tr:hover td{ background:#f3f8f6; }
  tbody tr{ cursor:pointer; }
  tbody tr.sel td{ background:#dcefe9 !important; }
  /* ★[2026-08-19 요청] 거래중지된 상품은 **줄 전체를 빨간색**으로 — 오른쪽 끝 [중지일] 칸과
     코드 칸 배지만으로는 긴 목록을 스크롤하며 훑을 때 눈에 안 들어왔다.
     ★칸에 직접 박은 색(거래처명 · 중지일 등)을 이기려고 `!important` 를 쓴다.
       배지(과세·매칭·중지·서브)는 제 색을 그대로 둔다 — 전부 빨간색이 되면 오히려 구분이 안 된다. */
  tbody tr.stopped td{ background:#fff4f3; color:#c0392b !important; }
  tbody tr.stopped:hover td{ background:#ffe7e3; }
  tbody tr.stopped.sel td{ background:#fbd5cf !important; }
  td.code{ font-family:Consolas,monospace; }
  td.nm{ white-space:normal; min-width:220px; max-width:340px; }
  /* ★[2026-08-17 요청 「거래처명이 제조사에 너무 붙어 있음 — 좌측으로 2.5cm」]
       원인 : `table{width:100%}` 인데 폭을 정해 둔 칸이 상품명뿐이라 ***남는 폭을 규격이 다 먹었다.***
              그래서 규격 칸이 넓게 벌어지고 거래처명이 오른쪽 끝(제조사 옆)까지 밀렸다.
     ⇒ **규격에 상한을 주고**(3번째 칸) 거래처명에 제 폭을 준다(4번째) — 남는 폭은 상품명이 먹는다.
     ★2.5cm ≒ 95px : 규격이 먹던 여백이 그만큼 줄어 거래처명이 왼쪽으로 당겨진다.
     ⚠칸 번호(nth-child)로 지정한다 — **칸 순서를 바꾸면 이 숫자도 함께 고쳐야 한다.**
       지금 순서 : 1코드 2상품명 3규격 4거래처명 5제조사 … */
  /* ★규격 폭이 곧 **거래처명·제조사·유형 세 칸의 시작 위치**다 — 규격을 넓히면 그만큼 오른쪽으로 밀린다.
       150 → 200 → 260 → **300px** (사용자가 보면서 조금씩 오른쪽으로 옮긴 값이다).
       ⚠더 미세하게 조절할 곳은 이 한 줄이다(min/max 를 같이 올리거나 내린다). */
    /* ★[2026-08-18] 규격이 길면 **거래처명 칸으로 삐져나왔다**(사용자 지적) —
       `table{white-space:nowrap}` 이라 글자가 칸 밖으로 그대로 흘러 옆 칸 글자와 겹쳤다.
       ⇒ 넘치면 **`…` 으로 자른다**(overflow:hidden + text-overflow:ellipsis).
       ★잘린 전체 값은 **마우스를 올리면** 보인다(행을 만들 때 title 을 함께 넣는다).
       ⚠td 에서 ellipsis 가 듣게 하려면 **max-width 가 반드시 있어야 한다** — 위 max-width 가 그 몫이다. */
  .card table th:nth-child(3), .card table td:nth-child(3){ min-width:300px; max-width:320px;
       overflow:hidden; text-overflow:ellipsis; }  /* 규격 */
  /* ★[2026-08-20] 거래처명 칸 삭제로 nth-child(4) 폭 규칙(2026-08-18 「제조사·유형 우측으로」 180px)도
       걷어냈다 — 남겨 두면 이제 4번째가 된 제조사가 애꿎게 넓어진다. */
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
  /* ★폭 820 → 960 · 위 여백 4vh → 2vh (2026-08-20 요청 「모달 하단 확대 잘보이게」) —
     아래 재고수량·조정 이력까지 스크롤 없이(또는 조금만 내려서) 한눈에 들어오게 */
  #ov .box{ background:#fff; width:min(960px,94vw); margin-top:2vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:95vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  <%-- ★★[2026-08-20 사용자 지정 콘셉] **입력은 「표 형식」** — 라벨이 왼쪽 회색 칸, 값이 오른쪽 칸인 격자.
       (거래처 사업자등록 화면과 같은 모양. 앞서 넣었던 '칸 위 작은 라벨' 은 이 결정으로 대체된다.)
       ★HTML 은 그대로다 — `.fld` 한 덩이(라벨+입력)를 **두 칸짜리 격자**로 바꿔 표처럼 보이게 한 것뿐이다.
         바깥 `.mb` 가 2열이라 한 줄에 [라벨|값][라벨|값] 네 칸이 선다.
       ★선은 겹치지 않게 : 바깥이 위·왼쪽, 각 칸이 아래·오른쪽을 그린다(표 테두리 한 겹). --%>
  <%-- ★[2026-08-20 요청 「좌우 조금만 간격유지」] 표를 창에 딱 붙이지 않는다 —
       붙여 놨더니 왼쪽 라벨 글자가 창 테두리에 닿고 오른쪽 [유사 상품] 단추가 밖으로 밀려 잘렸다.
       바깥 여백(14/16)을 되살리고, 값 칸 안에도 숨 쉴 자리(4/8)를 준다. --%>
  #ov .mb{ padding:14px 16px; overflow:auto; display:grid; grid-template-columns:1fr 1fr; gap:0;
           border-top:none; }
  #ov .fld{ display:grid; grid-template-columns:132px minmax(0,1fr); align-items:center;
            border-top:1px solid var(--bd); border-left:1px solid var(--bd);
            border-right:1px solid var(--bd); border-bottom:1px solid var(--bd);
            margin:0 0 -1px -1px;                          /* 이웃한 칸과 선을 1px 겹쳐 두 겹으로 보이지 않게 */
            min-height:44px; min-width:0; }
  <%-- 값 칸 안쪽 여백 — 입력칸이 셀 선에 닿지 않게. 상품명처럼 안에 묶음(div)이 든 칸도 같이. --%>
  #ov .fld > input, #ov .fld > select, #ov .fld > div{ margin:4px 8px; min-width:0; }
  <%-- ⚠예외 — 「최근 등록 코드」 안내줄은 라벨이 없는 한 줄 띠다. 표 칸으로 만들면 글이 눌린다. --%>
  #ov .fld.lastcd{ display:flex; flex-direction:row; align-items:center; flex-wrap:wrap;
                   border:none; margin:0; min-height:0; }
  /* ♻ 삭제 목록 모달 (2026-08-17) — #ov 와 같은 골격, 폭만 넓다(표를 본다) */
  #rc{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:60; align-items:flex-start; justify-content:center; }
  #rc.on{ display:flex; }
  #rc .box{ background:#fff; width:min(1320px,97vw); margin-top:4vh; border-radius:12px;
            box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:90vh; display:flex; flex-direction:column; }
  #rc .mh{ background:linear-gradient(135deg,#6b7a89,#48566a); color:#fff; padding:13px 18px;
           border-radius:12px 12px 0 0; display:flex; gap:10px; align-items:center; }
  #rc .mh b{ font-size:16px; } #rc .mh .x{ margin-left:auto; background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #rc .mb{ padding:12px 16px; overflow:auto; }
  /* ★table-layout:fixed 로 못 박는다 (2026-08-17) — 안 하면 상품명이 길어 표가 모달보다 넓어지고
     ***오른쪽 [되살리기] 칸이 잘린다.*** 긴 글자는 줄임표로 접고, 전체 내용은 title 로 본다. */
  #rc table{ width:100%; border-collapse:collapse; font-size:13px; table-layout:fixed; }
  #rc th{ background:#eef3f6; color:#3d4d5c; padding:7px 8px; text-align:left; position:sticky; top:0; }
  #rc td{ padding:6px 8px; border-bottom:1px solid #eef1f4;
          white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  #rc td.num{ text-align:right; }
  #rc .empty{ text-align:center; color:#8a97a3; padding:26px 0; }
  /* ⛔ 거래중지 입력창 (2026-08-17) — prompt() 대신 프로젝트 창 모양으로. **중지일만** 받는다 */
  #sp{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:70; align-items:flex-start; justify-content:center; }
  #sp.on{ display:flex; }
  #sp .box{ background:#fff; width:min(460px,94vw); margin-top:12vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); }
  #sp .mh{ background:linear-gradient(135deg,#c0392b,#96281b); color:#fff; padding:12px 16px; border-radius:12px 12px 0 0; font-weight:700; }
  #sp .mb{ padding:16px; }
  #sp .mb input{ height:36px; width:100%; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:14px; }
  #sp .mf{ padding:0 16px 14px; display:flex; gap:8px; justify-content:flex-end; }
  #ov .fld.full{ grid-column:1 / -1; }
  <%-- ★[2026-08-20 「다듬기」] 라벨에서 **파란 알약을 걷어냈다** — 칸 위 작은 회색 글씨로 통일.
       왜 : 알약이 값보다 눈에 먼저 들어와 정작 읽어야 할 내용이 뒤로 밀렸고, 고정폭(104px)이
            칸마다 다른 여백을 만들어 줄이 어긋나 보였다(2026-08-20 「규칙이 없다」 지적).
       ⚠라벨은 자리만 바뀌지 않았다 — 종전에도 칸 위였다. 모양만 바꾼 것이라 조작은 그대로다.
       (2026-08-04 「진하게·가운데」 는 이 결정으로 대체된다.) --%>
  <%-- 라벨 = 왼쪽 회색 칸(표의 머리칸). 값 칸과 선으로 나뉜다. --%>
  #ov label{ font-size:13px; font-weight:500; color:#37475a; background:#f6f8fa;
             border-right:1px solid var(--bd); align-self:stretch;
             display:flex; align-items:center; padding:0 12px; white-space:nowrap; margin:0; }
  <%-- 입력칸 : 높이 38 · 모서리 8 · 테두리 한 겹 · 초점은 teal 링 하나로(화면 규칙) --%>
  #ov input, #ov select{ height:38px; border:1px solid #cfd9e2; border-radius:8px; padding:0 11px;
             font-size:14px; font-family:inherit; color:#1f2a37; background:#fff;
             transition:border-color .12s, box-shadow .12s; }
  #ov input:focus, #ov select:focus{ outline:none; border-color:var(--teal); box-shadow:0 0 0 3px rgba(19,122,108,.14); }
  #ov input[readonly]{ background:#f2f5f7; color:#5f7381; }
  /* ★[2026-08-17 요청 「과세 이쪽으로 옮겨」] select 에 폭이 없으면 **글자만큼만 좁게** 나와
     오른쪽 칸의 왼쪽에 붙어 보였다 — 다른 입력칸처럼 칸을 채워야 한다.
     ⚠[2026-08-20 수정] 그런데 `width:100%` 는 **표 형식으로 바꾼 뒤 셀 밖으로 삐져나온다** —
       칸을 꽉 채운 폭에 좌우 여백(8px)이 더해져 화살표가 창 테두리에 걸렸다(사용자 지적).
       격자 칸에서는 폭을 주지 않아도 **저절로 칸을 채운다**(stretch) ⇒ auto 로 되돌린다.
       ***표 안의 입력칸에는 width:100% 를 쓰지 말 것.*** */
  #ov select{ width:auto; }
  /* 추가 창 안의 '거래처 코드' 묶음 — 상품 항목과 섞이지 않게 옅은 칸으로 감싼다 */
  #ov .sub{ grid-column:1 / -1; border:1px dashed #b9c9d6; border-radius:8px; padding:10px 12px;
            background:#f7fbfd; display:grid; grid-template-columns:1fr 1fr; gap:10px 14px; }
  #ov .sub .cap{ grid-column:1 / -1; font-size:12.5px; color:#5a6b7a; font-weight:700; }
  /* ── 재고수량 (수정 창에만) — 재고 일괄조정(stockAdj.jsp)의 한 줄 판 ──
     칸 배열·정렬을 그 화면과 똑같이 둔다(BOX재고·EA재고·합계재고 → 수정BOX·수정EA → 증감, 숫자는 오른쪽).
     두 화면을 오가며 재고를 만지는 사람이 같은 눈으로 읽게 하려는 것. */
  /* ★한 단계씩 키움 (2026-08-20 요청 「하단 확대 잘보이게」) — 글자 13→14.5px · 칸 여백·입력 높이 확대 */
  #ov .stk{ grid-column:1 / -1; border:1px dashed #b9c9d6; border-radius:8px; padding:12px 14px; background:#f7fbfd; }
  #ov .stk .cap{ font-size:13.5px; color:#5a6b7a; font-weight:700; margin-bottom:9px; }
  #ov .stk table{ width:100%; border-collapse:collapse; font-size:14.5px; }
  #ov .stk th{ background:#eaf2f0; border-bottom:1px solid #cfe0da; padding:8px 9px; font-weight:600; color:#125a4e; text-align:center; white-space:nowrap; font-size:12.5px; }
  #ov .stk td{ border-bottom:1px solid #eef1f5; padding:7px 9px; background:#fff; font-variant-numeric:tabular-nums; }
  #ov .stk td.r{ text-align:right; }
  #ov .stk td.c{ text-align:center; }
  #ov .stk td.neg{ color:#b23b3b; font-weight:500; }        /* 음수 재고 = 입고 누락 신호 (stockAdj 와 동일) */
  #ov .stk input{ width:104px; height:34px; text-align:right; font-variant-numeric:tabular-nums; font-size:14.5px; }
  #ov .stk .diff{ font-weight:600; }
  #ov .stk .diff.up{ color:#1f7a4b; }
  #ov .stk .diff.dn{ color:#b23b3b; }
  #ov .stk .rmk{ display:flex; gap:8px; align-items:center; margin-top:9px; }
  #ov .stk .rmk input{ flex:1 1 auto; width:auto; height:32px; text-align:left; }
  #ov .stk .dim{ color:#9aa7b3; }
  /* 이 상품의 조정 이력 — stockAdj 하단 [조정 이력]의 축소판(이 상품 것만) */
  #ov .stk .his{ margin-top:11px; border-top:1px dashed #b9c9d6; padding-top:9px; }
  #ov .stk .his .hcap{ font-size:13.5px; color:#5a6b7a; font-weight:700; margin-bottom:6px; }
  #ov .stk .hgrid{ max-height:220px; overflow:auto; }
  #ov .stk .his table{ font-size:13.5px; }
  #ov .stk .his th{ position:sticky; top:0; z-index:1; }
  #ov .stk .undo{ height:24px; width:auto; border:1px solid #b23b3b; background:#fff; color:#b23b3b;
                  border-radius:4px; padding:0 9px; font-size:12.5px; font-weight:700; cursor:pointer; text-align:center; }
  /* 규격·제조사명은 한 단계 크게 (2026-08-04 요청) — 값을 눈으로 대조하며 고르는 칸이라 */
  <%-- ★[2026-08-20 「다듬기」] 높이 예외(36px)를 없앴다 — 한 줄에 38·36 이 섞여 칸 아래선이 어긋났다.
       글자만 한 단계 크게 두던 뜻(값을 눈으로 대조하는 칸)은 그대로 살린다. --%>
  #ov #f_spec, #ov #f_maker{ font-size:15px; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
  /* 취소·저장은 가로를 넉넉히 (2026-08-04 요청) — 창을 닫는 마지막 손동작이라 누르기 쉬워야 한다 */
  #ov .mf .btn{ min-width:104px; padding:0 22px; }
  /* 「최종 코드」 안내 — 상품코드 칸 바로 아래 한 줄 (2026-08-12 요청). 추가할 때만 보인다.
     상품(품목)관리·매입/매출 거래처 화면과 같은 모양 — 세 화면을 오갈 때 눈이 자리를 다시 잡지 않게. */
  #ov .lastcd{ flex-direction:row; align-items:center; gap:7px; flex-wrap:wrap;
               background:#f2f8f6; border:1px solid #cfe3dd; border-radius:7px; padding:6px 10px; font-size:13.5px; color:#37475a; }
  #ov .lastcd b{ font-family:Consolas,monospace; font-size:14.5px; color:#0e6657; }
  #ov .lastcd .nmx{ font-weight:700; color:#1f2a37; }   /* 코드와 함께 '무슨 상품이었나'가 보여야 한다 */
  #ov .lastcd .dim{ color:#8b98a5; }
  #ov .lastcd button{ height:26px; padding:0 11px; font-size:12.5px; font-weight:700; border:1px solid var(--teal);
                      background:#fff; color:var(--teal); border-radius:6px; cursor:pointer; }
  #ov .lastcd button:hover{ background:var(--teal); color:#fff; }
  /* ───── 규격·제조사명 입력검색 (2026-08-04 요청) ─────
     이미 쓰고 있는 값 중에서 골라 넣는다 — 같은 규격이 표기만 달라 갈라지는 것을 막으려는 것.
     ★목록에 없는 값도 그냥 칠 수 있다(규격은 이제부터 채워 나가는 칸이라 고르기를 강요하면 못 쓴다).
     ★자리는 fixed 로 잡는다 — 모달 본문(.mb)이 overflow:auto 라 안쪽에 절대배치하면 목록이 잘린다. */
  .pfac{ position:fixed; z-index:70; background:#fff; border:1px solid var(--bd); border-radius:8px;
         box-shadow:0 8px 26px rgba(0,0,0,.20); font-size:13.5px; display:none; flex-direction:column; max-height:320px; }
  .pfac.on{ display:flex; }
  /* 안내줄은 반드시 한 줄 (2026-08-04 지적) — 두 줄로 접히면 그만큼 목록이 밀려 첫 후보가 안 보인다 */
  .pfac .h{ flex:0 0 auto; padding:5px 10px; background:#f7f9fa; color:#6b7a89; font-size:11.5px; border-bottom:1px solid #f0f3f5;
            white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .pfac .b{ flex:1 1 auto; min-height:0; overflow:auto; }
  .pfac .i{ padding:6px 10px; border-bottom:1px solid #f0f3f5; cursor:pointer; display:flex; gap:8px; align-items:center; }
  .pfac .i:last-child{ border-bottom:none; }
  .pfac .i:hover, .pfac .i.on{ background:#eef4ff; }
  .pfac .i .v{ flex:1 1 auto; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; color:#1f2a37; font-weight:700; }
  /* 건수 = 이 값을 쓰는 상품 수. 값 이름이 길어도 이 칸은 줄지 않는다(밀려서 잘리던 것 수정) */
  .pfac .i .c{ flex:0 0 auto; margin-left:auto; white-space:nowrap; color:#5a6b7a; background:#eef2f5;
               border-radius:9px; padding:1px 7px; font-size:11px; font-weight:700; }
  .pfac .nohit{ padding:9px 10px; color:#9aa7b3; cursor:default; }
  /* ───────── 거래처 매칭코드 — 하단 도킹 패널 (상품(품목)관리의 이력/재고 패널과 같은 방식) ─────────
     높이는 한 곳(--mc-h)에서만 정한다. .wrap 높이와 어긋나면 목록 끝이 패널에 가린다.
     ★2026-08-17 : 매칭코드가 여러 건인 상품이 늘어 34vh 로는 두세 줄밖에 안 보였다 ⇒ **46vh** 로 넓혔다.
       (입력 방식은 그대로다 — 보이는 공간만 늘렸다. 접기(▾)를 누르면 종전처럼 44px 로 접힌다.) */
  :root{ --mc-h:46vh; }
  #mc{ position:fixed; left:0; right:0; bottom:0; height:var(--mc-h); min-height:330px; z-index:45; }
  #mc.min{ height:44px; min-height:0; }
  #mc .box{ background:#fff; width:100%; height:100%; border-radius:12px 12px 0 0; box-shadow:0 -10px 34px rgba(0,0,0,.18);
            border-top:2px solid #8fc7bc; display:flex; flex-direction:column; }
  #mc.min .mb2{ display:none; }
  /* ★제목 띠 = 진한 teal → 연한 teal (2026-08-20 요청 「너무 진한색 연하게」) — 글자·닫기 색도 어두운 초록으로 */
  #mc .mh{ background:linear-gradient(135deg,#e3f2ee,#d2e9e2); color:#0b4f43; padding:8px 16px; border-radius:12px 12px 0 0;
           display:flex; align-items:center; gap:10px; }
  #mc .mh b{ font-size:14.5px; flex:0 0 auto; }
  #mc .mh .pick{ flex:1 1 auto; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
                 background:rgba(19,122,108,.08); border-radius:6px; padding:4px 10px; font-size:12.5px; }
  #mc .mh .x{ background:none; border:none; color:#137a6c; font-size:20px; cursor:pointer; flex:0 0 auto; }
  #mc .mb2{ flex:1 1 auto; min-height:0; display:flex; flex-direction:column; }
  #mc .tbwrap{ flex:1 1 auto; min-height:60px; overflow:auto; }
  #mc table{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  /* 머리글 — 조금 크게·구분색 (2026-08-04 요청). 위 목록의 검은 머리글과 색을 달리해
     '여기부터는 거래처 매칭코드 표'라는 것이 한눈에 갈리게 한다(패널 제목줄의 teal 과 같은 계열). */
  #mc thead th{ background:#b9ded4; color:#0b4f43; font-weight:800; border:1px solid #b6d6cf; border-bottom:2px solid var(--teal);
                padding:9px 10px; text-align:left; position:sticky; top:0; z-index:3; font-size:13.5px; font-weight:700; }
  #mc thead th.r{ text-align:right; }
  #mc tbody td{ border:1px solid var(--bd); padding:6px 10px; color:#10161d; }
  #mc tbody td.num{ text-align:right; }
  #mc tbody td.code{ font-family:Consolas,monospace; font-weight:700; }
  #mc .empty{ padding:18px; text-align:center; color:#9aa7b3; }
  /* 등록 줄 — 구두·문서로 받은 내용을 그대로 받아 적는 자리 */
  #mc .addbar{ flex:0 0 auto; border-top:1px solid var(--bd); background:#fafbfc; padding:9px 12px;
               display:flex; gap:6px; flex-wrap:wrap; align-items:flex-end; }
  #mc .addbar .f{ display:flex; flex-direction:column; gap:3px; }
  /* 글자 한 단계 크게 + 칸이름 진하게 (2026-08-04 요청) — 매일 받아 적는 자리라 흐리면 눈이 피로하다 */
  #mc .addbar label{ font-size:12.5px; font-weight:700; color:#1f2a37; }
  #mc .addbar input, #mc .addbar select{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:14px; }
  /* 품목명 입력칸 — 화면 폭을 다 먹지 않게 580px 로 (2026-08-02 요청, 380→490→580 재조정). 좁아지면 줄어들기만 한다 */
  #mc .addbar .grow{ flex:0 1 580px; }
  #mc .addbar .grow input{ width:100%; }
  /* 표 맨 끝 빈 칸 — 남는 폭을 여기서 먹어 품목명 칸이 늘어나지 않게 한다 */
  #mc thead th.sp{ border-left:none; }
  #mc tbody td.sp{ border-left:none; }
  #mc .addbar .btn{ height:34px; font-size:13.5px; }   /* 입력칸이 커진 만큼 [＋ 등록]도 같이 (2026-08-04) */
  /* ───── 품목코드 칸의 주상품코드 검색 (2026-08-02 요청) ─────
     거래처가 부르는 코드를 받아 적을 때 "이게 어느 주상품에 붙는 코드인지"를 이 자리에서 찾는다.
     ★위로 펼친다(bottom:100%) — 등록 줄이 화면 맨 아래라 아래로 열면 잘린다. */
  #mc .addbar .f.acwrap{ position:relative; }
  /* ★[2026-08-19 요청] 품목코드 칸 옆 「이 코드가 상품코드에 있는가」 표시.
     ★입력칸 **아래**가 아니라 **칸이름 줄**에 붙인다 — addbar 가 `align-items:flex-end` 라
       아래에 줄을 더하면 그 칸만 위로 들려 옆 칸들과 높이가 어긋난다. */
  #mc .addbar .acwrap label{ display:flex; align-items:baseline; gap:6px; max-width:520px; }
  #mc .addbar .cdinfo{ font-size:11.5px; font-weight:700; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  #mc .ac{ position:absolute; bottom:calc(100% + 4px); left:0; width:560px; max-height:340px;
           background:#fff; border:1px solid var(--bd); border-radius:8px; box-shadow:0 -8px 26px rgba(0,0,0,.20);
           z-index:60; font-size:12.5px; display:flex; flex-direction:column; }
  /* 창 안의 검색칸 — 위(품목코드)는 '등록할 거래처 코드', 여기는 '주상품 찾기'다. 둘을 섞지 않는다 */
  #mc .ac .ac-s{ flex:0 0 auto; padding:7px 8px; border-bottom:1px solid var(--bd); background:#f7f9fa; display:flex; gap:6px; align-items:center; }
  #mc .ac .ac-s input{ flex:1 1 auto; height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; }
  #mc .ac .ac-s .lb{ flex:0 0 auto; font-size:11.5px; font-weight:700; color:#6b7a89; }
  #mc .ac .ac-b{ flex:1 1 auto; min-height:0; overflow:auto; }
  #mc .ac .ac-i{ padding:6px 10px; border-bottom:1px solid #f0f3f5; cursor:pointer; display:flex; gap:8px; align-items:baseline; }
  #mc .ac .ac-i:last-child{ border-bottom:none; }
  #mc .ac .ac-i:hover, #mc .ac .ac-i.on{ background:#eef4ff; }
  #mc .ac .ac-i .c{ font-family:Consolas,monospace; font-weight:700; color:#274b8f; flex:0 0 110px; }
  #mc .ac .ac-i .n{ flex:1 1 auto; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; color:#1f2a37; }
  #mc .ac .ac-i .s{ flex:0 0 auto; color:#9aa7b3; font-size:11.5px; }
  #mc .ac .ac-i.self .c{ color:#9aa7b3; }          /* 붙일 상품 자기 자신 — 고를 일이 거의 없는 줄 */
  #mc .ac .ac-w{ padding:7px 10px; background:#fff6e8; border-bottom:1px solid #f2dfc2; color:#8a5a00; font-weight:700; }
  #mc .ac .ac-w.dup{ background:#fdeceb; border-bottom-color:#f5cfcc; color:#a5342c; }
  #mc .ac .nohit{ cursor:default; }                /* 알림 줄 — 누르는 자리가 아니다 */
  #mc .ac .ac-h{ padding:5px 10px; background:#f7f9fa; color:#6b7a89; font-size:11.5px; position:sticky; top:0; }
  #mc .ac .ac-f{ padding:5px 10px; background:#f7f9fa; color:#9aa7b3; font-size:11px; border-top:1px solid #f0f3f5; }
  /* 하단 패널 높이만큼 본문(스크롤 목록)이 짧아진다 — padding 이 아니라 높이로 뺀다 */
  .wrap{ height:calc(100% - var(--mc-h)); }
  .tag{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; background:#eef4ff; color:#274b8f; border:1px solid #c9d9f5; }
  .tag-n{ color:#9aa7b3; background:#f4f6f8; border-color:#e4e9ee; }
</style>
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
</head>
<body>
<div class="wrap">
  <h2>🏷️ 상품코드 등록 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(상품마스터 · TBL_PROD_MST)</span></h2>
  <%-- 설명줄은 뺐다(2026-08-04 요청) — 늘 같은 말이라 자리만 먹었다. 키 안내만 남긴다 --%>
  <div class="sub">⌨ <b>↑↓</b> 줄 이동 · <b>Enter</b> 수정 · <b>Alt+N</b> 추가
    &nbsp;|&nbsp; 창에서 <b>Enter</b> 다음 칸 · <b>Ctrl+S</b> 저장 · <b>Esc</b> 닫기</div>

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
    <%-- ★거래중지 조건 (2026-08-17 요청) — 중지한 코드만 모아 보거나, 살아 있는 것만 본다 --%>
    <select id="fStop" onchange="pcFilter()" style="height:34px;border:1px solid var(--bd);border-radius:7px;padding:0 8px;font-size:13px;font-weight:700;color:#37475a"
            title="거래중지된 상품만 / 중지 안 된 것만">
      <option value="">전체 (중지 무관)</option>
      <option value="Y">거래중지만</option>
      <option value="N">중지 안 된 것만</option>
    </select>
    <button class="btn btn-teal" style="margin-left:auto" onclick="pcOpen()">＋ 상품코드 추가</button>
    <button class="btn" onclick="pcEditSel()">✎ 수정</button>
    <button class="btn btn-danger" onclick="pcDelSel()">🗑 삭제</button>
    <%-- ★거래중지 (2026-08-17) — 거래가 붙어 **지울 수 없는** 잘못된 코드를 「앞으로 안 쓰는 코드」로.
         옛 전표·재고는 그대로 두고 매입·판매에서만 막힌다. --%>
    <button class="btn" id="btStop" onclick="pcStopSel()" title="이 코드를 앞으로 쓰지 않게 표시합니다(옛 자료는 그대로)">⛔ 거래중지</button>
    <%-- 삭제는 소프트 삭제라 자료가 남아 있다 — 실수로 지운 것을 여기서 되살린다 (2026-08-17 요청) --%>
    <button class="btn" onclick="rcOpen()" title="삭제한 상품코드를 보고 되살립니다">♻ 삭제 목록</button>
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
        <%-- ★[2026-08-17 요청] 적정재고를 **과세 앞으로** 옮겼다 — 오른쪽 끝에 있어 가로 스크롤을
             해야 보였다. 제조사·유형은 요청대로 **그대로** 둔다.
             ⚠칸 순서를 바꿀 때는 **머리글과 pcRender() 의 td 순서를 함께** 고쳐야 한다(둘 다 손댔다). --%>
        <%-- ★[2026-08-17 요청] 칸 순서 재배치 — **가로 스크롤 없이 봐야 하는 것을 앞으로.**
               · 적정재고 : **유형 뒤**로(제조사·유형은 원래 자리 그대로 앞에 둔다)
               · 중지일·매칭 : 오른쪽 끝에 있어 **스크롤해야 보였다** → 기본수량 뒤로 당김
               · 낱개BC·박스BC : 자주 안 보는 값이라 **맨 뒤로**
             ⚠칸 순서를 바꿀 때는 **머리글과 pcRender() 의 td 순서를 함께** 고쳐야 한다(둘 다 손댔다).
               어긋나면 값이 한 칸씩 밀려 엉뚱한 열에 보인다. --%>
        <%-- ★[2026-08-20 요청] 거래처명 칸 **삭제** — 거의 빈 칸이라 자리만 먹었다.
             값 자체(VENDOR_CD/NM)는 마스터에 남아 있고 수정 창의 거래처 칸에서 본다.
             (2026-08-17 「규격 뒤」 배치 이력은 git 참고. 되살리면 pcRender 의 td 도 같이.) --%>
        <th>코드</th><th>상품명</th><th>규격</th>
        <th>제조사</th><th>유형</th><th class="r">적정재고</th><th>과세</th>
        <th class="r">입수</th><th class="r">입고가</th><th class="r">판매가</th><th class="r">도매가</th>
        <%-- ★[2026-08-18 요청 「기본수량·매칭 위치 변경」] 기본수량을 **매칭 뒤로** 밀었다 —
             중지일·매칭이 한 칸씩 앞으로 당겨져 가로 스크롤 없이 먼저 보인다(자주 보는 값이다).
             바뀐 순서 : … 도매가 · 중지일 · 매칭 · **기본수량** · 낱개BC · 박스BC --%>
        <th title="거래중지 시작일 — 이 날짜부터 매입·판매에서 막힙니다">중지일</th><th>매칭</th>
        <th class="r">기본수량</th>
        <th>낱개BC</th><th>박스BC</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="16" class="empty">불러오는 중…</td></tr></tbody>
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
      <%-- 제목에서 '거래처' 는 뺐다(2026-08-04 요청) — 바로 아래 첫 칸이 '거래처'라 같은 말이 겹쳤다 --%>
      <b>🔖 매칭코드</b>
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
          <tbody id="mtb"><tr><td colspan="9" class="empty">위 목록에서 상품 줄을 고르세요.</td></tr></tbody>
        </table>
      </div>
      <div class="addbar">
        <%-- 거래처를 고르지 않으면 빈 값으로 저장되고 목록에는 '신규코드'로 표시된다(어느 거래처에도 매이지 않는 코드) --%>
        <div class="f"><label>거래처</label><select id="a_ven" style="width:170px"><option value="">(해당없음)</option></select></div>
        <%-- 품목코드 = 이 상품에 붙일 코드. 칸을 누르면 상품마스터 검색창이 열린다(2026-08-02 요청).
             ① 창에서 줄을 고르면 품목코드·품목명·규격이 그 줄 값으로 채워진다
             ② 붙는 곳은 언제나 '위에서 고른 상품' — 이 창은 대상 상품을 바꾸지 않는다 --%>
        <%-- ★[2026-08-19 요청] 친 코드가 상품코드(상품마스터)에 있으면 그 「주코드 명칭」을,
             없으면 「코드 없음」을 그 자리에서 알려 준다(mcCdInfo). 등록을 막지는 않는다. --%>
        <div class="f acwrap"><label>품목코드 * <span id="a_cdInfo" class="cdinfo"></span></label>
          <input id="a_cd" style="width:130px" autocomplete="off"
                 onclick="mcAcOpen()" onfocus="mcAcOpen()" oninput="mcAcTyped()" onkeydown="mcAcKey(event)">
          <div id="a_ac" class="ac" style="display:none"></div>
        </div>
        <%-- 품목명 + [유사 품명] — 치고 나서 **누를 때** 찾아 본다(2026-08-17 요청).
             코드가 달라도 같은 물건을 또 등록하는 것을 막을 사람은 사용자뿐이라, 판단 재료를 여기서 준다. --%>
        <div class="f grow"><label>품목명</label>
          <div style="display:flex; gap:6px">
            <%-- ★품목명을 치고 칸을 벗어나면 **그 자리에서** 비슷한 이름을 확인한다(2026-08-17 지시).
                 저장 순간이 아니라 **입력 직후**라야 고쳐 넣을 여지가 있다. --%>
            <%-- ★onfocus=mcCdFill — Tab·Enter 말고 **마우스로 품목명 칸을 바로 누를 때도**
                 채워진다(2026-08-19 추가 요청 「품명으로 선택해도」). 빈 칸일 때만 채우니 타이핑을 방해하지 않는다. --%>
            <input id="a_nm" style="flex:1" onfocus="mcCdFill()" onblur="mcSimBlur()"
                   onkeydown="if(event.keyCode===13){ mcSimBlur(); mcAdd(); }">
            <button class="btn" style="flex:0 0 auto" onclick="mcSimShow()"
                    title="비슷한 품목명이 이미 등록돼 있는지 찾아 봅니다">🔍 유사 품명</button>
          </div>
        </div>
        <div class="f"><label>규격</label><input id="a_spec" style="width:160px"></div>
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
      <%-- 새 코드는 9번대(2026-08-12) — 원천 코드(1000…)와 부딪히지 않게. 원천 코드를 직접 넣는 것은 막지 않는다. --%>
      <div class="fld"><label>상품코드 *</label><input id="f_cd" placeholder="예: 9000000001 (새 코드는 9번대)" title="새로 만드는 상품코드는 9로 시작합니다. 아래 줄의 새 코드가 미리 들어가 있습니다."></div>
      <div class="fld"><label>과세</label><select id="f_tax"><option value="과세">과세</option><option value="면세">면세</option></select></div>
      <%-- 코드 칸 바로 아래 줄 = 마지막으로 등록한 상품코드·상품명 (2026-08-12). 추가할 때만 나온다. --%>
      <div class="fld full lastcd" id="lastCd" style="display:none"></div>
      <%-- 거래처 칸은 규격 줄 오른쪽으로 옮겼다 (2026-08-20 요청 「규격 줄 2등분 우측」) — 아래 규격 옆에 있다. --%>
      <%-- ★상품명을 치고 칸을 벗어나면 **비슷한 상품이 이미 있는지** 알려 준다 (2026-08-17 요청).
           신규 등록 순간이 유일한 방어선이다 — 같은 물건을 다른 이름·다른 코드로 또 만들면
           ***재고가 두 코드로 갈라지고*** 뒤에 합칠 방법이 없다. 막지는 않는다(다른 물건일 수 있다). --%>
      <div class="fld full"><label>상품명 *</label>
        <div style="display:flex; gap:6px">
          <input id="f_nm" placeholder="상품명" style="flex:1" onblur="pcSimBlur()">
          <button type="button" class="btn" style="flex:0 0 auto" onclick="pcSimShow()"
                  title="비슷한 상품명이 이미 등록돼 있는지 찾아 봅니다">🔍 유사 상품</button>
        </div>
      </div>
      <%-- 규격·제조사명은 쓰던 값을 찾아 넣는다(2026-08-04) — 목록에 없으면 그냥 쳐도 된다 --%>
      <%-- ★규격 줄을 2등분 — 왼쪽 규격 · 오른쪽 거래처 (2026-08-20 요청). 둘 다 full 을 뗐다. --%>
      <div class="fld"><label>규격</label><input id="f_spec" placeholder="규격 — 쓰던 값 검색 (없으면 그냥 입력)" autocomplete="off"></div>
      <%-- ★[2026-08-17] 상품마스터에 **거래처 칸을 새로 만들어**(sql/prod_mst_vendor_alter.sql)
             여기서 「이 상품의 거래처」를 그대로 저장한다. 코드 칸이 필요 없어졌다.
           ⚠***거래처코드 매칭(아래 패널)과 다른 것***이다 :
             · 이 칸        = 「이 상품을 주로 대는 거래처」 — 사람이 보는 정보
             · 아래 매칭코드 = 「거래처가 부르는 코드 ↔ 우리 상품코드」 — 매입 자료를 잡는 열쇠
             매입 매칭은 여전히 코드가 있어야 도니, 코드를 붙일 때는 아래 패널을 쓴다.
           ★목록은 **입력칸 바로 아래**에 붙는다(규격·제조사와 같은 입력검색 방식 — pcAc 는 fixed 배치라
             칸이 어디 있든 따라온다). datalist 폐기·placeholder 축약 이력은 git(2026-08-17·18) 참고. --%>
      <div class="fld">
        <label>거래처</label>
        <input id="f_venQ" placeholder="거래처명 검색"
               autocomplete="off"
               title="이 상품을 주로 대는 거래처입니다. 매입 자료를 코드로 잡는 것은 아래 [거래처 매칭코드] 패널에서 합니다.">
        <input type="hidden" id="f_ven">
      </div>
      <div class="fld"><label>제조사명</label><input id="f_maker" placeholder="쓰던 값 검색 (없으면 그냥 입력)" autocomplete="off"></div>
      <div class="fld"><label>유형명</label><input id="f_type"></div>
      <%-- ★입수수량 입력칸은 **이 하나뿐**이다 (2026-08-20 「변수 중복」 지적) —
             수정 창에서는 이 칸(f_pack)을 통째로 아래 재고 표의 첫 칸(s_pkTd)으로 **옮겨 달고** 이 자리는 숨긴다.
             추가 창에서는 재고 표가 없으므로 여기 그대로 둔다. 값이 두 군데 살지 않으니 동기화도 없다. --%>
      <div class="fld" id="packFld"><label>입수수량</label><input id="f_pack" type="number" value="1"
           title="입수수량(BOX당 EA) — 고치면 BOX/EA 재고가 다시 나뉩니다"></div>
      <div class="fld"><label>조회순서</label><input id="f_sort" type="number" value="999999"></div>
      <div class="fld"><label>입고단가</label><input id="f_in" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>판매단가</label><input id="f_sale" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>도매단가</label><input id="f_whole" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>적정재고</label><input id="f_safe" type="number" value="0"></div>
      <div class="fld"><label>판매기본수량</label><input id="f_base" type="number" value="0"></div>
      <div class="fld"><label>낱개바코드</label><input id="f_ubc"></div>
      <div class="fld"><label>박스바코드</label><input id="f_bbc"></div>
      <%-- ★재고수량 (2026-08-20 요청) — **수정 창에만** 나온다(새 상품은 재고가 없다).
             재고 일괄조정(stockAdj.jsp)과 같은 칸 배열 : 현재고(BOX·EA·합계) → 수정BOX·수정EA → 증감.
           ★현재고는 창을 열 때 **이 상품 것만** 읽는다 — 목록(prodList)에 합계재고를 붙이면
             원장 집계가 조회마다 돌아 느려진다(재고 일괄조정에서 겪은 그 문제). 여기는 창 열 때 한 번뿐.
           ★저장은 stockAdjSave.do 재사용 — 덮어쓰지 않고 **차이만큼 조정행(IO_GB='A')** 이 남고,
             재고 일괄조정 화면의 [조정 이력]에서 똑같이 보이고 되돌릴 수 있다. --%>
      <div class="stk" id="stkBox" style="display:none">
        <%-- 괄호 안내(재고 일괄조정과 같은 방식…)는 뺐다 — 2026-08-20 요청 「표시삭제」 --%>
        <div class="cap">📦 재고수량 — 수정BOX·수정EA 를 고치면 <b>차이만큼 조정</b>으로 저장됩니다</div>
        <%-- ★입수수량이 **제일 앞** (2026-08-20 요청) — 재고 일괄조정의 칸 순서(입수수량 → 재고들)와 같다.
               이 칸은 비어 있다가 수정 창을 열 때 위 상품 항목의 입수수량 입력칸(f_pack)이 **통째로 옮겨 들어온다**
               (pcStkOpen) — 같은 값을 두 칸에 두고 동기화하는 중복을 없앤 것(2026-08-20 「변수 중복」 지적). --%>
        <table>
          <thead><tr>
            <th>입수수량</th>
            <th>BOX재고</th><th>EA재고</th><th>합계재고</th>
            <th>수정BOX재고</th><th>수정EA재고</th><th>증감</th>
          </tr></thead>
          <tbody><tr>
            <td class="c" id="s_pkTd"></td>
            <td class="r" id="s_vb">-</td>
            <td class="r" id="s_ve">-</td>
            <td class="r" id="s_cur">-</td>
            <td class="c"><input id="s_bx" type="number" oninput="pcStkChg()" title="BOX 단위 재고 — 입수수량(BOX당 EA)으로 환산해 합계가 계산됩니다"></td>
            <td class="c"><input id="s_ea" type="number" oninput="pcStkChg()" title="낱개(EA) 재고"></td>
            <td class="r" id="s_df"><span class="dim">-</span></td>
          </tr></tbody>
        </table>
        <div class="rmk"><label>사유</label><input id="s_rmk" placeholder="재고 조정 사유 (비우면 '상품코드등록에서 조정' 으로 남습니다)"></div>
        <%-- 이 상품의 조정 이력 (2026-08-20 요청) — 재고 일괄조정 하단 [조정 이력]과 같은 내용을 이 상품 것만.
             되돌리기는 stockAdj 와 같은 묶음(BATCH_NO) 단위 — 한 저장에 여러 상품이 섞였으면 **전부 함께** 내려간다. --%>
        <div class="his">
          <div class="hcap">📜 이 상품의 조정 이력</div>
          <div class="hgrid">
            <table>
              <thead><tr>
                <th>기준일자</th><th class="r">전</th><th class="r">후</th><th class="r">증감</th>
                <th class="r">입수</th><th>사유</th><th>등록자</th><th>등록일시</th><th class="c">되돌리기</th>
              </tr></thead>
              <tbody id="s_hisBody">
                <tr><td colspan="9" class="c dim" style="padding:10px">-</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
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
/* ★[2026-08-17 요청 「하단 페이징 스크롤되게 변경」] **기본을 「전체 펼침」으로** 바꿨다(_all=true) —
     페이지 단추(‹ 1 … 11 12 ›)를 눌러 넘기는 대신 ***목록을 그냥 스크롤***해 훑는다.
     이미 있던 [▼ 전체 펼치기] 기능을 기본값으로 돌린 것이라 새 코드가 아니다.
   ★`.card` 가 이미 `overflow:auto` 이고 머리글이 `position:sticky` 라 **스크롤해도 머리글은 남는다.**
   ⚠[▲ 접기] 단추는 남겨 둔다 — 다시 페이지 단위로 보고 싶을 때 쓸 수 있어야 한다(되돌리는 문). */
var LIST=[], _view=[], _page=1, PAGE=50, _byseq={}, _tax='', _sel=null, _all=true;   // _all = 전체 펼침(기본)

function toast(s,t){ if(window._toast) window._toast(s, t||'info'); }
/* 확인창. ★단추 글자·아이콘을 **부르는 쪽이 정한다** (2026-08-17) —
   기본이 '삭제/🗑️' 로 박혀 있어서 거래해제 창에도 [삭제] 가 떴다(사용자 지적).
   ***창의 단추는 그 창이 실제로 하는 일을 말해야 한다.*** */
function confirmBox(msg, onOk, okText, icon){
  if(window._confirmBox){ window._confirmBox({ msg:msg, icon:icon||'🗑️', okText:okText||'삭제', onOk:onOk }); return; }
  if(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))) onOk();
}
/* 알림 — ★공통 표준(ui-message.js)을 쓴다. **Swal 직접 사용 금지**(이 파일 머리 규칙).
   삭제 확인창과 같은 모양이라 사용자에게도 같은 창으로 읽힌다. 없으면 alert 로 내려간다. */
function alertBox(msg, icon){
  if(window._alertBox){ window._alertBox(msg, { icon: icon || 'ℹ️' }); return; }
  alert((''+msg).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]+>/g,''));
}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function num(v){ return (v==null||v==='')?'':Number(v).toLocaleString(); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function gnum(id){ var v=gv(id); return v===''?null:Number(v); }

/* ★done 콜백을 받는다(2026-08-17) — 상품을 새로 만든 뒤 **그 상품의 prodSeq 를 알아야** 매칭코드를
     붙일 수 있어서, 목록을 다시 읽고 나서 이어 할 일을 넘긴다. 인수를 안 주면 종전과 똑같이 동작한다. */
function pcLoad(done){
  fetch(CTX+'/prod/prodList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.text(); })
    .then(function(txt){ var j; try{ j=JSON.parse(txt); }catch(e){ toast('목록 응답 오류','err'); return; }
      LIST=(j&&j.data)||[]; _byseq={}; LIST.forEach(function(o){ _byseq[o.prodSeq]=o; });
      /* ★[2026-08-19] 고른 상품(_mcCur)도 **새로 읽은 줄로 갈아 끼운다** — 안 하면
         [⛔ 거래중지]·[▶ 거래해제] 를 누른 뒤에도 **옆날 상태**를 들고 있어
         매칭코드 잠금(아래 mcStopSync)이 그대로 남거나 풀리지 않는다. */
      if(_mcCur) _mcCur=_byseq[_mcCur.prodSeq]||_mcCur;
      pcUniqBuild();                     // 규격·제조사명 입력검색이 볼 값 목록(2026-08-04)
      pcFilter();
      mcStopSync();                      // 중지·해제가 반영되면 [＋ 등록] 잠금도 같이 맞춘다
      if(typeof done==='function'){ try{ done(); }catch(e){} }
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
  var sp=(document.getElementById('fStop')||{}).value||'';   // ★거래중지 조건(2026-08-17)
  _view=LIST.filter(function(o){
    if(_tax && (''+(o.taxGb||''))!==_tax) return false;
    // 매칭 필터 — _mcCnt 는 하단 [거래처 매칭코드] 를 읽을 때 채워진다(상품별 건수)
    if(mc==='Y' && !_mcCnt[o.prodSeq]) return false;
    if(mc==='N' &&  _mcCnt[o.prodSeq]) return false;
    if(sp==='Y' && o.stopYn!=='Y') return false;
    if(sp==='N' && o.stopYn==='Y') return false;
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
  if(!tot){ tb.innerHTML='<tr><td colspan="16" class="empty">데이터가 없습니다.</td></tr>'; _pager(0,1,0); return; }
  // 펼침(_all)이면 조회된 전 건을 한 번에 — 페이지 버튼 대신 목록 스크롤로 훑는다
  var from = _all ? 0 : (_page-1)*PAGE, to = _all ? tot : Math.min(from+PAGE, tot);
  tb.innerHTML=_view.slice(from,to).map(function(o){
    var c=(o.taxGb==='면세')?'#2e7d32':'#5a6b7a';
    /* ★이 상품코드가 **다른 주코드의 서브로 등록돼 있으면** 그렇게 적는다 (2026-08-17 요청) —
       매입등록 상품검색과 **같은 모양**(빨간 '서브' 배지 + → 주코드, 아래에 마스터 상품명).
       주코드를 누르면 그 상품 줄로 옮겨 간다(이미 있는 mcGoProd 를 쓴다). */
    var sb=_subOf[String(o.prodCd)], cdCell=esc(o.prodCd), mstNm='';
    /* ★거래중지 표시 (2026-08-17) — 목록에서 지우지 않는다(해제도 여기서 한다).
       ★코드 칸엔 **배지만 한 줄로** 붙인다 — 날짜는 오른쪽 [중지일] 칸에 따로 있다. */
    if(o.stopYn==='Y'){
      cdCell = '<span style="white-space:nowrap">' + cdCell
             + ' <span style="display:inline-block;padding:0 5px;border-radius:8px;'
             + 'background:#eceff1;color:#546e7a;font-size:11px;font-weight:700">중지</span></span>';
    }
    if(sb){
      var mp=_byseq[sb.prodSeq]||{};
      /* ★[2026-08-18 요청] 「서브 → 주코드」 줄만 **두 단계 크게** — 배지 11→12→13px, 코드 11.5→12.5→13.5px.
           누르는 자리인데 너무 작아 눈에 안 들어왔다. 아래 「마스터 : …」 는 읽기만 하는 줄이라 그대로 둔다. */
      cdCell += '<div style="margin-top:2px"><span style="display:inline-block;padding:0 5px;border-radius:8px;'
             +  'background:#fdecea;color:#c0392b;font-size:13px;font-weight:700">서브</span>'
             /* ★[2026-08-18] **인라인 onclick 을 없앴다** — 「주코드를 눌러도 다른 데로 간다 / 선택이 없어진다」가
                  이어졌다. 원인 후보 1순위는 ***문자열로 조립한 onclick 속성***이었다(코드를 따옴표로 감싸며
                  이스케이프가 어긋나면 핸들러가 통째로 죽고, ***누른 티도 안 난다*** — 화면은 직전 선택을
                  그대로 들고 있어 「다른 코드로 갔다」처럼 보인다).
                ⇒ 값은 **data 속성**으로만 싣고, 실제 처리는 **위임 핸들러 한 곳**에서 한다(아래 pcSubGoBind).
                  조립할 JS 문자열이 없어져 이 부류의 오류가 원천 차단된다. */
             +  ' <a href="javascript:;" class="subgo" data-cd="'+esc(sb.prodCd)+'" data-seq="'+sb.prodSeq+'"'
             +  ' style="font-size:13.5px;color:#1f7a4d;font-weight:700;text-decoration:underline"'
             +  ' title="주코드 '+esc(sb.prodCd)+' 를 선택합니다 — 화면은 그대로 있고 하단 매칭코드만 바뀝니다">→ '
             +  esc(sb.prodCd)+'</a></div>';
      if(mp.prodNm) mstNm='<div style="font-size:11.5px;color:#8a97a3;margin-top:2px">마스터 : '+esc(mp.prodNm)+'</div>';
    }
    /* ★중지된 줄은 class="stopped" — 색칠하기는 CSS 가 한다(2026-08-19 요청) */
    return '<tr'+(o.stopYn==='Y'?' class="stopped"':'')+' data-seq="'+o.prodSeq+'" onclick="pcSel(this,'+o.prodSeq+')" ondblclick="pcOpen('+o.prodSeq+')">'
      +'<td class="code">'+cdCell+'</td><td class="nm">'+esc(o.prodNm)+mstNm+'</td>'
      /* ★칸 순서는 위 thead 와 **똑같이** 유지한다(2026-08-20 거래처명 칸 삭제) :
           규격 → 제조사 → 유형 → 적정재고 → 과세 → 입수 → 입고가 → 판매가 → 도매가
           → 중지일 → 매칭 → 기본수량 → 낱개BC → 박스BC
         ★거래처명 칸은 뺐다(2026-08-20 요청) — 값(VENDOR_CD/NM)은 마스터에 그대로, 수정 창에서 본다. */
      +'<td title="'+esc(o.spec)+'">'+esc(o.spec)+'</td>'   /* 잘려도 마우스로 전체를 본다 */
      +'<td>'+esc(o.makerNm)+'</td><td>'+esc(o.typeNm)+'</td>'
      +'<td class="num">'+num(o.safeStock)+'</td>'
      +'<td><span class="tx" style="background:'+c+'">'+esc(o.taxGb||'-')+'</span></td>'
      +'<td class="num">'+num(o.packQty)+'</td><td class="num">'+num(o.inPrice)+'</td>'
      +'<td class="num">'+num(o.salePrice)+'</td><td class="num">'+num(o.wholePrice)+'</td>'
      /* 중지일 — 값이 있으면 회색으로. 코드 아래 배지와 겹치지만, ***칸으로도 있어야*** 훑거나
         엑셀로 뽑을 때 읽힌다(2026-08-17 요청). */
      +'<td style="white-space:nowrap;color:#546e7a">'+(o.stopYn==='Y'?esc(pcFmtDt8(o.stopFrDt)):'')+'</td>'
      // 매칭 = 이 상품에 붙여 둔 거래처 코드 수. 0이면 그 코드로 오는 자료는 미매핑이 된다
      +'<td>'+(_mcCnt[o.prodSeq] ? ('<span class="tag">'+_mcCnt[o.prodSeq]+'</span>') : '<span class="tag tag-n">0</span>')+'</td>'
      /* ★기본수량은 **매칭 뒤**다(2026-08-18) — 머리글과 순서를 맞춘 것이다. 어긋나면 값이 밀린다. */
      +'<td class="num">'+num(o.saleBaseQty)+'</td>'
      +'<td>'+esc(o.unitBarcode)+'</td><td>'+esc(o.boxBarcode)+'</td>'
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
  pcStopBtnSync();           // ★고른 상품이 중지 상태면 단추를 [거래해제] 로 (2026-08-17 요청)
}
/* 단추 하나로 중지·해제를 다 한다 — 두 개를 나란히 두면 어느 것이 지금 쓸 것인지 헷갈린다.
   ★고른 상품의 상태를 단추가 그대로 말해 준다. 아무것도 안 골랐으면 기본 문구. */
function pcStopBtnSync(){
  var b=document.getElementById('btStop'); if(!b) return;
  var o=(_sel!=null)?(_byseq[_sel]||{}):{};
  if(o.stopYn==='Y'){
    b.textContent='▶ 거래해제';
    b.title='이 코드를 다시 매입·판매에 쓸 수 있게 합니다'
          + (o.stopFrDt ? (' (지금 '+pcFmtDt8(o.stopFrDt)+' 부터 중지)') : '');
  }else{
    b.textContent='⛔ 거래중지';
    b.title='이 코드를 앞으로 쓰지 않게 표시합니다(옛 자료는 그대로)';
  }
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

/* ── 신규등록 창 「최종 코드」 안내 (2026-08-12 요청) ─────────────────────────────
   새 상품코드를 붙이려면 '지금 어디까지 썼나'를 먼저 알아야 한다. 목록은 코드순이라
   ★맨 끝 줄이 최근 등록분이 아니다. 그래서 두 가지를 같이 낸다:
     ① 가장 최근 등록(REG_DTTM 기준 · 코드 + 상품명) ② ★9번대 최대 코드 → 다음 코드(아래 규칙).
   ★자릿수가 다른 코드는 한 줄에 세우지 않는다 — 섞이면 '가장 큰 코드'가 뜻을 잃는다.
   ★수정은 REG_DTTM 을 안 건드리므로(updateProd 는 제자리 UPDATE) '최근 등록'이 실제 신규 등록순 그대로다.
   ★목록(LIST)은 이미 화면에 들어와 있으므로 서버를 부르지 않는다. 탭·검색은 화면단 필터라
     LIST 는 늘 전체다 — '최근 등록'이 지금 보고 있는 탭에 따라 달라지지 않는다.
   같은 것이 상품(품목)관리(prodmst.jsp)·매입/매출 거래처(vendorMng.jsp)에 있다 — 규칙을 고치면 함께. */
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
/* ── ★새 상품코드는 「9」로 시작한다 (2026-08-12 확정) ───────────────────────────
   원천 코드(웰스토리 발주현황표)는 `1000…` 번대다. 우리가 직접 붙이는 코드를 그 번호대에
   끼워 넣으면 뒤에 들어올 원천 코드와 부딪친다 → ★신규 코드는 9번대만 쓴다.
   그래서 '다음 코드'는 최근 등록분의 형식이 아니라 ★9로 시작하는 코드 중 최대값 +1.
   자릿수는 9번대 코드가 있으면 그 중 가장 최근 등록분을 따르고, 하나도 없으면 NEW_W
   (10자리 = 원천 코드와 같은 길이) 로 9000000001 부터 시작한다.
   ★9가 아닌 코드도 등록은 막지 않는다 — 원천 코드를 손으로 넣어야 할 때가 있다(안내만 한다). */
var NEW_PRE='9', NEW_W=10;
function _isNewCd(cd){ return /^9\d*$/.test(String(cd==null?'':cd)); }   // 9로 시작하는 숫자코드
function pcNineInfo(list){                   // 9번대 최대코드 → 다음코드
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
function pcLastInfo(){
  var last=null;
  LIST.forEach(function(o){                  // REG_DTTM 은 'YYYY-MM-DD HH:MM:SS' 문자열이라 그대로 비교된다
    if(!o.regDttm) return;
    if(!last || String(o.regDttm) > String(last.regDttm)) last=o;
  });
  // 등록일시가 아예 없는 자료면 코드가 가장 큰 줄을 대신 잡는다
  if(!last) LIST.forEach(function(o){ if(!last || String(o.prodCd) > String(last.prodCd)) last=o; });
  var n=pcNineInfo(LIST);
  return { last:last, max:n.max, next:n.next };   // 목록이 비어 있어도 시작 코드는 낸다
}
function pcLastCdShow(on){
  var el=document.getElementById('lastCd'); if(!el) return;
  _nextCd='';
  var i = on ? pcLastInfo() : null;
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
     + ' <button type="button" onclick="pcUseNext()" title="상품코드 칸에 넣습니다. 창을 열면 이미 들어가 있습니다 — 그대로 두거나 직접 쳐도 됩니다.">넣기</button>';
  }
  el.innerHTML=h; el.style.display='flex';
}
/* 추가/수정 창의 거래처 콤보 — 아래 [거래처 매칭코드] 패널이 읽어 둔 VEN 을 그대로 쓴다.
   ★따로 불러오지 않는다 — 두 곳이 다른 목록을 보여 주면 어느 것이 맞는지 알 수 없다.
   ⚠VEN 은 mcLoad 가 채운다. 아직 비어 있으면 '(해당없음)' 만 남는다 — 거래처 없이도 등록은 된다. */
/* 거래처 후보를 **입력검색과 같은 자료 구조**(_uniq.ven)에 담는다 — 그림·조작이 저절로 같아진다.
   ★표시는 「이름 [코드]」 — 같은 이름이 둘일 때 가려낼 수 있어야 한다.
   ★고르면 pcAcPick 이 이름을 칸에 넣고, 숨은 칸(f_ven)에 **코드**를 담는다(서버에 보내는 값은 코드). */
function pcVenFill(){
  _uniq.ven=(VEN||[]).filter(function(v){ return v.vendorCd; })
    .map(function(v){ return { v:(v.vendorNm||v.vendorCd)+' ['+v.vendorCd+']', n:0, cd:v.vendorCd }; });
}
function pcUseNext(){
  if(!_nextCd) return;
  var el=document.getElementById('f_cd');
  el.value=_nextCd; el.focus();
}

function pcOpen(seq){
  var o=(seq!=null)?_byseq[seq]:null;
  _pcSimLast = o ? String(o.prodNm||'') : '';   // ★새로 열면 유사 확인을 다시 한다(수정은 원래 이름은 넘긴다)
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
  /* ★거래처 코드 묶음 (2026-08-17) — **추가할 때만** 쓴다. 수정은 아래 패널에서 목록을 보며 고친다. */
  /* ★거래처 코드 묶음은 **추가·수정 둘 다** 쓴다(2026-08-17) — 이미 있는 상품에 코드를 붙일 때도
     아래 패널까지 내려가지 않아도 된다. **값은 열 때마다 비운다** — 남아 있으면 다른 상품에
     엉뚱한 코드를 또 붙인다(이 칸은 「지금 새로 붙일 코드」를 받는 자리다). */
  /* 거래처 — 저장된 값을 그대로 보여 준다(수정). 이름은 지금 목록에서 찾아 붙여 **바뀐 이름도 반영**한다. */
  pcVenFill();                                         // 거래처 목록 = 아래 패널과 같은 자료(VEN)
  _set('f_ven', o?(o.vendorCd||''):'');
  _set('f_venQ', o&&o.vendorCd ? ((mcVenNm(o.vendorCd)||o.vendorNm||'')+' ['+o.vendorCd+']') : '');
  pcLastCdShow(!o);                   // 추가일 때만 「최근 등록 코드·상품명」 줄을 낸다 (수정은 코드가 잠겨 있어 쓸모없다)
  pcStkOpen(o);                       // 재고수량 칸 — 수정이면 이 상품의 현재고를 읽어 채운다(추가면 숨김)
  // 추가는 9번대 새 코드를 미리 넣어 둔다 — 아래에서 코드 칸을 select 하므로 그냥 쳐서 바꿀 수 있다
  if(!o && _nextCd) _set('f_cd', _nextCd);
  document.getElementById('ov').classList.add('on');
  pcAcClose();                        // 이전에 열려 있던 규격·제조사 후보창은 닫고 시작한다
  // 창을 열면 곧바로 칠 수 있게(2026-08-04) — 추가는 상품코드에 포커스.
  // ★수정 창은 아무것도 선택하지 않는다 (2026-08-20 요청 「기본선택이 상품명인데 선택없게」) —
  //   상품명이 통째로 선택된 채 열려 키를 잘못 누르면 이름이 날아갔다.
  if(!o){
    var first=document.getElementById('f_cd');
    setTimeout(function(){ if(first){ first.focus(); if(first.select) first.select(); } }, 0);
  }
}
function pcClose(){ document.getElementById('ov').classList.remove('on'); pcAcClose(); }

/* ==================== 재고수량 (수정 창의 재고 칸) ====================
   재고 일괄조정(stockAdj.jsp)의 한 줄 판 — 규칙을 그 화면과 똑같이 둔다.
   ★현재고 = /prod/stockQtyMap.do (원장 합계, 대시보드가 쓰는 가벼운 조회 — 2026-08-07 실측 29ms).
     ***목록 조회(prodList)에는 붙이지 않는다*** — 전 품목 원장 집계가 조회마다 돌면
     재고 일괄조정에서 겪은 「현재고 계산 때문에 조회가 느려지는」 문제가 여기서도 생긴다.
     창을 여는 순간 한 번만 읽는다.
   ★BOX/EA 분해 = 현재고를 입수수량으로 나눈 표시일 뿐(음수는 부호 유지 — stockAdj 와 동일).
     입수수량 칸(f_pack)을 고치면 그 자리에서 다시 나눈다(수정칸도 같이 맞춰 증감 0).
   ★저장 = /prod/stockAdjSave.do 재사용 — 차이만큼 조정행(A)+이력. 되돌리기는 재고 일괄조정의 [조정 이력]. */
var _stk=null, _stkSeq=null;   /* _stk = {curQty,box,ea} — null 이면 아직 못 읽음(재고 저장은 건너뜀) */
function pcStkOpen(o){
  var box=document.getElementById('stkBox');
  _stk=null; _stkSeq=o?String(o.prodSeq):null;
  document.getElementById('s_rmk').value='';
  /* ★입수수량 입력칸(f_pack)은 하나뿐 — 수정 창에서는 재고 표 첫 칸으로 옮겨 달고 위 자리는 숨긴다.
     추가 창에서는 원래 자리(packFld)로 되돌린다. 값이 두 군데 살지 않으니 동기화가 필요 없다. */
  var pf=document.getElementById('packFld'), pi=document.getElementById('f_pack');
  if(!o){ pf.appendChild(pi); pf.style.display=''; box.style.display='none'; return; }
  document.getElementById('s_pkTd').appendChild(pi); pf.style.display='none';
  box.style.display='block';
  ['s_vb','s_ve','s_cur'].forEach(function(id){ var el=document.getElementById(id); el.textContent='…'; el.className='r'; });
  document.getElementById('s_df').innerHTML='<span class="dim">-</span>';
  ['s_bx','s_ea'].forEach(function(id){ var el=document.getElementById(id); el.value=''; el.disabled=true; });
  pcStkHisLoad(o);                                     // 이 상품의 조정 이력 — 재고와 나란히 읽는다
  fetch(CTX+'/prod/stockQtyMap.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(_stkSeq!==String(o.prodSeq)) return;          // 그 사이 다른 상품을 열었다 — 옛 응답은 버린다
      var cur=0;
      ((j&&j.data)||[]).some(function(x){ if(String(x.prodCd)===String(o.prodCd)){ cur=Number(x.curQty)||0; return true; } return false; });
      _stk={ curQty:cur };
      ['s_bx','s_ea'].forEach(function(id){ document.getElementById(id).disabled=false; });
      pcStkSplit();
    })
    .catch(function(){
      if(_stkSeq!==String(o.prodSeq)) return;
      ['s_vb','s_ve','s_cur'].forEach(function(id){ document.getElementById(id).textContent='?'; });
      toast('현재고를 불러오지 못했습니다 — 재고 칸은 이번 저장에서 빠집니다.','warn');
    });
}
function pcStkPack(){ var v=Number(gv('f_pack')||0); return v<1?1:v; }
function pcStkSplit(){
  if(!_stk) return;
  var pack=pcStkPack(), cur=_stk.curQty, sign=cur<0?-1:1;
  var box=sign*Math.floor(Math.abs(cur)/pack), ea=sign*(Math.abs(cur)%pack);
  _stk.box=box; _stk.ea=ea;
  document.getElementById('s_vb').textContent=box;
  document.getElementById('s_ve').textContent=ea;
  var c=document.getElementById('s_cur'); c.textContent=cur; c.className='r'+(cur<0?' neg':'');
  document.getElementById('s_bx').value=box;           // 수정칸 = 현재값 → 증감 0 에서 시작
  document.getElementById('s_ea').value=ea;
  pcStkChg();
}
function pcStkDiff(){
  if(!_stk) return 0;
  var aft=(Number(gv('s_bx'))||0)*pcStkPack()+(Number(gv('s_ea'))||0);
  return aft-_stk.curQty;
}
function pcStkChg(){
  var td=document.getElementById('s_df');
  if(!_stk){ td.innerHTML='<span class="dim">-</span>'; return; }
  var d=pcStkDiff();
  td.innerHTML = d===0 ? '<span class="dim">-</span>'
    : '<span class="diff '+(d>0?'up':'dn')+'">'+(d>0?'+':'')+d+'</span>';
}
/* 입수수량을 고치면 BOX/EA 를 그 자리에서 다시 나눈다 — 안 하면 옛 BOX 숫자가 새 입수수량으로
   곱해져 건드리지도 않은 재고가 바뀐 것처럼 잡힌다(stockAdj packChg 와 같은 이유).
   ★리스너는 요소에 붙어 있으므로 칸을 재고 표로 옮겨 달아도(appendChild) 그대로 산다. */
(function(){ var p=document.getElementById('f_pack'); if(p) p.addEventListener('input', function(){ if(_stk) pcStkSplit(); }); })();
function _todayYmd(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }

/* ── 이 상품의 조정 이력 — stockAdj 하단 [조정 이력]의 축소판 ─────────────────
   조회는 같은 엔드포인트(stockAdjHisList.do)에 prodSeq 만 얹는다(SQL 이 이미 받는다 — 서버 무변경).
   되돌리기도 stockAdj 와 같은 묶음(BATCH_NO) 단위 — 한 저장에 여러 상품이 섞였으면 전부 함께 내려간다. */
function pcStkHisLoad(o){
  var tb=document.getElementById('s_hisBody');
  tb.innerHTML='<tr><td colspan="9" class="c dim" style="padding:10px">불러오는 중…</td></tr>';
  fetch(CTX+'/prod/stockAdjHisList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
      credentials:'same-origin', body:'prodSeq='+encodeURIComponent(o.prodSeq) })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(_stkSeq!==String(o.prodSeq)) return;          // 그 사이 다른 상품을 열었다
      var rows=(j&&j.data)||[];
      if(!rows.length){ tb.innerHTML='<tr><td colspan="9" class="c dim" style="padding:10px">조정 이력이 없습니다.</td></tr>'; return; }
      tb.innerHTML=rows.map(function(h){
        var d=Number(h.diffQty)||0, bd=String(h.baseDt||'');
        if(bd.length===8) bd=bd.slice(0,4)+'-'+bd.slice(4,6)+'-'+bd.slice(6,8);
        return '<tr>'
          + '<td class="c">'+esc(bd)+'</td>'
          + '<td class="r">'+(h.befQty==null?'':h.befQty)+'</td>'
          + '<td class="r">'+(h.aftQty==null?'':h.aftQty)+'</td>'
          + '<td class="r"><span class="diff '+(d>0?'up':'dn')+'">'+(d>0?'+':'')+d+'</span></td>'
          + '<td class="r">'+(h.packQty==null?'':h.packQty)+'</td>'
          + '<td>'+esc(h.remark)+'</td>'
          + '<td class="c">'+esc(h.regUser)+'</td>'
          + '<td class="c">'+esc(h.regDttm)+'</td>'
          + '<td class="c"><button type="button" class="undo" onclick="pcStkUndo(\''+esc(h.batchNo)+'\')">되돌리기</button></td>'
          + '</tr>';
      }).join('');
    })
    .catch(function(){
      if(_stkSeq!==String(o.prodSeq)) return;
      tb.innerHTML='<tr><td colspan="9" class="c dim" style="padding:10px">이력을 불러오지 못했습니다.</td></tr>';
    });
}
function pcStkUndo(batchNo){
  var seq=gv('f_seq'), o=seq?_byseq[seq]:null;
  confirmBox('<b>'+esc(batchNo)+'</b> 묶음을 되돌립니다.<br>'
           + '이 저장으로 만들어진 <b>조정행이 모두 내려갑니다</b> — 같은 저장에 다른 상품이 섞였으면 그것도 함께 되돌아갑니다.',
    function(){
      fetch(CTX+'/prod/stockAdjCancel.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'},
          credentials:'same-origin', body:'batchNo='+encodeURIComponent(batchNo) })
        .then(function(r){ return r.json(); })
        .then(function(d){
          if(!d||d.result!=='OK'){ alertBox('되돌리지 못했습니다.<br>'+esc((d&&d.message)||''),'⚠️'); return; }
          toast(d.cnt+'건 되돌렸습니다.','ok');
          if(o) pcStkOpen(o);                          // 현재고·이력을 새 값으로 다시 읽는다 (사유 칸은 비워진다)
        })
        .catch(function(){ alertBox('되돌리지 못했습니다.','⚠️'); });
    }, '되돌리기', '⚠️');
}

function pcSave(){
  var seq=gv('f_seq'), cd=gv('f_cd'), nm=gv('f_nm');
  if(!cd){ toast('상품코드를 입력하세요.','warn'); return; }
  if(!nm){ toast('상품명을 입력하세요.','warn'); return; }
  var dto={ prodCd:cd, prodNm:nm, spec:gv('f_spec')||null, makerNm:gv('f_maker')||null, typeNm:gv('f_type')||null,
    taxGb:gv('f_tax')||null, packQty:gnum('f_pack'), sortOrd:gnum('f_sort'),
    inPrice:gnum('f_in'), salePrice:gnum('f_sale'), wholePrice:gnum('f_whole'),
    safeStock:gnum('f_safe'), saleBaseQty:gnum('f_base'),
    unitBarcode:gv('f_ubc')||null, boxBarcode:gv('f_bbc')||null,
    /* ★거래처 (2026-08-17) — 코드와 그때 그 이름을 함께 보낸다(목록에서 조인 없이 보여 주려고) */
    vendorCd:gv('f_ven')||null, vendorNm:(gv('f_ven')?(mcVenNm(gv('f_ven'))||null):null) };
  var url, okmsg;
  if(seq){ dto.prodSeq=Number(seq); url='/prod/prodUpdate.do'; okmsg='💾 수정 완료'; }
  else   { url='/prod/prodInsert.do'; okmsg='＋ 등록 완료'; }

  /* ★재고 증감 — 수정 창에서 재고 칸을 고쳤으면 상품 저장 **뒤에** 조정을 보낸다.
       (stockAdj 와 같은 순서 : 입수수량이 먼저 저장돼야 조정 이력에 새 입수수량이 박힌다)
     ★재고는 잘못 건드리면 티가 안 나므로, 0 이 아니면 저장 전에 한 번 묻는다. */
  var stkDiff=(seq&&_stk)?pcStkDiff():0;

  var go=function(){
  fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('실패 (HTTP '+r.status+'): '+(r.t||'').slice(0,120),'err'); return; }
      if(!stkDiff){ pcClose(); toast(okmsg,'ok'); pcLoad(); return; }
      /* 재고 조정 — 재고 일괄조정의 저장 엔드포인트 그대로. 차이만큼 조정행(A)+이력이 남는다. */
      fetch(CTX+'/prod/stockAdjSave.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin',
          body: JSON.stringify({ baseDt:_todayYmd(), remark:gv('s_rmk')||'상품코드등록에서 조정',
            rows:[{ prodSeq:Number(seq), prodCd:cd, packQty:pcStkPack(),
                    befQty:_stk.curQty, befBox:_stk.box, befEa:_stk.ea,
                    aftBox:Number(gv('s_bx'))||0, aftEa:Number(gv('s_ea'))||0 }] }) })
        .then(function(res){ return res.json(); })
        .then(function(d){
          if(!d||d.result!=='OK'){ alertBox('상품은 저장됐지만 <b>재고 조정은 실패</b>했습니다.<br>'+esc((d&&d.message)||''),'⚠️'); }
          else toast('💾 수정 + 재고 조정('+(stkDiff>0?'+':'')+stkDiff+') 완료','ok');
          pcClose(); pcLoad();
        })
        .catch(function(e){ alertBox('상품은 저장됐지만 <b>재고 조정은 실패</b>했습니다.<br>'+esc(e&&e.message||''),'⚠️'); pcClose(); pcLoad(); });
    })
    .catch(function(e){ toast('통신오류: '+e.message,'err'); });
  };

  if(stkDiff){
    var aft=(Number(gv('s_bx'))||0)*pcStkPack()+(Number(gv('s_ea'))||0);
    confirmBox('재고를 <b>'+_stk.curQty+' → '+aft+'</b> (증감 <b>'+(stkDiff>0?'+':'')+stkDiff+'</b>) 로 조정합니다.<br>'
             + '차이만큼 조정 이력이 남고, 재고 일괄조정의 [조정 이력]에서 되돌릴 수 있습니다.', go, '저장', '💾');
    return;
  }
  go();
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
  /* ★코드 관계를 **양쪽 다** 싣는다 (2026-08-17 요청) — 화면에서 보이는 것이 엑셀에도 있어야 한다.
       · 구분 / 주코드      : 이 줄이 **다른 주코드의 서브**면 '서브' 와 그 주코드·상품명
       · 서브코드(참고 품목코드) : 이 줄에 **붙여 둔 서브코드**들(여러 개면 줄바꿈으로)
     ⇒ 한 파일에서 「이건 누구의 서브인가」와 「내 서브는 누구인가」가 같이 읽힌다. */
  function subsOf(seq){
    return MC.filter(function(x){ return String(x.prodSeq)===String(seq); })
             .map(function(x){ return x.extItemCd + (x.extItemNm?(' '+x.extItemNm):''); });
  }
  var head=['코드','구분','주코드','주상품명','서브코드(참고 품목코드)',
            '상품명','규격','제조사','유형','과세','입수수량','입고단가','판매단가','도매단가','적정재고','판매기본수량','낱개바코드','박스바코드','조회순서'];
  var aoa=[head].concat(list.map(function(o){
    var sb=_subOf[String(o.prodCd)], mp=sb?(_byseq[sb.prodSeq]||{}):{};
    var mine=subsOf(o.prodSeq);
    return [o.prodCd, sb?'서브':'', sb?sb.prodCd:'', sb?(mp.prodNm||''):'', mine.join('\n'),
            o.prodNm,o.spec,o.makerNm,o.typeNm,o.taxGb,o.packQty,o.inPrice,o.salePrice,o.wholePrice,o.safeStock,o.saleBaseQty,o.unitBarcode,o.boxBarcode,o.sortOrd];
  }));
  var P=window.parent;
  function byLib(LIB){
    var ws=LIB.utils.aoa_to_sheet(aoa);
    /* 코드 / 구분 / 주코드 / 주상품명 / 서브코드 … 앞 5칸이 새로 늘었다(2026-08-17) */
    ws['!cols']=[{wch:14},{wch:6},{wch:14},{wch:36},{wch:40},
                 {wch:44},{wch:16},{wch:14},{wch:16},{wch:6},{wch:8},{wch:11},{wch:11},{wch:11},{wch:9},{wch:9},{wch:16},{wch:16},{wch:9}];
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
var MC=[], VEN=[], _mcCnt={}, _mcCur=null, _mcAll=false, _subOf={};   // _subOf = 서브코드 → 그 주코드 통보줄   // _mcAll = 전체 보기 모드

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
      MC=(j&&j.data)||[]; _mcCnt={}; _subOf={};
      MC.forEach(function(o){
        if(o.prodSeq!=null) _mcCnt[o.prodSeq]=(_mcCnt[o.prodSeq]||0)+1;
        /* ★서브코드 지도 (2026-08-17 요청) — 상품마스터에 **서브코드로도 등록된** 코드가 있다.
           그 줄에 「이건 어느 주코드의 서브다」를 매입등록 검색과 **같은 모양**으로 적어 준다.
           자기 자신(서브=주)은 뺀다 — 알려 줄 것이 없다. */
        if(o.prodCd && o.extItemCd && String(o.extItemCd)!==String(o.prodCd)) _subOf[String(o.extItemCd)]=o;
      });
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
  mcStopSync();                            // ★중지된 상품이면 여기서 바로 잠긴다(2026-08-19)
  mcCdInfo();                              // 친 코드가 남아 있으면 표시도 다시 맞춘다
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
  /* 품목명 칸을 줄이고, 남는 폭은 맨 끝 빈 칸(sp)이 먹는다 (2026-08-02 요청).
     ★품목명에 폭만 주면 소용없다 — table{width:100%} 이라 남는 폭이 제일 긴 칸(품목명)으로 다시 몰린다. */
  /* ★[2026-08-17 재요청 「주코드, 상품명 삭제」] **이 상품만 모드에서는 두 칸을 뺀다** —
     이 모드는 고른 상품 하나의 것만 보여 주므로 줄마다 **같은 주코드·상품명이 되풀이**됐고,
     그 값은 이미 **패널 머리줄**(📌 매칭코드 9904013213 은박보냉팩…)에 있다.
     ⇒ 남는 폭은 품목명(400→560)이 먹어 실제로 봐야 할 칸이 넓어진다.
   ⚠**전체 보기 모드(HEAD_ALL)는 그대로 둔다** — 여러 상품이 섞여 나오므로
     「이 줄이 어느 상품 것인지」를 지우면 읽을 수 없다. */
  var HEAD_ONE='<tr>'
    +'<th style="width:150px">거래처</th><th style="width:130px">품목코드</th><th style="width:560px">품목명</th>'
    +'<th style="width:175px">규격</th><th class="r" style="width:90px">단가</th>'
    +'<th style="width:100px">받은날</th><th style="width:150px">비고</th><th style="width:64px">관리</th><th class="sp"></th></tr>';
  var HEAD_ALL='<tr><th style="width:120px">상품코드</th><th style="width:230px">상품명</th>'
    +'<th style="width:150px">거래처</th><th style="width:130px">품목코드</th><th style="width:500px">품목명</th>'
    +'<th style="width:175px">규격</th><th class="r" style="width:90px">단가</th>'
    +'<th style="width:100px">받은날</th><th style="width:64px">관리</th><th class="sp"></th></tr>';
  function row(o, all){
    // 거래처를 안 고른 줄 = 어느 거래처에도 매이지 않은 코드 → '신규코드'로 표시(값은 빈 값으로 저장)
    //   ★esc() 로 감싸면 태그가 글자로 보인다 — 태그는 밖에 두고 값만 esc 한다
    var vn=o.vendorNm||mcVenNm(o.vendorCd)||o.vendorCd||'';
    var h='<tr'+(all?(' style="cursor:pointer" onclick="mcGoProd('+o.prodSeq+')"'):'')+'>';
    /* ★상품코드·상품명 칸은 **전체 보기에서만** 적는다(2026-08-17 「주코드, 상품명 삭제」) —
       이 상품만 모드에서는 같은 값이 줄마다 되풀이돼 지웠다(값은 패널 머리줄에 있다). */
    if(all){
      var pm=_byseq[o.prodSeq]||{};
      h+='<td class="code">'+esc(o.prodCd||pm.prodCd||'')+'</td>'
        +'<td>'+esc(pm.prodNm||'')+'</td>';
    }
    h+='<td>'+(vn ? esc(vn) : '<span style="color:#9aa7b3">신규코드</span>')+'</td>'
      +'<td class="code">'+esc(o.extItemCd)+'</td><td>'+esc(o.extItemNm)+'</td>'
      +'<td>'+esc(o.extSpec)+'</td><td class="num">'+num(o.extPrice)+'</td>'
      +'<td>'+esc(mcFmtDt(o.notiDt))+'</td>';
    if(!all) h+='<td>'+esc(o.remark)+'</td>';
    h+='<td><button class="btn btn-danger" style="height:26px;padding:0 9px;font-size:11.5px"'
      +' onclick="event.stopPropagation();mcDel('+o.extSeq+')">삭제</button></td><td class="sp"></td></tr>';
    return h;
  }
  if(_mcAll){
    th.innerHTML=HEAD_ALL;
    tb.innerHTML = MC.length ? MC.map(function(o){ return row(o,true); }).join('')
                             : '<tr><td colspan="10" class="empty">등록된 매칭코드가 없습니다.</td></tr>';
    return;
  }
  th.innerHTML=HEAD_ONE;
  if(!_mcCur){ tb.innerHTML='<tr><td colspan="9" class="empty">위 목록에서 상품 줄을 고르세요.'
    +' <span style="color:#5a6b7a">— 등록된 것을 다 보려면 [📋 전체 보기]</span></td></tr>'; return; }
  var l=MC.filter(function(o){ return String(o.prodSeq)===String(_mcCur.prodSeq); });
  if(!l.length){ tb.innerHTML='<tr><td colspan="9" class="empty">이 상품에 붙여 둔 거래처 코드가 없습니다 — 아래에서 등록하세요.'
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
/* ★[2026-08-18] **화면에 보여 준 코드로 찾아간다**(cd 인수 신설) —
     「주코드를 누르면 다른 코드로 간다」는 신고가 있었다. 자료는 정상이었다(통보줄의 prodSeq↔prodCd
     어긋남 **0건** 실측). 그래도 ***보여 준 코드와 도착지가 다를 여지***를 아예 없애는 편이 낫다 :
       · 코드를 받으면 **지금 목록(LIST)에서 그 코드의 줄을 찾아** 그 seq 로 간다
       · 코드가 없거나 목록에 없으면 종전처럼 seq 로 간다(옛 호출도 그대로 동작)
   ⇒ ***눈에 보인 코드 = 도착한 코드*** 가 보장된다. */
/* 서브 배지의 주코드 링크 — **위임 처리**(2026-08-18). 표를 다시 그려도 다시 걸 필요가 없다.
   ★행 클릭(pcSel)으로 번지지 않게 stopPropagation·preventDefault 를 여기서 한 번에 처리한다. */
(function pcSubGoBind(){
  document.addEventListener('click', function(ev){
    var a=ev.target && ev.target.closest ? ev.target.closest('a.subgo') : null;
    if(!a) return;
    ev.preventDefault(); ev.stopPropagation();
    mcGoProd(Number(a.getAttribute('data-seq'))||null, a.getAttribute('data-cd')||'');
  }, true);   // ★캡처 단계 — 행 클릭 핸들러보다 먼저 잡아야 선택이 엉키지 않는다
})();
/* ★[2026-08-18 요청 「클릭하면 화면이 바뀐다 — 고정이어야 한다」 · 세 번째 신고]
     서브 배지의 주코드를 누를 때 화면이 움직이는 곳은 **세 군데**였다. 셋 다 끊는다 :
       ① `scrollIntoView` — ***스크롤되는 조상을 전부*** 굴린다(이 화면은 iframe 안이라 바깥 셸까지).
       ② 목록(.card) 스크롤 — 주코드 줄로 굴리면 ***보던 자리를 잃는다.*** 2,001건이라 한참 멀다.
       ③ 하단 매칭코드 패널 — mcPickProd 가 **접혀 있으면 펼친다**(44px → 46vh). 목록 높이가
          통째로 줄어 「화면이 확 바뀐 것」의 실제 몸통이었다. ***사용자가 접어 둔 것은 접힌 채 둔다.***
   ⇒ 이제 이 클릭이 바꾸는 것은 **선택된 줄과 하단 매칭코드 내용뿐**이다 — 스크롤·패널은 그대로.
   ⚠되돌리려면(다시 그 줄로 굴러가게) _pick 안에서 .card 의 scrollTop 을 옮기면 된다. */
function mcGoProd(seq, cd){
  if(cd){
    for(var i=0;i<LIST.length;i++){
      if(String(LIST[i].prodCd)===String(cd)){ seq=LIST[i].prodSeq; break; }
    }
  }
  if(seq==null) return;
  _mcAll=false; document.getElementById('mcAllBtn').textContent='📋 전체 보기';
  /* ★접어 둔 하단 패널은 접힌 채로 (2026-08-18) — mcPickProd 가 안에서 펼치므로 전후를 비교해 되돌린다.
     ★행을 직접 누를 때(pcSel)는 종전대로 펼친다 — 그건 「이 상품 매칭코드를 보겠다」는 뜻이라 펼치는 게 맞다. */
  var mcEl=document.getElementById('mc'), wasMin=!!(mcEl && mcEl.classList.contains('min'));
  _sel=seq; mcPickProd(seq);
  if(wasMin && mcEl && !mcEl.classList.contains('min')) mcToggle();
  /* ★[2026-08-18] 그 줄이 화면에 없으면 **필터를 풀어 데려온다**(사용자 지적 「선택이 없어짐」) —
       주코드는 검색어·과세탭·매칭·중지 조건에 걸려 목록에서 빠져 있기 쉽다(예: '99' 로 검색해 서브코드
       줄만 보고 있는 상태). 종전에는 「목록 밖에 있습니다」 안내만 띄우고 **선택이 풀린 채로 끝났다.**
     ⇒ 조건을 지우고 다시 그린 뒤 그 줄을 고른다. ***'이동'이라고 했으면 실제로 이동해야 한다.***
     ⚠필터를 건드렸다는 사실은 알려 준다 — 사용자가 걸어 둔 조건이 말없이 사라지면 그게 또 혼란이다. */
  function _pick(){
    var sr=document.querySelector('#tb tr[data-seq="'+seq+'"]');
    if(!sr) return false;
    Array.prototype.forEach.call(document.querySelectorAll('#tb tr.sel'),function(r){ r.classList.remove('sel'); });
    sr.classList.add('sel');   // ★굴리지 않는다 — 보던 자리를 그대로 둔다(위 ② 참고)
    return true;
  }
  /* ★화면이 안 움직이니 **골랐다는 사실을 글로 알려 준다** — 안 그러면 누른 티가 안 난다.
       (하단 매칭코드 줄도 그 상품으로 바뀌지만, 접어 둔 상태면 그것마저 안 보인다.) */
  if(_pick()){ toast('주코드 '+(cd||seq)+' 을 선택했습니다 — 하단 매칭코드가 그 상품으로 바뀌었습니다.','ok'); return; }
  /* 조건 해제 — 검색어 · 과세탭 · 매칭 · 중지 */
  var cleared=[];
  var qEl=document.getElementById('q');
  if(qEl && qEl.value.trim()){ cleared.push('검색어'); qEl.value=''; }
  if(_tax){ cleared.push('과세 탭'); pcTab(''); }          // pcTab 이 안에서 pcFilter 까지 부른다
  var fm=document.getElementById('fMc'), fs=document.getElementById('fStop');
  if(fm && fm.value){ cleared.push('매칭 조건'); fm.value=''; }
  if(fs && fs.value){ cleared.push('중지 조건'); fs.value=''; }
  pcFilter();                                              // 조건을 지운 상태로 다시 그린다
  if(_pick()){
    if(cleared.length) toast('주코드로 이동하려고 '+cleared.join('·')+'을 해제했습니다.','warn');
    return;
  }
  toast('주코드 줄을 목록에서 찾지 못했습니다 — 조회를 다시 해 보세요.','warn');
}
/* ==================== 품목코드 칸 — 상품코드 검색 (2026-08-02 요청) ====================
   잘못 만들어진 코드를 제 주코드 밑으로 정리하는 작업용이다.
     ① 칸을 누르면 바로 열리고, 창 안 검색칸으로 상품마스터를 좁혀 본다(코드 앞부분 → 코드 포함 → 상품명 포함)
     ② 줄을 고르면 **품목코드·품목명·규격**이 그 줄 값으로 채워진다 (= 붙일 코드를 받아 적는 것)
     ③ 친 코드가 이미 다른 상품 매칭코드거나 상품마스터에도 있으면 맨 위에 알림 줄(누르는 자리 아님)
   ★붙일 상품은 언제나 **위 목록에서 고른 상품**이다 — 이 창은 대상 상품을 바꾸지 않고, 위 목록도 움직이지 않는다
     (2026-08-02 확정: "상단 선택코드에 매칭코드로 넣어야 함 · 정리는 상단에서").
   ★검색은 이미 받아 둔 LIST(상품 전체)·MC(매칭코드 전체)만 본다 — 서버를 다시 부르지 않는다. */
var _acRows=[], _acIdx=-1, AC_MAX=200, _acLock=false;   // AC_MAX = 한 번에 그릴 줄 수(1,941건 전부 그리면 열 때마다 버벅인다)
function mcAcOpened(){ var d=document.getElementById('a_ac'); return !!(d && d.style.display!=='none'); }
/* 상품을 고른 뒤·등록 직후에 커서를 품목코드 칸으로 돌려놓는데, 그냥 focus() 하면
   onfocus 가 창을 도로 연다. 그 한 번만 막는다(_acLock). */
function mcAcFocusCd(){
  _acLock=true;
  var el=document.getElementById('a_cd'); if(el) el.focus();
  setTimeout(function(){ _acLock=false; }, 0);
}
function mcAcHide(){
  _acRows=[]; _acIdx=-1;
  var d=document.getElementById('a_ac'); if(d){ d.style.display='none'; d.innerHTML=''; }
}
/* 칸을 클릭(또는 포커스)하면 바로 연다 — 글자를 안 쳐도 전 상품이 보인다.
   창 안의 검색칸으로 좁혀 간다. 창을 다시 그릴 때 검색칸을 새로 만들면 타이핑 중 포커스가 튀므로
   껍데기(검색칸)는 한 번만 만들고 목록(.ac-b)만 다시 그린다. */
function mcAcOpen(){
  if(_acLock) return;
  var d=document.getElementById('a_ac'); if(!d) return;
  if(mcAcOpened()) return;                 // 이미 열려 있으면 그대로 둔다(검색어·스크롤 유지)
  d.innerHTML='<div class="ac-s"><span class="lb">주상품 찾기</span>'
    + '<input id="ac_q" autocomplete="off" placeholder="상품코드 · 상품명으로 검색"'
    + ' oninput="mcAcBody()" onkeydown="mcAcKey(event)"></div>'
    + '<div class="ac-b" id="ac_b"></div>';
  d.style.display='';
  var q=document.getElementById('ac_q'); if(q) q.value=gv('a_cd');   // 이미 친 코드가 있으면 그걸로 시작
  mcAcBody();
}
/* ★★[2026-08-19 요청] **거래중지(중지일 있는) 상품에는 매칭코드를 붙이지 못하게 막는다.**
     「앞으로 안 쓰는 코드」에 새 이름표를 달면 그 코드로 오는 자료가 다시 그 상품으로 살아난다.
   ★막는 자리는 두 곳 —
       ① 눈으로 : [＋ 등록] 을 잠그고 **왜** 잠겼는지 옆에 적는다(mcStopSync)
       ② 실제로 : mcAdd 에서 한 번 더 본다 — [＋ 등록] 도 Enter 도 결국 그 함수를 지난다
   ★풀리는 길은 위 목록의 [▶ 거래해제] — 해제하면 목록을 다시 읽으면서 잠금도 같이 풀린다. */
function mcCurLive(){ return _mcCur ? (_byseq[_mcCur.prodSeq]||_mcCur) : null; }
function mcStopped(){ var c=mcCurLive(); return !!(c && c.stopYn==='Y'); }
function mcStopSync(){
  var b=document.getElementById('a_addBtn'), m=document.getElementById('a_msg');
  if(!b) return;
  var st=mcStopped(), c=mcCurLive();
  if(!_mcSaving){ b.disabled=st; b.style.opacity=st?'.5':''; }   /* 저장 중이면 _mcBusy 가 임자다 */
  b.title=st?'거래중지된 상품이라 매칭코드를 등록할 수 없습니다':'';
  if(!m) return;
  if(st){
    m.innerHTML='<span style="color:#c0392b;font-weight:700">⛔ 거래중지된 상품 — 매칭코드를 등록할 수 없습니다'
      + (c && c.stopFrDt ? (' ('+esc(pcFmtDt8(c.stopFrDt))+' 부터)') : '') + '</span>';
  }else if(c){ m.textContent='이 상품에 거래처 코드를 붙입니다.'; }
}
/* ★[2026-08-19 요청] 품목코드 칸에 친 코드가 **상품코드(상품마스터)에 있는 코드인지**를
     칸이름 줄에서 바로 알려 준다.
       · 있으면 : ✔ 그 코드의 상품명(= 주코드 명칭)
       · 없으면 : ⚠ 코드 없음
   ★등록을 막지 않는다 — 거래처가 부르는 코드는 우리 상품코드와 다른 것이 정상이다
     (달라서 매칭코드를 붙인다). 잘못 만들어진 코드를 제 주코드 밑으로 정리할 때
     「이 코드가 우리 마스터에도 있나」를 보려는 것이다.
   ★서버를 부르지 않는다 — 이미 받아 둔 LIST(상품 전체)만 본다. */
function mcCdInfo(){
  var el=document.getElementById('a_cdInfo'); if(!el) return;
  var cd=gv('a_cd');
  if(!cd || !LIST.length){ el.textContent=''; el.removeAttribute('title'); el.style.color=''; return; }   /* ★목록을 아직 못 읽었으면 아무 말도 하지 않는다 — 있는 코드를 '없음'으로 적으면 안 된다 */
  var k=cd.toLowerCase(), p=null, i;
  for(i=0;i<LIST.length;i++){ if(String(LIST[i].prodCd||'').toLowerCase()===k){ p=LIST[i]; break; } }
  if(p && p.stopYn==='Y'){
    /* ★친 코드가 **거래중지된 상품**의 코드면 빨강으로(2026-08-19 「중지된 코드는 빨간색」) —
       초록 ✔ 로 띄우면 멀슐한 코드로 읽혀 중지 사실을 모르고 붙이게 된다. 등록 자체는 안 막는다 —
       막히는 것은 「중지된 상품에 붙이기」지, 중지된 코드를 다른 산 상품의 매칭코드로 다는 것은 정상이다. */
    el.textContent='⛔ '+(p.prodNm||'(이름 없음)')+' (중지'+(p.stopFrDt?(' '+pcFmtDt8(p.stopFrDt)):'')+')';
    el.title='거래중지된 상품의 코드입니다 — '+p.prodCd+' '+(p.prodNm||'');
    el.style.color='#c0392b';
  }else if(p){
    el.textContent='✔ '+(p.prodNm||'(이름 없음)');
    el.title='상품코드(상품마스터)에 있는 코드입니다 — '+p.prodCd+' '+(p.prodNm||'')
           + (p.spec?(' · '+p.spec):'');
    el.style.color='#1f7a4d';
  }else{
    /* ★없는 코드여도 **등록은 된다** (2026-08-19 확정) — 거래처가 부르는 코드는
       우리 상품코드와 다른 것이 정상이다(달라서 매칭코드를 붙인다).
       대신 **어느 주코드에 붙는지**를 같이 적어 잘못 붙이는 것을 그 자리에서 막는다. */
    var t=mcCurLive();
    el.textContent='⚠ 없는 코드'
      + (t ? (' → '+(t.prodCd||'')+' '+(t.prodNm||'')+' 에 등록') : '');
    el.title='상품코드(상품마스터)에는 없는 코드입니다 — 그대로 등록됩니다.'
           + (t ? ('\n붙을 주코드 : '+(t.prodCd||'')+' '+(t.prodNm||'')) : '');
    el.style.color='#c0392b';
  }
}
/* 품목코드 칸에 글자를 치면 — 경고(정확히 같은 코드)와 후보를 그 글자로 다시 맞춘다 */
function mcAcTyped(){
  mcCdInfo();                              // ★코드가 바뀌었으니 표시도 같이 (2026-08-19)
  if(!mcAcOpened()){ mcAcOpen(); return; }
  var q=document.getElementById('ac_q'); if(q) q.value=gv('a_cd');
  mcAcBody();
}
function mcAcBody(){
  var b=document.getElementById('ac_b'); if(!b) return;
  var code=gv('a_cd').toLowerCase();                                   // 등록하려는 거래처 코드(경고 판정용)
  var qe=document.getElementById('ac_q'), ql=((qe&&qe.value)||'').trim().toLowerCase();   // 창 안 검색어
  var i, h='', rows=[];
  /* (1) 경고 — 품목코드 칸의 값이 '정확히 같을' 때만. 부분일치까지 경고하면 타이핑 내내 뜬다.
         ★알림 줄일 뿐 누르는 자리가 아니다 — 여기 적힌 상품은 '주코드'라서, 눌러서 채우면
           붙일 코드가 주코드로 바뀌어 버린다(반대로 등록됨). */
  if(code){
    for(i=0;i<MC.length;i++){
      if(String(MC[i].extItemCd||'').toLowerCase()!==code) continue;
      var m=MC[i], mp=_byseq[m.prodSeq]||{}, mine=(_mcCur && String(m.prodSeq)===String(_mcCur.prodSeq));
      h+='<div class="ac-w dup nohit">'
        + (mine ? '⚠ 이 상품에 이미 등록된 매칭코드입니다 (중복 등록 안 됨)'
                : ('⚠ 이미 매칭코드로 등록됨 — 주코드 '+esc(m.prodCd||mp.prodCd||'')+' '+esc(mp.prodNm||'')
                   + ' <span style="color:#9aa7b3">(옮기려면 그 주코드에서 삭제한 뒤 여기에 등록)</span>'))
        + '</div>';
    }
    for(i=0;i<LIST.length;i++){
      if(String(LIST[i].prodCd||'').toLowerCase()!==code) continue;
      h+='<div class="ac-w nohit">⚠ 이 코드는 상품마스터에도 있는 코드입니다 — '
        + esc(LIST[i].prodCd)+' '+esc(LIST[i].prodNm||'')+'</div>';
      break;
    }
  }
  /* (2) 목록 — 검색어가 없으면 전 상품(앞 AC_MAX건). 있으면 코드 앞부분 → 코드 포함 → 상품명 포함 순 */
  var cand;
  if(!ql){ cand=LIST.slice(0); }
  else {
    var a=[], b2=[], c=[];
    for(i=0;i<LIST.length;i++){
      var o=LIST[i], cd=String(o.prodCd||'').toLowerCase(), nm=String(o.prodNm||'').toLowerCase();
      if(cd.indexOf(ql)===0) a.push(o); else if(cd.indexOf(ql)>=0) b2.push(o); else if(nm.indexOf(ql)>=0) c.push(o);
    }
    cand=a.concat(b2,c);
  }
  var tot=cand.length, more=Math.max(0, tot-AC_MAX); cand=cand.slice(0, AC_MAX);
  h+='<div class="ac-h">상품 '+tot.toLocaleString()+'건'+(more?(' 중 앞 '+AC_MAX+'건 — 위 칸에서 더 좁혀 주세요'):'')
    + ' · 고르면 <b>품목코드·품목명·규격</b>이 그 줄 값으로 채워집니다'
    + (_mcCur ? (' → <b>'+esc(_mcCur.prodCd)+'</b> 에 붙습니다') : '') + '</div>';
  if(!tot){ h+='<div class="ac-f">찾는 상품이 없습니다.</div>'; }
  h+=cand.map(function(o){
    rows.push(o.prodSeq);
    var sel=(_mcCur && String(o.prodSeq)===String(_mcCur.prodSeq));
    return '<div class="ac-i'+(sel?' self':'')+'" data-i="'+(rows.length-1)+'" onmousedown="mcAcPick('+o.prodSeq+')">'
      +'<span class="c">'+esc(o.prodCd)+'</span><span class="n">'+esc(o.prodNm||'')+'</span>'
      +'<span class="s">'+(sel?'붙일 상품(자기 자신)':(_mcCnt[o.prodSeq]?('매칭 '+_mcCnt[o.prodSeq]):''))+'</span></div>';
  }).join('');
  h+='<div class="ac-f">붙일 상품은 <b>위 목록에서 고른 상품</b> 그대로입니다 — 이 창은 붙일 코드를 찾는 곳입니다. (Esc 닫기)</div>';
  /* ★목록은 언제나 맨 위부터 — 고른 상품 줄로 스크롤해 두면 '검색하면 그 코드로 따라가는' 느낌이 된다
       (2026-08-02 사용자 지적). 여기서 찾는 것은 붙일 코드지, 붙일 상품이 아니다. */
  _acRows=rows; _acIdx=-1;
  b.innerHTML=h; b.scrollTop=0;
}
/* ★[2026-08-19 요청] 품목코드 칸에서 **Tab·Enter** 를 치면 품목명을 채워 준다.
     · 친 코드가 상품마스터에 **있으면** : 그 코드의 상품명·규격 (검색창에서 고른 것과 같은 값)
     · **없으면** : 위에서 선택한 주코드(_mcCur)의 명칭·규격 — 거래처 코드는 보통 이름도
       안 주고 오므로, 붙을 상품의 이름을 바로 잎어 치는 수고를 된다.
   ★사람이 이미 친 품목명은 **덮지 않는다** — 거래처가 준 이름을 적는 것이 이 칸 본래 용도다.
     (등록 직후에는 칸이 비니 연달아 받아 적는 흐름에서는 매번 채워진다.) */
function mcCdFill(){
  var cd=gv('a_cd'); if(!cd || gv('a_nm')) return;
  var k=cd.toLowerCase(), p=null, i;
  for(i=0;i<LIST.length;i++){ if(String(LIST[i].prodCd||'').toLowerCase()===k){ p=LIST[i]; break; } }
  var src = p || mcCurLive();          // 마스터에 있으면 그 코드, 없으면 선택한 주코드
  if(!src) return;
  _set('a_nm', src.prodNm||'');
  if(!gv('a_spec')) _set('a_spec', src.spec||'');
  if(!p) toast('없는 코드라 주코드 명칭을 채웠습니다 — '+esc(src.prodCd||'')+' '+esc(src.prodNm||''),'info');
}
function mcAcKey(e){
  var b=document.getElementById('ac_b'), open=(mcAcOpened() && _acRows.length);
  var inQ=(e.target && e.target.id==='ac_q');
  if(e.keyCode===27){ mcAcHide(); mcAcFocusCd(); return; }   // Esc — 그냥 focus() 하면 창이 도로 열린다
  /* ★Tab (2026-08-19) — 품목명을 채우고 창을 닫는다. preventDefault 는 안 한다 —
       초점은 브라우저가 다음 칸(품목명)으로 그대로 옮긴다. 검색창 안(inQ)에서는 안 한다. */
  if(e.keyCode===9 && !inQ){ mcCdFill(); mcAcHide(); return; }
  if(open && (e.keyCode===38 || e.keyCode===40)){                                      // ↑ ↓
    e.preventDefault();
    _acIdx += (e.keyCode===40?1:-1);
    if(_acIdx<0) _acIdx=_acRows.length-1; if(_acIdx>=_acRows.length) _acIdx=0;
    Array.prototype.forEach.call(b.querySelectorAll('[data-i]'), function(el){
      var on=(Number(el.getAttribute('data-i'))===_acIdx);
      el.classList.toggle('on', on); if(on) el.scrollIntoView({block:'nearest'});
    });
    return;
  }
  if(e.keyCode!==13) return;
  /* Enter
       · 창 안 검색칸 : 고른 줄(또는 결과가 하나면 그것)을 선택 — 여기서 등록이 되면 안 된다
       · 품목코드 칸  : 방향키로 고른 줄이 있을 때만 선택, 그 외에는 종전대로 등록
                        (기존 손버릇 = 코드 치고 Enter → 등록. 가로채면 흐름이 끊긴다) */
  if(inQ){
    e.preventDefault();
    if(_acIdx>=0) mcAcPick(_acRows[_acIdx]);
    else if(_acRows.length===1) mcAcPick(_acRows[0]);
    return;
  }
  if(open && _acIdx>=0){ e.preventDefault(); mcAcPick(_acRows[_acIdx]); return; }
  mcCdFill();                          // ★Enter 로 바로 등록할 때도 품목명이 빈 채 들어가지 않게(2026-08-19)
  mcAcHide(); mcAdd();
}
/* 바깥을 누르면 닫는다 — 창 안(검색칸·줄)을 누를 때는 닫히면 안 되므로 blur 로 닫지 않는다 */
document.addEventListener('mousedown', function(e){
  if(!mcAcOpened()) return;
  var w=document.querySelector('#mc .addbar .acwrap');
  if(w && !w.contains(e.target)) mcAcHide();
});
/* 후보를 고르면 = '붙일 코드'를 받아 적는 것 (2026-08-02 확정)
     ★붙일 상품(_mcCur)은 **위에서 고른 상품 그대로** 둔다 — 매칭코드는 언제나 상단 선택 코드에 붙는다.
       (잘못 만들어진 코드 정리는 위 목록에서 상품을 골라 가며 한다)
     ★위 목록도 건드리지 않는다 — 페이지를 넘기거나 그 줄로 스크롤하면 보고 있던 자리를 잃는다.
     여기서 고른 상품의 코드·상품명·규격이 등록 줄(품목코드·품목명·규격)로 들어온다. */
function mcAcPick(seq){
  mcAcHide();
  var o=(seq==null)?null:_byseq[seq];
  if(!o){ toast('상품마스터에서 찾을 수 없는 줄입니다.','warn'); mcAcFocusCd(); return; }
  if(!_mcCur) toast('위 목록에서 붙일 상품을 먼저 고르세요 — 코드만 채웠습니다.','warn');
  else if(String(o.prodSeq)===String(_mcCur.prodSeq)) toast('붙일 상품과 같은 코드입니다 — 확인하세요.','warn');
  _set('a_cd', o.prodCd||'');
  _set('a_nm', o.prodNm||'');
  _set('a_spec', o.spec||'');
  mcCdInfo();                              // 고른 줄은 상품마스터 것이니 ✔ 로 바뀐다
  mcAcFocusCd();
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
/* ★"이미 등록되어 있다는데 이 상품엔 아무것도 없다" (2026-08-06 지적 — 원인은 그 코드를 다른 주코드에 넣어 둔 것)
     같은 (거래처 + 품목코드)는 표 전체에 한 건뿐이라 서버가 409 로 막는데,
     하단 표는 **고른 상품 것만** 보여 준다 — 그 코드가 다른 주코드에 붙어 있으면
     화면은 비어 있는 채 "이미 등록"만 떠서 어디 있는지 알 길이 없었다.
     → 종전 메시지 뒤에 **어느 주코드에 붙어 있는지**를 붙여 준다(MC = 전 건이라 서버를 더 부르지 않는다). */
function mcFindDup(cd, ven){
  var k=String(cd||'').trim().toLowerCase(), v=String(ven||'');
  for(var i=0;i<MC.length;i++){
    if(String(MC[i].extItemCd||'').trim().toLowerCase()!==k) continue;
    if(String(MC[i].vendorCd||'')!==v) continue;      // 거래처가 다르면 별개 코드다
    return MC[i];
  }
  return null;
}
/* 종전 메시지 + 붙어 있는 주코드. 상품에 안 붙은 줄(주코드 없음)도 알려 준다 */
function mcDupMsg(cd, dup){
  var m='이미 등록된 품목코드입니다 — '+esc(cd);
  if(!dup) return m;
  if(String(dup.prodSeq)===String((_mcCur||{}).prodSeq)) return '이 상품에 이미 등록된 품목코드입니다 — '+esc(cd);
  var p=_byseq[dup.prodSeq]||{};
  return m + '<br>' + (dup.prodSeq==null ? '주코드에 붙어 있지 않은 코드입니다 ([📋 전체 보기]에서 확인)'
    : ('주코드 <b>'+esc(dup.prodCd||p.prodCd||'')+'</b> '+esc(dup.prodNm||p.prodNm||'')+' 에 등록돼 있습니다'));
}
/* ═══ 비슷한 품목명 찾기 (2026-08-17 요청) ══════════════════════════════════
   ★코드가 달라도 **같은 물건**을 다른 이름으로 또 등록하는 것이 실제 사고다.
     코드 중복(mcFindDup)은 서버가 막지만, ***이름이 비슷한 것은 아무도 안 막는다.***
   ⇒ 등록 직전에 비슷한 이름을 찾아 **주코드와 함께** 보여 주고 사람이 판단하게 한다(막지는 않는다).
   ★비교는 **정규화 후**에 한다 — 같은 물건인데 띄어쓰기·괄호·쉼표만 다른 경우가 대부분이다.
     예) "아이스컵,14OZ,92Ø(파이)" ↔ "아이스컵 14oz 92파이"  */
function mcNorm(s){
  return String(s||'').toLowerCase()
    .replace(/[\s,.\-_/()\[\]]/g,'')     // 띄어쓰기·구두점은 뜻을 안 바꾼다
    .replace(/파이/g,'ø');               // 같은 것을 두 가지로 쓴다
}
/** 비슷한 이름 후보 — 상품마스터(LIST)와 등록된 매칭코드(MC) 양쪽에서 찾는다. 최대 6건. */
function mcSimilar(nm){
  var q=mcNorm(nm); if(q.length<3) return [];      // 너무 짧으면 아무거나 걸린다
  var out=[], seen={};
  function push(cd, name, why, seq){
    var k=String(cd)+'|'+String(name); if(seen[k]) return; seen[k]=1;
    out.push({cd:cd, nm:name, why:why, seq:seq});
  }
  function hit(a){
    if(!a) return null;
    if(a===q) return '같은 이름';
    if(a.indexOf(q)>=0 || q.indexOf(a)>=0) return '이름이 포함됨';
    /* 앞부분이 길게 같으면 같은 계열 — 품명은 앞에서 갈리는 일이 드물다 */
    var n=Math.min(a.length,q.length,10);
    if(n>=6 && a.slice(0,n)===q.slice(0,n)) return '앞부분이 같음';
    return null;
  }
  for(var i=0;i<LIST.length && out.length<6;i++){
    var w=hit(mcNorm(LIST[i].prodNm));
    if(w) push(LIST[i].prodCd, LIST[i].prodNm, '상품마스터 · '+w, LIST[i].prodSeq);
  }
  for(var j=0;j<MC.length && out.length<6;j++){
    var w2=hit(mcNorm(MC[j].extItemNm));
    if(w2){ var p=_byseq[MC[j].prodSeq]||{};
            push(MC[j].extItemCd, MC[j].extItemNm, '이미 등록된 코드 · 주코드 '+(MC[j].prodCd||p.prodCd||'?'), MC[j].prodSeq); }
  }
  return out;
}
/* ═══ 신규 상품 등록 — 비슷한 상품명 확인 (2026-08-17 요청) ═════════════════════
   ★***신규 등록 순간이 유일한 방어선***이다. 같은 물건을 다른 이름·다른 코드로 또 만들면
     재고가 두 코드로 갈라지고, 이미 거래가 붙은 뒤에는 합칠 방법이 없다.
   ⚠수정 중(f_seq 있음)이면 **자기 자신은 뺀다** — 제 이름과 같다고 알릴 일이 아니다.
   ⚠막지는 않는다. 규격만 다른 별개 품목이 실제로 많다(14oz / 20oz). 판단은 사람이 한다. */
function pcSimFind(nm){
  var q=mcNorm(nm); if(q.length<3) return [];
  var mySeq=String(gv('f_seq')||''), out=[];
  function hit(a){
    if(!a) return null;
    if(a===q) return '같은 이름';
    if(a.indexOf(q)>=0 || q.indexOf(a)>=0) return '이름이 포함됨';
    var n=Math.min(a.length,q.length,10);
    if(n>=6 && a.slice(0,n)===q.slice(0,n)) return '앞부분이 같음';
    return null;
  }
  for(var i=0;i<LIST.length && out.length<8;i++){
    if(mySeq && String(LIST[i].prodSeq)===mySeq) continue;     // 자기 자신
    var w=hit(mcNorm(LIST[i].prodNm));
    if(w) out.push({cd:LIST[i].prodCd, nm:LIST[i].prodNm, why:w, seq:LIST[i].prodSeq});
  }
  /* 같은 이름 → 포함 → 앞부분 순으로 위에 오게 (급한 것부터 읽힌다) */
  var rank={'같은 이름':0,'이름이 포함됨':1,'앞부분이 같음':2};
  out.sort(function(a,b){ return (rank[a.why]||9)-(rank[b.why]||9); });
  return out;
}
function pcSimTell(nm, sim, quiet){
  if(!sim.length){ if(!quiet) toast('비슷한 상품명이 없습니다 — 새 상품으로 보입니다.','ok'); return; }
  /* ★문구는 **사실만** (2026-08-17 지시) — 「그 코드를 쓰세요」 같은 지시문은 뺐다.
     같은 물건인지 아닌지는 화면이 알 수 없고, 판단은 사용자가 한다. */
  /* ★공통 표준 창으로 (2026-08-17 지시 "직관적으로") — 코드는 초록 굵게, 근거는 작은 회색.
     한눈에 「어느 코드와 비슷한가」가 읽히게 한다. */
  alertBox('<div style="text-align:left"><b style="font-size:15px">유사상품 있습니다</b>'
    + ' <span style="color:#8a97a3;font-size:12.5px">('+sim.length+'건)</span>'
    + '<div style="margin-top:10px">'
    + sim.map(function(s){
        return '<div style="padding:6px 0;border-top:1px solid #eef1f4">'
             + '<b style="color:#137a6c">'+esc(s.cd)+'</b> '+esc(s.nm||'')
             + '<div style="font-size:11.5px;color:#9aa7b3">'+esc(s.why)+'</div></div>';
      }).join('')
    + '</div></div>', '🔍');
}
function pcSimShow(){
  var nm=gv('f_nm');
  if(!nm){ toast('상품명을 먼저 입력하세요.','warn'); document.getElementById('f_nm').focus(); return; }
  pcSimTell(nm, pcSimFind(nm), false);
}
/* 칸을 벗어날 때 자동 확인 — 같은 값으로 두 번 알리지 않는다(드나들 때마다 뜨면 못 쓴다).
   없을 때는 조용히 지나간다 — 새 상품을 넣을 때마다 「없습니다」가 뜨면 걸림돌이다. */
var _pcSimLast='';
function pcSimBlur(){
  var nm=gv('f_nm');
  if(!nm){ _pcSimLast=''; return; }
  if(nm===_pcSimLast) return;
  _pcSimLast=nm;
  pcSimTell(nm, pcSimFind(nm), true);
}

/** 유사 품명 결과를 알린다. 공통 — 버튼과 자동확인이 같은 문구를 쓴다. */
function mcSimTell(nm, sim, quiet){
  if(!sim.length){ if(!quiet) toast('비슷한 품목명이 없습니다 — 새 품목으로 보입니다.','ok'); return; }
  /* 문구는 사실만 · 창은 공통 표준 — 상품명 쪽(pcSimTell)과 같은 모양으로 맞춘다(2026-08-17) */
  alertBox('<div style="text-align:left"><b style="font-size:15px">유사품목 있습니다</b>'
    + ' <span style="color:#8a97a3;font-size:12.5px">('+sim.length+'건)</span>'
    + '<div style="margin-top:10px">'
    + sim.map(function(s){
        return '<div style="padding:6px 0;border-top:1px solid #eef1f4">'
             + '<b style="color:#137a6c">'+esc(s.cd)+'</b> '+esc(s.nm||'')
             + '<div style="font-size:11.5px;color:#9aa7b3">'+esc(s.why)+'</div></div>';
      }).join('')
    + '</div></div>', '🔍');
}
/** [🔍 유사 품명] 단추 — 언제든 눌러 본다. 없으면 없다고도 알려 준다. */
function mcSimShow(){
  var nm=gv('a_nm');
  if(!nm){ toast('품목명을 먼저 입력하세요.','warn'); document.getElementById('a_nm').focus(); return; }
  mcSimTell(nm, mcSimilar(nm), false);
}
/* ★품목명을 치고 칸을 벗어날 때 자동 확인 (2026-08-17 지시 — 저장 때가 아니라 **입력 직후**).
   ⚠같은 값으로 두 번 알리지 않는다 — 칸을 드나들 때마다 창이 뜨면 못 쓴다.
   ⚠없을 때는 조용히 지나간다(quiet) — 새 품목을 넣을 때마다 「없습니다」가 뜨면 걸림돌이다. */
var _mcSimLast='';
function mcSimBlur(){
  var nm=gv('a_nm');
  if(!nm){ _mcSimLast=''; return; }
  if(nm===_mcSimLast) return;
  _mcSimLast=nm;
  mcSimTell(nm, mcSimilar(nm), true);
}
function mcAdd(){
  if(_mcSaving) return;                      // 저장이 끝날 때까지는 받지 않는다
  if(!_mcCur){ toast('먼저 위 목록에서 상품을 고르세요.','warn'); return; }
  /* ★★[2026-08-19 요청] 거래중지된 상품은 여기서 막는다 — [＋ 등록]·Enter 둘 다 이 길을 지난다. */
  if(mcStopped()){
    var sc=mcCurLive()||{};
    mcStopSync();
    alertBox('<div style="text-align:left"><b style="font-size:15px">거래중지된 상품입니다</b>'
      + '<div style="margin-top:8px"><b style="color:#137a6c">'+esc(sc.prodCd||'')+'</b> '+esc(sc.prodNm||'')+'</div>'
      + (sc.stopFrDt ? ('<div style="font-size:12.5px;color:#9aa7b3">'+esc(pcFmtDt8(sc.stopFrDt))+' 부터 중지</div>') : '')
      + '<div style="margin-top:10px;font-size:13px">중지된 코드에는 매칭코드를 등록할 수 없습니다.<br>'
      + '붙여야 한다면 위 목록에서 그 상품을 고른 뒤 <b>[▶ 거래해제]</b> 를 먼저 누르세요.</div></div>', '⛔');
    return;
  }
  var cd=gv('a_cd');
  if(!cd){ toast('거래처가 부르는 품목코드를 입력하세요.','warn'); document.getElementById('a_cd').focus(); return; }
  var ven=gv('a_ven');
  var dto={ extItemCd:cd, extItemNm:gv('a_nm')||null, extSpec:gv('a_spec')||null, extUnit:gv('a_unit')||null,
    extPrice:gv('a_price')?Number(gv('a_price')):null,
    vendorCd:ven||null, vendorNm:ven?mcVenNm(ven):null,
    notiDt:gv('a_noti')||null, statGb:'신규', remark:gv('a_remark')||null,
    prodSeq:_mcCur.prodSeq, prodCd:_mcCur.prodCd };
  /* 보내기 전에 전 건에서 찾아 본다 — 있으면 어느 주코드인지까지 적어 돌려준다(서버 호출 없음) */
  var dup=mcFindDup(cd, ven);
  if(dup){ toast(mcDupMsg(cd, dup),'warn'); return; }
  /* ⚠유사 품명 확인은 **저장 때 하지 않는다**(2026-08-17 사용자 지시) —
     품목명을 치고 칸을 벗어날 때(mcSimBlur) 이미 확인했다. 저장 순간에 또 묻으면 걸림돌만 된다. */
  mcSend(dto);
}
function mcSend(dto){
  var cd=dto.extItemCd;
  _mcBusy(true);
  fetch(CTX+'/prod/extItemSave.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){
      _mcBusy(false);
      if(!r.ok){
        /* 409 = 서버가 막은 중복. 화면이 들고 있던 MC 가 낡아 미리 못 잡은 경우다
           (다른 사람이 방금 등록했거나, 목록을 읽은 뒤 바뀐 경우) — 다시 읽어 주코드까지 알려 준다. */
        if(r.status===409){ mcRecheckDup(dto); return; }
        /* ★403 = 서버가 막은 **거래중지** (2026-08-19). 화면이 미리 막지만, 창을 열어 둔 사이에
           다른 사람이 중지했으면 여기로 온다 — 목록을 다시 읽어 화면 잠금도 같이 맞춘다. */
        if(r.status===403){
          alertBox('<div style="text-align:left;white-space:pre-wrap">'+esc((r.t||'거래중지된 상품입니다.').trim())+'</div>','⛔');
          pcLoad(); return;
        }
        toast((r.t||'').trim()||('등록 실패 (HTTP '+r.status+')'),'err'); return;
      }
      // 연달아 받아 적는 흐름 — 코드·품명·규격·단가만 비우고 거래처·받은날은 남긴다
      _set('a_cd',''); _set('a_nm',''); _set('a_spec',''); _set('a_price',''); mcCdInfo();
      toast('＋ 매칭코드 등록 — '+esc(cd),'ok');
      mcAcHide(); mcAcFocusCd();          // 등록 직후에 후보창이 도로 열리지 않게
      mcLoad();
    })
    .catch(function(e){ _mcBusy(false); toast('통신오류: '+e.message,'err'); });
}
/* 서버가 409 를 줬는데 화면에선 못 찾았을 때 — 목록을 새로 읽고 다시 찾아 안내한다 */
function mcRecheckDup(dto){
  fetch(CTX+'/prod/extItemList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){
      MC=(j&&j.data)||[]; _mcCnt={}; _subOf={};
      MC.forEach(function(o){
        if(o.prodSeq!=null) _mcCnt[o.prodSeq]=(_mcCnt[o.prodSeq]||0)+1;
        if(o.prodCd && o.extItemCd && String(o.extItemCd)!==String(o.prodCd)) _subOf[String(o.extItemCd)]=o;
      });
      mcRender();
      pcRender();   // ★그리드의 「서브 → 주코드」 표시도 새로 등록한 코드까지 반영한다
      toast(mcDupMsg(dto.extItemCd, mcFindDup(dto.extItemCd, dto.vendorCd||'')),'warn');
    })
    .catch(function(){ toast('이미 등록된 품목코드입니다 — '+esc(dto.extItemCd),'err'); });
}
function mcDel(seq){
  var o=null; for(var i=0;i<MC.length;i++){ if(String(MC[i].extSeq)===String(seq)){ o=MC[i]; break; } }
  if(!o) return;
  confirmBox('['+esc(o.extItemCd)+'] '+esc(o.extItemNm||'')+'<br>이 매칭코드를 지우시겠습니까?'
    +'<br><span style="color:#9aa7b3;font-size:12px">지우면 이 코드로 오는 자료는 다시 미매핑이 되고,'
    +'<br><b>이미 이 상품에 붙어 있던 과거 출고·정산도 되돌아갑니다</b>(재고 다시 계산 — 몇 초 걸릴 수 있음).</span>', function(){
    fetch(CTX+'/prod/extItemDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({extSeq:Number(seq)}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, t:t}; }); })
      .then(function(r){ if(!r.ok){ toast((r.t||'').trim()||'삭제 실패','err'); return; } toast('🗑️ 삭제 완료','ok'); mcLoad(); })
      .catch(function(e){ toast('통신오류: '+e.message,'err'); });
  });
}
/* 접기/펼치기 — 목록을 넓게 보고 싶을 때. 접으면 그만큼 위 목록이 늘어난다 */
function mcToggle(){
  var el=document.getElementById('mc'), min=el.classList.toggle('min');
  document.documentElement.style.setProperty('--mc-h', min ? '44px' : '46vh');   // 펼침 높이는 CSS 의 --mc-h 와 같아야 한다
  document.getElementById('mcToggleBtn').innerHTML = min ? '&#9652;' : '&#9662;';
}

/* ══════════════════════════════════════════════════════════════════════════
   규격 · 제조사명 입력검색 (2026-08-04 요청) — 상품코드 추가/수정 창 전용
   ─────────────────────────────────────────────────────────────────────────
   왜 : 같은 물건인데 규격을 사람마다 다르게 적으면(`150*200*H35MM` / `150X200X35`)
        한 규격이 여러 개로 갈라져 나중에 묶어 보지 못한다. 그래서 **이미 쓰고 있는 값**을
        먼저 보여 주고 그중에서 고르게 한다. 제조사명은 이미 값이 쌓여 있어 바로 쓸 수 있고,
        규격은 대부분 비어 있어 **여기서부터 채워 나가는 칸**이다.
   ★고르기를 강요하지 않는다 — 목록에 없으면 그냥 치면 그대로 저장된다(새 규격이 그렇게 는다).
   ★원천은 이미 화면에 들어와 있는 LIST(상품마스터 전 건) — 서버를 따로 부르지 않는다.
   ★거래처 매칭코드 줄(mcAc*)과는 별개다 — 그쪽은 손대지 않았다(2026-08-04 "거래처는 제외").
   ══════════════════════════════════════════════════════════════════════════ */
var _uniq={ spec:[], maker:[], ven:[] };   // ven = 거래처(2026-08-17)
function pcUniqBuild(){
  var m={ spec:{}, maker:{} };
  LIST.forEach(function(o){
    var s=(''+(o.spec||'')).trim();    if(s) m.spec[s]  = (m.spec[s]||0)+1;
    var k=(''+(o.makerNm||'')).trim(); if(k) m.maker[k] = (m.maker[k]||0)+1;
  });
  ['spec','maker'].forEach(function(t){
    // 많이 쓰는 값이 위 — 자주 쓰는 것이 손에 가깝게. 건수가 같으면 이름순
    _uniq[t]=Object.keys(m[t]).map(function(v){ return {v:v, n:m[t][v]}; })
      .sort(function(a,b){ return b.n-a.n || (a.v<b.v?-1:(a.v>b.v?1:0)); });
  });
}
var _faEl=null, _faFor=null, _faKind='', _faIdx=-1, _faRows=[];
function pcAcBox(){
  if(_faEl) return _faEl;
  _faEl=document.createElement('div'); _faEl.className='pfac';
  // ★mousedown 을 막아야 한다 — 안 막으면 입력칸 blur 가 먼저 나 목록이 닫히고 클릭이 허공을 친다
  _faEl.addEventListener('mousedown', function(e){ e.preventDefault(); });
  document.body.appendChild(_faEl);
  return _faEl;
}
function pcAcClose(){ if(_faEl) _faEl.classList.remove('on'); _faFor=null; _faIdx=-1; _faRows=[]; }
function pcAcPos(inp){
  var box=pcAcBox(), r=inp.getBoundingClientRect(), below=window.innerHeight-r.bottom;
  box.style.left=r.left+'px';
  // 입력칸보다 좁아지지 않게 + 최소 340px — 값 이름과 건수가 한 줄에 같이 들어가야 한다
  box.style.width=Math.max(r.width, 340)+'px';
  // 아래가 좁으면 위로 편다(창을 아래로 내려 열었을 때)
  if(below<190 && r.top>below){ box.style.top='auto'; box.style.bottom=(window.innerHeight-r.top+4)+'px'; }
  else                        { box.style.bottom='auto'; box.style.top=(r.bottom+4)+'px'; }
}
function pcAcDraw(inp, kind){
  var q=(inp.value||'').trim().toLowerCase(), ws=q?q.split(/\s+/):[];
  // 띄어쓰기로 나눠 AND — 규격은 낱말 순서가 제각각이라 통짜 비교로는 잘 안 걸린다
  _faRows=_uniq[kind].filter(function(o){
    if(!ws.length) return true;
    var lv=o.v.toLowerCase();
    return ws.every(function(w){ return lv.indexOf(w)>=0; });
  }).slice(0,60);
  _faFor=inp; _faKind=kind; _faIdx=-1;
  var lab=(kind==='spec'?'규격':kind==='ven'?'거래처':'제조사명'), box=pcAcBox();
  // ★한 줄에 담기게 짧게 — 길게 쓰면 접혀서 목록 첫 줄을 밀어낸다(2026-08-04 지적)
  var h='<div class="h">'+lab+' '+_uniq[kind].length.toLocaleString()+(kind==='ven'?'곳':'종')
      + (q ? (' · 검색 '+_faRows.length+'건') : '')
      + (kind==='ven' ? ' · 비워두면 등록 안 함' : ' · 없으면 그냥 입력')+'</div><div class="b">';
  if(!_faRows.length) h+='<div class="nohit">맞는 값이 없습니다'
      + (kind==='ven' ? ' — 거래처는 목록에 있는 것만 고를 수 있습니다' : (' — 새 '+lab+'으로 저장됩니다'))+'</div>';
  else _faRows.forEach(function(o,i){
    h+='<div class="i" data-i="'+i+'" onclick="pcAcPick('+i+')">'
      +'<span class="v">'+esc(o.v)+'</span><span class="c">'+(kind==='ven'?'':(o.n+'건'))+'</span></div>';
  });
  box.innerHTML=h+'</div>';
  box.classList.add('on'); pcAcPos(inp);
}
function pcAcMove(d){
  if(!_faRows.length) return;
  _faIdx += d;
  if(_faIdx<0) _faIdx=_faRows.length-1;
  if(_faIdx>=_faRows.length) _faIdx=0;
  var box=pcAcBox();
  Array.prototype.forEach.call(box.querySelectorAll('.i'), function(el){
    var on = (Number(el.getAttribute('data-i'))===_faIdx);
    el.classList.toggle('on', on);
    if(on && el.scrollIntoView) el.scrollIntoView({block:'nearest'});
  });
}
function pcAcPick(i){
  var o=_faRows[i]; if(!o || !_faFor) return;
  var inp=_faFor; inp.value=o.v;
  /* ★거래처는 **코드를 숨은 칸에** 담는다 — 서버에 보내는 값은 이름이 아니라 코드다(2026-08-17) */
  if(_faKind==='ven'){ var h=document.getElementById('f_ven'); if(h) h.value=o.cd||''; }
  pcAcClose(); inp.focus();
}
function pcAcAttach(id, kind){
  var inp=document.getElementById(id); if(!inp) return;
  inp.addEventListener('focus', function(){ pcAcDraw(inp, kind); });
  inp.addEventListener('input', function(){ pcAcDraw(inp, kind); });
  inp.addEventListener('blur',  function(){ setTimeout(pcAcClose, 120); });   // 클릭이 끝날 틈을 준다
  inp.addEventListener('keydown', function(e){
    var open=_faEl && _faEl.classList.contains('on');
    if(e.key==='ArrowDown'){ e.preventDefault(); if(open) pcAcMove(1); else pcAcDraw(inp,kind); }
    else if(e.key==='ArrowUp'){ if(open){ e.preventDefault(); pcAcMove(-1); } }
    // Enter 는 고른 줄이 있을 때만 가로챈다 — 그냥 친 값으로 넘어가려는 것을 막으면 안 된다.
    // ★stopPropagation 필수 — 안 하면 창의 'Enter=다음 칸' 이 이어서 돌아, 고른 값을 볼 새도 없이 넘어간다.
    else if(e.key==='Enter'){ if(open && _faIdx>=0){ e.preventDefault(); e.stopPropagation(); pcAcPick(_faIdx); } }
    // ★Esc 도 마찬가지 — 안 하면 후보창만 닫으려던 Esc 가 창까지 같이 닫는다
    else if(e.key==='Escape'){ if(open){ e.preventDefault(); e.stopPropagation(); pcAcClose(); } }
  });
}
pcAcAttach('f_spec','spec'); pcAcAttach('f_maker','maker');
/* ★거래처도 **같은 입력검색**으로 (2026-08-17) — 목록이 입력칸 바로 아래에 붙는다.
   ⚠거래처는 **목록에 있는 것만** 값이 된다(코드로 바꿔 저장하므로) — 그냥 친 글자는 값이 아니다.
     칸을 지우면 숨은 칸(f_ven)도 비워 「거래처 없음」으로 저장된다. */
pcAcAttach('f_venQ','ven');
(function(){ var e=document.getElementById('f_venQ'); if(!e) return;
  e.addEventListener('input', function(){ if(!e.value.trim()){ var h=document.getElementById('f_ven'); if(h) h.value=''; } });
})();

/* ══════════════════════════════════════════════════════════════════════════
   키보드 편의 (2026-08-04 요청) — 손이 마우스로 안 가게
   ★적용 범위는 「위쪽」뿐이다 : 목록 + 상품코드 추가/수정 창.
     하단 [거래처 매칭코드] 패널은 제외(사용자 지정) — 그쪽은 이미 자체 키 처리(mcAcKey)가 있고,
     아래 두 핸들러 모두 #mc 안에서 눌린 키는 손대지 않고 그대로 흘려보낸다.
   ─────────────────────────────────────────────────────────────────────────
   목록 : 진입 시 검색칸 포커스 · ↑↓ 행 이동(페이지 경계에서 자동으로 앞뒤 장 넘김) · Enter 수정 · Alt+N 추가
   창   : Enter 다음 칸(마지막 칸에서는 저장) · Ctrl+S 저장 · Esc 닫기
   ══════════════════════════════════════════════════════════════════════════ */
function pcOvOpen(){ return document.getElementById('ov').classList.contains('on'); }
function pcInMc(t){ var el=document.getElementById('mc'); return !!(el && t && el.contains(t)); }

/* ── 창 안 이동 순서 = 화면에 보이는 순서(모달이 2단 격자라 DOM 순서와 같다) ──
   ★수정 창은 입수수량(f_pack)이 아래 재고 표 첫 칸으로 옮겨 가므로 순서도 그 자리다 —
     한 배열로 쓰면 Enter 가 유형명 → (아래 표) 입수수량 → (다시 위로) 조회순서 로 널뛴다. */
var PC_FLOW_ADD =['f_cd','f_tax','f_nm','f_spec','f_maker','f_type','f_pack','f_sort',
                  'f_in','f_sale','f_whole','f_safe','f_base','f_ubc','f_bbc'];
var PC_FLOW_EDIT=['f_cd','f_tax','f_nm','f_spec','f_maker','f_type','f_sort',
                  'f_in','f_sale','f_whole','f_safe','f_base','f_ubc','f_bbc',
                  'f_pack','s_bx','s_ea','s_rmk'];         // 재고 표 = 입수수량 → 수정BOX → 수정EA → 사유(마지막 = 저장)
function pcFlow(){ return document.getElementById('stkBox').style.display==='none' ? PC_FLOW_ADD : PC_FLOW_EDIT; }
function pcNext(id){
  var FLOW=pcFlow();
  var i=FLOW.indexOf(id); if(i<0) return null;
  for(var k=i+1;k<FLOW.length;k++){
    var el=document.getElementById(FLOW[k]);
    // 잠긴 칸(수정 시 상품코드)·안 보이는 칸은 건너뛴다 — offsetParent 는 display:none 이면 null
    if(el && !el.readOnly && !el.disabled && el.offsetParent!==null) return el;
  }
  return null;                                             // 마지막 칸 = 저장
}
document.getElementById('ov').addEventListener('keydown', function(e){
  if(e.key!=='Enter') return;
  var t=e.target; if(!t || pcFlow().indexOf(t.id)<0) return;
  // 규격·제조사 후보창에서 줄을 고르는 Enter 는 그쪽이 먼저 먹고 여기까지 오지 않는다(stopPropagation)
  e.preventDefault(); pcAcClose();
  var nx=pcNext(t.id);
  if(nx){ nx.focus(); if(nx.select) nx.select(); }
  else pcSave();                                           // 박스바코드에서 Enter = 저장
});

document.addEventListener('keydown', function(e){
  if(pcInMc(e.target)) return;                             // ★하단 거래처 매칭코드 패널은 제외

  if((e.ctrlKey||e.metaKey) && (e.key==='s'||e.key==='S')){ // 저장 — 창이 떠 있을 때만
    if(pcOvOpen()){ e.preventDefault(); pcSave(); }
    return;
  }
  if(e.altKey && (e.key==='n'||e.key==='N')){ e.preventDefault(); pcOpen(null); return; }   // 새 상품코드
  if(e.key==='Escape' && pcOvOpen()){ e.preventDefault(); pcClose(); return; }
  if(pcOvOpen()) return;                                   // 창이 떠 있으면 아래 목록 조작은 안 한다

  // 목록 조작 — 검색칸(#q)에서는 그대로 먹힌다(검색어 치고 ↓ 로 바로 결과로 내려가라고).
  // 그 밖의 입력칸에 커서가 있으면 손대지 않는다.
  var t=e.target, tag=(t&&t.tagName||'').toUpperCase();
  if((tag==='INPUT'||tag==='SELECT'||tag==='TEXTAREA') && t.id!=='q') return;
  if(e.key==='ArrowDown'){ e.preventDefault(); pcRowMove(1); }
  else if(e.key==='ArrowUp'){ e.preventDefault(); pcRowMove(-1); }
  else if(e.key==='Enter'){
    if(_sel==null){ pcRowMove(1); return; }                // 아직 고른 줄이 없으면 첫 줄부터
    e.preventDefault(); pcOpen(_sel);
  }
});
/* ↑↓ 행 이동 — 이 장의 끝에 닿으면 앞뒤 장으로 넘어가 첫/끝 줄을 잡는다.
   (mcPickProd 는 이미 받아 둔 자료만 보므로 빠르게 눌러도 서버를 부르지 않는다) */
function pcRowMove(d){
  var tb=document.getElementById('tb');
  var rows=Array.prototype.slice.call(tb.querySelectorAll('tr[data-seq]'));
  if(!rows.length) return;
  var i=-1;
  if(_sel!=null) for(var k=0;k<rows.length;k++){ if(rows[k].getAttribute('data-seq')===String(_sel)){ i=k; break; } }
  var n=(i<0) ? (d>0?0:rows.length-1) : i+d;
  if(n<0 || n>=rows.length){
    var pages=Math.max(1,Math.ceil(_view.length/PAGE));
    if(!_all && n<0 && _page>1){ _go(_page-1); pcRowEdge(false); return; }
    if(!_all && n>=rows.length && _page<pages){ _go(_page+1); pcRowEdge(true); return; }
    n=(n<0)?0:rows.length-1;                               // 첫 장 맨 위·끝 장 맨 아래에서는 제자리
  }
  pcSel(rows[n], Number(rows[n].getAttribute('data-seq')));
  if(rows[n].scrollIntoView) rows[n].scrollIntoView({block:'nearest'});
}
function pcRowEdge(first){
  var rows=document.getElementById('tb').querySelectorAll('tr[data-seq]');
  if(!rows.length) return;
  var tr=first?rows[0]:rows[rows.length-1];
  pcSel(tr, Number(tr.getAttribute('data-seq')));
  if(tr.scrollIntoView) tr.scrollIntoView({block:'nearest'});
}
/* 창 본문을 스크롤하면 입력칸이 움직인다 — 붙어 있던 목록도 같이 따라가야 한다 */
(function(){
  var mb=document.querySelector('#ov .mb');
  if(mb) mb.addEventListener('scroll', function(){ if(_faFor) pcAcPos(_faFor); });
  window.addEventListener('resize', function(){ if(_faFor) pcAcPos(_faFor); });
})();

pcLoad(); mcVendors(); mcLoad(true);
/* 진입하면 검색칸에 커서 — 코드를 쳐서 찾는 것이 이 화면의 첫 동작이다(2026-08-04) */
(function(){ var q=document.getElementById('q'); if(q) q.focus(); })();

/* ═══ ♻ 삭제 목록 · 되살리기 (2026-08-17 요청) ═══════════════════════════
   ★삭제가 소프트 삭제라 **되살리기는 값 하나를 'Y' 로 되돌리는 것**뿐이다.
     그래서 복원 표도 백업도 필요 없다. 서버가 ACTION_YN='N' 인 것만 되돌린다. */
var RC=[];
function rcOpen(){
  document.getElementById('rc').classList.add('on');
  document.getElementById('rcTb').innerHTML='<tr><td colspan="9" class="empty">불러오는 중…</td></tr>';
  fetch(CTX+'/prod/prodDeletedList.do',{method:'POST',credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'findData='})
    .then(function(r){return r.json();})
    .then(function(j){ RC=(j&&j.data)||[]; rcRender(); })
    .catch(function(){ document.getElementById('rcTb').innerHTML='<tr><td colspan="9" class="empty">불러오지 못했습니다.</td></tr>'; });
}
function rcClose(){ document.getElementById('rc').classList.remove('on'); }
function rcRender(){
  var q=(document.getElementById('rcQ').value||'').toLowerCase();
  var l=RC.filter(function(o){
    if(!q) return true;
    return [o.prodCd,o.prodNm,o.spec,o.makerNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  });
  document.getElementById('rcCnt').textContent=l.length+'건';
  document.getElementById('rcTb').innerHTML = l.length ? l.map(function(o){
    /* 줄임표로 접히므로 전체 글자는 title 로 본다(마우스를 올리면 뜬다) */
    return '<tr><td class="code" title="'+esc(o.prodCd)+'">'+esc(o.prodCd)+'</td>'
      +'<td title="'+esc(o.prodNm)+'">'+esc(o.prodNm)+'</td>'
      +'<td title="'+esc(o.spec)+'">'+esc(o.spec)+'</td>'
      +'<td title="'+esc(o.makerNm)+'">'+esc(o.makerNm)+'</td>'
      +'<td class="num">'+num(o.inPrice)+'</td><td class="num">'+num(o.salePrice)+'</td>'
      +'<td>'+esc(o.updDttm||'')+'</td><td>'+esc(o.updUser||'')+'</td>'
      +'<td><button class="btn btn-teal" style="height:26px;padding:0 10px;font-size:11.5px"'
      +' onclick="rcRestore('+o.prodSeq+')">되살리기</button></td></tr>';
  }).join('') : '<tr><td colspan="9" class="empty">'+(q?'검색 결과가 없습니다.':'삭제한 상품코드가 없습니다.')+'</td></tr>';
}
function rcRestore(seq){
  var o=null; for(var i=0;i<RC.length;i++){ if(String(RC[i].prodSeq)===String(seq)){ o=RC[i]; break; } }
  if(!o) return;
  if(!confirm('['+o.prodCd+'] '+(o.prodNm||'')+'\n\n이 상품코드를 되살릴까요?')) return;
  fetch(CTX+'/prod/prodRestore.do',{method:'POST',credentials:'same-origin',
      headers:{'Content-Type':'application/json'},body:JSON.stringify({prodSeq:seq})})
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
    .then(function(){
      toast('되살렸습니다 — '+o.prodCd,'ok');
      RC=RC.filter(function(x){ return String(x.prodSeq)!==String(seq); });
      rcRender();
      pcLoad();     /* ★목록을 다시 읽는다 — 안 하면 되살렸는데 화면에 안 보인다 */
    })
    .catch(function(e){ toast(e.message||'되살리지 못했습니다.','err'); });
}


/* ═══ 거래중지 (2026-08-17 요청) ══════════════════════════════════════════════
   ★거래가 붙은 코드는 **지울 수 없다**(매입가·판매가 이력·재고 원장이 막는다). 지워서도 안 된다 —
     지우면 그 원장 행이 주인 없는 자료가 된다.
   ⇒ 지우는 대신 「앞으로 안 쓰는 코드」로 표시한다. ***옛 전표·재고는 그대로 유지***되고,
     매입등록·판매등록에서만 막힌다(서버 stopBlockMsg 가 전표일자로 판정).
   ★중지 시작일을 받는다 — 「언제부터 중지인지」가 있어야 지난 전표를 잘못 막지 않는다. */
function pcFmtDt8(d){ d=String(d||''); return d.length===8 ? d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8) : d; }
function pcStopSel(){
  if(!_sel){ toast('목록에서 상품을 먼저 고르세요.','warn'); return; }
  var o=_byseq[_sel]||{};
  if(o.stopYn==='Y'){                                  // 이미 중지 → 해제를 묻는다
    confirmBox('['+esc(o.prodCd)+'] '+esc(o.prodNm||'')
      +'<br><br>거래중지를 <b>해제</b>할까요?<br><span style="font-size:12.5px;color:#5b6b7a">다시 매입·판매에 쓸 수 있게 됩니다.</span>',
      function(){ pcStopSend('/prod/prodUnstop.do', {prodSeq:o.prodSeq}, '거래중지를 해제했습니다'); },
      '거래해제', '▶');   // ★[삭제] 가 아니라 [거래해제] — 하는 일을 단추가 말한다
    return;
  }
  /* ★prompt 대신 창으로 (2026-08-17 지시) — **중지일만** 받는다. 사유는 묻지 않는다. */
  var d=new Date();
  document.getElementById('spWho').innerHTML='<b>'+esc(o.prodCd)+'</b> '+esc(o.prodNm||'');
  document.getElementById('spDt').value =
    d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2);
  document.getElementById('sp').classList.add('on');
  document.getElementById('spDt').focus();
}
function spClose(){ document.getElementById('sp').classList.remove('on'); }
function spOk(){
  var o=_byseq[_sel]||{};
  var v=(document.getElementById('spDt').value||'').replace(/[^0-9]/g,'');   // YYYY-MM-DD → YYYYMMDD
  if(v.length!==8){ toast('중지 시작일을 고르세요.','warn'); return; }
  spClose();
  pcStopSend('/prod/prodStop.do', {prodSeq:o.prodSeq, stopFrDt:v},
             pcFmtDt8(v)+' 부터 거래중지로 표시했습니다');
}
function pcStopSend(url, body, okMsg){
  fetch(CTX+url,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/json'},body:JSON.stringify(body)})
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
    .then(function(){ toast(okMsg,'ok');
      /* 목록을 다시 읽은 뒤 단추도 맞춘다 — 안 하면 해제했는데 단추가 [거래해제] 로 남는다 */
      pcLoad(); setTimeout(pcStopBtnSync, 300); })
    .catch(function(e){ toast(e.message||'처리하지 못했습니다.','err'); });
}
</script>

<%-- ───────── ♻ 삭제 목록 (2026-08-17 요청) ─────────
     삭제는 처음부터 **소프트 삭제**(ACTION_YN='N')였다 — 자료가 남아 있으니 되살리기는 값 하나를
     되돌리는 것뿐이다. 「왜 지웠더라」를 판단하도록 **지운 날짜·지운 사람**을 같이 보여 준다. --%>
<div id="rc">
  <div class="box">
    <div class="mh"><b>♻ 삭제한 상품코드</b>
      <input id="rcQ" placeholder="코드·상품명·규격·제조사" oninput="rcRender()"
             style="height:28px;border:0;border-radius:6px;padding:0 10px;width:280px;font-size:13px">
      <span id="rcCnt" style="font-size:12.5px;opacity:.9"></span>
      <button class="x" onclick="rcClose()">&times;</button>
    </div>
    <div class="mb">
      <table>
        <%-- 폭 합계가 모달 안쪽을 넘지 않게 잡는다(상품명만 남는 폭을 먹는다) — 넘치면 오른쪽이 잘린다 --%>
        <thead><tr><th style="width:110px">코드</th><th>상품명</th><th style="width:150px">규격</th>
          <th style="width:100px">제조사</th><th style="width:80px">입고가</th><th style="width:80px">판매가</th>
          <th style="width:150px">지운 날</th><th style="width:90px">지운 사람</th><th style="width:86px">되살리기</th></tr></thead>
        <tbody id="rcTb"><tr><td colspan="9" class="empty">불러오는 중…</td></tr></tbody>
      </table>
      <div style="margin-top:10px;font-size:12.5px;color:#8a97a3">
        되살리면 목록에 다시 나타납니다. 매입가·판매가·재고 이력은 삭제 때 지워지지 않으므로 그대로 남아 있습니다.
      </div>
    </div>
  </div>
</div>

<%-- ⛔ 거래중지 — **중지일만** 받는다 (2026-08-17 지시). 사유는 안 묻는다(입력 단계를 늘리지 않는다) --%>
<div id="sp">
  <div class="box">
    <div class="mh">⛔ 거래중지</div>
    <div class="mb">
      <div id="spWho" style="font-size:13px;color:#37475a;margin-bottom:10px"></div>
      <label style="font-size:12.5px;font-weight:700;color:#1f2a37">중지 시작일</label>
      <input type="date" id="spDt">
      <div style="margin-top:8px;font-size:12px;color:#8a97a3">
        이 날짜부터 매입·판매에서 막힙니다. <b>그 전 전표와 재고는 그대로</b> 유지됩니다.
      </div>
    </div>
    <div class="mf">
      <button class="btn" onclick="spClose()">취소</button>
      <button class="btn btn-danger" onclick="spOk()">⛔ 거래중지</button>
    </div>
  </div>
</div>
</body>
</html>
