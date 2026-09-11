/* ============================================================================
   ui-colresize.js — 표 「칸 폭 조절」 공용 스크립트 (2026-09-07 신설)

   머리글 오른쪽 경계를 **끌면 그 칸이 넓어지고 좁아진다.** 매입등록·판매등록에
   화면마다 따로 박혀 있던 `bindColResize` 를 한 장으로 뽑은 것.

   ▸ 쓰는 법 — 화면 JSP 에 아래 한 줄만 걸고, 표에 `data-colrz="이름"` 을 준다.
       <script src="…/asset/js/ui-colresize.js?v=20260907"></script>
       <table data-colrz="prodcd-list"> … </table>
     동적으로 만든 표는 konetColResize(tableEl, '이름') 로 직접 건다.

   ▸ 기억한다 — 끈 폭은 localStorage('konetColW.<이름>') 에 남아 **다음에 들어와도
     그대로**다. 손잡이를 **더블클릭하면 그 표의 폭이 처음 상태로** 돌아간다
     (konetColResizeReset('이름') 도 같은 일을 한다).

   ★왜 처음부터 폭을 못 박지 않는가 — 목록 표는 자료가 오기 전에 그려지고(「불러오는
     중…」 한 줄), 그때 재면 자료가 들어온 뒤 폭과 어긋난다. ⇒ **사용자가 처음 끌 때**
     (또는 저장된 폭을 되살릴 때) 비로소 그 순간의 폭으로 얼려(table-layout:fixed +
     colgroup) 잡는다. 그전까지는 화면이 종전 그대로 돈다.

   ★얼린 뒤 `min-width` 를 칸 합으로 다시 잡는다 — 안 잡으면 넓힌 만큼 다른 칸이
     눌려 전체 폭이 그대로가 된다(table-layout:fixed 의 남는 폭 배분 규칙).
     ⚠표를 감싼 상자에 `overflow:auto` 가 있어야 넓힌 만큼 가로로 밀린다.

   ⚠머리글 첫 줄에 colspan 이 있는 표(2줄 머리글 등)는 걸지 않는다 — 칸과 col 이
     1:1 로 안 맞아 엉뚱한 칸이 늘어난다.
   ============================================================================ */
(function () {
  if (window.konetColResize) return;

  var LS = 'konetColW.';
  function lsGet(k) { try { return localStorage.getItem(LS + k); } catch (e) { return null; } }
  function lsSet(k, v) { try { localStorage.setItem(LS + k, v); } catch (e) { } }
  function lsDel(k) { try { localStorage.removeItem(LS + k); } catch (e) { } }

  /* 손잡이·얼린 표 CSS — 화면 CSS 를 안 건드리려고 여기서 한 번만 주입한다 */
  function injectCss() {
    if (document.getElementById('konetColrzCss')) return;
    var s = document.createElement('style');
    s.id = 'konetColrzCss';
    s.textContent =
      '.konet-colrz{position:absolute;top:0;right:0;width:8px;height:100%;cursor:col-resize;z-index:9;' +
      'user-select:none;-webkit-user-select:none;}' +
      '.konet-colrz:hover,.konet-colrz.on{background:rgba(19,122,108,.28);}' +
      /* 폭을 못 박은 뒤에는 좁힌 칸의 글자가 옆 칸으로 흘러넘치지 않게 …로 자른다 */
      'table.konet-colrz-on > thead > tr > th,table.konet-colrz-on > tbody > tr > td' +
      '{overflow:hidden;text-overflow:ellipsis;}' +
      /* ⚠화면 CSS 가 칸에 걸어 둔 min/max-width 를 푼다 — 안 풀면 그 칸만 안 줄어드는 브라우저가 있다
         (예: 상품코드등록의 규격 칸 min-width:300px). 폭은 colgroup 이 정한다. */
      'table.konet-colrz-on > thead > tr > th,table.konet-colrz-on > tbody > tr > td' +
      '{min-width:0!important;max-width:none!important;}' +
      'body.konet-colrzing{cursor:col-resize!important;user-select:none!important;}';
    (document.head || document.documentElement).appendChild(s);
  }

  /* 표의 <colgroup> — 남의 표(중첩 table)를 잡지 않게 직계 자식만 본다 */
  function ownColgroup(table) {
    for (var i = 0; i < table.children.length; i++) {
      if (table.children[i].tagName === 'COLGROUP') return table.children[i];
    }
    return null;
  }

  function bind(table, key) {
    if (!table || table.__colrz) return null;
    var head = table.tHead;
    if (!head || !head.rows.length) return null;
    var ths = head.rows[0].cells;
    var n = ths.length;
    if (n < 2) return null;
    for (var i = 0; i < n; i++) if (ths[i].colSpan > 1) return null;  /* 2줄 머리글은 지원 안 함 */

    injectCss();
    table.__colrz = true;

    /* 되돌릴 때 쓰려고 원래 inline 값을 들고 있는다 */
    var org = { tl: table.style.tableLayout, w: table.style.width, mw: table.style.minWidth };
    var cols = null;

    function applySum() {
      var sum = 0;
      for (var i = 0; i < cols.length; i++) sum += parseInt(cols[i].style.width, 10) || 0;
      table.style.width = '100%';
      table.style.minWidth = sum + 'px';
    }

    /* 지금 폭(또는 저장해 둔 폭)으로 표를 얼린다 */
    function freeze(ws) {
      if (!ws) {
        ws = [];
        for (var i = 0; i < n; i++) ws.push(Math.max(20, ths[i].offsetWidth));  /* offsetWidth = 배율 영향 없는 레이아웃 px */
      }
      var g = document.createElement('colgroup');
      for (var j = 0; j < n; j++) {
        var c = document.createElement('col');
        c.style.width = ws[j] + 'px';
        g.appendChild(c);
      }
      var old = ownColgroup(table);
      if (old) table.replaceChild(g, old); else table.insertBefore(g, table.firstChild);
      cols = g.children;
      table.style.tableLayout = 'fixed';
      table.classList.add('konet-colrz-on');
      applySum();
    }

    function save() {
      if (!cols || !key) return;
      var a = [];
      for (var i = 0; i < cols.length; i++) a.push(parseInt(cols[i].style.width, 10) || 0);
      lsSet(key, a.join(','));
    }

    function reset() {
      var old = ownColgroup(table);
      if (old) table.removeChild(old);
      cols = null;
      table.style.tableLayout = org.tl;
      table.style.width = org.w;
      table.style.minWidth = org.mw;
      table.classList.remove('konet-colrz-on');
      if (key) lsDel(key);
    }

    /* 저장해 둔 폭 되살리기 — 칸 수가 다르면(화면이 바뀐 것) 버린다 */
    if (key) {
      var raw = lsGet(key);
      if (raw) {
        var ws = raw.split(',').map(function (v) { return parseInt(v, 10); });
        if (ws.length === n && ws.every(function (v) { return v > 0; })) freeze(ws);
      }
    }

    /* 머리글마다 손잡이 */
    for (var k = 0; k < n; k++) {
      (function (th, idx) {
        if (getComputedStyle(th).position === 'static') th.style.position = 'relative';
        var h = document.createElement('span');
        h.className = 'konet-colrz';
        h.title = '끌어서 칸 폭 조절 (더블클릭 = 처음 폭으로)';
        th.appendChild(h);

        h.addEventListener('mousedown', function (e) {
          if (e.button !== 0) return;
          e.preventDefault(); e.stopPropagation();
          if (!cols) freeze();
          var sx = e.clientX, w0 = th.offsetWidth;
          h.classList.add('on');
          document.body.classList.add('konet-colrzing');
          function mv(ev) {
            cols[idx].style.width = Math.max(36, w0 + (ev.clientX - sx)) + 'px';
            applySum();
          }
          function up() {
            document.removeEventListener('mousemove', mv);
            document.removeEventListener('mouseup', up);
            h.classList.remove('on');
            document.body.classList.remove('konet-colrzing');
            save();
          }
          document.addEventListener('mousemove', mv);
          document.addEventListener('mouseup', up);
        });

        /* 더블클릭 = 이 표의 폭을 처음 상태로 (머리글 정렬 등 다른 동작은 막는다) */
        h.addEventListener('dblclick', function (e) { e.preventDefault(); e.stopPropagation(); reset(); });
        h.addEventListener('click', function (e) { e.stopPropagation(); });
      })(ths[k], k);
    }

    table.__colrzApi = { reset: reset, freeze: freeze };
    return table.__colrzApi;
  }

  /* 공개 API */
  window.konetColResize = function (table, key) {
    if (typeof table === 'string') table = document.querySelector(table);
    return bind(table, key || (table && table.getAttribute && table.getAttribute('data-colrz')) || '');
  };
  window.konetColResizeReset = function (key) {
    var t = document.querySelector('table[data-colrz="' + key + '"]');
    if (t && t.__colrzApi) { t.__colrzApi.reset(); return; }
    lsDel(key);   /* 아직 안 걸린 표라도 저장분은 지운다 */
  };
  /* 나중에 만들어진 표까지 한 번 더 훑고 싶을 때 */
  window.konetColResizeScan = function (root) {
    var list = (root || document).querySelectorAll('table[data-colrz]');
    for (var i = 0; i < list.length; i++) bind(list[i], list[i].getAttribute('data-colrz'));
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { window.konetColResizeScan(); });
  } else {
    window.konetColResizeScan();
  }
})();
