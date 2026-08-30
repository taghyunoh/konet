<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- ★날짜 칸에 달력 아이콘·[◀][▶][오늘] 을 자동으로 붙인다 (2026-08-17 요청) — 화면 수정 0.
     기본 달력의 ↑↓ 는 앞/뒤가 안 읽혀, 월 이동을 ‹ › 로 둔 우리 달력을 띄운다.
     빼려면 그 칸에 data-nonav="1" --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js?v=20260828f"></script>
<%--
  출고현황표(데시보드2) — 사이드바 iframe 패널로 로드되는 단독 화면 (logistics_demo.jsp 의 logiFrame 패턴)
  · 상단: 데시보드1과 공통 — 제목 + 액션버튼(엑셀업로드/매출·매입 업로드/출고데이타저장/출고장별 출력, 클릭 시 데시보드1로 전환하여 실행)
          + 조회바(출고일자/조회/당일/당월) + KPI
  · 툴바: 데시보드1과 공통 — 사업장 찾기 / 줌 / 전체화면·기본화면 / 출고장 접기·펼치기 / 품목·출고장 추가·초기화(데시보드1로 위임) / 사업장 보기
          — 합계맨앞 체크박스는 두지 않음(합계·소계는 항상 앞쪽(상단) 고정 배열)
  · 본문: 좌측 출고장 + 우측 내용(사업장·품목명·품목코드·출고수량)을 한 그리드(단일 표)로 표시
          — 맨 위 전체 합계 행, 출고장 블록마다 소계 행을 상단에 표시. 출고장 셀/소계행 클릭으로 개별 접기·펼치기
  · 하단 출고내역·재고(당월출고 이하 데모행)는 표시하지 않음
  · 데이터: /shipout/selectShipoutMst.do (단일 출고일자 활성배치) — 데시보드1과 동일 소스
--%>
<!DOCTYPE html>


<html>
<head>
<meta charset="UTF-8">
<title>출고현황표(데시보드2)</title>
<style>
  :root { --teal:#1f9b8e; --teal-dk:#178074; --bd:#dfe6e3; --bg:#f4f8f7; }
  * { box-sizing:border-box; }
  html, body { height:100%; }
  /* ★글꼴·기본 크기는 전 화면 공통 (2026-08-03) — 셸(logistics_demo2.jsp)의 .panel 주석 참고 */
  body { margin:0; padding:0; background:var(--bg); font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#10161d; font-weight:700; }
  b, th, h2 { font-weight:900; }
  

  /* 화면(iframe) 높이를 세로로 꽉 채움 — 그리드가 남는 공간을 모두 차지(해상도 커져도 하단 빈공간 없음) */
  /* 아래 여백을 줄여 표를 하단까지 내린다 (2026-08-28 요청 「하단공간 조금 넓혀서」).
     이 화면은 iframe 이고 높이가 100vh 로 고정이라, 표가 쓸 수 있는 세로는
     <바깥 여백 + 카드 안쪽 여백>을 줄인 만큼만 늘어난다. 좌우·위 여백은 그대로. */
  .d2-wrap { padding:14px 11px 3px; height:100vh; display:flex; flex-direction:column; }
  .d2-head, .d2-topbar { flex:0 0 auto; }
  /* gap 10 → 8 (2026-08-28 「출고세부조회가 두줄로」 — 한 줄에 담기게 조금씩 줄임)
     ★justify-content : space-between → flex-start (2026-08-28 연속 지적의 결론) —
       남는 공간을 요소 <사이>에 두는 한 어딘가는 늘 구멍으로 보였다(①[전체]↔요약 ②요약↔업로드
       ③제목 옆 — 세 번 다 동그라미로 지적됨). 전부 왼쪽으로 붙이고 남는 공간은 줄 맨 오른쪽
       끝에만 둔다. 줄이 접혀도(출고세부조회) 각 줄이 왼쪽부터 차므로 가운데 구멍이 안 생긴다. */
  .d2-head { display:flex; align-items:center; justify-content:flex-start; gap:8px; flex-wrap:wrap; margin-bottom:14px; }
  .d2-head h2 { margin:0; font-size:20px; color:#1f2a37; }
  .d2-head .sub { font-size:13px; color:#37475a; margin-top:4px; }
  .d2-head .actions { display:flex; gap:6px; flex-wrap:wrap; align-items:center; }
  /* 단추 좌우 여백 14 → 10 (2026-08-28 「출고세부조회가 두줄로」 — 한 줄 확보용, 이 줄만) */
  .d2-head .actions .btn-teal, .d2-head .actions .btn-line { padding:8px 10px; }
  .badge { display:inline-block; background:#e3f4ef; color:#137a6c; border:1px solid #b9e6dd; border-radius:11px; padding:1px 10px; font-size:11.5px; vertical-align:middle; }

  .btn-teal { background:var(--teal); color:#fff; border:none; border-radius:8px; padding:8px 14px; font-size:13px; cursor:pointer; font-weight:500; }
  .btn-teal:hover { background:var(--teal-dk); }
  .btn-line { background:#fff; color:#37475a; border:1px solid var(--bd); border-radius:8px; padding:8px 14px; font-size:13px; cursor:pointer; font-weight:500; }
  .btn-line:hover { background:#eef3f2; }

  /* 상단 조회바 + KPI (데시보드1 동일 스타일) */
  .d2-topbar { display:flex; align-items:center; justify-content:space-between; gap:14px; flex-wrap:wrap;
               background:#fff; border:1px solid var(--bd); border-left:4px solid var(--teal); border-radius:10px; padding:10px 16px; margin-bottom:14px; }
  /* ★조회조건 묶음(.tb-left)은 2026-08-28 요청으로 <제목줄(.d2-head)>로 올렸다 —
     그래서 규칙을 .d2-topbar 밑이 아니라 .tb-left 자체에 건다(어디에 놓이든 같은 모양). */
  .tb-left { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
  /* 제목 · 조회조건 · 요약숫자는 왼쪽으로 모으고, 남는 자리는 <요약숫자 오른쪽>에 준다
     → 액션단추만 오른쪽 끝. (2026-08-28 「표시부분은 조금 좌측으로」 — 종전에는 남는 자리가
        조회조건 오른쪽에 몰려 요약숫자가 액션단추에 붙어 있었다) */
  /* ★요약숫자 좌우 틈은 <작게 고정> (2026-08-28 「1번,2번 공간 조금만 좁혀줘」) —
     남는 공간은 위 .d2-head 의 flex-start 가 줄 맨 오른쪽 끝으로 보낸다(요소 사이 구멍 금지).
     [이력] margin 18px → 35px 「우측을 살짝」 → auto/auto 「빈공간 축소」 → 제목 뒤 auto
     (「제목 옆 구멍」 지적으로 폐기) → 14px 고정 + flex-start(지금). 되살리기 전에 이 이력 확인. */
  .d2-head .tb-stats { margin-left:14px; margin-right:14px; gap:6px; }
  .tb-left label { font-size:13px; color:#37475a; }
  /* width 132px 명시 (2026-08-28 머리줄 한 줄 확보 — 기본폭이 화면마다 150px 안팎으로 넉넉했다) */
  .tb-left input[type=date] { height:34px; width:132px; border:1px solid #cfd9e2; border-radius:8px; padding:0 8px; font-size:13px; cursor:pointer; background:#fff; font-weight:400; }
  .tb-left input[type=date]:hover { border-color:var(--teal); }
  .tb-left .btn-teal, .tb-left .btn-line { padding:5px 10px; }  /* 14 → 10 (2026-08-28 한 줄 확보) */
  /* ★날짜칸은 자동조회하지 않는다 (2026-08-28 요청 「날짜 선택하면 자동검색인데 조회버튼 실행해야 되게」).
     자동조회를 끄면 <바꾼 날짜와 화면의 표가 다른> 시간이 생긴다 — 그 사실이 보여야 한다.
     그래서 날짜가 바뀌면 [조회]가 주황으로 깜박이고 옆에 안내가 뜬다. 조회하면 원래대로. */
  #d2BtnSearch.need { background:#e67e22; animation:d2NeedPulse 1.2s ease-out infinite; }
  #d2BtnSearch.need:hover { background:#d3701b; }
  @keyframes d2NeedPulse { 0%{ box-shadow:0 0 0 0 rgba(230,126,34,.55); } 70%{ box-shadow:0 0 0 9px rgba(230,126,34,0); } 100%{ box-shadow:0 0 0 0 rgba(230,126,34,0); } }
  #d2NeedMsg { display:none; font-size:12px; font-weight:700; color:#c0651a; white-space:nowrap; }
  .d2-info { font-size:12px; color:#6b7a89; flex:1 1 200px; min-width:160px; line-height:1.4; }
  .d2-srcbadge { display:inline-block; background:#eef3f2; color:#37475a; border:1px solid var(--bd); border-radius:11px; padding:1px 10px; font-size:11.5px; margin-right:6px; }
  .d2-srcbadge.up { background:#e3f4ef; color:#137a6c; border-color:#b9e6dd; }
  .tb-stats { display:flex; gap:8px; flex-wrap:wrap; }
  .tb-stats .st { background:var(--bg); border:1px solid var(--bd); border-radius:8px; padding:5px 14px; text-align:center; min-width:92px; }
  .tb-stats .st-l { display:block; font-size:11px; color:#6b7a89; }
  .tb-stats .st-v { display:block; font-size:18px; font-weight:800; color:#1f2a37; line-height:1.25; }

  /* 툴바 (데시보드1 공통) */
  /* 좌→우로 채우되 폭 부족 시 다음 줄로 내려감(데시보드1처럼). overflow:visible 이라야 드롭다운이 잘리지 않고 제자리에 뜸 */
  .d2-toolbar { display:flex; align-items:center; justify-content:flex-start; gap:8px; flex-wrap:wrap; overflow:visible; margin-bottom:12px; }
  .d2-toolbar .tl, .d2-toolbar .tr { display:flex; gap:6px; align-items:center; flex-wrap:nowrap; flex:0 0 auto; }
  /* 보기 탭 — 목록 / 가로표 (2026-08-28) */
  /* 보기 탭 — 2026-08-28 「표시 크게 / 기본선택표시」. 지금 어느 화면인지 한눈에 보여야 해서 크게+진하게. */
  .d2-vtab { display:inline-flex; border:1px solid var(--bd); border-radius:9px; overflow:hidden; margin-right:8px; }
  .d2-vtab .vt { border:0; background:#fff; color:#5a6b7a; font-size:15px; font-weight:800; padding:8px 22px; cursor:pointer; letter-spacing:-0.3px; }
  .d2-vtab .vt + .vt { border-left:1px solid var(--bd); }
  .d2-vtab .vt:hover { background:#eef3f2; }
  .d2-vtab .vt.on { background:#137a6c; color:#fff; box-shadow:inset 0 -3px 0 rgba(0,0,0,.18); }
  /* 제목줄 콤보가 길어지면 그 줄이 통째로 접혀 「엑셀 보기/출력」 단추가 아랫줄로 내려간다 — 폭을 묶어 막는다 */
  .d2-head .actions select { max-width:150px; }
  /* 가로표 — 첫 칸(출고장)과 머리줄을 고정해 옆으로 밀어도 무엇의 값인지 보인다 */
  /* 글자 크기 (2026-08-28 「폰트 조금 크게」) — 표 13.5px / 품목 머리줄 12px.
     ★키우면 칸도 같이 넓혀야 한다 — 안 그러면 품목명이 더 잘게 접혀 머리줄만 높아진다. */
  table.d2-mx { border-collapse:separate; border-spacing:0; font-size:15px; }
  table.d2-mx th, table.d2-mx td { border:1px solid var(--bd); padding:5px 9px; white-space:nowrap; text-align:right; background:#fff; }
  table.d2-mx .cn { text-align:left; position:sticky; left:0; z-index:2; min-width:300px; font-weight:600; }
  table.d2-mx thead th { position:sticky; top:0; z-index:3; background:#dfeaf5; color:#1f2a37; height:34px; }
  /* 「출고장 / 품목」 모서리칸 · 사업장 머리줄은 표에서 길잡이라 본문보다 크게(2026-08-28) */
  table.d2-mx thead th.cn { z-index:4; background:#dfeaf5; font-size:17px; font-weight:800; }
  table.d2-mx thead th.it { top:34px; background:#eef4fa; font-weight:600; white-space:normal;
                            min-width:132px; max-width:186px; line-height:1.4; font-size:13px; }
  table.d2-mx thead th.it .nm { color:#5a6b7a; font-weight:400; }
  table.d2-mx td.none { background:#f1f3f5; }
  /* ★출고장 줄 높이를 못박는다 — 접었다 폈다 해도 위아래 간격이 그대로여야 눈이 줄을 안 놓친다(2026-08-28) */
  table.d2-mx tbody td { height:29px; box-sizing:border-box; }
  /* 사업장 머리칸 = 접기 손잡이 */
  /* ★사업장 병합 머리칸 진하게 + 사업장 경계 구분선 (2026-08-28 요청 「사업장 구분선 및 진하게」) —
       연한 파랑에 경계선이 옅어 어느 품목이 어느 사업장 것인지 줄을 세로로 따라가기 어려웠다.
       .gs = 각 사업장의 첫 칸(머리줄·품목줄·본문·합계·현재고까지) — 굵은 세로선으로 경계를 내려 긋는다. */
  table.d2-mx thead th.bz { cursor:pointer; user-select:none; font-size:16px; font-weight:900; letter-spacing:-0.2px; padding:6px 9px;
                            background:#5a7a9a; color:#fff; }
  table.d2-mx thead th.bz:hover { background:#49688a; }
  table.d2-mx th.gs, table.d2-mx td.gs { border-left:2px solid #5a7a9a; }
  /* ★접힌 사업장 (2026-08-28 「엑셀처럼 헤더 축소/확대」) — 접혀 있다는 것이 색으로 바로 보이게.
     .fd = 머리칸·합계 머리줄 / .fdv = 그 아래 값 칸(호박색 = 여러 품목을 더한 값이라는 표시) */
  table.d2-mx thead th.bz.fd { background:#7a6a3f; }
  table.d2-mx thead th.bz.fd:hover { background:#655736; }
  table.d2-mx thead th.bz .fn { font-size:12.5px; font-weight:700; color:#e8dfc4; }
  table.d2-mx thead th.it.fd { background:#f6efd9; color:#6b5a20; font-weight:800; cursor:pointer; }
  table.d2-mx thead th.it.fd:hover { background:#efe4c4; }
  table.d2-mx td.fdv { background:#fdf8ec; font-weight:800; }
  table.d2-mx tr.grp td.fdv { background:#0f6c60; }
  table.d2-mx tr.sum td.fdv { background:#efe9dc; }
  table.d2-mx tr.zc  td.fdv { background:#dde9d2; }
  table.d2-mx tr.stk td.fdv { background:#fbeedd; }
  /* 숨긴 사업장 되살리기 줄 — 가로로 밀어도 따라오게 sticky left:0 (2026-08-28 「숨김/펼치기」) */
  .d2-mxhide { position:sticky; left:0; width:max-content; max-width:100%; margin:0 0 8px; padding:7px 10px;
               background:#fff7e6; border:1px solid #f0d9a8; border-radius:8px; font-size:13px; color:#7a5a12;
               display:flex; align-items:center; gap:6px; flex-wrap:wrap; }
  .d2-mxhide .wn { color:#a1741c; font-size:12.5px; }
  .d2-mxhide .hc { border:1px solid #e0c48a; background:#fff; color:#7a5a12; border-radius:14px; padding:3px 11px; font-size:12.5px; font-weight:700; cursor:pointer; }
  .d2-mxhide .hc:hover { background:#fdf1d8; }
  .d2-mxhide .hall { border:1px solid var(--bd); background:#fff; color:#137a6c; border-radius:8px; padding:3px 11px; font-size:12.5px; font-weight:700; cursor:pointer; }
  .d2-mxhide .hall:hover { background:#eef3f2; }
  /* 눌러서 접는 줄(2026-08-28) — 고정칸(cn·합계·품목수)은 제 배경을 따로 갖고 있어 함께 지정해야
     줄 전체가 같이 어두워진다(안 그러면 가운데 칸만 색이 바뀌어 줄이 갈라져 보인다). */
  table.d2-mx tr.grp { cursor:pointer; }
  table.d2-mx tr.grp:hover td,
  table.d2-mx tr.grp:hover td.cn, table.d2-mx tr.grp:hover td.rtot, table.d2-mx tr.grp:hover td.rcnt { background:#0e6659; }
  table.d2-mx tr.grp td { background:#137a6c; color:#fff; font-weight:700; }
  table.d2-mx tr.grp td.none { background:#0e6659; }
  table.d2-mx tr.grp td.cn { background:#137a6c; }
  table.d2-mx tr.grp .sub { font-weight:400; color:#cdeee8; font-size:13px; }
  table.d2-mx td.cn.zn { padding-left:20px; font-weight:400; }
  table.d2-mx td.cn.zn.zpick { cursor:pointer; }               /* 체크가 켜져 있을 때만 누를 수 있음을 커서로 */
  table.d2-mx td.cn.zn.zpick:hover { background:#eef7f4; }
  .mxfull { color:#9aa7b3; font-weight:400; font-size:.86em; } /* 병기(전체값) — 옅게 */
  th.cn .mxzchk { display:block; margin-top:6px; font-size:12px; font-weight:600; color:#37475a; cursor:pointer; user-select:none; }
  th.cn .mxzchk input { vertical-align:-2px; margin-right:3px; }
  /* 출고장 선택 필터 중인 줄 강조 (2026-08-30) */
  table.d2-mx tr.zsel td { background:#fff8e1; }
  table.d2-mx tr.zsel td.cn { background:#fdf3cd; font-weight:800; }
  table.d2-mx tr.zsel td.rtot { background:#fbeebb; }
  table.d2-mx td.rtot { background:#fff2cc; font-weight:700; }
  table.d2-mx td.rcnt { background:#e2efda; font-weight:700; }
  table.d2-mx th.rtot { background:#fbe9bd; }
  table.d2-mx th.rcnt { background:#d5e8c6; }
  table.d2-mx tr.sum td { background:#f2f2f2; font-weight:700; }
  table.d2-mx tr.zc td { background:#e2efda; font-weight:700; color:#375623; }
  /* 센터 소계(csub) — 가로표 판. ★색·글자 = 목록의 묶음 합계(gsub)와 동일 톤(2026-08-30 요청) · 고정칸 배경 불투명 필수 */
  table.d2-mx tr.csub td { background:#eaf5f2; color:#137a6c; font-weight:700; }
  table.d2-mx tr.csub td.cn { background:#dcefe9; padding-left:22px; }
  table.d2-mx tr.csub td.rtot { background:#eaf5f2; }
  table.d2-mx tr.csub td.none { background:#eaf5f2; }
  /* 「직송」 단어만 빨간 글씨 (2026-08-30 최종 — 라벨 전체 빨강에서 축소) */
  table.d2-tb .jkw, table.d2-mx .jkw { color:#c0392b; font-weight:800; }
  /* 진청록 묶음 머리줄(tr.grp) 위에서는 진빨강이 안 보인다(2026-08-30 지적) → 밝은 살구빛 빨강 */
  table.d2-mx tr.grp .jkw, table.d2-tb tr.grp .jkw { color:#ffb4a2; }
  table.d2-mx tr.stk td { background:#fff4e6; font-weight:700; color:#137a6c; }
  table.d2-mx tr.stk td.neg { color:#c0392b; }
  /* ★고정칸(출고장·합계·품목수)의 바탕은 반드시 <불투명한 색>이어야 한다.
       background:inherit 은 tr 에 색이 없어 결국 투명 → 옆으로 밀면 스크롤되는 칸이 고정칸 <뒤로 비쳐>
       「합계 1 209 179」처럼 없는 숫자가 겹쳐 보인다(2026-08-28 지적). 색을 직접 박는다. */
  table.d2-mx tr.sum td.cn { background:#f2f2f2; }
  table.d2-mx tr.zc  td.cn { background:#e2efda; }
  table.d2-mx tr.stk td.cn { background:#fff4e6; }

  /* ★합계·품목수를 「출고장」 바로 뒤로 옮기고 같이 얼린다(2026-08-28 요청) — 옆으로 끝까지 밀어도 총량이 보인다.
     ★sticky 의 left 값은 앞칸 폭의 <합>이라 폭을 못박아야 한다. .cn 300(2026-08-30 「출고장 늘려줘」 — 배송·직송 나눔 라벨이 길어졌다) → 합계 300.
       폭을 바꾸면 left 도 같이 고쳐야 한다(안 그러면 칸이 겹치거나 틈이 생긴다). */
  /* 폭 확대 (2026-08-28 요청 「합계·품목수 확대」) : 합계 86 → 108 · 품목수 78 → 96.
     ⚠left 값은 앞칸 폭의 <합>이다 — 합계 left=300(.cn), 품목수 left=300+108=408. 폭을 또 바꾸면 여기도. */
  table.d2-mx .cn   { width:300px; min-width:300px; max-width:300px; box-sizing:border-box; }
  table.d2-mx .rtot { position:sticky; left:300px; z-index:2; width:108px; min-width:108px; max-width:108px; box-sizing:border-box; }
  table.d2-mx .rcnt { position:sticky; left:408px; z-index:2; width:96px;  min-width:96px;  max-width:96px;  box-sizing:border-box; }
  /* 글자도 한 단계 크게 — 이 두 칸이 표에서 가장 먼저 읽는 숫자다 */
  table.d2-mx td.rtot, table.d2-mx td.rcnt { font-size:16.5px; font-weight:800; }
  table.d2-mx thead th.rtot, table.d2-mx thead th.rcnt { font-size:15px; font-weight:800; }
  table.d2-mx thead th.rtot, table.d2-mx thead th.rcnt { z-index:4; }
  /* 줄 종류별 바탕색을 되살린다 — 안 넣으면 노랑/연두가 묶음줄·합계줄을 덮어쓴다 */
  table.d2-mx tr.grp td.rtot, table.d2-mx tr.grp td.rcnt { background:#137a6c; color:#fff; }
  table.d2-mx tr.sum td.rtot, table.d2-mx tr.sum td.rcnt { background:#f2f2f2; }
  table.d2-mx tr.zc  td.rtot, table.d2-mx tr.zc  td.rcnt { background:#e2efda; color:#375623; }
  table.d2-mx tr.stk td.rtot, table.d2-mx tr.stk td.rcnt { background:#fff4e6; }
  .d2-toolbar .tm { margin:0; flex:0 0 auto; }
  /* ★[2026-08-21] 화면 배율(가－/가＋)로 유효 폭이 줄면 우측 덩어리(출고장 접기~사업장 보기)가
     통째로 다음 줄로 떨어졌다(90% 실측 신고 「표시부분 밑으로 밀림」).
     ⚠flex-shrink 로는 못 막는다 — flex-wrap 컨테이너는 **줄이기 전에 줄바꿈부터** 한다(실측).
     ⇒ **컨테이너 쿼리** : 카드 폭이 좁아지면 검색칸·셀렉트·간격을 명시적으로 좁혀 한 줄을 지킨다.
       (배율은 CSS px 폭을 바꾸므로 컨테이너 쿼리가 정확히 따라간다. 90%≈1560 · 100%≈1400 근방이 목표,
        그보다 더 좁으면 종전대로 줄바꿈 — 110%↑ 배율에서는 어쩔 수 없다.)
       ⚠overflow-x:auto 로 풀면 안 된다 — 대표출고장·그룹순서 드롭다운(.dc-pop)이 잘린다. */
  #d2Card{ container-type:inline-size; }
  /* 상단 접기 — 2026-08-21 도구줄만 → 2026-08-28 '조회바+도구줄 통째로'(제목줄 .d2-head 까지)
       → ★같은 날 최종 「조회조건접기에서 해당라인의 제외」(제목줄에 밑줄+동그라미 스크린샷) :
         제목줄(.d2-head = 출고일자·조회·당일/당월/전체·요약숫자·엑셀 업로드/출력 단추)은 <접지 않는다>.
         접으면 조회·엑셀 업로드까지 사라져 매번 펼쳤다 접어야 했다 — 접는 것은 도구줄(.d2-toolbar)
         + 안내줄(.d2-topbar)만. (한때 body.tb-fold .d2-head{display:none} 이 여기 있었다 — 되살리자는
         얘기가 나오면 이 이력부터 확인할 것.)
     ★단추는 이 화면 안에 없다 — 셸(logistics_demo2.jsp) 맨 위 <자주 쓰는 메뉴> 줄의 [조회조건 접기].
       2026-08-28: 제목줄 오른쪽 끝에 두었더니 폭이 좁은 창에서 화면 밖으로 잘려 못 눌렀다.
       접기 자체는 여기 d2TbFold 가 하고, 셸 단추가 iframe 의 그 함수를 부른다.
     ⚠.d2-topbar 는 #d2Card 의 형제(.d2-wrap 직속)라 카드 클래스로는 못 잡는다 → body 에도 같은 클래스를 건다. */
  #d2Card.tb-fold .d2-toolbar{ display:none; }
  body.tb-fold .d2-topbar{ display:none !important; }
  /* 제목줄에 얹힌 요약숫자는 조금 좁게 — 제목+조회조건+요약+액션단추가 한 줄에 들어가야 한다.
     (1870px 실측: 제목 202 + 조회조건 647 + 요약 412 + 액션 567 = 여유가 거의 없다) */
  .d2-head .tb-stats .st { min-width:56px; padding:4px 9px; }  /* 64/12 → 56/9 (2026-08-28 「두줄로 생겨서」 한 줄 확보) */
  .d2-head .tb-stats .st-v { font-size:17px; }
  /* [이력] 2026-08-28 「해당 라벨 삭제」로 라벨을 감췄다가 「내용표시 없어짐」으로 <되살렸다> —
     숫자만 남으니 90/219/12/79 가 무엇인지 알 수 없었다. 대신 글자를 조금 줄여 한 줄을 지킨다. */
  .d2-head .tb-stats .st-l { font-size:10.5px; }
  @container (max-width:1660px){
    .d2-toolbar input[type=text]{ width:100px; }
  }
  @container (max-width:1480px){
    .d2-toolbar{ gap:6px; }
    .d2-toolbar .tl, .d2-toolbar .tr{ gap:4px; }
    .d2-toolbar input[type=text]{ width:76px; }
    .d2-toolbar select{ max-width:110px; }
    .d2-toolbar .sep{ padding-left:5px; gap:4px; }
    .d2-toolbar .btn-teal, .d2-toolbar .btn-line{ padding:5px 8px; }
  }
  .d2-toolbar > * { flex:0 0 auto; }
  /* 대표출고장(물류센터) 다중선택 콤보 — 드롭다운 체크박스(하나 이상 선택 조회) */
  .d2-toolbar .tm { position:relative; display:flex; align-items:center; }
  #d2DcBtn { min-width:150px; display:flex; align-items:center; justify-content:space-between; gap:6px; text-align:left; }
  #d2DcBtn .arr { margin-left:auto; flex:0 0 auto; color:#178074; }
  .dc-pop { display:none; position:absolute; top:38px; left:0; z-index:60; background:#fff; border:1px solid var(--bd);
            border-radius:8px; box-shadow:0 6px 18px rgba(31,42,55,.18); padding:8px 6px; min-width:220px; max-height:320px; overflow-y:auto; }
  .dc-pop.open { display:block; }
  .dc-pop label { display:flex; align-items:center; gap:7px; padding:6px 10px; font-size:12.5px; color:#37475a; cursor:pointer; border-radius:6px; }
  .dc-pop label:hover { background:#eef3f2; }
  .dc-pop label.all { color:#178074; border-bottom:1px dashed var(--bd); border-radius:6px 6px 0 0; margin-bottom:4px; }
  .dc-pop label.on { color:#0e6657; background:#e3f4ef; }
  .dc-pop label.kid { padding-left:26px; font-size:12px; }   /* 묶음 하위 개별 출고장 (2026-08-02) */
  .d2-toolbar label { font-size:13px; color:#37475a; font-weight:700; }
  .d2-toolbar input[type=text] { height:32px; border:1px solid #cfd9e2; border-radius:8px; padding:0 8px; font-size:13px; width:130px; font-weight:400; }
  .d2-toolbar select { height:32px; border:1px solid var(--bd); border-radius:6px; padding:0 8px; font-size:13px; font-weight:700; max-width:150px; }
  .d2-toolbar .btn-teal, .d2-toolbar .btn-line { padding:5px 11px; font-size:13px; }
  .d2-toolbar .zoomlbl { min-width:42px; text-align:center; font-size:13px; color:var(--teal-dk); font-weight:700; }
  .d2-toolbar .sep { padding-left:8px; margin-left:2px; border-left:1px solid var(--bd); display:inline-flex; gap:6px; align-items:center; }
  /* 접기/펼치기 라벨 길이가 달라도 폭 고정 — 줄바꿈 위치가 밀려 버튼이 이동하는 현상 방지 */
  #d2BtnZoneToggle { min-width:112px; text-align:center; }
  

  /* 본문: 출고장 + 내용 한 그리드 — 남는 세로 공간을 모두 차지(flex 채움) */
  .card { background:#fff; border:1px solid var(--bd); border-radius:10px; padding:12px 10px 5px; flex:1 1 auto; display:flex; flex-direction:column; min-height:0; }
  .card .d2-toolbar { flex:0 0 auto; }
  .card.d2-full { position:fixed; inset:0; z-index:999; border-radius:0; overflow:auto; }
  .card.d2-full .d2-scroll { flex:1 1 auto; }
  /* 그리드 스크롤 영역 = 남는 높이 전부. 데이터가 적으면 표가 그만큼만 차지(하단 빈공간은 카드 배경으로 채워짐) */
  .d2-scroll { flex:1 1 auto; min-height:0; overflow-y:auto; overflow-x:hidden; border:1px solid var(--bd); border-radius:8px; }
  /* 그리드 글자체 — 기준 13px, 그룹 12.5px, 출고장명 weight 600. table-layout:fixed = 컬럼폭 드래그 조절 */
  table.d2-tb { width:100%; border-collapse:separate; border-spacing:0; font-size:13px; table-layout:fixed; }
  table.d2-tb th, table.d2-tb td { border-bottom:1px solid var(--bd); border-right:1px solid var(--bd); padding:6px 8px; text-align:center; background:#fff; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  /* 헤더 열너비 조절 핸들 */
  table.d2-tb thead th { position:sticky; }
  .col-rz { position:absolute; top:0; right:0; width:8px; height:100%; cursor:col-resize; z-index:4; }
  .col-rz:hover { background:rgba(255,255,255,.5); }
  table.d2-tb th:first-child, table.d2-tb td:first-child { border-left:none; }
  <%-- ★[2026-08-28 요청 「스크롤시 글자 보이고 헤더 진하게」] 머리글을 다시 **진한 청록 + 흰 글자** 로.
       (2026-08-20 에 연한 청록으로 바꿨던 것을 이 화면만 사용자 요청으로 되돌림 — 이력 확인 후 손댈 것.)
       ★height:30px 로 못박는다 — 아래 tr.tot(전체 합계)가 top:30px 에 고정인데, 공통 밀도 CSS
       (konet-ui-fix §3)가 머리글 padding 을 줄여 실제 높이가 30px 미만이 되면서 **그 틈으로
       스크롤되는 자료 글자가 비쳐 보였다**(「스크롤시 글자 보이고」의 원인). 높이를 30 으로 맞추고
       tot 를 29px(1px 겹침)에 붙여 배율(zoom) 반올림 실틈까지 막는다 — 그래서 z-index 는 tot(3)보다
       높은 4 (겹친 1px 을 머리글이 덮는다). --%>
  <%-- 글자 12.5 → 14px (2026-08-28 요청 「헤더 글자 조금더 크게」) — 고정 높이 30px 안에 여유 있다. --%>
  table.d2-tb thead th { position:sticky; top:0; z-index:4; height:30px; background:#137a6c; color:#fff; font-weight:800; font-size:14px; letter-spacing:.02em; border-bottom:1px solid #0e6657; }
  table.d2-tb td.txt-l { text-align:left; }
  table.d2-tb td.num { text-align:right; font-variant-numeric:tabular-nums; }  /* [2026-08-20] 콘셉 : 세로로 자릿수가 맞아 눈으로 검산된다 */
  /* 출고장 셀(좌측 rowspan) — 데시보드1의 td.stick 속성(#f4f8f7 / teal / weight 600) + 클릭으로 접기/펼치기 */
  table.d2-tb td.zone { background:#f4f8f7; color:#178074; font-weight:600; text-align:left; vertical-align:top; position:sticky; left:0; z-index:2; cursor:pointer; }
  table.d2-tb td.zone:hover { background:#eef3f2; }
  table.d2-tb td.zone .zcaret { display:inline-block; width:12px; color:#1f9b8e; font-size:10px; }
  /* 납기일자 — 출고장명 아래 줄에 표시 (한 줄 표기 시 잘리는 문제 방지) */
  table.d2-tb td.zone .z-dlv { display:block; color:#c47f17; font-weight:700; font-size:11.5px; margin-left:14px; margin-top:2px; }
  /* 출고장명 옆 물류센터코드 — 괄호 표기(예: 광주물류센터 출고장 (E400)) */
  table.d2-tb td.zone .z-dc { color:#5b6b7a; font-weight:600; font-size:inherit; margin-left:4px; }
  /* 출고장 헤더 삭제 아이콘 — 기본 숨김, Ctrl+Del 로 토글(body.d2-del-on) */
  table.d2-tb td.zone .z-del { display:none; margin-left:8px; cursor:pointer; font-size:12px; opacity:.7; vertical-align:1px; }
  body.d2-del-on table.d2-tb td.zone .z-del { display:inline-block; }
  table.d2-tb td.zone .z-del:hover { opacity:1; transform:scale(1.15); }

  /* ── 차수(배치)별 수량 컬럼 — 메인 그리드(이력조회와 동일 표기) ── */
  table.d2-tb th.bcol { line-height:1.15; }
  table.d2-tb th.bcol .hb-dt { display:block; font-size:10px; color:#8fa6b6; font-weight:700; margin-top:2px; }
  table.d2-tb th.bcol .cur { display:inline-block; background:var(--teal-dk); color:#fff; border-radius:9px; padding:0 6px; font-size:9.5px; margin-left:3px; vertical-align:1px; }
  table.d2-tb td.hc { text-align:right; font-weight:800; }
  table.d2-tb td.hc-none { color:#c3ccd3; font-weight:600; }
  table.d2-tb td.hc-first { color:#1f2a37; }
  table.d2-tb td.hc-same { color:#37475a; }
  table.d2-tb td.hc-new  { color:#137a6c; background:#eafaf5; }
  table.d2-tb td.hc-new b { color:#0d5f54; }
  table.d2-tb td.hc-up   { color:#1663c7; background:#eef4fd; }
  table.d2-tb td.hc-dn   { color:#c0392b; background:#fdeeec; }
  table.d2-tb td.hc-del  { color:#9aa7b3; background:#f2f4f6; text-decoration:line-through; }
  /* 변동사항 그룹 헤더 — 2차전~N차전을 하나로 묶어 표시(세부 차수는 소계행에서 확인) */
  table.d2-tb th.bcol-chg { background:#20415a; color:#eaf1f6; font-size:14px; letter-spacing:2px; }  <%-- 12→14px — 머리글 글자 키움(2026-08-28)과 보조 맞춤 --%>
  /* 소계행: 각 출고장 '자기 차수' 라벨+시각+소계수량 (출고장마다 다른 차수를 자기 열에 표기) */
  table.d2-tb td.bcell-h { line-height:1.2; padding:2px 4px; background:#f4f8f7; text-align:right; }
  table.d2-tb td.bcell-h .bh-lab { display:block; font-size:10px; font-weight:800; color:#137a6c; }
  table.d2-tb td.bcell-h .bh-dt  { display:block; font-size:9px; font-weight:700; color:#8fa6b6; }
  table.d2-tb td.bcell-h .bh-sum { display:block; font-size:15px; font-weight:900; color:#1f2a37; }

  
  /* 전체 합계(맨 위) — 데시보드1 tr.ztot 속성.
     ★top:29px = 머리글(높이 30 고정, 위 thead th 주석)과 1px 겹침 — 배율 반올림 실틈으로
       자료 글자가 비치지 않게. 겹친 1px 은 z-index 4 인 머리글이 덮는다. */
  table.d2-tb tr.tot td { background:#11161d; color:#fff; font-weight:700; border-bottom:2px solid #0e1620;
                          height:34px;   /* 줄을 조금 크게 (2026-08-28 요청 「검은 전체출고장 합계폭 조금 확대」 — 표 셀에선 최소높이로 동작) */
                          position:sticky; top:29px; z-index:3; }   /* 헤더 바로 아래에 고정 — 스크롤해도 전체합계 유지 */
  /* 물류센터 대표그룹 행 — 데시보드1 tr.lgrp 속성 (▼ 그룹 헤더): 11.5px / weight 700 / teal */
  table.d2-tb tr.grp { cursor:pointer; }
  /* 대표출고장(물류센터) 그룹 헤더 — 크게 + 구분색(진한 청록 밴드/흰 글자) */
  table.d2-tb tr.grp td { background:#137a6c; color:#ffffff; font-weight:900; font-size:18px; text-align:left; letter-spacing:.3px; border-bottom:2px solid #0d5f54; }
  table.d2-tb tr.grp td.num { text-align:right; color:#d7f5ee; }
  table.d2-tb tr.grp td:first-child { background:#0e6657; position:sticky; left:0; z-index:2; box-shadow:inset 4px 0 0 #ffd166; }
  table.d2-tb tr.grp:hover td { background:#0e6657; }
  table.d2-tb tr.grp:hover td:first-child { background:#0a5249; }
  table.d2-tb tr.grp td .zcaret { display:inline-block; width:15px; color:#ffffff; font-size:12px; }
  /* 물류센터 합계 행 — 데시보드1 tr.lsub 속성 */
  table.d2-tb tr.gsub td { background:#eaf5f2; color:#137a6c; font-weight:700; text-align:left; }
  table.d2-tb tr.gsub td:first-child { background:#dcefe9; position:sticky; left:0; z-index:2; }
  table.d2-tb tr.gsub td.num { text-align:right; }
  /* 센터 소계(csub) — 오산센터 묶음 안 물류센터 단위 합계. ★색·글자 = 묶음 합계(gsub)와 동일(2026-08-30 요청) */
  table.d2-tb tr.csub td { background:#eaf5f2; color:#137a6c; font-weight:700; text-align:left; }
  table.d2-tb tr.csub td:first-child { background:#dcefe9; position:sticky; left:0; z-index:2; padding-left:16px; }
  table.d2-tb tr.csub td.num { text-align:right; }
  /* 출고장 소계(블록 상단) */
  table.d2-tb tr.sub td { background:#eef3f2; font-weight:700; color:#0e6657; }
  table.d2-tb tbody tr.item:nth-child(even) td { background:#fbfdfc; }
  table.d2-tb tbody tr.item td.zone, table.d2-tb tr.sub td.zone { background:#e9f5f2; }
  /* 사업장·품목명 — 데시보드1과 동일한 본문 글자체(weight 600) */
  table.d2-tb tr.item td.txt-l { font-weight:600; color:#1f2a37; }
  /* 이력(신규/삭제) 표시 */
  .hist-badge { display:inline-block; font-size:10.5px; font-weight:800; border-radius:9px; padding:0 7px; margin-left:4px; vertical-align:1px; }
  .hist-badge.new { background:#e3f4ef; color:#0e6657; border:1px solid #7fd0bf; }
  .hist-badge.del { background:#fdecec; color:#b3261e; border:1px solid #f0b4b0; }
  .hist-badge.chg { background:#fff4e0; color:#a85700; border:1px solid #f0d9a8; }
  .hist-badge.chg.up { background:#eaf6ec; color:#1a7a33; border-color:#a9dcb4; }
  .hist-badge.chg.dn { background:#fdf0e6; color:#b3600f; border-color:#f0c79a; }
  .hist-badge.keep { background:#eef1f3; color:#8090a0; border:1px solid #d6dde2; }
  .chg-dttm { font-size:10.5px; font-weight:600; color:#8a97a3; margin-left:5px; white-space:nowrap; }   /* 변경일시(UPLOAD_DTTM) */
  table.d2-tb td.dttm-cell { font-size:10px; color:#6b7a89; white-space:nowrap; letter-spacing:-.3px; padding-left:3px; padding-right:3px; }   /* 최초/변경일시 컬럼 — 좁게 */
  /* 배치 상태 배지 — 최초(파랑)/재생성(주황) */
  .batch-badge { display:inline-block; font-size:11px; font-weight:800; border-radius:9px; padding:1px 9px; margin-left:6px; vertical-align:1px; }
  .batch-badge.first { background:#e7f0fd; color:#1b5fc4; border:1px solid #a9c8f5; }
  .batch-badge.regen { background:#fff1e0; color:#b3600f; border:1px solid #f0c79a; }
  table.d2-tb tr.sub .batch-badge, table.d2-tb tr.sub .hist-badge { cursor:default; }   /* 소계 배지는 접기 커서 X */
  /* 그리드 행 선택 표시 */
  table.d2-tb tr.item.d2-sel td { background:#d8ebff !important; }
  table.d2-tb tr.item.d2-sel td:first-child { box-shadow: inset 3px 0 0 #2b7de9; }
  table.d2-tb tr.r-new td { background:#f2fbf8 !important; }
  table.d2-tb tr.r-new td.txt-l { color:#0e6657; }
  table.d2-tb tr.r-chg td { background:#fffdf6 !important; }
  /* 현재≠직전(수량 차이) 행 — 사업장·품목코드·품목명·현재·직전 칸만 노란색 강조
     (No·현재고·변동사항 제외)
     ★칸 번호가 한 칸씩 밀렸다 (2026-08-07 현재고 열이 No 뒤에 들어왔다) —
       1=No 2=현재고 3=사업장 4=품목코드 5=품목명 6=현재 7=직전.
     ★현재고는 일부러 뺀다 (2026-08-07 요청 "노란색에 겹쳐도 기존 색깔 유지") —
       노랑은 <출고 수량이 직전과 다르다> 는 뜻이라 재고와는 상관이 없고,
       덮어 칠하면 음수 빨강·양수 초록이 지워져 재고를 못 읽는다. */
  table.d2-tb tr.item.r-diff td:nth-child(3),
  table.d2-tb tr.item.r-diff td:nth-child(4),
  table.d2-tb tr.item.r-diff td:nth-child(5),
  table.d2-tb tr.item.r-diff td:nth-child(6),
  table.d2-tb tr.item.r-diff td:nth-child(7) { background:#ffe680 !important; color:#1f2a37 !important; }
  table.d2-tb tr.item.r-diff td:nth-child(6) b,
  table.d2-tb tr.item.r-diff td:nth-child(7) b { color:#8a5a00 !important; }
  table.d2-tb tr.r-del td { background:#fbf4f4 !important; color:#b06a66; text-decoration:line-through; text-decoration-color:#d99; }
  /* 삭제 줄이라도 재고는 지워진 게 아니다 — 취소선·회색을 걷어 원래 색을 지킨다(2026-08-07) */
  table.d2-tb tr.item.r-del td:nth-child(2) { text-decoration:none; color:inherit; }
  table.d2-tb tr.r-del td.num { color:#b06a66; }
  .d2-empty { padding:38px 20px; text-align:center; color:#6b7a89; font-size:13.5px; }
  .note { font-size:12px; color:#6b7a89; margin-top:8px; }
  /* 출고일자별 독립 블록 (기간·전체 조회 시) — 날짜 배너 + 표. 여러 표가 세로로 쌓임 */
  .d2-datehdr { position:sticky; top:0; z-index:5; display:flex; align-items:center; gap:10px; margin:14px 0 0; padding:7px 12px;
                background:linear-gradient(135deg,#11161d,#243447); color:#fff; font-size:15px; font-weight:900; border-radius:8px 8px 0 0; }
  .d2-datehdr:first-child { margin-top:0; }
  .d2-datehdr .d2-dsum { font-size:12px; font-weight:700; color:#aef0e7; margin-left:auto; }
  table.d2-tb.d2-tb-blk { margin-bottom:10px; }

  /* 출고장 변경 알림 — 화면 하단 고정 마퀴 바 (위너넷 알림바 스타일) */
  #d2Ticker { position:fixed; bottom:0; left:0; width:100%; height:36px; color:#fff; display:none; align-items:center;
    z-index:9999; overflow:hidden; font-size:13px; box-shadow:0 -2px 8px rgba(0,0,0,.15);
    background:linear-gradient(135deg,#1e3a5f 0%,#2c5282 100%); }
  body.d2-asqbar-on .d2-wrap { height:calc(100vh - 36px); }   /* 바가 뜨면 그만큼 본문 축소(가림 방지) */
  #d2Ticker .tk-lbl { flex-shrink:0; height:100%; display:flex; align-items:center; gap:6px; padding:0 14px;
    background:#e67e22; color:#fff; font-weight:700; font-size:13px; white-space:nowrap; }
  #d2Ticker .tk-lbl .bell { animation:d2bell 1.6s ease-in-out infinite; transform-origin:50% 0; display:inline-block; }
  @keyframes d2bell { 0%,70%,100%{ transform:rotate(0) } 78%{ transform:rotate(12deg) } 86%{ transform:rotate(-9deg) } 94%{ transform:rotate(4deg) } }
  #d2Ticker .tk-view { flex:1; height:100%; overflow:hidden; display:flex; align-items:center; }
  #d2Ticker .tk-track { display:flex; align-items:center; white-space:nowrap; animation:d2tkflow 40s linear infinite; }
  #d2Ticker .tk-track:hover { animation-play-state:paused; }   /* 마우스 올리면 멈춤 */
  #d2Ticker .tk-spacer { display:inline-block; flex-shrink:0; width:100vw; }   /* 우측 밖에서 시작 */
  @keyframes d2tkflow { 0%{ transform:translateX(0); } 100%{ transform:translateX(-100%); } }
  #d2Ticker .tk-item { display:inline-block; padding:0 6px; font-weight:700; }
  #d2Ticker .tk-item[data-zone] { cursor:pointer; }
  #d2Ticker .tk-item[data-zone]:hover { text-decoration:underline; text-underline-offset:2px; }
  #d2Ticker .tk-item .z { color:#ffd700; font-weight:800; }   /* 출고장명 = 금색 */
  #d2Ticker .tk-sep { color:#4a7ab5; margin:0 14px; }
  #d2Ticker .tk-new{ color:#68d391; } #d2Ticker .tk-up{ color:#9ae6b4; } #d2Ticker .tk-dn{ color:#fbd38d; } #d2Ticker .tk-del{ color:#feb2b2; }
  #d2Ticker .tk-toggle { flex-shrink:0; margin:0 8px; padding:3px 10px; border-radius:4px; cursor:pointer; font-size:11px;
    color:#fff; white-space:nowrap; background:rgba(255,255,255,.15); border:1px solid rgba(255,255,255,.3); transition:background .2s; }
  #d2Ticker .tk-toggle:hover { background:rgba(255,255,255,.25); }

  /* 토스트 */
  .d2-toast { position:fixed; left:50%; bottom:28px; transform:translateX(-50%); background:#1f2a37; color:#fff; border-radius:8px; padding:10px 18px; font-size:13px; z-index:9999; display:none; max-width:80vw; }
  /* 조회 중 안내 — 진입/조회 시 DB 응답이 올 때까지 화면을 덮는다 (빈 표가 잠깐 보이는 것 방지)
     z-index 는 토스트(9999)·삭제모달(9998) 아래 */
  /* ★조회 중 안내는 '알림'일 뿐 클릭을 막지 않는다(pointer-events:none) — 2026-07-29.
       종전에는 inset:0 로 화면 전체를 덮어 <상단 [📤 발주현황표 엑셀 보기/업로드]> 클릭이 통째로 먹혔다.
       조회가 끝날 때까지(응답이 안 오면 최대 20초) 버튼이 죽은 것처럼 보여 "두 번 눌러야 된다"는 증상이 났다. */
  .d2-loading { position:fixed; inset:0; background:rgba(255,255,255,.72); z-index:9997; display:none; align-items:center; justify-content:center; pointer-events:none; }
  .d2-loading.on { display:flex; }
  .d2-loading .box { display:flex; align-items:center; gap:12px; background:#fff; border:1px solid var(--bd); border-radius:12px; padding:16px 22px; box-shadow:0 10px 30px rgba(0,0,0,.14); font-size:14px; font-weight:800; color:#137a6c; }
  .d2-loading .sp { width:20px; height:20px; border:3px solid #d7ece7; border-top-color:#137a6c; border-radius:50%; animation:d2spin .8s linear infinite; flex:0 0 auto; }
  @keyframes d2spin { to { transform:rotate(360deg); } }
</style>
<%-- 노트북(1366×768·1440×900) 대응 — 2026-08-02 추가.
     viewport 는 이 화면이 tiles 를 안 거치는 .raw 페이지라 여기에 직접 둔다(셸 = 최상위 문서).
     CSS 는 이 한 줄만 빼면 종전 데스크탑 화면 그대로다. --%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
<%-- ★공통 UI 보정 (2026-08-21) — 단추 글자 두 줄 접힘 방지 + [글자 축소/확대] 단추 모양.
     화면 크기와 무관하게 늘 적용된다(위 konet-notebook.css 는 노트북 전용 @media 라 큰 화면에서는 안 걸린다). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
<%-- ★[2026-08-20] 화면 콘셉 공통 — 표 형식 입력 · 세로선 격자 · Pretendard.
     반드시 이 화면의 <style>·다른 CSS **뒤에** 걸어야 옛 규칙을 덮는다.
     이 두 줄만 빼면 이 화면만 예전 모습으로 돌아간다. 규칙 설명은 CSS 파일 머리말. --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/ui-concept.css?v=20260820">
</head>
<body>
<div class="d2-wrap">

  <!-- 상단 공통 (데시보드1과 동일 구성 — 버튼은 데시보드1로 전환하여 실행) -->
  <div class="d2-head">
    <div>
      <%-- [제외 2026-08-28 요청 「표시부분 제거」] 제목 옆 보기방식 배지(출고장별 보기 등) —
           d2SetView 의 d2ViewTag 갱신은 if(t) 가드라 요소가 없어도 조용히 지나간다. 재노출 시 주석 해제
      <h2>출고현황표 <span class="badge" id="d2ViewTag">출고장별 보기</span> --%>
      <h2>출고현황표
        <%-- 보기전환 콤보 — 대시보드(출고장별)에서는 감추고, 출고세부조회에서는 보인다(2026-07-25 요청).
             대시보드는 좌측 메뉴가 이미 그 보기를 정해줘 콤보가 자리만 차지했다. 반면 출고세부조회는
             출고장별품목 ↔ 사업장별 ↔ 품목별 을 오가는 화면이라 콤보가 있어야 한다.
             ★요소를 지우지는 않는다 — d2SetView 가 sel.value 를 읽고 쓰기 때문에 지우면 보기 전환이 깨진다.
             표시/숨김은 d2SetView 안에서 D2_VIEW 로 판단한다. --%>
        <span id="d2ViewSelBox" style="display:none; margin-left:12px;white-space:nowrap;gap:6px;vertical-align:middle">
          <select id="d2ViewSel" onchange="d2SetView(this.value)" title="보기 방식 선택 (출고장별 / 출고장별 품목 / 사업장별 / 품목별)"
                  style="height:34px;border:1px solid var(--bd);border-radius:8px;padding:0 30px 0 14px;font-size:13.5px;font-weight:800;cursor:pointer;color:#137a6c;background:#fff url(&quot;data:image/svg+xml;utf8,&lt;svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23137a6c' stroke-width='3'&gt;&lt;path d='M6 9l6 6 6-6'/&gt;&lt;/svg&gt;&quot;) no-repeat right 10px center;-webkit-appearance:none;-moz-appearance:none;appearance:none">
            <option value="zone">출고장별</option>
            <option value="zoneitem">출고장별 품목</option>
            <option value="biz">사업장별</option>
            <option value="item">품목별</option>
            <%-- 엑셀 [출고장 × 품목 (가로표)] 과 같은 화면 (2026-08-28 요청) --%>
            <option value="matrix">가로표 (출고장 × 품목)</option>
          </select>
        </span>
      </h2>
      <%-- [제외 2026-08-28 요청] 제목 밑 설명줄 — 화면을 위로 끌어올리려고 뺐다. 재노출 시 주석 해제
      <div class="sub">발주현황표(엑셀)를 업로드하면 <b>사업장·품목별 출고량</b> 과 <b>출고장별 수량</b> 이 자동 작성됩니다.</div>
      --%>
    </div>
    <%-- ★조회조건(출고일자·조회·당일/당월/전체)을 이 제목줄로 올렸다 (2026-08-28 요청 「표시 내용 출고현황표 옆으로」)
         — 종전에는 아래 .d2-topbar 안에 있었다. 제목 오른쪽 빈자리를 쓰고 화면을 그만큼 위로 끌어올린다.
         ★[조회조건 접기]를 눌러도 이 제목줄은 <남는다> (2026-08-28 「해당라인의 제외」) — 접히는 건 도구줄뿐.
           CSS 상단 접기 주석 참고. --%>
    <div class="tb-left">
      <span style="font-size:20px">📅</span>
      <label>출고일자</label>
      <%-- ★날짜를 고르는 것만으로는 조회하지 않는다 (2026-08-28 요청) — d2DateDirty 는 [조회]를 눌러 달라고 표시만 한다.
           종전에는 onchange="d2Load()" 라 날짜를 만질 때마다 DB 조회가 돌았다.
           ※[당일][당월][전체]는 그 자체가 실행 단추라 종전대로 바로 조회한다. --%>
      <input type="date" id="d2DateFrom" onchange="d2DateDirty()" onclick="d2OpenCal(this)" onfocus="d2OpenCal(this)" title="클릭하여 달력 선택 — 고른 뒤 [조회]를 누르세요">
      <span style="color:#9aa7b3">~</span>
      <input type="date" id="d2DateTo" onchange="d2DateDirty()" onclick="d2OpenCal(this)" onfocus="d2OpenCal(this)" title="클릭하여 달력 선택 — 고른 뒤 [조회]를 누르세요">
      <button class="btn-teal" id="d2BtnSearch" onclick="d2Load()" title="선택한 출고일자의 데이터를 DB에서 다시 조회합니다">🔍 조회</button>
      <span id="d2NeedMsg">← 날짜가 바뀌었습니다. [조회]를 누르세요</span>
      <button class="btn-line" id="d2BtnToday" onclick="d2Today()">당일</button>
      <button class="btn-line" id="d2BtnMonth" onclick="d2Month()">당월</button>
      <button class="btn-line" id="d2BtnAll" onclick="d2All()" title="출고일자와 상관없이 DB 전체 자료를 출고일자별 블록으로 표시">전체</button>
    </div>
    <%-- 요약숫자(KPI)도 이 제목줄로 올렸다 (2026-08-28 요청 「표시부분을 위로 이동」) —
         조회조건 다음, 액션단추 앞. 아래 줄에는 안내(#d2Info)만 남고 할 말이 없으면 줄째로 감춰진다. --%>
    <%-- 라벨(.st-l)은 CSS 로 감춰 둔다(2026-08-28 요청) — 무슨 숫자인지는 title 로 뜬다. --%>
    <div class="tb-stats">
      <div class="st" title="조회한 기간의 출고품목 수"><span class="st-l"><span id="d2KpiPrefix">당일</span> 출고품목</span><span class="st-v" id="d2KpiItem">0</span></div>
      <div class="st" title="출고수량 합계 (BOX)"><span class="st-l">출고수량(BOX)</span><span class="st-v" id="d2KpiQty">0</span></div>
      <div class="st" title="출고장 수"><span class="st-l">출고장 수</span><span class="st-v" id="d2KpiZone">0</span></div>
      <div class="st" title="사업장 수"><span class="st-l">사업장</span><span class="st-v" id="d2KpiBiz">0</span></div>
    </div>
    <div class="actions">
      <%-- 2026-07-26 사용자: 누르자마자 탐색기(파일 선택창)가 뜨지 않게 — 지정 폴더의 자료를 최신순으로 보여주는
           미리보기 모달을 먼저 연다. 탐색기가 필요하면 모달 안 [📄 파일 선택]. --%>
      <%-- 표시는 「발주현황표 업로드」 (2026-08-28 요청 — 종전 「발주현황표 엑셀 보기 / 업로드」에서 줄임.
           동작은 그대로 = 보기 모달 먼저) --%>
      <button class="btn-teal" onclick="d2Go('upload')" title="지정한 자료 폴더의 발주현황표를 최신순으로 보여줍니다 (탐색기는 모달 안 [📄 파일 선택])">📤 발주현황표 업로드</button>
      <%-- [삭제 2026-07-05] 매출금액/매입금액 업로드·출고데이타저장 버튼 제거 (마감관리 메뉴로 일원화) --%>
      <select id="d2PrintFmt" title="출력 형식 선택 (출고장별 / 품목별)" style="height:35px;border:1px solid var(--bd);border-radius:6px;padding:0 8px;font-size:13px;font-weight:700;cursor:pointer;color:#37475a;background:#fff">
        <option value="zone">출고장별</option>
        <option value="zoneitem">출고장별 품목</option>
        <option value="item">품목별</option>
        <option value="biz">사업장별 품목</option>
        <%-- 가로표 : 행=출고장(물류센터 묶음), 열=품목(사업장별 병합 머리줄). 한 장에 쭉 펴고,
             아무 데도 안 나가는 품목 열·아무것도 안 나가는 출고장 행은 빼서 가로를 줄인다.
             오른쪽 합계·품목수 / 아래 합계·출고장수 로 횡·종 대사가 가능하다. --%>
        <option value="matrix">출고장 × 품목 (가로표)</option>
      </select>
      <button class="btn-line" onclick="d2Download('daily')" title="선택한 형식(출고장별/품목별)으로 출고일자별 출력">🏷️ 일자별 출력</button>
      <button class="btn-line" onclick="d2Download('sum')" title="선택한 형식(출고장별/품목별)으로 기간 합계 출력">🧮 합계 출력</button>
    </div>
  </div>

  <!-- 조회바 + KPI (데시보드1 유지) -->
  <%-- 안내 전용 줄 — 조회조건·요약숫자가 제목줄로 올라가(2026-08-28) 여기엔 #d2Info 만 남았다.
       할 말(데이터 없음·대표출고장·찾기)이 없으면 d2Render 가 줄째로 감춘다. 그래서 처음엔 숨겨 둔다. --%>
  <div class="d2-topbar" style="display:none">
    <span id="d2Info" class="d2-info"></span>
  </div>

  <!-- 출고장 + 내용 한 그리드 (맨 위 전체 합계, 출고장별 소계 상단) -->
  <div class="card" id="d2Card">
    <!-- 툴바 (데시보드1 공통 — 합계맨앞 없음) -->
    <div class="d2-toolbar">
      <div class="tl">
        <%-- 보기 탭 (2026-08-28 요청 「기존 것 유지하면서 탭으로 두 개 선택」) —
             대시보드에서는 위 보기 콤보가 숨겨져 있어 가로표로 갈 길이 없었다. 여기 탭으로 오간다. --%>
        <span class="d2-vtab">
          <button type="button" class="vt on" id="d2VtList" onclick="d2SetView('zone')" title="지금까지 쓰던 목록 화면">목록</button>
          <button type="button" class="vt" id="d2VtMx" onclick="d2SetView('matrix')" title="엑셀 [출고장 × 품목] 과 같은 가로표">가로표</button>
        </span>
        <label>🔎 사업장 찾기</label>
        <input id="d2BizFind" type="text" list="d2BizFindList" placeholder="사업장명 입력"
               oninput="d2BizFindSet(this.value)" onkeydown="if(event.keyCode===13){d2BizFindSet(this.value);}">
        <datalist id="d2BizFindList"></datalist>
        <label>📦 품목 찾기</label>
        <input id="d2ItemFind" type="text" placeholder="품목명/품목코드/사업장" autocomplete="off" title="사업장명·품목명·품목코드 전체에서 부분일치(LIKE)로 찾습니다. 공백으로 여러 단어 입력 시 모두 포함된 행만 표시"
               oninput="d2ItemFindSet(this.value)" onkeydown="if(event.keyCode===13){d2ItemFindSet(this.value);}">
        <button class="btn-line" onclick="d2FindClear()" title="사업장/품목 찾기 해제(전체 보기)">전체</button>
        <span class="sep">
          <button class="btn-line" onclick="d2ZoomOut()" title="축소">🔍－</button>
          <span class="zoomlbl" id="d2ZoomLbl">100%</span>
          <button class="btn-line" onclick="d2ZoomIn()" title="확대">🔍＋</button>
          <button class="btn-line" id="d2BtnFull" onclick="d2FullExpand()" title="출고현황표를 화면 전체로 덮기">⛶ 전체화면</button>
          <button class="btn-line" id="d2BtnBasic" onclick="d2FullExit()" title="기본 화면 + 원래 크기로">⟲ 기본화면</button>
        </span>
      </div>
      <!-- 대표출고장(물류센터) 다중선택 콤보 — 드롭다운에서 하나 이상 체크 조회 -->
      <div class="tm" id="d2DcWrap">
        <button class="btn-line" id="d2DcBtn" onclick="d2DcOpen(event)" title="대표출고장(물류센터)을 하나 이상 선택하여 조회합니다"><span>🏬 대표출고장:</span><span class="arr"><b id="d2DcLbl" style="color:#178074">전체</b> ▾</span></button>
        <div class="dc-pop" id="d2DcPop"></div>
      </div>
      <div class="tr">
        <button class="btn-line" id="d2BtnZoneToggle" onclick="d2ToggleAllZones()">－ 출고장 접기</button>
        <%-- 가로표 전용 : 세로줄(사업장) 접기. 목록에서는 숨는다(d2VtSync) --%>
        <button class="btn-line" id="d2BtnBizFold" style="display:none" onclick="d2MxFoldAll()"
                title="가로표에서 사업장 열을 숨깁니다 / 다시 폅니다 (사업장 머리칸을 눌러 하나씩도 됩니다)">－ 사업장 접기</button>
        <span style="position:relative" id="d2GordWrap">
          <button class="btn-line" onclick="d2GordOpen(event)" title="출고장 그룹(물류센터) 표시 순서를 지정합니다. 브라우저에 저장되어 수정하지 않는 한 유지됩니다">⚙ 그룹순서</button>
          <div class="dc-pop" id="d2GordPop" style="left:auto; right:0; min-width:260px"></div>
        </span>
        <button class="btn-line" onclick="d2ColReset()" title="드래그로 바꾼 컬럼 너비를 기본값으로 되돌립니다 (헤더 경계 더블클릭도 동일)">↺ 열초기화</button>
        <%-- [제외 2026-07-02] 품목 추가/출고장 추가/출고장 초기화 — 편집 기능은 데시보드1에서만. 재노출 시 주석 해제
        <button class="btn-teal" onclick="d2Go('additem')" title="데시보드1로 이동하여 품목을 추가합니다">＋ 품목 추가</button>
        <button class="btn-line" onclick="d2Go('addzone')" title="데시보드1로 이동하여 출고장을 추가합니다">＋ 출고장 추가</button>
        <button class="btn-line" style="color:#c0392b; border-color:#e3b4ae" onclick="d2Go('clear')" title="데시보드1로 이동하여 출고장 데이터를 초기화합니다">🔄 출고장 초기화</button>
        --%>
        <label style="margin-left:6px">사업장 보기</label>
        <select id="d2BizSel" onchange="d2Render()"></select>
        <%-- [제외 2026-07-02] 이력(신규/삭제) 체크박스 — 기본 켜짐 유지 + UI 숨김(항상 이력 비교 동작). 재노출 시 display:none 제거 --%>
        <label style="display:none; margin-left:6px; cursor:pointer; color:#137a6c" title="직전 업로드와 비교해 이번에 새로 들어온 품목(신규)·빠진 품목(삭제)을 표시합니다"><input type="checkbox" id="d2HistChk" onchange="d2Render()" checked style="vertical-align:-2px"> 🕘 이력(신규/삭제)</label>
      </div>
    </div>
    <div class="d2-scroll">
      <table class="d2-tb" id="d2Tbl"></table>
    </div>
    <%-- [제외 2026-07-02] 하단 안내문 — 재노출 시 주석 해제
    <div class="note">※ 좌측 <b>출고장</b> 칸(또는 소계 행)을 클릭하면 해당 출고장을 접거나 펼칩니다. 맨 위 행은 <b>전체 출고장 합계</b>, 각 출고장 첫 행은 해당 출고장 <b>소계</b>입니다.</div>
    --%>
  </div>

</div>
<div class="d2-toast" id="d2Toast"></div>

<%-- 조회 중 안내 — 처음 진입 시 DB 조회(사업장분류→출고→직전배치→차수이력)가 끝날 때까지 표시.
     화면이 그려지기 전부터 보여야 하므로 'on' 상태로 시작하고 d2Render() 에서 해제한다. --%>
<div class="d2-loading on" id="d2Loading">
  <div class="box"><span class="sp"></span><span id="d2LoadingMsg">출고현황 자료를 불러오는 중입니다…</span></div>
</div>

<!-- 사업장 출고 삭제 모달 (소프트 삭제 · 이력 보존) -->
<div id="d2DelOverlay" style="display:none; position:fixed; inset:0; background:rgba(15,23,32,.5); z-index:9998; align-items:flex-start; justify-content:center;">
  <div style="background:#fff; width:min(460px,92vw); margin-top:11vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3);">
    <div style="background:linear-gradient(135deg,#c0392b,#a5281c); color:#fff; padding:12px 18px; border-radius:12px 12px 0 0; display:flex; justify-content:space-between; align-items:center;">
      <b style="font-size:15px">🗑️ 출고장 출고 삭제</b>
      <button onclick="d2DelClose()" style="background:none;border:none;color:#fff;font-size:22px;line-height:1;cursor:pointer">&times;</button>
    </div>
    <div style="padding:16px 18px;">
      <div style="font-size:12.5px;color:#6b7a89;margin-bottom:14px;line-height:1.5">선택한 <b>출고일자</b>의 <b>출고장</b> 출고분(활성)을 삭제합니다.</div>
      <div style="margin-bottom:12px"><label style="display:block;font-size:12px;font-weight:700;color:#37475a;margin-bottom:4px">출고일자</label>
        <select id="d2DelDate" onchange="d2DelFillZones(); d2DelDo();" style="width:100%;height:36px;border:1px solid var(--bd);border-radius:6px;padding:0 8px;font-weight:700;font-size:13px"></select></div>
      <div><label style="display:block;font-size:12px;font-weight:700;color:#37475a;margin-bottom:4px">출고장</label>
        <select id="d2DelZone" onchange="d2DelDo()" style="width:100%;height:36px;border:1px solid var(--bd);border-radius:6px;padding:0 8px;font-weight:700;font-size:13px"></select></div>
      <!-- 삭제 확인 메시지 (인라인) -->
      <div id="d2DelConfirmBox" style="display:none;margin-top:14px;padding:11px 13px;background:#fdecec;border:1px solid #f0b4b0;border-radius:8px">
        <div id="d2DelConfirmMsg" style="font-size:13px;font-weight:800;color:#a5281c;line-height:1.5;margin-bottom:10px"></div>
        <div style="display:flex;justify-content:flex-end;gap:8px">
          <button class="btn-line" onclick="d2DelClose()">아니오</button>
          <button class="btn-line" style="background:#c0392b;color:#fff;border-color:#c0392b;font-weight:800" onclick="d2DelExec()">예, 삭제합니다</button>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- 출고장 변경 알림 — 화면 하단 고정 마퀴 바 (위너넷 알림바 스타일) -->
<div id="d2Ticker">
  <div class="tk-lbl"><span class="bell">🔔</span> 알림</div>
  <div class="tk-view"><div class="tk-track" id="d2TickerTrack"></div></div>
  <button class="tk-toggle" id="d2TickerToggle" onclick="d2TickerToggle()" title="알림 멈춤/재생">끄기</button>
</div>


<script type="text/javascript">
  var CTX='${pageContext.request.contextPath}';
  var D2_DATA=[];            // {code,item,biz,bizCode,dc,zone,qty,dlvDt,date}
  var D2_PREV=[];            // 직전 배치(이력 비교용) — 같은 매핑
  var D2_HISTALL=[];         // 전 배치(모든 출고장) — 차수별 수량 매트릭스용(활성+이력)
  var D2_BIZI={};            // TBL_BIZI_MST {사업장코드:대표사업장명} — 사업장 유니크 카운트용(데시보드1 ssBiziMap 동일)
  /* 사업장 공통 매칭 {사업장코드:매칭명칭} — 거래처관리에서 지정한다(2026-08-28).
     ★쓰는 곳은 <가로표 화면 + 가로표 엑셀> 뿐이다. 목록 보기·KPI·다른 출력은 그대로 둔다.
     ★매칭이 없는 사업장은 원래 사업장 이름을 그대로 쓴다(사용자 확정). */
  var D2_BIZMT={};
  function d2MtNm(r){
    var c=(''+((r&&r.bizCode)||'')).trim();
    return (c && D2_BIZMT[c]) || (r&&r.biz) || '(사업장없음)';
  }
  var D2_SRC='', D2_UP=false;
  var D2_COLL={};            // 접힌 출고장 { zone:1 }
  var D2_GCOLL={};           // 접힌 물류센터 그룹 { dc:1 }
  var D2_ZOOM=100;
  var D2_VIEW='zone';        // 보기 모드: 'zone'(출고장별) | 'biz'(사업장별) | 'item'(품목별)
  var D2_UNIT='출고장';       // 좌측 단위 라벨 (zone=출고장 / biz 재사용 시 사업장)
  var D2_FIND='';            // 사업장 찾기(부분일치)
  var D2_IFIND='';           // 품목 찾기(품목명/품목코드 부분일치)
  var D2_DCSEL={};           // 선택된 대표출고장(물류센터) { dc:1 } — 비어있으면 전체
  // 출고장 그룹(물류센터) 표시 순서 — 데시보드1과 공유(localStorage 'logiGroupOrder', 물류센터명 배열).
  // 한쪽에서 정한 순서가 다른 쪽에도 동일 적용. 미지정 그룹은 ㄱㄴㄷ순 뒤에 붙음
  var D2_GORD=[];
  function d2GordLoad(){ try{ D2_GORD=JSON.parse(localStorage.getItem('logiGroupOrder')||'[]')||[]; }catch(e){ D2_GORD=[]; } return D2_GORD; }
  function d2GordSave(){ try{ localStorage.setItem('logiGroupOrder', JSON.stringify(D2_GORD)); }catch(e){} }
  d2GordLoad();

  // 컬럼 정의(전역) — 기본폭은 화면폭 비율(frac 합계 1)로 계산해 우측까지 꽉 채움.
  // 드래그는 엑셀처럼 그 열만 px로 조절(옆 열 안 건드림). 넘치면 가로 스크롤, 값은 px로 저장
  // 고정(기준) 컬럼 — 품목코드를 품목명 앞으로. 최초일시·변경일시 제거. 오른쪽엔 차수(배치)별 수량 컬럼이 동적으로 붙음
  var D2_BASECOLS=[
    /* [원복 2026-08-28] 「전체 출고장 폭 조금넓게」를 열 폭으로 잘못 읽어 0.16 으로 키웠다가
       「무엇을했는지 그것은 원복」 지시로 0.14 복귀 — 실제 요청은 검은 <전체 출고장 합계 줄> 높이(tr.tot). */
    {k:'zone', nm:'출고장', f:0.14},
    {k:'no',   nm:'No',    f:0.035},
    /* 현재고 (2026-08-07 요청 "No 뒤에") — 근거는 재고현황(①)과 같다: 수불원장 입고−출고.
       여기서 바로 보이면 "이만큼 나가는데 재고는 있나" 를 화면을 옮기지 않고 안다. */
        {k:'stock',nm:'현재고', f:0.038},
    {k:'biz',  nm:'사업장', f:0.16},
    {k:'code', nm:'품목코드', f:0.075},
    {k:'item', nm:'품목명', f:0.33}
  ];
  var D2_COLS=D2_BASECOLS.slice();   // d2Render에서 매 렌더 시 [기준 + 차수컬럼]으로 재구성
  var D2_COLW={};   // {k: fraction(0~1)} — 사용자 조절값(localStorage). 합계 1 유지 → 항상 우측까지 채움
  try{ D2_COLW=JSON.parse(localStorage.getItem('d2ColWidths8')||'{}')||{}; }catch(e){ D2_COLW={}; }
  // 이전 버전(px 저장) 잔여값 정리 — 비율(0~1) 범위를 벗어난 값이 있으면 전체 초기화
  (function(){ for(var k in D2_COLW){ var v=D2_COLW[k]; if(!(v>0 && v<=1)){ D2_COLW={}; try{ localStorage.removeItem('d2ColWidths8'); }catch(e){} break; } } })();
  function d2ColSave(){ try{ localStorage.setItem('d2ColWidths8', JSON.stringify(D2_COLW)); }catch(e){} }
  function d2ColFrac(k){ if(D2_COLW[k]>0 && D2_COLW[k]<=1) return D2_COLW[k]; for(var i=0;i<D2_COLS.length;i++) if(D2_COLS[i].k===k) return D2_COLS[i].f; return 0.15; }
  (function(){   // 헤더 경계 드래그 — 왼쪽 열↔오른쪽(다음) 열이 폭을 주고받음(총폭 고정, 우측 여백/스크롤 없음)
    var dragging=false, startX=0, tblW=1, ck=null, nk=null, sFi=0, sFn=0, MIN=0.005;
    document.addEventListener('mousedown', function(e){
      var h=e.target && e.target.closest ? e.target.closest('.col-rz') : null; if(!h) return;
      e.preventDefault();
      ck=h.getAttribute('data-ck');
      var ci=-1; for(var i=0;i<D2_COLS.length;i++) if(D2_COLS[i].k===ck){ ci=i; break; }
      if(ci<0 || ci>=D2_COLS.length-1) return;      // 마지막 열은 경계 없음
      nk=D2_COLS[ci+1].k;
      var tbl=document.getElementById('d2Tbl'); tblW=(tbl?tbl.offsetWidth:1)||1;
      sFi=d2ColFrac(ck); sFn=d2ColFrac(nk); startX=e.clientX; dragging=true;
      document.body.style.userSelect='none'; document.body.style.cursor='col-resize';
    });
    document.addEventListener('mousemove', function(e){
      if(!dragging) return;
      var dF=(e.clientX-startX)/tblW;             // 이동량을 비율로
      var total=sFi+sFn;
      var fi=Math.min(total-MIN, Math.max(MIN, sFi+dF));
      var fn=total-fi;
      var ci=document.getElementById('d2col_'+ck), cn=document.getElementById('d2col_'+nk);
      if(ci) ci.style.width=(fi*100)+'%'; if(cn) cn.style.width=(fn*100)+'%';
      D2_COLW[ck]=fi; D2_COLW[nk]=fn;
    });
    document.addEventListener('mouseup', function(){
      if(!dragging) return; dragging=false;
      document.body.style.userSelect=''; document.body.style.cursor='';
      d2ColSave(); ck=null; nk=null;
    });
    document.addEventListener('dblclick', function(e){   // 더블클릭 = 전체 컬럼폭 기본값 복원
      var h=e.target && e.target.closest ? e.target.closest('.col-rz') : null; if(!h) return;
      d2ColReset();
    });
  })();
  // 컬럼 폭 초기화(기본 비율로 복원) — 헤더 더블클릭 또는 버튼에서 호출
  function d2ColReset(){ D2_COLW={}; try{ localStorage.removeItem('d2ColWidths8'); }catch(e){} d2Render(); d2Toast('↺ 컬럼 너비를 기본값으로 초기화했습니다'); }

  function d2Pad(n){ return (n<10?'0':'')+n; }
  var D2_TODAY=(function(){ var d=new Date(); return d.getFullYear()+'-'+d2Pad(d.getMonth()+1)+'-'+d2Pad(d.getDate()); })();
  /* ── 현재고 (2026-08-07 요청) ─────────────────────────────
       근거를 재고현황(②번째 화면)과 <같은 것>으로 둔다 — 같은 서버 조회를 그대로 부른다.
       여기서 따로 계산하면 두 화면이 어긋나고, 어느 쪽이 맞는지 아무도 모르게 된다.
     · 원장(TBL_STOCK_LEDGER) 기준이라 <출고반영된 분>까지 빠져 있는 값이다.
       아직 재집계하지 않은 업로드분은 안 빠져 있다 — 그때는 재고현황의 [출고반영 재집계] 한 번.
     · 목록을 기다리게 하지 않는다. 도착하면 표만 다시 그린다(안 왔으면 칸은 비어 있다). */
  var D2_STOCK=null, D2_MAINCD=null, _d2StkBusy=false;
  function d2StockLoad(cb){
    if(D2_STOCK || _d2StkBusy) { if(cb&&D2_STOCK) cb(); return; }
    _d2StkBusy=true;
    var left=3, m={}, mc={};
    function done(){ if(--left) return; D2_STOCK=m; D2_MAINCD=mc; _d2StkBusy=false; if(cb) cb(); }
    /* ★재고현황(stockStatusList)이 아니라 <가벼운 전용 조회>를 부른다 (2026-08-07 속도개선).
         근거(수불원장 입고−출고)는 똑같고, 화면에 안 쓰는 extQtys 만 안 만든다.
         실측 664ms → 29ms. 값이 어긋날 일은 없다 — 같은 원장을 같은 규칙으로 더한다. */
    fetch(CTX+'/prod/stockQtyMap.do', { method:'POST', credentials:'same-origin',
            headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
      .then(function(r){ return r.json(); })
      .then(function(j){ ((j&&j.data)||[]).forEach(function(o){
              var c=(''+(o.prodCd||'')).trim();
              if(c) m[c]={ q:(+o.curQty||0), i:(+o.inQty||0) }; }); done(); })
      .catch(done);
    /* 매칭코드 → 주코드. 재고는 주코드로만 쌓이므로(원장 PROD_CD) 이 표가 없으면
       매칭코드 줄은 영영 빈칸이다. '매칭'과 '연결' 둘 다 같은 구실을 하므로 함께 읽는다. */
    ['/prod/extItemList.do','/prod/xrefList.do'].forEach(function(u){
      fetch(CTX+u, { method:'POST', credentials:'same-origin',
              headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
        .then(function(r){ return r.json(); })
        .then(function(j){ ((j&&j.data)||[]).forEach(function(o){
                var e=(''+(o.extItemCd||'')).trim(), p=(''+(o.prodCd||'')).trim();
                if(e && p && !mc[e]) mc[e]=p; }); done(); })
        .catch(done);
    });
  }
  /* 현재고 칸.
     · 그 코드로 재고가 잡혀 있으면 그대로.
     · 매칭코드면 재고가 <주코드>에 있다 — 그 값을 대신 보여주고 어디 재고인지 밝힌다
       (2026-08-07 "그런 찾아서 -82를 해야할것같은데"). 같은 주코드를 쓰는 줄이 여럿이면
       같은 숫자가 되풀이되는데, 실제로 같은 재고를 나눠 쓰는 것이므로 그게 맞다.
     · 어느 쪽도 아니면 '·' — 0으로 쓰면 '재고 없음' 으로 잘못 읽힌다. */
  /* fld : 'q'=현재고, 'i'=입고. 입고도 재고와 <똑같이> 주코드를 타고 찾는다
     (2026-08-07 "입고수량도 같이 같은 매칭") — 매입은 언제나 주코드로 들어오므로
     매칭코드 줄에서 입고를 보려면 주코드 쪽을 볼 수밖에 없다. */
  /* 숫자만 필요할 때(엑셀 출력) — 화면 칸(d2StockCell)과 <같은 규칙>으로 값을 고른다.
     매칭코드면 주코드 재고를 대신 본다. 어느 쪽도 없으면 null(빈칸). */
  function d2StockQty(code){
    var c=(''+(code||'')).trim();
    if(!D2_STOCK || !c) return null;
    var o=D2_STOCK[c];
    if(o==null && D2_MAINCD && D2_MAINCD[c]) o=D2_STOCK[D2_MAINCD[c]];
    return (o==null) ? null : (+o.q||0);
  }
  function d2StockCell(code, fld){
    fld = fld || 'q';
    var c=(''+(code||'')).trim();
    if(!D2_STOCK || !c) return '<td class="num" style="color:#c3ccd4">·</td>';
    var o=D2_STOCK[c], main='';
    if(o==null && D2_MAINCD && D2_MAINCD[c]){ main=D2_MAINCD[c]; o=D2_STOCK[main]; }
    if(o==null) return '<td class="num" style="color:#c3ccd4" title="이 코드로도, 주코드로도 재고가 잡혀 있지 않습니다.">·</td>';
    var v=(+o[fld]||0), isQ=(fld==='q');
    var what = isQ ? '재고' : '입고';
    var tip = main ? ('이 코드는 매칭코드입니다. '+what+'는 주코드 '+main+' 에 잡혀 있어 그 값을 보여줍니다.')
                   : '재고현황과 같은 근거(수불원장)입니다.';
    var col = isQ ? (v<0?'#c0392b':'#137a6c') : '#137a6c';
    return '<td class="num" style="font-weight:700;color:'+col+'" title="'+d2Esc(tip)+'">'
         + (v===0 && !isQ ? '<span style="color:#c3ccd4;font-weight:400">0</span>' : d2Num(v))
         + (main ? ' <span style="font-size:10px;font-weight:400;color:#8a97a3">주</span>' : '')
         + '</td>';
  }
  function d2Num(n){ return (Math.round(n||0)).toLocaleString(); }
  function d2Num0(n){ return (Math.round(n||0)===0) ? '' : d2Num(n); }   // 0은 빈칸 표시
  function d2Esc(s){ return (''+(s==null?'':s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function d2Set(id,html){ var e=document.getElementById(id); if(e) e.innerHTML=html; }
  function d2OpenCal(el){ try{ if(el && el.showPicker) el.showPicker(); }catch(e){} }
  function d2Toast(html){
    var t=document.getElementById('d2Toast'); if(!t) return;
    t.innerHTML=html; t.style.display='block';
    clearTimeout(t._tm); t._tm=setTimeout(function(){ t.style.display='none'; }, 3200);
  }
  /* 조회 중 안내 — d2Load() 시작에 켜고 d2Render() 에서 끈다.
     모든 조회 경로(단일일자·기간·오류)가 마지막에 d2Render() 로 수렴하므로 해제 지점은 한 곳이면 된다.
     응답이 끝내 오지 않는 경우 대비 20초 자동 해제 */
  var _d2LoadingTmr=null;
  function d2LoadingOn(msg){
    var o=document.getElementById('d2Loading'); if(!o) return;
    if(msg) d2Set('d2LoadingMsg', msg);
    o.classList.add('on');
    clearTimeout(_d2LoadingTmr);
    _d2LoadingTmr=setTimeout(d2LoadingOff, 20000);
  }
  function d2LoadingOff(){
    var o=document.getElementById('d2Loading'); if(o) o.classList.remove('on');
    clearTimeout(_d2LoadingTmr); _d2LoadingTmr=null;
  }


  // ── 상단/툴바 액션버튼: 데시보드1 기능을 화면 전환 없이 그 자리에서 실행 (동일 출처 iframe)
  //    · 미리보기 모달(ssPvOverlay 등)은 숨겨진 데시보드1 패널 안에 있어 부모 body 로 옮겨서 표시(fixed 오버레이라 화면은 데시보드2 유지)
  //    · 실행 전 데시보드1의 출고일자를 데시보드2 선택일자와 동기화(단일 일자일 때)
  function d2Go(act){
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.logiGo) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    function lift(id){ try{ var el=p.document.getElementById(id); if(el && el.parentNode!==p.document.body) p.document.body.appendChild(el); }catch(e){} }
    /* ★업로드 모달은 아래 '날짜 동기화(재조회)'보다 먼저 연다 — 2026-07-29.
         재조회가 걸리면 그 사이 조회중 안내가 뜨고 모달이 늦게 떠서 "안 눌렸다"로 보였다.
         모달은 조회 결과와 무관(엑셀 미리보기)하므로 먼저 열어도 안전하다. */
    if(act==='upload'){
      lift('ssPvOverlay');
      if(p.ssPvOpen) p.ssPvOpen(true);
      else { var e0=p.document.getElementById('ssFile'); if(e0) e0.click(); }   // 구버전 폴백
    }
    try{
      var f=(document.getElementById('d2DateFrom')||{}).value||'';
      var t=(document.getElementById('d2DateTo')||{}).value||'';
      if(f && f===t){
        var df=p.document.getElementById('ssDateFrom'), dt=p.document.getElementById('ssDateTo');
        if(df && dt && (df.value!==f || dt.value!==f)){ df.value=f; dt.value=f; if(p.ssLoadShipoutFromDB) p.ssLoadShipoutFromDB(); }
      }
    }catch(e){}
    try{
      // 업로드(act==='upload')는 위에서 이미 처리했다 — 탐색기부터 열지 않고 미리보기 모달을 연다(2026-07-26 사용자).
      //   ssPvOpen(true) → ssHistRefresh → 지정 폴더 스캔(최신순) → 최신 파일 자동 표시.
      if(act==='sales'){ lift('ssSalesPvOverlay'); var e2=p.document.getElementById('ssSalesFile'); if(e2) e2.click(); }
      else if(act==='cost'){ lift('ssCostPvOverlay'); var e3=p.document.getElementById('ssCostFile'); if(e3) e3.click(); }
      else if(act==='save' && p.ssSaveData) p.ssSaveData();
      else if(act==='zoneprint') d2DownloadByZone();
      else if(act==='additem' && p.ssAddItem) p.ssAddItem();
      else if(act==='addzone' && p.ssAddZone) p.ssAddZone();
      else if(act==='clear' && p.ssClearAll) p.ssClearAll();
    }catch(e){}
  }
  // 출력 디스패처 — 형식 선택(출고장별/품목별) × 모드(일자별/합계)
  function d2Download(mode){
    var fmt=(document.getElementById('d2PrintFmt')||{}).value||'zone';
    if(fmt==='item') d2DownloadByItem(mode);
    else if(fmt==='biz') d2DownloadByBiz(mode);
    else if(fmt==='zoneitem') d2DownloadByZoneItem(mode);
    else if(fmt==='matrix') d2DownloadByMatrix(mode);   // 출고장(행) × 품목(열) 가로표 — 2026-08-28
    else d2DownloadByZone(mode);
  }

  // ── 출고장 출고 삭제 (소프트 삭제 · 이력 보존) — 출고일자+출고장(DC_CD+INWH) 선택 후 활성분 ACTION_YN='D'
  function d2DelOpen(){
    if(!D2_DATA || !D2_DATA.length){ d2Toast('⚠️ 먼저 조회하세요. (삭제할 데이터가 없습니다)'); return; }
    var dates={}; D2_DATA.forEach(function(r){ if(r.date) dates[r.date]=1; });
    var dsel=document.getElementById('d2DelDate');
    var ds=Object.keys(dates).sort().reverse();
    dsel.innerHTML=ds.map(function(d){ return '<option value="'+d2Esc(d)+'">'+d2Esc(d)+'</option>'; }).join('');
    var f=(document.getElementById('d2DateFrom')||{}).value||''; if(f && ds.indexOf(f)>=0) dsel.value=f;
    d2DelFillZones();
    document.getElementById('d2DelOverlay').style.display='flex';
  }
  // 선택 출고일자에 존재하는 출고장만 채움 (dcCd+inwh 보관)
  function d2DelFillZones(){
    d2DelCancelConfirm();   // 선택 바뀌면 확인 메시지 닫기
    var dt=(document.getElementById('d2DelDate')||{}).value||'';
    var zmap={};
    /* ⚠직송 낱알(… 직송)은 목록에서 버린다(2026-08-30) — 서버 삭제키가 (dcCd+inwh)라 직송 행만 골라 지울 수 없고,
       inwh 가 겹치는 배송 입고장을 지우면 그 입고장의 직송 행도 함께 내려간다(종전과 같은 동작). */
    D2_DATA.forEach(function(r){ if((r.date||D2_TODAY)!==dt) return; if(!r.zone) return; if(/\s직송$/.test(r.zone)) return; if(!zmap[r.zone]) zmap[r.zone]={dcCd:(r.dcCd||''), inwh:(r.inwh||'')}; });
    window._d2DelZmap=zmap;
    var zsel=document.getElementById('d2DelZone');
    var names=Object.keys(zmap).sort(function(a,b){ return a.localeCompare(b,'ko'); });
    zsel.innerHTML = names.length
      ? names.map(function(z){ var m=zmap[z]; return '<option value="'+d2Esc(z)+'">'+d2Esc(z)+(m.dcCd?(' ('+d2Esc(m.dcCd)+(m.inwh?('-'+d2Esc(m.inwh)):'')+')'):'')+'</option>'; }).join('')
      : '<option value="">(해당 일자에 출고장 없음)</option>';
  }
  function d2DelClose(){ var o=document.getElementById('d2DelOverlay'); if(o) o.style.display='none'; d2DelCancelConfirm(); }
  function d2DelCancelConfirm(){ var b=document.getElementById('d2DelConfirmBox'); if(b) b.style.display='none'; window._d2DelPending=null; }
  // 1단계: 검증 후 인라인 확인 메시지 표시
  function d2DelDo(){
    var dt=(document.getElementById('d2DelDate')||{}).value||'';
    var zsel=document.getElementById('d2DelZone');
    var zlabel=(zsel&&zsel.value)||'';
    var m=(window._d2DelZmap||{})[zlabel]||{};
    var dcCd=m.dcCd||'', inwh=m.inwh||'';
    if(!dt){ d2Toast('⚠️ 출고일자를 선택하세요.'); return; }
    if(!zlabel){ d2Toast('⚠️ 출고장을 선택하세요.'); return; }
    if(!dcCd){ d2Toast('⚠️ 물류센터코드가 없어 안전상 삭제할 수 없습니다.'); return; }
    window._d2DelPending={ dcCd:dcCd, inwh:inwh, dt:dt, label:zlabel };
    d2Set('d2DelConfirmMsg', '⚠️ 출고일자 <u>'+d2Esc(dt)+'</u> 의 출고장 "<b>'+d2Esc(zlabel)+'</b>" 출고분을 삭제하시겠습니까?');
    var box=document.getElementById('d2DelConfirmBox'); if(box) box.style.display='block';
  }
  // 그리드 출고장 헤더의 🗑️ 클릭 → 삭제 모달을 해당 출고일자·출고장으로 맞춰 열고 인라인 확인 표시
  function d2DelZoneFromGrid(el){
    var dt=el.getAttribute('data-dt')||'', cd=el.getAttribute('data-cd')||'', iw=el.getAttribute('data-iw')||'', zn=el.getAttribute('data-zn')||'';
    if(!cd){ d2Toast('⚠️ 물류센터코드가 없어 삭제할 수 없습니다.'); return; }
    if(!dt){ d2Toast('⚠️ 출고일자를 확인할 수 없습니다.'); return; }
    d2DelOpen();
    var dsel=document.getElementById('d2DelDate');
    if(dsel){ var hasD=false,i; for(i=0;i<dsel.options.length;i++){ if(dsel.options[i].value===dt){ hasD=true; break; } }
      if(!hasD){ var od=document.createElement('option'); od.value=dt; od.text=dt; dsel.appendChild(od); }
      dsel.value=dt; }
    d2DelFillZones();
    var zsel=document.getElementById('d2DelZone');
    if(zsel){ var hasZ=false,k; for(k=0;k<zsel.options.length;k++){ if(zsel.options[k].value===zn){ hasZ=true; break; } }
      if(!hasZ){ window._d2DelZmap=window._d2DelZmap||{}; window._d2DelZmap[zn]={dcCd:cd,inwh:iw};
        var oz=document.createElement('option'); oz.value=zn; oz.text=zn+' ('+cd+(iw?('-'+iw):'')+')'; zsel.appendChild(oz); }
      zsel.value=zn; }
    d2DelDo();   // 검증 + 인라인 확인 메시지
  }

  // 2단계: 실제 삭제 실행
  function d2DelExec(){
    var pd=window._d2DelPending; if(!pd){ d2DelCancelConfirm(); return; }
    fetch(CTX+'/shipout/deleteShipoutZone.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin',
      body:'dcCd='+encodeURIComponent(pd.dcCd)+'&inwh='+encodeURIComponent(pd.inwh)+'&shpoutDt='+encodeURIComponent(pd.dt)
    })
    .then(function(r){ return r.text(); })
    .then(function(txt){ var j; try{ j=JSON.parse(txt); }catch(e){ j=null; }
      if(j && j.ok){
        d2DelClose();
        if((+j.count||0)>0) d2Toast('🗑️ 삭제 완료 · '+(j.count||0)+'행 (출고장 '+pd.label+' · '+pd.dt+')');
        else d2Toast('ℹ️ 삭제할 활성 출고분이 없습니다 (출고장 '+pd.label+' · '+pd.dt+')');
        d2Load();
      } else { d2Toast('⚠️ 삭제 실패: '+((j&&j.msg)||txt||'오류').toString().replace(/[<>]/g,'').slice(0,150)); }
    })
    .catch(function(e){ d2Toast('⚠️ 삭제 통신오류: '+e.message); });
  }

  // Ctrl+Del — 출고장 삭제 아이콘 켜기/끄기 토글 (기본 숨김)
  document.addEventListener('keydown', function(e){
    if(e.ctrlKey && (e.key==='Delete' || e.keyCode===46)){
      e.preventDefault();
      var on=document.body.classList.toggle('d2-del-on');
      d2Toast(on ? '🗑️ 출고장 삭제 아이콘 켜짐 (Ctrl+Del 로 끄기)' : '출고장 삭제 아이콘 꺼짐');
    }
  });

  /* == 출고장 × 품목 가로표 엑셀 (2026-08-28 요청) ==============================
       모양 : 행 = 출고장, 열 = 품목. 열은 <사업장 단위>로 묶여 머리줄에 사업장명이 병합되어 얹힌다.
              한 장에 쭉 — 블록으로 자르지 않는다(2026-08-28 「한 장으로 나오되 가로를 줄이는 방법」).
       ★가로를 줄이는 규칙 : <아무 출고장도 내보내지 않는 품목 열>과 <아무것도 안 나가는 출고장 행>은 아예 뺀다.
         빈칸이 남는 것은 그 조합만 없는 것이라 정상 — 대신 아래 두 집계로 무엇이 몇 개인지 알 수 있게 한다.
       ★횡·종 집계 (2026-08-28 「출고장 몇 개, 품목 몇 개 나가는지 횡과 종으로」)
         · 오른쪽 : 합계(수량) · 품목수  → 이 출고장이 <몇 품목> 나가는가
         · 아래   : 합계(수량) · 출고장수 → 이 품목이 <몇 출고장> 나가는가 */
  function d2DownloadByMatrix(mode){
    mode = (mode==='daily') ? 'daily' : 'sum';
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.ssLoadStyleXlsx) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    p.ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || p.XLSX, styled = !!XLSXS;
      if(!LIB){ d2Toast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var from=(document.getElementById('d2DateFrom')||{}).value||'';
      var to=(document.getElementById('d2DateTo')||{}).value||'';
      var dlab=(from&&from===to)?from:(from+' ~ '+to);
      var aoa=[], merges=[], meta=[], maxW=1, made=0;
      /* ★gsMeta[행] = { 그 행에서 <사업장이 새로 시작되는> 열번호들 } (2026-08-28 요청
           「엑셀도 사업장별 선 구분 명확하게」) — 그 열의 왼쪽에 굵은 세로선을 그어
           어디부터 어디까지가 한 사업장인지 눈으로 끊기게 한다(화면 가로표와 같은 규칙).
         날짜별(daily) 모드는 구간마다 품목 구성이 달라 <행마다> 따로 들고 다녀야 한다. */
      var gsMeta=[], gsCur={};
      function push(row,ty){ aoa.push(row); meta.push(ty||''); gsMeta.push(gsCur); }
      /* ★맨 위에 <화면 상단 조회조건>을 그대로 얹는다 (2026-08-28 요청 「상단 조건은 동일하게」).
           나중에 이 파일만 보고도 <무슨 조건으로 뽑은 것인지> 알 수 있어야 한다.
           값은 화면 KPI 칸에서 그대로 읽는다 — 따로 계산하면 화면과 어긋난다. */
      function _txt(id){ var e=document.getElementById(id); return e ? (''+(e.textContent||'')).trim() : ''; }
      push(['조회조건',
            '출고일자  '+dlab,
            (_txt('d2KpiPrefix')||'당일')+' 출고품목  '+(_txt('d2KpiItem')||'0'),
            '출고수량(BOX)  '+(_txt('d2KpiQty')||'0'),
            '출고장 수  '+(_txt('d2KpiZone')||'0'),
            '사업장  '+(_txt('d2KpiBiz')||'0')], 'cond');
      push([], 'blank');
      d2StockLoad();   // 하단 '현재고' 줄에 쓸 값 — 아직 안 왔으면 그 줄은 비워 둔다
      function buildSection(ag, dateHdr){
        var zones=d2ZonesSorted(ag).filter(function(zn){
          var rs=ag.zones[zn].rows;
          return Object.keys(rs).some(function(k){ return (+rs[k].qty||0)>0; });
        });
        if(!zones.length) return;
        /* 열 = <매칭명칭 x 품목> — 화면 가로표(d2RenderMatrixView)와 <같은 규칙>이어야 값이 안 어긋난다.
           매칭이 없는 사업장은 원래 사업장 이름 그대로. 같은 매칭·같은 품목은 한 칸으로 더한다. */
        var colMap={}, cols=[];
        zones.forEach(function(zn){
          var rs=ag.zones[zn].rows;
          Object.keys(rs).forEach(function(rk){
            var r=rs[rk]; if((+r.qty||0)<=0) return;
            var ik=(r.code ? r.code : ('NM:'+(r.name||'')));
            var ck=d2MtNm(r)+'\u0001'+ik;
            var c=colMap[ck];
            if(!c){ c=colMap[ck]={ ck:ck, biz:d2MtNm(r), code:(r.code||''), name:(r.name||''), keys:[], kset:{} }; cols.push(c); }
            if(!c.kset[rk]){ c.kset[rk]=1; c.keys.push(rk); }
          });
        });
        if(!cols.length) return;
        cols.sort(function(a,b){ return a.biz.localeCompare(b.biz,'ko') || a.name.localeCompare(b.name,'ko'); });
        function colQty(rs, c){ var t=0; for(var i=0;i<c.keys.length;i++){ var x=rs[c.keys[i]]; if(x) t+=(+x.qty||0); } return t; }
        /* 맨 위 '출고장일자' 줄은 뺐다 (2026-08-28 요청) — 이 날짜 배너가 같은 내용을 이미 담고 있다 */
        push(['📅 '+(dateHdr||dlab)+' 출고     ※ 회색 칸 = 그 출고장에 그 품목이 없음'], 'datehdr');
        /* ★열 차례 : [0]출고장  [1]합계  [2]품목수  [3~]사업장·품목  (2026-08-28 「엑셀도 합계·품목수가 앞으로」)
             화면 가로표와 같은 차례다. 세 칸을 틀 고정하므로 옆으로 끝까지 밀어도 총량이 보인다.
           ⚠아래 서식 루프의 자리번호(1·2)와 !cols·!freeze(xSplit:3) 가 이 차례에 묶여 있다 — 바꾸면 같이 고칠 것. */
        var W=cols.length+3;
        if(W>maxW) maxW=W;
        var cTot=1, cCnt=2, cOff=3;                     // cOff = 첫 품목 열
        var r1=new Array(W); for(var i=0;i<W;i++) r1[i]='';
        r1[0]='구분';
        r1[cTot]='합계'; r1[cCnt]='품목수';
        merges.push({s:{r:aoa.length,c:cTot}, e:{r:aoa.length+1,c:cTot}});
        merges.push({s:{r:aoa.length,c:cCnt}, e:{r:aoa.length+1,c:cCnt}});
        /* 이 구간의 사업장 경계 열 — 첫 사업장은 뺀다(왼쪽이 이미 합계·품목수 칸 경계라 선이 겹친다) */
        gsCur={};
        for(var g0=1;g0<cols.length;g0++) if(cols[g0].biz!==cols[g0-1].biz) gsCur[g0+cOff]=1;
        var start=0, bz=cols[0].biz;
        for(var i2=0;i2<cols.length;i2++){
          if(cols[i2].biz!==bz){
            r1[start+cOff]=bz;
            if(i2-start>=2) merges.push({s:{r:aoa.length,c:start+cOff}, e:{r:aoa.length,c:i2-1+cOff}});
            start=i2; bz=cols[i2].biz;
          }
        }
        r1[start+cOff]=bz;
        if(cols.length-start>=2) merges.push({s:{r:aoa.length,c:start+cOff}, e:{r:aoa.length,c:cols.length-1+cOff}});
        push(r1,'bizhdr');
        var r2=['출고장/품목','',''];
        cols.forEach(function(c){ r2.push(c.code ? (c.code+'('+c.name+')') : c.name); });
        push(r2,'colhdr');
        var sums=cols.map(function(){ return 0; });
        var zcnt=cols.map(function(){ return 0; });
        var grand=0, itemAll={};
        /* ★출고장을 대시보드처럼 <물류센터 묶음> 아래에 넣는다 (2026-08-28 요청).
             묶음 줄에는 그 묶음의 소계(열별 수량 · 합계 · 품목수)를 함께 적는다 — 화면의 ▼ 그룹 줄과 같은 뜻.
             묶음 순서는 화면의 [그룹순서] 설정(D2_GORD)을 그대로 따른다. */
        var groups={}, gOrder=[];
        zones.forEach(function(zn){ var g=(ag.zones[zn].dc||zn); if(!groups[g]){ groups[g]=[]; gOrder.push(g); } groups[g].push(zn); });
        gOrder.sort(function(a,b){
          var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);
          if(ia>=0&&ib>=0) return ia-ib;
          if(ia>=0) return -1; if(ib>=0) return 1;
          return a.localeCompare(b,'ko');
        });
        gOrder.forEach(function(g){
          /* 정렬 = 화면 가로표와 동일: 센터명으로 묶고 그 안에서 직송 맨 아래 (2026-08-30) */
          var gz=groups[g].slice().sort(function(a,b){
            var c=d2CenterNm(a).localeCompare(d2CenterNm(b),'ko'); if(c!==0) return c;
            var ja=/\s직송$/.test(a)?1:0, jb=/\s직송$/.test(b)?1:0; if(ja!==jb) return ja-jb;
            return a.localeCompare(b,'ko');
          });
          var gs=cols.map(function(){ return 0; }), gItems={}, lines=[];
          /* 센터 소계 — 화면 csub 와 같은 규칙(묶음 안 센터 여럿 + 그 센터 2줄 이상일 때만) (2026-08-30) */
          var _cCnt={}; gz.forEach(function(zn){ var c=d2CenterNm(zn); _cCnt[c]=(_cCnt[c]||0)+1; });
          var _cMulti=Object.keys(_cCnt).length>1;
          var _cCur=null, _cs=cols.map(function(){ return 0; }), _cItems={}, _cTot=0;
          function _cFlushX(){
            if(_cCur!==null && _cMulti && _cCnt[_cCur]>1){
              lines.push({ ty:'csub', row:['  '+_cCur+' 합계', _cTot||'', Object.keys(_cItems).length||''].concat(_cs.map(function(v){ return v||''; })) });
            }
            _cs=cols.map(function(){ return 0; }); _cItems={}; _cTot=0;
          }
          gz.forEach(function(zn){
            var _zc=d2CenterNm(zn); if(_cCur!==null && _zc!==_cCur) _cFlushX(); _cCur=_zc;
            var rs=ag.zones[zn].rows, cells=[], rt=0, rc=0;
            cols.forEach(function(c,ix){
              var q=colQty(rs,c);
              if(q>0){ sums[ix]+=q; zcnt[ix]++; gs[ix]+=q; _cs[ix]+=q; rt+=q; rc++; itemAll[c.ck]=1; gItems[c.ck]=1; _cItems[c.ck]=1; }
              cells.push(q>0 ? q : '');
            });
            grand+=rt; _cTot+=rt;
            lines.push({ ty:'body', row:['    '+zn, rt||'', rc||''].concat(cells) });
          });
          _cFlushX();   // 마지막 센터 소계
          var gTot=0; gs.forEach(function(v){ gTot+=v; });
          push(['▼ '+g+'   ('+gz.length+'개 출고장)', gTot||'', Object.keys(gItems).length||'']
                 .concat(gs.map(function(v){ return v||''; })), 'grp');
          lines.forEach(function(r){ push(r.row, r.ty); });
        });
        push(['합계', grand||'', Object.keys(itemAll).length||'']
               .concat(sums.map(function(v){ return v||''; })), 'sum');
        push(['출고장수', zones.length, '']
               .concat(zcnt.map(function(v){ return v||''; })), 'zcnt');
        /* ★품목별 현재고 (2026-08-28 요청 「하단에 현재고 품목별 표시」) —
             화면 '현재고' 칸과 같은 근거(수불원장). 값을 못 찾으면 0 이 아니라 빈칸으로 둔다
             — 0 으로 적으면 '재고 없음'으로 잘못 읽힌다. */
        var anyStk=false;
        var rowStk=['현재고','',''].concat(cols.map(function(c){
          var q=d2StockQty(c.code); if(q!=null) anyStk=true; return (q==null?'':q);
        }));
        if(anyStk) push(rowStk,'stk');
        push([], 'blank');
        push([], 'blank');
        made++;
      }
      if(mode==='daily'){
        var dset={}; (D2_DATA||[]).forEach(function(r){ var d=r.date||D2_TODAY; if(from&&d<from)return; if(to&&d>to)return; dset[d]=1; });
        Object.keys(dset).sort().forEach(function(d){
          buildSection(d2Aggregate(D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; }), d, d), d);
        });
      } else {
        buildSection(d2Aggregate(), null);
      }
      if(!made){ d2Toast('⚠️ 출고량이 있는 자료가 없습니다.'); return; }
      var ws=LIB.utils.aoa_to_sheet(aoa);
      /* 품목 칸 폭 18 (2026-08-28 「품목 칸 폭도 조금 넓게」) — 14 에서는 품목명이 너무 잘게 접혔다.
         ⚠아래 머리줄 높이 계산의 '한 줄에 몇 자'(9자)도 이 폭에 맞춘 값이다 — 폭을 바꾸면 같이 바꿀 것. */
      var cw=[{wch:24},{wch:10},{wch:9}]; for(var i3=3;i3<maxW;i3++) cw.push({wch:18});
      ws['!cols']=cw;
      ws['!merges']=merges;
      /* ★틀 고정 — 출고장명 열(A)과 머리줄 3행을 얼려, 오른쪽으로 밀어도 <무엇의 값인지> 보이게 한다
           (2026-08-28 요청 「표시는 고정으로 우측으로 스크롤해도」).
         ⚠xlsx-js-style 1.2.0 원본에는 이 기능이 <없다> — assets/vendor/xlsx-js-style/xlsx.bundle.js 를
           우리가 고쳐 넣었다(파일 머리 주석 참고). 그 파일을 새 버전으로 갈아 끼우면 고정이 조용히 사라진다.
           인터넷 CDN 폴백본에도 이 수정이 없다(로컬 파일이 먼저 시도되므로 평소엔 문제 없다). */
      /* 조회조건 2줄이 앞에 붙었으므로 고정할 머리줄도 2줄 늘어난다(날짜배너·사업장·품목명 = 3+2=5) */
      /* 출고장·합계·품목수 3열(A~C)과 머리줄 5행을 얼린다 — 앞으로 옮긴 두 칸도 같이 고정(2026-08-28) */
      ws['!freeze']={xSplit:3, ySplit:5, topLeftCell:'D6', activePane:'bottomRight', state:'frozen'};
      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'9BA7B4'}};
        var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          dateL:{ font:{bold:true,sz:12,color:{rgb:'1F2A37'}}, alignment:{horizontal:'left',vertical:'center'} },
          datehdr:{ fill:{fgColor:{rgb:'11161D'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:13}, alignment:{horizontal:'left',vertical:'center'} },
          /* 사업장명도 품목명처럼 줄바꿈해서 넣는다 (2026-08-28 요청) — 이름이 길면 한 줄로는 잘린다.
             ⚠병합된 칸은 엑셀이 높이를 자동으로 안 늘린다 → 아래에서 행 높이를 직접 준다. */
          bizhdr:{ fill:{fgColor:{rgb:'BDD7EE'}}, font:{bold:true,color:{rgb:'1F2A37'},sz:10}, alignment:{horizontal:'center',vertical:'center',wrapText:true}, border:box },
          colhdr:{ fill:{fgColor:{rgb:'DEEAF6'}}, font:{bold:true,color:{rgb:'1F2A37'},sz:10}, alignment:{horizontal:'center',vertical:'center',wrapText:true}, border:box },
          zoneL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          /* ★값이 있는 칸은 <흰 바탕 + 굵은 숫자>, 없는 칸은 <옅은 회색 바탕> (2026-08-28 요청).
             ⚠빈칸에 글자(-, · 등)를 넣지 않는다 — 넣으면 엑셀에서 합계·개수·필터가 그 글자를 세어 버린다. */
          num:{ font:{bold:true,color:{rgb:'1F2A37'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          none:{ fill:{fgColor:{rgb:'F1F3F5'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          grpNone:{ fill:{fgColor:{rgb:'0E6659'}}, border:box },
          rtot:{ fill:{fgColor:{rgb:'FFF2CC'}}, font:{bold:true,color:{rgb:'1F2A37'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          rcnt:{ fill:{fgColor:{rgb:'E2EFDA'}}, font:{bold:true,color:{rgb:'1F2A37'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          grpL:{ fill:{fgColor:{rgb:'137A6C'}}, font:{bold:true,color:{rgb:'FFFFFF'},sz:11}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          grpN:{ fill:{fgColor:{rgb:'137A6C'}}, font:{bold:true,color:{rgb:'FFFFFF'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          sumL:{ fill:{fgColor:{rgb:'F2F2F2'}}, font:{bold:true,color:{rgb:'1F2A37'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          sumN:{ fill:{fgColor:{rgb:'F2F2F2'}}, font:{bold:true,color:{rgb:'1F2A37'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          zcntL:{ fill:{fgColor:{rgb:'E2EFDA'}}, font:{bold:true,color:{rgb:'375623'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          zcntN:{ fill:{fgColor:{rgb:'E2EFDA'}}, font:{bold:true,color:{rgb:'375623'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          cond:{ fill:{fgColor:{rgb:'EAF1F8'}}, font:{bold:true,color:{rgb:'20415A'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          stkL:{ fill:{fgColor:{rgb:'FFF4E6'}}, font:{bold:true,color:{rgb:'8A5B14'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          stkN:{ fill:{fgColor:{rgb:'FFF4E6'}}, font:{bold:true,color:{rgb:'137A6C'}}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          stkNeg:{ fill:{fgColor:{rgb:'FFF4E6'}}, font:{bold:true,color:{rgb:'C0392B'}}, alignment:{horizontal:'right',vertical:'center'}, border:box }
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rowsH=[];
        meta.forEach(function(ty,r){
          var wid=(aoa[r]||[]).length, h=null, c;
          if(ty==='date'){ put(r,0,S.dateL); put(r,1,S.dateL); h=20; }
          else if(ty==='datehdr'){ put(r,0,S.datehdr); h=22; }
          else if(ty==='bizhdr'){
            for(c=0;c<wid;c++) put(r,c,S.bizhdr);
            /* 사업장명이 길면 두세 줄이 되므로 그만큼 높이를 준다 — 칸 폭 14 기준 대략 7자에 한 줄 */
            var _ln=1; (aoa[r]||[]).forEach(function(v){ var t=(''+(v==null?'':v)); if(t) _ln=Math.max(_ln, Math.min(3, Math.ceil(t.length/9))); });
            h=Math.max(20, 15*_ln+6);
          }
          else if(ty==='colhdr'){
            for(c=0;c<wid;c++) put(r,c,S.colhdr);
            /* 품목명 줄은 <가장 긴 이름에 맞춰> 높이를 준다 (2026-08-28 「품목명 아래를 조금 넓게」).
               품목코드(품목명,규격…)이 60자를 넘는 것이 흔해 42px 고정으로는 뒷부분이 잘렸다.
               칸 폭 14 기준 대략 7자에 한 줄, 최대 8줄까지. */
            var _cl=3; (aoa[r]||[]).forEach(function(v){ var t=(''+(v==null?'':v)); if(t) _cl=Math.max(_cl, Math.min(8, Math.ceil(t.length/9))); });
            h=Math.max(48, 13*_cl+8);
          }
          else if(ty==='body'){
            put(r,0,S.zoneL);
            put(r,1,S.rtot); put(r,2,S.rcnt);          // ★합계·품목수는 앞(B·C)으로 옮겼다
            for(c=3;c<wid;c++){ var bv=(aoa[r]||[])[c]; put(r,c, (bv===''||bv==null) ? S.none : S.num); }
            h=19;
          }
          else if(ty==='grp'){
            put(r,0,S.grpL);
            for(c=1;c<wid;c++){ var gv=(aoa[r]||[])[c]; put(r,c, (gv===''||gv==null) ? S.grpNone : S.grpN); }
            h=20;
          }
          else if(ty==='csub'){ put(r,0,S.csubL); for(c=1;c<wid;c++) put(r,c,S.csubN); h=19; }
          else if(ty==='sum'){ put(r,0,S.sumL); for(c=1;c<wid;c++) put(r,c,S.sumN); h=20; }
          else if(ty==='zcnt'){ put(r,0,S.zcntL); for(c=1;c<wid;c++) put(r,c,S.zcntN); h=20; }
          else if(ty==='cond'){ for(c=0;c<wid;c++) put(r,c,S.cond); h=22; }
          else if(ty==='stk'){
            put(r,0,S.stkL);
            /* B·C(합계·품목수 자리)는 현재고에 쓰지 않는다 — 회색(S.none)으로 두면 「값 없음」으로 읽혀 헷갈린다 */
            put(r,1,S.stkN); put(r,2,S.stkN);
            for(c=3;c<wid;c++){ var sv=(aoa[r]||[])[c]; put(r,c, (sv==='' || sv==null) ? S.none : ((+sv<0) ? S.stkNeg : S.stkN)); }
            h=20;
          }
          rowsH.push(h?{hpx:h}:{});
        });
        /* ★사업장 경계에 굵은 세로선 (2026-08-28 요청 「엑셀도 사업장별 선 구분 명확하게」) —
             머리줄(사업장·품목명)부터 본문·묶음·합계·출고장수·현재고 줄까지 <같은 열>에 그어
             한 사업장 덩어리가 세로로 끊겨 보이게 한다. 화면 가로표의 구분선과 같은 규칙.
           ⚠S.* 서식 객체는 여러 칸이 <같은 것을 공유>한다 — 그대로 고치면 표 전체가 굵어진다.
             그래서 그 칸만 복사본을 만들어 왼쪽 선을 얹는다.
           ⚠날짜 배너·조회조건 줄은 제외(한 칸짜리 줄이라 선이 뜬금없이 뜬다). */
        var GSB={style:'medium', color:{rgb:'2F5597'}};
        function gsMark(r,c){
          var ref=enc({r:r,c:c}), cell=ws[ref]; if(!cell) return;
          var s=cell.s ? JSON.parse(JSON.stringify(cell.s)) : {};
          s.border=s.border||{}; s.border.left=GSB; cell.s=s;
        }
        meta.forEach(function(ty,r){
          if(ty==='cond' || ty==='datehdr' || ty==='date' || ty==='blank') return;
          var set=gsMeta[r]; if(!set) return;
          for(var k in set) gsMark(r, +k);
        });
        ws['!rows']=rowsH;
      }
      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, '출고장x품목');
      var fn='출고장x품목_'+(mode==='daily'?'일자별_':'')+((dlab.replace(/[^0-9]/g,'')).slice(0,8)||'출력')+'.xlsx';
      LIB.writeFile(wb, fn);
      d2Toast('📥 <b>'+fn+'</b> 로 내려받았습니다');
    });
  }
  // ── 출고장별 엑셀 출력 — 데시보드2 그리드 그대로 출력 (TBL_BIZI_MST 무시, 사업장명[코드] 표시, 현재 필터 반영)
  //    엑셀 라이브러리는 부모(데시보드1)의 ssLoadStyleXlsx/XLSX 재사용. 레이아웃·색상은 데시보드1 출고장별 출력과 동일
  function d2DownloadByZone(mode){   // mode: 'daily'(일자별) | 'sum'(기간 합계, 기본)
    mode = (mode==='daily') ? 'daily' : 'sum';
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.ssLoadStyleXlsx) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    p.ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || p.XLSX;
      var styled = !!XLSXS;
      if(!LIB){ d2Toast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var from=(document.getElementById('d2DateFrom')||{}).value||'';
      var to=(document.getElementById('d2DateTo')||{}).value||'';
      var dlab=(from&&from===to)?from:(from+' ~ '+to);

      var COLS=5, aoa=[], merges=[], meta=[];
      function mergeRow(ri,e){ merges.push({s:{r:ri,c:0}, e:{r:ri,c:(e==null?COLS-1:e)}}); }
      function push(row,ty,mEnd){ aoa.push(row); meta.push(ty); if(mEnd!=null) mergeRow(aoa.length-1,mEnd); }
      push(['출고장별 출고현황'+(mode==='daily'?' (일자별)':' (기간 합계)')],'title',COLS-1);
      push(['출고일자  '+dlab],'date',COLS-1);
      push([],'blank');

      var grandAll=0, madeAll=0;
      // ag 하나(범위) 기준 출고장 섹션 생성. dateHdr 주면 날짜배너 + 날짜합계 추가
      function buildSection(ag, dateHdr){
        var zonesSorted=d2ZonesSorted(ag);
        var zonesWithItems=zonesSorted.filter(function(zn){ return Object.keys(ag.zones[zn].rows).length>0; });
        if(!zonesWithItems.length) return;
        if(dateHdr) push(['📅 '+dateHdr+' 출고'],'datehdr',COLS-1);
        // 물류센터(대표그룹) 단위로 묶기 — 화면과 동일 (오산센터 등)
        function d2CenterOfX(zn){ return (''+zn).replace(/\s*직송$/,'').replace(/\s*\d+\s*$/,'').trim(); }
        var groups={}, gOrder=[];
        zonesWithItems.forEach(function(zn){ var g=ag.zones[zn].dc || zn; if(!groups[g]){ groups[g]=[]; gOrder.push(g); } groups[g].push(zn); });
        gOrder.sort(function(a,b){ var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b); if(ia>=0&&ib>=0)return ia-ib; if(ia>=0)return -1; if(ib>=0)return 1; return a.localeCompare(b,'ko'); });
        var sub=0;
        gOrder.forEach(function(g){
          var gz=groups[g], gsum=0; gz.forEach(function(zn){ gsum+=ag.zones[zn].tot; });
          push(['▼ '+g+'   ('+gz.length+'개 출고장 · 출고 '+d2Num(gsum)+')'],'grp',COLS-1);
          /* 센터 소계 — 화면 csub 와 같은 규칙(2026-08-30 「엑셀도」) */
          var _cCnt={}; gz.forEach(function(zn){ var c=d2CenterOfX(zn); _cCnt[c]=(_cCnt[c]||0)+1; });
          var _cMulti=Object.keys(_cCnt).length>1;
          var _cCur=null, _cTot=0;
          function _cFlush(){
            if(_cCur!==null && _cMulti && _cCnt[_cCur]>1){ push(['▣ '+_cCur+' 합계','','','',_cTot],'sub',COLS-2); push([],'blank'); }
            _cTot=0;
          }
          gz.forEach(function(zn){
            var _zc=d2CenterOfX(zn); if(_cCur!==null && _zc!==_cCur) _cFlush(); _cCur=_zc;
            var z=ag.zones[zn];
            var keys=Object.keys(z.rows).sort(function(a,b){
              var A=z.rows[a],B=z.rows[b];
              return A.biz.localeCompare(B.biz,'ko')||A.name.localeCompare(B.name,'ko');
            });
            var dla=Object.keys(z.dlv).sort();   // 납기일자 — 출고일자와 무관하게 항상 표시
            var dl=dla.length?('납기일자 '+dla.join(', ')):'';
            push(['▣ '+zn+' 출고장   (품목 '+keys.length+'종 · 출고 '+d2Num(z.tot)+(dl?(' · '+dl):'')+')'],(/\s직송$/.test(zn)?'zonej':'zone'),COLS-1);   // 직송 블록 제목=빨간 글씨(2026-08-30)
            push(['No','사업장','품목명','품목코드','출고수량'],'head');
            keys.forEach(function(k,ix){ var r=z.rows[k]; push([ix+1, r.biz, r.name, r.code, r.qty],'item'); });
            push(['소계','','','',z.tot],'sub',COLS-2);
            push([],'blank');
            sub+=z.tot; _cTot+=z.tot; madeAll++;
          });
          _cFlush();
        });
        if(dateHdr){ push([dateHdr+' 합계','','','',sub],'dtot',COLS-2); push([],'blank'); }
        grandAll+=sub;
      }

      if(mode==='daily'){
        // 출고일자별로 섹션 반복 (화면 날짜블록과 동일)
        var dset={}; (D2_DATA||[]).forEach(function(r){ var d=r.date||D2_TODAY; if(from&&d<from)return; if(to&&d>to)return; dset[d]=1; });
        Object.keys(dset).sort().forEach(function(d){
          var rowsD=D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; });
          buildSection(d2Aggregate(rowsD, d, d), d);
        });
      } else {
        buildSection(d2Aggregate(), null);   // 기간 전체 합산
      }
      if(!madeAll){ d2Toast('⚠️ 출고량이 있는 출고장이 없습니다.'); return; }
      push(['전체 합계','','','',grandAll],'grand',COLS-2);

      var ws=LIB.utils.aoa_to_sheet(aoa);
      ws['!cols']=[{wch:5},{wch:26},{wch:44},{wch:14},{wch:11}];
      ws['!merges']=merges;

      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'A9B7B1'}};   // 셀 구분선 — 살짝 진하게
        var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          title:{ fill:{fgColor:{rgb:'178074'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          date:{ font:{color:{rgb:'1F2A37'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          datehdr:{ fill:{fgColor:{rgb:'11161D'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:13}, alignment:{horizontal:'left',vertical:'center'} },
          grp:{ fill:{fgColor:{rgb:'137A6C'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:13}, alignment:{horizontal:'left',vertical:'center'} },
          csubL:{ fill:{fgColor:{rgb:'EAF5F2'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'left',vertical:'center'}, border:{top:{style:'thin',color:{rgb:'C9DCD6'}},bottom:{style:'thin',color:{rgb:'C9DCD6'}},left:{style:'thin',color:{rgb:'C9DCD6'}},right:{style:'thin',color:{rgb:'C9DCD6'}}} },   // 센터 소계(2026-08-30)
          csubN:{ fill:{fgColor:{rgb:'EAF5F2'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'right',vertical:'center'}, border:{top:{style:'thin',color:{rgb:'C9DCD6'}},bottom:{style:'thin',color:{rgb:'C9DCD6'}},left:{style:'thin',color:{rgb:'C9DCD6'}},right:{style:'thin',color:{rgb:'C9DCD6'}}} },
          zone:{ fill:{fgColor:{rgb:'1F9B8E'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          zonej:{ fill:{fgColor:{rgb:'FDECEA'}}, font:{color:{rgb:'C0392B'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },   // 직송 블록 제목(빨간 글씨, 2026-08-30)
          head:{ fill:{fgColor:{rgb:'E3F4EF'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          itemCB:{ font:{color:{rgb:'000000'}}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemN:{ font:{color:{rgb:'1F2A37'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          subL:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'37475A'},bold:true}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          subN:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'137A6C'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          dtotL:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          dtotN:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'} },
          grandL:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grandN:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:14}, alignment:{horizontal:'right',vertical:'center'} }
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rows=[];
        meta.forEach(function(ty,r){
          var h=null;
          if(ty==='title'){ put(r,0,S.title); h=26; }
          else if(ty==='date'){ put(r,0,S.date); h=24; }
          else if(ty==='datehdr'){ put(r,0,S.datehdr); h=22; }
          else if(ty==='grp'){ put(r,0,S.grp); h=22; }
          else if(ty==='zone'){ put(r,0,S.zone); h=22; }
          else if(ty==='zonej'){ put(r,0,S.zonej); h=22; }
          else if(ty==='head'){ for(var c=0;c<COLS;c++) put(r,c,S.head); h=20; }
          else if(ty==='item'){ put(r,0,S.itemCB); put(r,1,S.itemL); put(r,2,S.itemL); put(r,3,S.itemCB); put(r,4,S.itemN); }
          else if(ty==='sub'){ for(var c2=0;c2<COLS-1;c2++) put(r,c2,S.subL); put(r,COLS-1,S.subN); h=19; }
          else if(ty==='dtot'){ for(var c4=0;c4<COLS-1;c4++) put(r,c4,S.dtotL); put(r,COLS-1,S.dtotN); h=21; }
          else if(ty==='grand'){ for(var c3=0;c3<COLS-1;c3++) put(r,c3,S.grandL); put(r,COLS-1,S.grandN); h=22; }
          rows.push(h!=null?{hpt:h}:{});
        });
        ws['!rows']=rows;
      }

      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, mode==='daily'?'출고장별_일자별':'출고장별_합계');
      LIB.writeFile(wb, '출고장별_'+(mode==='daily'?'일자별_':'합계_')+(from||'')+((to&&to!==from)?'~'+to:'')+'.xlsx');
      d2Toast('📥 출고장별 '+(mode==='daily'?'일자별':'합계')+' 엑셀 저장 완료 · '+dlab);
    });
  }

  // ── 품목별 출력 (별도 형식) — 품목별 총 출고수량 합산. mode: 'daily'(일자별) | 'sum'(기간 합계)
  function d2DownloadByItem(mode){
    mode=(mode==='daily')?'daily':'sum';
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.ssLoadStyleXlsx) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    p.ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || p.XLSX;
      var styled = !!XLSXS;
      if(!LIB){ d2Toast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var from=(document.getElementById('d2DateFrom')||{}).value||'';
      var to=(document.getElementById('d2DateTo')||{}).value||'';
      var dlab=(from&&from===to)?from:(from+' ~ '+to);
      // ag → 품목별(품목코드|품목명) 합산 목록
      function itemsFromAg(ag){
        var items={};
        ag.zoneOrder.forEach(function(zn){ var z=ag.zones[zn]; Object.keys(z.rows).forEach(function(rk){
          var r=z.rows[rk]; if(!((+r.qty||0)>0)) return;
          var k=r.code?('C:'+r.code):('N:'+r.name);
          if(!items[k]) items[k]={code:r.code||'', name:r.name||'', qty:0};
          items[k].qty+=(+r.qty||0);
        }); });
        return Object.keys(items).map(function(k){ return items[k]; })
          .sort(function(a,b){ return a.name.localeCompare(b.name,'ko')||a.code.localeCompare(b.code,'ko'); });
      }

      var COLS=4, aoa=[], merges=[], meta=[], grandAll=0, madeAll=0;
      function mergeRow(ri,e){ merges.push({s:{r:ri,c:0}, e:{r:ri,c:(e==null?COLS-1:e)}}); }
      function push(row,ty,mEnd){ aoa.push(row); meta.push(ty); if(mEnd!=null) mergeRow(aoa.length-1,mEnd); }
      push(['품목별 출고 합계'+(mode==='daily'?' (일자별)':' (기간 합계)')],'title',COLS-1);
      push(['출고일자  '+dlab],'date',COLS-1);
      push([],'blank');
      function buildItemSection(list, dateHdr){
        if(!list.length) return;
        if(dateHdr) push(['📅 '+dateHdr+' 출고'],'datehdr',COLS-1);
        push(['No','품목코드','품목명','출고수량'],'head');
        var sub=0;
        list.forEach(function(r,ix){ push([ix+1, r.code, r.name, r.qty],'item'); sub+=r.qty; madeAll++; });
        if(dateHdr){ push([dateHdr+' 합계','','',sub],'dtot',COLS-2); push([],'blank'); }
        grandAll+=sub;
      }
      if(mode==='daily'){
        var dset={}; (D2_DATA||[]).forEach(function(r){ var d=r.date||D2_TODAY; if(from&&d<from)return; if(to&&d>to)return; dset[d]=1; });
        Object.keys(dset).sort().forEach(function(d){
          var rowsD=D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; });
          buildItemSection(itemsFromAg(d2Aggregate(rowsD, d, d)), d);
        });
      } else {
        buildItemSection(itemsFromAg(d2Aggregate()), null);
      }
      if(!madeAll){ d2Toast('⚠️ 출고량이 있는 품목이 없습니다.'); return; }
      push(['전체 합계','','',grandAll],'grand',COLS-2);

      var ws=LIB.utils.aoa_to_sheet(aoa);
      ws['!cols']=[{wch:5},{wch:16},{wch:50},{wch:12}];
      ws['!merges']=merges;
      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'A9B7B1'}}; var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          title:{ fill:{fgColor:{rgb:'178074'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          date:{ font:{color:{rgb:'1F2A37'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          datehdr:{ fill:{fgColor:{rgb:'11161D'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:13}, alignment:{horizontal:'left',vertical:'center'} },
          head:{ fill:{fgColor:{rgb:'E3F4EF'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemCB:{ font:{color:{rgb:'000000'}}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          itemN:{ font:{color:{rgb:'1F2A37'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          dtotL:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          dtotN:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'} },
          grandL:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grandN:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:14}, alignment:{horizontal:'right',vertical:'center'} }
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rows=[];
        meta.forEach(function(ty,r){ var h=null;
          if(ty==='title'){ put(r,0,S.title); h=26; }
          else if(ty==='date'){ put(r,0,S.date); h=24; }
          else if(ty==='datehdr'){ put(r,0,S.datehdr); h=22; }
          else if(ty==='head'){ for(var c=0;c<COLS;c++) put(r,c,S.head); h=20; }
          else if(ty==='item'){ put(r,0,S.itemCB); put(r,1,S.itemCB); put(r,2,S.itemL); put(r,3,S.itemN); }
          else if(ty==='dtot'){ for(var c4=0;c4<COLS-1;c4++) put(r,c4,S.dtotL); put(r,COLS-1,S.dtotN); h=21; }
          else if(ty==='grand'){ for(var c3=0;c3<COLS-1;c3++) put(r,c3,S.grandL); put(r,COLS-1,S.grandN); h=22; }
          rows.push(h!=null?{hpt:h}:{});
        });
        ws['!rows']=rows;
      }
      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, mode==='daily'?'품목별_일자별':'품목별_합계');
      LIB.writeFile(wb, '품목별_'+(mode==='daily'?'일자별_':'합계_')+(from||'')+((to&&to!==from)?'~'+to:'')+'.xlsx');
      d2Toast('📥 품목별 '+(mode==='daily'?'일자별':'합계')+' 엑셀 저장 완료 · '+dlab);
    });
  }

  // ── 사업장별 품목합계 출력 — 사업장 그룹 안에 품목별 총 출고수량. mode: 'daily' | 'sum'
  function d2DownloadByBiz(mode){
    mode=(mode==='daily')?'daily':'sum';
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.ssLoadStyleXlsx) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    p.ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || p.XLSX;
      var styled = !!XLSXS;
      if(!LIB){ d2Toast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var from=(document.getElementById('d2DateFrom')||{}).value||'';
      var to=(document.getElementById('d2DateTo')||{}).value||'';
      var dlab=(from&&from===to)?from:(from+' ~ '+to);
      // ag → 사업장별 { 사업장: {items, tot} } (품목코드|품목명 기준 합산)
      function bizFromAg(ag){
        var bm={};
        ag.zoneOrder.forEach(function(zn){ var z=ag.zones[zn]; Object.keys(z.rows).forEach(function(rk){
          var r=z.rows[rk]; if(!((+r.qty||0)>0)) return;
          var b=r.biz||'(사업장 미지정)';
          var g=bm[b]||(bm[b]={items:{}, tot:0});
          var k=r.code?('C:'+r.code):('N:'+r.name);
          if(!g.items[k]) g.items[k]={code:r.code||'', name:r.name||'', qty:0};
          g.items[k].qty+=(+r.qty||0); g.tot+=(+r.qty||0);
        }); });
        return bm;
      }

      var COLS=5, aoa=[], merges=[], meta=[], grandAll=0, madeAll=0;   // [사업장, No, 품목코드, 품목명, 출고수량]
      function mergeRow(ri,e){ merges.push({s:{r:ri,c:0}, e:{r:ri,c:(e==null?COLS-1:e)}}); }
      function push(row,ty,mEnd){ aoa.push(row); meta.push(ty); if(mEnd!=null) mergeRow(aoa.length-1,mEnd); }
      push(['사업장별 품목합계'+(mode==='daily'?' (일자별)':' (기간 합계)')],'title',COLS-1);
      push(['출고일자  '+dlab],'date',COLS-1);
      push([],'blank');
      function buildBizSection(bm, dateHdr){
        var names=Object.keys(bm).sort(function(a,b){ return a.localeCompare(b,'ko'); });
        if(!names.length) return;
        if(dateHdr) push(['📅 '+dateHdr+' 출고'],'datehdr',COLS-1);
        push(['사업장','No','품목코드','품목명','출고수량'],'head');
        var sub=0;
        names.forEach(function(b){
          var g=bm[b];
          var list=Object.keys(g.items).map(function(k){ return g.items[k]; })
            .sort(function(x,y){ return x.name.localeCompare(y.name,'ko')||x.code.localeCompare(y.code,'ko'); });
          var startR=aoa.length;   // 사업장 좌측 병합 시작 = 소계 행
          push([b, '소계', '', '(품목 '+list.length+'종)', g.tot], 'bizsub');   // A=사업장(좌측), B=소계
          list.forEach(function(r,ix){ push(['', ix+1, r.code, r.name, r.qty], 'item'); });
          var endR=aoa.length-1;
          if(endR>startR) merges.push({s:{r:startR,c:0}, e:{r:endR,c:0}});   // 사업장 A열 세로 병합(조회화면처럼)
          sub+=g.tot; madeAll++;
        });
        if(dateHdr) push(['📅 '+dateHdr+' 합계','','','',sub],'dtot',COLS-2);
        grandAll+=sub;
      }
      if(mode==='daily'){
        var dset={}; (D2_DATA||[]).forEach(function(r){ var d=r.date||D2_TODAY; if(from&&d<from)return; if(to&&d>to)return; dset[d]=1; });
        Object.keys(dset).sort().forEach(function(d){
          var rowsD=D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; });
          buildBizSection(bizFromAg(d2Aggregate(rowsD, d, d)), d);
        });
      } else {
        buildBizSection(bizFromAg(d2Aggregate()), null);
      }
      if(!madeAll){ d2Toast('⚠️ 출고량이 있는 사업장이 없습니다.'); return; }
      push(['전체 합계','','','',grandAll],'grand',COLS-2);

      var ws=LIB.utils.aoa_to_sheet(aoa);
      ws['!cols']=[{wch:26},{wch:5},{wch:16},{wch:44},{wch:11}];   // 사업장·No·품목코드·품목명·출고수량
      ws['!merges']=merges;
      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'A9B7B1'}}; var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          title:{ fill:{fgColor:{rgb:'178074'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          date:{ font:{color:{rgb:'1F2A37'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          datehdr:{ fill:{fgColor:{rgb:'11161D'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:13}, alignment:{horizontal:'left',vertical:'center'} },
          za:{ fill:{fgColor:{rgb:'E3EFEC'}}, font:{color:{rgb:'0E6657'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center',wrapText:true}, border:box },   // 사업장 좌측 셀
          head:{ fill:{fgColor:{rgb:'E3F4EF'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemCB:{ font:{color:{rgb:'000000'}}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          itemN:{ font:{color:{rgb:'1F2A37'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          subL:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'37475A'},bold:true}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          subN:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'137A6C'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          dtotL:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          dtotN:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'} },
          grandL:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grandN:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:14}, alignment:{horizontal:'right',vertical:'center'} }
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rows=[];
        meta.forEach(function(ty,r){ var h=null;
          if(ty==='title'){ put(r,0,S.title); h=26; }
          else if(ty==='date'){ put(r,0,S.date); h=24; }
          else if(ty==='datehdr'){ put(r,0,S.datehdr); h=22; }
          else if(ty==='head'){ for(var c=0;c<COLS;c++) put(r,c,S.head); h=20; }
          else if(ty==='bizsub'){ put(r,0,S.za); put(r,1,S.subL); put(r,2,S.subL); put(r,3,S.subL); put(r,4,S.subN); h=18; }
          else if(ty==='item'){ put(r,0,S.za); put(r,1,S.itemCB); put(r,2,S.itemCB); put(r,3,S.itemL); put(r,4,S.itemN); }
          else if(ty==='dtot'){ for(var c4=0;c4<COLS-1;c4++) put(r,c4,S.dtotL); put(r,COLS-1,S.dtotN); h=21; }
          else if(ty==='grand'){ for(var c3=0;c3<COLS-1;c3++) put(r,c3,S.grandL); put(r,COLS-1,S.grandN); h=22; }
          rows.push(h!=null?{hpt:h}:{});
        });
        ws['!rows']=rows;
      }
      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, mode==='daily'?'사업장별품목_일자별':'사업장별품목_합계');
      LIB.writeFile(wb, '사업장별품목_'+(mode==='daily'?'일자별_':'합계_')+(from||'')+((to&&to!==from)?'~'+to:'')+'.xlsx');
      d2Toast('📥 사업장별 품목합계 '+(mode==='daily'?'일자별':'')+' 엑셀 저장 완료 · '+dlab);
    });
  }

  // ── 출고장별 품목 엑셀 출력 — 출고장 그룹 + 품목코드 합산 (좌측 출고장 세로병합, 사업장별 출력과 동일 레이아웃)
  function d2DownloadByZoneItem(mode){
    mode=(mode==='daily')?'daily':'sum';
    var p=null;
    try{ if(window.parent && window.parent!==window && window.parent.ssLoadStyleXlsx) p=window.parent; }catch(e){}
    if(!p){ d2Toast('⚠️ 물류관리 메인(사이드바) 안에서 열었을 때만 동작합니다.'); return; }
    p.ssLoadStyleXlsx(function(XLSXS){
      var LIB = XLSXS || p.XLSX;
      var styled = !!XLSXS;
      if(!LIB){ d2Toast('⚠️ 엑셀 모듈을 불러오지 못했습니다(인터넷 필요).'); return; }
      var from=(document.getElementById('d2DateFrom')||{}).value||'';
      var to=(document.getElementById('d2DateTo')||{}).value||'';
      var dlab=(from&&from===to)?from:(from+' ~ '+to);

      var COLS=5, aoa=[], merges=[], meta=[], grandAll=0, madeAll=0;   // [출고장, No, 품목코드, 품목명, 출고수량]
      function mergeRow(ri,e){ merges.push({s:{r:ri,c:0}, e:{r:ri,c:(e==null?COLS-1:e)}}); }
      function push(row,ty,mEnd){ aoa.push(row); meta.push(ty); if(mEnd!=null) mergeRow(aoa.length-1,mEnd); }
      push(['출고장별 품목합계'+(mode==='daily'?' (일자별)':' (기간 합계)')],'title',COLS-1);
      push(['출고일자  '+dlab],'date',COLS-1);
      push([],'blank');
      function buildZoneSection(zones, dateHdr){
        if(!zones.length) return;
        if(dateHdr) push(['📅 '+dateHdr+' 출고'],'datehdr',COLS-1);
        push(['출고장','No','품목코드','품목명','출고수량'],'head');
        var gp=d2GroupZones(zones), sub=0;
        gp.order.forEach(function(g){
          var zs=gp.groups[g], gtot=0; zs.forEach(function(z){ gtot+=z.tot; });
          push(['🏬 '+g+'  ('+zs.length+'개 출고장)', '', '', '', gtot], 'grphdr', COLS-2);   // 대표그룹(오산센터) 밴드
          zs.forEach(function(z){
            var startR=aoa.length;   // 출고장 좌측 병합 시작 = 소계 행
            var zlab=z.zone+(z.dcCd?(' ('+z.dcCd+')'):'');
            push([zlab, '소계', '', '(품목 '+z.items.length+'종)', z.tot], 'bizsub');
            z.items.forEach(function(r,ix){ push(['', ix+1, r.code, r.name, r.qty], 'item'); });
            var endR=aoa.length-1;
            if(endR>startR) merges.push({s:{r:startR,c:0}, e:{r:endR,c:0}});   // 출고장 A열 세로 병합
            madeAll++;
          });
          sub+=gtot;
        });
        if(dateHdr) push(['📅 '+dateHdr+' 합계','','','',sub],'dtot',COLS-2);
        grandAll+=sub;
      }
      if(mode==='daily'){
        var dset={}; (D2_DATA||[]).forEach(function(r){ var d=r.date||D2_TODAY; if(from&&d<from)return; if(to&&d>to)return; dset[d]=1; });
        Object.keys(dset).sort().forEach(function(d){
          var rowsD=D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; });
          buildZoneSection(d2ZoneItemsFromAg(d2Aggregate(rowsD, d, d)), d);
        });
      } else {
        buildZoneSection(d2ZoneItemsFromAg(d2Aggregate()), null);
      }
      if(!madeAll){ d2Toast('⚠️ 출고량이 있는 출고장이 없습니다.'); return; }
      push(['전체 합계','','','',grandAll],'grand',COLS-2);

      var ws=LIB.utils.aoa_to_sheet(aoa);
      ws['!cols']=[{wch:26},{wch:5},{wch:16},{wch:44},{wch:11}];   // 출고장·No·품목코드·품목명·출고수량
      ws['!merges']=merges;
      if(styled){
        var enc=LIB.utils.encode_cell;
        var LINE={style:'thin', color:{rgb:'A9B7B1'}}; var box={top:LINE,bottom:LINE,left:LINE,right:LINE};
        var S={
          title:{ fill:{fgColor:{rgb:'178074'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          date:{ font:{color:{rgb:'1F2A37'},bold:true,sz:15}, alignment:{horizontal:'left',vertical:'center'} },
          datehdr:{ fill:{fgColor:{rgb:'11161D'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:13}, alignment:{horizontal:'left',vertical:'center'} },
          grphdr:{ fill:{fgColor:{rgb:'0E6657'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grphdrN:{ fill:{fgColor:{rgb:'0E6657'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:12}, alignment:{horizontal:'right',vertical:'center'} },
          za:{ fill:{fgColor:{rgb:'E3EFEC'}}, font:{color:{rgb:'0E6657'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center',wrapText:true}, border:box },
          head:{ fill:{fgColor:{rgb:'E3F4EF'}}, font:{color:{rgb:'137A6C'},bold:true}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemCB:{ font:{color:{rgb:'000000'}}, alignment:{horizontal:'center',vertical:'center'}, border:box },
          itemL:{ font:{color:{rgb:'10161D'}}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          itemN:{ font:{color:{rgb:'1F2A37'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          subL:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'37475A'},bold:true}, alignment:{horizontal:'left',vertical:'center'}, border:box },
          subN:{ fill:{fgColor:{rgb:'F4F8F7'}}, font:{color:{rgb:'137A6C'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'}, border:box },
          dtotL:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          dtotN:{ fill:{fgColor:{rgb:'20415A'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:13}, alignment:{horizontal:'right',vertical:'center'} },
          grandL:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'FFFFFF'},bold:true,sz:12}, alignment:{horizontal:'left',vertical:'center'} },
          grandN:{ fill:{fgColor:{rgb:'1F2A37'}}, font:{color:{rgb:'AEF0E7'},bold:true,sz:14}, alignment:{horizontal:'right',vertical:'center'} }
        };
        function put(r,c,st){ var ref=enc({r:r,c:c}); if(!ws[ref]) ws[ref]={t:'s',v:''}; ws[ref].s=st; }
        var rows=[];
        meta.forEach(function(ty,r){ var h=null;
          if(ty==='title'){ put(r,0,S.title); h=26; }
          else if(ty==='date'){ put(r,0,S.date); h=24; }
          else if(ty==='datehdr'){ put(r,0,S.datehdr); h=22; }
          else if(ty==='grphdr'){ for(var cg=0;cg<COLS-1;cg++) put(r,cg,S.grphdr); put(r,COLS-1,S.grphdrN); h=20; }
          else if(ty==='head'){ for(var c=0;c<COLS;c++) put(r,c,S.head); h=20; }
          else if(ty==='bizsub'){ put(r,0,S.za); put(r,1,S.subL); put(r,2,S.subL); put(r,3,S.subL); put(r,4,S.subN); h=18; }
          else if(ty==='item'){ put(r,0,S.za); put(r,1,S.itemCB); put(r,2,S.itemCB); put(r,3,S.itemL); put(r,4,S.itemN); }
          else if(ty==='dtot'){ for(var c4=0;c4<COLS-1;c4++) put(r,c4,S.dtotL); put(r,COLS-1,S.dtotN); h=21; }
          else if(ty==='grand'){ for(var c3=0;c3<COLS-1;c3++) put(r,c3,S.grandL); put(r,COLS-1,S.grandN); h=22; }
          rows.push(h!=null?{hpt:h}:{});
        });
        ws['!rows']=rows;
      }
      var wb=LIB.utils.book_new();
      LIB.utils.book_append_sheet(wb, ws, mode==='daily'?'출고장별품목_일자별':'출고장별품목_합계');
      LIB.writeFile(wb, '출고장별품목_'+(mode==='daily'?'일자별_':'합계_')+(from||'')+((to&&to!==from)?'~'+to:'')+'.xlsx');
      d2Toast('📥 출고장별 품목합계 '+(mode==='daily'?'일자별':'')+' 엑셀 저장 완료 · '+dlab);
    });
  }

  // 업로드/저장 후 데시보드2로 돌아와 클릭하면(포커스 복귀) 자동 재조회 — 최신 데이터 반영 (3초 스로틀)
  var _d2FocusTm=0;
  window.addEventListener('focus', function(){
    var now=new Date().getTime();
    if(now-_d2FocusTm<3000) return;
    _d2FocusTm=now;
    if(D2_UP || D2_SRC) d2Load();
  });

  // ── 대표출고장(물류센터) 다중선택 콤보 — 체크 토글, 전체 클릭 시 선택 해제
  function d2DcToggle(g){ if(D2_DCSEL[g]) delete D2_DCSEL[g]; else D2_DCSEL[g]=1; d2Render(); }
  function d2DcAllSel(){ D2_DCSEL={}; d2Render(); }
  function d2DcOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('d2DcPop'); if(p) p.classList.toggle('open'); }
  document.addEventListener('click', function(e){
    [['d2DcWrap','d2DcPop'],['d2GordWrap','d2GordPop']].forEach(function(pair){
      var w=document.getElementById(pair[0]), p=document.getElementById(pair[1]);
      if(p && p.classList.contains('open') && w && !w.contains(e.target)) p.classList.remove('open');
    });
  });

  // ── 출고장 그룹(물류센터) 순서 설정 — ▲▼로 이동, localStorage 저장(수정 전까지 고정)
  function d2GordOpen(ev){ if(ev) ev.stopPropagation(); var p=document.getElementById('d2GordPop'); if(p) p.classList.toggle('open'); }
  function d2GordMove(g, dir){
    var base=(window._d2GOrderNow||[]).slice();     // 현재 화면 표시 순서 기준으로 스왑
    var i=base.indexOf(g), j=i+dir;
    if(i<0 || j<0 || j>=base.length) return;
    var tmp=base[i]; base[i]=base[j]; base[j]=tmp;
    D2_GORD=base; d2GordSave(); d2Render();
  }
  function d2GordReset(){ D2_GORD=[]; d2GordSave(); d2Render(); }
  // 데시보드1(부모)에서 순서를 바꾸면 즉시 반영 (같은 출처 localStorage 공유)
  window.addEventListener('storage', function(e){ if(e.key==='logiGroupOrder'){ d2GordLoad(); d2Render(); } });

  // ── 사업장/품목 찾기 / 줌 / 전체화면
  function d2BizFindSet(v){ D2_FIND=(''+(v||'')).trim(); d2Render(); }
  function d2ItemFindSet(v){ D2_IFIND=(''+(v||'')).trim(); d2Render(); }
  function d2FindClear(){
    D2_FIND=''; D2_IFIND='';
    var e=document.getElementById('d2BizFind'); if(e) e.value='';
    var e2=document.getElementById('d2ItemFind'); if(e2) e2.value='';
    d2Render();
  }
  /* 가로표(.d2-mx)도 같이 확대/축소 — 안 넣으면 가로표에서 🔍＋가 먹통이다(2026-08-28) */
  function d2ApplyZoom(){ var ts=document.querySelectorAll('table.d2-tb, table.d2-mx'); for(var i=0;i<ts.length;i++) ts[i].style.zoom=(D2_ZOOM/100); d2Set('d2ZoomLbl', D2_ZOOM+'%'); }
  function d2ZoomIn(){ if(D2_ZOOM<200) D2_ZOOM+=10; d2ApplyZoom(); }
  function d2ZoomOut(){ if(D2_ZOOM>40) D2_ZOOM-=10; d2ApplyZoom(); }
  function d2FullExpand(){ document.getElementById('d2Card').classList.add('d2-full'); }
  function d2FullExit(){ document.getElementById('d2Card').classList.remove('d2-full'); D2_ZOOM=100; d2ApplyZoom(); }

  // ── 출고장 접기/펼치기 (개별 + 물류센터 그룹 + 전체)
  function d2ToggleZone(zn){ if(D2_COLL[zn]) delete D2_COLL[zn]; else D2_COLL[zn]=1; d2Render(); }
  function d2ToggleGroup(g){ if(D2_GCOLL[g]) delete D2_GCOLL[g]; else D2_GCOLL[g]=1; d2Render(); }
  // 상단 접기/펼치기 — 도구줄(.d2-toolbar) + 안내줄(.d2-topbar)만 접는다. 대시보드(ssTbFold)와 같은 규칙.
  //  · ★제목줄(.d2-head = 출고일자·조회·요약숫자·엑셀 업로드)은 접지 않는다 (2026-08-28 「해당라인의 제외」 — CSS 주석 참고).
  //  · ★단추는 이 화면 안에 없다 — 셸 맨 위 줄의 [조회조건 접기](konetTbFold)가 여기 d2TbFold 를 부른다.
  //    (2026-08-28: 제목줄에 두었더니 좁은 창에서 잘려 못 눌렀다. 이 화면은 iframe 이라 제 폭을 못 넓힌다)
  //  · 조회바는 #d2Card 밖(형제)이라 body 클래스로 감춘다.
  //  · 저장키는 종전 그대로 konetD2TbFold — 이미 접어 둔 사용자는 다음 접속에 접힌 상태로 열린다.
  function d2TbFoldSet(on){
    var c=document.getElementById('d2Card'); if(!c) return;
    c.classList.toggle('tb-fold', !!on);
    document.body.classList.toggle('tb-fold', !!on);
    try{ localStorage.setItem('konetD2TbFold', on?'1':''); }catch(e){}
    // 셸 단추의 글자(접기 ↔ 펼치기)를 맞춰 준다. 셸 밖에서 단독으로 열려도 조용히 넘어간다.
    try{ if(window.parent && window.parent!==window && window.parent.konetTbFoldSync) window.parent.konetTbFoldSync(!!on); }catch(e){}
  }
  function d2TbFold(){ var c=document.getElementById('d2Card'); d2TbFoldSet(!(c&&c.classList.contains('tb-fold'))); }
  // 접힘·펼침 어느 쪽이든 부른다 — 셸 단추 글자까지 이때 맞춰지므로 '펼침'도 그냥 지나가면 안 된다.
  window.addEventListener('load', function(){ var on=false; try{ on = localStorage.getItem('konetD2TbFold')==='1'; }catch(e){} d2TbFoldSet(on); });

  function d2ToggleAllZones(){
    var ag=d2Aggregate();
    // 렌더(zonesWithItems)와 동일 기준 — 활성행 없이 '삭제행'만 있는 출고장도 접기 대상에 포함
    var zs=ag.zoneOrder.filter(function(zn){ var z=ag.zones[zn]; return Object.keys(z.rows).length>0 || (z.delRows&&z.delRows.length>0); });
    var allColl = zs.length>0 && zs.every(function(zn){ return !!D2_COLL[zn]; });
    D2_COLL={}; D2_GCOLL={};
    if(!allColl) zs.forEach(function(zn){ D2_COLL[zn]=1; });
    d2Render();
  }

  function d2Today(){ document.getElementById('d2DateFrom').value=D2_TODAY; document.getElementById('d2DateTo').value=D2_TODAY; d2Load(); }
  function d2Month(){
    var d=new Date(), y=d.getFullYear(), m=d.getMonth(), last=new Date(y,m+1,0).getDate();
    document.getElementById('d2DateFrom').value=y+'-'+d2Pad(m+1)+'-01';
    document.getElementById('d2DateTo').value=y+'-'+d2Pad(m+1)+'-'+d2Pad(last);
    d2Load();   // 당월=기간 조회 → 출고일자별 독립 블록으로 표시
  }
  // 전체 — 출고일자 무관 DB 전체를 출고일자별 블록으로 (날짜칸 비우고 조회)
  function d2All(){
    var f=document.getElementById('d2DateFrom'), t=document.getElementById('d2DateTo');
    if(f) f.value=''; if(t) t.value='';
    d2Load();
  }

  // ── 대표사업장 판정 (데시보드1 ssRowBrand 동일): 사업장코드→TBL_BIZI_MST 매핑, 없으면 품목명 () 접두어
  function d2Brand(r){
    var bc=(''+((r&&r.bizCode)||'')).trim();
    if(bc && D2_BIZI[bc]) return D2_BIZI[bc];
    var m=/^\(([^)]+)\)/.exec((r&&r.item)||'');
    return m?m[1]:'기타·공통';
  }
  // TBL_BIZI_MST 조회 → D2_BIZI{사업장코드:대표사업장명}
  function d2LoadBizi(cb){
    fetch(CTX+'/shipout/selectBiziMst.do', { method:'POST', credentials:'same-origin' })
    .then(function(res){ return res.text(); })
    .then(function(txt){
      try{ var j=JSON.parse(txt); var m={}, mt={};
        (j.data||[]).forEach(function(o){
          var c=(''+(o.bizCd||'')).trim(); if(!c) return;
          m[c]=(''+(o.bizNm||'')).trim();
          /* 공통 매칭 (2026-08-28) — 이름이 비면 코드라도 쓴다. 둘 다 비면 담지 않는다
             = 그 사업장은 <매칭 없음> 이고, 가로표에서 원래 사업장 이름 그대로 나온다. */
          var mn=(''+(o.matchNm||'')).trim() || (''+(o.matchCd||'')).trim();
          if(mn) mt[c]=mn;
        });
        D2_BIZI=m; D2_BIZMT=mt; }
      catch(e){}
      if(cb) cb();
    })
    .catch(function(){ if(cb) cb(); });
  }

  // ── DB 조회: 단일 일자(시작=종료)만 조회. 기간 모드는 현재 데이터로 렌더만. (데시보드1과 동일 규칙)
  // ── 대시보드1↔2 출고일자 조건 동기화 (localStorage 'logiShipDate' 공유 + storage 이벤트) ──
  var _d2DateSyncing=false;
  function d2SaveSharedDate(){
    try{ localStorage.setItem('logiShipDate', JSON.stringify({
      from:(document.getElementById('d2DateFrom')||{}).value||'',
      to:(document.getElementById('d2DateTo')||{}).value||'' })); }catch(e){}
  }
  function d2ApplySharedDate(){   // 저장된 공유 날짜 적용(있으면 true)
    try{ var d=JSON.parse(localStorage.getItem('logiShipDate')||'null'); if(!d) return false;
      var f=document.getElementById('d2DateFrom'), t=document.getElementById('d2DateTo');
      if(f && d.from!=null) f.value=d.from; if(t && d.to!=null) t.value=d.to; return true;
    }catch(e){ return false; }
  }
  window.addEventListener('storage', function(e){   // 대시보드1에서 날짜 바꾸면 따라가기
    if(e.key!=='logiShipDate') return;
    try{ var d=JSON.parse(e.newValue||'null'); if(!d) return;
      var f=document.getElementById('d2DateFrom'), t=document.getElementById('d2DateTo'); if(!f||!t) return;
      if(f.value===(d.from||'') && t.value===(d.to||'')) return;
      _d2DateSyncing=true; f.value=d.from||''; t.value=d.to||''; d2Load(); _d2DateSyncing=false;
    }catch(_){}
  });
  /* ── 날짜칸 자동조회 끄기 (2026-08-28 요청 「날짜 선택하면 자동검색인데 조회버튼 실행해야 되게」) ──
       날짜칸의 onchange 는 이제 조회를 부르지 않고 <조회를 눌러 달라는 표시>만 켠다.
       ⚠표시를 반드시 두는 이유 : 자동조회를 끄면 「바꾼 날짜」와 「화면의 표」가 다른 시간이 생긴다.
         표시가 없으면 옛 자료를 새 날짜의 자료로 잘못 읽는다.
       ※값을 코드로 넣는 곳(당일·당월·전체·공유날짜 복원)은 change 가 안 도므로 표시도 안 켜진다 — 그대로 두면 된다. */
  function d2DateDirty(){
    var b=document.getElementById('d2BtnSearch'); if(b) b.classList.add('need');
    var m=document.getElementById('d2NeedMsg');   if(m) m.style.display='inline';
  }
  function d2DateClean(){
    var b=document.getElementById('d2BtnSearch'); if(b) b.classList.remove('need');
    var m=document.getElementById('d2NeedMsg');   if(m) m.style.display='none';
  }
  /* ── 조회 기간 제한 : 최대 3개월 (2026-08-28 요청 「3달 이상은 조회 안되게」) ──────────
       왜 : 기간 조회는 날짜별 블록을 전부 그린다. 몇 달치를 한 번에 부르면 DB·화면이 함께 느려지고,
            실제로 그렇게 넓게 보는 일도 없다(월 단위로 본다).
       기준 : 시작 + 3개월 <보다 뒤>면 막는다 — 딱 3개월(1/16 ~ 4/16)까지는 된다.
       ⚠[전체]는 날짜를 <비우고> 부르는 별도 경로다 — 여기 걸리지 않는다(f·t 가 비면 통과).
       막을 때 [조회]의 강조는 그대로 둔다 — 아직 조회가 안 됐다는 표시라서. */
  var D2_MAX_MONTHS = 3;
  function d2RangeTooLong(){
    var f=(document.getElementById('d2DateFrom')||{}).value||'';
    var t=(document.getElementById('d2DateTo')||{}).value||'';
    if(!f || !t || f > t) return null;                       // 전체·빈값·뒤집힌 값은 여기서 다루지 않는다
    var a=new Date(f+'T00:00:00'), b=new Date(t+'T00:00:00');
    var lim=new Date(a.getFullYear(), a.getMonth()+D2_MAX_MONTHS, a.getDate());
    if(b<=lim) return null;
    return { from:f, to:t, days:Math.round((b-a)/86400000)+1 };
  }
  function d2Load(){
    var over=d2RangeTooLong();
    if(over){
      d2Toast('⚠️ 조회 기간은 <b>최대 '+D2_MAX_MONTHS+'개월</b>입니다.<br>지금 고른 기간 '+over.from+' ~ '+over.to+' ('+over.days+'일) 은 너무 깁니다 — 출고일자를 줄여 주세요.');
      d2LoadingOff();
      return;
    }
    d2DateClean(); d2LoadingOn(); if(!_d2DateSyncing) d2SaveSharedDate(); _d2LoadInner();
  }   // 조회 시작(분류표는 안에서 병렬 조회) + 날짜 공유 저장
  // ★속도 개선(2026-07-31): 종전엔 분류표→출고→직전배치→차수이력 4건을 순차 호출해 최초 진입이
  //   합산 지연(운영 실측 약 0.5+0.7+2.2+1.3 ≈ 4.8초)이었다 → 4건을 병렬로 던지고 전부 도착하면 1회 렌더.
  //   체감 대기 = 가장 느린 1건(직전배치 ≈ 2.2초) 수준. 쿼리·서버는 무변경(JSP만).
  function _d2LoadInner(){
    var f=(document.getElementById('d2DateFrom')||{}).value||'';
    var t=(document.getElementById('d2DateTo')||{}).value||'';
    // 단일일자(시작=종료)=기존 배치 매트릭스 경로. 그 외(기간·전체)=날짜별 독립 블록 경로.
    _d2PerfStart();
    if(!(f && f===t)){ _d2LoadRange(f, t); return; }
    var _body='shpoutDt='+encodeURIComponent(f);
    var pBizi=new Promise(function(done){ d2LoadBizi(done); });   // 분류표(TBL_BIZI_MST) — 렌더 전까지만 도착하면 됨
    // 현재 배치 — 실패 시에도 렌더는 한 번만(전부 도착 후). 오류 문구/토스트는 종전과 동일.
    var pMst=fetch(CTX+'/shipout/selectShipoutMst.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin', body:_body
    })
    .then(function(res){ return res.text().then(function(txt){ return {status:res.status, ok:res.ok, txt:txt}; }); })
    .then(function(r){
      if(!r.ok){ D2_SRC='⚠️ DB 조회 HTTP '+r.status; D2_UP=false; D2_DATA=[]; d2Toast('⚠️ 출고 조회 실패 (HTTP '+r.status+')'); return; }
      var j; try{ j=JSON.parse(r.txt); }catch(e){ D2_SRC='⚠️ 응답형식 오류'; D2_UP=false; D2_DATA=[]; d2Toast('⚠️ 조회 응답이 JSON이 아닙니다'); return; }
      var rows=(j&&j.data)||[];
      D2_DATA = rows.map(function(o){ return d2MapRow(o, f); });
      D2_UP = rows.length>0;
      D2_SRC = rows.length>0 ? ('🗄️ DB 조회 '+f+' · '+rows.length+'건') : ('🗄️ DB '+f+' — 데이터 없음');
      D2_COLL={};
    })
    .catch(function(e){ D2_SRC='⚠️ DB 통신오류'; D2_UP=false; D2_DATA=[]; d2Toast('⚠️ 출고 조회 통신오류: '+e.message); });
    // 직전 배치(이력) — 실패해도 현재본은 그대로 표시
    var pPrev=fetch(CTX+'/shipout/selectShipoutPrev.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin', body:_body
    })
    .then(function(res){ return res.ok?res.text():''; })
    .then(function(txt){ var pj; try{ pj=JSON.parse(txt); }catch(e){ pj=null; }
      var prows=(pj&&pj.data)||[]; D2_PREV=prows.map(function(o){ return d2MapRow(o, f); }); })
    .catch(function(){ D2_PREV=[]; });
    // 차수 매트릭스용 전 배치(모든 출고장)
    var pHist=fetch(CTX+'/shipout/selectShipoutHistAll.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin', body:_body
    })
    .then(function(res){ return res.ok?res.text():''; })
    .then(function(txt){ var hj; try{ hj=JSON.parse(txt); }catch(e){ hj=null; }
      var hrows=(hj&&hj.data)||[]; D2_HISTALL=hrows.map(function(o){ return d2MapRow(o, f); }); })
    .catch(function(){ D2_HISTALL=[]; });
    Promise.all([pBizi, pMst, pPrev, pHist]).then(function(){ _d2Perf('단일일자 '+f); d2Render(); _d2PerfDraw(); });
  }

  /* ── 속도 계측 (2026-08-07 요청) ──────────────────────────────────
       이 화면은 조회 4개(분류표·현재배치·직전배치·차수이력)를 **동시에** 부르고
       전부 도착한 뒤 한 번만 그린다. 그래서 체감 시간 = **가장 느린 조회 하나**다.
       어느 조회가 발목을 잡는지 모르면 엉뚱한 곳을 고치게 되므로, 넷을 따로 잰다.
       F12 콘솔에 [출고현황표] 로 찍힌다. */
  var _d2T0=0, _d2Mark={};
  function _d2PerfStart(){
    _d2T0=(window.performance&&performance.now)?performance.now():0; _d2Mark={};
    /* fetch 를 잠깐 감싸 각 조회의 왕복 시간을 잰다 — 원래 호출부는 손대지 않는다 */
    if(window._d2FetchWrapped) return; window._d2FetchWrapped=true;
    var of=window.fetch;
    window.fetch=function(u,o){
      var nm=String(u||'').split('/').pop().split('?')[0];
      if(nm.indexOf('.do')<0) return of.apply(this,arguments);
      var t=(window.performance&&performance.now)?performance.now():0;
      return of.apply(this,arguments).then(function(r){
        var e=(window.performance&&performance.now)?performance.now():0;
        _d2Mark[nm]=Math.round(e-t); return r;
      });
    };
  }
  function _d2Perf(lab){
    if(!window.console||!console.log) return;
    var t=(window.performance&&performance.now)?performance.now():0;
    var parts=[], mx=0;
    for(var k in _d2Mark){ parts.push(k.replace('.do','')+' '+_d2Mark[k]+'ms'); if(_d2Mark[k]>mx) mx=_d2Mark[k]; }
    /* ★'조회합계'는 벽시계가 아니라 **가장 느린 조회**로 잡는다 —
         넷을 동시에 부르므로 체감 시간은 합이 아니라 최댓값이고,
         벽시계로 재면 렌더 경로에 따라 0ms 같은 엉뚱한 값이 찍힌다(2026-08-07 관찰). */
    console.log('[출고현황표] '+lab+' · 가장느린조회 '+mx+'ms'
      +(parts.length?(' · '+parts.join(' / ')):'')+' · 행 '+(D2_DATA?D2_DATA.length:0)+'건');
    _d2T0=t;   // 여기서부터는 그리기 시간
  }
  function _d2PerfDraw(){
    if(!window.console||!console.log||!_d2T0) return;
    var t=(window.performance&&performance.now)?performance.now():0;
    console.log('[출고현황표] 그리기 '+Math.round(t-_d2T0)+'ms');
    _d2T0=0;
  }

  // 기간/전체 조회 — 날짜별 독립 블록용. (직전배치는 단일일자 전용이라 생략)
  //  ★속도 개선(2026-07-31): 출고·차수이력·분류표를 병렬 조회 후 1회 렌더(단일일자 경로와 동일 방침).
  function _d2LoadRange(f, t){
    _d2PerfStart();
    var body, lab;
    if(f && t){ body='shpoutDtFrom='+encodeURIComponent(f)+'&shpoutDtTo='+encodeURIComponent(t); lab=f+' ~ '+t; }
    else      { body=''; lab='전체(전 기간)'; }   // 날짜 비우면 전 기간
    var pBizi=new Promise(function(done){ d2LoadBizi(done); });
    var pMst=fetch(CTX+'/shipout/selectShipoutMst.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin', body:body
    })
    .then(function(res){ return res.text().then(function(txt){ return {ok:res.ok, status:res.status, txt:txt}; }); })
    .then(function(r){
      if(!r.ok){ D2_SRC='⚠️ DB 조회 HTTP '+r.status; D2_UP=false; D2_DATA=[]; d2Toast('⚠️ 출고 조회 실패 (HTTP '+r.status+')'); return; }
      var j; try{ j=JSON.parse(r.txt); }catch(e){ D2_SRC='⚠️ 응답형식 오류'; D2_UP=false; D2_DATA=[]; d2Toast('⚠️ 조회 응답이 JSON이 아닙니다'); return; }
      var rows=(j&&j.data)||[];
      D2_DATA = rows.map(function(o){ return d2MapRow(o, f); });
      D2_UP = rows.length>0;
      var nd={}; D2_DATA.forEach(function(x){ nd[x.date]=1; });
      D2_SRC = rows.length>0 ? ('🗄️ DB 조회 '+lab+' · '+rows.length+'건 · '+Object.keys(nd).length+'일') : ('🗄️ DB '+lab+' — 데이터 없음');
      D2_COLL={};
    })
    .catch(function(e){ D2_SRC='⚠️ DB 통신오류'; D2_UP=false; D2_DATA=[]; d2Toast('⚠️ 출고 조회 통신오류: '+e.message); });
    // 배치이력(현재/직전 차수) 기간 조회 → 날짜별 블록에서 각 날짜로 필터해 사용 (단일일자와 동일 로직)
    var pHist=fetch(CTX+'/shipout/selectShipoutHistAll.do', {
      method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, credentials:'same-origin', body:body
    })
    .then(function(res){ return res.ok?res.text():''; })
    .then(function(txt){ var hj; try{ hj=JSON.parse(txt); }catch(e){ hj=null; }
      var hrows=(hj&&hj.data)||[]; D2_HISTALL=hrows.map(function(o){ return d2MapRow(o, f); }); })
    .catch(function(){ D2_HISTALL=[]; });
    D2_PREV=[];   // 신규/삭제 비교는 기간 모드에서 생략(종전과 동일)
    Promise.all([pBizi, pMst, pHist]).then(function(){ _d2Perf(lab); d2Render(); _d2PerfDraw(); });
  }
  // DB행 → 화면행 매핑(현재/직전 공용). date = 행의 실제 출고일자(SHPOUT_DT) — 기간조회 시 날짜별 분리에 사용
  // 화면 표시용 물류센터 그룹 치환 — 특정 물류센터코드는 하나의 대표그룹으로 묶어 표시(DB 저장은 무관)
  var D2_DCGROUP={ 'E200':'오산센터', 'E400':'오산센터', 'E300':'오산센터', 'E600':'오산센터', 'E700':'오산센터' };   // E600=제주
  // 오산센터 그룹 내 출고장 표시 순서 (E600=제주, E300과 E700 사이)
  var D2_ZONEORDER=['E200','E400','E300','E600','E700'];
  function d2ZoneRank(ag, zn){
    var z=ag.zones[zn]; var cd=(z&&z.dcCd)||'';
    var i=D2_ZONEORDER.indexOf(cd);
    if(i<0 && /제주/.test(zn)) i=D2_ZONEORDER.indexOf('E600');   // 이름에 제주 있으면 E600 위치로(코드 누락 대비)
    return i<0 ? 999 : i;
  }
  function d2ZonesSorted(ag){   // 지정 순서 우선, 나머지는 이름순
    return ag.zoneOrder.slice().sort(function(a,b){
      var ra=d2ZoneRank(ag,a), rb=d2ZoneRank(ag,b);
      if(ra!==rb) return ra-rb;
      var c=d2CenterNm(a).localeCompare(d2CenterNm(b),'ko'); if(c!==0) return c;   // rank 동률이면 센터끼리 묶어야 소계가 안 갈라진다
      var ja=/\s직송$/.test(a)?1:0, jb=/\s직송$/.test(b)?1:0;
      if(ja!==jb) return ja-jb;   // 직송 줄은 센터 블록 맨 아래(2026-08-30)
      return a.localeCompare(b,'ko');
    });
  }
  /* 낱알 → 물류센터명 (끝 ' 직송'·숫자 떼기) — 가로표 센터 소계용 전역판.
     ⚠같은 식이 d2BuildTableInner(d2CenterOf)·엑셀(d2CenterOfX)에도 지역함수로 있다 — 규칙 바꾸면 셋 다. */
  function d2CenterNm(zn){ return (''+zn).replace(/\s*직송$/,'').replace(/\s*\d+\s*$/,'').trim(); }
  /* 배송/직송 나눔 라벨 — 합계 줄 이름 뒤에 「(배송 X · 직송 Y)」 (2026-08-30 「배송직송 합계표시 출고장별」).
     직송이 없는 센터는 빈 문자열(표시 없음 — 전부 배송이라 나눌 것이 없다). */
  function d2BdxLabel(delSum, jikSum){
    if(!(jikSum>0)) return '';
    return ' <span style="font-weight:600;font-size:.92em">(배송 '+d2Num(delSum)+' · <span class="jkw">직송</span> '+d2Num(jikSum)+')</span>';
  }
  function d2MapRow(o, f){
    var dcNm=(''+(o.dcNm||'')).trim(), inwh=(''+(o.inwh||'')).trim();
    /* ★배송/직송 구분 (2026-08-30) — 데시보드2(logi-oh.js SHIP_DATA 매핑)와 같은 규칙.
       직송 행(ZONE 또는 배송구분='직송')은 '물류센터명 직송' 낱알로 따로. */
    var _rz=(''+(o.zone||'')).trim(), _jk=(_rz==='직송'||(''+(o.dlvGb||'')).trim()==='직송');
    var zone = dcNm ? (dcNm+(_jk?' 직송':inwh)) : _rz;
    var bizNm=(''+(o.bizNm||'')).trim(), bizCd=(''+(o.bizCd||'')).trim();
    var bizLbl = bizCd ? (bizNm ? (bizNm+' ['+bizCd+']') : ('['+bizCd+']')) : bizNm;
    var _dlv=(''+(o.dlvDt||'')).trim(); if(/^\d{8}$/.test(_dlv)) _dlv=_dlv.slice(0,4)+'-'+_dlv.slice(4,6)+'-'+_dlv.slice(6,8);
    var _sd=(''+(o.shpoutDt||'')).trim(); if(/^\d{8}$/.test(_sd)) _sd=_sd.slice(0,4)+'-'+_sd.slice(4,6)+'-'+_sd.slice(6,8);
    var _dcCd=(''+(o.dcCd||'')).trim();
    var _grp=D2_DCGROUP[_dcCd] || (/제주/.test(dcNm) ? '오산센터' : dcNm);   // E200/E400/E300/E700 + 제주(이름) → '오산센터' 그룹
    return { code:(''+(o.itemCd||'')).trim(), item:(''+(o.itemNm||'')).trim(),
             biz:bizLbl, bizCode:bizCd, dc:_grp, dcCd:_dcCd, inwh:inwh, zone:zone, qty:(+o.curQty||0), dlvDt:_dlv, date:(_sd||f),
             uploadDttm:(''+(o.uploadDttm||'')).trim().slice(0,19),   // 변경일시(현재 배치)
             firstDttm:(''+(o.firstDttm||'')).trim().slice(0,19),     // 최초일시(같은 품목 MIN)
             jobSeq:(+o.jobSeq||0) };   // 배치 버전(1=최초, 2↑=재생성)
  }

  // ── 집계: 출고장별 (사업장+품목) 행 — 출고량 있는 품목만. 사업장 찾기/보기 필터 반영
  function d2Aggregate(rowsIn, fromOv, toOv){
    d2GordLoad();   // 그룹순서 최신값 반영(데시보드1에서 바꾼 것도 즉시 적용)
    var from=(fromOv!=null)?fromOv:((document.getElementById('d2DateFrom')||{}).value||'');
    var to=(toOv!=null)?toOv:((document.getElementById('d2DateTo')||{}).value||'');
    var selEl=document.getElementById('d2BizSel');
    var bizSel=(selEl && selEl.value) ? selEl.value : '__ALL__';
    var findLc=D2_FIND.toLowerCase();
    var ifindTk=D2_IFIND.toLowerCase().split(/\s+/).filter(function(s){ return s; });
    var dcAny=Object.keys(D2_DCSEL).length>0;
    var zones={}, zoneOrder=[], itemSet={}, bizSet={}, bizAll={}, matchAll={}, dcAll={}, zoneAll={}, totQty=0, curDttm='';
    (rowsIn||D2_DATA).forEach(function(r){
      var d=r.date||D2_TODAY;
      if(from && d<from) return;
      if(to && d>to) return;
      if(r.uploadDttm && r.uploadDttm>curDttm) curDttm=r.uploadDttm;   // 현재 배치 업로드(=삭제 발생) 시각
      var dcg=r.dc||r.zone||'미배정';
      dcAll[dcg]=1;                                            // 필터 무관 전체 대표출고장(콤보 목록용)
      /* 개별 출고장도 모은다 — 콤보를 2단(묶음 + 개별)으로 만들기 위해서(2026-08-02 요청).
         ★반드시 '필터 앞'에서 모아야 한다. 걸러진 뒤에 모으면 한 곳을 고른 순간 나머지가 목록에서 사라져 되돌릴 수 없다. */
      if(r.zone){ (zoneAll[dcg]||(zoneAll[dcg]={}))[r.zone]=1; }
      if(r.biz) bizAll[r.biz]=1;                               // 필터 무관 전체 사업장(옵션용)
      /* 매칭명칭도 찾기 후보에 넣는다 — 가로표에 그 이름이 보이는데 자동완성에 없으면 못 찾는다.
         ★사업장 보기 콤보(정확일치)에는 넣지 않는다 — 거기는 원래 사업장 하나를 고르는 자리다. */
      { var _mn=d2MtNm(r); if(_mn && _mn!==r.biz) matchAll[_mn]=1; }
      if(dcAny && !(D2_DCSEL[dcg] || (r.zone && D2_DCSEL[r.zone]))) return;   // 대표출고장/개별 출고장 다중선택(선택 없으면 전체)
      if(bizSel!=='__ALL__' && r.biz!==bizSel) return;         // 사업장 보기(정확일치)
      /* ★찾기는 <매칭명칭으로도> 걸려야 한다 (2026-08-28) —
           가로표 머리줄은 매칭명칭(예: 배고픈덮밥)인데 찾기는 원래 사업장명(파스타입니다…)만 봤다.
           그래서 「화면에 보이는 이름으로 검색하면 안 나오는」 상태였다. 둘 다 훑는다. */
      if(findLc && ((r.biz||'')+' '+d2MtNm(r)).toLowerCase().indexOf(findLc)<0) return;   // 사업장 찾기(부분일치)
      if(ifindTk.length){                                      // 품목 찾기 — 행 전체 LIKE(사업장명+매칭명+품목명+품목코드), 공백 구분 다중 키워드 AND
        var hay=((r.biz||'')+' '+d2MtNm(r)+' '+(r.item||'')+' '+(r.code||'')).toLowerCase();
        for(var ti=0; ti<ifindTk.length; ti++){ if(hay.indexOf(ifindTk[ti])<0) return; }
      }
      var q=+r.qty||0;
      var zn=r.zone||'미배정';
      var z=zones[zn];
      if(!z){ z=zones[zn]={dc:(r.dc||''), dcCd:(r.dcCd||''), inwh:(r.inwh||''), tot:0, dlv:{}, rows:{}, jobSeq:0}; zoneOrder.push(zn); }
      if(!z.dcCd && r.dcCd) z.dcCd=r.dcCd;   // 물류센터코드 — 존 첫 유효값 유지
      if(!z.inwh && r.inwh) z.inwh=r.inwh;   // 입고장 — 출고장(=물류센터+입고장) 매칭용
      if((+r.jobSeq||0)>z.jobSeq) z.jobSeq=(+r.jobSeq||0);   // 배치 버전(최대) — 최초/재생성 판정용
      if(r.dlvDt) z.dlv[r.dlvDt]=1;
      if(q<=0) return;                     // 출고량 있는 품목만 표시(출고장별 출력과 동일)
      z.tot+=q; totQty+=q;
      bizSet[d2Brand(r)]=1;                // 사업장 = 대표사업장(브랜드) 기준 유니크 (데시보드1 KPI와 동일)
      var ik=(r.code?r.code:('NM:'+r.item));
      itemSet[ik]=1;
      var rk=(r.biz||'')+'|'+ik;
      var row=z.rows[rk];
      /* bizCode 를 남긴다 — 가로표가 <사업장 공통 매칭>을 찾을 때 쓴다(2026-08-28). 다른 보기는 안 쓴다. */
      if(!row) row=z.rows[rk]={biz:(r.biz||''), bizCode:(r.bizCode||''), name:r.item, code:r.code, qty:0, uploadDttm:(r.uploadDttm||''), firstDttm:(r.firstDttm||''), ozones:{}};
      row.qty+=q;
      // 원래 출고장 분포 누적(사업장별 뷰에서 품목명 옆 출고장 콤보용, 2026-07-24). origZone 없으면(=출고장별 뷰) 무시
      if(r.origZone){ if(!row.ozones) row.ozones={}; row.ozones[r.origZone]=(row.ozones[r.origZone]||0)+q; }
      if(r.uploadDttm && r.uploadDttm>(row.uploadDttm||'')) row.uploadDttm=r.uploadDttm;   // 변경일시 최신값
      if(r.firstDttm && (!row.firstDttm || r.firstDttm<row.firstDttm)) row.firstDttm=r.firstDttm;   // 최초일시 최소값
    });

    // ── 이력(신규/삭제) — 직전 배치(D2_PREV)와 (출고장+사업장+품목코드)로 대조
    var histC=document.getElementById('d2HistChk');
    // 이력(신규/삭제) 비교는 단일일자(시작=종료)에서만 의미 있음. 기간/역순(시작>종료) 범위에선 끔
    // — 안 그러면 현재행은 날짜필터로 빠지고 직전배치만 남아 전부 '삭제'로 오표시됨
    var histOn = !!(histC && histC.checked && from && from===to && rowsIn==null);   // 단일일자 전역 렌더에서만(날짜별 블록 제외)
    function _pass(r){   // 현재 필터를 삭제행에도 동일 적용
      var dcg=r.dc||r.zone||'미배정';
      if(dcAny && !(D2_DCSEL[dcg] || (r.zone && D2_DCSEL[r.zone]))) return false;
      if(bizSel!=='__ALL__' && r.biz!==bizSel) return false;
      if(findLc && (r.biz||'').toLowerCase().indexOf(findLc)<0) return false;
      if(ifindTk.length){ var hay=((r.biz||'')+' '+(r.item||'')+' '+(r.code||'')).toLowerCase();
        for(var i=0;i<ifindTk.length;i++) if(hay.indexOf(ifindTk[i])<0) return false; }
      return true;
    }
    if(histOn){
      var prevByZone={};
      D2_PREV.forEach(function(r){
        var q=+r.qty||0; if(q<=0) return;
        var zn=r.zone||'미배정';
        var ik=(r.code?r.code:('NM:'+r.item)); var rk=(r.biz||'')+'|'+ik;
        (prevByZone[zn]=prevByZone[zn]||{})[rk]={biz:(r.biz||''), name:r.item, code:r.code, qty:q, dc:(r.dc||''), zone:zn, uploadDttm:(r.uploadDttm||''), firstDttm:(r.firstDttm||'')};
      });
      // 현재 존재하는 출고장: 신규 표시 + 삭제 항목 수집. (최초 배치는 pv 없음 → 판정 보류, 배치 배지로만 표시)
      Object.keys(zones).forEach(function(zn){
        var pv=prevByZone[zn], z=zones[zn]; z.delRows=z.delRows||[];
        z.hasPrev = !!pv;                     // 직전배치 존재 = 재생성 / 없으면 최초 (신규·삭제 비교와 동일 기준)
        if(!pv) return;                       // 직전배치 없는 출고장(최초 포함) = 품목 판정 보류
        Object.keys(z.rows).forEach(function(rk){
          if(!pv[rk]) z.rows[rk].isNew=true;                 // 직전에 없던 품목 = 신규
          else z.rows[rk].prevQty=pv[rk].qty;               // 기존 품목 = 직전 수량 기록(이력 표시)
        });
        Object.keys(pv).forEach(function(rk){ if(!z.rows[rk]){ var pr=pv[rk]; if(_pass(pr)) z.delRows.push(pr); } });   // 이번에 빠진 품목 = 삭제
      });
      // 완전히 사라진 출고장(직전엔 있고 현재 없음)의 삭제 항목도 표시
      Object.keys(prevByZone).forEach(function(zn){
        if(zones[zn]) return;
        var dels=[]; var pv=prevByZone[zn];
        Object.keys(pv).forEach(function(rk){ if(_pass(pv[rk])) dels.push(pv[rk]); });
        if(dels.length){ zones[zn]={dc:(dels[0].dc||''), dcCd:(dels[0].dcCd||''), inwh:(dels[0].inwh||''), tot:0, dlv:{}, rows:{}, delRows:dels, delOnly:true, hasPrev:true}; zoneOrder.push(zn); }
      });
    }

    return {zones:zones, zoneOrder:zoneOrder, histOn:histOn, itemCnt:Object.keys(itemSet).length,
            bizCnt:Object.keys(bizSet).length, bizAll:Object.keys(bizAll).sort(function(a,b){ return a.localeCompare(b,'ko'); }),
            matchAll:Object.keys(matchAll).sort(function(a,b){ return a.localeCompare(b,'ko'); }),
            dcAll:Object.keys(dcAll).sort(function(a,b){
              var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);   // 그룹순서 설정 반영, 미지정은 ㄱㄴㄷ순 뒤에
              if(ia>=0 && ib>=0) return ia-ib;
              if(ia>=0) return -1;
              if(ib>=0) return 1;
              return a.localeCompare(b,'ko');
            }),
            zoneAll:zoneAll,                 // { 묶음: {개별출고장:1} } — 콤보 2단용(2026-08-02)
            totQty:totQty, curDttm:curDttm};
  }

  // ── 보기 모드 전환 (출고장별/사업장별/품목별) — 메뉴 또는 툴바에서 호출
  function d2SetView(v){
    D2_VIEW=(v==='biz'||v==='item'||v==='zoneitem'||v==='matrix')?v:'zone';
    // 상단 보기 콤보박스 선택 동기화 — 메뉴/외부 호출로 바뀔 때도 콤보가 따라오게(2026-07-24)
    var sel=document.getElementById('d2ViewSel'); if(sel && sel.value!==D2_VIEW) sel.value=D2_VIEW;
    /* 콤보는 출고세부조회에서만 보인다 — 대시보드(zone)는 좌측 메뉴가 보기를 정해줘 필요 없다(2026-07-25 요청) */
    /* ★가로표도 숨긴다 — 탭이 그 역할을 하고, 콤보 글자가 길어 제목줄이 접히면서
       「발주현황표 엑셀 보기/출력」 단추들이 아랫줄로 내려가 버린다(2026-08-28 지적). */
    var box=document.getElementById('d2ViewSelBox'); if(box) box.style.display=(D2_VIEW==='zone'||D2_VIEW==='matrix')?'none':'inline-flex';
    /* 보기 탭 선택표시 — 목록/가로표 둘 중 어디에 있는지 늘 보이게 (2026-08-28) */
    var _vl=document.getElementById('d2VtList'), _vm=document.getElementById('d2VtMx');
    if(_vl) _vl.className='vt'+((D2_VIEW==='matrix')?'':' on');
    if(_vm) _vm.className='vt'+((D2_VIEW==='matrix')?' on':'');
    var t=document.getElementById('d2ViewTag'); if(t) t.textContent=(D2_VIEW==='matrix'?'가로표 보기':(D2_VIEW==='biz'?'사업장별 보기':(D2_VIEW==='item'?'품목별 보기':(D2_VIEW==='zoneitem'?'출고장별 품목보기':'출고장별 보기'))));
    // 출력 형식 셀렉터를 현재 보기와 동기화 → 상단 '일자별/합계 출력'이 현재 보기 형식으로 나감
    var pf=document.getElementById('d2PrintFmt'); if(pf){ var want=(D2_VIEW==='zone')?'zone':D2_VIEW; for(var i=0;i<pf.options.length;i++){ if(pf.options[i].value===want){ pf.value=want; break; } } }
    /* ★보기 콤보가 떠 있는 화면(출고세부조회)에서는 출력형식 콤보를 숨긴다 (2026-08-28 머리줄 두 줄 지적) —
       바로 위에서 현재 보기로 동기화되므로 두 콤보가 같은 값으로 나란히 떠 자리만 먹었다.
       출력은 지금 보는 형식 그대로 나간다. 대시보드(zone·matrix)는 보기 콤보가 없어 종전대로 보인다.
       ⚠요소를 지우지 않는다 — d2Download 가 pf.value 를 읽는다(숨겨도 값은 산다). */
    if(pf) pf.style.display=(D2_VIEW==='zone'||D2_VIEW==='matrix')?'':'none';
    d2Render();
  }
  // 부모(사이드바 메뉴)에서 보기 전환 요청 수신
  window.addEventListener('message', function(e){ var d=e.data; if(d && d.type==='d2view'){ d2SetView(d.view); } });

  // ag → 품목별 합산 목록 [{code,name,qty,zones:{출고장:수량},bizs:{사업장:수량}}]
  //   zones/bizs = 이 품목이 어느 출고장·사업장에 얼마나 나갔는지(연계자료, 2026-07-24). 순수 화면단 집계.
  function d2ItemsFromAg(ag){
    var items={};
    ag.zoneOrder.forEach(function(zn){ var z=ag.zones[zn]; Object.keys(z.rows).forEach(function(rk){
      var r=z.rows[rk]; if(!((+r.qty||0)>0)) return; var k=r.code?('C:'+r.code):('N:'+r.name);
      if(!items[k]) items[k]={code:r.code||'',name:r.name||'',qty:0,zones:{},bizs:{}};
      var q=(+r.qty||0); items[k].qty+=q;
      if(zn) items[k].zones[zn]=(items[k].zones[zn]||0)+q;
      var b=r.biz||'(사업장 미지정)'; items[k].bizs[b]=(items[k].bizs[b]||0)+q;
    }); });
    return Object.keys(items).map(function(k){ return items[k]; }).sort(function(a,b){ return a.name.localeCompare(b.name,'ko')||a.code.localeCompare(b.code,'ko'); });
  }
  // ag → 사업장별 { 사업장:{items,tot} }
  function d2BizFromAg(ag){
    var bm={};
    ag.zoneOrder.forEach(function(zn){ var z=ag.zones[zn]; Object.keys(z.rows).forEach(function(rk){
      var r=z.rows[rk]; if(!((+r.qty||0)>0)) return; var b=r.biz||'(사업장 미지정)';
      var g=bm[b]||(bm[b]={items:{},tot:0}); var k=r.code?('C:'+r.code):('N:'+r.name);
      if(!g.items[k]) g.items[k]={code:r.code||'',name:r.name||'',qty:0}; g.items[k].qty+=(+r.qty||0); g.tot+=(+r.qty||0);
    }); });
    return bm;
  }
  // ag → 출고장별 [{zone,dcCd,items:[{code,name,qty}],tot}] — 출고장 안에서 같은 품목코드는 합산
  function d2ZoneItemsFromAg(ag){
    var out=[];
    d2ZonesSorted(ag).forEach(function(zn){
      var z=ag.zones[zn]; if(!z) return;
      var items={};
      Object.keys(z.rows).forEach(function(rk){
        var r=z.rows[rk]; if(!((+r.qty||0)>0)) return;
        var k=r.code?('C:'+r.code):('N:'+r.name);
        if(!items[k]) items[k]={code:r.code||'',name:r.name||'',qty:0,bizs:{}};
        var q=(+r.qty||0); items[k].qty+=q;
        // 이 품목이 이 출고장에서 어느 사업장으로 나갔나(품목명 옆 사업장 콤보용, 2026-07-24)
        var b=r.biz||'(사업장 미지정)'; items[k].bizs[b]=(items[k].bizs[b]||0)+q;
      });
      var list=Object.keys(items).map(function(k){ return items[k]; })
        .sort(function(a,b){ return a.name.localeCompare(b.name,'ko')||a.code.localeCompare(b.code,'ko'); });
      var tot=0; list.forEach(function(r){ tot+=r.qty; });
      if(tot>0) out.push({ zone:zn, dc:(z.dc||zn), dcCd:(z.dcCd||''), items:list, tot:tot });
    });
    return out;
  }
  // 출고장 배열 → 대표그룹(오산센터 등)으로 묶기 — 대시보드와 동일한 그룹 순서
  function d2GroupZones(zones){
    var groups={}, gOrder=[];
    zones.forEach(function(z){ var g=z.dc||z.zone; if(!groups[g]){ groups[g]=[]; gOrder.push(g); } groups[g].push(z); });
    gOrder.sort(function(a,b){
      var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);
      if(ia>=0 && ib>=0) return ia-ib;
      if(ia>=0) return -1;
      if(ib>=0) return 1;
      return a.localeCompare(b,'ko');
    });
    return { groups:groups, order:gOrder };
  }
  // 출고장별 품목 한 집계(ag) → 표 HTML (출고장 그룹 + 품목코드 합산 목록)
  function d2ZoneItemsTableHtml(ag){
    // 출고장별 품목 — 품목명 옆에 사업장 분포 열 추가(2026-07-24). 이 출고장에서 이 품목이 어느 사업장으로 나갔나. 대표 1곳 + 2곳↑이면 콤보
    var COLG='<colgroup><col style="width:6%"><col style="width:15%"><col style="width:38%"><col style="width:28%"><col style="width:13%"></colgroup>';
    var THEAD='<thead><tr><th>No</th><th>품목코드</th><th>품목명</th><th>사업장</th><th>출고수량</th></tr></thead>';
    var zones=d2ZoneItemsFromAg(ag), grand=0; zones.forEach(function(z){ grand+=z.tot; });
    var gp=d2GroupZones(zones);
    var html='<table class="d2-tb d2-tb-blk">'+COLG+THEAD+'<tbody>';
    html+='<tr class="tot"><td class="txt-l" colspan="4">전체 합계 (출고장 '+zones.length+'곳)</td><td class="num">'+d2Num(grand)+'</td></tr>';
    if(!zones.length) html+='<tr class="item"><td class="txt-l" colspan="5"><div class="d2-empty">표시할 출고장이 없습니다.</div></td></tr>';
    gp.order.forEach(function(g){
      var zs=gp.groups[g], gtot=0; zs.forEach(function(z){ gtot+=z.tot; });
      // 대표그룹(오산센터 등) 헤더
      html+='<tr class="grp"><td class="txt-l" colspan="4">🏬 '+d2Esc(g)+' <span style="font-weight:600">('+zs.length+'개 출고장)</span></td><td class="num">'+d2Num(gtot)+'</td></tr>';
      zs.forEach(function(z){
        // 출고장 소계 + 품목(코드 합산)
        html+='<tr class="sub"><td class="txt-l" colspan="4" style="padding-left:20px">↳ '+d2Esc(z.zone)+(z.dcCd?' <span style="font-weight:600">('+d2Esc(z.dcCd)+')</span>':'')+' <span style="color:#9aa7b3">(품목 '+z.items.length+'종)</span></td><td class="num">'+d2Num(z.tot)+'</td></tr>';
        z.items.forEach(function(r,ix){ html+='<tr class="item"><td>'+(ix+1)+'</td><td>'+d2Esc(r.code)+'</td><td class="txt-l">'+d2Esc(r.name)+'</td><td class="txt-l">'+d2DistCell(r.bizs,'사업장')+'</td><td class="num">'+d2Num0(r.qty)+'</td></tr>'; });
      });
    });
    return html+'</tbody></table>';
  }
  // 품목별 분포 셀(출고장/사업장): 대표(최다) 1곳만 보이고, 2곳↑이면 화살표 콤보박스로 전체 열람 (2026-07-24)
  //   dist = {이름:수량}. 수량 내림차순 정렬 → 첫 곳(대표)이 기본 선택. 화살표 클릭 시 전체 목록이 펼쳐진다.
  function d2DistCell(dist, unit){
    var keys=Object.keys(dist||{});
    if(!keys.length) return '<span style="color:#c0392b">-</span>';
    keys.sort(function(a,b){ return (dist[b]||0)-(dist[a]||0)||a.localeCompare(b,'ko'); });
    // 1곳뿐이면 콤보 불필요 — 이름만 표기(수량 생략, 2026-07-24)
    if(keys.length<2) return '<span>'+d2Esc(keys[0])+'</span>';
    var opts=keys.map(function(k){ return '<option>'+d2Esc(k)+'  ('+d2Num0(dist[k])+')</option>'; }).join('');
    var arrow="url(&quot;data:image/svg+xml;utf8,&lt;svg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='%23137a6c' stroke-width='3'&gt;&lt;path d='M6 9l6 6 6-6'/&gt;&lt;/svg&gt;&quot;)";
    return '<select title="'+d2Esc(unit)+' '+keys.length+'곳 전체 보기" onclick="event.stopPropagation()"'
         +' style="max-width:100%;height:28px;border:1px solid var(--bd);border-radius:6px;padding:0 26px 0 9px;font-size:12.5px;font-weight:700;cursor:pointer;color:#137a6c;'
         +'background:#fff '+arrow+' no-repeat right 8px center;-webkit-appearance:none;-moz-appearance:none;appearance:none">'
         +opts+'</select>'
         +' <span style="color:#9aa7b3;font-size:11.5px">'+keys.length+'곳</span>';
  }
  // 사업장별/품목별 한 집계(ag) → 표 HTML 한 개
  function d2GroupTableHtml(ag, mode){
    var html;
    if(mode==='item'){
      // 품목별 — 품목명 뒤에 연계자료(출고장 분포·사업장 분포) 열 추가(2026-07-24). 각 셀은 대표 1곳 + [＋N] 펼침
      var COLG='<colgroup><col style="width:5%"><col style="width:13%"><col style="width:26%"><col style="width:26%"><col style="width:20%"><col style="width:10%"></colgroup>';
      var THEAD='<thead><tr><th>No</th><th>품목코드</th><th>품목명</th><th>출고장 분포</th><th>사업장</th><th>출고수량</th></tr></thead>';
      html='<table class="d2-tb d2-tb-blk">'+COLG+THEAD+'<tbody>';
      var items=d2ItemsFromAg(ag), grand=0; items.forEach(function(r){ grand+=r.qty; });
      html+='<tr class="tot"><td class="txt-l" colspan="5">품목 합계 ('+items.length+'종)</td><td class="num">'+d2Num(grand)+'</td></tr>';
      if(!items.length) html+='<tr class="item"><td class="txt-l" colspan="6"><div class="d2-empty">표시할 품목이 없습니다.</div></td></tr>';
      items.forEach(function(r,ix){
        html+='<tr class="item"><td>'+(ix+1)+'</td><td>'+d2Esc(r.code)+'</td><td class="txt-l">'+d2Esc(r.name)+'</td>'
            +'<td class="txt-l">'+d2DistCell(r.zones,'출고장')+'</td>'
            +'<td class="txt-l">'+d2DistCell(r.bizs,'사업장')+'</td>'
            +'<td class="num">'+d2Num0(r.qty)+'</td></tr>';
      });
    } else {
      var COLG='<colgroup><col style="width:7%"><col style="width:17%"><col style="width:56%"><col style="width:20%"></colgroup>';
      var THEAD='<thead><tr><th>No</th><th>품목코드</th><th>품목명</th><th>출고수량</th></tr></thead>';
      html='<table class="d2-tb d2-tb-blk">'+COLG+THEAD+'<tbody>';
      var bm=d2BizFromAg(ag), names=Object.keys(bm).sort(function(a,b){ return a.localeCompare(b,'ko'); }), gtot=0;
      names.forEach(function(b){ gtot+=bm[b].tot; });
      html+='<tr class="tot"><td class="txt-l" colspan="3">사업장 합계 ('+names.length+' 사업장)</td><td class="num">'+d2Num(gtot)+'</td></tr>';
      if(!names.length) html+='<tr class="item"><td class="txt-l" colspan="4"><div class="d2-empty">표시할 사업장이 없습니다.</div></td></tr>';
      names.forEach(function(b){
        var g=bm[b];
        var list=Object.keys(g.items).map(function(k){ return g.items[k]; }).sort(function(x,y){ return x.name.localeCompare(y.name,'ko')||x.code.localeCompare(y.code,'ko'); });
        html+='<tr class="grp"><td class="txt-l" colspan="3">🏢 '+d2Esc(b)+' <span style="font-weight:600">(품목 '+list.length+'종)</span></td><td class="num">'+d2Num(g.tot)+'</td></tr>';
        list.forEach(function(r,ix){ html+='<tr class="item"><td>'+(ix+1)+'</td><td>'+d2Esc(r.code)+'</td><td class="txt-l">'+d2Esc(r.name)+'</td><td class="num">'+d2Num0(r.qty)+'</td></tr>'; });
      });
    }
    return html+'</tbody></table>';
  }
  // 사업장별/품목별 렌더 — 단일일자=1개 / 기간=출고일자별 섹션
  //  · 사업장별(biz): 사업장을 '출고장'처럼 취급해 기존 출고장별 렌더(현재/직전·소계) 재사용
  //  · 품목별(item): 플랫 목록
  /* ══ 화면 가로표 보기 (2026-08-28 요청 「기존 조회 화면 말고 엑셀 내용을 여기에」) ═══════
       엑셀 [출고장 × 품목 (가로표)] 과 <같은 내용·같은 규칙>을 화면에 그대로 그린다.
         · 행 = 출고장(물류센터 묶음 아래), 열 = 품목(사업장별 병합 머리줄)
         · 아무 데도 안 나가는 품목 열 · 아무것도 안 나가는 출고장 행은 뺀다(가로 줄이기)
         · 값 없는 칸은 회색, 오른쪽 합계·품목수 / 아래 합계·출고장수·현재고
       ★엑셀과 계산을 <한 곳에서> 하지 않는다 — 둘 다 d2Aggregate 결과만 쓰므로 값이 어긋날 일은 없다.
         모양을 고칠 때는 엑셀(d2DownloadByMatrix)도 같이 볼 것. */
  /* 사업장 접기 상태 — 사업장명 → 1(접힘). D2_MXBIZALL 은 이번에 그린 전체 사업장.
     ★[2026-08-28 요청 「엑셀처럼 헤더 축소/확대」] 머리칸을 누르면 그 사업장이 <합계 한 칸>으로
       줄어들고(▸), 다시 누르면 품목 칸들로 펼쳐진다(▾) — 엑셀의 열 그룹 접기와 같다.
       값은 전부 그대로 더해지므로 합계·품목수가 화면과 어긋나지 않는다.
     [이력] 종전에는 누르면 사업장이 통째로 <숨어> 합계에서도 빠졌고(그래서 d2-mxhide 안내줄이
       필요했다) — 이 판에서 숨김·안내줄을 접기(축소)로 대체했다. 되살리려면 이 이력부터 확인. */
  var D2_MXFOLD = {}, D2_MXBIZALL = [];
  function d2MxFold(b){ if(!b) return; if(D2_MXFOLD[b]) delete D2_MXFOLD[b]; else D2_MXFOLD[b]=1; d2Render(); }
  function d2MxFoldAll(){
    /* 하나라도 보이면 전부 숨기고, 다 숨겨져 있으면 전부 편다 */
    var any=false, i;
    for(i=0;i<D2_MXBIZALL.length;i++){ if(!D2_MXFOLD[D2_MXBIZALL[i]]){ any=true; break; } }
    for(i=0;i<D2_MXBIZALL.length;i++){ var b=D2_MXBIZALL[i]; if(any) D2_MXFOLD[b]=1; else delete D2_MXFOLD[b]; }
    d2Render();
  }
  function d2MxShowAll(){ D2_MXFOLD={}; d2Render(); }
  /* ★출고장 줄 클릭 = 그 출고장의 품목 칸만 표시 (2026-08-30 「출고장/품목 누르면 우측 해당 품목만」).
     ★다중선택 지원(사용자 확인) — 누를 때마다 켜고 끄고, 여러 개면 <합집합> 품목이 보인다.
     행은 다 남긴다(다른 출고장과 비교용) — 칸만 걸러지므로 합계·품목수도 보이는 칸 기준으로
     다시 계산된다(사업장 접기와 같은 원리). 해제 = 같은 줄 다시 클릭 or 안내줄 [전체 품목 보기]. */
  var D2_MXZSEL={};
  /* ★무조건 필터는 헷갈린다(2026-08-30 사용자) → 머리칸 ☑「선택 출고장 품목만」이 켜져 있을 때만
     출고장 클릭이 필터로 동작한다. 끄면 선택도 비운다. localStorage 로 기억. */
  /* ★기본 = 꺼짐(출고장 선택 모드 아님) — 진입할 때마다 항상 전체 보기로 시작한다(2026-08-30 확정).
     localStorage 기억을 뒀다가 뺐다 — 지난번 켜 둔 것이 남아 있으면 「기본이 선택 모드」가 되어 버린다. */
  var D2_MXZONLY=false;
  function d2MxZoneChk(v){ D2_MXZONLY=!!v; if(!D2_MXZONLY) D2_MXZSEL={}; d2Render(); }
  /* ★단일선택 (2026-08-30 확정 — 「선택은 하나만, 이전 것은 없어져야」): 새 출고장을 누르면
     이전 선택이 지워지고 그것만 남는다. 같은 줄을 다시 누르면 해제. 다중선택은 폐기 —
     되살리자는 얘기가 나오면 이 이력부터 확인(합집합 표시가 헷갈린다는 피드백이 발단). */
  function d2MxZoneSel(zn){ if(!zn || !D2_MXZONLY) return; var on=!!D2_MXZSEL[zn]; D2_MXZSEL={}; if(!on) D2_MXZSEL[zn]=1; d2Render(); }
  function d2MxZoneClear(){ D2_MXZSEL={}; d2Render(); }
  function d2RenderMatrixView(ag, from, to){
    var sc=document.querySelector('.d2-scroll'); if(!sc) return;
    sc.style.overflowX='auto';                    // 가로표는 옆으로 밀어 본다(기본 보기는 hidden)
    var zones=d2ZonesSorted(ag).filter(function(zn){
      var rs=ag.zones[zn].rows;
      return Object.keys(rs).some(function(k){ return (+rs[k].qty||0)>0; });
    });
    if(!zones.length){ sc.innerHTML='<div style="padding:26px;text-align:center;color:#9aa7b3">출고량이 있는 자료가 없습니다.</div>'; return; }
    /* 열 = <매칭명칭 × 품목>. 매칭이 없는 사업장은 <원래 사업장 이름>이 그대로 한 덩어리다(2026-08-28).
       ★같은 매칭·같은 품목이면 여러 사업장의 수량을 <한 칸으로 더한다> — 그게 묶는 목적이다.
         그래서 칸마다 「합칠 원본 행키(keys)」를 들고 다닌다. */
    var colMap={}, allCols=[];
    zones.forEach(function(zn){
      var rs=ag.zones[zn].rows;
      Object.keys(rs).forEach(function(rk){
        var r=rs[rk]; if((+r.qty||0)<=0) return;
        var ik=(r.code ? r.code : ('NM:'+(r.name||'')));
        var ck=d2MtNm(r)+'\u0001'+ik;
        var c=colMap[ck];
        if(!c){ c=colMap[ck]={ ck:ck, biz:d2MtNm(r), code:(r.code||''), name:(r.name||''), keys:[], kset:{} }; allCols.push(c); }
        if(!c.kset[rk]){ c.kset[rk]=1; c.keys.push(rk); }
      });
    });
    allCols.sort(function(a,b){ return a.biz.localeCompare(b.biz,'ko') || a.name.localeCompare(b.name,'ko'); });
    function colQty(rs, c){ var t=0; for(var i=0;i<c.keys.length;i++){ var x=rs[c.keys[i]]; if(x) t+=(+x.qty||0); } return t; }
    /* 출고장 선택 필터 — ☑가 켜져 있을 때만. 재조회로 사라진 출고장은 선택에서 뺀다 */
    Object.keys(D2_MXZSEL).forEach(function(zn){ if(!ag.zones[zn]) delete D2_MXZSEL[zn]; });
    var _selZs=D2_MXZONLY?Object.keys(D2_MXZSEL):[];
    var allColsFull=allCols.slice();   // 필터 전 전체 칸 — 병기(전체값)·직송 나눔은 이걸로 센다
    var MXF=_selZs.length>0;           // 필터 가동 중
    if(MXF){ allCols=allCols.filter(function(c){ return _selZs.some(function(zn){ return colQty(ag.zones[zn].rows,c)>0; }); }); }
    /* 전체 기준 값 — 합계=ag.zones tot 합 / 품목수=allColsFull 중 수량 있는 칸 수 */
    function fullTot(zList){ var t=0; zList.forEach(function(zn){ t+=(ag.zones[zn]&&ag.zones[zn].tot||0); }); return t; }
    function fullCnt(zList){ var n=0; allColsFull.forEach(function(c){ for(var i=0;i<zList.length;i++){ if(colQty(ag.zones[zList[i]].rows,c)>0){ n++; return; } } }); return n; }
    /* 병기 — 필터 중에만 「보이는값 (전체값)」, 같으면 그냥 값 (2026-08-30 ②번 확정) */
    function bng(vis, full){ vis=+vis||0; full=+full||0; if(!MXF || vis===full) return (vis>0?d2Num(vis):(MXF&&full>0?'0':'')); return d2Num(vis)+' <span class="mxfull">('+d2Num(full)+')</span>'; }

    /* 사업장 묶음 → ★접힌 사업장은 <합계 한 칸>으로 줄인다 (엑셀 열 그룹 접기와 같다).
       cols = 실제로 그릴 칸 목록. 접힌 묶음은 그 사업장 품목 전부를 더하는 가상 칸 하나(fold:true)로
       들어가므로, 아래 집계·본문 코드는 <칸 하나>만 보고 그리면 되어 손댈 곳이 없다. */
    var bgsAll=[], bgs=[], cols=[], nFold=0;
    allCols.forEach(function(c){
      var g=bgsAll[bgsAll.length-1];
      if(!g || g.biz!==c.biz){ g={ biz:c.biz, cols:[] }; bgsAll.push(g); }
      g.cols.push(c);
    });
    D2_MXBIZALL = bgsAll.map(function(g){ return g.biz; });
    bgsAll.forEach(function(g){
      if(D2_MXFOLD[g.biz]){
        nFold++;
        var keys=[], kset={};
        g.cols.forEach(function(c){ c.keys.forEach(function(k){ if(!kset[k]){ kset[k]=1; keys.push(k); } }); });
        var fc={ ck:'FOLD'+g.biz, biz:g.biz, code:'', name:'합계 (품목 '+g.cols.length+'종)',
                 keys:keys, kset:kset, fold:true, nItem:g.cols.length, subs:g.cols };
        g.view=[fc]; cols.push(fc);   /* subs = 접기 전 원본 칸들 — 품목수를 <원래 품목 수>로 세는 데 쓴다 */
      } else { g.view=g.cols; g.cols.forEach(function(c){ cols.push(c); }); }
      bgs.push(g);
    });
    var FCLK=' onclick="d2MxFold(this.getAttribute(\'data-b\'))"';
    var GCLK=' onclick="d2ToggleGroup(this.getAttribute(\'data-g\'))"';   // 좌측 물류센터 묶음 접기(목록 보기와 공유)
    var bar='';   /* (숨김 안내줄은 접기 방식으로 바뀌며 없어졌다 — 위 D2_MXFOLD 주석의 [이력]) */
    if(_selZs.length){
      bar='<div class="d2-mxhide">📌 <b>'+_selZs.map(d2Esc).join(' · ')+'</b> 품목만 보는 중 ('+allCols.length+'칸 · 줄을 다시 누르면 해제 · <span class="mxfull" style="font-size:12px">괄호 = 전체 기준 값</span>) '
         +'<a style="margin-left:8px;color:#137a6c;font-weight:700;cursor:pointer;text-decoration:underline" onclick="d2MxZoneClear()">✕ 전체 품목 보기</a></div>';
    }

    /* ① 사업장 병합 머리줄 — 누르면 그 사업장이 숨는다 */
    /* ★GSIX = 각 사업장의 <첫 품목 칸> 열번호 (첫 사업장 제외 — 왼쪽은 고정칸 경계라 필요 없다).
         머리줄·품목줄·본문·합계·현재고 줄이 전부 이 표로 .gs 를 붙여 경계선이 세로로 이어진다(2026-08-28). */
    var GSIX={}; (function(){ var ix=0; bgs.forEach(function(g,bi){ if(bi>0) GSIX[ix]=1; ix+=g.view.length; }); })();
    var GC=function(ix,extra){ var cls=((GSIX[ix]?'gs ':'')+(extra||'')).trim(); return cls?' class="'+cls+'"':''; };
    var h='<table class="d2-mx"><thead><tr><th class="cn" rowspan="2">출고장 / 품목'
        + '<label class="mxzchk" title="켜면 출고장 줄을 눌러 그 출고장의 품목만 남길 수 있습니다(하나만 선택 · 다시 누르면 해제)"><input type="checkbox" onchange="d2MxZoneChk(this.checked)"'+(D2_MXZONLY?' checked':'')+'> 선택 출고장 품목만</label></th>'
        + '<th class="rtot" rowspan="2">합계</th><th class="rcnt" rowspan="2">품목수</th>';
    bgs.forEach(function(g,bi){
      var fold=!!D2_MXFOLD[g.biz];
      h += '<th class="bz'+(bi>0?' gs':'')+(fold?' fd':'')+'" colspan="'+g.view.length+'" data-b="'+d2Esc(g.biz)+'"'+FCLK
         + ' title="'+d2Esc(g.biz)+' — 누르면 '+(fold?('품목 '+g.cols.length+'칸으로 펼칩니다'):'합계 한 칸으로 접습니다')+'">'
         + (fold?'▸ ':'▾ ')+d2Esc(g.biz)+(fold?(' <span class="fn">('+g.cols.length+')</span>'):'')+'</th>';
    });
    h+='</tr><tr>';
    cols.forEach(function(c,ix){
      /* 접힌 사업장의 칸 — 품목코드 대신 '합계' 라고 적고, 눌러서 펼칠 수 있게 같은 클릭을 건다 */
      if(c.fold){
        h+='<th class="it fd'+(GSIX[ix]?' gs':'')+'" data-b="'+d2Esc(c.biz)+'"'+FCLK
          +' title="'+d2Esc(c.biz)+' — 품목 '+c.nItem+'종 합계. 누르면 펼칩니다">Σ 합계<br><span class="nm">품목 '+c.nItem+'종</span></th>';
        return;
      }
      var lab=c.code ? (c.code+'<br><span class="nm">'+d2Esc(c.name)+'</span>') : d2Esc(c.name);
      h+='<th class="it'+(GSIX[ix]?' gs':'')+'" title="'+d2Esc((c.code?c.code+' ':'')+c.name)+'">'+lab+'</th>';
    });
    h+='</tr></thead><tbody>';

    /* ② 물류센터 묶음 → 출고장 행 */
    var sums=cols.map(function(){ return 0; }), zcnt=cols.map(function(){ return 0; });
    var grand=0, itemAll={}, zoneVis=0;   // zoneVis = 보이는 사업장 물량이 <실제로 있는> 출고장 수
    var groups={}, gOrder=[];
    zones.forEach(function(zn){ var g=(ag.zones[zn].dc||zn); if(!groups[g]){ groups[g]=[]; gOrder.push(g); } groups[g].push(zn); });
    gOrder.sort(function(a,b){
      var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);
      if(ia>=0&&ib>=0) return ia-ib;
      if(ia>=0) return -1; if(ib>=0) return 1;
      return a.localeCompare(b,'ko');
    });
    gOrder.forEach(function(g){
      /* ★센터명으로 먼저 묶고 → 그 안에서 직송을 맨 아래로. 직송 플래그를 먼저 비교하면
           직송 줄들이 그룹 끝에 모여 센터 소계가 두 번씩 생긴다(2026-08-30 실화면으로 확인된 버그). */
      var gz=groups[g].slice().sort(function(a,b){
        var c=d2CenterNm(a).localeCompare(d2CenterNm(b),'ko'); if(c!==0) return c;
        var ja=/\s직송$/.test(a)?1:0, jb=/\s직송$/.test(b)?1:0; if(ja!==jb) return ja-jb;
        return a.localeCompare(b,'ko');
      });
      var gs=cols.map(function(){ return 0; }), gItems={}, lines='';
      /* ★센터 소계(csub) — 「오산물류센터도 평택처럼 SUM」(2026-08-30). 목록 보기와 같은 규칙:
           묶음 안 센터가 여럿이고 그 센터가 2줄 이상일 때만. 묶음=센터 하나면 grp 줄이 이미 그 센터 합계. */
      var _cCnt={}; gz.forEach(function(zn){ var c=d2CenterNm(zn); _cCnt[c]=(_cCnt[c]||0)+1; });
      var _cMulti=Object.keys(_cCnt).length>1;
      var _cCur=null, _cs=cols.map(function(){ return 0; }), _cItems={}, _cTot=0, _cZl=[];
      function _cFlushM(){
        if(_cCur!==null && _cMulti && _cCnt[_cCur]>1){
          /* ★배송/직송 나눔은 <전체 기준> — 필터 중 화면 누계로 세면 직송 표시가 사라진다(2026-08-30 재지적) */
          var _fj=0; _cZl.forEach(function(zn){ if(/\s직송$/.test(zn)) _fj+=(ag.zones[zn].tot||0); });
          var _ft=fullTot(_cZl);
          lines += '<tr class="csub"><td class="cn">'+d2Esc(_cCur)+' 합계'+d2BdxLabel(_ft-_fj,_fj)+'</td>'
                 + '<td class="rtot">'+bng(_cTot,_ft)+'</td><td class="rcnt">'+bng(Object.keys(_cItems).length, MXF?fullCnt(_cZl):Object.keys(_cItems).length)+'</td>'
                 + _cs.map(function(v,ix){ return v>0?('<td'+GC(ix)+'>'+d2Num(v)+'</td>'):'<td'+GC(ix,'none')+'></td>'; }).join('')
                 + '</tr>';
        }
        _cs=cols.map(function(){ return 0; }); _cItems={}; _cTot=0; _cZl=[];
      }
      gz.forEach(function(zn){
        var _zc=d2CenterNm(zn); if(_cCur!==null && _zc!==_cCur) _cFlushM(); _cCur=_zc; _cZl.push(zn);
        var rs=ag.zones[zn].rows, rt=0, rc=0, tds='';
        cols.forEach(function(c,ix){
          var q=colQty(rs,c);
          if(q>0){
            sums[ix]+=q; zcnt[ix]++; gs[ix]+=q; _cs[ix]+=q; rt+=q;
            /* ★품목수는 <접기와 무관하게> 원래 품목으로 센다 — 접었다고 1종으로 줄면
                 화면 숫자가 접기 상태에 따라 달라져 믿을 수 없게 된다(2026-08-28). */
            if(c.fold){ c.subs.forEach(function(s){ if(colQty(rs,s)>0){ rc++; itemAll[s.ck]=1; gItems[s.ck]=1; _cItems[s.ck]=1; } }); }
            else { rc++; itemAll[c.ck]=1; gItems[c.ck]=1; _cItems[c.ck]=1; }
          }
          tds += q>0 ? ('<td'+GC(ix,c.fold?'fdv':'')+'>'+d2Num(q)+'</td>') : '<td'+GC(ix,'none')+'></td>';
        });
        grand+=rt; _cTot+=rt; if(rt>0) zoneVis++;
        /* ★사업장을 숨기면 그 출고장 줄이 통째로 빌 수 있다 — 그때 0 이 아니라 빈칸이어야 한다
             (0 은 「0개 나갔다」로 읽혀 없는 실적을 있는 것처럼 만든다) */
        var _zTitle=D2_MXZONLY?'누르면 이 출고장의 품목만 남습니다 (다른 줄을 누르면 그쪽으로 바뀌고, 다시 누르면 해제)':'품목만 보려면 머리칸의 [선택 출고장 품목만] 체크를 먼저 켜세요';
        lines += '<tr'+((D2_MXZONLY&&D2_MXZSEL[zn])?' class="zsel"':'')+'><td class="cn zn'+(D2_MXZONLY?' zpick':'')+'" data-z="'+d2Esc(zn)+'" onclick="d2MxZoneSel(this.getAttribute(\'data-z\'))" title="'+_zTitle+'">'+d2Esc(zn).replace(/\s직송$/,' <span class="jkw">직송</span>')+'</td>'
               + '<td class="rtot">'+bng(rt, MXF?fullTot([zn]):rt)+'</td><td class="rcnt">'+bng(rc, MXF?fullCnt([zn]):rc)+'</td>'+tds+'</tr>';
      });
      _cFlushM(); _cCur=null;   // 마지막 센터 소계
      var gTot=0; gs.forEach(function(v){ gTot+=v; });
      /* ★물류센터 묶음 접기 (2026-08-28 「화살표 접기 작동 안 함」) — ▼ 를 그려 놓고 클릭이 없어
           눌러도 아무 일이 없었다. 목록 보기와 <같은 상태>(D2_GCOLL·d2ToggleGroup)를 쓰므로
           한쪽에서 접으면 다른 보기에서도 접혀 있다. 접어도 묶음 줄의 합계·품목수는 그대로다. */
      var gCol=!!D2_GCOLL[g];
      var _gfj=0; gz.forEach(function(zn){ if(/\s직송$/.test(zn)) _gfj+=(ag.zones[zn].tot||0); });   // 직송 나눔 = 전체 기준(필터와 무관)
      var _gft=fullTot(gz);
      h += '<tr class="grp" data-g="'+d2Esc(g)+'"'+GCLK+' title="'+d2Esc(g)+' — 누르면 출고장 줄을 '+(gCol?'폅니다':'접습니다')+'">'
         + '<td class="cn">'+(gCol?'▶':'▼')+' '+d2Esc(g)+' <span class="sub">('+gz.length+'개 출고장)</span>'+d2BdxLabel(_gft-_gfj,_gfj)+'</td>'
         + '<td class="rtot">'+bng(gTot,_gft)+'</td><td class="rcnt">'+bng(Object.keys(gItems).length, MXF?fullCnt(gz):Object.keys(gItems).length)+'</td>'
         + gs.map(function(v,ix){ return v>0 ? ('<td'+GC(ix)+'>'+d2Num(v)+'</td>') : '<td'+GC(ix,'none')+'></td>'; }).join('')
         + '</tr>' + (gCol ? '' : lines);
    });

    /* ③ 아래 집계 — 합계 · 출고장수 · 현재고(품목별) */
    h += '<tr class="sum"><td class="cn">합계</td>'
       + '<td class="rtot">'+bng(grand, MXF?fullTot(zones):grand)+'</td><td class="rcnt">'+bng(Object.keys(itemAll).length, MXF?allColsFull.length:Object.keys(itemAll).length)+'</td>'
       + sums.map(function(v,ix){ return v>0 ? ('<td'+GC(ix)+'>'+d2Num(v)+'</td>') : '<td'+GC(ix,'none')+'></td>'; }).join('')
       + '</tr>';
    h += '<tr class="zc"><td class="cn">출고장수</td>'
       + '<td class="rtot">'+bng(zoneVis, MXF?zones.length:zoneVis)+'</td><td class="rcnt"></td>'
       + zcnt.map(function(v,ix){ return v>0 ? ('<td'+GC(ix)+'>'+v+'</td>') : '<td'+GC(ix,'none')+'></td>'; }).join('')
       + '</tr>';
    /* 현재고 — 화면 '현재고' 칸과 같은 근거. 못 찾으면 0 이 아니라 빈칸(0 은 '재고 없음'으로 잘못 읽힌다) */
    /* ★이미 받아 뒀으면 다시 부르지 않는다 — 부르면 콜백이 곧바로 돌아 d2Render → 무한루프가 된다 */
    if(!D2_STOCK) d2StockLoad(function(){ var t=document.querySelector('.d2-mx'); if(t) d2Render(); });
    var stkTd='', anyStk=false;
    cols.forEach(function(c,ix){
      var q=d2StockQty(c.code);
      if(q==null){ stkTd+='<td'+GC(ix,'none')+'></td>'; return; }
      anyStk=true;
      stkTd += '<td'+GC(ix, q<0?'neg':'')+'>'+d2Num(q)+'</td>';
    });
    if(anyStk) h += '<tr class="stk"><td class="cn">현재고</td><td class="rtot"></td><td class="rcnt"></td>'+stkTd+'</tr>';
    h += '</tbody></table>';
    sc.innerHTML = bar + h;
    /* 툴바 단추 글씨를 현재 상태에 맞춘다 */
    var bf=document.getElementById('d2BtnBizFold');
    if(bf) bf.innerHTML=(nFold>=bgsAll.length && bgsAll.length) ? '＋ 사업장 펼치기' : '－ 사업장 접기';
  }

  function d2RenderGroupView(ag, from, to, mode){
    var scroll=document.querySelector('.d2-scroll'); if(!scroll) return;
    var dset={}; (D2_DATA||[]).forEach(function(r){ var d=r.date||D2_TODAY; if(from && d<from) return; if(to && d>to) return; dset[d]=1; });
    var dates=Object.keys(dset).sort().reverse();
    var html;
    if(mode==='biz'){
      // 사업장을 '출고장(zone)'처럼 매핑 → 기존 배치 매트릭스 렌더(현재/직전·소계) 재사용
      D2_UNIT='사업장';
      var _mapB=function(r){ return { code:r.code, item:r.item, biz:r.biz, bizCode:r.bizCode, dc:'전체 사업장', dcCd:(r.bizCode||''), inwh:'', zone:(r.biz||'(사업장 미지정)'), origZone:(r.zone||''), qty:r.qty, dlvDt:r.dlvDt, date:r.date, uploadDttm:r.uploadDttm, firstDttm:r.firstDttm, jobSeq:r.jobSeq }; };
      var dataB=(D2_DATA||[]).map(_mapB), histB=(D2_HISTALL||[]).map(_mapB);
      if(dates.length<=1){
        var agB=d2Aggregate(dataB, from, to);
        html='<table class="d2-tb" id="d2Tbl">'+d2BuildTableInner(agB, from, to, dataB, histB, (dates.length===1?dates[0]:from))+'</table>';
      } else {
        html='';
        dates.forEach(function(d){
          var rowsD=dataB.filter(function(r){ return (r.date||D2_TODAY)===d; });
          var histD=histB.filter(function(r){ return (r.date||D2_TODAY)===d; });
          var agD=d2Aggregate(rowsD, d, d);
          var zc=agD.zoneOrder.filter(function(zn){ return agD.zones[zn].tot>0; }).length;
          html+='<div class="d2-datehdr">📅 '+d2Esc(d)+' 출고 <span class="d2-dsum">사업장 '+zc+'곳</span></div>'
              +'<table class="d2-tb d2-tb-blk">'+d2BuildTableInner(agD, d, d, rowsD, histD, d)+'</table>';
        });
      }
    } else if(mode==='zoneitem'){
      // 출고장별 품목 — 출고장 그룹 + 품목코드 합산 (단일=1개 / 기간=출고일자별 섹션)
      if(dates.length<=1){
        html=d2ZoneItemsTableHtml(ag);
      } else {
        html='';
        dates.forEach(function(d){
          var rowsD=D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; });
          var agD=d2Aggregate(rowsD, d, d);
          var tot=0; d2ZoneItemsFromAg(agD).forEach(function(z){ tot+=z.tot; });
          html+='<div class="d2-datehdr">📅 '+d2Esc(d)+' 출고 <span class="d2-dsum">합계 '+d2Num(tot)+' BOX</span></div>'+d2ZoneItemsTableHtml(agD);
        });
      }
    } else {
      // 품목별 — 사업장 제외, 품목별 합계 플랫 목록 (단일=1개 / 기간=출고일자별 섹션)
      if(dates.length<=1){
        html=d2GroupTableHtml(ag, 'item');
      } else {
        html='';
        dates.forEach(function(d){
          var rowsD=D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; });
          var agD=d2Aggregate(rowsD, d, d);
          var tot=0; d2ItemsFromAg(agD).forEach(function(r){ tot+=r.qty; });
          html+='<div class="d2-datehdr">📅 '+d2Esc(d)+' 출고 <span class="d2-dsum">합계 '+d2Num(tot)+' BOX</span></div>'+d2GroupTableHtml(agD, 'item');
        });
      }
    }
    scroll.innerHTML=html;
    d2ApplyZoom();
    if(window.self!==window.top){ try{ window.parent.postMessage({type:'konetAsq', hide:true, html:''}, '*'); }catch(e){} }  // 변경알림바 숨김
  }

  /* 탭 선택표시. ★첫 화면은 d2SetView 를 거치지 않아 아무 탭도 안 켜져 있었다 → 그릴 때마다 맞춘다 */
  function d2VtSync(){
    var mx=(D2_VIEW==='matrix');
    var l=document.getElementById('d2VtList'), m=document.getElementById('d2VtMx');
    if(l) l.className='vt'+(mx?'':' on');
    if(m) m.className='vt'+(mx?' on':'');
    /* 가로표엔 접을 행이 없고, 목록엔 접을 열이 없다 → 쓸모 있는 단추만 자리에 둔다(폭도 그대로) */
    var zb=document.getElementById('d2BtnZoneToggle'); if(zb) zb.style.display=mx?'none':'';
    var bb=document.getElementById('d2BtnBizFold');    if(bb) bb.style.display=mx?'':'none';
  }
  function d2Render(){
    d2LoadingOff();   // 조회 중 안내 해제 (모든 조회 경로가 이 함수로 수렴)
    d2VtSync();
    /* 현재고는 목록을 기다리게 하지 않는다 — 없으면 그 칸만 '·' 로 두고, 도착하면 한 번 더 그린다.
       ★재귀 조심 : D2_STOCK 이 채워진 뒤에만 다시 부르므로 두 번째에는 이 가지로 안 들어온다. */
    if(!D2_STOCK) d2StockLoad(function(){ d2Render(); });
    var ag=d2Aggregate();
    var from=(document.getElementById('d2DateFrom')||{}).value||'';
    var to=(document.getElementById('d2DateTo')||{}).value||'';

    // KPI
    var single=!!(from && from===to);
    d2Set('d2KpiPrefix', single ? (from===D2_TODAY?'당일':'선택일') : '기간');
    var zoneCnt=0; ag.zoneOrder.forEach(function(zn){ if(ag.zones[zn].tot>0) zoneCnt++; });
    d2Set('d2KpiItem', d2Num(ag.itemCnt));
    d2Set('d2KpiQty',  d2Num(ag.totQty));
    d2Set('d2KpiZone', d2Num(zoneCnt));
    d2Set('d2KpiBiz',  d2Num(ag.bizCnt));

    // 당일/당월 버튼 상태
    var ym=D2_TODAY.slice(0,7);
    var _d=new Date(); var monLast=ym+'-'+d2Pad(new Date(_d.getFullYear(), _d.getMonth()+1, 0).getDate());
    var bt=document.getElementById('d2BtnToday'); if(bt) bt.className=(single && from===D2_TODAY)?'btn-teal':'btn-line';
    var bm=document.getElementById('d2BtnMonth'); if(bm) bm.className=(from===ym+'-01' && to===monLast)?'btn-teal':'btn-line';

    /* 조회 정보
       ★[제외 2026-08-28 요청] <🗄️ DB 조회 …건> 배지와 <📅 2026-08-28 (금일)> 은 빼 두었다 —
         바로 위 출고일자 칸에 같은 내용이 있어 겹쳤다. 되살리려면 아래 _inf 맨 앞에 이 두 줄을 다시 넣으면 된다:
           var range=single ? (from+(from===D2_TODAY?' <b>(금일)</b>':'')) : ((from||'~')+' ~ '+(to||'~'));
           _inf.push('<span class="d2-srcbadge'+(D2_UP?' up':'')+'">'+(D2_SRC||'조회 전')+'</span> 📅 '+range);
         ⚠줄(#d2Info) 자체는 남긴다 — 데이터 없음·대표출고장·찾기 안내가 여기 뜬다.
         ⚠조회 실패(HTTP·통신오류)는 D2_SRC 말고 d2Toast 로도 뜬다 — 배지를 빼도 오류는 보인다(확인함).
       남는 안내는 있는 것만 ' | ' 로 잇는다 — 그냥 이어 붙이면 줄이 ' | ' 로 시작한다. */
    var _inf=[];
    if(ag.totQty<=0) _inf.push('<span style="color:#c0392b">해당 기간 데이터 없음</span>');
    if(Object.keys(D2_DCSEL).length>0) _inf.push('<span style="color:#178074">대표출고장 '+Object.keys(D2_DCSEL).length+'곳 선택</span>');
    if(D2_FIND)  _inf.push('<span style="color:#178074">사업장 찾기: '+d2Esc(D2_FIND)+'</span>');
    if(D2_IFIND) _inf.push('<span style="color:#178074">품목 찾기: '+d2Esc(D2_IFIND)+'</span>');
    var _infoHtml=_inf.join(' &nbsp;|&nbsp; ');
    d2Set('d2Info', _infoHtml);
    /* 조회조건·요약숫자가 제목줄로 올라가(2026-08-28) 이 줄엔 안내만 남았다 —
       할 말이 없으면 줄째로 감춘다(빈 흰 줄이 자리만 차지하지 않게). 접기(body.tb-fold)는 CSS 가 따로 감춘다. */
    var _tbBar=document.querySelector('.d2-topbar'); if(_tbBar) _tbBar.style.display=_infoHtml?'':'none';

    // 대표출고장(물류센터) 다중선택 콤보 — 버튼 라벨 + 드롭다운 체크박스 (열림 상태 유지)
    var dcSelCnt=Object.keys(D2_DCSEL).length;
    d2Set('d2DcLbl', dcSelCnt===0 ? '전체' : (dcSelCnt===1 ? Object.keys(D2_DCSEL)[0] : dcSelCnt+'곳 선택'));
    /* 2단 콤보 (2026-08-02 요청) — 1단 묶음(오산센터 등) / 2단 개별 출고장.
       ★묶음을 고르면 그 아래 개별을 따로 안 골라도 전부 나온다(필터가 둘 중 하나만 맞으면 통과).
       ★출고장이 1곳뿐인 묶음은 하위를 또 보여줄 필요가 없어 접어 둔다(줄만 늘어난다). */
    var _zAll=(ag.zoneAll||{});
    var _kidHtml=function(z){
      var kon=!!D2_DCSEL[z];
      return '<label class="kid'+(kon?' on':'')+'">'
        +'<input type="checkbox"'+(kon?' checked':'')+' data-g="'+d2Esc(z)+'" '
        +'onchange="d2DcToggle(this.getAttribute(&#39;data-g&#39;))"> '+d2Esc(z)+'</label>';
    };
    d2Set('d2DcPop',
      '<label class="all'+(dcSelCnt===0?' on':'')+'">'
      +'<input type="checkbox"'+(dcSelCnt===0?' checked':'')+' onchange="d2DcAllSel()"> 전체 ('+ag.dcAll.length+'개 물류센터)</label>'
      + ag.dcAll.map(function(g){
          var on=!!D2_DCSEL[g];
          var kids=Object.keys(_zAll[g]||{}).sort(function(a,b){ return a.localeCompare(b,'ko'); });
          var h='<label class="'+(on?'on':'')+'">'
            +'<input type="checkbox"'+(on?' checked':'')+' data-g="'+d2Esc(g)+'" '
            +'onchange="d2DcToggle(this.getAttribute(&#39;data-g&#39;))"> &#128451; '+d2Esc(g)
            +(kids.length>1?' <span style="color:#9aa7b3">('+kids.length+'곳)</span>':'')+'</label>';
          if(kids.length>1) h+=kids.map(_kidHtml).join('');
          return h;
        }).join(''));

    // 사업장 찾기 datalist + 사업장 보기 select (전체 사업장 기준, 선택 유지)
    /* 매칭명칭을 <맨 위>에 둔다 — 여러 사업장을 한 번에 잡는 이름이라 먼저 보이는 게 쓸모 있다 */
    d2Set('d2BizFindList', (ag.matchAll||[]).concat(ag.bizAll)
            .map(function(bz){ return '<option value="'+d2Esc(bz)+'"></option>'; }).join(''));
    var sel=document.getElementById('d2BizSel');
    if(sel){
      var keep=sel.value||'__ALL__';
      sel.innerHTML='<option value="__ALL__">전체 ('+ag.bizAll.length+' 사업장)</option>'
        + ag.bizAll.map(function(bz){ return '<option value="'+d2Esc(bz)+'">'+d2Esc(bz)+'</option>'; }).join('');
      sel.value = (keep!=='__ALL__' && ag.bizAll.indexOf(keep)>=0) ? keep : '__ALL__';
    }

    // 보기 모드가 사업장별/품목별이면 별도 그리드 렌더 후 종료 (출고장별은 아래 기존 로직)
    /* 가로표 보기 — 엑셀 [출고장 × 품목] 과 같은 모양을 화면에 그린다 (2026-08-28 요청) */
    if(D2_VIEW==='matrix'){ d2RenderMatrixView(ag, from, to); return; }
    /* 가로표에서 켠 가로 스크롤을 목록으로 돌아올 때 되돌린다 — 안 되돌리면 목록에도 가로 스크롤이 남는다 */
    var _sc0=document.querySelector('.d2-scroll'); if(_sc0) _sc0.style.overflowX='';
    if(D2_VIEW!=='zone'){ d2RenderGroupView(ag, from, to, D2_VIEW); return; }
    D2_UNIT='출고장';   // 출고장별 렌더

    // ── 표 영역: 단일일자=기존 배치 매트릭스 1개 / 기간·전체=출고일자별 독립 블록 여러 개
    d2SetGordPop(ag);   // 그룹순서 팝업·이동기준 = 전체 기준 1회
    var _scroll=document.querySelector('.d2-scroll');
    var _dset={}; (D2_DATA||[]).forEach(function(r){ var d=r.date||D2_TODAY; if(from && d<from) return; if(to && d>to) return; _dset[d]=1; });
    var _dates=Object.keys(_dset).sort().reverse();
    if(_dates.length<=1){
      _scroll.innerHTML='<table class="d2-tb" id="d2Tbl"></table>';
      document.getElementById('d2Tbl').innerHTML=d2BuildTableInner(ag, from, to, D2_DATA, D2_HISTALL, (_dates.length===1?_dates[0]:from));
    } else {
      var _html='';
      _dates.forEach(function(d){
        var rowsD=D2_DATA.filter(function(r){ return (r.date||D2_TODAY)===d; });
        var histD=(D2_HISTALL||[]).filter(function(r){ return (r.date||D2_TODAY)===d; });   // 이 날짜의 배치이력만 → 현재/직전
        var agD=d2Aggregate(rowsD, d, d);
        var zc=agD.zoneOrder.filter(function(zn){ return agD.zones[zn].tot>0; }).length;
        _html+='<div class="d2-datehdr">📅 '+d2Esc(d)+' 출고'
             +'<span class="d2-dsum">합계 '+d2Num(agD.totQty)+' BOX · 출고장 '+zc+'곳 · 품목 '+d2Num(agD.itemCnt)+'종</span></div>'
             +'<table class="d2-tb d2-tb-blk">'+d2BuildTableInner(agD, d, d, rowsD, histD, d)+'</table>';
      });
      _scroll.innerHTML=_html;
    }
    d2ApplyZoom();
    d2RenderTicker(ag);
    var _zwi=ag.zoneOrder.filter(function(zn){ var z=ag.zones[zn]; return Object.keys(z.rows).length>0 || (z.delRows&&z.delRows.length>0); });
    var _allColl=_zwi.length>0 && _zwi.every(function(zn){ return !!D2_COLL[zn]; });
    var _zt=document.getElementById('d2BtnZoneToggle'); if(_zt) _zt.innerHTML=_allColl ? '＋ 출고장 펼치기' : '－ 출고장 접기';
  }

  // 그룹순서(물류센터) 설정 팝업 + 이동기준 — 전체 ag 기준 1회 (날짜별 블록마다 안 함)
  function d2SetGordPop(ag){
    var zonesSorted=d2ZonesSorted(ag);
    var zonesWithItems=zonesSorted.filter(function(zn){ var z=ag.zones[zn]; return Object.keys(z.rows).length>0 || (z.delRows&&z.delRows.length>0); });
    var groups={}, gOrder=[];
    zonesWithItems.forEach(function(zn){ var g=ag.zones[zn].dc || zn; if(!groups[g]){ groups[g]=[]; gOrder.push(g); } groups[g].push(zn); });
    gOrder.sort(function(a,b){ var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);
      if(ia>=0&&ib>=0)return ia-ib; if(ia>=0)return -1; if(ib>=0)return 1; return a.localeCompare(b,'ko'); });
    window._d2GOrderNow=gOrder.slice();
    d2Set('d2GordPop',
      gOrder.map(function(g,ix){
        return '<label style="justify-content:space-between; cursor:default">'
          +'<span>'+(ix+1)+'. '+d2Esc(g)+'</span>'
          +'<span style="display:inline-flex; gap:3px">'
          +'<button class="btn-line" style="padding:1px 8px" data-g="'+d2Esc(g)+'" onclick="event.stopPropagation(); d2GordMove(this.getAttribute(\'data-g\'),-1)" title="위로">▲</button>'
          +'<button class="btn-line" style="padding:1px 8px" data-g="'+d2Esc(g)+'" onclick="event.stopPropagation(); d2GordMove(this.getAttribute(\'data-g\'),1)" title="아래로">▼</button>'
          +'</span></label>';
      }).join('')
      +'<label class="all" style="border-bottom:none; border-top:1px dashed var(--bd); margin-top:4px; border-radius:0 0 6px 6px; justify-content:center">'
      +'<button class="btn-line" style="padding:3px 12px" onclick="event.stopPropagation(); d2GordReset()">↺ 순서 초기화 (ㄱㄴㄷ순)</button></label>');
  }

  // 표 1개(HTML) 생성 — ag:집계, from/to:이 표 기간(블록이면 해당 출고일자), rowsForBatch:차수 폴백용 원본행, histForBatch:이 표의 배치이력(현재/직전)
  function d2BuildTableInner(ag, from, to, rowsForBatch, histForBatch, blockDate){
    // ── 한 그리드: 출고장(좌) + 내용(우), 맨 위 전체 합계 + 출고장별 소계(블록 상단)
    var zonesSorted=d2ZonesSorted(ag);
    var zonesWithItems=zonesSorted.filter(function(zn){ var z=ag.zones[zn]; return Object.keys(z.rows).length>0 || (z.delRows&&z.delRows.length>0); });
    function dlvLabel(z){   // 납기일자 — 출고일자와 같든 다르든 항상 표시
      var a=Object.keys(z.dlv).sort();
      return a.length ? ('납기일자 '+a.join(', ')) : '';
    }
    // ── 차수(배치) 매트릭스 — D2_HISTALL(전 배치)로 (출고장+사업장+품목) × 배치(업로드 분) 피벗. 이력 팝업과 동일 개념
    var SEP='';
    // 출고장마다 '자기 배치(차수)'가 독립 — 따로 업로드하면 차수·시각이 다르므로 전역 공통이 아니라,
    // 각 출고장 배치를 '상대 슬롯(현재→과거)'에 채우고, 실제 차수 라벨·시각·소계는 각 출고장 소계행에 표기
    var zBatch={}, HQ={};                 // zBatch[zn]={set,list:[bk..asc],label:{bk:..}} ; HQ[zn][rk][bk]=qty
    (histForBatch||D2_HISTALL||[]).forEach(function(r){
      var bk=(''+(r.uploadDttm||'')).slice(0,16); if(!bk) return;          // 분 단위 = 1업로드(차수)
      var zn=r.zone||'미배정';
      var zb=zBatch[zn]||(zBatch[zn]={set:{}, list:[], label:{}});
      if(!zb.set[bk]){ zb.set[bk]=1; zb.list.push(bk); }
      var ik=(r.code?r.code:('NM:'+r.item)); var rk=(r.biz||'')+'|'+ik;
      var zq=HQ[zn]||(HQ[zn]={}); (zq[rk]||(zq[rk]={})); zq[rk][bk]=(zq[rk][bk]||0)+(+r.qty||0);
    });
    var noHist=true; for(var _zz in zBatch){ noHist=false; break; }
    if(noHist){                            // 전 배치 없음 → 활성분을 각 출고장 '현재' 1배치로 폴백
      zBatch={}; HQ={};
      (rowsForBatch||D2_DATA||[]).forEach(function(r){ var zn=r.zone||'미배정';
        var zb=zBatch[zn]||(zBatch[zn]={set:{'__CUR__':1}, list:['__CUR__'], label:{'__CUR__':'출고수량'}});
        var ik=(r.code?r.code:('NM:'+r.item)); var rk=(r.biz||'')+'|'+ik;
        var zq=HQ[zn]||(HQ[zn]={}); (zq[rk]||(zq[rk]={})); zq[rk]['__CUR__']=(zq[rk]['__CUR__']||0)+(+r.qty||0); });
    } else {
      Object.keys(zBatch).forEach(function(zn){ var zb=zBatch[zn]; zb.list.sort();
        zb.list.forEach(function(bk,i){ zb.label[bk]=(i===0?'최초 생성':'생성 '+i+'차'); }); });
    }
    // 상대 슬롯 수 = 출고장 중 최대 배치 수. slot 0 = 현재(최신)
    var maxN=1; Object.keys(zBatch).forEach(function(zn){ maxN=Math.max(maxN, zBatch[zn].list.length); });
    function slotBk(zn, s){ var zb=zBatch[zn]; if(!zb) return null; var idx=zb.list.length-1-s; return idx>=0?zb.list[idx]:null; }
    // 동적 컬럼 = 기준 + 상대 차수 슬롯(현재/직전/N차 전)
    var slotCols=[]; for(var s0=0;s0<maxN;s0++){ slotCols.push({ k:'bcol'+s0, slot:s0, chg:(s0>=2), nm:(s0===0?'현재':s0===1?'직전':(s0+'차 전')), batch:true, f:(s0<2?0.045:0.042) }); }
    D2_COLS = D2_BASECOLS.concat(slotCols);
    function delRk(r){ return (r.biz||'')+'|'+(r.code?r.code:('NM:'+r.name)); }
    // 품목 셀 — 각 출고장 '자기 배치' 시간순으로 증감/신규/삭제 판정 후 상대 슬롯에 배치
    function itemRowCells(zn, rk){
      var zb=zBatch[zn]; var q=(HQ[zn]&&HQ[zn][rk])||{}; var cell={}, prev=null;
      (zb?zb.list:[]).forEach(function(bk,i){ var v=q[bk]; var cls,txt;
        if(v==null){ if(prev!=null){cls='hc-del';txt='삭제';} else {cls='hc-none';txt='·';} }
        else if(i===0||prev==null){ cls=(i===0?'hc-first':'hc-new'); txt=d2Num0(v)+((i>0&&v!==0)?' <b>신규</b>':''); }
        else if(v>prev){ cls='hc-up'; txt=d2Num0(v)+' <b>▲'+d2Num(v-prev)+'</b>'; }
        else if(v<prev){ cls='hc-dn'; txt=d2Num0(v)+' <b>▼'+d2Num(prev-v)+'</b>'; }
        else { cls=(v===0?'hc-none':'hc-same'); txt=d2Num0(v); }
        cell[bk]={cls:cls,txt:txt}; prev=v; });
      var h=''; for(var s=0;s<maxN;s++){ var bk=slotBk(zn,s); var c=bk?cell[bk]:null; h+='<td class="hc '+(c?c.cls:'hc-none')+'">'+(c?c.txt:'')+'</td>'; }
      return h;
    }
    // 현재(최신 배치) vs 직전 배치 수량이 다른 행 여부 — 감색(네이비) 강조용. 직전 배치 없으면(단일 배치) 비교 안 함
    function itemRowChanged(zn, rk){
      var zb=zBatch[zn]; if(!zb || zb.list.length<2) return false;
      var q=(HQ[zn]&&HQ[zn][rk])||{};
      var cur=q[slotBk(zn,0)]; var prv=q[slotBk(zn,1)];
      cur=(cur==null?null:cur); prv=(prv==null?null:prv);
      return cur!==prv;   // 증감·신규·삭제 모두 '차이'로 간주
    }
    // 출고장별 슬롯(bk) 소계 — 표시 품목 기준
    var zSub={};
    zonesWithItems.forEach(function(zn){ zSub[zn]={}; var zq=HQ[zn]||{}; var z=ag.zones[zn]; var seen={};
      Object.keys(z.rows).concat((z.delRows||[]).map(delRk)).forEach(function(rk){ if(seen[rk])return; seen[rk]=1;
        var q=zq[rk]||{}; (zBatch[zn]?zBatch[zn].list:[]).forEach(function(bk){ var v=q[bk]; if(v!=null) zSub[zn][bk]=(zSub[zn][bk]||0)+v; });
      });
    });
    // 소계행 셀 — 각 출고장의 '자기 차수' 라벨+시각 + 소계수량 (자기컬럼 표현)
    function zoneHeadCells(zn){ var zb=zBatch[zn]; var h='';
      for(var s=0;s<maxN;s++){ var bk=slotBk(zn,s);
        if(!bk){ h+='<td></td>'; continue; }
        var lab=(zb&&zb.label[bk])||''; var dt=(bk==='__CUR__'?'':(''+bk).slice(5,16));
        h+='<td class="num bcell-h"><span class="bh-lab">'+d2Esc(lab)+'</span>'+(dt?'<span class="bh-dt">'+d2Esc(dt)+'</span>':'')
          +'<span class="bh-sum">'+d2Num0((zSub[zn]&&zSub[zn][bk])||0)+'</span></td>';
      }
      return h;
    }
    // 합계행 셀 — 상대 슬롯별 합(현재 합계/직전 합계…)
    function slotTotalCells(zoneList){ var h='';
      for(var s=0;s<maxN;s++){ var sum=0; zoneList.forEach(function(zn){ var bk=slotBk(zn,s); if(bk!=null) sum+=((zSub[zn]||{})[bk]||0); }); h+='<td class="num">'+d2Num0(sum)+'</td>'; }
      return h;
    }

    // 컬럼 폭 — 비율(%). 경계 드래그 시 옆 열과 주고받아 총폭 고정
    var colg='<colgroup>'+D2_COLS.map(function(c){ return '<col id="d2col_'+c.k+'" style="width:'+(d2ColFrac(c.k)*100)+'%">'; }).join('')+'</colgroup>';
    // 헤더(단일 줄): 기준 + 현재/직전 + '변동사항'(2차전~N차전을 하나로 묶어 표시, 세부 차수는 소계행에서 확인)
    var chgCols = slotCols.filter(function(c){ return c.chg; });
    var fixCols = D2_BASECOLS.concat(slotCols.filter(function(c){ return !c.chg; }));
    var lastK = D2_COLS[D2_COLS.length-1].k;
    var thh='<thead><tr>'
      + fixCols.map(function(c){
          // 사업장별 조회 헤더 조정(2026-07-24): 좌측 'zone'=대표사업장, 중복이던 'biz'열을 '출고장'으로 재활용
          var hnm=c.nm;
          if(D2_VIEW==='biz'){ if(c.k==='zone') hnm='대표사업장'; else if(c.k==='biz') hnm='출고장'; }
          return '<th data-ck="'+c.k+'"'+(c.batch?' class="bcol"':'')+'>'+d2Esc(hnm)
            +(c.k!==lastK?'<span class="col-rz" data-ck="'+c.k+'" title="드래그하여 열 너비 조절 (더블클릭 시 기본값 복원)"></span>':'')+'</th>';
        }).join('')
      + (chgCols.length ? '<th class="bcol bcol-chg" colspan="'+chgCols.length+'">변동사항</th>' : '')
      + '</tr></thead>';
    var h=colg+thh+'<tbody>';
    /* 전체 합계 (상단) — **기준 6열** + 차수별 총계
       ★[2026-08-20 수정] 이 줄만 기준칸이 **5칸**이라 뒤의 숫자가 **한 칸씩 왼쪽으로 밀려**
         머리글(현재·직전·변동사항)과 어긋났다. 맨 오른쪽 칸이 비어 보이던 것이 그 증거다.
         (2026-08-07 에 **현재고** 칸을 No 뒤에 끼워 넣으면서 이 줄만 안 늘린 것이 원인.)
       ⚠기준칸은 zone·no·**stock**·biz·code·item **6칸**이다 — 아래 그룹행(colspan 5+1)·
         출고장행(1+1+1+colspan 3)·소계행(1+colspan 5) 은 모두 6칸으로 맞아 있었다.
       ⚠칸을 더하거나 뺄 때는 **이 네 줄을 함께** 고쳐야 한다. */
    h+='<tr class="tot"><td class="txt-l">전체 '+D2_UNIT+' 합계</td><td></td><td></td>'
      +'<td class="txt-l" colspan="3">'+D2_UNIT+' '+d2Num(zonesWithItems.length)+'곳 · 품목 '+d2Num(ag.itemCnt)+'종 · 사업장 '+d2Num(ag.bizCnt)+'곳</td>'
      + slotTotalCells(zonesWithItems)+'</tr>';

    // 물류센터(대표그룹) 단위로 묶기 — 데시보드1의 ▼ 그룹과 동일 개념 (그룹 = DC_NM, 없으면 출고장명)
    var groups={}, gOrder=[];
    zonesWithItems.forEach(function(zn){
      var g=ag.zones[zn].dc || zn;
      if(!groups[g]){ groups[g]=[]; gOrder.push(g); }
      groups[g].push(zn);
    });
    // 그룹 순서: 저장된 사용자 지정 순서(D2_GORD) 우선, 미지정 그룹은 ㄱㄴㄷ순 뒤에
    gOrder.sort(function(a,b){
      var ia=D2_GORD.indexOf(a), ib=D2_GORD.indexOf(b);
      if(ia>=0 && ib>=0) return ia-ib;
      if(ia>=0) return -1;
      if(ib>=0) return 1;
      return a.localeCompare(b,'ko');
    });
    /* ★센터 소계(csub) — 「오산물류센터도 평택처럼 SUM」(2026-08-30 요구).
       묶음 안 센터가 여럿(오산센터)이고 그 센터 출고장이 2줄 이상일 때만 끼워 넣는다
       (묶음=센터 하나면 아래 gsub 이 이미 그 센터 합계). */
    function d2CenterOf(zn){ return (''+zn).replace(/\s*직송$/,'').replace(/\s*\d+\s*$/,'').trim(); }
    gOrder.forEach(function(g){
      var zs=groups[g];
      var gColl=!!D2_GCOLL[g];
      // ▼ 대표그룹 헤더 (데시보드1 lgrp 형태: "▼ 광주물류센터" + "1개 출고장") — 클릭 시 그룹 접기/펼치기
      h+='<tr class="grp" data-g="'+d2Esc(g)+'" onclick="d2ToggleGroup(this.getAttribute(\'data-g\'))" title="클릭하여 그룹 접기/펼치기">'
        +'<td><span class="zcaret">'+(gColl?'▶':'▼')+'</span> '+d2Esc(g)+'</td>'
        +'<td colspan="5">'+zs.length+'개 '+D2_UNIT+(gColl?' <span style="color:#9aa7b3">— 접힘(클릭하여 펼치기)</span>':'')+'</td>'
        + slotTotalCells(zs)+'</tr>';

      var _cCnt={}; zs.forEach(function(zn){ var c=d2CenterOf(zn); _cCnt[c]=(_cCnt[c]||0)+1; });
      var _cMulti=Object.keys(_cCnt).length>1;
      var _cCur=null, _cZs=[];
      function _cFlush(){
        if(_cCur!==null && _cMulti && _cCnt[_cCur]>1){
          var _dS=0,_jS=0; _cZs.forEach(function(zn){ var t=ag.zones[zn].tot||0; if(/\s직송$/.test(zn)) _jS+=t; else _dS+=t; });
          h+='<tr class="csub"><td>'+d2Esc(_cCur)+' 합계'+d2BdxLabel(_dS,_jS)+'</td><td colspan="5"></td>'+slotTotalCells(_cZs)+'</tr>';
        }
        _cZs=[];
      }
      if(!gColl){
        zs.forEach(function(zn){
          var _zc=d2CenterOf(zn); if(_cCur!==null && _zc!==_cCur) _cFlush(); _cCur=_zc; _cZs.push(zn);
          var z=ag.zones[zn];
          var keys=Object.keys(z.rows).sort(function(a,b){
            var A=z.rows[a],B=z.rows[b];
            return A.biz.localeCompare(B.biz,'ko')||A.name.localeCompare(B.name,'ko');
          });
          var dels=(ag.histOn && z.delRows) ? z.delRows.slice().sort(function(a,b){ return (a.biz||'').localeCompare(b.biz||'','ko')||(a.name||'').localeCompare(b.name||'','ko'); }) : [];
          var coll=!!D2_COLL[zn];
          var dl=dlvLabel(z);
          var bodyRows=coll?0:(keys.length+dels.length);   // 소계 아래 표시 행 수
          var _jkC=/\s직송$/.test(zn)?' jikz':'';   // 직송 낱알 = 빨간 글씨(2026-08-30)
          var zoneCell='<td class="zone'+_jkC+'" rowspan="'+(1+bodyRows)+'" data-z="'+d2Esc(zn)+'" '
            +'onclick="d2ToggleZone(this.getAttribute(\'data-z\'))" title="클릭하여 접기/펼치기">'
            +'<span class="zcaret">'+(coll?'▶':'▼')+'</span>'+d2Esc(zn).replace(/\s직송$/,' <span class="jkw">직송</span>')+' '+D2_UNIT
            +(z.dcCd?'<span class="z-dc">('+d2Esc(z.dcCd)+')</span>':'')
            +((D2_VIEW==='zone' && z.dcCd && !/\s직송$/.test(zn))?'<span class="z-del" title="이 출고장의 해당 출고일자 출고분을 삭제(이력 보존)" data-dt="'+d2Esc(blockDate||from||'')+'" data-cd="'+d2Esc(z.dcCd||'')+'" data-iw="'+d2Esc(z.inwh||'')+'" data-zn="'+d2Esc(zn)+'" onclick="event.stopPropagation(); d2DelZoneFromGrid(this)">🗑️</span>':'')
            +(dl?'<span class="z-dlv">('+d2Esc(dl)+')</span>':'')+'</td>';
          // 출고장 소계(블록 상단) + 차수별 소계
          h+='<tr class="sub">'+zoneCell+'<td></td><td></td><td class="txt-l" colspan="3" data-z="'+d2Esc(zn)+'" '
            +'onclick="d2ToggleZone(this.getAttribute(\'data-z\'))" style="cursor:pointer" title="클릭하여 접기/펼치기">소계 '
            +'<span style="color:#9aa7b3">(품목 '+keys.length+'종'+(coll?' — 접힘':'')+')</span>'
            +'</td>'+zoneHeadCells(zn)+'</tr>';
          if(!coll){
            keys.forEach(function(k,ix){
              var r=z.rows[k];
              // 사업장별 뷰: 중복이던 '사업장' 칸을 '출고장' 화살표 콤보박스로 교체(원래 어느 출고장에서 나갔나, 2026-07-24)
              var bizCell=(D2_VIEW==='biz')?d2DistCell(r.ozones,'출고장'):d2Esc(r.biz);
              h+='<tr class="item'+(r.isNew?' r-new':'')+(itemRowChanged(zn,k)?' r-diff':'')+'"><td>'+(ix+1)+'</td>'
                + d2StockCell(r.code,'q')
                +'<td class="txt-l">'+bizCell+'</td>'
                +'<td>'+d2Esc(r.code)+'</td>'
                +'<td class="txt-l">'+d2Esc(r.name)+'</td>'
                + itemRowCells(zn, k)
                +'</tr>';
            });
            // 이번에 빠진(삭제) 품목 — 회색+취소선. 차수 열에서 삭제 시점 표기
            dels.forEach(function(r){
              var rk=delRk(r);
              h+='<tr class="item r-del"><td>–</td>'
                + d2StockCell(r.code,'q')
                +'<td class="txt-l">'+((D2_VIEW==='biz')?d2DistCell(r.ozones,'출고장'):d2Esc(r.biz))+'</td>'
                +'<td>'+d2Esc(r.code)+'</td>'
                +'<td class="txt-l">'+d2Esc(r.name)+' <span class="hist-badge del">삭제</span></td>'
                + itemRowCells(zn, rk)
                +'</tr>';
            });
          }
        });
      }
      _cFlush(); _cCur=null;   // 마지막 센터 소계(그룹이 안 접혔을 때만 의미 있음)
      // 물류센터 합계 행 (데시보드1 lsub 형태: "광주물류센터 합계") — 상대 슬롯별 합계
      var _gdS=0,_gjS=0; zs.forEach(function(zn){ var t=ag.zones[zn].tot||0; if(/\s직송$/.test(zn)) _gjS+=t; else _gdS+=t; });
      h+='<tr class="gsub"><td>'+d2Esc(g)+' 합계'+d2BdxLabel(_gdS,_gjS)+'</td><td colspan="5"></td>'
        + slotTotalCells(zs)+'</tr>';
    });
    h+='</tbody>';
    if(!zonesWithItems.length){
      h='<tbody><tr><td><div class="d2-empty">표시할 출고 데이터가 없습니다. 출고일자를 선택 후 <b>조회</b>하세요.</div></td></tr></tbody>';
    }
    return h;
  }

  // 기간(날짜별) 모드용 — 배치이력(D2_HISTALL)에서 출고장별 '현재 vs 직전' 변경 집계 (모든 날짜 합산)
  function d2ChangeFromHist(){
    var byDate={};
    (D2_HISTALL||[]).forEach(function(r){
      var d=r.date||D2_TODAY, zn=r.zone||'미배정', bk=(''+(r.uploadDttm||'')).slice(0,16); if(!bk) return;
      var dz=byDate[d]||(byDate[d]={});
      var z=dz[zn]||(dz[zn]={set:{}, list:[], HQ:{}});
      if(!z.set[bk]){ z.set[bk]=1; z.list.push(bk); }
      var ik=(r.code?r.code:('NM:'+r.item)); var rk=(r.biz||'')+'|'+ik;
      (z.HQ[rk]||(z.HQ[rk]={}))[bk]=(z.HQ[rk][bk]||0)+(+r.qty||0);
    });
    var zoneAgg={};
    Object.keys(byDate).forEach(function(d){
      var dz=byDate[d];
      Object.keys(dz).forEach(function(zn){
        var z=dz[zn]; z.list.sort();
        if(z.list.length<2) return;   // 직전 배치 없으면 비교 불가
        var cur=z.list[z.list.length-1], prv=z.list[z.list.length-2];
        var agg=zoneAgg[zn]||(zoneAgg[zn]={nw:0,up:0,dn:0,dl:0});
        Object.keys(z.HQ).forEach(function(rk){
          var c=z.HQ[rk][cur], p=z.HQ[rk][prv];
          if(c!=null && p==null) agg.nw++;
          else if(c==null && p!=null) agg.dl++;
          else if(c!=null && p!=null){ if(c>p) agg.up++; else if(c<p) agg.dn++; }
        });
      });
    });
    return zoneAgg;
  }

  // 출고장 변경 알림 — iframe(부모 셸) 안이면 부모의 독립 하단 바로 postMessage, 단독 실행이면 자체 바 렌더.
  function d2RenderTicker(ag){
    // 1) 변경요약 계산(신규/증감/삭제, 출고장별)
    var items=[], hide;
    if(ag.histOn){
      hide=false;
      // ★ 하단바 증감도 그리드 셀·행강조와 '동일 소스'(D2_HISTALL 배치 매트릭스)로 산출.
      //   과거엔 D2_PREV(z.rows.prevQty)로 계산 → '직전' 정의가 그리드(selectShipoutHistAll: UPLOAD_DTTM 슬롯, 출고장=DC+INWH)와
      //   달라(selectShipoutPrev: ACTION_YN='N'+MAX(JOB_SEQ) per DC_CD) 재생성 출고장에서 유령 ▲증가가 발생했음.
      //   d2ChangeFromHist()는 그리드 슬롯0(현재) vs 슬롯1(직전)과 완전히 같은 배치·같은 키(사업장|품목코드)로 비교하므로 셀과 항상 일치.
      var _za = (D2_HISTALL && D2_HISTALL.length) ? d2ChangeFromHist() : {};
      Object.keys(_za).sort(function(a,b){ return a.localeCompare(b,'ko'); }).forEach(function(zn){
        var c=_za[zn]; if(c.nw+c.up+c.dn+c.dl===0) return;
        var parts=[];
        if(c.nw) parts.push('<span class="tk-new">신규 '+c.nw+'</span>');
        if(c.up) parts.push('<span class="tk-up">▲증가 '+c.up+'</span>');
        if(c.dn) parts.push('<span class="tk-dn">▼감소 '+c.dn+'</span>');
        if(c.dl) parts.push('<span class="tk-del">삭제 '+c.dl+'</span>');
        items.push('<span class="tk-item" data-zone="'+d2Esc(zn)+'" title="클릭하면 해당 출고장으로 이동"><span class="z">'+d2Esc(zn)+'</span> '+parts.join(' · ')+'</span>');
      });
      if(!items.length) items.push('<span class="tk-item">✓ 직전 업로드 대비 변경 없음</span>');
    } else if(D2_DATA && D2_DATA.length){
      // 기간(날짜별) 모드 — 데이터만 있으면 무조건 알림 표시. 배치이력 있으면 변경요약, 없으면 기간 요약.
      hide=false;
      if(D2_HISTALL && D2_HISTALL.length){
        var _za=d2ChangeFromHist();
        Object.keys(_za).sort(function(a,b){ return a.localeCompare(b,'ko'); }).forEach(function(zn){
          var c=_za[zn]; if(c.nw+c.up+c.dn+c.dl===0) return;
          var parts=[];
          if(c.nw) parts.push('<span class="tk-new">신규 '+c.nw+'</span>');
          if(c.up) parts.push('<span class="tk-up">▲증가 '+c.up+'</span>');
          if(c.dn) parts.push('<span class="tk-dn">▼감소 '+c.dn+'</span>');
          if(c.dl) parts.push('<span class="tk-del">삭제 '+c.dl+'</span>');
          items.push('<span class="tk-item" data-zone="'+d2Esc(zn)+'" title="클릭하면 해당 출고장으로 이동"><span class="z">'+d2Esc(zn)+'</span> '+parts.join(' · ')+'</span>');
        });
      }
      if(!items.length){   // 변경 없음(또는 이력 없음) → 기간 요약이라도 표시
        var _nd={}, _zs={}, _q=0;
        D2_DATA.forEach(function(r){ _nd[r.date]=1; if(r.zone)_zs[r.zone]=1; _q+=(+r.qty||0); });
        var _ff=(document.getElementById('d2DateFrom')||{}).value||'', _tt=(document.getElementById('d2DateTo')||{}).value||'';
        items.push('<span class="tk-item">📅 기간 '+d2Esc(_ff||'~')+' ~ '+d2Esc(_tt||'~')+' · 출고 '+Object.keys(_nd).length+'일 · 출고장 '+Object.keys(_zs).length+'곳 · '+d2Num(_q)+' BOX <span class="tk-new">· 직전 대비 변경 없음</span></span>');
      }
    } else { hide=true; }
    var trackHtml = hide ? '' : ('<span class="tk-spacer"></span>'+items.join('<span class="tk-sep">|</span>'));

    // 2) iframe(부모 셸) 안이면 → 부모 독립 하단 바로 전송(자체 바는 숨김)
    if(window.self !== window.top){
      try{ window.parent.postMessage({type:'konetAsq', hide:hide, html:trackHtml}, '*'); }catch(e){}
      var tkL=document.getElementById('d2Ticker'); if(tkL) tkL.style.display='none';
      document.body.classList.remove('d2-asqbar-on');
      return;
    }

    // 3) 단독 실행(직접 접근) → 자체 하단 바 렌더
    var tk=document.getElementById('d2Ticker'), track=document.getElementById('d2TickerTrack');
    if(!tk||!track) return;
    if(hide){ tk.style.display='none'; track.innerHTML=''; document.body.classList.remove('d2-asqbar-on'); return; }
    track.innerHTML=trackHtml;
    tk.style.display='flex';
    document.body.classList.add('d2-asqbar-on');
    var dur=Math.max(20, Math.round(track.scrollWidth/90));
    track.style.animationDuration=dur+'s';
    track.style.animationPlayState = window._d2TkOff ? 'paused' : 'running';
    track.style.opacity = window._d2TkOff ? '0.35' : '1';
  }
  // 자체 바 멈춤/재생(단독 실행 시)
  function d2TickerToggle(){
    var track=document.getElementById('d2TickerTrack'), btn=document.getElementById('d2TickerToggle');
    if(!track) return;
    window._d2TkOff = !window._d2TkOff;
    track.style.animationPlayState = window._d2TkOff ? 'paused' : 'running';
    track.style.opacity = window._d2TkOff ? '0.35' : '1';
    if(btn) btn.textContent = window._d2TkOff ? '켜기' : '끄기';
  }

  // 알림 항목 클릭 → 해당 출고장으로 이동(그룹/출고장 펼치기 + 스크롤 + 하이라이트)
  function d2GotoZone(zn){
    if(!zn) return;
    var ag=d2Aggregate();
    var g=(ag.zones[zn] && ag.zones[zn].dc) || zn;
    if(D2_GCOLL[g]) delete D2_GCOLL[g];   // 그룹 펼치기
    if(D2_COLL[zn]) delete D2_COLL[zn];   // 출고장 펼치기
    d2Render();
    var cells=document.querySelectorAll('.d2-scroll [data-z]'), el=null;
    for(var i=0;i<cells.length;i++){ if(cells[i].getAttribute('data-z')===zn){ el=cells[i]; break; } }
    if(!el) return;
    if(el.scrollIntoView) el.scrollIntoView({behavior:'smooth', block:'center'});
    var orig=el.style.background;   // 노란 플래시
    el.style.transition='background .3s'; el.style.background='#fff3b0';
    setTimeout(function(){ el.style.background=orig||''; }, 1500);
  }
  // 부모 셸 바에서 온 요청 수신 — 이동(konetAsqGoto) / 새로고침(konetAsqRefresh)
  window.addEventListener('message', function(e){
    var d=e.data; if(!d) return;
    if(d.type==='konetAsqGoto'){ d2GotoZone(d.zone); return; }
    if(d.type==='konetAsqRefresh'){ d2Load(); return; }   // 현재 조회일자로 재조회 → 새 요약 postMessage
  });
  // 단독 실행(직접 접근) 시 자체 바 클릭 → 이동
  (function(){
    var tk=document.getElementById('d2Ticker');
    if(tk) tk.addEventListener('click', function(e){
      var it=e.target.closest ? e.target.closest('.tk-item[data-zone]') : null;
      if(it) d2GotoZone(it.getAttribute('data-zone'));
    });
  })();

  // 그리드 행 선택 표시(한 줄만) — #d2Tbl 은 재렌더에도 유지되므로 위임 리스너 1회 부착
  (function(){
    var tb=document.getElementById('d2Tbl');
    if(!tb) return;
    tb.addEventListener('click', function(e){
      var tr=e.target.closest ? e.target.closest('tr.item') : null;
      if(!tr) return;
      var prev=tb.querySelector('tr.item.d2-sel');
      if(prev===tr){ tr.classList.remove('d2-sel'); return; }   // 같은 행 재클릭 = 선택 해제
      if(prev) prev.classList.remove('d2-sel');
      tr.classList.add('d2-sel');
    });
  })();

  // 초기(로그인/진입): 항상 당일로 시작 — 이전 날짜 기억 안 함. (두 대시보드 동시 사용 중엔 storage 이벤트로 실시간 동기화)
  (function(){
    document.getElementById('d2DateFrom').value=D2_TODAY;
    document.getElementById('d2DateTo').value=D2_TODAY;
    d2Load();
  })();
</script>
</body>
</html>
