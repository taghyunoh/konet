<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>재고 변동 확인</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script><script>window.stkChkCfg={ ctx:'${pageContext.request.contextPath}', admin:false, after:null };</script><script src="${pageContext.request.contextPath}/asset/js/stock-chk-act.js?v=20261126b"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<!--
  재고 변동 확인 (2026-11-26 신설 · 같은 날 오후 2판) — 재고 관리 ▸ 재고 변동 확인. 셸 iframe(logiFrame).
  사용자 「재고담당자가 입고·판매 관련 내용을 보고 재고에 반영할지, 적용 안 할지 관리하게 필요하지 않을까요」 → 「반영 후 확인 방식으로 진행해줘」
    · 손으로 넣는 전표(매입·판매 — 반품은 그 전표의 줄)는 지금처럼 저장·삭제하는 순간 재고에 반영된다. 정산서·발주현황표 자동 출고는 여기 없다.
    · 이 화면은 그 전표를 «작업한 때»(넣거나 고치거나 지운 때) 순으로 모아 보여 주고, 담당자가 전표를 [확인] 하거나 품목마다 [재고 미적용] 한다.
  2판 (사용자 「풀어서 보여주고 · 삭제한 것은 … 재고에서 제외 여부 있어야 250 재고로 포함 나옴 · 재고제외, 재고제외취소 등도 필요 · 전표일자가 아니고 작업한 일자 기준」
       · 「검색도 세부코드 검색가능하게」 · 「변경이력 년도도 표시되게」 · 「재고적용, 재고 미적용 으로」) :
    · 품목 줄을 처음부터 펼쳐 보인다(목록과 함께 받는다 — lines). [품목 줄 접기]로 접는다. 찾기는 품목코드·품목명까지.
    · 처리는 «품목 단위» — 줄마다 [재고 미적용] / [재고 적용]. 전표 줄의 [전체 미적용] 은 그 전표의 품목 전부. (말 = 재고 적용 · 재고 미적용 — 「제외」 라는 말은 안 쓴다)
    · 지운 전표도 재고 미적용할 수 있다 = «삭제를 재고에 적용하지 않는다» → 지워서 빠진 수량이 재고에 다시 들어간다(판매는 다시 빠진다).
      그래서 「재고 영향」 은 그 «작업»이 재고에 미친 수량이다 — 지운 전표는 부호가 반대(매입을 지우면 −).
    · 맨 앞 칸 = 작업한 때(연도까지) · 작업한 사람. 전표 일자는 뒤 칸.
    - 확인 = 실물도 그렇게 움직였다(재고 그대로). 누구나.   - 재고 미적용 / 재고 적용 = 재고가 바뀐다 — 관리자만 · 미적용은 사유 필수.
    - 전표를 확인한 뒤에 누가 또 고치거나 지우면 다시 «미확인» 으로 돌아온다(verDttm < evDttm). 미적용은 전표를 고쳐도 유지.
    · 「시작 전」 = 이 기능을 켠 때(startDttm · DDL 을 처음 돌린 때)보다 앞선 작업 — 볼 수 있고 처리도 되지만 미확인 숫자에 안 든다.
  자료 /prod/stockChkList.do(목록 data + 품목 줄 lines) · 처리 /prod/stockChkAct.do {items:[{refGb, refSeq, prodSeq}], act C|X|U, memo}.
  ★수정재고가 고정(🔒)된 품목의 «맞춘 날짜보다 앞» 전표는 미적용해도 현재고가 그대로다 — 처리 결과에 「현재고 그대로」 로 나온다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:12px 11px 12px; height:100vh; display:flex; flex-direction:column; }
  .wrap > *{ flex:0 0 auto; }
  h2{ margin:0 0 6px; font-size:20px; }
  .help{ font-size:12.5px; color:#5b6b7a; margin:0 0 8px; line-height:1.6; }
  .bar{ display:flex; gap:7px; align-items:center; flex-wrap:wrap; margin-bottom:8px; }
  .bar input[type=text], .bar input[type=date], .bar select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13.5px; background:#fff; }
  .bar .lab{ font-size:13px; color:#37475a; font-weight:700; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 13px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); }
  .btn:disabled{ opacity:.5; cursor:default; }
  .btn.sm{ height:28px; padding:0 9px; font-size:12.5px; }
  .btn.xs{ height:24px; padding:0 8px; font-size:12px; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); }
  .btn-warn{ background:#fff4e5; color:#9a5a00; border-color:#f0cf9a; }
  .btn-blue{ background:#e8f1fb; color:#1b4f86; border-color:#b9d2ee; }
  .cnt{ margin-left:auto; color:#37475a; font-size:13px; font-weight:700; background:#eef4f2; border:1px solid #cfe0da; border-radius:14px; padding:5px 12px; white-space:nowrap; }
  .cnt b{ color:var(--red); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; overflow:auto; flex:1 1 auto !important; min-height:150px; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g thead{ position:sticky; top:0; z-index:2; }
  table.g th{ background:#d9edf7; color:#1f2a37; font-weight:700; font-size:12.5px; border:1px solid #9fb6c3; padding:6px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border:1px solid #c9d3dc; padding:5px 7px; text-align:center; white-space:nowrap; }
  table.g td.l{ text-align:left; white-space:normal; word-break:break-all; }
  table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  /* 전표(대표) 줄 — 품목 줄과 한눈에 갈리게 (2026-11-26 사용자 「대표구분되게」) : 청록 바탕 · 굵은 글 · 위 굵은 선. 품목 줄 묶음은 흰 바탕 + 왼쪽 청록 띠 */
  table.g tbody tr.row{ cursor:pointer; }
  table.g tbody tr.row > td{ background:#e3f1ee; font-weight:700; border-top:2px solid #6fa89d; border-bottom:1px solid #9fc4bc; padding-top:7px; padding-bottom:7px; }
  table.g tbody tr.row:hover > td{ background:#d5ebe6; }
  table.g tr.row.old > td{ background:#edf1f3; color:#5f6d7a; border-top-color:#a9b6c1; border-bottom-color:#c3ccd4; }
  table.g tr.row.old:hover > td{ background:#e3e9ed; }
  table.g tr.row.del td.vn{ text-decoration:line-through; text-decoration-color:#c9a1a1; }
  .bd{ display:inline-block; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:800; white-space:nowrap; }
  .bd.new{ background:#e3eefb; color:#1b4f86; } .bd.mod{ background:#fff1dc; color:#a3570a; } .bd.del{ background:#fdecea; color:#b03a2e; }
  .bd.pu{ background:#eef4f2; color:#0f6b5e; } .bd.sa{ background:#f2eefa; color:#5b3fa0; }
  .st{ display:inline-block; padding:2px 9px; border-radius:10px; font-size:12px; font-weight:800; white-space:nowrap; }
  .st.P{ background:#fdecea; color:#b03a2e; } .st.C{ background:#e6f4ea; color:#1d7a3a; } .st.X{ background:#eceff1; color:#4a5866; border:1px dashed #9aa7b3; } .st.O{ background:#f1f3f5; color:#8a97a4; }
  .sub{ font-size:11.5px; color:#8a97a4; }
  .up{ color:#1b6fb0; font-weight:700; } .dn{ color:#c0392b; font-weight:700; }
  .off{ text-decoration:line-through; color:#9aa7b3 !important; font-weight:400 !important; }
  .empty{ text-align:center; color:#8a97a4; padding:26px 10px; line-height:1.8; }
  tr.lines > td{ background:#fff; padding:6px 10px 10px 40px; text-align:left; border-left:5px solid #6fa89d; }
  .legend{ font-size:12.5px; color:#37475a; margin:0 0 8px; line-height:1.9; background:#fff; border:1px solid var(--bd); border-radius:8px; padding:5px 10px; }
  .legend .st{ margin-right:3px; }
  .legend i{ font-style:normal; color:#5b6b7a; margin-right:12px; }
  table.ln{ border-collapse:collapse; font-size:12.5px; background:#fff; }
  table.ln th{ background:#eef2f5; border:1px solid #d5dde5; padding:4px 8px; font-weight:700; white-space:nowrap; }
  table.ln td{ border:1px solid #d5dde5; padding:4px 8px; white-space:nowrap; }
  table.ln td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.ln tr.x td{ background:#f7f8f9; }
  table.ln tr.hit td{ background:#fffbe6; }
  /* 재고수정 이전 전표 줄 (2026-11-26) — 회색 글 · 「재고수정 이전」 표 */
  table.ln tr.pre td{ color:#7d8a97; }
  .pre-tag{ display:inline-block; margin-left:4px; padding:0 6px; border-radius:9px; font-size:11px; font-weight:800; white-space:nowrap; background:#eef1f4; color:#55606c; border:1px solid #cfd8e3; }
  .pre-tag.fx{ background:#fdf3e1; color:#8a5a00; border-color:#ecd29a; }
  .pre-tag.aft{ background:#fdecea; color:#a6241c; border-color:#e7a9a3; }
  .btn.xs.lockb{ background:#f3f4f6; color:#6b7683; border:1px dashed #b9c0c9; }
  .pre-n{ display:inline-block; margin-left:4px; padding:0 6px; border-radius:9px; font-size:11px; font-weight:700; background:#eef1f4; color:#55606c; white-space:nowrap; }
  label.aft{ display:inline-flex; align-items:center; gap:4px; font-size:13px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
  .cd{ font-family:Consolas,monospace; font-size:12.5px; }
  /* 사유 입력 창 — 공통 알림창(ui-message)엔 입력칸이 없어 이 화면에 둔다(모양은 같은 흰 카드) */
  .rs-bd{ position:fixed; inset:0; background:rgba(15,23,32,.45); display:none; align-items:center; justify-content:center; z-index:9000; }
  .rs-box{ width:min(490px, calc(100vw - 30px)); background:#fff; border-radius:16px; padding:20px 20px 16px; box-shadow:0 18px 50px rgba(0,0,0,.25); }
  .rs-box h3{ margin:0 0 6px; font-size:16.5px; }
  .rs-box p{ margin:0 0 10px; font-size:13px; color:#5b6b7a; line-height:1.65; }
  .rs-chips{ display:flex; gap:6px; flex-wrap:wrap; margin-bottom:8px; }
  .rs-chips button{ border:1px solid var(--bd); background:#f6f8fa; border-radius:14px; padding:4px 11px; font-size:12.5px; cursor:pointer; font-weight:700; color:#37475a; }
  .rs-chips button:hover{ border-color:var(--teal); }
  .rs-box textarea{ width:100%; height:70px; border:1px solid var(--bd); border-radius:8px; padding:8px; font-size:13.5px; font-family:inherit; resize:vertical; }
  .rs-err{ color:var(--red); font-size:12.5px; min-height:18px; margin-top:4px; }
  .rs-act{ display:flex; gap:8px; justify-content:flex-end; margin-top:6px; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🔎 재고 변동 확인</h2>
  <div class="help">
    손으로 넣은 <b>매입·판매 전표</b>(반품 포함)는 저장하거나 지우는 순간 재고에 반영됩니다. 여기서 작업한 순서대로 보고
    실물도 그렇게 움직였으면 <b>[확인]</b>, 서류만 처리한 것이면 품목마다 <b>[재고 미적용]</b>(재고 수량에만 적용하지 않고 매입·매출 금액은 그대로)합니다.
    <b>지운 전표</b>를 재고 미적용하면 지워서 빠진 수량이 재고에 다시 들어갑니다. 확인한 뒤에 전표를 다시 고치거나 지우면 미확인으로 돌아옵니다. 정산서 자동 출고는 여기 나오지 않습니다.
  </div>
  <div class="legend" id="legend">
    <b>상태 뜻</b> &nbsp;
    <span class="st P">미확인</span><i>아직 아무도 확인하지 않은 작업</i>
    <span class="st C">확인</span><i>실물도 전표대로 움직였다고 확인함 — 재고 그대로</i>
    <span class="st X">재고 미적용</span><i>서류만 처리한 것 — 재고 수량에 적용하지 않음(금액은 그대로)</i>
    <span class="st O">시작 전</span><i id="lgStart">이 기능을 켜기 전에 한 작업 — 확인하지 않아도 되지만 할 수는 있습니다</i>
  </div>
  <div class="bar">
    <span class="lab">작업한 때</span>
    <input type="date" id="frDt"> ~ <input type="date" id="toDt">
    <button class="btn sm" onclick="setRange('d0')">오늘</button>
    <button class="btn sm" onclick="setRange('d7')">7일</button>
    <button class="btn sm" onclick="setRange('m0')">이번 달</button>
    <select id="fGb" onchange="render()" title="매입 · 판매 = 그 전표 종류 / 삭제 = 지운 전표(매입·판매) / 반품 = 반품·불량반품 줄이 있는 전표"><option value="">구분 전체</option><option value="PURCH">매입</option><option value="SALE">판매</option><option value="DEL">삭제</option><option value="RTN">반품</option></select>
    <select id="fSt" onchange="render()"><option value="P">미확인 · 시작 전</option><option value="C">확인</option><option value="X">재고 미적용</option><option value="">전체</option></select>
    <label class="aft" title="품목마다 «가장 최근 재고수정을 저장한 뒤에» 넣거나 고치거나 지운 것만 봅니다 — 재고수정 전에 한 작업은 숨깁니다. 재고수정 뒤에 앞 날짜 전표를 바꾼 것(실사 숫자를 흔든 것)도 여기 나옵니다. 재고수정을 한 적 없는 품목은 그대로 보입니다."><input type="checkbox" id="fAft" onchange="aftSave(); render()">최종 재고수정 이후만</label>
    <input type="text" id="fQ" placeholder="거래처 · 품목코드 · 품목명 · 전표번호 · 사람" style="width:260px" oninput="render()">
    <button class="btn btn-teal" id="btnLoad" onclick="load()">조회</button>
    <button class="btn" id="btnBulk" onclick="bulkConfirm()">☑ 선택 확인</button>
    <button class="btn" id="btnFold" onclick="foldAll()">품목 줄 접기</button>
    <span class="cnt" id="cnt"></span>
  </div>
  <div class="card"><table class="g"><thead><tr>
    <th style="width:34px"><input type="checkbox" id="chkAll" onclick="chkAll(this.checked)" title="보이는 미확인 줄 모두 고르기"></th>
    <th title="전표를 넣거나 고치거나 지운 때 — 이 차례로 보입니다(전표 일자가 아닙니다)">작업한 때</th><th>작업한 사람</th><th>작업</th><th>구분</th><th>전표 (일자 / 번호)</th><th>거래처</th><th>품목</th>
    <th title="이 작업이 재고에 미친 수량 — 매입 +, 판매 −, 반품은 반대. 지운 전표는 지워서 빠진(돌아온) 수량이라 부호가 반대입니다. 재고 미적용한 품목은 빼고 셉니다">재고 영향</th><th>금액</th>
    <th>상태</th><th>처리</th>
  </tr></thead><tbody id="body"><tr><td class="empty" colspan="12">불러오는 중…</td></tr></tbody></table></div>
</div>

<div class="rs-bd" id="rsBd"><div class="rs-box">
  <h3>재고 미적용</h3>
  <p id="rsMsg"></p>
  <div class="rs-chips" id="rsChips"></div>
  <textarea id="rsMemo" maxlength="200" placeholder="재고에 적용하지 않는 사유 (꼭 적어 주세요)"></textarea>
  <div class="rs-err" id="rsErr"></div>
  <div class="rs-act"><button class="btn" onclick="rsClose()">취소</button><button class="btn btn-warn" id="rsOk" onclick="rsGo()">재고 미적용</button></div>
</div></div>

<script>
var CTX='${pageContext.request.contextPath}';
var PEND_ALL=null, ROWS=[], LMAP={}, ADMIN=false, START='', CLOSED={}, FOLD=false, _seq=0, _rsItem=null;
try{ FOLD=(localStorage.getItem('konetStockChkFold')==='1'); }catch(e){}
function esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return (Math.round(n(v)*100)/100).toLocaleString(); }
function sg(q){ return (q>0?'+':'')+fmt(q); }
function gv(id){ return (document.getElementById(id)||{}).value||''; }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function tm(s){ s=String(s||''); return s.length>=16 ? s.slice(0,16) : s; }   /* YYYY-MM-DD HH:mm — 연도까지 (2026-11-26 「변경이력 년도도 표시되게」) */
function key(r){ return r.refGb+':'+r.refSeq; }
function who(nm, id){ return esc(nm||id||''); }
function linesOf(r){ return LMAP[key(r)]||[]; }

/* 작업 = 등록 / 수정 / 삭제 · 상태 = P 미확인 / C 확인 / X 재고 미적용(전표 전체) / O 시작 전 */
function kindOf(r){ return (''+r.liveYn)!=='Y' ? 'del' : (r.updDttm ? 'mod' : 'new'); }
var KIND_NM={ 'new':'등록', mod:'수정', del:'삭제' };
function stOf(r){
  var s=(''+(r.chkState||'')).trim(), ev=''+(r.evDttm||''), ver=''+(r.verDttm||'');
  if(s==='X') return 'X';
  if(s==='C' && ver>=ev) return 'C';
  if(START && ev<START && s!=='C') return 'O';
  return 'P';
}
/* 품목 줄이 재고 미적용인가 — 전표 전체가 미적용이거나 그 품목만 미적용 */
function lineOff(r, x){ return (''+(r.chkState||'')).trim()==='X' || (''+(x.xState||'')).trim()==='X'; }
/* 그 작업이 재고에 미친 수량 — 지운 전표는 반대 부호 */
function effOf(r, x){ var q=n(x.stkQty); return kindOf(r)==='del' ? -q : q; }
/* 재고수정 이전 전표 줄인가 (2026-11-26) — 그 품목의 «지금 기준 가장 최근 재고수정»(x.adjDt) 날짜보다 전표 일자가 «앞» 이면 이전. 같은 날은 이후(수정재고 고정 조각과 같은 규칙).
   고정(🔒 adjFixYn Y)이면 현재고에 영향이 없고, 고정 전 재고수정이면 아직 현재고에 들어간다(운영 반영 뒤 재고 일괄조정을 다시 저장하면 고정). */
function preAdj(r, x){ var a=String((x && x.adjDt)||'').replace(/[^0-9]/g,'').slice(0,8), t=String((r && r.trxDt)||'').replace(/[^0-9]/g,'').slice(0,8); return a.length===8 && t.length===8 && t<a; }
function preMsg(ev, cd, td, ad){
  if(ev) ev.stopPropagation();
  window._alertBox('<b>재고 미적용·적용을 할 수 없습니다</b><div style="text-align:left;margin-top:8px;font-size:13px;line-height:1.75;color:#37475a">'
    +'품목 <b>'+esc(cd)+'</b> 은 <b>'+esc(ad)+'</b> 재고수정으로 맞춰 고정(🔒)됐고, 이 전표('+esc(td)+')는 그보다 <b>앞 날짜</b>입니다.<br>'
    +'실사로 이미 맞춘 구간이라 적용·미적용을 바꿔도 현재고가 바뀌지 않습니다.<br>현재고를 바꾸려면 <b>재고 일괄조정에서 재고수정을 다시</b> 하세요.</div>', { icon:'🔒' });
}
/* 최종 재고수정 «뒤에 작업한» 것인가 (2026-11-26 「최종재고수정이후로 나와야하느데 체크하면 안나옴」) — 작업한 때(evDttm) > 그 품목의 가장 최근 재고수정을 저장한 때(adjRegDttm).
   재고수정한 적 없는 품목은 늘 «뒤» 로 본다. 저장한 때를 못 받으면(옛 서버) 전표 일자로 대신 판정. */
function aftAdj(r, x){
  if(!x || !x.adjDt) return true;
  var ar=String(x.adjRegDttm||''), ev=String((r && r.evDttm)||'');
  if(ar && ev) return ev.slice(0,19) > ar.slice(0,19);
  return !preAdj(r, x);
}
function aftOn(){ var e=document.getElementById('fAft'); return !!(e && e.checked); }
function aftSave(){ try{ localStorage.setItem('konetStockChkAft', aftOn()?'1':'0'); }catch(e){} }
function sumOf(r){ var t=0, off=0, L=linesOf(r); L.forEach(function(x){ if(lineOff(r,x)) off++; else t+=effOf(r,x); }); return { q:t, off:off, n:L.length }; }
function stHtml(r){
  var s=stOf(r), h, so=sumOf(r);
  if(s==='X') h='<span class="st X" title="'+esc(r.chkMemo||'')+'">재고 미적용</span>'+(((''+(r.verDttm||''))<(''+(r.evDttm||'')))?'<div class="sub">미적용 뒤 전표가 바뀜</div>':'');
  else if(s==='C') h='<span class="st C">확인</span>';
  else if(s==='O') h='<span class="st O" title="이 기능을 켜기 전에 한 작업입니다 — 미확인 숫자에는 들어가지 않습니다">시작 전</span>';
  else h='<span class="st P">미확인</span>'+(((''+(r.chkState||'')).trim()==='C')?'<div class="sub">확인 뒤 전표가 바뀜</div>':'');
  if(s!=='X' && so.off) h+='<div class="sub">품목 '+so.off+'개 재고 미적용</div>';
  if((s==='X'||s==='C') && r.chkDttm) h+='<div class="sub">'+who(r.chkUserNm, r.chkUser)+' · '+esc(tm(r.chkDttm))+'</div>';
  if(s==='X' && r.chkMemo) h+='<div class="sub" style="max-width:170px;white-space:normal">'+esc(r.chkMemo)+'</div>';
  return h;
}
function actHtml(r){
  var s=stOf(r), k=esc(key(r)), h='';
  if(s==='P' || s==='O') h+='<button class="btn sm btn-teal" onclick="act(event,\''+k+'\',0,\'C\')">확인</button> ';
  if(s==='C') h+='<button class="btn sm" onclick="act(event,\''+k+'\',0,\'U\')" title="확인을 지우고 미확인으로 되돌립니다">확인 취소</button> ';
  if(s!=='X' && ADMIN && linesOf(r).length) h+='<button class="btn sm btn-warn" onclick="rsOpen(event,\''+k+'\',0)" title="이 전표의 품목 전부를 재고에 적용하지 않습니다(금액은 그대로)">전체 미적용</button>';
  if(s==='X') h+=ADMIN ? '<button class="btn sm btn-blue" onclick="act(event,\''+k+'\',0,\'U\')" title="다시 재고에 적용하고 미확인으로 되돌립니다">재고 적용</button>' : '<span class="sub">관리자만 되돌릴 수 있습니다</span>';
  return h;
}
function qTxt(r){ var a=[r.custNm, r.custCd, d10(r.trxDt)+'/'+r.trxNo, r.trxNo, r.regUserNm, r.regUser, r.updUserNm, r.updUser, r.remark];
  linesOf(r).forEach(function(x){ a.push(x.prodCd); a.push(x.prodNm); }); return a.join(' ').toLowerCase(); }
function view(){
  var gb=gv('fGb'), st=gv('fSt'), q=gv('fQ').trim().toLowerCase();
  return ROWS.filter(function(r){
    /* 구분 (2026-11-26 사용자 「매입, 판매, 삭제, 반품, 전체 구분추가」) — 매입·판매 = 전표 종류 · 삭제 = 지운 전표(종류 무관) · 반품 = 반품·불량반품 줄이 하나라도 있는 전표 */
    if(gb==='DEL'){ if(kindOf(r)!=='del') return false; }
    else if(gb==='RTN'){ if(!linesOf(r).some(function(x){ return /반품/.test(''+(x.trxGb||'')); })) return false; }
    else if(gb && r.refGb!==gb) return false;
    var s=stOf(r);
    if(st==='X'){ if(s!=='X' && !sumOf(r).off) return false; }      /* 재고 미적용 = 전표 전체 또는 품목이 하나라도 */
    else if(st==='P'){ if(s!=='P' && s!=='O') return false; }   /* 미확인 = 아직 확인 안 한 것 전부(시작 전 포함 — 2026-11-26 「전체로 보아야 조회됨」) */
    else if(st && s!==st) return false;
    if(q && qTxt(r).indexOf(q)<0) return false;
    if(aftOn()){ var L=linesOf(r); if(L.length && !L.some(function(x){ return aftAdj(r,x); })) return false; }   /* 최종 재고수정 이후만 — 품목이 전부 «재고수정 전에 한 작업» 이면 전표째 숨김 */
    return true;
  });
}
function render(){
  var v=view(), h='', pend=0, old=0, q=gv('fQ').trim().toLowerCase();
  ROWS.forEach(function(r){ var s=stOf(r); if(s==='P') pend++; else if(s==='O') old++; });
  if(!v.length) h='<tr><td class="empty" colspan="12">'+(ROWS.length?'조건에 맞는 전표가 없습니다.':'이 기간에 넣거나 바꾼 전표가 없습니다.')+'</td></tr>';
  v.forEach(function(r){
    var k=key(r), kd=kindOf(r), s=stOf(r), pu=(r.refGb==='PURCH'), L=linesOf(r), so=sumOf(r);
    var item=(L.length?esc(L[0].prodNm||''):'')+((L.length>1)?' <span class="sub">외 '+(L.length-1)+'</span>':'');
    var pn=L.filter(function(x){ return preAdj(r,x); }).length;
    var an=L.filter(function(x){ return preAdj(r,x) && aftAdj(r,x) && x.adjRegDttm; }).length;
    if(an) item+=' <span class="pre-n" style="background:#fdecea;color:#a6241c" title="재고수정을 저장한 뒤에 그보다 앞 날짜 전표를 작업한 품목 '+an+'개 — 실사 숫자를 흔드는 작업">재고수정 뒤 작업 '+an+'개</span>';
    if(pn) item+=' <span class="pre-n" title="이 전표의 품목 중 '+pn+'개는 그 품목의 최근 재고수정 날짜보다 앞 날짜입니다">재고수정 이전 '+(pn===L.length?'전부':pn+'개')+'</span>';
    var doer=(kd==='new') ? who(r.regUserNm, r.regUser) : who(r.updUserNm, r.updUser);
    var first=(kd==='new') ? '' : '<div class="sub">처음 넣음 '+esc(tm(r.regDttm))+' · '+who(r.regUserNm, r.regUser)+'</div>';
    h+='<tr class="row'+(s==='O'?' old':'')+(kd==='del'?' del':'')+'" data-k="'+esc(k)+'" onclick="toggle(\''+esc(k)+'\')">'
      +'<td onclick="event.stopPropagation()">'+((s==='P'||s==='O')?'<input type="checkbox" class="ck" value="'+esc(k)+'">':'')+'</td>'
      +'<td class="cd">'+esc(tm(r.evDttm))+'</td>'
      +'<td>'+doer+first+'</td>'
      +'<td><span class="bd '+kd+'">'+KIND_NM[kd]+'</span></td>'
      +'<td><span class="bd '+(pu?'pu':'sa')+'">'+(pu?'매입':'판매')+'</span></td>'
      +'<td class="vn cd">'+esc(d10(r.trxDt))+' / '+esc(r.trxNo||'')+'</td>'
      +'<td class="l vn">'+esc(r.custNm||r.custCd||'')+'</td>'
      +'<td class="l vn">'+item+'</td>'
      +'<td class="r '+(so.q>0?'up':(so.q<0?'dn':''))+'">'+sg(so.q)+'</td>'
      +'<td class="r">'+fmt(r.totAmt)+'</td>'
      +'<td>'+stHtml(r)+'</td>'
      +'<td onclick="event.stopPropagation()">'+actHtml(r)+'</td></tr>';
    if(L.length && !(k in CLOSED ? CLOSED[k] : FOLD)) h+='<tr class="lines"><td colspan="12">'+linesHtml(r, q)+'</td></tr>';
  });
  document.getElementById('body').innerHTML=h;
  /* 기간 밖 미확인 — 메뉴 배지 숫자와 같은 «전체 미확인». 고른 기간에 없으면 안내 + [보기] (2026-11-26 「2번은 무슨뜻인가요 1표시」) */
  var out=(PEND_ALL!=null && PEND_ALL>pend) ? (PEND_ALL-pend) : 0;
  document.getElementById('cnt').innerHTML='미확인 <b>'+pend+'</b>건'+(out?(' · <a href="javascript:void(0)" onclick="pendAllShow()" style="color:#c0392b;font-weight:800" title="메뉴 배지 숫자 = 기간과 상관없는 전체 미확인. 눌러서 이 기능을 켠 날부터 오늘까지 보기">기간 밖 미확인 '+out+'건 보기</a>'):'')+(old?(' · 시작 전 '+old+'건'):'')+' · 보이는 줄 '+v.length+' / '+ROWS.length;
  var lg=document.getElementById('lgStart'); if(lg && START) lg.textContent='이 기능을 켠 때('+tm(START)+')보다 앞서 한 작업 — 확인하지 않아도 되지만 할 수는 있습니다';
  document.getElementById('btnFold').textContent=FOLD?'품목 줄 펼치기':'품목 줄 접기';
  var ca=document.getElementById('chkAll'); if(ca) ca.checked=false;
}
function linesHtml(r, q){
  var L=linesOf(r), kd=kindOf(r), vx=((''+(r.chkState||'')).trim()==='X'), k=esc(key(r));
  var h='<table class="ln"><thead><tr><th>품목코드</th><th>품목명</th><th>구분</th><th>수량</th><th title="'+(kd==='del'?'지워서 재고에 미친 수량 — 매입을 지우면 −':'이 줄이 재고에 미친 수량')+'">재고 영향</th><th>지금 현재고</th><th>마지막으로 맞춘 날 · 수정재고</th><th>재고</th></tr></thead><tbody>';
  var hid=0;
  L.forEach(function(x){
    var pre=preAdj(r,x), fx=((''+x.adjFixYn)==='Y');
    var aft=aftAdj(r,x);
    if(!aft && aftOn()){ hid++; return; }   /* 최종 재고수정 이후만 — 재고수정 전에 한 작업은 숨기고 아래에 몇 줄 숨겼는지 */
    var e=effOf(r,x), off=lineOff(r,x), mine=((''+(x.xState||'')).trim()==='X'), ps=n(x.prodSeq);
    var hit=q && ((''+(x.prodCd||'')+' '+(x.prodNm||'')).toLowerCase().indexOf(q)>=0);
    var c;
    var lock=(pre && fx);   /* 고정된 재고수정보다 앞 전표 — 재고 미적용·적용을 받지 않는다(서버 stockChkPre 와 같은 규칙) */
    var lockBtn=(ADMIN && ps) ? ' <button class="btn xs lockb" onclick="preMsg(event,\''+esc(x.prodCd)+'\',\''+esc(d10(r.trxDt))+'\',\''+esc(d10(x.adjDt))+'\')" title="고정된 재고수정보다 앞 전표라 현재고를 바꿀 수 없습니다 — 눌러서 이유 보기">🔒 적용 안 됨</button>' : '';
    if(n(x.stkQty)===0) c='<span class="sub">재고와 무관</span>';
    else if(vx) c='<span class="st X">재고 미적용</span> <span class="sub">전표 전체</span>';
    else if(mine && lock) c='<span class="st X" title="'+esc(x.xMemo||'')+'">재고 미적용</span>'+lockBtn+'<div class="sub">'+esc(x.xMemo||'')+'</div>';
    else if(lock) c='<span class="sub">적용됨</span>'+lockBtn;
    else if(mine) c='<span class="st X" title="'+esc(x.xMemo||'')+'">재고 미적용</span> '+(ADMIN?'<button class="btn xs btn-blue" onclick="act(event,\''+k+'\','+ps+',\'U\')" title="이 품목을 다시 재고에 적용합니다">재고 적용</button>':'')
      +'<div class="sub">'+esc(x.xMemo||'')+((x.xUserNm||x.xDttm)?(' · '+esc(x.xUserNm||'')+' '+esc(tm(x.xDttm))):'')+'</div>';
    else c='<span class="sub">적용됨</span> '+((ADMIN && ps)?'<button class="btn xs btn-warn" onclick="rsOpen(event,\''+k+'\','+ps+')" title="'+(kd==='del'?'삭제를 재고에 적용하지 않습니다 — 지워서 빠진 수량이 재고에 다시 들어갑니다(판매는 다시 빠집니다)':'이 품목을 재고에 적용하지 않습니다(금액은 그대로)')+'">재고 미적용</button>':'');
    h+='<tr class="'+(off?'x':'')+(hit?' hit':'')+(pre?' pre':'')+'"><td class="cd">'+esc(x.prodCd)+'</td><td>'+esc(x.prodNm||'')+'</td><td>'+esc(x.trxGb||'')+'</td><td class="r">'+fmt(x.qty)+'</td>'
      +'<td class="r '+(off?'off':(e>0?'up':(e<0?'dn':'')))+'">'+sg(e)+'</td><td class="r">'+fmt(x.curQty)+'</td>'
      +'<td>'+(x.adjDt?(esc(d10(x.adjDt))+' · '+fmt(x.adjQty)+(fx?' <span title="수정재고 고정 — 이 날짜보다 앞 날짜의 전표는 현재고를 바꾸지 않습니다">🔒</span>':'')):'<span class="sub">맞춘 적 없음</span>')
      +  ((pre && aft && x.adjRegDttm) ? ' <span class="pre-tag aft" title="재고수정('+esc(d10(x.adjDt))+', 저장 '+esc(tm(x.adjRegDttm))+')을 한 뒤에 그보다 앞 날짜('+esc(d10(r.trxDt))+') 전표를 작업했습니다('+esc(tm(r.evDttm))+'). 실사로 맞춘 숫자를 흔드는 작업이라 꼭 확인하세요.">재고수정 뒤 작업</span>' : '')
      +  (pre ? (fx ? ' <span class="pre-tag fx" title="이 전표('+esc(d10(r.trxDt))+')는 재고수정('+esc(d10(x.adjDt))+')보다 앞 날짜이고, 그 재고수정이 고정(🔒)이라 현재고에 영향이 없습니다. 재고 미적용·적용도 받지 않습니다 — 현재고를 바꾸려면 재고수정을 다시 하세요.">재고수정 이전 · 현재고 영향 없음</span>'
                  : ' <span class="pre-tag" title="이 전표('+esc(d10(r.trxDt))+')는 최근 재고수정('+esc(d10(x.adjDt))+')보다 앞 날짜입니다. 그 재고수정은 2026-11-25 이전 프로그램으로 저장돼 기준값이 비어 있어(기준값 채우기 SQL docs/sql/20261126_stock_adj_frz_backfill.sql 실행 전), 지금은 재고 미적용·적용이 현재고를 바꿉니다.">재고수정 이전 · 현재고 바뀜</span>') : '')+'</td>'
      +'<td style="text-align:left">'+c+'</td></tr>'; });
  if(hid) h+='<tr class="pre"><td colspan="8" style="text-align:left;color:#7d8a97">최종 재고수정 전에 한 작업 '+hid+'개는 숨겼습니다 — 「최종 재고수정 이후만」 을 끄면 보입니다.</td></tr>';
  return h+'</tbody></table>';
}
function toggle(k){ var cur=(k in CLOSED) ? CLOSED[k] : FOLD; CLOSED[k]=!cur; render(); }
function foldAll(){ FOLD=!FOLD; CLOSED={}; try{ localStorage.setItem('konetStockChkFold', FOLD?'1':'0'); }catch(e){} render(); }
function post(u, body, json){
  return fetch(CTX+u, { method:'POST', headers:{'Content-Type': json?'application/json':'application/x-www-form-urlencoded'}, credentials:'same-origin', body: json?JSON.stringify(body):(body||'') })
    .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); });
}
function pendAllShow(){
  var t=new Date(), st=String(START||'').slice(0,10);
  document.getElementById('frDt').value=(/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/.test(st) ? st : ymd(new Date(t.getFullYear(), t.getMonth(), t.getDate()-30)));
  document.getElementById('toDt').value=ymd(t); document.getElementById('fSt').value='P'; load();
}
function setRange(k){
  var t=new Date(), f=t;
  if(k==='d7') f=new Date(t.getFullYear(), t.getMonth(), t.getDate()-6);
  else if(k==='m0') f=new Date(t.getFullYear(), t.getMonth(), 1);
  document.getElementById('frDt').value=ymd(f); document.getElementById('toDt').value=ymd(t);
  load();
}
function load(){
  var my=++_seq, b=document.getElementById('btnLoad'); if(b) b.disabled=true;
  post('/prod/stockChkList.do', 'frDt='+encodeURIComponent(gv('frDt'))+'&toDt='+encodeURIComponent(gv('toDt'))).then(function(j){
    if(my!==_seq) return;
    if(b) b.disabled=false;
    if(!j || j.result!=='OK'){
      ROWS=[]; LMAP={}; document.getElementById('cnt').textContent='';
      document.getElementById('body').innerHTML='<tr><td class="empty" colspan="12">'+esc((j && j.message)||'조회하지 못했습니다.')+'</td></tr>';
      return;
    }
    ADMIN=(j.admin==='Y'); START=''+(j.startDttm||''); PEND_ALL=(j.pendAll==null) ? null : n(j.pendAll); ROWS=j.data||[]; LMAP={};
    (j.lines||[]).forEach(function(x){ var k=x.refGb+':'+x.refSeq; (LMAP[k]||(LMAP[k]=[])).push(x); });
    if(j.frDt) document.getElementById('frDt').value=j.frDt; if(j.toDt) document.getElementById('toDt').value=j.toDt;
    render();
  }).catch(function(){ if(my!==_seq) return; if(b) b.disabled=false; document.getElementById('body').innerHTML='<tr><td class="empty" colspan="12">조회하지 못했습니다 — 잠시 뒤 다시 눌러 주세요.</td></tr>'; });
}
function rowOf(k){ for(var i=0;i<ROWS.length;i++) if(key(ROWS[i])===k) return ROWS[i]; return null; }
function itemOf(k, ps){ var p=k.split(':'); return { refGb:p[0], refSeq:Number(p[1]), prodSeq:Number(ps)||0 }; }
/* 처리 결과 — 재고가 바뀐 품목이 있으면 «얼마에서 얼마로» 를 알림창으로, 아니면 토스트 */
function done(j, what){
  if(!j || j.result!=='OK'){ window._alertBox(esc((j && j.message)||'처리하지 못했습니다.'), { icon:'⚠️', okColor:'red' }); return; }
  var ps=j.prods||[], msg=what+' '+(j.done||0)+'건'+((j.skip||0)?(' · 건너뜀 '+j.skip+'건'):'')+((j.blocked||0)?(' · 관리자만 할 수 있어 건너뜀 '+j.blocked+'건'):'');
  if(ps.length){
    var h='<b>'+esc(msg)+'</b><div style="text-align:left;margin-top:8px;font-size:13px;line-height:1.7;max-height:240px;overflow:auto">';
    ps.forEach(function(p){ var same=(n(p.bef)===n(p.aft));
      h+='<div><span class="cd">'+esc(p.prodCd)+'</span> '+esc(p.prodNm||'')+' — 현재고 '+(same?('<b>'+fmt(p.bef)+'</b> 그대로 <span style="color:#8a97a4">(맞춘 날짜보다 앞 전표)</span>'):(fmt(p.bef)+' → <b>'+fmt(p.aft)+'</b>'))+'</div>'; });
    window._alertBox(h+'</div>', { icon:'📦' });
  } else window._toast(esc(msg), (j.done||0)?'ok':'warn');
  load();
  try{ if(window.parent && window.parent.empBadgeNow) window.parent.empBadgeNow(); }catch(e){}
}
function fail(){ window._alertBox('처리하지 못했습니다 — 다시 조회한 뒤 해 주세요.', { icon:'⚠️', okColor:'red' }); }
/* 확인(C) · 되돌리기(U — 확인 취소 / 재고 적용). ps = 품목(0 이면 전표) */
function act(ev, k, ps, a){
  if(ev) ev.stopPropagation();
  var r=rowOf(k); if(!r) return;
  var toStock=(a==='U' && (Number(ps)>0 || stOf(r)==='X'));      /* 재고 미적용이던 것을 다시 적용 */
  var go=function(){ post('/prod/stockChkAct.do', { items:[itemOf(k, ps)], act:a, memo:'' }, true).then(function(j){ done(j, a==='C'?'확인':(toStock?'재고 적용':'확인 취소')); }).catch(fail); };
  if(toStock){ preChk(itemOf(k, ps), 'U', function(){ act0(k, ps, r, go); }); return; }
  go();
}
/* 고정된 품목의 앞 날짜 전표면 안내만(처리 안 함) — 공용 stock-chk-act.js 의 stkChkPre (2026-11-26 「어차피 적용안되는데」). 그 파일이 없으면 종전대로 */
function preChk(it, a, go){ if(typeof window.stkChkPre==='function') window.stkChkPre([it], a, go); else go(); }
function act0(k, ps, r, go){
  {   /* 다시 재고에 적용 — 묻고 나서 */
    var nm=''; if(Number(ps)>0) linesOf(r).some(function(x){ if(n(x.prodSeq)===Number(ps)){ nm=x.prodCd+' '+(x.prodNm||''); return true; } return false; });
    window._confirmBox({ msg:(nm?('<b>'+esc(nm)+'</b><br>'):'')+'이 '+(nm?'품목':'전표')+'을(를) <b>다시 재고에 적용합니다.</b><br><span style="font-size:13px;color:#5b6b7a">'+esc(d10(r.trxDt))+' / '+esc(r.trxNo||'')+' · '+esc(r.custNm||'')+'</span>', icon:'📦', okText:'재고 적용', onOk:go });
  }
}
function chkAll(on){ var c=document.querySelectorAll('#body input.ck'); for(var i=0;i<c.length;i++) c[i].checked=!!on; }
function bulkConfirm(){
  var c=document.querySelectorAll('#body input.ck:checked'), keys=[]; for(var i=0;i<c.length;i++) keys.push(c[i].value);
  if(!keys.length){ window._alertBox('확인할 전표를 먼저 골라 주세요(맨 앞 네모).', { icon:'☑' }); return; }
  window._confirmBox({ msg:'고른 <b>'+keys.length+'건</b>을 확인으로 처리합니다.<br><span style="font-size:13px;color:#5b6b7a">실물도 전표대로 움직였다는 뜻입니다 — 재고는 바뀌지 않습니다.</span>', icon:'☑', okText:'확인 처리',
    onOk:function(){ post('/prod/stockChkAct.do', { items:keys.map(function(k){ return itemOf(k, 0); }), act:'C', memo:'' }, true).then(function(j){ done(j, '확인'); }).catch(fail); } });
}
/* 재고 미적용 — 사유 입력 창. ps = 품목(0 이면 전표 전체) */
function rsOpen(ev, k, ps){
  if(ev) ev.stopPropagation();
  if(!rowOf(k)) return;
  preChk(itemOf(k, ps), 'X', function(){ rsOpen0(k, ps); });   /* 고정 품목의 앞 날짜 전표면 안내만 (2026-11-26) */
}
function rsOpen0(k, ps){
  var r=rowOf(k); if(!r) return; _rsItem={ k:k, ps:Number(ps)||0 };
  var del=(kindOf(r)==='del'), L=linesOf(r).filter(function(x){ return !Number(ps) || n(x.prodSeq)===Number(ps); }), q=0;
  L.forEach(function(x){ if(!lineOff(r,x)) q+=effOf(r,x); });
  var what=Number(ps) ? ('<b>'+esc((L[0]||{}).prodCd||'')+'</b> '+esc((L[0]||{}).prodNm||'')) : ('이 전표의 <b>품목 전부('+L.length+'개)</b>');
  document.getElementById('rsMsg').innerHTML='<b>'+(r.refGb==='PURCH'?'매입':'판매')+' '+esc(d10(r.trxDt))+' / '+esc(r.trxNo||'')+'</b> · '+esc(r.custNm||'')+(del?' <span class="bd del">삭제</span>':'')+'<br>'+what+'<br>'
    +(del ? ('전표를 지워서 재고에 미친 수량 <b>'+sg(q)+'</b> 을(를) 재고에 적용하지 않습니다 — 그만큼 재고가 <b>지우기 전으로</b> 돌아갑니다.')
          : ('이 작업이 재고에 미친 수량 <b>'+sg(q)+'</b> 을(를) 재고에 적용하지 않습니다. 매입·매출 금액은 그대로 남습니다.'));
  var chips=del ? ['서류만 삭제 (실물은 그대로 있음)','중복 전표를 지운 것이 아님','잘못 지움'] : ['서류만 정정 (실물 그대로)','중복 입력','실물이 아직 안 들어옴','실물이 아직 안 나감'];
  document.getElementById('rsChips').innerHTML=chips.map(function(t){ return '<button type="button" onclick="rsPick(this)">'+esc(t)+'</button>'; }).join('');
  document.getElementById('rsMemo').value=''; document.getElementById('rsErr').textContent='';
  document.getElementById('rsBd').style.display='flex'; document.getElementById('rsMemo').focus();
}
function rsPick(b){ document.getElementById('rsMemo').value=b.textContent; document.getElementById('rsErr').textContent=''; }
function rsClose(){ document.getElementById('rsBd').style.display='none'; _rsItem=null; }
function rsGo(){
  var memo=gv('rsMemo').trim(), it=_rsItem;
  if(!memo){ document.getElementById('rsErr').textContent='재고에 적용하지 않는 사유를 적어 주세요.'; return; }
  if(!it) return;
  var ok=document.getElementById('rsOk'); ok.disabled=true;
  post('/prod/stockChkAct.do', { items:[itemOf(it.k, it.ps)], act:'X', memo:memo }, true).then(function(j){ ok.disabled=false; rsClose(); done(j, '재고 미적용'); })
    .catch(function(){ ok.disabled=false; document.getElementById('rsErr').textContent='처리하지 못했습니다 — 다시 눌러 주세요.'; });
}
document.getElementById('rsBd').addEventListener('click', function(e){ if(e.target===this) rsClose(); });
try{ var _af=document.getElementById('fAft'); if(_af) _af.checked=(localStorage.getItem('konetStockChkAft')==='1'); }catch(e){}
setRange('d7');
</script>
</body>
</html>
