/* 재고 일괄조정 — 목록 ↔ 조정 이력 높이 막대 시뮬 (2026-11-18 「막대 표시로 줄이고 늘리고 기능」)
   prod/stockAdj.jsp 를 통째로 jsdom 에 올린다. jsdom 은 배치(layout)가 없어 높이를 «본떠» 준다 :
     화면에 남는 높이 TOTAL 을 목록(#adjGrid)과 이력(#hisWrap)이 나눠 쓴다 — 이력 = inline height(없으면 기본 200), 목록 = TOTAL − 이력.
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_stockAdjGrip.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/prod/stockAdj.jsp'), 'utf8').replace(/\r\n/g, '\n');
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const html = src.replace(/<%@[\s\S]*?%>/g, '').replace(/<%--[\s\S]*?--%>/g, '').replace(/\$\{pageContext\.request\.contextPath\}/g, '')
  .replace(/<script[^>]*src="[^"]*"><\/script>/g, '').replace(/<link [^>]*>/g, '');
const DEF = 200;                                  /* 이력 표의 CSS 기본 높이(본뜬 값) */
async function open(o){
  o = o || {};
  const dom = new JSDOM(html, { url: 'http://localhost:9071/prod/stockAdj.do', runScripts: 'dangerously', pretendToBeVisual: true, beforeParse(w){
    w.__total = o.total || 600; w.__hisCalls = 0;
    if (o.saved) w.localStorage.setItem('konetAdjHisH', String(o.saved));
    w.fetch = function(url){ if (/stockAdjHisList/.test(url)) w.__hisCalls++; const v = /whList/.test(url) ? { data: [ { whCd: 'WH1', whNm: '제1창고', defaultYn: 'Y' } ] } : /stockAdjReqList/.test(url) ? { result: 'OK', admin: 'Y', me: 'admin', data: [] } : { data: [] };
      return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(v) }); };
    w._alertBox = function(){}; w._confirmBox = function(o2){ if (o2.onOk) o2.onOk(); }; w._toast = function(){};
    w.ResizeObserver = function(cb){ w.__ro = cb; this.observe = function(){}; };
    const hisH = () => { const e = w.document.getElementById('hisWrap'); if (w.document.getElementById('histBox').classList.contains('off')) return 0; const v = parseInt(e.style.getPropertyValue('height'), 10); return v > 0 ? v : DEF; };
    Object.defineProperty(w.HTMLElement.prototype, 'offsetHeight', { configurable: true, get(){ return this.id === 'hisWrap' ? hisH() : this.id === 'adjGrid' ? Math.max(0, w.__total - hisH()) : 0; } });
    Object.defineProperty(w.HTMLElement.prototype, 'clientHeight', { configurable: true, get(){ return this.id === 'adjGrid' ? Math.max(0, w.__total - hisH()) : this.classList && this.classList.contains('wrap') ? 900 : 0; } });
    Object.defineProperty(w.HTMLElement.prototype, 'scrollHeight', { configurable: true, get(){ return this.classList && this.classList.contains('wrap') ? 900 + Math.max(0, hisH() - w.__total) : 0; } });
  } });
  await sleep(60);
  return dom.window;
}
const H = (w) => w.document.getElementById('hisWrap').offsetHeight, G = (w) => w.document.getElementById('adjGrid').clientHeight;
const saved = (w) => w.localStorage.getItem('konetAdjHisH');
const ev = (w, el, type, y, tgt) => { const e = new w.MouseEvent(type, { bubbles: true, cancelable: true, button: 0, clientY: y || 0 }); (tgt || el).dispatchEvent(e); };
const btn = (w, d) => w.document.querySelector('#adjGrip b[data-d="' + d + '"]');

(async () => {
  let w = await open(), d = w.document, bar = d.getElementById('adjGrip');
  t('막대가 목록 표 바로 뒤(사유 줄 앞)에 있다', bar && bar.previousElementSibling === d.getElementById('adjGrid') && bar.nextElementSibling.classList.contains('foot'));
  t('단추 둘 — ▲ 줄이기 · ▼ 늘리기', btn(w, -1) && /줄이기/.test(btn(w, -1).textContent) && btn(w, 1) && /늘리기/.test(btn(w, 1).textContent));
  t('처음엔 손대지 않는다(이력 기본 200 · 목록 400 · 저장 없음)', H(w) === 200 && G(w) === 400 && !saved(w) && !d.getElementById('hisWrap').getAttribute('style'));
  btn(w, 1).click();
  t('[▼ 늘리기] — 목록 +120(이력 200 → 80) · 저장', H(w) === 80 && G(w) === 520 && saved(w) === '80', H(w) + '/' + saved(w));
  btn(w, 1).click();
  t('한 번 더 — 이력은 60 아래로 안 줄어든다', H(w) === 60 && saved(w) === '60', H(w));
  btn(w, -1).click(); btn(w, -1).click();
  t('[▲ 줄이기] 두 번 — 이력 60 → 300 · 목록 300', H(w) === 300 && G(w) === 300 && saved(w) === '300', H(w));
  btn(w, -1).click(); btn(w, -1).click();
  t('★목록은 110 아래로 안 눌린다(이력 490 에서 멈춤)', G(w) === 110 && H(w) === 490 && saved(w) === '490', G(w) + '/' + H(w));
  const st = d.getElementById('hisWrap').style;
  t('높이는 !important · min/max 를 푼다', st.getPropertyPriority('height') === 'important' && /^0(px)?$/.test(st.getPropertyValue('min-height')) && st.getPropertyValue('max-height') === 'none');
  /* 끌기 */
  ev(w, bar, 'mousedown', 300); ev(w, d, 'mousemove', 400, d);
  t('아래로 100 끌면 이력 −100(490 → 390) · 끄는 중엔 아직 저장 안 함', H(w) === 390 && saved(w) === '490' && bar.classList.contains('on'), H(w) + '/' + saved(w));
  ev(w, d, 'mouseup', 400, d);
  t('손을 떼면 저장(390) · 표시 해제', saved(w) === '390' && !bar.classList.contains('on'));
  ev(w, bar, 'mousedown', 300); ev(w, d, 'mousemove', 150, d); ev(w, d, 'mouseup', 150, d);
  t('위로 150 끌면 목록이 준다(이력 390 → 490 에서 멈춤 — 목록 최소)', H(w) === 490 && G(w) === 110 && saved(w) === '490', H(w));
  ev(w, bar, 'mousedown', 300); ev(w, d, 'mouseup', 300, d);
  t('누르기만 하고 안 움직이면 그대로', H(w) === 490 && saved(w) === '490');
  /* 다른 까닭으로 목록이 눌리면(승인 요청 상자가 나타남) 다시 맞춘다 */
  w.__total = 500; w.__ro(); await sleep(20);
  t('★화면에 남는 높이가 줄면(600 → 500) 고른 높이를 넘친 만큼 줄여 보여 준다(목록 110 유지 · 저장값은 그대로)', G(w) === 110 && H(w) === 390 && saved(w) === '490', G(w) + '/' + H(w) + '/' + saved(w));
  w.__total = 600; w.__ro(); await sleep(20);
  t('다시 넓어지면 저장한 높이로 돌아온다', H(w) === 490);
  /* 더블클릭 */
  ev(w, bar, 'dblclick', 0);
  t('더블클릭 — 처음 높이로(inline 지움 · 저장 지움)', H(w) === 200 && !saved(w) && !st.getPropertyValue('height') && !st.getPropertyValue('max-height'), H(w) + '/' + saved(w));
  /* 이력이 접혀 있을 때 */
  w.hisToggle();
  t('이력을 접으면 목록이 전부', d.getElementById('histBox').classList.contains('off') && G(w) === 600);
  btn(w, 1).click();
  t('접힌 채 [▼ 늘리기] — 아무 일 없다(이미 가장 크다)', d.getElementById('histBox').classList.contains('off') && !saved(w));
  btn(w, -1).click();
  t('접힌 채 [▲ 줄이기] — 이력을 펼친다', !d.getElementById('histBox').classList.contains('off') && H(w) === 200);
  w.hisToggle(); ev(w, bar, 'mousedown', 300); ev(w, d, 'mouseup', 300, d);
  t('접힌 채 막대를 잡아도 이력을 펼친다', !d.getElementById('histBox').classList.contains('off'));
  await sleep(60); w.close();

  /* 저장해 둔 높이로 열기 */
  w = await open({ saved: 120 });
  t('★다음에 들어오면 저장한 높이 그대로(이력 120 · 목록 480)', H(w) === 120 && G(w) === 480, H(w));
  await sleep(60); w.close();
  w = await open({ saved: 900 });
  t('저장값이 화면보다 크면 넘친 만큼 줄여 보여 준다(목록 110 · 저장값 그대로)', G(w) === 110 && H(w) === 490 && saved(w) === '900', G(w) + '/' + H(w));
  await sleep(60); w.close();

  console.log((bad ? '✗' : '✓') + ' sim_stockAdjGrip : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
