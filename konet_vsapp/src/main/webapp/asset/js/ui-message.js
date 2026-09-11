/* =====================================================================
   공통 UI 메시지 (native alert/confirm 대체)
   ---------------------------------------------------------------------
   사용법: 페이지에 <script src="/asset/js/ui-message.js"></script> 한 줄만 추가
     · _toast(msg, type)            — 하단 토스트 (type: 'ok'|'warn'|'err'|'info')
     · _confirmBox({msg, icon, okText, okColor:'red'|'blue', onOk, onCancel})
     · _alertBox(msg, {icon, okText, okColor, onOk})  — 단일 버튼 알림
   · CSS·모달 HTML 은 이 파일이 자동 주입하므로 페이지에 따로 넣을 필요 없음
   · jQuery 불필요 (순수 JS) — 어느 페이지에서나 동작
   ===================================================================== */
(function(){
  if (window._uiMessageLoaded) return;   // 중복 로드 방지
  window._uiMessageLoaded = true;

  /* ── CSS 주입 ── */
  var CSS =
    '.toast-wrap{position:fixed;left:50%;bottom:34px;transform:translateX(-50%);z-index:10001;display:flex;flex-direction:column;gap:8px;align-items:center;pointer-events:none;}'
  + '.toast-item{min-width:180px;max-width:90vw;padding:12px 20px;border-radius:10px;color:#fff;font-size:15px;line-height:1.4;box-shadow:0 6px 22px rgba(0,0,0,.25);opacity:0;transform:translateY(12px);transition:opacity .2s,transform .2s;text-align:center;}'
  + '.toast-item.show{opacity:1;transform:translateY(0);}'
  + '.toast-ok{background:#198754;}.toast-warn{background:#fd7e14;}.toast-err{background:#dc3545;}.toast-info{background:#343a40;}'
  + '.cfm-backdrop{position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.45);z-index:10000;display:none;align-items:center;justify-content:center;}'
  + '.cfm-box{background:#fff;border-radius:16px;padding:26px 28px 20px;width:340px;max-width:90%;box-shadow:0 14px 44px rgba(0,0,0,.28);text-align:center;animation:cfmPop .18s ease-out;}'
  + '@keyframes cfmPop{from{transform:scale(.92);opacity:0;}to{transform:scale(1);opacity:1;}}'
  + '.cfm-icon{font-size:38px;line-height:1;margin-bottom:12px;}'
  + '.cfm-msg{font-size:16px;color:#333;line-height:1.55;margin-bottom:22px;}'
  + '.cfm-actions{display:flex;gap:8px;}'
  + '.cfm-btn{border:none;border-radius:10px;padding:11px 0;font-size:15px;font-weight:600;cursor:pointer;flex:1;transition:background .12s;}'
  + '.cfm-btn-cancel{background:#eef0f3;color:#444;}.cfm-btn-cancel:hover{background:#e2e5ea;}'
  + '.cfm-btn-ok{background:#dc3545;color:#fff;}.cfm-btn-ok:hover{background:#bb2d3b;}'
  + '.cfm-btn-ok.cfm-ok-blue{background:#0d6efd;}.cfm-btn-ok.cfm-ok-blue:hover{background:#0b5ed7;}';

  function injectCss(){
    if (document.querySelector('style[data-ui-message]')) return;
    var s = document.createElement('style');
    s.setAttribute('data-ui-message','1');
    s.textContent = CSS;
    (document.head || document.documentElement).appendChild(s);
  }

  /* ── 토스트 ── */
  window._toast = function(msg, type){
    var wrap = document.getElementById('toastWrap');
    if(!wrap){ wrap=document.createElement('div'); wrap.id='toastWrap'; wrap.className='toast-wrap'; document.body.appendChild(wrap); }
    var el = document.createElement('div');
    el.className = 'toast-item toast-' + (type||'info');
    el.innerHTML = msg;
    wrap.appendChild(el);
    requestAnimationFrame(function(){ el.classList.add('show'); });
    setTimeout(function(){ el.classList.remove('show'); setTimeout(function(){ if(el.parentNode) el.parentNode.removeChild(el); }, 230); }, 2300);
  };

  /* ── 확인 모달 DOM (한 번만 생성) ── */
  function ensureDom(){
    var bd = document.getElementById('confirmBackdrop');
    if (bd) return bd;
    bd = document.createElement('div');
    bd.id = 'confirmBackdrop';
    bd.className = 'cfm-backdrop';
    bd.innerHTML =
        '<div class="cfm-box">'
      +   '<div class="cfm-icon" id="confirmIcon">&#10067;</div>'
      +   '<div class="cfm-msg" id="confirmMsg"></div>'
      +   '<div class="cfm-actions">'
      +     '<button type="button" class="cfm-btn cfm-btn-cancel" id="confirmCancel">취소</button>'
      +     '<button type="button" class="cfm-btn cfm-btn-ok" id="confirmOk">확인</button>'
      +   '</div>'
      + '</div>';
    document.body.appendChild(bd);
    return bd;
  }

  /* ── 확인 (취소/확인 2버튼) ── */
  window._confirmBox = function(opts){
    opts = opts || {};
    var bd = ensureDom();
    var ok = document.getElementById('confirmOk');
    var cancel = document.getElementById('confirmCancel');
    document.getElementById('confirmMsg').innerHTML = opts.msg || '진행할까요?';
    document.getElementById('confirmIcon').textContent = opts.icon || '❓';
    ok.textContent = opts.okText || '확인';
    ok.classList.toggle('cfm-ok-blue', opts.okColor === 'blue');
    cancel.style.display = '';
    bd.style.display = 'flex';
    function close(){ bd.style.display='none'; ok.onclick=null; cancel.onclick=null; bd.onclick=null; }
    ok.onclick     = function(){ close(); if(typeof opts.onOk==='function') opts.onOk(); };
    cancel.onclick = function(){ close(); if(typeof opts.onCancel==='function') opts.onCancel(); };
    bd.onclick     = function(e){ if(e.target===bd) close(); };   // 바깥 클릭 = 취소
  };

  /* ── 알림 (확인 1버튼) ── */
  window._alertBox = function(msg, opts){
    opts = opts || {};
    var bd = ensureDom();
    var ok = document.getElementById('confirmOk');
    var cancel = document.getElementById('confirmCancel');
    document.getElementById('confirmMsg').innerHTML = msg || '';
    document.getElementById('confirmIcon').textContent = opts.icon || 'ℹ️';
    ok.textContent = opts.okText || '확인';
    ok.classList.toggle('cfm-ok-blue', opts.okColor !== 'red');   // 기본 파랑
    cancel.style.display = 'none';
    bd.style.display = 'flex';
    function close(){ bd.style.display='none'; ok.onclick=null; bd.onclick=null; cancel.style.display=''; }
    ok.onclick = function(){ close(); if(typeof opts.onOk==='function') opts.onOk(); };
    bd.onclick = function(e){ if(e.target===bd) close(); };
  };

  if (document.head) injectCss();
  else document.addEventListener('DOMContentLoaded', injectCss);
})();
