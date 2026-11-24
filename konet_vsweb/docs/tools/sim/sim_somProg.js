// 월별 출고현황 — 조회 중 진행바 시뮬 (2026-11-24 사용자 「월별 출고현황도 진행바 확인해줘」)
//   · 조회 중 = 흐르는 바 + 「조회하는 중」 · [조회] 잠김 · 걸린 초 · 응답 뒤 「표를 그리는 중」 으로 바뀐 뒤 그림 · 늦게 온 옛 응답 버림 · 실패 시 풀림
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_somProg.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } };
const busyVar=/var _somSeq=0, _somBusyT=null;/.test(src);
(async()=>{
  const dom=new JSDOM('<body><input id="frDt" value="2026-01-01"><input id="toDt" value="2026-11-24"><button id="somBtn">조회</button><div id="card"></div><div id="cnt"></div></body>',{ runScripts:'outside-only' });
  const w=dom.window; let pend=[], renders=0, cardAtRender='';
  w.fetch=()=>new Promise((res,rej)=>pend.push({res,rej}));
  w.performance={ now:()=>Date.now() };
  w.eval('var RAW=null, _somAlias=null, _dtlCache={}, _somTiming="";\nfunction somAliasLoad(){}\nfunction toast(){}\nvar CTX="/konet";\n'
    +'function somRender(){ window.__renders=(window.__renders||0)+1; window.__cardAtRender=document.getElementById("card").textContent; document.getElementById("card").innerHTML="<table>표</table>"; }\n'
    +pick('esc')+'\n'+pick('qprog')+'\n'+(busyVar?'var _somSeq=0, _somBusyT=null;\n':'')+pick('somBusy')+'\n'+pick('somLoad')+'\nwindow.somLoad=somLoad;');
  const d=w.document, btn=d.getElementById('somBtn'), card=d.getElementById('card');
  const resp=(months)=>({ json:()=>Promise.resolve({ months:months, stock:[] }) });
  // ① 조회 중
  w.somLoad();
  T(card.querySelector('.qprog') && /월별 출고량을 조회하는 중/.test(card.textContent) && btn.disabled, '조회 중 = 진행바 · 「조회하는 중」 · [조회] 잠김');
  await new Promise(r=>setTimeout(r,1150));
  T(/· 1초|· 2초/.test(card.textContent), '걸린 초가 붙는다 : '+card.textContent);
  // ② 응답 → 「표를 그리는 중」 으로 바뀐 뒤 그린다
  pend.shift().res(resp([{ym:'202611'},{ym:'202610'}]));
  await new Promise(r=>setTimeout(r,5));
  T(/표를 그리는 중… \(자료 2줄\)/.test(card.textContent) && !w.__renders, '응답 직후 = 「표를 그리는 중」 (아직 그리기 전)');
  await new Promise(r=>setTimeout(r,60));
  T(w.__renders===1 && /표를 그리는 중/.test(w.__cardAtRender) && !btn.disabled && /표/.test(card.textContent), '그린 뒤 = 표 · [조회] 풀림');
  // ③ 늦게 온 옛 응답은 버린다
  w.somLoad(); w.somLoad();
  pend[1].res(resp([{ym:'202611'}])); await new Promise(r=>setTimeout(r,60));
  const after=w.__renders; pend[0].res(resp([{ym:'202601'},{ym:'202602'},{ym:'202603'}])); await new Promise(r=>setTimeout(r,60));
  T(after===2 && w.__renders===2, '두 번 연달아 조회하면 늦게 온 첫 응답은 그리지 않는다');
  // ④ 실패하면 풀린다
  pend=[]; w.somLoad(); pend.shift().rej(new Error('망 끊김')); await new Promise(r=>setTimeout(r,10));
  T(!btn.disabled && /조회 실패: 망 끊김/.test(card.textContent), '실패 = 안내 · [조회] 풀림');
  T(/id="somBtn" onclick="somLoad\(\)"/.test(src), '[조회] 단추에 id(somBtn)');
  console.log((bad?'✗':'✓')+' sim_somProg : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})();
