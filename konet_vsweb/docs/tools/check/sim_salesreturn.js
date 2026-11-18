/* 반품내역(mangr/salesReturn.jsp) 시뮬 — 2026-11-18
   · 화면 JSP 를 jsdom 에 올리고 /mangr/salesReturnList.do 응답을 흉내 낸다. 진짜 xlsx-js-style 로 엑셀 시트까지 만들어 본다(writeFile 만 가로챈다).
   · 줄 = 인자로 준 DbRead 출력 파일(운영 줄 그대로) — 없으면 아래 견본 9줄.
   · 둘째 인자 = 반품율의 분모(selectSalesReturnBase) DbRead 출력 파일들이 든 폴더(DbRead 가 500줄에서 끊어 달·코드로 나눠 받는다) — 없으면 견본.
       node docs/tools/check/sqlof.js selectSalesReturnList compCd=… frDt=… toDt=… → DbRead → rows.txt
       node docs/tools/check/sim_salesreturn.js rows.txt
   · 셋째·넷째 인자 = 매입 꼴(매입 관리 ▸ 매입 반품내역, 같은 JSP 의 kind=P)의 줄 파일 · 분모 폴더 — 없으면 견본.
   · jsdom 은 wnn_medcost 의 것을 빌린다(README). */
const fs = require('fs'), path = require('path');
const { JSDOM } = require('C:/Users/user/git/winn/wnn_medcost/docs/tools/sim/node_modules/jsdom');
const ROOT = path.resolve(__dirname, '../../..');
const W = s => { let w = 0; for (const ch of s) w += (ch.charCodeAt(0) > 0x1100 ? 2 : 1); return w; };

/* DbRead 표(한글 두 칸 폭) → 줄 객체 */
function parseDbRead(file) {
  const L = fs.readFileSync(file, 'utf8').split(/\r?\n/); const hi = L.findIndex(l => /^-+( {2}-+)+$/.test(l)); if (hi < 1) throw new Error('DbRead 표를 못 찾음');
  const cols = []; let pos = 0; L[hi].split('  ').forEach(d => { cols.push([pos, d.length]); pos += d.length + 2; });
  const cut = line => { const out = []; let ci = 0, w = 0, cur = ''; for (const ch of line) { const c = cols[ci]; if (!c) break; if (w >= c[0] + c[1]) { out.push(cur.trim()); cur = ''; ci++; if (!cols[ci]) break; } if (w >= cols[ci][0]) cur += ch; w += (ch.charCodeAt(0) > 0x1100 ? 2 : 1); } out.push(cur.trim()); while (out.length < cols.length) out.push(''); return out; };
  const head = cut(L[hi - 1]), rows = [];
  for (let i = hi + 1; i < L.length; i++) { if (!L[i].trim() || /^줄 =/.test(L[i])) break; const a = cut(L[i]), o = {}; head.forEach((h, k) => { o[h] = a[k] === 'NULL' ? null : a[k]; }); ['qty', 'price', 'supplyAmt', 'amt'].forEach(k => { o[k] = Number(o[k]); }); rows.push(o); }
  return rows;
}
const SAMPLE = [
  { src: 'STL', dt: '20261118', dcNm: '평택', custNm: '', rcvNm: '', docNo: '5060785428', rowNo: '00010', itemCd: '1000812464', prodCd: '1000812464', itemNm: '용기 A', spec: '', unit: 'BOX', qty: 1, price: 72500, supplyAmt: 72500, amt: 72500, gb: '반품', remark: '' },
  { src: 'STL', dt: '20261019', dcNm: '평택', custNm: '', rcvNm: '', docNo: '5060385377', rowNo: '00010', itemCd: '1000731259', prodCd: '9904013376', itemNm: '용기 B', spec: '', unit: 'BOX', qty: 1, price: 62500, supplyAmt: 62500, amt: 62500, gb: '반품', remark: '' },
  { src: 'STL', dt: '20261014', dcNm: '오산', custNm: '', rcvNm: '', docNo: '5060327770', rowNo: '00010', itemCd: '1000745707', prodCd: '9904012967', itemNm: '용기 C', spec: '', unit: 'BOX', qty: 1, price: 45000, supplyAmt: 45000, amt: 45000, gb: '반품', remark: '' },
  { src: 'STL', dt: '20260915', dcNm: '평택', custNm: '', rcvNm: '', docNo: '5060000001', rowNo: '00010', itemCd: '1000731259', prodCd: '9904013376', itemNm: '용기 B', spec: '', unit: 'BOX', qty: 2, price: 62500, supplyAmt: 125000, amt: 125000, gb: '반품', remark: '' },
  { src: 'TRX', dt: '20261020', dcNm: '', custCd: '001554', custNm: '샐러드 플러스', rcvNm: '', docNo: '0002', rowNo: '4', itemCd: '1010009149', prodCd: '1010009149', itemNm: '샌드위치 박스 4호', spec: '120*110', unit: '', qty: 2, price: 88400, supplyAmt: 176800, amt: 194480, gb: '반품', remark: '' },
  { src: 'TRX', dt: '20261020', dcNm: '', custCd: '001554', custNm: '샐러드 플러스', rcvNm: '', docNo: '0002', rowNo: '6', itemCd: '9904013376', prodCd: '9904013376', itemNm: '용기 B(우리 이름)', spec: '', unit: '', qty: 3, price: 10000, supplyAmt: 30000, amt: 33000, gb: '불량반품', remark: '파손 "3"<b>' },
  { src: 'PO', dt: '20260925', dcNm: '대상', custCd: 'D1', custNm: '대상주식회사(급식)', rcvNm: '단대부고 영양사', docNo: 'DS261106161243', rowNo: '1', itemCd: '1010014032', prodCd: '1010014032', itemNm: '급식 친환경 종이컵', spec: '', unit: 'EA', qty: 1000, price: 62, supplyAmt: 62000, amt: 62000, gb: '반품', remark: '' },
  { src: 'PO', dt: '20260926', dcNm: 'TODER', custCd: '', custNm: '', rcvNm: '가맹점1', docNo: 'TD1', rowNo: '1', itemCd: 'X1', prodCd: null, itemNm: '토더 품목', spec: '', unit: '', qty: 2, price: 5000, supplyAmt: 10000, amt: 10000, gb: '반품', remark: '' },
  { src: 'STL', dt: '20260909', dcNm: '김해', custNm: '', rcvNm: '', docNo: '5060000002', rowNo: '00010', itemCd: '1000765248', prodCd: '9904013366', itemNm: '냉면용기', spec: '', unit: 'BOX', qty: 0, price: 38060, supplyAmt: 0, amt: 0, gb: '반품', remark: '' }
];
const ROWS = process.argv[2] ? parseDbRead(process.argv[2]) : SAMPLE;
const SAMPLE_BASE = [
  { src: 'STL', ym: '202611', place: '평택', cd: '1000812464', saleAmt: 1000000 }, { src: 'STL', ym: '202610', place: '평택', cd: '9904013376', saleAmt: 500000 },
  { src: 'STL', ym: '202610', place: '평택', cd: '', saleAmt: 3000000 }, { src: 'STL', ym: '202610', place: '오산', cd: '9904012967', saleAmt: 900000 },
  { src: 'STL', ym: '202609', place: '평택', cd: '9904013376', saleAmt: 250000 }, { src: 'STL', ym: '202609', place: '김해', cd: '9904013366', saleAmt: 100000 },
  { src: 'STL', ym: '202609', place: '광주', cd: '', saleAmt: 700000 },
  { src: 'TRX', ym: '202610', place: '샐러드 플러스', cd: '1010009149', saleAmt: 1944800 }, { src: 'TRX', ym: '202610', place: '샐러드 플러스', cd: '9904013376', saleAmt: 330000 },
  { src: 'TRX', ym: '202610', place: '샐러드 플러스', cd: '', saleAmt: 5000000 }, { src: 'PO', ym: '202609', place: '대상주식회사(급식)', cd: '1010014032', saleAmt: 620000 }
];
const BASE = process.argv[3] ? [].concat.apply([], fs.readdirSync(process.argv[3]).filter(f => /\.txt$/.test(f)).map(f => parseDbRead(path.join(process.argv[3], f)).map(o => { o.saleAmt = Number(o.saleAmt); o.cnt = Number(o.cnt); return o; }))) : SAMPLE_BASE;
const placeOf = r => r.src === 'STL' ? (r.dcNm || '') : ((r.custNm || '') || (r.dcNm || '')), codeOf = r => String(r.prodCd || r.itemCd || '');
const pct = (a, b) => b > 0 ? (a / b * 100).toFixed(2) + '%' : '-';
const bsum = f => BASE.reduce((a, b) => a + (f(b) ? b.saleAmt : 0), 0);

let pass = 0, fail = 0;
const ok = (c, m) => { if (c) pass++; else { fail++; console.log('  ✗ ' + m); } };
const num = s => Number(String(s).replace(/[^0-9.-]/g, ''));

(async () => {
  const unJsp = kind => fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/salesReturn.jsp'), 'utf8')
    .replace(/<c:choose><c:when test="\$\{kind == 'P'\}">([\s\S]*?)<\/c:when>\s*<c:otherwise>([\s\S]*?)<\/c:otherwise><\/c:choose>/g, (m, a, b) => kind === 'P' ? a : b).replace(/\$\{kind\}/g, kind === 'P' ? 'P' : '');
  let html = unJsp('S');
  ok(!/c:choose|c:when|\$\{kind/.test(html.replace(/<%--[\s\S]*?--%>/g, '')), 'JSP 조건 태그가 다 풀림');
  ok(html.indexOf('<title>매출 반품내역<' + '/title>') >= 0 && /<h2>↩️ 매출 반품내역 /.test(html), '매출 꼴 제목 = 매출 반품내역');
  html = html.replace(/<%--[\s\S]*?--%>/g, '').replace(/<%@[\s\S]*?%>/g, '').replace(/<c:out[^>]*\/>/g, '코네트').replace(/\$\{pageContext\.request\.contextPath\}/g, '')
             .replace(/<script src="[^"]*"><\/script>/g, '');
  const body = html.slice(html.indexOf('<body>'), html.indexOf('<script>')), js = html.slice(html.indexOf('<script>') + 8, html.lastIndexOf('</script>'));
  const dom = new JSDOM('<!DOCTYPE html><html>' + body + '</body></html>', { runScripts: 'dangerously', pretendToBeVisual: true, url: 'http://localhost/mangr/salesReturn.do' });
  const w = dom.window, d = w.document; const calls = [], alerts = [], toasts = []; let fetchRows = ROWS, fetchBase = BASE, fetchErr = null, books = [];
  w._alertBox = m => alerts.push(m); w._toast = m => toasts.push(m);
  w.fetch = (u, o) => { calls.push({ u, b: o.body }); return Promise.resolve({ json: () => Promise.resolve(fetchErr ? { error: fetchErr, data: [] } : Object.assign({ data: fetchRows.map(r => Object.assign({}, r)) }, fetchBase ? { base: fetchBase.map(r => Object.assign({}, r)) } : {})) }); };
  w.eval(fs.readFileSync(path.join(ROOT, 'src/main/webapp/assets/vendor/xlsx-js-style/xlsx.bundle.js'), 'utf8'));
  w.XLSX.writeFile = (wb, nm) => books.push({ wb, nm });
  w.eval(js);
  const tick = () => new Promise(r => setTimeout(r, 30));
  const $ = id => d.getElementById(id), pane = () => $('pane');
  await tick();

  /* 1) 시작 — 최근 3개월로 한 번 조회 */
  ok(calls.length === 1 && /salesReturnList\.do$/.test(calls[0].u), '시작 조회 1번');
  const t = new Date(), fr0 = new Date(t.getFullYear(), t.getMonth() - 2, 1);
  ok($('srFrom').value === fr0.getFullYear() + '-' + ('0' + (fr0.getMonth() + 1)).slice(-2) + '-01', '처음 기간 = 최근 3개월 첫날 : ' + $('srFrom').value);
  ok(/frDt=\d{4}-\d{2}-\d{2}&toDt=\d{4}-\d{2}-\d{2}$/.test(calls[0].b), '기간만 서버로 : ' + calls[0].b);

  /* 2) 내역 — 줄 수 · 합계 = 자료 합 */
  w.tab('d');
  const sumAmt = ROWS.reduce((a, r) => a + r.amt, 0), nItems = new Set(ROWS.map(r => String(r.prodCd || r.itemCd || ''))).size;
  let trs = pane().querySelectorAll('tbody > tr');
  ok(trs.length === ROWS.length + 1, '내역 줄 수 ' + (trs.length - 1) + ' = ' + ROWS.length);
  ok(num(pane().querySelector('tr.lg-tot td.amt').textContent) === Math.round(sumAmt), '내역 합계 = ' + Math.round(sumAmt));
  ok(num($('kCnt').textContent) === ROWS.length && num($('kAmt').textContent) === Math.round(sumAmt) && num($('kItem').textContent) === nItems, '카드 건수·반품액·품목 수');
  ok([...pane().querySelectorAll('thead th')].length === 12 && [...trs[0].children].length === 12, '머리 = 자료 칸 수 12');
  ok(!/<b>/.test(pane().innerHTML.replace(/<b>\d[^<]*<\/b>/g, '')) || !ROWS.some(r => /<b>/.test(r.remark || '')) || pane().innerHTML.indexOf('&lt;b&gt;') >= 0, '비고의 꺾쇠는 글자로');
  const saleAll = bsum(() => true);
  ok($('kRate').textContent === pct(sumAmt, saleAll), '카드 반품율 ' + $('kRate').textContent + ' = ' + pct(sumAmt, saleAll));
  ok($('kSale').textContent.indexOf('판매액 ' + Math.round(saleAll).toLocaleString('ko-KR') + '원 대비') === 0, '카드 분모 : ' + $('kSale').textContent);
  ok(pane().querySelector('tr.lg-tot').textContent.indexOf('반품율 ' + pct(sumAmt, saleAll)) > 0, '내역 합계 줄에 반품율');
  /* 날짜 내림차순(기본) */
  const dts = [...trs].slice(0, -1).map(tr => tr.children[0].textContent);
  ok(dts.every((x, i) => i === 0 || dts[i - 1] >= x), '기본 정렬 = 일자 최근 먼저');
  /* 정렬 — 반품액 큰 차례 */
  w.sortBy('amt'); trs = pane().querySelectorAll('tbody > tr');
  const amts = [...trs].slice(0, -1).map(tr => num(tr.children[10].textContent));
  ok(amts.every((x, i) => i === 0 || amts[i - 1] >= x), '반품액 정렬(큰 차례)');
  w.sortBy('amt'); trs = pane().querySelectorAll('tbody > tr');
  const amts2 = [...trs].slice(0, -1).map(tr => num(tr.children[10].textContent));
  ok(amts2.every((x, i) => i === 0 || amts2[i - 1] <= x), '다시 누르면 작은 차례');
  w.sortBy('dt');

  /* 3) 원천 거르기 — 카드의 원천별 칸은 원천을 골라도 그대로 */
  const by = {}; ROWS.forEach(r => { (by[r.src] = by[r.src] || { c: 0, a: 0 }); by[r.src].c++; by[r.src].a += r.amt; });
  const tags = () => [...$('kSrc').querySelectorAll('.tag')].map(x => x.textContent);
  const before = tags().join('|');
  ok(tags().length === 3 && tags()[0].indexOf('정산서' + (by.STL ? by.STL.c : 0) + '건') === 0, '원천별 칸 : ' + tags()[0]);
  w.srcPick('STL');
  ok($('srSrc').value === 'STL' && pane().querySelectorAll('tbody > tr').length === (by.STL ? by.STL.c : 0) + 1, '정산서만 = ' + (by.STL ? by.STL.c : 0) + '줄');
  ok(num($('kAmt').textContent) === Math.round(by.STL ? by.STL.a : 0), '카드 반품액 = 정산서 합');
  ok(tags().join('|') === before, '원천별 칸은 그대로');
  ok($('kRate').textContent === pct(by.STL ? by.STL.a : 0, bsum(b => b.src === 'STL')), '정산서만 반품율 ' + $('kRate').textContent);
  ok(tags()[0].indexOf(pct(by.STL ? by.STL.a : 0, bsum(b => b.src === 'STL'))) > 0, '원천별 칩에 반품율 : ' + tags()[0]);
  ok(/전체 \d+건 중 거른 것/.test($('info').textContent), '거른 표시');
  w.srcPick('STL'); ok($('srSrc').value === '' && pane().querySelectorAll('tbody > tr').length === ROWS.length + 1, '다시 누르면 전체');

  /* 4) 출고장·거래처 고르기 — 받은 줄에 있는 곳만, 반품액 큰 차례 */
  const opts = [...$('srPlace').options].map(o => o.value).filter(v => v);
  const places = {}; ROWS.forEach(r => { const p = r.src === 'STL' ? (r.dcNm || '') : ((r.custNm || '') || (r.dcNm || '')); if (p) places[p] = (places[p] || 0) + r.amt; });
  ok(opts.length === Object.keys(places).length, '곳 ' + opts.length + '개');
  ok(opts.every((p, i) => i === 0 || places[opts[i - 1]] >= places[p]), '곳 = 반품액 큰 차례');
  $('srPlace').value = opts[0]; w.render();
  const n0 = ROWS.filter(r => (r.src === 'STL' ? (r.dcNm || '') : ((r.custNm || '') || (r.dcNm || ''))) === opts[0]).length;
  ok(pane().querySelectorAll('tbody > tr').length === n0 + 1, '「' + opts[0] + '」 = ' + n0 + '줄');
  ok($('kRate').textContent === pct(ROWS.filter(r => placeOf(r) === opts[0]).reduce((a, r) => a + r.amt, 0), bsum(b => b.place === opts[0])), '곳 고르면 그 곳 판매액 대비 ' + $('kRate').textContent);
  $('srPlace').value = ''; w.render();

  /* 5) 검색 — 품목코드(주코드·정산서 코드 둘 다) */
  const withSub = ROWS.find(r => r.src === 'STL' && r.prodCd && r.itemCd && r.prodCd !== r.itemCd);
  if (withSub) {
    $('srFind').value = withSub.itemCd; w.render();
    const a = pane().querySelectorAll('tbody > tr').length - 1;
    $('srFind').value = withSub.prodCd; w.render();
    const b = pane().querySelectorAll('tbody > tr').length - 1;
    ok(a >= 1 && b >= a, '정산서 코드 ' + withSub.itemCd + ' ' + a + '줄 · 주코드 ' + withSub.prodCd + ' ' + b + '줄');
    { const q = withSub.prodCd.toLowerCase(), hit = ROWS.filter(r => [r.itemCd, r.prodCd, r.itemNm, r.spec, r.dcNm, r.custNm, r.rcvNm, r.docNo, r.remark, r.gb].join('|').replace(/\s+/g, '').toLowerCase().indexOf(q) >= 0);
      const cs = new Set(hit.map(codeOf)), want = pct(hit.reduce((x, r) => x + r.amt, 0), bsum(z => z.cd && cs.has(z.cd)));
      ok($('kRate').textContent === want && /^거른 품목 판매액/.test($('kSale').textContent), '검색 중 = 거른 품목 판매액 대비 ' + $('kRate').textContent + ' = ' + want); }
    $('srFind').value = '';
    w.render();
  }
  $('srFind').value = '없는글자zzz'; w.render();
  ok(/거른 조건에 맞는 반품이 없습니다/.test(pane().textContent) && num($('kCnt').textContent) === 0, '검색 0건 안내');
  $('srFind').value = ''; w.render();

  /* 6) 품목별 — 주코드로 묶음 · 합 = 전체 · 펼치기 */
  w.tab('i');
  let g = pane().querySelectorAll('tr.grp');
  ok(g.length === nItems, '품목 묶음 ' + g.length + ' = ' + nItems);
  const gsum = [...g].reduce((a, tr) => a + num(tr.children[5].textContent), 0);
  ok(Math.abs(gsum - sumAmt) <= g.length, '품목별 반품액 합 ' + gsum + ' ≈ ' + Math.round(sumAmt));
  ok(num(pane().querySelector('tr.lg-tot td.amt').textContent) === Math.round(sumAmt), '품목별 합계 줄');
  const ga = [...g].map(tr => num(tr.children[5].textContent)); ok(ga.every((x, i) => i === 0 || ga[i - 1] >= x), '품목별 = 반품액 큰 차례');
  ok(pane().querySelectorAll(':scope > table > thead th').length === 10 && g[0].children.length === 10 && pane().querySelector('tr.lg-tot').children.length === 9, '품목별 칸 수 10(합계 줄은 2칸 합침)');
  ok([...g].every(tr => { const cd = tr.getAttribute('data-k').slice(2), a = num(tr.children[5].textContent), sl = bsum(b => b.cd === cd);
        return (sl > 0 ? num(tr.children[6].textContent) === Math.round(sl) : true) && tr.children[7].textContent === (sl > 0 ? pct(ROWS.filter(r => codeOf(r) === cd).reduce((x, r) => x + r.amt, 0), sl) : '-') && a >= 0; }), '품목마다 판매액·반품율 = 분모 자료');
  { const T = pane().querySelector('tr.lg-tot'); ok(T.children[6].textContent === pct(sumAmt, saleAll) && num(T.children[5].textContent) === Math.round(saleAll), '품목별 합계 줄 판매액·반품율 = 전체'); }
  w.gsortBy('rate'); { const rs = [...pane().querySelectorAll('tr.grp')].map(tr => tr.children[7].textContent === '-' ? -1 : parseFloat(tr.children[7].textContent));
    ok(rs.every((x, i) => i === 0 || rs[i - 1] >= x), '반품율 머리글 = 율 큰 차례'); ok(/반품율 ▼/.test(pane().querySelector('thead').textContent), '정렬 표시'); }
  w.gsortBy('amt'); g = pane().querySelectorAll('tr.grp');
  const k0 = g[0].getAttribute('data-k'), cnt0 = num(g[0].children[3].textContent);
  w.grpToggle(k0);
  let det = pane().querySelector('tr.det');
  ok(det && det.querySelector('table').tBodies[0].rows.length === cnt0, '펼치면 그 품목의 내역 ' + cnt0 + '줄');
  ok(pane().querySelector('tr.grp.open .car').textContent === '▼', '펼친 표시');
  ok(+det.firstElementChild.getAttribute('colspan') === pane().querySelectorAll(':scope > table > thead th').length, '펼친 칸 폭 = 머리 칸 수');
  w.grpToggle(k0); ok(!pane().querySelector('tr.det'), '다시 누르면 접힘');
  if (withSub) { const codes = [...g].map(tr => tr.children[0].textContent.replace(/[▶▼]/g, '').trim()); ok(codes.indexOf(withSub.prodCd) >= 0 && codes.indexOf(withSub.itemCd) < 0, '정산서 코드가 아니라 주코드로 묶임'); }

  /* 7) 출고장·거래처별 — 원천마다 따로 */
  w.tab('p');
  g = pane().querySelectorAll('tr.grp');
  const pk = new Set(ROWS.map(r => r.src + '|' + (r.src === 'STL' ? (r.dcNm || '') : ((r.custNm || '') || (r.dcNm || '')))));
  ok(g.length === pk.size, '곳 묶음 ' + g.length + ' = ' + pk.size);
  ok([...g].reduce((a, tr) => a + num(tr.children[2].textContent), 0) === ROWS.length, '곳별 건수 합 = 전체');
  ok(num(pane().querySelector('tr.lg-tot td.amt').textContent) === Math.round(sumAmt), '곳별 합계 줄');
  ok([...g].every(tr => { const k = tr.getAttribute('data-k').slice(2), sl = bsum(b => b.src + '|' + (b.place || '') === k), a = ROWS.filter(r => r.src + '|' + placeOf(r) === k).reduce((x, r) => x + r.amt, 0);
        return tr.children[6].textContent === pct(a, sl) && (sl > 0 ? num(tr.children[5].textContent) === Math.round(sl) : true); }), '곳마다 판매액·반품율');
  ok([...pane().querySelectorAll(':scope > table > thead th')].length === g[0].children.length && pane().querySelector('tr.lg-tot').children.length === g[0].children.length, '곳별 머리 = 자료 = 합계 칸 수');

  /* 8) 월별 — 최근 달 먼저 · 원천 칸 합 = 반품액 */
  w.tab('m');
  g = pane().querySelectorAll('tr.grp');
  const yms = new Set(ROWS.map(r => r.dt.slice(0, 6)));
  ok(g.length === yms.size, '월 묶음 ' + g.length + ' = ' + yms.size);
  const ml = [...g].map(tr => tr.children[0].textContent.replace(/[▶▼]/g, '').trim()); ok(ml.every((x, i) => i === 0 || ml[i - 1] > x), '월 = 최근 먼저');
  ok([...g].every(tr => Math.abs(num(tr.children[3].textContent) - [7, 8, 9].reduce((a, i) => a + (tr.children[i].textContent.trim() === '-' ? 0 : num(tr.children[i].textContent)), 0)) <= 2), '월 줄 : 원천 세 칸 합 = 반품액');
  ok(pane().querySelector('tr.lg-tot').children.length === 10 && pane().querySelectorAll(':scope > table > thead th').length === 10 && g[0].children.length === 10, '월별 칸 수 10');
  ok([...g].every(tr => { const ym = tr.getAttribute('data-k').slice(2), sl = bsum(b => b.ym === ym), a = ROWS.filter(r => r.dt.slice(0, 6) === ym).reduce((x, r) => x + r.amt, 0); return tr.children[5].textContent === pct(a, sl); }), '월마다 반품율');
  ok(!pane().querySelector('thead th.srt'), '월별은 머리글 정렬 없음');
  ok(w.localStorage.getItem('srTab') === 'm', '보던 탭 기억');

  /* 9) 엑셀 — 네 탭 모두, 줄 수·합계 */
  const sheetRows = b => { const ws = b.wb.Sheets[b.wb.SheetNames[0]]; return w.XLSX.utils.sheet_to_json(ws, { header: 1, defval: '' }); };
  for (const [tb, nm, amtCol, n] of [['d', '매출반품내역', 13, ROWS.length], ['i', '매출반품내역_품목별', 6, nItems], ['p', '매출반품내역_출고장거래처별', 4, pk.size], ['m', '매출반품내역_월별', 3, yms.size]]) {
    w.tab(tb); books = []; w.xls();
    ok(books.length === 1 && books[0].nm.indexOf(nm + '_') === 0 && /\.xlsx$/.test(books[0].nm), '엑셀 파일 이름 : ' + (books[0] || {}).nm);
    const A = sheetRows(books[0]);
    ok(A.length === 4 + n + 1, tb + ' 엑셀 줄 수 ' + A.length + ' = 4 + ' + n + ' + 1');
    ok(Math.round(A[A.length - 1][amtCol]) === Math.round(sumAmt), tb + ' 엑셀 합계 = ' + Math.round(A[A.length - 1][amtCol]));
    ok(Math.abs(A.slice(4, -1).reduce((a, r) => a + Number(r[amtCol] || 0), 0) - sumAmt) < 1, tb + ' 엑셀 줄 합 = 합계');
    ok(A[3].length === A[A.length - 1].length, tb + ' 머리 = 합계 칸 수');
    const ws = books[0].wb.Sheets[books[0].wb.SheetNames[0]];
    ok(ws.A4.s && ws.A4.s.fill.fgColor.rgb === 'D9EDF7' && ws.A1.s.font.sz === 17, tb + ' 서식(머리 하늘 · 제목 17)');
  }
  w.tab('i'); books = []; w.xls();
  { const A = sheetRows(books[0]), T = A[A.length - 1]; ok(A[3][7] === '판매액' && A[3][8] === '반품율(%)' && Math.round(T[7]) === Math.round(saleAll) && Number(T[8]).toFixed(2) + '%' === pct(sumAmt, saleAll), '품목별 엑셀 판매액·반품율 합계 ' + T[8]);
    const r1 = A[4], sl = bsum(b => b.cd === r1[0]); ok(sl > 0 ? Math.round(r1[7]) === Math.round(sl) : r1[7] === '', '품목별 엑셀 첫 줄 판매액'); }
  w.tab('d'); books = []; w.xls();
  { const ws = books[0].wb.Sheets[books[0].wb.SheetNames[0]]; ok(ws.A5.t === 'n' && ws.A5.z === 'yyyy-mm-dd', '내역 엑셀 일자 = 날짜 값'); }
  ok(toasts.length >= 5, '엑셀 토스트');

  /* 10) 거른 채 엑셀 — 조건이 조회기간 줄에 */
  w.srcPick('STL'); books = []; w.xls();
  { const A = sheetRows(books[0]); ok(/원천 정산서/.test(A[2][0]) && A.length === 4 + (by.STL ? by.STL.c : 0) + 1, '거른 엑셀 : ' + A[2][0]); }
  w.srcPick('STL');

  /* 11) 기간 단추 · 날짜 바꾸기 · 뒤집힌 기간 */
  let c0 = calls.length; w.setRange('m1'); await tick();
  ok(calls.length === c0 + 1 && $('srFrom').value.slice(8) === '01', '지난달 → 조회');
  c0 = calls.length; $('srFrom').value = '2026-12-01'; $('srTo').value = '2026-11-01'; w.dateChg(); await tick();
  ok(calls.length === c0, '뒤집힌 기간은 조회 안 함(알림 없음)'); ok(alerts.length === 0, '알림 0');
  w.load(); ok(alerts.length === 1 && /시작일이 끝일보다/.test(alerts[0]), '[조회] 누르면 안내');
  w.setRange('y'); await tick(); ok($('srFrom').value.slice(5) === '01-01', '올해');

  /* 12) 빈 결과 · 오류 */
  fetchRows = []; w.load(); await tick();
  ok(/이 기간에 반품이 없습니다/.test(pane().textContent) && num($('kCnt').textContent) === 0, '빈 기간 안내');
  books = []; const a0 = alerts.length; w.xls(); ok(books.length === 0 && alerts.length === a0 + 1, '빈 채 엑셀 = 안내');
  fetchErr = '로그인이 끊겼습니다'; w.load(); await tick();
  ok(/조회 오류 — 로그인이 끊겼습니다/.test(pane().textContent) && $('kCnt').textContent === '-', '오류 표시 · 카드 비움');
  fetchErr = null; fetchRows = ROWS;

  /* 12-2) 분모(base)가 안 오면 율은 「-」 — 내역은 그대로 */
  fetchBase = null; w.load(); await tick();
  ok($('kRate').textContent === '-' && num($('kCnt').textContent) === ROWS.length && /받지 못했습니다/.test($('kSale').textContent), 'base 없음 → 율 「-」 · 내역 정상');
  w.tab('i'); ok([...pane().querySelectorAll('tr.grp')].every(tr => tr.children[6].textContent === '-' && tr.children[7].textContent === '-'), 'base 없음 → 품목별 판매액·율 「-」');
  books = []; w.xls(); ok(books.length === 1 && sheetRows(books[0])[4][7] === '', 'base 없음 → 엑셀 빈 칸');
  w.tab('d'); fetchBase = BASE; w.load(); await tick();
  ok($('kRate').textContent === pct(sumAmt, saleAll), '다시 오면 율 복귀');

  /* 13) 늦게 온 옛 응답은 버린다 */
  { let rel; const slow = new Promise(r => { rel = r; }); const of = w.fetch;
    w.fetch = (u, o) => { calls.push({ u, b: o.body }); return slow.then(() => ({ json: () => Promise.resolve({ data: [ROWS[0]] }) })); };
    w.load(); w.fetch = of; w.load(); await tick(); rel(); await tick();
    ok(num($('kCnt').textContent) === ROWS.length, '옛 응답이 새 결과를 안 덮음'); }

  /* 14) 다시 보일 때 — 3초 안이면 건너뛰고, 지나면 다시 읽는다 */
  w.eval('_shownAt=Date.now()'); c0 = calls.length; w.konetShown(); ok(calls.length === c0, '3초 안 재호출 건너뜀');
  w.eval('_shownAt=0'); w.konetShown(); await tick(); ok(calls.length === c0 + 1, '다시 보이면 다시 조회');

  /* 15) 곳 고른 채 기간을 바꿔 그 곳이 없으면 전체로 */
  $('srPlace').value = opts[0]; fetchRows = ROWS.filter(r => (r.src === 'STL' ? r.dcNm : (r.custNm || r.dcNm)) !== opts[0]); w.load(); await tick();
  ok($('srPlace').value === '' && num($('kCnt').textContent) === fetchRows.length, '없어진 곳 → 전체');

  /* ═══════════ 매입 꼴 (kind=P) — 같은 JSP ═══════════ */
  {
    const numP = o => { ['qty', 'boxQty', 'eaQty', 'price', 'supplyAmt', 'vatAmt', 'amt', 'saleAmt', 'cnt'].forEach(k => { if (o[k] != null) o[k] = Number(o[k]); }); return o; };
    const SP = [
      { src: 'PUR', dt: '20261111', custCd: '00431', custNm: '그린팩', docNo: '0005', rowNo: '1', itemCd: 'A1', prodCd: 'A1', itemNm: '도넛비닐', spec: '50mic', qty: 19, price: 48000, supplyAmt: 912000, vatAmt: 91200, amt: 1003200, gb: '반품', remark: '매입 2026-08-04-0003', mgrNm: '전원배', whNm: '제1창고', undoYn: 'Y' },
      { src: 'PUR', dt: '20260827', custCd: '001595', custNm: '제이투팩', docNo: '0001', rowNo: '1', itemCd: 'B1', prodCd: 'B1', itemNm: '타코박스', spec: '', qty: -43, price: 47200, supplyAmt: -2029600, vatAmt: -202960, amt: -2232560, gb: '반품', remark: '5박스 미반품', mgrNm: '마스터', whNm: '물류창고', undoYn: 'N' },
      { src: 'PUR', dt: '20260818', custCd: '001595', custNm: '제이투팩', docNo: '0001', rowNo: '1', itemCd: 'B1', prodCd: 'B1', itemNm: '타코박스', spec: '', qty: 45, price: 47200, supplyAmt: 2124000, vatAmt: 212400, amt: 2336400, gb: '반품', remark: '7월31일 입고분', mgrNm: '마스터', whNm: '물류창고', undoYn: 'N' },
      { src: 'PUR', dt: '20260428', custCd: '00431', custNm: '그린팩', docNo: '0002', rowNo: '1', itemCd: 'C1', prodCd: 'C1', itemNm: '쇼핑백', spec: '', qty: 100, price: 49.33, supplyAmt: 4933, vatAmt: 493, amt: 5426, gb: '매입(음수)', remark: '', mgrNm: '마스터', whNm: '', undoYn: 'N' },
      { src: 'PUR', dt: '20260422', custCd: '00431', custNm: '그린팩', docNo: '0001', rowNo: '5', itemCd: 'D1', prodCd: 'D1', itemNm: '비닐봉투', spec: '', qty: 19, price: 63000, supplyAmt: 1197000, vatAmt: 119700, amt: 1316700, gb: '불량반품', remark: '', mgrNm: '마스터', whNm: '물류창고', undoYn: 'N' }
    ];
    const SPB = [{ src: 'PUR', ym: '202611', place: '그린팩', cd: 'A1', saleAmt: 5000000 }, { src: 'PUR', ym: '202608', place: '제이투팩', cd: 'B1', saleAmt: 9000000 }, { src: 'PUR', ym: '202608', place: '제이투팩', cd: '', saleAmt: 1000000 },
                 { src: 'PUR', ym: '202604', place: '그린팩', cd: 'C1', saleAmt: 200000 }, { src: 'PUR', ym: '202604', place: '그린팩', cd: 'D1', saleAmt: 2633400 }, { src: 'PUR', ym: '202604', place: '다른매입처', cd: '', saleAmt: 30000000 }];
    const PR = (process.argv[4] ? parseDbRead(process.argv[4]) : SP).map(numP);
    const PB = (process.argv[5] ? [].concat.apply([], fs.readdirSync(process.argv[5]).filter(f => /\.txt$/.test(f)).map(f => parseDbRead(path.join(process.argv[5], f)))) : SPB).map(numP);
    let h2 = unJsp('P').replace(/<%--[\s\S]*?--%>/g, '').replace(/<%@[\s\S]*?%>/g, '').replace(/<c:out[^>]*\/>/g, '코네트').replace(/\$\{pageContext\.request\.contextPath\}/g, '').replace(/<script src="[^"]*"><\/script>/g, '');
    const b2 = h2.slice(h2.indexOf('<body>'), h2.indexOf('<script>')), j2 = h2.slice(h2.indexOf('<script>') + 8, h2.lastIndexOf('</script>'));
    const dm = new JSDOM('<!DOCTYPE html><html>' + b2 + '</body></html>', { runScripts: 'dangerously', pretendToBeVisual: true, url: 'http://localhost/mangr/purchReturn.do' });
    const W = dm.window, D = W.document, C = [], AL = [], BK = []; let fb = PB;
    W._alertBox = m => AL.push(m); W._toast = () => {};
    W.fetch = (u, o) => { C.push({ u, b: o.body }); return Promise.resolve({ json: () => Promise.resolve(Object.assign({ data: PR.map(r => Object.assign({}, r)) }, fb ? { base: fb.map(r => Object.assign({}, r)) } : {})) }); };
    W.eval(fs.readFileSync(path.join(ROOT, 'src/main/webapp/assets/vendor/xlsx-js-style/xlsx.bundle.js'), 'utf8')); W.XLSX.writeFile = (wb, nm) => BK.push({ wb, nm });
    W.eval(j2); await tick();
    const P = () => D.getElementById('pane'), G = id => D.getElementById(id), SR = b => W.XLSX.utils.sheet_to_json(b.wb.Sheets[b.wb.SheetNames[0]], { header: 1, defval: '' });
    const sA = PR.reduce((a, r) => a + r.amt, 0), sS = PR.reduce((a, r) => a + r.supplyAmt, 0), sV = PR.reduce((a, r) => a + r.vatAmt, 0), bA = PB.reduce((a, b) => a + b.saleAmt, 0), nI = new Set(PR.map(r => r.prodCd)).size, nP = new Set(PR.map(r => r.custNm)).size, nM = new Set(PR.map(r => r.dt.slice(0, 6))).size;
    ok(/purchReturnList\.do$/.test(C[0].u), '[매입] 조회 주소 : ' + C[0].u);
    ok(h2.indexOf('<title>매입 반품내역<' + '/title>') >= 0 &&/매입 반품내역/.test(D.querySelector('h2').textContent) && D.querySelectorAll('h2').length === 1 && D.querySelectorAll('.note').length === 1, '[매입] 제목 · 설명 한 벌');
    ok(G('srSrcWrap').style.display === 'none' && G('kSrcCard').style.display === 'none' && G('lbPlace').textContent === '매입처' && /매입처별/.test(G('tab-p').textContent), '[매입] 원천 고르기·카드 숨김 · 이름');
    W.tab('d');
    let T = P().querySelectorAll(':scope > table > tbody > tr');
    ok(T.length === PR.length + 1 && P().querySelectorAll('thead th').length === 15 && T[0].children.length === 15, '[매입] 내역 ' + (T.length - 1) + '줄 · 15칸');
    { const tt = P().querySelector('tr.lg-tot'), span = [...tt.children].reduce((a, td) => a + (+td.getAttribute('colspan') || 1), 0);
      ok(span === 15, '[매입] 합계 줄 칸 합 = 15 (' + span + ')');
      ok(num(tt.querySelector('td.amt').textContent) === Math.round(sA) && num(tt.children[2].textContent) === Math.round(sS) && num(tt.children[3].textContent) === Math.round(sV), '[매입] 합계 공급가·부가세·반품액 = ' + Math.round(sS) + ' · ' + Math.round(sV) + ' · ' + Math.round(sA)); }
    ok(G('kRate').textContent === pct(sA, bA) && G('kSale').textContent.indexOf('매입액 ') === 0 && num(G('kAmt').textContent) === Math.round(sA), '[매입] 카드 반품율 ' + G('kRate').textContent + ' · 매입액 대비');
    const negN = PR.filter(r => r.qty < 0 || r.amt < 0).length, undoN = PR.filter(r => r.undoYn === 'Y').length, minusN = PR.filter(r => /음수/.test(r.gb)).length;
    ok([...P().querySelectorAll('.tag.bad')].filter(x => x.textContent === '반품 취소').length === negN, '[매입] 반품 취소 배지 ' + negN + '줄');
    ok([...P().querySelectorAll('.tag.PO')].filter(x => x.textContent === '원위치').length === undoN, '[매입] 원위치 배지 ' + undoN + '줄');
    ok([...T].filter(tr => /매입\(음수\)/.test(tr.children[6] ? tr.children[6].textContent : '')).length === minusN, '[매입] 매입(음수) ' + minusN + '줄');
    if (negN) { const tr = [...T].find(x => /반품 취소/.test(x.textContent)); ok(/^-/.test(tr.children[7].textContent) && /^-/.test(tr.children[11].textContent), '[매입] 반품 취소 줄은 수량·금액이 음수 그대로'); }
    W.sortBy('supplyAmt'); { const a = [...P().querySelectorAll(':scope > table > tbody > tr')].slice(0, -1).map(tr => num(tr.children[9].textContent)); ok(a.every((x, i) => i === 0 || a[i - 1] >= x), '[매입] 공급가 정렬'); } W.sortBy('dt');
    W.tab('i'); let g = P().querySelectorAll('tr.grp');
    ok(g.length === nI && P().querySelectorAll(':scope > table > thead th').length === 10 && /매입액/.test(P().querySelector('thead').textContent) && !/판매액/.test(P().querySelector('thead').textContent), '[매입] 품목별 ' + g.length + '종 · 머리 「매입액」');
    ok([...g].every(tr => { const cd = tr.getAttribute('data-k').slice(2), a = PR.filter(r => r.prodCd === cd).reduce((x, r) => x + r.amt, 0), sl = PB.reduce((x, b) => x + (b.cd === cd ? b.saleAmt : 0), 0); return tr.children[7].textContent === pct(a, sl); }), '[매입] 품목마다 반품율');
    W.grpToggle(g[0].getAttribute('data-k')); { const det = P().querySelector('tr.det'); ok(det && det.querySelector('table thead').querySelectorAll('th').length === 15 && +det.firstElementChild.getAttribute('colspan') === 10, '[매입] 펼친 내역 15칸'); } W.grpToggle(g[0].getAttribute('data-k'));
    W.tab('p'); g = P().querySelectorAll('tr.grp');
    ok(g.length === nP && P().querySelectorAll(':scope > table > thead th').length === 8 && g[0].children.length === 8 && [...P().querySelector('tr.lg-tot').children].length === 8 && !/원천/.test(P().querySelector('thead').textContent), '[매입] 매입처별 ' + g.length + '곳 · 8칸(원천 칸 없음)');
    ok([...g].every(tr => { const k = tr.getAttribute('data-k').slice(2), nm = k.slice(4), a = PR.filter(r => r.custNm === nm).reduce((x, r) => x + r.amt, 0), sl = PB.reduce((x, b) => x + (b.place === nm ? b.saleAmt : 0), 0); return k.indexOf('PUR|') === 0 && tr.children[5].textContent === pct(a, sl) && num(tr.children[3].textContent) === Math.round(a); }), '[매입] 매입처마다 반품액·반품율');
    W.tab('m'); g = P().querySelectorAll('tr.grp');
    ok(g.length === nM && P().querySelectorAll(':scope > table > thead th').length === 7 && g[0].children.length === 7 && P().querySelector('tr.lg-tot').children.length === 7, '[매입] 월별 ' + g.length + '달 · 7칸(원천 칸 없음)');
    ok(W.localStorage.getItem('prTab') === 'm' && W.localStorage.getItem('srTab') == null, '[매입] 탭 기억 열쇠가 따로');
    for (const [tb, nm, cols, ac, n] of [['d', '매입반품내역_', 16, 12, PR.length], ['i', '매입반품내역_품목별_', 10, 5, nI], ['p', '매입반품내역_매입처별_', 8, 3, nP], ['m', '매입반품내역_월별_', 7, 3, nM]]) {
      W.tab(tb); BK.length = 0; W.xls(); const A = BK.length ? SR(BK[0]) : [];
      ok(BK.length === 1 && BK[0].nm.indexOf(nm) === 0 && A.length === 4 + n + 1 && A[3].length === cols && Math.round(A[A.length - 1][ac]) === Math.round(sA) && /^\[매입 반품내역/.test(A[0][0]), '[매입] 엑셀 ' + tb + ' : ' + (BK[0] || {}).nm + ' · ' + A.length + '줄 · 합계 ' + (A.length ? A[A.length - 1][ac] : ''));
    }
    W.tab('d'); BK.length = 0; W.xls(); { const A = SR(BK[0]); ok(Math.round(A[A.length - 1][10]) === Math.round(sS) && Math.round(A[A.length - 1][11]) === Math.round(sV) && (negN ? A.some(r => /반품 취소/.test(r[7])) : true), '[매입] 내역 엑셀 공급가·부가세 합 · 반품 취소 표시'); }
    const o0 = [...G('srPlace').options].map(o => o.value).filter(v => v); G('srPlace').value = o0[0]; W.render();
    ok(G('kRate').textContent === pct(PR.filter(r => r.custNm === o0[0]).reduce((a, r) => a + r.amt, 0), PB.reduce((a, b) => a + (b.place === o0[0] ? b.saleAmt : 0), 0)), '[매입] 매입처 고르면 그 매입액 대비 ' + G('kRate').textContent);
    G('srPlace').value = ''; fb = null; W.load(); await tick(); ok(G('kRate').textContent === '-' && /매입액을 받지 못했습니다/.test(G('kSale').textContent) && num(G('kCnt').textContent) === PR.length, '[매입] 분모 없음 → 율 「-」');
    ok(AL.length === 0, '[매입] 알림 0');
    console.log('  매입 줄 ' + PR.length + ' · 분모 ' + PB.length);
  }

  console.log((fail ? '✗' : '✓') + ' sim_salesreturn : ' + pass + ' 통과 · ' + fail + ' 실패 (줄 ' + ROWS.length + ')');
  process.exit(fail ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
