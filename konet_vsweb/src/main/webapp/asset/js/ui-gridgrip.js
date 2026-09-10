/* ─────────────────────────────────────────────────────────────────────────
   표 높이 막대 (2026-09-10 요청 「판매등록이든 매입등록이든 상단 상품그리드 아래로 늘리기 및 위로 축소기능」)

   거는 법 : <script src=".../asset/js/ui-gridgrip.js?v=20260910"> + konetGridGrip(표상자id, 막대를붙일자리id, 보관이름)
             예) konetGridGrip('saGridWrap', 'saFootWrap', 'salesReg') — 합계줄 밑에 막대가 생긴다.
   · 막대를 잡고 **아래로 끌면 표가 늘고, 위로 끌면 준다.** 오른쪽 [▲ 줄이기]·[▼ 늘리기] 는 한 번에 120px.
   · 막대 더블클릭 = 처음 높이(화면 CSS 값, 판매·매입 210px).
     ★화면에 원래 inline 으로 걸려 있던 높이(예: 수금·지급 원장 style="max-height:max(440px, 52vh)")는
       묶을 때 기억해 두었다가 **되살린다**(2026-09-10) — 그냥 지우면 그 표만 끝없이 길어진다.
   · 높이는 localStorage('konetGridH.<보관이름>') 에 남아 다음에 들어와도 그대로.
   · 범위 : 112px ~ 창 높이의 92%. 창이 작아지면 넘친 만큼 줄여 보여 준다(저장값은 그대로 둔다).
   ⚠종전 CSS 모서리 손잡이(resize:vertical)는 끈다 — 손잡이가 둘이면 어느 쪽 값이 남는지 헷갈린다.
   ⚠높이는 `!important` 인라인으로 건다 — 노트북용 CSS 등이 높이를 다시 잡아도 사용자가 고른 값이 이긴다.
   ⚠높이를 바꾼 뒤 표에 scroll 이벤트를 한 번 쏜다 — 판매·매입 명세는 «아래로 스크롤하면 이어서 그리기» 라
     표를 늘려 빈자리가 생겨도 스크롤이 안 일어나 다음 줄이 안 나온다(saGridBind/puGridBind 가 이 신호로 더 그린다).
   ───────────────────────────────────────────────────────────────────────── */
(function () {
  if (window.konetGridGrip) return;

  var MIN = 112, STEP = 120;
  var cssDone = false;
  function css() {
    if (cssDone) return; cssDone = true;
    var st = document.createElement('style');
    st.textContent =
        '.kgg{position:relative;height:16px;margin-top:3px;display:flex;align-items:center;justify-content:center;'
      +   'cursor:ns-resize;user-select:none;border-radius:6px;background:#f3f6f8}'
      + '.kgg:hover,.kgg.on{background:#dff0eb}'
      + '.kgg i{display:block;width:64px;height:4px;border-radius:2px;background:#b9c6d2;pointer-events:none}'
      + '.kgg:hover i,.kgg.on i{background:#137a6c}'
      + '.kgg .kgg-bt{position:absolute;right:4px;top:0;display:flex;gap:4px}'
      + '.kgg .kgg-bt b{height:16px;line-height:14px;padding:0 7px;font-size:11px;font-weight:700;color:#37475a;'
      +   'background:#fff;border:1px solid #cfd8e3;border-radius:4px;cursor:pointer;white-space:nowrap}'
      + '.kgg .kgg-bt b:hover{border-color:#137a6c;color:#137a6c}';
    (document.head || document.documentElement).appendChild(st);
  }
  function lsGet(k) { try { var v = localStorage.getItem(k); return v == null ? null : parseFloat(v); } catch (e) { return null; } }
  function lsSet(k, v) { try { if (v == null) localStorage.removeItem(k); else localStorage.setItem(k, String(v)); } catch (e) {} }

  function bind(gridId, afterId, key) {
    var g = document.getElementById(gridId), a = document.getElementById(afterId || gridId);
    if (!g || !a || g.getAttribute('data-kgg')) return;
    g.setAttribute('data-kgg', '1');
    css();
    var k = 'konetGridH.' + (key || gridId);

    var bar = document.createElement('div');
    bar.className = 'kgg';
    bar.title = '끌어서 표 높이 조절 — 아래로 = 늘리기 · 위로 = 줄이기 · 더블클릭 = 처음 높이';
    bar.innerHTML = '<i></i><span class="kgg-bt">'
      + '<b data-d="-1" title="표 높이 줄이기 (120px)">▲ 줄이기</b>'
      + '<b data-d="1" title="표 높이 늘리기 (120px)">▼ 늘리기</b></span>';
    a.parentNode.insertBefore(bar, a.nextSibling);

    g.style.resize = 'none';                              // 모서리 손잡이 대신 이 막대 하나로
    /* 원래 inline 높이 — 저장된 높이를 걸기 <전에> 잡아 둔다(더블클릭 때 되살린다) */
    var orig = { h: g.style.getPropertyValue('height'),     hp: g.style.getPropertyPriority('height'),
                 m: g.style.getPropertyValue('max-height'), mp: g.style.getPropertyPriority('max-height') };
    function back(prop, v, p) { if (v) g.style.setProperty(prop, v, p); else g.style.removeProperty(prop); }
    function maxH() { return Math.max(300, Math.round(window.innerHeight * 0.92)); }
    function curH() { return parseFloat(getComputedStyle(g).height) || g.offsetHeight || 210; }
    function setH(h) {
      h = Math.round(Math.min(maxH(), Math.max(MIN, h)));
      g.style.setProperty('height', h + 'px', 'important');
      g.style.setProperty('max-height', 'none', 'important');
      return h;
    }
    function kick() { try { g.dispatchEvent(new Event('scroll')); } catch (e) {} }

    var saved = lsGet(k);
    if (saved > 0) setH(saved);

    bar.addEventListener('mousedown', function (e) {
      if (e.button !== 0) return;
      if (e.target && e.target.closest && e.target.closest('b')) return;   // 단추는 제 일을 한다
      e.preventDefault();
      var sy = e.clientY, h0 = curH(), last = h0;
      bar.classList.add('on');
      document.body.style.cursor = 'ns-resize';
      function mv(ev) { last = setH(h0 + (ev.clientY - sy)); }
      function up() {
        document.removeEventListener('mousemove', mv);
        document.removeEventListener('mouseup', up);
        bar.classList.remove('on');
        document.body.style.cursor = '';
        lsSet(k, last); kick();
      }
      document.addEventListener('mousemove', mv);
      document.addEventListener('mouseup', up);
    });
    bar.addEventListener('click', function (e) {
      var b = e.target && e.target.closest && e.target.closest('b[data-d]'); if (!b) return;
      lsSet(k, setH(curH() + parseInt(b.getAttribute('data-d'), 10) * STEP)); kick();
    });
    bar.addEventListener('dblclick', function (e) {
      if (e.target && e.target.closest && e.target.closest('b')) return;
      back('height', orig.h, orig.hp); back('max-height', orig.m, orig.mp);   // 원래 모양 그대로(inline 값 포함)
      lsSet(k, null); kick();
    });
    window.addEventListener('resize', function () {
      var s = lsGet(k); if (s > 0) setH(s);                // 창이 작아지면 넘친 만큼만 줄여 보여 준다
    });
  }

  window.konetGridGrip = function (gridId, afterId, key) {
    if (document.readyState === 'loading')
      document.addEventListener('DOMContentLoaded', function () { bind(gridId, afterId, key); });
    else bind(gridId, afterId, key);
  };
})();
