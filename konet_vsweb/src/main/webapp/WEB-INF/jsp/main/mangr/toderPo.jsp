<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>토더 발주 등록</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 읽기 (전역 XLSX) --%>
<!--
  토더 발주 등록 (2026-09-21 신설 — 「토더라는 곳에서 발주 엑셀로 받아서 출고 업로드 … 기존 DC 발주 등록과 같은 개념」) — 매출 관리 ▸ 토더 발주 등록. 셸 iframe(logiFrame) 화면.
  · 토더(가맹점 발주 플랫폼, 예: 샐러링)의 「상품별 발주 목록」 엑셀을 올린다. 머리 줄 = no·배송지명·배송담당자·발주번호·발주일시·출고마감일·상품명·단위·매입가·발주수량·출고수량·상품 상태 …
  · 엑셀에는 사업장코드·품목코드가 없다 → 줄마다 둘 다 넣고 [💾 저장]. 같은 배송지명·같은 상품명의 빈 칸은 한 번 넣으면 같이 채워진다.
    저장하면 (배송지명 → 사업장코드), (상품명 → 품목코드) 짝이 쌓여 다음 업로드부터 자동으로 채워진다(/shipout/toderPoMap.do — 저장된 토더 발주에서 읽는다, 표를 따로 안 둔다).
  · 발주일자(발주일시의 날짜) = 납기일자 = 출고일자. 수량 = 출고수량이 있으면 그것, 없으면 발주수량. 상태가 취소·반품이면 기본으로 체크를 뺀다.
  · 저장 = TBL_SHIPOUT_MST PROD_KIND='TD'(출고장 「토더」) + 재고 연동 (2026-09-21 저녁 「토더도 재고 맞추어 주고 정산서는 사용자 협의 후」) —
    저장·삭제하면 그 발주일자들의 출고 원장을 다시 만들어 재고에서 뺀다. 그 날 삼성웰스토리 정산서가 있어도 토더 줄은 뺀다(그 정산서에 토더는 없다).
    ★매출은 아직 안 잡는다 (2026-09-21 「일단 재고만 맞추고 반품이 정산서 형태로 오면 매출 및 재고 조정으로」) — 마감(selectClosing)·매출 그래프(월·일)의 출고 블록에서 TD 를 뺐다.
    정산서 대사에서도 뺀다. 월별 출고현황(출고 수량)에는 보이고, 납기현황관리에서는 뺀다. 반품·정산 자료가 (발주번호, 번호 = ORD_ITEM_NO)로 오면 그때 매출·재고 조정을 붙인다.
    같은 (발주번호, 배송지명, 상품명)을 다시 올리면 앞의 것을 대체한다(같은 기간을 여러 번 받아 올려도 중복되지 않는다).
  · 원본 파일은 보관하지 않는다(DC 발주와 같다). 파일 이름만 남는다.
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); } .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); } .btn-red{ color:var(--red); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .drop{ margin:12px; border:1.5px dashed #b9c9c4; border-radius:10px; padding:20px; text-align:center; color:#37475a; cursor:pointer; background:#fbfdfc; }
  .drop.on{ background:#e3f2ee; border-color:var(--teal); }
  .drop b{ color:var(--teal); }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:4px 6px; text-align:center; white-space:nowrap; vertical-align:middle; }
  table.g td.l{ text-align:left; } table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g input[type=text]{ height:30px; border:1.5px solid #e9b98a; background:#fdebd9; border-radius:6px; padding:0 6px; font-size:13px; width:130px; }
  table.g input[type=text].ok{ border-color:#7cc5b2; background:#f3fbf8; }
  table.g input[type=text].auto{ border-color:#9db7e8; background:#eef3fd; }
  table.g input[type=text].bad{ border-color:#e2b93b; background:#fff7d6; }
  table.g tr.off td{ color:#9aa7b3; background:#fafbfc; }
  .sub{ display:block; font-size:11.5px; color:#6b7a89; margin-top:1px; max-width:230px; overflow:hidden; text-overflow:ellipsis; }
  .sub.warn{ color:var(--amber); }
  .sub.nmf{ font-size:13px; color:#1f2a37; font-weight:700; margin:0 0 3px; max-width:260px; }   /* 명칭을 앞(위)에 */
  table.g input[type=text]{ width:170px; }
  .bd{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .bd.auto{ background:#e8eefb; color:#2f4f9a; } .bd.st{ background:#eef2f5; color:#556; } .bd.cx{ background:#fdecec; color:var(--red); }
  .dim{ color:#8a98a8; }
  input[type=date]{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; }
  .msg{ padding:22px; text-align:center; color:#8a98a8; }
  .note{ font-size:12.5px; color:#6b7a89; padding:8px 12px; line-height:1.6; }
</style>
</head>
<body>
<div class="wrap">
  <h2>🛒 토더 발주 등록 <small>— 토더 「상품별 발주 목록」 엑셀을 올려 출고로 저장한다. 사업장코드·품목코드는 한 번 넣으면 다음부터 자동으로 채워진다</small></h2>

  <div class="card">
    <div class="hd">올리기 <small>— 엑셀(xlsx). 여러 개를 한 번에 올려도 된다</small>
      <span class="bar" style="margin-left:auto">
        <span id="pvInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
        <button class="btn" id="btnOnlyNo" onclick="onlyNoToggle()" style="display:none">미입력 줄만</button>
        <button class="btn btn-teal" id="btnSave" onclick="save()" style="display:none">💾 저장</button>
        <button class="btn" id="btnClear" onclick="pvClear()" style="display:none" title="화면에 올려 둔 엑셀 내용을 비웁니다(저장된 것은 그대로)">업로드 취소</button>
      </span>
    </div>
    <div class="drop" id="drop" onclick="document.getElementById('fi').click()">📄 <b>토더 발주 엑셀</b>을 여기에 끌어다 놓거나 눌러서 고르세요
      <div class="dim" style="font-size:12.5px;margin-top:4px">배송지명 · 발주번호 · 발주일시 · 상품명 · 단위 · 매입가 · 발주수량 · 출고수량 · 상품 상태를 읽습니다</div></div>
    <input type="file" id="fi" accept=".xlsx,.xls" multiple style="display:none" onchange="onFiles(this.files); this.value=''">
    <div class="tw" id="pvWrap" style="display:none;max-height:56vh">
      <table class="g"><thead><tr>
        <th><input type="checkbox" id="pvAll" checked onchange="pvAllChk(this)"></th><th title="엑셀의 no 그대로">No</th><th>발주일자</th><th>발주번호</th><th title="우리 사업장코드 — 한 번 넣으면 같은 배송지명의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">사업장코드</th><th>배송지명</th>
        <th title="우리 품목코드(상품코드) — 한 번 넣으면 같은 상품명의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">품목코드</th><th>상품명</th>
        <th>단위</th><th>수량</th><th>단가</th><th>상태</th></tr></thead>
        <tbody id="pvBody"></tbody></table>
    </div>
    <div class="note" id="pvNote" style="display:none">· 주황 칸 = 넣어야 하는 칸 · 파랑 = 자동으로 채운 값(「자동」 = 지난 저장, 「추정」 = 사업장 마스터 이름과 맞춰 본 것 — 확인 필요) · 초록 = 마스터에 있는 코드 · 노랑 = 마스터에 없는 코드(<b>저장 안 됨</b> — 사업장·상품 마스터에 먼저 등록) · 코드가 둘 다 든 줄만 저장된다 · 저장한 뒤에도 아래 목록에서 코드를 고칠 수 있다</div>
  </div>

  <div class="card">
    <div class="hd">저장된 토더 발주 <small>— 발주일자 기준</small>
      <span class="bar" style="margin-left:auto">
        <input type="date" id="fr"> <span class="dim">~</span> <input type="date" id="to">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn btn-red" onclick="delSel()">🗑 선택 삭제</button>
        <span id="lsInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
      </span>
    </div>
    <div class="tw" style="max-height:50vh"><table class="g"><thead><tr>
      <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th><th>발주일자</th><th>발주번호</th><th title="토더 엑셀의 no — 반품이 (발주번호, 번호)로 온다">번호</th><th>구분</th><th>배송지명</th><th>사업장코드</th><th>상품명</th><th>품목코드</th><th>단위</th><th>수량</th><th>비고</th><th>올린 파일</th><th>등록</th></tr></thead>
      <tbody id="lsBody"><tr><td colspan="14" class="msg">[🔍 조회]를 누르세요.</td></tr></tbody></table></div>
  </div>
</div>
<datalist id="bizList"></datalist><datalist id="prodList"></datalist>

<script>
var CTX='${pageContext.request.contextPath}';
function n(v){ if(v==null) return 0; var x=parseFloat(String(v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return n(v).toLocaleString('ko-KR'); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }); }
function ok(m){ _alertBox(m,{icon:'✅'}); } function err(m){ _alertBox(m,{icon:'⚠️'}); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }

/* ── 기준자료 : 사업장·상품 마스터(이름 확인·찾기) + 자동 매칭(지난 저장) ── */
var _biz={}, _prod={}, _map={ biz:{}, item:{} }, _pv=[], _ls=[], _onlyNo=false;
function loadMasters(){
  var p1=post('/mangr/clientList.do','findData=').then(function(r){ return r.json(); }).then(function(j){ _biz={}; var h=[]; ((j&&j.data)||[]).forEach(function(o){ if(!o.bizCd) return; _biz[String(o.bizCd)]=o.bizNm||''; h.push('<option value="'+esc((o.bizNm||'')+' ['+o.bizCd+']')+'"></option>'); }); document.getElementById('bizList').innerHTML=h.join(''); }).catch(function(){});
  var p2=post('/prod/prodList.do','').then(function(r){ return r.json(); }).then(function(j){ _prod={}; var h=[]; ((j&&j.data)||[]).forEach(function(o){ if(!o.prodCd) return; _prod[String(o.prodCd)]=o.prodNm||''; h.push('<option value="'+esc((o.prodNm||'')+' ['+o.prodCd+']')+'"></option>'); }); document.getElementById('prodList').innerHTML=h.join(''); }).catch(function(){});
  var p3=post('/prod/extItemList.do','').then(function(r){ return r.json(); }).then(function(j){ ((j&&j.data)||[]).forEach(function(o){ if(o.extItemCd && !_prod[String(o.extItemCd)]) _prod[String(o.extItemCd)]=(o.extItemNm||'')+' 〔매칭코드〕'; }); }).catch(function(){});
  var p4=post('/shipout/toderPoMap.do','').then(function(r){ return r.json(); }).then(function(j){ _map={ biz:(j&&j.biz)||{}, item:(j&&j.item)||{} }; }).catch(function(){});
  return Promise.all([p1,p2,p3,p4]).then(function(){ if(_pv.length){ autoFill(); pvRender(); } });
}

/* ── 엑셀 읽기 ── */
var HDR={ no:['no','No','NO','번호'], bizNm:['배송지명'], ordNo:['발주번호'], ordDttm:['발주일시'], dueDt:['출고마감일'], itemNm:['상품명'], unit:['단위'], price:['매입가'], ordQty:['발주수량'], outQty:['출고수량'], status:['상품 상태','상품상태','상태'] };
function cellTxt(v){ if(v==null) return ''; if(v instanceof Date) return ymd(v)+' '+('0'+v.getHours()).slice(-2)+':'+('0'+v.getMinutes()).slice(-2)+':'+('0'+v.getSeconds()).slice(-2); return String(v).trim(); }
function parseWb(wb, fileNm){
  var brand=(/^(.+?)[_\s]*상품별/.exec(fileNm)||[])[1]||'', out=[];
  wb.SheetNames.forEach(function(sn){
    var aoa=XLSX.utils.sheet_to_json(wb.Sheets[sn],{ header:1, raw:true, defval:'' }), hr=-1, col={};
    for(var r=0;r<Math.min(aoa.length,30);r++){ var row=aoa[r].map(cellTxt); if(row.indexOf('배송지명')>=0 && row.indexOf('상품명')>=0){ hr=r; for(var k in HDR){ col[k]=-1; HDR[k].forEach(function(nm){ if(col[k]<0) col[k]=row.indexOf(nm); }); } break; } }
    if(hr<0) return;
    for(var i=hr+1;i<aoa.length;i++){ var a=aoa[i], g=function(k){ return col[k]>=0? cellTxt(a[col[k]]) : ''; };
      var bizNm=g('bizNm'), itemNm=g('itemNm'); if(!bizNm && !itemNm) continue;
      var dttm=g('ordDttm'), dlv=d10(dttm), st=g('status'), oq=n(g('outQty')), rq=n(g('ordQty'));
      out.push({ no:g('no'), seq:out.length, chk: !/취소|반품/.test(st), brand:brand, fileNm:fileNm, bizNm:bizNm, ordNo:g('ordNo'), ordDttm:dttm, dlvDt:dlv, dueDt:d10(g('dueDt')), itemNm:itemNm, unit:g('unit'), price:n(g('price')), qty:(oq||rq), status:st, bizCd:'', itemCd:'', bizAuto:false, itemAuto:false });
    }
  });
  return out;
}
function onFiles(files){
  var list=Array.prototype.slice.call(files||[]); if(!list.length) return;
  var jobs=list.map(function(f){ return new Promise(function(res){ var rd=new FileReader(); rd.onload=function(e){ try{ var wb=XLSX.read(new Uint8Array(e.target.result),{ type:'array', cellDates:true }); res({ nm:f.name, rows:parseWb(wb,f.name) }); }catch(x){ res({ nm:f.name, rows:[], err:x.message }); } }; rd.readAsArrayBuffer(f); }); });
  Promise.all(jobs).then(function(rs){
    var bad=[], add=[]; rs.forEach(function(r){ if(!r.rows.length) bad.push(esc(r.nm)+(r.err?' — '+esc(r.err):' — 머리 줄(배송지명·상품명)을 못 찾았습니다')); else add=add.concat(r.rows); });
    /* 같은 (발주번호, 배송지명, 상품명) 은 나중 것으로 */
    var seen={}; _pv.concat(add).forEach(function(x){ seen[x.ordNo+'|'+x.bizNm+'|'+x.itemNm]=x; }); _pv=Object.keys(seen).map(function(k){ return seen[k]; });
    /* 엑셀에 적힌 차례 그대로(파일 이름 → 줄 차례). 여러 파일이면 파일별로 이어 붙는다 */
    _pv.sort(function(a,b){ return String(a.fileNm||'').localeCompare(String(b.fileNm||'')) || (a.seq-b.seq); });
    autoFill(); pvRender();
    if(bad.length) err('읽지 못한 파일<br><span style="font-size:13px">'+bad.join('<br>')+'</span>');
  });
}
/* 이름 다듬기 — 브랜드 말·빈칸·괄호·끝의 「점」을 떼고 견준다 : 토더 「강남역점」 ↔ 마스터 「샐러링 강남역」 */
function normNm(s, brand){ s=String(s||''); if(brand) s=s.split(brand).join(''); return s.replace(/\([^)]*\)/g,'').replace(/\s+/g,'').replace(/점$/,'').toLowerCase(); }
function guessBiz(x){
  var key=normNm(x.bizNm, x.brand); if(!key) return '';
  var hit=[]; for(var cd in _biz){ var nm=_biz[cd]; if(x.brand && String(nm).indexOf(x.brand)<0) continue; if(normNm(nm, x.brand)===key) hit.push(cd); }
  return hit.length===1 ? hit[0] : '';   /* 하나로 떨어질 때만 */
}
function autoFill(){ _pv.forEach(function(x){
  if(!x.bizCd && _map.biz[x.bizNm]){ x.bizCd=_map.biz[x.bizNm]; x.bizAuto=true; x.bizGuess=false; }
  if(!x.bizCd){ var g=guessBiz(x); if(g){ x.bizCd=g; x.bizAuto=true; x.bizGuess=true; } }
  if(!x.itemCd && _map.item[x.itemNm]){ x.itemCd=_map.item[x.itemNm]; x.itemAuto=true; } }); }
function cdCls(cd, mst, auto){ if(!cd) return ''; return mst[cd]!=null ? (auto?'auto':'ok') : 'bad'; }
function pvRender(){
  var has=_pv.length>0;
  ['pvWrap','pvNote'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  ['btnSave','btnClear','btnOnlyNo'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  document.getElementById('btnOnlyNo').textContent=_onlyNo?'전체 줄 보기':'미입력 줄만';
  var tb=document.getElementById('pvBody');
  tb.innerHTML=_pv.map(function(x,i){
    if(_onlyNo && x.bizCd && x.itemCd) return '';
    var bn=_biz[x.bizCd], pn=_prod[x.itemCd];
    return '<tr class="'+(x.chk?'':'off')+'"><td><input type="checkbox" '+(x.chk?'checked':'')+' onchange="_pv['+i+'].chk=this.checked; pvRender()"></td><td>'+esc(x.no!==''&&x.no!=null?x.no:(i+1))+'</td><td>'+esc(x.dlvDt)+'</td><td>'+esc(x.ordNo)+'</td>'
      +'<td class="l">'+(x.bizCd?'<span class="sub nmf'+(bn==null?' warn':'')+'">'+(x.bizAuto?'<span class="bd auto" title="'+(x.bizGuess?'사업장 마스터의 이름과 맞춰 본 추정 — 맞는지 확인하세요':'지난 저장에서 가져온 값')+'">'+(x.bizGuess?'추정':'자동')+'</span> ':'')+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span>':'')+'<input type="text" list="bizList" class="'+cdCls(x.bizCd,_biz,x.bizAuto)+'" value="'+esc(x.bizCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'biz\',this.value)"></td>'
      +'<td class="l">'+esc(x.bizNm)+'</td>'
      +'<td class="l">'+(x.itemCd?'<span class="sub nmf'+(pn==null?' warn':'')+'">'+(x.itemAuto?'<span class="bd auto">자동</span> ':'')+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span>':'')+'<input type="text" list="prodList" class="'+cdCls(x.itemCd,_prod,x.itemAuto)+'" value="'+esc(x.itemCd)+'" placeholder="명칭 또는 코드" onchange="setCd('+i+',\'item\',this.value)"></td>'
      +'<td class="l">'+esc(x.itemNm)+'</td>'
      +'<td>'+esc(x.unit)+'</td><td class="r"><b>'+fmt(x.qty)+'</b></td><td class="r">'+(x.price?fmt(x.price):'')+'</td><td><span class="bd '+(/취소|반품/.test(x.status)?'cx':'st')+'">'+esc(x.status)+'</span></td></tr>';
  }).join('');
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(function(x){ return x.bizCd&&x.itemCd&&x.dlvDt&&x.qty; });
  var unk=rdy.filter(function(x){ return _biz[x.bizCd]==null || _prod[x.itemCd]==null; }).length;   /* 마스터에 없는 코드 — 저장 막힘(2026-09-22) */
  document.getElementById('pvInfo').textContent='올린 줄 '+_pv.length+' · 선택 '+sel.length+' · 저장 가능 '+(rdy.length-unk)+(sel.length-rdy.length?' · 코드 빈 줄 '+(sel.length-rdy.length):'')+(unk?' · 마스터에 없는 코드 '+unk+'줄(저장 막힘)':'');
  document.getElementById('pvAll').checked=_pv.every(function(x){ return x.chk; });
}
/* 코드 한 번 넣으면 같은 이름의 빈 칸(또는 자동으로 채워졌던 칸)에 같이 */
/* 목록에서 고른 「명칭 [코드]」 → 코드. 코드만 친 것은 그대로, 명칭만 정확히 친 것은 마스터에서 찾는다 */
function pickCd(v, mst){
  v=String(v||'').trim(); var m=/\[([^\[\]]+)\]\s*$/.exec(v); if(m) return m[1].trim();
  if(mst[v]!=null) return v;
  var hit=[]; for(var cd in mst){ if(String(mst[cd]).trim()===v) hit.push(cd); } return hit.length===1? hit[0] : v;
}
function setCd(i, kind, v){
  v=pickCd(v, kind==='biz'?_biz:_prod); var x=_pv[i]; if(!x) return;
  if(kind==='biz'){ var nm=x.bizNm; _pv.forEach(function(y){ if(y===x || (y.bizNm===nm && (!y.bizCd || y.bizAuto))){ y.bizCd=v; y.bizAuto=false; y.bizGuess=false; } }); }
  else { var inm=x.itemNm; _pv.forEach(function(y){ if(y===x || (y.itemNm===inm && (!y.itemCd || y.itemAuto))){ y.itemCd=v; y.itemAuto=false; } }); }
  pvRender();
}
function pvAllChk(el){ _pv.forEach(function(x){ x.chk=el.checked; }); pvRender(); }
function onlyNoToggle(){ _onlyNo=!_onlyNo; pvRender(); }
function pvClear(){ _pv=[]; _onlyNo=false; pvRender(); }

function save(){
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(function(x){ return x.bizCd&&x.itemCd&&x.dlvDt&&x.qty; }), miss=sel.length-rdy.length;
  if(!rdy.length){ err('저장할 줄이 없습니다 — 사업장코드·품목코드를 넣으세요.'); return; }
  /* ★[2026-09-22 「사업장코드·품목코드 선택한 것에 대하여 없으면 등록 안 되게」] 마스터에 없는 코드가 든 줄이 있으면 저장하지 않는다.
       종전엔 「그래도 저장됩니다」였다 — 그런 줄은 재고에서 조용히 빠졌다. 서버(toderPoSave)도 같은 관문으로 거절한다. */
  var unk=rdy.filter(function(x){ return _biz[x.bizCd]==null || _prod[x.itemCd]==null; });
  if(unk.length){
    var ub={}, ui={}; unk.forEach(function(x){ if(_biz[x.bizCd]==null) ub[x.bizCd]=1; if(_prod[x.itemCd]==null) ui[x.itemCd]=1; });
    err('마스터에 없는 코드가 든 줄이 <b>'+unk.length+'</b>개 있어 저장하지 않았습니다.<br><span style="font-size:13px">'
      +(Object.keys(ub).length?'사업장코드 : <b>'+esc(Object.keys(ub).join(', '))+'</b> — 거래처관리(사업장)에 먼저 등록<br>':'')
      +(Object.keys(ui).length?'품목코드 : <b>'+esc(Object.keys(ui).join(', '))+'</b> — 상품코드등록·매칭코드에 먼저 등록<br>':'')
      +'노란 칸을 고치거나 그 줄의 체크를 빼고 다시 저장하세요.</span>');
    return;
  }
  _confirmBox({ icon:'💾', okText:'저장',
    msg:'토더 발주 <b>'+rdy.length+'</b>줄을 출고로 저장합니다.'+(miss?'<br><span style="color:#b45309;font-size:13px">코드가 빈 '+miss+'줄은 저장하지 않습니다(화면에 남습니다).</span>':'')
       +'<br><span style="font-size:13px;color:#3d4d5c">같은 발주번호·배송지명·상품명이 이미 있으면 새것으로 대체합니다.</span>',
    onOk:function(){
      var b=document.getElementById('btnSave'); b.disabled=true;
      var brand=(rdy[0].brand||'');
      post('/shipout/toderPoSave.do',{ brand:brand, rows:rdy.map(function(x){ return { no:x.no, dlvDt:x.dlvDt, bizCd:x.bizCd, bizNm:x.bizNm, itemCd:x.itemCd, itemNm:x.itemNm, unit:x.unit, qty:x.qty, ordNo:x.ordNo, ordDttm:x.ordDttm, dueDt:x.dueDt, price:x.price||'', status:x.status, fileNm:x.fileNm }; }) },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){
          var warn=/\|STOCKFAIL:(.*)$/.exec(t), cnt=parseInt(t,10)||rdy.length;
          rdy.forEach(function(x){ _map.biz[x.bizNm]=x.bizCd; _map.item[x.itemNm]=x.itemCd; });
          _pv=_pv.filter(function(x){ return rdy.indexOf(x)<0; }); pvRender();
          var ds=rdy.map(function(x){ return x.dlvDt; }).sort(); document.getElementById('fr').value=ds[0]; document.getElementById('to').value=ds[ds.length-1]; load();
          ok('토더 발주 <b>'+cnt+'</b>줄을 저장했습니다.'+(_pv.length?'<br><span style="font-size:13px">코드가 빈 '+_pv.length+'줄이 화면에 남아 있습니다.</span>':'')+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':''));
        })
        .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
        .then(function(){ b.disabled=false; });
    }, onCancel:function(){} });
}

/* ── 저장된 목록 ── */
function load(){
  document.getElementById('lsBody').innerHTML='<tr><td colspan="14" class="msg">조회 중…</td></tr>';
  post('/shipout/toderPoList.do','frDt='+encodeURIComponent(document.getElementById('fr').value)+'&toDt='+encodeURIComponent(document.getElementById('to').value))
    .then(function(r){ return r.json(); }).then(function(j){ _ls=(j&&j.data)||[]; lsRender(); })
    .catch(function(e){ document.getElementById('lsBody').innerHTML='<tr><td colspan="14" class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsRender(){
  var tb=document.getElementById('lsBody'); document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="14" class="msg">저장된 토더 발주가 없습니다.</td></tr>'; document.getElementById('lsInfo').textContent=''; return; }
  var q=0;
  tb.innerHTML=_ls.map(function(x,i){ q+=n(x.qty);
    /* ★[2026-09-22 「저장 후 품목코드·사업장코드 수정 가능하게」] 두 코드 칸을 입력칸으로 — 고르면 확인창 뒤 lsCd(이름 단위로 고친다) */
    var bn=_biz[x.bizCd], pn=_prod[x.itemCd];
    return '<tr><td><input type="checkbox" class="lchk" data-i="'+i+'"></td><td>'+d10(x.dlvDt)+'</td><td>'+esc(x.ordNo)+'</td><td><b>'+esc(x.lineNo)+'</b></td><td>'+esc(x.dcNm)+'</td><td class="l">'+esc(x.bizNm)+'</td>'
      +'<td class="l"><span class="sub nmf'+(bn==null?' warn':'')+'">'+esc(bn!=null?bn:'사업장 마스터에 없는 코드')+'</span><input type="text" list="bizList" class="'+(bn==null?'bad':'ok')+'" value="'+esc(x.bizCd)+'" title="고르거나 쳐서 바꾸면 같은 배송지명의 저장된 줄이 모두 바뀝니다" onchange="lsCd('+i+',\'biz\',this)"></td>'
      +'<td class="l">'+esc(x.itemNm)+'</td><td class="l"><span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span><input type="text" list="prodList" class="'+(pn==null?'bad':'ok')+'" value="'+esc(x.itemCd)+'" title="고르거나 쳐서 바꾸면 같은 상품명의 저장된 줄이 모두 바뀌고 재고도 다시 맞춥니다" onchange="lsCd('+i+',\'item\',this)">'+(x.prodCd&&x.prodCd!==x.itemCd?'<span class="sub">주코드 '+esc(x.prodCd)+'</span>':'')+'</td><td>'+esc(x.unit)+'</td><td class="r"><b>'+fmt(x.qty)+'</b></td>'
      +'<td class="l dim" style="max-width:260px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.remark)+'">'+esc(x.remark)+'</td><td class="l dim" style="max-width:200px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.srcFile)+'">'+esc(x.srcFile)+'</td><td class="dim">'+esc(String(x.uploadDttm||'').slice(0,16))+'<br>'+esc(x.regUser)+'</td></tr>'; }).join('');
  document.getElementById('lsInfo').textContent=_ls.length+'줄 · 수량 '+fmt(q);
}
/* 저장된 줄의 코드 고치기 (2026-09-22) — 이름(배송지명 / 상품명) 단위로 저장된 줄을 모두 바꾼다(조회 기간 밖 포함).
     코드는 이름에 붙는 값이라 한 줄만 바꾸면 같은 이름의 다른 줄과 다음 업로드의 자동 매칭이 옛 코드로 남는다.
     새 코드도 마스터에 있어야 한다(서버 toderPoCode 가 한 번 더 본다). 품목을 바꾸면 서버가 그 날짜들의 재고를 다시 맞춘다. */
function lsCd(i, kind, el){
  var x=_ls[i]; if(!x) return;
  var mst=kind==='biz'?_biz:_prod, old=kind==='biz'?x.bizCd:x.itemCd, nm=kind==='biz'?x.bizNm:x.itemNm, cd=pickCd(el.value, mst);
  var lab=kind==='biz'?'사업장코드':'품목코드', nmLab=kind==='biz'?'배송지명':'상품명';
  if(!cd || cd===old){ el.value=old; return; }
  if(mst[cd]==null){ el.value=old; err(lab+' <b>'+esc(cd)+'</b> 는 마스터에 없습니다 — '+(kind==='biz'?'거래처관리(사업장)':'상품코드등록·매칭코드')+'에 먼저 등록하세요.'); return; }
  var same=_ls.filter(function(y){ return (kind==='biz'?y.bizNm:y.itemNm)===nm; }).length;
  _confirmBox({ icon:'✏️', okText:'고치기',
    msg:nmLab+' <b>'+esc(nm)+'</b> 의 '+lab+'를<br><b>'+esc(old)+'</b> → <b>'+esc(cd)+'</b> ('+esc(mst[cd])+') 로 고칩니다.'
      +'<br><span style="font-size:13px;color:#3d4d5c">같은 '+nmLab+'으로 저장된 줄이 모두 바뀝니다(지금 목록 '+same+'줄 · 조회 기간 밖 포함).'
      +(kind==='item'?' 그 날짜들의 재고를 다시 맞춥니다.':'')+' 다음 업로드의 자동 매칭도 새 코드로 채워집니다.</span>',
    onOk:function(){
      post('/shipout/toderPoCode.do',{ kind:kind, nm:nm, cd:cd },true)
        .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); _map[kind][nm]=cd; load();
          ok(lab+'를 고쳤습니다 — <b>'+(parseInt(t,10)||0)+'</b>줄.'+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':'')); })
        .catch(function(e){ el.value=old; err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
    }, onCancel:function(){ el.value=old; } });
}
function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function delSel(){
  var keys=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) keys.push({ dlvDt:x.dlvDt, ordNo:x.ordNo, bizNm:x.bizNm, itemNm:x.itemNm }); });
  if(!keys.length){ err('삭제할 줄을 고르세요.'); return; }
  _confirmBox({ icon:'🗑', okText:'삭제', msg:'고른 토더 발주 <b>'+keys.length+'</b>줄을 삭제합니다.<br><span style="font-size:13px;color:#3d4d5c">출고 자료에서 빠지고 재고도 다시 맞춥니다. (자동 매칭용 이름 → 코드 짝은 남습니다)</span>',
    onOk:function(){ post('/shipout/toderPoDelete.do',{ keys:keys },true).then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
      .then(function(t){ var warn=/\|STOCKFAIL:(.*)$/.exec(t); load(); ok((parseInt(t,10)||0)+'줄을 삭제했습니다.'+(warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(warn[1])+'</span>':'')); })
      .catch(function(e){ err('삭제하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }, onCancel:function(){} });
}

/* ── 끌어다 놓기 · 시작 ── */
(function(){
  var d=document.getElementById('drop');
  ['dragenter','dragover'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.add('on'); }); });
  ['dragleave','drop'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.remove('on'); }); });
  d.addEventListener('drop',function(e){ onFiles(e.dataTransfer.files); });
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth(), t.getDate()-14);
  document.getElementById('fr').value=ymd(a); document.getElementById('to').value=ymd(t);
  loadMasters();
})();
window.konetShown=function(){ loadMasters(); };   /* 다른 화면에서 사업장·상품을 고치고 돌아오면 새로 */
</script>
</body>
</html>
