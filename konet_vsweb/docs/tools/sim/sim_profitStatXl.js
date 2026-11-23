// 이익현황(mangr/profitStat.jsp) 엑셀 꾸밈 시뮬 (2026-11-24 사용자 「체크메뉴 엑셀도 이전 엑셀형식으로」)
//   세 메뉴(gb=1·2·3) 모두 : 제목 · 조회기간 · 띠 · 하늘색 머리 · 노란 Total · % 서식 · 정수 수량 · [회사전체이익] 요약 · 값은 화면 셈(aoaOf)과 같다
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_profitStatXl.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const W=path.join(__dirname,'../../../src/main/webapp/');
const src=fs.readFileSync(W+'WEB-INF/jsp/main/mangr/profitStat.jsp','utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const DATA=[
  { venCd:'V1', venNm:'우리푸드', mgrNm:'전원배', prodCd:'P1', prodNm:'용기A', spec:'300EA', makerNm:'가', packQty:10, saleAmt:100000, rtnAmt:0, costAmt:60000, saleQty:25, rtnQty:0, logiBase:100000, dcCd:'E100' },
  { venCd:'V1', venNm:'우리푸드', mgrNm:'전원배', prodCd:'P2', prodNm:'뚜껑B', spec:'', makerNm:'나', packQty:1, saleAmt:50000, rtnAmt:5000, costAmt:30000, saleQty:10.5, rtnQty:1, logiBase:0 },
  { venCd:'V2', venNm:'풍풍플라워', mgrNm:'마스터', prodCd:'P1', prodNm:'용기A', spec:'300EA', makerNm:'가', packQty:10, saleAmt:30000, rtnAmt:0, costAmt:40000, saleQty:3, rtnQty:0, logiBase:0 },
];
async function run(gb){
  const html=src.replace(/<%@[\s\S]*?%>/g,'').replace(/<%--[\s\S]*?--%>/g,'').replace(/\$\{pageContext\.request\.contextPath\}/g,'/konet').replace(/<script src=[^>]*><\/script>/g,'')
               .replace(/<body[^>]*>/,'<body data-comp="(주)코네트">');
  const dom=new JSDOM(html,{ runScripts:'outside-only', url:'http://x/konet/mangr/profitStat.do?gb='+gb, pretendToBeVisual:true });
  const w=dom.window;
  w.fetch=(u)=>Promise.resolve({ json:()=>Promise.resolve(/profitStatList/.test(u) ? { result:'OK', data:JSON.parse(JSON.stringify(DATA)), recv:[{venCd:'V1',rcvAmt:7000,dcAmt:300}] } : { data:[] }) });
  w._alertBox=()=>{}; w._toast=()=>{};
  w.eval(fs.readFileSync(W+'assets/vendor/xlsx-js-style/xlsx.bundle.js','utf8'));
  let saved=null; w.XLSX.writeFile=(wb,nm)=>{ saved={wb,nm}; };
  const scr=[...src.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1].replace(/\$\{pageContext\.request\.contextPath\}/g,'/konet')).join('\n');
  w.eval(scr+'\n;window.__t={ excel:excel, aoaOf:aoaOf, totRowOf:totRowOf, printIt:printIt };');
  await new Promise(r=>setTimeout(r,20));
  w.__t.excel();
  const nm=saved && saved.wb.SheetNames[0], ws=saved && saved.wb.Sheets[nm], a=w.__t.aoaOf();
  let ph=''; w.open=()=>({ document:{ write:(h)=>{ ph+=h; }, close(){} }, print(){} }); w.__t.printIt();
  return { w, ws, nm, file:saved&&saved.nm, a, html:ph };
}
(async()=>{
  // ── 거래처별 이익 ──
  let r=await run(1), ws=r.ws;
  T(r.nm==='거래처별이익' && /^거래처별이익_\d{8}-\d{8}\.xlsx$/.test(r.file), '거래처별 시트·파일 이름 : '+r.nm+' '+r.file);
  T(ws.A1.v==='[이익현황] 거래처별 이익' && ws.A1.s.font.bold && ws.A1.s.font.sz===16, '제목 굵게 16');
  T(/^조회기간 : \d{4}-\d{2}-01 ~ /.test(ws.A3.v), '조회기간 줄 : '+ws.A3.v);
  T(/~/.test(ws.A4.v) && ws.C4.v==='구분' && ws.E4.v==='이익현황 · 거래처별 이익' && /^출력일자 : /.test(ws.I4.v) && ws.M4.v==='(주)코네트', '띠 = 기간 · 구분 · 메뉴 · 출력일자 · 회사 : '+[ws.A4.v,ws.C4.v,ws.E4.v,ws.I4&&ws.I4.v,ws.M4&&ws.M4.v].join('|'));
  T(ws.A5.v==='#' && ws.B5.v==='거래처' && ws.M5.v==='할인액' && ws.B5.s.fill.fgColor.rgb==='DDEBF7', '칸 머리 13칸 하늘색');
  // 화면 셈과 같은 값 — aoaOf 첫 줄
  T(ws.B6.v===r.a[1][1] && ws.D6.v===r.a[1][3] && ws.J6.v===r.a[1][9], '값 = 화면 셈(aoaOf) 그대로');
  T(ws.H6.s.numFmt==='0.0%' && ws.K6.s.numFmt==='0.0%' && ws.D6.s.numFmt==='#,##0', '반품율·이익율 % 서식 · 금액 #,##0');
  const tr=6+r.a.length-1;   // Total 줄 번호(1부터)
  T(ws['A'+tr].v==='Total' && ws['B'+tr].v==='2곳' && ws['D'+tr].v===180000 && ws['L'+tr].v===7000 && ws['A'+tr].s.fill.fgColor.rgb==='FFE699', 'Total 줄 노랑 · 판매액 180,000 · 수금액 7,000 : '+(ws['A'+tr]&&ws['A'+tr].v));
  const neg=Object.keys(ws).find(k=>/^J\d+$/.test(k) && ws[k].v<0 && ws[k].s.font && ws[k].s.font.color);
  T(!!neg, '이익금 음수 = 빨강 글자(풍풍플라워 -10,000)');
  const sr=tr+2; T(ws['A'+sr].v==='[회사전체이익]' && ws['A'+(sr+1)].v==='판매액' && ws['A'+(sr+2)].v===180000 && ws['E'+(sr+2)].s.numFmt==='0.0%', '[회사전체이익] 요약 = 판매액 180,000 · 반품율 %');
  T(ws['!merges'].length>=6, '병합(제목·조회기간·띠·요약 제목)');
  // ── 상품별 이익 ──
  r=await run(2); ws=r.ws;
  T(r.nm==='상품별이익' && ws.A1.v==='[이익현황] 상품별 이익' && ws.B5.v==='상품' && ws.T5.v==='이익율', '상품별 시트 20칸');
  const row105=Object.keys(ws).find(k=>/^G\d+$/.test(k) && ws[k].v===10.5);
  T(row105 && ws[row105].s.numFmt==='#,##0.##', '소수 수량(10.5)만 소수 서식');
  const rowInt=Object.keys(ws).find(k=>/^G\d+$/.test(k) && ws[k].v===28);
  T(rowInt && ws[rowInt].s.numFmt==='#,##0', '정수 수량(28) = #,##0 — 「28.」로 안 보이게');
  // ── 거래처별 상품별 이익 ──
  r=await run(3); ws=r.ws;
  T(r.nm==='거래처별상품별이익' && ws.A1.v==='[이익현황] 거래처별 상품별 이익' && ws.C5.v==='거래처' && ws.P5.v==='이익율', '거래처별 상품별 시트 16칸');
  const t3=6+r.a.length-1; T(ws['A'+t3].v==='Total' && ws['C'+t3].v==='3줄' && ws['M'+t3].s.numFmt==='0.0%', 'Total 3줄 · 반품율 %');
  // ── 인쇄 = 엑셀과 같은 틀 (2026-11-24 「인쇄도 같은 형식으로」) ──
  for(const g of [1,2,3]){ const q=await run(g), h=q.html, ttl=['','거래처별 이익','상품별 이익','거래처별 상품별 이익'][g];
    T(h.indexOf('<h1>[이익현황] '+ttl+'</h1>')>=0 && /class="per">조회기간 : /.test(h), 'gb='+g+' 인쇄 제목·조회기간');
    T(/<tr class="band"><th colspan="2">[^<]*~/.test(h) && h.indexOf('>구분</th>')>=0 && h.indexOf('이익현황 · '+ttl)>=0 && /출력일자 : /.test(h) && h.indexOf('(주)코네트')>=0, 'gb='+g+' 인쇄 띠(기간·구분·메뉴·출력일자·회사)');
    T(h.indexOf('<tr class="tot"><td class="c">Total</td>')>=0 && h.indexOf('[회사전체이익]')>=0 && h.indexOf('물류비(차감) = ')>=0 && h.indexOf('thead{display:table-header-group}')>=0, 'gb='+g+' 인쇄 Total·회사전체이익·물류비 설명·머리 반복'); }
  { const q=await run(1); T(q.html.indexOf('<td class="neg">-10,000</td>')>=0 && q.html.indexOf('%</td>')>=0 && q.html.indexOf('<td class="c">1</td>')>=0, '인쇄 음수 빨강 · % 표시 · # 번호 가운데'); }
  console.log((bad?'✗':'✓')+' sim_profitStatXl : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})();
