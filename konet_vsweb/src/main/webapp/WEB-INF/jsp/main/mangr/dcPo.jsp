<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>DC 발주 등록</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 원본 보기(화면에서 시트를 표로 펼친다) — 전역 XLSX --%>
<!--
  DC 발주 등록 (2026-09-17 신설) — 매출 관리 ▸ DC 발주 등록. 셸 iframe(logiFrame) 화면.
  · 삼성웰스토리 SRM 「발주현황조회」에서 상품종류가 DC 인 발주는 발주현황표(통합가마감/라벨발행)에 안 실린다.
    그래서 정산서가 올 때까지 재고가 안 빠지고, 출고내역 대사에서는 「정산서만」으로 떴다.
  · SRM 에서 받은 입고예약서(PDF)·발주서(엑셀 ZMMA_XI_13_PO_QUERY)를 끌어다 놓으면 서버가 읽어 미리보기를 주고, [저장]으로 출고에 넣는다.
    저장 = TBL_SHIPOUT_MST · 상품종류(PROD_KIND)='DC'. 출고장은 납품장소 이름으로(없으면 평택 E500).
  · ★납기현황관리(대시보드·납기세부·이력)에서만 빠진다 — 재고 원장·정산서 교체·월별 출고현황·마감·출고내역 대사에는 들어간다.
  · 정산서가 그 납기일자에 오면 원장은 정산서가 주인이 된다(발주현황표와 같은 규칙) — 목록의 「정산서」 칸이 그 반영을 보여 준다.
  · 같은 납기일자·품목코드를 다시 올리면 앞의 것을 대체한다(입고예약서와 발주서가 같은 발주를 두 번 싣는 경우).
  · 자료 /shipout/dcPoParse.do(base64) · 저장 /shipout/dcPoSave.do · 목록 /shipout/dcPoList.do · 삭제 /shipout/dcPoDelete.do
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:12px; font-size:12.5px; line-height:1.6; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .bar input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ color:var(--red); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .card .hd .sp{ margin-left:auto; }
  .drop{ margin:12px; border:2px dashed #b9d3cc; border-radius:10px; background:#f6fbfa; padding:22px; text-align:center; color:#4b6b63; cursor:pointer; }
  .drop.on{ background:#e3f2ee; border-color:var(--teal); }
  .drop b{ color:var(--teal); }
  .drop small{ display:block; margin-top:5px; color:#7c8e98; font-size:12px; }
  .tw{ overflow:auto; max-height:52vh; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 8px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:4px 8px; vertical-align:middle; text-align:center; white-space:nowrap; }
  table.g td.l{ text-align:left; white-space:normal; min-width:220px; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g tr:hover td{ background:#f7faf9; }
  table.g input[type=date], table.g input[type=text], table.g select{ height:28px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; background:#fff; }
  table.g input.q{ width:80px; text-align:right; font-weight:700; }
  table.g input[type=checkbox]{ width:16px; height:16px; accent-color:var(--teal); cursor:pointer; }
  .bd{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .bd.pdf{ background:#fdecec; color:#a8322a; } .bd.xls{ background:#e3f2ee; color:#0f6b5e; }
  .bd.ok{ background:#e3f2ee; color:#0f6b5e; } .bd.wait{ background:#fdf0d5; color:#9a5b05; } .bd.warn{ background:#fdecec; color:var(--red); }
  .bd.day{ background:#e8eef7; color:#2b4a7a; }
  .dim{ color:#8a98a8; }
  .empty{ padding:30px; text-align:center; color:#8a98a8; }
  .err{ margin:0 12px 12px; padding:8px 12px; border-radius:8px; background:#fdecec; color:#8a2a22; font-size:12.5px; line-height:1.7; }
  .note{ font-size:12.5px; color:#5a6b7a; line-height:1.75; padding:8px 12px; }
  .note b{ color:#37475a; }
  .tot{ font-size:13px; color:#37475a; font-weight:700; }
  .tot b{ color:var(--teal); }
  .pvhd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin:0 12px 6px; padding:8px 12px; border-radius:8px; background:#e3f2ee; color:#0f6b5e; font-weight:800; font-size:14px; }
  .pvhd small{ font-weight:600; color:#4b6b63; font-size:12.5px; }
  .pvhd .sp{ margin-left:auto; display:flex; gap:6px; }
  .docview{ position:relative; }
  .docx{ position:sticky; top:6px; float:right; margin:6px 8px 0 0; z-index:2; height:26px; padding:0 9px; font-size:12px; }
  /* 원본 보기(2026-09-17 「문서 미리보기 없나요」) — PDF 는 브라우저 뷰어(embed), 엑셀은 시트를 표로 */
  .docbtn{ height:26px; padding:0 9px; font-size:12px; }
  .docbtn.on{ background:#137a6c; color:#fff; border-color:#137a6c; }
  .docview{ margin:0 12px 10px; border:1px solid var(--bd); border-radius:8px; overflow:auto; max-height:64vh; background:#fff; }
  .docview embed{ display:block; width:100%; height:64vh; }
  table.x{ border-collapse:collapse; font-size:12px; }
  table.x td{ border:1px solid #e3e8ee; padding:2px 6px; white-space:nowrap; max-width:420px; overflow:hidden; text-overflow:ellipsis; }
  table.x td.h{ background:#f1f5f8; color:#6b7a89; text-align:center; font-weight:600; }
  /* 엑셀 원본 = 병합(colspan/rowspan)을 살려 원본 모양대로 (2026-09-17 「엑셀은 흐트러져 나옴」) */
  .xh{ padding:8px 10px; }
  .xh table{ border-collapse:collapse; font-size:12px; table-layout:auto; }
  .xh td{ border:1px solid #d9e0e7; padding:2px 5px; white-space:pre-wrap; vertical-align:middle; min-width:14px; max-width:520px; line-height:1.35; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🏷 DC 발주 등록</h2>

  <div class="card">
    <div class="hd">📥 파일 올리기 <small>— 여러 개를 한 번에 올릴 수 있습니다. 미리보기를 확인하고 [💾 저장]</small>
      <span class="sp tot" id="pvTot"></span>
    </div>
    <div class="drop" id="drop" onclick="document.getElementById('file').click()">
      📄 <b>입고예약서 PDF</b> 또는 <b>발주서 엑셀</b>을 여기에 끌어다 놓거나 눌러서 고르세요
      <small>출고장은 납품장소 이름으로 정합니다. 엑셀처럼 납품장소가 비어 있으면 <b>평택물류센터</b>로 둡니다(아래에서 바꿀 수 있습니다).</small>
    </div>
    <input type="file" id="file" accept=".pdf,.xlsx,.xls" multiple hidden onchange="pickFiles(this.files); this.value='';">
    <div class="bar" style="padding:0 12px 10px">
      <button class="btn" onclick="pvManual()" title="서류가 없거나 읽지 못했을 때 줄을 직접 적습니다">✏ 수동 입력 줄 추가</button>
      <span class="dim" style="font-size:12.5px">서류가 없거나 읽지 못한 발주는 줄을 더해 납기일자·품목코드·수량을 직접 적고 [💾 저장]</span>
    </div>
    <div id="pvErr"></div>
    <div id="pvWrap" hidden>
      <div class="pvhd" id="pvHd">🔎 미리보기</div>
      <div id="docView" class="docview" hidden></div>
      <div class="tw">
        <table class="g">
          <thead><tr>
            <th><input type="checkbox" id="pvAll" checked onchange="pvAllChk(this)"></th>
            <th>원본</th><th>납기일자</th><th>출고장</th><th>발주번호</th><th>품목코드</th><th>품목명</th><th>단위</th><th>수량</th><th>단가</th><th>금액</th><th>비고</th>
          </tr></thead>
          <tbody id="pvBody"></tbody>
        </table>
      </div>
      <div class="bar" style="padding:10px 12px">
        <button class="btn btn-teal" id="saveBtn" onclick="save()">💾 저장</button>
        <button class="btn" onclick="pvClear()">✕ 미리보기 비우기</button>
        <span class="dim" style="font-size:12.5px">같은 납기일자·품목코드가 이미 있으면 새로 올린 것으로 대체합니다.</span>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="hd">📋 등록된 DC 발주 <small>— 납기일자 기준</small>
      <span class="bar" style="margin-left:8px">
        <input type="date" id="fr"> ~ <input type="date" id="to">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn btn-red" onclick="del()">🗑 선택 삭제</button>
      </span>
      <span class="sp tot" id="lsTot"></span>
    </div>
    <div class="tw">
      <table class="g">
        <thead><tr>
          <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th>
          <th>납기일자</th><th>출고장</th><th>발주번호</th><th>품목코드</th><th>품목명</th><th>수량</th><th>우리 품목</th><th title="같은 납기일자·품목코드의 정산서 출고수량">정산서</th><th>원본 파일</th><th>비고</th><th>등록</th>
        </tr></thead>
        <tbody id="lsBody"><tr><td colspan="12" class="empty">조회 중…</td></tr></tbody>
      </table>
    </div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _pv=[], _ls=[], _docs={}, _docOpen='', _pvFold=false;   // _docs = 올린 원본(파일명 → {kind:pdf|grid, url|grid}) — 「원본 보기」
var DCS=[['E500','평택'],['E100','용인'],['E200','왜관'],['E300','김해'],['E400','광주'],['E600','제주'],['E700','오산']];
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ var x=n(v); return (Math.round(x*100)/100).toLocaleString(); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function dcNm(cd){ for(var i=0;i<DCS.length;i++) if(DCS[i][0]===cd) return DCS[i][1]; return cd||''; }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin',
  headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }
function ok(m){ _alertBox(m,{icon:'✅'}); }   /* 가운데 알림창으로(2026-09-17 「가운데 메세지 뜨게」) — 토스트는 이 iframe 에서 아래로 밀려 글자가 안 보였다 */
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
function pickFiles(list){
  var fs=Array.prototype.slice.call(list||[]).filter(function(f){ return /\.(pdf|xlsx|xls)$/i.test(f.name); });
  if(!fs.length){ _alertBox('PDF 나 엑셀 파일을 골라 주세요.',{icon:'⚠️'}); return; }
  var big=fs.filter(function(f){ return f.size>15*1024*1024; });
  if(big.length){ _alertBox(big[0].name+' 이 15MB 를 넘습니다.',{icon:'⚠️'}); return; }
  var dr=document.getElementById('drop'); dr.innerHTML='⏳ 읽는 중… ('+fs.length+'개)';
  fs.forEach(docKeep);   // 원본 보기용(PDF 는 브라우저 뷰어, 엑셀은 시트 표) — 서버 해석과 별개
  Promise.all(fs.map(function(f){ return readB64(f).then(function(b){ return { name:f.name, b64:b }; }); }))
    .then(function(files){ return post('/shipout/dcPoParse.do', { files:files }, true); })
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t||('HTTP '+r.status)); return JSON.parse(t); }); })
    .then(function(j){
      var rows=(j&&j.rows)||[], errs=(j&&j.errors)||[];
      rows.forEach(function(x){ x._on=true; _pv.push(x); });
      document.getElementById('pvErr').innerHTML = errs.length ? '<div class="err">'+errs.map(esc).join('<br>')+'</div>' : '';
      pvRender();
      if(rows.length) ok('<b>'+rows.length+'줄</b>을 읽었습니다.<br><span style="font-size:13px;color:#3d4d5c">아래 <b>미리보기</b> 표에서 납기일자·출고장·수량을 확인하고 [💾 저장]을 누르세요.</span>');
    })
    .catch(function(e){ err('파일을 읽지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
    .then(function(){ dr.innerHTML='📄 <b>입고예약서 PDF</b> 또는 <b>발주서 엑셀</b>을 여기에 끌어다 놓거나 눌러서 고르세요<small>출고장은 납품장소 이름으로 정합니다. 엑셀처럼 납품장소가 비어 있으면 <b>평택물류센터</b>로 둡니다(아래에서 바꿀 수 있습니다).</small>'; });
}
function pvRender(){
  var w=document.getElementById('pvWrap'), tb=document.getElementById('pvBody');
  w.hidden = !_pv.length;
  var fns={}; _pv.forEach(function(x){ if(x.fileNm) fns[x.fileNm]=1; });
  document.getElementById('pvHd').innerHTML='🔎 미리보기 — 파일에서 읽은 내용 <b>'+_pv.length+'</b>줄 <small>'+esc(Object.keys(fns).join(' · '))+' — 맞으면 아래 [💾 저장], 틀리면 칸을 고치거나 체크를 끄세요</small>'
    +Object.keys(_docs).map(function(nm){ return '<button class="btn docbtn'+(_docOpen===nm?' on':'')+'" onclick="docShow(this.getAttribute(\'data-n\'))" data-n="'+esc(nm)+'" title="올린 원본 문서를 그대로 봅니다">📄 원본 보기 · '+esc(nm)+'</button>'; }).join('')
    +'<span class="sp"><button class="btn docbtn" onclick="pvFold()" title="표를 접거나 펼칩니다(내용은 그대로)">'+(_pvFold?'▼ 펼치기':'▲ 접기')+'</button>'
    +'<button class="btn docbtn" onclick="pvClose()" title="미리보기를 닫고 읽은 내용을 지웁니다">✕ 닫기</button></span>';   // 미리보기 닫기(2026-09-17)
  var _tw=document.querySelector('#pvWrap .tw'); if(_tw) _tw.hidden=!!_pvFold;
  if(_docOpen && !_docs[_docOpen]) docShow('');
  tb.innerHTML=_pv.map(function(x,i){
    var isPdf = x.src==='입고예약서', noDc = !/(^|[,\s(])DC([,\s)]|$)/i.test(String(x.itemNm||''));
    if(x._manual) return pvManualRow(x,i);   // 수동 입력 줄(2026-09-17)
    return '<tr>'
      +'<td><input type="checkbox"'+(x._on?' checked':'')+' onchange="_pv['+i+']._on=this.checked; pvTot()"></td>'
      +'<td><span class="bd '+(isPdf?'pdf':'xls')+'" title="'+esc(x.fileNm)+'">'+esc(x.src)+'</span></td>'
      +'<td><input type="date" value="'+d10(x.dlvDt)+'" onchange="_pv['+i+'].dlvDt=this.value; _pv['+i+'].shpoutDt=this.value"></td>'
      +'<td><select onchange="_pv['+i+'].dcCd=this.value">'+DCS.map(function(d){ return '<option value="'+d[0]+'"'+(d[0]===(x.dcCd||'E500')?' selected':'')+'>'+d[1]+'</option>'; }).join('')+'</select></td>'
      +'<td>'+esc(x.ordNo||'')+(x.rsvNo?'<div class="dim" style="font-size:11.5px">예약 '+esc(x.rsvNo)+'</div>':'')+'</td>'
      +'<td><b>'+esc(x.itemCd)+'</b></td>'
      +'<td class="l">'+esc(x.itemNm)+(noDc?' <span class="bd warn" title="품명에 DC 표시가 없습니다 — 발주현황표에도 실리는 TC 품목이면 이중으로 빠집니다">DC 표시 없음</span>':'')+'</td>'
      +'<td>'+esc(x.unit||'')+'</td>'
      +'<td><input type="text" class="q" value="'+fmt(x.qty)+'" onfocus="this.select()" oninput="_pv['+i+'].qty=this.value; pvTot()"></td>'
      +'<td class="r">'+(x.price?fmt(x.price):'')+'</td>'
      +'<td class="r">'+(x.amt?fmt(x.amt):'')+'</td>'
      +'<td class="dim">'+esc([x.rsvNo?'':'', x.ordDt?('발주 '+d10(x.ordDt)):''].join(''))+'</td></tr>';
  }).join('');
  pvTot();
}
/* ── 수동 입력 (2026-09-17 「내용 없을 시 수동 입력 가능하게」) — 서류가 없거나 못 읽은 발주를 직접 적는다.
     품목코드를 적고 칸을 떠나면 우리 상품 마스터(/prod/prodList.do)에서 이름을 찾아 채운다(없으면 비워 두고 직접 적는다). 저장 규칙은 파일로 읽은 줄과 같다. */
function pvManual(){
  var t=new Date(), ymd=t.getFullYear()+'-'+('0'+(t.getMonth()+1)).slice(-2)+'-'+('0'+t.getDate()).slice(-2);
  _pv.push({ src:'수동', fileNm:'수동 입력', _manual:true, _on:true, dlvDt:ymd, shpoutDt:ymd, dcCd:'E500', place:'', ordNo:'', rsvNo:'', itemCd:'', itemNm:'', unit:'BOX', qty:0, price:'', amt:0, ordDt:'' });
  pvRender();
  var rows=document.querySelectorAll('#pvBody tr'); var last=rows[rows.length-1]; var c=last&&last.querySelector('.mcd'); if(c) c.focus();
  try{ document.getElementById('pvWrap').scrollIntoView({block:'nearest'}); }catch(e){}
}
function pvManualRow(x,i){
  return '<tr>'
    +'<td><input type="checkbox"'+(x._on?' checked':'')+' onchange="_pv['+i+']._on=this.checked; pvTot()"></td>'
    +'<td><span class="bd day" title="직접 적은 줄">수동</span></td>'
    +'<td><input type="date" value="'+d10(x.dlvDt)+'" onchange="_pv['+i+'].dlvDt=this.value; _pv['+i+'].shpoutDt=this.value"></td>'
    +'<td><select onchange="_pv['+i+'].dcCd=this.value">'+DCS.map(function(d){ return '<option value="'+d[0]+'"'+(d[0]===(x.dcCd||'E500')?' selected':'')+'>'+d[1]+'</option>'; }).join('')+'</select></td>'
    +'<td><input type="text" value="'+esc(x.ordNo||'')+'" placeholder="발주번호" style="width:110px" oninput="_pv['+i+'].ordNo=this.value"></td>'
    +'<td><input type="text" class="mcd" value="'+esc(x.itemCd||'')+'" placeholder="품목코드" style="width:120px;font-weight:700" oninput="_pv['+i+'].itemCd=this.value.trim()" onblur="pvLookup('+i+', this)"></td>'
    +'<td class="l"><input type="text" class="mnm" value="'+esc(x.itemNm||'')+'" placeholder="품목명 (코드를 적으면 찾아 채웁니다)" style="width:100%;min-width:260px" oninput="_pv['+i+'].itemNm=this.value"></td>'
    +'<td><input type="text" value="'+esc(x.unit||'')+'" style="width:56px;text-align:center" oninput="_pv['+i+'].unit=this.value"></td>'
    +'<td><input type="text" class="q" value="'+(n(x.qty)?fmt(x.qty):'')+'" placeholder="수량" onfocus="this.select()" oninput="_pv['+i+'].qty=this.value; _pv['+i+'].amt=n(this.value)*n(_pv['+i+'].price); pvTot()"></td>'
    +'<td><input type="text" value="'+esc(x.price||'')+'" placeholder="단가" style="width:90px;text-align:right" oninput="_pv['+i+'].price=this.value.replace(/,/g,\'\'); _pv['+i+'].amt=n(_pv['+i+'].qty)*n(this.value); pvTot()"></td>'
    +'<td class="r">'+(n(x.amt)?fmt(x.amt):'')+'</td>'
    +'<td><button class="btn" style="height:26px;padding:0 8px;font-size:12px" onclick="_pv.splice('+i+',1); pvRender()" title="이 줄 빼기">✕</button></td></tr>';
}
function pvLookup(i, el){
  var x=_pv[i]; if(!x) return; var cd=String(el.value||'').trim(); if(!cd || (x.itemNm||'').trim()) return;
  post('/prod/prodList.do','findData='+encodeURIComponent(cd)).then(function(r){ return r.json(); }).then(function(j){
    var hit=((j&&j.data)||[]).filter(function(p){ return String(p.prodCd||'')===cd; })[0];
    if(!hit || (x.itemNm||'').trim()) return;
    x.itemNm=hit.prodNm||''; var tr=el.closest('tr'), nm=tr&&tr.querySelector('.mnm'); if(nm) nm.value=x.itemNm;
  }).catch(function(){});
}
function pvTot(){ var on=_pv.filter(function(x){ return x._on; }); var q=0, a=0; on.forEach(function(x){ q+=n(x.qty); a+=n(x.amt); });
  document.getElementById('pvTot').innerHTML = _pv.length ? ('선택 <b>'+on.length+'</b>/'+_pv.length+'줄 · 수량 <b>'+fmt(q)+'</b> · 금액 <b>'+fmt(a)+'</b>원') : ''; }
function pvAllChk(el){ _pv.forEach(function(x){ x._on=el.checked; }); pvRender(); }
function pvFold(){ _pvFold=!_pvFold; pvRender(); }
function pvClose(){
  if(!_pv.length){ pvClear(); return; }
  ask('미리보기를 닫습니다.<br><span style="font-size:13px;color:#3d4d5c">읽은 <b>'+_pv.length+'줄</b>은 저장되지 않고 지워집니다.</span>','닫기').then(function(y){ if(y){ _pvFold=false; pvClear(); } });
}
function pvClear(){ _pv=[]; document.getElementById('pvErr').innerHTML=''; docShow(''); for(var k in _docs){ try{ if(_docs[k].url) URL.revokeObjectURL(_docs[k].url); }catch(e){} } _docs={}; pvRender(); }

/* ── 원본 보기 (2026-09-17 「문서 미리보기 없나요」) — PDF 는 브라우저 PDF 뷰어(embed, 서버 안 거침), 엑셀은 첫 시트를 표로(전역 XLSX). 값 없는 줄은 건너뛴다 ── */
function docKeep(f){
  var nm=f.name;
  if(/\.pdf$/i.test(nm)){ _docs[nm]={ kind:'pdf', url:URL.createObjectURL(f) }; return; }
  var r=new FileReader();
  r.onload=function(){
    try{
      var wb=XLSX.read(new Uint8Array(r.result), { type:'array' }), ws=wb.Sheets[wb.SheetNames[0]];
      /* 병합 칸을 살려 원본 모양대로 — sheet_to_html 이 colspan/rowspan 을 만들어 준다(칸 단위 표는 자리가 흐트러졌다) */
      var html=XLSX.utils.sheet_to_html(ws, { editable:false, header:'', footer:'' });
      var mt=/<table[\s\S]*<\/table>/i.exec(html);
      _docs[nm]={ kind:'html', html: mt ? mt[0] : html, sheet:wb.SheetNames[0], sheets:wb.SheetNames.length };
    }catch(e){ _docs[nm]={ kind:'err', msg:String(e&&e.message||e) }; }
    if(_pv.length) pvRender();
  };
  r.readAsArrayBuffer(f);
}
function docShow(nm){
  var v=document.getElementById('docView');
  if(!nm || _docOpen===nm){ _docOpen=''; v.hidden=true; v.innerHTML=''; if(nm) pvRender(); return; }
  var d=_docs[nm]; if(!d) return;
  _docOpen=nm; v.hidden=false;
  var closeBtn='<button class="btn docx" onclick="docShow(\''+esc(nm).replace(/'/g,'&#39;')+'\')" title="원본 보기를 닫습니다">✕ 원본 닫기</button>';
  if(d.kind==='pdf') v.innerHTML=closeBtn+'<embed src="'+d.url+'#toolbar=1&navpanes=0" type="application/pdf">';
  else if(d.kind==='html'){
    v.innerHTML=closeBtn+'<div class="dim" style="padding:6px 10px 0;font-size:12px">시트 「'+esc(d.sheet)+'」'+(d.sheets>1?(' (시트 '+d.sheets+'개 중 첫 시트)'):'')+'</div><div class="xh">'+d.html+'</div>';
  } else v.innerHTML=closeBtn+'<div class="err" style="margin:10px">원본을 펼치지 못했습니다 — '+esc(d.msg||'')+'</div>';
  pvRender();
  try{ v.scrollIntoView({block:'nearest'}); }catch(e){}
}
function save(){
  var rows=_pv.filter(function(x){ return x._on; });
  if(!rows.length){ _alertBox('저장할 줄을 체크하세요.',{icon:'ℹ️'}); return; }
  var bad=rows.filter(function(x){ return !d10(x.dlvDt) || !x.itemCd || !n(x.qty); });
  if(bad.length){ _alertBox('납기일자·품목코드·수량이 빈 줄이 '+bad.length+'개 있습니다.',{icon:'⚠️'}); return; }
  var b=document.getElementById('saveBtn'); b.disabled=true;
  post('/shipout/dcPoSave.do', { rows: rows.map(function(x){ return { dlvDt:x.dlvDt, shpoutDt:x.shpoutDt, dcCd:x.dcCd, place:x.place, itemCd:x.itemCd, itemNm:x.itemNm,
         unit:x.unit, qty:n(x.qty), price:x.price, ordNo:x.ordNo, rsvNo:x.rsvNo, ordDt:x.ordDt, fileNm:x.fileNm }; }) }, true)
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
    .then(function(t){
      var cnt=String(t).split('|')[0], fail=String(t).indexOf('|STOCKFAIL:')>=0 ? String(t).split('|STOCKFAIL:')[1] : '';
      if(fail) _alertBox('DC 발주 <b>'+esc(cnt)+'줄</b>을 저장했습니다.<br><span style="color:#c0392b">그런데 재고 반영에 실패했습니다</span> — '+esc(fail)+'<br><span style="font-size:13px">월별 출고현황의 [출고반영 재집계]를 한 번 눌러 주세요.</span>',{icon:'⚠️'});
      else ok('DC 발주 '+cnt+'줄을 저장하고 재고에 반영했습니다');
      // 저장한 납기일자가 목록 기간 밖이면 기간을 넓힌다
      rows.forEach(function(x){ var d=d10(x.dlvDt), fr=document.getElementById('fr'), to=document.getElementById('to');
        if(d && (!fr.value || d<fr.value)) fr.value=d; if(d && (!to.value || d>to.value)) to.value=d; });
      pvClear(); load();
    })
    .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
    .then(function(){ b.disabled=false; });
}

/* ── 목록 ── */
function load(){
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  var tb=document.getElementById('lsBody'); tb.innerHTML='<tr><td colspan="12" class="empty">조회 중…</td></tr>';
  post('/shipout/dcPoList.do','dlvDtFrom='+encodeURIComponent(fr)+'&dlvDtTo='+encodeURIComponent(to))
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return JSON.parse(t); }); })
    .then(function(j){ _ls=(j&&j.data)||[]; lsRender(); })
    .catch(function(e){ tb.innerHTML='<tr><td colspan="12" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsRender(){
  var tb=document.getElementById('lsBody');
  document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="12" class="empty">이 기간에 등록된 DC 발주가 없습니다.</td></tr>'; document.getElementById('lsTot').innerHTML=''; return; }
  var q=0, wait=0;
  tb.innerHTML=_ls.map(function(x,i){
    q+=n(x.qty);
    var st = x.settleYn==='Y' ? '<span class="bd ok">반영 '+fmt(x.settleQty)+'</span>'
           : (x.settleDayYn==='Y' ? '<span class="bd day" title="그 날 정산서가 있어 원장은 정산서를 씁니다 — 이 품목은 정산서에 없습니다">그 날 정산서 있음</span>' : '<span class="bd wait">대기</span>');
    if(x.settleYn!=='Y' && x.settleDayYn!=='Y') wait++;
    return '<tr><td><input type="checkbox" class="lchk" data-i="'+i+'"></td>'
      +'<td>'+d10(x.dlvDt)+'</td><td>'+esc(dcNm(x.dcCd))+'</td><td>'+esc(x.ordNo||'')+'</td><td><b>'+esc(x.itemCd)+'</b></td>'
      +'<td class="l">'+esc(x.itemNm)+'</td><td class="r"><b>'+fmt(x.qty)+'</b> '+esc(x.unit||'')+'</td>'
      +'<td>'+(x.prodCd?esc(x.prodCd):'<span class="bd warn" title="품목코드(매핑)에서 이어 주세요 — 이어지기 전엔 재고에서 안 빠집니다">미매핑</span>')+'</td>'
      +'<td>'+st+'</td><td class="dim" style="white-space:normal;max-width:220px">'+esc(x.srcFile)+'</td><td class="dim">'+esc(x.remark)+'</td>'
      +'<td class="dim">'+esc(String(x.uploadDttm||'').slice(0,16))+(x.regUser?'<br>'+esc(x.regUser):'')+'</td></tr>';
  }).join('');
  document.getElementById('lsTot').innerHTML='<b>'+_ls.length+'</b>줄 · 수량 <b>'+fmt(q)+'</b>'+(wait?(' · 정산서 대기 <b style="color:#b45309">'+wait+'</b>'):'');
}
function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function del(){
  var ks=Array.prototype.filter.call(document.querySelectorAll('.lchk'), function(c){ return c.checked; }).map(function(c){ var x=_ls[+c.getAttribute('data-i')]; return { dlvDt:x.dlvDt, itemCd:x.itemCd }; });
  if(!ks.length){ _alertBox('지울 줄을 체크하세요.',{icon:'ℹ️'}); return; }
  ask('DC 발주 <b>'+ks.length+'줄</b>을 지웁니다.<br><span style="font-size:13px;color:#3d4d5c">그 날짜 재고 원장을 다시 맞춥니다.</span>','삭제').then(function(y){ if(!y) return;
    post('/shipout/dcPoDelete.do', { keys:ks }, true)
      .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(t){ var fail=String(t).indexOf('|STOCKFAIL:')>=0; if(fail) _alertBox('지웠지만 재고 반영에 실패했습니다 — [출고반영 재집계]를 눌러 주세요.',{icon:'⚠️'}); else ok(String(t).split('|')[0]+'줄을 지웠습니다'); load(); })
      .catch(function(e){ err('지우지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
  });
}

/* 시작 — 지난 달 1일 ~ 다음 달 말일 */
(function(){
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth()-1, 1), b=new Date(t.getFullYear(), t.getMonth()+2, 0);
  function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
  document.getElementById('fr').value=ymd(a); document.getElementById('to').value=ymd(b);
  load();
})();
window.konetShown=function(){ if(!_pv.length) load(); };
</script>
</body>
</html>
