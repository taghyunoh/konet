/* 직원 업무일지(mangr/empWorkLog.jsp) 시뮬 — 화면 JS 블록을 그대로 jsdom 에 올리고 fetch 를 가짜 자료로 바꿔 돌린다 (2026-11-08)
   쓰는 법 : NODE_PATH=%TEMP%/konet_chk/node_modules node docs/tools/sim/sim_empWorkLog.js
   검사 = 파서(날짜 셋 든 글 · 번호 뒤 공백 없는 줄 · 날짜 없는 글 · 같은 날짜 두 글 합치기 · 해 넘김 · 「11/6(목)」·「2026-11-06」·「11.06」 꼴 · 2/30 무시)
        + 격자(열 = 직원 · 행 = 날짜 최근이 위 · 칸 건수 · 요약 카드 · 직원·글자 거르기 · 칸 클릭 → 상세) + 직원별 탭(날짜 순 · 엑셀 자료 · 인쇄 새 창) + konetShown 날 넘김
        + ✏ 작성 탭(숨김 확인 뒤 WRITE_ON 을 켜고 : 방 목록 그룹 먼저 · 줄 → 번호 글 · 사람이 붙인 번호 떼기 · 날짜 묶음 추가/빼기 · 이미 있는 날짜 안내 · 빈 항목·4,000자 관문 · /emp/msgSend.do 본문 · 보낸 뒤 재조회·격자 칸 열기) */
const fs = require('fs'), path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
function req(name){ const tries=[name, path.join(process.env.TEMP||'', 'konet_chk/node_modules', name), 'C:/Users/user/git/winn/wnn_medcost/docs/tools/sim/node_modules/'+name];
  for (const t of tries){ try { return require(t); } catch(e){} } throw new Error(name+' 모듈 없음'); }
const { JSDOM } = req('jsdom');
const src = fs.readFileSync(path.join(ROOT, 'src/main/webapp/WEB-INF/jsp/main/mangr/empWorkLog.jsp'), 'utf8').replace(/\r\n/g, '\n');
let ok = 0, bad = 0;
function t(name, cond, info){ if(cond) ok++; else { bad++; console.log('✗ ' + name + (info!==undefined ? ' — ' + info : '')); } }

/* ── 가짜 자료 — 캡처(2026-11-06 그룹방)의 글 꼴 그대로 ── */
const TXT_KIM = '11/6\n1. 105파이 입고\n2. 비씨팔백 원두택배\n3. 쿠팡택배\n4. 롤지택배\n5. 급식택배\n6. 대승 홀더 견적서확인\n7. 소모품 계약리스트 정리준비\n8. 씨케이지피 세금계산서 발행\n9. 냅킨코리아 bh004 4건 주문\n\n11/7\n1. 소모품 계약리스트 정리하기\n2. 쿠팡택배\n3. 동원물류 택배\n4 대상급식 입력하기';
const TXT_JEON = '11/6\n1. 삼성 직,배송건 출력\n2. 입고건 매입전환 (에스이아이엘, 대영, 세경, 한국PLA)\n3. 프로티너 펄프몸체 택배처리\n4. 재고맞춤 및 서브코드 정리\n5. 배송출고건 검수 및 입문증 출력\n\n11/8\n1. 삼성 직배송건 출력\n2. 재고맞춤 및 서브코드정리\n3. 배송출고건 검수 및 입문증 출력';
const TXT_SEOL = '11/6\n1.피킹 및 창고정리\n2.왜관 납품\n3.평택/오산 납품\n\n11/8\n1. 피킹 및 창고정리\n2. 평택/오산 납품';
const TXT_NODATE = '오늘은 재고 실사만 했습니다\n- 창고 A 라인\n- 창고 B 라인';
const TXT_KIM2 = '11/7(금)\n5. 추가 — 거래명세서 발송';        /* 같은 직원·같은 날짜 두 번째 글(합쳐야) */
const TXT_OLD = '2026-10-20\n1) 월말 정리';                /* 기간 밖 — 격자에서 빠져야 */
const LIST = [
  { msgSeq: 1, roomSeq: 3, userId: 'K001', userNm: '김민지', msgTxt: TXT_KIM,    regDttm: '2026-11-06 17:40:00' },
  { msgSeq: 2, roomSeq: 3, userId: 'J001', userNm: '전원배', msgTxt: TXT_JEON,   regDttm: '2026-11-06 17:50:00' },
  { msgSeq: 3, roomSeq: 3, userId: 'S001', userNm: '설재우', msgTxt: TXT_SEOL,   regDttm: '2026-11-06 16:17:00' },
  { msgSeq: 4, roomSeq: 3, userId: 'L001', userNm: '이영섭', msgTxt: TXT_NODATE, regDttm: '2026-11-05 18:02:00' },
  { msgSeq: 5, roomSeq: 3, userId: 'K001', userNm: '김민지', msgTxt: TXT_KIM2,   regDttm: '2026-11-07 09:10:00' },
  { msgSeq: 6, roomSeq: 7, userId: 'K001', userNm: '김민지', msgTxt: TXT_OLD,    regDttm: '2026-10-20 18:00:00' },
];
const ROOMS = [ { roomSeq: 3, roomGb: 'G', roomNm: '', dispNm: '김민지, 강인성, 설재우, 이영섭, 이지훈, 전원배' }, { roomSeq: 7, roomGb: 'D', roomNm: '', dispNm: '김민지' } ];

/* ── 화면 올리기 ── */
const html = src.replace(/<%@[\s\S]*?%>/g, '').replace(/<%--[\s\S]*?--%>/g, '').replace(/\$\{pageContext\.request\.contextPath\}/g, '')
  .replace(/<script src="[^"]*"><\/script>/g, '').replace(/<link [^>]*>/g, '');
const calls = [];
const dom = new JSDOM(html, { url: 'http://localhost:9071/emp/workLog.do', runScripts: 'dangerously', pretendToBeVisual: true, beforeParse(w){   /* url 이 있어야 localStorage 가 산다(opaque origin 이면 SecurityError) */
  w.fetch = function(url, o){ calls.push({ url, body: JSON.parse(o.body) }); if (url === '/emp/msgSend.do'){ const b = JSON.parse(o.body); LIST.push({ msgSeq: 90 + LIST.length, roomSeq: b.roomSeq, userId: 'K001', userNm: '김민지', msgTxt: b.text, regDttm: '2026-11-08 10:00:00' }); return Promise.resolve({ json: () => Promise.resolve({ result: 'OK', msgSeq: 99 }) }); } return Promise.resolve({ json: () => Promise.resolve({ result: 'OK', list: LIST, rooms: ROOMS, me: 'K001' }) }); };
  w._alertBox = function(m){ w.__alerts = (w.__alerts||[]).concat([m]); };
  w._confirmBox = function(o){ w.__confirms = (w.__confirms||[]).concat([o.msg]); o.onOk && o.onOk(); };
  w._toast = function(m){ w.__toasts = (w.__toasts||[]).concat([m]); };
  w.open = function(){ const d = { html: '', open(){}, write(s){ this.html += s; }, close(){} }; w.__popup = d; return { document: d }; };
  /* 「오늘」 = 2026-11-08 로 고정 */
  const RealDate = w.Date;
  class FakeDate extends RealDate { constructor(...a){ if(a.length) super(...a); else super(2026, 10, 8, 10, 0, 0); } static now(){ return new RealDate(2026, 10, 8, 10, 0, 0).getTime(); } }
  w.Date = FakeDate;
} });
const w = dom.window, d = w.document;
const sleep = ms => new Promise(r => setTimeout(r, ms));

(async () => {
  await sleep(50);
  /* ── 1. 파서 ── */
  const P = w.parseWorkLog;
  const g1 = P(TXT_KIM, '2026-11-06 17:40:00');
  t('날짜 둘 든 글 → 묶음 2', g1.length === 2, g1.length);
  t('11/6 = 2026-11-06 · 9건', g1[0].date === '2026-11-06' && g1[0].items.length === 9, JSON.stringify(g1[0]));
  t('첫 항목 번호 떼기', g1[0].items[0] === '105파이 입고', g1[0].items[0]);
  t('11/7 = 4건 · 「4 대상급식」(점 없음)도 항목', g1[1].items.length === 4 && g1[1].items[3] === '대상급식 입력하기', JSON.stringify(g1[1].items));
  const g3 = P(TXT_SEOL, '2026-11-06 16:17:00');
  t('「3.평택/오산 납품」 번호 뒤 공백 없어도', g3[0].items[2] === '평택/오산 납품', JSON.stringify(g3[0].items));
  t('설재우 11/8 2건', g3[1].date === '2026-11-08' && g3[1].items.length === 2);
  const g4 = P(TXT_NODATE, '2026-11-05 18:02:00');
  t('날짜 없는 글 = 보낸 날짜 한 묶음 · hasDate false', g4.length === 1 && g4[0].date === '2026-11-05' && g4[0].hasDate === false && g4[0].items.length === 3, JSON.stringify(g4));
  t('「- 」 머리 떼기', g4[0].items[1] === '창고 A 라인');
  const g5 = P(TXT_KIM2, '2026-11-07 09:10:00');
  t('「11/7(금)」 요일 붙은 날짜 줄', g5.length === 1 && g5[0].date === '2026-11-07' && g5[0].items[0] === '추가 — 거래명세서 발송', JSON.stringify(g5));
  t('「2026-11-06」 연도 있는 꼴', P('2026-11-06\n1. a', '2026-11-20 00:00:00')[0].date === '2026-11-06');
  t('「11.06」 점 꼴', P('11.06\n1. a', '2026-11-20 00:00:00')[0].date === '2026-11-06');
  t('해 넘김 — 12월에 쓴 「1/3」 = 다음 해', P('1/3\n1. a', '2026-12-28 00:00:00')[0].date === '2027-01-03');
  t('해 넘김 — 1월에 쓴 「12/30」 = 지난 해', P('12/30\n1. a', '2027-01-02 00:00:00')[0].date === '2026-12-30');
  t('같은 해 안 — 11월에 쓴 「6/1」은 올해', P('6/1\n1. a', '2026-11-06 00:00:00')[0].date === '2026-06-01');
  const gBad = P('2/30\n1. a', '2026-11-06 00:00:00');
  t('없는 날짜(2/30)는 날짜 줄로 안 봄 → 항목으로 보낸 날짜 묶음', gBad.length === 1 && gBad[0].date === '2026-11-06' && gBad[0].items.length === 2, JSON.stringify(gBad));
  t('빈 줄만 있는 글 → 묶음 0', P('\n\n  \n', '2026-11-06 00:00:00').length === 0);
  t('날짜 줄만 있고 항목 없음 → 묶음은 남되 0건', (() => { const r = P('11/9', '2026-11-06 00:00:00'); return r.length === 1 && r[0].items.length === 0; })());
  t('CRLF 글도 같게', P('11/6\r\n1. a\r\n2. b', '2026-11-06 00:00:00')[0].items.length === 2);
  t('「1, 상품 피킹」 쉼표 번호 · 「3 창고 주변정리」(운영 글 꼴)', (() => { const r = P('11/5  \n1, 상품 피킹 및 재고 출고\n2, 파렛트 정리\n3 창고 주변정리', '2026-11-05 17:07:16')[0]; return r.date === '2026-11-05' && r.items.join('|') === '상품 피킹 및 재고 출고|파렛트 정리|창고 주변정리'; })());

  /* ── 2. 처음 올라오면 해당월(11-01~11-08)로 조회 · 서버에는 ±14일 ── */
  t('기본 기간 = 이번 달 1일 ~ 오늘', d.getElementById('frDt').value === '2026-11-01' && d.getElementById('toDt').value === '2026-11-08', d.getElementById('frDt').value + '~' + d.getElementById('toDt').value);
  t('서버에 보낸 때 ±14일로 묻는다', calls.length === 1 && calls[0].url === '/emp/workLogList.do' && calls[0].body.frDt === '2026-10-18' && calls[0].body.toDt === '2026-11-22' && calls[0].body.roomSeq === 0, JSON.stringify(calls[0]));
  t('해당월 단추 켜짐', d.getElementById('rgM').className.indexOf('on') > 0);

  /* ── 3. 격자 ── */
  const ths = [...d.querySelectorAll('#gHead th')].map(x => x.firstChild.textContent);
  t('열 = 날짜 + 직원 4명(이름순)', ths.join('|') === '날짜|김민지|설재우|이영섭|전원배', ths.join('|'));
  const dts = [...d.querySelectorAll('#gBody td.dt')].map(x => x.firstChild.textContent);
  t('행 = 날짜 최근이 위 · 10/20 은 기간 밖', dts.join('|') === '2026-11-08|2026-11-07|2026-11-06|2026-11-05', dts.join('|'));
  function cell(nm, dt){ const ci = ths.indexOf(nm); const tr = [...d.querySelectorAll('#gBody tr')].find(r => r.querySelector('td.dt').firstChild.textContent === dt); return tr.children[ci]; }
  t('김민지 11/6 칸 9건', cell('김민지', '2026-11-06').querySelector('.n').textContent === '9건');
  t('김민지 11/7 칸 = 두 글 합쳐 5건 · 번호 다시 셈 · 최근 글(11-07 09:10 「추가 …」)이 앞', cell('김민지', '2026-11-07').querySelector('.n').textContent === '5건' && cell('김민지', '2026-11-07').querySelectorAll('li').length === 5 && cell('김민지', '2026-11-07').querySelectorAll('li')[0].textContent === '추가 — 거래명세서 발송' && cell('김민지', '2026-11-07').querySelectorAll('li')[1].textContent.indexOf('소') === 0, [...cell('김민지', '2026-11-07').querySelectorAll('li')].map(x => x.textContent).join('|'));
  t('전원배 11/6 5건 · 11/8 3건', cell('전원배', '2026-11-06').querySelector('.n').textContent === '5건' && cell('전원배', '2026-11-08').querySelector('.n').textContent === '3건');
  t('설재우 11/8 2건 · 11/7 빈 칸', cell('설재우', '2026-11-08').querySelector('.n').textContent === '2건' && cell('설재우', '2026-11-07').children.length === 0);
  t('이영섭(날짜 없는 글) 11/5 3건', cell('이영섭', '2026-11-05').querySelector('.n').textContent === '3건');
  t('머리글 직원 합계 (김민지 14건)', d.querySelectorAll('#gHead th')[1].querySelector('small').textContent === '14건');
  t('요약 카드 — 직원 4 · 날짜 4 · 항목 30 · 글 5', d.getElementById('kEmp').textContent === '4명' && d.getElementById('kDay').textContent === '4일' && d.getElementById('kItem').textContent === '30건' && d.getElementById('kMsg').textContent === '5건',
    [d.getElementById('kEmp').textContent, d.getElementById('kDay').textContent, d.getElementById('kItem').textContent, d.getElementById('kMsg').textContent].join(' '));
  t('방 고르기에 내 방 2 + 전부', d.getElementById('room').options.length === 3 && d.getElementById('room').options[2].textContent.indexOf('1:1 · 김민지') === 0);

  /* ── 4. 칸 클릭 → 상세 ── */
  cell('김민지', '2026-11-07').querySelector('.cell').click();
  await sleep(10);
  const dtl = d.getElementById('dtl');
  t('상세 열림 · 글 2건 원문', dtl.className === 'card on' && dtl.querySelectorAll('.src').length === 2 && dtl.querySelector('.dh b').textContent === '김민지', dtl.querySelector('.dh') && dtl.querySelector('.dh').textContent);
  t('상세 원문의 날짜 줄 강조', dtl.querySelectorAll('.src pre .dl').length === 3);
  t('상세 글은 최근 보낸 것부터(11-07 09:10 → 11-06 17:40)', [...dtl.querySelectorAll('.src .meta b')].map(x => x.textContent).join('|') === '2026-11-07 09:10:00|2026-11-06 17:40:00', [...dtl.querySelectorAll('.src .meta b')].map(x => x.textContent).join('|'));
  t('[⛶ 크게] 토글 — .cols.big · 글자 · 기억', (() => { const bg = d.getElementById('dtlBg'); const cols = d.querySelector('.cols'); const a = bg.textContent === '⛶ 크게' && !cols.classList.contains('big'); bg.click(); const b = cols.classList.contains('big') && bg.textContent === '⛶ 작게' && w.localStorage.getItem('konetWlDtlBig') === '1'; bg.click(); const c = !cols.classList.contains('big') && bg.textContent === '⛶ 크게'; return a && b && c; })());
  t('고른 칸 .on', cell('김민지', '2026-11-07').querySelector('.cell').className.indexOf('on') > 0);
  w.dtlClose(); await sleep(5);
  t('상세 닫기', d.getElementById('dtl').className === 'card');

  /* ── 5. 거르기 ── */
  d.getElementById('q').value = '택배'; w.render();
  t('글자 거르기 — 김민지 11/6 칸 「4건 / 9」 · 걸린 항목 노랑', cell('김민지', '2026-11-06').querySelector('.n').textContent === '4건 / 9' && cell('김민지', '2026-11-06').querySelectorAll('li.hit').length === 4, cell('김민지', '2026-11-06').querySelector('.n').textContent);
  t('안 걸린 직원 열은 빠짐(이영섭)', [...d.querySelectorAll('#gHead th')].map(x => x.firstChild.textContent).indexOf('이영섭') < 0);
  t('요약은 거른 것 기준', d.getElementById('kItem').textContent === '7건' && d.getElementById('kNote').style.display === '', d.getElementById('kItem').textContent);
  d.getElementById('q').value = ''; d.getElementById('emp').value = 'J001'; w.render();
  t('직원 거르기 — 열 하나', d.querySelectorAll('#gHead th').length === 2 && d.getElementById('kDay').textContent === '2일');
  d.getElementById('emp').value = ''; w.render();

  /* ── 6. 직원별 탭 ── */
  w.tab('emp'); await sleep(5);
  t('직원별 탭 — 직원 「전체」면 첫 직원(김민지)이 골라진다', d.getElementById('emp').value === 'K001' && d.getElementById('eTitle').textContent === '김민지');
  const eDates = [...d.querySelectorAll('#eBody td[rowspan]')].filter((x, i) => i % 2 === 0).map(x => x.textContent);
  t('최근 날짜가 위 · 11/7 · 11/6', eDates.join('|') === '2026-11-07|2026-11-06', eDates.join('|'));
  t('줄 수 = 14 · 번호 다시 셈(최근 11/7 5줄이 앞 · 11/6 9줄이 뒤)', d.querySelectorAll('#eBody tr').length === 14 && d.querySelectorAll('#eBody tr')[4].children[0].textContent === '5' && d.querySelectorAll('#eBody tr')[13].children[0].textContent === '9');
  t('격자 숨고 직원별 표 보임', d.getElementById('gridWrap').style.display === 'none' && d.getElementById('empWrap').style.display === '');
  const ed = w.eData();
  t('엑셀 자료 14줄 · 칸 6 · 방 이름', ed.length === 14 && ed[0].length === 6 && ed[0][5].indexOf('김민지, 강인성') === 0 && ed[0][0] === '2026-11-07' && ed[4][2] === 5 && ed[13][2] === 9, JSON.stringify(ed[13]));
  w.ePrint(); await sleep(5);
  t('인쇄 = 새 창에 그린다(이 창 print 아님)', w.__popup && w.__popup.html.indexOf('직원 업무일지 — 김민지') > 0 && w.__popup.html.indexOf('window.print()') > 0);
  d.getElementById('emp').value = 'S001'; w.render();
  t('다른 직원 고르면 그 사람만(설재우 5줄)', d.querySelectorAll('#eBody tr').length === 5 && d.getElementById('eTitle').textContent === '설재우');
  w.tab('grid'); await sleep(5);
  t('격자 탭 복귀', d.getElementById('gridWrap').style.display === '' && d.getElementById('empWrap').style.display === 'none');
  t('손으로 고른 직원(설재우)은 격자에서도 유지', d.getElementById('emp').value === 'S001' && d.querySelectorAll('#gHead th').length === 2);
  d.getElementById('emp').value = ''; w.render(); w.tab('emp'); await sleep(5);
  t('「전체」로 직원별 탭 → 첫 직원 자동', d.getElementById('emp').value === 'K001');
  w.tab('grid'); await sleep(5);
  t('자동으로 고른 것은 격자로 돌아오면 「전체」로 — 열 전부', d.getElementById('emp').value === '' && d.querySelectorAll('#gHead th').length === 5, d.getElementById('emp').value + ' ths=' + d.querySelectorAll('#gHead th').length);

  /* ── 7. 빠른 단추 · konetShown ── */
  const n0 = calls.length;
  w.rg('w'); await sleep(20);
  t('1주일 = 11-02 ~ 11-08 · 재조회', d.getElementById('frDt').value === '2026-11-02' && calls.length === n0 + 1);
  d.getElementById('frDt').value = '2026-11-03'; w.rgSync();
  t('손으로 고치면 단추 색 꺼짐', d.getElementById('rgW').className === 'btn qb');
  w.konetShown();
  t('3초 안 konetShown 은 무시', calls.length === n0 + 1);
  w._loadedAt = 0; w._todayAt = '2026-11-07'; d.getElementById('toDt').value = '2026-11-07';   /* 어제 연 화면인 척 */
  w.konetShown(); await sleep(20);
  t('날이 바뀌었으면 끝날짜를 오늘로 옮기고 다시 읽는다', d.getElementById('toDt').value === '2026-11-08' && calls.length === n0 + 2, d.getElementById('toDt').value + ' calls=' + calls.length);
  t('alert/confirm 금지 — ui-message 만', !w.__alerts || w.__alerts.length === 0);

  /* ── 8. ✏ 작성 탭 — 2026-11-08 숨김(WRITE_ON=false) : 단추 안 보이고 탭 전환 거부. 그 뒤 WRITE_ON 을 켜 숨긴 코드도 그대로 검사한다 ── */
  t('작성 탭 단추 숨김(WRITE_ON=false)', d.getElementById('tbWrite').style.display === 'none' && w.WRITE_ON === false);
  w.tab('write'); await sleep(5);
  t("tab('write') 거부 — 격자 그대로", w.TAB === 'grid' && d.getElementById('writeWrap').style.display === 'none' && d.getElementById('gridWrap').style.display === '');
  w.WRITE_ON = true;   /* 아래는 켰을 때의 동작 */
  w.tab('write'); await sleep(5);
  t('작성 탭 — 칸 보이고 격자·직원별 숨김', d.getElementById('writeWrap').style.display === '' && d.getElementById('gridWrap').style.display === 'none' && d.getElementById('empWrap').style.display === 'none');
  const wr = d.getElementById('wRoom');
  t('보낼 방 = 내 방 전부 · 그룹방이 앞', wr.options.length === 2 && wr.options[0].value === '3' && wr.options[1].textContent.indexOf('1:1') === 0 && wr.value === '3', [...wr.options].map(o => o.value + ':' + o.textContent).join('|'));
  t('묶음 하나 · 날짜 = 오늘 · 빼기 ✕ 없음', d.querySelectorAll('#wBlocks .wblk').length === 1 && d.querySelector('#wBlocks .wDt').value === '2026-11-08' && !d.querySelector('#wBlocks .x'));
  t('빈 채 보내기 → 안내만', (() => { const n0 = calls.length; w.wSend(); return calls.length === n0 && w.__alerts.length === 1; })());
  d.querySelector('#wBlocks .wTx').value = '삼성 직배송건 출력\n2. 재고맞춤 및 서브코드정리\n\n- 배송출고건 검수\n   '; w.wPrevUpd();
  t('미리보기 = 「11/8」 + 번호 다시 붙임(사람이 붙인 2.·- 는 뗌)', d.getElementById('wPrev').textContent === '11/8\n1. 삼성 직배송건 출력\n2. 재고맞춤 및 서브코드정리\n3. 배송출고건 검수', JSON.stringify(d.getElementById('wPrev').textContent));
  t('건수 안내', d.getElementById('wCnt').textContent.indexOf('날짜 1개 · 항목 3건') === 0, d.getElementById('wCnt').textContent);
  w.wAddBlock(); await sleep(5);
  t('＋ 다음 날짜 묶음 = 다음 날 · 두 묶음엔 ✕', d.querySelectorAll('#wBlocks .wblk').length === 2 && d.querySelectorAll('#wBlocks .wDt')[1].value === '2026-11-09' && d.querySelectorAll('#wBlocks .x').length === 2);
  t('첫 묶음 글은 그대로', d.querySelectorAll('#wBlocks .wTx')[0].value.indexOf('삼성 직배송건') === 0);
  t('항목 없는 묶음이 있으면 막는다', (() => { const n0 = calls.length, a0 = w.__alerts.length; w.wSend(); return calls.length === n0 && w.__alerts.length === a0 + 1 && w.__alerts[a0].indexOf('11/9') === 0; })());
  d.querySelectorAll('#wBlocks .wDt')[1].value = '2026-11-07'; d.querySelectorAll('#wBlocks .wTx')[1].value = '내일 할 것'; w.wPrevUpd();
  t('이미 있는 날짜(김민지 11/7 5건) 안내', d.getElementById('wHas1').textContent.indexOf('이미 내 일지 5건') > 0, d.getElementById('wHas1').textContent);
  t('미리보기 두 묶음 = 빈 줄로 잇는다', d.getElementById('wPrev').textContent === '11/8\n1. 삼성 직배송건 출력\n2. 재고맞춤 및 서브코드정리\n3. 배송출고건 검수\n\n11/7\n1. 내일 할 것');
  w.wDelBlock(1); await sleep(5);
  t('✕ 로 묶음 빼기 — 하나 남으면 ✕ 사라짐', d.querySelectorAll('#wBlocks .wblk').length === 1 && !d.querySelector('#wBlocks .x'));
  d.querySelector('#wBlocks .wTx').value = 'x'.repeat(4100); w.wPrevUpd();
  t('4,000자 넘으면 막는다', (() => { const n0 = calls.length, a0 = w.__alerts.length; w.wSend(); return calls.length === n0 && w.__alerts.length === a0 + 1 && d.getElementById('wCnt').textContent.indexOf('4,000자를 넘었') > 0; })());
  d.querySelector('#wBlocks .wTx').value = '삼성 직배송건 출력\n재고맞춤'; w.wPrevUpd();
  const nSend = calls.length; w.wSend(); await sleep(30);
  const sendCall = calls[nSend];
  t('확인창 뒤 /emp/msgSend.do 로 {roomSeq, text}', sendCall && sendCall.url === '/emp/msgSend.do' && sendCall.body.roomSeq === 3 && sendCall.body.text === '11/8\n1. 삼성 직배송건 출력\n2. 재고맞춤', JSON.stringify(sendCall));
  t('확인창 문구에 방·건수', w.__confirms && w.__confirms[w.__confirms.length-1].indexOf('김민지, 강인성') > 0 && w.__confirms[w.__confirms.length-1].indexOf('항목 2건') > 0);
  t('보낸 뒤 다시 읽고(workLogList) 격자 탭으로 · 내 칸(ME=K001 · 11/8) 상세 열림', calls.length === nSend + 2 && calls[nSend+1].url === '/emp/workLogList.do' && d.getElementById('gridWrap').style.display === '' && d.getElementById('dtl').className === 'card on' && d.getElementById('dtl').querySelector('.dh b').textContent === '김민지', calls.length - nSend);
  t('작성 칸은 비워진다', d.querySelector('#wBlocks .wTx').value === '' && d.querySelectorAll('#wBlocks .wblk').length === 1);
  t('토스트', w.__toasts && w.__toasts.some(x => x.indexOf('메신저로 보냈습니다') > 0));
  w.tab('write'); d.querySelector('#wBlocks .wDt').value = '2026-11-20'; d.querySelector('#wBlocks .wTx').value = '먼 날짜'; w.wPrevUpd(); w.wSend(); await sleep(30);
  t('기간 밖 날짜를 보내면 끝날짜가 그 날짜까지 넓어진다', d.getElementById('toDt').value === '2026-11-20' && d.getElementById('rgM').className === 'btn qb', d.getElementById('toDt').value);
  wr.value = '7'; w.wRoomKeep();
  t('고른 방 기억(localStorage)', w.localStorage.getItem('konetWorkLogRoom') === '7');

  console.log((bad ? '✗ ' : '✓ ') + 'sim_empWorkLog : 통과 ' + ok + ' · 실패 ' + bad);
  process.exit(bad ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
