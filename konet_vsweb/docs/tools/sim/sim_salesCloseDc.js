/* 매출마감 — 탭 줄의 [🏬 출고장 ▾] 콤보(전체 · 하나 · 여러 곳) (2026-11-18)
   logi-oh.js 의 slcDc* 와 JSP 의 _zoneGroup·_salesView·_salesQNote 를 떼어 jsdom 위에서 돌린다.
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_salesCloseDc.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const J = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), 'utf8').replace(/\r\n/g, '\n');
const O = fs.readFileSync(path.join(ROOT, 'src/main/webapp/js/winct/logi-oh.js'), 'utf8').replace(/\r\n/g, '\n');
const cut = (src, a, b) => { const i = src.indexOf(a), j = src.indexOf(b, i + a.length); if (i < 0 || j < 0) throw new Error('cut ' + a.slice(0, 40)); return src.slice(i, j); };
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }
const { JSDOM } = req('jsdom');
/* 화면 조각 = JSP 의 탭 줄 그대로 */
const tabs = cut(J, '<div class="close-tabs" id="salesTabs">', '<div class="close-summary" id="closeSalesSum">').replace(/<%--[\s\S]*?--%>/g, '');
const tabs2 = cut(J, '<div class="close-tabs" id="statTabs">', '<div class="close-summary" id="closeStatusSum">').replace(/<%--[\s\S]*?--%>/g, '');
const dom = new JSDOM('<!DOCTYPE html><html><body>' + tabs + tabs2 + '<div id="outside">x</div></body></html>', { runScripts: 'outside-only' });
const w = dom.window, d = w.document;
w.eval([
  "var konetDc={ GROUP:{ E200:'오산센터', E300:'오산센터', E400:'오산센터', E600:'오산센터', E700:'오산센터' } };",
  "var _salesRows=[], _salesTab='zone', _salesCollapsed={z:1}, _salesAllCollapsed=true, __renders=0, __upd=0;",
  "function _cesc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }",
  "var CLOSE_DCGROUP=window.konetDc.GROUP;",
  cut(J, '  function _zoneGroup(r){', "  var _salesQ='';"),
  cut(J, "  var _salesQ='';", '  /* 출고미상 경고'),
  "function _salesUpdAllBtn(){ __upd++; }",
  "function salesRenderTab(){ if(window.slcDcSync) slcDcSync(); __renders++; window.__view=_salesView(); }",
  /* 마감현황 쪽 */
  "var _statRows=[], _statTab='zone', _statCollapsed={z:1}, _statAllCollapsed=true, __supd=0;",
  cut(J, "  var _statQ='';", '  function statSearch(){'),
  "function statUpdAllBtn(){ __supd++; }",
  "function statRenderTab(){ if(window.stcDcSync) stcDcSync(); window.__sview=_statView(); }",
  cut(O, '  function slcEsc(v){', '  var _spDcSel={};'),
].join('\n'));
const R = (cd, nm, item, amt) => ({ dcCd: cd, dcNm: nm, itemCd: item, itemNm: '품목 ' + item, bizCd: 'B' + item, bizNm: '매장 ' + item, salesAmt: amt });
const rows = [
  R('E200', '왜관물류센터', 'I1', 100), R('E300', '김해물류센터', 'I2', 200), R('E700', '오산물류센터', 'I3', 300),
  R('E500', '평택물류센터', 'I1', 1000), R('E500', '평택물류센터', 'I4', 2000),
  R('E100', '용인물류센터', 'I2', 500),
  R('TRX', '직접판매(전표)', 'I5', 7000), R('DAESANG', '대상', 'I6', 40), R('', '평택', 'I7', 9),
];
w.eval('_salesRows=' + JSON.stringify(rows) + '; salesRenderTab();');
const sum = () => w.__view.reduce((a, r) => a + r.salesAmt, 0);
const labs = () => [...d.querySelectorAll('#slcDcPop label')].map(l => (l.className ? '[' + l.className + '] ' : '') + l.textContent.trim());
const chk = (k) => [...d.querySelectorAll('#slcDcPop input[data-k]')].find(i => i.getAttribute('data-k') === k);
const press = (k) => { const i = chk(k); i.checked = !i.checked; w.slcDcToggle(k); };
t('탭 줄에 콤보가 🔎 검색칸 바로 뒤에 있다', (() => { const q = d.getElementById('salesQ'); return q && q.nextElementSibling && q.nextElementSibling.id === 'slcDcWrap'; })());
t('처음 = 전체 · 9줄 다 보인다', d.getElementById('slcDcLbl').textContent === '전체' && w.__view.length === 9 && sum() === 11149);
t('목록 = 전체(6개 출고장) + 묶음 6 + 오산센터 하위 3', (() => { const l = labs(); return /전체 \(6개 출고장\)/.test(l[0]) && l.filter(x => /🗂️/.test(x)).length === 6 && l.filter(x => /^\[kid/.test(x)).length === 3; })(), labs().join(' / '));
t('2곳 이상인 묶음만 하위를 편다(오산센터 3곳) · 평택물류센터는 한 줄', labs().some(x => /🗂️ 오산센터 \(3곳\)/.test(x)) && labs().some(x => /^\[kid\] 김해물류센터 \(E300\)/.test(x)) && !labs().some(x => /^\[kid.*평택물류센터/.test(x)));
t('「전체」가 체크돼 있다', d.querySelector('#slcDcPop label.all input').checked === true);
/* 단일 체크 — 묶음 */
w.eval('_salesCollapsed={z:1}; _salesAllCollapsed=true; __upd=0;');
press('G|오산센터');
t('★묶음 하나 체크 = 오산센터 3줄만 · 합 600', w.__view.length === 3 && sum() === 600, w.__view.length + ' / ' + sum());
t('라벨 = 오산센터 · 「전체」 체크 풀림 · 그 줄 강조', d.getElementById('slcDcLbl').textContent === '오산센터' && !d.querySelector('#slcDcPop label.all input').checked && chk('G|오산센터').checked && chk('G|오산센터').parentNode.className === 'on');
t('거르면 접기 상태를 비우고 단추 글자를 맞춘다', w.eval('Object.keys(_salesCollapsed).length') === 0 && w.eval('_salesAllCollapsed') === false && w.eval('__upd') === 1);
t('요약 줄 꼬리에 「🏬 출고장 오산센터만」', /🏬 출고장 오산센터만/.test(w.eval('_salesQNote()')));
t('거르는 중이면 단추 테두리 색이 바뀐다', d.getElementById('slcDcBtn').style.borderColor !== '');
/* 다중 체크 */
press('G|평택물류센터');
t('★여러 곳 체크 = 합(오산센터 3 + 평택물류센터 2) · 3,600 · 라벨 「2곳 선택」', w.__view.length === 5 && sum() === 3600 && d.getElementById('slcDcLbl').textContent === '2곳 선택', w.__view.length + ' / ' + sum());
press('G|직접판매(전표)');
t('세 곳 = 10,600 · 「3곳 선택」', sum() === 10600 && d.getElementById('slcDcLbl').textContent === '3곳 선택');
/* 다시 눌러 빼기 */
press('G|오산센터'); press('G|평택물류센터');
t('체크를 풀면 빠진다 → 직접판매(전표) 한 곳 7,000', w.__view.length === 1 && sum() === 7000 && d.getElementById('slcDcLbl').textContent === '직접판매(전표)');
/* 전체 */
d.querySelector('#slcDcPop label.all input').checked = true; w.slcDcAll();
t('★「전체」 = 선택을 다 풀고 9줄', w.__view.length === 9 && d.getElementById('slcDcLbl').textContent === '전체' && w.eval('_salesQNote()') === '' && d.getElementById('slcDcBtn').style.borderColor === '');
/* 단일 체크 — 개별 출고장 */
press('D|E300|김해물류센터');
t('★개별 출고장 하나 = 김해 1줄 200 · 라벨 「김해물류센터 (E300)」', w.__view.length === 1 && sum() === 200 && d.getElementById('slcDcLbl').textContent === '김해물류센터 (E300)');
press('D|E200|왜관물류센터');
t('개별 둘 = 300', sum() === 300 && d.getElementById('slcDcLbl').textContent === '2곳 선택');
w.slcDcAll();
/* 이름이 같은 묶음과 출고장 : 「평택」(코드 없는 정산서) ≠ 평택물류센터 */
press('G|평택');
t('「평택」(코드 없음)만 = 1줄 9 — 평택물류센터와 안 섞인다', w.__view.length === 1 && sum() === 9);
w.slcDcAll();
/* 검색과 함께 */
press('G|오산센터'); w.eval("_salesQ='i2'; salesRenderTab();");
t('출고장 + 검색 = 오산센터 안의 I2 한 줄(용인의 I2 는 빠짐)', w.__view.length === 1 && w.__view[0].dcCd === 'E300');
t('요약 꼬리에 둘 다 — 출고장 표시 + 검색중', /🏬 출고장 오산센터만/.test(w.eval('_salesQNote()')) && /검색중/.test(w.eval('_salesQNote()')));
w.eval("_salesQ='';");
/* 달을 바꿔 그 출고장이 없어지면 선택을 스스로 지운다 */
w.eval('_salesRows=' + JSON.stringify(rows.filter(r => r.dcCd === 'E500' || r.dcCd === 'E100')) + '; salesRenderTab();');
t('★다시 조회해 그 출고장이 없으면 선택을 지우고 전체로', d.getElementById('slcDcLbl').textContent === '전체' && w.__view.length === 3, d.getElementById('slcDcLbl').textContent + ' / ' + w.__view.length);
/* 조회 전(자료 없음) */
w.eval('_salesRows=[]; salesRenderTab();');
t('자료가 없으면 「[조회]를 먼저 하세요」', /\[조회\]를 먼저/.test(d.getElementById('slcDcPop').textContent));
/* 열기 · 바깥 누르면 닫힘 · 안쪽은 안 닫힘 */
w.eval('_salesRows=' + JSON.stringify(rows) + '; salesRenderTab();');
w.slcDcOpen({ stopPropagation(){} });
t('단추를 누르면 열린다', d.getElementById('slcDcPop').classList.contains('open'));
d.querySelector('#slcDcPop label').dispatchEvent(new w.MouseEvent('click', { bubbles: true }));
t('목록 안을 눌러도 안 닫힌다(여러 개를 이어서 체크)', d.getElementById('slcDcPop').classList.contains('open'));
press('G|대상');
t('체크한 뒤에도 열린 채(다시 그려도)', d.getElementById('slcDcPop').classList.contains('open') && sum() === 40);
d.getElementById('outside').dispatchEvent(new w.MouseEvent('click', { bubbles: true }));
t('바깥을 누르면 닫힌다', !d.getElementById('slcDcPop').classList.contains('open'));
/* 따옴표가 든 출고장 이름 */
w.slcDcAll(); w.eval("_salesRows=[{dcCd:'X1',dcNm:'가\"나 <센터>',itemCd:'I1',itemNm:'a',salesAmt:5},{dcCd:'X2',dcNm:'다',itemCd:'I1',itemNm:'a',salesAmt:6}]; salesRenderTab();");
t('이름에 따옴표·꺾쇠가 있어도 안 깨진다', !!chk('G|가"나 <센터>') && d.querySelectorAll('#slcDcPop label').length === 3);
press('G|가"나 <센터>');
t('그 출고장만 걸러진다', w.__view.length === 1 && sum() === 5);
/* JSP 연결 */
t('JSP _salesView 가 콤보를 먼저 거친다 · salesRenderTab 첫머리에 slcDcSync', J.indexOf('var base=window.slcDcView ? slcDcView(_salesRows) : _salesRows;') > 0 && /function salesRenderTab\(\)\{\n\s+if\(window\.slcDcSync\) slcDcSync\(\);/.test(J));
t('업무설명서 매출마감 행에 한 문장', /class="m">매출마감<\/td>[^\n]*\[🏬 출고장 ▾\]/.test(J));
/* ── 마감현황(월계표) — 같은 콤보, 선택은 따로 ── */
w.slcDcAll(); w.eval('_salesRows=' + JSON.stringify(rows) + '; salesRenderTab(); _statRows=' + JSON.stringify(rows) + '; statRenderTab();');
const ssum = () => w.__sview.reduce((a, r) => a + r.salesAmt, 0);
const schk = (k) => [...d.querySelectorAll('#stcDcPop input[data-k]')].find(i => i.getAttribute('data-k') === k);
t('마감현황 탭 줄에도 콤보가 🔎 검색칸 바로 뒤에', (() => { const q = d.getElementById('statQ'); return q && q.nextElementSibling && q.nextElementSibling.id === 'stcDcWrap'; })());
t('마감현황 처음 = 전체 · 9줄 · 목록 꼴은 매출마감과 같다', d.getElementById('stcDcLbl').textContent === '전체' && w.__sview.length === 9 && d.querySelectorAll('#stcDcPop label').length === d.querySelectorAll('#slcDcPop label').length);
w.eval('_statCollapsed={z:1}; _statAllCollapsed=true; __supd=0;');
w.stcDcToggle('G|오산센터');
t('★마감현황 묶음 하나 = 3줄 600 · 라벨 오산센터', w.__sview.length === 3 && ssum() === 600 && d.getElementById('stcDcLbl').textContent === '오산센터' && schk('G|오산센터').checked);
t('마감현황 접기 상태를 비우고 단추 글자를 맞춘다', w.eval('Object.keys(_statCollapsed).length') === 0 && w.eval('_statAllCollapsed') === false && w.eval('__supd') === 1);
t('★두 화면의 선택은 따로 — 매출마감은 전체 그대로', d.getElementById('slcDcLbl').textContent === '전체' && w.__view.length === 9 && !d.querySelector('#slcDcPop input[data-k="G|오산센터"]').checked);
w.stcDcToggle('D|E500|평택물류센터');
t('마감현황 여러 곳 = 3,600 · 「2곳 선택」', ssum() === 3600 && d.getElementById('stcDcLbl').textContent === '2곳 선택');
t('마감현황 요약 꼬리 「🏬 출고장 2곳 선택만」', /🏬 출고장 2곳 선택만/.test(w.eval('_statQNote()')));
w.eval("_statQ='i4'; statRenderTab();");
t('마감현황 출고장 + 검색 = 평택물류센터의 I4 한 줄', w.__sview.length === 1 && w.__sview[0].itemCd === 'I4');
w.eval("_statQ='용인'; statRenderTab();");
t('마감현황 출고장별 탭의 출고장 이름 검색도 콤보 안에서만(용인은 안 골랐다 → 0줄)', w.__sview.length === 0);
w.eval("_statQ=''; statRenderTab();");
press('G|대상');
t('매출마감에서 골라도 마감현황 선택은 그대로', d.getElementById('stcDcLbl').textContent === '2곳 선택' && ssum() === 3600 && sum() === 40);
d.querySelector('#stcDcPop label.all input').checked = true; w.stcDcAll();
t('마감현황 「전체」 = 9줄', w.__sview.length === 9 && d.getElementById('stcDcLbl').textContent === '전체' && w.eval('_statQNote()') === '');
w.stcDcOpen({ stopPropagation(){} });
t('마감현황 콤보를 열어도 매출마감 콤보는 안 열린다', d.getElementById('stcDcPop').classList.contains('open') && !d.getElementById('slcDcPop').classList.contains('open'));
d.getElementById('outside').dispatchEvent(new w.MouseEvent('click', { bubbles: true }));
t('바깥을 누르면 마감현황 콤보도 닫힌다', !d.getElementById('stcDcPop').classList.contains('open'));
t('JSP _statView 가 콤보를 먼저 거친다 · statRenderTab 첫머리에 stcDcSync', J.indexOf('var base=window.stcDcView ? stcDcView(_statRows) : _statRows;') > 0 && /function statRenderTab\(\)\{\n\s+if\(window\.stcDcSync\) stcDcSync\(\);/.test(J));
t('업무설명서 마감현황 행에 한 문장', /class="m">마감현황\(월계표\)<\/td>[^\n]*\[🏬 출고장 ▾\]/.test(J));
console.log((bad ? '✗ ' : '✓ ') + 'sim_salesCloseDc : 통과 ' + ok + ' · 실패 ' + bad);
