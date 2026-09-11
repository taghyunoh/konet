<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- =====================================================================================
     회사 정보 수정 (기준정보관리 ▸ 회사 정보 수정) — 2026-09-11 신설
     · 고객 요청 「회사정보를 이렇게 바꿔 달라」 — 다른 프로그램의 설정 ▸ 회사정보 수정 화면 3장
       (① 필수·기본 정보 ② 도장 ③ 거래명세서 인쇄 옵션 + 그 사이의 「기능」)을 한 화면에 담았다. 없는 칸은 채웠다.
     · ★모든 회사가 쓴다(관리자 전용인 「회사/사용자 관리」와 별개). 서버는 늘 <세션 회사코드>로만 읽고 쓴다.
     · 저장 : [💾 저장] 한 번에 ①(회사 마스터 활성행) + 기능 + 인쇄 옵션(TBL_COMP_SET 의 JSON)을 함께.
             도장·은행계좌·카드는 제 창에서 바로 저장한다(올리는 순간 끝나는 일이라).
     · 설정 기본값은 asset/js/comp-set.js 한 곳 — 이 화면도 거기서 가져온다.
     · 설정이 실제로 걸리는 곳은 각 항목의 ⓘ 툴팁과 CLAUDE.md 「회사 정보 수정」 절에 적어 두었다.
     ===================================================================================== --%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>회사 정보 수정</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<script src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260911"></script>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --teal2:#0f6b5e; --tl:#e3f2ee; --bg:#f5f7f9; --lab:#f6f8fa; --ink:#1f2a37; --mut:#6b7a89; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'Pretendard Variable',Pretendard,'맑은 고딕','Malgun Gothic',sans-serif; color:var(--ink); background:var(--bg); font-size:14px; }
  .wrap{ padding:8px 12px 24px; max-width:1280px; }
  h2{ margin:0 0 2px; font-size:17px; }
  .sub{ color:var(--mut); font-size:12.5px; margin-bottom:8px; }

  /* 맨 위 작업줄 — 채운 단추는 [저장] 하나(화면 규칙 3) */
  .topbar{ position:sticky; top:0; z-index:20; display:flex; gap:6px; align-items:center; flex-wrap:wrap;
           background:var(--bg); padding:6px 0 8px; border-bottom:1px solid var(--bd); margin-bottom:10px; }
  .topbar .sp{ flex:1; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:8px; padding:0 14px; cursor:pointer;
        font-size:13px; font-weight:600; color:#37475a; font-family:inherit; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); color:var(--teal2); }
  .btn.pri{ background:var(--teal); border-color:var(--teal); color:#fff; min-width:110px; }
  .btn.pri:hover{ background:var(--teal2); color:#fff; }
  .btn.sm{ height:29px; padding:0 10px; font-size:12.5px; }
  .btn.dng{ color:#c0392b; border-color:#e3b4ae; }
  .btn:disabled{ opacity:.5; cursor:default; }
  .dirty{ font-size:12.5px; color:#b45309; font-weight:600; }

  /* 덩어리(카드) */
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:10px 14px 14px; margin-bottom:10px; }
  /* 덩어리 제목 — 한 단계 크고 진하게 (2026-09-11 요청 「각 영역 제목 글자 조금 크게 진하게」) */
  .card > h3{ margin:0 0 10px; font-size:17.5px; font-weight:800; color:#0b5246; display:flex; align-items:center; gap:8px; }
  .card > h3 .no{ display:inline-flex; width:24px; height:24px; border-radius:50%; background:#c3e2d8; color:#0b5246;
                  align-items:center; justify-content:center; font-size:13px; font-weight:800; }
  .card > h3 small{ font-size:12px; color:var(--mut); font-weight:400; }
  .grp{ margin:12px 0 4px; font-size:14px; font-weight:800; color:#1f2a37; }

  /* 탭 (2026-09-11 요청 「탭으로 하고 전체 누르면 스크롤」) — [전체] = 모든 덩어리를 이어서(스크롤) · 나머지 = 그 덩어리만 */
  .tabs{ display:flex; gap:4px; flex-wrap:wrap; margin:0 0 10px; border-bottom:2px solid #d5e3df; }
  .tabs button{ height:36px; padding:0 16px; border:1px solid #d5e3df; border-bottom:none; background:#f1f5f4; border-radius:8px 8px 0 0;
                cursor:pointer; font-size:14px; font-weight:700; color:#5a6b7a; font-family:inherit; margin-bottom:-2px; }
  .tabs button:hover{ color:var(--teal2); }
  /* 고른 탭 = 청록 칠 + ✓ (2026-09-11 「체크 구분 표시」 — 흰 바탕만으로는 어느 탭인지 안 보였다. 거래처 화면 탭과 같은 색) */
  .tabs button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .tabs button.on::before{ content:'✓ '; }
  .card[data-tab][hidden]{ display:none; }
  .grp:first-of-type{ margin-top:0; }
  .grp small{ font-weight:400; color:var(--mut); }

  /* 입력 = 표 형식 (화면 규칙 1) — 라벨 왼쪽 회색 칸 132px + 값 칸 */
  .fm{ display:grid; grid-template-columns:repeat(3, minmax(0,1fr)); }
  .fld{ display:grid; grid-template-columns:132px minmax(0,1fr); align-items:center; border:1px solid var(--bd);
        margin:0 0 -1px -1px; min-height:46px; min-width:0; }
  .fld.s2{ grid-column:span 2; }
  .fld.full{ grid-column:1 / -1; }
  /* 라벨 칸 — 진하게 (2026-09-11 요청 「각 라벨 제목 진하게」) */
  .fld > label{ align-self:stretch; display:flex; align-items:center; gap:3px; padding:0 12px; background:var(--lab);
                border-right:1px solid var(--bd); font-size:13.5px; font-weight:700; color:#1f2a37; white-space:nowrap; }
  .fld > label .req{ color:#d9363e; font-weight:700; }
  .fld > .v{ padding:4px 8px; display:flex; gap:6px; align-items:center; min-width:0; }
  .fld input[type=text], .fld input[type=date], .fld input[type=number], .fld input[type=email], .fld select{
        height:38px; border:1px solid var(--bd); border-radius:8px; padding:0 10px; font-size:14px; font-family:inherit;
        min-width:0; flex:1; background:#fff; color:var(--ink); }
  .fld input:focus, .fld select:focus{ outline:none; border-color:var(--teal); box-shadow:0 0 0 3px rgba(19,122,108,.15); }
  .fld input[readonly]{ background:#f2f4f6; }
  .fld input.w90{ flex:0 0 90px; }
  .fld input.w110{ flex:0 0 110px; }
  .fld .unit{ color:var(--mut); font-size:13px; }
  .fld.bad input{ border-color:#d9363e; background:#fff6f6; }
  @media (max-width:1100px){ .fm{ grid-template-columns:repeat(2, minmax(0,1fr)); } .fld.s2{ grid-column:1 / -1; } }
  @media (max-width:900px){ .fld.full > .v{ flex-wrap:wrap; } .fld.full > .v input{ min-width:160px; } }
  @media (max-width:640px){ .fm{ grid-template-columns:1fr; } .fld{ grid-template-columns:104px minmax(0,1fr); } }

  /* 예/아니오 두 칸 선택 — 고른 쪽만 옅게 칠한다(꽉 채운 색은 [저장] 하나뿐) */
  .yn{ display:inline-flex; border:1px solid var(--bd); border-radius:8px; overflow:hidden; height:38px; flex:0 0 auto; }
  .yn button{ border:0; background:#fff; padding:0 14px; font-size:13.5px; font-family:inherit; cursor:pointer; color:#5a6b7a; min-width:64px; }
  .yn button + button{ border-left:1px solid var(--bd); }
  .yn button.on{ background:var(--tl); color:var(--teal2); font-weight:700; }
  .yn button.on.no{ background:#f3f4f6; color:#37475a; }
  .tip{ display:inline-flex; width:16px; height:16px; border-radius:50%; border:1px solid #b8c4cf; color:#7b8a98;
        font-size:10.5px; align-items:center; justify-content:center; cursor:help; flex:0 0 auto; font-weight:700; }
  .note{ font-size:12px; color:var(--mut); margin-top:6px; line-height:1.55; }
  .note b{ color:#37475a; }
  .soon{ display:inline-block; margin-left:4px; padding:0 6px; border-radius:8px; background:#fff4e0; color:#9a5b00;
         font-size:11px; font-weight:600; }

  /* ② 도장 */
  .stamp{ display:flex; gap:14px; align-items:center; flex-wrap:wrap; }
  .stamp .img{ width:104px; height:104px; border:1px dashed #b8c4cf; border-radius:8px; display:flex; align-items:center;
               justify-content:center; background:#fafbfc repeating-conic-gradient(#f0f2f4 0 25%, transparent 0 50%) 0 0/16px 16px;
               color:#9aa7b3; font-size:12.5px; overflow:hidden; }
  .stamp .img img{ max-width:96px; max-height:96px; }

  /* 창(은행계좌·카드) — 「덮개 > .box > .hd」 뼈대라 ui-popdrag.js 로 끌어 옮긴다 */
  .ci-pop{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.45); z-index:200; align-items:flex-start; justify-content:center; }
  .ci-pop.on{ display:flex; }
  .ci-pop .box{ background:#fff; width:min(820px,96vw); margin-top:6vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.28);
                max-height:86vh; display:flex; flex-direction:column; }
  .ci-pop .hd{ padding:10px 16px; border-bottom:1px solid var(--bd); display:flex; align-items:center; gap:8px; cursor:move; }
  .ci-pop .hd b{ font-size:15px; flex:1; }
  .ci-pop .hd .x{ border:0; background:none; font-size:20px; cursor:pointer; color:#6b7a89; }
  .ci-pop .bd{ padding:12px 16px; overflow:auto; }
  .ci-pop .ft{ padding:10px 16px; border-top:1px solid var(--bd); display:flex; gap:6px; justify-content:flex-end; }
  table.lst{ width:100%; border-collapse:collapse; font-size:13px; margin-bottom:10px; }
  table.lst th{ background:#eaf2f0; color:#125a4e; font-weight:600; padding:6px 8px; border:1px solid #d5e3df; text-align:center; }
  table.lst td{ padding:5px 8px; border:1px solid #e3e8ee; }
  table.lst tr.sel td{ background:#dcefe9; }
  table.lst tbody tr{ cursor:pointer; }
  table.lst tbody tr:hover td{ background:#f3f8f6; }
  table.lst td.c{ text-align:center; }
  table.lst td.empty{ text-align:center; color:#9aa7b3; padding:16px; cursor:default; }
  .ci-pop .fm{ grid-template-columns:repeat(2, minmax(0,1fr)); }
  /* 은행·카드사 고르기 목록 (2026-09-11 「은행 목록 주어서 스크롤」) — 창 안이 스크롤 상자라 잘리지 않게 body 에 fixed 로 띄운다 */
  input[data-ddl]{ cursor:pointer; background:#fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12'%3E%3Cpath d='M2 4l4 4 4-4' fill='none' stroke='%235a6b7a' stroke-width='1.6'/%3E%3C/svg%3E") no-repeat right 10px center !important; padding-right:28px !important; }
  .ci-ddl{ position:fixed; z-index:400; background:#fff; border:1px solid #9ccfc2; border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,.18);
           max-height:240px; overflow-y:auto; padding:4px 0; }
  .ci-ddl div{ padding:7px 12px; font-size:14px; cursor:pointer; }
  .ci-ddl div:hover, .ci-ddl div.on{ background:var(--tl); color:var(--teal2); font-weight:700; }
  .ci-ddl .none{ color:#9aa7b3; cursor:default; font-size:12.5px; }
  .ci-ddl .none:hover{ background:none; color:#9aa7b3; font-weight:400; }
  .ci-pop .fld{ grid-template-columns:104px minmax(0,1fr); }
</style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
</head>
<body>
<div class="wrap">
  <h2>🏢 회사 정보 수정</h2>
  <div class="sub">로그인한 회사의 정보만 고칩니다. 여기서 바꾼 값은 거래명세서·발주서·보내는 메일에 그대로 찍히고, 「기능」은 판매·매입·수금·상품·거래처 화면의 동작을 바꿉니다.</div>

  <div class="topbar">
    <button class="btn" onclick="ciBankOpen()">🏦 은행계좌 관리</button>
    <button class="btn" onclick="ciCardOpen()">💳 카드 관리</button>
    <span class="sp"></span>
    <span class="dirty" id="ciDirty" hidden>● 저장 안 한 변경이 있습니다</span>
    <button class="btn" onclick="ciLoad(true)" title="서버에 저장된 값으로 다시 불러옵니다">↻ 새로고침</button>
    <button class="btn pri" id="ciSaveBtn" onclick="ciSave()" title="Ctrl+S">💾 저장</button>
  </div>

  <%-- 탭 3개 + 전체 (2026-09-11 요청 「1,2,3 을 기본 탭 3개로, 전체 누르면 아래로 전체가 스크롤」)
       ① 필수·기본 정보 / ② 도장·기능 / ③ 거래명세서 인쇄 옵션 — 고객이 보내 준 화면 3장의 나눔 그대로 --%>
  <div class="tabs" id="ciTabs">
    <button type="button" data-t="info">① 회사정보</button>
    <button type="button" data-t="stamp">② 도장 · 기능</button>
    <button type="button" data-t="prt">③ 거래명세서 인쇄 옵션</button>
    <button type="button" data-t="all">전체</button>
  </div>

  <!-- ① 필수·기본 정보 -->
  <div class="card" data-tab="info">
    <h3><span class="no">1</span>필수 정보</h3>
    <div class="fm">
      <div class="fld"><label>회사명 <span class="req">*</span></label><div class="v"><input type="text" id="compNm" maxlength="100"></div></div>
      <div class="fld"><label>대표자명 <span class="req">*</span></label><div class="v"><input type="text" id="compCeo" maxlength="50"></div></div>
      <div class="fld"><label>사업자번호 <span class="req">*</span></label><div class="v"><input type="text" id="busiNum" maxlength="20" placeholder="000-00-00000" data-fmt="biz"></div></div>
    </div>
  </div>

  <div class="card" data-tab="info">
    <h3><span class="no">1</span>기본 정보</h3>
    <div class="fm">
      <div class="fld"><label>업태</label><div class="v"><input type="text" id="bizCond" maxlength="100"></div></div>
      <div class="fld s2"><label>종목</label><div class="v"><input type="text" id="bizItem" maxlength="200"></div></div>

      <%-- 주소 = 한 줄 (2026-09-11 요청 「주소 한줄로」) — 우편번호·[검색]·주소·상세주소를 한 줄에. 칸이 좁아 주소가 잘려 보였다 --%>
      <div class="fld full"><label>주소</label><div class="v">
        <input type="text" id="zipCd" class="w110" maxlength="10" readonly placeholder="우편번호" title="우편번호 — [🔍 검색]으로 넣습니다">
        <button class="btn sm" type="button" onclick="ciZip()">🔍 검색</button>
        <input type="text" id="compAddr" maxlength="200" placeholder="주소" style="flex:3 1 0">
        <input type="text" id="compExtradr" maxlength="200" placeholder="상세주소" style="flex:2 1 0"></div></div>

      <div class="fld"><label>휴대폰번호</label><div class="v"><input type="text" id="compHp" maxlength="30" data-fmt="tel"></div></div>
      <div class="fld"><label>전화번호</label><div class="v"><input type="text" id="compTel" maxlength="30" data-fmt="tel"></div></div>
      <div class="fld"><label>FAX</label><div class="v"><input type="text" id="compFax" maxlength="30" data-fmt="tel"></div></div>

      <div class="fld"><label>이메일</label><div class="v"><input type="text" id="compEmail" maxlength="100" placeholder="name@example.com"></div></div>
      <div class="fld"><label>설립일</label><div class="v"><input type="date" id="foundDt"></div></div>
      <div class="fld"><label>법인번호</label><div class="v"><input type="text" id="corpNo" maxlength="20" placeholder="000000-0000000" data-fmt="corp"></div></div>

      <div class="fld"><label>대표자 생년월일</label><div class="v"><input type="date" id="ceoBirth"></div></div>
      <div class="fld s2"><label>결제계좌 <span class="tip" title="거래명세서 아래 「계좌」 칸에 찍히는 계좌입니다.&#10;[🏦 은행계좌 관리]에서 등록한 계좌 중에서 고릅니다.">?</span></label>
        <div class="v"><select id="bankAcct"></select><button class="btn sm" type="button" onclick="ciBankOpen()">계좌 등록…</button></div></div>

      <div class="fld full"><label>공지사항1 <span class="tip" title="거래명세서 맨 아래 「공지사항」 칸 첫 줄입니다.">?</span></label><div class="v"><input type="text" id="stmtNotice" maxlength="500"></div></div>
      <div class="fld full"><label>공지사항2 <span class="tip" title="거래명세서 맨 아래 「공지사항」 칸 둘째 줄입니다.">?</span></label><div class="v"><input type="text" id="stmtNotice2" maxlength="500"></div></div>
    </div>
  </div>

  <!-- ② 도장 -->
  <div class="card" data-tab="stamp">
    <h3><span class="no">2</span>도장</h3>
    <div class="stamp">
      <div class="img" id="stampBox">없음</div>
      <div>
        <button class="btn" type="button" onclick="document.getElementById('stampFile').click()">⬆ 업로드</button>
        <button class="btn dng" type="button" id="stampDel" onclick="ciStampDel()" disabled>삭제</button>
        <input type="file" id="stampFile" accept="image/png,image/jpeg,image/gif,image/webp" hidden onchange="ciStampPick(this)">
        <div class="note">거래명세서 <b>공급자 「성명」 칸</b>에 찍힙니다(인쇄·미리보기·보내는 링크 모두).<br>
          배경이 투명한 <b>PNG</b>가 가장 깔끔합니다. 올리면 300px 안쪽으로 줄여 바로 저장됩니다.</div>
      </div>
    </div>
  </div>

  <!-- 기능 -->
  <div class="card" id="funcCard" data-tab="stamp">
    <h3>⚙ 기능 <small>— 각 항목의 <span class="tip" style="display:inline-flex">?</span> 에 어느 화면에 어떻게 걸리는지 적어 두었습니다</small></h3>

    <div class="grp">거래처 <small>(새 거래처를 등록할 때 처음 들어가는 값)</small></div>
    <div class="fm">
      <div class="fld"><label>기본 과세 유형 <span class="tip" title="새 거래처의 부가세 구분 첫 값입니다.&#10;거래처에 부가세 구분이 비어 있을 때 판매·매입등록도 이 값으로 계산합니다.&#10;별도 = 금액에 10% 더함 · 포함 = 금액 안에 부가세 · 면세 = 부가세 없음">?</span></label>
        <div class="v"><select data-f="venVat"><option>별도</option><option>포함</option><option>면세</option></select></div></div>
      <div class="fld"><label>DC 사용 <span class="tip" title="새 거래처의 「DC 사용」 첫 값입니다.&#10;거래처가 DC 사용 = 예 이고 DC율이 있으면 판매·매입등록에 상품을 담을 때&#10;DC 금액(= 금액 × DC율)이 저절로 들어갑니다. DC 칸을 손으로 고치면 그 줄은 자동 계산을 멈춥니다.">?</span></label>
        <div class="v"><span class="yn" data-f="venDcYn"></span></div></div>
      <div class="fld"><label>기본 DC율 <span class="tip" title="새 거래처의 DC율 첫 값입니다(%).">?</span></label>
        <div class="v"><input type="number" data-f="venDcRate" class="w90" min="0" max="100" step="0.1"><span class="unit">%</span></div></div>
    </div>

    <div class="grp">상품 <small>(새 상품을 등록할 때 처음 들어가는 값)</small></div>
    <div class="fm">
      <div class="fld"><label>기본 과세 유형 <span class="tip" title="상품코드등록·상품관리의 [추가] 창에서 과세 칸의 첫 값입니다.">?</span></label>
        <div class="v"><select data-f="prodTax"><option>과세</option><option>면세</option></select></div></div>
    </div>

    <div class="grp">거래 <small>(판매등록 · 매입등록)</small></div>
    <div class="fm">
      <div class="fld"><label>단가 소수점 <span class="tip" title="예 = 단가를 소수 2자리까지 쓰고 보여 줍니다(종전).&#10;아니오 = 단가를 정수로만 받고, 소수로 친 값은 반올림합니다.">?</span></label>
        <div class="v"><span class="yn" data-f="priceDec"></span></div></div>
      <div class="fld"><label>수량 소수점 <span class="tip" title="예 = BOX·EA 수량에 소수를 쓰고 합계수량도 소수로 보여 줍니다.&#10;아니오 = 수량은 정수만(소수로 친 값은 반올림).&#10;※ 재고 장부는 정수라 소수 수량은 재고에 반올림되어 들어갑니다.">?</span></label>
        <div class="v"><span class="yn" data-f="qtyDec"></span></div></div>
      <div class="fld"><label>서비스 칸 <span class="tip" title="판매·매입 명세의 「서비스」 칸을 보일지 정합니다.&#10;숨겨도 이미 적힌 값은 그대로 저장됩니다.">?</span></label>
        <div class="v"><span class="yn" data-f="svcFld"></span></div></div>
      <div class="fld"><label>비고 칸 <span class="tip" title="판매·매입 명세의 「비고」 칸을 보일지 정합니다.&#10;숨겨도 이미 적힌 값은 그대로 저장됩니다(거래명세서 비고에도 그대로 찍힘).">?</span></label>
        <div class="v"><span class="yn" data-f="rmkFld"></span></div></div>
      <div class="fld"><label>불량 반품 <span class="tip" title="예 = 거래구분에 「불량반품」이 생깁니다.&#10;· 판매 불량반품 : 금액은 반품처럼 빠지지만 재고로 되돌아가지 않습니다(팔 수 없는 물건).&#10;· 매입 불량반품 : 반품과 같이 재고에서 빠지고 매입액이 줄어듭니다.">?</span></label>
        <div class="v"><span class="yn" data-f="badRtn"></span></div></div>
    </div>

    <div class="grp">매출</div>
    <div class="fm">
      <div class="fld"><label>재고 부족 제한 <span class="tip" title="예 = 판매 저장 때 현재고보다 많이 팔면 저장을 막습니다(주코드 기준 · 반품 줄 제외).&#10;이미 저장된 전표를 고칠 때는 그 전표가 잡아 둔 수량을 되돌려 놓고 셉니다.">?</span></label>
        <div class="v"><span class="yn" data-f="stockLimit"></span></div></div>
      <div class="fld"><label>여신 초과 제한 <span class="tip" title="예 = 판매 저장 때 거래후잔고가 그 거래처의 「여신한도」를 넘으면 저장을 막습니다.&#10;여신한도는 [매입/매출 거래처] 수정 창에서 거래처마다 넣습니다(비우면 한도 없음).">?</span></label>
        <div class="v"><span class="yn" data-f="creditLimit"></span></div></div>
    </div>

    <div class="grp">수금</div>
    <div class="fm">
      <div class="fld"><label>기본 유형 <span class="tip" title="수금등록을 열거나 [신규등록]을 누를 때 입금구분의 첫 값입니다.">?</span></label>
        <div class="v"><select data-f="rcvPayGb"><option>무통장입금</option><option>현금</option><option>카드</option><option>계좌이체</option><option>어음</option></select></div></div>
    </div>

    <div class="grp">입고 <small>(매입등록 저장)</small></div>
    <div class="fm">
      <div class="fld"><label>매입단가 자동 갱신 <span class="tip" title="예 = 매입을 저장하면 그 상품의 매입단가(상품마스터)를 새 값으로 바꿉니다(종전 동작).&#10;아니오 = 매입단가 이력만 남기고 상품마스터 매입단가는 그대로 둡니다.">?</span></label>
        <div class="v"><span class="yn" data-f="inPriceAuto"></span></div></div>
      <div class="fld"><label>평균 매입단가 사용 <span class="tip" title="예 = 자동 갱신할 때 이번 매입단가가 아니라 <지금까지 입고의 평균 매입단가>로 바꿉니다.&#10;아니오 = 이번 매입단가로 바꿉니다(종전).&#10;※ 매입단가 자동 갱신이 예일 때만 뜻이 있습니다.">?</span></label>
        <div class="v"><span class="yn" data-f="inPriceAvg"></span></div></div>
      <div class="fld"><label>평균 산출 시 0원 포함 <span class="tip" title="평균 매입단가를 셀 때 단가 0원 입고(무상·조정 등)를 넣을지 정합니다.&#10;예 = 넣는다(종전) — 평균이 그만큼 낮아집니다.&#10;아니오 = 뺀다.&#10;재고현황·재고마감의 재고금액과 위 「평균 매입단가 사용」에 함께 걸립니다.">?</span></label>
        <div class="v"><span class="yn" data-f="avgZero"></span></div></div>
    </div>

    <div class="grp">세금계산서</div>
    <div class="fm">
      <div class="fld"><label>대표 상품명 <span class="tip" title="세금계산서에 품목을 한 줄로 묶을 때 쓰는 이름입니다.&#10;※ 세금계산서 발행 기능이 붙으면 이 값을 씁니다(지금은 저장만).">?</span></label>
        <div class="v"><input type="text" data-f="taxItemNm" maxlength="50" placeholder="예) 물품대금"></div></div>
      <div class="fld"><label>기본 발행 기준 <span class="tip" title="세금계산서를 매출(판매) 기준으로 낼지 수금 기준으로 낼지의 첫 값입니다.&#10;※ 세금계산서 발행 기능이 붙으면 이 값을 씁니다(지금은 저장만).">?</span></label>
        <div class="v"><select data-f="taxIssueGb"><option>매출 기준</option><option>수금 기준</option></select></div></div>
    </div>
    <div class="note">※ 세금계산서 두 칸은 아직 발행 기능이 없어 <b>값만 저장</b>됩니다<span class="soon">발행 기능과 함께 적용</span></div>
  </div>

  <!-- ③ 거래명세서 인쇄 옵션 -->
  <div class="card" id="prtCard" data-tab="prt">
    <h3><span class="no">3</span>거래명세서 인쇄 옵션 <small>— 판매등록 [🖨 거래명세표] 조건 창의 첫 값. 어느 PC에서 열어도 같습니다</small></h3>

    <div class="grp">웹(PC)</div>
    <div class="fm">
      <div class="fld"><label>상품 정렬 <span class="tip" title="입력순 = 명세에 담은 순서 · 조회번호순 = 상품마스터 조회순서(없으면 코드순)">?</span></label>
        <div class="v"><select data-p="ord"><option value="in">입력순</option><option value="sort">조회번호순</option></select></div></div>
      <div class="fld"><label>바코드 <span class="tip" title="품목 줄에 상품 바코드(낱개바코드, 없으면 박스바코드)를 찍습니다.">?</span></label><div class="v"><span class="yn" data-p="bc"></span></div></div>
      <div class="fld"><label>단가</label><div class="v"><span class="yn" data-p="price"></span></div></div>
      <div class="fld"><label>박스단가 <span class="tip" title="단가 × 입수수량 = 한 박스 값">?</span></label><div class="v"><span class="yn" data-p="boxp"></span></div></div>
      <div class="fld"><label>부가세 <span class="tip" title="예 = 공급가액 + 세액 두 칸 · 아니오 = 부가세를 더한 금액 한 칸">?</span></label><div class="v"><span class="yn" data-p="vat"></span></div></div>
      <div class="fld"><label>금액</label><div class="v"><span class="yn" data-p="amt"></span></div></div>
      <div class="fld"><label>잔고 <span class="tip" title="전잔고 · 잔고(거래후) 를 아래에 찍습니다">?</span></label><div class="v"><span class="yn" data-p="bal"></span></div></div>
      <div class="fld"><label>단가변동 표시 <span class="tip" title="그 거래처 직전 판매단가와 다르면 ▲/▼ 와 직전단가를 붙입니다">?</span></label><div class="v"><span class="yn" data-p="chg"></span></div></div>
      <div class="fld"><label>반품액·실매출액 <span class="tip" title="예 = 합계 아래에 반품액과 실매출액(판매 − 반품)을 따로 찍습니다">?</span></label><div class="v"><span class="yn" data-p="rtn"></span></div></div>
      <div class="fld"><label>반전 <span class="tip" title="머리글·합계 줄을 진한 바탕에 흰 글자로">?</span></label><div class="v"><span class="yn" data-p="inv"></span></div></div>
      <div class="fld"><label>음영 <span class="tip" title="품목 줄을 한 줄씩 건너 옅게 칠해 줄을 따라 읽기 쉽게 합니다">?</span></label><div class="v"><span class="yn" data-p="shade"></span></div></div>
      <div class="fld"><label>인쇄일시 <span class="tip" title="오른쪽 아래에 찍은 날짜·시각을 적습니다">?</span></label><div class="v"><span class="yn" data-p="ptime"></span></div></div>
      <div class="fld"><label>한 장에 품목 <span class="tip" title="한 장에 들어가는 품목 줄 수(3~40).&#10;「한 장에 모두」는 12줄, 한 부만 찍으면 38줄까지가 A4 한 장 안전선입니다.">?</span></label>
        <div class="v"><input type="number" data-p="rows" class="w90" min="3" max="40" step="1"><span class="unit">줄</span></div></div>
      <div class="fld s2"><label>인쇄 방식</label>
        <div class="v"><select data-p="mode">
          <option value="both">한 장에 모두 (위 공급받는자용 · 아래 공급자 보관용)</option>
          <option value="two">두 장으로 (공급받는자용 · 공급자 보관용)</option>
          <option value="b1">공급받는자용만</option>
          <option value="r1">공급자 보관용만</option></select></div></div>
    </div>

    <div class="grp">모바일(앱)</div>
    <div class="fm">
      <div class="fld"><label>바코드</label><div class="v"><span class="yn" data-a="bc"></span></div></div>
      <div class="fld"><label>바코드 방식 <span class="tip" title="문자 = 바코드 번호를 글자로 · 바코드 = 막대 그림으로">?</span></label>
        <div class="v"><select data-a="bcType"><option>문자</option><option>바코드</option></select></div></div>
      <div class="fld"><label>단가</label><div class="v"><span class="yn" data-a="price"></span></div></div>
      <div class="fld"><label>부가세</label><div class="v"><span class="yn" data-a="vat"></span></div></div>
      <div class="fld"><label>잔고</label><div class="v"><span class="yn" data-a="bal"></span></div></div>
      <div class="fld"><label>빈 서명 라인 <span class="tip" title="아래에 받는 분 서명 줄을 비워 둡니다">?</span></label><div class="v"><span class="yn" data-a="sign"></span></div></div>
    </div>
  </div>
</div>

<!-- 🏦 은행계좌 관리 -->
<div class="ci-pop" id="ciBankPop">
  <div class="box">
    <div class="hd"><b>🏦 은행계좌 관리</b><button class="x" onclick="ciPopClose('ciBankPop')">✕</button></div>
    <div class="bd">
      <table class="lst"><thead><tr><th style="width:44px">No</th><th>은행</th><th>계좌번호</th><th>예금주</th><th>별칭(용도)</th><th style="width:96px">결제계좌</th></tr></thead>
        <tbody id="bankRows"></tbody></table>
      <div class="fm">
        <div class="fld"><label>은행 <span class="req">*</span></label><div class="v"><input type="text" id="bk_nm" maxlength="50" placeholder="눌러서 고르거나 직접 입력" data-ddl="BANKS"></div></div>
        <div class="fld"><label>계좌번호 <span class="req">*</span></label><div class="v"><input type="text" id="bk_no" maxlength="50"></div></div>
        <div class="fld"><label>예금주</label><div class="v"><input type="text" id="bk_holder" maxlength="100"></div></div>
        <div class="fld"><label>별칭(용도)</label><div class="v"><input type="text" id="bk_alias" maxlength="100" placeholder="예) 매출 입금용"></div></div>
      </div>
    </div>
    <div class="ft">
      <button class="btn" onclick="ciBankNew()">＋ 새로 입력</button>
      <button class="btn dng" id="bk_del" onclick="ciBankDel()" disabled>삭제</button>
      <span style="flex:1"></span>
      <button class="btn" id="bk_save" onclick="ciBankSave()">💾 계좌 저장</button>
      <button class="btn" onclick="ciPopClose('ciBankPop')">닫기</button>
    </div>
  </div>
</div>

<!-- 💳 카드 관리 -->
<div class="ci-pop" id="ciCardPop">
  <div class="box">
    <div class="hd"><b>💳 카드 관리</b><button class="x" onclick="ciPopClose('ciCardPop')">✕</button></div>
    <div class="bd">
      <table class="lst"><thead><tr><th style="width:44px">No</th><th>카드사</th><th>카드 이름</th><th>번호 뒤 4자리</th><th>사용자</th><th>구분</th><th>비고</th></tr></thead>
        <tbody id="cardRows"></tbody></table>
      <div class="fm">
        <div class="fld"><label>카드사</label><div class="v"><input type="text" id="cd_co" maxlength="50" placeholder="눌러서 고르거나 직접 입력" data-ddl="CARDCOS"></div></div>
        <div class="fld"><label>카드 이름</label><div class="v"><input type="text" id="cd_nm" maxlength="100" placeholder="예) 법인 주유카드"></div></div>
        <div class="fld"><label>번호 뒤 4자리 <span class="tip" title="보안상 카드번호 전체는 저장하지 않습니다. 뒤 4자리만 적어 구분합니다.">?</span></label><div class="v"><input type="text" id="cd_l4" maxlength="4" inputmode="numeric" class="w90"></div></div>
        <div class="fld"><label>사용자</label><div class="v"><input type="text" id="cd_user" maxlength="50"></div></div>
        <div class="fld"><label>구분</label><div class="v"><select id="cd_gb"><option>법인</option><option>개인</option></select></div></div>
        <div class="fld"><label>비고</label><div class="v"><input type="text" id="cd_rmk" maxlength="200"></div></div>
      </div>
    </div>
    <div class="ft">
      <button class="btn" onclick="ciCardNew()">＋ 새로 입력</button>
      <button class="btn dng" id="cd_del" onclick="ciCardDel()" disabled>삭제</button>
      <span style="flex:1"></span>
      <button class="btn" onclick="ciCardSave()">💾 카드 저장</button>
      <button class="btn" onclick="ciPopClose('ciCardPop')">닫기</button>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/asset/js/ui-popdrag.js?v=20260910b"></script>
<script>
var CTX = '${pageContext.request.contextPath}';
var _info = {}, _bank = [], _card = [], _stamp = '', _dirty = false, _bankSel = null, _cardSel = null;
var INFO_F = ['compNm','compCeo','busiNum','bizCond','bizItem','zipCd','compAddr','compExtradr','compHp','compTel','compFax',
              'compEmail','foundDt','corpNo','ceoBirth','bankAcct','stmtNotice','stmtNotice2'];

function $(id){ return document.getElementById(id); }
function esc(s){ return String(s == null ? '' : s).replace(/[&<>"']/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }
function post(url, body, json){
  return fetch(CTX + url, { method:'POST', credentials:'same-origin',
      headers: json ? {'Content-Type':'application/json'} : {'Content-Type':'application/x-www-form-urlencoded'},
      body: json ? JSON.stringify(body) : (body || '') })
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t || ('HTTP ' + r.status)); return t; }); });
}
function ymdToIn(v){ v = String(v || '').replace(/-/g,''); return /^\d{8}$/.test(v) ? v.substr(0,4)+'-'+v.substr(4,2)+'-'+v.substr(6,2) : ''; }
/* 「저장 안 한 변경」 = <불러온 값과 지금 값이 다를 때만> (2026-09-11 「변경이 없는데 계속 뜬다」 지적).
     종전에는 입력 이벤트가 한 번만 나도 켰다 — 브라우저 자동완성이 칸을 건드리거나, 고쳤다가 되돌려도 계속 떠 있었다.
     ⇒ 불러온 직후 값을 찍어 두고(_snap) 이벤트마다 지금 값과 비교한다. */
var _snap = '';
function ciSnap(){
  var o = {};
  INFO_F.forEach(function(k){
    var el = $(k), v = el ? String(el.value || '').trim() : '';
    if (el && el.getAttribute('data-fmt')) v = v.replace(/[\s-]/g, '');   // 칸을 떠날 때 넣는 「-」는 변경으로 치지 않는다
    o[k] = v;
  });
  o.f = setRead('data-f', konetSet.DEF.func); o.p = setRead('data-p', konetSet.DEF.prt); o.a = setRead('data-a', konetSet.DEF.prtApp);
  return JSON.stringify(o);
}
function setDirty(on){
  if (on) on = (ciSnap() !== _snap);           // 되돌려 같아졌으면 끈다
  else _snap = ciSnap();                         // 불러온 직후·저장 직후 = 기준값
  _dirty = on; $('ciDirty').hidden = !on;
}

/* ── 예/아니오 두 칸 ─────────────────────────────────────── */
function ynInit(){
  document.querySelectorAll('.yn').forEach(function(el){
    el.innerHTML = '<button type="button" data-v="Y">✓ 예</button><button type="button" data-v="N" class="no">✕ 아니오</button>';
    el.addEventListener('click', function(e){
      var b = e.target.closest('button'); if(!b) return;
      ynSet(el, b.getAttribute('data-v')); setDirty(true);
    });
  });
}
function ynSet(el, v){ el.setAttribute('data-val', v === 'Y' ? 'Y' : 'N');
  el.querySelectorAll('button').forEach(function(b){ b.classList.toggle('on', b.getAttribute('data-v') === el.getAttribute('data-val')); }); }
function ynGet(el){ return el.getAttribute('data-val') || 'N'; }

/* 설정 칸 = data-f(기능) · data-p(웹 인쇄) · data-a(앱 인쇄) */
function setFill(sec, attr, vals){
  document.querySelectorAll('[' + attr + ']').forEach(function(el){
    var k = el.getAttribute(attr), v = vals[k];
    if (el.classList.contains('yn')) ynSet(el, v);
    else el.value = (v == null ? '' : v);
  });
}
function setRead(attr, def){
  var o = {};
  document.querySelectorAll('[' + attr + ']').forEach(function(el){
    var k = el.getAttribute(attr), v;
    if (el.classList.contains('yn')) v = ynGet(el);
    else if (el.type === 'number') { v = el.value === '' ? def[k] : Number(el.value); }
    else v = el.value;
    o[k] = v;
  });
  return o;
}

/* ── 불러오기 ───────────────────────────────────────────── */
function ciLoad(ask){
  if (ask && _dirty) {
    _confirmBox({ msg:'저장하지 않은 변경이 있습니다.<br>서버 값으로 다시 불러올까요?', icon:'↻', okText:'다시 불러오기', okColor:'blue', onOk:function(){ ciLoad(false); } });
    return;
  }
  post('/user/compInfoGet.do', '').then(function(t){
    var r = JSON.parse(t || '{}');
    if (r.error) { _alertBox(esc(r.error), {icon:'⚠️'}); return; }
    _info = r.info || {}; _bank = r.bank || []; _card = r.card || [];
    INFO_F.forEach(function(k){
      var el = $(k); if (!el || k === 'bankAcct') return;
      el.value = (k === 'foundDt' || k === 'ceoBirth') ? ymdToIn(_info[k]) : (_info[k] == null ? '' : _info[k]);
    });
    bankSelFill(_info.bankAcct || '');
    var raw = {}; try { raw = _info.setJson ? JSON.parse(_info.setJson) : {}; } catch(e) { raw = {}; }
    var S = konetSet.build(raw);
    setFill('func', 'data-f', S.func); setFill('prt', 'data-p', S.prt); setFill('app', 'data-a', S.prtApp);
    stampShow(_info.stampImg || '');
    setDirty(false);
  }).catch(function(e){ _alertBox('불러오지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); });
}

/* ── 저장 ───────────────────────────────────────────────── */
function fmtBiz(v){ var d = String(v||'').replace(/\D/g,''); return d.length === 10 ? d.substr(0,3)+'-'+d.substr(3,2)+'-'+d.substr(5) : v; }
function fmtCorp(v){ var d = String(v||'').replace(/\D/g,''); return d.length === 13 ? d.substr(0,6)+'-'+d.substr(6) : v; }
function fmtTel(v){
  var s = String(v||''); if (/[^\d]/.test(s.replace(/-/g,''))) return s;   // 숫자·- 말고 다른 글자가 있으면 손대지 않는다
  var d = s.replace(/\D/g,'');
  if (/^02\d{7,8}$/.test(d)) return d.length === 9 ? '02-'+d.substr(2,3)+'-'+d.substr(5) : '02-'+d.substr(2,4)+'-'+d.substr(6);
  if (d.length === 11) return d.substr(0,3)+'-'+d.substr(3,4)+'-'+d.substr(7);
  if (d.length === 10) return d.substr(0,3)+'-'+d.substr(3,3)+'-'+d.substr(6);
  if (d.length === 8)  return d.substr(0,4)+'-'+d.substr(4);
  return s;
}
function ciSave(){
  var info = {};
  INFO_F.forEach(function(k){ var el = $(k); info[k] = el ? String(el.value || '').trim() : ''; });
  document.querySelectorAll('.fld.bad').forEach(function(f){ f.classList.remove('bad'); });
  var miss = [];
  [['compNm','회사명'],['compCeo','대표자명'],['busiNum','사업자번호']].forEach(function(a){
    if (!info[a[0]]) { miss.push(a[1]); $(a[0]).closest('.fld').classList.add('bad'); } });
  // 칸이 다른 탭에 숨어 있으면 그 탭을 먼저 연다 — 안 그러면 무엇이 빠졌는지 안 보인다
  if (miss.length) { ciTabShow('info'); _alertBox('<b>' + miss.join(' · ') + '</b> 을(를) 넣어 주세요.', {icon:'⚠️'}); $( (miss[0]==='회사명'?'compNm':miss[0]==='대표자명'?'compCeo':'busiNum') ).focus(); return; }
  if (info.compEmail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(info.compEmail)) {
    ciTabShow('info'); $('compEmail').closest('.fld').classList.add('bad'); _alertBox('이메일 형식을 확인해 주세요.', {icon:'⚠️'}); return; }
  var D = konetSet.DEF;
  var func = setRead('data-f', D.func), prt = setRead('data-p', D.prt), app = setRead('data-a', D.prtApp);
  var r = Number(func.venDcRate); func.venDcRate = isFinite(r) ? Math.max(0, Math.min(100, r)) : 0;
  var rows = Number(prt.rows); prt.rows = isFinite(rows) ? Math.max(3, Math.min(40, Math.round(rows))) : D.prt.rows;
  var raw = {}; try { raw = _info.setJson ? JSON.parse(_info.setJson) : {}; } catch(e) {}
  raw.func = func; raw.prt = prt; raw.prtApp = app;      // 모르는 덩어리가 있으면 그대로 둔다
  $('ciSaveBtn').disabled = true; $('ciSaveBtn').textContent = '⏳ 저장 중…';
  post('/user/compInfoSave.do', { info: info, set: raw }, true).then(function(){
    _toast('저장했습니다', 'success');
    // 로컬에 적어 둔 거래명세표 인쇄 조건은 회사 값에 자리를 내준다 — 안 지우면 그 PC 만 옛 조건으로 뜬다
    try { localStorage.removeItem('konetSalesPrt1'); } catch(e) {}
    ciLoad(false);
  }).catch(function(e){ _alertBox('저장하지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); })
    .then(function(){ $('ciSaveBtn').disabled = false; $('ciSaveBtn').textContent = '💾 저장'; });
}

/* ── 우편번호 ───────────────────────────────────────────── */
function ciZip(){
  if (!window.daum || !daum.Postcode) { _alertBox('주소 검색을 불러오지 못했습니다. 주소를 직접 적어 주세요.', {icon:'⚠️'}); return; }
  new daum.Postcode({ oncomplete: function(d){
    var addr = d.userSelectedType === 'R' ? d.roadAddress : d.jibunAddress, ex = '';
    if (d.userSelectedType === 'R') {
      if (d.bname && /[동로가]$/.test(d.bname)) ex += d.bname;
      if (d.buildingName && d.apartment === 'Y') ex += (ex ? ', ' : '') + d.buildingName;
      if (ex) ex = ' (' + ex + ')';
    }
    $('zipCd').value = d.zonecode; $('compAddr').value = addr + ex; $('compExtradr').focus(); setDirty(true);
  } }).open();
}

/* ── ② 도장 ─────────────────────────────────────────────── */
function stampShow(src){
  _stamp = src || '';
  $('stampBox').innerHTML = _stamp ? '<img alt="도장" src="' + esc(_stamp) + '">' : '없음';
  $('stampDel').disabled = !_stamp;
}
function ciStampPick(inp){
  var f = inp.files && inp.files[0]; inp.value = '';
  if (!f) return;
  if (!/^image\/(png|jpeg|gif|webp)$/.test(f.type)) { _alertBox('그림 파일(png·jpg·gif·webp)만 올릴 수 있습니다.', {icon:'⚠️'}); return; }
  var rd = new FileReader();
  rd.onload = function(){
    var im = new Image();
    im.onload = function(){
      var M = 300, sc = Math.min(1, M / Math.max(im.width, im.height));
      var c = document.createElement('canvas'); c.width = Math.max(1, Math.round(im.width * sc)); c.height = Math.max(1, Math.round(im.height * sc));
      c.getContext('2d').drawImage(im, 0, 0, c.width, c.height);
      var url = c.toDataURL('image/png');                 // 투명 배경을 살리려고 PNG 로
      post('/user/compStampSave.do', 'stampImg=' + encodeURIComponent(url)).then(function(){
        stampShow(url); _toast('도장을 저장했습니다', 'success');
      }).catch(function(e){ _alertBox('도장을 저장하지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); });
    };
    im.onerror = function(){ _alertBox('그림을 읽지 못했습니다.', {icon:'⚠️'}); };
    im.src = rd.result;
  };
  rd.readAsDataURL(f);
}
function ciStampDel(){
  _confirmBox({ msg:'도장을 지울까요?<br><small>거래명세서에 더 이상 찍히지 않습니다.</small>', icon:'🗑', okText:'지우기', onOk:function(){
    post('/user/compStampSave.do', 'stampImg=').then(function(){ stampShow(''); _toast('도장을 지웠습니다', 'info'); })
      .catch(function(e){ _alertBox('지우지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); });
  } });
}

/* ── 결제계좌 (은행계좌 목록에서 고른다) ─────────────────── */
function bankLine(b){ return [b.bankNm, b.acctNo, b.acctHolder].filter(function(x){ return x; }).join('/'); }
function bankSelFill(cur){
  var sel = $('bankAcct'), h = '<option value="">(선택 안 함 — 명세서 계좌 칸을 비움)</option>', found = false;
  _bank.forEach(function(b){ var v = bankLine(b); if (v === cur) found = true;
    h += '<option value="' + esc(v) + '">' + esc(v) + (b.aliasNm ? ' · ' + esc(b.aliasNm) : '') + '</option>'; });
  // 종전에 글자로 적어 둔 계좌(은행계좌 관리에 없는 값)도 그대로 살린다 — 지우면 명세서 계좌 칸이 조용히 빈다
  if (cur && !found) h += '<option value="' + esc(cur) + '">' + esc(cur) + ' (종전 입력값)</option>';
  sel.innerHTML = h; sel.value = cur || '';
}

/* ── 🏦 은행계좌 관리 ───────────────────────────────────── */
function ciPopClose(id){ $(id).classList.remove('on'); if (window.ddlHide) ddlHide(); }
function ciBankOpen(){ ciBankNew(); bankRows(); $('ciBankPop').classList.add('on'); setTimeout(function(){ $('bk_nm').focus(); }, 30); }
function bankRows(){
  var cur = $('bankAcct').value;
  $('bankRows').innerHTML = _bank.length ? _bank.map(function(b, i){
    var on = bankLine(b) === cur;
    return '<tr data-i="' + i + '"' + (_bankSel === b.bankSeq ? ' class="sel"' : '') + ' onclick="ciBankPick(' + i + ')">'
      + '<td class="c">' + (i + 1) + '</td><td>' + esc(b.bankNm) + '</td><td>' + esc(b.acctNo) + '</td><td>' + esc(b.acctHolder) + '</td><td>' + esc(b.aliasNm) + '</td>'
      + '<td class="c">' + (on ? '✅ 사용 중' : '<button class="btn sm" onclick="event.stopPropagation();ciBankUse(' + i + ')">결제계좌로</button>') + '</td></tr>';
  }).join('') : '<tr><td class="empty" colspan="6">등록된 계좌가 없습니다. 아래에 적고 [💾 계좌 저장]을 누르세요.</td></tr>';
}
function ciBankNew(){ _bankSel = null; ['bk_nm','bk_no','bk_holder','bk_alias'].forEach(function(k){ $(k).value = ''; });
  $('bk_holder').value = $('compNm').value || ''; $('bk_del').disabled = true; bankRows(); }
function ciBankPick(i){ var b = _bank[i]; _bankSel = b.bankSeq;
  $('bk_nm').value = b.bankNm || ''; $('bk_no').value = b.acctNo || ''; $('bk_holder').value = b.acctHolder || ''; $('bk_alias').value = b.aliasNm || '';
  $('bk_del').disabled = false; bankRows(); }
function ciBankUse(i){ var v = bankLine(_bank[i]); bankSelFill(v); setDirty(true); bankRows();
  _toast('결제계좌로 골랐습니다 — [💾 저장]을 눌러야 반영됩니다', 'info'); }
function bankReload(keep){
  return post('/user/compInfoGet.do', '').then(function(t){ var r = JSON.parse(t || '{}'); _bank = r.bank || []; _card = r.card || [];
    bankSelFill(keep); bankRows(); cardRows(); setDirty(true); });   // 결제계좌가 바뀌었는지 다시 견준다
}
function ciBankSave(){
  var body = { bankSeq: _bankSel || '', bankNm: $('bk_nm').value.trim(), acctNo: $('bk_no').value.trim(),
               acctHolder: $('bk_holder').value.trim(), aliasNm: $('bk_alias').value.trim() };
  if (!body.bankNm || !body.acctNo) { _alertBox('은행과 계좌번호를 넣어 주세요.', {icon:'⚠️'}); return; }
  var cur = $('bankAcct').value, old = _bankSel ? _bank.filter(function(b){ return b.bankSeq === _bankSel; })[0] : null;
  var wasUsed = old && bankLine(old) === cur;
  post('/user/compBankSave.do', body, true).then(function(){
    // 결제계좌로 쓰던 계좌를 고쳤으면 고친 값으로 따라가게 한다
    var keep = wasUsed ? bankLine(body) : cur;
    if (wasUsed) setDirty(true);
    _toast('계좌를 저장했습니다', 'success'); ciBankNew(); return bankReload(keep);
  }).catch(function(e){ _alertBox('저장하지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); });
}
function ciBankDel(){
  if (!_bankSel) return;
  var b = _bank.filter(function(x){ return x.bankSeq === _bankSel; })[0];
  var used = b && bankLine(b) === $('bankAcct').value;
  _confirmBox({ msg:'이 계좌를 지울까요?' + (used ? '<br><small>지금 결제계좌로 쓰고 있어, 저장하면 명세서 계좌 칸이 비워집니다.</small>' : ''), icon:'🗑', okText:'지우기',
    onOk:function(){
      post('/user/compBankDelete.do', 'bankSeq=' + encodeURIComponent(_bankSel)).then(function(){
        var keep = used ? '' : $('bankAcct').value; if (used) setDirty(true);
        _toast('지웠습니다', 'info'); ciBankNew(); return bankReload(keep);
      }).catch(function(e){ _alertBox('지우지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); });
    } });
}

/* ── 💳 카드 관리 ───────────────────────────────────────── */
function ciCardOpen(){ ciCardNew(); $('ciCardPop').classList.add('on'); setTimeout(function(){ $('cd_co').focus(); }, 30); }
function cardRows(){
  $('cardRows').innerHTML = _card.length ? _card.map(function(c, i){
    return '<tr' + (_cardSel === c.cardSeq ? ' class="sel"' : '') + ' onclick="ciCardPick(' + i + ')"><td class="c">' + (i + 1) + '</td><td>' + esc(c.cardCo) + '</td><td>' + esc(c.cardNm)
      + '</td><td class="c">' + (c.cardLast4 ? '•••• ' + esc(c.cardLast4) : '—') + '</td><td>' + esc(c.cardUser) + '</td><td class="c">' + esc(c.cardGb) + '</td><td>' + esc(c.remark) + '</td></tr>';
  }).join('') : '<tr><td class="empty" colspan="7">등록된 카드가 없습니다.</td></tr>';
}
function ciCardNew(){ _cardSel = null; ['cd_co','cd_nm','cd_l4','cd_user','cd_rmk'].forEach(function(k){ $(k).value = ''; }); $('cd_gb').value = '법인';
  $('cd_del').disabled = true; cardRows(); }
function ciCardPick(i){ var c = _card[i]; _cardSel = c.cardSeq;
  $('cd_co').value = c.cardCo || ''; $('cd_nm').value = c.cardNm || ''; $('cd_l4').value = c.cardLast4 || ''; $('cd_user').value = c.cardUser || '';
  $('cd_gb').value = c.cardGb || '법인'; $('cd_rmk').value = c.remark || ''; $('cd_del').disabled = false; cardRows(); }
function ciCardSave(){
  var l4 = $('cd_l4').value.replace(/\D/g,'');
  if ($('cd_l4').value && l4.length !== 4) { _alertBox('카드번호는 <b>뒤 4자리</b>만 숫자로 적어 주세요.', {icon:'⚠️'}); return; }
  var body = { cardSeq: _cardSel || '', cardCo: $('cd_co').value.trim(), cardNm: $('cd_nm').value.trim(), cardLast4: l4,
               cardUser: $('cd_user').value.trim(), cardGb: $('cd_gb').value, remark: $('cd_rmk').value.trim() };
  if (!body.cardCo && !body.cardNm) { _alertBox('카드사나 카드 이름을 넣어 주세요.', {icon:'⚠️'}); return; }
  post('/user/compCardSave.do', body, true).then(function(){ _toast('카드를 저장했습니다', 'success'); ciCardNew(); return bankReload($('bankAcct').value); })
    .catch(function(e){ _alertBox('저장하지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); });
}
function ciCardDel(){
  if (!_cardSel) return;
  _confirmBox({ msg:'이 카드를 지울까요?', icon:'🗑', okText:'지우기', onOk:function(){
    post('/user/compCardDelete.do', 'cardSeq=' + encodeURIComponent(_cardSel)).then(function(){ _toast('지웠습니다', 'info'); ciCardNew(); return bankReload($('bankAcct').value); })
      .catch(function(e){ _alertBox('지우지 못했습니다.<br><small>' + esc(e.message) + '</small>', {icon:'❌', okColor:'red'}); });
  } });
}

/* ── 은행·카드사 고르기 목록 (2026-09-11 「은행 목록 주어서 스크롤」) ────────────────
     칸을 누르면 전체 목록이 스크롤 상자로 뜬다 · 치면 걸러진다 · ↑↓·Enter·Esc · 목록에 없는 이름도 그대로 쓸 수 있다. */
var DDL = {
  BANKS: ['국민은행','신한은행','우리은행','하나은행','농협은행','기업은행','SC제일은행','씨티은행','카카오뱅크','토스뱅크','케이뱅크',
          '수협은행','대구은행(iM뱅크)','부산은행','경남은행','광주은행','전북은행','제주은행','산업은행','새마을금고','신협','우체국','저축은행'],
  CARDCOS: ['신한카드','삼성카드','KB국민카드','현대카드','롯데카드','하나카드','우리카드','BC카드','NH농협카드','IBK기업카드','씨티카드','카카오뱅크카드']
};
var _ddl = null, _ddlInp = null, _ddlIdx = -1;
function ddlShow(inp, all){
  _ddlInp = inp;
  var q = all ? '' : String(inp.value || '').trim().toLowerCase();
  var l = (DDL[inp.getAttribute('data-ddl')] || []).filter(function(x){ return !q || x.toLowerCase().indexOf(q) >= 0; });
  if (!_ddl) {
    _ddl = document.createElement('div'); _ddl.className = 'ci-ddl'; document.body.appendChild(_ddl);
    _ddl.addEventListener('mousedown', function(e){
      e.preventDefault();                                  // 칸의 blur 보다 먼저 고른다
      var d = e.target.closest('div[data-v]'); if (d) ddlPick(d.getAttribute('data-v'));
    });
  }
  _ddlIdx = -1;
  _ddl.innerHTML = l.length ? l.map(function(x){ return '<div data-v="' + esc(x) + '">' + esc(x) + '</div>'; }).join('')
                            : '<div class="none">목록에 없음 — 친 이름 그대로 씁니다</div>';
  var r = inp.getBoundingClientRect();
  _ddl.style.left = r.left + 'px'; _ddl.style.width = Math.max(r.width, 180) + 'px';
  var below = window.innerHeight - r.bottom;
  if (below < 200 && r.top > below) { _ddl.style.top = ''; _ddl.style.bottom = (window.innerHeight - r.top + 2) + 'px'; }
  else { _ddl.style.bottom = ''; _ddl.style.top = (r.bottom + 2) + 'px'; }
  _ddl.style.display = 'block';
}
function ddlHide(){ if (_ddl) _ddl.style.display = 'none'; _ddlInp = null; }
function ddlPick(v){ if (_ddlInp) { _ddlInp.value = v; var nx = _ddlInp; ddlHide(); nx.dispatchEvent(new Event('input', {bubbles:true})); } }
function ddlMove(d){
  if (!_ddl) return;
  var it = _ddl.querySelectorAll('div[data-v]'); if (!it.length) return;
  _ddlIdx = Math.max(0, Math.min(it.length - 1, _ddlIdx + d));
  it.forEach(function(x, i){ x.classList.toggle('on', i === _ddlIdx); });
  it[_ddlIdx].scrollIntoView({ block:'nearest' });
}
document.querySelectorAll('input[data-ddl]').forEach(function(inp){
  inp.addEventListener('click', function(){ ddlShow(inp, true); });
  inp.addEventListener('focus', function(){ ddlShow(inp, true); });
  inp.addEventListener('input', function(e){ if (e.isTrusted) ddlShow(inp, false); });
  inp.addEventListener('blur', function(){ setTimeout(function(){ if (_ddlInp === inp) ddlHide(); }, 120); });
  inp.addEventListener('keydown', function(e){
    if (!_ddl || _ddl.style.display === 'none') return;
    if (e.key === 'ArrowDown') { e.preventDefault(); ddlMove(1); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); ddlMove(-1); }
    else if (e.key === 'Enter') { var on = _ddl.querySelector('div.on'); if (on) { e.preventDefault(); ddlPick(on.getAttribute('data-v')); } }
    else if (e.key === 'Escape') { e.stopPropagation(); ddlHide(); }
  });
});
document.querySelectorAll('.ci-pop .bd').forEach(function(b){ b.addEventListener('scroll', ddlHide); });

/* ── 탭 (2026-09-11) — ①②③ = 그 덩어리만 · [전체] = 덩어리를 전부 이어서(아래로 스크롤). 고른 탭은 다음에도 그대로 ── */
function ciTab(t){
  if (!/^(all|info|stamp|prt)$/.test(t || '')) t = 'info';
  document.querySelectorAll('#ciTabs button').forEach(function(b){ b.classList.toggle('on', b.getAttribute('data-t') === t); });
  document.querySelectorAll('.card[data-tab]').forEach(function(c){ c.hidden = (t !== 'all' && c.getAttribute('data-tab') !== t); });
  try { localStorage.setItem('konetCompInfoTab', t); } catch(e) {}
  window.scrollTo(0, 0);
}
function ciTabShow(t){       // 그 덩어리가 지금 숨어 있을 때만 옮긴다([전체]면 그대로)
  var c = document.querySelector('.card[data-tab="' + t + '"]');
  if (c && c.hidden) ciTab(t);
}
document.getElementById('ciTabs').addEventListener('click', function(e){
  var b = e.target.closest('button'); if (b) ciTab(b.getAttribute('data-t'));
});
(function(){ var t = 'info'; try { t = localStorage.getItem('konetCompInfoTab') || 'info'; } catch(e) {} ciTab(t); })();

/* ── 시작 ───────────────────────────────────────────────── */
// 브라우저 자동완성이 회사 칸에 엉뚱한 값(내 이메일·전화 등)을 넣지 않게
document.querySelectorAll('.wrap input, .ci-pop input').forEach(function(el){ el.setAttribute('autocomplete', 'off'); });
ynInit();
document.addEventListener('input', function(e){ if (e.target.closest('.wrap')) setDirty(true); });
document.addEventListener('change', function(e){ if (e.target.closest('.wrap')) setDirty(true); });
document.addEventListener('blur', function(e){
  var el = e.target, f = el && el.getAttribute && el.getAttribute('data-fmt'); if (!f) return;
  var v = el.value, n = f === 'biz' ? fmtBiz(v) : f === 'corp' ? fmtCorp(v) : fmtTel(v);
  if (n !== v) el.value = n;
}, true);
document.addEventListener('keydown', function(e){
  if ((e.ctrlKey || e.metaKey) && (e.key === 's' || e.key === 'S')) {
    e.preventDefault();
    if ($('ciBankPop').classList.contains('on')) ciBankSave();
    else if ($('ciCardPop').classList.contains('on')) ciCardSave();
    else ciSave();
  } else if (e.key === 'Escape' && !e.isComposing) {
    ['ciBankPop','ciCardPop'].forEach(function(id){ $(id).classList.remove('on'); });
  }
});
/* ⚠beforeunload(「사이트에서 나가시겠습니까?」)는 쓰지 않는다 — 브라우저 기본 창이라 모양을 못 바꾼다
     (알림·확인은 ui-message.js 만 — 2026-09-11 지적). 저장 안 한 변경은 위 「● 저장 안 한 변경」 표시로만 알린다. */
if (window.konetPopDrag) konetPopDrag('.ci-pop');
ciLoad(false);
</script>
</body>
</html>
