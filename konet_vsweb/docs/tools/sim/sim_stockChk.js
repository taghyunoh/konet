// 재고 변동 확인 (2026-11-26 신설 · 같은 날 오후 2판 = 품목 단위 · 지운 전표도 · 작업한 때 기준) — 화면 prod/stockChk.jsp 시뮬 + 서버 쪽 약속 검사
//   사용자 「재고담당자가 입고·판매 관련 내용을 보고 재고에 반영할지, 적용 안 할지 관리」 → 「반영 후 확인 방식으로 진행해줘」
//   2판 「풀어서 보여주고 · 삭제한 것은 … 재고에서 제외 여부 있어야 250 재고로 포함 나옴 · 전표일자가 아니고 작업한 일자 기준」 · 「세부코드 검색」 · 「년도도 표시」 · 「재고적용, 재고 미적용 으로」
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_stockChk.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
const R=p=>fs.readFileSync(path.join(__dirname,'../../..',p),'utf8').replace(/\r\n/g,'\n');
const jsp=R('src/main/webapp/WEB-INF/jsp/main/prod/stockChk.jsp'), X=R('src/main/resources/egovframework/sqlmap/mapper/User_SQL.xml');
const C=R('src/main/java/egovframework/konet/user/web/UserController.java'), J=R('src/main/java/egovframework/konet/user/service/impl/UserServiceImpl.java');
const TX=R('src/main/resources/egovframework/spring/context-transaction.xml'), DDL=R('docs/sql/20261126_stock_chk.sql');
const SH=R('src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), EB=R('src/main/webapp/asset/js/emp-badge.js');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const sleep=ms=>new Promise(r=>setTimeout(r,ms));

const html=jsp.replace(/<%--[\s\S]*?--%>/g,'').replace(/<%@[\s\S]*?%>/g,'').replace(/\$\{pageContext\.request\.contextPath\}/g,'')
  .replace(/<script src="[^"]*"><\/script>/g,'');
const START='2026-11-26 09:00:00';
const mk=(o)=>Object.assign({ refGb:'PURCH', refSeq:1, trxDt:'20261126', trxNo:'0001', custCd:'V1', custNm:'버개스패키지', totAmt:1000, liveYn:'Y', remark:'',
  regDttm:'2026-11-26 10:00:00', regUser:'K003', regUserNm:'전원배', updDttm:null, updUser:null, evDttm:'2026-11-26 10:00:00',
  chkState:null, verDttm:null, chkMemo:null, chkDttm:null, chkUser:null, chkUserNm:null }, o);
const ln=(gb,seq,row,ps,cd,nm,q,o)=>Object.assign({ refGb:gb, refSeq:seq, rowNo:row, prodSeq:ps, prodCd:cd, prodNm:nm, trxGb:gb==='PURCH'?'매입':'판매', qty:Math.abs(q), stkQty:q, curQty:70, adjDt:'20261118', adjQty:412, adjFixYn:'N', adjRegDttm:'2026-11-18 09:53:04', xState:null, xMemo:null, xDttm:null, xUserNm:null }, o||{});
const DATA=[
  mk({ refSeq:1 }),                                                                                                   // 새로 넣음 · 미확인
  mk({ refSeq:2, chkState:'C', verDttm:'2026-11-26 10:00:00', chkDttm:'2026-11-26 11:00:00', chkUserNm:'설재우' }),      // 확인
  mk({ refSeq:3, chkState:'C', verDttm:'2026-11-26 10:00:00', updDttm:'2026-11-26 12:00:00', updUser:'K001', updUserNm:'김민지', evDttm:'2026-11-26 12:00:00' }),   // 확인 뒤 고침 → 다시 미확인
  mk({ refSeq:4, chkState:'X', verDttm:'2026-11-26 10:00:00', chkMemo:'중복 입력', chkDttm:'2026-11-26 11:30:00', chkUserNm:'마스터' }),   // 전표 전체 재고 미적용
  mk({ refSeq:427, trxDt:'20260916', trxNo:'0002', liveYn:'N', regDttm:'2026-09-16 13:54:00', regUser:'admin', regUserNm:'마스터', updDttm:'2026-11-26 13:00:00', updUser:'admin', updUserNm:'마스터', evDttm:'2026-11-26 13:00:00' }),   // 지움 · 미확인
  mk({ refSeq:6, regDttm:'2026-11-25 10:00:00', evDttm:'2026-11-25 10:00:00' }),                                         // 이 기능을 켜기 전 → 시작 전
  mk({ refGb:'SALE', refSeq:7, custNm:'퐁퐁플라워' })                                                                    // 판매 · 미확인
];
const LINES=[
  ln('PURCH',1,1,11,'P0011','덮밥용기 뚜껑',100),
  ln('PURCH',2,1,11,'P0011','덮밥용기 뚜껑',50), ln('PURCH',2,2,13,'P0013','펄프용기뚜껑',-10,{ trxGb:'반품' }),
  ln('PURCH',3,1,11,'P0011','덮밥용기 뚜껑',30), ln('PURCH',3,2,12,'P0012','종이컵',20,{ xState:'X', xMemo:'실물이 아직 안 들어옴', xDttm:'2026-11-26 12:30:00', xUserNm:'마스터' }),
  ln('PURCH',4,1,11,'P0011','덮밥용기 뚜껑',40),
  ln('PURCH',427,1,204,'1000736038','(배고픈덮밥이)덮밥용기',250), ln('PURCH',427,2,2057,'1000808776','(빈쿨룸)다더퍼',105), ln('PURCH',427,3,1981,'9904013323','원형종이용기',599,{ curQty:681, adjDt:'20261122', adjQty:682, adjFixYn:'Y', adjRegDttm:'2026-11-22 22:54:19' }),
  ln('PURCH',6,1,11,'P0011','덮밥용기 뚜껑',5),
  ln('SALE',7,1,21,'S0021','딸기스무디',-76)
];
async function boot(admin){
  const dom=new JSDOM(html,{ runScripts:'dangerously', pretendToBeVisual:true, url:'http://localhost/', beforeParse(w){
    w.__calls=[]; w.__alerts=[]; w.__toasts=[]; w.__conf=[];
    w._alertBox=(m,o)=>w.__alerts.push(String(m)); w._toast=(m,t)=>w.__toasts.push(String(m)+'|'+t); w._confirmBox=(o)=>{ w.__conf.push(String(o.msg)+'|'+o.okText); if(o.onOk) o.onOk(); };
    w.fetch=(u,opt)=>{ w.__calls.push({ u:u, body:opt.body });
      let j;
      if(u.indexOf('stockChkList')>=0) j={ result:'OK', admin:admin?'Y':'N', me:'K003', startDttm:START, frDt:'2026-11-20', toDt:'2026-11-26', data:JSON.parse(JSON.stringify(DATA)), lines:JSON.parse(JSON.stringify(LINES)), pendAll:(w.__pendAll==null?4:w.__pendAll) };
      else j=w.__actRes||{ result:'OK', done:1, skip:0, blocked:0, prods:[] };
      return Promise.resolve({ ok:true, json:()=>Promise.resolve(j) }); };
  } });
  await sleep(30); return dom.window;
}
const txt=(w,sel)=>Array.from(w.document.querySelectorAll(sel)).map(e=>e.textContent.replace(/\s+/g,' ').trim());
const rowBy=(w,k)=>Array.from(w.document.querySelectorAll('#body tr.row')).find(r=>r.getAttribute('data-k')===k);
const linesBy=(w,k)=>{ const r=rowBy(w,k); const n=r && r.nextElementSibling; return (n && n.classList.contains('lines')) ? n : null; };
const lastAct=(w)=>{ const c=w.__calls.filter(x=>x.u.indexOf('stockChkAct')>=0).pop(); return c && JSON.parse(c.body); };
(async()=>{
  /* ── 관리자 ── */
  let w=await boot(true), d=w.document;
  T(w.__calls[0] && w.__calls[0].u==='/prod/stockChkList.do' && /frDt=\d{4}-\d\d-\d\d&toDt=\d{4}-\d\d-\d\d/.test(w.__calls[0].body), '열면 최근 7일을 조회한다');
  let rows=txt(w,'#body tr.row');
  T(rows.length===5 && /미확인 4건 · 시작 전 1건/.test(d.getElementById('cnt').textContent.replace(/\s+/g,' ')), '기본 = 미확인 · 시작 전(새 전표 · 확인 뒤 고친 전표 · 지운 전표 · 판매 + 시작 전 1) — 「전체」로 안 바꿔도 보인다 : '+rows.length);
  T(!d.getElementById('legend') && /아직 아무도 확인하지 않은 작업/.test(jsp) && /실물도 전표대로 움직였다고 확인함/.test(jsp) && jsp.indexOf('이 기능을 켜기 전(')>0, '「상태 뜻」 줄은 뺐다(사용자 「상태뜻도 제거」) — 뜻은 상태 표 말풍선으로');
  T(/tr\.row > td\{ background:#e3f1ee; font-weight:700; border-top:2px solid/.test(jsp) && /tr\.lines > td\{[^}]*border-left:5px solid/.test(jsp), '전표(대표) 줄은 청록 바탕·굵은 글·위 굵은 선 · 품목 줄 묶음은 왼쪽 띠');
  /* 작업한 때 기준 · 연도까지 · 작업한 사람 */
  const heads=txt(w,'table.g thead th');
  T(heads[1]==='작업한 때' && heads[2]==='작업한 사람' && heads[5]==='전표 (일자 / 번호)', '맨 앞 칸 = 작업한 때 · 작업한 사람(전표 일자는 뒤 칸)');
  const dRow=rowBy(w,'PURCH:427');
  T(dRow.cells[1].textContent.trim()==='2026-11-26 13:00' && /마스터/.test(dRow.cells[2].textContent) && /처음 넣음 2026-09-16 13:54/.test(dRow.cells[2].textContent) && /2026-09-16 \/ 0002/.test(dRow.cells[5].textContent), '지운 전표 — 작업한 때 = 지운 때(연도까지) · 처음 넣은 때도 연도까지 · 전표 일자는 따로');
  /* 처음부터 펼침 · 지운 전표의 재고 영향 = 반대 부호 */
  const dl=linesBy(w,'PURCH:427');
  T(dl && dl.querySelectorAll('table.ln tbody tr').length===3, '품목 줄은 처음부터 펼쳐져 있다');
  const dls=Array.from(dl.querySelectorAll('table.ln tbody tr'));
  T(/-250/.test(dls[0].cells[4].textContent) && /-954/.test(dRow.cells[8].textContent) && /🔒/.test(dls[2].cells[6].textContent), '지운 매입전표 — 재고 영향은 −(지워서 빠진 수량) · 전표 합 −954 · 고정 품목 🔒');
  T(dls.every(r=>/재고 미적용|🔒 적용 안 됨/.test(r.cells[8].textContent)) && /확인/.test(dRow.cells[11].textContent) && /전체 미적용/.test(dRow.cells[11].textContent), '지운 전표도 품목마다 [재고 미적용](고정된 재고수정보다 앞이면 「🔒 적용 안 됨」) · 전표 줄 [확인] [전체 미적용]');
  /* 지운 전표의 한 품목만 재고 미적용 → 사유 창 → act X + prodSeq */
  w.__calls.length=0; w.rsOpen(null,'PURCH:427',204);
  T(d.getElementById('rsBd').style.display==='flex' && /1000736038/.test(d.getElementById('rsMsg').textContent) && /-250/.test(d.getElementById('rsMsg').textContent) && /지우기 전으로/.test(d.getElementById('rsMsg').textContent), '사유 창 — 그 품목 · 지워서 빠진 수량 −250 · 「지우기 전으로 돌아갑니다」');
  w.rsGo(); T(!w.__calls.length && /사유/.test(d.getElementById('rsErr').textContent), '사유가 없으면 보내지 않는다');
  w.rsPick(d.querySelector('#rsChips button')); w.__actRes={ result:'OK', done:1, skip:0, blocked:0, prods:[{ prodCd:'1000736038', prodNm:'덮밥용기', bef:70, aft:320 }] };
  w.__alerts.length=0; w.rsGo(); await sleep(10);
  let b=lastAct(w);
  T(b && b.act==='X' && b.items.length===1 && b.items[0].refGb==='PURCH' && b.items[0].refSeq===427 && b.items[0].prodSeq===204 && /서류만 삭제/.test(b.memo), '보내는 것 = act X · 그 전표의 그 품목(prodSeq 204) · 사유');
  T(w.__alerts.some(a=>/재고 미적용 1건/.test(a) && /70 → <b>320<\/b>/.test(a)), '결과 — 현재고 70 → 320 (250 이 재고에 다시 들어감)');
  /* 살아 있는 전표 — 줄마다 · 품목 미적용 표시와 [재고 적용] */
  d.getElementById('fSt').value=''; w.render();
  const l3=Array.from(linesBy(w,'PURCH:3').querySelectorAll('table.ln tbody tr'));
  T(/재고 미적용/.test(l3[1].cells[8].textContent) && /재고 적용/.test(l3[1].cells[8].textContent) && /실물이 아직 안 들어옴/.test(l3[1].cells[8].textContent) && l3[1].cells[4].classList.contains('off'), '품목만 미적용한 줄 — 「재고 미적용」 · 사유 · [재고 적용] · 재고 영향 취소선');
  T(/\+30/.test(rowBy(w,'PURCH:3').cells[8].textContent) && /품목 1개 재고 미적용/.test(rowBy(w,'PURCH:3').cells[10].textContent), '전표 줄의 재고 영향은 미적용 품목을 빼고(+30) · 「품목 1개 재고 미적용」');
  w.__calls.length=0; w.__conf.length=0; w.__actRes=null; w.act(null,'PURCH:3',12,'U'); await sleep(10); b=lastAct(w);
  T(b && b.act==='U' && b.items[0].prodSeq===12 && w.__conf.some(m=>/P0012/.test(m) && /다시 재고에 적용합니다/.test(m) && /\|재고 적용$/.test(m)), '[재고 적용] — 품목 이름을 보이고 묻는다 · act U + prodSeq');
  /* 전표 전체 미적용 줄 */
  const r4=rowBy(w,'PURCH:4'), l4=Array.from(linesBy(w,'PURCH:4').querySelectorAll('table.ln tbody tr'));
  T(/재고 미적용/.test(r4.cells[10].textContent) && /중복 입력/.test(r4.cells[10].textContent) && /재고 적용/.test(r4.cells[11].textContent) && /전표 전체/.test(l4[0].cells[8].textContent) && !l4[0].cells[8].querySelector('button') && /^\+?0$/.test(r4.cells[8].textContent.trim()), '전표 전체 미적용 — 상태·사유·[재고 적용] · 줄은 「전표 전체」(줄 단추 없음) · 재고 영향 0');
  w.__calls.length=0; w.rsOpen(null,'PURCH:1',0); w.rsPick(d.querySelector('#rsChips button')); w.rsGo(); await sleep(10); b=lastAct(w);
  T(b && b.act==='X' && b.items[0].prodSeq===0, '[전체 미적용] = prodSeq 0');
  /* 상태 필터 · 찾기(품목코드) · 시작 전 */
  d.getElementById('fSt').value='X'; w.render(); T(txt(w,'#body tr.row').length===2, '상태 「재고 미적용」 = 전표 전체 미적용 + 품목이 하나라도 미적용인 전표');
  d.getElementById('fSt').value=''; w.render(); T(txt(w,'#body tr.row').length===7 && txt(w,'#body tr.row').some(r=>/시작 전/.test(r)) && /미확인 4건/.test(d.getElementById('cnt').textContent.replace(/\s+/g,' ')), '전체 보기 7줄 · 시작 전 전표는 미확인 숫자에 안 든다');
  d.getElementById('fQ').value='1000808776'; w.render();
  T(txt(w,'#body tr.row').length===1 && rowBy(w,'PURCH:427') && linesBy(w,'PURCH:427').querySelectorAll('tr.hit').length===1, '찾기 — 품목코드로(그 전표만 · 맞은 품목 줄은 노란 바탕)');
  d.getElementById('fQ').value='스무디'; w.render(); T(txt(w,'#body tr.row').length===1 && !!rowBy(w,'SALE:7'), '찾기 — 품목명으로');
  d.getElementById('fQ').value=''; d.getElementById('fGb').value='SALE'; w.render(); T(txt(w,'#body tr.row').length===1 && /-76/.test(rowBy(w,'SALE:7').cells[8].textContent), '구분 = 판매 · 판매전표는 재고 영향이 −');
  d.getElementById('fSt').value=''; d.getElementById('fGb').value='DEL'; w.render(); T(txt(w,'#body tr.row').length===1 && !!rowBy(w,'PURCH:427'), '구분 = 삭제 — 지운 전표만');
  d.getElementById('fGb').value='RTN'; w.render(); T(txt(w,'#body tr.row').length===1 && !!rowBy(w,'PURCH:2') && /\+40/.test(rowBy(w,'PURCH:2').cells[8].textContent), '구분 = 반품 — 반품 줄이 있는 전표만(재고 영향 50 − 10 = +40)');
  d.getElementById('fGb').value='PURCH'; w.render(); T(txt(w,'#body tr.row').length===6, '구분 = 매입 — 매입전표 6(지운 것 포함)');
  T(Array.from(d.getElementById('fGb').options).map(o=>o.textContent).join(',')==='구분 전체,매입,판매,삭제,반품', '구분 고르기 = 전체 · 매입 · 판매 · 삭제 · 반품');
  d.getElementById('fGb').value=''; d.getElementById('fSt').value='P'; w.render();
  /* 확인 — 한 건 · 여러 건 */
  w.__calls.length=0; w.__toasts.length=0; w.act(null,'PURCH:1',0,'C'); await sleep(10); b=lastAct(w);
  T(b && b.act==='C' && b.items[0].refSeq===1 && b.items[0].prodSeq===0 && w.__toasts.some(t=>/확인 1건/.test(t)) && w.__calls.some(x=>x.u.indexOf('stockChkList')>=0), '[확인] → act C(전표) · 토스트 · 다시 조회');
  w.__calls.length=0; w.__alerts.length=0; w.bulkConfirm(); T(w.__alerts.length===1 && !w.__calls.length, '고른 것이 없으면 안내만');
  w.chkAll(true); w.__conf.length=0; w.bulkConfirm(); await sleep(10); b=lastAct(w);
  T(b && b.act==='C' && b.items.length===5 && w.__conf.some(m=>/5건/.test(m)), '[☑ 선택 확인] — 보이는 미확인·시작 전 5건을 한 번에(묻고 나서)');
  /* 접기 */
  w.toggle('PURCH:1'); T(!linesBy(w,'PURCH:1') && !!linesBy(w,'PURCH:427'), '전표 줄을 누르면 그 전표의 품목 줄만 접힌다');
  w.foldAll(); T(!d.querySelector('#body tr.lines') && d.getElementById('btnFold').textContent==='품목 줄 펼치기', '[품목 줄 접기] — 전부 접고 단추 글이 바뀐다');
  w.toggle('PURCH:427'); T(!!linesBy(w,'PURCH:427') && d.querySelectorAll('#body tr.lines').length===1, '접어 둔 채로 한 전표만 펼칠 수 있다');
  /* 말 — 「제외」 를 쓰지 않는다 */
  T(!/제외/.test(d.body.textContent), '화면 글에 「제외」 가 없다(재고 적용 · 재고 미적용)');
  /* ── 관리자가 아닌 사람 ── */
  w=await boot(false); d=w.document; d.getElementById('fSt').value=''; w.render();
  T(!Array.from(d.querySelectorAll('#body button')).some(x=>/미적용|재고 적용/.test(x.textContent)) && /관리자만/.test(rowBy(w,'PURCH:4').cells[11].textContent) && Array.from(d.querySelectorAll('#body button')).some(x=>x.textContent==='확인'), '관리자가 아니면 재고 미적용·재고 적용 단추가 없다([확인]만)');
  /* 미확인이 없고 시작 전만 있을 때의 안내 */
  w.ROWS.forEach(r=>{ if(w.stOf(r)==='P'){ r.chkState='C'; r.verDttm=r.evDttm; } }); d.getElementById('fSt').value='P'; w.render();
  T(txt(w,'#body tr.row').length===1 && /시작 전/.test(txt(w,'#body tr.row')[0]), '미확인이 없어도 — 시작 전 작업은 「미확인 · 시작 전」 에서 그대로 보인다');

  /* ── 서버 쪽 약속 ── */
  const blk=(tag,id)=>{ const i=X.indexOf('<'+tag+' id="'+id+'"'); return i<0?'':X.slice(i, X.indexOf('</'+tag+'>', i)); };
  const frag=blk('sql','stockChkKeep'), sync=blk('update','syncStockChkLedger');
  T(frag.indexOf("IF COL_LENGTH('dbo.TBL_STOCK_CHK', 'PROD_SEQ') IS NOT NULL")>0 && frag.indexOf('EXEC sp_executesql N')>0 && frag.indexOf("N'@c VARCHAR(10), @p BIGINT', @c = @SCK_C, @p = @SCK_P")>0, '조각 stockChkKeep — 칸이 있을 때만 · 동적 SQL(칸이 없는 DB 에서도 재집계가 컴파일된다)');
  T((frag.match(/SET l\.ACTION_YN = ''X''/g)||[]).length===2 && frag.indexOf("( c.PROD_SEQ = 0 OR l.PROD_SEQ = c.PROD_SEQ )")>0, '살아 있는 전표 — 미적용(전표 전체 또는 그 품목)의 Y 줄을 X 로(매입·판매)');
  T(frag.indexOf("l.REF_GB = ''PURCHK'', l.REF_NO = l.REF_NO + ''#'' + CAST(m.PURCH_SEQ AS VARCHAR(12))")>0 && frag.indexOf("l.REF_GB = ''SALEK''")>0 && frag.indexOf("DATEADD(SECOND, -5, CONVERT(DATETIME, m.UPD_DTTM, 120))")>0 && frag.indexOf("m.ACTION_YN = ''N''")>0, '지운 전표 — 지울 때 닫힌 줄(5초 안)을 되살린다 · 근거구분 …K · 번호 뒤 #전표키');
  T(frag.indexOf("SET l.ACTION_YN = ''N'', l.REF_GB = ''PURCH'', l.REF_NO = LEFT(l.REF_NO, CHARINDEX(''#'', l.REF_NO) - 1)")>0, '되살린 줄 — 미적용을 풀거나 전표가 되살아나면 도로 닫고 근거구분·번호를 원래대로');
  T(frag.indexOf("SET l.ACTION_YN = ''Y''\n  FROM TBL_STOCK_LEDGER l")<0 && (sync.match(/SET l\.ACTION_YN = ''Y''\n  FROM TBL_STOCK_LEDGER l/g)||[]).length===2, 'X → Y(재고 적용)는 처리할 때만(syncStockChkLedger) — 재집계 조각에는 없다');
  ['recalcStockMstAll','recalcStockMst'].forEach(id=>T(X.indexOf('<update id="'+id+'" parameterType="egovframework.konet.user.model.StockLedgerDTO"><include refid="stockChkKeep"/><include refid="adjAnchorKeep"/>')>0, id+' — 미적용 지키기가 수정재고 고정보다 먼저'));
  T(blk('update','deletePurchaseLedger').indexOf("ACTION_YN IN ('Y','X') AND REF_GB='PURCH'")>0 && blk('update','deleteSalesTrxLedger').indexOf("ACTION_YN IN ('Y','X') AND REF_GB='SALE'")>0, '전표를 고치거나 지우면 X 줄도 같이 걷는다');
  ['selectStockOutByMonth','selectStockOutDetail'].forEach(id=>T(blk('select',id).indexOf("xl.ACTION_YN = 'X' )")>0, id+' — 재고 미적용한 판매전표는 출고로 세지 않는다'));
  T(blk('select','selectStockChkList').indexOf('AND c.PROD_SEQ = 0')>0 && blk('select','selectStockChkPendCnt').indexOf('AND c.PROD_SEQ = 0')>0 && blk('select','selectStockChkPendCnt').indexOf("REF_GB = 'START'")>0, '전표 상태·메뉴 숫자 = 전표 줄(PROD_SEQ 0) · 시작 뒤 작업만');
  T(blk('select','selectStockChkLineAll').indexOf("cx.PROD_SEQ = y.prodSeq AND cx.PROD_SEQ > 0 AND cx.STATE = 'X'")>0 && blk('select','selectStockChkLineAll').indexOf('TBL_STOCK_MST sm')>0, '품목 줄 — 그 품목만 미적용한 줄 표시 · 현재고는 재고 표에서');
  T(blk('update','upsertStockChk').indexOf('t.PROD_SEQ = s.PROD_SEQ')>0 && blk('update','upsertStockChk').indexOf('WHEN NOT MATCHED AND s.VER_DTTM IS NOT NULL')>0, '한 줄 = 전표 + 품목 · 없는 전표엔 줄을 안 만든다');
  T(/if \("X"\.equals\(act\) && !admin\)/.test(C) && /if \("X"\.equals\(act\) && memo\.isEmpty\(\)\)/.test(C) && /if \(!admin && \("X"\.equals\(act\) \|\| wasX\)\) \{ blocked\+\+; continue; \}/.test(J), '재고가 바뀌는 처리는 관리자만(컨트롤러 + 서비스가 DB 상태로) · 미적용은 사유 필수');
  T(J.indexOf('if (prodSeq < 0 || ("C".equals(act) && prodSeq != 0)) prodSeq = 0;')>0 && J.indexOf('mapper.syncStockChkLedger(sp);')>0 && J.indexOf('mapper.recalcStockMst(led);')>0 && J.indexOf('if ("X".equals(act) && (bef == null || bef.isEmpty())) { skip++; continue; }')>0 && J.indexOf('"Y".equals(live.trim())')<0, '서비스 — 확인은 전표 단위 · 원장 맞추기 → 품목마다 재집계 · 그 전표에 없는 품목은 건너뜀 · 지운 전표도 처리');
  T(C.indexOf('res.put("lines", svc.selectStockChkLineAll(p));')>0 && C.indexOf('/prod/stockChkLines.do')<0, '목록 응답에 품목 줄을 함께(따로 부르는 주소 없음)');
  T(TX.indexOf('UserServiceImpl.stockChkAct(..))')>0, '처리는 트랜잭션으로 묶인다');
  T(DDL.indexOf("IF OBJECT_ID('dbo.TBL_STOCK_CHK', 'U') IS NULL")>0 && DDL.indexOf("IF COL_LENGTH('dbo.TBL_STOCK_CHK', 'PROD_SEQ') IS NULL")>0 && DDL.indexOf('UX_TBL_STOCK_CHK_REF2')>0 && DDL.indexOf("'START', 0, 0, 'S'")>0, 'DDL — 없으면 만들고 · 오전 판이면 품목 칸만 더함 · 시작 표시는 그대로');
  T(SH.indexOf('data-key="stockChk"')>0 && SH.indexOf('id="panel-stockChk"')>0 && SH.indexOf('id="if-stockChk"')>0 && SH.indexOf('id="stkChkBadge"')>0 && EB.indexOf("paint('stkChkBadge'")>0 && C.indexOf('r.put("stkChk"')>0, '셸 메뉴 · 패널 · 배지(미확인 건수)');
  /* ── 수불 내역·월별 출고현황이 «재고 적용 / 미적용» 을 보인다 (2026-11-26 사용자 「재고미적용이면 표시도 틀려야함 월별재고도 마찬가지 적용미적용에 따라」) ── */
  { const LO=R('src/main/webapp/js/winct/logi-oh.js'), SOM=R('src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp');
    const pick=(src,name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let dd=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') dd++; else if(src[k]==='}'){ if(--dd===0) return src.slice(i,k+1); } } };
    const F=new Function('var _cesc=function(v){ return String(v).replace(/&/g,"&amp;").replace(/</g,"&lt;"); };\n'+['stkLedKeepRow','stkLedRefGb','stkLedRefNo','stkLedRmk'].map(n=>pick(LO,n)).join('\n')+'\nreturn { g:stkLedRefGb, n:stkLedRefNo, r:stkLedRmk };')();
    const kept={ refGb:'PURCHK', refNo:'20260916-0002#427', remark:'비고' }, norm={ refGb:'PURCH', refNo:'20261125-0008', remark:'비고' };
    T(/^PURCH <span/.test(F.g(kept)) && /삭제 전표/.test(F.g(kept)) && F.n(kept)==='20260916-0002' && /삭제 전표 · 재고 미적용/.test(F.r(kept)) && /비고$/.test(F.r(kept)), '수불 줄 — 되살려 둔 줄(PURCHK · #전표키)은 「PURCH 삭제 전표 · 20260916-0002 · 삭제 전표 · 재고 미적용」');
    T(F.g(norm)==='PURCH' && F.n(norm)==='20261125-0008' && F.r(norm)==='비고', '그 밖의 수불 줄은 종전 글 그대로');
    T(LO.indexOf("var keep=(x.keepYn==='Y');")>0 && LO.indexOf("var after=!keep && !!(adjAt && del && del > adjAt && adjDt && pd && pd <= adjDt")>0 && LO.indexOf("재고 미적용 · 재고에 그대로")>0 && LO.indexOf("OF.forEach(function(x){")>0 && LO.indexOf("재고 미적용 — 재고에 들어 있지 않음")>0,
      '품목별재고현황 — 삭제된 입고 줄이 재고 미적용이면 「재고에 그대로」(빨간 「조정 뒤 삭제」 꼬리 없음) · 살아 있는 전표의 재고 미적용 줄은 회색 줄로');
    T((SH.match(/stkLedRefGb\(l\)/g)||[]).length===3 && (SH.match(/stkLedRefNo\(l\)/g)||[]).length===3 && (SH.match(/stkLedRmk\(l\)/g)||[]).length===3 && SH.indexOf("_cesc(l.refGb||'')")<0 && SH.indexOf("_cesc(l.refNo||'')")<0, '셸 수불 내역·나누어보기 — 근거구분·번호·비고를 그 도우미로 그린다(수불 내역 본표도)');
    T((SH.match(/stkLedAct\(l\)/g)||[]).length===1 && SH.indexOf("+stkLedRmk(l)+stkLedAct(l)+'</td>'")>0, '수불 내역 본표의 비고 칸 뒤에 [재고 미적용]/[재고 적용] 단추(나누어보기 창에는 안 붙인다)');
    const G=new Function('var esc=function(v){ return String(v==null?"":v); };\n'+['somKeepRow','somRef','somKeepTag'].map(n=>pick(SOM,n)).join('\n')+'\nreturn { ref:somRef, tag:somKeepTag };')();
    T(G.ref(kept)==='PURCH 20260916-0002' && /삭제 전표 · 재고 미적용/.test(G.tag(kept)) && G.ref(norm)==='PURCH 20261125-0008' && G.tag(norm)==='', '월별 출고현황 입고내역 — 되살려 둔 줄 표시 · 그 밖은 그대로');
    T(SOM.indexOf("var keep=(x.keepYn==='Y');")>0 && SOM.indexOf("재고 미적용 · 재고에 그대로")>0 && SOM.indexOf('function somOffRows(sel, fr, to){')>0 && SOM.indexOf("'+pd.h+of.inH+dl.h;")>0 && SOM.indexOf("'+of.outH+ds.h;")>0,
      '월별 출고현황 — 삭제 줄의 재고 미적용 표시 · 살아 있는 전표의 재고 미적용 줄(입고내역·출고내역 맨 위)');
    const dp=blk('select','selectProdDelPurch'), dsl=blk('select','selectProdDelSales'), off=blk('select','selectProdChkOff');
    T(dp.indexOf("kk.REF_GB = 'PURCHK'")>0 && dp.indexOf('AS keepYn')>0 && dsl.indexOf("kk.REF_GB = 'SALEK'")>0 && off.indexOf("l.ACTION_YN = 'X' AND l.REF_GB IN ('PURCH','SALE')")>0 && C.indexOf('res.put("off", svc.selectProdChkOff(p));')>0, '서버 — 지운 전표 줄에 keepYn(원장의 …K 줄로 판정) · 재고 미적용 줄(원장 X) 목록 off');
    ['selectStockOutByMonth','selectStockOutDetail'].forEach(id=>T(blk('select',id).indexOf("l.REF_GB = 'SALEK' AND l.IO_GB = 'O' AND l.ACTION_YN = 'Y'")>0, id+' — 지운 판매전표인데 재고 미적용한 출고(SALEK)도 출고로 센다')); }
  /* ── 기간 밖 미확인 (2026-11-26 「2번은 무슨뜻인가요 1표시」 — 메뉴 배지 1 인데 고른 기간엔 미확인 0) · 도움말 문단 제거(「1번 제거」) ── */
  { const w=await boot(true), d=w.document;
    T(!/기간 밖 미확인/.test(d.getElementById('cnt').textContent), '전체 미확인 = 기간 안 미확인이면 안내 없음');
    w.PEND_ALL=5; w.render(); const a=d.querySelector('#cnt a');
    T(!!a && /기간 밖 미확인 1건 보기/.test(a.textContent), '전체 미확인(배지) 5 · 기간 안 4 → 「기간 밖 미확인 1건 보기」', d.getElementById('cnt').textContent);
    w.__calls.length=0; d.getElementById('fSt').value='C'; a.click(); await sleep(20);
    const lb=w.__calls.filter(x=>/stockChkList/.test(x.u)).pop();
    T(!!lb && /frDt=2026-11-26/.test(lb.body) && d.getElementById('fSt').value==='P', '[보기] = 이 기능을 켠 날부터 오늘까지 · 상태 「미확인 · 시작 전」 으로 다시 조회', lb && lb.body);
    T(!/품목 줄의 <b>「재고수정 이전」/.test(jsp) && !d.querySelector('.help'), '도움말에서 재고수정 이전 문단을 뺐다(뜻은 표 말풍선)');
    T(C.indexOf('res.put("pendAll", svc.selectStockChkPendCnt(p));')>0, '목록 응답에 전체 미확인 건수(pendAll)');
  }
  /* ── 재고수정 이전 표시 · 「최종 재고수정 이후만」 (2026-11-26 사용자 「여기에도 현재고수정 이전인지 보여주세요(현재 싯점 최종재고수정이후 것만 조회 조건 추가)」) ── */
  { const w=await boot(true), d=w.document;
    d.getElementById('fSt').value=''; w.render();
    const lnTxt=(k)=>{ const r=rowBy(w,k); const nx=r && r.nextElementSibling; return nx && nx.classList.contains('lines') ? nx.textContent.replace(/\s+/g,' ') : ''; };
    T(w.preAdj({ trxDt:'20260916' }, { adjDt:'20261118' }) && !w.preAdj({ trxDt:'20261118' }, { adjDt:'20261118' }) && !w.preAdj({ trxDt:'20261126' }, { adjDt:'20261118' }) && !w.preAdj({ trxDt:'20260916' }, { adjDt:'' }),
      '판정 — 전표 일자 < 최근 재고수정 날짜면 이전 · 같은 날·뒤·재고수정 없음은 이후');
    T(/재고수정 이전 전부/.test(rowBy(w,'PURCH:427').textContent) && !/재고수정 이전/.test(rowBy(w,'PURCH:1').textContent), '전표 줄 품목 칸 — 「재고수정 이전 전부」(09-16 전표) · 이후 전표엔 없음');
    const t427=lnTxt('PURCH:427');
    T((t427.match(/재고수정 이전/g)||[]).length===3 && (t427.match(/현재고 영향 없음/g)||[]).length===1 && (t427.match(/재고수정 이전 · 현재고 바뀜/g)||[]).length===2 && d.querySelectorAll('table.ln tr.pre').length===3, '품목 줄 — 3줄 모두 「재고수정 이전」 · 고정(🔒)된 1줄만 「현재고 영향 없음」 · 회색 줄', t427);
    T(!/재고수정 이전/.test(lnTxt('PURCH:1')), '재고수정 날짜보다 뒤 전표의 품목 줄엔 표가 없다');
    { const rw=rowBy(w,'PURCH:427'), lt=rw.nextElementSibling;
      T(rw.querySelector('.dt-v') && rw.querySelector('.dt-v').textContent==='2026-09-16' && lt.querySelector('.dt-a') && /재고수정 2026-11-18/.test(lt.querySelector('.dt-a').textContent) && /전표 09-16 ＜ 재고수정 11-18/.test(lt.querySelector('.dcmp').textContent),
        '날짜 구분 — 전표 일자(파랑 dt-v) · 재고수정 날짜(청록 dt-a, 「재고수정」 글) · 비교 칸 「전표 09-16 ＜ 재고수정 11-18」'); }
    { const L=Array.from(rowBy(w,'PURCH:427').nextElementSibling.querySelectorAll('table.ln tbody tr'));
      const lockRow=L.find(tr=>/9904013323/.test(tr.textContent)), openRow=L.find(tr=>/1000736038/.test(tr.textContent));
      T(!!lockRow && /🔒 적용 안 됨/.test(lockRow.textContent) && !lockRow.querySelector('.btn-warn') && !!openRow && /재고수정 이전 · 현재고 바뀜/.test(openRow.textContent) && !!openRow.querySelector('.btn-warn'),
        '고정(🔒)된 이전 줄 = 단추 대신 「🔒 적용 안 됨」 · 고정 전 이전 줄 = 「재고수정 이전 · 현재고 바뀜」 + [재고 미적용] 그대로');
      w.__alerts.length=0; lockRow.querySelector('.lockb').click();
      T(w.__alerts.some(m=>/할 수 없습니다/.test(m) && /9904013323/.test(m) && /2026-11-22/.test(m) && /2026-09-16/.test(m) && /재고수정을 다시/.test(m)) && w.__calls.filter(x=>/stockChkAct/.test(x.u)).length===0,
        '「🔒 적용 안 됨」 을 누르면 이유 안내만(서버에 처리 요청 없음)'); }
    T(w.aftAdj({ evDttm:'2026-11-22 18:48:00' }, { adjDt:'20261118', adjRegDttm:'2026-11-18 09:53:04' }) && !w.aftAdj({ evDttm:'2026-11-18 09:00:00' }, { adjDt:'20261118', adjRegDttm:'2026-11-18 09:53:04' }) && w.aftAdj({ evDttm:'2026-01-01 00:00:00' }, { adjDt:'' }),
      '「이후」 = 작업한 때 > 재고수정을 저장한 때 · 재고수정 없는 품목은 늘 이후');
    T(/재고수정 뒤 작업 3개/.test(rowBy(w,'PURCH:427').textContent) && (lnTxt('PURCH:427').match(/재고수정 뒤 작업/g)||[]).length===3 && !/재고수정 뒤 작업/.test(rowBy(w,'PURCH:1').textContent),
      '★재고수정(11-18) 뒤에 앞 날짜(09-16) 전표를 지운 것 — 빨간 「재고수정 뒤 작업」(전표 줄 3개 · 품목 줄마다) · 뒤 날짜 전표엔 없음');
    d.getElementById('fAft').checked=true; w.aftSave(); w.render();
    T(!!rowBy(w,'PURCH:427') && !!rowBy(w,'PURCH:1') && !!rowBy(w,'SALE:7') && w.localStorage.getItem('konetStockChkAft')==='1', '「최종 재고수정 이후만」 — 재고수정 뒤에 작업한 09-16 지운 전표가 «보인다»(첫 판은 숨겨 「체크하면 안나옴」) · 고른 것 기억');
    w.LMAP['PURCH:2'][1].adjRegDttm='2026-11-26 11:00:00'; w.render();
    const t2=lnTxt('PURCH:2');
    T(!!rowBy(w,'PURCH:2') && /P0011/.test(t2) && !/P0013/.test(t2) && /최종 재고수정 전에 한 작업 1개는 숨겼습니다/.test(t2), '작업한 뒤에 재고수정한 품목 줄만 숨김 + 「n개 숨겼습니다」', t2);
    w.LMAP['PURCH:1'][0].adjRegDttm='2026-11-27 00:00:00'; w.render();
    T(!rowBy(w,'PURCH:1'), '품목이 전부 «재고수정 전에 한 작업» 인 전표는 전표째 숨김');
    d.getElementById('fAft').checked=false; w.render();
    T(!!rowBy(w,'PURCH:1') && /P0013/.test(lnTxt('PURCH:2')), '끄면 다시 전부 보인다');
  }
  /* ── 품목별재고현황 · 월별 출고현황에서 바로 [재고 미적용]/[재고 적용] (2026-11-26 사용자 「여기에서 … 기능 추가해줘(여기서하면 직관적 일듯」) ── */
  { const LO=R('src/main/webapp/js/winct/logi-oh.js'), SOM=R('src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp'), ACT=R('src/main/webapp/asset/js/stock-chk-act.js');
    const { JSDOM }=require('jsdom');
    const mk=(admin, whole)=>{ const dom=new JSDOM('<!doctype html><html><head></head><body><div id="box"></div></body></html>', { runScripts:'outside-only' }); const w=dom.window;
      w.__posts=[]; w.__alerts=[]; w.__conf=[]; w.__after=0;
      w._alertBox=function(m){ w.__alerts.push(String(m)); }; w._toast=function(){}; w._confirmBox=function(o){ w.__conf.push(o.msg); o.onOk(); };
      w.__pres=[];
      w.fetch=function(u, o){ const b=JSON.parse(o.body);
        if(/stockChkPre\.do$/.test(u)){ w.__pres.push({ u, b }); if(w.__pre==='fail') return Promise.reject(new Error('x')); return Promise.resolve({ ok:true, json:()=>Promise.resolve(w.__pre || { result:'OK', total:1, list:[] }) }); }
        w.__posts.push({ u, b }); return Promise.resolve({ ok:true, json:()=>Promise.resolve(w.__resp || { result:'OK', done:1, skip:0, blocked:0, prods:[{ prodCd:'P1', prodNm:'품목', bef:68, aft:318 }] }) }); };
      w.stkChkCfg={ ctx:'/konet', admin:admin, whole:whole||[], after:function(){ w.__after++; } };
      w.eval(ACT); return w; };
    const tick=()=>new Promise(r=>setTimeout(r,10));
    { const w=mk(false); T(w.stkChkBtn({ act:'X', gb:'PURCH', no:'20261125-0008', cd:'P1', q:250 })==='', '관리자가 아니면 단추를 안 그린다'); }
    { const w=mk(true), d=w.document;
      d.getElementById('box').innerHTML=w.stkChkBtn({ act:'X', gb:'PURCH', no:'20261125-0008', cd:'P1', q:250, nm:'20261125-0008' });
      const b=d.querySelector('[data-chk-act]'); T(!!b && b.textContent==='재고 미적용' && b.getAttribute('data-no')==='20261125-0008', '관리자 — [재고 미적용] 단추');
      b.click(); await tick(); T(w.__pres.length===1 && w.__pres[0].b.act==='X' && w.__pres[0].b.items[0].refNo==='20261125-0008' && w.__pres[0].b.items[0].prodCd==='P1', '누르면 먼저 묻기(stockChkPre) — 같은 근거번호·품목코드로');
      const box=d.getElementById('stkChkAsk'); T(!!box && box.style.display==='flex' && /\+250/.test(d.getElementById('stkChkAskMsg').textContent) && /품목 P1/.test(d.getElementById('stkChkAskMsg').textContent), '누르면 사유 창 — 전표·품목·재고 영향 +250');
      d.getElementById('stkChkAskOk').click(); T(w.__posts.length===0 && /사유를 적어/.test(d.getElementById('stkChkAskErr').textContent), '사유가 없으면 안 보낸다');
      d.querySelector('#stkChkAskChips button').click(); d.getElementById('stkChkAskOk').click(); await tick();
      const p=w.__posts[0]; T(!!p && p.u==='/konet/prod/stockChkAct.do' && p.b.act==='X' && p.b.items[0].refGb==='PURCH' && p.b.items[0].refNo==='20261125-0008' && p.b.items[0].prodCd==='P1' && p.b.items[0].refSeq===undefined && /서류만/.test(p.b.memo), '사유 고르기 → 보냄 : 근거번호 + 품목코드(전표 키 없이) · act X', JSON.stringify(p));
      T(w.__alerts.some(m=>/68 → <b>318<\/b>/.test(m)) && w.__after===1, '처리 뒤 「현재고 68 → 318」 알림 + 화면 다시 읽기(after)'); }
    { const w=mk(true, ['PURCH:427']), d=w.document;
      T(w.stkChkWhole('PURCH', 427) && w.stkChkWhole('PURCH', '427') && !w.stkChkWhole('SALE', 427) && !w.stkChkWhole('PURCH', ''), '전표 전체 미적용 목록(whole) 판정');
      d.getElementById('box').innerHTML=w.stkChkBtn({ act:'U', gb:'PURCH', seq:427, cd:'', del:1, q:250, nm:'20260916-0002' });
      d.querySelector('[data-chk-act]').click(); await tick(); await tick();
      const p=w.__posts[0]; T(w.__conf.length===1 && /품목 전부/.test(w.__conf[0]) && /재고에 적용합니다/.test(w.__conf[0]) && p && p.b.act==='U' && p.b.items[0].refSeq===427 && p.b.items[0].prodCd==='', '지운 전표 [재고 적용] — 묻고 나서 전표 키로 · 전표 전체(품목 비움)', JSON.stringify(p)); }
    { const w=mk(true); w.__resp={ result:'OK', done:0, skip:1, blocked:0, prods:[] }; const d=w.document;
      d.getElementById('box').innerHTML=w.stkChkBtn({ act:'U', gb:'SALE', no:'20261120-0003', cd:'P1', q:-5 }); d.querySelector('[data-chk-act]').click(); await tick(); await tick();
      T(w.__alerts.some(m=>/찾지 못했습니다/.test(m)) && w.__after===0, '처리할 것이 없으면 안내만(다시 읽지 않음)'); }
    /* 처리 전 묻기 — 고정된 품목의 앞 날짜 전표 */
    { const w=mk(true), d=w.document; w.__pre={ result:'OK', total:1, list:[{ prodCd:'P1', prodNm:'덮밥용기', trxDt:'20260916', fixDt:'20261118' }] };
      d.getElementById('box').innerHTML=w.stkChkBtn({ act:'X', gb:'PURCH', no:'20260916-0002#427', cd:'P1', del:1, q:250 }); d.querySelector('[data-chk-act]').click(); await tick();
      const box=d.getElementById('stkChkAsk');
      T(w.__posts.length===0 && w.__conf.length===0 && !(box && box.style.display==='flex') && w.__alerts.some(m=>/현재고에 영향이 없어 처리하지 않았습니다/.test(m) && /2026-09-16/.test(m) && /재고수정 2026-11-18/.test(m) && /재고수정을 다시/.test(m)),
        '전부 해당(고정 품목의 앞 날짜 전표) — 안내만 · 사유 창도 처리도 없음(진행 단추 없음)'); }
    { const w=mk(true), d=w.document; w.__pre={ result:'OK', total:3, list:[{ prodCd:'P1', prodNm:'a', trxDt:'20260916', fixDt:'20261118' }] };
      d.getElementById('box').innerHTML=w.stkChkBtn({ act:'U', gb:'PURCH', seq:427, cd:'', del:1, nm:'20260916-0002' }); d.querySelector('[data-chk-act]').click(); await tick(); await tick();
      T(w.__conf.length===2 && /3개 중 1개는 현재고에 영향이 없습니다/.test(w.__conf[0]) && /나머지 <b>2개<\/b>/.test(w.__conf[0]) && w.__posts.length===1, '전표 전체에 일부만 해당 — 「n개 중 m개 영향 없음」 묻고 진행하면 처리'); }
    { const w=mk(true), d=w.document; w.__pre='fail';
      d.getElementById('box').innerHTML=w.stkChkBtn({ act:'U', gb:'SALE', no:'20261120-0003', cd:'P1', q:-5 }); d.querySelector('[data-chk-act]').click(); await tick(); await tick();
      T(w.__posts.length===1, '묻기를 못 하면(옛 서버·통신 실패) 종전대로 진행'); }
    /* 품목별재고현황 — 수불 줄 · 맨 위 줄의 단추 */
    const pick=(src,name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let dd=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') dd++; else if(src[k]==='}'){ if(--dd===0) return src.slice(i,k+1); } } };
    { const calls=[]; const F=new Function('window', ['stkChkB','stkChkW','stkLedAct'].map(n=>pick(LO,n)).join('\n')+'\nreturn stkLedAct;')({ stkChkBtn:function(o){ calls.push(o); return '[B]'; }, stkChkWhole:function(g,s){ return g==='SALE' && String(s)==='77'; } });
      F({ refGb:'PURCH', refNo:'20261125-0008', prodCd:'P1', ioGb:'I', qty:250 }); F({ refGb:'SALE', refNo:'20261120-0003', prodCd:'P1', ioGb:'O', qty:5 });
      F({ refGb:'PURCHK', refNo:'20260916-0002#427', prodCd:'P1', ioGb:'I', qty:250 }); F({ refGb:'SALEK', refNo:'20261110-0001#77', prodCd:'P1', ioGb:'O', qty:3 });
      T(F({ refGb:'SHIPOUT', refNo:'x', prodCd:'P1' })==='' && F({ refGb:'ADJ', refNo:'x', prodCd:'P1' })==='' && F({ refGb:'SALES', refNo:'x', prodCd:'P1' })==='', '출고현황·조정·정산서 줄에는 단추 없음');
      const [a,b,c2,d2]=calls;
      T(a.act==='X' && a.gb==='PURCH' && a.no==='20261125-0008' && a.cd==='P1' && a.q===250, '매입전표 줄 → [재고 미적용](품목만 · 재고 +250)');
      T(b.act==='X' && b.gb==='SALE' && b.q===-5, '판매전표 줄 → [재고 미적용](재고 −5)');
      T(c2.act==='U' && c2.gb==='PURCH' && c2.no==='20260916-0002#427' && c2.cd==='P1' && c2.del && c2.nm==='20260916-0002', '되살려 둔 줄(PURCHK) → [재고 적용] · 그 품목만');
      T(d2.act==='U' && d2.gb==='SALE' && d2.cd==='', '전표 전체를 미적용한 전표(whole)면 [재고 적용] 도 전표 전체로'); }
    T(LO.indexOf("stkChkB({ act:(keep ? 'U' : 'X'), gb:'PURCH', seq:x.purchSeq")>0 && LO.indexOf("stkChkB({ act:(keep ? 'U' : 'X'), gb:'SALE', seq:x.saleSeq")>0 && LO.indexOf("stkChkB({ act:'U', gb:String(x.refGb||''), seq:(x.refSeq==null ? '' : x.refSeq)")>0,
      '품목별재고현황 맨 위 — 삭제된 입고·출고 줄 [재고 미적용]↔[재고 적용] · 재고 미적용 줄 [재고 적용]');
    T(LO.indexOf("c.cfChg=stkChkCfgSet(d);")>0 && LO.indexOf("sc.src=cf.ctx+'/asset/js/stock-chk-act.js?v=20261126b'")>0 && LO.indexOf("if(typeof stkStatusLoad==='function') stkStatusLoad();")>0 && LO.indexOf("stkLedgerDetail(_stkSelSeq, null,")>0,
      '품목별재고현황 — 관리자 여부·whole 은 같은 응답에서 · 공용 스크립트를 한 번 싣는다 · 처리 뒤 목록·수불 내역 다시');
    /* 월별 출고현황 */
    { const calls=[]; const G=new Function('window','_somDel', 'function somKeepRow(r){ var g=\'\'+((r && r.refGb)||\'\'); return g===\'PURCHK\' || g===\'SALEK\'; }\n'+['somChkB','somChkW','somInAct','somOutAct'].map(n=>pick(SOM,n)).join('\n')+'\nreturn { i:somInAct, o:somOutAct };')(
        { stkChkBtn:function(o){ calls.push(o); return '[B]'; }, stkChkWhole:function(){ return false; } }, { P1:{ sales:[ { saleSeq:77, saleDt:'2026-11-10', saleNo:'0001', keepYn:'Y' } ] } });
      G.i({ refGb:'PURCH', refNo:'20261125-0008', ioGb:'I', qty:250 }, 'P1'); G.i({ refGb:'SALE', refNo:'20261120-0003', ioGb:'R', qty:2 }, 'P1'); G.i({ refGb:'PURCHK', refNo:'20260916-0002#427', ioGb:'I', qty:250 }, 'P1');
      T(G.i({ refGb:'ADJ', refNo:'x', ioGb:'A', qty:1 }, 'P1')==='', '입고내역 조정 줄에는 단추 없음');
      G.o({ src:'판매전표', ordNo:'20261120-0003', qty:5 }, 'P1'); G.o({ src:'판매전표(삭제 · 재고 미적용)', ordNo:'20261110-0001', qty:3 }, 'P1');
      T(G.o({ src:'정산서', ordNo:'A1', qty:1 }, 'P1')==='' && G.o({ src:'발주현황표', ordNo:'A1', qty:1 }, 'P1')==='' && G.o({ src:'판매전표(삭제 · 재고 미적용)', ordNo:'20991231-0009', qty:1 }, 'P1')==='', '출고내역 — 정산서·발주현황표 줄, 짝을 못 찾은 지운 판매전표 줄에는 단추 없음');
      const [i1,i2,i3,o1,o2]=calls;
      T(i1.act==='X' && i1.gb==='PURCH' && i1.no==='20261125-0008' && i1.q===250 && i2.act==='X' && i2.gb==='SALE' && i2.q===2, '입고내역 — 매입전표 줄 · 판매 반품 줄 → [재고 미적용]');
      T(i3.act==='U' && i3.del && i3.no==='20260916-0002#427', '입고내역 — 되살려 둔 줄 → [재고 적용]');
      T(o1.act==='X' && o1.gb==='SALE' && o1.no==='20261120-0003' && o1.q===-5, '출고내역 — 판매전표 줄 → [재고 미적용](재고 −5)');
      T(o2.act==='U' && o2.seq===77 && o2.del && o2.cd==='P1', '출고내역 — 지운 판매전표(재고 미적용) 줄 → [재고 적용] · 전표 키는 받아 둔 삭제 목록에서'); }
    T(SOM.indexOf('/asset/js/stock-chk-act.js?v=20261126b')>0 && SOM.indexOf('c.cfChg=somChkCfgSet(d);')>0 && SOM.indexOf("cf.after=function(){ _somDel={}; _somRun={}; var s=DTL_LAST; try{ somLoad(); }catch(e){} if(s){ try{ somDetail(s); }catch(e){} } };")>0
      && SOM.indexOf("somChkB({ act:(keep ? 'U' : 'X'), gb:'PURCH', seq:x.purchSeq")>0 && SOM.indexOf("somChkB({ act:(keep ? 'U' : 'X'), gb:'SALE', seq:x.saleSeq")>0 && (SOM.match(/'\+onB\+'/g)||[]).length===1 && SOM.indexOf("+onB+'</td></tr>';")>0
      && SOM.indexOf("somOutAct(r, String(sel.it.cd).trim())")>0 && SOM.indexOf("somInAct(r, String(sel.it.cd).trim())")>0, '월별 출고현황 — 공용 스크립트 · 맨 위 줄 단추 · 내역 줄 단추 · 처리 뒤 표·내역 다시 조회');
    /* 서버 */
    T(J.indexOf('Integer f = mapper.selectStockChkSeqByNo(q);')>0 && J.indexOf("int hx = no.indexOf('#');")>0 && J.indexOf('if (prodSeq == 0 && !pcd.isEmpty() && !"C".equals(act)) {')>0 && J.indexOf('if (found <= 0) return null;')>0
      && J.indexOf('java.util.Map<String,Object> p = chkItemOf(compCd, it, act);')>0 && (J.match(/chkItemOf\(compCd, it, act\)/g)||[]).length===2,
      '서비스 — 전표 키 대신 근거번호(「일자-번호」 → 살아 있는 전표 · 「#키」 → 그 키) · 품목번호 대신 품목코드(그 전표의 품목에서 찾음)');
    const sn=blk('select','selectStockChkSeqByNo'), wh=blk('select','selectStockChkWhole'), an=blk('select','selectStockChkAnchor');
    T(an.indexOf('a.rn = 1 AND a.FRZ_QTY IS NOT NULL')>0 && an.indexOf('ORDER BY l.LEDGER_SEQ DESC')>0 && J.indexOf('td.compareTo(fd.substring(0, 8)) < 0')>0 && C.indexOf('/prod/stockChkPre.do')>0,
      '묻기 서버 — 고정 = 품목·창고마다 가장 나중 조정에 고정값(FRZ_QTY) · 전표 일자 < 고정 일자만(같은 날은 반영)');
    { const SC=R('src/main/webapp/WEB-INF/jsp/main/prod/stockChk.jsp');
      T(SC.indexOf('/asset/js/stock-chk-act.js?v=20261126b')>0 && SC.indexOf("preChk(itemOf(k, ps), 'X', function(){ rsOpen0(k, ps); });")>0 && SC.indexOf("if(toStock){ preChk(itemOf(k, ps), 'U', function(){ act0(k, ps, r, go); }); return; }")>0,
        '재고 변동 확인 화면도 같은 묻기 — 재고 미적용(사유 창 전) · 재고 적용(확인창 전) · 확인(C)은 묻지 않음'); }
    T(sn.indexOf("CASE WHEN COUNT(*) = 1 THEN MAX(m.PURCH_SEQ) END")>0 && sn.indexOf("m.ACTION_YN = 'Y'")>0 && wh.indexOf("c.STATE = 'X' AND c.PROD_SEQ = 0")>0 && blk('select','selectProdChkOff').indexOf('ISNULL(pm.PURCH_SEQ, sm.SALE_SEQ) AS refSeq')>0,
      '매퍼 — 근거번호 → 전표 키(하나일 때만) · 전표 전체 미적용 목록 · 재고 미적용 줄에 전표 키');
    T(C.indexOf('res.put("admin", empAdmin(session) ? "Y" : "N");\n\t\t\t\ttry { res.put("whole", svc.selectStockChkWhole(p)); }')>0 || (C.indexOf('res.put("whole", svc.selectStockChkWhole(p));')>0), '삭제 줄 응답에 관리자 여부 · whole');
  }
  console.log((bad?'✗':'✓')+' sim_stockChk : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})().catch(e=>{ console.log('✗ 예외 '+(e && e.stack || e)); process.exit(1); });
