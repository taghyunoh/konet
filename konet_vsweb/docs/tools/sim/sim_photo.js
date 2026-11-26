// 사진함 시뮬 (2026-11-26 사용자 「모바일에서 찍은 사진을 한꺼번에 PC 에서」 → 「날짜별 · 줄인 사진만 · 1개월 보관」)
//   ① PC 사진함(konet_vsweb mangr/photoBox.jsp) : 날짜 목록 · 묶음별 격자 · 내 묶음만 이름/지우기 · 고르기 → ZIP 폼 · 고른 것 지우기(남의 것 빼고) · 크게 보기 ← → Esc · 이름 고치기 = ui-message 확인창(입력칸)
//   ② 모바일 사진 올리기(konet_vsapp m/photo.jsp) : 담기 · 묶음 한 번 만들고 한 장씩 올림 · 실패한 것만 같은 묶음에 다시 · 끝나면 비움
//   실행 : NODE_PATH=<jsdom 있는 node_modules> node docs/tools/sim/sim_photo.js
const fs=require('fs'), path=require('path'); const { JSDOM }=require('jsdom');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
function page(file){
  const s=fs.readFileSync(file,'utf8').replace(/\r\n/g,'\n');
  const body=/<body[^>]*>([\s\S]*?)<script>/.exec(s)[1];
  const js=/<script>([\s\S]*?)<\/script>\s*<\/body>/.exec(s)[1];
  return { body, js };
}
(async()=>{
  /* ───── ① PC 사진함 ───── */
  {
    const P=page(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/photoBox.jsp'));
    const dom=new JSDOM('<body>'+P.body.replace(/<%--[\s\S]*?--%>/g,'')+'</body>',{ runScripts:'outside-only', url:'http://localhost/' });
    const w=dom.window, d=w.document, calls=[];
    const DATA={ ok:true, frDt:'20261120', toDt:'20261126', cutDt:'20261026', keepMonths:1, me:'u1', admin:false,
      days:[{grpDt:'20261126',grpCnt:2,photoCnt:3},{grpDt:'20261125',grpCnt:1,photoCnt:1}],
      groups:[{grpSeq:2,grpDt:'20261126',title:'선피앤피 입고',photoCnt:2,regUser:'u1',regNm:'홍길동',regDttm:'2026-11-26 14:32:10'},
              {grpSeq:1,grpDt:'20261126',title:'',photoCnt:1,regUser:'u2',regNm:'김철수',regDttm:'2026-11-26 09:01:00'}],
      photos:[{photoSeq:11,grpSeq:2,sortNo:0,imgW:1600,imgH:1200},{photoSeq:12,grpSeq:2,sortNo:1},{photoSeq:13,grpSeq:1,sortNo:0}] };
    w.fetch=(url,o)=>{ calls.push({url, body:o&&o.body}); const j= /list\.do/.test(url) ? DATA : { ok:true };
      return Promise.resolve({ ok:true, status:200, text:()=>Promise.resolve(JSON.stringify(j)) }); };
    let conf=null, alerts=[], toasts=[];
    w._confirmBox=o=>{ conf=o; }; w._alertBox=m=>alerts.push(m); w._toast=m=>toasts.push(m);
    const forms=[]; const realSubmit=w.HTMLFormElement.prototype.submit; w.HTMLFormElement.prototype.submit=function(){ forms.push({ action:this.action, target:this.target, seqs:this.querySelector('input[name=seqs]').value }); };
    w.eval(P.js.replace(/\$\{pageContext\.request\.contextPath\}/g,'/konet'));
    await sleep(20);
    const main=d.getElementById('main');
    T(calls[0] && /\/konet\/photo\/list\.do/.test(calls[0].url) && /frDt=\d{8}&toDt=\d{8}/.test(calls[0].body), '처음 열면 최근 7일로 목록(날짜 8자리)');
    T(d.querySelectorAll('#days .d').length===2 && /11\/26/.test(d.getElementById('days').textContent) && /2묶음 · 3장/.test(d.getElementById('days').textContent), '왼쪽 날짜 목록 = 묶음 수 · 사진 수');
    T(d.querySelectorAll('.grp').length===2 && d.querySelectorAll('.ph').length===3, '묶음 2 · 사진 3 격자');
    T(/thumb=1&seq=11$/.test(d.querySelector('.ph img').getAttribute('src')) && d.querySelector('.ph img').getAttribute('loading')==='lazy', '작은 그림을 따로 부른다(lazy)');
    const g0=d.querySelectorAll('.grp')[0], g1=d.querySelectorAll('.grp')[1];
    T(/🗑 묶음 지우기/.test(g0.textContent) && /✏ 이름/.test(g0.textContent) && !/🗑 묶음 지우기/.test(g1.textContent), '내가 올린 묶음만 이름 고치기·지우기');
    T(/\(이름 없음\)/.test(g1.textContent) && /김철수/.test(g1.textContent), '이름 없는 묶음 표시 · 올린 사람');
    T(d.getElementById('cutLab').textContent==='2026-10-26', '보관 경계 날짜 안내');
    T(d.getElementById('zipBtn').disabled && d.getElementById('delBtn').disabled, '고른 것 없으면 ZIP·지우기 잠김');
    // 고르기
    w.pbTog(11); w.pbTog(13);
    T(d.querySelectorAll('.ph.sel').length===2 && !d.getElementById('zipBtn').disabled && /\(2\)/.test(d.getElementById('zipBtn').textContent) && /고른 2장/.test(d.getElementById('cnt').textContent), '두 장 고르면 표시·단추 풀림·개수');
    w.pbZip();
    T(forms.length===1 && /\/konet\/photo\/zip\.do$/.test(forms[0].action) && forms[0].target==='pbDlFrame' && forms[0].seqs==='11,13', 'ZIP = 숨은 창으로 폼 POST(seqs)');
    // 고른 것 지우기 — 남의 것(13) 빼고
    w.pbDelSel();
    T(conf && /1장/.test(conf.msg) && /다른 사람이 올린 1장은 빼고/.test(conf.msg), '지우기 확인창 = 내 것만 · 남의 것 빼고 안내');
    const before=calls.length; conf.onOk(); await sleep(30);
    const dels=calls.slice(before).filter(c=>/del\.do/.test(c.url));
    T(dels.length===1 && JSON.parse(dels[0].body).photoSeq===11, '지우기 요청은 내 사진(11)만');
    T(calls.slice(before).some(c=>/list\.do/.test(c.url)), '지운 뒤 다시 불러온다');
    await sleep(20);
    // 남의 것만 골랐을 때
    conf=null; alerts=[]; w.pbTog(13); w.pbDelSel();
    T(!conf && /올린 사람이나 관리자/.test(alerts[0]||''), '남의 사진만 고르면 안내만(지우지 않음)');
    // 전체 선택 토글
    w.pbSelAll(); T(d.querySelectorAll('.ph.sel').length===3, '전체 선택'); w.pbSelAll(); T(d.querySelectorAll('.ph.sel').length===0, '다시 누르면 전체 풀림');
    w.pbSelGrp(2); T(d.querySelectorAll('.ph.sel').length===2, '이 묶음 선택');
    // 크게 보기
    w.pbVwOpen(0);
    const vw=d.getElementById('vw'), im=d.getElementById('vwImg');
    T(!vw.hidden && /img\.do\?seq=11$/.test(im.getAttribute('src')) && /선피앤피 입고/.test(d.getElementById('vwCap').textContent) && /1 \/ 2/.test(d.getElementById('vwCap').textContent), '크게 보기 = 큰 그림 · 묶음 이름 · 1/2');
    d.dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowRight'})); d.dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowRight'}));
    T(/seq=13$/.test(im.getAttribute('src')) && d.getElementById('vwDel').style.display==='none', '→ 로 넘김 · 남의 사진이면 지우기 단추 숨김');
    d.dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowRight'}));
    T(/seq=11$/.test(im.getAttribute('src')), '끝에서 → 면 처음으로');
    d.dispatchEvent(new w.KeyboardEvent('keydown',{key:'Escape'}));
    T(vw.hidden, 'Esc 로 닫힘');
    // 이름 고치기 = 확인창 + 입력칸
    conf=null; w.pbTitle(2);
    T(conf && /<input id="pbTitleIn"/.test(conf.msg) && /value="선피앤피 입고"/.test(conf.msg), '이름 고치기 = ui-message 확인창 안 입력칸(브라우저 prompt 아님)');
    // 이름에 꺾쇠가 있어도 안전하게
    DATA.groups[0].title='<b>x</b>'; w.pbLoad(); await sleep(20);
    T(!d.querySelector('.grp b') && /&lt;b&gt;x/.test(d.getElementById('main').innerHTML), '묶음 이름은 글자로(esc)');
    // 거르기
    d.getElementById('q').value='김철수'; w.pbDraw();
    T(d.querySelectorAll('.grp').length===1 && d.querySelectorAll('.ph').length===1, '올린 사람으로 거르기');
    // 실패 안내
    w.fetch=()=>Promise.resolve({ ok:false, status:500, text:()=>Promise.resolve('Invalid object name TBL_PHOTO_GRP') });
    w.pbLoad(); await sleep(20);
    T(/불러오지 못했습니다/.test(main.textContent) && /20261126_photo\.sql/.test(main.textContent), '표가 없으면 DDL 안내');
    w.HTMLFormElement.prototype.submit=realSubmit;
  }
  /* ───── ② 모바일 사진 올리기 ───── */
  {
    const P=page(path.join(__dirname,'../../../../konet_vsapp/src/main/webapp/WEB-INF/jsp/m/photo.jsp'));
    const dom=new JSDOM('<body>'+P.body+'</body>',{ runScripts:'outside-only', url:'http://localhost/konetapp/m/photo.do' });
    const w=dom.window, d=w.document, sent=[]; let failSort=-1, grpN=0, alerts=[], toasts=[];
    w.URL.createObjectURL=()=>'blob:x'; w.URL.revokeObjectURL=()=>{};
    w._alertBox=m=>alerts.push(m); w._toast=m=>toasts.push(m);
    w.M={ CTX:'/konetapp', $:id=>d.getElementById(id), esc:s=>String(s==null?'':s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])),
      json:(url,o)=>{ sent.push({url,o}); if(/grpNew/.test(url)){ grpN++; return Promise.resolve({ok:true,grpSeq:77}); } if(o.sortNo===failSort) return Promise.resolve({ok:false,msg:'사진이 너무 큽니다'}); return Promise.resolve({ok:true,photoSeq:100+o.sortNo}); },
      form:(url)=>Promise.resolve({ ok:true, groups:[{grpSeq:77,grpDt:'20261126',title:'입고',regNm:'홍'}], photos:[{photoSeq:100,grpSeq:77}] }),
      errMsg:e=>e.message, ymd:()=>'2026-11-26', addDay:()=>'2026-11-20', lblDay:()=>'11월 26일 (목)', tabbar:()=>{}, session:()=>Promise.resolve({ok:true}) };
    w.eval(P.js);
    w.prep=()=>Promise.resolve({ img:'data:image/jpeg;base64,/9j/AAAA', w:1600, h:1200, thumb:'data:image/jpeg;base64,/9j/BB' });   // 캔버스 없이
    await sleep(20);
    const btn=d.getElementById('upBtn');
    T(btn.disabled && /최근 7일/.test(d.body.textContent) && /입고/.test(d.getElementById('recent').textContent), '처음 = 올리기 잠김 · 최근 올린 사진');
    const mk=(n)=>({ name:n, type:'image/jpeg', lastModified:new Date(2026,10,26,9,5,7).getTime() });
    w.addFiles([mk('a.jpg'), mk('b.jpg'), { name:'x.pdf', type:'application/pdf' }]); w.addFiles([mk('c.jpg')]);
    T(d.querySelectorAll('.qgrid .q').length===3 && /\(3장\)/.test(btn.textContent) && !btn.disabled, '사진만 담긴다(PDF 제외) · 여러 번 담으면 이어 붙음');
    w.rm(2); T(d.querySelectorAll('.qgrid .q').length===2, '✕ 로 빼기');
    w.addFiles([mk('c.jpg')]);
    d.getElementById('ttl').value='  선피앤피 입고 ';
    failSort=1; w.upload(); await sleep(40);
    const g=sent.filter(s=>/grpNew/.test(s.url)), u=sent.filter(s=>/upload/.test(s.url));
    T(g.length===1 && g[0].o.title==='선피앤피 입고', '묶음은 한 번 · 이름 앞뒤 공백 정리');
    T(u.length===3 && u.every(s=>s.o.grpSeq===77) && u.map(s=>s.o.sortNo).join()==='0,1,2', '사진은 한 장씩(차례 0,1,2) 같은 묶음으로');
    T(u[0].o.shotDttm==='2026-11-26 09:05:07' && u[0].o.fileNm==='a.jpg' && /^data:image\/jpeg/.test(u[0].o.img) && u[0].o.w===1600, '찍은 때·파일 이름·줄인 그림·크기를 보낸다');
    T(d.querySelectorAll('.qgrid .q.ok').length===2 && d.querySelectorAll('.qgrid .q.bad').length===1 && /2<\/b>장 올렸고/.test(alerts[0]||'') && /너무 큽니다/.test(alerts[0]||''), '실패한 1장 = 빨간 테두리 · 안내(이유)');
    T(/\(1장\)/.test(btn.textContent) && !btn.disabled, '남은 1장만 다시 올리기');
    failSort=-1; sent.length=0; w.upload(); await sleep(40);
    T(!sent.some(s=>/grpNew/.test(s.url)) && sent.length===1 && sent[0].o.grpSeq===77 && sent[0].o.sortNo===1, '다시 올리기 = 같은 묶음에 실패한 것만');
    T(d.querySelectorAll('.qgrid .q').length===0 && d.getElementById('ttl').value==='' && btn.disabled && /올렸습니다/.test(toasts.join()), '다 올리면 비우고 알림');
    // 다음 올리기는 새 묶음
    sent.length=0; w.addFiles([mk('d.jpg')]); w.upload(); await sleep(40);
    T(sent.filter(s=>/grpNew/.test(s.url)).length===1, '다음 올리기는 새 묶음');
    // 묶음 만들기 실패
    w.M.json=(url)=>/grpNew/.test(url) ? Promise.reject(new Error('로그인이 끊겼습니다.')) : Promise.resolve({ok:true});
    alerts=[]; w.addFiles([mk('e.jpg')]); w.upload(); await sleep(40);
    T(/올리지 못했습니다/.test(alerts[0]||'') && !btn.disabled && d.querySelectorAll('.qgrid .q').length===1, '묶음 실패 = 안내 · 담은 사진은 그대로');
  }
  console.log((bad?'✗':'✓')+' sim_photo : 통과 '+ok+' · 실패 '+bad);
  process.exit(bad?1:0);
})();
