/* ─────────────────────────────────────────────────────────────────────────
   판매·매입 전표 수정이력 (2026-11-16 사용자 「표시 부분에 수정이력 버튼으로 조회 내역 — 매입등록도 같이」)

   거는 법 : <script src=".../asset/js/trx-hist.js?v=20261116"> + 단추 onclick="konetTrxHist({...})"
     kind  : 'sales' | 'purch'
     title : '판매' | '매입'
     from/to/find : 목록의 검색기간·거래처 입력칸 id (목록과 같은 조건으로 연다)
     open(seq) : 전표를 위 입력칸에 불러오는 함수(sphOpen · pphOpen) — 줄의 [열기]

   ★이력 표가 따로 없다 — 저장할 때마다 옛 명세가 지워진 줄(ACTION_YN=N, 지운 때·사람)로 남고 새 명세가 들어가므로
     명세 묶음 하나 = «한 번 저장한 판». 서버(/mangr/trxEditHist.do)가 전표 × 판으로 돌려주고 이 창이 전표마다 묶는다.
     · 판 1 = 등록 · 판 2.. = 수정(그 판을 넣은 때·사람) · 머리가 지워졌으면 삭제(지운 때·사람)
     · 살아 있는 판이 없는데 전표는 살아 있으면 「⚠ 품목 없음」(저장 실패로 명세만 지워진 경우 — 2026-11-16 판매전표 172)
   알림은 ui-message(_alertBox) — 없으면 alert.
   ───────────────────────────────────────────────────────────────────────── */
(function () {
  if (window.konetTrxHist) return;
  var ST = null, CSS = false;
  function css() {
    if (CSS) return; CSS = true;
    var s = document.createElement('style');
    s.textContent =
        '#kthPop{position:fixed;inset:0;z-index:12600;background:rgba(15,23,32,.35);display:none;align-items:flex-start;justify-content:center;padding:40px 16px}'
      + '#kthPop.on{display:flex}'
      + '#kthPop .box{background:#fff;border-radius:12px;box-shadow:0 12px 40px rgba(0,0,0,.25);width:min(1180px,96vw);max-height:calc(100vh - 80px);display:flex;flex-direction:column}'
      + '#kthPop .hd{display:flex;align-items:center;gap:10px;padding:12px 16px;border-bottom:1px solid #e5ebf0;font-weight:800;color:#125a4e;font-size:15px}'
      + '#kthPop .hd small{font-weight:600;color:#6b7a89;font-size:12px}'
      + '#kthPop .hd .x{margin-left:auto;border:0;background:transparent;font-size:20px;cursor:pointer;color:#5a6b7a}'
      + '#kthPop .bar{display:flex;align-items:center;gap:12px;padding:8px 16px;font-size:12.5px;color:#37475a;border-bottom:1px solid #eef1f4}'
      + '#kthPop .bd{overflow:auto;padding:0 0 8px}'
      + '#kthPop table{border-collapse:collapse;width:100%;font-size:12.5px}'
      + '#kthPop th{position:sticky;top:0;background:#eaf2f0;color:#125a4e;font-weight:700;padding:6px 6px;border-bottom:1px solid #cfe0da;white-space:nowrap;z-index:1}'
      + '#kthPop td{padding:5px 6px;border-bottom:1px solid #eef1f4;white-space:nowrap;vertical-align:top}'
      + '#kthPop td.r{text-align:right} #kthPop td.c{text-align:center} #kthPop td.l{white-space:normal}'
      + '#kthPop tr.slip{cursor:pointer} #kthPop tr.slip:hover td{background:#f4faf8} #kthPop tr.slip.on td{background:#e3f2ee}'
      + '#kthPop .tag{display:inline-block;padding:1px 7px;border-radius:9px;font-size:11.5px;font-weight:700}'
      + '#kthPop .t-new{background:#e8eef4;color:#37475a} #kthPop .t-edit{background:#fff3c4;color:#8a5a00} #kthPop .t-del{background:#fdecea;color:#c0392b} #kthPop .t-warn{background:#fdecea;color:#c0392b}'
      + '#kthPop tr.ver td{background:#fbfcfd;font-size:12px} #kthPop tr.ver td.k{padding-left:26px}'
      + '#kthPop tr.ln td{background:#fff;font-size:11.5px;color:#4a5a6a} #kthPop tr.ln td.k{padding-left:46px}'
      + '#kthPop .dim{color:#8a95a1} #kthPop .up{color:#c0392b;font-weight:700} #kthPop .dn{color:#1f6fb3;font-weight:700}'
      + '#kthPop .lnk{border:1px solid #cfd8e3;background:#fff;border-radius:6px;padding:1px 8px;font-size:11.5px;cursor:pointer}'
      + '#kthPop .lnk:hover{border-color:#137a6c;color:#137a6c}';
    document.head.appendChild(s);
  }
  function esc(v) { return String(v == null ? '' : v).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
  function n(v) { var x = Number(String(v == null ? '' : v).replace(/,/g, '')); return isFinite(x) ? x : 0; }
  function fmt(v) { return Math.round(n(v)).toLocaleString(); }
  function fq(v) { var x = n(v); return (Math.round(x * 1000) / 1000).toLocaleString(); }
  function dt8(d) { d = String(d || '').replace(/-/g, ''); return d.length === 8 ? d.slice(0, 4) + '-' + d.slice(4, 6) + '-' + d.slice(6, 8) : d; }
  function tm(d) { d = String(d || ''); return d ? d.slice(0, 16) : ''; }
  function gv(id) { var e = id && document.getElementById(id); return e ? String(e.value || '').trim() : ''; }
  function alertMsg(h) { if (window._alertBox) window._alertBox(h, { icon: '⚠️' }); else alert(h.replace(/<[^>]+>/g, '')); }
  function ctx() { return window.CTX || ''; }
  function post(url, body) {
    return fetch(ctx() + url, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: body })
      .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); });
  }
  function pop() {
    var p = document.getElementById('kthPop');
    if (p) return p;
    p = document.createElement('div'); p.id = 'kthPop';
    p.innerHTML = '<div class="box"><div class="hd">🕘 <span id="kthTitle"></span> <small id="kthSub"></small><button class="x" title="닫기 (Esc)">✕</button></div>'
      + '<div class="bar"><label><input type="checkbox" id="kthOnly" checked> 고치거나 삭제한 전표만</label><span id="kthCnt" class="dim"></span>'
      + '<span class="dim" style="margin-left:auto">줄을 누르면 저장한 판마다 품목이 펼쳐집니다 · 등록·수정 시각은 그 판을 저장한 때</span></div>'
      + '<div class="bd"><table><thead><tr><th>일자</th><th>번호</th><th>거래처</th><th>상태</th><th>판</th><th>처음 등록</th><th>마지막 저장</th><th>현재 품목</th><th>현재 금액</th><th></th></tr></thead><tbody id="kthBody"></tbody></table></div></div>';
    document.body.appendChild(p);
    p.querySelector('.x').onclick = close;
    p.addEventListener('mousedown', function (e) { if (e.target === p) close(); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && p.classList.contains('on')) close(); });
    document.getElementById('kthOnly').onchange = render;
    return p;
  }
  function close() { var p = document.getElementById('kthPop'); if (p) p.classList.remove('on'); }

  /* 서버 줄(전표 × 판) → 전표마다 묶기 */
  function group(rows) {
    var m = {}, out = [];
    rows.forEach(function (r) {
      var k = String(r.seq), s = m[k];
      if (!s) { s = m[k] = { seq: r.seq, dt: r.dt, no: r.no, custCd: r.custCd, custNm: r.custNm, actionYn: r.actionYn, regDttm: r.regDttm, regUser: r.regUser,
                              updDttm: r.updDttm, updUser: r.updUser, totAmt: r.totAmt, vers: [] }; out.push(s); }
      if (r.vk != null) s.vers.push({ vk: r.vk, from: r.vFrom, user: r.vUser, to: r.vTo, toUser: r.vToUser, cnt: r.cnt, qty: r.qty, amt: r.amt });
    });
    out.forEach(function (s) {
      s.vers.sort(function (a, b) { return String(a.from || '').localeCompare(String(b.from || '')); });
      s.live = s.vers.filter(function (v) { return v.vk === 'LIVE'; })[0] || null;
      s.del = (s.actionYn && String(s.actionYn).trim() !== 'Y');
      s.noLines = !s.del && !s.live && s.vers.length > 0;
      s.edited = s.vers.length > 1 || s.del || s.noLines;
    });
    return out;
  }
  function stateTag(s) {
    if (s.del) return '<span class="tag t-del">삭제</span>';
    if (s.noLines) return '<span class="tag t-warn" title="전표 머리는 살아 있는데 살아 있는 품목이 없습니다 — 저장이 중간에 실패해 품목만 지워진 경우일 수 있습니다">⚠ 품목 없음</span>';
    if (s.vers.length > 1) return '<span class="tag t-edit">수정 ' + (s.vers.length - 1) + '회</span>';
    return '<span class="tag t-new">등록</span>';
  }
  function render() {
    var b = document.getElementById('kthBody'); if (!b || !ST) return;
    var only = document.getElementById('kthOnly').checked;
    var list = ST.list.filter(function (s) { return !only || s.edited; });
    document.getElementById('kthCnt').textContent = '전표 ' + list.length.toLocaleString() + '장' + (only ? ' (전체 ' + ST.list.length.toLocaleString() + '장 중 고치거나 삭제한 것)' : '');
    if (!list.length) { b.innerHTML = '<tr><td colspan="10" class="c dim" style="padding:22px">' + (only ? '이 기간에 고치거나 삭제한 전표가 없습니다. 「고치거나 삭제한 전표만」을 끄면 전부 보입니다.' : '이 기간에 전표가 없습니다.') + '</td></tr>'; return; }
    b.innerHTML = list.map(function (s) {
      var last = s.del ? { t: s.updDttm, u: s.updUser } : (s.vers.length ? { t: s.vers[s.vers.length - 1].from, u: s.vers[s.vers.length - 1].user } : { t: s.regDttm, u: s.regUser });
      var first = s.vers.length ? { t: s.vers[0].from, u: s.vers[0].user } : { t: s.regDttm, u: s.regUser };
      var lv = s.live;
      return '<tr class="slip" data-seq="' + esc(s.seq) + '"><td class="c">' + esc(dt8(s.dt)) + '</td><td class="c">' + esc(s.no) + '</td>'
        + '<td class="l">' + esc(s.custNm || '') + ' <span class="dim">' + esc(s.custCd || '') + '</span></td>'
        + '<td class="c">' + stateTag(s) + '</td><td class="c">' + s.vers.length + '</td>'
        + '<td>' + esc(tm(first.t)) + ' <b>' + esc(first.u || '') + '</b></td>'
        + '<td>' + (s.del ? '<span class="up">삭제</span> ' : '') + esc(tm(last.t)) + ' <b>' + esc(last.u || '') + '</b></td>'
        + '<td class="r">' + (lv ? n(lv.cnt) : '<span class="dim">0</span>') + '</td><td class="r">' + (lv ? fmt(lv.amt) : '<span class="dim">' + fmt(s.totAmt) + ' (머리)</span>') + '</td>'
        + '<td>' + (s.del || !ST.cfg.open ? '' : '<button class="lnk" data-open="' + esc(s.seq) + '" title="이 전표를 위 입력칸에 불러옵니다">열기</button>') + '</td></tr>';
    }).join('');
    Array.prototype.forEach.call(b.querySelectorAll('tr.slip'), function (tr) {
      tr.onclick = function (e) {
        var o = e.target && e.target.getAttribute && e.target.getAttribute('data-open');
        if (o) { e.stopPropagation(); close(); ST.cfg.open(Number(o)); return; }
        toggle(tr);
      };
    });
  }
  /* 전표 줄을 누르면 판마다 펼친다 — 판 머리(등록/수정·때·사람·품목 수·금액·바뀐 금액) + 그 판의 품목 */
  function toggle(tr) {
    var seq = tr.getAttribute('data-seq'), s = ST.list.filter(function (x) { return String(x.seq) === seq; })[0]; if (!s) return;
    var nx = tr.nextSibling;
    if (tr.classList.contains('on')) { while (nx && nx.classList && !nx.classList.contains('slip')) { var d = nx; nx = nx.nextSibling; d.parentNode.removeChild(d); } tr.classList.remove('on'); return; }
    tr.classList.add('on');
    var ph = document.createElement('tr'); ph.className = 'ver'; ph.innerHTML = '<td colspan="10" class="k dim">불러오는 중…</td>';
    tr.parentNode.insertBefore(ph, tr.nextSibling);
    post('/mangr/trxHistLines.do', 'kind=' + encodeURIComponent(ST.cfg.kind) + '&seq=' + encodeURIComponent(seq)).then(function (j) {
      var lines = (j && j.data) || [], by = {};
      lines.forEach(function (l) { (by[l.vk] = by[l.vk] || []).push(l); });
      var h = '', prev = null;
      s.vers.forEach(function (v, i) {
        var kind = i === 0 ? '<span class="tag t-new">등록</span>' : '<span class="tag t-edit">수정 ' + i + '</span>';
        var diff = '';
        if (prev) { var dA = n(v.amt) - n(prev.amt), dC = n(v.cnt) - n(prev.cnt);
          diff = (dA ? ' <span class="' + (dA > 0 ? 'up' : 'dn') + '">금액 ' + (dA > 0 ? '+' : '') + fmt(dA) + '</span>' : ' <span class="dim">금액 같음</span>')
               + (dC ? ' <span class="dim">· 품목 ' + (dC > 0 ? '+' : '') + dC + '</span>' : ''); }
        var end = v.vk === 'LIVE' ? '<span class="tag t-new" style="background:#e6f4ea;color:#1f7a34">지금 판</span>'
                : '<span class="dim">→ ' + esc(tm(v.to)) + ' ' + esc(v.toUser || '') + ' ' + (i === s.vers.length - 1 ? (s.del ? '삭제' : '지움(다음 판 없음)') : '바꿈') + '</span>';
        h += '<tr class="ver"><td colspan="10" class="k">' + kind + ' <b>' + esc(tm(v.from)) + '</b> ' + esc(v.user || '') + ' · 품목 ' + n(v.cnt) + ' · 수량 ' + fq(v.qty) + ' · 금액 <b>' + fmt(v.amt) + '</b>' + diff + ' ' + end + '</td></tr>';
        (by[v.vk] || []).forEach(function (l) {
          h += '<tr class="ln"><td colspan="10" class="k">' + esc(l.rowNo) + '. ' + esc(l.prodCd || '') + ' ' + esc(l.prodNm || '') + (l.spec ? ' <span class="dim">' + esc(l.spec) + '</span>' : '')
            + ' · ' + fq(l.qty) + ' × ' + fmt(l.unitPrice) + ' = <b>' + fmt(l.totAmt) + '</b>' + (l.trxGb && l.trxGb !== '판매' && l.trxGb !== '매입' ? ' <span class="up">' + esc(l.trxGb) + '</span>' : '')
            + (l.remark ? ' <span class="dim">· ' + esc(l.remark) + '</span>' : '') + '</td></tr>';
        });
        prev = v;
      });
      if (s.del) h += '<tr class="ver"><td colspan="10" class="k"><span class="tag t-del">삭제</span> <b>' + esc(tm(s.updDttm)) + '</b> ' + esc(s.updUser || '') + '</td></tr>';
      if (s.noLines) h += '<tr class="ver"><td colspan="10" class="k"><span class="tag t-warn">⚠ 품목 없음</span> 전표 머리(금액 ' + fmt(s.totAmt) + ')는 살아 있는데 살아 있는 품목이 없습니다. 마지막 판이 지워진 뒤 새 판이 들어가지 않았습니다.</td></tr>';
      if (!s.vers.length) h += '<tr class="ver"><td colspan="10" class="k dim">품목 기록이 없습니다.</td></tr>';
      var tmp = document.createElement('tbody'); tmp.innerHTML = h;
      var at = ph.nextSibling; ph.parentNode.removeChild(ph);
      while (tmp.firstChild) tr.parentNode.insertBefore(tmp.firstChild, at);
    }).catch(function (e) { ph.innerHTML = '<td colspan="10" class="k up">불러오지 못했습니다 — ' + esc(e.message) + '</td>'; });
  }

  window.konetTrxHist = function (cfg) {
    /* ★고른 전표 한 장만 (2026-11-17 사용자 「하단 선택된 내용에 대하여만 보여줘」) — cfg.seq 가 없으면(전표를 안 골랐으면) 안내만 */
    if (cfg.single && !cfg.seq) { alertMsg('아래 목록에서 전표를 먼저 고르세요.<br><span style="font-size:12.5px;color:#3d4d5c">고른(위에 불러온) 전표 한 장의 수정이력을 보여 줍니다.</span>'); return; }
    css(); var p = pop();
    var one = !!cfg.seq;
    var fr = one ? '' : gv(cfg.from).replace(/-/g, ''), to = one ? '' : gv(cfg.to).replace(/-/g, ''), fd = one ? '' : gv(cfg.find);
    document.getElementById('kthTitle').textContent = cfg.title + '전표 수정이력';
    document.getElementById('kthSub').textContent = one ? '— 고른 전표 한 장' : ('— ' + (fr ? dt8(fr) : '처음') + ' ~ ' + (to ? dt8(to) : '끝') + (fd ? ' · 거래처 「' + fd + '」' : '') + ' (목록과 같은 조건)');
    var bar = p.querySelector('.bar'); if (bar) bar.style.display = one ? 'none' : '';
    document.getElementById('kthOnly').checked = !one;   /* 한 장이면 고치지 않은 전표도 보여야 한다 */
    document.getElementById('kthBody').innerHTML = '<tr><td colspan="10" class="c dim" style="padding:22px">불러오는 중…</td></tr>';
    p.classList.add('on');
    post('/mangr/trxEditHist.do', 'kind=' + encodeURIComponent(cfg.kind) + '&frDt=' + encodeURIComponent(fr) + '&toDt=' + encodeURIComponent(to) + '&findData=' + encodeURIComponent(fd) + (one ? '&seq=' + encodeURIComponent(cfg.seq) : ''))
      .then(function (j) {
        if (!j || j.result !== 'OK') throw new Error((j && j.message) || '조회 실패');
        ST = { cfg: cfg, list: group(j.data || []) }; render();
        if (one) { var tr0 = document.querySelector('#kthBody tr.slip'); if (tr0) toggle(tr0);   /* 한 장이면 판을 바로 펼친다 */
                   else document.getElementById('kthBody').innerHTML = '<tr><td colspan="10" class="c dim" style="padding:22px">이 전표의 기록을 찾지 못했습니다. 저장한 뒤 다시 보세요.</td></tr>'; }
      })
      .catch(function (e) { document.getElementById('kthBody').innerHTML = '<tr><td colspan="10" class="c up" style="padding:22px">수정이력을 불러오지 못했습니다 — ' + esc(e.message) + '</td></tr>'; });
  };
})();
