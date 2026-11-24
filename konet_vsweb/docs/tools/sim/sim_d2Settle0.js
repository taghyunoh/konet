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
  +pick('d2MapRow')+'\n'+pick('d2Aggregate')+'\nwindow.M=d2MapRow; window.A=d2Aggregate; window.setPrev=function(p){ D2_PREV=p; }; window.setData=function(p){ D2_DATA=p; };');
const base={ dcNm:'용인물류센터', dcCd:'E100', inwh:'2', zone:'L3', bizCd:'A0397517', bizNm:'오티티스팟(부평점)', dlvDt:'20260922', shpoutDt:'20260922' };
const cur=[ Object.assign({}, base, { itemCd:'1000455370', itemNm:'아이스컵,20OZ', labelQty:1, settleYn:'Y', settleQty:0, jobSeq:4 }),     // 정산서 짝 없음 → 정산 0
            Object.assign({}, base, { itemCd:'1000736040', itemNm:'덮밥용기 뚜껑', labelQty:2, settleYn:'Y', settleQty:2, jobSeq:4 }) ];   // 정상
const prev=[ Object.assign({}, base, { itemCd:'1000455370', itemNm:'아이스컵,20OZ', labelQty:1, jobSeq:3 }),
             Object.assign({}, base, { itemCd:'1000736040', itemNm:'덮밥용기 뚜껑', labelQty:2, jobSeq:3 }),
             Object.assign({}, base, { itemCd:'1000999999', itemNm:'진짜 빠진 품목', labelQty:3, jobSeq:3 }) ];   // 이번 배치에 아예 없음 → 삭제
// ★2026-11-24 「현재 = 발주수량」(사용자 「발주현황표 그때 당시 유지하면서」) — 정산서가 온 날도 수량은 발주수량, 정산수량은 sQty · 다르면 「정산 n」 배지
const m0=w.M(cur[0],'2026-09-22'); T(m0.qty===1 && m0.sQty===0 && m0.settle===true, 'd2MapRow — 현재 = 발주 1 · 정산수량 sQty 0 따로');
const m1=w.M(Object.assign({}, cur[0], {settleYn:''}),'2026-09-22'); T(m1.qty===1 && m1.sQty===null, '정산서 없는 날 = 발주 그대로 · sQty 없음');
w.setData(cur.map(o=>w.M(o,'2026-09-22'))); w.setPrev(prev.map(o=>w.M(o,'2026-09-22')));
const ag=w.A(); const zn=Object.keys(ag.zones)[0], z=ag.zones[zn];
const dr=(z.delRows||[]).map(r=>({code:r.code, s0:!!r.settle0}));
const rs0=Object.keys(z.rows).map(k=>z.rows[k]).find(r=>r.code==='1000455370');
T(ag.histOn && Object.keys(z.rows).length===2 && rs0 && rs0.qty===1 && rs0.settle && rs0.sQty===0, '정산서 짝 없는 줄도 목록에 그대로(현재 1 · 정산 0)');
T(dr.length===1 && dr[0].code==='1000999999' && !dr[0].s0, '「삭제」 는 이번 배치에 진짜 없는 줄만 : '+JSON.stringify(dr));
// 배지 — 정산수량이 발주와 다를 때만 「정산 n」
w.eval('function d2Num(v){ return String(v); }\n'+pick('d2SettleBadge')+'\nwindow.B=d2SettleBadge;');
T(/정산 0/.test(w.B(rs0)) && /hist-badge s0/.test(w.B(rs0)) && /짝을 못 찾았습니다/.test(w.B(rs0)), '정산 0 줄 = 「정산 0」 배지 + 원인 안내');
T(w.B({settle:true, qty:2, sQty:2})==='' && w.B({settle:false, qty:2})==='' && /정산 1/.test(w.B({settle:true, qty:2, sQty:1})), '같으면·정산서 없는 날은 배지 없음 · 다르면 「정산 1」');
T(/d2Esc\(r\.name\)\+d2SettleBadge\(r\)/.test(src), '목록 품목명 옆에 배지');

// 납기세부조회(출고장별 품목) — 같은 배지 (2026-11-24 「납기세부조회도 같은 방식으로」)
w.eval('var D2_UNIT="출고장"; function d2Esc(v){ return String(v==null?"":v).replace(/&/g,"&amp;").replace(/</g,"&lt;"); } function d2Num0(v){ return String(v); }\n'
  +['d2ZoneRank','d2ZonesSorted','d2GroupZones','d2DistCell','d2ZoneItemsFromAg','d2ZoneItemsTableHtml'].map(pick).join('\n')
  +'\nwindow.ZI=d2ZoneItemsTableHtml; window.ZF=d2ZoneItemsFromAg;');
const zi=w.ZF(ag)[0].items.find(r=>r.code==='1000455370'); T(zi && zi.qty===1 && zi.settle && zi.sQty===0, '납기세부조회 집계 — 1000455370 발주 1 · 정산 0');
const zh=w.ZI(ag); T(/아이스컵,20OZ <span class="hist-badge s0"[^>]*>정산 0<\/span>/.test(zh) && !/덮밥용기 뚜껑 <span class="hist-badge/.test(zh), '납기세부조회 표 — 다른 줄에만 「정산 0」 배지');
T((src.match(/d2SettleBadge\(r\)/g)||[]).length===4, '배지 자리 4곳(출고장별 · 납기세부조회 · 품목별 · 사업장별)');
console.log((bad?'✗':'✓')+' sim_d2Settle0 : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
