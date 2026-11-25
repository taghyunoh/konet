/* 판매등록 — 전표 뒤에 재고조정을 한 품목 경고 시뮬 (2026-11-25)
   salesReg.jsp 의 saAdjAfter · saAdjWarnHtml · saAdjGuard · saDelete 를 꺼내 가짜 서버로 돌린다(jsdom 불필요).
   쓰는 법 : node docs/tools/sim/sim_saAdjWarn.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
const jsp = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/salesReg.jsp'), 'utf8');
let ok = 0, bad = 0;
function t(name, cond, info){ if (cond) ok++; else { bad++; console.log('✗ ' + name + (info !== undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const cut = (a, b) => { const i = jsp.indexOf(a), j = jsp.indexOf(b, i); if (i < 0 || j < 0) { console.log('✗ 자리 못 찾음 ' + a); process.exit(1); } return jsp.slice(i, j); };
const code = cut('function saAdjAfter(saleSeq){', '/* ── 전표 목록');

function make(o){
  const env = { calls: [], confirms: [], answer: o.answer !== false, adj: o.adj, oks: [], errs: [], closed: o.closed !== false };
  const post = (url, body) => { env.calls.push({ url, body });
    if (url === '/mangr/salesTrxAdjAfter.do') {
      if (env.adj === 'fail') return Promise.resolve({ ok: false, json: () => Promise.reject(new Error('x')) });
      return Promise.resolve({ ok: true, json: () => Promise.resolve({ data: env.adj }) });
    }
    return Promise.resolve({ ok: true, text: () => Promise.resolve('1') });
  };
  const f = new Function('post', 'swConfirm', 'swErr', 'swOk', 'n', 'esc', 'fmtQ', 'saClosedAsk', 'saNew', 'saLoad', 'env',
    'var _cur = env.cur0; Object.defineProperty(env, "cur", { get: function(){ return _cur; }, set: function(v){ _cur = v; } });' + code +
    '; return { after: saAdjAfter, html: saAdjWarnHtml, guard: saAdjGuard, del: saDelete };');
  env.cur0 = o.cur;
  env.api = f(post, (msg) => { env.confirms.push(msg); return Promise.resolve(env.answer); }, (m) => env.errs.push(m), (m) => env.oks.push(m),
    (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; },
    (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'),
    (v) => Math.round(+v || 0).toLocaleString('en-US'), () => Promise.resolve(env.closed), () => {}, () => {}, env);
  return env;
}
const txt = (h) => String(h).replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
/* 운영 2026-11-25 실측 그대로 — 판매전표 SALE_SEQ 202(우리푸드 11-16) 중 두 품목 */
const ADJ = () => [
  { prodCd: '9904012784', prodNm: '한끼뚝딱 수저세트', qty: 45, adjCnt: 1, lastAdjDt: '20261117', lastAftQty: 128, curQty: 128 },
  { prodCd: '9904013184', prodNm: 'JB303 용기', qty: 40, adjCnt: 2, lastAdjDt: '20261117', lastAftQty: 114, curQty: 114 }
];

(async () => {
  {
    const e = make({ adj: ADJ(), cur: { saleSeq: 202, saleDt: '2026-11-16', saleNo: '0001' } });
    e.api.del(); await sleep(5);
    const m = txt(e.confirms[0] || '');
    t('삭제 — 그 전표로 서버에 묻는다', e.calls[0] && e.calls[0].url === '/mangr/salesTrxAdjAfter.do' && e.calls[0].body.saleSeq === 202, JSON.stringify(e.calls[0]));
    t('삭제 확인창 — 종전 문구 + 경고', /이 전표를 삭제할까요/.test(m) && /출고도 함께 되돌아옵니다/.test(m) && /이 전표 뒤에 재고조정을 한 품목이 있습니다/.test(m), m);
    t('★삭제 — 재고가 그만큼 «는다» : 「현재고 128 → 173」 · 「114 → 154 (… 조정 2회)」', /현재고 128 → 173/.test(m) && /11-17 조정 · 수정재고 128\)/.test(m) && /현재고 114 → 154/.test(m) && /조정 2회/.test(m), m);
    t('삭제 — [삭제]를 누르면 종전대로 지운다', e.calls.length === 2 && e.calls[1].url === '/mangr/salesTrxDelete.do' && e.calls[1].body.saleSeq === 202 && e.oks.length === 1);
    const e2 = make({ adj: ADJ(), cur: { saleSeq: 202 }, answer: false }); e2.api.del(); await sleep(5);
    t('삭제 — [취소]면 지우지 않는다', e2.calls.length === 1);
    const e3 = make({ adj: ADJ(), cur: { saleSeq: 202 }, closed: false }); e3.api.del(); await sleep(5);
    t('마감 확인에서 멈추면 서버에 묻지도 않는다', e3.calls.length === 0 && e3.confirms.length === 0);
    const e4 = make({ adj: [], cur: { saleSeq: 9 } }); e4.api.del(); await sleep(5);
    t('조정 없는 전표 — 경고 없이 종전 확인창 · 삭제 진행', !/sa-adjwarn/.test(e4.confirms[0]) && e4.calls.length === 2);
    const e5 = make({ adj: 'fail', cur: { saleSeq: 9 } }); e5.api.del(); await sleep(5);
    t('옛 서버(404) — 경고 없이 종전 흐름', e5.confirms.length === 1 && !/sa-adjwarn/.test(e5.confirms[0]) && e5.calls.length === 2);
    const e6 = make({ adj: ADJ(), cur: { saleSeq: 202 } }); e6.api.del(); e6.cur = { saleSeq: 999 }; await sleep(5);
    t('묻는 사이 다른 전표를 골랐으면 지우지 않는다', e6.calls.length === 1, e6.calls.length);
  }
  {
    const cur = { saleSeq: 202 };
    const rows = (q1, q2, x) => [{ prodCd: '9904012784', qty: q1, trxGb: '판매' }, Object.assign({ prodCd: '9904013184', qty: q2, trxGb: '판매' }, x || {}), { prodCd: '9904012835', qty: 42, stockCutQty: 2, trxGb: '판매' }];
    const e = make({ adj: ADJ(), cur });
    t('수정 — 수량이 그대로면 묻지 않고 저장', (await e.api.guard(rows(45, 40))) === true && e.confirms.length === 0);
    t('수정 — 45 → 50 이면 「현재고 128 → 123」 · 안 바뀐 품목은 안 나온다', (await e.api.guard(rows(50, 40))) === true && /현재고 128 → 123/.test(txt(e.confirms[0])) && !/9904013184/.test(e.confirms[0]) && /수량을 바꾸면/.test(txt(e.confirms[0])), txt(e.confirms[0] || ''));
    const e2 = make({ adj: ADJ(), cur, answer: false });
    t('수정 — [취소]면 저장 안 함', (await e2.api.guard(rows(50, 40))) === false);
    const e3 = make({ adj: ADJ(), cur });
    await e3.api.guard(rows(45, 40, { stockCutQty: 10 }));
    t('★수정 — 출고차감 10 을 넣으면 재고에서 30 만 빠진다 「114 → 124」', /현재고 114 → 124/.test(txt(e3.confirms[0])), txt(e3.confirms[0] || ''));
    const e4 = make({ adj: ADJ(), cur });
    await e4.api.guard(rows(45, 40, { trxGb: '반품' }));
    t('수정 — 판매를 반품으로 바꾸면 「114 → 194」', /현재고 114 → 194/.test(txt(e4.confirms[0])), txt(e4.confirms[0] || ''));
    const e5 = make({ adj: ADJ(), cur });
    await e5.api.guard(rows(45, 40, { trxGb: '불량반품' }));
    t('수정 — 불량반품은 재고에 안 들어온다 「114 → 154」', /현재고 114 → 154/.test(txt(e5.confirms[0])), txt(e5.confirms[0] || ''));
    const e6 = make({ adj: ADJ(), cur: null });
    t('새 전표는 묻지 않는다(서버도 안 부름)', (await e6.api.guard(rows(1, 1))) === true && e6.calls.length === 0);
    const e7 = make({ adj: 'fail', cur });
    t('옛 서버 — 그대로 저장', (await e7.api.guard(rows(1, 1))) === true && e7.confirms.length === 0);
  }
  t('JSP — 저장은 마감 확인 다음에 saAdjGuard', /saAdjGuard\(items\)\.then\(function\(go\)\{ if\(!go\) return;/.test(jsp));
  console.log((bad ? '✗' : '✓') + ' sim_saAdjWarn : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
