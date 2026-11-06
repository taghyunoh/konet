/* 판매 등록 [📥 엑셀 업로드](구전산 매출 → 판매전표) 시뮬 — salesReg.jsp 의 xu* 블록을 그대로 꺼내 jsdom 에서 돌린다 (2026-11-06)
   쓰는 법 : node docs/tools/sim/sim_salesXlsUpload.js [양식.xlsx]   (기본 D:/코네트/판매내역_판매등록양식.xlsx)
   jsdom 은 저장소에 없다 — %TEMP%/konet_chk/node_modules (npm i jsdom@22) 또는 NODE_PATH 로. */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name), 'C:/Users/user/git/winn/wnn_medcost/docs/tools/sim/node_modules/'+name];
  for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const XLSX = require(path.join(ROOT, 'src/main/webapp/assets/vendor/sheetjs/xlsx.full.min.js'));
const XL = process.argv[2] || 'D:/코네트/판매내역_판매등록양식.xlsx';
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/salesReg.jsp'), 'utf8').replace(/\r\n/g, '\n');

function cut(a, b){ const i=src.indexOf(a); if(i<0) throw new Error('없음: '+a); const j=src.indexOf(b, i+a.length); if(j<0) throw new Error('없음: '+b); return src.slice(i, j); }
function fn(name){ const i=src.indexOf('\nfunction '+name+'('); if(i<0) throw new Error('함수 없음 '+name); let d=0, j=src.indexOf('{', i); for(let k=j;k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ d--; if(!d) return src.slice(i+1, k+1); } } }
const block = cut('/* ══════════════════════════════════════════════════════════════════════════\n   📥 엑셀 업로드 — 구전산 매출 엑셀', '/* ══════════════════════════════════════════════════════════════════════════\n   🖨 거래명세표 출력');
const real = [fn('ktCalcRow'), fn('emptyRow'), fn('saVenPick'), fn('saProdPick'), fn('saExtPick'), fn('fmtDt')].join('\n');

let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }

/* 양식 파일을 먼저 읽어 기대값(전표별 요약)을 만든다 */
const wbBuf = fs.readFileSync(XL);
const wb0 = XLSX.read(wbBuf, { type:'buffer', cellDates:true });
const data = XLSX.utils.sheet_to_json(wb0.Sheets['판매등록 양식'], { header:1, raw:true, defval:null }).slice(1).filter(r => r[5]);
const summ = XLSX.utils.sheet_to_json(wb0.Sheets['전표별 요약'], { header:1, raw:true, defval:null }).slice(1).filter(r => r[0] !== '합계' && r[0]);
const codes = [...new Set(data.map(r => String(r[5])))];
const TOT = XLSX.utils.sheet_to_json(wb0.Sheets['전표별 요약'], { header:1, raw:true, defval:null }).filter(r => r[0] === '합계')[0];

/* 가짜 마스터 — 엑셀 코드 전부를 마스터에 두되 ①9904013290 은 뺀다(미연결 시험) ②1010009149 는 매칭코드로만(서브 → 주코드 9904019999)
   ③9904013184 는 입수 400(「입수 ≠ 엑셀 → EA」 시험) */
const MISS = '9904013290', SUB = '1010009149', MAIN_OF_SUB = '9904019999', PACK400 = '9904013184';
const prods = codes.filter(c => c !== MISS && c !== SUB).map((c, i) => ({ prodSeq: i+1, prodCd: c, prodNm: '상품 '+c, spec: 'S'+c.slice(-3), packQty: c===PACK400 ? 400 : 1, taxGb: '과세', salePrice: 100 }));
prods.push({ prodSeq: 900, prodCd: MAIN_OF_SUB, prodNm: '주코드 상품', spec: '', packQty: 1, taxGb: '과세', salePrice: 50 });
const exts = [{ extSeq: 77, extItemCd: SUB, extItemNm: '거래처 표기 샌드위치박스', prodCd: MAIN_OF_SUB, prodSeq: 900, addYn: 'N' }];
const VEN_ALL = [ { vendorCd: '001554', vendorNm: '샐러드 플러스', vatGb: '포함', mgrCd: 'M1', mgrNm: '담당A' },
                  { vendorCd: '001532', vendorNm: '우리푸드', vatGb: '별도', mgrCd: 'M2', mgrNm: '담당B' },
                  { vendorCd: '000001', vendorNm: '다른 거래처', vatGb: '별도' } ];

function make(opts){
  opts = opts || {};
  const dom = new JSDOM(`<input id="saVenNm" value=""><input id="saMgrNm"><input id="saVenQ"><div id="saVenPop"></div><div id="saProdPop"></div><input id="saProdQ"><select id="saPayGb"><option value="외상" selected>외상</option></select>
    <div id="saXuPop"><div class="hd" id="xuHd"></div><input type="file" id="xuFile"><span id="xuFileNm"></span><input type="checkbox" id="xuAmtX" checked><span id="xuCnt"></span>
    <table><tbody id="xuBody"></tbody></table><input type="checkbox" id="xuChkAll"><span id="xuSum"></span><button id="xuSaveBtn" disabled>💾 선택 전표 저장</button><button id="xuFoldAllBtn" style="display:none">⊟ 전체 접기</button></div>`, { runScripts: 'dangerously', pretendToBeVisual: true });
  const w = dom.window;
  w.__X = XLSX;
  w.eval(`
    var VAT_DEF='별도', PRICE_DEC=true, CTX='';
    var _vendors=${JSON.stringify(opts.vendors || VEN_ALL)}, _prods=${JSON.stringify(prods)}, _extItems=${JSON.stringify(exts)};
    var _kt={ rows:[], groups:[], venTarget:null, venRowTarget:null, prodTarget:null, seq:0 }, _prodTargetRow=-1, _ppPick=[], _rows=[], _cur=null;
    var __log={ alerts:[], confirms:[], posts:[], toasts:[], loads:0, masters:0, nextNo:{} }, __failDt=${JSON.stringify(opts.failDt||'')};
    function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
    function fmt(v){ return Math.round(n(v)).toLocaleString(); }
    function fmtP(v){ var x=Math.round(n(v)*100)/100; return x.toLocaleString(undefined,{maximumFractionDigits:2}); }
    function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
    function saLoadMasters(){ __log.masters++; } function saLoad(){ __log.loads++; }
    function saVenOpen(){ document.getElementById('saVenPop').classList.add('on'); } function saVenClose(){ document.getElementById('saVenPop').classList.remove('on'); }
    function saVenRender(){} function saProdRender(){} function saProdClose(){ document.getElementById('saProdPop').classList.remove('on'); }
    function saVenVat(){} function saVenBal(){} function saXrefLoad(){} function saNmFor(cd,nm){ return nm; } function saCtApply(){ return false; } function saCalcRow(){} function saEnsureTail(){} function saRender(){}
    function ktRowById(){ return null; } function ktSetProd(){} function ktRender(){}
    function saWhCd(){ return 'WH1'; } function saWhNmTxt(){ return '물류창고'; }
    function saClosedAsk(){ return Promise.resolve(true); }
    function swOk(m){ __log.alerts.push('OK:'+m); } function swErr(m){ __log.alerts.push('ERR:'+m); } function swAlert(m){ __log.alerts.push('INFO:'+m); }
    function swConfirm(m,ti,okt){ __log.confirms.push(okt+'|'+m); return Promise.resolve(true); }
    window._toast=function(m,ty){ __log.toasts.push(m); };
    function ktLoadXlsx(cb){ cb(window.__X); }
    function post(url, body, isJson){
      __log.posts.push({ url:url, body:body });
      if(url.indexOf('salesTrxList')>=0) return Promise.resolve({ json:function(){ return Promise.resolve({ data:[ { saleDt:'20260108', custCd:'001554', saleNo:'0007' } ] }); } });
      if(url.indexOf('salesTrxNextNo')>=0){ var dt=decodeURIComponent(body.split('=')[1]); __log.nextNo[dt]=(__log.nextNo[dt]||0)+1; var no=('000'+__log.nextNo[dt]).slice(-4); return Promise.resolve({ json:function(){ return Promise.resolve({ data:no }); } }); }
      if(url.indexOf('salesTrxSave')>=0){ var okk = !(__failDt && body.saleDt===__failDt); return Promise.resolve({ ok:okk, status: okk?200:500, text:function(){ return Promise.resolve(okk?'OK':'서버 오류(시험)'); } }); }
      return Promise.resolve({ ok:true, json:function(){ return Promise.resolve({}); }, text:function(){ return Promise.resolve(''); } });
    }
  `);
  w.eval(real);
  w.eval(block);
  return w;
}
const tick = (ms) => new Promise(r => setTimeout(r, ms||20));

(async () => {
  /* ── 1. 파일 올리기(FileReader 경로) → 파싱 ── */
  let w = make();
  w.xuSumPaint(); t('파일 올리기 전 = 저장 단추 잠김 · [전체 접기] 숨김', w.document.getElementById('xuSaveBtn').disabled && w.document.getElementById('xuFoldAllBtn').style.display==='none');
  const inp = w.document.getElementById('xuFile');
  const file = new w.File([wbBuf], '판매내역_판매등록양식.xlsx');
  Object.defineProperty(inp, 'files', { value: [file] });
  w.xuFileChg(inp);
  for (let i=0; i<50 && !w._xu.rows.length; i++) await tick(40);
  t('FileReader 경로로 읽힘 — 자료 줄 수 = 시트 줄 수', w._xu.rows.length === data.length, w._xu.rows.length+' vs '+data.length);
  t('파일 이름 기억', w._xu.file === '판매내역_판매등록양식.xlsx');
  t('파일 안내 글자에 시트 이름·줄 수', /판매등록 양식.*373줄|시트 \d+줄/.test(w.document.getElementById('xuFileNm').textContent), w.document.getElementById('xuFileNm').textContent);
  t('마스터 다시 읽기는 열 때(xuOpen) — 여기선 0', w.__log.masters === 0);
  await tick(30);  // 중복 조회(salesTrxList) 응답 반영

  const G = w._xu.groups;
  t('전표 묶음 = 전표별 요약 줄 수', G.length === summ.length, G.length+' vs '+summ.length);
  t('묶음은 엑셀 줄 차례(첫 묶음 2026-01-08 샐러드 플러스)', G[0].dt === '2026-01-08' && G[0].venNm === '샐러드 플러스');
  t('거래처 전부 코드로 연결', G.every(g => g.venCd), G.filter(g=>!g.venCd).length+'장 미연결');
  t('부가세 구분 = 엑셀 부가세구분 칸(샐러드 포함 · 우리푸드 별도)', G.filter(g=>g.venCd==='001554').every(g=>g.vatGb==='포함') && G.filter(g=>g.venCd==='001532').every(g=>g.vatGb==='별도'));
  /* 금액 = 엑셀 그대로 → 전표별 요약과 1원도 안 어긋남 */
  let mism = [];
  summ.forEach(s => { const g = G.find(x => x.dt === s[0] && x.venNm === s[1]); if(!g){ mism.push('없음 '+s[0]+' '+s[1]); return; }
    const u = w.xuGroupSum(g); if (u.sup!==s[3] || u.vat!==s[4] || u.tot!==s[5]) mism.push(s[0]+' '+s[1]+' '+[u.sup,u.vat,u.tot].join('/')+' ≠ '+[s[3],s[4],s[5]].join('/')); });
  t('묶음 공급가·부가세·판매금액 = 「전표별 요약」 전부 일치', mism.length === 0, mism.slice(0,3).join(' | '));
  const all = G.reduce((a,g)=>{ const u=w.xuGroupSum(g); a.sup+=u.sup; a.vat+=u.vat; a.tot+=u.tot; a.n+=g.rows.length; return a; }, {sup:0,vat:0,tot:0,n:0});
  t('총합 = 요약 합계 줄 (373줄 · 194,397,145 / 19,439,681 / 213,836,826)', all.n===TOT[2] && all.sup===TOT[3] && all.vat===TOT[4] && all.tot===TOT[5], JSON.stringify(all));

  /* 상품 매칭 상태 */
  const R = w._xu.rows;
  const miss = R.filter(r => !r.prodCd);
  t('마스터에 없는 코드(9904013290) 줄만 미연결', miss.length && miss.every(r => r.cd === MISS), miss.length);
  const sub = R.filter(r => r.cd === SUB);
  t('매칭코드 줄 → 주코드로 「매칭」', sub.length && sub.every(r => r.prodCd === MAIN_OF_SUB && r.st === '매칭' && r.extCd === SUB), sub.length);
  t('마스터 코드 줄 = 「코드」 · 상품명·규격은 마스터 것', R.filter(r=>r.st==='코드').length === R.length - miss.length - sub.length && R.find(r=>r.st==='코드').prodNm.indexOf('상품 ')===0);
  const p4 = R.filter(r => r.cd === PACK400 && r.box > 0);
  t('입수 400 품목 BOX 48 → 엑셀 합계와 달라 EA 48 로(note)', p4.length && p4.every(r => r.boxQty===0 && r.eaQty===r.qtyCap && r.qty===r.qtyCap && /EA/.test(r.note)), p4.length ? JSON.stringify([p4[0].boxQty,p4[0].eaQty,p4[0].note]) : '줄 없음');
  const fix = R.find(r => r.dt === '2026-02-23' && r.cd === '9904012900');
  t('2/23 우리푸드 9904012900 — 엑셀 공급가 91,877 vs 셈 91,875 → 금액 보정 +2', fix && fix.o.supplyAmt===91877 && fix.fix===2, fix && JSON.stringify([fix.o.supplyAmt, fix.fix]));
  t('BOX·EA·합계 = 엑셀 그대로(첫 줄 EA 1,200 · 단가 194.66)', R[0].boxQty===0 && R[0].eaQty===1200 && R[0].qty===1200 && R[0].price===194.66 && R[0].o.unitPrice===194.66);
  t('줄 비고 = 엑셀 비고(「4박스」)', R[0].o.remark === '4박스');
  t('묶음 bad = 미연결 줄이 든 묶음만', G.filter(g=>g.bad).length === new Set(miss.map(r=>r.dt+'|'+r.venCd)).size);

  /* 중복 전표 표시 */
  const d0 = G.find(g => g.dt==='2026-01-08' && g.venCd==='001554');
  t('이미 있는 전표(1/8 샐러드) = dup 1장(0007) · 체크 꺼짐', d0 && d0.dup.length===1 && d0.dup[0]==='0007' && d0.chk===false, d0 && JSON.stringify([d0.dup, d0.chk]));
  t('나머지 묶음은 체크 켜짐', G.filter(g=>g!==d0).every(g=>g.chk));

  /* 그리기 */
  const body = w.document.getElementById('xuBody');
  t('묶음 머리줄 수 = 묶음 수', body.querySelectorAll('tr.xg').length === G.length);
  t('★올린 내용은 전부 펼쳐 보인다(373줄 전부 표에) — 2026-11-06 「업로드 내용 보여주고 저장기능으로」', G.every(g => g.open) && body.querySelectorAll('tr.xr').length === data.length, body.querySelectorAll('tr.xr').length);
  t('올린 직후 토스트 「아직 저장되지 않았습니다」 · 저장 요청 0', /아직 저장되지 않았습니다/.test(w.__log.toasts[0]||'') && w.__log.posts.filter(p=>p.url.indexOf('salesTrxSave')>=0).length===0, w.__log.toasts[0]);
  t('저장 단추 = 파일 올린 뒤 풀림 · [⊟ 전체 접기] 보임 · 머리 「확인 대기 47장 — 아직 저장 안 됨」', !w.document.getElementById('xuSaveBtn').disabled && w.document.getElementById('xuFoldAllBtn').style.display==='' && /확인 대기 47장/.test(w.document.getElementById('xuCnt').textContent), w.document.getElementById('xuCnt').textContent);
  w.xuFoldAll(); t('[⊟ 전체 접기] → 전부 접힘 · 단추 「⊞ 전체 펼치기」', G.every(g=>!g.open) && body.querySelectorAll('tr.xr').length===0 && /전체 펼치기/.test(w.document.getElementById('xuFoldAllBtn').textContent));
  w.xuFoldAll(); t('다시 누르면 전부 펼침', G.every(g=>g.open));
  t('bad 묶음 class bad · 이미 있는 전표 배지(1/8 샐러드는 미연결 줄도 있어 bad 가 이김)', body.querySelector('tr.xg.bad') && /이미 전표 1장 \(0007\)/.test(body.querySelectorAll('tr.xg')[G.indexOf(d0)].textContent));
  const dKey = d0.key, D0 = () => w._xu.groups.find(g => g.key === dKey);   // ★다시 묶으면(xuRegroup) 묶음 객체가 새로 생긴다 — 키로 다시 찾는다
  t('미연결 줄 빨강(tr.xr.bad) + 「미연결」 배지', body.querySelectorAll('tr.xr.bad').length === miss.length && /미연결/.test(body.querySelector('tr.xr.bad td:last-child').textContent));
  t('요약줄에 전표·줄·미연결·이미 있는 전표', /전표 <b>47장<\/b>/.test(w.document.getElementById('xuSum').innerHTML) && /상품 미연결/.test(w.document.getElementById('xuSum').textContent) && /이미 있는 전표 1장/.test(w.document.getElementById('xuSum').textContent), w.document.getElementById('xuSum').textContent);
  const wasOpen = G[0].open; w.xuFold(0); t('접기/펼치기 토글', G[0].open === !wasOpen); w.xuFold(0); t('토글 되돌림', G[0].open === wasOpen);
  w.xuChkAll(false); t('전체 해제', G.every(g=>!g.chk)); w.xuChkAll(true); t('전체 선택(dup 포함)', G.every(g=>g.chk));
  w.xuChk(G.indexOf(d0), false);

  /* 상품 고르기 훅 — 원코드 */
  const m0 = miss[0];
  w.xuProdOpen(m0.id);
  t('상품 칸 클릭 → 상품 팝업 열림 · 검색어 = 엑셀 코드 · _xu.prodTarget', w.document.getElementById('saProdPop').classList.contains('on') && w.document.getElementById('saProdQ').value===MISS && w._xu.prodTarget===m0.id);
  w.saProdPick(MAIN_OF_SUB);
  t('saProdPick 훅 → 같은 코드 줄 전부 「선택」 · 팝업 닫힘 · 명세(_rows) 무변경', R.filter(r=>r.cd===MISS).every(r=>r.prodCd===MAIN_OF_SUB && r.st==='선택') && !w.document.getElementById('saProdPop').classList.contains('on') && w._rows.length===0 && w._xu.prodTarget===null);
  t('이제 미연결 0 · bad 묶음 0', R.every(r=>r.prodCd) && w._xu.groups.every(g=>!g.bad));
  t('토스트 「n줄에 적용」', /줄에 적용/.test(w.__log.toasts[w.__log.toasts.length-1]));
  /* 상품 고르기 훅 — 🔖 매칭 */
  const s0 = R.find(r => r.cd === '9904013286');
  w.xuProdOpen(s0.id); w.saExtPick(77);
  t('saExtPick 훅 → 그 코드 줄이 매칭(주코드 9904019999 · extCd)', R.filter(r=>r.cd==='9904013286').every(r=>r.prodCd===MAIN_OF_SUB && r.st==='매칭' && r.extCd===SUB));

  /* 저장 — 금액 그대로. 2/5 샐러드 전표는 서버가 실패하게 */
  w.__failDt = '2026-02-05'; const nFail = w._xu.groups.filter(g => g.dt === '2026-02-05').length;   // 그날 전표 2장(샐러드·우리푸드) 둘 다 실패하게
  await w.xuSave(); await tick(60);
  const saves = w.__log.posts.filter(p => p.url.indexOf('salesTrxSave')>=0);
  t('저장 요청 = 체크한 묶음 수(이미 있는 전표 1장 제외)', saves.length === G.length - 1, saves.length);
  t('확인창 — 마감 묻기 뒤 「저장」 한 번(중복 체크 없으니 추가 저장 확인 없음)', w.__log.confirms.length===1 && /^저장\|/.test(w.__log.confirms[0]), w.__log.confirms.map(c=>c.split('|')[0]).join(','));
  const dto0 = saves[0].body, g0 = w._xu.groups.find(g=>g.dt===dto0.saleDt && g.venCd===dto0.custCd);
  t('payload 꼴 = 판매등록 저장과 같다(saleSeq null · saleDt/dlvDt · custCd/Nm · mgr · wh · 합계 · payGb 외상 · taxGb 과세 · items)', dto0.saleSeq===null && dto0.dlvDt===dto0.saleDt && dto0.custNm===g0.venNm && dto0.mgrNm && dto0.whCd==='WH1' && dto0.payGb==='외상' && dto0.taxGb==='과세' && Array.isArray(dto0.items) && dto0.items.length===g0.rows.length, JSON.stringify(Object.keys(dto0)));
  const gs0 = w.xuGroupSum(g0);
  t('머리 합계 = 줄 합(공급가·부가세·판매금액·수량)', dto0.supplyAmt===gs0.sup && dto0.vatAmt===gs0.vat && dto0.totAmt===gs0.tot && dto0.totQty===gs0.qty);
  t('전표 메모 = [엑셀 업로드 파일명]', dto0.remark === '[엑셀 업로드 판매내역_판매등록양식.xlsx]', dto0.remark);
  t('견적 연결 없음(quoteSeq null)', dto0.quoteSeq===null && dto0.quoteDocNo==='');
  const it0 = dto0.items[0];
  t('줄 payload = emptyRow 꼴 + 엑셀 값(prodCd·unitPrice·boxQty/eaQty·qty·공급가·부가세·판매금액·비고·trxGb 판매)', it0.prodCd && it0.unitPrice>0 && 'boxQty' in it0 && 'eaQty' in it0 && it0.qty>0 && it0.supplyAmt>0 && it0.totAmt===it0.supplyAmt+it0.vatAmt && it0.trxGb==='판매' && 'stockCutQty' in it0, JSON.stringify(it0));
  t('매칭코드 줄은 extCd·extNm 동봉', saves.some(s=>s.body.items.some(i=>i.extCd===SUB)));
  t('전표번호 = 날짜마다 salesTrxNextNo(같은 날 두 거래처면 0001·0002)', (function(){ const same = saves.filter(s=>s.body.saleDt==='2026-09-04'); return same.length===2 && same.map(s=>s.body.saleNo).sort().join()==='0001,0002'; })(), saves.filter(s=>s.body.saleDt==='2026-09-04').map(s=>s.body.saleNo).join());
  const failGs = w._xu.groups.filter(g=>g.dt==='2026-02-05');
  t('실패한 전표(2장) = 「실패 · 서버 오류(시험)」 · 체크 그대로 · 다음 장은 계속 저장', nFail===2 && failGs.every(g=>/^실패 · 서버 오류/.test(g.done) && g.chk===true) && w._xu.groups.filter(g=>/^저장됨/.test(g.done)).length === saves.length-nFail, failGs.map(g=>g.done).join());
  t('성공 묶음 = 「저장됨 · 전표 n」 + 체크 꺼짐', w._xu.groups.filter(g=>/^저장됨/.test(g.done)).every(g=>!g.chk));
  t('끝나면 목록 다시 읽기(saLoad) · 결과창(성공 44장 · 실패 2장 사유)', w.__log.loads===1 && /^ERR:<b>전표 44장/.test(w.__log.alerts[w.__log.alerts.length-1]) && /실패 2장/.test(w.__log.alerts[w.__log.alerts.length-1]) && /서버 오류\(시험\)/.test(w.__log.alerts[w.__log.alerts.length-1]), w.__log.alerts[w.__log.alerts.length-1].slice(0,120));
  t('저장 단추 되살아남', !w.document.getElementById('xuSaveBtn').disabled && /선택 전표 저장/.test(w.document.getElementById('xuSaveBtn').textContent));
  /* 다시 저장 — 저장된 것은 건너뛰고 실패한 1장만 */
  w.__failDt=''; const before = saves.length;
  await w.xuSave(); await tick(40);
  const saves2 = w.__log.posts.filter(p => p.url.indexOf('salesTrxSave')>=0);
  t('다시 저장 = 실패했던 2장만(저장된 것·dup 은 건너뜀)', saves2.length === before+nFail && saves2.slice(before).every(s=>s.body.saleDt==='2026-02-05'), saves2.length-before);
  /* dup 을 다시 체크하고 저장 → 「추가 저장」 확인창 */
  w.__log.confirms=[]; w.xuChk(w._xu.groups.indexOf(D0()), true);
  await w.xuSave(); await tick(40);
  t('이미 있는 전표를 체크해 저장 → 「추가 저장」 확인(전표 0007 안내) 뒤 저장', w.__log.confirms[0] && /^추가 저장\|/.test(w.__log.confirms[0]) && /0007/.test(w.__log.confirms[0]) && /^저장됨/.test(D0().done), w.__log.confirms.map(c=>c.split('|')[0]).join(','));

  /* ── 2. 「엑셀 금액 그대로」 끄면 ktCalcRow 셈으로 ── */
  w = make(); w.xuParse(XLSX, XLSX.read(wbBuf, {type:'buffer', cellDates:true}), 'a.xlsx'); w.xuRegroup();
  const r0 = w._xu.rows[0];
  w.document.getElementById('xuAmtX').checked = false; w.xuRegroup();
  t('끄면 포함 거래처 줄 = 금액 ÷ 1.1 반올림(233,592 → 212,356/21,236) · fix 0', r0.o.supplyAmt===212356 && r0.o.vatAmt===21236 && r0.o.totAmt===233592 && r0.fix===0, JSON.stringify([r0.o.supplyAmt,r0.o.vatAmt,r0.o.totAmt,r0.fix]));
  const rb = w._xu.rows.find(r=>r.venCd==='001532' && r.box>0);
  t('별도 거래처 줄 = 공급가 수량×단가 · 부가세 10% 반올림', rb.o.supplyAmt===Math.round(rb.qty*rb.price) && rb.o.vatAmt===Math.round(rb.o.supplyAmt*0.1));
  w.document.getElementById('xuAmtX').checked = true; w.xuRegroup();
  t('다시 켜면 엑셀 값 그대로', r0.o.supplyAmt===212357 && r0.o.vatAmt===21235);

  /* ── 3. 거래처 미연결 → 팝업 고르기 훅 ── */
  w = make({ vendors: VEN_ALL.filter(v => v.vendorCd !== '001532') });
  w.xuParse(XLSX, XLSX.read(wbBuf, {type:'buffer', cellDates:true}), 'b.xlsx'); w.xuRegroup();
  const un = w._xu.groups.filter(g => !g.venCd);
  t('거래처 마스터에 없으면(우리푸드 뺌) 그 묶음 미연결 · 이름으로 묶임', un.length>0 && un.every(g=>g.venRaw==='우리푸드' && g.bad) && w._xu.groups.length===summ.length, un.length);
  t('미연결 묶음은 저장에서 건너뛰고 안내', (async()=>{})() && true);
  const gi = w._xu.groups.indexOf(un[0]);
  w.xuVenOpen(gi);
  t('거래처 칸 클릭 → 거래처 팝업 · 검색어 = 엑셀 이름', w.document.getElementById('saVenPop').classList.contains('on') && w.document.getElementById('saVenQ').value==='우리푸드' && w._xu.venTarget===gi);
  w.eval('_vendors.push({ vendorCd:"001532", vendorNm:"우리푸드", vatGb:"별도", mgrNm:"담당B" });');
  w.saVenPick('001532');
  t('saVenPick 훅 → 같은 이름 줄 전부 연결 · 본 화면 거래처 칸 무변경 · 팝업 닫힘', w._xu.rows.every(r=>r.venCd) && w.document.getElementById('saVenNm').value==='' && !w.document.getElementById('saVenPop').classList.contains('on') && w._xu.venTarget===null);
  t('다시 묶여 거래처 미연결 0 · 우리푸드 부가세 별도(미연결 상품 줄은 남아 있다)', w._xu.groups.every(g=>g.venCd) && w._xu.groups.filter(g=>g.venCd==='001532').every(g=>g.vatGb==='별도'));
  /* 미연결 상태로 저장을 누르면 건너뜀 안내 */
  w = make({ vendors: VEN_ALL.filter(v => v.vendorCd !== '001532') }); w.xuParse(XLSX, XLSX.read(wbBuf,{type:'buffer',cellDates:true}), 'c.xlsx'); w.xuRegroup();
  w.xuChkAll(false); w.xuChk(w._xu.groups.indexOf(w._xu.groups.find(g=>!g.venCd)), true);
  await w.xuSave(); await tick(20);
  t('거래처 미연결 묶음만 체크해 저장 → 「저장할 전표가 없습니다 … 거래처 미연결」', /저장할 전표가 없습니다/.test(w.__log.alerts[0]) && /거래처 미연결/.test(w.__log.alerts[0]) && w.__log.posts.filter(p=>p.url.indexOf('salesTrxSave')>=0).length===0, (w.__log.alerts[0]||'').slice(0,80));

  /* ── 4. 양식 검사·날짜 꼴 ── */
  w = make();
  const wsBad = XLSX.utils.aoa_to_sheet([['이름','수량'],['a',1]]); const wbBad = XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wbBad, wsBad, 'S');
  t('머리글 없는 파일 → 양식 아님', /판매등록 양식.*아닙니다/.test(w.xuParse(XLSX, wbBad, 'x.xlsx').err||''));
  const wsM = XLSX.utils.aoa_to_sheet([['판매일자','거래처명','상품코드','BOX수량'],['2026-01-01','A','1',1]]); const wbM = XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wbM, wsM, 'S');
  t('단가 칸 없음 → 없는 칸 안내', /없는 칸.*단가/.test(w.xuParse(XLSX, wbM, 'x.xlsx').err||''));
  const wsD = XLSX.utils.aoa_to_sheet([['판매일자','거래처코드','상품코드','BOX수량','EA수량','단가','비고'],
    [new Date(2026,0,8), '001532', '9904013286', 2, 0, 100, 'a'], [46030, '001532', '9904013286', 0, 5, 100, 'b'], ['20260108', '001532', '9904013286', 0, 1, 100, ''], ['2026.1.8', '001532', '9904013286', 0, 1, 100, ''], ['합계', '', '', 3, 7, '', '']]);   // 46030 = 2026-01-08 시리얼
  const wbD = XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wbD, wsD, '임의');
  const pr = w.xuParse(XLSX, wbD, 'd.xlsx'); w.xuRegroup();
  t('날짜 꼴 4가지(Date · 시리얼 46030 · 20260108 · 2026.1.8) 전부 2026-01-08 · 합계 줄 제외', !pr.err && w._xu.rows.length===4 && w._xu.rows.every(r=>r.dt==='2026-01-08'), JSON.stringify(w._xu.rows.map(r=>r.dt)));
  t('공급가·부가세·판매금액 칸이 없으면 셈으로(hasX false · 우리푸드 별도 10% → 200/20)', w._xu.rows.every(r=>!r.hasX) && w._xu.rows[0].o.supplyAmt===200 && w._xu.rows[0].o.vatAmt===20);
  t('합계수량 칸 없이 BOX 2 · 입수 1 → 합계 2', w._xu.rows[0].qty===2 && w._xu.rows[0].boxQty===2);
  t('한 묶음(같은 날·같은 거래처)', w._xu.groups.length===1 && w._xu.groups[0].rows.length===4);

  /* ── 5. 소스 훅·단추·설명서 ── */
  t('saVenPick 에 _xu.venTarget 훅', /_xu\.venTarget != null[^\n]*xuSetVen/.test(src));
  t('saProdPick·saExtPick 에 _xu.prodTarget 훅', (src.match(/_xu\.prodTarget != null/g)||[]).length===2);
  t('[📥 판매자료 엑셀업로드] 단추 = 상단, [💬 카톡 주문 가져오기] 바로 앞 · 작업 단추 줄에는 없음', (src.match(/id="saBtnXu"/g)||[]).length===1 && src.indexOf('id="saBtnXu"') < src.indexOf('onclick="ktOpen()"') && src.indexOf('id="saBtnXu"') < src.indexOf('id="saBtnSave"') && /📥 판매자료 엑셀업로드<\/button>/.test(src) && /id="xuHd"[^\n]*📥 판매자료 엑셀업로드/.test(src));
  const guide = fs.readFileSync(path.join(ROOT,'src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'),'utf8');
  t('업무설명서 「판매 등록 / 수금 등록」 행에 판매자료 엑셀업로드 한 문장(자동 저장 없음)', /판매 등록 \/ 수금 등록<\/td><td>[^\n]*판매자료 엑셀업로드[^\n]*자동 저장 없음/.test(guide));

  console.log((bad ? '✗ ' : '✓ ') + 'sim_salesXlsUpload ' + ok + ' ok / ' + bad + ' bad');
  process.exit(bad ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
