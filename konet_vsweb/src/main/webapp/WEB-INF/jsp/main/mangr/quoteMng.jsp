<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>견적서 관리</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 원본 보기(시트를 병합 살려 표로) — 전역 XLSX --%>
<!--
  견적서 관리 (2026-09-17 신설 — 「견적서 엑셀을 입고예약서처럼 올리고 저장, 일자·담당자·문서번호로 관리」) — 매출 관리 ▸ 견적서 관리. 셸 iframe(logiFrame) 화면.
  · 우리가 낸 견적서 엑셀(xls/xlsx, 표본 260729-1(900cc, 500cc).xls)을 끌어다 놓으면 서버(POI)가 문서번호·견적일·수신·담당자·유효기간·품목 줄·비고를 읽어 미리보기를 준다.
    머리표(문서번호·견적일·수신·담당자)는 미리보기에서 고칠 수 있다(관리 기준). [저장] = TBL_QUOTE_MST/DTL + 원본 파일(base64).
  · 같은 문서번호를 다시 올리면 앞의 것을 대체한다. 목록은 견적일 기간·담당자·문서번호/수신/품명 검색. 줄을 누르면 아래에 품목 줄. [원본 내려받기]·[선택 삭제].
  · 자료 /mangr/quoteParse.do(base64) · 저장 /mangr/quoteSave.do · 목록 /mangr/quoteList.do · 줄 /mangr/quoteDetail.do · 원본 /mangr/quoteFile.do · 삭제 /mangr/quoteDelete.do
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .bar input[type=date], .bar input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ color:var(--red); }
  .lnk{ height:26px; padding:0 8px; font-size:12px; }
  .lnk.on{ background:#eef4f2; border-color:#9fc9bf; color:var(--teal); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .card .hd .sp{ margin-left:auto; }
  .drop{ margin:12px; border:2px dashed #b9d3cc; border-radius:10px; background:#f6fbfa; padding:20px; text-align:center; color:#4b6b63; cursor:pointer; }
  .drop.on{ background:#e3f2ee; border-color:var(--teal); }
  .drop b{ color:var(--teal); }
  .drop small{ display:block; margin-top:5px; color:#7c8e98; font-size:12px; }
  .tw{ overflow:auto; max-height:46vh; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 8px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:4px 8px; vertical-align:middle; text-align:center; white-space:nowrap; }
  table.g td.l{ text-align:left; white-space:normal; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g tr:hover td{ background:#f7faf9; }
  table.g tr.sel td{ background:#e3f2ee; }
  table.g tr.tap{ cursor:pointer; }
  table.g input[type=date], table.g input[type=text]{ height:28px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; background:#fff; }
  table.g input[type=checkbox]{ width:16px; height:16px; accent-color:var(--teal); cursor:pointer; }
  .doc{ margin:0 12px 12px; border:1px solid var(--bd); border-radius:8px; overflow:hidden; }
  .doc .dh{ display:flex; gap:8px 14px; align-items:center; flex-wrap:wrap; padding:8px 12px; background:#f6fbfa; border-bottom:1px solid #eef1f5; font-size:13px; }
  .doc .dh label{ display:flex; align-items:center; gap:5px; color:#37475a; font-weight:700; white-space:nowrap; }
  .doc .dh input[type=text]{ height:28px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; }
  .doc .dh input[type=date]{ height:28px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; }
  .doc .df{ padding:6px 12px; font-size:12.5px; color:#5a6b7a; border-top:1px solid #eef1f5; white-space:pre-wrap; }
  .bd{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .bd.xls{ background:#e3f2ee; color:#0f6b5e; } .bd.warn{ background:#fdecec; color:var(--red); } .bd.dup{ background:#fdf0d5; color:#9a5b05; }
  .dim{ color:#8a98a8; }
  .empty{ padding:28px; text-align:center; color:#8a98a8; }
  .err{ margin:0 12px 12px; padding:8px 12px; border-radius:8px; background:#fdecec; color:#8a2a22; font-size:12.5px; line-height:1.7; }
  .tot{ font-size:13px; color:#37475a; font-weight:700; }
  .tot b{ color:var(--teal); }
  .docview{ margin:0 12px 10px; border:1px solid var(--bd); border-radius:8px; overflow:auto; max-height:60vh; background:#fff; position:relative; }
  .docx{ position:sticky; top:6px; float:right; margin:6px 8px 0 0; z-index:2; height:26px; padding:0 9px; font-size:12px; }
  .xh{ padding:8px 10px; }
  .xh table{ border-collapse:collapse; font-size:14px; }
  .xh td{ border:1px solid #d9e0e7; padding:3px 7px; white-space:pre-wrap; vertical-align:middle; min-width:14px; max-width:520px; line-height:1.35; }
  .dtl{ margin:0 12px 12px; border:1px solid var(--bd); border-radius:8px; overflow:hidden; }
  .dtl .dh{ display:flex; gap:8px 14px; align-items:center; flex-wrap:wrap; padding:8px 12px; background:#f6fbfa; border-bottom:1px solid #eef1f5; font-size:13px; }
  .dtl .dh b{ color:var(--teal); }
</style>
</head>
<body>
<div class="wrap">
  <h2>📄 견적서 관리</h2>

  <div class="card">
    <div class="hd">📥 견적서 올리기 <small>— 우리가 낸 견적서 엑셀(xls/xlsx). 여러 개를 한 번에. 미리보기에서 문서번호·견적일·담당자를 확인하고 [💾 저장]</small>
      <span class="sp tot" id="pvTot"></span>
    </div>
    <div class="drop" id="drop" onclick="document.getElementById('file').click()">
      📄 <b>견적서 엑셀</b>을 여기에 끌어다 놓거나 눌러서 고르세요
      <small>문서번호 · 견적일 · 수신 · 담당자 · 품목(품명·규격·수량·단가·금액·비고)을 읽습니다. 같은 문서번호가 이미 있으면 새로 올린 것으로 대체합니다.</small>
    </div>
    <input type="file" id="file" accept=".xls,.xlsx" multiple hidden onchange="pickFiles(this.files); this.value='';">
    <div id="pvErr"></div>
    <div id="docView" class="docview" hidden></div>
    <div id="pvWrap" hidden>
      <div id="pvDocs"></div>
      <div class="bar" style="padding:0 12px 12px">
        <button class="btn btn-teal" id="saveBtn" onclick="save()">💾 저장</button>
        <button class="btn" onclick="pvClear()">✕ 미리보기 비우기</button>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="hd">📋 견적서 목록 <small>— 견적일 기준</small>
      <span class="bar" style="margin-left:8px">
        <input type="date" id="fr"> ~ <input type="date" id="to">
        <input type="text" id="mgr" placeholder="담당자" style="width:110px">
        <input type="text" id="q" placeholder="문서번호 · 수신 · 품명" style="width:200px" onkeydown="if(event.keyCode===13) load()">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn btn-red" onclick="del()">🗑 선택 삭제</button>
      </span>
      <span class="sp tot" id="lsTot"></span>
    </div>
    <div class="tw">
      <table class="g">
        <thead><tr>
          <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th>
          <th>견적일</th><th>문서번호</th><th>수신</th><th>담당자</th><th>품목</th><th>줄</th><th>금액(부가세 별도)</th><th>유효기간</th><th>원본</th><th>등록</th>
        </tr></thead>
        <tbody id="lsBody"><tr><td colspan="11" class="empty">조회 중…</td></tr></tbody>
      </table>
    </div>
    <div id="lsDoc" class="docview" hidden></div>
    <div id="dtlWrap" hidden></div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _pv=[], _ls=[], _docs={}, _docOpen='', _sel=null;
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ var x=n(v); return (Math.round(x*100)/100).toLocaleString(); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin',
  headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }
function ok(m){ _alertBox(m,{icon:'✅'}); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function ask(m, okText){ return new Promise(function(res){ _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', onOk:function(){res(true);}, onCancel:function(){res(false);} }); }); }

/* ── 파일 → 서버 해석 ── */
(function(){
  var d=document.getElementById('drop');
  ['dragenter','dragover'].forEach(function(t){ d.addEventListener(t,function(e){ e.preventDefault(); d.classList.add('on'); }); });
  ['dragleave','drop'].forEach(function(t){ d.addEventListener(t,function(e){ e.preventDefault(); d.classList.remove('on'); }); });
  d.addEventListener('drop',function(e){ if(e.dataTransfer && e.dataTransfer.files) pickFiles(e.dataTransfer.files); });
})();
function readB64(f){ return new Promise(function(res,rej){ var r=new FileReader(); r.onload=function(){ res(String(r.result||'')); }; r.onerror=function(){ rej(new Error(f.name+' 을 읽지 못했습니다')); }; r.readAsDataURL(f); }); }
var DROP_HTML=document.getElementById('drop').innerHTML;
function pickFiles(list){
  var fs=Array.prototype.slice.call(list||[]).filter(function(f){ return /\.(xlsx|xls)$/i.test(f.name); });
  if(!fs.length){ _alertBox('엑셀 파일(xls·xlsx)을 골라 주세요.',{icon:'⚠️'}); return; }
  var big=fs.filter(function(f){ return f.size>5*1024*1024; });
  if(big.length){ _alertBox(big[0].name+' 이 5MB 를 넘습니다.',{icon:'⚠️'}); return; }
  var dr=document.getElementById('drop'); dr.innerHTML='⏳ 읽는 중… ('+fs.length+'개)';
  fs.forEach(docKeep);
  Promise.all(fs.map(function(f){ return readB64(f).then(function(b){ return { name:f.name, b64:b }; }); }))
    .then(function(files){ return post('/mangr/quoteParse.do', { files:files }, true); })
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t||('HTTP '+r.status)); return JSON.parse(t); }); })
    .then(function(j){
      var docs=(j&&j.docs)||[], errs=(j&&j.errors)||[];
      docs.forEach(function(q){ q._on=true; _pv.push(q); });
      document.getElementById('pvErr').innerHTML = errs.length ? '<div class="err">'+errs.map(esc).join('<br>')+'</div>' : '';
      pvRender();
      if(docs.length){ ok('견적서 <b>'+docs.length+'</b>건을 읽었습니다.<br><span style="font-size:13px;color:#3d4d5c">아래 <b>미리보기</b>에서 문서번호·견적일·담당자·품목을 확인하고 [💾 저장]을 누르세요.</span>'); try{ document.getElementById('pvWrap').scrollIntoView({block:'nearest'}); }catch(e){} }
    })
    .catch(function(e){ err('파일을 읽지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
    .then(function(){ dr.innerHTML=DROP_HTML; });
}
function pvRender(){
  var w=document.getElementById('pvWrap'), box=document.getElementById('pvDocs');
  w.hidden = !_pv.length;
  var dups={}; _ls.forEach(function(x){ dups[String(x.docNo||'').trim()]=1; });
  box.innerHTML=_pv.map(function(q,i){
    var lines=q.lines||[], sum=0; lines.forEach(function(l){ sum+=n(l.amt); });
    var dup=!!dups[String(q.docNo||'').trim()];
    return '<div class="doc">'
      +'<div class="dh"><input type="checkbox"'+(q._on?' checked':'')+' onchange="_pv['+i+']._on=this.checked; pvTot()" title="저장할 견적서">'
      +'<span class="bd xls" title="'+esc(q.fileNm)+'">'+esc(q.fileNm)+'</span>'
      +'<label>문서번호 <input type="text" value="'+esc(q.docNo)+'" style="width:150px;font-weight:800" oninput="_pv['+i+'].docNo=this.value.trim(); pvTot()"></label>'
      +'<label>견적일 <input type="date" value="'+d10(q.quoteDt)+'" onchange="_pv['+i+'].quoteDt=this.value"></label>'
      +'<label>수신 <input type="text" value="'+esc(q.recvNm)+'" style="width:130px" oninput="_pv['+i+'].recvNm=this.value"></label>'
      +'<label>담당자 <input type="text" value="'+esc(q.mgrNm)+'" style="width:120px" oninput="_pv['+i+'].mgrNm=this.value"></label>'
      +'<label>유효기간 <input type="text" value="'+esc(q.validTxt)+'" style="width:140px" oninput="_pv['+i+'].validTxt=this.value"></label>'
      +(dup?'<span class="bd dup" title="같은 문서번호가 이미 저장돼 있습니다 — 저장하면 새로 올린 것으로 대체됩니다">대체</span>':'')
      +(!q.docNo?'<span class="bd warn">문서번호 없음</span>':'')
      +'<span style="margin-left:auto" class="tot">품목 <b>'+lines.length+'</b>줄 · 합계 <b>'+fmt(sum)+'</b>원</span>'
      +(_docs[q.fileNm]?'<button class="btn lnk'+(_docOpen===q.fileNm?' on':'')+'" onclick="docShow(this.getAttribute(\'data-n\'))" data-n="'+esc(q.fileNm)+'" title="올린 엑셀을 그대로 봅니다">📄 원본 보기</button>':'')
      +'</div>'
      +(q.titleTxt?'<div class="df" style="border-top:0;color:#37475a">'+esc(q.titleTxt)+'</div>':'')
      +'<div class="tw" style="max-height:none"><table class="g"><thead><tr><th>No</th><th>품명</th><th>규격</th><th>Box</th><th>수량</th><th>단위</th><th>단가</th><th>금액</th><th>비고</th></tr></thead><tbody>'
      +(lines.length?lines.map(function(l){ return '<tr><td>'+esc(l.rowNo)+'</td><td class="l">'+esc(l.prodNm)+'</td><td class="l">'+esc(l.spec)+'</td><td class="r">'+(l.boxQty!=null?fmt(l.boxQty):'')+'</td><td class="r"><b>'+fmt(l.qty)+'</b></td><td>'+esc(l.unit)+'</td><td class="r">'+fmt(l.unitPrice)+'</td><td class="r"><b>'+fmt(l.amt)+'</b></td><td class="l">'+esc(l.remark)+'</td></tr>'; }).join('')
        :'<tr><td colspan="9" class="empty">품목 줄을 읽지 못했습니다 — 품명·수량·단가 머리글이 있는지 원본을 확인하세요.</td></tr>')
      +'</tbody></table></div>'
      +(q.remark?'<div class="df">비고 : '+esc(q.remark)+'</div>':'')
      +'</div>';
  }).join('');
  pvTot();
}
function pvTot(){ var on=_pv.filter(function(q){ return q._on; }); document.getElementById('pvTot').innerHTML = _pv.length ? ('저장 대상 <b>'+on.length+'</b>/'+_pv.length+'건') : ''; }
function pvClear(){ _pv=[]; document.getElementById('pvErr').innerHTML=''; docShow(''); _docs={}; pvRender(); }
function save(){
  var docs=_pv.filter(function(q){ return q._on; });
  if(!docs.length){ _alertBox('저장할 견적서를 체크하세요.',{icon:'ℹ️'}); return; }
  var noDoc=docs.filter(function(q){ return !String(q.docNo||'').trim(); });
  if(noDoc.length){ _alertBox('문서번호가 빈 견적서가 '+noDoc.length+'건 있습니다 — 미리보기에서 적어 주세요.',{icon:'⚠️'}); return; }
  var dups={}; _ls.forEach(function(x){ dups[String(x.docNo||'').trim()]=1; });
  var rep=docs.filter(function(q){ return dups[String(q.docNo).trim()]; }).map(function(q){ return q.docNo; });
  var go = rep.length ? ask('같은 문서번호가 이미 있습니다 — <b>'+esc(rep.join(', '))+'</b><br><span style="font-size:13px;color:#3d4d5c">저장하면 앞의 것을 새로 올린 것으로 <b>대체</b>합니다(앞의 것은 이력으로 남습니다).</span>','대체 저장') : Promise.resolve(true);
  go.then(function(y){ if(!y) return;
    var b=document.getElementById('saveBtn'); b.disabled=true;
    post('/mangr/quoteSave.do', { docs: docs.map(function(q){ return { docNo:q.docNo, quoteDt:q.quoteDt, recvNm:q.recvNm, mgrNm:q.mgrNm, validTxt:q.validTxt, titleTxt:q.titleTxt, remark:q.remark, fileNm:q.fileNm, fileB64:q.fileB64, lines:q.lines }; }) }, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(t){
        ok('견적서 <b>'+esc(String(t).split('|')[0])+'</b>건을 저장했습니다.');
        docs.forEach(function(q){ var d=d10(q.quoteDt), fr=document.getElementById('fr'), to=document.getElementById('to'); if(d && (!fr.value || d<fr.value)) fr.value=d; if(d && (!to.value || d>to.value)) to.value=d; });
        pvClear(); load();
      })
      .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
      .then(function(){ b.disabled=false; });
  });
}

/* ── 원본 보기 — 엑셀 첫 시트를 병합 살려 표로(전역 XLSX) ── */
function docKeep(f){
  var nm=f.name, r=new FileReader();
  r.onload=function(){
    try{
      var wb=XLSX.read(new Uint8Array(r.result), { type:'array' }), ws=wb.Sheets[wb.SheetNames[0]];
      var html=XLSX.utils.sheet_to_html(ws, { editable:false, header:'', footer:'' }); var mt=/<table[\s\S]*<\/table>/i.exec(html);
      _docs[nm]={ html: mt ? mt[0] : html, sheet:wb.SheetNames[0] };
    }catch(e){ _docs[nm]={ err:String(e&&e.message||e) }; }
    if(_pv.length) pvRender();
  };
  r.readAsArrayBuffer(f);
}
function docShow(nm){
  var v=document.getElementById('docView');
  if(!nm || _docOpen===nm){ _docOpen=''; v.hidden=true; v.innerHTML=''; if(nm) pvRender(); return; }
  var d=_docs[nm]; if(!d) return;
  _docOpen=nm; v.hidden=false;
  var closeBtn='<button class="btn docx" onclick="docShow(\''+esc(nm).replace(/'/g,'&#39;')+'\')">✕ 원본 닫기</button>';
  v.innerHTML = closeBtn + (d.err ? '<div class="err" style="margin:10px">원본을 펼치지 못했습니다 — '+esc(d.err)+'</div>' : '<div class="dim" style="padding:6px 10px 0;font-size:12px">'+esc(nm)+' · 시트 「'+esc(d.sheet)+'」</div><div class="xh">'+d.html+'</div>');
  pvRender();
  try{ v.scrollIntoView({block:'nearest'}); }catch(e){}
}

/* ── 목록 ── */
function load(){
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value, mgr=document.getElementById('mgr').value.trim(), q=document.getElementById('q').value.trim();
  var tb=document.getElementById('lsBody'); tb.innerHTML='<tr><td colspan="11" class="empty">조회 중…</td></tr>';
  _sel=null; document.getElementById('dtlWrap').hidden=true;
  post('/mangr/quoteList.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)+'&mgrNm='+encodeURIComponent(mgr)+'&findData='+encodeURIComponent(q))
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return JSON.parse(t); }); })
    .then(function(j){ _ls=(j&&j.data)||[]; lsRender(); if(_pv.length) pvRender(); })
    .catch(function(e){ tb.innerHTML='<tr><td colspan="11" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsRender(){
  var tb=document.getElementById('lsBody');
  document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="11" class="empty">조건에 맞는 견적서가 없습니다.</td></tr>'; document.getElementById('lsTot').innerHTML=''; return; }
  var amt=0;
  tb.innerHTML=_ls.map(function(x,i){
    amt+=n(x.supplyAmt);
    return '<tr class="tap'+(_sel===x.quoteSeq?' sel':'')+'" onclick="if(event.target.tagName!==\'INPUT\' && event.target.tagName!==\'BUTTON\') detail('+i+')">'
      +'<td><input type="checkbox" class="lchk" data-i="'+i+'"></td>'
      +'<td>'+d10(x.quoteDt)+'</td><td><b>'+esc(x.docNo)+'</b></td><td>'+esc(x.recvNm)+'</td><td>'+esc(x.mgrNm)+'</td>'
      +'<td class="l" style="max-width:320px">'+esc(x.firstNm)+(n(x.lineCnt)>1?' <span class="dim">외 '+(n(x.lineCnt)-1)+'</span>':'')+'</td>'
      +'<td class="r">'+fmt(x.lineCnt)+'</td><td class="r"><b>'+fmt(x.supplyAmt)+'</b></td><td class="dim">'+esc(x.validTxt)+'</td>'
      +'<td>'+(x.hasFile==='Y'?'<button class="btn lnk" onclick="viewFile('+x.quoteSeq+', this.getAttribute(\x27data-n\x27))" data-n="'+esc(x.fileNm)+'" title="올린 엑셀 양식을 화면에서 봅니다 ('+esc(x.fileNm)+')">📄 원본</button>':'<span class="dim">—</span>')+'</td>'
      +'<td class="dim">'+esc(String(x.regDttm||'').slice(0,16))+(x.regUser?'<br>'+esc(x.regUser):'')+'</td></tr>';
  }).join('');
  document.getElementById('lsTot').innerHTML='<b>'+_ls.length+'</b>건 · 금액 <b>'+fmt(amt)+'</b>원';
}
function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function dl(seq){ window.open(CTX+'/mangr/quoteFile.do?quoteSeq='+seq, '_blank'); }
/* 원본을 화면에서 — 보관한 엑셀을 받아 첫 시트를 병합 살려 표로(전역 XLSX). 창 안에 [내려받기]. (2026-09-17 「원본 누르면 엑셀 양식이 뜨나요」) */
var _lsDocSeq=null;
function viewFile(seq, nm){
  var v=document.getElementById('lsDoc');
  if(_lsDocSeq===seq){ _lsDocSeq=null; v.hidden=true; v.innerHTML=''; return; }
  _lsDocSeq=seq; v.hidden=false; v.innerHTML='<div class="dim" style="padding:14px">원본을 불러오는 중…</div>';
  fetch(CTX+'/mangr/quoteFile.do?quoteSeq='+seq, { credentials:'same-origin' })
    .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.arrayBuffer(); })
    .then(function(ab){
      if(_lsDocSeq!==seq) return;
      var wb=XLSX.read(new Uint8Array(ab), { type:'array' }), ws=wb.Sheets[wb.SheetNames[0]];
      var html=XLSX.utils.sheet_to_html(ws, { editable:false, header:'', footer:'' }); var mt=/<table[\s\S]*<\/table>/i.exec(html);
      v.innerHTML='<div style="position:sticky;top:0;z-index:2;display:flex;gap:8px;align-items:center;padding:6px 10px;background:#f6fbfa;border-bottom:1px solid #eef1f5"><span class="dim" style="font-size:12.5px">'+esc(nm||'')+' · 시트 「'+esc(wb.SheetNames[0])+'」</span>'
        +'<button class="btn lnk" style="margin-left:auto" onclick="dl('+seq+')">⬇ 내려받기</button><button class="btn lnk" onclick="viewFile('+seq+')">✕ 닫기</button></div>'
        +'<div class="xh">'+(mt?mt[0]:html)+'</div>';
      try{ v.scrollIntoView({block:'nearest'}); }catch(e){}
    })
    .catch(function(e){ v.innerHTML='<div class="err" style="margin:10px">원본을 펼치지 못했습니다 — '+esc(e.message)+' <button class="btn lnk" onclick="dl('+seq+')">⬇ 내려받기</button></div>'; });
}
function detail(i){
  var x=_ls[i]; if(!x) return; _sel=x.quoteSeq; lsRender();
  var w=document.getElementById('dtlWrap'); w.hidden=false;
  w.innerHTML='<div class="dtl"><div class="dh"><b>'+esc(x.docNo)+'</b> · '+d10(x.quoteDt)+' · '+esc(x.recvNm)+' · 담당 '+esc(x.mgrNm)+(x.validTxt?' · '+esc(x.validTxt):'')+'<span style="margin-left:auto" class="dim">불러오는 중…</span></div></div>';
  post('/mangr/quoteDetail.do','quoteSeq='+encodeURIComponent(x.quoteSeq))
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(_sel!==x.quoteSeq) return;
      var ls=(j&&j.data)||[], sum=0; ls.forEach(function(l){ sum+=n(l.amt); });
      w.innerHTML='<div class="dtl"><div class="dh"><b>'+esc(x.docNo)+'</b> · '+d10(x.quoteDt)+' · '+esc(x.recvNm)+' · 담당 '+esc(x.mgrNm)+(x.validTxt?' · '+esc(x.validTxt):'')
        +'<span style="margin-left:auto" class="tot">품목 <b>'+ls.length+'</b>줄 · 합계 <b>'+fmt(sum)+'</b>원</span></div>'
        +(x.titleTxt?'<div class="df" style="border-top:0;color:#37475a">'+esc(x.titleTxt)+'</div>':'')
        +'<div class="tw" style="max-height:none"><table class="g"><thead><tr><th>No</th><th>품명</th><th>규격</th><th>Box</th><th>수량</th><th>단위</th><th>단가</th><th>금액</th><th>비고</th></tr></thead><tbody>'
        +(ls.length?ls.map(function(l){ return '<tr><td>'+esc(l.rowNo)+'</td><td class="l">'+esc(l.prodNm)+'</td><td class="l">'+esc(l.spec)+'</td><td class="r">'+(l.boxQty!=null?fmt(l.boxQty):'')+'</td><td class="r"><b>'+fmt(l.qty)+'</b></td><td>'+esc(l.unit)+'</td><td class="r">'+fmt(l.unitPrice)+'</td><td class="r"><b>'+fmt(l.amt)+'</b></td><td class="l">'+esc(l.remark)+'</td></tr>'; }).join(''):'<tr><td colspan="9" class="empty">품목 줄이 없습니다.</td></tr>')
        +'</tbody></table></div>'+(x.remark?'<div class="df">비고 : '+esc(x.remark)+'</div>':'')+'</div>';
    })
    .catch(function(e){ w.innerHTML='<div class="err">품목을 불러오지 못했습니다 — '+esc(e.message)+'</div>'; });
}
function del(){
  var ks=Array.prototype.filter.call(document.querySelectorAll('.lchk'), function(c){ return c.checked; }).map(function(c){ return _ls[+c.getAttribute('data-i')]; });
  if(!ks.length){ _alertBox('지울 견적서를 체크하세요.',{icon:'ℹ️'}); return; }
  ask('견적서 <b>'+ks.length+'</b>건을 지웁니다.<br><span style="font-size:13px;color:#3d4d5c">'+esc(ks.slice(0,5).map(function(x){ return x.docNo; }).join(', '))+(ks.length>5?' …':'')+'</span>','삭제').then(function(y){ if(!y) return;
    post('/mangr/quoteDelete.do', { seqs: ks.map(function(x){ return x.quoteSeq; }) }, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(t){ ok(t+'건을 지웠습니다.'); load(); })
      .catch(function(e){ err('지우지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
  });
}

/* 시작 — 올해 1월 1일 ~ 오늘 */
(function(){
  var t=new Date();
  function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
  document.getElementById('fr').value=t.getFullYear()+'-01-01'; document.getElementById('to').value=ymd(t);
  load();
})();
window.konetShown=function(){ if(!_pv.length) load(); };
</script>
</body>
</html>
