/* =====================================================================================================
   ceo-lines.js — 대표자 일정 «줄이 전부 끝났나» 판정 한 벌   (2026-11-20 신설)

   왜 : 대표자 일정 화면(ceoSched.jsp)의 「미완료」 목록은 줄이 다 끝난 일정(상태만 빈칸)을 뺀다.
        그런데 메뉴 옆 빨간 숫자·로그인 창(asset/js/emp-badge.js)은 상태 칸만 보고 세서 숫자가 어긋났다
        (사용자 2026-11-20 「서버 숫자도 맞춰줘」 — 실제로는 서버가 아니라 emp-badge.js 가 센다).
        ⇒ 판정을 이 파일 하나에 두고 두 곳이 같이 쓴다. 규칙을 두 벌로 두면 조용히 어긋난다.

   konetCeoAllDone(html) → 'Y'(줄이 전부 끝남 · 하나라도 완료) | 'C'(전부 취소) | null(남은 줄이 있음 · 줄이 없음)
     · 줄 나누기 = 편집기 글의 블록(div·p·li …)과 br 마다 한 줄 — ceoSched.jsp schedLines 와 같은 규칙
     · 줄 상태 = 줄 끝 글자 「… 완료」 / 「… 취소」(「일정취소」·「[완료]」·「(완료)」도 · 앞에 띄어쓰기나 괄호가 있어야 한다 — 「검수완료」는 아님)
     · 세는 줄 = 할 일 줄 — 번호 매긴 줄(「1. 」「2)」)이 하나라도 있으면 번호 줄만(번호 없는 줄 = 묶음 머리 「삼성미팅」), 없으면 모든 줄
   ⚠ceoSched.jsp 의 줄 칩·표시(LN_MK·LN_NUM·schedLines)를 바꾸면 이 파일도 같이 본다. 시뮬 = sim_ceoSchedLines.js(같은 결과인지 대조) · sim_ceoLoginLate.js
   ===================================================================================================== */
(function () {
  if (window.konetCeoAllDone) return;
  var MK = /(?:\s+|\s*[\[(])(완료|(?:일정\s?)?취소)\s*[\])]?\s*$/;
  var BLK = /^(P|DIV|LI|H1|H2|H3|H4|BLOCKQUOTE|TR|TD|TH|PRE|UL|OL|TABLE|HR)$/;
  var NUM = /^(\d{1,3})([.)])(?!\d)\s*/;

  function lines(html) {
    if (typeof DOMParser === 'undefined') return [];
    var doc = new DOMParser().parseFromString('<body>' + String(html == null ? '' : html) + '</body>', 'text/html'), out = [], cur = null;
    function flush() { if (cur !== null) out.push(cur); cur = null; }
    (function walk(n) {
      [].slice.call(n.childNodes).forEach(function (c) {
        if (c.nodeType === 3) { cur = (cur || '') + c.nodeValue; return; }
        if (c.nodeType !== 1) return;
        var t = c.tagName;
        if (t === 'BR') { flush(); return; }
        if (t === 'LI') { flush(); var p = c.parentNode; cur = (p && p.tagName === 'OL') ? (([].filter.call(p.children, function (x) { return x.tagName === 'LI'; }).indexOf(c)) + 1) + '. ' : '• '; walk(c); flush(); return; }
        var blk = BLK.test(t); if (blk) flush(); walk(c); if (blk) flush();
      });
    })(doc.body);
    flush();
    var res = [];
    out.forEach(function (s) {
      var tx = s.replace(/ /g, ' ').replace(/\s+/g, ' ').trim(); if (!tx) return;
      var m = MK.exec(tx), body = m ? tx.slice(0, m.index) : tx;
      res.push({ st: m ? (m[1] === '완료' ? 'Y' : 'C') : 'N', no: NUM.test(body.trim()) });
    });
    return res;
  }

  window.konetCeoAllDone = function (html) {
    var L = lines(html); if (!L.length) return null;
    var anyNo = L.some(function (l) { return l.no; });
    var it = anyNo ? L.filter(function (l) { return l.no; }) : L;
    if (!it.length || it.some(function (l) { return l.st === 'N'; })) return null;
    return it.every(function (l) { return l.st === 'C'; }) ? 'C' : 'Y';
  };
})();
