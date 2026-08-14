<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>택배출고관리</title>
<!--
  택배출고관리 (2026-08-06 신설) — 출고일자의 직송(TBL_SHIPOUT_MST ZONE='직송') 줄을
  택배 발송 엑셀(원양식: D:\코네트\택배관련\테스트 자료.xlsx)로 만든다.
    · 주소·전화 = TBL_BIZI_MST 택배값(PARCEL_ADDR/TEL/HP) 우선, 없으면 기본값(ADDR/TEL/HP) — 사용자 확정
    · 운임 = PARCEL_FEE, 없으면 4500 기본(행에서 수정 가능 — 같은 사업장도 품목 따라 3500 등)
    · [택배정보저장] = 그 행의 주소·전화·운임을 사업장(TBL_BIZI_MST)에 저장.
      사업장이 아직 없으면(출고자료에만 있는 신규) 자동 등록 후 저장(biziParcelUpdate.do)
    · 엑셀 9칼럼: A=받는분 · C=주소 · D=전화 · E=휴대폰 · F=총수량 · G=운임 · I=품목명 (B/H 빈칸),
      ※F=총수량 은 2026-08-14 요청으로 추가(그 전까지 F 는 빈칸이었다).
      시트명=MMDD. ★화면에 보이는 줄 그대로 한 줄씩 나간다(2026-08-14 확정).
      한때 박스 수만큼 같은 줄을 되풀이했으나(1박스 1송장) 화면에서 합친 줄이 엑셀에서 다시
      갈라져 두 곳이 어긋나 보였다 — 되풀이는 폐지. 되살리자는 얘기가 나오면 이 이력부터 확인.
    · ★머리글 줄과 출고일자 칸은 넣지 않는다(2026-08-06 확정) — 택배사 양식에 그대로 붙여 쓰려고
      원양식(머리글 없는 9칸)을 지킨다. 화면 목록에는 출고일자가 그대로 있다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; font-size:12.5px; }
  .sub b{ color:var(--teal); }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-teal:hover{ filter:brightness(1.06); }
  .cnt{ margin-left:auto; color:#6b7a89; font-size:13px; font-weight:700; }
  /* 목록 = 한 화면에 18줄 + 그 아래는 스크롤 (2026-08-06 요청).
     줄 높이는 두 줄짜리 품목명이 있어 들쭉날쭉 — 실측(poFit)으로 18줄 높이를 잡는다. */
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  /* 글자 한 단계 키움 (2026-08-06 요청) — 13 → 14px, 행 여백도 함께 */
  table{ width:100%; min-width:1280px; border-collapse:collapse; font-size:14px; }
  thead th{ background:#b9ded4; color:#0b4f43; font-weight:800; font-size:14px; box-shadow:inset 0 -2px 0 #0e6657; padding:10px 8px; text-align:center; position:sticky; top:0; z-index:2; white-space:nowrap; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:7px 6px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  td.c{ text-align:center; } td.num{ text-align:right; }
  td input{ width:100%; height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  td input.fee{ text-align:right; }
  td input.miss{ border-color:#e57373; background:#fff5f4; }   /* 주소 없음 — 채워야 발송 가능 */
  .newbiz{ display:inline-block; padding:1px 7px; border-radius:9px; font-size:11px; font-weight:800; background:#fff1e8; color:#b45309; border:1px solid #f0c9a4; white-space:nowrap; }
  /* 직송 표시 — 이 화면은 ZONE='직송' 출고만 조회한다(그 사실을 줄마다 보이게) */
  .zone{ display:inline-block; padding:1px 7px; border-radius:9px; font-size:11px; font-weight:800; background:#e9f4f1; color:#137a6c; border:1px solid #b9ded4; white-space:nowrap; }
  .act .btn{ height:29px; padding:0 10px; font-size:12.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  #msg{ position:fixed; left:50%; bottom:26px; transform:translateX(-50%); background:#1f2a37; color:#fff; padding:10px 18px; border-radius:9px; font-size:13px; opacity:0; transition:opacity .2s; pointer-events:none; z-index:50; }
  #msg.on{ opacity:1; }
  .note{ margin-top:10px; color:#8a98a8; font-size:12px; line-height:1.7; }
</style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<div class="wrap">
  <h2>🚛 택배출고관리</h2>
  <div class="sub">출고일자의 <b>직송(ZONE='직송')</b> 출고를 택배 발송 양식으로 만듭니다.
    주소·전화는 사업장의 <b>택배주소 우선(없으면 기본주소)</b>, 운임은 사업장 기본운임(없으면 4,500)이며 행에서 고칠 수 있습니다.</div>

  <div class="bar">
    <%-- 출고일자 기간 조회 (2026-08-06 요청) — 하루만 볼 때는 두 칸을 같은 날로 두면 된다 --%>
    <label style="font-weight:700">출고일자</label>
    <input type="date" id="outFr" onchange="poDtSync('fr')">
    <span style="color:#8a98a8">~</span>
    <input type="date" id="outTo" onchange="poDtSync('to')">
    <button class="btn btn-teal" onclick="poLoad()">🔍 조회</button>
    <%-- 주소 없는 줄 일괄 제외 (2026-08-06 요청) — 주소가 비면 송장이 안 나가므로 한 번에 뺀다 --%>
    <button class="btn" onclick="poOffNoAddr()" title="택배주소·배송지주소가 모두 없는 줄의 체크를 한꺼번에 풉니다">🚫 주소없음 제외</button>
    <button class="btn" onclick="poAllChk(true)" title="모든 줄을 다시 엑셀에 포함합니다">↺ 전체 포함</button>
    <button class="btn btn-teal" onclick="poExcel()">📥 엑셀 다운로드</button>
    <span class="cnt" id="cnt">-</span>
  </div>

  <div class="card" id="listCard">
    <table>
      <colgroup>
        <col style="width:36px"><col style="width:34px"><col style="width:52px"><col style="width:86px"><col style="width:96px"><col style="width:190px"><col>
        <col style="width:130px"><col style="width:130px"><col style="width:84px">
        <col style="width:300px"><col style="width:52px"><col style="width:72px"><col style="width:110px">
      </colgroup>
      <thead><tr>
        <th title="체크를 풀면 엑셀에서 빠집니다"><input type="checkbox" id="poAll" checked onchange="poAllChk(this.checked)"></th>
        <th>#</th><th>구분</th><th>출고일자</th><th>사업장코드</th><th>사업장명(받는분)</th><th>택배주소</th>
        <th>전화</th><th>휴대폰</th><th>운임</th><th>품목명</th><th>박스</th>
        <th title="발주현황표에 올라온 수량 그대로입니다(계산하지 않습니다). 대시보드의 수량과 같은 값입니다. 엑셀 F칸으로 나갑니다.">총수량</th>
        <th>택배정보</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="14" class="empty">출고일자를 고르고 [조회]를 누르세요.</td></tr></tbody>
    </table>
  </div>
  <%-- 목록 아래 진행 표시 (2026-08-06 요청) — 몇 줄까지 보고 있는지·더 있는지 알려 준다
       (매입등록 명세 그리드의 안내줄과 같은 방식) --%>
  <div id="poPager" style="padding:8px 2px 0; text-align:center; min-height:26px; font-size:13px; color:#5a6b7a"></div>

<%-- 하단 안내문은 사용자 요청으로 삭제(2026-08-06) — 규칙은 이 파일 맨 위 주석과 버튼 툴팁에 남아 있다 --%>
</div>
<div id="msg"></div>

<%-- 메시지는 프로젝트 공통 컴포넌트(asset/js/ui-message.js) — 로그인 화면·매입등록과 같은 모양.
     브라우저 기본 confirm/alert 은 쓰지 않는다(2026-08-06 요청). --%>
<script src="${ctx}/asset/js/ui-message.js"></script>
<script src="${ctx}/assets/vendor/sheetjs/xlsx.full.min.js"></script>
<script>
var CTX = '${ctx}';
var ROWS = [];

function toast(s){ var m=document.getElementById('msg'); m.innerHTML=s; m.classList.add('on'); clearTimeout(m._t); m._t=setTimeout(function(){ m.classList.remove('on'); }, 2600); }
/* 표준 알림·확인 (매입등록 swOk/swErr/swConfirm 과 같은 규격) — 컴포넌트가 없으면 기본창으로 떨어진다 */
function swOk(msg){   if (window._alertBox) return _alertBox(msg, { icon:'✅' }); alert(String(msg).replace(/<br\s*\/?>/gi,'\n')); }
function swErr(msg){  if (window._alertBox) return _alertBox(msg, { icon:'❌', okColor:'red' }); alert(String(msg).replace(/<br\s*\/?>/gi,'\n')); }
function swAlert(msg){ if (window._alertBox) return _alertBox(msg, { icon:'ℹ️' }); alert(String(msg).replace(/<br\s*\/?>/gi,'\n')); }
function swConfirm(msg, okText){
  return new Promise(function(resolve){
    if (!window._confirmBox) { resolve(confirm(String(msg).replace(/<br\s*\/?>/gi,'\n'))); return; }
    _confirmBox({ msg:msg, icon:'❓', okText:okText||'확인',
                  onOk:function(){ resolve(true); }, onCancel:function(){ resolve(false); } });
  });
}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number((''+(v==null?'':v)).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmtDt(s){ s=''+(s==null?'':s); return s.length===8 ? s.slice(4,6)+'-'+s.slice(6,8) : s; }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }

document.getElementById('outFr').value = today();
document.getElementById('outTo').value = today();
/* 시작이 종료보다 뒤면 자동으로 맞춘다 — 거꾸로 넣어 0건 나오는 일을 막는다 */
function poDtSync(which){
  var fr=document.getElementById('outFr'), to=document.getElementById('outTo');
  if(!fr.value || !to.value) return;
  if(fr.value > to.value){ if(which==='fr') to.value=fr.value; else fr.value=to.value; }
}
window.addEventListener('resize', function(){ clearTimeout(window._poFitT); window._poFitT=setTimeout(poFit, 150); });
/* 스크롤하면 아래 안내줄(몇 건까지 보는지)을 갱신 */
document.getElementById('listCard').addEventListener('scroll', function(){ clearTimeout(window._poPgT); window._poPgT=setTimeout(poPager, 60); });

function poLoad(){
  var fr = document.getElementById('outFr').value, to = document.getElementById('outTo').value;
  if(!fr || !to){ swErr('출고일자(시작·종료)를 선택하세요.'); return; }
  document.getElementById('tb').innerHTML = '<tr><td colspan="14" class="empty">조회 중…</td></tr>';
  fetch(CTX+'/shipout/parcelList.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to) })
    .then(function(r){ return r.json(); })
    .then(function(j){ ROWS=poMerge((j&&j.data)||[]); poRender(); })
    .catch(function(e){ document.getElementById('tb').innerHTML='<tr><td colspan="14" class="empty">조회 오류: '+esc(e.message)+'</td></tr>'; });
}

/* 한 화면에 18줄까지 보이고 그 아래는 스크롤 (2026-08-06 요청).
   ★고정 px 로 잡지 않는다 — 품목명이 두 줄인 행이 섞여 줄 높이가 제각각이라 어긋난다.
     그려 놓은 뒤 앞 18줄의 **실제 높이 합**(+머리글)으로 목록 높이를 정한다. */
var PO_ROWS = 18;
function poFit(){
  var card=document.getElementById('listCard'), tb=document.getElementById('tb');
  if(!card||!tb) return;
  var trs=tb.querySelectorAll('tr');
  /* ★18줄 이하로 돌아올 때도 안내줄을 갱신해야 한다 —
     여기서 그냥 return 하면 poPager 가 안 불려 이전 조회의 '17 / 54건' 이 남는다(2026-08-06 수정) */
  if(trs.length <= PO_ROWS){ card.style.maxHeight=''; poPager(); return; }   // 18줄 이하면 자연 높이
  var head=card.querySelector('thead');
  var h=(head?head.offsetHeight:0) + 2;
  for(var i=0;i<PO_ROWS;i++) h += trs[i].offsetHeight;
  /* 화면이 작으면 18줄이 창을 넘는다 — 목록 위(제목·버튼)와 아래 안내줄을 뺀 남은 높이를 넘지 않게 */
  var top = card.getBoundingClientRect().top;
  var room = Math.max(240, window.innerHeight - top - 40);
  card.style.maxHeight = Math.min(h, room) + 'px';
  poPager();
}
/* 목록 아래 안내줄 — 지금 몇 줄까지 보이는지 / 전체 몇 줄인지. 스크롤하면 따라 갱신된다 */
function poPager(){
  var el=document.getElementById('poPager'); if(!el) return;
  var card=document.getElementById('listCard'), trs=document.querySelectorAll('#tb tr');
  var tot=ROWS.length;
  if(!tot){ el.innerHTML=''; return; }
  var bottom=card.getBoundingClientRect().bottom, seen=0;
  for(var i=0;i<trs.length;i++){ if(trs[i].getBoundingClientRect().bottom <= bottom+2) seen++; }
  if(seen>=tot) el.innerHTML = '총 <b>'+tot+'</b>건 — 모두 표시됨';
  else el.innerHTML = seen+' / <b>'+tot+'</b>건 <span style="color:#8a98a8">— 아래로 스크롤하면 이어서 나옵니다</span>';
}
/* 같은 출고일자·사업장·품목은 한 줄로 합친다 (2026-08-13 요청 "대시보드 같은 식으로 합쳐서").
   발주현황표는 같은 사업장·품목이 여러 줄로 올라오는데, 택배는 한 곳에 한 번 보내므로
   화면에서 줄이 나뉘어 있을 이유가 없다. 대시보드1 이 사업장+품목으로 합산해 보여 주는 것과 같은 셈법.
   · 더하는 것은 <박스>와 <총수량> 둘뿐. 주소·전화·운임은 사업장 값이라 어차피 같다.
   · ★엑셀도 이 합친 줄 그대로 나간다 (2026-08-14 확정) — 종전에는 엑셀이 박스 수만큼 줄을
     되풀이해(1박스 1송장) 합친 줄이 다시 갈라졌지만, 이제 되풀이하지 않는다.
     즉 합치는 규칙을 고치면 엑셀 줄 수도 함께 바뀐다.
   · 몇 줄을 합쳤는지는 mergeCnt 에 담아 화면에 밝힌다(원자료가 몇 줄이었는지 감춰지지 않게). */
function poMerge(list){
  var out=[], idx={};
  (list||[]).forEach(function(o){
    var k=(o.outDt||'')+'|'+(o.bizCd||'')+'|'+(o.itemNm||'');
    if(idx[k]==null){
      var c={}; for(var f in o){ if(Object.prototype.hasOwnProperty.call(o,f)) c[f]=o[f]; }
      c.mergeCnt=1; idx[k]=out.length; out.push(c); return;
    }
    var m=out[idx[k]];
    m.boxQty=n(m.boxQty)+n(o.boxQty);
    m.totQty=n(m.totQty)+n(o.totQty);
    m.mergeCnt=(m.mergeCnt||1)+1;
  });
  return out;
}

/* 총수량 = 발주현황표(엑셀)의 '수량' 원값 그대로 (2026-08-13 확정 "발주한 대로 그대로").
   ★계산하지 않는다. 한때 '박스 × 입수' 로 냈다가 폐기했다 — 상품마스터 입수가 미등록(1)이거나
     품목명 표기와 달라(마스터 48 vs 품목명 100EA/BOX) 줄마다 1·48·100·2000 이 뒤섞여 나왔다.
   대시보드1 이 쓰는 칸(CUR_QTY)과 같아 두 화면 숫자가 어긋나지 않는다. */
function poRender(){
  var tb=document.getElementById('tb');
  poCnt();
  if(!ROWS.length){ tb.innerHTML='<tr><td colspan="14" class="empty">이 날짜의 직송 출고가 없습니다.</td></tr>'; poFit(); return; }
  tb.innerHTML = ROWS.map(function(o,i){
    var fee = n(o.fee) || 4500;                      /* 미설정(0) = 기본 4500 */
    var missA = !(o.addr && (''+o.addr).trim());
    var box = n(o.boxQty), tot = n(o.totQty);   /* 총수량 = 발주현황표 '수량' 원값 */
    /* 엑셀 제외 (2026-08-06 요청) — 체크를 풀면 그 줄은 엑셀에서 빠진다(화면 목록에는 남는다).
       o.off 가 true 면 제외. 조회하면 전부 포함(체크) 상태로 시작한다. */
    return '<tr'+(o.off?' style="opacity:.45"':'')+'>'
      + '<td class="c"><input type="checkbox" data-i="'+i+'" '+(o.off?'':'checked')+' onchange="poChk(this)" title="체크를 풀면 엑셀에서 빠집니다"></td>'
      + '<td class="c">'+(i+1)+'</td>'
      + '<td class="c"><span class="zone">직송</span></td>'
      + '<td class="c" style="color:#5a6b7a">'+esc(fmtDt(o.outDt))+'</td>'
      + '<td class="c">'+esc(o.bizCd)+(o.bizYn==='N'?' <span class="newbiz" title="사업장관리에 아직 없는 사업장 — 저장하면 함께 등록됩니다">신규</span>':'')+'</td>'
      + '<td>'+esc(o.bizNm)+'</td>'
      + '<td><input data-i="'+i+'" data-f="addr" class="'+(missA?'miss':'')+'" value="'+esc(o.addr)+'" placeholder="택배주소 입력" onchange="poSet(this)"></td>'
      + '<td><input data-i="'+i+'" data-f="tel" value="'+esc(o.tel)+'" onchange="poSet(this)"></td>'
      + '<td><input data-i="'+i+'" data-f="hp" value="'+esc(o.hp)+'" onchange="poSet(this)"></td>'
      + '<td><input data-i="'+i+'" data-f="fee" class="fee" inputmode="numeric" value="'+fee+'" onchange="poSet(this)"></td>'
      + '<td>'+esc(o.itemNm)+'</td>'
      + '<td class="c">'+box
          + (n(o.mergeCnt)>1 ? '<span style="font-size:10px;font-weight:400;color:#8a97a3" title="발주현황표에 같은 사업장·품목으로 '+n(o.mergeCnt)+'줄 올라온 것을 한 줄로 합쳤습니다. 엑셀도 이 한 줄로 나갑니다."> ('+n(o.mergeCnt)+'줄)</span>' : '')
          + '</td>'
      + (tot > 0
          ? '<td class="num" title="발주현황표에 올라온 수량 그대로입니다.">'+tot.toLocaleString()+'</td>'
          : '<td class="c" style="color:#b0bac4" title="발주현황표에 수량이 비어 있습니다.">-</td>')
      + '<td class="c act"><button class="btn" onclick="poSaveBiz('+i+')" title="이 행의 주소·전화·운임을 사업장에 저장">택배정보저장</button></td>'
      + '</tr>';
  }).join('');
  poFit();                       /* 그린 뒤 18줄 높이로 맞춘다 */
}
/* 엑셀 제외 체크 — 화면 건수 표시도 '전체 N건 · 엑셀 M건' 으로 갱신 */
function poChk(inp){
  var o = ROWS[+inp.dataset.i]; if(!o) return;
  o.off = !inp.checked;
  inp.closest('tr').style.opacity = o.off ? '.45' : '';
  poCnt();
}
function poAllChk(on){
  ROWS.forEach(function(o){ o.off = !on; });
  poRender();
  var a=document.getElementById('poAll'); if(a){ a.checked=!!on; a.indeterminate=false; }
}
/* 주소 없는 줄만 한꺼번에 제외 — 이미 제외한 줄은 그대로 둔다(포함으로 되돌리지 않는다) */
function poOffNoAddr(){
  if(!ROWS.length){ swErr('먼저 조회하세요.'); return; }
  var hit = 0;
  ROWS.forEach(function(o){
    if (!(o.addr && (''+o.addr).trim()) && !o.off) { o.off = true; hit++; }
  });
  poRender();
  if (hit) toast('🚫 주소 없는 '+hit+'건을 엑셀에서 제외했습니다');
  else     toast('주소 없는 줄이 없습니다');
}
function poCnt(){
  var use = ROWS.filter(function(o){ return !o.off; }).length;
  document.getElementById('cnt').textContent = ROWS.length + '건'
    + (use !== ROWS.length ? ' · 엑셀 '+use+'건' : '');
  var a=document.getElementById('poAll');
  if(a){ a.checked = (use===ROWS.length && use>0); a.indeterminate = (use>0 && use<ROWS.length); }
}
function poSet(inp){
  var o = ROWS[+inp.dataset.i]; if(!o) return;
  o[inp.dataset.f] = (inp.dataset.f==='fee') ? n(inp.value) : inp.value;
  if (inp.dataset.f==='addr') inp.classList.toggle('miss', !(''+inp.value).trim());
}

/* 행의 택배정보를 사업장(TBL_BIZI_MST)에 저장 — 같은 사업장 다른 행에도 즉시 반영 */
function poSaveBiz(i){
  var o = ROWS[i]; if(!o) return;
  var fee = n(o.fee) || 4500;
  fetch(CTX+'/mangr/biziParcelUpdate.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify([{ bizCd:o.bizCd, bizNm:o.bizNm, parcelAddr:o.addr||'', parcelTel:o.tel||'', parcelHp:o.hp||'', parcelFee:fee }]) })
    .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); }); })
    .then(function(){
      swOk('저장했습니다 — '+esc(o.bizNm));
      ROWS.forEach(function(x){ if(x.bizCd===o.bizCd){ x.addr=o.addr; x.tel=o.tel; x.hp=o.hp; x.fee=fee; x.bizYn='Y'; } });
      poRender();
    })
    .catch(function(e){ swErr('저장에 실패했습니다.<br><span style="font-size:12.5px;color:#3d4d5c">'+esc(e.message).slice(0,150)+'</span>'); });
}

/* 엑셀 — 원양식(9칼럼, 시트명 MMDD) 그대로. 화면에 보이는 줄 그대로 한 줄씩(2026-08-14) */
function poExcel(){
  if(!ROWS.length){ swErr('먼저 조회하세요.'); return; }
  var USE = ROWS.filter(function(o){ return !o.off; });          /* 체크 푼 줄은 제외(2026-08-06) */
  if(!USE.length){ swErr('엑셀에 담을 줄이 없습니다. (모두 제외되어 있습니다)'); return; }
  var missCnt = USE.filter(function(o){ return !(o.addr && (''+o.addr).trim()); }).length;
  /* 주소 빈 줄이 있으면 표준 확인창으로 묻는다(브라우저 기본 confirm 금지 — 2026-08-06) */
  if (!missCnt) { poExcelMake(); return; }
  swConfirm('주소가 비어 있는 줄이 <b>'+missCnt+'건</b> 있습니다.<br>'
    + '<span style="font-size:13px;color:#3d4d5c">그대로 엑셀을 만들까요? (그 줄은 주소 칸이 빈 채로 나갑니다)</span>', '엑셀 만들기')
    .then(function(ok){ if(ok) poExcelMake(); });
}
function poExcelMake(){
  /* 시트명·파일명 = 시작일자 기준(기간이면 '0806-0808' 로) */
  var dt = document.getElementById('outFr').value, dt2 = document.getElementById('outTo').value;
  var mmdd = dt.slice(5,7)+dt.slice(8,10) + (dt2 && dt2!==dt ? '-'+dt2.slice(5,7)+dt2.slice(8,10) : '');
  /* ★머리글 줄·출고일자 칸 없음 (2026-08-06 재요청) — 원양식(9칸, 머리글 없음) 그대로 만든다.
     한때 머리글 한 줄과 10번째(J) 출고일자 칸을 붙였으나, 택배사 양식에 그대로 붙여 쓰려면
     군더더기 없이 자료 줄만 있어야 한다. 다시 붙이자는 얘기가 나오면 이 이력부터 확인할 것. */
  var aoa = [];
  var cnt = 0;
  /* ★화면에 보이는 줄 = 엑셀 줄 (2026-08-14 확정) — 박스 수만큼 되풀이하지 않는다.
       종전에는 '1박스 1송장' 이라 박스 수대로 같은 줄을 되풀이했는데, 그러면 화면에서 한 줄로
       합쳐 놓은 것(같은 출고일자·사업장·품목)이 엑셀에서 다시 갈라져 두 곳이 어긋나 보였다.
       (사용자 예: 박스 2 인 기흥점 한 줄이 엑셀에서 두 줄로 나왔다)
     ★같은 사업장이라도 품목이 다르면 줄은 나뉜다 — 화면 합침 규칙(poMerge)과 똑같이 간다.
     ★체크를 푼 줄(o.off)은 빼고 만든다 (2026-08-06 요청) */
  ROWS.filter(function(o){ return !o.off; }).forEach(function(o){
    var fee = n(o.fee) || 4500;
    /* ★F칸 = 총수량 (2026-08-14 요청). 화면 '총수량' 칸과 같은 값(발주현황표 '수량' 원값)을
       손대지 않고 그대로 넣는다 — 빈값 대체·계산 없음(사용자 확정 "수량이 없을 수는 없음"). */
    aoa.push([ o.bizNm||'', '', o.addr||'', o.tel||'', o.hp||'', n(o.totQty), fee, '', o.itemNm||'' ]);
    cnt++;
  });
  /* 색·테두리를 넣으려면 스타일 지원본(xlsx-js-style)이 필요하다 — 출고장별 엑셀과 같은 방식.
     못 불러오면 기본 라이브러리로 '무색' 저장까지는 되게 한다(2026-08-06). */
  poLoadStyleXlsx(function(LIBS){
    var LIB = LIBS || XLSX, styled = !!LIBS;
    var ws = LIB.utils.aoa_to_sheet(aoa);
    /* F(6번째)는 총수량이 들어가므로 폭을 넓혔다(4 → 9) */
    ws['!cols'] = [{wch:24},{wch:4},{wch:46},{wch:14},{wch:14},{wch:9},{wch:8},{wch:4},{wch:44}];
    if (styled) {
      /* 색상은 다른 화면(출고장별 엑셀)과 같은 계열 — 머리글이 없으므로 본문 구분선만 */
      var LINE = { style:'thin', color:{ rgb:'DFE6E3' } };
      var box  = { top:LINE, bottom:LINE, left:LINE, right:LINE };
      var CELL = { alignment:{ vertical:'center' }, border:box };
      var NUM  = { alignment:{ horizontal:'right', vertical:'center' }, border:box };
      for (var r=0; r<aoa.length; r++){
        for (var c=0; c<9; c++){
          var ref = LIB.utils.encode_cell({ r:r, c:c });
          if (!ws[ref]) ws[ref] = { t:'s', v:'' };          // 빈 칸도 테두리가 이어지게
          ws[ref].s = ((c===5 || c===6) ? NUM : CELL);   /* F=총수량 · G=운임 = 숫자칸(우측정렬) */
        }
      }
    }
    var wb = LIB.utils.book_new();
    LIB.utils.book_append_sheet(wb, ws, mmdd);
    LIB.writeFile(wb, '택배출고_'+dt.replace(/-/g,'')+'.xlsx');
    /* 성공 알림창은 띄우지 않는다 (2026-08-06 요청) — 파일이 받아지면 그것으로 충분하다.
       하단 토스트로만 조용히 알린다. 다만 색·테두리가 빠진 경우는 알아야 하므로 그때만 알림창. */
    if (styled) toast('📥 엑셀 생성 — '+cnt+'줄 (화면 목록과 같은 줄 수)');
    else swAlert('엑셀을 만들었습니다.<br><span style="font-size:12.5px;color:#c0392b">색·테두리 없이 저장했습니다(스타일 모듈을 못 불러옴).</span>');
  });
}
/* 스타일 지원 엑셀 모듈 — 로컬 우선, 실패하면 CDN. window.XLSX 는 원래 것으로 되돌린다
   (출고현황표의 ssLoadStyleXlsx 와 같은 수법 — 두 라이브러리가 같은 전역을 쓰기 때문) */
var _poStyleLib = null;
function poLoadStyleXlsx(cb){
  if (_poStyleLib) { cb(_poStyleLib); return; }
  var srcs = [ CTX+'/assets/vendor/xlsx-js-style/xlsx.bundle.js',
               'https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js' ];
  var prev = window.XLSX, i = 0;
  (function tryNext(){
    if (i >= srcs.length) { window.XLSX = prev; cb(null); return; }
    var s = document.createElement('script');
    s.src = srcs[i++];
    s.onload  = function(){ _poStyleLib = window.XLSX; window.XLSX = prev; cb(_poStyleLib); };
    s.onerror = function(){ window.XLSX = prev; tryNext(); };
    document.head.appendChild(s);
  })();
}

poLoad();
</script>
</body>
</html>
