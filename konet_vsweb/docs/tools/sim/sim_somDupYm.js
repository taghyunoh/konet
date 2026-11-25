// 월별 출고현황 — 년월 줄 중복 회귀 + 2026-11-24 원복 확인
//   ① 그 달 첫 줄의 수량이 0 이어도 같은 달이 한 번만 들어간다(!yms[ym] → ym in yms)
//   ② 원복 (사용자 「정산 발주 매칭해서 했는데 대사하기도 힘들고 원래대로 원복이 나을듯」) : 칸 = 정산서 온 날은 정산서 · 아니면 발주현황표 —
//      「칸 = 발주수량 · 다르면 정산 n」·차이만·반품 배지·추정 짝 상한은 화면·SQL 에서 걷어냈다. 발주 ↔ 정산 대사는 「정산서 누락 조회」가 맡는다.
//   실행 : node docs/tools/sim/sim_somDupYm.js (jsdom 불필요)
const fs=require('fs'), path=require('path');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/WEB-INF/jsp/main/mangr/stockOutMonth.jsp'),'utf8').replace(/\r\n/g,'\n');
const X=fs.readFileSync(path.join(__dirname,'../../../src/main/resources/egovframework/sqlmap/mapper/User_SQL.xml'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } };
const blkOf=id=>{ const i=X.indexOf('<select id="'+id+'"'); return X.slice(i, X.indexOf('</select>', i)); };
// ① 같은 달 중복
const F=new Function('var RAW=null; function somQuery(){ return ""; }\n'+pick('somBuild')+'\nreturn function(raw){ RAW=raw; return somBuild(); };')();
const mk=(ym,biz,cd,q)=>({ ym:ym, bizKey:biz, bizNm:biz, prodCd:cd, prodNm:cd, outQty:q, newQty:0 });
const m=F({ stock:[], months:[ mk('202610','A','P1',0), mk('202610','B','P2',0), mk('202610','A','P1',10), mk('202610','B','P2',4), mk('202609','A','P1',0), mk('202609','A','P1',7), mk('202611','A','P1',1) ] });
T(m.yord.join(',')==='202611,202610,202609', '년월은 한 번씩 · 최근월부터 : '+m.yord.join(','));
T(m.yms['202610']===14 && m.yms['202609']===7 && m.cell['202610|#ALL|P1']===10, '달 합계 · 품목 합계 칸');
// ② 원복 — 화면
T(!/somS0|cellS|somDiffToggle|dtlDiffOnly|retQty|setQty/.test(src), '화면에 「정산 n」·차이만·반품 배지 코드가 없다(원복)');
T(/dtlOutSum'\)\.textContent=\(out\.length\?\(out\.length\+'건 · '\+num\(os\)\):''\)/.test(src), '출고내역 머리 = 「n건 · 수량」(종전 글자)');
T(/수정재고에 포함<\/span>/.test(src) && !/조정 전 반영/.test(src) && /id="dtlSplit"/.test(src), '남긴 것 — 「수정재고에 포함」 이름 · 좌우 조절 막대');
// ② 원복 — 서버
['selectStockOutByMonth','selectStockOutDetail'].forEach(id=>{ const b=blkOf(id).replace(/\/\*[\s\S]*?\*\//g,' ');   /* 주석(원복 설명에 옛 이름이 적혀 있다)은 빼고 본다 */
  T(!/AS SQTY|RQTY|\bSF AS \(|#SOM_SMX|#SOM_SF|AS setQty|AS retQty/.test(b) && /LEFT JOIN (SM|#SOD_SM) m ON/.test(b), id+' — 정산서 줄을 발주 줄의 사업장에 나눈다 · 추정 짝 상한·반품 순수량·setQty 없음');
  T(/\(CASE WHEN ABS\((?:[a-z0-9]+\.)?CUR_QTY\) > ABS\((?:[a-z0-9]+\.)?LABEL_QTY\) THEN /.test(b), id+' — 출고수량 규칙(라벨수량 · 수량이 더 크면 수량)은 그대로'); });
T(/THEN u\.BIZ_NM ELSE '' END, u\.PROD_CD/.test(blkOf('selectStockOutByMonth')), '표 — 사업장 코드 빈 줄(DC 입고 · 발주없음)은 이름으로 열을 가른다(남긴 것)');
// ★「정산서가 온 날」 = 납기일자 + 물류센터 (2026-11-24 사용자 「물류센터 단위로 진행해줘」) — 다섯 곳이 같은 갈림이어야 한다
{ const DK=a=>'<include refid="dcKeyOf"><property name="a" value="'+a+'"/></include>';
  const led=X.slice(X.indexOf('<insert id="insertShipoutLedger"'), X.indexOf('</insert>', X.indexOf('<insert id="insertShipoutLedger"')));
  T(led.indexOf("AND "+']]>'+DK('v.')+'<![CDATA['+" = "+']]>'+DK('s.')+'<![CDATA['+" ) )")>0, '재고 원장(insertShipoutLedger) — 같은 물류센터의 정산서가 있을 때만 발주현황표 줄을 뺀다');
  const sm=blkOf('selectShipoutMst'); T(/AS DCK FROM TBL_SALES_MST WHERE ACTION_YN = 'Y' \) sd/.test(sm) && sm.indexOf("sd.DLV_DT = t.DLV_DT AND sd.DCK = "+']]>'+DK('t.'))>0, '납기현황표·매출내역(selectShipoutMst settleYn) — 납기일자 + 물류센터');
  ['selectStockOutByMonth','selectStockOutDetail'].forEach(id=>{ const b=blkOf(id); T(/AS DCK INTO #SO[MD]_SD FROM TBL_SALES_MST/.test(b) && /SD\.DLV_DT = o\.DLV_DT AND SD\.DCK = o\.DC_CD \)/.test(b), id+' — 정산서 안 온 센터의 발주현황표 줄은 그대로 센다'); });
  const st=blkOf('selectStockMstList'); T(st.indexOf(DK('')+' AS DCK FROM TBL_SALES_MST')>0 && st.indexOf('AND SD.DCK = '+DK('s.')+' ) ) u')>0, '품목별재고현황 ↳ 줄(selectStockMstList) — 같은 갈림');
  T(!/SELECT DISTINCT COMP_CD, DLV_DT (INTO #SO[MD]_SD )?FROM TBL_SALES_MST/.test(X), '날짜만 보는 «정산서 온 날» 목록이 남아 있지 않다'); }
// ★정산수량을 «정수로» 나눈다 (2026-11-24 사용자 「정수로 나누게 바꿔줘」 → 「다른곳도 정산수량 표현하는곳 수정해줘요」) — 세 곳이 같은 식·같은 차례
{ const som=blkOf('selectStockOutByMonth'), sod=blkOf('selectStockOutDetail'), shm=blkOf('selectShipoutMst');
  const ord=(b)=>{ const m=b.match(/ORDER BY ([a-z])\.RF DESC, [a-z]\.(?:SQ|UQ) DESC, [a-z]\.BIZ_CD, ([^)]*)\) AS RN/); return m ? m[2].replace(/[a-z]\./g,'').replace(/\s/g,'') : null; };
  T(ord(som)==='OORD,OPROD,ODC,OKIND' && ord(sod)==='OORD,OPROD,ODC,OKIND,ITEM_CD' && ord(shm)==='ORD_NO,DC_CD,KIND', '나머지 1개씩 주는 차례 = 소수 나머지 큰 순 · 발주수량 큰 순 · 사업장코드 · 발주번호 · (품목) · 출고장 · 종류 — 세 곳이 같다');
  [som,sod,shm].forEach((b,i)=>T(/THEN 1 ELSE 0 END \) END\)? AS (AQ|UA)/.test(b) && /<> FLOOR\([a-z]\.VQ\) THEN/.test(b) && /SIGN\([a-z]\.VQ\) \*/.test(b), ['월별 표','출고내역','납기현황표'][i]+' — 내림 몫 + 남은 개수 1개씩 · 소수 정산수량은 비율 그대로 · 음수는 부호 되붙임'));
  T(som.indexOf("m.AQ END AS DECIMAL(18,3)), 0\n")>0 && sod.indexOf("m.AQ END AS DECIMAL(18,3)), N'정산서'")>0 && shm.indexOf("ELSE ISNULL(sa.SQTY, 0) END AS settleQty")>0 && shm.indexOf("LEFT JOIN #SHM_S sa ON sa.SEQ = t.SEQ")>0, '세 조회가 그 정수 몫을 쓴다(월별 표·내역 = AQ · 납기현황표 settleQty = 발주 줄마다 #SHM_S)');
  T(shm.indexOf("sa.SQTY * (CASE WHEN ABS(t.CUR_QTY)")<0 && shm.indexOf("MIN(s0.UPLOAD_DTTM) OVER")<0 && shm.indexOf("fd.FD AS firstDttm")>0 && shm.indexOf("MIN(x.UPLOAD_DTTM), 120) AS FD")>0, '납기현황표 — 옛 비율 식 없음 · 최초 업로드일시는 집계 임시 표(#SHM_F)로(창 함수 정렬 0.45초를 걷어냄)');
  T(sod.indexOf("u.OQ AS ordQty, u.LQ AS lineOrdQty, u.LV AS lineOutQty")>0, '출고내역 — 부분출고 설명용 세 칸(이 사업장 발주 · 발주 합 · 정산서 출고)');
  // 화면 partOf — 「홍대 0 으로 나오면 사용자 물어볼텐데」
  const i=src.indexOf('var partOf=function(r){'); let d=0, e=-1; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0){ e=k; break; } } }
  const partOf=new Function('num', src.slice(i,e+1)+'; return partOf;')(v=>String(Math.round(Number(v)||0)));
  const h0=partOf({ src:'정산서', qty:0, ordQty:1, lineOrdQty:8, lineOutQty:2 });
  T(h0.indexOf('>발주 1 → 0 (전체 8 → 2)<')>0 && /어느 사업장이 받았는지는 정산서로는 알 수 없습니다/.test(h0), '부분출고 줄(발주 8 · 출고 2) — 「발주 1 → 0 (전체 8 → 2)」 + 까닭 풀이');
  T(partOf({ src:'정산서', qty:4, ordQty:4, lineOrdQty:8, lineOutQty:8 })==='' && partOf({ src:'정산서', qty:9, ordQty:4, lineOrdQty:8, lineOutQty:9 })==='' && partOf({ src:'발주현황표', qty:1, ordQty:1, lineOrdQty:8, lineOutQty:2 })==='' && partOf({ src:'정산서', qty:2 })==='', '다 나간 줄 · 더 나간 줄 · 정산서 아닌 줄 · 옛 서버(칸 없음)에는 아무것도 안 붙인다');
  T(src.indexOf("preOf(r)+(function(){")>0 && src.indexOf("somRunPill(RM, RM.day[k], true); })()+partOf(r)+num(q)")>0, '수량 칸 = 「수정재고에 포함」 · (조정 뒤 재고) · 부분출고 설명 · 수량'); }
// 정산서 누락 조회 = 대사하는 화면 — 반품 뺀 순수량
{ const g=blkOf('selectSettleGap');
  T(/THEN -ISNULL\(v\.OUT_QTY,0\) ELSE 0 END\) AS Q\n\s+INTO #GAP_S0/.test(g) && /FROM #GAP_S s\n\s+WHERE s\.Q <> 0/.test(g), '정산서 누락 조회 — 정산수량 = 반품 뺀 순수량 · 전량반품 줄은 «정산서만 있음»에 안 올림'); }
console.log((bad?'✗':'✓')+' sim_somDupYm : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
