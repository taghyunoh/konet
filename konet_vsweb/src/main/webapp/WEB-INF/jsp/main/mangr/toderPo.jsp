<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>토더 발주 등록</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 읽기 (전역 XLSX) --%>
<%-- 표 높이 막대 (2026-09-22 「여기도 판매등록 막대」) — 판매·매입·수금·지급등록과 같은 공용 파일. 위 미리보기 · 아래 저장 목록 둘 다 --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20260910b"></script>
<!--
  토더 발주 등록 (2026-09-21 신설 — 「토더라는 곳에서 발주 엑셀로 받아서 출고 업로드 … 기존 DC 발주 등록과 같은 개념」) — 매출 관리 ▸ 토더 발주 등록. 셸 iframe(logiFrame) 화면.
  · 토더(가맹점 발주 플랫폼, 예: 샐러링)의 「상품별 발주 목록」 엑셀을 올린다. 머리 줄 = no·배송지명·배송담당자·발주번호·발주일시·출고마감일·상품명·단위·매입가·발주수량·출고수량·상품 상태 …
  · 엑셀에는 사업장코드·품목코드가 없다 → 줄마다 둘 다 넣고 [💾 저장]. 같은 배송지명·같은 상품명의 빈 칸은 한 번 넣으면 같이 채워진다.
    저장하면 (배송지명 → 사업장코드), (상품명 → 품목코드) 짝이 쌓여 다음 업로드부터 자동으로 채워진다(/shipout/toderPoMap.do — 저장된 토더 발주에서 읽는다, 표를 따로 안 둔다).
  · 발주일자(발주일시의 날짜) = 납기일자 = 출고일자. 수량 = 출고수량이 있으면 그것, 없으면 발주수량. 상태가 취소·반품이면 기본으로 체크를 뺀다.
  · 저장 = TBL_SHIPOUT_MST PROD_KIND='TD'(출고장 「토더」) + 재고 연동 (2026-09-21 저녁 「토더도 재고 맞추어 주고 정산서는 사용자 협의 후」) —
    저장·삭제하면 그 발주일자들의 출고 원장을 다시 만들어 재고에서 뺀다. 그 날 삼성웰스토리 정산서가 있어도 토더 줄은 뺀다(그 정산서에 토더는 없다).
    ★[2026-09-22 사용자 확정] 토더 = 매출 — 별도 정산서가 없다. ①엑셀 「매입가」 = 우리 판매가(SALE_PRICE) ②부가세 포함 ③받을 상대 = 거래처 「토더」(VENDOR_CD·DC_CD='TODER')
      ④사용자가 골라 저장하면 곧 출고·매출 ⑤반품은 당분간 저장된 줄의 수량 수정(0 = 전량 반품) ⑥발주일자 = 출고일자.
      매출 = 수량 × 판매가 — 마감(근거 '토더')·매출 그래프(직접판매 칸, 출고장 줄 '토더')·채권·채무·일계장·거래처 원장·하루 명세·거래처 합계 모두 같은 식.
      (09-21 의 「일단 재고만 · 반품이 정산서로 오면 매출」은 이것으로 바뀌었다.) 정산서 대사·납기현황관리에서는 여전히 뺀다.
      ⛔DDL docs/sql/20260922_toder_sales.sql(SALE_PRICE 칸 + 거래처 「토더」)을 새 WAR 보다 먼저.
    같은 (발주번호, 배송지명, 상품명)을 다시 올리면 앞의 것을 대체한다(같은 기간을 여러 번 받아 올려도 중복되지 않는다).
  · 원본 파일은 보관하지 않는다(DC 발주와 같다). 파일 이름만 남는다.
  · [✏️ 직접 입력] (2026-10-02 사용자 「엑셀업로드 말고 카톡으로 오는 경우도 있어서 직접입력 기능도」) — 엑셀 없이 줄을 만들어 친다.
    올린 표 안에 「직접」 줄로 들어가고 저장은 엑셀 줄과 같은 길이다(서버 그대로). 빈 발주번호·배송지명·상품명은 저장할 때 채운다(mPrep 머리말).
  · [📒 토더 마감장부] (이름 = 같은 날 사용자 「토더 마감장부」 · 2026-10-02 사용자 「토더발주에 대장 조회 및 엑셀출력 추가」 · 「토더 발주 이런 식으로 마감장」) — 조회 기간의 저장된 토더 발주를
    옛 시스템 「유형별 매출원장 전체조회」 엑셀과 같은 모양(거래처별 · 일계 · 소계 · 합계 · 누계)으로 보여 주고 엑셀로 낸다. 화면만의 기능이다(서버는 그대로).
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
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  /* 엑셀 고르기 = 제목 줄 단추(2026-09-22 「공간 없이 버튼으로」) · 끌어다 놓기는 카드 전체가 받는다 */
  #upCard.on{ outline:2px dashed var(--teal); outline-offset:-2px; background:#f3faf8; }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:4px 6px; text-align:center; white-space:nowrap; vertical-align:middle; }
  table.g td.l{ text-align:left; } table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g input[type=text]{ height:30px; border:1.5px solid #e9b98a; background:#fdebd9; border-radius:6px; padding:0 6px; font-size:13px; width:130px; }
  table.g input[type=text].ok{ border-color:#7cc5b2; background:#f3fbf8; }
  table.g input[type=text].auto{ border-color:#9db7e8; background:#eef3fd; }
  table.g input[type=text].bad{ border-color:#e2b93b; background:#fff7d6; }
  table.g tr.off td{ color:#9aa7b3; background:#fafbfc; }
  /* 저장 목록의 수량·판매가 입력칸(2026-09-22 반품 = 수정) — 넣어야 하는 칸(주황)이 아니라 고칠 수 있는 값이라 흰 바탕 · 오른쪽 정렬 */
  table.g input[type=text].num{ width:86px; text-align:right; background:#fff; border:1px solid var(--bd); font-variant-numeric:tabular-nums; }
  table.g input[type=text].num:focus{ border-color:var(--teal); outline:none; }
  /* 직접 입력 줄의 글자 칸 — 넣어도 되고 비워도 되는 칸이라 흰 바탕 */
  table.g input[type=text].mi, table.g input[type=date].mi{ height:30px; background:#fff; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; font-family:inherit; }
  table.g input.mi:focus{ border-color:var(--teal); outline:none; }
  table.g input[type=date].mi.bad{ border-color:#e2b93b; background:#fff7d6; }
  table.g input[type=text].num.bad{ border-color:#e2b93b; background:#fff7d6; }
  .sub{ display:block; font-size:11.5px; color:#6b7a89; margin-top:1px; max-width:230px; overflow:hidden; text-overflow:ellipsis; }
  .sub.warn{ color:var(--amber); }
  .sub.nmf{ font-size:13px; color:#1f2a37; font-weight:700; margin:0 0 3px; max-width:260px; }   /* 명칭을 앞(위)에 */
  table.g input[type=text]{ width:170px; }
  .bd{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .bd.auto{ background:#e8eefb; color:#2f4f9a; } .bd.st{ background:#eef2f5; color:#556; } .bd.cx{ background:#fdecec; color:var(--red); }
  .dim{ color:#8a98a8; }
  input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; }
  .msg{ padding:22px; text-align:center; color:#8a98a8; }
  .note{ font-size:12.5px; color:#6b7a89; padding:8px 12px; line-height:1.6; }
  /* 마감장 창 — 예시 엑셀과 같은 색(머리글 하늘 · 일계 연두 · 소계 보라 · 합계 크림) */
  #lgPop{ display:none; position:fixed; left:0; top:0; right:0; bottom:0; z-index:50; background:rgba(15,23,32,.45); align-items:center; justify-content:center; }
  #lgPop.on{ display:flex; }
  #lgPop .lg-box{ background:#fff; border-radius:12px; width:96vw; max-width:1560px; height:90vh; display:flex; flex-direction:column; box-shadow:0 14px 44px rgba(0,0,0,.28); overflow:hidden; }
  .lg-hd{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; padding:10px 14px; border-bottom:1px solid #eef1f5; }
  .lg-hd #lgTitle{ font-size:16px; font-weight:800; color:#1f2a37; }
  .lg-hd .lg-act{ margin-left:auto; display:flex; gap:8px; white-space:nowrap; }
  .lg-hd .lg-hd2{ flex-basis:100%; display:flex; gap:8px; align-items:center; }
  .lg-hd label{ font-size:12.5px; font-weight:700; color:#37475a; }
  .lg-hd input[type=date]{ height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; font-family:inherit; }
  .lg-hd input[type=text]{ height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; width:170px; font-family:inherit; }
  .lg-bd{ flex:1; overflow:auto; }
  table.lg{ border-collapse:collapse; width:100%; font-size:12.5px; }
  table.lg th{ position:sticky; top:0; z-index:1; background:#d9edf7; font-weight:700; border:1px solid #9fb6c3; padding:6px 6px; white-space:nowrap; text-align:center; }
  table.lg td{ border:1px solid #c9d3dc; padding:4px 6px; text-align:center; white-space:nowrap; }
  table.lg td.l{ text-align:left; } table.lg td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.lg tr.lg-day td{ background:#eeffb9; } table.lg tr.lg-day td.lg-keep{ background:#fff; }
  table.lg tr.lg-sub td{ background:#ecc7ff; } table.lg tr.lg-tot td{ background:#fcf8e3; font-weight:700; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🛒 토더 발주 등록 <small>— 토더 「상품별 발주 목록」 엑셀을 올려 출고로 저장한다. 사업장코드·품목코드는 한 번 넣으면 다음부터 자동으로 채워진다</small></h2>

  <div class="card" id="upCard">
    <div class="hd">올리기
      <button class="btn btn-teal" id="drop" onclick="document.getElementById('fi').click()" style="margin-left:10px"
        title="엑셀(xlsx) — 여러 개를 한 번에 골라도 됩니다. 이 카드 위로 파일을 끌어다 놓아도 됩니다.&#10;읽는 칸 : 배송지명 · 발주번호 · 발주일시 · 상품명 · 단위 · 매입가 · 발주수량 · 출고수량 · 상품 상태">📄 토더 발주 엑셀</button>
      <button class="btn" onclick="mAdd()" title="엑셀 없이 줄을 만들어 직접 넣습니다 — 카톡으로 온 발주처럼. 발주일자·사업장코드·품목코드·수량·단가를 넣고 [저장]">✏️ 직접 입력</button>
      <span class="bar" style="margin-left:auto">
        <span id="pvInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
        <button class="btn" id="btnOnlyNo" onclick="onlyNoToggle()" style="display:none">미입력 줄만</button>
        <button class="btn btn-teal" id="btnSave" onclick="save()" style="display:none">💾 저장</button>
        <button class="btn btn-red" id="btnClear" onclick="pvClearAsk()" style="display:none" title="위 표에 올려 둔 줄(엑셀로 올린 줄 · 직접 입력한 줄)을 모두 비웁니다. 저장된 토더 발주는 그대로입니다">🧹 전체 비우기</button>
      </span>
    </div>
    <input type="file" id="fi" accept=".xlsx,.xls" multiple style="display:none" onchange="onFiles(this.files); this.value=''">
    <div class="tw" id="pvWrap" style="display:none;max-height:56vh">
      <table class="g"><thead><tr>
        <%-- ★칸 차례는 아래 「저장된 토더 발주」 목록과 같게 한다 (2026-10-02 사용자 「1번(저장 목록)과 동일한 형식으로 입력되게 — 지금은 우측에 판매가 등이 없음」) —
             발주일자 · 발주번호 · 번호 · 구분 · 배송지명 · 사업장코드 · 상품명 · 품목코드 · 단위 · 수량 · 판매가 · 금액. 엑셀로 올린 줄도 직접 입력 줄도 같은 칸이다.
             종전엔 No · 발주일자 · 발주번호 · 사업장코드 · 배송지명 · 품목코드 · 상품명 · 단위 · 수량 · 단가 · 상태 였고 금액 칸이 없었다. --%>
        <th><input type="checkbox" id="pvAll" checked onchange="pvAllChk(this)"></th><th title="✕ = 그 줄을 화면에서 뺍니다(저장된 것과는 무관) — 맨 오른쪽 끝에 있을 때는 표를 옆으로 밀어야 보였다(2026-10-02)">빼기</th><th>발주일자</th><th>발주번호</th><th title="토더 엑셀의 no 그대로 · 직접 입력 줄은 저장할 때 매깁니다">번호</th><th>구분</th><th>배송지명</th>
        <th title="우리 사업장코드 — 한 번 넣으면 같은 배송지명의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">사업장코드</th><th>상품명</th>
        <th title="우리 품목코드(상품코드) — 한 번 넣으면 같은 상품명의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">품목코드</th>
        <th>단위</th><th>수량</th><th title="판매가(부가세 포함 — 토더 엑셀의 매입가)">판매가</th><th title="수량 × 판매가(부가세 포함)">금액</th><th>상태</th></tr></thead>
        <tbody id="pvBody"></tbody></table>
    </div>
    <div class="note" id="pvNote" style="display:none">· 주황 칸 = 넣어야 하는 칸 · 파랑 = 자동으로 채운 값(「자동」 = 지난 저장, 「추정」 = 사업장 마스터 이름과 맞춰 본 것 — 확인 필요) · 초록 = 마스터에 있는 코드 · 노랑 = 마스터에 없는 코드(<b>저장 안 됨</b> — 사업장·상품 마스터에 먼저 등록) · 코드가 둘 다 든 줄만 저장된다 · 저장한 뒤에도 아래 목록에서 코드를 고칠 수 있다</div>
  </div>

  <div class="card">
    <div class="hd">저장된 토더 발주 <small>— 발주일자 기준</small>
      <span class="bar" style="margin-left:auto">
        <input type="date" id="fr"> <span class="dim">~</span> <input type="date" id="to">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn" onclick="lgOpen()" title="지난달의 토더 발주를 마감장부(유형별 매출원장 — 거래처별 · 일계 · 소계 · 합계) 모양으로 보고 엑셀로 냅니다">📒 토더 마감장부</button>
        <button class="btn btn-red" onclick="delSel()">🗑 선택 삭제</button>
        <span id="lsInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
      </span>
    </div>
    <div class="tw" id="lsWrap" style="max-height:50vh"><table class="g"><thead><tr>
      <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th><th>발주일자</th><th>발주번호</th><th title="토더 엑셀의 no — 반품이 (발주번호, 번호)로 온다">번호</th><th>구분</th><th>배송지명</th><th>사업장코드</th><th>상품명</th><th>품목코드</th><th>단위</th>
      <th title="고쳐서 Enter — 반품은 여기서 수량을 줄인다(0 = 전량 반품). 재고를 다시 맞춘다">수량 ✏️</th><th title="판매가(부가세 포함 — 토더 엑셀의 매입가). 고쳐서 Enter">판매가 ✏️</th><th title="매출 = 수량 × 판매가(부가세 포함) — 거래처 「토더」">금액</th><th>비고</th><th>올린 파일</th><th>등록</th></tr></thead>
      <tbody id="lsBody"><tr><td colspan="16" class="msg">[🔍 조회]를 누르세요.</td></tr></tbody></table></div>
  </div>
</div>
<%-- 마감장 창 (2026-10-02) — 예시 엑셀 「유형별 매출원장 전체조회」와 같은 칸 · 같은 색. 회사 이름은 엑셀 머리 칸에 쓴다 --%>
<span id="compNm" style="display:none"><c:out value="${sessionScope.s_comp_nm}"/></span>
<div id="lgPop" onclick="if(event.target===this) lgClose()">
  <div class="lg-box">
    <div class="lg-hd">
      <span style="font-size:13px;font-weight:800;color:#125a4e;background:#e3f2ee;border-radius:7px;padding:3px 9px">📒 토더 마감장부</span>
      <span id="lgTitle">[테그글로벌-코네트] 유형별 매출원장 전체조회</span>
      <%-- 창 안에서 기간을 바꿔 다시 조회 (2026-10-02 사용자 「마감장부에서도 날짜 수정 가능하게 · 다시 조회 가능하게」).
           처음 값 = 지난달 한 달(같은 날 「이전달 월 기본으로」). 여기서 바꿔도 목록의 기간은 그대로 둔다 — [지난달][이번 달] --%>
      <input type="date" id="lgFr" onkeydown="if(event.key==='Enter') lgLoad()"> <span class="dim">&#126;</span> <input type="date" id="lgTo" onkeydown="if(event.key==='Enter') lgLoad()">
      <button class="btn btn-teal" onclick="lgLoad()">🔍 조회</button>
      <button class="btn" style="padding:0 10px" onclick="lgMonth(-1)" title="지난달 1일부터 말일까지로 조회합니다">지난달</button>
      <button class="btn" style="padding:0 10px" onclick="lgMonth(0)" title="이번 달 1일부터 말일까지로 조회합니다">이번 달</button>
      <span id="lgPeriod" style="display:none"></span>
      <%-- [엑셀 출력][닫기]는 첫 줄 오른쪽 끝에 붙여 두고, 유형 칸은 둘째 줄로 내린다 (2026-10-02 사용자 「닫기 엑셀출력 뒤로 · 유형 닫기 위치로」) --%>
      <span class="lg-act">
        <button class="btn btn-teal" onclick="lgXls()">📥 엑셀 출력</button>
        <button class="btn" onclick="lgClose()">닫기</button>
      </span>
      <div class="lg-hd2">
        <label title="제목과 엑셀의 「유형」 칸에 들어가는 이름 — 고치면 이 PC 에 기억합니다">유형</label>
        <input type="text" id="lgType" value="테그글로벌-코네트" onchange="lgTypeSave()">
        <span id="lgInfo" class="dim" style="font-size:12.5px;font-weight:700;color:#125a4e;margin-left:8px"></span>   <%-- 건수·합계는 둘째 줄에(첫 줄이 넘쳐 단추가 밀리지 않게) --%>
      </div>
    </div>
    <div class="lg-bd"><table class="lg"><thead><tr>
      <th>거래처</th><th>일자</th><th>번호</th><th>NO</th><th>구분</th><th>상품명</th><th>규격</th><th>수량</th><th>단가</th><th>금액</th><th>할인액</th><th>판매액</th><th title="처음부터 그 줄까지의 누계">계</th><th>S</th><th>행사</th><th>비고</th></tr></thead>
      <tbody id="lgBody"></tbody></table></div>
  </div>
</div>
<datalist id="bizList"></datalist><datalist id="prodList"></datalist>

<script>
var CTX='${pageContext.request.contextPath}';
function n(v){ if(v==null) return 0; var x=parseFloat(String(v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return n(v).toLocaleString('ko-KR'); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }); }
function ok(m){ _alertBox(m,{icon:'✅'}); } function err(m){ _alertBox(m,{icon:'⚠️'}); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }

/* ── 기준자료 : 사업장·상품 마스터(이름 확인·찾기) + 자동 매칭(지난 저장) ── */
var _biz={}, _prod={}, _map={ biz:{}, item:{} }, _pv=[], _ls=[], _onlyNo=false;
function loadMasters(){
  var p1=post('/mangr/clientList.do','findData=').then(function(r){ return r.json(); }).then(function(j){ _biz={}; var h=[]; ((j&&j.data)||[]).forEach(function(o){ if(!o.bizCd) return; _biz[String(o.bizCd)]=o.bizNm||''; h.push('<option value="'+esc((o.bizNm||'')+' ['+o.bizCd+']')+'"></option>'); }); document.getElementById('bizList').innerHTML=h.join(''); }).catch(function(){});
  var p2=post('/prod/prodList.do','').then(function(r){ return r.json(); }).then(function(j){ _prod={}; var h=[]; ((j&&j.data)||[]).forEach(function(o){ if(!o.prodCd) return; _prod[String(o.prodCd)]=o.prodNm||''; _spec[String(o.prodCd)]=o.spec||''; h.push('<option value="'+esc((o.prodNm||'')+' ['+o.prodCd+']')+'"></option>'); }); document.getElementById('prodList').innerHTML=h.join(''); }).catch(function(){});
  var p3=post('/prod/extItemList.do','').then(function(r){ return r.json(); }).then(function(j){ ((j&&j.data)||[]).forEach(function(o){ if(o.extItemCd && !_prod[String(o.extItemCd)]) _prod[String(o.extItemCd)]=(o.extItemNm||'')+' 〔매칭코드〕'; }); }).catch(function(){});
  var p4=post('/shipout/toderPoMap.do','').then(function(r){ return r.json(); }).then(function(j){ _map={ biz:(j&&j.biz)||{}, item:(j&&j.item)||{} }; }).catch(function(){});
  return Promise.all([p1,p2,p3,p4]).then(function(){ if(_pv.length){ autoFill(); pvRender(); } });
}

/* ── 엑셀 읽기 ── */
var HDR={ no:['no','No','NO','번호'], bizNm:['배송지명'], ordNo:['발주번호'], ordDttm:['발주일시'], dueDt:['출고마감일'], itemNm:['상품명'], unit:['단위'], price:['매입가'], ordQty:['발주수량'], outQty:['출고수량'], status:['상품 상태','상품상태','상태'] };
function cellTxt(v){ if(v==null) return ''; if(v instanceof Date) return ymd(v)+' '+('0'+v.getHours()).slice(-2)+':'+('0'+v.getMinutes()).slice(-2)+':'+('0'+v.getSeconds()).slice(-2); return String(v).trim(); }
function parseWb(wb, fileNm){
  var brand=(/^(.+?)[_\s]*상품별/.exec(fileNm)||[])[1]||'', out=[];
  wb.SheetNames.forEach(function(sn){
    var aoa=XLSX.utils.sheet_to_json(wb.Sheets[sn],{ header:1, raw:true, defval:'' }), hr=-1, col={};
    for(var r=0;r<Math.min(aoa.length,30);r++){ var row=aoa[r].map(cellTxt); if(row.indexOf('배송지명')>=0 && row.indexOf('상품명')>=0){ hr=r; for(var k in HDR){ col[k]=-1; HDR[k].forEach(function(nm){ if(col[k]<0) col[k]=row.indexOf(nm); }); } break; } }
    if(hr<0) return;
    for(var i=hr+1;i<aoa.length;i++){ var a=aoa[i], g=function(k){ return col[k]>=0? cellTxt(a[col[k]]) : ''; };
      var bizNm=g('bizNm'), itemNm=g('itemNm'); if(!bizNm && !itemNm) continue;
      var dttm=g('ordDttm'), dlv=d10(dttm), st=g('status'), oq=n(g('outQty')), rq=n(g('ordQty'));
      out.push({ no:g('no'), seq:out.length, chk: !/취소|반품/.test(st), brand:brand, fileNm:fileNm, bizNm:bizNm, ordNo:g('ordNo'), ordDttm:dttm, dlvDt:dlv, dueDt:d10(g('dueDt')), itemNm:itemNm, unit:g('unit'), price:n(g('price')), qty:(oq||rq), status:st, bizCd:'', itemCd:'', bizAuto:false, itemAuto:false });
    }
  });
  return out;
}
function onFiles(files){
  var list=Array.prototype.slice.call(files||[]); if(!list.length) return;
  var jobs=list.map(function(f){ return new Promise(function(res){ var rd=new FileReader(); rd.onload=function(e){ try{ var wb=XLSX.read(new Uint8Array(e.target.result),{ type:'array', cellDates:true }); res({ nm:f.name, rows:parseWb(wb,f.name) }); }catch(x){ res({ nm:f.name, rows:[], err:x.message }); } }; rd.readAsArrayBuffer(f); }); });
  Promise.all(jobs).then(function(rs){
    var bad=[], add=[]; rs.forEach(function(r){ if(!r.rows.length) bad.push(esc(r.nm)+(r.err?' — '+esc(r.err):' — 머리 줄(배송지명·상품명)을 못 찾았습니다')); else add=add.concat(r.rows); });
    /* 같은 (발주번호, 배송지명, 상품명) 은 나중 것으로 */
    var seen={}; _pv.concat(add).forEach(function(x){ seen[x.manual ? ('(직접)'+x.mid) : (x.ordNo+'|'+x.bizNm+'|'+x.itemNm)]=x; }); _pv=Object.keys(seen).map(function(k){ return seen[k]; });
    /* 엑셀에 적힌 차례 그대로(파일 이름 → 줄 차례). 여러 파일이면 파일별로 이어 붙는다 */
    _pv.sort(function(a,b){ return String(a.fileNm||'').localeCompare(String(b.fileNm||'')) || (a.seq-b.seq); });
    autoFill(); pvRender();
    if(bad.length) err('읽지 못한 파일<br><span style="font-size:13px">'+bad.join('<br>')+'</span>');
  });
}
/* 이름 다듬기 — 브랜드 말·빈칸·괄호·끝의 「점」을 떼고 견준다 : 토더 「강남역점」 ↔ 마스터 「샐러링 강남역」 */
function normNm(s, brand){ s=String(s||''); if(brand) s=s.split(brand).join(''); return s.replace(/\([^)]*\)/g,'').replace(/\s+/g,'').replace(/점$/,'').toLowerCase(); }
function guessBiz(x){
  var key=normNm(x.bizNm, x.brand); if(!key) return '';
  var hit=[]; for(var cd in _biz){ var nm=_biz[cd]; if(x.brand && String(nm).indexOf(x.brand)<0) continue; if(normNm(nm, x.brand)===key) hit.push(cd); }
  return hit.length===1 ? hit[0] : '';   /* 하나로 떨어질 때만 */
}
function autoFill(){ _pv.forEach(function(x){
  if(!x.bizCd && _map.biz[x.bizNm]){ x.bizCd=_map.biz[x.bizNm]; x.bizAuto=true; x.bizGuess=false; }
  if(!x.bizCd){ var g=guessBiz(x); if(g){ x.bizCd=g; x.bizAuto=true; x.bizGuess=true; } }
  if(!x.itemCd && _map.item[x.itemNm]){ x.itemCd=_map.item[x.itemNm]; x.itemAuto=true; } }); }
function cdCls(cd, mst, auto){ if(!cd) return ''; return mst[cd]!=null ? (auto?'auto':'ok') : 'bad'; }
function pvRender(){
  var has=_pv.length>0;
  ['pvWrap','pvNote'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  /* 미리보기 높이 막대(ui-gridgrip.js 가 #pvWrap 바로 뒤에 붙인 .kgg)도 표와 같이 숨긴다 — 올린 줄이 없을 때 막대만 떠 있지 않게 */
  var pg=document.getElementById('pvWrap').nextElementSibling; if(pg && pg.classList.contains('kgg')) pg.style.display=has?'':'none';
  ['btnSave','btnClear','btnOnlyNo'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  document.getElementById('btnOnlyNo').textContent=_onlyNo?'전체 줄 보기':'미입력 줄만';
  var tb=document.getElementById('pvBody');
  tb.innerHTML=_pv.map(function(x,i){
    if(_onlyNo && x.bizCd && x.itemCd) return '';
    if(x.manual) return mRow(x, i);   /* 직접 입력 줄 — 칸마다 입력칸 (2026-10-02) */
    var bn=_biz[x.bizCd], pn=_prod[x.itemCd];
    return '<tr class="'+(x.chk?'':'off')+'"><td><input type="checkbox" '+(x.chk?'checked':'')+' onchange="_pv['+i+'].chk=this.checked; pvRender()"></td><td><button class="btn" style="height:26px;padding:0 7px;color:#c0392b" title="이 줄을 화면에서 뺍니다(저장된 것과는 무관)" onclick="mDel('+i+')">✕</button></td><td>'+esc(x.dlvDt)+'</td><td>'+esc(x.ordNo)+'</td><td><b>'+esc(x.no!==''&&x.no!=null?x.no:(i+1))+'</b></td><td>토더</td>'
      +'<td class="l">'+esc(x.bizNm)+'</td>'
      +'<td class="l">'+(x.bizCd?'<span class="sub nmf'+(bn==null?' warn':'')+'">'+(x.bizAuto?'<span class="bd auto" title="'+(x.bizGuess?'사업장 마스터의 이름과 맞춰 본 추정 — 맞는지 확인하세요':'지난 저장에서 가져온 값')+'">'+(x.bizGuess?'추정':'자동')+'</span> ':'')+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span>':'')+'<input type="text" list="bizList" class="'+cdCls(x.bizCd,_biz,x.bizAuto)+'" value="'+esc(x.bizCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'biz\',this.value)"></td>'
      +'<td class="l">'+esc(x.itemNm)+'</td>'
      +'<td class="l">'+(x.itemCd?'<span class="sub nmf'+(pn==null?' warn':'')+'">'+(x.itemAuto?'<span class="bd auto">자동</span> ':'')+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span>':'')+'<input type="text" list="prodList" class="'+cdCls(x.itemCd,_prod,x.itemAuto)+'" value="'+esc(x.itemCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'item\',this.value)"></td>'
      +'<td>'+esc(x.unit)+'</td><td class="r"><b>'+fmt(x.qty)+'</b></td><td class="r">'+(x.price?fmt(x.price):'')+'</td><td class="r"><b>'+fmt(n(x.qty)*n(x.price))+'</b></td>'
      +'<td><span class="bd '+(/취소|반품/.test(x.status)?'cx':'st')+'">'+esc(x.status)+'</span></td></tr>';
  }).join('');
  pvInfoUpd();
}
function pvInfoUpd(){
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(function(x){ return x.bizCd&&x.itemCd&&x.dlvDt&&x.qty; });
  var unk=rdy.filter(function(x){ return _biz[x.bizCd]==null || _prod[x.itemCd]==null; }).length;   /* 마스터에 없는 코드 — 저장 막힘(2026-09-22) */
  document.getElementById('pvInfo').textContent='올린 줄 '+_pv.length+' · 선택 '+sel.length+' · 저장 가능 '+(rdy.length-unk)+(sel.length-rdy.length?' · 코드 빈 줄 '+(sel.length-rdy.length):'')+(unk?' · 마스터에 없는 코드 '+unk+'줄(저장 막힘)':'');
  document.getElementById('pvAll').checked=_pv.every(function(x){ return x.chk; });
}
/* 코드 한 번 넣으면 같은 이름의 빈 칸(또는 자동으로 채워졌던 칸)에 같이 */
/* 목록에서 고른 「명칭 [코드]」 → 코드. 코드만 친 것은 그대로, 명칭만 정확히 친 것은 마스터에서 찾는다 */
function pickCd(v, mst){
  v=String(v||'').trim(); var m=/\[([^\[\]]+)\]\s*$/.exec(v); if(m) return m[1].trim();
  if(mst[v]!=null) return v;
  var hit=[]; for(var cd in mst){ if(String(mst[cd]).trim()===v) hit.push(cd); } return hit.length===1? hit[0] : v;
}
function setCd(i, kind, v){
  v=pickCd(v, kind==='biz'?_biz:_prod); var x=_pv[i]; if(!x) return;
  if(kind==='biz'){ var nm=x.bizNm; _pv.forEach(function(y){ if(y===x || (nm && !y.manual && y.bizNm===nm && (!y.bizCd || y.bizAuto))){ y.bizCd=v; y.bizAuto=false; y.bizGuess=false; } }); }
  else { var inm=x.itemNm; _pv.forEach(function(y){ if(y===x || (inm && !y.manual && y.itemNm===inm && (!y.itemCd || y.itemAuto))){ y.itemCd=v; y.itemAuto=false; } }); }
  if(x.manual) mFill(x, kind);   /* 직접 줄 — 그 품목의 마지막 토더 판매가·단위 */
  pvRender();
}
function pvAllChk(el){ _pv.forEach(function(x){ x.chk=el.checked; }); pvRender(); }
function onlyNoToggle(){ _onlyNo=!_onlyNo; pvRender(); }
function pvClear(){ _pv=[]; _onlyNo=false; pvRender(); }
/* 전체 비우기 — 위 표의 줄(엑셀 · 직접 입력)을 모두 치운다. 저장된 것은 건드리지 않는다.
   종전 이름 「업로드 취소」는 직접 입력 줄이 생긴 뒤로 「엑셀만 지우는 것」처럼 읽혀 헷갈렸다(2026-10-02). 한 번 묻고 비운다 */
function pvClearAsk(){
  if(!_pv.length){ if(window._toast) _toast('비울 줄이 없습니다.','info'); return; }
  var man=_pv.filter(function(x){ return x.manual; }).length, xl=_pv.length-man;
  _confirmBox({ icon:'🧹', okText:'비우기',
    msg:'위 표의 <b>'+_pv.length+'</b>줄을 모두 비웁니다.<br><span style="font-size:13px;color:#3d4d5c">'
      +(xl?'엑셀로 올린 줄 '+xl+'개':'')+(xl&&man?' · ':'')+(man?'직접 입력한 줄 '+man+'개':'')+' — 아직 저장하지 않은 내용은 사라집니다. 저장된 토더 발주는 그대로입니다.</span>',
    onOk:function(){ pvClear(); }, onCancel:function(){} });
}

function save(){
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(function(x){ return x.bizCd&&x.itemCd&&x.dlvDt&&x.qty; }), miss=sel.length-rdy.length;
  if(!rdy.length){ err('저장할 줄이 없습니다 — 사업장코드·품목코드를 넣으세요.'); return; }
  /* ★[2026-09-22 「사업장코드·품목코드 선택한 것에 대하여 없으면 등록 안 되게」] 마스터에 없는 코드가 든 줄이 있으면 저장하지 않는다.
       종전엔 「그래도 저장됩니다」였다 — 그런 줄은 재고에서 조용히 빠졌다. 서버(toderPoSave)도 같은 관문으로 거절한다. */
  var unk=rdy.filter(function(x){ return _biz[x.bizCd]==null || _prod[x.itemCd]==null; });
  if(unk.length){
    var ub={}, ui={}; unk.forEach(function(x){ if(_biz[x.bizCd]==null) ub[x.bizCd]=1; if(_prod[x.itemCd]==null) ui[x.itemCd]=1; });
    err('마스터에 없는 코드가 든 줄이 <b>'+unk.length+'</b>개 있어 저장하지 않았습니다.<br><span style="font-size:13px">'
      +(Object.keys(ub).length?'사업장코드 : <b>'+esc(Object.keys(ub).join(', '))+'</b> — 거래처관리(사업장)에 먼저 등록<br>':'')
      +(Object.keys(ui).length?'품목코드 : <b>'+esc(Object.keys(ui).join(', '))+'</b> — 상품코드등록·매칭코드에 먼저 등록<br>':'')
      +'노란 칸을 고치거나 그 줄의 체크를 빼고 다시 저장하세요.</span>');
    return;
  }
  mPrep(rdy);   /* 직접 입력 줄 — 배송지명·상품명·발주번호·줄 번호를 채운다 (2026-10-02) */
  /* 토더 = 매출(2026-09-22) — 매출 = 수량 × 판매가(엑셀 매입가, 부가세 포함). 판매가가 빈 줄은 매출 0 으로 들어가므로 알린다(막지는 않는다 — 저장 뒤 목록에서 고칠 수 있다) */
  var noPrice=rdy.filter(function(x){ return !(n(x.price)>0); }).length, amt=rdy.reduce(function(s,x){ return s+n(x.qty)*n(x.price); },0);
  _confirmBox({ icon:'💾', okText:'저장',
    msg:'토더 발주 <b>'+rdy.length+'</b>줄을 <b>출고 · 매출</b>로 저장합니다. 매출 <b>'+fmt(amt)+'</b>원(부가세 포함 · 거래처 「토더」).'
      +(noPrice?'<br><span style="color:#c0392b;font-size:13px">판매가(매입가)가 빈 줄 '+noPrice+'개 — 매출 0원으로 들어갑니다(저장 뒤 목록에서 고칠 수 있습니다).</span>':'')
      +(miss?'<br><span style="color:#b45309;font-size:13px">코드가 빈 '+miss+'줄은 저장하지 않습니다(화면에 남습니다).</span>':'')
       +'<br><span style="font-size:13px;color:#3d4d5c">같은 발주번호·배송지명·상품명이 이미 있으면 새것으로 대체합니다.</span>',
    onOk:function(){
      var b=document.getElementById('btnSave'); b.disabled=true;
      var brand=(rdy[0].brand||'');
      post('/shipout/toderPoSave.do',{ brand:brand, rows:rdy.map(function(x){ return { no:x.no, dlvDt:x.dlvDt, bizCd:x.bizCd, bizNm:x.bizNm, itemCd:x.itemCd, itemNm:x.itemNm, unit:x.unit, qty:x.qty, ordNo:x.ordNo, ordDttm:x.ordDttm, dueDt:x.dueDt, price:x.price||'', status:x.status, fileNm:x.fileNm }; }) },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){
          var warn=/\|STOCKFAIL:(.*)$/.exec(t), cnt=parseInt(t,10)||rdy.length;
          rdy.forEach(function(x){ _map.biz[x.bizNm]=x.bizCd; _map.item[x.itemNm]=x.itemCd; });
          _pv=_pv.filter(function(x){ return rdy.indexOf(x)<0; }); pvRender();
          var ds=rdy.map(function(x){ return x.dlvDt; }).sort(); document.getElementById('fr').value=ds[0]; document.getElementById('to').value=ds[ds.length-1]; load();
          ok('토더 발주 <b>'+cnt+'</b>줄을 저장했습니다.'+(_pv.length?'<br><span style="font-size:13px">코드가 빈 '+_pv.length+'줄이 화면에 남아 있습니다.</span>':'')+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':''));
        })
        .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
        .then(function(){ b.disabled=false; });
    }, onCancel:function(){} });
}

/* ── 저장된 목록 ── */
function load(){
  document.getElementById('lsBody').innerHTML='<tr><td colspan="16" class="msg">조회 중…</td></tr>';
  post('/shipout/toderPoList.do','frDt='+encodeURIComponent(document.getElementById('fr').value)+'&toDt='+encodeURIComponent(document.getElementById('to').value))
    .then(function(r){ return r.json(); }).then(function(j){ _ls=(j&&j.data)||[]; lsRender(); })
    .catch(function(e){ document.getElementById('lsBody').innerHTML='<tr><td colspan="16" class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsRender(){
  var tb=document.getElementById('lsBody'); document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="16" class="msg">저장된 토더 발주가 없습니다.</td></tr>'; document.getElementById('lsInfo').textContent=''; return; }
  var q=0, amt=0;
  tb.innerHTML=_ls.map(function(x,i){ q+=n(x.qty); amt+=n(x.qty)*n(x.salePrice);
    /* ★[2026-09-22 「저장 후 품목코드·사업장코드 수정 가능하게」] 두 코드 칸을 입력칸으로 — 고르면 확인창 뒤 lsCd(이름 단위로 고친다) */
    var bn=_biz[x.bizCd], pn=_prod[x.itemCd];
    return '<tr><td><input type="checkbox" class="lchk" data-i="'+i+'"></td><td>'+d10(x.dlvDt)+'</td><td>'+esc(x.ordNo)+'</td><td><b>'+esc(x.lineNo)+'</b></td><td>'+esc(x.dcNm)+'</td><td class="l">'+esc(x.bizNm)+'</td>'
      +'<td class="l"><span class="sub nmf'+(bn==null?' warn':'')+'">'+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span><input type="text" list="bizList" class="'+(bn==null?'bad':'ok')+'" value="'+esc(x.bizCd)+'" title="고르거나 쳐서 바꾸면 같은 배송지명의 저장된 줄이 모두 바뀝니다" onchange="lsCd('+i+',\'biz\',this)"></td>'
      +'<td class="l">'+esc(x.itemNm)+'</td><td class="l"><span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span><input type="text" list="prodList" class="'+(pn==null?'bad':'ok')+'" value="'+esc(x.itemCd)+'" title="고르거나 쳐서 바꾸면 같은 상품명의 저장된 줄이 모두 바뀌고 재고도 다시 맞춥니다" onchange="lsCd('+i+',\'item\',this)">'+(x.prodCd&&x.prodCd!==x.itemCd?'<span class="sub">주코드 '+esc(x.prodCd)+'</span>':'')+'</td><td>'+esc(x.unit)+'</td>'
      /* ★[2026-09-22 「반품은 수정으로」 · 「토더 = 매출」] 수량·판매가 = 입력칸(Enter 또는 칸을 벗어나면 lsRow) · 금액 = 수량 × 판매가(부가세 포함) */
      +'<td class="r"><input type="text" class="num'+(n(x.qty)===0?' bad':'')+'" value="'+esc(fmtIn(x.qty))+'" data-v="'+esc(fmtIn(x.qty))+'" title="반품이면 줄여서 Enter — 0 = 전량 반품. 그 날 재고를 다시 맞춘다" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsRow('+i+',this,\'qty\')"></td>'
      +'<td class="r"><input type="text" class="num'+(x.salePrice==null||x.salePrice===''?' bad':'')+'" value="'+esc(fmtIn(x.salePrice))+'" data-v="'+esc(fmtIn(x.salePrice))+'" title="판매가(부가세 포함). 비면 매출 0" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsRow('+i+',this,\'price\')"></td>'
      +'<td class="r"><b>'+fmt(n(x.qty)*n(x.salePrice))+'</b></td>'
      +'<td class="l dim" style="max-width:260px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.remark)+'">'+esc(x.remark)+'</td><td class="l dim" style="max-width:200px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.srcFile)+'">'+esc(x.srcFile)+'</td><td class="dim">'+esc(String(x.uploadDttm||'').slice(0,16))+'<br>'+esc(x.regUser)+'</td></tr>'; }).join('');
  document.getElementById('lsInfo').textContent=_ls.length+'줄 · 수량 '+fmt(q)+' · 매출 '+fmt(amt)+'원(부가세 포함)';
}
/* 입력칸 값 — 콤마 없이(고칠 때 숫자만 치면 된다). 비면 빈 칸 */
function fmtIn(v){ if(v==null||v==='') return ''; var x=n(v); return String(Math.round(x*100)/100); }
/* 저장된 한 줄의 수량·판매가 고치기 (2026-09-22 「지금까지 반품은 수정으로 처리」) — 키는 삭제와 같은 (발주번호, 배송지명, 상품명).
     바꾼 칸만 새 값, 다른 칸은 지금 값 그대로 보낸다. 서버가 비고에 「수정 옛값→새값」을 남기고 그 날 재고를 다시 맞춘다. */
function lsRow(i, el, fld){
  var x=_ls[i]; if(!x) return;
  var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/,/g,'').trim();
  if(v===old) return;
  if(fld==='qty' && !/^\d+$/.test(v)){ el.value=old; err('수량은 0 이상의 정수로 넣으세요(0 = 전량 반품).'); return; }
  if(fld==='price' && v!=='' && !(/^\d+(\.\d+)?$/.test(v))){ el.value=old; err('판매가는 숫자로 넣으세요(부가세 포함).'); return; }
  var qty = fld==='qty' ? v : fmtIn(x.qty), price = fld==='price' ? v : fmtIn(x.salePrice);
  var what = fld==='qty' ? ('수량 <b>'+esc(old||'0')+'</b> → <b>'+esc(v)+'</b>'+(n(v)<n(old)?' <span style="color:#b45309">(반품 '+fmt(n(old)-n(v))+')</span>':'')) : ('판매가 <b>'+esc(old||'없음')+'</b> → <b>'+esc(v||'없음')+'</b>');
  _confirmBox({ icon:'✏️', okText:'고치기',
    msg:esc(x.bizNm)+' · '+esc(x.itemNm)+'<br>'+what
      +'<br><span style="font-size:13px;color:#3d4d5c">매출 '+fmt(n(qty)*n(price))+'원(부가세 포함)'+(fld==='qty'?' · 그 날('+d10(x.dlvDt)+') 재고를 다시 맞춥니다':'')+'. 비고에 수정 기록이 남습니다.</span>',
    onOk:function(){
      post('/shipout/toderPoRow.do',{ ordNo:x.ordNo, bizNm:x.bizNm, itemNm:x.itemNm, qty:qty, price:price },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); load();
          if(warn) err('고쳤지만 재고 반영에 실패했습니다 — '+esc(warn[1])+'<br><span style="font-size:13px">[출고반영 재집계]를 눌러 주세요.</span>'); else if(window._toast) _toast('고쳤습니다','ok'); })
        .catch(function(e){ el.value=old; err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
    }, onCancel:function(){ el.value=old; } });
}
/* 저장된 줄의 코드 고치기 (2026-09-22) — 이름(배송지명 / 상품명) 단위로 저장된 줄을 모두 바꾼다(조회 기간 밖 포함).
     코드는 이름에 붙는 값이라 한 줄만 바꾸면 같은 이름의 다른 줄과 다음 업로드의 자동 매칭이 옛 코드로 남는다.
     새 코드도 마스터에 있어야 한다(서버 toderPoCode 가 한 번 더 본다). 품목을 바꾸면 서버가 그 날짜들의 재고를 다시 맞춘다. */
function lsCd(i, kind, el){
  var x=_ls[i]; if(!x) return;
  var mst=kind==='biz'?_biz:_prod, old=kind==='biz'?x.bizCd:x.itemCd, nm=kind==='biz'?x.bizNm:x.itemNm, cd=pickCd(el.value, mst);
  var lab=kind==='biz'?'사업장코드':'품목코드', nmLab=kind==='biz'?'배송지명':'상품명';
  if(!cd || cd===old){ el.value=old; return; }
  if(mst[cd]==null){ el.value=old; err(lab+' <b>'+esc(cd)+'</b> 는 마스터에 없습니다 — '+(kind==='biz'?'거래처관리(사업장)':'상품코드등록·매칭코드')+'에 먼저 등록하세요.'); return; }
  var same=_ls.filter(function(y){ return (kind==='biz'?y.bizNm:y.itemNm)===nm; }).length;
  _confirmBox({ icon:'✏️', okText:'고치기',
    msg:nmLab+' <b>'+esc(nm)+'</b> 의 '+lab+'를<br><b>'+esc(old)+'</b> → <b>'+esc(cd)+'</b> ('+esc(mst[cd])+') 로 고칩니다.'
      +'<br><span style="font-size:13px;color:#3d4d5c">같은 '+nmLab+'으로 저장된 줄이 모두 바뀝니다(지금 목록 '+same+'줄 · 조회 기간 밖 포함).'
      +(kind==='item'?' 그 날짜들의 재고를 다시 맞춥니다.':'')+' 다음 업로드의 자동 매칭도 새 코드로 채워집니다.</span>',
    onOk:function(){
      post('/shipout/toderPoCode.do',{ kind:kind, nm:nm, cd:cd },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); _map[kind][nm]=cd; load();
          ok(lab+'를 고쳤습니다 — <b>'+(parseInt(t,10)||0)+'</b>줄.'+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':'')); })
        .catch(function(e){ el.value=old; err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
    }, onCancel:function(){ el.value=old; } });
}
function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function delSel(){
  var keys=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) keys.push({ dlvDt:x.dlvDt, ordNo:x.ordNo, bizNm:x.bizNm, itemNm:x.itemNm }); });
  if(!keys.length){ err('삭제할 줄을 고르세요.'); return; }
  _confirmBox({ icon:'🗑', okText:'삭제', msg:'고른 토더 발주 <b>'+keys.length+'</b>줄을 삭제합니다.<br><span style="font-size:13px;color:#3d4d5c">출고 자료에서 빠지고 재고도 다시 맞춥니다. (자동 매칭용 이름 → 코드 짝은 남습니다)</span>',
    onOk:function(){ post('/shipout/toderPoDelete.do',{ keys:keys },true).then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); load(); ok((parseInt(t,10)||0)+'줄을 삭제했습니다.'+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':'')); })
      .catch(function(e){ err('삭제하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }, onCancel:function(){} });
}


/* ── 마감장(유형별 매출원장) 조회 · 엑셀 (2026-10-02 사용자 「토더발주에 대장 조회 및 엑셀출력 추가」 · 「토더 발주 이런 식으로 마감장」) ──
   옛 시스템의 「유형별 매출원장 전체조회」 엑셀(예: D:\코네트\테그,샐러링 8월.xlsx)과 같은 모양으로 저장된 토더 발주를 보여 주고 엑셀로 낸다.
     · 칸 : 거래처 · 일자 · 번호 · NO · 구분 · 상품명 · 규격 · 수량 · 단가 · 금액 · 할인액 · 판매액 · 계 · S · 행사 · 비고
     · 거래처 = 사업장 마스터 이름(없으면 토더 배송지명) — 거래처의 첫 줄에만 적는다. 번호 = 토더 발주번호 · NO = 그 발주의 줄 번호.
     · 상품명·규격 = 우리 상품 마스터 것(품목코드가 매칭코드면 그 주코드 상품). 단가 = 판매가(부가세 포함) · 금액 = 수량 × 단가 · 할인액 0 · 판매액 = 금액.
     · 계 = 처음부터 그 줄까지의 누계. 날짜가 바뀔 때 「일계」(연두), 거래처가 바뀔 때 「소계」(보라), 맨 끝에 「합계」(크림).
     · 수량 0 줄(전량 반품)은 뺀다 — 매출이 아니다. 차례 = 사업장코드 → 일자 → 발주번호 → 줄 번호.
     · 기간 = 아래 목록의 조회 기간. 자료는 그때 새로 읽는다(/shipout/toderPoList.do) — 서버는 그대로다. */
var _spec={}, _lg=null;
/* 유형 이름 기본값 = 「테그글로벌-코네트」 (같은 날 사용자 「테그글로벌-코네트 처럼 변경」) — 예시 엑셀의 유형 이름 그대로. 창에서 고치면 이 PC 에 기억한다 */
var LG_TYPE_DEF='테그글로벌-코네트';
function lgTypeNm(){ var e=document.getElementById('lgType'); return (String(e&&e.value||'').trim())||LG_TYPE_DEF; }
function lgBuild(rows){
  var list=(rows||[]).filter(function(x){ return n(x.qty)>0; }).map(function(x){
    var pc=(x.prodCd && _prod[x.prodCd]!=null) ? String(x.prodCd) : String(x.itemCd||'');
    return { biz:String(_biz[x.bizCd]||x.bizNm||''), bizCd:String(x.bizCd||''), dt:d10(x.dlvDt), no:String(x.ordNo||''), ln:String(x.lineNo||''),
      nm:String(_prod[pc]!=null ? _prod[pc] : (x.itemNm||'')).replace(' 〔매칭코드〕',''), spec:String(_spec[pc]||''),
      qty:n(x.qty), price:n(x.salePrice), amt:Math.round(n(x.qty)*n(x.salePrice)) }; });
  var cmp=function(a,b){ return String(a).localeCompare(String(b),'ko',{ numeric:true }); };
  list.sort(function(a,b){ return cmp(a.bizCd,b.bizCd) || cmp(a.biz,b.biz) || cmp(a.dt,b.dt) || cmp(a.no,b.no) || cmp(a.ln,b.ln); });
  var out=[], run=0, tot=0, i=0, bizCnt=0;
  while(i<list.length){
    var bk=list[i].bizCd+'|'+list[i].biz, sub=0, first=true; bizCnt++;
    while(i<list.length && (list[i].bizCd+'|'+list[i].biz)===bk){
      var dt=list[i].dt, day=0;
      while(i<list.length && (list[i].bizCd+'|'+list[i].biz)===bk && list[i].dt===dt){
        var r=list[i]; run+=r.amt; day+=r.amt;
        out.push({ k:'row', biz:(first?r.biz:''), dt:r.dt, no:r.no, ln:r.ln, nm:r.nm, spec:r.spec, qty:r.qty, price:r.price, amt:r.amt, run:run });
        first=false; i++; }
      out.push({ k:'day', amt:day }); sub+=day; }
    out.push({ k:'sub', amt:sub }); tot+=sub; }
  if(list.length) out.push({ k:'tot', amt:tot });
  return { lines:out, cnt:list.length, bizCnt:bizCnt, tot:tot };
}
function lgOpen(){
  /* ★처음 값 = «지난달» 1일부터 말일까지 (2026-10-02 사용자 「이전달 월 기본으로」) — 마감장부는 지난달 치를 마감하며 본다.
       종전엔 아래 목록의 조회 기간을 가져왔다. 다른 기간은 창에서 날짜를 고치거나 [이번 달]을 누른다. */
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth()-1, 1), b=new Date(t.getFullYear(), t.getMonth(), 0);
  document.getElementById('lgFr').value=ymd(a); document.getElementById('lgTo').value=ymd(b);
  document.getElementById('lgPop').classList.add('on');
  try{ var sv=localStorage.getItem('tdLedgerType'); if(sv && sv!=='토더') document.getElementById('lgType').value=sv; }catch(e){}
  lgLoad();
}
/* 그 달 1일부터 말일까지로 조회. d = 0 이번 달 · -1 지난달 */
function lgMonth(d){ var t=new Date(), a=new Date(t.getFullYear(), t.getMonth()+d, 1), b=new Date(t.getFullYear(), t.getMonth()+d+1, 0);
  document.getElementById('lgFr').value=ymd(a); document.getElementById('lgTo').value=ymd(b); lgLoad(); }
/* 창의 기간으로 다시 읽는다 */
function lgLoad(){
  var fr=document.getElementById('lgFr').value, to=document.getElementById('lgTo').value;
  if(!fr || !to){ err('조회 기간을 넣으세요.'); return; }
  if(fr>to){ err('시작일이 끝일보다 늦습니다.'); return; }
  document.getElementById('lgBody').innerHTML='<tr><td colspan="16" class="msg">불러오는 중…</td></tr>'; document.getElementById('lgInfo').textContent='';
  post('/shipout/toderPoList.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(j){ _lg=lgBuild((j&&j.data)||[]); _lg.fr=fr; _lg.to=to; lgRender(); })
    .catch(function(e){ _lg=null; document.getElementById('lgBody').innerHTML='<tr><td colspan="16" class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lgClose(){ document.getElementById('lgPop').classList.remove('on'); }
function lgTypeSave(){ try{ localStorage.setItem('tdLedgerType', lgTypeNm()); }catch(e){} lgRender(); }
function lgRender(){
  if(!_lg) return;
  document.getElementById('lgTitle').textContent='['+lgTypeNm()+'] 유형별 매출원장 전체조회';
  document.getElementById('lgPeriod').textContent='조회기간 : '+_lg.fr+' ~ '+_lg.to;
  var tb=document.getElementById('lgBody');
  if(!_lg.lines.length){ tb.innerHTML='<tr><td colspan="16" class="msg">이 기간에 저장된 토더 발주가 없습니다.</td></tr>'; document.getElementById('lgInfo').textContent=''; return; }
  var blank7='<td></td><td></td><td></td><td></td><td></td><td></td><td></td>';
  tb.innerHTML=_lg.lines.map(function(o){
    if(o.k==='row') return '<tr><td class="l">'+esc(o.biz)+'</td><td>'+esc(o.dt)+'</td><td>'+esc(o.no)+'</td><td>'+esc(o.ln)+'</td><td>매출</td><td class="l">'+esc(o.nm)+'</td><td class="l">'+esc(o.spec)+'</td>'
      +'<td class="r">'+fmt(o.qty)+'</td><td class="r">'+fmt(o.price)+'</td><td class="r">'+fmt(o.amt)+'</td><td class="r">0</td><td class="r">'+fmt(o.amt)+'</td><td class="r">'+fmt(o.run)+'</td><td class="r">0</td><td></td><td></td></tr>';
    var cls=o.k==='day'?'lg-day':(o.k==='sub'?'lg-sub':'lg-tot'), lab=o.k==='day'?'일계':(o.k==='sub'?'소계':'합계');
    return '<tr class="'+cls+'">'+(o.k==='day'?'<td class="lg-keep"></td><td>일계</td>':'<td>'+lab+'</td><td></td>')+blank7
      +'<td class="r"><b>'+fmt(o.amt)+'</b></td><td class="r">0</td><td class="r"><b>'+fmt(o.amt)+'</b></td><td></td><td></td><td></td><td></td></tr>';
  }).join('');
  document.getElementById('lgInfo').textContent='거래처 '+_lg.bizCnt+'곳 · '+_lg.cnt+'줄 · 합계 '+fmt(_lg.tot)+'원';
}
/* 엑셀 — 예시 파일과 같은 틀 : 제목(A1:P2) · 조회기간/출력일자 줄 · 유형 줄 · 머리글 · 본문(일계·소계·합계 색) · 같은 글꼴·테두리 */
function lgXls(){
  if(!window.XLSX){ err('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  if(!_lg || !_lg.lines.length){ err('엑셀로 낼 자료가 없습니다.'); return; }
  var type=lgTypeNm(), today=ymd(new Date()), comp=String((document.getElementById('compNm')||{}).textContent||'').trim();
  var H=['거래처','일자','번호','NO','구분','상품명','규격','수량','단가','금액','할인액','판매액','계','S','행사','비고'], E=function(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; };
  var aoa=[ ['['+type+'] 유형별 매출원장 전체조회'].concat(E(15)), E(16),
            ['조회기간 : '+_lg.fr+' ~ '+_lg.to].concat(E(14)).concat(['출력일자 : '+today]),
            [_lg.fr+' ~ '+_lg.to,'','','유형',type,'','','','출력일자 : '+today,'','','',comp,'','',''], H ];
  var kinds=['t','t','p','h','h'];
  var serial=function(d){ var p=String(d).split('-'); return (Date.UTC(+p[0],+p[1]-1,+p[2])-Date.UTC(1899,11,30))/86400000; };
  _lg.lines.forEach(function(o){
    if(o.k==='row') aoa.push([o.biz, serial(o.dt), o.no, (/^\d+$/.test(o.ln)?Number(o.ln):o.ln), '매출', o.nm, o.spec, o.qty, o.price, o.amt, 0, o.amt, o.run, 0, '', '']);
    else if(o.k==='day') aoa.push(['','일계','','','','','','','',o.amt,0,o.amt,'','','','']);
    else aoa.push([(o.k==='sub'?'소계':'합계'),'','','','','','','','',o.amt,0,o.amt,'','','','']);
    kinds.push(o.k); });
  var ws=XLSX.utils.aoa_to_sheet(aoa), bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var FILL={ h:'D9EDF7', day:'EEFFB9', sub:'ECC7FF', tot:'FCF8E3' };
  for(var r=0;r<aoa.length;r++){ var k=kinds[r];
    for(var c=0;c<16;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var s={ font:{ name:'맑은 고딕', sz:10 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ s.font={ name:'맑은 고딕', sz:15, bold:true }; s.alignment.horizontal='center'; }
      else if(k==='p'){ s.alignment.horizontal=(c===15?'right':'left'); if(c<15) s.border={ bottom:bd }; }
      else if(k==='h'){ s.font.bold=true; s.alignment.horizontal=(r===3 && c>=12 ? 'right' : 'center'); s.fill={ fgColor:{ rgb:FILL.h } }; s.border=box; }
      else {
        s.border=box;
        var num=(c>=7 && c<=13), mid=(c>=1 && c<=4);
        s.alignment.horizontal = num ? 'right' : (mid ? 'center' : 'left');
        if(k==='row'){ s.fill={ fgColor:{ rgb:'FFFFFF' } }; if(c===0) s.border={ left:bd, right:bd }; }
        else { s.fill={ fgColor:{ rgb:FILL[k] } }; if(c===0) s.alignment.horizontal='center';
               if(k==='day' && c===0){ s.fill={ fgColor:{ rgb:'FFFFFF' } }; s.border={ left:bd, right:bd }; } }
        if(k==='row' && c===1){ ws[ref].t='n'; ws[ref].z='yyyy-mm-dd'; }
        if(ws[ref].t==='n' && c>=7 && c!==13 && c!==10){ ws[ref].z=(c===8 && Math.round(ws[ref].v)!==ws[ref].v) ? '#,##0.##' : '#,##0'; }
      }
      ws[ref].s=s; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:15 } }, { s:{ r:2, c:0 }, e:{ r:2, c:14 } },
                  { s:{ r:3, c:0 }, e:{ r:3, c:2 } }, { s:{ r:3, c:4 }, e:{ r:3, c:7 } }, { s:{ r:3, c:8 }, e:{ r:3, c:11 } }, { s:{ r:3, c:12 }, e:{ r:3, c:15 } } ];
  ws['!cols']=[{ wch:21 },{ wch:11 },{ wch:10.5 },{ wch:4.75 },{ wch:4.75 },{ wch:36 },{ wch:26 },{ wch:6.5 },{ wch:9 },{ wch:10.5 },{ wch:6.4 },{ wch:10.5 },{ wch:11.5 },{ wch:2.4 },{ wch:4.75 },{ wch:18.75 }];
  ws['!rows']=aoa.map(function(a,i){ return { hpt:(i<2?18.75:16.5) }; });
  var f8=_lg.fr.replace(/-/g,''), t8=_lg.to.replace(/-/g,'');
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, ('유형별원장조회_'+f8+'~'+t8).slice(0,31));
  XLSX.writeFile(wb, '토더 마감장부_'+type.replace(/[\\\/:*?"<>|]/g,'_')+'_'+f8+'~'+t8+'.xlsx');
  if(window._toast) _toast('📥 토더 마감장부 엑셀 생성 — '+_lg.cnt+'줄 · 합계 '+fmt(_lg.tot)+'원','ok');
}


/* ── 직접 입력 (2026-10-02 사용자 「토더 엑셀업로드 말고 카톡으로 오는 경우도 있어서 직접입력 기능도 추가」) ──
   엑셀 없이 줄을 만들어 친다. 올린 표 안에 「직접」 줄로 섞여 들어가고, 저장은 엑셀 줄과 같은 길(toderPoSave)을 탄다 — 서버는 그대로다.
     · 치는 칸 : 발주일자 · 사업장코드 · 품목코드 · 수량 · 단가(부가세 포함). 발주번호·배송지명·상품명·단위는 비워도 된다.
     · 비운 칸은 저장할 때 채운다 — 배송지명 = 사업장 마스터 이름 · 상품명 = 상품 마스터 이름 ·
       발주번호 = 「KT + 일시 + 차례」(같은 날·같은 사업장의 직접 줄은 한 번호로 묶고 줄 번호를 1부터 매긴다).
       ★발주번호를 꼭 붙이는 까닭 : 저장된 줄의 열쇠가 (발주번호, 배송지명, 상품명)이라, 비워 두면 다른 날 같은 지점·같은 상품을 넣을 때 앞의 것을 덮어쓴다.
     · 품목코드를 고르면 그 품목의 «마지막 토더 판매가»·단위를 가져온다(최근 석 달의 저장분에서). 없으면 단가 칸이 비어 있으니 직접 넣는다.
     · [직접 입력]을 다시 누르면 바로 앞 직접 줄의 발주일자·사업장을 이어받는다(한 지점이 여러 품목을 보내는 일이 많다). */
var _mid=0, _mh=null;
function mHist(){
  if(_mh) return;
  _mh=[]; var t=new Date(), a=new Date(t.getFullYear(), t.getMonth()-3, t.getDate());
  post('/shipout/toderPoList.do','frDt='+encodeURIComponent(ymd(a))+'&toDt='+encodeURIComponent(ymd(t)))
    .then(function(r){ return r.json(); }).then(function(j){ _mh=(j&&j.data)||[]; }).catch(function(){});
}
function mLast(pred){ var hit=null; (_mh||[]).concat(_ls||[]).forEach(function(y){ if(pred(y) && (!hit || String(y.dlvDt)>String(hit.dlvDt))) hit=y; }); return hit; }
/* 고른 코드로 빈 칸을 채운다 — 손으로 넣은 값은 안 건드린다 */
function mFill(x, kind){
  if(kind==='item' && x.itemCd){ var h=mLast(function(y){ return String(y.itemCd)===String(x.itemCd); });
    if(h){ if(!x.price && h.salePrice!=null) x.price=n(h.salePrice); if(!x.unit && h.unit) x.unit=h.unit; } }
}
function mAdd(){
  mHist();
  var prev=null; _pv.forEach(function(y){ if(y.manual) prev=y; });
  var x={ manual:true, mid:(++_mid), no:'', seq:9000000+_mid, chk:true, brand:'', fileNm:'직접 입력(카톡)', bizNm:(prev?prev.bizNm:''), ordNo:'', ordDttm:'',
          dlvDt:(prev&&prev.dlvDt)?prev.dlvDt:ymd(new Date()), dueDt:'', itemNm:'', unit:'', price:0, qty:1, status:'직접 입력',
          bizCd:(prev?prev.bizCd:''), itemCd:'', bizAuto:false, itemAuto:false };
  _pv.push(x); pvRender();
  var tr=document.querySelector('#pvBody tr[data-mid="'+x.mid+'"]');
  if(tr){ var e=tr.querySelector(x.bizCd ? 'input[list="prodList"]' : 'input[list="bizList"]'); if(e) e.focus(); tr.scrollIntoView({ block:'nearest' }); }
}
function mDel(i){ _pv.splice(i,1); pvRender(); }
function mSet(i, f, el){
  var x=_pv[i]; if(!x) return; var v=String(el.value||'').replace(/,/g,'').trim();
  if(f==='qty'){ x.qty=Math.max(0, Math.round(n(v))); el.value=x.qty||''; el.classList.toggle('bad', !x.qty); }
  else if(f==='price'){ x.price=(v==='' ? 0 : Math.max(0, n(v))); el.value=x.price||''; el.classList.toggle('bad', !x.price); }
  else if(f==='dlvDt'){ x.dlvDt=v; el.classList.toggle('bad', !v); }
  else { x[f]=String(el.value||'').trim(); if(f==='ordNo') x.ordAuto=false; }   /* 손으로 넣은 발주번호는 저장할 때 다시 매기지 않는다 */
  var ma=document.getElementById('mAmt'+x.mid); if(ma) ma.textContent=fmt(n(x.qty)*n(x.price));   /* 금액 = 수량 × 판매가 */
  pvInfoUpd();
}
function mRow(x, i){
  var bn=_biz[x.bizCd], pn=_prod[x.itemCd];
  var ti=function(f, w, ph){ return '<input type="text" class="mi" style="width:'+w+'px" value="'+esc(x[f]==null?'':x[f])+'" placeholder="'+ph+'" onchange="mSet('+i+',\''+f+'\',this)">'; };
  /* 칸 차례 = 저장 목록과 같다 : 발주일자 · 발주번호 · 번호 · 구분 · 배송지명 · 사업장코드 · 상품명 · 품목코드 · 단위 · 수량 · 판매가 · 금액 (2026-10-02 「1번과 동일한 형식」) */
  return '<tr data-mid="'+x.mid+'" class="'+(x.chk?'':'off')+'"><td><input type="checkbox" '+(x.chk?'checked':'')+' onchange="_pv['+i+'].chk=this.checked; pvRender()"></td>'
    +'<td><button class="btn" style="height:26px;padding:0 7px;color:#c0392b" title="이 줄을 화면에서 뺍니다(저장된 것과는 무관)" onclick="mDel('+i+')">✕</button></td>'
    +'<td><input type="date" class="mi'+(x.dlvDt?'':' bad')+'" value="'+esc(x.dlvDt)+'" onchange="mSet('+i+',\'dlvDt\',this)"></td>'
    +'<td>'+ti('ordNo', 96, '자동')+'</td>'
    +'<td class="dim" title="저장할 때 매깁니다">'+esc(x.ordAuto && x.no ? x.no : '자동')+'</td>'
    +'<td><span class="bd auto" title="직접 입력한 줄(엑셀이 아님)">직접</span></td>'
    +'<td class="l">'+ti('bizNm', 110, '(사업장명)')+'</td>'
    +'<td class="l">'+(x.bizCd?'<span class="sub nmf'+(bn==null?' warn':'')+'">'+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span>':'')
      +'<input type="text" list="bizList" class="'+cdCls(x.bizCd,_biz,false)+'" value="'+esc(x.bizCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'biz\',this.value)"></td>'
    +'<td class="l">'+ti('itemNm', 170, '(상품 마스터 이름)')+'</td>'
    +'<td class="l">'+(x.itemCd?'<span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span>':'')
      +'<input type="text" list="prodList" class="'+cdCls(x.itemCd,_prod,false)+'" value="'+esc(x.itemCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'item\',this.value)"></td>'
    +'<td>'+ti('unit', 96, '단위')+'</td>'
    +'<td class="r"><input type="text" class="num'+(x.qty?'':' bad')+'" style="width:70px" value="'+esc(x.qty||'')+'" title="수량" onchange="mSet('+i+',\'qty\',this)"></td>'
    +'<td class="r"><input type="text" class="num'+(x.price?'':' bad')+'" style="width:86px" value="'+esc(x.price||'')+'" placeholder="판매가" title="판매가(부가세 포함)" onchange="mSet('+i+',\'price\',this)"></td>'
    +'<td class="r"><b id="mAmt'+x.mid+'">'+fmt(n(x.qty)*n(x.price))+'</b></td>'
    +'<td><span class="bd st">직접 입력</span></td></tr>';
}
/* 저장 직전 — 직접 줄의 빈 칸을 채운다(배송지명·상품명 = 마스터 이름, 발주번호 = KT+일시+차례, 줄 번호) */
function mPrep(rdy){
  var d=new Date(), p2=function(v){ return ('0'+v).slice(-2); };
  var stamp=String(d.getFullYear()).slice(2)+p2(d.getMonth()+1)+p2(d.getDate())+p2(d.getHours())+p2(d.getMinutes())+p2(d.getSeconds());
  var grp={}, gk=0;
  rdy.forEach(function(x){ if(!x.manual) return;
    if(!x.bizNm) x.bizNm=String(_biz[x.bizCd]||'');
    if(!x.itemNm) x.itemNm=String(_prod[x.itemCd]||'').replace(' 〔매칭코드〕','');
    if(!x.ordNo || x.ordAuto){ var k=x.dlvDt+'|'+x.bizCd; if(!grp[k]) grp[k]={ no:'KT'+stamp+'-'+(++gk), ln:0 }; x.ordNo=grp[k].no; x.ordAuto=true; x.no=String(++grp[k].ln); }
    else if(x.no==='' || x.no==null) x.no='1'; });
}

/* ── 끌어다 놓기 · 시작 ── */
(function(){
  var d=document.getElementById('upCard');
  ['dragenter','dragover'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.add('on'); }); });
  ['dragleave','drop'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.remove('on'); }); });
  d.addEventListener('drop',function(e){ onFiles(e.dataTransfer.files); });
  /* 높이 막대 (2026-09-22) — 판매등록 막대와 같은 동작 : 아래로 끌면 늘고 위로 끌면 준다 · [▲ 줄이기][▼ 늘리기] · 더블클릭 = 처음 높이 · 표마다 따로 기억 */
  if(window.konetGridGrip){
    konetGridGrip('pvWrap','pvWrap','toderPoPv'); konetGridGrip('lsWrap','lsWrap','toderPoList');
    /* 막대는 문서가 다 읽힌 뒤(DOMContentLoaded) 붙는다 — 그 뒤에 pvRender 를 한 번 불러 올린 줄이 없으면 미리보기 막대를 숨긴다 */
    if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', pvRender); else pvRender();
  }
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth(), t.getDate()-14);
  document.getElementById('fr').value=ymd(a); document.getElementById('to').value=ymd(t);
  loadMasters();
})();
window.konetShown=function(){ loadMasters(); };   /* 다른 화면에서 사업장·상품을 고치고 돌아오면 새로 */
</script>
</body>
</html>
