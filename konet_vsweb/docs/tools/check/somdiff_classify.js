const fs=require('fs'),S=process.argv[2];
const L=fs.readFileSync(S+'/ana.out','utf8').split('\n');
const D=[], SL=new Map();
L.forEach(l=>{ const c=l.split('\t'); if(c[0]!=='ROW') return;
  if(c[1]==='D') D.push({dt:c[2],bk:c[3],bn:c[4],pc:c[5],Q:+c[6],SQ:+c[7],SD:+c[8],S1:+c[9],S2:+c[10],RQ:+c[11],DC:c[12],TQ:+c[13]});
  else if(c[1]==='L') SL.set(c[2]+'|'+c[3]+'|'+c[4], +c[5]); });
const addDay=(d,n)=>{ const t=new Date(+d.slice(0,4),+d.slice(4,6)-1,+d.slice(6,8)+n); return ''+t.getFullYear()+String(t.getMonth()+1).padStart(2,'0')+String(t.getDate()).padStart(2,'0'); };
const cells=new Map();
D.forEach(r=>{ if(/발주없음/.test(r.bn)) return; const k=r.dt.slice(0,6)+'|'+(r.bk||('~'+r.bn))+'|'+r.pc; let c=cells.get(k); if(!c){ c={ym:r.dt.slice(0,6),bn:r.bn,pc:r.pc,Q:0,SQ:0,days:[]}; cells.set(k,c);} c.Q+=r.Q; c.SQ+=r.SQ; c.days.push(r); });
const diff=[...cells.values()].filter(c=>Math.round(c.Q)!==Math.round(c.SQ));
console.log('차이 칸', diff.length);
const CAT={}, add=(cat,c,d)=>{ (CAT[cat]=CAT[cat]||{n:0,q:0,ex:[]}); CAT[cat].n++; CAT[cat].q+=d; if(CAT[cat].ex.length<4) CAT[cat].ex.push(c.ym+' '+c.bn.slice(0,16)+' '+c.pc+' 발주 '+c.Q+' 정산 '+(Math.round(c.SQ*10)/10)); };
// 라벨수량 ≠ 수량 겹침
const lab=new Map(); fs.readFileSync(S+'/lab.txt','utf8').split('\n').filter(Boolean).forEach(l=>{ const c=l.trim().split(/\s+/); lab.set(c[0]+'|'+c[1], (lab.get(c[0]+'|'+c[1])||0)+(+c[4]-+c[3])); });
diff.forEach(c=>{
  if(lab.get(c.ym+"|"+c.pc) && c.SQ>c.Q){ add("라벨수량 ≠ 실제 수량 (발주현황표 라벨 1장에 여러 개)",c,c.SQ-c.Q); return; }
  const part={}; const P=(k,v)=>{ part[k]=(part[k]||0)+v; };
  c.days.forEach(r=>{ const d=r.SQ-r.Q; if(Math.abs(d)<0.05) return;
    if(r.RQ>0.05){ P('일부 반품(돌아온 수량 뺌)', -r.RQ); }
    const d2=d+(r.RQ>0.05?r.RQ:0); if(Math.abs(d2)<0.05) return;
    if(r.S1+r.S2<0.05 && r.Q>0){
      const k0=r.dt+'|'+r.DC+'|'+r.pc, has=SL.has(k0), near=SL.has(addDay(r.dt,-1)+'|'+r.DC+'|'+r.pc)||SL.has(addDay(r.dt,1)+'|'+r.DC+'|'+r.pc);
      if(has) P('정산서에 그 품목은 있는데 이 사업장 몫 0 (같은 발주번호 짝이 다른 사업장으로)', d2);
      else if(near) P('정산서가 하루 앞뒤 날짜로 옴(납기일자 어긋남)', d2);
      else P('그날 정산서에 이 품목 없음(미출고·결품 의심)', d2);
    } else if(r.S1>0.05 && r.S2<0.05) P(d2<0?'같은 발주번호 — 정산이 적음(덜 나감)':'같은 발주번호 — 정산이 많음(더 나감)', d2);
    else if(r.S2>0.05) P(d2<0?'발주번호 빈칸 추정 짝 — 정산이 적음':'발주번호 빈칸 추정 짝 — 정산이 많음', d2);
    else P('기타', d2); });
  const ks=Object.keys(part);
  if(!ks.length || Math.abs(c.SQ-c.Q)<1 && ks.every(k=>Math.abs(part[k])<1)){ add('나눈 조각 반올림(1개 미만)',c,c.SQ-c.Q); return; }
  const top=ks.sort((a,b)=>Math.abs(part[b])-Math.abs(part[a]))[0];
  add(ks.length>1?top+' (+다른 원인 섞임)':top, c, c.SQ-c.Q);
});
Object.entries(CAT).sort((a,b)=>b[1].n-a[1].n).forEach(([k,v])=>{ console.log('\n■ '+k+' — '+v.n+'칸 · 차이 합 '+(Math.round(v.q*10)/10)); v.ex.forEach(e=>console.log('   · '+e)); });
let nLab=0, qLab=0, more=0; diff.forEach(c=>{ const g=lab.get(c.ym+'|'+c.pc); if(g){ nLab++; if(c.SQ>c.Q){ more++; qLab+=c.SQ-c.Q; } } });
console.log('\n라벨수량≠수량 품목이 낀 차이 칸', nLab, '그중 정산이 많은 칸', more, '차이 합', Math.round(qLab));
