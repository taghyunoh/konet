<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>거래처별 매입가 비교</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_toast) — 브라우저 alert 금지 --%>
<!--
  거래처별 매입가 비교 (2026-09-16 신설, 프로그램 목적 ③「거래처별 매입가 파악을 통한 효율적인 구매」) — 매입 관리 ▸ 거래처별 매입가 비교. 사이드바 iframe(logiFrame) 화면.
  · 한 줄 = 품목. 그 품목을 사 온 거래처들을 **최근 단가 싼 차례**로 나란히 놓고, 최저 거래처와 「마스터 매입가 − 최저 최근가」 차액을 짚는다.
  · 원천 = TBL_PROD_INPRICE_HST(매입 저장마다 쌓이는 품목×거래처×일자 단가 + 손 등록) — 최근가·최근일·최저·최고·건수.
    가중평균·수량은 매입전표(반품 제외)에서. SQL selectVendorPriceCmp · 자료 /mangr/vendorPriceCmpList.do
  · 기본 = 최근 6개월 · 거래처 2곳 이상인 품목만(비교가 되는 것만) · 차액 큰 순. 체크를 풀면 한 곳뿐인 품목도 본다.
  · ★마스터 매입가(상품마스터 IN_PRICE)는 발주서·매입등록이 기본으로 쓰는 값이다 — 그보다 싼 거래처가 있으면 빨갛게 보인다.
  · 발주서 관리의 상품 팝업도 같은 자료로 「최저 거래처」 칸을 보여 준다(발주하는 순간 보이게 — P2-b).
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
  .bar input[type=text], .bar select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .bar label.ck{ display:flex; align-items:center; gap:5px; font-size:13px; color:#37475a; cursor:pointer; white-space:nowrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .cnt{ margin-left:auto; color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; white-space:nowrap; }
  .cnt b{ color:var(--teal); font-weight:800; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; max-height:calc(100vh - 150px); }
  table.g{ border-collapse:collapse; width:100%; font-size:13.5px; }
  table.g th{ background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:8px 9px; text-align:center; position:sticky; top:0; z-index:2; white-space:nowrap; }
  table.g th:last-child{ border-right:none; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:6px 9px; vertical-align:middle; text-align:center; }
  table.g td:last-child{ border-right:none; }
  table.g td.l{ text-align:left; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g td.code{ font-weight:600; white-space:nowrap; }
  table.g tr:hover td{ background:#f7faf9; }
  td.diff.pos{ color:var(--red); font-weight:800; }
  td.diff.zero{ color:#8a98a8; }
  /* 거래처 칩 — 싼 차례. 최저 = 초록 테두리, 마스터 매입처 = ★ */
  .chips{ display:flex; flex-wrap:wrap; gap:6px; }
  .chip{ display:inline-flex; flex-direction:column; align-items:flex-start; border:1px solid var(--bd); border-radius:8px; padding:4px 8px; background:#fafbfc; font-size:12.5px; line-height:1.3; white-space:nowrap; }
  .chip b{ font-size:13.5px; color:#1f2a37; }
  .chip small{ color:#6b7a89; font-size:11px; }
  .chip.best{ border-color:var(--teal); background:#eef8f5; }
  .chip.best b{ color:var(--teal); }
  .chip.mst .nm::after{ content:' ★'; color:#b06a00; }
  .chip .nm{ font-weight:700; color:#37475a; }
  .empty{ padding:40px; text-align:center; color:#8a98a8; }
  .dim{ color:#8a98a8; }
</style>
</head>
<body>
<div class="wrap">
  <h2>💰 거래처별 매입가 비교</h2>
  <div class="sub">같은 품목을 <b>어느 거래처에서 얼마에 샀는지</b> 나란히 봅니다. 칩은 <b>최근 단가가 싼 차례</b>, 초록 = 최저 거래처, ★ = 상품마스터에 적힌 매입처. 차액 = 마스터 매입가 − 최저 최근가(빨강이면 더 싸게 사는 곳이 있습니다).</div>
  <div class="bar">
    <input type="text" id="q" placeholder="품목코드 · 품목명" style="width:220px" onkeydown="if(event.key==='Enter') load()">
    <select id="months" onchange="load()" title="이 기간 안의 매입 단가만 봅니다">
      <option value="3">최근 3개월</option><option value="6" selected>최근 6개월</option><option value="12">최근 12개월</option><option value="0">전체 기간</option>
    </select>
    <button class="btn btn-teal" onclick="load()">🔍 조회</button>
    <label class="ck"><input type="checkbox" id="only2" checked onchange="render()"> 거래처 2곳 이상만</label>
    <label class="ck"><input type="checkbox" id="onlyDiff" onchange="render()"> 더 싼 곳이 있는 품목만</label>
    <select id="sort" onchange="render()">
      <option value="diff">차액 큰 순</option><option value="code">품목코드 순</option><option value="vend">거래처 많은 순</option>
    </select>
    <button class="btn" onclick="excel()">📥 엑셀</button>
    <span class="cnt" id="cnt">—</span>
  </div>
  <div class="card"><table class="g" id="grid">
    <thead><tr>
      <th style="width:110px">품목코드</th><th style="min-width:200px">품목명</th><th style="width:120px">규격</th>
      <th style="width:96px" title="상품마스터 IN_PRICE — 발주서·매입등록이 기본으로 쓰는 단가">마스터<br>매입가</th>
      <th style="width:110px" title="상품마스터에 적힌 매입처">마스터<br>매입처</th>
      <th style="width:54px">거래처<br>수</th>
      <th style="width:130px" title="최근 단가가 가장 싼 거래처">최저 거래처</th>
      <th style="width:90px">최저<br>최근가</th>
      <th style="width:90px" title="마스터 매입가 − 최저 최근가. 양수면 마스터보다 싸게 사는 곳이 있다">차액</th>
      <th style="min-width:420px">거래처별 (최근가 · 최근일 · 평균 · 최저~최고 · 건수 · 수량)</th>
    </tr></thead>
    <tbody id="body"><tr><td colspan="10" class="empty">조회 중…</td></tr></tbody>
  </table></div>
</div>
<script>
var CTX='${pageContext.request.contextPath}';
var _raw=[], _grp=[];
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function fmtP(v){ v=Math.round(n(v)*100)/100; return v.toLocaleString(undefined,{maximumFractionDigits:2}); }
function d8(d){ d=''+(d||''); return /^\d{8}$/.test(d)?(d.slice(2,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8)):d; }
function toast(s, icon){ if(window._alertBox) return _alertBox(s,{icon:icon||'ℹ️'}); }
function post(url, body){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body:body }); }

function load(){
  document.getElementById('body').innerHTML='<tr><td colspan="10" class="empty">조회 중…</td></tr>';
  post('/mangr/vendorPriceCmpList.do','findData='+encodeURIComponent(document.getElementById('q').value||'')+'&months='+encodeURIComponent(document.getElementById('months').value))
    .then(function(r){ return r.json(); })
    .then(function(j){ _raw=(j&&j.data)||[]; group(); render(); })
    .catch(function(e){ document.getElementById('body').innerHTML='<tr><td colspan="10" class="empty" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
/* 품목별로 묶고 거래처는 최근가 싼 차례로 — 최저·마스터 매입처·차액을 미리 센다 */
function group(){
  var m={};
  _raw.forEach(function(r){ var k=String(r.prodCd||''); if(!k) return;
    var g=m[k]||(m[k]={ prodCd:k, prodNm:r.prodNm||'', spec:r.spec||'', mstPrice:n(r.mstPrice), mstVendorCd:String(r.mstVendorCd||''), vendors:[] });
    g.vendors.push({ vendorCd:String(r.vendorCd||''), vendorNm:r.vendorNm||r.vendorCd||'', lastPrice:n(r.lastPrice), lastDt:r.lastDt||'', minPrice:n(r.minPrice), maxPrice:n(r.maxPrice), avgPrice:(r.avgPrice==null?null:n(r.avgPrice)), cnt:n(r.cnt), qty:n(r.qty) }); });
  _grp=Object.keys(m).map(function(k){ var g=m[k];
    g.vendors.sort(function(a,b){ return a.lastPrice-b.lastPrice || b.cnt-a.cnt; });
    g.best=g.vendors[0]||null;
    g.mst=g.vendors.filter(function(v){ return v.vendorCd===g.mstVendorCd; })[0]||null;
    g.base = g.mstPrice>0 ? g.mstPrice : (g.mst ? g.mst.lastPrice : (g.best?g.best.lastPrice:0));   // 비교 기준 = 마스터 매입가(없으면 마스터 매입처 최근가)
    g.diff = g.best ? (g.base - g.best.lastPrice) : 0;
    return g; });
}
function render(){
  var only2=document.getElementById('only2').checked, onlyDiff=document.getElementById('onlyDiff').checked, sort=document.getElementById('sort').value;
  var l=_grp.filter(function(g){ if(only2 && g.vendors.length<2) return false; if(onlyDiff && !(g.diff>0)) return false; return true; });
  if(sort==='diff') l.sort(function(a,b){ return b.diff-a.diff || a.prodCd.localeCompare(b.prodCd); });
  else if(sort==='vend') l.sort(function(a,b){ return b.vendors.length-a.vendors.length || a.prodCd.localeCompare(b.prodCd); });
  else l.sort(function(a,b){ return a.prodCd.localeCompare(b.prodCd); });
  var saving=l.reduce(function(s,g){ return s+(g.diff>0?g.diff:0); },0);
  document.getElementById('cnt').innerHTML='품목 <b>'+l.length+'</b>'+(l.length!==_grp.length?' / '+_grp.length:'')+' · 더 싼 곳 있는 품목 <b>'+l.filter(function(g){ return g.diff>0; }).length+'</b>';
  if(!l.length){ document.getElementById('body').innerHTML='<tr><td colspan="10" class="empty">'+(_grp.length?'조건에 맞는 품목이 없습니다 — 체크를 풀거나 기간을 넓혀 보세요.':'이 기간에 거래처가 적힌 매입 단가 기록이 없습니다.')+'</td></tr>'; return; }
  document.getElementById('body').innerHTML=l.map(function(g){
    var chips=g.vendors.map(function(v,i){ var best=(i===0), mst=(v.vendorCd===g.mstVendorCd);
      return '<span class="chip'+(best?' best':'')+(mst?' mst':'')+'" title="'+esc(v.vendorNm)+(mst?' (상품마스터 매입처)':'')+(best?' — 최저':'')+'">'
        +'<span><span class="nm">'+esc(v.vendorNm)+'</span> <b>'+fmtP(v.lastPrice)+'</b></span>'
        +'<small>'+esc(d8(v.lastDt))+(v.avgPrice!=null?' · 평균 '+fmtP(v.avgPrice):'')+(v.minPrice!==v.maxPrice?' · '+fmtP(v.minPrice)+'~'+fmtP(v.maxPrice):'')+' · '+v.cnt+'건'+(v.qty?' · '+fmt(v.qty):'')+'</small></span>'; }).join('');
    var mstNm = g.mst ? g.mst.vendorNm : (g.mstVendorCd ? g.mstVendorCd : '<span class="dim">—</span>');
    return '<tr><td class="code">'+esc(g.prodCd)+'</td><td class="l">'+esc(g.prodNm)+'</td><td class="l">'+esc(g.spec)+'</td>'
      +'<td class="r">'+(g.mstPrice>0?fmtP(g.mstPrice):'<span class="dim">—</span>')+'</td><td>'+mstNm+'</td><td>'+g.vendors.length+'</td>'
      +'<td>'+(g.best?'<b style="color:#137a6c">'+esc(g.best.vendorNm)+'</b>':'')+'</td><td class="r">'+(g.best?fmtP(g.best.lastPrice):'')+'</td>'
      +'<td class="r diff '+(g.diff>0?'pos':'zero')+'" title="'+(g.diff>0?'마스터 매입가보다 '+fmtP(g.diff)+' 싸게 사는 곳이 있습니다':(g.diff<0?'최저 거래처가 마스터 매입가보다 비쌉니다(마스터가 옛 값일 수 있음)':'차이 없음'))+'">'+(g.diff>0?'▼ '+fmtP(g.diff):(g.diff<0?'▲ '+fmtP(-g.diff):'0'))+'</td>'
      +'<td class="l"><div class="chips">'+chips+'</div></td></tr>'; }).join('');
}
function excel(){
  var LIB=(window.parent&&window.parent.XLSX)||window.XLSX;
  if(!LIB){ toast('엑셀 도구를 아직 못 불러왔습니다. 잠시 뒤 다시 눌러 보세요.','⚠️'); return; }
  var only2=document.getElementById('only2').checked, onlyDiff=document.getElementById('onlyDiff').checked;
  var l=_grp.filter(function(g){ if(only2 && g.vendors.length<2) return false; if(onlyDiff && !(g.diff>0)) return false; return true; });
  var aoa=[['품목코드','품목명','규격','마스터 매입가','마스터 매입처','거래처 수','최저 거래처','최저 최근가','차액','거래처','최근가','최근일','평균','최저','최고','건수','수량']];
  l.forEach(function(g){ g.vendors.forEach(function(v,i){ aoa.push([g.prodCd,g.prodNm,g.spec,g.mstPrice||'',(g.mst?g.mst.vendorNm:g.mstVendorCd)||'',g.vendors.length,(g.best?g.best.vendorNm:''),(g.best?g.best.lastPrice:''),g.diff,
    v.vendorNm+(i===0?' (최저)':'')+(v.vendorCd===g.mstVendorCd?' ★':''),v.lastPrice,d8(v.lastDt),(v.avgPrice==null?'':Math.round(v.avgPrice*100)/100),v.minPrice,v.maxPrice,v.cnt,v.qty]); }); });
  var ws=LIB.utils.aoa_to_sheet(aoa), wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb, ws, '거래처별매입가');
  var mo=document.getElementById('months').value;
  LIB.writeFile(wb, '거래처별매입가비교_'+(mo==='0'?'전체':'최근'+mo+'개월')+'_'+new Date().toISOString().slice(0,10).replace(/-/g,'')+'.xlsx');
}
load();
</script>
</body>
</html>
