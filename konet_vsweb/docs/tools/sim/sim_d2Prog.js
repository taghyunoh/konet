// 납기현황표(logistics_demo1.jsp) — 조회 중 진행바 시뮬 (2026-11-24 사용자 「납기현황표도 진행바 확인해줘」)
//   · 켜면 흐르는 바 + 안내 · 단계(받은 조회 n/전체) · 걸린 초 · 다 받으면 「표를 그리는 중」 뒤 그림 · 끄면 초 시계도 멈춤
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_d2Prog.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo1.jsp'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } };
const h0=src.indexOf('<div class="d2-loading on" id="d2Loading">'), h1=src.indexOf('</div>\n</div>', h0)+13;
(async()=>{
  const dom=new JSDOM('<body>'+src.slice(h0,h1)+'</body>',{ runScripts:'outside-only' }); const w=dom.window, d=w.document;
  w.eval('var _d2LoadingTmr=null, _d2LoadT0=0, _d2LoadTick=null, _d2Step={ done:0, all:0 };\n'
    +['d2Set','d2LoadingSub','d2LoadStep','d2LoadStepDone','d2LoadRenderSoon','d2LoadingOn','d2LoadingOff'].map(pick).join('\n')
    +'\nwindow.T={on:d2LoadingOn, off:d2LoadingOff, step:d2LoadStep, done:d2LoadStepDone, soon:d2LoadRenderSoon};');
  const ov=d.getElementById('d2Loading'), msg=()=>d.getElementById('d2LoadingMsg').textContent, sub=()=>d.getElementById('d2LoadingSub').textContent;
  T(ov && ov.querySelector('.lbar > i') && d.getElementById('d2LoadingSub'), '덮개에 흐르는 바 · 단계 줄');
  w.T.off(); w.T.on(); w.T.step(4);
  T(ov.classList.contains('on') && /불러오는 중/.test(msg()) && sub()==='받은 조회 0 / 4', '켜면 = 안내 · 「받은 조회 0 / 4」');
  w.T.done(); w.T.done(); T(sub()==='받은 조회 2 / 4', '조회가 올 때마다 단계가 오른다 : '+sub());
  await new Promise(r=>setTimeout(r,1100)); T(/받은 조회 2 \/ 4 · 1초/.test(sub()), '걸린 초가 붙는다 : '+sub());
  w.T.done(); w.T.done(); w.T.done(); T(/받은 조회 4 \/ 4/.test(sub()), '전체를 넘지 않는다');
  let drawn=0, msgAtDraw=''; w.T.soon(function(){ drawn++; msgAtDraw=msg(); });
  T(msg()==='표를 그리는 중…' && !drawn, '다 받으면 「표를 그리는 중」 (아직 그리기 전)');
  await new Promise(r=>setTimeout(r,60)); T(drawn===1 && msgAtDraw==='표를 그리는 중…', '한 박자 뒤 그린다');
  w.T.off(); T(!ov.classList.contains('on'), '끄면 덮개가 사라진다');
  w.T.on(); T(/불러오는 중/.test(msg()) && sub()==='', '다시 켜면 안내·단계가 처음부터');
  w.T.off();
  T((src.match(/d2LoadRenderSoon\(function\(\)\{ d2Render\(\); _d2PerfDraw\(\); \}\)/g)||[]).length===2 && /d2LoadStep\(4\)/.test(src) && /d2LoadStep\(3\)/.test(src), '단일일자(4)·기간(3) 두 길 모두 단계와 「그리는 중」을 쓴다');
  T(/setTimeout\(d2LoadingOff, 60000\)/.test(src), '안전장치 60초');
  console.log((bad?'✗':'✓')+' sim_d2Prog : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})();
