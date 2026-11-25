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
  /* ── [🗑 삭제 전표] 창 · 되살리기 (2026-11-25 · 운영 SALE_SEQ 211 그대로) ── */
  {
    const c2 = cut('function sdlOpen(){', '/* ★전표 뒤에 재고조정을 한 품목 경고 (2026-11-25') + cut('function saAdjWarnHtml(list, mode){', '/* 수정 저장 — 조정 뒤 품목이');
    const HEAD = () => ({ saleSeq: 211, saleDt: '20261118', saleNo: '0001', custNm: '세진유통', totAmt: 1026900, dupYn: 'N', nextNo: '0003', twinNo: '20261118-0002' });
    const LINES = () => [ { prodCd: '2102014127', prodNm: '웰파인더진한레몬', qty: 9, curQty: -45 }, { prodCd: '9904012784', prodNm: '수저세트', qty: 45, curQty: 128, adjCnt: 1, lastAdjDt: '20261117', lastAftQty: 128 } ];
    const LIST = [ { saleSeq: 211, saleDt: '20261118', saleNo: '0001', custCd: '00343', custNm: '세진유통', totAmt: 1026900, delDttm: '2026-11-17 19:34:44', delUser: 'admin', delUserNm: '마스터', lineCnt: 5, qty: 63, firstNm: '웰파인더진한오렌지한라봉' } ];
    const mk = (o) => { const e = { calls: [], confirms: [], oks: [], errs: [], loads: 0, els: {}, answer: o.answer !== false };
      const el = (id) => e.els[id] || (e.els[id] = { innerHTML: '', textContent: '', value: ({ saFrom: '2026-10-01', saTo: '2026-11-25', saFindNm: '' })[id] || '', classList: { on: false, add(){ this.on = true; }, remove(){ this.on = false; }, contains(){ return this.on; } } });
      const post = (url, body) => { e.calls.push({ url, body });
        if (url === '/mangr/salesTrxDelList.do') return o.list === 'fail' ? Promise.resolve({ ok: false, status: 404 }) : Promise.resolve({ ok: true, json: () => Promise.resolve({ result: 'OK', data: LIST }) });
        if (url === '/mangr/salesTrxRestoreInfo.do') return Promise.resolve({ ok: true, json: () => Promise.resolve(o.info) });
        if (url === '/mangr/salesTrxRestore.do') return Promise.resolve({ ok: true, json: () => Promise.resolve(o.res || { result: 'OK', saleDt: '20261118', saleNo: '0001', oldNo: '0001' }) });
        return Promise.resolve({ ok: false }); };
      const esc = (x) => String(x == null ? '' : x).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
      const num = (v) => Math.round(+v || 0).toLocaleString('en-US');
      e.api = new Function('post', 'document', 'swConfirm', 'swErr', 'swOk', 'esc', 'fmt', 'fmtQ', 'fmtDt', 'n', 'saLoad', c2 + '; return { open: sdlOpen, close: sdlClose, html: sdlHtml, res: sdlRestore, sub: sdlSubHtml };')(post, { getElementById: el },
        (m) => { e.confirms.push(m); return Promise.resolve(e.answer); }, (m) => e.errs.push(m), (m) => e.oks.push(m), esc, num, num,
        (d) => { d = String(d || ''); return d.length === 8 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8) : d; },
        (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; }, () => { e.loads++; });
      return e; };
    const e = mk({ info: { result: 'OK', head: HEAD(), lines: LINES() } }); e.api.open(); await sleep(5);
    const rows = e.els.sdlBody.innerHTML.match(/<tr[\s\S]*?<\/tr>/g) || [], x = txt(rows[0] || '');
    t('삭제 전표 창 — 검색기간으로 묻고 9칸 한 줄', e.calls[0].url === '/mangr/salesTrxDelList.do' && e.calls[0].body === 'fromDt=2026-10-01&toDt=2026-11-25&findData=' && rows.length === 1 && (rows[0].match(/<td/g) || []).length === 8, e.calls[0].body);
    t('삭제 전표 창 — 일자·번호·거래처·품목 외 4·수량 합·합계·지운 때·사람', /2026-11-18 0001 세진유통 \[00343\] 웰파인더진한오렌지한라봉 외 4 63 1,026,900 2026-11-17 19:34 마스터$/.test(x.trim()) && !/되살리기/.test(rows[0]) && /onclick="sdlToggle\(211, this, event\)"/.test(rows[0]), x);
    t('품목 펼침 글 — 품목마다 수량과 현재고', /이 전표의 품목 2종/.test(txt(e.api.sub(LINES()))) && /2102014127 웰파인더진한레몬 — 출고 9 · 지금 현재고 -45/.test(txt(e.api.sub(LINES()))), txt(e.api.sub(LINES())));
    e.api.res(211); await sleep(5);
    const m = txt(e.confirms[0] || '');
    t('되살리기 확인창 — 일자·번호·거래처·합계·품목 수 · 「출고가 다시 빠집니다」', /2026-11-18 \/ 0001 세진유통/.test(m) && /합계 1,026,900원 · 품목 2종/.test(m) && /출고가 다시 빠집니다/.test(m), m);
    t('★확인창 — 같은 거래처·같은 금액 전표(2026-11-18 / 0002) 중복 경고', /같은 거래처 · 같은 금액의 전표가 이미 있습니다/.test(m) && /2026-11-18 \/ 0002/.test(m) && /되살리지 마세요/.test(m));
    t('★확인창 — 지운 뒤 조정한 품목만 「현재고 128 → 83」(되살리면 준다)', /이 전표를 지운 뒤에 재고조정을 한 품목이 있습니다/.test(m) && /현재고 128 → 83/.test(m) && !/현재고 -45 →/.test(m), m);
    t('되살리기 — 서버에 보내고 목록·삭제 전표 창을 다시 읽는다', e.calls.filter(c => c.url === '/mangr/salesTrxRestore.do').length === 1 && e.loads === 1 && e.calls.filter(c => c.url === '/mangr/salesTrxDelList.do').length === 2 && /되살렸습니다 — 2026-11-18 \/ 0001$/.test(e.oks[0] || ''), JSON.stringify([e.loads, e.oks]));
    const e2 = mk({ info: { result: 'OK', head: HEAD(), lines: LINES() }, answer: false }); e2.api.res(211); await sleep(5);
    t('[취소]면 보내지 않는다', e2.calls.filter(c => c.url === '/mangr/salesTrxRestore.do').length === 0);
    const h3 = HEAD(); h3.dupYn = 'Y'; h3.twinNo = null;
    const e3 = mk({ info: { result: 'OK', head: h3, lines: LINES().slice(0, 1) }, res: { result: 'OK', saleDt: '20261118', saleNo: '0003', oldNo: '0001' } }); e3.api.res(211); await sleep(5);
    t('번호가 그새 쓰였으면 「0003 번으로」 · 결과 「번호 0001 → 0003」 · 경고 상자 없음', /0003<\/b> 번으로 되살립니다/.test(e3.confirms[0]) && /번호 0001 → 0003/.test(e3.oks[0] || '') && !/sa-twin|sa-adjwarn/.test(e3.confirms[0]), e3.oks[0]);
    const e4 = mk({ info: { result: 'FAIL', message: '지운 전표를 찾지 못했습니다' } }); e4.api.res(211); await sleep(5);
    t('이미 되살린 전표 — 확인창 없이 사유', e4.confirms.length === 0 && /지운 전표를 찾지 못했습니다/.test(e4.errs[0] || ''));
    const e5 = mk({ list: 'fail' }); e5.api.open(); await sleep(5);
    t('옛 서버(404) — 창에 「HTTP 404」 한 줄', /HTTP 404/.test(e5.els.sdlBody.innerHTML));
    t('JSP — [🗑 삭제 전표] 단추', /onclick="sdlOpen\(\)"/.test(jsp));
  }
  /* ── 펼친 품목 : 전체 선택 · 개별 선택 → 그 전표에서 고른 품목만 되살리기 (2026-11-25 · 전표 여러 장 한꺼번에는 없앴다) ── */
  {
    const cB = cut('function sdlOpen(){', '/* ★전표 뒤에 재고조정을 한 품목 경고 (2026-11-25') + cut('function saAdjWarnHtml(list, mode){', '/* 수정 저장 — 조정 뒤 품목이');
    const LN = () => [ { prodCd: 'A', prodNm: '트레이', qty: 100, curQty: 10 }, { prodCd: 'B', prodNm: '뚜껑', qty: 50, curQty: 5, lastAdjDt: '20261120', lastAftQty: 5, adjCnt: 1 }, { prodCd: 'C', prodNm: '컵', qty: 20, curQty: 0 } ];
    const INFO = () => ({ result: 'OK', head: { saleSeq: 9, saleDt: '20261111', saleNo: '0004', custNm: '영신기업', totAmt: 6666000, dupYn: 'N' }, lines: LN() });
    const mk = (o2) => { o2 = o2 || {}; const e = { calls: [], confirms: [], oks: [], errs: [], loads: 0, els: {}, answer: o2.answer !== false };
      const el = (id) => e.els[id] || (e.els[id] = { innerHTML: '', textContent: '', value: '', checked: false, classList: { on: false, add(){ this.on = true; }, remove(){ this.on = false; }, contains(){ return this.on; } }, querySelectorAll: () => [] });
      const post = (url, body) => { e.calls.push({ url, body });
        if (url === '/mangr/salesTrxRestoreInfo.do') return Promise.resolve({ ok: true, json: () => Promise.resolve(INFO()) });
        if (url === '/mangr/salesTrxRestore.do') return Promise.resolve({ ok: true, json: () => Promise.resolve({ result: 'OK', saleDt: '20261111', saleNo: '0004', oldNo: '0004' }) });
        return Promise.resolve({ ok: true, json: () => Promise.resolve({ result: 'OK', data: [] }) }); };
      const esc = (x) => String(x == null ? '' : x).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
      const num = (v) => Math.round(+v || 0).toLocaleString('en-US');
      e.api = new Function('post', 'document', 'swConfirm', 'swErr', 'swOk', 'esc', 'fmt', 'fmtQ', 'fmtDt', 'n', '_pph', 'pphLoad', 'puLoad', 'saLoad',
        cB + '; return { sub: sdlSubHtml, all: sdlItAll, sync: sdlItSync, it: sdlItRestore, html: sdlHtml };')(post, { getElementById: el },
        (m) => { e.confirms.push(m); return Promise.resolve(e.answer); }, (m) => e.errs.push(m), (m) => e.oks.push(m), esc, num, num,
        (d) => { d = String(d || ''); return d.length === 8 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8) : d; },
        (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; }, { mode: false }, () => { e.loads += 100; }, () => { e.loads++; }, () => { e.loads++; });
      return e; };
    /* 가짜 펼친 줄 — 품목 체크 셋 + 전체 선택 체크 + 단추 */
    const box = (ck) => { const b = { className: 'sdl-items', getAttribute: (k) => k === 'data-seq' ? '9' : null };
      b.ics = ['A', 'B', 'C'].map((c, i) => ({ value: c, checked: ck ? !!ck[i] : true, parentNode: b })); b.ia = { checked: true, parentNode: b }; b.btn = { parentNode: b };
      b.querySelectorAll = (q) => q === 'input.sdl-ic' ? b.ics : []; b.querySelector = (q) => q === 'input.sdl-ia' ? b.ia : null; return b; };
    const res = (e) => e.calls.filter(c => c.url === '/mangr/salesTrxRestore.do');
    const e0 = mk();
    const h1 = e0.api.html([{ saleSeq: 7, saleDt: '20261111', saleNo: '0004', custNm: 'x', lineCnt: 1, qty: 1, totAmt: 1 }]);
    t('목록 줄 — 전표 체크 칸·되살리기 칸 없음(8칸 · 단추 없음) · 줄을 누르면 펼치기', (h1.match(/<td/g) || []).length === 8 && !/sdl-ck/.test(h1) && !/<button/.test(h1) && /onclick="sdlToggle\(7, this, event\)"/.test(h1), h1);
    const sub = e0.api.sub(LN(), 9);
    t('펼친 품목 — [전체 선택] + 품목마다 체크(★처음엔 체크 없음) · 칸 안에 [↩ 체크한 품목 되살리기] 하나', /class="sdl-items" data-seq="9"/.test(sub) && /class="sdl-ia" onclick="sdlItAll\(this\)"/.test(sub) && (sub.match(/class="sdl-ic" value="[ABC]" onclick="sdlItSync\(this\)"/g) || []).length === 3 && !/ checked/.test(sub) && (sub.match(/<button/g) || []).length === 1 && /onclick="sdlItRestore\(this\)"/.test(sub) && /↩ 체크한 품목 되살리기/.test(sub) && /이 전표의 품목 3종/.test(txt(sub)), txt(sub));
    const b1 = box(); b1.ia.checked = false; e0.api.all(b1.ia);
    t('전체 선택 해제 — 품목 체크가 모두 풀린다 · 다시 켜면 모두 체크', b1.ics.every(c => !c.checked) && (b1.ia.checked = true, e0.api.all(b1.ia), b1.ics.every(c => c.checked)));
    b1.ics[1].checked = false; e0.api.sync(b1.ics[1]); const s1 = b1.ia.checked; b1.ics[1].checked = true; e0.api.sync(b1.ics[1]);
    t('개별 해제 — [전체 선택] 체크가 풀리고, 다시 다 체크하면 켜진다', s1 === false && b1.ia.checked === true);
    const e1 = mk(); e1.api.it(box().btn); await sleep(10);
    t('전부 체크 → 종전처럼 전표 통째(품목 3종 · prodCds 안 보냄)', /합계 6,666,000원 · 품목 3종/.test(txt(e1.confirms[0] || '')) && !/종만/.test(txt(e1.confirms[0] || '')) && res(e1).length === 1 && res(e1)[0].body.saleSeq === 9 && res(e1)[0].body.prodCds === null, txt(e1.confirms[0] || ''));
    const e2 = mk(); e2.api.it(box([1, 0, 0]).btn); await sleep(10);
    const m2 = txt(e2.confirms[0] || '');
    t('★품목 하나만 체크 → 확인창 「품목 3종 중 1종만」 + 그 품목 + 「나머지 2종은 지운 채로」', /품목 3종 중\s*1종만\s*되살립니다/.test(m2) && /A\s+트레이 — 출고 100/.test(m2) && /나머지 2종은 지운 채로 남고/.test(m2) && /합계는 이 품목만으로 다시 계산/.test(m2) && !/뚜껑/.test(m2), m2);
    t('★고른 품목만 서버로 — prodCds [A] · 안 고른 품목(B)의 조정 경고는 안 뜬다', res(e2).length === 1 && JSON.stringify(res(e2)[0].body.prodCds) === '["A"]' && !/현재고 5 →/.test(m2) && e2.loads === 1, JSON.stringify(res(e2).map(c => c.body)));
    const e3 = mk(); e3.api.it(box([0, 1, 0]).btn); await sleep(10);
    t('조정한 품목(B)을 고르면 경고 「현재고 5 → -45」', /이 전표를 지운 뒤에 재고조정을 한 품목이 있습니다/.test(txt(e3.confirms[0] || '')) && /현재고 5 → -45/.test(txt(e3.confirms[0] || '')) && JSON.stringify(res(e3)[0].body.prodCds) === '["B"]', txt(e3.confirms[0] || ''));
    const e4 = mk(); e4.api.it(box([0, 0, 0]).btn); await sleep(10);
    t('하나도 체크 안 함 → 안내만(서버 안 부름)', /되살릴 품목을 체크하세요/.test(e4.errs[0] || '') && e4.calls.length === 0);
    const e6 = mk(); e6.api.it(box([1, 0, 1]).btn); await sleep(10);
    t('두 품목 체크 → 그 품목만(A·C)', JSON.stringify(res(e6)[0].body.prodCds) === '["A","C"]' && /품목 3종 중\s*2종만/.test(txt(e6.confirms[0] || '')), txt(e6.confirms[0] || ''));
    const e7 = mk({ answer: false }); e7.api.it(box([1, 0, 0]).btn); await sleep(10);
    t('[취소]면 보내지 않는다', e7.confirms.length === 1 && res(e7).length === 0);
    t('JSP — 전표 여러 장 [↩ 선택 되살리기]·전표 체크 칸은 없다', !/sdlSelBtn|sdlCkAll|sdlRestoreSel|sdl-ck"|sdlRowRestore/.test(jsp) && !/>되살리기<\/th>/.test(jsp) && /되살리기는 전표 한 건씩입니다/.test(jsp));
  }
  /* ── 품목 판매이력 맨 아래 «지운 전표» (2026-11-25 · 운영 2102014127 그대로) ── */
  {
    const c5 = cut('function sphDelLoad(cd){', 'function sphOpen(seq, tr){');
    const mk = (resp) => { const calls = []; const post = (url, body) => { calls.push({ url, body }); if (resp === 'fail') return Promise.resolve({ ok: false }); return Promise.resolve({ ok: true, json: () => Promise.resolve(resp) }); };
      const api = new Function('post', 'esc', 'fmt', 'fmtDt', 'n', c5 + '; return { load: sphDelLoad, html: sphDelHtml };')(post,
        (x) => String(x == null ? '' : x).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'),
        (v) => Math.round(+v || 0).toLocaleString('en-US'), (d) => { d = String(d || ''); return d.length === 8 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8) : d; },
        (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; });
      return { calls, api }; };
    const SV = [ { saleSeq: 211, saleDt: '20261118', saleNo: '0001', custCd: '00343', custNm: '세진유통', prodCd: '2102014127', qty: 9, unitPrice: 15500, amt: 139500, delDttm: '2026-11-17 19:34:44', delUser: 'admin', delUserNm: '마스터' },
                 { saleSeq: 300, saleDt: '20261101', saleNo: '0002', custCd: '00343', custNm: '세진유통', prodCd: '2102014127', qty: -2, unitPrice: 15500, amt: -31000, delDttm: '2026-11-02 09:00:00', delUser: 'K002' },
                 { saleSeq: 301, saleDt: '20261101', saleNo: '0003', custCd: '00343', custNm: '세진유통', prodCd: '2102014127', qty: 0, delDttm: '2026-11-02 09:00:00' } ];
    const m1 = mk({ result: 'OK', data: [], sales: SV }), got = await m1.api.load('2102014127');
    t('지운 판매전표 — 품목코드로 묻고 응답의 sales 를 쓴다', m1.calls[0].url === '/prod/prodDelPurchList.do' && m1.calls[0].body === 'prodCd=2102014127' && got.length === 3);
    const h = m1.api.html(got), rows = h.match(/<tr[\s\S]*?<\/tr>/g) || [];
    t('지운 판매전표 — 머리 줄 「🗑 지운 전표 2건」(수량 0 줄 제외) + 자료 줄 10칸', rows.length === 3 && /🗑 지운 전표 2건/.test(rows[0]) && (rows[1].match(/<td/g) || []).length === 10, rows.length);
    t('지운 판매전표 — 판매일자·번호·코드·거래처·[삭제 때 · 사람]·수량·단가·금액', /2026-11-18 0001 00343 세진유통 \[삭제 2026-11-17 19:34 · 마스터\] 9 15,500 139,500/.test(txt(rows[1])), txt(rows[1]));
    t('반품 전표였던 줄 — 「[반품]」 · 수량·금액은 양수', /\[반품\]/.test(rows[2]) && /K002\] 2 15,500 31,000/.test(txt(rows[2])), txt(rows[2]));
    t('줄에 되살리기 단추 없음(보기만) · 줄 자체는 누를 수 없다', !/<button/.test(h) && /\[🗑 삭제 전표\]에서/.test(h) && !/<tr[^>]*onclick/.test(h));
    t('지운 전표가 없으면 아무것도 안 그린다', m1.api.html([]) === '' && m1.api.html(null) === '');
    t('옛 서버(sales 없음)·404 — 빈 목록', (await mk({ result: 'OK', data: [] }).api.load('X')).length === 0 && (await mk('fail').api.load('X')).length === 0);
    t('JSP — 품목 판매이력이 지운 전표를 함께 읽고 목록 끝에 붙인다', /sphDelLoad\(_sph\.cd\) \]\)\.then\(function\(pa\)/.test(jsp) && /h\+=sphDelHtml\(del\);\s+b\.innerHTML=h;/.test(jsp));
  }
  /* ── 수정재고가 고정된 품목 안내 (2026-11-25 「앞 날짜 전표 넣을 때 안내도 넣어줘」) — saFixGuard ── */
  {
    const nn = (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; };
    const ee = (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    const FIX = () => [ { prodCd: 'A', prodNm: '덮밥용기', adjDt: '20261125', aftQty: 109 } ];
    const mk = (o) => { const e = { calls: [], confirms: [], answer: o.answer !== false };
      const post = (url, body) => { e.calls.push({ url, body });
        if (o.fix === 'fail') return Promise.resolve({ ok: false, json: () => Promise.reject(new Error('x')) });
        if (o.fix === 'throw') return Promise.reject(new Error('net'));
        return Promise.resolve({ ok: true, json: () => Promise.resolve(o.wrap ? JSON.stringify({ data: o.fix || [] }) : { data: o.fix || [] }) }); };
      e.api = new Function('post', 'swConfirm', 'n', 'esc', 'fmtQ', 'isRtn', 'document', '_cur',
        jsp.slice(jsp.indexOf('function saFixHtml(list){'), jsp.indexOf('function saDelete(){')) + '; return { guard: saFixGuard, sum: saFixSum };')(post,
        (m) => { e.confirms.push(m); return Promise.resolve(e.answer); }, nn, ee, (v) => Math.round(+v || 0).toLocaleString('en-US'), (g) => g === '반품' || g === '불량반품',
        { getElementById: () => ({ value: o.dt || '2026-11-20' }) }, o.cur || null);
      return e; };
    const IT = [ { prodCd: 'A', qty: 10, trxGb: '판매' }, { prodCd: 'B', qty: 3, trxGb: '판매' } ];
    const e1 = mk({ fix: FIX() }); const r1 = await e1.api.guard(IT);
    t('새 전표 — 품목 전부를 전표 날짜와 함께 묻는다', e1.calls.length === 1 && e1.calls[0].url === '/prod/adjFixCheck.do' && e1.calls[0].body.dt === '20261120' && JSON.stringify(e1.calls[0].body.prodCds) === '["A","B"]', JSON.stringify(e1.calls[0] && e1.calls[0].body));
    t('★고정된 품목이 있으면 안내창 — 「현재고가 달라지지 않습니다」·맞춘 날짜·수량', r1 === true && e1.confirms.length === 1 && /현재고가 달라지지 않습니다/.test(e1.confirms[0]) && /11-25 에 재고 109 \(으\)로 맞춤/.test(txt(e1.confirms[0])) && /나간 것이라면/.test(e1.confirms[0]), txt(e1.confirms[0] || ''));
    const e2 = mk({ fix: FIX(), answer: false });
    t('[취소]면 저장하지 않는다', (await e2.api.guard(IT)) === false);
    const e3 = mk({ fix: [] });
    t('고정된 품목이 없으면 안내 없이 저장', (await e3.api.guard(IT)) === true && e3.confirms.length === 0);
    const e4 = mk({ fix: FIX(), cur: { saleSeq: 7, _fixQ: { A: 10, B: 3 }, _fixDt: '20261120' } });
    t('수정 — 날짜·수량이 그대로면 묻지도 않는다(단가·비고만 고친 저장)', (await e4.api.guard(IT)) === true && e4.calls.length === 0 && e4.confirms.length === 0);
    const e5 = mk({ fix: FIX(), cur: { saleSeq: 7, _fixQ: { A: 4, B: 3 }, _fixDt: '2026-11-20' } }); await e5.api.guard(IT);
    t('수정 — 수량이 달라진 품목만 묻는다(A)', e5.calls.length === 1 && JSON.stringify(e5.calls[0].body.prodCds) === '["A"]' && e5.confirms.length === 1, JSON.stringify(e5.calls[0] && e5.calls[0].body));
    const e6 = mk({ fix: FIX(), cur: { saleSeq: 7, _fixQ: { A: 10, B: 3 }, _fixDt: '20261128' } }); await e6.api.guard(IT);
    t('수정 — 날짜를 옮겼으면 품목 전부', e6.calls.length === 1 && JSON.stringify(e6.calls[0].body.prodCds) === '["A","B"]');
    const e7 = mk({ fix: FIX(), cur: { saleSeq: 7, _fixQ: { A: 10, B: 3, C: 5 }, _fixDt: '20261120' } }); await e7.api.guard(IT);
    t('수정 — 뺀 품목(C)도 달라진 품목', e7.calls.length === 1 && JSON.stringify(e7.calls[0].body.prodCds) === '["C"]');
    t('옛 서버(404)·통신 오류 — 안내 없이 저장', (await mk({ fix: 'fail' }).api.guard(IT)) === true && (await mk({ fix: 'throw' }).api.guard(IT)) === true);
    const e8 = mk({ fix: FIX(), wrap: true }); await e8.api.guard(IT);
    t('응답이 글자로 한 번 더 싸여 와도 읽는다', e8.confirms.length === 1);
    t('수량 셈 — 반품은 −', JSON.stringify(e1.api.sum([ { prodCd: 'A', qty: 10 }, { prodCd: 'A', qty: 4, trxGb: '반품' } ])) === '{"A":6}');
    t('JSP — 불러올 때 품목별 수량·날짜를 적어 둔다', /d\._fixQ = saFixSum\(d\.items\); d\._fixDt = d\.saleDt;/.test(jsp));
  }
  t('판매 수량 셈 — 출고차감을 빼고 불량반품은 0', (() => { const f = new Function('n', jsp.slice(jsp.indexOf('function saFixSum(items){'), jsp.indexOf('function saFixGuard(items){')) + '; return saFixSum;')((v) => Number(v) || 0);
    return JSON.stringify(f([ { prodCd: 'A', qty: 10, stockCutQty: 3 }, { prodCd: 'B', qty: 5, trxGb: '불량반품' }, { prodCd: 'C', qty: 2, trxGb: '반품' } ])) === '{"A":7,"C":-2}'; })());
  t('JSP — 저장은 마감 확인 → saAdjGuard → saFixGuard 차례', /saAdjGuard\(items\)\.then\(function\(go\)\{ return go \? saFixGuard\(items\) : false; \}\)\.then\(function\(go\)\{ if\(!go\) return;/.test(jsp));
  console.log((bad ? '✗' : '✓') + ' sim_saAdjWarn : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
