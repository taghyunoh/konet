/* 견적서 진행 상태 — 「관리자 승인 전이면 제출완료·채택·거절 금지(작성 중·보류만)」 · 「승인 취소 = 제출완료·채택·거절을 작성 중으로(보류는 그대로)」 시뮬 (2026-11-12)
   quoteMng.jsp 의 상태 창 마크업(#stPop)과 stOpen/stClose/stPick/stSave/stLocked/quoteAppr 를 떼어 jsdom 에서 돌린다.
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_quoteStatAppr.js */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name)]; for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/quoteMng.jsp'), 'utf8').replace(/\r\n/g, '\n');
function fn(name){ const i=src.indexOf('\nfunction '+name+'('); if(i<0) throw new Error('함수 없음 '+name); let d=0, j=src.indexOf('{', i); for(let k=j;k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ d--; if(d===0) return src.slice(i+1, k+1); } } throw new Error('끝 없음 '+name); }
const pop = src.match(/<div class="stpop" id="stPop"[\s\S]*?<div class="pf">[\s\S]*?<\/div>\s*<\/div>\s*<\/div>/)[0];
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }

function boot(isMaster){
  const dom = new JSDOM('<!DOCTYPE html><html><body>' + pop + '</body></html>', { runScripts: 'outside-only' });
  const w = dom.window;
  w.eval([
    "var IS_MASTER=" + (isMaster ? 'true' : 'false') + ";",
    "function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }",
    "function n(v){ var x=parseFloat(String(v==null?'':v).replace(/,/g,'')); return isNaN(x)?0:x; }",
    "function dnum(s){ return String(s||'').replace(/[^0-9]/g,'').slice(0,8); }",
    "function d10(s){ s=String(s||''); return /^[0-9]{8}$/.test(s) ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s.slice(0,10); }",
    "function stSpan(){ return null; }",
    "var _alerts=[], _confirms=[], _toasts=[], _posts=[], _loads=0, _renders=0, _postRes=null;",
    "function _alertBox(m){ _alerts.push(String(m)); }",
    "function _confirmBox(o){ _confirms.push(o); }",
    "function _toast(m){ _toasts.push(m); }",
    "function load(){ _loads++; }",
    "function lsRender(){ _renders++; }",
    "function post(url, body){ _posts.push({ url:url, body:body }); var r=_postRes||{ ok:true, status:200, j:{ result:'OK' } };"
      + " return Promise.resolve({ ok:r.ok, status:r.status, json:function(){ return Promise.resolve(r.j); }, text:function(){ return Promise.resolve(JSON.stringify(r.j)); } }); }",
    "var _ls=[];",
    src.match(/var ST_NM=\{[^\n]*\n/)[0],
    src.match(/var ST_DTK=\{[^\n]*\n/)[0],
    fn('stGb'),
    src.slice(src.indexOf('var _stSeq=null'), src.indexOf('function stOpen(')),
    fn('stOpen'), fn('stClose'), fn('stPick'), fn('stSave'), fn('quoteAppr')
  ].join('\n'));
  return w;
}
const tick = () => new Promise(r => setTimeout(r, 0));
const ticks = async k => { for (let i = 0; i < k; i++) await tick(); };
const radio = (w, v) => w.document.querySelector('input[name=stgb][value=' + v + ']');
const pick = (w, v) => { const r = radio(w, v); if (r.disabled) return false; r.checked = true; w.stPick(v); return true; };

(async () => {
  /* ── 1. 미승인 · 작성 중 (일반 직원) — 작성 중·보류만 ── */
  let w = boot(false);
  w._ls = [{ quoteSeq: 11, docNo: 'Konet261112-01', recvNm: 'Daily F&B(주)', statGb: 'W', apprYn: 'N' }];
  w.stOpen(0);
  t('미승인 : 제출완료 잠김', radio(w, 'S').disabled === true);
  t('미승인 : 채택 잠김', radio(w, 'A').disabled === true);
  t('미승인 : 거절 잠김', radio(w, 'R').disabled === true);
  t('미승인 : 보류 열림', radio(w, 'H').disabled === false);
  t('미승인 : 작성 중 열림', radio(w, 'W').disabled === false);
  t('미승인 : 제출·채택·거절 일자 칸 잠김', ['stSub', 'stAdo', 'stRej'].every(id => w.document.getElementById(id).disabled === true));
  t('미승인 : 보류 일자 칸 열림', w.document.getElementById('stHol').disabled === false);
  const note = w.document.getElementById('stApprNote');
  t('미승인 : 안내 띠 보임', note.style.display !== 'none' && /승인 전/.test(note.textContent) && /작성 중·보류는 됩니다/.test(note.textContent), note.textContent);
  t('일반 직원 안내 = 승인 요청', /승인 요청/.test(note.textContent));
  /* 화면을 건너뛰어 라디오를 억지로 골라도 저장 관문이 막는다 */
  radio(w, 'S').checked = true; w.document.getElementById('stSub').value = '2026-11-12';
  w.stSave(); await tick();
  t('억지 제출완료 저장 = 요청 안 나감', w._posts.length === 0, w._posts.length);
  t('억지 제출완료 저장 = 안내창', w._alerts.length === 1 && /승인 전/.test(w._alerts[0]) && /제출완료/.test(w._alerts[0]), w._alerts[0]);
  radio(w, 'A').checked = true; w.stSave(); await tick();
  radio(w, 'R').checked = true; w.stSave(); await tick();
  t('채택·거절도 막힘', w._posts.length === 0 && w._alerts.length === 3, w._alerts.length);
  /* 보류는 저장된다 */
  t('미승인 : 보류 고르기', pick(w, 'H') === true);
  w.stSave(); await ticks(2);
  t('미승인 : 보류 저장 = 요청 1건', w._posts.length === 1 && w._posts[0].url === '/mangr/quoteStat.do' && w._posts[0].body.statGb === 'H' && /^\d{4}-\d{2}-\d{2}$/.test(w._posts[0].body.holdDt), JSON.stringify(w._posts));

  /* ── 2. 미승인 · 작성 중 → 작성 중 저장(메모만) ── */
  w = boot(false);
  w._ls = [{ quoteSeq: 12, docNo: 'Konet261112-02', statGb: 'W', apprYn: 'N' }];
  w.stOpen(0); w.document.getElementById('stMemo').value = '메모';
  w.stSave(); await ticks(2);
  t('작성 중 저장 됨', w._posts.length === 1 && w._posts[0].body.statGb === 'W' && w._posts[0].body.statMemo === '메모');
  t('작성 중 저장 뒤 목록 다시', w._loads === 1 && w._toasts.length === 1);

  /* ── 3. 승인됨 — 전부 열림 ── */
  w = boot(false);
  w._ls = [{ quoteSeq: 13, docNo: 'Konet261112-03', statGb: 'W', apprYn: 'Y' }];
  w.stOpen(0);
  t('승인 : 다섯 상태 모두 열림', ['W', 'S', 'A', 'R', 'H'].every(v => radio(w, v).disabled === false));
  t('승인 : 일자 칸 모두 열림', ['stSub', 'stAdo', 'stRej', 'stHol'].every(id => w.document.getElementById(id).disabled === false));
  t('승인 : 안내 띠 숨김', w.document.getElementById('stApprNote').style.display === 'none');
  t('승인 : 제출완료 고르기', pick(w, 'S') === true);
  w.stSave(); await ticks(2);
  t('승인 : 제출완료 저장', w._posts.length === 1 && w._posts[0].body.statGb === 'S' && !!w._posts[0].body.submitDt && w._alerts.length === 0, JSON.stringify(w._posts));
  w.stOpen(0); t('승인 : 보류 고르기', pick(w, 'H') === true);
  w.stSave(); await ticks(2);
  t('승인 : 보류 저장', w._posts.length === 2 && w._posts[1].body.statGb === 'H' && /^\d{4}-\d{2}-\d{2}$/.test(w._posts[1].body.holdDt));

  /* ── 4. 미승인인데 이미 제출완료·보류인 옛 줄 — 그 상태는 그대로 둘 수 있고, 다른 잠긴 상태로는 못 간다 ── */
  w = boot(true);
  w._ls = [{ quoteSeq: 14, docNo: 'Konet261111-01', statGb: 'S', submitDt: '20261112', apprYn: 'N' }];
  w.stOpen(0);
  t('옛 줄(S) : 제출완료 라디오는 열림(지금 상태)', radio(w, 'S').disabled === false && radio(w, 'S').checked === true);
  t('옛 줄(S) : 제출완료 일자 칸 열림', w.document.getElementById('stSub').disabled === false && w.document.getElementById('stSub').value === '2026-11-12');
  t('옛 줄(S) : 채택·거절 잠김 · 보류 열림', radio(w, 'A').disabled && radio(w, 'R').disabled && !radio(w, 'H').disabled);
  t('마스터 안내 = [미승인] 눌러 승인', /\[미승인\]/.test(w.document.getElementById('stApprNote').textContent));
  w.document.getElementById('stMemo').value = '메모만';
  w.stSave(); await ticks(2);
  t('옛 줄(S) : 메모만 저장 됨', w._posts.length === 1 && w._posts[0].body.statGb === 'S' && w._posts[0].body.submitDt === '2026-11-12');
  w.stOpen(0); pick(w, 'W'); w.stSave(); await ticks(2);
  t('옛 줄(S) : 작성 중으로 되돌리기 됨', w._posts.length === 2 && w._posts[1].body.statGb === 'W');
  w = boot(false);
  w._ls = [{ quoteSeq: 15, docNo: 'Konet261104-02', statGb: 'H', holdDt: '20261105', apprYn: 'N' }];
  w.stOpen(0);
  t('미승인 보류 줄 : 보류는 열림·제출완료·채택·거절 잠김', !radio(w, 'H').disabled && !w.document.getElementById('stHol').disabled && radio(w, 'S').disabled && radio(w, 'A').disabled && radio(w, 'R').disabled);

  /* ── 5. 같은 창을 미승인 줄 → 승인 줄 → 미승인 줄로 이어 열어도 잠금이 남지 않는다 ── */
  w = boot(false);
  w._ls = [{ quoteSeq: 21, docNo: 'A', statGb: 'W', apprYn: 'N' }, { quoteSeq: 22, docNo: 'B', statGb: 'W', apprYn: 'Y' }];
  w.stOpen(0); w.stClose(); w.stOpen(1);
  t('이어 열기 : 승인 줄은 다시 열림', !radio(w, 'S').disabled && !radio(w, 'H').disabled && !w.document.getElementById('stSub').disabled && !w.document.getElementById('stHol').disabled && radio(w, 'S').parentNode.style.opacity === '');
  w.stClose(); w.stOpen(0);
  t('이어 열기 : 미승인 줄은 다시 잠김', radio(w, 'S').disabled && !radio(w, 'H').disabled && w.document.getElementById('stSub').disabled);

  /* ── 6. 서버가 승인 전이라고 막을 때(그 사이 승인이 거둬짐) — 사유를 보여 주고 목록을 다시 읽는다 ── */
  w = boot(false);
  w._ls = [{ quoteSeq: 31, docNo: 'C', statGb: 'W', apprYn: 'Y' }];
  w.stOpen(0); pick(w, 'A'); w.document.getElementById('stSub').value = '2026-11-10';
  w._postRes = { ok: false, status: 409, j: { code: 'NOAPPR', error: '관리자(총괄관리자) 승인 전입니다 — 승인된 견적서만 채택(으)로 바꿀 수 있습니다.' } };
  w.stSave(); await ticks(3);
  t('서버 거절 : 사유 안내', w._alerts.length === 1 && /승인 전입니다/.test(w._alerts[0]), w._alerts[0]);
  t('서버 거절 : 목록 다시 읽음·창 닫힘', w._loads === 1 && !w.document.getElementById('stPop').classList.contains('on'));
  w = boot(false);
  w._ls = [{ quoteSeq: 32, docNo: 'D', statGb: 'W', apprYn: 'Y' }];
  w.stOpen(0); pick(w, 'H');
  w._postRes = { ok: false, status: 500, j: { error: 'DB 오류' } };
  w.stSave(); await ticks(3);
  t('다른 오류 : 창 유지', w._alerts.length === 1 && w._loads === 0 && w.document.getElementById('stPop').classList.contains('on'));

  /* ── 7. 승인 취소 = 제출완료·채택·거절을 작성 중으로 되돌림 (보류·작성 중은 그대로) ── */
  for (const g of ['S', 'A', 'R']) {
    w = boot(true);
    w._ls = [{ quoteSeq: 40, docNo: 'Konet261112-0' + g, statGb: g, submitDt: '20261110', adoptDt: g === 'A' ? '20261111' : '', rejectDt: g === 'R' ? '20261111' : '', holdDt: '20261101', apprYn: 'Y', apprDttm: '2026-11-10 09:00:00', apprUser: 'admin' }];
    w._postRes = { ok: true, status: 200, j: { result: 'OK', apprYn: 'N', apprUser: 'admin', apprDttm: '' } };
    const pr = w.quoteAppr(0, 'N'); await tick();
    t(g + ' 승인 취소 : 먼저 묻는다(요청 전)', w._confirms.length === 1 && w._posts.length === 0, w._confirms.length + '/' + w._posts.length);
    t(g + ' 승인 취소 : 확인창에 옛 상태·작성 중', new RegExp(w.ST_NM[g]).test(w._confirms[0].msg) && /작성 중/.test(w._confirms[0].msg), w._confirms[0] && w._confirms[0].msg);
    w._confirms[0].onOk(); const r = await pr; await ticks(2);
    t(g + ' 승인 취소 : 요청', w._posts.length === 1 && w._posts[0].url === '/mangr/quoteAppr.do' && w._posts[0].body.apprYn === 'N' && w._posts[0].body.quoteSeq === 40, JSON.stringify(w._posts));
    const x = w._ls[0];
    t(g + ' 승인 취소 : 줄이 작성 중·세 일자 비움·미승인', r === true && x.statGb === 'W' && x.apprYn === 'N' && !x.submitDt && !x.adoptDt && !x.rejectDt, JSON.stringify(x));
    t(g + ' 승인 취소 : 보류 일자는 그대로', x.holdDt === '20261101', x.holdDt);
    t(g + ' 승인 취소 : 토스트·목록 다시', w._toasts.length === 1 && /작성 중으로 되돌렸습니다/.test(w._toasts[0]) && w._loads === 1, w._toasts[0]);
  }
  /* 확인창에서 [취소] = 아무 일 없음 */
  w = boot(true);
  w._ls = [{ quoteSeq: 41, docNo: 'E', statGb: 'S', submitDt: '20261110', apprYn: 'Y' }];
  let pr = w.quoteAppr(0, 'N'); await tick(); w._confirms[0].onCancel(); let r = await pr;
  t('승인 취소 확인창 [취소] = 그대로', r === false && w._posts.length === 0 && w._ls[0].statGb === 'S' && w._ls[0].apprYn === 'Y');
  /* 보류인 줄의 승인 취소 = 묻지 않고 바로, 상태·일자 그대로 (「다시 보류는 미포함」) */
  w = boot(true);
  w._ls = [{ quoteSeq: 45, docNo: 'I', statGb: 'H', submitDt: '20261101', holdDt: '20261105', apprYn: 'Y' }];
  w._postRes = { ok: true, status: 200, j: { result: 'OK', apprYn: 'N' } };
  r = await w.quoteAppr(0, 'N'); await ticks(2);
  t('보류 줄 승인 취소 = 바로·보류 그대로', r === true && w._confirms.length === 0 && w._posts.length === 1 && w._ls[0].apprYn === 'N' && w._ls[0].statGb === 'H' && w._ls[0].holdDt === '20261105' && w._ls[0].submitDt === '20261101' && w._loads === 0 && !/되돌렸습니다/.test(w._toasts[0]), JSON.stringify(w._ls[0]));
  /* 작성 중인 줄의 승인 취소 = 묻지 않고 바로(되돌릴 상태가 없다) */
  w = boot(true);
  w._ls = [{ quoteSeq: 42, docNo: 'F', statGb: 'W', apprYn: 'Y' }];
  w._postRes = { ok: true, status: 200, j: { result: 'OK', apprYn: 'N' } };
  r = await w.quoteAppr(0, 'N'); await ticks(2);
  t('작성 중 줄 승인 취소 = 바로', r === true && w._confirms.length === 0 && w._posts.length === 1 && w._ls[0].apprYn === 'N' && w._loads === 0 && !/되돌렸습니다/.test(w._toasts[0]), w._toasts[0]);
  /* 승인(Y) = 묻지 않고, 상태를 안 건드린다 */
  w = boot(true);
  w._ls = [{ quoteSeq: 43, docNo: 'G', statGb: 'S', submitDt: '20261110', apprYn: 'N' }];
  w._postRes = { ok: true, status: 200, j: { result: 'OK', apprYn: 'Y', apprUser: 'admin', apprDttm: '2026-11-12 10:00:00' } };
  r = await w.quoteAppr(0, 'Y'); await ticks(2);
  t('승인 = 상태 그대로', r === true && w._confirms.length === 0 && w._ls[0].apprYn === 'Y' && w._ls[0].statGb === 'S' && w._ls[0].submitDt === '20261110' && w._loads === 0);
  /* 승인 취소가 서버에서 실패하면 줄은 그대로 */
  w = boot(true);
  w._ls = [{ quoteSeq: 44, docNo: 'H', statGb: 'A', adoptDt: '20261111', apprYn: 'Y' }];
  w._postRes = { ok: false, status: 403, j: { error: '견적서 승인은 관리자(총괄관리자)만 할 수 있습니다.' } };
  pr = w.quoteAppr(0, 'N'); await tick(); w._confirms[0].onOk(); r = await pr; await ticks(2);
  t('승인 취소 실패 = 줄 그대로·안내', r === false && w._ls[0].statGb === 'A' && w._ls[0].apprYn === 'Y' && w._alerts.length === 1, JSON.stringify(w._ls[0]));

  console.log((bad ? '✗ ' : '✓ ') + 'sim_quoteStatAppr : ' + ok + ' 통과' + (bad ? ' · ' + bad + ' 실패' : ''));
  process.exit(bad ? 1 : 0);
})();
