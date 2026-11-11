/* 견적서 새 판 저장 — 번호 겹침(QUOTE_DUPNO) 뒤 다시 저장할 수 있는가 (2026-11-11)
   quoteEdit.jsp 의 errTxt / revAsk / save 를 떼어 돌린다.
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_quoteRevNo.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const E = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/quoteEdit.jsp'), 'utf8').replace(/\r\n/g, '\n');
function fnOf(src, name){ const i=src.indexOf('\nfunction '+name+'('); if(i<0) throw new Error('함수 없음 '+name); let d=0, j=src.indexOf('{', i); for(let k=j;k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ d--; if(!d) return src.slice(i+1, k+1); } } throw new Error('끝 없음 '+name); }
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const { JSDOM } = req('jsdom');
const dom = new JSDOM('<!DOCTYPE html><html><body><input id="docNo"><input id="quoteDt"><input id="mgrNm"><button id="saveBtn"></button><span id="mode"></span></body></html>', { runScripts: 'outside-only' });
const w = dom.window, d = w.document;
w.eval([
  fnOf(E, 'esc'), fnOf(E, 'gv'), fnOf(E, 'n'), fnOf(E, 'fmt'), fnOf(E, 'd10'),
  "var ST_NM={W:'작성 중',S:'제출완료',A:'채택',R:'거절',H:'보류'};",
  "var _statGb='S', _editMemo='', _unlocked=false, _latestYn='Y', _seq=533, _savedSeq=533, _savedDocNo='', _nextDoc='', _revAsked=false;",
  "var _revDoc='', _revDt='', _openDoc='Konet261111-01', _openMgr='정준영 프로 님';",
  "var __alerts=[], __errs=[], __posts=[], __next='Konet261111-02', __saveRes=null;",
  "function _alertBox(m){ __alerts.push(String(m)); } function err(m){ __errs.push(String(m)); } function ok(m){ __alerts.push('OK:'+m); }",
  "function copyMode(){ return false; } function lockApply(){} function loadDoc(){}",
  "function ask(){ return Promise.resolve(true); }",
  "function payload(){ return { confirm:'Y', docs:[{ revDocNo:_revDoc, quoteSeq:_seq, editMemo:_editMemo, docNo:gv('docNo'), quoteDt:gv('quoteDt'), recvNm:'삼성웰스토리', mgrNm:gv('mgrNm'), lines:[{qty:1,unitPrice:1,amt:1}] }] }; }",
  "function post(url, body){ __posts.push({url:url, body:body});",
  "  if(url.indexOf('quoteNextNo')>=0) return Promise.resolve({ json:function(){ return { docNo:__next }; } });",
  "  if(url.indexOf('quoteSave')>=0) return Promise.resolve({ status:__saveRes.st, ok:__saveRes.st===200, text:function(){ return Promise.resolve(__saveRes.t); } });",
  "  return Promise.resolve({ json:function(){ return { quoteSeq:540 }; } }); }",
  fnOf(E, 'errTxt'), fnOf(E, 'revAsk'), fnOf(E, 'save'),
].join('\n'));
const $ = (s) => d.querySelector(s);
(async () => {
  /* 1. 오류 글자 풀기 */
  const wrapped = JSON.stringify('QUOTE_DUPNO:문서번호 Konet261111-01 는 이미 있습니다 — 다른 번호로 넣어 주세요.');
  t('errTxt — 따옴표 한 겹을 푼다', w.errTxt(wrapped).indexOf('QUOTE_DUPNO:문서번호') === 0, w.errTxt(wrapped));
  t('errTxt — 안 감싼 글자는 그대로', w.errTxt('QUOTE_OLDREV:이전 판') === 'QUOTE_OLDREV:이전 판');
  t('errTxt — JSON 객체 글자는 그대로', w.errTxt('{"a":1}') === '{"a":1}' && w.errTxt('') === '' && w.errTxt(null) === '');

  /* 2. 캡처 그대로 : 새 판 번호로 «지금 판 번호(-01)» 가 넘어가 서버가 막은 경우 */
  d.getElementById('docNo').value = 'Konet261111-01'; d.getElementById('quoteDt').value = '2026-11-11'; d.getElementById('mgrNm').value = '정준영 프로 님';
  w.eval("_revDoc='Konet261111-01'; _revAsked=true; __saveRes={ st:400, t:" + JSON.stringify(wrapped) + " };");
  w.save(); await sleep(30);
  t('겹침 오류 — 문구가 따옴표·머리말 없이 나온다', w.__errs.length === 1 && w.__errs[0].indexOf('&quot;') < 0 && w.__errs[0].indexOf('QUOTE_DUPNO') < 0 && w.__errs[0].indexOf('이미 있습니다') > 0, w.__errs[0]);
  t('겹침 오류 — 다시 저장하면 새 번호로 열린다고 안내', w.__errs[0].indexOf('다시 누르면') > 0);
  t('★겹침 뒤 확인창을 다시 열 수 있게 풀린다(_revAsked=false · 겹친 번호 버림)', w.eval('_revAsked') === false && w.eval('_revDoc') === '');
  t('저장 단추는 다시 눌린다', d.getElementById('saveBtn').disabled === false);

  /* 3. [저장]을 다시 누르면 — 확인창이 열리고 다음 번호(-02)가 들어 있다 */
  w.__posts.length = 0; w.save(); await sleep(20);
  t('★다시 [저장] → 새 판 확인창이 열린다', !!$('#_rvNo'));
  t('확인창 문서번호 = 서버가 준 다음 번호 -02', $('#_rvNo') && $('#_rvNo').value === 'Konet261111-02', $('#_rvNo') && $('#_rvNo').value);
  t('아직 저장 요청은 안 나갔다', !w.__posts.some(p => p.url.indexOf('quoteSave') >= 0));

  /* 4. 확인창에서 지금 판 번호(-01)를 넣으면 — 그 자리에서 막고 다음 번호를 다시 넣는다 */
  w.__alerts.length = 0; $('#_rvNo').value = 'Konet261111-01'; $('#_rvNo').oninput();
  $('#_rvOk').onclick(); await sleep(20);
  t('지금 판 번호는 확인창이 막는다(서버까지 안 간다)', w.__alerts.length === 1 && w.__alerts[0].indexOf('지금 판의 번호') > 0 && !w.__posts.some(p => p.url.indexOf('quoteSave') >= 0), w.__alerts[0]);
  t('막은 뒤 문서번호 칸에 다음 번호 -02', $('#_rvNo') && $('#_rvNo').value === 'Konet261111-02', $('#_rvNo') && $('#_rvNo').value);

  /* 5. -02 로 확인 → 저장 요청에 revDocNo=-02 */
  w.eval("__saveRes={ st:200, t:" + JSON.stringify(JSON.stringify('{"cnt":1,"seqs":[540],"seq":540,"docNo":"Konet261111-02"}')) + " };");
  $('#_rvOk').onclick(); await sleep(40);
  const sv = w.__posts.filter(p => p.url.indexOf('quoteSave') >= 0)[0];
  t('★-02 로 저장 요청이 나간다', !!sv && sv.body.docs[0].revDocNo === 'Konet261111-02' && sv.body.docs[0].quoteSeq === 533, sv && JSON.stringify(sv.body.docs[0].revDocNo));
  t('저장 뒤 머리 문서번호 = -02 · 화면이 새 판(540)으로', d.getElementById('docNo').value === 'Konet261111-02' && w.eval('_seq') === 540, d.getElementById('docNo').value + ' / ' + w.eval('_seq'));
  t('확인창은 닫혔다', !$('#_rvNo'));

  /* 6. 머리의 문서번호 칸을 손으로 바꿔 뒀으면(-05) 그 번호가 확인창 기본값 */
  w.eval("_seq=533; _revAsked=false; _revDoc=''; _statGb='S';"); d.getElementById('docNo').value = 'Konet261111-05';
  w.save(); await sleep(20);
  t('머리 칸을 고쳐 둔 번호가 확인창 기본값', $('#_rvNo') && $('#_rvNo').value === 'Konet261111-05', $('#_rvNo') && $('#_rvNo').value);
  $('#_rvNoBtn').onclick();

  /* 7. 담당자를 바꿨으면 같은 번호도 된다(번호는 담당자별) */
  d.getElementById('docNo').value = 'Konet261111-01'; d.getElementById('mgrNm').value = '오슬하 프로님'; w.eval("__next='Konet261111-01'; __posts.length=0; __alerts.length=0;");
  w.save(); await sleep(20);
  $('#_rvOk').onclick(); await sleep(40);
  t('담당자가 바뀌면 -01 도 그대로 보낸다', w.__posts.some(p => p.url.indexOf('quoteSave') >= 0 && p.body.docs[0].revDocNo === 'Konet261111-01') && !w.__alerts.some(a => a.indexOf('지금 판의 번호') > 0));

  console.log((bad ? '✗ ' : '✓ ') + 'sim_quoteRevNo : 통과 ' + ok + ' · 실패 ' + bad);
})();
