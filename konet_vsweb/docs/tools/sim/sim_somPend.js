/* 월별 출고현황 하단 입고내역 — 맨 위 «승인 대기» 줄 + 조정 줄 «전 → 후 (증감)» 시뮬 (2026-11-22)
   stockOutMonth.jsp 의 somPendLoad · somPendRows · somDetailRender 를 꺼내 가짜 fetch·가짜 문서로 돌린다(jsdom 불필요).
   쓰는 법 : node docs/tools/sim/sim_somPend.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
const jsp = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp'), 'utf8').replace(/\r\n/g, '\n');
let ok = 0, bad = 0;
function t(name, cond, info){ if (cond) ok++; else { bad++; console.log('✗ ' + name + (info !== undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const a = jsp.indexOf('var _somPend={'), b = jsp.indexOf('/* ── 🔄 출고반영 재집계', a);
if (a < 0 || b < 0) { console.log('✗ 함수 자리를 못 찾음'); process.exit(1); }
const code = jsp.slice(a, b);

function make(resp){
  const env = { calls: [], now: 5000000, resp, els: {}, fits: 0 };
  const el = (id) => env.els[id] || (env.els[id] = { innerHTML: '', textContent: '' });
  const fetch = (url, opt) => { env.calls.push({ url, body: opt && opt.body });
    if (env.resp === 'fail') return Promise.resolve({ ok: false, status: 404, json: () => Promise.reject(new Error('x')) });
    return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(env.resp) }); };
  const f = new Function('fetch', 'Date', 'document', 'CTX', 'num', 'esc', 'dt8', 'srcCls', 'srcIco', 'somFit', 'ctl',
    'var DTL_LAST=null;' + code + '; return { render: function(sel, j, fr, to){ DTL_LAST=sel; somDetailRender(sel, j, fr, to); }, close: function(){ DTL_LAST=null; }, rows: somPendRows, st: _somPend };');
  env.api = f(fetch, { now: () => env.now }, { getElementById: el }, '/konet', (v) => Math.round(Number(v) || 0).toLocaleString('en-US'),
    (s) => ('' + (s == null ? '' : s)).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'),
    (d) => { d = '' + (d || ''); return /^\d{8}$/.test(d) ? (d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8)) : d; }, () => '', () => '', () => { env.fits++; });
  return env;
}
const REQ = (n, st, rows, extra) => Object.assign({ reqSeq: n, statGb: st, baseDt: '20261122', remark: '실사 ' + n, reqUser: 'K003', reqUserNm: '전원배', reqDttm: '2026-11-22 10:00:00', payload: JSON.stringify(rows) }, extra || {});
const cells = (h) => (h.match(/<tr[\s\S]*?<\/tr>/g) || []).filter(tr => /<td/.test(tr)).map(tr => (tr.match(/<td[\s\S]*?<\/td>/g) || []).map(td => td.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim()));
const SEL = { ym: '', g: { key: '#ALL', nm: '품목 합계' }, it: { cd: '1000732260', seq: 77 } };
const LED = [ { trxDt: '20261028', ioGb: 'A', qty: 1, adjBef: 30, adjAft: 31, remark: '상품코드등록에서 조정' }, { trxDt: '20260914', ioGb: 'A', qty: 43, adjBef: -9, adjAft: 34, remark: '재고 일괄조정' }, { trxDt: '20260301', ioGb: 'I', qty: 100, vendorNm: '매입처' } ];

(async () => {
  {
    const e = make({ result: 'OK', data: [ REQ(5, 'P', [ { prodSeq: 77, prodCd: '1000732260', packQty: 1, befQty: 30, aftBox: 45, aftEa: 0 }, { prodSeq: 78, prodCd: '9999', packQty: 1, befQty: 1, aftBox: 2, aftEa: 0 } ]),
                                           REQ(6, 'R', [ { prodSeq: 77, prodCd: '1000732260', packQty: 1, befQty: 30, aftBox: 99, aftEa: 0 } ]) ] });
    e.api.render(SEL, { out: [], ledger: LED }, '20260101', '20261122');
    let C = cells(e.els.dtlIn.innerHTML);
    t('처음 — 원장 줄 3 · 대기 목록을 한 번 읽는다(pendOnly=Y)', C.length === 3 && e.calls.length === 1 && e.calls[0].url === '/konet/prod/stockAdjReqList.do' && e.calls[0].body === 'pendOnly=Y', C.length + '/' + JSON.stringify(e.calls));
    t('조정 줄 — ★가장 최근 줄만 「최근재고」 표 + 「전 30 → 수정재고 31(증감 +1)」 · 옛 줄 「전 -9 → 수정재고 34(증감 +43)」 · 입고 줄은 숫자 그대로', C[0][2] === '최근재고전 30 → 수정재고 31(증감 +1)' && C[1][2] === '전 -9 → 수정재고 34(증감 +43)' && C[2][2] === '100' && (e.els.dtlIn.innerHTML.match(/class="led-last"/g) || []).length === 1, C.map(c => c[2]).join(' / '));
    await sleep(10);
    C = cells(e.els.dtlIn.innerHTML);
    t('★목록이 오면 다시 그려 맨 위에 승인 대기 줄 1(반려된 #6 은 없다)', C.length === 4 && /승인 대기/.test(C[0][1]) && C[0][4] === '요청 #5' && e.fits === 1, C.length + '/' + (C[0] || []).join('|'));
    t('칸 6개 — 입고내역 머리글과 같다', C.every(c => c.length === 6));
    t('대기 줄 — 일자 · 「전 30 → 후 45(증감 +15)」 · 요청자 · 사유 + 「아직 재고에 반영 안 됨」', C[0][0] === '2026-11-22' && C[0][2] === '전 30 → 후 45(증감 +15)' && C[0][3] === '전원배' && /실사 5/.test(C[0][5]) && /아직 재고에 반영 안 됨/.test(C[0][5]), C[0].join('|'));
    t('★머리 합계는 원장 줄만(3건 · 144) + 조정 수정재고 + 「승인 대기 1건」', e.els.dtlInSum.textContent === '3건 · 144 · 조정 +44 (2회 · 마지막 수정재고 31) · 승인 대기 1건', e.els.dtlInSum.textContent);
    t('30초 안에는 다시 묻지 않는다', e.calls.length === 1);
    /* 원장이 없는 품목 — 대기 줄만 */
    e.api.render(SEL, { out: [], ledger: [] }, '20260101', '20261122');
    C = cells(e.els.dtlIn.innerHTML);
    t('입고가 없어도 대기 줄은 보인다 · 머리 「승인 대기 1건」', C.length === 1 && /승인 대기/.test(C[0][1]) && e.els.dtlInSum.textContent === '승인 대기 1건' && !/입고가 없습니다/.test(e.els.dtlIn.innerHTML), e.els.dtlInSum.textContent);
    /* 다른 품목 */
    e.api.render({ ym: '', g: SEL.g, it: { cd: '5555', seq: 5 } }, { out: [], ledger: [] }, '20260101', '20261122');
    t('요청이 없는 품목 — 「입고가 없습니다」 그대로', /입고가 없습니다/.test(e.els.dtlIn.innerHTML) && e.els.dtlInSum.textContent === '');
    /* 승인돼 사라짐 */
    e.api.render(SEL, { out: [], ledger: LED }, '20260101', '20261122');
    e.resp = { result: 'OK', data: [] }; e.now += 31000;
    e.api.render(SEL, { out: [], ledger: LED }, '20260101', '20261122'); await sleep(10);
    C = cells(e.els.dtlIn.innerHTML);
    t('★승인돼 요청이 빠지면 다시 그려 대기 줄이 사라진다', C.length === 3 && e.els.dtlInSum.textContent === '3건 · 144 · 조정 +44 (2회 · 마지막 수정재고 31)' && e.calls.length === 2, C.length + '/' + e.els.dtlInSum.textContent);
  }
  {
    const e = make('fail');
    e.api.render(SEL, { out: [], ledger: LED }, '20260101', '20261122'); await sleep(10);
    t('옛 서버(404) — 대기 줄 없이 종전 화면 · 다시 그리지 않는다', cells(e.els.dtlIn.innerHTML).length === 3 && e.fits === 0 && e.els.dtlInSum.textContent === '3건 · 144 · 조정 +44 (2회 · 마지막 수정재고 31)');
    e.now += 31000; e.api.render(SEL, { out: [], ledger: LED }, '20260101', '20261122'); await sleep(10);
    t('실패 뒤 30초로는 다시 안 묻는다 · 60초 뒤엔 묻는다', e.calls.length === 1 && (e.now += 31000, e.api.render(SEL, { out: [], ledger: LED }, '20260101', '20261122'), e.calls.length === 2), e.calls.length);
  }
  {
    /* 내역을 닫은 뒤 늦게 온 응답 — 다시 그리지 않는다 */
    const e = make({ result: 'OK', data: [ REQ(5, 'P', [ { prodSeq: 77, prodCd: '1000732260', packQty: 1, befQty: 30, aftBox: 45, aftEa: 0 } ]) ] });
    e.api.render(SEL, { out: [], ledger: LED }, '20260101', '20261122'); e.api.close(); await sleep(10);
    t('내역을 닫았으면 늦게 온 목록으로 다시 그리지 않는다', e.fits === 0);
  }
  {
    /* ── 출고내역 «올라온 때» + 「조정 전 반영」 (2026-11-22 「여기도 마찬가지로 시간표시」 — 운영 1000713440 그대로) ── */
    const e = make({ result: 'OK', data: [] });
    const OUT = [ { dlvDt: '20261022', bizNm: '명동피자(신논현점)', mtNm: '명동피자', dcNm: '평택물류센터', src: '정산서', qty: 1, srcDttm: '2026-10-21 15:40:04' },
                  { dlvDt: '20260918', bizNm: '명동피자(명동본점-창고)', mtNm: '명동피자', dcNm: '평택물류센터', src: '정산서', qty: 1, srcDttm: '2026-09-17 08:55:15' },
                  { dlvDt: '20260825', bizNm: '명동피자(신논현점)', mtNm: '명동피자', dcNm: '평택물류센터', src: '정산서', qty: 1, srcDttm: '2026-08-24 10:27:38' },
                  { dlvDt: '20260801', bizNm: '거래처 (판매전표)', mtNm: '', dcNm: '', src: '판매전표', qty: 3 } ];
    const LD = [ { trxDt: '20260917', ioGb: 'A', qty: 33, adjBef: -7, adjAft: 26, regDttm: '2026-09-17 09:48:15', remark: '재고 일괄조정' } ];
    e.api.render(SEL, { out: OUT, ledger: LD }, '20260101', '20261122'); await sleep(10);
    const O = cells(e.els.dtlOut.innerHTML), H = e.els.dtlOut.innerHTML;
    t('출고내역 칸 8개 — 수량 · 올린 시간 · 등록자 차례', (H.match(/<th[ >]/g) || []).length === 8 && /<th>수량<\/th><th[^>]*>올린 시간<\/th><th[^>]*>등록자<\/th><\/tr>/.test(H) && O.every(c => c.length === 8), (H.match(/<th[ >]/g) || []).length + '/' + O.map(c => c.length).join(','));
    t('★올린 시간 = 연-월-일 시:분:초 (품목별재고현황 등록일시와 같은 꼴)', O[0][6] === '2026-10-21 15:40:04' && O[2][6] === '2026-08-24 10:27:38', O.map(c => c[6]).join(' | '));
    t('★조정(09-17 09:48) 전에 올린 09-18 출고 — 수량 앞 「조정 전 반영」 + 뒤 칸에 시간', O[1][5] === '조정 전 반영1' && O[1][6] === '2026-09-17 08:55:15' && /2026-09-17 08:55 에 이미 올라와 있었습니다/.test(H) && /최근 조정\(2026-09-17 09:48\) 전/.test(H), O[1][5]);
    t('조정 뒤에 올라온 출고 · 조정 일자보다 앞 일자의 출고에는 표가 없다', O[0][5] === '1' && O[2][5] === '1' && (H.match(/class="led-pre"/g) || []).length === 1);
    t('판매전표 줄은 시간 빈 칸', O[3][6] === '' && O[3][5] === '3');
    const I = cells(e.els.dtlIn.innerHTML);
    t('입고내역 조정 줄 — 일자 옆에 저장한 시각(같은 날이면 시:분)', I[0][0] === '2026-09-17 09:48', I[0][0]);
    e.api.render(SEL, { out: OUT, ledger: [ { trxDt: '20260917', ioGb: 'A', qty: 33, adjBef: -7, adjAft: 26, regDttm: '2026-09-19 10:00:00' } ] }, '20260101', '20261122');
    t('★조정 한 번 — 머리 「1건 · 33 · 조정 +33 (전 -7 → 수정재고 26)」', e.els.dtlInSum.textContent === '1건 · 33 · 조정 +33 (전 -7 → 수정재고 26)', e.els.dtlInSum.textContent);
    e.api.render(SEL, { out: [], ledger: [ { trxDt: '20260917', ioGb: 'A', qty: 33 }, { trxDt: '20260910', ioGb: 'I', qty: 10 } ] }, '20260101', '20261122');
    t('전·후 값이 안 오면(옛 서버) 머리는 종전 글자', e.els.dtlInSum.textContent === '2건 · 43', e.els.dtlInSum.textContent);
    e.api.render(SEL, { out: OUT, ledger: [ { trxDt: '20260917', ioGb: 'A', qty: 33, adjBef: -7, adjAft: 26, regDttm: '2026-09-19 10:00:00' } ] }, '20260101', '20261122');
    t('기준일자와 저장한 날이 다르면 월-일까지', cells(e.els.dtlIn.innerHTML)[0][0] === '2026-09-17 09-19 10:00', cells(e.els.dtlIn.innerHTML)[0][0]);
    e.api.render(SEL, { out: OUT, ledger: [] }, '20260101', '20261122');
    t('조정이 없으면 시각만 — 표 없음', !/led-pre/.test(e.els.dtlOut.innerHTML) && cells(e.els.dtlOut.innerHTML)[1][5] === '1' && cells(e.els.dtlOut.innerHTML)[1][6] === '2026-09-17 08:55:15');
    e.api.render(SEL, { out: OUT.map(o => Object.assign({}, o, { srcDttm: undefined })), ledger: LD }, '20260101', '20261122');
    /* 「↻ 다시 만든 때」 — 품목별재고현황 등록일시 칸과 같은 모양 (2026-11-22 「월별재고현황에도」 · 운영 값 그대로) */
    const LED = { '20261022': '2026-10-22 10:28:53', '20260918': '2026-09-21 11:13:05', '20260825': '2026-08-24 10:27:50' };
    e.api.render(SEL, { out: OUT.map(o => Object.assign({}, o, { ledDttm: LED[o.dlvDt] })), ledger: LD }, '20260101', '20261122');
    const O2 = cells(e.els.dtlOut.innerHTML), H2 = e.els.dtlOut.innerHTML;
    t('★올린 시간 뒤에 「↻ 09-21 11:13」 — 재고 줄이 다시 만들어진 때', O2[1][6] === '2026-09-17 08:55:15 ↻ 09-21 11:13' && O2[0][6] === '2026-10-21 15:40:04 ↻ 10-22 10:28' && /다시 만들어진 때 2026-09-21 11:13:05/.test(H2), O2.map(c => c[6]).join(' | '));
    t('같은 분이면 ↻ 없이 올린 시간만 · 판매전표 줄은 빈 칸', O2[2][6] === '2026-08-24 10:27:38' && O2[3][6] === '' && (H2.match(/class="led-re"/g) || []).length === 2);
    t('↻ 가 붙어도 「조정 전 반영」 판정은 그대로(09-18 줄 하나)', O2[1][5] === '조정 전 반영1' && (H2.match(/class="led-pre"/g) || []).length === 1);
    e.api.render(SEL, { out: [ { dlvDt: '20260918', bizNm: 'x', src: '정산서', qty: 1, ledDttm: '2026-09-21 11:13:05' } ], ledger: LD }, '20260101', '20261122');
    t('올린 시간이 없고 다시 만든 때만 있으면 그것만', cells(e.els.dtlOut.innerHTML)[0][6] === '2026-09-21 11:13:05' && !/led-pre|led-re/.test(e.els.dtlOut.innerHTML));
    e.api.render(SEL, { out: OUT.map(o => Object.assign({}, o, { srcDttm: undefined })), ledger: LD }, '20260101', '20261122');
    /* 「등록자」 칸 — 처음 올린 사람 ↻ 다시 만든 사람 (2026-11-22 「월별재고현황도 같은 스타일로」 · 운영 1000718242 모양) */
    const USR = [ { dlvDt: '20261112', bizNm: 'a', src: '정산서', qty: 1, srcDttm: '2026-11-11 10:41:38', ledDttm: '2026-11-13 19:08:53', srcUser: 'K003', srcUserNm: '김담당', ledUser: 'admin', ledUserNm: '마스터' },
                  { dlvDt: '20260815', bizNm: 'b', src: '정산서', qty: 1, srcUser: 'admin', srcUserNm: '마스터', ledUser: 'admin ', ledUserNm: '마스터' },
                  { dlvDt: '20260824', bizNm: 'c', src: '정산서', qty: 1, srcUser: '', ledUser: 'admin', ledUserNm: '마스터' },
                  { dlvDt: '20260801', bizNm: 'd', src: '판매전표', qty: 3 },
                  { dlvDt: '20260701', bizNm: 'e', src: '발주현황표', qty: 2, srcUser: 'K009', ledUser: 'admin', ledUserNm: '마스터' } ];
    e.api.render(SEL, { out: USR, ledger: [] }, '20260101', '20261122');
    const O3 = cells(e.els.dtlOut.innerHTML), H3 = e.els.dtlOut.innerHTML;
    t('★등록자 — 처음 올린 사람이 다르면 「김담당 ↻ 마스터」', O3[0][7] === '김담당 ↻ 마스터' && /처음 올린 사람 \(K003\)/.test(H3) && /다시 만든 사람 \(admin\)/.test(H3), O3.map(c => c[7]).join(' | '));
    t('등록자 — 같은 사람이면 이름 하나 · 한쪽만 알면 그 사람', O3[1][7] === '마스터' && O3[2][7] === '마스터');
    t('등록자 — 판매전표 줄은 빈 칸 · 이름을 모르면 아이디', O3[3][7] === '' && O3[4][7] === 'K009 ↻ 마스터');
    e.api.render(SEL, { out: OUT.map(o => Object.assign({}, o, { srcDttm: undefined })), ledger: LD }, '20260101', '20261122');
    t('옛 서버(올린 시간 없음) — 빈 칸 · 표 없음 · 오류 없음', cells(e.els.dtlOut.innerHTML).every(c => c.length === 8 && c[6] === '' && c[7] === '') && !/led-pre/.test(e.els.dtlOut.innerHTML));
  }
  console.log((bad ? '✗ ' : '✓ ') + 'sim_somPend : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
