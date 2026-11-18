/* 재고 조정 승인 대기 — 셸 메뉴 빨간 배지 시뮬 (2026-11-18 「대기 중인 승인 요청 수를 관리자 메뉴에 빨간 배지」)
   asset/js/emp-badge.js 를 셸 메뉴 두 줄(재고 관리 · 재고 일괄조정)만 본뜬 문서에 올리고 /emp/badge.do 응답을 바꿔 가며 본다.
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_adjReqBadge.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const js = fs.readFileSync(path.join(ROOT, 'src/main/webapp/asset/js/emp-badge.js'), 'utf8');
const shell = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), 'utf8');
const ctl = fs.readFileSync(path.join(ROOT, 'src/main/java/egovframework/konet/user/web/UserController.java'), 'utf8');
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
/* 셸에서 메뉴 두 줄을 그대로 떼어 온다(배지 자리가 실제 마크업에 있는지도 함께 본다) */
const pick = (re) => { const m = shell.match(re); return m ? m[0].replace(/\$\{pageContext\.request\.contextPath\}/g, '') : ''; };
const mGrp = pick(/<a class="mi has-sub" data-sub="stockmng"[^\n]*?<\/a>/), mAdj = pick(/<a class="mi" data-key="stockAdj"[\s\S]*?<\/a>/);
const html = '<!doctype html><html><body><div class="logi-side">' + mGrp + mAdj + '</div><section id="panel-stockAdj" class="panel"></section></body></html>';

(async () => {
  t('셸 「재고 관리」 주메뉴에 배지 자리(adjReqGrpBadge · 처음엔 숨김)', /id="adjReqGrpBadge" style="display:none"/.test(mGrp) && /class="emp-badge"/.test(mGrp), mGrp.slice(0, 120));
  t('셸 「재고 일괄조정」 메뉴에 배지 자리(adjReqBadge · 처음엔 숨김)', /id="adjReqBadge" style="display:none"/.test(mAdj), mAdj.slice(0, 160));
  t('서버 — 배지 응답의 adjReq 는 관리자(empAdmin)일 때만 · 실패해도 따로 잡는다', /if \(empAdmin\(session\)\) \{\s*try \{[^}]*r\.put\("adjReq", svc\.selectStockAdjReqPendCnt\(q\)\); \}\s*catch/.test(ctl));

  let resp = { result: 'OK', noticeUnread: 0, msgUnread: 0, adjReq: 2 };
  const dom = new JSDOM(html, { url: 'http://localhost:9071/main.do', runScripts: 'outside-only', pretendToBeVisual: true });
  const w = dom.window, d = w.document; w.__toasts = [];
  w.fetch = (url) => Promise.resolve({ ok: true, json: () => Promise.resolve(/badge\.do/.test(url) ? resp : { result: 'OK', list: [] }) });
  w._toast = (m) => w.__toasts.push(String(m));
  w.eval(js); await sleep(80);
  const b1 = d.getElementById('adjReqBadge'), b2 = d.getElementById('adjReqGrpBadge');
  const again = async () => { w.konetEmpBadge(); await sleep(60); };
  if (b1.style.display === 'none') await again();          /* 스크립트가 첫 조회를 미뤄 두는 경우 */
  t('관리자 · 대기 2건 — 두 메뉴에 「2」가 보인다', b1.textContent === '2' && b1.style.display !== 'none' && b2.textContent === '2' && b2.style.display !== 'none', b1.textContent + '/' + b1.style.display);
  t('말풍선 — 「재고 조정 승인 대기 2건」', /재고 조정 승인 대기 2건/.test(b1.title) && /승인·반려/.test(b1.title), b1.title);
  t('처음 읽을 때는 알림을 띄우지 않는다', !w.__toasts.some(m => /재고 조정/.test(m)), w.__toasts.join('|'));
  resp = Object.assign({}, resp, { adjReq: 3 }); await again();
  t('★대기가 늘면(2 → 3) 배지 3 + 알림 한 번(「1건이 새로」)', b1.textContent === '3' && w.__toasts.filter(m => /재고 조정 승인 요청 1건/.test(m)).length === 1, w.__toasts.join('|'));
  await again();
  t('같은 수면 알림을 또 띄우지 않는다', w.__toasts.filter(m => /재고 조정/.test(m)).length === 1);
  d.getElementById('panel-stockAdj').classList.add('show');
  resp = Object.assign({}, resp, { adjReq: 5 }); await again();
  t('재고 일괄조정 화면을 보고 있을 때는 알림 없이 배지만(5)', b1.textContent === '5' && w.__toasts.filter(m => /재고 조정/.test(m)).length === 1);
  resp = Object.assign({}, resp, { adjReq: 4 }); await again();
  t('승인·반려로 줄면(5 → 4) 배지만 준다 · 알림 없음', b1.textContent === '4' && w.__toasts.filter(m => /재고 조정/.test(m)).length === 1);
  resp = Object.assign({}, resp, { adjReq: 0 }); await again();
  t('대기 0건 — 두 배지 모두 숨는다', b1.style.display === 'none' && b2.style.display === 'none' && b1.title === '');
  resp = Object.assign({}, resp, { adjReq: 120 }); await again();
  t('99 넘으면 「99+」', b1.textContent === '99+');
  /* 직원(응답에 adjReq 없음) */
  const dom2 = new JSDOM(html, { url: 'http://localhost:9071/main.do', runScripts: 'outside-only', pretendToBeVisual: true });
  const w2 = dom2.window; w2.__toasts = [];
  w2.fetch = (url) => Promise.resolve({ ok: true, json: () => Promise.resolve(/badge\.do/.test(url) ? { result: 'OK', noticeUnread: 1, msgUnread: 0 } : { result: 'OK', list: [] }) });
  w2._toast = (m) => w2.__toasts.push(String(m));
  w2.eval(js); await sleep(80); w2.konetEmpBadge(); await sleep(60);
  const c1 = w2.document.getElementById('adjReqBadge');
  t('★직원(응답에 adjReq 없음) — 배지는 숨은 채 · 알림 없음', c1.style.display === 'none' && c1.textContent === '' && !w2.__toasts.some(m => /재고 조정/.test(m)));
  /* ── 요청한 직원 : 내 요청 결과(adjMine) — 2026-11-18 「요청한 직원에게도 승인/반려 결과 알림 표시」 ── */
  const mkW = async (first) => { const dm = new JSDOM(html, { url: 'http://localhost:9071/main.do', runScripts: 'outside-only', pretendToBeVisual: true }); const ww = dm.window; ww.__toasts = []; ww.__resp = first;
    ww.fetch = (url) => Promise.resolve({ ok: true, json: () => Promise.resolve(/badge\.do/.test(url) ? ww.__resp : { result: 'OK', list: [] }) });
    ww._toast = (m, ty) => ww.__toasts.push(String(m) + ' [' + ty + ']'); ww.eval(js); await sleep(80);
    if (ww.document.getElementById('adjReqBadge').style.display === 'none' && (first.adjMine || first.adjReq)) { ww.konetEmpBadge(); await sleep(60); }
    return ww; };
  const A1 = { reqSeq: 1, statGb: 'A', apprUserNm: '마스터', apprMemo: '', itemNm: '크라프트 종이컵 13oz', itemCnt: 2 }, R2 = { reqSeq: 2, statGb: 'R', apprUserNm: '마스터', apprMemo: '사진 첨부 후 다시', itemNm: '스테이크 스티커', itemCnt: 1 };
  let w3 = await mkW({ result: 'OK', noticeUnread: 0, msgUnread: 0, adjMine: 0 });
  const e1 = w3.document.getElementById('adjReqBadge'), e2 = w3.document.getElementById('adjReqGrpBadge');
  t('직원 · 결과 없음 — 배지 숨김 · 알림 없음', e1.style.display === 'none' && !w3.__toasts.length);
  w3.__resp = { result: 'OK', adjMine: 1, adjMineList: [A1] }; w3.konetEmpBadge(); await sleep(60);
  t('★승인되면 — 배지 1(청록) + 「요청 #1 이 승인됐습니다」 알림', e1.textContent === '1' && e1.style.display !== 'none' && e2.textContent === '1' && /19,\s*122,\s*108|#137a6c/i.test(e1.style.background) && w3.__toasts.length === 1 && /요청 #1 \(크라프트 종이컵 13oz 외 1건\) 이 승인됐습니다/.test(w3.__toasts[0]) && /\[ok\]/.test(w3.__toasts[0]), e1.style.background + ' | ' + w3.__toasts.join('|'));
  t('말풍선 — 「내 재고 조정 요청 결과 1건」', /내 재고 조정 요청 결과 1건/.test(e1.title), e1.title);
  w3.__resp = { result: 'OK', adjMine: 2, adjMineList: [R2, A1] }; w3.konetEmpBadge(); await sleep(60);
  t('★반려되면 — 배지 2(빨강 = 기본색) + 「요청 #2 이 반려됐습니다 — 사유」 경고 알림', e1.textContent === '2' && !e1.style.background && w3.__toasts.length === 2 && /요청 #2 \(스테이크 스티커\) 이 반려됐습니다 — 사진 첨부 후 다시/.test(w3.__toasts[1]) && /\[warn\]/.test(w3.__toasts[1]), e1.style.background + ' | ' + w3.__toasts[1]);
  w3.konetEmpBadge(); await sleep(60);
  t('같은 수면 알림을 또 띄우지 않는다', w3.__toasts.length === 2);
  w3.__resp = { result: 'OK', adjMine: 0 }; w3.konetEmpBadge(); await sleep(60);
  t('[확인했습니다] 뒤(0건) — 배지가 사라진다', e1.style.display === 'none' && e2.style.display === 'none');
  await sleep(30); w3.close();
  let w4 = await mkW({ result: 'OK', adjMine: 3, adjMineList: [R2, A1, A1] });
  t('★로그인했을 때 이미 와 있던 결과 — 「결과 3건이 와 있습니다」 알림 한 번 + 배지 3', w4.document.getElementById('adjReqBadge').textContent === '3' && w4.__toasts.length === 1 && /요청 결과 3건이 와 있습니다/.test(w4.__toasts[0]), w4.__toasts.join('|'));
  await sleep(30); w4.close();
  let w5 = await mkW({ result: 'OK', adjReq: 2, adjMine: 1, adjMineList: [A1] });
  const f1 = w5.document.getElementById('adjReqBadge');
  t('대기와 내 결과가 함께면 합쳐서(2 + 1 = 3 · 빨강) · 말풍선에 둘 다', f1.textContent === '3' && !f1.style.background && /승인 대기 2건/.test(f1.title) && /내 재고 조정 요청 결과 1건/.test(f1.title), f1.title);
  await sleep(30); w5.close();
  let w6 = await mkW({ result: 'OK', adjMine: 0 }); w6.document.getElementById('panel-stockAdj').classList.add('show');
  w6.__resp = { result: 'OK', adjMine: 1, adjMineList: [A1] }; w6.konetEmpBadge(); await sleep(60);
  t('재고 일괄조정 화면을 보고 있으면 알림 없이 배지만', w6.document.getElementById('adjReqBadge').textContent === '1' && !w6.__toasts.length);
  await sleep(30); w6.close();
  let w7 = await mkW({ result: 'OK', adjMine: 0 });
  w7.__resp = { result: 'OK', adjMine: 1, adjMineList: [{ reqSeq: 9, statGb: 'A' }] }; w7.konetEmpBadge(); await sleep(60);
  t('서버가 상품명을 안 주면(옛 서버) 종전 글 그대로 — 「요청 #9 이 승인됐습니다」', w7.__toasts.length === 1 && /요청 #9 이 승인됐습니다/.test(w7.__toasts[0]), w7.__toasts.join('|'));
  t('컨트롤러 — 배지 응답은 조정 줄(payload)을 떼고 첫 상품명(itemNm)만', /Object pl = row\.remove\("payload"\);\s*row\.put\("itemNm", adjReqFirstNm\(/.test(ctl));
  await sleep(30); w7.close();
  await sleep(40); w.close(); w2.close();
  console.log((bad ? '✗' : '✓') + ' sim_adjReqBadge : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
