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
      [📋 목록] 으로 바꾸면 그 달 휴가 줄 목록(수정·삭제·승인·반려)
    · 권한 = 서버가 정한다(leaveUsers.do 의 admin). 총괄관리자만 관리자 : 모든 직원 등록·수정·승인·반려·부여 일수. 그 밖(부관리자·담당자) : 제 휴가만 등록(상태 「신청」)·수정·삭제
      (2026-10-21 사용자 「기존 정보 설정은 총괄관리자가 수정할 수 있게」「수정은 본인 것만」)
    · 일수 = 평일 수(토·일 뺌, 공휴일은 안 뺀다 — 손으로 고칠 수 있음) · 반차 = 0.5 하루
    · 엑셀 = 월별(지금 달 줄) · 연별(그 해 줄 + 현황 시트) · 사원별(그 해를 직원 차례로 한 시트에, 직원마다 소계 + 현황 시트)
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
  .gb-연차{ background:#137a6c; } .gb-월차{ background:#2f4f9a; } .gb-반차{ background:#6b4fa0; } .gb-병가{ background:#c0392b; }
  .gb-경조{ background:#b45309; } .gb-공가{ background:#3b7a57; } .gb-기타{ background:#5a6b7a; }
  .legend{ display:flex; gap:10px; flex-wrap:wrap; font-size:12px; color:#3d4d5c; margin-top:6px; align-items:center; }
  .legend i{ display:inline-block; width:12px; height:12px; border-radius:3px; vertical-align:-1px; margin-right:3px; }
  /* 현황·목록 표 */
  .box{ border:1px solid var(--bd); border-radius:8px; overflow:hidden; }
  .box .bh{ display:flex; align-items:center; gap:8px; padding:7px 10px; background:#eef5f3; border-bottom:1px solid var(--bd); font-weight:800; color:#0b4f43; font-size:13.5px; }
  .box .bh small{ font-weight:400; color:var(--gray); }
  table.grid{ width:100%; border-collapse:collapse; font-size:13px; }
  table.grid th{ background:#f3f6f8; color:#3d4d5c; font-weight:800; padding:5px 4px; border-bottom:1px solid var(--bd); border-right:1px solid #eef1f4; white-space:nowrap; text-align:center; }
  table.grid td{ padding:4px 5px; border-bottom:1px solid #eef1f4; border-right:1px solid #f1f4f6; text-align:center; white-space:nowrap; }
  table.grid td.l{ text-align:left; } table.grid td.r{ text-align:right; }
  table.grid tr.pick:hover td{ background:#f7fbfa; cursor:pointer; }
  table.grid tr.tot td{ background:#eef5f3; font-weight:800; }
  table.grid tr.me td{ background:#fffbea; }
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
  .hint{ font-size:12px; color:var(--gray); }
  .pend-row{ display:flex; align-items:center; gap:8px; padding:5px 10px; border-bottom:1px solid #f1f4f6; font-size:13px; }
  .pend-row:last-child{ border-bottom:0; } .pend-row .who{ font-weight:800; min-width:60px; } .pend-row .hint{ flex:1; }
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
</head>
<body>
<div class="lv-wrap">
  <div class="lv-head"><h2>🏖 직원 휴가 관리</h2><span class="desc">연차·월차·반차·병가를 직원별로 등록하고 달력과 연간 현황으로 봅니다. 본인 휴가는 누구나 등록·수정(「신청」 상태), 승인·반려와 다른 직원 휴가 수정·부여 일수는 총괄관리자만 합니다.</span></div>

  <div class="lv-bar">
    <button class="lv-btn" onclick="lvMove(-1)" title="지난 달">◀</button>
    <span class="lv-ym" id="lvYm">—</span>
    <button class="lv-btn" onclick="lvMove(1)" title="다음 달">▶</button>
    <button class="lv-btn" onclick="lvToday()">오늘</button>
    <span class="lv-sep"></span>
    <button class="lv-btn on" id="btnCal" onclick="lvView('cal')">📅 달력</button>
    <button class="lv-btn" id="btnList" onclick="lvView('list')">📋 목록</button>
    <span class="lv-sep"></span>
    <label style="font-size:12.5px; font-weight:700">직원</label>
    <select id="fUser" onchange="lvRender()" title="달력·목록을 이 직원만 보기"><option value="">전체</option></select>
    <label style="font-size:12.5px; font-weight:700">구분</label>
    <select id="fGb" onchange="lvRender()" title="달력·목록을 이 구분만 보기"><option value="">전체</option></select>
    <span style="margin-left:auto"></span>
    <button class="lv-btn teal" onclick="lvOpen(null,null)">＋ 휴가 등록</button>
    <button class="lv-btn xls" onclick="xlsMonth()" title="지금 달의 휴가 줄을 엑셀로">📥 월별</button>
    <button class="lv-btn xls" onclick="xlsYear()" title="올해(달력의 해) 휴가 줄 전체 + 현황 시트">📥 연별</button>
    <button class="lv-btn xls" onclick="xlsUser()" title="올해 휴가를 직원 차례로 한 시트에(직원마다 소계) + 현황 시트. 직원을 골라 두면 그 직원만">📥 사원별</button>
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
        <table class="grid"><thead><tr><th style="width:90px">직원</th><th style="width:84px">구분</th><th style="width:190px">기간</th><th style="width:52px">일수</th><th>사유</th><th style="width:120px">상태</th><th style="width:120px">등록</th><th style="width:170px"></th></tr></thead>
          <tbody id="listBody"><tr><td colspan="8" class="msg">불러오는 중…</td></tr></tbody></table>
      </div>
    </div>
    <div class="lv-right">
      <div class="box">
        <div class="bh">📊 <span id="sumTitle">연간 현황</span> <small>부여 − 사용 = 잔여 · 반려는 안 셉니다 · 이름을 누르면 그 직원만</small></div>
        <table class="grid" id="sumTbl">
          <thead><tr><th rowspan="2" style="width:74px">직원</th><th colspan="3">연차</th><th colspan="3">월차</th><th rowspan="2" title="반차 건수(0.5일씩, 연차에서 뺀다)">반차</th><th rowspan="2">병가</th><th rowspan="2">경조</th><th rowspan="2">공가</th><th rowspan="2">기타</th><th rowspan="2" title="승인 대기 건수">대기</th></tr>
                 <tr><th>부여</th><th>사용</th><th>잔여</th><th>부여</th><th>사용</th><th>잔여</th></tr></thead>
          <tbody id="sumBody"><tr><td colspan="13" class="msg">불러오는 중…</td></tr></tbody>
        </table>
        <div class="hint" style="padding:6px 10px">반차는 0.5일로 연차 사용에 들어갑니다. 공휴일은 일수에서 자동으로 빠지지 않으니 등록 창에서 일수를 고치세요.</div>
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
      <button class="lv-btn teal" onclick="lvSave()">💾 저장</button>
    </div>
  </div>
</div>

<%-- 부여 일수 (관리자) --%>
<div class="pop" id="qtPop">
  <div class="bx" style="width:min(640px,96vw)">
    <div class="hd">⚙ <span id="qtTitle">부여 일수</span><span class="hint" style="margin-left:6px">직원마다 올해 연차·월차 부여 일수</span><span style="margin-left:auto; font-size:18px; cursor:pointer; color:#8a98a8" onclick="qtClose()">✕</span></div>
    <div class="bd">
      <table class="grid"><thead><tr><th style="width:110px">직원</th><th style="width:110px">연차 부여</th><th style="width:110px">월차 부여(연간)</th><th>메모</th></tr></thead><tbody id="qtBody"></tbody></table>
      <div class="hint" style="margin-top:6px">비워 둔 직원은 연차 15일·월차 0일로 봅니다. 월차를 안 쓰는 회사는 0으로 두세요.</div>
    </div>
    <div class="ft"><span style="margin-left:auto"></span><button class="lv-btn" onclick="qtClose()">닫기</button><button class="lv-btn teal" onclick="qtSave()">💾 저장</button></div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
var GBS=['연차','월차','반차(오전)','반차(오후)','병가','경조','공가','기타'];
var _ym=new Date(); _ym=new Date(_ym.getFullYear(), _ym.getMonth(), 1);
var _users=[], _me='', _meNm='', _admin=false, _rows=[], _sum=[], _quota=[], _view='cal', _cur=null, _yearRows=null;
function n(v){ var x=parseFloat(String(v==null?'':v).replace(/,/g,'')); return isNaN(x)?0:x; }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }).then(function(r){ return r.json(); }).then(function(j){ if(j&&j.error) throw new Error(j.error); return j; }); }
function swErr(m){ if(window._alertBox) _alertBox(m,{icon:'❌',okColor:'red'}); else alert(String(m).replace(/<[^>]+>/g,'')); }
function toast(m,k){ if(window._toast) _toast(m,k||'ok'); }
function ymd(d){ return d.getFullYear()+('0'+(d.getMonth()+1)).slice(-2)+('0'+d.getDate()).slice(-2); }
function iso(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function fmtDt(s){ s=String(s||'').replace(/-/g,''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function fmtD(v){ var x=n(v); return (Math.round(x*10)/10).toLocaleString('ko-KR'); }
function gbCls(g){ g=String(g||''); return 'gb-'+(g.indexOf('반차')===0?'반차':(GBS.indexOf(g)>=0?g:'기타')); }
function gbShort(g){ g=String(g||''); return g==='반차(오전)'?'반차AM':(g==='반차(오후)'?'반차PM':g); }
function weekdays(a,b){ var d=new Date(a.getTime()), c=0; while(d<=b){ var w=d.getDay(); if(w!==0&&w!==6) c++; d.setDate(d.getDate()+1); } return c; }
function yearOf(){ return String(_ym.getFullYear()); }

/* ── 초기 ── */
function init(){
  var gb=document.getElementById('fGb'); GBS.forEach(function(g){ gb.insertAdjacentHTML('beforeend','<option>'+g+'</option>'); });
  var eg=document.getElementById('eGb'); GBS.forEach(function(g){ eg.insertAdjacentHTML('beforeend','<option>'+g+'</option>'); });
  document.getElementById('legend').innerHTML=['연차','월차','반차','병가','경조','공가','기타'].map(function(g){ return '<span><i class="'+gbCls(g)+'"></i>'+g+'</span>'; }).join('')
    +'<span style="margin-left:8px"><span class="chip pend" style="display:inline-block; background:#8a98a8; padding:0 6px">점선 = 신청(승인 대기)</span></span><span class="hint" style="margin-left:auto">빈 칸 <b>더블클릭</b> = 그 날짜로 등록 · 칩 <b>더블클릭</b> = 열기 · 마우스를 올리면 내용</span>';
  post('/mangr/leaveUsers.do','').then(function(j){
    _users=(j&&j.data)||[]; _admin=(j.admin==='Y'); _me=j.userId||''; _meNm=j.userNm||'';
    var fu=document.getElementById('fUser'), eu=document.getElementById('eUser');
    _users.forEach(function(u){ fu.insertAdjacentHTML('beforeend','<option value="'+esc(u.userId)+'">'+esc(u.userNm)+'</option>'); eu.insertAdjacentHTML('beforeend','<option value="'+esc(u.userId)+'">'+esc(u.userNm)+'</option>'); });
    if(_admin) document.getElementById('btnQuota').style.display='';
    load();
  }).catch(function(e){ swErr(e.message); });
}
function load(){
  var a=new Date(_ym.getFullYear(), _ym.getMonth(), 1), b=new Date(_ym.getFullYear(), _ym.getMonth()+1, 0);
  document.getElementById('lvYm').textContent=_ym.getFullYear()+'년 '+(_ym.getMonth()+1)+'월';
  document.getElementById('sumTitle').textContent=_ym.getFullYear()+'년 현황';
  _yearRows=null;
  Promise.all([
    post('/mangr/leaveList.do','frDt='+ymd(a)+'&toDt='+ymd(b)),
    post('/mangr/leaveSummary.do','year='+yearOf())
  ]).then(function(r){ _rows=(r[0]&&r[0].data)||[]; _sum=(r[1]&&r[1].data)||[]; _quota=(r[1]&&r[1].quota)||[]; lvRender(); sumRender(); })
    .catch(function(e){ swErr(e.message); });
}
function lvMove(k){ _ym=new Date(_ym.getFullYear(), _ym.getMonth()+k, 1); load(); }
function lvToday(){ var t=new Date(); _ym=new Date(t.getFullYear(), t.getMonth(), 1); load(); }
function lvView(v){ _view=v; document.getElementById('btnCal').classList.toggle('on', v==='cal'); document.getElementById('btnList').classList.toggle('on', v==='list');
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
        +(out?'':list.map(function(o){ return '<span class="chip '+gbCls(o.leaveGb)+(o.status==='신청'?' pend':'')+(o.status==='반려'?' rej':'')+'" ondblclick="event.stopPropagation(); lvOpen('+o.leaveSeq+',null)" title="'+esc(o.userNm+' · '+o.leaveGb+' · '+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+' · '+fmtD(o.days)+'일 · '+o.status+(o.remark?' · '+o.remark:''))+'">'+esc(o.userNm)+' '+esc(gbShort(o.leaveGb))+'</span>'; }).join(''))
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
  bar.innerHTML='<div class="bh">⏳ 승인 대기 <span class="st 신청">'+p.length+'건</span> <small>줄의 버튼으로 바로 승인·반려 — 내용을 보려면 「열기」</small></div>'
    + p.map(function(o){ return '<div class="pend-row"><span class="who">'+esc(o.userNm)+'</span><span class="chip '+gbCls(o.leaveGb)+'" style="display:inline-block">'+esc(o.leaveGb)+'</span>'
        +'<span>'+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+' · '+fmtD(o.days)+'일</span><span class="hint">'+esc(o.remark||'')+'</span>'
        +'<button class="mini" onclick="lvOpen('+o.leaveSeq+',null)">열기</button><button class="mini ok" onclick="lvStatus('+o.leaveSeq+',\'승인\')">✔ 승인</button><button class="mini no" onclick="lvStatus('+o.leaveSeq+',\'반려\')">✖ 반려</button></div>'; }).join('');
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
      +'<td>'+(can?'<button class="mini" onclick="lvOpen('+o.leaveSeq+',null)">✏ 수정</button><button class="mini no" onclick="lvDeleteSeq('+o.leaveSeq+')">🗑</button>':'')
      +(_admin&&o.status!=='승인'?'<button class="mini ok" onclick="lvStatus('+o.leaveSeq+',\'승인\')">✔ 승인</button>':'')
      +(_admin&&o.status!=='반려'?'<button class="mini no" onclick="lvStatus('+o.leaveSeq+',\'반려\')">✖ 반려</button>':'')+'</td></tr>';
  }).join('') : '<tr><td colspan="8" class="msg">이 달에 휴가가 없습니다.</td></tr>';
}

/* ── 연간 현황 ── */
function sumRender(){
  var q={}; _quota.forEach(function(x){ q[x.userId]=x; });
  var by={}; _sum.forEach(function(s){ var u=by[s.userId]=by[s.userId]||{ userId:s.userId, userNm:s.userNm, g:{}, pend:0 }; u.g[s.leaveGb]={ days:n(s.days), cnt:n(s.cnt) }; u.pend+=n(s.pendCnt); });
  var ids=_users.map(function(u){ return u.userId; }); Object.keys(by).forEach(function(k){ if(ids.indexOf(k)<0) ids.push(k); });   /* 퇴직자도 올해 휴가가 있으면 보인다 */
  var tot={ aq:0, au:0, mq:0, mu:0, half:0, sick:0, fam:0, pub:0, etc:0, pend:0 }, h='';
  ids.forEach(function(id){
    var u=_users.filter(function(x){ return x.userId===id; })[0]||{ userId:id, userNm:(by[id]||{}).userNm||id };
    var s=by[id]||{ g:{}, pend:0 }, g=function(k){ return (s.g[k]||{ days:0, cnt:0 }); };
    var aq=q[id]?n(q[id].annualDays):15, mq=q[id]?n(q[id].monthlyDays):0;
    var half=g('반차(오전)').cnt+g('반차(오후)').cnt, halfDays=g('반차(오전)').days+g('반차(오후)').days;
    var au=g('연차').days+halfDays, mu=g('월차').days;
    tot.aq+=aq; tot.au+=au; tot.mq+=mq; tot.mu+=mu; tot.half+=half; tot.sick+=g('병가').days; tot.fam+=g('경조').days; tot.pub+=g('공가').days; tot.etc+=g('기타').days; tot.pend+=s.pend;
    h+='<tr class="pick'+(id===_me?' me':'')+'" onclick="lvPickUser(\''+esc(id)+'\')" title="이 직원만 보기">'
      +'<td class="l"><b>'+esc(u.userNm)+'</b></td><td>'+fmtD(aq)+'</td><td>'+fmtD(au)+'</td><td class="rem'+(aq-au<0?' neg':'')+'">'+fmtD(aq-au)+'</td>'
      +'<td>'+(mq?fmtD(mq):'')+'</td><td>'+(mu?fmtD(mu):'')+'</td><td class="rem'+(mq-mu<0?' neg':'')+'">'+(mq||mu?fmtD(mq-mu):'')+'</td>'
      +'<td>'+(half?half+'건':'')+'</td><td>'+(g('병가').days?fmtD(g('병가').days):'')+'</td><td>'+(g('경조').days?fmtD(g('경조').days):'')+'</td><td>'+(g('공가').days?fmtD(g('공가').days):'')+'</td><td>'+(g('기타').days?fmtD(g('기타').days):'')+'</td>'
      +'<td>'+(s.pend?'<span class="st 신청">'+s.pend+'</span>':'')+'</td></tr>';
  });
  h+='<tr class="tot"><td class="l">합계</td><td>'+fmtD(tot.aq)+'</td><td>'+fmtD(tot.au)+'</td><td>'+fmtD(tot.aq-tot.au)+'</td><td>'+(tot.mq?fmtD(tot.mq):'')+'</td><td>'+(tot.mu?fmtD(tot.mu):'')+'</td><td>'+(tot.mq||tot.mu?fmtD(tot.mq-tot.mu):'')+'</td>'
    +'<td>'+(tot.half?tot.half+'건':'')+'</td><td>'+(tot.sick?fmtD(tot.sick):'')+'</td><td>'+(tot.fam?fmtD(tot.fam):'')+'</td><td>'+(tot.pub?fmtD(tot.pub):'')+'</td><td>'+(tot.etc?fmtD(tot.etc):'')+'</td><td>'+(tot.pend?tot.pend:'')+'</td></tr>';
  document.getElementById('sumBody').innerHTML=h||'<tr><td colspan="13" class="msg">직원이 없습니다.</td></tr>';
}
function lvPickUser(id){ var s=document.getElementById('fUser'); s.value=(s.value===id?'':id); lvRender(); }

/* ── 등록·수정 창 ── */
function lvOpen(seq, dateYmd){
  if(!seq && dateYmd){ var mine=_rows.filter(function(o){ return String(o.fromDt)<=dateYmd && String(o.toDt)>=dateYmd && (_admin || o.userId===_me); });
    if(mine.length===1){ seq=mine[0].leaveSeq; dateYmd=null; } }   /* 하나뿐이면 수정 창으로 바로 (2026-10-21) */
  _cur = seq ? _rows.filter(function(o){ return String(o.leaveSeq)===String(seq); })[0] : null;
  if(seq && !_cur){ swErr('그 휴가를 찾지 못했습니다 — 달을 다시 불러오세요.'); return; }
  if(_cur && !_admin && _cur.userId!==_me){ /* 담당자는 남의 휴가는 보기만 */
    swErr('<b>'+esc(_cur.userNm)+'</b> · '+esc(_cur.leaveGb)+' · '+fmtDt(_cur.fromDt)+(_cur.fromDt!==_cur.toDt?' ~ '+fmtDt(_cur.toDt):'')+' · '+fmtD(_cur.days)+'일 · '+esc(_cur.status)+(_cur.remark?'<br><span class="hint">'+esc(_cur.remark)+'</span>':'')+'<br><span class="hint">다른 직원의 휴가는 총괄관리자만 고칩니다.</span>'); return; }
  document.getElementById('lvPopTitle').textContent=_cur?'휴가 수정':'휴가 등록';
  var ex=document.getElementById('eExist'); ex.style.display='none'; ex.innerHTML='';
  if(!_cur && dateYmd){
    var exl=_rows.filter(function(o){ return String(o.fromDt)<=dateYmd && String(o.toDt)>=dateYmd; });
    if(exl.length){ ex.style.display='inline-flex'; ex.innerHTML='이 날짜 휴가 : '+exl.map(function(o){ return '<button class="mini" style="height:28px" onclick="lvOpen('+o.leaveSeq+',null)" title="열기 — 수정·삭제"><span class="chip '+gbCls(o.leaveGb)+'" style="display:inline-block; padding:0 6px">'+esc(o.userNm)+' '+esc(o.leaveGb)+'</span> 열기</button>'; }).join(''); }
  }
  _mcSel={}; _mc=null; document.getElementById('eMode').style.display=_cur?'none':''; lvMode('one');
  var eu=document.getElementById('eUser'), en=document.getElementById('eUserNm');
  if(_admin){ eu.style.display=''; en.style.display='none'; eu.value=_cur?_cur.userId:(document.getElementById('fUser').value||_me); if(!eu.value && _users.length) eu.value=_users[0].userId; }
  else { eu.style.display='none'; en.style.display=''; en.value=_meNm||_me; }
  document.getElementById('eGb').value=_cur?_cur.leaveGb:(document.getElementById('fGb').value||'연차');
  var f=_cur?fmtDt(_cur.fromDt):(dateYmd?fmtDt(dateYmd):iso(new Date())), t=_cur?fmtDt(_cur.toDt):f;
  document.getElementById('eFrom').value=f; document.getElementById('eTo').value=t;
  document.getElementById('eRemark').value=_cur?(_cur.remark||''):'';
  lvDays(); if(_cur) document.getElementById('eDays').value=n(_cur.days);
  document.getElementById('eDel').style.display=_cur?'':'none';
  var sr=document.getElementById('eStatRow'), sb=document.getElementById('eStatBtns');
  if(_cur){ sr.style.display=''; document.getElementById('eStat').innerHTML='<span class="st '+esc(_cur.status)+'">'+esc(_cur.status)+'</span>'+(_cur.statUser&&_cur.status!=='신청'?' <span class="hint">'+esc(_cur.statUser)+' · '+esc(String(_cur.statDttm||'').slice(0,16))+'</span>':'')+(!_admin?' <span class="hint">고쳐서 저장하면 다시 「신청」이 됩니다</span>':'');
    sb.style.display=_admin?'inline-flex':'none';
    var B=function(st,label,cls){ var cur=(_cur.status===st); return '<button class="lv-btn '+(cur?'on':cls)+'" '+(cur?'disabled title="지금 상태"':'onclick="lvStatus('+_cur.leaveSeq+',\''+st+'\')"')+'>'+label+(cur?' ✓':'')+'</button>'; };
    sb.innerHTML=_admin?(B('승인','✔ 승인','')+B('반려','✖ 반려','red')+B('신청','↩ 신청으로','')):''; }
  else { sr.style.display='none'; sb.style.display='none'; }
  document.getElementById('lvPop').classList.add('on');
  setTimeout(function(){ document.getElementById(_admin?'eUser':'eGb').focus(); }, 50);
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
  var uid=_admin?document.getElementById('eUser').value:_me;
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
  var half=String(document.getElementById('eGb').value||'').indexOf('반차')===0;
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
  var p={ userId:_admin?document.getElementById('eUser').value:_me, leaveGb:document.getElementById('eGb').value, dates:dates, remark:document.getElementById('eRemark').value };
  var u=_users.filter(function(x){ return x.userId===p.userId; })[0]; p.userNm=u?u.userNm:(_meNm||p.userId);
  post('/mangr/leaveSaveMulti.do', p, true).then(function(j){ lvClose(); var sk=(j.skipped||[]);
    toast(j.rows+'일을 등록했습니다 — 상태 '+(j.status||'')+(sk.length?' · 겹쳐서 건너뜀 '+sk.map(fmtDt).join(', '):''), sk.length?'warn':'ok');
    var d=dates[0]; _ym=new Date(+d.slice(0,4), +d.slice(4,6)-1, 1); load(); }).catch(function(e){ swErr(e.message); });
}
function lvDays(){
  var gb=document.getElementById('eGb').value, f=document.getElementById('eFrom').value, t=document.getElementById('eTo').value, dd=document.getElementById('eDays'), hint=document.getElementById('eDaysHint');
  var half=(gb.indexOf('반차')===0);
  if(_mode==='multi') mcRender();
  if(half){ document.getElementById('eTo').value=f; dd.value=0.5; dd.readOnly=true; hint.textContent='반차 = 0.5일 (하루)'; return; }
  dd.readOnly=false; hint.textContent='평일 수로 자동 계산 — 공휴일이 끼면 고치세요';
  if(!f) return; if(!t||t<f){ document.getElementById('eTo').value=f; t=f; }
  var a=new Date(f+'T00:00:00'), b=new Date(t+'T00:00:00'); dd.value=Math.max(0.5, weekdays(a,b));
}
function lvSave(){
  if(_mode==='multi' && !_cur){ lvSaveMulti(); return; }
  var p={ leaveSeq:_cur?_cur.leaveSeq:0, userId:_admin?document.getElementById('eUser').value:_me, leaveGb:document.getElementById('eGb').value,
          fromDt:document.getElementById('eFrom').value, toDt:document.getElementById('eTo').value, days:document.getElementById('eDays').value, remark:document.getElementById('eRemark').value };
  var u=_users.filter(function(x){ return x.userId===p.userId; })[0]; p.userNm=u?u.userNm:(_meNm||p.userId);
  if(!p.fromDt){ swErr('시작일을 넣으세요.'); return; }
  if(!(n(p.days)>0)){ swErr('일수를 넣으세요.'); return; }
  post('/mangr/leaveSave.do', p, true).then(function(j){ lvClose(); toast((_cur?'고쳤습니다':'등록했습니다')+' — 상태 '+(j.status||''),'ok'); var d=new Date(p.fromDt+'T00:00:00'); _ym=new Date(d.getFullYear(), d.getMonth(), 1); load(); })
    .catch(function(e){ swErr(e.message); });
}
function lvDelete(){ if(!_cur) return; lvDeleteSeq(_cur.leaveSeq); }
function lvDeleteSeq(seq){
  var o=_rows.filter(function(x){ return String(x.leaveSeq)===String(seq); })[0]; if(!o) return;
  var go=function(){ post('/mangr/leaveDelete.do','leaveSeq='+seq).then(function(){ lvClose(); toast('지웠습니다','ok'); load(); }).catch(function(e){ swErr(e.message); }); };
  if(window._confirmBox) _confirmBox({ msg:'<b>'+esc(o.userNm)+'</b> · '+esc(o.leaveGb)+' · '+fmtDt(o.fromDt)+(o.fromDt!==o.toDt?' ~ '+fmtDt(o.toDt):'')+' 를 지울까요?', icon:'🗑', okText:'지우기', okColor:'red', onOk:go });
  else if(confirm('지울까요?')) go();
}
function lvStatus(seq, st){ post('/mangr/leaveStatus.do','leaveSeq='+seq+'&status='+encodeURIComponent(st)).then(function(){ lvClose(); toast('「'+st+'」으로 바꿨습니다','ok'); load(); }).catch(function(e){ swErr(e.message); }); }

/* ── 부여 일수 ── */
function qtOpen(){
  var q={}; _quota.forEach(function(x){ q[x.userId]=x; });
  document.getElementById('qtTitle').textContent=yearOf()+'년 부여 일수';
  document.getElementById('qtBody').innerHTML=_users.map(function(u){ var x=q[u.userId]||{};
    return '<tr data-id="'+esc(u.userId)+'"><td class="l"><b>'+esc(u.userNm)+'</b> <span class="hint">'+esc(u.userId)+'</span></td>'
      +'<td><input type="number" step="0.5" min="0" class="qa" value="'+(x.annualDays!=null?n(x.annualDays):15)+'" style="width:84px; height:28px; text-align:right; border:1px solid var(--bd); border-radius:6px"></td>'
      +'<td><input type="number" step="0.5" min="0" class="qm" value="'+(x.monthlyDays!=null?n(x.monthlyDays):0)+'" style="width:84px; height:28px; text-align:right; border:1px solid var(--bd); border-radius:6px"></td>'
      +'<td><input type="text" class="qr" value="'+esc(x.remark||'')+'" maxlength="200" style="width:100%; height:28px; border:1px solid var(--bd); border-radius:6px; padding:0 6px"></td></tr>'; }).join('');
  document.getElementById('qtPop').classList.add('on');
}
function qtClose(){ document.getElementById('qtPop').classList.remove('on'); }
function qtSave(){
  var items=Array.prototype.map.call(document.querySelectorAll('#qtBody tr'), function(tr){ return { userId:tr.dataset.id, annualDays:tr.querySelector('.qa').value, monthlyDays:tr.querySelector('.qm').value, remark:tr.querySelector('.qr').value }; });
  post('/mangr/leaveQuotaSave.do', { year:yearOf(), items:items }, true).then(function(){ qtClose(); toast('부여 일수를 저장했습니다','ok'); load(); }).catch(function(e){ swErr(e.message); });
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
var LV_HEAD=['직원','구분','시작일','종료일','일수','사유','상태','승인자','등록일'], LV_OPT={ cols:[9,10,11,11,6,30,7,9,16], right:[4], num:[4] };
function lvRow(o){ return [o.userNm, o.leaveGb, fmtDt(o.fromDt), fmtDt(o.toDt), n(o.days), o.remark||'', o.status, o.status!=='신청'?(o.statUser||''):'', String(o.regDttm||'').slice(0,16)]; }
function lvTot(label, rows){ var d=rows.reduce(function(a,o){ return a+(o.status==='반려'?0:n(o.days)); },0); return [label,'','','',d,rows.length+'건 (반려 제외 일수)','','','']; }
function xlsListSheet(period, rows){ var R=rows.map(lvRow), K=rows.map(function(){ return 'row'; }); R.push(lvTot('합 계', rows)); K.push('tot');
  var opt={ cols:LV_OPT.cols.slice(), right:LV_OPT.right, num:LV_OPT.num }; var w=opt.cols[5]; rows.forEach(function(o){ w=Math.max(w, Math.min(50, wch(o.remark)+2)); }); opt.cols[5]=w;
  return xlsSheet('[휴가 목록]', period, LV_HEAD, R, K, opt); }
function xlsSumSheet(){
  var q={}; _quota.forEach(function(x){ q[x.userId]=x; }); var by={}; _sum.forEach(function(s){ (by[s.userId]=by[s.userId]||{})[s.leaveGb]=n(s.days); });
  var head=['직원','연차 부여','연차 사용','연차 잔여','월차 부여','월차 사용','월차 잔여','반차(일)','병가','경조','공가','기타'], R=[], K=[], T=[0,0,0,0,0,0,0,0,0,0,0];
  _users.forEach(function(u){ var g=by[u.userId]||{}, aq=q[u.userId]?n(q[u.userId].annualDays):15, mq=q[u.userId]?n(q[u.userId].monthlyDays):0, half=(g['반차(오전)']||0)+(g['반차(오후)']||0), au=(g['연차']||0)+half, mu=g['월차']||0;
    var row=[u.userNm, aq, au, aq-au, mq, mu, mq-mu, half, g['병가']||0, g['경조']||0, g['공가']||0, g['기타']||0]; R.push(row); K.push('row'); for(var i=1;i<12;i++) T[i-1]+=row[i]; });
  R.push(['합 계'].concat(T)); K.push('tot');
  return xlsSheet('[휴가 현황]', '기준연도 : '+yearOf()+'년 (부여 − 사용 = 잔여 · 반려 제외 · 반차 0.5일)', head, R, K, { cols:[9,9,9,9,9,9,9,8,7,7,7,7], right:[1,2,3,4,5,6,7,8,9,10,11], num:[1,2,3,4,5,6,7,8,9,10,11] }); }
function xlsMonth(){
  var rows=filtered(); if(!rows.length){ swErr('이 달에 휴가가 없습니다.'); return; }
  var a=new Date(_ym.getFullYear(), _ym.getMonth(), 1), b=new Date(_ym.getFullYear(), _ym.getMonth()+1, 0), tag=_ym.getFullYear()+'-'+('0'+(_ym.getMonth()+1)).slice(-2);
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, xlsListSheet('조회기간 : '+iso(a)+' ~ '+iso(b), rows), ('휴가목록_'+ymd(a)+'~'+ymd(b)).slice(0,31));
  XLSX.writeFile(wb, fnSafe('휴가 목록 '+tag)+'.xlsx'); }
function yearRows(){ if(_yearRows) return Promise.resolve(_yearRows); var y=yearOf();
  return post('/mangr/leaveList.do','frDt='+y+'0101&toDt='+y+'1231').then(function(j){ _yearRows=(j&&j.data)||[]; return _yearRows; }); }
function xlsYear(){ yearRows().then(function(rows){ var y=yearOf();
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, xlsListSheet('조회기간 : '+y+'-01-01 ~ '+y+'-12-31', rows), ('휴가목록_'+y+'0101~'+y+'1231').slice(0,31)); XLSX.utils.book_append_sheet(wb, xlsSumSheet(), '휴가현황_'+y);
    XLSX.writeFile(wb, fnSafe('휴가 목록 '+y+'년')+'.xlsx'); }).catch(function(e){ swErr(e.message); }); }
/* 사원별 = 시트 하나에 직원 차례로(직원마다 소계 줄, 끝에 합계) — 2026-10-21 사용자 「직원마다 시트 말고 통합으로」. 직원을 골라 두면 그 직원만 */
function xlsUser(){ yearRows().then(function(rows){ var y=yearOf();
    var fu=document.getElementById('fUser').value, R=[], K=[], all=[];
    _users.forEach(function(u){ if(fu && u.userId!==fu) return; var r=rows.filter(function(o){ return o.userId===u.userId; }); if(!r.length) return;
      r.forEach(function(o){ R.push(lvRow(o)); K.push('row'); all.push(o); }); R.push(lvTot(u.userNm+' 소계', r)); K.push('sub'); });
    if(!all.length){ swErr('올해 휴가가 없습니다.'); return; }
    R.push(lvTot('합 계', all)); K.push('tot');
    var opt={ cols:LV_OPT.cols.slice(), right:LV_OPT.right, num:LV_OPT.num }; var w=opt.cols[5]; all.forEach(function(o){ w=Math.max(w, Math.min(50, wch(o.remark)+2)); }); opt.cols[5]=w;
    var who=fu?((_users.filter(function(u){ return u.userId===fu; })[0]||{}).userNm||''):'';
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, xlsSheet('[사원별 휴가]', '조회기간 : '+y+'-01-01 ~ '+y+'-12-31'+(who?' · '+who:''), LV_HEAD, R, K, opt), ('사원별휴가_'+y).slice(0,31)); XLSX.utils.book_append_sheet(wb, xlsSumSheet(), '휴가현황_'+y);
    XLSX.writeFile(wb, fnSafe('사원별 휴가 '+y+'년'+(who?' '+who:''))+'.xlsx'); }).catch(function(e){ swErr(e.message); }); }

document.addEventListener('keydown', function(e){ if(e.key==='Escape'){ if(document.getElementById('lvPop').classList.contains('on')) lvClose(); else if(document.getElementById('qtPop').classList.contains('on')) qtClose(); } });
window.konetShown=function(){ load(); };   /* 셸이 다시 보여 줄 때 다시 읽는다 — 다른 직원이 올린 휴가가 바로 보이게 */
init();
</script>
</body>
</html>
