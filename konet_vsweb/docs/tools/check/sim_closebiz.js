// 매출마감 「사업장별 품목코드」 그리기 시험 — JSP 의 함수들을 그대로 꺼내 가짜 화면에 태운다
const fs = require('fs');
const ROOT = require('path').resolve(__dirname, '../../..');
const src = fs.readFileSync(ROOT + '/src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp', 'utf8').replace(/\r\n/g, '\n');
const cut = (a, b) => { const i = src.indexOf(a), j = src.indexOf(b, i); if (i < 0 || j < 0) throw new Error('cut ' + a.slice(0, 40)); return src.slice(i, j); };
const code = [
  cut('  function _cesc(s){', '  /* 금액 근거 배지'),
  cut('  function _closeAgg(rows, keyFn){', '  /* 조회 진행바'),
  cut('  function _salesView(){', '  function _salesQNote()'),
  cut('  function salesTab(t){', '  // ── 매입(입고)마감'),
].join('\n');
const els = {};
const el = id => els[id] || (els[id] = { id, innerHTML: '', textContent: '', style: {}, value: '', checked: false, placeholder: '', classList: { toggle() {} }, getAttribute() { return ''; } });
const store = {};
const env = {
  document: { getElementById: el, querySelectorAll: () => [] },
  localStorage: { getItem: k => (k in store ? store[k] : null), setItem: (k, v) => { store[k] = String(v); } },
  _cnum: n => String(Math.round(n)), _srcBadge: () => '', _salesNote: () => '', _zoneGroup: r => r.dcNm || '', SALES_PAGE: 18,
  lzMount: o => { const w = el('closeSalesWrap'); const n = Math.min(env.page, o.list.length); w._lz = { list: o.list, from: n, rowFn: o.rowFn, rows: env.page }; w._head = o.head; w.scrollTop = 0;
    w.innerHTML = o.head + o.list.slice(0, n).map(o.rowFn).join('') + '</tbody></table>'; },
  lzFill: w => { const z = w._lz; if (!z || z.from >= z.list.length) return; const to = Math.min(z.from + z.rows, z.list.length); z.from = to; w.innerHTML = w._head + z.list.slice(0, to).map(z.rowFn).join('') + '</tbody></table>'; },
  kzF: () => 1, page: 1000,
};
const dec = t => t.replace(/&quot;/g, '"').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
{ const w = el('closeSalesWrap'); w.scrollTop = 0; w.getBoundingClientRect = () => ({ top: 0 });
  w.querySelectorAll = () => w.innerHTML.split('<tr').slice(1).map((t, i) => ({ t, i })).filter(x => /data-k="/.test(x.t)).map(x => ({ getAttribute: () => dec(x.t.match(/data-k="([^"]*)"/)[1]), getBoundingClientRect: () => ({ top: x.i * 20 - w.scrollTop }) })); }
const names = Object.keys(env).filter(k => k !== 'page' && k !== '_mounted');
const api = new Function(...names, 'var _salesRows=[], _salesQ="", _salesTab="biz", _salesCollapsed={};\n' + code +
  '\nreturn { set:function(r){ _salesRows=r; }, q:function(v){ _salesQ=v; }, render:salesRenderTab, tab:salesTab, toggle:salesToggleKey, collapseAll:salesCollapseAll, expandAll:salesExpandAll, fr:bizFrToggle, st:function(){ return _salesCollapsed; } };')(...names.map(k => env[k]));

const R = (cd, nm, item, q, amt) => ({ bizCd: cd, bizNm: nm, itemCd: item, itemNm: '품목 ' + item, outQty: q, salesAmt: amt, costAmt: amt * 0.7, marginAmt: amt * 0.3 });
const rows = [
  R('A001', '꾸아(강남역삼성타운점)', 'I1', 1, 24150),
  R('A002', '꾸아(교대점)', 'I2', 1, 110400), R('A002', '꾸아(교대점)', 'I3', 1, 31200),
  R('A003', '꾸아(구월로데오점)(신)', 'I1', 2, 53972),
  R('B001', '단독카페', 'I1', 3, 9000),
  R('C001', '(온정돈까스)부산광안점', 'I4', 1, 1000), R('C002', '(온정돈까스) 광주수완점', 'I4', 2, 2000),
  R('D001', '같은이름', 'I1', 1, 100), R('D002', '같은이름', 'I1', 1, 200),
  R('E001', '이름에 "따옴표"(1호점)', 'I1', 1, 10), R('E002', '이름에 "따옴표"(2호점)', 'I1', 1, 20),
];
let ok = 0, bad = 0; const chk = (n, c, x) => { (c ? ok++ : bad++); console.log((c ? '✓ ' : '✗ ') + n + (x ? ' — ' + x : '')); };
const html = () => el('closeSalesWrap').innerHTML;
const trs = () => html().split('<tr').slice(1).map(t => '<tr' + t.split('</tr>')[0]);
const cnt = cls => trs().filter(t => t.includes('class="' + cls)).length;

api.set(rows); api.tab('biz');
chk('탭을 열면 묶기 체크가 보이고 켜져 있다', el('bizFrWrap').style.display === 'inline-flex' && el('bizFrChk').checked === true && /프랜차이즈/.test(el('salesQ').placeholder));
chk('요약 줄 : 사업장 10 · 프랜차이즈 3', /<b>10<\/b>사업장/.test(el('closeSalesSum').innerHTML) && /프랜차이즈 <b>3<\/b>개/.test(el('closeSalesSum').innerHTML), el('closeSalesSum').innerHTML.replace(/<[^>]+>/g, '').slice(0, 60));
chk('프랜차이즈 합계 줄 3 (꾸아 · 온정돈까스 · 이름에 "따옴표")', cnt('close-grp close-fr') === 3);
const kk = trs().find(t => t.includes('close-fr') && t.includes('<b>꾸아</b>'));
chk('꾸아 합계 = 매장 3곳 · 수량 5 · 매출 219,722', !!kk && kk.includes('매장 3곳') && kk.includes('>5</td>') && kk.includes('>219722</td>'), kk && kk.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').slice(0, 90));
chk('프랜차이즈 안 매장 줄은 들여쓴 줄(close-sub) 7 · 단독 매장 줄(close-grp) 3', cnt('close-sub') === 7 && trs().filter(t => t.includes('class="close-grp"')).length === 3);
chk('매장 줄에 코드가 보인다', trs().some(t => t.includes('꾸아(교대점)') && t.includes('<span class="bizcd"') && t.includes('A002')));
chk('같은 이름 · 다른 코드는 따로(D001 · D002)', trs().filter(t => t.includes('같은이름')).length === 2);
chk('총합계는 그대로', trs()[1].includes('■ 총합계') && trs()[1].includes('>15</td>'));
const before = trs().length;
api.toggle('bf#꾸아');
chk('프랜차이즈 줄을 누르면 그 매장·품목이 접힌다', trs().length === before - 3 - 4 && trs().find(t => t.includes('<b>꾸아</b>')).includes('▶'), before + ' → ' + trs().length);
api.toggle('bf#꾸아'); api.toggle('bs#A002|꾸아(교대점)');
chk('매장 줄을 누르면 그 품목만 접힌다', trs().length === before - 2);
api.expandAll(); api.collapseAll();
chk('전체 접기 = 프랜차이즈 3 + 단독 매장 3 + 총합계', trs().length === 1 + 1 + 3 + 3, String(trs().length));
api.expandAll();
const quote = trs().find(t => t.includes('close-fr') && t.includes('따옴표'));
chk('이름에 따옴표가 있어도 속성이 안 깨진다', !!quote && /data-k="bf#이름에 &quot;따옴표&quot;"/.test(quote));
api.fr(false);
chk('묶기를 끄면 프랜차이즈 줄 0 · 매장 줄 10(종전 모양)', cnt('close-grp close-fr') === 0 && trs().filter(t => t.includes('class="close-grp"')).length === 10 && cnt('close-sub') === 0 && !/프랜차이즈/.test(el('closeSalesSum').innerHTML));
api.fr(true); api.q('꾸아'); api.render();
chk('검색 「꾸아」 = 꾸아 매장만 + 합계', cnt('close-grp close-fr') === 1 && cnt('close-sub') === 3 && trs()[1].includes('>5</td>'));
api.q('a002'); api.render();
chk('매장코드로도 찾는다(A002 한 곳 — 한 곳뿐이라 묶지 않음)', cnt('close-grp close-fr') === 0 && trs().filter(t => t.includes('class="close-grp"')).length === 1);
api.q(''); api.tab('item');
chk('다른 탭에서는 묶기 체크가 숨는다', el('bizFrWrap').style.display === 'none' && !/프랜차이즈/.test(el('salesQ').placeholder));
api.q('꾸아'); api.render();
chk('품목 탭 검색은 종전대로(사업장 이름으로는 안 찾음)', /검색 결과가 없습니다/.test(el('closeSalesSum').textContent));
// ── 접기·펼치기 뒤에도 보던 자리 그대로(2026-11-18 「표시 접기하면 다른 곳으로 이동함」)
{ const many = []; for (let b = 0; b < 12; b++) for (let k = 0; k < 4; k++) many.push(R('M' + b + k, '브랜드' + b + '(' + k + '호점)', 'I1', 1, 100));
  api.q(''); api.set(many); env.page = 5; api.tab('biz'); api.expandAll();
  const w = el('closeSalesWrap'); while (w._lz.from < w._lz.list.length) env.lzFill(w);   // 끝까지 내려 본 상태
  const all = w._lz.list.length, key = 'bf#브랜드9';
  const rowOf = k => w.querySelectorAll().find(r => r.getAttribute() === k);
  w.scrollTop = 1500; const before = rowOf(key).getBoundingClientRect().top;
  api.toggle(key, rowOf(key));
  const after = rowOf(key);
  chk('아래쪽 프랜차이즈를 접어도 그 줄이 보던 높이에 그대로', !!after && after.getBoundingClientRect().top === before, '전 ' + before + ' · 뒤 ' + (after ? after.getBoundingClientRect().top : '없음') + ' · 스크롤 ' + w.scrollTop);
  chk('접은 뒤에도 보던 데까지 줄이 붙어 있다', w._lz.from === w._lz.list.length && w._lz.list.length === all - 8, w._lz.from + '/' + w._lz.list.length);
  api.toggle(key, rowOf(key));
  chk('다시 펴도 제자리', rowOf(key).getBoundingClientRect().top === before && w._lz.list.length === all);
  w.scrollTop = 700; api.toggle('없는열쇠', null);
  chk('줄을 모르면 전 스크롤 값으로', w.scrollTop === 700); }
console.log(ok + ' 통과 / ' + bad + ' 실패'); process.exit(bad ? 1 : 0);
