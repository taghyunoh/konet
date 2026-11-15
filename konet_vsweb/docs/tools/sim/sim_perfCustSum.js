/* 종합실적 상세보기 — 탭 둘 [일자별] / [거래처합] (2026-11-15) 시뮬.
   node docs/tools/sim/sim_perfCustSum.js      (jsdom 불필요 — 화면 스크립트에서 필요한 함수만 떼어 돌린다)
   검사 : [일자별] = 원래 모양(전표 줄·일 계·합 계 — 거래처 줄 없음) · [거래처합] = 거래처마다 한 줄(차례·줄 합 = 합 계·칸 수·코드 없는 거래처·담당 여럿·
          수금/매입/지급) · «전체 기간»(검색 기간과 무관 — 읽는 중·도착·조건 변경·실패) · 탭 바꾸기·지출엔 탭 없음 · 엑셀(탭별 시트·병합·이름) */
const fs = require('fs'), path = require('path'), vm = require('vm');
const src = fs.readFileSync(path.join(__dirname, '../../../src/main/webapp/WEB-INF/jsp/main/mangr/perfSummary.jsp'), 'utf8');
function fn(name){
  const a = src.indexOf('function ' + name + '(');
  if (a < 0) throw new Error('no function ' + name);
  let i = src.indexOf('{', a), d = 0;
  for (; i < src.length; i++){ const c = src[i]; if (c === '{') d++; else if (c === '}'){ d--; if (!d) break; } }
  return src.slice(a, i + 1);
}
const names = ['n', 'esc', 'fc', 'dl', 'payKind', 'sumOf', 'psNorm', 'psAllLoad', 'psAllRows', 'dtSpan', 'custGroups', 'psDtl', 'psDtlTab', 'psAllFold', 'psDtlNm', 'xE', 'xW', 'xsDtl'];
const els = {};
function el(id){ return els[id] || (els[id] = { innerHTML:'', textContent:'', className:'', style:{}, scrollTop:0, scrollIntoView(){} }); }
const ctx = {
  document:{ getElementById:el, querySelector(){ return el('__wrap'); } },
  _rows:[], _fr8:'20260101', _to8:'20260105', _dtlGb:'', _dtlTab:'date', _expM:[], _expD:[],
  _all:{ key:null, rows:null, busy:false, err:'' }, _q:'', _allOpen:false,
  /* 전 기간 조회(거래처합 탭의 «전체 기간») — 요청을 적어 두고, 시험이 정한 응답(allResp)을 돌려준다. 기본은 영영 안 오는 응답(읽는 중) */
  posts:[], allResp:null, expCalls:0,
  post(url, body){ ctx.posts.push({ url, body }); return ctx.allResp ? ctx.allResp() : new Promise(function(){}); },
  GBL:{ SALE:'매출', RCV:'수금', PURCH:'매입', PAY:'지급', EXP:'지출' },
  prnTit:'', prnHead(id, t){ ctx.prnTit = t; }, psDtlExp(){ ctx.expCalls++; }, xsDtlExp(){ return { exp:true }; },
  xHead(t, nc){ return { aoa:[[t],[],['기간']], kinds:['t','t','p'] }; },
  xSheet(aoa, kinds, ncol, nums, mg, w){ return { aoa, kinds, ncol, nums, mg, w }; },
  console
};
vm.createContext(ctx);
let code = '';
names.forEach(k => { code += fn(k) + '\n'; });
vm.runInContext(code, ctx);

let pass = 0, fail = 0;
function ok(c, m){ if (c) pass++; else { fail++; console.log('  ✗ ' + m); } }
function rowsOf(html, cls){ const re = new RegExp('<tr' + (cls ? ' class="' + cls + '"' : '') + '>([\\s\\S]*?)</tr>', 'g'); const out = []; let m; while ((m = re.exec(html))) out.push(m[1]); return out; }
function cells(tr){ return (tr.match(/<td[^>]*>([\s\S]*?)<\/td>/g) || []).map(x => x.replace(/<[^>]+>/g, '')); }
function heads(h){ return (h.match(/<th>([\s\S]*?)<\/th>/g) || []).map(x => x.replace(/<[^>]+>/g, '')); }
const num = s => Number(String(s).replace(/,/g, ''));
const html = () => el('psDtl').innerHTML;
const body = x => x.split('<tbody>')[1] || '';   /* 머리글 줄(<tr>)을 뺀 몸통 */
const S = (dt, cd, nm, sup, vat, mgr) => ({ gb:'SALE', dt, trxNo:'정산서', custCd:cd, custNm:nm, mgrNm:mgr || '마스터', supplyAmt:sup, vatAmt:vat, amt:sup + vat, dcAmt:0 });
const MIX = [
  S('20260101','00272','삼성웰스토리 평택',5067455,506745), S('20260101','00273','삼성웰스토리 용인',1248236,124824),
  S('20260101','00274','삼성웰스토리 김해',53727,5373),      S('20260102','00274','삼성웰스토리 김해',426400,42640),
  S('20260103','00272','삼성웰스토리 평택',7970720,797072), S('20260103','00273','삼성웰스토리 용인',2375264,237526),
  S('20260105','00272','삼성웰스토리 평택',4483927,448393,'김민지'), S('20260105','','무명 거래처',1000,100),
  { gb:'RCV', dt:'20260103', trxNo:'0001', custCd:'00272', custNm:'삼성웰스토리 평택', mgrNm:'마스터', payGb:'무통장', amt:1000000, dcAmt:0 }
];

(async function(){
  const tick = () => new Promise(r => setTimeout(r, 0));
  let h, cs, tot;

  /* ── ① [일자별] 탭 = 원래 모양 */
  ctx._rows = MIX; ctx._dtlTab = 'date'; ctx.psDtl('SALE', true); h = html();
  ok(heads(h).join('|') === '매출일자|코드|거래처코드|거래처명|담당사원|공급가|부가세|합계|DC', '일자별 머리글 9칸 그대로');
  ok(rowsOf(body(h), '').length === 8 && rowsOf(h, 'dsum').length === 4 && rowsOf(h, 'tot').length === 1, '일자별 = 전표 8줄 · 일 계 4 · 합 계 1');
  ok(!/class="csum|class="chd|거래처 계|거래처별/.test(h), '일자별에는 거래처 합계 줄·머리줄이 없다(원복)');
  ok(cells(rowsOf(h, 'dsum')[0]).join('|') === '일 계|6,369,418|636,942|7,006,360|0', '첫 날 일 계 값 — ' + cells(rowsOf(h, 'dsum')[0]).join('|'));
  ok(/합 계 \(8건\)/.test(rowsOf(h, 'tot')[0]) && num(cells(rowsOf(h, 'tot')[0])[3]) === 23789402, '합 계 (8건) 23,789,402');
  ok(el('psDtlTit').textContent === '📋 매출 상세 · 2026-01-01 ~ 2026-01-05 · 8건' && ctx.prnTit === '매출 상세', '일자별 제목·인쇄 머리 원래대로');
  ok(ctx.posts.length === 0, '일자별 탭에서는 전 기간 조회를 안 한다');
  ok(/ on$/.test(el('psTabDate').className) && !/ on$/.test(el('psTabCust').className) && el('psDtlTabs').style.display === '', '탭 단추 = 일자별 켜짐 · 탭 줄 보임');

  /* ── ② [거래처합] 탭 — 검색 기간 묶음 */
  ctx._q = '&mgrCd=&whCd=&prodCd='; ctx.allResp = null;
  ctx.psDtlTab('cust'); h = html();
  ok(ctx._dtlTab === 'cust' && / on$/.test(el('psTabCust').className) && !/ on$/.test(el('psTabDate').className), '탭 바꾸면 거래처합 켜짐');
  ok(heads(h).join('|') === '거래처코드|거래처명|담당사원|건수|공급가|부가세|합계|DC', '거래처합 머리글 8칸 — ' + heads(h).join('|'));
  ok(rowsOf(body(h), '').length === 0 && rowsOf(h, 'dsum').length === 0, '거래처합에는 전표 줄·일 계가 없다');
  ok(rowsOf(h, 'chd').length === 1 && /검색 기간 2026-01-01 ~ 2026-01-05 · 거래처 4곳/.test(rowsOf(h, 'chd')[0]) && /colspan="8"/.test(rowsOf(h, 'chd')[0]), '검색 기간 머리줄 · 4곳 · colspan 8');
  cs = rowsOf(h, 'csum'); tot = rowsOf(h, 'tot');
  ok(cs.length === 4 && cells(cs[0]).length === 8, '거래처 줄 4(수금 줄은 안 섞임) · 칸 8');
  ok(cells(cs[0]).slice(0, 4).join('|') === '00272|삼성웰스토리 평택|마스터 외 1|3', '첫 줄 = 평택(합계 가장 큼) 3건 · 담당 여럿 — ' + cells(cs[0]).slice(0, 4).join('|'));
  ok(num(cells(cs[0])[4]) === 5067455 + 7970720 + 4483927 && num(cells(cs[0])[6]) === 5574200 + 8767792 + 4932320, '평택 공급가·합계 = 세 줄 합');
  ok(cs.map(x => cells(x)[0]).join(',') === '00272,00273,00274,', '차례 = 합계 큰 순(코드 없는 거래처 맨 끝)');
  ok(cells(cs[3])[1] === '무명 거래처' && cells(cs[3])[3] === '1', '코드 없는 거래처는 이름으로 묶임');
  ok(tot.length === 1 && cells(tot[0])[0] === '합 계' && num(cells(tot[0])[1]) === 8, '합 계 줄 · 건수 8');
  [2, 3, 4, 5].forEach(k => ok(cs.reduce((a, x) => a + num(cells(x)[k + 2]), 0) === num(cells(tot[0])[k]), '거래처 줄 합 = 합 계 (칸 ' + k + ')'));
  ok(cs.reduce((a, x) => a + num(cells(x)[3]), 0) === 8, '건수 합 = 8');
  ok(/거래처합/.test(el('psDtlTit').textContent) && /거래처 4곳 · 8건/.test(el('psDtlTit').textContent) && ctx.prnTit === '매출 거래처합', '거래처합 제목·인쇄 머리 — ' + el('psDtlTit').textContent);
  ok(el('__wrap').scrollTop === 0, '탭을 바꾸면 목록 맨 위로');

  /* ── ③ «전체 기간» — 기본은 접힘(전 기간 조회도 안 한다) → 머리줄을 누르면 펼치며 읽는다 */
  const allTr = x => { const re = /<tr class="chd all"[^>]*>([\s\S]*?)<\/tr>/g, o = []; let m; while ((m = re.exec(x))) o.push(m[1]); return o; };
  ok(ctx.posts.length === 0 && allTr(h).length === 1 && /▸<\/b> 전체 기간/.test(allTr(h)[0]) && /눌러서 펼치기/.test(allTr(h)[0]) && rowsOf(h, 'csum acs').length === 0 && rowsOf(h, 'tot atot').length === 0, '전체 기간 = 접힌 머리줄 한 줄 · 전 기간 조회 안 함');
  ok(/<tr class="chd all" onclick="psAllFold\(\)">/.test(h) && /colspan="8"/.test(allTr(h)[0]), '접힌 머리줄 = 누르는 줄(psAllFold) · colspan 8');
  ok(ctx.xsDtl('SALE').kinds.indexOf('chda') < 0, '접혀 있으면 엑셀에도 전체 묶음 없음');
  el('__wrap').scrollTop = 120; ctx.psAllFold(); h = html();
  ok(ctx._allOpen === true && el('__wrap').scrollTop === 120 && /▾<\/b> 전체 기간/.test(allTr(h)[0]), '누르면 펼침(▾) · 스크롤 자리 유지');
  ok(ctx.posts.length === 1 && ctx.posts[0].url === '/mangr/perfData.do' && ctx.posts[0].body === 'frDt=1900-01-01&toDt=2999-12-31&mgrCd=&whCd=&prodCd=', '전 기간 요청 = 날짜만 넓히고 조건은 그대로');
  ok(allTr(h).length === 1 && /전체 기간/.test(allTr(h)[0]) && /불러오는 중/.test(allTr(h)[0]) && rowsOf(h, 'csum acs').length === 0, '읽는 동안 「불러오는 중」 한 줄');
  ctx.psDtl('SALE', true); ok(ctx.posts.length === 1, '읽는 중에는 다시 요청 안 함');

  /* ── ④ «전체 기간» — 도착 */
  const period = [ S('20260101','00272','삼성웰스토리 평택',100,10), S('20260103','00273','삼성웰스토리 용인',300,30) ];
  const allSet = [ S('20251202','001532','우리푸드',5000,500), S('20251210','00272','삼성웰스토리 평택',1000,100) ].concat(period.map(r => Object.assign({}, r)),
    [ { gb:'RCV', dt:'20251215', trxNo:'0001', custCd:'001532', custNm:'우리푸드', mgrNm:'마스터', payGb:'현금', amt:700, dcAmt:0 },
      { gb:'P_SALE', dt:'00000000', custCd:'', custNm:'', mgrNm:'마스터', amt:99999, dcAmt:0, src:'PREV' } ]);
  ctx._rows = period; ctx._all = { key:null, rows:null, busy:false, err:'' }; ctx.posts.length = 0; ctx._dtlGb = 'SALE';
  ctx.allResp = () => Promise.resolve({ rows: allSet.map(r => Object.assign({}, r)) });
  el('__wrap').scrollTop = 333;
  ctx.psDtl('SALE', true); await tick(); await tick(); h = html();
  const ah = allTr(h), ac = rowsOf(h, 'csum acs'), at = rowsOf(h, 'tot atot');
  ok(ah.length === 1 && /전체 기간/.test(ah[0]) && /검색 기간과 무관 · 2025-12-02 ~ 2026-01-03/.test(ah[0]) && /거래처 3곳/.test(ah[0]), '도착하면 다시 그림 — 「전체 기간 · 2025-12-02 ~ 2026-01-03 · 3곳」 — ' + (ah[0] || '').replace(/<[^>]+>/g, ''));
  ok(ac.length === 3 && cells(ac[0])[0] === '001532' && num(cells(ac[0])[6]) === 5500, '전체 줄 3 · 첫 줄 = 우리푸드 5,500(기간 밖 거래처도 나온다)');
  ok(cells(ac[1])[0] === '00272' && cells(ac[1])[3] === '2' && num(cells(ac[1])[6]) === 1210, '평택 = 기간 밖 1,100 + 기간 안 110 = 1,210 · 2건');
  ok(at.length === 1 && cells(at[0])[0] === '전체 합 계' && num(cells(at[0])[1]) === 4 && num(cells(at[0])[4]) === 7040, '전체 합 계 4건 7,040 (수금·전잔고 줄은 안 섞임)');
  ok(ac.reduce((a, x) => a + num(cells(x)[6]), 0) === num(cells(at[0])[4]), '전체 거래처 줄 합 = 전체 합 계');
  ok(cells(ac[0]).length === 8 && /colspan="8"/.test(ah[0]), '전체 줄 칸 수 8 · 머리줄 colspan 8');
  ok(h.indexOf('class="chd all"') > h.indexOf('class="tot"'), '자리 = 검색 기간 합 계 밑');
  ok(rowsOf(h, 'csum').length === 2 && num(cells(rowsOf(h, 'tot')[0])[4]) === 440, '검색 기간 묶음(2곳 · 440)은 그대로');
  ok(el('__wrap').scrollTop === 333, '전체가 도착해 다시 그려도 스크롤 자리 유지');
  ok(ctx.posts.length === 1, '같은 조건이면 한 번만 읽음'); ctx.psDtl('SALE', true); ok(ctx.posts.length === 1, '다시 그려도 재요청 없음');
  ok(/눌러서 접기/.test(ah[0]), '펼친 머리줄에 「눌러서 접기」');
  ctx.psAllFold(); h = html();
  ok(ctx._allOpen === false && rowsOf(h, 'csum acs').length === 0 && rowsOf(h, 'tot atot').length === 0 && /▸<\/b> 전체 기간/.test(allTr(h)[0]) && rowsOf(h, 'csum').length === 2, '다시 누르면 접힘 — 전체 줄만 사라지고 검색 기간 묶음은 그대로');
  ctx.psAllFold(); h = html();
  ok(ctx.posts.length === 1 && rowsOf(h, 'csum acs').length === 3, '다시 펼치면 읽어 둔 자료로 바로(재요청 없음)');

  /* ── ⑤ 수금·매입·지급 */
  ctx.psDtl('RCV', true); h = html();
  ok(heads(h).join('|') === '거래처코드|거래처명|담당사원|건수|현금|무통장입금|카드|기타|할인|합계', '수금 거래처합 머리글 10칸');
  ok(ctx.posts.length === 1 && /이 기간에 수금 전표가 없습니다/.test(h) && rowsOf(h, 'csum acs').length === 1 && num(cells(rowsOf(h, 'csum acs')[0])[9]) === 700 && num(cells(rowsOf(h, 'csum acs')[0])[4]) === 700, '수금 = 기간엔 없어도 전체 줄 1(우리푸드 현금 700) · 같은 자료 재사용');
  ctx._rows = [ { gb:'RCV', dt:'20260103', trxNo:'0001', custCd:'A1', custNm:'가상사', mgrNm:'마스터', payGb:'현금', amt:300, dcAmt:10 },
                { gb:'RCV', dt:'20260104', trxNo:'0002', custCd:'A1', custNm:'가상사', mgrNm:'마스터', payGb:'카드', amt:700, dcAmt:0 },
                { gb:'RCV', dt:'20260104', trxNo:'0003', custCd:'B2', custNm:'나상사', mgrNm:'', payGb:'현금', amt:5000, dcAmt:0 },
                { gb:'PURCH', dt:'20260103', trxNo:'0001', custCd:'V1', custNm:'매입처', mgrNm:'마스터', supplyAmt:1000, vatAmt:100, amt:1100, dcAmt:0 },
                { gb:'PAY', dt:'20260103', trxNo:'0001', custCd:'V1', custNm:'매입처', mgrNm:'마스터', payGb:'무통장', amt:1100, dcAmt:0 } ];
  ctx.psDtl('RCV', true); h = html(); cs = rowsOf(h, 'csum'); tot = rowsOf(h, 'tot');
  ok(cs.length === 2 && cells(cs[0]).length === 10 && cells(cs[0])[0] === 'B2' && num(cells(cs[0])[9]) === 5000, '수금 2곳 · 칸 10 · B2 5,000 먼저');
  ok(cells(cs[1]).slice(3).join('|') === '2|300|0|700|0|10|1,000', 'A1 = 2건 · 현금 300 · 카드 700 · 할인 10 · 합계 1,000 — ' + cells(cs[1]).slice(3).join('|'));
  ok(cs.reduce((a, x) => a + num(cells(x)[9]), 0) === num(cells(tot[0])[7]), '수금 거래처 합 = 합 계');
  ctx.psDtl('PURCH', true); cs = rowsOf(html(), 'csum');
  ok(cs.length === 1 && num(cells(cs[0])[6]) === 1100 && heads(html())[4] === '공급가', '매입 거래처 줄 1 · 합계 1,100');
  ctx.psDtl('PAY', true); cs = rowsOf(html(), 'csum');
  ok(cs.length === 1 && num(cells(cs[0])[5]) === 1100 && num(cells(cs[0])[9]) === 1100 && heads(html())[5] === '무통장지급', '지급 거래처 줄 1 · 무통장 1,100');

  /* ── ⑥ 탭 유지 · 지출엔 탭 없음 · 일자별로 돌아가기 */
  ctx.psDtl('SALE'); ok(ctx._dtlTab === 'cust' && heads(html())[0] === '거래처코드', '다른 구분의 [상세보기]를 눌러도 고른 탭 그대로');
  ctx.psDtl('EXP', true); ok(ctx.expCalls === 1 && el('psDtlTabs').style.display === 'none', '지출 상세 = 탭 줄 숨김 · 지출 그리기');
  ctx.psDtlTab('date'); ok(ctx._dtlTab === 'date' && ctx.expCalls === 1, '지출을 보는 중 탭을 바꿔도 다시 그리지 않는다(값만 기억)');
  ctx._rows = MIX; ctx.psDtl('SALE', true); h = html();
  ok(el('psDtlTabs').style.display === '' && heads(h)[0] === '매출일자' && rowsOf(h, 'dsum').length === 4 && !/class="csum/.test(h), '일자별로 돌아오면 원래 목록');

  /* ── ⑦ 엑셀 — 탭별 시트 */
  let x = ctx.xsDtl('SALE');
  ok(x.ncol === 9 && x.kinds.filter(k => k === 'row').length === 8 && x.kinds.filter(k => k === 'dsum').length === 4 && x.kinds.filter(k => k === 'tot').length === 1 && x.kinds.indexOf('csum') < 0 && x.kinds.indexOf('chd') < 0, '엑셀 일자별 = 전표 8 · 일 계 4 · 합 계 1 (거래처 줄 없음)');
  ok(x.aoa[0][0] === '매출 상세' && x.aoa[x.aoa.length - 1][0] === '합 계 (8건)' && x.aoa[x.aoa.length - 1][7] === 23789402 && x.mg.every(m => m.e.c === 4), '엑셀 일자별 제목·합 계·병합(0~4)');
  ok(ctx.psDtlNm() === '매출 상세', '시트 이름(일자별) = 매출 상세');
  ctx._rows = [ { gb:'RCV', dt:'20260103', trxNo:'0001', custCd:'A1', custNm:'가상사', mgrNm:'마스터', payGb:'현금', amt:300, dcAmt:0 } ];
  x = ctx.xsDtl('RCV'); ok(x.ncol === 12 && x.aoa[4][5] === '현금' && x.aoa[4][11] === 300, '엑셀 수금 일자별 = 구분 칸 포함 12칸');
  ctx._rows = period; ctx._dtlTab = 'cust'; ctx._dtlGb = 'SALE'; x = ctx.xsDtl('SALE');
  ok(ctx.psDtlNm() === '매출 거래처합' && x.aoa[0][0] === '매출 거래처합' && x.ncol === 8 && x.aoa[3].join('|') === '거래처코드|거래처명|담당사원|건수|공급가|부가세|합계|DC', '엑셀 거래처합 제목·머리글 8칸');
  ok(x.kinds.slice(4).join(',') === 'chd,csum,csum,tot,chda,csum,csum,csum,tot', '엑셀 거래처합 = 검색 기간(머리·2곳·합 계) + 전체 기간(머리·3곳·전체 합 계) — ' + x.kinds.slice(4).join(','));
  ok(x.aoa[5].join('|') === '00273|삼성웰스토리 용인|마스터|1|300|30|330|0' && x.aoa[7].join('|') === '합 계|||2|400|40|440|0', '엑셀 검색 기간 줄·합 계 값');
  ok(x.aoa[9][0] === '001532' && x.aoa[9][6] === 5500 && x.aoa[12].join('|') === '전체 합 계|||4|6400|640|7040|0', '엑셀 전체 기간 줄·전체 합 계 값');
  ok(x.mg.filter(m => m.e.c === 7).map(m => m.s.r).join(',') === '4,8' && x.mg.filter(m => m.e.c === 2).map(m => m.s.r).join(',') === '7,12' && x.nums.join(',') === '3,4,5,6,7', '엑셀 병합 = 머리줄 전 칸 · 합 계 0~2 · 숫자 칸 3~7');
  ctx.psDtlTab('date'); ok(ctx.psDtlNm() === '매출 상세', '일자별로 바꾸면 시트 이름도 「매출 상세」');
  ctx._dtlGb = 'EXP'; ctx._dtlTab = 'cust'; ok(ctx.psDtlNm() === '지출 상세' && ctx.xsDtl('EXP').exp === true, '지출은 탭과 무관하게 「지출 상세」');

  /* ── ⑧ 조건이 바뀌면(다시 조회) 다시 읽는다 · 실패 */
  ctx._dtlGb = 'SALE'; ctx._q = '&mgrCd=001&whCd=&prodCd='; ctx._all.key = null; ctx.posts.length = 0; ctx.psDtl('SALE', true);
  ok(ctx.posts.length === 1 && /mgrCd=001/.test(ctx.posts[0].body), '조건 바뀌면 새 조건으로 다시 요청');
  await tick(); await tick();
  ctx._all = { key:null, rows:null, busy:false, err:'' }; ctx.allResp = () => Promise.reject(new Error('로그인이 끊겼습니다'));
  ctx.psDtl('SALE', true); await tick(); await tick(); h = html();
  ok(/불러오지 못했습니다 : 로그인이 끊겼습니다/.test(allTr(h)[0] || '') && rowsOf(h, 'csum').length === 2, '실패하면 사유 한 줄 · 검색 기간 묶음은 그대로');
  ok(ctx.xsDtl('SALE').kinds.indexOf('chda') < 0, '못 읽었으면 엑셀에도 전체 묶음 없음');
  /* 일자별 탭을 보는 중 전체가 늦게 도착해도 목록을 다시 그리지 않는다 */
  let late; ctx._all = { key:null, rows:null, busy:false, err:'' }; ctx.allResp = () => new Promise(r => { late = r; });
  ctx.psDtl('SALE', true); ctx.psDtlTab('date'); el('psDtl').innerHTML = 'MARK'; late({ rows: [] }); await tick(); await tick();
  ok(html() === 'MARK' && ctx._all.rows && ctx._all.rows.length === 0, '일자별을 보는 중 도착한 전체 자료는 받아만 두고 다시 그리지 않는다');

  /* 접혀 있는 동안 도착한 전체 자료도 받아만 둔다 */
  let late2; ctx._dtlTab = 'cust'; ctx._allOpen = true; ctx._all = { key:null, rows:null, busy:false, err:'' }; ctx.allResp = () => new Promise(r => { late2 = r; });
  ctx._rows = period; ctx.psDtl('SALE', true); ctx.psAllFold(); el('psDtl').innerHTML = 'MARK2'; late2({ rows: [] }); await tick(); await tick();
  ok(html() === 'MARK2' && ctx._allOpen === false, '접은 뒤 도착한 전체 자료는 다시 그리지 않는다');
  /* 지출·일자별을 보는 중에는 값만 바뀐다 */
  ctx._dtlTab = 'date'; el('psDtl').innerHTML = 'MARK3'; ctx.psAllFold(); ok(ctx._allOpen === true && html() === 'MARK3', '일자별 탭에서는 접기 상태만 바뀌고 다시 그리지 않는다'); ctx._allOpen = false;

  /* ── ⑨ 빈 목록 */
  ctx._rows = []; ctx._dtlTab = 'date'; ctx.psDtl('SALE', true); h = html();
  ok(/매출 전표가 없습니다/.test(h) && rowsOf(h, 'tot').length === 1, '일자별 빈 목록 안내');

  console.log((fail ? '✗ ' : '✓ ') + 'sim_perfCustSum : ' + pass + ' 통과 · ' + fail + ' 실패');
  process.exit(fail ? 1 : 0);
})();
