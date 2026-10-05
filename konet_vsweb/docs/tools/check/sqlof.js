/* 매퍼에서 문장 하나를 꺼내 #{…} 자리에 값을 넣어 돌릴 수 있는 SQL 로 만든다(읽기 전용 조회기에 넘긴다).
   node sqlof.js <id> key=value ... */
const fs = require('fs');
const xml = fs.readFileSync('C:/Users/user/git/konet/konet_vsweb/src/main/resources/egovframework/sqlmap/mapper/User_SQL.xml', 'utf8');
const id = process.argv[2];
const vals = {};
process.argv.slice(3).forEach(a => { const i = a.indexOf('='); vals[a.slice(0, i)] = a.slice(i + 1); });
const m = xml.match(new RegExp('<select id="' + id + '"[^>]*>([\\s\\S]*?)</select>'));
if (!m) { console.error('없는 id: ' + id); process.exit(1); }
let sql = m[1].replace(/<!\[CDATA\[/g, '').replace(/\]\]>/g, '');
sql = sql.replace(/#\{(\w+)(,[^}]*)?\}/g, (_, k) => {
  const v = vals[k];
  if (v === undefined || v === '') return 'NULL';
  return "N'" + String(v).replace(/'/g, "''") + "'";
});
sql = sql.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/\s+/g, ' ').trim();
process.stdout.write(sql);
