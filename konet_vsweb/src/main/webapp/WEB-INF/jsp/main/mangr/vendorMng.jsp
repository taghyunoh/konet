<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<title>매입/매출 거래처 관리 (TBL_VENDOR_MST)</title>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; }
  *{ box-sizing:border-box; }
  /* ★화면 시작 위치·글꼴 통일 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 4px; font-size:20px; }
  .sub{ color:#6b7a89; margin-bottom:14px; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
  .bar input.search{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 10px; font-size:13px; width:280px; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .btn:hover{ border-color:var(--teal); }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-danger{ color:#c0392b; border-color:#e3b4ae; }
  .cnt{ margin-left:8px; color:#6b7a89; font-size:12.5px; }
  .tabs{ display:flex; gap:4px; margin-bottom:10px; border-bottom:2px solid #e2e8e6; }
  .tabs .t{ height:32px; padding:0 14px; border:1px solid #dfe6e3; border-bottom:none; background:#f1f5f4; border-radius:8px 8px 0 0; cursor:pointer; font-size:13px; font-weight:700; color:#5a6b7a; }
  .tabs .t.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  /* ★목록이 창 아래까지 차게 (2026-08-03 요청) — 종전에는 20줄만 그리고 그 아래가 통째로 비었다.
     높이는 JS(vmFit)가 실제 위치를 재서 넣는다. 고정 calc() 는 배율·줌마다 어긋난다(마감업로드에서 겪음). */
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; }
  #listCard{ min-height:220px; }
  table{ width:100%; border-collapse:collapse; font-size:13px; font-weight:700; white-space:nowrap; }
  thead th{ background:#b9ded4; color:#0b4f43; font-weight:800; font-size:14px; box-shadow:inset 0 -2px 0 #0e6657; padding:9px 10px; text-align:left; position:sticky; top:0; z-index:1; }
  tbody td{ border-bottom:1px solid #eef1f5; padding:6px 10px; vertical-align:middle; }
  tbody tr:hover td{ background:#f3f8f6; }
  tbody tr{ cursor:pointer; }
  tbody tr.sel td{ background:#dcefe9 !important; }
  td.code{ font-family:Consolas,monospace; }
  td.nm{ white-space:normal; min-width:160px; max-width:260px; }
  .gb{ display:inline-block; padding:1px 8px; border-radius:10px; font-size:11px; font-weight:700; color:#fff; }
  .dc{ display:inline-block; padding:1px 7px; border-radius:8px; font-size:11px; font-weight:700; background:#eef4ff; color:#274b8f; border:1px solid #c9d9f5; }
  .act .btn{ height:26px; padding:0 9px; font-size:11.5px; }
  .empty{ padding:26px; text-align:center; color:#9aa7b3; }
  .pager{ display:flex; gap:8px; justify-content:center; align-items:center; margin-top:10px; flex-wrap:wrap; }
  .pgnote{ font-size:12.5px; color:#5a6b7a; font-weight:600; }
  .pgnote b{ color:var(--teal); }
  .pager button{ min-width:32px; height:32px; border:1px solid var(--bd); background:#fff; border-radius:7px; cursor:pointer; font-size:12.5px; font-weight:700; color:#37475a; padding:0 8px; }
  .pager button.on{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .pager button:disabled{ opacity:.45; cursor:default; }
  .pager .ell{ padding:0 4px; color:#9aa7b3; }
  #ov{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:50; align-items:flex-start; justify-content:center; }
  #ov.on{ display:flex; }
  /* ★한 화면에 들어오게 (2026-08-03 요청) — 종전 2단 22칸이라 창이 세로로 길어
       노트북(768px)에서는 스크롤을 내려야 부가세·거래유형이 보였다.
       3단으로 넓히고(창 폭 1080px) 칸 높이·여백을 줄여 스크롤 없이 끝나게 한다. */
  #ov .box{ background:#fff; width:min(1080px,96vw); margin-top:2vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); max-height:96vh; display:flex; flex-direction:column; }
  #ov .mh{ background:linear-gradient(135deg,#1f9b8e,#137a6c); color:#fff; padding:9px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center; }
  #ov .mh b{ font-size:16px; }
  #ov .mh .x{ background:none; border:none; color:#fff; font-size:22px; cursor:pointer; }
  #ov .mb{ padding:12px 18px; overflow:auto; display:grid; grid-template-columns:1fr 1fr 1fr; gap:7px 14px; }
  #ov .fld{ display:flex; flex-direction:column; gap:2px; }
  #ov .fld.full{ grid-column:1 / -1; }
  #ov .fld.two{ grid-column:span 2; }
  /* 칸 묶음 제목 — 어디까지가 한 덩어리인지 보이면 훑는 속도가 빨라진다 */
  #ov .sep{ grid-column:1 / -1; margin:5px 0 0; padding-top:5px; border-top:1px dashed #cfd8e3;
            font-size:12px; font-weight:800; color:#137a6c; }
  #ov .sep:first-child{ border-top:0; padding-top:0; margin-top:0; }
  /* 창이 좁으면(태블릿·작은 노트북) 2단으로 접는다 — 3단을 우겨넣으면 칸이 너무 좁아진다 */
  @media (max-width:900px){
    #ov .mb{ grid-template-columns:1fr 1fr; }
    #ov .fld.two{ grid-column:span 2; }
  }
  <%-- 라벨 = 진하게·가운데 정렬 (2026-08-04 요청, 상품코드 등록 창과 동일) --%>
  #ov label{ font-size:12px; font-weight:700; color:#1f2a37; background:linear-gradient(135deg,#b3ddf0 0%,#d4ecf7 100%); border-radius:3px; padding:4px 10px; display:inline-flex; align-items:center; justify-content:center; text-align:center; align-self:flex-start; min-width:104px; min-height:26px; white-space:nowrap; }
  #ov label.wide{ width:auto; }
  #ov input, #ov select, #ov textarea{ height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:14px; font-family:inherit; }
  #ov textarea{ height:auto; padding:6px 8px; resize:vertical; }
  #ov .mf{ padding:9px 18px; border-top:1px solid var(--bd); display:flex; justify-content:flex-end; gap:8px; }
  /* 취소·저장은 가로를 넉넉히 (2026-08-04 요청) — 창을 닫는 마지막 손동작이라 누르기 쉬워야 한다 */
  #ov .mf .btn{ min-width:104px; padding:0 22px; }
</style>
<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     이 한 줄만 빼면 종전 데스크탑 화면 그대로다(파일 안에서 폭·높이 조건으로만 동작). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
</head>
<body>
<div class="wrap">
  <h2>🧾 매입/매출 거래처 관리 <span style="font-size:13px;color:#9aa7b3;font-weight:400">(회계 거래처 · TBL_VENDOR_MST)</span></h2>
  <div class="sub">회계 거래처 조회 · 추가 · 수정 · 삭제 · 엑셀 — 사업장(TBL_BIZI_MST, 배송 점포)과는 별개 마스터입니다.
    매입가·재고입고 화면의 매입처 선택은 여기의 <b>매입</b> 거래처를 씁니다.
    <%-- 키 안내 (2026-08-04) — 안 보이면 아무도 안 쓴다 --%>
    <div style="margin-top:3px;font-size:12px;color:#9aa7b3">⌨ <b>↑↓</b> 줄 이동 · <b>Enter</b> 수정 · <b>Alt+N</b> 추가
      &nbsp;|&nbsp; 창에서 <b>Enter</b> 다음 칸 · <b>Ctrl+S</b> 저장 · <b>Esc</b> 닫기</div></div>

  <div class="bar">
    <input type="text" class="search" id="q" placeholder="코드·거래처명·정식명칭·별칭·사업자번호·대표자 검색" onkeyup="vmFilter()">
    <button class="btn" onclick="vmLoad()">↻ 조회</button>
    <button class="btn btn-teal" style="margin-left:auto" onclick="vmOpen()">＋ 거래처 추가</button>
    <button class="btn" onclick="vmEditSel()">✎ 수정</button>
    <button class="btn btn-danger" onclick="vmDelSel()">🗑 삭제</button>
    <button class="btn" onclick="document.getElementById('upFile').click()" title="회계시스템의 거래처리스트.xls 를 다시 올리면 코드 기준으로 갱신·추가됩니다(있으면 갱신, 없으면 신규). 삭제는 하지 않습니다.">📤 거래처리스트 재업로드</button>
    <input type="file" id="upFile" accept=".xls,.xlsx,.html,.htm" style="display:none" onchange="vmUpload(this)">
    <button class="btn" onclick="vmExcel()">📥 엑셀 출력</button>
    <span class="cnt" id="cnt">0건</span>
  </div>

  <div class="tabs" id="gbTabs">
    <button class="t on" data-g=""      onclick="vmTab('')">전체</button>
    <button class="t"    data-g="매입"  onclick="vmTab('매입')">매입처</button>
    <button class="t"    data-g="매출"  onclick="vmTab('매출')">매출처</button>
  </div>

  <div class="card" id="listCard">
    <table>
      <thead><tr>
        <th>코드</th><th>거래처명</th><th>별칭</th><th>거래유형</th><th>사업자번호</th><th>대표자</th>
        <th>담당자</th><th>연락처</th><th>전화</th><th>부가세</th><th>물류센터</th>
      </tr></thead>
      <tbody id="tb"><tr><td colspan="11" class="empty">불러오는 중…</td></tr></tbody>
    </table>
  </div>
  <div id="pager" class="pager"></div>
</div>

<div id="ov">
  <div class="box">
    <div class="mh"><b id="ovTit">거래처 추가</b><button class="x" onclick="vmClose()">&times;</button></div>
    <div class="mb">
      <div class="sep">기본</div>
      <div class="fld"><label>거래처코드 *</label><input id="f_cd" placeholder="예: 0089"></div>
      <div class="fld"><label>거래유형 *</label><select id="f_gb"><option value="매입">매입</option><option value="매출">매출</option><option value="매입&매출">매입&매출</option></select></div>
      <div class="fld"><label>부가세</label><select id="f_vat" title="이 거래처의 매입·판매 등록에서 부가세를 어떻게 계산할지 정합니다. 비워 두면 별도로 봅니다."><option value="">- (별도와 같음)</option><option value="별도">별도 (단가 + 10%)</option><option value="포함">포함 (단가 안에 10% 들어 있음)</option><option value="면세">면세 (부가세 없음)</option></select></div>
      <div class="fld two"><label>거래처명 *</label><input id="f_nm"></div>
      <div class="fld"><label>계산서발행</label><select id="f_taxbill"><option value="">-</option><option value="발행">발행</option><option value="미발행">미발행</option></select></div>
      <div class="fld"><label>정식명칭</label><input id="f_full"></div>
      <div class="fld"><label>별칭</label><input id="f_alias"></div>
      <div class="fld"><label>사업자등록번호</label><input id="f_bizno"></div>
      <div class="sep">사업자</div>
      <div class="fld"><label>대표자</label><input id="f_ceo"></div>
      <div class="fld"><label>업태</label><input id="f_cond"></div>
      <div class="fld"><label>종목</label><input id="f_item"></div>
      <div class="fld"><label>담당자코드</label><input id="f_mgrcd"></div>
      <div class="fld"><label>담당자명</label><input id="f_mgrnm"></div>
      <div class="fld"><label class="wide">물류센터코드 <span style="color:#9aa7b3;font-weight:400">(삼성웰스토리 지점만, 예: E500)</span></label><input id="f_dc" placeholder="비워두면 일반 거래처"></div>
      <div class="sep">연락처·주소</div>
      <div class="fld"><label>연락처(휴대폰)</label><input id="f_hp"></div>
      <div class="fld"><label>전화</label><input id="f_tel"></div>
      <div class="fld"><label>팩스</label><input id="f_fax"></div>
      <div class="fld"><label>이메일</label><input id="f_email"></div>
      <div class="fld"><label>우편번호</label><input id="f_zip"></div>
      <div class="fld two"><label>주소</label><input id="f_addr"></div>
      <div class="fld two"><label>상세주소</label><input id="f_addr2"></div>
      <div class="fld"><label>계좌</label><input id="f_acct" placeholder="예: 우리은행/1005-…((주)코네트)"></div>
      <div class="sep">기타</div>
      <div class="fld full"><label>비고</label><textarea id="f_remark" rows="2"></textarea></div>
    </div>
    <div class="mf">
      <button class="btn" onclick="vmClose()">취소</button>
      <button class="btn btn-teal" onclick="vmSave()">💾 저장</button>
    </div>
  </div>
</div>

<script>
var CTX='${pageContext.request.contextPath}';
/* 목록은 페이지 버튼 없이 **스크롤로 이어서** 나온다 (2026-08-03 요청).
   _shown = 지금까지 그려 둔 줄 수. 바닥 가까이 내려가면 CHUNK 만큼 더 그린다.
   ★한 번에 전부 그리지 않는 이유 — 거래처가 400여 종이고 여기에 뱃지·이벤트가 붙어
     통째로 그리면 첫 표시가 눈에 띄게 느려진다. */
var LIST=[], _view=[], _shown=0, PAGE=20, CHUNK=40, _bycd={}, _gb='';
/* 물류센터 ↔ 삼성웰스토리 지점 거래처 (발주현황표 DC_CD 와 1:1 — 재업로드 시 자동 부여) */
var DC_MAP={ '00273':'E100', '00275':'E200', '00274':'E300', '00276':'E400', '00272':'E500', '00277':'E600', '00278':'E700' };

function toast(s){ if(window.Swal){ Swal.fire({toast:true,position:'top-end',html:s,showConfirmButton:false,timer:3000,timerProgressBar:true}); } }
function swConfirm(msg,title){ if(window.Swal) return Swal.fire({title:title||'확인',html:msg,icon:'question',showCancelButton:true,confirmButtonText:'확인',cancelButtonText:'취소',confirmButtonColor:'#137a6c',cancelButtonColor:'#94a3b8'}).then(function(r){return r.isConfirmed;}); return Promise.resolve(confirm((''+msg).replace(/<br\s*\/?>/gi,'\n'))); }
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function gv(id){ return (document.getElementById(id).value||'').trim(); }

function vmLoad(){
  fetch(CTX+'/vendor/selectVendorMst.do', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, credentials:'same-origin', body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){ LIST=(j&&j.data)||[]; _bycd={}; LIST.forEach(function(o){ _bycd[o.vendorCd]=o; }); vmFilter(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function vmTab(g){
  _gb=g;
  Array.prototype.forEach.call(document.querySelectorAll('#gbTabs .t'), function(b){ b.classList.toggle('on', b.getAttribute('data-g')===g); });
  vmFilter();
}
function vmFilter(){
  var q=(document.getElementById('q').value||'').trim().toLowerCase();
  _view=LIST.filter(function(o){
    if(_gb && (''+(o.vendorGb||'')).indexOf(_gb)<0) return false;
    if(!q) return true;
    return [o.vendorCd,o.vendorNm,o.fullNm,o.alias,o.bizno,o.ceoNm].some(function(v){ return (''+(v||'')).toLowerCase().indexOf(q)>=0; });
  });
  _shown=0;
  var _c=document.getElementById('listCard'); if(_c) _c.scrollTop=0;   // 새로 거른 목록은 맨 위부터 본다
  vmRender();
}
function vmRender(){
  var tot=_view.length;
  if(_shown<PAGE) _shown=PAGE;
  if(_shown>tot) _shown=tot;
  document.getElementById('cnt').textContent=tot.toLocaleString()+'건 / 전체 '+LIST.length.toLocaleString()+'건';
  var tb=document.getElementById('tb'); _selReset();
  if(!tot){ tb.innerHTML='<tr><td colspan="11" class="empty">데이터가 없습니다.</td></tr>'; _info(0,0); vmFit(); return; }
  var GB_COLOR={ '매입':'#a85700', '매출':'#2e7d32', '매입&매출':'#137a6c' };
  tb.innerHTML=_view.slice(0,_shown).map(function(o){
    var c=GB_COLOR[o.vendorGb]||'#5a6b7a';
    return '<tr data-cd="'+esc(o.vendorCd)+'" onclick="vmSel(this,\''+esc(o.vendorCd)+'\')" ondblclick="vmOpen(\''+esc(o.vendorCd)+'\')">'
      +'<td class="code">'+esc(o.vendorCd)+'</td><td class="nm">'+esc(o.vendorNm)+'</td><td>'+esc(o.alias)+'</td>'
      +'<td><span class="gb" style="background:'+c+'">'+esc(o.vendorGb||'-')+'</span></td>'
      +'<td>'+esc(o.bizno)+'</td><td>'+esc(o.ceoNm)+'</td><td>'+esc(o.mgrNm)+'</td>'
      +'<td>'+esc(o.hp)+'</td><td>'+esc(o.tel)+'</td><td>'+esc(o.vatGb)+'</td>'
      +'<td>'+(o.dcCd?('<span class="dc">'+esc(o.dcCd)+'</span>'):'')+'</td>'
    +'</tr>';
  }).join('');
  _info(_shown, tot);
  vmFit();
}


/* ── 목록 높이 자동 맞춤 ───────────────────────────────────────────
   ① 목록 카드를 창 아래(페이징 위)까지 늘리고, 그 안에서 스크롤하게 한다.
   ② 늘어난 높이에 맞춰 **한 쪽에 담는 줄 수(PAGE)** 도 다시 잡는다 —
      높이만 늘리면 20줄 밑이 그대로 비어 요청한 '빈 공간까지 쓰기' 가 안 된다.
   ★위치는 반드시 '문서 기준'(rect.top + scrollY)으로 잰다. 화면 기준으로 재면
     스크롤할 때마다 값이 달라져 높이가 계속 자라는 자가증식이 된다(마감업로드에서 겪은 함정). */
var _fitting = false;
function vmFit(){
  if (_fitting) return; _fitting = true;
  try {
    var card = document.getElementById('listCard'), pg = document.getElementById('pager');
    if (!card) return;
    var top = card.getBoundingClientRect().top + (window.pageYOffset || 0);
    var pgH = pg ? (pg.offsetHeight + 10) : 0;
    var h = Math.max(220, Math.floor(window.innerHeight - top - pgH - 14));
    card.style.height = h + 'px';

    /* 한 줄 높이는 실제로 그려진 줄에서 잰다(글꼴·배율마다 다르다). 없으면 30px 로 본다. */
    var tr = card.querySelector('tbody tr'), th = card.querySelector('thead');
    var rowH = (tr && tr.offsetHeight) || 30, headH = (th && th.offsetHeight) || 34;
    var fit = Math.max(10, Math.floor((h - headH) / rowH));
    if (fit !== PAGE) { PAGE = fit; if (_shown < PAGE) { vmRender(); } }   // 첫 화면이 꽉 차게(가드가 되돌이를 막는다)
    _bindScroll();
    /* 창을 키워 목록이 스크롤 없이 다 들어오면, 스크롤 이벤트가 안 오므로 여기서 더 채운다 */
    if (_shown < _view.length && card.scrollHeight <= card.clientHeight + 4) {
      _shown = Math.min(_shown + CHUNK, _view.length); vmRender();
    }
  } finally { _fitting = false; }
}
window.addEventListener('resize', function(){ clearTimeout(window._fitT); window._fitT = setTimeout(vmFit, 120); });
var _sel=null;
function _selReset(){ _sel=null; }
function vmSel(tr,cd){
  var tb=document.getElementById('tb');
  Array.prototype.forEach.call(tb.querySelectorAll('tr.sel'),function(r){ r.classList.remove('sel'); });
  tr.classList.add('sel'); _sel=cd;
}
function vmEditSel(){ if(!_sel){ toast('⚠️ 수정할 행을 먼저 선택하세요.'); return; } vmOpen(_sel); }
function vmDelSel(){ if(!_sel){ toast('⚠️ 삭제할 행을 먼저 선택하세요.'); return; } vmDel(_sel); }
/* 페이지 버튼을 없앤 자리 — 지금 몇 줄까지 보고 있는지와 [모두 표시]만 남긴다.
   (다른 화면의 목록과 같은 방식이라 조작이 눈에 익다) */
function _info(shown, tot){
  var el=document.getElementById('pager'); if(!el) return;
  if(!tot){ el.innerHTML=''; return; }
  el.innerHTML = shown>=tot
    ? '<span class="pgnote">전체 <b>'+tot.toLocaleString()+'</b>건을 모두 보고 있습니다</span>'
    : '<span class="pgnote"><b>'+shown.toLocaleString()+'</b> / '+tot.toLocaleString()+'건 — 아래로 스크롤하면 이어서 나옵니다</span>'
      + '<button onclick="vmShowAll()">모두 표시</button>';
}
function vmShowAll(){ _shown=_view.length; vmRender(); }

/* 목록 바닥 가까이 내려가면 이어서 그린다. 카드가 스크롤 영역이라 여기에 건다.
   ★목록을 다시 그려도 이벤트가 살아 있도록 카드(고정 요소)에 한 번만 건다. */
function _bindScroll(){
  var card=document.getElementById('listCard'); if(!card || card._bound) return;
  card._bound = true;
  card.addEventListener('scroll', function(){
    if (_shown >= _view.length) return;
    if (card.scrollTop + card.clientHeight >= card.scrollHeight - 80) {
      _shown = Math.min(_shown + CHUNK, _view.length);
      vmRender();
    }
  });
}
function _set(id,v){ document.getElementById(id).value=(v==null?'':v); }
function vmOpen(cd){
  var o=cd?_bycd[cd]:null;
  document.getElementById('ovTit').textContent=o?('거래처 수정 — '+o.vendorCd):'거래처 추가';
  _set('f_cd',o?o.vendorCd:''); document.getElementById('f_cd').readOnly=!!o;
  _set('f_gb',o?(o.vendorGb||'매입'):'매입');
  _set('f_nm',o?o.vendorNm:''); _set('f_full',o?o.fullNm:''); _set('f_alias',o?o.alias:'');
  _set('f_bizno',o?o.bizno:''); _set('f_ceo',o?o.ceoNm:''); _set('f_cond',o?o.bizCond:''); _set('f_item',o?o.bizItem:'');
  _set('f_mgrcd',o?o.mgrCd:''); _set('f_mgrnm',o?o.mgrNm:''); _set('f_zip',o?o.zipcd:''); _set('f_dc',o?o.dcCd:'');
  _set('f_addr',o?o.addr:''); _set('f_addr2',o?o.addr2:'');
  _set('f_hp',o?o.hp:''); _set('f_tel',o?o.tel:''); _set('f_fax',o?o.fax:''); _set('f_email',o?o.email:'');
  _set('f_taxbill',o?(o.taxbillGb||''):''); _set('f_vat',o?(o.vatGb||''):''); _set('f_acct',o?o.bankAcct:''); _set('f_remark',o?o.remark:'');
  document.getElementById('ov').classList.add('on');
  // 창을 열면 곧바로 칠 수 있게(2026-08-04) — 추가는 거래처코드부터, 수정은 코드가 잠겨 있으니 거래처명부터
  var first=document.getElementById(o?'f_nm':'f_cd');
  setTimeout(function(){ if(first){ first.focus(); if(first.select) first.select(); } }, 0);
}
function vmClose(){ document.getElementById('ov').classList.remove('on'); }
function vmDto(){
  return { vendorCd:gv('f_cd'), vendorNm:gv('f_nm')||null, fullNm:gv('f_full')||null, alias:gv('f_alias')||null,
    vendorGb:gv('f_gb')||null, bizno:gv('f_bizno')||null, ceoNm:gv('f_ceo')||null,
    bizCond:gv('f_cond')||null, bizItem:gv('f_item')||null, mgrCd:gv('f_mgrcd')||null, mgrNm:gv('f_mgrnm')||null,
    zipcd:gv('f_zip')||null, dcCd:gv('f_dc')||null, addr:gv('f_addr')||null, addr2:gv('f_addr2')||null,
    hp:gv('f_hp')||null, tel:gv('f_tel')||null, fax:gv('f_fax')||null, email:gv('f_email')||null,
    taxbillGb:gv('f_taxbill')||null, vatGb:gv('f_vat')||null, bankAcct:gv('f_acct')||null, remark:gv('f_remark')||null };
}
function vmSave(){
  var dto=vmDto();
  if(!dto.vendorCd){ toast('⚠️ 거래처코드를 입력하세요.'); return; }
  if(!dto.vendorNm){ toast('⚠️ 거래처명을 입력하세요.'); return; }
  var isEdit=document.getElementById('f_cd').readOnly;
  fetch(CTX+(isEdit?'/vendor/updateVendorMst.do':'/vendor/insertVendorMst.do'),
    { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(dto) })
    .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
    .then(function(r){ if(!r.ok){ toast('⚠️ '+((r.t||'').trim()||'저장 실패')); return; } vmClose(); toast(isEdit?'💾 수정 완료':'＋ 등록 완료'); vmLoad(); })
    .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
}
function vmDel(cd){
  var o=_bycd[cd]; if(!o) return;
  swConfirm('['+esc(o.vendorCd)+'] '+esc(o.vendorNm||'')+'<br>삭제(미사용 처리)하시겠습니까?<br><span style="color:#9aa7b3;font-size:12px">완전 삭제가 아니라 미사용(ACTION_YN=N) 처리라 이력은 남습니다.</span>','거래처 삭제')
  .then(function(ok){ if(!ok) return;
    fetch(CTX+'/vendor/deleteVendorMst.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify({vendorCd:cd}) })
      .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
      .then(function(r){ if(!r.ok){ toast('⚠️ 삭제 실패'); return; } toast('🗑️ 삭제(미사용) 완료'); vmLoad(); });
  });
}

/* ---- 거래처리스트.xls 재업로드 ----
   · 이 파일은 확장자만 .xls 이고 실제로는 HTML 표(40컬럼)다. DOMParser 로 읽는다.
   · 같은 코드가 거래유형/담당자별로 여러 줄인 비정규화 → 코드 기준 병합(거래유형은 합집합, 나머지는 첫 값)
   · 서버에서 코드별 MERGE upsert (있으면 갱신, 없으면 신규. 삭제는 안 함) */
function vmUpload(input){
  var f=input.files && input.files[0]; if(!f) return;
  var rd=new FileReader();
  rd.onload=function(e){
    try{
      var doc=new DOMParser().parseFromString(e.target.result,'text/html');
      var tables=doc.querySelectorAll('table'), target=null, hi={};
      Array.prototype.forEach.call(tables, function(tb){
        if(target) return;
        var tr0=tb.querySelector('tr'); if(!tr0) return;
        var heads=Array.prototype.map.call(tr0.querySelectorAll('td,th'), function(c){ return (c.textContent||'').replace(/\s+/g,' ').trim(); });
        if(heads.indexOf('코드')>=0 && heads.indexOf('거래처명')>=0){ target=tb; heads.forEach(function(h,i){ hi[h]=i; }); }
      });
      if(!target){ toast('⚠️ 거래처 표(코드·거래처명 헤더)를 찾지 못했습니다.'); input.value=''; return; }
      function cell(tds,name){ var i=hi[name]; if(i==null||!tds[i]) return ''; return (tds[i].textContent||'').replace(/\s+/g,' ').trim(); }
      var raw=[];
      Array.prototype.slice.call(target.querySelectorAll('tr'),1).forEach(function(tr){
        var tds=tr.querySelectorAll('td'); if(tds.length<10) return;
        var cd=cell(tds,'코드'); if(!cd) return;
        raw.push({ cd:cd, nm:cell(tds,'거래처명'), full:cell(tds,'정식명칭'), alias:cell(tds,'별칭'),
          ceo:cell(tds,'대표자명'), gb:cell(tds,'거래유형'), cond:cell(tds,'업태'), item:cell(tds,'종목'),
          mgrCd:cell(tds,'담당자코드'), mgrNm:cell(tds,'담당자명'), typeCd:cell(tds,'유형코드'), typeNm:cell(tds,'유형명'),
          areaCd:cell(tds,'지역코드'), areaNm:cell(tds,'지역명'), zip:cell(tds,'우편번호'),
          addr:cell(tds,'주소'), addr2:cell(tds,'상세주소'), email:cell(tds,'이메일'),
          hp:cell(tds,'연락처'), tel:cell(tds,'전화'), fax:cell(tds,'팩스'),
          taxbill:cell(tds,'계산서발행'), vat:cell(tds,'부가세'), acct:cell(tds,'계좌'),
          bizno:cell(tds,'사업자번호'), regDt:cell(tds,'등록일'),
          rm:[cell(tds,'비고1'),cell(tds,'비고2'),cell(tds,'비고3')].filter(function(x){return x;}).join(' / ') });
      });
      if(!raw.length){ toast('⚠️ 데이터 행이 없습니다.'); input.value=''; return; }
      // 코드 기준 병합 — 거래유형은 합집합, 나머지는 비어있지 않은 첫 값
      var g={}, order=[];
      raw.forEach(function(r){ if(!g[r.cd]){ g[r.cd]=[]; order.push(r.cd); } g[r.cd].push(r); });
      function pick(L,k){ for(var i=0;i<L.length;i++){ if(L[i][k]) return L[i][k]; } return null; }
      var rows=order.map(function(cd){
        var L=g[cd], s={};
        L.forEach(function(r){ (r.gb||'').split('&').forEach(function(x){ x=x.trim(); if(x) s[x]=1; }); });
        var gb=Object.keys(s).length>1?'매입&매출':(Object.keys(s)[0]||null);
        var rd8=(pick(L,'regDt')||'').replace(/[^0-9]/g,'').slice(0,8);
        return { vendorCd:cd, vendorNm:pick(L,'nm'), fullNm:pick(L,'full'), alias:pick(L,'alias'), ceoNm:pick(L,'ceo'),
          vendorGb:gb, bizCond:pick(L,'cond'), bizItem:pick(L,'item'), mgrCd:pick(L,'mgrCd'), mgrNm:pick(L,'mgrNm'),
          typeCd:pick(L,'typeCd'), typeNm:pick(L,'typeNm'), areaCd:pick(L,'areaCd'), areaNm:pick(L,'areaNm'),
          zipcd:pick(L,'zip'), addr:pick(L,'addr'), addr2:pick(L,'addr2'), email:pick(L,'email'),
          hp:pick(L,'hp'), tel:pick(L,'tel'), fax:pick(L,'fax'), bizno:pick(L,'bizno'), bankAcct:pick(L,'acct'),
          taxbillGb:pick(L,'taxbill'), vatGb:pick(L,'vat'), regDt:(rd8.length===8?rd8:null),
          dcCd:DC_MAP[cd]||null, remark:pick(L,'rm') };
      });
      swConfirm('거래처 <b>'+rows.length+'</b>종을 반영하시겠습니까?<br>(원본 '+raw.length+'행 → 코드 기준 병합)<br>'
        +'<span style="color:#9aa7b3;font-size:12px">이미 있는 코드는 갱신, 없는 코드는 신규 등록됩니다. 삭제는 하지 않습니다.</span>','거래처리스트 재업로드')
      .then(function(ok){ if(!ok){ input.value=''; return; }
        fetch(CTX+'/vendor/uploadVendorMst.do', { method:'POST', headers:{'Content-Type':'application/json'}, credentials:'same-origin', body:JSON.stringify(rows) })
          .then(function(res){ return res.text().then(function(t){ return {ok:res.ok,t:t}; }); })
          .then(function(r){ if(!r.ok){ toast('⚠️ 업로드 실패: '+(r.t||'')); return; } toast('📤 재업로드 완료 — <b>'+r.t+'</b>종 반영'); vmLoad(); })
          .catch(function(e){ toast('⚠️ 통신오류: '+e.message); });
        input.value='';
      });
    }catch(err){ toast('⚠️ 파일 처리 오류: '+err.message); input.value=''; }
  };
  rd.readAsText(f,'UTF-8');   // 파일이 UTF-8 HTML 임을 확인함 (charset=utf-8 선언)
}

function vmExcel(){
  var list=_view; if(!list.length){ toast('⚠️ 출력할 데이터가 없습니다.'); return; }
  var head=['코드','거래처명','정식명칭','별칭','거래유형','사업자번호','대표자','업태','종목','담당자','연락처','전화','팩스','이메일','우편번호','주소','상세주소','계산서발행','부가세','계좌','물류센터','비고'];
  var aoa=[head].concat(list.map(function(o){ return [o.vendorCd,o.vendorNm,o.fullNm,o.alias,o.vendorGb,o.bizno,o.ceoNm,o.bizCond,o.bizItem,o.mgrNm,o.hp,o.tel,o.fax,o.email,o.zipcd,o.addr,o.addr2,o.taxbillGb,o.vatGb,o.bankAcct,o.dcCd,o.remark]; }));
  var P=window.parent;
  function byLib(LIB){ var ws=LIB.utils.aoa_to_sheet(aoa); var wb=LIB.utils.book_new(); LIB.utils.book_append_sheet(wb,ws,'거래처'); LIB.writeFile(wb,'매입매출거래처.xlsx'); toast('📥 엑셀 저장 완료 · '+list.length+'건'); }
  try{ if(P && P.ssLoadStyleXlsx){ P.ssLoadStyleXlsx(function(XS){ var LIB=XS||P.XLSX; if(LIB){ byLib(LIB); } else { csv(); } }); return; } }catch(e){}
  if(P && P.XLSX){ byLib(P.XLSX); return; }
  csv();
  function csv(){ var c=aoa.map(function(r){ return r.map(function(x){ x=(x==null?'':(''+x)); return '"'+x.replace(/"/g,'""')+'"'; }).join(','); }).join('\r\n');
    var b=new Blob(['﻿'+c],{type:'text/csv;charset=utf-8'}), a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download='매입매출거래처.csv'; document.body.appendChild(a); a.click(); a.remove(); toast('📥 CSV 저장 완료'); }
}
/* ══════════════════════════════════════════════════════════════════════════
   키보드 편의 (2026-08-04 요청) — 상품코드 등록(prodcd.jsp)과 같은 규칙
     목록 : 진입 시 검색칸 포커스 · ↑↓ 줄 이동 · Enter 수정 · Alt+N 추가
     창   : Enter 다음 칸(마지막 칸에서는 저장) · Ctrl+S 저장 · Esc 닫기
   ══════════════════════════════════════════════════════════════════════════ */
function vmOvOpen(){ return document.getElementById('ov').classList.contains('on'); }
/* 창 안 이동 순서 = 화면에 보이는 순서(격자라 DOM 순서와 같다). 비고(textarea)는 줄바꿈이 필요해 뺀다 */
var VM_FLOW=['f_cd','f_gb','f_vat','f_nm','f_taxbill','f_full','f_alias','f_bizno',
             'f_ceo','f_cond','f_item','f_mgrcd','f_mgrnm','f_dc',
             'f_hp','f_tel','f_fax','f_email','f_zip','f_addr','f_addr2','f_acct'];
function vmNext(id){
  var i=VM_FLOW.indexOf(id); if(i<0) return null;
  for(var k=i+1;k<VM_FLOW.length;k++){
    var el=document.getElementById(VM_FLOW[k]);
    if(el && !el.readOnly && !el.disabled) return el;      // 수정 시 잠긴 거래처코드 같은 칸은 건너뛴다
  }
  return null;                                             // 마지막 칸 = 저장
}
document.getElementById('ov').addEventListener('keydown', function(e){
  if(e.key!=='Enter') return;
  var t=e.target; if(!t || VM_FLOW.indexOf(t.id)<0) return;   // 비고는 여기 없어 줄바꿈이 그대로 된다
  e.preventDefault();
  var nx=vmNext(t.id);
  if(nx){ nx.focus(); if(nx.select) nx.select(); }
  else vmSave();                                           // 계좌 칸에서 Enter = 저장
});
document.addEventListener('keydown', function(e){
  if((e.ctrlKey||e.metaKey) && (e.key==='s'||e.key==='S')){
    if(vmOvOpen()){ e.preventDefault(); vmSave(); }
    return;
  }
  if(e.altKey && (e.key==='n'||e.key==='N')){ e.preventDefault(); vmOpen(); return; }
  if(e.key==='Escape' && vmOvOpen()){ e.preventDefault(); vmClose(); return; }
  if(vmOvOpen()) return;                                   // 창이 떠 있으면 아래 목록 조작은 안 한다

  // 검색칸(#q)에서는 그대로 먹힌다 — 검색어 치고 ↓ 로 바로 결과로 내려가라고
  var t=e.target, tag=(t&&t.tagName||'').toUpperCase();
  if((tag==='INPUT'||tag==='SELECT'||tag==='TEXTAREA') && t.id!=='q') return;
  if(e.key==='ArrowDown'){ e.preventDefault(); vmRowMove(1); }
  else if(e.key==='ArrowUp'){ e.preventDefault(); vmRowMove(-1); }
  else if(e.key==='Enter'){
    if(!_sel){ vmRowMove(1); return; }                     // 아직 고른 줄이 없으면 첫 줄부터
    e.preventDefault(); vmOpen(_sel);
  }
});
/* ↑↓ 행 이동 — 이 화면은 스크롤로 이어 그리는 목록이라, 끝줄에서 더 내려가면 다음 묶음을 먼저 그린다.
   ★vmRender 가 _selReset() 을 하므로 다시 그린 뒤에 vmSel 로 잡아 준다(순서를 바꾸면 선택이 풀린다). */
function vmRowMove(d){
  var tb=document.getElementById('tb');
  var rows=Array.prototype.slice.call(tb.querySelectorAll('tr[data-cd]'));
  if(!rows.length) return;
  var i=-1;
  if(_sel) for(var k=0;k<rows.length;k++){ if(rows[k].getAttribute('data-cd')===_sel){ i=k; break; } }
  var n=(i<0) ? (d>0?0:rows.length-1) : i+d;
  if(n>=rows.length){
    if(_shown<_view.length){                               // 아직 안 그린 줄이 남아 있으면 이어서 그린다
      _shown=Math.min(_shown+CHUNK, _view.length); vmRender();
      rows=Array.prototype.slice.call(tb.querySelectorAll('tr[data-cd]'));
    }
    if(n>=rows.length) n=rows.length-1;                    // 맨 끝이면 제자리
  }
  if(n<0) n=0;
  var tr=rows[n]; if(!tr) return;
  vmSel(tr, tr.getAttribute('data-cd'));
  if(tr.scrollIntoView) tr.scrollIntoView({block:'nearest'});
}

vmLoad();
/* 진입하면 검색칸에 커서 — 이름을 쳐서 찾는 것이 이 화면의 첫 동작이다 */
(function(){ var q=document.getElementById('q'); if(q) q.focus(); })();
</script>
</body>
</html>
