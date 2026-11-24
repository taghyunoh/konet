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
T(/dtlOutSum'\)\.textContent=out\.length\?\(out\.length\+'건 · '\+num\(os\)\):''/.test(src), '출고내역 머리 = 「n건 · 수량」(종전 글자)');
T(/수정재고에 포함<\/span>/.test(src) && !/조정 전 반영/.test(src) && /id="dtlSplit"/.test(src), '남긴 것 — 「수정재고에 포함」 이름 · 좌우 조절 막대');
// ② 원복 — 서버
['selectStockOutByMonth','selectStockOutDetail'].forEach(id=>{ const b=blkOf(id).replace(/\/\*[\s\S]*?\*\//g,' ');   /* 주석(원복 설명에 옛 이름이 적혀 있다)은 빼고 본다 */
  T(!/AS SQTY|RQTY|\bSF AS \(|#SOM_SMX|#SOM_SF|AS setQty|AS retQty/.test(b) && /LEFT JOIN SM m ON/.test(b), id+' — 종전 식(정산서 줄을 발주 줄의 사업장에 비율로) · 추정 짝 상한·반품 순수량·setQty 없음');
  T(/\(CASE WHEN ABS\((?:[a-z0-9]+\.)?CUR_QTY\) > ABS\((?:[a-z0-9]+\.)?LABEL_QTY\) THEN /.test(b), id+' — 출고수량 규칙(라벨수량 · 수량이 더 크면 수량)은 그대로'); });
T(/THEN u\.BIZ_NM ELSE '' END, u\.PROD_CD/.test(blkOf('selectStockOutByMonth')), '표 — 사업장 코드 빈 줄(DC 입고 · 발주없음)은 이름으로 열을 가른다(남긴 것)');
// 정산서 누락 조회 = 대사하는 화면 — 반품 뺀 순수량
{ const g=blkOf('selectSettleGap');
  T(/THEN -ISNULL\(v\.OUT_QTY,0\) ELSE 0 END\) AS Q\n\s+INTO #GAP_S0/.test(g) && /FROM #GAP_S s\n\s+WHERE s\.Q <> 0/.test(g), '정산서 누락 조회 — 정산수량 = 반품 뺀 순수량 · 전량반품 줄은 «정산서만 있음»에 안 올림'); }
console.log((bad?'✗':'✓')+' sim_somDupYm : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
