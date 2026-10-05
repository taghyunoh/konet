/* 판매 등록 [📄 견적서] 시뮬 — salesReg.jsp 의 「견적서에서 가져오기」 블록을 그대로 꺼내 돌린다 */
const fs = require('fs');
const { JSDOM } = require('C:/Users/user/git/winn/wnn_medcost/docs/tools/sim/node_modules/jsdom');
const src = fs.readFileSync('C:/Users/user/git/konet/konet_vsweb/src/main/webapp/WEB-INF/jsp/main/mangr/salesReg.jsp', 'utf8').replace(/\r\n/g, '\n');
const a = src.indexOf('/* ── 견적서에서 가져오기 (2026-10-06');
const b = src.indexOf('function saDlvOpen(){', a);
const block = src.slice(a, b);
// 저장 payload 줄도 꺼내 본다
const saveLine = (src.match(/quoteSeq: _quoteLink \? _quoteLink\.quoteSeq : null, quoteDocNo: _quoteLink \? \(_quoteLink\.docNo\|\|''\) : '',/) || [])[0];

let ok = 0, bad = 0;
function t(name, cond, info) { if (cond) ok++; else { bad++; console.log('✗ ' + name + (info ? ' — ' + info : '')); } }

function make(opts) {
  const dom = new JSDOM('<input id="saVenNm" value=""><input id="qtQ"><div id="saQtPop"></div><table><tbody id="qtBody"></tbody></table><span id="saQtTag"></span>', { runScripts: 'dangerously' });
  const w = dom.window;
  w.eval(`
    var _rows=[], _pShown=0, _cur=null, _quoteLink=null, __alerts=[], __picked=null, __rendered=0;
    var _vendors=${JSON.stringify(opts.vendors || [])};
    var _prods=${JSON.stringify(opts.prods || [])};
    function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
    function fmt(v){ return Math.round(n(v)).toLocaleString(); }
    function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
    function emptyRow(){ return { prodCd:'', prodNm:'', spec:'', packQty:1, boxQty:0, eaQty:0, qty:0, unitPrice:0, amt:0, taxGb:'과세' }; }
    function saNmFor(cd, nm){ return nm; }
    function saCalcRow(o){ o.qty = n(o.boxQty)*(n(o.packQty)||1) + n(o.eaQty); o.amt = o.qty*n(o.unitPrice); }
    function saVenPick(cd){ __picked=cd; var v=_vendors.filter(function(x){return x.vendorCd===cd;})[0]; var e=document.getElementById('saVenNm'); e.value=v.vendorNm; e.dataset.cd=cd; }
    function saRender(){ __rendered++; }
    function swAlert(m){ __alerts.push(m); } function swErr(m){ __alerts.push('ERR:'+m); }
  `);
  w.__resp = opts.resp || {};
  w.post = function (url, body) {
    const key = url.indexOf('quoteAdoptList') >= 0 ? 'list' : 'detail';
    return Promise.resolve({ json: () => Promise.resolve(w.__resp[key] || { data: [] }) });
  };
  w.eval('var post = window.post;');
  w.eval(block);
  if (opts.preRows) w.eval('_rows=' + JSON.stringify(opts.preRows) + ';');
  if (opts.preVen) w.eval('document.getElementById("saVenNm").value="' + opts.preVen.nm + '"; document.getElementById("saVenNm").dataset.cd="' + opts.preVen.cd + '";');
  return w;
}
const tick = () => new Promise(r => setTimeout(r, 15));
const Q = { quoteSeq: 96, docNo: 'Konet260928-02', quoteDt: '20260928', recvNm: '삼성웰스토리', mgrNm: '이성열', amt: 44750, adoptDt: '20260929', itemCnt: 3, saleCnt: 0 };
const ITEMS = { data: [
  { rowNo: 1, prodCd: '9904013324', prodNm: '뚜껑', qty: 3000, unitPrice: 25.5 },
  { rowNo: 2, prodCd: '', prodNm: '동판비', qty: 1, unitPrice: 50000 },          // 상품코드 없음
  { rowNo: 3, prodCd: '9999999999', prodNm: '없는 상품', qty: 10, unitPrice: 100 } // 마스터에 없음
] };
const PRODS = [ { prodSeq: 1, prodCd: '9904013324', prodNm: '160Ø PET 뚜껑', spec: '160', packQty: 600, taxGb: '과세' } ];

(async () => {
  t('저장 payload 에 견적 두 칸이 실린다', !!saveLine);
  // 1) 이름이 정확히 하나 맞으면 거래처를 고른다
  let w = make({ vendors: [ { vendorCd: '00273', vendorNm: '삼성웰스토리' }, { vendorCd: '00900', vendorNm: '삼성웰스토리 오산' } ], prods: PRODS, resp: { list: { data: [Q] }, detail: ITEMS } });
  w.eval('_qtList=' + JSON.stringify([Q]) + '; saQtPick(0);'); await tick();
  t('수신처와 이름이 정확히 같은 거래처 하나 → 저절로 고름', w.eval('__picked') === '00273', w.eval('__picked'));
  const rows = w.eval('_rows');
  t('담긴 줄 = 상품코드가 맞는 1줄 + 빈 줄', rows.length === 2 && rows[0].prodCd === '9904013324', JSON.stringify(rows.map(r => r.prodCd)));
  t('단가 = 견적 단가 25.5', rows[0].unitPrice === 25.5);
  t('수량은 낱개(EA) 3000, 상자 0', rows[0].eaQty === 3000 && rows[0].boxQty === 0 && rows[0].qty === 3000);
  t('입수·과세는 상품마스터에서', rows[0].packQty === 600 && rows[0].taxGb === '과세');
  t('연결이 남는다', JSON.stringify(w.eval('_quoteLink')) === JSON.stringify({ quoteSeq: 96, docNo: 'Konet260928-02' }));
  t('연결 표시가 뜬다', /📄 견적 Konet260928-02/.test(w.document.getElementById('saQtTag').textContent));
  t('새 전표면 ✕ 로 풀 수 있다', /✕/.test(w.document.getElementById('saQtTag').innerHTML));
  const msg = w.eval('__alerts')[0] || '';
  t('알림 = 1개 품목 담음', /1개 품목을 담았습니다/.test(msg), msg.slice(0, 80));
  t('알림 = 못 담은 줄 2건과 이름', /못 담은 줄 2건/.test(msg) && /동판비/.test(msg) && /없는 상품/.test(msg));
  t('팝업이 닫힌다', !w.document.getElementById('saQtPop').classList.contains('on'));
  t('명세를 다시 그린다', w.eval('__rendered') === 1);

  // 2) 같은 이름 거래처가 여럿이면 고르지 않는다
  w = make({ vendors: [ { vendorCd: 'A', vendorNm: '삼성웰스토리' }, { vendorCd: 'B', vendorNm: '삼성 웰스토리' } ], prods: PRODS, resp: { detail: ITEMS } });
  w.eval('_qtList=' + JSON.stringify([Q]) + '; saQtPick(0);'); await tick();
  t('이름 같은 거래처 둘(빈칸 무시) → 고르지 않음', w.eval('__picked') === null);
  t('→ 「같은 거래처가 여럿」 안내', /같은 거래처가 여럿/.test(w.eval('__alerts')[0]));

  // 3) 같은 이름이 없으면 고르지 않는다
  w = make({ vendors: [ { vendorCd: 'C', vendorNm: '팜파스' } ], prods: PRODS, resp: { detail: ITEMS } });
  w.eval('_qtList=' + JSON.stringify([Q]) + '; saQtPick(0);'); await tick();
  t('같은 이름 없음 → 고르지 않고 「없어」 안내', w.eval('__picked') === null && /같은 거래처가 없어/.test(w.eval('__alerts')[0]));

  // 4) 이미 거래처를 골라 두었으면 건드리지 않는다
  w = make({ vendors: [ { vendorCd: '00273', vendorNm: '삼성웰스토리' } ], prods: PRODS, resp: { detail: ITEMS }, preVen: { cd: 'X1', nm: '다른 거래처' } });
  w.eval('_qtList=' + JSON.stringify([Q]) + '; saQtPick(0);'); await tick();
  t('거래처를 이미 골랐으면 바꾸지 않는다', w.eval('__picked') === null && w.document.getElementById('saVenNm').dataset.cd === 'X1');
  t('→ 거래처 안내문도 없다', !/거래처를 골라 주세요/.test(w.eval('__alerts')[0]));

  // 5) 명세에 이미 있는 상품은 건너뛴다
  w = make({ vendors: [], prods: PRODS, resp: { detail: ITEMS }, preRows: [ { prodCd: '9904013324', prodNm: '이미', unitPrice: 30, eaQty: 1 }, { prodCd: '' } ] });
  w.eval('_qtList=' + JSON.stringify([Q]) + '; saQtPick(0);'); await tick();
  const r5 = w.eval('_rows');
  t('이미 있는 상품 → 건너뜀(기존 줄 단가 30 그대로)', r5.filter(r => r.prodCd === '9904013324').length === 1 && r5[0].unitPrice === 30);
  t('→ 「건너뛰었습니다」 안내', /이미 명세에 있는 1건은 건너뛰었습니다/.test(w.eval('__alerts')[0]));

  // 6) 목록 그리기 — 판매된 견적은 💰, 아니면 —
  w = make({ resp: {} });
  w.eval('_qtList=' + JSON.stringify([Q, Object.assign({}, Q, { quoteSeq: 84, docNo: 'Konet260918-01', saleCnt: 2, saleLastDt: '20261003' })]) + '; saQtRender();');
  const tr = w.document.querySelectorAll('#qtBody tr');
  t('목록 2줄', tr.length === 2);
  t('판매 안 된 견적 → —', /—/.test(tr[0].lastChild.textContent));
  t('판매된 견적 → 💰 2건(막지 않음)', /💰 2건/.test(tr[1].textContent) && /saQtPick\(1\)/.test(tr[1].getAttribute('onclick')));
  w.eval('_qtList=[]; saQtRender();');
  t('채택 견적이 없으면 안내', /채택된 견적서가 없습니다/.test(w.document.getElementById('qtBody').textContent));

  // 7) 저장된 전표의 연결 표시엔 ✕ 가 없다
  w = make({ resp: {} });
  w.eval('_cur={saleSeq:5}; _quoteLink={quoteSeq:96, docNo:"K-1"}; saQtTag();');
  t('저장된 전표 → ✕ 없음', !/✕/.test(w.document.getElementById('saQtTag').innerHTML) && /K-1/.test(w.document.getElementById('saQtTag').textContent));
  w.eval('_quoteLink=null; saQtTag();');
  t('연결 없음 → 표시 비움', w.document.getElementById('saQtTag').innerHTML === '');

  console.log('판매 등록 견적 가져오기 시뮬 ' + ok + '/' + (ok + bad));
  process.exit(bad ? 1 : 0);
})();
