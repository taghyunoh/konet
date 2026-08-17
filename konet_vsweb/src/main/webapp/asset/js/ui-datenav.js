/* =============================================================================
   ui-datenav.js — 날짜 칸 공통 (2026-08-17 요청)
     ***우리 달력*** — 브라우저 기본 달력을 막고 대신 띄운다.
     (칸 옆 단추 묶음은 2026-08-17 지시로 **뺐다** — 화면의 [당일][당월][전체] 와 겹쳤다.)

   ★왜 우리 달력을 만들었나
     `<input type="date">` 의 달력은 **크롬이 브라우저 UI 로 띄운다**(페이지 밖).
     CSS·JS 가 닿지 않아 ***월 이동 화살표(`↑ ↓`)를 바꿀 수 없다.***
     위/아래로는 「앞/뒤」가 안 읽혀 엉뚱한 달로 넘어가는 일이 잦았다
     (실제로 매입일자가 다음 달로 가 있었다).
     ★★그리고 ***월별로 고르는 일이 많다***(2026-08-17 사용자) — 그 잦은 일이 가장 헷갈리는
       자리였다. 하루씩 옮기는 단추로는 해결되지 않는다.
     ⇒ 기본 달력을 감추고 **월 이동을 `‹ ›`(좌우)** 로 둔 달력을 우리가 그린다.
       `«  »` 는 1년 단위. 브라우저가 달라도 모양이 같아진다.

   ⚠**삭제(지우기) 단추는 두지 않는다**(사용자 지시) — 날짜를 비우는 것은 대개 실수다.
   ★`type="date"` 는 **그대로 둔다** — `.value` 가 늘 'YYYY-MM-DD' 라 기존 코드가 안 깨진다.
     기본 달력은 아이콘만 감춰 막는다(그 아이콘이 유일한 진입점이다).
   ⚠`.value` 를 코드로 바꿔도 onchange 는 안 돈다 ⇒ change 를 직접 쏜다.
     안 쏘면 딸린 조회(전표번호 재조회 등)가 안 돈다.

   쓰는 법 : 이 파일만 넣으면 그 화면의 모든 날짜 칸에 저절로 붙는다(화면 수정 0).
             빼려면 그 칸에  data-nonav="1"
   ============================================================================= */
(function () {
  'use strict';
  if (window.__uiDateNav) return;
  window.__uiDateNav = true;

  var CSS =
    /* 기본 달력 아이콘을 감춘다 — 이걸 눌러야 브라우저 달력이 뜨므로, 감추면 우리 것만 뜬다 */
    'input[type=date].udn-on::-webkit-calendar-picker-indicator{ display:none; -webkit-appearance:none; }' +
    /* ── 우리 달력 ── */
    '.udnCal{ position:absolute; z-index:9999; background:#fff; border:1px solid #cfd9e0; border-radius:10px;' +
    '  box-shadow:0 10px 30px rgba(15,23,32,.22); padding:8px; width:246px; font-size:13px; color:#1f2a37; }' +
    '.udnCal .hd{ display:flex; align-items:center; gap:3px; margin-bottom:6px; }' +
    '.udnCal .hd .t{ flex:1; text-align:center; font-weight:800; font-size:13.5px; }' +
    '.udnCal .hd button{ width:26px; height:26px; border:1px solid #cfd9e0; background:#fff; border-radius:6px;' +
    '  cursor:pointer; font-size:13px; line-height:1; color:#43555f; }' +
    '.udnCal .hd button:hover{ background:#eef3f6; }' +
    /* ★★페이지의 표 CSS 를 **물려받지 않게** 못 박는다 (2026-08-17 사고).
       화면마다 `table{width:100%}`·`th{background}`·`td{border}` 같은 규칙이 있어서,
       그대로 두면 달력 칸이 ***화면 폭만큼 퍼지고 본문 표와 겹쳤다***(택배출고관리·출고세부조회).
       달력은 남의 화면 위에 얹히는 것이므로 **자기 값을 !important 로 고정**해야 안전하다.
       table-layout:fixed 까지 줘서 칸 너비가 내용에 따라 흔들리지 않게 한다. */
    '.udnCal table{ border-collapse:collapse !important; table-layout:fixed !important;' +
    '  width:224px !important; min-width:0 !important; max-width:none !important; margin:0 !important;' +
    '  background:none !important; border:0 !important; font-size:13px !important; }' +
    /* ★`thead`·`tbody`·`tr` 까지 막는다 (2026-08-17 — 택배출고관리에서 **요일 밑에 줄**이 생겼다).
       그 화면 CSS 가 `tbody td{ border-bottom:… }` 처럼 **선택자를 다르게** 걸어 두면
       th/td 만 막아서는 새어 든다. 달력은 남의 화면에 얹히므로 **표의 모든 부위를 못 박는다.** */
    '.udnCal thead, .udnCal tbody, .udnCal tr{ border:0 !important; background:none !important; }' +
    /* ★★선은 border 만이 아니다 (2026-08-17 — 요일 밑 줄의 진짜 원인).
       parcelOut 은 `thead th{ box-shadow: inset 0 -2px 0 #0e6657 }` 로 선을 그린다.
       border 만 막아서는 안 지워진다. ***sticky·z-index 도 함께 막는다*** —
       그대로 두면 달력 머리줄이 스크롤에 붙어 따라다닌다.
       ⚠우리 `.today` 표시는 **button** 의 box-shadow 라 여기 걸리지 않는다(확인함). */
    '.udnCal th, .udnCal td, .udnCal tbody td, .udnCal thead th{ border:0 !important;' +
    '  border-bottom:0 !important; border-top:0 !important; background:none !important;' +
    '  box-shadow:none !important; outline:0 !important; background-image:none !important;' +
    '  position:static !important; top:auto !important; z-index:auto !important;' +
    '  color:inherit; height:auto !important; white-space:nowrap !important;' +
    '  vertical-align:middle !important; }' +
    '.udnCal th{ width:32px !important; font-size:11.5px !important; color:#8a97a3 !important;' +
    '  font-weight:700 !important; padding:2px 0 !important; text-align:center !important; }' +
    '.udnCal td{ width:32px !important; padding:1px !important; text-align:center !important; }' +
    '.udnCal td button{ width:30px !important; height:28px !important; border:0 !important;' +
    '  background:none; border-radius:6px; cursor:pointer; font-size:12.5px !important; color:#1f2a37;' +
    '  margin:0 !important; padding:0 !important; }' +
    '.udnCal td button:hover{ background:#eef3f6; }' +
    '.udnCal td button.out{ color:#c9d2d9; }' +
    '.udnCal td button.sun{ color:#c0392b; }' +
    '.udnCal td button.sat{ color:#1f6fb2; }' +
    '.udnCal td button.today{ box-shadow:inset 0 0 0 1px #1f9b8e; font-weight:800; }' +
    '.udnCal td button.on{ background:#137a6c; color:#fff; font-weight:800; }' +
    '.udnCal .ft{ margin-top:6px; text-align:center; }' +
    '.udnCal .ft button{ height:26px; padding:0 14px; border:1px solid #a9d5cd; background:#fff; color:#137a6c;' +
    '  border-radius:6px; cursor:pointer; font-size:12px; font-weight:700; }';

  /* ★★`showPicker()` 를 무력화한다 (2026-08-17 사고).
     일부 화면이 칸을 누르면 **기본 달력을 직접 연다**(logistics_demo1 의 d2OpenCal ·
     demo2 의 ssOpenCal 이 `el.showPicker()` 를 부른다). 그러면 우리 달력과 **둘이 겹쳐** 보인다.
     ⇒ 화면을 하나하나 고치는 대신 ***여기서 한 번에 막는다*** —
       우리가 붙인 칸(.udn-on)이면 기본 달력을 열지 않고 **우리 달력을 연다.**
     ⚠원래 함수를 지우지 않는다(다른 타입 칸이 쓸 수 있다) — 우리 칸만 갈아탄다. */
  function hookShowPicker() {
    try {
      var proto = HTMLInputElement.prototype;
      if (!proto.showPicker || proto.__udnHooked) return;
      var orig = proto.showPicker;
      proto.showPicker = function () {
        if (this.classList && this.classList.contains('udn-on')) { calOpen(this); return; }
        return orig.apply(this, arguments);
      };
      proto.__udnHooked = true;
    } catch (e) { /* 막지 못해도 화면은 돌아야 한다 */ }
  }

  function addCss() {
    if (document.getElementById('udnCss')) return;
    var st = document.createElement('style');
    st.id = 'udnCss'; st.textContent = CSS;
    (document.head || document.documentElement).appendChild(st);
  }

  function ymd(d) {
    return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2);
  }
  /** 'YYYY-MM-DD' → Date. ★'T00:00:00' 을 붙여야 **시간대 때문에 하루 밀리지 않는다.** */
  function parse(v) {
    if (!v) return null;
    var d = new Date(v + 'T00:00:00');
    return isNaN(d.getTime()) ? null : d;
  }
  function setVal(el, v) {
    el.value = v;
    try { el.dispatchEvent(new Event('change', { bubbles: true })); }
    catch (e) { var ev = document.createEvent('HTMLEvents'); ev.initEvent('change', true, false); el.dispatchEvent(ev); }
  }

  /* ── 우리 달력 ──────────────────────────────────────────────────────────── */
  var cal = null, calFor = null, calYm = null;   // calYm = 보고 있는 달(그 달 1일)

  function calClose() {
    if (cal && cal.parentNode) cal.parentNode.removeChild(cal);
    cal = null; calFor = null;
  }
  function calDraw() {
    if (!cal) return;
    var y = calYm.getFullYear(), m = calYm.getMonth();
    var sel = parse(calFor.value), tod = new Date();
    var first = new Date(y, m, 1), cur = new Date(y, m, 1 - first.getDay());
    /* ★월 이동은 `‹ ›`(좌우) — 월별로 고르는 일이 많아 이것이 가장 자주 눌린다.
       `« »` 는 1년. 위/아래 화살표를 쓰지 않는 이유가 여기 있다(앞/뒤가 안 읽힌다). */
    var h = '<div class="hd">'
          + '<button type="button" data-mv="-12" title="1년 앞으로">&laquo;</button>'
          + '<button type="button" data-mv="-1"  title="한 달 앞으로">&lsaquo;</button>'
          + '<span class="t">' + y + '년 ' + (m + 1) + '월</span>'
          + '<button type="button" data-mv="1"   title="한 달 뒤로">&rsaquo;</button>'
          + '<button type="button" data-mv="12"  title="1년 뒤로">&raquo;</button>'
          + '</div><table><thead><tr>';
    var W = ['일','월','화','수','목','금','토'];
    for (var w = 0; w < 7; w++) {
      h += '<th' + (w === 0 ? ' style="color:#c0392b"' : w === 6 ? ' style="color:#1f6fb2"' : '') + '>' + W[w] + '</th>';
    }
    h += '</tr></thead><tbody>';
    for (var r = 0; r < 6; r++) {
      h += '<tr>';
      for (var c = 0; c < 7; c++) {
        var cls = [];
        if (cur.getMonth() !== m) cls.push('out');
        else if (c === 0) cls.push('sun'); else if (c === 6) cls.push('sat');
        if (ymd(cur) === ymd(tod)) cls.push('today');
        if (sel && ymd(cur) === ymd(sel)) cls.push('on');
        h += '<td><button type="button" class="' + cls.join(' ') + '" data-d="' + ymd(cur) + '">' + cur.getDate() + '</button></td>';
        cur.setDate(cur.getDate() + 1);
      }
      h += '</tr>';
      if (cur.getMonth() !== m && r >= 4) break;      // 다 그렸으면 빈 줄을 더 만들지 않는다
    }
    /* ⚠[지우기] 는 두지 않는다(사용자 지시) — 날짜를 비우는 것은 대개 실수다 */
    h += '</tbody></table><div class="ft"><button type="button" data-today="1">오늘</button></div>';
    cal.innerHTML = h;
  }
  function calOpen(el) {
    if (calFor === el && cal) return;               // 같은 칸이면 그대로 둔다
    calClose();
    calFor = el;
    var base = parse(el.value) || new Date();
    calYm = new Date(base.getFullYear(), base.getMonth(), 1);
    cal = document.createElement('div');
    cal.className = 'udnCal';
    document.body.appendChild(cal);
    calDraw();
    /* 칸 아래에 놓고, 아래가 좁으면 위로 올린다 */
    var r = el.getBoundingClientRect(), sx = window.pageXOffset, sy = window.pageYOffset;
    var top = r.bottom + sy + 4;
    if (r.bottom + cal.offsetHeight + 8 > window.innerHeight) top = r.top + sy - cal.offsetHeight - 4;
    var left = Math.min(r.left + sx, sx + window.innerWidth - cal.offsetWidth - 8);
    cal.style.top = Math.max(sy + 4, top) + 'px';
    cal.style.left = Math.max(sx + 4, left) + 'px';

    /* 달력을 눌러도 칸의 focus 를 잃지 않게 — 잃으면 blur 로 닫히며 클릭이 씹힌다 */
    cal.addEventListener('mousedown', function (e) { e.preventDefault(); });
    cal.addEventListener('click', function (e) {
      var b = e.target;
      if (!b || b.tagName !== 'BUTTON') return;
      var mv = b.getAttribute('data-mv');
      if (mv) {   // ★달을 옮길 때는 창을 닫지 않는다 — 훑어 보다가 고른다
        calYm = new Date(calYm.getFullYear(), calYm.getMonth() + Number(mv), 1);
        calDraw(); return;
      }
      if (b.getAttribute('data-today')) { setVal(calFor, ymd(new Date())); calClose(); return; }
      var v = b.getAttribute('data-d');
      if (v) { setVal(calFor, v); calClose(); }
    });
  }
  /* 바깥을 누르면 닫는다 — 칸 자신과 달력 안은 뺀다 */
  document.addEventListener('mousedown', function (e) {
    if (!cal) return;
    if (cal.contains(e.target) || e.target === calFor) return;
    calClose();
  }, true);
  window.addEventListener('scroll', calClose, true);
  document.addEventListener('keydown', function (e) { if (e.keyCode === 27) calClose(); });
  /* ★★화면을 옮기면 달력을 닫는다 (2026-08-17 사고 "다른 화면 가면 달력 떠있음").
     달력은 `document.body` 에 붙는데, 이 앱은 **같은 문서에서 화면만 갈아 끼운다.**
     그래서 칸이 사라져도 달력만 남아 떠 있었다.
     ⇒ 달고 있던 칸이 **문서에서 빠졌으면** 닫는다. 화면 전환·팝업 닫힘·그리드 재생성에 다 걸린다. */
  function calCheckAlive() {
    if (!cal) return;
    if (!calFor || !document.body.contains(calFor)) calClose();
  }
  if (window.MutationObserver) {
    new MutationObserver(calCheckAlive).observe(document.documentElement, { childList: true, subtree: true });
  }
  window.addEventListener('beforeunload', calClose);
  window.addEventListener('hashchange', calClose);

  /* ── 칸에 붙이기 ────────────────────────────────────────────────────────── */
  function attach(el) {
    if (!el || el.__udn) return;
    if (el.type !== 'date') return;
    if (el.readOnly || el.disabled) return;          // 못 바꾸는 칸엔 붙이지 않는다
    if (el.getAttribute('data-nonav') === '1') return;
    el.__udn = true;
    el.classList.add('udn-on');                      // 기본 달력 아이콘 감추기

    /* ⛔칸 옆 단추 묶음([📅][◀][▶][오늘])은 **두지 않는다** (2026-08-17 지시 "이내용 삭제") —
       화면마다 이미 [당일][당월][전체] 같은 단추가 있어 겹치고, 60곳에 붙으니 어수선했다.
       ⇒ 남기는 것은 **달력 하나**다. 칸을 누르면 열린다. */
    el.addEventListener('mousedown', function (e) {
      e.preventDefault();
      try { el.focus(); } catch (_) {}
      if (cal && calFor === el) calClose(); else calOpen(el);
    });
    el.addEventListener('keydown', function (e) {
      if (e.keyCode === 115 || (e.altKey && e.keyCode === 40)) { e.preventDefault(); calOpen(el); }   // F4 · Alt+↓
    });
  }

  function scan(root) {
    var l = (root || document).querySelectorAll('input[type=date]');
    for (var i = 0; i < l.length; i++) attach(l[i]);
  }

  function boot() {
    addCss(); hookShowPicker(); scan(document);
    /* 팝업·그리드처럼 **나중에 만들어지는 칸**도 붙인다.
       ⚠내가 넣은 것(.udn / .udnCal) 때문에 다시 돌지 않도록 새 노드만 훑는다. */
    if (window.MutationObserver) {
      new MutationObserver(function (ms) {
        for (var i = 0; i < ms.length; i++) {
          var a = ms[i].addedNodes;
          for (var j = 0; j < a.length; j++) {
            var nd = a[j];
            if (nd.nodeType !== 1) continue;
            if (nd.className === 'udnCal') continue;
            if (nd.tagName === 'INPUT') attach(nd); else scan(nd);
          }
        }
      }).observe(document.documentElement, { childList: true, subtree: true });
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();
})();
