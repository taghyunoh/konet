// 재고 변동 확인 — 원장 줄 맞추기 SQL(동적 SQL 로 넣는 안쪽 문장). 매퍼 패치와 문법 검사가 같은 글을 쓴다.
//   @c = 회사 · @p = 품목(없으면 전부)
const G=[ { gb:'PURCH', t:'TBL_PURCHASE_MST', k:'PURCH_SEQ', d:'PURCH_DT', n:'PURCH_NO' }, { gb:'SALE', t:'TBL_SALES_TRX_MST', k:'SALE_SEQ', d:'SALE_DT', n:'SALE_NO' } ];
const no=g=>"REPLACE(ISNULL(m."+g.d+",''),'-','') + '-' + m."+g.n;
const seqOf="CAST(CASE WHEN ISNUMERIC(SUBSTRING(l.REF_NO, CHARINDEX('#', l.REF_NO) + 1, 12)) = 1 THEN SUBSTRING(l.REF_NO, CHARINDEX('#', l.REF_NO) + 1, 12) ELSE '0' END AS INT)";
// ① 살아 있는 전표 — 제외한 전표(품목)의 Y 줄을 X 로
const R1=g=>"UPDATE l SET l.ACTION_YN = 'X'\n"
 +"  FROM TBL_STOCK_CHK c\n"
 +"  JOIN "+g.t+" m ON m."+g.k+" = c.REF_SEQ AND m.COMP_CD = c.COMP_CD AND m.ACTION_YN = 'Y'\n"
 +"  JOIN TBL_STOCK_LEDGER l ON l.REF_GB = '"+g.gb+"' AND l.REF_NO = "+no(g)+" AND l.COMP_CD = c.COMP_CD AND l.ACTION_YN = 'Y'\n"
 +"                         AND ( c.PROD_SEQ = 0 OR l.PROD_SEQ = c.PROD_SEQ )\n"
 +" WHERE c.COMP_CD = @c AND c.REF_GB = '"+g.gb+"' AND c.STATE = 'X' AND ( @p IS NULL OR l.PROD_SEQ = @p );\n";
// ② 살아 있는 전표 — 더는 제외가 아닌 X 줄을 Y 로 (제외 취소). 처리할 때만 돈다(syncStockChkLedger)
const R2=g=>"UPDATE l SET l.ACTION_YN = 'Y'\n"
 +"  FROM TBL_STOCK_LEDGER l\n"
 +" WHERE l.COMP_CD = @c AND l.ACTION_YN = 'X' AND l.REF_GB = '"+g.gb+"' AND ( @p IS NULL OR l.PROD_SEQ = @p )\n"
 +"   AND NOT EXISTS ( SELECT 1 FROM "+g.t+" m\n"
 +"                      JOIN TBL_STOCK_CHK c ON c.COMP_CD = m.COMP_CD AND c.REF_GB = '"+g.gb+"' AND c.REF_SEQ = m."+g.k+" AND c.STATE = 'X' AND c.PROD_SEQ IN (0, l.PROD_SEQ)\n"
 +"                     WHERE m.COMP_CD = l.COMP_CD AND m.ACTION_YN = 'Y' AND "+no(g)+" = l.REF_NO );\n";
// ④ 지운 전표 — 제외(= 삭제를 재고에 반영 안 함)한 전표(품목)의 «지울 때 닫힌 줄»을 되살린다 : 근거구분 …K · 근거번호 뒤에 #전표키
const R4=g=>"UPDATE l SET l.ACTION_YN = 'Y', l.REF_GB = '"+g.gb+"K', l.REF_NO = l.REF_NO + '#' + CAST(m."+g.k+" AS VARCHAR(12))\n"
 +"  FROM TBL_STOCK_CHK c\n"
 +"  JOIN "+g.t+" m ON m."+g.k+" = c.REF_SEQ AND m.COMP_CD = c.COMP_CD AND m.ACTION_YN = 'N'\n"
 +"  JOIN TBL_STOCK_LEDGER l ON l.REF_GB = '"+g.gb+"' AND l.REF_NO = "+no(g)+" AND l.COMP_CD = c.COMP_CD AND l.ACTION_YN = 'N'\n"
 +"                         AND ( c.PROD_SEQ = 0 OR l.PROD_SEQ = c.PROD_SEQ )\n"
 +" WHERE c.COMP_CD = @c AND c.REF_GB = '"+g.gb+"' AND c.STATE = 'X' AND ( @p IS NULL OR l.PROD_SEQ = @p )\n"
 +"   AND l.UPD_DTTM <= m.UPD_DTTM AND l.UPD_DTTM >= CONVERT(VARCHAR(19), DATEADD(SECOND, -5, CONVERT(DATETIME, m.UPD_DTTM, 120)), 120)\n"
 +"   AND NOT EXISTS ( SELECT 1 FROM TBL_STOCK_LEDGER k WHERE k.REF_GB = '"+g.gb+"K' AND k.REF_NO = l.REF_NO + '#' + CAST(m."+g.k+" AS VARCHAR(12))\n"
 +"                       AND k.COMP_CD = l.COMP_CD AND k.PROD_SEQ = l.PROD_SEQ AND k.ACTION_YN = 'Y' );\n";
// ⑤ 되살린 줄 — 더는 제외가 아니거나 전표가 되살아났으면 도로 닫는다(근거구분·번호도 원래대로 — 다시 제외할 때 찾을 수 있게. UPD_DTTM 은 건드리지 않는다)
const R5=g=>"UPDATE l SET l.ACTION_YN = 'N', l.REF_GB = '"+g.gb+"', l.REF_NO = LEFT(l.REF_NO, CHARINDEX('#', l.REF_NO) - 1)\n"
 +"  FROM TBL_STOCK_LEDGER l\n"
 +" WHERE l.COMP_CD = @c AND l.REF_GB = '"+g.gb+"K' AND l.ACTION_YN = 'Y' AND CHARINDEX('#', l.REF_NO) > 1 AND ( @p IS NULL OR l.PROD_SEQ = @p )\n"
 +"   AND NOT EXISTS ( SELECT 1 FROM TBL_STOCK_CHK c\n"
 +"                      JOIN "+g.t+" m ON m."+g.k+" = c.REF_SEQ AND m.COMP_CD = c.COMP_CD AND m.ACTION_YN = 'N'\n"
 +"                     WHERE c.COMP_CD = l.COMP_CD AND c.REF_GB = '"+g.gb+"' AND c.STATE = 'X' AND c.PROD_SEQ IN (0, l.PROD_SEQ)\n"
 +"                       AND c.REF_SEQ = "+seqOf+" );\n";
const KEEP=G.map(R1).join('')+G.map(R5).join('')+G.map(R4).join('');     // 재집계 때마다(가볍다 — 제외한 전표·되살린 줄에서 출발)
const UNX =G.map(R2).join('');                                          // 처리할 때만
const q2=s=>s.replace(/'/g,"''");
const C="#{compCd,jdbcType=VARCHAR}", P="#{prodSeq,jdbcType=BIGINT}";
/* 매퍼에 넣는 꼴 — 칸(PROD_SEQ)이 있을 때만 · 동적 SQL(칸이 없는 DB 에서도 이 배치가 컴파일되게) */
function wrap(inner, declare){
  return "	  IF COL_LENGTH('dbo.TBL_STOCK_CHK', 'PROD_SEQ') IS NOT NULL\n	  BEGIN\n"
   +(declare ? "	    DECLARE @SCK_C VARCHAR(10), @SCK_P BIGINT;\n	    SELECT @SCK_C = ISNULL("+C+",'W1234567'), @SCK_P = "+P+";\n" : "")
   +"	    EXEC sp_executesql N'\n"+q2(inner)+"', N'@c VARCHAR(10), @p BIGINT', @c = @SCK_C, @p = @SCK_P;\n	  END\n";
}
module.exports={ KEEP, UNX, wrap, C, P };
