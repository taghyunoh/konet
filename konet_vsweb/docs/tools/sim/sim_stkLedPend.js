/* 품목별재고현황 ② 수불 내역 — 맨 위 «승인 대기» 줄 + 조정 줄 «전 → 후» 시뮬 (2026-11-22)
   logi-oh.js 의 stkLedQty · stkLedPendLoad · stkLedPend 를 꺼내 가짜 fetch 로 돌린다(jsdom 불필요).
   쓰는 법 : node docs/tools/sim/sim_stkLedPend.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/js/winct/logi-oh.js'), 'utf8');
const jsp = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), 'utf8');
let ok = 0, bad = 0;
function t(name, cond, info){ if (cond) ok++; else { bad++; console.log('✗ ' + name + (info !== undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const a = src.indexOf('  function stkLedLast(){'), b = src.indexOf("  var STK_LEDORD=['입고'", a);
if (a < 0 || b < 0) { console.log('✗ 함수 자리를 못 찾음'); process.exit(1); }
const code = src.slice(a, b);

function make(o){
  const env = { calls: [], paints: 0, now: 1000000, resp: o.resp, ext: o.ext || '' };
  const fetch = (url, opt) => { env.calls.push({ url, body: opt && opt.body });
    const r = env.resp; if (r === 'fail') return Promise.resolve({ ok: false, status: 404, json: () => Promise.reject(new Error('x')) });
    return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(r) }); };
  const DateF = { now: () => env.now };
  const f = new Function('fetch', 'Date', '_cnum', 'KONET_CTX', '_stkLedPaint', 'getExt', '_stkLedRaw', 'document', 'stkSplitOpen', '_splitExtGet', '_stkLedRow',
    'var _stkLedExt; Object.defineProperty(this||{}, "x", {value:1});' +
    code.replace(/typeof _stkLedExt!=='undefined' && _stkLedExt/, 'getExt()').replace(/typeof _splitExt!=='undefined' && _splitExt/, '_splitExtGet()') + '; return { qty: stkLedQty, reg: stkLedReg, user: stkLedUser, pend: stkLedPend, split: stkSplitPend, load: stkLedPendLoad, st: _stkPend };');
  env.api = f(fetch, DateF, (v) => Math.round(+v || 0).toLocaleString('en-US'), '/konet', () => { env.paints++; }, () => env.ext, o.raw || [], { getElementById: (id) => id === 'stkSplitPop' ? { classList: { contains: () => !!env.popOn } } : null }, () => { env.splits = (env.splits || 0) + 1; }, () => env.sext || '', o.row || null);
  return env;
}
const pay = (rows) => JSON.stringify(rows);
const REQ = (n, st, rows, extra) => Object.assign({ reqSeq: n, statGb: st, baseDt: '20261122', remark: '실사 ' + n, reqUser: 'K003', reqUserNm: '전원배', reqDttm: '2026-11-22 10:00:00', payload: pay(rows) }, extra || {});
const cells = (h) => { const m = h.match(/<tr[\s\S]*?<\/tr>/g) || []; return m.map(tr => (tr.match(/<td[\s\S]*?<\/td>/g) || []).map(td => td.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim())); };

(async () => {
  /* ── 1. 조정 줄 «전 → 후» ── */
  {
    const e = make({ resp: { result: 'OK', data: [] } }), q = e.api.qty, s = (h) => h.replace(/<[^>]+>/g, '|').replace(/\|+/g, '|');
    t('조정 +1 — 「전 30 → 수정재고 31」 「(증감 +1)」', s(q({ ioGb: 'A', qty: 1, adjBef: 30, adjAft: 31 })) === '|전 30 → 수정재고 31|(증감 +1)|', s(q({ ioGb: 'A', qty: 1, adjBef: 30, adjAft: 31 })));
    t('조정 −1 — 「전 34 → 수정재고 33」 「(증감 -1)」', s(q({ ioGb: 'A', qty: -1, adjBef: 34, adjAft: 33 })) === '|전 34 → 수정재고 33|(증감 -1)|');
    t('★마이너스에서 맞춘 줄 — 「전 -9 → 수정재고 34 (증감 +43)」', s(q({ ioGb: 'A', qty: 43, adjBef: -9, adjAft: 34 })) === '|전 -9 → 수정재고 34|(증감 +43)|', s(q({ ioGb: 'A', qty: 43, adjBef: -9, adjAft: 34 })));
    t('전·후가 없는 조정(옛 서버)·출고 줄은 종전 숫자 그대로', q({ ioGb: 'A', qty: 5 }) === '5' && q({ ioGb: 'O', qty: 1200, adjBef: 1, adjAft: 2 }) === '1,200');
  }
  /* ── 1-2. 가장 최근 조정 줄에 「최근 재고」 표 (2026-11-22) ── */
  {
    const r1 = { ledgerSeq: 9, ioGb: 'O', qty: 1 }, r2 = { ledgerSeq: 8, ioGb: 'A', qty: 1, adjBef: 30, adjAft: 31 }, r3 = { ledgerSeq: 7, ioGb: 'A', qty: -1, adjBef: 34, adjAft: 33 }, r4 = { ledgerSeq: 6, ioGb: 'A', qty: 43, adjBef: -9, adjAft: 34 };
    const e = make({ resp: { result: 'OK', data: [] }, raw: [ r1, r2, r3, r4 ] }), q = e.api.qty, txt = (h) => h.replace(/<[^>]+>/g, '|').replace(/\|+/g, '|');
    t('★가장 최근 조정 줄 — 앞에 「최근재고」 표 + 청록 알약', txt(q(r2)) === '|최근재고|전 30 → 수정재고 31|(증감 +1)|' && /class="led-last"/.test(q(r2)) && /border:1px solid #137a6c/.test(q(r2)), txt(q(r2)));
    t('그 앞(옛) 조정 줄에는 표가 없다', txt(q(r3)) === '|전 34 → 수정재고 33|(증감 -1)|' && !/led-last/.test(q(r3)) && !/led-last/.test(q(r4)));
    t('같은 줄의 사본(ledgerSeq 같음)도 최근으로 본다 · 말풍선에 「최근에 수정한 현재고 31」', /led-last/.test(q(Object.assign({}, r2))) && /최근에 수정한 현재고 31/.test(q(r2)));
    const e0 = make({ resp: { result: 'OK', data: [] }, raw: [ { ledgerSeq: 3, ioGb: 'A', qty: 5 }, r3 ] });
    t('전·후 값이 없는 조정(이력 없음)은 건너뛰고 그다음 줄이 최근', /led-last/.test(e0.api.qty(r3)) && e0.api.qty({ ledgerSeq: 3, ioGb: 'A', qty: 5 }) === '5');
  }
  /* ── 1-3. 「조정 전 반영」 — 최근 조정 위에 보이지만 조정할 때 이미 빠져 있던 출고 (2026-11-22 · 운영 1000713440 그대로) ── */
  {
    const o1 = { ledgerSeq: 9, ioGb: 'O', qty: 1, trxDt: '20261022', regDttm: '2026-10-22 10:28:53', srcDttm: '2026-10-21 15:40:04' };   /* 조정 뒤에 올라온 출고 */
    const o2 = { ledgerSeq: 8, ioGb: 'O', qty: 1, trxDt: '20260918', regDttm: '2026-09-21 11:13:05', srcDttm: '2026-09-17 08:55:15' };   /* 조정(09:48) 전에 이미 올라와 있던 출고 */
    const ad = { ledgerSeq: 7, ioGb: 'A', qty: 33, trxDt: '20260917', regDttm: '2026-09-17 09:48:15', adjBef: -7, adjAft: 26 };
    const o3 = { ledgerSeq: 6, ioGb: 'O', qty: 1, trxDt: '20260825', regDttm: '2026-09-11 18:53:21', srcDttm: '2026-08-24 10:27:38' };   /* 조정 줄 아래(옛 일자) */
    const e = make({ resp: { result: 'OK', data: [] }, raw: [ o1, o2, ad, o3 ], row: { prodCd: '1000713440', curQty: 25 } }), q = e.api.qty, txt = (h) => String(h).replace(/<[^>]+>/g, '|').replace(/\|+/g, '|');
    t('★조정 전에 이미 올라와 있던 출고(09-18) — 수량 앞 회색 「조정 전 반영」', txt(q(o2)) === '|조정 전 반영|1|' && /class="led-pre"/.test(q(o2)), txt(q(o2)));
    t('말풍선에 올라온 때·조정한 때 — 「2026-09-17 08:55 에 이미 … 최근 조정(2026-09-17 09:48) 전」', /2026-09-17 08:55 에 이미 올라와 있었습니다/.test(q(o2)) && /최근 조정\(2026-09-17 09:48\) 전/.test(q(o2)));
    t('조정 뒤에 올라온 출고(10-22)는 표시 없음 — 숫자 그대로', q(o1) === '1');
    t('조정 줄 아래(옛 일자) 출고는 표시 없음', q(o3) === '1');
    t('★최근재고 말풍선 검산 — 「조정 뒤 새로 반영된 입출고 -1 → 25 = 지금 현재고」', /조정 뒤 새로 반영된 입출고 -1 → 25 = 지금 현재고/.test(q(ad)), (q(ad).match(/조정 뒤[^"]*/) || [''])[0]);
    const e2 = make({ resp: { result: 'OK', data: [] }, raw: [ o1, o2, ad, o3 ], row: { prodCd: '1000713440', curQty: 99 } });
    t('현재고와 안 맞으면 「= 지금 현재고」는 안 붙인다', /조정 뒤 새로 반영된 입출고 -1 → 25/.test(e2.api.qty(ad)) && !/= 지금 현재고/.test(e2.api.qty(ad)));
    const e3 = make({ resp: { result: 'OK', data: [] }, raw: [ { ledgerSeq: 9, ioGb: 'O', qty: 1, srcDttm: '2026-09-17 08:55:15' }, o3 ] });
    /* 등록일시 칸 — 처음 올린 시간 + ↻ 다시 만든 때 (2026-11-22 「표시가 21일 나중인데 맞나요」 → 「네, 같이 표시」) */
    const rg = e.api.reg, tx = (h) => String(h).replace(/<[^>]+>/g, '');
    t('★등록일시 — 09-18 출고 : 처음 올린 시간 앞 + 「↻ 09-21 11:13」', tx(rg(o2)) === '2026-09-17 08:55:15 ↻ 09-21 11:13' && /class="led-src"/.test(rg(o2)) && /다시 만들어진 때 2026-09-21 11:13:05/.test(rg(o2)), tx(rg(o2)));
    t('등록일시 — 10-22 출고도 처음 올린 시간(10-21 15:40) + ↻', tx(rg(o1)) === '2026-10-21 15:40:04 ↻ 10-22 10:28', tx(rg(o1)));
    t('등록일시 — 조정·입고 줄은 종전 글자 그대로', rg(ad) === '2026-09-17 09:48:15' && rg({ ioGb: 'I', regDttm: '2026-01-03 10:00:00', srcDttm: '2026-01-01 09:00:00' }) === '2026-01-03 10:00:00');
    t('등록일시 — 올린 시간이 없거나(옛 서버·판매전표) 같은 분이면 종전 그대로', rg({ ioGb: 'O', regDttm: '2026-09-21 11:13:05' }) === '2026-09-21 11:13:05' && rg({ ioGb: 'O', regDttm: '2026-09-17 08:55:40', srcDttm: '2026-09-17 08:55:15' }) === '2026-09-17 08:55:40' && rg(null) === '' && rg({ ioGb: 'O' }) === '');
    /* 등록자 칸 — 처음 올린 사람도 같이 (2026-11-22) */
    const us = (x) => e3.api.user(x);
    const u1 = us({ ioGb: 'O', regUser: 'admin', regUserNm: '마스터', srcUser: 'K003', srcUserNm: '김담당' });
    t('등록자 — 처음 올린 사람이 다르면 앞에 그 사람 · 뒤에 ↻ 다시 만든 사람', u1.indexOf('class="led-src"') >= 0 && u1.indexOf('>김담당</span>') >= 0 && u1.indexOf('>↻ 마스터</span>') >= 0 && u1.indexOf('(K003)') >= 0 && u1.indexOf('(admin)') >= 0);
    t('등록자 — 같은 사람이면 이름 하나', us({ ioGb: 'O', regUser: 'admin', regUserNm: '마스터', srcUser: 'admin ', srcUserNm: '마스터' }) === '마스터');
    t('등록자 — 처음 올린 사람을 모르면(옛 서버·판매전표) 종전 그대로', us({ ioGb: 'O', regUser: 'K002', regUserNm: '이담당' }) === '이담당' && us({ ioGb: 'O', regUser: 'K002' }) === 'K002' && us(null) === '');
    t('등록자 — 입고·조정 줄은 종전 그대로', us({ ioGb: 'A', regUser: 'admin', regUserNm: '마스터', srcUser: 'K003' }) === '마스터');
    t('등록자 — 이름을 모르면 아이디로', us({ ioGb: 'O', regUser: 'admin', regUserNm: '마스터', srcUser: 'K009' }).indexOf('>K009</span>') >= 0);
    t('조정이 없는 품목 — 표시 없음', e3.api.qty({ ledgerSeq: 9, ioGb: 'O', qty: 1, srcDttm: '2026-09-17 08:55:15' }) === '1');
    const e4 = make({ resp: { result: 'OK', data: [] }, raw: [ { ledgerSeq: 8, ioGb: 'O', qty: 1 }, ad ] });
    t('원천 시각이 없는 줄(옛 서버·판매전표) — 표시 없음', e4.api.qty({ ledgerSeq: 8, ioGb: 'O', qty: 1 }) === '1');
    t('매칭코드로 걸러 본 사본(ledgerSeq 같음)도 같은 표시', /led-pre/.test(q(Object.assign({}, o2))));
  }
  /* ── 2. 승인 대기 줄 ── */
  {
    const rows = [ { prodSeq: 11, prodCd: '9904010001', prodNm: '종이컵', packQty: 10, befQty: 100, aftBox: 9, aftEa: 5 },
                   { prodSeq: 12, prodCd: '9904010002', prodNm: '뚜껑', packQty: 1, befQty: 40, aftBox: 60, aftEa: 0 },
                   { prodSeq: 13, prodCd: '9904010003', prodNm: '빨대', packQty: 1, befQty: 7, aftBox: 7, aftEa: 0 } ];
    const e = make({ resp: { result: 'OK', admin: 'N', me: 'K003', data: [ REQ(5, 'P', rows), REQ(6, 'A', rows), REQ(7, 'P', [ { prodSeq: 99, prodCd: '9904010002', packQty: 1, befQty: 60, aftBox: 58, aftEa: 0 } ], { remark: '<파손>' }) ] } });
    const row = { prodSeq: 12, prodCd: '9904010002' };
    const h0 = e.api.pend(row);
    t('처음 그릴 때는 줄 없이 — 요청 목록을 한 번 읽는다(pendOnly=Y)', h0 === '' && e.calls.length === 1 && e.calls[0].url === '/konet/prod/stockAdjReqList.do' && e.calls[0].body === 'pendOnly=Y', JSON.stringify(e.calls));
    await sleep(10);
    t('목록이 오면 수불 내역을 한 번 다시 그린다', e.paints === 1, e.paints);
    const h = e.api.pend(row), C = cells(h);
    t('★그 품목의 대기 줄 2건(요청 #5 · #7) — 승인된 #6 은 안 나온다', C.length === 2 && /#5/.test(C[0][9]) && /#7/.test(C[1][9]), C.map(c => c[9]).join(','));
    t('칸 13개 — 수불 내역 머리글과 같다', C.every(c => c.length === 13) && (jsp.match(/<th[^>]*>일자<\/th><th>품목코드<\/th><th>구분<\/th>[\s\S]*?<th>등록자<\/th>/) || [''])[0].split('<th').length - 1 === 13, C.map(c => c.length).join(','));
    t('일자 = 요청 기준일자 · 품목코드 · 구분 「승인 대기」', C[0][0] === '2026-11-22' && C[0][1] === '9904010002' && /승인 대기/.test(C[0][2]), C[0].slice(0, 3).join('|'));
    t('★수량 칸 — 「40 → 60」 + 「+20」 (입력한 수량이 60)', C[0][3] === '전 40 → 후 60(증감 +20)', C[0][3]);
    t('둘째 줄 — 품목코드로 맞춘 요청(prodSeq 다름) 「60 → 58」 「-2」', C[1][3] === '전 60 → 후 58(증감 -2)', C[1][3]);
    t('근거 「요청」 · 비고 = 사유 + 「아직 재고에 반영 안 됨」 · 등록일시·요청자', C[0][8] === '요청' && /실사 5/.test(C[0][10]) && /아직 재고에 반영 안 됨/.test(C[0][10]) && C[0][11] === '2026-11-22 10:00:00' && C[0][12] === '전원배', C[0].slice(8).join('|'));
    t('사유의 < > 는 글자로', /&lt;파손&gt;/.test(h) && !/<파손>/.test(h));
    t('줄에 표식(led-pend · data-req) · 말풍선에 「현재고와 달 합계에는 들어 있지 않습니다」', /class="led-pend" data-req="5"/.test(h) && /현재고와 달 합계에는 들어 있지 않습니다/.test(h));
    t('증감 0 인 품목(빨대)은 줄이 없다', e.api.pend({ prodSeq: 13, prodCd: '9904010003' }) === '');
    t('입수 10 품목 — 9박스 5개 = 95 「100 → 95」 「-5」', cells(e.api.pend({ prodSeq: 11, prodCd: '9904010001' }))[0][3] === '전 100 → 후 95(증감 -5)');
    t('요청이 없는 품목은 줄 없음', e.api.pend({ prodSeq: 500, prodCd: '1000000000' }) === '');
    t('30초 안에는 다시 묻지 않는다', e.calls.length === 1, e.calls.length);
    e.ext = '1000455367';
    t('매칭코드로 걸러 보는 중에는 안 그린다', e.api.pend(row) === '');
    e.ext = '';
    /* 30초 뒤 — 같은 내용이면 다시 그리지 않는다 */
    e.now += 31000; e.api.pend(row); await sleep(10);
    t('30초가 지나면 다시 읽는다 · 내용이 같으면 다시 그리지 않는다', e.calls.length === 2 && e.paints === 1, e.calls.length + '/' + e.paints);
    /* 승인돼 #5 가 사라짐 */
    e.resp = { result: 'OK', data: [ REQ(7, 'P', [ { prodSeq: 99, prodCd: '9904010002', packQty: 1, befQty: 60, aftBox: 58, aftEa: 0 } ]) ] };
    e.now += 31000; e.api.pend(row); await sleep(10);
    t('★승인돼 요청이 빠지면 다시 그리고 그 줄이 사라진다', e.paints === 2 && cells(e.api.pend(row)).length === 1 && /#7/.test(cells(e.api.pend(row))[0][9]), e.paints);
  }
  /* ── 2-2. [입·출고 나누어보기] 창의 승인 대기 묶음 (2026-11-22) ── */
  {
    const rows = [ { prodSeq: 12, prodCd: '9904010002', prodNm: '뚜껑 92파이', packQty: 1, befQty: 40, aftBox: 60, aftEa: 0 } ];
    const e = make({ resp: { result: 'OK', data: [ REQ(5, 'P', rows), REQ(7, 'P', [ { prodSeq: 12, prodCd: '9904010002', packQty: 1, befQty: 60, aftBox: 58, aftEa: 0 } ]) ] } });
    const row = { prodSeq: 12, prodCd: '9904010002', prodNm: '뚜껑 92파이(마스터)' };
    e.popOn = true;
    t('처음엔 묶음 없이 목록을 읽는다', e.api.split(row) === '' && e.calls.length === 1);
    await sleep(10);
    t('★목록이 오면 열려 있는 나누어보기 창도 다시 그린다', e.splits === 1 && e.paints === 1, e.splits + '/' + e.paints);
    const h = e.api.split(row), C = cells(h).filter(c => c.length);   /* 머리글 줄(td 없음)은 뺀다 */
    t('묶음 제목 「⏳ 승인 대기 2건 · 증감 합 +18 · 아직 재고에 반영 안 됨」', /class="sp-pend"/.test(h) && /⏳ 승인 대기/.test(h) && /<b>2<\/b>건 · 증감 합 <b>\+18<\/b>/.test(h), h.slice(0, 200).replace(/<[^>]+>/g, ' '));
    const ths = (h.match(/<th[ >]/g) || []).length;
    t('칸 11개 — 그 창의 입고 표와 같다(머리글 11 · 줄 11)', ths === 11 && C.length === 2 && C.every(c => c.length === 11), ths + '/' + C.map(c => c.length).join(','));
    t('줄 — No · 일자 · 품목코드 · 품목명 · 「전 40 → 후 60(증감 +20)」 · 요청자 · 요청 #5', C[0][0] === '1' && C[0][1] === '2026-11-22' && C[0][2] === '9904010002' && C[0][3] === '뚜껑 92파이' && C[0][4] === '전 40 → 후 60(증감 +20)' && /전원배/.test(C[0][7]) && C[0][8] === '요청' && C[0][9] === '#5' && /아직 재고에 반영 안 됨/.test(C[0][10]), C[0].join('|'));
    t('요청 줄에 품목명이 없으면 고른 품목 이름', C[1][3] === '뚜껑 92파이(마스터)' && C[1][4] === '전 60 → 후 58(증감 -2)', C[1].join('|'));
    t('요청이 없는 품목은 묶음 자체가 없다', e.api.split({ prodSeq: 500, prodCd: '1' }) === '');
    e.sext = '1000455367';
    t('매칭코드로 걸러 보는 중에는 안 그린다', e.api.split(row) === '');
    e.sext = ''; e.popOn = false; e.resp = { result: 'OK', data: [] }; e.now += 31000; e.api.split(row); await sleep(10);
    t('창이 닫혀 있으면 다시 그리지 않는다(수불 내역만)', e.splits === 1 && e.paints === 2, e.splits + '/' + e.paints);
  }
  /* ── 3. 못 읽을 때 ── */
  {
    const e = make({ resp: 'fail' }); const row = { prodSeq: 12, prodCd: '9904010002' };
    e.api.pend(row); await sleep(10);
    t('옛 서버(404) — 줄 없이 종전 화면 · 다시 그리지 않는다', e.api.pend(row) === '' && e.paints === 0 && e.calls.length === 1, e.paints + '/' + e.calls.length);
    e.now += 31000; e.api.pend(row); await sleep(10);
    t('실패 뒤 30초로는 다시 안 묻는다(60초)', e.calls.length === 1, e.calls.length);
    e.now += 31000; e.api.pend(row); await sleep(10);
    t('60초가 지나면 다시 묻는다', e.calls.length === 2, e.calls.length);
    const e2 = make({ resp: { result: 'FAIL', login: true } }); e2.api.pend(row); await sleep(10);
    t('로그인 끊김(FAIL) — 줄 없음 · 오류 없음', e2.api.pend(row) === '' && e2.paints === 0);
    t('품목을 안 골랐으면 아무것도 안 한다', e2.api.pend(null) === '');
  }
  /* ── 4. 화면이 부르는 자리 ── */
  t('JSP — 수불 내역 등록자 칸은 stkLedUser(l)', jsp.indexOf("+'\">'+stkLedUser(l)+'</td></tr>'") >= 0);
  t('JSP — 수불 내역 등록일시 칸은 stkLedReg(l)', jsp.indexOf("<td style=\"color:#9aa7b3\">'+stkLedReg(l)+'</td>'") >= 0);
  t('JSP — 나누어보기 창 출고내역 수량 칸도 stkLedQty(l)', jsp.indexOf("color:#b06a00\">'+stkLedQty(l)+'</td>')") >= 0);
  { /* 나누어보기 창 세 표의 등록자 칸 (2026-11-22) — 머리글 두 벌 · 자료 줄 두 벌 · ↳ 하위 줄 12칸 */
    const a = jsp.indexOf('function _stkSplitTb('), b = jsp.indexOf("+th+'<tbody>'+body+'</tbody></table></div>';", a), blk = jsp.slice(a, b);
    const thIn = (blk.match(/<thead><tr>[^']*<\/tr><\/thead>/g) || []);
    t('JSP — 나누어보기 창 머리글 두 벌 모두 12칸 · 맨 뒤 등록자', thIn.length === 2 && thIn.every(h => (h.match(/<th[ >]/g) || []).length === 12 && />등록자<\/th><\/tr><\/thead>$/.test(h)), thIn.map(h => (h.match(/<th[ >]/g) || []).length).join(','));
    t('JSP — 나누어보기 창 자료 줄 두 벌의 맨 뒤 칸은 stkLedUser(l)', blk.split("'+stkLedUser(l)+'</td></tr>'+_sub(l)").length === 3);
    t('JSP — 나누어보기 창 ↳ 하위 줄도 12칸', blk.indexOf("+'<td></td><td></td><td></td><td></td></tr>';") >= 0);
  }
  t('JSP — 나누어보기 창 요약표 뒤에 stkSplitPend(r)', jsp.indexOf('_stkSplitTop(r, si, so) + stkSplitPend(r)') >= 0);
  t('JSP — 표 몸통 앞에 stkLedPend(row) · 수량 칸은 stkLedQty(l)', /'<tbody>'\+stkLedPend\(row\)\+body\+'<\/tbody>/.test(jsp) && /'\+stkLedQty\(l\)\+'<\/td>/.test(jsp));
  t('[입·출고 나누어보기] 팝업 「기타(반품·조정)」 표의 수량 칸도 stkLedQty(l)', jsp.indexOf("color:#137a6c\">'+stkLedQty(l)+'</td>')") >= 0);
  console.log((bad ? '✗ ' : '✓ ') + 'sim_stkLedPend : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
