<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>동원홈푸드 등록</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 읽기·쓰기 (전역 XLSX, 서식 포함) --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20261014"></script>   <%-- 표 높이 막대 — 위 미리보기 · 아래 저장 목록 --%>
<!--
  동원홈푸드 등록 (2026-10-29 신설 — 사용자 「대상 발주 등록 밑에 동원홈푸드 등록 메뉴 추가 · 토더 등록 형태 · 엑셀 동원홈푸드 매출장부도 · 매출 및 재고 직접 연계」) — 매출 관리 ▸ 동원홈푸드 등록. 셸 iframe(logiFrame) 화면.
  · 동원홈푸드가 내려 주는 「직송발주정보_주문내역_YYYYMMDD.xlsx」(머리 1행 : 배송일자 · 납품진행상태 · 주문마감 · 생성일시 · 확정일시 · 상품코드 · 상품명 · 규격 · 온도 · 포장단위 · 출고단위 ·
    최대포장량 · 원주문량 · 최종주문량 · 공급처수량 · 주문번호 · 의뢰번호 · 순번 · 배송처코드 · 배송처 · 배송처주소 · 배송처연락처 · 주문요청사항 · 공급처코드 · 공급처명 · 거래처코드)을 올린다.
  · 토더 발주 등록(toderPo.jsp)과 같은 틀 — 엑셀에는 우리 사업장코드·품목코드가 없다 → 줄마다 둘 다 넣고 [💾 저장]. 같은 배송처·같은 상품명의 빈 칸은 한 번 넣으면 같이 채워진다.
    저장하면 (배송처 → 사업장코드), (상품명 → 품목코드), (동원 상품코드 → 품목코드) 짝이 쌓여 다음 업로드부터 자동으로 채워진다(/shipout/dongwonPoMap.do — 저장된 줄에서 읽는다, 표를 따로 안 둔다).
    동원 상품코드(640862 …)를 상품코드등록 ▸ 매칭코드에 걸어 두면 처음부터 자동이다(매칭코드 = 품목코드로 바로 쓴다).
  · ★엑셀에 단가가 없다 → 판매가(부가세 별도)는 「지난 동원 저장 단가 → 그 품목의 계약단가(판매 등록과 같은 규칙) → 상품 판매가」 차례로 채우고 사람이 고친다. 출처는 파란 배지로.
    ★수량 = 최종주문량(출고단위 BOX) — 토더와 같이 엑셀 단위 그대로 넣는다(규격 「3,000EA/BOX」는 단위 칸·비고에 남긴다). 단가도 그 단위(BOX) 기준으로 넣는다.
  · 배송일자 = 납기일자 = 출고일자. 납품진행상태가 취소·반려면 기본으로 체크를 뺀다.
  · 저장 = TBL_SHIPOUT_MST PROD_KIND='TD'(출고장 「동원홈푸드」 DONGWON) + 재고 연동 — 저장·삭제·수량 수정하면 그 배송일자들의 출고 원장을 다시 만들어 재고에서 뺀다.
    매출 = 수량 × 판매가(부가세 별도) — 거래처 「동원홈푸드」(VENDOR_CD·DC_CD='DONGWON', DDL docs/sql/20261029_dongwon_po.sql). 마감(근거 '동원')·매출 그래프(직접판매 칸, 출고장 줄 '동원홈푸드')·채권·채무·일계장·거래처 원장 모두 토더와 같은 식.
    같은 (주문번호, 순번, 상품명)을 다시 올리면 앞의 것을 대체한다(마감 전 자료를 여러 번 받아 올려도 중복되지 않는다). 반품은 저장된 줄의 수량을 줄인다(0 = 전량 반품).
  · 받는 곳(배송처·주소·연락처)은 RCV_NM·RCV_ADDR·RCV_TEL 에, 동원 상품코드는 RCV_ITEM_CD 에, 의뢰번호는 JUMUN_NO 에 남는다(택배 처리·다음 매칭용).
  · [📒 동원홈푸드 매출장부] — 아래 목록의 조회 기간으로 저장된 줄을 새로 읽어 배송처·배송일자별(일계 · 소계 · 합계 · 누계)로 묶은 엑셀을 «바로» 내린다(공급가액 · 부가세(과세 10% · 면세 0) · 합계).
    ★창 없이 바로 엑셀(2026-10-29 사용자 「이 내용 필요 없이 엑셀 바로 나오게」 — 처음 판의 미리보기 창을 뺐다). 화면만의 기능(서버는 그대로).
  · 원본 파일은 보관하지 않는다. 파일 이름만 남는다. [✏️ 직접 입력]은 엑셀 없이 줄을 만들어 친다(토더와 같다).
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); } .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); } .btn-red{ color:var(--red); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  #upCard.on{ outline:2px dashed var(--teal); outline-offset:-2px; background:#f3faf8; }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:4px 6px; text-align:center; white-space:nowrap; vertical-align:middle; }
  table.g td.l{ text-align:left; } table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g input[type=text]{ height:30px; border:1.5px solid #e9b98a; background:#fdebd9; border-radius:6px; padding:0 6px; font-size:13px; width:130px; }
  table.g input[type=text].ok{ border-color:#7cc5b2; background:#f3fbf8; }
  table.g input[type=text].auto{ border-color:#9db7e8; background:#eef3fd; }
  table.g input[type=text].bad{ border-color:#e2b93b; background:#fff7d6; }
  table.g tr.off td{ color:#9aa7b3; background:#fafbfc; }
  table.g input[type=text].num{ width:86px; text-align:right; background:#fff; border:1px solid var(--bd); font-variant-numeric:tabular-nums; }
  table.g input[type=text].num:focus{ border-color:var(--teal); outline:none; }
  table.g input[type=text].num.bad{ border-color:#e2b93b; background:#fff7d6; }
  table.g input[type=text].mi, table.g input[type=date].mi{ height:30px; background:#fff; border:1px solid var(--bd); border-radius:6px; padding:0 6px; font-size:13px; font-family:inherit; }
  table.g input.mi:focus{ border-color:var(--teal); outline:none; }
  table.g input[type=date].mi.bad{ border-color:#e2b93b; background:#fff7d6; }
  .sub{ display:block; font-size:11.5px; color:#6b7a89; margin-top:1px; max-width:230px; overflow:hidden; text-overflow:ellipsis; }
  .sub.warn{ color:var(--amber); }
  .sub.nmf{ font-size:13px; color:#1f2a37; font-weight:700; margin:0 0 3px; max-width:260px; }
  table.g input[type=text]{ width:170px; }
  .bd{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .bd.auto{ background:#e8eefb; color:#2f4f9a; } .bd.st{ background:#eef2f5; color:#556; } .bd.cx{ background:#fdecec; color:var(--red); }
  .bd.ps{ background:#e3f2ee; color:#0f6b5e; }   /* 단가 출처(지난 저장 · 계약 · 판매가) */
  .dim{ color:#8a98a8; }
  input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; }
  .msg{ padding:22px; text-align:center; color:#8a98a8; }
  .note{ font-size:12.5px; color:#6b7a89; padding:8px 12px; line-height:1.6; }
  /* 「거래처 매출장·마감」 그리드 모양(2026-10-21 「DC·토더·대상 발주등록도」) — 머리줄 하늘 · 칸 테두리 · 합계 줄 크림. !important = 공용 ui-concept.css 가 덮지 않게 */
  table.g th{ background:#d9edf7 !important; color:#1f2a37 !important; font-weight:700; border:1px solid #9fb6c3 !important; padding:6px 6px; box-shadow:inset 0 -1px 0 #9fb6c3, inset 0 1px 0 #9fb6c3 !important; }
  table.g td{ border:1px solid #c9d3dc !important; }
  table.g tr.tot td, table.g tr.sum td{ background:#fcf8e3 !important; color:#1f2a37; font-weight:800; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🧃 동원홈푸드 등록 <small>— 동원홈푸드 「직송발주정보_주문내역」 엑셀을 올려 출고 · 매출로 저장한다. 사업장코드·품목코드·단가는 한 번 넣으면 다음부터 자동으로 채워진다</small></h2>

  <div class="card" id="upCard">
    <div class="hd">올리기
      <button class="btn btn-teal" id="drop" onclick="document.getElementById('fi').click()" style="margin-left:10px"
        title="엑셀(xlsx) — 여러 개를 한 번에 골라도 됩니다. 이 카드 위로 파일을 끌어다 놓아도 됩니다.&#10;읽는 칸 : 배송일자 · 납품진행상태 · 상품코드 · 상품명 · 규격 · 출고단위 · 최종주문량 · 주문번호 · 의뢰번호 · 순번 · 배송처코드 · 배송처 · 배송처주소 · 배송처연락처">📄 동원홈푸드 주문내역 엑셀</button>
      <button class="btn" onclick="mAdd()" title="엑셀 없이 줄을 만들어 직접 넣습니다. 배송일자·사업장코드·품목코드·수량·단가를 넣고 [저장]">✏️ 직접 입력</button>
      <span class="bar" style="margin-left:auto">
        <span id="pvInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
        <button class="btn" id="btnOnlyNo" onclick="onlyNoToggle()" style="display:none">미입력 줄만</button>
        <button class="btn btn-teal" id="btnSave" onclick="save()" style="display:none">💾 저장</button>
        <button class="btn btn-red" id="btnClear" onclick="pvClearAsk()" style="display:none" title="위 표에 올려 둔 줄(엑셀로 올린 줄 · 직접 입력한 줄)을 모두 비웁니다. 저장된 것은 그대로입니다">🧹 전체 비우기</button>
      </span>
    </div>
    <input type="file" id="fi" accept=".xlsx,.xls" multiple style="display:none" onchange="onFiles(this.files); this.value=''">
    <div class="tw" id="pvWrap" style="display:none;max-height:56vh">
      <table class="g"><thead><tr>
        <%-- 칸 차례는 아래 「저장된 동원홈푸드 발주」 목록과 같다 : 배송일자 · 주문번호 · 순번 · 배송처 · 사업장코드 · 동원코드 · 상품명 · 품목코드 · 규격 · 수량 · 단가 · 공급가 · 부가세 · 합계 · 상태 --%>
        <th><input type="checkbox" id="pvAll" checked onchange="pvAllChk(this)"></th><th title="✕ = 그 줄을 화면에서 뺍니다(저장된 것과는 무관)">빼기</th><th title="배송일자 = 납기일자 = 출고일자">배송일자</th><th>주문번호</th><th title="동원 엑셀의 순번 · 직접 입력 줄은 저장할 때 매깁니다">순번</th>
        <th title="동원 배송처(받는 곳) — 주소·연락처는 마우스를 올리면">배송처</th>
        <th title="우리 사업장코드 — 한 번 넣으면 같은 배송처의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">사업장코드</th>
        <th title="동원홈푸드 상품코드 — 상품코드등록 ▸ 매칭코드에 걸어 두면 품목코드가 바로 채워집니다">동원코드</th><th>상품명</th>
        <th title="우리 품목코드(상품코드) — 한 번 넣으면 같은 상품명의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">품목코드</th>
        <th title="동원 규격(EA/BOX) — 단위 칸에 저장됩니다">규격</th><th title="최종주문량(출고단위 BOX)">수량</th>
        <th title="판매가(부가세 별도 · 수량 단위 기준) — 지난 저장 → 계약단가 → 상품 판매가 차례로 채웁니다. 고칠 수 있습니다">단가</th>
        <th title="수량 × 단가">공급가</th><th title="과세 품목 10% · 면세 0">부가세</th><th title="공급가 + 부가세">합계</th><th>상태</th></tr></thead>
        <tbody id="pvBody"></tbody></table>
    </div>
    <div class="note" id="pvNote" style="display:none">· 주황 칸 = 넣어야 하는 칸 · 파랑 = 자동으로 채운 값(「자동」 = 지난 저장, 「매칭」 = 동원코드가 매칭코드로 등록됨, 「추정」 = 사업장 마스터 이름과 맞춰 본 것 — 확인 필요) · 초록 = 마스터에 있는 코드 · 노랑 = 마스터에 없는 코드(<b>저장 안 됨</b> — 사업장·상품 마스터에 먼저 등록) · 단가 배지 = 출처(지난 저장 · 계약 · 판매가) · 코드가 둘 다 든 줄만 저장된다 · 저장한 뒤에도 아래 목록에서 코드·수량·단가를 고칠 수 있다</div>
  </div>

  <div class="card">
    <div class="hd">저장된 동원홈푸드 발주 <small>— 배송일자 기준</small>
      <span class="bar" style="margin-left:auto">
        <input type="date" id="fr"> <span class="dim">~</span> <input type="date" id="to">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn" onclick="lgXlsNow()" title="위 조회 기간의 저장된 동원홈푸드 발주를 매출장부 엑셀(배송처 · 배송일자별 · 일계 · 소계 · 합계 · 공급가액 · 부가세 · 누계)로 바로 내립니다 — 동원홈푸드 송부용">📒 동원홈푸드 매출장부</button>
        <button class="btn btn-red" onclick="delSel()">🗑 선택 삭제</button>
        <span id="lsInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
      </span>
    </div>
    <div class="tw" id="lsWrap" style="max-height:50vh"><table class="g"><thead><tr>
      <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th><th>배송일자</th><th>주문번호</th><th title="동원 순번 — (주문번호, 순번)이 줄의 열쇠">순번</th><th>배송처</th><th>사업장코드</th><th>동원코드</th><th>상품명</th><th>품목코드</th><th>규격</th>
      <th title="고쳐서 Enter — 반품은 여기서 수량을 줄인다(0 = 전량 반품). 재고를 다시 맞춘다">수량 ✏️</th><th title="판매가(부가세 별도). 고쳐서 Enter">단가 ✏️</th><th title="수량 × 단가 — 매출(거래처 「동원홈푸드」)">공급가</th><th>부가세</th><th>합계</th><th>비고</th><th>올린 파일</th><th>등록</th></tr></thead>
      <tbody id="lsBody"><tr><td colspan="18" class="msg">[🔍 조회]를 누르세요.</td></tr></tbody></table></div>
  </div>
</div>
<%-- 매출장부 엑셀의 공급자 이름 --%>
<span id="compNm" style="display:none"><c:out value="${sessionScope.s_comp_nm}"/></span>
<datalist id="bizList"></datalist><datalist id="prodList"></datalist>

<script>
var CTX='${pageContext.request.contextPath}';
function n(v){ if(v==null) return 0; var x=parseFloat(String(v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return n(v).toLocaleString('ko-KR'); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }); }
function ok(m){ _alertBox(m,{icon:'✅'}); } function err(m){ _alertBox(m,{icon:'⚠️'}); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }

/* ── 기준자료 : 사업장·상품 마스터 + 매칭코드 + 계약단가 + 자동 매칭(지난 저장) ── */
var _biz={}, _prod={}, _price={}, _spec={}, _tax={}, _main={}, _ct={}, _map={ biz:{}, item:{}, dwcd:{}, price:{} }, _pv=[], _ls=[], _onlyNo=false;
/* ★거래처 「동원홈푸드」의 부가세 구분(거래처관리 VAT_GB : 포함/별도/면세) — 단가를 어떻게 가르는지가 여기서 정해진다 (2026-10-30 사용자 「토더처럼 부가세 포함으로 설정했는데 … 기준정보 따르지 않는지」 — 종전엔 「별도」로 못 박혀 있었다).
     포함 = 단가에 부가세가 들어 있다 → 합계 = 수량×단가, 공급가 = 합계÷1.1 · 별도 = 공급가 = 수량×단가, 부가세 10% 얹음 · 면세 = 부가세 0. 품목이 면세면 구분과 무관하게 0.
     매출(서버, 수량×SALE_PRICE)은 그대로다 — 토더(포함)와 같이 「포함」이면 그 값이 부가세 포함 매출이다. 못 읽으면 종전대로 「별도」 */
var _venVat='별도';
function vtLbl(){ return '부가세 '+_venVat; }
function dwSplit(cd, qty, price){ var base=Math.round(n(qty)*n(price)), free=(_venVat==='면세')||(cd && taxOf(cd)==='면세');
  if(free) return { sup:base, vat:0, tot:base };
  if(_venVat==='포함'){ var sup=Math.round(base/1.1); return { sup:sup, vat:base-sup, tot:base }; }
  var vat=Math.round(base*0.1); return { sup:base, vat:vat, tot:base+vat }; }
/* 머리글·칸 설명의 「부가세 별도」를 읽어 온 구분으로 바꾼다 */
function vtApply(){ var l=vtLbl(); document.querySelectorAll('#pvWrap th[title], #lsWrap th[title]').forEach(function(th){ th.title=th.title.replace(/부가세 (별도|포함|면세)/g, l); });
  var sup=document.querySelector('#pvWrap th[title="수량 × 단가"]'); if(sup) sup.title=(_venVat==='포함'?'합계 ÷ 1.1 (단가가 부가세 포함)':'수량 × 단가'); }
function loadMasters(){
  var p1=post('/mangr/clientList.do','findData=').then(function(r){ return r.json(); }).then(function(j){ _biz={}; var h=[]; ((j&&j.data)||[]).forEach(function(o){ if(!o.bizCd) return; _biz[String(o.bizCd)]=o.bizNm||''; h.push('<option value="'+esc((o.bizNm||'')+' ['+o.bizCd+']')+'"></option>'); }); document.getElementById('bizList').innerHTML=h.join(''); }).catch(function(){});
  var p2=post('/prod/prodList.do','').then(function(r){ return r.json(); }).then(function(j){ _prod={}; _price={}; _spec={}; _tax={}; var h=[];
      ((j&&j.data)||[]).forEach(function(o){ if(!o.prodCd) return; var c=String(o.prodCd); _prod[c]=o.prodNm||''; _price[c]=n(o.salePrice); _spec[c]=o.spec||''; _tax[c]=o.taxGb||'';
        if(o.stopYn!=='Y') h.push('<option value="'+esc((o.prodNm||'')+' ['+c+']')+'"></option>'); });
      document.getElementById('prodList').innerHTML=h.join(''); }).catch(function(){});
  /* 매칭코드(동원 상품코드를 여기 걸어 두면 품목코드로 바로 쓴다) — 주코드 표 _main 도 함께 */
  var p3=p2.then(function(){ return post('/prod/extItemList.do',''); }).then(function(r){ return r.json(); }).then(function(j){ _main={};
      ((j&&j.data)||[]).forEach(function(o){ if(!o.extItemCd) return; var c=String(o.extItemCd); if(o.prodCd && String(o.prodCd)!==c) _main[c]=String(o.prodCd);
        if(_prod[c]==null) _prod[c]=(o.extItemNm||'')+' 〔매칭코드〕'; }); }).catch(function(){});
  /* 계약단가(2026-10-27 판매 등록과 같은 규칙) — 품목코드 → 계약 줄들 */
  var p4=post('/prod/contractList.do','').then(function(r){ return r.json(); }).then(function(j){ var m={}; ((j&&j.data)||[]).forEach(function(c){ var cd=String(c.prodCd||''); if(cd) (m[cd]=m[cd]||[]).push(c); }); _ct=m; }).catch(function(){});
  var p6=post('/vendor/selectVendorMst.do','').then(function(r){ return r.json(); }).then(function(j){ var v=((j&&j.data)||[]).filter(function(o){ return String(o.vendorCd||'')==='DONGWON'; })[0]; _venVat=(v&&v.vatGb)||'별도'; vtApply(); }).catch(function(){});
  var p5=post('/shipout/dongwonPoMap.do','').then(function(r){ return r.json(); }).then(function(j){ _map={ biz:(j&&j.biz)||{}, item:(j&&j.item)||{}, dwcd:(j&&j.dwcd)||{}, price:(j&&j.price)||{} }; }).catch(function(){});
  return Promise.all([p1,p3,p4,p5,p6]).then(function(){ if(_pv.length){ autoFill(); pvRender(); } if(_ls.length) lsRender(); });
}
function prodNmOf(cd){ return String(_prod[cd]||'').replace(' 〔매칭코드〕',''); }
function mainOf(cd){ cd=String(cd||''); return (_main[cd] && _prod[_main[cd]]!=null) ? _main[cd] : cd; }
function specOf(cd){ cd=String(cd||''); return _spec[cd]||_spec[mainOf(cd)]||''; }
function taxOf(cd){ cd=String(cd||''); return _tax[cd]||_tax[mainOf(cd)]||'과세'; }
function vatOf(cd, amt){ return taxOf(cd)==='면세' ? 0 : Math.round(n(amt)*0.1); }
/* 계약단가 — 배송일자 이전에 시작한 계약 중 가장 늦은 것(판매 등록 saCtOf 와 같다 · 종료일은 안 본다) */
function ctOf(cd, dlv){ var l=_ct[mainOf(cd)]||_ct[String(cd||'')]; if(!l||!l.length) return null;
  var d=String(dlv||ymd(new Date())).replace(/-/g,''), best=null;
  l.forEach(function(c){ var fr=String(c.frDt||'').replace(/-/g,''); if(fr && fr<=d && n(c.contractPrice)>0 && (!best || fr>String(best.frDt||'').replace(/-/g,''))) best=c; });
  return best; }
/* ★단가 차례 = 지난 동원 저장 단가 → 계약단가 → 상품 판매가(매칭코드면 주코드) → 0. 돌려주는 값 = {p, src} */
function priceOf(cd, dlv){ cd=String(cd||''); if(!cd) return { p:0, src:'' };
  var m=mainOf(cd), lp=n(_map.price[cd]||_map.price[m]); if(lp>0) return { p:lp, src:'지난 저장' };
  var c=ctOf(cd, dlv); if(c) return { p:n(c.contractPrice), src:'계약' };
  if(_price[cd]>0) return { p:_price[cd], src:'판매가' }; if(_price[m]>0) return { p:_price[m], src:'판매가' };
  return { p:0, src:'' }; }

/* ── 엑셀 읽기 — 머리 1행 ── */
var HDR={ dlvDt:['배송일자'], status:['납품진행상태','진행상태','상태'], createDttm:['생성일시'], dwItemCd:['상품코드'], itemNm:['상품명'], spec:['규격'], unit:['출고단위','포장단위'],
          qty:['최종주문량'], qty2:['공급처수량'], qty3:['원주문량'], ordNo:['주문번호'], reqNo:['의뢰번호'], no:['순번'], bizCode:['배송처코드'], bizNm:['배송처'], rcvAddr:['배송처주소'], rcvTel:['배송처연락처'], memo:['주문요청사항'] };
function cellTxt(v){ if(v==null) return ''; if(Object.prototype.toString.call(v)==='[object Date]') return ymd(v)+' '+('0'+v.getHours()).slice(-2)+':'+('0'+v.getMinutes()).slice(-2)+':'+('0'+v.getSeconds()).slice(-2); return String(v).trim(); }
function parseWb(wb, fileNm){
  var out=[];
  wb.SheetNames.forEach(function(sn){
    var aoa=XLSX.utils.sheet_to_json(wb.Sheets[sn],{ header:1, raw:true, defval:'' }), hr=-1, col={};
    for(var r=0;r<Math.min(aoa.length,30);r++){ var row=aoa[r].map(cellTxt);
      if(row.indexOf('배송처')>=0 && row.indexOf('상품명')>=0 && row.indexOf('주문번호')>=0){ hr=r; for(var k in HDR){ col[k]=-1; HDR[k].forEach(function(nm){ if(col[k]<0) col[k]=row.indexOf(nm); }); } break; } }
    if(hr<0) return;
    for(var i=hr+1;i<aoa.length;i++){ var a=aoa[i], g=function(k){ return col[k]>=0? cellTxt(a[col[k]]) : ''; };
      var bizNm=g('bizNm'), itemNm=g('itemNm'); if(!bizNm && !itemNm) continue;
      var st=g('status'), q=n(g('qty'))||n(g('qty2'))||n(g('qty3'));
      out.push({ no:g('no'), seq:out.length, chk: !/취소|반려|반품/.test(st), fileNm:fileNm, bizNm:bizNm, bizCode:g('bizCode'), rcvAddr:g('rcvAddr'), rcvTel:g('rcvTel'),
        ordNo:g('ordNo'), reqNo:g('reqNo'), createDttm:g('createDttm'), dlvDt:d10(g('dlvDt')), dwItemCd:g('dwItemCd'), itemNm:itemNm, spec:g('spec'), unit:g('unit'),
        price:0, priceSrc:'', priceEdited:false, qty:q, status:st, memo:g('memo'), bizCd:'', itemCd:'', bizAuto:false, itemAuto:false, itemHow:'' });
    }
  });
  return out;
}
function onFiles(files){
  var list=Array.prototype.slice.call(files||[]); if(!list.length) return;
  var jobs=list.map(function(f){ return new Promise(function(res){ var rd=new FileReader(); rd.onload=function(e){ try{ var wb=XLSX.read(new Uint8Array(e.target.result),{ type:'array', cellDates:true }); res({ nm:f.name, rows:parseWb(wb,f.name) }); }catch(x){ res({ nm:f.name, rows:[], err:x.message }); } }; rd.readAsArrayBuffer(f); }); });
  Promise.all(jobs).then(function(rs){
    var bad=[], add=[]; rs.forEach(function(r){ if(!r.rows.length) bad.push(esc(r.nm)+(r.err?' — '+esc(r.err):' — 머리 줄(배송처·상품명·주문번호)을 못 찾았습니다')); else add=add.concat(r.rows); });
    /* 같은 (주문번호, 순번, 상품명)은 나중 것으로 */
    var seen={}; _pv.concat(add).forEach(function(x){ seen[x.manual ? ('(직접)'+x.mid) : (x.ordNo+'|'+x.no+'|'+x.itemNm)]=x; }); _pv=Object.keys(seen).map(function(k){ return seen[k]; });
    _pv.sort(function(a,b){ return String(a.fileNm||'').localeCompare(String(b.fileNm||'')) || (a.seq-b.seq); });
    autoFill(); pvRender();
    if(bad.length) err('읽지 못한 파일<br><span style="font-size:13px">'+bad.join('<br>')+'</span>');
  });
}
/* 이름 다듬기 — 브랜드 말(샐러링·테그42 …)·빈칸·괄호·끝의 「본점/점」을 떼고 견준다 : 동원 「샐러링 성수본점(신)」 ↔ 마스터 「성수 샐러링」 */
var BRANDS=['샐러링','테그42','테그','셀러링'];
function normNm(s){ s=String(s||''); BRANDS.forEach(function(b){ s=s.split(b).join(''); }); return s.replace(/\([^)]*\)/g,'').replace(/\s+/g,'').replace(/본점$/,'').replace(/점$/,'').toLowerCase(); }
function guessBiz(x){
  var key=normNm(x.bizNm); if(!key) return '';
  var hit=[]; for(var cd in _biz){ if(normNm(_biz[cd])===key) hit.push(cd); }
  return hit.length===1 ? hit[0] : '';   /* 하나로 떨어질 때만 */
}
function autoFill(){ _pv.forEach(function(x){
  if(!x.bizCd && _map.biz[x.bizNm]){ x.bizCd=_map.biz[x.bizNm]; x.bizAuto=true; x.bizGuess=false; }
  if(!x.bizCd){ var g=guessBiz(x); if(g){ x.bizCd=g; x.bizAuto=true; x.bizGuess=true; } }
  /* 품목 : 동원코드 → 지난 저장(코드) → 지난 저장(상품명) → 동원코드가 매칭코드(또는 우리 코드)로 등록돼 있으면 그대로 */
  if(!x.itemCd && x.dwItemCd && _map.dwcd[x.dwItemCd]){ x.itemCd=_map.dwcd[x.dwItemCd]; x.itemAuto=true; x.itemHow='자동'; }
  if(!x.itemCd && _map.item[x.itemNm]){ x.itemCd=_map.item[x.itemNm]; x.itemAuto=true; x.itemHow='자동'; }
  if(!x.itemCd && x.dwItemCd && _prod[x.dwItemCd]!=null){ x.itemCd=x.dwItemCd; x.itemAuto=true; x.itemHow='매칭'; }
  priceFill(x); }); }
/* 단가 — 사람이 고친 값은 안 건드린다. 품목코드가 바뀌면 다시 채운다 */
function priceFill(x){ if(x.priceEdited || !x.itemCd) return; var r=priceOf(x.itemCd, x.dlvDt); x.price=r.p; x.priceSrc=r.src; }
function cdCls(cd, mst, auto){ if(!cd) return ''; return mst[cd]!=null ? (auto?'auto':'ok') : 'bad'; }
function amtOf(x){ return dwSplit(x.itemCd, x.qty, x.price); }   /* 거래처 부가세 구분(_venVat)에 따라 가른다 (2026-10-30) */
function pvRender(){
  var has=_pv.length>0;
  ['pvWrap','pvNote'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  var pg=document.getElementById('pvWrap').nextElementSibling; if(pg && pg.classList.contains('kgg')) pg.style.display=has?'':'none';
  ['btnSave','btnClear','btnOnlyNo'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  document.getElementById('btnOnlyNo').textContent=_onlyNo?'전체 줄 보기':'미입력 줄만';
  var tb=document.getElementById('pvBody');
  tb.innerHTML=_pv.map(function(x,i){
    if(_onlyNo && x.bizCd && x.itemCd) return '';
    if(x.manual) return mRow(x, i);
    var bn=_biz[x.bizCd], pn=_prod[x.itemCd], a=amtOf(x);
    return '<tr class="'+(x.chk?'':'off')+'"><td><input type="checkbox" '+(x.chk?'checked':'')+' onchange="_pv['+i+'].chk=this.checked; pvRender()"></td><td><button class="btn" style="height:26px;padding:0 7px;color:#c0392b" title="이 줄을 화면에서 뺍니다(저장된 것과는 무관)" onclick="mDel('+i+')">✕</button></td><td>'+esc(x.dlvDt)+'</td><td>'+esc(x.ordNo)+'</td><td><b>'+esc(x.no!==''&&x.no!=null?x.no:(i+1))+'</b></td>'
      +'<td class="l" title="'+esc((x.bizCode?'배송처코드 '+x.bizCode+'\n':'')+(x.rcvAddr||'')+(x.rcvTel?'\n'+x.rcvTel:''))+'">'+esc(x.bizNm)+(x.rcvAddr?'<span class="sub">'+esc(x.rcvAddr)+'</span>':'')+'</td>'
      +'<td class="l">'+(x.bizCd?'<span class="sub nmf'+(bn==null?' warn':'')+'">'+(x.bizAuto?'<span class="bd auto" title="'+(x.bizGuess?'사업장 마스터의 이름과 맞춰 본 추정 — 맞는지 확인하세요':'지난 저장에서 가져온 값')+'">'+(x.bizGuess?'추정':'자동')+'</span> ':'')+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span>':'')+'<input type="text" list="bizList" class="'+cdCls(x.bizCd,_biz,x.bizAuto)+'" value="'+esc(x.bizCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'biz\',this.value)"></td>'
      +'<td>'+esc(x.dwItemCd)+'</td><td class="l" title="'+esc(x.itemNm)+'" style="max-width:300px;overflow:hidden;text-overflow:ellipsis">'+esc(x.itemNm)+'</td>'
      +'<td class="l">'+(x.itemCd?'<span class="sub nmf'+(pn==null?' warn':'')+'">'+(x.itemAuto?'<span class="bd auto" title="'+(x.itemHow==='매칭'?'동원코드가 매칭코드(또는 우리 코드)로 등록돼 있어 그대로 씁니다':'지난 저장에서 가져온 값')+'">'+esc(x.itemHow||'자동')+'</span> ':'')+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span>':'')+'<input type="text" list="prodList" class="'+cdCls(x.itemCd,_prod,x.itemAuto)+'" value="'+esc(x.itemCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'item\',this.value)"></td>'
      +'<td>'+esc(x.spec||x.unit)+'</td><td class="r"><b>'+fmt(x.qty)+'</b></td>'
      +'<td class="r">'+(x.priceSrc&&!x.priceEdited?'<span class="bd ps" title="단가 출처">'+esc(x.priceSrc)+'</span> ':'')+'<input type="text" class="num'+(n(x.price)>0?'':' bad')+'" style="width:84px" value="'+esc(x.price?String(x.price):'')+'" title="판매가('+vtLbl()+' · 수량 단위 기준) — 고치면 그 값으로" onchange="pvPrice('+i+',this)"></td>'
      +'<td class="r"><b>'+fmt(a.sup)+'</b></td><td class="r">'+fmt(a.vat)+'</td><td class="r"><b>'+fmt(a.tot)+'</b></td>'
      +'<td><span class="bd '+(/취소|반려|반품/.test(x.status)?'cx':'st')+'">'+esc(x.status)+'</span></td></tr>';
  }).join('');
  pvInfoUpd();
}
function pvPrice(i, el){ var x=_pv[i]; if(!x) return; var v=String(el.value||'').replace(/,/g,'').trim();
  if(v!=='' && !(/^\d+(\.\d+)?$/.test(v))){ err('단가는 숫자로 넣으세요('+vtLbl()+').'); pvRender(); return; }
  x.price=v===''?0:n(v); x.priceEdited=true; x.priceSrc='';
  /* 같은 품목코드의 다른 줄도 — 단가는 품목에 붙는 값(사람이 따로 고친 줄은 둔다) */
  _pv.forEach(function(y){ if(y!==x && !y.manual && y.itemCd && y.itemCd===x.itemCd && !y.priceEdited){ y.price=x.price; y.priceSrc='같이'; } });
  pvRender(); }
function pvInfoUpd(){
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(function(x){ return x.bizCd&&x.itemCd&&x.dlvDt&&x.qty; });
  var unk=rdy.filter(function(x){ return _biz[x.bizCd]==null || _prod[x.itemCd]==null; }).length;
  var sup=0, vat=0; rdy.forEach(function(x){ var a=amtOf(x); sup+=a.sup; vat+=a.vat; });
  document.getElementById('pvInfo').textContent='올린 줄 '+_pv.length+' · 선택 '+sel.length+' · 저장 가능 '+(rdy.length-unk)+(sel.length-rdy.length?' · 코드 빈 줄 '+(sel.length-rdy.length):'')+(unk?' · 마스터에 없는 코드 '+unk+'줄(저장 막힘)':'')+' · 공급가 '+fmt(sup)+' · 부가세 '+fmt(vat)+' · 합계 '+fmt(sup+vat);
  document.getElementById('pvAll').checked=_pv.every(function(x){ return x.chk; });
}
function pickCd(v, mst){
  v=String(v||'').trim(); var m=/\[([^\[\]]+)\]\s*$/.exec(v); if(m) return m[1].trim();
  if(mst[v]!=null) return v;
  var hit=[]; for(var cd in mst){ if(String(mst[cd]).trim()===v) hit.push(cd); } return hit.length===1? hit[0] : v;
}
/* 코드 한 번 넣으면 같은 이름(배송처 / 상품명 또는 동원코드)의 빈 칸(또는 자동으로 채워졌던 칸)에 같이 */
function setCd(i, kind, v){
  v=pickCd(v, kind==='biz'?_biz:_prod); var x=_pv[i]; if(!x) return;
  if(kind==='biz'){ var nm=x.bizNm; _pv.forEach(function(y){ if(y===x || (nm && !y.manual && y.bizNm===nm && (!y.bizCd || y.bizAuto))){ y.bizCd=v; y.bizAuto=false; y.bizGuess=false; } }); }
  else { var inm=x.itemNm, dc=x.dwItemCd; _pv.forEach(function(y){ if(y===x || (!y.manual && ((inm && y.itemNm===inm) || (dc && y.dwItemCd===dc)) && (!y.itemCd || y.itemAuto))){ y.itemCd=v; y.itemAuto=false; y.itemHow=''; if(!y.priceEdited) priceFill(y); } }); }
  if(x.manual) mFill(x, kind);
  pvRender();
}
function pvAllChk(el){ _pv.forEach(function(x){ x.chk=el.checked; }); pvRender(); }
function onlyNoToggle(){ _onlyNo=!_onlyNo; pvRender(); }
function pvClear(){ _pv=[]; _onlyNo=false; pvRender(); }
function pvClearAsk(){
  if(!_pv.length){ if(window._toast) _toast('비울 줄이 없습니다.','info'); return; }
  var man=_pv.filter(function(x){ return x.manual; }).length, xl=_pv.length-man;
  _confirmBox({ icon:'🧹', okText:'비우기',
    msg:'위 표의 <b>'+_pv.length+'</b>줄을 모두 비웁니다.<br><span style="font-size:13px;color:#3d4d5c">'
      +(xl?'엑셀로 올린 줄 '+xl+'개':'')+(xl&&man?' · ':'')+(man?'직접 입력한 줄 '+man+'개':'')+' — 아직 저장하지 않은 내용은 사라집니다. 저장된 동원홈푸드 발주는 그대로입니다.</span>',
    onOk:function(){ pvClear(); }, onCancel:function(){} });
}

function save(){
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(function(x){ return x.bizCd&&x.itemCd&&x.dlvDt&&x.qty; }), miss=sel.length-rdy.length;
  if(!rdy.length){ err('저장할 줄이 없습니다 — 사업장코드·품목코드를 넣으세요.'); return; }
  var unk=rdy.filter(function(x){ return _biz[x.bizCd]==null || _prod[x.itemCd]==null; });
  if(unk.length){
    var ub={}, ui={}; unk.forEach(function(x){ if(_biz[x.bizCd]==null) ub[x.bizCd]=1; if(_prod[x.itemCd]==null) ui[x.itemCd]=1; });
    err('마스터에 없는 코드가 든 줄이 <b>'+unk.length+'</b>개 있어 저장하지 않았습니다.<br><span style="font-size:13px">'
      +(Object.keys(ub).length?'사업장코드 : <b>'+esc(Object.keys(ub).join(', '))+'</b> — 거래처관리(사업장)에 먼저 등록<br>':'')
      +(Object.keys(ui).length?'품목코드 : <b>'+esc(Object.keys(ui).join(', '))+'</b> — 상품코드등록·매칭코드에 먼저 등록<br>':'')
      +'노란 칸을 고치거나 그 줄의 체크를 빼고 다시 저장하세요.</span>');
    return;
  }
  mPrep(rdy);
  var noPrice=rdy.filter(function(x){ return !(n(x.price)>0); }).length, sup=0, vat=0; rdy.forEach(function(x){ var a=amtOf(x); sup+=a.sup; vat+=a.vat; });
  _confirmBox({ icon:'💾', okText:'저장',
    msg:'동원홈푸드 발주 <b>'+rdy.length+'</b>줄을 <b>출고 · 매출</b>로 저장합니다. 공급가 <b>'+fmt(sup)+'</b>원 · 부가세 '+fmt(vat)+'원 · 합계 '+fmt(sup+vat)+'원(거래처 「동원홈푸드」).'
      +(noPrice?'<br><span style="color:#c0392b;font-size:13px">단가가 빈 줄 '+noPrice+'개 — 매출 0원으로 들어갑니다(저장 뒤 목록에서 고칠 수 있습니다).</span>':'')
      +(miss?'<br><span style="color:#b45309;font-size:13px">코드가 빈 '+miss+'줄은 저장하지 않습니다(화면에 남습니다).</span>':'')
      +'<br><span style="font-size:13px;color:#3d4d5c">같은 주문번호·순번·상품명이 이미 있으면 새것으로 대체합니다. 그 배송일자의 재고를 다시 맞춥니다.</span>',
    onOk:function(){
      var b=document.getElementById('btnSave'); b.disabled=true;
      post('/shipout/dongwonPoSave.do',{ rows:rdy.map(function(x){ return { no:x.no, dlvDt:x.dlvDt, ordNo:x.ordNo, reqNo:x.reqNo, bizCode:x.bizCode, bizCd:x.bizCd, bizNm:x.bizNm, dwItemCd:x.dwItemCd, itemCd:x.itemCd, itemNm:x.itemNm,
          spec:x.spec, unit:(x.spec||x.unit), qty:x.qty, price:(n(x.price)>0?x.price:''), rcvAddr:x.rcvAddr, rcvTel:x.rcvTel, status:x.status, createDttm:x.createDttm, fileNm:x.fileNm }; }) },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){
          var warn=/\|STOCKFAIL:(.*)$/.exec(t), cnt=parseInt(t,10)||rdy.length;
          rdy.forEach(function(x){ _map.biz[x.bizNm]=x.bizCd; _map.item[x.itemNm]=x.itemCd; if(x.dwItemCd) _map.dwcd[x.dwItemCd]=x.itemCd; if(n(x.price)>0) _map.price[x.itemCd]=String(x.price); });
          _pv=_pv.filter(function(x){ return rdy.indexOf(x)<0; }); pvRender();
          var ds=rdy.map(function(x){ return x.dlvDt; }).sort(); document.getElementById('fr').value=ds[0]; document.getElementById('to').value=ds[ds.length-1]; load();
          ok('동원홈푸드 발주 <b>'+cnt+'</b>줄을 저장했습니다.'+(_pv.length?'<br><span style="font-size:13px">코드가 빈 '+_pv.length+'줄이 화면에 남아 있습니다.</span>':'')+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':''));
        })
        .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
        .then(function(){ b.disabled=false; });
    }, onCancel:function(){} });
}

/* ── 저장된 목록 ── */
function load(){
  document.getElementById('lsBody').innerHTML='<tr><td colspan="18" class="msg">조회 중…</td></tr>';
  post('/shipout/dongwonPoList.do','frDt='+encodeURIComponent(document.getElementById('fr').value)+'&toDt='+encodeURIComponent(document.getElementById('to').value))
    .then(function(r){ return r.json(); }).then(function(j){ _ls=(j&&j.data)||[]; lsRender(); })
    .catch(function(e){ document.getElementById('lsBody').innerHTML='<tr><td colspan="18" class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsAmt(x){ return dwSplit(x.itemCd, x.qty, x.salePrice); }
function lsRender(){
  var tb=document.getElementById('lsBody'); document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="18" class="msg">저장된 동원홈푸드 발주가 없습니다.</td></tr>'; document.getElementById('lsInfo').textContent=''; return; }
  var q=0, sup=0, vat=0;
  tb.innerHTML=_ls.map(function(x,i){ var a=lsAmt(x); q+=n(x.qty); sup+=a.sup; vat+=a.vat;
    var bn=_biz[x.bizCd], pn=_prod[x.itemCd];
    return '<tr><td><input type="checkbox" class="lchk" data-i="'+i+'"></td><td>'+d10(x.dlvDt)+'</td><td>'+esc(x.ordNo)+(x.reqNo?'<span class="sub" title="의뢰번호">'+esc(x.reqNo)+'</span>':'')+'</td><td><b>'+esc(x.lineNo)+'</b></td>'
      +'<td class="l" title="'+esc((x.rcvAddr||'')+(x.rcvTel?'\n'+x.rcvTel:''))+'">'+esc(x.bizNm)+(x.rcvAddr?'<span class="sub">'+esc(x.rcvAddr)+'</span>':'')+'</td>'
      +'<td class="l"><span class="sub nmf'+(bn==null?' warn':'')+'">'+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span><input type="text" list="bizList" class="'+(bn==null?'bad':'ok')+'" value="'+esc(x.bizCd)+'" title="고르거나 쳐서 바꾸면 같은 배송처의 저장된 줄이 모두 바뀝니다" onchange="lsCd('+i+',\'biz\',this)"></td>'
      +'<td>'+esc(x.dwItemCd)+'</td><td class="l" title="'+esc(x.itemNm)+'" style="max-width:300px;overflow:hidden;text-overflow:ellipsis">'+esc(x.itemNm)+'</td>'
      +'<td class="l"><span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span><input type="text" list="prodList" class="'+(pn==null?'bad':'ok')+'" value="'+esc(x.itemCd)+'" title="고르거나 쳐서 바꾸면 같은 상품명의 저장된 줄이 모두 바뀌고 재고도 다시 맞춥니다" onchange="lsCd('+i+',\'item\',this)">'+(x.prodCd&&x.prodCd!==x.itemCd?'<span class="sub">주코드 '+esc(x.prodCd)+'</span>':'')+'</td><td>'+esc(x.unit)+'</td>'
      +'<td class="r"><input type="text" class="num'+(n(x.qty)===0?' bad':'')+'" value="'+esc(fmtIn(x.qty))+'" data-v="'+esc(fmtIn(x.qty))+'" title="반품이면 줄여서 Enter — 0 = 전량 반품. 그 날 재고를 다시 맞춘다" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsRow('+i+',this,\'qty\')"></td>'
      +'<td class="r"><input type="text" class="num'+(x.salePrice==null||x.salePrice===''?' bad':'')+'" value="'+esc(fmtIn(x.salePrice))+'" data-v="'+esc(fmtIn(x.salePrice))+'" title="판매가('+vtLbl()+'). 비면 매출 0" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsRow('+i+',this,\'price\')"></td>'
      +'<td class="r"><b>'+fmt(a.sup)+'</b></td><td class="r">'+fmt(a.vat)+'</td><td class="r"><b>'+fmt(a.tot)+'</b></td>'
      +'<td class="l dim" style="max-width:260px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.remark)+'">'+esc(x.remark)+'</td><td class="l dim" style="max-width:200px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.srcFile)+'">'+esc(x.srcFile)+'</td><td class="dim">'+esc(String(x.uploadDttm||'').slice(0,16))+'<br>'+esc(x.regUser)+'</td></tr>'; }).join('');
  document.getElementById('lsInfo').textContent=_ls.length+'줄 · 수량 '+fmt(q)+' · 공급가 '+fmt(sup)+' · 부가세 '+fmt(vat)+' · 합계 '+fmt(sup+vat)+'원';
}
function fmtIn(v){ if(v==null||v==='') return ''; var x=n(v); return String(Math.round(x*100)/100); }
/* 저장된 한 줄의 수량·판매가 고치기 — 열쇠 = (주문번호, 순번, 상품명). 서버가 비고에 「수정 옛값→새값」을 남기고 그 날 재고를 다시 맞춘다 */
function lsRow(i, el, fld){
  var x=_ls[i]; if(!x) return;
  var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/,/g,'').trim();
  if(v===old) return;
  if(fld==='qty' && !/^\d+$/.test(v)){ el.value=old; err('수량은 0 이상의 정수로 넣으세요(0 = 전량 반품).'); return; }
  if(fld==='price' && v!=='' && !(/^\d+(\.\d+)?$/.test(v))){ el.value=old; err('판매가는 숫자로 넣으세요('+vtLbl()+').'); return; }
  var qty = fld==='qty' ? v : fmtIn(x.qty), price = fld==='price' ? v : fmtIn(x.salePrice);
  var what = fld==='qty' ? ('수량 <b>'+esc(old||'0')+'</b> → <b>'+esc(v)+'</b>'+(n(v)<n(old)?' <span style="color:#b45309">(반품 '+fmt(n(old)-n(v))+')</span>':'')) : ('판매가 <b>'+esc(old||'없음')+'</b> → <b>'+esc(v||'없음')+'</b>');
  _confirmBox({ icon:'✏️', okText:'고치기',
    msg:esc(x.bizNm)+' · '+esc(x.itemNm)+'<br>'+what
      +'<br><span style="font-size:13px;color:#3d4d5c">'+(_venVat==='포함'?'합계':'공급가')+' '+fmt(n(qty)*n(price))+'원('+vtLbl()+')'+(fld==='qty'?' · 그 날('+d10(x.dlvDt)+') 재고를 다시 맞춥니다':'')+'. 비고에 수정 기록이 남습니다.</span>',
    onOk:function(){
      post('/shipout/dongwonPoRow.do',{ ordNo:x.ordNo, lineNo:x.lineNo, itemNm:x.itemNm, qty:qty, price:price },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); load();
          if(warn) err('고쳤지만 재고 반영에 실패했습니다 — '+esc(warn[1])+'<br><span style="font-size:13px">[출고반영 재집계]를 눌러 주세요.</span>'); else if(window._toast) _toast('고쳤습니다','ok'); })
        .catch(function(e){ el.value=old; err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
    }, onCancel:function(){ el.value=old; } });
}
/* 저장된 줄의 코드 고치기 — 이름(배송처 / 상품명) 단위로 저장된 줄을 모두 바꾼다(조회 기간 밖 포함). 토더와 같은 규칙 */
function lsCd(i, kind, el){
  var x=_ls[i]; if(!x) return;
  var mst=kind==='biz'?_biz:_prod, old=kind==='biz'?x.bizCd:x.itemCd, nm=kind==='biz'?x.bizNm:x.itemNm, cd=pickCd(el.value, mst);
  var lab=kind==='biz'?'사업장코드':'품목코드', nmLab=kind==='biz'?'배송처':'상품명';
  if(!cd || cd===old){ el.value=old; return; }
  if(mst[cd]==null){ el.value=old; err(lab+' <b>'+esc(cd)+'</b> 는 마스터에 없습니다 — '+(kind==='biz'?'거래처관리(사업장)':'상품코드등록·매칭코드')+'에 먼저 등록하세요.'); return; }
  var same=_ls.filter(function(y){ return (kind==='biz'?y.bizNm:y.itemNm)===nm; }).length;
  _confirmBox({ icon:'✏️', okText:'고치기',
    msg:nmLab+' <b>'+esc(nm)+'</b> 의 '+lab+'를<br><b>'+esc(old)+'</b> → <b>'+esc(cd)+'</b> ('+esc(mst[cd])+') 로 고칩니다.'
      +'<br><span style="font-size:13px;color:#3d4d5c">같은 '+nmLab+'으로 저장된 줄이 모두 바뀝니다(지금 목록 '+same+'줄 · 조회 기간 밖 포함).'
      +(kind==='item'?' 그 날짜들의 재고를 다시 맞춥니다.':'')+' 다음 업로드의 자동 매칭도 새 코드로 채워집니다.</span>',
    onOk:function(){
      post('/shipout/dongwonPoCode.do',{ kind:kind, nm:nm, cd:cd },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); _map[kind][nm]=cd; load();
          ok(lab+'를 고쳤습니다 — <b>'+(parseInt(t,10)||0)+'</b>줄.'+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':'')); })
        .catch(function(e){ el.value=old; err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
    }, onCancel:function(){ el.value=old; } });
}
function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function delSel(){
  var keys=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) keys.push({ dlvDt:x.dlvDt, ordNo:x.ordNo, lineNo:x.lineNo, itemNm:x.itemNm }); });
  if(!keys.length){ err('삭제할 줄을 고르세요.'); return; }
  _confirmBox({ icon:'🗑', okText:'삭제', msg:'고른 동원홈푸드 발주 <b>'+keys.length+'</b>줄을 삭제합니다.<br><span style="font-size:13px;color:#3d4d5c">출고·매출 자료에서 빠지고 재고도 다시 맞춥니다. (자동 매칭용 이름 → 코드 짝은 남습니다)</span>',
    onOk:function(){ post('/shipout/dongwonPoDelete.do',{ keys:keys },true).then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); load(); ok((parseInt(t,10)||0)+'줄을 삭제했습니다.'+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':'')); })
      .catch(function(e){ err('삭제하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }, onCancel:function(){} });
}

/* ── 매출장부 (동원홈푸드 송부용) ──
   저장된 동원홈푸드 발주를 배송처별 → 배송일자별로 묶어 엑셀로 낸다.
     · 칸 : 배송처 · 배송일자 · 주문번호 · 순번 · 동원코드 · 상품명 · 규격 · 수량 · 단가 · 공급가액 · 부가세 · 합계 · 누계 · 비고
     · 배송처 = 사업장 마스터 이름(없으면 동원 배송처) — 배송처의 첫 줄에만 적는다. 상품명 = 동원 상품명(동원이 보는 장부라 그쪽 이름), 규격 = 동원 규격(단위 칸).
     · 공급가액·부가세 = 거래처 부가세 구분대로(dwSplit : 포함이면 합계 = 수량×단가, 공급가액 = ÷1.1 / 별도면 공급가액 = 수량×단가 + 10%) · 면세 품목 0 · 합계 = 공급가액 + 부가세 · 누계 = 처음부터 그 줄까지 합계 누계.
     · 날짜가 바뀔 때 「일계」(연두), 배송처가 바뀔 때 「소계」(보라), 맨 끝에 「합계」(크림). 수량 0 줄(전량 반품)은 뺀다.
     · 기간 = 아래 목록의 조회 기간. 자료는 그때 새로 읽는다(/shipout/dongwonPoList.do) — 서버는 그대로다. 미리보기 창은 없다(바로 엑셀). */
var _lg=null;
function lgBuild(rows){
  var list=(rows||[]).filter(function(x){ return n(x.qty)>0; }).map(function(x){ var a=lsAmt(x);
    return { biz:String(_biz[x.bizCd]||x.bizNm||''), bizCd:String(x.bizCd||''), dt:d10(x.dlvDt), no:String(x.ordNo||''), ln:String(x.lineNo||''), dw:String(x.dwItemCd||''),
      nm:String(x.itemNm||''), spec:String(x.unit||''), qty:n(x.qty), price:n(x.salePrice), sup:a.sup, vat:a.vat, tot:a.tot, rmk:(x.remark||'').indexOf('수정')>=0?'수정 있음':'' }; });
  var cmp=function(a,b){ return String(a).localeCompare(String(b),'ko',{ numeric:true }); };
  list.sort(function(a,b){ return cmp(a.bizCd,b.bizCd) || cmp(a.biz,b.biz) || cmp(a.dt,b.dt) || cmp(a.no,b.no) || cmp(a.ln,b.ln); });
  var out=[], run=0, i=0, bizCnt=0, T={ sup:0, vat:0, tot:0, qty:0 };
  while(i<list.length){
    var bk=list[i].bizCd+'|'+list[i].biz, sub={ sup:0, vat:0, tot:0 }, first=true; bizCnt++;
    while(i<list.length && (list[i].bizCd+'|'+list[i].biz)===bk){
      var dt=list[i].dt, day={ sup:0, vat:0, tot:0 };
      while(i<list.length && (list[i].bizCd+'|'+list[i].biz)===bk && list[i].dt===dt){
        var r=list[i]; run+=r.tot; day.sup+=r.sup; day.vat+=r.vat; day.tot+=r.tot; T.qty+=r.qty;
        out.push({ k:'row', biz:(first?r.biz:''), dt:r.dt, no:r.no, ln:r.ln, dw:r.dw, nm:r.nm, spec:r.spec, qty:r.qty, price:r.price, sup:r.sup, vat:r.vat, tot:r.tot, run:run, rmk:r.rmk });
        first=false; i++; }
      out.push({ k:'day', sup:day.sup, vat:day.vat, tot:day.tot }); sub.sup+=day.sup; sub.vat+=day.vat; sub.tot+=day.tot; }
    out.push({ k:'sub', sup:sub.sup, vat:sub.vat, tot:sub.tot }); T.sup+=sub.sup; T.vat+=sub.vat; T.tot+=sub.tot; }
  if(list.length) out.push({ k:'tot', sup:T.sup, vat:T.vat, tot:T.tot });
  return { lines:out, cnt:list.length, bizCnt:bizCnt, sup:T.sup, vat:T.vat, tot:T.tot, qty:T.qty };
}
/* 단추 한 번 = 목록의 조회 기간으로 새로 읽어 바로 엑셀 (2026-10-29 「이 내용 필요 없이 엑셀 바로 나오게」) */
function lgXlsNow(){
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  if(!fr || !to){ err('조회 기간(배송일자)을 넣으세요.'); return; }
  if(fr>to){ err('시작일이 끝일보다 늦습니다.'); return; }
  if(window._toast) _toast('매출장부를 만드는 중…','info');
  post('/shipout/dongwonPoList.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to))
    .then(function(r){ return r.json(); })
    .then(function(j){ _lg=lgBuild((j&&j.data)||[]); _lg.fr=fr; _lg.to=to;
      if(!_lg.lines.length){ err('이 기간('+fr+' ~ '+to+')에 저장된 동원홈푸드 발주가 없습니다.'); return; }
      lgXls(); })
    .catch(function(e){ _lg=null; err('매출장부를 만들지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}
/* 엑셀 — 제목(A1:N2) · 조회기간/출력일자 줄 · 머리글 · 본문(일계·소계·합계 색) · 토더 마감장부와 같은 글꼴·테두리 */
function lgXls(){
  if(!window.XLSX){ err('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  if(!_lg || !_lg.lines.length){ err('엑셀로 낼 자료가 없습니다.'); return; }
  var today=ymd(new Date()), comp=String((document.getElementById('compNm')||{}).textContent||'').trim(), NC=14;
  var H=['배송처','배송일자','주문번호','순번','동원코드','상품명','규격','수량','단가','공급가액','부가세','합계','누계','비고'], E=function(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; };
  var aoa=[ ['[동원홈푸드] 매출장부'].concat(E(NC-1)), E(NC),
            ['조회기간 : '+_lg.fr+' ~ '+_lg.to].concat(E(NC-2)).concat(['출력일자 : '+today]),
            ['공급자 : '+comp,'','','','','','','','','','','',vtLbl(),''], H ];   /* 거래처 부가세 구분 그대로 (2026-10-30) */
  var kinds=['t','t','p','p','h'];
  var serial=function(d){ var p=String(d).split('-'); return (Date.UTC(+p[0],+p[1]-1,+p[2])-Date.UTC(1899,11,30))/86400000; };
  _lg.lines.forEach(function(o){
    if(o.k==='row') aoa.push([o.biz, serial(o.dt), o.no, (/^\d+$/.test(o.ln)?Number(o.ln):o.ln), o.dw, o.nm, o.spec, o.qty, o.price, o.sup, o.vat, o.tot, o.run, o.rmk]);
    else if(o.k==='day') aoa.push(['','일계','','','','','','','',o.sup,o.vat,o.tot,'','']);
    else aoa.push([(o.k==='sub'?'소계':'합계'),'','','','','','','','',o.sup,o.vat,o.tot,'','']);
    kinds.push(o.k); });
  var ws=XLSX.utils.aoa_to_sheet(aoa), bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var FILL={ h:'D9EDF7', day:'EEFFB9', sub:'ECC7FF', tot:'FCF8E3' };
  for(var r=0;r<aoa.length;r++){ var k=kinds[r];
    for(var c=0;c<NC;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var s={ font:{ name:'맑은 고딕', sz:10 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ s.font={ name:'맑은 고딕', sz:15, bold:true }; s.alignment.horizontal='center'; }
      else if(k==='p'){ s.alignment.horizontal=(c>=NC-2?'right':'left'); if(r===3) s.border={ bottom:bd }; }
      else if(k==='h'){ s.font.bold=true; s.alignment.horizontal='center'; s.fill={ fgColor:{ rgb:FILL.h } }; s.border=box; }
      else {
        s.border=box;
        var num=(c>=7 && c<=12), mid=(c>=1 && c<=4);
        s.alignment.horizontal = num ? 'right' : (mid ? 'center' : 'left');
        if(k==='row'){ s.fill={ fgColor:{ rgb:'FFFFFF' } }; if(c===0) s.border={ left:bd, right:bd }; }
        else { s.fill={ fgColor:{ rgb:FILL[k] } }; if(c===0) s.alignment.horizontal='center';
               if(k==='day' && c===0){ s.fill={ fgColor:{ rgb:'FFFFFF' } }; s.border={ left:bd, right:bd }; } }
        if(k==='row' && c===1){ ws[ref].t='n'; ws[ref].z='yyyy-mm-dd'; }
        if(ws[ref].t==='n' && c>=7){ ws[ref].z=(c===8 && Math.round(ws[ref].v)!==ws[ref].v) ? '#,##0.##' : '#,##0'; }
      }
      ws[ref].s=s; } }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:NC-1 } }, { s:{ r:2, c:0 }, e:{ r:2, c:NC-3 } }, { s:{ r:2, c:NC-2 }, e:{ r:2, c:NC-1 } }, { s:{ r:3, c:0 }, e:{ r:3, c:NC-3 } }, { s:{ r:3, c:NC-2 }, e:{ r:3, c:NC-1 } } ];
  ws['!cols']=[{ wch:22 },{ wch:11 },{ wch:12 },{ wch:5 },{ wch:9 },{ wch:46 },{ wch:14 },{ wch:6.5 },{ wch:10 },{ wch:12 },{ wch:10 },{ wch:12 },{ wch:13 },{ wch:10 }];
  ws['!rows']=aoa.map(function(a,i){ return { hpt:(i<2?18.75:16.5) }; });
  var f8=_lg.fr.replace(/-/g,''), t8=_lg.to.replace(/-/g,'');
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, ('동원홈푸드_'+f8+'~'+t8).slice(0,31));
  XLSX.writeFile(wb, '동원홈푸드 매출장부_'+f8+'~'+t8+'.xlsx');
  if(window._toast) _toast('📥 동원홈푸드 매출장부 엑셀 생성 — '+_lg.cnt+'줄 · 합계 '+fmt(_lg.tot)+'원','ok');
}

/* ── 직접 입력 — 토더와 같다. 치는 칸 : 배송일자 · 사업장코드 · 품목코드 · 수량 · 단가(부가세 별도). 비운 배송처·상품명·주문번호는 저장할 때 채운다(mPrep) ── */
var _mid=0;
function mFill(x, kind){ if(kind==='item' && x.itemCd && !x.priceEdited){ var r=priceOf(x.itemCd, x.dlvDt); x.price=r.p; x.priceSrc=r.src; if(!x.unit) x.unit=specOf(x.itemCd); } }
function mAdd(){
  var prev=null; _pv.forEach(function(y){ if(y.manual) prev=y; });
  var x={ manual:true, mid:(++_mid), no:'', seq:9000000+_mid, chk:true, fileNm:'직접 입력', bizNm:(prev?prev.bizNm:''), bizCode:'', rcvAddr:'', rcvTel:'', ordNo:'', reqNo:'', createDttm:'',
          dlvDt:(prev&&prev.dlvDt)?prev.dlvDt:ymd(new Date()), dwItemCd:'', itemNm:'', spec:'', unit:'', price:0, priceSrc:'', priceEdited:false, qty:1, status:'직접 입력', memo:'',
          bizCd:(prev?prev.bizCd:''), itemCd:'', bizAuto:false, itemAuto:false, itemHow:'' };
  _pv.push(x); pvRender();
  var tr=document.querySelector('#pvBody tr[data-mid="'+x.mid+'"]');
  if(tr){ var e=tr.querySelector(x.bizCd ? 'input[list="prodList"]' : 'input[list="bizList"]'); if(e) e.focus(); if(tr.scrollIntoView) tr.scrollIntoView({ block:'nearest' }); }
}
function mDel(i){ _pv.splice(i,1); pvRender(); }
function mSet(i, f, el){
  var x=_pv[i]; if(!x) return; var v=String(el.value||'').replace(/,/g,'').trim();
  if(f==='qty'){ x.qty=Math.max(0, Math.round(n(v))); el.value=x.qty||''; el.classList.toggle('bad', !x.qty); }
  else if(f==='price'){ x.price=(v==='' ? 0 : Math.max(0, n(v))); x.priceEdited=true; x.priceSrc=''; el.value=x.price||''; el.classList.toggle('bad', !x.price); }
  else if(f==='dlvDt'){ x.dlvDt=v; el.classList.toggle('bad', !v); }
  else { x[f]=String(el.value||'').trim(); if(f==='ordNo') x.ordAuto=false; }
  var a=amtOf(x), ma=document.getElementById('mAmt'+x.mid); if(ma) ma.textContent=fmt(a.sup)+' / '+fmt(a.vat)+' / '+fmt(a.tot);
  pvInfoUpd();
}
function mRow(x, i){
  var bn=_biz[x.bizCd], pn=_prod[x.itemCd], a=amtOf(x);
  var ti=function(f, w, ph){ return '<input type="text" class="mi" style="width:'+w+'px" value="'+esc(x[f]==null?'':x[f])+'" placeholder="'+ph+'" onchange="mSet('+i+',\''+f+'\',this)">'; };
  return '<tr data-mid="'+x.mid+'" class="'+(x.chk?'':'off')+'"><td><input type="checkbox" '+(x.chk?'checked':'')+' onchange="_pv['+i+'].chk=this.checked; pvRender()"></td>'
    +'<td><button class="btn" style="height:26px;padding:0 7px;color:#c0392b" title="이 줄을 화면에서 뺍니다(저장된 것과는 무관)" onclick="mDel('+i+')">✕</button></td>'
    +'<td><input type="date" class="mi'+(x.dlvDt?'':' bad')+'" value="'+esc(x.dlvDt)+'" onchange="mSet('+i+',\'dlvDt\',this)"></td>'
    +'<td>'+ti('ordNo', 96, '자동')+'</td>'
    +'<td class="dim" title="저장할 때 매깁니다">'+esc(x.ordAuto && x.no ? x.no : '자동')+'</td>'
    +'<td class="l">'+ti('bizNm', 110, '(배송처)')+'</td>'
    +'<td class="l">'+(x.bizCd?'<span class="sub nmf'+(bn==null?' warn':'')+'">'+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span>':'')
      +'<input type="text" list="bizList" class="'+cdCls(x.bizCd,_biz,false)+'" value="'+esc(x.bizCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'biz\',this.value)"></td>'
    +'<td>'+ti('dwItemCd', 80, '동원코드')+'</td>'
    +'<td class="l">'+ti('itemNm', 170, '(상품 마스터 이름)')+'</td>'
    +'<td class="l">'+(x.itemCd?'<span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span>':'')
      +'<input type="text" list="prodList" class="'+cdCls(x.itemCd,_prod,false)+'" value="'+esc(x.itemCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'item\',this.value)"></td>'
    +'<td>'+ti('unit', 96, '규격')+'</td>'
    +'<td class="r"><input type="text" class="num'+(x.qty?'':' bad')+'" style="width:70px" value="'+esc(x.qty||'')+'" title="수량" onchange="mSet('+i+',\'qty\',this)"></td>'
    +'<td class="r">'+(x.priceSrc&&!x.priceEdited?'<span class="bd ps">'+esc(x.priceSrc)+'</span> ':'')+'<input type="text" class="num'+(x.price?'':' bad')+'" style="width:84px" value="'+esc(x.price||'')+'" placeholder="단가" title="판매가('+vtLbl()+')" onchange="mSet('+i+',\'price\',this)"></td>'
    +'<td class="r" colspan="3"><b id="mAmt'+x.mid+'">'+fmt(a.sup)+' / '+fmt(a.vat)+' / '+fmt(a.tot)+'</b></td>'
    +'<td><span class="bd st">직접 입력</span></td></tr>';
}
/* 저장 직전 — 직접 줄의 빈 칸을 채운다(배송처·상품명 = 마스터 이름, 주문번호 = DW+일시+차례, 순번) */
function mPrep(rdy){
  var d=new Date(), p2=function(v){ return ('0'+v).slice(-2); };
  var stamp=String(d.getFullYear()).slice(2)+p2(d.getMonth()+1)+p2(d.getDate())+p2(d.getHours())+p2(d.getMinutes())+p2(d.getSeconds());
  var grp={}, gk=0;
  rdy.forEach(function(x){ if(!x.manual) return;
    if(!x.bizNm) x.bizNm=String(_biz[x.bizCd]||'');
    if(!x.itemNm) x.itemNm=prodNmOf(x.itemCd);
    if(!x.unit) x.unit=specOf(x.itemCd);
    if(!x.ordNo || x.ordAuto){ var k=x.dlvDt+'|'+x.bizCd; if(!grp[k]) grp[k]={ no:'DW'+stamp+'-'+(++gk), ln:0 }; x.ordNo=grp[k].no; x.ordAuto=true; x.no=String(++grp[k].ln); }
    else if(x.no==='' || x.no==null) x.no='1'; });
}

/* ── 끌어다 놓기 · 시작 ── */
(function(){
  var d=document.getElementById('upCard');
  ['dragenter','dragover'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.add('on'); }); });
  ['dragleave','drop'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.remove('on'); }); });
  d.addEventListener('drop',function(e){ onFiles(e.dataTransfer.files); });
  if(window.konetGridGrip){
    konetGridGrip('pvWrap','pvWrap','dongwonPoPv'); konetGridGrip('lsWrap','lsWrap','dongwonPoList');
    if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', pvRender); else pvRender();
  }
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth(), t.getDate()-14);
  document.getElementById('fr').value=ymd(a); document.getElementById('to').value=ymd(t);
  loadMasters();
})();
window.konetShown=function(){ loadMasters(); };   /* 다른 화면에서 사업장·상품·계약을 고치고 돌아오면 새로 */
</script>
</body>
</html>
