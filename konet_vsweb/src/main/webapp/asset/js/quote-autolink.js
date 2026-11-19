/* =====================================================================================================
   quote-autolink.js — 견적서 작성 ▸ [⚡ 자동연계 작성]   (2026-11-18 신설)

   사용자 요청 : 「견적서 작성 내용으로 사용자 품목코드, 배송 MOQ, 배송 단가 등 사용자 선택과 자동계산 내용을 파악해서
                 자동연계 견적서 작성 구성해줘(동판, 목형 포함) — 기존 내용은 그대로 유지하고 자동연계에서 기존 데이터에 안착하는 형식으로」

   ■ 하는 일
     품목을 고르고 <사람이 정하는 것>(품목 · 배송 MOQ수량 · 배송 단가 · 동판비 · 목형비 · 목표 마진율)만 넣으면,
     나머지 <자동으로 따라오는 것>을 채워 견적서 품목 줄로 만든다.
       · 연계(끌어오는 값) : 지난 견적서(★제출완료·채택만 — HIST_STAT)의 같은 품목 → 규격 · 제조사 · 박스 입수량 · 운송 · 보관 · 소분 · 박스 · 줄 물류비 · 목표 마진율 · 동판 · 목형 · MOQ 줄들
                            상품마스터 → 품명 · 규격 · 제조사 · 입수량 · 매입가(배송 단가) · 판매가
       · 계산(식은 견적서 작성 화면의 calcOf 그대로 — 여기서 다시 만들지 않는다) :
            금액 = 단가 × MOQ · 구단(계산) = 단가+운송+보관+소분+박스+원가 포함 동판·목형/개 · 필요 판매단가(목표 마진율) → 판매적용단가 · 물류비 · 실 마진율
   ■ 안착
     [⚡ 견적서에 넣기] = 견적서 작성 화면의 <지금 줄 밑에> 품목 줄(+MOQ 변형 줄 ↳)로 붙는다. 이미 적힌 줄은 건드리지 않는다.
     만들어지는 줄은 손으로 적은 줄과 <똑같은 자료>다({품명·규격·단가…, calc:{moqQty,buy,box,…,extras}}) — 그 뒤 고치기·저장·인쇄·엑셀·계산조회는 전부 종전 길 그대로.
     ⇒ 이 파일은 저장하지 않는다. 표(TBL_QUOTE_*)·저장 본문(CALC_JSON)·계산식은 하나도 안 바뀐다.

   ■ 기대는 것 (quoteEdit.jsp 의 전역) — 이 파일은 그 화면에서만 쓴다
       _lines · _cs · COST · n · fmt · esc · post · blank · newCalc · normCalc · calcOf · calcHasVal · calcHasFee · calcLineSync · moqRmkSync
       · renderLines · csRate · prodMastersLoad · _prodsAll · _extItems · gv · _alertBox · _confirmBox · _toast
       · prodOpen · prodPick · prodRender · _prodRows (묶음의 품명 옆 🔍 — 기존 「상품 찾기」 창을 그대로 쓴다 · alProd/hook)
     서버 : POST /mangr/quoteItemHist.do → { docs:[{quoteSeq,docNo,quoteDt,recvNm,mgrNm,statGb,calcJson}], lines:[{quoteSeq,rowNo,prodNm,spec,…}] }
            ★이 주소가 아직 없는 서버(재기동 전)에서도 창은 뜬다 — 지난 견적 연계만 빠지고 상품 찾기·직접 입력·자동계산은 그대로 된다.

   ⚠고칠 때 : ①계산식을 여기 베끼지 말 것(rowLine 으로 줄을 만들어 calcOf 에 태운다 — 두 벌이면 조용히 어긋난다)
             ②줄 모양을 바꾸면 quoteEdit 의 blank()/normCalc 와 같이 볼 것 ③고친 뒤 quoteEdit.jsp 의 ?v= 를 올릴 것(브라우저 캐시)
             ④시뮬 docs/tools/sim/sim_quoteAutoLink.js
   ===================================================================================================== */
(function(){
  if (window.alOpen) return;

  var AL = { loaded:false, loading:false, err:'', sets:[], items:[], blocks:[], hits:[], uid:0, recvF:null, docSig:'', q:'' };
  var ROUNDS = [['2','소수 둘째 자리 (그대로)'],['0.1','0.1원 단위로 올림'],['0.5','0.5원 단위로 올림'],['1','1원 단위로 올림'],['10','10원 단위로 올림']];
  var USES = [['off','적용 안 함'],['sub','별도 청구'],['cost','원가 포함']];
  var MODE_NM = { center:'센터배송', direct:'DC', parcel:'직송' };
  /* 끌어다 쓰는 지난 견적 = 제출완료(S)·채택(A)만 — 작성 중(W)·거절(R)·보류(H)는 내지 않았거나 받아들여지지 않은 값이다 */
  var HIST_STAT = { S:1, A:1 };
  var OPT = (function(){ var o={ round:'2', target:'' };
    try{ var s=JSON.parse(localStorage.getItem('konetQuoteAuto')||'null'); if(s){ if(s.round!=null) o.round=String(s.round); if(s.target!=null) o.target=s.target; } }catch(e){}
    if(!ROUNDS.some(function(r){ return r[0]===o.round; })) o.round='2';
    return o; })();
  function optSave(){ try{ localStorage.setItem('konetQuoteAuto', JSON.stringify(OPT)); }catch(e){} }

  function clone(o){ return JSON.parse(JSON.stringify(o)); }
  function nmKey(s){ return String(s||'').replace(/\s+/g,' ').trim().toLowerCase(); }
  function isFeeNm(s){ return /^(동판비|목형비)(\s|\(|$)/.test(String(s||'').trim()); }   /* 옛 견적서의 부대비 줄 — 품목이 아니다 */
  function moqFromRmk(s){ var m=/MOQ\s*([\d,\.]+)/i.exec(String(s||'')); return m? n(m[1]) : 0; }
  function d8(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
  function num(v,d){ return n(v)? fmt(v,d||0) : ''; }
  /* 동판비·목형비 두 줄은 늘 있게(옛 자료의 다른 이름 부대비는 뒤에 그대로 둔다) */
  function feeNorm(ex){
    var a=(ex||[]).map(function(x){ return { nm:String(x.nm||''), qty:n(x.qty), price:n(x.price), use:(x.use==='sub'||x.use==='cost')?x.use:'off', hide:false }; });
    var out=[]; ['동판비','목형비'].forEach(function(nm){ var k=-1; a.forEach(function(x,i){ if(k<0 && x.nm===nm) k=i; });
      out.push(k>=0 ? a.splice(k,1)[0] : { nm:nm, qty:0, price:0, use:'off', hide:false }); });
    return out.concat(a.filter(function(x){ return x.nm.trim() && (x.qty||x.price||x.use!=='off'); }));
  }

  /* ── 지난 견적 → 품목 이력 ──────────────────────────────────────────────────────────────
     견적서 작성 화면 loadDoc 과 같은 규칙 : genRows(동판·목형 서브 줄)는 걷어내고, 남은 줄 차례 = calcs 차례.
     품목 한 벌(set) = 품명 줄 + 그 밑 MOQ 변형 줄(calcs[].variant)들. 같은 품명의 벌들을 최근 것부터 item 으로 묶는다. */
  function buildHist(docs, lines){
    var by={}; (lines||[]).forEach(function(l){ var k=String(l.quoteSeq); (by[k]=by[k]||[]).push(l); });
    var sets=[];
    (docs||[]).forEach(function(d){
      if(!HIST_STAT[String(d.statGb||'W')]) return;   /* ★제출완료·채택만 (2026-11-18 사용자 「제출완료·채택된 견적만 보이게 해줘」) — 서버 조회(selectQuoteHistDocs)도 같은 조건 */
      var cj=null; try{ cj=JSON.parse(d.calcJson||'null'); }catch(e){}
      var gen={}; if(cj&&cj.genRows) cj.genRows.forEach(function(r){ gen[r]=true; });
      var ls=(by[String(d.quoteSeq)]||[]).slice().sort(function(a,b){ return n(a.rowNo)-n(b.rowNo); }).filter(function(l){ return !gen[l.rowNo]; });
      var cur=null;
      ls.forEach(function(l,idx){
        var raw=(cj&&cj.calcs)? cj.calcs[idx] : null, c=raw? normCalc(raw) : null, has=!!(c&&calcHasVal(c));
        var nm=String(l.prodNm||'').replace(/\s+/g,' ').trim();
        var row={ moqQty: (c&&n(c.moqQty)) ? n(c.moqQty) : (has ? 0 : (moqFromRmk(l.remark)||n(l.qty))),
                  buy: c?n(c.buy):0, buyMemo: c?String(c.buyMemo||''):'', target: c?n(c.target):0, sell: n(l.unitPrice), hasCalc: has,
                  base: { trans:c?n(c.trans):0, store:c?n(c.store):0, storeManual:!!(c&&c.storeManual), split:c?n(c.split):0, pack:c?n(c.pack):0,
                          lgFee:(c&&c.lgFee!==''&&c.lgFee!=null)? n(c.lgFee) : '', tgtAmt:c?n(c.tgtAmt):0 } };
        if(raw&&raw.variant&&cur){ cur.rows.push(row); return; }
        if(!nm || isFeeNm(nm)){ cur=null; return; }
        cur={ key:nmKey(nm), quoteSeq:d.quoteSeq, docNo:String(d.docNo||''), quoteDt:String(d.quoteDt||''), recvNm:String(d.recvNm||''), mgrNm:String(d.mgrNm||''), statGb:String(d.statGb||'W'),
              mode:(cj&&cj.set&&cj.set.mode)||'', fee:(cj&&cj.set)? n(cj.set.fee) : 0,
              makerNm:String(l.makerNm||''), prodNm:nm, spec:String(l.spec||''), unit:String(l.unit||'ea')||'ea', prodCd:String(l.prodCd||''),
              box: c?n(c.box):0, extras: feeNorm(c&&c.extras&&c.extras.length ? c.extras : null), rows:[row] };
        sets.push(cur);
      });
    });
    sets.sort(function(a,b){ return a.quoteDt===b.quoteDt ? n(b.quoteSeq)-n(a.quoteSeq) : (a.quoteDt<b.quoteDt?1:-1); });
    var map={}, items=[];
    sets.forEach(function(s){ var it=map[s.key]; if(!it){ it=map[s.key]={ key:s.key, prodNm:s.prodNm, sets:[], seqs:{} }; items.push(it); } it.sets.push(s); it.seqs[s.quoteSeq]=1; });
    items.forEach(function(it){ it.cnt=Object.keys(it.seqs).length;
      it.hay=(it.prodNm+' '+it.sets.map(function(s){ return [s.spec,s.makerNm,s.prodCd,s.recvNm,s.docNo].join(' '); }).join(' ')).toLowerCase(); });
    return { sets:sets, items:items };
  }

  /* ── 묶음(블록) : 품목 하나 + MOQ 줄들 ── */
  function newRow(prev){
    var r={ moqQty:0, buy:0, buyMemo:'', target:(OPT.target===''||OPT.target==null)? 0 : n(OPT.target), prevSell:0, prevNm:'', sellMan:false, sell:0,
            base:{ trans:0, store:0, storeManual:false, split:0, pack:0, lgFee:'', tgtAmt:0 } };
    if(prev){ r.target=n(prev.target); r.base=clone(prev.base); r.base.tgtAmt=0; }   /* ＋MOQ = 윗줄 조건을 물려받아 MOQ수량·단가만 새로 (견적서 작성의 ＋MOQ 와 같다) */
    return r;
  }
  function blkNew(){ return { id:++AL.uid, src:'n', item:null, setIdx:-1, makerNm:'', prodNm:'', spec:'', unit:'ea', prodCd:'', box:0, extras:feeNorm(null), rows:[newRow()], note:'' }; }
  function blkFill(b, s){
    b.makerNm=s.makerNm; b.prodNm=s.prodNm; b.spec=s.spec; b.unit=s.unit||'ea'; b.prodCd=s.prodCd; b.box=n(s.box); b.extras=clone(s.extras);
    b.rows=s.rows.map(function(r){ return { moqQty:n(r.moqQty), buy:n(r.buy), buyMemo:r.buyMemo||'', target:n(r.target), prevSell:n(r.sell), prevNm:'지난 견적', sellMan:false, sell:0, base:clone(r.base) }; });
    if(!b.rows.length) b.rows=[newRow()];
    b.sigMode=s.mode||''; b.sigFee=n(s.fee); b.rows.forEach(function(r){ r.sig=sigOf(b, r); });   /* 그때 조건 — 하나도 안 바꾸면 그때 단가를 그대로 쓴다(rowCalc) */
    return b;
  }
  function blkFromItem(it, k){ var b=blkNew(); b.src='h'; b.item=it; b.setIdx=k||0; return blkFill(b, it.sets[b.setIdx]); }
  function blkFromProd(p){
    var b=blkNew(); b.src='p'; b.makerNm=String(p.makerNm||''); b.prodNm=String(p.prodNm||''); b.spec=String(p.spec||''); b.prodCd=String(p.prodCd||'');
    b.box=n(p.packQty)>1 ? n(p.packQty) : 0;
    b.rows[0].buy=n(p.inPrice); b.rows[0].prevSell=n(p.salePrice); b.rows[0].prevNm='상품 판매가';
    return b;
  }

  /* ── 계산 — 견적서 작성 화면의 calcOf 에 그대로 태운다 ── */
  function rowLine(b, r, sell){
    return { variant:false, unitPrice:n(sell), unitPrice2:0, boxQty:1, qty:0,
             calc: normCalc({ moqQty:n(r.moqQty), buy:n(r.buy), buyMemo:String(r.buyMemo||''), box:n(b.box), trans:n(r.base.trans), store:n(r.base.store), storeManual:!!r.base.storeManual,
                              split:n(r.base.split), pack:n(r.base.pack), target:n(r.target), tgtAmt:n(r.base.tgtAmt), lgFee:r.base.lgFee, extras:b.extras }) };
  }
  function sigOf(b, r){ return JSON.stringify([ n(r.moqQty), n(r.buy), n(r.target), n(b.box), n(r.base.trans), r.base.storeManual? n(r.base.store) : 'auto', n(r.base.split), n(r.base.pack),
      r.base.lgFee===''? '' : n(r.base.lgFee), (b.extras||[]).map(function(x){ return [x.nm, n(x.qty), n(x.price), x.use]; }) ]); }
  function roundSell(x){ x=n(x); if(!x) return 0; if(OPT.round==='2') return Math.round(x*100)/100; var u=n(OPT.round)||1; return Math.round(Math.ceil(x/u - 1e-7)*u*100)/100; }
  /* 판매적용단가 : ①직접 적었으면 그 값 ②배송 단가·목표 마진율이 있고 구매 계가 서면 필요 판매단가(올림 단위 적용) ③아니면 지난 견적 단가·상품 판매가
     ⚠②에 «배송 단가가 있을 때»를 건 까닭 — 단가는 비었는데 원가 포함 동판·목형만 있으면 구매 계가 그 몫(금액÷MOQ)만으로 서서 4원 같은 엉뚱한 판매단가가 나온다 */
  function rowCalc(b, r){
    var c0=calcOf(rowLine(b, r, 0)), auto=0, how='';
    var can=!!(c0 && c0.I && n(r.target) && n(r.buy));
    /* ★지난 견적에서 끌어온 줄을 <하나도 안 바꿨으면> 그때 단가 그대로 (2026-11-18 운영 자료 실측 — 목표 마진율로 다시 내면 그때 단가와 다른 줄이 153줄 중 75줄 :
         담당자가 필요 판매단가 70.66 을 71 로, 26.67 을 28 로 손봐서 낸 것이다. 같은 조건인데 단가가 조용히 바뀌면 이미 나간 견적과 어긋난다).
       MOQ수량·배송 단가·운송·보관·소분·박스·입수량·목표 마진율·동판·목형 중 하나라도 바꾸거나 물류비 갈래가 그때와 다르면 필요 판매단가로 다시 계산한다. */
    var same=!!(r.sig && n(r.prevSell) && r.sig===sigOf(b, r) && (!b.sigMode || (b.sigMode===_cs.mode && (b.sigMode!=='parcel' || n(b.sigFee)===n(_cs.fee)))));   /* 직송은 직송비/박스까지 같아야 「그때와 같다」 */
    if(same){ auto=n(r.prevSell); how='same'; }
    else if(can){ auto=roundSell(c0.need); how='need'; }
    else if(n(r.prevSell)){ auto=n(r.prevSell); how='prev'; }
    var sell=r.sellMan ? n(r.sell) : auto;
    return { c:calcOf(rowLine(b, r, sell)), need:can? c0.need : 0, auto:auto, how:how, sell:sell };
  }
  function modeTxt(){
    if(_cs.mode==='center') return '센터배송 · 기준 '+_cs.center+' '+fmt(csRate(),1)+'%';
    if(_cs.mode==='direct') return 'DC '+fmt(COST.dcRate,1)+'%';
    return '직송 · 직송비/박스 '+fmt(_cs.fee)+'원';
  }
  function modeNmOf(s){ return s.mode==='parcel' ? '직송 · 직송비/박스 '+fmt(s.fee)+'원' : (MODE_NM[s.mode]||s.mode); }
  /* 지난 견적의 물류비 갈래로 이 견적서를 맞춘다 — 품목 표 위 라디오를 누른 것과 같은 길(csBarPaint·renderLines·delivByMode).
     갈래는 견적서 한 장에 하나라 이미 계산이 든 줄이 있으면 그 줄의 물류비·마진도 같이 바뀐다 → 그때는 먼저 묻는다 */
  window.alModeMatch=function(bi){
    var b=AL.blocks[bi]; if(!b||!b.item) return; var s=b.item.sets[b.setIdx]; if(!s||!s.mode) return;
    var go=function(){
      _cs.mode=s.mode; if(s.mode==='parcel') _cs.fee=n(s.fee);
      csBarPaint(); renderLines(); if(typeof delivByMode==='function') delivByMode();
      paintAll(); if(window._toast) _toast('견적서의 물류비 갈래를 '+modeNmOf(s)+'(으)로 바꿨습니다.','ok');
    };
    var cnt=_lines.filter(function(l){ return l.calc && calcHasVal(l.calc); }).length;
    if(cnt) _confirmBox({ msg:'견적서의 물류비 갈래를 <b>'+esc(modeNmOf(s))+'</b>(으)로 바꿀까요?<br><span style="font-size:12.5px;color:#3d4d5c">갈래는 견적서 한 장에 하나입니다 — 이미 계산이 든 <b>'+cnt+'</b>줄의 물류비·실 마진율도 함께 바뀝니다(단가는 그대로).</span>', icon:'🧮', okText:'바꾸기', onOk:go, onCancel:function(){} });
    else go();
  };
  function lgCol(){ return _cs.mode!=='center'; }   /* 줄 물류비 직접 입력 칸 — 견적서 작성과 같이 DC·직송 갈래에서만 */

  /* ── 창 ── */
  function css(){
    if(document.getElementById('alCss')) return;
    var st=document.createElement('style'); st.id='alCss';
    st.textContent=
      '#alPop{ padding-top:3vh; }'
     +'#alPop > .box{ width:min(1500px,98vw); max-height:93vh; }'
     +'#alPop .ph b{ font-size:15px; color:#125a4e; white-space:nowrap; }'
     +'#alPop .al-opt{ display:flex; gap:14px; align-items:center; flex-wrap:wrap; padding:7px 14px; border-bottom:1px solid #eef1f5; font-size:13px; background:#f7faf9; }'
     +'#alPop .al-opt select, #alPop .al-opt input{ height:30px; border:1px solid var(--bd); border-radius:7px; padding:0 6px; font-size:13px; background:#fff; }'
     +'#alPop .al-opt .md{ font-weight:800; color:#125a4e; }'
     +'#alPop .al-find{ display:flex; gap:8px; align-items:center; padding:8px 14px; border-bottom:1px solid #eef1f5; flex-wrap:wrap; }'
     +'#alPop .al-find input[type=text]{ flex:1; min-width:260px; height:34px; border:1.5px solid #0f6b5e; border-radius:7px; padding:0 10px; font-size:14px; }'
     +'#alPop .al-find select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 6px; font-size:13px; }'
     +'#alPop .al-hits{ max-height:26vh; overflow:auto; border-bottom:2px solid #cfe0da; }'
     +'#alPop .al-hits td{ font-size:12.5px; padding:4px 6px; } #alPop .al-hits td.l{ text-align:left; }'
     +'#alPop .al-hits tr.stop td{ opacity:.45; }'
     +'#alPop .al-hits{ flex:0 1 auto; min-height:0; } #alPop .kgg{ flex:none; margin-top:0; border-radius:0; border-bottom:1px solid #dbe2ea; }'   /* 목록 높이 막대 (2026-11-19) — 막대는 눌리지 않게 */
     +'#alPop .tg{ display:inline-block; border-radius:10px; padding:1px 8px; font-size:11.5px; font-weight:800; white-space:nowrap; }'
     +'#alPop .tg.h{ background:#e3f2ee; color:#0f6b5e; border:1px solid #9fcfc3; } #alPop .tg.p{ background:#eaf0fb; color:#2f4f9a; border:1px solid #b5c6e8; } #alPop .tg.n{ background:#f3f5f8; color:#4a5a6a; border:1px solid #cdd6df; }'
     +'#alPop .al-body{ overflow:auto; padding:10px 14px; background:#f5f7f9; flex:1; min-height:120px; }'
     +'#alPop .al-empty{ padding:26px 10px; text-align:center; color:#6b7a89; font-size:13.5px; line-height:1.8; }'
     +'#alPop .al-blk{ background:#fff; border:1px solid #c9d3dc; border-left:5px solid #0f6b5e; border-radius:9px; margin-bottom:10px; }'
     +'#alPop .al-bh{ display:flex; gap:6px; align-items:center; flex-wrap:wrap; padding:7px 10px; border-bottom:1px solid #eef1f5; }'
     +'#alPop .al-no{ display:inline-flex; width:24px; height:24px; border-radius:50%; background:#0f6b5e; color:#fff; font-weight:800; font-size:12.5px; align-items:center; justify-content:center; flex:none; }'
     +'#alPop .al-in{ height:30px; border:1px solid var(--bd); border-radius:6px; padding:0 7px; font-size:13px; }'
     +'#alPop .al-in.nm{ flex:1 1 220px; min-width:180px; font-weight:800; border-color:#0f6b5e; }'
     +'#alPop .al-lb{ font-size:12px; color:#4a5a6a; font-weight:700; white-space:nowrap; }'
     +'#alPop .al-src{ font-size:12px; color:#3d4d5c; white-space:nowrap; } #alPop .al-src select{ height:28px; border:1px solid var(--bd); border-radius:6px; font-size:12px; max-width:330px; }'
     +'#alPop .al-fee{ display:flex; gap:18px; align-items:center; flex-wrap:wrap; padding:6px 10px; border-bottom:1px solid #eef1f5; background:#fffdf5; font-size:13px; }'
     +'#alPop .al-fee .fx{ display:inline-flex; gap:5px; align-items:center; white-space:nowrap; } #alPop .al-fee .fx b{ color:#8a5200; }'
     +'#alPop .al-fee select{ height:28px; border:1px solid var(--bd); border-radius:6px; font-size:12.5px; }'
     +'#alPop .al-fee .fa{ min-width:70px; text-align:right; font-weight:800; color:#8a5200; font-variant-numeric:tabular-nums; }'
     +'#alPop input.ci{ height:28px; border:1.5px solid #e9b98a; background:#fdebd9; text-align:right; border-radius:6px; padding:0 5px; width:74px; font-size:13px; font-variant-numeric:tabular-nums; }'
     +'#alPop input.cm{ height:28px; background:#fff3c4; border:1.5px solid #e2b93b; text-align:right; border-radius:6px; padding:0 5px; width:74px; font-size:13px; font-variant-numeric:tabular-nums; }'
     +'#alPop input.ca{ height:28px; background:#eef1f5; border:1px dashed #b9c4d0; text-align:right; border-radius:6px; padding:0 5px; color:#4a5a6a; width:74px; font-size:13px; font-variant-numeric:tabular-nums; }'
     +'#alPop table.al-t{ width:auto; min-width:100%; } #alPop table.al-t th{ position:static; font-size:12px; padding:5px 6px; } #alPop table.al-t th.u{ background:#fdebd9 !important; } #alPop table.al-t th.a{ background:#e9eef3 !important; }'
     +'#alPop table.al-t td{ padding:3px 4px; white-space:nowrap; } #alPop table.al-t input[type=text]{ width:74px; }'
     +'#alPop table.al-t td.au{ background:#f3f5f8; color:#2b3a49; font-weight:700; text-align:right; padding-right:7px; font-variant-numeric:tabular-nums; min-width:70px; }'
     +'#alPop table.al-t td.au.b{ color:#2f4f9a; background:#eef2f8; font-weight:800; } #alPop table.al-t td.au.s{ background:#e3f7df; font-weight:800; } #alPop table.al-t td.au.p{ background:#d9ecf7; } #alPop .neg{ color:#c0392b; }'
     +'#alPop table.al-t td.pv{ font-size:12px; color:#4a5a6a; text-align:right; }'
     +'#alPop .al-bf{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; padding:6px 10px; font-size:12.5px; }'
     +'#alPop .al-warn{ color:#b45309; font-weight:700; } #alPop .al-info{ color:#4a5a6a; }'
     +'#alPop .al-ft{ display:flex; gap:10px; align-items:center; flex-wrap:wrap; padding:10px 14px; border-top:1px solid #dbe2ea; background:#fff; }'
     +'#alPop .al-ft .sum{ font-size:13.5px; color:#1f2a37; } #alPop .al-ft .keep{ font-size:12.5px; color:#0f6b5e; font-weight:700; }'
     +'#alPop .xb{ height:24px; padding:0 5px; font-size:11.5px; }'
     +'@keyframes alflash{ 0%{ background:#ffe9a8; } 100%{ background:transparent; } }'
     +'#alSug{ position:fixed; z-index:1050; display:none; background:#fff; border:1.5px solid #0f6b5e; border-radius:8px; box-shadow:0 10px 30px rgba(0,0,0,.28); max-height:320px; overflow:auto; font-size:12.5px; }'
     +'#alSug.on{ display:block; }'
     +'#alSug .sr{ display:flex; gap:8px; align-items:center; padding:5px 9px; cursor:pointer; border-bottom:1px solid #eef1f5; white-space:nowrap; }'
     +'#alSug .sr:hover, #alSug .sr.cur{ background:#e3f2ee; }'
     +'#alSug .sr .nm{ font-weight:800; color:#1f2a37; } #alSug .sr .sp{ color:#4a5a6a; overflow:hidden; text-overflow:ellipsis; max-width:300px; } #alSug .sr .ex{ color:#2f4f9a; margin-left:auto; padding-left:14px; } #alSug .sr .dt{ color:#6b7a89; } #alSug .sr .mk{ color:#8a5200; font-weight:700; }'
     +'#alSug .tg{ display:inline-block; border-radius:10px; padding:1px 8px; font-size:11.5px; font-weight:800; flex:none; } #alSug .tg.h{ background:#e3f2ee; color:#0f6b5e; border:1px solid #9fcfc3; } #alSug .tg.p{ background:#eaf0fb; color:#2f4f9a; border:1px solid #b5c6e8; }'
     +'#alSug .sf{ padding:4px 9px; color:#6b7a89; font-size:11.5px; background:#f7faf9; position:sticky; bottom:0; }'
     +'table.g tr.al-new > td{ animation:alflash 3.2s ease-out 1; }';
    (document.head||document.documentElement).appendChild(st);
  }
  function build(){
    if(document.getElementById('alPop')) return;
    css();
    var d=document.createElement('div'); d.className='pop'; d.id='alPop';
    d.innerHTML=
      '<div class="box">'
     +'<div class="ph"><b>⚡ 자동연계 견적 작성</b><span class="dim" style="flex:1;font-size:12.5px" title="품목 · 배송 MOQ수량 · 배송 단가 · 동판·목형만 정하면 나머지는 지난 견적·상품에서 끌어와 계산합니다. 견적서에 이미 적힌 줄은 그대로 두고 그 밑에 붙습니다">품목·MOQ·단가만 넣으면 나머지는 자동 — <b style="color:#0f6b5e">기존 줄 밑에</b> 붙습니다</span>'
     +'<button class="btn" onclick="alClose()">닫기 ✕</button></div>'
     +'<div class="al-opt">'
     +'<span title="견적서 한 장에 하나 — 품목 표 위 「🧮 마진계산 물류비」에서 바꿉니다. 여기 계산도 그 값을 씁니다">🧮 물류비 <span class="md" id="alMode"></span></span>'
     +'<span title="필요 판매단가를 판매적용단가로 넣을 때의 자릿수 — 「그대로」는 견적서 작성의 [→] 와 같습니다(소수 둘째 자리 반올림). 올림을 고르면 그 단위로 올려 넣고 실 마진율을 다시 보여 줍니다">판매단가 자릿수 <select id="alRound" onchange="alOpt(\'round\', this.value)"></select></span>'
     +'<span title="새로 넣는 품목·MOQ 줄의 목표 마진율 기본값 — 지난 견적에서 끌어온 줄은 그때 값을 그대로 씁니다">목표 마진율 기본 <input type="text" id="alTgt" style="width:60px;text-align:right" onfocus="this.select()" oninput="alOpt(\'target\', this.value)"> %</span>'
     +'<span class="dim" style="font-size:12px;margin-left:auto" title="주황 = 사람이 넣는 칸 · 회색 점선 = 자동으로 끌어온 값(고치면 노랑) · 회색 = 계산"><span style="display:inline-block;width:12px;height:12px;background:#fdebd9;border:1.5px solid #e9b98a;border-radius:3px;vertical-align:-2px"></span> 넣는 칸 · <span style="display:inline-block;width:12px;height:12px;background:#eef1f5;border:1px dashed #b9c4d0;border-radius:3px;vertical-align:-2px"></span> 자동(고치면 <span style="background:#fff3c4;border:1px solid #e2b93b;border-radius:3px;padding:0 3px">노랑</span>) · <span style="display:inline-block;width:12px;height:12px;background:#f3f5f8;border:1px solid #cdd6df;border-radius:3px;vertical-align:-2px"></span> 계산</span>'
     +'</div>'
     +'<div class="al-find"><b style="color:#125a4e;white-space:nowrap">① 품목 고르기</b>'
     +'<input type="text" id="alQ" placeholder="품명 · 규격 · 제조사 · 상품코드 · 문서번호" title="비우면 최근 견적 품목 · 띄어 쓰면 낱말이 모두 든 것 · 지난 견적은 제출완료·채택된 것만" oninput="alSearch()" onkeydown="alKey(event)">'
     +'<select id="alRecv" onchange="alRecvSet(this.value)" title="지난 견적 품목을 수신처로 거릅니다(단가는 수신처마다 다를 수 있습니다) — 상품마스터 결과는 거르지 않습니다"></select>'
     +'<button class="btn" onclick="alNewBlock()" title="지난 견적·상품에 없는 새 품목 — 빈 묶음을 만들어 직접 적습니다">＋ 새 품목 직접 입력</button>'
     +'<span class="dim" id="alLoad" style="font-size:12px"></span></div>'
     +'<div class="al-hits" id="alHitsWrap"><table class="g"><thead><tr><th style="width:86px">출처</th><th>상품코드</th><th>제조사</th><th>품명</th><th>규격</th><th>입수</th><th>MOQ → 배송 단가</th><th>판매단가</th><th>동판·목형</th><th>최근 견적</th></tr></thead><tbody id="alHits"></tbody></table></div>'
     +'<div class="al-body" id="alBody"></div>'
     +'<div class="al-ft"><span class="sum" id="alSum"></span><span class="keep" id="alKeep"></span>'
     +'<button class="btn" style="margin-left:auto" onclick="alClear()" title="아래 묶음을 모두 지웁니다(견적서에는 아무 영향 없음)">비우기</button>'
     +'<button class="btn btn-teal" id="alGo" style="font-size:14.5px;height:38px;padding:0 20px" onclick="alApply()">⚡ 견적서에 넣기</button></div>'
     +'</div>';
    document.body.appendChild(d);
    /* ★품목 목록 높이 막대 (2026-11-19 사용자 「여기도 막대 표시 확대·축소되게」) — 판매·매입·견적서 품목 표와 같은 공용 막대(ui-gridgrip.js).
       목록과 아래 묶음 영역 사이에 붙는다 : 아래로 끌면 목록이 늘고(묶음 영역이 그만큼 준다) 위로 끌면 준다 · 더블클릭 = 처음 높이(26vh) ·
       높이는 localStorage('konetGridH.quoteAutoHits') 에 남는다. 창이 93vh 를 넘지 못하므로 너무 늘리면 목록이 창 안에서 멈춘다(묶음 영역은 120px 는 남는다) */
    if(window.konetGridGrip) konetGridGrip('alHitsWrap', 'alHitsWrap', 'quoteAutoHits');
    var sg=document.createElement('div'); sg.id='alSug'; document.body.appendChild(sg);   /* 품명 칸에 치는 대로 뜨는 목록 (2026-11-18) */
    var bd=document.getElementById('alBody'); if(bd) bd.addEventListener('scroll', function(){ alSugHide(); });   /* 묶음 영역을 굴리면 칸과 떨어지므로 닫는다 */
    var rs=document.getElementById('alRound'); rs.innerHTML=ROUNDS.map(function(r){ return '<option value="'+r[0]+'">'+r[1]+'</option>'; }).join(''); rs.value=OPT.round;
    document.getElementById('alTgt').value=(OPT.target===''||OPT.target==null)? '' : fmt(OPT.target,1);
  }

  function locked(){ return document.body.classList.contains('qlock'); }
  function docSig(){ return String(typeof _seq==='number'? _seq : 0)+'|'+(document.getElementById('docNo')? gv('docNo') : ''); }

  window.alOpen=function(){
    if(locked()){ _alertBox('잠긴 견적서입니다 — 위 띠에서 잠금을 풀거나 최신 판을 연 뒤에 쓰세요.',{icon:'🔒'}); return; }
    build();
    var sig=docSig(); if(AL.docSig && AL.docSig!==sig) AL.blocks=[];   /* 다른 견적서를 열었으면 만들던 묶음은 비운다 */
    AL.docSig=sig;
    document.getElementById('alMode').textContent=modeTxt();
    document.getElementById('alPop').classList.add('on');
    paintAll(); hits();
    var q=document.getElementById('alQ'); try{ q.focus(); }catch(e){}
    histLoad(); prodMastersLoad(function(){ hits(); });
  };
  window.alClose=function(){ var p=document.getElementById('alPop'); if(p) p.classList.remove('on'); alSugHide(); };
  window.alKey=function(ev){ if(ev.key==='Escape' && !ev.isComposing) alClose(); };

  function histLoad(){
    if(AL.loading) return; AL.loading=true; loadTxt();
    post('/mangr/quoteItemHist.do','').then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); }).then(function(j){
      var h=buildHist((j&&j.docs)||[], (j&&j.lines)||[]);
      AL.sets=h.sets; AL.items=h.items; AL.loaded=true; AL.err=''; AL.loading=false;
      /* 묶음이 붙들고 있던 이력(item)을 새로 읽은 것으로 갈아 준다 — 출처 고르기가 옛 목록을 가리키지 않게 */
      AL.blocks.forEach(function(b){ if(b.src!=='h'||!b.item) return; var cur=b.item.sets[b.setIdx], it=null; AL.items.forEach(function(x){ if(x.key===b.item.key) it=x; });
        if(!it){ return; } var k=-1; it.sets.forEach(function(s,i){ if(cur && String(s.quoteSeq)===String(cur.quoteSeq) && k<0) k=i; }); b.item=it; b.setIdx=k<0?0:k; });
      recvFill(); loadTxt(); hits(); paintAll();
    }).catch(function(e){ AL.loading=false; AL.err='지난 견적을 불러오지 못했습니다'; loadTxt(); hits(); });
  }
  function loadTxt(){ var e=document.getElementById('alLoad'); if(!e) return;
    e.textContent = AL.loading&&!AL.loaded ? '지난 견적을 읽는 중…' : (AL.err ? '⚠ '+AL.err : (AL.loaded ? '지난 견적 품목 '+fmt(AL.items.length)+'종 (제출완료·채택)' : '')); e.style.color=AL.err?'#b45309':''; }
  function recvFill(){
    var s=document.getElementById('alRecv'); if(!s) return;
    var cnt={}, ord=[]; AL.sets.forEach(function(x){ var k=x.recvNm||''; if(!k) return; if(!cnt[k]){ cnt[k]={}; ord.push(k); } cnt[k][x.key]=1; });
    ord.sort(function(a,b){ return Object.keys(cnt[b]).length-Object.keys(cnt[a]).length; });
    if(AL.recvF==null){ var cur=(document.getElementById('recvNm')? gv('recvNm') : ''); AL.recvF=(cur && cnt[cur]) ? cur : ''; }   /* 처음 = 지금 견적서의 수신처(이력이 있을 때만) */
    if(AL.recvF && !cnt[AL.recvF]) AL.recvF='';
    s.innerHTML='<option value="">수신 전체</option>'+ord.map(function(k){ return '<option value="'+esc(k)+'">'+esc(k)+' ('+Object.keys(cnt[k]).length+'종)</option>'; }).join('');
    s.value=AL.recvF;
  }
  window.alRecvSet=function(v){ AL.recvF=v||''; hits(); };
  var _qt=null;
  window.alSearch=function(){ clearTimeout(_qt); _qt=setTimeout(hits, 120); };

  /* ── ① 품목 고르기 결과 : 지난 견적(먼저) + 상품마스터 ── */
  function setOf(it){ if(!AL.recvF) return 0; for(var i=0;i<it.sets.length;i++) if(it.sets[i].recvNm===AL.recvF) return i; return -1; }
  function feeTxt(ex){ return (ex||[]).filter(function(x){ return n(x.qty)*n(x.price); }).map(function(x){
      return esc(x.nm.replace(/비$/,''))+' '+fmt(n(x.qty)*n(x.price))+(x.use==='sub'?'(별도)':(x.use==='cost'?'(원가)':'(미적용)')); }).join(' · '); }
  function hits(){
    var tb=document.getElementById('alHits'); if(!tb) return;
    var q=(document.getElementById('alQ').value||'').trim().toLowerCase(), tk=q? q.split(/\s+/) : [], out=[];
    var all=function(h){ return tk.every(function(t){ return h.indexOf(t)>=0; }); };
    AL.items.forEach(function(it){ var k=setOf(it); if(k<0) return; if(tk.length && !all(it.hay)) return; out.push({ t:'h', it:it, k:k }); });
    out.sort(function(a,b){ var x=a.it.sets[a.k], y=b.it.sets[b.k]; return x.quoteDt===y.quoteDt ? n(y.quoteSeq)-n(x.quoteSeq) : (x.quoteDt<y.quoteDt?1:-1); });
    out=out.slice(0, tk.length?80:40);
    if(tk.length && window._prodsAll){
      var ext={}; (window._extItems||[]).forEach(function(e){ if(e.prodCd && all([e.extItemCd,e.extItemNm,e.extSpec].join(' ').toLowerCase())) ext[String(e.prodCd)]=1; });
      var ps=_prodsAll.filter(function(p){ return ext[String(p.prodCd)] || all([p.prodCd,p.prodNm,p.spec,p.makerNm].join(' ').toLowerCase()); }).slice(0,80);
      ps.forEach(function(p){ out.push({ t:'p', p:p }); });
    }
    AL.hits=out;
    if(!out.length){
      tb.innerHTML='<tr><td colspan="10" class="dim" style="padding:16px">'+(tk.length ? '맞는 품목 없음 — [＋ 새 품목 직접 입력]'
        : (AL.loaded ? (AL.recvF?'이 수신처의 지난 견적 품목 없음 — 「수신 전체」로 바꿔 보세요.':'지난 견적 품목 없음 — 글자를 치면 상품에서 찾습니다.') : (AL.err? esc(AL.err)+' — 글자를 치면 상품에서 찾습니다.' : '불러오는 중…')))+'</td></tr>';
      return;
    }
    tb.innerHTML=out.map(function(h,i){
      if(h.t==='p'){ var p=h.p, stop=p.stopYn==='Y';
        return '<tr class="'+(stop?'stop':'pick')+'"'+(stop?' title="거래중지 상품 — 고를 수 없습니다"':' onclick="alPick('+i+')"')+'><td><span class="tg p">상품</span></td><td>'+esc(p.prodCd||'')+(stop?' <span style="color:#c0392b;font-size:11px">중지</span>':'')+'</td><td>'+esc(p.makerNm||'')+'</td><td class="l">'+esc(p.prodNm||'')+'</td><td class="l">'+esc(p.spec||'')+'</td>'
          +'<td>'+num(p.packQty)+'</td><td>'+(n(p.inPrice)?'매입가 '+fmt(p.inPrice,2):'')+'</td><td>'+(n(p.salePrice)?fmt(p.salePrice,2):'')+'</td><td></td><td></td></tr>'; }
      var it=h.it, s=it.sets[h.k];
      var mq=s.rows.slice(0,3).map(function(r){ return (n(r.moqQty)?fmt(r.moqQty):'–')+' → '+(n(r.buy)?fmt(r.buy,2):'–'); }).join(' / ')+(s.rows.length>3?' …':'');
      var sp=s.rows.slice(0,3).map(function(r){ return n(r.sell)?fmt(r.sell,2):'–'; }).join(' / ')+(s.rows.length>3?' …':'');
      return '<tr class="pick" onclick="alPick('+i+')"><td><span class="tg h" title="이 품명이 든 지난 견적서 수(제출완료·채택된 견적만 셉니다)">견적 '+it.cnt+'회</span></td><td>'+esc(s.prodCd)+'</td><td>'+esc(s.makerNm)+'</td><td class="l">'+esc(s.prodNm)+'</td><td class="l">'+esc(s.spec)+'</td>'
        +'<td>'+num(s.box)+'</td><td>'+mq+'</td><td>'+sp+'</td><td>'+feeTxt(s.extras)+'</td><td style="white-space:nowrap">'+esc(d8(s.quoteDt).slice(5))+' '+esc(s.recvNm)+' <span class="dim">'+esc(s.docNo)+'</span></td></tr>';
    }).join('');
  }
  window.alPick=function(i){
    var h=AL.hits[i]; if(!h) return;
    var b = h.t==='p' ? blkFromProd(h.p) : blkFromItem(h.it, h.k);
    var same=AL.blocks.filter(function(x){ return nmKey(x.prodNm)===nmKey(b.prodNm); }).length;
    AL.blocks.push(b); paintAll(); scrollBlk(AL.blocks.length-1);
    if(same && window._toast) _toast('같은 품명을 한 번 더 담았습니다.','warn');
  };
  window.alNewBlock=function(){ var b=blkNew(); var q=(document.getElementById('alQ').value||'').trim(); if(q) b.prodNm=q; AL.blocks.push(b); paintAll(); scrollBlk(AL.blocks.length-1, true); };
  /* ★품명 · 규격 · 제조사 · 상품코드 칸에 직접 쳐도 찾는다 (2026-11-18 사용자 「품명 직접 입력해도 검색되게 해줘」 → 「규격도 …」 → 「제조사도 …」 → 「상품코드도 직접 입력하면 검색되게 해줘」 — 네 칸이 같은 목록·같은 키를 쓴다.
     상품코드 칸만 찾는 차례가 다르다(sugFind 의 cd — 상품 먼저·코드순) · 그 칸은 떠날 때 종전대로 마스터와 대조한다(alCode : 없는 코드는 안 받는다)) —
     치는 대로 그 칸 바로 밑에 «지난 견적 품목 + 상품마스터»가 뜨고(위 ① 품목 고르기와 같은 찾기 규칙 : 띄어 쓴 낱말이 모두 든 것 · 매칭코드 포함),
     고르면 <이 묶음>이 그 값으로 채워진다(새 묶음을 만들지 않는다). 지난 견적 = MOQ 줄·단가·운송·보관·동판·목형까지(blkFill) · 상품 = 품명·규격·제조사·코드·입수량(prodFill — 단가는 빈 칸만).
     · ↓↑ 로 고르고 Enter · ESC 로 닫기(창은 안 닫힌다) · 칸을 떠나면 닫힘 · 아무것도 안 고르면 친 글자가 그대로 품명(직접 입력).
     · 수신 거르기는 여기 안 건다 — 묶음에서 찾을 때는 어느 수신처 것이든 보여 주고 최근 견적을 앞에 둔다. */
  var SG={ bi:-1, list:[], cur:-1, t:null, hideT:null };
  function sugFind(q, cd){
    var tk=String(q||'').trim().toLowerCase().split(/\s+/).filter(function(x){ return x; }); if(!tk.length) return [];
    var all=function(h){ return tk.every(function(t){ return h.indexOf(t)>=0; }); }, out=[];
    /* ★같은 품명의 견적이 여럿이면 <친 글자가 든 견적(벌)>을 고른다 — 규격은 견적마다 다를 수 있어(「150*200」 ↔ 「150*200 구판」) 늘 최근 것만 보여 주면 규격으로 찾은 것과 다른 값이 채워진다.
       어느 한 벌에도 다 들어 있지 않으면(낱말이 벌마다 흩어짐) 최근 벌 */
    AL.items.forEach(function(it){ if(!all(it.hay)) return; var k=0, hit=false;
      it.sets.forEach(function(x,i){ if(!hit && all([x.prodNm,x.spec,x.makerNm,x.prodCd,x.recvNm,x.docNo].join(' ').toLowerCase())){ hit=true; k=i; } });
      out.push({ t:'h', it:it, k:k }); });
    out.sort(function(a,b){ var x=a.it.sets[a.k], y=b.it.sets[b.k]; return x.quoteDt===y.quoteDt ? n(y.quoteSeq)-n(x.quoteSeq) : (x.quoteDt<y.quoteDt?1:-1); });
    /* ★상품코드 칸(cd)에서 찾을 때 — 숫자 몇 자는 견적 문서번호(Konet261112-01)·규격(240*180)에도 흔히 들어 있어 그대로 두면 엉뚱한 지난 견적이 먼저 뜬다.
       ⇒ 상품을 앞에(코드가 그 글자로 <시작> → 코드에 <들어 있음> → 매칭코드 → 그 밖, 같은 갈래 안은 코드순), 지난 견적은 <상품코드가 맞는 것만> 뒤에. */
    if(cd) out=out.filter(function(h){ return h.it.sets.some(function(x){ var c=String(x.prodCd||'').toLowerCase(); return !!c && all(c); }); });
    out=out.slice(0,20);   /* 제조사로 찾으면 품목이 여럿이라 10 → 20 (상자는 320px 에서 굴린다) */
    if(window._prodsAll){
      var ext={}; (window._extItems||[]).forEach(function(e){ if(e.prodCd && all([e.extItemCd,e.extItemNm,e.extSpec].join(' ').toLowerCase())) ext[String(e.prodCd)]=1; });
      var pl=_prodsAll.filter(function(p){ return p.stopYn!=='Y' && (ext[String(p.prodCd)] || all([p.prodCd,p.prodNm,p.spec,p.makerNm].join(' ').toLowerCase())); });
      if(cd){
        var rk=function(p){ var c=String(p.prodCd||'').toLowerCase(); return c.indexOf(tk[0])===0 ? 0 : (all(c) ? 1 : (ext[String(p.prodCd)] ? 2 : 3)); };
        pl=pl.map(function(p){ return { p:p, r:rk(p) }; }).sort(function(x,y){ return x.r-y.r || String(x.p.prodCd||'').localeCompare(String(y.p.prodCd||'')); }).map(function(x){ return x.p; });
        out=pl.slice(0,20).map(function(p){ return { t:'p', p:p }; }).concat(out);
      } else pl.slice(0,20).forEach(function(p){ out.push({ t:'p', p:p }); });
    }
    return out;
  }
  /* ★단위 칸 (2026-11-18 사용자 「단위도 직접 입력하면 검색되게 해줘」) — 단위로 «품목»을 찾는 것은 뜻이 없다(운영 견적 285줄이 전부 ea 라 전 품목이 걸린다).
     ⇒ 이 칸의 찾기는 <단위 목록>이다 : 지난 견적에서 쓴 단위(많이 쓴 차례 · 몇 번 썼는지) + 자주 쓰는 단위. 칸을 누르면 전부, 치면 그 글자가 든 것만. 고르면 <단위만> 바뀐다(다른 칸은 안 건드린다).
     목록에 없는 단위는 친 글자 그대로. */
  var UNITS=['ea','box','set','매','장','롤','개','봉','kg','pk'];
  function sugUnits(q, all){
    var cnt={}, ord=[]; AL.sets.forEach(function(x){ var u=String(x.unit||'').trim(); if(!u) return; var k=u.toLowerCase(); if(!cnt[k]){ cnt[k]={ u:u, c:0 }; ord.push(k); } cnt[k].c++; });
    ord.sort(function(a,b){ return cnt[b].c-cnt[a].c; });
    UNITS.forEach(function(u){ var k=u.toLowerCase(); if(!cnt[k]){ cnt[k]={ u:u, c:0 }; ord.push(k); } });
    var t=String(q||'').trim().toLowerCase();
    return ord.filter(function(k){ return all || !t || k.indexOf(t)>=0; }).map(function(k){ return { t:'u', u:cnt[k].u, c:cnt[k].c }; });
  }
  function sugPaint(){
    var e=document.getElementById('alSug'); if(!e) return;
    e.innerHTML=SG.list.map(function(h,i){
      var cur=(i===SG.cur?' cur':'');
      if(h.t==='u') return '<div class="sr'+cur+'" onmousedown="event.preventDefault()" onclick="alSugPick('+i+')"><span class="nm">'+esc(h.u)+'</span><span class="ex">'+(h.c?'지난 견적 '+fmt(h.c)+'줄':'')+'</span></div>';
      if(h.t==='p'){ var p=h.p; return '<div class="sr'+cur+'" onmousedown="event.preventDefault()" onclick="alSugPick('+i+')"><span class="tg p">상품</span><span class="dt">'+esc(p.prodCd||'')+'</span>'+(p.makerNm?'<span class="mk">'+esc(p.makerNm)+'</span>':'')+'<span class="nm">'+esc(p.prodNm||'')+'</span><span class="sp">'+esc(p.spec||'')+'</span>'
        +'<span class="ex">'+(n(p.packQty)>1?'입수 '+fmt(p.packQty)+' · ':'')+(n(p.inPrice)?'매입가 '+fmt(p.inPrice,2):'')+(n(p.salePrice)?' · 판매가 '+fmt(p.salePrice,2):'')+'</span></div>'; }
      var s=h.it.sets[h.k], r=s.rows[0]||{};
      return '<div class="sr'+cur+'" onmousedown="event.preventDefault()" onclick="alSugPick('+i+')"><span class="tg h">견적 '+h.it.cnt+'회</span>'+(s.makerNm?'<span class="mk">'+esc(s.makerNm)+'</span>':'')+'<span class="nm">'+esc(s.prodNm)+'</span><span class="sp">'+esc(s.spec)+'</span>'
        +'<span class="ex">'+(n(r.moqQty)?'MOQ '+fmt(r.moqQty):'')+(n(r.buy)?' → '+fmt(r.buy,2):'')+(s.rows.length>1?' 외 '+(s.rows.length-1)+'줄':'')+(n(r.sell)?' · 판매 '+fmt(r.sell,2):'')+'</span><span class="dt">'+esc(d8(s.quoteDt).slice(5))+' '+esc(s.recvNm)+'</span></div>';
    }).join('')+'<div class="sf">'+((SG.list[0]&&SG.list[0].t==='u') ? '↑↓ · Enter · ESC' : '↑↓ 고르기 · Enter 넣기 · ESC 닫기')+'</div>';
  }
  function sugShow(bi, el, all){
    var e=document.getElementById('alSug'); if(!e || !el) return;
    var md=(el.getAttribute && el.getAttribute('data-sg'))||'';
    SG.bi=bi; SG.list = md==='unit' ? sugUnits(el.value, all) : sugFind(el.value, md==='cd'); SG.cur=-1;
    if(!SG.list.length){ e.classList.remove('on'); return; }
    sugPaint();
    var r=el.getBoundingClientRect(), vw=window.innerWidth||1200, vh=window.innerHeight||800, w=(md==='unit') ? 210 : Math.max(r.width, Math.min(860, vw-24));
    e.style.width=w+'px'; e.style.left=Math.max(8, Math.min(r.left, vw-w-12))+'px';
    var below=vh-r.bottom-10; if(below>=170 || below>=r.top){ e.style.top=(r.bottom+2)+'px'; e.style.bottom=''; e.style.maxHeight=Math.max(120, Math.min(320, below))+'px'; }
    else { e.style.top=''; e.style.bottom=(vh-r.top+2)+'px'; e.style.maxHeight=Math.max(120, Math.min(320, r.top-10))+'px'; }   /* 밑에 자리가 없으면 칸 위로 */
    e.classList.add('on');
  }
  window.alSug=function(bi, el, all){ clearTimeout(SG.t); clearTimeout(SG.hideT); SG.t=setTimeout(function(){ if(document.activeElement===el || !document.activeElement || document.activeElement===document.body) sugShow(bi, el, all); }, 140); };   /* all = 친 글자로 거르지 않고 전부(단위 칸을 눌렀을 때) */
  window.alSugHide=function(later){ clearTimeout(SG.t); clearTimeout(SG.hideT); var go=function(){ var e=document.getElementById('alSug'); if(e) e.classList.remove('on'); SG.list=[]; SG.cur=-1; };
    if(later) SG.hideT=setTimeout(go, 160); else go(); };
  window.alSugKey=function(ev, bi){
    var e=document.getElementById('alSug'), on=!!(e && e.classList.contains('on') && SG.list.length);
    if(ev.isComposing) return;
    if(ev.key==='Escape'){ if(on){ ev.preventDefault(); ev.stopPropagation(); alSugHide(); } return; }
    if(ev.key==='ArrowDown' || ev.key==='ArrowUp'){
      if(!on){ if(ev.key==='ArrowDown'){ ev.preventDefault(); clearTimeout(SG.t); sugShow(bi, ev.target, true); } return; }
      ev.preventDefault(); var N=SG.list.length; SG.cur = ev.key==='ArrowDown' ? (SG.cur+1)%N : (SG.cur<=0 ? N-1 : SG.cur-1);
      sugPaint(); var c=e.querySelector('.sr.cur'); if(c && c.scrollIntoView){ try{ c.scrollIntoView({ block:'nearest' }); }catch(x){} } return; }
    if(ev.key==='Enter' && on && SG.cur>=0){ ev.preventDefault(); alSugPick(SG.cur); }
  };
  window.alSugPick=function(i){
    var h=SG.list[i], bi=SG.bi, b=AL.blocks[bi]; alSugHide(); if(!h || !b) return;
    SG.picked=Date.now();   /* 상품코드 칸에서 고르면 칸에 남은 «치다 만 글자»로 change(alCode)가 뒤따라 올 수 있다 — 잠깐 무시한다 */
    if(h.t==='u'){ b.unit=h.u; paintAll(); var ue=document.querySelector('#alB'+bi+' input[data-sg=unit]'); if(ue){ try{ ue.blur(); }catch(x){} } return; }   /* 단위만 바꾼다 */
    if(h.t==='p'){ prodFill(b, h.p); if(window._toast) _toast('상품 값을 가져왔습니다.','ok'); }
    else { b.src='h'; b.item=h.it; b.setIdx=h.k; blkFill(b, h.it.sets[h.k]); if(window._toast) _toast('지난 견적 값으로 채웠습니다.','ok'); }
    paintAll(); scrollBlk(bi);
  };
  function scrollBlk(bi, focusNm){ var e=document.getElementById('alB'+bi); if(!e) return; try{ e.scrollIntoView({ block:'nearest' }); }catch(x){}
    var f=e.querySelector(focusNm ? '.al-in.nm' : 'input.ci'); if(f){ try{ f.focus(); f.select(); }catch(x){} } }

  /* ── ② 묶음 그리기 ── */
  function srcHtml(b, bi){
    if(b.src==='h' && b.item){
      var s=b.item.sets[b.setIdx];
      if(b.item.sets.length>1)
        return '<span class="tg h">지난 견적</span> <select onchange="alSrc('+bi+', this.value)" title="같은 품명의 다른 견적서 값으로 바꿉니다 — 아래 칸이 그 견적서 값으로 다시 채워집니다">'
          + b.item.sets.map(function(x,k){ return '<option value="'+k+'"'+(k===b.setIdx?' selected':'')+'>'+esc(d8(x.quoteDt))+' · '+esc(x.recvNm)+' · '+esc(x.docNo)+(x.rows.length>1?' · MOQ '+x.rows.length+'줄':'')+'</option>'; }).join('')+'</select>';
      return '<span class="tg h">지난 견적</span> '+esc(d8(s.quoteDt))+' · '+esc(s.recvNm)+' · '+esc(s.docNo);
    }
    if(b.src==='p') return '<span class="tg p" title="상품마스터 — 매입가 → 배송 단가 · 입수량">상품마스터</span>';
    return '<span class="tg n">직접 입력</span>';
  }
  function warnOf(b){
    var w=[], info=[];
    if(!(b.prodNm||'').trim()) w.push('품명을 적으세요');
    if(!n(b.box) && b.rows.some(function(r){ return n(r.buy); })) w.push('박스 입수량을 넣어야 계산됩니다');
    if((b.prodNm||'').trim() && typeof _lines!=='undefined' && _lines.some(function(l){ return !l.variant && nmKey(l.prodNm)===nmKey(b.prodNm); })) w.push('견적서에 같은 품명이 이미 있습니다');
    if(b.src==='h' && b.item){ var s=b.item.sets[b.setIdx];
      if(s.mode && s.mode!==_cs.mode) info.push('지난 견적은 '+(MODE_NM[s.mode]||s.mode)+' 기준이었습니다(지금 '+(MODE_NM[_cs.mode]||_cs.mode)+')'); }
    var bi=AL.blocks.indexOf(b), btn=(info.length && bi>=0) ? ' <button class="btn lnk xb" style="font-weight:800;color:#0f6b5e" onclick="alModeMatch('+bi+')" title="품목 표 위 「🧮 마진계산 물류비」를 그때 갈래로 바꿉니다 — 견적서 한 장에 하나라 이미 적힌 줄의 계산도 같이 바뀝니다">'+esc(modeNmOf(b.item.sets[b.setIdx]))+'(으)로 맞추기</button>' : '';
    return (w.length?'<span class="al-warn">⚠ '+w.map(esc).join(' · ')+'</span>':'')+(info.length?'<span class="al-info">ℹ '+info.map(esc).join(' · ')+btn+'</span>':'');
  }
  function tin(cls, val, d, oninput, extra){ return '<input type="text" class="'+cls+'" value="'+(n(val)?fmt(val,d||0):'')+'" onfocus="this.select()" oninput="'+oninput+'"'+(extra||'')+'>'; }
  function blkHtml(b, bi){
    var lg=lgCol();
    var h='<div class="al-blk" id="alB'+bi+'">'
     +'<div class="al-bh"><span class="al-no">'+(bi+1)+'</span>'
     +'<input type="text" class="al-in nm" value="'+esc(b.prodNm)+'" placeholder="품명" title="치면 지난 견적·상품에서 찾아 줍니다 — 고르지 않으면 친 글자가 그대로 품명" autocomplete="off" oninput="alSet('+bi+',\'prodNm\',this.value); alSug('+bi+', this)" onkeydown="alSugKey(event, '+bi+')" onblur="alSugHide(true)" onchange="alWarn('+bi+')">'
     +'<button class="btn lnk" style="height:30px;flex:none" onclick="alProd('+bi+')" title="우리 상품에서 고르기 — 견적서 작성 표의 🔍 와 같은 「상품 찾기」 창(상품코드 · 품명 · 규격 · 매칭코드). 고르면 이 묶음에 품명·규격·제조사·상품코드·입수량이 들어옵니다">🔍</button>'
     +'<input type="text" class="al-in" style="flex:0 1 230px;min-width:140px" value="'+esc(b.spec)+'" placeholder="규격 및 재질" title="치면 지난 견적·상품에서 찾아 줍니다" autocomplete="off" oninput="alSet('+bi+',\'spec\',this.value); alSug('+bi+', this)" onkeydown="alSugKey(event, '+bi+')" onblur="alSugHide(true)">'
     +'<input type="text" class="al-in" style="width:100px" value="'+esc(b.makerNm)+'" placeholder="제조사" title="제조사 — 치면 그 제조사의 지난 견적 품목·상품을 찾아 줍니다" autocomplete="off" oninput="alSet('+bi+',\'makerNm\',this.value); alSug('+bi+', this)" onkeydown="alSugKey(event, '+bi+')" onblur="alSugHide(true)">'
     +'<span class="al-lb">상품코드</span><input type="text" class="al-in" style="width:110px" value="'+esc(b.prodCd)+'" placeholder="(없으면 비움)" data-sg="cd" autocomplete="off" oninput="alSug('+bi+', this)" onkeydown="alSugKey(event, '+bi+')" onblur="alSugHide(true)" onchange="alCode('+bi+', this.value)" title="우리 상품코드 — 치면 그 코드의 상품을 찾아 줍니다(매칭코드 포함). 다 적고 칸을 떠나도 상품마스터에서 품명·규격·제조사·입수량·매입가를 가져옵니다. 마스터에 없는 코드는 넣지 않습니다(비워 둬도 됩니다)">'
     +'<span class="al-lb">단위</span><input type="text" class="al-in" style="width:46px;text-align:center" value="'+esc(b.unit)+'" data-sg="unit" autocomplete="off" title="단위 — 누르거나 치면 단위 목록이 뜹니다(지난 견적에서 쓴 단위 + 자주 쓰는 단위). 목록에 없는 단위는 그대로 적으면 됩니다" onfocus="this.select(); alSug('+bi+', this, true)" oninput="alSet('+bi+',\'unit\',this.value); alSug('+bi+', this)" onkeydown="alSugKey(event, '+bi+')" onblur="alSugHide(true)">'
     +'<span class="al-lb" title="마진계산 줄은 견적서에 Box 1 · 수량 = 이 값으로 들어갑니다">박스 입수량</span>'+tin('ci', b.box, 0, 'alSet('+bi+',\'box\', n(this.value))', ' style="width:70px"')
     +'<span class="al-src">'+srcHtml(b, bi)+'</span>'
     +'<button class="btn lnk btn-red" style="margin-left:auto" onclick="alBlkDel('+bi+')" title="이 묶음 빼기(견적서에는 아무 영향 없음)">✕ 빼기</button></div>'
     +'<div class="al-fee">'+b.extras.map(function(x,j){
        return '<span class="fx"><b>'+esc(x.nm)+'</b> 수량 '+tin('ci', x.qty, 0, 'alFee('+bi+','+j+',\'qty\', n(this.value))', ' style="width:52px"')
          +' × 단가 '+tin('ci', x.price, 0, 'alFee('+bi+','+j+',\'price\', n(this.value))', ' style="width:88px"')
          +' = <span class="fa" id="alX'+bi+'_'+j+'"></span>'
          +'<select onchange="alFee('+bi+','+j+',\'use\', this.value)" title="적용 안 함 = 줄만 보임(합계·원가 제외) · 별도 청구 = 견적서에 줄로 나가고 합계에 더함 · 원가 포함 = 금액 ÷ MOQ수량을 개당 구매에 더함(견적서에는 줄로 안 나옴)">'
          + USES.map(function(u){ return '<option value="'+u[0]+'"'+(x.use===u[0]?' selected':'')+'>'+u[1]+'</option>'; }).join('')+'</select></span>'; }).join('')
     +'<span class="dim" style="font-size:12px">모든 MOQ 줄에 적용</span></div>'
     +'<div style="overflow:auto"><table class="g al-t"><thead><tr>'
     +'<th class="u" title="사람이 정하는 칸">배송 MOQ수량</th><th class="u">배송 단가</th><th>금액</th>'
     +'<th class="a" title="지난 견적에서 끌어온 값 — 고칠 수 있습니다">운송</th><th class="a" title="비우면 자동 = 보관료 × 팔레트 × 개월 ÷ MOQ수량 (배송 단가가 있을 때만)">보관</th><th class="a">소분</th><th class="a">박스</th>'
     +(lg?'<th class="a" title="이 줄의 물류비 — 비우면 '+(_cs.mode==='parcel'?'직송비/박스':'DC 비율')+' 기본값">줄 물류비</th>':'')
     +'<th title="개당 구매 = 단가 + 운송 + 보관 + 소분 + 박스 + 원가 포함 동판·목형/개">구단(계산)</th>'
     +'<th class="u" title="넣으면 필요 판매단가가 나오고 판매적용단가로 자동 적용됩니다">목표 마진율(%)</th><th>필요 판매단가</th>'
     +'<th style="color:#0f6b5e" title="견적서 줄의 단가 — 자동 : 지난 견적 조건을 하나도 안 바꿨으면 그때 단가 그대로 · 바꿨으면 필요 판매단가(자릿수 적용) · 목표 마진율이 없으면 지난 견적 단가·상품 판매가. 직접 고치면 노란 칸">판매적용단가</th>'
     +'<th>물류비</th><th>실 마진율</th><th title="지난 견적의 단가 / 상품마스터 판매가 — [←] 로 판매적용단가에 넣습니다">참고 단가</th><th></th></tr></thead><tbody>'
     + b.rows.map(function(r,ri){
        var p=bi+','+ri;
        return '<tr><td>'+tin('ci', r.moqQty, 0, 'alRow('+p+',\'moqQty\', n(this.value))', ' style="width:88px"')+'</td>'
          +'<td>'+tin('ci', r.buy, 2, 'alRow('+p+',\'buy\', n(this.value))', (r.buyMemo?' title="📝 '+esc(r.buyMemo)+'"':''))+'</td>'
          +'<td class="au" id="alF'+bi+'_'+ri+'"></td>'
          +'<td>'+tin('ca', r.base.trans, 2, 'alBase('+p+',\'trans\', n(this.value))', ' style="width:62px"')+'</td>'
          +'<td><input type="text" class="'+(r.base.storeManual?'cm':'ca')+'" style="width:62px" id="alSt'+bi+'_'+ri+'" value="'+(r.base.storeManual&&n(r.base.store)?fmt(r.base.store,2):'')+'" onfocus="this.select()" oninput="alStore('+p+', this.value)"><button class="btn lnk xb" onclick="alStore('+p+', null)" title="자동(보관료 × 팔레트 × 개월 ÷ MOQ)으로 되돌리기">↻</button></td>'
          +'<td>'+tin('ca', r.base.split, 2, 'alBase('+p+',\'split\', n(this.value))', ' style="width:62px"')+'</td>'
          +'<td>'+tin('ca', r.base.pack, 2, 'alBase('+p+',\'pack\', n(this.value))', ' style="width:62px"')+'</td>'
          +(lg?'<td><input type="text" class="'+(r.base.lgFee===''?'ca':'cm')+'" style="width:70px" id="alLg'+bi+'_'+ri+'" value="'+(r.base.lgFee===''?'':fmt(r.base.lgFee))+'" onfocus="this.select()" oninput="alLg('+p+', this.value)"></td>':'')
          +'<td class="au" id="alH'+bi+'_'+ri+'"></td>'
          +'<td>'+tin('ci', r.target, 2, 'alRow('+p+',\'target\', n(this.value))', ' style="width:62px"')+'</td>'
          +'<td class="au b" id="alN'+bi+'_'+ri+'"></td>'
          +'<td><input type="text" class="'+(r.sellMan?'cm':'ca')+'" style="width:82px;'+(r.sellMan?'':'color:#0f6b5e;font-weight:800')+'" id="alS'+bi+'_'+ri+'" value="" onfocus="this.select()" oninput="alSell('+p+', this.value)"><button class="btn lnk xb" onclick="alSell('+p+', null)" title="자동으로 되돌리기">↻</button></td>'
          +'<td class="au p" id="alP'+bi+'_'+ri+'"></td><td class="au s" id="alM'+bi+'_'+ri+'"></td>'
          +'<td class="pv">'+(n(r.prevSell)?'<span title="'+esc(r.prevNm||'참고')+'">'+esc(r.prevNm||'참고')+' '+fmt(r.prevSell,2)+'</span> <button class="btn lnk xb" onclick="alSell('+p+', '+n(r.prevSell)+')" title="이 단가를 판매적용단가로 넣기">←</button>':'')+'</td>'
          +'<td>'+(b.rows.length>1?'<button class="btn lnk xb btn-red" onclick="alRowDel('+p+')" title="이 MOQ 줄 빼기">✕</button>':'')+'</td></tr>'; }).join('')
     +'</tbody></table></div>'
     +'<div class="al-bf"><button class="btn lnk" style="font-weight:800;color:#0f6b5e" onclick="alRowAdd('+bi+')" title="같은 품명으로 MOQ수량만 다른 줄 — 견적서에는 품명 밑 ↳ 줄로 들어가고 인쇄에는 품명이 하나로 합쳐 나갑니다">＋MOQ</button>'
     +'<span id="alW'+bi+'">'+warnOf(b)+'</span></div>'
     +'</div>';
    return h;
  }
  function paintAll(){
    var body=document.getElementById('alBody'); if(!body) return;
    document.getElementById('alMode').textContent=modeTxt();
    body.innerHTML = AL.blocks.length ? AL.blocks.map(blkHtml).join('')
      : '<div class="al-empty">위에서 품목을 고르거나 <b>[＋ 새 품목 직접 입력]</b>을 누르세요.<br>'
        +'<span class="tg h">견적 n회</span> 지난 견적(제출완료·채택) &nbsp; <span class="tg p">상품</span> 상품마스터 &nbsp; <span class="tg n">직접 입력</span> 새 품목</div>';   /* 짧게 (2026-11-18 「화면에 보이는 설명 간결하게」 — 종전 네 줄) */
    AL.blocks.forEach(function(b,bi){ blkPaint(bi); });
    sumPaint();
  }
  function setTxt(id, txt, neg){ var e=document.getElementById(id); if(!e) return; e.textContent=txt; if(e.classList) e.classList.toggle('neg', !!neg); }
  function blkPaint(bi){
    var b=AL.blocks[bi]; if(!b) return;
    b.extras.forEach(function(x,j){ var a=n(x.qty)*n(x.price); setTxt('alX'+bi+'_'+j, a?fmt(a):''); });
    b.rows.forEach(function(r,ri){
      var rc=rowCalc(b,r), c=rc.c, k=bi+'_'+ri;
      setTxt('alF'+k, c.buyTotal?fmt(c.buyTotal):'');
      setTxt('alH'+k, c.H?fmt(c.H,2):'');
      var he=document.getElementById('alH'+k); if(he){ he.title=c.exPer ? ('원가 포함 동판·목형 '+fmt(c.exCost)+' ÷ MOQ '+fmt(n(r.moqQty))+' = 개당 '+fmt(c.exPer,2)+' 포함') : ''; he.style.background=c.exPer?'#fff3c4':''; }
      var st=document.getElementById('alSt'+k); if(st && !r.base.storeManual && document.activeElement!==st) st.value=c.store?fmt(c.store,2):'';
      var lg=document.getElementById('alLg'+k); if(lg && r.base.lgFee==='' && document.activeElement!==lg) lg.value=(c.O||c.P)?fmt(c.P):'';
      setTxt('alN'+k, rc.need?fmt(rc.need,2):'');
      var se=document.getElementById('alS'+k);
      if(se){ if(document.activeElement!==se) se.value=rc.sell?fmt(rc.sell,2):'';
        se.title = r.sellMan ? '직접 넣은 단가 — ↻ 로 자동' : (rc.how==='same' ? '자동 = 지난 견적 단가 그대로(조건이 그때와 같습니다) — MOQ수량·배송 단가·목표 마진율 등을 바꾸면 필요 판매단가로 다시 계산합니다' : rc.how==='need' ? '자동 = 필요 판매단가'+(OPT.round==='2'?'':' ('+OPT.round+'원 단위 올림)') : (rc.how==='prev' ? '자동 = '+(r.prevNm||'참고 단가')+' (목표 마진율을 넣으면 필요 판매단가로 바뀝니다)' : '목표 마진율을 넣거나 직접 적으세요')); }
      setTxt('alP'+k, (c.O||c.P)?fmt(c.P):'');
      setTxt('alM'+k, (c.I&&c.O)?(fmt(c.S*100,2)+'%'):'', c.S<0);
    });
  }
  function sumPaint(){
    var good=AL.blocks.filter(function(b){ return (b.prodNm||'').trim(); }), rows=0, fee=0;
    good.forEach(function(b){ rows+=outRows(b).length; b.extras.forEach(function(x){ if(n(x.qty)*n(x.price)) fee++; }); });
    var e=document.getElementById('alSum'); if(e) e.innerHTML = AL.blocks.length
      ? '넣을 품목 <b>'+good.length+'</b>개 · 견적서 줄 <b>'+rows+'</b>줄'+(fee?' · 동판·목형 <b>'+fee+'</b>건':'')+(AL.blocks.length>good.length?' <span class="al-warn">(품명 없는 '+(AL.blocks.length-good.length)+'개 제외)</span>':'')
      : '<span class="dim">아직 고른 품목이 없습니다</span>';
    var typed=(typeof _lines==='undefined')? 0 : _lines.filter(function(l){ return !pristine(l); }).length;
    var kp=document.getElementById('alKeep'); if(kp) kp.textContent = typed ? '기존 '+typed+'줄 밑에 붙습니다' : '';
    var go=document.getElementById('alGo'); if(go) go.disabled=!good.length;
  }

  /* ── 값 고치기 — 모델만 바꾸고 계산 칸만 다시 그린다(입력 중 포커스가 안 튄다) ── */
  window.alSet=function(bi,k,v){ var b=AL.blocks[bi]; if(!b) return; b[k]=v; if(k==='box') blkPaint(bi); if(k==='prodNm'||k==='box'){ alWarn(bi); sumPaint(); } };
  window.alWarn=function(bi){ var b=AL.blocks[bi], e=document.getElementById('alW'+bi); if(b&&e) e.innerHTML=warnOf(b); };
  window.alRow=function(bi,ri,k,v){ var b=AL.blocks[bi], r=b&&b.rows[ri]; if(!r) return; r[k]=v; blkPaint(bi); if(k==='buy') alWarn(bi); sumPaint(); };
  window.alBase=function(bi,ri,k,v){ var b=AL.blocks[bi], r=b&&b.rows[ri]; if(!r) return; r.base[k]=v; blkPaint(bi); };
  window.alStore=function(bi,ri,v){ var b=AL.blocks[bi], r=b&&b.rows[ri]; if(!r) return;
    var e=document.getElementById('alSt'+bi+'_'+ri);
    if(v==null || String(v).trim()===''){ r.base.storeManual=false; r.base.store=0; if(e){ e.className='ca'; if(v==null) e.value=''; } }
    else { r.base.storeManual=true; r.base.store=n(v); if(e) e.className='cm'; }
    blkPaint(bi); };
  window.alLg=function(bi,ri,v){ var b=AL.blocks[bi], r=b&&b.rows[ri]; if(!r) return; var t=String(v==null?'':v).replace(/,/g,'').trim();
    r.base.lgFee=(t==='')? '' : n(t); var e=document.getElementById('alLg'+bi+'_'+ri); if(e) e.className=(r.base.lgFee===''?'ca':'cm'); blkPaint(bi); };
  window.alSell=function(bi,ri,v){ var b=AL.blocks[bi], r=b&&b.rows[ri]; if(!r) return;
    var e=document.getElementById('alS'+bi+'_'+ri), typing=(typeof v==='string');
    if(v==null || (typing && v.trim()==='')){ r.sellMan=false; r.sell=0; }
    else { r.sellMan=true; r.sell=n(v); }
    if(e){ e.className=r.sellMan?'cm':'ca'; e.style.color=r.sellMan?'':'#0f6b5e'; e.style.fontWeight=r.sellMan?'':'800'; if(!typing){ try{ e.blur(); }catch(x){} } }
    blkPaint(bi); };
  window.alFee=function(bi,j,k,v){ var b=AL.blocks[bi]; if(!b||!b.extras[j]) return; b.extras[j][k]=v; blkPaint(bi); sumPaint(); };
  window.alRowAdd=function(bi){ var b=AL.blocks[bi]; if(!b) return; b.rows.push(newRow(b.rows[b.rows.length-1])); paintAll();
    var e=document.getElementById('alB'+bi); if(e){ var ins=e.querySelectorAll('tbody tr'); var f=ins[ins.length-1]&&ins[ins.length-1].querySelector('input.ci'); if(f){ try{ f.focus(); }catch(x){} } } };
  window.alRowDel=function(bi,ri){ var b=AL.blocks[bi]; if(!b||b.rows.length<2) return; b.rows.splice(ri,1); paintAll(); };
  window.alBlkDel=function(bi){ AL.blocks.splice(bi,1); paintAll(); };
  window.alClear=function(){ if(!AL.blocks.length) return; _confirmBox({ msg:'아래 묶음 <b>'+AL.blocks.length+'</b>개를 모두 지울까요?<br><span style="font-size:12.5px;color:#3d4d5c">견적서에 이미 넣은 줄에는 아무 영향이 없습니다.</span>', icon:'🧹', okText:'비우기', onOk:function(){ AL.blocks=[]; paintAll(); }, onCancel:function(){} }); };
  window.alSrc=function(bi,k){ var b=AL.blocks[bi]; if(!b||!b.item||!b.item.sets[+k]) return; b.setIdx=+k; blkFill(b, b.item.sets[b.setIdx]); paintAll(); if(window._toast) _toast('그 견적서 값으로 다시 채웠습니다.','info'); };
  window.alOpt=function(k,v){
    if(k==='round'){ OPT.round=String(v); optSave(); AL.blocks.forEach(function(b,bi){ blkPaint(bi); }); return; }
    if(k==='target'){ var t=String(v||'').replace(/,/g,'').trim(); OPT.target=(t==='')? '' : n(t); optSave(); }
  };
  /* 묶음에 상품마스터 값 넣기 — 품명·규격·제조사·코드·입수량은 그 상품 것으로 바꾸고(「다시 고른 것 = 그 상품을 쓰겠다」 — 작성 화면 prodPick 과 같은 뜻),
     ★배송 단가·참고 단가는 <빈 칸만> 채운다 — 지난 견적에서 끌어온 MOQ 줄의 단가를 마스터 매입가로 덮으면 그때 조건이 통째로 바뀐다 */
  function prodFill(b, p){
    b.prodCd=String(p.prodCd||''); b.prodNm=String(p.prodNm||''); b.spec=String(p.spec||''); b.makerNm=String(p.makerNm||'');
    if(n(p.packQty)>1) b.box=n(p.packQty);
    b.rows.forEach(function(r){ if(!n(r.buy)) r.buy=n(p.inPrice); if(!n(r.prevSell)){ r.prevSell=n(p.salePrice); r.prevNm='상품 판매가'; } });
    if(b.src==='n') b.src='p';
  }
  /* ★품명 옆 [🔍] = 작성 화면의 「상품 찾기」 창을 <그대로> 쓴다 (2026-11-18 사용자 그림 「기존처럼 검색도 가능하게」 — 묶음의 품명 칸 오른쪽 끝에 표시).
     창·검색 규칙(코드·매칭코드 먼저, 그 뒤 이웃 코드, 이름·규격은 맨 뒤 · 거래중지는 흐리게)·ESC 는 전부 기존 것이고, 여기서 바꾸는 것은 «고른 값이 어디로 가는가» 하나다 :
       AL.pickBi ≥ 0 이면 그 묶음으로(prodFill), 아니면 종전대로 견적서 줄로(원래 prodPick).
     · 원래 prodOpen·prodPick 을 감싸 둔다(hook — 한 번만). 표의 🔍(prodOpen)를 누르면 pickBi 를 -1 로 되돌리므로, 창을 고르지 않고 닫았다가 표에서 다시 열어도 줄로 간다.
     · 상품 찾기 창은 이 창보다 먼저 만들어져 있어 같은 z-index 면 밑에 깔린다 → 묶음에서 열 때만 위로 올린다. */
  AL.pickBi=-1;
  function hook(){
    if(AL.hooked || typeof prodOpen!=='function' || typeof prodPick!=='function') return; AL.hooked=true;
    var o0=window.prodOpen, p0=window.prodPick;
    window.prodOpen=function(i){ AL.pickBi=-1; var pp=document.getElementById('prodPop'); if(pp) pp.style.zIndex=''; return o0.apply(this, arguments); };
    window.prodPick=function(k){
      if(AL.pickBi<0) return p0.apply(this, arguments);
      var bi=AL.pickBi, b=AL.blocks[bi], p=(window._prodRows||[])[k]; AL.pickBi=-1;
      var pp=document.getElementById('prodPop'); if(pp){ pp.classList.remove('on'); pp.style.zIndex=''; }
      if(!b || !p) return;
      prodFill(b, p); paintAll(); scrollBlk(bi);
      if(window._toast) _toast('상품 값을 가져왔습니다.','ok');
    };
  }
  window.alProd=function(bi){
    var b=AL.blocks[bi]; if(!b) return; hook();
    prodOpen(-1);   /* 창을 열고 목록을 읽는다(없는 줄 번호 — 줄에는 아무것도 안 건드린다) */
    AL.pickBi=bi;
    var pp=document.getElementById('prodPop'), q=document.getElementById('prodQ'); if(pp) pp.style.zIndex='1100';
    if(q){ q.value=String(b.prodCd||b.prodNm||'').trim(); try{ q.focus(); q.select(); }catch(e){} }
    if(typeof prodRender==='function') prodRender();
  };

  /* 상품코드를 직접 적었을 때 — 마스터에 있는 코드만 받는다(없는 코드를 넣으면 채택 → 판매 연결에서 어긋난다) */
  window.alCode=function(bi, v){
    var b=AL.blocks[bi]; if(!b) return; var cd=String(v||'').trim();
    if(SG.picked && Date.now()-SG.picked<400) return;   /* 방금 목록에서 골랐다 — 칸에 남아 있던 치다 만 글자는 버린다 */
    if(cd && String(b.prodCd||'').trim().toLowerCase()===cd.toLowerCase()) return;   /* 이미 그 코드 */
    if(!cd){ b.prodCd=''; return; }
    var go=function(){
      var p=null; (window._prodsAll||[]).forEach(function(x){ if(!p && String(x.prodCd||'').trim().toLowerCase()===cd.toLowerCase()) p=x; });
      if(!p){ b.prodCd=''; paintAll(); _alertBox('상품마스터에 없는 코드입니다 : <b>'+esc(cd)+'</b><br><span style="font-size:12.5px;color:#3d4d5c">상품코드는 비워 두고 품명만으로 견적을 낼 수 있습니다.</span>',{icon:'⚠️'}); return; }
      if(p.stopYn==='Y'){ b.prodCd=''; paintAll(); _alertBox('거래중지 상품입니다 : <b>'+esc(cd)+'</b>',{icon:'⚠️'}); return; }
      prodFill(b, p);
      paintAll(); if(window._toast) _toast('상품 값을 가져왔습니다.','ok');
    };
    if(window._prodsAll) go(); else prodMastersLoad(go);
  };

  /* ── ③ 견적서에 넣기 — 기존 줄은 그대로, 그 밑에 ── */
  function pristine(l){ return !(l.prodNm||'').trim() && !(l.spec||'').trim() && !n(l.qty) && !n(l.unitPrice) && !n(l.unitPrice2) && !(l.calc && (calcHasVal(l.calc) || calcHasFee(l.calc))); }
  /* 묶음에서 실제로 줄이 될 MOQ 줄 — 아무것도 안 적은 줄은 뺀다(전부 비었으면 품명만 든 한 줄) */
  function outRows(b){ var a=b.rows.filter(function(r){ return n(r.moqQty) || n(r.buy) || (r.sellMan && n(r.sell)); }); return a.length ? a : [b.rows[0]]; }
  function makeLines(){
    var add=[];
    AL.blocks.forEach(function(b){
      var nm=String(b.prodNm||'').trim(); if(!nm) return;
      outRows(b).forEach(function(r,k){
        var rc=rowCalc(b,r), l=blank();
        l.variant=k>0; l.makerNm=String(b.makerNm||'').trim(); l.prodNm=nm; l.spec=String(b.spec||''); l.unit=String(b.unit||'').trim()||'ea'; l.prodCd=String(b.prodCd||'');
        l.unitPrice=rc.sell; l.unitPrice2=0; l.remark='';
        var c=rowLine(b, r, rc.sell).calc; c.open=true; c.feeOpen=calcHasFee(c);
        l.calc=c;
        calcLineSync(l);   /* 입수량이 있으면 Box 1 · 수량 = 입수량 (견적서 작성의 규칙 그대로) */
        add.push(l);
      });
    });
    return add;
  }
  window.alApply=function(){
    if(locked()){ _alertBox('잠긴 견적서입니다 — 잠금을 푼 뒤에 넣으세요.',{icon:'🔒'}); return; }
    var add=makeLines();
    if(!add.length){ _alertBox('넣을 품목이 없습니다 — 위에서 품목을 고르고 품명을 확인하세요.',{icon:'ℹ️'}); return; }
    var noSell=add.filter(function(l){ return !n(l.unitPrice); }).length;
    var go=function(){
      var keep=_lines.every(pristine) ? [] : _lines.slice();   /* 빈 줄뿐이면(새 견적서 첫 화면) 그 자리에, 아니면 기존 줄 밑에 */
      var first=keep.length;
      _lines=keep.concat(add);
      for(var i=first;i<_lines.length;i++) moqRmkSync(i);   /* 비고 「MOQ n개」 자동 기재 — 손으로 적은 줄과 같은 규칙 */
      renderLines();
      var prods=add.filter(function(l){ return !l.variant; }).length;
      AL.blocks=[]; alClose(); paintAll();
      var trs=document.querySelectorAll('#lbody tr.mainln');
      for(var k=first;k<trs.length;k++) trs[k].classList.add('al-new');
      if(trs[first]){ try{ trs[first].scrollIntoView({ block:'center' }); }catch(e){} }
      if(window._toast) _toast('⚡ 품목 '+prods+'개 · '+add.length+'줄을 '+(first?'기존 '+first+'줄 밑에 ':'')+'넣었습니다.','ok');
    };
    if(noSell) _confirmBox({ msg:'판매적용단가가 비어 있는 줄이 <b>'+noSell+'</b>줄 있습니다.<br><span style="font-size:12.5px;color:#3d4d5c">목표 마진율·박스 입수량·배송 단가가 있어야 자동으로 나옵니다. 그대로 넣고 견적서 표에서 채워도 됩니다.</span>', icon:'❓', okText:'그대로 넣기', onOk:go, onCancel:function(){} });
    else go();
  };

  /* 시뮬·점검용 — 화면은 쓰지 않는다 */
  window._alDbg={ AL:AL, OPT:OPT, buildHist:buildHist, rowCalc:rowCalc, makeLines:makeLines, roundSell:roundSell, blkFromItem:blkFromItem, blkFromProd:blkFromProd, blkNew:blkNew, pristine:pristine, feeNorm:feeNorm };
})();
