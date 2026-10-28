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
  t(ws.G3.v === '판매금액' && ws.G2.v === 'VAT 포함' && !ws.G4.f && ws.G4.v === 68200, '금액 = 판매금액(VAT 포함) 68,200 (' + ws.G4.v + ')');
  t(ws.G7.v === 4400 && ws.G9.v === 13200, '택배비 줄 금액 = 택배비 + 부가세 10%');
  t(ws.B5.v === '경인중' && ws.A5.v === '', '같은 차수 둘째 줄 일자 비움(합치기)');
  t(ws.C7.v === '택배비(로젠)' && ws.E7.v === 1 && ws.F7.v === 4000 && ws.G7.v === 4400, '송임숙 아래 택배비 1×4,000 · 판매금액 4,400(부가세 포함)');
  t(ws.C9.v === '택배비(로젠)' && ws.E9.v === 3 && ws.F9.v === 4000 && ws.G9.v === 13200, '장유림 12,000 → 3×4,000 · 판매금액 13,200');
  t(ws.I1.v === '4건' && ws.J1.v === 17600, '오른쪽 위 택배비 4건 17,600(부가세 포함)');
  // 차수 일괄 넣기 — 차수 없는 줄 2개에 넣고 daesangPoInfo 가 줄마다 간다
  w._ls[2].dsRound=''; w._ls[3].dsRound=''; w.document.getElementById('roundLs').value='10월 9차'; CALLS.length=0; w.__alerts=[]; w.__cfm=null; w.lsRoundAll(); await new Promise(r=>setTimeout(r,10));
  t(!w.__cfm && (w.__alerts||[]).some(m=>/체크/.test(m)) && CALLS.filter(c=>/daesangPoInfo/.test(c.url)).length===0, '체크 없으면 넣지 않고 안내');
  w.document.querySelectorAll('.lchk')[2].checked=true; w.document.querySelectorAll('.lchk')[3].checked=true; w.lsRoundAll(); if(w.__cfm) await w.__cfm.onOk(); await new Promise(r=>setTimeout(r,30));
  t(w._ls[2].dsRound==='10월 9차' && w._ls[3].dsRound==='10월 9차' && w._ls[0].dsRound==='10월 1차' && CALLS.filter(c=>/daesangPoInfo/.test(c.url)).length===2, '체크한 2줄에만 차수');
  t(ws.A10.v === '합 계' && ws.E10.f === 'SUM(E4:E9)' && ws.G10.v === 68200 + 44220 + 11880 + 4400 + 204600 + 13200, '합계 줄 = 판매금액 합(VAT 포함) + 택배비(부가세 포함)');
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
  // ── 같은 날 차수가 다르면 마감 엑셀에서 따로(원본 10-06 4차·5차) ──
  w.__LS=[ { seq:11, dlvDt:'20261006', dsRound:'10월 4차', rcvNm:'이기애', rcvAddr:'', itemCd:'9904012192', itemNm:'트레이', qty:800, salePrice:46, rcvFee:0, ordNo:'A', lineNo:'1' },
           { seq:12, dlvDt:'20261006', dsRound:'10월 5차', rcvNm:'이주영', rcvAddr:'', itemCd:'9904012192', itemNm:'트레이', qty:1000, salePrice:46, rcvFee:0, ordNo:'B', lineNo:'1' },
           { seq:13, dlvDt:'20261006', dsRound:'10월 5차', rcvNm:'이예진', rcvAddr:'', itemCd:'1010014032', itemNm:'종이컵', qty:1000, salePrice:62, rcvFee:0, ordNo:'B', lineNo:'2' } ];
  w.load(); await new Promise(r=>setTimeout(r,20)); w.dsCloseXls(); var ws2=w.__xls.wb.Sheets[w.__xls.wb.SheetNames[0]];
  t(ws2.A4.v==='2026-10-06 10월 4차' && ws2.A5.v==='2026-10-06 10월 5차' && ws2.A6.v==='' && ws2['!merges'].some(m=>m.s.r===4&&m.e.r===5&&m.s.c===0), '같은 날 다른 차수 → 일자 칸 따로(4차 1줄 · 5차 2줄 병합)');
  // ── 비고 수정 기록 한 줄씩 ──
  var rmk='대상 발주 · 수정 10-27 17:53 수량 150→10000 판매가 67→62 · 수정 10-27 17:53 수량 10000→150 판매가 62→67 · 수정 10-27 19:10 수량 150→1000 판매가 67→62 · 복구 10-27 19:20';
  var html=w.dhRemark(rmk, 7); var div=w.document.createElement('div'); div.innerHTML=html;
  var lines=[...div.querySelectorAll('div[style*="nowrap"]')].map(d=>d.textContent);
  t(lines.length===4 && /^10-27 19:20 복구/.test(lines[0]) && /19:10 수정 수량 150 → 1000 · 판매가 67 → 62/.test(lines[1]), '비고 최근 것부터 한 줄씩 ('+lines[0]+' / '+lines[1]+')');
  t(!!div.querySelector('#dhMore7') && /\+ 1건 더/.test(div.textContent) && /총 4회 · 대상 발주/.test(div.textContent), '3건 넘으면 접기 + 총 n회');
  t(w.dhRemark('대상 발주', 1).indexOf('대상 발주')>=0, '수정 없으면 그대로');
  // ── 차수마다 합계 줄 ──
  w.__LS=[ { seq:21, dlvDt:'20260827', dsRound:'9월 2차', rcvNm:'휘경중', rcvAddr:'', itemCd:'1010014032', itemNm:'종이컵', qty:400, salePrice:67, rcvFee:0, ordNo:'A', lineNo:'1' },
           { seq:22, dlvDt:'20260827', dsRound:'9월 2차', rcvNm:'종암중', rcvAddr:'', itemCd:'1010014032', itemNm:'종이컵', qty:600, salePrice:67, rcvFee:4000, ordNo:'A', lineNo:'2' },
           { seq:23, dlvDt:'20260826', dsRound:'9월 1차', rcvNm:'급식2지점', rcvAddr:'', itemCd:'6010040023', itemNm:'유산지', qty:15000, salePrice:33, rcvFee:0, ordNo:'B', lineNo:'1' } ];
  w.load(); await new Promise(r=>setTimeout(r,20)); var sums=[...w.document.querySelectorAll('#lsBody tr.sum')].map(tr=>tr.textContent.replace(/s+/g,' '));
  t(sums.length===3 && /2026-08-27 9월 2차 합계 · 받는 사람 2곳 · 2줄/.test(sums[0]) && /1,000/.test(sums[0]) && /67,000/.test(sums[0]) && /6,700/.test(sums[0]) && /73,700/.test(sums[0]) && /택배 포함 78,100/.test(sums[0]), '9월 2차 합계 줄 (수량 1,000 · 공급가 67,000 · 부가세 6,700 · 판매 73,700 · 택배 포함 78,100 = 택배비 4,000 + 부가세 400) : '+sums[0]);
  t(/9월 1차 합계/.test(sums[1]) && /전체 합계/.test(sums[2]) && /562,000/.test(sums[2]), '9월 1차 합계 + 전체 합계(공급가 562,000)');
  // ── 접기/펼치기 (2026-10-28) : 합계 줄 = 묶음 맨 앞 · ▾/▸ · 전체 접기 ──
  await new Promise(r=>setTimeout(r,10));
  var trs=[...w.document.querySelectorAll('#lsBody tr')];
  t(trs[0].classList.contains('sum') && /9월 2차 합계/.test(trs[0].textContent) && trs[1].getAttribute('data-g')==='0' && trs[2].getAttribute('data-g')==='0' && trs[3].classList.contains('sum') && /9월 1차 합계/.test(trs[3].textContent) && trs[4].getAttribute('data-g')==='1', '합계 줄이 묶음 맨 앞 · 줄에 data-g 묶음 번호');
  var tg0=w.document.getElementById('dsfold-ls-0'); t(!!tg0 && tg0.textContent==='▾' && trs[1].style.display==='', '묶음 0 토글 ▾ · 줄 보임');
  w.dsFold('ls',0); t(tg0.textContent==='▸' && trs[1].style.display==='none' && trs[2].style.display==='none' && trs[4].style.display==='', '▸ 로 접으면 그 묶음 줄만 숨고 합계는 남는다 · 다른 묶음 그대로');
  w.dsFold('ls',0); t(tg0.textContent==='▾' && trs[1].style.display==='', '다시 누르면 펼침');
  var fa=w.document.getElementById('lsFoldAll'); t(!!fa && /전체 접기/.test(fa.textContent), '[⊟ 전체 접기] 단추');
  w.dsFoldAll('ls'); await new Promise(r=>setTimeout(r,5)); t(trs[1].style.display==='none' && trs[4].style.display==='none' && /전체 펼치기/.test(fa.textContent) && w.document.getElementById('dsfold-ls-1').textContent==='▸', '전체 접기 → 모든 묶음 줄 숨김 · 단추 「전체 펼치기」');
  w.load(); await new Promise(r=>setTimeout(r,20)); var trs2=[...w.document.querySelectorAll('#lsBody tr')]; t(trs2[1].style.display==='none' && trs2[4].style.display==='none', '다시 그려도 접힌 채(상태 유지)');
  w.dsFoldAll('ls'); await new Promise(r=>setTimeout(r,5)); t(trs2[1].style.display==='' && trs2[4].style.display==='' && /전체 접기/.test(fa.textContent), '전체 펼치기 → 전부 보임');
  t(w.document.querySelector('table.g input.rnd') && /112px/.test(w.document.querySelector('style').textContent), '차수 칸 112px');
  var s0=w.document.querySelector('#lsBody tr.sum'), s0td=s0.children; t(s0td[0].classList.contains('fd') && s0td[0].querySelector('.fold') && +s0td[1].getAttribute('colspan')===9 && s0td[1].classList.contains('l') && !s0td[1].querySelector('.fold'), '토글 = 합계 줄 맨 앞 칸(td.fd) · 라벨 칸 colspan 9(=lead-1) · 라벨 옆엔 토글 없음 (2026-10-28)');
  // ── 판매등록 그리드 칸 : DC · 영세 · 반품 · 서비스 ──
  var c1=w.dsCalc({ qty:1000, price:62, itemCd:'1010014032', dsDcAmt:2000, dsZeroYn:'N', dsTrxGb:'판매', dsSvcQty:50 },'pv');
  t(c1.gross===62000 && c1.dc===2000 && c1.sup===60000 && c1.vat===6000 && c1.tot===66000 && c1.sign===1 && c1.svc===50, 'DC 2,000 → 공급가 60,000 · 부가세 6,000 · 판매 66,000');
  var c2=w.dsCalc({ qty:100, salePrice:67, itemCd:'1010014032', dsZeroYn:'Y', dsTrxGb:'반품' },'ls');
  t(c2.vat===0 && c2.sign===-1 && c2.tot===6700, '영세 → 부가세 0 · 반품 → 부호 -1');
  var h2=w.extCells({ qty:100, price:67, itemCd:'1010014032', dsDcAmt:'', dsZeroYn:'N', dsTrxGb:'반품', dsSvcQty:'', dsMemo:'메모' }, 3, 'pv'); var dv=w.document.createElement('tr'); dv.innerHTML=h2;
  t(dv.children.length===9 && /-6,700/.test(dv.children[0].textContent) && dv.querySelector('select').value==='반품' && dv.querySelector('input[placeholder="비고"]').value==='메모', '칸 9개(금액·DC·공급가·부가세·판매금액·서비스·비고·영세·거래구분) · 반품 음수');
  w.__LS=[ { seq:31, dlvDt:'20261027', dsRound:'10월 12차', rcvNm:'A', rcvAddr:'', itemCd:'1010014032', itemNm:'종이컵', qty:1000, salePrice:62, rcvFee:0, dsDcAmt:2000, dsSvcQty:10, dsZeroYn:'N', dsTrxGb:'판매', dsMemo:'', ordNo:'A', lineNo:'1' },
           { seq:32, dlvDt:'20261027', dsRound:'10월 12차', rcvNm:'B', rcvAddr:'', itemCd:'1010014032', itemNm:'종이컵', qty:100, salePrice:67, rcvFee:0, dsDcAmt:null, dsSvcQty:null, dsZeroYn:'N', dsTrxGb:'반품', dsMemo:'', ordNo:'A', lineNo:'2' } ];
  w.load(); await new Promise(r=>setTimeout(r,20)); var sm=[...w.document.querySelectorAll('#lsBody tr.sum')].map(tr=>tr.textContent.replace(/\s+/g,' '));
  t(sm.length===1 && /금액|55,300/.test(sm[0]) && /2,000/.test(sm[0]) && /53,300/.test(sm[0]) && /58,63010$/.test(sm[0]), '합계 = 금액 55,300(62,000−6,700) · DC 2,000 · 공급가 53,300 · 서비스 10 : '+sm[0]);
  var payload=null; w.fetch=((orig)=>(u,o)=>{ if(/daesangPoSave/.test(u)) payload=JSON.parse(o.body); return orig(u,o); })(w.fetch);
  w._pv=[]; w.addParsed([{ rcvNm:'C', rcvAddr:'', qty:500, itemNm:'종이컵' }],'t'); w._pv[0].dsDcAmt=1000; w._pv[0].dsTrxGb='반품'; w._pv[0].dsMemo='m'; w.document.getElementById('bizSel').value='K0000002'; w.__cfm=null; w.save(); if(w.__cfm) await w.__cfm.onOk(); await new Promise(r=>setTimeout(r,20));
  t(payload && payload.rows[0].dsDcAmt===1000 && payload.rows[0].dsTrxGb==='반품' && payload.rows[0].dsMemo==='m' && payload.force==='Y', '저장 본문에 DC·거래구분·비고 + 무조건 저장(force)');
  // ── 머리줄 칸 수 = 몸통 칸 수 (올린 표 24 · 저장 목록 25) ──
  var pvTh=w.document.querySelectorAll('#pvWrap thead th').length, lsTh=w.document.querySelectorAll('#lsWrap thead th').length, lsTd=w.document.querySelector('#lsBody tr:not(.sum)') ? w.document.querySelector('#lsBody tr:not(.sum)').children.length : 0;
  t(pvTh===24 && lsTh===25 && lsTd===25, '머리줄 칸 수 올린 표 '+pvTh+'/24 · 저장 목록 '+lsTh+'/25 · 몸통 '+lsTd);
  var c3=w.dsCalc({ qty:1000, price:62, itemCd:'1010014032', dsDcAmt:'', dsZeroYn:'N', dsTrxGb:'판매', dsVatAmt:6199 },'pv'); t(c3.vat===6199 && c3.vatMan===true && c3.tot===68199, '손 부가세 6,199 → 판매금액 68,199');
  var c4=w.dsCalc({ qty:1000, price:62, itemCd:'1010014032', dsDcAmt:'', dsZeroYn:'N', dsTrxGb:'판매', dsVatAmt:'' },'pv'); t(c4.vat===6200 && !c4.vatMan, '비우면 자동 6,200');
  // ── 부가세 칸 : 비우면 0 · 「자동」·↺ 이면 자동 (2026-10-27 「부가세 빼면 금액 변경안됨」) ──
  w._pv=[]; w.addParsed([{ rcvNm:'D', rcvAddr:'', qty:1000, itemNm:'종이컵' }],'t'); await new Promise(r=>setTimeout(r,20));
  w.pvSet(0,'dsVatAmt',{ value:'' }); await new Promise(r=>setTimeout(r,20)); var c5=w.dsCalc(w._pv[0],'pv');
  t(w._pv[0].dsVatAmt===0 && c5.vat===0 && c5.vatMan===true && c5.tot===c5.sup, '올린 표 : 부가세 비우면 0 · 판매금액 = 공급가 ('+c5.tot+')');
  var vt=w.document.querySelector('#pvBody tr td a.vauto'); t(!!vt, '손 부가세면 ↺ 단추가 보인다');
  w.pvSet(0,'dsVatAmt',{ value:'자동' }); await new Promise(r=>setTimeout(r,20)); var c6=w.dsCalc(w._pv[0],'pv');
  t(w._pv[0].dsVatAmt==='' && !c6.vatMan && c6.vat===Math.round(c6.sup*0.1), '「자동」이라 쓰면 자동 10% ('+c6.vat+')');
  w._pv[0].dsVatAmt=0; w.pvRender(); w.vatAuto(0,'pv'); await new Promise(r=>setTimeout(r,20)); t(w._pv[0].dsVatAmt==='' && !w.document.querySelector('#pvBody a.vauto'), '↺ 누르면 자동 · ↺ 사라짐');
  var lsPay=null; w.fetch=((orig)=>(u,o)=>{ if(/daesangPoInfo/.test(u)){ lsPay=JSON.parse(o.body); return Promise.resolve({ ok:true, json:()=>Promise.resolve({}), text:()=>Promise.resolve('{}') }); } return orig(u,o); })(w.fetch);
  var li=w._ls.findIndex(x=>x.seq===31); if(li>=0){ w.lsInfo(li,'dsVatAmt',{ value:'', getAttribute:()=>'', setAttribute(){}, title:'' }); await new Promise(r=>setTimeout(r,30));
    t(lsPay && lsPay.dsVatAmt==='0', '저장 목록 : 비우면 서버에 0 으로 (dsVatAmt='+(lsPay&&lsPay.dsVatAmt)+')');
    lsPay=null; w.vatAuto(li,'ls'); await new Promise(r=>setTimeout(r,30)); t(lsPay && lsPay.dsVatAmt==='', '저장 목록 : ↺ → 서버에 빈 값(자동) (dsVatAmt='+JSON.stringify(lsPay&&lsPay.dsVatAmt)+')'); }
  else t(false, 'seq 31 줄 없음');
  console.log('ok', ok, 'bad', bad);
})().catch(e => { console.log('ERR', e); process.exit(1); });
