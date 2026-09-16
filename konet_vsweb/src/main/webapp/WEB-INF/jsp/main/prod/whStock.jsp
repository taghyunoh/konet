<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>창고별 재고현황</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<!--
  창고별 재고현황 (2026-09-16 신설, P3 창고별 재고 1단계) — 재고 관리 ▸ 창고별 재고현황. 셸 iframe(logiFrame).
  · 한 줄 = 품목, 창고마다 한 칸 + 합계. 원천 = 재고 원장(TBL_STOCK_LEDGER.WH_CD) 창고별 합(selectStockByWh) — 합계는 품목별재고현황과 같은 숫자다.
  · 기존 원장 행은 전부 기본창고(WH1)라, 처음엔 재고가 다 제1창고에 있다 — 창고 이동(창고 관리)으로 옮기면 여기서 갈린다.
  · 종전 「물품동선관리 ▸ 창고별 재고현황」(숫자를 박아 둔 데모)은 이 화면으로 바뀌었다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:12px; font-size:12.5px; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input[type=text], .bar input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .bar label.ck{ display:flex; align-items:center; gap:5px; font-size:13px; color:#37475a; cursor:pointer; white-space:nowrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .cnt{ margin-left:auto; color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; white-space:nowrap; }
  .cnt b{ color:var(--teal); font-weight:800; }
  .kpis{ display:flex; gap:10px; flex-wrap:wrap; margin-bottom:12px; }
  .kpi{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:8px 14px; min-width:150px; }
  .kpi .l{ font-size:11.5px; color:#6b7a89; font-weight:700; }
  .kpi .v{ font-size:19px; font-weight:800; color:#1f2a37; font-variant-numeric:tabular-nums; }
  .kpi.def{ border-color:#9fcfc5; background:#f6fbfa; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; max-height:calc(100vh - 230px); }
  table.g{ border-collapse:collapse; width:100%; font-size:13.5px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:8px 9px; text-align:center; position:sticky; top:0; z-index:2; white-space:nowrap; }
  table.g th:last-child, table.g td:last-child{ border-right:none; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:6px 9px; vertical-align:middle; text-align:center; }
  table.g td.l{ text-align:left; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g td.code{ font-weight:600; white-space:nowrap; }
  table.g tr:hover td{ background:#f7faf9; }
  table.g tr.tot td{ background:#eef4f2; font-weight:800; position:sticky; top:37px; z-index:1; }
  td.neg{ color:var(--red); font-weight:800; }
  td.zero{ color:#b8c2cc; }
  .empty{ padding:40px; text-align:center; color:#8a98a8; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🏬 창고별 재고현황</h2>
  <div class="sub">품목마다 <b>창고별 재고</b>와 합계. 합계는 품목별재고현황과 같은 숫자입니다. 창고 사이 이동은 <b>기준정보관리 ▸ 창고 관리</b>에서.</div>
  <div class="bar">
    <input type="text" id="q" placeholder="품목코드 · 품목명" style="width:220px" onkeydown="if(event.key==='Enter') load()">
    <input type="date" id="asOf" title="기준일 — 비우면 지금 현재고, 날짜를 넣으면 그날까지의 재고" onchange="load()">
    <button class="btn btn-teal" onclick="load()">🔍 조회</button>
    <label class="ck"><input type="checkbox" id="hideZero" checked onchange="render()"> 재고 0 품목 숨김</label>
    <label class="ck"><input type="checkbox" id="onlySplit" onchange="render()"> 두 창고 이상에 있는 품목만</label>
    <button class="btn" onclick="excel()">📥 엑셀</button>
    <span class="cnt" id="cnt">—</span>
  </div>
  <div class="kpis" id="kpis"></div>
  <div class="card"><table class="g" id="grid"><thead id="head"></thead><tbody id="body"><tr><td class="empty">조회 중…</td></tr></tbody></table></div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _wh=[], _rows=[], _grp=[];
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body:body }); }
function load(){
  document.getElementById('body').innerHTML='<tr><td class="empty">조회 중…</td></tr>';
  post('/prod/whStockList.do','findData='+encodeURIComponent(document.getElementById('q').value||'')+'&asOfDt='+encodeURIComponent(document.getElementById('asOf').value||''))
    .then(function(r){ return r.json(); })
    .then(function(j){ _wh=(j&&j.wh)||[]; _rows=(j&&j.data)||[]; group(); render(); })
    .catch(function(e){ document.getElementById('body').innerHTML='<tr><td class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
/* 창고 열 = 사용 중인 창고 + 원장에 실제로 있는 창고(사용을 껐어도 재고가 남아 있으면 보여야 한다) */
function whCols(){
  var seen={}, cols=[];
  _wh.forEach(function(w){ if(w.useYn==='Y'){ cols.push(w); seen[w.whCd]=1; } });
  _rows.forEach(function(r){ if(!seen[r.whCd]){ var w=_wh.filter(function(x){ return x.whCd===r.whCd; })[0]; cols.push(w||{ whCd:r.whCd, whNm:r.whCd }); seen[r.whCd]=1; } });
  return cols;
}
function group(){
  var m={};
  _rows.forEach(function(r){ var k=String(r.prodCd||''); if(!k) return;
    var g=m[k]||(m[k]={ prodCd:k, prodNm:r.prodNm||'', spec:r.spec||'', q:{}, tot:0 });
    g.q[r.whCd]=n(g.q[r.whCd])+n(r.curQty); g.tot+=n(r.curQty); });
  _grp=Object.keys(m).sort().map(function(k){ return m[k]; });
}
function render(){
  var cols=whCols(), hz=document.getElementById('hideZero').checked, os=document.getElementById('onlySplit').checked;
  var l=_grp.filter(function(g){
    if(hz && cols.every(function(w){ return Math.round(n(g.q[w.whCd]))===0; })) return false;
    if(os && cols.filter(function(w){ return Math.round(n(g.q[w.whCd]))!==0; }).length<2) return false;
    return true; });
  var sum={}, tot=0; cols.forEach(function(w){ sum[w.whCd]=0; });
  l.forEach(function(g){ cols.forEach(function(w){ sum[w.whCd]+=n(g.q[w.whCd]); }); tot+=g.tot; });
  document.getElementById('kpis').innerHTML=cols.map(function(w){ return '<div class="kpi'+(w.defaultYn==='Y'?' def':'')+'"><div class="l">'+esc(w.whNm)+(w.defaultYn==='Y'?' · 기본':'')+'</div><div class="v">'+fmt(sum[w.whCd])+' <small style="font-size:12px;color:#6b7a89">EA</small></div></div>'; }).join('')
    +'<div class="kpi"><div class="l">합계</div><div class="v">'+fmt(tot)+' <small style="font-size:12px;color:#6b7a89">EA</small></div></div>';
  document.getElementById('cnt').innerHTML='품목 <b>'+l.length+'</b>'+(l.length!==_grp.length?' / '+_grp.length:'')+' · 창고 <b>'+cols.length+'</b>';
  document.getElementById('head').innerHTML='<tr><th style="width:120px">품목코드</th><th style="min-width:220px">품목명</th><th style="width:110px">규격</th>'
    +cols.map(function(w){ return '<th style="width:110px" title="'+esc(w.whCd)+'">'+esc(w.whNm)+(w.defaultYn==='Y'?' ★':'')+'</th>'; }).join('')+'<th style="width:110px">합계</th></tr>';
  if(!l.length){ document.getElementById('body').innerHTML='<tr><td colspan="'+(cols.length+4)+'" class="empty">'+(_grp.length?'조건에 맞는 품목이 없습니다 — 체크를 풀어 보세요.':'재고 원장에 자료가 없습니다.')+'</td></tr>'; return; }
  var cell=function(v){ v=Math.round(n(v)); return '<td class="r'+(v<0?' neg':(v===0?' zero':''))+'">'+(v===0?'-':v.toLocaleString())+'</td>'; };
  document.getElementById('body').innerHTML='<tr class="tot"><td class="l" colspan="3">■ 합계 ('+l.length+'품목)</td>'+cols.map(function(w){ return cell(sum[w.whCd]); }).join('')+cell(tot)+'</tr>'
    +l.map(function(g){ return '<tr><td class="code">'+esc(g.prodCd)+'</td><td class="l">'+esc(g.prodNm)+'</td><td class="l">'+esc(g.spec)+'</td>'+cols.map(function(w){ return cell(g.q[w.whCd]); }).join('')+'<td class="r"><b>'+fmt(g.tot)+'</b></td></tr>'; }).join('');
}
function excel(){
  var LIB=(window.parent&&window.parent.XLSX)||window.XLSX;
  if(!LIB){ _alertBox('엑셀 도구를 아직 못 불러왔습니다. 잠시 뒤 다시 눌러 보세요.',{icon:'⚠️'}); return; }
  var cols=whCols(), hz=document.getElementById('hideZero').checked;
  var aoa=[['품목코드','품목명','규격'].concat(cols.map(function(w){ return w.whNm; })).concat(['합계'])];
  _grp.forEach(function(g){ if(hz && Math.round(g.tot)===0 && cols.every(function(w){ return Math.round(n(g.q[w.whCd]))===0; })) return;
    aoa.push([g.prodCd,g.prodNm,g.spec].concat(cols.map(function(w){ return Math.round(n(g.q[w.whCd])); })).concat([Math.round(g.tot)])); });
  var ws=LIB.utils.aoa_to_sheet(aoa), wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb, ws, '창고별재고');
  LIB.writeFile(wb, '창고별재고현황_'+((document.getElementById('asOf').value||'현재').replace(/-/g,''))+'.xlsx');
}
window.konetShown=function(){ load(); };
load();
</script>
</body>
</html>
