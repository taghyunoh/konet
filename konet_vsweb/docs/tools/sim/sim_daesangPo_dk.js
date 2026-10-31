// 대상 발주 등록 ▸ [⚠ 중복 점검] 창 (2026-10-31) — 화면 JS 를 jsdom 에 그대로 태운다.
//   돌리는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_daesangPo_dk.js  (jsdom@22)
const fs = require('fs'), path = require('path'), vm = require('vm');
const { JSDOM } = require('jsdom');
let src = fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/daesangPo.jsp'), 'utf8').replace(/\r\n/g, '\n');
src = src.replace(/<%--[\s\S]*?--%>/g, '').replace(/\$\{pageContext\.request\.contextPath\}/g, '').replace(/<%@[^%]*%>/g, '');
const html = src.replace(/<script src="[^"]*"><\/script>/g, '');
const dom = new JSDOM(html, { runScripts: 'outside-only', pretendToBeVisual: true });
const w = dom.window;
let ok = 0, bad = 0; const t = (c, m) => { if (c) ok++; else { bad++; console.log('FAIL', m); } };
// 운영 실측(2026-10-23)을 본뜬 자료 — 대상 발주 1차·11차 겹침 + 대상 판매전표 0002
const LS = [
  { seq: 1, dlvDt: '20261023', dsRound: '10월 1차',  rcvNm: '청라중 선생님',       itemCd: '1010014032', itemNm: '종이컵', qty: 150,  salePrice: 67, uploadDttm: '2026-10-27 19:10:17', regUser: 'admin', rcvAddr: '충남' },
  { seq: 2, dlvDt: '20261023', dsRound: '10월 1차',  rcvNm: '혜인여고 영양선생님', itemCd: '1010014032', itemNm: '종이컵', qty: 100,  salePrice: 62, uploadDttm: '2026-10-27 16:50:36', regUser: 'admin', rcvAddr: '전남' },
  { seq: 3, dlvDt: '20261023', dsRound: '10월 1차',  rcvNm: '혜인여고 영양선생님', itemCd: '6010040023', itemNm: '유산지', qty: 1000, salePrice: 47, uploadDttm: '2026-10-27 16:35:00', regUser: 'admin', rcvAddr: '전남' },
  { seq: 4, dlvDt: '20261023', dsRound: '10월 11차', rcvNm: '청라중 선생님',       itemCd: '1010014032', itemNm: '종이컵', qty: 150,  salePrice: 67, uploadDttm: '2026-10-27 20:27:16', regUser: 'admin', rcvAddr: '충남' },
  { seq: 5, dlvDt: '20261023', dsRound: '10월 11차', rcvNm: '혜인여고 영양선생님', itemCd: '1010014032', itemNm: '종이컵', qty: 1000, salePrice: 62, uploadDttm: '2026-10-27 20:27:16', regUser: 'admin', rcvAddr: '전남' },
  { seq: 6, dlvDt: '20261023', dsRound: '10월 11차', rcvNm: '혜인여고 영양선생님', itemCd: '6010040023', itemNm: '유산지', qty: 1000, salePrice: 47, uploadDttm: '2026-10-27 20:27:16', regUser: 'admin', rcvAddr: '전남' },
  { seq: 7, dlvDt: '20261021', dsRound: '10월 10차', rcvNm: '효문고',             itemCd: '1010014032', itemNm: '종이컵', qty: 500,  salePrice: 67, uploadDttm: '2026-10-21 10:00:00', regUser: 'admin', rcvAddr: '서울' }
];
const TRX = [
  { saleSeq: 91, saleDt: '20261023', saleNo: '0002', custCd: '00177', custNm: '대상 급식', totAmt: 119955, prodCnt: 4 },
  { saleSeq: 92, saleDt: '20261023', saleNo: '0003', custCd: '001565', custNm: '세진유통', totAmt: 50000, prodCnt: 1 },   // 대상 아님 — 안 보여야
  { saleSeq: 93, saleDt: '20261030', saleNo: '0001', custCd: '1',     custNm: '대상주식회사', totAmt: 1000, prodCnt: 1 }   // DC_CD DAESANG 거래처 · 그 날 대상 발주 없음
];
const CALLS = [];
w.fetch = (url, o) => { CALLS.push({ url, body: o && o.body });
  const J = x => Promise.resolve({ ok: true, json: () => Promise.resolve(x), text: () => Promise.resolve(JSON.stringify(x)) });
  if (/clientList/.test(url)) return J({ data: [{ bizCd: 'K0000002', bizNm: '대상주식회사(급식)' }] });
  if (/prodList/.test(url)) return J({ data: [{ prodCd: '1010014032', prodNm: '급식 친환경 종이컵 10oz', salePrice: 54000, spec: '10oz', taxGb: '과세' }, { prodCd: '6010040023', prodNm: '유산지', salePrice: 47, taxGb: '과세' }] });
  if (/extItemList/.test(url)) return J({ data: [] });
  if (/daesangPoMap/.test(url)) return J({ item: {}, price: [], rounds: [] });
  if (/daesangPoFee/.test(url)) return J({ cnt: 0 });
  if (/daesangPoList/.test(url)) return J({ data: w.__LS });
  if (/daesangPoDelete/.test(url)) { const b = JSON.parse(o.body); w.__LS = w.__LS.filter(x => b.seqs.indexOf(x.seq) < 0); return J({ cnt: b.seqs.length }); }
  if (/selectVendorMst/.test(url)) return J({ data: [{ vendorCd: '1', vendorNm: '대상주식회사', dcCd: 'DAESANG' }, { vendorCd: '00177', vendorNm: '대상 급식', dcCd: '' }, { vendorCd: '001565', vendorNm: '세진유통', dcCd: '' }] });
  if (/salesTrxList/.test(url)) return J({ data: w.__TRX });
  if (/salesTrxDelete/.test(url)) { const b = JSON.parse(o.body); w.__TRX = w.__TRX.filter(m => m.saleSeq !== b.saleSeq); return Promise.resolve({ ok: true, text: () => Promise.resolve('1') }); }
  if (/stockRebuild/.test(url)) return Promise.resolve({ ok: true, text: () => Promise.resolve('"12"') });
  return J({});
};
w.__LS = LS.slice(); w.__TRX = TRX.slice();
w._alertBox = (m) => { w.__alerts = (w.__alerts || []).concat([String(m)]); }; w._confirmBox = (o) => { w.__cfm = o; }; w._toast = () => {};
w.konetPopDrag = () => {}; w.konetGridGrip = () => {};
const m = /<script>\n([\s\S]*?)<\/script>/.exec(html); vm.runInContext(m[1], dom.getInternalVMContext());
const tick = (ms) => new Promise(r => setTimeout(r, ms || 20));
(async () => {
  await tick(40);
  const D = w.document;
  D.getElementById('fr').value = '2026-10-01'; D.getElementById('to').value = '2026-10-31';
  w.load(); await tick();
  t(w._ls.length === 7, '목록 7줄');
  // ── 창 열기 ──
  w.dkOpen(); await tick(40);
  t(D.getElementById('dkMask').classList.contains('on'), '창 열림');
  t(/2026-10-01 ~ 2026-10-31/.test(D.getElementById('dkSub').textContent), '기간 표시');
  const trxRows = D.querySelectorAll('#dkTrx tr');
  t(trxRows.length === 2, '대상 판매전표 2장(세진유통 제외) : ' + trxRows.length);
  t(/대상 급식/.test(trxRows[0].textContent) && /겹침/.test(trxRows[0].textContent) && /6<\/b>줄/.test(trxRows[0].innerHTML), '0002 = 같은 날 대상 발주 6줄 겹침');
  t(/대상주식회사/.test(trxRows[1].textContent) && /없음/.test(trxRows[1].textContent), '10-30 전표 = 같은 날 발주 없음');
  t(/공급가 (10,050|6,200)/.test(trxRows[0].textContent) || /공급가 [\d,]+/.test(trxRows[0].textContent), '공급가 합 표시');
  // ── 겹친 줄 ──
  const dupHdr = D.querySelectorAll('#dkDup tr.sum');
  t(dupHdr.length === 3, '겹친 묶음 3(청라중 종이컵 · 혜인 종이컵 · 혜인 유산지) : ' + dupHdr.length);
  t(D.querySelectorAll('#dkDup input.dkc').length === 6, '겹친 줄 6(효문고는 없음)');
  t(/2<\/b>줄 겹침/.test(D.getElementById('dkDup').innerHTML), '머리줄 「2줄 겹침」');
  // ── 겹친 줄 삭제 : 1차 세 줄 체크 ──
  D.querySelectorAll('#dkDup input.dkc').forEach(c => { if (['1','2','3'].indexOf(c.getAttribute('data-seq')) >= 0) c.checked = true; });
  w.dkDelDup(); t(w.__cfm && /3<\/b>줄/.test(w.__cfm.msg), '확인창 3줄'); w.__cfm.onOk(); await tick(60);
  const del = CALLS.filter(c => /daesangPoDelete/.test(c.url)).pop();
  t(del && JSON.parse(del.body).seqs.join() === '1,2,3', '삭제 요청 seqs 1,2,3');
  t(w._ls.length === 4, '목록 다시 읽어 4줄');
  t(D.querySelectorAll('#dkDup tr.sum').length === 0 && /없습니다/.test(D.getElementById('dkDup').textContent), '겹침 해소');
  t(/<b>3<\/b>줄/.test(D.querySelector('#dkTrx tr').innerHTML), '전표 줄의 같은 날 발주가 3줄로(11차만 남음)');
  // ── 전표 삭제 ──
  const c0 = D.querySelector('#dkTrx input.dkc'); c0.checked = true;
  w.dkDelTrx(); t(w.__cfm && /1<\/b>장/.test(w.__cfm.msg) && /119,955/.test(w.__cfm.msg), '전표 확인창 1장 · 금액');
  w.__cfm.onOk(); await tick(80);
  const dt = CALLS.filter(c => /salesTrxDelete/.test(c.url));
  t(dt.length === 1 && JSON.parse(dt[0].body).saleSeq === 91, '전표 삭제 요청 saleSeq 91');
  t(/1<\/b>장을 지웠습니다/.test((w.__alerts || []).slice(-1)[0] || ''), '결과 알림');
  t(D.querySelectorAll('#dkTrx tr').length === 1 && /대상주식회사/.test(D.getElementById('dkTrx').textContent), '다시 읽어 남은 전표 1장');
  // 체크 없이 누르면 안내만
  w.__alerts = []; w.dkDelTrx(); t(/체크하세요/.test(w.__alerts[0] || ''), '체크 없음 안내(전표)');
  w.__alerts = []; w.dkDelDup(); t(/체크하세요/.test(w.__alerts[0] || ''), '체크 없음 안내(줄)');
  // ── 재집계 ──
  w.dkRebuild(); t(w.__cfm && /전 기간/.test(w.__cfm.msg), '재집계 확인창'); w.__alerts = []; w.__cfm.onOk(); await tick(60);
  t(CALLS.some(c => /stockRebuild\.do/.test(c.url)), '재집계 요청');
  t(/재집계를 마쳤습니다 — 12일치/.test(w.__alerts[0] || ''), '재집계 결과 12일치 : ' + (w.__alerts[0] || ''));
  // 머리 체크 = 전체
  w.dkOpen(); await tick(40);
  const hd = D.getElementById('dkDup').parentNode.querySelector('thead input'); hd.checked = true; w.dkAll('dkDup', hd);
  t(Array.prototype.every.call(D.querySelectorAll('#dkDup input.dkc'), c => c.checked), '머리 체크 = 전부');
  w.dkClose(); t(!D.getElementById('dkMask').classList.contains('on'), '닫힘');
  console.log('ok', ok, 'bad', bad);
  process.exit(bad ? 1 : 0);
})();
