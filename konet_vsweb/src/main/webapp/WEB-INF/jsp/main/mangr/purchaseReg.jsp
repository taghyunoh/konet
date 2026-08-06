<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 메시지는 프로젝트 공통 컴포넌트를 쓴다 — 로그인 화면(base_login.jsp)과 같은 모양.
     SweetAlert 가 아니라 이 파일이 표준이다(_alertBox / _confirmBox / _toast). --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- 거래처 입력검색 — 거래처 칸에 직접 쳐서 고른다(2026-08-01). [거래처] 팝업은 그대로 둔다. --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js?v=20260805"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-quick.js"></script>
<!--
  매입등록 — 홀세일닥터 매입등록 이관 (2026-07-25 신설)
    · 상단 = 전표 입력(헤더 + 명세 그리드) / 하단 = 기간 전표 목록
    · 저장하면 TBL_PURCHASE_MST/DTL + 파생 TBL_STOCK_LEDGER + TBL_PROD_INPRICE_HST 가 함께 쌓인다
    · 설계 근거 : docs/매입등록_설계안.md
-->
<style>
  :root{ --pu-bd:#dbe2ea; --pu-teal:#137a6c; --pu-bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  /* 글자 크기 한 단계 키움(2026-07-25 요청) — 기준 13 → 14px. 이 14px 이 전 화면 공통 기준이 됐다(2026-08-03) */
  .pu-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .pu-wrap h2{ margin:0 0 4px; font-size:20px; }
  .pu-sub{ color:#1f2a37; margin-bottom:12px; font-size:12.5px; font-weight:600; }
  .pu-card{ background:#fff; border:1px solid var(--pu-bd); border-radius:10px; padding:12px; margin-bottom:12px; }
  /* 검색·조건줄은 한 줄로 붙인다(2026-07-25 요청). 넘치면 이 줄만 가로 스크롤 */
  .pu-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:nowrap; overflow-x:auto; margin-bottom:8px; }
  .pu-fld{ display:flex; flex-direction:column; gap:3px; }
  .pu-fld label{ font-size:12px; font-weight:700; color:#1f2a37; white-space:nowrap; }
  .pu-fld input, .pu-fld select{ height:32px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .pu-btn{ height:32px; border:1px solid var(--pu-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .pu-btn:hover{ border-color:var(--pu-teal); }
  .pu-btn.teal{ background:var(--pu-teal); color:#fff; border-color:var(--pu-teal); }
  .pu-btn.red{ color:#c0392b; border-color:#e3b4ae; }
  .pu-bal{ margin-left:auto; display:flex; gap:14px; align-items:center; font-size:12.5px; }
  .pu-bal b{ font-size:15px; color:#c0392b; }
  /* 명세 그리드 */
  /* 상단 명세 그리드 — 행수가 늘어도 화면이 안 흔들리게 높이 고정(2026-07-25 요청) */
  /* 기본 210px, ★아래 모서리를 끌어 늘리고 줄일 수 있다(2026-08-04 — 판매등록과 동일) */
  .pu-grid{ height:210px; min-height:112px; max-height:70vh; resize:vertical;
            overflow:auto; scrollbar-gutter:stable; border:1px solid var(--pu-bd); border-radius:8px 8px 0 0; }
  /* 합계 — 그리드 바로 밑 고정. 가로 스크롤은 JS 가 그리드와 맞춘다 */
  .pu-foot{ overflow:hidden; scrollbar-gutter:stable; border:1px solid var(--pu-bd); border-top:0; border-radius:0 0 8px 8px; }
  /* ★그리드 표와 합계 표의 칸 맞춤(2026-08-04 — 판매등록과 동일한 방식):
       두 표 모두 table-layout:fixed + 같은 colgroup + 같은 min-width(colgroup 합 1740px).
       화면이 그보다 넓으면 width:100% 로 우측 끝까지 늘어난다 — 남는 폭은 두 표가 같은 비율로
       나눠 갖고, scrollbar-gutter 로 세로 스크롤바 자리도 똑같이 예약해 어느 쪽도 밀리지 않는다. */
  .pu-foot table{ width:100%; min-width:1740px; table-layout:fixed; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .pu-foot td{ border:1px solid var(--pu-bd); padding:6px 4px; text-align:center; background:#137a6c; color:#fff; font-weight:800; }
  .pu-foot td.num{ text-align:right; }
  .pu-grid table{ width:100%; min-width:1740px; table-layout:fixed; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .pu-grid th{ background:#eef3f2; color:#1f2a37; font-weight:700; border:1px solid var(--pu-bd); padding:7px 6px; position:sticky; top:0; z-index:2; }
  /* 컬럼 폭 조절 손잡이 — 머리글 오른쪽 경계를 끌면 그 칼럼이 늘고 줄어든다(bindColResize) */
  .pu-colrz{ position:absolute; top:0; right:-4px; width:8px; height:100%; cursor:col-resize; z-index:4; }
  .pu-colrz:hover{ background:rgba(19,122,108,.25); }
  .pu-grid td{ border:1px solid var(--pu-bd); padding:2px 4px; text-align:center;
               overflow:hidden; text-overflow:ellipsis; }   /* 고정 폭이라 긴 품명은 …로 줄인다 */
  .pu-grid td.num{ text-align:right; }
  .pu-grid td.txt{ text-align:left; }
  .pu-grid input{ width:100%; border:0; background:transparent; font-size:13.5px; padding:4px 2px; text-align:right; }
  .pu-grid input:focus{ outline:2px solid #bfe3dc; border-radius:3px; }
  .pu-grid input.txt{ text-align:left; }
  .pu-grid tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
  .pu-grid .lnk{ color:#137a6c; text-decoration:underline; cursor:pointer; }
  .pu-grid .del{ color:#c0392b; cursor:pointer; font-weight:700; }
  /* 행 조작(삽입·위·아래) — 주문·발주 순서 그대로 입력하기 위한 열(2026-07-31, 판매등록과 같다) */
  /* 거래처 부가세 설정 표시 — 계산이 왜 그렇게 나왔는지 화면에서 바로 보이게(2026-08-03) */
  /* 거래처 목록의 거래유형 — 이 화면(매입)에는 그 유형 + '매입&매출' + 유형 미지정이 함께 보인다.
     섞여 있어도 한눈에 갈리게 색을 준다(2026-08-03 요청) */
  .vp-gb{ display:inline-block; white-space:nowrap; padding:1px 7px; border-radius:10px; font-size:11.5px; font-weight:800;
          background:#e9f4f1; color:#137a6c; border:1px solid #b9ded4; }
  .vp-gb.both{ background:#eef0ff; color:#3f43a8; border-color:#c9cdf3; }
  .vp-gb.none{ background:#f2f4f6; color:#8a97a4; border-color:#dde3e9; }
  .vat-tag{ display:inline-block; white-space:nowrap; margin-left:6px; padding:2px 8px; border-radius:10px; font-size:12.5px;
            font-weight:800; background:#eef3f2; color:#37475a; border:1px solid #cfd8e3; vertical-align:middle; }
  .vat-tag.inc { background:#eaf3ff; color:#1a56a8; border-color:#b9d3f2; }
  .vat-tag.free{ background:#fff1e8; color:#b45309; border-color:#f0c9a4; }
  .pu-grid td.no{ text-align:center; color:#8a97a4; font-weight:700; background:#fbfcfd; }
  /* 반품 줄 — 글자를 전부 빨강으로. 안쪽 input·select 까지 물려야 줄 전체가 빨갛게 보인다.
     배경까지 칠하면 입력칸이 묻혀 읽기 어려워, 아주 옅은 분홍만 깐다. */
  .pu-grid tr.ret td{ color:#c0392b; background:#fff5f4; }
  .pu-grid tr.ret td.no{ background:#ffe9e6; color:#c0392b; }
  .pu-grid tr.ret input, .pu-grid tr.ret select, .pu-grid tr.ret .lnk{ color:#c0392b; font-weight:700; }
  .pu-grid td.ops{ white-space:nowrap; padding:2px 1px; }
  .pu-grid td.ops span{ display:inline-block; width:20px; height:20px; line-height:19px; margin:0 1px;
                        border:1px solid var(--pu-bd); border-radius:4px; cursor:pointer; font-size:11px; color:#37475a; background:#fff; }
  .pu-grid td.ops span:hover{ border-color:var(--pu-teal); color:var(--pu-teal); }
  .pu-grid .hist{ cursor:pointer; font-size:13px; }
  .pu-grid .hist:hover{ filter:brightness(1.3); }
  /* 하단 목록 */
  /* 하단 목록 — 5행 고정 + 자동 스크롤(매출내역과 같은 방식) */
  .pu-list{ max-height:196px; overflow:auto; border:1px solid var(--pu-bd); border-radius:8px; }
  .pu-list table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .pu-list th{ background:#eef3f2; border:1px solid var(--pu-bd); padding:7px 8px; position:sticky; top:0; z-index:2; }
  .pu-list td{ border:1px solid var(--pu-bd); padding:6px 8px; text-align:center; }
  .pu-list td.num{ text-align:right; }
  .pu-list tr{ cursor:pointer; }
  .pu-list tr:hover td{ background:#f3f8f6; }
  .pu-list tr.on td{ background:#fdeef0; font-weight:700; }
  .pu-sum{ display:flex; gap:0; border:1px solid var(--pu-bd); border-top:0; border-radius:0 0 8px 8px; overflow:hidden; }
  .pu-sum div{ flex:1; padding:8px 10px; font-size:13.5px; }
  .pu-sum div.k{ background:#eef3f2; font-weight:700; flex:0 0 90px; text-align:center; }
  .pu-sum div.v{ text-align:right; font-weight:700; }
  /* 팝업 */
  .pu-pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:200; }
  .pu-pop.on{ display:block; }
  .pu-pop .box{ background:#fff; width:min(940px,96vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.3); }
  .pu-pop .hd{ padding:12px 16px; border-bottom:1px solid var(--pu-bd); font-weight:800; display:flex; align-items:center; gap:8px; }
  /* ★padding-top 을 0 으로 (2026-08-03) — sticky 머리글은 이 영역의 '패딩 안쪽' 맨 위에 서기 때문에
     위쪽 여백 12px 구간으로 지나가는 줄이 머리글 위에 비쳐 보였다.
     표가 제목줄(.hd) 밑선에 딱 붙게 되는데, .hd 에 아래 테두리가 있어 그대로 깔끔하다. */
  .pu-pop .bd{ padding:0 16px 12px; overflow:auto; }
  .pu-pop .ft{ padding:10px 16px; border-top:1px solid var(--pu-bd); text-align:right; }
  .pu-pop table{ width:100%; border-collapse:collapse; font-size:12.5px; }
  /* ★머리글 고정 (2026-08-03 요청) — 목록을 내리면 어느 칸이 무엇인지 알 수 없었다.
     border-collapse 표에서는 sticky th 의 테두리가 같이 안 따라와 줄이 사라지므로
     box-shadow 로 아래·위 선을 그려 준다. */
  .pu-pop thead th{ background:#eef3f2; border:1px solid var(--pu-bd); padding:6px 8px;
                 position:sticky; top:0; z-index:5;
                 box-shadow:inset 0 1px 0 var(--pu-bd), inset 0 -1px 0 var(--pu-bd); }
  .pu-pop tbody td{ position:relative; z-index:1; }   /* 줄이 머리글을 덮지 않게 */
  .pu-pop td{ border:1px solid var(--pu-bd); padding:6px 8px; text-align:center; }
  .pu-pop td .vat-tag{ margin-left:0; }
  .pu-pop td.num{ text-align:right; }
  .pu-pop tr.pick{ cursor:pointer; }
  .pu-pop tr.pick:hover td{ background:#f3f8f6; }
  .pu-msg{ padding:10px; color:#5a6b7a; text-align:center; font-size:12.5px; }
  /* 원장 합계 — 스크롤 영역 밖에 고정 */
  .pu-lgfoot{ overflow:hidden; border:1px solid var(--pu-bd); border-top:0; border-radius:0 0 8px 8px; }
  .pu-lgfoot table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .pu-lgfoot td{ border:1px solid var(--pu-bd); padding:7px 8px; text-align:right; background:#d9f0e0; font-weight:800; }
  .pu-lgfoot td:first-child{ text-align:center; }
</style>

<div class="pu-wrap">
  <h2>🧾 매입등록</h2>
  <div class="pu-sub">거래처를 고르고 상품을 넣으면 전표가 생깁니다. 저장 시 <b>재고(수불원장)</b>와 <b>매입단가 이력</b>이 함께 기록됩니다.</div>

  <!-- ========== 전표 입력 ========== -->
  <div class="pu-card">
    <div class="pu-row">
      <div class="pu-fld" style="flex:0 0 140px"><label>매입일자</label><input type="date" id="puDt" onchange="puNextNo()"></div>
      <div class="pu-fld" style="flex:0 0 90px"><label>전표번호</label><input type="text" id="puNo" readonly style="background:#f5f7f9"></div>
      <%-- 거래처 = 직접 입력검색(거래처명·코드·별칭·대표·담당 부분일치). 목록을 훑어보려면 [거래처] 버튼. --%>
      <div class="pu-fld" style="flex:0 0 220px"><label>거래처</label><input type="text" id="puVenNm" placeholder="거래처명 입력 또는 [거래처]" title="거래처명·코드·별칭·대표자·담당자로 검색합니다. ↑↓ 로 고르고 Enter."><span id="puVatTag" class="vat-tag" style="display:none"></span></div>
      <button class="pu-btn teal" onclick="puVenOpen()">거래처</button>
      <button class="pu-btn" onclick="puVenNew()" title="없는 거래처를 이 자리에서 바로 등록합니다">＋신규</button>
      <%-- 매입분 = 그 매입처에서 이미 사 온 품목(매입전표 + 매입단가이력)을 중복 없이.
           체크한 순서 그대로 명세에 담긴다 — 판매등록의 [납품분]과 같은 장치(2026-07-31). --%>
      <button class="pu-btn teal" onclick="puDlvOpen()" title="이 매입처에서 사 온 품목 목록에서 골라 담기">매입분</button>
      <div class="pu-fld" style="flex:0 0 120px"><label>담당자</label><input type="text" id="puMgrNm" readonly style="background:#f5f7f9"></div>
      <div class="pu-fld" style="flex:0 0 130px"><label>창고</label><input type="text" id="puWhNm" value="물류창고"></div>
      <%-- 일괄등록 (2026-08-06 요청) — 거래처는 그대로 두고 일자만 바꿔 여러 상품을 한 번에 전표로 저장 --%>
      <button class="pu-btn teal" onclick="puBatchOpen()" title="거래처가 선택된 상태에서 일자만 바꿔 여러 상품을 한 번에 전표로 저장합니다">일괄등록</button>
      <div class="pu-bal">
        <span>현잔고 <b id="puBalNow">0</b></span>
        <span>거래후잔고 <b id="puBalAfter">0</b></span>
      </div>
    </div>

    <%-- 합계는 스크롤 영역 밖(그리드 바로 밑)에 둔다 — 안에 두면 행이 적을 때 빈 공간 위에 떠서
         그리드 중간에 걸린 것처럼 보인다(2026-07-25 요청). 두 표의 열 너비는 같은 colgroup 으로 맞추고
         가로 스크롤은 JS 로 동기화한다. --%>
    <div class="pu-grid" id="puGridWrap">
      <table>
        <colgroup><col style="width:38px"><col style="width:82px"><col style="width:110px"><col style="width:320px"><col style="width:140px"><col style="width:70px"><col style="width:70px"><col style="width:80px"><col style="width:85px"><col style="width:95px"><col style="width:70px"><col style="width:95px"><col style="width:85px"><col style="width:100px"><col style="width:60px"><col style="width:110px"><col style="width:50px"><col style="width:80px"></colgroup>
        <thead><tr>
          <th>No</th><th>행(＋삽입/▲▼)</th><th>상품코드</th><th>품명(단가이력조회)</th>
          <th>[입수량]규격</th><th>BOX수량</th><th>EA수량</th>
          <th>합계수량</th><th>단가</th><th>금액</th>
          <th>DC</th><th>공급가</th><th>부가세</th>
          <th>매입금액</th><th>서비스</th><th>비고</th>
          <th>행사</th><th>거래구분</th>
        </tr></thead>
        <tbody id="puBody"></tbody>
      </table>
    </div>
    <div id="puGridPager" style="padding:5px 2px 0; text-align:center; min-height:22px"></div>
    <div class="pu-foot" id="puFootWrap">
      <table>
        <colgroup><col style="width:38px"><col style="width:82px"><col style="width:110px"><col style="width:320px"><col style="width:140px"><col style="width:70px"><col style="width:70px"><col style="width:80px"><col style="width:85px"><col style="width:95px"><col style="width:70px"><col style="width:95px"><col style="width:85px"><col style="width:100px"><col style="width:60px"><col style="width:110px"><col style="width:50px"><col style="width:80px"></colgroup>
        <tbody><tr class="tot">
          <td colspan="5">■ 합계</td>
          <td class="num" id="tBox">0</td><td class="num" id="tEa">0</td><td class="num" id="tQty">0</td>
          <td></td><td class="num" id="tAmt">0</td><td class="num" id="tDc">0</td>
          <td class="num" id="tSup">0</td><td class="num" id="tVat">0</td><td class="num" id="tTot">0</td>
          <td class="num" id="tSvc">0</td><td colspan="3"></td>
        </tr></tbody>
      </table>
    </div>

    <div class="pu-row" style="margin-top:10px">
      <div class="pu-fld" style="flex:1 1 320px"><label>매입메모</label><input type="text" id="puRemark" style="width:100%"></div>
      <div class="pu-fld" style="flex:0 0 110px"><label>지급구분</label>
        <select id="puPayGb"><option>현금</option><option>카드</option><option selected>외상</option><option>계좌이체</option></select>
      </div>
      <div class="pu-fld" style="flex:0 0 120px"><label>지급액</label><input type="text" id="puPayAmt" value="0" style="text-align:right" oninput="puCalc()"></div>
      <button class="pu-btn" onclick="puPayFill()">매입액</button>
      <div class="pu-fld" style="flex:0 0 120px"><label>할인액</label><input type="text" id="puDcAmt" value="0" style="text-align:right" oninput="puCalc()"></div>
      <button class="pu-btn" onclick="puDcFill()">털기</button>
    </div>

    <div class="pu-row" style="margin-top:4px">
      <button class="pu-btn teal" onclick="puNew()">＋ 신규등록</button>
      <button class="pu-btn" onclick="puSave()">💾 저장</button>
      <button class="pu-btn" onclick="puReload()">🔄 새로고침</button>
      <button class="pu-btn red" onclick="puDelete()">✖ 삭제하기</button>
      <span id="puState" style="margin-left:8px; color:#3d4d5c; font-size:12.5px"></span>
      <span style="margin-left:auto; color:#8a97a4; font-size:11.5px"
            title="상품칸에 바로 입력해 ↑↓·Enter 로 고르고, Enter 로 다음 칸/다음 줄, ↑↓ 로 줄을 오갑니다">⌨ 상품칸 입력검색 · Enter 다음칸 · ↑↓ 줄이동 · Ctrl+S 저장 · Alt+N 신규</span>
    </div>
  </div>

  <!-- ========== 하단 : 좌 전표목록 / 우 거래처 원장 ========== -->
  <div style="display:flex; gap:12px; align-items:flex-start">
  <div class="pu-card" style="flex:1 1 auto; min-width:0">
    <div class="pu-row">
      <span style="font-weight:700">Total : <span id="puTotal">0</span></span>
      <div class="pu-fld" style="flex:0 0 140px"><label>검색기간</label><input type="date" id="puFrom"></div>
      <div class="pu-fld" style="flex:0 0 140px"><label>&nbsp;</label><input type="date" id="puTo"></div>
      <div class="pu-fld" style="flex:0 0 200px"><label>거래처</label><input type="text" id="puFindNm" placeholder="거래처명"></div>
      <button class="pu-btn teal" onclick="puLoad()">리스트조회</button>
    </div>
    <div class="pu-list" id="puListWrap">
      <table>
        <thead><tr>
          <th style="width:70px">복사저장</th><th style="width:110px">매입일시</th><th style="width:64px">번호</th>
          <%-- 거래처명은 폭을 지정해 줄인다(2026-08-04 — 판매등록과 동일) --%>
          <th style="width:220px">거래처명</th><th style="width:84px">담당사원</th><th style="width:64px">상품수</th>
          <th style="width:110px">금액</th><th style="width:84px">창고</th><th style="width:84px">등록자</th>
        </tr></thead>
        <tbody id="puListBody"><tr><td colspan="9" class="pu-msg">[리스트조회]를 누르세요.</td></tr></tbody>
      </table>
    </div>
    <div id="puPager" style="padding:6px 2px; text-align:center; min-height:26px"></div>
    <div class="pu-sum">
      <div class="k">매입계</div><div class="v" id="sPurch">0</div>
      <div class="k">반품계</div><div class="v" id="sRet">0</div>
      <div class="k">지급계</div><div class="v" id="sPay">0</div>
      <div class="k">할인계</div><div class="v" id="sDc">0</div>
      <div class="k">미지급</div><div class="v" id="sUnpaid">0</div>
    </div>
  </div>

  <!-- 거래처 원장(분개장) — 거래처를 고르면 그 거래처의 일자별 매입·지급·잔고 -->
  <%-- 460→680px (2026-08-04 — 판매등록과 동일) — 왼쪽 목록은 그만큼 자동으로 줄어든다 --%>
  <div class="pu-card" style="flex:0 0 680px">
    <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
      <b>원장</b>
      <span style="margin-left:auto; font-size:11.5px; color:#5a6b7a">* 일자를 클릭하면 그 날 매입품목이 보입니다.</span>
    </div>
    <div style="border:1px solid var(--pu-bd); border-radius:6px; padding:6px 8px; margin-bottom:6px; font-size:12.5px">
      <b>거래처명</b> <span id="lgVen" style="margin-left:8px">—</span>
    </div>
    <%-- 원장 스크롤 : 머리글 고정 + 합계는 스크롤 영역 밖(항상 보임). 지급등록 화면과 같은 규격 --%>
    <div class="pu-list" id="lgWrap" style="max-height:300px; border-radius:8px 8px 0 0">
      <table>
        <%-- 균형 배분(2026-08-04 — 판매등록과 동일) --%>
        <colgroup><col style="width:96px"><col><col style="width:88px"><col style="width:112px"><col style="width:88px"><col style="width:122px"></colgroup>
        <thead><tr><th>일자</th><th>매입</th><th>DC</th><th>지급</th><th>할인</th><th>잔고</th></tr></thead>
        <tbody id="lgBody"><tr><td colspan="6" class="pu-msg">거래처를 선택하세요.</td></tr></tbody>
      </table>
    </div>
    <div class="pu-lgfoot">
      <table>
        <%-- 균형 배분(2026-08-04 — 판매등록과 동일) --%>
        <colgroup><col style="width:96px"><col><col style="width:88px"><col style="width:112px"><col style="width:88px"><col style="width:122px"></colgroup>
        <tbody id="lgFoot"></tbody>
      </table>
    </div>
  </div>
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="pu-pop" id="puVenPop">
  <div class="box" style="width:min(1140px,96vw)"><%-- 총판매·총매입 칼럼이 늘어 기본(940)보다 넓게 --%>
    <div class="hd">거래처 선택
      <input type="text" id="puVenQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:30px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px" oninput="puVenRender()">
    </div>
    <%-- 총매입·총판매 표시(2026-08-04) — 정렬(총매입 순)의 근거가 화면에 보이게. 매입 화면이라 매입을 앞에 --%>
    <div class="bd"><table><thead><tr><th style="width:78px">코드</th><th>거래처명</th><th style="width:96px">거래유형</th><th style="width:74px">부가세</th><th style="width:108px">총매입</th><th style="width:108px" title="정산서 매출 + 판매전표를 모두 더한 금액입니다. 숫자에 마우스를 올리면 내역이 보입니다.">총판매</th><th style="width:110px">별칭</th><th style="width:92px">대표자</th><th style="width:88px">담당사원</th></tr></thead>
      <tbody id="puVenBody"></tbody></table></div>
    <div class="ft" style="justify-content:space-between"><span style="display:flex;gap:6px"><button class="pu-btn" id="puVenAllBtn" onclick="puVenAll(!_venAll)" title="끄면 매입 거래처(+유형 미지정)만 보입니다">전체</button><button class="pu-btn teal" onclick="puVenNew()">＋ 신규 거래처</button></span><button class="pu-btn" onclick="puVenClose()">닫기</button></div>
  </div>
</div>

<!-- 상품 선택 팝업 — ✔칸으로 여러 상품을 체크해 한꺼번에 담을 수 있다(2026-08-06 요청, 매입분 팝업과 같은 방식).
     줄 클릭 = 종전 그대로 그 상품 한 건 즉시 담기. -->
<div class="pu-pop" id="puProdPop">
  <div class="box">
    <div class="hd">상품 선택
      <input type="text" id="puProdQ" placeholder="상품코드·상품명" style="flex:1; height:30px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px" oninput="puProdRender()">
    </div>
    <div class="bd"><table><thead><tr><th style="width:44px" title="체크한 순서대로 한꺼번에 담습니다">✔</th><th style="width:110px">상품코드</th><th>상품명</th><th style="width:110px">규격</th><th style="width:60px">입수</th><th style="width:90px">매입가</th></tr></thead>
      <tbody id="puProdBody"></tbody></table></div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span id="puPickInfo" style="font-size:12.5px; color:#137a6c; font-weight:700"></span>
      <span style="margin-left:auto"></span>
      <button class="pu-btn teal" onclick="puProdMultiApply()" title="체크한 상품을 순서대로 명세에 담습니다. BOX수량은 1로 채워집니다">확인 — 선택 담기</button>
      <button class="pu-btn" onclick="puProdClose()">닫기</button>
    </div>
  </div>
</div>

<!-- 일괄등록 팝업 (2026-08-06 요청) —————————————————————————————
     거래처는 '선택된 상태' 그대로 두고, 위의 매입일자만 바꿔 여러 상품을 한 번에 전표로 만든다.
       · [상품코드] 탭   = 상품마스터를 코드순으로 — ✔ 체크한 순서대로 담긴다. BOX수량 1.
       · [최근 매입내역] 탭 = 이 거래처에서 사 온 내역을 최근 일자부터 일자별로 —
         일자 머리줄의 ✔ 가 그 날 전체선택. 수량·단가는 그때 그대로.
       · [명세에 담기] = 화면에 올려 확인 후 저장 / [일괄저장] = 그 자리에서 바로 전표 저장. -->
<div class="pu-pop" id="puBatchPop">
  <div class="box" style="width:min(1600px,97vw)">
<%-- 머리줄 글자·버튼 높이 30px 통일 — 한 선상 정렬(2026-08-06 요청) --%>
    <div class="hd" style="align-items:center">일괄등록 — <span id="btVen" style="color:#137a6c">—</span>
      <span class="pu-btn" style="pointer-events:none; background:#f1f5f4; height:30px; line-height:28px; padding:0 10px">매입일자</span>
      <input type="date" id="btDt" style="height:30px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px; font-size:13px" onchange="puBatchDtHint();puBatchRender()">
      <span id="btDtHint" style="font-size:12px; font-weight:700; color:#c0392b; line-height:30px"></span>
      <%-- 담을 내용 비우기 (2026-08-06) — [전체 초기화]만 여기에. 일자별 삭제는 왼쪽 일자 머리줄의 ✖ 로 --%>
      <button class="pu-btn red" style="height:30px; line-height:1; padding:0 10px" onclick="puBatchDelAll()" title="담을 내용을 모두 비웁니다">전체 초기화</button>
      <%-- [일괄저장]은 상단 우측(✕ 옆) 배치 (2026-08-06 확정 — 판매·매입 동일). 누르면 확인창이 먼저 뜬다 --%>
      <span style="margin-left:auto; display:flex; align-items:center; gap:8px">
        <%-- 버튼 너비(112px)만큼 왼쪽으로 — ✕ 와 붙어 잘못 누르는 것 방지(2026-08-06 요청) --%>
        <button class="pu-btn teal" style="min-width:112px; height:30px; line-height:1; margin-right:112px" onclick="puBatchApply()" title="담을 내용을 일자별 전표로 한 장씩 바로 저장합니다 (확인창이 먼저 뜹니다)">💾 일괄저장</button>
        <span class="pu-btn" style="border:0;background:transparent;font-size:18px" onclick="puBatchClose()">✕</span>
      </span>
    </div>
    <div class="bd">
      <%-- 좌 = 담을 내용(전표 미리보기, 넓게) / 우 = 상품 목록 (2026-08-06 요청 — 입력 내용이 많이 보이게 2단).
           오른쪽에서 체크하면 왼쪽에 순서대로 쌓이고, [일괄저장]이 일자별 전표로 저장한다. --%>
      <div style="display:flex; gap:12px; align-items:flex-start; margin-top:10px">
        <div style="flex:1 1 58%; min-width:0">
          <div style="font-size:12.5px; font-weight:800; color:#37475a; margin:0 0 4px">⤒ 담을 내용
            <span style="font-weight:600; color:#8a97a4">— 오른쪽 목록에서 체크한 상품이 순서대로 쌓입니다. 확인 후 [일괄저장]</span></div>
          <div style="height:60vh; overflow:auto; border:1px solid var(--pu-bd); border-radius:6px">
            <table>
              <%-- 세부 줄의 일자 칸 없음 (2026-08-06) — 저장 일자는 📅 머리줄(매입일자)이 전부인데,
                   원천일자 칸이 저장 일자처럼 읽혀 혼동을 줬다 --%>
              <%-- 순서(▲▼)는 코드 앞 (2026-08-06 요청 — 명세 그리드의 행 조작 열과 같은 자리) --%>
              <thead><tr><th style="width:36px">#</th><th style="width:52px" title="▲▼ 순서 조정(같은 일자 안)">순서</th><th style="width:106px">상품코드</th><th>상품명</th>
                <th style="width:104px">[입수량]규격</th><th style="width:58px">BOX</th><th style="width:58px">EA</th><th style="width:64px">합계</th><th style="width:82px">단가</th><th style="width:92px">금액</th><th style="width:34px"></th></tr></thead>
              <tbody id="btSelBody"><tr><td colspan="11" class="pu-msg">오른쪽 목록에서 체크하면 여기에 순서대로 담깁니다.</td></tr></tbody>
            </table>
          </div>
        </div>
        <div style="flex:1 1 42%; min-width:0">
          <div style="display:flex; gap:6px; margin:0 0 6px">
            <button class="pu-btn" id="btTab1" onclick="puBatchTab(1)">상품코드</button>
            <button class="pu-btn" id="btTab2" onclick="puBatchTab(2)">최근 매입내역</button>
            <input type="text" id="btQ" placeholder="상품코드·상품명" style="flex:1; height:32px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="puBatchRender()">
          </div>
          <div style="height:56vh; overflow:auto; border:1px solid var(--pu-bd); border-radius:6px">
            <table>
              <thead id="btHead"></thead>
              <tbody id="btBody"></tbody>
            </table>
          </div>
          <div style="margin-top:6px; font-size:12px; color:#3d4d5c">
            체크하면 위 <b>매입일자</b>로 담깁니다 — <b>일자를 바꿔 체크하면 일자별 전표로 나뉘고</b>, [일괄저장]이 전표를 일자마다 한 장씩 저장합니다.
            상품코드 탭은 BOX수량 1, 최근 매입내역 탭은 그때의 수량·단가 그대로. 담긴 줄은 왼쪽에서 고치거나 ✖ 로 뺍니다.
          </div>
        </div>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="font-size:12.5px; color:#137a6c; font-weight:700" id="btCnt"></span>
      <span style="margin-left:auto"></span>
      <button class="pu-btn" style="min-width:112px" onclick="puBatchClose()">닫기</button>
    </div>
  </div>
</div>

<!-- 매입분 검색 팝업 (2026-07-31) —————————————————————————————
     그 매입처에서 이미 사 온 품목을 중복 없이 모아 보여준다(매입전표 + 매입단가이력).
       · 체크한 '순서'가 곧 명세 줄 순서다. 체크 칸에 1,2,3… 이 찍혀 순서를 눈으로 확인한다.
       · [매입분제외] = 앞으로 이 목록에 안 나오게 한다(거래처별). 매입 이력은 그대로 둔다.
       · 판매등록의 [납품분]과 같은 표를 쓰되 GB='P' 로 갈린다 — 매출에서 뺀 게 매입에 영향 없다. -->
<div class="pu-pop" id="puDlvPop">
  <div class="box" style="width:min(980px,96vw)">
    <div class="hd">매입분 검색
      <select id="dvPeriod" style="height:30px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 6px; font-size:12.5px" onchange="puDlvLoad()">
        <option value="1">최근 1년</option><option value="3">최근 3년</option><option value="">전체</option>
      </select>
      <select id="dvSrc" style="height:30px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 6px; font-size:12.5px" onchange="puDlvLoad()">
        <option value="">전체(전표+단가이력)</option><option value="TRX">매입전표만</option><option value="HST">매입단가이력만</option>
      </select>
      <button class="pu-btn" id="dvExclBtn" onclick="puDlvToggleExcl()">📋 제외이력보기</button>
      <span style="margin-left:auto"><span class="pu-btn" style="border:0;background:transparent;font-size:18px" onclick="puDlvClose()">✕</span></span>
    </div>
    <div class="bd">
      <div style="display:flex; gap:6px; margin-bottom:8px">
        <input type="text" id="dvQ" placeholder="상품코드·상품명·규격·제조사" style="flex:1; height:32px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="puDlvRender()">
        <button class="pu-btn" onclick="puDlvRender()">🔍</button>
      </div>
      <div style="max-height:420px; overflow:auto; border:1px solid var(--pu-bd); border-radius:6px">
        <table>
          <thead><tr>
            <th style="width:46px"><input type="checkbox" id="dvAll" onchange="puDlvAll(this.checked)"></th>
            <th style="width:110px">상품코드</th><th>상품명</th><th style="width:110px">규격</th>
            <th style="width:110px">제조사</th><th style="width:90px">단가</th><th style="width:90px">현재고</th>
            <th style="width:96px">최근거래</th><th style="width:76px">원천</th>
          </tr></thead>
          <tbody id="dvBody"><tr><td colspan="9" class="pu-msg">거래처를 먼저 선택하세요.</td></tr></tbody>
        </table>
      </div>
      <div style="margin-top:8px; font-size:12.5px; color:#3d4d5c">
        체크한 <b>순서대로</b> 명세에 담깁니다. <span id="dvPickInfo" style="color:#137a6c; font-weight:700"></span>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="font-size:12.5px; color:#5a6b7a" id="dvCnt">0건</span>
      <span style="margin-left:auto"></span>
      <button class="pu-btn red" id="dvExclSave" onclick="puDlvExclSave()">🚫 매입분제외</button>
      <button class="pu-btn teal" id="dvOk" onclick="puDlvApply()">확인 — 순서대로 담기</button>
    </div>
  </div>
</div>

<!-- 원장 일자 클릭 → 그 날 매입품목 (2026-07-31) —————————————
     원장 금액과 같은 원천(selectCustDayDetail)에서 그 날 매입전표 줄만 골라 보여준다.
     [불러오기] 는 '새 전표'로 올린다 — 그 날 전표를 여는 게 아니다.
     그대로 저장하면 매입이 한 번 더 잡히므로 미리 알린다. -->
<div class="pu-pop" id="puDayPop">
  <div class="box" style="width:min(900px,96vw)">
    <div class="hd">원장 — <span id="dyTitle">일자별 매입품목</span>
      <span style="margin-left:auto"><span class="pu-btn" style="border:0;background:transparent;font-size:18px" onclick="puDayClose()">✕</span></span>
    </div>
    <div class="bd">
      <div style="max-height:380px; overflow:auto; border:1px solid var(--pu-bd); border-radius:6px">
        <table>
          <thead><tr>
            <th style="width:90px">구분</th><th style="width:130px">전표</th><th style="width:110px">품목코드</th>
            <th>품목명</th><th style="width:80px">수량</th><th style="width:90px">단가</th><th style="width:100px">금액</th>
          </tr></thead>
          <tbody id="dyBody"><tr><td colspan="7" class="pu-msg">불러오는 중…</td></tr></tbody>
        </table>
      </div>
      <div style="margin-top:8px; font-size:12.5px; color:#3d4d5c">
        <b>합계</b> <span id="dySum" style="color:#c0392b; font-weight:700">0</span>
        <span style="margin-left:12px">* [불러오기] 는 이 품목들을 <b>새 전표</b>로 올립니다. 그대로 저장하면 매입이 한 번 더 잡힙니다.</span>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="margin-left:auto"></span>
      <button class="pu-btn teal" onclick="puDayApply()">⤓ 불러오기</button>
      <button class="pu-btn" onclick="puDayClose()">닫기</button>
    </div>
  </div>
</div>

<!-- 복사저장 설정 팝업 — 지난 전표의 명세를 '다른 일자·다른 거래처'로 복제할 때 쓴다 -->
<div class="pu-pop" id="puCopyPop">
  <div class="box" style="width:min(620px,94vw)">
    <div class="hd">복사저장 설정 <span style="margin-left:auto"><span class="pu-btn" style="border:0;background:transparent;font-size:18px" onclick="puCopyClose()">✕</span></span></div>
    <div class="bd">
      <div style="display:flex; align-items:center; gap:10px; margin-bottom:12px">
        <span class="pu-btn" style="pointer-events:none; background:#f1f5f4">매입일자선택</span>
        <input type="date" id="cpDt" style="height:32px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px; font-size:13.5px">
      </div>
      <div style="font-weight:700; margin-bottom:6px">거래처선택</div>
      <div style="display:flex; gap:6px; margin-bottom:8px">
        <input type="text" id="cpQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:32px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="puCopyRender()">
        <button class="pu-btn" onclick="puCopyRender()">🔍</button>
      </div>
      <div style="max-height:280px; overflow:auto; border:1px solid var(--pu-bd); border-radius:6px">
        <table><thead><tr><th style="width:90px">거래처코드</th><th>거래처명</th><th style="width:120px">별칭</th><th style="width:100px">대표자</th><th style="width:90px">담당사원</th></tr></thead>
          <tbody id="cpBody"></tbody></table>
      </div>
      <div style="margin-top:8px; color:#3d4d5c; font-size:12.5px">거래처를 클릭하면 그 거래처·일자로 <b>새 전표</b>가 만들어집니다. 내용을 확인한 뒤 [저장]을 누르세요.</div>
    </div>
    <div class="ft"><button class="pu-btn" onclick="puCopyClose()">닫기</button></div>
  </div>
</div>

<!-- 매입단가 이력 팝업 -->
<div class="pu-pop" id="puHistPop">
  <div class="box">
    <div class="hd">거래처 상품 매입 단가 이력</div>
    <div class="bd">
      <%-- 상단 정보는 상품마스터에서 그대로 보여준다(서버 왕복 없음) --%>
      <table style="margin-bottom:10px">
        <tr><th style="width:110px">거래처</th><td class="txt" style="text-align:left" colspan="3" id="hvVen">—</td></tr>
        <tr><th>상품명</th><td class="txt" style="text-align:left" colspan="3" id="hvNm">—</td></tr>
        <tr><th>바코드</th><td id="hvBc">—</td><th style="width:110px">박스 바코드</th><td id="hvBox">—</td></tr>
        <tr><th>매입 단가</th><td class="num" id="hvIn">0</td><th>판매 단가</th><td class="num" id="hvSale">0</td></tr>
        <tr><th>도매 단가</th><td class="num" id="hvWhole">0</td><th></th><td></td></tr>
      </table>
      <div style="display:flex; align-items:center; margin:8px 0 6px; font-size:12.5px">
        <span id="hvCnt" style="font-weight:700">[ 조회 건 수: 0/0 ]</span>
        <span style="margin-left:auto; color:#3d4d5c">최대 3년 전 단가 이력까지 볼 수 있습니다.</span>
      </div>
      <div style="max-height:300px; overflow:auto; border:1px solid var(--pu-bd); border-radius:6px">
        <table><thead><tr>
          <th style="width:34px">#</th><th style="width:100px">거래 일자</th><th>거래처</th>
          <th style="width:80px">단가</th><th style="width:70px">Box 수량</th><th style="width:70px">낱개 수량</th>
          <th style="width:80px">전체 수량</th><th style="width:100px">금액</th><th style="width:50px">행사</th><th style="width:50px">반품</th>
        </tr></thead><tbody id="puHistBody"></tbody></table>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center">
      <label style="font-size:12.5px; cursor:pointer"><input type="checkbox" id="hvEvtOnly" onchange="puHistRender()"> 행사만 보기</label>
      <span style="margin-left:auto"><button class="pu-btn" onclick="puHistClose()">✕ 닫기</button></span>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
/* 명세 그리드 페이징 상태 — ★선언이 init() 아래에 있으면 첫 렌더 때 undefined 가 된다.
     init() → puNew()/saNew() → 렌더가 '동기'로 돌아 이 줄보다 먼저 실행되기 때문.
     실제로 합계 아래 표시가 'undefined / 5행' 으로 나왔다(2026-07-25 수정). */
var PU_ROWS = 8, _pShown = 0, _pBound = false;
var _rows = [];        // 명세 행
var _list = [];        // 전표 목록
var _vendors = [];     // 거래처 마스터
var _venSum = {};      // 거래처별 총판매·총매입 {s,p} — 팝업에 표시하고 총매입 순으로 정렬(2026-08-04)
/* 고른 거래처의 부가세 설정 '별도'|'포함'|'면세' (TBL_VENDOR_MST.VAT_GB).
   비어 있으면 '별도' 로 본다 — 예전 자료는 이 칸이 비어 있는데, 지금까지의 동작이 별도였다. */
var _venVat = '별도';
var _prods = [];       // 상품 마스터
var _cur = null;       // 선택된 전표(수정 모드)
/* 수정 중인 전표가 '저장된 상태로' 현잔고에 이미 반영해 놓은 금액(매입금액 − 지급액 − 할인액).
   현잔고는 그 전표를 포함해 계산되므로, 거래후잔고를 낼 때 이 값을 빼지 않으면 이중으로 더해진다.
   신규 전표는 0. (2026-07-25 수정 — 전표를 고르면 거래후잔고가 두 배로 뜨던 문제) */
var _curNet = 0;
var _prodTargetRow = -1;

function n(v){ var x = Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x) ? x : 0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
/* 단가 표시용 — 소수점을 살린다(소수 2자리, 2026-08-05 요청). fmt 는 반올림이라 230.5 가 231 로 보였다.
   금액(합계)은 종전대로 정수 반올림(fmt) — DB 도 DECIMAL(18,2)라 소수 2자리까지 저장된다. */
function fmtP(v){ v = Math.round(n(v)*100)/100; return v.toLocaleString(undefined, {maximumFractionDigits:2}); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
/* 메시지 — 프로젝트 공통 컴포넌트(asset/js/ui-message.js). 로그인 화면이 쓰는 그것과 같다.
     _alertBox(msg, {icon, okColor:'red', onOk})  ·  _confirmBox({msg, icon, okText, onOk, onCancel})
   SweetAlert 로 흉내 내려다 아이콘이 깨졌었다 — 표준 컴포넌트를 그대로 쓴다(2026-07-25). */
function swOk(msg){
  if (window._alertBox) return _alertBox(msg, { icon:'✅' });
  alert(String(msg).replace(/<br\s*\/?>/gi,'\n'));
}
function swErr(msg){
  if (window._alertBox) return _alertBox(msg, { icon:'❌', okColor:'red' });
  alert(String(msg).replace(/<br\s*\/?>/gi,'\n'));
}
function swAlert(msg){
  if (window._alertBox) return _alertBox(msg, { icon:'ℹ️' });
  alert(String(msg).replace(/<br\s*\/?>/gi,'\n'));
}
function swConfirm(msg, title, okText){
  return new Promise(function(resolve){
    if (!window._confirmBox) { resolve(confirm(String(msg).replace(/<br\s*\/?>/gi,'\n'))); return; }
    _confirmBox({ msg:msg, icon:'❓', okText:okText||'확인',
                  onOk:function(){ resolve(true); }, onCancel:function(){ resolve(false); } });
  });
}
function post(url, body, isJson){
  return fetch(CTX+url, { method:'POST', credentials:'same-origin',
    headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded'},
    body: isJson ? JSON.stringify(body) : body });
}

/* ── 초기화 ───────────────────────────────────────────── */
(function init(){
  document.getElementById('puDt').value = today();
  var d = new Date(); d.setMonth(d.getMonth()-1);
  document.getElementById('puFrom').value = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01';
  document.getElementById('puTo').value = today();
  puNew();
  puLoadMasters();
  puLoad();
  /* 거래처 칸 입력검색 — 고르는 동작은 팝업과 같은 puVenPick() 을 그대로 탄다(잔고·원장·담당자 갱신 포함).
     _vendors 는 puLoadMasters() 가 나중에 채우므로 배열이 아니라 '함수'로 넘긴다. */
  _vendorPick(document.getElementById('puVenNm'), {
    list   : function(){ return _vendors.filter(puVenFit); },   // 거래유형 필터(＋신규/전체 버튼과 같은 기준)
    rank   : function(o){ return (_venSum[o.vendorCd]||{}).p||0; },   // 총매입 많은 순 — [거래처] 팝업과 같은 기준(2026-08-05)
    onPick : function(o){ puVenPick(o.vendorCd); },
    onClear: function(){ puVenVat(null); document.getElementById('puMgrNm').value=''; document.getElementById('puMgrNm').dataset.cd=''; puVenBal(''); }
  });
})();

/* 합계 표는 그리드 밖에 있으므로 가로 스크롤을 따라가게 맞춘다 */
(function bindFootScroll(){
  var g = document.getElementById('puGridWrap'), f = document.getElementById('puFootWrap');
  if (g && f) g.addEventListener('scroll', function(){ f.scrollLeft = g.scrollLeft; });
})();

/* 컬럼 폭 조절(2026-08-04 — 판매등록과 동일) — 머리글 오른쪽 경계를 끌면 그 칼럼이 늘고 준다.
   ★그리드와 합계 표의 colgroup 을 <같이> 바꾼다 — 한쪽만 바꾸면 칸 맞춤이 깨진다.
   ★끌고 나면 두 표의 min-width 를 칼럼 합으로 다시 잡는다 — 안 잡으면 넓힌 만큼
     다른 칼럼이 눌려 전체 폭이 그대로가 된다(table-layout:fixed 의 배분 규칙). */
(function bindColResize(){
  var gw = document.getElementById('puGridWrap'), fw = document.getElementById('puFootWrap');
  if (!gw || !fw) return;
  var gc = gw.querySelectorAll('colgroup col'), fc = fw.querySelectorAll('colgroup col');
  var gt = gw.querySelector('table'), ft = fw.querySelector('table');
  var ths = gw.querySelectorAll('thead th');

  function applyMin(){
    var sum = 0;
    for (var i = 0; i < gc.length; i++) sum += parseInt(gc[i].style.width, 10) || 0;
    gt.style.minWidth = sum + 'px';
    ft.style.minWidth = sum + 'px';
  }
  ths.forEach(function(th, i){
    if (i >= gc.length) return;
    var h = document.createElement('span');
    h.className = 'pu-colrz';
    h.title = '끌어서 칼럼 폭 조절';
    th.appendChild(h);
    h.addEventListener('mousedown', function(e){
      e.preventDefault(); e.stopPropagation();
      var sx = e.clientX, w0 = th.offsetWidth;
      function mv(ev){
        var w = Math.max(36, w0 + (ev.clientX - sx));
        gc[i].style.width = w + 'px';
        fc[i].style.width = w + 'px';
        applyMin();
      }
      function up(){
        document.removeEventListener('mousemove', mv);
        document.removeEventListener('mouseup', up);
        document.body.style.cursor = '';
      }
      document.body.style.cursor = 'col-resize';
      document.addEventListener('mousemove', mv);
      document.addEventListener('mouseup', up);
    });
    /* 더블클릭 = 처음 폭으로 */
    var w0px = gc[i].style.width;
    h.addEventListener('dblclick', function(){
      gc[i].style.width = w0px; fc[i].style.width = w0px; applyMin();
    });
  });
})();

/* 등록내용 새로고침 — 지금 보고 있는 전표를 서버에서 다시 읽는다.
   목록·원장·잔고도 같이 갱신한다. 신규 작성 중이면 목록만 새로 읽는다(입력분은 보존). */
function puReload(){
  var seq = _cur ? _cur.purchSeq : null;
  puLoad();
  if (seq) {
    post('/mangr/purchaseDetail.do','purchSeq='+seq).then(function(r){return r.json();}).then(function(j){
      var d = j&&j.data; if(!d){ puNew(); return; }
      puApply(d);
    }).catch(function(){});
  } else {
    var cd = document.getElementById('puVenNm').dataset.cd||'';
    if (cd) puVenBal(cd);
  }
}

function puLoadMasters(){
  post('/vendor/selectVendorMst.do','').then(function(r){return r.json();}).then(function(j){ _vendors=(j&&j.data)||[]; }).catch(function(){});
  /* 거래처 팝업용 — 거래처별 총판매·총매입(2026-08-04). 표시 + 총매입 순 정렬에 쓴다.
     못 받아와도 팝업은 이름순·금액 0 으로 그대로 뜬다. */
  post('/vendor/vendorTrxSum.do','').then(function(r){return r.json();}).then(function(j){
    _venSum = {};
    ((j&&j.data)||[]).forEach(function(o){
      /* 총판매 = 정산서(settleAmt) + 판매전표(trxAmt) — 내역은 칸에 마우스를 올리면 보인다 */
      _venSum[o.vendorCd] = { s:n(o.saleAmt), p:n(o.purchAmt), st:n(o.settleAmt), tx:n(o.trxAmt) };
    });
  }).catch(function(){});
  post('/prod/prodList.do','findData=').then(function(r){return r.json();}).then(function(j){ _prods=(j&&j.data)||[]; }).catch(function(){});
}

/* ── 전표 입력 ────────────────────────────────────────── */
function puNew(){
  _cur = null; _curNet = 0; _rows = [];
  document.getElementById('puVenNm').value=''; document.getElementById('puVenNm').dataset.cd='';
  document.getElementById('puMgrNm').value=''; document.getElementById('puMgrNm').dataset.cd='';
  document.getElementById('puRemark').value=''; document.getElementById('puPayAmt').value='0'; document.getElementById('puDcAmt').value='0';
  document.getElementById('puState').textContent = '신규 전표';
  for (var i=0;i<5;i++) _rows.push(emptyRow());
  puRender(); puNextNo();
  Array.prototype.forEach.call(document.querySelectorAll('#puListBody tr'), function(tr){ tr.classList.remove('on'); });
  puFocusFirstProd();                    // 진입 즉시 첫 상품칸에 커서(2026-08-04)
}
function emptyRow(){ return { prodCd:'', prodNm:'', spec:'', packQty:1, boxQty:0, eaQty:0, qty:0, unitPrice:0, amt:0, dcAmt:0,
                              supplyAmt:0, vatAmt:0, totAmt:0, serviceQty:0, remark:'', eventYn:'N', trxGb:'매입', taxGb:'과세' }; }
function puNextNo(){
  var dt = document.getElementById('puDt').value;
  if (!dt || _cur) return;
  post('/mangr/purchaseNextNo.do','purchDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){ document.getElementById('puNo').value = (j&&j.data)||'0001'; })
    .catch(function(){ document.getElementById('puNo').value='0001'; });
}
/* 명세 그리드도 매출내역과 같은 방식 — 8행씩 보여주고 스크롤하면 이어붙인다(2026-07-25 요청).
     · 화면에 안 그려진 행도 _rows 에 그대로 있어 저장에는 전부 들어간다(입력값 보존).
     · 편집으로 다시 그릴 때 이미 펼친 만큼(_pShown)은 유지한다 — 안 그러면 보던 줄이 접힌다. */
// (PU_ROWS·_pShown·_pBound 선언은 파일 위 전역 블록으로 옮겼다 — init() 보다 먼저 값이 있어야 한다)
function puGridMore(cnt){
  if (_pShown >= _rows.length) return;
  _pShown = Math.min(_pShown + (cnt||PU_ROWS), _rows.length);
  puRender();
}
function puGridBind(){
  var g = document.getElementById('puGridWrap');
  if (!g || _pBound) return; _pBound = true;
  g.addEventListener('scroll', function(){
    if (_pShown >= _rows.length) return;
    if (g.scrollTop + g.clientHeight >= g.scrollHeight - 30) puGridMore();
  });
}
function puGridPager(){
  var el = document.getElementById('puGridPager');
  if (_pShown >= _rows.length) {
    el.innerHTML = _rows.length > PU_ROWS
      ? '<span style="color:#5a6b7a; font-size:12.5px">총 '+_rows.length+'행 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a; font-size:12.5px">'+_pShown+' / <b>'+_rows.length+'</b>행'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="pu-btn" style="height:22px;margin-left:8px;font-size:12px" onclick="puGridMore('+_rows.length+')">모두 표시</button>';
}
function puRender(){
  var _keep = puCaptureFocus();          // 다시 그려도 커서가 있던 칸을 유지(2026-08-04 키보드 입력)
  var h = '';
  if (_pShown < PU_ROWS) _pShown = PU_ROWS;
  if (_pShown > _rows.length) _pShown = _rows.length;
  _rows.slice(0, _pShown).forEach(function(o,i){
    /* 반품 줄은 **줄 전체를 빨간색**으로 (2026-08-03 요청) — 거래구분 칸만 봐서는
         여러 줄 중 어느 것이 반품인지 눈에 안 들어온다. 글자색은 CSS(tr.ret)에서 준다. */
    h += '<tr'+(o.trxGb==='반품' ? ' class="ret"' : '')+'>'
      /* 맨 앞 순번 — 화면에 보이는 줄 번호(1부터). 저장 자료가 아니라 표시용이라
         줄을 지우거나 순서를 바꾸면 자동으로 다시 매겨진다. */
      + '<td class="no">'+(i+1)+'</td>'
      /* 행 조작 — 발주·주문 순서 그대로 넣기 위한 열(2026-07-31).
           ＋ = 이 줄 '위'에 빈 줄 삽입 / ▲▼ = 순서 바꾸기.
         (예전 ＋ 는 상품선택이었다. 상품선택은 아래 상품코드 칸을 눌러 그대로 쓴다) */
      + '<td class="ops">'
      +   '<span title="이 줄 위에 새 줄 삽입" onclick="puInsRow('+i+')">＋</span>'
      +   '<span title="한 줄 위로" onclick="puMoveRow('+i+',-1)">▲</span>'
      +   '<span title="한 줄 아래로" onclick="puMoveRow('+i+',1)">▼</span>'
      + '</td>'
      /* ★빈 줄은 '상품코드 칸에 직접 입력검색'(2026-08-04) — 칸에 쳐서 ↑↓·Enter 로 고른다(puPin*).
           고르면 그 행에 담기고 커서가 BOX수량 칸으로 넘어간다(매입 합계=BOX×입수+EA). [🔍]는 종전 팝업. */
      + (o.prodCd
          ? '<td><span class="lnk" title="클릭 → 다른 상품으로 바꾸기" onclick="puProdOpen('+i+')">'+esc(o.prodCd)+'</span></td>'
          : '<td class="txt" style="padding:2px 3px"><div style="display:flex;align-items:center;gap:2px">'
              + '<input class="puPin" data-r="'+i+'" data-f="prod" placeholder="상품검색" autocomplete="off"'
              +   ' oninput="puPinInput(this)" onkeydown="puPinKey(this,event)" onblur="puPinBlur()"'
              +   ' style="width:100%;border:0;background:transparent;font-size:13.5px;text-align:left;padding:4px 2px">'
              + '<span class="lnk" title="상품 선택 팝업으로 찾기" style="font-size:12px" onclick="puProdOpen('+i+')">🔍</span>'
              + '</div></td>')
      /* 품명 클릭 = 그 거래처의 매입단가 이력. 찾기 쉽게 📈 아이콘을 붙였다(2026-07-25) */
      + '<td class="txt">'+ (o.prodNm
          ? '<span class="lnk" onclick="puHistOpen('+i+')" title="클릭 → 이 거래처의 매입단가 이력(최대 3년)">'+esc(o.prodNm)+'</span>'
            + ' <span class="hist" onclick="puHistOpen('+i+')" title="매입단가 이력 보기">📈</span>'
          : '') +'</td>'
      + '<td class="txt">'+ (o.packQty?('['+fmt(o.packQty)+']'):'') + esc(o.spec) +'</td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="boxQty" value="'+n(o.boxQty)+'" onchange="puSet('+i+',\'boxQty\',this.value)"></td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="eaQty" value="'+n(o.eaQty)+'" onchange="puSet('+i+',\'eaQty\',this.value)"></td>'
      + '<td class="num">'+fmt(o.qty)+'</td>'
      /* 단가·DC 는 천단위 콤마로 보여 준다(2026-08-04 — 판매등록과 동일). n() 이 콤마를 지우므로 계산은 그대로다.
         단가는 소수점 입력 가능(fmtP — 2026-08-05 요청) */
      + '<td><input inputmode="decimal" data-r="'+i+'" data-f="unitPrice" value="'+fmtP(o.unitPrice)+'" onchange="puSet('+i+',\'unitPrice\',this.value)"></td>'
      + '<td class="num">'+fmt(o.amt)+'</td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="dcAmt" value="'+fmt(o.dcAmt)+'" onchange="puSet('+i+',\'dcAmt\',this.value)"></td>'
      + '<td class="num">'+fmt(o.supplyAmt)+'</td>'
      + '<td class="num">'+fmt(o.vatAmt)+'</td>'
      + '<td class="num">'+fmt(o.totAmt)+'</td>'
      + '<td><input inputmode="numeric" data-r="'+i+'" data-f="serviceQty" value="'+n(o.serviceQty)+'" onchange="puSet('+i+',\'serviceQty\',this.value)"></td>'
      + '<td><input class="txt" data-r="'+i+'" data-f="remark" value="'+esc(o.remark)+'" onchange="puSet('+i+',\'remark\',this.value)"></td>'
      + '<td><input type="checkbox" '+(o.eventYn==='Y'?'checked':'')+' onchange="puSet('+i+',\'eventYn\',this.checked?\'Y\':\'N\')"></td>'
      + '<td><select onchange="puSet('+i+',\'trxGb\',this.value)" style="border:0;background:transparent;font-size:12.5px">'
      +   '<option '+(o.trxGb==='매입'?'selected':'')+'>매입</option><option '+(o.trxGb==='반품'?'selected':'')+'>반품</option></select>'
      +   ' <span class="del" onclick="puDelRow('+i+')">✖</span></td>'
      + '</tr>';
  });
  document.getElementById('puBody').innerHTML = h;
  puGridBind(); puGridPager();
  puCalc();
  puRestoreFocus(_keep);                 // _focusNext 가 있으면 그 칸으로, 없으면 있던 칸 그대로
}
function puSet(i, k, v){
  var o = _rows[i]; if(!o) return;
  o[k] = (k==='remark'||k==='eventYn'||k==='trxGb') ? v : n(v);
  puCalcRow(o);
  if (i === _rows.length-1 && o.prodCd) puEnsureTail();   // 마지막 줄을 쓰면 새 줄 자동 추가(그 줄이 보이게)
  puRender();
}
function puCalcRow(o){
  o.qty = n(o.boxQty) * (n(o.packQty)||1) + n(o.eaQty);
  o.amt = Math.round(o.qty * n(o.unitPrice)) - n(o.dcAmt);
  /* 부가세 = ① 거래처 설정(TBL_VENDOR_MST.VAT_GB) × ② 품목 과세여부 (2026-08-03 요청)
       · 별도(기본) : 공급가 = 금액,        부가세 = 금액의 10%   → 합계 = 금액 + 부가세
       · 포함       : 공급가 = 금액 ÷ 1.1,  부가세 = 금액 − 공급가 → 합계 = 금액 (그대로)
       · 면세       : 부가세 0
     ★품목이 면세면 거래처가 무엇이든 면세다(면세 품목에 세금을 붙일 수는 없다).
     ★거래처를 바꾸면 담긴 줄을 전부 다시 계산한다(puVenVat 참고). */
  var vg = _venVat || '별도';
  var tax = (o.taxGb !== '면세') && (vg !== '면세');
  if (!tax)                 { o.supplyAmt = o.amt;                        o.vatAmt = 0; }
  else if (vg === '포함')   { o.supplyAmt = Math.round(o.amt / 1.1);      o.vatAmt = o.amt - o.supplyAmt; }
  else                      { o.supplyAmt = o.amt;                        o.vatAmt = Math.round(o.amt * 0.1); }
  o.totAmt = o.supplyAmt + o.vatAmt;
}
/* 거래처의 부가세 설정을 화면에 반영 — 담긴 줄 전부 재계산 + 거래처 칸 옆 표시 */
function puVenVat(o){
  _venVat = (o && o.vatGb) || '별도';
  var b = document.getElementById('puVatTag');
  if (b) {
    b.textContent = '부가세 ' + _venVat;
    b.style.display = '';
    b.className = 'vat-tag' + (_venVat === '면세' ? ' free' : (_venVat === '포함' ? ' inc' : ''));
  }
  /* 담긴 줄을 다시 계산하고 화면·합계까지 갱신 — 거래처를 바꾸면 부가세가 그 자리에서 달라져야 한다 */
  _rows.forEach(puCalcRow); puRender();
}
function puDelRow(i){ _rows.splice(i,1); puTail(); puRender(); }
/* ── 행 순서 (2026-07-31) ───────────────────────────────
     발주한 순서 그대로 명세가 서야 한다. 저장할 때 화면 순서가 그대로 ROW_NO 1,2,3… 이 되므로
     여기서 줄을 옮기면 전표에도 그 순서로 남는다. 판매등록과 같은 동작이다.
     맨 아래 빈 줄은 항상 하나 있어야 한다 — '마지막 줄을 쓰면 새 줄이 붙는' 규칙(puSet)이 거기 걸려 있다. */
/* 마지막 줄에 상품이 들어오면 그 뒤에 빈 줄('선택')을 하나 남겨 둔다 (2026-08-03 요청).
   ★_pShown 까지 같이 늘려야 한다 — 줄을 배열에 넣기만 하고 '보여 줄 줄 수'를 안 늘리면
     줄은 생겼는데 화면에는 안 나온다(상품을 골라 담을 때 실제로 그랬다). */
function puEnsureTail(){
  var last = _rows[_rows.length-1];
  if (!last || last.prodCd) { _rows.push(emptyRow()); }
  if (_pShown < _rows.length) _pShown = _rows.length;
  puScrollTail();
}
/* 새로 생긴 빈 줄이 화면에 보이게 그리드를 끝까지 내린다 (2026-08-03 요청).
   그리드는 높이가 고정(210px)이라 줄이 늘면 아래로 밀려 나가는데, 지금까지는
   오른쪽 스크롤막대를 손으로 내려야 그 줄이 보였다.
   ★다시 그린 뒤라야 높이가 반영되므로 setTimeout 으로 한 박자 늦춘다. */
function puScrollTail(){
  setTimeout(function(){
    var w = document.getElementById('puGridWrap');
    if (!w) return;
    /* 사용자가 위쪽 줄을 보려고 일부러 올려 둔 경우까지 끌어내리지는 않는다 —
       마지막 줄 근처(두 줄 높이 안)에 있을 때만 따라 내린다. */
    var gap = w.scrollHeight - w.scrollTop - w.clientHeight;
    if (gap <= 74) w.scrollTop = w.scrollHeight;
  }, 0);
}
function puTail(){
  if (!_rows.length) { _rows.push(emptyRow()); return; }
  if (_rows[_rows.length-1].prodCd) _rows.push(emptyRow());
}
function puInsRow(i){
  _rows.splice(i, 0, emptyRow());
  puTail();
  _pShown = Math.min(_rows.length, Math.max(_pShown + 1, i + 2));   // 끼운 줄이 화면에 보이게
  puRender();
}
function puMoveRow(i, d){
  var j = i + d;
  if (j < 0 || j >= _rows.length) return;
  if (!_rows[i].prodCd && !_rows[j].prodCd) return;                 // 빈 줄끼리는 의미 없음
  var t = _rows[i]; _rows[i] = _rows[j]; _rows[j] = t;
  puTail();
  if (_pShown < j + 1) _pShown = Math.min(j + 1, _rows.length);
  puRender();
}
function puCalc(){
  var t = {box:0, ea:0, qty:0, amt:0, dc:0, sup:0, vat:0, tot:0, svc:0};
  _rows.forEach(function(o){
    if(!o.prodCd) return;
    var sign = (o.trxGb==='반품') ? -1 : 1;
    t.box += n(o.boxQty)*sign; t.ea += n(o.eaQty)*sign; t.qty += n(o.qty)*sign;
    t.amt += n(o.amt)*sign; t.dc += n(o.dcAmt); t.sup += n(o.supplyAmt)*sign;
    t.vat += n(o.vatAmt)*sign; t.tot += n(o.totAmt)*sign; t.svc += n(o.serviceQty);
  });
  document.getElementById('tBox').textContent=fmt(t.box); document.getElementById('tEa').textContent=fmt(t.ea);
  document.getElementById('tQty').textContent=fmt(t.qty); document.getElementById('tAmt').textContent=fmt(t.amt);
  document.getElementById('tDc').textContent=fmt(t.dc);   document.getElementById('tSup').textContent=fmt(t.sup);
  document.getElementById('tVat').textContent=fmt(t.vat); document.getElementById('tTot').textContent=fmt(t.tot);
  document.getElementById('tSvc').textContent=fmt(t.svc);
  /* 거래후잔고 = 현잔고 − (이 전표가 이미 반영해 둔 금액) + (지금 화면 금액)
       · 신규     : _curNet = 0 → 현잔고 + 이번 전표
       · 수정 중  : 고친 만큼만 움직인다. 아무것도 안 고치면 현잔고와 같다
       · 삭제     : 저장 후 목록·잔고를 다시 읽으므로 그만큼 빠진다 */
  var now = n(document.getElementById('puBalNow').textContent);
  var net = t.tot - n(document.getElementById('puPayAmt').value) - n(document.getElementById('puDcAmt').value);
  document.getElementById('puBalAfter').textContent = fmt(now - _curNet + net);
  return t;
}
function puPayFill(){ document.getElementById('puPayAmt').value = n(document.getElementById('tTot').textContent); puCalc(); }
function puDcFill(){   // 털기 — 매입금액에서 지급액을 뺀 잔돈을 할인으로
  var rest = n(document.getElementById('tTot').textContent) - n(document.getElementById('puPayAmt').value);
  document.getElementById('puDcAmt').value = rest > 0 ? rest : 0; puCalc();
}

/* ── 저장 / 삭제 ──────────────────────────────────────── */
function puSave(){
  var venCd = document.getElementById('puVenNm').dataset.cd || '';
  if (!venCd) { swErr('거래처를 선택하세요.'); return; }
  var items = _rows.filter(function(o){ return o.prodCd; });
  if (!items.length) { swErr('상품을 한 줄 이상 입력하세요.'); return; }
  var t = puCalc();
  var dto = {
    purchSeq: _cur ? _cur.purchSeq : null,
    purchDt: document.getElementById('puDt').value,
    purchNo: document.getElementById('puNo').value,
    vendorCd: venCd, vendorNm: document.getElementById('puVenNm').value,
    mgrCd: document.getElementById('puMgrNm').dataset.cd||'', mgrNm: document.getElementById('puMgrNm').value,
    whCd:'', whNm: document.getElementById('puWhNm').value,
    totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty,
    supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:n(document.getElementById('puDcAmt').value),
    payGb: document.getElementById('puPayGb').value, payAmt:n(document.getElementById('puPayAmt').value),
    remark: document.getElementById('puRemark').value,
    items: items
  };
  /* 성공 여부를 promise 로 돌려준다 — 일괄등록이 '저장 후 팝업 유지' 흐름에서 결과를 봐야 한다(2026-08-06) */
  return post('/mangr/purchaseSave.do', dto, true).then(function(r){
    return r.text().then(function(t2){ if(!r.ok) throw new Error(t2); return t2; });
  }).then(function(){ swOk('저장했습니다.'); puNew(); puLoad(); return true; })
    .catch(function(e){ swErr('저장에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); return false; });
}
function puDelete(){
  if (!_cur) { swErr('목록에서 전표를 먼저 선택하세요.'); return; }
  swConfirm('이 전표를 삭제할까요?<br><span style="font-size:13px;color:#3d4d5c">재고(수불원장)에 기록된 입고도 함께 취소됩니다.</span>', null, '삭제')
    .then(function(ok){
      if(!ok) return;
      post('/mangr/purchaseDelete.do', { purchSeq:_cur.purchSeq, purchDt:_cur.purchDt, purchNo:_cur.purchNo }, true)
        .then(function(r){ if(!r.ok) return r.text().then(function(t){ throw new Error(t); }); swOk('삭제했습니다.'); puNew(); puLoad(); })
        .catch(function(e){ swErr('삭제에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
    });
}

/* ── 전표 목록 ────────────────────────────────────────── */
function puLoad(){
  var b = 'fromDt='+encodeURIComponent(document.getElementById('puFrom').value)
        + '&toDt='+encodeURIComponent(document.getElementById('puTo').value)
        + '&findData='+encodeURIComponent(document.getElementById('puFindNm').value);
  document.getElementById('puListBody').innerHTML = '<tr><td colspan="9" class="pu-msg">조회 중…</td></tr>';
  post('/mangr/purchaseList.do', b).then(function(r){return r.json();}).then(function(j){
    _list = (j&&j.data)||[]; puListRender();
  }).catch(function(e){ document.getElementById('puListBody').innerHTML='<tr><td colspan="9" class="pu-msg" style="color:#c0392b">조회 오류 : '+esc(e.message)+'</td></tr>'; });
}
/* 하단 목록 — 5행만 보여주고 스크롤이 바닥에 닿으면 다음 5행을 이어붙인다(매출내역과 같은 방식).
     행수에 따라 화면 높이가 들쑥날쑥하던 것을 막는다(2026-07-25 요청).
     페이지 버튼 대신 아래에 '몇 건까지 나왔는지'와 [모두 표시]를 둔다. */
var LIST_ROWS = 5, _lShown = 0, _lBound = false;
function puRowHtml(o, i){
  return '<tr onclick="puPick('+i+')">'
    + '<td><button class="pu-btn" style="height:24px;padding:0 8px;font-size:12px" onclick="event.stopPropagation();puCopy('+i+')">복사저장</button></td>'
    + '<td>'+esc(fmtDt(o.purchDt))+'</td><td>'+esc(o.purchNo)+'</td>'
    + '<td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td><td>'+esc(o.mgrNm)+'</td>'
    + '<td>'+n(o.prodCnt)+'</td><td class="num">'+fmt(o.totAmt)+'</td>'
    + '<td>'+esc(o.whNm)+'</td><td>'+esc(o.regUser)+'</td></tr>';
}
function puListRender(){
  document.getElementById('puTotal').textContent = _list.length;
  var tb = document.getElementById('puListBody');
  if (!_list.length) { tb.innerHTML='<tr><td colspan="9" class="pu-msg">전표가 없습니다.</td></tr>'; _lShown=0; puPagerRender(); puSumRender(); return; }
  _lShown = Math.min(LIST_ROWS, _list.length);
  tb.innerHTML = _list.slice(0,_lShown).map(function(o,i){ return puRowHtml(o,i); }).join('');
  puListBind();
  puPagerRender(); puSumRender();
}
function puListMore(cnt){
  if (_lShown >= _list.length) return;
  var to = Math.min(_lShown + (cnt||LIST_ROWS), _list.length), h='';
  for (var i=_lShown; i<to; i++) h += puRowHtml(_list[i], i);
  document.getElementById('puListBody').insertAdjacentHTML('beforeend', h);
  _lShown = to; puPagerRender();
}
function puListBind(){
  var w = document.getElementById('puListWrap');
  if (!w || _lBound) return; _lBound = true;
  w.addEventListener('scroll', function(){
    if (_lShown >= _list.length) return;
    if (w.scrollTop + w.clientHeight >= w.scrollHeight - 30) puListMore();   // 바닥 30px 전에 미리
  });
}
function puPagerRender(){
  var el = document.getElementById('puPager');
  if (_lShown >= _list.length) {
    el.innerHTML = _list.length > LIST_ROWS
      ? '<span style="color:#5a6b7a; font-size:12.5px">총 '+_list.length+'건 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a; font-size:12.5px">'+_lShown+' / <b>'+_list.length+'</b>건'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="pu-btn" style="height:24px;margin-left:8px;font-size:12px" onclick="puListMore('+_list.length+')">모두 표시</button>';
}
function fmtDt(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function puSumRender(){
  var p=0, r=0, pay=0, dc=0;
  _list.forEach(function(o){ var a=n(o.totAmt); if(a<0) r+=a; else p+=a; pay+=n(o.payAmt); dc+=n(o.dcAmt); });
  document.getElementById('sPurch').textContent=fmt(p);
  document.getElementById('sRet').textContent=fmt(r);
  document.getElementById('sPay').textContent=fmt(pay);
  document.getElementById('sDc').textContent=fmt(dc);
  document.getElementById('sUnpaid').textContent=fmt(p+r-pay-dc);
}
function puPick(i){
  var o = _list[i]; if(!o) return;
  post('/mangr/purchaseDetail.do','purchSeq='+o.purchSeq).then(function(r){return r.json();}).then(function(j){
    var d = j&&j.data; if(!d) return;
    puApply(d);
    Array.prototype.forEach.call(document.querySelectorAll('#puListBody tr'), function(tr,k){ tr.classList.toggle('on', k===i); });
  });
}
/* 서버에서 읽은 전표 1건을 상단 입력 영역에 그대로 얹는다 (선택·새로고침 공용) */
function puApply(d){
  _cur = d;
  _curNet = n(d.totAmt) - n(d.payAmt) - n(d.dcAmt);   // 이 전표가 현잔고에 이미 반영해 둔 금액
  document.getElementById('puDt').value = fmtDt(d.purchDt);
  document.getElementById('puNo').value = d.purchNo;
  var v = document.getElementById('puVenNm'); v.value = d.vendorNm||''; v.dataset.cd = d.vendorCd||'';
  var m = document.getElementById('puMgrNm'); m.value = d.mgrNm||''; m.dataset.cd = d.mgrCd||'';
  /* 저장된 전표를 열 때도 그 거래처의 부가세 설정을 적용한다 —
     안 하면 직전에 보던 거래처의 설정이 남아 금액이 달리 보인다. */
  puVenVat(_vendors.filter(function(x){ return String(x.vendorCd)===String(d.vendorCd||''); })[0]);
  document.getElementById('puWhNm').value = d.whNm||'물류창고';
  document.getElementById('puRemark').value = d.remark||'';
  document.getElementById('puPayGb').value = d.payGb||'외상';
  document.getElementById('puPayAmt').value = n(d.payAmt);
  document.getElementById('puDcAmt').value = n(d.dcAmt);
  _rows = (d.items||[]).map(function(x){ x.taxGb='과세'; return x; });
  _rows.push(emptyRow());
  document.getElementById('puState').textContent = '수정 중 — '+fmtDt(d.purchDt)+' / '+d.purchNo;
  puRender(); puVenBal(d.vendorCd);
}
/* ── 복사저장 ─────────────────────────────────────────
     지난 전표의 명세를 그대로 두고 '매입일자'와 '거래처'만 바꿔 새 전표로 만든다.
     같은 물건을 다른 거래처에서도 사거나, 같은 거래처에 반복 매입할 때 쓴다.
     팝업에서 일자·거래처를 고르면 그 조건으로 상단에 복사본이 올라온다(저장은 아직 안 함). */
var _cpSrc = -1;
function puCopy(i){
  _cpSrc = i;
  var o = _list[i];
  document.getElementById('cpDt').value = o ? fmtDt(o.purchDt) : today();
  document.getElementById('cpQ').value = '';
  puCopyRender();
  document.getElementById('puCopyPop').classList.add('on');
}
function puCopyClose(){ document.getElementById('puCopyPop').classList.remove('on'); }
function puCopyRender(){
  var q = (document.getElementById('cpQ').value||'').toLowerCase();
  var l = _vendors.filter(function(o){
    if(!puVenFit(o)) return false;
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  }).slice(0,200);
  document.getElementById('cpBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="puCopyPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td>'
         + '<td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td><td>'+esc(o.alias)+'</td>'
         + '<td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="7" class="pu-msg">검색 결과가 없습니다.</td></tr>';
}
function puCopyPick(cd){
  var src = _list[_cpSrc]; if(!src) { puCopyClose(); return; }
  var ven = _vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0];
  var dt  = document.getElementById('cpDt').value || today();
  puCopyClose();
  post('/mangr/purchaseDetail.do','purchSeq='+src.purchSeq).then(function(r){return r.json();}).then(function(j){
    var d = j&&j.data; if(!d) return;
    puApply(d);                       // 명세를 그대로 올린 뒤
    _cur = null; _curNet = 0;         // 새 전표로 돌린다 — 현잔고에 반영된 게 없다
    document.getElementById('puDt').value = dt;
    if (ven) {
      var v = document.getElementById('puVenNm'); v.value = ven.vendorNm||''; v.dataset.cd = ven.vendorCd||'';
      var m = document.getElementById('puMgrNm'); m.value = ven.mgrNm||''; m.dataset.cd = ven.mgrCd||'';
      puVenBal(ven.vendorCd);         // 바뀐 거래처의 현잔고·원장으로 갱신
    }
    document.getElementById('puState').textContent =
      '복사본 — ' + dt + ' / ' + (ven?ven.vendorNm:'') + ' · 내용 확인 후 [저장]';
    puNextNo();
    Array.prototype.forEach.call(document.querySelectorAll('#puListBody tr'), function(tr){ tr.classList.remove('on'); });
  }).catch(function(e){ swErr('복사에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
}

/* ── 거래처 / 상품 / 단가이력 팝업 ───────────────────── */
/* ── 거래처 거래유형 필터 (2026-08-03 요청) ─────────────────────────
     이 화면은 '매입' 화면이라 매입 거래처만 보여 주는 게 맞다(거래처가 400여 종이라
     반대편 거래처가 섞이면 고르기 어렵다). 다만 —
     · '매입&매출' 은 양쪽 다 보인다.
     · **거래유형이 안 적힌 예전 거래처는 그대로 보여 준다** — 안 그러면 분류를 안 해 둔
       거래처가 화면에서 통째로 사라져 "거래처가 없어졌다" 가 된다.
     · [전체] 로 끄면 모두 보인다(오분류를 찾을 때 필요). */
  var _venAll = false;
  function puVenFit(o){
    if (_venAll) return true;
    var g = String((o && o.vendorGb) || '');
    return !g || g.indexOf('매입') >= 0;
  }
  function puVenAll(on){
    _venAll = !!on;
    var b = document.getElementById('puVenAllBtn');
    if (b) { b.textContent = _venAll ? '전체 ✔' : '전체'; b.classList.toggle('teal', _venAll); }
    puVenRender();
  }
  /* 없는 거래처를 이 자리에서 등록 — 저장되면 목록에 넣고 곧바로 고른 상태로 만든다 */
  function puVenNew(){
    var box = document.getElementById('puVenNm');
    var typed = (box && box.value || '').trim();
    /* 팝업 검색칸에 친 글자가 있으면 그걸 우선 쓴다(대개 거기서 못 찾아 누른다) */
    var q = document.getElementById('puVenQ');
    if (q && document.getElementById('puVenPop').classList.contains('on') && (q.value||'').trim()) typed = q.value.trim();
    _vendorQuickOpen({
      gb: '매입', ctx: CTX, name: typed,
      list: function(){ return _vendors; },
      onDone: function(o){
        _vendors.push(o);
        puVenClose();
        if (box) { box.value = o.vendorNm; box.dataset.cd = o.vendorCd; }
        puVenPick(o.vendorCd);
        swOk('거래처를 등록했습니다 — '+o.vendorNm+' ('+o.vendorCd+')');
      }
    });
  }
  function puVenOpen(){ document.getElementById('puVenPop').classList.add('on'); document.getElementById('puVenQ').value=''; puVenRender(); }
function puVenClose(){ document.getElementById('puVenPop').classList.remove('on'); }
function puVenRender(){
  var q = (document.getElementById('puVenQ').value||'').toLowerCase();
  var l = _vendors.filter(function(o){
    if(!puVenFit(o)) return false;
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  });
  /* 총매입금액 많은 순 — 같거나 없으면 이름순(2026-08-04 요청) */
  l.sort(function(a,b){
    var d = ((_venSum[b.vendorCd]||{}).p||0) - ((_venSum[a.vendorCd]||{}).p||0);
    return d || String(a.vendorNm||'').localeCompare(String(b.vendorNm||''), 'ko');
  });
  l = l.slice(0,200);
  document.getElementById('puVenBody').innerHTML = l.length ? l.map(function(o){
    var gb = String(o.vendorGb||''), vt = String(o.vatGb||'') || '별도';
    var sum = _venSum[o.vendorCd] || {};
    return '<tr class="pick" onclick="puVenPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td><td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td>'
         /* 거래유형·부가세도 같이 보여 준다 (2026-08-03 요청) — 고르기 전에 성격을 알 수 있게.
            부가세가 비어 있는 예전 거래처는 '별도*' 로 — 계산도 별도로 하고 있음을 별표로 알린다. */
         + '<td>'+(gb ? '<span class="vp-gb'+(gb.indexOf('&')>=0?' both':'')+'">'+esc(gb)+'</span>'
                      : '<span class="vp-gb none">미지정</span>')+'</td>'
         + '<td><span class="vat-tag'+(vt==='면세'?' free':(vt==='포함'?' inc':''))+'">'+esc(vt)+(o.vatGb?'':'*')+'</span></td>'
         /* 총매입·총판매 — 0 이면 빈칸(숫자 소음을 줄인다). 이 목록의 정렬 기준이 총매입이다.
            ★총판매에는 <정산서 매출과 판매전표가 모두> 들어간다 — hover 로 내역을 보여 준다(2026-08-04). */
         + '<td class="num">'+(sum.p ? fmt(sum.p) : '')+'</td>'
         + '<td class="num"'+(sum.s ? ' title="정산서 '+fmt(sum.st)+' + 판매전표 '+fmt(sum.tx)+' = '+fmt(sum.s)+'"' : '')+'>'
         +   (sum.s ? fmt(sum.s) : '')+'</td>'
         + '<td>'+esc(o.alias)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="9" class="pu-msg">검색 결과가 없습니다.</td></tr>';
}
function puVenPick(cd){
  var o = _vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0]; if(!o) return;
  var v = document.getElementById('puVenNm'); v.value = o.vendorNm||''; v.dataset.cd = o.vendorCd||'';
  var m = document.getElementById('puMgrNm'); m.value = o.mgrNm||''; m.dataset.cd = o.mgrCd||'';
  puVenVat(o);
  puVenClose(); puVenBal(o.vendorCd);
}
/* 현잔고 = 그 거래처 전표의 미지급 누계 */
function puVenBal(cd){
  if(!cd){ document.getElementById('puBalNow').textContent='0'; puCalc(); puLedger(''); return; }
  post('/mangr/purchaseList.do','vendorCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l=(j&&j.data)||[], bal=0;
    l.forEach(function(o){ bal += n(o.totAmt) - n(o.payAmt) - n(o.dcAmt); });
    document.getElementById('puBalNow').textContent = fmt(bal); puCalc();
  }).catch(function(){});
  puLedger(cd);
}

/* ── 거래처 원장(분개장) ──────────────────────────────
     서버는 일자별 매입·DC·지급·할인만 준다. 잔고 누계와 [월 계]·[합 계] 는 여기서 만든다
     (원본 화면과 같은 형태 — 월이 바뀌는 자리에 월계 줄을 끼워 넣는다). */
/* ★ 원장을 그린 거래처를 따로 들고 있는다 (2026-07-31).
     저장 후 puNew() 는 상단 거래처를 비우지만 원장은 그대로 남는다. 그 상태에서
     원장 일자를 눌렀을 때 상단 거래처(빈 값)를 보면 아무 일도 안 일어난 것처럼 죽는다. */
var _lgCd = '', _lgSeq = 0;
function puLedger(cd){
  _lgCd = cd || '';
  var tb = document.getElementById('lgBody'), wrap = document.getElementById('lgWrap');
  var seq = ++_lgSeq;                     /* 행을 연달아 눌러도 <마지막 요청>만 화면에 남는다 */
  document.getElementById('lgVen').textContent = cd ? (document.getElementById('puVenNm').value||cd) : '—';
  if(!cd){ tb.innerHTML='<tr><td colspan="6" class="pu-msg">거래처를 선택하세요.</td></tr>'; document.getElementById('lgFoot').innerHTML=''; return; }
  /* ★깜박임 방지(2026-08-04 — 판매등록과 동일) — 표를 지우지 않고 살짝 흐리게만 두었다가
       새 자료가 오면 통째로 갈아끼운다. '불러오는 중…' 으로 비우면 행을 누를 때마다 번쩍인다. */
  wrap.style.transition = 'opacity .15s'; wrap.style.opacity = '.55';
  post('/mangr/purchaseLedger.do','vendorCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    if (seq !== _lgSeq) return;           /* 더 새 요청이 이미 나갔다 — 이 응답은 버린다 */
    wrap.style.opacity = '';
    var l = (j&&j.data)||[];
    if(!l.length){ tb.innerHTML='<tr><td colspan="6" class="pu-msg">거래 내역이 없습니다.</td></tr>'; document.getElementById('lgFoot').innerHTML=''; return; }
    var h='', bal=0, mm=null, m={p:0,d:0,y:0,c:0}, t={p:0,d:0,y:0,c:0};
    function monthRow(){
      if(mm===null) return '';
      return '<tr style="background:#e8f6ec"><td>[월 계]</td><td class="num">'+fmt(m.p)+'</td><td class="num">'+fmt(m.d)
           + '</td><td class="num">'+fmt(m.y)+'</td><td class="num">'+fmt(m.c)+'</td><td></td></tr>';
    }
    l.forEach(function(o){
      var dt = String(o.dt||''), ym = dt.slice(0,6);
      var p=n(o.purchAmt), d=n(o.dcAmt), y=n(o.payAmt), c=n(o.discAmt);
      if(mm!==null && ym!==mm){ h+=monthRow(); m={p:0,d:0,y:0,c:0}; }
      mm = ym;
      bal += p - d - y - c;
      m.p+=p; m.d+=d; m.y+=y; m.c+=c;
      t.p+=p; t.d+=d; t.y+=y; t.c+=c;
      /* 일자 줄 클릭 → 그 날 매입품목 팝업(2026-07-31). [월 계]·[합 계] 줄은 클릭 대상이 아니다 */
      h += '<tr onclick="puDayOpen(\''+dt+'\')" title="클릭 → 이 날 매입품목 보기">'
         + '<td>'+esc(fmtDt(dt))+'</td><td class="num">'+fmt(p)+'</td><td class="num">'+fmt(d)
         + '</td><td class="num">'+fmt(y)+'</td><td class="num">'+fmt(c)+'</td><td class="num"><b>'+fmt(bal)+'</b></td></tr>';
    });
    h += monthRow();
    tb.innerHTML = h;
    /* 합계는 스크롤 영역 밖에 — 아무리 내려도 항상 보인다 */
    document.getElementById('lgFoot').innerHTML =
      '<tr><td>합 계</td><td>'+fmt(t.p)+'</td><td>'+fmt(t.d)+'</td><td>'+fmt(t.y)+'</td><td>'+fmt(t.c)+'</td><td>'+fmt(bal)+'</td></tr>';
  }).catch(function(e){
    if (seq !== _lgSeq) return;
    wrap.style.opacity = '';
    tb.innerHTML='<tr><td colspan="6" class="pu-msg" style="color:#c0392b">원장 조회 오류</td></tr>';
  });
}

function puProdOpen(i){
  _prodTargetRow=i; document.getElementById('puProdPop').classList.add('on');
  var q=document.getElementById('puProdQ'); q.value='';
  _ppPick = [];                          // 다중선택은 열 때마다 새로 시작
  puProdRender();
  /* 열리면 바로 검색칸에 커서 — 마우스로 칸을 다시 누를 필요 없이 즉시 친다(2026-08-05 요청) */
  setTimeout(function(){ q.focus(); }, 0);
}
function puProdClose(){ document.getElementById('puProdPop').classList.remove('on'); }
function puProdRender(){
  var q = (document.getElementById('puProdQ').value||'').toLowerCase();
  /* 코드로 검색하면 장부 넘겨 보듯 — 걸린 상품(코드순)을 앞에 두고, 그 뒤에 **찾은 코드 다음
     코드의 상품들을 이어서** 보여 준다(2026-08-05 요청 — 걸린 것만 나오면 이웃 상품을 못 고른다).
     걸린 상품은 코드를 굵은 초록으로 표시해 이어붙은 이웃과 구분한다. 이름·규격 매치는 맨 뒤. */
  var l, hit = {};
  if(!q){ l = _prods.slice(0,200); }
  else{
    var byCd=[], byNm=[];
    _prods.forEach(function(o){
      if(String(o.prodCd||'').toLowerCase().indexOf(q)>=0) byCd.push(o);
      else if([o.prodNm,o.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) byNm.push(o);
    });
    var byCode = function(a,b){ return String(a.prodCd||'').localeCompare(String(b.prodCd||'')); };
    byCd.sort(byCode);
    if(byCd.length){
      byCd.forEach(function(o){ hit[String(o.prodCd)]=1; });
      var first = String(byCd[0].prodCd||'');
      var after = _prods.filter(function(o){ return !hit[String(o.prodCd)] && String(o.prodCd||'') > first; }).sort(byCode);
      l = byCd.concat(after).concat(byNm).slice(0,200);
    }else l = byNm.slice(0,200);
  }
  document.getElementById('puProdBody').innerHTML = l.length ? l.map(function(o){
    var cd = hit[String(o.prodCd)] ? '<b style="color:#137a6c">'+esc(o.prodCd)+'</b>' : esc(o.prodCd);
    /* ✔칸 — 체크하면 순번(1,2,3…)이 찍히고 그 순서대로 담긴다. 체크박스 클릭이 줄 클릭(한 건 담기)으로
       번지지 않게 td 에서 끊는다. 체크박스 자체 클릭도 td 로 흘러 한 번만 토글된다(pointer-events 없음). */
    var k = _ppPick.indexOf(String(o.prodCd));
    return '<tr class="pick" onclick="puProdPick(\''+esc(o.prodCd)+'\')">'
         + '<td style="cursor:pointer" onclick="event.stopPropagation();puProdToggle(\''+esc(o.prodCd)+'\')">'
         +   (k>=0 ? '<b style="color:#137a6c">'+(k+1)+'</b>' : '<input type="checkbox" style="pointer-events:none">')
         + '</td>'
         + '<td>'+cd+'</td><td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
         + '<td>'+esc(o.spec)+'</td><td class="num">'+n(o.packQty)+'</td><td class="num">'+fmt(o.inPrice)+'</td></tr>';
  }).join('') : '<tr><td colspan="6" class="pu-msg">검색 결과가 없습니다.</td></tr>';
  puPickInfo();
}
/* ── 상품 다중선택 담기 (2026-08-06 요청) ─────────────────
     ✔를 체크한 순서대로 명세에 한꺼번에 담는다(매입분 팝업과 같은 방식).
     담긴 줄의 BOX수량은 기본 1 — 수량이 다른 줄만 고치면 된다.
     줄 클릭(한 건 즉시 담기)은 종전 그대로다. 검색어를 바꿔도 체크는 유지된다(팝업을 열 때 초기화). */
var _ppPick = [];
function puProdToggle(cd){
  cd = String(cd);
  var k = _ppPick.indexOf(cd);
  if (k >= 0) _ppPick.splice(k,1); else _ppPick.push(cd);   // 뺀 자리는 뒤 번호가 당겨진다
  puProdRender();
}
function puPickInfo(){
  var el = document.getElementById('puPickInfo');
  if (el) el.textContent = _ppPick.length ? ('선택 '+_ppPick.length+'건 — 체크한 순서대로 담깁니다 (BOX수량 1)') : '';
}
function puProdMultiApply(){
  if (!_ppPick.length) { swErr('담을 상품을 체크하세요.<br><span style="font-size:12.5px;color:#3d4d5c">한 건만 담을 때는 줄을 바로 클릭하면 됩니다.</span>'); return; }
  var ven = document.getElementById('puVenNm').dataset.cd || '';
  var rows = _rows.filter(function(o){ return o.prodCd; });
  var added = [], dup = [];
  _ppPick.forEach(function(cd){
    var p = _prods.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!p) return;
    if (rows.some(function(o){ return String(o.prodCd)===String(cd); })) { dup.push(cd); return; }
    var o = emptyRow();
    o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=p.prodNm; o.spec=p.spec||'';
    o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
    o.unitPrice=n(p.inPrice);
    o.boxQty=1;                                   // BOX수량 기본 1 (2026-08-06 요청)
    puCalcRow(o);
    rows.push(o); added.push(o);
  });
  rows.push(emptyRow());
  _rows = rows; _pShown = _rows.length;
  puRender(); puProdClose();
  /* 그 거래처의 최근 매입단가가 있으면 그 값으로 덮는다 — 한 건 담기(puProdPick)와 같은 규칙 */
  added.forEach(function(o){
    post('/mangr/purchaseLastPrice.do','prodCd='+encodeURIComponent(o.prodCd)+'&remark='+encodeURIComponent(ven))
      .then(function(r){return r.json();}).then(function(j){ if(j&&j.data){ o.unitPrice=n(j.data); puCalcRow(o); puRender(); } })
      .catch(function(){});
  });
  if (dup.length) swAlert(added.length+'건을 담았습니다.<br><span style="font-size:12.5px;color:#3d4d5c">이미 명세에 있는 '+dup.length+'건은 건너뛰었습니다 — '+esc(dup.join(', '))+'</span>');
}
function puProdPick(cd){
  var p = _prods.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!p) return;
  var o = _rows[_prodTargetRow]; if(!o) return;
  o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=p.prodNm; o.spec=p.spec||'';
  o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
  o.unitPrice=n(p.inPrice);
  /* 수량이 빈 줄이면 BOX수량 기본 1 (2026-08-06 요청 — 인라인 검색·팝업 한 건 담기 포함).
     이미 수량이 있는 줄(다른 상품으로 바꾸기)은 건드리지 않는다. */
  if (!n(o.boxQty) && !n(o.eaQty)) o.boxQty = 1;
  puProdClose();
  // 그 거래처의 최근 매입단가가 있으면 그 값으로 덮는다
  var ven = document.getElementById('puVenNm').dataset.cd||'';
  post('/mangr/purchaseLastPrice.do','prodCd='+encodeURIComponent(p.prodCd)+'&remark='+encodeURIComponent(ven))
    .then(function(r){return r.json();}).then(function(j){ if(j&&j.data) o.unitPrice=n(j.data); })
    .catch(function(){}).then(function(){
      puCalcRow(o);
      if (_prodTargetRow === _rows.length-1) puEnsureTail();
      puRender();
    });
}

/* ── 일괄등록 (2026-08-06 요청) ────────────────────────────
     거래처는 '선택된 상태' 그대로, 팝업의 매입일자만 바꿔 여러 상품을 한 번에 전표로 만든다.
       · 탭1 [상품코드]      : 상품마스터를 코드순으로 — ✔ 체크한 순서대로 담긴다. BOX수량 1.
       · 탭2 [최근 매입내역] : 원장에서 매입이 있던 일자(최근 15일치)를 최근 것부터 —
         selectCustDayDetail 로 그 날 매입 줄을 읽어 일자별로 묶는다. 일자 머리줄 ✔ = 그 날 전체선택.
         수량·단가는 그때 그대로(원장 [불러오기]와 같은 셈법 — 총수량을 입수로 박스/낱개 분해).
       · [명세에 담기] = 그리드에 올려 확인 후 저장 / [일괄저장] = 전표번호를 새 일자로 받아 그 자리에서 puSave().
     ★지금 입력 중인 명세는 지워진다 — 확인창에서 미리 알린다(원장 불러오기와 동일).
     탭별 체크는 따로 들고 있으며, [담기]/[저장]은 지금 보고 있는 탭의 체크만 쓴다. */
var _btTab = 1, _btDays = null;
/* 체크한 순서 그대로 쌓이는 '담을 내용' — {t:1, cd:상품코드, dt:등록일자} | {t:2, di, ii, dt}.
   ★dt = '체크하는 순간'의 위 매입일자 (2026-08-06 요청) —
     일자를 바꿔 가며 체크하면 일자별로 나뉘어 쌓이고, [일괄저장]이 일자마다 전표 한 장씩 만든다.
     일자를 바꾸면 아래 목록의 체크 표시는 새로 시작된다(먼저 담은 일자 것은 위 미리보기에 그대로). */
var _btSel = [];
function btDtVal(){ return document.getElementById('btDt').value || today(); }
function btSelIdx1(cd){ var d=btDtVal(); for (var i=0;i<_btSel.length;i++){ var s=_btSel[i]; if (s.t===1 && String(s.cd)===String(cd) && s.dt===d) return i; } return -1; }
function btSelIdx2(di,ii){ var d=btDtVal(); for (var i=0;i<_btSel.length;i++){ var s=_btSel[i]; if (s.t===2 && s.di===di && s.ii===ii && s.dt===d) return i; } return -1; }
/* 순번은 일자(전표)마다 1부터 다시 센다 (2026-08-06 요청) — k번째 체크의 '그 일자 안' 순서 */
function btOrderOf(k){ if (k<0) return 0; var d=_btSel[k].dt, c=0; for (var i=0;i<=k;i++){ if (_btSel[i].dt===d) c++; } return c; }

function puBatchOpen(){
  var cd = document.getElementById('puVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _btTab = 1; _btSel = []; _btDays = null;
  document.getElementById('btVen').textContent = document.getElementById('puVenNm').value || cd;
  document.getElementById('btDt').value = document.getElementById('puDt').value || today();
  document.getElementById('btQ').value = '';
  document.getElementById('puBatchPop').classList.add('on');
  puBatchTab(1);
  puBatchSelRender();
  puBatchDtHint();
}
function puBatchClose(){ document.getElementById('puBatchPop').classList.remove('on'); }
/* 매입일자를 바꾸면 그 날 이 거래처 전표가 이미 있는지 일자 옆에 바로 알려 준다(저장은 막지 않는다).
   확정 알림은 [담기]/[일괄저장] 확인창에서 한 번 더 나온다. */
var _btDtSeq = 0;
function puBatchDtHint(){
  var el = document.getElementById('btDtHint');
  var venCd = document.getElementById('puVenNm').dataset.cd || '';
  var dt = document.getElementById('btDt').value;
  if (!el) return;
  el.textContent = '';
  if (!venCd || !dt) return;
  var seq = ++_btDtSeq;                     /* 연달아 바꿔도 마지막 요청만 표시 */
  post('/mangr/purchaseList.do','vendorCd='+encodeURIComponent(venCd)).then(function(r){return r.json();}).then(function(j){
    if (seq !== _btDtSeq) return;
    var d8 = dt.replace(/-/g,'');
    var ex = ((j&&j.data)||[]).filter(function(o){ return String(o.purchDt||'')===d8; });
    el.textContent = ex.length ? ('⚠ 이 일자에 전표 '+ex.length+'건 있음') : '';
  }).catch(function(){});
}
function puBatchTab(t){
  _btTab = t;
  document.getElementById('btTab1').classList.toggle('teal', t===1);
  document.getElementById('btTab2').classList.toggle('teal', t===2);
  if (t===2 && _btDays === null) { puBatchLoad2(); return; }
  puBatchRender();
}
/* 탭2 자료 — 원장에서 매입이 있던 일자를 최근 것부터 15일치 골라, 날짜별 매입 줄을 병렬로 읽는다 */
function puBatchLoad2(){
  var cd = document.getElementById('puVenNm').dataset.cd || '';
  document.getElementById('btHead').innerHTML = '';
  document.getElementById('btBody').innerHTML = '<tr><td class="pu-msg">최근 매입내역을 불러오는 중…</td></tr>';
  post('/mangr/purchaseLedger.do','vendorCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var dts = [];
    ((j&&j.data)||[]).forEach(function(o){ if (n(o.purchAmt)) dts.push(String(o.dt||'')); });
    dts = dts.filter(function(d,i){ return d && dts.indexOf(d)===i; }).sort().reverse().slice(0,15);
    if (!dts.length) { _btDays = []; puBatchRender(); return; }
    return Promise.all(dts.map(function(dt){
      return post('/mangr/selectCustDayDetail.do','custCd='+encodeURIComponent(cd)+'&trxDt='+encodeURIComponent(dt))
        .then(function(r){return r.json();})
        .then(function(j2){ return { dt:dt, items:((j2&&j2.data)||[]).filter(function(o){ return o.gb==='PURCH'; }) }; })
        .catch(function(){ return { dt:dt, items:[] }; });
    })).then(function(gs){ _btDays = gs.filter(function(g){ return g.items.length; }); puBatchRender(); });
  }).catch(function(){
    _btDays = [];
    document.getElementById('btBody').innerHTML = '<tr><td class="pu-msg" style="color:#c0392b">최근 매입내역 조회 오류</td></tr>';
  });
}
function puBatchRender(){ if (_btTab===1) puBatchRender1(); else puBatchRender2(); }
function puBatchRender1(){
  var q = (document.getElementById('btQ').value||'').toLowerCase();
  document.getElementById('btHead').innerHTML =
    '<tr><th style="width:44px" title="체크한 순서대로 담깁니다">✔</th><th style="width:110px">상품코드</th><th>상품명</th>'
    + '<th style="width:110px">규격</th><th style="width:60px">입수</th><th style="width:90px">매입가</th></tr>';
  /* 코드로 검색하면 장부 넘겨 보듯 — 상품선택 팝업(puProdRender)과 같은 규칙(2026-08-06 요청).
       걸린 상품(코드순)을 앞에 두고, 그 뒤에 찾은 코드 '다음 코드'의 상품들을 이어서 보여 준다.
       걸린 상품은 코드를 굵은 초록으로 구분. 이름·규격 매치는 맨 뒤. */
  var byCode = function(a,b){ return String(a.prodCd||'').localeCompare(String(b.prodCd||'')); };
  var l, hit = {};
  if(!q){ l = _prods.slice().sort(byCode).slice(0,300); }
  else{
    var byCd=[], byNm=[];
    _prods.forEach(function(o){
      if(String(o.prodCd||'').toLowerCase().indexOf(q)>=0) byCd.push(o);
      else if([o.prodNm,o.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) byNm.push(o);
    });
    byCd.sort(byCode);
    if(byCd.length){
      byCd.forEach(function(o){ hit[String(o.prodCd)]=1; });
      var first = String(byCd[0].prodCd||'');
      var after = _prods.filter(function(o){ return !hit[String(o.prodCd)] && String(o.prodCd||'') > first; }).sort(byCode);
      l = byCd.concat(after).concat(byNm).slice(0,300);
    }else l = byNm.slice(0,300);
  }
  document.getElementById('btBody').innerHTML = l.length ? l.map(function(o){
    var k = btSelIdx1(o.prodCd);
    var cd = hit[String(o.prodCd)] ? '<b style="color:#137a6c">'+esc(o.prodCd)+'</b>' : esc(o.prodCd);
    /* 상품명은 좁게 — 긴 이름은 …로 줄이고 전체는 툴팁으로(2026-08-06 요청, 우측 칸이 좁아졌다) */
    return '<tr class="pick" onclick="puBatchTgl1(\''+esc(o.prodCd)+'\')">'
      + '<td>'+(k>=0 ? '<b style="color:#137a6c">'+btOrderOf(k)+'</b>' : '<input type="checkbox" style="pointer-events:none">')+'</td>'
      + '<td>'+cd+'</td><td class="txt" style="text-align:left;max-width:210px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="'+esc(o.prodNm)+'">'+esc(o.prodNm)+'</td>'
      + '<td>'+esc(o.spec)+'</td><td class="num">'+n(o.packQty)+'</td><td class="num">'+fmt(o.inPrice)+'</td></tr>';
  }).join('') : '<tr><td colspan="6" class="pu-msg">검색 결과가 없습니다.</td></tr>';
  puBatchInfo();
}
function puBatchRender2(){
  /* 세부 줄의 일자 칸은 없다 (2026-08-06 요청) — 일자 머리줄(대표일자)이 이미 있어 중복이고,
     좁은 우측 칸에서 날짜가 두 줄로 꺾여 지저분했다. */
  document.getElementById('btHead').innerHTML =
    '<tr><th style="width:44px">✔</th><th style="width:106px">상품코드</th><th>상품명</th>'
    + '<th style="width:66px">수량</th><th style="width:84px">단가</th><th style="width:96px">금액</th></tr>';
  if (_btDays === null) return;                       // 아직 읽는 중
  var q = (document.getElementById('btQ').value||'').toLowerCase();
  var h = '';
  _btDays.forEach(function(g, di){
    var idx = [];                                     // 검색에 걸린 줄만 (일자 전체선택도 이 줄들만)
    g.items.forEach(function(o, ii){
      if (!q || [o.itemCd,o.itemNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) idx.push(ii);
    });
    if (!idx.length) return;
    var all = idx.every(function(ii){ return btSelIdx2(di,ii) >= 0; });
    /* 그 날 원천 전표번호도 같이 표시 (2026-08-06 요청 '양쪽 전표표시') — 어느 전표에서 온 내역인지 보이게 */
    var sum = 0, dns = [];
    idx.forEach(function(ii){ sum += n(g.items[ii].amt);
      var dn = String(g.items[ii].docNo||''); if (dn && dns.indexOf(dn)<0) dns.push(dn); });
    h += '<tr style="background:#e8f6ec; cursor:pointer" onclick="puBatchDayAll('+di+','+(all?'false':'true')+')" title="클릭 → 이 날 전체선택/해제">'
      + '<td><input type="checkbox" style="pointer-events:none"'+(all?' checked':'')+'></td>'
      + '<td colspan="2" class="txt" style="text-align:left"><b>'+esc(fmtDt(g.dt))+'</b> — '+idx.length+'건'
      +   (dns.length ? ' <span style="color:#137a6c;font-weight:700">전표 '+esc(dns.join(', '))+'</span>' : '')
      +   ' <span style="color:#5a6b7a">(일자별 전체선택)</span></td>'
      + '<td></td><td></td><td class="num"><b>'+fmt(sum)+'</b></td></tr>';
    idx.forEach(function(ii){
      var o = g.items[ii], on = btSelIdx2(di,ii) >= 0;
      /* 세부 줄의 일자 칸 없음 — 위 일자 머리줄(대표일자)로 충분(2026-08-06 요청) */
      h += '<tr class="pick" onclick="puBatchTgl2('+di+','+ii+')">'
        + '<td><input type="checkbox" style="pointer-events:none"'+(on?' checked':'')+'></td>'
        + '<td>'+esc(o.itemCd)+'</td>'
        + '<td class="txt" style="text-align:left;max-width:210px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="'+esc(o.itemNm)+'">'+esc(o.itemNm)+'</td>'
        + '<td class="num">'+fmt(o.qty)+'</td><td class="num">'+fmtP(o.price)+'</td><td class="num">'+fmt(o.amt)+'</td></tr>';
    });
  });
  document.getElementById('btBody').innerHTML = h || '<tr><td colspan="6" class="pu-msg">'
    + (q ? '검색 결과가 없습니다.' : '이 거래처의 최근 매입내역이 없습니다.') + '</td></tr>';
  puBatchInfo();
}
function puBatchTgl1(cd){
  var k = btSelIdx1(cd);
  if (k>=0) _btSel.splice(k,1); else _btSel.push({ t:1, cd:String(cd), dt:btDtVal() });
  puBatchRender1(); puBatchSelRender();
}
function puBatchTgl2(di, ii){
  var k = btSelIdx2(di, ii);
  if (k>=0) _btSel.splice(k,1); else _btSel.push({ t:2, di:di, ii:ii, dt:btDtVal() });
  puBatchRender2(); puBatchSelRender();
}
function puBatchDayAll(di, on){
  var q = (document.getElementById('btQ').value||'').toLowerCase();
  var g = _btDays[di]; if(!g) return;
  g.items.forEach(function(o, ii){
    if (q && ![o.itemCd,o.itemNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; })) return;
    var k = btSelIdx2(di, ii);
    if (on) { if (k<0) _btSel.push({ t:2, di:di, ii:ii, dt:btDtVal() }); }
    else if (k>=0) _btSel.splice(k,1);
  });
  puBatchRender2(); puBatchSelRender();
}
function puBatchInfo(){
  document.getElementById('btCnt').textContent = _btSel.length ? ('담을 내용 '+_btSel.length+'건') : '';
}
/* 체크 하나를 명세 행 하나로 — 상단 미리보기와 [담기]/[저장]이 같은 계산을 쓴다 */
function puBatchRowFor(s){
  if (s.t===1){
    var p = _prods.filter(function(x){ return String(x.prodCd)===String(s.cd); })[0]; if(!p) return null;
    var o = emptyRow();
    o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=p.prodNm; o.spec=p.spec||'';
    o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
    o.unitPrice=n(p.inPrice);
    o.boxQty=1;                                       // BOX수량 기본 1
    puCalcRow(o);
    return btSelOverride(s, o);                       // 미리보기에서 고친 BOX·EA·단가 반영
  }
  var g = (_btDays||[])[s.di], it = g && g.items[s.ii]; if(!it) return null;
  var p2 = _prods.filter(function(x){ return String(x.prodCd)===String(it.itemCd); })[0] || {};
  var r = emptyRow();
  r.prodSeq = p2.prodSeq; r.prodCd = it.itemCd; r.prodNm = it.itemNm || p2.prodNm || '';
  r.spec = p2.spec || ''; r.packQty = n(p2.packQty)||1; r.taxGb = p2.taxGb || '과세';
  r.unitPrice = n(it.price);
  /* 수량은 총수량으로 온다 — 입수가 있으면 박스/낱개로 쪼갠다(원장 [불러오기]와 같은 셈법) */
  var qv = n(it.qty), pk = n(r.packQty)||1;
  if (pk > 1) { r.boxQty = Math.floor(Math.abs(qv)/pk) * (qv<0?-1:1); r.eaQty = qv - r.boxQty*pk; }
  else { r.boxQty = 0; r.eaQty = qv; }
  if (qv < 0) { r.trxGb = '반품'; r.boxQty = Math.abs(r.boxQty); r.eaQty = Math.abs(r.eaQty); }
  puCalcRow(r);
  return btSelOverride(s, r);
}
/* 미리보기에서 고친 값(BOX·EA·단가)은 체크 항목(s)에 남겨 두었다가 매번 덮어씌운다 —
   행은 렌더 때마다 새로 만들어지므로(puBatchRowFor) 여기 안 두면 고친 값이 사라진다(2026-08-06 요청). */
function btSelOverride(s, o){
  if (s.boxQty    != null) o.boxQty    = n(s.boxQty);
  if (s.eaQty     != null) o.eaQty     = n(s.eaQty);
  if (s.unitPrice != null) o.unitPrice = n(s.unitPrice);
  if (s.boxQty != null || s.eaQty != null || s.unitPrice != null) puCalcRow(o);
  return o;
}
function puBatchSelSet(i, k, v){
  var s = _btSel[i]; if(!s) return;
  s[k] = n(v);
  puBatchSelRender();
}
/* 상단 '담을 내용' 미리보기 — 체크한 순서 그대로, 등록일자(dt)가 바뀌는 자리에 일자 머리줄을 끼운다.
   [일괄저장]이 이 일자 단위로 전표를 한 장씩 만든다. ✖ 로 한 줄씩 뺄 수 있다 */
function puBatchSelRender(){
  var tb = document.getElementById('btSelBody');
  if (!_btSel.length){
    tb.innerHTML = '<tr><td colspan="11" class="pu-msg">오른쪽 목록에서 체크하면 여기에 담깁니다. 일자를 바꿔 체크하면 일자별 전표로 나뉩니다.</td></tr>';
    puBatchInfo(); return;
  }
  var perDt = {};
  _btSel.forEach(function(s){ perDt[s.dt] = (perDt[s.dt]||0) + 1; });
  /* BOX·EA·단가는 본 명세 그리드처럼 입력칸 — 고치면 합계·금액이 그 자리에서 다시 계산된다(2026-08-06 요청) */
  var inp = 'style="width:100%;border:0;background:transparent;font-size:13px;text-align:right;padding:2px"';
  var h = '', tot = 0, cnt = 0, num = 0, lastDt = null;
  _btSel.forEach(function(s, i){
    var o = puBatchRowFor(s); if(!o) return;
    if (s.dt !== lastDt){
      lastDt = s.dt; num = 0;                          /* 일자(전표)가 바뀌면 순번 1부터 다시 */
      /* 일자별 삭제는 그 일자 머리줄에서 (2026-08-06 요청) — 이 전표(일자)로 담은 줄을 통째로 뺀다 */
      h += '<tr style="background:#e8f6ec"><td colspan="10" class="txt" style="text-align:left"><b>📅 '+esc(s.dt)+'</b> 전표 — '+perDt[s.dt]+'건 <span style="color:#5a6b7a">— 이 일자로 저장됩니다</span></td>'
        + '<td><span style="color:#c0392b;cursor:pointer;font-weight:700;white-space:nowrap" title="'+esc(s.dt)+' 전표로 담은 줄 모두 빼기" onclick="puBatchDelDtOf(\''+esc(s.dt)+'\')">✖</span></td></tr>';
    }
    num++; cnt++; tot += n(o.totAmt) * (o.trxGb==='반품' ? -1 : 1);
    h += '<tr'+(o.trxGb==='반품' ? ' style="color:#c0392b"' : '')+'><td>'+num+'</td>'
      /* ▲▼ 순서 조정 — 코드 앞 (2026-08-06 요청). 같은 일자(전표) 안에서만 움직인다 */
      + '<td style="white-space:nowrap">'
      +   '<span style="cursor:pointer;color:#37475a" title="한 줄 위로" onclick="puBatchSelMove('+i+',-1)">▲</span>'
      +   '<span style="cursor:pointer;color:#37475a" title="한 줄 아래로" onclick="puBatchSelMove('+i+',1)">▼</span></td>'
      + '<td>'+esc(o.prodCd)+'</td><td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
      + '<td class="txt">'+ (o.packQty?('['+fmt(o.packQty)+']'):'') + esc(o.spec||'') +'</td>'
      + '<td><input inputmode="numeric" '+inp+' value="'+n(o.boxQty)+'" onchange="puBatchSelSet('+i+',\'boxQty\',this.value)"></td>'
      + '<td><input inputmode="numeric" '+inp+' value="'+n(o.eaQty)+'" onchange="puBatchSelSet('+i+',\'eaQty\',this.value)"></td>'
      + '<td class="num">'+fmt(o.qty)+'</td>'
      + '<td><input inputmode="decimal" '+inp+' value="'+fmtP(o.unitPrice)+'" onchange="puBatchSelSet('+i+',\'unitPrice\',this.value)"></td>'
      + '<td class="num">'+fmt(o.totAmt)+'</td>'
      + '<td><span style="color:#c0392b;cursor:pointer;font-weight:700" title="빼기" onclick="puBatchSelDel('+i+')">✖</span></td></tr>';
  });
  h += '<tr style="background:#137a6c;color:#fff;font-weight:800"><td colspan="9">■ 합계 '+cnt+'건 · 전표 '+Object.keys(perDt).length+'장</td><td class="num">'+fmt(tot)+'</td><td></td></tr>';
  tb.innerHTML = h;
  puBatchInfo();
}
function puBatchSelDel(i){
  _btSel.splice(i,1);
  puBatchRender(); puBatchSelRender();
}
/* ▲▼ 순서 조정 — 같은 일자(전표) 안에서만 옮긴다(일자가 다르면 전표가 달라 의미 없음) */
function puBatchSelMove(i, d){
  var j = i + d;
  if (j < 0 || j >= _btSel.length) return;
  if (_btSel[i].dt !== _btSel[j].dt) return;
  var t = _btSel[i]; _btSel[i] = _btSel[j]; _btSel[j] = t;
  puBatchRender(); puBatchSelRender();
}
/* 담을 내용 비우기 (2026-08-06 요청) — 일자별 삭제는 그 일자 머리줄의 ✖ 에서, [전체삭제]=모두(확인창) */
function puBatchDelDtOf(d){
  _btSel = _btSel.filter(function(s){ return s.dt!==d; });
  puBatchRender(); puBatchSelRender();
}
function puBatchDelAll(){
  if (!_btSel.length) { swAlert('담은 내용이 없습니다.'); return; }
  swConfirm('담을 내용 '+_btSel.length+'건을 모두 비울까요?', null, '전체 초기화').then(function(ok){
    if(!ok) return;
    _btSel = [];
    puBatchRender(); puBatchSelRender();
  });
}
/* '담을 내용' 전체를 명세 행 배열로 */
function puBatchRows(){ return _btSel.map(puBatchRowFor).filter(Boolean); }
/* [일괄저장] — '담을 내용'을 등록일자(dt)별로 묶어 일자마다 전표 한 장씩 바로 저장한다 (2026-08-06 확정).
     · 화면의 명세 그리드는 건드리지 않는다(입력 중이던 내용 보존). [명세에 담기]는 사용자 요청으로 제거.
     · 이미 전표가 있는 일자는 확인창에서 '있다'고 알리고 진행한다(별도 전표로 추가, 막지 않음).
     · 상품코드 탭 줄은 저장 직전 그 거래처 최근 매입단가로 덮는다. 최근 매입내역 줄은 그때 단가 그대로.
     · 저장 후 팝업 유지 — 담을 내용만 비우고 최근 매입내역·'전표 있음' 힌트를 다시 읽어 다음 회차 준비. */
function puBatchApply(){
  var venCd = document.getElementById('puVenNm').dataset.cd || '';
  if (!venCd) { swErr('거래처를 먼저 선택하세요.'); return; }
  var venNm = document.getElementById('puVenNm').value || '';
  var entries = _btSel.map(function(s){ var r = puBatchRowFor(s); return r ? { s:s, row:r } : null; }).filter(Boolean);
  if (!entries.length) { swErr('담을 상품을 체크하세요.'); return; }
  /* 등록일자별 그룹 — 먼저 체크한 일자부터 */
  var dts = [], byDt = {};
  entries.forEach(function(e){
    if (dts.indexOf(e.s.dt) < 0) dts.push(e.s.dt);
    (byDt[e.s.dt] = byDt[e.s.dt] || []).push(e);
  });
  /* [같은 일자 전표에 합치기]는 2026-08-06 사용자 요청으로 제거 — 항상 별도 전표로 추가한다.
     (같은 일괄저장 안의 같은 일자 체크분은 어차피 한 전표로 묶인다) */
  post('/mangr/purchaseList.do','vendorCd='+encodeURIComponent(venCd))
    .then(function(r){ return r.json(); })
    .then(function(j){
      var list = (j&&j.data)||[], tx = '';
      dts.forEach(function(d){
        var d8 = d.replace(/-/g,'');
        var ex = list.filter(function(o){ return String(o.purchDt||'')===d8; });
        if (!ex.length) return;
        var sum = 0; ex.forEach(function(o){ sum += n(o.totAmt); });
        tx += '<br><span style="font-size:13px;color:#c0392b">⚠ '+d+' 에 이미 전표 '+ex.length+'건 ('+fmt(sum)+'원) — 별도 전표로 추가됩니다.</span>';
      });
      return tx;
    })
    .catch(function(){ return ''; })
    .then(function(exMsg){
      var brk = dts.map(function(d){ return d+' '+byDt[d].length+'건'; }).join(' · ');
      var msg = '총 '+entries.length+'건을 <b>일자별 전표 '+dts.length+'장</b>으로 바로 저장할까요?'
        + '<br><span style="font-size:13px;color:#3d4d5c">'+esc(brk)+'</span>' + exMsg;
      return swConfirm(msg, null, '일괄저장');
    })
    .then(function(ok){
      if(!ok) return;
      /* ① 상품코드 탭 줄 최근단가 덮기 → ② 일자 순서대로 nextNo 받아 전표 저장 */
      var jobs = [];
      entries.forEach(function(e){
        if (e.s.t !== 1) return;
        if (e.s.unitPrice != null) return;   /* 미리보기에서 단가를 직접 고친 줄은 그 값 그대로(최근단가로 안 덮음) */
        jobs.push(post('/mangr/purchaseLastPrice.do','prodCd='+encodeURIComponent(e.row.prodCd)+'&remark='+encodeURIComponent(venCd))
          .then(function(r){return r.json();}).then(function(j){ if(j&&j.data){ e.row.unitPrice=n(j.data); puCalcRow(e.row); } })
          .catch(function(){}));
      });
      var made = [];                       /* 저장된 전표 [일자 · 번호] — 완료 알림에 보여 준다 */
      function saveOne(k){
        if (k >= dts.length) return Promise.resolve();
        var d = dts[k], grp = byDt[d].map(function(e){ return e.row; });
        return post('/mangr/purchaseNextNo.do','purchDt='+encodeURIComponent(d))
          .then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||'0001'; })
          .catch(function(){ return '0001'; })
          .then(function(no){
            var t = {box:0, ea:0, qty:0, sup:0, vat:0, tot:0, svc:0};
            grp.forEach(function(o){
              var sg = (o.trxGb==='반품') ? -1 : 1;
              t.box+=n(o.boxQty)*sg; t.ea+=n(o.eaQty)*sg; t.qty+=n(o.qty)*sg;
              t.sup+=n(o.supplyAmt)*sg; t.vat+=n(o.vatAmt)*sg; t.tot+=n(o.totAmt)*sg; t.svc+=n(o.serviceQty);
            });
            var dto = {
              purchSeq:null, purchDt:d, purchNo:no,
              vendorCd:venCd, vendorNm:venNm,
              mgrCd: document.getElementById('puMgrNm').dataset.cd||'', mgrNm: document.getElementById('puMgrNm').value||'',
              whCd:'', whNm: document.getElementById('puWhNm').value||'물류창고',
              totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty,
              supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:0,
              payGb: document.getElementById('puPayGb').value||'외상', payAmt:0,
              remark:'', items: grp
            };
            return post('/mangr/purchaseSave.do', dto, true)
              .then(function(r){ return r.text().then(function(t2){ if(!r.ok) throw new Error(d+' — '+t2); made.push(d+' · 전표 '+no+' ('+grp.length+'건)'); }); });
          })
          .then(function(){ return saveOne(k+1); });
      }
      Promise.all(jobs).then(function(){ return saveOne(0); }).then(function(){
        swOk('일자별 전표 '+dts.length+'장, 총 '+entries.length+'건을 저장했습니다.'
          + '<br><span style="font-size:12.5px;color:#3d4d5c">'+made.join('<br>')+'</span>');
        _btSel = []; _btDays = null;
        if (_btTab === 2) puBatchLoad2(); else puBatchRender();
        puBatchSelRender(); puBatchDtHint();
        puLoad(); puVenBal(venCd);            /* 하단 목록·현잔고·원장 갱신 — 명세 그리드는 건드리지 않는다 */
      }).catch(function(e){
        swErr('저장 중 오류가 났습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)
          + '<br>이미 저장된 일자 전표는 하단 목록에서 확인하세요.</span>');
        puLoad();
      });
    });
}

/* 거래처 상품 매입 단가 이력 — 품명을 클릭하면 뜬다.
     상단(거래처·상품·바코드·단가)은 이미 받아둔 상품마스터에서 채우고,
     아래 이력만 서버에서 읽는다(그 거래처 × 그 상품, 최대 3년). */
var _hist = [];
function puHistOpen(i){
  var o=_rows[i]; if(!o||!o.prodCd) return;
  var ven = document.getElementById('puVenNm').dataset.cd||'';
  var p = _prods.filter(function(x){ return String(x.prodCd)===String(o.prodCd); })[0] || {};
  document.getElementById('hvVen').textContent   = document.getElementById('puVenNm').value || '(전체 거래처)';
  document.getElementById('hvNm').textContent    = o.prodNm || p.prodNm || '';
  document.getElementById('hvBc').textContent    = p.unitBarcode || '—';
  document.getElementById('hvBox').textContent   = p.boxBarcode || '—';
  document.getElementById('hvIn').textContent    = fmt(p.inPrice);
  document.getElementById('hvSale').textContent  = fmt(p.salePrice);
  document.getElementById('hvWhole').textContent = fmt(p.wholePrice);
  document.getElementById('hvEvtOnly').checked   = false;
  _hist = [];
  document.getElementById('puHistBody').innerHTML = '<tr><td colspan="10" class="pu-msg">불러오는 중…</td></tr>';
  document.getElementById('puHistPop').classList.add('on');
  post('/mangr/purchasePriceHist.do','prodCd='+encodeURIComponent(o.prodCd)+'&remark='+encodeURIComponent(ven))
    .then(function(r){return r.json();}).then(function(j){ _hist=(j&&j.data)||[]; puHistRender(); })
    .catch(function(){ document.getElementById('puHistBody').innerHTML='<tr><td colspan="10" class="pu-msg">조회 오류</td></tr>'; });
}
function puHistRender(){
  var only = document.getElementById('hvEvtOnly').checked;
  var l = only ? _hist.filter(function(x){ return x.eventYn==='Y'; }) : _hist;
  document.getElementById('hvCnt').textContent = '[ 조회 건 수: '+l.length+'/'+_hist.length+' ]';
  document.getElementById('puHistBody').innerHTML = l.length ? l.map(function(x,k){
    return '<tr><td>'+(k+1)+'</td><td>'+esc(fmtDt(x.spec))+'</td><td class="txt" style="text-align:left">'+esc(x.prodNm)+'</td>'
         + '<td class="num">'+fmtP(x.unitPrice)+'</td><td class="num">'+n(x.boxQty)+'</td><td class="num">'+n(x.eaQty)+'</td>'
         + '<td class="num">'+n(x.qty)+'</td><td class="num">'+fmt(x.amt)+'</td>'
         + '<td>'+(x.eventYn==='Y'?'●':'')+'</td><td>'+(x.trxGb==='반품'?'●':'')+'</td></tr>';
  }).join('') : '<tr><td colspan="10" class="pu-msg">'+(only?'행사 매입 이력이 없습니다.':'이 상품의 매입 이력이 아직 없습니다.')+'</td></tr>';
}
function puHistClose(){ document.getElementById('puHistPop').classList.remove('on'); }

/* ── 매입분 (2026-07-31) ────────────────────────────────
     [매입분] = 그 매입처에서 이미 사 온 품목을 중복 없이 모은 목록.
       원천 ① 매입전표 명세  ② 매입단가이력(상품관리에서 매입처별 단가를 등록해 둔 품목)
     상품마스터 전체에서 찾지 않고 '이 매입처에서 늘 사는 것' 중에서 고른다.

     ★ 핵심은 '순서' — 발주한 순서대로 체크하면 그 순서 그대로 명세에 담긴다.
       체크 순서를 _dvPick 에 쌓고 체크 칸에 1,2,3… 을 찍어 눈으로 확인한다.
     ★ [매입분제외] 는 판매등록의 [납품분제외]와 같은 표를 쓰되 GB='P' 로 갈린다.
       매출에서 뺀 품목이 매입에서 사라지는 사고가 없다. */
var _dlv = [], _dvPick = [], _dvExclMode = false;

function puDlvOpen(){
  var cd = document.getElementById('puVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _dvPick = []; _dvExclMode = false;
  document.getElementById('dvQ').value = '';
  document.getElementById('dvAll').checked = false;
  document.getElementById('puDlvPop').classList.add('on');
  puDlvLoad();
}
function puDlvClose(){ document.getElementById('puDlvPop').classList.remove('on'); }
function puDlvToggleExcl(){ _dvExclMode = !_dvExclMode; _dvPick = []; puDlvLoad(); }
function puDlvLoad(){
  var cd = document.getElementById('puVenNm').dataset.cd || '';
  if (!cd) return;
  var yrs = document.getElementById('dvPeriod').value;
  var from = '';
  if (yrs) { var d = new Date(); d.setFullYear(d.getFullYear() - Number(yrs)); from = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
  var url = _dvExclMode ? '/mangr/salesDlvExclList.do' : '/mangr/purchDlvList.do';
  var body = 'custCd='+encodeURIComponent(cd) + '&gb=P'
           + '&fromDt='+encodeURIComponent(_dvExclMode ? '' : from)
           + '&srcFilter='+encodeURIComponent(_dvExclMode ? '' : document.getElementById('dvSrc').value);
  document.getElementById('dvBody').innerHTML = '<tr><td colspan="9" class="pu-msg">불러오는 중…</td></tr>';
  document.getElementById('dvExclBtn').textContent = _dvExclMode ? '↩ 매입분으로' : '📋 제외이력보기';
  document.getElementById('dvExclSave').textContent = _dvExclMode ? '↩ 제외해제' : '🚫 매입분제외';
  document.getElementById('dvOk').style.display = _dvExclMode ? 'none' : '';
  document.getElementById('dvPeriod').disabled = _dvExclMode;
  document.getElementById('dvSrc').disabled = _dvExclMode;
  post(url, body).then(function(r){return r.json();}).then(function(j){
    _dlv = (j&&j.data)||[]; puDlvRender();
  }).catch(function(e){
    document.getElementById('dvBody').innerHTML =
      '<tr><td colspan="9" class="pu-msg" style="color:#c0392b">조회 오류 — 제외표(TBL_SALES_DLV_EXCL)가 없거나 GB 칸이 없으면 sql/sales_dlv_excl_ddl.sql · sales_dlv_excl_gb_alter.sql 을 먼저 실행하세요.</td></tr>';
  });
}
function puDlvFiltered(){
  var q = (document.getElementById('dvQ').value||'').toLowerCase();
  return _dlv.filter(function(o){
    if(!q) return true;
    return [o.prodCd,o.prodNm,o.spec,o.makerNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  });
}
function puDlvRender(){
  var l = puDlvFiltered();
  document.getElementById('dvCnt').textContent = l.length + '건'
    + (l.length !== _dlv.length ? ' (전체 '+_dlv.length+'건 중)' : '');
  document.getElementById('dvBody').innerHTML = l.length ? l.map(function(o){
    var cd = String(o.prodCd||'');
    var k  = _dvPick.indexOf(cd);
    var st = n(o.curQty);
    return '<tr class="pick" onclick="puDlvPick(\''+esc(cd)+'\')">'
      + '<td>' + (k>=0
          ? '<b style="color:#137a6c">'+(k+1)+'</b>'
          : '<input type="checkbox" onclick="event.stopPropagation();puDlvPick(\''+esc(cd)+'\')">') + '</td>'
      + '<td>'+esc(cd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
      + '<td>'+esc(o.spec)+'</td><td>'+esc(o.makerNm)+'</td>'
      + '<td class="num">'+fmtP(o.unitPrice)+'</td>'
      + '<td class="num"'+(st<0?' style="color:#c0392b;font-weight:700"':'')+'>'+fmt(st)+'</td>'
      + '<td>'+esc(_dvExclMode ? String(o.regDttm||'').slice(0,10) : fmtDt(o.lastDt))+'</td>'
      + '<td>'+esc(_dvExclMode ? '제외' : (o.srcGb||''))+'</td></tr>';
  }).join('') : '<tr><td colspan="9" class="pu-msg">'
      + (_dvExclMode ? '제외해 둔 품목이 없습니다.' : '이 매입처에서 사 온 품목이 아직 없습니다.') + '</td></tr>';
  puDlvInfo();
}
function puDlvPick(cd){
  var k = _dvPick.indexOf(cd);
  if (k >= 0) _dvPick.splice(k,1); else _dvPick.push(cd);   // 뺀 자리는 뒤 번호가 당겨진다
  puDlvRender();
}
function puDlvAll(on){
  _dvPick = on ? puDlvFiltered().map(function(o){ return String(o.prodCd||''); }) : [];
  puDlvRender();
}
function puDlvInfo(){
  var el = document.getElementById('dvPickInfo');
  el.textContent = _dvPick.length ? ('선택 '+_dvPick.length+'건 — '+_dvPick.join(' → ')) : '';
}
/* [확인] — 체크한 순서대로 명세에 담는다 */
function puDlvApply(){
  if (!_dvPick.length) { swErr('담을 품목을 체크하세요.'); return; }
  var rows = _rows.filter(function(o){ return o.prodCd; });
  var added = 0, dup = [];
  _dvPick.forEach(function(cd){
    var s = _dlv.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!s) return;
    if (rows.some(function(o){ return String(o.prodCd)===String(cd); })) { dup.push(cd); return; }
    var o = emptyRow();
    o.prodSeq  = s.prodSeq;  o.prodCd = s.prodCd; o.prodNm = s.prodNm; o.spec = s.spec||'';
    o.packQty  = n(s.packQty)||1;
    o.taxGb    = s.taxGb || '과세';
    o.unitPrice= n(s.unitPrice);      // 그 매입처의 최근 매입단가
    puCalcRow(o);
    rows.push(o); added++;
  });
  rows.push(emptyRow());
  _rows = rows; _pShown = _rows.length;
  puRender();
  puDlvClose();
  if (dup.length) swAlert(added+'건을 담았습니다.<br><span style="font-size:12.5px;color:#3d4d5c">이미 명세에 있는 '+dup.length+'건은 건너뛰었습니다 — '+esc(dup.join(', '))+'</span>');
}
/* [매입분제외] / [제외해제] — 체크한 품목을 거래처별로 넣거나 뺀다(GB='P') */
function puDlvExclSave(){
  var cd = document.getElementById('puVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  if (!_dvPick.length) { swErr('품목을 체크하세요.'); return; }
  var on = !_dvExclMode;
  var msg = on
    ? '체크한 '+_dvPick.length+'건을 <b>매입분에서 제외</b>할까요?<br><span style="font-size:13px;color:#3d4d5c">'
      + document.getElementById('puVenNm').value + ' 거래처의 매입분 목록에만 안 나옵니다. 지난 매입 자료는 그대로입니다.</span>'
    : '체크한 '+_dvPick.length+'건의 <b>제외를 해제</b>할까요?<br><span style="font-size:13px;color:#3d4d5c">다시 매입분 목록에 나옵니다.</span>';
  swConfirm(msg, null, on?'제외':'해제').then(function(ok){
    if(!ok) return;
    var one = (_dvPick.length===1) ? (_dlv.filter(function(x){ return String(x.prodCd)===String(_dvPick[0]); })[0]||{}) : {};
    var body = 'custCd='+encodeURIComponent(cd) + '&gb=P'
             + '&actionYn='+(on?'Y':'N')
             + '&prodNm='+encodeURIComponent(one.prodNm||'')
             + '&prodCds='+encodeURIComponent(_dvPick.join(','));
    post('/mangr/salesDlvExclSave.do', body).then(function(r){
      return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; });
    }).then(function(){
      _dvPick = [];
      document.getElementById('dvAll').checked = false;
      puDlvLoad();
      swOk(on ? '매입분에서 제외했습니다.' : '제외를 해제했습니다.');
    }).catch(function(e){ swErr('처리에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
  });
}

/* ── 원장 일자 클릭 → 그 날 매입품목 (2026-07-31) ────────
     원장 금액과 같은 원천(selectCustDayDetail)에서 그 날 매입전표(PURCH) 줄만 골라 보여준다.
     [불러오기] 는 그 품목들을 '새 전표'로 올린다 — 그 날 전표를 여는 게 아니다. */
var _day = [], _dayDt = '';
function puDayOpen(dt){
  var cd = _lgCd || document.getElementById('puVenNm').dataset.cd || '';
  if (!dt) return;
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _dayDt = dt; _day = [];
  var nm = (_lgCd && _lgCd === (document.getElementById('puVenNm').dataset.cd||''))
             ? document.getElementById('puVenNm').value
             : (document.getElementById('lgVen').textContent||cd);
  document.getElementById('dyTitle').textContent = fmtDt(dt) + ' · ' + (nm||cd);
  document.getElementById('dyBody').innerHTML = '<tr><td colspan="7" class="pu-msg">불러오는 중…</td></tr>';
  document.getElementById('dySum').textContent = '0';
  document.getElementById('puDayPop').classList.add('on');
  post('/mangr/selectCustDayDetail.do','custCd='+encodeURIComponent(cd)+'&trxDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){
      _day = ((j&&j.data)||[]).filter(function(o){ return o.gb==='PURCH'; });
      puDayRender();
    }).catch(function(e){
      document.getElementById('dyBody').innerHTML = '<tr><td colspan="7" class="pu-msg" style="color:#c0392b">조회 오류</td></tr>';
    });
}
function puDayClose(){ document.getElementById('puDayPop').classList.remove('on'); }
function puDayRender(){
  var sum = 0;
  document.getElementById('dyBody').innerHTML = _day.length ? _day.map(function(o){
    sum += n(o.amt);
    return '<tr><td>'+esc(o.gbNm)+'</td><td>'+esc(o.docNo)+'</td><td>'+esc(o.itemCd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.itemNm)+'</td>'
      + '<td class="num">'+fmt(o.qty)+'</td><td class="num">'+fmt(o.price)+'</td><td class="num">'+fmt(o.amt)+'</td></tr>';
  }).join('') : '<tr><td colspan="7" class="pu-msg">이 날 매입품목이 없습니다.</td></tr>';
  document.getElementById('dySum').textContent = fmt(sum);
}
function puDayApply(){
  if (!_day.length) { swErr('불러올 품목이 없습니다.'); return; }
  swConfirm(fmtDt(_dayDt)+' 매입품목 '+_day.length+'건을 <b>새 전표</b>로 올릴까요?'
    + '<br><span style="font-size:13px;color:#c0392b">이 날 이미 저장된 매입전표입니다. 그대로 저장하면 매입이 한 번 더 잡힙니다.</span>'
    + '<br><span style="font-size:13px;color:#3d4d5c">지금 입력 중인 명세는 지워집니다.</span>', null, '불러오기')
  .then(function(ok){
    if(!ok) return;
    /* 거래처는 원장 기준(_lgCd). 상단이 비어 있거나 다른 거래처면 거래처마스터에서 채운다 */
    var cur = document.getElementById('puVenNm').dataset.cd||'';
    var ven;
    if (_lgCd && _lgCd !== cur) {
      var v0 = _vendors.filter(function(x){ return String(x.vendorCd)===String(_lgCd); })[0] || {};
      ven = { cd:_lgCd, nm: v0.vendorNm || document.getElementById('lgVen').textContent || _lgCd,
              mgrCd: v0.mgrCd||'', mgrNm: v0.mgrNm||'' };
    } else {
      ven = { cd: cur, nm: document.getElementById('puVenNm').value||'',
              mgrCd: document.getElementById('puMgrNm').dataset.cd||'', mgrNm: document.getElementById('puMgrNm').value||'' };
    }
    puNew();
    var v = document.getElementById('puVenNm'); v.value = ven.nm; v.dataset.cd = ven.cd;
    var m = document.getElementById('puMgrNm'); m.value = ven.mgrNm; m.dataset.cd = ven.mgrCd;
    document.getElementById('puDt').value = fmtDt(_dayDt);
    var rows = [];
    _day.forEach(function(o){
      var p = _prods.filter(function(x){ return String(x.prodCd)===String(o.itemCd); })[0] || {};
      var r = emptyRow();
      r.prodSeq = p.prodSeq; r.prodCd = o.itemCd; r.prodNm = o.itemNm || p.prodNm || '';
      r.spec = p.spec || ''; r.packQty = n(p.packQty)||1; r.taxGb = p.taxGb || '과세';
      r.unitPrice = n(o.price);
      /* 수량은 총수량으로 온다 — 입수가 있으면 박스/낱개로 쪼갠다 */
      var q = n(o.qty), pk = n(r.packQty)||1;
      if (pk > 1) { r.boxQty = Math.floor(Math.abs(q)/pk) * (q<0?-1:1); r.eaQty = q - r.boxQty*pk; }
      else { r.boxQty = 0; r.eaQty = q; }
      if (q < 0) { r.trxGb = '반품'; r.boxQty = Math.abs(r.boxQty); r.eaQty = Math.abs(r.eaQty); }
      puCalcRow(r);
      rows.push(r);
    });
    rows.push(emptyRow());
    _rows = rows; _pShown = _rows.length;
    document.getElementById('puState').textContent = '원장에서 불러옴 — '+fmtDt(_dayDt)+' · 내용 확인 후 [저장]';
    puRender(); puNextNo(); puVenBal(ven.cd);
    puDayClose();
  });
}

/* ══════════════════════════════════════════════════════════════════════
   명세 그리드 키보드 입력 (2026-08-04) — 판매등록과 같은 방식을 이식.
     ① 빈 줄 '상품코드' 칸에 직접 쳐서 ↑↓·Enter 로 상품을 고른다(puPin*) — 팝업을 안 열어도 된다.
     ② 칸에서 Enter = 다음 칸, 줄 끝이면 다음 줄로. ↑↓ = 같은 칸으로 윗줄/아랫줄.
     ③ 진입하면 첫 상품칸에 커서. Ctrl+S = 저장, Alt+N = 신규.
   ★판매와 다른 점 두 가지:
     · 매입 합계수량 = BOX×입수 + EA 라, 상품을 담으면 커서를 'BOX수량' 으로 보낸다(판매는 EA수량).
       Enter 경로도 상품 → BOX수량 → 단가 → 다음 줄.
     · 매입은 우리 코드 기준이라 '거래처 매칭코드' 검색이 없다 — 상품마스터(_prods)만 훑는다.
   ★그리드는 값이 바뀔 때마다 통째로 다시 그리므로(puRender) 커서가 튀지 않게 위치를 잡아 두었다 되돌린다.
   기존 동작(최근 매입단가 자동채움·부가세·반품·매입분·복사저장)은 그대로다. */
var _focusNext = null;                     // 다음에 커서를 둘 칸 {r,f,sel} — puRender 가 소비하고 비운다

function puCaptureFocus(){
  var a = document.activeElement;
  if (!a || !a.dataset || a.dataset.r == null) return null;
  if (!a.closest || !a.closest('#puBody')) return null;
  var s = null, e = null;
  try { s = a.selectionStart; e = a.selectionEnd; } catch(_){}
  return { r:a.dataset.r, f:a.dataset.f, s:s, e:e };
}
function puRestoreFocus(keep){
  var t = _focusNext; _focusNext = null;
  if (t) { puFocusCell(t); return; }
  if (keep) puFocusCell(keep);
}
function puFocusCell(t){
  if (!t) return false;
  var el = document.querySelector('#puBody [data-r="'+t.r+'"][data-f="'+t.f+'"]');
  if (!el && t.f === 'prod') el = document.querySelector('#puBody [data-r="'+t.r+'"][data-f="boxQty"]');
  if (!el) return false;
  try {
    el.focus();
    if (t.sel === 'all' || t.s == null) { if (el.select) el.select(); }
    else el.setSelectionRange(t.s, t.e);
  } catch(_){}
  return true;
}
function puFocusFirstProd(){
  setTimeout(function(){
    var el = document.querySelector('#puBody input.puPin[data-f="prod"]');
    if (el) el.focus();
  }, 0);
}

/* 칸 사이 이동 — Enter 는 '상품 → BOX수량 → 단가 → (다음 줄)'. 그 밖의 칸은 다음 줄로 넘어간다. */
function puNextEnter(r, f){
  if (f === 'prod') return { r:r, f:'boxQty' };
  if (f === 'boxQty' || f === 'eaQty') return { r:r, f:'unitPrice' };
  var nr = r + 1;
  if (_rows[nr] && _rows[nr].prodCd) return { r:nr, f:'boxQty' };
  return { r:nr, f:'prod' };
}
function puGridKey(e){
  var t = e.target;
  if (!t || !t.dataset || t.dataset.r == null) return;
  if (t.classList && t.classList.contains('puPin')) return;   // 상품 입력칸은 자체 처리
  var r = +t.dataset.r, f = t.dataset.f;
  if (e.key === 'Enter') {
    e.preventDefault();
    var nx = puNextEnter(r, f);
    _focusNext = nx ? { r:nx.r, f:nx.f, sel:'all' } : null;
    t.blur();                              // 값 확정(onchange→puSet→puRender→_focusNext 로 이동)
    if (_focusNext) {                      // 값이 안 바뀌어 재렌더가 없었던 경우
      if (!puFocusCell(_focusNext)) {      // 갈 줄이 아직 없으면 꼬리 빈 줄을 만들어 그린다
        puTail(); if (_pShown < _rows.length) _pShown = _rows.length; puRender();
      } else { _focusNext = null; }
    }
  } else if (e.key === 'ArrowDown') { e.preventDefault(); puStepRow(t, 1); }
  else if (e.key === 'ArrowUp')     { e.preventDefault(); puStepRow(t, -1); }
}
function puStepRow(t, dr){
  var r = +t.dataset.r, f = t.dataset.f, nr = r + dr;
  if (nr < 0 || nr >= _rows.length) return;
  _focusNext = { r:nr, f:f, sel:'all' };
  t.blur();
  if (_focusNext) { puFocusCell(_focusNext); _focusNext = null; }
}

/* 상품코드 칸 입력검색 — 이미 들고 있는 상품마스터(_prods)만 훑어 서버를 부르지 않는다.
     · 우리 코드/품명/규격으로 찾는다(매입은 매칭코드가 없다).
     · 고르면 그 행에 담기고(puProdPick 재사용) 커서가 BOX수량으로 넘어간다.
   드롭다운은 그리드가 overflow 라 잘리므로 body 에 position:fixed 로 띄운다. */
var _pinInp = null, _pinRow = -1, _pinList = [], _pinIdx = -1, _pinDrop = null;
function _pinHit(q){ return function(x){ return String(x==null?'':x).toLowerCase().indexOf(q) >= 0; }; }
function puPinCands(q){
  var out = [];
  for (var i=0; i<_prods.length && out.length<12; i++){
    var p = _prods[i]; if (!p.prodCd) continue;
    if (![p.prodCd,p.prodNm,p.spec].some(_pinHit(q))) continue;
    out.push({ code:p.prodCd, nm:p.prodNm, spec:p.spec, price:p.inPrice, prodCd:p.prodCd });   // 매입가 표시
  }
  return out;
}
function puPinInput(inp){
  _pinInp = inp; _pinRow = +inp.dataset.r;
  var q = String(inp.value||'').trim().toLowerCase();
  if (!q) { puPinClose(); return; }
  _pinList = puPinCands(q); _pinIdx = _pinList.length ? 0 : -1;
  puPinDraw(inp);
}
function puPinDraw(inp){
  if (!_pinDrop) {
    _pinDrop = document.createElement('div');
    _pinDrop.id = 'puPinDrop';
    _pinDrop.style.cssText = 'position:fixed;z-index:400;background:#fff;border:1px solid #cfd8e3;border-radius:8px;box-shadow:0 10px 30px rgba(0,0,0,.18);font-size:12.5px;max-height:260px;overflow:auto';
    document.body.appendChild(_pinDrop);
  }
  if (!_pinList.length) { puPinClose(); return; }
  var rc = inp.getBoundingClientRect();
  _pinDrop.style.left = rc.left + 'px';
  _pinDrop.style.top = (rc.bottom + 2) + 'px';
  _pinDrop.style.minWidth = Math.max(380, rc.width) + 'px';
  _pinDrop.innerHTML = _pinList.map(function(it,k){
    var on = (k === _pinIdx);
    return '<div data-k="'+k+'" onmousedown="puPinPickMd(event,'+k+')"'
      + ' style="display:flex;gap:8px;padding:6px 10px;cursor:pointer;white-space:nowrap;'+(on?'background:#e9f4f1;':'')+'">'
      + '<b style="min-width:100px;color:#137a6c">'+esc(it.code)+'</b>'
      + '<span style="flex:1;text-align:left;color:#1f2a37">'+esc(it.nm)+'</span>'
      + '<span style="min-width:96px;color:#8a97a4">'+esc(it.spec||'')+'</span>'
      + '<span style="min-width:66px;text-align:right;color:#37475a">'+(it.price!=null&&it.price!==''?fmt(it.price):'')+'</span>'
      + '</div>';
  }).join('');
  _pinDrop.style.display = 'block';
}
function puPinKey(inp, e){
  if (e.key === 'ArrowDown') { e.preventDefault(); if (_pinList.length){ _pinIdx = Math.min(_pinList.length-1, _pinIdx+1); puPinDraw(inp); } }
  else if (e.key === 'ArrowUp') { e.preventDefault(); if (_pinList.length){ _pinIdx = Math.max(0, _pinIdx-1); puPinDraw(inp); } }
  else if (e.key === 'Enter') {
    e.preventDefault();
    if (_pinList.length && _pinIdx >= 0) puPinPick(_pinIdx);
    else puProdOpen(+inp.dataset.r);       // 후보가 없으면 상품 선택 팝업으로
  }
  else if (e.key === 'Escape') { puPinClose(); }
}
function puPinPickMd(e, k){ e.preventDefault(); puPinPick(k); }
function puPinPick(k){
  var it = _pinList[k]; if (!it) { puPinClose(); return; }
  var row = _pinRow;
  puPinClose();
  _prodTargetRow = row;
  _focusNext = { r:row, f:'boxQty', sel:'all' };   // 담긴 뒤 커서는 BOX수량으로
  puProdPick(it.prodCd);
}
function puPinClose(){ if (_pinDrop) _pinDrop.style.display = 'none'; _pinList = []; _pinIdx = -1; }
function puPinBlur(){ setTimeout(puPinClose, 150); }

(function puKbdBind(){
  var b = document.getElementById('puBody');
  if (b) b.addEventListener('keydown', puGridKey);
  var g = document.getElementById('puGridWrap');
  if (g) g.addEventListener('scroll', puPinClose);
  window.addEventListener('resize', puPinClose);
  document.addEventListener('keydown', function(e){
    if ((e.ctrlKey || e.metaKey) && (e.key === 's' || e.key === 'S')) { e.preventDefault(); puSave(); }
    else if (e.altKey && (e.key === 'n' || e.key === 'N')) { e.preventDefault(); puNew(); }
    /* ESC = 상품 선택 팝업 닫기(2026-08-05 요청) — 한글 조합 중 ESC 는 IME 취소라 건드리지 않는다 */
    else if (e.key === 'Escape' && !e.isComposing){
      var p = document.getElementById('puProdPop');
      if (p && p.classList.contains('on')) { e.preventDefault(); puProdClose(); }
      var b = document.getElementById('puBatchPop');
      if (b && b.classList.contains('on')) { e.preventDefault(); puBatchClose(); }
    }
  });
})();
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
