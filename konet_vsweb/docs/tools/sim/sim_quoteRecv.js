/* 견적서 목록 「수신」 고르기(수신별 조회) 시뮬 — quoteMng.jsp 의 lsRender/recvFill/lsHit/lsView/cmpOpen 앞부분을 떼어 jsdom 에서 돌린다 (2026-11-08)
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_quoteRecv.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/quoteMng.jsp'), 'utf8').replace(/\r\n/g, '\n');
function fn(name){ const i=src.indexOf('\nfunction '+name+'('); if(i<0) throw new Error('함수 없음 '+name); let d=0, j=src.indexOf('{', i); for(let k=j;k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ d--; if(!d) return src.slice(i+1, k+1); } } }
const bar = src.match(/<select id="recv"[\s\S]*?<\/select>/)[0];
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }

const html = '<!DOCTYPE html><html><body>' + bar + '<input type="checkbox" id="lsAll"><table><tbody id="lsBody"></tbody></table><div id="lsTot"></div></body></html>';
const dom = new JSDOM(html, { runScripts: 'outside-only' });
const w = dom.window;
/* 화면이 쓰는 보조 함수 — 실제와 같은 뜻으로 */
w.eval([
  "var RECV_NONE_=null;",
  "function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\"/g,'&quot;'); }",
  "function n(v){ var x=parseFloat(String(v==null?'':v).replace(/,/g,'')); return isNaN(x)?0:x; }",
  "function fmt(v){ return Math.round(n(v)).toLocaleString('en-US'); }",
  "function d10(s){ return String(s||'').slice(0,10); }",
  "function linCell(){ return ''; } function stCell(){ return ''; } function apprCell(){ return ''; } function stGb(){ return 'W'; } var ST_NM={W:'작성 중'};",
  "var _ls=[], _sel=null;",
  "var RECV_NONE='__none__';",
  src.slice(src.indexOf('function recvKey('), src.indexOf('function lsRender(')),
  fn('lsRender').replace(/return '<tr class="tap[\s\S]*?<\/tr>';/, "return '<tr class=\"tap\"><td><input type=\"checkbox\" class=\"lchk\" data-i=\"'+i+'\"></td><td>'+esc(x.docNo)+'</td><td>'+esc(x.recvNm)+'</td></tr>';"),
].join('\n'));

w._ls = [
  { quoteSeq: 1, docNo: 'Konet261106-03', recvNm: '샐러링', supplyAmt: 107000 },
  { quoteSeq: 2, docNo: 'Konet261106-01', recvNm: '우리들병원', supplyAmt: 1386000 },
  { quoteSeq: 3, docNo: 'Konet261106-01', recvNm: '샐러링', supplyAmt: 35500 },
  { quoteSeq: 4, docNo: 'Konet261105-01', recvNm: '삼성웰스토리', supplyAmt: 74000 },
  { quoteSeq: 5, docNo: 'Konet261105-01', recvNm: ' 샐러링 ', supplyAmt: 69000 },   /* 앞뒤 공백 — 같은 수신으로 */
  { quoteSeq: 6, docNo: 'Konet261104-02', recvNm: '', supplyAmt: 741200 },           /* 수신 없음 */
];
const d = w.document;
w.lsRender();
const opts = [...d.querySelectorAll('#recv option')].map(o => o.value + '|' + o.textContent);
t('수신 목록 = 전체 + 이름순 3 + (수신 없음) 맨 뒤', opts.join(' / ') === '|수신 전체 (6건) / 삼성웰스토리|삼성웰스토리 (1건 · 74,000원) / 샐러링|샐러링 (3건 · 211,500원) / 우리들병원|우리들병원 (1건 · 1,386,000원) / __none__|(수신 없음) (1건 · 741,200원)', opts.join(' / '));
t('전체 = 6줄 · 합계', d.querySelectorAll('#lsBody tr').length === 6 && d.getElementById('lsTot').textContent === '6건 · 금액 2,412,700원', d.getElementById('lsTot').textContent);
d.getElementById('recv').value = '샐러링'; w.lsRender();
const rows = [...d.querySelectorAll('#lsBody tr')];
t('샐러링 = 3줄(공백 줄 포함) · data-i 는 _ls 번호 그대로(0,2,4)', rows.length === 3 && rows.map(r => r.querySelector('.lchk').getAttribute('data-i')).join(',') === '0,2,4', rows.map(r => r.querySelector('.lchk') && r.querySelector('.lchk').getAttribute('data-i')).join(','));
t('합계 줄 = 3건 / 전체 6 · 211,500 · (수신 샐러링)', d.getElementById('lsTot').textContent === '3건 / 전체 6 · 금액 211,500원 (수신 샐러링)', d.getElementById('lsTot').textContent);
t('lsView = 거른 줄 3', w.lsView().length === 3 && w.lsView()[2].quoteSeq === 5);
d.getElementById('recv').value = '__none__'; w.lsRender();
t('(수신 없음) = 1줄 · 합계 (수신 없음)', d.querySelectorAll('#lsBody tr').length === 1 && d.getElementById('lsTot').textContent.indexOf('(수신 없음)') > 0, d.getElementById('lsTot').textContent);
t('고른 값은 다시 그려도 남는다', d.getElementById('recv').value === '__none__');
/* 다시 조회해 그 수신이 없어지면 전체로 */
w._ls = w._ls.filter(x => x.recvNm); w.lsRender();
t('수신이 사라지면 「수신 전체」로 · 5줄', d.getElementById('recv').value === '' && d.querySelectorAll('#lsBody tr').length === 5, d.getElementById('recv').value);
d.getElementById('recv').value = '삼성웰스토리'; w.lsRender();
w._ls = []; w.lsRender();
t('목록이 비면 빈 줄 안내 · 합계 없음', d.querySelector('#lsBody td.empty') && d.getElementById('lsTot').textContent === '');
/* 견적 비교 fallback = 보이는 줄 */
const cmpLine = src.slice(src.indexOf('function cmpOpen('), src.indexOf('function cmpOpen(') + 400);
t('견적 비교의 「체크 없으면 전체」 = lsView()', cmpLine.indexOf('seqs=lsView().map') > 0);
console.log((bad ? '✗ ' : '✓ ') + 'sim_quoteRecv : 통과 ' + ok + ' · 실패 ' + bad);
process.exit(bad ? 1 : 0);
