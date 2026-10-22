<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>직원 휴가 관리</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 📥 엑셀 (전역 XLSX) --%>
<%--
  직원 휴가 관리 (2026-10-21 신설 — 사용자 「기존 직원 휴가 내용을 메시지로 처리하고 있는데 연차·월차·반차·병가 등 구분으로 직원별 휴가 관리,
                                     메뉴는 직원 메신저 밑에, 달력으로 한눈에, 총괄관리자는 현황을 한눈에, 엑셀 월별·연별·사원별」, 직원 10명 정도)
    · 셸 iframe(logiFrame('leaveMng')) · 자바 /mangr/leave*.do · 표 TBL_LEAVE_MST / TBL_LEAVE_QUOTA (docs/sql/20261021_leave.sql)
    · 왼쪽 = 달력(그 달 휴가가 직원 이름 칩으로, 구분마다 색) · 오른쪽 = 연간 현황(직원마다 연차·월차 부여/사용/잔여, 반차·병가·경조·공가·기타 건수, 신청 대기)
      ([📋 목록] 보기는 2026-10-22 사용자 지시로 단추를 뺐다 — 코드는 남아 있음)
    · 권한 = 서버가 정한다(leaveUsers.do 의 admin). 등록·수정·삭제는 본인 휴가만(총괄관리자도) · 승인 전 상태만. 총괄관리자 본인 것은 저장 즉시 승인. 승인·반려·부여 일수(입사일·이월 포함)·휴가 구분은 총괄관리자만
      (2026-10-21 사용자 「기존 정보 설정은 총괄관리자가 수정할 수 있게」「수정은 본인 것만」)
    · 일수 = 평일 수(토·일 뺌, 공휴일은 안 뺀다 — 손으로 고칠 수 있음) · 반일 구분(반차) = 0.5 하루
    · 휴가 구분 = 회사 설정(SET_JSON 'leave', leaveUsers.do 의 gbs) — 총괄관리자가 [⚙ 휴가 구분]에서 이름·종류(연차 차감/월차 차감/별도)·반일·색·사용을 고친다
      (2026-10-21 「휴가 구분은 설정 아닌가요」). 서버 저장 검사도 같은 목록. 현황 표의 칸은 구분 목록에 따라 바뀐다
    · 엑셀 = 월별(지금 달 줄) · 연별(연도마다 시트 + 연도별 현황) · 사원별(전 연도를 직원 차례로, 소계) · 연차 양식(사용자 수기 양식 연차양식.xlsx 모양 — 연차 현황·사용 날짜·날인 대장). 목록 시트 끝에 「날인」 빈 칸
    · 달력 셀 빈 곳 더블클릭 = 그 날짜로 등록 창 · 칩 더블클릭 = 그 휴가 열기 (2026-10-21 「달력은 더블클릭으로」 — 한 번 클릭은 아무 일도 없다)
    · 등록 창 「여러 날짜」 (2026-10-21 「월별 및 연으로 등록도 가능하게」) — 작은 달력을 넘기며 날짜를 여러 개 찍거나 「10/23, 11/06 …」 글로 붙여 넣으면
      날짜마다 한 건씩(/mangr/leaveSaveMulti.do). 한 해 치를 한 번에 넣는 용도. 겹치는 날짜는 건너뛰고 알려 준다
--%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --blue:#2f4f9a; --purple:#6b4fa0; --amber:#b45309; --gray:#5a6b7a; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; background:#fff; }
  .lv-wrap{ padding:14px 12px 16px; }
  .lv-head{ display:flex; align-items:baseline; gap:10px; margin-bottom:6px; }
  .lv-head h2{ margin:0; font-size:19px; font-weight:800; color:#1f2a37; }
  .lv-head .desc{ font-size:12.5px; color:var(--gray); }
  .lv-bar{ display:flex; align-items:center; gap:6px; flex-wrap:wrap; margin:6px 0 10px; }
  .lv-btn{ height:32px; padding:0 12px; border:1px solid var(--bd); border-radius:7px; background:#fff; font-size:13px; font-weight:700; cursor:pointer; color:#1f2a37; white-space:nowrap; }
  .lv-btn:hover{ border-color:var(--teal); color:var(--teal); }
  .lv-btn.teal{ background:var(--teal); border-color:var(--teal); color:#fff; } .lv-btn.teal:hover{ background:#0f6457; color:#fff; }
  .lv-btn.red{ color:var(--red); border-color:#e3b0a9; } .lv-btn.on{ background:#e6f4f1; border-color:var(--teal); color:var(--teal); } .lv-btn:disabled{ cursor:default; opacity:.9; }
  .lv-btn.xls{ background:#e9f7ee; border-color:#bfe3cc; color:#1e7a46; }
  .lv-bar select, .lv-bar input{ height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; }
  .lv-ym{ font-size:17px; font-weight:800; min-width:130px; text-align:center; }
  .lv-sep{ width:1px; height:24px; background:var(--bd); margin:0 4px; }
  .lv-main{ display:flex; gap:12px; align-items:flex-start; }
  .lv-left{ flex:1 1 640px; min-width:520px; }
  .lv-right{ flex:0 0 560px; }
  /* 달력 */
  .cal{ width:100%; border-collapse:collapse; table-layout:fixed; }
  .cal th{ background:#b9ded4; color:#0b4f43; font-weight:800; padding:6px 0; border:1px solid var(--bd); font-size:13px; }
  .cal th.sun{ color:#c0392b; } .cal th.sat{ color:#2f4f9a; }
  .cal td{ border:1px solid var(--bd); vertical-align:top; height:92px; padding:3px 4px; cursor:default; background:#fff; user-select:none; }
  .cal td:hover{ background:#f7fbfa; }
  .cal td.out{ background:#fafbfc; color:#b0bac4; cursor:default; } .cal td.out:hover{ background:#fafbfc; }
  .cal td.wend{ background:#fcfcfd; } .cal td.today{ outline:2px solid var(--teal); outline-offset:-2px; background:#f1f9f7; }
  .cal .dn{ font-size:13px; font-weight:800; color:#3d4d5c; margin-bottom:2px; display:flex; justify-content:space-between; }
  .cal td.out .dn{ color:#b0bac4; } .cal .dn .sun{ color:#c0392b; } .cal .dn .sat{ color:#2f4f9a; }
  .cal .dn .cnt{ font-size:11px; font-weight:700; color:var(--gray); }
  .chip{ display:block; font-size:12px; font-weight:700; line-height:1.35; padding:1px 5px; margin:1px 0; border-radius:5px; color:#fff; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; cursor:pointer; }
  .chip.pend{ opacity:.75; outline:2px dashed rgba(0,0,0,.25); outline-offset:-2px; }
  .chip.rej{ text-decoration:line-through; opacity:.45; }
  .chip:hover{ filter:brightness(.92); }
  .chip.gb-x{ background:#5a6b7a; }   /* 구분별 색은 gbApply() 가 #gbCss 에 .gb-0 ~ .gb-N 으로 만든다 (2026-10-21 구분 = 설정) */
  .gbt td{ padding:3px 4px; } .gbt input[type=text]{ width:100%; height:28px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; }
  .gbt select{ height:28px; border:1px solid var(--bd); border-radius:6px; } .gbt input[type=color]{ width:36px; height:28px; border:1px solid var(--bd); border-radius:6px; padding:0; background:#fff; }
  .legend{ display:flex; gap:10px; flex-wrap:wrap; font-size:12px; color:#3d4d5c; margin-top:6px; align-items:center; }
  .legend i{ display:inline-block; width:12px; height:12px; border-radius:3px; vertical-align:-1px; margin-right:3px; }
  /* 현황·목록 표 */
  .box{ border:1px solid var(--bd); border-radius:8px; overflow:hidden; }
  .box .bh{ display:flex; align-items:center; gap:8px; padding:7px 10px; background:#eef5f3; border-bottom:1px solid var(--bd); font-weight:800; color:#0b4f43; font-size:13.5px; }
  .box .bh small{ font-weight:400; color:var(--gray); }
  table.grid{ width:100%; border-collapse:collapse; font-size:13px; }
  table.grid th{ background:#f3f6f8; color:#3d4d5c; font-weight:800; padding:5px 4px; border:1px solid var(--bd); white-space:nowrap; text-align:center; }
  table.grid td{ padding:4px 5px; border:1px solid var(--bd); text-align:center; white-space:nowrap; }
  table.grid td.l{ text-align:left; } table.grid td.r{ text-align:right; }
  table.grid tr.pick:hover td{ background:#f7fbfa; cursor:pointer; }
  table.grid tr.tot td{ background:#eef5f3; font-weight:800; }
  table.grid tr.me td{ background:#fffbea; }
  table.grid tr.on td{ background:#cfeae3 !important; font-weight:800; } table.grid tr.on td:first-child{ box-shadow:inset 4px 0 0 #137a6c; }   /* 현황에서 고른 직원 (2026-10-21) */
  .rem{ color:var(--teal); font-weight:800; } .rem.neg{ color:var(--red); }
  .st{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .st.신청{ background:#fff1e0; color:#9a4b00; border:1px solid #f0c9a4; } .st.승인{ background:#e6f4f1; color:#137a6c; } .st.반려{ background:#fdecec; color:#c0392b; }
  .msg{ padding:16px; text-align:center; color:var(--gray); font-size:13px; }
  .mini{ height:24px; padding:0 7px; font-size:12px; border:1px solid var(--bd); border-radius:5px; background:#fff; cursor:pointer; margin:0 1px; }
  .mini:hover{ border-color:var(--teal); color:var(--teal); } .mini.ok{ color:#137a6c; } .mini.no{ color:#c0392b; }
  /* 팝업 */
  .pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:50; align-items:center; justify-content:center; }
  .pop.on{ display:flex; }
  .pop .bx{ background:#fff; border-radius:12px; width:min(560px, 96vw); max-height:92vh; overflow:auto; box-shadow:0 12px 40px rgba(0,0,0,.25); }
  .pop .hd{ display:flex; align-items:center; gap:8px; padding:12px 16px; border-bottom:1px solid var(--bd); font-weight:800; font-size:15px; }
  .pop .bd{ padding:12px 16px; } .pop .ft{ display:flex; gap:8px; padding:10px 16px; border-top:1px solid var(--bd); align-items:center; }
  .fld{ display:flex; align-items:center; gap:8px; margin:7px 0; }
  .fld label{ flex:0 0 76px; font-size:13px; font-weight:700; color:#3d4d5c; }
  .fld input, .fld select, .fld textarea{ flex:1; height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 9px; font-size:13.5px; font-family:inherit; }
  .fld textarea{ height:64px; padding:7px 9px; resize:vertical; }
  .fld input[readonly]{ background:#f5f7f9; color:#5a6b7a; }
  .ejoin{ flex:1; } .ejoin table{ border-collapse:collapse; font-size:12.5px; width:100%; }   /* 휴가 창의 입사일·연차 표 (2026-10-21) */
  .ejoin th{ background:#eef3f7; font-weight:700; color:#3d4d5c; padding:3px 6px; border:1px solid #d5dde5; text-align:center; white-space:nowrap; }
  .ejoin td{ padding:3px 6px; border:1px solid #d5dde5; text-align:center; color:#1f2d3a; white-space:nowrap; } .ejoin td.rem{ font-weight:700; color:#1f7a8c; } .ejoin td.none{ color:#8a98a8; }
  #sumTbl td.yr{ font-weight:700; vertical-align:middle; background:#f3f6f9; color:#2a3b4c; }   /* 연도별 현황의 연도 칸 (2026-10-21) */
  /* 보기 전용 창 : 잠근 칸도 글자는 또렷하게 (2026-10-21 「표시 활성화하고 저장만 없애면 — 글자가 희미해서」) */
  #lvPop .fld input:disabled, #lvPop .fld select:disabled, #lvPop .fld textarea:disabled, #lvPop .fld input[readonly]{ color:#1f2d3a; -webkit-text-fill-color:#1f2d3a; opacity:1; background:#f7f9fb; border-color:#d5dde5; cursor:default; }
  .hint{ font-size:12px; color:var(--gray); }
  /* 승인 대기 — 2026-10-22 「표시부분 다른 그리드처럼」 : 띠(flex 줄) → table.grid 로. 칸마다 테두리(위 table.grid 와 같은 선) */
  table.grid td.who{ font-weight:800; }
  table.grid.pend2 th.gap, table.grid.pend2 td.gap{ width:10px; border-top:0; border-bottom:0; background:#f7f9fb; padding:0; }   /* 두 건 사이 틈 */
  table.grid.pend2 td.blank{ background:#fafbfc; }
  .ulScroll{ overflow:auto; }   /* 직원 휴가 목록 — 15줄까지는 그대로, 넘으면 ulFit() 이 max-height 를 준다 */
  .ulScroll thead th{ position:sticky; top:0; z-index:1; box-shadow:0 1px 0 var(--bd); }   /* 스크롤해도 머리줄은 남는다 */
  .ul-more{ text-align:center; font-size:12px; font-weight:700; color:#137a6c; background:#eef5f3; border-top:1px solid var(--bd); padding:4px 0; cursor:pointer; }   /* 「▼ 아래 N건 더」 — 끝까지 내리면 사라진다 */
  /* 여러 날짜 고르기 (작은 달력) */
  .mode{ display:flex; gap:4px; margin-bottom:6px; } .mode .lv-btn{ height:28px; font-size:12.5px; padding:0 10px; }
  .mcal{ width:100%; border-collapse:collapse; table-layout:fixed; font-size:12.5px; }
  .mcal th{ background:#eef5f3; color:#0b4f43; padding:3px 0; border:1px solid var(--bd); }
  .mcal td{ border:1px solid var(--bd); text-align:center; height:30px; cursor:pointer; }
  .mcal td:hover{ background:#f1f9f7; } .mcal td.out{ color:#c3ccd5; background:#fafbfc; } .mcal td.wend{ color:#9aa6b2; background:#fcfcfd; }
  .mcal td.sel{ background:var(--teal); color:#fff; font-weight:800; } .mcal td.has{ box-shadow:inset 0 -3px 0 #e3b0a9; }
  .mhd{ display:flex; align-items:center; gap:6px; margin:4px 0; font-weight:800; }
  .mhd .lv-btn{ height:26px; padding:0 8px; font-size:12px; }
  .dsel{ display:flex; flex-wrap:wrap; gap:4px; margin-top:6px; min-height:24px; }
  .dsel span{ background:#e6f4f1; color:#137a6c; border-radius:6px; padding:1px 7px; font-size:12px; font-weight:700; cursor:pointer; }
  .dsel span:hover{ background:#fdecec; color:#c0392b; text-decoration:line-through; }
  @media (max-width:1180px){ .lv-main{ flex-direction:column; } .lv-right{ flex:1 1 auto; width:100%; } .lv-left{ min-width:0; } }
</style>
<style id="gbCss"></style>
</head>
<body>
<div class="lv-wrap">
  <div class="lv-head"><h2>🏖 직원 휴가 관리</h2><span class="desc" title="등록·수정·삭제는 본인 휴가만(총괄관리자도 같음, 「신청」 상태). 승인된 휴가는 본인도 고치거나 지울 수 없고(총괄관리자가 「신청으로」 되돌린 뒤), 다른 직원 휴가는 누구나 보기만 합니다. 승인·반려·부여 일수·휴가 구분 설정은 총괄관리자가 합니다.">본인 휴가만 등록·수정(신청 상태) · 승인된 휴가는 수정 불가 · 승인·부여일수·구분 설정은 총괄관리자</span></div>

  <div class="lv-bar">
    <button class="lv-btn" onclick="lvMove(-1)" title="지난 달">◀</button>
    <span class="lv-ym" id="lvYm">—</span>
    <button class="lv-btn" onclick="lvMove(1)" title="다음 달">▶</button>
    <button class="lv-btn" onclick="lvToday()">오늘</button>
    <span class="lv-sep"></span>
    <%-- [📅 달력]·[📋 목록] 전환 단추는 2026-10-22 사용자 「목록은 제거」로 뺐다 — lvView()·listWrap 은 남아 있어 단추만 되넣으면 목록 보기가 돌아온다 --%>
    <span class="lv-sep"></span>
    <label style="font-size:12.5px; font-weight:700">직원</label>
    <select id="fUser" onchange="lvRender()" title="달력·목록을 이 직원만 보기"><option value="">전체</option></select>
    <label style="font-size:12.5px; font-weight:700">구분</label>
    <select id="fGb" onchange="lvRender()" title="달력·목록을 이 구분만 보기"><option value="">전체</option></select>
    <span style="margin-left:auto"></span>
    <button class="lv-btn teal" id="btnNew" onclick="lvOpen(null,null)">＋ 휴가 등록</button>
    <button class="lv-btn xls" onclick="xlsMonth()" title="지금 달의 휴가 줄을 엑셀로">📥 월별</button>
    <button class="lv-btn xls" onclick="xlsYear()" title="올해(달력의 해) 휴가 줄 전체 + 현황 시트">📥 연별</button>
    <button class="lv-btn xls" onclick="xlsUser()" title="전 연도 휴가를 직원 차례로 한 시트에(직원마다 소계) + 연도별 현황 시트. 직원을 골라 두면 그 직원만">📥 사원별</button>
    <button class="lv-btn xls" onclick="xlsForm()" title="사용자 수기 양식(연차양식.xlsx) 모양 — 그 해 연차 현황(입사일·이월·부여·월별 사용)·직원별 사용 날짜·날인 대장">📥 연차 양식</button>
    <button class="lv-btn" id="btnGb" style="display:none" onclick="gbOpen()" title="휴가 구분(연차·월차·반차·병가 …) 이름·종류·반일·색을 정합니다 — 총괄관리자">⚙ 휴가 구분</button>
    <button class="lv-btn" id="btnQuota" style="display:none" onclick="qtOpen()" title="직원마다 올해 연차·월차 부여 일수 — 현황의 「잔여」 계산에 쓴다">⚙ 부여 일수</button>
  </div>

  <div class="lv-main">
    <div class="lv-left">
      <div id="calWrap">
        <%-- 승인 대기 띠 (2026-10-21 사용자 「총괄관리인데 승인·반려가 없음」 — 달력에서는 승인·반려가 보이지 않았다). 총괄관리자에게만, 그 달 「신청」 건을 줄줄이 + 바로 승인·반려 --%>
        <div id="pendBar" class="box" style="display:none; margin-bottom:8px"></div>
        <table class="cal"><thead><tr><th class="sun">일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th class="sat">토</th></tr></thead><tbody id="calBody"></tbody></table>
        <div class="legend" id="legend"></div>
      </div>
      <div id="listWrap" style="display:none" class="box">
        <div class="bh">📋 <span id="listTitle">휴가 목록</span> <small id="listCnt"></small></div>
        <table class="grid"><thead><tr><th style="width:90px">직원</th><th style="width:84px">구분</th><th style="width:190px">기간</th><th style="width:52px">일수</th><th>사유</th><th style="width:120px">상태</th><th style="width:120px">신청일</th><th style="width:170px"></th></tr></thead>
          <tbody id="listBody"><tr><td colspan="8" class="msg">불러오는 중…</td></tr></tbody></table>
      </div>
    </div>
    <div class="lv-right">
      <div class="box">
        <div class="bh">📊 <span id="sumTitle">연도별 현황</span> <small>부여 − 사용 = 잔여 · 반려 제외 · 이름을 누르면 아래에 그 직원·그 연도 목록</small></div>
        <table class="grid" id="sumTbl">
          <thead id="sumHead"></thead>
          <tbody id="sumBody"><tr><td colspan="13" class="msg">불러오는 중…</td></tr></tbody>
        </table>
        <div class="hint" style="padding:6px 10px" id="sumHint">반일 구분(반차)은 0.5일로 그 종류(연차·월차)의 사용에 들어갑니다. 공휴일은 일수에서 자동으로 빠지지 않으니 등록 창에서 일수를 고치세요.</div>
      </div>
    <%-- 고른 직원의 올해 휴가 목록 (2026-10-21 사용자 「현황에서 대상자를 클릭하면 밑에 해당자 휴가 리스트」) — 현황 이름 클릭 = 달력 거르기 + 이 목록 --%>
    <div class="box" id="ulBox" style="display:none; margin-top:10px">
      <div class="bh">📋 <span id="ulTitle">휴가 목록</span> <small id="ulCnt"></small><button class="mini ok" id="ulAll" style="display:none; margin-left:8px; height:26px"></button><span style="margin-left:auto; cursor:pointer; color:#8a98a8" onclick="lvPickUser('')" title="닫기">✕</span></div>
      <%-- 15줄 넘으면 상자 안에서만 스크롤 (2026-10-22) — 높이는 ulFit() 이 머리줄 + 앞 15줄을 실제로 재서 정한다 --%>
      <div class="ulScroll" id="ulScroll">
      <table class="grid"><thead><tr><th style="width:84px">구분</th><th style="width:170px">기간</th><th style="width:46px">일수</th><th>사유</th><th style="width:60px">상태</th><th style="width:110px">신청일</th><th style="width:96px"></th></tr></thead>
        <tbody id="ulBody"></tbody></table>
      </div>
      <div id="ulMore" class="ul-more" style="display:none" onclick="document.getElementById('ulScroll').scrollBy({top:200,behavior:'smooth'})" title="누르면 아래로 내립니다"></div>
    </div>
    </div>
  </div>
</div>

<%-- 휴가 등록·수정 --%>
<div class="pop" id="lvPop">
  <div class="bx">
    <div class="hd"><span id="lvPopTitle">휴가 등록</span><span style="margin-left:auto; font-size:18px; cursor:pointer; color:#8a98a8" onclick="lvClose()">✕</span></div>
    <div class="bd">
      <div class="fld"><label>직원</label><select id="eUser" onchange="if(_mode==='multi') mcRender()"></select><input type="text" id="eUserNm" readonly style="display:none"></div>
      <div class="fld"><label>입사일</label><div id="eJoin" class="ejoin" title="입사일은 회사/사용자관리 또는 [⚙ 부여 일수]에서 넣습니다"></div></div>
      <div class="fld"><label>구분</label><select id="eGb" onchange="lvDays()"></select></div>
      <div class="mode" id="eMode"><label style="flex:0 0 76px; font-size:13px; font-weight:700; color:#3d4d5c">방식</label>
        <button class="lv-btn on" id="mdOne" onclick="lvMode('one')" title="하루 또는 이어지는 기간을 한 건으로">하루·기간</button>
        <button class="lv-btn" id="mdMulti" onclick="lvMode('multi')" title="달력을 넘기며 날짜를 여러 개 찍어 날짜마다 한 건씩 — 한 달 치·한 해 치를 한 번에">여러 날짜 (월별·연별)</button></div>
      <div id="oneBox">
      <div class="fld"><label>시작일</label><input type="date" id="eFrom" onchange="lvDays()"><label style="flex:0 0 auto">종료일</label><input type="date" id="eTo" onchange="lvDays()"></div>
      <div class="fld"><label>일수</label><input type="number" id="eDays" step="0.5" min="0.5" style="flex:0 0 110px"><span class="hint" id="eDaysHint">평일 수로 자동 계산 — 공휴일이 끼면 고치세요</span></div>
      </div>
      <div id="multiBox" style="display:none">
        <div class="mhd"><button class="lv-btn" onclick="mcMove(-1)">◀</button><span id="mcYm" style="min-width:110px; text-align:center"></span><button class="lv-btn" onclick="mcMove(1)">▶</button>
          <span class="hint" style="margin-left:6px">날짜를 눌러 찍고 다시 누르면 뺍니다 · 달을 넘겨 가며 한 해 치를 한 번에</span></div>
        <table class="mcal"><thead><tr><th style="color:#c0392b">일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th style="color:#2f4f9a">토</th></tr></thead><tbody id="mcBody"></tbody></table>
        <div class="fld" style="margin-top:6px"><label>글로 넣기</label><input type="text" id="mcText" placeholder="예) 10/23, 11/06, 11/13  또는  2026-12-04 2026-12-11" title="달력의 해 기준. 쉼표·빈칸으로 나눠 적습니다"><button class="lv-btn" style="flex:0 0 auto" onclick="mcParse()">＋ 추가</button></div>
        <div class="dsel" id="mcSel"></div>
        <div class="hint" id="mcHint">고른 날짜 0일 — 날짜마다 한 건씩(연차 1일, 반차 0.5일) 저장됩니다. 이미 휴가가 있는 날(붉은 밑줄)은 건너뜁니다.</div>
      </div>
      <div class="fld"><label>사유·메모</label><textarea id="eRemark" maxlength="200" placeholder="예) 가족 여행 / 병원 진료"></textarea></div>
      <div class="fld" id="eStatRow" style="display:none"><label>상태</label><span id="eStat"></span></div>
    </div>
    <div class="ft">
      <button class="lv-btn red" id="eDel" style="display:none" onclick="lvDelete()">🗑 삭제</button>
      <span id="eStatBtns" style="display:none; gap:4px"></span>
      <%-- 등록 창일 때 그 날짜에 이미 있는 휴가 — 저장·닫기 줄 왼쪽(2026-10-21 「두번째 위치」). 하나뿐이면 애초에 수정 창이 바로 열린다(lvOpen) --%>
      <span id="eExist" style="display:none; align-items:center; gap:4px; flex-wrap:wrap; font-size:12.5px; color:#8a4c0d"></span>
      <span style="margin-left:auto"></span>
      <button class="lv-btn" onclick="lvClose()">닫기</button>
      <button class="lv-btn teal" id="eSave" onclick="lvSave()">💾 저장</button>
    </div>
  </div>
</div>

<%-- 휴가 구분 설정 (총괄관리자) — 회사 설정 'leave' (2026-10-21) --%>
<div class="pop" id="gbPop">
  <div class="bx" style="width:min(720px,96vw)">
    <div class="hd">⚙ 휴가 구분<span class="hint" style="margin-left:6px">이름 · 종류(연차에서 뺌 / 월차에서 뺌 / 따로 셈) · 반일(0.5일, 하루) · 색 · 사용</span><span style="margin-left:auto; font-size:18px; cursor:pointer; color:#8a98a8" onclick="gbClose()">✕</span></div>
    <div class="bd">
      <table class="grid gbt"><thead><tr><th style="width:150px">이름</th><th style="width:120px">종류</th><th style="width:52px" title="하루짜리 0.5일">반일</th><th style="width:52px">색</th><th style="width:52px">사용</th><th style="width:96px">순서</th><th style="width:52px"></th></tr></thead><tbody id="gbBody"></tbody></table>
      <div style="margin-top:6px"><button class="lv-btn" onclick="gbAdd()">＋ 구분 추가</button></div>
      <div class="hint" style="margin-top:6px">이름을 바꿔도 이미 등록된 휴가의 구분 글자는 그대로 남습니다 — 그런 구분은 현황에 따로 칸이 생깁니다. 안 쓰는 구분은 지우지 말고 「사용」을 끄면 옛 자료가 그대로 보입니다.</div>
    </div>
    <div class="ft"><span style="margin-left:auto"></span><button class="lv-btn" onclick="gbClose()">닫기</button><button class="lv-btn teal" onclick="gbSave()">💾 저장</button></div>
  </div>
</div>

<%-- 부여 일수 (관리자) --%>
<div class="pop" id="qtPop">
  <div class="bx" style="width:min(900px,96vw)">
    <div class="hd">⚙ <span id="qtTitle">부여 일수</span><span class="hint" style="margin-left:6px">직원마다 입사일 · 전년 이월 · 올해 연차·월차 부여</span><span style="margin-left:auto; font-size:18px; cursor:pointer; color:#8a98a8" onclick="qtClose()">✕</span></div>
    <div class="bd">
      <table class="grid"><thead><tr><th style="width:96px">직원</th><th style="width:140px">입사일</th><th style="width:130px">근속 · 권장</th><th style="width:96px" title="비우면 자동(전년 잔여)">전년 이월</th><th style="width:84px">연차 부여</th><th style="width:84px">월차(연간)</th><th>메모</th></tr></thead><tbody id="qtBody"></tbody></table>
      <div class="hint" style="margin-top:6px">비워 둔 직원은 연차 15일 · 월차 0일로 봅니다. <b>전년 이월은 비워 두면 자동</b>(전년 잔여 = 전년 이월 + 부여 − 사용, 칸에 「자동 n」으로 미리 보임), 숫자를 넣으면 그 값으로 고정. 잔여 = 이월 + 부여 − 사용. 권장 = 1~2년차 15일, 3년차부터 2년마다 1일(최대 25), 입사한 해는 월 1일 발생 — <button class="mini" onclick="qtFill()">권장 일수로 채우기</button> · 입사일은 직원 정보에 저장되어 해마다 같습니다.</div>
    </div>
    <div class="ft"><span style="margin-left:auto"></span><button class="lv-btn" onclick="qtClose()">닫기</button><button class="lv-btn teal" onclick="qtSave()">💾 저장</button></div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var _gbs=[];   /* 휴가 구분 [{nm,kind:'annual'|'monthly'|'other',half,color,use}] — leaveUsers.do 가 준다(회사 설정 'leave', 없으면 기본 8가지) */
function gbDef(g){ g=String(g||''); for(var i=0;i<_gbs.length;i++) if(_gbs[i].nm===g) return _gbs[i]; return { nm:g, kind:'other', half:false, color:'#5a6b7a', use:true, _idx:-1 }; }
function gbHalf(g){ return !!gbDef(g).half; }
function gbUse(){ return _gbs.filter(function(g){ return g.use!==false; }); }
/* 구분별 색 CSS(.gb-0 …)·고르기 목록·범례를 목록대로 다시 만든다 */
function gbApply(){
  document.getElementById('gbCss').textContent=_gbs.map(function(g,i){ return '.chip.gb-'+i+'{ background:'+(g.color||'#5a6b7a')+'; }'; }).join('\n');
  var fg=document.getElementById('fGb'), eg=document.getElementById('eGb'), fv=fg.value;
  fg.innerHTML='<option value="">전체</option>'+gbUse().map(function(g){ return '<option>'+esc(g.nm)+'</option>'; }).join(''); fg.value=fv;
  eg.innerHTML=gbUse().map(function(g){ return '<option>'+esc(g.nm)+'</option>'; }).join('');
  var seen={}; document.getElementById('legend').innerHTML=gbUse().filter(function(g){ var k=g.nm.replace(/\(.*\)$/,''); if(seen[k]) return false; seen[k]=1; return true; }).map(function(g){ return '<span><i class="chip '+gbCls(g.nm)+'" style="display:inline-block; width:12px; height:12px; padding:0"></i>'+esc(g.nm.replace(/\(.*\)$/,''))+'</span>'; }).join('')
    +'<span style="margin-left:8px"><span class="chip pend" style="display:inline-block; background:#8a98a8; padding:0 6px">점선 = 신청(승인 대기)</span></span><span class="hint" style="margin-left:auto">빈 칸 <b>더블클릭</b> = 그 날짜로 등록 · 칩 <b>더블클릭</b> = 열기 · 마우스를 올리면 내용</span>';
}
var _ym=new Date(); _ym=new Date(_ym.getFullYear(), _ym.getMonth(), 1);
var _users=[], _me='', _meNm='', _admin=false, _rows=[], _sum=[], _quota=[], _view='cal', _cur=null, _yearRows=null;
var _ulList=[];   /* 직원별 목록에 지금 보이는 자료 (2026-10-21) */
function allRows(){ return _rows.concat(_allRows||[]); }   /* 번호로 휴가를 찾을 때 — 달력 달 + 전 연도 자료에서 */
function n(v){ var x=parseFloat(String(v==null?'':v).replace(/,/g,'')); return isNaN(x)?0:x; }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }).then(function(r){ return r.json(); }).then(function(j){ if(j&&j.error) throw new Error(j.error); return j; }); }
function swErr(m){ if(window._alertBox) _alertBox(m,{icon:'❌',okColor:'red'}); else alert(String(m).replace(/<[^>]+>/g,'')); }
function toast(m,k){ if(window._toast) _toast(m,k||'ok'); }
function ymd(d){ return d.getFullYear()+('0'+(d.getMonth()+1)).slice(-2)+('0'+d.getDate()).slice(-2); }
function iso(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function fmtDt(s){ s=String(s||'').replace(/-/g,''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function fmtD(v){ var x=n(v); return (Math.round(x*10)/10).toLocaleString('ko-KR'); }
function gbCls(g){ g=String(g||''); for(var i=0;i<_gbs.length;i++) if(_gbs[i].nm===g) return 'gb-'+i; return 'gb-x'; }
function gbShort(g){ return String(g||'').replace('(오전)','AM').replace('(오후)','PM'); }
function weekdays(a,b){ var d=new Date(a.getTime()), c=0; while(d<=b){ var w=d.getDay(); if(w!==0&&w!==6) c++; d.setDate(d.getDate()+1); } return c; }
function yearOf(){ return String(_ym.getFullYear()); }   /* 달력의 연도 — 부여 일수 설정·월별 엑셀 기준 */
var _allRows=[], _years=[], _sumYears={};
/* 전년 이월 (2026-10-21 「2027년은 자동 이월」) : 부여 줄의 carryDays 가 숫자면 고정, 비어 있으면(NULL) 서버가 낸 전년 잔여(auto), 그것도 없으면 0 */
function autoOf(y, uid){ var a=(_sumYears[y]||{}).auto||{}; return a[uid]!=null ? n(a[uid]) : null; }
function carryFixed(y, uid){ var q=((_sumYears[y]||{ quota:[] }).quota||[]).filter(function(x){ return x.userId===uid; })[0]; return (q && q.carryDays!=null && q.carryDays!=='') ? n(q.carryDays) : null; }
function carryOf(y, uid){ var f=carryFixed(y, uid); if(f!=null) return f; var a=autoOf(y, uid); return a!=null ? a : 0; }   /* 전 연도 휴가 · 자료 있는 연도(올해 먼저) · 연도별 현황 {sum,quota} (2026-10-21 「직원 앞에 연도 추가, 상단 연도 이동 제거」) */

/* ── 초기 ── */
function init(){
  post('/mangr/leaveUsers.do','').then(function(j){
    _users=(j&&j.data)||[]; _admin=(j.admin==='Y'); _me=j.userId||''; _meNm=j.userNm||'';
    /* 총괄관리자도 본인 휴가는 등록한다 (2026-10-21 「총괄관리자는 남의 것도 보고 본인 휴가 등록해야 함」) — 남의 것은 보기만 */
    _gbs=(j.gbs||[]).map(function(g,i){ g._idx=i; return g; }); gbApply();
    if(_admin) document.getElementById('btnGb').style.display='';
    var fu=document.getElementById('fUser'), eu=document.getElementById('eUser');
    _users.forEach(function(u){ fu.insertAdjacentHTML('beforeend','<option value="'+esc(u.userId)+'">'+esc(u.userNm)+'</option>'); eu.insertAdjacentHTML('beforeend','<option value="'+esc(u.userId)+'">'+esc(u.userNm)+'</option>'); });
    if(_admin) document.getElementById('btnQuota').style.display='';
    load();
  }).catch(function(e){ swErr(e.message); });
}
function load(){
  var a=new Date(_ym.getFullYear(), _ym.getMonth(), 1), b=new Date(_ym.getFullYear(), _ym.getMonth()+1, 0), cy=yearOf();
  document.getElementById('lvYm').textContent=_ym.getFullYear()+'년 '+(_ym.getMonth()+1)+'월';
  /* 달력 달 자료 + 전 연도 자료(직원 10명 정도라 가볍다) → 자료 있는 연도마다 현황 */
  Promise.all([
    post('/mangr/leaveList.do','frDt='+ymd(a)+'&toDt='+ymd(b)),
    post('/mangr/leaveList.do','frDt=20000101&toDt=99991231')
  ]).then(function(r){ _rows=(r[0]&&r[0].data)||[]; _allRows=(r[1]&&r[1].data)||[];
    var ys={}; ys[cy]=1; _allRows.forEach(function(o){ ys[String(o.fromDt).slice(0,4)]=1; }); _years=Object.keys(ys).sort().reverse();
    return Promise.all(_years.map(function(y){ return post('/mangr/leaveSummary.do','year='+y); })); })
  .then(function(rs){ _sumYears={}; _years.forEach(function(y,i){ _sumYears[y]={ sum:(rs[i]&&rs[i].data)||[], quota:(rs[i]&&rs[i].quota)||[], auto:(rs[i]&&rs[i].auto)||{} }; });
    _sum=(_sumYears[cy]||{ sum:[] }).sum; _quota=(_sumYears[cy]||{ quota:[] }).quota; lvRender(); sumRender(); ulRender(); })
  .catch(function(e){ swErr(e.message); });
}
function lvMove(k){ _ym=new Date(_ym.getFullYear(), _ym.getMonth()+k, 1); load(); }
function lvToday(){ var t=new Date(); _ym=new Date(t.getFullYear(), t.getMonth(), 1); load(); }
function lvView(v){ _view=v; var bc=document.getElementById('btnCal'), bl=document.getElementById('btnList'); if(bc) bc.classList.toggle('on', v==='cal'); if(bl) bl.classList.toggle('on', v==='list');
  document.getElementById('calWrap').style.display=(v==='cal'?'':'none'); document.getElementById('listWrap').style.display=(v==='list'?'':'none'); lvRender(); }
function filtered(){ var u=document.getElementById('fUser').value, g=document.getElementById('fGb').value;
  return _rows.filter(function(o){ return (!u||o.userId===u) && (!g||o.leaveGb===g); }); }
function lvRender(){ if(_view==='cal') calRender(); else listRender(); }

/* ── 달력 ── */
function calRender(){
  var y=_ym.getFullYear(), m=_ym.getMonth(), first=new Date(y,m,1), start=new Date(y,m,1-first.getDay()), today=ymd(new Date());
  var rows=filtered(), h='', d=new Date(start.getTime());
  for(var w=0; w<6; w++){
    h+='<tr>';
    for(var i=0;i<7;i++){
      var k=ymd(d), out=(d.getMonth()!==m), wend=(i===0||i===6);
      var list=rows.filter(function(o){ return String(o.fromDt)<=k && String(o.toDt)>=k; });
      h+='<td class="'+(out?'out':'')+(wend?' wend':'')+(k===today?' today':'')+'"'+(out?'':' ondblclick="lvOpen(null,\''+k+'\')"')+'>'
        +'<div class="dn"><span class="'+(i===0?'sun':(i===6?'sat':''))+'">'+d.getDate()+'</span>'+(list.length&&!out?'<span class="cnt">'+list.length+'명</span>':'')+'</div>'
        +(out?'':list.map(function(o){ return '<span class="chip '+gbCls(o.leaveGb)+(o.status==='신청'?' pend':'')+(o.status==='반려'?' rej':'')+'" ondblclick="event.stopPropagation(); lvOpen('+o.leaveSeq+',null)" title="'+esc(o.userNm+' · '+o.leaveGb+' · '+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+' · '+fmtD(o.days)+'일 · '+o.status+(o.remark?' · '+o.remark:'')+(o.regDttm?' · 신청 '+String(o.regDttm).slice(0,10):''))+'">'+esc(o.userNm)+' '+esc(gbShort(o.leaveGb))+'</span>'; }).join(''))
        +'</td>';
      d.setDate(d.getDate()+1);
    }
    h+='</tr>';
    if(d.getMonth()!==m && w>=3) break;   /* 다음 달로 넘어갔으면 그만 (4~6주) */
  }
  document.getElementById('calBody').innerHTML=h;
  pendRender();
}
/* 승인 대기 띠 — 총괄관리자만. 그 달에 걸린 「신청」 건(거르기와 무관하게 전부) */
function pendRender(){
  var bar=document.getElementById('pendBar'); if(!bar) return;
  var p=_admin ? _rows.filter(function(o){ return o.status==='신청'; }) : [];
  if(!p.length){ bar.style.display='none'; bar.innerHTML=''; return; }
  bar.style.display='';
  bar.innerHTML='<div class="bh">⏳ 승인 대기 <span class="st 신청">'+p.length+'건</span> <small>줄의 버튼으로 바로 승인·반려 — 내용을 보려면 「열기」</small>'
    +'<button class="mini ok" style="margin-left:auto;height:26px;font-weight:700" onclick="pendApproveAll()" title="이 달 승인 대기 전부를 한 번에 승인 — 확인창을 거칩니다">✔ 대기 '+p.length+'건 전부 승인</button></div>'
    + '<table class="grid pend2"><thead><tr>'+[0,1].map(function(){ return '<th style="width:72px">직원</th><th style="width:60px">구분</th><th style="width:150px">기간</th><th style="width:44px">일수</th><th style="width:112px">신청일</th><th style="width:168px"></th>'; }).join('<th class="gap"></th>')+'</tr></thead><tbody>'
    + (function(){ var rows=[]; for(var i=0;i<p.length;i+=2) rows.push('<tr>'+pendCells(p[i])+'<td class="gap"></td>'+(p[i+1]?pendCells(p[i+1]):'<td colspan="6" class="blank"></td>')+'</tr>'); return rows.join(''); })()
    + '</tbody></table>';
}
/* 직원 휴가 목록 — 15줄 넘으면 상자 안 스크롤 (2026-10-22 사용자 「15개에서 스크롤되게」). 머리줄 + 앞 15줄 높이를 실제로 재서 max-height 로 */
var UL_MAX_ROWS=15;
function ulFit(){
  var more=document.getElementById('ulMore');
  var sc=document.getElementById('ulScroll'), tb=document.getElementById('ulBody'); if(!sc||!tb) return;
  var rows=tb.rows; sc.style.maxHeight='';
  if(rows.length<=UL_MAX_ROWS){ if(more) more.style.display='none'; return; }
  var th=sc.querySelector('thead'), h=(th?th.offsetHeight:0);
  for(var i=0;i<UL_MAX_ROWS;i++) h+=rows[i].offsetHeight;
  sc.style.maxHeight=(h+1)+'px';
  /* 「▼ 아래 N건 더」 — 보이는 마지막 줄 밑에 몇 건이 남았는지, 스크롤할 때마다 다시 센다. 끝까지 내리면 띠가 사라진다 */
  var upd=function(){ var bottom=sc.scrollTop+sc.clientHeight, left=0; for(var k=0;k<rows.length;k++){ if(rows[k].offsetTop+rows[k].offsetHeight>bottom+2) left++; }
    if(!more) return; if(left>0){ more.style.display=''; more.textContent='아래 '+left+'건 더 있음';   /* 2026-10-22 사용자 「안보이는 건수만」 */ } else more.style.display='none'; };
  sc.onscroll=upd; upd();
}
/* 승인 대기 전부 승인 (2026-10-22) — 확인창에 사람별 건수를 적고, 직원 패널의 lvApproveAll 과 같은 길(한 건씩 차례로 /mangr/leaveStatus.do) */
function pendApproveAll(){
  var p=_admin ? _rows.filter(function(o){ return o.status==='신청'; }) : [];
  if(!p.length){ toast('승인 대기 건이 없습니다',''); return; }
  var by={}, order=[]; p.forEach(function(o){ if(!by[o.userNm]){ by[o.userNm]=0; order.push(o.userNm); } by[o.userNm]++; });
  var who=order.map(function(n){ return esc(n)+' '+by[n]+'건'; }).join(' · ');
  lvApproveAll(p.map(function(o){ return o.leaveSeq; }), '승인 대기', '이 달 <b>승인 대기 '+p.length+'건</b>을 모두 승인할까요?<br><span class="hint">'+who+'</span><br><span class="hint">반려할 건이 있으면 먼저 줄의 [✖ 반려]를 누르고 나서 쓰세요.</span>');
}
/* 승인 대기 한 건 = 칸 6개 (한 줄에 두 건 — 2026-10-22 사용자 「한줄에 두개씩」). 사유는 title 로 */
function pendCells(o){
  return '<td class="who" title="'+esc(o.remark||'')+'">'+esc(o.userNm)+'</td><td><span class="chip '+gbCls(o.leaveGb)+'" style="display:inline-block">'+esc(o.leaveGb)+'</span></td>'
    +'<td>'+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+'</td><td>'+fmtD(o.days)+'</td><td title="신청일">'+esc(String(o.regDttm||'').slice(0,16))+'</td>'
    +'<td><button class="mini" onclick="lvOpen('+o.leaveSeq+',null)">열기</button><button class="mini ok" onclick="lvStatus('+o.leaveSeq+',\'승인\')">✔ 승인</button><button class="mini no" onclick="lvStatus('+o.leaveSeq+',\'반려\')">✖ 반려</button></td>';
}

/* ── 목록 ── */
function listRender(){
  var rows=filtered(); document.getElementById('listTitle').textContent=_ym.getFullYear()+'년 '+(_ym.getMonth()+1)+'월 휴가 목록';
  document.getElementById('listCnt').textContent=rows.length+'건 · '+fmtD(rows.reduce(function(a,o){ return a+(o.status==='반려'?0:n(o.days)); },0))+'일';
  document.getElementById('listBody').innerHTML = rows.length ? rows.map(function(o){
    var mine=(o.userId===_me), can=_admin||mine;
    return '<tr class="'+(mine?'me':'')+'"><td>'+esc(o.userNm)+'</td><td><span class="chip '+gbCls(o.leaveGb)+'" style="display:inline-block">'+esc(o.leaveGb)+'</span></td>'
      +'<td>'+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+'</td><td class="r">'+fmtD(o.days)+'</td><td class="l" style="white-space:normal">'+esc(o.remark)+'</td>'
      +'<td><span class="st '+esc(o.status)+'">'+esc(o.status)+'</span>'+(o.statUser&&o.status!=='신청'?' <span class="hint">'+esc(o.statUser)+'</span>':'')+'</td>'
      +'<td class="hint">'+esc(String(o.regDttm||'').slice(0,16))+'</td>'
      +'<td>'+(mine&&o.status!=='승인'?'<button class="mini" onclick="lvOpen('+o.leaveSeq+',null)">✏ 수정</button><button class="mini no" onclick="lvDeleteSeq('+o.leaveSeq+')">🗑</button>':'<button class="mini" onclick="lvOpen('+o.leaveSeq+',null)">보기</button>')
      +(_admin&&o.status!=='승인'?'<button class="mini ok" onclick="lvStatus('+o.leaveSeq+',\'승인\')">✔ 승인</button>':'')
      +(_admin&&o.status!=='반려'?'<button class="mini no" onclick="lvStatus('+o.leaveSeq+',\'반려\')">✖ 반려</button>':'')+'</td></tr>';
  }).join('') : '<tr><td colspan="8" class="msg">이 달에 휴가가 없습니다.</td></tr>';
}

/* ── 연간 현황 ── */
/* 현황 칸 = 구분 목록대로 : 연차(부여·사용·잔여) · 월차(월차 종류가 있을 때) · 반일 건수(반일 구분이 있을 때) · 따로 셈 구분마다 한 칸 · 대기
     올해 자료에 있는데 목록에 없는 구분(이름을 바꿨거나 지운 것)도 따로 칸을 만든다 */
function sumCols(){
  var use=gbUse(), inSum={}, all=[]; Object.keys(_sumYears).forEach(function(y){ all=all.concat(_sumYears[y].sum||[]); }); (all.length?all:_sum).forEach(function(s){ inSum[s.leaveGb]=1; });
  var others=use.filter(function(g){ return g.kind==='other'; }).map(function(g){ return g.nm; });
  Object.keys(inSum).forEach(function(k){ if(!_gbs.some(function(g){ return g.nm===k; }) && others.indexOf(k)<0) others.push(k); });
  return { hasM:use.some(function(g){ return g.kind==='monthly'; }), hasHalf:use.some(function(g){ return g.half; }), others:others };
}
function sumCalc(g, C){   /* g = {구분:{days,cnt}} → {au, mu, half, oth:{nm:days}} */
  var r={ au:0, mu:0, half:0, oth:{} };
  Object.keys(g).forEach(function(k){ var d=gbDef(k), x=g[k];
    if(d._idx>=0 && d.kind==='annual'){ r.au+=x.days; if(d.half) r.half+=x.cnt; }
    else if(d._idx>=0 && d.kind==='monthly'){ r.mu+=x.days; if(d.half) r.half+=x.cnt; }
    else { r.oth[k]=(r.oth[k]||0)+x.days; } });
  return r;
}
function sumRender(){
  var C=sumCols(), years=_years.length?_years:[yearOf()];
  document.getElementById('sumHead').innerHTML='<tr><th rowspan="2" style="width:48px">연도</th><th rowspan="2" style="width:74px">직원</th><th colspan="4">연차</th>'+(C.hasM?'<th colspan="3">월차</th>':'')+(C.hasHalf?'<th rowspan="2" title="반일 구분 건수(0.5일씩)">반일</th>':'')
    +C.others.map(function(nm){ return '<th rowspan="2">'+esc(nm)+'</th>'; }).join('')+'<th rowspan="2" title="승인 대기 건수">대기</th></tr><tr><th title="전년에서 넘어온 연차">이월</th><th>부여</th><th>사용</th><th>잔여</th>'+(C.hasM?'<th>부여</th><th>사용</th><th>잔여</th>':'')+'</tr>';
  var h='', ncol=6+(C.hasM?3:0)+(C.hasHalf?1:0)+C.others.length+1;
  /* 연도마다 : 직원 줄들 + 그 연도 합계. 연도 칸은 세로로 합쳐 한 번만 (2026-10-21) */
  years.forEach(function(y){
    var Y=_sumYears[y]||{ sum:[], quota:[] }, q={}; (Y.quota||[]).forEach(function(x){ q[x.userId]=x; });
    var by={}; (Y.sum||[]).forEach(function(s){ var u=by[s.userId]=by[s.userId]||{ userId:s.userId, userNm:s.userNm, g:{}, pend:0 }; u.g[s.leaveGb]={ days:n(s.days), cnt:n(s.cnt) }; u.pend+=n(s.pendCnt); });
    var ids=_users.map(function(u){ return u.userId; }); Object.keys(by).forEach(function(k){ if(ids.indexOf(k)<0) ids.push(k); });   /* 퇴직자도 그 해 휴가가 있으면 보인다 */
    var tot={ cq:0, aq:0, au:0, mq:0, mu:0, half:0, oth:{}, pend:0 }, first=true;
    ids.forEach(function(id){
      var u=_users.filter(function(x){ return x.userId===id; })[0]||{ userId:id, userNm:(by[id]||{}).userNm||id };
      var s=by[id]||{ g:{}, pend:0 }, r=sumCalc(s.g, C), aq=q[id]?n(q[id].annualDays):15, mq=q[id]?n(q[id].monthlyDays):0, cq=carryOf(y,id);
      tot.cq+=cq; tot.aq+=aq; tot.au+=r.au; tot.mq+=mq; tot.mu+=r.mu; tot.half+=r.half; tot.pend+=s.pend; C.others.forEach(function(nm){ tot.oth[nm]=(tot.oth[nm]||0)+(r.oth[nm]||0); });
      h+='<tr class="pick'+(id===_me?' me':'')+(id===_pickUser&&y===_pickYear?' on':'')+'" onclick="lvPickUser(\''+esc(id)+'\',\''+y+'\')" title="누르면 아래에 이 직원의 '+y+'년 휴가 목록 (달력은 그대로)">'
        +(first?'<td class="yr" rowspan="'+(ids.length+1)+'">'+y+'</td>':'')
        +'<td class="l"><b>'+esc(u.userNm)+'</b></td><td'+(carryFixed(y,id)==null&&cq?' title="전년 잔여 자동 이월" style="color:#1f7a8c"':'')+'>'+(cq?fmtD(cq):'')+'</td><td>'+fmtD(aq)+'</td><td>'+fmtD(r.au)+'</td><td class="rem'+(cq+aq-r.au<0?' neg':'')+'">'+fmtD(cq+aq-r.au)+'</td>'
        +(C.hasM?'<td>'+(mq?fmtD(mq):'')+'</td><td>'+(r.mu?fmtD(r.mu):'')+'</td><td class="rem'+(mq-r.mu<0?' neg':'')+'">'+(mq||r.mu?fmtD(mq-r.mu):'')+'</td>':'')
        +(C.hasHalf?'<td>'+(r.half?r.half+'건':'')+'</td>':'')
        +C.others.map(function(nm){ return '<td>'+(r.oth[nm]?fmtD(r.oth[nm]):'')+'</td>'; }).join('')
        +'<td>'+(s.pend?'<span class="st 신청">'+s.pend+'</span>':'')+'</td></tr>';
      first=false;
    });
    h+='<tr class="tot">'+(first?'<td class="yr">'+y+'</td>':'')+'<td class="l">'+y+' 합계</td><td>'+(tot.cq?fmtD(tot.cq):'')+'</td><td>'+fmtD(tot.aq)+'</td><td>'+fmtD(tot.au)+'</td><td>'+fmtD(tot.cq+tot.aq-tot.au)+'</td>'
      +(C.hasM?'<td>'+(tot.mq?fmtD(tot.mq):'')+'</td><td>'+(tot.mu?fmtD(tot.mu):'')+'</td><td>'+(tot.mq||tot.mu?fmtD(tot.mq-tot.mu):'')+'</td>':'')
      +(C.hasHalf?'<td>'+(tot.half?tot.half+'건':'')+'</td>':'')+C.others.map(function(nm){ return '<td>'+(tot.oth[nm]?fmtD(tot.oth[nm]):'')+'</td>'; }).join('')+'<td>'+(tot.pend?tot.pend:'')+'</td></tr>';
  });
  document.getElementById('sumBody').innerHTML=h||'<tr><td colspan="'+ncol+'" class="msg">직원이 없습니다.</td></tr>';
}
/* ── 휴가 구분 설정 (총괄관리자) ── */
var _gbEdit=[];
function gbOpen(){ _gbEdit=_gbs.map(function(g){ return { nm:g.nm, kind:g.kind||'other', half:!!g.half, color:g.color||'#5a6b7a', use:g.use!==false }; }); gbDraw(); document.getElementById('gbPop').classList.add('on'); }
function gbClose(){ document.getElementById('gbPop').classList.remove('on'); }
function gbDraw(){
  document.getElementById('gbBody').innerHTML=_gbEdit.map(function(g,i){ var K=function(v,l){ return '<option value="'+v+'"'+(g.kind===v?' selected':'')+'>'+l+'</option>'; };
    return '<tr><td><input type="text" maxlength="20" value="'+esc(g.nm)+'" oninput="_gbEdit['+i+'].nm=this.value"></td>'
      +'<td><select onchange="_gbEdit['+i+'].kind=this.value">'+K('annual','연차에서 뺌')+K('monthly','월차에서 뺌')+K('other','따로 셈')+'</select></td>'
      +'<td><input type="checkbox"'+(g.half?' checked':'')+' onchange="_gbEdit['+i+'].half=this.checked" title="하루짜리 0.5일"></td>'
      +'<td><input type="color" value="'+esc(g.color)+'" onchange="_gbEdit['+i+'].color=this.value"></td>'
      +'<td><input type="checkbox"'+(g.use?' checked':'')+' onchange="_gbEdit['+i+'].use=this.checked"></td>'
      +'<td><button class="mini" onclick="gbMove('+i+',-1)">▲</button><button class="mini" onclick="gbMove('+i+',1)">▼</button></td>'
      +'<td><button class="mini no" onclick="gbDel('+i+')" title="목록에서 빼기 — 옛 자료는 남는다">✕</button></td></tr>'; }).join('') || '<tr><td colspan="7" class="msg">구분이 없습니다 — 「＋ 구분 추가」</td></tr>';
}
function gbAdd(){ _gbEdit.push({ nm:'', kind:'other', half:false, color:'#5a6b7a', use:true }); gbDraw(); var l=document.querySelectorAll('#gbBody input[type=text]'); if(l.length) l[l.length-1].focus(); }
function gbDel(i){ _gbEdit.splice(i,1); gbDraw(); }
function gbMove(i,k){ var j=i+k; if(j<0||j>=_gbEdit.length) return; var t=_gbEdit[i]; _gbEdit[i]=_gbEdit[j]; _gbEdit[j]=t; gbDraw(); }
function gbSave(){
  var list=_gbEdit.map(function(g){ return { nm:String(g.nm||'').trim(), kind:g.kind, half:!!g.half, color:g.color, use:!!g.use }; }).filter(function(g){ return g.nm; });
  if(!list.length){ swErr('구분을 하나 이상 두세요.'); return; }
  var seen={}; for(var i=0;i<list.length;i++){ if(list[i].nm.length>20){ swErr('이름은 20자까지입니다 — '+list[i].nm); return; } if(seen[list[i].nm]){ swErr('같은 이름이 둘 있습니다 — '+list[i].nm); return; } seen[list[i].nm]=1; }
  if(!list.some(function(g){ return g.kind==='annual' && g.use; })){ swErr('「연차에서 뺌」 구분이 하나는 있어야 합니다(현황의 연차 칸).'); return; }
  fetch(CTX+'/user/compSetPatch.do',{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/json;charset=UTF-8'}, body:JSON.stringify({ key:'leave', val:{ gbs:list } }) })
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t||('HTTP '+r.status)); }); })
    .then(function(){ _gbs=list.map(function(g,i){ g._idx=i; return g; }); gbApply(); gbClose(); toast('휴가 구분을 저장했습니다 — 어느 PC 에서나 같습니다','ok'); lvRender(); sumRender(); })
    .catch(function(e){ swErr(e.message); });
}
var _pickUser='', _pickYear='';   /* 현황에서 고른 직원·연도 — 아래 목록용. 달력 거르기(fUser)와는 따로 (2026-10-21 「선택하면 다른 직원이 안 보임」) */
function lvPickUser(id, y){ y=y||yearOf(); if(_pickUser===id && _pickYear===y){ _pickUser=''; _pickYear=''; } else { _pickUser=id; _pickYear=y; } sumRender(); ulRender(); }
/* 고른 직원의 올해 휴가 목록 — 현황 표 밑 (2026-10-21). 달력 거르기(fUser)와 같은 직원. 줄을 더블클릭하면 그 휴가 창 */
function ulRender(){
  var box=document.getElementById('ulBox'), id=_pickUser;
  if(!id){ box.style.display='none'; return; }
  var u=_users.filter(function(x){ return x.userId===id; })[0]||{ userNm:id };
  box.style.display='';
  document.getElementById('ulBody').innerHTML='<tr><td colspan="7" class="msg">불러오는 중…</td></tr>';
  /* 현황에서 누른 직원·연도의 휴가 — 전 연도 자료(_allRows)에서 고른다 (2026-10-21 「이전 연도별도 보여 줘」 → 「직원 앞에 연도」) */
  var y=_pickYear||yearOf(), got=Promise.resolve(_allRows.filter(function(o){ return o.userId===id && String(o.fromDt).slice(0,4)===y; }));
  got.then(function(rows){ if(_pickUser!==id) return;
    _ulList=rows; document.getElementById('ulTitle').textContent=y+'년 '+u.userNm+' 휴가';
    var l=rows, d=l.reduce(function(a,o){ return a+(o.status==='반려'?0:n(o.days)); },0);
    document.getElementById('ulCnt').textContent=l.length+'건 · '+fmtD(d)+'일 (반려 제외)';
    document.getElementById('ulBody').innerHTML = l.length ? l.map(function(o){ var can=_admin||o.userId===_me;
      return '<tr class="pick" ondblclick="lvOpen('+o.leaveSeq+',null)" title="더블클릭 = 열기"><td><span class="chip '+gbCls(o.leaveGb)+'" style="display:inline-block">'+esc(o.leaveGb)+'</span></td>'
        +'<td>'+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+'</td><td class="r">'+fmtD(o.days)+'</td><td class="l" style="white-space:normal">'+esc(o.remark)+'</td>'
        +'<td><span class="st '+esc(o.status)+'">'+esc(o.status)+'</span></td><td class="hint">'+esc(String(o.regDttm||'').slice(0,16))+'</td><td style="white-space:nowrap">'+(o.userId===_me&&o.status!=='승인'?'<button class="mini" onclick="lvOpen('+o.leaveSeq+',null)" title="수정">✏</button>':'<button class="mini" onclick="lvOpen('+o.leaveSeq+',null)" title="보기">👁</button>')
        +(_admin&&o.status!=='승인'?'<button class="mini ok" onclick="lvStatus('+o.leaveSeq+',\'승인\')" title="승인">✔</button>':'')+(_admin&&o.status!=='반려'?'<button class="mini no" onclick="lvStatus('+o.leaveSeq+',\'반려\')" title="반려">✖</button>':'')+'</td></tr>'; }).join('')
      : '<tr><td colspan="7" class="msg">'+y+'년 휴가가 없습니다.</td></tr>';
    ulFit();
    var pend=l.filter(function(o){ return o.status==='신청'; }), ab=document.getElementById('ulAll');
    if(ab){ ab.style.display=(_admin&&pend.length)?'':'none'; ab.textContent='✔ 대기 '+pend.length+'건 전부 승인'; ab.onclick=function(){ lvApproveAll(pend.map(function(o){ return o.leaveSeq; }), u.userNm); }; } }).catch(function(e){ document.getElementById('ulBody').innerHTML='<tr><td colspan="7" class="msg" style="color:#c0392b">'+esc(e.message)+'</td></tr>'; });
}

/* ── 등록·수정 창 ── */
function lvOpen(seq, dateYmd){

  if(!seq && dateYmd){ var mine=_rows.filter(function(o){ return String(o.fromDt)<=dateYmd && String(o.toDt)>=dateYmd && o.userId===_me; });
    if(mine.length===1){ seq=mine[0].leaveSeq; dateYmd=null; } }   /* 하나뿐이면 수정 창으로 바로 (2026-10-21) */
  _cur = seq ? (allRows().filter(function(o){ return String(o.leaveSeq)===String(seq); })[0]) : null;
  if(seq && !_cur){ swErr('그 휴가를 찾지 못했습니다 — 달을 다시 불러오세요.'); return; }
  var ro=!!(_cur && (_cur.userId!==_me || _cur.status==='승인'));   /* 보기만 : 남의 휴가(총괄관리자도) · 승인된 휴가(본인도) (2026-10-21 「총괄관리자도 삭제·수정 못함 보기만」 「승인된 상태면 수정·삭제 못함」). 수정·삭제 = 본인 + 신청·반려 상태만 */
  if(false){
    swErr('<b>'+esc(_cur.userNm)+'</b> · '+esc(_cur.leaveGb)+' · '+fmtDt(_cur.fromDt)+(_cur.fromDt!==_cur.toDt?' ~ '+fmtDt(_cur.toDt):'')+' · '+fmtD(_cur.days)+'일 · '+esc(_cur.status)+(_cur.remark?'<br><span class="hint">'+esc(_cur.remark)+'</span>':'')+'<br><span class="hint">다른 직원의 휴가는 총괄관리자만 고칩니다.</span>'); return; }
  document.getElementById('lvPopTitle').textContent=_cur?(ro?'휴가 보기':'휴가 수정'):'휴가 등록';
  var ex=document.getElementById('eExist'); ex.style.display='none'; ex.innerHTML='';
  if(!_cur && dateYmd){
    var exl=_rows.filter(function(o){ return String(o.fromDt)<=dateYmd && String(o.toDt)>=dateYmd && o.userId===_me; });   /* 본인 휴가만 보여 준다 — 남의 휴가는 창에 안 띄움 (2026-10-21 「표시 없애고 본인만 수정·삭제」) */
    if(exl.length){ ex.style.display='inline-flex'; ex.innerHTML='이 날짜 휴가 : '+exl.map(function(o){ return '<button class="mini" style="height:28px" onclick="lvOpen('+o.leaveSeq+',null)" title="열기"><span class="chip '+gbCls(o.leaveGb)+'" style="display:inline-block; padding:0 6px">'+esc(o.userNm)+' '+esc(o.leaveGb)+'</span> 열기</button>'; }).join(''); }
  }
  _mcSel={}; _mc=null; document.getElementById('eMode').style.display=_cur?'none':''; lvMode('one');
  var eu=document.getElementById('eUser'), en=document.getElementById('eUserNm');
  eu.style.display='none'; en.style.display=''; en.value=_cur?(_cur.userNm||_cur.userId):(_meNm||_me);
  document.getElementById('eJoin').innerHTML=lvJoinTxt(_cur?_cur.userId:_me);   /* 입사일 · 근속 · 올해 연차 잔여 — 작은 표 (2026-10-21) */   /* 등록은 본인만 — 총괄관리자도 남의 휴가는 못 넣는다 (2026-10-21) */
  document.getElementById('eGb').value=_cur?_cur.leaveGb:(document.getElementById('fGb').value||'연차');
  var f=_cur?fmtDt(_cur.fromDt):(dateYmd?fmtDt(dateYmd):iso(new Date())), t=_cur?fmtDt(_cur.toDt):f;
  document.getElementById('eFrom').value=f; document.getElementById('eTo').value=t;
  document.getElementById('eRemark').value=_cur?(_cur.remark||''):'';
  lvDays(); if(_cur) document.getElementById('eDays').value=n(_cur.days);
  document.getElementById('eDel').style.display=(_cur && !ro)?'':'none';   /* 삭제는 본인 + 승인 전만 (2026-10-21 「삭제는 해당 담당자만」 「승인된 상태면 수정·삭제 못함」) — 총괄관리자도 남의 휴가는 반려로 */
  ['eGb','eFrom','eTo','eDays','eRemark'].forEach(function(id){ document.getElementById(id).disabled=ro; });
  document.getElementById('eSave').style.display=ro?'none':'';
  var sr=document.getElementById('eStatRow'), sb=document.getElementById('eStatBtns');
  if(_cur){ sr.style.display=''; document.getElementById('eStat').innerHTML='<span class="st '+esc(_cur.status)+'">'+esc(_cur.status)+'</span>'+(_cur.regDttm?' <span class="hint">신청일 '+esc(String(_cur.regDttm).slice(0,16))+'</span>':'')+(_cur.statUser&&_cur.status!=='신청'?' <span class="hint">'+esc(_cur.statUser)+' · '+esc(String(_cur.statDttm||'').slice(0,16))+'</span>':'')+(!ro?' <span class="hint">'+(_admin?'총괄관리자 본인 휴가는 저장하면 바로 「승인」입니다':'고쳐서 저장하면 다시 「신청」이 됩니다')+'</span>':'');
    sb.style.display='none';   /* 휴가 창의 승인·반려·신청으로 버튼은 뺐다 (2026-10-21 사용자 「여기 있는 승인·반려는 제거」) — 승인·반려는 승인 대기 띠·목록·직원별 목록에서 */
    var B=function(st,label,cls){ var cur=(_cur.status===st); return '<button class="lv-btn '+(cur?'on':cls)+'" '+(cur?'disabled title="지금 상태"':'onclick="lvStatus('+_cur.leaveSeq+',\''+st+'\')"')+'>'+label+(cur?' ✓':'')+'</button>'; };
    sb.innerHTML=_admin?(B('승인','✔ 승인','')+B('반려','✖ 반려','red')+B('신청','↩ 신청으로','')):''; }
  else { sr.style.display='none'; sb.style.display='none'; }
  document.getElementById('lvPop').classList.add('on');
  if(!ro) setTimeout(function(){ document.getElementById('eGb').focus(); }, 50);
}
function lvClose(){ document.getElementById('lvPop').classList.remove('on'); _cur=null; }
/* ── 여러 날짜 (2026-10-21) ── */
var _mode='one', _mc=null, _mcSel={};
function lvMode(m){ if(_cur && m==='multi') return;   /* 수정 때는 하루·기간만 */
  _mode=m; document.getElementById('mdOne').classList.toggle('on', m==='one'); document.getElementById('mdMulti').classList.toggle('on', m==='multi');
  document.getElementById('oneBox').style.display=(m==='one'?'':'none'); document.getElementById('multiBox').style.display=(m==='multi'?'':'none');
  if(m==='multi'){ if(!_mc){ var f=document.getElementById('eFrom').value; var d=f?new Date(f+'T00:00:00'):_ym; _mc=new Date(d.getFullYear(), d.getMonth(), 1); } mcRender(); } }
function mcMove(k){ _mc=new Date(_mc.getFullYear(), _mc.getMonth()+k, 1); mcRender(); }
function mcToggle(k){ if(_mcSel[k]) delete _mcSel[k]; else _mcSel[k]=1; mcRender(); }
function mcRender(){
  var y=_mc.getFullYear(), m=_mc.getMonth(), first=new Date(y,m,1), d=new Date(y,m,1-first.getDay()), h='';
  var uid=_me;
  document.getElementById('mcYm').textContent=y+'년 '+(m+1)+'월';
  for(var w=0; w<6; w++){ h+='<tr>';
    for(var i=0;i<7;i++){ var k=ymd(d), out=(d.getMonth()!==m);
      var has=_rows.some(function(o){ return o.userId===uid && o.status!=='반려' && String(o.fromDt)<=k && String(o.toDt)>=k; });   /* 보고 있는 달 자료만 안다 — 서버가 다시 거른다 */
      h+='<td class="'+(out?'out':'')+((i===0||i===6)?' wend':'')+(_mcSel[k]?' sel':'')+(has&&!out?' has':'')+'" onclick="mcToggle(\''+k+'\')" title="'+fmtDt(k)+(has?' — 이미 휴가가 있는 날':'')+'">'+d.getDate()+'</td>';
      d.setDate(d.getDate()+1); }
    h+='</tr>'; if(d.getMonth()!==m && w>=3) break; }
  document.getElementById('mcBody').innerHTML=h;
  var keys=Object.keys(_mcSel).sort();
  document.getElementById('mcSel').innerHTML=keys.map(function(k){ return '<span onclick="mcToggle(\''+k+'\')" title="빼기">'+k.slice(4,6)+'/'+k.slice(6,8)+(k.slice(0,4)!==String(y)?' ('+k.slice(0,4)+')':'')+'</span>'; }).join('');
  var half=gbHalf(document.getElementById('eGb').value);
  document.getElementById('mcHint').textContent='고른 날짜 '+keys.length+'일 — 날짜마다 한 건씩('+(half?'반차 0.5일':'1일')+') 저장됩니다. 이미 휴가가 있는 날(붉은 밑줄)은 건너뜁니다.';
}
/* 「10/23, 11/06」 「2026-12-04」 「12.11」 꼴을 달력의 해 기준으로 읽는다 */
function mcParse(){
  var t=document.getElementById('mcText').value||'', y=_mc.getFullYear(), n0=Object.keys(_mcSel).length;
  t.split(/[\s,;]+/).forEach(function(x){ if(!x) return; var m=/^(?:(\d{4})[-./])?(\d{1,2})[-./](\d{1,2})$/.exec(x); if(!m) return;
    var yy=m[1]||String(y), mm=('0'+m[2]).slice(-2), dd=('0'+m[3]).slice(-2); var dt=new Date(yy+'-'+mm+'-'+dd+'T00:00:00'); if(isNaN(dt.getTime())||dt.getMonth()+1!==+m[2]) return; _mcSel[yy+mm+dd]=1; });
  var added=Object.keys(_mcSel).length-n0; document.getElementById('mcText').value=''; mcRender();
  if(!added) swErr('읽을 수 있는 날짜가 없습니다 — 「10/23, 11/06」 또는 「2026-12-04」 꼴로 적어 주세요.');
}
function lvSaveMulti(){
  var dates=Object.keys(_mcSel).sort(); if(!dates.length){ swErr('날짜를 하나 이상 고르세요.'); return; }
  var p={ userId:_me, leaveGb:document.getElementById('eGb').value, dates:dates, remark:document.getElementById('eRemark').value };
  var u=_users.filter(function(x){ return x.userId===p.userId; })[0]; p.userNm=u?u.userNm:(_meNm||p.userId);
  post('/mangr/leaveSaveMulti.do', p, true).then(function(j){ lvClose(); var sk=(j.skipped||[]);
    toast(j.rows+'일을 등록했습니다 — 상태 '+(j.status||'')+(sk.length?' · 겹쳐서 건너뜀 '+sk.map(fmtDt).join(', '):''), sk.length?'warn':'ok');
    var d=dates[0]; _ym=new Date(+d.slice(0,4), +d.slice(4,6)-1, 1); load(); }).catch(function(e){ swErr(e.message); });
}
function lvDays(){
  var gb=document.getElementById('eGb').value, f=document.getElementById('eFrom').value, t=document.getElementById('eTo').value, dd=document.getElementById('eDays'), hint=document.getElementById('eDaysHint');
  var half=gbHalf(gb);
  if(_mode==='multi') mcRender();
  if(half){ document.getElementById('eTo').value=f; dd.value=0.5; dd.readOnly=true; hint.textContent='반일 구분 = 0.5일 (하루)'; return; }
  dd.readOnly=false; hint.textContent='평일 수로 자동 계산 — 공휴일이 끼면 고치세요';
  if(!f) return; if(!t||t<f){ document.getElementById('eTo').value=f; t=f; }
  var a=new Date(f+'T00:00:00'), b=new Date(t+'T00:00:00'); dd.value=Math.max(0.5, weekdays(a,b));
}
function lvSave(){
  if(_mode==='multi' && !_cur){ lvSaveMulti(); return; }
  var p={ leaveSeq:_cur?_cur.leaveSeq:0, userId:_me, leaveGb:document.getElementById('eGb').value,
          fromDt:document.getElementById('eFrom').value, toDt:document.getElementById('eTo').value, days:document.getElementById('eDays').value, remark:document.getElementById('eRemark').value };
  var u=_users.filter(function(x){ return x.userId===p.userId; })[0]; p.userNm=u?u.userNm:(_meNm||p.userId);
  if(!p.fromDt){ swErr('시작일을 넣으세요.'); return; }
  if(!(n(p.days)>0)){ swErr('일수를 넣으세요.'); return; }
  post('/mangr/leaveSave.do', p, true).then(function(j){ lvClose(); toast((_cur?'고쳤습니다':'등록했습니다')+' — 상태 '+(j.status||''),'ok'); var d=new Date(p.fromDt+'T00:00:00'); _ym=new Date(d.getFullYear(), d.getMonth(), 1); load(); })
    .catch(function(e){ swErr(e.message); });
}
function lvDelete(){ if(!_cur) return; lvDeleteSeq(_cur.leaveSeq); }
function lvDeleteSeq(seq){
  var o=allRows().filter(function(x){ return String(x.leaveSeq)===String(seq); })[0]; if(!o) return;

  if(o.status==='승인'){ swErr('승인된 휴가는 지울 수 없습니다 — 총괄관리자가 「신청으로」 되돌린 뒤 지우세요.'); return; }
  var go=function(){ post('/mangr/leaveDelete.do','leaveSeq='+seq).then(function(){ lvClose(); toast('지웠습니다','ok'); load(); }).catch(function(e){ swErr(e.message); }); };
  if(window._confirmBox) _confirmBox({ msg:'<b>'+esc(o.userNm)+'</b> · '+esc(o.leaveGb)+' · '+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+' 를 지울까요?', icon:'🗑', okText:'지우기', okColor:'red', onOk:go });
  else if(confirm('지울까요?')) go();
}
/* 한 직원의 신청 건을 한 번에 승인 (2026-10-21) — 차례로 보내고 끝나면 다시 읽는다 */
function lvApproveAll(seqs, nm, msg){ if(!seqs.length) return;   /* msg = 확인창 글(선택) — 승인 대기 띠의 전부 승인이 넘긴다 */
  var go=function(){ var i=0; (function next(){ if(i>=seqs.length){ toast(nm+' 신청 '+seqs.length+'건을 모두 승인했습니다','ok'); load(); return; }
      post('/mangr/leaveStatus.do','leaveSeq='+seqs[i]+'&status='+encodeURIComponent('승인')).then(function(){ i++; next(); }).catch(function(e){ swErr(e.message); load(); }); })(); };
  var m=msg||('<b>'+esc(nm)+'</b>의 신청 <b>'+seqs.length+'건</b>을 모두 승인할까요?');
  if(window._confirmBox) _confirmBox({ msg:m, icon:'✔', okText:'전부 승인', onOk:go }); else if(confirm(m.replace(/<[^>]+>/g,''))) go(); }
/* 승인·반려·신청으로 — 확인창을 거친 뒤 바꾼다 (2026-10-21 사용자 「승인·반려 누르면 메시지 처리 후 진행하나요」 → 「네」) */
function lvStatus(seq, st){
  var o=allRows().filter(function(x){ return String(x.leaveSeq)===String(seq); })[0]||{};
  var who=(o.userNm?'<b>'+esc(o.userNm)+'</b> · '+esc(o.leaveGb||'')+' · '+fmtDt(o.fromDt)+(o.fromDt&&o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+(o.days?' · '+fmtD(o.days)+'일':''):'이 휴가');
  var go=function(){ post('/mangr/leaveStatus.do','leaveSeq='+seq+'&status='+encodeURIComponent(st)).then(function(){ lvClose(); toast('「'+st+'」으로 바꿨습니다','ok'); load(); }).catch(function(e){ swErr(e.message); }); };
  var msg=who+(st==='승인'?'을(를) <b>승인</b>할까요?':(st==='반려'?'을(를) <b style="color:#c0392b">반려</b>할까요?<br><span class="hint">반려하면 달력에 취소선으로 남고 잔여 계산에서 빠집니다.</span>':'을(를) 다시 <b>신청</b> 상태로 돌릴까요?'));
  if(window._confirmBox) _confirmBox({ msg:msg, icon:(st==='반려'?'✖':'✔'), okText:st, okColor:(st==='반려'?'red':'blue'), onOk:go }); else if(confirm(msg.replace(/<[^>]+>/g,''))) go();
}

/* ── 부여 일수 ── */
function qtOpen(){
  var q={}; _quota.forEach(function(x){ q[x.userId]=x; }); var y=yearOf(), ib='height:28px; border:1px solid var(--bd); border-radius:6px';
  document.getElementById('qtTitle').textContent=y+'년 부여 일수';
  document.getElementById('qtBody').innerHTML=_users.map(function(u){ var x=q[u.userId]||{}, jd=String(u.joinDt||'').trim();
    return '<tr data-id="'+esc(u.userId)+'"><td class="l"><b>'+esc(u.userNm)+'</b> <span class="hint">'+esc(u.userId)+'</span></td>'
      +'<td><input type="date" class="qj" value="'+(jd.length===8?fmtDt(jd):'')+'" onchange="qtSugCell(this)" style="width:132px; '+ib+'"></td>'
      +'<td class="qs hint l">'+qtSugTxt(jd, y)+'</td>'
      +'<td><input type="number" step="0.5" min="0" class="qc" value="'+(x.carryDays!=null&&x.carryDays!==''?n(x.carryDays):'')+'" placeholder="'+(autoOf(y,u.userId)!=null?'자동 '+fmtD(autoOf(y,u.userId)):'자동 0')+'" title="비우면 전년 잔여가 자동으로 넘어옵니다. 숫자를 넣으면 그 값으로 고정" style="width:84px; text-align:right; '+ib+'"></td>'
      +'<td><input type="number" step="0.5" min="0" class="qa" value="'+(x.annualDays!=null?n(x.annualDays):15)+'" style="width:72px; text-align:right; '+ib+'"></td>'
      +'<td><input type="number" step="0.5" min="0" class="qm" value="'+(x.monthlyDays!=null?n(x.monthlyDays):0)+'" style="width:72px; text-align:right; '+ib+'"></td>'
      +'<td><input type="text" class="qr" value="'+esc(x.remark||'')+'" maxlength="200" style="width:100%; padding:0 6px; '+ib+'"></td></tr>'; }).join('');
  document.getElementById('qtPop').classList.add('on');
}
/* 입사일 → 근속 연차 · 권장 연차 일수 (사용자 양식 연차양식.xlsx 의 규칙, 2026-10-21) : 1~2년차 15일, 3년차부터 2년마다 1일(3·4년차 16, 5·6년차 17 …, 최대 25), 입사한 해는 0(월 1일 발생). 연차 = 그 해 − 입사 연도 */
function qtSug(joinDt, y){ joinDt=String(joinDt||'').trim().replace(/-/g,''); if(joinDt.length!==8) return { n:null, days:null };
  var k=Number(y)-Number(joinDt.slice(0,4)); if(k<=0) return { n:0, days:0 }; return { n:k, days:Math.min(25, 15+Math.floor((k-1)/2)) }; }
/* 휴가 창의 입사일 줄 : 「2023-11-01 · 3년차 · 2026년 연차 이월 7 + 부여 16 − 사용 7 = 잔여 16」. 입사일이 없으면 안내 */
function lvJoinTxt(uid){ var y=yearOf(), u=_users.filter(function(x){ return x.userId===uid; })[0]||{}, jd=String(u.joinDt||'').trim(), s=qtSug(jd, y);
  var q=((_sumYears[y]||{ quota:[] }).quota||[]).filter(function(x){ return x.userId===uid; })[0]||{}, cq=carryOf(y,uid), aq=q.annualDays!=null?n(q.annualDays):15, used=0;
  ((_sumYears[y]||{ sum:[] }).sum||[]).forEach(function(x){ if(x.userId===uid && gbDef(x.leaveGb).kind==='annual') used+=n(x.days); });
  return '<table><tr><th>입사일</th><th>근속</th><th>'+y+' 이월</th><th>부여</th><th>사용</th><th>잔여</th></tr><tr>'
    +(jd.length===8 ? '<td>'+fmtDt(jd)+'</td><td>'+(s.n?s.n+'년차':'입사한 해')+'</td>' : '<td class="none" colspan="2">입사일 없음</td>')
    +'<td>'+(cq?fmtD(cq):'-')+'</td><td>'+fmtD(aq)+'</td><td>'+fmtD(used)+'</td><td class="rem">'+fmtD(cq+aq-used)+'</td></tr></table>'; }
function qtSugTxt(jd, y){ var s=qtSug(jd, y); return s.n==null?'':(s.n?s.n+'년차 · 권장 '+s.days+'일':'입사한 해 · 월 1일'); }
function qtSugCell(inp){ var tr=inp.closest('tr'); tr.querySelector('.qs').textContent=qtSugTxt(inp.value, yearOf()); }
function qtFill(){ Array.prototype.forEach.call(document.querySelectorAll('#qtBody tr'), function(tr){ var s=qtSug(tr.querySelector('.qj').value, yearOf()); if(s.days!=null) tr.querySelector('.qa').value=s.days; }); }
function qtClose(){ document.getElementById('qtPop').classList.remove('on'); }
function qtSave(){
  var items=Array.prototype.map.call(document.querySelectorAll('#qtBody tr'), function(tr){ return { userId:tr.dataset.id, joinDt:tr.querySelector('.qj').value.replace(/-/g,''), carryDays:tr.querySelector('.qc').value, annualDays:tr.querySelector('.qa').value, monthlyDays:tr.querySelector('.qm').value, remark:tr.querySelector('.qr').value }; });
  post('/mangr/leaveQuotaSave.do', { year:yearOf(), items:items }, true).then(function(){ qtClose(); toast('부여 일수를 저장했습니다','ok');
    return post('/mangr/leaveUsers.do','').then(function(j){ if(j&&j.data) _users=j.data; }); }).then(function(){ load(); }).catch(function(e){ swErr(e.message); });
}

/* ── 엑셀 (2026-10-21 「엑셀 월별·연별·사원별 휴가 리스트」 → 「엑셀 자료 제공 형태 스타일로」) ──
     매출장(salesLedger.jsp ledgerSheet)과 같은 꼴 : 굴림 9 · 제목 [ … ] 17 굵게(두 줄 합침) · 조회기간 줄(밑줄) · 머리글 하늘(D9EDF7) 테두리 · 본문 흰 바탕 테두리 · 합 계 크림(FCF8E3) */
function wch(s){ var w=0; String(s||'').split('').forEach(function(ch){ w+=(ch.charCodeAt(0)>255?1.8:1); }); return w; }
function fnSafe(s){ return String(s||'').replace(/[\\\/:*?"<>|]/g,'_').trim(); }
/* 한 시트 — title '[휴가 목록]' · period '조회기간 : …' · head [] · rows [[…]] · kinds[r] = 'row'|'sub'|'tot' · opt {cols:[wch…], right:[칸 번호…], num:[칸 번호…]} */
function xlsSheet(title, period, head, rows, kinds, opt){
  var N=head.length, bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd }, E=function(k){ var x=[]; for(var i=0;i<k;i++) x.push(''); return x; };
  var aoa=[ [title].concat(E(N-1)), E(N), [period].concat(E(N-1)), head.slice() ], kk=['t','t','p','h'];
  rows.forEach(function(r,i){ aoa.push(r); kk.push(kinds[i]||'row'); });
  var ws=XLSX.utils.aoa_to_sheet(aoa), right=opt.right||[], num=opt.num||[];
  for(var r=0;r<aoa.length;r++){ var k=kk[r];
    for(var c=0;c<N;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'굴림', sz:17, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else { st.border=box; st.fill={ fgColor:{ rgb:(k==='tot'?'FCF8E3':(k==='sub'?'F4F6F8':'FFFFFF')) } };
        st.alignment.horizontal = right.indexOf(c)>=0 ? 'right' : ((k==='tot'||k==='sub') && c===0 ? 'center' : 'left');
        if(k!=='row') st.font.bold=true;
        if(ws[ref].t==='n' && num.indexOf(c)>=0) ws[ref].z='#,##0.#'; }
      ws[ref].s=st; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:N-1 } }, { s:{ r:2, c:0 }, e:{ r:2, c:N-1 } } ];
  ws['!cols']=(opt.cols||[]).map(function(w){ return { wch:w }; });
  ws['!rows']=aoa.map(function(x,i){ return { hpt:(i<2?18.75:16.5) }; });
  return ws;
}
var LV_HEAD=['직원','구분','시작일','종료일','일수','사유','상태','승인자','신청일','날인'], LV_OPT={ cols:[9,10,11,11,6,30,7,9,16,9], right:[4], num:[4] };   /* 날인 = 빈 칸, 출력해서 도장 (2026-10-21 「엑셀에 직원 날인 추가」) */
function lvRow(o){ return [o.userNm, o.leaveGb, fmtDt(o.fromDt), fmtDt(o.toDt), n(o.days), o.remark||'', o.status, o.status!=='신청'?(o.statUser||''):'', String(o.regDttm||'').slice(0,16), '']; }
function lvTot(label, rows){ var d=rows.reduce(function(a,o){ return a+(o.status==='반려'?0:n(o.days)); },0); return [label,'','','',d,rows.length+'건 (반려 제외 일수)','','','','']; }
function xlsListSheet(period, rows){ var R=rows.map(lvRow), K=rows.map(function(){ return 'row'; }); R.push(lvTot('합 계', rows)); K.push('tot');
  var opt={ cols:LV_OPT.cols.slice(), right:LV_OPT.right, num:LV_OPT.num }; var w=opt.cols[5]; rows.forEach(function(o){ w=Math.max(w, Math.min(50, wch(o.remark)+2)); }); opt.cols[5]=w;
  return xlsSheet('[휴가 목록]', period, LV_HEAD, R, K, opt); }
function xlsSumSheet(){
  var C=sumCols(), years=_years.length?_years:[yearOf()];
  var head=['연도','직원','연차 이월','연차 부여','연차 사용','연차 잔여'].concat(C.hasM?['월차 부여','월차 사용','월차 잔여']:[]).concat(C.hasHalf?['반일(건)']:[]).concat(C.others), R=[], K=[];
  years.forEach(function(y){
    var Y=_sumYears[y]||{ sum:[], quota:[] }, q={}; (Y.quota||[]).forEach(function(x){ q[x.userId]=x; });
    var by={}; (Y.sum||[]).forEach(function(s){ var u=by[s.userId]=by[s.userId]||{}; u[s.leaveGb]={ days:n(s.days), cnt:n(s.cnt) }; });
    var ids=_users.map(function(u){ return u.userId; }); (Y.sum||[]).forEach(function(s){ if(ids.indexOf(s.userId)<0) ids.push(s.userId); });
    var T=[]; for(var i=2;i<head.length;i++) T.push(0);
    ids.forEach(function(id){ var u=_users.filter(function(x){ return x.userId===id; })[0]||{ userNm:((Y.sum||[]).filter(function(s){ return s.userId===id; })[0]||{}).userNm||id };
      var r=sumCalc(by[id]||{}, C), aq=q[id]?n(q[id].annualDays):15, mq=q[id]?n(q[id].monthlyDays):0, cq=carryOf(y,id);
      var row=[y, u.userNm, cq, aq, r.au, cq+aq-r.au].concat(C.hasM?[mq, r.mu, mq-r.mu]:[]).concat(C.hasHalf?[r.half]:[]).concat(C.others.map(function(nm){ return r.oth[nm]||0; }));
      R.push(row); K.push('row'); for(var i=2;i<row.length;i++) T[i-2]+=row[i]; });
    R.push([y, y+' 합계'].concat(T)); K.push('sub'); });
  var cols=[7,9], right=[], num=[]; for(var i=2;i<head.length;i++){ cols.push(Math.max(7, Math.min(14, wch(head[i])+1))); right.push(i); num.push(i); }
  return xlsSheet('[휴가 현황]', '연도별 (부여 − 사용 = 잔여 · 반려 제외 · 반일 구분 0.5일)', head, R, K, { cols:cols, right:right, num:num }); }

/* 연차 양식 — 사용자 수기 양식(연차양식.xlsx, 2026-10-21 카카오톡) 모양으로 그 해(달력 연도) 한 시트 :
   ① 연차 현황(성명·입사일·근속·전년 이월·부여·1~12월 사용·사용 합계·남은 일수 — 연차 차감 구분만, 기간은 평일 수로 달마다 나눔)
   ② 직원별 사용 날짜(26.03.03~04 꼴, (반)=반일, 괄호=연차 아닌 구분)
   ③ 연차 사용 대장(신청 일자·휴가 일자·사용 일수·구분·성명·날인·비고 + 빈 줄 8) — 날인 칸은 비워 둔다, 출력해서 도장. 반려는 뺀다 */
function xlsForm(){
  var y=yearOf(), rows=_allRows.filter(function(o){ return String(o.fromDt).slice(0,4)===y && o.status!=='반려'; });
  var Q=(_sumYears[y]||{ quota:[] }).quota||[], q={}; Q.forEach(function(x){ q[x.userId]=x; });
  var bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var cs=function(o){ var s={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', horizontal:'center', wrapText:true }, border:box }; if(o) Object.keys(o).forEach(function(k){ s[k]=o[k]; }); return s; };
  var H=cs({ font:{ name:'굴림', sz:9, bold:true }, fill:{ fgColor:{ rgb:'D9EDF7' } } }), L=cs({ alignment:{ vertical:'center', horizontal:'left', wrapText:true } }), R=cs({ alignment:{ vertical:'center', horizontal:'right' } });
  var T=cs({ font:{ name:'굴림', sz:9, bold:true }, fill:{ fgColor:{ rgb:'FCF8E3' } } }), TR=cs({ font:{ name:'굴림', sz:9, bold:true }, fill:{ fgColor:{ rgb:'FCF8E3' } }, alignment:{ vertical:'center', horizontal:'right' } });
  var SEC=cs({ font:{ name:'굴림', sz:10, bold:true }, alignment:{ vertical:'center', horizontal:'left' }, border:{} });
  var aoa=[], ST=[], merges=[], hts=[];
  var put=function(cells, st, h){ aoa.push(cells); ST.push(st||[]); hts.push(h||16.5); return aoa.length-1; };
  var mon=function(o){ var m=[0,0,0,0,0,0,0,0,0,0,0,0], wk=[0,0,0,0,0,0,0,0,0,0,0,0], tot=0;   /* 기간의 평일을 달별로 세어 일수를 나눈다 */
    var a=String(o.fromDt), b=String(o.toDt), d=new Date(+a.slice(0,4), +a.slice(4,6)-1, +a.slice(6,8)), e=new Date(+b.slice(0,4), +b.slice(4,6)-1, +b.slice(6,8));
    for(; d<=e; d.setDate(d.getDate()+1)){ if(String(d.getFullYear())!==y) continue; if(d.getDay()===0||d.getDay()===6) continue; wk[d.getMonth()]++; tot++; }
    if(!tot){ if(a.slice(0,4)===y) m[+a.slice(4,6)-1]=n(o.days); return m; }
    for(var i=0;i<12;i++) m[i]=Math.round(n(o.days)*wk[i]/tot*10)/10; return m; };
  var dstr=function(o){ var a=String(o.fromDt), b=String(o.toDt), s=a.slice(2,4)+'.'+a.slice(4,6)+'.'+a.slice(6,8);
    if(b!==a) s+='~'+(b.slice(0,6)===a.slice(0,6)?b.slice(6,8):b.slice(4,6)+'.'+b.slice(6,8));
    var g=gbDef(o.leaveGb); if(g.half) s+='(반)'; else if(g.kind!=='annual') s+='('+o.leaveGb+')'; return s; };
  var byU={}; rows.forEach(function(o){ (byU[o.userId]=byU[o.userId]||[]).push(o); });
  var maxD=0; Object.keys(byU).forEach(function(k){ maxD=Math.max(maxD, byU[k].length); });
  var W=Math.max(19, 2+maxD), E=function(k){ var x=[]; for(var i=0;i<k;i++) x.push(''); return x; };
  var full=function(v, st, h){ var r=put([v].concat(E(W-1)), [st], h); merges.push({ s:{ r:r, c:0 }, e:{ r:r, c:W-1 } }); return r; };
  full(y+'년 연차사용 내역', { font:{ name:'굴림', sz:17, bold:true }, alignment:{ vertical:'center', horizontal:'center' } }, 30);
  put(E(W));
  var who=_users.filter(function(u){ return String(u.joinDt||'').trim().length===8; }).map(function(u){ var s=qtSug(u.joinDt, y), x=q[u.userId]; return u.userNm+' '+(s.n?s.n+'년차-'+((x&&x.annualDays!=null)?fmtD(x.annualDays):s.days)+'일':'입사한 해'); });
  full('연차 : 1~2년차 15일 · 3년차부터 2년마다 1일 추가(3·4년차 16일, 5·6년차 17일 …) · 입사한 해는 월 1일 발생'+(who.length?'   |   '+who.join(' · '):''), cs({ alignment:{ vertical:'center', horizontal:'left', wrapText:true }, border:{} }), 22);
  put(E(W));
  /* ① */
  full('① 연차 현황 (연차 차감 구분만 · 남은 일수 = 전년 이월 + 부여 − 사용)', SEC, 18);
  var h1=['성명','입사일','근속','전년 이월',y+'년 부여','1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월','사용 합계','남은 일수'];
  put(h1.concat(E(W-h1.length)), h1.map(function(){ return H; }));
  var tm=[0,0,0,0,0,0,0,0,0,0,0,0], tc=0, ta=0, tu=0, r1=function(v){ return Math.round(v*10)/10; };
  _users.forEach(function(u){ var x=q[u.userId]||{}, jd=String(u.joinDt||'').trim(), s=qtSug(jd, y), cq=carryOf(y,u.userId), aq=x.annualDays!=null?n(x.annualDays):15, m=[0,0,0,0,0,0,0,0,0,0,0,0];
    (byU[u.userId]||[]).forEach(function(o){ if(gbDef(o.leaveGb).kind!=='annual') return; var mm=mon(o); for(var i=0;i<12;i++) m[i]+=mm[i]; });
    var used=0; for(var i=0;i<12;i++){ m[i]=r1(m[i]); used+=m[i]; tm[i]+=m[i]; } used=r1(used); tc+=cq; ta+=aq; tu+=used;
    var r=[u.userNm, jd.length===8?fmtDt(jd):'', s.n==null?'':(s.n?s.n+'년차':'첫해'), cq||'', aq].concat(m.map(function(v){ return v||''; })).concat([used||'', r1(cq+aq-used)]);
    put(r.concat(E(W-r.length)), r.map(function(v,i){ return i<3?cs():R; })); });
  var rt=['합계','','',tc||'',ta].concat(tm.map(function(v){ return r1(v)||''; })).concat([r1(tu)||'', r1(tc+ta-tu)]);
  put(rt.concat(E(W-rt.length)), rt.map(function(v,i){ return i<3?T:TR; }));
  put(E(W));
  /* ② */
  full('② 직원별 사용 날짜 — (반)=반일, 괄호=연차 아닌 구분', SEC, 18);
  var h2=['성명','건수'].concat(E(W-2)); put(h2, h2.map(function(v,i){ return i<2?H:cs({ fill:{ fgColor:{ rgb:'D9EDF7' } } }); }));
  _users.forEach(function(u){ var l=byU[u.userId]||[]; if(!l.length) return; var r=[u.userNm, l.length].concat(l.map(dstr)); put(r.concat(E(W-r.length)), r.map(function(v,i){ return i===1?R:cs(); })); });
  put(E(W));
  /* ③ */
  full('③ 연차 사용 대장 — 날인 칸에 본인 도장 (출력용)', SEC, 18);
  var h3=['신청 일자','휴가 일자','사용 일수','구분','성 명','날 인','비 고']; put(h3.concat(E(W-h3.length)), h3.map(function(){ return H; }));
  rows.slice().sort(function(a,b){ return String(a.fromDt)<String(b.fromDt)?-1:(String(a.fromDt)>String(b.fromDt)?1:0); }).forEach(function(o){
    var r=[String(o.regDttm||'').slice(0,10), fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):''), n(o.days), o.leaveGb, o.userNm, '', ((o.remark||'')+(o.status==='신청'?' (신청 중)':'')).trim()];
    put(r.concat(E(W-r.length)), r.map(function(v,i){ return i===2?R:(i===6?L:cs()); }), 24); });
  for(var k=0;k<8;k++){ put(E(W), [cs(),cs(),cs(),cs(),cs(),cs(),cs()], 24); }   /* 손으로 적을 빈 줄 */
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  for(var r=0;r<aoa.length;r++) for(var c=0;c<W;c++){ var st=ST[r][c]; if(!st) continue; var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' }; ws[ref].s=st; }
  ws['!merges']=merges; ws['!rows']=hts.map(function(h){ return { hpt:h }; });
  var cols=[11,13,9,9,9,9,14]; for(var i=7;i<W;i++) cols.push(i<17?7.5:(i<19?9:11)); ws['!cols']=cols.map(function(w){ return { wch:w }; });
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, ('연차사용내역_'+y).slice(0,31));
  XLSX.writeFile(wb, fnSafe('연차사용 내역 '+y+'년')+'.xlsx');
}
function xlsMonth(){
  var rows=filtered(); if(!rows.length){ swErr('이 달에 휴가가 없습니다.'); return; }
  var a=new Date(_ym.getFullYear(), _ym.getMonth(), 1), b=new Date(_ym.getFullYear(), _ym.getMonth()+1, 0), tag=_ym.getFullYear()+'-'+('0'+(_ym.getMonth()+1)).slice(-2);
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, xlsListSheet('조회기간 : '+iso(a)+' ~ '+iso(b), rows), ('휴가목록_'+ymd(a)+'~'+ymd(b)).slice(0,31));
  XLSX.writeFile(wb, fnSafe('휴가 목록 '+tag)+'.xlsx'); }
function yearRows(){ var y=yearOf(); return Promise.resolve(_allRows.filter(function(o){ return String(o.fromDt).slice(0,4)===y; })); }   /* 달력 연도의 자료 — 전 연도 자료에서 */
function xlsYear(){ var years=_years.length?_years:[yearOf()]; if(!_allRows.length){ swErr('휴가가 없습니다.'); return; }
  var wb=XLSX.utils.book_new(), cnt=0;   /* 연도마다 시트 하나(올해 먼저) + 연도별 현황 (2026-10-21 「엑셀도 이전 내용 보여 줘」) */
  years.forEach(function(y){ var rows=_allRows.filter(function(o){ return String(o.fromDt).slice(0,4)===y; }); if(!rows.length) return; cnt++;
    XLSX.utils.book_append_sheet(wb, xlsListSheet('조회기간 : '+y+'-01-01 ~ '+y+'-12-31', rows), ('휴가목록_'+y).slice(0,31)); });
  XLSX.utils.book_append_sheet(wb, xlsSumSheet(), '휴가현황_연도별');
  XLSX.writeFile(wb, fnSafe('휴가 목록 연도별 '+years[years.length-1]+(years.length>1?'~'+years[0]:''))+'.xlsx'); }

/* 사원별 = 시트 하나에 직원 차례로(직원마다 소계 줄, 끝에 합계) — 2026-10-21 사용자 「직원마다 시트 말고 통합으로」. 직원을 골라 두면 그 직원만 */
function xlsUser(){ Promise.resolve(_allRows).then(function(rows){ var years=_years.length?_years:[yearOf()], tag=years[years.length-1]+(years.length>1?'~'+years[0]:'');
    var fu=document.getElementById('fUser').value, R=[], K=[], all=[];   /* 전 연도, 직원마다 날짜순 + 소계 (2026-10-21 「엑셀도 이전 내용」) */
    _users.forEach(function(u){ if(fu && u.userId!==fu) return; var r=rows.filter(function(o){ return o.userId===u.userId; }); if(!r.length) return;
      r.forEach(function(o){ R.push(lvRow(o)); K.push('row'); all.push(o); }); R.push(lvTot(u.userNm+' 소계', r)); K.push('sub'); });
    if(!all.length){ swErr('휴가가 없습니다.'); return; }
    R.push(lvTot('합 계', all)); K.push('tot');
    var opt={ cols:LV_OPT.cols.slice(), right:LV_OPT.right, num:LV_OPT.num }; var w=opt.cols[5]; all.forEach(function(o){ w=Math.max(w, Math.min(50, wch(o.remark)+2)); }); opt.cols[5]=w;
    var who=fu?((_users.filter(function(u){ return u.userId===fu; })[0]||{}).userNm||''):'';
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, xlsSheet('[사원별 휴가]', '조회기간 : '+tag+'년 전체'+(who?' · '+who:''), LV_HEAD, R, K, opt), '사원별휴가'); XLSX.utils.book_append_sheet(wb, xlsSumSheet(), '휴가현황_연도별');
    XLSX.writeFile(wb, fnSafe('사원별 휴가 '+tag+(who?' '+who:''))+'.xlsx'); }).catch(function(e){ swErr(e.message); }); }

document.addEventListener('keydown', function(e){ if(e.key==='Escape'){ if(document.getElementById('lvPop').classList.contains('on')) lvClose(); else if(document.getElementById('qtPop').classList.contains('on')) qtClose(); } });
window.konetShown=function(){ load(); };   /* 셸이 다시 보여 줄 때 다시 읽는다 — 다른 직원이 올린 휴가가 바로 보이게 */
init();
</script>
</body>
</html>
