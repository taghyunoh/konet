/* 매퍼 문장 → 「?」 SQL + 값 목록 (앱과 같은 PreparedStatement 로 재기 위해)
   node prep.js <id> <out.sql> key=value ...   (include dcKeyOf 전개 · 주석 제거 · 동적 태그 없는 문장만) */
const fs = require('fs');
const xml = fs.readFileSync(process.env.MAPPER || 'C:/Users/HYUN/git/konet/konet_vsweb/src/main/resources/egovframework/sqlmap/mapper/User_SQL.xml', 'utf8');
const id = process.argv[2], out = process.argv[3], vals = {};
process.argv.slice(4).forEach(a => { const i = a.indexOf('='); vals[a.slice(0, i)] = a.slice(i + 1); });
const m = xml.match(new RegExp('<select id="' + id + '"[^>]*>([\\s\\S]*?)</select>'));
if (!m) { console.error('없는 id'); process.exit(1); }
const frag = {}; xml.replace(/<sql id="(\w+)">([\s\S]*?)<\/sql>/g, (_, k, v) => { frag[k] = v; });
let sql = m[1];
sql = sql.replace(/\]\]>\s*<include refid="(\w+)">\s*<property name="(\w+)" value="([^"]*)"\/>\s*<\/include>\s*<!\[CDATA\[/g, (_, r, pn, pv) => {
  return (frag[r] || '').replace(/<!\[CDATA\[/g, '').replace(/\]\]>/g, '').replace(new RegExp('\\$\\{' + pn + '\\}', 'g'), pv); });
sql = sql.replace(/<!\[CDATA\[/g, '').replace(/\]\]>/g, '');
if (/<(if|choose|foreach|include|where)\b/.test(sql)) { console.error('동적 태그가 남았다'); process.exit(1); }
sql = sql.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/--[^\n]*/g, ' ');
const ps = [];
sql = sql.replace(/#\{(\w+)(,[^}]*)?\}/g, (_, k) => { ps.push(vals[k] === undefined ? '\u0000' : vals[k]); return '?'; });
sql = sql.replace(/\s+/g, ' ').trim();
fs.writeFileSync(out, sql + '\n' + ps.join('\u0001'), 'utf8');
console.log(id, '자리표', ps.length, '길이', sql.length);
