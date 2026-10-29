// 동원홈푸드 등록 (2026-10-29) — 화면 JS 를 jsdom 에 그대로 태운다. 실제 엑셀(직송발주정보_주문내역)을 SheetJS 로 읽어 parseWb 에 넣는다.
//   NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_dongwonPo.js [엑셀경로]
const fs = require('fs'), path = require('path'), vm = require('vm');
const { JSDOM } = require('jsdom');
const ROOT = path.join(__dirname, '../../..');
let src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/dongwonPo.jsp'), 'utf8').replace(/\r\n/g, '\n');
src = src.replace(/<%--[\s\S]*?--%>/g, '').replace(/\$\{pageContext\.request\.contextPath\}/g, '').replace(/<%@[^%]*%>/g, '');
const html = src.replace(/<script src="[^"]*"><\/script>/g, '');
const dom = new JSDOM(html, { runScripts: 'outside-only', pretendToBeVisual: true });
const w = dom.window;
let ok = 0, bad = 0; const t = (c, m) => { if (c) ok++; else { bad++; console.log('FAIL', m); } };
const CALLS = [];
w.fetch = (url, o) => { CALLS.push({ url, body: o && o.body });
  const J = x => Promise.resolve({ ok: true, json: () => Promise.resolve(x), text: () => Promise.resolve(typeof x === 'string' ? x : JSON.stringify(x)) });
  if (/clientList/.test(url)) return J({ data: [{ bizCd: '2-18', bizNm: '성수 샐러링' }, { bizCd: 'T001', bizNm: '테그42 대구성서홈플러스점' }, { bizCd: 'A0001', bizNm: '성수CK' }] });
  if (/prodList/.test(url)) return J({ data: [
    { prodCd: '9904012901', prodNm: '70파이 2온스 소스용기', salePrice: 95000, spec: '3,000EA/BOX', taxGb: '과세' },
    { prodCd: '9904012902', prodNm: '70파이 2온스 소스뚜껑', salePrice: 70000, spec: '3,000EA/BOX', taxGb: '과세' },
    { prodCd: '9904012903', prodNm: '종이 스프 뚜껑', salePrice: 0, spec: '500EA/BOX', taxGb: '과세' },
    { prodCd: '9904012904', prodNm: '테그 로고봉투 대', salePrice: 50000, spec: '1,500EA/BOX', taxGb: '면세' }] });
  if (/extItemList/.test(url)) return J({ data: [{ extItemCd: '640862', prodCd: '9904012901', extItemNm: '[C]70파이 2온스 소스용기 투명' }] });
  if (/contractList/.test(url)) return J({ data: [{ prodCd: '9904012903', contractPrice: 20000, frDt: '20261001', toDt: '' }, { prodCd: '9904012903', contractPrice: 15000, frDt: '20250101', toDt: '20250930' }, { prodCd: '9904012902', contractPrice: 99999, frDt: '20261201', toDt: '' }] });
  if (/selectVendorMst/.test(url)) return J({ data: [{ vendorCd: 'DONGWON', vendorNm: '동원홈푸드', vatGb: w.__VAT || '별도' }] });
  if (/dongwonPoMap/.test(url)) return J({ biz: {}, item: {}, dwcd: { '640863': '9904012902' }, price: { '9904012902': '48000' } });
  if (/dongwonPoSave/.test(url)) return J('4');
  if (/dongwonPoList/.test(url)) return J({ data: w.__LS || [] });
  return J({});
};
w._alertBox = (m) => { w.__alerts = (w.__alerts || []).concat([String(m)]); }; w._confirmBox = (o) => { w.__cfm = o; }; w._toast = () => {};
const XLSX = require(path.join(ROOT, 'src/main/webapp/assets/vendor/sheetjs/xlsx.full.min.js'));
w.XLSX = XLSX;
const m = /<script>\n([\s\S]*?)<\/script>/.exec(html); vm.runInContext(m[1], dom.getInternalVMContext());
const XL = process.argv[2] || path.join(process.env.TEMP || '', 'claude/C--Users-HYUN-git-konet-konet-vsweb/2cef5e45-8ffe-48de-bc3e-ff1ca4bfdb57/scratchpad/xin/dw.xlsx');
(async () => {
  await new Promise(r => setTimeout(r, 40));
  t(w._biz['2-18'] === '성수 샐러링' && w._prod['640862'] != null && w._main['640862'] === '9904012901', '기준자료 로드(사업장·매칭코드·주코드)');
  t(w.taxOf('640862') === '과세' && w.taxOf('9904012904') === '면세', '과세 구분(매칭코드는 주코드)');
  // ── 엑셀 읽기 ──
  const wb = XLSX.read(fs.readFileSync(XL), { type: 'buffer', cellDates: true });
  const rows = w.parseWb(wb, '직송발주정보_주문내역_20261029.xlsx');
  t(rows.length === 4, '4줄 (' + rows.length + ')');
  const r0 = rows[0];
  t(r0.dlvDt === '2026-10-29', '배송일자 KST 29일 (' + r0.dlvDt + ')');
  t(r0.dwItemCd === '640862' && r0.qty === 1 && r0.ordNo === '1060864642' && r0.no === '1' && r0.reqNo === 'P261026-396842', '상품코드·수량·주문번호·순번·의뢰번호');
  t(r0.bizNm === '샐러링 성수본점(신)' && r0.bizCode === '208437' && /성동구/.test(r0.rcvAddr) && r0.rcvTel === '010-9925-4789', '배송처·코드·주소·연락처');
  t(r0.spec === '3,000EA/BOX' && r0.unit === 'BOX' && r0.status === '납품확정' && r0.chk === true, '규격·단위·상태');
  t(rows[1].no === '2' && rows[1].ordNo === r0.ordNo, '같은 주문의 둘째 줄 순번 2');
  // ── 자동 매칭 ──
  w._pv = rows; w.autoFill(); w.pvRender();
  t(r0.itemCd === '640862' && r0.itemHow === '매칭' && w.mainOf(r0.itemCd) === '9904012901', '동원코드가 매칭코드 → 그 코드 그대로 품목코드(주코드는 서버 resolve) 「매칭」 (' + r0.itemCd + ' ' + r0.itemHow + ')');
  t(r0.price === 95000 && r0.priceSrc === '판매가', '단가 = 상품 판매가(지난 저장·계약 없음) (' + r0.price + ' ' + r0.priceSrc + ')');
  t(rows[1].itemCd === '9904012902' && rows[1].itemHow === '자동' && rows[1].price === 48000 && rows[1].priceSrc === '지난 저장', '둘째 줄 : 지난 저장 코드 매칭 + 지난 단가 48,000 (' + rows[1].price + ' ' + rows[1].priceSrc + ')');
  t(rows[2].itemCd === '' && rows[3].itemCd === '', '셋째·넷째 줄 품목 미매칭');
  t(r0.bizCd === '2-18' && r0.bizGuess === true, '배송처 「샐러링 성수본점(신)」 → 추정 「성수 샐러링」 (' + r0.bizCd + ')');
  t(rows[3].bizCd === 'T001' && rows[3].bizGuess === true, '「테그42 대구성서홈플러스점(신)」 → 추정 (' + rows[3].bizCd + ')');
  const a0 = w.amtOf(r0); t(a0.sup === 95000 && a0.vat === 9500 && a0.tot === 104500, '공급가·부가세·합계');
  // ── 코드 넣기 → 단가 차례(계약) · 면세 ──
  w.setCd(2, 'item', '9904012903');
  t(rows[2].itemCd === '9904012903' && rows[2].price === 20000 && rows[2].priceSrc === '계약', '스프 뚜껑 : 계약단가 20,000(시작 10-01 · 옛 계약 15,000 제외) (' + rows[2].price + ' ' + rows[2].priceSrc + ')');
  w.setCd(3, 'item', '테그 로고봉투 대 [9904012904]');
  t(rows[3].itemCd === '9904012904' && rows[3].price === 50000, '「명칭 [코드]」로 고르기 + 판매가');
  const a3 = w.amtOf(rows[3]); t(a3.vat === 0 && a3.tot === 50000, '면세 품목 부가세 0');
  t(w.priceOf('9904012902', '2026-10-29').p === 48000, '지난 저장이 계약(12-01 시작, 아직 아님)·판매가보다 먼저');
  t(w.priceOf('9904012902', '2026-12-05').src === '지난 저장', '지난 저장 있으면 계약 시작 뒤에도 지난 저장');
  // ── 단가 손으로 고치기 ──
  const inp = { value: '90000' }; w.pvPrice(0, inp);
  t(r0.price === 90000 && r0.priceEdited === true && r0.priceSrc === '', '단가 고침 → 출처 배지 없음');
  const info = w.document.getElementById('pvInfo').textContent;
  t(/저장 가능 4/.test(info) && /공급가 /.test(info), '요약줄 : 저장 가능 4 · 공급가 (' + info + ')');
  // ── 저장 payload ──
  w.save(); const cfm = w.__cfm; t(cfm && /4<\/b>줄/.test(cfm.msg) && /부가세/.test(cfm.msg), '확인창 : 4줄 · 부가세 표기');
  cfm.onOk(); await new Promise(r => setTimeout(r, 30));
  const sv = CALLS.find(c => /dongwonPoSave/.test(c.url)); t(!!sv, '저장 호출');
  const body = JSON.parse(sv.body); const b0 = body.rows[0];
  t(body.rows.length === 4 && b0.unit === '3,000EA/BOX' && b0.dwItemCd === '640862' && b0.bizCd === '2-18' && b0.itemCd === '640862' && b0.price === 90000 && b0.no === '1' && b0.reqNo === 'P261026-396842' && b0.bizCode === '208437' && /성동구/.test(b0.rcvAddr), '저장 줄 : 단위=규격 · 동원코드 · 코드 · 단가 · 순번 · 의뢰번호 · 배송처코드 · 주소');
  t(w._pv.length === 0 && w._map.dwcd['640862'] === '640862' && w._map.price['9904012903'] === '20000', '저장 뒤 비움 + 매칭·단가 기억');
  // ── 직접 입력 ──
  w.mAdd(); const mr = w._pv[0]; t(mr && mr.manual && mr.qty === 1, '직접 줄 생성');
  w.setCd(0, 'biz', '2-18'); w.setCd(0, 'item', '9904012903');
  t(mr.price === 20000 && mr.priceSrc === '지난 저장' && mr.unit === '500EA/BOX', '직접 줄 : 코드 고르면 단가(방금 저장한 20,000 = 지난 저장)·규격 ('+mr.price+' '+mr.priceSrc+' '+mr.unit+')');
  w.mPrep([mr]); t(/^DW\d{12}-1$/.test(mr.ordNo) && mr.no === '1' && mr.bizNm === '성수 샐러링' && mr.itemNm === '종이 스프 뚜껑', '직접 줄 저장 준비 : 주문번호 DW+일시 · 순번 1 · 이름 채움 (' + mr.ordNo + ')');
  w._pv = []; w.pvRender();
  // ── 저장 목록 · 매출장부 ──
  w.__LS = [
    { seq: 1, dlvDt: '20261029', ordNo: '1060864642', lineNo: '1', reqNo: 'P1', bizCd: '2-18', bizNm: '샐러링 성수본점(신)', itemCd: '9904012901', itemNm: '[C]70파이 2온스 소스용기', dwItemCd: '640862', rcvAddr: '서울', rcvTel: '010', unit: '3,000EA/BOX', qty: 1, prodCd: '9904012901', salePrice: 95000, remark: '동원홈푸드 발주', srcFile: 'f.xlsx', uploadDttm: '2026-10-29 10:00:00', regUser: 'admin' },
    { seq: 2, dlvDt: '20261029', ordNo: '1060864642', lineNo: '2', reqNo: 'P1', bizCd: '2-18', bizNm: '샐러링 성수본점(신)', itemCd: '9904012902', itemNm: '[C]70파이 2온스 소스뚜껑', dwItemCd: '640863', rcvAddr: '서울', rcvTel: '010', unit: '3,000EA/BOX', qty: 2, prodCd: '9904012902', salePrice: 48000, remark: '', srcFile: 'f.xlsx', uploadDttm: '2026-10-29 10:00:00', regUser: 'admin' },
    { seq: 3, dlvDt: '20261030', ordNo: '1060888760', lineNo: '1', reqNo: 'P2', bizCd: 'T001', bizNm: '테그42 대구성서홈플러스점(신)', itemCd: '9904012904', itemNm: '[C]테그 로고봉투 대', dwItemCd: '640836', rcvAddr: '대구', rcvTel: '010', unit: '1,500EA/BOX', qty: 1, prodCd: '9904012904', salePrice: 50000, remark: '동원홈푸드 발주 · 수정 10-29 11:00 수량 2→1', srcFile: 'f.xlsx', uploadDttm: '2026-10-29 10:00:00', regUser: 'admin' },
    { seq: 4, dlvDt: '20261030', ordNo: '1060888760', lineNo: '2', reqNo: 'P2', bizCd: 'T001', bizNm: '테그42 대구성서홈플러스점(신)', itemCd: '9904012901', itemNm: 'x', dwItemCd: '640862', rcvAddr: '대구', rcvTel: '010', unit: '', qty: 0, prodCd: '9904012901', salePrice: 95000, remark: '전량 반품', srcFile: 'f.xlsx', uploadDttm: '', regUser: '' }];
  w.load(); await new Promise(r => setTimeout(r, 30));
  const lsInfo = w.document.getElementById('lsInfo').textContent;
  t(/4줄/.test(lsInfo) && /공급가 241,000/.test(lsInfo) && /부가세 19,100/.test(lsInfo) && /합계 260,100/.test(lsInfo), '목록 합계 : 공급가 241,000 · 부가세 19,100(면세 50,000 제외) · 합계 260,100 (' + lsInfo + ')');
  t(w.document.querySelectorAll('#lsBody tr').length === 4 && w.document.querySelectorAll('#lsBody tr:first-child td').length === 18, '목록 4줄 · 칸 18 = 머리글');
  const lg = w.lgBuild(w.__LS);
  t(lg.cnt === 3 && lg.bizCnt === 2, '매출장부 : 수량 0 줄 제외 → 3줄 · 배송처 2곳 (' + lg.cnt + ',' + lg.bizCnt + ')');
  const kinds = lg.lines.map(o => o.k).join(',');
  t(kinds === 'row,row,day,sub,row,day,sub,tot', '줄 차례 row,row,day,sub,row,day,sub,tot (' + kinds + ')');
  const rowsLg = lg.lines.filter(o => o.k === 'row');
  t(rowsLg[0].biz === '성수 샐러링' && rowsLg[1].biz === '' && rowsLg[0].nm === '[C]70파이 2온스 소스용기' && rowsLg[0].spec === '3,000EA/BOX', '배송처는 첫 줄만 · 상품명·규격 = 동원 것');
  t(rowsLg[0].sup === 95000 && rowsLg[0].vat === 9500 && rowsLg[1].sup === 96000 && rowsLg[1].run === 104500 + 105600, '공급가·부가세·누계 (' + rowsLg[1].run + ')');
  t(lg.lines[2].tot === 210100 && lg.lines[3].tot === 210100 && lg.lines[7].tot === 260100 && lg.sup === 241000 && lg.vat === 19100, '일계·소계·합계 (' + lg.lines[7].tot + ')');
  t(rowsLg[2].vat === 0 && rowsLg[2].rmk === '수정 있음', '면세 줄 부가세 0 · 수정 표시');
  // 엑셀 — 머리글 칸 수 = 본문 칸 수 · 시트 이름
  const realWrite = XLSX.writeFile; XLSX.writeFile = (wb, nm) => { w.__xls = { wb, nm }; };
  w._lg = lg; w._lg.fr = '2026-10-01'; w._lg.to = '2026-10-31'; w.lgXls(); XLSX.writeFile = realWrite;
  const ws = w.__xls.wb.Sheets[w.__xls.wb.SheetNames[0]];
  t(w.__xls.wb.SheetNames[0] === '동원홈푸드_20261001~20261031' && /동원홈푸드 매출장부_/.test(w.__xls.nm), '시트 이름 · 파일 이름');
  t(ws['A5'].v === '배송처' && ws['N5'].v === '비고' && ws['O5'] == null, '머리글 14칸');
  t(ws['A6'].v === '성수 샐러링' && ws['J6'].v === 95000 && ws['K6'].v === 9500 && ws['L6'].v === 104500 && ws['M6'].v === 104500, '본문 첫 줄 공급가·부가세·합계·누계');
  t(ws['B6'].t === 'n' && ws['B6'].z === 'yyyy-mm-dd', '배송일자 날짜 서식');
  t(ws['A8'].v === '' && ws['B8'].v === '일계' && ws['L8'].v === 210100, '일계 줄');
  // 단추 한 번 = 바로 엑셀 (창 없음)
  t(typeof w.lgOpen === 'undefined' && w.document.getElementById('lgPop') == null, '미리보기 창·함수 없음');
  w.__xls = null; XLSX.writeFile = (wb, nm) => { w.__xls = { wb, nm }; };
  w.document.getElementById('fr').value = '2026-10-01'; w.document.getElementById('to').value = '2026-10-31'; w.lgXlsNow(); await new Promise(r => setTimeout(r, 30)); XLSX.writeFile = realWrite;
  t(w.__xls && w.__xls.wb.SheetNames[0] === '동원홈푸드_20261001~20261031', '[📒 매출장부] = 목록 기간으로 바로 엑셀');
  w.__LS = []; w.__xls = null; w.__alerts = []; w.lgXlsNow(); await new Promise(r => setTimeout(r, 30));
  t(!w.__xls && w.__alerts.some(x => /없습니다/.test(x)), '줄이 없으면 안내만');
  // ── 거래처 부가세 구분 = 포함 (2026-10-30 「토더처럼 부가세 포함으로 설정했는데 … 기준정보 따르지 않는지」) ──
  w.__VAT = '포함'; w._venVat = '별도'; w.loadMasters(); await new Promise(r => setTimeout(r, 30));
  t(w._venVat === '포함', '거래처관리 VAT_GB 를 읽는다 (' + w._venVat + ')');
  const ai = w.amtOf({ itemCd: '9904012901', qty: 1, price: 11000 }); t(ai.tot === 11000 && ai.sup === 10000 && ai.vat === 1000, '포함 : 단가 11,000 → 합계 11,000 · 공급가 10,000 · 부가세 1,000 (' + JSON.stringify(ai) + ')');
  const af = w.amtOf({ itemCd: '9904012904', qty: 2, price: 50000 }); t(af.tot === 100000 && af.vat === 0 && af.sup === 100000, '포함이어도 면세 품목은 부가세 0');
  const al = w.lsAmt({ itemCd: '9904012902', qty: 3, salePrice: 10000 }); t(al.tot === 30000 && al.sup === 27273 && al.vat === 2727, '저장 목록도 같은 규칙 (' + JSON.stringify(al) + ')');
  const th = w.document.querySelector('#pvWrap th[title*="부가세"]'); t(th && /부가세 포함/.test(th.title) && !/부가세 별도/.test(th.title), '머리글 설명이 「부가세 포함」으로 (' + (th && th.title) + ')');
  w.__VAT = '면세'; w.loadMasters(); await new Promise(r => setTimeout(r, 30)); const an = w.amtOf({ itemCd: '9904012901', qty: 1, price: 11000 }); t(an.vat === 0 && an.sup === 11000, '거래처 면세 → 부가세 0');
  w.__VAT = ''; w.loadMasters(); await new Promise(r => setTimeout(r, 30)); t(w._venVat === '별도', '구분이 비면 종전대로 별도');
  console.log('동원홈푸드 등록 시뮬 : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
