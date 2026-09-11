/* 코네트 모바일(PWA) 공통 스크립트 — 요약·판매·수금지급·재고 네 화면이 함께 쓴다 (2026-09-11).
 *
 * ★모든 서버 요청은 M.form / M.json 으로 보낸다 — 헤더 `X-Konet-M` 를 붙여서.
 *   서버의 MobileGuardFilter 가 이 헤더가 달린 요청에서 세션이 없으면 401 로 거절한다
 *   (기존 엔드포인트는 세션을 안 봐서, 세션이 끊긴 채 부르면 전 회사 자료가 오고 저장은 기본 회사로 들어간다).
 *   401 이 오면 모바일 로그인으로 보낸다.
 * ★저장·삭제 응답은 문자열이 한 번 더 JSON 으로 싸여 올 수 있다(메시지 변환기가 Jackson 하나뿐) — M.body 가 풀어 준다.
 * 컨텍스트 경로는 이 파일의 <script src> 에서 뽑는다(화면 전역변수에 기대지 않는다).
 */
(function(){
  var me = document.currentScript || (function(){ var s=document.getElementsByTagName('script'); return s[s.length-1]; })();
  var CTX = (me && me.src) ? new URL(me.src, location.href).pathname.replace(/\/m\/m\.js$/, '') : '';

  if (typeof window._alertBox !== 'function') { window._alertBox = function(m){ alert(String(m).replace(/<[^>]*>/g,'')); }; }
  if (typeof window._confirmBox !== 'function') { window._confirmBox = function(o){ if(confirm(String(o.msg).replace(/<[^>]*>/g,''))&&o.onOk) o.onOk(); }; }
  if (typeof window._toast !== 'function') { window._toast = function(m){ console.log(m); }; }

  var M = window.M = { CTX: CTX };

  /* ---------- 도우미 ---------- */
  M.$ = function(id){ return document.getElementById(id); };
  M.n = function(v){ if(typeof v==='string') v=v.replace(/,/g,''); v=+v; return isFinite(v) ? v : 0; };
  M.fmt  = function(v){ v=Math.round(M.n(v)); return v===0 ? '—' : v.toLocaleString('ko-KR'); };          // 화면 규칙 6 : 빈 값은 —
  M.fmt0 = function(v){ return Math.round(M.n(v)).toLocaleString('ko-KR'); };                               // 0 도 0 으로(합계·잔고)
  M.fmtQ = function(v){ v=Math.round(M.n(v)*10)/10; return v===0 ? '—' : v.toLocaleString('ko-KR'); };
  M.fmtP = function(v){ v=M.n(v); return v===0 ? '—' : v.toLocaleString('ko-KR',{maximumFractionDigits:2}); };  // 단가만 소수 2자리
  M.esc = function(s){ return String(s==null?'':s).replace(/[&<>"']/g,function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); };
  function pad(x){ return (x<10?'0':'')+x; }
  M.ymd = function(d){ d=d||new Date(); return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate()); };
  M.addDay = function(s,k){ var d=new Date(s+'T00:00:00'); d.setDate(d.getDate()+k); return M.ymd(d); };
  M.ym6 = function(s){ return String(s||'').replace(/-/g,'').slice(0,6); };
  M.d10 = function(s){ s=String(s||'').replace(/-/g,''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : s; };
  M.lblDay = function(s){ var d=new Date(M.d10(s)+'T00:00:00'); return (d.getMonth()+1)+'월 '+d.getDate()+'일 ('+'일월화수목금토'.charAt(d.getDay())+')'; };
  M.lblMon = function(s){ s=M.d10(s); return s.slice(0,4)+'년 '+(+s.slice(5,7))+'월'; };
  M.norm = function(s){ return String(s==null?'':s).toLowerCase().replace(/\s+/g,''); };

  /* ---------- 서버 요청 ---------- */
  function goLogin(){ location.replace(CTX+'/m/login.do'); }
  /** 응답 본문 풀기 — JSON 이면 객체, 문자열이 한 번 더 싸여 있으면 한 겹 더 벗긴다 */
  M.body = function(r){
    return r.text().then(function(t){
      var v=t;
      try{ v=JSON.parse(t); if(typeof v==='string'){ try{ v=JSON.parse(v); }catch(e){} } }catch(e){}
      if(r.status===401 && v && v.login){ goLogin(); throw new Error('로그인이 끊겼습니다.'); }
      if(!r.ok){ throw new Error((typeof v==='string' && v) ? v : ('서버 오류 (HTTP '+r.status+')')); }
      return v;
    });
  };
  function send(url, body, type){
    return fetch(CTX+url, { method:'POST', credentials:'same-origin',
      headers:{ 'Content-Type':type, 'X-Konet-M':'1' }, body:body }).then(M.body);
  }
  M.form = function(url, params){
    var b=Object.keys(params||{}).map(function(k){ var v=params[k]; return encodeURIComponent(k)+'='+encodeURIComponent(v==null?'':v); }).join('&');
    return send(url, b, 'application/x-www-form-urlencoded');
  };
  M.json = function(url, obj){ return send(url, JSON.stringify(obj||{}), 'application/json'); };
  M.errMsg = function(e){ var m=(e&&e.message)||''; return /Failed to fetch|NetworkError|Load failed/i.test(m) ? '서버에 연결하지 못했습니다. 인터넷 연결을 확인하세요.' : (m||'오류가 발생했습니다.'); };

  /** 로그인 확인 — 자료를 부르기 전에. 머리줄 #who 에 회사·사용자 이름 */
  M.session = function(){
    return M.form('/m/session.do',{}).then(function(s){
      if(!s || !s.ok){ goLogin(); throw new Error('login'); }
      var w=M.$('who'); if(w) w.textContent=(s.compNm||'')+(s.userNm?' · '+s.userNm:'');
      M.user=s; return s;
    });
  };
  M.logout = function(){
    _confirmBox({ msg:'로그아웃할까요?', icon:'🚪', okText:'로그아웃', okColor:'blue', onOk:function(){ location.href=CTX+'/m/logout.do'; } });
  };

  /* ---------- 아래 탭 ---------- */
  M.TABS = [
    { k:'index',  href:'/m/index.do',  i:'📊', t:'요약' },
    { k:'sales',  href:'/m/sales.do',  i:'🧾', t:'판매등록' },
    { k:'settle', href:'/m/settle.do', i:'💳', t:'수금·지급' },
    { k:'stock',  href:'/m/stock.do',  i:'📦', t:'재고·상품' }
  ];
  M.tabbar = function(active){
    var nav=document.createElement('nav'); nav.className='tabbar';
    nav.innerHTML='<div class="in">'+M.TABS.map(function(t){
      return '<a href="'+CTX+t.href+'"'+(t.k===active?' class="on" aria-current="page"':'')+'><i>'+t.i+'</i>'+t.t+'</a>';
    }).join('')+'</div>';
    document.body.appendChild(nav);
  };

  /* ---------- 아래에서 올라오는 선택 창 ----------
     M.sheet({ title, placeholder, opt:{label, checked}, list:function(q, optOn){ return [{html, dis, v}] }, onPick:function(v){} })
     list 는 검색어가 바뀔 때마다 불린다(화면이 이미 들고 있는 목록을 거르는 용도 — 서버를 부르지 않는다). */
  var _sh=null;
  function sheetDom(){
    if(_sh) return _sh;
    var bd=document.createElement('div'); bd.className='sheet-bd';
    var el=document.createElement('div'); el.className='sheet'; el.setAttribute('role','dialog');
    el.innerHTML='<div class="sh"><h3></h3><button type="button" class="x" aria-label="닫기">✕</button></div>'
      +'<div class="sf"><input class="inp" type="search" autocomplete="off"><label class="sopt" hidden><input type="checkbox"><span></span></label></div>'
      +'<div class="sb"></div>';
    document.body.appendChild(bd); document.body.appendChild(el);
    _sh={ bd:bd, el:el, h:el.querySelector('h3'), q:el.querySelector('.sf input.inp'), optL:el.querySelector('.sopt'),
          opt:el.querySelector('.sopt input'), optT:el.querySelector('.sopt span'), b:el.querySelector('.sb'), cfg:null, rows:[] };
    bd.onclick=M.sheetClose; el.querySelector('.x').onclick=M.sheetClose;
    _sh.q.oninput=sheetDraw; _sh.opt.onchange=sheetDraw;
    _sh.b.onclick=function(e){
      var r=e.target.closest('[data-i]'); if(!r) return;
      var it=_sh.rows[+r.getAttribute('data-i')]; if(!it || it.dis) return;
      var cb=_sh.cfg.onPick; M.sheetClose(); if(cb) cb(it.v);
    };
    return _sh;
  }
  function sheetDraw(){
    var s=_sh, rows=s.cfg.list(s.q.value.trim(), s.opt.checked)||[];
    s.rows=rows;
    s.b.innerHTML = rows.length
      ? '<div class="list" style="margin-top:0">'+rows.map(function(r,i){ return '<div class="row tap'+(r.dis?' dis':'')+'" data-i="'+i+'">'+r.html+'</div>'; }).join('')+'</div>'
      : '<div class="empty">'+(s.cfg.emptyMsg ? s.cfg.emptyMsg(s.q.value.trim()) : '찾는 항목이 없습니다.')+'</div>';
  }
  M.sheet = function(cfg){
    var s=sheetDom(); s.cfg=cfg; s.q.parentNode.hidden=false;
    s.h.textContent=cfg.title||''; s.q.placeholder=cfg.placeholder||'검색'; s.q.value=cfg.q||'';
    s.optL.hidden=!cfg.opt; if(cfg.opt){ s.optT.textContent=cfg.opt.label; s.opt.checked=!!cfg.opt.checked; }
    sheetDraw();
    s.bd.classList.add('on'); requestAnimationFrame(function(){ s.el.classList.add('on'); });
    if(cfg.focus!==false) setTimeout(function(){ s.q.focus(); }, 220);
  };
  /** 검색칸 없이 내용만 보여 주는 창(상세 보기용). 돌려준 요소에 나중에 더 그려 넣어도 된다. */
  M.sheetHtml = function(title, html){
    var s=sheetDom(); s.cfg={ list:function(){ return []; } }; s.rows=[];
    s.q.parentNode.hidden=true; s.h.textContent=title||''; s.b.innerHTML=html||'';
    s.bd.classList.add('on'); requestAnimationFrame(function(){ s.el.classList.add('on'); });
    s.b.scrollTop=0; return s.b;
  };
  M.sheetRedraw = function(){ if(_sh && _sh.cfg) sheetDraw(); };
  M.sheetClose = function(){ if(!_sh) return; _sh.el.classList.remove('on'); _sh.bd.classList.remove('on'); _sh.q.blur(); };

  /* ---------- 거래처 ----------
     목록은 PC 판매·수금·지급 화면과 같은 /vendor/selectVendorMst.do (한 번만 읽는다).
     gb('매출'|'매입') 를 주면 그 구분 거래처만 먼저 보여 주고 「전체 거래처」 체크로 넓힌다
     — 구분이 빈 거래처는 양쪽 다 보인다(PC 판매등록 saVenFit 과 같은 규칙). */
  var _ven=null;
  M.vendors = function(){
    if(_ven) return Promise.resolve(_ven);
    return M.form('/vendor/selectVendorMst.do',{}).then(function(res){ _ven=res.data||[]; return _ven; });
  };
  function venScore(v, q){
    var cd=M.norm(v.vendorCd), nm=M.norm(v.vendorNm);
    if(cd===q) return 0;
    if(cd.indexOf(q)===0) return 1;
    if(nm.indexOf(q)===0) return 2;
    if(nm.indexOf(q)>=0) return 3;
    if([v.fullNm,v.alias,v.ceoNm,v.mgrNm,v.bizno].some(function(x){ return M.norm(x).indexOf(q)>=0; })) return 4;
    return -1;
  }
  M.pickVendor = function(opt, onPick){
    opt=opt||{};
    M.vendors().then(function(list){
      M.sheet({
        title: opt.title||'거래처 선택', placeholder:'거래처명 · 코드 · 대표자',
        opt: opt.gb ? { label:'전체 거래처 보기 ('+opt.gb+' 외 포함)', checked:false } : null,
        list: function(q, all){
          var qn=M.norm(q), out=[];
          list.forEach(function(v){
            if(opt.gb && !all){ var g=String(v.vendorGb||''); if(g && g.indexOf(opt.gb)<0) return; }
            var sc = qn ? venScore(v, qn) : 5;
            if(sc<0) return;
            out.push({ sc:sc, v:v });
          });
          out.sort(function(a,b){ return a.sc-b.sc; });
          return out.slice(0,80).map(function(o){ var v=o.v;
            return { v:v, html:'<div class="k">'+M.esc(v.vendorNm)+'<small>'+M.esc(v.vendorCd)
              +(v.vendorGb?' · '+M.esc(v.vendorGb):'')+(v.ceoNm?' · '+M.esc(v.ceoNm):'')+'</small></div>' };
          });
        },
        emptyMsg: function(q){ return q ? '「'+M.esc(q)+'」 거래처가 없습니다.' : '거래처가 없습니다.'; },
        onPick: onPick
      });
    }).catch(function(e){ _alertBox('거래처 목록을 불러오지 못했습니다.<br>'+M.esc(M.errMsg(e)),{icon:'❌',okColor:'red'}); });
  };

  /* ---------- 거래처 잔고 = custLedger 누계 (PC 수금·판매·지급 화면과 같은 식) ----------
     기초잔액 개념이 없어 처음부터의 누계가 곧 지금 잔고다.
     받을금액 = 매출 − 매출할인 − 수금 − 할인 / 지급할금액 = 매입 − 지급 − 할인 */
  M.balance = function(custCd){
    return M.form('/mangr/custLedger.do',{ custCd:custCd }).then(function(res){
      var r=0, p=0;
      (res.data||[]).forEach(function(x){
        r += M.n(x.saleAmt) - M.n(x.dcAmt) - M.n(x.rcvAmt) - M.n(x.discAmt);
        p += M.n(x.purchAmt) - M.n(x.payAmt) - M.n(x.discAmt);
      });
      return { recv:r, pay:p, rows:res.data||[] };
    });
  };

  /* ---------- 숫자 입력칸 : 콤마 표시 ---------- */
  M.numIn = function(el, onChange, decimals){
    el.addEventListener('focus', function(){ var v=M.n(el.value); el.value = v ? String(v) : ''; setTimeout(function(){ try{ el.select(); }catch(e){} },0); });
    el.addEventListener('blur', function(){ var v=M.n(el.value); el.value = v ? v.toLocaleString('ko-KR',{maximumFractionDigits:decimals||0}) : ''; });
    el.addEventListener('input', function(){ if(onChange) onChange(M.n(el.value)); });
  };
  M.setNum = function(el, v, decimals){ v=M.n(v); el.value = v ? v.toLocaleString('ko-KR',{maximumFractionDigits:decimals||0}) : ''; };

  /* ---------- 서비스워커 ---------- */
  if('serviceWorker' in navigator){ navigator.serviceWorker.register(CTX+'/m/sw.js',{scope:CTX+'/m/'}).catch(function(){}); }
})();
