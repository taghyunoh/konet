/* 대표자 일정 — 제목 칸 없음 · 내용 줄 보이기 · 줄마다 완료/일정취소 · 내용 검색 (2026-11-19)
   node docs/tools/sim/sim_ceoSchedLines.js   (jsdom 필요 — NODE_PATH 로 빌려 써도 된다) */
const fs=require('fs'), path=require('path');
const { JSDOM }=require('jsdom');
const F=path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/ceoSched.jsp');
let src=fs.readFileSync(F,'utf8')
  .replace(/<%--[\s\S]*?--%>/g,'').replace(/<%@[^%]*%>/g,'')
  .replace(/\$\{pageContext\.request\.contextPath\}/g,'').replace(/\$\{ceoAdmin\}/g,'Y')
  .replace(/<script[^>]*src=[^>]*><\/script>/g,'');
let ok=0, bad=0; function T(c,m){ if(c){ ok++; } else { bad++; console.log('✗ '+m); } }

/* 가짜 서버 */
const today=(()=>{ const d=new Date(); return ''+d.getFullYear()+String(d.getMonth()+1).padStart(2,'0')+String(d.getDate()).padStart(2,'0'); })();
const C1='<div>삼성미팅</div><div>1. 차상회 셀장 미팅 : 샘플 건(갈릭 보이) 완료</div><div>2. 서예림 프로 미팅 : 샘플 건(벅벅)</div><div><br></div><div>대상미팅</div><div>1. 납품</div><div>2. <b>품질</b></div>';
const DB={ 1:{ schedSeq:1, fromDt:today, toDt:today, schedTm:'', title:'삼성미팅', place:'', content:C1, doneYn:'N', doneDttm:'', hasContent:'Y' },
           2:{ schedSeq:2, fromDt:today, toDt:today, schedTm:'14:00', title:'테그42 디자인 건', place:'본사', content:'', doneYn:'N', doneDttm:'', hasContent:'N' } };
let saves=[], listHasContent=true;
function resp(o){ return Promise.resolve({ ok:true, status:200, json:()=>Promise.resolve(o) }); }
function fakeFetch(url, opt){
  const b=opt&&opt.body||''; const P=(typeof b==='string' && b[0]!=='{') ? Object.fromEntries(new URLSearchParams(b)) : JSON.parse(b||'{}');
  if(/ceoSchedList/.test(url)) return resp({ data:Object.values(DB).filter(r=>!r.deleted).map(r=>{ const o=Object.assign({},r); if(!listHasContent) delete o.content; return o; }) });
  if(/ceoSchedGet/.test(url)) return resp({ data:Object.assign({},DB[+P.schedSeq]) });
  if(/ceoSchedDelList/.test(url)) return resp({ data:Object.values(DB).filter(r=>r.deleted).map(r=>Object.assign({ delDttm:'2026-11-19 21:10:00', delUser:'마스터' }, r)) });
  if(/ceoSchedRestore/.test(url)){ (globalThis.__rst=globalThis.__rst||[]).push(+P.schedSeq); if(DB[+P.schedSeq]) DB[+P.schedSeq].deleted=false; return resp({ rows:1 }); }
  if(/ceoSchedDel\.do|ceoSchedDone/.test(url)){ (globalThis.__dels=globalThis.__dels||[]).push(url); if(/ceoSchedDel\.do/.test(url) && DB[+P.schedSeq]) DB[+P.schedSeq].deleted=true; return resp({ rows:1 }); }
  if(/ceoSchedSave/.test(url)){ saves.push(P); const r=DB[P.schedSeq]; Object.assign(r,{ title:P.title, content:P.content, place:P.place, doneYn:P.doneYn, hasContent:P.content?'Y':'N' }); return resp({ rows:1 }); }
  return resp({});
}
const dom=new JSDOM(src,{ runScripts:'dangerously', pretendToBeVisual:true, url:'http://localhost/', beforeParse(w){ w.fetch=fakeFetch; w._toast=function(m){ w.__toast=m; }; w._alertBox=function(m){ w.__alert=m; }; w._confirmBox=function(o){ o.onOk&&o.onOk(); }; } });
const w=dom.window, d=w.document;
const tick=()=>new Promise(r=>setTimeout(r,30));
(async()=>{
  await tick(); await tick();
  T(d.getElementById('tabTodo').classList.contains('on') && !d.getElementById('tabAll').classList.contains('on') && !d.getElementById('tabMon'), '처음 탭 = 미완료 · 「이 달」 탭 없음');
  w.tabGo('all');   /* 아래 검사는 전체 목록 기준 */
  /* 창 : 제목 칸 없음 */
  T(!d.getElementById('fTitle'), '제목 칸이 남아 있다');
  T(!!d.getElementById('fPlace'), '장소 칸이 없다');
  T(/내용 \/ 장소/.test(d.getElementById('q').placeholder), '검색칸 안내');
  /* 줄 나누기 */
  const L=w.schedLines(C1).lines;
  T(L.length===6, '줄 수 6 (빈 줄 제외) : '+L.length);
  T(L[1].st==='Y' && L[1].body==='1. 차상회 셀장 미팅 : 샘플 건(갈릭 보이)', '손으로 적은 「완료」 = 완료 : '+JSON.stringify(L[1].body));
  T(L[2].st==='N', '둘째 항목은 상태 없음');
  T(w.lnMark('검수완료').st==='N', '「검수완료」는 상태 아님');
  T(w.lnMark('납품 [완료]').st==='Y' && w.lnMark('납품 (일정취소)').st==='C' && w.lnMark('납품 일정 취소').st==='C', '괄호·띄어쓴 표기');
  T(w.titleOf(C1)==='삼성미팅', '제목 = 첫 줄');
  const ol=w.schedLines('<ol><li>가</li><li>나 완료</li></ol><ul><li>다</li></ul>').lines;
  T(ol.map(l=>l.body).join('|')==='1. 가|2. 나|• 다' && ol[1].st==='Y', '목록 번호 : '+ol.map(l=>l.body).join('|'));
  const br=w.schedLines('첫째<br>둘째 완료<br><br>셋째').lines;
  T(br.length===3 && br[1].st==='Y', 'br 줄');
  /* 줄 상태 고치기 — 서식 유지 */
  let h=w.lnApply(C1, 5, 'Y');
  T(/<b>품질 완료<\/b>/.test(h), '굵은 글 안 끝에 완료 : '+h.slice(-60));
  h=w.lnApply(h, 5, 'C'); T(/<b>품질 취소<\/b>/.test(h), '완료 → 취소');
  T(w.lnMark('미팅 취소').st==='C' && w.lnMark('미팅 일정취소').st==='C' && w.lnMark('주문취소').st==='N', '「취소」·옛 「일정취소」 = 취소 · 붙여 쓴 「주문취소」는 아님');
  h=w.lnApply(h, 5, 'N'); T(/<b>품질<\/b>/.test(h), '일정취소 → 지움');
  T(w.lnApply(C1,1,'N').indexOf('(갈릭 보이)</div>')>0, '손 「완료」 지우기');
  /* 달력 칸 */
  const cal=d.getElementById('cal');
  const ev=[...cal.querySelectorAll('.ev.lns')];
  T(ev.length===2, '오늘 칸 일정 2 : '+ev.length);
  const e1=ev.find(x=>/삼성미팅/.test(x.textContent));
  T(e1 && e1.querySelectorAll('.ln').length===6, '삼성미팅 줄 6');
  T(e1 && e1.querySelectorAll('.ln.lY').length===1, '완료 줄 1');
  const e2=ev.find(x=>/테그42/.test(x.textContent));
  T(e2 && /14:00 · 본사/.test(e2.querySelector('.eh').textContent) && e2.querySelectorAll('.ln').length===1, '옛 일정(내용 없음) = 제목 한 줄 + 시간·장소');
  /* 목록 */
  const it=[...d.querySelectorAll('#list .it')];
  T(it.length===2 && !d.querySelector('#list .t1'), '목록 2 · 제목 줄 없음');
  /* 검색 = 내용 */
  const q=d.getElementById('q'); q.value='서예림'; w.paintList();
  T(d.querySelectorAll('#list .it').length===1 && d.querySelector('#list mark').textContent==='서예림', '내용으로 찾기 + 표시');
  q.value='본사'; w.paintList(); T(d.querySelectorAll('#list .it').length===1, '장소로 찾기');
  q.value='없는말'; w.paintList(); T(d.querySelectorAll('#list .it').length===0, '없는 말');
  q.value=''; w.paintList();
  /* 칩 누르기 → 저장 */
  const ck=[...d.querySelectorAll('#list .it')].find(x=>/삼성미팅/.test(x.textContent)).querySelectorAll('.ln .ck')[2];   /* 2. 서예림 … */
  ck.dispatchEvent(new w.MouseEvent('click',{ bubbles:true }));
  await tick(); await tick();
  T(saves.length===1, '저장 1회');
  T(saves[0] && /서예림 프로 미팅 : 샘플 건\(벅벅\) 완료</.test(saves[0].content), '그 줄 끝에 완료');
  T(saves[0] && saves[0].doneYn==='N' && saves[0].title==='삼성미팅' && saves[0].fromDt===today, '일정 상태·제목·일자 그대로');
  T(!d.getElementById('pop').classList.contains('on'), '칩은 창을 열지 않는다');
  T(d.querySelectorAll('#list .ln.lY').length===2, '목록에 완료 줄 2 반영');
  /* 옛 일정(내용 없음) 칩 → 제목을 첫 줄로 */
  const ck2=[...d.querySelectorAll('#list .it')].find(x=>/테그42/.test(x.textContent)).querySelector('.ln .ck');
  ck2.dispatchEvent(new w.MouseEvent('click',{ bubbles:true })); await tick(); await tick();
  T(saves[1] && saves[1].content==='<div>테그42 디자인 건 완료</div>' && saves[1].title==='테그42 디자인 건', '옛 일정 칩 : '+JSON.stringify(saves[1]&&saves[1].content));
  /* 창 열기 — 옛 일정은 제목이 첫 줄로 · 저장 시 제목 = 첫 줄 */
  DB[3]={ schedSeq:3, fromDt:today, toDt:today, schedTm:'', title:'옛 제목', place:'', content:'', doneYn:'N', hasContent:'N' };
  w.edOpen(3); await tick(); await tick();
  T(d.getElementById('ed').textContent==='옛 제목', '옛 일정 열면 제목이 내용 첫 줄로');
  d.getElementById('ed').innerHTML='<div>새 첫 줄 완료</div><div>1. 둘째</div>';
  w.edSave(); await tick(); await tick();
  T(saves[2] && saves[2].title==='새 첫 줄', '저장 제목 = 첫 줄(「완료」 뺌) : '+(saves[2]&&saves[2].title));
  /* 빈 내용 저장 막기 */
  w.edOpen(0); await tick(); d.getElementById('ed').innerHTML=''; w.__alert=''; w.edSave(); await tick();
  T(/내용을 적으세요/.test(w.__alert||''), '빈 내용 저장 막음');
  /* 옛 서버(목록에 내용 없음) — 내용을 한 건씩 채운다 */
  listHasContent=false; w.edClose(true); w.load(); await tick(); await tick(); await tick(); await tick();
  const e3=[...d.querySelectorAll('#cal .ev.lns')].find(x=>/삼성미팅/.test(x.textContent));
  T(e3 && e3.querySelectorAll('.ln').length===6, '옛 서버도 내용 줄 채움');
  /* ── 업무일지 꼴 : 번호 칸 · 묶음 머리 · N건 ── */
  const e4=[...d.querySelectorAll('#cal .ev.lns')].find(x=>/삼성미팅/.test(x.textContent));
  T(e4.querySelectorAll('.ln.hd').length===2, '번호 없는 줄 = 묶음 머리 2');
  T([...e4.querySelectorAll('.ln .no')].map(x=>x.textContent).join(',')==='1.,2.,1.,2.', '번호 칸 : '+[...e4.querySelectorAll('.ln .no')].map(x=>x.textContent).join(','));
  T(!/^1\./.test(e4.querySelectorAll('.ln .lt')[1].textContent.trim()), '번호는 글 칸에서 빠진다');
  T(/4건/.test(e4.querySelector('.cnt').textContent) && /끝 2/.test(e4.querySelector('.cnt').textContent), '건수 4 · 끝 2 : '+e4.querySelector('.cnt').textContent);
  T(!!d.querySelector('#list .it .t2 .cnt'), '목록에도 건수');
  T(w.LN_NUM.exec('11.19')===null && w.LN_NUM.exec('3.평택')!==null && w.LN_NUM.exec('2) 납품')!==null, '번호 규칙(11.19 는 아님)');
  /* 번호 없는 일정은 머리 없음 · 건수 = 줄 수 */
  const e5=[...d.querySelectorAll('#cal .ev.lns')].find(x=>/테그42/.test(x.textContent));
  T(e5 && !e5.querySelector('.ln.hd') && /1건/.test(e5.querySelector('.cnt').textContent), '번호 없는 일정 = 1건 · 머리 없음');
  /* 편집기 Enter → 다음 번호 */
  w.edOpen(0); await tick();
  const ED=d.getElementById('ed');
  w.document.execCommand=function(cmd,ui,val){ if(cmd!=='insertText') return false; const sel=w.getSelection(); const r=sel.getRangeAt(0); const tn=d.createTextNode(val); r.insertNode(tn); r.setStartAfter(tn); r.collapse(true); sel.removeAllRanges(); sel.addRange(r); return true; };
  function enterAt(html){ ED.innerHTML=html; const nb=ED.lastChild; const r=d.createRange(); r.setStart(nb,0); r.collapse(true); const sel=w.getSelection(); sel.removeAllRanges(); sel.addRange(r); w.edAutoNum(); return ED.innerHTML; }
  T(enterAt('<div>삼성미팅</div><div>1. 차상회 미팅</div><div><br></div>').endsWith('<div>2. <br></div>'), 'div 줄 Enter → 2. : '+ED.innerHTML);
  T(enterAt('1) 첫 줄<div><br></div>').endsWith('<div>2) <br></div>'), '맨 첫 줄(글자만) Enter → 2) : '+ED.innerHTML);
  T(enterAt('<div>삼성미팅</div><div><br></div>')==='<div>삼성미팅</div><div><br></div>', '번호 없는 줄은 그대로');
  T(enterAt('<div>1. 가</div><div>2. </div><div><br></div>')==='<div>1. 가</div><div><br></div><div><br></div>', '번호만 남은 줄 Enter = 번호 끝 : '+ED.innerHTML);
  T(enterAt('<div>11.19</div><div><br></div>')==='<div>11.19</div><div><br></div>', '「11.19」 다음은 번호 안 붙음');
  /* 번호 정리 */
  ED.innerHTML='<div>삼성미팅</div><div>1. 가</div><div>3. <b>나</b></div><div>대상미팅</div><div>5. 다</div><div>7) 라</div>';
  w.edRenumber();
  T(ED.innerHTML==='<div>삼성미팅</div><div>1. 가</div><div>2. <b>나</b></div><div>대상미팅</div><div>1. 다</div><div>2) 라</div>', '번호 정리 : '+ED.innerHTML);
  w.__toast=''; w.edRenumber(); T(/이미 차례대로/.test(w.__toast||''), '이미 차례면 그대로');
  w.edClose(true);

  /* ── 묶음 머리 줄 : 칩 없음 · 상태가 붙어 있으면 칩을 눌러 바로 지움 (그림 — 「삼성미팅 완료」) ── */
  listHasContent=true;
  DB[4]={ schedSeq:4, fromDt:today, toDt:today, schedTm:'', title:'삼성미팅', place:'', doneYn:'N', hasContent:'Y',
    content:'<div>삼성미팅 완료</div><div>1. 가</div><div>2. 나 완료</div><div>대상미팅</div><div>1. 다</div>' };
  w.load(); await tick(); await tick();
  const it4=[...d.querySelectorAll('#list .it')].find(x=>/대상미팅/.test(x.textContent) && /다/.test(x.textContent) && x.querySelectorAll('.ln').length===5);
  const hd=[...it4.querySelectorAll('.ln.hd')];
  T(hd.length===2, '머리 줄 2');
  T(hd[1].classList.contains('nock') && !hd[1].querySelector('.ck').getAttribute('onclick'), '상태 없는 머리 = 칩 없음');
  T(!hd[0].classList.contains('nock') && /,'N'\)/.test(hd[0].querySelector('.ck').getAttribute('onclick')), '완료 붙은 머리 = 칩 → 지우기');
  T(/^3건/.test(it4.querySelector('.cnt').textContent), '건수에 머리 안 셈(3건) : '+it4.querySelector('.cnt').textContent);
  const n0=saves.length; hd[0].querySelector('.ck').dispatchEvent(new w.MouseEvent('click',{ bubbles:true })); await tick(); await tick();
  T(saves.length===n0+1 && /<div>삼성미팅<\/div>/.test(saves[n0].content) && /나 완료/.test(saves[n0].content), '머리 완료만 지우고 다른 줄 그대로 : '+(saves[n0]&&saves[n0].content));
  /* ── 편집기 서식이 달력·목록에도 (그림 — 빨간 큰 글 · 취소선 머리) ── */
  DB[5]={ schedSeq:5, fromDt:today, toDt:today, schedTm:'', title:'서식', place:'', doneYn:'N', hasContent:'Y',
    content:'<div><s>대상미팅</s></div><div>1. <b>납품</b> 완료</div><div><span style="color: rgb(192, 57, 43); font-size: 16px;">테그42 디자인 시안 확인 요청</span></div><div><span style="background-color: rgb(255, 243, 163);">2. 형광 줄</span></div><div><a href="http://x" onclick="alert(1)">3. 링크 <img src=x onerror=alert(1)></a></div>' };
  w.load(); await tick(); await tick();
  const it5=[...d.querySelectorAll('#list .it')].find(x=>/테그42 디자인 시안/.test(x.textContent));
  const lt=[...it5.querySelectorAll('.ln .lt')];
  T(!!lt[0].querySelector('s') && lt[0].textContent.indexOf('대상미팅')===0, '취소선 머리 그대로');
  T(!!lt[1].querySelector('b') && lt[1].querySelector('b').textContent==='납품' && /완료$/.test(lt[1].textContent) && !/^1\./.test(lt[1].textContent), '굵게 · 번호·완료는 칸·꼬리표로 : '+lt[1].innerHTML);
  const red=lt[2].querySelector('span[style]');
  T(red && /color/.test(red.getAttribute('style')) && /16px/.test(red.getAttribute('style')), '빨간 큰 글 : '+lt[2].innerHTML);
  T(!/^2\./.test(lt[3].textContent) && /background-color/.test(lt[3].innerHTML) && it5.querySelectorAll('.ln .no')[1].textContent==='2.', '형광 줄 · 번호는 칸');
  T(!lt[4].querySelector('a,img') && !/onclick|onerror/.test(lt[4].innerHTML), '링크·그림·on 속성은 안 실림 : '+lt[4].innerHTML);
  const cal5=[...d.querySelectorAll('#cal .ev.lns')].find(x=>/테그42 디자인 시안/.test(x.textContent));
  T(cal5 && cal5.querySelector('.lt span[style*="16px"]'), '달력 칸에도 서식');
  q.value='시안'; w.paintList();
  T(d.querySelector('#list mark') && d.querySelector('#list mark').textContent==='시안', '검색 중엔 글자 + 표시');
  q.value=''; w.paintList();
  /* ── 날짜 칸 빈 곳 = 그 날짜 일정 열기 (없으면 새 일정) ── */
  const cell=[...d.querySelectorAll('#cal .dc')].find(x=>x.querySelector('.ev.lns'));
  w.edClose(true);
  cell.dispatchEvent(new w.MouseEvent('click',{ bubbles:true })); await tick(); await tick();
  T(d.getElementById('pop').classList.contains('on') && d.getElementById('popTit').textContent==='일정 수정', '일정 있는 날 빈 곳 = 그 일정 열기');
  T(/어디를 눌러도/.test(cell.getAttribute('title')), '칸 안내 글');
  w.edClose(true);
  const empty=[...d.querySelectorAll('#cal .dc')].find(x=>!x.querySelector('.ev'));
  empty.dispatchEvent(new w.MouseEvent('click',{ bubbles:true })); await tick();
  T(d.getElementById('pop').classList.contains('on') && d.getElementById('popTit').textContent==='일정 등록', '일정 없는 날 = 새 일정');
  w.edClose(true);
  /* ── 위 상태 칸 = 내용 줄 전부에 적용(완료·취소·지움, 묶음 제목은 그대로) · 뒤에 줄마다 따로 ── */
  DB[6]={ schedSeq:6, fromDt:today, toDt:today, schedTm:'', title:'삼성미팅', place:'', doneYn:'N', hasContent:'Y',
    content:'<div>삼성미팅</div><div>1. 가</div><div>2. 나 취소</div><div>대상미팅</div><div>1. <b>다</b></div>' };
  w.load(); await tick(); await tick();
  let nS=saves.length; w.doneSet(6,'Y'); await tick(); await tick(); await tick();
  const sv=saves[nS];
  T(sv && sv.doneYn==='Y', '상태 완료로 저장');
  T(sv && /<div>1\. 가 완료<\/div>/.test(sv.content) && /<div>2\. 나 완료<\/div>/.test(sv.content) && /<b>다 완료<\/b>/.test(sv.content), '줄 전부 완료(취소였던 줄도) : '+(sv&&sv.content));
  T(sv && /<div>삼성미팅<\/div>/.test(sv.content) && /<div>대상미팅<\/div>/.test(sv.content), '묶음 제목은 그대로');
  /* 그 뒤 줄 하나를 따로 — 일정 상태는 완료 그대로 */
  const it6=[...d.querySelectorAll('#list .it')].find(x=>x.querySelector('.rowdel').getAttribute('onclick').indexOf('rowDel(6,')===0);
  nS=saves.length; it6.querySelectorAll('.ln:not(.hd) .ck')[0].dispatchEvent(new w.MouseEvent('click',{ bubbles:true })); await tick(); await tick();
  T(saves[nS] && saves[nS].doneYn==='Y' && /<div>1\. 가 취소<\/div>/.test(saves[nS].content), '완료 뒤 줄 따로 바꾸기 : '+(saves[nS]&&saves[nS].content));
  /* 취소 → 줄 전부 취소 · 「-」 → 표시 전부 지움 */
  nS=saves.length; w.doneSet(6,'C'); await tick(); await tick(); await tick();
  T(saves[nS] && saves[nS].doneYn==='C' && /1\. 가 취소</.test(saves[nS].content) && /2\. 나 취소</.test(saves[nS].content) && /<b>다 취소<\/b>/.test(saves[nS].content) && /<div>삼성미팅<\/div>/.test(saves[nS].content), '취소 = 줄 전부 취소 : '+(saves[nS]&&saves[nS].content));
  nS=saves.length; w.doneSet(6,'N'); await tick(); await tick(); await tick();
  T(saves[nS] && saves[nS].doneYn==='N' && /<div>1\. 가<\/div>/.test(saves[nS].content) && /<b>다<\/b>/.test(saves[nS].content), '「-」 = 표시 전부 지움 : '+(saves[nS]&&saves[nS].content));
  /* 창의 [완료] = 편집 칸에 바로 */
  w.edOpen(0); await tick();
  const ED2=d.getElementById('ed'); ED2.innerHTML='<div>미팅</div><div>1. 하나</div><div>2. 둘</div>';
  d.querySelector('#fSt .sb[data-v="Y"]').dispatchEvent(new w.MouseEvent('click',{ bubbles:true }));
  T(ED2.innerHTML==='<div>미팅</div><div>1. 하나 완료</div><div>2. 둘 완료</div>', '창 [완료] → 편집 칸 줄 완료 : '+ED2.innerHTML);
  d.querySelector('#fSt .sb[data-v="C"]').dispatchEvent(new w.MouseEvent('click',{ bubbles:true }));
  T(ED2.innerHTML==='<div>미팅</div><div>1. 하나 취소</div><div>2. 둘 취소</div>', '창 [취소] → 편집 칸 줄 취소 : '+ED2.innerHTML);
  d.querySelector('#fSt .sb[data-v="N"]').dispatchEvent(new w.MouseEvent('click',{ bubbles:true }));
  T(ED2.innerHTML==='<div>미팅</div><div>1. 하나</div><div>2. 둘</div>', '창 [-] → 표시 지움 : '+ED2.innerHTML);
  w.edClose(true);
  /* ── 달력 칸에도 상태 칸 — 고르면 저장(줄 전부 적용) · 창은 안 열림 ── */
  w.load(); await tick(); await tick();
  const evS=[...d.querySelectorAll('#cal .ev.lns')].find(x=>x.getAttribute('onclick').indexOf('edOpen(6,')===0);
  const cs=evS && evS.querySelector('.eh select.st');
  T(!!cs && [...cs.options].filter(o=>!o.hidden).map(o=>o.textContent).join(',')==='완료,취소,-', '달력 상태 칸(완료 / 취소 / -)');
  nS=saves.length; cs.value='Y'; cs.dispatchEvent(new w.Event('change',{ bubbles:true })); await tick(); await tick(); await tick();
  T(saves[nS] && saves[nS].doneYn==='Y' && /1\. 가 완료</.test(saves[nS].content), '달력에서 완료 → 저장·줄 적용');
  T(!d.getElementById('pop').classList.contains('on'), '상태 칸은 창을 안 연다');
  /* ── 이미 완료인 일정 : 줄 하나 취소 → 상태 칸에서 다시 「완료」 = 줄 전부 완료 (그림) ── */
  DB[7]={ schedSeq:7, fromDt:today, toDt:today, schedTm:'', title:'삼성미팅', place:'', doneYn:'Y', hasContent:'Y',
    content:'<div>삼성미팅</div><div>1. 가 완료</div><div>대상미팅</div><div>1. 납품 취소</div><div>2. 품질 완료</div>' };
  w.load(); await tick(); await tick();
  const it7=[...d.querySelectorAll('#list .it')].find(x=>x.querySelector('.rowdel').getAttribute('onclick').indexOf('rowDel(7,')===0);
  const sel7=it7.querySelector('select.st');
  T(sel7.value==='' && sel7.options[sel7.selectedIndex].textContent==='완료', '상태 칸은 지금 상태(완료)를 보인다');
  nS=saves.length; sel7.value='Y'; sel7.dispatchEvent(new w.Event('change',{ bubbles:true })); await tick(); await tick(); await tick();
  T(saves[nS] && /1\. 납품 완료</.test(saves[nS].content) && !/취소/.test(saves[nS].content), '같은 「완료」를 다시 골라도 줄 전부 완료 : '+(saves[nS]&&saves[nS].content));
  /* 창 : 눌린 [완료] 를 또 누르면 다시 적용(풀리지 않음) */
  w.edOpen(0); await tick();
  const ED3=d.getElementById('ed'); ED3.innerHTML='<div>1. 하나 완료</div><div>2. 둘 취소</div>';
  d.querySelector('#fSt .sb[data-v="Y"]').dispatchEvent(new w.MouseEvent('click',{ bubbles:true }));
  d.querySelector('#fSt .sb[data-v="Y"]').dispatchEvent(new w.MouseEvent('click',{ bubbles:true }));
  T(ED3.innerHTML==='<div>1. 하나 완료</div><div>2. 둘 완료</div>' && d.querySelector('#fSt .sb.on').getAttribute('data-v')==='Y', '창 [완료] 두 번 = 완료 그대로·줄 전부 완료 : '+ED3.innerHTML);
  w.edClose(true);
  /* ── 완료한 일정의 🗑 = 막고 안내만(자동으로 취소·삭제하지 않음) ── */
  w.load(); await tick(); await tick();
  globalThis.__dels=[]; w.__alert=''; let confirmed=false; const cb=w._confirmBox; w._confirmBox=function(o){ confirmed=true; };
  w.rowDel(7); await tick(); await tick();
  T(globalThis.__dels.length===0 && !confirmed && /취소<\/b>로 바꾼 뒤/.test(w.__alert||''), '완료 일정 🗑 = 안내만 : '+(w.__alert||'').replace(/<[^>]+>/g,'').slice(0,60));
  /* 취소인 일정은 한 번 묻고 지운다 */
  DB[7].doneYn='C'; w.load(); await tick(); await tick();
  w._confirmBox=function(o){ confirmed=true; o.onOk&&o.onOk(); };
  w.rowDel(7); await tick(); await tick();
  T(confirmed && globalThis.__dels.length===1 && /ceoSchedDel/.test(globalThis.__dels[0]), '취소 일정 🗑 = 묻고 삭제 하나만(상태 바꾸기 없음)');
  w._confirmBox=cb;
  /* ── 삭제 탭 · 복구 ── */
  await tick(); await tick();
  T(d.getElementById('delCnt').textContent==='1', '삭제 탭 건수 1 : '+d.getElementById('delCnt').textContent);
  w.tabGo('del'); await tick();
  const di=d.querySelectorAll('#list .it.del');
  T(di.length===1 && /🗑 11-19 21:10 마스터/.test(di[0].textContent) && !!di[0].querySelector('.rst'), '지운 일정 · 지운 때·사람 · [복구]');
  T(!di[0].querySelector('select.st') && ![...di[0].querySelectorAll('.ln .ck')].some(c=>c.getAttribute('onclick')), '삭제 탭은 읽기만(상태 칸·칩 없음)');
  const calHas=[...d.querySelectorAll('#cal .ev.lns')].some(x=>x.getAttribute('onclick').indexOf('edOpen(7,')===0);
  T(!calHas, '지운 일정은 달력에 없음');
  di[0].querySelector('.rst').dispatchEvent(new w.MouseEvent('click',{ bubbles:true })); await tick(); await tick(); await tick(); await tick();
  T((globalThis.__rst||[])[0]===7 && d.getElementById('delCnt').textContent==='0', '복구 → 삭제 탭 0');
  T([...d.querySelectorAll('#cal .ev.lns')].some(x=>x.getAttribute('onclick').indexOf('edOpen(7,')===0), '복구한 일정이 달력에 돌아옴');
  w.tabGo('mon');
  /* ── 위 줄 「로그인 알림 · 지난 미완료 [n] 일 전까지」 숫자 칸 ── */
  const ld=d.getElementById('lateDays');
  T(ld && ld.type==='number' && ld.value==='0' && /지난 건 안 보임/.test(d.getElementById('lateDaysTip').textContent), '숫자 칸 · 처음 = 0(지난 건 안 보임)');
  ld.value='7'; ld.dispatchEvent(new w.Event('input',{ bubbles:true }));
  T(w.localStorage.getItem('konetCeoLateDays2')==='7' && d.getElementById('lateDaysTip').textContent==='', '7 저장');
  ld.value='0'; ld.dispatchEvent(new w.Event('input',{ bubbles:true }));
  T(w.localStorage.getItem('konetCeoLateDays2')==='0' && /지난 건 안 보임/.test(d.getElementById('lateDaysTip').textContent), '0 저장 · 안내');
  ld.value='999'; ld.dispatchEvent(new w.Event('input',{ bubbles:true }));
  T(w.localStorage.getItem('konetCeoLateDays2')==='365', '상한 365');
  ld.value=''; ld.dispatchEvent(new w.Event('input',{ bubbles:true }));
  T(w.localStorage.getItem('konetCeoLateDays2')==='0', '비우면 0');
  console.log((bad?'✗':'✓')+' sim_ceoSchedLines ok='+ok+' bad='+bad);
  process.exit(bad?1:0);
})().catch(e=>{ console.log('ERR', e); process.exit(1); });
