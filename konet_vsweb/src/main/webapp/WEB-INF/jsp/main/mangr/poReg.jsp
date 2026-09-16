<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>발주서 관리</title>
<!--
  발주서 관리 (2026-09-03 신설) — 매입 관리 ▸ 발주서 관리. 사이드바 iframe(logiFrame) 화면.
  · 거래처에 보낼 발주서를 등록/수정/삭제 · 🖨 인쇄(poPrint.jsp) · 📥 엑셀 · 💬 카톡 공유 · 🔗 링크 복사
  · 카톡 공유 = 카카오 JavaScript SDK 「공유하기」 카드(제목·설명·[웹페이지로 보기]) → 공개 주소 /pub/po.do?t=토큰 (로그인 없이 읽기만)
      키 = src/main/resources/kakao.properties 의 kakao.js.key (Kakao Developers 앱의 JavaScript 키, 플랫폼 Web 에 이 사이트 도메인 등록 필요)
      키가 없거나 SDK 를 못 불러오면 「🔗 링크 복사」로 주소를 카톡에 붙여 넣는다(카드 미리보기는 og: 태그로 뜬다).
  · 매입전환은 예정(버튼만) — 매입 등록 화면과 연결 규칙을 정한 뒤 붙인다.
  · 표: TBL_PO_MST / TBL_PO_DTL — 매입전표와 별개. 재고에는 영향이 없다.
-->
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260911"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js?v=20260911"></script>
<%-- 칸 폭 조절 — 머리글 오른쪽 경계를 끌면 그 칸이 늘고 준다(더블클릭 = 처음 폭으로).
     표에 data-colrz="이름" 만 주면 걸린다. 폭은 localStorage 에 남아 다음에도 그대로. --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-colresize.js?v=20260907"></script>
<%-- 팝업 창 끌어 옮기기 (2026-09-10 「발주서 팝업도 움직이게」) — 판매·매입등록과 같은 공용 파일.
     이 화면 팝업은 제목줄 이름이 .ph 라 둘째 인자로 알려 준다. 제목줄을 잡고 끈다 · 더블클릭 = 처음 자리 --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-popdrag.js?v=20260910b"></script>
<%-- 명세 표 높이 막대 (2026-09-10 「발주서 표도 높이 조절 막대」) — 판매·매입등록과 같은 공용 파일.
     표 바로 밑 막대를 아래로 끌면 늘고 위로 끌면 준다 · [▲ 줄이기][▼ 늘리기] · 더블클릭 = 처음(38vh 까지 저절로) · 높이 기억.
     이 화면은 합계줄이 표 안(tfoot)이라 막대를 표 상자 바로 뒤에 붙인다(둘째 인자 = 표 상자 자신). --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20260910b"></script>
<%-- 아래 발주서 목록 표에도 같은 막대 (2026-09-10 「발주서 목록 표에도 높이 막대」) — 높이는 표마다 따로 기억한다(poReg / poRegList) --%>
<script type="text/javascript">konetPopDrag('.pop', '.ph'); konetGridGrip('poGridWrap', 'poGridWrap', 'poReg'); konetGridGrip('poListWrap', 'poListWrap', 'poRegList');</script>
<%-- 전송이력 — 발주서를 <누구에게 · 어떤 방법으로> 보냈는지 남기고 보여 준다 (2026-09-10).
     판매등록 거래명세표와 **같은 파일·같은 표**를 쓴다(docGb 로만 갈린다). --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/send-hist.js?v=20260910f"></script>
<script src="https://t1.kakaocdn.net/kakao_js_sdk/2.7.4/kakao.min.js" crossorigin="anonymous"></script>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:10px; font-size:12.5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:10px 12px; margin-bottom:12px; }
  .hd{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
  .hd label{ font-weight:700; color:#37475a; }
  .hd input[type=date], .hd input[type=text], .hd select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; }
  .hd input[readonly]{ background:#f4f6f8; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn.teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn.red{ background:#c0392b; color:#fff; border-color:#c0392b; }
  .btn.blue{ background:#1f6fb3; color:#fff; border-color:#1f6fb3; }
  .btn.kakao{ background:#fee500; color:#191919; border-color:#f2d900; }
  .btn:disabled{ opacity:.45; cursor:default; }
  .gridwrap{ overflow:auto; border:1px solid var(--bd); border-radius:8px; max-height:38vh; }
  /* ↑ 기본은 줄 수만큼 자라다 38vh 에서 멈춘다. 높이 막대(ui-gridgrip.js, 2026-09-10)로 고르면 그 높이로 고정되고
       이 max-height 도 풀린다(창의 92% 까지) · 막대 더블클릭 = 이 기본 모양으로 */
  table.g{ border-collapse:collapse; width:100%; font-size:13.5px; white-space:nowrap; }
  table.g th{ background:#dfeaf5; color:#1f2a37; border:1px solid var(--bd); padding:6px 6px; position:sticky; top:0; z-index:2; font-weight:800; }
  table.g td{ border:1px solid var(--bd); padding:2px 4px; text-align:right; height:30px; }
  table.g td.c{ text-align:center; } table.g td.l{ text-align:left; }
  table.g input{ width:100%; border:0; background:transparent; font-size:13.5px; padding:4px 2px; text-align:right; }
  table.g input.l{ text-align:left; }
  table.g input:focus{ outline:2px solid #bfe3dc; border-radius:3px; }
  table.g td.ro{ background:#fafbfc; color:#37475a; }
  /* 현재고·적정·최근발주 칸 (2026-09-16) — 빨강 = 적정재고 미달·0 이하 / 14일 안 발주(아직 매입 안 됨). 팝업의 현재고 칸도 같은 색 */
  table.g td.rcnt{ font-size:12px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:190px; }
  table.g td.rcv{ font-size:12px; white-space:nowrap; }
  table.g td.stk.low, table.g td.rcnt.warn, table.g td.pend.warn, .pb td.low{ color:#c0392b; font-weight:800; background:#fff5f5; }
  table.g td .low, .pb td .low{ color:#c0392b; font-weight:800; }
  table.g td .dim, .pb td .dim{ color:#8a98a8; font-weight:400; }
  table.g td input.vpc{ background:#fff8dc; }   /* 단가 — 이 거래처보다 싼 곳이 있다(P2-b, 툴팁에 어디·얼마) */
  table.g tr.tot td{ background:#e2efda; font-weight:800; color:#375623; }
  table.g .lnk{ color:var(--teal); text-decoration:underline; cursor:pointer; }
  table.g .del{ color:#c0392b; cursor:pointer; font-weight:800; }
  table.g input.pin::placeholder{ color:#9aa7b3; font-weight:400; }   /* 빈 줄 코드 칸 입력검색 (2026-09-10) */
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:10px; }
  .bar .cnt{ color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; }
  .bar .cnt b{ color:var(--teal); }
  .listwrap{ overflow:auto; border:1px solid var(--bd); border-radius:8px; max-height:max(200px,30vh); }
  /* ↑ 발주서 목록도 높이 막대(ui-gridgrip.js, 2026-09-10) — 고르면 그 높이로 고정되고 이 max-height 가 풀린다 · 더블클릭 = 이 기본 모양 */
  table.lst{ border-collapse:collapse; width:100%; font-size:13.5px; white-space:nowrap; }
  table.lst th{ background:#b9ded4; color:#0b4f43; border:1px solid var(--bd); padding:7px 8px; position:sticky; top:0; font-weight:800; }
  table.lst td{ border:1px solid var(--bd); padding:6px 8px; text-align:center; }
  table.lst td.r{ text-align:right; } table.lst td.l{ text-align:left; }
  table.lst tr{ cursor:pointer; } table.lst tr:hover td{ background:#f3f8f6; } table.lst tr.on td{ background:#fdeef0; font-weight:700; }
  .empty{ padding:22px; text-align:center; color:#9aa7b3; }
  /* 팝업(거래처·상품) */
  .pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:200; }
  .pop.on{ display:block; }
  .pop .box{ background:#fff; width:min(900px,96vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.25); }
  .pop .ph{ padding:12px 16px; border-bottom:1px solid var(--bd); font-weight:800; display:flex; gap:8px; align-items:center; }
  .pop .ph input{ flex:1; height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; }
  .pop .pb{ padding:0 16px 12px; overflow:auto; }
  .pop table{ width:100%; border-collapse:collapse; font-size:13px; }
  .pop th{ background:#eef3f2; border:1px solid var(--bd); padding:6px 8px; position:sticky; top:0; }
  .pop td{ border:1px solid var(--bd); padding:6px 8px; text-align:center; }
  .pop td.l{ text-align:left; } .pop td.r{ text-align:right; }
  .pop tr.pick{ cursor:pointer; } .pop tr.pick:hover td{ background:#f3f8f6; }
  .pop tr.sel td{ background:#eaf5f1; }
  .pop td.ck, .pop th.ck{ padding:4px; }
  .pop td.ck input, .pop th.ck input{ width:16px; height:16px; cursor:pointer; vertical-align:middle; }
  .pop .pf{ padding:10px 16px; border-top:1px solid var(--bd); text-align:right; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📋 발주서 관리</h2>
  <div class="sub">거래처에 보낼 <b>발주서</b>를 만듭니다 — 저장 후 <b>🖨 인쇄</b>·<b>📥 엑셀</b>·<b>💬 카톡 공유</b>(받는 쪽은 로그인 없이 발주서만 봅니다). 매입전표·재고와는 별개입니다.</div>

  <div class="card">
    <div class="hd">
      <label>발주일자</label><input type="date" id="poDt" onchange="poDtChanged()">
      <label>번호</label><input type="text" id="poNo" readonly style="width:64px; text-align:center">
      <label>거래처</label><input type="text" id="venNm" placeholder="거래처명 입력·선택" style="width:220px" autocomplete="off">
      <button class="btn" onclick="venOpen()">거래처</button>
      <label>담당자</label><input type="text" id="mgrNm" value="${sessionScope.s_user_nm}" readonly style="width:110px">
      <span id="stat" style="margin-left:auto; color:#6b7a89; font-size:12.5px"></span>
    </div>
    <div class="gridwrap" id="poGridWrap" style="margin-top:10px">
      <%-- ★[2026-09-10] 삭제 칸을 맨 끝 → # 바로 뒤로 옮기면서 칸 폭 보관 이름을 poReg-grid → poReg-grid2 로 바꿨다.
           칸 수(17)는 그대로라 옛 이름을 두면 저장된 폭이 한 칸씩 밀려 엉뚱한 칸에 걸린다(ui-colresize 는 칸 수만 본다). --%>
      <table class="g" id="grid" data-colrz="poReg-grid3"><%-- grid2→grid3 : 칸이 3개 늘어 저장된 칸 폭이 어긋나므로 키를 올렸다(2026-09-16) --%>
        <thead><tr>
          <th style="width:36px">#</th><th style="width:40px" title="이 줄 삭제">삭제</th><th style="width:112px" title="빈 줄은 코드·상품명을 직접 쳐서 고릅니다 (↑↓·Enter) — 🔍 = 상품 선택 팝업">코드</th><th style="min-width:230px">상품명</th><th style="width:130px">규격</th>
          <%-- 현재고·적정·최근발주 (2026-09-16 「재고 파악이 안 돼 중복 발주」) — 발주하는 순간 보이게. 빨강 = 적정 미달 / 14일 안 발주(아직 매입 안 됨) --%>
          <th style="width:70px" title="재고 원장 합(품목별재고현황과 같은 숫자). 적정재고 미달·0 이하면 빨강">현재고</th><th style="width:56px" title="상품마스터의 적정재고(SAFE_STOCK). 없으면 —">적정</th><th style="width:170px" title="이 품목의 가장 최근 다른 발주서 — 며칠 전 · 수량 · 거래처. 14일 안이고 아직 매입전환이 안 됐으면 ⚠ 빨강(중복 발주 확인)">최근발주</th>
          <%-- 미입고·입고 (2026-09-16 P1-b) — 미입고 = 다른 발주서에서 아직 안 들어온 수량(입고예정) · 입고 = 이 줄의 기입고/잔량 + [마감] --%>
          <th style="width:60px" title="이 품목을 다른 발주서에서 발주했는데 아직 안 들어온 수량(입고예정). 있으면 빨강 — 또 발주하기 전에 확인">미입고</th><th style="width:110px" title="이 줄의 기입고 · 잔량(저장된 발주서만). [마감] = 더 안 들어온다 — 잔량을 미입고에서 뺍니다">입고</th>
          <th style="width:56px">입수</th><th style="width:70px">BOX</th><th style="width:70px">EA</th><th style="width:78px">합계수량</th>
          <th style="width:90px">단가</th><th style="width:100px">금액</th><th style="width:76px">DC</th><th style="width:100px">공급가</th>
          <th style="width:86px">부가세</th><th style="width:104px">매입금액</th><th style="width:60px">서비스</th><th style="width:140px">비고</th>
        </tr></thead>
        <tbody id="gbody"></tbody>
        <tfoot><tr class="tot" id="trow"></tr></tfoot>
      </table>
    </div>
    <div class="hd" style="margin-top:8px">
      <label>비고</label><input type="text" id="remark" style="flex:1; min-width:300px" placeholder="발주서에 찍히는 비고">
    </div>
    <div class="bar">
      <button class="btn teal" onclick="poSave()">💾 발주서 저장</button>
      <button class="btn red" id="btnDel" onclick="poDelete()" disabled>🗑 삭제</button>
      <button class="btn" onclick="poNew()">＋ 새 발주서</button>
      <%-- 추천 발주 (2026-09-16 P1-c 후반) — 적정재고에 못 미치는 품목을 한 번에 담는다.
           ★막지 않는다 : 추천일 뿐이고 수량은 담은 뒤 얼마든 고친다(사용자 원칙 「메시지 처리」). --%>
      <button class="btn" id="btnShort" onclick="shOpen()" title="「현재고 + 입고예정」이 적정재고에 못 미치는 품목을 보여 줍니다. 골라서 담으면 부족한 만큼 수량이 채워집니다.">⚠ 추천 발주</button>
      <span style="width:8px"></span>
      <button class="btn" id="btnPrint" onclick="poPrint()" disabled>🖨 발주서 인쇄</button>
      <button class="btn" id="btnXls" onclick="poExcel()" disabled>📥 엑셀</button>
      <button class="btn kakao" id="btnKakao" onclick="poKakao()" disabled>💬 카톡 공유</button>
      <button class="btn" id="btnLink" onclick="poCopyLink()" disabled>🔗 링크 복사</button>
      <%-- 전송이력 (2026-09-10) — 저장 전에도 열린다(그때는 「전체 이력」 탭만) --%>
      <button class="btn" id="btnHist" onclick="poSendHist()" title="이 발주서를 언제·누구에게·어떤 방법으로 보냈는지 봅니다.&#10;[전체 이력] 탭에서는 기간으로 모든 발주서의 전송을 훑어볼 수 있습니다.">📨 전송이력</button>
      <button class="btn blue" id="btnCv" style="margin-left:auto" onclick="cvOpen()" disabled>📦 매입전환</button>
    </div>
  </div>

  <div class="card">
    <div class="hd">
      <label>조회기간</label><input type="date" id="frDt" data-range-to="toDt"> <span style="color:#8a98a8">~</span> <input type="date" id="toDt">
      <label>거래처</label><input type="text" id="findNm" placeholder="거래처명" style="width:180px" onkeydown="if(event.key==='Enter') poLoad()">
      <button class="btn teal" onclick="poLoad()">🔍 리스트 조회</button>
      <span class="cnt" id="cnt">-</span>
    </div>
    <div class="listwrap" id="poListWrap" style="margin-top:8px">
      <table class="lst" data-colrz="poReg-list"><thead><tr><th>발주일자</th><th>번호</th><th>거래처명</th><th>담당</th><th>품목</th><th>수량</th><th>공급가액</th><th>부가세</th><th>합계</th><th>공유</th><th title="입고 현황(2026-09-16) — 미입고 / 부분 입고수량/발주수량 / ✔ 완료 / 마감. 줄마다 연결된 매입 명세로 센다">입고</th><th>등록자</th></tr></thead>
      <tbody id="lbody"><tr><td colspan="12" class="empty">기간을 고르고 [리스트 조회]를 누르세요.</td></tr></tbody></table>
    </div>
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="pop" id="venPop"><div class="box">
  <div class="ph">거래처 선택 <input type="text" id="venQ" placeholder="거래처명·코드·사업자번호" oninput="venRender()"><button class="btn" onclick="venClose()">닫기</button></div>
  <div class="pb"><table><thead><tr><th style="width:90px">코드</th><th>거래처명</th><th style="width:110px">대표</th><th style="width:120px">전화</th><th style="width:130px">사업자번호</th></tr></thead><tbody id="venBody"></tbody></table></div>
</div></div>
<!-- 상품 선택 팝업 — ☑ 로 여러 개를 한 번에 담는다(2026-09-07). 줄을 그냥 누르면 종전대로 한 개만 담고 닫힌다. -->
<div class="pop" id="prodPop"><div class="box">
  <div class="ph">상품 선택 <input type="text" id="prodQ" placeholder="코드·상품명·규격" oninput="prodRender()"><button class="btn" onclick="prodClose()">닫기</button></div>
  <div class="pb"><table><thead><tr><th class="ck" style="width:38px"><input type="checkbox" id="prodAll" onclick="prodAllToggle(this.checked)" title="이 목록 전체 선택"></th><th style="width:100px">코드</th><th>상품명</th><th style="width:150px">규격</th><th style="width:56px">입수</th><th style="width:70px" title="재고 원장 합 — 적정재고 미달·0 이하면 빨강 (2026-09-16)">현재고</th><th style="width:90px" title="상품마스터 매입가 — 담을 때 단가로 들어갑니다">매입단가</th><th style="width:150px" title="최근 6개월 매입 단가 이력에서 가장 싼 거래처 (P2-b 2026-09-16). 마스터 매입가보다 싸면 빨강 — 발주하기 전에 어디서 살지 보라고">최저 거래처</th><th style="width:60px">과세</th></tr></thead><tbody id="prodBody"></tbody></table></div>
  <div class="pf" style="display:flex; align-items:center; gap:8px; text-align:left">
    <span id="prodSelInfo" style="margin-right:auto; color:#6b7a89; font-size:12.5px">여러 개는 왼쪽 <b>☑</b> 로 고른 뒤 [담기] — 줄을 누르면 한 개만 담고 닫힙니다.</span>
    <button class="btn" id="prodSelClr" onclick="prodSelClear()" disabled>선택 해제</button>
    <button class="btn teal" id="prodSelAdd" onclick="prodAddSel()" disabled>선택한 0개 담기</button>
  </div>
</div></div>

<!-- 추천 발주 (2026-09-16 P1-c 후반) — 적정재고 미달 품목. 상품 선택 팝업과 같은 틀·같은 담기 경로(prodFill) -->
<div class="pop" id="shPop"><div class="box" style="width:min(1180px,97vw)">
  <div class="ph">⚠ 추천 발주 <span id="shSub" style="font-weight:600;font-size:12.5px;color:#6b7a89"></span>
    <input type="text" id="shQ" placeholder="코드·상품명·규격" oninput="shRender()">
    <label style="display:flex;align-items:center;gap:5px;white-space:nowrap;font-size:12.5px;font-weight:700;cursor:pointer" title="끄면 이 발주서에 고른 거래처에서 사던 품목만 보여 줍니다(발주서 한 장 = 거래처 한 곳).">
      <input type="checkbox" id="shAllVen" onchange="shRender()" style="width:14px;height:14px"> 전체 품목
    </label>
    <button class="btn" onclick="shClose()">닫기</button>
  </div>
  <div class="pb"><table><thead><tr>
    <th class="ck" style="width:36px"><input type="checkbox" id="shAll" onclick="shAllToggle(this.checked)" title="이 목록 전체 선택"></th>
    <th style="width:100px">코드</th><th>상품명</th><th style="width:120px">규격</th>
    <th style="width:64px" title="재고 원장 합">현재고</th><th style="width:64px" title="발주했는데 아직 안 들어온 수량">입고예정</th>
    <th style="width:56px">적정</th><th style="width:62px" title="적정 − (현재고 + 입고예정)">부족</th>
    <th style="width:76px" title="부족을 입수 배수로 올린 수량 — 담으면 이 수량이 들어갑니다">추천</th>
    <th style="width:120px" title="가장 최근 입고한 매입처(없으면 상품마스터 거래처)">대표 매입처</th>
    <th style="width:150px" title="최근 6개월 최저가 거래처 — 대표 매입처보다 싸면 빨강">최저 거래처</th>
    <th style="width:78px">단가</th></tr></thead><tbody id="shBody"></tbody></table></div>
  <div class="pf" style="display:flex; align-items:center; gap:8px; text-align:left">
    <span id="shInfo" style="margin-right:auto; color:#6b7a89; font-size:12.5px"></span>
    <button class="btn" id="shClr" onclick="shClear()" disabled>선택 해제</button>
    <button class="btn teal" id="shAdd" onclick="shAddSel()" disabled>선택한 0개 담기</button>
  </div>
</div></div>

<!-- 매입전환 (2026-09-03) — 발주서를 그대로 매입전표로 넣는다. 매입일자 = 실제 들어온 날. 매입 등록과 같은 저장 경로(재고·단가이력 함께) -->
<div class="pop" id="cvPop"><div class="box" style="width:min(860px,96vw)">
  <div class="ph">📦 매입전환 — 들어온 수량만큼 매입전표로</div>
  <div class="pb" style="padding:14px 16px">
    <div id="cvInfo" style="margin-bottom:12px; color:#37475a; font-size:13.5px"></div>
    <div class="hd" style="margin-bottom:8px"><label style="width:70px">매입일자</label><input type="date" id="cvDt" data-nonav="1"> <span style="color:#6b7a89; font-size:12px">← 실제 들어온 날(입고일)</span></div>
    <div class="hd" style="margin-bottom:8px"><label style="width:70px">창고</label><select id="cvWh" style="width:160px" title="입고될 창고(2026-09-16)"></select></div>
    <div class="hd"><label style="width:70px">지급구분</label><select id="cvPay"><option>현금</option><option>카드</option><option selected>외상</option><option>계좌이체</option></select></div>
    <%-- 줄별 이번 입고 (2026-09-16 P1-b 부분 입고) — cvRender() 가 채운다 --%>
    <div style="margin-top:10px; max-height:46vh; overflow:auto; border:1px solid var(--bd)">
      <table class="g" style="width:100%"><thead><tr><th style="width:32px">#</th><th style="width:100px">코드</th><th>상품명</th><th style="width:50px">입수</th><th style="width:70px">발주</th><th style="width:70px">기입고</th><th style="width:70px">잔량</th><th style="width:80px" title="이번에 들어온 BOX 수">이번 BOX</th><th style="width:70px">EA</th><th style="width:80px">합계</th></tr></thead><tbody id="cvBody"></tbody></table>
    </div>
    <div id="cvSum" style="margin-top:8px; font-size:13px; color:#37475a"></div>
    <div style="margin-top:4px; font-size:12px; color:#6b7a89">「이번 입고」는 <b>잔량</b>으로 채워 둡니다. 안 들어온 줄은 0 으로 두면 전표에서 빠집니다. 잔량보다 많이 넣으면 <span style="color:#c0392b">초과 입고</span>로 표시하고 한 번 물을 뿐 막지 않습니다.</div>
    <div id="cvWarn" style="margin-top:12px; color:#c0392b; font-size:12.5px; display:none"></div>
  </div>
  <div class="pf"><button class="btn" onclick="cvClose()">취소</button> <button class="btn blue" id="cvGo" onclick="cvGo()">매입전표 만들기</button></div>
</div></div>
<script>
var CTX='${pageContext.request.contextPath}';
/* ★창고 셀렉트 (2026-09-16 P3) — 값 = 창고코드, 글자 = 이름. 목록은 /prod/whList.do(사용 중인 창고), 처음엔 기본창고.
     전표를 불러오면 cvWhSet(저장된 코드·이름) 으로 맞춘다(옛 전표는 코드가 비어 이름 '물류창고' 만 있다 → 기본창고). */
var _cvWh=[];
function cvWhLoad(){
  fetch(CTX+'/prod/whList.do',{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'useOnly=Y' })
    .then(function(r){ return r.json(); }).then(function(j){
      _cvWh=(j&&j.data)||[]; var e=document.getElementById('cvWh'); if(!e) return;
      var cur=e.value;
      e.innerHTML=_cvWh.map(function(w){ return '<option value="'+w.whCd+'"'+(w.defaultYn==='Y'?' data-def="1"':'')+'>'+w.whNm+'</option>'; }).join('');
      if(cur && _cvWh.some(function(w){ return w.whCd===cur; })) e.value=cur; else cvWhSet('','');
    }).catch(function(){});
}
function cvWhCd(){ var e=document.getElementById('cvWh'); return e ? (e.value||'') : ''; }
function cvWhNmTxt(){ var e=document.getElementById('cvWh'); return (e && e.selectedIndex>=0) ? e.options[e.selectedIndex].text : ''; }
function cvWhSet(cd, nm){
  var e=document.getElementById('cvWh'); if(!e) return;
  var hit=_cvWh.filter(function(w){ return cd && w.whCd===cd; })[0] || _cvWh.filter(function(w){ return nm && w.whNm===nm; })[0]
        || _cvWh.filter(function(w){ return w.defaultYn==='Y'; })[0] || _cvWh[0];
  if(hit) e.value=hit.whCd;
}
cvWhLoad();                                                      // 매입 전환 창고 목록(2026-09-16 P3)
var KAKAO_KEY='${kakaoJsKey}', SHARE_BASE='${shareBase}';
var _vendors=[], _prods=[], _rows=[], _cur=null, _list=[], _prodRow=-1;
var _prodSel=[], _prodShown=[];   /* 상품팝업 ☑ 선택(_prods 첨자, 고른 차례) / 지금 목록에 보이는 첨자 */
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function fmtQ(v){ v=Math.round(n(v)*100)/100; return v.toLocaleString(undefined,{maximumFractionDigits:2}); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d8(d){ d=''+(d||''); return /^\d{8}$/.test(d)?(d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8)):d; }
function toast(s, icon){ if(window._alertBox) return _alertBox(s,{icon:icon||'ℹ️'}); alert(s.replace(/<[^>]*>/g,'')); }
function confirmBox(msg, onOk){ if(window._confirmBox) return _confirmBox({msg:msg, icon:'❓', okText:'확인', okColor:'blue', onOk:onOk}); if(confirm(msg.replace(/<[^>]*>/g,''))) onOk(); }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': isJson?'application/json; charset=UTF-8':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }

/* ── 마스터 ── */
function loadMasters(){
  post('/vendor/selectVendorMst.do','').then(function(r){return r.json();}).then(function(j){ _vendors=(j&&j.data)||[]; poPopRefreshed(); }).catch(function(){});
  post('/prod/prodList.do','findData=').then(function(r){return r.json();}).then(function(j){ _prods=((j&&j.data)||[]).filter(function(p){ return (''+(p.stopYn||'')).toUpperCase()!=='Y'; });
    _prodByCd={}; _prods.forEach(function(p){ if(p.prodCd!=null) _prodByCd[String(p.prodCd)]=p; });   // 코드 → 상품(적정재고 safeStock 을 여기서 읽는다)
    poPopRefreshed(); stkPaint(); }).catch(function(){});
  /* 서브코드(거래처 통보 코드) — 코드 칸 입력검색이 서브코드로 쳐도 주코드를 찾게 (2026-09-10, 매입등록과 같은 목록) */
  post('/prod/extItemList.do','').then(function(r){return r.json();}).then(function(j){ _extItems=(j&&j.data)||[]; poPopRefreshed(); }).catch(function(){});
  loadStockInfo();   // 현재고·최근 발주도 기준자료와 함께(창을 다시 볼 때도 새로 읽힌다)
}

/* ── 현재고 · 적정재고 · 최근 발주 (2026-09-16, 프로그램 목적 ①「재고 파악이 안 돼 중복 발주」) ──
   발주서를 만드는 순간 그 품목의 현재고·적정재고·직전 발주가 줄마다 보인다(종전엔 아무것도 없어 같은 것을 또 발주했다).
   · 현재고 = 재고 원장 합(/prod/stockQtyMap.do — 대시보드·품목별재고현황과 같은 SQL) · 적정 = 상품마스터 SAFE_STOCK(_prods 에 이미 온다)
   · 최근 발주 = 품목마다 가장 최근 발주서 한 줄(/mangr/poRecentByProd.do). 지금 열어 둔 발주서 자신은 뺀다.
   · DUP_DAYS(14)일 안 발주가 있고 아직 매입전환이 안 됐으면 ⚠ 빨강 + 담을 때 알림 한 번. ★막지는 않는다 — 의도한 재발주일 수 있다.
   · 칸은 render() 가 빈 채로 만들고 stkPaint() 가 채운다 — 자료가 나중에 와도 표를 다시 그리지 않아(입력 중인 칸이 안 튄다).
   ★미입고(발주 잔량)는 아직 개념이 없어 못 보여 준다 — TBL_PO_DTL 에 입고수량이 생기면 여기에 붙인다(분석 문서 P1-b). */
var _stock={}, _poRecent={}, _prodByCd={}, _dupQ=[], DUP_DAYS=14;
var _poRemain={};   // 품목별 미입고(다른 발주서 잔량 합) — {prodCd:{remainQty,lineCnt,oldestDt}} (2026-09-16 P1-b)
function loadStockInfo(){
  post('/prod/stockQtyMap.do','').then(function(r){return r.json();}).then(function(j){ var m={}; ((j&&j.data)||[]).forEach(function(s){ if(s.prodCd!=null) m[String(s.prodCd)]=n(s.curQty); }); _stock=m; stkPaint(); }).catch(function(){});
  post('/mangr/poRecentByProd.do','').then(function(r){return r.json();}).then(function(j){ var m={}; ((j&&j.data)||[]).forEach(function(x){ if(x.prodCd!=null) m[String(x.prodCd)]=x; }); _poRecent=m; stkPaint(); }).catch(function(){});
  post('/mangr/poRemainByProd.do','').then(function(r){return r.json();}).then(function(j){ var m={}; ((j&&j.data)||[]).forEach(function(x){ if(x.prodCd!=null) m[String(x.prodCd)]=x; }); _poRemain=m; stkPaint(); }).catch(function(){});
  shLoad();   // 추천 발주(적정재고 미달) — 단추 배지에 품목 수 (2026-09-16)
  /* 거래처별 매입가 (P2-b 2026-09-16) — 최근 6개월, 품목마다 최근가 싼 차례. 상품 팝업 「최저 거래처」 칸 + 명세 단가 칸 툴팁·노란 바탕 */
  post('/mangr/vendorPriceCmpList.do','months=6').then(function(r){return r.json();}).then(function(j){ var m={};
    ((j&&j.data)||[]).forEach(function(x){ var k=String(x.prodCd||''); if(!k) return; (m[k]||(m[k]=[])).push({ vendorCd:String(x.vendorCd||''), vendorNm:x.vendorNm||'', lastPrice:n(x.lastPrice), lastDt:x.lastDt||'', cnt:n(x.cnt) }); });
    Object.keys(m).forEach(function(k){ m[k].sort(function(a,b){ return a.lastPrice-b.lastPrice || b.cnt-a.cnt; }); });
    _vpc=m; stkPaint(); }).catch(function(){});
}
var _vpc={};   // prodCd → [{vendorCd,vendorNm,lastPrice,lastDt,cnt}] 최근가 싼 차례

/* ── 추천 발주 (2026-09-16 P1-c 후반, 프로그램 목적 ①의 반대쪽 「떨어졌는데 발주를 안 하는」) ───────────
     서버(/prod/safeStockShort.do)가 **상품마스터 기준**으로 미달 품목을 준다 — 원장에 기록이 없는 품목도 나온다
     (품목별재고현황은 원장 GROUP BY 라 그런 품목이 아예 안 보인다. 그래서 담는 자리는 여기다).
     가용 = 현재고 + 입고예정, 부족 = 적정 − 가용, 추천 = 부족을 입수 배수로 올림.
     ★목록은 이 발주서에 고른 거래처 것 먼저 — 발주서 한 장이 거래처 한 곳이라 전체를 섞으면 「이건 다른 데서 사는 건데」가 된다. */
var _short=[], _shSel=[], _shShown=[];
function shLoad(){
  post('/prod/safeStockShort.do','').then(function(r){return r.json();}).then(function(j){ _short=(j&&j.data)||[]; shBadge(); })
    .catch(function(){ _short=[]; shBadge(); });
}
function shBadge(){
  var b=document.getElementById('btnShort'); if(!b) return;
  var k=_short.length;
  b.innerHTML = k ? ('⚠ 추천 발주 <b>'+k+'</b>') : '⚠ 추천 발주';
  b.style.color = k ? '#c0392b' : '';
  b.style.borderColor = k ? '#f0b4b0' : '';
  b.title = k ? ('적정재고에 못 미치는 품목 '+k+'개 — 눌러서 담습니다(수량은 담은 뒤 고칠 수 있습니다).')
              : '적정재고에 못 미치는 품목이 없습니다. (적정재고는 상품코드관리에서 넣습니다)';
}
function shRecoQty(o){ var pk=n(o.packQty)||1, sh=Math.max(0, Math.round(n(o.shortQty))); if(pk<=1) return sh; return Math.ceil(sh/pk)*pk; }
function shHasRow(cd){ return _rows.some(function(o){ return o.prodCd && String(o.prodCd)===String(cd); }); }
function shOpen(){
  if(!_short.length){ toast('적정재고에 못 미치는 품목이 없습니다.<br><span style="font-size:12.5px;color:#3d4d5c">적정재고는 <b>기준정보관리 ▸ 상품코드관리</b> 에서 품목마다 넣습니다. 넣어 두면 「현재고 + 입고예정」이 그 아래로 내려갈 때 여기에 모입니다.</span>','ℹ️'); return; }
  _shSel=[]; document.getElementById('shPop').classList.add('on'); document.getElementById('shQ').value=''; shRender();
  setTimeout(function(){ var q=document.getElementById('shQ'); if(q) q.focus(); },30);
}
function shClose(){ document.getElementById('shPop').classList.remove('on'); }
function shVenCd(){ return (document.getElementById('venNm').dataset.cd||''); }
function shList(){
  var q=(document.getElementById('shQ').value||'').trim().toLowerCase();
  var all=(document.getElementById('shAllVen')||{}).checked, ven=shVenCd();
  return _short.filter(function(o){
    if(!all && ven && String(o.vendorCd||'')!==String(ven)) return false;
    if(q){ var hay=(o.prodCd+' '+(o.prodNm||'')+' '+(o.spec||'')).toLowerCase(); if(hay.indexOf(q)<0) return false; }
    return true; });
}
function shRender(){
  var l=shList(), h='', ven=shVenCd(), all=(document.getElementById('shAllVen')||{}).checked;
  _shShown=[];
  l.forEach(function(o){
    var i=_short.indexOf(o); _shShown.push(i);
    var on=_shSel.indexOf(i)>=0, has=shHasRow(o.prodCd), reco=shRecoQty(o);
    h+='<tr class="pick'+(on?' sel':'')+'"'+(has?' style="opacity:.55"':' onclick="shToggle('+i+',event)"')+'>'
      +'<td class="ck" onclick="event.stopPropagation()">'+(has?'<span class="dim" title="이미 이 발주서에 담겨 있습니다">담김</span>':'<input type="checkbox"'+(on?' checked':'')+' onclick="shToggle('+i+',event)">')+'</td>'
      +'<td>'+esc(o.prodCd)+'</td><td class="l">'+esc(o.prodNm)+'</td><td class="l">'+esc(o.spec)+'</td>'
      +'<td class="r">'+fmtQ(o.curQty)+'</td>'
      +'<td class="r" style="color:#b06a00">'+(n(o.poRemainQty)>0?fmtQ(o.poRemainQty):'')+'</td>'
      +'<td class="r">'+fmtQ(o.safeStock)+'</td>'
      +'<td class="r low">'+fmtQ(o.shortQty)+'</td>'
      +'<td class="r"><b>'+fmtQ(reco)+'</b>'+((n(o.packQty)||1)>1?'<span class="dim" style="font-size:11px"> ('+fmtQ(n(o.packQty))+'입)</span>':'')+'</td>'
      +'<td class="l" style="font-size:12px">'+(o.vendorNm?esc(o.vendorNm):'<span class="dim">—</span>')+(!all&&!ven&&o.vendorNm?'':'')+'</td>'
      +vpcCell(String(o.prodCd), n(o.inPrice))
      +'<td class="r">'+fmt(o.inPrice)+'</td></tr>';
  });
  document.getElementById('shBody').innerHTML = h || '<tr><td colspan="12" class="empty" style="padding:22px;text-align:center;color:#8a98a8">'
    + (ven && !all ? '이 거래처에서 사던 미달 품목이 없습니다 — 위 <b>[전체 품목]</b> 을 켜면 다른 거래처 것도 보입니다.' : '조건에 맞는 품목이 없습니다.') + '</td></tr>';
  document.getElementById('shSub').textContent = '적정재고에 못 미치는 품목 ' + _short.length + '개' + ((ven && !all) ? ' · 이 거래처 ' + l.length + '개' : '');
  shSelUpd();
}
function shToggle(i, ev){ if(ev&&ev.stopPropagation) ev.stopPropagation();
  var o=_short[i]; if(!o || shHasRow(o.prodCd)) return;
  var k=_shSel.indexOf(i); if(k<0) _shSel.push(i); else _shSel.splice(k,1); shRender(); }
function shAllToggle(on){ _shShown.forEach(function(i){ var o=_short[i]; if(!o||shHasRow(o.prodCd)) return;
  var k=_shSel.indexOf(i); if(on&&k<0) _shSel.push(i); else if(!on&&k>=0) _shSel.splice(k,1); }); shRender(); }
function shClear(){ _shSel=[]; shRender(); }
function shSelUpd(){ var c=_shSel.length;
  document.getElementById('shAdd').disabled = !c; document.getElementById('shClr').disabled = !c;
  document.getElementById('shAdd').textContent = '선택한 '+c+'개 담기';
  document.getElementById('shInfo').innerHTML = c ? ('고른 '+c+'개를 담으면 <b>추천 수량</b>이 채워집니다 — 담은 뒤 고칠 수 있습니다.')
    : '왼쪽 <b>☑</b> 로 고른 뒤 [담기]. 추천 수량 = 부족을 <b>입수 배수</b>로 올린 값입니다.'; }
/* 담기 — 상품 팝업과 같은 길(prodFill)로 줄을 만들고 추천 수량을 채운다.
   입수 배수면 BOX 로, 아니면 EA 로 넣는다(발주서 수량 칸이 BOX·EA 둘이라). */
function shAddSel(){
  if(!_shSel.length) return;
  var base=_prodRow; if(!_rows[base] || _rows[base].prodCd){ ensureTail(); base=_rows.length-1; }
  var at=base, cnt=0;
  _shSel.forEach(function(i){ var o=_short[i]; if(!o || shHasRow(o.prodCd)) return;
    var row; if(!cnt){ row=_rows[base]; } else { row=emptyRow(); _rows.splice(++at,0,row); }
    prodFill(row, { prodSeq:o.prodSeq, prodCd:o.prodCd, prodNm:o.prodNm, spec:o.spec, packQty:o.packQty, inPrice:o.inPrice, taxGb:o.taxGb });
    var pk=n(o.packQty)||1, reco=shRecoQty(o);
    if(pk>1 && reco%pk===0){ row.boxQty=reco/pk; row.eaQty=0; } else { row.boxQty=0; row.eaQty=reco; }
    calcRow(row); cnt++; });
  _shSel=[]; shClose(); render(); prodFocusRow(base);
  if(window._toast) _toast(cnt+'개 품목을 담았습니다 — 추천 수량이 채워져 있습니다. 필요하면 고치세요.','ok');
}
/* 상품 팝업 「최저 거래처」 칸 — 마스터 매입가(inPrice)보다 싸면 빨강 */
function vpcCell(cd, inPrice){ var l=_vpc[cd]||[]; if(!l.length) return '<td><span class="dim">—</span></td>';
  var b=l[0], cheaper=(inPrice>0 && b.lastPrice<inPrice);
  var tip=l.slice(0,6).map(function(v){ return v.vendorNm+' '+fmtQ(v.lastPrice)+'('+d8(v.lastDt).slice(5)+')'; }).join(' · ')+(l.length>6?' 외 '+(l.length-6):'');
  return '<td class="l'+(cheaper?' low':'')+'" style="font-size:12px;white-space:nowrap" title="'+esc(tip)+(cheaper?'\n마스터 매입가보다 '+fmtQ(inPrice-b.lastPrice)+' 쌉니다':'')+'">'+esc(b.vendorNm)+' <b>'+fmtQ(b.lastPrice)+'</b>'+(l.length>1?' <span class="dim">외 '+(l.length-1)+'</span>':'')+'</td>'; }
function daysAgo(s){ s=''+(s||''); if(!/^\d{8}$/.test(s)) return null; var a=new Date(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8)), b=new Date(); b.setHours(0,0,0,0); return Math.round((b-a)/86400000); }
function stkInfo(cd){ var p=_prodByCd[cd]||{}, cur=_stock[cd], safe=n(p.safeStock);
  return { cur:(cur==null?null:cur), safe:safe, low:(cur!=null && (cur<=0 || (safe>0 && cur<safe))) }; }
function rcntInfo(cd){ var r=_poRecent[cd]; if(!r) return null; if(_cur && _cur.poSeq!=null && String(r.poSeq)===String(_cur.poSeq)) return null;
  /* 경고 기준 = 잔량이 남았고 마감 안 됨 (2026-09-16 P1-b — 종전엔 「매입전환 됐나」로만 봤다). 잔량 정보가 없는 옛 서버면 종전 기준 */
  var d=daysAgo(r.poDt), open=(r.remainQty!=null) ? (n(r.remainQty)>0 && r.closeYn!=='Y') : !r.purchSeq;
  return { r:r, days:d, open:open, warn:(d!=null && d<=DUP_DAYS && open) }; }
function whenTxt(d, dt){ return d==null ? d8(dt) : (d===0 ? '오늘' : d+'일 전'); }
function stkPaint(){
  var tb=document.getElementById('gbody'); if(!tb) return;
  _rows.forEach(function(o,i){ var tr=tb.rows[i]; if(!tr) return;
    var a=tr.querySelector('td.stk'), b=tr.querySelector('td.safe'), c=tr.querySelector('td.rcnt'), pd=tr.querySelector('td.pend'), rv=tr.querySelector('td.rcv');
    if(!a||!b||!c||!pd||!rv) return;
    if(!o.prodCd){ [a,b,c,pd,rv].forEach(function(x){ x.innerHTML=''; x.title=''; }); a.className='ro c stk'; c.className='l rcnt'; pd.className='ro c pend'; return; }
    var s=stkInfo(o.prodCd);
    a.innerHTML = (s.cur==null) ? '<span class="dim">—</span>' : fmtQ(s.cur);
    a.className = 'ro c stk'+(s.low?' low':'');
    a.title = (s.cur==null) ? '재고 원장에 기록이 없는 품목' : ('현재고 '+fmtQ(s.cur)+(s.safe?' · 적정 '+fmtQ(s.safe):'')+(s.low?' — 적정재고 미달':''));
    b.innerHTML = s.safe ? fmtQ(s.safe) : '<span class="dim">—</span>';
    var k=rcntInfo(o.prodCd);
    if(!k){ c.innerHTML='<span class="dim">없음</span>'; c.className='l rcnt'; c.title='이 품목의 다른 발주서가 없습니다'; }
    else { var r=k.r, hasRem=(r.remainQty!=null);
      var tail = hasRem ? (k.open ? ' · <b>잔 '+fmtQ(r.remainQty)+'</b>' : (r.closeYn==='Y' ? ' <span class="dim">(마감)</span>' : ' <span class="dim">(입고됨)</span>'))
                        : (r.purchSeq ? ' <span class="dim">(매입됨)</span>' : '');
      c.innerHTML=(k.warn?'⚠ ':'')+esc(whenTxt(k.days,r.poDt))+' · '+fmtQ(r.qty)+' · '+esc(r.vendorNm||'')+tail;
      c.className='l rcnt'+(k.warn?' warn':'');
      c.title='최근 발주서 '+d8(r.poDt)+' - '+(r.poNo||'')+' · '+(r.vendorNm||'')+' · 수량 '+fmtQ(r.qty)
        +(hasRem ? ' · 잔량 '+fmtQ(r.remainQty)+(r.closeYn==='Y'?'(마감)':'') : (r.purchSeq?' · 매입전환 됨':' · 아직 매입전환 안 됨'))
        +(n(r.cnt30)>1?' · 최근 30일 발주 '+r.cnt30+'줄':'')+(k.warn?'\n'+DUP_DAYS+'일 안에 발주했고 아직 안 들어온 품목입니다 — 중복 발주가 아닌지 확인하세요':''); }
    /* 미입고 = 이 품목의 다른 발주서 잔량 합 (이 발주서 자신의 줄은 뺀다 — 자기 잔량은 「입고」 칸에 있다) */
    var pr=_poRemain[o.prodCd], pq=pr?n(pr.remainQty):0;
    if(_cur && o.poDtlSeq && o.closeYn!=='Y' && o.remainQty!=null && n(o.remainQty)>0) pq-=n(o.remainQty);
    if(pq<0) pq=0;
    pd.innerHTML = pq>0 ? fmtQ(pq) : '<span class="dim">—</span>'; pd.className='ro c pend'+(pq>0?' warn':'');
    pd.title = pq>0 ? ('다른 발주서에서 아직 안 들어온 수량 '+fmtQ(pq)+(pr&&pr.oldestDt?' · 가장 오래된 발주 '+d8(pr.oldestDt):'')+' — 곧 들어올 예정이니 또 발주하기 전에 확인') : '다른 발주서의 미입고 없음';
    /* 이 줄의 입고 · 잔량 · [마감] — 저장된 발주서만 */
    if(!_cur || !o.poDtlSeq){ rv.innerHTML='<span class="dim">—</span>'; rv.title='저장하고 매입전환하면 이 줄의 입고·잔량이 여기 보입니다'; }
    else { var inq=n(o.inQty), rem=(o.remainQty!=null?n(o.remainQty):n(o.qty)-inq), cl=(o.closeYn==='Y');
      var st = cl ? '<span class="dim">마감</span>'
             : rem<0 ? '<span class="low" title="발주보다 많이 들어왔습니다(초과 입고)">초과 +'+fmtQ(-rem)+'</span>'
             : rem===0 ? '<span style="color:#137a6c;font-weight:700">✔ 완료</span>'
             : (inq>0 ? '<span class="low">잔 '+fmtQ(rem)+'</span>' : '<span class="dim">미입고</span>');
      var ck = (rem>0) ? ' <label title="더 안 들어온다 — 이 줄의 잔량을 미입고에서 뺍니다(다시 누르면 풉니다)" style="font-size:11px;white-space:nowrap;cursor:pointer"><input type="checkbox"'+(cl?' checked':'')+' onchange="poLineClose('+i+',this.checked)"> 마감</label>' : '';
      rv.innerHTML='<span style="font-size:12px">'+fmtQ(inq)+'</span> '+st+ck;
      rv.title='발주 '+fmtQ(o.qty)+' · 기입고 '+fmtQ(inq)+' · 잔량 '+fmtQ(rem)+(cl?' · 마감(더 안 온다)':''); }
    /* 단가 칸 툴팁 (P2-b) — 이 품목의 거래처별 최근가. 이 발주서 거래처보다 싼 곳이 있으면 노란 바탕(알림뿐, 막지 않는다) */
    var pi=tr.querySelector('input[data-f="unitPrice"]'), l=_vpc[o.prodCd]||[];
    if(pi){ if(!l.length){ pi.title=''; pi.classList.remove('vpc'); }
      else { var vc=(document.getElementById('venNm')||{}).dataset ? (document.getElementById('venNm').dataset.cd||'') : '';
        var mine=l.filter(function(v){ return v.vendorCd===vc; })[0], best=l[0], cheaper=!!(vc && best.vendorCd!==vc && (mine ? best.lastPrice<mine.lastPrice : best.lastPrice<n(o.unitPrice)));
        pi.title='거래처별 최근 매입가 (6개월) : '+l.slice(0,6).map(function(v){ return v.vendorNm+' '+fmtQ(v.lastPrice)+'('+d8(v.lastDt).slice(5)+')'; }).join(' · ')+(l.length>6?' 외 '+(l.length-6):'')
          +(cheaper?'\n▼ '+best.vendorNm+' 이(가) 더 쌉니다 — '+fmtQ((mine?mine.lastPrice:n(o.unitPrice))-best.lastPrice)+' 차이':'');
        pi.classList[cheaper?'add':'remove']('vpc'); } }
  });
}
/* 발주 줄 마감/해제 — 저장하는 상태는 이것뿐. 저장 뒤 미입고·목록을 다시 읽는다 */
function poLineClose(i,on){ var o=_rows[i]; if(!o||!o.poDtlSeq) return;
  post('/mangr/poLineClose.do','poDtlSeq='+o.poDtlSeq+'&closeYn='+(on?'Y':'N')).then(function(r){ if(!r.ok) return r.text().then(function(x){ throw new Error(x); });
      o.closeYn=on?'Y':'N'; stkPaint(); loadStockInfo(); if(_cur) poLoad(_cur.poSeq);
      if(window._toast) _toast(on?'이 줄을 마감했습니다 — 잔량이 미입고에서 빠집니다.':'마감을 풀었습니다.','ok'); })
    .catch(function(e){ toast('마감 저장 실패: '+esc(e.message),'⚠️'); stkPaint(); }); }
/* 이 발주서를 보고 있는 매입전표들 — 삭제 확인창에 보여 준다 */
function poLinked(seq, cb){ post('/mangr/poLinkedPurch.do','poSeq='+seq).then(function(r){return r.json();}).then(function(j){ cb((j&&j.data)||[]); }).catch(function(){ cb([]); }); }
/* 목록 「입고」 열 — 줄마다 센 잔량을 넷으로 가른다 */
function poRcvLbl(o){ var ln=n(o.lineCnt); if(!ln) return '';
  var rem=n(o.remainSum), ins=n(o.inSum), cl=n(o.closeCnt), tot=n(o.totQty);
  if(ins<=0 && cl===0) return '<span class="dim">미입고</span>';
  if(ins<=0 && cl>0) return '<span class="dim">마감 '+cl+'/'+ln+'</span>';
  if(rem<=0) return '<span style="color:#137a6c;font-weight:700">✔ 완료</span>'+(cl?' <span class="dim">(마감 '+cl+')</span>':'');
  return '<span style="color:#c0392b;font-weight:700">부분</span> '+fmtQ(ins)+'/'+fmtQ(tot)+(cl?' <span class="dim">(마감 '+cl+')</span>':''); }
/* 담을 때 모아 두었다가 render() 끝에서 한 번만 알린다(여러 개 담아도 알림 하나) */
function poDupNote(cd){ if(cd && _dupQ.indexOf(cd)<0) _dupQ.push(cd); }
function poDupFlush(){ if(!_dupQ.length) return; var q=_dupQ; _dupQ=[]; var hits=[];
  q.forEach(function(cd){ var k=rcntInfo(cd); if(!k||!k.warn) return; var p=_prodByCd[cd]||{};
    hits.push((p.prodNm||cd)+'('+whenTxt(k.days,k.r.poDt)+' · '+(k.r.vendorNm||'')+' '+fmtQ(k.r.qty)+')'); });
  if(!hits.length) return;
  var msg='⚠ 최근 '+DUP_DAYS+'일 안에 발주한 품목 — 중복 발주가 아닌지 확인 : '+hits.slice(0,3).join(' · ')+(hits.length>3?' 외 '+(hits.length-3)+'건':'');
  if(window._toast) _toast(msg,'error'); else toast(esc(msg),'⚠️'); }
/* 거래처 칸에 직접 쳐서 고른다(공통 vendor-pick) — 못 불러오면 팝업만 */
try{ if(window._vendorPick) _vendorPick(document.getElementById('venNm'), { list:function(){ return _vendors; }, onPick:function(o){ venPick(o.vendorCd, o.vendorNm); }, onClear:function(){ venPick('',''); } }); }catch(e){}
function venPick(cd, nm){ var el=document.getElementById('venNm'); el.dataset.cd=cd||''; if(nm!=null) el.value=nm; }
/* ★기준자료를 «다시 보일 때»·창을 열 때 새로 읽는다 (2026-09-13 「수금·지급·발주서 등록도 같게」 — 매입·판매등록과 같은 규칙)
     셸 iframe 은 로그아웃 전까지 그대로라, 화면을 열 때 한 번만 읽으면 다른 화면에서 고친 상품·거래처가 안 보였다.
     셸(logiFrame)이 이 화면을 다시 보여 줄 때 konetShown 을 부른다(3초 안 중복은 한 번만).
     도착하면 열려 있는 거래처·상품 창을 그 자리에서 다시 그린다. 이미 담은 명세 줄은 건드리지 않는다. */
function poPopRefreshed(){
  var v=document.getElementById('venPop'), p=document.getElementById('prodPop');
  if(v && v.classList.contains('on')) venRender();
  if(p && p.classList.contains('on')) prodRender();
}
var _poMastersAt=0;
window.konetShown=function(){
  if(Date.now()-_poMastersAt<3000) return;
  _poMastersAt=Date.now();
  loadMasters();
};
function venOpen(){ document.getElementById('venPop').classList.add('on'); document.getElementById('venQ').value=''; venRender(); loadMasters();setTimeout(function(){ document.getElementById('venQ').focus(); },50); }
function venClose(){ document.getElementById('venPop').classList.remove('on'); }
function venRender(){ var q=(document.getElementById('venQ').value||'').trim().toLowerCase(), h='';
  _vendors.forEach(function(v){ var hay=(v.vendorCd+' '+(v.vendorNm||'')+' '+(v.fullNm||'')+' '+(v.bizno||'')+' '+(v.ceoNm||'')).toLowerCase(); if(q && hay.indexOf(q)<0) return;
    h+='<tr class="pick" onclick="venPick(\''+esc(v.vendorCd)+'\',\''+esc(v.vendorNm)+'\');venClose()"><td>'+esc(v.vendorCd)+'</td><td class="l">'+esc(v.vendorNm)+'</td><td>'+esc(v.ceoNm)+'</td><td>'+esc(v.tel||v.hp)+'</td><td>'+esc(v.bizno)+'</td></tr>'; });
  document.getElementById('venBody').innerHTML=h||'<tr><td colspan="5" class="empty">거래처가 없습니다.</td></tr>'; }

/* ── 품목 줄 ── */
function emptyRow(){ return { prodSeq:null, prodCd:'', prodNm:'', spec:'', packQty:1, boxQty:0, eaQty:0, qty:0, unitPrice:0, amt:0, dcAmt:0, supplyAmt:0, vatAmt:0, totAmt:0, serviceQty:0, taxGb:'', remark:'',
  poDtlSeq:null, inQty:0, remainQty:null, closeYn:'N', closeRmk:'' }; }   /* 입고·잔량·마감 (2026-09-16 P1-b) — poDetail 이 줄마다 준다. poDtlSeq 는 저장 때 되돌려 보내 매입 연결을 지킨다(savePo 가 새 번호로 옮긴다) */
function taxFree(o){ var t=(''+(o.taxGb||'')).toUpperCase(); return t==='F' || t==='N' || t.indexOf('면세')>=0 || t.indexOf('FREE')>=0; }
function calcRow(o){ var pk=n(o.packQty)||1; o.qty=n(o.boxQty)*pk+n(o.eaQty); o.amt=Math.round(o.qty*n(o.unitPrice)); o.supplyAmt=o.amt-n(o.dcAmt); o.vatAmt=taxFree(o)?0:Math.round(o.supplyAmt*0.1); o.totAmt=o.supplyAmt+o.vatAmt; }
function ensureTail(){ if(!_rows.length || _rows[_rows.length-1].prodCd) _rows.push(emptyRow()); }
function render(){
  ensureTail(); var h='';
  _rows.forEach(function(o,i){ calcRow(o);
    h+='<tr><td class="c ro">'+(i+1)+'</td>'
      /* 줄 삭제 ✕ — 맨 앞 번호 바로 뒤 (2026-09-10 요청 — 판매·매입등록과 같은 자리. 종전엔 맨 끝 칸) */
      +'<td class="c"><span class="del" title="이 줄 삭제" onclick="delRow('+i+')">✕</span></td>'
      /* 코드 칸 — 빈 줄은 직접 쳐서 고른다(pin*, 2026-09-10 「매입등록하는 것처럼」). 담긴 줄은 코드를 눌러 다른 상품으로 바꾼다 */
      +(o.prodCd
        ? '<td class="c"><span class="lnk" title="클릭 → 다른 상품으로 바꾸기" onclick="prodOpen('+i+')">'+esc(o.prodCd)+'</span></td>'
        : '<td class="l" style="padding:2px 3px"><div style="display:flex;align-items:center;gap:2px">'
          +'<input class="l pin" data-r="'+i+'" placeholder="코드·상품명" autocomplete="off" oninput="pinInput(this)" onkeydown="pinKey(this,event)" onblur="pinBlur()">'
          +'<span class="lnk" title="상품 선택 팝업으로 찾기" style="font-size:12px;text-decoration:none" onclick="prodOpen('+i+')">🔍</span></div></td>')
      +'<td class="l"><input class="l" value="'+esc(o.prodNm)+'" onchange="setv('+i+',\'prodNm\',this.value)" onclick="if(!_rows['+i+'].prodCd) prodOpen('+i+')"></td>'
      +'<td class="l"><input class="l" value="'+esc(o.spec)+'" onchange="setv('+i+',\'spec\',this.value)"></td>'
      +'<td class="ro c stk"></td><td class="ro c safe"></td><td class="l rcnt"></td><td class="ro c pend"></td><td class="c rcv"></td>'   // 현재고·적정·최근발주·미입고·입고 — stkPaint() 가 채운다
      +'<td><input value="'+fmtQ(o.packQty)+'" onchange="setv('+i+',\'packQty\',this.value)"></td>'
      +'<td><input data-f="boxQty" value="'+fmtQ(o.boxQty)+'" onchange="setv('+i+',\'boxQty\',this.value)"></td>'
      +'<td><input value="'+fmtQ(o.eaQty)+'" onchange="setv('+i+',\'eaQty\',this.value)"></td>'
      +'<td class="ro">'+fmtQ(o.qty)+'</td>'
      +'<td><input data-f="unitPrice" value="'+fmtQ(o.unitPrice)+'" onchange="setv('+i+',\'unitPrice\',this.value)"></td>'   // data-f : stkPaint 가 거래처별 단가 툴팁을 단다(P2-b)
      +'<td class="ro">'+fmt(o.amt)+'</td>'
      +'<td><input value="'+fmt(o.dcAmt)+'" onchange="setv('+i+',\'dcAmt\',this.value)"></td>'
      +'<td class="ro">'+fmt(o.supplyAmt)+'</td><td class="ro">'+fmt(o.vatAmt)+'</td><td class="ro">'+fmt(o.totAmt)+'</td>'
      +'<td><input value="'+fmtQ(o.serviceQty)+'" onchange="setv('+i+',\'serviceQty\',this.value)"></td>'
      +'<td class="l"><input class="l" value="'+esc(o.remark)+'" onchange="setv('+i+',\'remark\',this.value)"></td>'
      +'</tr>'; });
  document.getElementById('gbody').innerHTML=h;
  var t=calcAll();
  document.getElementById('trow').innerHTML='<td colspan="11" class="c">합계 · 품목 '+t.cnt+'</td><td>'+fmtQ(t.box)+'</td><td>'+fmtQ(t.ea)+'</td><td>'+fmtQ(t.qty)+'</td><td></td><td>'+fmt(t.amt)+'</td><td>'+fmt(t.dc)+'</td><td>'+fmt(t.sup)+'</td><td>'+fmt(t.vat)+'</td><td>'+fmt(t.tot)+'</td><td>'+fmtQ(t.svc)+'</td><td></td>';   // 합계줄 = 11(#·삭제·코드·상품명·규격·현재고·적정·최근발주·미입고·입고·입수) + … + 비고 1 = 22칸 (2026-09-16 재고 3 + 입고 2 추가)
  stkPaint(); poDupFlush();   // 재고·최근발주 칸 채우기 + 방금 담은 품목의 중복 발주 알림
}
function setv(i,k,v){ var o=_rows[i]; if(!o) return; o[k]=(k==='prodNm'||k==='spec'||k==='remark')?v:n(v); render(); }
function delRow(i){ _rows.splice(i,1); render(); }
function calcAll(){ var t={cnt:0,box:0,ea:0,qty:0,amt:0,dc:0,sup:0,vat:0,tot:0,svc:0}; _rows.forEach(function(o){ if(!o.prodCd) return; calcRow(o); t.cnt++; t.box+=n(o.boxQty); t.ea+=n(o.eaQty); t.qty+=o.qty; t.amt+=o.amt; t.dc+=n(o.dcAmt); t.sup+=o.supplyAmt; t.vat+=o.vatAmt; t.tot+=o.totAmt; t.svc+=n(o.serviceQty); }); return t; }
function prodOpen(i){ _prodRow=i; _prodSel=[]; document.getElementById('prodPop').classList.add('on'); document.getElementById('prodQ').value=''; prodRender(); loadMasters();setTimeout(function(){ document.getElementById('prodQ').focus(); },50); }
function prodClose(){ document.getElementById('prodPop').classList.remove('on'); }
function prodRender(){ var q=(document.getElementById('prodQ').value||'').trim().toLowerCase(), h='', k=0; _prodShown=[];
  for(var i=0;i<_prods.length && k<300;i++){ var p=_prods[i]; var hay=(p.prodCd+' '+(p.prodNm||'')+' '+(p.spec||'')).toLowerCase(); if(q && hay.indexOf(q)<0) continue; k++; _prodShown.push(i);
    var on=_prodSel.indexOf(i)>=0;
    h+='<tr class="pick'+(on?' sel':'')+'" onclick="prodPick('+i+')">'
      +'<td class="ck" onclick="event.stopPropagation()"><input type="checkbox"'+(on?' checked':'')+' onclick="prodToggle('+i+',event)"></td>'
      +'<td>'+esc(p.prodCd)+'</td><td class="l">'+esc(p.prodNm)+'</td><td class="l">'+esc(p.spec)+'</td><td>'+fmtQ(p.packQty||1)+'</td>'
      +(function(){ var s=stkInfo(String(p.prodCd)); return '<td class="r stk'+(s.low?' low':'')+'" title="'+(s.cur==null?'재고 원장에 기록이 없는 품목':('현재고 '+fmtQ(s.cur)+(s.safe?' · 적정 '+fmtQ(s.safe):'')))+'">'+(s.cur==null?'—':fmtQ(s.cur))+'</td>'; })()   // 현재고 (2026-09-16)
      +'<td class="r">'+fmt(p.inPrice)+'</td>'
      +vpcCell(String(p.prodCd), n(p.inPrice))   // 최저 거래처 (P2-b)
      +'<td>'+esc(p.taxGb)+'</td></tr>'; }
  document.getElementById('prodBody').innerHTML=h||'<tr><td colspan="9" class="empty">상품이 없습니다.</td></tr>';
  prodSelUpd(); }
/* ☑ 여러 개 담기 — _prodSel 은 <고른 차례>대로 담는다(그 순서로 줄이 생긴다). 검색어를 바꿔도 선택은 남는다. */
function prodToggle(pi, ev){ if(ev&&ev.stopPropagation) ev.stopPropagation();
  var k=_prodSel.indexOf(pi); if(k<0) _prodSel.push(pi); else _prodSel.splice(k,1);
  var tr=ev&&ev.target?ev.target.parentNode.parentNode:null; if(tr&&tr.classList) tr.classList[k<0?'add':'remove']('sel');
  prodSelUpd(); }
function prodAllToggle(on){ _prodShown.forEach(function(i){ var k=_prodSel.indexOf(i); if(on&&k<0) _prodSel.push(i); else if(!on&&k>=0) _prodSel.splice(k,1); }); prodRender(); }
function prodSelClear(){ _prodSel=[]; prodRender(); }
function prodSelUpd(){ var c=_prodSel.length;
  var b=document.getElementById('prodSelAdd'); if(b){ b.textContent='선택한 '+c+'개 담기'; b.disabled=!c; }
  var x=document.getElementById('prodSelClr'); if(x) x.disabled=!c;
  var a=document.getElementById('prodAll'); if(a) a.checked=!!(_prodShown.length && _prodShown.every(function(i){ return _prodSel.indexOf(i)>=0; }));
  var s=document.getElementById('prodSelInfo');
  if(s) s.innerHTML = c ? ('<b style="color:#137a6c">'+c+'개</b> 선택 — [담기]를 누르면 줄이 '+c+'개 생깁니다.')
                       : '여러 개는 왼쪽 <b>☑</b> 로 고른 뒤 [담기] — 줄을 누르면 한 개만 담고 닫힙니다.'; }
function prodFill(o,p){ o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=p.prodNm||''; o.spec=p.spec||''; o.packQty=n(p.packQty)||1; o.unitPrice=n(p.inPrice); o.taxGb=p.taxGb||''; if(!n(o.boxQty)&&!n(o.eaQty)) o.boxQty=1;
  poDupNote(String(p.prodCd)); }   // 담는 길 셋(팝업 한 개·팝업 여러 개·코드 칸 입력검색)이 전부 여기를 지나므로 중복 발주 알림은 여기 한 곳
function prodFocusRow(i){ var tr=document.getElementById('gbody').rows[i]; if(tr){ var inp=tr.querySelector('input[data-f="boxQty"]');   /* 몇 번째 input 으로 찾지 않는다 — 빈 줄은 코드 칸에도 input 이 있다(2026-09-10) */ if(inp){ inp.focus(); inp.select(); } } }
function prodPick(pi){ var p=_prods[pi], o=_rows[_prodRow]; if(!p||!o) return;
  prodFill(o,p);
  prodClose(); render(); prodFocusRow(_prodRow); }
/* 고른 것 중 첫 줄은 팝업을 연 그 줄에 넣고, 나머지는 바로 밑에 줄을 만들어 이어 넣는다. */
function prodAddSel(){
  if(!_prodSel.length) return;
  var base=_prodRow; if(!_rows[base]){ ensureTail(); base=_rows.length-1; }
  var at=base, cnt=0;
  _prodSel.forEach(function(pi){ var p=_prods[pi]; if(!p) return;
    var o; if(!cnt){ o=_rows[base]; } else { o=emptyRow(); _rows.splice(++at,0,o); }
    prodFill(o,p); cnt++; });
  _prodSel=[]; prodClose(); render(); prodFocusRow(base);
  if(window._toast) _toast(cnt+'개 상품을 담았습니다. 수량을 입력하세요.','ok'); }

/* ── 코드 칸 입력검색 (2026-09-10 「코드 직접입력 가능하게 — 매입등록하는 것처럼」) ──
   매입등록 puPin* 과 같은 동작 : 빈 줄의 코드 칸에 치면 후보가 뜨고 ↑↓·Enter(또는 마우스)로 고른다 → 커서는 BOX 로.
   · 찾는 곳 = 이미 들고 있는 상품마스터(_prods)의 코드·상품명·규격 + 서브코드(_extItems) — 서버를 부르지 않는다.
     서브코드가 걸리면 **주코드로** 담고 알려 준다(매입등록과 같다 — 서브코드로 발주하면 매입전환 때 재고가 갈라진다).
   · 후보가 없는데 Enter = 상품 선택 팝업(친 글자가 검색어로 들어간다).
   · 드롭다운은 표 상자(.gridwrap)가 overflow 라 잘리므로 body 에 position:fixed 로 띄운다. */
var _extItems=[], _pinRow=-1, _pinList=[], _pinIdx=-1, _pinDrop=null;
function _pinHit(q){ return function(x){ return String(x==null?'':x).toLowerCase().indexOf(q)>=0; }; }
function pinCands(q){
  var out=[], seen={}, idx={};
  for(var a=0;a<_prods.length;a++){ if(_prods[a].prodCd!=null) idx[String(_prods[a].prodCd)]=a; }
  /* ⓐ 서브코드 — 사용자가 친 그 코드가 정확히 걸린 줄이라 맨 위에 둔다 */
  for(var j=0;j<_extItems.length && out.length<12;j++){ var e=_extItems[j];
    if(!e || !e.prodCd || !e.extItemCd || String(e.extItemCd)===String(e.prodCd)) continue;
    if(![e.extItemCd, e.extItemNm].some(_pinHit(q))) continue;
    var pi=idx[String(e.prodCd)]; if(pi==null) continue;                  // 주코드가 마스터에 없으면 담을 수 없다
    var key='S'+e.extItemCd+'>'+e.prodCd; if(seen[key]) continue; seen[key]=1;
    out.push({ pi:pi, viaSub:String(e.extItemCd) }); }
  /* ⓑ 상품마스터 */
  for(var i=0;i<_prods.length && out.length<12;i++){ var p=_prods[i]; if(!p.prodCd) continue;
    if(![p.prodCd, p.prodNm, p.spec].some(_pinHit(q))) continue;
    if(seen['M'+p.prodCd]) continue; seen['M'+p.prodCd]=1;
    out.push({ pi:i }); }
  return out; }
function pinInput(inp){ _pinRow=+inp.dataset.r; var q=String(inp.value||'').trim().toLowerCase();
  if(!q){ pinClose(); return; }
  _pinList=pinCands(q); _pinIdx=_pinList.length?0:-1; pinDraw(inp); }
function pinDraw(inp){
  if(!_pinDrop){ _pinDrop=document.createElement('div');
    _pinDrop.style.cssText='position:fixed;z-index:400;background:#fff;border:1px solid #cfd8e3;border-radius:8px;box-shadow:0 10px 30px rgba(0,0,0,.18);font-size:12.5px;max-height:260px;overflow:auto';
    document.body.appendChild(_pinDrop); }
  if(!_pinList.length){ pinClose(); return; }
  var rc=inp.getBoundingClientRect();
  _pinDrop.style.left=rc.left+'px'; _pinDrop.style.top=(rc.bottom+2)+'px'; _pinDrop.style.minWidth=Math.max(420, rc.width)+'px';
  _pinDrop.innerHTML=_pinList.map(function(it,k){ var p=_prods[it.pi]||{}, on=(k===_pinIdx);
    var badge=it.viaSub ? '<span style="flex:0 0 auto;padding:0 5px;border-radius:8px;background:#fdecea;color:#c0392b;font-size:11px;font-weight:800">서브 '+esc(it.viaSub)+' →</span>' : '';
    return '<div onmousedown="pinPickMd(event,'+k+')" style="display:flex;gap:8px;padding:6px 10px;cursor:pointer;white-space:nowrap;'+(on?'background:#e9f4f1;':(it.viaSub?'background:#fffaf9;':''))+'">'
      + badge
      + '<b style="min-width:100px;color:#137a6c">'+esc(p.prodCd)+'</b>'
      + '<span style="flex:1;text-align:left;color:#1f2a37">'+esc(p.prodNm)+'</span>'
      + '<span style="min-width:96px;color:#8a97a4">'+esc(p.spec||'')+'</span>'
      + '<span style="min-width:40px;text-align:right;color:#8a97a4">['+fmtQ(p.packQty||1)+']</span>'
      + '<span style="min-width:66px;text-align:right;color:#37475a">'+(p.inPrice!=null&&p.inPrice!==''?fmt(p.inPrice):'')+'</span>'
      + '</div>'; }).join('');
  _pinDrop.style.display='block'; }
function pinKey(inp, e){
  if(e.key==='ArrowDown'){ e.preventDefault(); if(_pinList.length){ _pinIdx=Math.min(_pinList.length-1,_pinIdx+1); pinDraw(inp); } }
  else if(e.key==='ArrowUp'){ e.preventDefault(); if(_pinList.length){ _pinIdx=Math.max(0,_pinIdx-1); pinDraw(inp); } }
  else if(e.key==='Enter'){ e.preventDefault();
    if(_pinList.length && _pinIdx>=0) pinPick(_pinIdx);
    else { var q=inp.value||''; pinClose(); prodOpen(+inp.dataset.r); if(q){ document.getElementById('prodQ').value=q; prodRender(); } } }   // 후보가 없으면 팝업으로
  else if(e.key==='Escape'){ pinClose(); } }
function pinPickMd(e, k){ e.preventDefault(); pinPick(k); }
function pinPick(k){ var it=_pinList[k], row=_pinRow; pinClose(); if(!it) return;
  var o=_rows[row], p=_prods[it.pi]; if(!o || !p) return;
  prodFill(o,p); render(); prodFocusRow(row);                              // 담은 뒤 커서는 BOX
  if(it.viaSub && window._toast) _toast('서브코드 '+it.viaSub+' → 주코드 '+p.prodCd+' 로 담았습니다.','ok'); }
function pinClose(){ if(_pinDrop) _pinDrop.style.display='none'; _pinList=[]; _pinIdx=-1; }
function pinBlur(){ setTimeout(pinClose, 150); }

/* ── 머리 ── */
function poNew(){ _cur=null; _rows=[]; document.getElementById('poDt').value=today(); venPick('',''); document.getElementById('remark').value=''; document.getElementById('poNo').value=''; poDtChanged(); render(); setButtons(); document.getElementById('stat').textContent='새 발주서'; }
function poDtChanged(){ if(_cur) return; var d=document.getElementById('poDt').value; if(!d) return; post('/mangr/poNextNo.do','poDt='+encodeURIComponent(d)).then(function(r){return r.json();}).then(function(j){ document.getElementById('poNo').value=(j&&j.data)||'0001'; }).catch(function(){}); }
function setButtons(){ var on=!!(_cur&&_cur.poSeq); ['btnDel','btnPrint','btnXls','btnKakao','btnLink','btnCv'].forEach(function(id){ document.getElementById(id).disabled=!on; }); }
function poSave(){
  var venCd=document.getElementById('venNm').dataset.cd||'', venNm=document.getElementById('venNm').value||'';
  if(!document.getElementById('poDt').value){ toast('발주일자를 선택하세요.','⚠️'); return; }
  if(!venCd){ toast('거래처를 선택하세요.','⚠️'); return; }
  var items=_rows.filter(function(o){ return o.prodCd; }); if(!items.length){ toast('상품을 한 줄 이상 넣으세요.','⚠️'); return; }
  var t=calcAll();
  var dto={ poSeq:_cur?_cur.poSeq:null, poDt:document.getElementById('poDt').value, poNo:document.getElementById('poNo').value, vendorCd:venCd, vendorNm:venNm,
    mgrCd:'${sessionScope.s_user_id}', mgrNm:document.getElementById('mgrNm').value, totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty, supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:t.dc,
    remark:document.getElementById('remark').value, items:items };
  post('/mangr/poSave.do', dto, true).then(function(r){ return r.text().then(function(x){ if(!r.ok) throw new Error(x); return x; }); })
    .then(function(seq){ seq=String(seq||'').replace(/[^0-9]/g,'');   /* 응답이 감싸여 와도 숫자만 */
      shLoad();   /* 저장하면 잔량(입고예정)이 늘어 미달이 풀린다 — 배지를 다시 센다 (2026-09-16) */
      toast('발주서를 저장했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">번호 '+esc(document.getElementById('poDt').value)+' - '+esc(document.getElementById('poNo').value)+'</span>','✅'); poLoad(seq); poOpen(seq); loadStockInfo(); })   // 저장한 발주가 곧 「최근 발주」가 되므로 다시 읽는다
    .catch(function(e){ toast('저장에 실패했습니다.<br><span style="font-size:12.5px;color:#c0392b">'+esc(e.message)+'</span>','⚠️'); });
}
/* 삭제 — 연결된 매입전표가 있어도 막지 않는다(사용자 확정 「메시지 처리」). 무엇이 끊기는지만 확인창에 적는다 (2026-09-16 P1-b) */
function poDelete(){ if(!_cur) return; poLinked(_cur.poSeq, function(lk){
  var extra = lk.length ? '<br><span style="font-size:12.5px;color:#c0392b">⚠ 매입전표 <b>'+lk.length+'장</b>('+lk.map(function(x){ return d8(x.purchDt)+'-'+(x.purchNo||''); }).join(', ')+')이 이 발주를 보고 있습니다.<br>지워도 전표와 재고는 그대로이고, 이 발주와의 입고·잔량 연결만 끊깁니다.</span>' : '';
  confirmBox('이 발주서를 삭제할까요?<br><span style="font-size:13px;color:#3d4d5c">'+esc(d8(_cur.poDt))+' - '+esc(_cur.poNo)+' '+esc(_cur.vendorNm)+'</span>'+extra, function(){
  post('/mangr/poDelete.do','poSeq='+_cur.poSeq).then(function(r){ if(!r.ok) return r.text().then(function(x){ throw new Error(x); }); toast('삭제했습니다.','✅'); poNew(); poLoad(); loadStockInfo(); }).catch(function(e){ toast('삭제 실패: '+esc(e.message),'⚠️'); }); }); }); }
/* cb = 다 올린 뒤 부를 함수(선택) — 전송이력 [📂 전표 열기]가 연 뒤 이력 창을 다시 띄우는 데 쓴다 (2026-09-10) */
function poOpen(seq, cb){ post('/mangr/poDetail.do','poSeq='+seq).then(function(r){return r.json();}).then(function(j){ var m=j&&j.mst; if(!m){ toast('발주서를 찾을 수 없습니다.','⚠️'); return; }
  _cur=m; document.getElementById('poDt').value=d8(m.poDt); document.getElementById('poNo').value=m.poNo||''; venPick(m.vendorCd||'', m.vendorNm||''); document.getElementById('remark').value=m.remark||'';
  if(m.mgrNm) document.getElementById('mgrNm').value=m.mgrNm;
  _rows=(j.items||[]).map(function(d){ var o=emptyRow(); for(var k in o) if(d[k]!=null) o[k]=d[k]; return o; }); render(); setButtons();
  document.getElementById('stat').textContent='발주서 '+d8(m.poDt)+' - '+m.poNo+' · 공유 '+(m.shareCnt||0)+'회'+(m.lastShareDttm?(' (마지막 '+m.lastShareDttm+')'):'')+(m.purchNo?(' · 📦 매입전표 '+d8(m.purchDt)+'-'+m.purchNo):'');
  markList(); if(typeof cb==='function') cb(); }).catch(function(e){ toast('불러오기 실패: '+esc(e.message),'⚠️'); }); }

/* ── 목록 ── */
function poLoad(selSeq){ var b='fromDt='+encodeURIComponent(document.getElementById('frDt').value)+'&toDt='+encodeURIComponent(document.getElementById('toDt').value)+'&findData='+encodeURIComponent(document.getElementById('findNm').value);
  document.getElementById('lbody').innerHTML='<tr><td colspan="12" class="empty">조회 중…</td></tr>';
  post('/mangr/poList.do', b).then(function(r){return r.json();}).then(function(j){ _list=(j&&j.data)||[]; listRender(); if(selSeq) markList(selSeq); }).catch(function(e){ document.getElementById('lbody').innerHTML='<tr><td colspan="12" class="empty" style="color:#c0392b">조회 오류: '+esc(e.message)+'</td></tr>'; }); }
function listRender(){ var h='', ts=0, tv=0, tt=0;
  _list.forEach(function(o,i){ ts+=n(o.supplyAmt); tv+=n(o.vatAmt); tt+=n(o.totAmt);
    h+='<tr data-seq="'+o.poSeq+'" onclick="poOpen('+o.poSeq+')"><td>'+d8(o.poDt)+'</td><td>'+esc(o.poNo)+'</td><td class="l">'+esc(o.vendorNm)+'</td><td>'+esc(o.mgrNm)+'</td><td>'+n(o.prodCnt)+'</td><td class="r">'+fmtQ(o.totQty)+'</td><td class="r">'+fmt(o.supplyAmt)+'</td><td class="r">'+fmt(o.vatAmt)+'</td><td class="r">'+fmt(o.totAmt)+'</td><td>'+(n(o.shareCnt)?('💬 '+n(o.shareCnt)):'')+'</td><td title="'+(o.purchNo?('마지막 매입전표 '+d8(o.purchDt)+'-'+esc(o.purchNo)):'')+'">'+poRcvLbl(o)+'</td><td>'+esc(o.regUser)+'</td></tr>'; });
  document.getElementById('lbody').innerHTML=h||'<tr><td colspan="12" class="empty">발주서가 없습니다.</td></tr>';
  document.getElementById('cnt').innerHTML='<b>'+_list.length+'</b>건 · 공급가 <b>'+fmt(ts)+'</b> · 부가세 <b>'+fmt(tv)+'</b> · 합계 <b>'+fmt(tt)+'</b>'; }
function markList(seq){ var s=seq||(_cur&&_cur.poSeq); document.querySelectorAll('#lbody tr').forEach(function(tr){ tr.classList.toggle('on', String(tr.getAttribute('data-seq'))===String(s)); }); }

/* ── 인쇄 · 엑셀 · 공유 ── */
function poPrint(){ if(!_cur) return; window.open(CTX+'/mangr/poPrint.do?poSeq='+_cur.poSeq, 'poPrint', 'width=900,height=1000'); }
function shareUrl(){ return _cur&&_cur.shareToken ? (SHARE_BASE+'/pub/po.do?t='+encodeURIComponent(_cur.shareToken)) : ''; }
/* ── 📨 전송이력 (2026-09-10) — 공용 [asset/js/send-hist.js] · 판매등록 거래명세표와 같은 표(TBL_SEND_HIST) ──
   ★기록과 조회가 **같은 함수**(poHistDoc)로 «지금 발주서»를 만든다 — 두 곳이 어긋나면
     보낸 줄을 그 발주서 이력에서 못 찾는다.
   ★poShared.do(공유 횟수 +1)는 그대로 둔다 — 그건 «몇 번」, 이력은 «언제·어떻게». */
function poHistDoc(){ var t=calcAll();
  return { docGb:'PO', docSeq:(_cur&&_cur.poSeq)||0,
           docDt:document.getElementById('poDt').value, docNo:document.getElementById('poNo').value,
           vendorCd:document.getElementById('venNm').dataset.cd||'', vendorNm:document.getElementById('venNm').value||'',
           totAmt:t.tot }; }
function poHistLog(gb, extra){ if(!window.konetSendHist) return;
  var o=poHistDoc(); o.sendGb=gb; if(extra) for(var k in extra) o[k]=extra[k];
  konetSendHist.log(o); }
/* 읽음·열람 열쇠 — 보낼 때마다 새 열쇠를 주소 뒤 &s= 로 붙인다(공개 주소·토큰은 그대로). 받는 쪽이 열면 그 전송 줄의 열람이 올라간다 */
function poHistTag(u){ var k=window.konetSendHist?konetSendHist.key():''; return { k:k, u:(k?konetSendHist.tag(u,k):u) }; }
/* 📨 전송이력 창 — [↻ 재전송]은 같은 수단으로 이 화면 함수를 다시 부르고, 다른 발주서 줄은 그 발주서를 먼저 연다 (2026-09-10) */
function poSendHist(){ if(!window.konetSendHist){ toast('전송이력을 불러오지 못했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">새로고침 뒤 다시 눌러 보세요.</span>','⚠️'); return; }
  var o=poHistDoc();
  o.onResend=function(row){ if(String(row.sendGb)==='KAKAO') poKakao(); else poCopyLink(); };
  o.onOpenDoc=function(seq){ poOpen(seq, function(){ poSendHist(); }); };
  konetSendHist.open(o); }
/* ★링크 복사는 <전송>이 아니라 전송이력에 남기지 않는다 (2026-09-10 「링크복사는 전송내역이 아니지 않나요」) — 꼬리표도 안 붙인다 */
function poCopyLink(){ var u=shareUrl(); if(!u){ toast('먼저 저장하세요.','⚠️'); return; }
  var done=function(){
    toast('발주서 링크를 복사했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">카톡 대화창에 붙여 넣으면 거래처가 로그인 없이 봅니다.</span><br><span style="font-size:11.5px;color:#6b7a89;word-break:break-all">'+esc(u)+'</span>','🔗'); };
  if(navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(u).then(done, function(){ prompt('아래 주소를 복사하세요', u); });
  else prompt('아래 주소를 복사하세요', u); }
function poKakao(){ var u0=shareUrl(); if(!u0){ toast('먼저 저장하세요.','⚠️'); return; }
  var tg=poHistTag(u0), u=tg.u;      /* 읽음·열람 열쇠가 붙은 주소로 카드를 만든다 */
  if(!window.Kakao || !KAKAO_KEY){ toast('카카오 공유 설정이 없어 <b>링크 복사</b>로 보냅니다.<br><span style="font-size:12px;color:#6b7a89">kakao.properties 의 kakao.js.key 를 채우고 Kakao Developers 에 이 사이트 도메인을 등록하면 카드로 보내집니다.</span>','💬'); poCopyLink(); return; }
  try{ if(!Kakao.isInitialized()) Kakao.init(KAKAO_KEY); }catch(e){ toast('카카오 초기화 실패: '+esc(e.message),'⚠️'); poCopyLink(); return; }
  var t=calcAll(), dt=d8(_cur.poDt);
  try{
    /* 텍스트형 카드 — 그림(썸네일) 없이 글만 (2026-09-03 「앞에 표시는 제거」). feed 형은 이미지가 필수라 text 형으로 */
    Kakao.Share.sendDefault({ objectType:'text',
      text:'📋 발주서 — '+(_cur.vendorNm||'')+'\n'+dt+' · 품목 '+t.cnt+'종 · 합계 '+fmt(t.tot)+'원 · '+(document.getElementById('mgrNm').value||''),
      link:{ mobileWebUrl:u, webUrl:u },
      buttons:[ { title:'웹페이지로 보기', link:{ mobileWebUrl:u, webUrl:u } } ] });
    poHistLog('KAKAO',{shareUrl:u,trackKey:tg.k});
    post('/mangr/poShared.do','poSeq='+_cur.poSeq).then(function(){ if(_cur){ _cur.shareCnt=n(_cur.shareCnt)+1; document.getElementById('stat').textContent='발주서 '+dt+' - '+_cur.poNo+' · 공유 '+_cur.shareCnt+'회'; } poLoad(_cur.poSeq); }).catch(function(){});
  }catch(e){ poHistLog('KAKAO',{shareUrl:u,trackKey:tg.k,resultGb:'FAIL',errMsg:e.message});
    toast('카카오 공유 실패: '+esc(e.message)+'<br><span style="font-size:12px">링크 복사로 보내세요.</span>','⚠️'); }
}
function poExcel(){ if(!_cur) return; var t=calcAll(), aoa=[];
  aoa.push(['발주서']); aoa.push(['발주일자', d8(_cur.poDt), '번호', _cur.poNo, '거래처', _cur.vendorNm||'', '담당', document.getElementById('mgrNm').value||'']); aoa.push([]);
  aoa.push(['번호','코드','품명','규격','입수','BOX','EA','합계수량','단가','금액','DC','공급가','부가세','매입금액','서비스','비고']);
  var k=0; _rows.forEach(function(o){ if(!o.prodCd) return; k++; aoa.push([k,o.prodCd,o.prodNm,o.spec,n(o.packQty),n(o.boxQty),n(o.eaQty),o.qty,n(o.unitPrice),o.amt,n(o.dcAmt),o.supplyAmt,o.vatAmt,o.totAmt,n(o.serviceQty),o.remark||'']); });
  aoa.push(['합계','','','','',t.box,t.ea,t.qty,'',t.amt,t.dc,t.sup,t.vat,t.tot,t.svc,'']); aoa.push([]); aoa.push(['비고', document.getElementById('remark').value||'']);
  var P=window.parent, fn='발주서_'+(_cur.vendorNm||'')+'_'+(_cur.poDt||'')+'-'+(_cur.poNo||'')+'.xlsx';
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); ws['!cols']=[{wch:6},{wch:12},{wch:36},{wch:18},{wch:6},{wch:8},{wch:8},{wch:10},{wch:10},{wch:12},{wch:8},{wch:12},{wch:10},{wch:12},{wch:8},{wch:20}]; var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'발주서'); LIB.writeFile(wb,fn); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB) byLib(LIB); else toast('엑셀 모듈을 못 불러왔습니다.','⚠️'); }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; } toast('엑셀 모듈은 물류관리 메인 안에서만 씁니다.','⚠️'); }

/* ── 매입전환 ── 발주서 → 매입전표(TBL_PURCHASE_*). 서버가 매입 등록과 같은 저장 경로를 타므로 재고 입고·단가 이력도 같이 생긴다 */
/* ── 매입전환 = 부분 입고 (2026-09-16 P1-b, 설계 docs/설계_발주잔량_부분입고_2026-09-16.md) ──
   줄마다 「발주 · 기입고 · 잔량 · 이번 입고」. 이번 입고는 잔량으로 채워 둔다 — 두 번째 전환은 저절로 나머지만.
   0 인 줄은 전표에서 빠진다. 잔량보다 많이 넣으면 초과 입고로 <표시만>(확인창 한 번, 막지 않는다 — 사용자 확정). */
var _cv=[];   // {poDtlSeq, prodCd, prodNm, packQty, poQty, inQty, remain, closeYn, box, ea, qty}
function cvOpen(){ if(!_cur){ toast('먼저 발주서를 저장하세요.','⚠️'); return; }
  _cv=_rows.filter(function(o){ return o.prodCd; }).map(function(o){ var pack=n(o.packQty)||1, inq=n(o.inQty), rem=(o.remainQty!=null?n(o.remainQty):n(o.qty)-inq);
    var q=(rem>0 && o.closeYn!=='Y')?rem:0, box=Math.floor(q/pack), ea=q-box*pack;
    return { poDtlSeq:o.poDtlSeq, prodCd:o.prodCd, prodNm:o.prodNm, packQty:pack, poQty:n(o.qty), inQty:inq, remain:rem, closeYn:o.closeYn||'N', box:box, ea:ea, qty:q }; });
  document.getElementById('cvInfo').innerHTML='<b>'+esc(_cur.vendorNm)+'</b> · 발주 '+d8(_cur.poDt)+'-'+esc(_cur.poNo)+' · 품목 '+_cv.length+'종';
  document.getElementById('cvDt').value=today();
  cvRender(); document.getElementById('cvPop').classList.add('on'); }
function cvRender(){ var h='', tq=0, cnt=0;
  _cv.forEach(function(r,i){ r.qty=n(r.box)*r.packQty+n(r.ea); if(r.qty>0){ tq+=r.qty; cnt++; }
    var over=(r.qty>0 && r.remain>=0 && r.qty>r.remain) ? r.qty-r.remain : 0;
    h+='<tr'+(r.closeYn==='Y'?' style="opacity:.55"':'')+'><td class="c ro">'+(i+1)+'</td><td class="c">'+esc(r.prodCd)+'</td><td class="l">'+esc(r.prodNm)+(r.closeYn==='Y'?' <span class="dim">(마감)</span>':'')+'</td>'
      +'<td class="ro">'+fmtQ(r.packQty)+'</td><td class="ro">'+fmtQ(r.poQty)+'</td><td class="ro">'+fmtQ(r.inQty)+'</td><td class="ro'+(r.remain<0?' low':'')+'">'+fmtQ(r.remain)+'</td>'
      +'<td><input value="'+fmtQ(r.box)+'" onchange="cvSet('+i+',\'box\',this.value)"></td><td><input value="'+fmtQ(r.ea)+'" onchange="cvSet('+i+',\'ea\',this.value)"></td>'
      +'<td class="ro'+(over?' low':'')+'" title="'+(over?('잔량보다 '+fmtQ(over)+' 많습니다 — 초과 입고(막지 않습니다)'):'')+'">'+fmtQ(r.qty)+(over?' ⚠':'')+'</td></tr>'; });
  document.getElementById('cvBody').innerHTML=h||'<tr><td colspan="10" class="empty">품목이 없습니다.</td></tr>';
  var w=document.getElementById('cvWarn'), allDone=!!_cv.length && _cv.every(function(r){ return r.remain<=0 || r.closeYn==='Y'; });
  w.style.display=allDone?'block':'none';
  w.innerHTML=allDone?'잔량이 없습니다 — <b>이미 전부 입고(또는 마감)된 발주서</b>입니다. 추가로 들어온 것이 있으면 「이번 입고」에 수량을 넣으세요.':'';
  document.getElementById('cvSum').innerHTML='이번 입고 <b>'+fmtQ(tq)+'</b> · 전표에 들어갈 줄 <b>'+cnt+'</b>'+(cnt<_cv.length?' <span class="dim">(0 인 줄 '+(_cv.length-cnt)+'개는 빠집니다)</span>':''); }
function cvSet(i,f,v){ var r=_cv[i]; if(!r) return; r[f]=n(v); cvRender(); }
function cvClose(){ document.getElementById('cvPop').classList.remove('on'); }
function cvGo(){ if(!_cur) return; var dt=document.getElementById('cvDt').value; if(!dt){ toast('매입일자를 고르세요.','⚠️'); return; }
  var items=_cv.filter(function(r){ return r.qty>0; }).map(function(r){ return { poDtlSeq:r.poDtlSeq, boxQty:n(r.box), eaQty:n(r.ea), qty:r.qty }; });
  if(!items.length){ toast('이번에 들어온 수량이 없습니다.<br><span style="font-size:12.5px;color:#3d4d5c">「이번 입고」에 수량을 넣으세요.</span>','⚠️'); return; }
  var over=_cv.filter(function(r){ return r.qty>0 && r.remain>=0 && r.qty>r.remain; }).length;
  var run=function(){
    var b={ poSeq:_cur.poSeq, purchDt:dt, whCd:cvWhCd(), whNm:cvWhNmTxt()||'물류창고', payGb:document.getElementById('cvPay').value, items:items };
    document.getElementById('cvGo').disabled=true;
    post('/mangr/poToPurchase.do', b, true).then(function(r){ return r.text().then(function(x){ if(!r.ok) throw new Error(x); return x; }); })
      .then(function(x){ var j={}; try{ j=JSON.parse(x); }catch(e){} cvClose();
        toast('매입전표를 만들었습니다.<br><span style="font-size:13px;color:#3d4d5c">매입일자 '+esc(dt)+' · 전표번호 <b>'+esc(j.purchNo||'')+'</b> · 품목 '+esc(j.rows||'')+'줄 · 수량 '+fmtQ(j.qty||0)+'</span><br><span style="font-size:12px;color:#6b7a89">매입 등록 화면에서 확인·수정할 수 있습니다. 발주서의 입고·잔량은 바로 반영됩니다.</span>','✅');
        poLoad(_cur.poSeq); poOpen(_cur.poSeq); loadStockInfo(); })
      .catch(function(e){ toast('매입전환 실패<br><span style="font-size:12.5px;color:#c0392b;white-space:pre-line">'+esc(e.message)+'</span>','⚠️'); })
      .finally(function(){ document.getElementById('cvGo').disabled=false; }); };
  if(over) confirmBox('잔량보다 많이 넣은 줄이 <b>'+over+'개</b> 있습니다(초과 입고). 그대로 매입전표를 만들까요?', run); else run(); }
/* ── 시작 ── */
(function(){ var d=new Date(); document.getElementById('toDt').value=today(); d.setDate(1); document.getElementById('frDt').value=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01'; })();
loadMasters(); poNew(); poLoad();
/* 코드 칸 후보 목록은 fixed 로 떠 있으므로 표를 굴리거나 창 크기가 바뀌면 닫는다 (2026-09-10) */
(function(){ var g=document.querySelector('.gridwrap'); if(g) g.addEventListener('scroll', pinClose); window.addEventListener('resize', pinClose); })();
</script>
</body>
</html>
