<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>견적서 작성</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) — 브라우저 alert 금지 --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 📥 엑셀 (전역 XLSX) --%>
<!--
  견적서 작성 (2026-09-17 신설 — 「여기에서 견적서 작성 및 출력 가능하게」) — 견적서관리 ▸ 견적서 작성. 셸 iframe(logiFrame) 화면.
  · 새 견적서 : 문서번호는 'Konet' + 견적일 yyMMdd + '-' + 두 자리 차례로 자동(고칠 수 있음). 수신·담당자·유효기간·제목은 표본 값이 기본.
  · 품목 줄 : 품명·규격·Box·수량·단위·단가·금액(수량×단가 자동)·비고. [🔍 상품] 로 우리 상품 마스터에서 골라 품명·규격·판매가를 채운다.
    「택배출고 단가도」를 켜면 단가 묶음이 둘(센터배송 / 택배출고(D2~3))이 된다 — 표본 260730-1 꼴.
  · 저장 = quoteSave.do (파일 없이). 같은 문서번호는 대체되므로 「수정」(?quoteSeq=)도 같은 길 — 그때는 확인 없이 덮는다(confirm=Y).
  · [🖨 출력] = quotePrint.do (A4 양식). [📥 엑셀] = 화면 표를 시트로.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ color:var(--red); }
  .lnk{ height:26px; padding:0 8px; font-size:12px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .fm{ display:grid; grid-template-columns:110px 1fr 110px 1fr; gap:8px 10px; padding:12px; align-items:center; max-width:1100px; }
  .fm label{ font-weight:700; color:#37475a; font-size:13px; text-align:right; }
  .fm input[type=text], .fm input[type=date], .fm textarea{ width:100%; height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .fm textarea{ height:58px; padding:6px 8px; resize:vertical; }
  .fm .frmOpt{ display:flex; align-items:center; gap:6px; font-weight:400; text-align:left; font-size:13px; border:1px solid var(--bd); border-radius:8px; padding:6px 12px; cursor:pointer; background:#fff; }
  .fm .frmOpt:has(input:checked){ border-color:#0f6b5e; background:#e3f2ee; }
  .fm .frmOpt input{ margin:0; }
  .fm select#delivSel{ height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 6px; font-size:13.5px; background:#fff; }
  .fm .full{ grid-column:2 / span 3; }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:3px 4px; vertical-align:middle; text-align:center; }
  table.g input[type=text]{ width:100%; height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; }
  table.g input.num{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g td.amt{ text-align:right; font-weight:800; color:#137a6c; font-variant-numeric:tabular-nums; padding-right:8px; }
  table.g tr.sum td{ background:#eef4f2; font-weight:800; }
  .tot{ font-size:13px; color:#37475a; font-weight:700; } .tot b{ color:var(--teal); }
  .dim{ color:#8a98a8; }
  .pop{ position:fixed; inset:0; background:rgba(15,23,32,.35); display:none; align-items:flex-start; justify-content:center; z-index:1000; padding-top:6vh; }
  .pop.on{ display:flex; }
  .pop .box{ background:#fff; width:min(860px,94vw); max-height:84vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); display:flex; flex-direction:column; overflow:hidden; }
  .pop .ph{ display:flex; gap:8px; align-items:center; padding:10px 14px; border-bottom:1px solid #eef1f5; }
  .pop .ph input{ flex:1; height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:14px; }
  .pop .pb{ overflow:auto; }
  .pop table.g tr.pick{ cursor:pointer; } .pop table.g tr.pick:hover td{ background:#e3f2ee; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🧾 견적서 작성 <small id="mode">새 견적서</small></h2>
  <div class="card">
    <div class="hd">머리 <small>— 문서번호는 견적일로 자동 매깁니다(고칠 수 있음). 같은 문서번호를 저장하면 앞의 것을 대체합니다</small>
    </div>
    <div class="fm">
      <label>양식</label><div style="grid-column:2 / span 3;display:flex;gap:8px;flex-wrap:wrap">
        <label class="frmOpt"><input type="radio" name="frm" value="2" id="use2" checked onchange="renderLines(); delivOnUse2()"> <b>센터배송 + 택배출고(D2~3)</b> <span class="dim">— 단가·금액 두 묶음 + 비고(MOQ) · 260730-1 꼴</span></label>
        <label class="frmOpt"><input type="radio" name="frm" value="1" id="use1" onchange="renderLines(); delivOnUse2()"> <b>단가 하나</b> <span class="dim">— 센터배송만 · 260729-1 꼴</span></label>
      </div>
      <label>문서번호</label><div style="display:flex;gap:6px"><input type="text" id="docNo" style="font-weight:800" placeholder="Konet260917-01"><button class="btn lnk" style="height:32px" onclick="nextNo(true)" title="견적일 기준 다음 번호">↻ 번호</button></div>
      <label>견적일</label><input type="date" id="quoteDt" onchange="if(!_seq) nextNo(false)">
      <label>수신</label><input type="text" id="recvNm" value="삼성웰스토리" list="recvList" autocomplete="off">
      <label>담당자</label><input type="text" id="mgrNm" placeholder="예: 김정호 프로님" list="mgrList" autocomplete="off" title="지금까지 저장한 담당자 이름이 목록으로 뜹니다(칸을 비우고 ▼ 또는 글자를 치면). 새 이름은 그냥 적으면 됩니다">
      <datalist id="mgrList"></datalist><datalist id="recvList"></datalist>
      <label>유효기간</label><input type="text" id="validTxt" value="견적일로부터 15일">
      <label>단가 묶음 이름</label><div style="display:flex;gap:6px;align-items:center"><input type="text" id="p1" value="센터배송" style="width:150px" title="첫째 묶음 이름(묶음이 하나면 인쇄에 안 나옵니다)"><span class="dim">/</span><input type="text" id="p2" value="택배출고 (D2~3)" style="width:170px" title="둘째 묶음 이름"></div>
      <label>배송</label><div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
        <select id="delivSel" onchange="delivPick(this.value)" title="배송 조건 — 제목 줄 「(…, 부가세 별도)」와 비고에 같이 들어갑니다">
          <option value="센터배송 / 택배출고 (D2~3)">센터배송 / 택배출고 (D2~3)</option><option value="센터배송">센터배송</option><option value="택배출고 (D2~3)">택배출고 (D2~3)</option><option value="배송비 포함">배송비 포함</option><option value="직송">직송</option><option value="배송비 별도">배송비 별도</option><option value="*">직접 입력…</option>
        </select>
        <input type="text" id="deliv" autocomplete="off" value="센터배송 / 택배출고 (D2~3)" style="width:230px" placeholder="직접 적기" oninput="delivSync()" onchange="delivApply()" title="고른 값이 여기 들어옵니다. 다르게 쓰려면 이 칸에 직접 적으세요">
        <span class="dim" style="font-size:12px">→ 제목 줄·비고에 들어갑니다</span></div>
      <label>제목 줄</label><input type="text" id="titleTxt" class="full" value="아래와 같이 견적을 드립니다.(센터배송, 부가세 별도)">
      <label>비고</label><textarea id="remark" class="full" placeholder="예: 배송비 포함, 부가세 별도"></textarea>
    </div>
  </div>

  <div class="card">
    <div class="hd">품목 <small>— 금액 = 수량 × 단가(자동). [🔍 상품]으로 우리 상품에서 품명·규격·판매가를 채울 수 있습니다</small>
      <span class="bar" style="margin-left:auto"><button class="btn" onclick="addLine()">＋ 줄 추가</button></span>
    </div>
    <div class="tw"><table class="g"><thead id="lhead"></thead><tbody id="lbody"></tbody></table></div>
    <div class="bar" style="padding:10px 12px">
      <button class="btn btn-teal" id="saveBtn" onclick="save()">💾 저장</button>
      <button class="btn" id="printBtn" onclick="printIt()" title="저장한 견적서를 A4 양식으로">🖨 출력</button>
      <button class="btn" onclick="excel()">📥 엑셀</button>
      <button class="btn" onclick="newDoc()">✨ 새 견적서</button>
      <span class="tot" style="margin-left:auto" id="tot"></span>
    </div>
  </div>
</div>

<div class="pop" id="prodPop">
  <div class="box">
    <div class="ph"><b>🔍 상품 찾기</b><input type="text" id="prodQ" placeholder="상품코드 · 품명 · 규격 (두 글자 이상)" oninput="prodSearch()"><button class="btn" onclick="document.getElementById('prodPop').classList.remove('on')">닫기 ✕</button></div>
    <div class="pb"><table class="g"><thead><tr><th>코드</th><th>품명</th><th>규격</th><th>입수</th><th>판매가</th></tr></thead><tbody id="prodBody"><tr><td colspan="5" class="dim" style="padding:20px">글자를 치면 찾습니다.</td></tr></tbody></table></div>
  </div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _seq=0, _lines=[], _prodRow=-1, _prodT=null, _savedSeq=0, _savedDocNo='';   /* _savedDocNo = 이 화면에서 방금 저장한 문서번호 — 다시 저장할 땐 중복 확인 없이 덮어쓴다 */
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ var x=n(v); return (Math.round(x*100)/100).toLocaleString(); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin',
  headers:{'Content-Type': isJson?'application/json':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }
function ok(m){ _alertBox(m,{icon:'✅'}); }
function err(m){ _alertBox(m,{icon:'❌', okColor:'red'}); }
function ask(m, okText){ return new Promise(function(res){ _confirmBox({ msg:m, icon:'❓', okText:okText||'확인', onOk:function(){res(true);}, onCancel:function(){res(false);} }); }); }
function use2(){ return document.getElementById('use2').checked; }

/* ── 줄 ── */
function blank(){ return { prodNm:'', spec:'', boxQty:1, qty:0, unit:'ea', unitPrice:0, unitPrice2:0, remark:'' }; }
function addLine(){ _lines.push(blank()); renderLines(); var tb=document.getElementById('lbody'); var last=tb.querySelectorAll('tr'); var el=last[last.length-1]&&last[last.length-1].querySelector('.nm'); if(el) el.focus(); }
function renderLines(){
  var h2=use2();
  document.getElementById('lhead').innerHTML='<tr><th style="width:36px">No</th><th style="min-width:220px">품명</th><th style="min-width:220px">규격</th><th style="width:64px">Box</th><th style="width:84px">수량</th><th style="width:56px">단위</th>'
    +(h2?'<th style="width:90px">'+esc(gv('p1')||'단가1')+' 단가</th><th style="width:100px">금액</th><th style="width:90px">'+esc(gv('p2')||'단가2')+' 단가</th><th style="width:100px">금액</th>':'<th style="width:90px">단가</th><th style="width:100px">금액</th>')
    +'<th style="min-width:120px">'+(h2?'비고 (MOQ)':'비고')+'</th><th style="width:40px"></th></tr>';
  if(!_lines.length) _lines.push(blank());
  var tb=document.getElementById('lbody'), sum=0;
  tb.innerHTML=_lines.map(function(l,i){
    var amt=Math.round(n(l.qty)*n(l.unitPrice)), amt2=Math.round(n(l.qty)*n(l.unitPrice2)); sum+=amt;
    return '<tr><td>'+(i+1)+'</td>'
      +'<td><div style="display:flex;gap:4px"><input type="text" class="nm" value="'+esc(l.prodNm)+'" placeholder="품명" oninput="_lines['+i+'].prodNm=this.value"><button class="btn lnk" style="height:30px" onclick="prodOpen('+i+')" title="우리 상품에서 고르기">🔍</button></div></td>'
      +'<td><input type="text" value="'+esc(l.spec)+'" placeholder="규격 및 재질" oninput="_lines['+i+'].spec=this.value"></td>'
      +'<td><input type="text" class="num" value="'+(n(l.boxQty)?fmt(l.boxQty):'')+'" oninput="_lines['+i+'].boxQty=n(this.value)"></td>'
      +'<td><input type="text" class="num" value="'+(n(l.qty)?fmt(l.qty):'')+'" placeholder="0" onfocus="this.select()" oninput="_lines['+i+'].qty=n(this.value); calc()"></td>'
      +'<td><input type="text" value="'+esc(l.unit)+'" style="text-align:center" oninput="_lines['+i+'].unit=this.value"></td>'
      +'<td><input type="text" class="num" value="'+(n(l.unitPrice)?fmt(l.unitPrice):'')+'" placeholder="0" onfocus="this.select()" oninput="_lines['+i+'].unitPrice=n(this.value); calc()"></td>'
      +'<td class="amt" id="amt'+i+'">'+(amt?fmt(amt):'')+'</td>'
      +(h2?'<td><input type="text" class="num" value="'+(n(l.unitPrice2)?fmt(l.unitPrice2):'')+'" placeholder="0" onfocus="this.select()" oninput="_lines['+i+'].unitPrice2=n(this.value); calc()"></td><td class="amt" id="amt2_'+i+'">'+(amt2?fmt(amt2):'')+'</td>':'')
      +'<td><input type="text" value="'+esc(l.remark)+'" placeholder="예: MOQ 50,000개" oninput="_lines['+i+'].remark=this.value"></td>'
      +'<td><button class="btn lnk" title="이 줄 빼기" onclick="_lines.splice('+i+',1); renderLines()">✕</button></td></tr>';
  }).join('');
  calc();
}
function calc(){
  var sum=0, sum2=0, h2=use2();
  _lines.forEach(function(l,i){ var a=Math.round(n(l.qty)*n(l.unitPrice)), a2=Math.round(n(l.qty)*n(l.unitPrice2)); sum+=a; sum2+=a2;
    var e=document.getElementById('amt'+i); if(e) e.textContent=a?fmt(a):''; var e2=document.getElementById('amt2_'+i); if(e2) e2.textContent=a2?fmt(a2):''; });
  document.getElementById('tot').innerHTML='품목 <b>'+_lines.filter(function(l){ return (l.prodNm||'').trim()||n(l.qty); }).length+'</b>줄 · 합계 <b>'+fmt(sum)+'</b>원'+(h2?' · '+esc(gv('p2')||'둘째')+' 합계 <b>'+fmt(sum2)+'</b>원':'')+' (부가세 별도)';
}

/* ── 상품 찾기 (우리 상품 마스터) ── */
function prodOpen(i){ _prodRow=i; document.getElementById('prodPop').classList.add('on'); var q=document.getElementById('prodQ'); q.value=(_lines[i]&&_lines[i].prodNm)||''; q.focus(); if(q.value.trim().length>=2) prodSearch(); }
function prodSearch(){
  clearTimeout(_prodT);
  var q=gv('prodQ'); if(q.length<2){ document.getElementById('prodBody').innerHTML='<tr><td colspan="5" class="dim" style="padding:20px">두 글자 이상 치면 찾습니다.</td></tr>'; return; }
  _prodT=setTimeout(function(){
    post('/prod/prodList.do','findData='+encodeURIComponent(q)).then(function(r){ return r.json(); }).then(function(j){
      var rows=((j&&j.data)||[]).filter(function(p){ return p.stopYn!=='Y'; }).slice(0,80);
      document.getElementById('prodBody').innerHTML = rows.length ? rows.map(function(p,k){
        return '<tr class="pick" onclick="prodPick('+k+')" data-k="'+k+'"><td>'+esc(p.prodCd)+'</td><td style="text-align:left">'+esc(p.prodNm)+'</td><td style="text-align:left">'+esc(p.spec||'')+'</td><td>'+fmt(p.packQty)+'</td><td style="text-align:right">'+fmt(p.salePrice)+'</td></tr>'; }).join('')
        : '<tr><td colspan="5" class="dim" style="padding:20px">없습니다.</td></tr>';
      window._prodRows=rows;
    }).catch(function(){});
  }, 250);
}
function prodPick(k){
  var p=(window._prodRows||[])[k], l=_lines[_prodRow]; if(!p||!l) return;
  l.prodNm=p.prodNm||''; l.spec=p.spec||''; l.prodCd=p.prodCd||''; if(!n(l.unitPrice)) l.unitPrice=n(p.salePrice); if(!n(l.qty) && n(p.packQty)>1) l.qty=n(p.packQty);
  document.getElementById('prodPop').classList.remove('on'); renderLines();
}

/* 쌓인 담당자·수신 이름 (2026-09-17) — datalist 로 보여 주고, 새 견적서면 최근 담당자를 기본으로 */
var _names={ mgr:[], recv:[] };
function loadNames(cb){
  post('/mangr/quoteNames.do','').then(function(r){ return r.json(); }).then(function(j){
    _names={ mgr:(j&&j.mgr)||[], recv:(j&&j.recv)||[] };
    document.getElementById('mgrList').innerHTML=_names.mgr.map(function(v){ return '<option value="'+esc(v)+'">'; }).join('');
    document.getElementById('recvList').innerHTML=_names.recv.map(function(v){ return '<option value="'+esc(v)+'">'; }).join('');
    if(cb) cb();
  }).catch(function(){ if(cb) cb(); });
}
/* 배송 조건 (2026-09-17 「직접 작성 시 배송 내용도 추가」) — 표본 견적서처럼 제목 줄 「(센터배송, 부가세 별도)」와 비고 「1. 센터배송」에 넣는다.
   제목 줄은 「(…, 부가세 별도)」 괄호를 바꿔 끼우고, 비고는 비었거나 앞서 넣은 배송 줄 그대로일 때만 바꾼다(사람이 고친 비고는 안 건드린다). */
var _delivPrev='', _delivRmk='';
var DELIV_DEF2='센터배송 / 택배출고 (D2~3)', DELIV_DEF1='센터배송';   /* 양식별 기본 배송 (「이것을 기본으로」) */
function delivTitle(v){ var t=gv('titleTxt')||'아래와 같이 견적을 드립니다.(부가세 별도)'; var par=v?'('+v+', 부가세 별도)':'(부가세 별도)';
  if(/\(.*부가세 별도\)\s*$/.test(t)) return t.replace(/\(.*부가세 별도\)\s*$/, par); return t.replace(/\s*$/,'')+par; }
function delivApply(){
  var v=(gv('deliv')||'').trim(); delivSync();
  document.getElementById('titleTxt').value=delivTitle(v);
  var r=document.getElementById('remark'), cur=(r.value||'').trim();
  var rmk=!v?'':(use2()?v+', 부가세 별도':'1. '+v);   /* 표본 꼴 — 양식1 「1. 센타배송」, 양식2 「배송비 포함, 부가세 별도」 */
  if(cur===''||(_delivRmk&&cur===_delivRmk)) r.value=rmk;   /* 사람이 고친 비고는 안 건드린다 */
  _delivPrev=v; _delivRmk=rmk;
}
function delivPick(v){ if(v==='*'){ var d=document.getElementById('deliv'); d.focus(); d.select(); return; } document.getElementById('deliv').value=v; delivApply(); }
function delivSync(){ var v=(gv('deliv')||'').trim(), sel=document.getElementById('delivSel'), hit=false;   /* 직접 적은 값이 목록에 있으면 그것을, 없으면 「직접 입력…」을 고른 상태로 */
  for(var i=0;i<sel.options.length;i++){ if(sel.options[i].value===v){ sel.selectedIndex=i; hit=true; break; } } if(!hit) sel.value='*'; }
/* 양식을 바꾸면 배송 기본값도 따라간다 — 양식2 「센터배송 / 택배출고 (D2~3)」, 양식1 「센터배송」 (사람이 다르게 적어 둔 값은 그대로) */
function delivOnUse2(){ var d=document.getElementById('deliv'); if(use2()&&d.value===DELIV_DEF1){ d.value=DELIV_DEF2; delivApply(); } else if(!use2()&&d.value===DELIV_DEF2){ d.value=DELIV_DEF1; delivApply(); } else delivApply(); }
function delivFromTitle(t){ var m=/\((.*?),\s*부가세 별도\)\s*$/.exec(t||''); return m?m[1].trim():''; }
/* ── 번호 · 불러오기 ── */
function nextNo(force){
  if(!force && gv('docNo')) return;
  post('/mangr/quoteNextNo.do','quoteDt='+encodeURIComponent(gv('quoteDt'))).then(function(r){ return r.json(); }).then(function(j){ if(j&&j.docNo) document.getElementById('docNo').value=j.docNo; }).catch(function(){});
}
function newDoc(){
  _seq=0; _savedSeq=0; _savedDocNo=''; _lines=[blank()]; document.getElementById('mode').textContent='새 견적서';
  var t=new Date(); document.getElementById('quoteDt').value=t.getFullYear()+'-'+('0'+(t.getMonth()+1)).slice(-2)+'-'+('0'+t.getDate()).slice(-2);
  document.getElementById('docNo').value=''; document.getElementById('mgrNm').value=''; document.getElementById('remark').value='';
  document.getElementById('recvNm').value='삼성웰스토리'; document.getElementById('validTxt').value='견적일로부터 15일'; document.getElementById('titleTxt').value='아래와 같이 견적을 드립니다.(부가세 별도)';
  document.getElementById('use2').checked=true; document.getElementById('p1').value='센터배송'; document.getElementById('p2').value='택배출고 (D2~3)';   /* 기본 = 양식 2 (2026-09-17 「직접 작성 시 이런 내용 포함이 안 됨」) */
  document.getElementById('deliv').value=DELIV_DEF2; _delivPrev=''; _delivRmk=''; delivApply();   /* 배송 기본 → 제목 줄·비고 */
  renderLines(); nextNo(true);
  loadNames(function(){ var m=document.getElementById('mgrNm'); if(!m.value && _names.mgr.length) m.value=_names.mgr[0]; });   /* 최근 담당자를 기본으로 */
}
function loadDoc(seq){
  post('/mangr/quoteMst.do','quoteSeq='+encodeURIComponent(seq)).then(function(r){ return r.json(); }).then(function(j){
    var m=j&&j.mst; if(!m){ err('견적서를 찾을 수 없습니다.'); newDoc(); return; }
    _seq=seq; _savedSeq=seq; document.getElementById('mode').textContent='수정 — '+m.docNo;
    document.getElementById('docNo').value=m.docNo; document.getElementById('quoteDt').value=d10(m.quoteDt); document.getElementById('recvNm').value=m.recvNm; document.getElementById('mgrNm').value=m.mgrNm;
    document.getElementById('validTxt').value=m.validTxt; document.getElementById('titleTxt').value=m.titleTxt; document.getElementById('remark').value=m.remark;
    var h2=!!m.price2Nm; document.getElementById('use2').checked=h2; document.getElementById('use1').checked=!h2; if(m.price1Nm) document.getElementById('p1').value=m.price1Nm; if(m.price2Nm) document.getElementById('p2').value=m.price2Nm;
    _delivPrev=delivFromTitle(m.titleTxt); _delivRmk=''; document.getElementById('deliv').value=_delivPrev; delivSync();   /* 저장된 제목 줄의 「(…, 부가세 별도)」에서 배송을 읽는다 */
    _lines=((j&&j.lines)||[]).map(function(l){ return { prodNm:l.prodNm, spec:l.spec, boxQty:l.boxQty==null?'':n(l.boxQty), qty:n(l.qty), unit:l.unit||'ea', unitPrice:n(l.unitPrice), unitPrice2:n(l.unitPrice2), remark:l.remark, prodCd:l.prodCd||'' }; });
    renderLines();
  }).catch(function(e){ err('불러오지 못했습니다 — '+esc(e.message)); });
}

/* ── 저장 · 출력 · 엑셀 ── */
function payload(){
  var h2=use2();
  return { confirm: _seq?'Y':'N', docs:[{ docNo:gv('docNo'), quoteDt:gv('quoteDt'), recvNm:gv('recvNm'), mgrNm:gv('mgrNm'), validTxt:gv('validTxt'), titleTxt:gv('titleTxt'), remark:gv('remark'),
    price1Nm: h2?gv('p1'):'', price2Nm: h2?gv('p2'):'', fileNm:'', fileB64:'',
    lines:_lines.filter(function(l){ return (l.prodNm||'').trim()||n(l.qty); }).map(function(l,i){ return { rowNo:i+1, prodNm:l.prodNm, spec:l.spec, boxQty:(l.boxQty===''||l.boxQty==null)?null:n(l.boxQty), unit:l.unit, qty:n(l.qty), unitPrice:n(l.unitPrice), amt:Math.round(n(l.qty)*n(l.unitPrice)), unitPrice2:h2?n(l.unitPrice2):null, amt2:h2?Math.round(n(l.qty)*n(l.unitPrice2)):null, remark:l.remark, prodCd:l.prodCd||'' }; }) }] };
}
function save(){
  var p=payload(), d=p.docs[0];
  if(!d.docNo){ _alertBox('문서번호를 넣으세요.',{icon:'⚠️'}); return; }
  if(!d.quoteDt){ _alertBox('견적일을 고르세요.',{icon:'⚠️'}); return; }
  if(!d.lines.length){ _alertBox('품목을 한 줄 이상 적으세요.',{icon:'⚠️'}); return; }
  var noP=d.lines.filter(function(l){ return !l.qty || !l.unitPrice; });
  var sum=0; d.lines.forEach(function(l){ sum+=l.amt; });
  ask('견적서 <b>'+esc(d.docNo)+'</b>를 저장합니다.<br><span style="font-size:13px;color:#3d4d5c">'+d10(d.quoteDt)+' · '+esc(d.recvNm)+' · '+esc(d.mgrNm)+' · 품목 '+d.lines.length+'줄 · 합계 <b>'+fmt(sum)+'</b>원'+(noP.length?'<br><span style="color:#b45309">⚠ 수량이나 단가가 빈 줄 '+noP.length+'개</span>':'')+'</span>', _seq?'덮어쓰기':'저장')
  .then(function(y){ if(!y) return;
    var b=document.getElementById('saveBtn'); b.disabled=true;
    var send=function(conf){ p.confirm=conf?'Y':'N'; return post('/mangr/quoteSave.do', p, true).then(function(r){ return r.text().then(function(t){ return { st:r.status, ok:r.ok, t:t }; }); }); };
    send(!!_seq || (_savedDocNo && _savedDocNo===d.docNo)).then(function(res){
      if(res.st===409) return ask('<b>같은 문서번호</b>가 이미 있습니다.<br><span style="font-size:13px;color:#3d4d5c;white-space:pre-line">'+esc(res.t)+'</span><br><span style="font-size:13px;color:#3d4d5c">덮어쓰면 앞의 것은 이력으로 남습니다. 새 번호로 하려면 [취소] 후 [↻ 번호].</span>','덮어쓰기').then(function(y2){ if(!y2) throw new Error('__cancel'); return send(true); });
      return res;
    }).then(function(res){
      if(!res.ok) throw new Error(res.t);
      var jr={}; try{ jr=JSON.parse(res.t); }catch(e){ var m=/\|(\d+)/.exec(String(res.t)); if(m) jr={ seq:+m[1] }; }
      try{ console.log('quoteSave 응답', res.t); }catch(e){}
      var seq=n(jr.seq); _savedDocNo=d.docNo;
      /* ★번호는 서버에 문서번호로 다시 물어 확정한다 (2026-09-17 「저장 후 출력 시 오류」) — 대체 저장이면 옛 번호는 이력(N)이 되므로
           응답 번호가 비거나 늦게 오면 옛 번호로 인쇄해 「찾을 수 없습니다」가 났다. 확정될 때까지 출력 창을 띄우지 않는다. */
      return post('/mangr/quoteByDoc.do','docNo='+encodeURIComponent(d.docNo)).then(function(r){ return r.json(); }).then(function(j){
        var s2=n(j&&j.quoteSeq); if(s2) seq=s2;
        _seq=seq||_seq; _savedSeq=seq||_savedSeq;
      }).catch(function(){ _seq=seq||_seq; _savedSeq=seq||_savedSeq; });
    }).then(function(){
      document.getElementById('mode').textContent='수정 — '+d.docNo;
      ok('견적서 <b>'+esc(d.docNo)+'</b>를 저장했습니다.<br><span style="font-size:13px;color:#3d4d5c">인쇄는 [🖨 출력], 엑셀은 [📥 엑셀] 단추로.</span>');   /* 저장 뒤 자동으로 출력을 묻지 않는다(2026-09-17 「별도 출력하게」) */
    }).catch(function(e){ if(String(e&&e.message)!=='__cancel') err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
    .then(function(){ b.disabled=false; });
  });
}
function printIt(){ if(!_savedSeq){ _alertBox('먼저 [💾 저장]을 하세요 — 저장된 견적서를 인쇄합니다.',{icon:'ℹ️'}); return; } window.open(CTX+'/mangr/quotePrint.do?quoteSeq='+_savedSeq, '_blank'); }
/* 엑셀 = 서버가 우리 양식 파일(quote_tpl1/2.xls)에 값을 채워 준다 (2026-09-17 「양식 그대로」). 저장된 견적서만 — 화면 표를 시트로 만들던 옛 길은 아래(excelSheet)에 남겨 둔다(안 쓴다) */
function excel(){ if(!_savedSeq){ _alertBox('먼저 [💾 저장]을 하세요 — 저장된 견적서를 양식 그대로 엑셀로 냅니다.',{icon:'ℹ️'}); return; } window.open(CTX+'/mangr/quoteExcel.do?quoteSeq='+_savedSeq, '_blank'); }
function excelSheet(){
  if(typeof XLSX==='undefined'){ _alertBox('엑셀 모듈이 없습니다.',{icon:'⚠️'}); return; }
  var h2=use2(), d=payload().docs[0];
  var aoa=[['견 적 서'],[],['문서번호',d.docNo,'','수신',d.recvNm],['견적일',d10(d.quoteDt),'','담당자',d.mgrNm],['유효기간',d.validTxt],[],[d.titleTxt],[]];
  var head=['No','품명','규격','Box','수량','단위']; if(h2){ head.push(d.price1Nm+' 단가', d.price1Nm+' 금액', d.price2Nm+' 단가', d.price2Nm+' 금액'); } else head.push('단가','금액'); head.push('비고'); aoa.push(head);
  d.lines.forEach(function(l){ var row=[l.rowNo,l.prodNm,l.spec,l.boxQty==null?'':l.boxQty,l.qty,l.unit,l.unitPrice,l.amt]; if(h2) row.push(l.unitPrice2,l.amt2); row.push(l.remark); aoa.push(row); });
  var sum=0; d.lines.forEach(function(l){ sum+=l.amt; }); aoa.push([],['합계(부가세 별도)','','','','','','',sum]); if(d.remark) aoa.push([],['비고',d.remark]);
  var ws=XLSX.utils.aoa_to_sheet(aoa), wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '견적서');
  XLSX.writeFile(wb, (d.docNo||'견적서')+'.xlsx');
}

/* 시작 — ?quoteSeq= 이면 수정, 아니면 새 견적서 */
(function(){
  var m=/[?&]quoteSeq=(\d+)/.exec(location.search);
  if(m){ loadNames(); loadDoc(+m[1]); } else newDoc();
})();
document.getElementById('p1').addEventListener('input', renderLines); document.getElementById('p2').addEventListener('input', renderLines);
window.konetShown=function(){ var m=/[?&]quoteSeq=(\d+)/.exec(location.search); if(m && +m[1]!==_seq) loadDoc(+m[1]); loadNames(); takeHandoff(); };   /* 담당자·수신 목록도 다시 (2026-09-17) */
/* 원가·마진 계산 화면이 넘긴 품목 받기 (2026-09-17) — localStorage konet.costToQuote {ts, lines:[{prodNm,spec,boxQty,qty,unitPrice,remark}], deliv}.
   10분 안의 것만. 이 화면에 적어 둔 줄이 있으면 물어보고 바꾼다. 받으면 지운다(두 번 안 들어가게). */
function takeHandoff(){
  var h=null; try{ h=JSON.parse(localStorage.getItem('konet.costToQuote')||'null'); }catch(e){}
  if(!h || !h.lines || !h.lines.length) return;
  if(Date.now()-n(h.ts)>10*60*1000){ try{ localStorage.removeItem('konet.costToQuote'); }catch(e){} return; }
  var apply=function(){
    try{ localStorage.removeItem('konet.costToQuote'); }catch(e){}
    if(_seq){ newDoc(); }
    _lines=h.lines.map(function(l){ return { prodNm:l.prodNm||'', spec:l.spec||'', boxQty:n(l.boxQty)||1, qty:n(l.qty), unit:'ea', unitPrice:n(l.unitPrice), unitPrice2:0, remark:l.remark||'', prodCd:'' }; });
    if(h.deliv){ var d=document.getElementById('deliv'); if(d){ d.value=h.deliv; delivApply(); } }
    renderLines(); _toast('원가·마진 계산에서 품목 '+_lines.length+'줄을 받았습니다.');
  };
  var typed=_lines.filter(function(l){ return (l.prodNm||'').trim()||n(l.qty); }).length;
  if(typed) _confirmBox({ msg:'원가·마진 계산에서 넘긴 품목 <b>'+h.lines.length+'</b>줄이 있습니다.<br>지금 적힌 줄을 지우고 그것으로 바꿀까요?', icon:'🧮', okText:'바꾸기', onOk:apply, onCancel:function(){} });
  else apply();
}
takeHandoff();
</script>
</body>
</html>
