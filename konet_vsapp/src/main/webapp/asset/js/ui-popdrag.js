/* ─────────────────────────────────────────────────────────────────────────
   팝업 창 끌어 옮기기 (2026-09-10 요청 「상품조회든 팝업으로 뜨는 내용 고정이 아니고 움직이게」)

   거는 법 : <script src=".../asset/js/ui-popdrag.js?v=20260910b"> 한 줄 + konetPopDrag('.sa-pop')
             — 팝업 뼈대가 「덮개(sel) > .box > .hd(제목줄)」 인 화면이면 그대로 걸린다(판매·매입등록).
             제목줄 이름이 다르면 둘째 인자로 : konetPopDrag('.pop', '.ph') — 발주서 관리(2026-09-10).
   · 끌어서 옮긴 직후의 click 한 번은 삼킨다 — 덮개 위에서 손을 떼면 click 이 덮개로 가서,
     「바깥 누르면 닫기」가 있는 화면이면 창이 닫혀 버린다.
   · 제목줄을 잡고 끌면 창(.box)이 옮겨진다. 제목줄 안 입력칸·단추·✕ 위에서는 끌지 않는다(평소대로 쓴다).
   · 옮긴 자리는 localStorage('konetPopPos.<덮개 id>') 에 남아 다음에 열어도 그 자리.
   · 제목줄 더블클릭 = 처음 자리(가운데)로.
   · 창을 다시 열 때 · 창 크기가 바뀌었을 때 제목줄이 화면 밖으로 나가 있으면 안으로 끌어온다
     (잡을 곳이 사라지면 닫기 단추도 못 누른다).
   ⚠자리 이동은 position:relative + left/top 이다 — .box 의 margin:auto 가운데 정렬은 그대로 두고
     그 자리에서 얼마나 비켜 섰는지만 적는다. 그래서 창 폭이 달라도 계산이 어긋나지 않는다.
   ⚠덮개(어두운 바탕)는 그대로다 — 창만 옮겨 아래 명세를 보면서 고를 수 있게 하는 것.
   ───────────────────────────────────────────────────────────────────────── */
(function () {
  if (window.konetPopDrag) return;

  var NO_DRAG = 'input,select,textarea,button,a,label,[onclick],[contenteditable]';
  var KEEP = 60;        // 옆으로 밀어도 이만큼(px)은 화면 안에 남긴다
  var HEAD = 36;        // 제목줄 높이만큼은 화면 안에 남긴다

  function lsGet(k) { try { return JSON.parse(localStorage.getItem(k) || 'null'); } catch (e) { return null; } }
  function lsSet(k, v) { try { if (v == null) localStorage.removeItem(k); else localStorage.setItem(k, JSON.stringify(v)); } catch (e) {} }
  function keyOf(pop) { return pop.id ? 'konetPopPos.' + pop.id : null; }

  /* 지금 left/top 에서 dx,dy 만큼 더 비켜 설 때, 화면 밖으로 나가지 않게 조인 값 */
  function clampTo(box, left, top) {
    var cl = parseFloat(box.style.left) || 0, ct = parseFloat(box.style.top) || 0;
    var r = box.getBoundingClientRect();
    var baseL = r.left - cl, baseT = r.top - ct;          // 비켜 서지 않았을 때의 자리
    var vw = window.innerWidth, vh = window.innerHeight;
    var minL = KEEP - r.width - baseL, maxL = vw - KEEP - baseL;
    var minT = -baseT, maxT = vh - HEAD - baseT;
    return { l: Math.round(Math.min(maxL, Math.max(minL, left))), t: Math.round(Math.min(maxT, Math.max(minT, top))) };
  }
  function place(box, l, t) {
    if (!l && !t) { box.style.position = ''; box.style.left = ''; box.style.top = ''; return; }
    box.style.position = 'relative'; box.style.left = l + 'px'; box.style.top = t + 'px';
  }
  /* 열 때·창 크기 바뀔 때 — 저장된 자리를 되살리고 화면 안으로 조인다 */
  function restore(pop) {
    var box = pop.querySelector(':scope > .box'); if (!box) return;
    var k = keyOf(pop), p = k ? lsGet(k) : null;
    if (p && (p.l || p.t)) { place(box, 0, 0); var c = clampTo(box, p.l, p.t); place(box, c.l, c.t); }
    else if (box.style.left || box.style.top) { var c2 = clampTo(box, parseFloat(box.style.left) || 0, parseFloat(box.style.top) || 0); place(box, c2.l, c2.t); }
  }

  /* 끌기가 끝난 직후의 click 한 번만 삼킨다(같은 사용자 동작 안에서 mouseup 바로 뒤에 온다 — 타이머보다 먼저) */
  function swallowNextClick() {
    function off() { document.removeEventListener('click', sw, true); }
    function sw(e) { e.stopPropagation(); e.preventDefault(); off(); }
    document.addEventListener('click', sw, true);
    setTimeout(off, 0);
  }

  function konetPopDrag(sel, hdSel) {
    hdSel = hdSel || '.hd';
    /* 제목줄에 「잡을 수 있다」 표시 — 입력칸·단추 위는 평소 커서 */
    var st = document.createElement('style');
    st.textContent = sel + ' > .box > ' + hdSel + '{cursor:move}'
      + sel + ' > .box > ' + hdSel + ' :is(' + NO_DRAG + '){cursor:auto}'
      + sel + ' > .box > ' + hdSel + ' :is(button,a,[onclick]){cursor:pointer}'
      + sel + ' > .box.kpd-mv{user-select:none}';
    (document.head || document.documentElement).appendChild(st);

    document.addEventListener('mousedown', function (e) {
      if (e.button !== 0) return;
      var t = e.target; if (!t || !t.closest) return;
      var hd = t.closest(hdSel); if (!hd) return;
      var box = hd.parentElement; if (!box || !box.classList.contains('box')) return;
      var pop = box.parentElement; if (!pop || !pop.matches(sel)) return;
      if (t.closest(NO_DRAG)) return;                     // 입력칸·단추는 제 일을 한다
      e.preventDefault();
      var sx = e.clientX, sy = e.clientY;
      var l0 = parseFloat(box.style.left) || 0, t0 = parseFloat(box.style.top) || 0;
      box.classList.add('kpd-mv');
      var moved = false;
      function mv(ev) {
        if (!moved && Math.abs(ev.clientX - sx) + Math.abs(ev.clientY - sy) > 3) moved = true;
        var c = clampTo(box, l0 + (ev.clientX - sx), t0 + (ev.clientY - sy));
        place(box, c.l, c.t);
      }
      function up() {
        document.removeEventListener('mousemove', mv);
        document.removeEventListener('mouseup', up);
        box.classList.remove('kpd-mv');
        if (!moved) return;                               // 제목줄을 그냥 누른 것 — 자리도 click 도 건드리지 않는다
        swallowNextClick();
        var k = keyOf(pop);
        if (k) lsSet(k, { l: parseFloat(box.style.left) || 0, t: parseFloat(box.style.top) || 0 });
      }
      document.addEventListener('mousemove', mv);
      document.addEventListener('mouseup', up);
    });

    /* 제목줄 더블클릭 = 처음 자리 */
    document.addEventListener('dblclick', function (e) {
      var t = e.target; if (!t || !t.closest || t.closest(NO_DRAG)) return;
      var hd = t.closest(hdSel); if (!hd) return;
      var box = hd.parentElement; if (!box || !box.classList.contains('box')) return;
      var pop = box.parentElement; if (!pop || !pop.matches(sel)) return;
      place(box, 0, 0); var k = keyOf(pop); if (k) lsSet(k, null);
    });

    /* 열릴 때(class 에 on 이 붙을 때) 자리를 되살린다 — 여는 함수들은 손대지 않는다 */
    function watch() {
      var pops = document.querySelectorAll(sel);
      var mo = new MutationObserver(function (list) {
        list.forEach(function (m) { if (m.target.classList.contains('on')) restore(m.target); });
      });
      pops.forEach(function (p) { mo.observe(p, { attributes: true, attributeFilter: ['class'] }); });
      window.addEventListener('resize', function () {
        pops.forEach(function (p) { if (p.classList.contains('on')) restore(p); });
      });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', watch); else watch();
  }
  window.konetPopDrag = konetPopDrag;
})();
