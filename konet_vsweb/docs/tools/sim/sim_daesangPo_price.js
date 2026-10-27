// 대상 발주 — 수량별 단가 · 받는 사람 택배비 · 차수 · 마감 엑셀 (2026-10-27) — 화면 JS 를 jsdom 에 그대로 태운다
const fs = require('fs'), path = require('path'), vm = require('vm');
const { JSDOM } = require('jsdom');
let src = fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/daesangPo.jsp'), 'utf8').replace(/\r\n/g, '\n');
src = src.replace(/<%--[\s\S]*?--%>/g, '').replace(/\$\{pageContext\.request\.contextPath\}/g, '').replace(/<%@[^%]*%>/g, '');
const html = src.replace(/<script src="[^"]*"><\/script>/g, '');
const dom = new JSDOM(html, { runScripts: 'outside-only', pretendToBeVisual: true });
const w = dom.window;
let ok = 0, bad = 0; const t = (c, m) => { if (c) ok++; else { bad++; console.log('FAIL', m); } };
// 서버 흉내
const CALLS = []; const PRICE = [
  { prodCd: '1010014032', baseQty: 1000, basePrice: 62, underPrice: 67, useYn: 'Y', sortOrd: 10 },
  { prodCd: '9904012907', baseQty: 0, basePrice: 108, underPrice: null, useYn: 'Y', sortOrd: 80 },
  { prodCd: '6010040023', baseQty: 2000, basePrice: 33, underPrice: 47, useYn: 'Y', sortOrd: 40 }];
w.fetch = (url, o) => { CALLS.push({ url, body: o && o.body });
  const J = x => Promise.resolve({ ok: true, json: () => Promise.resolve(x), text: () => Promise.resolve(JSON.stringify(x)) });
  if (/clientList/.test(url)) return J({ data: [{ bizCd: 'K0000002', bizNm: '대상주식회사(급식)' }] });
  if (/prodList/.test(url)) return J({ data: [{ prodCd: '1010014032', prodNm: '급식 친환경 종이컵 10oz', salePrice: 54000, spec: '10oz' }, { prodCd: '9904012907', prodNm: '급식 트레이(플래터용)', salePrice: 0, spec: '152*241*24' }, { prodCd: '6010040023', prodNm: '(급식) 유산지', salePrice: 33, spec: '180*180' }, { prodCd: 'X1', prodNm: '단가표 밖 품목', salePrice: 500, spec: '' }] });
  if (/extItemList/.test(url)) return J({ data: [{ extItemCd: 'SUB1', prodCd: '1010014032', extItemNm: '서브' }] });
  if (/daesangPoMap/.test(url)) return J({ item: { '종이컵': '1010014032' }, price: PRICE, rounds: [{ dsRound: '10월 11차', frDt: '20261023', toDt: '20261023', cnt: 3 }] });
  if (/daesangPoFee/.test(url)) return J({ cnt: 1 });
  if (/daesangPoList/.test(url)) return J({ data: w.__LS || [] });
  if (/daesangPoHist/.test(url)) return J({ data: w.__HIST || [] });
  if (/daesangPoRestore/.test(url)) return J({ cnt: 1 });
  return J({});
};
w._alertBox = (m) => { w.__alerts = (w.__alerts || []).concat([String(m)]); }; w._confirmBox = (o) => { w.__cfm = o; }; w._toast = () => {};
w.XLSX = { utils: { aoa_to_sheet: (aoa) => { const ws = {}; aoa.forEach((r, ri) => r.forEach((v, ci) => { if (v === null || v === undefined || v === '') return; ws[String.fromCharCode(65 + ci) + (ri + 1)] = { t: typeof v === 'number' ? 'n' : 's', v }; })); ws['!ref'] = 'A1'; return ws; }, encode_cell: c => String.fromCharCode(65 + c.c) + (c.r + 1), book_new: () => ({ Sheets: {}, SheetNames: [] }), book_append_sheet: (wb, ws, nm) => { wb.Sheets[nm] = ws; wb.SheetNames.push(nm); } }, writeFile: (wb, nm) => { w.__xls = { wb, nm }; } };
const m = /<script>\n([\s\S]*?)<\/script>/.exec(html); vm.runInContext(m[1], dom.getInternalVMContext());
(async () => {
  await new Promise(r => setTimeout(r, 30));
  // ── 단가표 적용 ──
  t(w.priceOf('1010014032', 1000) === 62, '1000개 → 62');
  t(w.priceOf('1010014032', 999) === 67, '999개 → 67');
  t(w.priceOf('1010014032', 150) === 67, '150개 → 67 (최소 발주량 없음)');
  t(w.priceOf('SUB1', 500) === 67, '매칭코드 → 주코드 단가표');
  t(w.priceOf('9904012907', 10) === 108 && w.priceOf('9904012907', 5000) === 108, '기본수량 0 = 단가 하나');
  t(w.priceOf('X1', 10) === 500, '단가표 밖 → 판매가');
  // ── 차수 제안 ──
  w.document.getElementById('dt').value = '2026-10-27'; w.roundAuto();
  t(w.document.getElementById('round').value === '10월 12차', '다음 차수 = 10월 12차 (' + w.document.getElementById('round').value + ')');
  w.document.getElementById('dt').value = '2026-10-23'; w.roundAuto();
  t(w.document.getElementById('round').value === '10월 11차', '같은 날이면 같은 차수');
  w.document.getElementById('dt').value = '2026-10-27'; w.roundAuto();
  // ── 붙여넣기 → 택배비 묶음 ──
  w.addParsed([
    { rcvNm: '효문고 영양사', rcvAddr: '서울', qty: 500, itemNm: '종이컵' },      // 500×67=33,500 → 0
    { rcvNm: '송우고', rcvAddr: '경기', qty: 300, itemNm: '종이컵' },             // 300×67=20,100 → 4000
    { rcvNm: '석사초', rcvAddr: '경기', qty: 400, itemNm: '종이컵' },             // 26,800
    { rcvNm: '석사초', rcvAddr: '경기', qty: 100, itemNm: '종이컵' },             // +6,700 = 33,500 → 0 (합산)
    { rcvNm: '제주1지점', rcvAddr: '제주시', qty: 200, itemNm: '종이컵' },        // 13,400 → 4000+3000
    { rcvNm: '급식2지점', rcvAddr: '서울', qty: 3000, itemNm: '종이컵' }          // 3000×62
  ], 'test');
  const P = w._pv;
  t(P[0].price === 67 && P[5].price === 62, '붙여넣기 단가 기본/미만');
  t(P.every(x => x.dsRound === '10월 12차'), '차수가 줄마다');
  t(P[0].fee === 0, '33,500 → 택배비 0 (' + P[0].fee + ')');
  t(P[1].fee === 4000, '20,100 → 4,000');
  t(P[2].fee === 0 && P[3].fee === 0 && P[2].feeInfo.amt === 33500, '같은 받는 사람 합산 33,500 → 0');
  t(P[4].fee === 7000, '제주 13,400 → 7,000 (' + P[4].fee + ')');
  // 수량 고치면 단가·택배비 다시
  const qEl = { value: '1000', classList: { toggle() {} } }; w.pvSet(1, 'qty', qEl); await new Promise(r => setTimeout(r, 5));
  t(P[1].price === 62 && P[1].fee === 0, '수량 300→1000 : 단가 62, 금액 62,000 → 택배비 0');
  // 손으로 택배비
  w.pvSet(1, 'fee', { value: '12000' }); await new Promise(r => setTimeout(r, 5));
  t(P[1].fee === 12000 && P[1].feeAuto === false, '손 택배비 유지');
  w.pvSet(1, 'fee', { value: '' }); await new Promise(r => setTimeout(r, 5));
  t(P[1].fee === 0 && P[1].feeAuto === true, '비우면 다시 자동');
  // 손 단가 → 수량 바꿔도 유지, 비우면 자동
  w.pvSet(0, 'price', { value: '70' }); await new Promise(r => setTimeout(r, 5));
  w.pvSet(0, 'qty', { value: '2000', classList: { toggle() {} } }); await new Promise(r => setTimeout(r, 5));
  t(P[0].price === 70, '손 단가는 수량 바꿔도 그대로');
  w.pvSet(0, 'price', { value: '' }); await new Promise(r => setTimeout(r, 5));
  t(P[0].price === 62, '단가 비우면 단가표(2000개 → 62)');
  // 저장 본문에 차수·택배비
  w.document.getElementById('bizSel').value = 'K0000002'; w.save();
  t(!!w.__cfm, '저장 확인창');
  // ── 저장 목록 : 택배비 맞추기 · 마감 엑셀 ──
  w.__LS = [
    { seq: 1, dlvDt: '20260928', dsRound: '10월 1차', rcvNm: '영석고', rcvAddr: '서울', itemCd: '1010014032', itemNm: '종이컵', qty: 1000, salePrice: 62, rcvFee: 0, ordNo: 'A', lineNo: '1' },
    { seq: 2, dlvDt: '20260928', dsRound: '10월 1차', rcvNm: '경인중', rcvAddr: '서울', itemCd: '1010014032', itemNm: '종이컵', qty: 600, salePrice: 67, rcvFee: 0, ordNo: 'A', lineNo: '2' },
    { seq: 3, dlvDt: '20261002', dsRound: '10월 3차', rcvNm: '송임숙', rcvAddr: '전북', itemCd: '9904012907', itemNm: '트레이', qty: 100, salePrice: 108, rcvFee: null, ordNo: 'B', lineNo: '1' },
    { seq: 4, dlvDt: '20261016', dsRound: '10월 8차', rcvNm: '장유림', rcvAddr: '서울', itemCd: '1010014032', itemNm: '종이컵', qty: 3000, salePrice: 62, rcvFee: 12000, ordNo: 'C', lineNo: '1' }
  ];
  w.load(); await new Promise(r => setTimeout(r, 20));
  t(w._ls.length === 4, '목록 4줄');
  CALLS.length = 0;
  const r = await w.lsFeeSync(null, false);
  t(r.cnt === 1 && r.skip === 1, '빈 택배비(10,800 → 4,000) 1줄 넣고, 손값(12,000) 묶음은 건너뜀 : cnt=' + r.cnt + ' skip=' + r.skip);
  t(w._ls[2].fee === 4000, '송임숙 4,000');
  const r2 = await w.lsFeeSync([w.lsKey(w._ls[3])], true);
  t(r2.cnt === 1 && w._ls[3].fee === 0, '강제 다시 계산 → 186,000 은 0');
  w._ls[3].fee = 12000; w._ls[3].rcvFee = 12000;
  w.document.getElementById('fr').value = '2026-09-28'; w.document.getElementById('to').value = '2026-10-23';
  w.dsCloseXls();
  const ws = w.__xls.wb.Sheets[w.__xls.wb.SheetNames[0]];
  t(w.__xls.wb.SheetNames[0] === '202610', '시트 202610 (' + w.__xls.wb.SheetNames[0] + ')');
  t(ws.A4.v === '2026-09-28 10월 1차' && ws.B4.v === '영석고' && ws.C4.v === '급식 친환경 종이컵 10oz' && ws.D4.v === '10oz' && ws.E4.v === 1000 && ws.F4.v === 62, '첫 줄 = 일자 차수·출고점·상품명·규격·수량·단가');
  t(ws.G4.f === 'E4*F4' && ws.G4.v === 62000, '금액 식');
  t(ws.B5.v === '경인중' && ws.A5.v === '', '같은 차수 둘째 줄 일자 비움(합치기)');
  t(ws.C7.v === '택배비(로젠)' && ws.E7.v === 1 && ws.F7.v === 4000, '송임숙 아래 택배비 1×4,000');
  t(ws.C9.v === '택배비(로젠)' && ws.E9.v === 3 && ws.F9.v === 4000, '장유림 12,000 → 3×4,000');
  t(ws.I1.v === '4건' && ws.J1.v === 16000, '오른쪽 위 택배비 4건 16,000');
  // 차수 일괄 넣기 — 차수 없는 줄 2개에 넣고 daesangPoInfo 가 줄마다 간다
  w._ls[2].dsRound=''; w._ls[3].dsRound=''; w.document.getElementById('roundLs').value='10월 9차'; CALLS.length=0; w.__alerts=[]; w.__cfm=null; w.lsRoundAll(); await new Promise(r=>setTimeout(r,10));
  t(!w.__cfm && (w.__alerts||[]).some(m=>/체크/.test(m)) && CALLS.filter(c=>/daesangPoInfo/.test(c.url)).length===0, '체크 없으면 넣지 않고 안내');
  w.document.querySelectorAll('.lchk')[2].checked=true; w.document.querySelectorAll('.lchk')[3].checked=true; w.lsRoundAll(); if(w.__cfm) await w.__cfm.onOk(); await new Promise(r=>setTimeout(r,30));
  t(w._ls[2].dsRound==='10월 9차' && w._ls[3].dsRound==='10월 9차' && w._ls[0].dsRound==='10월 1차' && CALLS.filter(c=>/daesangPoInfo/.test(c.url)).length===2, '체크한 2줄에만 차수');
  t(ws.A10.v === '합 계' && ws.E10.f === 'SUM(E4:E9)' && ws.G10.v === 62000 + 40200 + 10800 + 4000 + 186000 + 12000, '합계 줄');
  t(ws['!merges'].some(m => m.s.r === 3 && m.e.r === 4 && m.s.c === 0), '차수 세로 합치기');
  // ── 이력·복구 ──
  w.__HIST=[ { seq: 100, actionYn:'N', dlvDt:'20261016', dsRound:'10월 8차', rcvNm:'장유림', itemCd:'1010014032', itemNm:'종이컵', qty:2000, salePrice:62, rcvFee:0, remark:'대상 발주', updDttm:'2026-10-27 17:53', updUser:'admin', liveSeq:4 },
                { seq: 101, actionYn:'D', dlvDt:'20261002', dsRound:'10월 3차', rcvNm:'고창고', itemCd:'9904012192', itemNm:'트레이', qty:400, salePrice:46, rcvFee:4000, remark:'대상 발주', updDttm:'2026-10-27 12:00', updUser:'K002', liveSeq:null } ];
  w.dhOpen(); await new Promise(r=>setTimeout(r,20));
  t(w.document.getElementById('dhFr').value==='2026-09-28' && w.document.getElementById('dhTo').value==='2026-10-23', '이력 창 기간 = 저장 목록 기간');
  CALLS.length=0; w.document.getElementById('dhFr').value='2026-08-01'; w.dhLoad(); await new Promise(r=>setTimeout(r,20));
  t(CALLS.some(c=>/daesangPoHist/.test(c.url) && /frDt=2026-08-01/.test(c.body)), '창 안에서 기간 바꿔 조회');
  t(w.document.getElementById('dhMask').classList.contains('on') && w._dh.length===2 && w.document.querySelectorAll('#dhBody tr').length===2, '이력 창 2줄');
  t(/수정 전/.test(w.document.querySelectorAll('#dhBody tr')[0].textContent) && /삭제/.test(w.document.querySelectorAll('#dhBody tr')[1].textContent), '상태 배지 수정 전·삭제');
  CALLS.length=0; w.__cfm=null; w.dhRestore(0); t(!!w.__cfm && /지금 : 2026-10-16/.test(w.__cfm.msg) && /수량 3,000/.test(w.__cfm.msg) && /되돌릴 값.*수량 2,000/.test(w.__cfm.msg), '수정 전 복구 확인창에 지금 → 되돌릴 값');
  await w.__cfm.onOk(); await new Promise(r=>setTimeout(r,40));
  t(CALLS.some(c=>/daesangPoRestore/.test(c.url) && /"seq":100/.test(c.body)) && w._dh.length===1 && CALLS.some(c=>/daesangPoList/.test(c.url)), '복구 호출 + 목록 다시 읽음');
  w.__cfm=null; w.dhRestore(0); t(!!w.__cfm && /다시 살립니다/.test(w.__cfm.msg), '삭제 복구 확인창');
  // ── 끌기 : 제목줄 위로 onclick 조상이 없어야 popdrag 가 잡는다 · 덮개 클릭은 닫힌다
  ['dpMask','dhMask'].forEach(function(id){ var hd=w.document.querySelector('#'+id+' > .box > .dh'); t(!!hd && !hd.closest('[onclick]') && hd.parentElement.classList.contains('box'), id+' 제목줄 끌기 조건(onclick 조상 없음·.box)'); });
  w.document.getElementById('dhMask').classList.add('on'); w.document.getElementById('dhMask').dispatchEvent(new w.MouseEvent('click',{bubbles:true})); t(!w.document.getElementById('dhMask').classList.contains('on'), '덮개 클릭 → 닫힘');
  console.log('ok', ok, 'bad', bad);
})().catch(e => { console.log('ERR', e); process.exit(1); });
