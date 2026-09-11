/* ============================================================================
   send-hist.js — 문서 「전송이력」 공용 스크립트 (2026-09-10 신설)

   판매등록 ▸ 거래명세표 와 발주서(poReg) 를 카톡·이메일·링크로 보낸 <사실>을
   남기고 보여 준다. 종전에는 전표에 「몇 번 보냄 · 마지막 언제」 두 값뿐이라
   *누구에게 · 어떤 방법으로* 보냈는지는 아무 데도 남지 않았다.

   ▸ 쓰는 법 — 화면에 이 한 줄만 걸면 된다(CSS 는 스스로 넣는다).
       <script src="…/asset/js/send-hist.js?v=20260910f"></script>

     ① 보낼 때                                    ② 이력 보기(모달)
       var k = konetSendHist.key();                 konetSendHist.open({
       var u = konetSendHist.tag(url, k);             docGb:'STMT', docSeq:123,
       …u 로 보낸 뒤…                                 docDt:'2026-09-10', docNo:'0007', vendorNm:'…',
       konetSendHist.log({                            onResend : function(row){ … },   // [↻ 재전송]
         docGb:'STMT', docSeq:123, docDt, docNo,      onOpenDoc: function(docSeq,row){ … } // 다른 전표 줄 [📂 열기]
         vendorCd, vendorNm, sendGb:'KAKAO',        });
         shareUrl:u, trackKey:k, totAmt });

   ★두 화면이 <한 표>(TBL_SEND_HIST)를 쓰고 docGb('STMT'=거래명세표 / 'PO'=매입발주서)
     로만 갈린다. 목록 모양·조회 규칙을 두 벌로 두면 조용히 달라진다.

   ★log() 는 <실패해도 조용히 넘어간다> — 기록이 안 남았다고 이미 나간 카톡·메일을
     되돌릴 수는 없다. 부르는 쪽 흐름을 절대 막지 않는다(항상 resolve 하는 Promise).

   ★서버가 직접 보내는 이메일(stmtMailSend.do)은 <서버가> 남긴다(성공·실패 둘 다).
     여기서 또 부르면 한 번 보낸 것이 두 줄로 남는다. ⇒ 화면은 «브라우저에서 나가는
     것»(카톡·링크복사·메일프로그램·Gmail·내용복사)만 기록한다.

   ★★이력 = <실제로 나간 것>만 — 💬 카톡(KAKAO) · ✉ 서버 발송 이메일(EMAIL).
     링크복사·내용복사(「링크복사는 전송내역이 아니지 않나요」) 도, 메일프로그램·Gmail
     (「이것도 실제 받은 게 이메일이 아닌데」) 도 <기록하지 않는다> (2026-09-10, 같은 날 두 번 확정) —
     주소를 쥐거나 창을 열어 준 것뿐, 거래처가 실제로 받았는지 우리 서버는 모른다.
     GB 의 LINK/COPY/MAILTO/GMAIL 은 **그 전에 남은 줄을 그리기 위해서만** 남겨 둔다
     (새로 기록하는 곳은 없다 — 그 줄에는 「보낼 준비까지」 꼬리말이 붙어 실제 전송과 갈린다).

   ★읽음·열람 (2026-09-10 「메일 읽은정보 표시」) — 보낼 때마다 무작위 열쇠(key)를 만들어
     링크 뒤에 `&s=열쇠` 로 붙인다(tag). 받는 쪽이 그 링크를 열면 공개 페이지가 «그 전송 한 줄»의
     열람(VIEW) 을 올린다. 서버 발송 메일은 본문의 1×1 그림으로 «메일 열림(MAIL_OPEN)» 도 잡는다.
     ⚠메일 열림은 메일 프로그램이 그림을 막으면 안 잡힌다 — 「표시 없음」≠「안 읽음」.
       링크 열람이 더 확실한 신호다. 목록 툴팁과 안내줄에 같은 말을 적어 둔다.
     ⚠공개 주소 자체(토큰)는 전표당 하나 그대로다 — &s= 는 꼬리표일 뿐, 떼도 열린다.

   ★재전송 (2026-09-10 「재전송 가능하게」) — 화면이 onResend 를 주면 줄마다 [↻ 재전송].
     이 스크립트는 보내는 법을 모르므로 <같은 수단·같은 받는 곳>을 화면 함수에 돌려준다.
     다른 전표의 줄은 onOpenDoc 으로 그 전표부터 열게 한다(엉뚱한 전표를 보내지 않게).
     단추를 누르면 이 모달을 먼저 닫는다 — 화면의 메일 창(z-index 210)이 이 모달(300) 밑에 깔린다.
   ============================================================================ */
(function () {
  if (window.konetSendHist) return;

  /* 컨텍스트 경로 — 이 스크립트 자신의 주소에서 뽑는다(화면 전역변수에 기대지 않는다) */
  var CTX = (function () {
    var s = document.currentScript;
    if (!s) { var a = document.getElementsByTagName('script'); s = a[a.length - 1]; }
    var m = String((s && s.src) || '').match(/^(?:https?:\/\/[^\/]+)?(.*)\/asset\/js\/send-hist\.js/);
    return m ? m[1] : '';
  })();

  /* 전송 수단 — 라벨·색·«정말 나갔는가» */
  var GB = {
    KAKAO : { nm:'💬 카톡',        cls:'k', sure:true,  tip:'카카오 공유 카드로 보냈습니다.' },
    EMAIL : { nm:'✉ 이메일',      cls:'e', sure:true,  tip:'서버가 직접 보낸 메일입니다.' },
    MAILTO: { nm:'✉ 메일프로그램', cls:'m', sure:false, tip:'이 PC 의 메일 프로그램을 열었습니다 — 그 창에서 [보내기]를 눌러야 실제로 나갑니다.' },
    GMAIL : { nm:'✉ Gmail',       cls:'m', sure:false, tip:'Gmail 쓰기 창을 열었습니다 — 그 창에서 [보내기]를 눌러야 실제로 나갑니다.' },
    LINK  : { nm:'🔗 링크복사',    cls:'l', sure:false, tip:'주소를 복사했습니다 — 붙여 넣어 보냈는지까지는 알 수 없습니다.' },
    COPY  : { nm:'📋 내용복사',    cls:'l', sure:false, tip:'메일 내용을 복사했습니다 — 붙여 넣어 보냈는지까지는 알 수 없습니다.' }
  };
  var DOC = { STMT:'거래명세표', PO:'매입발주서' };
  var COLS = 11;   /* 머리글 칸 수 — 빈 줄·오류 줄 colspan 이 이 값을 쓴다 */

  function esc(s){ return String(s == null ? '' : s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  /* 자릿점 — 화면들이 쓰는 관용구 그대로(toLocaleString 은 엔진마다 결과가 갈린다) */
  function fmt(v){
    if (v == null || v === '') return '';
    var n = Number(v); if (!isFinite(n)) return '';
    return String(Math.round(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }
  function d8(s){ var t = String(s||'').replace(/-/g,''); return t.length === 8 ? t.slice(0,4)+'-'+t.slice(4,6)+'-'+t.slice(6,8) : (s||''); }
  function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
  function dm(s){ s = String(s||''); return s.length >= 16 ? s.slice(5,16) : s; }   /* 'YYYY-MM-DD HH:MM:SS' → 'MM-DD HH:MM' */
  function qs(o){ var a=[]; for (var k in o) if (o[k] != null && o[k] !== '') a.push(encodeURIComponent(k)+'='+encodeURIComponent(o[k])); return a.join('&'); }
  function post(url, body){
    return fetch(CTX + url, { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: body });
  }

  /* ── CSS 는 한 번만 넣는다 ─────────────────────────────────────────── */
  function css(){
    if (document.getElementById('konetSendHistCss')) return;
    var st = document.createElement('style'); st.id = 'konetSendHistCss';
    st.textContent = [
      '.ksh-pop{display:none;position:fixed;inset:0;background:rgba(15,23,32,.42);z-index:300;',
      '  font-family:"Pretendard Variable",Pretendard,"맑은 고딕",Malgun Gothic,sans-serif;}',
      '.ksh-pop.on{display:block;}',
      '.ksh-box{position:absolute;left:50%;top:5vh;transform:translateX(-50%);width:min(1240px,96vw);max-height:88vh;',
      '  display:flex;flex-direction:column;background:#fff;border-radius:10px;box-shadow:0 18px 50px rgba(15,23,32,.3);overflow:hidden;}',
      '.ksh-box.mv{transform:none;resize:both;min-width:520px;min-height:260px;}',   /* 한 번 끌면 left/top 좌표계로 */
      '.ksh-hd{display:flex;align-items:center;gap:10px;padding:12px 16px;border-bottom:1px solid #dbe2ea;background:#f7f9fb;cursor:move;user-select:none;}',
      '.ksh-hd .x{cursor:pointer;}',
      '.ksh-hd b{font-size:16px;color:#0e4f45;}',
      '.ksh-hd .who{font-size:12.5px;color:#5a6b7a;}',
      '.ksh-hd .x{border:1px solid #cfd8e3;background:#fff;border-radius:8px;height:29px;padding:0 12px;cursor:pointer;font-size:13px;white-space:nowrap;}',
      '.ksh-hd .x.rf{margin-left:auto;}',
      '.ksh-tab{display:flex;gap:6px;padding:10px 16px 0;}',
      '.ksh-tab button{border:1px solid #cfd8e3;background:#fff;border-radius:8px 8px 0 0;height:32px;padding:0 16px;cursor:pointer;',
      '  font-size:13px;color:#3d4d5c;border-bottom-color:transparent;white-space:nowrap;}',
      '.ksh-tab button.on{background:#137a6c;border-color:#137a6c;color:#fff;font-weight:700;}',
      '.ksh-tab button:disabled{opacity:.45;cursor:default;}',
      '.ksh-bar{display:flex;align-items:center;gap:6px;flex-wrap:wrap;padding:8px 16px;border-bottom:1px solid #eef2f6;}',
      '.ksh-bar label{font-size:12.5px;color:#5a6b7a;}',
      '.ksh-bar input{height:30px;border:1px solid #cfd8e3;border-radius:8px;padding:0 8px;font-size:13px;}',
      '.ksh-bar button{height:30px;border:1px solid #137a6c;background:#137a6c;color:#fff;border-radius:8px;padding:0 14px;cursor:pointer;font-size:13px;}',
      '.ksh-bar .cnt{margin-left:auto;font-size:12.5px;color:#5a6b7a;}',
      '.ksh-wrap{overflow:auto;flex:1;padding:0 16px 4px;}',
      '.ksh-tb{width:100%;border-collapse:collapse;font-size:13px;white-space:nowrap;}',
      '.ksh-tb th{position:sticky;top:0;background:#eaf2f0;color:#125a4e;font-weight:600;padding:5px 8px;border-bottom:1px solid #cfd8e3;z-index:1;}',
      '.ksh-tb td{padding:4px 8px;border-bottom:1px solid #eef2f6;color:#1f2a37;}',
      '.ksh-tb td.l{text-align:left;} .ksh-tb td.r{text-align:right;font-variant-numeric:tabular-nums;} .ksh-tb td.c{text-align:center;}',
      '.ksh-tb tr:hover td{background:#f6fbfa;}',
      '.ksh-tb td.emp{text-align:center;color:#8a97a4;padding:26px 0;}',
      '.ksh-gb{display:inline-block;border-radius:6px;padding:1px 7px;font-size:12px;font-weight:700;}',
      '.ksh-gb.k{background:#fff3c4;color:#7a5c00;} .ksh-gb.e{background:#dcefe7;color:#0e5b4e;}',
      '.ksh-gb.m{background:#e4ecf7;color:#28486e;} .ksh-gb.l{background:#eef1f4;color:#54626f;}',
      '.ksh-ng{color:#8a97a4;font-size:11.5px;}',
      '.ksh-fail{color:#c0392b;font-weight:700;}',
      '.ksh-rd{display:inline-block;border-radius:6px;padding:1px 6px;font-size:11.5px;font-weight:700;background:#e3f2ee;color:#0e5b4e;margin:1px 0;}',
      '.ksh-rd.v{background:#dbeafe;color:#1e40af;}',
      '.ksh-lnk{border:1px solid #cfd8e3;background:#fff;border-radius:6px;height:22px;padding:0 7px;cursor:pointer;font-size:11.5px;color:#3d4d5c;}',
      '.ksh-lnk.rs{border-color:#137a6c;color:#0e5b4e;font-weight:700;}',
      '.ksh-lnk.op{border-color:#93a7bd;color:#28486e;}',
      '.ksh-ft{padding:8px 16px 12px;border-top:1px solid #eef2f6;font-size:11.5px;color:#6b7a89;line-height:1.6;}'
    ].join('');
    document.head.appendChild(st);
  }

  /* ── 모달 뼈대 ─────────────────────────────────────────────────────── */
  var _o = {}, _tab = 'doc', _rows = [];

  function build(){
    if (document.getElementById('kshPop')) return;
    css();
    var d = document.createElement('div');
    d.id = 'kshPop'; d.className = 'ksh-pop';
    d.innerHTML =
      '<div class="ksh-box">'
      + '<div class="ksh-hd"><b>📨 전송이력</b><span class="who" id="kshWho"></span>'
      +   '<span class="who" style="color:#9aa7b3" title="이 줄을 끌면 창이 움직입니다 · 더블클릭 = 처음 자리 · 오른쪽 아래 모서리로 크기 조절">⠿ 끌어서 이동</span>'
      +   '<button class="x rf" onclick="konetSendHist.load()" title="읽음·열람은 받는 쪽이 열 때 올라갑니다 — 다시 읽어 옵니다">🔄 새로고침</button>'
      +   '<button class="x" onclick="konetSendHist.close()">닫기</button></div>'
      + '<div class="ksh-tab">'
      +   '<button id="kshTabDoc" onclick="konetSendHist.tab(&quot;doc&quot;)">이 전표</button>'
      +   '<button id="kshTabAll" onclick="konetSendHist.tab(&quot;all&quot;)">전체 이력</button>'
      + '</div>'
      + '<div class="ksh-bar" id="kshBar">'
      +   '<label>기간</label><input type="date" id="kshFr"><span style="color:#8a98a8">~</span><input type="date" id="kshTo">'
      +   '<label style="margin-left:6px">찾기</label>'
      +   '<input type="text" id="kshFind" placeholder="거래처·받는 곳·전표번호" style="width:190px">'
      +   '<button onclick="konetSendHist.load()">🔍 조회</button>'
      +   '<span class="cnt" id="kshCnt"></span>'
      + '</div>'
      + '<div class="ksh-wrap"><table class="ksh-tb">'
      +   '<thead><tr><th>보낸 일시</th><th>수단</th><th>받는 곳</th><th>전표</th><th>거래처</th>'
      +   '<th>금액</th><th>결과</th><th title="✉ 읽음 = 메일을 열었음(그림 차단이면 안 잡힘) · 👁 열람 = 명세서 링크를 열어 봤음">읽음 · 열람</th>'
      +   '<th>보낸이</th><th>주소</th><th>재전송</th></tr></thead>'
      +   '<tbody id="kshBody"></tbody></table></div>'
      + '<div class="ksh-ft">'
      +   '여기에는 <b style="color:#0e5b4e">실제로 나간 것</b>만 남습니다 — <b>💬 카톡 공유 · ✉ 이메일(서버 발송)</b>. '
      +   '🔗 링크 복사 · 📋 내용 복사 · 메일 프로그램 · Gmail 은 주소를 쥐거나 창을 연 것뿐이라 남기지 않습니다'
      +   '(예전에 남은 줄은 「보낼 준비까지」로 표시).'
      +   '<br><b style="color:#0e5b4e">✉ 읽음</b> = 받는 쪽이 메일을 열었음(메일 프로그램이 그림을 막으면 안 잡힙니다 — <b>표시 없음 ≠ 안 읽음</b>) · '
      +   '<b style="color:#1e40af">👁 열람</b> = 보낸 주소로 명세서를 실제로 열어 봤음(이쪽이 더 확실합니다). '
      +   '<b>[↻ 재전송]</b> 은 같은 수단·같은 받는 곳으로 다시 보냅니다(다른 전표 줄은 그 전표를 먼저 엽니다). 최근 500건.'
      + '</div></div>';
    document.body.appendChild(d);
    /* ★[닫기]로만 닫힌다 (2026-09-10 「전송이력 닫기해야 닫히게 — 바깥 클릭하면 닫힘」) —
       처음엔 어두운 바탕을 누르면 닫혔는데, 목록을 보다가 화면 다른 곳을 짚으면 창이 사라져 다시 열어야 했다.
       카톡 주문 창(#saKtPop)과 같은 규칙 : 바깥 클릭·ESC 로는 안 닫히고 [닫기] 단추뿐. */
    /* ★머리줄을 끌어 옮긴다 (2026-09-10 「마우스로 더 움직이게」) — 위치는 localStorage 에 남아 다음에도 그 자리.
       끌기 시작하면 가운데 정렬(transform)을 버리고 left/top 으로 바꾼다. 화면 밖으로는 못 나가게 잡는다.
       단추 위에서 누른 것은 끌기가 아니다. */
    var box = d.querySelector('.ksh-box'), hd = d.querySelector('.ksh-hd'), drag = null;
    hd.addEventListener('mousedown', function(e){
      if (e.button !== 0 || e.target.closest('button')) return;
      var r = box.getBoundingClientRect();
      box.classList.add('mv'); box.style.left = r.left + 'px'; box.style.top = r.top + 'px';
      drag = { dx: e.clientX - r.left, dy: e.clientY - r.top, w: r.width, h: r.height };
      e.preventDefault();
    });
    document.addEventListener('mousemove', function(e){
      if (!drag) return;
      var x = e.clientX - drag.dx, y = e.clientY - drag.dy;
      x = Math.max(8 - drag.w + 120, Math.min(x, window.innerWidth  - 120));   /* 머리줄 한 조각은 늘 화면 안에 */
      y = Math.max(0, Math.min(y, window.innerHeight - 48));
      box.style.left = x + 'px'; box.style.top = y + 'px';
    });
    document.addEventListener('mouseup', function(){
      if (!drag) return; drag = null;
      try { localStorage.setItem('konetSendHistPos', JSON.stringify({ l: parseInt(box.style.left,10), t: parseInt(box.style.top,10) })); } catch(e){}
    });
    /* 머리줄 더블클릭 = 처음 자리(가운데)로 */
    hd.addEventListener('dblclick', function(e){
      if (e.target.closest('button')) return;
      box.classList.remove('mv'); box.style.left = ''; box.style.top = ''; box.style.width = ''; box.style.height = '';
      try { localStorage.removeItem('konetSendHistPos'); } catch(e){}
    });
    /* ESC 닫기도 두지 않는다 — [닫기] 단추뿐 (위 규칙과 같다) */
  }

  function readCell(r){
    var h = '';
    if (Number(r.mailOpenCnt) > 0)
      h += '<span class="ksh-rd" title="메일을 처음 연 때 ' + esc(r.mailOpenDttm||'') + ' · ' + Number(r.mailOpenCnt) + '회">✉ 읽음 '
        +  esc(dm(r.mailOpenDttm)) + (Number(r.mailOpenCnt) > 1 ? ' ×' + Number(r.mailOpenCnt) : '') + '</span>';
    if (Number(r.viewCnt) > 0)
      h += (h ? '<br>' : '') + '<span class="ksh-rd v" title="명세서를 처음 열어 본 때 ' + esc(r.viewDttm||'') + ' · ' + Number(r.viewCnt) + '회">👁 열람 '
        +  esc(dm(r.viewDttm)) + (Number(r.viewCnt) > 1 ? ' ×' + Number(r.viewCnt) : '') + '</span>';
    if (!h) h = '<span class="ksh-ng" title="' + (r.trackKey
              ? '아직 열린 기록이 없습니다. 메일 그림이 차단되면 읽어도 표시되지 않습니다 — 명세서 링크를 열면 👁 열람으로 잡힙니다.'
              : '읽음 표시 기능 이전에 보낸 줄입니다.') + '">—</span>';
    return h;
  }
  function actCell(r, i){
    var mine = _o.docSeq && String(r.docSeq) === String(_o.docSeq);
    if (mine && typeof _o.onResend === 'function')
      return '<button class="ksh-lnk rs" onclick="konetSendHist.resend(' + i + ')" title="같은 수단(' + esc((GB[r.sendGb]||{}).nm||r.sendGb) + ')'
           + (r.sendTo ? ' · ' + esc(r.sendTo) : '') + ' 으로 다시 보냅니다">↻ 재전송</button>';
    if (!mine && r.docSeq && typeof _o.onOpenDoc === 'function')
      return '<button class="ksh-lnk op" onclick="konetSendHist.openDoc(' + i + ')" title="이 줄의 전표를 화면에 연 뒤 재전송할 수 있습니다">📂 전표 열기</button>';
    return '<span class="ksh-ng">—</span>';
  }

  function render(){
    var b = document.getElementById('kshBody'), h = '';
    if (!_rows.length){
      h = '<tr><td class="emp" colspan="' + COLS + '">'
        + (_tab === 'doc' ? '이 전표는 아직 보낸 적이 없습니다.' : '그 기간에 보낸 이력이 없습니다.')
        + '</td></tr>';
    } else {
      _rows.forEach(function(r, i){
        var g = GB[r.sendGb] || { nm:esc(r.sendGb), cls:'l', sure:false, tip:'' };
        var ok = String(r.resultGb||'OK') !== 'FAIL';
        h += '<tr>'
          +  '<td class="c">' + esc(String(r.regDttm||'').slice(0,16)) + '</td>'
          +  '<td class="c"><span class="ksh-gb ' + g.cls + '" title="' + esc(g.tip) + '">' + g.nm + '</span>'
          +      (g.sure ? '' : '<div class="ksh-ng">보낼 준비까지</div>') + '</td>'
          +  '<td class="l">' + (r.sendTo ? esc(r.sendTo) : '<span class="ksh-ng">—</span>')
          +      (r.subject ? '<div class="ksh-ng">' + esc(r.subject) + '</div>' : '') + '</td>'
          +  '<td class="c">' + esc(d8(r.docDt)) + (r.docNo ? ' - ' + esc(r.docNo) : '') + '</td>'
          +  '<td class="l">' + esc(r.vendorNm || '') + '</td>'
          +  '<td class="r">' + fmt(r.totAmt) + '</td>'
          +  '<td class="c">' + (ok ? '✔' : '<span class="ksh-fail" title="' + esc(r.errMsg||'') + '">실패</span>') + '</td>'
          +  '<td class="c">' + readCell(r) + '</td>'
          +  '<td class="c">' + esc(r.regUser || '') + '</td>'
          +  '<td class="c">' + (r.shareUrl
                ? '<button class="ksh-lnk" title="' + esc(r.shareUrl) + '" data-u="' + esc(r.shareUrl) + '" onclick="konetSendHist.copy(this)">🔗 복사</button>'
                : '<span class="ksh-ng">—</span>') + '</td>'
          +  '<td class="c">' + actCell(r, i) + '</td>'
          +  '</tr>';
      });
    }
    b.innerHTML = h;
    var bad = _rows.filter(function(r){ return String(r.resultGb||'OK') === 'FAIL'; }).length;
    var rd  = _rows.filter(function(r){ return Number(r.mailOpenCnt) > 0 || Number(r.viewCnt) > 0; }).length;
    document.getElementById('kshCnt').innerHTML =
      '<b>' + _rows.length + '</b>건'
      + (rd ? ' · 읽음·열람 <b>' + rd + '</b>' : '')
      + (bad ? ' · <span class="ksh-fail">실패 ' + bad + '</span>' : '');
  }

  var api = {
    /* 전송 한 건의 열쇠 — 무작위 20자(hex). 서버(sendHistKey)와 같은 꼴 */
    key: function(){
      var s = '', i;
      if (window.crypto && crypto.getRandomValues){
        var a = new Uint8Array(10); crypto.getRandomValues(a);
        for (i = 0; i < a.length; i++) s += ('0' + a[i].toString(16)).slice(-2);
      } else {
        for (i = 0; i < 20; i++) s += Math.floor(Math.random() * 16).toString(16);
      }
      return s;
    },
    /* 링크에 열쇠 꼬리표 — 이미 &s= 가 있으면 바꿔 끼운다(같은 주소를 두 번 태그하지 않게) */
    tag: function(url, key){
      url = String(url || ''); if (!key) return url;
      url = url.replace(/([?&])s=[^&#]*(&?)/, function(m, p1, p2){ return p2 ? p1 : ''; }).replace(/[?&]$/, '');
      return url + (url.indexOf('?') >= 0 ? '&' : '?') + 's=' + encodeURIComponent(key);
    },
    /* 보낸 사실 기록 — ★어떤 경우에도 흐름을 막지 않는다(항상 resolve) */
    log: function(o){
      o = o || {};
      if (!o.docGb || !o.docSeq) return Promise.resolve(false);
      return post('/mangr/sendHistSave.do', qs({
        docGb:o.docGb, docSeq:o.docSeq, docDt:o.docDt, docNo:o.docNo,
        vendorCd:o.vendorCd, vendorNm:o.vendorNm,
        sendGb:o.sendGb, sendTo:o.sendTo, subject:o.subject, memo:o.memo,
        shareUrl:o.shareUrl, totAmt:(o.totAmt == null ? '' : o.totAmt),
        resultGb:o.resultGb, errMsg:o.errMsg, trackKey:o.trackKey
      })).then(function(){ return true; }).catch(function(){ return false; });
    },
    open: function(o){
      build();
      _o = o || {};
      _tab = _o.docSeq ? 'doc' : 'all';
      document.getElementById('kshWho').textContent =
        '— ' + (DOC[_o.docGb] || '문서')
        + (_o.docSeq ? (' · ' + d8(_o.docDt) + (_o.docNo ? ' - ' + _o.docNo : '')
                        + (_o.vendorNm ? ' · ' + _o.vendorNm : '')) : '');
      var t = new Date(), f = new Date(); f.setDate(f.getDate() - 30);
      document.getElementById('kshFr').value = ymd(f);
      document.getElementById('kshTo').value = ymd(t);
      document.getElementById('kshFind').value = '';
      document.getElementById('kshPop').classList.add('on');
      /* 지난번에 끌어 둔 자리로 — 화면(해상도)이 바뀌어 밖이면 가운데로 */
      try {
        var pos = JSON.parse(localStorage.getItem('konetSendHistPos') || 'null');
        var bx = document.querySelector('#kshPop .ksh-box');
        if (pos && bx && pos.l < window.innerWidth - 120 && pos.t < window.innerHeight - 48 && pos.t >= 0){
          bx.classList.add('mv'); bx.style.left = pos.l + 'px'; bx.style.top = pos.t + 'px';
        }
      } catch(e){}
      api.tab(_tab);
    },
    close: function(){ var p = document.getElementById('kshPop'); if (p) p.classList.remove('on'); },
    tab: function(t){
      _tab = _o.docSeq ? t : 'all';          /* 전표가 없으면 「이 전표」 탭은 뜻이 없다 */
      document.getElementById('kshTabDoc').classList.toggle('on', _tab === 'doc');
      document.getElementById('kshTabAll').classList.toggle('on', _tab === 'all');
      document.getElementById('kshTabDoc').disabled = !_o.docSeq;
      /* 「이 전표」 탭에서는 기간·찾기 줄이 뜻이 없다 — 감춘다 */
      document.getElementById('kshBar').style.display = (_tab === 'all') ? 'flex' : 'none';
      api.load();
    },
    load: function(){
      if (!document.getElementById('kshPop')) return;
      var body = { docGb:_o.docGb };
      if (_tab === 'doc') body.docSeq = _o.docSeq;
      else {
        body.fromDt   = document.getElementById('kshFr').value;
        body.toDt     = document.getElementById('kshTo').value;
        body.findData = document.getElementById('kshFind').value;
      }
      document.getElementById('kshBody').innerHTML = '<tr><td class="emp" colspan="' + COLS + '">조회 중…</td></tr>';
      post('/mangr/sendHistList.do', qs(body))
        .then(function(r){ return r.json(); })
        .then(function(j){
          if (j && j.error) throw new Error(j.error);
          _rows = (j && j.data) || []; render();
        })
        .catch(function(e){
          document.getElementById('kshBody').innerHTML =
            '<tr><td class="emp" colspan="' + COLS + '" style="color:#c0392b">조회 오류: ' + esc(e.message) + '</td></tr>';
        });
    },
    /* [↻ 재전송] — 모달을 닫고 화면 함수에 «같은 수단·같은 받는 곳»을 돌려준다 */
    resend: function(i){
      var r = _rows[i]; if (!r || typeof _o.onResend !== 'function') return;
      api.close();
      try { _o.onResend(r); } catch(e){ /* 화면 쪽 오류는 화면이 알린다 */ }
    },
    /* [📂 전표 열기] — 다른 전표 줄 : 그 전표부터 열게 한다 */
    openDoc: function(i){
      var r = _rows[i]; if (!r || typeof _o.onOpenDoc !== 'function') return;
      api.close();
      try { _o.onOpenDoc(r.docSeq, r); } catch(e){}
    },
    copy: function(btn){
      var u = btn.getAttribute('data-u') || '';
      var done = function(){ var t = btn.textContent; btn.textContent = '✔ 복사됨';
                             setTimeout(function(){ btn.textContent = t; }, 1200); };
      var fb = function(txt){
        var t = document.createElement('textarea'); t.value = txt;
        t.style.position = 'fixed'; t.style.left = '-9999px'; document.body.appendChild(t);
        t.select(); try { document.execCommand('copy'); } catch(e){} document.body.removeChild(t);
      };
      if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(u).then(done, function(){ fb(u); done(); });
      else { fb(u); done(); }
    }
  };
  window.konetSendHist = api;
})();
