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
      rcvPayGb: '무통장입금', // 수금 기본 유형
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
    prtApp: { bc: 'N', bcType: '문자', price: 'Y', vat: 'N', bal: 'N', sign: 'N' }
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
    return { func: merge(DEF.func, s.func), prt: merge(DEF.prt, s.prt), prtApp: merge(DEF.prtApp, s.prtApp), _raw: s };
  }

  var CTX = ctx(), raw = null, loaded = false;
  try {
    var x = new XMLHttpRequest();
    x.open('POST', CTX + '/user/compSetGet.do', false);   // 동기 — 아래 설명
    x.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    x.send('');
    if (x.status === 200 && x.responseText) {
      var r = JSON.parse(x.responseText);
      raw = r && r.setJson ? JSON.parse(r.setJson) : {};
      loaded = !!(r && 'setJson' in r);
    }
  } catch (e) { raw = null; }

  var S = build(raw);
  S.DEF = DEF;
  S.loaded = loaded;
  S.build = build;
  S.f = function (k) { return S.func[k]; };
  S.on = function (k) { return String(S.func[k]) === 'Y'; };
  w.konetSet = S;
})(window);
