// 납기현황표(logistics_demo1.jsp) — 「정산 0」 구분 시뮬 (2026-11-24 사용자 「정산 0으로 구분해줘」)
//   정산서가 온 날 발주는 있는데 정산서 짝이 없어 «현재»(정산수량)가 0 이 된 줄을 「삭제」 가 아니라 「정산 0」 으로.
//   d2Aggregate 를 통째로 꺼내 돌린다(필요한 전역만 흉내). 실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_d2Settle0.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo1.jsp'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } };
const dom=new JSDOM('<body><input id="d2DateFrom" value="2026-09-22"><input id="d2DateTo" value="2026-09-22"><input type="checkbox" id="d2HistChk" checked><select id="d2BizSel"><option value="__ALL__" selected>전체</option></select><input id="d2Find" value=""><input id="d2ItemFind" value=""></body>',{ runScripts:'outside-only' });
const w=dom.window;
w.eval('var D2_DCGROUP={}, D2_DCSEL={}, D2_TODAY="2026-09-22", D2_PREV=[], D2_DATA=[], D2_FIND="", D2_IFIND="", D2_GORD=[];\n'
  +'function d2GordLoad(){}\nfunction d2MtNm(r){ return ""; }\nfunction d2Brand(r){ return r.biz; }\n'
  +pick('d2ShipQty')+'\n'+pick('d2MapRow')+'\n'+pick('d2Aggregate')+'\nwindow.M=d2MapRow; window.A=d2Aggregate; window.setPrev=function(p){ D2_PREV=p; }; window.setData=function(p){ D2_DATA=p; };');
const base={ dcNm:'용인물류센터', dcCd:'E100', inwh:'2', zone:'L3', bizCd:'A0397517', bizNm:'오티티스팟(부평점)', dlvDt:'20260922', shpoutDt:'20260922' };
const cur=[ Object.assign({}, base, { itemCd:'1000455370', itemNm:'아이스컵,20OZ', labelQty:1, settleYn:'Y', settleQty:0, jobSeq:4 }),     // 정산서 짝 없음 → 정산 0
            Object.assign({}, base, { itemCd:'1000736040', itemNm:'덮밥용기 뚜껑', labelQty:2, settleYn:'Y', settleQty:2, jobSeq:4 }) ];   // 정상
const prev=[ Object.assign({}, base, { itemCd:'1000455370', itemNm:'아이스컵,20OZ', labelQty:1, jobSeq:3 }),
             Object.assign({}, base, { itemCd:'1000736040', itemNm:'덮밥용기 뚜껑', labelQty:2, jobSeq:3 }),
             Object.assign({}, base, { itemCd:'1000999999', itemNm:'진짜 빠진 품목', labelQty:3, jobSeq:3 }) ];   // 이번 배치에 아예 없음 → 삭제
// ★2026-11-24 원복 (사용자 「납기현황표도 원래대로 원복해줘(오류수정은 유지하고)」) — 현재 = 정산서 온 날은 정산수량(같은 날 「현재 = 발주수량 · 정산 n 배지」로 바꿨다가 되돌림).
//   남긴 오류 수정 = 「정산 0」 구분(정산서 짝이 없어 0 이 된 줄을 «삭제» 로 보이지 않게) · 발주 쪽 수량 규칙(라벨수량 · 수량이 더 크면 수량)
const m0=w.M(cur[0],'2026-09-22'); T(m0.qty===0 && m0.settle===true && m0.ordQty===1 && m0.sQty===undefined, 'd2MapRow — 정산서 온 날 현재 = 정산수량 0 · 발주 원값 ordQty 1');
const m1=w.M(Object.assign({}, cur[0], {settleYn:''}),'2026-09-22'); T(m1.qty===1, '정산서 없는 날 = 발주수량 그대로');
const m2=w.M(Object.assign({}, cur[0], {settleYn:'', labelQty:1, curQty:6}),'2026-09-22'); T(m2.qty===6 && m2.ordQty===6, '발주 쪽 수량 = 라벨수량 · 수량이 더 크면 수량(1 · 6 → 6)');
w.setData(cur.map(o=>w.M(o,'2026-09-22'))); w.setPrev(prev.map(o=>w.M(o,'2026-09-22')));
const ag=w.A(); const zn=Object.keys(ag.zones)[0], z=ag.zones[zn];
const dr=(z.delRows||[]).map(r=>({code:r.code, s0:!!r.settle0, ord:r.ordQty}));
T(ag.histOn && Object.keys(z.rows).length===1 && z.rows[Object.keys(z.rows)[0]].code==='1000736040', '목록 = 정산수량이 있는 줄만(덮밥용기 뚜껑 2)');
T(dr.length===2 && dr.some(r=>r.code==='1000455370' && r.s0 && r.ord===1) && dr.some(r=>r.code==='1000999999' && !r.s0), '정산서 짝 없는 줄 = 「정산 0」(발주 1 그대로 있음) · 진짜 빠진 줄만 「삭제」 : '+JSON.stringify(dr));
T(src.indexOf("class=\"item '+(_s0?'r-s0':'r-del')")>=0 && /hist-badge s0/.test(src), '그리기 — 정산 0 은 취소선 없이 주황(r-s0) · 배지 「정산 0」');
T(!/d2SettleBadge|sQty/.test(src), '「정산 n」 배지·정산수량 따로 들기(sQty)는 걷어냈다(원복)');
console.log((bad?'✗':'✓')+' sim_d2Settle0 : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
