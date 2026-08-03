<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 메시지는 프로젝트 공통 컴포넌트를 쓴다 — 로그인 화면(base_login.jsp)과 같은 모양.
     SweetAlert 가 아니라 이 파일이 표준이다(_alertBox / _confirmBox / _toast). --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- 거래처 입력검색 — 거래처 칸에 직접 쳐서 고른다(2026-08-01). [거래처] 팝업은 그대로 둔다. --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js"></script>
<!--
  판매등록 (2026-07-25 신설) — 매입등록 화면과 대칭. 같은 조작감으로 쓰도록 구조를 그대로 맞췄다.
    · 상단 = 전표 입력(헤더 + 명세 그리드) / 하단 좌 = 기간 전표 목록 / 하단 우 = 거래처 원장
    · 저장하면 TBL_SALES_TRX_MST/DTL + 파생 TBL_STOCK_LEDGER(출고 'O') 가 함께 쌓인다
    · ★ 정산서(TBL_SALES_MST)와 다른 표다. 그쪽은 출고장이 준 엑셀 적재표라 같은
      (납품일자+출고장)을 재업로드하면 기존 행이 죽는다. 여기는 정산서 밖에서 직접 판 건이다.
    · 원장·현잔고는 수금등록과 같은 쿼리(/mangr/custLedger.do)를 쓴다 — 두 화면 잔고가 어긋나면 안 된다.
    · DDL : sql/sales_trx_ddl.sql
-->
<style>
  :root{ --sa-bd:#dbe2ea; --sa-teal:#137a6c; --sa-bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  /* 글자 크기 한 단계 키움(2026-07-25 요청) — 기준 13 → 14px. 이 14px 이 전 화면 공통 기준이 됐다(2026-08-03) */
  .sa-wrap{ padding:14px 11px 16px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .sa-wrap h2{ margin:0 0 4px; font-size:20px; }
  .sa-sub{ color:#1f2a37; margin-bottom:12px; font-size:12.5px; font-weight:600; }
  .sa-card{ background:#fff; border:1px solid var(--sa-bd); border-radius:10px; padding:12px; margin-bottom:12px; }
  /* 검색·조건줄은 한 줄로 붙인다(2026-07-25 요청). 넘치면 이 줄만 가로 스크롤 */
  .sa-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:nowrap; overflow-x:auto; margin-bottom:8px; }
  .sa-fld{ display:flex; flex-direction:column; gap:3px; }
  .sa-fld label{ font-size:12px; font-weight:700; color:#1f2a37; white-space:nowrap; }
  .sa-fld input, .sa-fld select{ height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .sa-btn{ height:32px; border:1px solid var(--sa-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .sa-btn:hover{ border-color:var(--sa-teal); }
  .sa-btn.teal{ background:var(--sa-teal); color:#fff; border-color:var(--sa-teal); }
  .sa-btn.red{ color:#c0392b; border-color:#e3b4ae; }
  .sa-bal{ margin-left:auto; display:flex; gap:14px; align-items:center; font-size:12.5px; }
  .sa-bal b{ font-size:15px; color:#c0392b; }
  /* 명세 그리드 */
  /* 상단 명세 그리드 — 행수가 늘어도 화면이 안 흔들리게 높이 고정(2026-07-25 요청) */
  .sa-grid{ height:210px; overflow:auto; border:1px solid var(--sa-bd); border-radius:8px 8px 0 0; }
  /* 합계 — 그리드 바로 밑 고정. 가로 스크롤은 JS 가 그리드와 맞춘다 */
  .sa-foot{ overflow:hidden; border:1px solid var(--sa-bd); border-top:0; border-radius:0 0 8px 8px; }
  .sa-foot table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-foot td{ border:1px solid var(--sa-bd); padding:6px 4px; text-align:center; background:#137a6c; color:#fff; font-weight:800; }
  .sa-foot td.num{ text-align:right; }
  .sa-grid table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-grid th{ background:#eef3f2; color:#1f2a37; font-weight:700; border:1px solid var(--sa-bd); padding:7px 6px; position:sticky; top:0; z-index:2; }
  .sa-grid td{ border:1px solid var(--sa-bd); padding:2px 4px; text-align:center; }
  .sa-grid td.num{ text-align:right; }
  .sa-grid td.txt{ text-align:left; }
  .sa-grid input{ width:100%; border:0; background:transparent; font-size:13.5px; padding:4px 2px; text-align:right; }
  .sa-grid input:focus{ outline:2px solid #bfe3dc; border-radius:3px; }
  .sa-grid input.txt{ text-align:left; }
  .sa-grid tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
  .sa-grid .lnk{ color:#137a6c; text-decoration:underline; cursor:pointer; }
  .sa-grid .del{ color:#c0392b; cursor:pointer; font-weight:700; }
  /* 행 조작(삽입·위·아래) — 주문 받은 순서 그대로 입력하기 위한 열(2026-07-31) */
  .sa-grid td.ops{ white-space:nowrap; padding:2px 1px; }
  .sa-grid td.ops span{ display:inline-block; width:20px; height:20px; line-height:19px; margin:0 1px;
                        border:1px solid var(--sa-bd); border-radius:4px; cursor:pointer; font-size:11px; color:#37475a; background:#fff; }
  .sa-grid td.ops span:hover{ border-color:var(--sa-teal); color:var(--sa-teal); }
  .sa-grid .hist{ cursor:pointer; font-size:13px; }
  .sa-grid .hist:hover{ filter:brightness(1.3); }
  /* 하단 목록 */
  /* 하단 목록 — 5행 고정 + 자동 스크롤(매출내역과 같은 방식) */
  .sa-list{ max-height:196px; overflow:auto; border:1px solid var(--sa-bd); border-radius:8px; }
  .sa-list table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-list th{ background:#eef3f2; border:1px solid var(--sa-bd); padding:7px 8px; position:sticky; top:0; z-index:2; }
  .sa-list td{ border:1px solid var(--sa-bd); padding:6px 8px; text-align:center; }
  .sa-list td.num{ text-align:right; }
  .sa-list tr{ cursor:pointer; }
  .sa-list tr:hover td{ background:#f3f8f6; }
  .sa-list tr.on td{ background:#fdeef0; font-weight:700; }
  .sa-sum{ display:flex; gap:0; border:1px solid var(--sa-bd); border-top:0; border-radius:0 0 8px 8px; overflow:hidden; }
  .sa-sum div{ flex:1; padding:8px 10px; font-size:13.5px; }
  .sa-sum div.k{ background:#eef3f2; font-weight:700; flex:0 0 90px; text-align:center; }
  .sa-sum div.v{ text-align:right; font-weight:700; }
  /* 팝업 */
  .sa-pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:200; }
  .sa-pop.on{ display:block; }
  .sa-pop .box{ background:#fff; width:min(760px,94vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.3); }
  .sa-pop .hd{ padding:12px 16px; border-bottom:1px solid var(--sa-bd); font-weight:800; display:flex; align-items:center; gap:8px; }
  .sa-pop .bd{ padding:12px 16px; overflow:auto; }
  .sa-pop .ft{ padding:10px 16px; border-top:1px solid var(--sa-bd); text-align:right; }
  .sa-pop table{ width:100%; border-collapse:collapse; font-size:12.5px; }
  .sa-pop th{ background:#eef3f2; border:1px solid var(--sa-bd); padding:6px 8px; }
  .sa-pop td{ border:1px solid var(--sa-bd); padding:6px 8px; text-align:center; }
  .sa-pop td.num{ text-align:right; }
  .sa-pop tr.pick{ cursor:pointer; }
  .sa-pop tr.pick:hover td{ background:#f3f8f6; }
  /* 매칭코드 줄 — 원코드 줄과 '같은 칸'에 맞춰 그리되(코드는 코드 칸, 품명은 품명 칸),
     그 상품에 딸린 줄임을 알 수 있게 파란 계열 + 왼쪽 띠만 다르게 둔다 */
  .sa-pop tr.sa-exrow td{ color:#274b8f; background:#f7faff; }
  .sa-pop tr.sa-exrow td:first-child{ box-shadow:inset 3px 0 0 #c9d9f5; }
  .sa-pop tr.sa-exrow:hover td{ background:#eef4ff; }
  .sa-msg{ padding:10px; color:#5a6b7a; text-align:center; font-size:12.5px; }
  /* 원장 합계 — 스크롤 영역 밖에 고정 */
  .sa-lgfoot{ overflow:hidden; border:1px solid var(--sa-bd); border-top:0; border-radius:0 0 8px 8px; }
  .sa-lgfoot table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .sa-lgfoot td{ border:1px solid var(--sa-bd); padding:7px 8px; text-align:right; background:#d9f0e0; font-weight:800; }
  .sa-lgfoot td:first-child{ text-align:center; }
</style>

<div class="sa-wrap">
  <%-- 제목줄 = 제목 + (우측) 정산 엑셀 올리기. 정산 엑셀 버튼은 매출내역 화면에서 이 자리로 옮겨왔다(2026-08-01 요청)
       — 매출을 넣는 화면에서 정산서도 같이 올리도록. 실제 파일 선택·확인·저장은 부모(물류관리 셸)의 기존 흐름 그대로다. --%>
  <div style="display:flex; align-items:flex-start; gap:12px">
    <div style="flex:1 1 auto; min-width:0">
      <h2>🧾 판매등록</h2>
      <div class="sa-sub">정산서 밖에서 <b>직접 판 건</b>을 입력합니다. 저장 시 <b>재고가 출고</b>로 빠지고 거래처 원장의 매출·미수에 잡힙니다.</div>
    </div>
    <%-- 설명은 버튼 '앞(왼쪽)' — 버튼 아래에 두면 아래 입력카드와 붙어 읽기 나빴다(2026-08-01 요청) --%>
    <div style="flex:0 0 auto; display:flex; align-items:center; gap:10px">
      <span style="font-size:11.5px; color:#5a6b7a; line-height:1.5; text-align:right">
        출고장이 보내준 <b>정산서(받을 금액)</b> 엑셀을 가져옵니다.<br>
        가져온 내용은 <b>매출내역</b> 화면에서 출고와 대사됩니다.
      </span>
      <button class="sa-btn teal" onclick="saSlsExcel()"
              title="출고장이 준 정산 엑셀을 고릅니다(여러 개 가능).&#10;고르면 확인·저장 창이 열립니다.&#10;출고장은 파일명에서 인식합니다 — 2026.07.11_평택.xlsx → 평택">📥 정산서 가져오기</button>
    </div>
  </div>

  <!-- ========== 전표 입력 ========== -->
  <div class="sa-card">
    <div class="sa-row">
      <div class="sa-fld" style="flex:0 0 140px"><label>판매일자</label><input type="date" id="saDt" onchange="saNextNo()"></div>
      <div class="sa-fld" style="flex:0 0 90px"><label>전표번호</label><input type="text" id="saNo" readonly style="background:#f5f7f9"></div>
      <%-- 거래처 = 직접 입력검색(거래처명·코드·별칭·대표·담당 부분일치). 목록을 훑어보려면 [거래처] 버튼. --%>
      <div class="sa-fld" style="flex:0 0 220px"><label>거래처</label><input type="text" id="saVenNm" placeholder="거래처명 입력 또는 [거래처]" title="거래처명·코드·별칭·대표자·담당자로 검색합니다. ↑↓ 로 고르고 Enter."></div>
      <button class="sa-btn teal" onclick="saVenOpen()">거래처</button>
      <%-- 납품분 = 그 거래처에 이미 나간 품목(판매전표+정산서)을 중복 없이 모아 보여준다.
           체크한 순서 그대로 명세에 담긴다 — 주문 받은 순서대로 입력하기 위한 장치(2026-07-31). --%>
      <button class="sa-btn teal" onclick="saDlvOpen()" title="이 거래처가 받아 온 품목 목록에서 골라 담기">납품분</button>
      <div class="sa-fld" style="flex:0 0 120px"><label>담당자</label><input type="text" id="saMgrNm" readonly style="background:#f5f7f9"></div>
      <div class="sa-fld" style="flex:0 0 130px"><label>창고</label><input type="text" id="saWhNm" value="물류창고"></div>
      <%-- 납품일자 = 원장에 잡히는 날. 비우면 판매일자를 그대로 쓴다.
           정산서(TBL_SALES_MST)가 DLV_DT 로 귀속되는 것과 같은 규칙이라 두 매출이 같은 기준에 선다. --%>
      <div class="sa-fld" style="flex:0 0 140px"><label>납품일자(비우면 판매일)</label><input type="date" id="saDlvDt"></div>
      <div class="sa-bal">
        <span>현잔고(미수) <b id="saBalNow">0</b></span>
        <span>거래후잔고 <b id="saBalAfter">0</b></span>
      </div>
    </div>

    <%-- 합계는 스크롤 영역 밖(그리드 바로 밑)에 둔다 — 안에 두면 행이 적을 때 빈 공간 위에 떠서
         그리드 중간에 걸린 것처럼 보인다(2026-07-25 요청). 두 표의 열 너비는 같은 colgroup 으로 맞추고
         가로 스크롤은 JS 로 동기화한다. --%>
    <div class="sa-grid" id="saGridWrap">
      <table>
        <colgroup><col style="width:82px"><col style="width:110px"><col style="width:230px"><col style="width:110px"><col style="width:70px"><col style="width:70px"><col style="width:80px"><col style="width:85px"><col style="width:95px"><col style="width:70px"><col style="width:95px"><col style="width:85px"><col style="width:100px"><col style="width:60px"><col style="width:110px"><col style="width:50px"><col style="width:80px"></colgroup>
        <thead><tr>
          <th>행(＋삽입/▲▼)</th><th>상품코드</th><th>품명(단가이력조회)</th>
          <th>[입수량]규격</th><th>BOX수량</th><th>EA수량</th>
          <th>합계수량</th><th>단가</th><th>금액</th>
          <th>DC</th><th>공급가</th><th>부가세</th>
          <th>판매금액</th><th>서비스</th><th>비고</th>
          <th>행사</th><th>거래구분</th>
        </tr></thead>
        <tbody id="saBody"></tbody>
      </table>
    </div>
    <div id="saGridPager" style="padding:5px 2px 0; text-align:center; min-height:22px"></div>
    <div class="sa-foot" id="saFootWrap">
      <table>
        <colgroup><col style="width:82px"><col style="width:110px"><col style="width:230px"><col style="width:110px"><col style="width:70px"><col style="width:70px"><col style="width:80px"><col style="width:85px"><col style="width:95px"><col style="width:70px"><col style="width:95px"><col style="width:85px"><col style="width:100px"><col style="width:60px"><col style="width:110px"><col style="width:50px"><col style="width:80px"></colgroup>
        <tbody><tr class="tot">
          <td colspan="4">■ 합계</td>
          <td class="num" id="tBox">0</td><td class="num" id="tEa">0</td><td class="num" id="tQty">0</td>
          <td></td><td class="num" id="tAmt">0</td><td class="num" id="tDc">0</td>
          <td class="num" id="tSup">0</td><td class="num" id="tVat">0</td><td class="num" id="tTot">0</td>
          <td class="num" id="tSvc">0</td><td colspan="3"></td>
        </tr></tbody>
      </table>
    </div>

    <div class="sa-row" style="margin-top:10px">
      <div class="sa-fld" style="flex:1 1 320px"><label>판매메모</label><input type="text" id="saRemark" style="width:100%"></div>
      <div class="sa-fld" style="flex:0 0 110px"><label>수금구분</label>
        <select id="saPayGb"><option>현금</option><option>카드</option><option selected>외상</option><option>계좌이체</option></select>
      </div>
      <div class="sa-fld" style="flex:0 0 120px"><label>수금액</label><input type="text" id="saPayAmt" value="0" style="text-align:right" oninput="saCalc()"></div>
      <button class="sa-btn" onclick="saPayFill()">판매액</button>
      <div class="sa-fld" style="flex:0 0 120px"><label>할인액</label><input type="text" id="saDcAmt" value="0" style="text-align:right" oninput="saCalc()"></div>
      <button class="sa-btn" onclick="saDcFill()">털기</button>
    </div>

    <div class="sa-row" style="margin-top:4px">
      <button class="sa-btn teal" onclick="saNew()">＋ 신규등록</button>
      <button class="sa-btn" onclick="saSave()">💾 저장</button>
      <button class="sa-btn" onclick="saReload()">🔄 새로고침</button>
      <button class="sa-btn red" onclick="saDelete()">✖ 삭제하기</button>
      <span id="saState" style="margin-left:8px; color:#3d4d5c; font-size:12.5px"></span>
    </div>
  </div>

  <!-- ========== 하단 : 좌 전표목록 / 우 거래처 원장 ========== -->
  <div style="display:flex; gap:12px; align-items:flex-start">
  <div class="sa-card" style="flex:1 1 auto; min-width:0">
    <div class="sa-row">
      <span style="font-weight:700">Total : <span id="saTotal">0</span></span>
      <div class="sa-fld" style="flex:0 0 140px"><label>검색기간</label><input type="date" id="saFrom"></div>
      <div class="sa-fld" style="flex:0 0 140px"><label>&nbsp;</label><input type="date" id="saTo"></div>
      <div class="sa-fld" style="flex:0 0 200px"><label>거래처</label><input type="text" id="saFindNm" placeholder="거래처명"></div>
      <button class="sa-btn teal" onclick="saLoad()">리스트조회</button>
    </div>
    <div class="sa-list" id="saListWrap">
      <table>
        <thead><tr>
          <th style="width:70px">복사저장</th><th style="width:110px">판매일시</th><th style="width:70px">번호</th>
          <th>거래처명</th><th style="width:90px">담당사원</th><th style="width:70px">상품수</th>
          <th style="width:120px">금액</th><th style="width:90px">창고</th><th style="width:90px">등록자</th>
        </tr></thead>
        <tbody id="saListBody"><tr><td colspan="9" class="sa-msg">[리스트조회]를 누르세요.</td></tr></tbody>
      </table>
    </div>
    <div id="saPager" style="padding:6px 2px; text-align:center; min-height:26px"></div>
    <div class="sa-sum">
      <div class="k">판매계</div><div class="v" id="sPurch">0</div>
      <div class="k">반품계</div><div class="v" id="sRet">0</div>
      <div class="k">수금계</div><div class="v" id="sPay">0</div>
      <div class="k">할인계</div><div class="v" id="sDc">0</div>
      <div class="k">미수금</div><div class="v" id="sUnpaid">0</div>
    </div>
  </div>

  <!-- 거래처 원장(분개장) — 거래처를 고르면 그 거래처의 일자별 매출·수금·잔고.
       수금등록과 같은 쿼리(/mangr/custLedger.do)라 두 화면의 잔고가 항상 같다. -->
  <div class="sa-card" style="flex:0 0 460px">
    <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px">
      <b>원장</b>
      <span style="margin-left:auto; font-size:11.5px; color:#5a6b7a">* 일자를 클릭하면 그 날 매출품목이 보입니다.</span>
    </div>
    <div style="border:1px solid var(--sa-bd); border-radius:6px; padding:6px 8px; margin-bottom:6px; font-size:12.5px">
      <b>거래처명</b> <span id="lgVen" style="margin-left:8px">—</span>
    </div>
    <%-- 원장 스크롤 : 머리글 고정 + 합계는 스크롤 영역 밖(항상 보임). 지급등록 화면과 같은 규격 --%>
    <div class="sa-list" id="lgWrap" style="max-height:300px; border-radius:8px 8px 0 0">
      <table>
        <colgroup><col style="width:88px"><col><col style="width:52px"><col style="width:70px"><col style="width:52px"><col style="width:90px"></colgroup>
        <thead><tr><th>일자</th><th>매출</th><th>DC</th><th>수금</th><th>할인</th><th>잔고</th></tr></thead>
        <tbody id="lgBody"><tr><td colspan="6" class="sa-msg">거래처를 선택하세요.</td></tr></tbody>
      </table>
    </div>
    <div class="sa-lgfoot">
      <table>
        <colgroup><col style="width:88px"><col><col style="width:52px"><col style="width:70px"><col style="width:52px"><col style="width:90px"></colgroup>
        <tbody id="lgFoot"></tbody>
      </table>
    </div>
  </div>
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="sa-pop" id="saVenPop">
  <div class="box">
    <div class="hd">거래처 선택
      <input type="text" id="saVenQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px" oninput="saVenRender()">
    </div>
    <div class="bd"><table><thead><tr><th style="width:90px">코드</th><th>거래처명</th><th style="width:140px">별칭</th><th style="width:110px">대표자</th><th style="width:100px">담당사원</th></tr></thead>
      <tbody id="saVenBody"></tbody></table></div>
    <div class="ft"><button class="sa-btn" onclick="saVenClose()">닫기</button></div>
  </div>
</div>

<!-- 상품 선택 팝업 -->
<div class="sa-pop" id="saProdPop">
  <div class="box">
    <div class="hd">상품 선택
      <input type="text" id="saProdQ" placeholder="상품코드·상품명 — 거래처가 준 품목코드로도 찾습니다" style="flex:1; height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px" oninput="saProdRender()">
    </div>
    <%-- 거래처 통보품목으로 찾기 (2026-08-01 통화 확정)
         거래처가 준 코드로 입력할 때, 원 상품코드를 골라 둔 통보분이면 그대로 우리 상품이 잡히고,
         안 골라 둔 것(미연결)은 그 자리에서 알려 준다 — 몰래 다른 상품으로 넣지 않는다. --%>
    <div class="bd" id="saExtWrap" style="display:none; padding-bottom:0">
      <div style="font-size:12px; font-weight:800; color:#37475a; margin-bottom:4px">🔖 거래처 매칭코드</div>
      <table><thead><tr><th style="width:110px">거래처 코드</th><th>거래처가 부르는 품목명</th><th style="width:110px">규격</th><th style="width:150px">우리 상품코드</th></tr></thead>
        <tbody id="saExtBody"></tbody></table>
    </div>
    <div class="bd"><table><thead><tr><th style="width:110px">상품코드</th><th>상품명</th><th style="width:110px">규격</th><th style="width:60px">입수</th><th style="width:90px">판매가</th></tr></thead>
      <tbody id="saProdBody"></tbody></table></div>
    <div class="ft"><button class="sa-btn" onclick="saProdClose()">닫기</button></div>
  </div>
</div>

<!-- 납품분 검색 팝업 (2026-07-31) —————————————————————————————
     그 거래처에 이미 나간 품목을 중복 없이 모아 보여준다(판매전표 + 정산서).
       · 체크한 '순서'가 곧 명세 줄 순서다. 체크 칸에 1,2,3… 이 찍혀 순서를 눈으로 확인한다.
       · [납품분제외] = 앞으로 이 목록에 안 나오게 한다(거래처별). 판매 이력은 그대로 둔다.
       · [제외이력보기] 에서 되돌릴 수 있다. -->
<div class="sa-pop" id="saDlvPop">
  <div class="box" style="width:min(980px,96vw)">
    <div class="hd">납품분 검색
      <select id="dvPeriod" style="height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 6px; font-size:12.5px" onchange="saDlvLoad()">
        <option value="1">최근 1년</option><option value="3">최근 3년</option><option value="">전체</option>
      </select>
      <select id="dvSrc" style="height:30px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 6px; font-size:12.5px" onchange="saDlvLoad()">
        <option value="">전체(전표+정산서)</option><option value="TRX">판매전표만</option><option value="MST">정산서만</option>
      </select>
      <button class="sa-btn" id="dvExclBtn" onclick="saDlvToggleExcl()">📋 제외이력보기</button>
      <span style="margin-left:auto"><span class="sa-btn" style="border:0;background:transparent;font-size:18px" onclick="saDlvClose()">✕</span></span>
    </div>
    <div class="bd">
      <div style="display:flex; gap:6px; margin-bottom:8px">
        <input type="text" id="dvQ" placeholder="상품코드·상품명·규격·제조사" style="flex:1; height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="saDlvRender()">
        <button class="sa-btn" onclick="saDlvRender()">🔍</button>
      </div>
      <div style="max-height:420px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table>
          <thead><tr>
            <th style="width:46px"><input type="checkbox" id="dvAll" onchange="saDlvAll(this.checked)"></th>
            <th style="width:110px">상품코드</th><th>상품명</th><th style="width:110px">규격</th>
            <th style="width:110px">제조사</th><th style="width:90px">단가</th><th style="width:90px">현재고</th>
            <th style="width:96px">최근거래</th><th style="width:66px">원천</th>
          </tr></thead>
          <tbody id="dvBody"><tr><td colspan="9" class="sa-msg">거래처를 먼저 선택하세요.</td></tr></tbody>
        </table>
      </div>
      <div style="margin-top:8px; font-size:12.5px; color:#3d4d5c">
        체크한 <b>순서대로</b> 명세에 담깁니다. <span id="dvPickInfo" style="color:#137a6c; font-weight:700"></span>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="font-size:12.5px; color:#5a6b7a" id="dvCnt">0건</span>
      <span style="margin-left:auto"></span>
      <button class="sa-btn red" id="dvExclSave" onclick="saDlvExclSave()">🚫 납품분제외</button>
      <button class="sa-btn teal" id="dvOk" onclick="saDlvApply()">확인 — 순서대로 담기</button>
    </div>
  </div>
</div>

<!-- 원장 일자 클릭 → 그 날 매출품목 (2026-07-31) —————————————
     정산서 매출과 판매전표를 함께 보여준다(원장 금액과 같은 원천 selectCustDayDetail).
     [불러오기] 는 '새 전표'로 올린다 — 그 날 전표를 고치는 게 아니다.
     이미 저장된 판매전표를 다시 담아 저장하면 매출이 두 번 잡히므로 확인을 받는다. -->
<div class="sa-pop" id="saDayPop">
  <div class="box" style="width:min(900px,96vw)">
    <div class="hd">원장 — <span id="dyTitle">일자별 매출품목</span>
      <span style="margin-left:auto"><span class="sa-btn" style="border:0;background:transparent;font-size:18px" onclick="saDayClose()">✕</span></span>
    </div>
    <div class="bd">
      <div style="max-height:380px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table>
          <thead><tr>
            <th style="width:90px">구분</th><th style="width:130px">전표·발주</th><th style="width:110px">품목코드</th>
            <th>품목명</th><th style="width:80px">수량</th><th style="width:90px">단가</th><th style="width:100px">금액</th>
          </tr></thead>
          <tbody id="dyBody"><tr><td colspan="7" class="sa-msg">불러오는 중…</td></tr></tbody>
        </table>
      </div>
      <div style="margin-top:8px; font-size:12.5px; color:#3d4d5c">
        <b>합계</b> <span id="dySum" style="color:#c0392b; font-weight:700">0</span>
        <span style="margin-left:12px">* [불러오기] 는 이 품목들을 <b>새 전표</b>로 올립니다. 그대로 저장하면 매출이 한 번 더 잡힙니다.</span>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center; gap:8px">
      <span style="margin-left:auto"></span>
      <button class="sa-btn teal" onclick="saDayApply()">⤓ 불러오기</button>
      <button class="sa-btn" onclick="saDayClose()">닫기</button>
    </div>
  </div>
</div>

<!-- 복사저장 설정 팝업 — 지난 전표의 명세를 '다른 일자·다른 거래처'로 복제할 때 쓴다 -->
<div class="sa-pop" id="saCopyPop">
  <div class="box" style="width:min(620px,94vw)">
    <div class="hd">복사저장 설정 <span style="margin-left:auto"><span class="sa-btn" style="border:0;background:transparent;font-size:18px" onclick="saCopyClose()">✕</span></span></div>
    <div class="bd">
      <div style="display:flex; align-items:center; gap:10px; margin-bottom:12px">
        <span class="sa-btn" style="pointer-events:none; background:#f1f5f4">판매일자선택</span>
        <input type="date" id="cpDt" style="height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px">
      </div>
      <div style="font-weight:700; margin-bottom:6px">거래처선택</div>
      <div style="display:flex; gap:6px; margin-bottom:8px">
        <input type="text" id="cpQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:32px; border:1px solid var(--sa-bd); border-radius:6px; padding:0 8px; font-size:13.5px" oninput="saCopyRender()">
        <button class="sa-btn" onclick="saCopyRender()">🔍</button>
      </div>
      <div style="max-height:280px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table><thead><tr><th style="width:90px">거래처코드</th><th>거래처명</th><th style="width:120px">별칭</th><th style="width:100px">대표자</th><th style="width:90px">담당사원</th></tr></thead>
          <tbody id="cpBody"></tbody></table>
      </div>
      <div style="margin-top:8px; color:#3d4d5c; font-size:12.5px">거래처를 클릭하면 그 거래처·일자로 <b>새 전표</b>가 만들어집니다. 내용을 확인한 뒤 [저장]을 누르세요.</div>
    </div>
    <div class="ft"><button class="sa-btn" onclick="saCopyClose()">닫기</button></div>
  </div>
</div>

<!-- 판매단가 이력 팝업 -->
<div class="sa-pop" id="saHistPop">
  <div class="box">
    <div class="hd">거래처 상품 판매 단가 이력</div>
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
      <div style="max-height:300px; overflow:auto; border:1px solid var(--sa-bd); border-radius:6px">
        <table><thead><tr>
          <th style="width:34px">#</th><th style="width:100px">거래 일자</th><th>거래처</th>
          <th style="width:80px">단가</th><th style="width:70px">Box 수량</th><th style="width:70px">낱개 수량</th>
          <th style="width:80px">전체 수량</th><th style="width:100px">금액</th><th style="width:50px">행사</th><th style="width:50px">반품</th>
        </tr></thead><tbody id="saHistBody"></tbody></table>
      </div>
    </div>
    <div class="ft" style="display:flex; align-items:center">
      <label style="font-size:12.5px; cursor:pointer"><input type="checkbox" id="hvEvtOnly" onchange="saHistRender()"> 행사만 보기</label>
      <span style="margin-left:auto"><button class="sa-btn" onclick="saHistClose()">✕ 닫기</button></span>
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
var _prods = [];       // 상품 마스터
var _extItems = [];    // 거래처 통보품목(TBL_EXT_ITEM_MST) — 거래처가 준 코드로 찾기용
var _cur = null;       // 선택된 전표(수정 모드)
/* 수정 중인 전표가 '저장된 상태로' 현잔고에 이미 반영해 놓은 금액(판매금액 − 수금액 − 할인액).
   현잔고는 그 전표를 포함해 계산되므로, 거래후잔고를 낼 때 이 값을 빼지 않으면 이중으로 더해진다.
   신규 전표는 0. (2026-07-25 수정 — 전표를 고르면 거래후잔고가 두 배로 뜨던 문제) */
var _curNet = 0;
var _prodTargetRow = -1;

function n(v){ var x = Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x) ? x : 0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
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
/* 📥 정산 엑셀 — 매출내역 화면에 있던 버튼을 이 화면으로 옮겼다(2026-08-01 요청).
   ★기능 자체는 옮기지 않았다. 파일 선택·미리보기·저장은 부모(물류관리 셸 logistics_demo2)의 기존 흐름을 그대로 부른다
     — 파서·출고장 인식·중복 파일 판정이 거기 다 있어서, 여기로 복사하면 두 벌이 되어 갈라진다.
   ★확인·저장 창은 화면 전체를 덮는 오버레이라 이 화면 위에 그대로 뜬다. */
function saSlsExcel(){
  try{
    if (window.parent && window.parent !== window && typeof window.parent.konetSlsExcelPick === 'function'){
      if (window.parent.konetSlsExcelPick()) return;
    }
  }catch(e){}   // 부모 접근 불가(단독 창으로 연 경우 등)
  swAlert('정산 엑셀은 <b>물류관리</b> 화면 안에서만 올릴 수 있습니다.<br>왼쪽 메뉴로 들어와 <b>매출 관리 ▸ 판매 등록</b> 에서 다시 눌러 주세요.');
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
  document.getElementById('saDt').value = today();
  var d = new Date(); d.setMonth(d.getMonth()-1);
  document.getElementById('saFrom').value = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01';
  document.getElementById('saTo').value = today();
  saNew();
  saLoadMasters();
  saLoad();
  /* 거래처 칸 입력검색 — 고르는 동작은 팝업과 같은 saVenPick() 을 그대로 탄다(잔고·원장·담당자 갱신 포함).
     _vendors 는 saLoadMasters() 가 나중에 채우므로 배열이 아니라 '함수'로 넘긴다. */
  _vendorPick(document.getElementById('saVenNm'), {
    list   : function(){ return _vendors; },
    onPick : function(o){ saVenPick(o.vendorCd); },
    onClear: function(){ document.getElementById('saMgrNm').value=''; document.getElementById('saMgrNm').dataset.cd=''; saVenBal(''); saXrefLoad(''); }
  });
})();

/* 합계 표는 그리드 밖에 있으므로 가로 스크롤을 따라가게 맞춘다 */
(function bindFootScroll(){
  var g = document.getElementById('saGridWrap'), f = document.getElementById('saFootWrap');
  if (g && f) g.addEventListener('scroll', function(){ f.scrollLeft = g.scrollLeft; });
})();

/* 등록내용 새로고침 — 지금 보고 있는 전표를 서버에서 다시 읽는다.
   목록·원장·잔고도 같이 갱신한다. 신규 작성 중이면 목록만 새로 읽는다(입력분은 보존). */
function saReload(){
  var seq = _cur ? _cur.saleSeq : null;
  saLoad();
  if (seq) {
    post('/mangr/salesTrxDetail.do','saleSeq='+seq).then(function(r){return r.json();}).then(function(j){
      var d = j&&j.data; if(!d){ saNew(); return; }
      saApply(d);
    }).catch(function(){});
  } else {
    var cd = document.getElementById('saVenNm').dataset.cd||'';
    if (cd) saVenBal(cd);
  }
}

/* ★기준자료(상품·거래처·매칭코드)는 화면을 열 때 한 번만 읽으면 안 된다 (2026-08-01 지적:
     "상품 등록하고 다시 로그인하지 않으면 상품검색이 이전 것으로 나온다").
     이 화면은 물류관리 셸 안의 iframe 이라 한 번 뜨면 다시 로드되지 않는다 —
     다른 화면에서 상품·매칭코드를 등록해도 여기 목록은 옛것 그대로였다.
     그래서 상품 선택 팝업을 열 때마다 다시 읽고, 도착하면 열려 있는 목록을 그 자리에서 다시 그린다. */
function saLoadMasters(){
  post('/vendor/selectVendorMst.do','').then(function(r){return r.json();}).then(function(j){ _vendors=(j&&j.data)||[]; }).catch(function(){});
  post('/prod/prodList.do','findData=').then(function(r){return r.json();}).then(function(j){ _prods=(j&&j.data)||[]; saProdRefreshed(); }).catch(function(){});
  /* 거래처 매칭코드 — 상품 선택 팝업에서 '거래처가 준 코드'로도 찾기 위한 목록 (2026-08-01) */
  post('/prod/extItemList.do','').then(function(r){return r.json();}).then(function(j){ _extItems=(j&&j.data)||[]; saProdRefreshed(); }).catch(function(){});
}
/* 새로 읽은 목록이 도착했을 때 — 팝업이 열려 있으면 그 자리에서 다시 그린다(닫혀 있으면 아무 일 없음) */
function saProdRefreshed(){
  var p=document.getElementById('saProdPop');
  if(p && p.classList.contains('on')) saProdRender();
}

/* ── 전표 입력 ────────────────────────────────────────── */
function saNew(){
  _cur = null; _curNet = 0; _rows = [];
  _xrefNm = {};                       // 거래처가 비워지므로 그 거래처 표기표도 비운다
  document.getElementById('saVenNm').value=''; document.getElementById('saVenNm').dataset.cd='';
  document.getElementById('saMgrNm').value=''; document.getElementById('saMgrNm').dataset.cd='';
  document.getElementById('saRemark').value=''; document.getElementById('saPayAmt').value='0'; document.getElementById('saDcAmt').value='0';
  document.getElementById('saDlvDt').value='';
  document.getElementById('saState').textContent = '신규 전표';
  for (var i=0;i<5;i++) _rows.push(emptyRow());
  saRender(); saNextNo();
  Array.prototype.forEach.call(document.querySelectorAll('#saListBody tr'), function(tr){ tr.classList.remove('on'); });
}
function emptyRow(){ return { prodCd:'', prodNm:'', spec:'', packQty:1, boxQty:0, eaQty:0, qty:0, unitPrice:0, amt:0, dcAmt:0,
                              supplyAmt:0, vatAmt:0, totAmt:0, serviceQty:0, remark:'', eventYn:'N', trxGb:'판매', taxGb:'과세' }; }
function saNextNo(){
  var dt = document.getElementById('saDt').value;
  if (!dt || _cur) return;
  post('/mangr/salesTrxNextNo.do','saleDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){ document.getElementById('saNo').value = (j&&j.data)||'0001'; })
    .catch(function(){ document.getElementById('saNo').value='0001'; });
}
/* 명세 그리드도 매출내역과 같은 방식 — 8행씩 보여주고 스크롤하면 이어붙인다(2026-07-25 요청).
     · 화면에 안 그려진 행도 _rows 에 그대로 있어 저장에는 전부 들어간다(입력값 보존).
     · 편집으로 다시 그릴 때 이미 펼친 만큼(_pShown)은 유지한다 — 안 그러면 보던 줄이 접힌다. */
// (PU_ROWS·_pShown·_pBound 선언은 파일 위 전역 블록으로 옮겼다 — init() 보다 먼저 값이 있어야 한다)
function saGridMore(cnt){
  if (_pShown >= _rows.length) return;
  _pShown = Math.min(_pShown + (cnt||PU_ROWS), _rows.length);
  saRender();
}
function saGridBind(){
  var g = document.getElementById('saGridWrap');
  if (!g || _pBound) return; _pBound = true;
  g.addEventListener('scroll', function(){
    if (_pShown >= _rows.length) return;
    if (g.scrollTop + g.clientHeight >= g.scrollHeight - 30) saGridMore();
  });
}
function saGridPager(){
  var el = document.getElementById('saGridPager');
  if (_pShown >= _rows.length) {
    el.innerHTML = _rows.length > PU_ROWS
      ? '<span style="color:#5a6b7a; font-size:12.5px">총 '+_rows.length+'행 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a; font-size:12.5px">'+_pShown+' / <b>'+_rows.length+'</b>행'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="sa-btn" style="height:22px;margin-left:8px;font-size:12px" onclick="saGridMore('+_rows.length+')">모두 표시</button>';
}
function saRender(){
  var h = '';
  if (_pShown < PU_ROWS) _pShown = PU_ROWS;
  if (_pShown > _rows.length) _pShown = _rows.length;
  _rows.slice(0, _pShown).forEach(function(o,i){
    h += '<tr>'
      /* 행 조작 — 주문 받은 순서대로 넣기 위한 열(2026-07-31).
           ＋ = 이 줄 '위'에 빈 줄 삽입 / ▲▼ = 순서 바꾸기.
         (예전 ＋ 는 상품선택이었다. 상품선택은 아래 상품코드 칸을 눌러 그대로 쓴다) */
      + '<td class="ops">'
      +   '<span title="이 줄 위에 새 줄 삽입" onclick="saInsRow('+i+')">＋</span>'
      +   '<span title="한 줄 위로" onclick="saMoveRow('+i+',-1)">▲</span>'
      +   '<span title="한 줄 아래로" onclick="saMoveRow('+i+',1)">▼</span>'
      + '</td>'
      /* 상품코드 = 우리 코드. 그 아래 작게 '거래처가 부르는 코드'(매칭코드)를 함께 보여 준다(2026-08-01).
         수동 판매는 주문서에 적힌 대로 넣고 확인해야 해서, 우리 코드만 보이면 대조가 안 된다. */
      + '<td>'+ (o.prodCd ? '<span class="lnk" title="클릭 → 다른 상품으로 바꾸기" onclick="saProdOpen('+i+')">'+esc(o.prodCd)+'</span>'
                          : '<span class="lnk" onclick="saProdOpen('+i+')">선택</span>')
             /* 매칭으로 골라 넣은 행만 그 코드를 보여 준다 — 원코드로 넣었으면 표시가 없다(구별) */
             + (o.extCd ? '<div style="font-size:11px;color:#274b8f;margin-top:1px" title="거래처가 부르는 품목코드 (매칭코드)로 넣었습니다">🔖 '+esc(o.extCd)+'</div>' : '')
             +'</td>'
      /* 품명 클릭 = 그 거래처의 판매단가 이력. 찾기 쉽게 📈 아이콘을 붙였다(2026-07-25)
         ★거래처 표기로 바뀐 품명은 🔗 로 표시하고 우리 품명은 hover 로 함께 보여 준다(2026-08-01).
           출고는 요청한 이름으로 나가야 하지만, 우리가 무엇을 파는지도 화면에서 잃으면 안 된다. */
      + '<td class="txt">'+ (function(){
            if(!o.prodNm) return '';
            var our = saOurNm(o.prodCd), alias = (our && our !== o.prodNm);
            return '<span class="lnk" onclick="saHistOpen('+i+')" title="'
              + (alias ? '거래처가 요청한 품명입니다 (우리 품명: '+esc(our)+')&#10;' : '')
              + '클릭 → 이 거래처의 판매단가 이력(최대 3년)">'+esc(o.prodNm)+'</span>'
              + (alias ? ' <span title="거래처 요청 품명 — 이 이름으로 출고됩니다 (우리 품명: '+esc(our)+')" style="cursor:help">🔗</span>' : '')
              + ' <span class="hist" onclick="saHistOpen('+i+')" title="판매단가 이력 보기">📈</span>';
          })() +'</td>'
      + '<td class="txt">'+ (o.packQty?('['+fmt(o.packQty)+']'):'') + esc(o.spec) +'</td>'
      + '<td><input value="'+n(o.boxQty)+'" onchange="saSet('+i+',\'boxQty\',this.value)"></td>'
      + '<td><input value="'+n(o.eaQty)+'" onchange="saSet('+i+',\'eaQty\',this.value)"></td>'
      + '<td class="num">'+fmt(o.qty)+'</td>'
      + '<td><input value="'+n(o.unitPrice)+'" onchange="saSet('+i+',\'unitPrice\',this.value)"></td>'
      + '<td class="num">'+fmt(o.amt)+'</td>'
      + '<td><input value="'+n(o.dcAmt)+'" onchange="saSet('+i+',\'dcAmt\',this.value)"></td>'
      + '<td class="num">'+fmt(o.supplyAmt)+'</td>'
      + '<td class="num">'+fmt(o.vatAmt)+'</td>'
      + '<td class="num">'+fmt(o.totAmt)+'</td>'
      + '<td><input value="'+n(o.serviceQty)+'" onchange="saSet('+i+',\'serviceQty\',this.value)"></td>'
      + '<td><input class="txt" value="'+esc(o.remark)+'" onchange="saSet('+i+',\'remark\',this.value)"></td>'
      + '<td><input type="checkbox" '+(o.eventYn==='Y'?'checked':'')+' onchange="saSet('+i+',\'eventYn\',this.checked?\'Y\':\'N\')"></td>'
      + '<td><select onchange="saSet('+i+',\'trxGb\',this.value)" style="border:0;background:transparent;font-size:12.5px">'
      +   '<option '+(o.trxGb==='판매'?'selected':'')+'>판매</option><option '+(o.trxGb==='반품'?'selected':'')+'>반품</option></select>'
      +   ' <span class="del" onclick="saDelRow('+i+')">✖</span></td>'
      + '</tr>';
  });
  document.getElementById('saBody').innerHTML = h;
  saGridBind(); saGridPager();
  saCalc();
}
function saSet(i, k, v){
  var o = _rows[i]; if(!o) return;
  o[k] = (k==='remark'||k==='eventYn'||k==='trxGb') ? v : n(v);
  /* ★BOX수량을 치면 EA수량이 '친 대로' 따라온다 (2026-08-01 확정 — 입수로 환산하지 않는다).
       입수 48짜리에 BOX 1 → EA 1 · 합계 1. 합계수량은 EA 를 따라가고 화면에서 고칠 수 없다(계산 전용). */
  if (k==='boxQty') o.eaQty = n(o.boxQty);
  saCalcRow(o);
  if (i === _rows.length-1 && o.prodCd) { _rows.push(emptyRow()); _pShown = _rows.length; }   // 마지막 줄을 쓰면 새 줄 자동 추가(그 줄이 보이게)
  saRender();
}
function saCalcRow(o){
  /* 합계수량 = EA수량 그대로 (2026-08-01 확정 — 입수로 환산하지 않는다).
     BOX 1 치면 EA 1 · 합계 1. 입수([48])는 규격 칸에 참고로 보일 뿐 수량 계산에 쓰지 않는다. */
  o.qty = n(o.eaQty);
  o.amt = Math.round(o.qty * n(o.unitPrice)) - n(o.dcAmt);
  var tax = (o.taxGb !== '면세');
  o.supplyAmt = o.amt;
  o.vatAmt = tax ? Math.round(o.amt * 0.1) : 0;
  o.totAmt = o.supplyAmt + o.vatAmt;
}
function saDelRow(i){ _rows.splice(i,1); saTail(); saRender(); }
/* ── 행 순서 (2026-07-31) ───────────────────────────────
     거래처가 불러 준 순서 그대로 명세가 서야 한다. 저장할 때 화면 순서가 그대로
     ROW_NO 1,2,3… 이 되므로(saveSalesTrx), 여기서 줄을 옮기면 전표에도 그 순서로 남는다.
     · saInsRow(i) : i번째 줄 '위'에 빈 줄을 끼운다 — 빠뜨린 품목을 사이에 넣을 때
     · saMoveRow(i,d) : 한 줄 위/아래로. 맨 끝의 빈 줄과는 자리를 바꾸지 않는다
       (빈 줄은 항상 맨 아래에 있어야 '마지막 줄을 쓰면 새 줄 추가' 규칙이 깨지지 않는다) */
/* 맨 아래 빈 줄은 항상 하나 있어야 한다 — '마지막 줄을 쓰면 새 줄이 붙는' 규칙(saSet)이
   거기에 걸려 있다. 줄을 끼우거나 옮기거나 지운 뒤 이걸 불러 모양을 되돌린다. */
function saTail(){
  if (!_rows.length) { _rows.push(emptyRow()); return; }
  if (_rows[_rows.length-1].prodCd) _rows.push(emptyRow());
}
function saInsRow(i){
  _rows.splice(i, 0, emptyRow());
  saTail();
  _pShown = Math.min(_rows.length, Math.max(_pShown + 1, i + 2));   // 끼운 줄이 화면에 보이게
  saRender();
}
function saMoveRow(i, d){
  var j = i + d;
  if (j < 0 || j >= _rows.length) return;
  if (!_rows[i].prodCd && !_rows[j].prodCd) return;                 // 빈 줄끼리는 의미 없음
  var t = _rows[i]; _rows[i] = _rows[j]; _rows[j] = t;
  saTail();                                                          // 맨 끝 빈 줄을 끌어내렸으면 되돌린다
  if (_pShown < j + 1) _pShown = Math.min(j + 1, _rows.length);
  saRender();
}
function saCalc(){
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
  var now = n(document.getElementById('saBalNow').textContent);
  var net = t.tot - n(document.getElementById('saPayAmt').value) - n(document.getElementById('saDcAmt').value);
  document.getElementById('saBalAfter').textContent = fmt(now - _curNet + net);
  return t;
}
function saPayFill(){ document.getElementById('saPayAmt').value = n(document.getElementById('tTot').textContent); saCalc(); }
function saDcFill(){   // 털기 — 판매금액에서 수금액을 뺀 잔돈을 할인으로
  var rest = n(document.getElementById('tTot').textContent) - n(document.getElementById('saPayAmt').value);
  document.getElementById('saDcAmt').value = rest > 0 ? rest : 0; saCalc();
}

/* ── 저장 / 삭제 ──────────────────────────────────────── */
function saSave(){
  var venCd = document.getElementById('saVenNm').dataset.cd || '';
  if (!venCd) { swErr('거래처를 선택하세요.'); return; }
  var items = _rows.filter(function(o){ return o.prodCd; });
  if (!items.length) { swErr('상품을 한 줄 이상 입력하세요.'); return; }
  var t = saCalc();
  var dto = {
    saleSeq: _cur ? _cur.saleSeq : null,
    saleDt: document.getElementById('saDt').value,
    dlvDt: document.getElementById('saDlvDt').value,
    saleNo: document.getElementById('saNo').value,
    custCd: venCd, custNm: document.getElementById('saVenNm').value,
    mgrCd: document.getElementById('saMgrNm').dataset.cd||'', mgrNm: document.getElementById('saMgrNm').value,
    whCd:'', whNm: document.getElementById('saWhNm').value,
    totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty,
    supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:n(document.getElementById('saDcAmt').value),
    payGb: document.getElementById('saPayGb').value, payAmt:n(document.getElementById('saPayAmt').value),
    taxGb: '과세',
    remark: document.getElementById('saRemark').value,
    items: items
  };
  post('/mangr/salesTrxSave.do', dto, true).then(function(r){
    return r.text().then(function(t2){ if(!r.ok) throw new Error(t2); return t2; });
  }).then(function(){ swOk('저장했습니다.'); saNew(); saLoad(); })
    .catch(function(e){ swErr('저장에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
}
function saDelete(){
  if (!_cur) { swErr('목록에서 전표를 먼저 선택하세요.'); return; }
  swConfirm('이 전표를 삭제할까요?<br><span style="font-size:13px;color:#3d4d5c">재고(수불원장)에서 빠졌던 출고도 함께 되돌아옵니다.</span>', null, '삭제')
    .then(function(ok){
      if(!ok) return;
      post('/mangr/salesTrxDelete.do', { saleSeq:_cur.saleSeq, saleDt:_cur.saleDt, saleNo:_cur.saleNo }, true)
        .then(function(r){ if(!r.ok) return r.text().then(function(t){ throw new Error(t); }); swOk('삭제했습니다.'); saNew(); saLoad(); })
        .catch(function(e){ swErr('삭제에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
    });
}

/* ── 전표 목록 ────────────────────────────────────────── */
function saLoad(){
  var b = 'fromDt='+encodeURIComponent(document.getElementById('saFrom').value)
        + '&toDt='+encodeURIComponent(document.getElementById('saTo').value)
        + '&findData='+encodeURIComponent(document.getElementById('saFindNm').value);
  document.getElementById('saListBody').innerHTML = '<tr><td colspan="9" class="sa-msg">조회 중…</td></tr>';
  post('/mangr/salesTrxList.do', b).then(function(r){return r.json();}).then(function(j){
    _list = (j&&j.data)||[]; saListRender();
  }).catch(function(e){ document.getElementById('saListBody').innerHTML='<tr><td colspan="9" class="sa-msg" style="color:#c0392b">조회 오류 : '+esc(e.message)+'</td></tr>'; });
}
/* 하단 목록 — 5행만 보여주고 스크롤이 바닥에 닿으면 다음 5행을 이어붙인다(매출내역과 같은 방식).
     행수에 따라 화면 높이가 들쑥날쑥하던 것을 막는다(2026-07-25 요청).
     페이지 버튼 대신 아래에 '몇 건까지 나왔는지'와 [모두 표시]를 둔다. */
var LIST_ROWS = 5, _lShown = 0, _lBound = false;
function saRowHtml(o, i){
  return '<tr onclick="saPick('+i+')">'
    + '<td><button class="sa-btn" style="height:24px;padding:0 8px;font-size:12px" onclick="event.stopPropagation();saCopy('+i+')">복사저장</button></td>'
    + '<td>'+esc(fmtDt(o.saleDt))+'</td><td>'+esc(o.saleNo)+'</td>'
    + '<td class="txt" style="text-align:left">'+esc(o.custNm)+'</td><td>'+esc(o.mgrNm)+'</td>'
    + '<td>'+n(o.prodCnt)+'</td><td class="num">'+fmt(o.totAmt)+'</td>'
    + '<td>'+esc(o.whNm)+'</td><td>'+esc(o.regUser)+'</td></tr>';
}
function saListRender(){
  document.getElementById('saTotal').textContent = _list.length;
  var tb = document.getElementById('saListBody');
  if (!_list.length) { tb.innerHTML='<tr><td colspan="9" class="sa-msg">전표가 없습니다.</td></tr>'; _lShown=0; saPagerRender(); saSumRender(); return; }
  _lShown = Math.min(LIST_ROWS, _list.length);
  tb.innerHTML = _list.slice(0,_lShown).map(function(o,i){ return saRowHtml(o,i); }).join('');
  saListBind();
  saPagerRender(); saSumRender();
}
function saListMore(cnt){
  if (_lShown >= _list.length) return;
  var to = Math.min(_lShown + (cnt||LIST_ROWS), _list.length), h='';
  for (var i=_lShown; i<to; i++) h += saRowHtml(_list[i], i);
  document.getElementById('saListBody').insertAdjacentHTML('beforeend', h);
  _lShown = to; saPagerRender();
}
function saListBind(){
  var w = document.getElementById('saListWrap');
  if (!w || _lBound) return; _lBound = true;
  w.addEventListener('scroll', function(){
    if (_lShown >= _list.length) return;
    if (w.scrollTop + w.clientHeight >= w.scrollHeight - 30) saListMore();   // 바닥 30px 전에 미리
  });
}
function saPagerRender(){
  var el = document.getElementById('saPager');
  if (_lShown >= _list.length) {
    el.innerHTML = _list.length > LIST_ROWS
      ? '<span style="color:#5a6b7a; font-size:12.5px">총 '+_list.length+'건 — 모두 표시됨</span>' : '';
    return;
  }
  el.innerHTML = '<span style="color:#5a6b7a; font-size:12.5px">'+_lShown+' / <b>'+_list.length+'</b>건'
    + ' <span style="color:#5a6b7a">— 아래로 스크롤하면 이어서 나옵니다</span></span>'
    + ' <button class="sa-btn" style="height:24px;margin-left:8px;font-size:12px" onclick="saListMore('+_list.length+')">모두 표시</button>';
}
function fmtDt(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; }
function saSumRender(){
  var p=0, r=0, pay=0, dc=0;
  _list.forEach(function(o){ var a=n(o.totAmt); if(a<0) r+=a; else p+=a; pay+=n(o.payAmt); dc+=n(o.dcAmt); });
  document.getElementById('sPurch').textContent=fmt(p);
  document.getElementById('sRet').textContent=fmt(r);
  document.getElementById('sPay').textContent=fmt(pay);
  document.getElementById('sDc').textContent=fmt(dc);
  document.getElementById('sUnpaid').textContent=fmt(p+r-pay-dc);
}
function saPick(i){
  var o = _list[i]; if(!o) return;
  post('/mangr/salesTrxDetail.do','saleSeq='+o.saleSeq).then(function(r){return r.json();}).then(function(j){
    var d = j&&j.data; if(!d) return;
    saApply(d);
    Array.prototype.forEach.call(document.querySelectorAll('#saListBody tr'), function(tr,k){ tr.classList.toggle('on', k===i); });
  });
}
/* 서버에서 읽은 전표 1건을 상단 입력 영역에 그대로 얹는다 (선택·새로고침 공용) */
function saApply(d){
  _cur = d;
  _curNet = n(d.totAmt) - n(d.payAmt) - n(d.dcAmt);   // 이 전표가 현잔고에 이미 반영해 둔 금액
  document.getElementById('saDt').value = fmtDt(d.saleDt);
  document.getElementById('saNo').value = d.saleNo;
  var v = document.getElementById('saVenNm'); v.value = d.custNm||''; v.dataset.cd = d.custCd||'';
  var m = document.getElementById('saMgrNm'); m.value = d.mgrNm||''; m.dataset.cd = d.mgrCd||'';
  document.getElementById('saWhNm').value = d.whNm||'물류창고';
  document.getElementById('saDlvDt').value = d.dlvDt ? fmtDt(d.dlvDt) : '';
  document.getElementById('saRemark').value = d.remark||'';
  document.getElementById('saPayGb').value = d.payGb||'외상';
  document.getElementById('saPayAmt').value = n(d.payAmt);
  document.getElementById('saDcAmt').value = n(d.dcAmt);
  _rows = (d.items||[]).map(function(x){ x.taxGb='과세'; return x; });
  _rows.push(emptyRow());
  /* 저장된 품명은 그대로 둔다(그 전표의 사실). 표기표는 이후 '품목 추가' 에만 쓴다. */
  saXrefLoad(d.custCd||'', false);
  document.getElementById('saState').textContent = '수정 중 — '+fmtDt(d.saleDt)+' / '+d.saleNo;
  saRender(); saVenBal(d.custCd);
}
/* ── 복사저장 ─────────────────────────────────────────
     지난 전표의 명세를 그대로 두고 '판매일자'와 '거래처'만 바꿔 새 전표로 만든다.
     같은 물건을 다른 거래처에도 팔거나, 같은 거래처에 반복 판매할 때 쓴다.
     팝업에서 일자·거래처를 고르면 그 조건으로 상단에 복사본이 올라온다(저장은 아직 안 함). */
var _cpSrc = -1;
function saCopy(i){
  _cpSrc = i;
  var o = _list[i];
  document.getElementById('cpDt').value = o ? fmtDt(o.saleDt) : today();
  document.getElementById('cpQ').value = '';
  saCopyRender();
  document.getElementById('saCopyPop').classList.add('on');
}
function saCopyClose(){ document.getElementById('saCopyPop').classList.remove('on'); }
function saCopyRender(){
  var q = (document.getElementById('cpQ').value||'').toLowerCase();
  var l = _vendors.filter(function(o){
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  }).slice(0,200);
  document.getElementById('cpBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="saCopyPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td>'
         + '<td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td><td>'+esc(o.alias)+'</td>'
         + '<td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="5" class="sa-msg">검색 결과가 없습니다.</td></tr>';
}
function saCopyPick(cd){
  var src = _list[_cpSrc]; if(!src) { saCopyClose(); return; }
  var ven = _vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0];
  var dt  = document.getElementById('cpDt').value || today();
  saCopyClose();
  post('/mangr/salesTrxDetail.do','saleSeq='+src.saleSeq).then(function(r){return r.json();}).then(function(j){
    var d = j&&j.data; if(!d) return;
    saApply(d);                       // 명세를 그대로 올린 뒤
    _cur = null; _curNet = 0;         // 새 전표로 돌린다 — 현잔고에 반영된 게 없다
    document.getElementById('saDt').value = dt;
    if (ven) {
      var v = document.getElementById('saVenNm'); v.value = ven.vendorNm||''; v.dataset.cd = ven.vendorCd||'';
      var m = document.getElementById('saMgrNm'); m.value = ven.mgrNm||''; m.dataset.cd = ven.mgrCd||'';
      saVenBal(ven.vendorCd);         // 바뀐 거래처의 현잔고·원장으로 갱신
    }
    document.getElementById('saState').textContent =
      '복사본 — ' + dt + ' / ' + (ven?ven.vendorNm:'') + ' · 내용 확인 후 [저장]';
    saNextNo();
    Array.prototype.forEach.call(document.querySelectorAll('#saListBody tr'), function(tr){ tr.classList.remove('on'); });
  }).catch(function(e){ swErr('복사에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
}

/* ── 거래처 / 상품 / 단가이력 팝업 ───────────────────── */
function saVenOpen(){ document.getElementById('saVenPop').classList.add('on'); document.getElementById('saVenQ').value=''; saVenRender(); }
function saVenClose(){ document.getElementById('saVenPop').classList.remove('on'); }
function saVenRender(){
  var q = (document.getElementById('saVenQ').value||'').toLowerCase();
  var l = _vendors.filter(function(o){
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  }).slice(0,200);
  document.getElementById('saVenBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="saVenPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td><td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td>'
         + '<td>'+esc(o.alias)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="5" class="sa-msg">검색 결과가 없습니다.</td></tr>';
}
function saVenPick(cd){
  var o = _vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0]; if(!o) return;
  var v = document.getElementById('saVenNm'); v.value = o.vendorNm||''; v.dataset.cd = o.vendorCd||'';
  var m = document.getElementById('saMgrNm'); m.value = o.mgrNm||''; m.dataset.cd = o.mgrCd||'';
  saVenClose(); saVenBal(o.vendorCd); saXrefLoad(o.vendorCd);
}

/* ── 거래처 표기(품명) ────────────────────────────────────
     ★출고는 '거래처가 요청한 품목명' 으로 나가야 한다 (2026-08-01).
     코네트 품목은 하나지만 거래처는 같은 물건을 자기 이름으로 부른다. 그 이름을 명세 품명에
     채워 저장하면 TBL_SALES_TRX_DTL.PROD_NM 에 그대로 남아 명세서·조회에 그 이름으로 보인다.
     · 표기가 없는 품목은 우리 PROD_NM 을 그대로 쓴다(_xrefNm 에 없으면 원래 동작).
     · 품명 칸은 입력칸이 아니라 표시 전용이라, 거래처를 바꾸면 담긴 행도 다시 맞춰도 안전하다
       (사람이 손으로 고쳐 둔 값을 덮어쓸 여지가 없다).
     · 우리 품명은 사라지지 않는다 — 셀 hover(title)로 함께 보여 준다. */
var _xrefNm = {};        // 우리 prodCd → 그 거래처 표기(EXT_ITEM_NM)
/* 우리 품명은 '상품마스터(_prods)' 에서 직접 읽는다 (2026-08-01).
   ★행에 찍힌 prodNm 을 우리 이름으로 기억해 두면 안 된다 — 저장된 전표를 불러올 때 거기 찍힌 것은
     이미 '거래처 표기' 라, 그걸 우리 이름으로 잘못 기억하면 다른 거래처로 바꿀 때 옛 거래처 이름이 남는다. */
var _ourNmMap = null;
function saOurNm(cd){
  if(!cd) return '';
  var n0 = (_prods||[]).length;
  if(!_ourNmMap || _ourNmMap.__n !== n0){       // 마스터가 늦게 도착하므로 건수가 바뀌면 다시 만든다
    _ourNmMap = { __n: n0 };
    (_prods||[]).forEach(function(p){ if(p.prodCd) _ourNmMap[p.prodCd] = p.prodNm; });
  }
  return _ourNmMap[cd] || '';
}
/* apply=false 로 부르면 표기표만 받아 두고 담긴 행은 건드리지 않는다.
   ★저장된 전표를 불러올 때가 그 경우다 — 그때 찍힌 이름이 그 전표의 사실이므로,
     지금 매핑이 바뀌었다고 과거 전표의 품명을 조용히 갈아치우면 안 된다. */
function saXrefLoad(cd, apply){
  if(apply === undefined) apply = true;
  _xrefNm = {};
  if(!cd){ if(apply) saXrefApply(); return; }
  post('/prod/xrefNames.do','vendorCd='+encodeURIComponent(cd))
    .then(function(r){return r.json();})
    .then(function(j){
      ((j&&j.data)||[]).forEach(function(x){ if(x.prodCd && x.extItemNm) _xrefNm[x.prodCd]=x.extItemNm; });
      if(apply) saXrefApply();
    })
    .catch(function(){ if(apply) saXrefApply(); });   // 실패해도 우리 품명으로 그냥 간다
}
/* 그 거래처 표기로 품명을 맞춘다(표기 없으면 우리 품명으로 되돌린다) */
function saXrefApply(){
  var changed = false;
  _rows.forEach(function(o){
    if(!o.prodCd) return;
    var want = _xrefNm[o.prodCd] || saOurNm(o.prodCd) || o.prodNm;
    if(want && want !== o.prodNm){ o.prodNm = want; changed = true; }
  });
  if(changed) saRender();
}
/* 품목을 담을 때 쓸 이름 — 그 거래처 표기 우선 */
function saNmFor(prodCd, ourNm){
  return (prodCd && _xrefNm[prodCd]) ? _xrefNm[prodCd] : ourNm;
}
/* 현잔고 = 그 거래처의 미수 누계 = 매출 − DC − 수금 − 할인.
   수금등록(rcvReg)과 같은 쿼리·같은 식이라 두 화면 잔고가 어긋나지 않는다.
   여기 매출에는 정산서(TBL_SALES_MST)와 판매전표가 함께 들어간다. */
function saVenBal(cd){
  if(!cd){ document.getElementById('saBalNow').textContent='0'; saCalc(); saLedger(''); return; }
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l=(j&&j.data)||[], bal=0;
    l.forEach(function(o){ bal += n(o.saleAmt) - n(o.dcAmt) - n(o.rcvAmt) - n(o.discAmt); });
    document.getElementById('saBalNow').textContent = fmt(bal); saCalc();
  }).catch(function(){});
  saLedger(cd);
}

/* ── 거래처 원장(분개장) ──────────────────────────────
     서버는 일자별 매출·DC·수금·할인만 준다. 잔고 누계와 [월 계]·[합 계] 는 여기서 만든다
     (원본 화면과 같은 형태 — 월이 바뀌는 자리에 월계 줄을 끼워 넣는다). */
/* ★ 원장을 그린 거래처를 따로 들고 있는다 (2026-07-31).
     저장 후 saNew() 는 상단 거래처를 비우지만 원장은 그대로 남는다. 그 상태에서
     원장 일자를 눌렀을 때 상단 거래처(빈 값)를 보면 아무 일도 안 일어난 것처럼 죽는다.
     원장에 보이는 것이 곧 이 거래처이므로, 일자 클릭은 이 값을 기준으로 삼는다. */
var _lgCd = '';
function saLedger(cd){
  _lgCd = cd || '';
  var tb = document.getElementById('lgBody');
  document.getElementById('lgVen').textContent = cd ? (document.getElementById('saVenNm').value||cd) : '—';
  if(!cd){ tb.innerHTML='<tr><td colspan="6" class="sa-msg">거래처를 선택하세요.</td></tr>'; document.getElementById('lgFoot').innerHTML=''; return; }
  tb.innerHTML = '<tr><td colspan="6" class="sa-msg">불러오는 중…</td></tr>';
  post('/mangr/custLedger.do','custCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l = (j&&j.data)||[];
    if(!l.length){ tb.innerHTML='<tr><td colspan="6" class="sa-msg">거래 내역이 없습니다.</td></tr>'; return; }
    var h='', bal=0, mm=null, m={p:0,d:0,y:0,c:0}, t={p:0,d:0,y:0,c:0};
    function monthRow(){
      if(mm===null) return '';
      return '<tr style="background:#e8f6ec"><td>[월 계]</td><td class="num">'+fmt(m.p)+'</td><td class="num">'+fmt(m.d)
           + '</td><td class="num">'+fmt(m.y)+'</td><td class="num">'+fmt(m.c)+'</td><td></td></tr>';
    }
    l.forEach(function(o){
      var dt = String(o.dt||''), ym = dt.slice(0,6);
      var p=n(o.saleAmt), d=n(o.dcAmt), y=n(o.rcvAmt), c=n(o.discAmt);
      if(mm!==null && ym!==mm){ h+=monthRow(); m={p:0,d:0,y:0,c:0}; }
      mm = ym;
      bal += p - d - y - c;
      m.p+=p; m.d+=d; m.y+=y; m.c+=c;
      t.p+=p; t.d+=d; t.y+=y; t.c+=c;
      /* 일자 줄 클릭 → 그 날 매출품목 팝업(2026-07-31). [월 계]·[합 계] 줄은 클릭 대상이 아니다 */
      h += '<tr onclick="saDayOpen(\''+dt+'\')" title="클릭 → 이 날 매출품목 보기">'
         + '<td>'+esc(fmtDt(dt))+'</td><td class="num">'+fmt(p)+'</td><td class="num">'+fmt(d)
         + '</td><td class="num">'+fmt(y)+'</td><td class="num">'+fmt(c)+'</td><td class="num"><b>'+fmt(bal)+'</b></td></tr>';
    });
    h += monthRow();
    tb.innerHTML = h;
    /* 합계는 스크롤 영역 밖에 — 아무리 내려도 항상 보인다 */
    document.getElementById('lgFoot').innerHTML =
      '<tr><td>합 계</td><td>'+fmt(t.p)+'</td><td>'+fmt(t.d)+'</td><td>'+fmt(t.y)+'</td><td>'+fmt(t.c)+'</td><td>'+fmt(bal)+'</td></tr>';
  }).catch(function(e){ tb.innerHTML='<tr><td colspan="6" class="sa-msg" style="color:#c0392b">원장 조회 오류</td></tr>'; });
}

/* 열 때마다 기준자료를 다시 읽는다 — 방금 등록한 상품·매칭코드가 바로 보여야 한다(재로그인 없이).
   먼저 들고 있던 목록으로 즉시 그리고, 새 목록이 도착하면 saProdRefreshed 가 다시 그린다(기다리게 하지 않는다). */
function saProdOpen(i){
  _prodTargetRow=i;
  document.getElementById('saProdPop').classList.add('on');
  document.getElementById('saProdQ').value='';
  saProdRender();
  saLoadMasters();
}
function saProdClose(){ document.getElementById('saProdPop').classList.remove('on'); }
function saProdRender(){
  var q = (document.getElementById('saProdQ').value||'').toLowerCase();
  /* ★검색은 매칭코드까지 훑는다 (2026-08-01) — 주문서에 적힌 '거래처 코드·거래처 품명' 으로 쳐도
       우리 상품이 나와야 한다. 그 코드로 걸린 상품코드 집합을 먼저 만들어 아래 필터에서 함께 본다. */
  var byExt={};
  if(q) _extItems.forEach(function(e){
    if(!e.prodCd) return;
    if([e.extItemCd,e.extItemNm,e.extSpec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; }))
      byExt[String(e.prodCd)]=1;
  });
  var l = _prods.filter(function(o){
    if(!q) return true;
    if(byExt[String(o.prodCd)]) return true;                       // 매칭코드로 걸린 상품
    return [o.prodCd,o.prodNm,o.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  }).slice(0,200);
  document.getElementById('saProdBody').innerHTML = l.length ? l.map(function(o){
    /* ★한 상품에 매칭코드가 여럿일 수 있다 — 전부 보여 주고 **무엇으로 넣을지 골라 누르게** 한다(2026-08-01).
         · 줄(상품코드·상품명) 클릭 = 우리 원코드·우리 품명으로 넣기
         · 🔖 줄 클릭            = 그 거래처 코드·그 품명으로 넣기(주문서에 적힌 대로)
       종전에는 매칭 하나만 골라 보여 주고 자동으로 그 품명을 썼다 — 어느 것으로 들어갔는지 알 수 없었다. */
    var exl=saExtListFor(o.prodCd);
    /* 원코드 줄 — 누르면 우리 코드·우리 품명으로 넣는다 */
    var h='<tr class="pick" onclick="saProdPick(\''+esc(o.prodCd)+'\')" title="이 줄을 누르면 우리 원코드로 넣습니다">'
         + '<td>'+esc(o.prodCd)+'</td>'
         + '<td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
         + '<td>'+esc(o.spec)+'</td><td class="num">'+n(o.packQty)+'</td><td class="num">'+fmt(o.salePrice)+'</td></tr>';
    /* 매칭코드 줄 — ★같은 칸(코드는 코드 칸, 품명은 품명 칸)에 맞춰 별도 줄로 둔다(2026-08-01 지적).
       품명 칸에 코드까지 몰아넣으니 어느 것이 코드인지 읽히지 않았다. */
    h += exl.map(function(e){
      return '<tr class="pick sa-exrow" onclick="saExtPick('+e.extSeq+')"'
        + ' title="이 거래처 코드·품명으로 넣습니다'+(e.vendorNm?(' — '+esc(e.vendorNm)):'')+'">'
        + '<td>🔖 '+esc(e.extItemCd)+'</td>'
        + '<td class="txt" style="text-align:left">'+esc(e.extItemNm||'')
        +   (e.vendorNm?(' <span style="color:#8a97a3">('+esc(e.vendorNm)+')</span>'):'')+'</td>'
        + '<td>'+esc(e.extSpec||'')+'</td><td class="num"></td>'
        + '<td class="num">'+(e.extPrice!=null?fmt(e.extPrice):'')+'</td></tr>';
    }).join('');
    return h;
  }).join('') : '<tr><td colspan="5" class="sa-msg">검색 결과가 없습니다.</td></tr>';
  saExtRender(q);
}
/* 거래처 통보품목으로 찾기 (2026-08-01 통화 확정)
     · 원 상품코드를 골라 둔 통보분 → 누르면 그 우리 상품이 그대로 잡힌다(품명은 거래처 통보명으로).
     · 안 골라 둔 것(미연결) → 누르면 알려만 준다. 임의로 다른 상품에 붙이지 않는다.
   현재 거래처의 통보분을 위로 올린다(거래처를 안 가린 공통 통보도 함께). */
/* 우리 상품코드 → 그 거래처가 부르는 코드(매칭코드) 하나 찾기.
   같은 상품에 코드가 여럿이면 ① 지금 고른 거래처 것 ② 거래처를 안 가린 것(신규코드) 순으로 고른다. */
function saExtCdFor(prodCd){
  var l=saExtListFor(prodCd); return l.length?l[0]:null;
}
/* 그 상품에 붙어 있는 매칭코드 전부 — 지금 고른 거래처 것을 앞에, 거래처를 안 가린 것(신규코드)을 뒤에 */
function saExtListFor(prodCd){
  if(!prodCd || !_extItems.length) return [];
  var ven=document.getElementById('saVenNm').dataset.cd||'';
  var l=_extItems.filter(function(o){ return String(o.prodCd||'')===String(prodCd); });
  l.sort(function(a,b){
    var av=(ven&&a.vendorCd===ven)?0:(a.vendorCd?2:1), bv=(ven&&b.vendorCd===ven)?0:(b.vendorCd?2:1);
    return av-bv;
  });
  return l;
}
function saExtRender(q){
  var wrap=document.getElementById('saExtWrap'), body=document.getElementById('saExtBody');
  if(!wrap||!body) return;
  if(!_extItems.length){ wrap.style.display='none'; body.innerHTML=''; return; }
  var ven=document.getElementById('saVenNm').dataset.cd||'';
  /* 검색어가 없어도 '지금 고른 거래처의 매칭코드'는 먼저 펼쳐 둔다(2026-08-01) —
     수동 판매는 주문서의 거래처 코드로 찾는 일이 잦아, 매번 쳐야 하면 이 목록이 없는 것과 같다. */
  var l;
  if(q){
    l=_extItems.filter(function(o){
      return [o.extItemCd,o.extItemNm,o.extSpec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
    });
  }else{
    if(!ven){ wrap.style.display='none'; body.innerHTML=''; return; }   // 거래처도 검색어도 없으면 접어 둔다
    l=_extItems.filter(function(o){ return o.vendorCd===ven; });
  }
  if(ven) l.sort(function(a,b){ return ((b.vendorCd===ven)?1:0)-((a.vendorCd===ven)?1:0); });
  l=l.slice(0,30);
  if(!l.length){ wrap.style.display='none'; body.innerHTML=''; return; }
  body.innerHTML=l.map(function(o){
    var linked=!!o.prodCd;
    return '<tr class="pick" onclick="saExtPick('+o.extSeq+')">'
      + '<td>'+esc(o.extItemCd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.extItemNm||'')
      +   (o.vendorNm?(' <span style="color:#9aa7b3;font-size:11.5px">'+esc(o.vendorNm)+'</span>'):'')+'</td>'
      + '<td>'+esc(o.extSpec||'')+'</td>'
      + '<td>'+(linked ? ('<b style="color:#137a6c">'+esc(o.prodCd)+'</b>')
                       : '<span style="color:#c0392b;font-weight:700">미연결</span>')+'</td></tr>';
  }).join('');
  wrap.style.display='';
}
function saExtPick(seq){
  var o=null; for(var i=0;i<_extItems.length;i++){ if(String(_extItems[i].extSeq)===String(seq)){ o=_extItems[i]; break; } }
  if(!o) return;
  if(!o.prodCd){
    swAlert('<b>'+esc(o.extItemCd)+'</b> 은 아직 우리 상품과 <b>연결되지 않았습니다</b>.<br>'
      + '기준정보 ▸ <b>상품코드등록</b> 화면에서 상품을 고른 뒤 하단 <b>거래처 매칭코드</b> 에 등록해 주세요.<br>'
      + '<span style="color:#5a6b7a;font-size:12.5px">연결 전에는 아래 목록에서 상품을 직접 고르셔도 됩니다.</span>');
    return;
  }
  saProdPick(o.prodCd);
  /* 매칭으로 고른 것 — 코드·품명을 그 표기로 바꿔 두고, 어느 매칭으로 넣었는지 행에 남긴다.
     (saProdPick 이 extCd 를 지우므로 반드시 그 뒤에) */
  var r=_rows[_prodTargetRow];
  if(r){ r.extCd=o.extItemCd; r.extNm=o.extItemNm||''; if(o.extItemNm) r.prodNm=o.extItemNm; saRender(); }
}
function saProdPick(cd){
  var p = _prods.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!p) return;
  var o = _rows[_prodTargetRow]; if(!o) return;
  /* 품명 = 그 거래처가 요청한 이름(있으면). 없으면 우리 품명 그대로 */
  o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=saNmFor(p.prodCd, p.prodNm); o.spec=p.spec||'';
  /* ★매칭 품명을 여기서 자동으로 씌우지 않는다 (2026-08-01) — 매칭으로 넣으려면 팝업에서 🔖 줄을 고른다.
       자동으로 바꾸면 '원코드로 넣었는지 매칭으로 넣었는지' 를 화면에서 구별할 수 없다.
       원코드로 고르면 이 행의 매칭 표시(extCd)도 지운다. */
  o.extCd=null; o.extNm=null;
  o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
  o.unitPrice=n(p.salePrice);   // 기본값 = 상품마스터 판매가 (매입 화면은 inPrice 를 쓴다)
  saProdClose();
  // 그 거래처의 최근 판매단가가 있으면 그 값으로 덮는다
  var ven = document.getElementById('saVenNm').dataset.cd||'';
  post('/mangr/salesLastPrice.do','prodCd='+encodeURIComponent(p.prodCd)+'&remark='+encodeURIComponent(ven))
    .then(function(r){return r.json();}).then(function(j){ if(j&&j.data) o.unitPrice=n(j.data); })
    .catch(function(){}).then(function(){
      saCalcRow(o);
      if (_prodTargetRow === _rows.length-1) _rows.push(emptyRow());
      saRender();
    });
}

/* 거래처 상품 판매 단가 이력 — 품명을 클릭하면 뜬다.
     상단(거래처·상품·바코드·단가)은 이미 받아둔 상품마스터에서 채우고,
     아래 이력만 서버에서 읽는다(그 거래처 × 그 상품, 최대 3년). */
var _hist = [];
function saHistOpen(i){
  var o=_rows[i]; if(!o||!o.prodCd) return;
  var ven = document.getElementById('saVenNm').dataset.cd||'';
  var p = _prods.filter(function(x){ return String(x.prodCd)===String(o.prodCd); })[0] || {};
  document.getElementById('hvVen').textContent   = document.getElementById('saVenNm').value || '(전체 거래처)';
  document.getElementById('hvNm').textContent    = o.prodNm || p.prodNm || '';
  document.getElementById('hvBc').textContent    = p.unitBarcode || '—';
  document.getElementById('hvBox').textContent   = p.boxBarcode || '—';
  document.getElementById('hvIn').textContent    = fmt(p.inPrice);
  document.getElementById('hvSale').textContent  = fmt(p.salePrice);
  document.getElementById('hvWhole').textContent = fmt(p.wholePrice);
  document.getElementById('hvEvtOnly').checked   = false;
  _hist = [];
  document.getElementById('saHistBody').innerHTML = '<tr><td colspan="10" class="sa-msg">불러오는 중…</td></tr>';
  document.getElementById('saHistPop').classList.add('on');
  post('/mangr/salesPriceHist.do','prodCd='+encodeURIComponent(o.prodCd)+'&remark='+encodeURIComponent(ven))
    .then(function(r){return r.json();}).then(function(j){ _hist=(j&&j.data)||[]; saHistRender(); })
    .catch(function(){ document.getElementById('saHistBody').innerHTML='<tr><td colspan="10" class="sa-msg">조회 오류</td></tr>'; });
}
function saHistRender(){
  var only = document.getElementById('hvEvtOnly').checked;
  var l = only ? _hist.filter(function(x){ return x.eventYn==='Y'; }) : _hist;
  document.getElementById('hvCnt').textContent = '[ 조회 건 수: '+l.length+'/'+_hist.length+' ]';
  document.getElementById('saHistBody').innerHTML = l.length ? l.map(function(x,k){
    return '<tr><td>'+(k+1)+'</td><td>'+esc(fmtDt(x.spec))+'</td><td class="txt" style="text-align:left">'+esc(x.prodNm)+'</td>'
         + '<td class="num">'+fmt(x.unitPrice)+'</td><td class="num">'+n(x.boxQty)+'</td><td class="num">'+n(x.eaQty)+'</td>'
         + '<td class="num">'+n(x.qty)+'</td><td class="num">'+fmt(x.amt)+'</td>'
         + '<td>'+(x.eventYn==='Y'?'●':'')+'</td><td>'+(x.trxGb==='반품'?'●':'')+'</td></tr>';
  }).join('') : '<tr><td colspan="10" class="sa-msg">'+(only?'행사 판매 이력이 없습니다.':'이 상품의 판매 이력이 아직 없습니다.')+'</td></tr>';
}
function saHistClose(){ document.getElementById('saHistPop').classList.remove('on'); }

/* ── 납품분 (2026-07-31) ────────────────────────────────
     [납품분] = 그 거래처에 이미 나간 품목을 중복 없이 모은 목록(판매전표 + 정산서).
     상품마스터 전체에서 찾지 않고 '이 거래처가 늘 받는 것' 중에서 고른다.

     ★ 핵심은 '순서' — 거래처가 불러 준 순서대로 체크하면 그 순서 그대로 명세에 담긴다.
       체크 순서를 _dvPick(상품코드 배열)에 쌓고, 체크 칸에 1,2,3… 을 찍어 눈으로 확인한다.
       (체크박스를 다시 누르면 그 자리만 빠지고 뒤 번호가 당겨진다)
     ★ [납품분제외] = 앞으로 이 목록에 안 나오게 한다. 거래처별이고, 판매 이력은 손대지 않는다.
       되돌리려면 [제외이력보기] → [해제]. 서버는 TBL_SALES_DLV_EXCL 한 줄을 ACTION_YN 으로 뒤집는다. */
var _dlv = [];          // 서버에서 받은 납품분(또는 제외이력) 목록
var _dvPick = [];       // 체크한 상품코드 — ★배열 순서 = 담길 순서
var _dvExclMode = false;// true 면 제외이력 보기

function saDlvOpen(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _dvPick = []; _dvExclMode = false;
  document.getElementById('dvQ').value = '';
  document.getElementById('dvAll').checked = false;
  document.getElementById('saDlvPop').classList.add('on');
  saDlvLoad();
}
function saDlvClose(){ document.getElementById('saDlvPop').classList.remove('on'); }
function saDlvToggleExcl(){ _dvExclMode = !_dvExclMode; _dvPick = []; saDlvLoad(); }
function saDlvLoad(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  if (!cd) return;
  var yrs = document.getElementById('dvPeriod').value;
  var from = '';
  if (yrs) { var d = new Date(); d.setFullYear(d.getFullYear() - Number(yrs)); from = d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
  var url = _dvExclMode ? '/mangr/salesDlvExclList.do' : '/mangr/salesDlvList.do';
  var body = 'custCd='+encodeURIComponent(cd)
           + '&fromDt='+encodeURIComponent(_dvExclMode ? '' : from)
           + '&srcFilter='+encodeURIComponent(_dvExclMode ? '' : document.getElementById('dvSrc').value);
  document.getElementById('dvBody').innerHTML = '<tr><td colspan="9" class="sa-msg">불러오는 중…</td></tr>';
  document.getElementById('dvExclBtn').textContent = _dvExclMode ? '↩ 납품분으로' : '📋 제외이력보기';
  document.getElementById('dvExclSave').textContent = _dvExclMode ? '↩ 제외해제' : '🚫 납품분제외';
  document.getElementById('dvOk').style.display = _dvExclMode ? 'none' : '';
  document.getElementById('dvPeriod').disabled = _dvExclMode;
  document.getElementById('dvSrc').disabled = _dvExclMode;
  post(url, body).then(function(r){return r.json();}).then(function(j){
    _dlv = (j&&j.data)||[]; saDlvRender();
  }).catch(function(e){
    document.getElementById('dvBody').innerHTML =
      '<tr><td colspan="9" class="sa-msg" style="color:#c0392b">조회 오류 — 납품분제외 표(TBL_SALES_DLV_EXCL)가 없으면 sql/sales_dlv_excl_ddl.sql 을 먼저 실행하세요.</td></tr>';
  });
}
function saDlvFiltered(){
  var q = (document.getElementById('dvQ').value||'').toLowerCase();
  return _dlv.filter(function(o){
    if(!q) return true;
    return [o.prodCd,o.prodNm,o.spec,o.makerNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  });
}
function saDlvRender(){
  var l = saDlvFiltered();
  document.getElementById('dvCnt').textContent = l.length + '건'
    + (l.length !== _dlv.length ? ' (전체 '+_dlv.length+'건 중)' : '');
  document.getElementById('dvBody').innerHTML = l.length ? l.map(function(o){
    var cd = String(o.prodCd||'');
    var k  = _dvPick.indexOf(cd);
    var st = n(o.curQty);
    return '<tr class="pick" onclick="saDlvPick(\''+esc(cd)+'\')">'
      + '<td>' + (k>=0
          ? '<b style="color:#137a6c">'+(k+1)+'</b>'
          : '<input type="checkbox" onclick="event.stopPropagation();saDlvPick(\''+esc(cd)+'\')">') + '</td>'
      + '<td>'+esc(cd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
      + '<td>'+esc(o.spec)+'</td><td>'+esc(o.makerNm)+'</td>'
      + '<td class="num">'+fmt(o.unitPrice)+'</td>'
      + '<td class="num"'+(st<0?' style="color:#c0392b;font-weight:700"':'')+'>'+fmt(st)+'</td>'
      + '<td>'+esc(_dvExclMode ? String(o.regDttm||'').slice(0,10) : fmtDt(o.lastDt))+'</td>'
      + '<td>'+esc(_dvExclMode ? '제외' : (o.srcGb||''))+'</td></tr>';
  }).join('') : '<tr><td colspan="9" class="sa-msg">'
      + (_dvExclMode ? '제외해 둔 품목이 없습니다.' : '이 거래처에 나간 품목이 아직 없습니다.') + '</td></tr>';
  saDlvInfo();
}
function saDlvPick(cd){
  var k = _dvPick.indexOf(cd);
  if (k >= 0) _dvPick.splice(k,1); else _dvPick.push(cd);   // 뺀 자리는 뒤 번호가 당겨진다
  saDlvRender();
}
function saDlvAll(on){
  _dvPick = on ? saDlvFiltered().map(function(o){ return String(o.prodCd||''); }) : [];
  saDlvRender();
}
function saDlvInfo(){
  var el = document.getElementById('dvPickInfo');
  el.textContent = _dvPick.length ? ('선택 '+_dvPick.length+'건 — '+_dvPick.join(' → ')) : '';
}
/* [확인] — 체크한 순서대로 명세에 담는다.
     이미 입력된 줄 뒤에 붙이고, 화면에 있던 빈 줄은 걷어낸 뒤 맨 끝에 하나만 다시 둔다. */
function saDlvApply(){
  if (!_dvPick.length) { swErr('담을 품목을 체크하세요.'); return; }
  var rows = _rows.filter(function(o){ return o.prodCd; });
  var added = 0, dup = [];
  _dvPick.forEach(function(cd){
    var s = _dlv.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!s) return;
    if (rows.some(function(o){ return String(o.prodCd)===String(cd); })) { dup.push(cd); return; }
    var o = emptyRow();
    o.prodSeq  = s.prodSeq;  o.prodCd = s.prodCd; o.prodNm = saNmFor(s.prodCd, s.prodNm); o.spec = s.spec||'';
    o.packQty  = n(s.packQty)||1;
    o.taxGb    = s.taxGb || '과세';
    o.unitPrice= n(s.unitPrice);      // 그 거래처의 최근 거래단가
    saCalcRow(o);
    rows.push(o); added++;
  });
  rows.push(emptyRow());
  _rows = rows; _pShown = _rows.length;
  saRender();
  saDlvClose();
  if (dup.length) swAlert(added+'건을 담았습니다.<br><span style="font-size:12.5px;color:#3d4d5c">이미 명세에 있는 '+dup.length+'건은 건너뛰었습니다 — '+esc(dup.join(', '))+'</span>');
}
/* [납품분제외] / [제외해제] — 체크한 품목을 거래처별로 넣거나 뺀다 */
function saDlvExclSave(){
  var cd = document.getElementById('saVenNm').dataset.cd || '';
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  if (!_dvPick.length) { swErr('품목을 체크하세요.'); return; }
  var on = !_dvExclMode;   // 납품분 목록에서 누르면 제외, 제외이력에서 누르면 해제
  var msg = on
    ? '체크한 '+_dvPick.length+'건을 <b>납품분에서 제외</b>할까요?<br><span style="font-size:13px;color:#3d4d5c">'
      + document.getElementById('saVenNm').value + ' 거래처의 납품분 목록에만 안 나옵니다. 지난 판매 자료는 그대로입니다.</span>'
    : '체크한 '+_dvPick.length+'건의 <b>제외를 해제</b>할까요?<br><span style="font-size:13px;color:#3d4d5c">다시 납품분 목록에 나옵니다.</span>';
  swConfirm(msg, null, on?'제외':'해제').then(function(ok){
    if(!ok) return;
    var one = (_dvPick.length===1) ? (_dlv.filter(function(x){ return String(x.prodCd)===String(_dvPick[0]); })[0]||{}) : {};
    var body = 'custCd='+encodeURIComponent(cd)
             + '&actionYn='+(on?'Y':'N')
             + '&prodNm='+encodeURIComponent(one.prodNm||'')
             + '&prodCds='+encodeURIComponent(_dvPick.join(','));
    post('/mangr/salesDlvExclSave.do', body).then(function(r){
      return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; });
    }).then(function(){
      _dvPick = [];
      document.getElementById('dvAll').checked = false;
      saDlvLoad();
      swOk(on ? '납품분에서 제외했습니다.' : '제외를 해제했습니다.');
    }).catch(function(e){ swErr('처리에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
  });
}

/* ── 원장 일자 클릭 → 그 날 매출품목 (2026-07-31) ────────
     원장 금액과 같은 원천(selectCustDayDetail)에서 그 날 것만 읽어
     정산서 매출(SALE)과 판매전표(STRX)만 골라 보여준다. 매입·수금 줄은 여기 관심사가 아니다.
     [불러오기] 는 그 품목들을 '새 전표'로 올린다 — 그 날 전표를 여는 게 아니다.
     판매전표에서 온 줄이 섞여 있으면 그대로 저장할 때 매출이 두 번 잡히므로 미리 알린다. */
var _day = [], _dayDt = '';
function saDayOpen(dt){
  /* 기준은 '원장에 보이는 거래처'(_lgCd) — 상단이 비어 있어도(신규 전표) 원장은 살아 있다 */
  var cd = _lgCd || document.getElementById('saVenNm').dataset.cd || '';
  if (!dt) return;
  if (!cd) { swErr('거래처를 먼저 선택하세요.'); return; }
  _dayDt = dt; _day = [];
  var nm = (_lgCd && _lgCd === (document.getElementById('saVenNm').dataset.cd||''))
             ? document.getElementById('saVenNm').value
             : (document.getElementById('lgVen').textContent||cd);
  document.getElementById('dyTitle').textContent = fmtDt(dt) + ' · ' + (nm||cd);
  document.getElementById('dyBody').innerHTML = '<tr><td colspan="7" class="sa-msg">불러오는 중…</td></tr>';
  document.getElementById('dySum').textContent = '0';
  document.getElementById('saDayPop').classList.add('on');
  post('/mangr/selectCustDayDetail.do','custCd='+encodeURIComponent(cd)+'&trxDt='+encodeURIComponent(dt))
    .then(function(r){return r.json();}).then(function(j){
      _day = ((j&&j.data)||[]).filter(function(o){ return o.gb==='SALE' || o.gb==='STRX'; });
      saDayRender();
    }).catch(function(e){
      document.getElementById('dyBody').innerHTML = '<tr><td colspan="7" class="sa-msg" style="color:#c0392b">조회 오류</td></tr>';
    });
}
function saDayClose(){ document.getElementById('saDayPop').classList.remove('on'); }
function saDayRender(){
  var sum = 0;
  document.getElementById('dyBody').innerHTML = _day.length ? _day.map(function(o){
    sum += n(o.amt);
    return '<tr><td>'+esc(o.gbNm)+'</td><td>'+esc(o.docNo)+'</td><td>'+esc(o.itemCd)+'</td>'
      + '<td class="txt" style="text-align:left">'+esc(o.itemNm)+'</td>'
      + '<td class="num">'+fmt(o.qty)+'</td><td class="num">'+fmt(o.price)+'</td><td class="num">'+fmt(o.amt)+'</td></tr>';
  }).join('') : '<tr><td colspan="7" class="sa-msg">이 날 매출품목이 없습니다.</td></tr>';
  document.getElementById('dySum').textContent = fmt(sum);
}
function saDayApply(){
  if (!_day.length) { swErr('불러올 품목이 없습니다.'); return; }
  var hasTrx = _day.some(function(o){ return o.gb==='STRX'; });
  var msg = fmtDt(_dayDt)+' 매출품목 '+_day.length+'건을 <b>새 전표</b>로 올릴까요?'
    + (hasTrx ? '<br><span style="font-size:13px;color:#c0392b">이 날 이미 저장된 판매전표가 섞여 있습니다. 그대로 저장하면 매출이 한 번 더 잡힙니다.</span>' : '')
    + '<br><span style="font-size:13px;color:#3d4d5c">지금 입력 중인 명세는 지워집니다.</span>';
  swConfirm(msg, null, '불러오기').then(function(ok){
    if(!ok) return;
    /* 거래처는 원장 기준(_lgCd). 상단이 비어 있거나 다른 거래처면 거래처마스터에서 채워 넣는다 */
    var cur = document.getElementById('saVenNm').dataset.cd||'';
    var ven;
    if (_lgCd && _lgCd !== cur) {
      var v0 = _vendors.filter(function(x){ return String(x.vendorCd)===String(_lgCd); })[0] || {};
      ven = { cd:_lgCd, nm: v0.vendorNm || document.getElementById('lgVen').textContent || _lgCd,
              mgrCd: v0.mgrCd||'', mgrNm: v0.mgrNm||'' };
    } else {
      ven = { cd: cur, nm: document.getElementById('saVenNm').value||'',
              mgrCd: document.getElementById('saMgrNm').dataset.cd||'', mgrNm: document.getElementById('saMgrNm').value||'' };
    }
    saNew();                                   // 새 전표로 시작(수정 중이던 전표는 놓아준다)
    var v = document.getElementById('saVenNm'); v.value = ven.nm; v.dataset.cd = ven.cd;
    var m = document.getElementById('saMgrNm'); m.value = ven.mgrNm; m.dataset.cd = ven.mgrCd;
    document.getElementById('saDt').value = fmtDt(_dayDt);
    var rows = [];
    _day.forEach(function(o){
      var p = _prods.filter(function(x){ return String(x.prodCd)===String(o.itemCd); })[0] || {};
      var r = emptyRow();
      r.prodSeq = p.prodSeq; r.prodCd = o.itemCd; r.prodNm = o.itemNm || p.prodNm || '';
      r.spec = p.spec || ''; r.packQty = n(p.packQty)||1; r.taxGb = p.taxGb || '과세';
      r.unitPrice = n(o.price);
      /* 저장된 수량을 그대로 되돌린다 — 입수로 쪼개지 않는다(합계 = EA 규칙과 같은 모양). */
      var q = n(o.qty), aq = Math.abs(q);
      r.boxQty = aq; r.eaQty = aq;
      if (q < 0) r.trxGb = '반품';
      saCalcRow(r);
      rows.push(r);
    });
    rows.push(emptyRow());
    _rows = rows; _pShown = _rows.length;
    document.getElementById('saState').textContent = '원장에서 불러옴 — '+fmtDt(_dayDt)+' · 내용 확인 후 [저장]';
    saRender(); saNextNo(); saVenBal(ven.cd);
    saDayClose();
  });
}
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
