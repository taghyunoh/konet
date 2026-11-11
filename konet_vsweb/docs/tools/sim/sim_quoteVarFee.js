/* 견적서 MOQ 변형 줄(↳)의 동판·목형(원가 포함) 적용 시뮬 (2026-11-11)
   quoteEdit.jsp 의 feeSrcOf/calcOf/cxset · quoteMng.jsp 의 marginView 를 떼어 돌린다.
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_quoteVarFee.js */
const fs = require('fs'), path = require('path'), vm = require('vm');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
function load(f){ return fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/' + f), 'utf8').replace(/\r\n/g, '\n'); }
function fnOf(src, name){ const i=src.indexOf('\nfunction '+name+'('); if(i<0) throw new Error('함수 없음 '+name); let d=0, j=src.indexOf('{', i); for(let k=j;k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ d--; if(!d) return src.slice(i+1, k+1); } } throw new Error('끝 없음 '+name); }
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }
const near = (a, b) => Math.abs(a - b) < 1e-6;

/* ── 1. 작성 화면 : calcOf ── */
const E = load('quoteEdit.jsp');
const painted = [];
const ctx = vm.createContext({ painted, console });
vm.runInContext([
  fnOf(E, 'n'), fnOf(E, 'fmt'),
  "var COST={ centers:[{nm:'평/용센터',rate:10.5},{nm:'왜관센터',rate:15.1}], storeFee:0, storePlt:0, storeMon:0, dcRate:11.5 };",
  "var _cs={ mode:'center', center:'평/용센터', fee:0 }; var _lines=[];",
  fnOf(E, 'csRate'), fnOf(E, 'csCents'), fnOf(E, 'lgFeeMan'), fnOf(E, 'storeAuto'), fnOf(E, 'feeSrcOf'), fnOf(E, 'calcOf'),
  "function calcPaint(i){ painted.push(i); } function subPaint(){} function calc(){} function renderLines(){ painted.push('render'); }",
  fnOf(E, 'cxset'),
].join('\n'), ctx);
const mk = (variant, moq, buy, extras) => ({ variant, unitPrice: 32.18, calc: { moqQty: moq, buy, box: 2000, trans: 0, store: 0, storeManual: true, split: 0, pack: 0, target: 20, lgFee: '', extras } });
const fee = (use) => [{ nm: '동판비', qty: 1, price: 160000, use }, { nm: '목형비', qty: 0, price: 0, use: 'off' }];
/* 캡처 그대로 : 1번 품명 50,000 @19.50 (동판비 160,000 원가 포함) + ↳ 100,000 @18.50 / 2번 품명 50,000 @22.50 (동판비 180,000 별도 청구) + ↳ 100,000 @21.50 */
const L = [ mk(false, 50000, 19.5, fee('cost')), mk(true, 100000, 18.5, []), mk(true, 200000, 18.0, []),
            mk(false, 50000, 22.5, [{ nm: '동판비', qty: 1, price: 180000, use: 'sub' }]), mk(true, 100000, 21.5, []) ];
vm.runInContext('_lines=' + JSON.stringify(L), ctx);
const co = (i) => vm.runInContext('calcOf(_lines[' + i + '])', ctx);
t('품명 줄 50,000 : 19.50 + 160,000÷50,000 = 22.70 · 계 45,400', near(co(0).H, 22.7) && near(co(0).I, 45400), co(0).H);
t('★MOQ 변형 100,000 : 18.50 + 160,000÷100,000 = 20.10 · 계 40,200', near(co(1).H, 20.1) && near(co(1).I, 40200), co(1).H);
t('★MOQ 변형 200,000 : 18.00 + 0.8 = 18.80', near(co(2).H, 18.8), co(2).H);
t('exCost·exPer 를 돌려준다(툴팁용)', near(co(1).exCost, 160000) && near(co(1).exPer, 1.6));
t('별도 청구 품명 : 품명 줄 22.50 그대로 · 변형 줄도 21.50 그대로', near(co(3).H, 22.5) && near(co(4).H, 21.5), co(3).H + ' / ' + co(4).H);
t('변형 줄은 «제 윗 품명»만 따른다(앞 품명 것이 안 섞임)', near(co(4).exCost, 0));
/* 윗줄 선택을 적용 안 함으로 → 변형 줄도 빠진다 */
vm.runInContext("_lines[0].calc.extras[0].use='off'", ctx);
t('윗줄을 「적용 안 함」으로 바꾸면 변형 줄도 18.50', near(co(1).H, 18.5) && near(co(0).H, 19.5));
vm.runInContext("_lines[0].calc.extras[0].use='cost'", ctx);
/* 목형비도 원가 포함이면 합쳐서 */
vm.runInContext("_lines[0].calc.extras[1]={nm:'목형비',qty:2,price:120000,use:'cost'}", ctx);
t('동판 160,000 + 목형 240,000 = 400,000 → 100,000 줄 +4.0', near(co(1).H, 22.5), co(1).H);
vm.runInContext("_lines[0].calc.extras[1]={nm:'목형비',qty:0,price:0,use:'off'}", ctx);
/* MOQ 가 빈 변형 줄 = 나눌 수 없으니 안 더한다 */
vm.runInContext('_lines[2].calc.moqQty=0', ctx);
t('변형 줄 MOQ 0 이면 안 더한다(0 나눗셈 없음)', near(co(2).H, 18.0) && near(co(2).exCost, 160000));
/* 필요 판매단가도 따라간다 : I×1.2 ÷ (G×(1−10.5%)) */
t('필요 판매단가 = 40,200×1.2÷(2000×0.895)', near(co(1).need, 40200 * 1.2 / (2000 * 0.895)), co(1).need);
/* cxset — 값(단가)을 고치면 그 품명의 변형 줄도 다시 그린다 · 다음 품명 줄은 안 건드림 */
painted.length = 0; vm.runInContext("cxset(0,0,'price',200000)", ctx);
t('cxset(값) → calcPaint(0)·(1)·(2), 3 은 아님', painted.join(',') === '0,1,2', painted.join(','));
t('고친 값이 변형 줄에 반영 : 18.50 + 2.0', near(co(1).H, 20.5), co(1).H);
painted.length = 0; vm.runInContext("cxset(0,0,'use','sub')", ctx);
t('cxset(use) → renderLines(전부 다시)', painted.join(',') === 'render');
t('별도 청구로 바꾸면 변형 줄에서도 빠진다', near(co(1).H, 18.5));
/* 첫 줄이 variant 로 잘못 서 있어도 죽지 않는다 */
vm.runInContext("_lines=[{variant:true,unitPrice:1,calc:{moqQty:10,buy:1,box:1,extras:[]}}]", ctx);
t('윗줄이 없는 변형 줄 = 품명비 없음(오류 없음)', near(co(0).H, 1));

/* ── 2. 견적서 목록 [🧮 계산조회] : marginView ── */
const { JSDOM } = req('jsdom');
const M = load('quoteMng.jsp');
const dom = new JSDOM('<!DOCTYPE html><html><body><div id="mgWrap" hidden></div></body></html>', { runScripts: 'outside-only' });
const w = dom.window;
const cj = { v: 1, set: { mode: 'direct', dcRate: 11.5 }, genRows: [],
  calcs: [ { variant: false, moqQty: 50000, buy: 19.5, box: 2000, storeVal: 0, extras: [{ nm: '동판비', qty: 1, price: 160000, use: 'cost' }] },
           { variant: true, moqQty: 100000, buy: 18.5, box: 2000, storeVal: 0, extras: [] } ] };
const lines = [ { rowNo: 1, prodNm: '성탄절U 봉투', spec: '150*150', unitPrice: 32.18 }, { rowNo: 2, prodNm: '성탄절U 봉투', spec: '150*150', unitPrice: 32.18 } ];
w.eval([
  fnOf(M, 'esc'), fnOf(M, 'n'), fnOf(M, 'fmt'), fnOf(M, 'd10'),
  "var _mgSeq=null, _ls=[{quoteSeq:9, docNo:'Konet261111-01', quoteDt:'20261111'}]; var __alerts=[]; function _alertBox(m){ __alerts.push(m); }",
  "var __mst=" + JSON.stringify({ mst: { calcJson: JSON.stringify(cj) } }) + ", __dtl=" + JSON.stringify({ data: lines }) + ";",
  "function post(url){ return Promise.resolve({ json:function(){ return url.indexOf('quoteMst')>=0 ? __mst : __dtl; } }); }",
  fnOf(M, 'mgRate'), fnOf(M, 'mgCents'), fnOf(M, 'mgShort'), fnOf(M, 'marginView'),
].join('\n'));
(async () => {
  w.marginView(0); await new Promise(r => setTimeout(r, 30));
  const trs = [...w.document.querySelectorAll('#mgWrap tbody tr')];
  const cell = (r, k) => trs[r] && trs[r].children[k] ? trs[r].children[k].textContent : '';
  t('계산조회 줄 = 품명 줄 + 변형 줄(+ 합계)', trs.length >= 2, trs.length);
  t('계산조회 품명 줄 구매(계산) 22.7 · 계 45,400', cell(0, 4) === '22.7' && cell(0, 5) === '45,400', cell(0, 4) + ' / ' + cell(0, 5));
  t('★계산조회 변형 줄 구매(계산) 20.1 · 계 40,200', cell(1, 4) === '20.1' && cell(1, 5) === '40,200', cell(1, 4) + ' / ' + cell(1, 5));
  const last = trs[1] ? trs[1].children[trs[1].children.length - 1].textContent : '';
  t('변형 줄 품명비 칸 = 「↑ 윗줄 원가 포함 160,000 ÷ 100,000」', last.indexOf('윗줄 원가 포함 160,000') >= 0 && last.indexOf('100,000') > 0, last);
  t('머리글 칸 수 = 자료 줄 칸 수', w.document.querySelectorAll('#mgWrap thead th').length === trs[0].children.length, w.document.querySelectorAll('#mgWrap thead th').length + ' vs ' + trs[0].children.length);
  console.log((bad ? '✗ ' : '✓ ') + 'sim_quoteVarFee : 통과 ' + ok + ' · 실패 ' + bad);
})();
