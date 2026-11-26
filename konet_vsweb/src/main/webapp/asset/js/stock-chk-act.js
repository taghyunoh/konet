/* ============================================================================
   재고 적용 / 재고 미적용 단추 — 공용 (2026-11-26)
   사용자 「여기에서 품목별재고현황 / 월별출고현황 재고 적용, 재고미적용 기능 추가해줘(여기서 하면 직관적일 듯)」
   · 쓰는 곳 : 품목별재고현황 ② 수불 내역(셸 logi-oh.js) · 월별 출고현황 내역(stockOutMonth.jsp). 처리 = 재고 변동 확인과 같은 /prod/stockChkAct.do.
   · 화면은 window.stkChkCfg = { ctx, admin, after } 를 채우고, 줄마다 stkChkBtn({...}) 이 돌려주는 단추 HTML 을 붙인다. 누르는 것은 여기서 한 번에 받는다(문서 위임).
       act  X 재고 미적용(사유 창) · U 재고 적용(확인 창)
       gb   PURCH | SALE      seq  전표 키  (없으면 no = 근거번호 「일자-번호」 또는 「일자-번호#전표키」 — 서버가 전표를 찾는다)
       cd   품목코드(그 품목만) · 비우면 전표 전체        del  1 = 지운 전표(«삭제를 재고에 적용 안 함»)
       q    그 줄이 재고에 미친 수량(글에만 쓴다)         nm   창에 보일 이름(전표 번호 등)
   · 관리자(총괄·부관리자)만 단추가 보인다 — 서버도 같은 기준으로 막는다. 알림은 ui-message(_alertBox·_confirmBox·_toast), 사유 창만 여기 것(입력칸이 필요해서).
   ============================================================================ */
(function () {
  if (window.stkChkBtn) return;
  window.stkChkCfg = window.stkChkCfg || { ctx: '', admin: false, after: null };
  function esc(s) { return ('' + (s == null ? '' : s)).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
  function num(v) { var x = Number(v); return isFinite(x) ? (Math.round(x * 100) / 100).toLocaleString() : '0'; }
  function sg(q) { q = Number(q) || 0; return (q > 0 ? '+' : '') + num(q); }

  window.stkChkBtn = function (o) {
    if (!o || !window.stkChkCfg.admin) return '';
    var x = (o.act === 'X');
    return ' <button type="button" class="stk-chk-btn" data-chk-act="' + (x ? 'X' : 'U') + '" data-gb="' + esc(o.gb || '') + '" data-seq="' + esc(o.seq == null ? '' : o.seq) + '" data-no="' + esc(o.no || '')
      + '" data-cd="' + esc(o.cd || '') + '" data-del="' + (o.del ? '1' : '') + '" data-q="' + esc(o.q == null ? '' : o.q) + '" data-nm="' + esc(o.nm || '') + '"'
      + ' title="' + (x ? (o.del ? '삭제를 재고에 적용하지 않습니다 — 지워서 빠진 수량이 재고에 다시 들어갑니다(판매는 다시 빠집니다)' : '이 줄을 재고에 적용하지 않습니다(매입·매출 금액은 그대로)') : '다시 재고에 적용합니다') + '"'
      + ' style="margin-left:4px;height:22px;padding:0 8px;border-radius:6px;font-size:11.5px;font-weight:800;cursor:pointer;white-space:nowrap;'
      + (x ? 'background:#fff4e5;color:#9a5a00;border:1px solid #f0cf9a' : 'background:#e8f1fb;color:#1b4f86;border:1px solid #b9d2ee') + '">' + (x ? '재고 미적용' : '재고 적용') + '</button>';
  };

  /* 전표 전체를 재고 미적용한 전표인가 — 그러면 [재고 적용] 도 전표 전체로 보낸다(품목만 보내면 «되돌릴 줄이 없다») */
  window.stkChkWhole = function (gb, seq) { var w = window.stkChkCfg.whole || []; return seq !== '' && seq != null && w.indexOf(gb + ':' + seq) >= 0; };

  var box = null, cur = null;
  function ensure() {
    if (box) return box;
    box = document.createElement('div');
    box.id = 'stkChkAsk';
    box.style.cssText = 'position:fixed;left:0;top:0;right:0;bottom:0;background:rgba(15,23,32,.45);display:none;align-items:center;justify-content:center;z-index:13000';
    box.innerHTML = '<div style="width:min(480px,calc(100vw - 30px));background:#fff;border-radius:16px;padding:20px 20px 16px;box-shadow:0 18px 50px rgba(0,0,0,.25);font-family:\'맑은 고딕\',sans-serif;color:#1f2a37">'
      + '<h3 style="margin:0 0 6px;font-size:16.5px">재고 미적용</h3><p id="stkChkAskMsg" style="margin:0 0 10px;font-size:13px;color:#5b6b7a;line-height:1.65"></p>'
      + '<div id="stkChkAskChips" style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:8px"></div>'
      + '<textarea id="stkChkAskMemo" maxlength="200" placeholder="재고에 적용하지 않는 사유 (꼭 적어 주세요)" style="width:100%;height:70px;border:1px solid #dbe2ea;border-radius:8px;padding:8px;font-size:13.5px;font-family:inherit;box-sizing:border-box"></textarea>'
      + '<div id="stkChkAskErr" style="color:#c0392b;font-size:12.5px;min-height:18px;margin-top:4px"></div>'
      + '<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:6px">'
      + '<button type="button" id="stkChkAskNo" style="height:34px;border:1px solid #dbe2ea;background:#fff;border-radius:7px;padding:0 13px;cursor:pointer;font-size:13px;font-weight:700;color:#37475a">취소</button>'
      + '<button type="button" id="stkChkAskOk" style="height:34px;border:1px solid #f0cf9a;background:#fff4e5;border-radius:7px;padding:0 13px;cursor:pointer;font-size:13px;font-weight:700;color:#9a5a00">재고 미적용</button></div></div>';
    document.body.appendChild(box);
    box.addEventListener('click', function (e) { if (e.target === box) close(); });
    document.getElementById('stkChkAskNo').onclick = close;
    document.getElementById('stkChkAskOk').onclick = function () {
      var memo = (document.getElementById('stkChkAskMemo').value || '').trim();
      if (!memo) { document.getElementById('stkChkAskErr').textContent = '재고에 적용하지 않는 사유를 적어 주세요.'; return; }
      var o = cur; close(); if (o) post(o, memo);
    };
    document.getElementById('stkChkAskChips').addEventListener('click', function (e) {
      var b = e.target; if (b && b.tagName === 'BUTTON') { document.getElementById('stkChkAskMemo').value = b.textContent; document.getElementById('stkChkAskErr').textContent = ''; }
    });
    return box;
  }
  function close() { if (box) box.style.display = 'none'; cur = null; }
  function warn(m) { if (typeof window._alertBox === 'function') window._alertBox(m, { icon: '⚠️', okColor: 'red' }); }
  function post(o, memo) {
    var it = itemOf(o);
    fetch((window.stkChkCfg.ctx || '') + '/prod/stockChkAct.do', { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ items: [it], act: o.act, memo: memo || '' }) })
      .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
      .then(function (j) {
        if (!j || j.result !== 'OK') { warn(esc((j && j.message) || '처리하지 못했습니다.')); return; }
        var what = (o.act === 'X') ? '재고 미적용' : '재고 적용', ps = j.prods || [];
        if (!(j.done > 0)) { warn(j.blocked ? '관리자만 할 수 있는 처리입니다.' : '처리할 전표(품목)를 찾지 못했습니다 — 다시 조회한 뒤 해 주세요.'); return; }
        if (ps.length && typeof window._alertBox === 'function') {
          var h = '<b>' + what + ' 했습니다</b><div style="text-align:left;margin-top:8px;font-size:13px;line-height:1.7;max-height:240px;overflow:auto">';
          ps.forEach(function (p) { var same = (Number(p.bef) === Number(p.aft));
            h += '<div>' + esc(p.prodCd) + ' ' + esc(p.prodNm || '') + ' — 현재고 ' + (same ? ('<b>' + num(p.bef) + '</b> 그대로 <span style="color:#8a97a4">(맞춘 날짜보다 앞 전표)</span>') : (num(p.bef) + ' → <b>' + num(p.aft) + '</b>')) + '</div>'; });
          window._alertBox(h + '</div>', { icon: '📦' });
        } else if (typeof window._toast === 'function') window._toast(what + ' 했습니다', 'ok');
        try { if (typeof window.stkChkCfg.after === 'function') window.stkChkCfg.after(j, o); } catch (e) {}
      })
      .catch(function () { warn('처리하지 못했습니다 — 다시 조회한 뒤 해 주세요.'); });
  }
  function itemOf(o) { var it = { refGb: o.gb, prodCd: o.cd || '' }; if (o.seq !== '' && o.seq != null) it.refSeq = Number(o.seq); else it.refNo = o.no || ''; return it; }
  function d10(s) { s = ('' + (s || '')).replace(/[^0-9]/g, ''); return s.length >= 8 ? (s.slice(0, 4) + '-' + s.slice(4, 6) + '-' + s.slice(6, 8)) : s; }
  /* ★처리 전에 묻기 — «수정재고로 고정된 품목» 의 «고정 날짜보다 앞» 전표면 재고 미적용·적용을 해도 현재고가 그대로다
       (2026-11-26 사용자 「이전것 적용미적용 할려할때 메세지 뛰워야 겠네요」 → 「그래도 진행은 의미 없지않나요 · 어차피 적용안되는데」).
       · 대상 품목이 전부 그렇다 → 안내만 하고 처리하지 않는다(진행 단추 없음).
       · 전표 전체인데 일부만 그렇다 → 「n개는 영향 없음 · 나머지 m개」 를 알리고 진행 여부를 묻는다.
       · 판정 = /prod/stockChkPre.do(서버 — 조정 이력의 고정값 FRZ_QTY 와 날짜). 못 물어보면(옛 서버·통신 실패) 종전대로 진행.
       재고 변동 확인 화면(stockChk.jsp)도 이 함수를 쓴다. go = 진행할 때 부를 함수 */
  window.stkChkPre = function (items, act, go) {
    var ctx = (window.stkChkCfg && window.stkChkCfg.ctx) || '';
    var pass = function () { try { go(); } catch (e) {} };
    try {
      fetch(ctx + '/prod/stockChkPre.do', { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ items: items, act: act }) })
        .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(function (j) {
          var L = (j && j.result === 'OK' && j.list) || [], total = Number(j && j.total) || 0;
          if (!L.length) { pass(); return; }
          var lines = L.map(function (x) { return '<div>' + esc(x.prodCd || '') + ' ' + esc(x.prodNm || '') + ' — 전표 ' + esc(d10(x.trxDt)) + ' · 🔒 재고수정 ' + esc(d10(x.fixDt)) + '</div>'; }).join('');
          var box = '<div style="text-align:left;margin-top:8px;font-size:13px;line-height:1.7;max-height:200px;overflow:auto">' + lines + '</div>';
          if (L.length >= total) {
            if (typeof window._alertBox === 'function')
              window._alertBox('<b>현재고에 영향이 없어 처리하지 않았습니다</b>' + box
                + '<div style="text-align:left;margin-top:8px;font-size:13px;color:#5b6b7a;line-height:1.7">재고수정으로 맞춰 고정된 품목이고, 이 전표는 그보다 <b>앞 날짜</b>입니다.<br>'
                + '재고 미적용·적용을 해도 현재고가 바뀌지 않습니다.<br>현재고를 바꾸려면 <b>재고 일괄조정에서 재고수정을 다시</b> 하세요.</div>', { icon: '🔒' });
            return;
          }
          if (typeof window._confirmBox === 'function')
            window._confirmBox({ msg: '<b>품목 ' + total + '개 중 ' + L.length + '개는 현재고에 영향이 없습니다</b>' + box
                + '<div style="text-align:left;margin-top:8px;font-size:13px;color:#5b6b7a;line-height:1.7">재고수정으로 고정된 품목의 앞 날짜 전표입니다. 나머지 <b>' + (total - L.length) + '개</b>만 현재고가 바뀝니다.</div>',
              icon: '🔒', okText: '진행', onOk: pass });
          else pass();
        })
        .catch(pass);
    } catch (e) { pass(); }
  };
  document.addEventListener('click', function (e) {
    var b = e.target && e.target.closest ? e.target.closest('[data-chk-act]') : null; if (!b) return;
    e.preventDefault(); e.stopPropagation();
    var o = { act: b.getAttribute('data-chk-act'), gb: b.getAttribute('data-gb'), seq: b.getAttribute('data-seq'), no: b.getAttribute('data-no'), cd: b.getAttribute('data-cd'),
              del: b.getAttribute('data-del') === '1', q: b.getAttribute('data-q'), nm: b.getAttribute('data-nm') };
    window.stkChkPre([itemOf(o)], o.act, function () { ask(o); });
  }, true);
  function ask(o) {
    var qq = (o.cd && o.q !== '' && o.q != null) ? Number(o.q) : null;   /* 전표 전체면 수량을 안 적는다(이 품목 것만 알고 있다) */
    var head = '<b>' + (o.gb === 'PURCH' ? '매입' : '판매') + '전표 ' + esc(o.nm || o.no || '') + '</b>' + (o.del ? ' <span style="color:#b03a2e;font-weight:700">(지운 전표)</span>' : '')
             + '<br>' + (o.cd ? ('품목 <b>' + esc(o.cd) + '</b>') : '이 전표의 <b>품목 전부</b>');
    if (o.act === 'X') {
      ensure(); cur = o;
      document.getElementById('stkChkAskMsg').innerHTML = head + '<br>'
        + (o.del ? ('전표를 지워서 재고에 미친 수량' + (qq != null ? (' <b>' + sg(-qq) + '</b>') : '') + ' 을(를) 재고에 적용하지 않습니다 — 그만큼 재고가 <b>지우기 전으로</b> 돌아갑니다.')
                 : ('이 줄이 재고에 미친 수량' + (qq != null ? (' <b>' + sg(qq) + '</b>') : '') + ' 을(를) 재고에 적용하지 않습니다. 매입·매출 금액은 그대로 남습니다.'));
      var chips = o.del ? ['서류만 삭제 (실물은 그대로 있음)', '잘못 지움'] : ['서류만 정정 (실물 그대로)', '중복 입력', '실물이 아직 안 들어옴', '실물이 아직 안 나감'];
      document.getElementById('stkChkAskChips').innerHTML = chips.map(function (t) { return '<button type="button" style="border:1px solid #dbe2ea;background:#f6f8fa;border-radius:14px;padding:4px 11px;font-size:12.5px;cursor:pointer;font-weight:700;color:#37475a">' + esc(t) + '</button>'; }).join('');
      document.getElementById('stkChkAskMemo').value = ''; document.getElementById('stkChkAskErr').textContent = '';
      box.style.display = 'flex'; document.getElementById('stkChkAskMemo').focus();
    } else if (typeof window._confirmBox === 'function') {
      window._confirmBox({ msg: head + '<br>' + (o.del ? ('전표 삭제를 <b>재고에 적용합니다</b>' + (qq != null ? (' — 재고 <b>' + sg(-qq) + '</b>') : '') + '.')
                                                       : ('다시 <b>재고에 적용합니다</b>' + (qq != null ? (' — 재고 <b>' + sg(qq) + '</b>') : '') + '.')),
                           icon: '📦', okText: '재고 적용', onOk: function () { post(o, ''); } });
    } else post(o, '');
  }
})();
