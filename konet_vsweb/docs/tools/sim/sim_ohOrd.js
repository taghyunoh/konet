// 출고수량 규칙 + 2026-11-24 원복 확인 (매출내역 · 정산실적 · 매출마감)
//   ① 출고수량 = 라벨수량 · 수량이 더 크면 수량 (사용자 「라벨수량보다 수량이 크면 수량 쓰는 걸로」 — 유지)
//   ② 원복 (사용자 「매출내역 정산실적 매출마감도 원래대로 원복해줘(오류수정은 유지하고)」) :
//      매출내역 출고 = ssOutQty(정산서 온 날은 정산수량) · 정산실적 17칸(발주현황표·차이 칸 없음) · 매출마감 「정산 n」 없음.
//   실행 : node docs/tools/sim/sim_ohOrd.js   (jsdom 불필요)
const fs=require('fs'), path=require('path');
const R=p=>fs.readFileSync(path.join(__dirname,'../../..',p),'utf8').replace(/\r\n/g,'\n');
const src=R('src/main/webapp/js/winct/logi-oh.js'), J=R('src/main/webapp/WEB-INF/jsp/main/admin/logistics_demo2.jsp'), X=R('src/main/resources/egovframework/sqlmap/mapper/User_SQL.xml');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
const pick=(name)=>{ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } };
const F=new Function(['ssShipQty','ssOutQty'].map(pick).join('\n')+'\nreturn {ssShipQty, ssOutQty};')();
// ① 수량 규칙
T(F.ssShipQty({ labelQty:1, curQty:6 })===6 && F.ssShipQty({ labelQty:1, curQty:0 })===1 && F.ssShipQty({ labelQty:3, curQty:3 })===3 && F.ssShipQty({ labelQty:-1, curQty:-6 })===-6,
  '수량이 라벨수량보다 크면 수량(1·6 → 6) · 라벨이 크면 라벨(1·0 → 1) · 같으면 그대로 · 음수는 크기로');
T(F.ssShipQty({ labelQty:null, curQty:5 })===5 && F.ssShipQty({ labelQty:0, curQty:0 })===0 && F.ssShipQty({ labelQty:0, curQty:5 })===5, '라벨수량 없으면 수량 · 0 은 0 · 라벨 0 인데 수량이 있으면 수량');
T((X.match(/\(CASE WHEN ABS\((?:[a-z0-9]+\.)?CUR_QTY\) > ABS\((?:[a-z0-9]+\.)?LABEL_QTY\) THEN /g)||[]).length===63 && !/[^(]ISNULL\((?:[a-z0-9]+\.)?LABEL_QTY, ISNULL\((?:[a-z0-9]+\.)?CUR_QTY,0\)\)(?! END\))/.test(X),
  '서버 SQL 62곳(+설명 주석 1) 모두 같은 식 (납기현황표 정산수량을 임시 표로 옮기며 한 곳 · 출고현황이력조회를 라벨수량 그대로로 바꾸며 한 곳 줄었다)');
// ② 원복 — 매출내역
T(F.ssOutQty({ labelQty:8, curQty:8, settleYn:'Y', settleQty:2 })===2 && F.ssOutQty({ labelQty:1, curQty:6, settleYn:'N' })===6, '매출내역 출고수량 = 정산서 온 날은 정산수량 · 안 온 날은 발주현황표(수량 규칙)');
T(!/ssOrdQty|ssSettleBadge/.test(src) && /_ohIndex\(_ohShip, ssOutQty\)/.test(src), '매출내역 — 발주수량 따로 세기·「정산 n」 배지 없음(원복) · 대사 = ssOutQty');
// ② 원복 — 정산실적
T(!/_spShipOk|_spQ2|selectSalesShipQty/.test(src) && !/selectSalesShipQty/.test(X), '정산실적 — 「발주현황표 · 차이」 칸과 그 조회(selectSalesShipQty) 없음(원복)');
// ② 원복 — 매출마감
{ const i=X.indexOf('<select id="selectClosing"'), c=X.slice(i, X.indexOf('</select>', i)).replace(/\/\*[\s\S]*?\*\//g,' ');
  T(!/setQty|setDay|stlQty,\s*$/m.test(c) && !/_setBadge|_sbOf|_salesSetNote/.test(J), '매출마감 — 정산 기준 수량(setQty·setDay)·「정산 n」 없음(원복)');
  T(/_salesNumCells\(gQ,0,0,gS,gC,gM,false\)/.test(J), '매출마감 총합계 줄 = 종전 꼴'); }
// 남긴 오류 수정
T(/dupSkip/.test(src) && /\|DUP:/.test(src) && /수정재고에 포함<\/span>/.test(src) && !/조정 전 반영/.test(src), '남긴 것 — 파일끼리 겹친 줄 알림(정산서·발주현황표) · 표 이름 「수정재고에 포함」');
console.log((bad?'✗':'✓')+' sim_ohOrd : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
