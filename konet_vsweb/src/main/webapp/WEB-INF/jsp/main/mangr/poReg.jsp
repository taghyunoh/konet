<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>발주서 관리</title>
<!--
  발주서 관리 (2026-09-03 신설) — 매입 관리 ▸ 발주서 관리. 사이드바 iframe(logiFrame) 화면.
  · 거래처에 보낼 발주서를 등록/수정/삭제 · 🖨 인쇄(poPrint.jsp) · 📥 엑셀 · 💬 카톡 공유 · 🔗 링크 복사
  · 카톡 공유 = 카카오 JavaScript SDK 「공유하기」 카드(제목·설명·[웹페이지로 보기]) → 공개 주소 /pub/po.do?t=토큰 (로그인 없이 읽기만)
      키 = src/main/resources/kakao.properties 의 kakao.js.key (Kakao Developers 앱의 JavaScript 키, 플랫폼 Web 에 이 사이트 도메인 등록 필요)
      키가 없거나 SDK 를 못 불러오면 「🔗 링크 복사」로 주소를 카톡에 붙여 넣는다(카드 미리보기는 og: 태그로 뜬다).
  · 매입전환은 예정(버튼만) — 매입 등록 화면과 연결 규칙을 정한 뒤 붙인다.
  · 표: TBL_PO_MST / TBL_PO_DTL — 매입전표와 별개. 재고에는 영향이 없다.
-->
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/vendor-pick.js?v=20260805"></script>
<script src="https://t1.kakaocdn.net/kakao_js_sdk/2.7.4/kakao.min.js" crossorigin="anonymous"></script>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:10px; font-size:12.5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; padding:10px 12px; margin-bottom:12px; }
  .hd{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
  .hd label{ font-weight:700; color:#37475a; }
  .hd input[type=date], .hd input[type=text], .hd select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; }
  .hd input[readonly]{ background:#f4f6f8; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn.teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn.red{ background:#c0392b; color:#fff; border-color:#c0392b; }
  .btn.blue{ background:#1f6fb3; color:#fff; border-color:#1f6fb3; }
  .btn.kakao{ background:#fee500; color:#191919; border-color:#f2d900; }
  .btn:disabled{ opacity:.45; cursor:default; }
  .gridwrap{ overflow:auto; border:1px solid var(--bd); border-radius:8px; max-height:38vh; }
  table.g{ border-collapse:collapse; width:100%; font-size:13.5px; white-space:nowrap; }
  table.g th{ background:#dfeaf5; color:#1f2a37; border:1px solid var(--bd); padding:6px 6px; position:sticky; top:0; z-index:2; font-weight:800; }
  table.g td{ border:1px solid var(--bd); padding:2px 4px; text-align:right; height:30px; }
  table.g td.c{ text-align:center; } table.g td.l{ text-align:left; }
  table.g input{ width:100%; border:0; background:transparent; font-size:13.5px; padding:4px 2px; text-align:right; }
  table.g input.l{ text-align:left; }
  table.g input:focus{ outline:2px solid #bfe3dc; border-radius:3px; }
  table.g td.ro{ background:#fafbfc; color:#37475a; }
  table.g tr.tot td{ background:#e2efda; font-weight:800; color:#375623; }
  table.g .lnk{ color:var(--teal); text-decoration:underline; cursor:pointer; }
  table.g .del{ color:#c0392b; cursor:pointer; font-weight:800; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:10px; }
  .bar .cnt{ color:#37475a; font-size:13.5px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 13px; }
  .bar .cnt b{ color:var(--teal); }
  .listwrap{ overflow:auto; border:1px solid var(--bd); border-radius:8px; max-height:max(200px,30vh); }
  table.lst{ border-collapse:collapse; width:100%; font-size:13.5px; white-space:nowrap; }
  table.lst th{ background:#b9ded4; color:#0b4f43; border:1px solid var(--bd); padding:7px 8px; position:sticky; top:0; font-weight:800; }
  table.lst td{ border:1px solid var(--bd); padding:6px 8px; text-align:center; }
  table.lst td.r{ text-align:right; } table.lst td.l{ text-align:left; }
  table.lst tr{ cursor:pointer; } table.lst tr:hover td{ background:#f3f8f6; } table.lst tr.on td{ background:#fdeef0; font-weight:700; }
  .empty{ padding:22px; text-align:center; color:#9aa7b3; }
  /* 팝업(거래처·상품) */
  .pop{ display:none; position:fixed; inset:0; background:rgba(0,0,0,.35); z-index:200; }
  .pop.on{ display:block; }
  .pop .box{ background:#fff; width:min(900px,96vw); max-height:80vh; margin:6vh auto; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.25); }
  .pop .ph{ padding:12px 16px; border-bottom:1px solid var(--bd); font-weight:800; display:flex; gap:8px; align-items:center; }
  .pop .ph input{ flex:1; height:32px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; }
  .pop .pb{ padding:0 16px 12px; overflow:auto; }
  .pop table{ width:100%; border-collapse:collapse; font-size:13px; }
  .pop th{ background:#eef3f2; border:1px solid var(--bd); padding:6px 8px; position:sticky; top:0; }
  .pop td{ border:1px solid var(--bd); padding:6px 8px; text-align:center; }
  .pop td.l{ text-align:left; } .pop td.r{ text-align:right; }
  .pop tr.pick{ cursor:pointer; } .pop tr.pick:hover td{ background:#f3f8f6; }
  .pop .pf{ padding:10px 16px; border-top:1px solid var(--bd); text-align:right; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📋 발주서 관리</h2>
  <div class="sub">거래처에 보낼 <b>발주서</b>를 만듭니다 — 저장 후 <b>🖨 인쇄</b>·<b>📥 엑셀</b>·<b>💬 카톡 공유</b>(받는 쪽은 로그인 없이 발주서만 봅니다). 매입전표·재고와는 별개입니다.</div>

  <div class="card">
    <div class="hd">
      <label>발주일자</label><input type="date" id="poDt" onchange="poDtChanged()">
      <label>번호</label><input type="text" id="poNo" readonly style="width:64px; text-align:center">
      <label>거래처</label><input type="text" id="venNm" placeholder="거래처명 입력·선택" style="width:220px" autocomplete="off">
      <button class="btn" onclick="venOpen()">거래처</button>
      <label>담당자</label><input type="text" id="mgrNm" value="${sessionScope.s_user_nm}" readonly style="width:110px">
      <span id="stat" style="margin-left:auto; color:#6b7a89; font-size:12.5px"></span>
    </div>
    <div class="gridwrap" style="margin-top:10px">
      <table class="g" id="grid">
        <thead><tr>
          <th style="width:36px">#</th><th style="width:96px">코드</th><th style="min-width:230px">상품명</th><th style="width:130px">규격</th>
          <th style="width:56px">입수</th><th style="width:70px">BOX</th><th style="width:70px">EA</th><th style="width:78px">합계수량</th>
          <th style="width:90px">단가</th><th style="width:100px">금액</th><th style="width:76px">DC</th><th style="width:100px">공급가</th>
          <th style="width:86px">부가세</th><th style="width:104px">매입금액</th><th style="width:60px">서비스</th><th style="width:140px">비고</th><th style="width:40px">삭제</th>
        </tr></thead>
        <tbody id="gbody"></tbody>
        <tfoot><tr class="tot" id="trow"></tr></tfoot>
      </table>
    </div>
    <div class="hd" style="margin-top:8px">
      <label>비고</label><input type="text" id="remark" style="flex:1; min-width:300px" placeholder="발주서에 찍히는 비고">
    </div>
    <div class="bar">
      <button class="btn teal" onclick="poSave()">💾 발주서 저장</button>
      <button class="btn red" id="btnDel" onclick="poDelete()" disabled>🗑 삭제</button>
      <button class="btn" onclick="poNew()">＋ 새 발주서</button>
      <span style="width:8px"></span>
      <button class="btn" id="btnPrint" onclick="poPrint()" disabled>🖨 발주서 인쇄</button>
      <button class="btn" id="btnXls" onclick="poExcel()" disabled>📥 엑셀</button>
      <button class="btn kakao" id="btnKakao" onclick="poKakao()" disabled>💬 카톡 공유</button>
      <button class="btn" id="btnLink" onclick="poCopyLink()" disabled>🔗 링크 복사</button>
      <button class="btn blue" id="btnCv" style="margin-left:auto" onclick="cvOpen()" disabled>📦 매입전환</button>
    </div>
  </div>

  <div class="card">
    <div class="hd">
      <label>조회기간</label><input type="date" id="frDt" data-range-to="toDt"> <span style="color:#8a98a8">~</span> <input type="date" id="toDt">
      <label>거래처</label><input type="text" id="findNm" placeholder="거래처명" style="width:180px" onkeydown="if(event.key==='Enter') poLoad()">
      <button class="btn teal" onclick="poLoad()">🔍 리스트 조회</button>
      <span class="cnt" id="cnt">-</span>
    </div>
    <div class="listwrap" style="margin-top:8px">
      <table class="lst"><thead><tr><th>발주일자</th><th>번호</th><th>거래처명</th><th>담당</th><th>품목</th><th>수량</th><th>공급가액</th><th>부가세</th><th>합계</th><th>공유</th><th>매입전환</th><th>등록자</th></tr></thead>
      <tbody id="lbody"><tr><td colspan="12" class="empty">기간을 고르고 [리스트 조회]를 누르세요.</td></tr></tbody></table>
    </div>
  </div>
</div>

<!-- 거래처 선택 팝업 -->
<div class="pop" id="venPop"><div class="box">
  <div class="ph">거래처 선택 <input type="text" id="venQ" placeholder="거래처명·코드·사업자번호" oninput="venRender()"><button class="btn" onclick="venClose()">닫기</button></div>
  <div class="pb"><table><thead><tr><th style="width:90px">코드</th><th>거래처명</th><th style="width:110px">대표</th><th style="width:120px">전화</th><th style="width:130px">사업자번호</th></tr></thead><tbody id="venBody"></tbody></table></div>
</div></div>
<!-- 상품 선택 팝업 -->
<div class="pop" id="prodPop"><div class="box">
  <div class="ph">상품 선택 <input type="text" id="prodQ" placeholder="코드·상품명·규격" oninput="prodRender()"><button class="btn" onclick="prodClose()">닫기</button></div>
  <div class="pb"><table><thead><tr><th style="width:100px">코드</th><th>상품명</th><th style="width:150px">규격</th><th style="width:56px">입수</th><th style="width:90px">매입단가</th><th style="width:60px">과세</th></tr></thead><tbody id="prodBody"></tbody></table></div>
</div></div>

<!-- 매입전환 (2026-09-03) — 발주서를 그대로 매입전표로 넣는다. 매입일자 = 실제 들어온 날. 매입 등록과 같은 저장 경로(재고·단가이력 함께) -->
<div class="pop" id="cvPop"><div class="box" style="width:min(520px,94vw)">
  <div class="ph">📦 매입전환 — 발주서를 매입전표로</div>
  <div class="pb" style="padding:14px 16px">
    <div id="cvInfo" style="margin-bottom:12px; color:#37475a; font-size:13.5px"></div>
    <div class="hd" style="margin-bottom:8px"><label style="width:70px">매입일자</label><input type="date" id="cvDt" data-nonav="1"> <span style="color:#6b7a89; font-size:12px">← 실제 들어온 날(입고일)</span></div>
    <div class="hd" style="margin-bottom:8px"><label style="width:70px">창고</label><input type="text" id="cvWh" value="물류창고" style="width:160px"></div>
    <div class="hd"><label style="width:70px">지급구분</label><select id="cvPay"><option>현금</option><option>카드</option><option selected>외상</option><option>계좌이체</option></select></div>
    <div id="cvWarn" style="margin-top:12px; color:#c0392b; font-size:12.5px; display:none"></div>
  </div>
  <div class="pf"><button class="btn" onclick="cvClose()">취소</button> <button class="btn blue" id="cvGo" onclick="cvGo()">매입전표 만들기</button></div>
</div></div>
<script>
var CTX='${pageContext.request.contextPath}';
var KAKAO_KEY='${kakaoJsKey}', SHARE_BASE='${shareBase}';
var _vendors=[], _prods=[], _rows=[], _cur=null, _list=[], _prodRow=-1;
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString(); }
function fmtQ(v){ v=Math.round(n(v)*100)/100; return v.toLocaleString(undefined,{maximumFractionDigits:2}); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d8(d){ d=''+(d||''); return /^\d{8}$/.test(d)?(d.slice(0,4)+'-'+d.slice(4,6)+'-'+d.slice(6,8)):d; }
function toast(s, icon){ if(window._alertBox) return _alertBox(s,{icon:icon||'ℹ️'}); alert(s.replace(/<[^>]*>/g,'')); }
function confirmBox(msg, onOk){ if(window._confirmBox) return _confirmBox({msg:msg, icon:'❓', okText:'확인', okColor:'blue', onOk:onOk}); if(confirm(msg.replace(/<[^>]*>/g,''))) onOk(); }
function post(url, body, isJson){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': isJson?'application/json; charset=UTF-8':'application/x-www-form-urlencoded; charset=UTF-8'}, body: isJson?JSON.stringify(body):body }); }

/* ── 마스터 ── */
function loadMasters(){
  post('/vendor/selectVendorMst.do','').then(function(r){return r.json();}).then(function(j){ _vendors=(j&&j.data)||[]; }).catch(function(){});
  post('/prod/prodList.do','findData=').then(function(r){return r.json();}).then(function(j){ _prods=((j&&j.data)||[]).filter(function(p){ return (''+(p.stopYn||'')).toUpperCase()!=='Y'; }); }).catch(function(){});
}
/* 거래처 칸에 직접 쳐서 고른다(공통 vendor-pick) — 못 불러오면 팝업만 */
try{ if(window._vendorPick) _vendorPick(document.getElementById('venNm'), { list:function(){ return _vendors; }, onPick:function(o){ venPick(o.vendorCd, o.vendorNm); }, onClear:function(){ venPick('',''); } }); }catch(e){}
function venPick(cd, nm){ var el=document.getElementById('venNm'); el.dataset.cd=cd||''; if(nm!=null) el.value=nm; }
function venOpen(){ document.getElementById('venPop').classList.add('on'); document.getElementById('venQ').value=''; venRender(); setTimeout(function(){ document.getElementById('venQ').focus(); },50); }
function venClose(){ document.getElementById('venPop').classList.remove('on'); }
function venRender(){ var q=(document.getElementById('venQ').value||'').trim().toLowerCase(), h='';
  _vendors.forEach(function(v){ var hay=(v.vendorCd+' '+(v.vendorNm||'')+' '+(v.fullNm||'')+' '+(v.bizno||'')+' '+(v.ceoNm||'')).toLowerCase(); if(q && hay.indexOf(q)<0) return;
    h+='<tr class="pick" onclick="venPick(\''+esc(v.vendorCd)+'\',\''+esc(v.vendorNm)+'\');venClose()"><td>'+esc(v.vendorCd)+'</td><td class="l">'+esc(v.vendorNm)+'</td><td>'+esc(v.ceoNm)+'</td><td>'+esc(v.tel||v.hp)+'</td><td>'+esc(v.bizno)+'</td></tr>'; });
  document.getElementById('venBody').innerHTML=h||'<tr><td colspan="5" class="empty">거래처가 없습니다.</td></tr>'; }

/* ── 품목 줄 ── */
function emptyRow(){ return { prodSeq:null, prodCd:'', prodNm:'', spec:'', packQty:1, boxQty:0, eaQty:0, qty:0, unitPrice:0, amt:0, dcAmt:0, supplyAmt:0, vatAmt:0, totAmt:0, serviceQty:0, taxGb:'', remark:'' }; }
function taxFree(o){ var t=(''+(o.taxGb||'')).toUpperCase(); return t==='F' || t==='N' || t.indexOf('면세')>=0 || t.indexOf('FREE')>=0; }
function calcRow(o){ var pk=n(o.packQty)||1; o.qty=n(o.boxQty)*pk+n(o.eaQty); o.amt=Math.round(o.qty*n(o.unitPrice)); o.supplyAmt=o.amt-n(o.dcAmt); o.vatAmt=taxFree(o)?0:Math.round(o.supplyAmt*0.1); o.totAmt=o.supplyAmt+o.vatAmt; }
function ensureTail(){ if(!_rows.length || _rows[_rows.length-1].prodCd) _rows.push(emptyRow()); }
function render(){
  ensureTail(); var h='';
  _rows.forEach(function(o,i){ calcRow(o);
    h+='<tr><td class="c ro">'+(i+1)+'</td>'
      +'<td class="c"><span class="lnk" onclick="prodOpen('+i+')">'+(o.prodCd?esc(o.prodCd):'선택')+'</span></td>'
      +'<td class="l"><input class="l" value="'+esc(o.prodNm)+'" onchange="setv('+i+',\'prodNm\',this.value)" onclick="if(!_rows['+i+'].prodCd) prodOpen('+i+')"></td>'
      +'<td class="l"><input class="l" value="'+esc(o.spec)+'" onchange="setv('+i+',\'spec\',this.value)"></td>'
      +'<td><input value="'+fmtQ(o.packQty)+'" onchange="setv('+i+',\'packQty\',this.value)"></td>'
      +'<td><input value="'+fmtQ(o.boxQty)+'" onchange="setv('+i+',\'boxQty\',this.value)"></td>'
      +'<td><input value="'+fmtQ(o.eaQty)+'" onchange="setv('+i+',\'eaQty\',this.value)"></td>'
      +'<td class="ro">'+fmtQ(o.qty)+'</td>'
      +'<td><input value="'+fmtQ(o.unitPrice)+'" onchange="setv('+i+',\'unitPrice\',this.value)"></td>'
      +'<td class="ro">'+fmt(o.amt)+'</td>'
      +'<td><input value="'+fmt(o.dcAmt)+'" onchange="setv('+i+',\'dcAmt\',this.value)"></td>'
      +'<td class="ro">'+fmt(o.supplyAmt)+'</td><td class="ro">'+fmt(o.vatAmt)+'</td><td class="ro">'+fmt(o.totAmt)+'</td>'
      +'<td><input value="'+fmtQ(o.serviceQty)+'" onchange="setv('+i+',\'serviceQty\',this.value)"></td>'
      +'<td class="l"><input class="l" value="'+esc(o.remark)+'" onchange="setv('+i+',\'remark\',this.value)"></td>'
      +'<td class="c"><span class="del" onclick="delRow('+i+')">✕</span></td></tr>'; });
  document.getElementById('gbody').innerHTML=h;
  var t=calcAll();
  document.getElementById('trow').innerHTML='<td colspan="5" class="c">합계 · 품목 '+t.cnt+'</td><td>'+fmtQ(t.box)+'</td><td>'+fmtQ(t.ea)+'</td><td>'+fmtQ(t.qty)+'</td><td></td><td>'+fmt(t.amt)+'</td><td>'+fmt(t.dc)+'</td><td>'+fmt(t.sup)+'</td><td>'+fmt(t.vat)+'</td><td>'+fmt(t.tot)+'</td><td>'+fmtQ(t.svc)+'</td><td colspan="2"></td>';
}
function setv(i,k,v){ var o=_rows[i]; if(!o) return; o[k]=(k==='prodNm'||k==='spec'||k==='remark')?v:n(v); render(); }
function delRow(i){ _rows.splice(i,1); render(); }
function calcAll(){ var t={cnt:0,box:0,ea:0,qty:0,amt:0,dc:0,sup:0,vat:0,tot:0,svc:0}; _rows.forEach(function(o){ if(!o.prodCd) return; calcRow(o); t.cnt++; t.box+=n(o.boxQty); t.ea+=n(o.eaQty); t.qty+=o.qty; t.amt+=o.amt; t.dc+=n(o.dcAmt); t.sup+=o.supplyAmt; t.vat+=o.vatAmt; t.tot+=o.totAmt; t.svc+=n(o.serviceQty); }); return t; }
function prodOpen(i){ _prodRow=i; document.getElementById('prodPop').classList.add('on'); document.getElementById('prodQ').value=''; prodRender(); setTimeout(function(){ document.getElementById('prodQ').focus(); },50); }
function prodClose(){ document.getElementById('prodPop').classList.remove('on'); }
function prodRender(){ var q=(document.getElementById('prodQ').value||'').trim().toLowerCase(), h='', k=0;
  for(var i=0;i<_prods.length && k<300;i++){ var p=_prods[i]; var hay=(p.prodCd+' '+(p.prodNm||'')+' '+(p.spec||'')).toLowerCase(); if(q && hay.indexOf(q)<0) continue; k++;
    h+='<tr class="pick" onclick="prodPick('+i+')"><td>'+esc(p.prodCd)+'</td><td class="l">'+esc(p.prodNm)+'</td><td class="l">'+esc(p.spec)+'</td><td>'+fmtQ(p.packQty||1)+'</td><td class="r">'+fmt(p.inPrice)+'</td><td>'+esc(p.taxGb)+'</td></tr>'; }
  document.getElementById('prodBody').innerHTML=h||'<tr><td colspan="6" class="empty">상품이 없습니다.</td></tr>'; }
function prodPick(pi){ var p=_prods[pi], o=_rows[_prodRow]; if(!p||!o) return;
  o.prodSeq=p.prodSeq; o.prodCd=p.prodCd; o.prodNm=p.prodNm||''; o.spec=p.spec||''; o.packQty=n(p.packQty)||1; o.unitPrice=n(p.inPrice); o.taxGb=p.taxGb||''; if(!n(o.boxQty)&&!n(o.eaQty)) o.boxQty=1;
  prodClose(); render();
  var tr=document.getElementById('gbody').rows[_prodRow]; if(tr){ var inp=tr.querySelectorAll('input')[3]; if(inp){ inp.focus(); inp.select(); } } }

/* ── 머리 ── */
function poNew(){ _cur=null; _rows=[]; document.getElementById('poDt').value=today(); venPick('',''); document.getElementById('remark').value=''; document.getElementById('poNo').value=''; poDtChanged(); render(); setButtons(); document.getElementById('stat').textContent='새 발주서'; }
function poDtChanged(){ if(_cur) return; var d=document.getElementById('poDt').value; if(!d) return; post('/mangr/poNextNo.do','poDt='+encodeURIComponent(d)).then(function(r){return r.json();}).then(function(j){ document.getElementById('poNo').value=(j&&j.data)||'0001'; }).catch(function(){}); }
function setButtons(){ var on=!!(_cur&&_cur.poSeq); ['btnDel','btnPrint','btnXls','btnKakao','btnLink','btnCv'].forEach(function(id){ document.getElementById(id).disabled=!on; }); }
function poSave(){
  var venCd=document.getElementById('venNm').dataset.cd||'', venNm=document.getElementById('venNm').value||'';
  if(!document.getElementById('poDt').value){ toast('발주일자를 선택하세요.','⚠️'); return; }
  if(!venCd){ toast('거래처를 선택하세요.','⚠️'); return; }
  var items=_rows.filter(function(o){ return o.prodCd; }); if(!items.length){ toast('상품을 한 줄 이상 넣으세요.','⚠️'); return; }
  var t=calcAll();
  var dto={ poSeq:_cur?_cur.poSeq:null, poDt:document.getElementById('poDt').value, poNo:document.getElementById('poNo').value, vendorCd:venCd, vendorNm:venNm,
    mgrCd:'${sessionScope.s_user_id}', mgrNm:document.getElementById('mgrNm').value, totBoxQty:t.box, totEaQty:t.ea, totQty:t.qty, supplyAmt:t.sup, vatAmt:t.vat, totAmt:t.tot, dcAmt:t.dc,
    remark:document.getElementById('remark').value, items:items };
  post('/mangr/poSave.do', dto, true).then(function(r){ return r.text().then(function(x){ if(!r.ok) throw new Error(x); return x; }); })
    .then(function(seq){ seq=String(seq||'').replace(/[^0-9]/g,'');   /* 응답이 감싸여 와도 숫자만 */
      toast('발주서를 저장했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">번호 '+esc(document.getElementById('poDt').value)+' - '+esc(document.getElementById('poNo').value)+'</span>','✅'); poLoad(seq); poOpen(seq); })
    .catch(function(e){ toast('저장에 실패했습니다.<br><span style="font-size:12.5px;color:#c0392b">'+esc(e.message)+'</span>','⚠️'); });
}
function poDelete(){ if(!_cur) return; confirmBox('이 발주서를 삭제할까요?<br><span style="font-size:13px;color:#3d4d5c">'+esc(d8(_cur.poDt))+' - '+esc(_cur.poNo)+' '+esc(_cur.vendorNm)+'</span>', function(){
  post('/mangr/poDelete.do','poSeq='+_cur.poSeq).then(function(r){ if(!r.ok) return r.text().then(function(x){ throw new Error(x); }); toast('삭제했습니다.','✅'); poNew(); poLoad(); }).catch(function(e){ toast('삭제 실패: '+esc(e.message),'⚠️'); }); }); }
function poOpen(seq){ post('/mangr/poDetail.do','poSeq='+seq).then(function(r){return r.json();}).then(function(j){ var m=j&&j.mst; if(!m){ toast('발주서를 찾을 수 없습니다.','⚠️'); return; }
  _cur=m; document.getElementById('poDt').value=d8(m.poDt); document.getElementById('poNo').value=m.poNo||''; venPick(m.vendorCd||'', m.vendorNm||''); document.getElementById('remark').value=m.remark||'';
  if(m.mgrNm) document.getElementById('mgrNm').value=m.mgrNm;
  _rows=(j.items||[]).map(function(d){ var o=emptyRow(); for(var k in o) if(d[k]!=null) o[k]=d[k]; return o; }); render(); setButtons();
  document.getElementById('stat').textContent='발주서 '+d8(m.poDt)+' - '+m.poNo+' · 공유 '+(m.shareCnt||0)+'회'+(m.lastShareDttm?(' (마지막 '+m.lastShareDttm+')'):'')+(m.purchNo?(' · 📦 매입전표 '+d8(m.purchDt)+'-'+m.purchNo):'');
  markList(); }).catch(function(e){ toast('불러오기 실패: '+esc(e.message),'⚠️'); }); }

/* ── 목록 ── */
function poLoad(selSeq){ var b='fromDt='+encodeURIComponent(document.getElementById('frDt').value)+'&toDt='+encodeURIComponent(document.getElementById('toDt').value)+'&findData='+encodeURIComponent(document.getElementById('findNm').value);
  document.getElementById('lbody').innerHTML='<tr><td colspan="12" class="empty">조회 중…</td></tr>';
  post('/mangr/poList.do', b).then(function(r){return r.json();}).then(function(j){ _list=(j&&j.data)||[]; listRender(); if(selSeq) markList(selSeq); }).catch(function(e){ document.getElementById('lbody').innerHTML='<tr><td colspan="12" class="empty" style="color:#c0392b">조회 오류: '+esc(e.message)+'</td></tr>'; }); }
function listRender(){ var h='', ts=0, tv=0, tt=0;
  _list.forEach(function(o,i){ ts+=n(o.supplyAmt); tv+=n(o.vatAmt); tt+=n(o.totAmt);
    h+='<tr data-seq="'+o.poSeq+'" onclick="poOpen('+o.poSeq+')"><td>'+d8(o.poDt)+'</td><td>'+esc(o.poNo)+'</td><td class="l">'+esc(o.vendorNm)+'</td><td>'+esc(o.mgrNm)+'</td><td>'+n(o.prodCnt)+'</td><td class="r">'+fmtQ(o.totQty)+'</td><td class="r">'+fmt(o.supplyAmt)+'</td><td class="r">'+fmt(o.vatAmt)+'</td><td class="r">'+fmt(o.totAmt)+'</td><td>'+(n(o.shareCnt)?('💬 '+n(o.shareCnt)):'')+'</td><td>'+(o.purchNo?('✔ '+d8(o.purchDt)+'-'+esc(o.purchNo)):'')+'</td><td>'+esc(o.regUser)+'</td></tr>'; });
  document.getElementById('lbody').innerHTML=h||'<tr><td colspan="12" class="empty">발주서가 없습니다.</td></tr>';
  document.getElementById('cnt').innerHTML='<b>'+_list.length+'</b>건 · 공급가 <b>'+fmt(ts)+'</b> · 부가세 <b>'+fmt(tv)+'</b> · 합계 <b>'+fmt(tt)+'</b>'; }
function markList(seq){ var s=seq||(_cur&&_cur.poSeq); document.querySelectorAll('#lbody tr').forEach(function(tr){ tr.classList.toggle('on', String(tr.getAttribute('data-seq'))===String(s)); }); }

/* ── 인쇄 · 엑셀 · 공유 ── */
function poPrint(){ if(!_cur) return; window.open(CTX+'/mangr/poPrint.do?poSeq='+_cur.poSeq, 'poPrint', 'width=900,height=1000'); }
function shareUrl(){ return _cur&&_cur.shareToken ? (SHARE_BASE+'/pub/po.do?t='+encodeURIComponent(_cur.shareToken)) : ''; }
function poCopyLink(){ var u=shareUrl(); if(!u){ toast('먼저 저장하세요.','⚠️'); return; }
  var done=function(){ toast('발주서 링크를 복사했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">카톡 대화창에 붙여 넣으면 거래처가 로그인 없이 봅니다.</span><br><span style="font-size:11.5px;color:#6b7a89;word-break:break-all">'+esc(u)+'</span>','🔗'); };
  if(navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(u).then(done, function(){ prompt('아래 주소를 복사하세요', u); });
  else prompt('아래 주소를 복사하세요', u); }
function poKakao(){ var u=shareUrl(); if(!u){ toast('먼저 저장하세요.','⚠️'); return; }
  if(!window.Kakao || !KAKAO_KEY){ toast('카카오 공유 설정이 없어 <b>링크 복사</b>로 보냅니다.<br><span style="font-size:12px;color:#6b7a89">kakao.properties 의 kakao.js.key 를 채우고 Kakao Developers 에 이 사이트 도메인을 등록하면 카드로 보내집니다.</span>','💬'); poCopyLink(); return; }
  try{ if(!Kakao.isInitialized()) Kakao.init(KAKAO_KEY); }catch(e){ toast('카카오 초기화 실패: '+esc(e.message),'⚠️'); poCopyLink(); return; }
  var t=calcAll(), dt=d8(_cur.poDt);
  try{
    /* 텍스트형 카드 — 그림(썸네일) 없이 글만 (2026-09-03 「앞에 표시는 제거」). feed 형은 이미지가 필수라 text 형으로 */
    Kakao.Share.sendDefault({ objectType:'text',
      text:'📋 발주서 — '+(_cur.vendorNm||'')+'\n'+dt+' · 품목 '+t.cnt+'종 · 합계 '+fmt(t.tot)+'원 · '+(document.getElementById('mgrNm').value||''),
      link:{ mobileWebUrl:u, webUrl:u },
      buttons:[ { title:'웹페이지로 보기', link:{ mobileWebUrl:u, webUrl:u } } ] });
    post('/mangr/poShared.do','poSeq='+_cur.poSeq).then(function(){ if(_cur){ _cur.shareCnt=n(_cur.shareCnt)+1; document.getElementById('stat').textContent='발주서 '+dt+' - '+_cur.poNo+' · 공유 '+_cur.shareCnt+'회'; } poLoad(_cur.poSeq); }).catch(function(){});
  }catch(e){ toast('카카오 공유 실패: '+esc(e.message)+'<br><span style="font-size:12px">링크 복사로 보내세요.</span>','⚠️'); }
}
function poExcel(){ if(!_cur) return; var t=calcAll(), aoa=[];
  aoa.push(['발주서']); aoa.push(['발주일자', d8(_cur.poDt), '번호', _cur.poNo, '거래처', _cur.vendorNm||'', '담당', document.getElementById('mgrNm').value||'']); aoa.push([]);
  aoa.push(['번호','코드','품명','규격','입수','BOX','EA','합계수량','단가','금액','DC','공급가','부가세','매입금액','서비스','비고']);
  var k=0; _rows.forEach(function(o){ if(!o.prodCd) return; k++; aoa.push([k,o.prodCd,o.prodNm,o.spec,n(o.packQty),n(o.boxQty),n(o.eaQty),o.qty,n(o.unitPrice),o.amt,n(o.dcAmt),o.supplyAmt,o.vatAmt,o.totAmt,n(o.serviceQty),o.remark||'']); });
  aoa.push(['합계','','','','',t.box,t.ea,t.qty,'',t.amt,t.dc,t.sup,t.vat,t.tot,t.svc,'']); aoa.push([]); aoa.push(['비고', document.getElementById('remark').value||'']);
  var P=window.parent, fn='발주서_'+(_cur.vendorNm||'')+'_'+(_cur.poDt||'')+'-'+(_cur.poNo||'')+'.xlsx';
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); ws['!cols']=[{wch:6},{wch:12},{wch:36},{wch:18},{wch:6},{wch:8},{wch:8},{wch:10},{wch:10},{wch:12},{wch:8},{wch:12},{wch:10},{wch:12},{wch:8},{wch:20}]; var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'발주서'); LIB.writeFile(wb,fn); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB) byLib(LIB); else toast('엑셀 모듈을 못 불러왔습니다.','⚠️'); }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; } toast('엑셀 모듈은 물류관리 메인 안에서만 씁니다.','⚠️'); }

/* ── 매입전환 ── 발주서 → 매입전표(TBL_PURCHASE_*). 서버가 매입 등록과 같은 저장 경로를 타므로 재고 입고·단가 이력도 같이 생긴다 */
function cvOpen(){ if(!_cur){ toast('먼저 발주서를 저장하세요.','⚠️'); return; }
  var t=calcAll(); document.getElementById('cvInfo').innerHTML='<b>'+esc(_cur.vendorNm)+'</b> · 발주 '+d8(_cur.poDt)+'-'+esc(_cur.poNo)+' · 품목 '+t.cnt+'종 · 합계 <b>'+fmt(t.tot)+'</b>원';
  document.getElementById('cvDt').value=today();
  var w=document.getElementById('cvWarn'); if(_cur.purchNo){ w.style.display='block'; w.innerHTML='이미 매입전표 <b>'+d8(_cur.purchDt)+'-'+esc(_cur.purchNo)+'</b>로 전환된 발주서입니다. 다시 만들면 <b>매입이 두 번</b> 잡힙니다 — 먼저 매입 등록에서 그 전표를 지우세요.'; } else { w.style.display='none'; }
  document.getElementById('cvPop').classList.add('on'); }
function cvClose(){ document.getElementById('cvPop').classList.remove('on'); }
function cvGo(){ if(!_cur) return; var dt=document.getElementById('cvDt').value; if(!dt){ toast('매입일자를 고르세요.','⚠️'); return; }
  var run=function(){ var b='poSeq='+_cur.poSeq+'&purchDt='+encodeURIComponent(dt)+'&whNm='+encodeURIComponent(document.getElementById('cvWh').value||'물류창고')+'&payGb='+encodeURIComponent(document.getElementById('cvPay').value)+(_cur.purchNo?'&force=Y':'');
    document.getElementById('cvGo').disabled=true;
    post('/mangr/poToPurchase.do', b).then(function(r){ return r.text().then(function(x){ if(!r.ok) throw new Error(x); return x; }); })
      .then(function(x){ var j={}; try{ j=JSON.parse(x); }catch(e){} cvClose(); toast('매입전표를 만들었습니다.<br><span style="font-size:13px;color:#3d4d5c">매입일자 '+esc(dt)+' · 전표번호 <b>'+esc(j.purchNo||'')+'</b> · 품목 '+esc(j.rows||'')+'줄</span><br><span style="font-size:12px;color:#6b7a89">매입 등록 화면에서 확인·수정할 수 있습니다.</span>','✅'); poLoad(_cur.poSeq); poOpen(_cur.poSeq); })
      .catch(function(e){ toast('매입전환 실패<br><span style="font-size:12.5px;color:#c0392b;white-space:pre-line">'+esc(e.message)+'</span>','⚠️'); })
      .finally(function(){ document.getElementById('cvGo').disabled=false; }); };
  if(_cur.purchNo) confirmBox('이미 전환된 발주서입니다. <b>매입전표를 하나 더</b> 만들까요?', run); else run(); }
/* ── 시작 ── */
(function(){ var d=new Date(); document.getElementById('toDt').value=today(); d.setDate(1); document.getElementById('frDt').value=d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-01'; })();
loadMasters(); poNew(); poLoad();
</script>
</body>
</html>
