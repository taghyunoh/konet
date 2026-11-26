// 매퍼 문장(select·update·insert·delete 아무거나)을 꺼내 #{…} 자리에 값을 글자로 넣는다 — 문법 검사(NoExec) 용
//   node sqlany.js <id> <out.sql> key=value …   (없는 값은 NULL)
const fs=require('fs'); const x=fs.readFileSync(process.env.MAPPER||'C:/Users/user/git/konet/konet_vsweb/src/main/resources/egovframework/sqlmap/mapper/User_SQL.xml','utf8').replace(/\r\n/g,'\n');
const id=process.argv[2], out=process.argv[3]; const vals={}; process.argv.slice(4).forEach(a=>{ const i=a.indexOf('='); vals[a.slice(0,i)]=a.slice(i+1); });
const m=new RegExp('<(select|update|insert|delete) id="'+id+'"[^>]*>([\\s\\S]*?)</\\1>').exec(x); if(!m) throw 'no '+id;
let s=m[2];
const frag=n=>{ const f=new RegExp('<sql id="'+n+'">([\\s\\S]*?)</sql>').exec(x); if(!f) throw 'no sql '+n; return f[1]; };
for(let k=0;k<5;k++){
  s=s.replace(/<include refid="([^"]+)">\s*<property name="a" value="([^"]*)"\/>\s*<\/include>/g,(_,n,a)=>frag(n).replace(/\$\{a\}/g,a));
  s=s.replace(/<include refid="([^"]+)"\s*\/>/g,(_,n)=>frag(n));
}
s=s.replace(/<!\[CDATA\[|\]\]>/g,'');
if(/<(if|choose|foreach|include|where|set)\b/.test(s)) throw 'dynamic tags in '+id;
s=s.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
s=s.replace(/#\{(\w+)(,[^}]*)?\}/g,(_,k)=>{ const v=vals[k]; if(v===undefined||v==='') return 'NULL'; return /^-?\d+$/.test(v)&&/Seq$/.test(k) ? v : "N'"+String(v).replace(/'/g,"''")+"'"; });
fs.writeFileSync(out,s); console.log(id+' → '+out+' ('+s.length+'자)');
