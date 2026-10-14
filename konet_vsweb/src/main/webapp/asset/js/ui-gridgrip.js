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
   ★「아래 더 있음」 표시 (2026-10-14 사용자 「막대가 현재 위치에 있을 때 밑에도 있는데 없다고 전화 오는 경우 — 막대를 내리면 있는데 표시해 줘」)
     표 안에 아직 안 보이는 줄이 아래에 남아 있으면 막대 왼쪽에 주황색 「▼ 아래 N줄 더 있음 · 막대를 내리거나 표를 스크롤」을 띄운다.
     끝까지 보이면 사라진다. 누르면 [▼ 늘리기]와 같다. 줄 수는 tbody tr 가운데 표 아래 경계보다 아래에 있는 것(없으면 줄 수 없이 「더 있음」만).
     다시 세는 때 : 표 스크롤 · 높이 바꿈 · 창 크기 · 표 안 내용 바뀜(MutationObserver) — 40ms 타이머로 한 번에 모은다.
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
      + '.kgg .kgg-bt b:hover{border-color:#137a6c;color:#137a6c}'
      + '.kgg .kgg-more{position:absolute;left:6px;top:0;height:16px;line-height:14px;padding:0 8px;font-size:11px;font-weight:800;'
      +   'color:#9a4d00;background:#fff3dc;border:1px solid #e9b96a;border-radius:4px;cursor:pointer;white-space:nowrap}'
      + '.kgg .kgg-more:hover{background:#ffe8bf;border-color:#d99a2b}';
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
    /* 「아래 더 있음」 표시 — 안 보이는 줄이 남아 있을 때만 보인다(refreshMore) */
    var more = document.createElement('span');
    more.className = 'kgg-more'; more.style.display = 'none';
    more.title = '표 아래에 아직 안 보이는 줄이 있습니다 — 누르면 표가 늘어납니다. 막대를 아래로 끌거나 표 안을 스크롤해도 됩니다';
    bar.insertBefore(more, bar.firstChild);

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
      moreSoon();
      return h;
    }
    function kick() { try { g.dispatchEvent(new Event('scroll')); } catch (e) {} }
    function hiddenRows() {
      /* 보이는 아래 경계 = 표 위 + clientHeight (가로 스크롤 막대에 가려진 부분은 안 보이는 것).
         ★반쯤 걸친 줄도 «안 보이는 줄»로 센다 (2026-10-14 사용자 「3줄인데 2줄 있다고, 한 줄일 때는 숫자 없이」 — 종전엔 걸친 줄을 보이는 줄로 쳤다) */
      var gb = g.getBoundingClientRect(), vis = gb.top + g.clientHeight, rows = g.querySelectorAll('tbody tr'), n = 0;
      for (var i = rows.length - 1; i >= 0; i--) {              // 아래에서 위로 — 다 보이는 줄을 만나면 그친다
        var r = rows[i].getBoundingClientRect();
        if (r.height === 0) continue;
        if (r.bottom > vis + 1) n++; else break;
      }
      return n;
    }
    function refreshMore() {
      var over = g.scrollHeight - g.clientHeight - g.scrollTop;
      if (over <= 2 || g.offsetParent === null) { more.style.display = 'none'; return; }
      var n = hiddenRows();
      more.textContent = '▼ 아래 ' + (n ? n.toLocaleString() + '줄 ' : '') + '더 있음 · 막대를 내리거나 표를 스크롤';
      more.style.display = '';
    }
    var pend = false;
    function moreSoon() { if (pend) return; pend = true; setTimeout(function () { pend = false; refreshMore(); }, 40); }   // rAF 는 창이 가려지면 미뤄져 타이머로 (2026-10-14)

    var saved = lsGet(k);
    if (saved > 0) setH(saved);
    g.addEventListener('scroll', moreSoon);
    try { new MutationObserver(moreSoon).observe(g, { childList: true, subtree: true, attributes: true, attributeFilter: ['style', 'class'] }); } catch (e) {}
    more.addEventListener('click', function () { lsSet(k, setH(curH() + STEP)); kick(); });
    setTimeout(refreshMore, 0); window.addEventListener('load', moreSoon);

    bar.addEventListener('mousedown', function (e) {
      if (e.button !== 0) return;
      if (e.target && e.target.closest && e.target.closest('b,.kgg-more')) return;   // 단추·「더 있음」 표시는 제 일을 한다
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
      moreSoon();
    });
  }

  window.konetGridGrip = function (gridId, afterId, key) {
    if (document.readyState === 'loading')
      document.addEventListener('DOMContentLoaded', function () { bind(gridId, afterId, key); });
    else bind(gridId, afterId, key);
  };
})();
