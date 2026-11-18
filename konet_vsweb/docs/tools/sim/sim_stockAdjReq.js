/* 재고 일괄조정 — 승인 요청(직원 = 요청 · 총괄관리자/부관리자 = 승인) 시뮬 (2026-11-18)
   prod/stockAdj.jsp 를 통째로 jsdom 에 올리고, fetch 를 «서버 규칙을 본뜬» 가짜로 바꿔 돌린다
   (가짜 서버 = 관리자면 바로 저장 · 아니면 요청으로 쌓기 · 승인하면 그때 재고 반영 — UserController.stockAdjSave/stockAdjReqAct 와 같은 갈래).
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_stockAdjReq.js */
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

/* ── 가짜 서버 ── */
function makeServer(o){
  const S = { admin: !!o.admin, me: o.me, reqOk: o.reqOk !== false, stock: { 11: 100, 12: 50, 13: 7 }, reqs: o.reqs || [], his: [], calls: [], seq: (o.reqs||[]).length };
  const prods = [ { prodSeq: 11, prodCd: '9904010001', prodNm: '종이컵 13oz', spec: '1000입', packQty: 10 }, { prodSeq: 12, prodCd: '9904010002', prodNm: '뚜껑 92파이', spec: '', packQty: 1 }, { prodSeq: 13, prodCd: '9904010003', prodNm: '빨대 일자', spec: '', packQty: 1 } ];
  const diffOf = (r) => { const p = (+r.packQty||0) < 1 ? 1 : +r.packQty; return (+r.aftBox||0) * p + (+r.aftEa||0) - (+r.befQty||0); };
  const apply = (rows) => { let n = 0; rows.forEach(r => { const d = diffOf(r); if (!d) return; S.stock[r.prodSeq] += d; n++; }); return n; };
  S.fetch = function(url, opt){
    const body = (opt && opt.body) || ''; const json = (v) => Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(v), text: () => Promise.resolve(JSON.stringify(v)) });
    S.calls.push({ url, body });
    if (url === '/prod/whList.do') return json({ data: [ { whCd: 'WH1', whNm: '제1창고', defaultYn: 'Y' } ] });
    if (url === '/prod/prodList.do') return json({ data: prods });
    if (url === '/prod/extItemList.do') return json({ data: [] });
    if (url === '/prod/stockAdjList.do') return json({ data: prods.map(p => { const q = S.stock[p.prodSeq]; return Object.assign({}, p, { curQty: q, boxQty: Math.floor(q / p.packQty), eaQty: q % p.packQty }); }) });
    if (url === '/prod/packQtySave.do') return json({ result: 'OK', cnt: JSON.parse(body).rows.length });
    if (url === '/prod/stockAdjHisList.do') return json({ data: S.his });
    if (url === '/prod/stockAdjReqList.do'){
      if (!S.reqOk) return Promise.resolve({ ok: false, status: 404, json: () => Promise.reject(new Error('x')) });
      const pend = /pendOnly=Y/.test(body);
      return json({ result: 'OK', admin: S.admin ? 'Y' : 'N', me: S.me, mine: S.mineOk === false ? undefined : S.reqs.filter(q => q.reqUser === S.me && !q.seen && (q.statGb === 'A' || q.statGb === 'R' || (q.statGb === 'C' && q.apprUser !== q.reqUser))), data: S.reqs.filter(q => !pend || q.statGb === 'P').slice().sort((a, b) => (a.statGb === 'P' ? 0 : 1) - (b.statGb === 'P' ? 0 : 1) || b.reqSeq - a.reqSeq) });
    }
    if (url === '/prod/stockAdjSave.do'){
      const b = JSON.parse(body);
      if (S.admin){ const n = apply(b.rows); S.his.push({ batchNo: 'ADJ1' }); return json({ result: 'OK', cnt: n, batchNo: 'ADJ1' }); }
      const live = b.rows.filter(r => diffOf(r) !== 0);
      const q = { reqSeq: ++S.seq, baseDt: String(b.baseDt).replace(/-/g, ''), whCd: b.whCd, whNm: '제1창고', remark: b.remark, itemCnt: live.length, diffSum: live.reduce((a, r) => a + diffOf(r), 0),
                  payload: JSON.stringify(b.rows), src: b.src, statGb: 'P', reqUser: S.me, reqUserNm: '김직원', reqDttm: '2026-11-18 10:00:00', apprUser: '', apprUserNm: '', apprDttm: '', apprMemo: '', batchNo: '' };
      S.reqs.push(q);
      return json({ result: 'REQ', reqSeq: q.reqSeq, cnt: live.length, message: '승인 요청으로 올렸습니다' });
    }
    if (url === '/prod/stockAdjReqAct.do'){
      const b = JSON.parse(body), q = S.reqs.find(x => x.reqSeq === b.reqSeq);
      if (!q || q.statGb !== 'P') return json({ result: 'FAIL', message: '이미 처리된 요청입니다 — 목록을 다시 읽어 주세요.' });
      if (b.act === 'C' ? !(S.admin || q.reqUser === S.me) : !S.admin) return json({ result: 'FAIL', message: '총괄관리자·부관리자만 승인·반려할 수 있습니다.' });
      if (b.act === 'R' && !b.memo) return json({ result: 'FAIL', message: '반려 사유를 적어 주세요.' });
      q.statGb = b.act; q.apprUser = S.me; q.apprUserNm = '마스터'; q.apprDttm = '2026-11-18 11:00:00'; q.apprMemo = b.memo || '';
      if (b.act !== 'A') return json({ result: 'OK', statGb: b.act });
      const n = apply(JSON.parse(q.payload)); q.batchNo = 'ADJ9'; S.his.push({ batchNo: 'ADJ9' });
      return json({ result: 'OK', statGb: 'A', cnt: n, batchNo: 'ADJ9' });
    }
    if (url === '/prod/stockAdjReqSeen.do'){ let n = 0; S.reqs.forEach(q => { if (q.reqUser === S.me && !q.seen && q.statGb !== 'P'){ q.seen = true; n++; } }); return json({ result: 'OK', cnt: n }); }
    return json({});
  };
  return S;
}
async function open(S){
  const dom = new JSDOM(html, { url: 'http://localhost:9071/prod/stockAdj.do', runScripts: 'dangerously', pretendToBeVisual: true, beforeParse(w){
    w.fetch = S.fetch;
    w._alertBox = function(m){ w.__alerts = (w.__alerts||[]).concat([String(m)]); };
    w._confirmBox = function(o){ w.__confirms = (w.__confirms||[]).concat([o]); if (w.__autoOk !== false && o.onOk) o.onOk(); };
    w._toast = function(m){ w.__toasts = (w.__toasts||[]).concat([String(m)]); };
    w.__alerts = []; w.__confirms = []; w.__toasts = [];
  } });
  await sleep(60);
  return dom.window;
}
const rowsOf = (w) => [...w.document.querySelectorAll('#reqBody tr.rq-h')];
const idxOf = (w, cd) => w.eval('ROWS').findIndex(r => r.prodCd === cd);
const setRow = (w, cd, box, ea) => { const i = idxOf(w, cd); w.document.getElementById('bx' + i).value = box; w.document.getElementById('ea' + i).value = ea; };

(async () => {
  /* ═══ 1. 직원 : [수정저장] → 승인 요청(재고 그대로) ═══ */
  const S1 = makeServer({ admin: false, me: 'K002' });
  let w = await open(S1), d = w.document;
  t('직원 화면 — 저장 단추 이름이 「승인 요청」', d.getElementById('btnSave').textContent === '승인 요청', d.getElementById('btnSave').textContent);
  t('승인 요청 상자가 보이고(대기 없음 = 표는 접힘) 안내', d.getElementById('reqBox').style.display !== 'none' && d.getElementById('reqBox').classList.contains('none') && /대기 중인 요청이 없습니다/.test(d.getElementById('reqHint').textContent));
  t('목록 3줄이 그려졌다', w.eval('ROWS.length') === 3);
  setRow(w, '9904010001', 9, 5);        /* 100 → 95  (-5) */
  setRow(w, '9904010002', 60, 0);       /* 50 → 60   (+10) */
  w.save(); await sleep(60);
  const cf = w.__confirms[0];
  t('확인창 — 「승인 요청합니다」 문구 · 단추 「승인 요청」', cf && /승인 요청<\/b>합니다/.test(cf.msg) && cf.okText === '승인 요청' && /승인해야 재고에 반영/.test(cf.msg), cf && cf.okText);
  const sv = S1.calls.filter(c => c.url === '/prod/stockAdjSave.do')[0];
  t('저장 요청 본문 — 고친 2줄 · 품명 · src stockAdj', (() => { const b = sv && JSON.parse(sv.body); return b && b.rows.length === 2 && b.src === 'stockAdj' && b.rows[0].prodNm === '종이컵 13oz' && b.whCd === 'WH1'; })());
  t('★재고는 그대로(100 · 50) — 요청만 쌓였다', S1.stock[11] === 100 && S1.stock[12] === 50 && S1.reqs.length === 1 && S1.reqs[0].statGb === 'P');
  t('알림 — 「재고 2건 승인 요청 · 아직 바뀌지 않았습니다」', w.__alerts.some(m => /재고 2건 <b>승인 요청<\/b>/.test(m) && /아직 바뀌지 않았습니다/.test(m)), w.__alerts.join(' | '));
  let rs = rowsOf(w);
  t('요청 목록에 한 줄 — #1 · 승인 대기 · 2건 · 증감 합 +5', rs.length === 1 && /#1/.test(rs[0].textContent) && /승인 대기/.test(rs[0].textContent) && /2건/.test(rs[0].textContent) && /\+5/.test(rs[0].textContent), rs[0] && rs[0].textContent);
  t('머리 「1건 대기」 · 주황 탭', /1건 대기/.test(d.getElementById('reqCnt').textContent) && d.getElementById('reqTab').classList.contains('pend'));
  t('직원에게는 승인·반려 단추가 없고 제 요청의 [요청 취소]만', !rs[0].querySelector('.rq-ok') && !rs[0].querySelector('.rq-no') && !!rs[0].querySelector('.rq-cx'));
  t('다시 그린 목록의 수정칸은 원래 재고(요청은 재고를 안 바꿨다)', d.getElementById('bx' + idxOf(w, '9904010001')).value === '10' && d.getElementById('ea' + idxOf(w, '9904010001')).value === '0');
  /* 줄 펼치기 */
  /* ★승인 요청 표 = 상품이 보이는 그리드 (2026-11-18 「승인 입장도 이런 형태로」) — 누르지 않아도 요청마다 상품 한 줄씩 */
  const hd = [...d.querySelectorAll('#reqWrap > table > thead th')].map(e => e.textContent.trim());
  t('머리글 12칸 — 번호·상태·상품코드·상품명·전·후·증감·사유·기준일자·요청·처리·작업', hd.length === 12 && /^번호\|상태\|상품코드\|상품명\|전\|후\|증감\|사유\|기준일자 · 창고\|요청\|처리\|작업$/.test(hd.join('|')), hd.join('|'));
  const all = [...d.querySelectorAll('#reqBody tr')], c = (r, n) => r.children[n] ? r.children[n].textContent.replace(/\s+/g, ' ').trim() : '';
  t('요청 #1 = 두 줄(상품 2개) — 첫 줄 12칸 · 둘째 줄 5칸 · 요청 칸은 rowspan 2', all.length === 2 && all[0].children.length === 12 && all[1].children.length === 5 && all[1].classList.contains('rq-i')
     && [0, 1, 7, 8, 9, 10, 11].every(n => all[0].children[n].getAttribute('rowspan') === '2') && [2, 3, 4, 5, 6].every(n => !all[0].children[n].getAttribute('rowspan')), all.length + '/' + (all[0] && all[0].children.length));
  t('★상품이 바로 보인다 — 종이컵 100 → 95 (-5) · 뚜껑 50 → 60 (+10)', c(all[0], 2) === '9904010001' && c(all[0], 3) === '종이컵 13oz' && c(all[0], 4) === '100' && c(all[0], 5) === '95' && c(all[0], 6) === '-5'
     && c(all[1], 0) === '9904010002' && c(all[1], 2) === '50' && c(all[1], 3) === '60' && c(all[1], 4) === '+10', all.map(r => r.textContent.replace(/\s+/g, ' ')).join(' || ').slice(0, 220));
  t('작업 칸은 오른쪽에 붙는다(rq-act) · 줄을 눌러 펼치는 방식은 없다', all[0].children[11].classList.contains('rq-act') && d.querySelector('#reqWrap thead th.rq-act') && !all[0].getAttribute('onclick') && !d.querySelector('#reqBody tr.rq-d') && typeof w.reqOpen === 'undefined');
  /* 같은 품목을 또 올리려 하면 경고 */
  w.__confirms.length = 0; w.__autoOk = false;
  setRow(w, '9904010001', 9, 0); w.save(); await sleep(30);
  t('★대기 중인 품목을 또 올리면 확인창에 「두 번 반영」 경고', w.__confirms[0] && /승인 대기 중<\/b>인 품목 1개/.test(w.__confirms[0].msg) && /두 번/.test(w.__confirms[0].msg), w.__confirms[0] && w.__confirms[0].msg.slice(-200));
  w.__autoOk = true;
  /* 직원이 억지로 승인 → 서버가 거절 */
  w.__alerts.length = 0; w.reqAct(1, 'A'); await sleep(40);
  t('직원이 승인을 보내도 서버가 거절 · 재고 그대로', w.__alerts.some(m => /총괄관리자·부관리자만/.test(m)) && S1.stock[11] === 100 && S1.reqs[0].statGb === 'P', w.__alerts.join(' | '));
  /* 요청 취소 */
  w.__confirms.length = 0; w.reqAct(1, 'C'); await sleep(40);
  t('[요청 취소] — 확인창 뒤 취소 · 재고 그대로 · 대기 목록에서 사라짐', w.__confirms.length === 1 && S1.reqs[0].statGb === 'C' && S1.stock[11] === 100 && rowsOf(w).length === 0 && d.getElementById('reqCnt').textContent === '');
  d.getElementById('reqAll').checked = true; w.reqLoad(); await sleep(30);
  t('「끝난 요청도」를 켜면 취소한 요청이 보인다', rowsOf(w).length === 1 && /요청 취소/.test(rowsOf(w)[0].textContent));
  w.close();

  /* ═══ 2. 관리자 : 직원 요청을 승인 → 그때 재고 반영 ═══ */
  const pay = [ { prodSeq: 11, prodCd: '9904010001', prodNm: '종이컵 13oz', packQty: 10, befQty: 100, befBox: 10, befEa: 0, aftBox: 9, aftEa: 5 }, { prodSeq: 12, prodCd: '9904010002', prodNm: '뚜껑 92파이', packQty: 1, befQty: 50, befBox: 50, befEa: 0, aftBox: 60, aftEa: 0 } ];
  const mkReq = (n, st) => ({ reqSeq: n, baseDt: '20261118', whCd: 'WH1', whNm: '제1창고', remark: '실사', itemCnt: 2, diffSum: 5, payload: JSON.stringify(pay), src: 'stockAdj', statGb: st, reqUser: 'K002', reqUserNm: '김직원', reqDttm: '2026-11-18 10:00:00', apprUser: '', apprUserNm: '', apprDttm: '', apprMemo: '', batchNo: '' });
  const S2 = makeServer({ admin: true, me: 'admin', reqs: [ mkReq(1, 'P'), mkReq(2, 'P') ] });
  w = await open(S2); d = w.document;
  t('관리자 화면 — 저장 단추는 「수정저장」 그대로', d.getElementById('btnSave').textContent === '수정저장');
  rs = rowsOf(w);
  t('대기 2건이 보이고 줄마다 [✔ 승인][✖ 반려] (남의 요청이라 취소 단추는 없음)', rs.length === 2 && rs.every(r => r.querySelector('.rq-ok') && r.querySelector('.rq-no') && !r.querySelector('.rq-cx')) && /2건 대기/.test(d.getElementById('reqCnt').textContent));
  w.__confirms.length = 0; w.reqAct(2, 'A'); await sleep(60);
  t('승인 확인창 — 요청 번호·요청자·증감 · 「재고에 바로 반영」', w.__confirms[0] && /#2/.test(w.__confirms[0].msg) && /김직원/.test(w.__confirms[0].msg) && /재고에 바로 반영/.test(w.__confirms[0].msg) && w.__confirms[0].okText === '승인');
  t('★승인하면 그때 재고 반영 — 100 → 95 · 50 → 60', S2.stock[11] === 95 && S2.stock[12] === 60 && S2.reqs.find(q => q.reqSeq === 2).statGb === 'A');
  t('승인 알림 「재고 2건 반영」 · 대기 1건으로', w.__toasts.some(m => /승인했습니다 — 재고 2건 반영/.test(m)) && rowsOf(w).length === 1 && /1건 대기/.test(d.getElementById('reqCnt').textContent));
  t('위 목록도 바뀐 재고로 다시 그렸다(수정칸 9 · 5)', d.getElementById('bx' + idxOf(w, '9904010001')).value === '9' && d.getElementById('ea' + idxOf(w, '9904010001')).value === '5');
  /* 반려 — 사유 창 */
  w.reqAct(1, 'R'); await sleep(20);
  const why = d.getElementById('_rqWhy');
  t('[✖ 반려] = 사유를 받는 창이 뜬다(브라우저 prompt 아님)', !!why);
  d.getElementById('_rqOk').onclick(); await sleep(20);
  t('사유가 비면 안 보낸다', !S2.calls.some(c => c.url === '/prod/stockAdjReqAct.do' && JSON.parse(c.body).act === 'R') && !!d.getElementById('_rqWhy'));
  why.value = '수량 다시 세어 주세요'; d.getElementById('_rqOk').onclick(); await sleep(50);
  const rj = S2.calls.filter(c => c.url === '/prod/stockAdjReqAct.do').map(c => JSON.parse(c.body)).find(b => b.act === 'R');
  t('★반려 — 사유와 함께 전송 · 재고 그대로(95) · 대기 0', rj && rj.memo === '수량 다시 세어 주세요' && S2.stock[11] === 95 && S2.reqs.find(q => q.reqSeq === 1).statGb === 'R' && rowsOf(w).length === 0);
  d.getElementById('reqAll').checked = true; w.reqLoad(); await sleep(30);
  t('끝난 요청 보기 — 승인(묶음 번호)·반려(사유)가 처리 칸에', (() => { const x = rowsOf(w).map(r => r.textContent).join(' | '); return /ADJ9/.test(x) && /수량 다시 세어 주세요/.test(x) && /마스터/.test(x); })(), rowsOf(w).map(r => r.textContent).join(' | ').slice(0, 300));
  t('끝난 요청에는 작업 단추가 없다', rowsOf(w).every(r => !r.querySelector('button')));
  /* 관리자의 직접 저장은 바로 반영 */
  w.__confirms.length = 0; w.__toasts.length = 0;
  setRow(w, '9904010003', 9, 0);        /* 7 → 9 */
  w.save(); await sleep(60);
  t('★관리자가 직접 [수정저장] = 요청 없이 바로 반영(7 → 9) · 확인창 단추 「저장」', S2.stock[13] === 9 && S2.reqs.length === 2 && w.__confirms[0] && w.__confirms[0].okText === '저장' && !/승인 요청/.test(w.__confirms[0].msg));
  t('저장 알림은 종전 문구', w.__toasts.some(m => /재고 1건 저장했습니다/.test(m)), w.__toasts.join(' | '));
  /* 이미 처리된 요청을 또 승인 */
  w.__alerts.length = 0; w.eval("_req.list.push(" + JSON.stringify(mkReq(2, 'P')) + ")"); w.reqAct(2, 'A'); await sleep(50);
  t('이미 처리된 요청을 다시 승인하면 서버가 거절(재고 한 번만)', w.__alerts.some(m => /이미 처리된 요청/.test(m)) && S2.stock[11] === 95);
  /* 접기 */
  w.reqFold();
  t('탭을 누르면 접힌다', d.getElementById('reqBox').classList.contains('off'));
  w.close();

  /* ═══ 3. 옛 서버(요청 주소 없음) — 종전 화면 그대로 ═══ */
  const S3 = makeServer({ admin: false, me: 'K002', reqOk: false });
  w = await open(S3); d = w.document;
  t('요청 목록을 못 받으면 상자는 숨고 단추는 「수정저장」', d.getElementById('reqBox').style.display === 'none' && d.getElementById('btnSave').textContent === '수정저장');
  w.close();

  /* ═══ 4. 상품코드등록 수정 창 — 같은 주소를 쓰므로 REQ 를 안다 ═══ */
  const P = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/prod/prodcd.jsp'), 'utf8');
  t('prodcd.jsp — src:prodcd 를 보내고 REQ 응답이면 「승인 요청」 알림', /src:'prodcd'/.test(P) && /d&&d\.result==='REQ'/.test(P) && /재고 조정\('\+\(stkDiff>0\?'\+':''\)\+stkDiff\+'\)은 승인 요청/.test(P));
  /* ═══ 5. 서버 소스 갈래 ═══ */
  const C = fs.readFileSync(path.join(ROOT, 'src/main/java/egovframework/konet/user/web/UserController.java'), 'utf8');
  t('컨트롤러 — 관리자가 아니면 saveStockAdjBatch 앞에서 요청으로 돌린다', (() => { const i = C.indexOf('if (!empAdmin(session)) {\r\n\t\t\t\t\tint cnt = 0, dsum = 0;'), j = C.indexOf('int n = svc.saveStockAdjBatch(head, rows);'); return i > 0 && j > i && C.slice(i, j).indexOf('svc.insertStockAdjReq(rq);') > 0 && C.slice(i, j).indexOf('return response;') > 0; })());
  t('컨트롤러 — 승인은 P→A 를 먼저 잡고(중복 승인 방지) 실패하면 P 로 되돌린다', /up\.put\("fromStat", "P"\)/.test(C) && /back\.put\("fromStat", "A"\); back\.put\("statGb", "P"\)/.test(C));
  /* ═══ 6. 요청한 직원에게 결과 알림 — 「내 요청 결과」 띠 · [확인했습니다] (2026-11-18) ═══ */
  {
    const mk = (n, st, memo, by) => ({ reqSeq: n, baseDt: '20261118', whCd: 'WH1', whNm: '제1창고', remark: n === 1 ? '실사' : '파손', itemCnt: n, diffSum: n === 1 ? 5 : -12, payload: '[]', src: 'stockAdj', statGb: st,
      reqUser: 'K002', reqUserNm: '김직원', reqDttm: '2026-11-18 10:00:00', apprUser: by || 'admin', apprUserNm: by === 'K002' ? '김직원' : '마스터', apprDttm: '2026-11-18 11:0' + n + ':00', apprMemo: memo || '', batchNo: st === 'A' ? 'ADJ9' : '' });
    const S6 = makeServer({ admin: false, me: 'K002', reqs: [ mk(1, 'A'), mk(2, 'R', '사진 첨부 후 다시'), mk(3, 'C', '', 'K002'), mk(4, 'P') ] });
    let w6 = await open(S6), d6 = w6.document, m6 = d6.getElementById('reqMine');
    t('★직원 화면 — 「내 요청 결과 2건」 띠가 보인다(내가 스스로 취소한 #3 · 대기 #4 는 빠짐)', m6.style.display !== 'none' && /내 요청 결과 2건/.test(m6.textContent) && m6.querySelectorAll('tr.rm-first').length === 2, m6.textContent.slice(0, 60));
    const its = [...m6.querySelectorAll('tr.rm-first')].map(e => e.textContent.replace(/\s+/g, ' '));
    t('승인 줄 — 「#1 승인 · 재고에 반영됨 · 마스터 · 묶음」', its.some(x => /#1.*승인/.test(x) && /재고 반영/.test(x) && /마스터/.test(x) && /ADJ9/.test(x)), its.join(' | '));
    t('반려 줄 — 「#2 반려 · 사유 : 사진 첨부 후 다시」(빨간 띠)', its.some(x => /#2.*반려/.test(x) && /사진 첨부 후 다시/.test(x) && /재고 반영 안 됨/.test(x)) && m6.classList.contains('rej'), its.join(' | '));
    t('「끝난 요청도」를 안 켜도 띠는 보인다(표에는 대기 #4 한 줄뿐)', !d6.getElementById('reqAll').checked && rowsOf(w6).length === 1 && /#4/.test(rowsOf(w6)[0].textContent));
    const btn6 = m6.querySelector('button');
    t('[확인했습니다] 단추', btn6 && /확인했습니다/.test(btn6.textContent));
    w6.__badge = 0; w6.reqBadge = function(){ w6.__badge++; };
    btn6.click(); await sleep(60);
    t('★[확인했습니다] — 서버에 확인 요청 · 띠가 사라진다 · 셸 배지 갱신 호출', S6.calls.some(c => c.url === '/prod/stockAdjReqSeen.do') && d6.getElementById('reqMine').style.display === 'none' && S6.reqs[0].seen && S6.reqs[1].seen && w6.__badge === 1, d6.getElementById('reqMine').style.display + '/' + w6.__badge);
    t('확인해도 요청 기록은 남는다(상태 그대로 · 대기 #4 는 안 건드림)', S6.reqs[0].statGb === 'A' && S6.reqs[1].statGb === 'R' && !S6.reqs[3].seen);
    w6.reqLoad(); await sleep(40);
    t('다시 읽어도 띠는 안 나온다', d6.getElementById('reqMine').style.display === 'none');
    await sleep(40); w6.close();
    /* 전부 승인이면 초록 띠 · 관리자가 대신 취소한 것은 알린다 */
    const S7 = makeServer({ admin: false, me: 'K002', reqs: [ mk(1, 'A'), mk(2, 'C', '', 'admin') ] });
    let w7 = await open(S7), m7 = w7.document.getElementById('reqMine');
    t('관리자가 취소한 내 요청도 알린다(「#2 취소(관리자)」)', /#2.*취소\(관리자\)/.test(m7.textContent) && m7.classList.contains('rej'), m7.textContent.slice(0, 80));
    await sleep(40); w7.close();
    const S8 = makeServer({ admin: false, me: 'K002', reqs: [ mk(1, 'A') ] });
    let w8 = await open(S8), m8 = w8.document.getElementById('reqMine');
    t('전부 승인이면 초록 띠(「승인된 요청은 재고에 반영됐습니다」)', !m8.classList.contains('rej') && /재고에 반영됐습니다/.test(m8.textContent));
    await sleep(40); w8.close();
    /* 관리자 화면 · 옛 서버(mine 칸 없음) */
    const S9 = makeServer({ admin: true, me: 'admin', reqs: [ mk(1, 'A'), mk(2, 'R', 'x') ] });
    let w9 = await open(S9);
    t('남의 요청 결과는 띠에 안 나온다(관리자 화면)', w9.document.getElementById('reqMine').style.display === 'none');
    await sleep(40); w9.close();
    const S10 = makeServer({ admin: false, me: 'K002', reqs: [ mk(1, 'A') ] }); S10.mineOk = false;
    let w10 = await open(S10);
    t('서버가 mine 을 안 주면(칸 없는 DB · 옛 서버) 띠 없이 종전대로', w10.document.getElementById('reqMine').style.display === 'none' && w10.document.getElementById('reqBox').style.display !== 'none');
    await sleep(40); w10.close();
    /* ── 어떤 상품인지 — 표(그리드) + 스크롤 (2026-11-18 「어떤 상품이 반려 승인 됐는지 표시」·「그리드 형태로 · 스크롤되게」) ── */
    {
      const pA = JSON.stringify([ { prodSeq: 11, prodCd: '9904010001', prodNm: '종이컵 13oz', packQty: 10, befQty: 100, befBox: 10, befEa: 0, aftBox: 9, aftEa: 5 },
                                  { prodSeq: 13, prodCd: '9904010003', prodNm: '빨대 일자', packQty: 1, befQty: 7, befBox: 7, befEa: 0, aftBox: 7, aftEa: 0 },      /* 증감 0 — 안 보인다 */
                                  { prodSeq: 12, prodCd: '9904010002', prodNm: '뚜껑 <92>', packQty: 1, befQty: 50, befBox: 50, befEa: 0, aftBox: 60, aftEa: 0 } ]);
      const pR = JSON.stringify([ { prodSeq: 13, prodCd: '9904010003', prodNm: '빨대 일자', packQty: 1, befQty: 7, befBox: 7, befEa: 0, aftBox: 2, aftEa: 0 } ]);
      const a1 = mk(1, 'A'), r2 = mk(2, 'R', '수량 다시 세기'), e3 = mk(3, 'A'); a1.payload = pA; r2.payload = pR;
      const S11 = makeServer({ admin: false, me: 'K002', reqs: [ a1, r2, e3 ] });
      let w11 = await open(S11), g = w11.document.querySelector('#reqMine .rm-grid'), rows = g ? [...g.querySelectorAll('tbody tr')] : [];
      t('★결과가 표(그리드)로 — 머리글 10칸 · 줄 = 상품 수(2 + 1 + 내역 없는 요청 1)', g && g.querySelectorAll('thead th').length === 10 && rows.length === 4, rows.length);
      const heads = [...(g ? g.querySelectorAll('thead th') : [])].map(e => e.textContent).join('|');
      t('머리글 — 번호·결과·상품코드·상품명·전·후·증감·요청 사유·처리·반려 사유', /번호\|결과\|상품코드\|상품명\|전\|후\|증감\|요청 사유\|처리\|반려 사유/.test(heads), heads);
      const rA = rows.filter(r => r.classList.contains('A')), rR = rows.filter(r => r.classList.contains('R'));
      const cell = (r, i) => r.children[i] ? r.children[i].textContent.trim() : '';
      t('승인 #... 의 첫 줄 — 요청 칸들이 상품 수만큼 세로로 묶인다(rowspan 2) · 첫 줄 10칸 / 둘째 줄 5칸', (() => { const f = rows.find(r => r.classList.contains('rm-first') && /#1/.test(cell(r, 0))); const nx = f && f.nextElementSibling;
        return f && f.children.length === 10 && f.children[0].getAttribute('rowspan') === '2' && f.children[1].getAttribute('rowspan') === '2' && f.children[9].getAttribute('rowspan') === '2' && nx && nx.children.length === 5 && !nx.classList.contains('rm-first'); })());
      const f1 = rows.find(r => r.classList.contains('rm-first') && /#1/.test(cell(r, 0)));
      t('★승인된 상품 — 코드 · 이름 · 전 100 → 후 95 · 증감 -5', f1 && cell(f1, 2) === '9904010001' && cell(f1, 3) === '종이컵 13oz' && cell(f1, 4) === '100' && cell(f1, 5) === '95' && cell(f1, 6) === '-5', f1 && f1.textContent.replace(/\s+/g, ' ').slice(0, 80));
      const n1 = f1 && f1.nextElementSibling;
      t('둘째 상품 — 뚜껑 50 → 60 · +10 (이름의 < > 는 글자 그대로) · 증감 0 인 빨대는 안 나온다', n1 && cell(n1, 0) === '9904010002' && cell(n1, 1) === '뚜껑 <92>' && cell(n1, 4) === '+10' && !rA.some(r => /9904010003/.test(r.textContent)), n1 && n1.textContent);
      const f2 = rows.find(r => r.classList.contains('rm-first') && /#2/.test(cell(r, 0)));
      t('★반려된 상품 — 빨대 7 → 2 · -5 · 사유 「수량 다시 세기」 · 재고 반영 안 됨', f2 && cell(f2, 2) === '9904010003' && cell(f2, 4) === '7' && cell(f2, 5) === '2' && cell(f2, 6) === '-5' && /수량 다시 세기/.test(cell(f2, 9)) && /재고 반영 안 됨/.test(cell(f2, 9)) && !f2.children[0].getAttribute('rowspan') && rR.length === 1, f2 && f2.textContent.replace(/\s+/g, ' '));
      const f3 = rows.find(r => r.classList.contains('rm-first') && /#3/.test(cell(r, 0)));
      t('상품 내역이 없는 요청(옛 자료)도 한 줄 — 「(상품 내역 없음)」 · 10칸', f3 && f3.children.length === 10 && /상품 내역 없음/.test(f3.textContent));
      t('머리줄에 「상품 3개」', /상품 3개/.test(w11.document.querySelector('#reqMine .rm-hd').textContent));
      t('★스크롤 — 표 상자에 높이 상한 + overflow:auto(내용이 많으면 그 안에서 굴린다)', /#reqMine \.rm-grid\{ max-height:min\(26vh, 200px\); overflow:auto;/.test(src));
      await sleep(40); w11.close();
    }
    t('컨트롤러 — 확인 엔드포인트 · 목록 응답의 mine · 배지의 adjMine(각각 따로 잡는다)', /stockAdjReqSeen\.do/.test(C) && /response\.put\("mine", svc\.selectStockAdjReqMine\(q2\)\)/.test(C) && /r\.put\("adjMine", mn\)/.test(C) && /empBadge adjMine ERROR/.test(C));
  }
  /* ═══ 7. 승인하는 사람의 표 — 상품 그리드 (2026-11-18 「승인 입장도 이런 형태로 보여줘요」) ═══ */
  {
    const pay7 = JSON.stringify([ { prodSeq: 11, prodCd: '9904010001', prodNm: '종이컵 13oz', packQty: 10, befQty: 100, befBox: 10, befEa: 0, aftBox: 9, aftEa: 5 },
                                  { prodSeq: 12, prodCd: '9904010002', prodNm: '뚜껑 92파이', packQty: 1, befQty: 50, befBox: 50, befEa: 0, aftBox: 60, aftEa: 0 },
                                  { prodSeq: 13, prodCd: '9904010003', prodNm: '빨대 일자', packQty: 1, befQty: 7, befBox: 7, befEa: 0, aftBox: 4, aftEa: 0 } ]);
    const q = (n, st, pl) => ({ reqSeq: n, baseDt: '20261118', whCd: 'WH1', whNm: '제1창고', remark: '실사 ' + n, itemCnt: 3, diffSum: 2, payload: pl, src: 'stockAdj', statGb: st, reqUser: 'K002', reqUserNm: '김직원',
      reqDttm: '2026-11-18 10:00:00', apprUser: st === 'P' ? '' : 'admin', apprUserNm: st === 'P' ? '' : '마스터', apprDttm: st === 'P' ? '' : '2026-11-18 11:00:00', apprMemo: st === 'R' ? '다시 세기' : '', batchNo: '' });
    const S7 = makeServer({ admin: true, me: 'admin', reqs: [ q(1, 'P', pay7), q(2, 'P', '[]'), q(3, 'R', pay7) ] });
    let w7 = await open(S7), d7 = w7.document; d7.getElementById('reqAll').checked = true; w7.reqLoad(); await sleep(50);
    const R = [...d7.querySelectorAll('#reqBody tr')], hs = R.filter(r => r.classList.contains('rq-h')), cc = (r, n) => r.children[n] ? r.children[n].textContent.replace(/\s+/g, ' ').trim() : '';
    t('★관리자 표 — 요청 3건 = 줄 7(상품 3 + 내역 없음 1 + 상품 3)', hs.length === 3 && R.length === 7, R.length + '/' + hs.length);
    const h1 = hs.find(r => /#1/.test(cc(r, 0)));
    t('승인할 요청의 상품이 바로 보인다 — 3줄 · 전/후/증감 · 「3건 · 합 +2」', h1 && h1.children[0].getAttribute('rowspan') === '3' && cc(h1, 2) === '9904010001' && cc(h1, 6) === '-5' && /3건 · 합 \+2/.test(cc(h1, 1))
       && cc(h1.nextElementSibling, 4) === '+10' && cc(h1.nextElementSibling.nextElementSibling, 0) === '9904010003' && cc(h1.nextElementSibling.nextElementSibling, 4) === '-3', h1 && h1.textContent.replace(/\s+/g, ' ').slice(0, 120));
    t('[✔ 승인][✖ 반려] 는 그 요청의 첫 줄 작업 칸(세로로 묶임)', h1 && h1.querySelector('td.rq-act .rq-ok') && h1.querySelector('td.rq-act .rq-no') && h1.querySelector('td.rq-act').getAttribute('rowspan') === '3' && !h1.nextElementSibling.querySelector('button'));
    const h2 = hs.find(r => /#2/.test(cc(r, 0)));
    t('상품 내역이 없는 요청 — 한 줄 12칸 「(상품 내역 없음)」 · 단추는 그대로', h2 && h2.children.length === 12 && /상품 내역 없음/.test(h2.textContent) && h2.querySelector('.rq-ok') && !h2.children[0].getAttribute('rowspan'));
    const h3 = hs.find(r => /#3/.test(cc(r, 0)));
    t('끝난 요청(반려)도 같은 꼴 — 처리 칸에 처리자 · 사유 · 단추 없음', h3 && /마스터/.test(cc(h3, 10)) && /다시 세기/.test(cc(h3, 10)) && !h3.querySelector('button') && h3.classList.contains('R'));
    t('안내 글 — 「승인하면 상품마다 증감만큼 재고에 반영」', /상품마다 증감만큼 재고에 반영/.test(d7.getElementById('reqHint').textContent), d7.getElementById('reqHint').textContent.slice(0, 60));
    h1.querySelector('.rq-ok').click(); await sleep(60);
    t('★표의 [✔ 승인] 단추 → 확인창 → 승인 · 재고 반영(100 → 95 · 50 → 60 · 7 → 4)', S7.reqs[0].statGb === 'A' && S7.stock[11] === 95 && S7.stock[12] === 60 && S7.stock[13] === 4, S7.reqs[0].statGb + '/' + S7.stock[11]);
    t('CSS — 작업 칸 오른쪽 고정(sticky right) · 요청 사이 굵은 선', /#reqBody td\.rq-act\{ position:sticky; right:0;/.test(src) && /tr\.rq-h > td\{ border-top:2px solid/.test(src));
    await sleep(40); w7.close();
  }
  console.log((bad ? '✗ ' : '✓ ') + 'sim_stockAdjReq : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})();
