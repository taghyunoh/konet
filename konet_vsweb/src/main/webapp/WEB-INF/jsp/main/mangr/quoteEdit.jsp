<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>견적서 작성</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<script src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260917c"></script>   <%-- 회사 설정 — 센터별 물류비율·보관 기본값(konetSet.cost) --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-popdrag.js?v=20260910b"></script>   <%-- 팝업 끌어 옮기기 (2026-09-18 「상품검색 마우스 클릭으로 이동」) — 발주서와 같은 .pop+.ph 뼈대 --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 📥 엑셀 (전역 XLSX) --%>
<!--
  견적서 작성 (2026-09-17 신설 — 「여기에서 견적서 작성 및 출력 가능하게」) — 견적서관리 ▸ 견적서 작성. 셸 iframe(logiFrame) 화면.
  · 새 견적서 : 문서번호는 'Konet' + 견적일 yyMMdd + '-' + 두 자리 차례로 자동(고칠 수 있음). 수신·담당자·유효기간·제목은 표본 값이 기본.
  · 머리 칸은 한 줄에 세 칸(라벨+값 세 짝)씩 (2026-09-17 「표시줄을 한 줄에 세 줄로」 — 오른쪽 빈자리 지적).
  · 품목 줄 : 품명·규격·Box·수량·단위·단가·금액(수량×단가 자동)·비고. [🔍 상품] 로 우리 상품 마스터에서 골라 품명·규격·판매가를 채운다.
    「택배출고 단가도」를 켜면 단가 묶음이 둘(센터배송 / 택배출고(D2~3))이 된다 — 표본 260730-1 꼴.
  ★원가·마진 계산 통합 (2026-09-17 「원가마진계산을 견적서 작성에서 품명 연관으로 · 메뉴에서는 없애고」) — 품목 줄의 [🧮] 를 누르면
    그 줄 밑에 계산 칸이 펼쳐진다(표본 오택현.xls 식 그대로 : 구매 = 단가+운송+보관+소분+박스+부대비/개 · 실 마진율 = 실판매÷구매계−1).
    · 판매 단가 이름 = ★「판매적용단가」(종전 원가마진계산 화면의 「평/용센터」 칸 — 2026-09-17 「평/용센터를 판매적용단가로 변경」).
      계산 칸의 판매적용단가 = 품목 줄의 단가(같은 값, 어느 쪽을 고쳐도 같이 움직인다).
    · 목표 마진율을 넣으면 「필요 판매단가」가 나오고 [→ 적용] 으로 판매적용단가(=줄 단가)에 넣는다.
    · ★마진계산이 붙은 줄은 Box = 1 · 수량 = 박스 입수량 으로 자동(2026-09-17 「box 는 1, 수량은 박스입수량」 — 칸이 잠긴다).
    · ★부대비(동판비·목형비 …)는 품명의 <서브 줄>로 : 줄마다 [서브 줄로(별도 청구)/원가 포함/적용 안 함] 을 고른다
      (2026-09-17 「품명에 서브로 동판비·목형비가 적용될지 말지」). 서브 줄은 저장 때 진짜 품목 줄(비고 '별도 청구')로 들어간다.
    · ★계산 내용은 견적서 한 건마다 근거자료로 저장(TBL_QUOTE_MST.CALC_JSON — DDL docs/sql/20260917_quote_calc.sql).
      calcJson = { v, use2(양식2 여부), set(배송·센터·직송비 — mode 값 direct=DC·parcel=직송, 2026-09-18 이름만 변경), calcs(품목 줄 차례대로), genRows(서브 줄의 rowNo — 불러올 때 걷어내고 다시 만든다) }.
    · 센터별 물류비율·보관 기본값은 회사 설정(konetSet.cost, compSetPatch key=cost) — 종전 원가마진계산 화면과 같은 자리.
  ★저장 정리 : 양식2 인데 둘째 단가를 한 줄도 안 넣었으면 <단가 묶음 하나>로 저장한다(price2Nm 비움) —
    인쇄·엑셀(양식 1/2 선택)·목록이 전부 「선택한 내용만」이 된다(2026-09-17 「없으면 출력하지 말고 선택한 내용만」). 양식 라디오는 calcJson.use2 로 되살린다.
  · 저장 = quoteSave.do (파일 없이). 같은 문서번호는 대체되므로 「수정」(?quoteSeq=)도 같은 길 — 그때는 확인 없이 덮는다(confirm=Y).
  · [🖨 출력] = quotePrint.do (A4 양식 — 합계 줄 없음). [📥 엑셀] = quoteExcel.do (양식 파일 그대로 — 합계 줄이 원래 없다).
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; --blue:#2f4f9a; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ color:var(--red); }
  .lnk{ height:26px; padding:0 8px; font-size:12px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  /* 머리 칸 — 한 줄에 세 짝 (2026-09-17 「표시줄을 한 줄에 세 줄로」) */
  .fm{ display:grid; grid-template-columns:96px 1fr 96px 1fr 96px 1fr; gap:8px 10px; padding:12px; align-items:center; max-width:1560px; }
  .fm label{ font-weight:700; color:#37475a; font-size:13px; text-align:right; }
  .fm input[type=text], .fm input[type=date], .fm textarea{ width:100%; height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .fm textarea{ height:58px; padding:6px 8px; resize:vertical; }
  .fm .frmOpt{ display:flex; align-items:center; gap:6px; font-weight:400; text-align:left; font-size:13px; border:1px solid var(--bd); border-radius:8px; padding:6px 12px; cursor:pointer; background:#fff; }
  .fm .frmOpt:has(input:checked){ border-color:#0f6b5e; background:#e3f2ee; }
  .fm .frmOpt input{ margin:0; }
  .fm select#delivSel{ height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 6px; font-size:13.5px; background:#fff; }
  .fm .full{ grid-column:2 / span 5; }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:3px 4px; vertical-align:middle; text-align:center; }
  table.g input[type=text]{ width:100%; height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; }
  table.g input.num{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g input.lock{ background:#eef1f5; color:#4a5a6a; border:1px dashed #b9c4d0; }
  table.g td.amt{ text-align:right; font-weight:800; color:#137a6c; font-variant-numeric:tabular-nums; padding-right:8px; }
  table.g tr.sum td{ background:#eef4f2; font-weight:800; }
  /* 부대비 서브 줄 (2026-09-17) — 품명 밑에 들여쓴 표시 전용 줄. 값은 위 계산 칸에서 고친다 */
  table.g tr.subln td{ background:#fbfcfd; color:#37475a; font-size:12.5px; }
  table.g tr.subln td.snm{ text-align:left; padding-left:22px; }
  table.g tr.subln td.samt{ text-align:right; font-weight:700; font-variant-numeric:tabular-nums; padding-right:8px; }
  /* 줄별 원가·마진 계산 칸 */
  table.g tr.crow > td{ background:#f4faf8; border-bottom:1px solid #cfe0da; text-align:left; padding:8px 10px; }
  .cwrap{ display:flex; flex-wrap:wrap; gap:6px 12px; align-items:flex-end; }
  .cf{ display:flex; flex-direction:column; gap:2px; font-size:11.5px; color:#5b6b7b; font-weight:700; white-space:nowrap; }
  .cf input{ height:28px !important; font-size:13px !important; }
  .cf input.ci{ border:1.5px solid #e9b98a; background:#fdebd9; width:76px; text-align:right; border-radius:6px; padding:0 6px; }
  .cf input.cm{ background:#fff3c4; border:1.5px solid #e2b93b; width:76px; text-align:right; border-radius:6px; padding:0 6px; }
  .cf input.ca{ background:#eef1f5; border:1px dashed #b9c4d0; width:76px; text-align:right; border-radius:6px; padding:0 6px; color:#4a5a6a; }
  .cv{ display:inline-block; min-width:76px; text-align:right; background:#eef1f5; border:1px dashed #b9c4d0; border-radius:6px; padding:5px 6px; font-weight:700; font-variant-numeric:tabular-nums; font-size:13px; height:28px; }
  .cv.s{ background:#e3f7df; font-weight:800; }
  .cv.p{ background:#d9ecf7; } .cv.q{ background:#fff9d6; }
  .cv.b{ color:var(--blue); font-weight:800; }
  .cv.neg{ color:var(--red); }
  .cex{ display:flex; flex-wrap:wrap; gap:6px 10px; align-items:center; margin-top:7px; font-size:12.5px; }
  .cex select{ height:28px; border:1px solid var(--bd); border-radius:6px; font-size:12px; background:#fff; }
  .cex input{ height:28px; border:1.5px solid #e9b98a; background:#fdebd9; border-radius:6px; padding:0 6px; font-size:13px; }
  /* 계산 칸 = 그룹 머리글 있는 표 — 표본 엑셀과 같은 색 구분 (2026-09-18 「엑셀처럼 헤더 컬럼 구분 명확하게」 : 배송 노랑 · 박스입수량 주황 · 구매/판매 노랑 · 물류비 파랑 · 실 마진율 초록) */
  table.csh{ border-collapse:collapse; font-size:12.5px; background:#fff; }
  table.csh th{ border:1px solid #c9d3dd; padding:4px 6px; text-align:center; font-weight:700; font-size:12px; white-space:nowrap; color:#2b3a49; background:#f3f5f8; }
  table.csh th.g1{ background:#fff3a3; } table.csh th.g2{ background:#f7c99a; }
  table.csh th.g4{ background:#a9d0e6; } table.csh th.g6{ background:#a8e6a0; } table.csh th.g7{ background:#e6ebf1; }
  table.csh td{ border:1px solid #d8e0e8; padding:3px 4px; text-align:right; vertical-align:middle; white-space:nowrap; font-variant-numeric:tabular-nums; }
  table.csh td.au{ background:#f3f5f8; color:#2b3a49; font-weight:700; min-width:76px; }
  table.csh td.au.p{ background:#d9ecf7; } table.csh td.au.q{ background:#fff9d6; } table.csh td.au.s{ background:#e3f7df; font-weight:800; }
  table.csh td.au.b{ color:var(--blue); font-weight:800; background:#eef2f8; }
  table.csh td.neg{ color:var(--red); }
  table.csh td.c{ text-align:center; }
  /* 도움말 카드 (2026-09-18) — 탭 단추 .qht + 본문 .qhp */
  .qht{ font-weight:800; color:#37475a; }
  .qht.on{ background:#e3f2ee; border-color:#0f6b5e; color:#0f6b5e; }
  .qhp{ padding:10px 14px 12px; font-size:12.5px; line-height:1.8; color:#37475a; }
  .qhp b{ color:#125a4e; }
  .tot{ font-size:13px; color:#37475a; font-weight:700; } .tot b{ color:var(--teal); }
  .dim{ color:#8a98a8; }
  .csbar{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; padding:8px 12px; border-bottom:1px solid #eef1f5; font-size:13px; }
  .csbar .opt{ display:inline-flex; align-items:center; gap:5px; font-size:13px; font-weight:800; border:1px solid var(--bd); border-radius:8px; padding:5px 10px; cursor:pointer; background:#fff; }   /* 갈래 이름 진하게 (2026-09-18 「글자 진하게」) */
  .csbar .opt .dim{ font-weight:600; }
  .csbar .opt:has(input:checked){ border-color:#0f6b5e; background:#e3f2ee; }
  .csbar select, .csbar input{ height:30px; border:1px solid var(--bd); border-radius:7px; padding:0 6px; font-size:13px; background:#fff; }
  .csbar input.num{ text-align:right; border:1.5px solid #e9b98a; background:#fdebd9; }
  .pop{ position:fixed; inset:0; background:rgba(15,23,32,.35); display:none; align-items:flex-start; justify-content:center; z-index:1000; padding-top:6vh; }
  .pop.on{ display:flex; }
  .pop .box{ background:#fff; width:min(860px,94vw); max-height:84vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); display:flex; flex-direction:column; overflow:hidden; }
  .pop .ph{ display:flex; gap:8px; align-items:center; padding:10px 14px; border-bottom:1px solid #eef1f5; }
  .pop .ph input{ flex:1; height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:14px; }
  .pop .pb{ overflow:auto; }
  .pop table.g tr.pick{ cursor:pointer; } .pop table.g tr.pick:hover td{ background:#e3f2ee; }
  .pop .pb .in{ border:1.5px solid #e9b98a; background:#fdebd9; height:30px; border-radius:6px; padding:0 6px; font-size:13px; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🧾 견적서 작성 <small id="mode">새 견적서</small>
    <button class="btn lnk" style="margin-left:auto" onclick="helpToggle()" title="이 화면 사용법 — 1) 견적서 작성 · 2) 원가·마진 계산">ℹ️ 도움말</button></h2>
  <%-- 도움말 카드 (2026-09-18 「도움말 버튼으로 1) 견적서작성 2) 원가마진계산」) — 기본 접힘, 매출 그래프 도움말 카드와 같은 방식 --%>
  <div class="card" id="qHelp" hidden>
    <div class="hd" style="gap:6px">
      <button class="btn lnk qht on" id="qhB1" onclick="helpTab(1)">1) 견적서 작성</button>
      <button class="btn lnk qht" id="qhB2" onclick="helpTab(2)">2) 원가·마진 계산</button>
      <button class="btn lnk" style="margin-left:auto" onclick="helpToggle()">닫기 ✕</button>
    </div>
    <div id="qhP1" class="qhp">
      <b>흐름</b> : 머리 칸 채우기 → 품목 줄에 [🔍 상품]으로 담기(금액 = 수량 × 단가 자동) → [💾 저장] → [🖨 출력]·[📥 엑셀]<br>
      · <b>양식</b> — 「센터배송 + 택배출고」 = 단가·금액 <b>두 묶음</b> + 비고(MOQ) / 「단가 하나」 = 묶음 하나.
        두 묶음 양식이라도 <b>둘째 단가를 한 줄도 안 넣으면 묶음 하나로 저장·출력</b>됩니다(선택한 내용만 나감).<br>
      · <b>문서번호</b> — 견적일로 자동(고칠 수 있음). <b>같은 문서번호를 저장하면 앞의 것을 대체</b>합니다.<br>
      · <b>배송</b> — 고르면 제목 줄 「(…, 부가세 별도)」와 비고에 같이 들어갑니다. 다르게 쓰려면 옆 칸에 직접 적으세요.<br>
      · <b>출력</b> — A4 양식(하단 합계 줄 없음), 품명·규격·비고가 길면 두 줄로 접힙니다. 엑셀은 견적서 양식 파일 그대로.<br>
      · 저장한 견적서는 <b>견적서관리 목록</b>에서 다시 열기(✏)·출력(🖨)·계산 조회(🧮)를 할 수 있습니다.
    </div>
    <div id="qhP2" class="qhp" hidden>
      <b>여는 법</b> : 품목 줄 맨 앞 <b>[🧮]</b> — 그 품명 밑에 계산 칸이 펼쳐집니다. [➕ 품목 추가 (🧮 세트)] = 품명 + 계산 + 품명비 세트 한 벌씩 이어 붙임.<br>
      · <b>계산 붙은 줄은 Box 1 · 수량 = 박스 입수량 자동</b>(잠김) — 한 박스 기준으로 계산합니다.<br>
      · <b>구매(계산)</b> = 단가 + 운송 + 보관 + 소분 + 박스 (+ 원가 포함 품명비/개). 보관은 「보관료 × 팔레트 × 개월 ÷ MOQ」 자동 — 손대면 노란 칸(직접 값).<br>
      · <b>물류비</b> = 판매 계 × 센터 비율(센터배송) / 판매 계 × DC 비율(DC — 기본 11.5%) / 박스당 직송비(직송) — 표 위 「🧮 마진계산 물류비」에서 고릅니다. 비율·보관 기본값은 [⚙]에서(회사 설정).<br>
      · <b>판매적용단가 = 품목 줄의 단가</b>(같은 값·양방향). 목표 마진율을 넣으면 필요 판매단가가 나오고 [→ 적용]으로 단가에 넣습니다.<br>
      · <b>품명비(동판·목형)</b> — 「적용 안 함 / 서브 줄로(별도 청구·마진 0) / 원가 포함」. 원가 포함이면 개당(금액÷MOQ)으로 구매(계산)에 들어가고,
        견적서에는 <b>단가·금액 없는 표시 줄</b> + 비고에 근거(수량 × 단가 = 금액)가 자동 기재됩니다.<br>
      · 계산 내용은 <b>저장할 때 견적서에 근거자료로 함께 저장</b>됩니다 — 견적서관리 목록의 [🧮]로 그때 값(비율·보관 포함) 그대로 다시 봅니다.
    </div>
  </div>
  <div class="card">
    <div class="hd">머리 <small>— 문서번호는 견적일로 자동 매깁니다(고칠 수 있음). 같은 문서번호를 저장하면 앞의 것을 대체합니다</small>
    </div>
    <div class="fm">
      <label>양식</label><div class="full" style="display:flex;gap:8px;flex-wrap:wrap">
        <label class="frmOpt"><input type="radio" name="frm" value="2" id="use2" checked onchange="renderLines(); delivOnUse2()"> <b>센터배송 + 택배출고(D2~3)</b> <span class="dim">— 단가·금액 두 묶음 + 비고(MOQ) · 260730-1 꼴</span></label>
        <label class="frmOpt"><input type="radio" name="frm" value="1" id="use1" onchange="renderLines(); delivOnUse2()"> <b>단가 하나</b> <span class="dim">— 센터배송만 · 260729-1 꼴</span></label>
      </div>
      <label>문서번호</label><div style="display:flex;gap:6px"><input type="text" id="docNo" style="font-weight:800" placeholder="Konet260917-01"><button class="btn lnk" style="height:32px" onclick="nextNo(true)" title="견적일 기준 다음 번호">↻ 번호</button></div>
      <label>견적일</label><input type="date" id="quoteDt" onchange="if(!_seq) nextNo(false)">
      <label>수신</label><input type="text" id="recvNm" value="삼성웰스토리" list="recvList" autocomplete="off">
      <label>담당자</label><input type="text" id="mgrNm" placeholder="예: 김정호 프로님" list="mgrList" autocomplete="off" title="지금까지 저장한 담당자 이름이 목록으로 뜹니다(칸을 비우고 ▼ 또는 글자를 치면). 새 이름은 그냥 적으면 됩니다">
      <datalist id="mgrList"></datalist><datalist id="recvList"></datalist>
      <label>유효기간</label><input type="text" id="validTxt" value="견적일로부터 15일">
      <label>단가 묶음 이름</label><div style="display:flex;gap:6px;align-items:center"><input type="text" id="p1" value="센터배송" style="width:130px" title="첫째 묶음 이름(묶음이 하나면 인쇄에 안 나옵니다)"><span class="dim">/</span><input type="text" id="p2" value="택배출고 (D2~3)" style="width:150px" title="둘째 묶음 이름"></div>
      <label>배송</label><div class="full" style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
        <select id="delivSel" onchange="delivPick(this.value)" title="배송 조건 — 제목 줄 「(…, 부가세 별도)」와 비고에 같이 들어갑니다">
          <option value="센터배송 / 택배출고 (D2~3)">센터배송 / 택배출고 (D2~3)</option><option value="센터배송">센터배송</option><option value="택배출고 (D2~3)">택배출고 (D2~3)</option><option value="배송비 포함">배송비 포함</option><option value="직송">직송</option><option value="배송비 별도">배송비 별도</option><option value="*">직접 입력…</option>
        </select>
        <input type="text" id="deliv" autocomplete="off" value="센터배송 / 택배출고 (D2~3)" style="width:230px" placeholder="직접 적기" oninput="delivSync()" onchange="delivApply()" title="고른 값이 여기 들어옵니다. 다르게 쓰려면 이 칸에 직접 적으세요">
        <span class="dim" style="font-size:12px">→ 제목 줄·비고에 들어갑니다</span></div>
      <label>제목 줄</label><input type="text" id="titleTxt" class="full" value="아래와 같이 견적을 드립니다.(센터배송, 부가세 별도)">
      <label>비고</label><textarea id="remark" class="full" placeholder="예: 배송비 포함, 부가세 별도"></textarea>
    </div>
  </div>

  <div class="card">
    <div class="hd">품목 <small>— 금액 = 수량 × 단가(자동). [🔍 상품]으로 품명·규격·판매가, [🧮]로 그 품명의 원가·마진 계산</small>
      <span class="bar" style="margin-left:auto">
        <button class="btn" style="border-color:#0f6b5e;background:#e3f2ee;color:#0f6b5e" onclick="addCalcLine()" title="품명 + 마진계산 + 품명비(동판·목형) 세트를 한 벌 더 — 이어서 계속 작성">➕ 품목 추가 (🧮 세트)</button>
        <button class="btn" onclick="addLine()" title="계산 없는 품목 줄만 하나 더">＋ 줄만 추가</button>
      </span>
    </div>
    <%-- 원가·마진 계산 공통 조건 (2026-09-17 통합) — 물류비 갈래는 견적서 한 장에 하나. 줄별 계산 칸이 이 값을 쓴다 --%>
    <div class="csbar" id="csBar">
      <b style="color:#125a4e">🧮 마진계산 물류비</b>
      <label class="opt"><input type="radio" name="csmode" value="center" onchange="csModeSet()"> 센터배송</label>
      <select id="csCenter" onchange="_cs.center=this.value; csPaintAll()" title="센터별 물류비율 — ⚙ 에서 고친다" style="min-width:170px"></select>
      <%-- 이름 변경 (2026-09-18 「직송 → DC · 택배 → 직송」) — 값(direct/parcel)은 저장된 근거자료(CALC_JSON set.mode)와 호환되게 그대로 둔다 --%>
      <label class="opt"><input type="radio" name="csmode" value="direct" onchange="csModeSet()"> DC <span class="dim" id="csDcLab">(11.5%)</span></label>
      <label class="opt"><input type="radio" name="csmode" value="parcel" onchange="csModeSet()"> 직송</label>
      <span id="csFeeWrap" style="display:none;align-items:center;gap:5px">직송비/박스 <input type="text" class="num" id="csFee" style="width:84px" onfocus="this.select()" oninput="_cs.fee=n(this.value); csPaintAll()"> 원</span>
      <span class="dim" id="csNote" style="font-size:12px"></span>
      <button class="btn lnk" style="margin-left:auto" onclick="cenOpen()" title="센터별 물류비율과 보관 기본값 — 회사 설정에 저장(어느 PC 에서나 같다)">⚙ 센터 비율·보관 기본값</button>
    </div>
    <div class="tw"><table class="g"><thead id="lhead"></thead><tbody id="lbody"></tbody></table></div>
    <div class="bar" style="padding:10px 12px">
      <button class="btn btn-teal" id="saveBtn" onclick="save()">💾 저장</button>
      <button class="btn" id="printBtn" onclick="printIt()" title="저장한 견적서를 A4 양식으로">🖨 출력</button>
      <button class="btn" onclick="excel()">📥 엑셀</button>
      <button class="btn" onclick="newDoc()">✨ 새 견적서</button>
      <span class="tot" style="margin-left:auto" id="tot"></span>
    </div>
  </div>
</div>

<div class="pop" id="prodPop">
  <div class="box">
    <div class="ph"><b>🔍 상품 찾기</b><input type="text" id="prodQ" placeholder="상품코드 · 품명 · 규격 · 매칭코드 (비우면 앞 200개 · ESC 닫기)" oninput="prodSearch()" onkeydown="prodKey(event)"><button class="btn" onclick="document.getElementById('prodPop').classList.remove('on')">닫기 ✕</button></div>
    <div class="pb"><table class="g"><thead><tr><th>코드</th><th>품명</th><th>규격</th><th>입수</th><th>판매가</th></tr></thead><tbody id="prodBody"><tr><td colspan="5" class="dim" style="padding:20px">글자를 치면 찾습니다.</td></tr></tbody></table></div>
  </div>
</div>

<%-- ⚙ 센터별 물류비율·보관 기본값 (2026-09-17 — 종전 원가·마진 계산 화면에서 옮겨 옴. 회사 설정 konetSet.cost) --%>
<div class="pop" id="cenPop">
  <div class="box" style="width:min(560px,94vw)">
    <div class="ph"><b>⚙ 센터 비율·보관 기본값</b><span class="dim" style="flex:1;font-size:12px">회사 설정에 저장 — 어느 PC 에서나 같다</span><button class="btn" onclick="document.getElementById('cenPop').classList.remove('on')">닫기 ✕</button></div>
    <div class="pb" style="padding:12px">
      <div class="bar" style="margin-bottom:6px"><b>센터별 물류비율(%)</b> <span class="dim" style="font-size:12px">판매 계(박스)에 곱한다</span></div>
      <table class="g"><thead><tr><th>센터</th><th style="width:110px">비율(%)</th><th style="width:50px"></th></tr></thead><tbody id="cenBody"></tbody></table>
      <div class="bar" style="margin-top:8px"><button class="btn lnk" onclick="cenAdd()">➕ 센터</button></div>
      <div class="bar" style="margin-top:14px"><b>보관/개 기본값</b> <span class="dim" style="font-size:12px">= 보관료 × 팔레트 × 개월 ÷ MOQ 수량</span></div>
      <div class="bar" style="margin-top:6px">보관료 <input type="text" class="in num" id="storeFee" style="width:90px;text-align:right"> 원 × 팔레트 <input type="text" class="in num" id="storePlt" style="width:56px;text-align:right"> × 개월 <input type="text" class="in num" id="storeMon" style="width:56px;text-align:right">
        <span style="margin-left:14px">DC 비율 <input type="text" class="in num" id="dcRate" style="width:56px;text-align:right" title="DC 갈래의 물류비율 — 물류비 = 판매 계 × 이 비율 (기본 11.5%)"> %</span></div>
      <div class="bar" style="margin-top:14px"><button class="btn btn-teal" onclick="cenSave()">💾 회사 설정에 저장</button></div>
    </div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _seq=0, _lines=[], _prodRow=-1, _prodT=null, _savedSeq=0, _savedDocNo='';   /* _savedDocNo = 이 화면에서 방금 저장한 문서번호 — 다시 저장할 땐 중복 확인 없이 덮어쓴다 */
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v,d){ var x=n(v); return d ? x.toLocaleString('ko-KR',{minimumFractionDigits:d,maximumFractionDigits:d}) : (Math.round(x*100)/100).toLocaleString(); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin',
  headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }
function ok(m){ _alertBox(m,{icon:'✅'}); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function ask(m, okText){ return new Promise(function(res){ _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', onOk:function(){res(true);}, onCancel:function(){res(false);} }); }); }
function use2(){ return document.getElementById('use2').checked; }
function cols(){ return use2()?12:10; }

/* ══ 원가·마진 계산 (2026-09-17 통합 — 종전 costCalc.jsp 의 식 그대로) ══ */
var DEF_COST={ centers:[{nm:'평/용센터',rate:10.5},{nm:'왜관센터',rate:15.1},{nm:'광주센터',rate:14.6},{nm:'김해센터',rate:16.1},{nm:'제주센터',rate:18.1}], storeFee:25000, storePlt:3, storeMon:3, dcRate:11.5 };
var COST=(function(){ var c=(window.konetSet&&konetSet.cost)||{}; return { centers:(c.centers&&c.centers.length)?c.centers.map(function(x){ return {nm:String(x.nm||''),rate:n(x.rate)}; }):DEF_COST.centers.slice(), storeFee:n(c.storeFee)||DEF_COST.storeFee, storePlt:n(c.storePlt)||DEF_COST.storePlt, storeMon:n(c.storeMon)||DEF_COST.storeMon, dcRate:(c.dcRate!=null? n(c.dcRate) : DEF_COST.dcRate) }; })();
var _cs={ mode:'center', center:(COST.centers[0]?COST.centers[0].nm:''), fee:0 };   /* 물류비 갈래 — calcJson.set 으로 견적서마다 저장 */
function csRate(){ for(var i=0;i<COST.centers.length;i++) if(COST.centers[i].nm===_cs.center) return n(COST.centers[i].rate); return COST.centers[0]?n(COST.centers[0].rate):0; }
function csCenterFill(){ var s=document.getElementById('csCenter'); s.innerHTML=COST.centers.map(function(c){ return '<option value="'+esc(c.nm)+'">'+esc(c.nm)+' — '+fmt(c.rate,1)+'%</option>'; }).join(''); if(_cs.center) s.value=_cs.center; if(!s.value&&COST.centers[0]){ s.value=COST.centers[0].nm; } _cs.center=s.value; }
function csBarPaint(){ var r=document.querySelector('input[name=csmode][value="'+_cs.mode+'"]'); if(r) r.checked=true; csCenterFill();
  document.getElementById('csFee').value=n(_cs.fee)?fmt(_cs.fee):'';
  document.getElementById('csCenter').style.display=_cs.mode==='center'?'':'none';
  document.getElementById('csFeeWrap').style.display=_cs.mode==='parcel'?'inline-flex':'none';
  var dl=document.getElementById('csDcLab'); if(dl) dl.textContent='('+fmt(n(COST.dcRate),1)+'%)';
  document.getElementById('csNote').textContent=_cs.mode==='center'?'물류비 = 판매 계 × 센터 비율':(_cs.mode==='direct'?('물류비 = 판매 계 × DC 비율 '+fmt(n(COST.dcRate),1)+'%'):'물류비 = 박스마다 직송비'); }
function csModeSet(){ var r=document.querySelector('input[name=csmode]:checked'); _cs.mode=r?r.value:'center'; csBarPaint(); csPaintAll(); }
function csPaintAll(){ _lines.forEach(function(l,i){ if(l.calc) calcPaint(i); }); calc(); }
/* ★품명 세트 = 품명 + 동판 + 목형 (2026-09-17 「품명, 동판, 목형 세 개 세트 — (동판·목형) 적용 여부만」) —
   자유 추가 「부대비」 목록을 없애고 두 줄 고정. 적용(체크) = 품명 밑 서브 줄(별도 청구·마진 0)로 견적서에 들어간다. */
function newCalc(){ return { open:true, moqQty:0, buy:0, box:0, trans:0, store:0, storeManual:false, split:0, pack:0, target:0, tgtAmt:0,
  extras:[{nm:'동판비',qty:0,price:0,use:'off'},{nm:'목형비',qty:0,price:0,use:'off'}] }; }
function normCalc(c){ var b=newCalc(); if(!c) return null; for(var k in b) if(c[k]!=null) b[k]=c[k];
  b.extras=(c.extras||[]).map(function(x){ return { nm:String(x.nm||''), qty:n(x.qty), price:n(x.price), use:(x.use==='sub'||x.use==='cost')?x.use:'off' }; });
  if(!b.extras.length) b.extras=newCalc().extras;   /* 옛 자료가 비어 있어도 동판·목형 두 줄은 늘 있다 */
  return b; }
function storeAuto(c){ var q=n(c.moqQty); return q? COST.storeFee*COST.storePlt*COST.storeMon/q : 0; }
/* 계산에 값이 하나라도 들었나 — 불러올 때 「값이 있을 때만」 펼치는 판정 (2026-09-18) */
function calcHasVal(c){ if(!c) return false;
  if(['moqQty','buy','box','trans','store','split','pack','target','tgtAmt'].some(function(k){ return n(c[k])>0; })) return true;
  return (c.extras||[]).some(function(x){ return n(x.qty)>0 || n(x.price)>0 || (x.use&&x.use!=='off'); });
}
function calcOf(l){
  var c=l.calc; if(!c) return null;
  var G=n(c.box), Q0=n(c.moqQty), E=n(c.buy);
  var exCost=(c.extras||[]).filter(function(x){ return x.use==='cost'; }).reduce(function(a,x){ return a+n(x.qty)*n(x.price); },0);
  var exPer=Q0? exCost/Q0 : 0;
  var store=c.storeManual? n(c.store) : storeAuto(c);
  var H=E+n(c.trans)+store+n(c.split)+n(c.pack)+exPer;
  var I=H*G, N=n(l.unitPrice), O=N*G;
  /* 물류비 비율 — 센터배송 = 고른 센터, ★DC = 회사 설정 dcRate(기본 11.5% — 2026-09-18 「DC 비는 11.5% 계산」, 종전 「물류비 없음」을 대체), 직송 = 박스당 직송비 */
  var eff=_cs.mode==='center'? csRate() : (_cs.mode==='direct'? n(COST.dcRate) : 0);
  var P=_cs.mode==='parcel'? n(_cs.fee) : O*eff/100;
  var Q=O-P, R=Q-I, S=I?(Q/I-1):0;
  var t=n(c.target)/100;
  var need=_cs.mode!=='parcel'? (G&&eff<100? I*(1+t)/(G*(1-eff/100)) : 0) : (G? (I*(1+t)+n(_cs.fee))/G : 0);
  return { store:store, H:H, I:I, O:O, P:P, Q:Q, R:R, S:S, need:need, buyTotal:E*Q0 };
}
/* 견적서에 서브 줄로 붙는 품명비 = 별도 청구 + ★원가 포함도 (2026-09-18 「원가 포함이어서 견적서에는 표시되게 — 별도 청구처럼」).
   단, 원가 포함은 금액이 이미 판매적용단가에 녹아 있으므로 저장 줄의 단가·금액은 0(이중 청구 방지) — 근거 숫자는 비고에 적는다. */
function subsOf(l){ return (l.calc&&l.calc.extras||[]).filter(function(x){ return (x.use==='sub'||x.use==='cost') && (x.nm||'').trim(); }); }
/* ★마진계산이 붙은 줄은 Box 1 · 수량 = 박스 입수량 (2026-09-17 확정) */
function calcLineSync(l){ if(l.calc && n(l.calc.box)>0){ l.boxQty=1; l.qty=n(l.calc.box); return true; } return false; }
function calcToggle(i){ var l=_lines[i]; if(!l) return; if(!l.calc){ l.calc=newCalc(); } else l.calc.open=!l.calc.open; calcLineSync(l); renderLines(); }
function calcDrop(i){ var l=_lines[i]; if(!l) return; _confirmBox({ msg:'이 줄의 원가·마진 계산을 뺄까요?<br><span style="font-size:12.5px;color:#3d4d5c">서브 줄(부대비)도 함께 빠집니다. 단가·수량은 지금 값 그대로 남습니다.</span>', icon:'🧮', okText:'빼기', onOk:function(){ l.calc=null; renderLines(); }, onCancel:function(){} }); }
function cset(i,k,v){ var l=_lines[i]; if(!l||!l.calc) return; l.calc[k]=v; if(k==='box'){ if(calcLineSync(l)){ var b=document.getElementById('bv'+i), q=document.getElementById('qv'+i); if(b) b.value='1'; if(q) q.value=fmt(l.qty); } } if(k==='moqQty') moqRmkSync(i); calcPaint(i); calc(); }
/* ★비고가 빈 줄은 MOQ 수량을 자동 기재 (2026-09-18 「비고 공란일 경우 MOQ 수량 표시」) — 빈 칸 또는 「MOQ n개」 꼴(=자동 기재분)일 때만 갈아 끼운다. 사람이 다르게 적은 비고는 안 덮는다.
   ★원천 = 🧮 계산의 MOQ수량, ★계산이 없는 줄은 <줄 수량> 폴백 (2026-09-18 「원가마진 안 찍고 MOQ 안 나온다」 — 계산 없이 쓰는 사용자도 견적 수량이 곧 최소 주문량).
   ⚠계산이 붙었는데 MOQ수량이 빈 줄은 수량으로 안 물러선다 — 그 줄의 수량은 박스 입수량(개당 계산 단위)이라 MOQ 가 아니다 */
function moqRmkSync(i){ var l=_lines[i]; if(!l) return;
  var q=l.calc? n(l.calc.moqQty) : n(l.qty);
  var auto=q?('MOQ '+fmt(q)+'개'):'', cur=(l.remark||'').trim();
  if(cur && !/^MOQ [\d,\.]+개$/.test(cur)) return;
  if(cur===auto) return;
  l.remark=auto; var e=document.getElementById('rv'+i); if(e) e.value=auto;
}
function cxset(i,j,k,v){ var l=_lines[i]; if(!l||!l.calc||!l.calc.extras[j]) return; l.calc.extras[j][k]=v; if(k==='use'){ renderLines(); return; } calcPaint(i); subPaint(i); calc(); }
function subPaint(i){ var l=_lines[i]; if(!l) return; subsOf(l).forEach(function(x,k){
  var q=document.getElementById('sq'+i+'_'+k), p=document.getElementById('sp'+i+'_'+k), a=document.getElementById('sa'+i+'_'+k), amt=Math.round(n(x.qty)*n(x.price));
  if(q) q.textContent=n(x.qty)?fmt(x.qty):''; if(p) p.textContent=n(x.price)?fmt(x.price):''; if(a) a.textContent=amt?fmt(amt):''; }); }
function calcPaint(i){
  var l=_lines[i]; if(!l||!l.calc) return; var r=calcOf(l), c=l.calc;
  var set=function(id,txt,neg){ var e=document.getElementById(id); if(!e) return; e.textContent=txt; e.classList.toggle('neg', !!neg); };
  set('cF'+i, r.buyTotal?fmt(r.buyTotal):'');
  set('cH'+i, r.H?fmt(r.H,2):''); set('cI'+i, r.I?fmt(r.I):'');
  var ke=document.getElementById('cSt'+i); if(ke && !c.storeManual) ke.value=r.store?fmt(r.store,2):'';
  set('cO'+i, r.O?fmt(r.O):''); set('cP'+i, (r.O||r.P)?fmt(r.P):''); set('cQ'+i, r.O?fmt(r.Q):'');
  set('cR'+i, (r.O||r.I)?fmt(r.R):'', r.R<0); set('cS'+i, (r.I&&r.O)?(fmt(r.S*100,2)+'%'):'', r.S<0);
  set('cNeed'+i, (r.I&&n(c.target))?fmt(r.need,2):'');
  (c.extras||[]).forEach(function(x,j){ var amt=n(x.qty)*n(x.price); set('cxa'+i+'_'+j, amt?fmt(amt):''); });
}
function applyNeed(i){ var l=_lines[i]; if(!l||!l.calc) return; var r=calcOf(l); if(!r||!r.need){ _alertBox('목표 마진율과 구매·입수량을 먼저 넣으세요.',{icon:'⚠️'}); return; }
  l.unitPrice=Math.round(r.need*100)/100;
  var p=document.getElementById('pv'+i); if(p) p.value=fmt(l.unitPrice,2); var s=document.getElementById('cSell'+i); if(s) s.value=fmt(l.unitPrice,2);
  calcPaint(i); calc(); _toast('필요 판매단가를 판매적용단가(줄 단가)에 넣었습니다.'); }
function sellSet(i,v,from){ var l=_lines[i]; if(!l) return; l.unitPrice=n(v);
  var p=document.getElementById('pv'+i), s=document.getElementById('cSell'+i);
  if(from!=='grid'&&p) p.value=n(v)?fmt(l.unitPrice,2):''; if(from!=='calc'&&s) s.value=n(v)?fmt(l.unitPrice,2):'';
  if(l.calc) calcPaint(i); calc(); }
/* ⚙ 센터 비율·보관 설정 */
function cenOpen(){ cenRender(); document.getElementById('cenPop').classList.add('on'); }
function cenRender(){
  document.getElementById('cenBody').innerHTML=COST.centers.map(function(c,i){ return '<tr><td style="text-align:left"><input type="text" class="in" value="'+esc(c.nm)+'" style="width:180px" oninput="COST.centers['+i+'].nm=this.value"></td><td><input type="text" class="in num" style="width:80px;text-align:right" value="'+fmt(c.rate,1)+'" onfocus="this.select()" oninput="COST.centers['+i+'].rate=n(this.value)"></td><td><button class="btn lnk" onclick="COST.centers.splice('+i+',1); cenRender()">✕</button></td></tr>'; }).join('');
  document.getElementById('storeFee').value=fmt(COST.storeFee); document.getElementById('storePlt').value=fmt(COST.storePlt); document.getElementById('storeMon').value=fmt(COST.storeMon);
  document.getElementById('dcRate').value=fmt(n(COST.dcRate),1);
}
function cenAdd(){ COST.centers.push({nm:'',rate:0}); cenRender(); }
function cenSave(){
  COST.storeFee=n(gv('storeFee')); COST.storePlt=n(gv('storePlt')); COST.storeMon=n(gv('storeMon')); COST.dcRate=n(gv('dcRate'));
  COST.centers=COST.centers.filter(function(c){ return (c.nm||'').trim(); });
  post('/user/compSetPatch.do',{ key:'cost', val:{ centers:COST.centers, storeFee:COST.storeFee, storePlt:COST.storePlt, storeMon:COST.storeMon, dcRate:COST.dcRate } },true)
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); }); })
    .then(function(){ if(window.konetSet) konetSet.cost={ centers:COST.centers, storeFee:COST.storeFee, storePlt:COST.storePlt, storeMon:COST.storeMon, dcRate:COST.dcRate }; csBarPaint(); csPaintAll(); document.getElementById('cenPop').classList.remove('on'); ok('센터 비율·보관 기본값을 회사 설정에 저장했습니다.'); })
    .catch(function(e){ err('저장 실패 — '+esc(e.message)); });
}

/* ── 줄 ── */
function blank(){ return { prodNm:'', spec:'', boxQty:1, qty:0, unit:'ea', unitPrice:0, unitPrice2:0, remark:'', calc:null }; }
function addLine(){ _lines.push(blank()); renderLines(); focusLast(); }
/* [원복 2026-09-18] 품목 추가 단추를 품명비 줄 맨 앞으로 옮겼다가(「1번 두 개를 2번 앞으로」) 곧바로 「지금 작업 원복」 — 카드 머리(오른쪽 위)가 자리다. 다시 옮기자는 얘기가 나오면 이 이력 확인 */
/* ➕ 품목 추가 = 품명 + 마진계산 + 품명비 세트 한 벌 (2026-09-17 「이 내용을 품목 추가 버튼으로 계속 작성」).
   비어 있는 계산 없는 줄이 하나뿐이면(첫 화면) 새 줄을 만들지 않고 그 줄에 세트를 붙인다 — 빈 줄이 위에 남지 않게 */
function addCalcLine(){
  var l=_lines.length===1 && !_lines[0].calc && !(_lines[0].prodNm||'').trim() && !n(_lines[0].qty) ? _lines[0] : null;
  if(!l){ l=blank(); _lines.push(l); }
  l.calc=newCalc(); renderLines(); focusLast();
}
function focusLast(){ var tb=document.getElementById('lbody'); var last=tb.querySelectorAll('tr.mainln'); var el=last[last.length-1]&&last[last.length-1].querySelector('.nm'); if(el) el.focus(); }
function renderLines(){
  var h2=use2();
  /* 🧮·✕ 칸 = 맨 앞 No 바로 뒤 (2026-09-18 「이번 표시 맨 앞으로」 — 매입·판매등록 「줄 삭제 ✖ = 맨 앞 번호 바로 뒤」와 같은 규칙. 종전 맨 끝) */
  document.getElementById('lhead').innerHTML='<tr><th style="width:36px">No</th><th style="width:74px" title="🧮 원가·마진 계산 / ✕ 줄 빼기"></th><th style="min-width:220px">품명</th><th style="min-width:200px">규격</th><th style="width:60px">Box</th><th style="width:84px">수량</th><th style="width:52px">단위</th>'
    +(h2?'<th style="width:90px">'+esc(gv('p1')||'단가1')+' 단가</th><th style="width:100px">금액</th><th style="width:90px">'+esc(gv('p2')||'단가2')+' 단가</th><th style="width:100px">금액</th>':'<th style="width:90px">단가</th><th style="width:100px">금액</th>')
    +'<th style="min-width:110px">'+(h2?'비고 (MOQ)':'비고')+'</th></tr>';
  if(!_lines.length) _lines.push(blank());
  var tb=document.getElementById('lbody'), NC=cols();
  tb.innerHTML=_lines.map(function(l,i){
    calcLineSync(l);
    var amt=Math.round(n(l.qty)*n(l.unitPrice)), amt2=Math.round(n(l.qty)*n(l.unitPrice2));
    var lock=!!(l.calc&&n(l.calc.box)>0), lockTip=' title="마진계산 연결 줄 — Box 1 · 수량 = 박스 입수량(자동)" readonly';
    var h='<tr class="mainln"><td>'+(i+1)+'</td>'
      +(function(){   /* 🧮 단추 = 계산 유무 표시 (2026-09-18 「펼치지 말고 있다고 표시만 — 사용자가 펼치게」) : 값 든 계산 = 진한 청록 칠 · 빈 계산 = 옅은 칠 · 없음 = 흰 단추 */
        var hasC=l.calc&&calcHasVal(l.calc);
        return '<td><button class="btn lnk" title="'+(l.calc?(hasC?'저장된 원가·마진 계산 있음 — 누르면 펼침/접힘':'원가·마진 계산(빈 칸) 펼침/접힘'):'원가·마진 계산 붙이기')+'"'
          +(l.calc?(hasC?' style="background:#137a6c;border-color:#137a6c;color:#fff"':' style="background:#e3f2ee;border-color:#0f6b5e"'):'')
          +' onclick="calcToggle('+i+')">🧮</button> <button class="btn lnk" title="이 줄 빼기" onclick="_lines.splice('+i+',1); renderLines()">✕</button></td>'; })()
      +'<td><div style="display:flex;gap:4px"><input type="text" class="nm" value="'+esc(l.prodNm)+'" placeholder="품명" oninput="_lines['+i+'].prodNm=this.value"><button class="btn lnk" style="height:30px" onclick="prodOpen('+i+')" title="우리 상품에서 고르기">🔍</button></div></td>'
      +'<td><input type="text" value="'+esc(l.spec)+'" placeholder="규격 및 재질" oninput="_lines['+i+'].spec=this.value"></td>'
      +'<td><input type="text" class="num'+(lock?' lock':'')+'" id="bv'+i+'" value="'+(n(l.boxQty)?fmt(l.boxQty):'')+'"'+(lock?lockTip:' oninput="_lines['+i+'].boxQty=n(this.value)"')+'></td>'
      +'<td><input type="text" class="num'+(lock?' lock':'')+'" id="qv'+i+'" value="'+(n(l.qty)?fmt(l.qty):'')+'" placeholder="0"'+(lock?lockTip:' onfocus="this.select()" oninput="_lines['+i+'].qty=n(this.value); moqRmkSync('+i+'); calc()"')+'></td>'
      +'<td><input type="text" value="'+esc(l.unit)+'" style="text-align:center" oninput="_lines['+i+'].unit=this.value"></td>'
      +'<td><input type="text" class="num" id="pv'+i+'" value="'+(n(l.unitPrice)?fmt(l.unitPrice,2):'')+'" placeholder="0" onfocus="this.select()" oninput="sellSet('+i+', this.value, \'grid\')" title="'+(l.calc?'판매적용단가 — 아래 계산 칸과 같은 값':'')+'"></td>'
      +'<td class="amt" id="amt'+i+'">'+(amt?fmt(amt):'')+'</td>'
      +(h2?'<td><input type="text" class="num" value="'+(n(l.unitPrice2)?fmt(l.unitPrice2,2):'')+'" placeholder="0" onfocus="this.select()" oninput="_lines['+i+'].unitPrice2=n(this.value); calc()"></td><td class="amt" id="amt2_'+i+'">'+(amt2?fmt(amt2):'')+'</td>':'')
      +'<td><input type="text" id="rv'+i+'" value="'+esc(l.remark)+'" placeholder="예: MOQ 50,000개" oninput="_lines['+i+'].remark=this.value" title="비워 두면 「MOQ n개」가 자동 기재됩니다 — 🧮 계산이 있으면 MOQ수량, 없으면 줄 수량(직접 적으면 그대로)"></td></tr>';
    if(l.calc&&l.calc.open) h+=calcRowHtml(l,i,NC);
    subsOf(l).forEach(function(x,k){
      var samt=Math.round(n(x.qty)*n(x.price));
      h+='<tr class="subln"><td>↳</td><td></td><td class="snm">'+esc(x.nm)+'</td><td></td><td></td>'
        +'<td class="samt" id="sq'+i+'_'+k+'">'+(n(x.qty)?fmt(x.qty):'')+'</td><td>ea</td>'
        +'<td class="samt" id="sp'+i+'_'+k+'">'+(n(x.price)?fmt(x.price):'')+'</td><td class="samt" id="sa'+i+'_'+k+'">'+(samt?fmt(samt):'')+'</td>'
        +(h2?'<td></td><td></td>':'')
        +'<td style="color:#8a98a8">'+(x.use==='cost'?'원가 포함 (단가에 반영 — 합계에 안 더함)':'별도 청구 (마진 0)')+'</td></tr>';
    });
    return h;
  }).join('');
  calc();
}
/* 줄별 원가·마진 계산 칸 — 표본 오택현.xls 식. 판매 단가 이름 = 판매적용단가(종전 「평/용센터」) */
function calcRowHtml(l,i,NC){
  var c=l.calc;
  var ci=function(k,val,d,ph,w){ return '<input type="text" class="ci" style="width:'+(w||84)+'px" value="'+(n(val)?fmt(val,d||0):'')+'" placeholder="'+(ph||'')+'" onfocus="this.select()" oninput="cset('+i+',\''+k+'\', n(this.value))">'; };   /* 폭은 inline 로 못박는다 — table.g input 100% 규칙에 안 밀리게 */
  /* 칸 차례·이름·그룹 = 종전 원가마진계산 표(표본 엑셀) 그대로 — 그룹 머리글 색으로 구분 (2026-09-18 「엑셀처럼 헤더 컬럼 구분 명확하게」) :
       [배송] MOQ수량·단가·금액 | [박스 입수량] | [구매] 구매(계산)·계·운송·보관·소분·박스 | [판매] 판매적용단가·계 | 물류비 | 실 판매금액 | 실 마진금액 | 실 마진율 | 목표·필요 */
  var h='<tr class="crow"><td colspan="'+NC+'"><div style="overflow:auto"><table class="csh">'
    +'<thead><tr>'
    +'<th class="g1" colspan="3">배송</th>'
    +'<th class="g2" rowspan="2">박스<br>입수량</th>'
    +'<th class="g1" colspan="6">구매</th>'
    +'<th class="g7" rowspan="2" title="확인용 메모 칸 — 다른 값과 아무 연관 없이 저장만 됩니다 (2026-09-18)">타겟<br>금액</th>'
    +'<th class="g1" colspan="2">판매</th>'
    +'<th class="g4" rowspan="2">물류비</th>'
    +'<th class="g1" rowspan="2">실 판매금액</th>'
    +'<th class="g1" rowspan="2">실 마진금액</th>'
    +'<th class="g6" rowspan="2">실 마진율</th>'
    +'<th class="g7" rowspan="2">목표<br>마진율(%)</th>'
    +'<th class="g7" rowspan="2">필요<br>판매단가</th>'
    +'<th class="g7" rowspan="2"></th>'
    +'</tr><tr>'
    +'<th>MOQ수량</th><th>단가</th><th>금액</th>'
    +'<th title="개당 구매 = 단가 + 운송 + 보관 + 소분 + 박스 + 원가 포함 품명비/개">구매<span style="font-weight:400;color:#8a98a8">(계산)</span></th><th title="구매 계 = 구매(계산) × 입수">계</th><th>운송</th><th>보관</th><th>소분</th><th>박스</th>'
    +'<th style="color:#0f6b5e" title="= 품목 줄의 단가(같은 값)">판매적용단가</th><th title="판매 계 = 판매적용단가 × 입수">계</th>'
    +'</tr></thead><tbody><tr>'
    +'<td>'+ci('moqQty',c.moqQty,0)+'</td>'   /* 자리표시 팁(MOQ·구매단가·입수·%)은 뺐다 (2026-09-18 「표시 팁 제거」 — 머리글 표가 있어 중복) */
    +'<td>'+ci('buy',c.buy,2)+'</td>'
    +'<td class="au" id="cF'+i+'" title="단가 × MOQ수량"></td>'
    +'<td>'+ci('box',c.box,0)+'</td>'
    +'<td class="au" id="cH'+i+'"></td>'
    +'<td class="au" id="cI'+i+'"></td>'
    +'<td>'+ci('trans',c.trans,2)+'</td>'
    +'<td><span style="display:inline-flex;gap:3px;align-items:center"><input type="text" class="'+(c.storeManual?'cm':'ca')+'" style="width:84px" id="cSt'+i+'" value="'+(c.storeManual&&n(c.store)?fmt(c.store,2):'')+'" onfocus="this.select()" oninput="cset('+i+',\'store\', n(this.value)); _lines['+i+'].calc.storeManual=true" title="기본 = 보관료 × 팔레트 × 개월 ÷ MOQ 수량. 직접 고치면 노란 칸"><button class="btn lnk" style="height:26px;padding:0 5px" onclick="_lines['+i+'].calc.storeManual=false; renderLines()" title="기본식으로 되돌리기">↻</button></span></td>'
    +'<td>'+ci('split',c.split,2)+'</td>'
    +'<td>'+ci('pack',c.pack,2)+'</td>'
    +'<td>'+ci('tgtAmt',c.tgtAmt,0)+'</td>'   /* 타겟금액 — 확인용 저장 전용, 어떤 계산에도 안 들어간다 (2026-09-18) */
    +'<td><input type="text" class="ci" style="width:90px;border-color:#0f6b5e;background:#e3f2ee" id="cSell'+i+'" value="'+(n(l.unitPrice)?fmt(l.unitPrice,2):'')+'" onfocus="this.select()" oninput="sellSet('+i+', this.value, \'calc\')" title="= 품목 줄의 단가(같은 값)"></td>'
    +'<td class="au" id="cO'+i+'"></td>'
    +'<td class="au p" id="cP'+i+'"></td>'
    +'<td class="au q" id="cQ'+i+'"></td>'
    +'<td class="au q" id="cR'+i+'"></td>'
    +'<td class="au s" id="cS'+i+'"></td>'
    +'<td>'+ci('target',c.target,1,'',64)+'</td>'
    +'<td class="au b" id="cNeed'+i+'"></td>'
    +'<td class="c"><button class="btn lnk" style="height:28px" onclick="applyNeed('+i+')" title="필요 판매단가를 판매적용단가(줄 단가)로">→ 적용</button> <button class="btn lnk btn-red" style="height:28px" onclick="calcDrop('+i+')" title="이 줄의 마진계산을 뺀다">계산 빼기</button></td>'
    +'</tr></tbody></table></div>'
    /* 품명비 — 설명 문구는 화면에서 빼고 툴팁으로 (2026-09-18 「표시 제거」). 내용 = 품명+동판+목형 세트 · 서브 줄로 = 품명 밑 별도 청구 줄(마진 0) · 원가 포함 = 금액 ÷ MOQ 수량을 개당 구매에 */
    +'<div class="cex"><b style="color:#125a4e" title="품명 + 동판 + 목형 세트 — 서브 줄로 = 품명 밑 별도 청구 줄(마진 0) · 원가 포함 = 금액 ÷ MOQ 수량을 개당 구매에 더함">품명비</b>';
  /* ★동판·목형 두 줄 고정 세트 (2026-09-17 「부대비 아니고 품명비 · 세 개 세트」) — 자유 추가·이름 입력·✕ 는 뺐다.
     적용 여부는 기존 옵션 그대로(사용자 2026-09-17 「기존 옵션 유지」) : 적용 안 함 / 서브 줄로(별도 청구) / 원가 포함 */
  (c.extras||[]).forEach(function(x,j){
    h+='<span style="display:inline-flex;gap:6px;align-items:center;border:1px solid #dbe2ea;border-radius:8px;padding:4px 8px;background:#fff">'
      +'<b>'+esc(x.nm||('품명비'+(j+1)))+'</b>'
      +'수량 <input type="text" class="num ci" style="width:64px" value="'+(n(x.qty)?fmt(x.qty):'')+'" onfocus="this.select()" oninput="cxset('+i+','+j+',\'qty\', n(this.value))">'
      +'× 단가 <input type="text" class="num ci" style="width:84px" value="'+(n(x.price)?fmt(x.price):'')+'" onfocus="this.select()" oninput="cxset('+i+','+j+',\'price\', n(this.value))">'
      +'= <span class="cv" style="min-width:76px" id="cxa'+i+'_'+j+'"></span>'
      +'<select onchange="cxset('+i+','+j+',\'use\', this.value)" title="적용 여부 — 서브 줄로 = 품명 밑 별도 청구 줄(마진 0) / 원가 포함 = 금액 ÷ MOQ 수량을 개당 구매에 더함"><option value="off"'+(x.use==='off'?' selected':'')+'>적용 안 함</option><option value="sub"'+(x.use==='sub'?' selected':'')+'>서브 줄로(별도 청구)</option><option value="cost"'+(x.use==='cost'?' selected':'')+'>원가 포함</option></select></span>';
  });
  h+='</div></td></tr>';
  setTimeout(function(){ calcPaint(i); },0);
  return h;
}
/* ★원가 포함 품명비의 근거는 견적서 비고 칸에 자동 기재 (2026-09-18 「견적서 비고 칸에 비고」) —
   「동판비 2 × 100,000 = 200,000 — 원가 포함(단가에 반영)」 줄을 우리가 만든 블록(_costRmk)으로 들고 있다가
   값이 바뀌면 그 블록만 갈아 끼운다(사람이 적은 비고는 안 건드림 — deliv 의 _delivRmk 와 같은 요령). calc() 가 부른다 */
var _costRmk='';
function costRmkSync(){
  var parts=[];
  _lines.forEach(function(l){ ((l.calc&&l.calc.extras)||[]).forEach(function(x){ var amt=Math.round(n(x.qty)*n(x.price));
    if(x.use==='cost'&&amt&&(x.nm||'').trim()) parts.push(x.nm+' '+fmt(x.qty)+' × '+fmt(x.price)+' = '+fmt(amt)+' — 원가 포함(단가에 반영)'); }); });
  var blk=parts.join('\n');
  var r=document.getElementById('remark'); if(!r) return;
  var cur=r.value||'';
  if(blk===_costRmk && (!blk || cur.indexOf(blk)>=0)) return;
  if(_costRmk && cur.indexOf(_costRmk)>=0) cur=cur.replace(_costRmk,'').replace(/\s+$/,'');
  if(blk && cur.indexOf(blk)<0) cur=(cur?cur+'\n':'')+blk;
  r.value=cur; _costRmk=blk;
}
function calc(){
  costRmkSync();
  var sum=0, sum2=0, subSum=0, subCnt=0, h2=use2();
  _lines.forEach(function(l,i){ var a=Math.round(n(l.qty)*n(l.unitPrice)), a2=Math.round(n(l.qty)*n(l.unitPrice2)); sum+=a; sum2+=a2;
    var e=document.getElementById('amt'+i); if(e) e.textContent=a?fmt(a):''; var e2=document.getElementById('amt2_'+i); if(e2) e2.textContent=a2?fmt(a2):'';
    subsOf(l).forEach(function(x){ var sa=Math.round(n(x.qty)*n(x.price)); if(!sa) return; subCnt++; if(x.use==='sub') subSum+=sa; });   /* 원가 포함 줄은 합계에 안 더한다(단가에 이미 반영) */
  });
  document.getElementById('tot').innerHTML='품목 <b>'+_lines.filter(function(l){ return (l.prodNm||'').trim()||n(l.qty); }).length+'</b>줄'
    +(subCnt?' + 부대비 <b>'+subCnt+'</b>줄':'')+' · 합계 <b>'+fmt(sum+subSum)+'</b>원'
    +(h2?' · '+esc(gv('p2')||'둘째')+' 합계 <b>'+fmt(sum2)+'</b>원':'')+' (부가세 별도)';
}

/* ── 상품 찾기 (우리 상품 마스터) — 매입·판매등록과 같은 «장부식» 검색 (2026-09-18 「매입등록이나 판매등록 시 검색처럼」 · salesReg saProdRender 와 같은 규칙) :
   ①마스터·매칭코드를 처음 열 때 한 번 통째로 받아 화면에서 거른다(종전 = 글자마다 서버 조회·걸린 것만 표시)
   ②코드·매칭코드 매치(굵은 초록, 코드순)를 앞에 + 그 뒤에 <찾은 코드 다음 코드>의 상품을 이어붙임(장부 넘겨 보기 — 걸린 것만 나오면 이웃 상품을 못 고른다)
   ③이름·규격 매치는 맨 뒤 ④빈 검색 = 앞 200개 ⑤ESC 로 닫기(한글 조합 중 제외) ⑥거래중지는 흐리게 보여 주되 못 고름(숨기면 「있는 코드인데 검색이 안 된다」가 된다) */
var _prodsAll=null, _extItems=[];
function prodMastersLoad(cb){
  if(_prodsAll){ if(cb) cb(); return; }
  Promise.all([
    post('/prod/prodList.do','findData=').then(function(r){ return r.json(); }).catch(function(){ return null; }),
    post('/prod/extItemList.do','').then(function(r){ return r.json(); }).catch(function(){ return null; })
  ]).then(function(a){ _prodsAll=((a[0]&&a[0].data)||[]); _extItems=((a[1]&&a[1].data)||[]); if(cb) cb(); });
}
function prodOpen(i){ _prodRow=i; document.getElementById('prodPop').classList.add('on'); var q=document.getElementById('prodQ'); q.value=(_lines[i]&&_lines[i].prodNm)||''; q.focus(); q.select(); prodRender(); prodMastersLoad(prodRender); }
function prodKey(ev){ if(ev.key==='Escape' && !ev.isComposing) document.getElementById('prodPop').classList.remove('on'); }
function prodSearch(){ clearTimeout(_prodT); _prodT=setTimeout(prodRender, 120); }
function prodRender(){
  var tb=document.getElementById('prodBody');
  if(!_prodsAll){ tb.innerHTML='<tr><td colspan="5" class="dim" style="padding:20px">상품 목록을 불러오는 중…</td></tr>'; return; }
  var q=gv('prodQ').toLowerCase(), hit={}, l;
  if(!q){ l=_prodsAll.slice(0,200); }
  else{
    var byExt={};
    _extItems.forEach(function(e){ if(!e.prodCd) return;
      if([e.extItemCd,e.extItemNm,e.extSpec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) byExt[String(e.prodCd)]=1; });
    var byCd=[], byNm=[];
    _prodsAll.forEach(function(o){
      if(String(o.prodCd||'').toLowerCase().indexOf(q)>=0 || byExt[String(o.prodCd)]) byCd.push(o);
      else if([o.prodNm,o.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) byNm.push(o);
    });
    var byCode=function(a,b){ return String(a.prodCd||'').localeCompare(String(b.prodCd||'')); };
    byCd.sort(byCode);
    if(byCd.length){
      byCd.forEach(function(o){ hit[String(o.prodCd)]=1; });
      var first=String(byCd[0].prodCd||'');
      var after=_prodsAll.filter(function(o){ return !hit[String(o.prodCd)] && String(o.prodCd||'')>first; }).sort(byCode);
      l=byCd.concat(after).concat(byNm).slice(0,200);
    } else l=byNm.slice(0,200);
  }
  tb.innerHTML = l.length ? l.map(function(p,k){
    var stop=p.stopYn==='Y';
    var cd = hit[String(p.prodCd)] ? '<b style="color:#0f6b5e">'+esc(p.prodCd)+'</b>' : esc(p.prodCd);
    return '<tr class="'+(stop?'':'pick')+'"'+(stop?' style="opacity:.45" title="거래중지 상품 — 고를 수 없습니다"':' onclick="prodPick('+k+')"')
      +'><td>'+cd+(stop?' <span style="color:#c0392b;font-size:11px">중지</span>':'')+'</td><td style="text-align:left">'+esc(p.prodNm)+'</td><td style="text-align:left">'+esc(p.spec||'')+'</td><td>'+fmt(p.packQty)+'</td><td style="text-align:right">'+fmt(p.salePrice,2)+'</td></tr>'; }).join('')
    : '<tr><td colspan="5" class="dim" style="padding:20px">없습니다.</td></tr>';
  window._prodRows=l;
}
function prodPick(k){
  var p=(window._prodRows||[])[k], l=_lines[_prodRow], i=_prodRow; if(!p||!l) return;
  /* ★다시 고른 것 = 그 상품을 쓰겠다는 뜻 — 단가·수량(입수량)을 새 상품 값으로 <바로> 바꾼다
     (2026-09-18 「코드를 다시 검색한 거니까」 — 「빈 칸만 채움」·같은 날 잠깐 냈던 확인창 모두 폐기).
     ⚠판매가 0(미등록)이면 단가를 0 으로 — 옛 상품 단가가 남으면 엉뚱한 값이 견적에 나간다(직접 넣으라는 뜻).
     ⚠입수량 미등록(pk≤1)만 수량을 안 건드린다(바꿔 넣을 값 자체가 없다). */
  l.prodNm=p.prodNm||''; l.spec=p.spec||''; l.prodCd=p.prodCd||'';
  var sp=n(p.salePrice), pk=n(p.packQty);
  l.unitPrice=sp;
  if(pk>1){ if(l.calc){ l.calc.box=pk; calcLineSync(l); } else l.qty=pk; }
  document.getElementById('prodPop').classList.remove('on');
  moqRmkSync(i); renderLines(); calc();
}

/* 쌓인 담당자·수신 이름 (2026-09-17) — datalist 로 보여 주고, 새 견적서면 최근 담당자를 기본으로 */
var _names={ mgr:[], recv:[] };
function loadNames(cb){
  post('/mangr/quoteNames.do','').then(function(r){ return r.json(); }).then(function(j){
    _names={ mgr:(j&&j.mgr)||[], recv:(j&&j.recv)||[] };
    document.getElementById('mgrList').innerHTML=_names.mgr.map(function(v){ return '<option value="'+esc(v)+'">'; }).join('');
    document.getElementById('recvList').innerHTML=_names.recv.map(function(v){ return '<option value="'+esc(v)+'">'; }).join('');
    if(cb) cb();
  }).catch(function(){ if(cb) cb(); });
}
/* 배송 조건 (2026-09-17 「직접 작성 시 배송 내용도 추가」) — 표본 견적서처럼 제목 줄 「(센터배송, 부가세 별도)」와 비고 「1. 센터배송」에 넣는다.
   제목 줄은 「(…, 부가세 별도)」 괄호를 바꿔 끼우고, 비고는 비었거나 앞서 넣은 배송 줄 그대로일 때만 바꾼다(사람이 고친 비고는 안 건드린다). */
var _delivPrev='', _delivRmk='';
var DELIV_DEF2='센터배송 / 택배출고 (D2~3)', DELIV_DEF1='센터배송';   /* 양식별 기본 배송 (「이것을 기본으로」) */
function delivTitle(v){ var t=gv('titleTxt')||'아래와 같이 견적을 드립니다.(부가세 별도)'; var par=v?'('+v+', 부가세 별도)':'(부가세 별도)';
  if(/\(.*부가세 별도\)\s*$/.test(t)) return t.replace(/\(.*부가세 별도\)\s*$/, par); return t.replace(/\s*$/,'')+par; }
function delivApply(){
  var v=(gv('deliv')||'').trim(); delivSync();
  document.getElementById('titleTxt').value=delivTitle(v);
  var r=document.getElementById('remark'), cur=(r.value||'').trim();
  var rmk=!v?'':(use2()?v+', 부가세 별도':'1. '+v);   /* 표본 꼴 — 양식1 「1. 센타배송」, 양식2 「배송비 포함, 부가세 별도」 */
  if(cur===''||(_delivRmk&&cur===_delivRmk)) r.value=rmk;   /* 사람이 고친 비고는 안 건드린다 */
  _delivPrev=v; _delivRmk=rmk;
}
function delivPick(v){ if(v==='*'){ var d=document.getElementById('deliv'); d.focus(); d.select(); return; } document.getElementById('deliv').value=v; delivApply(); }
function delivSync(){ var v=(gv('deliv')||'').trim(), sel=document.getElementById('delivSel'), hit=false;   /* 직접 적은 값이 목록에 있으면 그것을, 없으면 「직접 입력…」을 고른 상태로 */
  for(var i=0;i<sel.options.length;i++){ if(sel.options[i].value===v){ sel.selectedIndex=i; hit=true; break; } } if(!hit) sel.value='*'; }
/* 양식을 바꾸면 배송 기본값도 따라간다 — 양식2 「센터배송 / 택배출고 (D2~3)」, 양식1 「센터배송」 (사람이 다르게 적어 둔 값은 그대로) */
function delivOnUse2(){ var d=document.getElementById('deliv'); if(use2()&&d.value===DELIV_DEF1){ d.value=DELIV_DEF2; delivApply(); } else if(!use2()&&d.value===DELIV_DEF2){ d.value=DELIV_DEF1; delivApply(); } else delivApply(); }
function delivFromTitle(t){ var m=/\((.*?),\s*부가세 별도\)\s*$/.exec(t||''); return m?m[1].trim():''; }
/* ── 번호 · 불러오기 ── */
function nextNo(force){
  if(!force && gv('docNo')) return;
  post('/mangr/quoteNextNo.do','quoteDt='+encodeURIComponent(gv('quoteDt'))).then(function(r){ return r.json(); }).then(function(j){ if(j&&j.docNo) document.getElementById('docNo').value=j.docNo; }).catch(function(){});
}
/* 도움말 (2026-09-18 「도움말 버튼으로 1) 견적서작성 2) 원가마진계산」) — 기본 접힘, 탭 둘 */
function helpToggle(){ var b=document.getElementById('qHelp'); b.hidden=!b.hidden; }
function helpTab(k){
  document.getElementById('qhP1').hidden=(k!==1); document.getElementById('qhP2').hidden=(k!==2);
  document.getElementById('qhB1').classList.toggle('on',k===1); document.getElementById('qhB2').classList.toggle('on',k===2);
}
function newDoc(){
  _seq=0; _savedSeq=0; _savedDocNo=''; _lines=[blank()]; document.getElementById('mode').textContent='새 견적서';
  var t=new Date(); document.getElementById('quoteDt').value=t.getFullYear()+'-'+('0'+(t.getMonth()+1)).slice(-2)+'-'+('0'+t.getDate()).slice(-2);
  document.getElementById('docNo').value=''; document.getElementById('mgrNm').value=''; document.getElementById('remark').value='';
  document.getElementById('recvNm').value='삼성웰스토리'; document.getElementById('validTxt').value='견적일로부터 15일'; document.getElementById('titleTxt').value='아래와 같이 견적을 드립니다.(부가세 별도)';
  document.getElementById('use2').checked=true; document.getElementById('p1').value='센터배송'; document.getElementById('p2').value='택배출고 (D2~3)';   /* 기본 = 양식 2 (2026-09-17 「직접 작성 시 이런 내용 포함이 안 됨」) */
  document.getElementById('deliv').value=DELIV_DEF2; _delivPrev=''; _delivRmk=''; delivApply();   /* 배송 기본 → 제목 줄·비고 */
  _cs={ mode:'center', center:(COST.centers[0]?COST.centers[0].nm:''), fee:(window.konetSet?n(konetSet.f('parcelFeeDef')):0) };
  _costRmk='';
  csBarPaint(); renderLines(); nextNo(true);
  loadNames(function(){ var m=document.getElementById('mgrNm'); if(!m.value && _names.mgr.length) m.value=_names.mgr[0]; });   /* 최근 담당자를 기본으로 */
}
function loadDoc(seq){
  post('/mangr/quoteMst.do','quoteSeq='+encodeURIComponent(seq)).then(function(r){ return r.json(); }).then(function(j){
    var m=j&&j.mst; if(!m){ err('견적서를 찾을 수 없습니다.'); newDoc(); return; }
    _seq=seq; _savedSeq=seq; document.getElementById('mode').textContent='수정 — '+m.docNo;
    document.getElementById('docNo').value=m.docNo; document.getElementById('quoteDt').value=d10(m.quoteDt); document.getElementById('recvNm').value=m.recvNm; document.getElementById('mgrNm').value=m.mgrNm;
    document.getElementById('validTxt').value=m.validTxt; document.getElementById('titleTxt').value=m.titleTxt; document.getElementById('remark').value=m.remark;
    /* 근거자료(원가·마진 계산) — CALC_JSON. genRows(서브 줄)는 걷어내고 계산에서 다시 만든다 */
    var cj=null; try{ cj=JSON.parse(m.calcJson||'null'); }catch(e){}
    var h2=(cj&&cj.use2!=null)?!!cj.use2:!!m.price2Nm;   /* 양식 라디오 — 묶음이 정리돼 저장됐어도 근거자료가 기억한다 */
    document.getElementById('use2').checked=h2; document.getElementById('use1').checked=!h2; if(m.price1Nm) document.getElementById('p1').value=m.price1Nm; if(m.price2Nm) document.getElementById('p2').value=m.price2Nm;
    _delivPrev=delivFromTitle(m.titleTxt); _delivRmk=''; document.getElementById('deliv').value=_delivPrev; delivSync();   /* 저장된 제목 줄의 「(…, 부가세 별도)」에서 배송을 읽는다 */
    var gen={}; if(cj&&cj.genRows) cj.genRows.forEach(function(r){ gen[r]=true; });
    _lines=((j&&j.lines)||[]).filter(function(l){ return !gen[l.rowNo]; }).map(function(l){ return { prodNm:l.prodNm, spec:l.spec, boxQty:l.boxQty==null?'':n(l.boxQty), qty:n(l.qty), unit:l.unit||'ea', unitPrice:n(l.unitPrice), unitPrice2:n(l.unitPrice2), remark:l.remark, prodCd:l.prodCd||'', calc:null }; });
    if(cj&&cj.calcs) cj.calcs.forEach(function(c,idx){ if(c&&_lines[idx]){ _lines[idx].calc=normCalc(c); _lines[idx].calc.open=false; } });   /* ★접힌 채 + 🧮 단추 색으로 「있음」 표시만 (2026-09-18 「펼치지 말고 있다고 표시만」 — 같은 날 「다 보이게」를 뒤집음. 펼치기는 🧮) */
    if(cj&&cj.set){ _cs.mode=cj.set.mode||'center'; if(cj.set.center) _cs.center=cj.set.center; _cs.fee=n(cj.set.fee); }
    _costRmk='';   /* 저장된 비고에 이미 든 원가 포함 블록은 costRmkSync 가 그대로 알아본다(중복 안 붙음) */
    _lines.forEach(function(l,i){ moqRmkSync(i); });   /* 옛 저장분(비고 빈 채 저장)도 열면 MOQ 가 채워진다 — 다시 저장하면 인쇄·엑셀에도 나간다 (2026-09-18) */
    csBarPaint(); renderLines();
  }).catch(function(e){ err('불러오지 못했습니다 — '+esc(e.message)); });
}

/* ── 저장 · 출력 · 엑셀 ── */
function payload(){
  var h2=use2();
  _lines.forEach(function(l,i){ moqRmkSync(i); });   /* ★저장 직전에도 한 번 — 비고 빈 줄(동판·목형 안 써도)은 MOQ 수량이 반드시 실려 인쇄·엑셀 비고 칸에 나간다 (2026-09-18) */
  var mains=_lines.filter(function(l){ return (l.prodNm||'').trim()||n(l.qty); });
  var lines=[], calcs=[], genRows=[], no=0;
  mains.forEach(function(l){
    lines.push({ rowNo:++no, prodNm:l.prodNm, spec:l.spec, boxQty:(l.boxQty===''||l.boxQty==null)?null:n(l.boxQty), unit:l.unit, qty:n(l.qty), unitPrice:n(l.unitPrice), amt:Math.round(n(l.qty)*n(l.unitPrice)), unitPrice2:h2?n(l.unitPrice2):null, amt2:h2?Math.round(n(l.qty)*n(l.unitPrice2)):null, remark:l.remark, prodCd:l.prodCd||'' });
    calcs.push(l.calc? { moqQty:n(l.calc.moqQty), buy:n(l.calc.buy), box:n(l.calc.box), trans:n(l.calc.trans), store:n(l.calc.store), storeManual:!!l.calc.storeManual,
      storeVal:(l.calc.storeManual? n(l.calc.store) : storeAuto(l.calc)),   /* 조회용 스냅샷 — 보관 기본값 설정이 나중에 바뀌어도 「그때 계산」이 남게 */
      split:n(l.calc.split), pack:n(l.calc.pack), target:n(l.calc.target), tgtAmt:n(l.calc.tgtAmt), extras:(l.calc.extras||[]).map(function(x){ return { nm:x.nm, qty:n(x.qty), price:n(x.price), use:x.use }; }) } : null);
    subsOf(l).forEach(function(x){ var amt=Math.round(n(x.qty)*n(x.price)); if(!amt) return;
      if(x.use==='sub')
        lines.push({ rowNo:++no, prodNm:x.nm, spec:'', boxQty:null, unit:'ea', qty:n(x.qty), unitPrice:n(x.price), amt:amt, unitPrice2:null, amt2:null, remark:'별도 청구', prodCd:'' });
      else   /* 원가 포함 — 표시용 줄. 단가·금액 0(서버 supplyAmt·인쇄 합산에 안 잡힘 — 0이면 서버가 qty×단가 재계산도 안 한다). 근거 숫자는 견적서 비고 칸에(costRmkSync — 2026-09-18 「견적서 비고 칸에 비고」) */
        lines.push({ rowNo:++no, prodNm:x.nm, spec:'', boxQty:null, unit:'ea', qty:n(x.qty), unitPrice:0, amt:0, unitPrice2:null, amt2:null, remark:'원가 포함 (단가에 반영)', prodCd:'' });
      genRows.push(no); });
  });
  /* ★양식2 인데 둘째 단가를 한 줄도 안 넣었으면 묶음 하나로 저장 (2026-09-17 「없으면 출력하지 말고 선택한 내용만」 — 인쇄·엑셀·목록이 전부 따라온다) */
  var real2 = h2 && lines.some(function(l){ return n(l.unitPrice2)>0; });
  if(h2 && !real2) lines.forEach(function(l){ l.unitPrice2=null; l.amt2=null; });
  var calcJson=JSON.stringify({ v:1, use2:h2, set:{ mode:_cs.mode, center:_cs.center, fee:n(_cs.fee), rate:csRate(), dcRate:n(COST.dcRate) }, calcs:calcs, genRows:genRows });   /* rate·dcRate 도 스냅샷 — 목록 조회가 그때 비율로 다시 그린다(dcRate 없는 옛 저장분 = 그때 규칙 0%) */
  return { confirm: _seq?'Y':'N', docs:[{ docNo:gv('docNo'), quoteDt:gv('quoteDt'), recvNm:gv('recvNm'), mgrNm:gv('mgrNm'), validTxt:gv('validTxt'), titleTxt:gv('titleTxt'), remark:gv('remark'),
    price1Nm: h2?gv('p1'):'', price2Nm: real2?gv('p2'):'', fileNm:'', fileB64:'', calcJson:calcJson, lines:lines }] };
}
function save(){
  var p=payload(), d=p.docs[0];
  if(!d.docNo){ _alertBox('문서번호를 넣으세요.',{icon:'⚠️'}); return; }
  if(!d.quoteDt){ _alertBox('견적일을 고르세요.',{icon:'⚠️'}); return; }
  if(!d.lines.length){ _alertBox('품목을 한 줄 이상 적으세요.',{icon:'⚠️'}); return; }
  var noP=d.lines.filter(function(l){ return !l.qty || !l.unitPrice; });
  var sum=0; d.lines.forEach(function(l){ sum+=l.amt; });
  ask('견적서 <b>'+esc(d.docNo)+'</b>를 저장합니다.<br><span style="font-size:13px;color:#3d4d5c">'+d10(d.quoteDt)+' · '+esc(d.recvNm)+' · '+esc(d.mgrNm)+' · 품목 '+d.lines.length+'줄 · 합계 <b>'+fmt(sum)+'</b>원'+(noP.length?'<br><span style="color:#b45309">⚠ 수량이나 단가가 빈 줄 '+noP.length+'개</span>':'')+'<br><span style="color:#6b7a89">원가·마진 계산 내용은 이 견적서의 근거자료로 함께 저장됩니다.</span></span>', _seq?'덮어쓰기':'저장')
  .then(function(y){ if(!y) return;
    var b=document.getElementById('saveBtn'); b.disabled=true;
    var send=function(conf){ p.confirm=conf?'Y':'N'; return post('/mangr/quoteSave.do', p, true).then(function(r){ return r.text().then(function(t){ return { st:r.status, ok:r.ok, t:t }; }); }); };
    send(!!_seq || (_savedDocNo && _savedDocNo===d.docNo)).then(function(res){
      if(res.st===409) return ask('<b>같은 문서번호</b>가 이미 있습니다.<br><span style="font-size:13px;color:#3d4d5c;white-space:pre-line">'+esc(res.t)+'</span><br><span style="font-size:13px;color:#3d4d5c">덮어쓰면 앞의 것은 이력으로 남습니다. 새 번호로 하려면 [취소] 후 [↻ 번호].</span>','덮어쓰기').then(function(y2){ if(!y2) throw new Error('__cancel'); return send(true); });
      return res;
    }).then(function(res){
      if(!res.ok) throw new Error(res.t);
      var jr={}; try{ jr=JSON.parse(res.t); }catch(e){ var m=/\|(\d+)/.exec(String(res.t)); if(m) jr={ seq:+m[1] }; }
      try{ console.log('quoteSave 응답', res.t); }catch(e){}
      var seq=n(jr.seq); _savedDocNo=d.docNo;
      /* ★번호는 서버에 문서번호로 다시 물어 확정한다 (2026-09-17 「저장 후 출력 시 오류」) — 대체 저장이면 옛 번호는 이력(N)이 되므로
           응답 번호가 비거나 늦게 오면 옛 번호로 인쇄해 「찾을 수 없습니다」가 났다. 확정될 때까지 출력 창을 띄우지 않는다. */
      return post('/mangr/quoteByDoc.do','docNo='+encodeURIComponent(d.docNo)).then(function(r){ return r.json(); }).then(function(j){
        var s2=n(j&&j.quoteSeq); if(s2) seq=s2;
        _seq=seq||_seq; _savedSeq=seq||_savedSeq;
      }).catch(function(){ _seq=seq||_seq; _savedSeq=seq||_savedSeq; });
    }).then(function(){
      document.getElementById('mode').textContent='수정 — '+d.docNo;
      ok('견적서 <b>'+esc(d.docNo)+'</b>를 저장했습니다.<br><span style="font-size:13px;color:#3d4d5c">인쇄는 [🖨 출력], 엑셀은 [📥 엑셀] 단추로.</span>');   /* 저장 뒤 자동으로 출력을 묻지 않는다(2026-09-17 「별도 출력하게」) */
    }).catch(function(e){ if(String(e&&e.message)!=='__cancel') err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
    .then(function(){ b.disabled=false; });
  });
}
function printIt(){ if(!_savedSeq){ _alertBox('먼저 [💾 저장]을 하세요 — 저장된 견적서를 인쇄합니다.',{icon:'ℹ️'}); return; } window.open(CTX+'/mangr/quotePrint.do?quoteSeq='+_savedSeq, '_blank'); }
/* 엑셀 = 서버가 우리 양식 파일(quote_tpl1/2.xls)에 값을 채워 준다 (2026-09-17 「양식 그대로」). 저장된 견적서만.
   ★둘째 묶음을 안 쓴 견적서는 저장 때 price2Nm 이 비므로 양식 1 로 나간다(「엑셀출력도 동일하게」 — 선택한 내용만). 양식엔 합계 줄이 원래 없다. */
function excel(){ if(!_savedSeq){ _alertBox('먼저 [💾 저장]을 하세요 — 저장된 견적서를 양식 그대로 엑셀로 냅니다.',{icon:'ℹ️'}); return; } fileDown(CTX+'/mangr/quoteExcel.do?quoteSeq='+_savedSeq, '견적서.xls'); }
/* 파일 받기 — 새 창(window.open) 대신 이 화면에서 받는다 (2026-09-19 「엑셀 출력 시 화면이 다른 데로 갔다 온다」 — 새 탭이 떴다 닫히며 화면이 튀었다) */
function fileDown(url, fallbackNm){
  fetch(url, {credentials:'same-origin'}).then(function(r){
    if(!r.ok) throw new Error('HTTP '+r.status);
    var cd=r.headers.get('Content-Disposition')||'', nm=fallbackNm||'download';
    var m=/filename\*=UTF-8''([^;]+)/i.exec(cd) || /filename="?([^";]+)"?/i.exec(cd);
    if(m){ try{ nm=decodeURIComponent(m[1]); }catch(e){ nm=m[1]; } }
    return r.blob().then(function(b){
      var a=document.createElement('a'), u=URL.createObjectURL(b);
      a.href=u; a.download=nm; a.style.display='none'; document.body.appendChild(a); a.click();
      setTimeout(function(){ URL.revokeObjectURL(u); a.remove(); }, 1500);
    });
  }).catch(function(e){ _alertBox('파일을 받지 못했습니다 — '+(e&&e.message||e),{icon:'⚠️'}); });
}

/* 시작 — ?quoteSeq= 이면 수정, 아니면 새 견적서.
   ★URL 의 quoteSeq 는 <한 번만> 쓴다 (2026-09-18 「견적서 작성 선택하면 찾을 수 없습니다 발생」) — iframe 은 로그아웃 전까지 그대로라
   URL 에 옛 번호가 남는데, konetShown 이 볼 때마다 다시 불러오면 ①그 견적서를 지운 뒤엔 열 때마다 「찾을 수 없습니다」
   ②[새 견적서]로 작성 중이던 것도 옛 문서로 조용히 덮였다. 같은 번호를 다시 열려면 목록의 [✏ 수정](iframe 재로드)로 온다. */
var _urlSeqDone=false;
(function(){
  var m=/[?&]quoteSeq=(\d+)/.exec(location.search);
  if(m){ _urlSeqDone=true; csBarPaint(); loadNames(); loadDoc(+m[1]); } else newDoc();
})();
document.getElementById('p1').addEventListener('input', renderLines); document.getElementById('p2').addEventListener('input', renderLines);
if(window.konetPopDrag) konetPopDrag('.pop', '.ph');   /* 팝업(상품 찾기·⚙ 센터 비율) 제목줄을 끌어 옮긴다 (2026-09-18) — 발주서와 같은 뼈대·같은 호출 */
window.konetShown=function(){ var m=/[?&]quoteSeq=(\d+)/.exec(location.search); if(m && !_urlSeqDone){ _urlSeqDone=true; loadDoc(+m[1]); } loadNames(); takeHandoff();
  try{ var c=window.konetSet&&konetSet.cost; if(c&&c.centers&&c.centers.length){ COST.centers=c.centers.map(function(x){ return {nm:String(x.nm||''),rate:n(x.rate)}; }); COST.storeFee=n(c.storeFee)||COST.storeFee; COST.storePlt=n(c.storePlt)||COST.storePlt; COST.storeMon=n(c.storeMon)||COST.storeMon; if(c.dcRate!=null) COST.dcRate=n(c.dcRate); csBarPaint(); csPaintAll(); } }catch(e){} };
/* 원가·마진 계산 화면(옛 costCalc — 메뉴에서 내림)이 넘긴 품목 받기 — localStorage konet.costToQuote {ts, lines, deliv}. 10분 안의 것만. */
function takeHandoff(){
  var h=null; try{ h=JSON.parse(localStorage.getItem('konet.costToQuote')||'null'); }catch(e){}
  if(!h || !h.lines || !h.lines.length) return;
  if(Date.now()-n(h.ts)>10*60*1000){ try{ localStorage.removeItem('konet.costToQuote'); }catch(e){} return; }
  var apply=function(){
    try{ localStorage.removeItem('konet.costToQuote'); }catch(e){}
    if(_seq){ newDoc(); }
    _lines=h.lines.map(function(l){ return { prodNm:l.prodNm||'', spec:l.spec||'', boxQty:1, qty:n(l.qty), unit:'ea', unitPrice:n(l.unitPrice), unitPrice2:0, remark:l.remark||'', prodCd:'', calc:null }; });
    if(h.deliv){ var d=document.getElementById('deliv'); if(d){ d.value=h.deliv; delivApply(); } }
    renderLines(); _toast('원가·마진 계산에서 품목 '+_lines.length+'줄을 받았습니다.');
  };
  var typed=_lines.filter(function(l){ return (l.prodNm||'').trim()||n(l.qty); }).length;
  if(typed) _confirmBox({ msg:'원가·마진 계산에서 넘긴 품목 <b>'+h.lines.length+'</b>줄이 있습니다.<br>지금 적힌 줄을 지우고 그것으로 바꿀까요?', icon:'🧮', okText:'바꾸기', onOk:apply, onCancel:function(){} });
  else apply();
}
takeHandoff();
</script>
</body>
</html>
