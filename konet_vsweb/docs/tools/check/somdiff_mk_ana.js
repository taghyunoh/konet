const fs=require('fs'), S=process.argv[2];
let s=fs.readFileSync(S+'/sbm_n.sql','utf8').replace(/\r\n/g,'\n');
function rep(a,b){ const k=s.split(a).length-1; if(k!==1) throw 'anchor('+k+') '+a.slice(0,90); s=s.split(a).join(b); }
// 갈래마다 TG · BMX · RQX · DCX
rep("	           0 AS NEW_YN    \n	      FROM OL o\n", "	           0 AS NEW_YN, 'O' AS TG, 0 AS BMX, CAST(0 AS DECIMAL(18,3)) AS RQX, o.DC_CD AS DCX\n	      FROM OL o\n");
rep("ELSE (l.VQ - l.RQ) * m.W * m.F END AS DECIMAL(18,3)), 1, 0    \n",
    "ELSE (l.VQ - l.RQ) * m.W * m.F END AS DECIMAL(18,3)), 1, 0, CASE WHEN m.BIZ_CD IS NULL THEN 'N' ELSE 'S' END, ISNULL(m.BM,0), CAST(CASE WHEN m.BIZ_CD IS NULL THEN l.RQ ELSE l.RQ * m.W * m.F END AS DECIMAL(18,3)), l.DC_CD\n");
rep("CAST((l.VQ - l.RQ) * (1 - x.F) AS DECIMAL(18,3)), 1, 0\n", "CAST((l.VQ - l.RQ) * (1 - x.F) AS DECIMAL(18,3)), 1, 0, 'X', 0, CAST(l.RQ * (1 - x.F) AS DECIMAL(18,3)), l.DC_CD\n");
rep("CAST(o.SQ AS DECIMAL(18,3)), CAST(o.SQ AS DECIMAL(18,3)), 0, 1\n	      FROM OL o WHERE o.KIND = 'TD'", "CAST(o.SQ AS DECIMAL(18,3)), CAST(o.SQ AS DECIMAL(18,3)), 0, 1, 'T', 0, CAST(0 AS DECIMAL(18,3)), o.DC_CD\n	      FROM OL o WHERE o.KIND = 'TD'");
// 판매전표 갈래 : SELECT 목록 끝 "0, 1\n	      FROM TBL_SALES_TRX_MST m"
rep(" AS DECIMAL(18,3)), 0, 1\n	      FROM TBL_SALES_TRX_MST m", " AS DECIMAL(18,3)), 0, 1, 'R', 0, CAST(0 AS DECIMAL(18,3)), ''\n	      FROM TBL_SALES_TRX_MST m");
// 마지막 SELECT → 날짜 단위
const i=s.indexOf("	  SELECT LEFT(u.DLV_DT,6) AS ym,"), j=s.indexOf("  DROP TABLE #SOM_M;");
s=s.slice(0,i)+
"	  SELECT 'D' AS K, u.DLV_DT, ISNULL(NULLIF(b.MATCH_CD,''), u.BIZ_CD) AS bizKey, MAX(ISNULL(NULLIF(b.MATCH_NM,''), u.BIZ_NM)) AS bizNm, u.PROD_CD,\n"
+"	         SUM(u.QTY) AS Q, SUM(u.SQTY) AS SQ, MAX(u.SDAY) AS SDAY,\n"
+"	         SUM(CASE WHEN u.TG='S' AND u.BMX=1 THEN u.SQTY ELSE 0 END) AS S1, SUM(CASE WHEN u.TG='S' AND u.BMX>=2 THEN u.SQTY ELSE 0 END) AS S2,\n"
+"	         SUM(u.RQX) AS RQ, MAX(CASE WHEN u.TG='O' THEN u.DCX ELSE '' END) AS DC, SUM(CASE WHEN u.TG IN ('T','R') THEN u.QTY ELSE 0 END) AS TQ\n"
+"	    FROM U u\n"
+"	    LEFT JOIN ( SELECT COMP_CD, BIZ_CD, MAX(MATCH_CD) AS MATCH_CD, MAX(MATCH_NM) AS MATCH_NM FROM TBL_BIZI_MST WHERE ACTION_YN = 'Y' GROUP BY COMP_CD, BIZ_CD ) b ON b.BIZ_CD = u.BIZ_CD AND b.COMP_CD = u.COMP_CD\n"
+"	   GROUP BY u.DLV_DT, ISNULL(NULLIF(b.MATCH_CD,''), u.BIZ_CD), CASE WHEN ISNULL(NULLIF(b.MATCH_CD,''), u.BIZ_CD) = '' THEN u.BIZ_NM ELSE '' END, u.PROD_CD;\n"
+"	  SELECT 'L' AS K, DLV_DT, DC_CD, PROD_CD, SUM(VQ) AS VQ, MAX(MK) AS MK, COUNT(*) AS N FROM #SOM_SL GROUP BY DLV_DT, DC_CD, PROD_CD;\n"
+s.slice(j);
fs.writeFileSync(S+'/ana.sql', s); console.log('ok');
