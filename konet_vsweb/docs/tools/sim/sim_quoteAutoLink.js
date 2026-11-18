/* 견적서 작성 ▸ [⚡ 자동연계 작성] 시뮬 (2026-11-18)
   quoteEdit.jsp 를 <통째로> jsdom 에 올리고(인라인 스크립트 전부) 그 위에 asset/js/quote-autolink.js 를 얹어 돌린다 —
   자동연계가 만든 줄이 «손으로 적은 줄과 같은 자료»인지(계산·저장 본문·다시 열기)까지 본다.

   쓰는 법 : NODE_PATH=<jsdom 이 있는 node_modules> node docs/tools/sim/sim_quoteAutoLink.js [docs.txt lines.txt]
     · 인자 없이 = 내장 견본 자료
     · docs.txt · lines.txt = DbRead 로 뽑은 selectQuoteHistDocs / selectQuoteHistLines 결과(운영 자료로 한 번 더 — 조회만) */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + (typeof info==='string'?info:JSON.stringify(info)) : '')); } }
const near = (a, b, e) => Math.abs(a - b) < (e || 1e-6);
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

/* ── 화면 올리기 ── */
const JSP = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/quoteEdit.jsp'), 'utf8').replace(/\r\n/g, '\n');
const AUTO = fs.readFileSync(path.join(ROOT, 'src/main/webapp/asset/js/quote-autolink.js'), 'utf8').replace(/\r\n/g, '\n');
t('작성 화면이 자동연계 스크립트를 싣는다(?v= 포함)', /asset\/js\/quote-autolink\.js\?v=\d{8}/.test(JSP));
t('작성 화면에 [⚡ 자동연계 작성] 단추(잠금 대상)', /<button class="btn lockable" id="alBtn"[^>]*onclick="if\(window\.alOpen\) alOpen\(\);/.test(JSP));
let html = JSP.replace(/<%--[\s\S]*?--%>/g, '').replace(/<%@[\s\S]*?%>/g, '').replace(/\$\{pageContext\.request\.contextPath\}/g, '');
const bodyM = /<body[^>]*>([\s\S]*)<\/body>/.exec(html); if(!bodyM) throw new Error('body 없음');
const scripts = []; const body = bodyM[1].replace(/<script\b[^>]*>([\s\S]*?)<\/script>/g, (m, s) => { if(s.trim()) scripts.push(s); return ''; });
if(scripts.length !== 1) throw new Error('인라인 스크립트 수 ' + scripts.length);

/* ── 견본 자료 — 지난 견적 3건 ── */
const ex = (a, b) => [{ nm:'동판비', qty:a?a[0]:0, price:a?a[1]:0, use:a?a[2]:'off', hide:false }, { nm:'목형비', qty:b?b[0]:0, price:b?b[1]:0, use:b?b[2]:'off', hide:false }];
const cj = (set, calcs, genRows) => JSON.stringify({ v:1, use2:true, set, calcs, genRows: genRows||[] });
const C = (o) => Object.assign({ variant:false, moqQty:0, buy:0, buyMemo:'', feeOpen:false, box:0, trans:0, store:0, storeManual:false, storeVal:0, split:0, pack:0, target:0, tgtAmt:0, lgFee:'', extras:ex() }, o);
const SET_C = { mode:'center', center:'평/용센터', fee:0, rate:10.5, dcRate:11.5 }, SET_P = { mode:'parcel', center:'평/용센터', fee:4500, rate:10.5, dcRate:11.5 };
let DOCS = [
  { quoteSeq:900, docNo:'Konet261111-01', quoteDt:'20261111', recvNm:'삼성웰스토리', mgrNm:'담당A', statGb:'S',
    calcJson: cj(SET_C, [ C({ moqQty:50000, buy:19.5, box:2000, target:20, extras:ex([1,160000,'cost']) }), C({ variant:true, moqQty:100000, buy:18.5, box:2000, target:20, extras:ex([1,160000,'cost']) }),
                          C({ moqQty:9000, buy:145, box:300, store:8.3, storeManual:true, target:15, extras:ex(null,[1,175000,'sub']) }) ], [4]) },
  { quoteSeq:880, docNo:'Konet261020-01', quoteDt:'20261020', recvNm:'샐러링', mgrNm:'담당B', statGb:'A',
    calcJson: cj(SET_P, [ C({ moqQty:12500, buy:66.2, box:500, store:6, storeManual:true, target:10, lgFee:4090.909, buyMemo:'도매몰 139원' }), null ], []) },
  { quoteSeq:870, docNo:'Konet261001-01', quoteDt:'20261001', recvNm:'삼성웰스토리', mgrNm:'담당A', statGb:'S',
    calcJson: cj(SET_C, [ C({ moqQty:30000, buy:21, box:2000, target:18 }) ], []) },
];
/* 제출완료·채택이 아닌 견적 — 이력에 나오면 안 된다 (2026-11-18). 날짜를 가장 최근으로 둬 「최근 것이 앞」에도 안 끼는지 본다 */
DOCS.push({ quoteSeq:960, docNo:'Konet261117-09', quoteDt:'20261117', recvNm:'삼성웰스토리', mgrNm:'담당A', statGb:'W', calcJson: cj(SET_C, [ C({ moqQty:1000, buy:5, box:100, target:10 }), C({ moqQty:9000, buy:999, box:300, target:15 }) ], []) });
DOCS.push({ quoteSeq:961, docNo:'Konet261117-08', quoteDt:'20261117', recvNm:'삼성웰스토리', mgrNm:'담당A', statGb:'R', calcJson: cj(SET_C, [ C({ moqQty:2000, buy:6, box:100, target:10 }) ], []) });
DOCS.push({ quoteSeq:962, docNo:'Konet261117-07', quoteDt:'20261117', recvNm:'삼성웰스토리', mgrNm:'담당A', statGb:'H', calcJson: cj(SET_C, [ C({ moqQty:3000, buy:7, box:100, target:10 }) ], []) });
let LINES = [
  { quoteSeq:960, rowNo:1, prodNm:'작성 중인 품목', spec:'', boxQty:1, unit:'ea', qty:100, unitPrice:9, unitPrice2:null, remark:'', prodCd:'', makerNm:'' },
  { quoteSeq:960, rowNo:2, prodNm:'이벤트 박스', spec:'300*200*100', boxQty:1, unit:'ea', qty:300, unitPrice:1500, unitPrice2:null, remark:'', prodCd:'', makerNm:'' },
  { quoteSeq:961, rowNo:1, prodNm:'거절된 품목', spec:'', boxQty:1, unit:'ea', qty:100, unitPrice:9, unitPrice2:null, remark:'', prodCd:'', makerNm:'' },
  { quoteSeq:962, rowNo:1, prodNm:'보류된 품목', spec:'', boxQty:1, unit:'ea', qty:100, unitPrice:9, unitPrice2:null, remark:'', prodCd:'', makerNm:'' },
  { quoteSeq:900, rowNo:1, prodNm:'(아벡쉐리)성탄절U 봉투', spec:'150*200', boxQty:1, unit:'ea', qty:2000, unitPrice:36.5, unitPrice2:null, remark:'MOQ 50,000개', prodCd:'', makerNm:'선피앤피' },
  { quoteSeq:900, rowNo:2, prodNm:'(아벡쉐리)성탄절U 봉투', spec:'150*200', boxQty:1, unit:'ea', qty:2000, unitPrice:30, unitPrice2:null, remark:'MOQ 100,000개', prodCd:'', makerNm:'선피앤피' },
  { quoteSeq:900, rowNo:3, prodNm:'이벤트 박스', spec:'300*200*100', boxQty:1, unit:'ea', qty:300, unitPrice:197, unitPrice2:null, remark:'MOQ 9,000개', prodCd:'', makerNm:'' },
  { quoteSeq:900, rowNo:4, prodNm:'목형비', spec:'', boxQty:null, unit:'ea', qty:1, unitPrice:175000, unitPrice2:null, remark:'별도 청구', prodCd:'', makerNm:'' },
  { quoteSeq:880, rowNo:1, prodNm:'샐러링 종이용기', spec:'1000ml', boxQty:1, unit:'ea', qty:500, unitPrice:160, unitPrice2:null, remark:'MOQ 12,500개', prodCd:'', makerNm:'' },
  { quoteSeq:880, rowNo:2, prodNm:'샐러링 PET 뚜껑', spec:'', boxQty:5, unit:'ea', qty:25000, unitPrice:72, unitPrice2:null, remark:'MOQ 25,000개', prodCd:'', makerNm:'' },
  { quoteSeq:870, rowNo:1, prodNm:'(아벡쉐리)성탄절U  봉투', spec:'150*200 구판', boxQty:1, unit:'ea', qty:2000, unitPrice:27.7, unitPrice2:null, remark:'MOQ 30,000개', prodCd:'', makerNm:'선피앤피' },
];
const PRODS = [
  { prodCd:'4003071185', prodNm:'핫도그 트레이', spec:'180*60', makerNm:'대상', packQty:1000, inPrice:48, salePrice:62, stopYn:'N' },
  { prodCd:'9904012907', prodNm:'플래터 용기', spec:'대', makerNm:'', packQty:400, inPrice:90, salePrice:108, stopYn:'N' },
  { prodCd:'STOP01', prodNm:'중지 품목', spec:'', makerNm:'', packQty:10, inPrice:1, salePrice:2, stopYn:'Y' },
  { prodCd:'3004', prodNm:'크라프트 컵 300', spec:'300ml', makerNm:'', packQty:50, inPrice:30, salePrice:40, stopYn:'N' },
  { prodCd:'A3009', prodNm:'리드 뚜껑', spec:'', makerNm:'', packQty:100, inPrice:10, salePrice:15, stopYn:'N' },
];

/* DbRead 출력(고정 폭 표) → 줄.  ⚠칸 폭은 «글자 수»가 아니라 «표시 폭»이다(DbRead.width — 0x1100 넘는 글자는 2칸) — 한글이 든 칸을 글자 수로 자르면 뒤 칸이 전부 밀린다 */
function parseDbRead(file){
  const L = fs.readFileSync(file, 'utf8').replace(/\r\n/g, '\n').split('\n');
  const di = L.findIndex(x => /^-{2,}( {2}-{2,})*\s*$/.test(x)); if(di < 1) throw new Error('표 머리 없음 ' + file);
  const widths = L[di].split('  ').map(seg => seg.length);
  const cut = (x) => { const out = []; let p = 0; widths.forEach((wd, k) => { if(k === widths.length - 1){ out.push(x.slice(p).trim()); return; }
      let w0 = 0, q = p; while(q < x.length && w0 < wd){ w0 += (x.charCodeAt(q) > 0x1100 ? 2 : 1); q++; } out.push(x.slice(p, q).trim()); p = q + 2; }); return out; };
  const names = cut(L[di-1]); const rows = [];
  for(let i = di + 1; i < L.length; i++){ const x = L[i]; if(!x.trim()) break; const v = cut(x), o = {}; names.forEach((nm, k) => { o[nm] = v[k]; }); rows.push(o); }
  return rows;
}
const REAL = process.argv.length >= 4;
if(REAL){
  DOCS = parseDbRead(process.argv[2]).map(r => ({ quoteSeq:+r.quoteSeq, docNo:r.docNo, quoteDt:r.quoteDt, recvNm:r.recvNm, mgrNm:r.mgrNm, statGb:r.statGb, calcJson:r.calcJson }));
  const num = v => (v === '' || v === 'null' || v == null) ? null : +v;
  LINES = parseDbRead(process.argv[3]).map(r => ({ quoteSeq:+r.quoteSeq, rowNo:+r.rowNo, prodNm:r.prodNm, spec:r.spec, boxQty:num(r.boxQty), unit:r.unit, qty:num(r.qty), unitPrice:num(r.unitPrice), unitPrice2:num(r.unitPrice2), remark:r.remark, prodCd:r.prodCd, makerNm:r.makerNm }));
}

const dom = new JSDOM('<!DOCTYPE html><html><head></head><body>' + body + '</body></html>', { runScripts:'outside-only', url:'http://localhost/mangr/quoteEdit.do' });
const w = dom.window, d = w.document;
w.__alerts = []; w.__toasts = []; w.__confirms = []; w.__posts = []; w.__histFail = false; w.__saved = null;
w._alertBox = (m) => { w.__alerts.push(String(m)); };
w._toast = (m) => { w.__toasts.push(String(m)); };
w._confirmBox = (o) => { w.__confirms.push(String(o.msg)); if(w.__confirmNo){ if(o.onCancel) o.onCancel(); } else if(o.onOk) o.onOk(); };
w.HTMLElement.prototype.scrollIntoView = function(){};
const J = (o, st) => Promise.resolve({ ok:(st||200)===200, status:st||200, json:() => Promise.resolve(JSON.parse(JSON.stringify(o))), text:() => Promise.resolve(JSON.stringify(o)) });
w.fetch = (url, opt) => { url = String(url); w.__posts.push({ url, body: opt && opt.body });
  if(url.indexOf('quoteItemHist') >= 0) return w.__histFail ? J({}, 404) : J({ docs:DOCS, lines:LINES });
  if(url.indexOf('/prod/prodList') >= 0) return J({ data:PRODS });
  if(url.indexOf('extItemList') >= 0) return J({ data:[{ prodCd:'9904012907', extItemCd:'EXT-PLT', extItemNm:'플래터', extSpec:'' }] });
  if(url.indexOf('quoteNames') >= 0) return J({ mgr:['담당A'], recv:['삼성웰스토리'] });
  if(url.indexOf('quoteNextNo') >= 0) return J({ docNo:'Konet261118-01' });
  if(url.indexOf('quoteMst') >= 0) return J(w.__saved || {});
  return J({});
};
w.eval(scripts[0]);
w.eval(AUTO);
const $ = (s) => d.querySelector(s), $$ = (s) => Array.from(d.querySelectorAll(s));
const ev = (code) => w.eval(code);
/* jsdom 'outside-only' 는 태그에 적힌 oninput="…" 을 돌리지 않는다 — 속성 글자를 그 요소를 this 로 직접 돌린다 */
const run = (el, attr) => { const code = el.getAttribute(attr); if(!code) throw new Error(attr + ' 없음 : ' + el.outerHTML.slice(0, 80)); w.__el = el; w.eval('(function(){' + code + '}).call(window.__el)'); };
const type = (el, v) => { el.value = String(v); run(el, 'oninput'); };
const fire = type;
const A = () => w._alDbg.AL;
/* 화면 식으로 직접 계산 — 자동연계 값과 맞대는 기준 */
const ref = (o, sell, extras) => w.calcOf({ variant:false, unitPrice:sell, calc: w.normCalc(Object.assign({ extras: extras || ex() }, o)) });

(async () => {
  await sleep(30);
  t('화면이 떴다(빈 줄 1)', ev('_lines.length') === 1 && !!$('#alBtn'));
  t('창은 아직 없다(누르기 전엔 만들지 않는다)', !$('#alPop'));
  /* ✕ 로 줄을 빼도 「되살리기」 알림은 안 뜬다(단추·기능은 그대로) — 2026-11-18 「삭제표시하면 되돌린다는 메세지 제거」 */
  ev("_lines[0].prodNm='뺄 줄'; _lines.push(blank()); renderLines();"); w.__toasts.length = 0; w.delLine(0);
  t('★줄 ✕ — 알림 없음 · [↩ 뺀 줄 되살리기] 단추는 보인다', w.__toasts.length === 0 && ev('_lines.length') === 1 && $('#undoBtn').style.display !== 'none');
  w.undoLine();
  t('되살리기는 그대로 된다', ev('_lines.length') === 2 && ev('_lines[0].prodNm') === '뺄 줄');
  w.newDoc(); await sleep(30);
  t('늘 보이는 설명은 짧게(물류비 줄·표 머리)', $('#csNote').textContent === '판매 계 × 센터 비율' && /견적서 줄\s*— 인쇄되는 칸/.test($('#lhead').textContent) && $('#hdTip').textContent.length < 25, [$('#csNote').textContent, $('#hdTip').textContent]);

  /* ── 1. 이력 짜기 ── */
  const H = w._alDbg.buildHist(DOCS, LINES);
  if(!REAL){
    t('이력 — 품목 벌 5개(동판·목형 서브 줄·genRows 제외)', H.sets.length === 5, H.sets.map(s => s.prodNm));
    t('★이력 — 제출완료·채택 견적만 : 작성 중·거절·보류 견적의 품목은 없다', !H.items.some(i => /작성 중인|거절된|보류된/.test(i.prodNm)) && H.sets.every(s => s.statGb === 'S' || s.statGb === 'A'), H.items.map(i => i.prodNm));
    t('★같은 품명이 작성 중 견적에 더 최근 값(단가 999)으로 있어도 제출완료 값(145)을 쓴다 · 횟수에도 안 센다', (() => { const b0 = H.items.find(i => i.prodNm === '이벤트 박스'); return b0 && b0.cnt === 1 && b0.sets.length === 1 && b0.sets[0].rows[0].buy === 145 && b0.sets[0].quoteSeq === 900; })());
    t('이력 — 같은 품명(빈칸 차이 무시)은 한 품목 : 4종', H.items.length === 4, H.items.map(i => i.prodNm));
    const it = H.items.find(i => /성탄절U/.test(i.prodNm));
    t('이력 — 성탄절U 봉투 = 견적 2회 · 최근 것이 앞', it && it.cnt === 2 && it.sets[0].quoteSeq === 900 && it.sets[1].quoteSeq === 870);
    t('이력 — MOQ 변형 줄이 한 벌로 묶인다(50,000 · 100,000)', it && it.sets[0].rows.length === 2 && it.sets[0].rows[0].moqQty === 50000 && it.sets[0].rows[1].moqQty === 100000 && it.sets[0].rows[1].buy === 18.5);
    t('이력 — 동판비 원가 포함이 따라온다', it && it.sets[0].extras[0].nm === '동판비' && it.sets[0].extras[0].price === 160000 && it.sets[0].extras[0].use === 'cost');
    const bx = H.items.find(i => i.prodNm === '이벤트 박스');
    t('이력 — 목형비 별도 청구 · 보관 직접값 · 입수량', bx && bx.sets[0].extras[1].use === 'sub' && bx.sets[0].rows[0].base.storeManual && bx.sets[0].rows[0].base.store === 8.3 && bx.sets[0].box === 300);
    const sl = H.items.find(i => i.prodNm === '샐러링 종이용기');
    t('이력 — 줄 물류비·메모·갈래(직송)', sl && near(sl.sets[0].rows[0].base.lgFee, 4090.909) && sl.sets[0].rows[0].buyMemo === '도매몰 139원' && sl.sets[0].mode === 'parcel');
    const pt = H.items.find(i => i.prodNm === '샐러링 PET 뚜껑');
    t('이력 — 계산 없는 줄은 비고의 MOQ 를 읽는다', pt && pt.sets[0].rows[0].moqQty === 25000 && pt.sets[0].rows[0].buy === 0 && pt.sets[0].rows[0].sell === 72);
  }

  /* ── 2. 창 열기 ── */
  d.getElementById('recvNm').value = '삼성웰스토리';
  w.alOpen(); await sleep(60);
  t('창이 열린다', !!$('#alPop') && $('#alPop').classList.contains('on'));
  t('이력·상품을 한 번씩 읽는다', w.__posts.filter(p => p.url.indexOf('quoteItemHist') >= 0).length === 1 && w.__posts.filter(p => p.url.indexOf('/prod/prodList') >= 0).length === 1);
  if(!REAL) t('읽은 품목 수 옆에 기준을 적는다(제출완료·채택)', /4종 \(제출완료·채택\)/.test($('#alLoad').textContent), $('#alLoad').textContent);
  t('물류비 갈래를 보여 준다(센터배송 · 기준 센터)', /센터배송 · 기준 평\/용센터 10\.5%/.test($('#alMode').textContent), $('#alMode').textContent);
  if(!REAL){
    t('수신 거르기 — 처음 = 지금 견적서의 수신처', $('#alRecv').value === '삼성웰스토리');
    t('빈 검색 = 그 수신처의 최근 견적 품목 2종', $$('#alHits tr.pick').length === 2, $$('#alHits tr').map(x => x.textContent.slice(0, 40)));
    w.alRecvSet(''); t('수신 전체 = 4종', $$('#alHits tr.pick').length === 4);
    fire($('#alQ'), '봉투 150'); await sleep(160);
    t('띄어 쓴 낱말이 모두 든 것만', $$('#alHits tr.pick').length === 1 && /성탄절U/.test($('#alHits').textContent));
    t('결과에 MOQ → 배송 단가 · 판매단가 · 동판·목형이 보인다', /50,000 → 19\.50 \/ 100,000 → 18\.50/.test($('#alHits').textContent) && /36\.50 \/ 30\.00/.test($('#alHits').textContent) && /동판 160,000\(원가\)/.test($('#alHits').textContent), $('#alHits').textContent);

    /* ── 3. 지난 견적 품목 고르기 → 자동 채움·자동 계산 ── */
    w.alPick(0);
    const b = A().blocks[0];
    t('묶음 — 품명·규격·제조사·입수량이 채워진다', b && b.prodNm === '(아벡쉐리)성탄절U 봉투' && b.spec === '150*200' && b.makerNm === '선피앤피' && b.box === 2000);
    t('묶음 — MOQ 줄 2개(수량·단가·목표 마진율)', b.rows.length === 2 && b.rows[0].buy === 19.5 && b.rows[1].moqQty === 100000 && b.rows[0].target === 20);
    const r0 = ref({ moqQty:50000, buy:19.5, box:2000, target:20 }, 0, ex([1,160000,'cost']));
    t('★구단(계산) = 화면 식 그대로 : 19.5 + 보관 4.5 + 동판 160,000÷50,000', near(r0.H, 19.5 + 225000/50000 + 3.2) && $('#alH0_0').textContent === w.fmt(r0.H, 2), [$('#alH0_0').textContent, r0.H]);
    t('★필요 판매단가 = 화면 식 그대로', $('#alN0_0').textContent === w.fmt(r0.need, 2), [$('#alN0_0').textContent, r0.need]);
    t('★조건을 안 바꾼 줄 = 그때 단가 그대로(필요 판매단가 36.47 이 아니라 손봐서 낸 36.50)', near(r0.need, 36.4692, 1e-3) && near(n$('#alS0_0'), 36.5) && near(n$('#alS0_1'), 30) && $('#alS0_0').className === 'ca' && /그때와 같습니다/.test($('#alS0_0').title), [$('#alS0_0').value, $('#alS0_1').value]);
    const r0s = ref({ moqQty:50000, buy:19.5, box:2000, target:20 }, 36.5, ex([1,160000,'cost']));
    t('실 마진율 = 화면 식 그대로(그때 단가 기준 ≈ 20.1%)', $('#alM0_0').textContent === w.fmt(r0s.S*100, 2) + '%' && r0s.S > 0.2, $('#alM0_0').textContent);
    w.alRow(0, 0, 'target', 21);
    const r0t = ref({ moqQty:50000, buy:19.5, box:2000, target:21 }, 0, ex([1,160000,'cost']));
    t('★조건을 바꾸면(목표 마진율 20 → 21) 필요 판매단가로 다시 계산', near(n$('#alS0_0'), Math.round(r0t.need*100)/100) && near(n$('#alS0_1'), 30) && /필요 판매단가/.test($('#alS0_0').title), $('#alS0_0').value);
    w.alRow(0, 0, 'target', 20);
    t('되돌리면 다시 그때 단가', near(n$('#alS0_0'), 36.5));
    const r1 = ref({ moqQty:100000, buy:18.5, box:2000, target:20 }, 0, ex([1,160000,'cost']));
    t('★둘째 MOQ 줄도 동판 원가 포함 : 160,000 ÷ 100,000 = 1.6', near(r1.exPer, 1.6) && $('#alH0_1').textContent === w.fmt(r1.H, 2), $('#alH0_1').textContent);
    t('참고 단가 = 지난 견적 단가', /지난 견적 36\.50/.test($('#alB0').textContent) && /지난 견적 30\.00/.test($('#alB0').textContent));
    t('출처 = 같은 품명의 견적서 고르기(2건)', $$('#alB0 .al-src select option').length === 2);

    /* 사람이 정하는 칸을 바꾸면 바로 다시 계산 */
    type($$('#alB0 tbody tr')[0].querySelectorAll('input.ci')[1], '21');   // 배송 단가 19.5 → 21
    const r0b = ref({ moqQty:50000, buy:21, box:2000, target:20 }, 0, ex([1,160000,'cost']));
    t('배송 단가를 고치면 구단·판매적용단가가 따라온다', $('#alH0_0').textContent === w.fmt(r0b.H, 2) && near(n$('#alS0_0'), Math.round(r0b.need*100)/100), [$('#alH0_0').textContent, $('#alS0_0').value]);
    type($$('#alB0 tbody tr')[0].querySelectorAll('input.ci')[1], '');
    t('★배송 단가를 비우면 보관을 계산하지 않는다(11-18 규칙)', near(w._alDbg.rowCalc(b, b.rows[0]).c.store, 0));
    t('★배송 단가가 비면 동판 원가 포함 몫만으로 판매단가를 내지 않는다 — 지난 단가를 쓴다', near(n$('#alS0_0'), 36.5) && $('#alN0_0').textContent === '', [$('#alS0_0').value, $('#alN0_0').textContent]);
    type($$('#alB0 tbody tr')[0].querySelectorAll('input.ci')[1], '19.5');

    /* 판매단가 자릿수 */
    w.alRow(0, 0, 'buy', 19.6);
    const rq = ref({ moqQty:50000, buy:19.6, box:2000, target:20 }, 0, ex([1,160000,'cost']));
    $('#alRound').value = '0.5'; w.alOpt('round', '0.5');
    const up = Math.ceil(rq.need / 0.5 - 1e-7) * 0.5;
    t('자릿수 0.5원 올림(조건을 바꾼 줄)', near(n$('#alS0_0'), up) && up >= rq.need && up - rq.need < 0.5, [$('#alS0_0').value, rq.need]);
    const rqu = ref({ moqQty:50000, buy:19.6, box:2000, target:20 }, up, ex([1,160000,'cost']));
    t('올린 단가로 실 마진율을 다시 보여 준다(≥ 목표)', $('#alM0_0').textContent === w.fmt(rqu.S*100, 2) + '%' && rqu.S >= 0.2 - 1e-9, $('#alM0_0').textContent);
    t('자릿수는 안 바꾼 줄(그때 단가)에는 안 걸린다', near(n$('#alS0_1'), 30));
    $('#alRound').value = '2'; w.alOpt('round', '2'); w.alRow(0, 0, 'buy', 19.5);

    /* 직접 넣은 단가 · 되돌리기 */
    w.alSell(0, 0, '30');
    t('판매적용단가를 직접 적으면 노란 칸 · 그 값으로 실 마진율', $('#alS0_0').className === 'cm' && $('#alM0_0').textContent === w.fmt(ref({ moqQty:50000, buy:19.5, box:2000, target:20 }, 30, ex([1,160000,'cost'])).S*100, 2) + '%');
    w.alSell(0, 0, null);
    t('↻ = 자동으로 되돌림', $('#alS0_0').className === 'ca' && near(n$('#alS0_0'), 36.5));
    w.alSell(0, 1, 30);
    t('[←] 참고 단가 넣기', A().blocks[0].rows[1].sellMan && near(n$('#alS0_1'), 30));
    w.alSell(0, 1, null);

    /* 동판·목형 갈래 */
    w.alFee(0, 0, 'use', 'sub');
    t('동판비를 별도 청구로 바꾸면 구단에서 빠진다', near(w._alDbg.rowCalc(b, b.rows[0]).c.exPer, 0));
    w.alFee(0, 0, 'use', 'cost');

    /* 다른 견적서 값으로 */
    w.alSrc(0, 1);
    t('출처를 바꾸면 그 견적서 값으로 다시 채운다', b.rows.length === 1 && b.rows[0].moqQty === 30000 && b.spec === '150*200 구판' && b.extras[0].use === 'off');
    w.alSrc(0, 0);

    /* ＋MOQ */
    w.alRowAdd(0);
    t('＋MOQ — 윗줄 조건(목표 마진율)을 물려받은 빈 줄', b.rows.length === 3 && b.rows[2].moqQty === 0 && b.rows[2].target === 20);
    const tr3 = $$('#alB0 tbody tr')[2].querySelectorAll('input.ci'); type(tr3[0], '200,000'); type(tr3[1], '18');
    const r2 = ref({ moqQty:200000, buy:18, box:2000, target:20 }, 0, ex([1,160000,'cost']));
    t('새 MOQ 줄도 바로 계산(동판 ÷ 200,000 = 0.8)', near(r2.exPer, 0.8) && near(n$('#alS0_2'), Math.round(r2.need*100)/100), $('#alS0_2').value);


    /* ── 4. 상품마스터 · 직접 입력 ── */
    fire($('#alQ'), '플래터'); await sleep(160);
    t('상품마스터에서도 찾는다(매칭코드 포함)', $$('#alHits tr.pick').length === 1 && /9904012907/.test($('#alHits').textContent));
    w.alPick(0);
    const bp = A().blocks[1];
    t('상품 — 코드·입수량·매입가(배송 단가)·판매가(참고)', bp && bp.prodCd === '9904012907' && bp.box === 400 && bp.rows[0].buy === 90 && bp.rows[0].prevSell === 108 && bp.rows[0].prevNm === '상품 판매가');
    t('목표 마진율이 없으면 판매적용단가 = 상품 판매가', near(n$('#alS1_0'), 108));
    type($$('#alB1 tbody tr')[0].querySelectorAll('input.ci')[0], '4000');
    type($$('#alB1 tbody tr')[0].querySelectorAll('input.ci')[2], '15');
    const rp = ref({ moqQty:4000, buy:90, box:400, target:15 }, 0);
    t('목표 마진율을 넣으면 필요 판매단가로 바뀐다', near(n$('#alS1_0'), Math.round(rp.need*100)/100), [$('#alS1_0').value, rp.need]);
    fire($('#alQ'), '중지'); await sleep(160);
    t('거래중지 상품은 보이되 못 고른다', $$('#alHits tr.stop').length === 1 && $$('#alHits tr.pick').length === 0);
    fire($('#alQ'), '신규 테이크아웃 컵'); await sleep(160);
    t('없는 품목 — 직접 입력 안내', /새 품목 직접 입력/.test($('#alHits').textContent));
    w.alNewBlock();
    const bn = A().blocks[2];
    t('직접 입력 묶음 — 찾던 글자가 품명으로', bn && bn.src === 'n' && bn.prodNm === '신규 테이크아웃 컵' && bn.rows.length === 1);
    t('입수량 없이 단가만 넣으면 안내', (type($$('#alB2 tbody tr')[0].querySelectorAll('input.ci')[1], '55'), /박스 입수량을 넣어야/.test($('#alW2').textContent)));
    w.alCode(2, 'NOPE'); await sleep(10);
    t('상품마스터에 없는 코드는 넣지 않는다', A().blocks[2].prodCd === '' && w.__alerts.some(x => /상품마스터에 없는 코드/.test(x)));
    w.alCode(2, '4003071185'); await sleep(10);
    t('있는 코드 → 품명·규격·입수량·매입가를 가져온다(이미 적은 단가는 안 덮는다)', bn.prodNm === '핫도그 트레이' && bn.box === 1000 && bn.rows[0].buy === 55 && bn.rows[0].prevSell === 62);
    w.alBlkDel(2);
    t('✕ 빼기', A().blocks.length === 2);

    /* 이벤트 박스(목형비 별도 청구 · 보관 직접값)도 담는다 */
    fire($('#alQ'), '이벤트'); await sleep(160); w.alPick(0);
    t('담은 품목 3개 · 줄 5개 요약', /품목 <b>3<\/b>개 · 견적서 줄 <b>5<\/b>줄/.test($('#alSum').innerHTML), $('#alSum').innerHTML);

    /* ── 5. 견적서에 넣기 — 기존 줄은 그대로 ── */
    ev("_lines[0].prodNm='손으로 적은 품목'; _lines[0].qty=100; _lines[0].unitPrice=50; renderLines();");
    w.alClose(); w.alOpen(); await sleep(60);
    t('창을 닫았다 열어도 만들던 묶음은 남는다', A().blocks.length === 3);
    t('기존 줄 밑에 붙는다고 알려 준다(짧게)', /기존 1줄 밑에 붙습니다/.test($('#alKeep').textContent), $('#alKeep').textContent);
    const before = JSON.stringify(ev('_lines[0]'));
    w.alApply(); await sleep(20);
    const L = ev('_lines');
    t('★기존 줄은 그대로(값 하나 안 바뀜) · 그 밑에 5줄', L.length === 6 && JSON.stringify(L[0]) === before, L.length);
    t('창이 닫히고 묶음이 비워진다', !$('#alPop').classList.contains('on') && A().blocks.length === 0);
    t('품명 줄 + ↳ MOQ 변형 줄', L[1].variant === false && L[2].variant === true && L[3].variant === true && L[4].variant === false && L[5].variant === false && L[2].prodNm === L[1].prodNm);
    t('마진계산 줄 규칙 : Box 1 · 수량 = 박스 입수량', L[1].boxQty === 1 && L[1].qty === 2000 && L[4].qty === 400 && L[5].qty === 300);
    t('단가 = 판매적용단가 — 안 바꾼 줄은 그때 단가(36.50 · 30 · 197), 새 MOQ 줄·상품 줄은 필요 판매단가', near(L[1].unitPrice, 36.5) && near(L[2].unitPrice, 30) && near(L[3].unitPrice, Math.round(r2.need*100)/100) && near(L[4].unitPrice, Math.round(rp.need*100)/100) && near(L[5].unitPrice, 197), L.map(l => l.unitPrice));
    t('비고 = 「MOQ n개」 자동', L[1].remark === 'MOQ 50,000개' && L[2].remark === 'MOQ 100,000개' && L[3].remark === 'MOQ 200,000개' && L[4].remark === 'MOQ 4,000개');
    t('계산 근거(calc) = 손으로 적은 줄과 같은 꼴', L[1].calc && L[1].calc.moqQty === 50000 && L[1].calc.buy === 19.5 && L[1].calc.box === 2000 && L[1].calc.target === 20 && L[1].calc.extras.length === 2 && L[1].calc.extras[0].use === 'cost'
      && JSON.stringify(Object.keys(L[1].calc).sort()) === JSON.stringify(Object.keys(w.newCalc()).sort()), Object.keys(L[1].calc));
    t('보관 직접값·줄 물류비도 따라온다', L[5].calc.storeManual === true && L[5].calc.store === 8.3 && L[5].calc.extras[1].use === 'sub' && L[5].calc.extras[1].price === 175000);
    t('표에 줄이 그려진다(품목 줄 6 · 새 줄 5개 표시)', $$('#lbody tr.mainln').length === 6 && $$('#lbody tr.mainln.al-new').length === 5);
    t('화면 계산 칸이 창에서 본 값과 같다(구단)', $('#cH1') && $('#cH1').textContent === w.fmt(r0.H, 2), $('#cH1') && $('#cH1').textContent);
    t('알림 한 줄', w.__toasts.some(x => /품목 3개 · 5줄을 기존 1줄 밑에/.test(x)), w.__toasts.slice(-1));

    /* ── 6. 저장 본문 — 종전 payload 그대로 ── */
    d.getElementById('docNo').value = 'Konet261118-01'; d.getElementById('mgrNm').value = '담당A';
    const P = w.payload().docs[0], CJ = JSON.parse(P.calcJson);
    t('저장 줄 = 품목 6 + 목형비 별도 청구 1', P.lines.length === 7 && P.lines[6].prodNm === '목형비' && P.lines[6].remark === '별도 청구' && P.lines[6].amt === 175000, P.lines.map(l => l.prodNm));
    t('원가 포함 동판비는 줄로 안 나가고 비고에 근거', !P.lines.some(l => l.prodNm === '동판비') && /동판비 1 × 160,000 = 160,000 — 원가 포함/.test(P.remark), P.remark);
    t('근거자료 calcs 6 · 변형 표시 · genRows [7]', CJ.calcs.length === 6 && CJ.calcs[2].variant === true && CJ.calcs[1].variant === false && JSON.stringify(CJ.genRows) === '[7]');
    t('금액 = 수량 × 단가', P.lines[1].amt === Math.round(2000 * L[1].unitPrice) && P.lines[4].amt === Math.round(400 * L[4].unitPrice));

    /* ── 7. 저장한 것을 다시 열면 같은 줄 ── */
    w.__saved = { mst:{ docNo:P.docNo, quoteDt:'20261118', recvNm:P.recvNm, mgrNm:P.mgrNm, validTxt:P.validTxt, titleTxt:P.titleTxt, remark:P.remark, price1Nm:P.price1Nm, price2Nm:P.price2Nm, calcJson:P.calcJson, statGb:'W', latestYn:'Y', revNo:1 }, lines:P.lines };
    const snap = L.map(l => ({ nm:l.prodNm, v:!!l.variant, q:l.qty, p:l.unitPrice, moq:l.calc.moqQty, buy:l.calc.buy, ex:l.calc.extras.map(x => [x.nm, x.qty, x.price, x.use]) }));
    w.loadDoc(950); await sleep(40);
    const L2 = ev('_lines');
    t('★다시 열기 = 같은 줄(품명·변형·수량·단가·MOQ·단가·동판·목형)', JSON.stringify(L2.map(l => ({ nm:l.prodNm, v:!!l.variant, q:l.qty, p:l.unitPrice, moq:l.calc.moqQty, buy:l.calc.buy, ex:l.calc.extras.map(x => [x.nm, x.qty, x.price, x.use]) }))) === JSON.stringify(snap));
    w.alOpen(); await sleep(60);
    t('다른 견적서를 열면 만들던 묶음은 비운다', A().blocks.length === 0);
    fire($('#alQ'), '성탄절'); await sleep(160); w.alPick(0);
    t('이미 있는 품명이면 알려 준다(막지는 않는다)', /같은 품명이 이미 있습니다/.test($('#alW0').textContent));
    w.alClear(); t('비우기', A().blocks.length === 0);
    w.alClose();

    /* ── 7-2. 물류비 갈래가 그때와 다른 품목 — 맞추기 ── */
    w.newDoc(); await sleep(30); w.alOpen(); await sleep(60); w.alRecvSet(''); fire($('#alQ'), '샐러링 종이'); await sleep(160); w.alPick(0);
    const bs = A().blocks[0], rs = w._alDbg.rowCalc(bs, bs.rows[0]);
    t('갈래가 다르면(그때 직송 · 지금 센터배송) 그때 단가를 그대로 쓰지 않고 다시 계산', rs.how === 'need' && !near(rs.sell, 160) && /직송 기준이었습니다/.test($('#alW0').textContent) && /직송 · 직송비\/박스 4,500원\(으\)로 맞추기/.test($('#alW0').textContent), [rs.how, rs.sell, $('#alW0').textContent]);
    t('줄 물류비 칸은 센터배송에선 없다', !$('#alLg0_0'));
    w.__confirms.length = 0; w.alModeMatch(0); await sleep(20);
    const rs2 = w._alDbg.rowCalc(bs, bs.rows[0]);
    t('★[이 견적서를 직송으로 맞추기] — 견적서 갈래·직송비가 바뀌고(빈 견적서라 묻지 않음) 그때 단가 160 그대로', ev('_cs.mode') === 'parcel' && ev('_cs.fee') === 4500 && w.__confirms.length === 0 && rs2.how === 'same' && near(rs2.sell, 160) && d.querySelector('input[name=csmode][value=parcel]').checked, [ev('_cs.mode'), rs2.how, rs2.sell]);
    t('맞춘 뒤 안내가 사라지고 줄 물류비 칸(그때 값 4,090.909)이 보인다', !/기준이었습니다/.test($('#alW0').textContent) && $('#alLg0_0') && $('#alLg0_0').className === 'cm' && near(n$('#alLg0_0'), 4091, 1));
    w.alLg(0, 0, ''); const rs3 = w._alDbg.rowCalc(bs, bs.rows[0]);
    t('줄 물류비를 비우면(직송비/박스 기본값) 조건이 달라져 다시 계산', rs3.how === 'need' && near(rs3.c.P, 4500), [rs3.how, rs3.c.P]);
    w.alLg(0, 0, '4090.909'); w.eval('_cs.fee=5000');
    t('직송비/박스가 그때와 다르면 「같다」로 보지 않는다', w._alDbg.rowCalc(bs, bs.rows[0]).how === 'need');
    w.eval('_cs.fee=4500'); w.alApply(); await sleep(20);
    t('넣은 줄 — 단가 160 · 줄 물류비·메모가 calc 에', ev('_lines.length') === 1 && near(ev('_lines[0].unitPrice'), 160) && near(ev('_lines[0].calc.lgFee'), 4090.909) && ev('_lines[0].calc.buyMemo') === '도매몰 139원');
    w.alOpen(); await sleep(60); fire($('#alQ'), '이벤트'); await sleep(160); w.alPick(0); w.__confirms.length = 0; w.__confirmNo = true; w.alModeMatch(0);
    t('계산이 든 줄이 있는 견적서에서는 갈래를 바꾸기 전에 묻는다(취소하면 그대로)', w.__confirms.some(x => /물류비 갈래를/.test(x)) && ev('_cs.mode') === 'parcel');
    w.__confirmNo = false; w.alModeMatch(0);
    t('바꾸기 → 센터배송', ev('_cs.mode') === 'center');
    w.alClear(); w.alClose();

    /* ── 7-3. 묶음의 품명 옆 🔍 = 기존 「상품 찾기」 창 (2026-11-18 「기존처럼 검색도 가능하게」) ── */
    w.newDoc(); await sleep(30); w.alOpen(); await sleep(60); w.alNewBlock();
    t('묶음 품명 옆에 🔍 단추', !!$('#alB0 .al-bh button[onclick^="alProd("]'));
    A().blocks[0].prodNm = '플래터'; w.alProd(0); await sleep(30);
    t('🔍 → 기존 상품 찾기 창이 이 창 위에 뜬다 · 찾는 글자 = 묶음의 품명', $('#prodPop').classList.contains('on') && $('#prodPop').style.zIndex === '1100' && $('#prodQ').value === '플래터' && $('#alPop').classList.contains('on'));
    t('기존 검색 규칙 그대로(찾은 것이 맨 앞 · 그 뒤로 이웃 코드 — 장부식)', $$('#prodBody tr.pick').length >= 1 && /9904012907/.test($$('#prodBody tr.pick')[0].textContent) && /플래터 용기/.test($$('#prodBody tr.pick')[0].textContent), $('#prodBody').textContent);
    type($('#prodQ'), 'EXT-PLT'); await sleep(200);
    t('매칭코드로도 찾는다(기존 그대로)', $$('#prodBody tr.pick').length >= 1 && /9904012907/.test($('#prodBody').textContent));
    const before2 = JSON.stringify(ev('_lines'));
    w.prodPick(0); await sleep(10);
    const bf = A().blocks[0];
    t('★고르면 묶음에 들어온다(코드·품명·규격·입수량·매입가) — 견적서 줄은 안 건드린다', bf.prodCd === '9904012907' && bf.prodNm === '플래터 용기' && bf.box === 400 && bf.rows[0].buy === 90 && bf.rows[0].prevSell === 108 && JSON.stringify(ev('_lines')) === before2 && !$('#prodPop').classList.contains('on'), [bf.prodCd, bf.prodNm]);
    t('직접 입력 묶음이 상품마스터 묶음으로 표시', bf.src === 'p' && /상품마스터/.test($('#alB0 .al-src').textContent));
    bf.rows[0].buy = 77; w.alProd(0); await sleep(30); type($('#prodQ'), '핫도그'); await sleep(200); w.prodPick(0);
    t('다시 고르면 품목은 바뀌고 이미 적은 배송 단가는 그대로', bf.prodCd === '4003071185' && bf.box === 1000 && bf.rows[0].buy === 77);
    w.alProd(0); await sleep(30); $('#prodPop').classList.remove('on');   /* 고르지 않고 닫음 */
    w.alClose(); w.prodOpen(0); await sleep(30); type($('#prodQ'), '플래터'); await sleep(200); w.prodPick(0);
    t('★표의 🔍 는 종전대로 견적서 줄로(창을 닫았다 열어도 묶음으로 새지 않는다)', ev('_lines[0].prodCd') === '9904012907' && ev('_lines[0].prodNm') === '플래터 용기' && bf.prodCd === '4003071185' && $('#prodPop').style.zIndex === '');
    w.alOpen(); await sleep(30); w.alClear(); w.alClose();

    /* ── 7-4. 품명 칸에 직접 쳐도 찾는다 (2026-11-18 「품명 직접 입력해도 검색되게 해줘」) ── */
    const key = (el, k) => { const e = new w.KeyboardEvent('keydown', { key:k, bubbles:true, cancelable:true }); w.__el = el; w.__ev = e; w.eval('(function(event){' + el.getAttribute('onkeydown') + '}).call(window.__el, window.__ev)'); return e; };
    w.newDoc(); await sleep(30); w.alOpen(); await sleep(60); w.alNewBlock();
    let nmI = $('#alB0 .al-in.nm'); nmI.focus(); type(nmI, '성탄절'); await sleep(220);
    t('품명 칸에 치면 바로 밑에 찾은 품목이 뜬다(지난 견적)', $('#alSug').classList.contains('on') && $$('#alSug .sr').length === 1 && /견적 2회/.test($('#alSug').textContent) && /MOQ 50,000 → 19\.50 외 1줄/.test($('#alSug').textContent), $('#alSug').textContent);
    t('친 글자는 그대로 품명에 들어가 있다(고르지 않아도 직접 입력)', A().blocks[0].prodNm === '성탄절' && A().blocks.length === 1);
    w.alSugPick(0); await sleep(10);
    let bq = A().blocks[0];
    t('★고르면 «이 묶음»이 지난 견적 값으로 — MOQ 2줄·단가·동판(새 묶음을 만들지 않는다)', A().blocks.length === 1 && bq.src === 'h' && bq.prodNm === '(아벡쉐리)성탄절U 봉투' && bq.rows.length === 2 && bq.rows[1].buy === 18.5 && bq.extras[0].use === 'cost' && !$('#alSug').classList.contains('on'));
    t('채운 뒤 계산·그때 단가도 그대로', near(n$('#alS0_0'), 36.5) && $$('#alB0 .al-src select option').length === 2);
    nmI = $('#alB0 .al-in.nm'); nmI.focus(); type(nmI, '핫도그'); await sleep(220);
    t('상품마스터도 같이 찾는다', $$('#alSug .sr').length === 1 && /상품/.test($('#alSug .sr').textContent) && /4003071185/.test($('#alSug').textContent) && /매입가 48\.00/.test($('#alSug').textContent), $('#alSug').textContent);
    const e1 = key(nmI, 'ArrowDown');
    t('↓ 로 고른다', $$('#alSug .sr.cur').length === 1 && e1.defaultPrevented);
    key(nmI, 'Enter'); await sleep(10); bq = A().blocks[0];
    t('Enter → 상품 값이 들어온다(이미 있던 배송 단가는 그대로)', bq.prodCd === '4003071185' && bq.prodNm === '핫도그 트레이' && bq.box === 1000 && bq.rows[0].buy === 19.5 && !$('#alSug').classList.contains('on'), [bq.prodCd, bq.rows[0].buy]);
    nmI = $('#alB0 .al-in.nm'); nmI.focus(); type(nmI, '플래터'); await sleep(220);
    const e2 = key(nmI, 'Escape');
    t('ESC = 목록만 닫는다(창은 그대로 · 친 글자도 그대로)', !$('#alSug').classList.contains('on') && $('#alPop').classList.contains('on') && e2.defaultPrevented && A().blocks[0].prodNm === '플래터');
    type(nmI, 'EXT-PLT'); await sleep(220);
    t('매칭코드로도 찾는다', $$('#alSug .sr').length === 1 && /9904012907/.test($('#alSug').textContent));
    type(nmI, '중지'); await sleep(220);
    t('거래중지 상품은 안 뜬다 · 맞는 것이 없으면 목록도 없다', !$('#alSug').classList.contains('on'));
    type(nmI, '세상에 없는 품목'); await sleep(220);
    t('없는 품명 = 그대로 직접 입력', !$('#alSug').classList.contains('on') && A().blocks[0].prodNm === '세상에 없는 품목');
    type(nmI, '이벤트'); await sleep(220); w.eval("(function(){" + nmI.getAttribute('onblur') + "}).call(window.__el)"); await sleep(220);
    t('칸을 떠나면 닫힌다', !$('#alSug').classList.contains('on'));
    type(nmI, '이벤트'); await sleep(220); w.alClose();
    t('창을 닫으면 목록도 닫힌다', !$('#alSug').classList.contains('on'));
    w.alOpen(); await sleep(30); w.alClear();

    /* ── 7-5. 규격 칸에 직접 쳐도 찾는다 (2026-11-18 「규격도 직접 입력하면 검색되게 해줘」) ── */
    w.alOpen(); await sleep(30); w.alNewBlock();
    let spI = $$('#alB0 .al-bh input.al-in')[1]; spI.focus();
    t('규격 칸에도 찾기가 걸려 있다', /alSug\(0, this\)/.test(spI.getAttribute('oninput')) && !!spI.getAttribute('onkeydown') && !!spI.getAttribute('onblur'));
    type(spI, '300*200'); await sleep(220);
    t('규격을 치면 그 규격의 품목이 뜬다', $('#alSug').classList.contains('on') && $$('#alSug .sr').length === 1 && /이벤트 박스/.test($('#alSug').textContent), $('#alSug').textContent);
    t('친 글자는 규격에 그대로(고르지 않으면 직접 입력)', A().blocks[0].spec === '300*200' && A().blocks[0].src === 'n' && A().blocks[0].rows.length === 1 && !A().blocks[0].box, [A().blocks[0].spec, A().blocks[0].src]);
    key(spI, 'ArrowDown'); key(spI, 'Enter'); await sleep(10);
    t('★고르면 이 묶음이 채워진다(품명·규격·입수량·목형비)', A().blocks.length === 1 && A().blocks[0].prodNm === '이벤트 박스' && A().blocks[0].spec === '300*200*100' && A().blocks[0].box === 300 && A().blocks[0].extras[1].use === 'sub');
    spI = $$('#alB0 .al-bh input.al-in')[1]; spI.focus(); type(spI, '구판'); await sleep(220);
    t('★같은 품명의 견적이 둘이면 <친 규격이 든 견적>이 뜬다(최근 것이 아니라 10-01 구판)', $$('#alSug .sr').length === 1 && /150\*200 구판/.test($('#alSug').textContent) && /MOQ 30,000 → 21\.00/.test($('#alSug').textContent) && /10-01/.test($('#alSug').textContent), $('#alSug').textContent);
    w.alSugPick(0); await sleep(10);
    t('그 견적 값으로 채워지고 출처 고르기도 그 견적을 가리킨다', A().blocks[0].spec === '150*200 구판' && A().blocks[0].rows.length === 1 && A().blocks[0].rows[0].moqQty === 30000 && A().blocks[0].setIdx === 1 && $('#alB0 .al-src select').value === '1');
    spI = $$('#alB0 .al-bh input.al-in')[1]; spI.focus(); type(spI, '180*60'); await sleep(220);
    t('상품마스터의 규격으로도 찾는다', $$('#alSug .sr').length === 1 && /핫도그 트레이/.test($('#alSug').textContent));
    const e3 = key(spI, 'Escape');
    t('ESC = 목록만 닫고 친 규격은 그대로', !$('#alSug').classList.contains('on') && e3.defaultPrevented && A().blocks[0].spec === '180*60' && A().blocks[0].prodNm === '(아벡쉐리)성탄절U  봉투'.replace(/\s+/g, ' '));
    w.alClear(); w.alClose();

    /* ── 7-6. 제조사 칸에 직접 쳐도 찾는다 (2026-11-18 「제조사도 직접 입력하면 검색되게 해줘」) ── */
    w.alOpen(); await sleep(30); w.alNewBlock();
    let mkI = $$('#alB0 .al-bh input.al-in')[2]; mkI.focus();
    t('제조사 칸에도 찾기가 걸려 있다', /alSet\(0,'makerNm',this\.value\); alSug\(0, this\)/.test(mkI.getAttribute('oninput')) && !!mkI.getAttribute('onkeydown') && !!mkI.getAttribute('onblur'));
    type(mkI, '선피앤피'); await sleep(220);
    t('제조사를 치면 그 제조사의 품목이 뜬다(목록 줄에 제조사 표시)', $('#alSug').classList.contains('on') && $$('#alSug .sr').length === 1 && /성탄절U/.test($('#alSug').textContent) && $('#alSug .sr .mk') && $('#alSug .sr .mk').textContent === '선피앤피', $('#alSug').textContent);
    t('친 글자는 제조사에 그대로(고르지 않으면 직접 입력)', A().blocks[0].makerNm === '선피앤피' && A().blocks[0].src === 'n');
    type(mkI, '선피앤피 구판'); await sleep(220);
    t('제조사 + 다른 낱말 = 모두 든 견적(10-01 구판)', $$('#alSug .sr').length === 1 && /150\*200 구판/.test($('#alSug').textContent));
    type(mkI, '선피앤피'); await sleep(220); key(mkI, 'ArrowDown'); key(mkI, 'Enter'); await sleep(10);
    t('★고르면 이 묶음이 채워진다(품명·규격·제조사·MOQ 2줄)', A().blocks.length === 1 && A().blocks[0].prodNm === '(아벡쉐리)성탄절U 봉투' && A().blocks[0].makerNm === '선피앤피' && A().blocks[0].rows.length === 2 && A().blocks[0].src === 'h');
    mkI = $$('#alB0 .al-bh input.al-in')[2]; mkI.focus(); type(mkI, '대상'); await sleep(220);
    t('상품마스터의 제조사로도 찾는다', $$('#alSug .sr').length === 1 && /핫도그 트레이/.test($('#alSug').textContent) && /상품/.test($('#alSug .sr').textContent));
    const e4 = key(mkI, 'Escape');
    t('ESC = 목록만 닫고 친 제조사는 그대로', !$('#alSug').classList.contains('on') && e4.defaultPrevented && A().blocks[0].makerNm === '대상' && A().blocks[0].prodNm === '(아벡쉐리)성탄절U 봉투');
    w.alClear(); w.alClose();

    /* ── 7-7. 상품코드 칸에 직접 쳐도 찾는다 (2026-11-18 「상품코드도 직접 입력하면 검색되게 해줘」) ── */
    w.alOpen(); await sleep(30); w.alNewBlock(); A().blocks[0].prodNm = '';
    let cdI = $('#alB0 .al-bh input[data-sg=cd]'); cdI.focus();
    t('상품코드 칸에도 찾기가 걸려 있다(떠날 때 대조는 그대로)', !!cdI && /alSug\(0, this\)/.test(cdI.getAttribute('oninput')) && /alCode\(0, this\.value\)/.test(cdI.getAttribute('onchange')) && !!cdI.getAttribute('onkeydown'));
    type(cdI, '30'); await sleep(220);
    const rowsCd = $$('#alSug .sr').map(x => x.textContent);
    t('★코드를 치면 상품이 뜬다 — 코드가 그 글자로 시작하는 것(3004) 먼저, 들어 있는 것(4003071185 · A3009)은 코드순으로 뒤', $('#alSug').classList.contains('on') && rowsCd.length === 3 && /3004/.test(rowsCd[0]) && /4003071185/.test(rowsCd[1]) && /A3009/.test(rowsCd[2]), rowsCd);
    t('★규격·문서번호에 그 숫자가 든 지난 견적(이벤트 박스 300*200*100)은 코드 칸에서는 안 뜬다', !/이벤트 박스/.test($('#alSug').textContent) && !$('#alSug .tg.h'));
    type(cdI, 'EXT-PLT'); await sleep(220);
    t('매칭코드로도 찾는다', $$('#alSug .sr').length === 1 && /9904012907/.test($('#alSug').textContent));
    type(cdI, '4003'); await sleep(220); w.__alerts.length = 0;
    key(cdI, 'ArrowDown'); key(cdI, 'Enter'); await sleep(10);
    run(cdI, 'onchange'); await sleep(10);   /* 고른 직후 칸에 남은 글자(4003)로 change 가 뒤따라 오는 경우 */
    let bc = A().blocks[0];
    t('★↓ Enter 로 고르면 묶음이 채워진다 — 치다 만 글자(4003)를 «없는 코드»로 되물리지 않는다', bc.prodCd === '4003071185' && bc.prodNm === '핫도그 트레이' && bc.box === 1000 && bc.rows[0].buy === 48 && w.__alerts.length === 0 && $('#alB0 .al-bh input[data-sg=cd]').value === '4003071185', [bc.prodCd, w.__alerts]);
    await sleep(450);
    cdI = $('#alB0 .al-bh input[data-sg=cd]'); cdI.value = '9904012907'; run(cdI, 'onchange'); await sleep(10);
    t('목록 없이 코드를 다 적고 떠나도 종전대로 가져온다', A().blocks[0].prodCd === '9904012907' && A().blocks[0].prodNm === '플래터 용기');
    cdI = $('#alB0 .al-bh input[data-sg=cd]'); cdI.value = 'NOPE'; w.__alerts.length = 0; run(cdI, 'onchange'); await sleep(10);
    t('마스터에 없는 코드는 종전대로 안 받는다', A().blocks[0].prodCd === '' && w.__alerts.some(x => /상품마스터에 없는 코드/.test(x)));
    cdI = $('#alB0 .al-bh input[data-sg=cd]'); cdI.focus(); type(cdI, '핫도그'); await sleep(220);
    t('코드 칸에 품명을 쳐도 상품은 찾는다', $$('#alSug .sr').length === 1 && /4003071185/.test($('#alSug').textContent));
    const e5 = key(cdI, 'Escape');
    t('ESC = 목록만 닫는다', !$('#alSug').classList.contains('on') && e5.defaultPrevented && $('#alPop').classList.contains('on'));
    const nm2 = $('#alB0 .al-in.nm'); nm2.focus(); type(nm2, '300'); await sleep(220);
    t('품명 칸의 차례는 그대로(지난 견적 먼저)', /견적 1회/.test($$('#alSug .sr')[0].textContent) && /이벤트 박스/.test($$('#alSug .sr')[0].textContent));
    w.alClear(); w.alClose();

    /* ── 7-8. 단위 칸 = 단위 목록 (2026-11-18 「단위도 직접 입력하면 검색되게 해줘」) ── */
    w.alOpen(); await sleep(30); fire($('#alQ'), '성탄절'); await sleep(160); w.alRecvSet(''); w.alPick(0);
    let unI = $('#alB0 .al-bh input[data-sg=unit]'); unI.focus();
    t('단위 칸에도 찾기가 걸려 있다', !!unI && /alSug\(0, this\)/.test(unI.getAttribute('oninput')) && /alSug\(0, this, true\)/.test(unI.getAttribute('onfocus')) && !!unI.getAttribute('onkeydown'));
    run(unI, 'onfocus'); await sleep(220);
    const us = $$('#alSug .sr').map(x => x.querySelector('.nm').textContent);
    t('칸을 누르면 단위 목록 전부 — 지난 견적에서 쓴 단위(ea)가 맨 앞 · 쓴 횟수', $('#alSug').classList.contains('on') && us[0] === 'ea' && us.indexOf('box') > 0 && us.indexOf('롤') > 0 && /지난 견적 \d+줄/.test($$('#alSug .sr')[0].textContent) && !$('#alSug .tg'), us);
    type(unI, 'bo'); await sleep(220);
    t('치면 그 글자가 든 단위만', $$('#alSug .sr').length === 1 && $('#alSug .sr .nm').textContent === 'box' && A().blocks[0].unit === 'bo');
    const snapU = JSON.stringify([A().blocks[0].prodNm, A().blocks[0].spec, A().blocks[0].rows]);
    key(unI, 'ArrowDown'); key(unI, 'Enter'); await sleep(10);
    t('★고르면 단위만 바뀐다(품명·MOQ 줄은 그대로)', A().blocks[0].unit === 'box' && $('#alB0 .al-bh input[data-sg=unit]').value === 'box' && JSON.stringify([A().blocks[0].prodNm, A().blocks[0].spec, A().blocks[0].rows]) === snapU && !$('#alSug').classList.contains('on'));
    unI = $('#alB0 .al-bh input[data-sg=unit]'); unI.focus(); type(unI, '팩'); await sleep(220);
    t('목록에 없는 단위는 그대로 적는다', !$('#alSug').classList.contains('on') && A().blocks[0].unit === '팩');
    type(unI, ''); await sleep(220);
    t('지우면 목록 전부', $$('#alSug .sr').length >= 10);
    const e6 = key(unI, 'Escape');
    t('ESC = 목록만 닫는다', !$('#alSug').classList.contains('on') && e6.defaultPrevented && $('#alPop').classList.contains('on'));
    type(unI, 'set'); await sleep(220); w.alSugPick(0); w.alApply(); await sleep(20);
    t('넣은 줄의 단위 = 고른 단위(↳ 줄도)', ev('_lines.length') >= 2 && ev('_lines[_lines.length-1].unit') === 'set' && ev('_lines[_lines.length-2].unit') === 'set');

    /* ── 8. 빈 견적서 · 잠금 · 서버 반영 전 ── */
    w.newDoc(); await sleep(30);
    w.alOpen(); await sleep(60); fire($('#alQ'), '이벤트'); await sleep(160); w.alRecvSet(''); w.alPick(0); w.alApply(); await sleep(20);
    t('빈 줄뿐인 새 견적서 = 빈 줄 자리에(빈 줄이 위에 안 남는다)', ev('_lines.length') === 1 && ev('_lines[0].prodNm') === '이벤트 박스');
    w.alOpen(); await sleep(30); w.alNewBlock(); w.__alerts.length = 0; A().blocks[0].prodNm = ''; w.alApply();
    t('품명 없는 묶음만 있으면 넣지 않는다', w.__alerts.some(x => /넣을 품목이 없습니다/.test(x)) && ev('_lines.length') === 1);
    A().blocks[0].prodNm = '단가 없는 품목'; w.__confirms.length = 0; w.__confirmNo = true; w.alApply();
    t('판매적용단가가 빈 줄은 한 번 묻는다(취소하면 안 넣는다)', w.__confirms.some(x => /판매적용단가가 비어 있는 줄/.test(x)) && ev('_lines.length') === 1);
    w.__confirmNo = false; w.alApply(); await sleep(10);
    t('그대로 넣기 → 들어간다', ev('_lines.length') === 2 && ev('_lines[1].prodNm') === '단가 없는 품목');
    d.body.classList.add('qlock'); w.__alerts.length = 0; w.alOpen();
    t('잠긴 견적서에서는 열리지 않는다', w.__alerts.some(x => /잠긴 견적서/.test(x)) && !$('#alPop').classList.contains('on'));
    d.body.classList.remove('qlock');
    w.__histFail = true; A().loaded = false; A().items.length = 0; A().sets.length = 0;
    w.alOpen(); await sleep(60); fire($('#alQ'), '핫도그'); await sleep(160);
    t('★이력 주소가 없는 서버(재기동 전)에서도 창은 뜨고 상품 찾기는 된다', $('#alPop').classList.contains('on') && /불러오지 못했습니다/.test($('#alLoad').textContent) && $$('#alHits tr.pick').length === 1, $('#alLoad').textContent);
  } else {
    /* ── 운영 자료 ── */
    const items = H.items, sets = H.sets;
    t('운영 — 이력이 만들어진다', sets.length > 0 && items.length > 0, [sets.length, items.length]);
    t('운영 — 동판비·목형비 줄은 품목이 아니다', !items.some(i => /^(동판비|목형비)/.test(i.prodNm)), items.filter(i => /^(동판비|목형비)/.test(i.prodNm)).map(i => i.prodNm));
    let rows = 0, hasCalc = 0, repro = 0, cmp = 0, far = [], sameN = 0, sameMiss = [], sellN = 0;
    sets.forEach(s => { const modeBak = w.eval('_cs.mode'), feeBak = w.eval('_cs.fee');
      w.eval('_cs.mode=' + JSON.stringify(s.mode || 'center') + '; _cs.fee=' + (+s.fee || 0));
      const b = w._alDbg.blkFromItem({ key:s.key, sets:[s] }, 0);
      b.rows.forEach((r, k) => { rows++; const o = s.rows[k]; if(!o.hasCalc) return; hasCalc++; if(o.sell) sellN++;
        const keepSame = w._alDbg.rowCalc(b, r); if(keepSame.how === 'same' && o.sell) sameN++; else if(o.sell) sameMiss.push([s.docNo, s.mode, w.eval('_cs.mode')]);
        r.sig = '';   /* 조건표를 비우면 목표 마진율로 다시 낸다 */
        const rc = w._alDbg.rowCalc(b, r);
        if(rc.how === 'need' && o.sell){ cmp++; if(Math.abs(rc.sell - o.sell) <= 0.011) repro++; else far.push([s.docNo, s.prodNm.slice(0, 14), o.sell, rc.sell]); } });
      w.eval('_cs.mode=' + JSON.stringify(modeBak) + '; _cs.fee=' + feeBak); });
    console.log('  운영 자료 : 견적 ' + DOCS.length + '건 · 줄 ' + LINES.length + ' → 품목 ' + items.length + '종(벌 ' + sets.length + ') · MOQ 줄 ' + rows + ' · 계산 든 줄 ' + hasCalc
      + ' · 목표 마진율로 낸 단가가 그때 단가와 같은 줄 ' + repro + '/' + cmp);
    if(far.length) console.log('  (그때 단가를 손으로 고친 줄 예 : ' + far.slice(0, 5).map(x => x.join(' ')).join(' | ') + ')');
    t('운영 — 계산 든 줄이 있다', hasCalc > 0);
    t('운영 — 제출완료·채택 견적만', sets.every(s => s.statGb === 'S' || s.statGb === 'A'), sets.filter(s => s.statGb !== 'S' && s.statGb !== 'A').length);
    t('운영 — ★조건을 안 바꾸면 전 줄이 그때 단가 그대로 (' + sameN + '/' + sellN + ')', sellN > 0 && sameN === sellN, sameMiss.slice(0, 5));
    w.alOpen(); await sleep(80);
    t('운영 — 창이 열리고 최근 품목이 보인다', $$('#alHits tr.pick').length > 0, $('#alLoad').textContent);
    w.alRecvSet(''); const nAll = $$('#alHits tr.pick').length; w.alPick(0); w.alPick(1);
    t('운영 — 두 품목을 담아 넣는다', A().blocks.length === 2 && nAll >= 2);
    const want = A().blocks.reduce((a, b) => a + b.rows.length, 0);
    w.alApply(); await sleep(20);
    t('운영 — 견적서 줄이 생긴다', ev('_lines.length') === want, [ev('_lines.length'), want]);
    const P = w.payload().docs[0];
    t('운영 — 저장 본문이 만들어진다(calcs 수 = 품목 줄 수)', JSON.parse(P.calcJson).calcs.length === want && P.lines.length >= want);
  }

  console.log((bad ? '✗ ' : '✓ ') + 'sim_quoteAutoLink' + (REAL ? '(운영 자료)' : '') + ' : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
function n$(sel){ const e = d.querySelector(sel); return e ? Number(String(e.value).replace(/,/g, '')) : NaN; }
