/* ==========================================================================
   글자 축소 · 확대 — 2026-08-21 요청
     「공통적으로 자주쓰는메뉴 위치 우측에 글자 축소, 확대 기능 구현」

   두는 자리 : 상단 <자주 쓰는 메뉴>(#favBar) 줄 **맨 오른쪽** — [가−][100%][가+]
               어느 화면을 열어도 늘 같은 자리다(그 줄이 sticky 라 스크롤해도 따라온다).
   보관      : localStorage(브라우저별). 다음에 들어와도 그 크기 그대로.
   되돌리기  : 가운데 [100%] 를 누르면 기본으로.

   ★★여기서 말하는 「100%」는 <브라우저 기본 크기>가 아니라 <이 앱의 기본 크기>다 (2026-08-21).
     사용자 실측 「지금 90% 해야 한눈에 들어옴 — 100% 를 한눈에 들어오게」 ⇒ 아래 BASE 참고.

   ★왜 font-size 가 아니라 zoom 인가
     이 앱의 CSS 는 글자·칸 높이·표 폭이 전부 **px 로 박혀** 있다. 글자만 키우면
     32px 짜리 단추 안에서 글자가 두 줄이 되고 표 칸이 터진다(=사용자가 지적한 바로 그 현상).
     zoom 은 글자·칸·표를 **같은 비율로** 키워 배치가 그대로 유지된다(Ctrl + 와 같은 방식).

   ★iframe 화면(판매·매입·수금·지급 등록, 원장, 그래프 …)
     이 앱의 업무화면은 대부분 셸 안 iframe 이다. 브라우저에 따라 부모의 zoom 이
     iframe 안까지 저절로 전해지기도(Chrome) 하고 아니기도 한다.
     ⇒ **재 보고 판단한다** : iframe 의 실제 폭과 그 안 window.innerWidth 를 비교해
       이미 전해졌으면 그냥 두고, 안 전해졌으면 그 문서에 직접 건다. 두 번 걸려 두 배가 되는 일이 없다.

   ★★배율은 **본문 내용(.logi-main .panel)에만** 건다 — 셸 뼈대(좌측 메뉴·상단 줄·본문 스크롤 상자)는 그대로 둔다.
     처음 판처럼 문서 전체(`<html>`)에 걸면 `height:100vh`·`position:sticky` 로 짜인 셸이 함께 끌려가
     **그리드가 좌측 메뉴 위로 넘어가고, 메뉴 끝이 올라간다**(2026-08-21 대시보드에서 실제로 났다).
     자세한 근거는 아래 zoomTargets/applyZoom 주석.
   ========================================================================== */
(function(){
  'use strict';

  /* ★보관 키 판을 올렸다(konetUiZoom → 2) — 아래 BASE 가 생기면서 **저장된 숫자의 뜻이 바뀌었다.**
       옛 값 90 을 그대로 읽으면 90×0.9=81% 가 되어 시험해 본 브라우저만 더 작아진다. 옛 값은 버린다. */
  var KEY   = 'konetUiZoom4';   // ★BASE 가 바뀔 때마다 판을 올린다(아래 BASE 주석) — 옛 저장값은 버린다
  /* ★축소 쪽을 50% 까지 넓혔다 (2026-08-21 「기본 100% 는 한눈에 안 들어온다 — 작게 해야 들어온다」).
       처음 판은 80% 가 바닥이라 ***목록이 긴 화면이 한 화면에 안 담겼다.***
       50·60·70 은 글자가 작지만 <전체를 훑는> 용도라 필요하다 — 읽을 때는 다시 올리면 된다. */
  var STEPS = [50, 60, 70, 80, 90, 100, 110, 120, 130, 140];
  var DEF   = 100;

  /* ★★기준 배율 — 화면에 거는 **실제 배율 = 고른 값 × BASE**. 1 이면 브라우저 그대로(원래 크기).
       [이력] 2026-08-21 하루에 세 번 옮겼다. 그 과정이 곧 근거다 :
         ① 1   : 원래 크기. → 「한눈에 안 들어온다」
         ② 0.9 : 작게. → 「기본 100% 가 너무 작음」 (다 담기 ↔ 크게 읽기는 같이 안 된다)
         ③ 1   : 되돌림. ***그 사이에 여백·표 줄높이를 줄여(konet-ui-fix.css §3) 같은 자리에 줄이 더 들어오게 했다.***
         ④ 1.2  : 여백·줄높이를 줄인 뒤(§③ 밀도) 「120% 를 100% 로」 확정.
         ⑤ **0.96** : 1.2 를 며칠 써 보고 **「80% 크기가 맞다 — 이걸 100% 으로」**(2026-08-21 저녁,
              대시보드 실화면 캡처로 확정. 0.8×1.2=0.96). ***지금 값.***
       ⇒ 첫 진입(=100%) = 실제 0.96(원래 크기보다 4% 작게). [가＋] 로 110%(=1.056)·120%(=1.152)…
       ⚠이 값을 또 건드리면 **저장된 숫자의 뜻이 함께 바뀐다** — 그때는 위 KEY 판도 반드시 같이 올릴 것
         (1.2→0.96 때도 konetUiZoom3→4 로 올렸다). */
  var BASE  = 0.96;
  function zoomOf(p){ return (p / 100) * BASE; }

  function load(){
    var v = 0;
    try{ v = parseInt(localStorage.getItem(KEY), 10); }catch(e){}
    return (STEPS.indexOf(v) >= 0) ? v : DEF;
  }
  function save(p){ try{ localStorage.setItem(KEY, String(p)); }catch(e){} }

  var cur = load();

  /* ── ★★배율을 <어디에> 거는가 (2026-08-21 두 번째 판) ───────────────────
       처음에는 문서 전체(`<html>`)에 걸었다. 그러면 **셸의 뼈대까지 같이 커진다** —
       이 셸은 `height:100vh` 로 화면에 딱 맞춰 잘려 있고(`.logi-wrap`·`.logi-side`),
       좌측 메뉴는 `position:sticky`, 본문은 `overflow:auto` 다. 그 셋이 배율에 함께 끌려가면서
       실제로 두 가지가 깨졌다(사용자 지적, 대시보드) :
         ① 그리드를 스크롤하면 **표가 좌측 메뉴 위로 넘어간다**
         ② **메뉴 끝(아래)이 올라간다** — 사이드바가 화면 높이에 안 맞는다
       ⇒ **셸 뼈대(좌측 메뉴 · 상단 자주 쓰는 메뉴 줄 · 본문 스크롤 상자)는 건드리지 않는다.**
         배율은 <본문 내용>인 `.logi-main .panel` 에만 건다. 화면 하나하나가 곧 panel 이고,
         iframe 업무화면도 그 안에 있다 — ***보이는 내용은 다 커지고, 틀은 그대로다.***
       ※ 셸이 아닌 단독 문서(화면을 따로 연 경우)는 `<body>` 에 건다 — 거긴 100vh 틀이 없다.  */
  /* ★★iframe 화면 패널은 <상자(panel)를 키우지 않는다> (2026-08-21 세 번째 판) —
       iframe 은 height:calc(100vh - 70px) 로 화면에 딱 맞게 잘려 있는데, 그 상자를 배율로 키우면
       **상자째 배율만큼 길어져**(1.2 면 화면보다 20% — 판매등록 실측 144px) 본문 끝에
       내용 없는 빈 스크롤이 생긴다(2026-08-21 「이런현상」 — 오른쪽 긴 스크롤바).
       iframe 화면의 <내용> 배율은 fixFrames 가 그 문서 안에 직접 건다 — 상자는 그대로,
       안쪽만 커져서 안에서 스크롤된다(브라우저 Ctrl+ 와 같은 감각). */
  function zoomTargets(){
    var ps = document.querySelectorAll('.logi-main .panel'), out = [], i;
    for (i=0;i<ps.length;i++){
      if (!ps[i].querySelector(':scope > iframe')) out.push(ps[i]);
    }
    if (ps.length) return out;
    return document.body ? [document.body] : [];
  }
  function applyZoom(f){
    /* 먼저 모든 panel 의 배율을 지운다 — 앞 판이 iframe 패널에 걸어 둔 값이 남아 있으면
       상자가 계속 큰 채로 남는다(스크립트만 바꿔서는 안 지워진다). */
    var all = document.querySelectorAll('.logi-main .panel');
    for (var k=0;k<all.length;k++) all[k].style.zoom = '';
    var t = zoomTargets();
    for (var i=0;i<t.length;i++) t[i].style.zoom = (f === 1) ? '' : f;
    /* ★--kz = 지금 패널에 걸린 배율 (2026-08-28 「재고현황도 글자 축소시 하단 빈공간」) —
       인라인 패널의 vh 높이는 zoom 과 무관하게 실제 화면 기준으로 계산된 뒤 zoom 배로 <줄어들어>
       축소 시 표가 짧아지고 아래가 빈다(iframe 화면과 같은 뿌리, 그쪽은 상자 역보정으로 해결).
       인라인 쪽은 CSS 가 `calc(74vh / var(--kz,1))` 처럼 나눠서 되살린다 — demo2 의 --kz 주석 참고. */
    document.documentElement.style.setProperty('--kz', String(f));
    /* 종전 판이 `<html>`·`.logi-wrap`·`.logi-side` 에 남겨 둔 값을 지운다 —
       한 번이라도 옛 스크립트가 돈 창에서는 이게 남아 있으면 두 배로 걸린다. */
    document.documentElement.style.zoom = '';
    var w = document.querySelector('.logi-wrap'), s = document.querySelector('.logi-side');
    if (w) w.style.height = '';
    if (s) s.style.height = '';
  }

  /* ── iframe 화면에 배율이 전해졌는지 재 보고, 모자라면 직접 건다 ────────
     ⚠★[2026-08-21 실측 수정] 종전 식은 <내가 건 zoom 만큼 innerWidth 가 줄어든다>고 가정하고
       내 몫(mine)을 나눠 보정했는데, **Chrome 은 안쪽 zoom 이 innerWidth 를 안 바꾼다** —
       그래서 부를 때마다 need 가 f 배씩 불어나는 **폭주**가 된다(1.2→1.44→1.73→… 실측).
       지금까지 티가 안 났던 것은 패널 zoom 이 전파돼 need=1 로만 떨어졌기 때문이다(잠복).
       ⇒ **재기 전에 내 몫을 걷어내고 잰다** — 그러면 innerWidth 를 바꾸는 엔진이든
       안 바꾸는 엔진이든 같은 값이 나온다(멱등 · 폭주 불가).
     ★★[2026-08-28 네 번째 판] <문서 안> zoom → <iframe 상자> zoom + 상자 역보정 —
       「글자 축소하면 하단 빈공간 생김」(80% 스크린샷, 출고현황표).
       ⚠원인 : 업무화면(demo1 등)은 `.d2-wrap{height:100vh}` 처럼 **화면 높이에 딱 맞춘** 레이아웃인데,
         zoom 을 <문서 안(html)>에 걸면 100vh 는 상자 높이 그대로 계산되고 렌더만 0.768배로 줄어
         **상자 아래 (1−배율)만큼 흰 빈공간**이 남는다(축소). 확대(1.2) 때 안쪽 스크롤이 생기던 것도 같은 뿌리.
       ⇒ zoom 을 **iframe 상자에** 걸고 상자 CSS 크기를 역수로 키운다(잰값/need, 폭·높이 모두 px)
         — 렌더 크기 = 원래 상자 그대로, 대신 **안쪽 뷰포트가 실제로 커져** 100vh 가 상자를 정확히 채운다
         (브라우저 Ctrl± 와 같은 원리). 재현 페이지 실측(2026-08-28) : 80%·100%·120% 모두 빈공간 0 ·
         5회 재호출 안정 · 안쪽 innerWidth = 상자CSS폭(=원래폭/need) 정확.
       ⚠원래 inline 크기(width:100%·height:calc(100vh - 70px))는 style 속성에 있어 그냥 지우면 없어진다
         → 처음 만질 때 __kzOrig 에 담아 두고, 잴 때마다 그 값으로 되돌린 뒤 잰다(멱등).
       ⚠★폭도 %가 아니라 **px** — zoom 이 걸린 상자의 %폭은 부모 폭을 <자기 zoom 좌표계>로 다시 재서
         (100/need)% 로 주면 **이중 보정**되어 상자가 가로로 넘친다(재현 실측 : 0.768 에서 30% 초과).
         px 은 그 좌표계 그대로라 정확하다. 창 크기가 바뀌면 resize/클릭 재기가 다시 재서 다시 박는다. */
  function fixFrames(f){
    var frames = document.getElementsByTagName('iframe');
    for (var i=0;i<frames.length;i++){
      var fr = frames[i], w, d;
      try{
        w = fr.contentWindow; d = fr.contentDocument;
        if (!w || !d || !d.documentElement) continue;          // 아직 안 뜬 iframe
        /* ★★[2026-09-04 속도] 손대기 전에 <먼저 본다> — 숨은 화면·크기 안 바뀐 화면은 건드리지 않는다.
             종전엔 매 클릭(150ms·700ms 두 번)마다 모든 iframe 의 zoom·width·height 를 떼었다 도로 걸었다.
             iframe 의 zoom 이 바뀌면 그 안 문서 전체가 스타일을 다시 계산한다 — 월별 출고현황(셀 3만)이
             display:none 으로 숨어 있어도 그 문서는 살아 있어 클릭마다 몇 번씩 통째로 다시 계산했고,
             보이는 동안은 크기까지 바뀌어 3만 셀 레이아웃이 클릭마다 여러 번 돌았다(「다른 메뉴 이동 시 잔상·엄청 느림」).
             ① 상자(panel)가 안 보이면(폭 0) 아무 것도 안 쓴다 — 나타날 때 클릭 재기가 다시 잰다.
             ② 배율(f)·상자 크기·창 크기가 지난번과 같으면 이미 맞는 값이라 건너뛴다(강제 레이아웃 0). */
        var pb = (fr.parentElement || fr).getBoundingClientRect();
        if (!pb.width || !pb.height) continue;
        var key = f + '|' + Math.round(pb.width) + 'x' + Math.round(pb.height) + '|' + window.innerWidth + 'x' + window.innerHeight;
        if (fr.__kzKey === key) continue;
        fr.__kzKey = key;
        d.documentElement.style.zoom = '';                     // 옛 판(문서 안 zoom) 잔재는 늘 걷어낸다
        if (fr.__kzOrig === undefined)
          fr.__kzOrig = { z: fr.style.zoom || '', w: fr.style.width || '', h: fr.style.height || '' };
        fr.style.removeProperty('zoom');                        // 잰다 — 내 몫(!important 포함)을 걷어낸 맨눈으로
        fr.style.removeProperty('width');
        fr.style.removeProperty('height');
        fr.style.zoom = fr.__kzOrig.z;                          // 원래 inline 값 복원
        fr.style.width = fr.__kzOrig.w;
        fr.style.height = fr.__kzOrig.h;
        var box = fr.getBoundingClientRect();                   // 화면에 보이는 실제 크기
        var inn = w.innerWidth;                                 // 그 문서가 생각하는 폭(스크롤바 포함 = box 와 같은 기준)
        if (!box.width || !inn) continue;                       // 숨은 화면(폭 0) — 나타날 때 클릭 재기가 다시 잰다
        var fromUp = box.width / inn;                           // 부모(패널 zoom 등)에서 전해져 온 몫
        var need   = f / (fromUp || 1);
        if (Math.abs(need - 1) < 0.02) continue;                // 재는 값 오차 흡수 — 원래 크기 그대로 둔다
        /* ★역보정은 **inline !important** 로 건다(2026-08-28 「글자 축소시 아래 빈공간」 재신고) —
           셸 CSS 에 `body.konet-asqbar-on #if-shipstatus2{height:… !important}`(알림바 가림 방지)가 있어
           보통 inline 은 진다 → 높이 역보정이 무시돼 안쪽 뷰포트가 안 커지고 빈공간이 그대로 남았다.
           inline !important 는 스타일시트 !important 를 이긴다. 알림바가 뜨고 내릴 때는 아래
           body class 감시가 다시 재서 다시 박는다(원래 CSS 값으로 잰 뒤 거는 것이라 가림도 안 생긴다). */
        fr.style.setProperty('zoom',   String(need), 'important');
        fr.style.setProperty('width',  (box.width  / need) + 'px', 'important');   // %금지 — 위 주석
        fr.style.setProperty('height', (box.height / need) + 'px', 'important');
      }catch(e){}                                              // 다른 출처 iframe 등 — 조용히 지나간다
    }
  }

  function apply(p, remember){
    cur = p;
    var f = zoomOf(p);
    applyZoom(f);
    fixFrames(f);
    paint();
    if (remember) save(p);
    /* 배율이 바뀌면 JS 가 화면 px 로 재서 박아 둔 표 높이(lzFit·_stkLedFit 등)도 다시 잡혀야 한다 —
       그 함수들은 전부 resize 에 물려 있으므로 resize 를 한 번 쏜다(2026-08-28). fixFrames 도
       resize 를 받지만 멱등이라 무해하다. */
    try{ window.dispatchEvent(new Event('resize')); }catch(e){}
  }

  /* ── 단추 그리기 ──────────────────────────────────────────────────────── */
  function paint(){
    var v = document.getElementById('fzVal');
    if (!v) return;
    v.textContent = cur + '%';
    v.classList.toggle('off', cur !== DEF);
    v.title = (cur === DEF) ? '기본 크기입니다' : '누르면 기본(100%)으로 되돌립니다';
    var i = STEPS.indexOf(cur);
    document.getElementById('fzMinus').disabled = (i <= 0);
    document.getElementById('fzPlus').disabled  = (i >= STEPS.length - 1);
  }

  function step(d){
    var i = STEPS.indexOf(cur) + d;
    if (i < 0 || i >= STEPS.length) return;
    apply(STEPS[i], true);
  }

  function build(){
    var bar = document.getElementById('favBar');
    if (!bar || document.getElementById('favZoom')) return false;
    var box = document.createElement('span');
    box.id = 'favZoom';
    box.title = '화면 글자 크기 — 표·단추가 함께 커지고 작아집니다';
    box.innerHTML =
        '<button type="button" id="fzMinus" title="글자 축소">가－</button>'
      + '<button type="button" id="fzVal"   title="기본(100%)으로">100%</button>'
      + '<button type="button" id="fzPlus"  title="글자 확대">가＋</button>';
    /* ★자리 (2026-08-21 요청 「확대 축소 위치 그대로, 비우기를 메뉴 마지막 옆으로」)
           [메뉴 접기] ⭐자주 쓰는 메뉴 [칩][칩][칩] [✕ 비우기] ……… [가－][100%][가＋]
         · 축소·확대 = 줄 **맨 오른쪽**(margin-left:auto 로 민다 — konet-ui-fix.css)
         · [✕ 비우기] = **마지막 칩 바로 옆**(#favList 다음). 종전에는 저 혼자 오른쪽 끝에 떨어져 있어
           무엇을 비우는 단추인지 칩과 멀었다. 셸의 margin-left:auto 는 konet-ui-fix.css 가 덮는다. */
    bar.appendChild(box);
    var clr = document.getElementById('favClearBtn'),
        lst = document.getElementById('favList');
    if (clr && lst && lst.nextSibling !== clr) bar.insertBefore(clr, lst.nextSibling);
    document.getElementById('fzMinus').onclick = function(){ step(-1); };
    document.getElementById('fzPlus' ).onclick = function(){ step( 1); };
    document.getElementById('fzVal'  ).onclick = function(){ apply(DEF, true); };
    return true;
  }

  function init(){
    build();
    apply(cur, false);
    /* 새로 뜨는 iframe(메뉴를 처음 열 때 로드된다)에도 같은 배율을 물려준다 */
    var frames = document.getElementsByTagName('iframe');
    for (var i=0;i<frames.length;i++){
      (function(fr){
        if (fr.__kzHooked) return;
        fr.__kzHooked = 1;
        fr.addEventListener('load', function(){ fr.__kzKey = null; setTimeout(function(){ fixFrames(zoomOf(cur)); }, 60); });   // 새 문서 = 건너뛰기 캐시 무효
      })(frames[i]);
    }
  }

  /* 창 크기가 바뀌면 셸 높이를 다시 잡는다 */
  /* 창 크기가 바뀌면 iframe 폭이 달라지므로 배율 전달 여부를 다시 잰다
     (셸 뼈대는 이제 손대지 않으니 높이 보정은 필요 없다) */
  window.addEventListener('resize', function(){ fixFrames(zoomOf(cur)); });

  /* ★body 클래스가 바뀌면 iframe 의 <자연> 크기가 클릭 없이 변할 수 있다 —
       예: 하단 알림바(konet-asqbar-on)가 저절로 떠서 #if-shipstatus2 높이를 CSS 로 줄이는 경우.
       역보정을 inline !important 로 걸기 때문에, 다시 재 주지 않으면 옛 크기가 그대로 남는다.
       ⇒ body class 변화를 감시해 잠깐 뒤 다시 잰다(재기 자체가 원래 CSS 값으로 되돌린 뒤 재는 구조라 안전). */
  if (window.MutationObserver){
    var _kzMoT = null;
    var _kzMo = new MutationObserver(function(){
      clearTimeout(_kzMoT);
      /* body class 로 iframe 의 CSS 높이만 바뀌는 경우는 상자(panel) 크기가 그대로라 위 건너뛰기 캐시에 걸린다 → 캐시를 비우고 잰다 */
      _kzMoT = setTimeout(function(){
        var fs = document.getElementsByTagName('iframe'); for (var i=0;i<fs.length;i++) fs[i].__kzKey = null;
        fixFrames(zoomOf(cur)); }, 120);
    });
    if (document.body) _kzMo.observe(document.body, { attributes:true, attributeFilter:['class'] });
    else document.addEventListener('DOMContentLoaded', function(){
      _kzMo.observe(document.body, { attributes:true, attributeFilter:['class'] });
    });
  }

  /* ★숨어 있던 화면(panel)이 나타나는 순간을 잡는다.
       숨은 iframe 은 폭이 0 이라 위 재기(fixFrames)를 건너뛴다 — 그대로 두면
       메뉴를 눌러 그 화면이 처음 나타났을 때만 배율이 안 맞는다.
       화면이 바뀌는 계기는 메뉴 클릭뿐이므로, 클릭 뒤 두 번만 다시 맞춘다(비용 거의 없다). */
  document.addEventListener('click', function(){
    /* ⚠기본(100%)일 때도 건너뛰면 안 된다 — 기준 배율(BASE)이 1 이 아니라 늘 걸어야 한다 */
    setTimeout(function(){ fixFrames(zoomOf(cur)); }, 150);
    setTimeout(function(){ fixFrames(zoomOf(cur)); }, 700);
  }, true);

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
  /* 메뉴를 눌러 iframe 이 뒤늦게 로드되는 경우까지 — 몇 번 더 훑는다(비용이 거의 없다) */
  setTimeout(function(){ init(); }, 400);
  setTimeout(function(){ init(); }, 1500);

  /* 다른 스크립트에서도 쓸 수 있게 (예: 새 화면을 연 뒤 강제 재적용) */
  window.konetZoomApply = function(p){ apply(p, true); };
  window.konetZoomSync  = function(){ fixFrames(zoomOf(cur)); };
})();
