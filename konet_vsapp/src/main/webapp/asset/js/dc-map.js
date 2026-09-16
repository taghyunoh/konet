/* 출고장(삼성웰스토리 물류센터) 코드 · 지역명 · 묶음(오산센터) · 거래처 — 화면 쪽 **단일 원천** (2026-09-16 P3 「삼성 판정 상수 통합」)
   · 종전엔 같은 표가 logi-oh.js(KONET_DC · SS_DCGROUP · SS_ZONEORDER) · 대시보드1(D2_DCGROUP · D2_ZONEORDER) ·
     셸 매출마감(CLOSE_DCGROUP) · 채권·채무(CB_DC · CB_DCGROUP) · 거래처관리(DC_MAP) 다섯 군데에 따로 박혀 있었다.
     센터가 늘거나 묶음이 바뀌면 다섯 곳을 다 고쳐야 했고 하나만 빠져도 화면마다 다르게 묶였다.
   · 이제 그 다섯 변수는 이 파일의 **같은 객체를 가리킨다**(참조) — 서버(TBL_DC_MST, /shipout/dcList.do)에서 표를 받으면
     객체를 «제자리에서» 갈아 채우므로 먼저 만든 변수도 새 값을 본다. 서버가 없거나(옛 서버) 표가 비면 아래 기본값(DEF)으로 간다.
   · ⚠매퍼 SQL 의 이름→코드 규칙(<sql id="dcKeyOf">, User_SQL.xml 머리)은 여기와 짝이다 — 센터를 더하면 TBL_DC_MST 씨앗 + 그 조각.
   · 쓰는 법 : <script src=".../asset/js/dc-map.js"> 를 그 표를 쓰는 스크립트보다 먼저.
       konetDc.NAME   {E100:'용인',…}        코드→지역명          konetDc.NAME_R {'용인':'E100',…}  지역명→코드
       konetDc.GROUP  {E200:'오산센터',…}    묶음(단독은 없음)     konetDc.ORDER  ['E100','E500','E200',…] 표시 차례
       konetDc.VENDOR_TO_DC {'00273':'E100',…}  거래처→코드       konetDc.list   [{cd,nm,grp,ven,ord}] 원본
       konetDc.grpOf(cd, nm) → 묶음 이름(없으면 지역명·이름 그대로)  */
(function (w) {
  var DEF = [
    { cd:'E100', nm:'용인', grp:'',        ven:'00273', ord:10 },
    { cd:'E500', nm:'평택', grp:'',        ven:'00272', ord:20 },
    { cd:'E200', nm:'왜관', grp:'오산센터', ven:'00275', ord:30 },
    { cd:'E400', nm:'광주', grp:'오산센터', ven:'00276', ord:40 },
    { cd:'E300', nm:'김해', grp:'오산센터', ven:'00274', ord:50 },
    { cd:'E600', nm:'제주', grp:'오산센터', ven:'00277', ord:60 },
    { cd:'E700', nm:'오산', grp:'오산센터', ven:'00278', ord:70 }
  ];
  var D = w.konetDc = w.konetDc || { list:[], NAME:{}, NAME_R:{}, GROUP:{}, VENDOR_TO_DC:{}, ORDER:[], loaded:false };
  function clearObj(o){ for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) delete o[k]; }
  /* 표를 제자리에서 갈아 채운다 — 다른 파일이 들고 있는 참조(SS_DCGROUP 등)가 그대로 새 값을 보게 */
  function apply(list) {
    var l = (list || []).filter(function (r) { return r && r.cd; }).map(function (r) {
      return { cd: String(r.cd).trim().toUpperCase(), nm: String(r.nm || '').trim(), grp: String(r.grp || '').trim(), ven: String(r.ven || '').trim(), ord: Number(r.ord) || 0 };
    }).sort(function (a, b) { return a.ord - b.ord || (a.cd < b.cd ? -1 : 1); });
    if (!l.length) return;
    D.list.length = 0; clearObj(D.NAME); clearObj(D.NAME_R); clearObj(D.GROUP); clearObj(D.VENDOR_TO_DC); D.ORDER.length = 0;
    l.forEach(function (r) {
      D.list.push(r); D.NAME[r.cd] = r.nm; if (r.nm) D.NAME_R[r.nm] = r.cd;
      if (r.grp) D.GROUP[r.cd] = r.grp;
      if (r.ven) D.VENDOR_TO_DC[r.ven] = r.cd;
      D.ORDER.push(r.cd);
    });
  }
  D.apply = apply;
  /* 묶음 이름 — 코드로 못 찾으면 이름에 지역명이 들어 있는지 본다(발주현황표 옛 양식은 코드가 없다) */
  D.grpOf = function (cd, nm) {
    cd = String(cd || '').trim().toUpperCase(); nm = String(nm || '');
    if (cd && D.GROUP[cd]) return D.GROUP[cd];
    if (cd && D.NAME[cd]) return D.NAME[cd];
    for (var i = 0; i < D.list.length; i++) if (D.list[i].nm && nm.indexOf(D.list[i].nm) >= 0) return D.list[i].grp || D.list[i].nm;
    return nm;
  };
  D.cdOfNm = function (nm) { nm = String(nm || ''); for (var i = 0; i < D.list.length; i++) if (D.list[i].nm && nm.indexOf(D.list[i].nm) >= 0) return D.list[i].cd; return ''; };
  function ctx() {                       // 제 <script src> 에서 컨텍스트 경로를 뽑는다(comp-set.js 와 같은 방식)
    var s = document.currentScript || (function () { var a = document.getElementsByTagName('script'); for (var i = a.length - 1; i >= 0; i--) if (/dc-map\.js/.test(a[i].src || '')) return a[i]; return null; })();
    var src = s ? (s.getAttribute('src') || '') : ''; var i = src.indexOf('/asset/');
    return i >= 0 ? src.slice(0, i) : '';
  }
  D.load = function () {
    if (!w.fetch) return;
    fetch(ctx() + '/shipout/dcList.do', { method:'POST', credentials:'same-origin', headers:{ 'Content-Type':'application/x-www-form-urlencoded' }, body:'' })
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (j) { if (j && j.data && j.data.length) { apply(j.data); D.loaded = true; } })
      .catch(function () {});            // 옛 서버·표 없음 → 기본값 그대로
  };
  apply(DEF);
  D.load();
})(window);
