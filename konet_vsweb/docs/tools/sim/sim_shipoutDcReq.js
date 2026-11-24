// 발주현황표 업로드 — 물류센터 없는 파일·행은 반영하지 않는다 (2026-11-24 사용자 「물류센터 없는 것은 오류 나게 — 제공 엑셀처럼 없어서 오류가 안 남」)
//   대상 = js/winct/logi-oh.js 의 ssPvDcLack(파일 목록 단계 판정) · ssSaveShipoutToDB(저장 직전 판정)
//   실행 : node docs/tools/sim/sim_shipoutDcReq.js   (jsdom 불필요)
const fs=require('fs'), path=require('path');
const src=fs.readFileSync(path.join(__dirname,'../../../src/main/webapp/js/winct/logi-oh.js'),'utf8').replace(/\r\n/g,'\n');
let bad=0, ok=0; const T=(c,m)=>{ if(c){ ok++; } else { bad++; console.log('✗ '+m); } };
function pick(name){ const i=src.indexOf('function '+name+'('); if(i<0) throw name; let d=0; for(let k=src.indexOf('{',i);k<src.length;k++){ if(src[k]==='{') d++; else if(src[k]==='}'){ if(--d===0) return src.slice(i,k+1); } } }
const F=new Function(['ssBuildShipoutRows','ssPvDcLack','ssPvIsKJ','ssDupIdx','ssFmtDate','ssPad'].map(pick).join('\n')+'\nreturn {ssBuildShipoutRows, ssPvDcLack};')();
// 코네트 양식(물류센터 칸 있음) — 머리 2행 + 자료
const H1=['No','물류센터코드','물류센터명','품목코드','품목명','납기일자','사업장코드','사업장명','현 발주','','',''];
const H2=['','','','','','','','','입고장','존','수량','배송구분'];
const row=(dc,nm,item,q)=>[1,dc,nm,item,'품목'+item,'2026-09-22','A1','점포',1,'A1',q,'배송'];
const good=[H1,H2,row('E300','김해물류센터','1000736213',1),row('E600','제주물류센터','1000769371',1)];
T(F.ssBuildShipoutRows(good).length===2 && F.ssPvDcLack({cur:{aoa:good}, filter:''})==='', '물류센터 있는 파일 = 통과');
// 물류센터 칸이 없는 양식(기존 2행 헤더 — 제공 파일 2026.11.24_11.34.34.xlsx 와 같은 머리글)
const noCol=[['No','라벨발행 구분','품목코드','품목명','납기일자','사업장코드','사업장명','1차 가마감','','','현 발주','',''],['','','','','','','','입고장','존','수량','입고장','존','수량'],[1,'Y','1000736213','보냉팩','46287','A0412515','런베서면',1,'A1',1,1,'A1',1]];
T(F.ssBuildShipoutRows(noCol).length===0 && /물류센터 칸 없음/.test(F.ssPvDcLack({cur:{aoa:noCol}, filter:''})), '물류센터 칸 없는 양식 = 「물류센터 칸 없음」');
// 칸은 있는데 값이 빈 행
const blank=good.map(r=>r.slice()); blank[3][1]=''; blank[3][2]='';
T(/물류센터 없는 행 1건/.test(F.ssPvDcLack({cur:{aoa:blank}, filter:''})), '물류센터 값이 빈 행 = 「물류센터 없는 행 1건」');
// [가져올 범위] 로 그 행이 빠지면 막지 않는다 (서버에 안 가는 줄)
const blankKJ=good.map(r=>r.slice()); blankKJ[2][1]='E100'; blankKJ[2][2]='용인물류센터'; blankKJ[3][1]=''; blankKJ[3][2]='';
T(F.ssPvDcLack({cur:{aoa:blankKJ}, filter:'ex'})==='물류센터 없는 행 1건' , '범위 「김해·제주 제외」 — 이름이 빈 줄은 김해·제주가 아니라 남는다 → 막음');
// 연결 : 목록 판정에 쓰이고, 저장 함수도 0줄·빈 행이면 알림 뒤 멈춘다(조용히 return 하지 않는다)
T(/if\(!f\.bad\) f\.bad=ssPvDcLack\(f\);/.test(src), 'ssPvApplyFilter 가 ssPvDcLack 으로 f.bad 를 채운다(→ ssPvApply 가 반영을 막음)');
const save=pick('ssSaveShipoutToDB');
T(!/if\(!rows\.length\) return;/.test(save) && /저장되지 않았습니다/.test(save) && /_noDc/.test(save), '저장 함수 — 0줄·물류센터 빈 행이면 알리고 멈춤');
// 「포맷 틀린 것과 같은 조건」 (2026-11-24) — 물류센터 칸 없는 양식은 ssMapCols 가 null(= 형식 오류 길) · 오류내역에 「없는 컬럼 물류센터명」
const specA=src.indexOf('  var SS_FMT_SPEC=['), specB=src.indexOf('];',specA)+2;
const M=new Function('var _cesc=function(v){return String(v);};\n'+src.slice(specA,specB)+'\n'+(/var SS_ALLOW_NO_DC=false;/.test(src)?'var SS_ALLOW_NO_DC=false;\n':'')+['ssMapCols','ssDupIdx','ssHdrCells','ssFmtDiag','ssFmtErrHtml'].map(pick).join('\n')+'\nreturn {ssMapCols, ssFmtErrHtml};')();
T(M.ssMapCols(noCol)===null && /없는 컬럼 .*물류센터명/.test(M.ssFmtErrHtml(noCol).replace(/<[^>]+>/g,'')), '물류센터 칸 없는 양식 = ssMapCols null · 오류내역 「없는 컬럼 물류센터명」');
const gm=M.ssMapCols([['No','물류센터명','품목코드','품목명','납기일자','사업장명','입고장','라벨수량'],['','','','','','','',''],[1,'김해물류센터','1','품목','2026-09-22','점포','1',1]]);
T(gm && gm.fmt==='konet', '물류센터명·입고장 있는 코네트 양식은 그대로 인식');
const rnd=src.slice(src.indexOf('function ssPvRender('), src.indexOf('function ssPvRender(')+9000);
T(/ssPvDcLack\(\{ cur:\{aoa:aoa\}/.test(rnd) && /btn\.setAttribute\('disabled','disabled'\)/.test(rnd) && /반영할 수 없는 자료입니다/.test(rnd), '미리보기 — 물류센터 빈 행이면 빨간 안내 + [반영] 잠김');
console.log((bad?'✗':'✓')+' sim_shipoutDcReq : 통과 '+ok+' · 실패 '+bad);
process.exit(bad?1:0);
