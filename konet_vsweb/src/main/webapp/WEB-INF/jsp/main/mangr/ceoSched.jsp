<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 쓰기 (전역 XLSX, 서식 포함) — 재고내용분석과 같은 도구 (2026-11-19) --%>
<title>대표자 일정</title>
<%-- 대표자 일정 (처음 이름 「대표이사 일정」 — 같은 날 사용자 「대표자 일정 으로 하고 별도 메뉴표시」. 주소·data-key·파일·표 이름은 ceoSched 그대로) (2026-11-19 신설 — 사용자 「직원일정 말고 대표이사 일정 등록하고 완료여부 체크, 편집기능도」 「총괄관리자만 보여지면 됨」)
     왼쪽 메뉴의 따로 선 묶음 「대표자 일정」(직원관리 묶음 밑, 처음엔 직원관리 서브메뉴였다). 셸 iframe(logiFrame 'ceoSched'). 총괄관리자(s_main_gu 1)만 — 메뉴·화면·서버 셋 다 같은 조건.

     화면 : 왼쪽 = 월 달력(날짜 칸에 일정 띠, 완료는 줄 긋고 흐리게) · 오른쪽 = 목록(「이 달」 / 「미완료」 / 「전체」 — 전체는 2026-11-19 추가, 최근 날짜가 위), 줄 앞 상태 칸 = 빈 칸(-) · 완료 · 일정취소(2026-11-19 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」 — 처음엔 완료 체크 하나였다. DB 칸은 DONE_YN 그대로 N·Y·C).
            날짜 칸의 빈 곳을 누르면 그 날짜로 새 일정, 띠·목록 줄을 누르면 그 일정을 연다(고치기·지우기).
     일정 한 건 : 일자(기간) · 시간(없어도 됨) · 제목 · 장소 · 완료 · 내용(편집기).
     편집기 : 가벼운 자체 편집기(contenteditable + execCommand) — 굵게·기울임·밑줄·취소선 · 글꼴 · 크기 · 글자색 · 형광펜 · 목록 · 정렬 · 서식 지우기.
              ★그림은 넣지 않는다(붙여 넣어도 빠진다) — 내용이 DB 한 칸(NVARCHAR(MAX))에 들어가므로. 붙여 넣은 글은 clean() 으로 걸러(허용 태그·속성만) 넣는다.
              서버(ceoClean)도 한 번 더 거른다.
     엑셀·인쇄 (2026-11-19) : 오른쪽 목록에 보이는 것 그대로(탭 + 검색). 내용은 그때 한 건씩 읽어 온다 — 아래 「엑셀 · 인쇄」 묶음.
     삭제 (2026-11-19) : 창의 [삭제] · 목록 줄 끝의 🗑. 완료한 일정은 일정취소로 바꾼 뒤에만 지운다 — 아래 delAsk.
     같은 시간 일정 (2026-11-19) : 날짜가 겹치고 시간이 같은 다른 일정이 있으면 창에 노란 띠 + 저장 때 「그래도 저장」 확인 — 아래 dupOf.
     자료 : /mangr/ceoSchedList.do(목록, 내용 없이) · ceoSchedGet.do(한 건, 내용 포함) · ceoSchedSave.do · ceoSchedDone.do(완료 체크만) · ceoSchedDel.do
            표 = TBL_CEO_SCHED (docs/sql/20261119_ceo_sched.sql) — 아직 없으면 서버가 noTable=Y 를 주고 화면 위에 안내 띠가 뜬다.
     ⚠JSP 라 스크립트 안에 달러+중괄호 · 샵+중괄호를 쓰지 않는다(EL 로 읽힌다) — 글 잇기는 + 로. --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#b23b3b; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; overflow:hidden; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:6px 11px 8px; height:100%; display:flex; flex-direction:column; min-height:0; }
  .hd{ display:flex; align-items:baseline; gap:10px; margin:2px 2px 6px; }
  .hd h2{ margin:0; font-size:19px; } .hd small{ color:#6b7a89; font-size:12.5px; }
  .bar{ display:flex; flex-wrap:wrap; align-items:center; gap:5px 8px; padding:6px 10px; background:#fff; border:1px solid var(--bd); border-radius:8px; margin-bottom:6px; }
  .bar .sp{ flex:1; }
  .bar .ym{ font-size:17px; font-weight:800; min-width:118px; text-align:center; font-variant-numeric:tabular-nums; }
  .bar .nav{ width:30px; height:30px; border:1px solid #cbd5e1; background:#fff; border-radius:5px; cursor:pointer; font-size:13px; color:#37475a; }
  .bar .nav:hover{ border-color:var(--teal); color:var(--teal); }
  .bar input[type=search]{ height:30px; width:200px; border:1px solid #cbd5e1; border-radius:5px; padding:0 8px; font-size:13px; font-family:inherit; }
  .bar .sum{ font-size:13px; color:#48606f; margin-left:6px; } .bar .sum b{ color:#0f6b5e; } .bar .sum b.late{ color:var(--red); }
  .btn{ height:30px; border:1px solid var(--teal); background:var(--teal); color:#fff; border-radius:5px; padding:0 14px; font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
  .btn.ghost{ background:#fff; color:var(--teal); }
  .btn.danger{ background:#fff; border-color:#d9a3a3; color:var(--red); }
  .btn.danger:hover{ background:var(--red); border-color:var(--red); color:#fff; }
  .warn{ padding:9px 12px; margin-bottom:6px; background:#fff6dc; border:1px solid #e9c46a; border-radius:8px; color:#7a5c00; font-size:13.5px; line-height:1.6; }
  .deny{ margin:60px auto; padding:26px 34px; background:#fff; border:1px solid var(--bd); border-radius:10px; font-size:15px; color:#48606f; text-align:center; }

  .main{ flex:1 1 0; min-height:0; display:flex; gap:8px; }
  /* 달력 */
  .calbox{ flex:1 1 0; min-width:0; background:#fff; border:1px solid var(--bd); border-radius:8px; overflow:hidden; display:flex; flex-direction:column; }
  .calhd{ display:grid; grid-template-columns:repeat(7,1fr); background:#d9edf7; border-bottom:1px solid #9fb6c3; flex:none; }
  .calhd div{ padding:3px 0; text-align:center; font-weight:700; font-size:13px; }
  .calhd div span{ display:inline-block; min-width:24px; height:24px; line-height:24px; border-radius:12px; padding:0 4px; }
  .calhd div.tdy span{ background:var(--teal); color:#fff; }   /* 오늘 요일 (2026-11-19 사용자 「헤더 해당요일표시」) — 오늘이 든 달을 볼 때만. 직원 휴가 관리 달력과 같은 표시 */
  .calhd div:first-child{ color:#c0392b; } .calhd div:last-child{ color:#2f4f9a; }
  .cal{ flex:1 1 0; min-height:0; display:grid; grid-template-columns:repeat(7,1fr); }
  .cal .dc{ border-right:1px solid #e3e8ee; border-bottom:1px solid #e3e8ee; padding:3px 4px 2px; min-width:0; min-height:0; overflow-y:auto; cursor:pointer; scrollbar-width:thin; }
  .cal .dc:nth-child(7n){ border-right:0; }
  .cal .dc:hover{ background:#f6fbfa; }
  .cal .dc.out{ background:#fafbfc; } .cal .dc.out .dn{ color:#b6c0ca; }
  .cal .dn{ display:inline-flex; align-items:center; justify-content:center; min-width:22px; height:22px; font-size:12.5px; font-weight:700; color:#37475a; border-radius:11px; padding:0 4px; }
  .cal .dc.sun .dn{ color:#c0392b; } .cal .dc.sat .dn{ color:#2f4f9a; }
  .cal .dc.tdy .dn{ background:var(--teal); color:#fff; }
  .cal .ev{ display:block; margin-top:2px; padding:1px 6px; border-radius:4px; background:#e3f2ee; border-left:3px solid var(--teal); color:#12453d; font-size:12px; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .cal .ev:hover{ background:#cfe9e2; }
  .cal .ev i{ font-style:normal; font-weight:800; color:#0f6b5e; margin-right:3px; font-variant-numeric:tabular-nums; }
  .cal .ev.late{ background:#fde8e8; border-left-color:var(--red); color:#7d2323; } .cal .ev.late i{ color:var(--red); }
  .cal .ev.done, .cal .ev.cancel{ background:#eef1f4; border-left-color:#aab5c0; color:#8794a1; text-decoration:line-through; font-weight:600; } .cal .ev.done i, .cal .ev.cancel i{ color:#8794a1; }
  /* 목록 */
  .side{ flex:0 0 clamp(340px,30%,460px); min-width:0; background:#fff; border:1px solid var(--bd); border-radius:8px; display:flex; flex-direction:column; overflow:hidden; }
  .tabs{ display:flex; gap:4px; padding:6px 8px 0; border-bottom:1px solid var(--bd); background:#f7faf9; flex:none; }
  .tab{ padding:6px 13px; border:1px solid var(--bd); border-bottom:0; border-radius:7px 7px 0 0; background:#eef2f5; font-size:13px; font-weight:700; color:#5a6b7a; cursor:pointer; user-select:none; }
  .tab.on{ background:#fff; color:#0f6b5e; position:relative; top:1px; }
  .tab b{ display:inline-block; min-width:18px; padding:0 5px; margin-left:3px; border-radius:9px; background:#c7d2dc; color:#fff; font-size:11.5px; text-align:center; }
  .tab b.late{ background:var(--red); }
  .list{ flex:1 1 0; min-height:0; overflow:auto; }
  .list .empty{ padding:34px 12px; text-align:center; color:#8794a1; font-size:13.5px; line-height:1.8; }
  .it{ display:flex; gap:9px; align-items:flex-start; padding:8px 11px; border-bottom:1px solid #eef1f5; cursor:pointer; }
  .it:hover{ background:#f1f9f7; }
  /* 줄 끝 삭제 단추 (2026-11-19 사용자 「일정 삭제기능도」) — 평소엔 흐리게, 줄에 마우스를 올리면 또렷하게 */
  .it .rowdel{ flex:none; width:28px; height:28px; padding:0; border:1px solid transparent; border-radius:6px; background:transparent; font-size:13px; cursor:pointer; opacity:.3; }
  .it:hover .rowdel{ opacity:.85; border-color:#e6caca; } .it .rowdel:hover{ opacity:1; background:#fde8e8; border-color:#d9a3a3; }
  /* 상태 칸 (2026-11-19 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」) — 종전 완료 체크 칸 자리. 빈 칸(-) · 완료 · 일정취소 중에 고른다 */
  .it select.st{ flex:none; width:84px; height:26px; margin-top:1px; padding:0 2px 0 8px; border:1px solid #cbd5e1; border-radius:13px; background:#fff; color:#5a6b7a; font-size:12px; font-weight:800; font-family:inherit; cursor:pointer; }
  .it select.st.stY{ background:#137a6c; border-color:#137a6c; color:#fff; } .it select.st.stC{ background:#eef1f4; border-color:#c3cad2; color:#8794a1; }
  .it select.st option{ background:#fff; color:#1f2a37; font-weight:600; }
  .it .tx{ flex:1; min-width:0; }
  .it .t1{ font-size:14px; font-weight:700; color:#1f2a37; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .it .t2{ margin-top:2px; font-size:12.5px; color:#5a6b7a; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .it .t2 b{ color:#0f6b5e; font-variant-numeric:tabular-nums; }
  .it.done .t1, .it.cancel .t1{ color:#8794a1; text-decoration:line-through; font-weight:600; } .it.done .t2, .it.done .t2 b, .it.cancel .t2, .it.cancel .t2 b{ color:#9aa7b3; }
  .tag{ display:inline-block; padding:0 7px; border-radius:9px; font-size:11.5px; font-weight:800; margin-left:5px; vertical-align:1px; }
  .tag.late{ background:#fde8e8; color:#a12b2b; } .tag.tdy{ background:#dff0eb; color:#0f6b5e; } .tag.ok{ background:#eef1f4; color:#5a6b7a; }
  .memo{ margin-left:4px; font-size:12px; opacity:.75; }

  /* 등록·수정 창 */
  .pop{ position:fixed; inset:0; background:rgba(15,23,32,.35); display:none; align-items:flex-start; justify-content:center; z-index:900; padding-top:4vh; }
  .pop.on{ display:flex; }
  .pop .box{ background:#fff; width:min(900px,96vw); max-height:92vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); display:flex; flex-direction:column; overflow:hidden; }
  .pop .ph{ display:flex; gap:10px; align-items:center; padding:10px 14px; border-bottom:1px solid #eef1f5; flex:none; }
  .pop .ph b{ font-size:15.5px; color:#125a4e; } .pop .ph .info{ flex:1; font-size:12px; color:#8794a1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .pop .pf{ display:flex; flex-wrap:wrap; gap:6px 8px; align-items:center; padding:7px 14px 0; flex:none; }
  .pop .pf label{ font-size:13px; font-weight:700; color:#48606f; min-width:34px; }
  .pop .pf input[type=text], .pop .pf input[type=date], .pop .pf input[type=time]{ height:32px; border:1px solid #cbd5e1; border-radius:6px; padding:0 8px; font-size:13.5px; font-family:inherit; }
  .pop .pf input.req{ border-color:#e9b98a; background:#fffaf4; }
  /* 창의 상태 고르기 — [완료][일정취소] 둘. 둘 다 안 눌린 것이 «아무것도 없음» (2026-11-19 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」) */
  .pop .pf .stg{ display:inline-flex; margin-left:8px; border:1px solid #cbd5e1; border-radius:16px; overflow:hidden; }
  .pop .pf .stg .sb{ min-width:0; display:inline-flex; align-items:center; height:30px; padding:0 14px; font-size:13px; font-weight:700; font-family:inherit; color:#5a6b7a; background:#fff; cursor:pointer; border:0; border-right:1px solid #e3e8ee; user-select:none; }
  .pop .pf .stg .sb:last-child{ border-right:0; } .pop .pf .stg .sb:hover{ background:#f6fbfa; }
  .pop .pf .stg .sb.on.vY{ background:#137a6c; color:#fff; } .pop .pf .stg .sb.on.vC{ background:#d9dee4; color:#5a6b7a; }
  .pop .dup{ margin:6px 14px 0; padding:5px 10px; border:1px solid #e9c46a; border-radius:6px; background:#fff6dc; color:#7a5c00; font-size:12.5px; line-height:1.55; flex:none; }   /* 같은 시간 일정 알림 (2026-11-19) */
  .pop .dup b{ color:#8a4a00; }
  /* 편집기 */
  .tb{ display:flex; flex-wrap:wrap; align-items:center; gap:3px; margin:9px 14px 0; padding:5px 6px; border:1px solid #cbd5e1; border-bottom:0; border-radius:7px 7px 0 0; background:#f3f6f8; flex:none; }
  .tb button{ min-width:28px; height:28px; padding:0 6px; border:1px solid #cfd8e3; border-radius:5px; background:#fff; font-size:13px; color:#1f2a37; cursor:pointer; font-family:inherit; }
  .tb button:hover{ border-color:var(--teal); color:var(--teal); }
  .tb button.on{ background:#dff0eb; border-color:var(--teal); color:#0f6b5e; }   /* 지금 켜져 있는 서식 (2026-11-19) */
  .tb select{ height:28px; border:1px solid #cfd8e3; border-radius:5px; background:#fff; font-size:12.5px; font-family:inherit; }
  .tb .sep{ width:1px; height:20px; background:#cfd8e3; margin:0 4px; }
  .tb .lb{ font-size:12px; color:#5a6b7a; font-weight:700; margin:0 2px 0 3px; }
  .tb .sw{ width:20px; min-width:20px; height:20px; padding:0; border-radius:4px; border:1px solid #b9c4d0; }
  .tb .sw.no{ background:#fff; color:#b23b3b; font-size:12px; line-height:16px; }
  .ed{ flex:1 1 auto; height:clamp(220px,44vh,460px); min-height:110px;   /* 창이 낮으면 편집 칸이 줄어 [저장] 줄이 늘 보인다 */ margin:0 14px; padding:10px 12px; border:1px solid #cbd5e1; border-radius:0 0 7px 7px; overflow:auto; font-size:14px; line-height:1.65; outline:none; background:#fff; word-break:break-word; }
  .ed:focus{ border-color:var(--teal); }
  .ed:empty:before{ content:attr(data-ph); color:#a3afbb; }
  .ed p{ margin:0 0 6px; } .ed ul, .ed ol{ margin:4px 0 6px; padding-left:24px; } .ed table{ border-collapse:collapse; } .ed td, .ed th{ border:1px solid #cbd5e1; padding:3px 6px; }
  .ed a{ color:#2f4f9a; }
  .pop .pb{ display:flex; gap:8px; align-items:center; padding:10px 14px; border-top:1px solid #dbe2ea; margin-top:9px; flex:none; }
  .pop .pb .sp{ flex:1; } .pop .pb .len{ font-size:12px; color:#8794a1; }
  .busy{ position:fixed; right:16px; bottom:14px; padding:7px 14px; background:#1f2a37; color:#fff; border-radius:16px; font-size:12.5px; display:none; z-index:950; }
  .busy.on{ display:block; }
  /* ── 인쇄 (2026-11-19 사용자 「엑셀출력 및 인쇄 넣어줘요」) — 화면(달력·단추·창)은 통째로 빼고 #printArea 의 제목 + 표만. A4 세로 ── */
  #printArea{ display:none; }
  @page{ size:A4 portrait; margin:10mm; }
  @media print{
    html, body{ height:auto !important; overflow:visible !important; background:#fff !important; }
    body > *:not(#printArea){ display:none !important; }
    #printArea{ display:block !important; color:#000; }
    #printArea .pt{ margin:0 0 7px; } #printArea .pt b{ font-size:17px; } #printArea .pt span{ font-size:11.5px; color:#333; margin-left:10px; }
    table.pl{ width:100%; border-collapse:collapse; table-layout:fixed; font-size:11px; }
    table.pl th{ background:#d9edf7 !important; border:1px solid #555; padding:3px 4px; font-weight:700; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    table.pl td{ border:1px solid #777; padding:3px 5px; vertical-align:top; word-break:break-word; line-height:1.45; }
    table.pl td.c{ text-align:center; } table.pl td.late{ color:#b23b3b; font-weight:700; }
    table.pl tr{ page-break-inside:avoid; } table.pl tr.dn td{ color:#555; }
    table.pl .pp{ font-size:10px; color:#555; font-weight:400; }
    table.pl td.ct p{ margin:0 0 3px; } table.pl td.ct ul, table.pl td.ct ol{ margin:2px 0; padding-left:18px; }
    table.pl td.ct table{ border-collapse:collapse; } table.pl td.ct td, table.pl td.ct th{ border:1px solid #999; padding:1px 4px; }
  }
</style>
</head>
<body>
<div class="wrap" id="wrap">
  <div class="hd"><h2>🗓 대표자 일정</h2><small>일정을 등록하고 끝난 일은 체크합니다 — 총괄관리자만 보입니다</small></div>
  <div class="bar">
    <button type="button" class="nav" onclick="monGo(-1)" title="앞 달">◀</button>
    <span class="ym" id="ymTxt"></span>
    <button type="button" class="nav" onclick="monGo(1)" title="다음 달">▶</button>
    <button type="button" class="btn ghost" onclick="monToday()">오늘</button>
    <span class="sum" id="sumTxt"></span>
    <span class="sp"></span>
    <input type="search" id="q" placeholder="🔎 제목 / 장소 검색" oninput="paintList()">
    <button type="button" class="btn ghost" onclick="xls()" title="오른쪽 목록에 보이는 일정(탭·검색 그대로)을 엑셀로 — 내용은 글자만">📥 엑셀</button>
    <button type="button" class="btn ghost" onclick="prt()" title="오른쪽 목록에 보이는 일정(탭·검색 그대로)을 인쇄 — A4 세로, 내용은 서식 그대로">🖨 인쇄</button>
    <button type="button" class="btn" onclick="edOpen(0)" title="새 일정을 등록합니다 — 달력의 날짜 칸을 눌러도 됩니다">＋ 일정 등록</button>
  </div>
  <div class="warn" id="noTable" style="display:none">⚠ 일정 표(<b>TBL_CEO_SCHED</b>)가 아직 없습니다 — <b>docs/sql/20261119_ceo_sched.sql</b> 을 운영 DB에서 한 번 실행한 뒤 이 화면을 새로고침해 주세요. (그 전에는 저장되지 않습니다)</div>
  <div class="main">
    <div class="calbox">
      <div class="calhd" id="calHd"><div><span>일</span></div><div><span>월</span></div><div><span>화</span></div><div><span>수</span></div><div><span>목</span></div><div><span>금</span></div><div><span>토</span></div></div>
      <div class="cal" id="cal"></div>
    </div>
    <div class="side">
      <div class="tabs">
        <span class="tab on" id="tabMon" onclick="tabGo('mon')" title="달력에 보이는 달의 일정">이 달 <b id="monCnt">0</b></span>
        <span class="tab" id="tabTodo" onclick="tabGo('todo')" title="달과 관계없이 아직 끝내지 않은 일정 전부(완료·일정취소 제외) — 빨간 숫자는 날짜가 지난 것이 있다는 표시">미완료 <b id="todoCnt">0</b></span>
        <span class="tab" id="tabAll" onclick="tabGo('all')" title="달·완료 여부와 관계없이 등록된 일정 전부 — 최근 날짜가 위">전체 <b id="allCnt">0</b></span>
      </div>
      <div class="list" id="list"></div>
    </div>
  </div>
</div>

<%-- 등록·수정 창 --%>
<div class="pop" id="pop">
  <div class="box">
    <div class="ph"><b id="popTit">일정 등록</b><span class="info" id="popInfo"></span><button type="button" class="btn ghost" onclick="edClose()">닫기 ✕</button></div>
    <div class="pf">
      <label>일자</label><input type="date" id="fFrom" class="req" onchange="edFromSet()"> <span style="color:#8794a1">~</span> <input type="date" id="fTo">
      <label style="margin-left:8px">시간</label><input type="time" id="fTm" title="비워 두면 종일 일정">
      <span class="stg" id="fSt" title="끝났으면 [완료], 없어진 일정이면 [일정취소] — 눌린 것을 한 번 더 누르면 풀립니다(아무것도 없음). 목록의 상태 칸으로도 바꿀 수 있습니다"><button type="button" class="sb vY" data-v="Y">완료</button><button type="button" class="sb vC" data-v="C">일정취소</button></span>
    </div>
    <div class="dup" id="dupHint" style="display:none"></div>
    <div class="pf">
      <label>제목</label><input type="text" id="fTitle" class="req" maxlength="200" style="flex:1; min-width:240px" placeholder="무슨 일정인지">
      <label style="margin-left:8px">장소</label><input type="text" id="fPlace" maxlength="100" style="width:230px" placeholder="(선택)">
    </div>
    <div class="tb" id="tb"></div>
    <div class="ed" id="ed" contenteditable="true" data-ph="내용을 적으세요 — 글을 고른 뒤 위 단추로 굵게·색·크기를 바꿉니다 (그림은 넣을 수 없습니다)"></div>
    <div class="pb">
      <button type="button" class="btn danger" id="btnDel" onclick="edDel()">🗑 삭제</button>
      <span class="sp"></span><span class="len" id="edLen"></span>
      <button type="button" class="btn ghost" onclick="edClose()">닫기</button>
      <button type="button" class="btn" onclick="edSave()" title="Ctrl+S">💾 저장</button>
    </div>
  </div>
</div>
<div id="printArea"></div>
<div class="busy" id="busy">⏳ 처리 중…</div>

<script>
var CTX='${pageContext.request.contextPath}', ADMIN=('${ceoAdmin}'==='Y');
var WK=['일','월','화','수','목','금','토'];
var _y=0, _m=0;            /* 보고 있는 달 (m = 0~11) */
var _rows=[], _todo=[];    /* 전체 일정(달력·「이 달」·「전체」가 여기서 고른다) · 그중 미완료 */
var _tab='mon', _seq=0, _dirty=false, _noTable=false;

function gel(id){ return document.getElementById(id); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function p2(v){ return (v<10?'0':'')+v; }
function ymd(d){ return ''+d.getFullYear()+p2(d.getMonth()+1)+p2(d.getDate()); }
function d10(s){ s=String(s||''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function d8(s){ return String(s||'').replace(/[^0-9]/g,'').slice(0,8); }
function toDate(s){ return new Date(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8)); }
function dTxt(s){ var d=toDate(s); return (d.getMonth()+1)+'/'+d.getDate()+'('+WK[d.getDay()]+')'; }
function today(){ return ymd(new Date()); }
function lTxt(v){ return ((_tab!=='mon' && v.slice(0,4)!==String(new Date().getFullYear())) ? v.slice(2,4)+'/' : '')+dTxt(v); }   /* 목록의 날짜 — 올해가 아니면 연도 두 자리 */
function dayGap(a,b){ return Math.round((toDate(b).getTime()-toDate(a).getTime())/86400000); }
function busy(on){ gel('busy').classList.toggle('on', !!on); }
function alertBox(m){ if(window._alertBox) _alertBox(m,{icon:'⚠️'}); else alert(String(m).replace(/<[^>]*>/g,'')); }
function toast(m,t){ if(window._toast) _toast(m,t||'ok'); }
function noTable(on){ _noTable=!!on; gel('noTable').style.display=on?'':'none'; }

/* 서버 호출 — 오류(error)는 던진다. 표가 없으면(noTable) 안내 띠를 켠다 */
function done(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json().then(function(j){
  if(j && j.noTable==='Y') noTable(true);
  if(!j || j.error) throw new Error((j&&j.error)||'처리하지 못했습니다'); return j; }); }
function postForm(url, o){ var b=[]; for(var k in o) b.push(encodeURIComponent(k)+'='+encodeURIComponent(o[k]==null?'':o[k]));
  return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:b.join('&') }).then(done); }
function postJson(url, o){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/json'}, body:JSON.stringify(o) }).then(done); }

/* ── 달 ── */
function gridRange(){ var f=new Date(_y,_m,1), l=new Date(_y,_m+1,0);
  var a=new Date(_y,_m,1-f.getDay()), b=new Date(_y,_m+1,0+(6-l.getDay())); return { a:a, b:b, weeks:Math.round((b.getTime()-a.getTime())/86400000+1)/7 }; }
function monGo(d){ var x=new Date(_y,_m+d,1); _y=x.getFullYear(); _m=x.getMonth(); load(); }
function monToday(){ var t=new Date(); _y=t.getFullYear(); _m=t.getMonth(); load(); }
function monOf(s){ var a=''+_y+p2(_m+1)+'01', b=ymd(new Date(_y,_m+1,0)); return s.toDt>=a && s.fromDt<=b; }   /* 이 달과 겹치는가 */

function load(){
  gel('ymTxt').textContent=_y+'년 '+(_m+1)+'월';
  if(!ADMIN) return;
  /* ★전부 한 번에 읽는다 (2026-11-19 「전체」 탭 추가) — 종전엔 달력 범위 + 미완료 두 번을 불렀다. 목록에는 내용(HTML)이 실려 오지 않아 줄이 많아도 가볍다.
       달력은 날짜로, 「이 달」은 monOf 로, 「미완료」는 완료 여부로 여기서 고른다 */
  busy(true);
  postForm('/mangr/ceoSchedList.do',{ frDt:'00000101', toDt:'99991231' })
    .then(function(r){ _rows=r.data||[]; _todo=_rows.filter(isOpen); noTable(false); busy(false); paint();
      try{ if(window.parent && window.parent!==window && typeof window.parent.konetCeoBadge==='function') window.parent.konetCeoBadge(); }catch(e){}   /* 메뉴 옆 «지난 미완료» 건수도 같이 (2026-11-19) */
    })
    .catch(function(e){ busy(false); _rows=[]; _todo=[]; paint(); if(!_noTable) alertBox(esc(e.message)); });
}
/* ★상태 셋 (2026-11-19 사용자 「완료, 일부완료, 일정취소로 구분해줘요」 → 곧바로 「완료 , 일정취소 만」) — DB 칸은 종전 DONE_YN(CHAR 1) 그대로 : N 미완료 · Y 완료 · C 일정취소.
   ★표시하는 상태는 「완료」「일정취소」 둘뿐이고 아무것도 안 고른 것(N)은 빈 칸이다(같은 날 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」) —
   「미완료」는 그 빈 것들을 탭·합계에서 묶어 부르는 이름으로만 남는다.
   아무것도 없는 것(isOpen)만 「미완료」 탭 · 지난 미완료 · 메뉴 옆 숫자에 든다. 완료 · 일정취소는 끝난 것 — 흐리게 줄 긋는다 */
var ST={ N:{ nm:'', ic:'☐' }, Y:{ nm:'완료', ic:'☑' }, C:{ nm:'일정취소', ic:'✕' } }, ST_KEYS=['N','Y','C'];   /* N = 아무것도 없음(표시 글 없음) */
function stKey(s){ return (s && ST[s.doneYn]) ? s.doneYn : 'N'; }
function isOpen(s){ return stKey(s)==='N'; }
function late(s){ return isOpen(s) && s.toDt<today(); }
function paint(){ paintCal(); paintList(); }
function paintCal(){
  var g=gridRange(), t=today(), h='', d=new Date(g.a.getTime());
  gel('cal').style.gridTemplateRows='repeat('+g.weeks+', minmax(0,1fr))';
  for(var i=0;i<g.weeks*7;i++){
    var k=ymd(d), dow=d.getDay(), out=(d.getMonth()!==_m);
    var ev=_rows.filter(function(s){ return s.fromDt<=k && s.toDt>=k; }).sort(function(a,b){ return (a.schedTm||'99')<(b.schedTm||'99')?-1:((a.schedTm||'99')>(b.schedTm||'99')?1:a.schedSeq-b.schedSeq); });
    h+='<div class="dc'+(out?' out':'')+(dow===0?' sun':'')+(dow===6?' sat':'')+(k===t?' tdy':'')+'" onclick="edOpen(0,\''+k+'\')" title="'+d10(k)+' — 빈 곳을 누르면 이 날짜로 새 일정">'
      +'<span class="dn">'+d.getDate()+'</span>'
      + ev.map(function(s){ var k=stKey(s), cls=(k==='Y'?' done':(k==='C'?' cancel':(late(s)?' late':'')));
          return '<span class="ev'+cls+'" onclick="edOpen('+s.schedSeq+',null,event)" title="'+esc((s.schedTm?s.schedTm+' ':'')+s.title+(s.place?' · '+s.place:'')+(k!=='N'?' ('+ST[k].nm+')':''))+'">'
          +(k==='Y'?'✓ ':(k==='C'?'✕ ':''))+(s.schedTm?'<i>'+esc(s.schedTm)+'</i>':'')+esc(s.title)+'</span>'; }).join('')
      +'</div>';
    d.setDate(d.getDate()+1);
  }
  gel('cal').innerHTML=h;
  /* 머리의 요일 — 오늘이 든 달을 보고 있으면 오늘 요일에 동그라미 */
  var now=new Date(), cur=(now.getFullYear()===_y && now.getMonth()===_m);
  [].forEach.call(gel('calHd').children, function(e, i){ e.classList.toggle('tdy', cur && i===now.getDay()); });
}
function tabGo(t){ _tab=t; paintList(); gel('list').scrollTop=0; }
function paintList(){
  var q=gel('q').value.trim().toLowerCase(), t=today();
  var mon=_rows.filter(monOf), nLate=_todo.filter(late).length, cnt={ N:0, Y:0, C:0 }; mon.forEach(function(s){ cnt[stKey(s)]++; });
  gel('tabMon').classList.toggle('on', _tab==='mon'); gel('tabTodo').classList.toggle('on', _tab==='todo'); gel('tabAll').classList.toggle('on', _tab==='all');
  gel('monCnt').textContent=mon.length; gel('todoCnt').textContent=_todo.length; gel('todoCnt').className=nLate?'late':''; gel('allCnt').textContent=_rows.length;
  gel('sumTxt').innerHTML='이 달 <b>'+mon.length+'</b>건 · 완료 <b>'+cnt.Y+'</b>'+(cnt.C?' · 일정취소 <b>'+cnt.C+'</b>':'')+' · 미완료 <b>'+cnt.N+'</b>'+(nLate?' &nbsp;|&nbsp; 지난 미완료 <b class="late">'+nLate+'</b>건':'');
  var list=curList();   /* 탭 + 검색 + 차례 — 엑셀·인쇄와 같은 목록 */
  if(!list.length){ gel('list').innerHTML='<div class="empty">'+(q?'검색에 맞는 일정이 없습니다.':(_tab==='todo'?'끝내지 않은 일정이 없습니다 👍':((_tab==='all'?'등록된 일정이 없습니다.':'이 달에 등록된 일정이 없습니다.')+'<br>달력의 날짜 칸을 누르거나 [＋ 일정 등록]을 누르세요.')))+'</div>'; return; }
  gel('list').innerHTML=list.map(function(s){
    var k=stKey(s), tag='';
    if(k==='Y' || k==='C') tag='<span class="tag ok" title="'+ST[k].nm+'(으)로 바꾼 때">'+ST[k].nm+(s.doneDttm?' '+esc(s.doneDttm.slice(5,16)):'')+'</span>';
    else if(s.toDt<t) tag='<span class="tag late">'+dayGap(s.toDt,t)+'일 지남</span>';
    else if(s.fromDt<=t) tag='<span class="tag tdy">오늘</span>';
    return '<div class="it'+(k==='Y'?' done':(k==='C'?' cancel':''))+'" onclick="edOpen('+s.schedSeq+')">'
      +'<select class="st st'+k+'" onclick="event.stopPropagation()" onchange="doneSet('+s.schedSeq+', this.value, event)" title="'+(k==='N'?'상태 없음 — 눌러서 완료 · 일정취소를 고릅니다':'상태 — 눌러서 바꿉니다( - 를 고르면 지워집니다)')+'">'
        +ST_KEYS.map(function(x){ return '<option value="'+x+'"'+(x===k?' selected':'')+'>'+(ST[x].nm||'-')+'</option>'; }).join('')+'</select>'
      +'<div class="tx"><div class="t1" title="'+esc(s.title)+'">'+esc(s.title)+(s.hasContent==='Y'?'<span class="memo" title="내용이 있습니다">📝</span>':'')+'</div>'
      +'<div class="t2"><b>'+lTxt(s.fromDt)+(s.toDt!==s.fromDt?' ~ '+lTxt(s.toDt):'')+'</b>'+(s.schedTm?' '+esc(s.schedTm):'')+(s.place?' · '+esc(s.place):'')+tag+'</div></div>'
      +'<button type="button" class="rowdel" onclick="rowDel('+s.schedSeq+', event)" title="'+(k==='Y'?'완료한 일정 — 누르면 일정취소로 바꾸고 지웁니다(한 번 묻습니다)':'이 일정을 지웁니다')+'">🗑</button></div>';
  }).join('');
}
/* ══ 엑셀 · 인쇄 (2026-11-19 사용자 「엑셀출력 및 인쇄 넣어줘요」) ══
     범위 = 오른쪽 목록에 지금 보이는 것 그대로(탭 「이 달」/「미완료」/「전체」 + 검색). 화면·엑셀·인쇄가 curList() 하나를 쓴다.
     내용(편집기 글)은 목록에 실려 오지 않으므로 내보낼 때 내용 있는 일정만 한 건씩 읽어 온다(gather, 6건씩 묶어서).
     엑셀 : 재고내용분석·매출 반품내역과 같은 서식(굴림 9 · 제목 17 굵게 병합 · 조건 줄 · 머리글 하늘 D9EDF7 · 테두리). 날짜는 날짜 값으로.
            내용은 서식을 떼고 글자만(줄바꿈·목록 기호는 살린다) — 엑셀 칸 하나에 들어가야 해서. 줄 높이는 내용 줄 수에 맞춘다.
     인쇄 : 제목 + 표(일자·시간·제목/장소·완료·내용). 내용은 서식 그대로. A4 세로, 화면의 달력·단추는 빼고 표만 */
function curList(){
  var q=gel('q').value.trim().toLowerCase(), list=(_tab==='mon' ? _rows.filter(monOf) : (_tab==='all' ? _rows : _todo)).slice();
  if(q) list=list.filter(function(s){ return (s.title+' '+s.place).toLowerCase().indexOf(q)>=0; });
  list.sort(function(a,b){ return a.fromDt<b.fromDt?-1:(a.fromDt>b.fromDt?1:((a.schedTm||'99')<(b.schedTm||'99')?-1:((a.schedTm||'99')>(b.schedTm||'99')?1:a.schedSeq-b.schedSeq))); });
  if(_tab==='all') list.reverse();   /* 「전체」는 최근 날짜가 위 (2026-11-19) */
  return list;
}
function scopeNm(){ return _tab==='mon' ? (_y+'년 '+(_m+1)+'월') : (_tab==='all' ? '전체' : '미완료'); }
function stOf(s, t){ var k=stKey(s); if(k==='Y' || k==='C') return { k:k, txt:ST[k].nm, late:false };
  if(s.toDt<t) return { k:k, txt:dayGap(s.toDt,t)+'일 지남', late:true }; return { k:k, txt:ST[k].nm, late:false }; }
/* 내용 있는 일정의 내용을 읽어 { 번호: 걸러 낸 HTML } 로 */
function gather(list){
  var need=list.filter(function(s){ return s.hasContent==='Y'; }), map={}, i=0;
  function next(){ if(i>=need.length) return Promise.resolve(map);
    var part=need.slice(i, i+6); i+=6;
    return Promise.all(part.map(function(s){ return postForm('/mangr/ceoSchedGet.do',{ schedSeq:s.schedSeq }).then(function(j){ map[s.schedSeq]=clean((j.data && j.data.content) || ''); }); })).then(next); }
  return next();
}
/* 서식 있는 글 → 글자만. 문단·목록·표 줄은 줄바꿈으로, 목록은 • / 1. 을 앞에 붙인다 */
function htmlText(html){
  if(!html) return '';
  var doc=new DOMParser().parseFromString('<body>'+html+'</body>','text/html'), out='';
  (function walk(n){ [].slice.call(n.childNodes).forEach(function(c){
    if(c.nodeType===3){ out+=String(c.nodeValue).replace(/ /g,' '); return; }
    if(c.nodeType!==1) return;
    var t=c.tagName;
    if(t==='BR'){ out+='\n'; return; }
    var blk=/^(P|DIV|LI|H1|H2|H3|H4|BLOCKQUOTE|TR|PRE|UL|OL|TABLE|HR)$/.test(t);
    if(blk && out && !/\n$/.test(out)) out+='\n';
    if(t==='LI') out+=((c.parentNode && c.parentNode.tagName==='OL') ? (([].indexOf.call(c.parentNode.children, c)+1)+'. ') : '• ');
    walk(c);
    if(t==='TD' || t==='TH') out+='\t';
    if(blk && !/\n$/.test(out)) out+='\n';
  }); })(doc.body);
  return out.replace(/[ \t]+\n/g,'\n').replace(/\n{3,}/g,'\n\n').replace(/^\n+|\s+$/g,'');
}
function E(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; }
function wch(v){ var w=0; String(v==null?'':v).split('').forEach(function(ch){ w+=(ch.charCodeAt(0)>255?1.8:1); }); return w; }
function dser(v){ var d=d10(v); if(!d) return ''; var q=d.split('-'); return (Date.UTC(+q[0],+q[1]-1,+q[2])-Date.UTC(1899,11,30))/86400000; }
/* 표 하나 → 시트. o = { widths:[칸 너비], date:[날짜 칸], left:[왼쪽 맞춤 칸], red:function(줄) → 빨강 칸들, dim:function(줄) → 흐리게(완료) } */
function sheetOf(title, cond, head, body, o){
  var N=head.length, bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var aoa=[ [title].concat(E(N-1)), E(N), [cond].concat(E(N-1)), head ], kinds=['t','t','p','h'];
  body.forEach(function(r){ aoa.push(r); kinds.push('row'); });
  var ws=XLSX.utils.aoa_to_sheet(aoa), H=[];
  for(var r=0;r<aoa.length;r++){ var k=kinds[r], reds=(k==='row' && o.red) ? o.red(aoa[r]) : [], dim=(k==='row' && o.dim) ? o.dim(aoa[r]) : false, lines=1;
    for(var c=0;c<N;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'굴림', sz:17, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else {
        st.border=box; st.fill={ fgColor:{ rgb:'FFFFFF' } };
        st.alignment.horizontal=((o.left||[]).indexOf(c)>=0 ? 'left' : 'center');
        if((o.date||[]).indexOf(c)>=0 && ws[ref].t==='n') ws[ref].z='yyyy-mm-dd';
        if(dim) st.font.color={ rgb:'808080' };
        if(reds.indexOf(c)>=0){ st.font.color={ rgb:'C0392B' }; st.font.bold=true; }
        if(typeof aoa[r][c]==='string' && aoa[r][c]){ var n=0, per=Math.max(4, (o.widths[c]||10)-1); aoa[r][c].split('\n').forEach(function(ln){ n+=Math.max(1, Math.ceil(wch(ln)/per)); }); if(n>lines) lines=n; }
      }
      ws[ref].s=st; }
    H.push({ hpt:(r<2 ? 18.75 : (k==='row' ? Math.min(409, Math.max(16.5, lines*12.75+3)) : 16.5)) }); }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:N-1 } }, { s:{ r:2, c:0 }, e:{ r:2, c:N-1 } } ];
  ws['!cols']=o.widths.map(function(w){ return { wch:w }; });
  ws['!rows']=H;
  return ws;
}
function sumTxt(list, t){ var c={ N:0, Y:0, C:0 }, nLate=0, q=gel('q').value.trim(); list.forEach(function(s){ c[stKey(s)]++; if(isOpen(s) && s.toDt<t) nLate++; });
  return list.length+'건 · 완료 '+c.Y+(c.C?' · 일정취소 '+c.C:'')+' · 미완료 '+c.N+(nLate?' (지남 '+nLate+')':'')+(q?' · 검색 「'+q+'」':''); }
function xls(){
  if(!ADMIN) return;
  if(!window.XLSX || !XLSX.utils){ alertBox('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  var list=curList(); if(!list.length){ alertBox('내보낼 일정이 없습니다.'); return; }
  busy(true);
  gather(list).then(function(map){
    busy(false);
    var t=today();
    var head=['No','시작일','종료일','요일','시간','제목','장소','상태','처리 일시','내용'];
    var body=list.map(function(s, i){ var st=stOf(s,t), txt=htmlText(map[s.schedSeq]||''); if(txt.length>32000) txt=txt.slice(0,32000)+'\n…(이하 생략)';
      return [i+1, dser(s.fromDt), (s.toDt!==s.fromDt ? dser(s.toDt) : ''), WK[toDate(s.fromDt).getDay()], s.schedTm||'', s.title||'', s.place||'', st.txt, (s.doneDttm||'').slice(0,16), txt]; });
    var ws=sheetOf('[대표자 일정 — '+scopeNm()+']', scopeNm()+'   ('+sumTxt(list,t)+' · 출력 '+d10(t)+')', head, body,
      { widths:[5,11,11,5,7,34,18,12,16,70], date:[1,2], left:[5,6,9],
        red:function(a){ return /지남/.test(String(a[7])) ? [7] : []; }, dim:function(a){ return a[7]==='완료' || a[7]==='일정취소'; } });
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '대표자 일정');
    XLSX.writeFile(wb, '대표자일정_'+(_tab==='mon' ? (_y+'-'+p2(_m+1)) : (_tab==='all' ? '전체' : '미완료'))+'_'+t+'.xlsx');
    toast('📥 '+list.length+'건을 엑셀로 저장했습니다');
  }).catch(function(e){ busy(false); alertBox(esc(e.message)); });
}
function prt(){
  if(!ADMIN) return;
  var list=curList(); if(!list.length){ alertBox('인쇄할 일정이 없습니다.'); return; }
  busy(true);
  gather(list).then(function(map){
    busy(false);
    var t=today();
    function pd(v){ return d10(v).slice(2)+'('+WK[toDate(v).getDay()]+')'; }
    gel('printArea').innerHTML='<div class="pt"><b>[대표자 일정 — '+esc(scopeNm())+']</b><span>'+esc(sumTxt(list,t))+' · 출력 '+d10(t)+'</span></div>'
      +'<table class="pl"><thead><tr><th style="width:26px">No</th><th style="width:100px">일자</th><th style="width:40px">시간</th><th style="width:25%">제목 / 장소</th><th style="width:76px">상태</th><th>내용</th></tr></thead><tbody>'
      + list.map(function(s, i){ var st=stOf(s,t);
          return '<tr'+((st.k==='Y'||st.k==='C')?' class="dn"':'')+'><td class="c">'+(i+1)+'</td>'
            +'<td class="c" style="white-space:nowrap">'+pd(s.fromDt)+(s.toDt!==s.fromDt ? '<br>~ '+pd(s.toDt) : '')+'</td><td class="c">'+esc(s.schedTm||'')+'</td>'
            +'<td><b>'+esc(s.title)+'</b>'+(s.place ? '<div class="pp">'+esc(s.place)+'</div>' : '')+'</td>'
            +'<td class="c'+(st.late?' late':'')+'">'+ST[st.k].ic+' '+esc(st.txt)+((st.k!=='N' && s.doneDttm) ? '<div class="pp">'+esc(s.doneDttm.slice(5,16))+'</div>' : '')+'</td>'
            +'<td class="ct">'+(map[s.schedSeq]||'')+'</td></tr>'; }).join('')
      +'</tbody></table>';
    setTimeout(function(){ window.print(); }, 60);
  }).catch(function(e){ busy(false); alertBox(esc(e.message)); });
}

/* 목록의 상태 칸 — 상태만 바꾼다(창을 열지 않는다). v = N 미완료 · Y 완료 · C 일정취소 */
function doneSet(seq, v, ev){
  if(ev) ev.stopPropagation();
  if(!ST[v]) v='N';
  postForm('/mangr/ceoSchedDone.do',{ schedSeq:seq, doneYn:v })
    .then(function(){ toast(v==='N' ? '상태를 지웠습니다' : ((v==='Y'?'✅ ':'')+'「'+ST[v].nm+'」(으)로 바꿨습니다')); load(); })
    .catch(function(e){ alertBox(esc(e.message)); load(); });
}
/* 창의 상태 고르기 */
function stGet(){ var b=document.querySelector('#fSt .sb.on'), v=b ? b.getAttribute('data-v') : 'N'; return ST[v] ? v : 'N'; }
function stSet(v){ if(!ST[v]) v='N'; [].forEach.call(document.querySelectorAll('#fSt .sb'), function(b){ b.classList.toggle('on', b.getAttribute('data-v')===v); }); }

/* ══ 편집기 ══ */
var ED=null, _rng=null;
var FONTS=['맑은 고딕','굴림','돋움','바탕','궁서'], SIZES=[11,12,13,14,16,18,22,28];
var COLORS=['#1f2a37','#c0392b','#b45309','#137a6c','#2f4f9a','#6b4fa0','#8794a1'], HILITE=['#fff3a3','#d9f2c4','#d6ebff','#ffd9e0'];
function tbBuild(){
  function b(cmd, html, tip){ return '<button type="button" data-c="'+cmd+'" title="'+tip+'">'+html+'</button>'; }
  gel('tb').innerHTML=
     b('bold','<b>B</b>','굵게 (Ctrl+B)')+b('italic','<i>I</i>','기울임 (Ctrl+I)')+b('underline','<u>U</u>','밑줄 (Ctrl+U)')+b('strikeThrough','<s>S</s>','취소선')
    +'<span class="sep"></span>'
    +'<select id="tbFont" title="글꼴" onchange="edFont(this.value); this.value=\'\'"><option value="">글꼴</option>'+FONTS.map(function(f){ return '<option value="'+f+'" style="font-family:\''+f+'\'">'+f+'</option>'; }).join('')+'</select>'
    +'<select id="tbSize" title="글자 크기" onchange="edSize(this.value); this.value=\'\'"><option value="">크기</option>'+SIZES.map(function(s){ return '<option value="'+s+'">'+s+'</option>'; }).join('')+'</select>'
    +'<span class="sep"></span><span class="lb">글자색</span>'
    + COLORS.map(function(c){ return '<button type="button" class="sw" data-c="foreColor" data-v="'+c+'" style="background:'+c+'" title="글자색"></button>'; }).join('')
    +'<span class="sep"></span><span class="lb">형광펜</span>'
    + HILITE.map(function(c){ return '<button type="button" class="sw" data-c="hiliteColor" data-v="'+c+'" style="background:'+c+'" title="형광펜"></button>'; }).join('')
    +'<button type="button" class="sw no" data-c="hiliteColor" data-v="transparent" title="형광펜 지우기">✕</button>'
    +'<span class="sep"></span>'
    + b('insertUnorderedList','• 목록','글머리 기호')+b('insertOrderedList','1. 목록','번호 매기기')
    + b('justifyLeft','왼쪽','왼쪽 맞춤')+b('justifyCenter','가운데','가운데 맞춤')+b('justifyRight','오른쪽','오른쪽 맞춤')
    +'<span class="sep"></span>'
    + b('removeFormat','🧹 서식 지우기','고른 글의 굵기·색·크기를 지웁니다')+b('undo','↶','되돌리기 (Ctrl+Z)')+b('redo','↷','다시 (Ctrl+Y)');
  /* 단추를 눌러도 글 고른 것이 풀리지 않게 — mousedown 을 막고 click 에서 실행 */
  gel('tb').addEventListener('mousedown', function(e){ if(e.target.closest('button')) e.preventDefault(); });
  gel('tb').addEventListener('click', function(e){ var x=e.target.closest('button[data-c]'); if(!x) return; edCmd(x.getAttribute('data-c'), x.getAttribute('data-v')); });
}
function edKeep(){ var s=window.getSelection(); if(s && s.rangeCount && ED.contains(s.anchorNode)) _rng=s.getRangeAt(0).cloneRange(); }
/* ★이미 편집 칸 안에 커서가 있으면 건드리지 않는다 (2026-11-19) — 고른 범위를 다시 넣으면, 글자를 고르지 않고 누른 굵게·밑줄(«다음 글자 서식»)이 풀려
   [굵게][밑줄][색]을 차례로 눌러도 마지막 것만 먹었다. 글꼴·크기 고르기처럼 초점이 편집 칸을 떠났을 때만 되돌린다 */
function edBack(){ var s=window.getSelection();
  if(document.activeElement===ED && s && s.rangeCount && ED.contains(s.anchorNode)) return;
  ED.focus(); if(_rng){ s=window.getSelection(); s.removeAllRanges(); s.addRange(_rng); } }
/* ★빈 줄에는 밑줄·취소선·형광펜을 남기지 않는다 (2026-11-19 사용자 「키보드 이동인데 표시됨」) —
   밑줄 친 줄 끝에서 Enter 를 치면 브라우저가 그 서식을 새 줄로 그대로 물려줘, 아무것도 안 쓴 줄에 밑줄 토막이 보였다.
   커서가 놓인 줄이 비어 있으면(글자 없음) 그 줄의 «빈 곳에도 그려지는» 서식 셋만 뗀다. 굵기·색·크기는 여느 편집기처럼 이어진다.
   글이 있는 줄은 건드리지 않는다. 다시 밑줄을 쓰려면 [U] 를 누르면 된다 */
function edLineTidy(){
  var s=window.getSelection(); if(!s || !s.rangeCount || !s.isCollapsed) return;
  var n=s.anchorNode; if(!n || !ED.contains(n) || n===ED) return;
  var blk=(n.nodeType===1 ? n : n.parentNode);
  while(blk && blk!==ED && !/^(DIV|P|LI|H1|H2|H3|H4|BLOCKQUOTE|TD|TH|PRE)$/.test(blk.tagName)) blk=blk.parentNode;
  if(!blk || blk===ED) return;
  if((blk.textContent||'').replace(/[\s ​]/g,'')!=='') return;
  [].slice.call(blk.querySelectorAll('span,font,u,s,strike,b,i,em,strong')).forEach(function(e){
    var tag=e.tagName;
    if(tag==='U' || tag==='S' || tag==='STRIKE') e.style.textDecorationLine='none';
    else if(e.style){ e.style.removeProperty('text-decoration'); e.style.removeProperty('text-decoration-line'); e.style.removeProperty('background-color'); }
  });
}
/* 굵게·기울임·밑줄·취소선 단추 — 지금 커서 자리에 그 서식이 켜져 있으면 눌린 모양으로 */
function edState(){ if(!ED) return; var s=window.getSelection(), inEd=!!(s && s.rangeCount && ED.contains(s.anchorNode));
  ['bold','italic','underline','strikeThrough'].forEach(function(c){ var b=gel('tb').querySelector('button[data-c="'+c+'"]'); if(!b) return; var on=false; try{ on=inEd && document.queryCommandState(c); }catch(e){} b.classList.toggle('on', !!on); }); }
function edCmd(cmd, val){
  edBack();
  try{ document.execCommand('styleWithCSS', false, true); }catch(e){}
  var ok=false; try{ ok=document.execCommand(cmd, false, val==null?null:val); }catch(e){}
  if(!ok && cmd==='hiliteColor'){ try{ document.execCommand('backColor', false, val); }catch(e){} }
  edKeep(); edTouched();
}
function edFont(f){ if(f) edCmd('fontName', f); }
/* 글자 크기 — execCommand 는 1~7 단계만 안다. 7로 찍어 표식을 만든 뒤 그 자리를 px 로 바꾼다 */
function edSize(px){
  if(!px) return; edBack();
  try{ document.execCommand('styleWithCSS', false, false); document.execCommand('fontSize', false, '7'); }catch(e){}
  [].slice.call(ED.querySelectorAll('font[size="7"]')).forEach(function(f){ var s=document.createElement('span'); s.style.fontSize=px+'px'; while(f.firstChild) s.appendChild(f.firstChild); f.parentNode.replaceChild(s, f); });
  try{ document.execCommand('styleWithCSS', false, true); }catch(e){}
  _rng=null; edTouched();
}
function edTouched(){ _dirty=true; var n=(ED.textContent||'').length; gel('edLen').textContent=n?('내용 '+n.toLocaleString()+'자'):''; }

/* ★걸러 내기 — 허용한 태그·속성만 남긴다. 붙여 넣을 때 · 저장 전 · 불러와 보여 줄 때 모두 이 함수를 지난다.
     버리는 것(안의 글까지) : 스크립트·스타일·그림·틀·입력 칸 … / 풀어 놓는 것(안의 글은 남김) : 그 밖의 모르는 태그 /
     속성 : style(글 모양에 쓰는 몇 가지만) · a 의 href(http·https·mailto) · 표 칸의 colspan·rowspan 만 */
var OKTAG={P:1,DIV:1,BR:1,SPAN:1,B:1,STRONG:1,I:1,EM:1,U:1,S:1,STRIKE:1,FONT:1,UL:1,OL:1,LI:1,H1:1,H2:1,H3:1,H4:1,BLOCKQUOTE:1,A:1,TABLE:1,THEAD:1,TBODY:1,TR:1,TD:1,TH:1,HR:1,SUB:1,SUP:1,PRE:1};
var DROP={SCRIPT:1,STYLE:1,IFRAME:1,OBJECT:1,EMBED:1,IMG:1,SVG:1,MATH:1,LINK:1,META:1,FORM:1,INPUT:1,BUTTON:1,TEXTAREA:1,SELECT:1,VIDEO:1,AUDIO:1,CANVAS:1,HEAD:1,TITLE:1,BASE:1,NOSCRIPT:1,TEMPLATE:1,PICTURE:1,SOURCE:1};
var OKCSS=['color','background-color','font-size','font-family','font-weight','font-style','text-decoration-line','text-align','vertical-align','border','border-collapse','padding','width','margin-left'];
function clean(html){
  var doc=new DOMParser().parseFromString('<body>'+String(html==null?'':html)+'</body>','text/html');
  (function walk(node){
    [].slice.call(node.childNodes).forEach(function(c){
      if(c.nodeType===3) return;
      if(c.nodeType!==1){ node.removeChild(c); return; }
      var tag=String(c.tagName||'').toUpperCase();
      if(DROP[tag]){ node.removeChild(c); return; }
      walk(c);
      if(!OKTAG[tag]){ while(c.firstChild) node.insertBefore(c.firstChild, c); node.removeChild(c); return; }
      var css=[], st=c.style;
      if(st) OKCSS.forEach(function(p){ var v=st.getPropertyValue(p); if(v && !/url\(|expression|javascript:|@import/i.test(v) && !/^(initial|inherit|unset)$/i.test(v)) css.push(p+':'+v); });
      var href=c.getAttribute('href'), cs=c.getAttribute('colspan'), rs=c.getAttribute('rowspan'), face=c.getAttribute('face'), col=c.getAttribute('color');
      [].slice.call(c.attributes).forEach(function(a){ c.removeAttribute(a.name); });
      if(tag==='FONT'){ if(face && /^[0-9A-Za-z가-힣 ,'_-]+$/.test(face)) css.push('font-family:'+face); if(col && /^#?[0-9A-Za-z]+$/.test(col)) css.push('color:'+col); }
      if(css.length) c.setAttribute('style', css.join(';'));
      if(tag==='A' && href && /^(https?:|mailto:)/i.test(href.trim())){ c.setAttribute('href', href.trim()); c.setAttribute('target','_blank'); c.setAttribute('rel','noopener noreferrer'); }
      if(tag==='TD'||tag==='TH'){ if(/^[0-9]{1,3}$/.test(cs||'')) c.setAttribute('colspan', cs); if(/^[0-9]{1,3}$/.test(rs||'')) c.setAttribute('rowspan', rs); }
    });
  })(doc.body);
  return doc.body.innerHTML;
}
function edInit(){
  ED=gel('ed'); tbBuild();
  ED.addEventListener('input', function(e){ if(e && (e.inputType==='insertParagraph' || e.inputType==='insertLineBreak')) edLineTidy(); edTouched(); });
  ED.addEventListener('keyup', function(e){ if(/^(Enter|ArrowUp|ArrowDown|ArrowLeft|ArrowRight|Home|End|PageUp|PageDown)$/.test(e.key)) edLineTidy(); });
  ED.addEventListener('mouseup', function(){ setTimeout(edLineTidy, 0); });
  document.addEventListener('selectionchange', function(){ edKeep(); edState(); });
  /* 붙여넣기 — 서식 있는 글은 걸러서, 그 밖은 글자만. 그림은 빠진다 */
  ED.addEventListener('paste', function(e){
    var cd=e.clipboardData; if(!cd) return;
    e.preventDefault();
    var html=cd.getData('text/html'), txt=cd.getData('text/plain');
    var had=/<img\b/i.test(html||'') || (cd.files && cd.files.length>0 && !html && !txt);
    if(html) document.execCommand('insertHTML', false, clean(html));
    else if(txt) document.execCommand('insertText', false, txt);
    if(had) toast('그림은 넣을 수 없어 글만 붙였습니다','warn');
    edTouched();
  });
  ED.addEventListener('drop', function(e){ if(e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length){ e.preventDefault(); toast('그림·파일은 넣을 수 없습니다','warn'); } });
  gel('fSt').addEventListener('click', function(e){ var b=e.target.closest('.sb'); if(!b) return; var v=b.getAttribute('data-v'); stSet(stGet()===v ? 'N' : v); _dirty=true; dupPaint(); });   /* 눌린 것을 또 누르면 풀린다 */
  ['fFrom','fTo','fTm'].forEach(function(id){ gel(id).addEventListener('input', dupPaint); gel(id).addEventListener('change', function(){ setTimeout(dupPaint, 0); }); });   /* 같은 시간 일정 알림 — 시작일을 바꾸면 끝나는 날도 따라 바뀐 뒤에 본다 */
  ['fFrom','fTo','fTm','fTitle','fPlace'].forEach(function(id){ gel(id).addEventListener('input', function(){ _dirty=true; }); gel(id).addEventListener('change', function(){ _dirty=true; }); });
  document.addEventListener('keydown', function(e){
    if(!gel('pop').classList.contains('on')) return;
    if((e.ctrlKey||e.metaKey) && (e.key==='s'||e.key==='S')){ e.preventDefault(); edSave(); }
    else if(e.key==='Escape' && !e.isComposing) edClose();
  });
}
function edFromSet(){ var a=gel('fFrom').value, b=gel('fTo').value; if(a && (!b || b<a)) gel('fTo').value=a; }
function edFill(s){
  _seq=s.schedSeq||0;
  gel('popTit').textContent=_seq?'일정 수정':'일정 등록';
  gel('popInfo').textContent=_seq?(('등록 '+(s.regDttm||'').slice(0,16)+(s.regUser?' '+s.regUser:''))+(s.updDttm?' · 수정 '+s.updDttm.slice(0,16)+(s.updUser?' '+s.updUser:''):'')+((stKey(s)!=='N' && s.doneDttm)?' · '+ST[stKey(s)].nm+' '+s.doneDttm.slice(0,16):'')):'';
  gel('fFrom').value=d10(s.fromDt); gel('fTo').value=d10(s.toDt||s.fromDt); gel('fTm').value=s.schedTm||'';
  gel('fTitle').value=s.title||''; gel('fPlace').value=s.place||''; stSet(stKey(s));
  ED.innerHTML=clean(s.content||''); _rng=null;
  gel('btnDel').style.display=_seq?'':'none';
  edTouched(); _dirty=false; dupPaint();
  gel('pop').classList.add('on');
  setTimeout(function(){ try{ (_seq?ED:gel('fTitle')).focus(); }catch(e){} }, 30);
}
/* 열기 — seq 0 = 새 일정(dt 가 있으면 그 날짜로, 없으면 오늘이 보이는 달이면 오늘·아니면 그 달 1일) */
function edOpen(seq, dt, ev){
  if(ev) ev.stopPropagation();
  if(!ADMIN) return;
  if(!seq){ var t=today(), d=dt || ((+t.slice(0,4)===_y && +t.slice(4,6)-1===_m) ? t : (''+_y+p2(_m+1)+'01'));
    edFill({ schedSeq:0, fromDt:d, toDt:d, schedTm:'', title:'', place:'', content:'', doneYn:'N' }); return; }
  busy(true);
  postForm('/mangr/ceoSchedGet.do',{ schedSeq:seq }).then(function(j){ busy(false); edFill(j.data); })
    .catch(function(e){ busy(false); alertBox(esc(e.message)); });
}
function edClose(force){
  if(!force && _dirty && window._confirmBox){ _confirmBox({ msg:'고친 내용을 저장하지 않고 닫을까요?', icon:'📝', okText:'저장 안 하고 닫기', onOk:function(){ edClose(true); }, onCancel:function(){} }); return; }
  gel('pop').classList.remove('on'); _dirty=false;
}
/* ★같은 시간 일정 (2026-11-19 사용자 「시간 중복있을경우 메세지처리」) —
   겹침 = 날짜(기간)가 겹치고 «시간이 같은» 다른 일정. 일정에는 끝나는 시간이 없어 시작 시간이 같은 것만 겹침으로 본다.
     · 시간을 비운 종일 일정은 따지지 않는다(시간이 없으니 겹칠 것이 없다)
     · 일정취소한 것은 상대로 치지 않고, 지금 일정을 일정취소로 저장할 때도 묻지 않는다
     · 고치는 중인 그 일정 자신은 뺀다
   알리는 곳 둘 : ① 창에서 일자·시간을 고르는 즉시 그 밑에 노란 띠(dupPaint) ② [저장]을 누르면 「그래도 저장」을 한 번 묻는다 — 막지는 않는다(일부러 겹쳐 잡는 일도 있다).
   목록(_rows)은 화면이 읽어 둔 전체 일정이라 서버에 다시 묻지 않는다 */
function dupOf(from, to, tm, st){
  if(!tm || st==='C' || from.length!==8) return [];
  return _rows.filter(function(x){ return x.schedSeq!==_seq && stKey(x)!=='C' && x.schedTm===tm && x.toDt>=from && x.fromDt<=to; });
}
function dupLine(x){ return '<b>'+dTxt(x.fromDt)+(x.toDt!==x.fromDt?' ~ '+dTxt(x.toDt):'')+' '+esc(x.schedTm)+'</b> '+esc(x.title)+(x.place?' · '+esc(x.place):'')+(stKey(x)==='Y'?' (완료)':''); }
function dupPaint(){
  var from=d8(gel('fFrom').value), to=d8(gel('fTo').value)||from, d=dupOf(from, to, gel('fTm').value||'', stGet()), el=gel('dupHint');
  if(!d.length){ el.style.display='none'; el.innerHTML=''; return; }
  el.innerHTML='⚠ 같은 시간에 이미 일정이 있습니다 — '+d.slice(0,3).map(dupLine).join(' / ')+(d.length>3?' 외 '+(d.length-3)+'건':'');
  el.style.display='';
}
function edSave(){
  var from=d8(gel('fFrom').value), to=d8(gel('fTo').value)||from, title=gel('fTitle').value.trim();
  if(from.length!==8){ alertBox('일자를 넣으세요.'); return; }
  if(to<from){ alertBox('끝나는 날이 시작하는 날보다 앞섭니다.'); return; }
  if(!title){ alertBox('제목을 넣으세요.'); gel('fTitle').focus(); return; }
  var html=((ED.textContent||'').trim()==='' && !ED.querySelector('hr,table')) ? '' : clean(ED.innerHTML);
  if(html.length>200000){ alertBox('내용이 너무 깁니다(20만 자까지) — 줄여서 저장해 주세요.'); return; }
  var body={ schedSeq:_seq, fromDt:from, toDt:to, schedTm:gel('fTm').value||'', title:title, place:gel('fPlace').value.trim(), content:html, doneYn:stGet() };
  var d=dupOf(from, to, body.schedTm, body.doneYn);
  if(d.length){
    var msg='같은 시간에 이미 일정이 있습니다.<br><span style="font-size:12.5px;color:#3d4d5c;line-height:1.7">'+d.slice(0,5).map(function(x){ return '· '+dupLine(x); }).join('<br>')+(d.length>5?'<br>· 외 '+(d.length-5)+'건':'')+'</span><br>그래도 저장할까요?';
    if(window._confirmBox){ _confirmBox({ msg:msg, icon:'⏰', okText:'그래도 저장', onOk:function(){ edPost(body); }, onCancel:function(){ try{ gel('fTm').focus(); }catch(e){} } }); return; }
    if(!confirm('같은 시간에 이미 일정이 있습니다. 그래도 저장할까요?')) return;
  }
  edPost(body);
}
function edPost(body){
  var from=body.fromDt, to=body.toDt;
  busy(true);
  postJson('/mangr/ceoSchedSave.do', body)
    .then(function(){ busy(false); toast(_seq?'💾 일정을 고쳤습니다':'💾 일정을 등록했습니다');
      /* 저장한 일정이 다른 달이면 그 달로 옮겨 보여 준다 */
      var mA=''+_y+p2(_m+1)+'01', mB=ymd(new Date(_y,_m+1,0)); if(to<mA || from>mB){ _y=+from.slice(0,4); _m=+from.slice(4,6)-1; }
      edClose(true); load(); })
    .catch(function(e){ busy(false); alertBox(esc(e.message)); });
}
/* ★삭제 (2026-11-19 사용자 「일정 삭제기능도 (완료는 일정취소하고)」) — 창의 [🗑 삭제] 와 목록 줄 끝의 🗑 둘 다 delAsk 하나를 쓴다.
   완료한 일정은 바로 지우지 않는다 — 끝낸 일의 기록이 실수로 사라지지 않게, 상태를 일정취소(또는 빈 칸)로 바꾼 뒤에 지운다(delGuard). 서버도 같은 검사를 한다.
   상태는 «저장돼 있는 값»(_rows)으로 본다 — 창에서 단추만 눌러 놓고 저장하지 않은 것은 치지 않는다 */
function rowOf(seq){ for(var i=0;i<_rows.length;i++) if(_rows[i].schedSeq===seq) return _rows[i]; return null; }
function delGuard(seq){
  var s=rowOf(seq);
  if(s && stKey(s)==='Y'){ alertBox('완료한 일정은 바로 지울 수 없습니다.<br><span style="font-size:12.5px;color:#3d4d5c">상태를 <b>일정취소</b>로 바꾼 뒤 지워 주세요 — 목록의 상태 칸에서 바로 바꿀 수 있습니다.</span>'); return false; }
  return true;
}
function delAsk(seq, title, after){
  if(!seq || !delGuard(seq)) return;
  var go=function(){ busy(true); postForm('/mangr/ceoSchedDel.do',{ schedSeq:seq }).then(function(){ busy(false); toast('🗑 일정을 지웠습니다'); if(after) after(); load(); }).catch(function(e){ busy(false); alertBox(esc(e.message)); }); };
  if(window._confirmBox) _confirmBox({ msg:'이 일정을 지울까요?<br><b>'+esc(title||'')+'</b><br><span style="font-size:12px;color:#6b7a89">지우면 달력과 목록에서 사라집니다.</span>', icon:'🗑', okText:'지우기', onOk:go, onCancel:function(){} });
  else if(confirm('이 일정을 지울까요?')) go();
}
/* ★창에서 완료를 풀고 바로 [삭제] (2026-11-19 사용자 「완료에서 일정취소 하고 저장 안 하고 하면 삭제 안 됨 — 저장하고 다시 들어와서 해야 삭제됨」) —
   저장돼 있는 상태는 완료인데 창에서 [일정취소](또는 완료 풀기)를 눌러 놓았으면, 따로 저장하지 않아도 «그 상태로 먼저 바꾼 뒤» 지운다(한 번에).
   확인 글에 상태를 바꾼다는 것을 같이 적는다. 창에서도 완료인 채면 종전대로 막고, 이 창에서 어떻게 하면 되는지 알려 준다 */
function edDel(){
  if(!_seq) return;
  var s=rowOf(_seq), cur=stGet(), seq=_seq, title=gel('fTitle').value;
  if(s && stKey(s)==='Y' && cur==='Y'){ alertBox('완료한 일정은 바로 지울 수 없습니다.<br><span style="font-size:12.5px;color:#3d4d5c">위의 <b>[일정취소]</b>를 누른 다음 [삭제]를 누르세요 — 저장은 따로 하지 않아도 됩니다.</span>'); return; }
  if(s && stKey(s)==='Y'){
    var nm=(cur==='C' ? '일정취소' : '완료 해제');
    var go=function(){ busy(true);
      postForm('/mangr/ceoSchedDone.do',{ schedSeq:seq, doneYn:cur })
        .then(function(){ return postForm('/mangr/ceoSchedDel.do',{ schedSeq:seq }); })
        .then(function(){ busy(false); toast('🗑 일정을 지웠습니다'); edClose(true); load(); })
        .catch(function(e){ busy(false); alertBox(esc(e.message)); load(); }); };
    if(window._confirmBox) _confirmBox({ msg:'상태를 <b>'+nm+'</b>(으)로 바꾸고 이 일정을 지울까요?<br><b>'+esc(title)+'</b><br><span style="font-size:12px;color:#6b7a89">지우면 달력과 목록에서 사라집니다.</span>', icon:'🗑', okText:'지우기', onOk:go, onCancel:function(){} });
    else if(confirm('상태를 '+nm+'(으)로 바꾸고 이 일정을 지울까요?')) go();
    return;
  }
  delAsk(seq, title, function(){ edClose(true); });
}
/* 목록 줄 끝의 🗑 — 창을 열지 않고 바로 */
/* ★완료한 줄의 🗑 = 일정취소로 바꾸고 바로 지운다 (2026-11-19 사용자 「목록 🗑도 완료면 일정취소하고 바로 삭제되게」) —
   종전엔 「상태 칸에서 일정취소로 바꾼 뒤」라고 안내만 했다. 이제 한 번 물은 뒤 상태 변경 + 삭제를 이어서 한다(확인 글에 완료한 일정이라는 것을 적는다) */
function rowDel(seq, ev){
  if(ev) ev.stopPropagation();
  var s=rowOf(seq); if(!s) return;
  if(stKey(s)!=='Y'){ delAsk(seq, s.title); return; }
  var go=function(){ busy(true);
    postForm('/mangr/ceoSchedDone.do',{ schedSeq:seq, doneYn:'C' })
      .then(function(){ return postForm('/mangr/ceoSchedDel.do',{ schedSeq:seq }); })
      .then(function(){ busy(false); toast('🗑 일정을 지웠습니다'); load(); })
      .catch(function(e){ busy(false); alertBox(esc(e.message)); load(); }); };
  if(window._confirmBox) _confirmBox({ msg:'<b>완료한 일정</b>입니다 — 일정취소로 바꾸고 지울까요?<br><b>'+esc(s.title||'')+'</b><br><span style="font-size:12px;color:#6b7a89">지우면 달력과 목록에서 사라집니다.</span>', icon:'🗑', okText:'지우기', onOk:go, onCancel:function(){} });
  else if(confirm('완료한 일정입니다 — 일정취소로 바꾸고 지울까요?')) go();
}

(function(){
  var t=new Date(); _y=t.getFullYear(); _m=t.getMonth();
  if(!ADMIN){ gel('wrap').innerHTML='<div class="deny">🔒 대표자 일정은 <b>총괄관리자</b>만 볼 수 있습니다.</div>'; return; }
  edInit(); load();
})();
</script>
</body>
</html>
