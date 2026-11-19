/* 로그인 창 「대표자 일정 — 오늘부터 일주일」의 «지난 미완료» 며칠 전까지 설정 (2026-11-19)
   설정 = 대표자 일정 화면 위 줄 숫자 칸 → localStorage('konetCeoLateDays2') : 없음·비움·0 = 지난 미완료 안 보임(기본) · n = n일 전까지. 창(오늘부터 일주일)은 늘 뜬다
   node docs/tools/sim/sim_ceoLoginLate.js   (jsdom 필요 — NODE_PATH 로 빌려 써도 된다)
   실제 asset/js/emp-badge.js 를 태운다. 서버는 가짜(ceoSchedList.do 만 답함) */
const fs=require('fs'), path=require('path');
const { JSDOM }=require('jsdom');
const js=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/asset/js/emp-badge.js'),'utf8');
let ok=0, bad=0; function T(c,m){ if(c) ok++; else { bad++; console.log('✗ '+m); } }
function d8(off){ const d=new Date(); d.setDate(d.getDate()+off); return ''+d.getFullYear()+String(d.getMonth()+1).padStart(2,'0')+String(d.getDate()).padStart(2,'0'); }
/* 지난 미완료 : 2일 전 · 5일 전 · 10일 전 · 40일 전 끝난 것 + 완료(빠져야 함) */
const LATE=[ { schedSeq:1, fromDt:d8(-2), toDt:d8(-2), title:'2일 전', doneYn:'N' }, { schedSeq:2, fromDt:d8(-5), toDt:d8(-5), title:'5일 전', doneYn:'N' },
             { schedSeq:3, fromDt:d8(-10), toDt:d8(-10), title:'10일 전', doneYn:'N' }, { schedSeq:4, fromDt:d8(-40), toDt:d8(-40), title:'40일 전', doneYn:'N' },
             { schedSeq:5, fromDt:d8(-3), toDt:d8(-3), title:'완료한 것', doneYn:'Y' } ];
const WEEK=[ { schedSeq:9, fromDt:d8(0), toDt:d8(0), title:'오늘 일', doneYn:'N' }, { schedSeq:10, fromDt:d8(1), toDt:d8(1), title:'내일 취소', doneYn:'C' } ];
function make(days, justLogin){
  const dom=new JSDOM('<!doctype html><body><span id="ceoLateBadge"></span></body>',{ runScripts:'outside-only', pretendToBeVisual:true, url:'http://localhost/' });
  const w=dom.window;
  if(days!=null) w.localStorage.setItem('konetCeoLateDays2', String(days));
  if(justLogin) w.sessionStorage.setItem('konetJustLogin','1');
  w.fetch=function(url,opt){ const b=String(opt&&opt.body||''); let data=[];
    if(/ceoSchedList/.test(url)) data=/doneYn=N/.test(b)?LATE:WEEK;
    return Promise.resolve({ ok:true, json:()=>Promise.resolve(/ceoSchedList/.test(url)?{ data:data }:{}) }); };
  w.setInterval=function(){ return 0; };
  w.eval(js);
  return w;
}
const tick=(ms)=>new Promise(r=>setTimeout(r,ms||30));
(async()=>{
  /* 365 = 사실상 전부 */
  let w=make(365); w.konetCeoWeek(); await tick(); await tick();
  let box=w.document.getElementById('ceoWeek');
  T(!!box, '창이 뜬다');
  let txt=box.textContent;
  T(/지난 미완료 \(최근 365일\) 4건/.test(txt) && /40일 전/.test(txt) && !/완료한 것/.test(txt), '365 = 4건(완료 빠짐)');
  T(!w.document.getElementById('ceoLateDays'), '창에는 설정 칸이 없다(화면 위 줄에서만)');
  T(/취소/.test(txt) && !/일정취소/.test(txt), '「일정취소」 → 「취소」');
  T(!/line-through/.test(w.document.getElementById('ceoWeekCss').textContent.split('.cw-i.off .tt')[1].split('}')[0]), '끝난 일정 취소선 없음');
  /* 7일 전까지 */
  w=make(7); w.konetCeoWeek(); await tick(); await tick();
  txt=w.document.getElementById('ceoWeek').textContent;
  T(/지난 미완료 \(최근 7일\) 2건/.test(txt) && /2일 전/.test(txt) && /5일 전/.test(txt) && !/10일 전/.test(txt), '7일 = 2건 : '+txt.match(/지난 미완료[^건]*건/));
  T(/7일보다 오래된 미완료 2건은/.test(txt), '오래된 것 안내');
  const items=[...w.document.querySelectorAll('#ceoWeek .cw-d.late ~ .cw-i .tt')].map(e=>e.textContent);
  T(items[0]==='2일 전' && items[1]==='5일 전', '최근에 지난 것이 위 : '+items.join(','));
  /* 3일 = 1건 · 14일 = 3건 */
  w=make(3); w.konetCeoWeek(); await tick(); await tick();
  T(/\(최근 3일\) 1건/.test(w.document.getElementById('ceoWeek').textContent), '3일 = 1건');
  w=make(14); w.konetCeoWeek(); await tick(); await tick();
  T(/\(최근 14일\) 3건/.test(w.document.getElementById('ceoWeek').textContent), '14일 = 3건');
  /* 0 = 지난 미완료 없음(직접 부를 때) · 로그인 때는 창 자체를 안 띄움 */
  w=make(0); w.konetCeoWeek(); await tick(); await tick();
  T(!/지난 미완료/.test(w.document.getElementById('ceoWeek').textContent), '0 = 지난 미완료 안 보임');
  w=make(0, true); await tick(700);
  T(!!w.document.getElementById('ceoWeek') && /오늘 일/.test(w.document.getElementById('ceoWeek').textContent) && !/지난 미완료/.test(w.document.getElementById('ceoWeek').textContent), '0 = 로그인 때 창은 뜨고(오늘 일정) 지난 미완료만 없음');
  w=make(7, true); await tick(700);
  T(!!w.document.getElementById('ceoWeek'), '7 = 로그인 때 창 뜸');
  w=make(null, true); await tick(700);
  T(!!w.document.getElementById('ceoWeek') && !/지난 미완료/.test(w.document.getElementById('ceoWeek').textContent), '설정 없음 = 기본 0 = 창은 뜨고 지난 미완료 없음');
  w=make('', true); await tick(700);
  T(!!w.document.getElementById('ceoWeek') && !/지난 미완료/.test(w.document.getElementById('ceoWeek').textContent), '비움 = 0 = 지난 미완료 없음');
  /* 옛 키(고르기 칸 판)는 안 읽는다 */
  w=make(null, true); w.localStorage.setItem('konetCeoLateDays','7'); await tick(700);
  T(!!w.document.getElementById('ceoWeek') && !/지난 미완료/.test(w.document.getElementById('ceoWeek').textContent), '옛 키 무시');
  console.log((bad?'✗':'✓')+' sim_ceoLoginLate ok='+ok+' bad='+bad);
  process.exit(bad?1:0);
})().catch(e=>{ console.log('ERR', e); process.exit(1); });
