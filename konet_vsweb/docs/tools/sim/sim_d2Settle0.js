// 납기현황표(logistics_demo1.jsp) — 수량은 «늘» 발주현황표 (2026-11-24 저녁 사용자 「납기현황표는 정산서와 상관없이 발주현황표 받은대로」)
//   종전(같은 날 낮) : 정산서 온 날은 정산수량 · 짝이 없어 0 이 된 줄은 「정산 0」 구분. 지금은 정산서가 와도 수량을 갈아 끼우지 않는다 — 「정산 0」 줄이 생기지 않는다.
//   d2Aggregate 를 통째로 꺼내 돌린다(필요한 전역만 흉내). 실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_d2Settle0.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const R=p=>fs.readFileSync(path.join(__dirname,'../../..',p),'utf8').replace(/\r\n/g,'\n');
const src=R('src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo1.jsp'), J=R('src/main/java/egovframework/konet/user/service/impl/UserServiceImpl.java');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } };
const dom=new JSDOM('<body><input id="d2DateFrom" value="2026-09-22"><input id="d2DateTo" value="2026-09-22"><input type="checkbox" id="d2HistChk" checked><select id="d2BizSel"><option value="__ALL__" selected>전체</option></select><input id="d2Find" value=""><input id="d2ItemFind" value=""></body>',{ runScripts:'outside-only' });
const w=dom.window;
w.eval('var D2_DCGROUP={}, D2_DCSEL={}, D2_TODAY="2026-09-22", D2_PREV=[], D2_DATA=[], D2_FIND="", D2_IFIND="", D2_GORD=[];\n'
  +'function d2GordLoad(){}\nfunction d2MtNm(r){ return ""; }\nfunction d2Brand(r){ return r.biz; }\n'
  +pick('d2ShipQty')+'\n'+pick('d2MapRow')+'\n'+pick('d2Aggregate')+'\nwindow.M=d2MapRow; window.A=d2Aggregate; window.setPrev=function(p){ D2_PREV=p; }; window.setData=function(p){ D2_DATA=p; };');
const base={ dcNm:'용인물류센터', dcCd:'E100', inwh:'2', zone:'L3', bizCd:'A0397517', bizNm:'오티티스팟(부평점)', dlvDt:'20260922', shpoutDt:'20260922' };
const cur=[ Object.assign({}, base, { itemCd:'1000455370', itemNm:'아이스컵,20OZ', labelQty:1, settleYn:'Y', settleQty:0, jobSeq:4 }),     // 정산서엔 짝이 없다(정산 0) — 그래도 발주 1 그대로
            Object.assign({}, base, { itemCd:'1000736040', itemNm:'덮밥용기 뚜껑', labelQty:8, settleYn:'Y', settleQty:2, jobSeq:4 }) ];   // 정산서는 2개만 출고 — 그래도 발주 8 그대로
const prev=[ Object.assign({}, base, { itemCd:'1000455370', itemNm:'아이스컵,20OZ', labelQty:1, jobSeq:3 }),
             Object.assign({}, base, { itemCd:'1000736040', itemNm:'덮밥용기 뚜껑', labelQty:8, jobSeq:3 }),
             Object.assign({}, base, { itemCd:'1000999999', itemNm:'진짜 빠진 품목', labelQty:3, jobSeq:3 }) ];   // 이번 배치에 아예 없음 → 삭제
const m0=w.M(cur[0],'2026-09-22'); T(m0.qty===1 && m0.settle===false, '정산서가 와도(정산 0) 수량 = 발주현황표 1 · 정산 표시 없음');
const m1=w.M(cur[1],'2026-09-22'); T(m1.qty===8, '정산서가 2개만 출고로 와도 수량 = 발주현황표 8');
const m2=w.M(Object.assign({}, cur[0], {settleYn:'', labelQty:1, curQty:6}),'2026-09-22'); T(m2.qty===1 && m2.ordQty===1, '수량 = 라벨수량 그대로 — 수량 칸이 더 커도(1 · 6) 라벨수량 1 (2026-11-24 저녁 「납기현황표는 라벨수량 그대로 보여줘」)');
const m3=w.M(Object.assign({}, cur[0], {settleYn:'', labelQty:null, curQty:5}),'2026-09-22'), m4=w.M(Object.assign({}, cur[0], {settleYn:'', labelQty:0, curQty:5}),'2026-09-22');
T(m3.qty===5 && m4.qty===0, '라벨수량이 없는 옛 줄만 수량(5) · 라벨수량 0 은 0 그대로');
w.setData(cur.map(o=>w.M(o,'2026-09-22'))); w.setPrev(prev.map(o=>w.M(o,'2026-09-22')));
const ag=w.A(); const zn=Object.keys(ag.zones)[0], z=ag.zones[zn];
const rows=Object.keys(z.rows).map(k=>z.rows[k].code).sort(), dr=(z.delRows||[]).map(r=>({code:r.code, s0:!!r.settle0}));
T(rows.join(',')==='1000455370,1000736040', '목록 = 발주현황표 줄 그대로(둘 다 보인다) : '+rows.join(','));
T(dr.length===1 && dr[0].code==='1000999999' && !dr[0].s0 && !z.s0, '이력 대조 — 진짜 빠진 줄만 「삭제」 · 「정산 0」 줄은 생기지 않는다 : '+JSON.stringify(dr));
T(src.indexOf("qty:d2ShipQty(o),\n             settle:false,")>0 && !/d2SettleBadge|sQty/.test(src), 'd2MapRow — 수량 = d2ShipQty · settle 늘 false (「정산 n」 배지도 없음)');
T(J.indexOf('double v = r.getLabelQty() != null ? r.getLabelQty().doubleValue() : (r.getCurQty() == null ? 0 : r.getCurQty().doubleValue());')>0 && J.indexOf('"Y".equals(scStr(r.getSettleYn()))')<0 && J.indexOf('shipQtyOf')<0, '진행 현황 「업무 진행 상황」 납기수량(자바)도 같은 셈 — 라벨수량 그대로 · 정산 배분 수량을 쓰지 않는다');
console.log((bad?'✗':'✓')+' sim_d2Settle0 : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
