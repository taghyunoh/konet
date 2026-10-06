/* 매퍼 점검 두 가지 (2026-10-06 — 견적 값 두 개가 판매가 아니라 매입 INSERT 에 들어간 사고 뒤에 만들었다)
   ① node mapper_audit.js count             — 모든 INSERT 의 「칸 수 = 값 수」 (INSERT … VALUES 꼴만. INSERT … SELECT 는 건너뜀)
   ② node mapper_audit.js diff <옛.xml>      — 옛 판과 문장 단위로 견주어 «바뀐 문장 id» 를 늘어놓는다(의도한 것만 바뀌었는지 사람이 본다)
   ★javac·XML 정형성·MyBatis 파싱은 이 둘을 못 잡는다 — 칸 수가 어긋나도 문법은 멀쩡하고, 엉뚱한 문장이 바뀌어도 파싱은 된다. */
const fs = require('fs');
const MAPPER = 'C:/Users/user/git/konet/konet_vsweb/src/main/resources/egovframework/sqlmap/mapper/User_SQL.xml';
function stmts(xml) {
  const out = {}, re = /<(insert|update|select|delete) id="([^"]+)"[\s\S]*?<\/\1>/g; let m;
  while ((m = re.exec(xml))) out[m[2]] = { kind: m[1], text: m[0].replace(/\r/g, ''), line: xml.slice(0, m.index).split('\n').length };
  return out;
}
function splitTop(s) {   // 괄호·중괄호 깊이 0, 따옴표 밖의 쉼표로 가른다
  const out = []; let d = 0, cur = '', q = false;
  for (const c of s) {
    if (c === "'") q = !q;
    if (!q) { if (c === '(' || c === '{') d++; if (c === ')' || c === '}') d--; }
    if (c === ',' && d === 0 && !q) { out.push(cur.trim()); cur = ''; } else cur += c;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
}
const mode = process.argv[2] || 'count';
const xml = fs.readFileSync(MAPPER, 'utf8');
const all = stmts(xml);
if (mode === 'count') {
  let n = 0, bad = 0, skip = 0;
  Object.keys(all).forEach(function (id) {
    const s = all[id]; if (s.kind !== 'insert') return;
    let t = s.text.replace(/<!\[CDATA\[|\]\]>/g, '').replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/<!--[\s\S]*?-->/g, ' ');
    const vi = t.search(/\bVALUES\b/i);
    if (vi < 0 || /<foreach|<if |<choose|<trim/.test(t)) { skip++; return; }   // INSERT … SELECT · 동적 조각은 사람이 본다
    const ci = t.indexOf('(', t.search(/INSERT\s+INTO/i));
    let depth = 0, ce = -1; for (let i = ci; i < vi; i++) { if (t[i] === '(') depth++; if (t[i] === ')') { depth--; if (depth === 0) { ce = i; break; } } }
    const cols = splitTop(t.slice(ci + 1, ce));
    let v = t.slice(vi + 6).trim(); v = v.slice(v.indexOf('(') + 1, v.lastIndexOf(')'));
    const vals = splitTop(v);
    n++;
    if (cols.length !== vals.length) { bad++; console.log('✗ ' + String(s.line).padStart(5) + '행 ' + id + ' : 칸 ' + cols.length + ' · 값 ' + vals.length); }
  });
  console.log('INSERT … VALUES ' + n + '문 · 어긋남 ' + bad + ' · 건너뜀(SELECT·동적) ' + skip);
  process.exit(bad ? 1 : 0);
}
if (mode === 'diff') {
  const old = stmts(fs.readFileSync(process.argv[3], 'utf8'));
  const changed = [], added = [], removed = [];
  Object.keys(all).forEach(function (id) { if (!old[id]) added.push(id); else if (old[id].text !== all[id].text) changed.push(id); });
  Object.keys(old).forEach(function (id) { if (!all[id]) removed.push(id); });
  console.log('바뀐 문장 ' + changed.length + ' : ' + changed.join(', '));
  console.log('새 문장   ' + added.length + ' : ' + added.join(', '));
  console.log('없어진 문장 ' + removed.length + (removed.length ? ' : ' + removed.join(', ') : ''));
}
