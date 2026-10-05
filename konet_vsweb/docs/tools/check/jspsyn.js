/* JSP 인라인 <script> 문법 검사 — src 없는 script 블록만 꺼내 JSP 표현식(${…}·<%…%>·<c:…>)을 문자열로 바꾼 뒤 new Function 으로 파싱한다.
   쓰는 법: node jspsyn.js a.jsp b.jsp … */
const fs = require('fs');
let allBad = 0;
process.argv.slice(2).forEach(function (p) {
  const t = fs.readFileSync(p, 'utf8');
  const re = /<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/gi;
  let m, blocks = 0, bad = 0;
  while ((m = re.exec(t))) {
    blocks++;
    let js = m[1]
      .replace(/<%--[\s\S]*?--%>/g, '')
      .replace(/<%=[\s\S]*?%>/g, '0')
      .replace(/<%[\s\S]*?%>/g, '')
      .replace(/<\/?c:[^>]*>/g, '')
      .replace(/<\/?fmt:[^>]*>/g, '')
      .replace(/\$\{[^}]*\}/g, 'X');
    try { new Function(js); }
    catch (e) {
      bad++;
      const line = t.slice(0, m.index).split('\n').length;
      console.log('✗ ' + p.split(/[\\/]/).pop() + ' 블록 시작 ' + line + '행 : ' + e.message);
    }
  }
  allBad += bad;
  console.log((bad ? '✗ ' : '✓ ') + p.split(/[\\/]/).pop() + ' blocks=' + blocks + ' bad=' + bad);
});
process.exit(allBad ? 1 : 0);
