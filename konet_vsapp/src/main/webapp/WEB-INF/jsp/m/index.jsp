<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 모바일(PWA) 요약 — /m/index.do (MobileController, 로그인 필수).
     카드 5장 : ①그날 장부(일계장) ②이번 달 매출·순마진 ③출고 ④받을금액·지급할금액 ⑤재고 마이너스
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
<script src="<%=request.getContextPath()%>/asset/js/ui-message.js"></script>
<style>
  :root{ --teal:#137a6c; --teal-d:#0e6657; --teal-l:#eaf2f0; --bd:#dbe4e1; --ink:#1f2a37; --mute:#6b7785;
         --bg:#f4f7f6; --card:#fff; --red:#c62828; --blue:#1f5fbf; --amber:#a15c00; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; background:var(--bg); color:var(--ink);
    font-family:"Pretendard Variable",Pretendard,"Malgun Gothic",sans-serif; -webkit-text-size-adjust:100%; }
  .num,.tile b,.row .v{ font-variant-numeric:tabular-nums; }

  header{ position:sticky; top:0; z-index:10; background:var(--teal); color:#fff;
    padding:calc(10px + env(safe-area-inset-top)) 14px 10px; }
  .hd1{ display:flex; align-items:center; gap:10px; max-width:560px; margin:0 auto; }
  .hd1 h1{ margin:0; font-size:18px; font-weight:800; }
  .hd1 .who{ flex:1; font-size:12px; opacity:.85; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .hd1 button{ background:rgba(255,255,255,.16); color:#fff; border:0; border-radius:8px; height:32px; padding:0 10px;
    font:inherit; font-size:13px; }
  .datebar{ display:flex; align-items:center; gap:6px; max-width:560px; margin:10px auto 0; }
  .datebar button{ height:38px; min-width:38px; border:0; border-radius:8px; background:rgba(255,255,255,.16); color:#fff;
    font:inherit; font-size:15px; }
  .datebar input{ flex:1; height:38px; border:0; border-radius:8px; padding:0 10px; font:inherit; font-size:16px;
    color:var(--ink); background:#fff; min-width:0; }
  .datebar .today{ padding:0 12px; font-size:14px; }

  main{ max-width:560px; margin:0 auto; padding:12px 12px calc(24px + env(safe-area-inset-bottom)); }
  .card{ background:var(--card); border:1px solid var(--bd); border-radius:14px; padding:14px; margin-bottom:12px; }
  .card h2{ display:flex; align-items:baseline; gap:8px; margin:0 0 10px; font-size:16px; font-weight:800; color:var(--teal-d); }
  .card h2 small{ font-size:12px; font-weight:500; color:var(--mute); }
  .card h2 .badge{ margin-left:auto; font-size:12px; font-weight:700; padding:3px 8px; border-radius:20px;
    background:#fff4e0; color:var(--amber); }
  .card h2 .badge.ok{ background:var(--teal-l); color:var(--teal-d); }

  .tiles{ display:grid; grid-template-columns:1fr 1fr; gap:8px; }
  .tile{ background:#f8fbfa; border:1px solid #e6eeeb; border-radius:10px; padding:9px 11px; min-width:0; }
  .tile span{ display:block; font-size:12px; font-weight:600; color:var(--mute); }
  .tile b{ display:block; font-size:19px; font-weight:800; margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .tile b.long{ font-size:16px; letter-spacing:-.2px; }
  .tile b.red{ color:var(--red); } .tile b.blue{ color:var(--blue); } .tile b.teal{ color:var(--teal-d); }
  .tile em{ display:block; font-style:normal; font-size:11.5px; color:var(--mute); margin-top:1px; }

  .note{ font-size:12px; color:var(--mute); margin:8px 0 0; line-height:1.45; }
  .list{ margin-top:10px; border-top:1px solid #edf2f0; }
  .row{ display:flex; align-items:center; gap:8px; padding:8px 2px; border-bottom:1px solid #edf2f0; font-size:14px; }
  .row .k{ flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .row .k small{ display:block; font-size:11.5px; color:var(--mute); white-space:normal; }
  .row .v{ font-weight:700; white-space:nowrap; text-align:right; }
  .row .v small{ display:block; font-weight:500; font-size:11.5px; color:var(--mute); }
  .bar{ height:5px; border-radius:3px; background:#e6eeeb; margin-top:4px; overflow:hidden; }
  .bar i{ display:block; height:100%; background:var(--teal); border-radius:3px; }
  .jk{ color:var(--red); }

  details{ margin-top:10px; }
  details summary{ cursor:pointer; font-size:13.5px; font-weight:700; color:var(--teal-d); padding:6px 0; list-style:none; }
  details summary::-webkit-details-marker{ display:none; }
  details summary::before{ content:'▸ '; }
  details[open] summary::before{ content:'▾ '; }
  .h3{ margin:10px 0 0; font-size:13px; color:var(--mute); }

  .btn2{ display:inline-block; margin-top:10px; height:34px; padding:0 14px; border:1px solid var(--teal); border-radius:8px;
    background:#fff; color:var(--teal-d); font:inherit; font-size:14px; font-weight:700; }
  .loading{ color:var(--mute); font-size:13px; padding:10px 0; }
  .err{ color:var(--red); font-size:13px; padding:8px 0; }
  .err button{ margin-left:6px; border:1px solid var(--red); background:#fff; color:var(--red); border-radius:6px; height:28px; font:inherit; font-size:12.5px; }
  footer{ text-align:center; font-size:12px; color:var(--mute); padding:4px 0 10px; }
  footer a{ color:var(--mute); }
</style>
</head>
<body>
<header>
  <div class="hd1">
    <h1>코네트</h1>
    <div class="who" id="who"></div>
    <button type="button" onclick="loadAll()" title="다시 불러오기">↻</button>
    <button type="button" onclick="mLogout()">로그아웃</button>
  </div>
  <div class="datebar">
    <button type="button" onclick="shiftDay(-1)" aria-label="전날">◀</button>
    <input type="date" id="dt" onchange="setDay(this.value)">
    <button type="button" onclick="shiftDay(1)" aria-label="다음날">▶</button>
    <button type="button" class="today" onclick="setDay(ymd(new Date()))">오늘</button>
  </div>
</header>

<main>
  <section class="card"><h2>📒 그날 장부 <small id="dayLbl"></small></h2><div id="cDay" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>💰 이번 달 매출 <small id="monLbl"></small><span class="badge" id="closeBadge" hidden></span></h2><div id="cMon" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>🚚 출고 <small id="shipLbl"></small></h2><div id="cShip" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>📊 받을금액 · 지급할금액 <small id="balLbl"></small></h2><div id="cBal" class="loading">불러오는 중…</div></section>
  <section class="card"><h2>📦 재고</h2><div id="cStk" class="loading">불러오는 중…</div></section>
  <footer><a href="<%=request.getContextPath()%>/konet.do">PC 화면으로 열기</a></footer>
</main>

<script>
var CTX = '<%=request.getContextPath()%>';
if (typeof window._alertBox !== 'function') { window._alertBox = function(m){ alert(String(m).replace(/<[^>]*>/g,'')); }; }
if (typeof window._confirmBox !== 'function') { window._confirmBox = function(o){ if(confirm(String(o.msg).replace(/<[^>]*>/g,''))&&o.onOk) o.onOk(); }; }

/* ---------- 도우미 ---------- */
function $(id){ return document.getElementById(id); }
function n(v){ v=+v; return isFinite(v) ? v : 0; }
function fmt(v){ v=Math.round(n(v)); return v===0 ? '—' : v.toLocaleString('ko-KR'); }          // 화면 규칙 6 : 빈 값은 —
function fmtQ(v){ v=Math.round(n(v)*10)/10; return v===0 ? '—' : v.toLocaleString('ko-KR'); }
function esc(s){ return String(s==null?'':s).replace(/[&<>"']/g,function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }
function pad(x){ return (x<10?'0':'')+x; }
function ymd(d){ return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); }
function ym6(s){ return String(s||'').replace(/-/g,'').slice(0,6); }
function lblDay(s){ var d=new Date(s+'T00:00:00'); return (d.getMonth()+1)+'월 '+d.getDate()+'일 ('+'일월화수목금토'.charAt(d.getDay())+')'; }
function lblMon(s){ return s.slice(0,4)+'년 '+(+s.slice(5,7))+'월'; }
function post(url, params){
  var b=Object.keys(params||{}).map(function(k){ return encodeURIComponent(k)+'='+encodeURIComponent(params[k]); }).join('&');
  return fetch(CTX+url,{ method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:b })
    .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); });
}
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
    if(!s.ok){ location.replace(CTX+'/m/login.do'); return; }
    $('who').textContent = (s.compNm||'') + (s.userNm ? ' · '+s.userNm : '');
    loadDay(); loadMon(); loadShip(); loadBal(); loadStk();
  }).catch(function(){
    ['cDay','cMon','cShip','cBal','cStk'].forEach(function(id){ $(id).innerHTML='<div class="err">서버에 연결하지 못했습니다.<button type="button" onclick="loadAll()">다시</button></div>'; });
  });
}
function mLogout(){
  _confirmBox({ msg:'로그아웃할까요?', icon:'🚪', okText:'로그아웃', onOk:function(){ location.href=CTX+'/m/logout.do'; } });
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
$('dt').value=D;
loadAll();
// 앱으로 돌아왔을 때 5분 넘게 지났으면 새로 부른다(세션 확인 포함)
document.addEventListener('visibilitychange',function(){ if(document.visibilityState==='visible' && Date.now()-_lastLoad>300000) loadAll(); });
if('serviceWorker' in navigator){ navigator.serviceWorker.register(CTX+'/m/sw.js',{scope:CTX+'/m/'}).catch(function(){}); }
</script>
</body>
</html>
