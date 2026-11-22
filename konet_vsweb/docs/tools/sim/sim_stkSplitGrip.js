/* 품목별재고현황 [입·출고 나누어보기] 창 — 표마다 높이 막대 시뮬 (2026-11-22)
   logi-oh.js 의 stkSplitGrips 를 꺼내 jsdom 문서에 태운다(jsdom 에는 배치가 없어 보이는 높이는 본떠 준다).
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_stkSplitGrip.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries = [name, path.join(process.env.TEMP || '', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch (e) {} } throw new Error(name + ' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/js/winct/logi-oh.js'), 'utf8');
const jsp = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), 'utf8');
let ok = 0, bad = 0;
function t(name, cond, info){ if (cond) ok++; else { bad++; console.log('✗ ' + name + (info !== undefined ? ' — ' + info : '')); } }
const a = src.indexOf("  var STK_SPK='konetSplitH.'"), b = src.indexOf("  var STK_LEDORD=['입고'", a);
if (a < 0 || b < 0) { console.log('✗ 함수 자리를 못 찾음'); process.exit(1); }
const code = src.slice(a, b);
const BODY = () => '<div id="stkSplitBody">'
  + '<div><b>선택 품목</b></div><div style="border:1px solid #ccc;overflow:auto"><table><tr><td>요약</td></tr></table></div>'
  + '<div class="sp-pend"><b>⏳ 승인 대기</b></div><div style="max-height:16vh;overflow:auto"><table><tr><td>p</td></tr></table></div>'
  + '<div><b>⬇️ 입고내역</b></div><div style="padding:14px">내역이 없습니다.</div>'
  + '<div><b>⬆️ 출고내역</b></div><div style="max-height:calc(58vh - 62px);overflow:auto"><table><tr><td>o</td></tr></table></div>'
  + '<div><b>◇ 기타(반품·조정)</b></div><div style="max-height:16vh;overflow:auto"><table><tr><td>e</td></tr></table></div>'
  + '</div>';
function open(store){
  const dom = new JSDOM('<!doctype html><html><head></head><body>' + BODY() + '</body></html>', { url: 'http://localhost:9071/', runScripts: 'outside-only', pretendToBeVisual: true });
  const w = dom.window;
  if (store) Object.keys(store).forEach(k => w.localStorage.setItem(k, store[k]));
  w.__h = {};   /* 표 상자의 «보이는 높이» 본뜨기 — data-k 로 */
  w.eval('function kzF(){ return window.__kz || 1; } function stkTopBar(){}');
  w.eval(code + '; window.stkSplitGrips = stkSplitGrips;');
  const boxes = () => [...w.document.querySelectorAll('#stkSplitBody > div')].filter(d => d.style.maxHeight && d.querySelector('table'));
  boxes().forEach((bx, i) => { bx.getBoundingClientRect = () => ({ height: w.__h[i] || 0 }); });
  return { w, d: w.document, boxes };
}
const fire = (w, el, type, o) => el.dispatchEvent(new w.MouseEvent(type, Object.assign({ bubbles: true, cancelable: true, button: 0 }, o || {})));

(() => {
  let { w, d, boxes } = open();
  w.__h = { 0: 80, 1: 400, 2: 120 };
  w.stkSplitGrips();
  let bars = [...d.querySelectorAll('#stkSplitBody > .stk-grip')];
  t('막대 3개 — 승인 대기 · 출고내역 · 기타 (요약표·「내역이 없습니다」에는 없다)', bars.length === 3 && bars.map(x => x.getAttribute('data-k')).join(',') === 'pend,out,etc', bars.map(x => x.getAttribute('data-k')).join(','));
  t('막대는 그 표 상자 바로 밑', boxes().every(bx => bx.nextElementSibling && bx.nextElementSibling.classList.contains('stk-grip')));
  t('막대 CSS 한 번 주입 · 단추 [▲ 줄이기][▼ 늘리기]', d.querySelectorAll('#stkGripCss').length === 1 && bars[1].querySelectorAll('b[data-d]').length === 2);
  w.stkSplitGrips();
  t('다시 불러도 막대가 겹쳐 붙지 않는다', d.querySelectorAll('#stkSplitBody > .stk-grip').length === 3);
  const out = boxes()[1], etc = boxes()[2], bOut = bars[1], bEtc = bars[2];
  /* ▼ 늘리기 */
  fire(w, bEtc.querySelector('b[data-d="1"]'), 'click');
  t('★기타 표 [▼ 늘리기] — 보이는 120 + 100 = 220px · 저장 · 「높이 고정」', etc.style.maxHeight === '220px' && w.localStorage.getItem('konetSplitH.etc') === '220' && bEtc.classList.contains('fix'), etc.style.maxHeight + '/' + w.localStorage.getItem('konetSplitH.etc'));
  w.__h[1] = 400; fire(w, bOut.querySelector('b[data-d="-1"]'), 'click');
  t('출고 표 [▲ 줄이기] — 400 − 100 = 300px', out.style.maxHeight === '300px' && w.localStorage.getItem('konetSplitH.out') === '300');
  w.__h[1] = 70; fire(w, bOut.querySelector('b[data-d="-1"]'), 'click');
  t('아래 한계 60px', out.style.maxHeight === '60px', out.style.maxHeight);
  /* 끌기 */
  w.__h[2] = 220;
  fire(w, bEtc, 'mousedown', { clientY: 500 }); fire(w, d, 'mousemove', { clientY: 580 }); fire(w, d, 'mouseup', { clientY: 580 });
  t('★끌기 — 아래로 80px → 300px · 저장', etc.style.maxHeight === '300px' && w.localStorage.getItem('konetSplitH.etc') === '300', etc.style.maxHeight);
  w.__h[2] = 300; fire(w, bEtc, 'mousedown', { clientY: 500 }); fire(w, d, 'mouseup', { clientY: 500 });
  t('안 움직이고 놓으면 그대로(저장값 불변)', etc.style.maxHeight === '300px' && w.localStorage.getItem('konetSplitH.etc') === '300');
  w.__kz = 0.8; w.__h[2] = 240;   /* 화면 240px = CSS 300px */
  fire(w, bEtc, 'mousedown', { clientY: 500 }); fire(w, d, 'mousemove', { clientY: 460 }); fire(w, d, 'mouseup', { clientY: 460 });
  t('글자 배율 0.8 — 화면 40px 위로 = CSS 50px 줄어 250px', etc.style.maxHeight === '250px', etc.style.maxHeight);
  w.__kz = 1;
  /* 더블클릭 = 처음 높이 */
  fire(w, bEtc, 'dblclick');
  t('더블클릭 — 처음 높이(16vh)로 · 저장값 지움 · 「높이 고정」 꺼짐', etc.style.maxHeight === '16vh' && w.localStorage.getItem('konetSplitH.etc') === null && !bEtc.classList.contains('fix'), etc.style.maxHeight);
  fire(w, bEtc.querySelector('b[data-d="1"]'), 'dblclick');
  t('단추 위 더블클릭은 되돌리기가 아니다', etc.style.maxHeight === '16vh');
  /* 다시 열기 — 저장한 높이가 되입혀진다 */
  ({ w, d, boxes } = open({ 'konetSplitH.out': '280', 'konetSplitH.pend': '90' }));
  w.stkSplitGrips();
  bars = [...d.querySelectorAll('#stkSplitBody > .stk-grip')];
  t('★창을 다시 열면 저장한 높이로 — 출고 280px · 승인 대기 90px · 기타는 처음 그대로', boxes()[1].style.maxHeight === '280px' && boxes()[0].style.maxHeight === '90px' && boxes()[2].style.maxHeight === '16vh' && bars[1].classList.contains('fix') && !bars[2].classList.contains('fix'));
  t('JSP — 창을 연 줄 끝에 stkSplitGrips()', jsp.indexOf("classList.add('on'); stkSplitGrips();") >= 0);
  console.log((bad ? '✗ ' : '✓ ') + 'sim_stkSplitGrip : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
