/* 품목별재고현황 ② 선택 품목 수불 내역 — 달마다 구분별 합계 줄 (2026-11-18)
   logi-oh.js 의 stkLedMon / stkLedMonHead 를 떼어, JSP 의 _ioLbl·_ioRet·_cnum·_cesc 와 함께 돌린다.
   쓰는 법 : node docs/tools/sim/sim_stkLedMon.js */
const fs = require('fs'), path = require('path'), vm = require('vm');
const ROOT = path.resolve(__dirname, '../../..');
const J = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), 'utf8').replace(/\r\n/g, '\n');
const O = fs.readFileSync(path.join(ROOT, 'src/main/webapp/js/winct/logi-oh.js'), 'utf8').replace(/\r\n/g, '\n');
function fnOf(src, name){ const i=src.indexOf('\n  function '+name+'('); if(i<0) throw new Error('함수 없음 '+name); let d=0, j=src.indexOf('{', i); for(let k=j;k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ d--; if(!d) return src.slice(i+1, k+1); } } throw new Error('끝 없음 '+name); }
function lineOf(src, head){ const i=src.indexOf(head); if(i<0) throw new Error('줄 없음 '+head); return src.slice(i, src.indexOf('\n', i)); }
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }
const ctx = vm.createContext({ console });
vm.runInContext([
  lineOf(J, "var _IOGB={"), fnOf(J, '_ioRet'), fnOf(J, '_ioLbl'), fnOf(J, '_cnum'), fnOf(J, '_cesc'),
  lineOf(O, "var STK_LEDORD="), fnOf(O, 'stkLedMon'), fnOf(O, 'stkLedMonHead'),
].join('\n'), ctx);
/* 캡처(2010026009 스트로우) 그대로 — 최근 날짜부터 */
const R = (dt, io, qty, price, amt) => ({ trxDt: dt, prodCd: '2010026009', ioGb: io, qty, unitPrice: price, amt });
const rows = [
  R('20261116','I',10,20200,202000), R('20261027','A',-15,0,0), R('20261003','O',1,0,0), R('20261001','O',1,0,0),
  R('20260930','O',1,0,0), R('20260929','O',1,0,0), R('20260928','O',1,0,0), R('20260922','O',1,0,0), R('20260914','O',1,0,0), R('20260908','O',1,0,0), R('20260905','O',2,0,0),
  R('20260825','O',1,0,0), R('20260817','O',1,0,0), R('20260815','O',1,0,0), R('20260814','O',1,0,0), R('20260812','O',1,0,0), R('20260812','I',12,20200,242400),
  R('20260508','I',12,27000,324000),
];
ctx.rows = rows;
const html = vm.runInContext("stkLedMon(rows, function(l){ return '<tr class=\"r\" data-d=\"'+l.trxDt+'\"><td>'+l.trxDt+'</td></tr>'; })", ctx);
const trs = html.match(/<tr[\s\S]*?<\/tr>/g) || [];
const mons = trs.filter(x => x.indexOf('class="led-mon"') >= 0);
const txt = (x) => x.replace(/<[^>]+>/g, '|').replace(/\|+/g, '|');
const cells = (x) => (x.match(/<td[\s\S]*?<\/td>/g) || []).map(c => c.replace(/<[^>]+>/g, ''));
const span = (x) => (x.match(/<td[^>]*>/g) || []).reduce((a, c) => a + (+(/colspan="(\d+)"/.exec(c) || [0, 1])[1]), 0);
t('자료 줄 18줄은 그대로(차례도)', trs.filter(x => x.indexOf('class="r"') >= 0).map(x => /data-d="(\d+)"/.exec(x)[1]).join(',') === rows.map(r => r.trxDt).join(','));
t('합계 줄 = 11월 입고 · 10월 출고·조정 · 9월 출고 · 8월 입고·출고 · 5월 입고 = 7줄', mons.length === 7, mons.length);
const find = (ymLab, g) => mons.map(cells).find((c, i) => { const m = mons[i]; return /data-ym="(\d+)"/.exec(m)[1] === ymLab && c.indexOf(g) >= 0; });
const q = (c, g) => c[c.indexOf(g) + 1], a = (c, g) => c[c.indexOf(g) + 3], n = (c) => c[c.length - 1];
t('2026-11 입고 10 · 202,000 · 1건', (() => { const c = find('202611', '입고'); return c && q(c, '입고') === '10' && a(c, '입고') === '202,000' && n(c) === '1건'; })(), JSON.stringify(find('202611', '입고')));
t('2026-10 출고 2 · 2건', (() => { const c = find('202610', '출고'); return c && q(c, '출고') === '2' && n(c) === '2건'; })(), JSON.stringify(find('202610', '출고')));
t('2026-10 조정 -15 · 1건(출고와 안 합침)', (() => { const c = find('202610', '조정'); return c && q(c, '조정') === '-15' && n(c) === '1건'; })(), JSON.stringify(find('202610', '조정')));
t('★2026-09 출고 8 · 7건(9/5 의 2개 포함)', (() => { const c = find('202609', '출고'); return c && q(c, '출고') === '8' && n(c) === '7건'; })(), JSON.stringify(find('202609', '출고')));
t('2026-08 입고 12 · 242,400 / 출고 5 · 5건', (() => { const i = find('202608', '입고'), o = find('202608', '출고'); return i && o && q(i, '입고') === '12' && a(i, '입고') === '242,400' && q(o, '출고') === '5' && n(o) === '5건'; })());
t('2026-05 입고 12 · 324,000', (() => { const c = find('202605', '입고'); return c && q(c, '입고') === '12' && a(c, '입고') === '324,000'; })());
/* 자리 : 그 달의 첫 줄 바로 앞 */
const pos = (re) => trs.findIndex(x => re.test(x));
t('합계 줄은 그 달 첫 줄 바로 앞(10월 : 합계 2줄 → 10-27 줄)', pos(/data-ym="202610"/) + 2 === pos(/data-d="20261027"/), pos(/data-ym="202610"/) + ' / ' + pos(/data-d="20261027"/));
t('9월 합계는 10-01 줄 뒤 · 09-30 줄 앞', pos(/data-d="20261001"/) + 1 === pos(/data-ym="202609"/) && pos(/data-ym="202609"/) + 1 === pos(/data-d="20260930"/));
/* 구분 차례 : 입고 → 출고 → 조정 */
t('같은 달 구분 차례 = 입고 · 출고(8월) / 출고 · 조정(10월)', (() => { const m8 = mons.filter(x => /data-ym="202608"/.test(x)).map(x => cells(x).find(c => ['입고','출고','조정'].indexOf(c) >= 0)); const m10 = mons.filter(x => /data-ym="202610"/.test(x)).map(x => cells(x).find(c => ['입고','출고','조정'].indexOf(c) >= 0)); return m8.join() === '입고,출고' && m10.join() === '출고,조정'; })());
/* 칸 수 13 : 첫 줄은 2+1+1+1+1+7, 둘째 줄은 rowspan 으로 앞 2칸이 빠져 11 */
const m8 = mons.filter(x => /data-ym="202608"/.test(x));
t('칸 수 — 첫 합계 줄 13 · 같은 달 둘째 줄 11(앞 두 칸은 rowspan 2)', span(m8[0]) === 13 && span(m8[1]) === 11 && /rowspan="2"/.test(m8[0]), span(m8[0]) + ' / ' + span(m8[1]));
t('달 이름 「▣ 2026-08 합계」는 그 달 첫 합계 줄에만', /▣ 2026-08 합계/.test(m8[0]) && !/▣/.test(m8[1]));
t('한 구분뿐인 달은 rowspan 1', /rowspan="1"/.test(mons.find(x => /data-ym="202609"/.test(x))));
/* 반품 · 일자 꼴 · 빈 목록 */
ctx.rows = [ { trxDt: '2026-07-03', ioGb: 'R', qty: 3, amt: 3000 }, { trxDt: '2026-07-02', ioGb: 'I', qty: -2, amt: -2000 }, { trxDt: '2026-07-01', ioGb: 'O', qty: 4, amt: 0 }, { trxDt: '', ioGb: 'O', qty: 1, amt: 0 } ];
const h2 = vm.runInContext("stkLedMon(rows, function(l){ return '<tr class=\"r\"></tr>'; })", ctx);
const m2 = (h2.match(/<tr class="led-mon"[\s\S]*?<\/tr>/g) || []);
t('「2026-07-03」 꼴 일자도 같은 달로 · 반품은 따로(R 3 + 음수 입고 -2 = 반품 1)', m2.some(x => /data-ym="202607"/.test(x) && cells(x).indexOf('반품') >= 0 && cells(x)[cells(x).indexOf('반품') + 1] === '1'), m2.map(txt).join(' // '));
t('일자가 빈 줄은 「(일자 없음) 합계」로', m2.some(x => /\(일자 없음\) 합계/.test(x)));
ctx.rows = [];
t('빈 목록이면 아무것도 안 그린다', vm.runInContext("stkLedMon(rows, function(l){ return 'x'; })", ctx) === '');
/* JSP 가 이 함수를 부르는지 · 줄 수 불변 */
t('JSP _stkLedPaint 가 stkLedMon 으로 그린다', J.indexOf('var body= rows.length ? stkLedMon(rows, function(l){') > 0 && J.indexOf('var body= rows.length ? rows.map(function(l){') < 0);
t('업무설명서 재고현황 행에 한 문장', /class="m">재고현황<\/td>[^\n]*▣ 2026-10 합계/.test(J));
/* ── 총합계(달 이름 옆 칸) = 그 달 재고 증감 = 입고 − 출고 ± 조정·반품 ── */
const netOf = (list, ymv) => { ctx.rows = list; const h = vm.runInContext("stkLedMon(rows, function(l){ return ''; })", ctx);
  const m = (h.match(/<tr class="led-mon"[\s\S]*?<\/tr>/g) || []).find(x => new RegExp('data-ym="' + ymv + '"').test(x) && /class="led-net"/.test(x)); if (!m) return null;
  const td = /<td class="led-net"[^>]*title="([^"]*)"[^>]*>([\s\S]*?)<\/td>/.exec(m); return { txt: td[2].replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim(), tip: td[1], red: /color:#c0392b/.test(td[2]), rowspan: +/class="led-net" rowspan="(\d+)"/.exec(m)[1], tr: m }; };
/* 사용자 그림(1010014032 · 2026-09) : 입고 96,000 · 출고 36,700(7건) · 조정 50,546 */
const sep = [ { trxDt:'20260930', ioGb:'A', qty:50546, amt:0 }, { trxDt:'20260928', ioGb:'O', qty:6400, amt:0 }, { trxDt:'20260922', ioGb:'O', qty:5000, amt:0 }, { trxDt:'20260917', ioGb:'O', qty:9300, amt:0 },
  { trxDt:'20260910', ioGb:'O', qty:4000, amt:0 }, { trxDt:'20260908', ioGb:'O', qty:3000, amt:0 }, { trxDt:'20260904', ioGb:'O', qty:5000, amt:0 }, { trxDt:'20260902', ioGb:'O', qty:4000, amt:0 }, { trxDt:'20260901', ioGb:'I', qty:96000, amt:3552000 } ];
const n9 = netOf(sep, '202609');
t('★총합계 = 96,000 − 36,700 + 50,546 = 109,846 (구분 줄을 그냥 더한 183,246 이 아니다)', n9 && n9.txt === '총합계 109,846', n9 && n9.txt);
t('총합계 칸은 달 이름 칸 옆(품목코드 자리) · 세 구분 줄에 걸친다(rowspan 3)', n9 && n9.rowspan === 3 && /▣ 2026-09 합계<\/td><td class="led-net"/.test(n9.tr));
t('말풍선에 셈 식 — 입고 +96,000 · 출고 −36,700 · 조정 +50,546 = 109,846', n9 && /입고 \+96,000 · 출고 −36,700 · 조정 \+50,546 = 109,846/.test(n9.tip), n9 && n9.tip);
t('늘어난 달은 검정', n9 && !n9.red);
/* 앞의 캡처 품목(2010026009) */
const n10 = netOf(rows, '202610'), n09 = netOf(rows, '202609'), n08 = netOf(rows, '202608'), n11 = netOf(rows, '202611');
t('10월 = 출고 2 · 조정 −15 → −17 (줄어든 달은 빨강)', n10 && n10.txt === '총합계 -17' && n10.red, n10 && n10.txt);
t('9월 = 출고만 8 → −8 · 한 줄짜리(rowspan 1)', n09 && n09.txt === '총합계 -8' && n09.rowspan === 1, n09 && n09.txt);
t('8월 = 입고 12 − 출고 5 = 7', n08 && n08.txt === '총합계 7', n08 && n08.txt);
t('11월 = 입고만 10 → 10', n11 && n11.txt === '총합계 10');
/* 반품 : 매입 반품(음수 입고)은 줄고 · 판매 반품(R)은 는다 */
const nr = netOf([ { trxDt:'20260703', ioGb:'R', qty:3, amt:0 }, { trxDt:'20260702', ioGb:'I', qty:-2, amt:0 }, { trxDt:'20260701', ioGb:'O', qty:4, amt:0 } ], '202607');
t('반품 포함 = +3 − 2 − 4 = −3', nr && nr.txt === '총합계 -3', nr && nr.txt);
t('첫 합계 줄 칸 수는 그대로 13', span((netOf(sep, '202609') || {}).tr || '') === 13);
console.log((bad ? '✗ ' : '✓ ') + 'sim_stkLedMon : 통과 ' + ok + ' · 실패 ' + bad);
