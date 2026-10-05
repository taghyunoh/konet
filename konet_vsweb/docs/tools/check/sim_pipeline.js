/* 진행 현황(pipeline.jsp) 시뮬 — 진짜 JSP 의 본문·스크립트를 jsdom 에 태우고 fetch 를 흉내 낸다 */
const fs = require('fs');
const { JSDOM } = require('C:/Users/user/git/winn/wnn_medcost/docs/tools/sim/node_modules/jsdom');
const src = fs.readFileSync('C:/Users/user/git/konet/konet_vsweb/src/main/webapp/WEB-INF/jsp/main/mangr/pipeline.jsp', 'utf8').replace(/\r\n/g, '\n');
const body = src.slice(src.indexOf('<body>') + 6, src.indexOf('<script>\nvar CTX'));
const js = src.slice(src.indexOf('<script>\nvar CTX') + 8, src.lastIndexOf('</script>')).replace("${pageContext.request.contextPath}", '');

let ok = 0, bad = 0;
function t(name, cond, info) { if (cond) ok++; else { bad++; console.log('✗ ' + name + (info ? ' — ' + info : '')); } }

function make(stat, lists) {
  const dom = new JSDOM('<!doctype html><html><body>' + body + '</body></html>', { runScripts: 'dangerously' });
  const w = dom.window;
  w.__calls = [];
  w.fetch = function (url, opt) {
    w.__calls.push({ url: url, body: opt && opt.body });
    let data;
    if (url.indexOf('pipelineStat') >= 0) data = stat;
    else { const m = /stage=([A-Z]+)/.exec(opt.body || ''); data = { data: (lists && lists[m && m[1]]) || [] }; }
    return Promise.resolve({ ok: true, json: () => Promise.resolve(data) });
  };
  w._alertBox = function (m) { w.__alert = m; };
  // 부모 셸 흉내 — 메뉴 a.mi[data-key] 를 누르면 기록
  w.__menu = [];
  const parentDoc = new JSDOM('<a class="mi" data-key="poReg"></a><a class="mi" data-key="purchase"></a><a class="mi" data-key="salesreg"></a><a class="mi" data-key="quoteMng"></a>').window.document;
  parentDoc.querySelectorAll('a.mi').forEach(a => a.click = () => w.__menu.push(a.getAttribute('data-key')));
  Object.defineProperty(w, 'parent', { value: { document: parentDoc }, configurable: true });
  w.eval(js);
  return w;
}
const tick = () => new Promise(r => setTimeout(r, 15));

(async () => {
  // ── 실측 숫자(2026-10-06 운영 DB) 그대로
  const STAT = { po: { reqCnt: 0, reqQty: 0, poCnt: 4, poRemainQty: 60242, purchCnt: 0, poAllCnt: 4 },
                 quote: [ { statGb: 'A', cnt: 2, amt: 101750, saleCnt: 0, saleAmt: 0 },
                          { statGb: 'S', cnt: 10, amt: 6302550, saleCnt: 0, saleAmt: 0 },
                          { statGb: 'W', cnt: 1, amt: 2090992, saleCnt: 0, saleAmt: 0 } ] };
  let w = make(STAT);
  await tick();
  const d = w.document;
  t('처음 열면 3개월 기간이 들어간다', d.getElementById('fr').value && d.getElementById('to').value);
  t('집계를 한 번 묻는다', w.__calls.filter(c => c.url.indexOf('pipelineStat') >= 0).length === 1);
  const po = d.querySelectorAll('#poSteps .step');
  t('발주 단계 3칸', po.length === 3, po.length);
  t('발주 화살표 2개', d.querySelectorAll('#poSteps .arrow').length === 2);
  t('① 미등록 0 → 회색(zero)', po[0].classList.contains('zero'));
  t('② 발주서 4장 → 주황(wait)', po[1].classList.contains('wait') && /4/.test(po[1].querySelector('.v').textContent));
  t('② 미입고 60,242', /60,242/.test(po[1].querySelector('.x').textContent), po[1].querySelector('.x').textContent);
  t('③ 매입전환 0 → 회색, 발주서 전체 4장', po[2].classList.contains('zero') && /전체 4장/.test(po[2].textContent));
  const qt = d.querySelectorAll('#qtSteps .step');
  t('견적 단계 4칸', qt.length === 4, qt.length);
  t('견적 화살표 3개', d.querySelectorAll('#qtSteps .arrow').length === 3);
  t('① 작성 중 1', /^1/.test(qt[0].querySelector('.v').textContent));
  t('② 제출 10', /^10/.test(qt[1].querySelector('.v').textContent));
  t('③ 채택 2 · 판매 전 2건', /^2/.test(qt[2].querySelector('.v').textContent) && /판매 전 2건/.test(qt[2].textContent), qt[2].textContent);
  t('④ 판매등록 0 → 회색', qt[3].classList.contains('zero'));
  t('거절·보류 칩 둘(0건이어도 보인다)', d.querySelectorAll('#qtSide .chip').length === 2);
  t('오류 줄 비어 있음', !d.getElementById('poErr').textContent && !d.getElementById('qtErr').textContent);

  // ── 단계를 누르면 목록 + 그 단계가 켜짐
  const LISTS = {
    PO: [ { dt: '20260922', prodCd: '1000719149', prodNm: '하이웨스트 베이글박스', spec: '130*100*115mm', partyNm: '선피앤피', qty: 50, qty2: 50, docNo: '0004', note: '미입고' },
          { dt: '20260922', prodCd: '1000764840', prodNm: '칵테일 냅킨', spec: '흰색', partyNm: '', qty: 32, qty2: 32, docNo: '0002', note: '미입고' } ],
    A: [ { quoteDt: '20260928', docNo: 'Konet260928-02', recvNm: '삼성웰스토리', mgrNm: '이성열', amt: 44750, statGb: 'A', submitDt: '', adoptDt: '20260929', saleCnt: 0 },
         { quoteDt: '20260918', docNo: 'Konet260918-01', recvNm: '삼성웰스토리', mgrNm: '최동준', amt: 57000, statGb: 'A', submitDt: '', adoptDt: '20260929', saleCnt: 1, saleAmt: 62700, saleLastDt: '20261003' } ],
    SALE: []
  };
  w = make(STAT, LISTS); await tick();
  const d2 = w.document;
  d2.querySelectorAll('#poSteps .step')[1].click(); await tick();
  t('② 누르면 그 칸이 켜진다', d2.querySelectorAll('#poSteps .step')[1].classList.contains('on'));
  t('목록 제목 「발주 ▸ 발주서 등록」', /발주 ▸ 발주서 등록/.test(d2.getElementById('lTitle').textContent), d2.getElementById('lTitle').textContent);
  t('목록 2줄', d2.querySelectorAll('#lBody tr').length === 2);
  t('거래처 빈 줄은 「미정」', /미정/.test(d2.querySelectorAll('#lBody tr')[1].textContent));
  t('머리 열 = 미입고(잔량)', /미입고\(잔량\)/.test(d2.getElementById('lHead').textContent));
  d2.querySelectorAll('#lBody tr')[0].click();
  t('발주 줄을 누르면 발주서 관리', w.__menu[w.__menu.length - 1] === 'poReg', w.__menu.join(','));

  d2.querySelectorAll('#qtSteps .step')[2].click(); await tick();
  const ar = d2.querySelectorAll('#lBody tr');
  t('채택 목록 2줄', ar.length === 2);
  t('판매 전 줄은 「판매 전」', /판매 전/.test(ar[0].textContent));
  t('판매된 줄은 💰 1건', /💰 1건/.test(ar[1].textContent), ar[1].textContent);
  ar[0].click();
  t('판매 전 채택 줄 → 판매 등록 화면', w.__menu[w.__menu.length - 1] === 'salesreg', w.__menu.join(','));
  ar[1].click();
  t('판매된 채택 줄 → 견적서 관리', w.__menu[w.__menu.length - 1] === 'quoteMng', w.__menu.join(','));
  t('견적 쪽을 누르면 발주 칸은 꺼진다', !d2.querySelector('#poSteps .step.on'));

  d2.querySelectorAll('#qtSteps .step')[3].click(); await tick();
  t('판매등록 0건 안내문', /판매 등록 ▸ \[📄 견적서\]/.test(d2.getElementById('lBody').textContent));

  // ── 빠르게 두 단계를 눌러 옛 응답이 늦게 와도 덮지 않는다
  let w3 = make(STAT, LISTS); await tick();
  let release; const slow = new Promise(r => release = r);
  const orig = w3.fetch;
  w3.fetch = function (url, opt) {
    if (/stage=PO\b/.test(opt.body || '')) return slow.then(() => orig(url, opt));
    return orig(url, opt);
  };
  w3.document.querySelectorAll('#poSteps .step')[1].click();     // PO — 늦게 온다
  w3.document.querySelectorAll('#qtSteps .step')[2].click();     // A — 먼저 온다
  await tick(); release(); await tick(); await tick();
  t('늦게 온 옛 응답이 새 목록을 덮지 않는다', /견적 ▸ 채택/.test(w3.document.getElementById('lTitle').textContent) && /Konet260928-02/.test(w3.document.getElementById('lBody').textContent),
    w3.document.getElementById('lTitle').textContent);

  // ── 한쪽 집계가 실패해도 다른 쪽은 보인다
  let w4 = make({ poErr: 'Invalid object name TBL_PO_REQ', quote: STAT.quote }); await tick();
  t('발주 실패 → 안내문 + 발주 칸 없음', /TBL_PO_REQ/.test(w4.document.getElementById('poErr').textContent) && w4.document.querySelectorAll('#poSteps .step').length === 0);
  t('발주 실패해도 견적 4칸은 그대로', w4.document.querySelectorAll('#qtSteps .step').length === 4);
  let w5 = make({ po: STAT.po, quoteErr: 'Invalid column name QUOTE_SEQ' }); await tick();
  t('견적 실패 → DDL 안내', /20261006_quote_sale_link/.test(w5.document.getElementById('qtErr').textContent));

  // ── 기간 단추
  let w6 = make(STAT); await tick();
  w6.document.querySelectorAll('.bar .btn')[2].click(); await tick();   // 1년
  const fr = w6.document.getElementById('fr').value, to = w6.document.getElementById('to').value;
  t('[1년] = 12개월 범위', (+to.slice(0, 4)) - (+fr.slice(0, 4)) === 1 && to.slice(5) === fr.slice(5), fr + '~' + to);
  t('[1년] 누르면 다시 센다', w6.__calls.filter(c => c.url.indexOf('pipelineStat') >= 0).length === 2);

  // ── 메뉴를 못 찾으면 알림
  let w7 = make(STAT); await tick();
  Object.defineProperty(w7, 'parent', { value: { document: { querySelector: () => null } } });
  w7.eval('openMenu("nothing")');
  t('메뉴를 못 찾으면 ui-message 알림', /메뉴에서 찾지 못했습니다/.test(w7.__alert || ''));

  console.log('진행 현황 시뮬 ' + ok + '/' + (ok + bad));
  process.exit(bad ? 1 : 0);
})();
