// 정산서 누락 조회(mangr/settleGap.jsp) 시뮬 (2026-11-24) — 세 탭 · 원인 · 요약 · 거르기 · 엑셀 · 다른 화면이 넘긴 기간
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_settleGap.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const W=path.join(__dirname,'../../../src/main/webapp/');
const src=fs.readFileSync(W+'WEB-INF/jsp/main/mangr/settleGap.jsp','utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const DATA=[
  { gb:'S', reason:'DAY',  dlvDt:'20260921', dcCd:'E500', dcNm:'평택', ordNo:'5060050373', itemCd:'1000800551', prodCd:'1000800551', itemNm:'(PAZAC)박스대', qty:7, lineCnt:1, otherProdCd:null },
  { gb:'S', reason:'CODE', dlvDt:'20260101', dcCd:'E500', dcNm:'평택', ordNo:'5056771543', itemCd:'1000455370', prodCd:'9904013345', itemNm:'아이스컵,20OZ', qty:1, lineCnt:1, otherProdCd:'1000455370' },
  { gb:'S', reason:'ITEM', dlvDt:'20260110', dcCd:'E700', dcNm:'오산', ordNo:'5056800000', itemCd:'1000700001', prodCd:'1000700001', itemNm:'종이컵', qty:2, lineCnt:1, otherProdCd:null },
  { gb:'O', reason:'CODE', dlvDt:'20260101', dcCd:'E500', dcNm:'평택', ordNo:'5056771543', itemCd:'1000455370', prodCd:'1000455370', itemNm:'아이스컵,20OZ', bizNm:'카페홈즈 신대방점', bizCnt:2, qty:1, lineCnt:1, otherProdCd:'9904013345' },
  { gb:'O', reason:'ITEM', dlvDt:'20260105', dcCd:'E100', dcNm:'용인', ordNo:'5056790000', itemCd:'1000600001', prodCd:'1000600001', itemNm:'빨대', bizNm:'파작(종로점)', bizCnt:1, qty:3.5, lineCnt:1, otherProdCd:null },
  { gb:'N', reason:'NOSETTLE', dlvDt:'20261123', dcCd:'E500', dcNm:'평택', ordNo:'', itemCd:'', prodCd:'', itemNm:'', bizNm:null, bizCnt:4, qty:120, lineCnt:80, otherProdCd:null },
];
let lastBody='';
async function boot(parentRange){
  const html=src.replace(/<%@[\s\S]*?%>/g,'').replace(/<%--[\s\S]*?--%>/g,'').replace(/\$\{pageContext\.request\.contextPath\}/g,'/konet').replace(/<script src=[^>]*><\/script>/g,'').replace(/<body[^>]*>/,'<body data-comp="(주)코네트">');
  const dom=new JSDOM(html,{ runScripts:'outside-only', url:'http://x/konet/mangr/settleGap.do', pretendToBeVisual:true });
  const w=dom.window;
  if(parentRange){ const P={ konetSettleGapRange:parentRange, document:w.document }; Object.defineProperty(w,'parent',{ value:P, configurable:true }); }
  w.fetch=(u,o)=>{ lastBody=o&&o.body; return Promise.resolve({ json:()=>Promise.resolve({ result:'OK', data:JSON.parse(JSON.stringify(DATA)), frDt:'20260101', toDt:'20261124' }) }); };
  w._alertBox=(m)=>{ w.__alert=m; }; w._toast=()=>{};
  w.eval(fs.readFileSync(W+'assets/vendor/xlsx-js-style/xlsx.bundle.js','utf8'));
  const scr=[...src.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1].replace(/\$\{pageContext\.request\.contextPath\}/g,'/konet')).join('\n');
  w.eval(scr+'\n;window.__t={ render:render, tabGo:tabGo, excel:excel, picked:picked };');
  await new Promise(r=>setTimeout(r,20));
  return w;
}
(async()=>{
  let w=await boot(); const $=s=>w.document.querySelector(s), $$=s=>[...w.document.querySelectorAll(s)];
  T(/frDt=\d{4}-\d{2}-01/.test(lastBody), '처음 = 이번 달로 조회');
  T($('#frDt').value==='2026-01-01' && $('#toDt').value==='2026-11-24', '서버가 돌려준 기간으로 맞춤');
  const kp=$$('#sumbox .kpi').map(k=>k.textContent);
  T(/정산서만 있음/.test(kp[0]) && /3줄/.test(kp[0]) && /미업로드 1 · 코드 다름 1 · 발주현황표에 없는 발주 1/.test(kp[0]), '요약 ① 정산서만 3줄 · 원인별 : '+kp[0]);
  T(/정산서 누락/.test(kp[1]) && /2줄/.test(kp[1]) && /코드 다름 1 · 정산서에 없는 발주 1/.test(kp[1]), '요약 ② 발주현황표만 2줄');
  T(/정산서 안 온 날/.test(kp[2]) && /1곳/.test(kp[2]) && /80줄/.test(kp[2]), '요약 ③ 정산서 안 온 날 1곳');
  T(/상품코드 다름/.test(kp[3]) && /2건/.test(kp[3]), '요약 ④ 상품코드 다름 양쪽 2건');
  // 정산서만 탭(처음)
  let rows=$$('#body tr'); T($('#tabs .t.on').getAttribute('data-v')==='S' && rows.length===4, '처음 탭 = 정산서만 있음 · 3줄 + 합계');
  const code=rows.find(r=>/상품코드 다름/.test(r.textContent));
  T(code && /9904013345/.test(code.textContent) && code.querySelector('.cd.diff') && /1000455370/.test(code.cells[6].textContent), '상품코드 다름 줄 = 정산서 9904013345 ↔ 발주현황표 1000455370');
  const day=rows.find(r=>/발주현황표 미업로드/.test(r.textContent)); T(day && /발주현황표 없음/.test(day.cells[6].textContent), '발주현황표 미업로드 줄');
  T(/합계 3줄/.test($('#body tr.tot').textContent) && /10/.test($('#body tr.tot').textContent), '합계 3줄 · 수량 10');
  T(/정산서에는 있는데/.test($('#help').textContent), '탭 설명');
  T(/매칭코드로 묶인 하위 코드/.test($('#help').textContent) && /매칭코드로 안 묶인/.test($$('#sumbox .kpi')[3].textContent), '주코드 매칭은 같은 품목으로 본다는 안내 (2026-11-24)');
  // 원인 거르기
  $('#rs').value='CODE'; w.__t.render(); T($$('#body tr').length===2, '원인 = 상품코드 다름 → 1줄'); $('#rs').value=''; w.__t.render();
  // 물류센터 목록·거르기
  T($$('#dc option').map(o=>o.textContent).join()==='전체,용인,평택,오산', '물류센터 목록(자료에서) : '+$$('#dc option').map(o=>o.textContent).join());
  $('#dc').value='E500'; w.__t.render(); T($$('#body tr').length===3, '물류센터 = 평택 → 2줄'); $('#dc').value=''; w.__t.render();
  // 찾기
  $('#q').value='아이스'; w.__t.render(); T($$('#body tr').length===2, '찾기 「아이스」 → 1줄'); $('#q').value=''; w.__t.render();
  // 발주현황표만 탭
  w.__t.tabGo('O'); rows=$$('#body tr');
  T(rows.length===3 && /카페홈즈 신대방점/.test(rows.map(r=>r.textContent).join()) && /외 1곳/.test($('#body').textContent) && $$('#head th').length===10, '발주현황표만 = 2줄 · 사업장(외 n곳) 칸');
  T(/정산서가 빠진 줄/.test($('#help').textContent), '탭 설명(정산서 누락)');
  T([...w.document.querySelectorAll('#body tr')].some(r=>/정산서에 없는 발주/.test(r.textContent)) && $('#rs option[value="ITEM"]').textContent==='정산서에 없는 발주', '발주현황표만 탭의 ITEM = 「정산서에 없는 발주」 (이름 바꿈 2026-11-24)');
  // 정산서 안 온 날 탭
  w.__t.tabGo('N'); rows=$$('#body tr');
  T(rows.length===2 && /2026-11-23/.test(rows[0].textContent) && /평택/.test(rows[0].textContent) && $('#rs').disabled, '정산서 안 온 날 = 1곳 · 원인 고르기는 잠김');
  // 요약 카드 누르면 그 탭
  w.Function($$('#sumbox .kpi')[1].getAttribute('onclick'))(); T($('#tabs .t.on').getAttribute('data-v')==='O', '요약 카드 누르면 그 탭');
  // 엑셀
  let saved=null; w.XLSX.writeFile=(wb,nm)=>{ saved={wb,nm}; };
  w.__t.tabGo('S'); w.__t.excel(); let ws=saved.wb.Sheets[saved.wb.SheetNames[0]];
  T(/^정산서누락조회_정산서만_\d{8}-\d{8}\.xlsx$/.test(saved.nm) && ws.A1.v==='정산서 누락 조회 — 정산서만 있음' && ws.A4.v==='원인' && ws.A4.s.fill.fgColor.rgb==='DDEBF7', '엑셀 = 탭 이름 · 제목 · 하늘색 머리 : '+saved.nm);
  T(ws.A5 && /발주현황표 미업로드|상품코드 다름|발주현황표에 없는 발주/.test(ws.A5.v) && ws['A8'].v==='합계 3줄' && ws['A8'].s.fill.fgColor.rgb==='FFE699', '엑셀 줄 · 노란 합계');
  w.__t.tabGo('O'); w.__t.excel(); ws=saved.wb.Sheets[saved.wb.SheetNames[0]]; T(ws.I4.v==='사업장' && /발주현황표만/.test(saved.nm), '엑셀 발주현황표만 = 사업장 칸');
  // 상품코드 다름이 0건이면 4번째 칸을 빼고 세 칸으로 (2026-11-24)
  T(!$('#sumbox').classList.contains('n3') && $$('#sumbox .kpi').length===4, '상품코드 다름이 있으면 4칸');
  // 다른 화면(월별 출고현황)이 넘긴 기간으로 연다
  w=await boot({ fr:'20260901', to:'20260930', tab:'S' });
  T(/frDt=2026-09-01&toDt=2026-09-30/.test(lastBody), '셸이 넘긴 기간(9월)으로 조회 : '+lastBody);
  // 상품코드 다름 0건 → 4번째 칸 없음 · 세 칸 (2026-11-24 사용자 「0건 표시는」)
  for(let i=DATA.length-1;i>=0;i--) if(DATA[i].reason==='CODE') DATA.splice(i,1);
  w=await boot(); const k3=[...w.document.querySelectorAll('#sumbox .kpi')];
  T(k3.length===3 && w.document.getElementById('sumbox').classList.contains('n3') && !/상품코드 다름 \(양쪽\)/.test(w.document.getElementById('sumbox').textContent), '상품코드 다름 0건 = 세 칸만');
  console.log((bad?'✗':'✓')+' sim_settleGap : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})();
