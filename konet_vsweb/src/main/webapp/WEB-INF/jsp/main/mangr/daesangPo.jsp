<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>대상 발주 등록</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 읽기·쓰기 (전역 XLSX) --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20260910b"></script>   <%-- 표 높이 막대(판매등록과 같은 공용 파일) --%>
<script src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260917"></script>   <%-- 회사 설정(konetSet) — 기본 택배 운임 parcelFeeDef --%>
<!--
  대상 발주 등록 (2026-10-02 신설 — 사용자 「토더처럼 대상이라는 곳에서 이메일로 엑셀을 캡쳐해서 옵니다(토더는 금액은 있는데 대상은 없습니다, 발주일자도 없고),
    캡쳐를 엑셀로 출력 기능도 있어야 함 · 토더처럼 입력하고 저장하는 스타일로 · 나중에 쌓이면 발주일자만 입력 · 매출관리에 대상발주등록 추가 · 저장 후 취소 기능도 · 매출은 토더처럼 발생하게」)
  매출 관리 ▸ 대상 발주 등록. 셸 iframe(logiFrame) 화면. 토더 발주 등록(toderPo.jsp)과 같은 틀.
  · 원본 = 대상(대상주식회사)이 이메일 본문에 넣어 보내는 배송요청 표 : 받는 사람 · 공란 · 주소 · 전화번호1 · 전화번호2 · 수량(ea) · 공란 · 공란 · 제품코드 · 제품명. 금액·발주일자가 없다.
  · 올리는 길 셋 —
      ① 메일의 표를 끌어 복사해(Ctrl+C) 이 화면에 붙여넣기(Ctrl+V) : 글자 그대로 표에 들어간다(HTML 표 · 탭으로 나뉜 글).
      ② 캡쳐 «그림»을 붙여넣거나 파일로 올리기 : 그림 속 글자는 자동으로 못 읽는다 — 그림을 위에 띄워 두고 보면서 아래 표에 친다.
         (같은 날 AI(구글 Gemini) 판독을 붙였다가 사용자 「제미나이는 취소하고 기존 해놓은 대로」로 뺐다.) 그림의 확대·축소는 그림에만 적용한다.
      ③ 엑셀 파일(같은 양식) 올리기 · [＋ 줄 추가]로 직접 치기.
  · 표의 모든 칸을 고칠 수 있다(사용자 「발주일자(납품일자)·품목코드·금액 수정 가능하게」). 발주일자는 위 칸의 날짜가 줄마다 들어가고 [전체 적용]으로 한꺼번에 바꾼다.
  · 품목코드(우리 코드)는 줄마다 넣는다 — 같은 제품명의 빈 칸은 한 번 넣으면 같이 채워지고, 저장하면 (제품명 → 품목코드) 짝이 쌓여 다음부터 자동(/shipout/daesangPoMap.do).
    그래서 쌓이고 나면 발주일자만 넣고 저장하면 된다.
  · 단가 = 고른 품목코드의 상품코드 판매가(매칭코드면 그 주코드의 판매가)를 자동으로 넣고 고칠 수 있다(사용자 확정). 금액 = 수량 × 단가.
  · 저장 = TBL_SHIPOUT_MST — 토더와 같은 종류(PROD_KIND='TD'), 출고장만 「대상」(DC_CD='DAESANG'). 그래서 매출·재고·마감·채권이 토더와 똑같이 선다 :
      저장하면 곧 출고·매출(수량 × 단가), 그 날짜의 재고에서 빠진다. 매출 거래처 = 대상주식회사(물류센터코드 DAESANG — ⛔DDL docs/sql/20261002_daesang_po.sql 먼저).
    사업장 = 위에서 고른 대상 사업장 하나. 받는 사람(학교·지점)은 사업장으로 만들지 않고 줄마다 배송 정보로만 남긴다(사용자 확정).
  · 저장 뒤 : 아래 목록에서 발주일자·품목코드·수량·단가를 고치고(옛 줄을 이력으로 닫고 새 줄을 넣는다), [선택 삭제]로 저장을 취소한다(재고도 다시 맞춘다).
    받는 사람·주소·전화 1·2·제품코드·제품명·택배비도 고칠 수 있다(같은 날 사용자 「저장내용 수정기능」) — 매출·재고와 무관한 칸이라 그 줄만 제자리에서 바로 저장한다(확인창 없이 알림만).
  · 엑셀 저장 = «택배 납기관리»의 엑셀과 같은 양식(머리글 없는 9칸 — 사용자 「엑셀출력은 택배 납기관리에서 엑셀저장처럼 동일하게」) — 올린 표에서도, 저장된 목록에서도 된다.
    (처음엔 「캡쳐처럼 엑셀 저장만 하면 됨」으로 메일 표와 같은 10칸이었다가 같은 날 이것으로 바꿨다.)
  · 택배비 (같은 날 사용자 「기본 택배비는 4500으로 입력 가능하게」) — 줄마다 기본 4,500원(회사 설정의 기본 택배 운임), 칸에서 고칠 수 있고 엑셀의 운임(G) 칸으로 나간다.
    ★DB 에 저장한다(같은 날 사용자 「DB 저장은 없나요」 — TBL_SHIPOUT_MST.RCV_FEE, DDL 같은 파일에 덧붙임) — 저장할 때 줄마다 같이 들어가고,
     저장 목록에서 고치면 그 줄만 바로 저장된다(/shipout/daesangPoFee.do). 매출·재고와는 무관한 값이라 재고를 다시 맞추지 않는다.
     (처음엔 택배 납기관리처럼 화면에서만 쓰는 값이었다.)
    택배 납기관리는 「총수량 × 운임」이지만 대상의 수량은 낱개(ea)라 곱하지 않고 한 줄에 한 번만 넣는다.
  · 같은 표를 두 번 올리면 두 번 들어간다(발주번호가 없다) — 저장 때 같은 줄(날짜·받는 사람·제품명·수량)이 이미 있으면 한 번 더 묻는다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); } .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); } .btn-red{ color:var(--red); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .card .hd label{ font-weight:700; font-size:12.5px; color:#37475a; }
  #upCard.on{ outline:2px dashed var(--teal); outline-offset:-2px; background:#f3faf8; }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:4px 6px; text-align:center; white-space:nowrap; vertical-align:middle; }
  table.g td.l{ text-align:left; } table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g input[type=text], table.g input[type=date]{ height:30px; border:1px solid var(--bd); background:#fff; border-radius:6px; padding:0 6px; font-size:13px; font-family:inherit; }
  table.g input:focus{ border-color:var(--teal); outline:none; }
  table.g input.num{ text-align:right; font-variant-numeric:tabular-nums; }
  /* 품목코드 칸 — 넣어야 하는 칸(주황) · 초록 = 마스터에 있는 코드 · 파랑 = 자동 · 노랑 = 마스터에 없는 코드 (토더 화면과 같은 색) */
  table.g input.cd{ width:170px; border:1.5px solid #e9b98a; background:#fdebd9; }
  table.g input.cd.ok{ border-color:#7cc5b2; background:#f3fbf8; }
  table.g input.cd.auto{ border-color:#9db7e8; background:#eef3fd; }
  table.g input.cd.bad, table.g input.num.bad, table.g input.req.bad{ border-color:#e2b93b; background:#fff7d6; }
  table.g tr.off td{ color:#9aa7b3; background:#fafbfc; }
  .sub{ display:block; font-size:11.5px; color:#6b7a89; margin-top:1px; max-width:230px; overflow:hidden; text-overflow:ellipsis; }
  .sub.warn{ color:var(--amber); }
  .sub.nmf{ font-size:12.5px; color:#1f2a37; font-weight:700; margin:0 0 3px; max-width:260px; }
  .bd{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .bd.auto{ background:#e8eefb; color:#2f4f9a; }
  .dim{ color:#8a98a8; }
  .hd input[type=date], .hd select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; font-family:inherit; background:#fff; }
  .msg{ padding:22px; text-align:center; color:#8a98a8; }
  .note{ font-size:12.5px; color:#6b7a89; padding:8px 12px; line-height:1.6; }
  .x{ border:0; background:none; color:#b0392b; cursor:pointer; font-size:15px; padding:2px 6px; }
  /* 올리는 방법 안내(올린 줄이 없을 때) */
  #howBox{ padding:14px 14px 12px; color:#3d4d5c; font-size:13px; }
  .how-top{ text-align:right; margin-bottom:6px; } .how-top .btn{ height:28px; padding:0 10px; font-size:12px; }
  /* 접힌 모양 — 붙여넣기 자리 한 줄 + [펼치기] */
  #howBox.fold{ display:flex; align-items:center; gap:8px; padding:8px 12px; }
  #howBox.fold .how-top{ order:2; margin:0; }
  #howBox.fold #pasteZone{ flex:1; padding:6px 12px; text-align:left; border-radius:8px; }
  #howBox.fold .pz-ic, #howBox.fold .pz-s, #howBox.fold .how-cards, #howBox.fold .how-steps{ display:none; }
  #howBox.fold .pz-t{ font-size:14px; margin-top:0; }
  #howBox.fold #pasteZone kbd{ font-size:12.5px; min-width:24px; padding:0 6px; border-bottom-width:2px; }
  #pasteZone{ border:2px dashed #b9c7d6; border-radius:12px; background:#f8fafc; padding:20px 12px 18px; text-align:center; cursor:pointer; outline:none; transition:border-color .12s, background .12s; }
  #pasteZone:hover{ border-color:#7fa9a1; background:#f3faf8; }
  #pasteZone:focus{ border-color:var(--teal); border-style:solid; background:#eaf6f3; box-shadow:0 0 0 3px rgba(19,122,108,.14); }
  #pasteZone .pz-ic{ font-size:30px; line-height:1; }
  #pasteZone .pz-t{ font-size:19px; font-weight:800; color:#125a4e; margin-top:6px; }
  #pasteZone .pz-s{ font-size:13px; color:#6b7a89; margin-top:6px; }
  #pasteZone .pz-s b{ color:#37475a; }
  #pasteZone .pz-on{ display:none; } #pasteZone:focus .pz-on{ display:inline; } #pasteZone:focus .pz-idle{ display:none; }
  #pasteZone kbd{ display:inline-block; min-width:30px; padding:1px 8px; border:1px solid #9fb3ae; border-bottom-width:3px; border-radius:6px; background:#fff; font:800 15px/1.5 Consolas,'Malgun Gothic',monospace; color:#125a4e; }
  .how-cards{ display:flex; gap:8px; flex-wrap:wrap; margin-top:10px; }
  .hc{ flex:1 1 220px; display:flex; gap:10px; align-items:center; border:1px solid #b9d6cf; border-radius:10px; background:#f6fbfa; padding:10px 12px; cursor:pointer; }
  .hc:hover{ border-color:var(--teal); background:#eaf6f3; }
  .hc .hc-ic{ font-size:22px; line-height:1.1; }
  .hc b{ display:block; font-size:13.5px; color:#125a4e; }
  .hc span{ display:block; font-size:12px; color:#6b7a89; margin-top:2px; }
  .how-steps{ display:flex; align-items:center; justify-content:center; gap:10px; flex-wrap:wrap; margin-top:11px; font-size:12.5px; font-weight:700; color:#37475a; }
  .how-steps i{ display:inline-block; width:19px; height:19px; line-height:19px; border-radius:50%; background:var(--teal); color:#fff; font-style:normal; font-size:11.5px; text-align:center; margin-right:4px; }
  .how-steps b{ color:#9aa7b3; font-size:15px; }
  /* 캡쳐 그림 — 보면서 입력 */
  #capBox{ display:none; border-bottom:1px solid #eef1f5; padding:8px 12px; background:#fbfcfd; overflow:hidden; min-width:0; }
  #capBox .ct{ display:flex; align-items:center; gap:8px; font-size:12.5px; color:#3d4d5c; margin-bottom:6px; }
  #capScroll{ max-height:260px; max-width:100%; overflow:auto; border:1px solid var(--bd); border-radius:8px; background:#fff; }
  #capScroll.big{ max-height:70vh; }
  #capImg{ display:block; max-width:none; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📦 대상 발주 등록 <small>— 대상의 배송요청 표를 올려 출고·매출로 저장한다. 품목코드는 한 번 넣으면 다음부터 자동으로 채워진다</small></h2>

  <div class="card" id="upCard">
    <div class="hd">올리기
      <button class="btn btn-teal" onclick="document.getElementById('fi').click()" style="margin-left:6px"
        title="엑셀(xlsx · 메일 표와 같은 양식) 또는 캡쳐 그림 파일을 고릅니다. 이 카드 위로 끌어다 놓아도 됩니다.&#10;메일의 표를 복사했으면 파일 없이 이 화면에서 Ctrl+V 만 누르면 됩니다.">📄 파일 선택</button>
      <button class="btn" onclick="addRow(true)" title="빈 줄을 하나 더합니다 — 캡쳐 그림을 보면서 직접 칠 때">＋ 줄 추가</button>
      <button class="btn btn-red" id="btnClear" onclick="pvClearAsk()" title="화면에 올려 둔 줄과 캡쳐 그림을 모두 비웁니다(저장된 것은 그대로)">🧹 전체 비우기</button>
      <label style="margin-left:8px" title="줄마다 들어가는 발주일자(납품일자) = 출고일자. 줄마다 따로 고칠 수도 있습니다">발주일자(납품일자)</label>
      <input type="date" id="dt">
      <button class="btn" onclick="dtAll()" title="위 날짜를 올려 둔 모든 줄에 넣습니다">전체 적용</button>
      <label style="margin-left:8px" title="이 발주를 붙일 대상 사업장 — 받는 사람(학교·지점)은 줄마다 배송 정보로만 남습니다">사업장</label>
      <select id="bizSel" onchange="bizSave()"></select>
      <span class="bar" style="margin-left:auto">
        <span id="pvInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
        <button class="btn" id="btnXls" onclick="pvXls()" style="display:none" title="올려 둔 표를 택배 납기관리의 엑셀과 같은 양식(머리글 없는 9칸)으로 저장합니다(체크한 줄)">📊 엑셀 저장</button>
        <button class="btn btn-teal" id="btnSave" onclick="save()" style="display:none">💾 저장</button>
      </span>
    </div>
    <input type="file" id="fi" accept=".xlsx,.xls,image/*" multiple style="display:none" onchange="onFiles(this.files); this.value=''">
    <div id="capBox">
      <div class="ct"><b>🖼 캡쳐 그림</b> <span class="dim">— 그림을 보면서 아래 표에 넣으세요. 확대·축소는 <b>그림에만</b> 적용됩니다(그림 위에서 Ctrl+휠도 됩니다).</span>
        <span style="margin-left:auto"></span>
        <button class="btn" style="height:28px" onclick="capZoom(-1)" title="그림만 작게">🔍 작게</button><button class="btn" style="height:28px" onclick="capZoom(1)" title="그림만 크게">🔍 크게</button>
        <button class="btn" style="height:28px" onclick="capReset()" title="그림을 원래 크기로">원래 크기</button><span id="capPct" class="dim" style="min-width:42px;text-align:right;font-weight:700">100%</span>
        <button class="btn" style="height:28px" onclick="capTall()" id="capTallBtn">길게 보기</button>
        <button class="btn" style="height:28px" onclick="capClose()">그림 닫기</button></div>
      <div id="capScroll"><img id="capImg" alt="캡쳐"></div>
    </div>
    <%-- 올리는 방법 안내 (2026-10-02 사용자 「이 부분을 직관적으로」 · 「사용자는 무엇인지 헷갈림」) — 설명 글 네 줄을 없애고 할 일만 남겼다 :
         «큰 붙여넣기 자리 + 단추 둘 + 차례 한 줄».
         큰 자리는 눌러서 이 화면을 잡게 한다 — 메뉴를 막 누른 직후에는 글쇠가 바깥(셸)으로 가서 Ctrl+V 가 안 먹기 때문. 잡히면 테두리가 초록으로 바뀌고 글이 「준비됐습니다」로 바뀐다. --%>
    <%-- ★기본은 접힌 한 줄 (2026-10-02 사용자 「기본은 접기」) — 아래 저장 목록이 바로 보이게. 접혀 있어도 그 한 줄을 누르고 Ctrl+V 하면 그대로 붙는다.
         [▼ 펼치기]로 큰 자리·단추·차례를 다시 볼 수 있고, 펼침·접힘은 이 PC 에 기억한다(dsPoHow). --%>
    <div id="howBox" class="fold">
      <div class="how-top"><button class="btn" id="howTgl" onclick="howToggle()" title="붙여넣기 안내를 펼치거나 접습니다">▼ 펼치기</button></div>
      <div id="pasteZone" tabindex="0" title="여기를 한 번 누른 뒤 Ctrl+V 를 누르세요">
        <div class="pz-ic">📋</div>
        <div class="pz-t"><span class="pz-idle">여기를 누르고 <kbd>Ctrl</kbd> + <kbd>V</kbd></span><span class="pz-on">준비됐습니다 — <kbd>Ctrl</kbd> + <kbd>V</kbd> 를 누르세요</span></div>
        <div class="pz-s">메일에서 복사한 <b>표</b>나 <b>캡쳐 그림</b>을 붙여넣으면 아래에 표로 나옵니다</div>
      </div>
      <div class="how-cards">
        <div class="hc" onclick="document.getElementById('fi').click()" title="엑셀(같은 양식)이나 그림 파일을 고릅니다"><div class="hc-ic">📄</div><div><b>파일로 올리기</b><span>엑셀 · 그림 파일을 고릅니다</span></div></div>
        <div class="hc" onclick="addRow(true)" title="빈 줄을 만들고 직접 칩니다"><div class="hc-ic">✏️</div><div><b>직접 입력하기</b><span>빈 줄을 만들어 하나씩 넣습니다</span></div></div>
      </div>
      <div class="how-steps"><span><i>1</i> 붙여넣기</span><b>›</b><span><i>2</i> 발주일자 · 품목코드 넣기</span><b>›</b><span><i>3</i> 💾 저장</span></div>
    </div>
    <div class="tw" id="pvWrap" style="display:none;max-height:56vh">
      <table class="g"><thead><tr>
        <%-- 줄 빼기(✕) 칸은 No 앞에 둔다 (2026-10-02 사용자 「취소코드를 NO 앞으로」) — 맨 오른쪽 끝에 있을 때는 표를 옆으로 밀어야 보였다 --%>
        <th><input type="checkbox" id="pvAll" checked onchange="pvAllChk(this)"></th><th title="✕ = 그 줄을 화면에서 뺍니다(저장된 것과는 무관)">빼기</th><th>No</th>
        <th title="발주일자(납품일자) = 출고일자">발주일자</th><th>받는 사람</th><th>주소</th><th>전화번호1</th><th>전화번호2</th><th>수량(ea)</th><th title="엑셀의 운임 칸으로 나갑니다. 기본 4,500원 — 고칠 수 있고, 비우면 빈 칸으로 나갑니다. [저장]하면 줄마다 같이 저장됩니다">택배비</th>
        <th title="대상의 제품코드(메일 표에 적힌 값 그대로)">제품코드</th>
        <%-- 품목코드를 제품명 앞에 (2026-10-02 사용자 「품목코드가 제품명 앞으로 오게」) — 아래 저장 목록도 같은 차례 --%>
        <th title="우리 품목코드(상품코드) — 한 번 넣으면 같은 제품명의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">품목코드</th>
        <th title="대상의 제품명(메일 표에 적힌 값 그대로) — 이 이름으로 품목코드를 기억합니다">제품명</th>
        <th title="품목코드를 고르면 상품코드의 판매가가 들어갑니다. 고칠 수 있습니다">단가</th><th title="수량 × 단가" style="min-width:110px">금액</th></tr></thead>
        <tbody id="pvBody"></tbody></table>
    </div>
    <div class="note" id="pvNote" style="display:none">· 모든 칸을 고칠 수 있습니다 · 주황 칸(품목코드) = 넣어야 하는 칸 · 파랑 = 지난 저장에서 자동으로 채운 값 · 초록 = 마스터에 있는 코드 · 노랑 = 마스터에 없는 코드(<b>저장 안 됨</b>) 또는 빠진 값 · 발주일자·품목코드·수량이 든 줄만 저장됩니다 · 저장 = 출고·매출(수량 × 단가) + 재고 차감 · 저장한 뒤에도 아래 목록에서 고치거나 취소(삭제)할 수 있습니다</div>
  </div>

  <div class="card">
    <div class="hd">저장된 대상 발주 <small>— 발주일자 기준</small>
      <span class="bar" style="margin-left:auto">
        <input type="date" id="fr"> <span class="dim">~</span> <input type="date" id="to">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn" onclick="lsXls()" title="저장된 줄을 택배 납기관리의 엑셀과 같은 양식(머리글 없는 9칸)으로 저장합니다(체크한 줄 — 체크가 없으면 조회된 전부)">📊 엑셀 저장</button>
        <button class="btn btn-red" onclick="delSel()" title="체크한 줄의 저장을 취소합니다 — 출고·매출에서 빠지고 재고도 다시 맞춥니다">🗑 선택 삭제(저장 취소)</button>
        <span id="lsInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
      </span>
    </div>
    <div class="tw" id="lsWrap" style="max-height:50vh"><table class="g"><thead><tr>
      <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th><th title="고치면 그 줄을 새 날짜로 옮깁니다(재고도 두 날짜 모두 다시 맞춥니다)">발주일자 ✏️</th><th title="고치면 그 줄만 바로 저장됩니다">받는 사람 ✏️</th><th title="고치면 그 줄만 바로 저장됩니다">주소 ✏️</th><th>전화번호1 ✏️</th><th>전화번호2 ✏️</th><th>제품코드 ✏️</th>
      <th title="고르거나 쳐서 바꾸면 이 줄의 품목코드가 바뀌고 재고도 다시 맞춥니다">품목코드 ✏️</th><th title="고치면 그 줄만 바로 저장됩니다. 이 이름으로 품목코드를 기억합니다">제품명 ✏️</th><th title="고쳐서 Enter">수량 ✏️</th><th title="엑셀의 운임 칸으로 나갑니다. 고쳐서 Enter — 그 줄만 바로 저장됩니다">택배비 ✏️</th><th title="고쳐서 Enter. 비면 매출 0">단가 ✏️</th><th title="매출 = 수량 × 단가 — 거래처 대상주식회사" style="min-width:110px">금액</th><th>사업장</th><th>비고</th><th>등록</th></tr></thead>
      <tbody id="lsBody"><tr><td colspan="16" class="msg">[🔍 조회]를 누르세요.</td></tr></tbody></table></div>
  </div>
</div>
<datalist id="prodList"></datalist>

<script>
var CTX='${pageContext.request.contextPath}';
function n(v){ if(v==null) return 0; var x=parseFloat(String(v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return n(v).toLocaleString('ko-KR'); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }); }
/* 응답 = JSON(Map). 문자열로 한 번 더 싸여 올 때도 푼다 */
function pj(r){ return r.text().then(function(t){ var j=null; try{ j=JSON.parse(t); if(typeof j==='string') j=JSON.parse(j); }catch(e){ j=null; }
  if(!j) throw new Error(r.ok?'서버 응답을 읽지 못했습니다.':('서버 오류 ('+r.status+')')); return j; }); }
function ok(m){ _alertBox(m,{icon:'✅'}); } function err(m){ _alertBox(m,{icon:'⚠️'}); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function fmtIn(v){ if(v==null||v==='') return ''; var x=n(v); return String(Math.round(x*100)/100); }

/* ── 기준자료 : 상품 마스터(이름·판매가) · 매칭코드(→ 주코드) · 대상 사업장 · 자동 매칭(지난 저장의 제품명 → 품목코드) ── */
var _prod={}, _price={}, _main={}, _bizNm={}, _map={}, _pv=[], _ls=[], _fileNm='';
function loadMasters(){
  var p1=post('/mangr/clientList.do','findData=').then(function(r){ return r.json(); }).then(function(j){
      var all=((j&&j.data)||[]).filter(function(o){ return o.bizCd; }), ds=all.filter(function(o){ return String(o.bizNm||'').indexOf('대상')>=0; });
      var list=ds.length?ds:all, sel=document.getElementById('bizSel'), keep=sel.value, saved='';
      try{ saved=localStorage.getItem('dsPoBiz')||''; }catch(e){}
      _bizNm={}; sel.innerHTML=list.map(function(o){ _bizNm[String(o.bizCd)]=o.bizNm||''; return '<option value="'+esc(o.bizCd)+'">'+esc((o.bizNm||'')+' ['+o.bizCd+']')+'</option>'; }).join('');
      var want=[keep, saved, 'K0000002'].filter(function(c){ return c && _bizNm[c]!=null; })[0];   /* 기본 = 마지막에 고른 곳 → 대상주식회사(급식) → 첫 줄 */
      if(want) sel.value=want;
    }).catch(function(){});
  var p2=post('/prod/prodList.do','').then(function(r){ return r.json(); }).then(function(j){ _prod={}; _price={}; var h=[];
      ((j&&j.data)||[]).forEach(function(o){ if(!o.prodCd) return; var c=String(o.prodCd); _prod[c]=o.prodNm||''; _price[c]=n(o.salePrice);
        if(o.stopYn!=='Y') h.push('<option value="'+esc((o.prodNm||'')+' ['+c+']')+'"></option>'); });
      document.getElementById('prodList').innerHTML=h.join(''); }).catch(function(){});
  var p3=p2.then(function(){ return post('/prod/extItemList.do',''); }).then(function(r){ return r.json(); }).then(function(j){ _main={};
      ((j&&j.data)||[]).forEach(function(o){ if(!o.extItemCd) return; var c=String(o.extItemCd);
        if(o.prodCd && String(o.prodCd)!==c) _main[c]=String(o.prodCd);
        if(_prod[c]==null) _prod[c]=(o.extItemNm||'')+' 〔매칭코드〕'; }); }).catch(function(){});
  var p4=post('/shipout/daesangPoMap.do','').then(function(r){ return r.json(); }).then(function(j){ _map=(j&&j.item)||{}; }).catch(function(){});
  return Promise.all([p1,p3,p4]).then(function(){ if(_pv.length){ autoFill(); pvRender(); } if(_ls.length) lsRender(); });
}
function bizSave(){ try{ localStorage.setItem('dsPoBiz', document.getElementById('bizSel').value||''); }catch(e){} }
/* 단가 = 그 코드의 상품코드 판매가. 매칭코드(상품으로 따로 등록되지 않은 것)면 그 주코드의 판매가. 없으면 0 */
function priceOf(cd){ cd=String(cd||''); if(_price[cd]>0) return _price[cd]; var m=_main[cd]; return (m && _price[m]>0) ? _price[m] : 0; }
function prodNmOf(cd){ return String(_prod[cd]||'').replace(' 〔매칭코드〕',''); }
/* 기본 택배비 = 회사 설정의 기본 택배 운임(없으면 4,500) — 택배 납기관리(poFeeDef)와 같은 값. 줄마다 한 번(수량을 곱하지 않는다) */
function feeDef(){ var v=Number(window.konetSet ? konetSet.f('parcelFeeDef') : 0); return (isFinite(v) && v>0) ? v : 4500; }
function feeNum(x){ return (x.fee===''||x.fee==null) ? '' : n(x.fee); }   /* 비운 줄은 빈 칸 */


/* ── 읽기 : 표(HTML · 탭 글 · 엑셀) → 줄 ── */
function htmlRows(html){
  var doc=new DOMParser().parseFromString(html,'text/html'), best=null, bn=0;
  Array.prototype.forEach.call(doc.querySelectorAll('table'), function(t){ if(t.querySelector('table')) return;   /* 틀로 쓴 바깥 표는 건너뛴다 */
    var k=t.querySelectorAll('tr').length; if(k>bn){ bn=k; best=t; } });
  if(!best) return [];
  return Array.prototype.map.call(best.querySelectorAll('tr'), function(tr){ var out=[];
    Array.prototype.forEach.call(tr.children, function(td){ if(!/^(TD|TH)$/.test(td.tagName)) return;
      out.push(String(td.textContent||'')); var cs=parseInt(td.getAttribute('colspan'),10)||1; for(var k=1;k<cs;k++) out.push(''); });
    return out; });
}
/* 글 → 칸. 탭이 있으면 탭으로, 없으면 «빈칸 둘 이상»으로 나눈다 (2026-10-02 사용자 「이미지를 텍스트로 했는데 가능할까요」 —
     그림을 글자로 바꿔 주는 도구(글자 인식)는 칸 사이를 빈칸 여러 개로 띄우고 빈 칸 자리에 전각 빈칸(U+3000)을 넣어 준다. 전각 빈칸 하나짜리 칸은 parseRows 가 빈 칸으로 본다) */
function tsvRows(txt){ txt=String(txt||''); var tab=txt.indexOf('\t')>=0;
  return txt.split(/\r?\n/).map(function(l){ return tab ? l.split('\t') : l.replace(/^ +| +$/g,'').split(/ {2,}/); }); }
/* 빈칸으로 나눈 글이 «표»로 보이는가 — 네 칸 이상인 줄이 있을 때만(주소 한 줄을 칸에 붙여넣는 것까지 표로 읽지 않게) */
function looksSpaceTable(txt){ return String(txt||'').split(/\r?\n/).some(function(l){ return l.replace(/^ +| +$/g,'').split(/ {2,}/).length>=4; }); }
var TEL=/^0\d{1,2}[-\s.]?\d{3,4}[-\s.]?\d{4}$/;
function parseRows(aoa){
  aoa=(aoa||[]).map(function(r){ return (r||[]).map(function(c){ return String(c==null?'':c).replace(/ /g,' ').replace(/\s+/g,' ').trim(); }); })
               .filter(function(r){ return r.some(function(c){ return c!==''; }); });
  if(!aoa.length) return [];
  var hr=-1, col={ nm:-1, addr:-1, tel1:-1, tel2:-1, qty:-1, code:-1, item:-1 };
  for(var r=0;r<Math.min(aoa.length,15);r++){ var j=aoa[r].join('|').replace(/\s+/g,'');
    if(/받는|수령|수취/.test(j) && /(제품|품목|상품)명|품명|주소/.test(j)){ hr=r; break; } }
  if(hr>=0){ aoa[hr].forEach(function(c,i){ var t=c.replace(/\s+/g,'');
      if(col.nm<0 && /받는|수령|수취/.test(t)) col.nm=i;
      else if(col.addr<0 && /주소/.test(t)) col.addr=i;
      else if(/전화|연락처|휴대/.test(t)){ if(col.tel1<0) col.tel1=i; else if(col.tel2<0) col.tel2=i; }
      else if(col.qty<0 && /수량/.test(t)) col.qty=i;
      else if(col.code<0 && /(제품|품목|상품)코드/.test(t)) col.code=i;
      else if(col.item<0 && /(제품|품목|상품)명|품명/.test(t)) col.item=i; }); }
  var body=aoa.slice(hr+1), W=0; body.forEach(function(r){ if(r.length>W) W=r.length; });
  var HW=(hr>=0) ? aoa[hr].length : W;   /* 제대로 된 줄의 칸 수 */
  /* 머리 줄이 없으면 열 수로 — 10열 = 메일 표 그대로(공란 셋 포함) · 7열 = 공란을 뺀 것. 그 밖은 줄마다 짐작한다 */
  if(hr<0){ if(W>=10) col={ nm:0, addr:2, tel1:3, tel2:4, qty:5, code:8, item:9 }; else if(W===7) col={ nm:0, addr:1, tel1:2, tel2:3, qty:4, code:5, item:6 }; else col=null; }
  var out=[];
  body.forEach(function(a){
    var g=function(k){ return (col && col[k]>=0 && a[col[k]]!=null) ? a[col[k]] : ''; }, x;
    /* 칸 수가 머리 줄보다 모자라면(글자 인식이 두 칸을 붙였거나 빈 칸을 빠뜨린 줄) 칸 번호로 읽으면 한 칸씩 밀린다 → 전화번호를 기준으로 맞춘다(anchorRow) */
    if(col && a.length<HW && a.some(function(v){ return TEL.test(v); })){ x=anchorRow(a); }
    else if(col){ x={ rcvNm:g('nm'), rcvAddr:g('addr'), rcvTel:g('tel1'), rcvTel2:g('tel2'), qty:n(String(g('qty')).replace(/[^0-9.,]/g,'')), rcvItemCd:g('code'), itemNm:g('item') }; }
    else { x=guessRow(a); }
    if(!x.rcvNm && !x.itemNm && !x.qty) return;
    out.push(x);
  });
  return out;
}
/* 칸이 붙거나 빠진 줄 — 전화번호 칸을 기준으로 앞·뒤를 나눠 맞춘다.
     앞 = 받는 사람·주소(한 칸으로 붙었으면 시·도 이름이 시작하는 자리에서 가른다) · 뒤 = (전화번호2) · 수량 · 제품코드 · 제품명.
     맞춰 넣은 줄은 fix 표시를 달아 화면이 ⚠ 로 알린다(사람이 한 번 본다). */
var REGION=/\s(서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충청[남북]|충[남북]|전라[남북]|전[남북]|경상[남북]|경[남북]|제주)/;
function anchorRow(a){
  var x={ rcvNm:'', rcvAddr:'', rcvTel:'', rcvTel2:'', qty:0, rcvItemCd:'', itemNm:'', fix:true }, t=-1, i;
  for(i=0;i<a.length;i++){ if(TEL.test(a[i])){ t=i; break; } }
  if(t<0) return guessRow(a);
  var nb=function(v){ return v!==''; }, left=a.slice(0,t).filter(nb), right=a.slice(t+1);
  x.rcvTel=a[t];
  if(right.length && TEL.test(right[0])){ x.rcvTel2=right[0]; right=right.slice(1); }
  var r=right.filter(nb);
  for(i=0;i<r.length;i++){ if(/^[\d,]+$/.test(r[i])){ x.qty=n(r[i]); r.splice(i,1); break; } }
  if(r.length>=2){ x.itemNm=r[r.length-1]; x.rcvItemCd=r[r.length-2]; } else if(r.length===1){ x.itemNm=r[0]; }
  if(left.length>=2){ x.rcvNm=left[0]; x.rcvAddr=left.slice(1).join(' '); }
  else if(left.length===1){ var m=REGION.exec(left[0]);
    if(m){ x.rcvNm=left[0].slice(0,m.index).trim(); x.rcvAddr=left[0].slice(m.index).trim(); } else x.rcvNm=left[0]; }
  return x;
}
/* 머리 줄도 없고 열 수도 낯선 줄 — 전화 모양·숫자 모양으로 짐작한다(넣은 뒤 화면에서 고친다) */
function guessRow(a){
  var c=a.filter(function(v){ return v!==''; }), x={ rcvNm:'', rcvAddr:'', rcvTel:'', rcvTel2:'', qty:0, rcvItemCd:'', itemNm:'' }, rest=[];
  c.forEach(function(v){ if(TEL.test(v)){ if(!x.rcvTel) x.rcvTel=v; else if(!x.rcvTel2) x.rcvTel2=v; } else rest.push(v); });
  var nums=[]; rest.forEach(function(v,i){ if(/^[\d,]+$/.test(v)) nums.push(i); });
  if(nums.length){ x.qty=n(rest[nums[0]]); if(nums.length>1) x.rcvItemCd=rest[nums[nums.length-1]]; }
  var txt=rest.filter(function(v,i){ return nums.indexOf(i)<0; });
  if(txt.length){ x.rcvNm=txt[0]; if(txt.length>1) x.itemNm=txt[txt.length-1];
    if(txt.length>2) x.rcvAddr=txt.slice(1,-1).sort(function(p,q){ return q.length-p.length; })[0]; }
  return x;
}
function newRow(x){ x=x||{}; return { chk:true, dlvDt:document.getElementById('dt').value||'', rcvNm:x.rcvNm||'', rcvAddr:x.rcvAddr||'', rcvTel:x.rcvTel||'', rcvTel2:x.rcvTel2||'',
  qty:n(x.qty), rcvItemCd:x.rcvItemCd||'', itemNm:x.itemNm||'', itemCd:'', itemAuto:false, price:'', priceAuto:true, fix:!!x.fix, fee:feeDef() }; }
function addParsed(rows, src){
  if(!rows.length){ err('표에서 읽을 줄을 찾지 못했습니다.<br><span style="font-size:13px">메일 본문의 표를 머리 줄(받는 사람 … 제품명)부터 끝 줄까지 끌어 고른 뒤 복사해 붙여 보세요.</span>'); return; }
  if(src && !_fileNm) _fileNm=src;
  /* 직접 넣으려고 더해 둔 빈 줄은 치운다 */
  _pv=_pv.filter(function(y){ return y.rcvNm||y.rcvAddr||y.itemNm||y.itemCd||y.qty; });
  rows.forEach(function(x){ _pv.push(newRow(x)); });
  autoFill(); pvRender();
  if(window._toast) _toast(rows.length+'줄을 읽었습니다 — 발주일자·품목코드·단가를 확인하고 [저장]','ok');
}
function addRow(focus){ _pv.push(newRow()); pvRender();
  if(focus){ var e=document.querySelector('#pvBody [data-k="'+(_pv.length-1)+':rcvNm"]'); if(e) e.focus(); } }
function onFiles(files){
  var list=Array.prototype.slice.call(files||[]); if(!list.length) return;
  var img=list.filter(function(f){ return /^image\//.test(f.type); }), xl=list.filter(function(f){ return !/^image\//.test(f.type); });
  if(img.length) showImg(img[0]);
  if(!xl.length) return;
  if(!window.XLSX){ err('엑셀 읽기 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  var jobs=xl.map(function(f){ return new Promise(function(res){ var rd=new FileReader();
    rd.onload=function(e){ try{ var wb=XLSX.read(new Uint8Array(e.target.result),{ type:'array' }), rows=[];
        wb.SheetNames.forEach(function(sn){ rows=rows.concat(parseRows(XLSX.utils.sheet_to_json(wb.Sheets[sn],{ header:1, raw:false, defval:'' }))); });
        res({ nm:f.name, rows:rows }); }catch(x){ res({ nm:f.name, rows:[], err:x.message }); } };
    rd.readAsArrayBuffer(f); }); });
  Promise.all(jobs).then(function(rs){ var add=[], bad=[];
    rs.forEach(function(r){ if(r.rows.length) add=add.concat(r.rows); else bad.push(esc(r.nm)+(r.err?' — '+esc(r.err):' — 읽을 줄을 못 찾았습니다')); });
    if(add.length) addParsed(add, rs.map(function(r){ return r.nm; }).join(', '));
    if(bad.length) err('읽지 못한 파일<br><span style="font-size:13px">'+bad.join('<br>')+'</span>'); });
}
/* 캡쳐 그림 — 위에 띄워 두고 보면서 친다. 그림 속 글자는 자동으로 읽지 않는다.
     (2026-10-02 같은 날 AI(구글 Gemini) 판독을 붙였다가 사용자 「제미나이는 취소하고 기존 해놓은 대로」로 뺐다 — 그림은 어디로도 보내지 않는다. 다시 붙이지 말 것)
   ★확대·축소는 «그림에만» (사용자 「이미지 올린 것 확대축소 이미지만 적용되게 — 지금 전체 됨」) :
     [작게][크게][원래 크기] 단추 · 그림 위에서 Ctrl+휠. 그림 너비(px)만 바꾸고, 넘치는 부분은 그림 칸(#capScroll) 안에서 스크롤한다.
     셸의 화면 배율(가+/가-)과 브라우저의 Ctrl+휠은 화면 전체를 키운다 — 그래서 그림 위의 Ctrl+휠은 가로채 그림만 키운다. */
var _capUrl='', _capW=0, _capNat=0;
function showImg(file){
  if(_capUrl){ try{ URL.revokeObjectURL(_capUrl); }catch(e){} }
  _capUrl=URL.createObjectURL(file); var im=document.getElementById('capImg');
  im.onload=function(){ _capNat=im.naturalWidth||600; _capW=_capNat; capApply(); };
  im.src=_capUrl; document.getElementById('capBox').style.display='block';
  if(!_fileNm) _fileNm=file.name||'캡쳐 그림';
  if(!_pv.length){ for(var i=0;i<3;i++) _pv.push(newRow()); }
  pvRender();
  if(window._toast) _toast('캡쳐 그림을 띄웠습니다 — 그림을 보면서 아래 표에 넣으세요. 확대·축소는 그림에만 적용됩니다.','info');
}
function capApply(){ var im=document.getElementById('capImg'), p=document.getElementById('capPct'); if(!_capW) return;
  im.style.width=_capW+'px'; if(p) p.textContent=Math.round(_capW/(_capNat||_capW)*100)+'%'; }
/* d>0 크게 · d<0 작게. step = 한 번에 바꾸는 비율(단추 1.25 · 휠 1.1). 원래 크기의 20% ~ 600% */
function capZoom(d, step){ if(!_capW) return; var f=step||1.25, nat=_capNat||_capW;
  _capW=Math.max(Math.round(nat*0.2), Math.min(Math.round(nat*6), Math.round(_capW*(d>0?f:1/f)))); capApply(); }
function capReset(){ if(!_capNat) return; _capW=_capNat; capApply(); }
function capTall(){ var s=document.getElementById('capScroll'), b=s.classList.toggle('big'); document.getElementById('capTallBtn').textContent=b?'짧게 보기':'길게 보기'; }
function capClose(){ document.getElementById('capBox').style.display='none'; }

/* ── 올린 표 ── */
function autoFill(){ _pv.forEach(function(x){
  if(!x.itemCd && x.itemNm && _map[x.itemNm]){ x.itemCd=_map[x.itemNm]; x.itemAuto=true; }
  if(x.itemCd && x.price==='' && x.priceAuto){ var p=priceOf(x.itemCd); if(p>0) x.price=p; } }); }
function cdCls(cd, auto){ if(!cd) return ''; return _prod[cd]!=null ? (auto?' auto':' ok') : ' bad'; }
function rowReady(x){ return x.chk && x.dlvDt && x.itemCd && n(x.qty)>=1; }
function pvRender(){
  var has=_pv.length>0;
  document.getElementById('howBox').style.display=has?'none':'';
  ['pvWrap','pvNote'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  var pg=document.getElementById('pvWrap').nextElementSibling; if(pg && pg.classList.contains('kgg')) pg.style.display=has?'':'none';   /* 높이 막대도 같이 숨긴다 */
  ['btnSave','btnXls'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  document.getElementById('pvBody').innerHTML=_pv.map(function(x,i){
    var pn=_prod[x.itemCd], k=function(f){ return ' data-k="'+i+':'+f+'"'; }, t=function(f,w,ph){ return '<input type="text"'+k(f)+' style="width:'+w+'px" value="'+esc(x[f])+'" placeholder="'+(ph||'')+'" onchange="pvSet('+i+',\''+f+'\',this)">'; };
    return '<tr class="'+(x.chk?'':'off')+'"><td><input type="checkbox" '+(x.chk?'checked':'')+' onchange="_pv['+i+'].chk=this.checked; pvLater()"></td>'
      +'<td><button class="x" title="이 줄을 화면에서 뺍니다" onclick="pvDel('+i+')">✕</button></td>'
      +(x.fix?'<td style="color:#b45309;font-weight:800;background:#fff7d6" title="원본 글에서 이 줄은 칸이 붙거나 빠져 있어 전화번호를 기준으로 맞춰 넣었습니다 — 받는 사람·주소·수량·제품명을 확인하세요">⚠ '+(i+1)+'</td>':'<td>'+(i+1)+'</td>')
      +'<td><input type="date"'+k('dlvDt')+' class="req'+(x.dlvDt?'':' bad')+'" value="'+esc(x.dlvDt)+'" onchange="pvSet('+i+',\'dlvDt\',this)"></td>'
      +'<td class="l">'+t('rcvNm',150,'받는 사람')+'</td><td class="l">'+t('rcvAddr',300,'주소')+'</td><td>'+t('rcvTel',118,'')+'</td><td>'+t('rcvTel2',118,'')+'</td>'
      +'<td><input type="text"'+k('qty')+' class="num'+(n(x.qty)>=1?'':' bad')+'" style="width:84px" value="'+(x.qty?esc(fmt(x.qty)):'')+'" onchange="pvSet('+i+',\'qty\',this)"></td>'
      +'<td><input type="text"'+k('fee')+' class="num" style="width:68px" value="'+(feeNum(x)===''?'':esc(fmt(x.fee)))+'" title="택배비(엑셀 운임 칸)" onchange="pvSet('+i+',\'fee\',this)"></td>'
      +'<td>'+t('rcvItemCd',64,'')+'</td>'
      +'<td class="l">'+(x.itemCd?'<span class="sub nmf'+(pn==null?' warn':'')+'">'+(x.itemAuto?'<span class="bd auto" title="지난 저장에서 가져온 값">자동</span> ':'')+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span>':'')
        +'<input type="text" list="prodList"'+k('itemCd')+' class="cd'+cdCls(x.itemCd,x.itemAuto)+'" value="'+esc(x.itemCd)+'" placeholder="명칭 또는 코드" onchange="setItem('+i+',this)"></td>'
      +'<td class="l">'+t('itemNm',190,'제품명')+'</td>'
      +'<td><input type="text"'+k('price')+' class="num" style="width:74px" value="'+(x.price===''?'':esc(fmt(x.price)))+'" title="'+(x.priceAuto&&x.price!==''?'상품코드 판매가에서 가져온 값 — 고칠 수 있습니다':'')+'" onchange="pvSet('+i+',\'price\',this)"></td>'
      +'<td class="r" style="min-width:110px"><b id="amt'+i+'">'+fmt(n(x.qty)*n(x.price))+'</b></td></tr>';
  }).join('');
  pvInfo();
}
function pvInfo(){
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(rowReady), unk=rdy.filter(function(x){ return _prod[x.itemCd]==null; }).length;
  var q=0, amt=0, fee=0; rdy.forEach(function(x){ q+=n(x.qty); amt+=n(x.qty)*n(x.price); }); sel.forEach(function(x){ fee+=n(x.fee); });
  document.getElementById('pvInfo').textContent=_pv.length ? ('올린 줄 '+_pv.length+' · 선택 '+sel.length+' · 저장 가능 '+(rdy.length-unk)
    +(sel.length-rdy.length?' · 빠진 값이 있는 줄 '+(sel.length-rdy.length):'')+(unk?' · 마스터에 없는 코드 '+unk+'줄(저장 막힘)':'')+' · 수량 '+fmt(q)+' · 금액 '+fmt(amt)+'원 · 택배비 '+fmt(fee)+'원') : '';
  var a=document.getElementById('pvAll'); if(a) a.checked=_pv.length>0 && _pv.every(function(x){ return x.chk; });
}
/* 다시 그리기 — 칸을 벗어난 뒤(다음 칸으로 옮겨 간 뒤)에 그리고, 옮겨 간 칸을 다시 잡는다(Tab 으로 이어 칠 수 있게) */
function pvLater(){ setTimeout(function(){ var a=document.activeElement, k=(a&&a.getAttribute)?a.getAttribute('data-k'):null; pvRender();
  if(k){ var e=document.querySelector('#pvBody [data-k="'+k+'"]'); if(e){ e.focus(); if(e.type==='text'){ try{ e.select(); }catch(x){} } } } },0); }
function pvSet(i, f, el){
  var x=_pv[i]; if(!x) return; var v=String(el.value||'').trim();
  if(f==='qty'){ x.qty=Math.round(n(v)); el.value=x.qty?fmt(x.qty):''; el.classList.toggle('bad', !(x.qty>=1)); }
  else if(f==='price'){ if(v===''){ x.price=''; } else { x.price=Math.max(0,n(v)); x.priceAuto=false; el.value=fmt(x.price); } el.title=''; }
  else if(f==='fee'){ x.fee=(v===''?'':Math.max(0,Math.round(n(v)))); el.value=(x.fee===''?'':fmt(x.fee)); }
  else if(f==='dlvDt'){ x.dlvDt=v; el.classList.toggle('bad', !v); }
  else if(f==='itemNm'){ x.itemNm=v; if(!x.itemCd && v && _map[v]){ autoFill(); pvLater(); return; } }
  else x[f]=v;
  var a=document.getElementById('amt'+i); if(a) a.textContent=fmt(n(x.qty)*n(x.price));
  pvInfo();
}
/* 목록에서 고른 「명칭 [코드]」 → 코드. 코드만 친 것은 그대로, 명칭만 정확히 친 것은 마스터에서 찾는다 */
function pickCd(v){
  v=String(v||'').trim(); var m=/\[([^\[\]]+)\]\s*$/.exec(v); if(m) return m[1].trim();
  if(_prod[v]!=null) return v;
  var hit=[]; for(var cd in _prod){ if(String(_prod[cd]).trim()===v) hit.push(cd); } return hit.length===1? hit[0] : v;
}
/* 품목코드 — 한 번 넣으면 같은 제품명의 빈 칸(또는 자동으로 채워졌던 칸)에 같이. 단가도 그 코드의 판매가로(손으로 고친 단가는 그대로 둔다) */
function setItem(i, el){
  var x=_pv[i]; if(!x) return; var v=pickCd(el.value), nm=x.itemNm;
  _pv.forEach(function(y){ if(y===x || (nm && y.itemNm===nm && (!y.itemCd || y.itemAuto))){ y.itemCd=v; y.itemAuto=false;
    if(y.priceAuto){ var p=priceOf(v); y.price=(p>0?p:''); } } });
  pvLater();
}
function pvAllChk(el){ _pv.forEach(function(x){ x.chk=el.checked; }); pvRender(); }
function pvDel(i){ _pv.splice(i,1); pvRender(); }
function pvClear(){ _pv=[]; _fileNm=''; capClose();
  if(_capUrl){ try{ URL.revokeObjectURL(_capUrl); }catch(e){} _capUrl=''; _capW=0; _capNat=0; document.getElementById('capImg').removeAttribute('src'); }
  pvRender(); }
/* 전체 비우기 — 올려 둔 줄과 캡쳐 그림을 모두 치운다. 넣어 둔 내용이 있으면 한 번 묻는다(저장된 것은 건드리지 않는다) */
function pvClearAsk(){
  var img=document.getElementById('capBox').style.display==='block';
  var filled=_pv.filter(function(y){ return y.rcvNm||y.rcvAddr||y.rcvTel||y.itemNm||y.itemCd||y.qty; }).length;
  if(!_pv.length && !img){ if(window._toast) _toast('비울 내용이 없습니다.','info'); return; }
  if(!filled){ pvClear(); return; }
  _confirmBox({ icon:'🧹', okText:'비우기', msg:'올려 둔 <b>'+filled+'</b>줄'+(img?'과 캡쳐 그림':'')+'을 모두 비웁니다.<br><span style="font-size:13px;color:#3d4d5c">아직 저장하지 않은 내용은 사라집니다. 아래 「저장된 대상 발주」는 그대로입니다.</span>',
    onOk:function(){ pvClear(); if(window._toast) _toast('비웠습니다','ok'); }, onCancel:function(){} });
}
function dtAll(){ var d=document.getElementById('dt').value; if(!d){ err('발주일자(납품일자)를 고르세요.'); return; }
  if(!_pv.length){ if(window._toast) _toast('올려 둔 줄이 없습니다 — 이 날짜는 앞으로 올리는 줄에 들어갑니다.','info'); return; }
  _pv.forEach(function(x){ x.dlvDt=d; }); pvRender(); if(window._toast) _toast('모든 줄의 발주일자를 '+d+' 로 넣었습니다','ok'); }

/* ── 저장 ── */
function save(){
  var bizCd=document.getElementById('bizSel').value||'', bizNm=_bizNm[bizCd]||'';
  if(!bizCd){ err('사업장(대상)을 고르세요.<br><span style="font-size:13px">목록이 비어 있으면 거래처관리(사업장)에 대상 사업장을 먼저 등록하세요.</span>'); return; }
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(rowReady), miss=sel.length-rdy.length;
  if(!rdy.length){ err('저장할 줄이 없습니다 — 발주일자·품목코드·수량을 넣으세요.'); return; }
  var unk=rdy.filter(function(x){ return _prod[x.itemCd]==null; });
  if(unk.length){ var ui={}; unk.forEach(function(x){ ui[x.itemCd]=1; });
    err('마스터에 없는 품목코드가 든 줄이 <b>'+unk.length+'</b>개 있어 저장하지 않았습니다.<br><span style="font-size:13px">품목코드 : <b>'+esc(Object.keys(ui).join(', '))+'</b> — 상품코드등록·매칭코드에 먼저 등록하거나, 노란 칸을 고치거나 그 줄의 체크를 빼고 다시 저장하세요.</span>'); return; }
  var noPrice=rdy.filter(function(x){ return !(n(x.price)>0); }).length, amt=rdy.reduce(function(s,x){ return s+n(x.qty)*n(x.price); },0);
  var ds={}; rdy.forEach(function(x){ ds[x.dlvDt]=1; }); var dl=Object.keys(ds).sort();
  var body=function(force){ return { bizCd:bizCd, bizNm:bizNm, fileNm:_fileNm||'', force:force?'Y':'',
    rows:rdy.map(function(x){ return { dlvDt:x.dlvDt, rcvNm:x.rcvNm, rcvAddr:x.rcvAddr, rcvTel:x.rcvTel, rcvTel2:x.rcvTel2, qty:x.qty, rcvItemCd:x.rcvItemCd,
      itemNm:(x.itemNm||prodNmOf(x.itemCd)), itemCd:x.itemCd, price:(x.price===''?'':x.price), fee:feeNum(x) }; }) }; };
  var go=function(force){
    var b=document.getElementById('btnSave'); b.disabled=true;
    post('/shipout/daesangPoSave.do', body(force), true).then(pj)
      .then(function(j){
        if(j.error){ err(esc(j.error)); return; }
        if(j.dup){ _confirmBox({ icon:'⚠️', okText:'그래도 저장',
            msg:'이미 저장된 것과 <b>같은 줄이 '+j.dup+'개</b> 있습니다(발주일자·받는 사람·제품명·수량이 모두 같음).<br><span style="font-size:13px;color:#3d4d5c">같은 표를 두 번 올린 것이 아닌지 확인하세요. 그래도 저장하면 두 번 들어갑니다.</span>',
            onOk:function(){ go(true); }, onCancel:function(){} }); return; }
        rdy.forEach(function(x){ if(x.itemNm) _map[x.itemNm]=x.itemCd; });
        _pv=_pv.filter(function(x){ return rdy.indexOf(x)<0; }); if(!_pv.length){ _fileNm=''; } pvRender();
        document.getElementById('fr').value=dl[0]<document.getElementById('fr').value||!document.getElementById('fr').value?dl[0]:document.getElementById('fr').value;
        if(dl[dl.length-1]>document.getElementById('to').value) document.getElementById('to').value=dl[dl.length-1];
        load();
        ok('대상 발주 <b>'+(j.cnt||rdy.length)+'</b>줄을 저장했습니다.'+(_pv.length?'<br><span style="font-size:13px">저장하지 않은 '+_pv.length+'줄이 화면에 남아 있습니다.</span>':'')
          +(j.warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(j.warn)+'</span>':''));
      })
      .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
      .then(function(){ b.disabled=false; });
  };
  _confirmBox({ icon:'💾', okText:'저장',
    msg:'대상 발주 <b>'+rdy.length+'</b>줄을 <b>출고 · 매출</b>로 저장합니다.<br>발주일자 <b>'+esc(dl.length>1?(dl[0]+' ~ '+dl[dl.length-1]):dl[0])+'</b> · 사업장 <b>'+esc(bizNm)+'</b><br>매출 <b>'+fmt(amt)+'</b>원 (수량 × 단가 · 거래처 대상주식회사)'
      +(noPrice?'<br><span style="color:#c0392b;font-size:13px">단가가 빈 줄 '+noPrice+'개 — 매출 0원으로 들어갑니다(저장 뒤 목록에서 고칠 수 있습니다).</span>':'')
      +(miss?'<br><span style="color:#b45309;font-size:13px">발주일자·품목코드·수량이 빠진 '+miss+'줄은 저장하지 않습니다(화면에 남습니다).</span>':'')
      +'<br><span style="font-size:13px;color:#3d4d5c">그 날짜의 재고에서 빠집니다. 저장 뒤 아래 목록에서 고치거나 취소(삭제)할 수 있습니다.</span>',
    onOk:function(){ go(false); }, onCancel:function(){} });
}

/* ── 엑셀 저장 — «택배 납기관리»의 엑셀과 같은 양식 (2026-10-02 사용자 「엑셀출력은 택배 납기관리에서 엑셀저장처럼 동일하게」) ──
     parcelOut.jsp 의 poExcelMake 와 같은 모양 : 머리글 줄 없음 · 9칸 · 시트명 = MMDD(여러 날이면 MMDD-MMDD) · 같은 칸 너비·테두리.
       A = 받는 분 · B = 빈칸 · C = 주소 · D = 전화 · E = 휴대폰(전화번호2) · F = 총수량 · G = 운임 · H = 빈칸 · I = 품목명(대상 제품명)
     ★G(운임) = 화면의 택배비 칸 그대로(기본 4,500 · 고친 줄은 그 값 · 비운 줄은 빈 칸). 택배 납기관리는 「총수량 × 기본 운임」이지만
       대상의 수량은 낱개(ea)라 곱하지 않는다 — 한 줄에 한 번.
     (같은 날 먼저 만든 「메일 표와 같은 10칸 + 머리글」 양식은 이 요청으로 바꿨다. 대상 제품코드 칸은 택배 양식에 없어 빠진다.) */
function xlsOut(rows){
  if(!window.XLSX){ err('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  if(!rows.length){ err('엑셀로 저장할 줄이 없습니다.'); return; }
  var ds=rows.map(function(x){ return d10(x.dlvDt); }).filter(function(v){ return v; }).sort();
  var dt=ds.length?ds[0]:ymd(new Date()), dt2=ds.length?ds[ds.length-1]:dt;
  var mmdd=dt.slice(5,7)+dt.slice(8,10)+(dt2!==dt ? '-'+dt2.slice(5,7)+dt2.slice(8,10) : '');
  var aoa=rows.map(function(x){ return [ x.rcvNm||'', '', x.rcvAddr||'', x.rcvTel||'', x.rcvTel2||'', n(x.qty), feeNum(x), '', x.itemNm||'' ]; });
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  ws['!cols']=[{ wch:24 },{ wch:4 },{ wch:46 },{ wch:14 },{ wch:14 },{ wch:9 },{ wch:8 },{ wch:4 },{ wch:44 }];
  var LINE={ style:'thin', color:{ rgb:'DFE6E3' } }, box={ top:LINE, bottom:LINE, left:LINE, right:LINE };
  var CELL={ alignment:{ vertical:'center' }, border:box }, NUM={ alignment:{ horizontal:'right', vertical:'center' }, border:box };
  for(var r=0;r<aoa.length;r++){ for(var c=0;c<9;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c });
    if(!ws[ref]) ws[ref]={ t:'s', v:'' };          /* 빈 칸도 테두리가 이어지게 */
    ws[ref].s=((c===5 || c===6) ? NUM : CELL); } }   /* F = 총수량 · G = 운임 = 숫자 칸(오른쪽 맞춤) */
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, mmdd);
  XLSX.writeFile(wb, '택배출고_대상_'+dt.replace(/-/g,'')+'.xlsx');
  if(window._toast) _toast('📥 엑셀 생성 — '+rows.length+'줄 (택배 납기관리와 같은 양식)','ok');
}
function pvXls(){ xlsOut(_pv.filter(function(x){ return x.chk && (x.rcvNm||x.rcvAddr||x.itemNm||x.qty); })); }
function lsXls(){ var pick=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) pick.push(x); });
  xlsOut(pick.length?pick:_ls); }

/* ── 저장된 목록 ── */
function load(){
  document.getElementById('lsBody').innerHTML='<tr><td colspan="16" class="msg">조회 중…</td></tr>';
  post('/shipout/daesangPoList.do','frDt='+encodeURIComponent(document.getElementById('fr').value)+'&toDt='+encodeURIComponent(document.getElementById('to').value)).then(pj)
    .then(function(j){ _ls=(j&&j.data)||[]; _ls.forEach(function(x){ x.fee=(x.rcvFee==null ? '' : n(x.rcvFee)); });   /* 택배비 = 저장된 값(없으면 빈 칸) */ if(j&&j.error){ _ls=[]; document.getElementById('lsBody').innerHTML='<tr><td colspan="16" class="msg" style="color:#c0392b">'+esc(j.error)+'</td></tr>'; document.getElementById('lsInfo').textContent=''; return; } lsRender(); })
    .catch(function(e){ document.getElementById('lsBody').innerHTML='<tr><td colspan="16" class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsRender(){
  var tb=document.getElementById('lsBody'); document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="16" class="msg">저장된 대상 발주가 없습니다.</td></tr>'; document.getElementById('lsInfo').textContent=''; return; }
  var q=0, amt=0;
  tb.innerHTML=_ls.map(function(x,i){ q+=n(x.qty); amt+=n(x.qty)*n(x.salePrice); var pn=_prod[x.itemCd];
    /* 글자 칸(배송 정보·제품코드·제품명) = 입력칸 — 고치면 lsInfo 가 그 줄만 바로 저장한다 */
    var ti=function(f,w){ return '<input type="text" style="width:'+w+'px" value="'+esc(x[f])+'" data-v="'+esc(x[f])+'" title="'+esc(x[f])+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsInfo('+i+',\''+f+'\',this)">'; };
    return '<tr><td><input type="checkbox" class="lchk" data-i="'+i+'"></td>'
      +'<td><input type="date" value="'+d10(x.dlvDt)+'" data-v="'+d10(x.dlvDt)+'" onchange="lsEdit('+i+',\'dlvDt\',this)"></td>'
      +'<td class="l">'+ti('rcvNm',150)+'</td><td class="l">'+ti('rcvAddr',300)+'</td><td>'+ti('rcvTel',116)+'</td><td>'+ti('rcvTel2',116)+'</td>'
      +'<td>'+ti('rcvItemCd',60)+'</td>'
      +'<td class="l"><span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span><input type="text" list="prodList" class="cd '+(pn==null?'bad':'ok')+'" value="'+esc(x.itemCd)+'" data-v="'+esc(x.itemCd)+'" onchange="lsEdit('+i+',\'itemCd\',this)">'+(x.prodCd&&x.prodCd!==x.itemCd?'<span class="sub">주코드 '+esc(x.prodCd)+'</span>':'')+'</td>'
      +'<td class="l">'+ti('itemNm',180)+'</td>'
      +'<td class="r"><input type="text" class="num" style="width:84px" value="'+esc(fmtIn(x.qty))+'" data-v="'+esc(fmtIn(x.qty))+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsEdit('+i+',\'qty\',this)"></td>'
      +'<td class="r"><input type="text" class="num" style="width:68px" value="'+(feeNum(x)===''?'':esc(fmt(x.fee)))+'" title="택배비(엑셀 운임 칸) — 고쳐서 Enter. 그 줄만 바로 저장됩니다" data-v="'+(feeNum(x)===''?'':x.fee)+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsFee('+i+',this)"></td>'
      +'<td class="r"><input type="text" class="num'+(x.salePrice==null||x.salePrice===''?' bad':'')+'" style="width:74px" value="'+esc(fmtIn(x.salePrice))+'" data-v="'+esc(fmtIn(x.salePrice))+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsEdit('+i+',\'price\',this)"></td>'
      +'<td class="r" style="min-width:110px"><b>'+fmt(n(x.qty)*n(x.salePrice))+'</b></td>'
      +'<td class="l dim">'+esc(x.bizNm)+'</td>'
      +'<td class="l dim" style="max-width:220px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.remark)+'">'+esc(x.remark)+'</td>'
      +'<td class="dim">'+esc(String(x.uploadDttm||'').slice(0,16))+'<br>'+esc(x.regUser)+'</td></tr>'; }).join('');
  lsInfoUpd();
}
function lsInfoUpd(){ var q=0, amt=0, fee=0; _ls.forEach(function(x){ q+=n(x.qty); amt+=n(x.qty)*n(x.salePrice); fee+=n(x.fee); });
  document.getElementById('lsInfo').textContent=_ls.length+'줄 · 수량 '+fmt(q)+' · 매출 '+fmt(amt)+'원 · 택배비 '+fmt(fee)+'원'; }
/* 저장 목록의 글자 칸(받는 사람·주소·전화 1·2·제품코드·제품명) — 고치면 그 줄만 바로 저장한다(/shipout/daesangPoInfo.do).
     매출·재고와 무관한 칸이라 확인창 없이 저장하고 알림만 띄운다. 실패하면 옛 값으로 되돌린다. 바꾸지 않은 칸은 지금 값을 그대로 보낸다 */
function lsInfo(i, fld, el){
  var x=_ls[i]; if(!x) return; var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/\s+/g,' ').trim();
  var back=function(){ el.value=old; };
  if(v===old){ back(); return; }
  if(fld==='itemNm' && !v){ back(); err('제품명은 비울 수 없습니다.'); return; }
  var b={ seq:x.seq, rcvNm:x.rcvNm||'', rcvAddr:x.rcvAddr||'', rcvTel:x.rcvTel||'', rcvTel2:x.rcvTel2||'', rcvItemCd:x.rcvItemCd||'', itemNm:x.itemNm||'' }; b[fld]=v;
  post('/shipout/daesangPoInfo.do', b, true).then(pj)
    .then(function(j){ if(j.error){ back(); err(esc(j.error)); return; }
      x[fld]=v; el.value=v; el.setAttribute('data-v', v); el.title=v;
      if(fld==='itemNm' && x.itemCd) _map[v]=x.itemCd;   /* 고친 제품명도 다음 붙여넣기의 자동 매칭에 쓴다 */
      if(window._toast) _toast('저장했습니다','ok'); })
    .catch(function(e){ back(); err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}
/* 저장 목록의 택배비 — 고치면 그 줄만 바로 저장한다(/shipout/daesangPoFee.do). 매출·재고와 무관한 값이라 확인창 없이 저장하고 알림만 띄운다. 실패하면 옛 값으로 되돌린다 */
function lsFee(i, el){
  var x=_ls[i]; if(!x) return; var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/,/g,'').trim();
  var back=function(){ el.value=(old===''?'':fmt(old)); };
  if(v!=='' && !/^\d+$/.test(v)){ back(); err('택배비는 숫자로 넣으세요(비우면 빈 칸).'); return; }
  if(v===old){ back(); return; }
  post('/shipout/daesangPoFee.do',{ seq:x.seq, fee:v },true).then(pj)
    .then(function(j){ if(j.error){ back(); err(esc(j.error)); return; }
      x.fee=(v===''?'':n(v)); x.rcvFee=(v===''?null:n(v)); el.setAttribute('data-v', v); el.value=(v===''?'':fmt(v)); lsInfoUpd();
      if(window._toast) _toast('택배비를 저장했습니다','ok'); })
    .catch(function(e){ back(); err('택배비를 저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}
/* 저장된 한 줄 고치기 — 발주일자·품목코드·수량·단가. 바꾼 칸만 새 값, 다른 칸은 지금 값 그대로 보낸다(서버가 옛 줄을 이력으로 닫고 새 줄을 넣는다) */
function lsEdit(i, fld, el){
  var x=_ls[i]; if(!x) return;
  var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/,/g,'').trim(), back=function(){ el.value=old; };
  if(fld==='itemCd') v=pickCd(el.value);
  if(v===old){ back(); return; }
  if(fld==='dlvDt' && !v){ back(); return; }
  if(fld==='qty' && !(/^\d+$/.test(v) && +v>=1)){ back(); err('수량은 1 이상의 정수로 넣으세요.<br><span style="font-size:13px">이 줄을 취소하려면 체크하고 [선택 삭제(저장 취소)]를 누르세요.</span>'); return; }
  if(fld==='price' && v!=='' && !(/^\d+(\.\d+)?$/.test(v))){ back(); err('단가는 숫자로 넣으세요.'); return; }
  if(fld==='itemCd' && (!v || _prod[v]==null)){ back(); err('품목코드 <b>'+esc(v)+'</b> 는 마스터에 없습니다 — 상품코드등록·매칭코드에 먼저 등록하세요.'); return; }
  var b={ seq:x.seq, dlvDt:(fld==='dlvDt'?v:d10(x.dlvDt)), itemCd:(fld==='itemCd'?v:x.itemCd), qty:(fld==='qty'?v:fmtIn(x.qty)), price:(fld==='price'?v:fmtIn(x.salePrice)) };
  var lab={ dlvDt:'발주일자', itemCd:'품목코드', qty:'수량', price:'단가' }[fld];
  _confirmBox({ icon:'✏️', okText:'고치기',
    msg:esc(x.rcvNm||'')+' · '+esc(x.itemNm)+'<br>'+lab+' <b>'+esc(old||'없음')+'</b> → <b>'+esc(v||'없음')+'</b>'+(fld==='itemCd'?' ('+esc(_prod[v])+')':'')
      +'<br><span style="font-size:13px;color:#3d4d5c">매출 '+fmt(n(b.qty)*n(b.price))+'원'+(fld==='price'?'':' · 재고를 다시 맞춥니다')+'. 비고에 수정 기록이 남습니다.</span>',
    onOk:function(){
      post('/shipout/daesangPoRow.do', b, true).then(pj)
        .then(function(j){ if(j.error){ back(); err(esc(j.error)); return; }
          if(fld==='itemCd' && x.itemNm) _map[x.itemNm]=v;
          load();
          if(j.warn) err('고쳤지만 재고 반영에 실패했습니다 — '+esc(j.warn)); else if(window._toast) _toast('고쳤습니다','ok'); })
        .catch(function(e){ back(); err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
    }, onCancel:back });
}
function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function delSel(){
  var seqs=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) seqs.push(x.seq); });
  if(!seqs.length){ err('취소(삭제)할 줄을 고르세요.'); return; }
  _confirmBox({ icon:'🗑', okText:'삭제', msg:'고른 대상 발주 <b>'+seqs.length+'</b>줄의 저장을 취소(삭제)합니다.<br><span style="font-size:13px;color:#3d4d5c">출고·매출에서 빠지고 재고도 다시 맞춥니다. (자동 매칭용 제품명 → 품목코드 짝은 남습니다)</span>',
    onOk:function(){ post('/shipout/daesangPoDelete.do',{ seqs:seqs },true).then(pj)
      .then(function(j){ if(j.error){ err(esc(j.error)); return; } load();
        ok((j.cnt||0)+'줄을 삭제했습니다.'+(j.warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(j.warn)+'</span>':'')); })
      .catch(function(e){ err('삭제하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }, onCancel:function(){} });
}

/* 붙여넣기 안내 펼치기·접기 — 기본은 접힘. 이 PC 에 기억한다 */
function howSet(open){ var b=document.getElementById('howBox'), t=document.getElementById('howTgl');
  b.classList.toggle('fold', !open); t.textContent=open?'▲ 접기':'▼ 펼치기'; }
function howToggle(){ var open=document.getElementById('howBox').classList.contains('fold'); howSet(open);
  try{ localStorage.setItem('dsPoHow', open?'1':'0'); }catch(e){} }

/* ── 붙여넣기 · 끌어다 놓기 · 시작 ── */
(function(){
  /* 붙여넣기 — 표(HTML 표 · 탭으로 나뉜 글)면 줄로 읽고, 그림뿐이면 캡쳐로 띄운다. 칸 안에서 한 칸짜리 글을 붙이는 것은 그대로 둔다 */
  document.addEventListener('paste', function(e){
    var cd=e.clipboardData; if(!cd) return;
    var html=cd.getData('text/html')||'', txt=cd.getData('text/plain')||'', img=null;
    Array.prototype.forEach.call(cd.items||[], function(it){ if(!img && it.kind==='file' && /^image\//.test(it.type)) img=it.getAsFile(); });
    var rows=null;
    if(/<table[\s>]/i.test(html)) rows=parseRows(htmlRows(html));
    if((!rows || !rows.length) && (txt.indexOf('\t')>=0 || looksSpaceTable(txt))) rows=parseRows(tsvRows(txt));   /* 탭 글 · 빈칸으로 띄운 글(그림을 글자로 바꾼 것) */
    if(rows && rows.length){ e.preventDefault(); addParsed(rows,'메일 표 붙여넣기');
      var fx=rows.filter(function(r){ return r.fix; }).length;
      if(fx) err('칸이 붙거나 빠진 줄 <b>'+fx+'</b>개를 전화번호 기준으로 맞춰 넣었습니다.<br><span style="font-size:13px">번호 칸에 <b style="color:#b45309">⚠</b> 가 붙은 줄입니다 — 받는 사람·주소·수량·제품명을 한 번 확인하세요.</span>');
      return; }
    if(img && !txt.trim()){ e.preventDefault(); showImg(img); return; }
    var t=e.target, inInput=t && (t.tagName==='INPUT' || t.tagName==='TEXTAREA');
    if(!inInput && txt.trim()){ err('붙여넣은 내용을 표로 읽지 못했습니다.<br><span style="font-size:13px">메일 본문의 표를 머리 줄(받는 사람 … 제품명)부터 끝 줄까지 끌어 고른 뒤 복사해 붙여 보세요. 그림(캡쳐)이면 그림만 복사해 붙이면 위에 뜹니다.</span>'); }
  });
  /* 그림 위의 Ctrl+휠 = 그림만 확대·축소(브라우저가 화면 전체를 키우지 않게 가로챈다). Ctrl 없이 굴리면 그림 칸 안에서 스크롤 */
  document.getElementById('capScroll').addEventListener('wheel', function(e){ if(!e.ctrlKey) return; e.preventDefault(); capZoom(e.deltaY<0?1:-1, 1.1); }, { passive:false });
  var d=document.getElementById('upCard');
  ['dragenter','dragover'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.add('on'); }); });
  ['dragleave','drop'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.remove('on'); }); });
  d.addEventListener('drop',function(e){ onFiles(e.dataTransfer.files); });
  if(window.konetGridGrip){
    konetGridGrip('pvWrap','pvWrap','daesangPoPv'); konetGridGrip('lsWrap','lsWrap','daesangPoList');
    if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', pvRender); else pvRender();
  }
  try{ howSet(localStorage.getItem('dsPoHow')==='1'); }catch(e){ howSet(false); }
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth(), t.getDate()-30);
  document.getElementById('dt').value=ymd(t);
  document.getElementById('fr').value=ymd(a); document.getElementById('to').value=ymd(t);
  loadMasters();
  grabFocus();
})();
/* 이 화면이 보일 때 글쇠를 이 화면으로 가져온다 — 메뉴를 누른 직후에는 글쇠가 바깥(셸)에 있어 Ctrl+V 가 안 먹는다(접혀 있어도 바로 붙여넣을 수 있게).
   입력칸에 커서가 있으면 건드리지 않는다 */
function grabFocus(){ try{ var a=document.activeElement; if(a && (a.tagName==='INPUT' || a.tagName==='SELECT' || a.tagName==='TEXTAREA')) return; window.focus(); }catch(e){} }
window.konetShown=function(){ loadMasters(); grabFocus(); };   /* 다른 화면에서 상품·사업장을 고치고 돌아오면 새로 */
</script>
</body>
</html>
