/* ============================================================================
   회사 설정 (기준정보관리 ▸ 회사 정보 수정 의 「기능」·「거래명세서 인쇄 옵션」) — 2026-09-11
   · 화면마다 <script src=".../asset/js/comp-set.js?v=..."> 한 줄이면 window.konetSet 이 선다.
   · ★기본값은 이 파일 DEF 한 곳뿐이다 — 회사 정보 수정 화면도 이 값을 쓴다.
     기본값 = 설정이 생기기 전의 <종전 동작> 그대로(아무도 설정을 안 건드리면 아무것도 안 바뀐다).
   · ★읽기는 <동기> 요청 한 번(작은 JSON). 화면이 처음 그릴 때부터 설정대로여야 해서 기다리지 않는다.
     실패하면(로그인 끊김 등) 조용히 기본값으로 돈다.
   · 저장은 회사 정보 수정 화면(/user/compInfoSave.do) 또는 한 덩어리만 /user/compSetPatch.do.
   ============================================================================ */
(function (w) {
  var DEF = {
    func: {
      venVat: '별도',        // 거래처 기본 과세 유형 (새 거래처 · 값 빈 거래처)  별도/포함/면세
      venDcYn: 'N',          // 거래처 DC 사용 (새 거래처 기본값)
      venDcRate: 0,          // 기본 DC율 % (새 거래처 기본값)
      prodTax: '과세',       // 상품 기본 과세 유형 (새 상품)  과세/면세
      priceDec: 'Y',         // 단가 소수점 사용 (종전 = 소수 2자리)
      qtyDec: 'N',           // 수량 소수점 사용 (종전 = 정수)
      svcFld: 'Y',           // 서비스 칸 보이기
      rmkFld: 'Y',           // 비고 칸 보이기
      badRtn: 'N',           // 불량 반품 사용 (거래구분에 「불량반품」 — 판매는 재고로 안 돌아간다)
      stockLimit: 'N',       // 매출 재고 부족 제한
      creditLimit: 'N',      // 매출 여신 초과 제한
      parcelFeeDef: 4500,    // 기본 택배 운임(원) — 사업장에 운임이 없을 때. 택배출고관리 종이·비용 등록 자동 운임이 같이 쓴다 (2026-09-16 P2-e, 종전 4500 하드코딩)
      safeWindow: 90,        // 적정재고 자동 산출 — 최근 며칠 출고로 일평균을 내나 (2026-09-17, 품목별재고현황 [🧮 적정재고 산출])
      safeLeadDays: 7,       // 적정재고 자동 산출 — 리드타임(일)
      safeBufDays: 7,        // 적정재고 자동 산출 — 안전일수(일). 적정 = 일평균 × (리드타임 + 안전일수), 입수 배수 올림
      safeMinDays: 5,        // 적정재고 자동 산출 — 기간 안 출고 일수가 이보다 적으면 「간헐」(제안 안 함)
      rcvPayGb: '무통장입금', // 수금 기본 유형
      dueWarn: 30,           // 미수 경과 경고(⚠) 기준일 — 거래처별 채권·채무 「미수 경과」·「N일 넘긴 것만」 (2026-09-16)
      dueBad: 60,            // 미수 경과 위험(⛔) 기준일 (경고보다 작으면 경고 일수로 맞춘다)
      inPriceAuto: 'Y',      // 입고(매입 저장) 시 상품 매입단가 자동 갱신 (종전 = 늘 갱신)
      inPriceAvg: 'N',       // 갱신할 때 평균 매입단가를 쓴다 (N = 이번 매입단가)
      avgZero: 'Y',          // 평균 매입단가 산출 시 금액 0 거래 포함 (종전 = 포함)
      taxItemNm: '',         // 세금계산서 대표 상품명
      taxIssueGb: '매출 기준' // 세금계산서 기본 발행 기준
    },
    // 거래명세서 인쇄 옵션 (웹) — 판매등록 조건 창의 첫 값. 키는 salesReg SAPRT_DEF 와 같다(+새 칸 4개)
    prt: { ord: 'in', amt: 'Y', price: 'Y', bal: 'N', inv: 'N', boxp: 'N', chg: 'N', vat: 'N', rows: 10, mode: 'both',
           bc: 'N', rtn: 'N', shade: 'N', ptime: 'Y' },   // 인쇄일시는 종전에 늘 찍었다 → 기본 Y
    // 거래명세서 인쇄 옵션 (모바일 앱)
    prtApp: { bc: 'N', bcType: '문자', price: 'Y', vat: 'N', bal: 'N', sign: 'N' },
    // 원가·마진 계산 (2026-09-17, 견적서관리 ▸ 원가·마진 계산) — 센터별 물류비율(%)·보관/개 기본식(보관료 × 팔레트 × 개월 ÷ MOQ 수량). 표본 오택현.xls
    cost: { centers: [ { nm: '평/용센터', rate: 10.5 }, { nm: '왜관센터', rate: 15.1 }, { nm: '광주센터', rate: 14.6 }, { nm: '김해센터', rate: 16.1 }, { nm: '제주센터', rate: 18.1 } ],
            storeFee: 25000, storePlt: 3, storeMon: 3, moqBoxDef: 100 }   // moqBoxDef = MOQ 수량 기본 박스 수 (표본 D11 = 100 × 입수)
  };

  function merge(def, v) {
    var o = {}, k;
    for (k in def) o[k] = def[k];
    if (v && typeof v === 'object') for (k in v) if (v[k] !== null && v[k] !== undefined && v[k] !== '') o[k] = v[k];
    return o;
  }
  function ctx() {                       // 제 <script src> 에서 컨텍스트 경로를 뽑는다(send-hist.js 와 같은 방식)
    var ss = document.getElementsByTagName('script');
    for (var i = ss.length - 1; i >= 0; i--) {
      var m = (ss[i].getAttribute('src') || '').match(/^(.*)\/asset\/js\/comp-set\.js/);
      if (m) return m[1];
    }
    return '';
  }
  function build(raw) {
    var s = raw || {};
    return { func: merge(DEF.func, s.func), prt: merge(DEF.prt, s.prt), prtApp: merge(DEF.prtApp, s.prtApp), cost: merge(DEF.cost, s.cost), _raw: s };
  }

  var CTX = ctx();
  /* 회사 설정 읽기 — 동기 XHR (아래 설명). 처음 로드 때 한 번, 그 뒤엔 셸(logiFrame)이 화면을 다시 보여 줄 때
     konetSetReload() 로 다시 읽는다 (2026-09-17 「데이터 수정 후 연관 조회 바로 안 됨」 — 회사 정보 수정에서 바꾼 설정이
     이미 떠 있는 판매·매입등록 등에 로그아웃 전까지 안 먹던 것). */
  function fetchRaw() {
    var out = { raw: null, loaded: false };
    try {
      var x = new XMLHttpRequest();
      x.open('POST', CTX + '/user/compSetGet.do', false);   // 동기 — 아래 설명
      x.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
      x.send('');
      if (x.status === 200 && x.responseText) {
        var r = JSON.parse(x.responseText);
        out.raw = r && r.setJson ? JSON.parse(r.setJson) : {};
        out.loaded = !!(r && 'setJson' in r);
      }
    } catch (e) { out.raw = null; }
    return out;
  }
  var first = fetchRaw();
  var S = build(first.raw);
  S.DEF = DEF;
  S.loaded = first.loaded;
  /* 다시 읽기 — 같은 객체 S 를 제자리에서 갱신한다. 화면들이 「var KS = window.konetSet」으로 잡아 둔 참조가 그대로 새 값을 본다.
     못 읽으면(세션 끊김 등) 갖고 있던 값을 지킨다. */
  S.reload = function () {
    var r = fetchRaw(); if (r.raw === null) return S;
    var B = build(r.raw); S.func = B.func; S.prt = B.prt; S.prtApp = B.prtApp; S.cost = B.cost; S._raw = B._raw; S.loaded = r.loaded; return S;
  };
  w.konetSetReload = function () { return S.reload(); };
  S.build = build;
  S.f = function (k) { return S.func[k]; };
  S.on = function (k) { return String(S.func[k]) === 'Y'; };
  w.konetSet = S;
})(window);
