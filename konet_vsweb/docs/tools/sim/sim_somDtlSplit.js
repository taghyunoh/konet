// 월별 출고현황 — 출고내역 | 입고내역 좌우 조절 막대 시뮬 (2026-11-24 사용자 「좌우 조정가능하게」)
//   실행 : node docs/tools/sim/sim_somDtlSplit.js (jsdom 불필요 — 가짜 요소)
const fs=require('fs'), path=require('path');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const a=src.indexOf("(function(){\n  var sp=document.getElementById('dtlSplit');"), b=src.indexOf("konetGridGrip('card', 'card', 'stockOutMonth');", a);
T(a>0 && b>a, '막대 스크립트가 있다'); const code=src.slice(a,b);
const mkEl=()=>{ const h={}; return { style:{}, cls:{}, classList:{ add(c){ this._o.cls[c]=1; }, remove(c){ delete this._o.cls[c]; }, _o:null }, addEventListener(t,f){ h[t]=f; }, fire(t,e){ if(h[t]) h[t](e||{ preventDefault(){} }); }, getBoundingClientRect(){ return { left:100, width:1000 }; } }; };
const sp=mkEl(), lft=mkEl(), rgt=mkEl(), cols=mkEl(); [sp,lft,rgt,cols].forEach(e=>e.classList._o=e);
sp.parentNode=cols; sp.previousElementSibling=lft; sp.nextElementSibling=rgt;
const store={ konetSomDtlSplit:'62.5' }, dh={}, wh={};
const document={ getElementById:id=>id==='dtlSplit'?sp:null, addEventListener(t,f){ dh[t]=f; } };
const window={ addEventListener(t,f){ wh[t]=f; } };
const localStorage={ getItem:k=>store[k]===undefined?null:store[k], setItem(k,v){ store[k]=v; }, removeItem(k){ delete store[k]; } };
new Function('document','window','localStorage', code)(document, window, localStorage);
T(lft.style.flex==='0 0 calc(62.5% - 4px)' && rgt.style.flex==='1 1 0' && lft.cls.lft===1, '기억한 폭(62.5%)으로 시작 · 오른쪽은 나머지');
sp.fire('mousedown'); dh.mousemove({ clientX:400 }); T(lft.style.flex==='0 0 calc(30% - 4px)' && sp.cls.on===1, '끌면 왼쪽 폭 = 마우스 자리(30%)');
dh.mousemove({ clientX:150 }); T(lft.style.flex==='0 0 calc(20% - 4px)', '너무 좁게는 안 됨(20% 하한)');
dh.mousemove({ clientX:1090 }); T(lft.style.flex==='0 0 calc(85% - 4px)', '너무 넓게도 안 됨(85% 상한)');
dh.mousemove({ clientX:800 }); dh.mouseup(); T(store.konetSomDtlSplit==='70' && !sp.cls.on, '놓으면 기억(70%) · 막대 표시 해제');
dh.mousemove({ clientX:300 }); T(lft.style.flex==='0 0 calc(70% - 4px)', '놓은 뒤에는 마우스를 움직여도 안 바뀜');
sp.fire('dblclick'); T(lft.style.flex==='0 0 calc(50% - 4px)' && store.konetSomDtlSplit===undefined, '두 번 누르면 반반 · 기억 지움');
T(/<div class="vsp" id="dtlSplit"/.test(src) && /\.dtl \.vsp\{[^}]*cursor:col-resize/.test(src), '막대 요소 · 모양(col-resize)');
console.log((bad?'✗':'✓')+' sim_somDtlSplit : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
