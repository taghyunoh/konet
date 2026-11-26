// 월별 출고현황 — 조회 중 진행바 시뮬 (2026-11-24 사용자 「월별 출고현황도 진행바 확인해줘」)
//   2026-11-26 갱신 (사용자 「날짜 변경하면 조회 누르게 · 속도 확인 · 진행바」) :
//   · 진행률 바(% · 지난 조회 시간으로 어림) · [조회] 잠김 · 걸린 초 · 응답 뒤 「표를 그리는 중」 95% → 그림 · 늦게 온 옛 응답 버림 · 실패 시 풀림
//   · 기간을 바꾸면 조회하지 않는다 — [조회] 깜박임(due) · 옛 표 흐리게 · 안내 글 → [조회]로 풀림
//   · 「발주현황표 없는 날」 알림은 따로 받는다(stockOutNoPoDays.do) — 표 조회엔 noPo=N · 먼저 와도 늦게 와도 붙는다 · 옛 서버(404)면 표 응답의 것을 쓴다
//   · 서버가 준 tm(출고 집계·현재고)을 시간 줄에
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_somProg.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } };
const line=(re)=>{ const m=re.exec(src); if(!m) throw String(re); return m[0]; };
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
  const dom=new JSDOM('<body><input id="frDt" value="2026-01-01"><input id="toDt" value="2026-11-24"><button id="somBtn">조회</button><div id="card"></div><div id="cnt"></div></body>',{ runScripts:'outside-only', url:'http://localhost/' });
  const w=dom.window; let main=[], npo=[], bodies=[];
  w.fetch=(url,o)=>new Promise((res,rej)=>{ bodies.push(url+'?'+(o&&o.body)); (/NoPoDays/.test(url)?npo:main).push({res,rej}); });
  w.performance={ now:()=>Date.now() };
  w.eval('var RAW=null, _somAlias=null, _dtlCache={}, _somTiming="", _somM=null;\nfunction somAliasLoad(){}\nfunction toast(){}\nvar CTX="/konet";\n'
    +'function npoPaint(l){ window.__npo=(l||[]).length; }\n'
    +'function somRender(){ window.__renders=(window.__renders||0)+1; window.__cardAtRender=document.getElementById("card").textContent; _somM={cols:[]}; document.getElementById("card").innerHTML="<table>표</table>"; }\n'
    +pick('esc')+'\n'+line(/var _somSeq=0[^\n]*/)+'\n'+line(/var _somEst=[^\n]*/)+'\n'+pick('qprogDet')+'\n'+pick('somOv')+'\n'+pick('somOvPos')+'\n'+pick('somOvOff')+'\n'+pick('somProg')+'\n'+pick('somBusy')+'\n'+pick('somDirty')+'\n'+pick('somLoad')
    +'\nwindow.somLoad=somLoad; window.somDirty=somDirty; window.__raw=function(){ return RAW; }; window.__tim=function(){ return _somTiming; };');
  const d=w.document, btn=d.getElementById('somBtn'), card=d.getElementById('card'), cnt=d.getElementById('cnt');
  const resp=(months,extra)=>({ json:()=>Promise.resolve(Object.assign({ months:months, stock:[] }, extra||{})) });
  // ① 조회 중 = 진행률 바
  w.somLoad();
  const ov=()=>d.getElementById('somOv');
  T(ov() && !ov().hidden && ov().querySelector('.bx .qprog.det #somQbar') && /월별 출고량을 집계하는 중/.test(ov().textContent) && btn.disabled, '조회 중 = 표 위 진행 상자(바·%) · 「집계하는 중」 · [조회] 잠김');
  T(parseFloat(ov().style.width)>=320 && parseFloat(ov().style.height)>=240, '상자 자리를 잡는다(크기 0 이면 화면 전체)');
  T(main.length===1 && npo.length===1, '표 조회와 알림 조회가 나란히 나간다');
  T(/stockOutMonthList\.do\?.*noPo=N/.test(bodies.find(b=>/MonthList/.test(b))||''), '표 조회엔 noPo=N');
  await sleep(1150);
  const pct=parseFloat(d.getElementById('somQbar').style.width);
  T(pct>30 && pct<=85 && /%/.test(d.getElementById('somQpct').textContent), '바가 차오른다(어림 2초 → 1.15초에 '+pct+'%)');
  T(/· 1초|· 2초/.test(ov().textContent), '걸린 초가 붙는다 : '+ov().textContent);
  // ② 알림이 먼저 오고 → 표 응답 → 「표를 그리는 중」 95% → 그린다 · 알림이 RAW 에 붙는다
  npo.shift().res({ json:()=>Promise.resolve({ noPoDays:[{dlvDt:'20261101'},{dlvDt:'20261102'}] }) }); await sleep(5);
  main.shift().res(resp([{ym:'202611'},{ym:'202610'}], { tm:{ out:1500, npo:0, stk:120 } }));
  await sleep(5);
  T(/표를 그리는 중… \(자료 2줄\)/.test(ov().textContent) && !w.__renders && parseFloat(d.getElementById('somQbar').style.width)===95, '응답 직후 = 「표를 그리는 중」 95% (아직 그리기 전)');
  await sleep(60);
  T(w.__renders===1 && !btn.disabled && /표/.test(card.textContent) && ov().hidden && card.style.opacity==='', '그린 뒤 = 표 · 상자 거둠 · 흐림 풀림 · [조회] 풀림');
  T((w.__raw().noPoDays||[]).length===2, '먼저 온 알림이 표 자료에 붙는다');
  T(/출고 집계 1\.5 · 현재고 0\.1/.test(w.__tim()), '시간 줄에 서버 나눔 : '+w.__tim());
  T(+w.localStorage.getItem('konetSomMs')>=0, '걸린 시간을 기억(다음 진행률 어림)');
  // ③ 알림이 늦게 오면 그때 칠한다
  w.__npo=undefined; w.somLoad();
  main.shift().res(resp([{ym:'202611'}])); await sleep(60);
  T(w.__renders===2 && !w.__raw().noPoDays, '알림 전에 표가 먼저 그려진다');
  npo.shift().res({ json:()=>Promise.resolve({ noPoDays:[{dlvDt:'20261103'}] }) }); await sleep(5);
  T(w.__npo===1 && w.__raw().noPoDays.length===1, '늦게 온 알림은 그때 칠한다');
  // ④ 옛 서버 = 알림 404 → 표 응답의 noPoDays 그대로
  w.somLoad();
  npo.shift().res({ json:()=>Promise.reject(new Error('404 html')) });
  main.shift().res(resp([{ym:'202611'}], { noPoDays:[{dlvDt:'1'},{dlvDt:'2'},{dlvDt:'3'}] })); await sleep(60);
  T(w.__raw().noPoDays.length===3, '옛 서버면 표 응답의 알림을 쓴다');
  // ⑤ 늦게 온 옛 응답은 버린다
  w.somLoad(); w.somLoad();
  main[1].res(resp([{ym:'202611'}])); await sleep(60);
  const after=w.__renders; main[0].res(resp([{ym:'202601'},{ym:'202602'},{ym:'202603'}])); await sleep(60);
  T(w.__renders===after, '두 번 연달아 조회하면 늦게 온 첫 응답은 그리지 않는다');
  npo[0].res({ json:()=>Promise.resolve({ noPoDays:[1,2,3,4,5,6,7] }) }); await sleep(5);
  T((w.__raw().noPoDays||[]).length!==7, '옛 조회의 알림도 버린다');
  main=[]; npo=[];
  // ⑥ 실패하면 풀린다
  w.somLoad(); main.shift().rej(new Error('망 끊김')); await sleep(10);
  T(!btn.disabled && /조회 실패: 망 끊김/.test(card.textContent) && ov().hidden, '실패 = 안내 · 상자 거둠 · [조회] 풀림');
  // ⑦ 기간을 바꾸면 조회하지 않는다
  main=[]; npo=[]; w.somLoad(); main.shift().res(resp([{ym:'202611'}])); await sleep(60);
  const n0=bodies.length; w.somDirty();
  T(bodies.length===n0, '기간을 바꿔도 조회가 나가지 않는다');
  T(btn.classList.contains('due') && card.style.opacity==='0.5' && /기간이 바뀌었습니다/.test(cnt.textContent), '[조회] 깜박임 · 옛 표 흐리게 · 안내 글');
  w.somLoad();
  T(!btn.classList.contains('due') && card.style.opacity==='0.35' && !ov().hidden && /표/.test(card.textContent), '[조회] 누르면 깜박임 풀림 · 옛 표는 지우지 않고 흐리게 · 그 위 진행 상자');
  main.shift().res(resp([{ym:'202611'}])); await sleep(60);
  T(ov().hidden && card.style.opacity==='', '끝나면 상자 거두고 흐림 풀림');
  // ⑧ 화면 연결
  T(/id="frDt"[^>]*onchange="somDirty\(\)"/.test(src) && /id="toDt"[^>]*onchange="somDirty\(\)"/.test(src), '두 날짜 칸의 change = somDirty (조회 아님)');
  T(/id="toDt"[^>]*onkeydown="if\(event\.key==='Enter'\)\{ somLoad\(\); \}"/.test(src), '날짜 칸에서 Enter = 조회');
  T(/id="somBtn" onclick="somLoad\(\)"/.test(src), '[조회] 단추에 id(somBtn)');
  console.log((bad?'✗':'✓')+' sim_somProg : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})();
