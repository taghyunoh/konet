<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%-- 공통 알림/확인 표준 (_alertBox/_confirmBox/_toast) — 2026-08-28.
     ★프로젝트 규칙(logistics_demo2.jsp 머리말) : 새 코드는 swAlert/swConfirm 이 아니라 이걸 쓴다.
       확인창 모양이 화면마다 달라 보이던 것을 이 표준으로 맞춘다. CSS·모달은 이 파일이 스스로 넣는다. --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<title>거래처관리 (사업장 · TBL_BIZI_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  /* 도구줄 글자 한 단계 크게 (2026-08-28 요청) — 13 → 14.5px. 높이·여백도 같이 올린다. */
  .bar input.search{ height:36px; border:1px solid var(--bd); border-radius:7px; padding:0 11px; font-size:14.5px; width:300px; }
  .btn{ height:36px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 15px; cursor:pointer; font-size:14.5px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:8px; color:#6b7a89; font-size:12.5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  /* 목록 높이는 cliFit() 이 창 크기에 맞춰 px 로 잡는다(매입/매출 거래처 화면과 같은 방식) */
  #listCard{ min-height:220px; }
  /* 스크롤해도 머리글은 남아야 한다. z-index 없으면 행이 머리글 위로 그려진다 */
  .card thead th{ position:sticky; top:0; z-index:3; }
  /* 목록 글자 한 단계 크게 (2026-08-28 요청) — 13→14.5px / 머리줄 14→15px.
     ★칸 안쪽 여백도 같이 올린다 — 글자만 키우면 줄이 빽빽해 보인다. */
  table{ width:100%; border-collapse:collapse; font-size:14.5px; font-weight:700; white-space:nowrap; }
  thead th{ background:#b9ded4; color:#0b4f43; font-weight:800; font-size:15px; box-shadow:inset 0 -2px 0 #0e6657; padding:10px 10px; text-align:left; position:sticky; top:0; z-index:1; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:7px 10px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  tbody tr{ cursor:pointer; }
  tbody tr.sel td{ background:#dcefe9 !important; }
  .btn:disabled{ opacity:.45; cursor:default; }
  td.code{ font-family:Consolas,monospace; }
  td.nm{ white-space:normal; min-width:180px; max-width:280px; }
  /* 주소 칸 — 길어서 가로가 터지지 않게 폭 제한 + 말줄임(전체는 마우스 올리면 툴팁) */
  td.ad{ max-width:300px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-weight:500; }
  .gb{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; color:#fff; }
  .act .btn{ height:26px; padding:0 9px; font-size:11.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  .pager{ display:flex; gap:8px; justify-content:center; align-items:center; margin-top:10px; flex-wrap:wrap; }
  .pgnote{ font-size:12.5px; color:#5a6b7a; font-weight:600; }
  .pgnote b{ color:var(--teal); }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  <%-- 3단 배치(2026-08-06 요청) — 칸이 늘어 두 줄이 길어졌다. 폭도 함께 넓혀 칸이 좁아지지 않게 --%>
  #ov .box{ background:#fff; width:min(1080px,96vw); margin-top:4vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:92vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:16px 18px; overflow:auto; display:grid; grid-template-columns:repeat(3,1fr); gap:12px 16px; }
  #ov .fld{ display:flex; flex-direction:column; gap:4px; }
  #ov .fld.full{ grid-column:1 / -1; }
  /* 사업장명·주소류는 3단에서도 넓게 — 두 칸 차지 */
  #ov .fld.wide{ grid-column:span 2; }
  /* 좁은 화면에서는 2단 → 1단으로 접힌다 */
  @media (max-width:900px){ #ov .mb{ grid-template-columns:1fr 1fr; } }
  @media (max-width:620px){ #ov .mb{ grid-template-columns:1fr; } #ov .fld.wide{ grid-column:auto; } }
  <%-- 라벨 = 진하게·가운데 정렬 (2026-08-04 요청, 다른 등록 창과 동일) --%>
  #ov label{ font-size:13px; font-weight:700; color:#1f2a37; background:linear-gradient(135deg,#b3ddf0 0%,#d4ecf7 100%); border-radius:3px; padding:4px 10px; display:inline-flex; align-items:center; justify-content:center; text-align:center; align-self:flex-start; min-width:104px; min-height:26px; white-space:nowrap; }
  #ov input, #ov select, #ov textarea{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:14px; font-family:inherit; }
  #ov textarea{ height:auto; padding:6px 8px; resize:vertical; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
  /* 취소·저장은 가로를 넉넉히 (2026-08-04 요청) */
  #ov .mf .btn{ min-width:104px; padding:0 22px; }

  /* ── 공통 매칭코드 창 (2026-08-28) ─────────────────────────────────────
       ★#ov 규칙은 ui-concept.css 에도 있어 <다른 화면과 공유>된다 → 거기에 #mov 를 끼워 넣지 않고
         여기에서 필요한 것만 따로 쓴다. 그래야 다른 화면이 영향을 안 받는다. */
  #mov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:60; align-items:flex-start; justify-content:center; }
  #mov.on{ display:flex; }
  #mov .box{ background:#fff; width:min(520px,94vw); margin-top:7vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:86vh; display:flex; flex-direction:column; }
  #mov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #mov .mh b{ font-size:16px; }
  #mov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #mov .mb{ padding:16px 18px; overflow:auto; }
  #mov .fld{ display:flex; flex-direction:column; gap:4px; }
  #mov label{ font-size:13px; font-weight:700; color:#1f2a37; background:linear-gradient(135deg,#b3ddf0 0%,#d4ecf7 100%); border-radius:3px; padding:4px 10px; display:inline-flex; align-items:center; justify-content:center; align-self:flex-start; min-width:104px; min-height:26px; white-space:nowrap; }
  #mov input{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:14px; font-family:inherit; width:100%; box-sizing:border-box; }
  #mov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
  #mov .mf .btn{ min-width:104px; padding:0 22px; }
  /* 이미 쓰는 매칭 = <세로 목록>. 옆으로 미는 한 줄은 매칭이 늘면 못 찾는다(2026-08-28 지적).
     한 줄에 하나씩 보여 주고, 위 찾기 칸으로 걸러 쓴다. */
  /* ★높이를 못박는다(min=max) — 목록은 <무엇이 있는지 보여 주는> 자리다.
       한 줄만 있다고 상자가 쪼그라들면 「이게 전부인가?」를 알 수 없고, 늘어나면 창이 출렁인다.
       여섯 줄쯤 보이고 그 이상은 세로 스크롤. 찾기는 <못 찾을 때> 쓰는 보조다. */
  /* 매칭 목록 : <내용만큼 늘어나되 10줄에서 멈추고> 그 다음은 세로 스크롤 (2026-08-28).
     ★height 로 못박으면 안 된다 — 매칭이 두어 개일 때 빈 칸만 커지고,
       창이 화면보다 길어져 아래 [지정] 단추가 잘린다(실제로 그랬다).
     한 줄 29.6px × 10 + 안쪽여백 8 + 테두리 2 = 312px. 줄 높이를 바꾸면 같이 고칠 것.
     ★32vh 로 한 번 더 조인다 — 낮은 화면(720px 등)에서는 10줄이 다 들어가면 창이 화면을 넘어
       아래 [지정] 단추가 잘린다. 화면이 크면 312px 그대로 10줄. */
  #mov #m_used{ display:block; min-height:70px; max-height:min(312px, 32vh); overflow-y:auto; overflow-x:hidden;
                border:1px solid #e6ecf0; border-radius:6px; padding:4px; }
  #mov #m_used::-webkit-scrollbar{ width:9px; }
  #mov #m_used::-webkit-scrollbar-thumb{ background:#c9d6d2; border-radius:5px; }
  #mov #m_used::-webkit-scrollbar-track{ background:#f4f7f6; border-radius:5px; }
  #mov .mchip{ display:flex; align-items:center; gap:8px; width:100%; text-align:left;
               border:1px solid transparent; border-bottom:1px solid #eef2f5; background:none;
               color:#37475a; border-radius:5px; padding:6px 9px; font-size:13px; cursor:pointer; font-family:inherit; }
  #mov .mchip:last-child{ border-bottom-color:transparent; }
  #mov .mchip:hover{ background:#eef7f4; }
  #mov .mchip.on{ background:#137a6c; color:#fff; border-color:#137a6c; }
  #mov .mchip .cd{ font-family:Consolas,monospace; font-weight:700; color:#137a6c; min-width:58px; }
  #mov .mchip.on .cd{ color:#cdeee8; }
  #mov .mchip .nm{ flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-weight:600; }
  #mov .mchip .n{ color:#8aa8a0; font-weight:700; font-size:12px; white-space:nowrap; }
  #mov .mchip.on .n{ color:#bfe6dd; }
  /* 목록의 매칭코드 표시 — 코드가 있는 줄이 한눈에 보이게 */
  .mtag{ display:inline-block; background:#e3f4ef; color:#137a6c; border:1px solid #b9e6dd; border-radius:11px; padding:1px 9px; font-size:12px; font-weight:700; }
</style>
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
<%-- ★공통 UI 보정 (2026-08-21) — 단추 글자 두 줄 접힘 방지 + [글자 축소/확대] 단추 모양.
     화면 크기와 무관하게 늘 적용된다(위 konet-notebook.css 는 노트북 전용 @media 라 큰 화면에서는 안 걸린다). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
<%-- ★[2026-08-20] 화면 콘셉 공통 — 표 형식 입력 · 세로선 격자 · Pretendard.
     반드시 이 화면의 <style>·다른 CSS **뒤에** 걸어야 옛 규칙(알약 라벨 등)을 덮는다.
     이 두 줄만 빼면 이 화면만 예전 모습으로 돌아간다. 규칙 설명은 CSS 파일 머리말. --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/ui-concept.css?v=20260820">
</head>
<body>
<div class="wrap">
  <h2>🤝 거래처관리 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(사업장 · TBL_BIZI_MST)</span></h2>
  <div class="sub">사업장(거래처) 조회 · 추가 · 수정 · 삭제 · 엑셀출력
    <%-- 키 안내 (2026-08-04) — 안 보이면 아무도 안 쓴다 --%>
    <div style="margin-top:3px;font-size:12px;color:#9aa7b3">⌨ <b>↑↓</b> 줄 이동 · <b>Enter</b> 수정 · <b>Alt+N</b> 추가
      &nbsp;|&nbsp; 창에서 <b>Enter</b> 다음 칸 · <b>Ctrl+S</b> 저장 · <b>Esc</b> 닫기</div></div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·사업장명·약칭·사업자번호·대표자 검색" oninput="cliFilter()" onkeyup="if(event.keyCode===13)cliFilter()">
    <button class="btn" onclick="cliLoad()">↻ 조회</button>
    <%-- 체크 관리 (2026-08-28 요청 「두 내용 앞으로」) — 왼쪽 체크칸을 다루는 단추라 <검색 옆>이 자리다.
         오른쪽 덩어리(추가·수정·삭제·매칭)는 <고른 뒤에> 하는 일이라 성격이 다르다.
         ★[전체 해제]는 검색으로 지금 안 보이는 체크까지 푼다 — 그게 「전체」의 뜻이다. --%>
    <button class="btn" id="btnChkAllOn" onclick="cliChkAll(true)" title="지금 목록(검색 결과)에 보이는 사업장을 모두 체크합니다">☑ 해당목록 체크</button>
    <%-- ★「해당목록」 = 지금 <검색 결과로 보이는> 줄만 뜻한다. 검색으로 안 보이는 체크는 그대로 남는다
         (그건 매칭 창의 빨간 경고에서 [✕ 체크 모두 풀기]로 푼다). 둘을 헷갈리지 않게 이름을 나눠 뒀다. --%>
    <button class="btn" id="btnChkAllOff" onclick="cliChkAll(false)" title="지금 목록(검색 결과)에 보이는 사업장의 체크만 풉니다">☐ 해당목록 해제</button>
    <button class="btn" id="btnOnlySel" onclick="cliOnlySel()" title="체크한 사업장만 모아 봅니다 (다시 누르면 전체)">☑ 선택만 보기</button>
    <%-- 공통 매칭코드 (2026-08-28) — 체크로 고른 사업장들을 하나의 코드/이름으로 묶는다.
         차례 = 「고른다(전체체크·선택만보기) → 묶는다(지정·해제) → 치운다(전체해제)」 로 묶어 둔다. --%>
    <button class="btn" id="btnMatch" onclick="cliMatchOpen()" title="체크한 사업장들을 하나의 공통 매칭코드로 묶습니다">🔗 매칭코드 지정</button>
    <%-- 「선택목록 매칭해제」 = <체크한 사업장>의 매칭만 지운다(2026-08-28 확정).
         ★한때 「보이는 목록 전체」로 만들었다가 되돌렸다 — 검색 결과를 통째로 지우는 건 되돌리기 어렵다. --%>
    <button class="btn" id="btnMatchClr" onclick="cliMatchClear()" title="체크한 사업장의 매칭코드만 지웁니다">↩ 선택목록 매칭해제</button>
    <%-- ✕ 전체 해제 단추는 2026-08-28 요청으로 툴바에서 뺐다.
         지정·해제 뒤 체크가 저절로 풀리므로 평소엔 쓸 일이 없다.
         ★기능 자체는 남겨 둔다(cliChkClearAll) — 안 보이는 체크가 남았을 때
           매칭 창의 빨간 경고 안에서 [모두 풀기]로 부른다. 그 순간이 실제로 필요한 때다. --%>
    <button class="btn btn-teal" style="margin-left:auto" onclick="cliOpen()">＋ 거래처 추가</button>
    <button class="btn" id="btnEdit" onclick="cliEditSel()">✎ 수정</button>
    <button class="btn btn-danger" id="btnDel" onclick="cliDelSel()">🗑 삭제</button>
    <button class="btn" onclick="cliExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="card" id="listCard">
    <table>
      <%-- 목록 칸 = 실제로 채워 쓰는 정보로 교체 (2026-08-06 요청)
           약칭·거래구분·사업자번호·대표자·업태·종목은 사업장 자료에 거의 비어 있어 자리만 차지했다.
           대신 배송·택배에 필요한 주소·수령자·연락처·운임을 보여 준다. 상세는 더블클릭(수정창). --%>
      <thead><tr>
        <th style="width:34px;text-align:center"><input type="checkbox" id="ckAll" onclick="cliChkAll(this.checked)" title="보이는 줄 모두 선택/해제"></th>
        <th style="width:96px">매칭코드</th><th style="width:150px">매칭명칭</th>
        <th>코드</th><th>사업장명</th><th>배송처 주소</th><th>택배주소</th>
        <th>수령자</th><th>전화</th><th>휴대폰</th><th>운임</th><th>담당자</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="12" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
</div>

<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">거래처 추가</b><button class="x" onclick="cliClose()">&times;</button></div>
    <div class="mb">
      <div class="fld"><label>사업장코드 *</label><input id="f_cd" placeholder="예: A0386956"></div>
      <div class="fld"><label>거래구분</label><select id="f_gb"><option value="">-</option><option value="매출">매출처</option><option value="매입">매입처</option><option value="both">매입+매출</option></select></div>
      <div class="fld wide"><label>사업장명 *</label><input id="f_nm" placeholder="사업장명"></div>
      <div class="fld"><label>약칭</label><input id="f_snm" placeholder="약어 명칭"></div>
      <div class="fld"><label>사업자등록번호</label><input id="f_bizno"></div>
      <div class="fld"><label>대표자</label><input id="f_ceo"></div>
      <div class="fld"><label>담당자</label><input id="f_mgr"></div>
      <div class="fld"><label>업태</label><input id="f_cond"></div>
      <div class="fld"><label>종목</label><input id="f_item"></div>
      <div class="fld"><label>우편번호</label><input id="f_zip"></div>
      <div class="fld"><label>정렬순서</label><input id="f_sort" type="number" value="999999"></div>
      <div class="fld wide"><label>주소</label><input id="f_addr"></div>
      <div class="fld wide"><label>상세주소</label><input id="f_addr2"></div>
      <div class="fld"><label>전화</label><input id="f_tel"></div>
      <div class="fld"><label>팩스</label><input id="f_fax"></div>
      <div class="fld"><label>휴대폰</label><input id="f_hp"></div>
      <div class="fld"><label>이메일</label><input id="f_email"></div>
      <%-- 택배 정보 (2026-08-06 신설) — 택배출고관리 엑셀이 쓰는 값.
           택배주소가 비면 위 [주소]를 쓴다. 운임은 비우면 4,500 기본. --%>
      <div class="fld wide" style="border-top:1px dashed #dbe2ea; padding-top:8px; margin-top:2px">
        <label style="color:#137a6c">🚛 택배주소 <span style="font-weight:500;color:#8a98a8">(비우면 위 주소 사용)</span></label>
        <input id="f_paddr" placeholder="택배 발송 주소">
      </div>
      <div class="fld"><label>택배 수령자</label><input id="f_pnm" placeholder="수령자"></div>
      <div class="fld"><label>택배 전화</label><input id="f_ptel"></div>
      <div class="fld"><label>택배 휴대폰</label><input id="f_php"></div>
      <div class="fld"><label>택배 기본운임</label><input id="f_pfee" type="number" placeholder="4500"></div>
      <div class="fld full"><label>비고</label><textarea id="f_remark" rows="2"></textarea></div>
    </div>
    <div class="mf">
      <button class="btn" onclick="cliClose()">취소</button>
      <button class="btn btn-teal" onclick="cliSave()">💾 저장</button>
    </div>
  </div>
</div>

<%-- ── 공통 매칭코드 지정 창 (2026-08-28) ───────────────────────────────
     체크한 사업장들에 <코드 + 이름>을 한 번에 넣는다.
     코드는 [자동채번]으로 M0001… 을 받아 오거나 직접 칠 수 있다(둘 다 허용 — 사용자 확정). --%>
<div id="mov">
  <div class="box" style="max-width:520px">
    <div class="mh"><b>🔗 공통 매칭코드 지정</b><button class="x" onclick="cliMatchClose()">&times;</button></div>
    <div class="mb" style="display:block">
      <div id="mvCnt" style="font-size:13px;color:#37475a;margin-bottom:10px"></div>
      <%-- 이미 쓰고 있는 매칭 (2026-08-28 요청 「매칭했던 코드·명칭 보여줘」) —
           누르면 아래 칸이 그 값으로 채워진다. 새 코드를 또 따지 않고 <기존 묶음에 추가>할 때 쓴다. --%>
      <%-- 이미 쓰는 매칭 — 알약 한 줄 + 가로 스크롤(2026-08-28).
           ★매칭이 수십 개가 되면 옆으로만 미는 건 못 찾는다 → 바로 위에 <찾기 칸>을 둔다.
             한 글자만 쳐도 알약이 걸러지고, 딱 하나면 그것이 자동으로 골라진다. --%>
      <div class="fld" style="margin-bottom:8px">
        <label>이미 쓰는 매칭 <span id="m_usedCnt" style="font-weight:500;color:#5a6b7a"></span></label>
        <input id="m_usedQ" placeholder="🔎 목록에서 거르기 — 코드나 이름 일부 (예: 호호, M0002)"
               oninput="cliMatchUsed()" style="margin-bottom:5px;font-size:13px">
        <div id="m_used"></div>
      </div>
      <div class="fld" style="margin-bottom:8px">
        <label>매칭코드 *</label>
        <div style="display:flex;gap:6px;align-items:center">
          <input id="m_cd" placeholder="예: M0001 (직접 입력 가능)" style="flex:1">
          <button class="btn" onclick="cliMatchNext()" title="쓰지 않은 다음 번호를 받아옵니다">🔢 자동채번</button>
        </div>
      </div>
      <div class="fld"><label>매칭명칭</label><input id="m_nm" placeholder="예: 데블다이스"></div>
      <div id="mvList" style="margin-top:10px;max-height:120px;overflow:auto;border:1px solid #e6ecf0;border-radius:6px;
                              padding:7px 10px;font-size:12.5px;color:#5a6b7a;line-height:1.7"></div>
      <div style="margin-top:9px;font-size:12px;color:#9aa7b3;line-height:1.6">
        · 이미 매칭코드가 있는 사업장은 <b>이 값으로 바뀝니다</b>.<br>
        · 지금은 이 화면(목록·검색·엑셀)에서만 쓰입니다 — 출고현황표 묶음은 그대로입니다.
      </div>
    </div>
    <div class="mf">
      <button class="btn" onclick="cliMatchClose()">취소</button>
      <button class="btn btn-teal" onclick="cliMatchSave()">💾 지정</button>
    </div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
/* 목록은 페이지 버튼 없이 **스크롤로 이어서** 나온다 (2026-08-04 요청 — 매입/매출 거래처 화면과 같은 방식).
   _shown = 지금까지 그려 둔 줄 수. 바닥 가까이 내려가면 CHUNK 만큼 더 그린다.
   ★한 번에 전부 그리지 않는 이유 — 사업장이 1,300여 종이라 통째로 그리면 첫 표시가 눈에 띄게 느려진다.
   PAGE 는 고정값이 아니라 cliFit() 이 실제 창 높이에서 다시 잡는다(첫 화면이 꽉 차게). */
var LIST=[], _view=[], _shown=0, PAGE=20, CHUNK=40, _bycd={};
var GB_MAP={ '매출':['매출처','#2e7d32'], '매입':['매입처','#a85700'], 'both':['매입+매출','#137a6c'] };

/* 알림은 <화면 정중앙>에 띄운다 (2026-08-28 요청 「중앙 가운데」) — 오른쪽 끝은 눈이 목록에 있을 때 놓친다.
   ★목록을 잠깐 가리므로 머무는 시간을 2.5초 → 1.8초로 줄인다. 클릭은 통과시킨다(가려도 조작은 된다). */
function toast(s){ if(window.Swal){ Swal.fire({toast:true,position:'center',html:s,showConfirmButton:false,timer:1800,timerProgressBar:true,
    didOpen:function(el){ try{ el.parentElement.style.pointerEvents='none'; }catch(e){} } }); return; } }
/* 확인창 = 공통 표준 _confirmBox (ui-message.js) — 2026-08-28 요청 「이런 스타일로」.
   ★제목은 창에 따로 자리가 없다 → 굵게 한 줄로 올려 붙인다(그림 속 「🔄 출고반영 재집계」와 같은 모양).
   ★okColor:'blue' = 파란 [확인]. 지우는 동작만 기본(빨강)으로 둔다. */
function swConfirm(msg,title,opt){
  opt=opt||{};
  return new Promise(function(resolve){
    if(typeof window._confirmBox !== 'function'){ resolve(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))); return; }
    var head = title ? ('<b style="display:block;font-size:15px;color:#137a6c;margin-bottom:9px">'+title+'</b>') : '';
    _confirmBox({ msg: head+msg, icon: opt.icon||'❓', okText: opt.okText||'확인',
                  okColor: (opt.okColor===undefined ? 'blue' : opt.okColor),
                  onOk:function(){ resolve(true); }, onCancel:function(){ resolve(false); } });
  });
}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function gnum(id){ var v=gv(id); return v===''?null:Number(v); }

/* ── 검색 (2026-08-06 개편) ─────────────────────────────────
     ★목록은 서버에서 전부 받아 두고 **화면에서 거른다** — 사업장이 1,400여 종이라 가볍고,
       무엇보다 '영문 자판으로 친 한글'(ghgh → 호호) 검색을 서버 LIKE 로는 할 수 없다.
     비교 방법 : 글자 그대로 비교 + **자모(초·중·종성) 나열 비교**.
       친 영문을 두벌식 자판대로 자모로 바꾸고(ghgh → ㅎㅗㅎㅗ),
       자료의 한글도 자모로 풀어(호호 → ㅎㅗㅎㅗ) 부분일치를 본다.
       겹자모(ㅘ·ㄺ 등)는 양쪽 모두 낱자로 쪼개 비교해야 맞는다(ㅗ+ㅏ 로 치기 때문). */
var _KMAP={q:'ㅂ',w:'ㅈ',e:'ㄷ',r:'ㄱ',t:'ㅅ',y:'ㅛ',u:'ㅕ',i:'ㅑ',o:'ㅐ',p:'ㅔ',
           a:'ㅁ',s:'ㄴ',d:'ㅇ',f:'ㄹ',g:'ㅎ',h:'ㅗ',j:'ㅓ',k:'ㅏ',l:'ㅣ',
           z:'ㅋ',x:'ㅌ',c:'ㅊ',v:'ㅍ',b:'ㅠ',n:'ㅜ',m:'ㅡ',
           Q:'ㅃ',W:'ㅉ',E:'ㄸ',R:'ㄲ',T:'ㅆ',O:'ㅒ',P:'ㅖ'};
var _CHO='ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';
var _JUNG='ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ';
var _JONG=['','ㄱ','ㄲ','ㄳ','ㄴ','ㄵ','ㄶ','ㄷ','ㄹ','ㄺ','ㄻ','ㄼ','ㄽ','ㄾ','ㄿ','ㅀ','ㅁ','ㅂ','ㅄ','ㅅ','ㅆ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
var _SPLIT={'ㅘ':'ㅗㅏ','ㅙ':'ㅗㅐ','ㅚ':'ㅗㅣ','ㅝ':'ㅜㅓ','ㅞ':'ㅜㅔ','ㅟ':'ㅜㅣ','ㅢ':'ㅡㅣ',
            'ㄳ':'ㄱㅅ','ㄵ':'ㄴㅈ','ㄶ':'ㄴㅎ','ㄺ':'ㄹㄱ','ㄻ':'ㄹㅁ','ㄼ':'ㄹㅂ','ㄽ':'ㄹㅅ','ㄾ':'ㄹㅌ','ㄿ':'ㄹㅍ','ㅀ':'ㄹㅎ','ㅄ':'ㅂㅅ'};
function _jamo(s){                       /* 한글 → 자모 나열(겹자모는 낱자로) */
  s=''+(s==null?'':s); var out='';
  for(var i=0;i<s.length;i++){
    var ch=s.charAt(i), c=s.charCodeAt(i);
    if(c>=0xAC00 && c<=0xD7A3){
      var x=c-0xAC00, ju=_JUNG.charAt(Math.floor((x%588)/28)), jo=_JONG[x%28];
      out += _CHO.charAt(Math.floor(x/588)) + (_SPLIT[ju]||ju) + (jo?(_SPLIT[jo]||jo):'');
    } else out += (_SPLIT[ch]||ch);
  }
  return out;
}
function _engJamo(s){                    /* 영문 자판 → 자모 (ghgh → ㅎㅗㅎㅗ) */
  s=''+(s==null?'':s); var out='';
  for(var i=0;i<s.length;i++){
    var ch=s.charAt(i);
    out += (_KMAP[ch] || _KMAP[ch.toLowerCase()] || ch);
  }
  return out;
}
function _cliHit(o,q){
  if(!q) return true;
  var joined=[o.bizCd,o.bizNm,o.bizSmallNm,o.bizno,o.ceoNm,o.addr,o.addr2,o.parcelAddr,o.parcelNm,
              o.tel,o.hp,o.parcelTel,o.parcelHp,o.manager,o.matchCd,o.matchNm]
             .map(function(x){ return x==null?'':(''+x); }).join(' ');
  if(joined.toLowerCase().indexOf(q.toLowerCase())>=0) return true;
  if(/[a-zA-Z]/.test(q)){                /* 영문이 섞였으면 '영타로 친 한글'로도 본다 */
    var qj=_jamo(_engJamo(q)).replace(/\s+/g,'');
    if(qj && _jamo(joined).replace(/\s+/g,'').indexOf(qj)>=0) return true;
  }
  return false;
}
var _ALL=[];                             /* 서버에서 받은 전체 목록(검색은 여기서 거른다) */
function cliLoad(){
  fetch(CTX+'/mangr/clientList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'findData=' })
    .then(function(r){ return r.text(); }).then(function(t){ var j; try{ j=JSON.parse(t); }catch(e){ toast('⚠️ 목록 응답 오류'); return; }
      _ALL=(j&&j.data)||[];
      cliFilter();
    }).catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function cliFilter(){
  var q=(document.getElementById('q').value||'').trim();
  LIST=q ? _ALL.filter(function(o){ return _cliHit(o,q); }) : _ALL.slice();
  /* ★_bycd 는 <검색 결과>가 아니라 전체로 만든다 — 매칭 창이 "지금 안 보이는 체크"의 이름을 찾아야 한다 */
  _bycd={}; _ALL.forEach(function(o){ _bycd[o.bizCd]=o; });
  /* 선택만 보기 : 검색 결과가 아니라 <전체>에서 체크한 것을 모은다 —
     여러 번 검색해 가며 모은 체크를 한 화면에서 보는 게 이 기능의 목적이다. */
  _view = _onlySel ? _ALL.filter(function(o){ return !!_mchk[o.bizCd]; }) : LIST.slice();
  _shown=0; _selReset();      // 새로 거른 목록이라 고른 줄은 푼다(빠진 줄일 수 있다)
  var c=document.getElementById('listCard'); if(c) c.scrollTop=0;
  cliRender();
}
function cliRender(){
  var tot=_view.length;
  if(_shown<PAGE) _shown=PAGE;
  if(_shown>tot) _shown=tot;
  document.getElementById('cnt').textContent=tot.toLocaleString()+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="12" class="empty">데이터가 없습니다.</td></tr>'; _selReset(); _info(0,0); cliFit(); return; }
  tb.innerHTML=_view.slice(0,_shown).map(function(o){
    /* 택배주소·전화·휴대폰은 **택배값이 없으면 배송지(기본) 값으로 대체**해 보여 준다 (2026-08-06 확정)
       — 택배출고관리·엑셀이 실제로 쓰는 값과 목록에 보이는 값이 같아야 한다.
       대체된 주소는 회색 + [배송지] 꼬리표로 구분한다(택배주소를 따로 등록한 것과 헷갈리지 않게). */
    var tel=o.parcelTel||o.tel||'', hp=o.parcelHp||o.hp||'';
    var pAddr=o.parcelAddr ? esc(o.parcelAddr)
              : (o.addr ? '<span style="color:#8a98a8;font-weight:500">'+esc(o.addr)
                          +' <span style="font-size:11px;color:#b9c3cd">[배송지]</span></span>'
                        : '<span style="color:#c9d2da;font-weight:500">—</span>');
    /* 체크칸은 <행 선택>과 다르다 — 체크 = 매칭 대상 여러 개, 파란 줄 = 수정/삭제 대상 하나.
       그래서 체크박스 클릭은 stopPropagation 으로 행 선택과 섞이지 않게 한다. */
    var _ck=_mchk[o.bizCd] ? ' checked' : '';
    var _mc=o.matchCd ? '<span class="mtag">'+esc(o.matchCd)+'</span>' : '<span style="color:#c9d2da">—</span>';
    return '<tr data-cd="'+esc(o.bizCd)+'" onclick="cliSel(this,\''+esc(o.bizCd)+'\')" ondblclick="cliOpen(\''+esc(o.bizCd)+'\')">'
      +'<td style="text-align:center"><input type="checkbox"'+_ck+' onclick="event.stopPropagation();cliChk(\''+esc(o.bizCd)+'\',this.checked)"></td>'
      +'<td>'+_mc+'</td><td class="nm">'+esc(o.matchNm)+'</td>'
      +'<td class="code">'+esc(o.bizCd)+'</td><td class="nm">'+esc(o.bizNm)+'</td>'
      +'<td class="ad">'+esc(o.addr)+'</td><td class="ad">'+pAddr+'</td>'
      +'<td>'+esc(o.parcelNm)+'</td><td>'+esc(tel)+'</td><td>'+esc(hp)+'</td>'
      +'<td style="text-align:right">'+(o.parcelFee!=null?Number(o.parcelFee).toLocaleString():'')+'</td>'
      +'<td>'+esc(o.manager)+'</td>'
    +'</tr>';
  }).join('');
  // ★고른 줄 표시를 되살린다 — 스크롤로 이어 그릴 때마다 선택이 풀리면
  //   줄을 고른 뒤 조금만 내려도 [수정]이 "행을 먼저 선택하세요"로 튕긴다.
  if(_sel!=null){ var sr=tb.querySelector('tr[data-cd="'+_sel+'"]'); if(sr) sr.classList.add('sel'); }
  _info(_shown, tot);
  cliChkInfo();          // 체크 개수·[모두] 상태를 다시 그릴 때마다 맞춘다
  cliFit();
}
/* 페이지 버튼을 없앤 자리 — 지금 몇 줄까지 보고 있는지와 [모두 표시]만 남긴다 */
function _info(shown, tot){
  var el=document.getElementById('pager'); if(!el) return;
  if(!tot){ el.innerHTML=''; return; }
  el.innerHTML = shown>=tot
    ? '<span class="pgnote">전체 <b>'+tot.toLocaleString()+'</b>건을 모두 보고 있습니다</span>'
    : '<span class="pgnote"><b>'+shown.toLocaleString()+'</b> / '+tot.toLocaleString()+'건 — 아래로 스크롤하면 이어서 나옵니다</span>'
      + '<button onclick="cliShowAll()">모두 표시</button>';
}
function cliShowAll(){ _shown=_view.length; cliRender(); }
/* ── 목록 높이 자동 맞춤 (매입/매출 거래처 화면 vmFit 과 같은 방식) ─────────
   ① 목록 카드를 창 아래(안내줄 위)까지 늘리고, 그 안에서 스크롤하게 한다.
   ② 늘어난 높이에 맞춰 첫 화면에 담는 줄 수(PAGE)도 다시 잡는다 — 높이만 늘리면 20줄 밑이 그대로 빈다.
   ★위치는 반드시 '문서 기준'(rect.top + scrollY)으로 잰다. 화면 기준으로 재면
     스크롤할 때마다 값이 달라져 높이가 계속 자라는 자가증식이 된다. */
var _fitting=false;
function cliFit(){
  if(_fitting) return; _fitting=true;
  try{
    var card=document.getElementById('listCard'), pg=document.getElementById('pager');
    if(!card) return;
    var top=card.getBoundingClientRect().top + (window.pageYOffset||0);
    var pgH=pg ? (pg.offsetHeight+10) : 0;
    var h=Math.max(220, Math.floor(window.innerHeight - top - pgH - 14));
    card.style.height=h+'px';
    // 한 줄 높이는 실제로 그려진 줄에서 잰다(글꼴·배율마다 다르다). 없으면 30px 로 본다
    var tr=card.querySelector('tbody tr'), th=card.querySelector('thead');
    var rowH=(tr&&tr.offsetHeight)||30, headH=(th&&th.offsetHeight)||34;
    var fit=Math.max(10, Math.floor((h-headH)/rowH));
    if(fit!==PAGE){ PAGE=fit; if(_shown<PAGE){ cliRender(); } }   // 가드가 되돌이를 막는다
    _bindScroll();
    // 창을 키워 목록이 스크롤 없이 다 들어오면 스크롤 이벤트가 안 오므로 여기서 더 채운다
    if(_shown<_view.length && card.scrollHeight<=card.clientHeight+4){
      _shown=Math.min(_shown+CHUNK, _view.length); cliRender();
    }
  } finally { _fitting=false; }
}
window.addEventListener('resize', function(){ clearTimeout(window._fitT); window._fitT=setTimeout(cliFit,120); });
/* 목록 바닥 가까이 내려가면 이어서 그린다 — 카드가 스크롤 영역이라 여기에 건다.
   ★목록을 다시 그려도 이벤트가 살아 있도록 카드(고정 요소)에 한 번만 건다. */
function _bindScroll(){
  var card=document.getElementById('listCard'); if(!card || card._bound) return;
  card._bound=true;
  card.addEventListener('scroll', function(){
    if(_shown>=_view.length) return;
    if(card.scrollTop + card.clientHeight >= card.scrollHeight - 80){
      _shown=Math.min(_shown+CHUNK, _view.length); cliRender();
    }
  });
}
function _set(id,v){ document.getElementById(id).value=(v==null?'':v); }
function cliOpen(cd){
  var o=cd?_bycd[cd]:null;
  document.getElementById('ovTit').textContent=o?'거래처 수정':'거래처 추가';
  _set('f_cd',o?o.bizCd:''); document.getElementById('f_cd').readOnly=!!o;
  _set('f_gb',o?o.bizGb:''); _set('f_nm',o?o.bizNm:''); _set('f_snm',o?o.bizSmallNm:'');
  _set('f_bizno',o?o.bizno:''); _set('f_ceo',o?o.ceoNm:''); _set('f_mgr',o?o.manager:'');
  _set('f_cond',o?o.bizCond:''); _set('f_item',o?o.bizItem:''); _set('f_zip',o?o.zipcd:'');
  _set('f_sort',o?(o.sortOrd!=null?o.sortOrd:999999):999999); _set('f_addr',o?o.addr:''); _set('f_addr2',o?o.addr2:'');
  _set('f_tel',o?o.tel:''); _set('f_fax',o?o.fax:''); _set('f_hp',o?o.hp:''); _set('f_email',o?o.email:''); _set('f_remark',o?o.remark:'');
  /* 택배 정보 (2026-08-06) — 택배출고관리가 쓰는 값. 빈 칸이면 위 주소·전화를 쓴다 */
  _set('f_paddr',o?o.parcelAddr:''); _set('f_pnm',o?o.parcelNm:'');
  _set('f_ptel',o?o.parcelTel:'');   _set('f_php',o?o.parcelHp:'');
  _set('f_pfee',o&&o.parcelFee!=null?o.parcelFee:'');
  document.getElementById('ov').classList.add('on');
  // 창을 열면 곧바로 칠 수 있게(2026-08-04) — 추가는 사업장코드부터, 수정은 코드가 잠겨 있으니 사업장명부터
  var first=document.getElementById(o?'f_nm':'f_cd');
  setTimeout(function(){ if(first){ first.focus(); if(first.select) first.select(); } }, 0);
}
function cliClose(){ document.getElementById('ov').classList.remove('on'); }
function cliSave(){
  var cd=gv('f_cd'), nm=gv('f_nm');
  if(!cd){ toast('⚠️ 사업장코드를 입력하세요.'); return; }
  if(!nm){ toast('⚠️ 사업장명을 입력하세요.'); return; }
  var dto={ bizCd:cd, bizNm:nm, bizSmallNm:gv('f_snm')||null, bizGb:gv('f_gb')||null, bizno:gv('f_bizno')||null,
    ceoNm:gv('f_ceo')||null, manager:gv('f_mgr')||null, bizCond:gv('f_cond')||null, bizItem:gv('f_item')||null,
    zipcd:gv('f_zip')||null, addr:gv('f_addr')||null, addr2:gv('f_addr2')||null, tel:gv('f_tel')||null, fax:gv('f_fax')||null,
    hp:gv('f_hp')||null, email:gv('f_email')||null, sortOrd:gnum('f_sort'), remark:gv('f_remark')||null };
  /* 택배 정보는 별도 저장(biziParcelUpdate) — 기존 clientUpdate 쿼리를 건드리지 않는다(2026-08-06) */
  var parcel={ bizCd:cd, bizNm:nm, parcelAddr:gv('f_paddr')||'', parcelNm:gv('f_pnm')||'',
               parcelTel:gv('f_ptel')||'', parcelHp:gv('f_php')||'', parcelFee:gnum('f_pfee') };
  var isEdit=document.getElementById('f_cd').readOnly;
  var url=isEdit?'/mangr/clientUpdate.do':'/mangr/clientInsert.do';
  fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
    .then(function(r){
      if(!r.ok){ toast('⚠️ '+((r.t||'').trim()||'저장 실패')); return; }
      return fetch(CTX+'/mangr/biziParcelUpdate.do', { method:'POST', headers:{'Content-Type':'application/json'},
                 credentials:'same-origin', body:JSON.stringify([parcel]) })
        .then(function(){ cliClose(); toast(isEdit?'💾 수정 완료':'＋ 등록 완료'); cliLoad(); });
    })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function cliDel(cd){
  var o=_bycd[cd]; if(!o) return;
  swConfirm('['+esc(o.bizCd)+'] '+esc(o.bizNm||'')+'<br>삭제하시겠습니까?','🗑 거래처 삭제',{icon:'🗑️',okText:'삭제',okColor:'red'}).then(function(ok){ if(!ok) return;
    fetch(CTX+'/mangr/clientDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({bizCd:cd}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
      .then(function(r){ if(!r.ok){ toast('⚠️ 삭제 실패'); return; } toast('🗑️ 삭제 완료'); cliLoad(); });
  });
}
/* ══ 공통 매칭코드 (2026-08-28) ══════════════════════════════════════════
   ★체크(_mchk)와 파란 줄(_sel)은 <다른 것>이다.
     체크 = 매칭 대상 여러 개 · 파란 줄 = 수정/삭제 대상 하나.
   ★체크는 <코드로> 기억한다 — 목록은 스크롤하며 조금씩 다시 그려서
     DOM 의 체크상태로 두면 위로 스크롤한 순간 다 풀린다. */
var _mchk={};
function cliChkCnt(){ var n=0; for(var k in _mchk) if(_mchk[k]) n++; return n; }
function cliChk(cd, on){ if(on) _mchk[cd]=1; else delete _mchk[cd]; cliChkInfo(); }
function cliChkAll(on){
  _view.forEach(function(o){ if(on) _mchk[o.bizCd]=1; else delete _mchk[o.bizCd]; });
  cliRender();
}
function cliChkInfo(){
  var n=cliChkCnt(), b=document.getElementById('btnMatch'), c=document.getElementById('btnMatchClr');
  var lab = n ? ('🔗 매칭코드 지정 ('+n+')') : '🔗 매칭코드 지정';
  if(b) b.innerHTML=lab;
  if(c) c.style.opacity = n ? '1' : '.55';    // 체크가 없으면 흐리게 — 이 단추는 체크가 있어야 쓴다
  var a=document.getElementById('ckAll'); if(a) a.checked = (n>0 && n>=_view.length);
  var cc=document.getElementById('btnChkClr'); if(cc) cc.style.opacity = n ? '1' : '.55';
  cliOnlySelUpd();
}
function cliChkList(){ var a=[]; for(var k in _mchk) if(_mchk[k]) a.push(k); return a; }
/* 체크한 것만 모아 보기 — 검색어와 <함께> 걸린다(검색 → 체크 → 다른 검색 → 선택만 보기 로 모을 수 있다).
   ★목록에서 사라져도 체크는 코드로 남아 있으므로, 여기서 _ALL 전체를 훑어 되살린다. */
var _onlySel=false;
function cliOnlySel(){
  if(!_onlySel && !cliChkCnt()){ toast('⚠️ 체크한 사업장이 없습니다.'); return; }
  _onlySel=!_onlySel;
  cliFilter();
}
function cliOnlySelUpd(){
  var b=document.getElementById('btnOnlySel'); if(!b) return;
  b.innerHTML = _onlySel ? '↩ 전체 보기' : '☑ 선택만 보기';
  b.style.background = _onlySel ? '#137a6c' : '';
  b.style.color      = _onlySel ? '#fff'    : '';
}
/* 전체 해제 — 지금 화면에 안 보이는 체크까지 전부. cliChkAll(false) 는 <보이는 줄>만 풀어서 다르다. */
function cliChkClearAll(){
  var n=cliChkCnt();
  if(!n){ toast('⚠️ 풀 체크가 없습니다.'); return; }
  _mchk={};
  if(_onlySel){ _onlySel=false; }      // 선택만 보기 상태에서 다 풀면 빈 화면이 된다 → 전체 보기로 되돌린다
  cliFilter();
  toast('✕ 체크 <b>'+n+'</b>건 모두 해제');
}

function cliMatchOpen(){
  var cds=cliChkList();
  if(!cds.length){ toast('⚠️ 왼쪽 <b>체크</b>로 묶을 사업장을 먼저 고르세요.'); return; }
  /* 고른 것들이 이미 같은 코드를 쓰고 있으면 그 값을 채워 준다 — 이름만 고치는 일이 잦다 */
  var cd0='', nm0='', same=true;
  cds.forEach(function(c,i){ var o=_bycd[c]||{}; if(i===0){ cd0=o.matchCd||''; nm0=o.matchNm||''; }
                             else if((o.matchCd||'')!==cd0) same=false; });
  document.getElementById('m_cd').value = same ? cd0 : '';
  document.getElementById('m_nm').value = same ? nm0 : '';
  /* ★[2026-08-28] 실제 사고 : 앞선 검색에서 체크해 둔 파스타입니다 28곳이 <화면에 안 보이는 채로> 남아
       배고픈덮밥 지정 때 함께 들어갔다. 체크는 검색을 넘어 유지되므로 <안 보이는 체크>를 반드시 알린다. */
  var _vis={}; _view.forEach(function(o){ _vis[o.bizCd]=1; });
  var _hid=cds.filter(function(c){ return !_vis[c]; });
  document.getElementById('mvCnt').innerHTML =
      '고른 사업장 <b style="color:#137a6c">'+cds.length+'</b>곳'
    + (_hid.length
       ? '<div style="margin-top:8px;padding:8px 10px;border:1px solid #f0b6b6;background:#fff1f1;'
         +'border-radius:6px;color:#b02a2a;font-size:12.5px;line-height:1.6">'
         +'⚠️ 이 중 <b>'+_hid.length+'곳</b>은 <b>지금 검색 결과에 없습니다</b> — 아래 목록에서 <b>빨간 줄</b>로 표시했습니다.<br>'
         +'전에 다른 검색에서 체크해 둔 것입니다. 함께 묶을 게 아니라면 아래 단추로 모두 풀고 다시 고르세요.'
         +'<div style="margin-top:7px"><button type="button" onclick="cliMatchClose();cliChkClearAll();" '
         +'style="border:1px solid #e0a0a0;background:#fff;color:#b02a2a;border-radius:6px;padding:4px 12px;'
         +'font-size:12.5px;font-weight:700;cursor:pointer;font-family:inherit">✕ 체크 모두 풀기</button></div>'
         +'</div>'
       : '');
  document.getElementById('mvList').innerHTML = cds.map(function(c){
      var o=_bycd[c]||{}, off=!_vis[c];
      return '<span style="'+(off?'color:#b02a2a;font-weight:700':'')+'">'
           + (off?'⚠ ':'· ')+esc(o.bizNm||c)+' <span style="color:'+(off?'#d08a8a':'#9aa7b3')+'">['+esc(c)+']</span>'
           + (o.matchCd ? ' <span style="color:#a85700">(현재 '+esc(o.matchCd)+')</span>' : '')
           + '</span>'; }).join('<br>');
  var _uq=document.getElementById('m_usedQ'); if(_uq) _uq.value='';   // 연속으로 열 때 이전 찾기말이 남지 않게
  cliMatchUsed();
  document.getElementById('mov').classList.add('on');
  setTimeout(function(){ document.getElementById('m_cd').focus(); }, 30);
}
function cliMatchClose(){ document.getElementById('mov').classList.remove('on'); }
/* 이미 쓰고 있는 매칭 목록 — 서버에 다시 묻지 않고 <이미 받아 둔 전체 목록(_ALL)>에서 센다.
   ★_view(검색 결과)가 아니라 _ALL 을 봐야 한다 — 검색 중에도 전체 매칭이 보여야 고를 수 있다. */
function cliMatchUsed(){
  var box=document.getElementById('m_used'); if(!box) return;
  var m={}, ord=[];
  (_ALL||[]).forEach(function(o){
    var c=(''+(o.matchCd||'')).trim(); if(!c) return;
    if(!m[c]){ m[c]={cd:c, nm:(''+(o.matchNm||'')).trim(), n:0}; ord.push(m[c]); }
    m[c].n++;
    if(!m[c].nm && o.matchNm) m[c].nm=(''+o.matchNm).trim();
  });
  /* ★최근에 만든 것이 <맨 위>로 (2026-08-28) — 오름차순이면 방금 만든 매칭이 목록 맨 끝에 박혀
       스크롤해야 보인다. 바로 이어서 그 매칭에 더 담는 일이 가장 잦다. */
  ord.sort(function(a,b){ return b.cd.localeCompare(a.cd); });
  var all=ord.length;
  var cnt=document.getElementById('m_usedCnt');
  if(!all){
    if(cnt) cnt.textContent='';
    box.innerHTML='<div style="height:100%;display:flex;align-items:center;justify-content:center;color:#9aa7b3;font-size:12.5px">아직 지정된 매칭이 없습니다 — 아래에서 새로 만드세요.</div>';
    return;
  }
  /* 찾기 — 코드·이름 어디든 부분일치. 매칭이 수십 개로 늘어도 한 줄 안에서 찾을 수 있게. */
  var qe=document.getElementById('m_usedQ'), q=((qe&&qe.value)||'').trim().toLowerCase();
  var view = q ? ord.filter(function(x){ return (x.cd+' '+x.nm).toLowerCase().indexOf(q)>=0; }) : ord;
  if(cnt) cnt.textContent = q ? ('('+view.length+' / '+all+'개)') : ('('+all+'개)');
  if(!view.length){
    box.innerHTML='<div style="height:100%;display:flex;align-items:center;justify-content:center;color:#9aa7b3;font-size:12.5px">찾는 매칭이 없습니다 — 아래에서 새 코드를 만드세요.</div>';
    return;
  }
  var cur=(document.getElementById('m_cd')||{}).value||'';
  box.innerHTML = view.map(function(x){
    return '<button type="button" class="mchip'+(x.cd===cur?' on':'')+'" data-cd="'+esc(x.cd)+'" data-nm="'+esc(x.nm)+'"'
         + ' onclick="cliMatchPick(this)" title="이 매칭에 추가합니다 (현재 '+x.n+'곳)">'
         + '<span class="cd">'+esc(x.cd)+'</span>'
         + '<span class="nm">'+esc(x.nm||'(이름없음)')+'</span>'
         + '<span class="n">'+x.n+'곳</span></button>';
  }).join('');
  /* ★자동 선택은 하지 않는다 — 목록은 <보여 주는> 것이고, 고르는 건 사용자가 눌러서 한다.
       거르다가 잠깐 하나만 남았다고 값이 저절로 바뀌면 엉뚱한 매칭으로 지정될 수 있다. */
}
function cliMatchPick(el){
  document.getElementById('m_cd').value=el.getAttribute('data-cd');
  document.getElementById('m_nm').value=el.getAttribute('data-nm');
  var box=document.getElementById('m_used');
  Array.prototype.forEach.call(box.querySelectorAll('.mchip'),function(b){ b.classList.remove('on'); });
  el.classList.add('on');
}
function cliMatchNext(){
  fetch(CTX+'/mangr/clientMatchNext.do', { method:'POST', credentials:'same-origin' })
    .then(function(r){ return r.json(); })
    .then(function(j){ if(j&&j.matchCd){ document.getElementById('m_cd').value=j.matchCd; document.getElementById('m_nm').focus(); } })
    .catch(function(e){ toast('⚠️ 채번 실패: '+e.message); });
}
function cliMatchSave(){
  var cds=cliChkList(), cd=gv('m_cd'), nm=gv('m_nm');
  if(!cds.length){ toast('⚠️ 고른 사업장이 없습니다.'); return; }
  if(!cd){ toast('⚠️ 매칭코드를 입력하거나 [자동채번]을 누르세요.'); document.getElementById('m_cd').focus(); return; }
  /* ★지정한 뒤에도 체크를 푼다 (2026-08-28 요청) — 안 풀면 다음 매칭을 줄 때 그대로 딸려 들어간다.
       실제로 그 사고가 났다 : 파스타입니다 28곳이 배고픈덮밥(M0002)에 섞여 들어갔다. */
  cliMatchPost(cds, cd, nm, '🔗 매칭코드 '+cd+' 지정', true);
}
/* 선택목록 매칭해제 — 대상은 <체크한 사업장>이다 (2026-08-28 확정).
   ★한때 「보이는 목록 전체」로 만들었다가 되돌렸다. 검색 결과 전체를 지우는 것은 되돌리기 어렵고,
     실제로 필요한 건 「고른 것만 빼기」였다. 지우기 전에 <어떤 매칭이 몇 곳> 빠지는지 보여 준다. */
function cliMatchClear(){
  var cds=cliChkList();
  if(!cds.length){ toast('⚠️ 왼쪽 <b>체크</b>로 해제할 사업장을 먼저 고르세요.'); return; }
  var has=cds.filter(function(c){ var o=_bycd[c]||{}; return (''+(o.matchCd||'')).trim(); });
  if(!has.length){ toast('⚠️ 고른 사업장에 <b>매칭이 없습니다</b> — 지울 것이 없습니다.'); return; }
  var by={}, ord=[];
  has.forEach(function(c){ var o=_bycd[c]||{}, m=(''+(o.matchCd||'')).trim();
    if(!by[m]){ by[m]={cd:m, nm:(''+(o.matchNm||'')).trim(), n:0}; ord.push(by[m]); } by[m].n++; });
  ord.sort(function(a,b){ return b.n-a.n; });
  var msg='고른 <b>'+cds.length.toLocaleString()+'</b>곳 중 매칭이 있는 <b style="color:#b02a2a">'
        + has.length.toLocaleString()+'</b>곳의 매칭코드를 지웁니다.'
        + '<div style="margin-top:8px;font-size:12.5px;color:#5a6b7a;text-align:left;max-height:96px;overflow:auto">'
        + ord.map(function(x){ return '· '+esc(x.cd)+' '+esc(x.nm||'(이름없음)')+' — '+x.n+'곳'; }).join('<br>')
        + '</div><div style="margin-top:7px;font-size:12px;color:#9aa7b3">사업장 자료 자체는 그대로입니다.</div>';
  swConfirm(msg, '↩ 선택목록 매칭해제', {okText:'해제'})
    /* 해제한 뒤에는 체크도 푼다 — 코드를 지운 줄이 체크로 남으면 다음 지정 때 딸려 들어간다 */
    .then(function(ok){ if(ok) cliMatchPost(has, '', '', '↩ 선택목록 매칭해제', true); });
}
function cliMatchPost(cds, cd, nm, msg, clearChk){
  fetch(CTX+'/mangr/clientMatchSet.do', { method:'POST', headers:{'Content-Type':'application/json'},
        credentials:'same-origin', body:JSON.stringify({ bizCds:cds, matchCd:cd, matchNm:nm }) })
    .then(function(r){ return r.text().then(function(t){ return {ok:r.ok, t:t}; }); })
    .then(function(x){
      if(!x.ok){ toast('⚠️ 저장 실패: '+x.t); return; }
      cliMatchClose();
      toast(msg+' — <b>'+x.t+'</b>건');
      if(clearChk) _mchk={};        // 해제한 줄은 체크도 푼다
      /* ★다시 조회한다 — 화면 값만 고치면 새로고침 때 되돌아가 「저장된 줄 알았는데」가 된다. */
      cliLoad();
    })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}

var _sel=null;
function _selReset(){ _sel=null; }
function cliSel(tr,cd){
  var tb=document.getElementById('tb');
  Array.prototype.forEach.call(tb.querySelectorAll('tr.sel'),function(r){ r.classList.remove('sel'); });
  tr.classList.add('sel'); _sel=cd;
}
function cliEditSel(){ if(!_sel){ toast('⚠️ 수정할 행을 먼저 선택하세요.'); return; } cliOpen(_sel); }
function cliDelSel(){ if(!_sel){ toast('⚠️ 삭제할 행을 먼저 선택하세요.'); return; } cliDel(_sel); }
function cliExcel(){
  var list=_view; if(!list.length){ toast('⚠️ 출력할 데이터가 없습니다.'); return; }
  var head=['매칭코드','매칭명칭','코드','사업장명','약칭','거래구분','사업자번호','대표자','업태','종목','우편번호','주소','상세주소','전화','팩스','휴대폰','이메일','담당자','정렬','비고','택배주소(실제사용)','택배수령자','택배전화(실제사용)','택배휴대폰(실제사용)','택배운임'];
  var aoa=[head].concat(list.map(function(o){ return [o.matchCd,o.matchNm,o.bizCd,o.bizNm,o.bizSmallNm,o.bizGb,o.bizno,o.ceoNm,o.bizCond,o.bizItem,o.zipcd,o.addr,o.addr2,o.tel,o.fax,o.hp,o.email,o.manager,o.sortOrd,o.remark,(o.parcelAddr||o.addr||''),o.parcelNm,(o.parcelTel||o.tel||''),(o.parcelHp||o.hp||''),o.parcelFee]; }));
  var P=window.parent;
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'거래처'); LIB.writeFile(wb,'거래처.xlsx'); toast('📥 엑셀 저장 완료 · '+list.length+'건'); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csv(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csv();
  function csv(){ var c=aoa.map(function(r){ return r.map(function(x){ x=(x==null?'':(''+x)); return '"'+x.replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var b=new Blob(['﻿'+c],{type:'text/csv;charset=utf-8'}), a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download='거래처.csv'; document.body.appendChild(a); a.click(); a.remove(); toast('📥 CSV 저장 완료'); }
}
/* ══════════════════════════════════════════════════════════════════════════
   키보드 편의 (2026-08-04 요청) — 매입/매출 거래처·상품코드 등록 화면과 같은 규칙
     목록 : 진입 시 검색칸 포커스 · ↑↓ 줄 이동 · Enter 수정 · Alt+N 추가
     창   : Enter 다음 칸(마지막 칸에서는 저장) · Ctrl+S 저장 · Esc 닫기
   ══════════════════════════════════════════════════════════════════════════ */
function cliOvOpen(){ return document.getElementById('ov').classList.contains('on'); }
/* 창 안 이동 순서 = 화면에 보이는 순서. 비고(textarea)는 줄바꿈이 필요해 뺀다 */
var CLI_FLOW=['f_cd','f_gb','f_nm','f_snm','f_bizno','f_ceo','f_mgr','f_cond','f_item','f_zip','f_sort',
              'f_addr','f_addr2','f_tel','f_fax','f_hp','f_email','f_paddr','f_pnm','f_ptel','f_php','f_pfee'];
function cliNext(id){
  var i=CLI_FLOW.indexOf(id); if(i<0) return null;
  for(var k=i+1;k<CLI_FLOW.length;k++){
    var el=document.getElementById(CLI_FLOW[k]);
    if(el && !el.readOnly && !el.disabled) return el;      // 수정 시 잠긴 사업장코드 같은 칸은 건너뛴다
  }
  return null;                                             // 마지막 칸 = 저장
}
document.getElementById('ov').addEventListener('keydown', function(e){
  if(e.key!=='Enter') return;
  var t=e.target; if(!t || CLI_FLOW.indexOf(t.id)<0) return;   // 비고는 여기 없어 줄바꿈이 그대로 된다
  e.preventDefault();
  var nx=cliNext(t.id);
  if(nx){ nx.focus(); if(nx.select) nx.select(); }
  else cliSave();                                          // 이메일 칸에서 Enter = 저장
});
document.addEventListener('keydown', function(e){
  if((e.ctrlKey||e.metaKey) && (e.key==='s'||e.key==='S')){
    if(cliOvOpen()){ e.preventDefault(); cliSave(); }
    return;
  }
  if(e.altKey && (e.key==='n'||e.key==='N')){ e.preventDefault(); cliOpen(); return; }
  /* 매칭창이 떠 있으면 그것부터 처리한다 — Esc 로 닫고 Enter 로 지정 */
  if(document.getElementById('mov') && document.getElementById('mov').classList.contains('on')){
    if(e.key==='Escape'){ e.preventDefault(); cliMatchClose(); }
    else if(e.key==='Enter'){ e.preventDefault(); cliMatchSave(); }
    return;
  }
  if(e.key==='Escape' && cliOvOpen()){ e.preventDefault(); cliClose(); return; }
  if(cliOvOpen()) return;                                  // 창이 떠 있으면 아래 목록 조작은 안 한다

  var t=e.target, tag=(t&&t.tagName||'').toUpperCase();
  if((tag==='INPUT'||tag==='SELECT'||tag==='TEXTAREA') && t.id!=='q') return;
  // ★검색칸의 Enter 는 건드리지 않는다 — 이 화면은 서버로 다시 조회하는 검색이라 Enter 가 [조회]다
  if(e.key==='Enter' && t.id==='q') return;
  if(e.key==='ArrowDown'){ e.preventDefault(); cliRowMove(1); }
  else if(e.key==='ArrowUp'){ e.preventDefault(); cliRowMove(-1); }
  else if(e.key==='Enter'){
    if(!_sel){ cliRowMove(1); return; }                    // 아직 고른 줄이 없으면 첫 줄부터
    e.preventDefault(); cliOpen(_sel);
  }
});
/* ↑↓ 행 이동 — 스크롤로 이어 그리는 목록이라, 끝줄에서 더 내려가면 다음 묶음을 먼저 그린다 */
function cliRowMove(d){
  var tb=document.getElementById('tb');
  var rows=Array.prototype.slice.call(tb.querySelectorAll('tr[data-cd]'));
  if(!rows.length) return;
  var i=-1;
  if(_sel) for(var k=0;k<rows.length;k++){ if(rows[k].getAttribute('data-cd')===_sel){ i=k; break; } }
  var n=(i<0) ? (d>0?0:rows.length-1) : i+d;
  if(n>=rows.length){
    if(_shown<_view.length){
      _shown=Math.min(_shown+CHUNK, _view.length); cliRender();
      rows=Array.prototype.slice.call(tb.querySelectorAll('tr[data-cd]'));
    }
    if(n>=rows.length) n=rows.length-1;                    // 맨 끝이면 제자리
  }
  if(n<0) n=0;
  var tr=rows[n]; if(!tr) return;
  cliSel(tr, tr.getAttribute('data-cd'));
  if(tr.scrollIntoView) tr.scrollIntoView({block:'nearest'});
}

cliLoad();
/* 진입하면 검색칸에 커서 — 이름을 쳐서 찾는 것이 이 화면의 첫 동작이다 */
(function(){ var q=document.getElementById('q'); if(q) q.focus(); })();
</script>
</body>
</html>
