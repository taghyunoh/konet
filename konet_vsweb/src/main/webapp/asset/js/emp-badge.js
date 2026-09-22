/* =====================================================================
   emp-badge.js — 셸(logistics_demo2.jsp)의 직원 소통 세 가지 (2026-09-22)
     ① 사이드바 「직원 공지사항 / 직원 메신저」 안 읽음 배지
        · 30초마다 POST /emp/badge.do → {noticeUnread, msgUnread, roomUnread}
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
   셸 JSP 에 스크립트를 넣지 않는 이유 = 그 JSP 는 인라인 스크립트 한도(65535)에 닿아 있다(파일 머리말 참고).
   ===================================================================== */
(function () {
  var CTX = (typeof KONET_CTX === 'string') ? KONET_CTX : '';
  var PERIOD = 30000, TICK_PERIOD = 60000;
  var lastMsg = -1, timer = null, busy = false;
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
  function paint(id, n, dockToo) {
    var el = document.getElementById(id);
    if (!el) return;
    n = Number(n) || 0;
    el.textContent = n > 99 ? '99+' : String(n);
    el.style.display = n > 0 ? '' : 'none';
    el.title = n > 0 ? ('안 읽은 것 ' + n + '건') : '';
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
        paint('empDockNoticeN', j.noticeUnread); paint('empDockMsgN', j.msgUnread);
        paint('empDockTabN1', j.noticeUnread); paint('empDockTabN2', j.msgUnread);
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

  /* ── 시작 ── */
  function refreshAll() { fetchBadge(); fetchTicker(); fetchRooms(); }
  function start() {
    dockApply();
    if (timer) clearInterval(timer);
    if (tickTimer) clearInterval(tickTimer);
    refreshAll();
    timer = setInterval(function () { fetchBadge(); if (dockOpen()) fetchRooms(); }, PERIOD);
    tickTimer = setInterval(fetchTicker, TICK_PERIOD);
  }
  window.konetEmpBadge = refreshAll;   /* iframe 화면이 저장·읽음 처리 뒤 부른다 — 배지·띠·도크를 함께 */
  document.addEventListener('click', function (e) {
    var it = e.target.closest ? e.target.closest('#empTickerBar .et-item[data-seq]') : null;
    if (it) window.empTickerOpen(it.getAttribute('data-seq'));
  });
  document.addEventListener('visibilitychange', function () { if (!document.hidden) refreshAll(); });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
