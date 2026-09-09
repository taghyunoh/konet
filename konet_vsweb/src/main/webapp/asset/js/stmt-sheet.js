/* ══════════════════════════════════════════════════════════════════════════════
   거래명세서 한 장을 그리는 공용 렌더러  (2026-09-09 신설)

   ★쓰는 곳이 둘이다 — 그래서 한 파일로 뺐다.
     ① 판매등록 salesReg.jsp ▸ [🖨 거래명세표]      — 화면의 전표를 새 창에 그린다
     ② 공개 링크 stmtPrint.jsp ▸ /pub/stmt.do?t=토큰 — 거래처가 로그인 없이 본다(카톡·이메일로 보낸 주소)
   ⚠양식을 두 벌로 만들면 <보낸 명세서>와 <내가 찍은 명세서>가 조용히 달라진다.
     칸을 더하거나 뺄 때는 이 파일만 고치면 두 곳이 함께 바뀐다.

   쓰는 법 :
     konetStmt.doc(D, O, S, prev, opt) → 문서 한 장 통째(HTML 문자열)
       D  전표   {dt,no,dlvDt,venNm,ven{bizno,addr,addr2,email,hp,tel},remark,pay,dc,
                  t{box,ea,qty,sup,vat,tot}, rows[...], balBefore,balAfter, sortMap{prodCd:조회순서}}
       O  조건   konetStmt.DEF 참고
       S  공급자 {nm,biz,ceo,cond,item,addr,bank,tel,notice}
       prev 직전단가 {prodCd:단가} — 없으면 null(단가변동 표시 안 함)
       opt  {autoPrint:true|false, close:true|false, note:'머리줄에 덧붙일 글'}
   ══════════════════════════════════════════════════════════════════════════════ */
(function(g){
  'use strict';

  function n(v){ var x = Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x) ? x : 0; }
  function fmt(v){ return Math.round(n(v)).toLocaleString('en-US'); }
  /* 단가만 소수점을 살린다(소수 2자리) — 금액·합계는 정수. 판매등록 화면과 같은 규칙 */
  function fmtP(v){ v = Math.round(n(v)*100)/100; return v.toLocaleString('en-US', {maximumFractionDigits:2}); }
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  /* ★번호에 「-」를 넣어 찍는다 (2026-09-09 실제 출력물에서 발견) —
       회사 마스터·거래처 마스터에는 「1298667271」·「07082225194」 처럼 숫자만 들어 있는 경우가 많은데,
       세금계산서 짝인 거래명세서에 그대로 찍히면 읽기도 나쁘고 사업자번호처럼 안 보인다.
     ⚠**이미 「-」가 있거나 숫자가 아닌 글자가 섞이면 손대지 않는다** — 사람이 넣어 둔 표기를 존중한다.
       DB 값은 안 바꾼다. 찍을 때만 모양을 낸다. */
  function bizNo(v){
    var s = String(v==null?'':v).trim();
    return /^\d{10}$/.test(s) ? s.slice(0,3)+'-'+s.slice(3,5)+'-'+s.slice(5) : s;
  }
  function telNo(v){
    var s = String(v==null?'':v).trim();
    if (!/^\d{9,11}$/.test(s)) return s;
    if (s.length === 11) return s.slice(0,3)+'-'+s.slice(3,7)+'-'+s.slice(7);          // 010·070…
    if (s.indexOf('02') === 0) return s.slice(0,2)+'-'+s.slice(2,s.length-4)+'-'+s.slice(-4); // 서울
    return s.slice(0,3)+'-'+s.slice(3,s.length-4)+'-'+s.slice(-4);                     // 그 밖 지역
  }

  /* 기본 조건 — 판매등록 조건 창의 처음 상태와 같다 */
  var DEF = { ord:'in', amt:'Y', price:'Y', bal:'N', inv:'N', boxp:'N', chg:'N', vat:'N', rows:10, mode:'both' };

  /* ★A4 실측(2026-09-09, 머리표 4줄) — 쓸 수 있는 높이 279mm · 품목 한 줄 5.3mm.
       한 부만 찍으면 38줄이 종이를 꽉 채운다. 「한 장일 때는 아래까지」(2026-09-09 요청)로
       한 부 모드에서는 남는 자리를 빈 줄로 이 수까지 채워 <종이 아래까지> 양식이 내려온다.
       ⚠머리표에 줄을 더하면 이 수가 내려간다 — 그때 다시 재고 여기와 조건 창 안내를 같이 고칠 것. */
  var FILL_ONE = 38;
  /* 「한 장에 모두」는 한 부가 종이의 절반이라 12줄이 한계 — 그쪽은 채우지 않는다(채우면 넘친다) */
  var FILL_BOTH = 12;

  /* 정렬 — '조회번호' = 상품마스터의 조회순서(SORT_ORD), 없으면 상품코드 순 */
  function sortRows(rows, ord, sortMap){
    var l = rows.slice();
    if (ord !== 'sort') return l;
    var m = sortMap || {};
    return l.sort(function(a,b){
      var sa = (m[a.prodCd]==null || m[a.prodCd]==='') ? 999999 : n(m[a.prodCd]);
      var sb = (m[b.prodCd]==null || m[b.prodCd]==='') ? 999999 : n(m[b.prodCd]);
      if (sa!==sb) return sa-sb;
      return String(a.prodCd||'').localeCompare(String(b.prodCd||''));
    });
  }
  /* 장 나누기 — 마지막 장에는 [수량합계]·이하여백 두 줄이 더 들어가므로 꽉 차면 한 장을 더 만든다 */
  function pages(rows, per){
    per = Math.max(3, per||10);
    var pgs=[], i=0;
    while (i < rows.length){ pgs.push(rows.slice(i, i+per)); i += per; }
    if (!pgs.length) pgs.push([]);
    if (pgs[pgs.length-1].length > per-2) pgs.push([]);
    return pgs;
  }
  /* 칸 구성 — 조건에 따라 칸 자체가 생기고 사라진다(빈 칸을 남기지 않는다).
     ⚠머리글·자료·[수량합계]·이하여백·빈 줄이 <한 조건 안에서 모두 같은 칸 수>여야 한다 */
  function cols(O){
    var c = [{k:'no',t:'순번',w:7,a:'c'}, {k:'nm',t:'품목 / 규격',w:0,a:'l'},
             {k:'box',t:'BOX수',w:8,a:'r'}, {k:'ea',t:'EA수',w:9,a:'r'}, {k:'qty',t:'총수량',w:9,a:'r'}];
    if (O.price==='Y' || O.boxp==='Y') c.push({k:'up', t:(O.price==='Y'?'단가':'BOX단가'), w:12, a:'r'});
    if (O.amt==='Y')  c.push({k:'amt', t:(O.vat==='Y'?'공급가액':'금액'), w:12, a:'r'});
    if (O.amt==='Y' && O.vat==='Y') c.push({k:'vat', t:'세액', w:10, a:'r'});
    c.push({k:'rm', t:'비고', w:12, a:'l'});
    var used=0; c.forEach(function(x){ used+=x.w; });
    c.forEach(function(x){ if(x.k==='nm') x.w = Math.max(18, 100-used); });
    return c;
  }
  function chgTag(o, O, prev){
    if (O.chg!=='Y' || !prev || prev[o.prodCd]==null) return '';
    var pv = n(prev[o.prodCd]), cur = n(o.unitPrice);
    if (Math.round(pv*100) === Math.round(cur*100)) return '';
    return ' <span class="chg '+(cur>pv?'up':'dn')+'">'+(cur>pv?'▲':'▼')+fmtP(pv)+'</span>';
  }
  function cell(k, o, O, prev, no){
    var sg = (o.trxGb==='반품') ? -1 : 1;          /* 값은 양수로 저장된다 — 반품 줄만 −로 보인다 */
    if (k==='no')  return no;
    if (k==='nm'){
      var h = esc(o.prodNm||'');
      if (o.spec) h += ' <span class="sp">'+esc(o.spec)+'</span>';
      if (o.trxGb==='반품') h += ' <span class="ret">[반품]</span>';
      /* 단가·박스단가를 둘 다 안 찍으면 단가 칸이 없다 — 그때는 변동 표시를 품명 뒤에 */
      if (O.price!=='Y' && O.boxp!=='Y') h += chgTag(o,O,prev);
      return h;
    }
    if (k==='box') return fmt(n(o.boxQty)*sg);
    if (k==='ea')  return fmt(n(o.eaQty)*sg);
    if (k==='qty') return fmt(n(o.qty)*sg);
    if (k==='up'){
      var h2 = (O.price==='Y') ? fmtP(n(o.unitPrice)) : '';
      if (O.boxp==='Y'){
        var pk = n(o.packQty)||1;
        h2 += (h2?'<br>':'') + '<span class="sp">BOX '+fmtP(n(o.unitPrice)*pk)+'</span>';
      }
      return h2 + chgTag(o,O,prev);
    }
    /* ★금액 칸의 뜻은 부가세 출력 여부가 정한다 —
         부가세 출력 : 금액 = 공급가액, 세액 칸이 따로 선다 (합계 = 공급가 + 세액)
         부가세 미출력 : 금액 = 판매금액(부가세 포함) — 그래야 품목 합과 하단 합계가 같다 */
    if (k==='amt') return fmt((O.vat==='Y' ? n(o.supplyAmt) : n(o.totAmt)) * sg);
    if (k==='vat') return fmt(n(o.vatAmt)*sg);
    if (k==='rm')  return esc(o.remark||'');
    return '';
  }
  function nowStr(){
    var d=new Date(), p=function(v){ return ('0'+v).slice(-2); };
    return d.getFullYear()+'-'+p(d.getMonth()+1)+'-'+p(d.getDate())+' '+p(d.getHours())+':'+p(d.getMinutes())+':'+p(d.getSeconds());
  }
  /* 한 부(공급받는자용 b / 공급자 보관용 r) */
  function copy(D,O,S,prev,rs,pi,pn,kind,fill){
    var lab   = (kind==='b') ? '공급받는자용' : '공급자 보관용';
    var last  = (pi === pn-1);
    var cs    = cols(O);
    var money = (O.amt==='Y');
    var bal   = (money && O.bal==='Y');
    var ven   = D.ven || {};
    var vAddr = ((ven.addr||'')+' '+(ven.addr2||'')).trim();
    /* 공급받는자 이메일 (2026-09-09 요청) — 거래처 마스터 TBL_VENDOR_MST.EMAIL 그대로. 없으면 빈 칸 */
    var vMail = ven.email || '';
    var h = '<div class="cp cp-'+kind+(O.inv==='Y'?' inv':'')+'">';
    h += '<div class="top"><span>공급받는자연락처 : '+esc(telNo(ven.hp||ven.tel||''))+'</span>'
       + '<span>인쇄일시 : '+nowStr()+'</span></div>';
    h += '<h1>거 래 명 세 서 <small>('+lab+')</small></h1>';
    h += '<table class="hd">'
       + '<colgroup><col style="width:4%"><col style="width:9%"><col style="width:29%"><col style="width:4%">'
       +   '<col style="width:9%"><col style="width:19%"><col style="width:8%"><col style="width:18%"></colgroup>'
       /* ★'일자' 칸은 두 칸을 합쳐 쓴다 — 첫 칸(4%)은 세로 라벨(공급받는자) 자리라 글자가 잘린다 */
       + '<tr><td class="k" colspan="2">일자</td><td colspan="4" class="c"><b>'+esc(D.dt)+'</b>'
       +      (D.no ? ' ('+esc(D.no)+')' : '')
       +      (D.dlvDt ? ' <span class="sp">납품 '+esc(D.dlvDt)+'</span>' : '')
       +      '</td><td colspan="2" class="c">'+(pi+1)+' / '+pn+'</td></tr>'
       /* ★네 줄 짝맞춤 — 왼쪽(공급받는자) 상호·주소·이메일·합계금액 / 오른쪽(공급자) 사업자·성명 / 상호·업태 / 종목 / 주소.
          세로 라벨의 rowspan 과 줄 수가 어긋나면 표가 통째로 밀린다 — 줄을 더하거나 뺄 때 rowspan 도 같이 고칠 것. */
       + '<tr><td class="k vt" rowspan="4">공<br>급<br>받<br>는<br>자</td>'
       +     '<td colspan="2" class="l big">'+(ven.bizno?'('+esc(bizNo(ven.bizno))+') ':'')+'<b>'+esc(D.venNm||'')+'</b> 귀하</td>'
       +     '<td class="k vt" rowspan="4">공<br>급<br>자</td>'
       +     '<td class="k">사업자</td><td class="c">'+esc(bizNo(S.biz))+'</td>'
       +     '<td class="k">성명</td><td class="c">'+esc(S.ceo)+'</td></tr>'
       + '<tr><td class="k">주소</td><td class="l">'+esc(vAddr)+'</td>'
       +     '<td class="k">상호</td><td class="c">'+esc(S.nm)+'</td>'
       +     '<td class="k">업태</td><td class="c">'+esc(S.cond)+'</td></tr>'
       + '<tr><td class="k">이메일</td><td class="l">'+esc(vMail)+'</td>'
       +     '<td class="k">종목</td><td colspan="3" class="l">'+esc(S.item)+'</td></tr>'
       + '<tr><td class="k">합계금액</td><td class="r"><b>'+(money?fmt(D.t.tot):'')+'</b></td>'
       +     '<td class="k">주소</td><td colspan="3" class="l">'+esc(S.addr)+'</td></tr>'
       + '</table>';
    h += '<table class="it"><colgroup>'
       + cs.map(function(c){ return '<col style="width:'+c.w+'%">'; }).join('')
       + '</colgroup><thead><tr>'
       + cs.map(function(c){ return '<td class="c">'+c.t+'</td>'; }).join('')
       + '</tr></thead><tbody>';
    var base = pi*O.rows, lines = rs.length;
    rs.forEach(function(o,i){
      h += '<tr'+(o.trxGb==='반품'?' class="retrow"':'')+'>'
         + cs.map(function(c){
             return '<td class="'+c.a+'">'+cell(c.k,o,O,prev,('00'+(base+i+1)).slice(-3))+'</td>';
           }).join('') + '</tr>';
    });
    if (last){
      h += '<tr class="sub">' + cs.map(function(c){
             if (c.k==='nm')  return '<td class="l">[ 수량합계 ]</td>';
             if (c.k==='box') return '<td class="r">'+fmt(D.t.box)+'</td>';
             if (c.k==='ea')  return '<td class="r">'+fmt(D.t.ea)+'</td>';
             if (c.k==='qty') return '<td class="r">'+fmt(D.t.qty)+'</td>';
             if (c.k==='amt') return '<td class="r">'+(money?fmt(O.vat==='Y'?D.t.sup:D.t.tot):'')+'</td>';
             if (c.k==='vat') return '<td class="r">'+(money?fmt(D.t.vat):'')+'</td>';
             return '<td></td>';
           }).join('') + '</tr>';
      h += '<tr class="end"><td colspan="'+cs.length+'" class="c">= = = =　이 하 여 백　= = = =</td></tr>';
      lines += 2;
    }
    /* 빈 줄로 채운다 — 한 부 모드면 종이 아래까지(FILL_ONE) */
    for (var f=lines; f<fill; f++)
      h += '<tr class="blank">'+cs.map(function(){ return '<td>&nbsp;</td>'; }).join('')+'</tr>';
    h += '</tbody></table>';
    var memo = esc(D.remark||'') + ((money && n(D.dc)>0) ? ' <span class="sp">(할인 '+fmt(D.dc)+')</span>' : '');
    h += '<table class="ft">'
       /* 계좌·연락처 칸을 넓게 — 은행명+예금주+계좌번호가 한 줄에 들어가야 한다 */
       + '<colgroup><col style="width:8%"><col style="width:12%"><col style="width:8%"><col style="width:12%">'
       +   '<col style="width:8%"><col style="width:12%"><col style="width:9%"><col style="width:31%"></colgroup>'
       + '<tr><td class="k">전잔고</td><td class="r">'+(bal?fmt(D.balBefore):'')+'</td>'
       +     '<td class="k">매출액</td><td class="r">'+(money?fmt(O.vat==='Y'?D.t.sup:D.t.tot):'')+'</td>'
       +     '<td class="k">세액</td><td class="r">'+((money&&O.vat==='Y')?fmt(D.t.vat):'')+'</td>'
       +     '<td class="k">계좌</td><td class="l">'+esc(S.bank)+'</td></tr>'
       + '<tr><td class="k">합계</td><td class="r"><b>'+(money?fmt(D.t.tot):'')+'</b></td>'
       +     '<td class="k">수금</td><td class="r">'+(money?fmt(D.pay):'')+'</td>'
       +     '<td class="k">잔고</td><td class="r">'+(bal?fmt(D.balAfter):'')+'</td>'
       +     '<td class="k">연락처</td><td class="l">'+esc(telNo(S.tel))+'</td></tr>'
       + '<tr><td class="k">메모</td><td colspan="5" class="l">'+memo+'</td>'
       +     '<td class="k">인수자</td><td class="r sig">(인)</td></tr>'
       + '<tr><td class="k">공지사항</td><td colspan="7" class="l">'+esc(S.notice||'')+'</td></tr>'
       + '</table>';
    return h + '</div>';
  }

  var CSS =
    '*{box-sizing:border-box}'
  + 'body{margin:0;background:#f2f3f5;color:#111;font-size:12px;'
  +      "font-family:'맑은 고딕','Malgun Gothic',sans-serif}"
  + '.bar{position:sticky;top:0;z-index:9;display:flex;gap:8px;align-items:center;padding:9px 14px;background:#fff;border-bottom:1px solid #dbe2ea}'
  + '.bar b{font-size:14px;color:#137a6c;margin-right:auto}'
  + '.bar button{height:32px;padding:0 14px;border:1px solid #cfd8e3;border-radius:7px;background:#fff;font-weight:700;cursor:pointer;font-size:13px}'
  + '.bar button.p{background:#137a6c;color:#fff;border-color:#137a6c}'
  + '.pg{width:210mm;min-height:297mm;margin:12px auto;padding:9mm;background:#fff;box-shadow:0 4px 20px rgba(0,0,0,.12)}'
  + '.cut{border-top:1px dashed #9aa5b1;margin:7mm 0 5mm}'
  /* 한 부 — 테두리 색만 다르다(공급받는자용 파랑 · 공급자 보관용 빨강) */
  + '.cp{--ln:#1b4fa0}'
  + '.cp-r{--ln:#c0392b}'
  + '.cp .top{display:flex;justify-content:space-between;font-size:10.5px;color:#333;margin-bottom:2px}'
  + '.cp h1{margin:0 0 4px;text-align:center;font-size:19px;letter-spacing:6px;color:var(--ln)}'
  + '.cp h1 small{font-size:12px;letter-spacing:0;font-weight:700}'
  + '.cp table{width:100%;table-layout:fixed;border-collapse:collapse}'
  + '.cp td{border:1px solid var(--ln);padding:2px 4px;font-size:11px;height:19px;'
  +        'white-space:nowrap;overflow:hidden;text-overflow:ellipsis;vertical-align:middle}'
  + '.cp .k{background:#f4f6f8;text-align:center;font-weight:700;font-size:10.5px}'
  + '.cp .vt{font-weight:800;line-height:1.1;font-size:10.5px;letter-spacing:0}'
  + '.cp .c{text-align:center}.cp .r{text-align:right}.cp .l{text-align:left}'
  + '.cp .big{font-size:12.5px}'
  + '.cp .sp{color:#5a6b7a;font-size:10px}'
  + '.cp .ret{color:#c0392b;font-weight:700}'
  + '.cp tr.retrow td{color:#c0392b}'
  + '.cp .it thead td{background:#f4f6f8;font-weight:800;font-size:10.5px}'
  + '.cp .it tr.sub td{background:#f7f9fa;font-weight:800}'
  + '.cp .it tr.end td{color:#5a6b7a;letter-spacing:2px;font-size:10.5px}'
  + '.cp .it tr.blank td{color:#fff}'
  + '.cp .ft{margin-top:3px}'
  /* 계좌·연락처·메모는 글이 길다 — 한 단계 작게 해서 잘리지 않게 */
  + '.cp .ft td.l{font-size:10.5px}'
  + '.cp .ft .sig{color:#8a97a4}'
  + '.cp .chg{font-size:10px;font-weight:700}'
  + '.cp .chg.up{color:#c0392b}.cp .chg.dn{color:#1b6ec2}'
  /* ★반전 — 머리글·이름칸을 진한 바탕 + 흰 글자. 인쇄에서도 배경이 나오게 색보정을 강제한다 */
  + '.cp.inv .k, .cp.inv .it thead td{background:var(--ln);color:#fff;'
  +        '-webkit-print-color-adjust:exact;print-color-adjust:exact}'
  + '@media print{'
  +   'body{background:#fff}'
  +   '.bar{display:none}'
  +   '.pg{width:auto;min-height:0;margin:0;padding:0;box-shadow:none;page-break-after:always}'
  +   '.pg:last-child{page-break-after:auto}'
  +   '.cut{margin:6mm 0 5mm}'
  +   '@page{size:A4 portrait;margin:9mm 9mm}'
  + '}';

  /* 명세서 본문(페이지들)만 — 문서 뼈대 없이 필요할 때 */
  function body(D,O,S,prev){
    var pgs = pages(sortRows(D.rows||[], O.ord, D.sortMap), O.rows);
    var out = '';
    if (O.mode==='both'){
      /* 한 장에 두 부 — 채우지 않는다(한 부가 종이의 절반이라 채우면 넘친다) */
      var fb = Math.min(O.rows, FILL_BOTH) === O.rows ? O.rows : O.rows;
      pgs.forEach(function(rs,pi){
        out += '<div class="pg two">'
             + copy(D,O,S,prev,rs,pi,pgs.length,'b',fb)
             + '<div class="cut"></div>'
             + copy(D,O,S,prev,rs,pi,pgs.length,'r',fb)
             + '</div>';
      });
    } else {
      /* ★한 부 = 종이 아래까지 채운다 (2026-09-09 「한 장일 때는 아래까지」) */
      var fo = Math.max(O.rows, FILL_ONE);
      var kinds = (O.mode==='two') ? ['b','r'] : (O.mode==='b1' ? ['b'] : ['r']);
      kinds.forEach(function(k){
        pgs.forEach(function(rs,pi){
          out += '<div class="pg">'+copy(D,O,S,prev,rs,pi,pgs.length,k,fo)+'</div>';
        });
      });
    }
    return { html: out, pages: pgs.length };
  }

  /* 문서 한 장 통째 — 새 창(판매등록)·공개 페이지가 함께 쓴다 */
  function doc(D,O,S,prev,opt){
    opt = opt || {};
    var b = body(D,O,S,prev);
    var title = '거래명세서 — '+(D.venNm||'')+' '+(D.dt||'')+(D.no?' / '+D.no:'');
    /* ★[🖨 인쇄]로 연 창은 <프린터로 보낸 뒤 스스로 닫힌다> (2026-09-09 「인쇄시 프린터로 갔다가 우리쪽으로 화면 다시옴」) —
         인쇄가 끝나도 이 창이 남아 있어 사람이 손으로 닫아야 우리 화면으로 돌아왔다.
         `afterprint` 는 <인쇄>든 <취소>든 대화상자를 닫으면 뜨므로 어느 쪽이든 제자리로 돌아온다.
       ⚠[👁 미리보기]로 연 창은 이 script 를 안 넣는다 — 보라고 연 창이라 저절로 닫히면 안 된다.
         (그 창 안 [🖨 인쇄] 단추로 찍어도 창은 남는다.)
       ⚠`afterprint` 를 안 쏘는 브라우저에서는 그냥 창이 남는다 — 종전과 같을 뿐 나빠지지 않는다. */
    var auto = opt.autoPrint
      ? '<scr'+'ipt>(function(){var done=false;'
        + 'function bye(){ if(done) return; done=true; setTimeout(function(){ try{ window.close(); }catch(e){} }, 200); }'
        + 'window.addEventListener("afterprint", bye);'
        + 'window.addEventListener("load", function(){ setTimeout(function(){ window.print(); }, 300); });'
        + '})();</scr'+'ipt>'
      : '';
    return '<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8">'
         + '<meta name="viewport" content="width=device-width, initial-scale=1">'
         + '<title>'+esc(title)+'</title><style>'+CSS+'</style></head><body>'
         /* ★조건 창과 <같은 말·같은 숫자>로 적는다 (2026-09-09 「인쇄시 조금 모순이 있어서」) —
              종전에는 「1장 × 두 부(따로)」라 적었는데, 그 1장은 <한 부당> 장수라
              조건 창의 「모두 2장」과 서로 다른 숫자를 말하는 셈이었다. 실제로 나가는 것은 2장이다. */
         + '<div class="bar"><b>🧾 '+esc(title)+'</b>'
         + '<span style="color:#5a6b7a;font-size:12px;margin-right:8px">'
         + '모두 ' + ((O.mode==='two') ? b.pages*2 : b.pages) + '장 · '
         + (O.mode==='both' ? '한 장에 두 부'
           : O.mode==='two' ? '두 부(따로)'
           : O.mode==='b1'  ? '공급받는자용 한 부' : '공급자 보관용 한 부')
         + (opt.note ? ' · '+esc(opt.note) : '')+'</span>'
         + '<button class="p" onclick="window.print()">🖨 인쇄</button>'
         + (opt.close===false ? '' : '<button onclick="window.close()">닫기</button>')
         + '</div>' + b.html + auto + '</body></html>';
  }

  g.konetStmt = { DEF:DEF, FILL_ONE:FILL_ONE, FILL_BOTH:FILL_BOTH,
                  doc:doc, body:body, cols:cols, pages:pages, sortRows:sortRows, css:CSS };
})(window);
