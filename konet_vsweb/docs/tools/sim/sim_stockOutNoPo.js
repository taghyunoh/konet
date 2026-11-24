// 월별 출고현황 — 「발주현황표가 없는 날」 알림 줄 시뮬 (2026-11-24)
//   · 한 줄 요약만 · 검색한 품목에 해당하는 날만 · 날짜·센터 목록은 마우스 올림(title)
//   · [자세히]·[정산서 누락 조회 →] 링크는 뺐다 (2026-11-24 사용자 「여기에서는 제거」 — 정산서 누락 조회는 매출 관리의 별도 메뉴)
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_stockOutNoPo.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const dom=new JSDOM('<body><input id="q"><input id="frDt" value="2026-01-01"><input id="toDt" value="2026-11-24"><div class="npo" id="npo" hidden></div></body>',{ runScripts:'outside-only' }); const w=dom.window;
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; const j=src.indexOf('\n}\n', i); return src.slice(i, j+2); };
w.eval('var RAW=null, _npoOpen=false, _somM=null;\n'+pick('esc')+'\n'+pick('npoPaint')+'\nwindow.npoPaint=npoPaint; window.setRaw=function(r){ RAW=r; }; window.setM=function(m){ _somM=m; };');
const box=w.document.getElementById('npo'), q=w.document.getElementById('q');
const L=[ {dlvDt:'20260921',dcCd:'E500',dcNm:'평택',prodCd:'1000800551',lineCnt:1,qty:7,dayMissing:'Y'}, {dlvDt:'20260921',dcCd:'E500',dcNm:'평택',prodCd:'1000800552',lineCnt:1,qty:5,dayMissing:'Y'},
          {dlvDt:'20260921',dcCd:'E500',dcNm:'평택',prodCd:'9904000001',lineCnt:77,qty:154.8,dayMissing:'Y'},
          {dlvDt:'20260921',dcCd:'E100',dcNm:'용인',prodCd:'9904000002',lineCnt:20,qty:37,dayMissing:'Y'},
          {dlvDt:'20260922',dcCd:'E300',dcNm:'김해',prodCd:'9904000003',lineCnt:5,qty:6,dayMissing:'Y'},
          {dlvDt:'20260915',dcCd:'E500',dcNm:'평택',prodCd:'1000800551',lineCnt:2,qty:3,dayMissing:'N'}, {dlvDt:'20260916',dcCd:'E700',dcNm:'오산',prodCd:'9904000004',lineCnt:1,qty:1,dayMissing:'N'} ];
w.setRaw({ noPoDays:L });
w.npoPaint(L); let t=box.textContent;
T(!box.hidden && /발주현황표가 없는 날 3곳/.test(t) && /9\/21 평택 외/.test(t), '한 줄 = 통째로 없는 날·센터 3곳 : '+t);
T(!box.querySelector('.lk') && !/자세히|정산서 누락 조회/.test(t), '[자세히]·[정산서 누락 조회 →] 링크 없음 (사용자 「여기에서는 제거」)');
T(/2026-09-21 평택·용인/.test(box.title) && /2026-09-22 김해/.test(box.title) && /정산서 104줄 · 수량 209.8/.test(box.title), '날짜·센터 목록 · 합계는 마우스 올림(title) : '+box.title);
T(!/그 품목만 없는/.test(t) && !box.querySelector('.lst'), '「그 품목만 없는」 부분·목록은 없다');
// 검색 품목만
q.value='pazac'; w.setM({ cols:[{cd:'1000800551'},{cd:'1000800552'}] }); w.npoPaint(L); t=box.textContent;
T(/발주현황표가 없는 날 1곳/.test(t) && /9\/21 평택\)/.test(t) && /검색 품목 기준/.test(t), '검색 = 9/21 평택 한 곳');
w.setM({ cols:[{cd:'1000999999'}] }); w.npoPaint(L); T(box.hidden, '검색 품목에 해당하는 날 없으면 숨김');
q.value=''; w.npoPaint(L.filter(r=>r.dayMissing==='N')); T(box.hidden, '품목만 빠진 줄만이면 숨김(그건 정산서 누락 조회 화면에서)');
w.npoPaint([]); T(box.hidden, '없으면 숨김'); w.npoPaint(undefined); T(box.hidden, '옛 서버도 숨김');
T((src.match(/npoPaint\(RAW\.noPoDays\)/g)||[]).length===2 && /\.npo\{[^}]*white-space:nowrap/.test(src), 'somRender 끝에서 그림 · 한 줄 CSS');
console.log((bad?'✗':'✓')+' sim_stockOutNoPo : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
