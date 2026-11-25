/* 재고 일괄조정 — 해당코드 조정이력의 「변동 ±d → n」 시뮬 (2026-11-25)
   stockAdj.jsp 의 adjRunCalc · adjRunGet · adjRunPill · adjRunRow 를 꺼내 가짜 fetch 로 돌린다(jsdom 불필요).
   쓰는 법 : node docs/tools/sim/sim_stockAdjRun.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
const jsp = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/prod/stockAdj.jsp'), 'utf8').replace(/\r\n/g, '\n');
let ok = 0, bad = 0;
function t(name, cond, info){ if (cond) ok++; else { bad++; console.log('✗ ' + name + (info !== undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const a = jsp.indexOf('var _adjRun = {};'), b = jsp.indexOf('function hisLoad(quiet, keepCache){', a);
if (a < 0 || b < 0) { console.log('✗ 함수 자리를 못 찾음'); process.exit(1); }
const code = jsp.slice(a, b);
const txt = (h) => String(h).replace(/<[^>]+>/g, '|').replace(/\|+/g, '|');

function make(led, o){
  o = o || {};
  const env = { calls: [], now: 9000000, led, selPaints: 0, hisPaints: 0, filt: o.filt !== false, off: !!o.off };
  const fetch = (url, opt) => {
    if (/prodDelPurchList\.do$/.test(url)) { (env.dcalls = env.dcalls || []).push({ url, body: opt && opt.body });   /* 지운 전표(2026-11-25) — 따로 센다 */
      if (env.del === 'fail') return Promise.resolve({ ok: false, status: 404, json: () => Promise.reject(new Error('x')) });
      return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve({ result: 'OK', data: env.del || [], sales: env.dsales || [] }) }); }
    env.calls.push({ url, body: opt && opt.body });
    if (env.led === 'fail') return Promise.resolve({ ok: false, status: 404, json: () => Promise.reject(new Error('x')) });
    return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve({ data: env.led }) }); };
  const f = new Function('fetch', 'Date', 'CTX', 'gel', 'hisSelPaint', 'hisPaint', 'hisFilt',
    'function esc(v){ return String(v == null ? "" : v).replace(/&/g, "&amp;").replace(/</g, "&lt;"); }' + code + '; return { calc: adjRunCalc, get: adjRunGet, pill: adjRunPill, row: adjRunRow, reset: function(){ _adjRun = {}; } };');
  env.api = f(fetch, { now: () => env.now }, '/konet', () => ({ classList: { contains: () => env.off } }), () => { env.selPaints++; }, () => { env.hisPaints++; }, () => (env.filt ? { prodSeq: 5 } : null));
  return env;
}
/* 운영 1000727644 모양 — 조정 「전 0 → 수정재고 2」인데 지금 장부로는 조정 직후 3 */
const LED = () => [ { ledgerSeq: 40, ioGb: 'O', qty: 1, trxDt: '20261012', srcDttm: '2026-10-11 13:53:13' }, { ledgerSeq: 39, ioGb: 'I', qty: 36, trxDt: '20261007' },
                    { ledgerSeq: 38, ioGb: 'O', qty: 2, trxDt: '20261003', srcDttm: '2026-10-02 10:24:12' }, { ledgerSeq: 37, ioGb: 'O', qty: 2, trxDt: '20261002', srcDttm: '2026-09-30 15:45:06' },
                    { ledgerSeq: 36, ioGb: 'A', qty: 2, adjBef: 0, adjAft: 2, trxDt: '20261002', regDttm: '2026-10-02 16:59:27' }, { ledgerSeq: 30, ioGb: 'I', qty: 5, trxDt: '20260901' } ];

(async () => {
  {
    const e = make(LED());
    const m = e.api.calc(LED());
    t('셈 — 지금 장부로 조정 직후 3 · 수정재고 2 · 전 0 · 현재고 38 · 최근 조정 줄 36', m.base === 3 && m.aft === 2 && m.bef === 0 && m.tot === 38 && m.adjSeq === '36' && m.dq === 2, JSON.stringify(m));
    t('조정이 없는 원장은 셈 없음', e.api.calc(LED().filter(x => x.ioGb !== 'A')) === null && e.api.calc([]) === null);
    t('처음 물으면 아직 없음 — 원장을 한 번 읽는다(prodSeq)', e.api.get(5) === null && e.calls.length === 1 && e.calls[0].url === '/konet/prod/stockList.do' && e.calls[0].body === 'prodSeq=5');
    await sleep(10);
    t('오면 탭 이름과 이력 표를 다시 그린다', e.selPaints === 1 && e.hisPaints === 1 && e.api.get(5).base === 3 && e.calls.length === 1);
    const p = e.api.pill(e.api.get(5));
    t('★알약 — 「변동 +1 → 3」', txt(p) === '|변동 +1 → 3|' && /class="led-now"/.test(p), txt(p));
    t('말풍선 — 세 줄(맞췄는데 지금은 n · 까닭 · 할 일)', /재고조정으로 2 에 맞췄는데, 지금은 3 입니다 \(재고가 1 늘었습니다\)/.test(p) && /조정한 뒤에 그 앞 날짜의 입고·출고가 바뀐 것입니다/.test(p) && /실물과 다르면 다시 조정하세요/.test(p) && (p.match(/&#10;/g) || []).length === 2, p);
    t('이력 표 — 최근 조정 줄(원장 줄 36)에만 붙는다', /변동 \+1 → 3/.test(e.api.row({ prodSeq: 5, ledgerSeq: 36 })) && e.api.row({ prodSeq: 5, ledgerSeq: 20 }) === '' && e.api.row({ prodSeq: 5 }) === '');
    e.now += 30000; e.api.get(5);
    t('60초 안에는 다시 묻지 않는다', e.calls.length === 1);
    e.now += 31000; e.api.get(5); await sleep(10);
    t('60초 뒤엔 다시 묻는다 · 값이 같으면 다시 그리지 않는다', e.calls.length === 2 && e.selPaints === 1);
    e.api.reset(); e.api.get(5);
    t('저장·되돌리기 뒤(받아 둔 것 버림)에는 다시 묻는다', e.calls.length === 3);
  }
  {
    /* 맞아 있는 보통 경우 — 처음 입고가 4 였다면 조정 직후 2 = 수정재고 */
    const L2 = LED(); L2[5].qty = 4;
    const e = make(L2); e.api.get(7); await sleep(10);
    t('맞아 있으면 표시 없음', e.api.pill(e.api.get(7)) === '' && e.api.row({ prodSeq: 7, ledgerSeq: 36 }) === '', JSON.stringify(e.api.get(7)));
    /* 줄어든 경우 (운영 1000808776 : 116 → 11) */
    const e2 = make([ { ledgerSeq: 18, ioGb: 'O', qty: 2, trxDt: '20261120', srcDttm: '2026-11-19 08:48:33' }, { ledgerSeq: 17, ioGb: 'O', qty: 4, trxDt: '20261118', srcDttm: '2026-11-17 08:50:07' },
                      { ledgerSeq: 16, ioGb: 'A', qty: 104, adjBef: 12, adjAft: 116, trxDt: '20261118', regDttm: '2026-11-18 09:55:29' }, { ledgerSeq: 10, ioGb: 'I', qty: 103, trxDt: '20261015' }, { ledgerSeq: 9, ioGb: 'O', qty: 192, trxDt: '20261001' } ]);
    e2.api.get(9); await sleep(10);
    const p2 = e2.api.pill(e2.api.get(9));
    t('줄어든 경우 — 「변동 -105 → 11」 · 「재고가 105 줄었습니다」', txt(p2) === '|변동 -105 → 11|' && /재고가 105 줄었습니다/.test(p2), txt(p2));
    const e3 = make('fail'); e3.api.get(5); await sleep(10);
    t('원장을 못 읽으면 표시 없음 · 60초 동안 다시 안 묻는다', e3.api.get(5) === null && e3.calls.length === 1 && e3.api.pill(null) === '');
    const e4 = make(LED(), { filt: false }); e4.api.get(5); await sleep(10);
    t('해당코드 탭을 안 보는 중이면 이력 표는 다시 그리지 않는다(탭 이름만)', e4.selPaints === 1 && e4.hisPaints === 0);
  }
  /* ── 말풍선의 「바뀐 줄(추정)」 줄 · 줄 밑 빨간 줄은 없다 · 지운 전표도 더는 안 묻는다 (2026-11-25 「그럼 빨간 표는 빼줘」 → 「말풍선의 바뀐 줄(추정)도 빼줘」) ── */
  {
    const L9 = LED().map(x => Object.assign({ prodCd: 'P5' }, x)); L9[2].regDttm = '2026-10-07 14:41:12';
    const e = make(L9); e.del = [ { purchSeq: 9, purchDt: '20260916', purchNo: '0002', qty: 105, delDttm: '2026-11-22 18:48:02' } ];
    e.api.get(5); await sleep(20);
    const p = e.api.pill(e.api.get(5));
    t('★말풍선 — 다시 만들어진 줄·지운 전표가 있어도 「바뀐 줄」 줄이 없다(세 줄)', /led-now/.test(p) && !/바뀐 줄|10-03 출고|09-16 입고/.test(p) && /바뀐 것입니다\.&#10;실물과 다르면 다시 조정하세요\./.test(p), (p.match(/title="[^"]*/) || [''])[0]);
    t('어긋난 상품이어도 지운 전표를 따로 묻지 않는다', !(e.dcalls || []).length && e.calls.length === 1, (e.dcalls || []).length);
    t('JSP — 줄 밑 빨간 줄(adjRunSub)·바뀐 줄 셈(m.chg)은 없다', !/adjRunSub\(/.test(jsp) && !/chgrow/.test(jsp) && !/m\.chg/.test(jsp) && !/prodDelPurchList/.test(jsp));
  }
  /* ── 수정재고 고정 (2026-11-25) — 조정 줄이 고정(adjFixYn='Y')이면 「변동」을 안 그린다 ── */
  {
    const Lf = LED().map(x => Object.assign({}, x)); Lf.forEach(x => { if (x.ioGb === 'A') x.adjFixYn = 'Y'; });
    const ef = make(Lf); ef.api.get(5); await sleep(10);
    t('고정된 조정 — 「변동」 없음', ef.api.pill(ef.api.get(5)) === '' && ef.api.get(5) && ef.api.get(5).fix === true);
    t('JSP — 고정된 조정은 알약을 안 그린다', /m\.base === m\.aft \|\| m\.fix/.test(jsp));
  }
  /* ── 목록 줄의 「변동」 (2026-11-25 「목록 줄에도 변동 표시 넣어줘」) — 서버가 한 번에 센 것을 상품명 옆에 ── */
  {
    const a2 = jsp.indexOf('var _drift = {'), b2 = jsp.indexOf('function hisLoad(quiet, keepCache){', a2);
    const mk = (resp, o) => { o = o || {}; const e = { calls: [], els: {}, filters: 0, resp };
      const gel = (id) => e.els[id] || (e.els[id] = { innerHTML: '', textContent: id === 'chgCnt' ? (o.chg || '0') : '', checked: id === 'driftOnly' ? !!o.only : false, classList: { contains: () => false } });
      const fetch = (url, opt) => { e.calls.push({ url, body: opt && opt.body });
        if (e.resp === 'fail') return Promise.resolve({ ok: false, status: 404, json: () => Promise.reject(new Error('x')) });
        return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(e.resp) }); };
      const ROWS = [ { prodSeq: 81, prodCd: '1000727644' }, { prodSeq: 99, prodCd: '9999' }, { prodSeq: 2057, prodCd: '1000808776' } ];
      e.api = new Function('fetch', 'Date', 'CTX', 'gel', 'hisSelPaint', 'hisPaint', 'hisFilt', 'ROWS', '_ALL', 'applyFilter',
        jsp.slice(a2, b2) + '; return { load: driftLoad, of: driftOf, paint: driftPaint, st: _drift, pill: adjRunPill };')(fetch, { now: () => 1 }, '/konet', gel, () => {}, () => {}, () => null, ROWS, ROWS, () => { e.filters++; });
      e.rows = ROWS; ROWS.forEach((r, i) => gel('dr' + i)); return e; };
    const DATA = { result: 'OK', data: [ { prodSeq: 81, prodCd: '1000727644', ledgerSeq: 2374712, adjDt: '20261002', adjBef: 0, adjAft: 2, adjQty: 2, curQty: 21, baseQty: 3 },
                                         { prodSeq: 2057, prodCd: '1000808776', ledgerSeq: 3125107, adjDt: '20261118', adjBef: 12, adjAft: 116, adjQty: 104, curQty: 4, baseQty: 11 } ] };
    const e = mk(DATA);
    t('받기 전 — 표시 없음', e.api.of(e.rows[0]) === null && e.api.pill(e.api.of(e.rows[0])) === '');
    e.api.load(); e.api.load(); await sleep(10);
    t('한 번만 묻는다(/prod/stockAdjDrift.do)', e.calls.length === 1 && e.calls[0].url === '/konet/prod/stockAdjDrift.do');
    t('★어긋난 줄의 상품명 옆에만 「변동」 — 1000727644 +1 → 3 · 1000808776 -105 → 11 · 다른 줄은 빈칸', txt(e.els.dr0.innerHTML) === '|변동 +1 → 3|' && e.els.dr1.innerHTML === '' && txt(e.els.dr2.innerHTML) === '|변동 -105 → 11|', [e.els.dr0.innerHTML, e.els.dr1.innerHTML].map(txt).join(' / '));
    t('조회줄 「변동만」 옆에 어긋난 품목 수 · 목록은 다시 그리지 않는다(치던 수량 보존)', e.els.driftCnt.textContent === '(2)' && e.filters === 0);
    const e2 = mk(DATA, { only: true }); e2.api.load(); await sleep(10);
    t('「변동만」을 켜 둔 채 늦게 오면 다시 거른다', e2.filters === 1);
    const e3 = mk(DATA, { only: true, chg: '3' }); e3.api.load(); await sleep(10);
    t('고친 칸이 있으면 다시 거르지 않고 자리만 채운다', e3.filters === 0 && txt(e3.els.dr0.innerHTML) === '|변동 +1 → 3|');
    const e4 = mk('fail'); e4.api.load(); await sleep(10);
    t('옛 서버(404) — 표시 없이 종전 화면', e4.els.dr0.innerHTML === '' && e4.els.driftCnt.textContent === '' && e4.api.st.map === null);
    t('JSP — 조회할 때마다 읽고 · 상품명 칸에 자리 · [변동만] 거르기', /driftLoad\(\);\s+\/\* 변동 품목/.test(jsp) && /'<span id="dr'\+i\+'">' \+ adjRunPill\(driftOf\(r\)\) \+ '<\/span><\/td>'/.test(jsp) && /if \(dr && !driftOf\(r\)\) return false;/.test(jsp) && /id="driftOnly"/.test(jsp));
  }
  t('JSP — 탭 이름 옆 · 이력 표 「후」 칸에 붙인다 · 다시 읽으면 버린다', /adjRunPill\(adjRunGet\(_hisSel\.mainSeq != null \? _hisSel\.mainSeq : _hisSel\.prodSeq\)\)/.test(jsp) && /nvl\(h\.aftQty\) \+ \(selTab \? adjRunRow\(h\) : ''\)/.test(jsp) && /_hisCache = \{\}; _adjRun = \{\};/.test(jsp));
  console.log((bad ? '✗ ' : '✓ ') + 'sim_stockAdjRun : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
