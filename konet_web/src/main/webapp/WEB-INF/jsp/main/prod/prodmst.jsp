<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>상품(품목) 관리 (TBL_PROD_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  body{ margin:0; font-family:'맑은 고딕',Malgun Gothic,sans-serif; color:#1f2a37; background:var(--bg); font-size:13px; }
  .wrap{ padding:18px 20px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:260px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:auto; color:#6b7a89; font-size:12.5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  table{ width:100%; border-collapse:collapse; font-size:12.5px; white-space:nowrap; }
  thead th{ background:#1f2a37; color:#fff; font-weight:700; padding:9px 10px; text-align:left; position:sticky; top:0; z-index:1; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:6px 10px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  td.code{ font-family:Consolas,monospace; }
  td.num{ text-align:right; }
  td.nm{ white-space:normal; min-width:220px; max-width:340px; }
  .act .btn{ height:26px; padding:0 9px; font-size:11.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  #msg{ position:fixed; left:50%; bottom:26px; transform:translateX(-50%); background:#1f2a37; color:#fff; padding:10px 18px; border-radius:9px; font-size:13px; opacity:0; transition:opacity .2s; pointer-events:none; z-index:60; }
  #msg.on{ opacity:1; }
  .pager{ display:flex; gap:4px; justify-content:center; align-items:center; margin-top:14px; flex-wrap:wrap; }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  /* 모달 */
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  #ov .box{ background:#fff; width:min(720px,94vw); margin-top:5vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:90vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:13px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:16px 18px; overflow:auto; display:grid; grid-template-columns:1fr 1fr; gap:12px 16px; }
  #ov .fld{ display:flex; flex-direction:column; gap:4px; }
  #ov .fld.full{ grid-column:1 / -1; }
  #ov label{ font-size:12px; font-weight:700; color:#37475a; }
  #ov input, #ov select{ height:34px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; }
  #ov .mf{ padding:12px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📦 상품(품목) 관리</h2>
  <div class="sub">상품마스터(TBL_PROD_MST) 조회 · 추가 · 수정 · 삭제 · 엑셀출력</div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·상품명·규격·제조사·유형 검색" oninput="prodFilter()">
    <button class="btn" onclick="prodLoad()">↻ 새로고침</button>
    <button class="btn btn-teal" onclick="prodOpen()">＋ 상품 추가</button>
    <button class="btn" onclick="prodExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="card">
    <table>
      <thead><tr>
        <th>코드</th><th>상품명</th><th>규격</th><th>제조사</th><th>유형</th><th>과세</th>
        <th style="text-align:right">입수</th><th style="text-align:right">입고가</th><th style="text-align:right">판매가</th><th style="text-align:right">도매가</th>
        <th style="text-align:right">적정재고</th><th style="text-align:right">기본수량</th><th>낱개BC</th><th>박스BC</th><th style="width:110px">관리</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="15" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
</div>
<div id="msg"></div>

<!-- 추가/수정 모달 -->
<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">상품 추가</b><button class="x" onclick="prodClose()">&times;</button></div>
    <div class="mb">
      <input type="hidden" id="f_seq">
      <div class="fld"><label>코드 *</label><input id="f_cd" placeholder="예: 1000455367"></div>
      <div class="fld"><label>과세</label><select id="f_tax"><option value="과세">과세</option><option value="면세">면세</option></select></div>
      <div class="fld full"><label>상품명 *</label><input id="f_nm" placeholder="상품명"></div>
      <div class="fld full"><label>규격</label><input id="f_spec" placeholder="규격"></div>
      <div class="fld"><label>제조사명</label><input id="f_maker"></div>
      <div class="fld"><label>유형명</label><input id="f_type"></div>
      <div class="fld"><label>입수수량</label><input id="f_pack" type="number" value="1"></div>
      <div class="fld"><label>조회순서</label><input id="f_sort" type="number" value="999999"></div>
      <div class="fld"><label>입고단가</label><input id="f_in" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>판매단가</label><input id="f_sale" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>도매단가</label><input id="f_whole" type="number" step="0.01" value="0"></div>
      <div class="fld"><label>적정재고</label><input id="f_safe" type="number" value="0"></div>
      <div class="fld"><label>판매기본수량</label><input id="f_base" type="number" value="0"></div>
      <div class="fld"><label>낱개바코드</label><input id="f_ubc"></div>
      <div class="fld"><label>박스바코드</label><input id="f_bbc"></div>
    </div>
    <div class="mf">
      <button class="btn" onclick="prodClose()">취소</button>
      <button class="btn btn-teal" onclick="prodSave()">💾 저장</button>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var PROD = [], _view = [], _page = 1, PAGE_SIZE = 20, _byseq = {};

function toast(s){ var m=document.getElementById('msg'); m.innerHTML=s; m.classList.add('on'); clearTimeout(m._t); m._t=setTimeout(function(){ m.classList.remove('on'); }, 2600); }
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function num(v){ return (v==null||v==='')?'':Number(v).toLocaleString(); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }
function gnum(id){ var v=gv(id); return v===''?null:Number(v); }

function prodLoad(){
  fetch(CTX+'/prod/prodList.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.text(); })
    .then(function(txt){ var j; try{ j=JSON.parse(txt); }catch(e){ toast('⚠️ 목록 응답 오류'); return; }
      PROD=(j&&j.data)||[]; _byseq={}; PROD.forEach(function(o){ _byseq[o.prodSeq]=o; });
      prodFilter();
    })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function prodFilter(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  _view = !q ? PROD.slice() : PROD.filter(function(o){
    return [o.prodCd,o.prodNm,o.spec,o.makerNm,o.typeNm].some(function(x){ return (''+(x||'')).toLowerCase().indexOf(q)>=0; });
  });
  _page=1; prodRender();
}
function prodRender(){
  var tot=_view.length, pages=Math.max(1, Math.ceil(tot/PAGE_SIZE)); if(_page>pages)_page=pages;
  document.getElementById('cnt').textContent = tot.toLocaleString()+'건';
  var tb=document.getElementById('tb');
  if(!tot){ tb.innerHTML='<tr><td colspan="15" class="empty">데이터가 없습니다.</td></tr>'; _pager(0,1); return; }
  var start=(_page-1)*PAGE_SIZE, rows=_view.slice(start,start+PAGE_SIZE);
  tb.innerHTML = rows.map(function(o){
    return '<tr>'
      +'<td class="code">'+esc(o.prodCd)+'</td>'
      +'<td class="nm">'+esc(o.prodNm)+'</td>'
      +'<td>'+esc(o.spec)+'</td><td>'+esc(o.makerNm)+'</td><td>'+esc(o.typeNm)+'</td><td>'+esc(o.taxGb)+'</td>'
      +'<td class="num">'+num(o.packQty)+'</td><td class="num">'+num(o.inPrice)+'</td><td class="num">'+num(o.salePrice)+'</td><td class="num">'+num(o.wholePrice)+'</td>'
      +'<td class="num">'+num(o.safeStock)+'</td><td class="num">'+num(o.saleBaseQty)+'</td>'
      +'<td>'+esc(o.unitBarcode)+'</td><td>'+esc(o.boxBarcode)+'</td>'
      +'<td class="act"><button class="btn" onclick="prodOpen('+o.prodSeq+')">수정</button> <button class="btn btn-danger" onclick="prodDel('+o.prodSeq+')">삭제</button></td>'
    +'</tr>';
  }).join('');
  _pager(pages,_page);
}
function _go(p){ _page=p; prodRender(); }
function _pager(pages,cur){
  var el=document.getElementById('pager'); if(pages<=1){ el.innerHTML=''; return; }
  var h='<button '+(cur<=1?'disabled':'')+' onclick="_go('+(cur-1)+')">‹</button>';
  var from=Math.max(1,cur-3), to=Math.min(pages,cur+3);
  if(from>1){ h+='<button onclick="_go(1)">1</button>'; if(from>2)h+='<span class="ell">…</span>'; }
  for(var p=from;p<=to;p++) h+='<button class="'+(p===cur?'on':'')+'" onclick="_go('+p+')">'+p+'</button>';
  if(to<pages){ if(to<pages-1)h+='<span class="ell">…</span>'; h+='<button onclick="_go('+pages+')">'+pages+'</button>'; }
  h+='<button '+(cur>=pages?'disabled':'')+' onclick="_go('+(cur+1)+')">›</button>';
  el.innerHTML=h;
}

function prodOpen(seq){
  var o = seq!=null ? _byseq[seq] : null;
  document.getElementById('ovTit').textContent = o ? '상품 수정' : '상품 추가';
  document.getElementById('f_seq').value = o ? o.prodSeq : '';
  document.getElementById('f_cd').value = o ? (o.prodCd||'') : '';
  document.getElementById('f_cd').readOnly = !!o;   // 수정 시 코드는 잠금(원하면 해제 가능)
  document.getElementById('f_nm').value = o ? (o.prodNm||'') : '';
  document.getElementById('f_spec').value = o ? (o.spec||'') : '';
  document.getElementById('f_maker').value = o ? (o.makerNm||'') : '';
  document.getElementById('f_type').value = o ? (o.typeNm||'') : '';
  document.getElementById('f_tax').value = o ? (o.taxGb||'과세') : '과세';
  document.getElementById('f_pack').value = o ? (o.packQty!=null?o.packQty:1) : 1;
  document.getElementById('f_sort').value = o ? (o.sortOrd!=null?o.sortOrd:999999) : 999999;
  document.getElementById('f_in').value = o ? (o.inPrice!=null?o.inPrice:0) : 0;
  document.getElementById('f_sale').value = o ? (o.salePrice!=null?o.salePrice:0) : 0;
  document.getElementById('f_whole').value = o ? (o.wholePrice!=null?o.wholePrice:0) : 0;
  document.getElementById('f_safe').value = o ? (o.safeStock!=null?o.safeStock:0) : 0;
  document.getElementById('f_base').value = o ? (o.saleBaseQty!=null?o.saleBaseQty:0) : 0;
  document.getElementById('f_ubc').value = o ? (o.unitBarcode||'') : '';
  document.getElementById('f_bbc').value = o ? (o.boxBarcode||'') : '';
  document.getElementById('ov').classList.add('on');
}
function prodClose(){ document.getElementById('ov').classList.remove('on'); }

function prodSave(){
  var seq=gv('f_seq'), cd=gv('f_cd'), nm=gv('f_nm');
  if(!cd){ toast('⚠️ 코드를 입력하세요.'); return; }
  if(!nm){ toast('⚠️ 상품명을 입력하세요.'); return; }
  var dto={ prodCd:cd, prodNm:nm, spec:gv('f_spec')||null, makerNm:gv('f_maker')||null, typeNm:gv('f_type')||null,
    taxGb:gv('f_tax')||null, packQty:gnum('f_pack'), sortOrd:gnum('f_sort'),
    inPrice:gnum('f_in'), salePrice:gnum('f_sale'), wholePrice:gnum('f_whole'),
    safeStock:gnum('f_safe'), saleBaseQty:gnum('f_base'),
    unitBarcode:gv('f_ubc')||null, boxBarcode:gv('f_bbc')||null };
  var url, okmsg;
  if(seq){ dto.prodSeq=Number(seq); url='/prod/prodUpdate.do'; okmsg='💾 수정 완료'; }
  else   { url='/prod/prodInsert.do'; okmsg='＋ 등록 완료'; }
  fetch(CTX+url, { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('⚠️ 실패 (HTTP '+r.status+'): '+(r.t||'').slice(0,120)); return; } prodClose(); toast(okmsg); prodLoad(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function prodDel(seq){
  var o=_byseq[seq]; if(!o) return;
  if(!confirm('['+o.prodCd+'] '+(o.prodNm||'')+'\n삭제하시겠습니까? (이력 보존)')) return;
  fetch(CTX+'/prod/prodDelete.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({prodSeq:Number(seq)}) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok, status:res.status, t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('⚠️ 삭제 실패 (HTTP '+r.status+')'); return; } toast('🗑️ 삭제 완료'); prodLoad(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}

function prodExcel(){
  var list=_view;
  if(!list.length){ toast('⚠️ 출력할 데이터가 없습니다.'); return; }
  var head=['코드','상품명','규격','제조사','유형','과세','입수수량','입고단가','판매단가','도매단가','적정재고','판매기본수량','낱개바코드','박스바코드','조회순서'];
  var aoa=[head].concat(list.map(function(o){ return [o.prodCd,o.prodNm,o.spec,o.makerNm,o.typeNm,o.taxGb,o.packQty,o.inPrice,o.salePrice,o.wholePrice,o.safeStock,o.saleBaseQty,o.unitBarcode,o.boxBarcode,o.sortOrd]; }));
  var P=window.parent;
  function byLib(LIB){
    var ws=LIB.utils.aoa_to_sheet(aoa);
    ws['!cols']=[{wch:14},{wch:44},{wch:16},{wch:14},{wch:16},{wch:6},{wch:8},{wch:11},{wch:11},{wch:11},{wch:9},{wch:9},{wch:16},{wch:16},{wch:9}];
    var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'상품마스터'); LIB.writeFile(wb,'상품마스터.xlsx'); toast('📥 엑셀 저장 완료 · '+list.length+'건');
  }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csvFallback(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csvFallback();
  function csvFallback(){
    var csv=aoa.map(function(r){ return r.map(function(c){ c=(c==null?'':(''+c)); return '"'+c.replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var blob=new Blob(['﻿'+csv],{type:'text/csv;charset=utf-8'}); var a=document.createElement('a');
    a.href=URL.createObjectURL(blob); a.download='상품마스터.csv'; document.body.appendChild(a); a.click(); a.remove();
    toast('📥 CSV 저장 완료 · '+list.length+'건');
  }
}

prodLoad();
</script>
</body>
</html>
