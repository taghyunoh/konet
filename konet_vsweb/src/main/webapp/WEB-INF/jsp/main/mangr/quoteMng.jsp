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
  table.g td, .cmp td, .dtl td{ user-select:text; -webkit-user-select:text; }   /* 글자 드래그 → Ctrl+C (2026-09-17 「Ctrl+C 가 안 됨」). 드래그로 고른 채 놓으면 상세가 안 열려 선택이 남는다 */
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
  .bd.hand{ background:#e8eefb; color:#2f4f9a; margin-left:6px; vertical-align:1px; }   /* 직접 작성 표시 (2026-09-17) */
  .bd.up{ background:#eef2f5; color:#556; margin-left:6px; vertical-align:1px; }
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
  /* 견적서별 비교분석(2026-09-17) — 품명 × 견적서 행렬 */
  .cmp{ margin:0 12px 12px; border:1px solid var(--bd); border-radius:8px; overflow:hidden; }
  .cmp .dh{ display:flex; gap:8px 14px; align-items:center; flex-wrap:wrap; padding:8px 12px; background:#f6fbfa; border-bottom:1px solid #eef1f5; font-size:13px; }
  .cmp table.g th{ white-space:normal; min-width:96px; }
  .cmp td.nm{ text-align:left; white-space:normal; min-width:200px; position:sticky; left:0; background:#fff; z-index:1; }
  .cmp th.nm{ position:sticky; left:0; z-index:3; }
  .cmp .up{ color:var(--red); font-weight:700; } .cmp .dn{ color:#1f5fbf; font-weight:700; } .cmp .same{ color:#8a98a8; }
  .cmp .sub{ font-size:11.5px; color:#6b7a89; }
  .cmp tr.tot td{ background:#eef4f2; font-weight:800; }
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
        <input type="text" id="mgr" placeholder="담당자" style="width:110px" list="mgrList" autocomplete="off"><datalist id="mgrList"></datalist>
        <input type="text" id="q" placeholder="문서번호 · 수신 · 품명" style="width:200px" onkeydown="if(event.keyCode===13) load()">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn" style="border-color:#137a6c;color:#137a6c" onclick="cmpOpen()" title="체크한 견적서(없으면 목록 전체)를 품명 × 견적서 행렬로 비교합니다 — 단가 변동·최저·최고">📊 견적 비교</button>
        <button class="btn btn-red" onclick="del()">🗑 선택 삭제</button>
      </span>
      <span class="sp tot" id="lsTot"></span>
    </div>
    <div class="tw">
      <table class="g">
        <thead><tr>
          <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th>
          <th>견적일</th><th>문서번호</th><th>수신</th><th>담당자</th><th>품목</th><th>줄</th><th>금액(부가세 별도)</th><th>유효기간</th><th>원본</th><th title="A4 양식 인쇄 · 작성 화면에서 수정">출력·수정</th><th>등록</th>
        </tr></thead>
        <tbody id="lsBody"><tr><td colspan="12" class="empty">조회 중…</td></tr></tbody>
      </table>
    </div>
    <div id="cmpWrap" hidden></div>
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
/* 단가 묶음이 둘(센터배송 · 택배출고)이면 열을 넷으로 — 머리글에 묶음 이름 (2026-09-17 둘째 표본) */
function priceHead(q){ var p1=(q&&q.price1Nm)||'', p2=(q&&q.price2Nm)||''; if(!p2) return '<th>단가</th><th>금액</th>'; return '<th>'+esc(p1||'단가1')+' 단가</th><th>'+esc(p1||'단가1')+' 금액</th><th>'+esc(p2)+' 단가</th><th>'+esc(p2)+' 금액</th>'; }
function priceCells(l, has2){ var h='<td class="r">'+fmt(l.unitPrice)+'</td><td class="r"><b>'+fmt(l.amt)+'</b></td>'; if(has2) h+='<td class="r">'+(n(l.unitPrice2)?fmt(l.unitPrice2):'')+'</td><td class="r"><b>'+(n(l.amt2)?fmt(l.amt2):'')+'</b></td>'; return h; }
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
      +((q.exists||dup)?'<span class="bd dup" title="같은 문서번호가 이미 저장돼 있습니다 — 저장하면 새로 올린 것으로 대체되고 앞의 것은 이력으로 남습니다">⚠ 이미 올린 견적서'+(q.exists?' · '+esc(String(q.exists.regDttm||'').slice(0,16))+(q.exists.regUser?' '+esc(q.exists.regUser):''):'')+'</span>':'')
      +(!q.docNo?'<span class="bd warn">문서번호 없음</span>':'')
      +'<span style="margin-left:auto" class="tot">품목 <b>'+lines.length+'</b>줄 · 합계 <b>'+fmt(sum)+'</b>원</span>'
      +(_docs[q.fileNm]?'<button class="btn lnk'+(_docOpen===q.fileNm?' on':'')+'" onclick="docShow(this.getAttribute(\'data-n\'))" data-n="'+esc(q.fileNm)+'" title="올린 엑셀을 그대로 봅니다">📄 원본 보기</button>':'')
      +'</div>'
      +(q.titleTxt?'<div class="df" style="border-top:0;color:#37475a">'+esc(q.titleTxt)+'</div>':'')
      +'<div class="tw" style="max-height:none"><table class="g"><thead><tr><th>No</th><th>품명</th><th>규격</th><th>Box</th><th>수량</th><th>단위</th>'+priceHead(q)+'<th>비고</th></tr></thead><tbody>'
      +(lines.length?lines.map(function(l){ return '<tr><td>'+esc(l.rowNo)+'</td><td class="l">'+esc(l.prodNm)+'</td><td class="l">'+esc(l.spec)+'</td><td class="r">'+(l.boxQty!=null?fmt(l.boxQty):'')+'</td><td class="r"><b>'+fmt(l.qty)+'</b></td><td>'+esc(l.unit)+'</td>'+priceCells(l, !!q.price2Nm)+'<td class="l">'+esc(l.remark)+'</td></tr>'; }).join('')
        :'<tr><td colspan="11" class="empty">품목 줄을 읽지 못했습니다 — 품명·수량·단가 머리글이 있는지 원본을 확인하세요.</td></tr>')
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
  /* 기존에 올린 게 있는지는 서버가 문서번호로 확인한다(2026-09-17) — 없으면 바로 저장, 있으면 409 로 목록을 주고 여기서 묻는다. 화면 목록의 기간 필터와 무관 */
  var body=function(confirm){ return { confirm: confirm?'Y':'N', docs: docs.map(function(q){ return { docNo:q.docNo, quoteDt:q.quoteDt, recvNm:q.recvNm, mgrNm:q.mgrNm, validTxt:q.validTxt, titleTxt:q.titleTxt, remark:q.remark, price1Nm:q.price1Nm, price2Nm:q.price2Nm, fileNm:q.fileNm, fileB64:q.fileB64, lines:q.lines }; }) }; };
  /* 저장 전 확인 (2026-09-17 「아무 오류 없어도 저장할 거냐 메세지」) — 문서번호·견적일·담당자·품목 수를 보여 주고 [저장]을 눌러야 진행 */
  var sum=0; docs.forEach(function(q){ (q.lines||[]).forEach(function(l){ sum+=n(l.amt); }); });
  ask('견적서 <b>'+docs.length+'</b>건을 저장합니다.<br><span style="font-size:13px;color:#3d4d5c;text-align:left;display:inline-block">'
      +docs.map(function(q){ return '· <b>'+esc(q.docNo)+'</b> '+d10(q.quoteDt)+' · '+esc(q.mgrNm||'')+' · 품목 '+(q.lines||[]).length+'줄'; }).join('<br>')
      +'</span><br><span style="font-size:13px;color:#3d4d5c">합계 <b>'+fmt(sum)+'</b>원 · 원본 파일도 함께 보관합니다.</span>', '저장')
  .then(function(y){ if(!y) return;
  var b=document.getElementById('saveBtn'); b.disabled=true;
  post('/mangr/quoteSave.do', body(false), true)
    .then(function(r){ return r.text().then(function(t){
        if(r.status===409){
          return ask('<b>이미 올린 견적서</b>가 있습니다.<br><span style="font-size:13px;color:#3d4d5c;white-space:pre-line">'+esc(t)+'</span><br><span style="font-size:13px;color:#3d4d5c">저장하면 앞의 것을 새로 올린 것으로 <b>대체</b>합니다(앞의 것은 이력으로 남습니다).</span>','대체 저장')
            .then(function(y){ if(!y) throw new Error('__cancel'); return post('/mangr/quoteSave.do', body(true), true).then(function(r2){ return r2.text().then(function(t2){ if(!r2.ok) throw new Error(t2); return t2; }); }); });
        }
        if(!r.ok) throw new Error(t); return t; }); })
      .then(function(t){
        var jr={}; try{ jr=JSON.parse(t); }catch(e){}
        ok('견적서 <b>'+esc(jr.cnt!=null?jr.cnt:docs.length)+'</b>건을 저장했습니다.');
        docs.forEach(function(q){ var d=d10(q.quoteDt), fr=document.getElementById('fr'), to=document.getElementById('to'); if(d && (!fr.value || d<fr.value)) fr.value=d; if(d && (!to.value || d>to.value)) to.value=d; });
        pvClear(); load();
      })
      .catch(function(e){ if(String(e&&e.message)!=='__cancel') err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
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
  var tb=document.getElementById('lsBody'); tb.innerHTML='<tr><td colspan="12" class="empty">조회 중…</td></tr>';
  _sel=null; document.getElementById('dtlWrap').hidden=true;
  /* 다시 조회(저장·삭제 뒤 포함)하면 아래 비교 표·원본 보기·상세도 접는다 (2026-09-17 「선택 삭제하면 아래도 없어지게」) — 지운 견적서가 비교 표에 남지 않게 */
  _cmp=null; var _cw=document.getElementById('cmpWrap'); if(_cw){ _cw.hidden=true; _cw.innerHTML=''; }
  _lsDocSeq=null; var _ld=document.getElementById('lsDoc'); if(_ld){ _ld.hidden=true; _ld.innerHTML=''; }
  post('/mangr/quoteList.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)+'&mgrNm='+encodeURIComponent(mgr)+'&findData='+encodeURIComponent(q))
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return JSON.parse(t); }); })
    .then(function(j){ _ls=(j&&j.data)||[]; lsRender(); if(_pv.length) pvRender(); })
    .catch(function(e){ tb.innerHTML='<tr><td colspan="12" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsRender(){
  var tb=document.getElementById('lsBody');
  document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="12" class="empty">조건에 맞는 견적서가 없습니다.</td></tr>'; document.getElementById('lsTot').innerHTML=''; return; }
  var amt=0;
  tb.innerHTML=_ls.map(function(x,i){
    amt+=n(x.supplyAmt);
    return '<tr class="tap'+(_sel===x.quoteSeq?' sel':'')+'" onclick="if(event.target.tagName!==\'INPUT\' && event.target.tagName!==\'BUTTON\' && !(window.getSelection&&String(window.getSelection()).length)) detail('+i+')">'
      +'<td><input type="checkbox" class="lchk" data-i="'+i+'"></td>'
      +'<td>'+d10(x.quoteDt)+'</td><td><b>'+esc(x.docNo)+'</b>'+(x.hasFile==='Y'?'<span class="bd up" title="엑셀 파일을 올려 저장한 견적서 ('+esc(x.fileNm)+')">올림</span>':'<span class="bd hand" title="견적서 작성 화면에서 직접 작성한 견적서(올린 파일 없음)">✍ 직접 작성</span>')+'</td><td>'+esc(x.recvNm)+'</td><td>'+esc(x.mgrNm)+'</td>'
      +'<td class="l" style="max-width:320px">'+esc(x.firstNm)+(n(x.lineCnt)>1?' <span class="dim">외 '+(n(x.lineCnt)-1)+'</span>':'')+'</td>'
      +'<td class="r">'+fmt(x.lineCnt)+'</td><td class="r"><b>'+fmt(x.supplyAmt)+'</b></td><td class="dim">'+esc(x.validTxt)+'</td>'
      +'<td>'+(x.hasFile==='Y'?'<button class="btn lnk" onclick="viewFile('+x.quoteSeq+', this.getAttribute(\x27data-n\x27))" data-n="'+esc(x.fileNm)+'" title="올린 엑셀 양식을 화면에서 봅니다 ('+esc(x.fileNm)+')">📄 원본</button>':'<button class="btn lnk" onclick="window.open(CTX+\'/mangr/quoteExcel.do?quoteSeq='+x.quoteSeq+'\',\'_blank\')" title="우리 견적서 양식 그대로 엑셀로 내려받기">📥 엑셀</button>')+'</td>'
      +'<td><button class="btn lnk" onclick="printQuote('+x.quoteSeq+')" title="A4 견적서 양식으로 인쇄">🖨</button> <button class="btn lnk" onclick="editQuote('+x.quoteSeq+')" title="견적서 작성 화면에서 수정">✏</button></td>'
      +'<td class="dim">'+esc(String(x.regDttm||'').slice(0,16))+(x.regUser?'<br>'+esc(x.regUser):'')+'</td></tr>';
  }).join('');
  document.getElementById('lsTot').innerHTML='<b>'+_ls.length+'</b>건 · 금액 <b>'+fmt(amt)+'</b>원';
}
function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function dl(seq){ window.open(CTX+'/mangr/quoteFile.do?quoteSeq='+seq, '_blank'); }
/* 출력 · 수정 (2026-09-17 「여기에서 견적서 작성 및 출력 가능하게」) — 인쇄는 새 창(A4), 수정은 셸의 견적서 작성 화면을 그 번호로 연다 */
function printQuote(seq){ window.open(CTX+'/mangr/quotePrint.do?quoteSeq='+seq, '_blank'); }
function editQuote(seq){
  var url=CTX+'/mangr/quoteEdit.do?quoteSeq='+seq;
  try{
    var P=window.parent; if(P && P!==window && typeof P.logiFrame==='function'){
      var f=P.document.getElementById('if-quoteEdit'); if(f){ f.src=url; }   /* 먼저 그 번호로 로드 — logiFrame 은 src 가 있으면 유지한다 */
      var m=P.document.querySelector('a.mi[data-key="quoteEdit"]'); if(m){ m.click(); return; }
    }
  }catch(e){}
  window.open(url, '_blank');
}
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
        +'<div class="tw" style="max-height:none"><table class="g"><thead><tr><th>No</th><th>품명</th><th>규격</th><th>Box</th><th>수량</th><th>단위</th>'+priceHead(x)+'<th>비고</th></tr></thead><tbody>'
        +(ls.length?ls.map(function(l){ return '<tr><td>'+esc(l.rowNo)+'</td><td class="l">'+esc(l.prodNm)+'</td><td class="l">'+esc(l.spec)+'</td><td class="r">'+(l.boxQty!=null?fmt(l.boxQty):'')+'</td><td class="r"><b>'+fmt(l.qty)+'</b></td><td>'+esc(l.unit)+'</td>'+priceCells(l, !!x.price2Nm)+'<td class="l">'+esc(l.remark)+'</td></tr>'; }).join(''):'<tr><td colspan="11" class="empty">품목 줄이 없습니다.</td></tr>')
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

/* ── 견적서별 비교분석 (2026-09-17) ── 체크한 견적서(없으면 목록 전체, 최대 30) → 서버에서 품목 줄을 받아 품명 × 견적서 행렬.
     같은 품명(띄어쓰기·대소문자 무시)이 같은 줄. 칸 = 단가1(센터배송) · 아래 작은 글씨로 수량·단가2. 앞 견적 대비 단가 변동은 빨강(↑)/파랑(↓).
     맨 오른쪽 = 최저·최고·최근 변동. 맨 아래 = 견적서 합계·품목 수. [📥 엑셀] 은 같은 표를 시트로. */
var _cmp=null;
function cmpKey(s){ return String(s||'').replace(/\s+/g,'').toLowerCase(); }
function cmpOpen(){
  var seqs=Array.prototype.filter.call(document.querySelectorAll('.lchk'), function(c){ return c.checked; }).map(function(c){ return _ls[+c.getAttribute('data-i')].quoteSeq; });
  if(!seqs.length) seqs=_ls.map(function(x){ return x.quoteSeq; });
  if(seqs.length<1){ _alertBox('비교할 견적서가 없습니다 — 목록을 먼저 조회하세요.',{icon:'ℹ️'}); return; }
  if(seqs.length>30){ seqs=seqs.slice(0,30); _toast&&_toast('최근 30건까지만 비교합니다','warning'); }
  var w=document.getElementById('cmpWrap'); w.hidden=false; w.innerHTML='<div class="cmp"><div class="dh">📊 견적 비교 <span class="dim">불러오는 중…</span></div></div>';
  post('/mangr/quoteCompare.do', { seqs:seqs }, true)
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return JSON.parse(t); }); })
    .then(function(j){ _cmp=cmpBuild((j&&j.data)||[]); cmpRender(); try{ w.scrollIntoView({block:'nearest'}); }catch(e){} })
    .catch(function(e){ w.innerHTML='<div class="err">비교 자료를 불러오지 못했습니다 — '+esc(e.message)+'</div>'; });
}
function cmpBuild(rows){
  var qs=[], qi={}, ps=[], pi={};
  rows.forEach(function(r){
    var k=String(r.quoteSeq); if(qi[k]==null){ qi[k]=qs.length; qs.push({ seq:r.quoteSeq, docNo:r.docNo, quoteDt:r.quoteDt, recvNm:r.recvNm, mgrNm:r.mgrNm, price1Nm:r.price1Nm, price2Nm:r.price2Nm, supplyAmt:n(r.supplyAmt), cnt:0 }); }
    var pk=cmpKey(r.prodNm); if(pi[pk]==null){ pi[pk]=ps.length; ps.push({ key:pk, prodNm:r.prodNm, spec:r.spec, cells:{} }); }
    var p=ps[pi[pk]]; p.cells[k]={ price:n(r.unitPrice), price2:(r.unitPrice2==null?null:n(r.unitPrice2)), qty:n(r.qty), amt:n(r.amt) }; if(!p.spec && r.spec) p.spec=r.spec;
    qs[qi[k]].cnt++;
  });
  qs.sort(function(a,b){ return (a.quoteDt||'')<(b.quoteDt||'')?-1:((a.quoteDt||'')>(b.quoteDt||'')?1:(a.seq-b.seq)); });
  return { qs:qs, ps:ps };
}
function cmpRender(){
  var w=document.getElementById('cmpWrap'), c=_cmp; if(!c) return;
  var has2=c.qs.some(function(q){ return !!q.price2Nm; });
  var h='<div class="cmp"><div class="dh"><b>📊 견적 비교</b> <span class="dim">견적서 '+c.qs.length+'건 · 품목 '+c.ps.length+'종 · 단가 = '+esc(c.qs[0]&&c.qs[0].price1Nm||'첫째 묶음')+(has2?' (아래 작은 글씨 = 둘째 묶음 단가)':'')+' · 앞 견적 대비 <span class="up">▲빨강</span>/<span class="dn">▼파랑</span></span>'
    +'<button class="btn lnk" style="margin-left:auto" onclick="cmpExcel()">📥 엑셀</button><button class="btn lnk" onclick="document.getElementById(\'cmpWrap\').hidden=true">✕ 닫기</button></div>'
    +'<div class="tw" style="max-height:60vh"><table class="g"><thead><tr><th class="nm">품명 / 규격</th>';
  c.qs.forEach(function(q){ h+='<th title="'+esc(q.recvNm)+' · '+esc(q.mgrNm)+'">'+esc(q.docNo)+'<div class="sub">'+d10(q.quoteDt)+'</div></th>'; });
  h+='<th>최저</th><th>최고</th><th>최근 변동</th></tr></thead><tbody>';
  c.ps.forEach(function(p){
    h+='<tr><td class="nm"><b>'+esc(p.prodNm)+'</b>'+(p.spec?'<div class="sub">'+esc(p.spec)+'</div>':'')+'</td>';
    var prev=null, vals=[], last=null, lastPrev=null;
    c.qs.forEach(function(q){
      var cell=p.cells[String(q.seq)];
      if(!cell){ h+='<td class="same">—</td>'; return; }
      var pr=cell.price, dif='';
      if(prev!=null && prev>0 && pr!==prev){ var pct=Math.round((pr-prev)/prev*1000)/10; dif='<div class="'+(pr>prev?'up':'dn')+'">'+(pr>prev?'▲':'▼')+fmt(Math.abs(pr-prev))+' ('+(pct>0?'+':'')+pct+'%)</div>'; }
      else if(prev!=null && pr===prev) dif='<div class="same">＝</div>';
      h+='<td class="r"><b>'+fmt(pr)+'</b>'+dif+'<div class="sub">수량 '+fmt(cell.qty)+(has2&&cell.price2!=null&&cell.price2>0?' · '+fmt(cell.price2):'')+'</div></td>';
      if(pr>0){ vals.push(pr); lastPrev=last; last=pr; } prev=pr;
    });
    var mn=vals.length?Math.min.apply(null,vals):0, mx=vals.length?Math.max.apply(null,vals):0;
    var chg = (last!=null && lastPrev!=null && lastPrev>0) ? (last-lastPrev) : null;
    h+='<td class="r">'+(vals.length?fmt(mn):'')+'</td><td class="r">'+(vals.length?fmt(mx):'')+'</td>'
      +'<td class="r">'+(chg==null?'<span class="same">—</span>':(chg===0?'<span class="same">＝</span>':'<span class="'+(chg>0?'up':'dn')+'">'+(chg>0?'▲':'▼')+fmt(Math.abs(chg))+' ('+(chg>0?'+':'')+(Math.round(chg/lastPrev*1000)/10)+'%)</span>'))+'</td></tr>';
  });
  h+='<tr class="tot"><td class="nm">합계(첫째 묶음) · 품목 수</td>';
  c.qs.forEach(function(q){ h+='<td class="r">'+fmt(q.supplyAmt)+'<div class="sub">'+q.cnt+'종</div></td>'; });
  h+='<td></td><td></td><td></td></tr></tbody></table></div></div>';
  w.hidden=false; w.innerHTML=h;
}
function cmpExcel(){
  var c=_cmp; if(!c || typeof XLSX==='undefined'){ _alertBox('엑셀 모듈이 없습니다.',{icon:'⚠️'}); return; }
  var head=['품명','규격']; c.qs.forEach(function(q){ head.push(q.docNo+' ('+d10(q.quoteDt)+') 단가'); head.push('수량'); }); head.push('최저','최고');
  var aoa=[head];
  c.ps.forEach(function(p){ var row=[p.prodNm, p.spec], vals=[]; c.qs.forEach(function(q){ var cell=p.cells[String(q.seq)]; row.push(cell?cell.price:''); row.push(cell?cell.qty:''); if(cell&&cell.price>0) vals.push(cell.price); }); row.push(vals.length?Math.min.apply(null,vals):''); row.push(vals.length?Math.max.apply(null,vals):''); aoa.push(row); });
  var tot=['합계','']; c.qs.forEach(function(q){ tot.push(q.supplyAmt); tot.push(q.cnt+'종'); }); aoa.push(tot);
  var ws=XLSX.utils.aoa_to_sheet(aoa), wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '견적비교');
  XLSX.writeFile(wb, '견적비교_'+new Date().toISOString().slice(0,10).replace(/-/g,'')+'.xlsx');
}

/* 담당자 목록(datalist) — 쌓인 이름 (2026-09-17) */
post('/mangr/quoteNames.do','').then(function(r){ return r.json(); }).then(function(j){ document.getElementById('mgrList').innerHTML=((j&&j.mgr)||[]).map(function(v){ return '<option value="'+esc(v)+'">'; }).join(''); }).catch(function(){});
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
