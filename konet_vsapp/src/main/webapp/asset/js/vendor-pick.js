/* =====================================================================
   거래처 입력검색 (typeahead) — 판매등록·매입등록·수금등록·지급등록 공용
   ---------------------------------------------------------------------
   종전에는 [거래처] 버튼으로 팝업을 열어야만 고를 수 있었다. 거래처명을
   아는 경우가 대부분이라 칸에 바로 쳐서 고를 수 있게 한다(2026-08-01 요청).

   사용법: 페이지에 <script src="/asset/js/vendor-pick.js"></script> 한 줄 추가 후
     _vendorPick(document.getElementById('saVenNm'), {
       list   : function(){ return _vendors; },        // 거래처 마스터(늦게 도착하므로 '함수'로 넘긴다)
       onPick : function(o){ saVenPick(o.vendorCd); }, // 고르면 페이지의 기존 pick 함수를 그대로 부른다
       onClear: function(){ saVenPick2(''); }          // 칸을 비웠을 때(선택 해제) — 없으면 생략 가능
     });

   설계 메모
   · **고르는 동작은 페이지가 갖고 있는 기존 pick 함수를 그대로 부른다.** 잔고·원장·담당자
     갱신이 전부 거기 붙어 있어서, 여기서 값만 넣으면 화면이 반쪽만 바뀐다.
   · **[거래처] 팝업은 그대로 둔다** — 이름을 모를 때 목록을 훑는 용도. 두 방법이 같은
     `_vendors` 배열을 보므로 결과가 어긋날 일이 없다.
   · **이름과 코드가 어긋난 상태를 만들지 않는다** — 칸을 떠날 때 글자가 고른 거래처와
     다르면 되돌린다(후보가 딱 하나면 그걸로 확정). 실제 값은 `input.dataset.cd`.
   · CSS 는 이 파일이 자동 주입. jQuery 불필요(순수 JS).
   ===================================================================== */
(function(){
  if (window._vendorPickLoaded) return;   // 중복 로드 방지
  window._vendorPickLoaded = true;

  var MAX = 60;   // 한 번에 보여 줄 최대 후보 수 (거래처가 400여 종이라 전부 그리면 느리다)

  /* ── CSS 주입 ── */
  var CSS =
    '.vp-dd{position:fixed;z-index:9998;display:none;background:#fff;border:1px solid #cfd8e3;border-radius:8px;'
  + 'box-shadow:0 8px 24px rgba(0,0,0,.16);max-height:300px;overflow:auto;font-size:13px;color:#22313f;}'
  + '.vp-dd.on{display:block;}'
  + '.vp-it{display:flex;gap:8px;align-items:baseline;padding:6px 10px;cursor:pointer;white-space:nowrap;}'
  + '.vp-it+.vp-it{border-top:1px solid #eef2f6;}'
  + '.vp-it.on,.vp-it:hover{background:#e8f5f1;}'
  + '.vp-cd{flex:0 0 88px;color:#137a6c;font-weight:700;}'
  + '.vp-nm{font-weight:600;overflow:hidden;text-overflow:ellipsis;}'
  + '.vp-sub{margin-left:auto;padding-left:12px;color:#6b7c8c;font-size:12px;}'
  + '.vp-tag{flex:0 0 auto;padding:0 6px;border-radius:9px;font-size:11px;font-weight:800;line-height:17px;}'
  + '.vp-tag.gb{background:#e9f4f1;color:#137a6c;border:1px solid #b9ded4;}'
  + '.vp-tag.gb.both{background:#eef0ff;color:#3f43a8;border-color:#c9cdf3;}'
  + '.vp-tag.vat{background:#eef3f2;color:#37475a;border:1px solid #cfd8e3;}'
  + '.vp-tag.vat.inc{background:#eaf3ff;color:#1a56a8;border-color:#b9d3f2;}'
  + '.vp-tag.vat.free{background:#fff1e8;color:#b45309;border-color:#f0c9a4;}'
  + '.vp-msg{padding:10px;color:#6b7c8c;text-align:center;}'
  + '.vp-more{padding:6px 10px;color:#6b7c8c;font-size:12px;text-align:center;border-top:1px solid #eef2f6;background:#fafcfd;}'
  + '.vp-hit{background:#ffe9a8;border-radius:2px;}';

  function injectCss(){
    if (document.querySelector('style[data-vendor-pick]')) return;
    var s = document.createElement('style');
    s.setAttribute('data-vendor-pick','1');
    s.textContent = CSS;
    (document.head || document.documentElement).appendChild(s);
  }

  function esc(s){
    return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;')
                               .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }
  /* 검색어가 걸린 부분만 노랗게. 원문을 잘라 각 조각을 escape 한 뒤 합친다(주입 방지).
     q2 = 영타→한글 변환 검색어(있으면) — 원검색어가 안 걸릴 때 이걸로 칠한다. */
  function hi(s, q, q2){
    s = String(s==null?'':s);
    if(!q && !q2) return esc(s);
    var i = q ? s.toLowerCase().indexOf(q) : -1, n = q ? q.length : 0;
    if(i < 0 && q2){ i = s.toLowerCase().indexOf(q2); n = q2.length; }
    if(i < 0) return esc(s);
    return esc(s.slice(0,i)) + '<b class="vp-hit">' + esc(s.slice(i,i+n)) + '</b>' + esc(s.slice(i+n));
  }

  /* ── 영타→한글 변환 (한/영 모드를 브라우저가 못 바꾸므로, 영문 상태로 쳐도 찾아지게) ──
     "eodudwjstks" → "대영전산". 두벌식 자판 배열 그대로 자모를 조합한다.
     · 대문자 = 쌍자음/이중모음 키(R=ㄲ, O=ㅒ …), 그 외 대문자는 소문자 취급
     · 영문·한글이 섞여 있어도 영문 조각만 변환된다(숫자·기호는 그대로) */
  var _CHO = ['ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
  var _JUN = ['ㅏ','ㅐ','ㅑ','ㅒ','ㅓ','ㅔ','ㅕ','ㅖ','ㅗ','ㅘ','ㅙ','ㅚ','ㅛ','ㅜ','ㅝ','ㅞ','ㅟ','ㅠ','ㅡ','ㅢ','ㅣ'];
  var _JON = ['','ㄱ','ㄲ','ㄳ','ㄴ','ㄵ','ㄶ','ㄷ','ㄹ','ㄺ','ㄻ','ㄼ','ㄽ','ㄾ','ㄿ','ㅀ','ㅁ','ㅂ','ㅄ','ㅅ','ㅆ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
  var _KEY = { r:'ㄱ',R:'ㄲ',s:'ㄴ',e:'ㄷ',E:'ㄸ',f:'ㄹ',a:'ㅁ',q:'ㅂ',Q:'ㅃ',t:'ㅅ',T:'ㅆ',d:'ㅇ',w:'ㅈ',W:'ㅉ',c:'ㅊ',z:'ㅋ',x:'ㅌ',v:'ㅍ',g:'ㅎ',
               k:'ㅏ',o:'ㅐ',i:'ㅑ',O:'ㅒ',j:'ㅓ',p:'ㅔ',u:'ㅕ',P:'ㅖ',h:'ㅗ',y:'ㅛ',n:'ㅜ',b:'ㅠ',m:'ㅡ',l:'ㅣ' };
  var _VC = {'ㅗㅏ':'ㅘ','ㅗㅐ':'ㅙ','ㅗㅣ':'ㅚ','ㅜㅓ':'ㅝ','ㅜㅔ':'ㅞ','ㅜㅣ':'ㅟ','ㅡㅣ':'ㅢ'};
  var _JC = {'ㄱㅅ':'ㄳ','ㄴㅈ':'ㄵ','ㄴㅎ':'ㄶ','ㄹㄱ':'ㄺ','ㄹㅁ':'ㄻ','ㄹㅂ':'ㄼ','ㄹㅅ':'ㄽ','ㄹㅌ':'ㄾ','ㄹㅍ':'ㄿ','ㄹㅎ':'ㅀ','ㅂㅅ':'ㅄ'};
  function _isV(j){ return _JUN.indexOf(j) >= 0; }
  function _isC(j){ return _CHO.indexOf(j) >= 0 || 'ㄳㄵㄶㄺㄻㄼㄽㄾㄿㅀㅄ'.indexOf(j) >= 0; }
  function engToKor(str){
    var jm = [], i, ch, j;
    for (i = 0; i < str.length; i++){
      ch = str.charAt(i);
      j = _KEY[ch] || _KEY[ch.toLowerCase()];
      jm.push(j || ch);
    }
    var out = '';
    i = 0;
    while (i < jm.length){
      var c = jm[i];
      if (!_isC(c) && !_isV(c)){ out += c; i++; continue; }
      if (_isV(c)){                                     // 초성 없는 모음 — 복모음만 붙여 낱자로
        var v0 = c; i++;
        if (i < jm.length && _VC[v0 + jm[i]]){ v0 = _VC[v0 + jm[i]]; i++; }
        out += v0; continue;
      }
      if (i + 1 >= jm.length || !_isV(jm[i+1])){ out += c; i++; continue; }   // 다음이 모음 아니면 낱자
      var cho = c; i++;
      var v = jm[i]; i++;
      if (i < jm.length && _VC[v + jm[i]]){ v = _VC[v + jm[i]]; i++; }
      var jong = '';
      if (i < jm.length && _isC(jm[i]) && !(i + 1 < jm.length && _isV(jm[i+1]))){
        jong = jm[i]; i++;
        if (i < jm.length && _isC(jm[i]) && _JC[jong + jm[i]] && !(i + 1 < jm.length && _isV(jm[i+1]))){
          jong = _JC[jong + jm[i]]; i++;
        }
      }
      var ci = _CHO.indexOf(cho), vi = _JUN.indexOf(v), gi = _JON.indexOf(jong);
      if (ci < 0 || vi < 0 || gi < 0){ out += cho + v + jong; continue; }
      out += String.fromCharCode(0xAC00 + (ci * 21 + vi) * 28 + gi);
    }
    return out;
  }

  window._vendorPick = function(input, opt){
    if (!input || input._vpBound) return;
    input._vpBound = true;
    injectCss();
    opt = opt || {};

    var getList = (typeof opt.list === 'function') ? opt.list : function(){ return opt.list || []; };
    var CD = opt.cdKey || 'vendorCd';
    var NM = opt.nmKey || 'vendorNm';
    var FIELDS = opt.fields || ['vendorCd','vendorNm','alias','ceoNm','mgrNm'];
    /* 후보 정렬 기준 — 페이지가 넘기면 큰 순으로 앞에 온다(매입등록=총매입, 판매등록=총판매).
       [거래처] 팝업과 같은 순서가 되게 한다(2026-08-05 요청). 없으면 종전과 같다. */
    var RANK = (typeof opt.rank === 'function') ? opt.rank : null;

    input.readOnly = false;                       // 팝업 전용 시절의 잠금 해제(JSP 를 못 고친 경우 대비)
    input.setAttribute('autocomplete','off');

    var dd = document.createElement('div');
    dd.className = 'vp-dd';
    document.body.appendChild(dd);

    var hits = [], act = -1;

    /* 현재 선택돼 있는 거래처(코드 기준). 되돌릴 때의 기준값이다. */
    function held(){
      var cd = input.dataset.cd || '';
      if(!cd) return null;
      var l = getList() || [];
      for(var i=0;i<l.length;i++) if(String(l[i][CD]) === String(cd)) return l[i];
      return null;
    }

    /* 마지막 검색의 영타→한글 변환어 — render() 가 강조 표시에 쓴다 */
    var lastQ2 = '';

    function match(q){
      var l = getList() || [];
      var raw = String(q||'').trim();
      q = raw.toLowerCase();
      /* 영문이 섞여 있으면 한글 변환어로도 같이 찾는다 — 한/영 키를 안 눌러도 걸리게(2026-08-05).
         코드·별칭처럼 진짜 영문인 값은 원검색어 쪽에서 그대로 걸리므로 잃는 것이 없다. */
      var q2 = '';
      if (raw && /[a-z]/i.test(raw)){
        var k = engToKor(raw);
        if (k !== raw) q2 = k.toLowerCase();
      }
      lastQ2 = q2;
      var out;
      if(!q){ out = l.slice(); }
      else{
        out = [];
        for(var i=0;i<l.length;i++){
          var o = l[i];
          for(var f=0; f<FIELDS.length; f++){
            var s = String(o[FIELDS[f]]==null?'':o[FIELDS[f]]).toLowerCase();
            if(s.indexOf(q) >= 0 || (q2 && s.indexOf(q2) >= 0)){ out.push(o); break; }
          }
        }
      }
      /* ① 이름이 검색어로 '시작'하는 거래처 먼저(정확히 아는 이름을 쳤을 때 맨 위)
         ② 그 안에서는 rank 큰 순(거래금액 많은 순) ③ 같으면 이름순 */
      out.sort(function(a,b){
        if(q){
          var an = String(a[NM]||'').toLowerCase(), bn = String(b[NM]||'').toLowerCase();
          var A = (an.indexOf(q) === 0 || (q2 && an.indexOf(q2) === 0)) ? 0 : 1;
          var B = (bn.indexOf(q) === 0 || (q2 && bn.indexOf(q2) === 0)) ? 0 : 1;
          if(A !== B) return A - B;
        }
        if(RANK){
          var d = (RANK(b)||0) - (RANK(a)||0);
          if(d) return d;
        }
        return String(a[NM]||'').localeCompare(String(b[NM]||''), 'ko');
      });
      return out;
    }

    function place(){
      var r = input.getBoundingClientRect();
      dd.style.left = Math.round(r.left) + 'px';
      dd.style.minWidth = Math.round(Math.max(r.width, 340)) + 'px';
      dd.style.top = Math.round(r.bottom + 2) + 'px';
      /* 아래 공간이 부족하면 위로 연다 — 이 칸들이 카드 위쪽에 있어 보통은 아래가 넉넉하다 */
      var h = dd.offsetHeight || 0;
      if (r.bottom + 4 + h > window.innerHeight && r.top > h) dd.style.top = Math.round(r.top - h - 2) + 'px';
    }

    function render(q){
      var all = match(q), more = 0;
      if (all.length > MAX){ more = all.length - MAX; all = all.slice(0, MAX); }
      hits = all; act = all.length ? 0 : -1;
      if(!all.length){
        dd.innerHTML = '<div class="vp-msg">' + ((getList()||[]).length ? '검색 결과가 없습니다.' : '거래처를 불러오는 중…') + '</div>';
      }else{
        var ql = String(q||'').trim().toLowerCase(), qk = lastQ2;
        dd.innerHTML = all.map(function(o,i){
          var sub = [o.alias, o.ceoNm, o.mgrNm].filter(function(x){ return x; }).join(' · ');
          /* 거래유형·부가세도 같이 보여 준다 (2026-08-03 요청) — 고르기 전에 성격을 알 수 있게.
             부가세가 비어 있는 예전 거래처는 '별도*' — 계산도 별도로 하고 있음을 별표로 알린다.
             (같은 표기를 거래처 팝업 목록에서도 쓴다) */
          var gb = String(o.vendorGb||''), vt = String(o.vatGb||'') || '별도';
          return '<div class="vp-it' + (i===0?' on':'') + '" data-i="' + i + '">'
               +   '<span class="vp-cd">' + hi(o[CD], ql, qk) + '</span>'
               +   '<span class="vp-nm">' + hi(o[NM], ql, qk) + '</span>'
               +   (gb ? '<span class="vp-tag gb' + (gb.indexOf('&')>=0?' both':'') + '">' + esc(gb) + '</span>' : '')
               +   '<span class="vp-tag vat' + (vt==='면세'?' free':(vt==='포함'?' inc':'')) + '">'
               +     esc(vt) + (o.vatGb?'':'*') + '</span>'
               +   (sub ? '<span class="vp-sub">' + hi(sub, ql, qk) + '</span>' : '')
               + '</div>';
        }).join('') + (more ? '<div class="vp-more">… 외 ' + more + '건 — 더 입력해 좁히세요</div>' : '');
      }
      dd.classList.add('on');
      dd.scrollTop = 0;
      place();
    }

    function close(){ dd.classList.remove('on'); act = -1; }

    function markAct(){
      var els = dd.querySelectorAll('.vp-it');
      for(var i=0;i<els.length;i++) els[i].classList.toggle('on', i===act);
      if(act >= 0 && els[act]){
        var e = els[act], top = e.offsetTop, bot = top + e.offsetHeight;
        if(top < dd.scrollTop) dd.scrollTop = top;
        else if(bot > dd.scrollTop + dd.clientHeight) dd.scrollTop = bot - dd.clientHeight;
      }
    }

    function pick(o){
      if(!o) return;
      close();
      if (opt.onPick) opt.onPick(o);
      else { input.value = o[NM] || ''; input.dataset.cd = o[CD] || ''; }
    }

    /* 칸을 떠날 때 — 글자와 코드가 어긋난 채로 남지 않게 정리한다 */
    function commit(){
      close();
      var cur = held(), txt = (input.value || '').trim();
      if(!txt){
        if(input.dataset.cd){ input.dataset.cd = ''; if(opt.onClear) opt.onClear(); }
        return;
      }
      if(cur && txt === String(cur[NM] || '')) return;      // 고른 그대로면 둔다
      var m = match(txt);
      if(m.length === 1){ pick(m[0]); return; }             // 후보가 딱 하나면 확정
      input.value = cur ? (cur[NM] || '') : '';             // 아니면 되돌린다
      if(!cur && input.dataset.cd){ input.dataset.cd = ''; if(opt.onClear) opt.onClear(); }
    }

    /* 목록 클릭 — mousedown 에서 기본동작을 막아 blur 가 먼저 나지 않게 한다 */
    dd.addEventListener('mousedown', function(e){ e.preventDefault(); });
    dd.addEventListener('click', function(e){
      var el = e.target;
      while(el && el !== dd && !(el.className && String(el.className).indexOf('vp-it') >= 0)) el = el.parentNode;
      if(!el || el === dd) return;
      pick(hits[+el.getAttribute('data-i')]);
    });

    input.addEventListener('input', function(){ render(input.value); });
    input.addEventListener('focus', function(){ render(input.value); });
    input.addEventListener('blur',  function(){ commit(); });

    input.addEventListener('keydown', function(e){
      var open = dd.classList.contains('on');
      if(e.key === 'ArrowDown' || e.key === 'ArrowUp'){
        if(!open){ render(input.value); return; }
        e.preventDefault();
        if(!hits.length) return;
        act = (e.key === 'ArrowDown') ? Math.min(act+1, hits.length-1) : Math.max(act-1, 0);
        markAct();
      }else if(e.key === 'Enter'){
        if(e.isComposing || e.keyCode === 229) return;      // 한글 조합 중의 Enter 는 확정용이라 무시
        if(open && act >= 0){ e.preventDefault(); pick(hits[act]); }
      }else if(e.key === 'Escape' || e.key === 'Esc'){
        if(open){ e.stopPropagation(); close(); var c = held(); input.value = c ? (c[NM]||'') : ''; }
      }else if(e.key === 'Tab'){
        if(open && act >= 0) pick(hits[act]);
      }
    });

    /* 화면이 움직이면 위치를 따라간다(카드 안 스크롤 포함 → capture) */
    window.addEventListener('scroll', function(){ if(dd.classList.contains('on')) place(); }, true);
    window.addEventListener('resize', function(){ if(dd.classList.contains('on')) place(); });
  };
})();
