<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 요약 — /m/index.do (MobileController, 로그인 필수).
     카드 6장 : ①그날 장부(일계장) ②이번 달 매출·순마진 ③출고 ④받을금액·지급할금액 ⑤재고 마이너스 ⑥이번 달 휴가자(2026-10-21 「KONET_VSAPP 에서 당월 휴가자 볼 수 있게」)
     자료는 PC 화면과 **같은 조회(*.do)** 를 부르고, 금액 규칙도 PC 와 같게 계산한다(할인 뺀 금액 · 라벨수량 등).
     ★자료를 부르기 전에 /m/session.do 로 로그인부터 확인한다 — 기존 조회는 세션을 안 봐서
       끊긴 세션으로 부르면 전 회사 자료가 오기 때문(MobileController 주석 참고). --%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#137a6c">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="코네트">
<title>코네트 요약</title>
<link rel="manifest" href="<%=request.getContextPath()%>/m/manifest.json">
<link rel="apple-touch-icon" href="<%=request.getContextPath()%>/m/icons/apple-touch-icon.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/m/m.css?v=20260914a">
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<script src="<%=request.getContextPath()%>/m/m.js?v=20260914a"></script>
<style>
  .btn2{ display:inline-block; margin-top:10px; height:34px; padding:0 14px; border:1px solid var(--teal); border-radius:8px;
    background:#fff; color:var(--teal-d); font:inherit; font-size:15.5px; font-weight:700; }
  .quick{ display:grid; grid-template-columns:1fr 1fr 1fr 1fr; gap:8px; margin-bottom:12px; }   /* 넷째 칸 = 휴가자조회 (2026-10-21) */
  .quick a{ display:flex; flex-direction:column; align-items:center; gap:4px; padding:12px 4px; border-radius:12px; background:#fff;
    border:1px solid var(--bd); text-decoration:none; color:var(--teal-d); font-size:16px; font-weight:800; }
  .quick a i{ font-style:normal; font-size:24px; }
  @media (max-width:420px){ .quick a{ font-size:14.5px; padding:10px 2px; } .quick a i{ font-size:22px; } }
  @media (min-width:768px){ .quick a{ flex-direction:row; justify-content:center; gap:8px; font-size:18px; padding:14px 4px; } }
  .lvchip{ display:inline-block; font-size:14px; font-weight:800; line-height:1.4; padding:1px 8px; border-radius:7px; color:#fff; background:#5a6b7a; margin:2px 4px 2px 0; white-space:nowrap; }
  .lvchip.pend{ opacity:.75; outline:2px dashed rgba(0,0,0,.3); outline-offset:-2px; }
  .lvday{ flex:0 0 76px; font-weight:800; color:var(--teal-d); } .lvday.today{ color:var(--red); }
  .row.lv{ align-items:flex-start; } .row.lv .k{ white-space:normal; }
</style>
</head>
<body>
<header>
  
  <div class="hd1">
    <h1>코네트</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="loadAll()" title="다시 불러오기">↻</button>
    <button type="button" onclick="M.logout()">로그아웃</button>
  </div>
  <div class="datebar">
    <button type="button" onclick="shiftDay(-1)" aria-label="전날">◀</button>
    <input type="date" id="dt" onchange="setDay(this.value)">
    <button type="button" onclick="shiftDay(1)" aria-label="다음날">▶</button>
    <button type="button" class="today" onclick="setDay(ymd(new Date()))">오늘</button>
  </div>
</header>

<main class="lay2"><%-- 태블릿 = 카드 두 단(m.css .lay2) --%>
  <nav class="quick span" aria-label="바로 가기">
    <a href="<%=request.getContextPath()%>/m/sales.do"><i>🧾</i>판매등록</a>
    <a href="<%=request.getContextPath()%>/m/settle.do?gb=RCV"><i>💰</i>수금</a>
    <a href="<%=request.getContextPath()%>/m/settle.do?gb=PAY"><i>💸</i>지급</a>
    <a href="<%=request.getContextPath()%>/m/leave.do"><i>🏖</i>휴가자조회</a>
  </nav>
  <section class="card"><h2>📒 그날 장부 <small id="dayLbl"></small></h2><div id="cDay" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>💰 이번 달 매출 <small id="monLbl"></small><span class="badge" id="closeBadge" hidden></span></h2><div id="cMon" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>🚚 출고 <small id="shipLbl"></small></h2><div id="cShip" class="loading">불러오는 중…</div></section>
  <%-- ⑥ 이번 달 휴가자 (2026-10-21) — 웹 직원관리 ▸ 직원 휴가 관리와 같은 표(TBL_LEAVE_MST)·같은 구분 색(회사 설정 'leave'). 보기만, 등록·승인은 웹에서 --%>
  <section class="card"><h2>🏖 이번 달 휴가자 <small id="lvLbl"></small><span class="badge ok" id="lvBadge" hidden></span></h2><div id="cLv" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>📊 받을금액 · 지급할금액 <small id="balLbl"></small></h2><div id="cBal" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>📦 재고</h2><div id="cStk" class="loading">불러오는 중…</div></section>
</main>

<script>
/* ---------- 도우미 (m/m.js 공용) ---------- */
var $=M.$, n=M.n, fmt=M.fmt, fmtQ=M.fmtQ, esc=M.esc, ymd=M.ymd, ym6=M.ym6, lblDay=M.lblDay, lblMon=M.lblMon;
var post=M.form;   // ★모바일 헤더(X-Konet-M)를 달아 보낸다 — 세션이 끊겼으면 서버가 401 로 막는다
function errHtml(fnName){ return '<div class="err">불러오지 못했습니다.<button type="button" onclick="'+fnName+'()">다시</button></div>'; }
function tile(lbl, v, cls, em){   // 12자 넘는 값(10억 단위 금액)은 한 단계 작게 — 반칸 폭에서 잘리지 않게
  var c=(cls||'')+(String(v).length>11?' long':'');
  return '<div class="tile"><span>'+lbl+'</span><b class="'+c+'">'+v+'</b>'+(em?'<em>'+em+'</em>':'')+'</div>'; }

/* ---------- 날짜 ---------- */
var D = ymd(new Date());
function setDay(v){ if(!v) return; D=v; $('dt').value=v; loadAll(); }
function shiftDay(k){ var d=new Date(D+'T00:00:00'); d.setDate(d.getDate()+k); setDay(ymd(d)); }

/* ---------- 로그인 확인 → 카드 5장 ---------- */
var _lastLoad = 0;
function loadAll(){
  _lastLoad = Date.now();
  post('/m/session.do',{}).then(function(s){
    if(!s.ok){ location.replace(M.CTX+'/m/login.do'); return; }
    $('who').textContent = (s.compNm||'') + (s.userNm ? ' · '+s.userNm : '');
    loadDay(); loadMon(); loadShip(); loadBal(); loadStk(); loadLv();
  }).catch(function(){
    ['cDay','cMon','cShip','cBal','cStk','cLv'].forEach(function(id){ $(id).innerHTML='<div class="err">서버에 연결하지 못했습니다.<button type="button" onclick="loadAll()">다시</button></div>'; });
  });
}

/* ① 그날 장부 = 일계장(selectDayBook). dt='00000000'(전일 누계) 줄은 버린다.
      금액은 일계장·채권채무 화면과 같은 규칙 : 매출 = 매출 − 매출할인, 매입 = 매입 − 매입할인. */
function loadDay(){
  var el=$('cDay'); el.className=''; el.innerHTML='<div class="loading">불러오는 중…</div>'; $('dayLbl').textContent=lblDay(D);
  post('/mangr/selectDayBook.do',{ fromDt:D, toDt:D }).then(function(res){
    var m={}, ord=[], t={sale:0,rcv:0,purch:0,pay:0};
    (res.data||[]).forEach(function(r){
      if(String(r.dt||'')==='00000000') return;
      var k=String(r.custCd||''); if(!m[k]){ m[k]={ nm:r.custNm||k, sale:0,rcv:0,purch:0,pay:0 }; ord.push(k); }
      var o=m[k], s=n(r.saleAmt)-n(r.saleDcAmt), rc=n(r.rcvAmt), p=n(r.purchAmt)-n(r.purchDcAmt), py=n(r.payAmt);
      o.sale+=s; o.rcv+=rc; o.purch+=p; o.pay+=py; t.sale+=s; t.rcv+=rc; t.purch+=p; t.pay+=py;
    });
    var list=ord.map(function(k){ return m[k]; }).filter(function(o){ return o.sale||o.rcv||o.purch||o.pay; });
    list.sort(function(a,b){ return (Math.abs(b.sale)+Math.abs(b.rcv)+Math.abs(b.purch)+Math.abs(b.pay))-(Math.abs(a.sale)+Math.abs(a.rcv)+Math.abs(a.purch)+Math.abs(a.pay)); });
    var h='<div class="tiles">'+tile('매출',fmt(t.sale),'teal')+tile('수금(입금)',fmt(t.rcv))+tile('매입',fmt(t.purch),'blue')+tile('지급(출금)',fmt(t.pay))+'</div>';
    if(!list.length){ h+='<p class="note">이 날은 거래가 없습니다.</p>'; }
    else{
      h+='<details><summary>거래처 '+list.length+'곳 보기</summary><div class="list">';
      list.forEach(function(o){
        var parts=[]; if(o.sale) parts.push('매출 '+fmt(o.sale)); if(o.rcv) parts.push('수금 '+fmt(o.rcv));
        if(o.purch) parts.push('매입 '+fmt(o.purch)); if(o.pay) parts.push('지급 '+fmt(o.pay));
        h+='<div class="row"><div class="k">'+esc(o.nm)+'<small>'+parts.join(' · ')+'</small></div></div>';
      });
      h+='</div></details>';
    }
    el.innerHTML=h;
  }).catch(function(){ el.innerHTML=errHtml('loadDay'); });
}

/* ② 이번 달 매출 = 매출 그래프 월별(selectSalesChart) — 마감현황과 같은 정의(정산서 + 정산서 없는 출고의 추정 + 직접판매).
      월 단위로만 비교하므로 기준일이 속한 달 전체다. 마감 확정 여부는 selectClosingStatus. */
function loadMon(){
  var el=$('cMon'); el.innerHTML='<div class="loading">불러오는 중…</div>'; $('monLbl').textContent=lblMon(D);
  var YM=ym6(D), bd=$('closeBadge'); bd.hidden=true;
  post('/shipout/selectClosingStatus.do',{ ym:YM }).then(function(res){
    var c=res.data; bd.hidden=false;
    if(c && c.status==='C'){ bd.textContent='🔒 마감 확정'; bd.className='badge ok'; } else { bd.textContent='마감 전'; bd.className='badge'; }
  }).catch(function(){ bd.hidden=true; });
  post('/shipout/selectSalesChart.do',{ fromDt:D.slice(0,7)+'-01', toDt:D }).then(function(res){
    var t={sale:0,cost:0,mg:0}, m={}, ord=[];
    (res.data||[]).forEach(function(r){
      if(ym6(r.ym)!==YM) return;
      var k = r.dcCd==='TRX' ? '직접판매' : String(r.dcNm||r.dcCd||'기타').replace(/\s*(물류)?센터$/,'');
      if(!m[k]){ m[k]=0; ord.push(k); }
      m[k]+=n(r.saleAmt); t.sale+=n(r.saleAmt); t.cost+=n(r.costAmt); t.mg+=n(r.marginAmt);
    });
    ord.sort(function(a,b){ return m[b]-m[a]; });
    var rate = t.sale ? (t.mg/t.sale*100).toFixed(1)+'%' : '—';
    var h='<div class="tiles">'+tile('매출액',fmt(t.sale),'teal')+tile('매입액',fmt(t.cost),'blue')
        +tile('순마진',fmt(t.mg),t.mg<0?'red':'','마진율 '+rate)
        +tile('출고장',(function(c){ return c ? c+'곳' : '—'; })(ord.filter(function(k){ return k!=='직접판매'; }).length),'',m['직접판매']?'직접판매 '+fmt(m['직접판매']):'')+'</div>';
    if(ord.length){
      var mx=Math.max.apply(null,ord.map(function(k){ return Math.abs(m[k]); }))||1;
      h+='<div class="list">';
      ord.forEach(function(k){
        h+='<div class="row"><div class="k">'+esc(k)+'<div class="bar"><i style="width:'+Math.max(2,Math.round(Math.abs(m[k])/mx*100))+'%"></i></div></div><div class="v">'+fmt(m[k])+'</div></div>';
      });
      h+='</div>';
    }
    h+='<p class="note">매입가가 등록되지 않은 품목은 매입액 0 으로 잡혀 순마진이 크게 보일 수 있습니다.</p>';
    el.innerHTML=h;
  }).catch(function(){ el.innerHTML=errHtml('loadMon'); });
}

/* ③ 출고 = 출고현황(selectShipoutMst, 출고일자 = 기준일).
      출고수량 규칙은 대시보드와 같다(logi-oh.js ssOutQty) : 정산서 반영분이면 정산수량, 아니면 라벨수량(없으면 수량).
      직송 = ZONE 또는 배송구분이 '직송'. */
function outQty(o){
  if((''+(o.settleYn||''))==='Y') return Math.round(n(o.settleQty)*10)/10;
  var v=(o.labelQty!=null && o.labelQty!=='') ? o.labelQty : o.curQty;
  return n(v);
}
function loadShip(){
  var el=$('cShip'); el.innerHTML='<div class="loading">불러오는 중…</div>'; $('shipLbl').textContent='출고일자 '+lblDay(D);
  post('/shipout/selectShipoutMst.do',{ shpoutDt:D }).then(function(res){
    var rows=res.data||[], t={dlv:0,jik:0}, biz={}, item={}, m={}, ord=[];
    rows.forEach(function(r){
      var q=outQty(r), jik=(r.zone==='직송'||r.dlvGb==='직송');
      var k=String(r.dcNm||r.dcCd||'기타').replace(/\s*(물류)?센터$/,'');
      if(!m[k]){ m[k]={dlv:0,jik:0,biz:{}}; ord.push(k); }
      if(jik){ m[k].jik+=q; t.jik+=q; } else { m[k].dlv+=q; t.dlv+=q; }
      if(r.bizCd){ biz[r.bizCd]=1; m[k].biz[r.bizCd]=1; }
      if(r.itemCd) item[r.itemCd]=1;
    });
    if(!rows.length){ el.innerHTML='<p class="note" style="margin:0">이 출고일자에 올라온 발주현황표가 없습니다.</p>'; return; }
    ord.sort(function(a,b){ return (m[b].dlv+m[b].jik)-(m[a].dlv+m[a].jik); });
    var h='<div class="tiles">'+tile('총 출고수량',fmtQ(t.dlv+t.jik),'teal','배송 '+fmtQ(t.dlv)+' · 직송 '+fmtQ(t.jik))
        +tile('사업장',Object.keys(biz).length.toLocaleString()+'곳','','품목 '+Object.keys(item).length.toLocaleString()+'종')+'</div>';
    var mx=Math.max.apply(null,ord.map(function(k){ return m[k].dlv+m[k].jik; }))||1;
    h+='<div class="list">';
    ord.forEach(function(k){
      var o=m[k], tot=o.dlv+o.jik;
      h+='<div class="row"><div class="k">'+esc(k)+'<small>배송 '+fmtQ(o.dlv)+(o.jik?' · <span class="jk">직송 '+fmtQ(o.jik)+'</span>':'')
        +' · 사업장 '+Object.keys(o.biz).length+'곳</small><div class="bar"><i style="width:'+Math.max(2,Math.round(tot/mx*100))+'%"></i></div></div>'
        +'<div class="v">'+fmtQ(tot)+'</div></div>';
    });
    el.innerHTML=h+'</div>';
  }).catch(function(){ el.innerHTML=errHtml('loadShip'); });
}

/* ⑥ 이번 달 휴가자 = 웹 「직원 휴가 관리」 표(/mangr/leaveList.do, 그 달 범위). 반려는 뺀다. 구분 색은 /mangr/leaveInfo.do(회사 설정 'leave').
      위 타일 = 오늘 쉬는 사람 · 이번 달 건수/인원. 아래 = 날짜별 줄(이름 + 구분 칩, 점선 = 승인 대기). 사유는 안 보인다(개인 사정). */
var _lvGb=null;
function lvColor(g){ var x=(_lvGb||[]).filter(function(o){ return o.nm===g; })[0]; return x?x.color:'#5a6b7a'; }
function lvShort(g){ return String(g||'').replace('(오전)','AM').replace('(오후)','PM'); }
function loadLv(){
  var el=$('cLv'); el.innerHTML='<div class="loading">불러오는 중…</div>';
  var y=+D.slice(0,4), m=+D.slice(5,7), a=D.slice(0,7)+'-01', bd=new Date(y, m, 0), b=ymd(bd), tk=D.replace(/-/g,'');
  $('lvLbl').textContent=lblMon(D); var bg=$('lvBadge'); bg.hidden=true;
  var gbP=_lvGb ? Promise.resolve(_lvGb) : post('/mangr/leaveInfo.do',{}).then(function(r){ _lvGb=(r&&r.gbs)||[]; return _lvGb; }).catch(function(){ _lvGb=[]; return _lvGb; });
  gbP.then(function(){ return post('/mangr/leaveList.do',{ frDt:a, toDt:b }); }).then(function(res){
    if(res&&res.error) throw new Error(res.error);
    var rows=(res.data||[]).filter(function(o){ return o.status!=='반려'; });
    if(!rows.length){ el.innerHTML='<p class="note" style="margin:0">이 달에 등록된 휴가가 없습니다.</p>'; return; }
    var people={}, todayL=rows.filter(function(o){ return String(o.fromDt)<=tk && String(o.toDt)>=tk; });
    rows.forEach(function(o){ people[o.userId]=1; });
    bg.textContent=Object.keys(people).length+'명'; bg.hidden=false;
    var h='<div class="tiles">'+tile('오늘 휴가', todayL.length?todayL.map(function(o){ return esc(o.userNm); }).join(', '):'없음', todayL.length?'red':'', todayL.length?todayL.map(function(o){ return lvShort(o.leaveGb); }).join(' · '):lblDay(D))
        +tile('이번 달', rows.length+'건', 'teal', Object.keys(people).length+'명 · '+rows.reduce(function(t,o){ return t+n(o.days); },0).toLocaleString('ko-KR')+'일')+'</div>';
    /* 날짜별 — 기간 휴가는 걸치는 날마다 */
    var byDay={}, keys=[]; var d=new Date(y, m-1, 1);
    while(d.getMonth()===m-1){ var k=ymd(d).replace(/-/g,''); var l=rows.filter(function(o){ return String(o.fromDt)<=k && String(o.toDt)>=k; }); if(l.length){ byDay[k]=l; keys.push(k); } d.setDate(d.getDate()+1); }
    var W=['일','월','화','수','목','금','토'];
    h+='<div class="list">'+keys.map(function(k){ var dd=new Date(+k.slice(0,4), +k.slice(4,6)-1, +k.slice(6,8));
      return '<div class="row lv"><div class="lvday'+(k===tk?' today':'')+'">'+(+k.slice(4,6))+'/'+(+k.slice(6,8))+' ('+W[dd.getDay()]+')</div><div class="k">'
        +byDay[k].map(function(o){ return '<span class="lvchip'+(o.status==='신청'?' pend':'')+'" style="background:'+lvColor(o.leaveGb)+'">'+esc(o.userNm)+' '+esc(lvShort(o.leaveGb))+(o.status==='신청'?' (신청)':'')+'</span>'; }).join('')+'</div></div>'; }).join('')+'</div>';
    h+='<p class="note" style="margin:8px 0 0">등록·수정·승인은 PC 웹 「직원관리 ▸ 직원 휴가 관리」에서 합니다. 점선 = 승인 대기.</p>';
    el.innerHTML=h;
  }).catch(function(e){ el.innerHTML=errHtml('loadLv'); });
}

/* ④ 받을금액·지급할금액 = 거래처별 채권·채무(selectCustBalance) 누적 방식.
      기초잔액 개념이 없어 «기준월 말까지 전 기간 누계»가 곧 잔액이다(PC 화면과 같다).
      받을금액 = (매출 − 매출할인) − 수금 · 지급할금액 = (매입 − 매입할인) − 지급. 매출은 정산서·판매전표만(추정분 제외). */
function loadBal(){
  var el=$('cBal'); el.innerHTML='<div class="loading">불러오는 중…</div>';
  var YM=ym6(D); $('balLbl').textContent=lblMon(D)+' 말 기준';
  post('/mangr/selectCustBalance.do',{}).then(function(res){
    var m={}, ord=[], tr=0, tp=0;
    (res.data||[]).forEach(function(r){
      if(ym6(r.ym)>YM) return;
      var k=String(r.custCd||''); if(!m[k]){ m[k]={ nm:r.custNm||k, r:0, p:0 }; ord.push(k); }
      var rv=n(r.saleAmt)-n(r.saleDcAmt)-n(r.rcvAmt), pv=n(r.purchAmt)-n(r.purchDcAmt)-n(r.payAmt);
      m[k].r+=rv; m[k].p+=pv; tr+=rv; tp+=pv;
    });
    var all=ord.map(function(k){ return m[k]; });
    var topR=all.filter(function(o){ return Math.round(o.r)>0; }).sort(function(a,b){ return b.r-a.r; });
    var topP=all.filter(function(o){ return Math.round(o.p)>0; }).sort(function(a,b){ return b.p-a.p; });
    var h='<div class="tiles">'+tile('받을금액',fmt(tr),'teal',topR.length+'곳')+tile('지급할금액',fmt(tp),'blue',topP.length+'곳')+'</div>';
    function top(list, key){
      if(!list.length) return '<p class="note">없음</p>';
      return '<div class="list">'+list.slice(0,5).map(function(o){ return '<div class="row"><div class="k">'+esc(o.nm)+'</div><div class="v">'+fmt(o[key])+'</div></div>'; }).join('')+'</div>';
    }
    h+='<details><summary>많은 순 5곳 보기</summary>'
      +'<h3 class="h3">받을금액</h3>'+top(topR,'r')+'<h3 class="h3">지급할금액</h3>'+top(topP,'p')+'</details>';
    h+='<p class="note">매출은 정산서·판매전표만 셉니다(정산서 오기 전 출고의 추정분은 빠짐) — PC 「거래처별 채권·채무」와 같은 기준.</p>';
    el.innerHTML=h;
  }).catch(function(){ el.innerHTML=errHtml('loadBal'); });
}

/* ⑤ 재고 = 현재고 요약(/prod/stockQtyMap.do — 가벼운 조회). 마이너스 재고 품목은 [보기]를 눌렀을 때만
      품목명이 있는 재고현황(stockStatusList)을 읽는다(무거운 조회라 미리 부르지 않는다).
      재고는 기준일과 무관한 «지금» 값이다. */
function loadStk(){
  var el=$('cStk'); el.innerHTML='<div class="loading">불러오는 중…</div>';
  post('/prod/stockQtyMap.do',{}).then(function(res){
    var rows=res.data||[], neg=rows.filter(function(r){ return n(r.curQty)<0; }).length;
    el.innerHTML='<div class="tiles">'+tile('마이너스 재고',neg?neg.toLocaleString()+'품목':'—',neg?'red':'','입고 누락 신호')
      +tile('재고 품목',rows.length.toLocaleString()+'품목')+'</div>'
      +(neg?'<button type="button" class="btn2" onclick="loadNeg(this)">마이너스 품목 보기</button><div id="negList"></div>':'')
      +'<p class="note">기준일과 상관없이 지금 재고입니다.</p>';
  }).catch(function(){ el.innerHTML=errHtml('loadStk'); });
}
function loadNeg(btn){
  btn.disabled=true; btn.textContent='불러오는 중…';
  post('/prod/stockStatusList.do',{ findData:'' }).then(function(res){
    var list=(res.data||[]).filter(function(r){ return n(r.curQty)<0; }).sort(function(a,b){ return n(a.curQty)-n(b.curQty); });
    btn.remove();
    $('negList').innerHTML='<div class="list">'+list.slice(0,50).map(function(r){
      return '<div class="row"><div class="k">'+esc(r.prodNm||r.prodCd)+'<small>'+esc(r.prodCd)+'</small></div><div class="v" style="color:var(--red)">'+fmtQ(r.curQty)+'</div></div>';
    }).join('')+'</div>'+(list.length>50?'<p class="note">많은 순 50개만 보입니다(전체 '+list.length+'품목).</p>':'');
  }).catch(function(){ btn.disabled=false; btn.textContent='다시 보기'; _alertBox('재고 품목을 불러오지 못했습니다.',{icon:'❌',okColor:'red'}); });
}

/* ---------- 시작 ---------- */
M.tabbar('index');
$('dt').value=D;
loadAll();
// 앱으로 돌아왔을 때 5분 넘게 지났으면 새로 부른다(세션 확인 포함)
document.addEventListener('visibilitychange',function(){ if(document.visibilityState==='visible' && Date.now()-_lastLoad>300000) loadAll(); });
</script>
</body>
</html>
