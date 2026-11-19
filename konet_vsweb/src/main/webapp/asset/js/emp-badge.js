/* =====================================================================
   emp-badge.js — 셸(logistics_demo2.jsp)의 직원 소통 세 가지 (2026-09-22)
     ① 사이드바 「직원 공지사항 / 직원 메신저」 안 읽음 배지
        · 30초마다 POST /emp/badge.do → {noticeUnread, msgUnread, roomUnread, leaveToday, leaveNames, adjReq(관리자만 — 재고 조정 승인 대기 건수, 2026-11-18), adjMine·adjMineList(내 요청의 승인·반려 결과 중 안 본 것)}
        · 「직원 휴가 관리」 옆 empLeaveBadge = 오늘 휴가 중인 직원 수(반려 제외), 말풍선에 이름·구분 (2026-11-03)
        · 메뉴 글자 옆 <span class="emp-badge" id="empNoticeBadge|empMsgBadge"> 에 수를 적고, 0 이면 숨긴다
        · 안 읽은 메시지가 <늘어나면>(다른 사람이 보냄) 하단 토스트 한 번 — 메신저 화면을 보고 있을 때는 안 띄운다
     ② 화면 맨 아래 「📢 공지」 흐름 띠 (사용자 「하단에 공지사항 흐르게도 추가」)
        · 60초마다 POST /emp/noticeList.do(기존 목록 조회 그대로 — 새 엔드포인트 없음) → 고정(📌) 공지 + 최근 30일 공지, 최대 10건
        · 안 읽은 공지엔 NEW 표. 제목을 누르면 공지 화면이 열리며 그 공지가 펼쳐진다(empTickerOpen)
        · [멈춤/재생] · [✕ 접기](왼쪽 아래 작은 알약으로, 브라우저에 기억) · 공지가 하나도 없으면 띠 자체가 안 보인다
        · 띠가 켜지면 body.emp-ticker-on — 셸 CSS 가 iframe 높이를 그만큼 줄인다(마지막 줄 가림 방지)
     ③ 우측 패널(도크) #empDock (사용자 「로그인 뒤 우측 패널로」) — 어느 메뉴를 보고 있든 최근 공지 5건 + 내 대화방 8개가 늘 보인다
        · 공지는 ②와 같은 응답(noticeRaw)에서 앞 5건 · 대화방은 30초마다(배지 폴링과 함께) POST /emp/roomList.do
        · 줄을 누르면 그 공지/그 방으로 화면이 열린다(empTickerOpen · empDockGoRoom). [✚ 새 대화] 는 메신저의 상대 고르기 창을 바로 연다
        · 열려 있으면 body.emp-dock-on → 셸 CSS 가 .logi-main 을 284px 밀어 업무 화면이 안 가려진다. 접으면 오른쪽 가장자리 세로 탭(안 읽은 수)만
        · 기본 = 열림, localStorage konetEmpDockOpen 에 기억
     · iframe 안 화면(공지·메신저)이 저장·읽음 처리한 뒤 parent.konetEmpBadge() 를 부르면 셋을 함께 갱신한다
     · 탭이 숨어 있으면(document.hidden) 쉬었다가 돌아오면 바로 한 번
     ④ 사이드바 「대표자 일정」 옆 «지난 미완료» 건수 (2026-11-19) — 총괄관리자만. 아래 ④ 묶음
     ⑤ 로그인 직후 「대표자 일정 — 오늘부터 일주일」 요약 창 (2026-11-19) — 총괄관리자만, 로그인 때 한 번. 아래 ⑤ 묶음
   셸 JSP 에 스크립트를 넣지 않는 이유 = 그 JSP 는 인라인 스크립트 한도(65535)에 닿아 있다(파일 머리말 참고).
   ===================================================================== */
(function () {
  var CTX = (typeof KONET_CTX === 'string') ? KONET_CTX : '';
  var PERIOD = 30000, TICK_PERIOD = 60000;
  var lastMsg = -1, timer = null, busy = false;
  var lastAdj = -1;   /* 재고 조정 승인 대기 건수(관리자만 응답에 온다) — 늘면 알림 한 번 (2026-11-18) */
  var lastMine = 0;   /* 내 요청의 결과 중 안 본 건수 — 0 에서 시작하므로 «로그인했을 때 와 있던 결과»도 한 번 알린다 */
  function paintAdj(n, title, color) {
    ['adjReqBadge', 'adjReqGrpBadge'].forEach(function (id) { paint(id, n, title); var el = document.getElementById(id); if (el) el.style.background = color || ''; });
  }
  var tickTimer = null, tickList = [], noticeRaw = [], tickBusy = false, tickPaused = false;
  var dockRooms = [], roomsBusy = false, lastBadge = { noticeUnread: 0, msgUnread: 0 };

  function esc(s) { return ('' + (s == null ? '' : s)).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
  function post(url, body) {
    return fetch(CTX + url, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body || {}) })
      .then(function (r) { return r.ok ? r.json() : null; });
  }
  function shortTm(s) {
    s = String(s || ''); if (!s) return '';
    var t = new Date(), today = t.getFullYear() + '-' + ('0' + (t.getMonth() + 1)).slice(-2) + '-' + ('0' + t.getDate()).slice(-2);
    return s.slice(0, 10) === today ? s.slice(11, 16) : s.slice(5, 10);
  }
  /* 메뉴를 열고, iframe 안 화면이 준비되면(ready) 그 화면 함수를 부른다 — 최대 5초 */
  function openScreen(key, ready, run) {
    var menu = document.querySelector('.logi-side a.mi[data-key="' + key + '"]');
    if (menu) menu.click();
    var n = 0;
    (function tryRun() {
      var f = document.getElementById('if-' + key), w = null;
      try { w = f && f.contentWindow; } catch (e) { }
      if (w && ready(w)) { try { run(w); } catch (e) { } return; }
      if (++n < 20) setTimeout(tryRun, 250);
    })();
  }

  /* ── ① 배지 ── */
  function paint(id, n, title) {
    var el = document.getElementById(id);
    if (!el) return;
    n = Number(n) || 0;
    el.textContent = n > 99 ? '99+' : String(n);
    el.style.display = n > 0 ? '' : 'none';
    el.title = n > 0 ? (title || ('안 읽은 것 ' + n + '건')) : '';
  }
  function msgPanelShown() {
    var p = document.getElementById('panel-empMsg');
    return !!(p && p.classList.contains('show'));
  }
  function fetchBadge() {
    if (busy || document.hidden) return;
    busy = true;
    post('/emp/badge.do', {})
      .then(function (j) {
        busy = false;
        if (!j || j.result !== 'OK') return;      /* 세션 없음·서버 오류 = 조용히(배지는 마지막 값 유지) */
        lastBadge = { noticeUnread: Number(j.noticeUnread) || 0, msgUnread: Number(j.msgUnread) || 0 };
        paint('empNoticeBadge', j.noticeUnread);
        paint('empMsgBadge', j.msgUnread);
        paint('empGrpBadge', (Number(j.noticeUnread) || 0) + (Number(j.msgUnread) || 0));   /* 「직원관리」 주메뉴 — 접혀 있어도 보이게 (2026-10-21) */
        paint('empLeaveBadge', j.leaveToday, '오늘 휴가 ' + (Number(j.leaveToday) || 0) + '명 : ' + (j.leaveNames || ''));   /* 「직원 휴가 관리」 — 오늘 휴가자 수 (2026-11-03). 주메뉴 합계에는 안 넣는다(안 읽은 수가 아니라서) */
        paint('empDockNoticeN', j.noticeUnread); paint('empDockMsgN', j.msgUnread);
        paint('empDockTabN1', j.noticeUnread); paint('empDockTabN2', j.msgUnread);
        /* 재고 조정 승인 대기 (2026-11-18 「대기 중인 승인 요청 수를 관리자 메뉴에 빨간 배지」) — 응답에 adjReq 가 있을 때만(= 총괄관리자·부관리자).
           「재고 관리」 주메뉴(접혀 있어도 보이게)와 「재고 일괄조정」 메뉴 두 곳. 늘어나면 알림 한 번 — 그 화면을 보고 있을 때는 안 띄운다. */
        /* ★요청한 직원에게도 결과를 알린다 (2026-11-18 「요청한 직원에게도 승인/반려 결과 알림 표시」) — adjMine = 내 요청 중 승인·반려됐는데 아직 [확인했습니다] 안 한 건수,
           adjMineList = 최근 5건. 같은 두 배지 자리에 «대기 + 내 결과» 를 더해 보인다(관리자는 요청을 안 올리므로 보통 한쪽뿐).
           색 : 대기가 있거나 반려가 섞이면 빨강(기본) · 내 결과가 전부 승인이면 청록. 재고 일괄조정 화면의 [확인했습니다]를 눌러야 사라진다. */
        if (j.adjReq != null || j.adjMine != null) {
          var a = Number(j.adjReq) || 0, mn = Number(j.adjMine) || 0, ml = j.adjMineList || [];
          var rej = ml.filter(function (x) { return x && x.statGb !== 'A'; }).length, tip = [];
          if (a) tip.push('재고 조정 승인 대기 ' + a + '건 — 재고 일괄조정에서 승인·반려');
          if (mn) tip.push('내 재고 조정 요청 결과 ' + mn + '건 — 재고 일괄조정에서 확인');
          paintAdj(a + mn, tip.join(' / '), (!a && mn && !rej) ? '#137a6c' : '');
          var ap = document.getElementById('panel-stockAdj'), onAdj = !!(ap && ap.classList.contains('show')), canT = (typeof window._toast === 'function');
          if (j.adjReq != null) {
            if (lastAdj >= 0 && a > lastAdj && !onAdj && canT) _toast('⏳ 재고 조정 승인 요청 ' + (a - lastAdj) + '건이 새로 올라왔습니다 — 재고 관리 ▸ 재고 일괄조정', 'ok');
            lastAdj = a;
          }
          if (j.adjMine != null) {
            if (mn > lastMine && !onAdj && canT) {
              var x = ml[0] || {}, one = (mn - lastMine === 1 && x.reqSeq != null);
              /* 어떤 상품인지 — 「(크라프트 종이컵 13oz 외 1건)」. 서버가 첫 상품명(itemNm)을 줄 때만 (2026-11-18 「어떤 상품이 반려 승인 됐는지 표시」) */
              var ic = Number(x.itemCnt) || 0, xn = x.itemNm ? ' (' + x.itemNm + (ic > 1 ? ' 외 ' + (ic - 1) + '건' : '') + ')' : '';
              if (one && x.statGb === 'A') _toast('✅ 재고 조정 요청 #' + x.reqSeq + xn + ' 이 승인됐습니다 — 재고에 반영됐습니다', 'ok');
              else if (one && x.statGb === 'R') _toast('↩ 재고 조정 요청 #' + x.reqSeq + xn + ' 이 반려됐습니다' + (x.apprMemo ? ' — ' + x.apprMemo : ''), 'warn');
              else if (one) _toast('재고 조정 요청 #' + x.reqSeq + xn + ' 이 취소됐습니다(관리자)', 'warn');
              else _toast('재고 조정 요청 결과 ' + mn + '건이 와 있습니다 — 재고 관리 ▸ 재고 일괄조정에서 확인', rej ? 'warn' : 'ok');
            }
            lastMine = mn;
          }
        }
        var m = Number(j.msgUnread) || 0;
        if (lastMsg >= 0 && m > lastMsg) {
          if (!msgPanelShown() && typeof window._toast === 'function') _toast('💬 새 메시지 ' + (m - lastMsg) + '건 — 직원 메신저를 확인하세요', 'ok');
          fetchRooms();                             /* 새 글이 왔으면 도크의 방 목록도 바로 */
        }
        lastMsg = m;
      })
      .catch(function () { busy = false; });
  }

  /* ── ② 하단 공지 흐름 띠 ── */
  function folded() { try { return localStorage.getItem('konetEmpTickerFold') === '1'; } catch (e) { return false; } }
  function tickRender() {
    var bar = document.getElementById('empTickerBar'), track = document.getElementById('empTickerTrack'), pill = document.getElementById('empTickerPill');
    if (!bar || !track) return;
    if (!tickList.length) {
      bar.style.display = 'none'; if (pill) pill.style.display = 'none';
      document.body.classList.remove('emp-ticker-on'); track.innerHTML = '';
      return;
    }
    var unread = 0;
    tickList.forEach(function (n) { if (n.readYn !== 'Y') unread++; });
    if (folded()) {
      bar.style.display = 'none'; document.body.classList.remove('emp-ticker-on');
      if (pill) { pill.style.display = ''; var pn = document.getElementById('empTickerPillN'); if (pn) pn.textContent = tickList.length + '건' + (unread ? ' · 안 읽음 ' + unread : ''); }
      return;
    }
    if (pill) pill.style.display = 'none';
    var h = '<span class="et-spacer"></span>';
    tickList.forEach(function (n, i) {
      if (i) h += '<span class="et-sep">│</span>';
      h += '<span class="et-item" data-seq="' + esc(n.noticeSeq) + '" title="' + esc(n.regNm) + ' · ' + esc(n.regDttm) + ' — 누르면 공지가 열립니다">'
        + (n.readYn !== 'Y' ? '<span class="new">NEW</span>' : '')
        + (n.pinYn === 'Y' ? '<span class="pin">📌 </span>' : '')
        + esc(n.title) + '<small>' + esc(n.regNm) + ' · ' + esc(String(n.regDttm || '').slice(5, 10)) + '</small></span>';
    });
    track.innerHTML = h;
    bar.style.display = 'flex'; document.body.classList.add('emp-ticker-on');
    var dur = Math.max(30, Math.round(track.scrollWidth / 45));   /* 천천히(초당 ~45px, 최소 30초) — 출고장 알림 바와 같은 속도 */
    track.style.animationDuration = dur + 's';
    track.style.animationPlayState = tickPaused ? 'paused' : 'running';
    track.style.opacity = tickPaused ? '0.45' : '1';
    var tb = document.getElementById('empTickerToggle'); if (tb) tb.textContent = tickPaused ? '재생' : '멈춤';
  }
  function fetchTicker() {
    if (tickBusy || document.hidden || !document.getElementById('empTickerBar')) return;
    tickBusy = true;
    post('/emp/noticeList.do', { findData: '' })
      .then(function (j) {
        tickBusy = false;
        if (!j || j.result !== 'OK') return;
        noticeRaw = j.list || [];
        var lim = new Date(); lim.setDate(lim.getDate() - 30);
        var limS = lim.getFullYear() + '-' + ('0' + (lim.getMonth() + 1)).slice(-2) + '-' + ('0' + lim.getDate()).slice(-2);
        /* 목록은 이미 고정 먼저·최신 먼저 — 고정 공지는 날짜와 무관하게, 나머지는 30일 안 것만, 최대 10건 */
        tickList = noticeRaw.filter(function (n) { return n.pinYn === 'Y' || String(n.regDttm || '') >= limS; }).slice(0, 10);
        tickRender();
        dockRenderNotices();
      })
      .catch(function () { tickBusy = false; });
  }
  /* 띠·도크의 공지를 누르면 → 공지 화면 열고 그 공지 펼치기 */
  window.empTickerOpen = function (seq) {
    openScreen('empNotice', function (w) { return typeof w.open_ === 'function' && w.LIST; }, function (w) { w.open_(Number(seq)); });
  };
  window.empTickerToggle = function () { tickPaused = !tickPaused; tickRender(); };
  window.empTickerFold = function (on) { try { localStorage.setItem('konetEmpTickerFold', on ? '1' : '0'); } catch (e) { } tickRender(); };

  /* ── ③ 우측 패널(도크) ── */
  function dockOpen() { try { return localStorage.getItem('konetEmpDockOpen') !== '0'; } catch (e) { return true; } }   /* 기본 열림 */
  function dockApply() { document.body.classList.toggle('emp-dock-on', dockOpen()); }
  function dockRenderNotices() {
    var box = document.getElementById('empDockNotice'); if (!box) return;
    var list = noticeRaw.slice(0, 5), h = '';
    list.forEach(function (n) {
      h += '<div class="ed-it' + (n.readYn !== 'Y' ? ' unread' : '') + '" onclick="empTickerOpen(' + Number(n.noticeSeq) + ')" title="' + esc(n.title) + '">'
        + '<div class="t">' + (n.readYn !== 'Y' ? '<span class="new">NEW</span>' : '') + (n.pinYn === 'Y' ? '<span class="pin">📌 </span>' : '') + esc(n.title) + '</div>'
        + '<div class="s">' + esc(n.regNm) + ' · ' + esc(shortTm(n.regDttm)) + ' · 읽음 ' + esc(n.readCnt) + '</div></div>';
    });
    box.innerHTML = h || '<div class="ed-empty">등록된 공지가 없습니다.</div>';
  }
  function dockRenderRooms() {
    var box = document.getElementById('empDockRooms'); if (!box) return;
    var list = dockRooms.slice(0, 8), h = '';
    list.forEach(function (r) {
      var un = Number(r.unread) || 0, g = (r.roomGb === 'G');
      var mbrs = (r.members || []).filter(function (m) { return m.leaveYn !== 'Y'; }).length;
      h += '<div class="ed-it' + (un > 0 ? ' unread' : '') + '" onclick="empDockGoRoom(' + Number(r.roomSeq) + ')" title="' + esc(r.dispNm) + '">'
        + (un > 0 ? '<span class="un">' + (un > 99 ? '99+' : un) + '</span>' : '')
        + '<div class="t">' + (g ? '👥 ' : '') + esc(r.dispNm) + (g ? ' <small style="color:#8a98a8;font-weight:400">' + mbrs + '명</small>' : '') + '</div>'
        + '<div class="s">' + esc(r.lastTxt || '(글 없음)') + (r.lastDttm ? ' · ' + esc(shortTm(r.lastDttm)) : '') + '</div></div>';
    });
    box.innerHTML = h || '<div class="ed-empty">대화방이 없습니다. [✚ 새 대화]로 시작하세요.</div>';
  }
  function fetchRooms() {
    if (roomsBusy || document.hidden || !document.getElementById('empDockRooms')) return;
    roomsBusy = true;
    post('/emp/roomList.do', {})
      .then(function (j) { roomsBusy = false; if (!j || j.result !== 'OK') return; dockRooms = j.list || []; dockRenderRooms(); })
      .catch(function () { roomsBusy = false; });
  }
  window.empDockOpen = function (on) { try { localStorage.setItem('konetEmpDockOpen', on ? '1' : '0'); } catch (e) { } dockApply(); if (on) refreshAll(); };
  window.empDockGo = function (key, sub) {
    if (sub === 'new') openScreen('empMsg', function (w) { return typeof w.openPick === 'function'; }, function (w) { w.openPick('new'); });
    else openScreen(key, function () { return true; }, function () { });
  };
  window.empDockGoRoom = function (seq) {
    openScreen('empMsg', function (w) { return typeof w.openRoom === 'function' && w.ROOMS; }, function (w) { w.openRoom(Number(seq)); });
  };
  window.empDockRefresh = function () { refreshAll(); if (typeof window._toast === 'function') _toast('새로 읽었습니다.', 'ok'); };

  /* ── ④ 「대표자 일정」 옆 «지난 미완료» 건수 (2026-11-19 사용자 「메뉴 옆에 지난 미완료 건수 표시해줘요」) ──
       · 배지 자리 #ceoLateBadge 는 총괄관리자에게만 있다(셸이 메뉴째 가린다) — 없으면 아무것도 부르지 않는다
       · 새 서버 주소 없이 일정 목록(/mangr/ceoSchedList.do, 미완료만 · 어제까지 시작한 것)을 그대로 읽어 «끝나는 날이 오늘보다 앞선 것»을 센다
         — 화면(ceoSched.jsp)의 「지난 미완료」와 같은 셈. 말풍선에 제목 다섯 개까지
       · 처음 한 번 · 5분마다(자정을 넘기면 저절로 바뀐다) · 탭으로 돌아왔을 때 · 일정 화면이 저장·체크·삭제한 뒤 parent.konetCeoBadge() */
  var ceoBusy = false, ceoTimer = null;
  function ymd8(d) { return '' + d.getFullYear() + ('0' + (d.getMonth() + 1)).slice(-2) + ('0' + d.getDate()).slice(-2); }
  function fetchCeo() {
    if (ceoBusy || document.hidden || !document.getElementById('ceoLateBadge')) return;
    ceoBusy = true;
    var t = new Date(), today = ymd8(t), yest = ymd8(new Date(t.getFullYear(), t.getMonth(), t.getDate() - 1));
    fetch(CTX + '/mangr/ceoSchedList.do', { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'frDt=00000101&toDt=' + yest + '&doneYn=N' })
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (j) {
        ceoBusy = false;
        if (!j || j.error || !j.data) return;      /* 세션 없음·표 없음·권한 없음 = 조용히(마지막 값 유지) */
        var late = j.data.filter(function (x) { return x && x.doneYn !== 'Y' && x.doneYn !== 'C' && String(x.toDt || '') < today; });   /* 완료·일정취소는 뺀다 (2026-11-19 상태 셋) */
        var nm = late.slice(0, 5).map(function (x) { return x.title; }).join(', ');
        paint('ceoLateBadge', late.length, '날짜가 지난 미완료 일정 ' + late.length + '건' + (nm ? ' : ' + nm + (late.length > 5 ? ' 외 ' + (late.length - 5) + '건' : '') : ''));
      })
      .catch(function () { ceoBusy = false; });
  }
  window.konetCeoBadge = fetchCeo;

  /* ★로그인 창의 «지난 미완료»를 며칠 전 것까지 보일지 (2026-11-19 사용자 「미완료 건 메세지(로그인 화면 최초에서) — 며칠 전까지 메세지 처리인지 설정하기」
       → 「설정은 여기서(대표자 일정 화면 위 줄) · 숫자로 치게 · 0이면 안 뜸」)
       · 숫자 n = 끝나는 날이 n일 전 안쪽인 미완료만 · 0 = 지난 미완료를 아예 안 띄움 · 비우면(설정 없음) = 전부(종전 그대로)
       · 고르는 곳은 대표자 일정 화면 위 줄 하나(로그인 창에서는 못 바꾼다) — localStorage('konetCeoLateDays2', 이 브라우저에만)
         ※키 이름에 2 : 잠깐(같은 날) 고르기 칸 판이 「전부」를 '0'으로 남겼다 — 그 값이 새 판에서 «안 띄움»으로 읽히지 않게 키를 바꿨다
       · 메뉴 옆 빨간 숫자(④)는 종전대로 지난 미완료 «전부»를 센다 */
  /* ★기본 = 0 (같은 날 사용자 「기본 0으로」) — 설정이 없거나 비어 있으면 0 = 창에 «지난 미완료»를 안 보인다. 「전부」 는 없어졌다(크게 보고 싶으면 365)
     ★창 자체는 늘 뜬다 (같은 날 사용자 「지난 내용 미완료 건이고 당일 미완료 건은 무조건 떠야 함 — 당일 일정은 알아야 함. 최초 뜰 때 과거 건 미완료 메세지를 이야기한 것」)
       — 잠깐 「0 = 로그인 창을 안 띄움」으로 했다가 되돌렸다. 오늘부터 일주일 일정은 설정과 상관없이 보이고, 이 숫자는 그 밑 «지난 미완료» 줄만 정한다 */
  function ceoLateDays() {            /* 0 = 지난 미완료 안 보임(기본) · n = n일 */
    var v = null; try { v = localStorage.getItem('konetCeoLateDays2'); } catch (e) { }
    var n = parseInt(v == null ? '' : v, 10); return (isNaN(n) || n < 0) ? 0 : Math.min(n, 365);
  }
  window.konetCeoLateDays = ceoLateDays;

  /* ── ⑤ 로그인 직후 「대표자 일정 — 오늘부터 일주일」 요약 창 (2026-11-19 사용자 「대표자 로그인하면 총괄관리자 오늘부터 일주일 써머리해서 보여줘요」 「별도 일정등록 버튼으로 들어가게」) ──
       · 언제 : 로그인에 성공해 이 화면으로 막 들어왔을 때 한 번 — 로그인 화면(base_login.jsp)이 넘어오기 직전 sessionStorage('konetJustLogin')='1' 을 남기고,
                여기서 읽자마자 지운다. 그래서 새로고침(F5)이나 메뉴 이동으로는 다시 뜨지 않는다. 총괄관리자가 아니면(메뉴 배지 자리 #ceoLateBadge 없음) 아무것도 안 한다
       · 무엇 : 오늘 ~ 6일 뒤(7일)의 일정을 날짜별로 — 시간 · 제목 · 장소 · 상태(완료/일정취소는 줄 긋고 흐리게). 여러 날 일정은 «기간 안의 첫날»에 한 번, 끝나는 날을 덧붙인다.
                그 밑에 날짜가 지난 미완료(다섯 건까지). 일정이 하나도 없어도 창은 뜬다(「일정 없음」 — 이번 주가 비었다는 것도 알릴 내용이다)
       · 들어가기 : 줄을 눌러서가 아니라 아래의 **따로 있는 단추** [일정 등록 화면으로 →] — 왼쪽 메뉴 「대표자 일정」을 그대로 누른다(화면 여는 길을 두 벌로 만들지 않는다)
       · 닫기 : [닫기] · ✕ · Esc · 창 바깥.   「오늘은 그만 보기」에 체크하고 닫으면 그날은 다시 안 뜬다(아래 ceoWeekClose).
                다시 보고 싶으면 콘솔에서 konetCeoWeek() — 화면에는 로그인 때만 */
  var WK7 = ['일', '월', '화', '수', '목', '금', '토'];
  function toD8(s) { return new Date(+String(s).slice(0, 4), +String(s).slice(4, 6) - 1, +String(s).slice(6, 8)); }
  function mdw(s) { var d = toD8(s); return (d.getMonth() + 1) + '/' + d.getDate() + '(' + WK7[d.getDay()] + ')'; }
  function ceoList(body) {
    return fetch(CTX + '/mangr/ceoSchedList.do', { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: body })
      .then(function (r) { return r.ok ? r.json() : null; });
  }
  function ceoWeekCss() {
    if (document.getElementById('ceoWeekCss')) return;
    var st = document.createElement('style'); st.id = 'ceoWeekCss';
    st.textContent =
        '#ceoWeek{position:fixed;inset:0;z-index:4000;background:rgba(15,23,32,.38);display:flex;align-items:flex-start;justify-content:center;padding-top:9vh;font-family:"맑은 고딕","Malgun Gothic",sans-serif}'
      + '#ceoWeek .cw-box{width:min(560px,94vw);max-height:80vh;display:flex;flex-direction:column;background:#fff;border-radius:12px;box-shadow:0 14px 44px rgba(0,0,0,.34);overflow:hidden;color:#1f2a37}'
      + '#ceoWeek .cw-h{display:flex;align-items:center;gap:10px;padding:12px 16px;background:#137a6c;color:#fff}'
      + '#ceoWeek .cw-h b{font-size:16px}#ceoWeek .cw-h span{flex:1;font-size:12.5px;opacity:.9}'
      + '#ceoWeek .cw-x{width:28px;height:28px;border:0;border-radius:6px;background:rgba(255,255,255,.18);color:#fff;font-size:14px;cursor:pointer}#ceoWeek .cw-x:hover{background:rgba(255,255,255,.32)}'
      + '#ceoWeek .cw-s{padding:8px 16px;background:#f1f9f7;border-bottom:1px solid #dbe2ea;font-size:13px;color:#37475a}#ceoWeek .cw-s b{color:#0f6b5e}#ceoWeek .cw-s b.late{color:#b23b3b}'
      + '#ceoWeek .cw-b{flex:1 1 auto;min-height:60px;overflow:auto;padding:6px 16px 10px}'
      + '#ceoWeek .cw-d{margin:10px 0 4px;padding-bottom:3px;border-bottom:1px solid #e3e8ee;font-size:13px;font-weight:800;color:#48606f}'
      + '#ceoWeek .cw-d.tdy{color:#0f6b5e}#ceoWeek .cw-d.tdy i{font-style:normal;display:inline-block;margin-right:6px;padding:0 8px;border-radius:9px;background:#137a6c;color:#fff;font-size:11.5px}'
      + '#ceoWeek .cw-d.late{color:#b23b3b}'
      + '#ceoWeek .cw-i{display:flex;align-items:baseline;gap:8px;padding:4px 2px;font-size:13.5px}'
      + '#ceoWeek .cw-i .tm{flex:none;width:44px;font-weight:800;color:#0f6b5e;font-variant-numeric:tabular-nums;font-size:12.5px}'
      + '#ceoWeek .cw-i .tt{flex:1;min-width:0;font-weight:700;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}'
      + '#ceoWeek .cw-i .pl{flex:none;max-width:38%;color:#6b7a89;font-size:12.5px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}'
      + '#ceoWeek .cw-i .tg{flex:none;padding:0 7px;border-radius:9px;background:#eef1f4;color:#5a6b7a;font-size:11.5px;font-weight:800}'
      + '#ceoWeek .cw-i .tg.late{background:#fde8e8;color:#a12b2b}'
      + '#ceoWeek .cw-i.off .tt{color:#48606f;font-weight:600}#ceoWeek .cw-i.off .tm,#ceoWeek .cw-i.off .pl{color:#6b7a89}'   /* 취소선 없음 (2026-11-19 사용자 「글자 중간선은 제거」) */
      + '#ceoWeek .cw-i .tg.cx{background:#fde8e8;color:#c0392b}'
      + '#ceoWeek .cw-ld{display:inline-flex;align-items:center;gap:5px;font-size:13px;color:#48606f}#ceoWeek .cw-ld select{height:28px;border:1px solid #cbd5e1;border-radius:6px;font-family:inherit;font-size:12.5px;padding:0 4px;cursor:pointer}'
      + '#ceoWeek .cw-e{padding:26px 6px;text-align:center;color:#8794a1;font-size:13.5px}'
      + '#ceoWeek .cw-f{display:flex;gap:8px;align-items:center;padding:10px 16px;border-top:1px solid #dbe2ea;background:#fff}'
      + '#ceoWeek .cw-ck{display:inline-flex;align-items:center;gap:6px;font-size:13px;color:#48606f;cursor:pointer;user-select:none}#ceoWeek .cw-ck input{width:16px;height:16px;accent-color:#137a6c;cursor:pointer}'
      + '#ceoWeek .cw-f button{height:34px;padding:0 16px;border-radius:6px;font-size:13.5px;font-weight:700;cursor:pointer;font-family:inherit}'
      + '#ceoWeek .cw-go{border:1px solid #137a6c;background:#137a6c;color:#fff}#ceoWeek .cw-go:hover{background:#0f6b5e}'
      + '#ceoWeek .cw-cl{border:1px solid #cbd5e1;background:#fff;color:#37475a}';
    (document.head || document.documentElement).appendChild(st);
  }
  /* ★「오늘은 그만 보기」 (2026-11-19 사용자 「로그인하면 뜨는 내용 계속 뜰지 오늘은 그만일지 선택하게」) — 기본은 계속(로그인할 때마다 뜬다).
     창 왼쪽 아래 칸에 체크하고 닫으면 localStorage('konetCeoWeekSkip')에 오늘 날짜를 남겨, 그날은 다시 로그인해도 안 뜬다. 날이 바뀌면 저절로 다시 뜬다.
     이 브라우저에만 남는다(다른 PC 에서는 따로) */
  function ceoWeekClose() {
    var p = document.getElementById('ceoWeek');
    if (p) { var ck = p.querySelector('#ceoWeekSkip'); if (ck && ck.checked) { try { localStorage.setItem('konetCeoWeekSkip', ymd8(new Date())); } catch (e) { } } }
    if (p && p.parentNode) p.parentNode.removeChild(p); document.removeEventListener('keydown', ceoWeekKey);
  }
  function ceoWeekKey(e) { if (e.key === 'Escape') ceoWeekClose(); }
  function ceoWeekShow() {
    if (!document.getElementById('ceoLateBadge')) return;            /* 총괄관리자만 */
    var t = new Date(), a = ymd8(t), b = ymd8(new Date(t.getFullYear(), t.getMonth(), t.getDate() + 6)), y = ymd8(new Date(t.getFullYear(), t.getMonth(), t.getDate() - 1)), tm = ymd8(new Date(t.getFullYear(), t.getMonth(), t.getDate() + 1));
    Promise.all([ceoList('frDt=' + a + '&toDt=' + b), ceoList('frDt=00000101&toDt=' + y + '&doneYn=N')])
      .then(function (r) {
        if (!r[0] || r[0].error || !r[0].data) return;               /* 세션 없음·표 없음·권한 없음 = 조용히 */
        var ld = ceoLateDays(), lim = (ld > 0) ? ymd8(new Date(t.getFullYear(), t.getMonth(), t.getDate() - ld)) : '';
        var lateAll = (ld === 0) ? [] : ((r[1] && r[1].data) || []).filter(function (x) { return x && x.doneYn !== 'Y' && x.doneYn !== 'C' && String(x.toDt || '') < a; });   /* 0 = 지난 미완료 안 띄움 */
        var list = r[0].data.slice(), late = lateAll.filter(function (x) { return !lim || String(x.toDt || '') >= lim; });   /* 설정한 날수 안쪽만 */
        late.sort(function (p, q) { return String(q.toDt) < String(p.toDt) ? -1 : (String(q.toDt) > String(p.toDt) ? 1 : 0); });   /* 최근에 지난 것이 위 */
        var nY = 0, nC = 0;
        list.forEach(function (x) { x._day = (String(x.fromDt) < a) ? a : String(x.fromDt); if (x.doneYn === 'Y') nY++; else if (x.doneYn === 'C') nC++; });
        list.sort(function (p, q) { return p._day < q._day ? -1 : (p._day > q._day ? 1 : ((p.schedTm || '99') < (q.schedTm || '99') ? -1 : ((p.schedTm || '99') > (q.schedTm || '99') ? 1 : p.schedSeq - q.schedSeq))); });
        function item(x, dateFirst) {
          var off = (x.doneYn === 'Y' || x.doneYn === 'C'), span = (x.toDt !== x.fromDt) ? ' ~ ' + mdw(x.toDt) : '';
          return '<div class="cw-i' + (off ? ' off' : '') + '"><span class="tm">' + (dateFirst ? esc(mdw(x.fromDt).replace(/\(.\)$/, '')) : esc(x.schedTm || '종일')) + '</span>'
            + '<span class="tt" title="' + esc(x.title) + '">' + esc(x.title) + (span ? ' <small style="font-weight:400;color:#6b7a89">' + esc(span) + '</small>' : '') + '</span>'
            + (x.place ? '<span class="pl" title="' + esc(x.place) + '">' + esc(x.place) + '</span>' : '')
            + (x.doneYn === 'Y' ? '<span class="tg">완료</span>' : (x.doneYn === 'C' ? '<span class="tg cx">취소</span>' : (dateFirst ? '<span class="tg late">' + Math.round((toD8(a) - toD8(x.toDt)) / 86400000) + '일 지남</span>' : ''))) + '</div>';
        }
        var h = '', day = '';
        list.forEach(function (x) {
          if (x._day !== day) { day = x._day; h += '<div class="cw-d' + (day === a ? ' tdy' : '') + '">' + (day === a ? '<i>오늘</i>' : (day === tm ? '내일 · ' : '')) + esc(mdw(day)) + '</div>'; }
          h += item(x, false);
        });
        if (!list.length) h += '<div class="cw-e">오늘부터 일주일 동안 등록된 일정이 없습니다.</div>';
        if (late.length) {
          h += '<div class="cw-d late">지난 미완료 ' + (ld > 0 ? '(최근 ' + ld + '일) ' : '') + late.length + '건</div>';
          late.slice(0, 10).forEach(function (x) { h += item(x, true); });
          if (late.length > 10) h += '<div class="cw-i"><span class="tm"></span><span class="tt" style="font-weight:400;color:#8794a1">… 외 ' + (late.length - 10) + '건</span></div>';
        }
        if (ld > 0 && lateAll.length > late.length) {
          h += '<div class="cw-i"><span class="tm"></span><span class="tt" style="font-weight:400;color:#8794a1">' + ld + '일보다 오래된 미완료 ' + (lateAll.length - late.length) + '건은 대표자 일정 「미완료」 탭에서 보입니다</span></div>';
        }
        ceoWeekCss(); ceoWeekClose();
        var p = document.createElement('div'); p.id = 'ceoWeek';
        p.innerHTML = '<div class="cw-box">'
          + '<div class="cw-h"><b>🗓 대표자 일정 — 오늘부터 일주일</b><span>' + esc(mdw(a)) + ' ~ ' + esc(mdw(b)) + '</span><button type="button" class="cw-x" data-cw="close" title="닫기 (Esc)">✕</button></div>'
          + '<div class="cw-s">일정 <b>' + list.length + '</b>건' + (list.length ? ' · 완료 ' + nY + (nC ? ' · 취소 ' + nC : '') + ' · 남은 일정 <b>' + (list.length - nY - nC) + '</b>' : '')
          + (late.length ? ' &nbsp;|&nbsp; 지난 미완료' + (ld > 0 ? '(최근 ' + ld + '일)' : '') + ' <b class="late">' + late.length + '</b>건' : '') + '</div>'
          + '<div class="cw-b">' + h + '</div>'
          + '<div class="cw-f"><label class="cw-ck" title="체크하고 닫으면 오늘은 다시 로그인해도 이 창이 뜨지 않습니다 — 내일부터는 다시 뜹니다. 체크하지 않으면 로그인할 때마다 뜹니다"><input type="checkbox" id="ceoWeekSkip"> 오늘은 그만 보기</label><span style="flex:1"></span><button type="button" class="cw-go" data-cw="go" title="왼쪽 메뉴 「대표자 일정」 화면을 엽니다 — 거기서 등록·수정·완료 체크">🗓 일정 등록 화면으로 →</button><button type="button" class="cw-cl" data-cw="close">닫기</button></div>'
          + '</div>';
        p.addEventListener('click', function (e) {
          var bt = e.target.closest ? e.target.closest('[data-cw]') : null;
          if (bt && bt.getAttribute('data-cw') === 'go') { ceoWeekClose(); openScreen('ceoSched', function () { return true; }, function () { }); return; }
          if (bt || e.target === p) ceoWeekClose();                 /* [닫기] · ✕ · 창 바깥 */
        });
        document.body.appendChild(p);
        document.addEventListener('keydown', ceoWeekKey);
      })
      .catch(function () { });
  }
  window.konetCeoWeek = ceoWeekShow;
  /* 로그인 화면이 남긴 표식 — 읽자마자 지운다(누구든). 총괄관리자면 요약 창 */
  function ceoWeekOnLogin() {
    var just = false;
    try { just = (sessionStorage.getItem('konetJustLogin') === '1'); if (just) sessionStorage.removeItem('konetJustLogin'); } catch (e) { }
    if (!just) return;
    var skip = ''; try { skip = localStorage.getItem('konetCeoWeekSkip') || ''; } catch (e) { }
    if (skip === ymd8(new Date())) return;                       /* 「오늘은 그만 보기」로 닫았다 */
    setTimeout(ceoWeekShow, 500);
  }

  /* ── 시작 ── */
  function refreshAll() { fetchBadge(); fetchTicker(); fetchRooms(); }
  function start() {
    dockApply();
    if (timer) clearInterval(timer);
    if (tickTimer) clearInterval(tickTimer);
    refreshAll();
    timer = setInterval(function () { fetchBadge(); if (dockOpen()) fetchRooms(); }, PERIOD);
    tickTimer = setInterval(fetchTicker, TICK_PERIOD);
    fetchCeo(); if (ceoTimer) clearInterval(ceoTimer); ceoTimer = setInterval(fetchCeo, 300000);   /* ④ 대표자 일정 — 5분마다 */
    ceoWeekOnLogin();   /* ⑤ 로그인 직후 한 번 — 오늘부터 일주일 요약 창 */
  }
  window.konetEmpBadge = refreshAll;   /* iframe 화면이 저장·읽음 처리 뒤 부른다 — 배지·띠·도크를 함께 */
  document.addEventListener('click', function (e) {
    var it = e.target.closest ? e.target.closest('#empTickerBar .et-item[data-seq]') : null;
    if (it) window.empTickerOpen(it.getAttribute('data-seq'));
  });
  document.addEventListener('visibilitychange', function () { if (!document.hidden) { refreshAll(); fetchCeo(); } });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
