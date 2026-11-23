// 매입/판매 등록현황(mangr/trxStat.jsp) 시뮬 (2026-11-24) — 네 보기 합계·거르기·접기·전표 열기 · 엑셀/인쇄 「원장」(일계·소계·누계·시트 병합·색)
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_trxStat.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/trxStat.jsp'),'utf8').replace(/\r\n/g,'\n');
let html=src.replace(/<%@[\s\S]*?%>/g,'').replace(/<%--[\s\S]*?--%>/g,'').replace(/\$\{pageContext\.request\.contextPath\}/g,'/konet').replace(/<script src=[^>]*><\/script>/g,'');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const ROWS=[
  { gb:'S', seq:11, dt:'20261103', dlvDt:'20261104', docNo:'S-1', custCd:'C1', custNm:'가나상회', mgrNm:'김', qty:10, supplyAmt:1000, vatAmt:100, totAmt:1100, dcAmt:0, payAmt:500, payGb:'현금', remark:'', rtnAmt:0, lineCnt:2 },
  { gb:'S', seq:12, dt:'20261105', docNo:'S-2', custCd:'C1', custNm:'가나상회', qty:5, supplyAmt:2000, vatAmt:200, totAmt:2200, rtnAmt:300, lineCnt:3 },
  { gb:'P', seq:21, dt:'20261103', docNo:'P-1', custCd:'V1', custNm:'다라물산', qty:20, supplyAmt:3000, vatAmt:300, totAmt:3300, rtnAmt:0, lineCnt:1 },
  { gb:'P', seq:22, dt:'20261105', docNo:'P-2', custCd:'C1', custNm:'가나상회', qty:4, supplyAmt:400, vatAmt:40, totAmt:440, rtnAmt:0, lineCnt:1 },
  { gb:'S', seq:13, dt:'20261105', docNo:'S-3', custCd:'', custNm:'현장 "손님"', qty:1, supplyAmt:100, vatAmt:10, totAmt:110, rtnAmt:0, lineCnt:1 },
];
const LINES=[
  { gb:'S', seq:12, dt:'20261105', docNo:'0002', custCd:'C1', custNm:'가나상회', rowNo:1, prodNm:'용기A', spec:'', trxGb:'판매', qty:5, unitPrice:400, supplyAmt:2000, vatAmt:200, totAmt:2200 },
  { gb:'S', seq:11, dt:'20261103', docNo:'0001', custCd:'C1', custNm:'가나상회', rowNo:1, prodNm:'용기A', spec:'', trxGb:'판매', qty:2, unitPrice:400, supplyAmt:800, vatAmt:80, totAmt:880 },
  { gb:'S', seq:11, dt:'20261103', docNo:'0001', custCd:'C1', custNm:'가나상회', rowNo:2, prodNm:'뚜껑B', spec:'100EA', trxGb:'판매', qty:1, unitPrice:200, supplyAmt:200, vatAmt:20, totAmt:220 },
  { gb:'S', seq:13, dt:'20261105', docNo:'0003', custCd:'', custNm:'현장 "손님"', rowNo:1, prodNm:'컵', spec:'', trxGb:'반품', qty:-1, unitPrice:100, supplyAmt:-100, vatAmt:-10, totAmt:-110 },
  { gb:'P', seq:21, dt:'20261103', docNo:'0001', custCd:'V1', custNm:'다라물산', rowNo:1, prodNm:'원지', spec:'', trxGb:'매입', qty:20, unitPrice:150, supplyAmt:3000, vatAmt:300, totAmt:3300 },
];
let lastBody='', lineCalls=0;
const dom=new JSDOM(html,{ runScripts:'outside-only', url:'http://x/konet/mangr/trxStat.do', pretendToBeVisual:true });
const w=dom.window;
w.fetch=(u,o)=>{ if(/trxStatLines/.test(u)){ lineCalls++; return Promise.resolve({ json:()=>Promise.resolve({ result:'OK', data:JSON.parse(JSON.stringify(LINES)) }) }); } lastBody=o&&o.body; return Promise.resolve({ json:()=>Promise.resolve({ result:'OK', data:JSON.parse(JSON.stringify(ROWS)), frDt:'20261101', toDt:'20261124' }) }); };
w._alertBox=(m)=>{ w.__alert=m; }; w._toast=(m)=>{ w.__toast=m; };
const scr=[...src.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1].replace(/\$\{pageContext\.request\.contextPath\}/g,'/konet')).join('\n');
w.eval(scr+'\n;window.__t={render:render,picked:picked,ledgerRows:ledgerRows,specTab:specTab,specSheet:specSheet,excel:excel,printIt:printIt,lineHit:lineHit,tabGo:tabGo,foldOne:foldOne,foldAll:foldAll,openDoc:openDoc,get ROWS(){return ROWS;}};');
const tick=()=>new Promise(r=>setTimeout(r,0));
const $=s=>w.document.querySelector(s), $$=s=>[...w.document.querySelectorAll(s)];
const clk=el=>w.Function('event', el.getAttribute('onclick')).call(el, { stopPropagation(){} });   /* jsdom 은 onclick 속성을 안 돌린다 */
(async()=>{
  await tick(); await tick();
  T(/frDt=\d{4}-\d{2}-01/.test(lastBody), '처음 = 이번 달 1일부터 조회 : '+lastBody);
  T($('#frDt').value==='2026-11-01' && $('#toDt').value==='2026-11-24', '서버가 돌려준 기간으로 맞춤');
  T($('#tabs .t').getAttribute('data-v')==='day' && $('#tabs .t.on').getAttribute('data-v')==='day' && $$('#tabs .t').map(b=>b.getAttribute('data-v')).join()==='day,cust,cd,doc' && $$('#body tr.go').length===2, '일자별이 맨 앞 · 처음 보기(날짜 2줄) · 순서 일자별·거래처별·거래처×일자·전표별 (2026-11-24 「일자별을 맨앞으로」·「전표별을 맨뒤로」)');
  T(!$('#fltBox') && !/만 보는 중/.test($('#tabs').textContent), '「… 만 보는 중 ✕ 풀기」 표시 없음');
  T(w.getComputedStyle($('#head')).position==='sticky' || /thead\{ position:sticky/.test(w.document.querySelector('style').textContent), '머리글은 thead 통째로 고정');
  w.__t.tabGo('cust');
  // 요약
  const sum=$('#sumbox').textContent;
  T(/판매합계3,410/.test(sum.replace(/\s/g,'')), '판매 합계 = 1100+2200+110 = 3,410 : '+sum);
  T(/매입합계3,740/.test(sum.replace(/\s/g,'')), '매입 합계 = 3300+440 = 3,740');
  T(/판매 − 매입-330/.test(sum.replace(/\s+/g,' ').replace(/ (?=[-\d])/g,'').replace('판매 − 매입 ','판매 − 매입')) || /-330/.test(sum), '판매−매입 = -330');
  T(/판매 반품 300/.test(sum), '판매 반품 300');
  // 거래처별 — 금액 큰 순 : 가나상회(3300+440=3740) > 다라물산 3300 > 현장 110
  let rows=$$('#body tr'); T(rows.length===4, '거래처별 = 3곳 + 합계 : '+rows.length);
  T(/가나상회/.test(rows[0].textContent) && /다라물산/.test(rows[1].textContent) && /현장/.test(rows[2].textContent), '금액 큰 거래처부터');
  T(rows[0].cells.length===12, '판매·매입 두 묶음(5+5) + 거래처 + 차액 = 12칸 : '+rows[0].cells.length);
  T(rows[0].cells[1].textContent==='2' && rows[0].cells[4].textContent==='3,300' && rows[0].cells[5].textContent==='300' && rows[0].cells[6].textContent==='1' && rows[0].cells[9].textContent==='440' && rows[0].cells[11].textContent==='2,860', '가나상회 판매 2건 3,300 반품 300 · 매입 1건 440 · 차액 2,860 : '+[...rows[0].cells].map(c=>c.textContent).join('|'));
  T(/합계/.test(rows[3].textContent) && rows[3].cells[4].textContent==='3,410' && rows[3].cells[9].textContent==='3,740', '합계 줄 = 요약과 같음');
  // 구분 = 판매만
  $('#gb').value='S'; w.__t.render(); rows=$$('#body tr');
  T(rows.length===3 && rows[0].cells.length===6, '판매만 = 다라물산 빠짐 · 칸 6 : '+rows.length+'/'+rows[0].cells.length);
  $('#gb').value=''; w.__t.render();
  // 일자별 — 최근 날부터
  w.__t.tabGo('day'); rows=$$('#body tr');
  T(rows.length===3 && /2026-11-05/.test(rows[0].textContent) && /2026-11-03/.test(rows[1].textContent), '일자별 = 11-05, 11-03 + 합계');
  T(rows[0].cells[1].textContent==='2' && rows[0].cells[4].textContent==='2,310', '11-05 판매 2건 2,310(2200+110)');
  // 거래처×일자 + 접기
  w.__t.tabGo('cd'); rows=$$('#body tr');
  T($$('#body tr.grp').length===3 && $$('#body tr.sub').length===4, '거래처 3묶음 · 날짜 줄 4(가나 2 · 다라 1 · 현장 1) : '+$$('#body tr.sub').length);
  T(!$('#foldAll').hidden, '거래처×일자에서만 전체 접기 단추');
  w.__t.foldAll(); T($$('#body tr.sub').length===0 && /펼치기/.test($('#foldAll').textContent), '전체 접기 → 날짜 줄 0');
  w.__t.foldAll(); T($$('#body tr.sub').length===4, '전체 펼치기');
  clk($$('#body tr.grp')[0]); T($$('#body tr.sub').length===2, '한 묶음 접기(가나상회 2줄 숨김)');
  w.__t.foldAll(); w.__t.foldAll();
  // 거래처 줄 누르기 → 전표별 + 거르기
  // 거래처별 — 줄을 누르면 탭은 그대로, 아래 칸에 그 거래처 전표 (2026-11-24 「하단에 전표별」·「상하단으로 구분」)
  w.__t.tabGo('cust');
  T(!$('#wrap').classList.contains('one') && /위에서 거래처를 누르면/.test($('#dtlHd').textContent) && !$$('#dBody tr').length, '거래처별 = 위아래 나눔 · 아래 칸 안내');
  clk($$('#body tr.go')[0]);
  T($('#tabs .t.on').getAttribute('data-v')==='cust' && $$('#dBody tr.go').length===3, '가나상회 누름 → 탭 그대로 · 아래 칸 전표 3건 : '+$$('#dBody tr.go').length);
  T($$('#body tr.on').length===1 && /가나상회/.test($('#body tr.on').textContent), '누른 줄 표시');
  T(/가나상회/.test($('#dtlHd').textContent) && /3건/.test($('#dtlHd').textContent) && !/전표별 탭에서 보기/.test($('#dtlHd').textContent) && $$('#dtlHd .btn').length===1, '아래 칸 제목 = 거래처 · 건수 · [✕ 닫기]만');
  T(/판매 2건 · 매입 1건/.test($('#dBody tr.tot').textContent), '아래 칸 합계 줄(섞이면 따로)');
  $('#gb').value='S'; w.__t.render(); T($$('#dBody tr.go').length===2, '구분 = 판매만이면 아래 칸도 판매만'); $('#gb').value=''; w.__t.render();
  clk($$('#dtlHd .btn')[0]); T(!$$('#dBody tr').length && !$$('#body tr.on').length, '✕ 닫기 → 아래 칸 비움');
  const hz=$$('#body tr.go').find(r=>/현장/.test(r.textContent)); clk(hz);
  T($$('#dBody tr.go').length===1 && /S-3/.test($('#dBody').textContent), '따옴표 든 이름(코드 없음)도 아래 칸에');
  w.__t.tabGo('day'); T($$('#body tr.go').length===2, '거래처를 고른 뒤 일자별로 가도 일자별은 다 보인다(거르기가 남지 않음)'); w.__t.tabGo('cust');
  // 일자별 — 날짜 줄 → 아래 칸에 그날 전표 · 탭을 바꾸면 고른 것은 풀린다
  w.__t.tabGo('day'); clk($$('#body tr.go')[1]);
  T($('#tabs .t.on').getAttribute('data-v')==='day' && $$('#dBody tr.go').length===2 && /2026-11-03/.test($('#dtlHd').textContent), '11-03 누름 → 아래 칸 2건');
  w.__t.tabGo('cust'); T(!$$('#dBody tr').length, '탭을 바꾸면 아래 칸 비움');
  // 거래처×일자 — 날짜 줄 → 그 거래처·그날
  w.__t.tabGo('cd'); if(!$$('#body tr.sub').length) w.__t.foldAll();   /* 앞 시험이 전부 접어 두었으면 편다 */
  clk($$('#body tr.sub')[0]); T($$('#dBody tr.go').length===2 && /S-2/.test($('#dBody').textContent) && /P-2/.test($('#dBody').textContent), '거래처×일자 날짜 줄(가나상회 11-05) → 그날 판매 S-2 · 매입 P-2 : '+$$('#dBody tr.go').length);
  w.__t.tabGo('doc');
  // 찾기
  $('#q').value='P-2'; w.__t.render(); T($$('#body tr.go').length===1, '전표번호로 찾기'); $('#q').value=''; w.__t.render();
  // 원장 줄 — 거래처 차례 = 처음 나온 전표 차례 · 날짜마다 일계 · 거래처 소계 · 누계
  { const L=JSON.parse(JSON.stringify(LINES)); const R=w.__t.ledgerRows(L,'S'); const k=R.map(r=>r.k).join(',');
    T(k==='line,line,day,line,day,sub,line,day,sub,tot', '판매 원장 줄 차례 : '+k);
    T(R[0].c[0]==='가나상회 [C1]' && R[1].c[0]==='' && R[0].c[1]==='2026-11-03' && R[0].c[2]===1 && R[0].c[3]===1 && R[0].c[4]==='매출', '첫 줄 = 거래처 이름 · 일자 · 번호 0001→1 · NO · 구분 매출 / 둘째 줄 거래처 칸 비움');
    T(R[1].c[5]==='뚜껑B 100EA', '규격이 이름에 없으면 붙인다');
    T(R[0].c[10]===880 && R[1].c[10]===1100 && R[3].c[10]===3300, '계 = 판매액 누계 880 → 1,100 → 3,300');
    T(R[2].c[1]==='일계' && R[2].c[8]===1000 && R[2].c[9]===1100 && R[2].c[10]==='', '11-03 일계 = 금액 1,000 · 판매액 1,100 · 계 비움');
    T(R[5].c[0]==='소계' && R[5].c[9]===3300, '가나상회 소계 3,300');
    T(R[6].c[4]==='반품' && R[6].c[9]===-110 && R[6].c[10]===3190, '반품 줄 = 음수 · 누계에서 빠짐');
    T(R[9].c[0]==='합계' && R[9].c[8]===2900 && R[9].c[9]===3190, '합계 = 금액 2,900 · 판매액 3,190');
    const P=w.__t.ledgerRows(L,'P'); T(P.length===4 && P[0].c[4]==='매입' && P[3].c[9]===3300, '매입 원장 따로(줄·일계·소계·합계)'); }
  // 엑셀 — 실제 xlsx-js-style 로 시트를 만들어 본다(병합·색·숫자 서식)
  { w.eval(fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/assets/vendor/xlsx-js-style/xlsx.bundle.js'),'utf8'));
    let saved=null; w.XLSX.writeFile=(wb,nm)=>{ saved={wb,nm}; };
    w.document.body.setAttribute('data-comp','(주)코네트');
    $('#outMode').value='ledger';
    w.__t.excel(); await tick(); await tick(); await tick();
    T(saved && saved.wb.SheetNames.join(',')==='매출원장,매입원장' && /^매입판매원장_\d{8}-\d{8}\.xlsx$/.test(saved.nm), '판매·매입 = 시트 두 장 : '+(saved&&saved.wb.SheetNames)+' '+(saved&&saved.nm));
    const ws=saved.wb.Sheets['매출원장'];
    T(ws.A1.v==='[판매] 거래처별 매출원장 전체조회' && ws.A1.s.font.bold && ws.A1.s.font.sz===16, '제목 A1 굵게 16');
    T(/^조회기간 : 2026-11-01 ~ 2026-11-24/.test(ws.A3.v), '조회기간 줄');
    T(ws.A4.v==='2026-11-01 ~ 2026-11-24' && ws.C4.v==='구분' && ws.E4.v==='판매등록' && /^출력일자 : /.test(ws.H4.v) && ws.K4.v==='(주)코네트', '띠 줄 = 기간 · 구분 · 판매등록 · 출력일자 · 회사 이름');
    T(ws.J5.v==='판매액' && ws.K5.v==='계' && ws.A5.s.fill.fgColor.rgb==='DDEBF7', '칸 머리 + 하늘색');
    T(ws['!merges'].length===6, '병합 6곳(제목·조회기간·띠 4)');
    T(ws.B8.v==='일계' && ws.B8.s.fill.fgColor.rgb==='F3F9C4' && ws.I8.v===1000 && ws.I8.s.numFmt==='#,##0', '일계 줄 연두 · 숫자 서식');
    T(ws.A11.v==='소계' && ws.A11.s.fill.fgColor.rgb==='E9CDF5', '소계 줄 연보라');
    T(ws.K6.v===880 && ws.F7.v==='뚜껑B 100EA', '누계·상품명 칸'); }
  // 구분 = 매입만 → 매입 원장 한 장 · 거래처 거르기도 따른다
  { let saved=null; w.XLSX.writeFile=(wb,nm)=>{ saved={wb,nm}; };
    $('#gb').value='P'; w.__t.excel(); await tick(); await tick();
    T(saved && saved.wb.SheetNames.join(',')==='매입원장' && /^매입원장_/.test(saved.nm), '매입만 = 매입원장 한 장');
    $('#gb').value=''; $('#q').value='가나'; saved=null; w.__t.excel(); await tick(); await tick();
    T(saved && saved.wb.SheetNames.join(',')==='매출원장' && /조건 : 찾기 「가나」/.test(saved.wb.Sheets['매출원장'].A3.v), '찾기 「가나」 = 매출원장만 · 조회기간 줄에 조건');
    $('#q').value=''; T(lineCalls===1, '원장 줄은 한 번만 받는다(같은 기간이면 다시 안 부름) : '+lineCalls); }
  // 인쇄 — 새 창에 일계·소계·합계 색 줄, 판매·매입은 쪽을 나눈다
  { let html=''; w.open=()=>({ document:{ write:(h)=>{ html+=h; }, close(){} }, focus(){}, print(){} });
    w.__t.printIt(); await tick(); await tick();
    T(/\[판매\] 거래처별 매출원장/.test(html) && /\[매입\] 거래처별 매입원장/.test(html) && /class="pb"/.test(html), '인쇄 = 두 원장 · 쪽 나눔');
    T((html.match(/tr class="day"/g)||[]).length===4 && (html.match(/tr class="sub"/g)||[]).length===3 && /tr class="tot"/.test(html), '인쇄 일계 4 · 소계 3 · 합계'); }
  // ── 「출력 : 이 탭」 — 탭마다 그 표 그대로 (2026-11-24 사용자 「엑셀출력이 한 양식으로만 나옴, 해당 탭에 맞게」) ──
  { $('#outMode').value='tab'; let saved=null, html=''; w.XLSX.writeFile=(wb,nm)=>{ saved={wb,nm}; };
    const xl=async(v)=>{ w.__t.tabGo(v); saved=null; w.__t.excel(); await tick(); return saved; };
    let sv=await xl('doc'); let ws=sv.wb.Sheets[sv.wb.SheetNames[0]];
    T(sv.wb.SheetNames.join()==='전표별' && /^매입판매등록_전표별_/.test(sv.nm) && ws.A1.v==='[판매·매입] 전표별 등록현황', '전표별 탭 = 전표 목록 시트 : '+sv.wb.SheetNames+' '+ws.A1.v);
    T(ws.A5.v==='구분' && ws.N5.v==='비고' && ws.A6.v==='판매' && ws.D6.v==='가나상회 [C1]', '전표별 머리 14칸 · 첫 줄');
    T(ws.D11.v==='판매 합계 3건' && ws.D12.v==='매입 합계 2건' && ws.D13.v==='판매 − 매입' && ws.J13.v===-330 && ws.D11.s.fill.fgColor.rgb==='E9CDF5' && ws.D13.s.fill.fgColor.rgb==='FFE699', '섞이면 판매 합계·매입 합계(연보라)·판매−매입(노랑)');
    T(ws.G6.v===10 && ws.G6.s.numFmt==='#,##0', '정수 수량은 「#,##0」(1. 안 보이게)');
    T(ws.A4.v==='2026-11-01 ~ 2026-11-24' && ws.C4.v==='구분' && ws.E4.v==='판매·매입등록', '띠 줄도 같은 틀(14칸에 맞춰 나눔)');
    sv=await xl('cust'); ws=sv.wb.Sheets['거래처별'];
    T(sv.wb.SheetNames.join()==='거래처별' && ws.A5.v==='거래처' && ws.B5.v==='판매' && ws.G5.v==='매입' && ws.L5.v==='판매 − 매입' && ws.B6.v==='건수' && ws.E6.v==='합계', '거래처별 = 두 줄 머리(판매·매입 묶음)');
    T(ws['!merges'].some(m=>m.s.r===4&&m.s.c===0&&m.e.r===5) && ws['!merges'].some(m=>m.s.r===4&&m.s.c===1&&m.e.c===5), '거래처 칸 두 줄 병합 · 판매 5칸 병합');
    T(ws.A7.v==='가나상회 [C1]' && ws.E7.v===3300 && ws.J7.v===440 && ws.L7.v===2860 && ws.A10.v==='합계' && ws.E10.v===3410, '거래처별 값 · 합계');
    sv=await xl('day'); ws=sv.wb.Sheets['일자별'];
    T(ws.A5.v==='일자' && ws.A7.v==='2026-11-05' && ws.A9.v==='합계', '일자별 시트');
    sv=await xl('cd'); ws=sv.wb.Sheets['거래처일자'];
    T(ws.A5.v==='거래처' && ws.B5.v==='일자' && ws.C5.v==='판매', '거래처×일자 머리 = 거래처 · 일자 · 판매 · 매입');
    T(ws.A7.v==='가나상회 [C1]' && ws.B7.v==='2026-11-05' && ws.A8.v==='' && ws.A9.v==='소계' && ws.A9.s.fill.fgColor.rgb==='E9CDF5', '거래처 첫 줄에만 이름 · 날짜 줄 · 소계 연보라');
    $('#gb').value='S'; sv=await xl('cust'); ws=sv.wb.Sheets['거래처별'];
    T(ws.A1.v==='[판매] 거래처별 등록현황' && ws.G5===undefined || (ws.G5&&ws.G5.v==='') , '판매만이면 매입 묶음 칸이 없다'); $('#gb').value='';
    w.open=()=>({ document:{ write:(h)=>{ html+=h; }, close(){} }, focus(){}, print(){} });
    w.__t.tabGo('cust'); w.__t.printIt(); await tick();
    T(/거래처별 등록현황/.test(html) && /rowspan="2">거래처/.test(html) && /colspan="5">판매/.test(html) && !/매출원장/.test(html), '인쇄도 탭(거래처별 두 줄 머리) — 원장 아님');
    html=''; w.__t.tabGo('doc'); w.__t.printIt(); await tick(); T(/전표별 등록현황/.test(html) && /<th>비고<\/th>/.test(html), '전표별 인쇄'); }
  // 전표 열기 — 셸 밖이면 안내
  w.__alert=''; w.__t.openDoc('S', 11); T(/물류관리 화면 안/.test(w.__alert), '셸 밖에서 열면 안내');
  /* 셸 안 — 판매 전표를 누르면 판매등록을 열고(logiFrame) 상품·거래처를 받은 뒤 그 전표를 얹는다 */
  { const calls=[]; const child={ document:{ readyState:'complete' }, _prods:[], _vendors:[], post:(u,b)=>{ calls.push(['post',u,b]); return Promise.resolve({ json:()=>Promise.resolve({ data:{ saleSeq:11 } }) }); }, saApply:(d)=>calls.push(['apply',d.saleSeq]) };
    const P={ logiFrame:(k,u)=>calls.push(['frame',k,u]), document:{ querySelector:()=>null, getElementById:(id)=>id==='if-salesreg'?{ contentWindow:child }:null } };
    Object.defineProperty(w,'parent',{ value:P, configurable:true });
    w.__t.openDoc('S', 11); await new Promise(r=>setTimeout(r,250));
    T(calls[0][0]==='frame' && calls[0][1]==='salesreg' && /salesReg.do/.test(calls[0][2]) && !calls.some(c=>c[0]==='post'), '판매등록을 열고, 목록이 오기 전에는 전표를 안 얹는다');
    child._prods=[1]; child._vendors=[1]; await new Promise(r=>setTimeout(r,450));
    T(calls.some(c=>c[0]==='post' && c[1]==='/mangr/salesTrxDetail.do' && c[2]==='saleSeq=11') && calls.some(c=>c[0]==='apply' && c[1]===11), '목록이 오면 salesTrxDetail → saApply : '+JSON.stringify(calls)); }
  console.log((bad?'✗':'✓')+' sim_trxStat : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})();
