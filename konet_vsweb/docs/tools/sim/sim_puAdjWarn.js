/* 매입등록 — 전표 뒤에 재고조정을 한 품목 경고 시뮬 (2026-11-25)
   purchaseReg.jsp 의 puAdjAfter · puAdjWarnHtml · puAdjGuard · puDelete 를 꺼내 가짜 서버로 돌린다(jsdom 불필요).
   쓰는 법 : node docs/tools/sim/sim_puAdjWarn.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
const jsp = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/purchaseReg.jsp'), 'utf8');
let ok = 0, bad = 0;
function t(name, cond, info){ if (cond) ok++; else { bad++; console.log('✗ ' + name + (info !== undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const cut = (a, b) => { const i = jsp.indexOf(a), j = jsp.indexOf(b, i); if (i < 0 || j < 0) { console.log('✗ 자리 못 찾음 ' + a); process.exit(1); } return jsp.slice(i, j); };
const code = cut('function puAdjAfter(purchSeq){', 'function puSaveGo(){') + cut('function puDelete(){', '/* ── 전표 목록');

function make(o){
  const env = { calls: [], confirms: [], answer: o.answer !== false, adj: o.adj, cur: o.cur, oks: [], errs: [] };
  const post = (url, body) => { env.calls.push({ url, body });
    if (url === '/mangr/purchaseAdjAfter.do') {
      if (env.adj === 'fail') return Promise.resolve({ ok: false, json: () => Promise.reject(new Error('x')) });
      if (env.adj === 'throw') return Promise.reject(new Error('net'));
      return Promise.resolve({ ok: true, json: () => Promise.resolve(env.wrap ? JSON.stringify({ data: env.adj }) : { data: env.adj }) });
    }
    return Promise.resolve({ ok: true, text: () => Promise.resolve('1') });
  };
  const f = new Function('post', 'swConfirm', 'swErr', 'swOk', 'n', 'esc', 'fmtQ', 'isRtn', 'puNew', 'puLoad', 'env',
    'var _cur = env.cur; Object.defineProperty(env, "cur", { get: function(){ return _cur; }, set: function(v){ _cur = v; } });' + code +
    '; return { after: puAdjAfter, html: puAdjWarnHtml, guard: puAdjGuard, del: puDelete };');
  env.api = f(post, (msg) => { env.confirms.push(msg); return Promise.resolve(env.answer); }, (m) => env.errs.push(m), (m) => env.oks.push(m),
    (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; },
    (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'),
    (v) => Math.round(+v || 0).toLocaleString('en-US'), (g) => g === '반품' || g === '불량반품', () => {}, () => {}, env);
  return env;
}
const txt = (h) => String(h).replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
/* 운영 2026-11-25 실측 그대로 — 매입전표 09-18-0002(PURCH_SEQ 391) */
const ADJ = () => [
  { prodCd: '1000736038', prodNm: '(배고픈덮밥이)덮밥용기,몸체,1290CC', qty: 250, adjCnt: 4, lastAdjDt: '20261118', lastAftQty: 412, curQty: 70 },
  { prodCd: '1000808776', prodNm: '(빈쿨룸)다더퍼', qty: 105, adjCnt: 1, lastAdjDt: '20261118', lastAftQty: 116, curQty: 4 }
];

(async () => {
  /* ── 삭제 ── */
  {
    const e = make({ adj: ADJ(), cur: { purchSeq: 391, purchDt: '2026-09-18', purchNo: '0002' } });
    e.api.del(); await sleep(5);
    const m = txt(e.confirms[0] || '');
    t('삭제 — 먼저 그 전표로 서버에 묻는다', e.calls[0] && e.calls[0].url === '/mangr/purchaseAdjAfter.do' && e.calls[0].body.purchSeq === 391, JSON.stringify(e.calls[0]));
    t('삭제 확인창 — 종전 문구 + 경고 머리', /이 전표를 삭제할까요/.test(m) && /이 전표 뒤에 재고조정을 한 품목이 있습니다/.test(m) && /삭제하면 그때 맞춘 재고가 그만큼 달라집니다/.test(m), m);
    t('★삭제 — 「현재고 70 → -180」 (11-18 조정 · 수정재고 412 · 조정 4회)', /1000736038/.test(m) && /현재고 70 → -180/.test(m) && /11-18 조정 · 수정재고 412 · 조정 4회/.test(m), m);
    t('삭제 — 둘째 품목 「현재고 4 → -101」 · 조정 1회는 횟수 안 적음', /현재고 4 → -101/.test(m) && /11-18 조정 · 수정재고 116\)/.test(m), m);
    t('삭제 — 뒤에 재고 일괄조정 안내', /삭제 뒤 재고 일괄조정 으로 다시 맞추세요/.test(m), m);
    t('삭제 — [삭제]를 누르면 종전대로 지운다', e.calls.length === 2 && e.calls[1].url === '/mangr/purchaseDelete.do' && e.calls[1].body.purchSeq === 391 && e.oks.length === 1, JSON.stringify(e.calls.map(c => c.url)));
    const e2 = make({ adj: ADJ(), cur: { purchSeq: 391 }, answer: false }); e2.api.del(); await sleep(5);
    t('삭제 — [취소]면 지우지 않는다', e2.calls.length === 1);
    const e3 = make({ adj: [], cur: { purchSeq: 5 } }); e3.api.del(); await sleep(5);
    t('조정 없는 전표 — 종전 확인창 그대로(경고 없음) · 삭제 진행', !/pu-adjwarn/.test(e3.confirms[0]) && /이 전표를 삭제할까요/.test(e3.confirms[0]) && e3.calls.length === 2);
    for (const k of ['fail', 'throw']) {
      const e4 = make({ adj: k, cur: { purchSeq: 5 } }); e4.api.del(); await sleep(5);
      t('옛 서버·조회 실패(' + k + ') — 경고 없이 종전 흐름', e4.confirms.length === 1 && !/pu-adjwarn/.test(e4.confirms[0]) && e4.calls.length === 2);
    }
    const e5 = make({ adj: ADJ(), cur: { purchSeq: 391 } }); e5.wrap = true; e5.api.del(); await sleep(5);
    t('응답이 글자 한 겹에 싸여 와도 읽는다', /현재고 70 → -180/.test(txt(e5.confirms[0])));
    const e6 = make({ adj: ADJ(), cur: null }); e6.api.del(); await sleep(5);
    t('전표를 안 골랐으면 종전 안내만', e6.errs.length === 1 && e6.calls.length === 0);
    const e7 = make({ adj: ADJ(), cur: { purchSeq: 391 } }); e7.api.del(); e7.cur = { purchSeq: 999 }; await sleep(5);
    t('묻는 사이 다른 전표를 골랐으면 지우지 않는다', e7.calls.length === 1, e7.calls.length);
    const many = []; for (let i = 0; i < 7; i++) many.push({ prodCd: 'P' + i, prodNm: '품목' + i, qty: 1, adjCnt: 1, lastAdjDt: '20261101', lastAftQty: 9, curQty: 9 });
    const h = make({ adj: [] }).api.html(many.map(x => Object.assign(x, { delta: -1 })), 'del');
    t('품목이 많으면 5개 + 「외 2품목」', (h.match(/· <b>P/g) || []).length === 5 && /외 2품목/.test(h));
    t('이름의 < > 는 글자로', /&lt;b&gt;/.test(make({ adj: [] }).api.html([{ prodCd: 'X', prodNm: '<b>x', qty: 1, delta: -1, curQty: 1, lastAdjDt: '20261101', lastAftQty: 1 }], 'del')));
  }
  /* ── 수정 저장 ── */
  {
    const cur = { purchSeq: 391 };
    const rows = (q1, q2, g2) => [{ prodCd: '1000736038', qty: q1, trxGb: '매입' }, { prodCd: '1000808776', qty: q2, trxGb: g2 || '매입' }, { prodCd: '9904013323', qty: 599, trxGb: '매입' }];
    const e = make({ adj: ADJ(), cur });
    t('수정 — 수량이 그대로면 묻지 않고 저장', (await e.api.guard(rows(250, 105))) === true && e.confirms.length === 0);
    t('수정 — 수량 250 → 200 이면 확인창 「현재고 70 → 20」 · 안 바뀐 품목은 안 나온다', (await e.api.guard(rows(200, 105))) === true && /현재고 70 → 20/.test(txt(e.confirms[0])) && !/1000808776/.test(e.confirms[0]) && /수량을 바꾸면/.test(txt(e.confirms[0])) && /저장 뒤 재고 일괄조정/.test(txt(e.confirms[0])), txt(e.confirms[0] || ''));
    const e2 = make({ adj: ADJ(), cur, answer: false });
    t('수정 — [취소]면 저장 안 함', (await e2.api.guard(rows(200, 105))) === false);
    const e3 = make({ adj: ADJ(), cur });
    await e3.api.guard([{ prodCd: '9904013323', qty: 599, trxGb: '매입' }]);
    t('수정 — 줄을 뺀 품목 「현재고 70 → -180」 · 「4 → -101」', /현재고 70 → -180/.test(txt(e3.confirms[0])) && /현재고 4 → -101/.test(txt(e3.confirms[0])), txt(e3.confirms[0] || ''));
    const e4 = make({ adj: ADJ(), cur });
    await e4.api.guard(rows(250, 105, '반품'));
    t('수정 — 매입을 반품으로 바꾸면 「4 → -206」', /현재고 4 → -206/.test(txt(e4.confirms[0])), txt(e4.confirms[0] || ''));
    const e5 = make({ adj: ADJ(), cur: null });
    t('새 전표는 묻지 않는다(서버도 안 부름)', (await e5.api.guard(rows(1, 1))) === true && e5.calls.length === 0);
    const e6 = make({ adj: 'fail', cur });
    t('옛 서버 — 그대로 저장', (await e6.api.guard(rows(1, 1))) === true && e6.confirms.length === 0);
  }
  /* ── 품목 매입이력 맨 아래 «지운 전표» (2026-11-25) ── */
  {
    const c2 = cut('function pphDelLoad(cd){', 'function pphOpen(seq, tr){');
    const mk = (resp) => { const calls = []; const post = (url, body) => { calls.push({ url, body }); if (resp === 'fail') return Promise.resolve({ ok: false }); return Promise.resolve({ ok: true, json: () => Promise.resolve(resp) }); };
      const api = new Function('post', 'esc', 'fmt', 'fmtDt', c2 + '; return { load: pphDelLoad, html: pphDelHtml };')(post,
        (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'),
        (v) => Math.round(+v || 0).toLocaleString('en-US'), (d) => { d = String(d || ''); return d.length === 8 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8) : d; });
      return { calls, api }; };
    const D = [{ purchSeq: 427, purchDt: '20260916', purchNo: '0002', vendorNm: '버개스패키지', qty: 250, unitPrice: 24900, amt: 6225000, delDttm: '2026-11-22 18:48:02', delUser: 'admin', delUserNm: '마스터' }];
    const m1 = mk({ result: 'OK', data: D }), got = await m1.api.load('1000736038');
    t('지운 전표 — 품목코드로 묻는다', m1.calls[0].url === '/prod/prodDelPurchList.do' && m1.calls[0].body === 'prodCd=1000736038' && got.length === 1);
    const h = m1.api.html(got), rows = h.match(/<tr[\s\S]*?<\/tr>/g) || [];
    t('지운 전표 — 머리 줄 「🗑 지운 전표 1건」 + 자료 줄 10칸', rows.length === 2 && /🗑 지운 전표 1건/.test(rows[0]) && /colspan="10"/.test(rows[0]) && (rows[1].match(/<td/g) || []).length === 10, rows.length);
    const x = txt(rows[1] || '');
    t('지운 전표 — 매입일자·번호·거래처·[삭제 때 · 사람]·수량·단가·금액', /2026-09-16 0002 버개스패키지 \[삭제 2026-11-22 18:48 · 마스터\] ↩ 되살리기 250 24,900 6,225,000/.test(x), x);
    t('지운 전표 — 줄 자체는 누를 수 없고(tr 에 onclick 없음) 단추만 있다', !/<tr[^>]*onclick/.test(h) && (h.match(/onclick="pphRestore\(427\)"/g) || []).length === 1);
    t('지운 전표가 없으면 아무것도 안 그린다', m1.api.html([]) === '' && m1.api.html(null) === '');
    t('옛 서버(404)·실패 응답 — 빈 목록', (await mk('fail').api.load('X')).length === 0 && (await mk({ result: 'FAIL' }).api.load('X')).length === 0);
    t('JSP — 품목 매입이력이 지운 전표를 함께 읽고 목록 끝에 붙인다', /pphDelLoad\(_pph\.cd\) \]\)\.then\(function\(pa\)/.test(jsp) && /h\+=pphDelHtml\(del\);\s+b\.innerHTML=h;/.test(jsp));
  }
  /* ── 지운 전표 되살리기 (2026-11-25 · 운영 PURCH_SEQ 427 그대로) ── */
  {
    const c3 = cut('function puAdjWarnHtml(list, mode){', 'function puAdjGuard(items){') + cut('function pphDelLoad(cd){', 'function pphOpen(seq, tr){');
    const HEAD = () => ({ purchSeq: 427, purchDt: '20260916', purchNo: '0002', vendorNm: '버개스패키지', totAmt: 23729640, dupYn: 'N', nextNo: '0004', twinNo: '20260918-0002' });
    const LINES = () => [ { prodCd: '1000736038', prodNm: '덮밥용기', qty: 250, curQty: 70 }, { prodCd: '1000808776', prodNm: '다더퍼', qty: 105, curQty: 4 },
                          { prodCd: '9904013323', prodNm: '900CC', qty: 599, curQty: 681, adjCnt: 1, lastAdjDt: '20261122', lastAftQty: 682 } ];
    const mk = (o) => { const e = { calls: [], confirms: [], oks: [], errs: [], loads: 0, answer: o.answer !== false };
      const post = (url, body) => { e.calls.push({ url, body });
        if (url === '/mangr/purchaseRestoreInfo.do') return Promise.resolve({ ok: true, json: () => Promise.resolve(o.info) });
        if (url === '/mangr/purchaseRestore.do') return Promise.resolve({ ok: true, json: () => Promise.resolve(o.res || { result: 'OK', purchDt: '20260916', purchNo: '0002', oldNo: '0002', lines: 3 }) });
        return Promise.resolve({ ok: false }); };
      const esc = (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
      const num = (v) => Math.round(+v || 0).toLocaleString('en-US');
      e.api = new Function('post', 'swConfirm', 'swErr', 'swOk', 'esc', 'fmt', 'fmtQ', 'fmtDt', 'n', '_pph', 'pphLoad', 'puLoad', 'document', 'pdlLoad', c3 + '; return { res: pphRestore, html: pphDelHtml };')(post,
        (m) => { e.confirms.push(m); return Promise.resolve(e.answer); }, (m) => e.errs.push(m), (m) => e.oks.push(m), esc, num, num,
        (d) => { d = String(d || ''); return d.length === 8 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8) : d; },
        (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; }, { mode: true }, () => { e.loads++; }, () => { e.loads += 100; }, { getElementById: () => ({ classList: { contains: () => false } }) }, () => {});
      return e; };
    const e = mk({ info: { result: 'OK', head: HEAD(), lines: LINES() } });
    t('지운 전표 줄 — [↩ 되살리기] 단추(10칸 그대로)', /onclick="pphRestore\(427\)"/.test(e.api.html([{ purchSeq: 427, purchDt: '20260916', purchNo: '0002', qty: 250 }])) && ((e.api.html([{ purchSeq: 427, qty: 1 }]).match(/<tr[\s\S]*?<\/tr>/g) || [])[1].match(/<td/g) || []).length === 10);
    e.api.res(427); await sleep(5);
    const m = txt(e.confirms[0] || '');
    t('되살리기 — 먼저 그 전표를 묻는다', e.calls[0].url === '/mangr/purchaseRestoreInfo.do' && e.calls[0].body.purchSeq === 427);
    t('확인창 — 일자·번호·거래처·합계·품목 수', /이 전표를 되살릴까요/.test(m) && /2026-09-16 \/ 0002 버개스패키지/.test(m) && /합계 23,729,640원 · 품목 3종/.test(m), m);
    t('★확인창 — 같은 거래처·같은 금액 전표(2026-09-18 / 0002) 중복 경고', /같은 거래처 · 같은 금액의 전표가 이미 있습니다/.test(m) && /2026-09-18 \/ 0002/.test(m) && /되살리지 마세요/.test(m) && /class="pu-twin"/.test(e.confirms[0]), m);
    t('★확인창 — 지운 뒤 재고조정을 한 품목만 「현재고 681 → 1,280」', /이 전표를 지운 뒤에 재고조정을 한 품목이 있습니다/.test(m) && /되살리면 그때 맞춘 재고가/.test(m) && /9904013323/.test(m) && /현재고 681 → 1,280/.test(m) && !/현재고 70 →/.test(m), m);
    t('되살리기 — [되살리기]를 누르면 서버에 보내고 목록을 다시 읽는다', e.calls.length === 2 && e.calls[1].url === '/mangr/purchaseRestore.do' && e.calls[1].body.purchSeq === 427 && e.loads === 1 && /되살렸습니다 — 2026-09-16 \/ 0002$/.test(e.oks[0] || ''), JSON.stringify([e.calls.length, e.loads, e.oks]));
    const e2 = mk({ info: { result: 'OK', head: HEAD(), lines: LINES() }, answer: false }); e2.api.res(427); await sleep(5);
    t('되살리기 — [취소]면 보내지 않는다 · 다시 누를 수 있다', e2.calls.length === 1 && (e2.api.res(427), e2.calls.length === 2));
    const h3 = HEAD(); h3.dupYn = 'Y'; h3.twinNo = null;
    const e3 = mk({ info: { result: 'OK', head: h3, lines: LINES().slice(0, 2) }, res: { result: 'OK', purchDt: '20260916', purchNo: '0004', oldNo: '0002' } }); e3.api.res(427); await sleep(5);
    const m3 = txt(e3.confirms[0] || '');
    t('번호가 그새 쓰였으면 「0004 번으로 되살립니다」 · 결과에 「번호 0002 → 0004」', /0004 번으로 되살립니다/.test(m3) && /번호 0002 → 0004/.test(e3.oks[0] || ''), m3 + ' / ' + e3.oks[0]);
    t('닮은 전표·조정이 없으면 경고 상자 없음', !/pu-twin/.test(e3.confirms[0]) && !/pu-adjwarn/.test(e3.confirms[0]));
    const e4 = mk({ info: { result: 'FAIL', message: '지운 전표를 찾지 못했습니다' } }); e4.api.res(427); await sleep(5);
    t('이미 되살린 전표 — 확인창 없이 사유를 알린다', e4.confirms.length === 0 && /지운 전표를 찾지 못했습니다/.test(e4.errs[0] || ''));
    const e5 = mk({ info: { result: 'OK', head: HEAD(), lines: LINES() }, res: { result: 'FAIL', message: '전표를 되살리지 못했습니다' } }); e5.api.res(427); await sleep(5);
    t('서버가 거절하면 사유를 알리고 목록은 그대로', /전표를 되살리지 못했습니다/.test(e5.errs[0] || '') && e5.loads === 0 && e5.oks.length === 0);
    const e6 = mk({ info: JSON.stringify({ result: 'OK', head: HEAD(), lines: LINES() }) }); e6.api.res(427); await sleep(5);
    t('응답이 글자 한 겹에 싸여 와도 읽는다', e6.confirms.length === 1);
  }
  /* ── [🗑 삭제 전표] 창 (2026-11-25) ── */
  {
    const c4 = cut('function pdlOpen(){', '/* ★지운 전표 되살리기 (2026-11-25');
    const mk = (resp) => { const e = { calls: [], els: {} };
      const el = (id) => e.els[id] || (e.els[id] = { innerHTML: '', textContent: '', value: ({ puFrom: '2026-10-01', puTo: '2026-11-25', puFindNm: ' 버개스 ' })[id] || '', classList: { on: false, add(){ this.on = true; }, remove(){ this.on = false; }, contains(){ return this.on; } } });
      const post = (url, body) => { e.calls.push({ url, body }); if (resp === 'fail') return Promise.resolve({ ok: false, status: 404 }); return Promise.resolve({ ok: true, json: () => Promise.resolve(resp) }); };
      const esc = (x) => String(x == null ? '' : x).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
      e.api = new Function('post', 'document', 'esc', 'fmt', 'fmtDt', 'n', c4 + '; return { open: pdlOpen, close: pdlClose, html: pdlHtml };')(post, { getElementById: el }, esc,
        (v) => Math.round(+v || 0).toLocaleString('en-US'), (d) => { d = String(d || ''); return d.length === 8 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8) : d; },
        (v) => { const x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; });
      return e; };
    const D = [ { purchSeq: 427, purchDt: '20260916', purchNo: '0002', vendorCd: '00382', vendorNm: '버개스패키지', totAmt: 23729640, delDttm: '2026-11-22 18:48:02', delUser: 'admin', delUserNm: '마스터', lineCnt: 3, qty: 954, firstNm: '(배고픈덮밥이)덮밥용기' } ];
    const e = mk({ result: 'OK', data: D }); e.api.open(); await sleep(5);
    t('삭제 전표 창 — 열면서 목록의 검색기간·거래처명으로 묻는다', e.els.puDelPop.classList.on && e.calls[0].url === '/mangr/purchaseDelList.do' && e.calls[0].body === 'fromDt=2026-10-01&toDt=2026-11-25&findData=' + encodeURIComponent('버개스'), e.calls[0] && e.calls[0].body);
    const rows = e.els.pdlBody.innerHTML.match(/<tr[\s\S]*?<\/tr>/g) || [], x = txt(rows[0] || '');
    t('삭제 전표 창 — 9칸 · 일자·번호·거래처·품목 외 2·수량·합계·지운 때·사람', rows.length === 1 && (rows[0].match(/<td/g) || []).length === 9 && /2026-09-16 0002 버개스패키지 \[00382\] \(배고픈덮밥이\)덮밥용기 외 2 954 23,729,640 2026-11-22 18:48 마스터 ↩ 되살리기/.test(x), x);
    t('삭제 전표 창 — 줄의 단추는 pphRestore(427) · 머리에 기간과 장수', /onclick="pphRestore\(427\)"/.test(rows[0]) && /2026-10-01 ~ 2026-11-25/.test(e.els.pdlHead.textContent) && /1장$/.test(e.els.pdlHead.textContent), e.els.pdlHead.textContent);
    t('지운 전표가 없으면 안내 한 줄', /이 기간에 지운 매입전표가 없습니다/.test(e.api.html([])));
    const e2 = mk('fail'); e2.api.open(); await sleep(5);
    t('옛 서버(404) — 「HTTP 404」 한 줄 · 오류 없음', /HTTP 404/.test(e2.els.pdlBody.innerHTML));
    e.api.close(); t('닫기', e.els.puDelPop.classList.on === false);
    t('JSP — 되살린 뒤 삭제 전표 창이 열려 있으면 그 목록도 다시 읽는다', /getElementById\('puDelPop'\)\.classList\.contains\('on'\)\) pdlLoad\(\);/.test(jsp) && /onclick="pdlOpen\(\)"/.test(jsp));
  }
  t('JSP — 저장은 서브코드 관문 다음에 puAdjGuard', /return puAdjGuard\(items\)\.then\(function\(go2\)\{ return go2 \? puSaveGo\(\) : false; \}\);/.test(jsp));
  console.log((bad ? '✗' : '✓') + ' sim_puAdjWarn : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
