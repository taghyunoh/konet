/* 셸 메뉴 「경영자관리」(총괄관리자만) — 서브메뉴 대표자 일정 · 비용 등록 · 종합 실적 시뮬 (2026-11-20)
   logistics_demo2.jsp 의 사이드바(재고 관리 ~ 정보 현황 서브메뉴 끝)를 떼어, 스크립틀릿 if 를 «총괄관리자 / 그 밖» 두 갈래로 풀어 jsdom 에서 본다.
   주메뉴 배지는 실제 asset/js/emp-badge.js 의 그 줄(ceoTip → paint 둘)을 떼어 돌린다.
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_ceoMngMenu.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), 'utf8').replace(/\r\n/g, '\n');
const badge = fs.readFileSync(path.join(ROOT, 'src/main/webapp/asset/js/emp-badge.js'), 'utf8').replace(/\r\n/g, '\n');
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }

/* 사이드바 조각 — 「재고 관리」 묶음 이름부터 「원장관리」 묶음 이름 앞까지 */
const a = src.indexOf('<div class="grp">재고 관리</div>'), b = src.indexOf('<div class="grp">원장관리</div>');
if (a < 0 || b < a) throw new Error('사이드바 조각을 못 찾음');
const raw = src.slice(a, b);
const IF = '<% if ("1".equals(String.valueOf(session.getAttribute("s_main_gu")).trim())) { %>';
function side(master){
  let s = raw.replace(/<%--[\s\S]*?--%>/g, '');                     /* JSP 주석 */
  let out = '', i = 0;
  for(;;){                                                           /* 총괄관리자 if 블록 */
    const p = s.indexOf(IF, i); if (p < 0) { out += s.slice(i); break; }
    const e = s.indexOf('<% } %>', p); if (e < 0) throw new Error('if 가 안 닫힘');
    out += s.slice(i, p) + (master ? s.slice(p + IF.length, e) : '');
    i = e + '<% } %>'.length;
  }
  if (/<%/.test(out)) throw new Error('안 풀린 스크립틀릿 : ' + out.slice(out.search(/<%/), out.search(/<%/) + 80));
  return out.replace(/\$\{pageContext\.request\.contextPath\}/g, '/konet');
}
function fn(name){ const i=src.indexOf('\n  function '+name+'('); if(i<0) throw new Error('함수 없음 '+name); let d=0, j=src.indexOf('{', i); for(let k=j;k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ d--; if(d===0) return src.slice(i+1, k+1); } } throw new Error('끝 없음 '+name); }
function boot(master){
  const dom = new JSDOM('<!DOCTYPE html><html><body><div class="logi-side">' + side(master) + '</div></body></html>', { runScripts: 'dangerously' });
  const w = dom.window;
  w.eval('var _calls=[]; function logiFrame(k,u,el){ _calls.push([k,u]); } function logiGo(){} function stkStatusLoad(){} function closeHistLoad(){} function xaLoad(){} function empTickerFold(){}\n' + fn('logiToggleSub'));
  return w;
}
const keysIn = (w, id) => [...w.document.querySelectorAll('#' + id + ' a.mi[data-key]')].map(x => x.getAttribute('data-key'));
const KEYS = ['ceoSched', 'expenseReg', 'perfSummary'];

/* ── 1. 총괄관리자 ── */
let w = boot(true), d = w.document;
const grps = [...d.querySelectorAll('.grp')].map(x => x.textContent.trim());
t('묶음 이름 「경영자관리」', grps.includes('경영자관리'), grps.join('|'));
t('옛 묶음 이름 「대표자 일정」 없음', !grps.includes('대표자 일정'));
t('묶음 차례 = 직원관리 → 경영자관리 → 정보 현황', grps.indexOf('경영자관리') === grps.indexOf('직원관리') + 1 && grps.indexOf('정보 현황') === grps.indexOf('경영자관리') + 1, grps.join('|'));
const head = d.querySelector('a.mi.has-sub[data-sub="ceomng"]');
t('주메뉴 = 접이식(has-sub)', !!head && /경영자관리/.test(head.textContent) && !!head.querySelector('.caret'));
t('주메뉴 배지 자리 ceoGrpBadge(처음엔 숨김)', !!head && !!head.querySelector('#ceoGrpBadge') && head.querySelector('#ceoGrpBadge').style.display === 'none');
t('주메뉴 바로 뒤가 서브메뉴 상자', !!head && head.nextElementSibling && head.nextElementSibling.id === 'sub-ceomng');
t('서브메뉴 = 대표자 일정 · 비용 등록 · 종합 실적 (그 차례)', keysIn(w, 'sub-ceomng').join(',') === KEYS.join(','), keysIn(w, 'sub-ceomng').join(','));
const labels = [...d.querySelectorAll('#sub-ceomng a.mi')].map(x => [...x.childNodes].filter(n => n.nodeType === 3).map(n => n.textContent.trim()).join(''));
t('메뉴 이름 그대로', labels.join('|') === '대표자 일정|비용 등록|종합 실적', labels.join('|'));
KEYS.forEach(k => t(k + ' 메뉴는 한 곳뿐', d.querySelectorAll('a.mi[data-key="' + k + '"]').length === 1));
t('재고 관리에는 비용 등록 없음', !keysIn(w, 'sub-stockmng').includes('expenseReg'));
t('재고 관리에 원가 관리는 그대로', keysIn(w, 'sub-stockmng').includes('costMng'));
t('정보 현황에는 종합 실적 없음', !keysIn(w, 'sub-infomng').includes('perfSummary'));
t('정보 현황 나머지 그대로', ['pipeline', 'closeStatus', 'closeHist', 'profitVen'].every(k => keysIn(w, 'sub-infomng').includes(k)), keysIn(w, 'sub-infomng').join(','));
t('대표자 일정 배지 자리(ceoLateBadge) 그대로', !!d.querySelector('#sub-ceomng a[data-key="ceoSched"] #ceoLateBadge'));
/* 접기·펼치기 */
const box = d.getElementById('sub-ceomng');
t('처음엔 접힘', !box.classList.contains('open') && !head.classList.contains('open'));
head.click();
t('주메뉴를 누르면 펼침', box.classList.contains('open') && head.classList.contains('open'));
t('펼쳐도 화면은 안 열림', w._calls.length === 0);
head.click();
t('다시 누르면 접힘', !box.classList.contains('open') && !head.classList.contains('open'));
/* 서브메뉴 → 화면 */
head.click();
d.querySelector('a.mi[data-key="ceoSched"]').click();
d.querySelector('a.mi[data-key="expenseReg"]').click();
d.querySelector('a.mi[data-key="perfSummary"]').click();
t('세 화면 주소', JSON.stringify(w._calls) === JSON.stringify([['ceoSched', '/konet/mangr/ceoSched.do'], ['expenseReg', '/konet/mangr/expenseReg.do'], ['perfSummary', '/konet/mangr/perfSummary.do']]), JSON.stringify(w._calls));
/* 패널(iframe 자리)은 그대로 */
KEYS.forEach(k => t(k + ' 패널·iframe 그대로', src.indexOf('id="panel-' + k + '"') > 0 && src.indexOf('id="if-' + k + '"') > 0));

/* 주메뉴 배지 — 실제 emp-badge.js 의 줄을 떼어 */
const pi = badge.indexOf("var ceoTip = "), pe = badge.indexOf('\n', badge.indexOf("paint('ceoGrpBadge'", pi));
t('emp-badge.js 가 두 배지를 같은 값으로 칠함', pi > 0 && pe > pi && /paint\('ceoLateBadge', late\.length, ceoTip\);\s*\n\s*paint\('ceoGrpBadge', late\.length, ceoTip\);/.test(badge.slice(pi, pe + 1)));
const pf = badge.indexOf('  function paint(id, n, title) {'), pfe = badge.indexOf('\n  }', pf) + 4;
function paintRun(win, late){ win._late = late; win.eval(badge.slice(pf, pfe) + '\nvar late=_late, nm=late.slice(0,5).map(function(x){ return x.title; }).join(", ");\n' + badge.slice(pi, pe + 1)); }
paintRun(w, [{ title: '삼성 미팅' }, { title: '은행' }]);
const gb = d.getElementById('ceoGrpBadge'), lb = d.getElementById('ceoLateBadge');
t('지난 미완료 2건 → 주메뉴·대표자 일정 둘 다 2', gb.textContent === '2' && lb.textContent === '2' && gb.style.display === '' && lb.style.display === '');
t('말풍선 같음', gb.title === lb.title && /지난 미완료 일정 2건/.test(gb.title), gb.title);
paintRun(w, []);
t('0건 → 둘 다 숨김', gb.style.display === 'none' && lb.style.display === 'none');

/* ── 2. 총괄관리자가 아닌 직원 ── */
w = boot(false); d = w.document;
const grps2 = [...d.querySelectorAll('.grp')].map(x => x.textContent.trim());
t('직원 : 묶음 이름 없음', !grps2.includes('경영자관리') && !grps2.includes('대표자 일정'), grps2.join('|'));
t('직원 : 주메뉴·서브메뉴 상자 없음', !d.querySelector('[data-sub="ceomng"]') && !d.getElementById('sub-ceomng'));
KEYS.forEach(k => t('직원 : ' + k + ' 메뉴 없음', d.querySelectorAll('a.mi[data-key="' + k + '"]').length === 0));
t('직원 : 배지 자리 없음(emp-badge.js 가 일정 조회를 안 함)', !d.getElementById('ceoLateBadge') && !d.getElementById('ceoGrpBadge'));
t('직원 : 원가 관리도 종전대로 없음', !d.querySelector('a.mi[data-key="costMng"]'));
t('직원 : 다른 메뉴는 그대로', ['stockStatus', 'stockAdj', 'empNotice', 'empMsg', 'leaveMng', 'pipeline', 'closeStatus'].every(k => d.querySelectorAll('a.mi[data-key="' + k + '"]').length === 1));
t('직원 : 묶음 차례 = 직원관리 → 정보 현황', grps2.indexOf('정보 현황') === grps2.indexOf('직원관리') + 1, grps2.join('|'));

/* ── 3. 업무설명서 ── */
const g = src.match(/<tr><td class="m">경영자관리<br>[\s\S]*?<\/tr>/);
t('업무설명서에 경영자관리 줄', !!g && /총괄관리자/.test(g[0]) && /대표자 일정/.test(g[0]) && /비용 등록/.test(g[0]) && /종합 실적/.test(g[0]));

console.log((bad ? '✗ ' : '✓ ') + 'sim_ceoMngMenu : ' + ok + ' 통과' + (bad ? ' · ' + bad + ' 실패' : ''));
process.exit(bad ? 1 : 0);
