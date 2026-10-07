<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>거래처 매출장·마감</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 쓰기 (전역 XLSX, 서식 포함) --%>
<%-- 우리 달력 (2026-10-07 사용자 「달력 두 개 뜨게」) — 공용 ui-datenav.js. 기간칸 slFrom ~ slTo 를 짝으로 묶어 두 달을 나란히 띄운다(xxFrom/xxTo 이름 규칙).
     달력에서 기간을 다 고르면 종료칸 change 한 번 → dateChg() 로 조회 --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<%--
  거래처 매출장 · 마감 (2026-10-07 신설) — 매출 관리 ▸ 거래처 매출장·마감. 셸 iframe(logiFrame) 화면.
  · 사용자 「샐러드플러스 0821 · 우리푸드 0821 = 매출장 거래처별로 / 우리푸드 샐러드플러스 7월 마감 = 두 거래처 이름 포함으로 마감 / 매출관리 메뉴에」
    + 「확장 감안해서 만들어줘」. 표본 = D:\코네트\샐러드플러스 0821.xlsx · 우리푸드 0821.xlsx · 우리푸드 샐러드플러스 7월 마감.xlsx (옛 시스템 출력).
  · 원천 = 판매 등록(판매전표). 기간 = 전표일자. 서버 /mangr/salesLedgerList.do (매퍼 selectSalesLedger).
  · ★확장 = 「마감 유형」(거래처 묶음). 유형 하나 = 이름 + 거래처 여러 곳(순서 = 마감장 순서). 유형도 거래처도 몇 개든 늘린다.
    저장 = 회사 설정 SET_JSON 의 ledger 덩어리(/mangr/salesLedgerGrpSave.do) — 회사 공용이라 어느 PC 에서나 같다. 표를 새로 두지 않았다(DDL 없음).
    아직 저장한 유형이 없으면 거래처 마스터에서 「우리푸드」·「샐러드 플러스」를 찾아 기본 유형 「우리푸드」를 보여 준다(저장 전).
  · 탭 ① 거래처별 매출장 — 표본 0821 과 같은 칸 : 일자 · 거래처명 · 상품명 · BOX · 합계(수량) · 단가 · 금액 · 세액 · 합계.
         단가 = 공급가 ÷ 수량 (부가세 포함 거래처도 공급가 단가 — 표본 샐러드 플러스 66,120 = 72,732 ÷ 1.1) · 금액 = 공급가 · 세액 · 합계 = 공급가 + 세액.
         엑셀 = 거래처마다 파일 하나(표본처럼) 또는 한 파일에 거래처별 시트.
    탭 ② 마감장(유형별 매출원장) — 표본 7월 마감과 같은 칸 : 거래처 · 일자 · 번호 · NO · 구분 · 상품명 · 수량 · 단가 · 금액 · 판매액 · 계.
         단가·금액 = 전표에 넣은 그대로(부가세 포함 거래처면 포함 단가 — 표본 샐러드 플러스 72,732) · 판매액 = 공급가 + 세액 · 계 = 처음부터의 판매액 누계.
         번호 = 그 날의 전표 번호 · NO = 전표 안 줄 차례 · 일계(연두) · 소계(보라, 거래처마다) · 합계(크림). 제목 = [유형 이름] 유형별 매출원장 전체조회.
  · 반품 줄은 수량·금액이 음수로 오고 구분이 「반품」.
  · 이 설명은 JSP 주석이다 — 받은 엑셀 자료 이야기가 페이지 소스로 나가지 않게 (같은 날 「팁 내용에 엑셀 준 자료 내용은 제외」).
--%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; background:#fff; border:1px solid var(--bd); border-radius:10px; padding:9px 12px; margin-bottom:10px; }
  .bar label{ font-size:12.5px; font-weight:700; color:#37475a; }
  .bar .sep{ width:1px; height:22px; background:#e3e8ee; margin:0 4px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; font-family:inherit; }
  .btn:hover{ border-color:var(--teal); } .btn:disabled{ opacity:.5; cursor:default; }
  .btn.sm{ height:28px; padding:0 10px; font-size:12.5px; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); } .btn-red{ color:var(--red); }
  input[type=date], select, input[type=text]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; font-family:inherit; background:#fff; }
  select{ min-width:170px; font-weight:700; }
  .chips{ display:flex; gap:6px; align-items:center; flex-wrap:wrap; margin:0 0 10px; }
  .chips .lab{ font-size:12.5px; font-weight:700; color:#37475a; margin-right:2px; }
  .chip{ display:inline-flex; align-items:center; gap:5px; height:30px; padding:0 11px; border:1px solid #b9d8cf; background:#eef8f5; color:#125a4e; border-radius:16px; font-size:13px; font-weight:700; cursor:pointer; user-select:none; }
  .chip input{ margin:0; cursor:pointer; }
  .chip.off{ background:#f4f6f8; border-color:var(--bd); color:#9aa7b3; text-decoration:line-through; }
  .chip .cnt{ font-size:11.5px; font-weight:600; color:#6b7a89; text-decoration:none; }
  .chips .hint{ font-size:12px; color:var(--amber); margin-left:6px; }
  /* 탭 — 지금 보는 쪽을 꽉 찬 청록으로 (2026-10-07 사용자 「구분 더 명확하게」 — 종전엔 흰 바탕·회색 바탕 차이뿐이라 어느 쪽인지 헷갈렸다) */
  .tabs{ display:flex; gap:6px; align-items:flex-end; flex-wrap:wrap; border-bottom:2px solid #9fd3c7; margin-bottom:10px; }
  .tab{ height:40px; padding:0 20px; border:1px solid #c9d3dc; border-bottom:0; border-radius:9px 9px 0 0; background:#eef1f4; cursor:pointer; font-size:14px; font-weight:700; color:#6b7a89; font-family:inherit; }
  .tab:hover{ background:#e2efeb; color:#125a4e; }
  .tab.on{ background:#dcf1ec; color:#0f5f54; border-color:#9fd3c7; border-top:3px solid #3fa392; font-size:14.5px; }   /* 「색깔 조금 연하게」(같은 날) — 꽉 찬 청록 → 연한 청록 */
  .tab .tsub{ font-size:11.5px; font-weight:600; opacity:.8; margin-left:4px; }
  /* 엑셀 출력 단추 — 엑셀 초록으로 따로 보이게 (같은 날 「엑셀 출력 버튼도」) */
  .btn-xls{ background:#e8f5ec; color:#1d6f42; border-color:#a9d6b8; }   /* 「색깔 조금 연하게」 — 진한 초록 → 연한 초록 바탕 · 초록 글자 */
  .btn-xls:hover{ background:#d5eddd; border-color:#6fba88; }
  .tabs .info{ font-size:12.5px; color:#3d4d5c; margin-left:6px; }
  .tabs .act{ margin-left:auto; display:flex; gap:6px; padding-bottom:5px; }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:8px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14.5px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .card .hd .sum{ margin-left:auto; font-size:13px; color:#1f2a37; }
  .doc{ padding:10px 12px 12px; }
  .doc-t{ text-align:center; font-size:17px; font-weight:800; margin:2px 0 6px; }
  .doc-p{ font-size:12.5px; color:#37475a; border-bottom:1px solid #9fb6c3; padding:0 0 4px; margin-bottom:6px; display:flex; gap:10px; }
  .doc-p .r{ margin-left:auto; }
  .tw{ overflow:auto; }
  table.lg{ border-collapse:collapse; width:100%; font-size:12.5px; }
  table.lg th{ background:#d9edf7; font-weight:700; border:1px solid #9fb6c3; padding:6px 6px; white-space:nowrap; text-align:center; }
  table.lg td{ border:1px solid #c9d3dc; padding:4px 6px; text-align:center; white-space:nowrap; }
  table.lg td.l{ text-align:left; } table.lg td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.lg td.nm{ white-space:normal; min-width:240px; }
  table.lg tr.neg td{ color:var(--red); }
  table.lg tr.lg-day td{ background:#eeffb9; } table.lg tr.lg-day td.lg-keep{ background:#fff; }
  table.lg tr.lg-sub td{ background:#ecc7ff; } table.lg tr.lg-tot td{ background:#fcf8e3; font-weight:700; }
  table.lg td.cust{ text-align:left; font-weight:700; border-top-color:transparent; border-bottom-color:transparent; }
  table.lg tr.first td.cust{ border-top-color:#c9d3dc; }
  .msg{ padding:22px; text-align:center; color:#8a98a8; }
  .empty-cust{ font-size:12.5px; color:#8a98a8; padding:8px 12px; }
  /* 유형 편집 창 */
  .pop{ display:none; position:fixed; inset:0; z-index:60; background:rgba(15,23,32,.45); align-items:center; justify-content:center; }
  .pop.on{ display:flex; }
  .pbox{ background:#fff; border-radius:12px; width:560px; max-width:96vw; max-height:90vh; display:flex; flex-direction:column; box-shadow:0 14px 44px rgba(0,0,0,.28); overflow:hidden; }
  .ph{ display:flex; align-items:center; padding:11px 14px; border-bottom:1px solid #eef1f5; font-size:15.5px; font-weight:800; }
  .ph .x{ margin-left:auto; border:0; background:none; font-size:18px; cursor:pointer; color:#6b7a89; }
  .pb{ padding:12px 14px; overflow:auto; flex:1; }
  .pb .row{ margin-bottom:10px; }
  .pb .row > label{ display:block; font-size:12.5px; font-weight:800; color:#37475a; margin-bottom:4px; }
  .pb .row small{ display:block; font-size:11.5px; color:#6b7a89; margin-top:3px; }
  .pb input[type=text]{ width:100%; }
  ol.gl{ margin:0; padding:0; list-style:none; border:1px solid var(--bd); border-radius:8px; max-height:250px; overflow:auto; }
  ol.gl li{ display:flex; align-items:center; gap:8px; padding:6px 8px; border-bottom:1px solid #eef1f5; font-size:13px; }
  ol.gl li:last-child{ border-bottom:0; }
  ol.gl li .no{ width:20px; text-align:right; color:#8a98a8; font-size:12px; }
  ol.gl li b{ font-weight:700; } ol.gl li small{ display:inline; color:#8a98a8; margin:0; }
  ol.gl li .sp{ flex:1; }
  ol.gl li button{ height:26px; min-width:28px; border:1px solid var(--bd); background:#fff; border-radius:6px; cursor:pointer; font-size:12px; }
  ol.gl li.none{ color:#8a98a8; justify-content:center; padding:14px; }
  .hits{ margin-top:6px; display:flex; flex-direction:column; gap:3px; max-height:200px; overflow:auto; }
  .hits button{ text-align:left; border:1px solid #e3e8ee; background:#fafcfd; border-radius:6px; padding:6px 9px; cursor:pointer; font-size:13px; font-family:inherit; }
  .hits button:hover{ border-color:var(--teal); background:#f0f9f6; }
  .hits button small{ color:#8a98a8; margin-left:6px; }
  .pf{ display:flex; gap:8px; align-items:center; padding:10px 14px; border-top:1px solid #eef1f5; }
</style>
</head>
<body>
<span id="compNm" style="display:none"><c:out value="${sessionScope.s_comp_nm}"/></span>
<div class="wrap">
  <h2>📗 거래처 매출장 · 마감 <small>판매 등록(판매전표) 기준 · 거래처 묶음(마감 유형)은 회사 공용으로 저장됩니다</small></h2>

  <div class="bar">
    <label>기간</label>
    <input type="date" id="slFrom" onchange="dateChg()"> ~ <input type="date" id="slTo" onchange="dateChg()">
    <button class="btn sm" onclick="setRange('d')">오늘</button>
    <button class="btn sm" onclick="setRange(0)">이번 달</button>
    <button class="btn sm" onclick="setRange(-1)">지난달</button>
    <span class="sep"></span>
    <label>마감 유형</label>
    <select id="grpSel" onchange="grpPick()"></select>
    <button class="btn sm" onclick="geOpen(false)" title="이 유형의 이름·거래처·순서를 고칩니다">✏️ 유형 편집</button>
    <button class="btn sm" onclick="geOpen(true)" title="거래처 묶음을 새로 만듭니다 (예: 다른 거래처들의 마감)">＋ 새 유형</button>
    <span class="sep"></span>
    <button class="btn btn-teal" onclick="load()">🔍 조회</button>
  </div>

  <div class="chips" id="chips"></div>

  <div class="tabs">
    <button class="tab on" id="tab-l" onclick="tab('l')">📄 거래처별 매출장<span class="tsub">거래처마다 따로</span></button>
    <button class="tab" id="tab-c" onclick="tab('c')">📒 마감장<span class="tsub">유형별 매출원장 · 거래처 모아서</span></button>
    <span class="info" id="info"></span>
    <span class="act" id="act-l">
      <button class="btn btn-xls" onclick="xlsLedgerAll(false)" title="거래처마다 엑셀 파일을 하나씩 만듭니다 (거래처 수만큼 내려받기)">📥 매출장 엑셀 출력 · 거래처마다 파일</button>
      <button class="btn btn-xls" onclick="xlsLedgerAll(true)" title="엑셀 파일 하나에 거래처마다 시트를 하나씩 만듭니다">📥 매출장 엑셀 출력 · 한 파일(시트별)</button>
    </span>
    <span class="act" id="act-c" style="display:none">
      <button class="btn btn-xls" onclick="xlsClose()" title="지금 보는 마감장(일계·소계·합계 포함)을 엑셀 파일 하나로 만듭니다">📥 마감장 엑셀 출력</button>
    </span>
  </div>

  <div id="pane-l"><div class="msg">기간과 마감 유형을 고르고 [🔍 조회]를 누르세요.</div></div>
  <div id="pane-c" style="display:none">
    <div class="card"><div class="doc">
      <div class="doc-t" id="cTitle">유형별 매출원장 전체조회</div>
      <div class="doc-p"><span id="cPeriod"></span><span class="r" id="cType"></span></div>
      <div class="tw"><table class="lg">
        <thead><tr><th>거래처</th><th>일자</th><th>번호</th><th>NO</th><th>구분</th><th>상품명</th><th>수량</th><th>단가</th><th>금액</th><th>판매액</th><th>계</th></tr></thead>
        <tbody id="cBody"><tr><td colspan="11" class="msg">조회하면 여기에 나옵니다.</td></tr></tbody>
      </table></div>
    </div></div>
  </div>
</div>

<!-- 마감 유형 편집 -->
<div class="pop" id="gePop" onclick="if(event.target===this) geClose()">
  <div class="pbox">
    <div class="ph"><span id="geTitle">마감 유형 편집</span><button class="x" onclick="geClose()">✕</button></div>
    <div class="pb">
      <div class="row">
        <label>유형 이름</label>
        <input type="text" id="geNm" maxlength="40" placeholder="예) 우리푸드">
        <small>마감장 제목 「[유형 이름] 유형별 매출원장 전체조회」와 「유형」 칸에 들어갑니다.</small>
      </div>
      <div class="row">
        <label>거래처 <span id="geCnt" style="font-weight:600;color:#6b7a89"></span></label>
        <ol class="gl" id="geList"></ol>
        <small>위에서부터 마감장에 나오는 차례입니다. ▲▼로 바꿉니다.</small>
      </div>
      <div class="row">
        <label>거래처 추가</label>
        <input type="text" id="geFind" placeholder="거래처 이름 · 코드 · 별칭으로 찾기" oninput="geFindRun()" onkeydown="if(event.key==='Enter'){ event.preventDefault(); geFirstHit(); }">
        <div class="hits" id="geHits"></div>
      </div>
    </div>
    <div class="pf">
      <button class="btn btn-red" id="geDelBtn" onclick="geDelete()">🗑 유형 삭제</button>
      <span style="flex:1"></span>
      <button class="btn" onclick="geClose()">닫기</button>
      <button class="btn btn-teal" id="geSaveBtn" onclick="geSave()">💾 저장</button>
    </div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }); }
function ok(m){ _alertBox(m,{icon:'✅'}); } function err(m){ _alertBox(m,{icon:'⚠️'}); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(v); return isFinite(x)?x:0; }
function fmt(v){ return Math.round(n(v)).toLocaleString('ko-KR'); }
function fmt2(v){ return n(v).toLocaleString('ko-KR',{ minimumFractionDigits:2, maximumFractionDigits:2 }); }
function fq(v){ var x=n(v); return Math.round(x)===x ? x.toLocaleString('ko-KR') : x.toLocaleString('ko-KR',{ maximumFractionDigits:3 }); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function nkey(s){ return String(s||'').replace(/\s+/g,'').toLowerCase(); }
function lsGet(k){ try{ return localStorage.getItem(k); }catch(e){ return null; } }
function lsSet(k,v){ try{ localStorage.setItem(k,v); }catch(e){} }

/* ── 기준자료 : 거래처 마스터 + 마감 유형(회사 설정 ledger) ── */
var _vend=[], _grps=[], _gi=0, _seeded=false, _off={}, _rows=null, _q=null, _tab='l', _cl=null;

/* 저장한 유형이 아직 없을 때의 기본 유형 — 우리푸드 + 샐러드 플러스 (유형 이름 「우리푸드」) */
function seedGrps(){
  var want=['우리푸드','샐러드플러스'], cs=[];
  want.forEach(function(w){ for(var i=0;i<_vend.length;i++){ if(nkey(_vend[i].nm)===w){ cs.push({ cd:_vend[i].cd, nm:_vend[i].nm }); break; } } });
  return cs.length ? [{ nm:'우리푸드', custs:cs }] : [];
}
function loadBase(){
  return Promise.all([
    post('/vendor/selectVendorMst.do','').then(function(r){ return r.json(); }).then(function(j){ return (j&&j.data)||[]; }).catch(function(){ return []; }),
    post('/user/compSetGet.do','').then(function(r){ return r.json(); }).catch(function(){ return {}; })
  ]).then(function(a){
    _vend=a[0].map(function(v){ return { cd:String(v.vendorCd||''), nm:String(v.vendorNm||''), alias:String(v.alias||''), full:String(v.fullNm||''), gb:String(v.vendorGb||''), vat:String(v.vatGb||'') }; });
    var raw={}; try{ raw=(a[1]&&a[1].setJson) ? JSON.parse(a[1].setJson) : {}; }catch(e){ raw={}; }
    var g=(raw && raw.ledger && raw.ledger.grps) || null;
    var keep=(_grps[_gi]||{}).nm || lsGet('slGrp') || '';
    if(g && g.length){ _grps=g; _seeded=false; } else { _grps=seedGrps(); _seeded=_grps.length>0; }
    _gi=0; for(var i=0;i<_grps.length;i++){ if(_grps[i].nm===keep){ _gi=i; break; } }
    grpFill();
  });
}
function vendNm(cd){ for(var i=0;i<_vend.length;i++) if(_vend[i].cd===cd) return _vend[i].nm; return ''; }
function grpFill(){
  var s=document.getElementById('grpSel');
  if(!_grps.length){ s.innerHTML='<option value="">(유형 없음 — ＋ 새 유형)</option>'; renderChips(); return; }
  s.innerHTML=_grps.map(function(g,i){ return '<option value="'+i+'"'+(i===_gi?' selected':'')+'>'+esc(g.nm)+' ('+(g.custs||[]).length+'곳)</option>'; }).join('');
  renderChips();
}
function grpPick(){ _gi=+document.getElementById('grpSel').value||0; _off={}; lsSet('slGrp', (_grps[_gi]||{}).nm||''); renderChips(); load(); }
function curGrp(){ return _grps[_gi] || null; }
function renderChips(){
  var g=curGrp(), el=document.getElementById('chips');
  if(!g){ el.innerHTML='<span class="lab">거래처</span><span class="hint">마감 유형이 없습니다 — [＋ 새 유형]으로 거래처를 묶어 주세요.</span>'; return; }
  var cnt={}; (_rows||[]).forEach(function(r){ cnt[r.custCd]=(cnt[r.custCd]||0)+1; });
  el.innerHTML='<span class="lab">거래처</span>'+(g.custs||[]).map(function(c){
      var off=!!_off[c.cd], nm=vendNm(c.cd)||c.nm||c.cd, k=(_q && cnt[c.cd]!=null) ? '<span class="cnt">'+cnt[c.cd]+'줄</span>' : (_q?'<span class="cnt">0줄</span>':'');
      return '<label class="chip'+(off?' off':'')+'" title="거래처코드 '+esc(c.cd)+' · 끄면 이번 조회에서 뺍니다"><input type="checkbox"'+(off?'':' checked')+' onchange="chipToggle(\''+esc(c.cd)+'\', this.checked)">'+esc(nm)+k+'</label>'; }).join('')
    +(_seeded?'<span class="hint">※ 기본으로 보여 주는 유형입니다(아직 저장 전) — [✏️ 유형 편집]에서 저장하면 모든 PC 에 같이 보입니다.</span>':'');
}
function chipToggle(cd, on){ if(on) delete _off[cd]; else _off[cd]=1; renderChips(); load(); }

/* ── 기간 ── */
function setRange(d){
  var t=new Date(), a, b;
  if(d==='d'){ a=t; b=t; } else { a=new Date(t.getFullYear(), t.getMonth()+d, 1); b=new Date(t.getFullYear(), t.getMonth()+d+1, 0); }
  document.getElementById('slFrom').value=ymd(a); document.getElementById('slTo').value=ymd(b); load();
}

/* 날짜 칸이 바뀌면 조회 — 달력(두 달)에서 기간을 고르면 한 번, 손으로 고치면 칸마다. 기간이 뒤집혔거나 빈 칸이면 조용히 기다린다(알림 없음) */
function dateChg(){ var fr=document.getElementById('slFrom').value, to=document.getElementById('slTo').value; if(fr && to && fr<=to) load(); }
/* ── 조회 ── */
function load(){
  var g=curGrp(), fr=document.getElementById('slFrom').value, to=document.getElementById('slTo').value;
  if(!g){ return; }
  if(!fr || !to){ err('조회 기간을 넣으세요.'); return; }
  if(fr>to){ err('시작일이 끝일보다 늦습니다.'); return; }
  var custs=(g.custs||[]).filter(function(c){ return !_off[c.cd]; }).map(function(c){ return { cd:c.cd, nm:vendNm(c.cd)||c.nm||c.cd }; });
  if(!custs.length){ _rows=[]; _q={ fr:fr, to:to, grp:g.nm, custs:[] }; render(); return; }
  document.getElementById('pane-l').innerHTML='<div class="msg">불러오는 중…</div>';
  document.getElementById('cBody').innerHTML='<tr><td colspan="11" class="msg">불러오는 중…</td></tr>';
  document.getElementById('info').textContent='';
  post('/mangr/salesLedgerList.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)+'&custCds='+encodeURIComponent(custs.map(function(c){ return c.cd; }).join(',')))
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(j && j.error){ throw new Error(j.error); }
      _rows=(j&&j.data)||[]; _q={ fr:fr, to:to, grp:g.nm, custs:custs };
      _rows.forEach(function(r){ var c=null; for(var i=0;i<custs.length;i++) if(custs[i].cd===r.custCd){ c=custs[i]; break; } if(c && r.custNm) c.nm=r.custNm; });
      render(); renderChips();
    })
    .catch(function(e){ _rows=null; _q=null; var m='<div class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</div>';
      document.getElementById('pane-l').innerHTML=m; document.getElementById('cBody').innerHTML='<tr><td colspan="11" class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function rowsOf(cd){ return (_rows||[]).filter(function(r){ return r.custCd===cd; }); }
function isRet(r){ return /반품/.test(String(r.trxGb||'')); }

/* ── ① 거래처별 매출장 ── */
/* 줄 하나 → 매출장 칸. 단가 = 공급가 ÷ 수량(소수 2자리) */
function lrow(r){ var q=n(r.qty), sup=n(r.supplyAmt);
  return { dt:d10(r.saleDt), cust:String(r.custNm||''), nm:String(r.prodNm||''), box:n(r.boxQty), qty:q,
           price:(q ? Math.round(sup/q*100)/100 : n(r.unitPrice)), sup:sup, vat:n(r.vatAmt), tot:n(r.totAmt), ret:isRet(r) }; }
function ledgerOf(c){
  var L=rowsOf(c.cd).map(lrow), s={ box:0, qty:0, sup:0, vat:0, tot:0 };
  L.forEach(function(x){ s.box+=x.box; s.qty+=x.qty; s.sup+=x.sup; s.vat+=x.vat; s.tot+=x.tot; });
  return { c:c, lines:L, sum:s };
}
function renderLedger(){
  var p=document.getElementById('pane-l');
  if(!_q){ p.innerHTML='<div class="msg">기간과 마감 유형을 고르고 [🔍 조회]를 누르세요.</div>'; return; }
  if(!_q.custs.length){ p.innerHTML='<div class="msg">고른 거래처가 없습니다 — 위 거래처 칩을 켜 주세요.</div>'; return; }
  p.innerHTML=_q.custs.map(function(c, ci){
    var Lg=ledgerOf(c), s=Lg.sum;
    var hd='<div class="hd">🏢 '+esc(c.nm)+' <small>'+esc(c.cd)+' · '+Lg.lines.length+'줄</small>'
      +'<span class="sum">'+(Lg.lines.length?'합계 <b>'+fmt(s.tot)+'</b>원 (공급가 '+fmt(s.sup)+' · 세액 '+fmt(s.vat)+')':'')+'</span>'
      +(Lg.lines.length?'<button class="btn sm btn-xls" onclick="xlsLedger('+ci+')" title="이 거래처의 매출장을 엑셀 파일로 만듭니다">📥 개별 매출장 출력</button>':'')+'</div>';
    if(!Lg.lines.length) return '<div class="card">'+hd+'<div class="empty-cust">이 기간에 판매전표가 없습니다.</div></div>';
    var body=Lg.lines.map(function(x){
      return '<tr'+(x.ret?' class="neg"':'')+'><td>'+esc(x.dt)+'</td><td class="l">'+esc(x.cust)+'</td><td class="l nm">'+esc(x.nm)+'</td>'
        +'<td class="r">'+fq(x.box)+'</td><td class="r">'+fq(x.qty)+'</td><td class="r">'+fmt2(x.price)+'</td>'
        +'<td class="r">'+fmt(x.sup)+'</td><td class="r">'+fmt(x.vat)+'</td><td class="r">'+fmt(x.tot)+'</td></tr>'; }).join('');
    body+='<tr class="lg-tot"><td>합 계</td><td></td><td></td><td class="r">'+fq(s.box)+'</td><td class="r">'+fq(s.qty)+'</td><td></td>'
      +'<td class="r">'+fmt(s.sup)+'</td><td class="r">'+fmt(s.vat)+'</td><td class="r">'+fmt(s.tot)+'</td></tr>';
    return '<div class="card">'+hd+'<div class="doc"><div class="doc-t">[매출장]</div><div class="doc-p">조회기간 : '+esc(_q.fr)+' ~ '+esc(_q.to)+'</div>'
      +'<div class="tw"><table class="lg"><thead><tr><th>일자</th><th>거래처명</th><th>상품명</th><th>BOX</th><th>합계</th><th>단가</th><th>금액</th><th>세액</th><th>합계</th></tr></thead><tbody>'+body+'</tbody></table></div></div></div>';
  }).join('');
}

/* ── ② 마감장(유형별 매출원장) ── 거래처(유형 차례) → 일자 → 전표 번호 → 줄. 일계·소계·합계 · 계 = 판매액 누계 */
function closeBuild(){
  var out=[], run=0, tot={ amt:0, sale:0 }, custN=0, cnt=0;
  _q.custs.forEach(function(c){
    var rs=rowsOf(c.cd); if(!rs.length) return; custN++;
    var sub={ amt:0, sale:0 }, first=true, i=0;
    while(i<rs.length){
      var dt=rs[i].saleDt, day={ amt:0, sale:0 };
      while(i<rs.length && rs[i].saleDt===dt){
        var no=rs[i].saleNo, ln=0;
        while(i<rs.length && rs[i].saleDt===dt && rs[i].saleNo===no){
          var r=rs[i], amt=n(r.amt), sale=n(r.totAmt); ln++; cnt++; run+=sale; day.amt+=amt; day.sale+=sale;
          out.push({ k:'row', first:first, cust:(first?c.nm:''), dt:d10(r.saleDt), no:(/^\d+$/.test(String(r.saleNo))?Number(r.saleNo):String(r.saleNo||'')), ln:ln,
                     gb:(isRet(r)?'반품':'매출'), nm:String(r.prodNm||''), qty:n(r.qty), price:n(r.unitPrice), amt:amt, sale:sale, run:run });
          first=false; i++; }
      }
      out.push({ k:'day', amt:day.amt, sale:day.sale }); sub.amt+=day.amt; sub.sale+=day.sale;
    }
    out.push({ k:'sub', amt:sub.amt, sale:sub.sale }); tot.amt+=sub.amt; tot.sale+=sub.sale;
  });
  if(cnt) out.push({ k:'tot', amt:tot.amt, sale:tot.sale });
  return { lines:out, cnt:cnt, custN:custN, tot:tot };
}
function renderClose(){
  var tb=document.getElementById('cBody');
  document.getElementById('cTitle').textContent='['+(_q?_q.grp:'')+'] 유형별 매출원장 전체조회';
  document.getElementById('cPeriod').textContent=_q?('조회기간 : '+_q.fr+' ~ '+_q.to):'';
  document.getElementById('cType').textContent=_q?('유형 : '+_q.grp+' · '+_q.custs.map(function(c){ return c.nm; }).join(', ')):'';
  if(!_q){ _cl=null; tb.innerHTML='<tr><td colspan="11" class="msg">조회하면 여기에 나옵니다.</td></tr>'; return; }
  _cl=closeBuild();
  if(!_cl.cnt){ tb.innerHTML='<tr><td colspan="11" class="msg">이 기간에 판매전표가 없습니다.</td></tr>'; return; }
  tb.innerHTML=_cl.lines.map(function(o){
    if(o.k==='row') return '<tr class="'+(o.first?'first':'')+(o.gb==='반품'?' neg':'')+'"><td class="cust">'+esc(o.cust)+'</td><td>'+esc(o.dt)+'</td><td>'+esc(o.no)+'</td><td>'+o.ln+'</td><td>'+o.gb+'</td>'
      +'<td class="l nm">'+esc(o.nm)+'</td><td class="r">'+fq(o.qty)+'</td><td class="r">'+fmt(o.price)+'</td><td class="r">'+fmt(o.amt)+'</td><td class="r">'+fmt(o.sale)+'</td><td class="r">'+fmt(o.run)+'</td></tr>';
    var cls=o.k==='day'?'lg-day':(o.k==='sub'?'lg-sub':'lg-tot'), lab=o.k==='day'?'일계':(o.k==='sub'?'소계':'합계');
    return '<tr class="'+cls+'">'+(o.k==='day'?'<td class="lg-keep cust"></td><td>일계</td>':'<td>'+lab+'</td><td></td>')
      +'<td></td><td></td><td></td><td></td><td></td><td></td><td class="r"><b>'+fmt(o.amt)+'</b></td><td class="r"><b>'+fmt(o.sale)+'</b></td><td></td></tr>';
  }).join('');
}
function render(){
  renderLedger(); renderClose();
  var info=document.getElementById('info');
  if(!_q){ info.textContent=''; return; }
  var t=0, k=0; (_rows||[]).forEach(function(r){ t+=n(r.totAmt); k++; });
  var withRows=_q.custs.filter(function(c){ return rowsOf(c.cd).length>0; }).length;
  info.innerHTML='거래처 <b>'+withRows+'</b>/'+_q.custs.length+'곳 · <b>'+k+'</b>줄 · 판매액 합계 <b>'+fmt(t)+'</b>원';
}
function tab(t){
  _tab=t; lsSet('slTab', t);
  ['l','c'].forEach(function(x){ document.getElementById('tab-'+x).classList.toggle('on', x===t);
    document.getElementById('pane-'+x).style.display=(x===t?'':'none'); document.getElementById('act-'+x).style.display=(x===t?'':'none'); });
}

/* ── 엑셀 ── */
function E(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; }
function serial(d){ var p=String(d).split('-'); return (Date.UTC(+p[0],+p[1]-1,+p[2])-Date.UTC(1899,11,30))/86400000; }
function fnSafe(s){ return String(s||'').replace(/[\\\/:*?"<>|]/g,'_').trim(); }
function f8(d){ return String(d).replace(/-/g,''); }
function isFullMonth(f,t){ if(f.slice(0,7)!==t.slice(0,7) || f.slice(8)!=='01') return false; var p=t.split('-'); return new Date(+p[0], +p[1], 0).getDate()===+p[2]; }
/* 기간 꼬리표 — 하루 = 0821 · 한 달 전체 = 7월 · 그 밖 = 0801~0815 (해가 다르면 8자리) */
function pTag(){ var f=_q.fr, t=_q.to;
  if(f===t) return f.slice(5,7)+f.slice(8,10);
  if(isFullMonth(f,t)) return (+f.slice(5,7))+'월';
  if(f.slice(0,4)===t.slice(0,4)) return f.slice(5,7)+f.slice(8,10)+'~'+t.slice(5,7)+t.slice(8,10);
  return f8(f)+'~'+f8(t); }
function wch(s){ var w=0; String(s||'').split('').forEach(function(ch){ w+=(ch.charCodeAt(0)>255?1.8:1); }); return w; }
function noXls(){ if(!window.XLSX){ err('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return true; } if(!_q){ err('먼저 조회하세요.'); return true; } return false; }

/* 매출장 시트 하나 — 굴림 9 · 제목 [매출장] 17 굵게(A1:I2) · 조회기간(A3:I3, 밑줄) · 머리글 하늘 · 본문 흰 바탕 · 합 계 크림 */
function ledgerSheet(c){
  var Lg=ledgerOf(c), s=Lg.sum, bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var aoa=[ ['[매출장]'].concat(E(8)), E(9), ['조회기간 : '+_q.fr+' ~ '+_q.to].concat(E(8)), ['일자','거래처명','상품명','BOX','합계','단가','금액','세액','합계'] ], kinds=['t','t','p','h'], nmW=24.75;
  Lg.lines.forEach(function(x){ aoa.push([serial(x.dt), x.cust, x.nm, x.box, x.qty, x.price, x.sup, x.vat, x.tot]); kinds.push('row'); nmW=Math.max(nmW, Math.min(52, wch(x.nm)+2)); });
  aoa.push(['합 계','','',s.box,s.qty,'',s.sup,s.vat,s.tot]); kinds.push('tot');
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  for(var r=0;r<aoa.length;r++){ var k=kinds[r];
    for(var cc=0;cc<9;cc++){ var ref=XLSX.utils.encode_cell({ r:r, c:cc }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'굴림', sz:17, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else {
        st.border=box; st.fill={ fgColor:{ rgb:(k==='tot'?'FCF8E3':'FFFFFF') } };
        st.alignment.horizontal = cc>=3 ? 'right' : (k==='tot' && cc===0 ? 'center' : 'left');
        if(k==='row' && cc===0){ ws[ref].t='n'; ws[ref].z='m/d/yy'; }
        if(ws[ref].t==='n' && cc===5) ws[ref].z='#,##0.00';
        if(ws[ref].t==='n' && cc>=6) ws[ref].z='#,##0';
      }
      ws[ref].s=st; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:8 } }, { s:{ r:2, c:0 }, e:{ r:2, c:8 } } ];
  ws['!cols']=[{ wch:8 },{ wch:Math.max(11, Math.min(30, wch(c.nm)+2)) },{ wch:nmW },{ wch:5 },{ wch:5 },{ wch:9.5 },{ wch:10.5 },{ wch:9 },{ wch:10.5 }];
  ws['!rows']=aoa.map(function(a,i){ return { hpt:(i<2?18.75:16.5) }; });
  return { ws:ws, n:Lg.lines.length, tot:s.tot };
}
function ledgerBook(c){ var S=ledgerSheet(c), wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, S.ws, ('매출장_'+f8(_q.fr)+'~'+f8(_q.to)).slice(0,31)); return { wb:wb, S:S }; }
function xlsLedger(ci){
  if(noXls()) return; var c=_q.custs[ci]; if(!c) return;
  var B=ledgerBook(c); if(!B.S.n){ err('이 거래처는 이 기간에 판매전표가 없습니다.'); return; }
  XLSX.writeFile(B.wb, fnSafe(c.nm+' '+pTag())+'.xlsx');
  if(window._toast) _toast('📥 '+c.nm+' 매출장 — '+B.S.n+'줄 · 합계 '+fmt(B.S.tot)+'원','ok');
}
/* 모두 — oneFile=true 면 한 파일에 거래처별 시트, 아니면 거래처마다 파일 (차례로 내려받는다. 브라우저가 「여러 파일 다운로드 허용」을 물으면 허용) */
function xlsLedgerAll(oneFile){
  if(noXls()) return;
  var list=_q.custs.filter(function(c){ return rowsOf(c.cd).length>0; });
  if(!list.length){ err('엑셀로 낼 자료가 없습니다.'); return; }
  if(oneFile){
    var wb=XLSX.utils.book_new(), used={};
    list.forEach(function(c){ var S=ledgerSheet(c), nm=fnSafe(c.nm).replace(/[\[\]]/g,'_').slice(0,28)||c.cd, k=nm, i=2; while(used[k]){ k=nm.slice(0,26)+'_'+(i++); } used[k]=1; XLSX.utils.book_append_sheet(wb, S.ws, k); });
    XLSX.writeFile(wb, fnSafe((list.length<=3 ? list.map(function(c){ return c.nm; }).join(' ') : _q.grp+' '+list.length+'곳')+' 매출장 '+pTag())+'.xlsx');
    if(window._toast) _toast('📥 매출장 한 파일 — 거래처 '+list.length+'곳(시트)','ok');
    return;
  }
  var i=0;
  (function next(){ if(i>=list.length){ if(window._toast) _toast('📥 매출장 '+list.length+'개 파일 — 거래처마다 하나','ok'); return; }
    var c=list[i++], B=ledgerBook(c); XLSX.writeFile(B.wb, fnSafe(c.nm+' '+pTag())+'.xlsx'); setTimeout(next, 600); })();
}

/* 마감장 — 맑은 고딕 10 · 제목 15 굵게(A1:K2) · 조회기간(A3:K3, 밑줄) · 기간/유형/출력일자/회사 줄 · 머리글 · 일계 연두 · 소계 보라 · 합계 크림 */
function xlsClose(){
  if(noXls()) return;
  if(!_cl || !_cl.cnt){ err('엑셀로 낼 자료가 없습니다.'); return; }
  var today=ymd(new Date()), comp=String((document.getElementById('compNm')||{}).textContent||'').trim(), grp=_q.grp;
  var bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd }, nmW=36;
  var aoa=[ ['['+grp+'] 유형별 매출원장 전체조회'].concat(E(10)), E(11), ['조회기간 : '+_q.fr+' ~ '+_q.to].concat(E(10)),
            [_q.fr+' ~ '+_q.to,'','','유형',grp,'','','출력일자 : '+today,'','',comp],
            ['거래처','일자','번호','NO','구분','상품명','수량','단가','금액','판매액','계'] ];
  var kinds=['t','t','p','h','h'];
  _cl.lines.forEach(function(o){
    if(o.k==='row'){ aoa.push([o.cust, serial(o.dt), o.no, o.ln, o.gb, o.nm, o.qty, o.price, o.amt, o.sale, o.run]); nmW=Math.max(nmW, Math.min(56, wch(o.nm)+2)); }
    else if(o.k==='day') aoa.push(['','일계','','','','','','',o.amt,o.sale,'']);
    else aoa.push([(o.k==='sub'?'소계':'합계'),'','','','','','','',o.amt,o.sale,'']);
    kinds.push(o.k); });
  var ws=XLSX.utils.aoa_to_sheet(aoa), FILL={ day:'EEFFB9', sub:'ECC7FF', tot:'FCF8E3' };
  for(var r=0;r<aoa.length;r++){ var k=kinds[r];
    for(var cc=0;cc<11;cc++){ var ref=XLSX.utils.encode_cell({ r:r, c:cc }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'맑은 고딕', sz:10 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'맑은 고딕', sz:15, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else {
        st.border=box; st.fill={ fgColor:{ rgb:(k==='row'?'FFFFFF':FILL[k]) } };
        st.alignment.horizontal = (cc>=6) ? 'right' : (cc===5 ? 'left' : (cc===0 ? (k==='row'?'left':'center') : 'center'));
        if(cc===0 && (k==='row' || k==='day')){ st.fill={ fgColor:{ rgb:'FFFFFF' } }; st.border={ left:bd, right:bd }; }
        if(k==='row' && cc===1){ ws[ref].t='n'; ws[ref].z='m/d/yy'; }
        if(ws[ref].t==='n' && cc>=7) ws[ref].z='#,##0';
      }
      ws[ref].s=st; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:10 } }, { s:{ r:2, c:0 }, e:{ r:2, c:10 } },
                  { s:{ r:3, c:0 }, e:{ r:3, c:2 } }, { s:{ r:3, c:4 }, e:{ r:3, c:6 } }, { s:{ r:3, c:7 }, e:{ r:3, c:9 } } ];
  var custW=12; _q.custs.forEach(function(c){ custW=Math.max(custW, Math.min(30, wch(c.nm)+2)); });
  ws['!cols']=[{ wch:custW },{ wch:9.75 },{ wch:4.75 },{ wch:4.75 },{ wch:4.75 },{ wch:nmW },{ wch:5.5 },{ wch:8 },{ wch:11 },{ wch:11 },{ wch:12 }];
  ws['!rows']=aoa.map(function(a,i){ return { hpt:(i<2?18.75:16.5) }; });
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, ('유형별원장조회_전체_'+f8(_q.fr)+'~'+f8(_q.to)+'_'+fnSafe(grp).replace(/[\[\]]/g,'_')).slice(0,31));
  /* 파일 이름 = 거래처 이름을 함께 (예: 「우리푸드 샐러드 플러스 7월 마감」). 거래처가 4곳 이상이면 유형 이름 + 곳 수 */
  var names=_q.custs.filter(function(c){ return rowsOf(c.cd).length>0; }).map(function(c){ return c.nm; });
  var head=names.length<=3 ? names.join(' ') : grp+' '+names.length+'곳', tag=pTag();
  XLSX.writeFile(wb, fnSafe(head+' '+(isFullMonth(_q.fr,_q.to) ? tag+' 마감' : '마감 '+tag))+'.xlsx');
  if(window._toast) _toast('📥 마감장 엑셀 — '+_cl.cnt+'줄 · 판매액 합계 '+fmt(_cl.tot.sale)+'원','ok');
}

/* ── 마감 유형 편집 ── */
var _ge=null;
function geOpen(isNew){
  if(!isNew && !curGrp()) isNew=true;
  var g=curGrp();
  _ge=isNew ? { i:-1, custs:[] } : { i:_gi, custs:(g.custs||[]).map(function(c){ return { cd:c.cd, nm:vendNm(c.cd)||c.nm||c.cd }; }) };
  if(!isNew && _seeded) _ge.i=-2;   /* 저장 전 기본 유형 → 저장하면 새로 생긴다 */
  document.getElementById('geTitle').textContent=isNew?'＋ 새 마감 유형':'✏️ 마감 유형 편집';
  document.getElementById('geNm').value=isNew?'':g.nm;
  document.getElementById('geFind').value=''; document.getElementById('geHits').innerHTML='';
  document.getElementById('geDelBtn').style.display=(_ge.i>=0?'':'none');
  geRender(); document.getElementById('gePop').classList.add('on');
  setTimeout(function(){ document.getElementById(isNew?'geNm':'geFind').focus(); }, 30);
}
function geClose(){ document.getElementById('gePop').classList.remove('on'); _ge=null; }
function geRender(){
  var ul=document.getElementById('geList'); document.getElementById('geCnt').textContent='('+_ge.custs.length+'곳)';
  if(!_ge.custs.length){ ul.innerHTML='<li class="none">아래에서 거래처를 찾아 추가하세요.</li>'; return; }
  ul.innerHTML=_ge.custs.map(function(c,i){
    return '<li><span class="no">'+(i+1)+'</span><b>'+esc(c.nm)+'</b><small>'+esc(c.cd)+'</small><span class="sp"></span>'
      +'<button onclick="geMove('+i+',-1)"'+(i===0?' disabled':'')+' title="위로">▲</button><button onclick="geMove('+i+',1)"'+(i===_ge.custs.length-1?' disabled':'')+' title="아래로">▼</button>'
      +'<button onclick="geDel('+i+')" title="이 유형에서 빼기" style="color:#c0392b">✕</button></li>'; }).join('');
}
function geMove(i,d){ var j=i+d; if(j<0 || j>=_ge.custs.length) return; var t=_ge.custs[i]; _ge.custs[i]=_ge.custs[j]; _ge.custs[j]=t; geRender(); }
function geDel(i){ _ge.custs.splice(i,1); geRender(); geFindRun(); }
var _geHits=[];
function geFindRun(){
  var q=nkey(document.getElementById('geFind').value), box=document.getElementById('geHits');
  if(!q){ box.innerHTML=''; _geHits=[]; return; }
  var have={}; _ge.custs.forEach(function(c){ have[c.cd]=1; });
  _geHits=_vend.filter(function(v){ return !have[v.cd] && (nkey(v.nm).indexOf(q)>=0 || nkey(v.cd).indexOf(q)>=0 || nkey(v.alias).indexOf(q)>=0 || nkey(v.full).indexOf(q)>=0); })
    .sort(function(a,b){ var sa=/매출/.test(a.gb)?0:1, sb=/매출/.test(b.gb)?0:1; return sa-sb || a.nm.localeCompare(b.nm,'ko'); }).slice(0,40);
  box.innerHTML=_geHits.length ? _geHits.map(function(v,i){ return '<button onclick="geAdd('+i+')">＋ '+esc(v.nm)+'<small>'+esc(v.cd)+(v.gb?' · '+esc(v.gb):'')+(v.vat?' · 부가세 '+esc(v.vat):'')+'</small></button>'; }).join('')
    : '<div class="empty-cust">맞는 거래처가 없습니다.</div>';
}
function geFirstHit(){ if(_geHits.length) geAdd(0); }
function geAdd(i){ var v=_geHits[i]; if(!v) return; _ge.custs.push({ cd:v.cd, nm:v.nm }); geRender(); document.getElementById('geFind').value=''; geFindRun(); document.getElementById('geFind').focus(); }
function geSave(){
  var nm=String(document.getElementById('geNm').value||'').trim();
  if(!nm){ err('유형 이름을 넣으세요.'); return; }
  if(!_ge.custs.length){ err('거래처를 한 곳 이상 넣으세요.'); return; }
  var base=_seeded ? [] : _grps.slice();
  for(var k=0;k<base.length;k++){ if(k!==_ge.i && base[k].nm===nm){ err('같은 이름의 유형이 이미 있습니다.'); return; } }
  var g={ nm:nm, custs:_ge.custs.map(function(c){ return { cd:c.cd, nm:c.nm }; }) };
  if(_ge.i>=0 && !_seeded) base[_ge.i]=g; else base.push(g);
  grpSaveAll(base, nm, '💾 마감 유형 「'+nm+'」을(를) 저장했습니다.');
}
function geDelete(){
  if(!_ge || _ge.i<0) return; var g=_grps[_ge.i];
  _confirmBox({ icon:'🗑', okText:'삭제', msg:'마감 유형 <b>'+esc(g.nm)+'</b>을(를) 지웁니다.<br><span style="font-size:13px;color:#3d4d5c">거래처 묶음만 지워집니다 — 판매전표는 그대로입니다.</span>',
    onOk:function(){ var base=_grps.slice(); base.splice(_ge.i,1); grpSaveAll(base, (base[0]||{}).nm||'', '🗑 마감 유형을 지웠습니다.'); }, onCancel:function(){} });
}
function grpSaveAll(list, pickNm, okMsg){
  var b=document.getElementById('geSaveBtn'); b.disabled=true;
  post('/mangr/salesLedgerGrpSave.do',{ grps:list },true).then(function(r){ return r.json(); })
    .then(function(j){
      if(!j || j.error) throw new Error((j&&j.error)||'저장하지 못했습니다.');
      _grps=j.grps||[]; _seeded=false; _gi=0;
      for(var i=0;i<_grps.length;i++){ if(_grps[i].nm===pickNm){ _gi=i; break; } }
      lsSet('slGrp', (_grps[_gi]||{}).nm||''); _off={};
      geClose(); grpFill(); if(window._toast) _toast(okMsg,'ok'); load();
    })
    .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
    .then(function(){ b.disabled=false; });
}

/* ── 다시 보일 때 (셸 logiFrame) — 거래처 마스터·마감 유형만 다시 읽는다(다른 PC·화면에서 고친 것). 3초 안 재호출 · 편집 창이 열려 있으면 건너뛴다 ── */
var _shownAt=0;
window.konetShown=function(){
  var t=Date.now(); if(t-_shownAt<3000) return; _shownAt=t;
  if(document.getElementById('gePop').classList.contains('on')) return;
  loadBase();
};

/* ── 시작 — 처음 기간 = 지난달(마감은 지난달 치를 본다). 다른 기간은 날짜를 고치거나 [오늘]·[이번 달] ── */
(function(){
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth()-1, 1), b=new Date(t.getFullYear(), t.getMonth(), 0);
  document.getElementById('slFrom').value=ymd(a); document.getElementById('slTo').value=ymd(b);
  tab(lsGet('slTab')==='c'?'c':'l');
  _shownAt=Date.now();
  loadBase().then(function(){ if(curGrp()) load(); });
})();
</script>
</body>
</html>
