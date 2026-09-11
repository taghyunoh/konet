/* =====================================================================
   거래처 빠른등록 — 매입등록 · 판매등록 공용 (2026-08-03 요청)
   ---------------------------------------------------------------------
   전표를 쓰다가 없는 거래처를 만나면, 지금까지는 화면을 나가 [거래처관리]에서
   등록하고 돌아와야 했다. 그 자리에서 바로 만들고 이어서 쓰게 한다.

   사용법: 페이지에 <script src="/asset/js/vendor-quick.js"></script> 한 줄 추가 후
     _vendorQuickOpen({
       gb    : '매입',                              // 이 화면의 거래유형 → 기본값으로 찍어 준다
       ctx   : CTX,                                 // 컨텍스트 경로
       list  : function(){ return _vendors; },      // 거래처 마스터(코드 자동제안·중복확인에 쓴다)
       onDone: function(o){ _vendors.push(o); puVenPick(o.vendorCd); }   // 저장 뒤 할 일
     });

   설계 메모
   · **필수만 받는다** — 코드·거래처명·거래유형·부가세. 사업자번호·대표자·연락처는
     있으면 같이 받되 비워도 저장된다. 나머지 상세는 [거래처관리]에서 채운다.
     전표를 쓰다 멈춘 사람에게 20칸짜리 폼을 내밀면 결국 화면을 나가게 된다.
   · **거래처코드는 자동 제안** — 지금 마스터에서 숫자로만 된 코드의 최대값+1(4자리).
     칸은 열어 두어 병원·거래처가 쓰던 코드 규칙이 따로 있으면 고쳐 쓸 수 있다.
     ★서버에 같은 코드가 있으면 저장이 실패한다(PK) — 저장 전에 화면에서 한 번 걸러 준다.
   · **저장은 거래처관리와 같은 엔드포인트**(/vendor/insertVendorMst.do)를 쓴다.
     따로 만들면 두 곳의 규칙이 갈라진다.
   · CSS 는 이 파일이 자동 주입. jQuery 불필요(순수 JS).
   ===================================================================== */
(function () {
  if (window._vendorQuickLoaded) return;   // 중복 로드 방지
  window._vendorQuickLoaded = true;

  var CSS =
      '.vq-dim{position:fixed;inset:0;background:rgba(0,0,0,.35);z-index:9990;display:none;}'
    + '.vq-dim.on{display:block;}'
    + '.vq-box{background:#fff;width:min(560px,94vw);margin:8vh auto;border-radius:12px;'
    +   'box-shadow:0 18px 48px rgba(0,0,0,.28);font-family:"맑은 고딕","Malgun Gothic",sans-serif;color:#1f2a37;}'
    + '.vq-hd{padding:12px 16px;border-bottom:1px solid #dbe2ea;font-weight:800;font-size:15px;}'
    + '.vq-hd small{font-weight:600;color:#6b7c8c;font-size:12px;margin-left:6px;}'
    + '.vq-bd{padding:14px 16px;display:flex;flex-wrap:wrap;gap:10px;}'
    + '.vq-f{display:flex;flex-direction:column;gap:3px;flex:1 1 160px;}'
    + '.vq-f.w100{flex:1 1 100%;}'
    + '.vq-f label{font-size:12px;font-weight:700;}'
    + '.vq-f label i{color:#c0392b;font-style:normal;}'
    + '.vq-f input,.vq-f select{height:32px;border:1px solid #cfd8e3;border-radius:6px;padding:0 8px;font-size:13.5px;}'
    + '.vq-f input:focus,.vq-f select:focus{outline:none;border-color:#137a6c;}'
    + '.vq-msg{flex:1 1 100%;font-size:12.5px;color:#b45309;font-weight:700;min-height:17px;}'
    + '.vq-ft{padding:10px 16px;border-top:1px solid #dbe2ea;display:flex;gap:8px;justify-content:flex-end;}'
    + '.vq-btn{height:32px;border:1px solid #cfd8e3;background:#fff;border-radius:7px;padding:0 14px;'
    +   'cursor:pointer;font-size:13px;font-weight:700;color:#37475a;}'
    + '.vq-btn:hover{border-color:#137a6c;}'
    + '.vq-btn.teal{background:#137a6c;color:#fff;border-color:#137a6c;}';
  var st = document.createElement('style'); st.textContent = CSS; document.head.appendChild(st);

  var dim, opt = {};

  function el(id) { return document.getElementById(id); }
  function val(id) { var e = el(id); return e ? (e.value || '').trim() : ''; }

  /* 숫자로만 된 코드 중 가장 큰 값 + 1. 자리수는 지금 쓰는 코드에 맞춘다(대개 4자리) */
  function nextCd(list) {
    var max = 0, len = 4;
    (list || []).forEach(function (o) {
      var c = String(o.vendorCd || '');
      if (/^\d+$/.test(c)) { var v = parseInt(c, 10); if (v > max) { max = v; len = c.length; } }
    });
    var s = String(max + 1);
    while (s.length < len) s = '0' + s;
    return s;
  }

  function build() {
    dim = document.createElement('div');
    dim.className = 'vq-dim';
    dim.innerHTML =
        '<div class="vq-box">'
      +   '<div class="vq-hd">＋ 거래처 빠른등록 <small>필수만 넣고 바로 씁니다. 나머지는 [거래처관리]에서 채우세요.</small></div>'
      +   '<div class="vq-bd">'
      +     '<div class="vq-f"><label>거래처코드 <i>*</i></label><input id="vqCd" placeholder="예: 0089"></div>'
      +     '<div class="vq-f" style="flex:2 1 260px"><label>거래처명 <i>*</i></label><input id="vqNm" placeholder="거래처명"></div>'
      +     '<div class="vq-f"><label>거래유형 <i>*</i></label><select id="vqGb">'
      +       '<option value="매입">매입</option><option value="매출">매출</option><option value="매입&매출">매입&매출</option></select></div>'
      +     '<div class="vq-f"><label>부가세</label><select id="vqVat" title="이 거래처의 매입·판매 등록에서 부가세를 어떻게 계산할지 정합니다.">'
      +       '<option value="별도">별도 (단가 + 10%)</option>'
      +       '<option value="포함">포함 (단가 안에 10%)</option>'
      +       '<option value="면세">면세 (부가세 없음)</option></select></div>'
      +     '<div class="vq-f"><label>사업자등록번호</label><input id="vqBizno" placeholder="숫자만 또는 000-00-00000"></div>'
      +     '<div class="vq-f"><label>대표자</label><input id="vqCeo"></div>'
      +     '<div class="vq-f"><label>연락처</label><input id="vqTel"></div>'
      +     '<div class="vq-f"><label>담당자</label><input id="vqMgr"></div>'
      +     '<div class="vq-msg" id="vqMsg"></div>'
      +   '</div>'
      +   '<div class="vq-ft">'
      +     '<button type="button" class="vq-btn" id="vqCancel">취소</button>'
      +     '<button type="button" class="vq-btn teal" id="vqSave">저장하고 사용</button>'
      +   '</div>'
      + '</div>';
    document.body.appendChild(dim);

    dim.addEventListener('click', function (e) { if (e.target === dim) close(); });
    el('vqCancel').onclick = close;
    el('vqSave').onclick = save;
    dim.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') close();
      /* 엔터로 바로 저장 — 셀렉트에서는 목록을 여는 키라 제외 */
      if (e.key === 'Enter' && e.target.tagName === 'INPUT') { e.preventDefault(); save(); }
    });
  }

  function close() { if (dim) dim.classList.remove('on'); }

  function save() {
    var msg = el('vqMsg'); msg.textContent = '';
    var cd = val('vqCd'), nm = val('vqNm');
    if (!cd) { msg.textContent = '⚠ 거래처코드를 넣으세요.'; el('vqCd').focus(); return; }
    if (!nm) { msg.textContent = '⚠ 거래처명을 넣으세요.'; el('vqNm').focus(); return; }

    var list = (opt.list && opt.list()) || [];
    /* 같은 코드가 이미 있으면 서버 PK 오류로 떨어진다 — 미리 막고 다음 번호를 권한다 */
    if (list.some(function (o) { return String(o.vendorCd) === cd; })) {
      msg.textContent = '⚠ 이미 있는 거래처코드입니다. 다음 번호는 ' + nextCd(list) + ' 입니다.';
      el('vqCd').focus(); return;
    }
    if (list.some(function (o) { return String(o.vendorNm || '') === nm; })) {
      /* 이름이 같다고 막지는 않는다(지점·사업자가 다른 같은 이름이 실제로 있다). 알려만 준다 */
      msg.textContent = 'ℹ 같은 이름의 거래처가 이미 있습니다. 그래도 저장하려면 한 번 더 누르세요.';
      if (!el('vqSave').dataset.warned) { el('vqSave').dataset.warned = '1'; return; }
    }

    var dto = {
      vendorCd: cd, vendorNm: nm,
      vendorGb: val('vqGb') || null, vatGb: val('vqVat') || null,
      bizno: val('vqBizno') || null, ceoNm: val('vqCeo') || null,
      tel: val('vqTel') || null, mgrNm: val('vqMgr') || null
    };
    el('vqSave').disabled = true;
    fetch((opt.ctx || '') + '/vendor/insertVendorMst.do', {
      method: 'POST', credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(dto)
    })
      .then(function (res) { return res.text().then(function (t) { return { ok: res.ok, t: t }; }); })
      .then(function (r) {
        el('vqSave').disabled = false;
        if (!r.ok) { msg.textContent = '⚠ ' + ((r.t || '').trim() || '저장 실패'); return; }
        close();
        if (opt.onDone) opt.onDone(dto);
      })
      .catch(function (e) { el('vqSave').disabled = false; msg.textContent = '⚠ 통신오류: ' + e.message; });
  }

  /* 창 열기. name 을 주면 거래처명 칸에 미리 채운다(칸에 치다가 없어서 부른 경우) */
  window._vendorQuickOpen = function (o) {
    opt = o || {};
    if (!dim) build();
    var list = (opt.list && opt.list()) || [];
    el('vqCd').value = nextCd(list);
    el('vqNm').value = opt.name || '';
    el('vqGb').value = opt.gb || '매입';
    el('vqVat').value = '별도';
    ['vqBizno', 'vqCeo', 'vqTel', 'vqMgr'].forEach(function (id) { el(id).value = ''; });
    el('vqMsg').textContent = '';
    delete el('vqSave').dataset.warned;
    dim.classList.add('on');
    setTimeout(function () { el(opt.name ? 'vqCd' : 'vqNm').focus(); }, 30);
  };
})();
