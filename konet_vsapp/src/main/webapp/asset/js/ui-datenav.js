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

   ★기간칸(시작 ~ 종료)은 **달력 하나**로 고른다 (2026-08-28 요청 「달력이 두 개 떠서 — from to 를 한 번에」).
     짝은 이름 규칙(xxFrom/xxTo)으로 저절로 찾는다 — 자세한 것은 아래 pairOf 주석.

   쓰는 법 : 이 파일만 넣으면 그 화면의 모든 날짜 칸에 저절로 붙는다(화면 수정 0).
             빼려면 그 칸에  data-nonav="1" · 기간으로 안 묶으려면  data-norange="1"
   ============================================================================= */
(function () {
  'use strict';
  if (window.__uiDateNav) return;
  window.__uiDateNav = true;

  var CSS =
    /* 기본 달력 아이콘을 감춘다 — 이걸 눌러야 브라우저 달력이 뜨므로, 감추면 우리 것만 뜬다 */
    'input[type=date].udn-on::-webkit-calendar-picker-indicator{ display:none; -webkit-appearance:none; }' +
    /* ★[2026-08-20 「달력이 없습니다」] 기본 아이콘을 감추면 **누를 수 있는 칸인지 알 수가 없다** —
       화면에 따라 옆에 달력 그림이 따로 있는 곳도, 없는 곳도 있어 사용자가 "이 화면엔 달력이 없다"고 읽었다.
       ⇒ 감춘 자리에 **우리 달력 아이콘**을 그려 넣는다. 모든 날짜 칸이 같은 모습이 된다(화면 수정 0). */
    'input[type=date].udn-on{ cursor:pointer; background-repeat:no-repeat;' +
    /* ★padding-right 는 !important (2026-08-28) — 아이콘이 <날짜 글자 위에 겹치는> 것을 막는 자리다.
         화면들이 날짜칸에 style="padding:0 8px" 처럼 인라인으로 padding 을 주는데(8곳 실측),
         인라인이 이겨 이 자리가 사라지면 아이콘이 '2026-01-01' 마지막 글자를 덮는다. */
    '  background-position:right 7px center; background-size:15px 15px; padding-right:26px !important;' +
    '  background-image:url("data:image/svg+xml;charset=utf-8,' +
    "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2348606f' stroke-width='2' stroke-linecap='round'%3E%3Crect x='3' y='5' width='18' height='16' rx='2'/%3E%3Cpath d='M8 3v4M16 3v4M3 10h18'/%3E%3C/svg%3E" +
    '"); }' +
    /* ── 우리 달력 ──
       ★z-index 는 **가장 위**로 (2026-08-20) — 화면마다 모달·상단바가 9998~100001 을 쓰고 있어
         9999 로는 그 아래에 깔려 **열렸는데 안 보이는** 일이 생긴다. 달력은 언제나 맨 위여야 한다. */
    '.udnCal{ position:absolute; z-index:2147483000; background:#fff; border:1px solid #cfd9e0; border-radius:10px;' +
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
    '  border-radius:6px; cursor:pointer; font-size:12px; font-weight:700; }' +
    /* ── 기간(from ~ to) 모드 — 2026-08-28 ──
       머리에 [① 시작][② 종료] 를 두어 <지금 무엇을 고르는 중인지> 보이게 한다(눌러서 되돌아갈 수도 있다).
       사이 날짜는 옅게 칠해 고른 기간이 한눈에 보이게. */
    /* ★두 달을 나란히 (2026-08-28 「기간이 달이 다를 경우·년이 다를 경우 두 개 달력이 떠야 함」)
       한 달만 보이면 8월→9월 기간을 고를 때 ‹ › 로 달을 넘겨야 해서 오히려 불편했다. */
    '.udnCal.rg{ width:auto; }' +
    '.udnCal .ms{ display:flex; gap:12px; align-items:flex-start; }' +
    /* ★좌우 달력은 <각자> 년·월을 옮긴다 (2026-08-28 요청) — 한 벌로 묶어 두면
       「8월 ~ 11월」처럼 떨어진 기간을 고를 때 오른쪽을 못 맞춘다. 그래서 머리줄을 판마다 둔다. */
    '.udnCal .mo{ width:240px; }' +
    '.udnCal.rg .hd{ gap:2px; }' +
    '.udnCal.rg .hd button{ width:22px; height:22px; font-size:12px; }' +
    /* 달 이름은 단추다 — 누르면 그 달 통째로(1일~말일). 평소엔 제목처럼 보이게 테두리를 감춘다. */
    '.udnCal button.mtt{ flex:1; height:22px; padding:0 2px; border:1px solid transparent !important;' +
    '  background:none; border-radius:6px; cursor:pointer; font-size:13px; font-weight:800; color:#1f2a37;' +
    '  white-space:nowrap; width:auto; }' +
    '.udnCal button.mtt:hover{ background:#eaf5f3; border-color:#a9d5cd !important; color:#137a6c; }' +
    '.udnCal .rgh{ display:flex; align-items:center; gap:5px; margin:0 0 6px; }' +
    '.udnCal .rgh button.stp{ flex:1; height:26px; padding:0 6px; border:1px solid #d7e3e0 !important; background:#fff;' +
    '  border-radius:6px; cursor:pointer; font-size:11.5px; font-weight:700; color:#5a6b76; white-space:nowrap; }' +
    '.udnCal .rgh button.stp.on{ background:#137a6c; border-color:#137a6c !important; color:#fff; }' +
    '.udnCal .rgh .tl{ color:#9aa7b3; font-size:12px; }' +
    '.udnCal td button.in{ background:#e3f2ef; border-radius:0; }' +
    '.udnCal .ft button + button{ margin-left:6px; }';

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
      nativeShowPicker = orig;                   // 대비용으로 원본을 들고 있는다
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

  /* 값만 넣고 change 는 나중에 — 기간모드에서 <두 칸을 다 채운 뒤> 한꺼번에 알리려고 나눠 두었다.
     이렇게 안 하면 시작일을 고른 순간 (새 시작 > 옛 종료) 인 뒤집힌 기간으로 조회가 한 번 돈다. */
  function fireChange(el) {
    try { el.dispatchEvent(new Event('change', { bubbles: true })); }
    catch (e) { var ev = document.createEvent('HTMLEvents'); ev.initEvent('change', true, false); el.dispatchEvent(ev); }
  }

  /* ── 기간(from ~ to) 을 달력 하나에서 — 2026-08-28 요청 「달력이 두 개 떠서, from to 를 한 번에」 ──
       종전 : 시작칸·종료칸이 각자 달력을 띄웠다. 기간 하나 고르려고 달력을 두 번 열고,
              중간에 뒤집힌 기간(새 시작 > 옛 종료)으로 조회가 한 번 돌았다.
       지금 : 짝이 있는 칸이면 달력 하나가 ① 시작 → ② 종료 를 이어서 받고, 닫힐 때 두 값이 함께 들어간다.
       ★짝 찾기는 <이름 규칙> — 이 파일의 원칙이 '화면 수정 0' 이라 마크업에 손대지 않는다.
         이 앱은 예외 없이 xxFrom / xxTo 로 쓴다(d2DateFrom·ssDateTo·svFrom·outFr·hTo …).
         규칙 밖이면 칸에 data-range-to="상대칸id"(또는 data-range-from) 를 주면 된다.
         짝으로 묶지 않으려면 data-norange="1". 짝을 못 찾으면 종전대로 한 칸짜리 달력. */
  var FROM_SUF = ['From', 'from', 'FROM', 'Fr', 'fr', '_from', '_fr', 'Start', 'start'];
  var TO_SUF   = ['To', 'to', 'TO', 'End', 'end', '_to', '_end'];
  /** 짝으로 쓸 수 있는 칸인가 — 숨은 칸·읽기전용 칸은 묶지 않는다(값만 몰래 바뀌면 안 된다) */
  function usable(el) {
    return !!el && el.tagName === 'INPUT' && el.type === 'date' && !el.readOnly && !el.disabled
        && el.getAttribute('data-nonav') !== '1' && el.getClientRects().length > 0;
  }
  function byId(id) { try { return id ? document.getElementById(id) : null; } catch (e) { return null; } }
  function mate(id, sufs, others) {
    for (var i = 0; i < sufs.length; i++) {
      var s = sufs[i];
      if (id.length > s.length && id.slice(-s.length) === s) {
        var pre = id.slice(0, id.length - s.length);
        for (var j = 0; j < others.length; j++) { var m = byId(pre + others[j]); if (usable(m)) return m; }
      }
    }
    return null;
  }
  function pairOf(el) {
    if (!el || el.getAttribute('data-norange') === '1') return null;
    var t = byId(el.getAttribute('data-range-to'));   if (usable(t)) return { from: el, to: t, role: 'from' };
    var f = byId(el.getAttribute('data-range-from')); if (usable(f)) return { from: f, to: el, role: 'to' };
    var id = el.id || ''; if (!id) return null;
    var m = mate(id, FROM_SUF, TO_SUF); if (m) return { from: el, to: m, role: 'from' };
    m = mate(id, TO_SUF, FROM_SUF);     if (m) return { from: m, to: el, role: 'to' };
    return null;
  }

  /* ── 우리 달력 ──────────────────────────────────────────────────────────── */
  var cal = null, calFor = null, calYm = null;   // calYm = 보고 있는 달(그 달 1일)
  var calYm2 = null;   // 기간모드 오른쪽 판이 보고 있는 달 — 왼쪽(calYm)과 <따로> 움직인다(2026-08-28 요청)
  var rg = null;   // 기간모드 상태 {from, to, f, t, step(0=시작 고르는 중, 1=종료)} · null 이면 한 칸짜리
  /* ★[2026-08-20] 연 시각 — 여는 **그 순간의 스크롤로 스스로 닫히는 것**을 막는다(아래 scroll 처리 참고) */
  var calAt = 0;
  var nativeShowPicker = null;                   // 브라우저 기본 달력(우리 것이 못 뜰 때의 대비)

  /* 기간모드 : 고른 값을 실제 칸에 넣고, 화면의 <조회를 한 번> 돌린다
     (2026-08-28 요청 「대시보드 조회 버튼 실행해 조회되게」).
     ★두 값을 다 넣은 뒤에 change 를 쏜다 — 화면의 조회는 두 칸을 함께 읽으므로,
       중간에 쏘면 뒤집힌 기간(새 시작 > 옛 종료)으로 한 번 더 돈다.
     ★change 는 <반드시 한 번> 쏜다. 두 가지를 여기서 잡는다 —
       ① 바뀐 칸마다 쏘면 두 칸 다 바뀐 보통의 경우 조회가 2번 돈다(DB 왕복 2회).
       ② 반대로 <같은 기간을 다시 골랐을 때>는 바뀐 게 없어 조회가 아예 안 돌았다
          — 사용자에겐 "달력에서 골랐는데 아무 일도 안 일어난다"로 보인다.
     쏘는 칸 : 인라인 onchange 가 걸린 칸(이 앱은 시작·종료가 같은 조회 함수를 부른다) 중 종료칸 우선.
              양쪽 다 없으면(조회를 [조회] 단추로만 하는 화면) 양쪽에 알린다 — 어차피 자동조회가 없다. */
  function rgApply(r) {
    if (!r) return;
    if (r.f) r.from.value = r.f;
    if (r.t) r.to.value = r.t;
    var tgt = (r.t && r.to.getAttribute('onchange')) ? r.to
            : (r.f && r.from.getAttribute('onchange')) ? r.from : null;
    if (tgt) { fireChange(tgt); return; }
    if (r.f) fireChange(r.from);
    if (r.t && r.to !== r.from) fireChange(r.to);
  }
  function calClose() {
    /* ★먼저 rg 를 비우고 적용한다 — change 로 화면이 다시 그려지며 이 함수가 또 불려도 두 번 들어가지 않게 */
    var r = rg; rg = null;
    rgApply(r);
    if (cal && cal.parentNode) cal.parentNode.removeChild(cal);
    cal = null; calFor = null;
  }
  /* 기간모드에서 날짜 하나를 골랐을 때 */
  /* ★시작을 새로 고르면 <두 판을 그 달로> 맞춘다 (2026-08-28 요청 「from to 같은달로」).
     열 때는 왼쪽=시작의 달, 오른쪽=종료의 달이지만, 시작을 다시 고르면 옛 종료의 달은 대개 쓸모가 없다.
     기간이 여러 달이면 오른쪽 판을 ‹ › 로 옮기면 된다(좌우는 따로 움직인다). */
  function rgSameMonth(v) {
    var d = parse(v); if (!d) return;
    calYm  = new Date(d.getFullYear(), d.getMonth(), 1);
    calYm2 = new Date(d.getFullYear(), d.getMonth(), 1);
  }
  function rgPick(v) {
    if (rg.step === 0) {                       // ① 시작 — 창을 닫지 않고 ② 종료로 넘어간다
      rg.f = v;
      if (rg.t && rg.t < v) rg.t = v;          // 시작이 종료보다 뒤면 종료를 끌어 올린다
      rgSameMonth(v);
      rg.step = 1; calDraw(); return;
    }
    if (v < rg.f) { rg.f = v; rgSameMonth(v); calDraw(); return; }   // 종료를 시작보다 앞으로 고르면 '새 시작'으로 읽는다
    rg.t = v; calClose();                      // 닫으면서 두 값이 함께 들어간다
  }
  /* 한 달치 표 하나 — 기간모드는 이것을 <두 개 나란히> 놓는다(2026-08-28 요청).
     제목(2026년 8월)은 단추다 — 누르면 그 달 통째로(1일~말일)가 기간이 된다. */
  function monthPane(y, m, sel, tod, pane) {
    var first = new Date(y, m, 1), cur = new Date(y, m, 1 - first.getDay());
    var mk = y + '-' + ('0' + (m + 1)).slice(-2);
    var h = '<div class="mo">';
    if (rg) {   /* 판마다 제 머리줄 — «‹ [달이름] ›» . 좌우가 서로 상관없이 움직인다. */
      h += '<div class="hd">'
         + '<button type="button" data-mv="-12" data-pane="' + pane + '" title="1년 앞으로">&laquo;</button>'
         + '<button type="button" data-mv="-1"  data-pane="' + pane + '" title="한 달 앞으로">&lsaquo;</button>'
         + '<button type="button" class="mtt" data-mon="' + mk + '" title="이 달 전체(1일~말일)를 기간으로">' + y + '년 ' + (m + 1) + '월</button>'
         + '<button type="button" data-mv="1"   data-pane="' + pane + '" title="한 달 뒤로">&rsaquo;</button>'
         + '<button type="button" data-mv="12"  data-pane="' + pane + '" title="1년 뒤로">&raquo;</button>'
         + '</div>';
    }
    h += '<table><thead><tr>';
    var W = ['일','월','화','수','목','금','토'];
    for (var w = 0; w < 7; w++) {
      h += '<th' + (w === 0 ? ' style="color:#c0392b"' : w === 6 ? ' style="color:#1f6fb2"' : '') + '>' + W[w] + '</th>';
    }
    h += '</tr></thead><tbody>';
    for (var r = 0; r < 6; r++) {
      h += '<tr>';
      for (var c = 0; c < 7; c++) {
        var cls = [], v = ymd(cur);
        if (cur.getMonth() !== m) cls.push('out');
        else if (c === 0) cls.push('sun'); else if (c === 6) cls.push('sat');
        if (v === ymd(tod)) cls.push('today');
        if (rg) {                                   // 기간모드 — 양끝은 진하게, 사이는 옅게
          if ((rg.f && v === rg.f) || (rg.t && v === rg.t)) cls.push('on');
          else if (rg.f && rg.t && v > rg.f && v < rg.t) cls.push('in');
        }
        else if (sel && v === ymd(sel)) cls.push('on');
        h += '<td><button type="button" class="' + cls.join(' ') + '" data-d="' + v + '">' + cur.getDate() + '</button></td>';
        cur.setDate(cur.getDate() + 1);
      }
      h += '</tr>';
      if (cur.getMonth() !== m && r >= 4) break;      // 다 그렸으면 빈 줄을 더 만들지 않는다
    }
    return h + '</tbody></table></div>';
  }
  function calDraw() {
    if (!cal) return;
    var y = calYm.getFullYear(), m = calYm.getMonth();
    var sel = parse(calFor.value), tod = new Date();
    var h = '';
    if (rg) {   /* ① 시작 / ② 종료 — 지금 무엇을 고르는 중인지 보이고, 눌러서 되돌아갈 수도 있다 */
      h += '<div class="rgh">'
         + '<button type="button" class="stp' + (rg.step === 0 ? ' on' : '') + '" data-step="0">① 시작 ' + (rg.f || '—') + '</button>'
         + '<span class="tl">~</span>'
         + '<button type="button" class="stp' + (rg.step === 1 ? ' on' : '') + '" data-step="1">② 종료 ' + (rg.t || '—') + '</button>'
         + '</div>';
    }
    /* ★월 이동은 `‹ ›`(좌우) — 월별로 고르는 일이 많아 이것이 가장 자주 눌린다.
       `« »` 는 1년. 위/아래 화살표를 쓰지 않는 이유가 여기 있다(앞/뒤가 안 읽힌다).
       ★기간모드에서는 머리줄이 <판마다> 있다(2026-08-28 요청 「좌우 달력 년월 조절 따로」) —
         한 벌로 묶여 있으면 8월 ~ 11월 처럼 떨어진 기간에서 오른쪽 달을 맞출 수가 없었다. */
    if (rg) {
      h += '<div class="ms">' + monthPane(y, m, sel, tod, 0)
         + monthPane(calYm2.getFullYear(), calYm2.getMonth(), sel, tod, 1) + '</div>';
    } else {
      h += '<div class="hd">'
          + '<button type="button" data-mv="-12" title="1년 앞으로">&laquo;</button>'
          + '<button type="button" data-mv="-1"  title="한 달 앞으로">&lsaquo;</button>'
          + '<span class="t">' + y + '년 ' + (m + 1) + '월</span>'
          + '<button type="button" data-mv="1"   title="한 달 뒤로">&rsaquo;</button>'
          + '<button type="button" data-mv="12"  title="1년 뒤로">&raquo;</button>'
          + '</div>'
          + monthPane(y, m, sel, tod, 0);
    }
    /* ⚠[지우기] 는 두지 않는다(사용자 지시) — 날짜를 비우는 것은 대개 실수다 */
    h += '<div class="ft"><button type="button" data-today="1">오늘</button></div>';
    cal.innerHTML = h;
  }
  function calOpen(el) {
    if (calFor === el && cal) return;               // 같은 칸이면 그대로 둔다
    calClose();
    calFor = el;
    /* 짝(from~to)이 있으면 기간모드로 연다. 시작칸을 눌렀으면 ① 부터, 종료칸을 눌렀으면 ② 부터. */
    var _p = pairOf(el);
    rg = _p ? { from: _p.from, to: _p.to, f: _p.from.value || '', t: _p.to.value || '',
                step: (_p.role === 'from' ? 0 : 1) } : null;
    var base = parse(el.value) || new Date();
    calYm = new Date(base.getFullYear(), base.getMonth(), 1);
    calYm2 = null;
    if (rg) {
      /* 왼쪽 = 시작의 달, 오른쪽 = 종료의 달. 두 값이 같은 달이면 오른쪽은 그 다음 달.
         (좌우는 열린 뒤 각자 옮길 수 있다 — 2026-08-28 요청) */
      var _bf = parse(rg.f) || parse(rg.t) || new Date();
      calYm = new Date(_bf.getFullYear(), _bf.getMonth(), 1);
      var _bt = parse(rg.t);
      calYm2 = (_bt && (_bt.getFullYear() !== calYm.getFullYear() || _bt.getMonth() !== calYm.getMonth()))
             ? new Date(_bt.getFullYear(), _bt.getMonth(), 1)
             : new Date(calYm.getFullYear(), calYm.getMonth() + 1, 1);
      /* 종료가 시작보다 앞이면(뒤집힌 값) 오른쪽은 그냥 다음 달 */
      if (calYm2 < calYm) calYm2 = new Date(calYm.getFullYear(), calYm.getMonth() + 1, 1);
    }
    cal = document.createElement('div');
    cal.className = 'udnCal' + (rg ? ' rg' : '');
    document.body.appendChild(cal);
    calDraw();
    /* 칸 아래에 놓고, 아래가 좁으면 위로 올린다 */
    var r = el.getBoundingClientRect(), sx = window.pageXOffset, sy = window.pageYOffset;
    var top = r.bottom + sy + 4;
    if (r.bottom + cal.offsetHeight + 8 > window.innerHeight) top = r.top + sy - cal.offsetHeight - 4;
    var left = Math.min(r.left + sx, sx + window.innerWidth - cal.offsetWidth - 8);
    cal.style.top = Math.max(sy + 4, top) + 'px';
    cal.style.left = Math.max(sx + 4, left) + 'px';

    calAt = +new Date();     /* ★여는 순간을 적어 둔다 — 바로 뒤따라오는 스크롤로 스스로 닫히지 않게 */

    /* ★[2026-08-20] **안전망** — 우리 달력이 화면에 못 나오면(가려짐·크기 0)
       칸을 눌러도 아무 일도 안 일어난 것처럼 보인다("달력이 없습니다" 신고).
       그때는 **브라우저 기본 달력**이라도 띄운다.
       ⚠`el.showPicker()` 를 부르면 안 된다 — 그건 위에서 **우리 달력으로 갈아 끼운 것**이라 제자리걸음이다.
         반드시 들고 있던 **원본**을 부른다. */
    if (!cal.offsetWidth || !cal.offsetHeight) {
      calClose();
      try { if (nativeShowPicker) nativeShowPicker.call(el); } catch (_) {}
    }

    /* 달력을 눌러도 칸의 focus 를 잃지 않게 — 잃으면 blur 로 닫히며 클릭이 씹힌다 */
    cal.addEventListener('mousedown', function (e) { e.preventDefault(); });
    cal.addEventListener('click', function (e) {
      var b = e.target;
      if (!b || b.tagName !== 'BUTTON') return;
      var mv = b.getAttribute('data-mv');
      if (mv) {   // ★달을 옮길 때는 창을 닫지 않는다 — 훑어 보다가 고른다
        if (rg && b.getAttribute('data-pane') === '1') {          // 오른쪽 판만 움직인다
          calYm2 = new Date(calYm2.getFullYear(), calYm2.getMonth() + Number(mv), 1);
        } else {                                                  // 왼쪽 판(또는 한 칸짜리 달력)
          calYm = new Date(calYm.getFullYear(), calYm.getMonth() + Number(mv), 1);
        }
        calDraw(); return;
      }
      var st = b.getAttribute('data-step');
      if (rg && st) { rg.step = Number(st); calDraw(); return; }        // ①/② 를 눌러 되돌아가기
      var mo = b.getAttribute('data-mon');                              // 달 제목을 누르면 그 달 통째로(1일~말일)
      if (rg && mo) {
        var _y = Number(mo.slice(0, 4)), _m = Number(mo.slice(5, 7)) - 1;
        rg.f = ymd(new Date(_y, _m, 1));
        rg.t = ymd(new Date(_y, _m + 1, 0));
        calClose(); return;
      }
      if (b.getAttribute('data-today')) {
        if (rg) { rgPick(ymd(new Date())); return; }
        setVal(calFor, ymd(new Date())); calClose(); return;
      }
      var v = b.getAttribute('data-d');
      if (v) { if (rg) rgPick(v); else { setVal(calFor, v); calClose(); } }
    });
  }
  /* 바깥을 누르면 닫는다 — 칸 자신과 달력 안은 뺀다 */
  document.addEventListener('mousedown', function (e) {
    if (!cal) return;
    if (cal.contains(e.target) || e.target === calFor) return;
    calClose();
  }, true);
  /* 스크롤하면 닫는다 — 달력은 칸 옆에 절대좌표로 놓이므로 화면이 움직이면 자리가 어긋난다.
     ★★[2026-08-20 「클릭하면 달력 실행 안 됨」의 진짜 원인] **여는 그 순간의 스크롤은 무시한다.**
       칸을 누르면 `el.focus()` 가 도는데, 그 칸이 스크롤되는 영역 안에 있으면 브라우저가
       칸을 보이게 하려고 **살짝 스크롤**한다. 그 scroll 이 곧바로 이 처리를 깨워
       ***방금 연 달력을 즉시 닫아*** 「눌러도 아무 일도 안 일어난다」로 보였다.
       (물류관리 셸처럼 본문이 스크롤되는 화면에서만 나타나, 화면마다 되고 안 되고가 갈렸다.)
       ⇒ 연 지 0.4초 안의 스크롤은 흘려보낸다. 사람이 손으로 굴리는 스크롤은 그 뒤라 그대로 닫힌다. */
  window.addEventListener('scroll', function () {
    if (cal && (+new Date()) - calAt < 400) return;
    calClose();
  }, true);
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
