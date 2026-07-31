<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 메시지는 프로젝트 공통 컴포넌트를 쓴다 — 로그인 화면(base_login.jsp)과 같은 모양.
     SweetAlert 가 아니라 이 파일이 표준이다(_alertBox / _confirmBox / _toast). --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- 거래처 입력검색 — 거래처 칸에 직접 쳐서 고른다(2026-08-01). [거래처] 팝업은 그대로 둔다. --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js"></script>
<!--
  매입등록 — 홀세일닥터 매입등록 이관 (2026-07-25 신설)
    · 상단 = 전표 입력(헤더 + 명세 그리드) / 하단 = 기간 전표 목록
    · 저장하면 TBL_PURCHASE_MST/DTL + 파생 TBL_STOCK_LEDGER + TBL_PROD_INPRICE_HST 가 함께 쌓인다
    · 설계 근거 : docs/매입등록_설계안.md
-->
<style>
  :root{ --pu-bd:#dbe2ea; --pu-teal:#137a6c; --pu-bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* 글자 크기 한 단계 키움(2026-07-25 요청) — 기준 13 → 14px */
  .pu-wrap{ padding:16px 18px; font-family:'맑은 고딕',Malgun Gothic,sans-serif; font-size:14px; color:#1f2a37; }
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
  .pu-grid{ height:210px; overflow:auto; border:1px solid var(--pu-bd); border-radius:8px 8px 0 0; }
  /* 합계 — 그리드 바로 밑 고정. 가로 스크롤은 JS 가 그리드와 맞춘다 */
  .pu-foot{ overflow:hidden; border:1px solid var(--pu-bd); border-top:0; border-radius:0 0 8px 8px; }
  .pu-foot table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .pu-foot td{ border:1px solid var(--pu-bd); padding:6px 4px; text-align:center; background:#137a6c; color:#fff; font-weight:800; }
  .pu-foot td.num{ text-align:right; }
  .pu-grid table{ width:100%; border-collapse:collapse; font-size:13.5px; white-space:nowrap; }
  .pu-grid th{ background:#eef3f2; color:#1f2a37; font-weight:700; border:1px solid var(--pu-bd); padding:7px 6px; position:sticky; top:0; z-index:2; }
  .pu-grid td{ border:1px solid var(--pu-bd); padding:2px 4px; text-align:center; }
  .pu-grid td.num{ text-align:right; }
  .pu-grid td.txt{ text-align:left; }
  .pu-grid input{ width:100%; border:0; background:transparent; font-size:13.5px; padding:4px 2px; text-align:right; }
  .pu-grid input:focus{ outline:2px solid #bfe3dc; border-radius:3px; }
  .pu-grid input.txt{ text-align:left; }
  .pu-grid tr.tot td{ background:#137a6c; color:#fff; font-weight:800; }
  .pu-grid .lnk{ color:#137a6c; text-decoration:underline; cursor:pointer; }
  .pu-grid .del{ color:#c0392b; cursor:pointer; font-weight:700; }
  /* 행 조작(삽입·위·아래) — 주문·발주 순서 그대로 입력하기 위한 열(2026-07-31, 판매등록과 같다) */
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
  .pu-pop .box{ background:#fff; width:min(760px,94vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.3); }
  .pu-pop .hd{ padding:12px 16px; border-bottom:1px solid var(--pu-bd); font-weight:800; display:flex; align-items:center; gap:8px; }
  .pu-pop .bd{ padding:12px 16px; overflow:auto; }
  .pu-pop .ft{ padding:10px 16px; border-top:1px solid var(--pu-bd); text-align:right; }
  .pu-pop table{ width:100%; border-collapse:collapse; font-size:12.5px; }
  .pu-pop th{ background:#eef3f2; border:1px solid var(--pu-bd); padding:6px 8px; }
  .pu-pop td{ border:1px solid var(--pu-bd); padding:6px 8px; text-align:center; }
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
      <div class="pu-fld" style="flex:0 0 220px"><label>거래처</label><input type="text" id="puVenNm" placeholder="거래처명 입력 또는 [거래처]" title="거래처명·코드·별칭·대표자·담당자로 검색합니다. ↑↓ 로 고르고 Enter."></div>
      <button class="pu-btn teal" onclick="puVenOpen()">거래처</button>
      <%-- 매입분 = 그 매입처에서 이미 사 온 품목(매입전표 + 매입단가이력)을 중복 없이.
           체크한 순서 그대로 명세에 담긴다 — 판매등록의 [납품분]과 같은 장치(2026-07-31). --%>
      <button class="pu-btn teal" onclick="puDlvOpen()" title="이 매입처에서 사 온 품목 목록에서 골라 담기">매입분</button>
      <div class="pu-fld" style="flex:0 0 120px"><label>담당자</label><input type="text" id="puMgrNm" readonly style="background:#f5f7f9"></div>
      <div class="pu-fld" style="flex:0 0 130px"><label>창고</label><input type="text" id="puWhNm" value="물류창고"></div>
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
        <colgroup><col style="width:82px"><col style="width:110px"><col style="width:230px"><col style="width:110px"><col style="width:70px"><col style="width:70px"><col style="width:80px"><col style="width:85px"><col style="width:95px"><col style="width:70px"><col style="width:95px"><col style="width:85px"><col style="width:100px"><col style="width:60px"><col style="width:110px"><col style="width:50px"><col style="width:80px"></colgroup>
        <thead><tr>
          <th>행(＋삽입/▲▼)</th><th>상품코드</th><th>품명(단가이력조회)</th>
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
          <th style="width:70px">복사저장</th><th style="width:110px">매입일시</th><th style="width:70px">번호</th>
          <th>거래처명</th><th style="width:90px">담당사원</th><th style="width:70px">상품수</th>
          <th style="width:120px">금액</th><th style="width:90px">창고</th><th style="width:90px">등록자</th>
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
  <div class="pu-card" style="flex:0 0 460px">
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
        <colgroup><col style="width:88px"><col><col style="width:52px"><col style="width:70px"><col style="width:52px"><col style="width:90px"></colgroup>
        <thead><tr><th>일자</th><th>매입</th><th>DC</th><th>지급</th><th>할인</th><th>잔고</th></tr></thead>
        <tbody id="lgBody"><tr><td colspan="6" class="pu-msg">거래처를 선택하세요.</td></tr></tbody>
      </table>
    </div>
    <div class="pu-lgfoot">
      <table>
        <colgroup><col style="width:88px"><col><col style="width:52px"><col style="width:70px"><col style="width:52px"><col style="width:90px"></colgroup>
        <tbody id="lgFoot"></tbody>
      </table>
    </div>
  </div>
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="pu-pop" id="puVenPop">
  <div class="box">
    <div class="hd">거래처 선택
      <input type="text" id="puVenQ" placeholder="거래처명·코드·별칭·대표자" style="flex:1; height:30px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px" oninput="puVenRender()">
    </div>
    <div class="bd"><table><thead><tr><th style="width:90px">코드</th><th>거래처명</th><th style="width:140px">별칭</th><th style="width:110px">대표자</th><th style="width:100px">담당사원</th></tr></thead>
      <tbody id="puVenBody"></tbody></table></div>
    <div class="ft"><button class="pu-btn" onclick="puVenClose()">닫기</button></div>
  </div>
</div>

<!-- 상품 선택 팝업 -->
<div class="pu-pop" id="puProdPop">
  <div class="box">
    <div class="hd">상품 선택
      <input type="text" id="puProdQ" placeholder="상품코드·상품명" style="flex:1; height:30px; border:1px solid var(--pu-bd); border-radius:6px; padding:0 8px" oninput="puProdRender()">
    </div>
    <div class="bd"><table><thead><tr><th style="width:110px">상품코드</th><th>상품명</th><th style="width:110px">규격</th><th style="width:60px">입수</th><th style="width:90px">매입가</th></tr></thead>
      <tbody id="puProdBody"></tbody></table></div>
    <div class="ft"><button class="pu-btn" onclick="puProdClose()">닫기</button></div>
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
var _prods = [];       // 상품 마스터
var _cur = null;       // 선택된 전표(수정 모드)
/* 수정 중인 전표가 '저장된 상태로' 현잔고에 이미 반영해 놓은 금액(매입금액 − 지급액 − 할인액).
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
    list   : function(){ return _vendors; },
    onPick : function(o){ puVenPick(o.vendorCd); },
    onClear: function(){ document.getElementById('puMgrNm').value=''; document.getElementById('puMgrNm').dataset.cd=''; puVenBal(''); }
  });
})();

/* 합계 표는 그리드 밖에 있으므로 가로 스크롤을 따라가게 맞춘다 */
(function bindFootScroll(){
  var g = document.getElementById('puGridWrap'), f = document.getElementById('puFootWrap');
  if (g && f) g.addEventListener('scroll', function(){ f.scrollLeft = g.scrollLeft; });
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
  var h = '';
  if (_pShown < PU_ROWS) _pShown = PU_ROWS;
  if (_pShown > _rows.length) _pShown = _rows.length;
  _rows.slice(0, _pShown).forEach(function(o,i){
    h += '<tr>'
      /* 행 조작 — 발주·주문 순서 그대로 넣기 위한 열(2026-07-31).
           ＋ = 이 줄 '위'에 빈 줄 삽입 / ▲▼ = 순서 바꾸기.
         (예전 ＋ 는 상품선택이었다. 상품선택은 아래 상품코드 칸을 눌러 그대로 쓴다) */
      + '<td class="ops">'
      +   '<span title="이 줄 위에 새 줄 삽입" onclick="puInsRow('+i+')">＋</span>'
      +   '<span title="한 줄 위로" onclick="puMoveRow('+i+',-1)">▲</span>'
      +   '<span title="한 줄 아래로" onclick="puMoveRow('+i+',1)">▼</span>'
      + '</td>'
      + '<td>'+ (o.prodCd ? '<span class="lnk" title="클릭 → 다른 상품으로 바꾸기" onclick="puProdOpen('+i+')">'+esc(o.prodCd)+'</span>'
                          : '<span class="lnk" onclick="puProdOpen('+i+')">선택</span>') +'</td>'
      /* 품명 클릭 = 그 거래처의 매입단가 이력. 찾기 쉽게 📈 아이콘을 붙였다(2026-07-25) */
      + '<td class="txt">'+ (o.prodNm
          ? '<span class="lnk" onclick="puHistOpen('+i+')" title="클릭 → 이 거래처의 매입단가 이력(최대 3년)">'+esc(o.prodNm)+'</span>'
            + ' <span class="hist" onclick="puHistOpen('+i+')" title="매입단가 이력 보기">📈</span>'
          : '') +'</td>'
      + '<td class="txt">'+ (o.packQty?('['+fmt(o.packQty)+']'):'') + esc(o.spec) +'</td>'
      + '<td><input value="'+n(o.boxQty)+'" onchange="puSet('+i+',\'boxQty\',this.value)"></td>'
      + '<td><input value="'+n(o.eaQty)+'" onchange="puSet('+i+',\'eaQty\',this.value)"></td>'
      + '<td class="num">'+fmt(o.qty)+'</td>'
      + '<td><input value="'+n(o.unitPrice)+'" onchange="puSet('+i+',\'unitPrice\',this.value)"></td>'
      + '<td class="num">'+fmt(o.amt)+'</td>'
      + '<td><input value="'+n(o.dcAmt)+'" onchange="puSet('+i+',\'dcAmt\',this.value)"></td>'
      + '<td class="num">'+fmt(o.supplyAmt)+'</td>'
      + '<td class="num">'+fmt(o.vatAmt)+'</td>'
      + '<td class="num">'+fmt(o.totAmt)+'</td>'
      + '<td><input value="'+n(o.serviceQty)+'" onchange="puSet('+i+',\'serviceQty\',this.value)"></td>'
      + '<td><input class="txt" value="'+esc(o.remark)+'" onchange="puSet('+i+',\'remark\',this.value)"></td>'
      + '<td><input type="checkbox" '+(o.eventYn==='Y'?'checked':'')+' onchange="puSet('+i+',\'eventYn\',this.checked?\'Y\':\'N\')"></td>'
      + '<td><select onchange="puSet('+i+',\'trxGb\',this.value)" style="border:0;background:transparent;font-size:12.5px">'
      +   '<option '+(o.trxGb==='매입'?'selected':'')+'>매입</option><option '+(o.trxGb==='반품'?'selected':'')+'>반품</option></select>'
      +   ' <span class="del" onclick="puDelRow('+i+')">✖</span></td>'
      + '</tr>';
  });
  document.getElementById('puBody').innerHTML = h;
  puGridBind(); puGridPager();
  puCalc();
}
function puSet(i, k, v){
  var o = _rows[i]; if(!o) return;
  o[k] = (k==='remark'||k==='eventYn'||k==='trxGb') ? v : n(v);
  puCalcRow(o);
  if (i === _rows.length-1 && o.prodCd) { _rows.push(emptyRow()); _pShown = _rows.length; }   // 마지막 줄을 쓰면 새 줄 자동 추가(그 줄이 보이게)
  puRender();
}
function puCalcRow(o){
  o.qty = n(o.boxQty) * (n(o.packQty)||1) + n(o.eaQty);
  o.amt = Math.round(o.qty * n(o.unitPrice)) - n(o.dcAmt);
  var tax = (o.taxGb !== '면세');
  o.supplyAmt = o.amt;
  o.vatAmt = tax ? Math.round(o.amt * 0.1) : 0;
  o.totAmt = o.supplyAmt + o.vatAmt;
}
function puDelRow(i){ _rows.splice(i,1); puTail(); puRender(); }
/* ── 행 순서 (2026-07-31) ───────────────────────────────
     발주한 순서 그대로 명세가 서야 한다. 저장할 때 화면 순서가 그대로 ROW_NO 1,2,3… 이 되므로
     여기서 줄을 옮기면 전표에도 그 순서로 남는다. 판매등록과 같은 동작이다.
     맨 아래 빈 줄은 항상 하나 있어야 한다 — '마지막 줄을 쓰면 새 줄이 붙는' 규칙(puSet)이 거기 걸려 있다. */
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
  post('/mangr/purchaseSave.do', dto, true).then(function(r){
    return r.text().then(function(t2){ if(!r.ok) throw new Error(t2); return t2; });
  }).then(function(){ swOk('저장했습니다.'); puNew(); puLoad(); })
    .catch(function(e){ swErr('저장에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message)+'</span>'); });
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
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  }).slice(0,200);
  document.getElementById('cpBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="puCopyPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td>'
         + '<td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td><td>'+esc(o.alias)+'</td>'
         + '<td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="5" class="pu-msg">검색 결과가 없습니다.</td></tr>';
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
function puVenOpen(){ document.getElementById('puVenPop').classList.add('on'); document.getElementById('puVenQ').value=''; puVenRender(); }
function puVenClose(){ document.getElementById('puVenPop').classList.remove('on'); }
function puVenRender(){
  var q = (document.getElementById('puVenQ').value||'').toLowerCase();
  var l = _vendors.filter(function(o){
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.alias,o.ceoNm,o.mgrNm].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  }).slice(0,200);
  document.getElementById('puVenBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="puVenPick(\''+esc(o.vendorCd)+'\')"><td>'+esc(o.vendorCd)+'</td><td class="txt" style="text-align:left">'+esc(o.vendorNm)+'</td>'
         + '<td>'+esc(o.alias)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td></tr>';
  }).join('') : '<tr><td colspan="5" class="pu-msg">검색 결과가 없습니다.</td></tr>';
}
function puVenPick(cd){
  var o = _vendors.filter(function(x){ return String(x.vendorCd)===String(cd); })[0]; if(!o) return;
  var v = document.getElementById('puVenNm'); v.value = o.vendorNm||''; v.dataset.cd = o.vendorCd||'';
  var m = document.getElementById('puMgrNm'); m.value = o.mgrNm||''; m.dataset.cd = o.mgrCd||'';
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
var _lgCd = '';
function puLedger(cd){
  _lgCd = cd || '';
  var tb = document.getElementById('lgBody');
  document.getElementById('lgVen').textContent = cd ? (document.getElementById('puVenNm').value||cd) : '—';
  if(!cd){ tb.innerHTML='<tr><td colspan="6" class="pu-msg">거래처를 선택하세요.</td></tr>'; document.getElementById('lgFoot').innerHTML=''; return; }
  tb.innerHTML = '<tr><td colspan="6" class="pu-msg">불러오는 중…</td></tr>';
  post('/mangr/purchaseLedger.do','vendorCd='+encodeURIComponent(cd)).then(function(r){return r.json();}).then(function(j){
    var l = (j&&j.data)||[];
    if(!l.length){ tb.innerHTML='<tr><td colspan="6" class="pu-msg">거래 내역이 없습니다.</td></tr>'; return; }
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
  }).catch(function(e){ tb.innerHTML='<tr><td colspan="6" class="pu-msg" style="color:#c0392b">원장 조회 오류</td></tr>'; });
}

function puProdOpen(i){ _prodTargetRow=i; document.getElementById('puProdPop').classList.add('on'); document.getElementById('puProdQ').value=''; puProdRender(); }
function puProdClose(){ document.getElementById('puProdPop').classList.remove('on'); }
function puProdRender(){
  var q = (document.getElementById('puProdQ').value||'').toLowerCase();
  var l = _prods.filter(function(o){
    if(!q) return true;
    return [o.prodCd,o.prodNm,o.spec].some(function(x){ return String(x||'').toLowerCase().indexOf(q)>=0; });
  }).slice(0,200);
  document.getElementById('puProdBody').innerHTML = l.length ? l.map(function(o){
    return '<tr class="pick" onclick="puProdPick(\''+esc(o.prodCd)+'\')"><td>'+esc(o.prodCd)+'</td><td class="txt" style="text-align:left">'+esc(o.prodNm)+'</td>'
         + '<td>'+esc(o.spec)+'</td><td class="num">'+n(o.packQty)+'</td><td class="num">'+fmt(o.inPrice)+'</td></tr>';
  }).join('') : '<tr><td colspan="5" class="pu-msg">검색 결과가 없습니다.</td></tr>';
}
function puProdPick(cd){
  var p = _prods.filter(function(x){ return String(x.prodCd)===String(cd); })[0]; if(!p) return;
  var o = _rows[_prodTargetRow]; if(!o) return;
  o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=p.prodNm; o.spec=p.spec||'';
  o.packQty=n(p.packQty)||1; o.taxGb=p.taxGb||'과세';
  o.unitPrice=n(p.inPrice);
  puProdClose();
  // 그 거래처의 최근 매입단가가 있으면 그 값으로 덮는다
  var ven = document.getElementById('puVenNm').dataset.cd||'';
  post('/mangr/purchaseLastPrice.do','prodCd='+encodeURIComponent(p.prodCd)+'&remark='+encodeURIComponent(ven))
    .then(function(r){return r.json();}).then(function(j){ if(j&&j.data) o.unitPrice=n(j.data); })
    .catch(function(){}).then(function(){
      puCalcRow(o);
      if (_prodTargetRow === _rows.length-1) _rows.push(emptyRow());
      puRender();
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
         + '<td class="num">'+fmt(x.unitPrice)+'</td><td class="num">'+n(x.boxQty)+'</td><td class="num">'+n(x.eaQty)+'</td>'
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
      + '<td class="num">'+fmt(o.unitPrice)+'</td>'
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
</script>
