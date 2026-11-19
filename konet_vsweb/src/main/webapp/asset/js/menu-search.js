/* ─────────────────────────────────────────────────────────────────────────
   메뉴 검색 (2026-11-19 사용자 「상단에 검색 기능 넣고 — 해당 검색 메뉴 내용 보여 주고 간단한 설명 주고, 해당 메뉴 클릭하면 들어가게」)

   자리   : 상단 <자주 쓰는 메뉴>(#favBar) 줄 오른쪽 — 글자 크기 [가－][100%][가＋] 바로 앞.
   쓰는 법 : 칸에 메뉴 이름·하는 일을 적으면(예 「반품」「재고」「견적」「ㅈㄱ」) 걸리는 메뉴가 아래에 뜬다.
             줄마다 [아이콘 메뉴이름  ▸ 묶음 경로] + 한 줄 설명. 누르거나 ↑↓ + Enter 로 그 화면에 들어간다. Esc = 닫기 · Ctrl+K = 검색 칸으로.
             빈 칸으로 누르면 전체 메뉴가 묶음 차례대로 나온다(메뉴 지도).
   자료   : 메뉴 목록은 <왼쪽 사이드바에 실제로 있는 메뉴>(a.mi)를 그때그때 읽는다 — 권한으로 가려진 메뉴는 사이드바에 없으므로 검색에도 안 나온다.
             메뉴가 늘어도 이 파일을 고칠 필요가 없다(설명만 없을 뿐). 설명은 ①아래 DESC 표 ②메뉴의 title ③업무 설명서 표(td.m) 차례로 찾는다.
   들어가기 : 접힌 묶음을 펼친 뒤 그 메뉴의 click 을 그대로 부른다 — 자주 쓰는 메뉴(favRun)와 같은 길이라 화면 여는 방법이 두 벌이 되지 않는다.
   초성    : 「ㅈㄱ」 처럼 초성만 적어도 이름의 초성과 맞춰 찾는다.
   ⚠이 화면(logistics_demo2.jsp)은 JSP 메서드 크기 한도(65535)에 가깝다 — 스크립트·마크업은 여기 파일에 두고 JSP 에는 <script src> 한 줄만 넣었다.
   ───────────────────────────────────────────────────────────────────────── */
(function () {
  if (window.konetMenuSearch) return;
  window.konetMenuSearch = true;

  /* 설명 · 찾는 말(이름에 없는 다른 말) — 이름은 사이드바 글자 그대로(공백 포함) */
  var DESC = {
    '납기현황표(대시보드)': ['발주현황표 엑셀을 올려 출고장·사업장·품목별 납기(출고) 수량을 작성하고 봅니다', '출고현황표 발주현황표 업로드 대시보드 출고'],
    '납기세부조회': ['저장된 납기(출고)를 출고장▸품목 · 사업장별 · 품목별로 바꿔 가며 조회합니다', '출고세부조회 출고 조회'],
    '납기현황이력조회': ['발주현황표를 올리고 고친 이력을 조회합니다', '출고이력 업로드 이력'],
    '택배납기관리': ['직송(택배) 건을 택배 발송 엑셀로 내보내고 주소·운임을 관리합니다', '택배 직송 송장 운임'],
    '매출내역': ['출고·정산서·판매전표 기준 매출을 일자·거래처·품목별로 조회합니다', '매출 조회 정산'],
    '정산실적': ['정산서 원본을 일자별·품목별로 펼쳐 봅니다', '정산서'],
    '매출 반품내역': ['판매 반품(음수 수량 판매) 내역을 조회합니다', '반품 판매반품'],
    'DC 발주 등록': ['DC 상품의 SRM 발주(입고예약서·발주서)를 등록합니다', '입고예약서 SRM'],
    '토더 발주 등록': ['토더 「상품별 발주 목록」 엑셀을 올려 출고·매출로 등록합니다', '토더 TD 거래처 발주'],
    '대상 발주 등록': ['대상 배송요청 표를 등록합니다(배송 처리용 — 매출은 판매전표)', '대상 배송요청 거래처 발주'],
    '동원홈푸드 등록': ['동원홈푸드 직송발주 엑셀을 올려 출고·매출로 등록합니다', '동원 직송발주 거래처 발주'],
    '판매 등록': ['판매전표를 등록·수정합니다 — 정산서 가져오기 · 거래명세서 출력', '판매전표 거래명세서 매출 전표'],
    '수금 등록': ['거래처에서 받은 돈(수금) 전표를 등록합니다', '입금 수금 받을돈'],
    '거래처 매출장·마감': ['거래처별 매출장과 마감 유형별 매출원장을 출력합니다', '매출장 매출원장'],
    '매출마감': ['월 매출을 마감합니다(출고 × 납기일자 단가 → 매출·매입·이익)', '마감 월마감'],
    '매출 그래프': ['월별·일자별 매출을 그래프로 봅니다', '차트'],
    '정산 그래프': ['정산서와 직접판매를 일자별·월별 그래프로 봅니다', '차트 정산서'],
    '매입 등록': ['매입전표를 등록·수정합니다(입고·재고 반영) — 반품은 음수 수량', '입고 매입전표 반품'],
    '발주서 관리': ['발주서를 작성·공유하고 들어온 만큼 매입으로 전환합니다 — 추천 발주', '발주 PO 매입전환 카톡'],
    '거래처별 매입가 비교': ['같은 품목을 매입처마다 얼마에 샀는지 비교합니다', '단가 비교 매입처'],
    '지급 등록': ['매입처에 준 돈(지급) 전표를 등록합니다', '출금 지급 줄돈'],
    '입고내역': ['매입 입고 내역을 공급가·부가세·합계로 조회합니다', '입고 매입 부가세'],
    '매입 반품내역': ['매입 반품(음수 수량 입고) 내역을 조회합니다', '반품 매입반품'],
    '매입마감': ['월 매입을 마감합니다', '마감 월마감'],
    '품목별재고현황': ['품목별 입고·반품·출고·현재고와 그 근거(수불 내역)를 봅니다', '재고 현재고 수불 입출고'],
    '재고흐름조회': ['재고 흐름이 이상한 품목을 찾습니다 — 현재고 음수 · 입고 없이 출고 · 과거 음수 · 조정 잦음 · 장기 무출고', '재고 흐름 이상 음수 마이너스 무출고 점검 수불'],
    '월별 출고현황': ['품목별 월별 출고량과 입·출고 상세를 봅니다', '출고 월별'],
    '재고마감': ['월 재고를 마감합니다(기초·입고·출고·기말)', '마감 월마감 재고'],
    '비용 등록': ['월 비용(지출)을 등록합니다 — 종합 실적·마감현황에 반영', '지출 경비 비용'],
    '원가 관리': ['품목 원가(이동평균단가·매입가)를 관리합니다', '원가 단가'],
    '재고 일괄조정': ['실사한 재고로 한꺼번에 조정합니다 — 직원은 승인 요청, 관리자가 승인 · 조정 이력', '재고조정 실사 승인 요청 조정이력'],
    '서브코드 재고 정리': ['서브코드에 남은 재고를 주코드로 옮겨 정리합니다', '서브코드 주코드 재고'],
    '품목코드(매핑)': ['주코드와 매칭코드(거래처 코드)의 연결을 점검합니다', '매칭코드 매핑 xref 코드'],
    '직원 공지사항': ['직원 공지를 쓰고 읽습니다 — 읽은 사람 수 표시 · 하단 흐름 띠', '공지'],
    '직원 메신저': ['직원끼리 메시지를 주고받습니다', '메시지 쪽지 채팅'],
    '직원 업무일지': ['하루 업무를 적고 봅니다', '업무일지 일지'],
    '직원 휴가 관리': ['휴가를 신청·승인하고 연도별 연차 부여·사용·잔여를 봅니다', '연차 월차 반차 휴가'],
    '진행 현황': ['발주(등록·발주서·매입전환)와 견적(등록·제출·채택·판매) 진행 상황을 봅니다', '발주 견적 진행'],
    '종합 실적': ['기간·하루의 매출·수금·매입·지급·지출을 한 장에 — 사원별 현황(총괄관리자)', '실적 기간계 일계 사원별'],
    '마감현황(월계표)': ['월 매출·매입·비용·순이익을 한 표로 봅니다', '월계표 마감 순이익'],
    '월별 마감이력': ['월별 마감을 언제 누가 했는지 봅니다', '마감 이력'],
    '거래처별 이익': ['거래처별 매출·원가·이익을 봅니다', '이익 마진'],
    '상품별 이익': ['상품별 매출·원가·이익을 봅니다', '이익 마진 품목'],
    '거래처별 상품별 이익': ['거래처 안에서 상품별 이익을 봅니다', '이익 마진'],
    '일계장': ['하루의 매출·매입·수금·지급 전표를 한 장에 봅니다', '일계 전표 일람'],
    '거래처별 채권·채무': ['거래처 잔액(미수·미지급)과 원장, 미수 경과를 봅니다', '미수금 미지급 잔액 외상 원장'],
    '상품코드등록': ['상품 코드·입수·단가·거래중지·적정재고를 등록합니다', '품목 등록 상품 코드 입수'],
    '상품(품목)관리': ['상품 마스터를 조회·수정하고 수불 내역·재고 조정을 봅니다', '품목 상품 마스터'],
    '매입/매출 거래처': ['매입처·매출처를 등록합니다(담당자·결제 조건)', '거래처 매입처 매출처'],
    '거래처관리(사업장)': ['사업장(납품처)을 등록합니다 — 택배 주소·운임', '사업장 납품처 주소'],
    '거래처 통합(수금 묶음)': ['여러 거래처를 하나의 수금 단위로 묶습니다', '수금 묶음 통합'],
    '회사 정보 수정': ['회사 이름·사업자번호·주소·도장 등 기본 정보를 고칩니다', '회사 사업자'],
    '회사/사용자 관리': ['회사와 사용자(직원 계정·권한)를 관리합니다', '계정 사용자 권한 비밀번호'],
    '공통코드 관리': ['화면에서 쓰는 공통 코드를 관리합니다', '코드'],
    '견적서 목록': ['견적서를 조회하고 상태(제출·채택)·인쇄·엑셀·카톡 공유·계산조회를 합니다', '견적 인쇄 채택'],
    '견적서 작성': ['견적서를 작성합니다 — 원가·마진 계산(엑셀형 한 표) · 동판·목형 · MOQ', '견적 원가 마진 MOQ 동판 목형'],
    '업무 설명서': ['메뉴별 업무 설명을 봅니다', '도움말 매뉴얼 설명'],
    '창고 / 로케이션': ['창고와 로케이션(위치)을 봅니다 (예정·데모)', '창고 위치'],
    '입고등록 (창고선정)': ['입고할 창고·위치를 고릅니다 (예정·데모)', '입고 창고'],
    '창고 관리': ['창고를 등록·관리합니다', '창고'],
    '창고별 재고현황': ['창고별 재고를 봅니다', '창고 재고'],
    '재고 / 위치 조회': ['품목이 어느 위치에 있는지 봅니다 (예정·데모)', '위치 재고'],
    '출고지시 (위치→출고)': ['위치에서 출고를 지시합니다 (예정·데모)', '출고지시']
  };

  var CHO = ['ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
  function esc(s) { return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
  function norm(s) { return String(s || '').toLowerCase().replace(/[\s·\/()\-_,.]/g, ''); }
  function cho(s) { var o = ''; s = String(s || ''); for (var i = 0; i < s.length; i++) { var c = s.charCodeAt(i); if (c >= 0xAC00 && c <= 0xD7A3) o += CHO[Math.floor((c - 0xAC00) / 588)]; else if (!/\s/.test(s.charAt(i))) o += s.charAt(i).toLowerCase(); } return o; }
  function isCho(s) { return /^[ㄱ-ㅎ]+$/.test(s); }
  function label(a) { var s = ''; for (var i = 0; i < a.childNodes.length; i++) { var c = a.childNodes[i]; if (c.nodeType === 3) s += c.nodeValue; } return s.replace(/\s+/g, ' ').trim(); }

  /* 업무 설명서 표에서 설명 한 줄 (이름이 같은 줄의 둘째 칸 첫 문장) */
  var _manual = null;
  function manualOf(nm) {
    if (_manual === null) { _manual = {};
      var tds = document.querySelectorAll('td.m');
      for (var i = 0; i < tds.length; i++) { var k = norm(tds[i].textContent.replace(/[^\w가-힣()·\/ ]/g, '')), d = tds[i].nextElementSibling;
        if (k && d) { var t = d.textContent.replace(/\s+/g, ' ').trim(); if (t.length > 90) t = t.slice(0, 88) + '…'; _manual[k] = t; } } }
    return _manual[norm(nm)] || '';
  }

  /* 사이드바에서 메뉴 읽기 — 묶음(.grp)·펼침메뉴(.has-sub) 경로까지 */
  function build() {
    var out = [], side = document.querySelector('nav.logi-side') || document.querySelector('.logi-side'); if (!side) return out;
    var as = side.querySelectorAll('a.mi');
    for (var i = 0; i < as.length; i++) {
      var a = as[i];
      if (a.classList.contains('has-sub') || a.getAttribute('data-nofav') || !a.getAttribute('onclick')) continue;
      if (a.style.display === 'none') continue;
      var nm = label(a); if (!nm || nm === '로그아웃') continue;
      var path = [], top = a, sub = a.closest('.sub-menu');
      while (sub) { var head = sub.previousElementSibling; if (head && head.classList.contains('has-sub')) { path.unshift(label(head)); top = head; } sub = sub.parentElement ? sub.parentElement.closest('.sub-menu') : null; }
      var g = top.previousElementSibling; while (g && !(g.classList && g.classList.contains('grp'))) g = g.previousElementSibling;
      var grp = g ? g.textContent.replace(/[★☆]/g, '').trim() : '';
      if (grp && path[0] !== grp && norm(path[0] || '') !== norm(grp)) path.unshift(grp);
      var ic = a.querySelector('.ic'), d = DESC[nm] || null;
      var desc = d ? d[0] : (a.getAttribute('title') || manualOf(nm) || '');
      var key = d ? d[1] : '';
      out.push({ a: a, nm: nm, ic: ic ? ic.textContent : '•', path: path, desc: desc,
                 n: norm(nm), c: cho(nm), p: norm(path.join(' ')), d: norm(desc + ' ' + key) });
    }
    return out;
  }

  /* 점수 — 이름 앞머리 > 이름 안 > 초성 > 경로 > 설명·찾는 말. 낱말 여러 개면 전부 걸려야 한다 */
  function score(m, toks) {
    var s = 0;
    for (var i = 0; i < toks.length; i++) { var t = toks[i], v = 0;
      if (m.n.indexOf(t) === 0) v = 100; else if (m.n.indexOf(t) > 0) v = 80;
      else if (isCho(t) && m.c.indexOf(t) >= 0) v = (m.c.indexOf(t) === 0 ? 70 : 60);
      else if (m.p.indexOf(t) >= 0) v = 40; else if (m.d.indexOf(t) >= 0) v = 25;
      if (!v) return 0; s += v; }
    return s;
  }
  function mark(nm, toks) {   /* 이름 안의 맞은 글자를 굵게 */
    var h = esc(nm);
    toks.forEach(function (t) { if (isCho(t) || !t) return; var re; try { re = new RegExp('(' + t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').split('').join('\\s*') + ')', 'i'); } catch (e) { return; } h = h.replace(re, '<mark>$1</mark>'); });
    return h;
  }

  var box, inp, pop, list = [], cur = -1, items = null;

  function css() {
    var st = document.createElement('style');
    st.textContent =
        '#menuSearch{position:relative;margin-left:auto;display:inline-flex;align-items:center}'
      + '#menuSearch input{width:290px;height:34px;border:1px solid #cfd8e3;border-radius:18px;padding:0 14px 0 34px;font-size:14px;background:#f7faf9;outline:none;transition:width .15s,border-color .15s}'
      + '#menuSearch input:focus{width:380px;border-color:#137a6c;background:#fff;box-shadow:0 0 0 3px rgba(19,122,108,.12)}'
      + '#menuSearch .ms-ic{position:absolute;left:12px;top:50%;transform:translateY(-50%);font-size:14px;pointer-events:none;opacity:.7}'
      + '#menuSearchPop{display:none;position:absolute;right:0;top:40px;width:min(520px,92vw);max-height:min(70vh,560px);overflow:auto;background:#fff;border:1px solid #cfd8e3;border-radius:10px;box-shadow:0 10px 30px rgba(31,42,55,.18);z-index:500;padding:4px 0}'
      + '#menuSearchPop.on{display:block}'
      + '#menuSearchPop .ms-it{display:flex;gap:10px;padding:7px 12px;cursor:pointer;border-left:3px solid transparent}'
      + '#menuSearchPop .ms-it.on,#menuSearchPop .ms-it:hover{background:#eaf5f2;border-left-color:#137a6c}'
      + '#menuSearchPop .ms-it .i{flex:0 0 22px;text-align:center;font-size:15px;line-height:20px}'
      + '#menuSearchPop .ms-it .t{min-width:0;flex:1}'
      + '#menuSearchPop .ms-it .n{font-size:13.5px;font-weight:800;color:#1f2a37}'
      + '#menuSearchPop .ms-it .n mark{background:#fff0a8;color:inherit;padding:0 1px;border-radius:2px}'
      + '#menuSearchPop .ms-it .p{font-size:11.5px;font-weight:600;color:#8a98a8;margin-left:8px}'
      + '#menuSearchPop .ms-it .d{font-size:12px;color:#5a6b7a;margin-top:1px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}'
      + '#menuSearchPop .ms-g{padding:6px 12px 2px;font-size:11px;font-weight:800;color:#0f6b5e;letter-spacing:.3px}'
      + '#menuSearchPop .ms-no{padding:16px 14px;color:#8a98a8;font-size:13px;text-align:center}'
      + '#menuSearchPop .ms-ft{padding:5px 12px;border-top:1px solid #eef1f5;font-size:11px;color:#9aa7b3;position:sticky;bottom:-4px;background:#fff}'
      + '#favBar #favZoom{margin-left:8px !important}';
    (document.head || document.documentElement).appendChild(st);
  }

  function render() {
    var q = inp.value.trim(), toks = q ? q.split(/\s+/).map(norm).filter(function (t) { return t; }) : [];
    if (!items) items = build();
    var h = '';
    if (!toks.length) {   /* 빈 칸 = 전체 메뉴(묶음 차례) */
      list = items.slice(); var g = null;
      list.forEach(function (m, i) { var gg = m.path[0] || ''; if (gg !== g) { g = gg; h += '<div class="ms-g">' + esc(g || '기타') + '</div>'; } h += row(m, i, []); });
    } else {
      list = items.map(function (m, i) { return { m: m, s: score(m, toks), i: i }; }).filter(function (x) { return x.s > 0; })
                  .sort(function (a, b) { return b.s - a.s || a.i - b.i; }).map(function (x) { return x.m; });
      h = list.length ? list.map(function (m, i) { return row(m, i, toks); }).join('')
                      : '<div class="ms-no">「' + esc(q) + '」 에 맞는 메뉴가 없습니다.<br>다른 말로 찾아 보세요 (예: 반품 · 재고 · 견적 · 마감)</div>';
    }
    h += '<div class="ms-ft">↑↓ 고르기 · Enter 들어가기 · Esc 닫기 · Ctrl+K 검색 칸 — ' + (toks.length ? list.length + '개 찾음' : '전체 ' + list.length + '개 메뉴') + '</div>';
    pop.innerHTML = h; pop.classList.add('on');
    /* 뜨는 자리 — 보통은 검색 칸 오른쪽 끝에 맞춘다. 창이 좁아 검색 칸이 왼쪽으로 내려와 있으면(상단 줄이 두 줄로 접힘) 왼쪽 끝에 맞춰 화면 밖으로 안 나가게 */
    (function(){ var r = box.getBoundingClientRect(), w = Math.min(520, window.innerWidth * 0.92); if (r.right < w + 8){ pop.style.left = '0'; pop.style.right = 'auto'; } else { pop.style.right = '0'; pop.style.left = 'auto'; } })();
    cur = toks.length && list.length ? 0 : -1; paint();
  }
  function row(m, i, toks) {
    return '<div class="ms-it" data-i="' + i + '"><span class="i">' + esc(m.ic) + '</span><span class="t"><span class="n">' + mark(m.nm, toks) + '</span>'
      + (m.path.length ? '<span class="p">' + esc(m.path.join(' ▸ ')) + '</span>' : '')
      + (m.desc ? '<div class="d" title="' + esc(m.desc) + '">' + esc(m.desc) + '</div>' : '') + '</span></div>';
  }
  function paint() {
    var its = pop.querySelectorAll('.ms-it');
    for (var i = 0; i < its.length; i++) its[i].classList.toggle('on', i === cur);
    if (cur >= 0 && its[cur] && its[cur].scrollIntoView) its[cur].scrollIntoView({ block: 'nearest' });
  }
  function close() { pop.classList.remove('on'); cur = -1; }
  function go(i) {
    var m = list[i]; if (!m) return;
    close(); inp.value = ''; inp.blur();
    /* 접힌 묶음을 바깥까지 펼친 뒤 메뉴의 click 을 그대로 — favRun 과 같은 길 */
    var sub = m.a.closest('.sub-menu');
    while (sub) { if (!sub.classList.contains('open')) { sub.classList.add('open'); var head = sub.previousElementSibling; if (head && head.classList.contains('has-sub')) head.classList.add('open'); }
      sub = sub.parentElement ? sub.parentElement.closest('.sub-menu') : null; }
    m.a.click();
    try { if (m.a.scrollIntoView) m.a.scrollIntoView({ block: 'nearest' }); } catch (e) {}
  }

  function mount() {
    var bar = document.getElementById('favBar'); if (!bar || document.getElementById('menuSearch')) return !!bar;
    css();
    box = document.createElement('span'); box.id = 'menuSearch';
    box.innerHTML = '<span class="ms-ic">🔍</span><input type="text" id="menuSearchInput" autocomplete="off" spellcheck="false" placeholder="메뉴 검색 (Ctrl+K)" title="메뉴 이름·하는 일을 적으세요 — 예: 반품 · 재고 · 견적 · ㅈㄱ(초성)">'
                  + '<div id="menuSearchPop"></div>';
    var zoom = document.getElementById('favZoom');
    if (zoom) bar.insertBefore(box, zoom); else bar.appendChild(box);
    inp = box.querySelector('input'); pop = box.querySelector('#menuSearchPop');
    inp.addEventListener('focus', function () { items = build(); render(); });
    inp.addEventListener('input', render);
    inp.addEventListener('keydown', function (e) {
      if (e.isComposing || e.keyCode === 229) return;                         /* 한글 조합 중에는 손대지 않는다 */
      if (e.key === 'ArrowDown') { e.preventDefault(); if (!pop.classList.contains('on')) render(); if (list.length) { cur = (cur + 1) % list.length; paint(); } }
      else if (e.key === 'ArrowUp') { e.preventDefault(); if (list.length) { cur = (cur <= 0 ? list.length : cur) - 1; paint(); } }
      else if (e.key === 'Enter') { e.preventDefault(); if (cur < 0 && list.length === 1) cur = 0; if (cur >= 0) go(cur); }
      else if (e.key === 'Escape') { close(); inp.blur(); }
    });
    pop.addEventListener('mousedown', function (e) { var it = e.target.closest && e.target.closest('.ms-it'); if (!it) return; e.preventDefault(); go(parseInt(it.getAttribute('data-i'), 10)); });
    document.addEventListener('mousedown', function (e) { if (box && !box.contains(e.target)) close(); });
    document.addEventListener('keydown', function (e) { if ((e.ctrlKey || e.metaKey) && (e.key === 'k' || e.key === 'K')) { e.preventDefault(); inp.focus(); inp.select(); } });
    window.addEventListener('blur', function () { setTimeout(function () { if (document.activeElement !== inp) close(); }, 0); });   /* 화면(iframe)을 누르면 닫는다 */
    return true;
  }
  /* 글자 크기 단추(#favZoom)가 먼저 붙은 뒤에 그 앞에 끼운다 — 늦게 붙으면 다시 자리를 맞춘다 */
  function boot() {
    var n = 0, t = setInterval(function () {
      n++; var ok = mount(), zoom = document.getElementById('favZoom');
      if (ok && zoom && box && box.nextSibling !== zoom) zoom.parentNode.insertBefore(box, zoom);
      if ((ok && zoom) || n > 40) clearInterval(t);
    }, 150);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot); else boot();
})();
