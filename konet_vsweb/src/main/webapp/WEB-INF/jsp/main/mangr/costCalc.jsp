<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>원가·마진 계산</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260917c"></script>   <%-- 회사 설정 — 센터별 물류비율·보관 기본값(konetSet.cost) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 📥 엑셀 (전역 XLSX) --%>
<!--
  원가·마진 계산 (2026-09-17 신설 — 표본 D:\코네트\오택현.xls 「견적서를 내기 위한 원가계산 방식」) — 견적서관리 ▸ 원가·마진 계산. 셸 iframe(logiFrame) 화면.
  · 표(칸 차례)는 표본 시트 그대로 (2026-09-17 「순서 이대로」「사용자 기존 방식 고수」, 네 줄 배치는 「원복」) :
      배송[제조사·품명·규격·MOQ수량·단가·금액] | 박스 입수량 | 구매[구매(계산)·계·운송·보관·소분·박스] | 판매[단가·계] | 물류비 | 실 판매금액 | 실 마진금액 | 실 마진율
      + 목표 마진율 → 필요 판매단가, 별도 청구. 품목 줄 아래에 부대비(동판비·목형비 …) 줄 : 수량 × 단가 = 금액, 구매 칸에 개당(금액 ÷ MOQ 수량).
  · 계산 규칙(표본 그대로) — 개당 구매 H(계산) = 단가 + 운송 + 보관 + 소분 + 박스 + 부대비/개(원가 포함분 ÷ MOQ 수량)
      계 I = H × 입수 · 판매 계 O = 판매단가 × 입수 · 물류비 P = 센터배송이면 O × 센터 비율, 직송이면 0, 택배면 택배비(직접 입력)
      실 판매 Q = O − P · 실 마진 R = Q − I · 실 마진율 S = Q ÷ I − 1 (원가 대비). 판매가 대비 R ÷ Q 는 엑셀에만.
      보관/개 기본값 = 보관료 × 팔레트 × 개월 ÷ MOQ 수량 — 직접 고치면(노란 칸) 그 값을 쓴다.
  · 부대비 줄마다 「원가 포함」(MOQ 수량으로 나눠 개당 구매에 더함) / 「별도 청구」(원가에 안 넣고 받은 만큼 그대로 청구, 마진 0) 를 고른다
    (2026-09-17 「위에 추가할 경우도 있고 독립할 경우도 있음, 독립이면 마진 없음」). 별도 청구분은 견적서로 보낼 때 따로 한 줄씩 들어간다.
  · 목표 마진율을 넣으면 그 마진이 나오는 「필요 판매단가」를 거꾸로 낸다(센터배송 = I×(1+t) ÷ (입수 × (1−비율)), 그 외 = (I×(1+t) + 택배비) ÷ 입수).
  · 센터 비율·보관 기본값은 회사 설정(konetSet.cost, compSetPatch key=cost)에 저장 — 어느 PC 에서나 같다. 품목 입력은 이 브라우저에 자동 저장(localStorage).
  · [🧾 견적서로 보내기] = 품명·규격·입수·MOQ·판매단가를 견적서 작성 화면에 넘긴다(localStorage konet.costToQuote → quoteEdit 이 받는다).
  · DB 표 없음(자바는 화면 매핑·설정 키 허용뿐). 칸 색 : 직접 입력 = 연주황(표본과 같음), 자동 = 회색 점선, 자동값을 직접 고침 = 노랑.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; --blue:#2f4f9a; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:15px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:13.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:36px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:14px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-red{ color:var(--red); }
  .lnk{ height:28px; padding:0 8px; font-size:13px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:15px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:13px; }
  .card .bd{ padding:12px; }
  .dim{ color:#8a98a8; }
  input[type=text], select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:15px; background:#fff; }
  input.num{ text-align:right; font-variant-numeric:tabular-nums; }
  /* 직접 입력 / 자동 계산 구분 (2026-09-17) — 표본 시트의 색 : 직접 입력 = 연주황, 자동 = 회색 점선, 자동값을 직접 고침 = 노랑 */
  input.in{ border:1.5px solid #e9b98a; background:#fdebd9; }
  input.in:focus{ outline:2px solid #f3c9a3; outline-offset:1px; }
  input.auto{ background:#eef1f5; color:#4a5a6a; border:1px dashed #b9c4d0; }
  input.manual{ background:#fff3c4; border:1.5px solid #e2b93b; }
  .tag{ display:inline-block; font-size:11.5px; font-weight:800; padding:1px 5px; border-radius:5px; margin-left:4px; vertical-align:1px; }
  .tag.in{ background:#fdebd9; color:#9a4f0a; } .tag.au{ background:#e6ebf1; color:#5b6b7b; }
  .legend{ display:flex; gap:12px; align-items:center; flex-wrap:wrap; font-size:13.5px; color:#37475a; padding:8px 12px; background:#fbfcfd; border:1px solid var(--bd); border-radius:8px; margin-bottom:12px; }
  .legend .sw{ display:inline-block; width:34px; height:18px; border-radius:5px; vertical-align:middle; margin-right:4px; }
  .legend .sw.in{ border:1.5px solid #e9b98a; background:#fdebd9; } .legend .sw.au{ background:#eef1f5; border:1px dashed #b9c4d0; } .legend .sw.mn{ background:#fff3c4; border:1.5px solid #e2b93b; }
  .opt{ display:inline-flex; align-items:center; gap:6px; font-size:14.5px; border:1px solid var(--bd); border-radius:8px; padding:6px 12px; cursor:pointer; background:#fff; }
  .opt:has(input:checked){ border-color:#0f6b5e; background:#e3f2ee; }
  .opt input{ margin:0; }
  .note{ font-size:13px; color:#6b7a89; line-height:1.55; }
  .cen{ display:none; margin-top:10px; padding:10px 12px; border:1px dashed var(--bd); border-radius:8px; background:#fbfcfd; }
  .cen.on{ display:block; }
  /* 표본 시트 꼴 표 */
  .tw{ overflow:auto; }
  table.sh{ border-collapse:collapse; font-size:14px; }
  table.sh th{ border:1px solid #c9d3dd; padding:6px 6px; text-align:center; font-weight:700; font-size:13.5px; white-space:nowrap; background:#f3f5f8; color:#2b3a49; }
  table.sh th.g1{ background:#fff3a3; }   /* 배송 (표본 노랑) */
  table.sh th.g2{ background:#f7c99a; }   /* 박스 입수량 (표본 주황) */
  table.sh th.g3{ background:#fff3a3; }   /* 구매·판매 */
  table.sh th.g4{ background:#a9d0e6; }   /* 물류비 (표본 파랑) */
  table.sh th.g5{ background:#fff3a3; }   /* 실 판매·실 마진 */
  table.sh th.g6{ background:#a8e6a0; }   /* 실 마진율 (표본 초록) */
  table.sh th.g7{ background:#e6ebf1; }   /* 목표·필요·별도·버튼 */
  table.sh td{ border:1px solid #d8e0e8; padding:3px 4px; vertical-align:middle; text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap; background:#fff; }
  table.sh td.l{ text-align:left; }
  table.sh td.c{ text-align:center; }
  table.sh td.au{ background:#f3f5f8; color:#2b3a49; font-weight:600; min-width:80px; }
  table.sh td.au.p{ background:#d9ecf7; }   /* 물류비 */
  table.sh td.au.q{ background:#fff9d6; }   /* 실 판매·실 마진 */
  table.sh td.au.s{ background:#e3f7df; font-weight:800; font-size:16px; }   /* 실 마진율 */
  table.sh td.au.b{ color:var(--blue); font-weight:800; }
  table.sh td.neg{ color:var(--red); }
  table.sh td.amber{ color:var(--amber); }
  table.sh input[type=text]{ height:32px; font-size:14.5px; }
  table.sh input.w1{ width:78px; } table.sh input.w2{ width:96px; } table.sh input.w3{ width:120px; } table.sh input.w4{ width:190px; } table.sh input.w5{ width:250px; }
  table.sh tr.ex td{ background:#fbfcfd; }
  table.sh tr.ex td.au{ background:#f3f5f8; }
  table.sh tr.ex select{ height:30px; font-size:13px; padding:0 4px; }
  table.sh tr.add td{ background:#fbfcfd; text-align:left; padding:4px 8px; }
  table.sh tr.gap td{ border:0; background:transparent; height:10px; padding:0; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🧮 원가·마진 계산 <small>— 표본 시트 순서 그대로. 구매원가·물류비를 넣으면 실 마진율이 바로 나오고, 목표 마진을 넣으면 필요 판매단가를 거꾸로 낸다</small>
    <span class="bar" style="margin-left:auto">
      <button class="btn" onclick="addItem()">➕ 품목 추가</button>
      <button class="btn" onclick="excel()" title="이 표를 엑셀로">📥 엑셀</button>
      <button class="btn btn-teal" onclick="toQuote()" title="품명·규격·입수·MOQ·판매단가를 견적서 작성 화면으로">🧾 견적서로 보내기</button>
      <button class="btn btn-red" onclick="clearAll()">🗑 비우기</button>
    </span>
  </h2>

  <div class="legend"><b>칸 구분</b>
    <span><span class="sw in"></span>직접 입력 — 사람이 넣는 값(표본의 주황 칸)</span>
    <span><span class="sw au"></span>자동 계산 — 식으로 나온 값</span>
    <span><span class="sw mn"></span>자동값을 직접 고침 — 대표자 의지(보관/개). ↻ 로 자동으로 되돌림</span></div>

  <div class="card">
    <div class="hd">배송·물류비 <small>— 센터배송은 판매 계 × 센터 비율, 직송은 물류비 없음, 택배는 택배비를 박스마다 직접 넣는다</small>
      <button class="btn lnk" style="margin-left:auto" onclick="cenToggle()" title="센터별 물류비율과 보관 기본값을 고쳐 회사 설정에 저장">⚙ 센터 비율·보관 기본값</button>
    </div>
    <div class="bd">
      <div class="bar">
        <label class="opt"><input type="radio" name="mode" value="center" checked onchange="modeSet()"> 센터배송</label>
        <select id="center" onchange="calcAll()" title="센터별 물류비율(상단 표)" style="min-width:190px"></select>
        <label class="opt"><input type="radio" name="mode" value="direct" onchange="modeSet()"> 직송 <span class="dim">(물류비 없음)</span></label>
        <label class="opt"><input type="radio" name="mode" value="parcel" onchange="modeSet()"> 택배</label>
        <span id="parcelWrap" style="display:none;align-items:center;gap:6px">택배비/박스<span class="tag in">입력</span> <input type="text" class="num in" id="parcelFee" value="" style="width:90px" onfocus="this.select()" oninput="calcAll()"> 원</span>
        <span class="note" id="modeNote"></span>
      </div>
      <div class="cen" id="cen">
        <div class="bar" style="margin-bottom:8px"><b>센터별 물류비율(%)</b> <span class="note">판매 계(박스)에 곱한다</span></div>
        <div class="tw"><table class="sh"><thead><tr><th>센터</th><th>비율(%)</th><th></th></tr></thead><tbody id="cenBody"></tbody></table></div>
        <div class="bar" style="margin-top:8px"><button class="btn lnk" onclick="cenAdd()">➕ 센터</button></div>
        <div class="bar" style="margin-top:12px"><b>보관/개 기본값</b> <span class="note">= 보관료 × 팔레트 × 개월 ÷ MOQ 수량</span></div>
        <div class="bar" style="margin-top:6px">보관료 <input type="text" class="num in" id="storeFee" style="width:90px"> 원 × 팔레트 <input type="text" class="num in" id="storePlt" style="width:60px"> × 개월 <input type="text" class="num in" id="storeMon" style="width:60px"></div>
        <div class="bar" style="margin-top:10px"><button class="btn btn-teal" onclick="cenSave()">💾 회사 설정에 저장</button><button class="btn" onclick="cenToggle()">닫기</button></div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="hd">품목 <small>— 표본 시트 순서. 품목 줄 아래에 부대비(동판비·목형비 …) 줄 : 수량 × 단가 = 금액, 구매 칸에 개당</small></div>
    <div class="tw">
      <table class="sh">
        <thead>
          <tr>
            <th class="g1" colspan="6">배송</th><th class="g2" rowspan="2">박스<br>입수량</th><th class="g3" colspan="6">구매</th><th class="g3" colspan="2">판매</th>
            <th class="g4" rowspan="2">물류비<br><span id="thP" class="dim" style="font-weight:600"></span></th><th class="g5" rowspan="2">실 판매금액</th><th class="g5" rowspan="2">실 마진금액</th><th class="g6" rowspan="2">실 마진율</th>
            <th class="g7" rowspan="2">목표<br>마진율</th><th class="g7" rowspan="2">필요<br>판매단가</th><th class="g7" rowspan="2">별도 청구<br>(마진 0)</th><th class="g7" rowspan="2"></th>
          </tr>
          <tr>
            <th class="g1">제조사</th><th class="g1">품명</th><th class="g1">규격</th><th class="g1">MOQ수량</th><th class="g1">단가</th><th class="g1">금액</th>
            <th class="g3">구매<span class="tag au">계산</span></th><th class="g3">계</th><th class="g3">운송</th><th class="g3">보관</th><th class="g3">소분</th><th class="g3">박스</th>
            <th class="g3" id="thN">단가</th><th class="g3">계</th>
          </tr>
        </thead>
        <tbody id="items"></tbody>
      </table>
    </div>
    <div class="bd note">· 구매(개당, 계산) = 단가 + 운송 + 보관 + 소분 + 박스 + 부대비/개(원가 포함분 ÷ MOQ 수량) · 계 = 구매 × 입수 · 판매 계 = 판매단가 × 입수 · 실 판매 = 판매 계 − 물류비 · 실 마진 = 실 판매 − 구매 계 · 실 마진율 = 실 판매 ÷ 구매 계 − 1 · 별도 청구 부대비는 원가·마진에 안 들어가고 받은 만큼 그대로 청구</div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
function n(v){ if(v==null) return 0; var x=parseFloat(String(v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v,d){ d=d==null?0:d; var x=n(v); return x.toLocaleString('ko-KR',{minimumFractionDigits:d,maximumFractionDigits:d}); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function gv(id){ var e=document.getElementById(id); return e?e.value:''; }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }); }
function ok(m){ _alertBox(m,{icon:'✅'}); } function err(m){ _alertBox(m,{icon:'⚠️'}); }

/* ── 회사 설정(센터 비율·보관 기본값) ── */
var DEF_COST={ moqBoxDef:100, centers:[{nm:'평/용센터',rate:10.5},{nm:'왜관센터',rate:15.1},{nm:'광주센터',rate:14.6},{nm:'김해센터',rate:16.1},{nm:'제주센터',rate:18.1}], storeFee:25000, storePlt:3, storeMon:3 };
var COST=(function(){ var c=(window.konetSet&&konetSet.cost)||{}; return { centers:(c.centers&&c.centers.length)?c.centers.map(function(x){ return {nm:String(x.nm||''),rate:n(x.rate)}; }):DEF_COST.centers.slice(), storeFee:n(c.storeFee)||DEF_COST.storeFee, storePlt:n(c.storePlt)||DEF_COST.storePlt, storeMon:n(c.storeMon)||DEF_COST.storeMon, moqBoxDef:n(c.moqBoxDef)||DEF_COST.moqBoxDef }; })();
function centerFill(keep){
  var s=document.getElementById('center'), cur=keep?s.value:'';
  s.innerHTML=COST.centers.map(function(c,i){ return '<option value="'+i+'">'+esc(c.nm)+' — '+fmt(c.rate,1)+'%</option>'; }).join('');
  if(cur!==''&&s.querySelector('option[value="'+cur+'"]')) s.value=cur;
}
function cenToggle(){ var e=document.getElementById('cen'); e.classList.toggle('on'); if(e.classList.contains('on')) cenRender(); }
function cenRender(){
  document.getElementById('cenBody').innerHTML=COST.centers.map(function(c,i){ return '<tr><td class="l"><input type="text" class="in" value="'+esc(c.nm)+'" style="width:160px" oninput="COST.centers['+i+'].nm=this.value"></td><td><input type="text" class="num in w1" value="'+fmt(c.rate,1)+'" onfocus="this.select()" oninput="COST.centers['+i+'].rate=n(this.value)"></td><td class="c"><button class="btn lnk" onclick="COST.centers.splice('+i+',1); cenRender()">✕</button></td></tr>'; }).join('');
  document.getElementById('storeFee').value=fmt(COST.storeFee); document.getElementById('storePlt').value=fmt(COST.storePlt); document.getElementById('storeMon').value=fmt(COST.storeMon);
}
function cenAdd(){ COST.centers.push({nm:'',rate:0}); cenRender(); }
function cenSave(){
  COST.storeFee=n(gv('storeFee')); COST.storePlt=n(gv('storePlt')); COST.storeMon=n(gv('storeMon'));
  COST.centers=COST.centers.filter(function(c){ return (c.nm||'').trim(); });
  post('/user/compSetPatch.do',{ key:'cost', val:COST },true).then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); }); })
    .then(function(){ if(window.konetSet) konetSet.cost=COST; centerFill(true); calcAll(); ok('센터 비율·보관 기본값을 회사 설정에 저장했습니다.'); })
    .catch(function(e){ err('저장 실패 — '+esc(e.message)); });
}
function mode(){ var r=document.querySelector('input[name=mode]:checked'); return r?r.value:'center'; }
function modeSet(){
  var m=mode(); document.getElementById('center').style.display=m==='center'?'':'none'; document.getElementById('parcelWrap').style.display=m==='parcel'?'inline-flex':'none';
  document.getElementById('modeNote').textContent= m==='center'?'물류비 = 판매 계 × 센터 비율':(m==='direct'?'물류비 0 — 판매 계가 그대로 실 판매':'물류비 = 박스마다 택배비');
  calcAll();
}
function rate(){ var c=COST.centers[+gv('center')]; return c?n(c.rate):0; }
function centerNm(){ var c=COST.centers[+gv('center')]; return c?c.nm:''; }

/* ── 품목 ── */
var _items=[];
function blankItem(){ return { maker:'', nm:'', spec:'', moqQty:0, buy:0, box:0, trans:0, store:0, storeManual:false, split:0, pack:0, sell:0, target:0, extras:[{nm:'동판비',qty:0,price:0,sep:false},{nm:'목형비',qty:0,price:0,sep:false}] }; }   /* 빈 칸으로 시작 */
function addItem(){ _items.push(blankItem()); render(); var rows=document.querySelectorAll('tr.it'); var e=rows[rows.length-1]&&rows[rows.length-1].querySelector('.nm'); if(e) e.focus(); }
function delItem(i){ _confirmBox({ msg:'품목 '+(i+1)+'을 지울까요?', icon:'🗑', onOk:function(){ _items.splice(i,1); if(!_items.length) _items.push(blankItem()); render(); }, onCancel:function(){} }); }
function copyItem(i){ var c=JSON.parse(JSON.stringify(_items[i])); _items.splice(i+1,0,c); render(); }
function storeAuto(it){ var q=n(it.moqQty); return q? COST.storeFee*COST.storePlt*COST.storeMon/q : 0; }
/* 계산 — 표본 시트의 식 그대로 (머리 주석) */
function calc(it, setup){
  var G=n(it.box)||0, Q0=n(it.moqQty)||0, E=n(it.buy);
  var exSum=(it.extras||[]).filter(function(x){ return !x.sep; }).reduce(function(a,x){ return a+n(x.qty)*n(x.price); },0);   /* 원가 포함분 */
  var sepSum=(it.extras||[]).filter(function(x){ return x.sep; }).reduce(function(a,x){ return a+n(x.qty)*n(x.price); },0);   /* 별도 청구분 — 마진 0 */
  var exPer= Q0? exSum/Q0 : 0;
  var store= it.storeManual? n(it.store) : storeAuto(it);
  var H=E+n(it.trans)+store+n(it.split)+n(it.pack)+exPer;
  var I=H*G, N=n(it.sell), O=N*G;
  var P= setup.mode==='center'? O*setup.rate/100 : (setup.mode==='parcel'? n(setup.fee) : 0);
  var Q=O-P, R=Q-I, S= I? (Q/I-1) : 0, S2= Q? R/Q : 0;
  var t=n(it.target)/100, need= setup.mode==='center' ? (G&&setup.rate<100? I*(1+t)/(G*(1-setup.rate/100)) : 0) : (G? (I*(1+t)+(setup.mode==='parcel'?n(setup.fee):0))/G : 0);
  return { exSum:exSum, sepSum:sepSum, exPer:exPer, store:store, H:H, I:I, O:O, P:P, Q:Q, R:R, S:S, S2:S2, need:need, buyTotal:E*Q0 };
}
function setup(){ return { mode:mode(), rate:rate(), fee:n(gv('parcelFee')) }; }
/* 직접 입력 칸 */
function ci(i,k,val,d,w,ph){ return '<input type="text" class="num in '+(w||'w2')+'" value="'+(n(val)?fmt(val,d||0):'')+'" placeholder="'+(ph||'')+'" onfocus="this.select()" oninput="_items['+i+'].'+k+'=n(this.value); calcAll()">'; }
function ct(i,k,val,w,ph){ return '<input type="text" class="in '+(w||'w3')+'" value="'+esc(val)+'" placeholder="'+(ph||'')+'" oninput="_items['+i+'].'+k+'=this.value">'; }
function render(){
  if(!_items.length) _items.push(blankItem());
  var h='';
  _items.forEach(function(it,i){
    h+='<tr class="it">'
      +'<td class="l">'+ct(i,'maker',it.maker,'w1','제조사')+'</td>'
      +'<td class="l"><input type="text" class="in w4 nm" value="'+esc(it.nm)+'" placeholder="품명" oninput="_items['+i+'].nm=this.value"></td>'
      +'<td class="l">'+ct(i,'spec',it.spec,'w5','규격')+'</td>'
      +'<td>'+ci(i,'moqQty',it.moqQty,0,'w2','MOQ')+'</td>'
      +'<td>'+ci(i,'buy',it.buy,2,'w2','단가')+'</td>'
      +'<td class="au" id="f'+i+'"></td>'
      +'<td>'+ci(i,'box',it.box,0,'w1','입수')+'</td>'
      +'<td class="au" id="h'+i+'"></td><td class="au" id="i'+i+'"></td>'
      +'<td>'+ci(i,'trans',it.trans,2,'w1')+'</td>'
      +'<td><span style="display:inline-flex;gap:3px;align-items:center"><input type="text" class="num w1 '+(it.storeManual?'manual':'auto')+'" id="k'+i+'" value="" onfocus="this.select()" oninput="_items['+i+'].store=n(this.value); _items['+i+'].storeManual=true; calcAll()" title="기본 = 보관료 × 팔레트 × 개월 ÷ MOQ 수량. 직접 고치면 노란 칸"><button class="btn lnk" style="height:26px;padding:0 5px" onclick="_items['+i+'].storeManual=false; render()" title="기본식으로 되돌리기">↻</button></span></td>'
      +'<td>'+ci(i,'split',it.split,2,'w1')+'</td>'
      +'<td>'+ci(i,'pack',it.pack,2,'w1')+'</td>'
      +'<td>'+ci(i,'sell',it.sell,2,'w2','판매단가')+'</td>'
      +'<td class="au" id="o'+i+'"></td>'
      +'<td class="au p" id="p'+i+'"></td><td class="au q" id="q'+i+'"></td><td class="au q" id="r'+i+'"></td><td class="au s" id="s'+i+'"></td>'
      +'<td><span style="display:inline-flex;gap:3px;align-items:center">'+ci(i,'target',it.target,1,'w1')+'%</span></td>'
      +'<td class="au b" id="need'+i+'"></td><td class="au" id="sep'+i+'"></td>'
      +'<td class="c"><button class="btn lnk" onclick="copyItem('+i+')" title="이 품목을 복사해 아래에">⧉</button> <button class="btn lnk" onclick="delItem('+i+')" title="이 품목 지우기">✕</button></td>'
      +'</tr>';
    (it.extras||[]).forEach(function(x,j){
      h+='<tr class="ex">'
        +'<td></td>'
        +'<td class="l"><input type="text" class="in w4" value="'+esc(x.nm)+'" placeholder="부대비 이름 (예: 동판비)" oninput="_items['+i+'].extras['+j+'].nm=this.value"></td>'
        +'<td class="l"><select onchange="_items['+i+'].extras['+j+'].sep=(this.value===\'Y\'); calcAll()" title="원가 포함 = MOQ 수량으로 나눠 개당 구매에 더한다 / 별도 청구 = 원가에 안 넣고 이 금액을 그대로 따로 받는다(마진 없음)"><option value="N"'+(x.sep?'':' selected')+'>원가 포함</option><option value="Y"'+(x.sep?' selected':'')+'>별도 청구(마진 0)</option></select></td>'
        +'<td><input type="text" class="num in w2" value="'+(n(x.qty)?fmt(x.qty):'')+'" placeholder="수량" onfocus="this.select()" oninput="_items['+i+'].extras['+j+'].qty=n(this.value); calcAll()"></td>'
        +'<td><input type="text" class="num in w2" value="'+(n(x.price)?fmt(x.price):'')+'" placeholder="단가" onfocus="this.select()" oninput="_items['+i+'].extras['+j+'].price=n(this.value); calcAll()"></td>'
        +'<td class="au" id="exAmt'+i+'_'+j+'"></td>'
        +'<td></td>'
        +'<td class="au" id="exPer'+i+'_'+j+'" title="금액 ÷ MOQ 수량 (원가 포함일 때만)"></td>'
        +'<td colspan="14"></td>'
        +'<td class="c"><button class="btn lnk" onclick="_items['+i+'].extras.splice('+j+',1); render()" title="이 부대비 줄 빼기">✕</button></td>'
        +'</tr>';
    });
    h+='<tr class="add"><td colspan="23"><button class="btn lnk" onclick="_items['+i+'].extras.push({nm:\'\',qty:0,price:0,sep:false}); render()">➕ 부대비 줄</button></td></tr>';
    h+='<tr class="gap"><td colspan="23"></td></tr>';
  });
  document.getElementById('items').innerHTML=h;
  calcAll();
}
function setTd(id,txt,cls){ var e=document.getElementById(id); if(!e) return; e.textContent=txt; if(cls!=null){ e.classList.remove('neg','amber'); if(cls) e.classList.add(cls); } }
function calcAll(){
  var st=setup();
  document.getElementById('thP').textContent= st.mode==='center'?centerNm()+' '+fmt(st.rate,1)+'%':(st.mode==='parcel'?'택배비':'직송 0');
  document.getElementById('thN').textContent='판매적용단가';   /* 2026-09-17 「평/용센터를 판매적용단가로 변경」 — 센터 이름 대신 고정 이름 */
  _items.forEach(function(it,i){
    var r=calc(it,st), cls=r.S<0?'neg':(r.S<0.1?'amber':'');
    setTd('f'+i, r.buyTotal?fmt(r.buyTotal):'');
    setTd('h'+i, r.H?fmt(r.H,2):''); setTd('i'+i, r.I?fmt(r.I):'');
    var ke=document.getElementById('k'+i); if(ke && !it.storeManual) ke.value=r.store?fmt(r.store,2):'';
    setTd('o'+i, r.O?fmt(r.O):''); setTd('p'+i, r.O||r.P?fmt(r.P):''); setTd('q'+i, r.O?fmt(r.Q):'');
    setTd('r'+i, (r.O||r.I)?fmt(r.R):'', cls); setTd('s'+i, r.I&&r.O?fmt(r.S*100,2)+'%':'', cls);
    setTd('need'+i, r.I&&n(it.target)?fmt(r.need,2):''); setTd('sep'+i, r.sepSum?fmt(r.sepSum):'');
    (it.extras||[]).forEach(function(x,j){ var amt=n(x.qty)*n(x.price); setTd('exAmt'+i+'_'+j, amt?fmt(amt):''); setTd('exPer'+i+'_'+j, (!x.sep&&amt&&n(it.moqQty))?fmt(amt/n(it.moqQty),2):''); });
  });
  saveDraft();
}

/* ── 자동 저장(이 브라우저) · 견적서로 · 엑셀 ── */
function saveDraft(){ try{ localStorage.setItem('konet.costCalc', JSON.stringify({ mode:mode(), center:gv('center'), fee:gv('parcelFee'), items:_items })); }catch(e){} }
function loadDraft(){ try{ var d=JSON.parse(localStorage.getItem('konet.costCalc')||'null'); if(!d) return false; var r=document.querySelector('input[name=mode][value="'+d.mode+'"]'); if(r) r.checked=true; if(d.center!=null) document.getElementById('center').value=d.center; if(d.fee) document.getElementById('parcelFee').value=d.fee; _items=(d.items||[]).map(function(it){ var b=blankItem(); for(var k in it) if(k!=='moqBox'&&k!=='moqManual') b[k]=it[k]; return b; }); return _items.length>0; }catch(e){ return false; } }
function clearAll(){ _confirmBox({ msg:'입력한 품목을 모두 비울까요?', icon:'🗑', onOk:function(){ _items=[blankItem()]; render(); }, onCancel:function(){} }); }
function toQuote(){
  var st=setup(), lines=[];
  _items.filter(function(it){ return (it.nm||'').trim(); }).forEach(function(it){
    var r=calc(it,st); lines.push({ prodNm:it.nm, spec:it.spec, boxQty:1, qty:n(it.box), unitPrice:n(it.sell), remark:'MOQ '+fmt(it.moqQty)+'개', margin:r.S });   /* 2026-09-17 「견적서 적용 시 Box 1 · 수량 = 박스 입수량」 */
    (it.extras||[]).filter(function(x){ return x.sep && (x.nm||'').trim() && n(x.qty)*n(x.price); }).forEach(function(x){ lines.push({ prodNm:x.nm, spec:'', boxQty:'', qty:n(x.qty), unitPrice:n(x.price), remark:'별도 청구', margin:0 }); });   /* 별도 청구 부대비 — 받은 금액 그대로(마진 0). 규격은 비운다 (2026-09-17 「따라오는 규격 제거」) */
  });
  if(!lines.length){ err('품명을 넣은 품목이 없습니다.'); return; }
  try{ localStorage.setItem('konet.costToQuote', JSON.stringify({ ts:Date.now(), lines:lines, deliv: st.mode==='center'?'센터배송':(st.mode==='parcel'?'택배출고 (D2~3)':'직송') })); }catch(e){ err('브라우저 저장소를 쓸 수 없습니다.'); return; }
  try{ var a=parent.document.querySelector('.mi[data-key="quoteEdit"]'); if(a){ a.click(); return; } }catch(e){}
  ok('견적서 작성 메뉴를 열면 품목이 들어갑니다.');
}
/* 엑셀 — 표본 시트 꼴(칸 차례 같음) : 품목 줄 아래에 부대비 줄. 숫자 서식(천 단위·소수·%)과 머리 칠, 테두리, 칸 너비 */
function excel(){
  if(typeof XLSX==='undefined'){ err('엑셀 모듈이 없습니다.'); return; }
  var st=setup(), bd={ top:{style:'thin',color:{rgb:'B7C4D0'}}, bottom:{style:'thin',color:{rgb:'B7C4D0'}}, left:{style:'thin',color:{rgb:'B7C4D0'}}, right:{style:'thin',color:{rgb:'B7C4D0'}} };
  var hs=function(rgb){ return { font:{bold:true,sz:10}, fill:{fgColor:{rgb:rgb}}, alignment:{horizontal:'center',vertical:'center',wrapText:true}, border:bd }; };
  var sT={ alignment:{vertical:'center',wrapText:true}, border:bd }, sN={ numFmt:'#,##0', alignment:{vertical:'center'}, border:bd }, sD={ numFmt:'#,##0.00', alignment:{vertical:'center'}, border:bd }, sP={ numFmt:'0.0%', alignment:{vertical:'center'}, border:bd };
  var sIn={ fill:{fgColor:{rgb:'FDEBD9'}}, alignment:{vertical:'center',wrapText:true}, border:bd }, sInN={ fill:{fgColor:{rgb:'FDEBD9'}}, numFmt:'#,##0', alignment:{vertical:'center'}, border:bd }, sInD={ fill:{fgColor:{rgb:'FDEBD9'}}, numFmt:'#,##0.00', alignment:{vertical:'center'}, border:bd }, sInP={ fill:{fgColor:{rgb:'FDEBD9'}}, numFmt:'0.0%', alignment:{vertical:'center'}, border:bd };
  var sPB={ fill:{fgColor:{rgb:'D9ECF7'}}, numFmt:'#,##0', alignment:{vertical:'center'}, border:bd }, sQ={ fill:{fgColor:{rgb:'FFF9D6'}}, numFmt:'#,##0', alignment:{vertical:'center'}, border:bd }, sS={ fill:{fgColor:{rgb:'E3F7DF'}}, numFmt:'0.00%', font:{bold:true}, alignment:{vertical:'center'}, border:bd };
  var sX={ fill:{fgColor:{rgb:'F7FAFC'}}, font:{color:{rgb:'4A5A6A'},sz:10}, alignment:{vertical:'center'}, border:bd }, sXN={ fill:{fgColor:{rgb:'F7FAFC'}}, font:{color:{rgb:'4A5A6A'},sz:10}, numFmt:'#,##0', alignment:{vertical:'center'}, border:bd }, sXD={ fill:{fgColor:{rgb:'F7FAFC'}}, font:{color:{rgb:'4A5A6A'},sz:10}, numFmt:'#,##0.00', alignment:{vertical:'center'}, border:bd };
  var t=function(v,s){ return { v:v==null?'':v, t:'s', s:s||sT }; }, num=function(v,s){ return { v:n(v), t:'n', s:s||sN }; }, blank=function(s){ return { v:'', t:'s', s:s||sT }; };
  var Y='FFF3A3', O='F7C99A', B='A9D0E6', G='A8E6A0', E='E6EBF1';
  var dv= st.mode==='center' ? '센터배송 — '+centerNm()+' '+fmt(st.rate,1)+'% (판매 계 × 비율)' : (st.mode==='parcel' ? '택배 — 택배비/박스 '+fmt(st.fee)+'원' : '직송 — 물류비 없음');
  var aoa=[ [ t('원가·마진 계산',{font:{bold:true,sz:14}}) ], [ t('배송',{font:{bold:true}}), t(dv) ], [ t('보관/개 기본',{font:{bold:true}}), t('보관료 '+fmt(COST.storeFee)+' × 팔레트 '+fmt(COST.storePlt)+' × 개월 '+fmt(COST.storeMon)+' ÷ MOQ 수량') ], [ t('작성',{font:{bold:true}}), t(new Date().toISOString().slice(0,10)) ], [] ];
  var pn= st.mode==='center'?(centerNm()||'단가'):'단가';
  aoa.push([ t('배송',hs(Y)),blank(hs(Y)),blank(hs(Y)),blank(hs(Y)),blank(hs(Y)),blank(hs(Y)), t('박스 입수량',hs(O)), t('구매',hs(Y)),blank(hs(Y)),blank(hs(Y)),blank(hs(Y)),blank(hs(Y)),blank(hs(Y)), t('판매',hs(Y)),blank(hs(Y)), t('물류비',hs(B)), t('실 판매금액',hs(Y)), t('실 마진금액',hs(Y)), t('실 마진율',hs(G)), t('목표 마진율',hs(E)), t('필요 판매단가',hs(E)), t('별도 청구(마진 0)',hs(E)), t('판매가 대비 마진율',hs(E)) ]);
  aoa.push([ t('제조사',hs(Y)), t('품명',hs(Y)), t('규격',hs(Y)), t('MOQ수량',hs(Y)), t('단가',hs(Y)), t('금액',hs(Y)), blank(hs(O)), t('구매',hs(Y)), t('계',hs(Y)), t('운송',hs(Y)), t('보관',hs(Y)), t('소분',hs(Y)), t('박스',hs(Y)), t(pn,hs(Y)), t('계',hs(Y)), t(st.mode==='center'?centerNm():'',hs(B)), blank(hs(Y)), blank(hs(Y)), blank(hs(G)), blank(hs(E)), blank(hs(E)), blank(hs(E)), blank(hs(E)) ]);
  _items.forEach(function(it,i){
    var r=calc(it,st);
    aoa.push([ t(it.maker,sIn), t(it.nm,sIn), t(it.spec,sIn), num(it.moqQty,sInN), num(it.buy,sInD), num(r.buyTotal), num(it.box,sInN), num(r.H,sD), num(r.I), num(it.trans,sInD), num(r.store, it.storeManual?sInD:sD), num(it.split,sInD), num(it.pack,sInD), num(it.sell,sInD), num(r.O), num(r.P,sPB), num(r.Q,sQ), num(r.R,sQ), num(r.S,sS), num(n(it.target)/100,sInP), num(r.need,sD), r.sepSum?num(r.sepSum):blank(), num(r.S2,sP) ]);
    (it.extras||[]).filter(function(x){ return (x.nm||'').trim()||n(x.qty)*n(x.price); }).forEach(function(x){
      var amt=n(x.qty)*n(x.price);
      var row=[ blank(sX), t((x.nm||'')+(x.sep?' (별도 청구·마진 0)':' (원가 포함)'),sX), blank(sX), num(x.qty,sXN), num(x.price,sXN), num(amt,sXN), blank(sX), (!x.sep&&amt&&n(it.moqQty))?num(amt/n(it.moqQty),sXD):blank(sX) ];
      while(row.length<23) row.push(blank(sX));
      aoa.push(row);
    });
  });
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  ws['!cols']=[{wch:9},{wch:26},{wch:30},{wch:10},{wch:10},{wch:12},{wch:8},{wch:10},{wch:11},{wch:8},{wch:8},{wch:8},{wch:8},{wch:10},{wch:11},{wch:11},{wch:12},{wch:12},{wch:10},{wch:9},{wch:12},{wch:12},{wch:11}];
  ws['!rows']=[{hpt:22},null,null,null,null,{hpt:22},{hpt:22}];
  ws['!merges']=[{ s:{r:1,c:1}, e:{r:1,c:8} },{ s:{r:2,c:1}, e:{r:2,c:8} },
    { s:{r:5,c:0}, e:{r:5,c:5} },{ s:{r:5,c:6}, e:{r:6,c:6} },{ s:{r:5,c:7}, e:{r:5,c:12} },{ s:{r:5,c:13}, e:{r:5,c:14} },
    { s:{r:5,c:16}, e:{r:6,c:16} },{ s:{r:5,c:17}, e:{r:6,c:17} },{ s:{r:5,c:18}, e:{r:6,c:18} },{ s:{r:5,c:19}, e:{r:6,c:19} },{ s:{r:5,c:20}, e:{r:6,c:20} },{ s:{r:5,c:21}, e:{r:6,c:21} },{ s:{r:5,c:22}, e:{r:6,c:22} }];
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '원가마진');
  XLSX.writeFile(wb, '원가마진계산_'+new Date().toISOString().slice(0,10).replace(/-/g,'')+'.xlsx');
}

/* ── 시작 ── */
centerFill(false);
(function(){ var v=window.konetSet?n(konetSet.f('parcelFeeDef')):0; var e=document.getElementById('parcelFee'); if(e && !e.value && v) e.value=fmt(v); })();   /* 택배비 첫 값 = 회사 설정 기본 운임 */
if(!loadDraft()) _items=[blankItem()];
modeSet(); render();
window.konetShown=function(){ /* 설정(센터 비율)은 셸이 konetSetReload 로 새로 읽어 둔다 — 그것을 다시 받는다 */
  try{ var c=window.konetSet&&konetSet.cost; if(c&&c.centers&&c.centers.length){ COST.centers=c.centers.map(function(x){ return {nm:String(x.nm||''),rate:n(x.rate)}; }); COST.storeFee=n(c.storeFee)||COST.storeFee; COST.storePlt=n(c.storePlt)||COST.storePlt; COST.storeMon=n(c.storeMon)||COST.storeMon; centerFill(true); calcAll(); } }catch(e){}
};
</script>
</body>
</html>
