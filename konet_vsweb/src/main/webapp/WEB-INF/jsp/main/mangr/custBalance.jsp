<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<%-- ★날짜 칸에 [◀][▶][오늘] 을 자동으로 붙인다 (2026-08-17 요청) — 화면 수정 0.
     브라우저 기본 달력의 ↑↓ 는 앞/뒤가 안 읽혀 엉뚱한 달로 넘어가는 일이 잦았다.
     빼려면 그 칸에 data-nonav="1" --%>
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-datenav.js"></script>
<!--
  거래처별 채권·채무 (2026-07-26 요청 신설)
    · 메뉴 이름은 "거래처별 채권·채무"(사용자 유지 요청), 화면 표기는 쉬운 말로 — 받을금액 / 지급할금액 / 이월 / 남은금액.
      한번 회계용어(매출채권·미수금 …)로 바꿨다가 "너무 딱딱하다"는 지적으로 되돌렸다. 다시 바꾸자는 얘기가 나오면 이 이력을 먼저 확인할 것.
    · 왼쪽 = 거래처별 남은금액 한 줄씩 / 오른쪽 = 그 거래처의 월별 이력(최근부터)
      / 아래 = 그 거래처가 **특정일자 하루**에 한 거래 4탭(출고·매입·입금·출금) — 2026-07-27 추가

    ★★특정일자와 잔액은 서로 무관하다 (2026-07-27 사용자 확정)
      · 위(잔액·월별이력) = 기준월 말까지의 **누계**  — 종전 그대로, 아무것도 안 바뀌었다
      · 아래(건별 내역)   = 특정일자 **하루에 벌어진 일** — 이번에 새로 붙인 것
      한때 특정일자로 잔액까지 잘랐다(서버 낟알도 월→일자로 내렸다). "기존것에 합친것은 너무 복잡함"
      지적으로 **전부 되돌리고** 둘을 갈라 놓았다. 다시 합치자는 얘기가 나오면 이 이력부터 확인할 것.

    ★[특정일자 발생 칸] (2026-07-27 2차 요청 — "첫번째 내용은 유지하고 특정일자에 발생 내역도")
      잔액표에 **[특정일자 발생] 4칸(매출·수금·매입·지급)** 을 덧붙였다.
      · **누계 칸(이월·당월·남은금액)은 하나도 안 건드렸다** — 위 확정 그대로다.
        '잔액을 날짜로 자른 것'이 아니라 **그날 얼마가 움직였나를 옆에 나란히 붙인 것**이다.
      · 원천은 **일계장의 `selectDayBook`(fromDt=toDt=특정일자)** 을 그대로 쓴다.
        일계장과 금액 규칙(UNION 4갈래)이 같아 두 화면 숫자가 어긋날 수 없고, 서버를 새로 만들 필요도 없다.
        응답 중 `dt='00000000'`(전일누계) 줄은 여기서는 안 쓰고 버린다 — 누계는 이미 위 칸이 갖고 있다.
      · 이 칸을 보고 움직인 거래처를 찾아 줄을 누르면 **아래 건별 내역**에 그 하루가 펼쳐진다(같은 날짜).
    · 원천은 수금등록·지급등록 화면의 원장(selectCustLedger)과 같다. 다만 '한 거래처 × 일자'가 아니라
      '전 거래처 × 월' 로 넓혀 한 번에 받는다(selectCustBalance).

    ★잔액은 '전 기간 누계'다 — 기초잔액 테이블이 없고 전표가 곧 원장이라 그렇다.
      그래서 조회에 기간을 걸지 않는다. 대신 [기준월]까지만 누적해 '그 달 말 시점 잔액'을 만든다.
      기간(from~to)을 걸면 그 사이 증감만 남아 잔액이 아니게 된다 — 이 화면에서 가장 위험한 오해라
      화면에도 도움말에도 같은 말을 적어 둔다.

    ★받을금액이 0으로 보이는 거래처가 많은 게 정상이다.
      정산서(TBL_SALES_MST)에는 거래처코드가 없어 거래처마스터의 DC_CD(출고장코드)로만 이어진다.
      DC_CD 가 있는 거래처는 삼성웰스토리 지점 7곳뿐이고 나머지는 매입처라 매출이 없다.
-->
<style>
  :root{ --cb-bd:#dbe2ea; --cb-teal:#137a6c; --cb-red:#c0392b; }
  *{ box-sizing:border-box; }
  /* ★iframe 안 기본 body 여백(8px) 제거 — 제목 위 빈 자리를 없앤다(2026-07-29 요청) */
  html, body{ margin:0; padding:0; }
  /* ★여백은 전 화면 공통값 — 위 14px · 좌우 11px(0.3cm) (2026-08-03).
       종전엔 위 4px(+셸의 margin-top:-14px)·좌우 6px 이라 이 화면만 유독 위·옆에 붙어 있었다.
       좌우를 6px 로 줄였던 것은 옆으로 긴 표에 자리를 주려던 것(2026-07-28)인데, 셸이 갖고 있던
       좌우 14px 을 이번에 0 으로 내렸으므로 11px 로도 표에 쓰는 폭은 오히려 늘었다.
       (셸 logistics_demo2.jsp 의 .panel 주석 참고 — 값을 바꾸려면 양쪽을 함께 고칠 것) */
  .cb-wrap{ padding:14px 11px 14px; font-family:'맑은 고딕','Malgun Gothic',sans-serif; font-size:14px; color:#1f2a37; }
  .cb-wrap h2{ margin:0 0 4px; font-size:20px; }
  .cb-sub{ color:#1f2a37; margin-bottom:10px; font-size:12.5px; font-weight:600; }
  .cb-card{ background:#fff; border:1px solid var(--cb-bd); border-radius:10px; padding:11px 9px; margin-bottom:11px; }
  .cb-row{ display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; }
  .cb-fld{ display:flex; flex-direction:column; gap:3px; }
  .cb-fld label{ font-size:12px; font-weight:700; color:#1f2a37; }
  .cb-fld input, .cb-fld select{ height:32px; border:1px solid var(--cb-bd); border-radius:6px; padding:0 8px; font-size:13.5px; }
  .cb-btn{ height:32px; border:1px solid var(--cb-bd); background:#fff; border-radius:7px; padding:0 12px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; }
  .cb-btn:hover{ border-color:var(--cb-teal); }
  .cb-btn.teal{ background:var(--cb-teal); color:#fff; border-color:var(--cb-teal); }
  /* 체크박스도 버튼과 같은 높이·같은 바닥선에 세운다 — align-self:center 로 두면 혼자 떠 보인다(2026-07-26) */
  .cb-chk{ display:inline-flex; align-items:center; gap:6px; align-self:flex-end;
           height:32px; padding:0 10px; border:1px solid var(--cb-bd); border-radius:7px; background:#fff;
           font-size:13px; font-weight:700; color:#37475a; cursor:pointer; white-space:nowrap; }
  .cb-chk input{ margin:0; }
  .kpi{ display:flex; gap:10px; flex-wrap:wrap; margin:10px 0 0; }
  .kpi div{ flex:1 1 170px; border:1px solid var(--cb-bd); border-radius:8px; padding:8px 12px; background:#fbfdfc; }
  .kpi b{ display:block; font-size:19px; color:var(--cb-teal); margin-top:2px; white-space:nowrap; }
  .kpi b.red{ color:var(--cb-red); }
  .kpi span{ font-size:12px; color:#1f2a37; font-weight:700; }
  /* ★[함정] 주석 끝기호를 주석 안에 적지 말 것. 끝기호가 나오는 순간 주석이 거기서 닫히고,
       남은 글이 CSS 로 읽혀 **바로 뒤 규칙이 통째로 버려진다**. 2026-07-28 에 두 번 당했다 —
       .cb-two 의 display:flex 가 죽어 좌우 두 칸이 위아래로 접혔다(증상: 오른쪽이 텅 빔). */
  /* ★위아래 2단으로 확정 (2026-07-28 사용자 확정 — "이전내용 좋습니다, 보완만")
       거래처별 잔액 → 월별 이력 → 건별 내역 순으로 쌓고 **둘 다 화면 폭을 꽉 채운다**.
       좌우로 나눠 놨을 때는 어느 쪽을 늘려도 다른 쪽이 잘렸다 —
         · 왼쪽 잔액표는 16칸이라 다 보이려면 1084px 필요 (거래처·구분·받을4·지급4·발생4·순액·최근거래일)
         · 오른쪽 월별이력은 9칸이라 566px 필요
       둘을 한 줄에 넣으면 1650 이상이어야 해서 실제 창에서는 늘 한쪽이 스크롤이었다.
       위아래로 쌓으니 **양쪽 다 가로스크롤 없이** 들어온다 — 잔액표의 최근거래일까지 보인다.
     ★클래스 이름(.l/.r)은 예전 좌우 배치 때 붙인 것이라 지금은 위/아래라는 뜻이다. 이름만 남겨 둔다. */
  .cb-two{ display:block; }
  .cb-two > .l, .cb-two > .r{ width:100%; min-width:0; }
  /* 월별 이력은 한 달에 한 줄이라 보통 두세 줄이다 — 좌우 배치 때 쓰던 min-height:220px 를 그대로 두면
     폭이 넓어진 만큼 아래가 휑하게 빈다. 줄 수만큼만 차지하게 풀어 준다(2026-07-28 보완). */
  .cb-two > .r .cb-tbwrap{ min-height:0; max-height:44vh; }
  .cb-tit{ display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:7px; font-weight:800; }
  .cb-tit small{ font-weight:600; color:#2b3a48; font-size:12px; }
  .cb-tbwrap{ max-height:calc(100vh - 330px); min-height:220px; overflow:auto; border:1px solid var(--cb-bd); border-radius:8px; }
  table.cb-tb{ width:100%; border-collapse:collapse; font-size:13px; white-space:nowrap; }
  table.cb-tb th{ background:#b9ded4; color:#0b4f43; font-weight:800; box-shadow:inset 0 -2px 0 #0e6657; border:1px solid var(--cb-bd); padding:6px 8px; position:sticky; top:0; z-index:2; }
  /* ★머리글이 2줄이라 둘째 줄과 합계줄의 sticky 위치를 손으로 내려 준다(안 하면 겹쳐서 가린다) */
  table.cb-tb thead tr:nth-child(2) th{ top:28px; }
  table.cb-tb th.grp{ background:#e3edea; }
  /* ★머리글 정렬을 칸 내용에 맞춘다 (2026-07-27 요청) — 숫자칸 머리글은 오른쪽, 이름칸은 왼쪽.
       묶음 머리글(받을금액·지급할금액…)만 가운데로 남긴다. */
  table.cb-tb th.lft{ text-align:left; }
  table.cb-tb th.num{ text-align:right; }
  /* 거래처 칸 — 출고장 꼬리표를 뺀 만큼 폭을 줄이고, 이름이 길면 …로 줄인다(줄바꿈은 안 한다) */
  table.cb-tb td.txt .nm{ display:inline-block; max-width:158px; overflow:hidden;
                          text-overflow:ellipsis; vertical-align:bottom; }
  /* [특정일자 발생] 묶음 — 누계 칸과 눈으로 바로 갈리게 조회줄의 '특정일자'와 같은 호박색 계열로 */
  table.cb-tb th.grpd{ background:#f9ecd5; color:#7a4b0a; }
  table.cb-tb th.dayh{ background:#fdf5e6; color:#7a4b0a; }
  table.cb-tb td.dayc{ background:#fffaf1; }
  table.cb-tb tr.tot td.dayc{ background:#0f6a5e; }
  table.cb-tb tr.grow td.dayc{ background:#f3ecdd; }
  .amt-d{ color:#b45309; font-weight:700; }          /* 그날 발생 금액 */
  /* ★칸 폭 — 받을금액·지급할금액은 넓게, [특정일자 발생]은 조금 좁게 (2026-07-27 요청).
       발생 칸은 보통 한두 칸에만 금액이 들어 비어 있는 자리가 넓어 보였고,
       정작 매일 보는 누계 칸(당월매출·남은금액)이 좁아 숫자가 답답했다.
     ★[함정] 위치(nth-child) 기준이라 **칸 순서가 바뀌면 여기도 같이 고쳐야 한다**.
         본문 16칸 = 1 거래처 · 2 구분 · 3~6 받을금액 · 7~10 지급할금액 · 11~14 특정일자 발생 · 15 순액 · 16 최근거래일
         머리글 둘째 줄 12칸 = 1~4 받을금액 · 5~8 지급할금액 · 9~12 특정일자 발생 */
  #cbList thead tr:nth-child(2) th:nth-child(-n+8){ min-width:98px; }
  #cbList tbody td:nth-child(n+3):nth-child(-n+10){ min-width:98px; }
  #cbList th.dayh, #cbList td.dayc{ min-width:76px; }
  /* ★거래처 칸 가로 고정 (2026-07-27 요청) — 최근거래일까지 옆으로 밀어 봐도 이름은 남아 있어야 한다.
       머리글은 **첫 줄의 첫 칸만** 잡는다(둘째 줄 '이월'이 딸려 붙지 않게 tr:first-child 필수).
       sticky 칸은 배경이 비치면 안 되므로 줄 종류마다 배경색을 다시 지정한다. */
  /* ★머리글은 고정된 거래처 칸(z-index:3~4)보다 반드시 위에 있어야 한다 —
       안 그러면 세로로 스크롤할 때 거래처 이름이 머리글을 뚫고 올라온다. */
  #cbList thead th{ z-index:7; }
  #cbList thead tr:first-child th:first-child{ position:sticky; left:0; top:0; z-index:8;
                                               background:#eef3f2; border-right:2px solid #cfe0db; }
  #cbList tbody td:first-child{ position:sticky; left:0; z-index:3;
                                background:#fff; border-right:2px solid #cfe0db; }
  #cbList tbody tr.tot td:first-child{ background:var(--cb-teal); z-index:4; }
  #cbList tbody tr.grow td:first-child{ background:#e9f1ef; }
  #cbList tbody tr.on td:first-child{ background:#fdeef0; }
  #cbList tbody tr.pick:hover td:first-child{ background:#f3f8f6; }
  table.cb-tb th.sortable{ cursor:pointer; }
  table.cb-tb th.sortable:hover{ color:var(--cb-teal); }
  table.cb-tb td{ border:1px solid var(--cb-bd); padding:6px 8px; text-align:right; }
  table.cb-tb td.txt{ text-align:left; }
  table.cb-tb td.ctr{ text-align:center; }
  table.cb-tb tr.tot td{ background:var(--cb-teal); color:#fff; font-weight:800; position:sticky; top:56px; z-index:1; }
  table.cb-tb tbody tr.pick{ cursor:pointer; }
  table.cb-tb tbody tr.pick:hover td{ background:#f3f8f6; }
  table.cb-tb tbody tr.on td{ background:#fdeef0; font-weight:700; }
  table.cb-tb tr.mtot td{ background:#eef3f2; font-weight:800; }
  /* 하단 건별 내역의 합계는 **맨 위**(2026-07-27 요청) — 머리글(28px) 바로 아래에 붙여 스크롤해도 따라오게 */
  #cbDtl tr.mtot td{ position:sticky; top:28px; z-index:1; border-bottom:2px solid #cfe0db; }
  /* ★건별 내역 칸 폭 — 품목명이 남는 자리를 다 먹어 수량·단가·금액·비고가 답답했다(2026-07-28 요청).
       숫자·비고 칸에 min-width 를 깔아 두면 표(width:100%)가 남는 자리를 품목명 대신 이쪽에 준다.
       품목명 글자를 자르는 것이 아니라 **남는 자리 배분만** 바꾸는 것이라 이름은 그대로 다 보인다.
     ★[함정] 탭에 따라 칸수가 다르다 — 물건 탭 10칸(…6 품목명·7 수량·8 단가·9 금액·10 비고) / 돈 탭 7칸(…6 금액·7 비고).
         그래서 수량·단가는 nth-child + nth-last-child 를 같이 걸어 **10칸일 때만** 잡고,
         금액·비고는 두 탭 모두 끝에서 2번째·마지막이라 뒤에서 세어 잡는다(합계줄 colspan 에도 안 흔들린다). */
  #cbDtl th:nth-child(7):nth-last-child(4), #cbDtl td:nth-child(7):nth-last-child(4){ min-width:74px; }   /* 수량 */
  #cbDtl th:nth-child(8):nth-last-child(3), #cbDtl td:nth-child(8):nth-last-child(3){ min-width:92px; }   /* 단가 */
  #cbDtl th:nth-last-child(2), #cbDtl td:nth-last-child(2){ min-width:112px; }                            /* 금액 */
  #cbDtl th:last-child,        #cbDtl td:last-child{ min-width:72px; }                                    /* 비고 */
  /* 출고장 묶음 머리행 — 대시보드와 같은 2단 트리 */
  table.cb-tb tr.grow td{ background:#e9f1ef; font-weight:800; border-top:2px solid #cfe0db; }
  table.cb-tb tr.grow td .cnt{ font-size:11px; font-weight:600; color:#5a6b7a; }
  /* 접기 버튼 — 머리행 전체가 아니라 이 화살표만 눌린다(2026-07-26 요청) */
  table.cb-tb tr.grow td .tg{ display:inline-block; width:18px; text-align:center; cursor:pointer;
                              border-radius:4px; color:#37475a; user-select:none; }
  table.cb-tb tr.grow td .tg:hover{ background:#cfe0db; color:#0f5f54; }
  table.cb-tb td.ind{ padding-left:22px; }
  /* 3단(월·년 모드) — 일자(월) ▸ 출고장 묶음 ▸ 거래처 */
  table.cb-tb td.ind2{ padding-left:40px; }
  /* ★월·년 모드는 위 표를 조금 낮춘다 (2026-07-29 요청 "월별 조금줄여서 세부내역 볼수있게") —
       일자 낟알을 펼치면 표가 화면을 다 먹어 아래 [건별 내역]이 스크롤 밖으로 밀려났다.
       가운데 이력 카드가 없어진 자리를 표가 다 차지하지 않게 상한만 낮춘다(내용은 안에서 스크롤). */
  .cb-wrap.cb-occ .l .cb-tbwrap{ max-height:52vh; }
  /* 일자(월) 머리행 — 그 하루(한 달)의 소계. 묶음 머리행보다 한 단계 위라 색을 진하게 준다.
     ★글자도 **한 단계 크게**(2026-07-29 요청) — 소계 줄이 거래처 줄에 묻히지 않게. */
  /* ★낟알(일자·월) 사이를 선으로 가른다 (2026-07-30 요청 "월에 일자, 년에 월 표시 라인 구분되게") —
       종전 2px 연한 선은 아래 거래처 줄들과 붙어 보여 "여기서 다음 날짜가 시작된다"가 안 읽혔다.
       위 = 진한 teal 3px(구역 시작) / 아래 = 얇은 선(머리행과 거래처 줄 분리).
       월 모드(일자)·년 모드(월)가 같은 dgrow 를 쓰므로 이 한 곳으로 둘 다 적용된다.
       ※ 묶음 머리행(.grow)은 2px 연한 선 그대로 — 단계 차이가 보이게 일부러 다르게 둔다. */
  table.cb-tb tr.dgrow td{ background:#dfeeea; font-size:14.5px;
                           border-top:3px solid var(--cb-teal); border-bottom:1px solid #b9d5ce; }
  table.cb-tb tr.dgrow td b{ font-size:15.5px; }
  /* 첫 낟알 앞에는 보통 ■합계 줄(tr.tot)이 있어 굵은 선이 오히려 구분에 도움이 된다.
     합계 줄이 없는 경우(=낟알이 tbody 첫 줄)만 겹쳐 보이므로 그때만 위 선을 뺀다. */
  table.cb-tb tbody tr.dgrow:first-child td{ border-top:0; }
  #cbList tbody tr.dgrow td:first-child{ background:#dfeeea; }
  /* 년 모드에서 고른 달 — 아래 [일자별 발생]이 이 달을 보고 있다는 표시 */
  table.cb-tb tr.dgrow.on td{ background:#cfe6df; }
  #cbList tbody tr.dgrow.on td:first-child{ background:#cfe6df; }
  .amt-r{ color:var(--cb-teal); font-weight:700; }   /* 받을금액 */
  .amt-p{ color:var(--cb-red);  font-weight:700; }   /* 지급할금액 */
  .gb{ font-size:11px; padding:1px 6px; border-radius:9px; background:#eef3f2; color:#37475a; font-weight:700; }
  /* 구분 꼬리표 — gbx = 거래처마스터 등록값과 다름(실거래로 판정한 값을 보여주는 중) / gbm = 거래가 없어 마스터값을 그대로 */
  .gb.gbx{ background:#fdf0dc; color:#7a4b0a; }
  .gb.gbx i{ font-style:normal; margin-left:1px; }
  .gb.gbm{ opacity:.5; }
  /* 하단 건별 명세 — 탭 + 안내줄 */
  .cb-tabs{ display:flex; gap:5px; flex-wrap:wrap; }
  .cb-tab{ border:1px solid var(--cb-bd); background:#fff; border-radius:7px; padding:4px 11px; cursor:pointer;
           font-size:12.5px; font-weight:700; color:#37475a; white-space:nowrap; }
  .cb-tab:hover{ border-color:var(--cb-teal); }
  .cb-tab.on{ background:var(--cb-teal); color:#fff; border-color:var(--cb-teal); }
  /* ★보기 방식(누적/월/년) 탭은 조금 크게 (2026-07-29 요청) — 화면 성격을 가르는 탭이라 눈에 먼저 들어와야 한다.
       아래 [건별 내역] 탭(.cb-tabs 안의 같은 클래스)은 종전 크기 그대로 둔다. */
  .cb-modetabs .cb-tab{ font-size:14.5px; font-weight:800; padding:7px 17px; border-radius:8px; }
  .cb-tab .c{ font-weight:600; opacity:.75; margin-left:3px; }
  .cb-dtlnote{ margin-top:6px; font-size:12px; color:#5a6b7a; font-weight:600; }
  .cb-dtlnote b{ color:#37475a; }
  .cb-msg{ padding:24px; text-align:center; color:#2b3a48; font-size:13.5px; font-weight:600; }
  .cb-note{ font-size:12.5px; color:#1f2a37; line-height:1.75; font-weight:600; }
  .cb-note b{ color:#37475a; }
</style>

<div class="cb-wrap" id="cbWrap">
  <%-- ★제목 옆 부제("— 받을금액 · 지급할금액")와 그 아래 설명 줄은 2026-07-29 사용자 요청으로 **삭제**.
         (누적·월·년 세 모드 모두) 같은 설명은 [ℹ️ 도움말] 안에 그대로 있다. 다시 넣자는 얘기가 나오면 이 이력부터 확인. --%>
  <h2>💳 거래처별 채권·채무</h2>

  <%-- ★보기 방식 3가지 (2026-07-29 요청) — 누적 / 월 / 년.
         · 누적 = 종전 화면 그대로(기초부터 기준월 말까지 쌓인 **잔액**)
         · 월   = 시작일~종료일 사이에 **발생한 것만** (일자별로 편다)
         · 년   = 그 해 1/1~오늘(지난 해는 12/31) 사이에 **발생한 것만** (월별로 접는다)
       ★[중요] 누적은 '남은 돈', 월·년은 '그 사이 움직인 돈'이다 — 서로 다른 것을 보는 화면이라
         숫자가 안 맞는 것이 정상이다(도움말에도 같은 말을 적어 뒀다). --%>
  <div class="cb-tabs cb-modetabs" style="margin-bottom:9px">
    <span class="cb-tab on" id="cbMdC" onclick="cbMode('cum')" title="기초부터 기준월 말까지 쌓인 잔액 — 지금 실제로 받을(줄) 돈">📊 누적 채권·채무</span>
    <span class="cb-tab"    id="cbMdM" onclick="cbMode('mon')" title="고른 기간(한 달)에 발생한 것만 — 일자별로 폅니다">🗓️ 월 채권·채무</span>
    <span class="cb-tab"    id="cbMdY" onclick="cbMode('yr')"  title="고른 해에 발생한 것만 — 월별로 접어서 봅니다">📆 년 채권·채무</span>
  </div>

  <div class="cb-card">
    <div class="cb-row">
      <div class="cb-fld" id="cbYmFld" style="flex:0 0 150px"><label>기준월 (이 달 말 기준 잔액)</label><input type="month" id="cbYm" onchange="cbRender()"></div>
      <%-- 월·년 모드 전용 기간칸 — 누적 모드에서는 숨긴다(누적은 기간을 걸면 잔액이 아니게 되므로) --%>
      <div class="cb-fld" id="cbFromFld" style="flex:0 0 165px; display:none"><label style="color:#137a6c">시작일자 (발생분)</label>
        <input type="date" id="cbFrom" onchange="cbOccLoad()"></div>
      <div class="cb-fld" id="cbToFld" style="flex:0 0 165px; display:none"><label style="color:#137a6c">종료일자 (발생분)</label>
        <input type="date" id="cbTo" onchange="cbOccLoad()"></div>
      <%-- 빠른 선택 — 월 모드=이번달/지난달, 년 모드=올해/작년. '지나지 않은 해'는 종료일자가 오늘이 된다 --%>
      <span id="cbQuick" style="display:none; align-self:flex-end; gap:5px"></span>
      <%-- ★특정일자 (2026-07-27 요청) — 위 '잔액(누계)' 칸과는 **무관**하다.
             이 날짜가 쓰이는 곳은 딱 둘 : 표의 [특정일자 발생] 4칸 + 아래 건별 내역.
             한때 이 날짜로 잔액까지 잘랐다가 "기존것에 합친것은 너무 복잡함" 지적으로 갈라 놓았다.
             ★잔액(이월·당월·남은금액)은 앞으로도 기준월 것이다 — 날짜로 자르지 말 것. --%>
      <div class="cb-fld" id="cbDtFld" style="flex:0 0 195px"><label style="color:#b45309">특정일자 (발생 칸·아래 내역)</label>
        <input type="date" id="cbDt" onchange="cbDayChg()" style="border-color:#e3c08a"></div>
      <div class="cb-fld" style="flex:0 0 195px"><label>보기</label>
        <select id="cbFilter" onchange="cbRender()">
          <option value="bal">잔액 있는 거래처만</option>
          <option value="recv">받을금액 있는 곳만</option>
          <option value="pay">지급할금액 있는 곳만</option>
          <option value="day">특정일자에 거래 있는 곳만</option>
          <option value="all">전체(거래 있는 곳)</option>
        </select>
      </div>
      <div class="cb-fld" style="flex:0 0 200px"><label>거래처 검색(코드·이름)</label>
        <input type="text" id="cbFind" placeholder="예: 대양 / 00272" onkeyup="if(event.keyCode===13) cbRender()">
      </div>
      <button class="cb-btn teal" onclick="cbLoad()">조회</button>
      <%-- ★[오늘]을 [이번 달] 앞으로 (2026-07-28 요청) — 매일 누르는 것이 [오늘]이라 조회 버튼 바로 옆에 둔다 --%>
      <button class="cb-btn" id="cbTodayBtn" onclick="cbToday()" title="특정일자를 오늘로 (발생 칸 · 아래 건별 내역)">오늘</button>
      <button class="cb-btn" id="cbThisMonBtn" onclick="cbThisMonth()" title="기준월을 이번 달로 (잔액)">이번 달</button>
      <%-- 출고장 묶음(대시보드와 같은 규칙) — 기본 켬. 끄면 거래처만 평평하게 나온다 --%>
      <label class="cb-chk"><input type="checkbox" id="cbGroup" checked onchange="cbRender()"> 출고장 묶음</label>
      <%-- 글자는 cbAllBtn() 이 지금 상태에 맞춰 [⊟ 접기] ↔ [⊞ 펼치기] 로 바꾼다 --%>
      <button class="cb-btn" id="cbAllBtn" onclick="cbToggleAll()" title="묶음 전체 접기/펼치기">⊟ 접기</button>
      <button class="cb-btn" onclick="cbHelp()" id="cbHelpBtn" style="margin-left:auto">ℹ️ 도움말</button>
    </div>
    <%-- KPI 이름은 모드에 따라 바뀐다(cbModeUI) — 누적은 '잔액', 월·년은 '그 기간에 발생한 금액' --%>
    <div class="kpi">
      <div><span id="kRecvL">받을금액 합계</span><b id="kRecv">—</b></div>
      <div><span id="kPayL">지급할금액 합계</span><b id="kPay" class="red">—</b></div>
      <div><span id="kNetL">순액 (받을−지급)</span><b id="kNet">—</b></div>
      <div><span id="kRecvCntL">받을 거래처</span><b id="kRecvCnt">—</b></div>
      <div><span id="kPayCntL">지급 거래처</span><b id="kPayCnt">—</b></div>
      <div><span id="kRangeL">자료 있는 달</span><b id="kRange" style="font-size:15px; padding-top:3px">조회 전</b></div>
    </div>
  </div>

  <%-- 도움말 — 기본 접힘(다른 화면과 같은 방식) --%>
  <div class="cb-card" id="cbHelpBox" style="display:none; border-color:#9fcfc5; background:#f6fbfa">
    <div class="cb-tit"><span>ℹ️ 이 화면 보는 법</span><button class="cb-btn" onclick="cbHelp(false)">닫기 ✕</button></div>
    <div class="cb-note">
      <b style="color:#137a6c">■ 보기 방식 3가지</b> <span style="color:#5a6b7a">— 맨 위 탭</span><br>
      &nbsp;&nbsp;· <b>📊 누적 채권·채무</b> — 처음부터 <b>기준월 말까지 쌓인 잔액</b>입니다. <b>지금 실제로 받을(줄) 돈</b>이 이것입니다.<br>
      &nbsp;&nbsp;· <b>🗓️ 월 채권·채무</b> — 고른 <b>기간에 발생한 것만</b>. <b>발생일자마다</b> 소계 줄이 서고, <b>▶</b> 를 누르면 그 날 움직인
      <b>거래처별 발생표</b>가 펼쳐집니다(출고장 묶음도 그대로). <b>거래가 있는 날만</b> 줄이 생기고 <b>처음엔 접혀</b> 있어 하루하루가 한눈에 들어옵니다.
      거래처 줄을 누르면 화면 아래에 <b>그 일자의 건별 내역</b>이 나옵니다. (기본 기간 = 이번 달 1일 ~ 오늘)<br>
      &nbsp;&nbsp;· <b>📆 년 채권·채무</b> — 고른 <b>해에 발생한 것만</b>. 위 표가 <b>월마다</b> 소계 줄로 서고 펼치면 그 달의 거래처가 나옵니다.
      <b>거래가 있는 달만</b> 표시됩니다. (기본 = 올해 1월 1일 ~ <b>오늘</b>. 지나간 해를 고르면 12월 31일까지)<br>
      &nbsp;&nbsp;· <b>⊟ 접기</b> 버튼은 <b>일자(월) 줄까지 한꺼번에</b> 여닫습니다. 월·년에서는 <b>월별 이력</b>표를 따로 두지 않습니다 —
      위 표가 이미 일자(월)별이라 같은 것을 두 번 보게 되기 때문입니다.<br>
      &nbsp;&nbsp;· 월·년의 <b>차액</b> = <b>매출 − 수금</b>(받을 쪽) / <b>매입 − 지급</b>(지급 쪽) = 그 사이에 <b>늘어난</b> 금액입니다.<br>
      <span style="color:#b45309"><b>★누적과 월·년은 서로 다른 것을 보는 화면입니다.</b></span>
      누적은 <b>남은 돈</b>, 월·년은 <b>그 사이 움직인 돈</b>이라 <b>월 발생분을 다 더해도 누적 잔액과 같아지지 않습니다</b>(누적에는 그 전에 쌓인 것이 들어 있습니다).
      월·년 화면의 금액 규칙은 <b>일계장</b>과 같습니다.<br><br>

      <b style="color:#137a6c">■ 금액이 어떻게 나오나</b><br>
      <b>받을금액</b> = (매출액 − 매출할인) − 수금액 &nbsp;/&nbsp; <b>지급할금액</b> = (매입액 − 매입할인) − 지급액<br>
      &nbsp;&nbsp;· <b>매출액</b> = 출고장 정산서 + 판매등록 전표 &nbsp;· <b>수금액</b> = 수금등록 전표(+판매전표의 즉시수금)<br>
      &nbsp;&nbsp;· <b>매입액</b> = 매입등록 전표 &nbsp;· <b>지급액</b> = 지급등록 전표(+매입전표의 즉시지급)<br>
      &nbsp;&nbsp;· <b>순액</b> = 받을금액 − 지급할금액 (상계 처리는 하지 않고 참고로만 보여줍니다)<br>
      수금등록·지급등록 화면의 <b>거래처 원장과 같은 원천</b>이라 두 화면 숫자가 맞습니다.<br>
      <span style="color:#b45309"><b>★매출 그래프·마감현황보다 매출이 작게 나옵니다 — 의도된 차이입니다.</b></span>
      그 화면들은 <b>정산서가 아직 안 온 출고분(추정)</b>까지 매출로 잡지만,
      여기 받을금액은 <b>청구가 확정된 것만</b>(정산서 + 직접 판 전표) 셉니다. 아직 청구서가 없는 건은 받을 돈으로 세지 않습니다.<br><br>

      <b style="color:#137a6c">■ 기준월 · 이월 · 당월</b> <span style="color:#5a6b7a">— 위쪽 잔액표</span><br>
      <b style="color:#137a6c">이월 + 당월매출 − 당월수금 = 남은금액</b> (지급 쪽도 같은 구조: 이월 + 당월매입 − 당월지급 = 남은금액)<br>
      &nbsp;&nbsp;· <b>이월</b> — 기준월 <b>앞달 말</b>의 잔액. 여러 달 밀린 못 받은·못 준 돈이 전부 여기 쌓입니다.<br>
      &nbsp;&nbsp;· <b>당월</b> — 기준월 <b>그 달에만</b> 생긴 매출·수금(매입·지급).<br>
      &nbsp;&nbsp;· <b>남은금액</b> — 처음부터 그 달 말까지 쌓인 금액 = 지금 실제로 받을(줄) 돈.<br>
      기준월을 과거로 옮기면 <b>그 시점</b> 기준으로 이월·당월·잔액이 다시 계산됩니다. 기본값은 이번 달.<br>
      <span style="color:#b45309">이 화면에 '기간(부터~까지)'이 없는 이유 — 기간으로 자르면 그 사이 증감만 남아 잔액이 아니게 됩니다.</span><br><br>

      <b style="color:#137a6c">■ 특정일자 — 발생 칸 · 아래 건별 내역</b><br>
      <span style="color:#b45309"><b>★조회줄의 「특정일자」는 위 잔액(이월·당월·남은금액)을 바꾸지 않습니다.</b></span>
      이 날짜가 쓰이는 곳은 <b>두 군데</b>입니다 — 표 오른쪽의 <b style="color:#b45309">특정일자 발생</b> 칸과, 화면 <b>아래 건별 내역</b>입니다.
      잔액은 <b>기준월</b>, 이 둘은 <b>특정일자</b>로 따로 움직입니다.<br>
      &nbsp;&nbsp;· <b style="color:#b45309">특정일자 발생</b> — 그 <b>하루에 움직인</b> 매출·수금·매입·지급입니다.
      왼쪽 누계 칸과 <b>더하거나 빼는 칸이 아니라</b>, 나란히 놓고 보는 칸입니다(오늘 무슨 일이 있었나).
      금액 규칙은 <b>일계장</b>과 같아 두 화면 숫자가 맞습니다.<br>
      &nbsp;&nbsp;· 보기를 <b>특정일자에 거래 있는 곳만</b>으로 두면 그날 움직인 거래처만 남습니다.<br>
      왼쪽에서 거래처를 고르면 화면 아래에 그 거래처가 <b>그 날 하루</b>에 한 거래가 건별로 펼쳐집니다 —
      <b>출고내역</b>(정산서 품목행 + 직접 판 판매전표) · <b>매입내역</b>(매입전표 명세) · <b>입금내역</b>(수금 전표) · <b>출금내역</b>(지급 전표).<br>
      &nbsp;&nbsp;· 탭 옆 숫자는 그 날 그 종류의 <b>건수</b>라, 눌러보지 않아도 어디에 자료가 있는지 알 수 있습니다.<br>
      &nbsp;&nbsp;· 위(누계)와 아래(하루)는 <b>서로 다른 것을 보는 표</b>라 숫자가 맞지 않는 것이 정상입니다.<br>
      &nbsp;&nbsp;· 전표(판매·매입)는 <b>명세 줄</b>을 폅니다. 전표 머리에 할인이 걸려 있으면 명세 합계가 잔액에 잡힌 전표 금액과 다를 수 있습니다.<br><br>

      <b style="color:#137a6c">■ 출고장 묶음</b><br>
      물류센터 거래처(삼성웰스토리 지점)는 <b>대시보드·매출마감과 같은 규칙</b>으로 묶입니다 —
      <b>오산센터</b>(왜관·김해·광주·제주·오산), <b>용인</b>, <b>평택</b>은 각각 따로. 그 밖의 거래처는 <b>기타 거래처</b>로 모입니다.
      묶음 줄을 누르면 접히고, <b>⊟ 접기</b>로 전체를 한 번에 여닫습니다. 묶음 없이 보려면 <b>출고장 묶음</b> 체크를 끄면 됩니다.<br><br>

      <b style="color:#137a6c">■ 오른쪽 월별 이력</b><br>
      왼쪽에서 거래처 줄을 누르면 그 거래처의 <b>달마다 이월 · 매출 · 수금 · 남은금액</b>이 나옵니다(최근 달부터).
      각 줄도 <b>이월 + 매출 − 수금 = 남은금액</b>이 그대로 맞고, 그 달 남은금액이 다음 달 이월이 됩니다.
      맨 위 <b>누계</b> 줄은 기준월까지의 발생 합계입니다.<br><br>

      <b style="color:#b45309">■ 읽을 때 주의</b><br>
      &nbsp;&nbsp;· <b>받을금액이 0인 거래처가 대부분인 것은 정상</b>입니다. 정산서에는 거래처코드가 없어
      거래처마스터의 <b>출고장코드(DC_CD)</b>로만 매출이 이어지는데, 그 코드가 있는 곳은 <b>삼성웰스토리 지점 7곳</b>뿐입니다.
      나머지는 매입처라 매출이 없습니다.<br>
      &nbsp;&nbsp;· <b>구분(매입·매출)은 실제 거래로 판정</b>합니다 — 매출·수금만 있으면 <b>매출</b>, 매입·지급만 있으면 <b>매입</b>, 둘 다면 <b>매입&amp;매출</b>(기준월과 무관하게 전 기간으로 봅니다).
      거래처관리에 <b>등록된 거래유형과 다르면 호박색에 <span class="gb gbx">매출<i>*</i></span> 처럼 별표</b>가 붙습니다. 거래가 아예 없는 곳은 등록값을 흐리게 보여줍니다.
      꼬리표에 마우스를 올리면 등록값이 같이 나옵니다. <b>여기서 등록값을 고치지는 않습니다</b> — 거래처관리 화면에서 수정하세요.<br>
      &nbsp;&nbsp;· <b>매입·매출을 같이 하는 거래처</b>는 한 줄에 양쪽 금액이 다 뜹니다. <b>상계(서로 빼기)는 하지 않고</b> 순액 칸으로만 보여줍니다.<br>
      &nbsp;&nbsp;· 여기서 <b>수정은 안 됩니다</b>. 금액을 바꾸려면 판매·매입·수금·지급 <b>등록 화면에서 전표를 고쳐야</b> 합니다.<br>
      &nbsp;&nbsp;· 사업장(거래처관리(사업장), TBL_BIZI_MST)과는 <b>다른 모집단</b>입니다. 여기 나오는 건 회계 거래처입니다.
    </div>
  </div>

  <div class="cb-two">
    <div class="l">
      <div class="cb-card">
        <div class="cb-tit"><span id="cbListTit">🏢 거래처별 잔액 <small id="cbListSub">기준월 말 기준</small></span>
          <span style="font-size:12px; font-weight:600; color:#5a6b7a">머리글을 누르면 정렬</span></div>
        <div class="cb-tbwrap"><table class="cb-tb" id="cbList"></table></div>
      </div>
    </div>
    <%-- 월별 이력 — **누적 모드 전용**(2026-07-29 확정).
           월·년 모드는 위 표 자체가 일자(월)별로 펼쳐지므로 여기 또 두면 같은 것을 두 번 보는 셈이라 숨긴다. --%>
    <div class="r" id="cbHistCard">
      <div class="cb-card">
        <div class="cb-tit"><span id="cbHistTit">📅 월별 이력 <small id="cbHistSub">거래처를 고르세요</small></span></div>
        <div class="cb-tbwrap"><table class="cb-tb" id="cbHist"></table></div>
      </div>
    </div>
  </div>

  <%-- ★하단 건별 명세 (2026-07-27 요청) — 좌측에서 거래처를 고르면 그 거래처의 **기준일자 하루** 거래를 건별로 편다.
         위(좌측·우측)는 '누계'이고 여기는 '그날 무슨 일이 있었나'다 — 성격이 달라 화면도 나눠 둔다.
         탭 4개 = 출고내역 / 매입내역 / 입금내역 / 출금내역. --%>
  <div class="cb-card" id="cbDtlCard">
    <div class="cb-tit">
      <span id="cbDtlTit">📄 건별 내역 <small id="cbDtlSub">거래처를 고르면 그 날짜의 거래가 나옵니다</small></span>
      <span id="cbDtlTabs" class="cb-tabs"></span>
    </div>
    <div class="cb-tbwrap" style="max-height:340px; min-height:120px"><table class="cb-tb" id="cbDtl"></table></div>
    <div class="cb-dtlnote" id="cbDtlNote">
      위 잔액(이월·당월·남은금액)은 <b>기준월 말까지 쌓인 누계</b>이고, 이 표는 조회줄의 <b>특정일자 하루</b>에 벌어진 거래입니다 —
      <b>서로 다른 것을 보는 표</b>라 숫자가 맞지 않는 것이 정상입니다.
      위 표의 <b style="color:#b45309">특정일자 발생</b> 칸과는 <b>같은 날짜</b>라 그 칸의 금액이 여기 건별로 펼쳐집니다.
      <span id="cbDtlWarn"></span>
    </div>
  </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var _rows = [];        // 서버 원본 (거래처 × 월)
var _list = [];        // 화면용 거래처별 집계
var _pick = null;      // 선택한 거래처코드
var _sort = { key:'recv', desc:true };
var _col  = {};        // 접힌 묶음 { 접기키: true }  (월·년 모드의 일자 낟알은 '#'+일자, 그 안 묶음은 '일자|묶음')
var _colKeys = [];     // 직전 렌더가 만든 접기키 목록 — [⊟ 접기] 전체토글이 쓴다
/* ★아직 한 번도 손대지 않은 키의 기본 상태 (2026-07-29).
     일자(월) 낟알은 **접힘**으로 시작하고(하루하루가 한눈에), 그 안 출고장 묶음은 **펼침**이 기본이다
     — 낟알을 펼쳤는데 묶음이 또 접혀 있으면 두 번 눌러야 거래처가 보인다(사용자 지적).
   [⊟ 접기]/[⊞ 펼치기] 는 이 기본값째 바꾸므로 **아직 안 그린 안쪽까지** 한 번에 여닫힌다. */
var _dcolDef = false;  // 일자(월) 낟알 기본 = **펼침** (2026-07-29 확정 — 처음엔 접힘이었다)
var _gcolDef = false;  // 출고장 묶음 기본 = 펼침
/* 지금 접혀 있나? — 손댄 적 없으면 위 기본값을 따른다('#'로 시작하면 일자 낟알) */
function cbOffKey(k){ return (_col[k]===undefined) ? (String(k).charAt(0)==='#' ? _dcolDef : _gcolDef) : !!_col[k]; }
/* ★[특정일자 발생] — 잔액(누계)과 별개로 '그 하루에 움직인 금액'만 담는다.
     _day[거래처코드] = { sale, rcv, purch, pay }  (없으면 그날 거래가 없는 곳)
     _dayKey = 마지막으로 읽은 일자(재조회 방지) · _dayOn = 한 번이라도 읽었는지 */
var _day    = {};
var _dayKey = '';
var _dayOn  = false;
var _dayErr = '';      // 발생분 조회 실패 메시지(부제에만 조용히 적는다 — 잔액은 멀쩡하므로 팝업까지는 안 띄운다)

/* ══════════════════════════════════════════════════════════════════
   ★보기 방식 3가지 (2026-07-29 요청) — 누적 / 월 / 년
     · 'cum' 누적 = 종전 화면 그대로. 기초부터 **기준월 말까지 쌓인 잔액**(이월+당월−수금).
     · 'mon' 월   = 시작일~종료일에 **발생한 것만**. 가운데 표를 **일자별**로 편다.
     · 'yr'  년   = 그 해에 **발생한 것만**. 가운데 표를 **월별**로 접는다.
   ★누적과 월·년은 **더하고 빼는 사이가 아니다** — 앞은 '남은 돈', 뒤는 '그 사이 움직인 돈'이다.
     (월 발생분을 다 더해도 누적 잔액이 되지 않는다 — 누적에는 그 이전에 쌓인 것이 들어 있다)
   ★원천 = 일계장 `selectDayBook(fromDt,toDt)` — 일자 × 거래처 발생액.
     새 서버 조회를 만들지 않은 이유 : 금액 규칙(UNION 4갈래)이 일계장·누적과 같아야 숫자가 맞고,
     이미 있는 것을 쓰면 **WAR 재빌드 없이 화면만** 고쳐 반영된다. 년 모드는 이 응답을 월로 접어 쓴다.
     응답의 dt='00000000'(이전 누계) 줄은 발생 화면에서는 버린다.
   ══════════════════════════════════════════════════════════════════ */
var _mode   = 'cum';
var _pickB  = '';      // 위 표에서 **어느 일자(월) 낟알 안의** 거래처를 눌렀는지 — 아래 이력을 그 낟알만으로 좁힌다
var _occ    = [];      // 발생 원본 (일자 × 거래처) — 월·년 모드 공용
var _occKey = '';      // 마지막으로 읽은 'from|to' (같으면 재조회 안 함)
var _occOn  = false;   // 한 번이라도 읽었는지
var _occErr = '';
function cbIsOcc(){ return _mode!=='cum'; }

/* ★출고장 묶음 — 대시보드1·매출마감과 같은 규칙(2026-07-26 요청).
     오산센터 = 왜관·김해·광주·제주·오산 / 용인·평택은 단독.
     거래처마스터의 DC_CD 가 출고장코드라 그걸로 묶는다(삼성웰스토리 지점 7곳).
     DC_CD 가 없는 거래처(매입처 등)는 '기타 거래처'로 모은다. */
var CB_DC       = { E100:'용인', E200:'왜관', E300:'김해', E400:'광주', E500:'평택', E600:'제주', E700:'오산' };
var CB_DCGROUP  = { E200:'오산센터', E300:'오산센터', E400:'오산센터', E600:'오산센터', E700:'오산센터' };
var CB_ETC      = '기타 거래처';
/* 출고장코드 판정 — ①거래처마스터 DC_CD 우선 ②없으면 거래처명으로 환원.
   ★②가 필요한 이유 : DC_CD 는 나중에 추가한 컬럼이라 WAR 재빌드 전에는 응답에 없고,
     마스터에 DC_CD 를 안 넣은 지점이 생겨도 이름으로는 잡힌다.
   ★오탐 방지 : '웰스토리' 가 들어간 거래처만 이름으로 본다.
     그냥 지역명만 보면 '광주○○상사' 같은 매입처가 광주 출고장으로 끌려온다. */
function cbDcCdOf(o){
  var cd=(''+(o.dcCd||'')).trim().toUpperCase();
  if(cd) return cd;
  var nm=(''+(o.custNm||'')).replace(/\s+/g,'');
  if(nm.indexOf('웰스토리') < 0) return '';
  for(var c in CB_DC){ if(nm.indexOf(CB_DC[c]) >= 0) return c; }
  return '';
}
function cbGrpOf(o){
  var cd=cbDcCdOf(o);
  if(!cd) return CB_ETC;
  return CB_DCGROUP[cd] || (CB_DC[cd] || CB_ETC);
}
function cbDcNm(o){ return CB_DC[cbDcCdOf(o)] || ''; }

/* 실거래 기준 구분 — 받을 쪽(매출·수금) / 지급 쪽(매입·지급) 움직임이 있었는지로만 본다.
   둘 다 없으면 '' (거래가 아예 없는 거래처 → 화면은 마스터 등록값을 흐리게 보여준다) */
function cbGbReal(a){
  if(!a) return '';
  var r=Math.round(a.r)!==0, p=Math.round(a.p)!==0;
  return (r&&p) ? '매입&매출' : (r ? '매출' : (p ? '매입' : ''));
}
function n(v){ var x=Number(String(v==null?'':v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ v=Math.round(n(v)); return v===0 ? '-' : v.toLocaleString(); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function ymLbl(s){ s=String(s||''); return s.length===6 ? s.slice(0,4)+'-'+s.slice(4,6) : s; }
function dtLbl(s){ s=String(s||''); return s.length===8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : (s||'-'); }
function thisMonth(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2); }
function today(){ var d=new Date(); return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }

(function init(){
  document.getElementById('cbYm').value = thisMonth();   // 잔액용 — 종전 그대로
  document.getElementById('cbDt').value = today();       // 아래 건별 내역용 — 잔액과 무관
  document.getElementById('cbList').innerHTML =
    '<tbody><tr><td class="cb-msg">[조회]를 누르면 거래처별 잔액이 나옵니다.</td></tr></tbody>';
  document.getElementById('cbHist').innerHTML = '';
  cbModeUI();          // 보기 방식(누적/월/년) 기본 = 누적 — 조회줄·이름표를 그 모드로 세운다
  cbDtlRender();
})();

/* ══════════ 보기 방식(누적/월/년) 전환 ══════════════════════════════ */
function _v(id){ var e=document.getElementById(id); return e ? (e.value||'') : ''; }
function _setv(id, v){ var e=document.getElementById(id); if(e) e.value=v; }
function _show(id, on){ var e=document.getElementById(id); if(e) e.style.display = on ? '' : 'none'; }
function _txt(id, s){ var e=document.getElementById(id); if(e) e.textContent=s; }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
/* 그 달의 1일~말일. 단 **이번 달이면 종료일자는 오늘**(아직 안 지난 날까지 보여 줄 이유가 없다) */
function cbSetMonth(y, m){                       // m = 1~12
  var last=new Date(y, m, 0), t=new Date();
  var to = (y===t.getFullYear() && m===t.getMonth()+1) ? t : last;
  _setv('cbFrom', ymd(new Date(y, m-1, 1)));
  _setv('cbTo',   ymd(to));
}
/* 그 해 1/1~12/31. 단 **올해면 종료일자는 오늘** (사용자 요청 — "지나지 않은해는 오늘일자") */
function cbSetYear(y){
  var t=new Date();
  _setv('cbFrom', y+'-01-01');
  _setv('cbTo',   (y===t.getFullYear()) ? ymd(t) : (y+'-12-31'));
}
function cbQuickMon(off){                        // off=0 이번 달 / -1 지난 달
  var d=new Date(); d.setDate(1); d.setMonth(d.getMonth()+off);
  cbSetMonth(d.getFullYear(), d.getMonth()+1); cbOccLoad();
}
function cbQuickYear(off){ cbSetYear(new Date().getFullYear()+off); cbOccLoad(); }

function cbMode(m){
  if(_mode===m) return;
  _mode=m; _pick=null; _pickB=''; _dtlKey=''; _dtl=null;
  _col={}; _dcolDef=false; _gcolDef=false;       // 접기 상태는 모드마다 새로 시작(둘 다 펼침이 기본)
  /* 정렬키가 모드에 없는 것이면(특정일자 발생 4칸) 기본으로 되돌린다 — 발생 모드엔 그 칸이 없다 */
  if(cbIsOcc() && CB_DAYK[_sort.key]){ _sort={ key:'recv', desc:true }; }
  if(m==='mon'){ var d=new Date(); cbSetMonth(d.getFullYear(), d.getMonth()+1); }
  if(m==='yr'){  cbSetYear(new Date().getFullYear()); }
  cbModeUI();
  if(cbIsOcc()){ _occKey=''; cbOccLoad(); }      // 기간이 바뀌었으니 다시 읽는다
  else cbRender();
}
/* 모드에 맞게 조회줄·이름표·필터 옵션을 갈아 끼운다 */
function cbModeUI(){
  var occ=cbIsOcc(), mon=(_mode==='mon');
  document.getElementById('cbMdC').className='cb-tab'+(_mode==='cum'?' on':'');
  document.getElementById('cbMdM').className='cb-tab'+(_mode==='mon'?' on':'');
  document.getElementById('cbMdY').className='cb-tab'+(_mode==='yr' ?' on':'');
  _show('cbYmFld',   !occ);
  _show('cbDtFld',   !occ);                      // 특정일자는 누적 모드 전용(발생 모드엔 발생 칸이 없다)
  _show('cbFromFld',  occ);
  _show('cbToFld',    occ);
  _show('cbTodayBtn', !occ);
  _show('cbThisMonBtn', !occ);
  _show('cbHistCard', !occ);                     // 월·년은 위 표가 이미 일자(월)별 — 가운데 이력은 중복이라 숨긴다
  var wrp=document.getElementById('cbWrap');     // 월·년은 위 표 높이를 낮춰 아래 표가 함께 보이게
  if(wrp) wrp.className='cb-wrap'+(occ?' cb-occ':'');
  /* 하단 카드 — 누적·월은 [건별 내역], 년은 [고른 달의 일자별 발생] (2026-07-29 요청) */
  _show('cbDtlCard', true);
  var dt=document.getElementById('cbDtlTit');
  if(dt) dt.innerHTML = (_mode==='yr' ? '📅 일자별 발생 ' : '📄 건별 내역 ')
                      + '<small id="cbDtlSub">'+(_mode==='yr' ? '위에서 <b>달</b> 또는 그 안 <b>거래처</b>를 고르세요'
                                                              : '거래처를 고르면 그 날짜의 거래가 나옵니다')+'</small>';
  var q=document.getElementById('cbQuick');
  if(q){
    q.style.display = occ ? 'inline-flex' : 'none';
    q.innerHTML = !occ ? '' : (mon
      ? '<button class="cb-btn" onclick="cbQuickMon(0)" title="이번 달 1일 ~ 오늘">이번 달</button>'
        +'<button class="cb-btn" style="margin-left:5px" onclick="cbQuickMon(-1)" title="지난 달 1일 ~ 말일">지난 달</button>'
      : '<button class="cb-btn" onclick="cbQuickYear(0)" title="올해 1월 1일 ~ 오늘">올해</button>'
        +'<button class="cb-btn" style="margin-left:5px" onclick="cbQuickYear(-1)" title="작년 1월 1일 ~ 12월 31일">작년</button>');
  }
  /* 보기(필터) 옵션 — 누적은 '잔액 있는 곳', 발생은 '그 기간에 거래 있는 곳' 으로 말이 달라진다.
     값(bal/recv/pay/all)은 같게 두어 고른 것이 모드를 옮겨도 유지된다. */
  var f=document.getElementById('cbFilter'), cur=f?f.value:'bal';
  if(f){
    f.innerHTML = occ
      ? '<option value="bal">발생 있는 거래처만</option>'
        +'<option value="recv">매출·수금 있는 곳만</option>'
        +'<option value="pay">매입·지급 있는 곳만</option>'
        +'<option value="all">전체(거래 있는 곳)</option>'
      : '<option value="bal">잔액 있는 거래처만</option>'
        +'<option value="recv">받을금액 있는 곳만</option>'
        +'<option value="pay">지급할금액 있는 곳만</option>'
        +'<option value="day">특정일자에 거래 있는 곳만</option>'
        +'<option value="all">전체(거래 있는 곳)</option>';
    f.value = (occ && cur==='day') ? 'bal' : cur;
    if(!f.value) f.value='bal';
  }
  /* 이름표 — 누적/발생이 헷갈리지 않게 화면 곳곳의 말을 함께 바꾼다 */
  _txt('kRecvL', occ ? '받을 발생 (매출−수금)' : '받을금액 합계');
  _txt('kPayL',  occ ? '지급 발생 (매입−지급)' : '지급할금액 합계');
  _txt('kRangeL',occ ? '조회 기간' : '자료 있는 달');
  document.getElementById('cbListTit').innerHTML =
      (occ ? '🏢 거래처별 '+(mon?'월':'년')+' 발생 ' : '🏢 거래처별 잔액 ')
      + '<small id="cbListSub">'+(occ?'고른 기간에 움직인 금액':'기준월 말 기준')+'</small>';
  document.getElementById('cbHistTit').innerHTML =
      (mon ? '📅 일자별 이력 ' : '📅 월별 이력 ')
      + '<small id="cbHistSub">거래처를 고르세요</small>';
  /* 하단 건별 내역 안내문 — 월 모드는 날짜를 '가운데 일자별 이력'에서 고른다(특정일자 칸이 숨겨져 있어 헷갈리지 않게) */
  var dn=document.getElementById('cbDtlNote');
  if(dn && mon){
    dn.innerHTML = '위 표에서 <b>일자 아래의 거래처</b>를 누르면 <b>그 하루</b>의 거래가 여기 펼쳐집니다 '
                 + '(일자를 펼치지 않고 고르면 그 기간의 <b>마지막 거래일</b>). '
                 + '위 표는 <b>기간 전체 발생</b>이라 숫자가 다른 것이 정상입니다. <span id="cbDtlWarn"></span>';
  } else if(dn && !occ){
    dn.innerHTML = '위 잔액(이월·당월·남은금액)은 <b>기준월 말까지 쌓인 누계</b>이고, 이 표는 조회줄의 <b>특정일자 하루</b>에 벌어진 거래입니다 — '
                 + '<b>서로 다른 것을 보는 표</b>라 숫자가 맞지 않는 것이 정상입니다. '
                 + '위 표의 <b style="color:#b45309">특정일자 발생</b> 칸과는 <b>같은 날짜</b>라 그 칸의 금액이 여기 건별로 펼쳐집니다. <span id="cbDtlWarn"></span>';
  }
  /* ※ 제목 밑 설명 줄(cbSub)은 2026-07-29 사용자 요청으로 **세 모드 모두 삭제**했다(요소 자체가 없다).
       설명은 [ℹ️ 도움말] 안에 있다. */
}

/* ★월·년 발생분 — 일계장(selectDayBook)을 기간으로 부른다.
     응답 = 일자 × 거래처 발생액. 월 모드는 그대로, 년 모드는 화면에서 월로 접는다.
     dt='00000000'(기간 이전 누계) 줄은 **버린다** — 여기는 '그 사이 움직인 것'만 보는 화면이다. */
function cbOccLoad(){
  if(!cbIsOcc()) return;
  var f=_v('cbFrom').replace(/-/g,''), t=_v('cbTo').replace(/-/g,'');
  if(!f || !t){ _occ=[]; _occOn=false; _occErr='기간을 입력하세요'; cbRender(); return; }
  if(f>t){ _occ=[]; _occOn=false; _occErr='시작일자가 종료일자보다 뒤입니다'; cbRender(); return; }
  var key=f+'|'+t;
  if(key===_occKey && _occOn){ cbRender(); return; }
  _occKey=key; _occErr='';
  _txt('kRange','조회 중…');
  fetch(CTX+'/mangr/selectDayBook.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'fromDt='+encodeURIComponent(f)+'&toDt='+encodeURIComponent(t) })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(_occKey!==key) return;                        // 그 사이 기간을 또 바꿨으면 버린다
      _occ=((j&&j.data)||[]).filter(function(r){ return String(r.dt||'')!=='00000000'; });
      _occOn=true; _pick=null; _pickB='';
      _col={}; _dcolDef=false; _gcolDef=false;       // 기간이 바뀌면 접기 상태도 기본(펼침)으로
      cbRender();
    })
    .catch(function(e){
      if(_occKey!==key) return;
      _occ=[]; _occOn=false; _occErr='발생분을 읽지 못했습니다';
      cbRender();
    });
}

/* 발생분을 거래처로 접는다.
   ★필드 이름을 누적 모드(cbFold)와 **같게** 맞춘다 — 정렬·묶음·KPI 코드를 그대로 나눠 쓰기 위함.
     recv = 매출−수금 (그 기간 받을 발생) / pay = 매입−지급 / sale·rcv·purch·payout = 기간 합계
     buckets = 낟알별(월 모드=일자, 년 모드=월) 줄 — 가운데 이력표가 쓴다. 값이 0인 낟알은 애초에 안 온다. */
function cbOccFold(){
  var yr=(_mode==='yr');
  var m={}, ord=[];
  _occ.forEach(function(r){
    var k=String(r.custCd||''); if(!k) return;
    var dt=String(r.dt||''); if(!dt) return;
    var key = yr ? dt.slice(0,6) : dt;                 // 년 모드는 월로 접는다
    if(!m[k]){ m[k]={ custCd:k, custNm:r.custNm||k, gb:r.vendorGb||'', gbReal:'',
                      mgrNm:'', tel:'', dcCd:r.dcCd||'',
                      recv:0, pay:0, sale:0, rcv:0, purch:0, payout:0,
                      prevRecv:0, prevPay:0, curSale:0, curRcv:0, curPurch:0, curPay:0,
                      lastDt:'', months:[], bmap:{}, buckets:[] }; ord.push(k); }
    var o=m[k];
    var sale=n(r.saleAmt)-n(r.saleDcAmt), rcv=n(r.rcvAmt),
        purch=n(r.purchAmt)-n(r.purchDcAmt), payout=n(r.payAmt);
    o.sale+=sale; o.rcv+=rcv; o.purch+=purch; o.payout+=payout;
    o.recv+=sale-rcv; o.pay+=purch-payout;
    if(dt>o.lastDt) o.lastDt=dt;
    if(!o.bmap[key]){ o.bmap[key]={ k:key, sale:0, rcv:0, purch:0, pay:0 }; o.buckets.push(o.bmap[key]); }
    var b=o.bmap[key]; b.sale+=sale; b.rcv+=rcv; b.purch+=purch; b.pay+=payout;
  });
  return ord.map(function(k){
    var o=m[k];
    o.gbReal = cbGbReal({ r:Math.abs(o.sale)+Math.abs(o.rcv), p:Math.abs(o.purch)+Math.abs(o.payout) });
    o.buckets.sort(function(a,b){ return a.k<b.k?-1:(a.k>b.k?1:0); });
    return o;
  });
}

/* ★기준월(잔액)과 특정일자(발생 칸·아래 내역)는 서로 건드리지 않는다 (2026-07-27 사용자 확정).
     한때 두 칸을 연동해 특정일자로 잔액까지 잘랐는데 "기존것에 합친것은 너무 복잡함" 지적으로 갈라 놓았다.
     · 이번 달 → 기준월만 (잔액 누계)   · 오늘 → 특정일자만 (발생 칸 + 아래 내역)
   ★다시 연동하지 말 것 — 특정일자를 바꿔도 이월·당월·남은금액은 그대로여야 정상이다. */
function cbThisMonth(){ document.getElementById('cbYm').value = thisMonth(); cbRender(); }
function cbToday(){ document.getElementById('cbDt').value = today(); cbDayChg(); }
/* 특정일자가 바뀌면 — 발생 칸과 아래 건별 내역을 함께 다시 읽는다(잔액은 손대지 않는다) */
function cbDayChg(){ cbDayLoad(); cbDtlLoad(); }
/* 발생 칸·건별 내역이 볼 날짜 — 'yyyymmdd' */
function cbDtVal(){ return (document.getElementById('cbDt').value||'').replace(/-/g,''); }

/* ★특정일자 발생분 — 일계장(selectDayBook)을 그대로 쓴다.
     fromDt=toDt=특정일자 로 부르면 '그날 거래처별 매출·매입·수금·지급'이 온다.
     ★새 서버 조회를 만들지 않은 이유 : 일계장과 금액 규칙(UNION 4갈래)이 같아야 두 화면 숫자가 맞고,
       이미 있는 것을 쓰면 WAR 재빌드 없이 화면만 고쳐 반영된다.
     응답에는 dt='00000000'(그 전날까지의 누계) 줄도 섞여 오는데 여기서는 **버린다** —
     누계는 위 잔액 칸이 이미 갖고 있어 겹치면 오히려 헷갈린다. */
function cbDayLoad(){
  if(cbIsOcc()) return;                          // 발생 모드엔 [특정일자 발생] 칸이 없다
  var dt=cbDtVal();
  if(!dt){ _day={}; _dayKey=''; _dayOn=false; _dayErr=''; return; }
  if(dt===_dayKey) return;                       // 같은 날짜면 다시 안 읽는다
  _dayKey=dt; _dayErr='';
  fetch(CTX+'/mangr/selectDayBook.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'fromDt='+encodeURIComponent(dt)+'&toDt='+encodeURIComponent(dt) })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(_dayKey!==dt) return;                   // 그 사이 날짜를 또 바꿨으면 버린다
      var m={};
      ((j&&j.data)||[]).forEach(function(r){
        if(String(r.dt||'')==='00000000') return;          // 전일누계 줄 — 안 쓴다
        var k=String(r.custCd||''); if(!k) return;
        if(!m[k]) m[k]={ sale:0, rcv:0, purch:0, pay:0 };
        m[k].sale  += n(r.saleAmt)  - n(r.saleDcAmt);      // 잔액 칸과 같은 규칙(할인 뺀 금액)
        m[k].rcv   += n(r.rcvAmt);
        m[k].purch += n(r.purchAmt) - n(r.purchDcAmt);
        m[k].pay   += n(r.payAmt);
      });
      _day=m; _dayOn=true;
      if(_rows.length) cbRender();               // 필터·합계까지 다시 맞춘다
    })
    .catch(function(e){
      if(_dayKey!==dt) return;
      _day={}; _dayOn=false; _dayErr='발생분을 읽지 못했습니다';
      if(_rows.length) cbRender();               // 잔액은 그대로 두고 발생 칸만 비운다
    });
}
/* 그날 발생분 꺼내기 — 없으면 0짜리 */
function cbDayOf(cd){ return _day[cd] || { sale:0, rcv:0, purch:0, pay:0 }; }
function cbDayAny(cd){ var d=cbDayOf(cd); return Math.round(d.sale)!==0 || Math.round(d.rcv)!==0
                                              || Math.round(d.purch)!==0 || Math.round(d.pay)!==0; }

/* ★서버는 '전 기간 × 전 거래처'를 한 번에 준다 — 잔액이 누계라 기간을 걸 수 없기 때문이다.
     한 번 받아두면 기준월·필터·검색을 바꿔도 재조회가 없다(매출 그래프 일자별과 같은 방식).
     ※ 하단 건별 내역만 예외로 그때그때 읽는다(하루치라 가볍고, 이 응답에 없는 낟알이라). */
function cbLoad(){
  /* 월·년 모드의 [조회] = 발생분 다시 읽기(같은 기간이어도 강제로) — 누적표는 손대지 않는다 */
  if(cbIsOcc()){ _occKey=''; cbOccLoad(); return; }
  document.getElementById('kRange').textContent='조회 중…';
  fetch(CTX+'/mangr/selectCustBalance.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'' })
    .then(function(r){ return r.json(); })
    .then(function(j){ _rows=(j&&j.data)||[]; _pick=null; cbRender(); })
    .catch(function(e){
      document.getElementById('kRange').textContent='오류';
      if(window._alertBox) _alertBox('조회에 실패했습니다.<br><span style="font-size:13px;color:#2b3a48">'+esc(e.message)+'</span>', {icon:'❌', okColor:'red'});
    });
}

/* 거래처별로 접는다. 기준월(ymTo) 이후 달은 잔액에서 뺀다 — '그 시점 잔액'을 보기 위함.
   ★조회줄의 '특정일자'는 여기 안 쓴다 — 그건 아래 건별 내역 전용이다(2026-07-27).
   ★이월 / 당월 분리 (2026-07-26 요청) : 기준월보다 앞선 달 = 이월, 기준월 = 당월.
     이월 + 당월매출 − 당월수금 = 남은금액  (지급 쪽도 같은 구조)
     기준월을 비워 두면 당월이 없어 전부 이월로 잡힌다. */
function cbFold(){
  var ymTo=(document.getElementById('cbYm').value||'').replace('-','');
  /* ★구분(매입/매출)은 **실제 거래 기준**으로 판정한다 (2026-07-27 확정).
       종전엔 거래처마스터 `VENDOR_GB` 를 그대로 찍었는데, 거래처 엑셀 가져오기가 같은 코드의 거래유형을
       합집합으로 병합해(vendorMng.jsp) 매출만 하는 웰스토리 지점까지 '매입&매출'로 뭉뚱그려져
       화면 숫자(지급할금액 전부 0)와 어긋나 보였다. 마스터값은 꼬리표 설명(title)에 남기고, 다르면 표시한다.
     ★기준월과 무관하게 **전 기간**으로 본다 — 기준월을 옮길 때마다 구분이 바뀌면 '성격' 표시가 아니게 된다.
     ★수금·지급도 활동으로 센다 — 옛 매출을 이번에 받기만 한 달도 '매출 거래처'다. */
  var act={};
  _rows.forEach(function(r){
    var k=String(r.custCd||''); if(!k) return;
    if(!act[k]) act[k]={ r:0, p:0 };
    act[k].r += Math.abs(n(r.saleAmt))  + Math.abs(n(r.rcvAmt));
    act[k].p += Math.abs(n(r.purchAmt)) + Math.abs(n(r.payAmt));
  });
  var m={}, ord=[];
  _rows.forEach(function(r){
    var ym=String(r.ym||'');
    if(ymTo && ym > ymTo) return;                 // 기준월 이후는 아직 안 일어난 일로 본다
    var k=String(r.custCd||'');
    if(!m[k]){ m[k]={ custCd:k, custNm:r.custNm||k, gb:r.vendorGb||'', gbReal:cbGbReal(act[k]),
                      mgrNm:r.mgrNm||'', tel:r.tel||'', dcCd:r.dcCd||'',
                      recv:0, pay:0, sale:0, rcv:0, purch:0, payout:0,
                      prevRecv:0, prevPay:0, curSale:0, curRcv:0, curPurch:0, curPay:0,
                      lastDt:'', months:[] }; ord.push(k); }
    var o=m[k];
    var sale=n(r.saleAmt)-n(r.saleDcAmt), rcv=n(r.rcvAmt),
        purch=n(r.purchAmt)-n(r.purchDcAmt), payout=n(r.payAmt);
    o.sale+=sale; o.rcv+=rcv; o.purch+=purch; o.payout+=payout;
    o.recv += sale-rcv;        // 받을금액 = 매출(할인 후) - 수금
    o.pay  += purch-payout;    // 지급할금액 = 매입(할인 후) - 지급
    if(ymTo && ym === ymTo){ o.curSale+=sale; o.curRcv+=rcv; o.curPurch+=purch; o.curPay+=payout; }
    else { o.prevRecv += sale-rcv; o.prevPay += purch-payout; }
    if(String(r.lastDt||'') > o.lastDt) o.lastDt=String(r.lastDt||'');
    o.months.push({ ym:ym, sale:n(r.saleAmt), saleDc:n(r.saleDcAmt), rcv:rcv,
                    purch:n(r.purchAmt), purchDc:n(r.purchDcAmt), pay:payout });
  });
  return ord.map(function(k){ return m[k]; });
}

function cbRender(){
  var occ=cbIsOcc();
  if(occ && !_occOn){
    document.getElementById('cbList').innerHTML =
      '<tbody><tr><td class="cb-msg">'+(_occErr ? esc(_occErr) : '기간을 정하면 그 사이 <b>발생한 금액</b>이 나옵니다.')+'</td></tr></tbody>';
    document.getElementById('cbHist').innerHTML='';
    _list=[]; _txt('kRange', _occErr?'오류':'조회 전');
    if(_mode==='yr') cbYrDayRender(); else cbDtlRender();
    return;
  }
  if(!occ && !_rows.length){
    document.getElementById('cbList').innerHTML =
      '<tbody><tr><td class="cb-msg">[조회]를 누르면 거래처별 잔액이 나옵니다.</td></tr></tbody>';
    return;
  }
  var f=document.getElementById('cbFilter').value;
  var q=(document.getElementById('cbFind').value||'').trim().toLowerCase();

  _list = (occ ? cbOccFold() : cbFold()).filter(function(o){
    /* 발생 모드의 '받을/지급만' 은 **움직임이 있었는지**로 본다 — 매출과 수금이 같아 차액이 0인 달도
       거래는 있었던 것이라 빼면 안 된다(누적 모드의 '잔액 0'과는 뜻이 다르다). */
    if(occ){
      var ar=Math.round(o.sale)!==0||Math.round(o.rcv)!==0, ap=Math.round(o.purch)!==0||Math.round(o.payout)!==0;
      if(f==='recv' && !ar) return false;
      if(f==='pay'  && !ap) return false;
      if(f==='bal'  && !ar && !ap) return false;
    } else {
      if(f==='recv' && Math.round(o.recv)===0) return false;
      if(f==='pay'  && Math.round(o.pay)===0)  return false;
      if(f==='bal'  && Math.round(o.recv)===0 && Math.round(o.pay)===0) return false;
      /* '특정일자에 거래 있는 곳만' — 발생분을 아직 못 읽었으면 거르지 않는다(빈 화면이 되지 않게) */
      if(f==='day'  && _dayOn && !cbDayAny(o.custCd)) return false;
    }
    if(q && (o.custNm||'').toLowerCase().indexOf(q)<0 && (o.custCd||'').toLowerCase().indexOf(q)<0) return false;
    return true;
  });

  var tR=0,tP=0,cR=0,cP=0;
  _list.forEach(function(o){
    tR+=o.recv; tP+=o.pay;
    if(Math.round(o.recv)!==0) cR++;
    if(Math.round(o.pay)!==0)  cP++;
  });
  document.getElementById('kRecv').textContent    = fmt(tR)==='-' ? '0' : fmt(tR);
  document.getElementById('kPay').textContent     = fmt(tP)==='-' ? '0' : fmt(tP);
  document.getElementById('kNet').textContent     = (Math.round(tR-tP)).toLocaleString();
  document.getElementById('kRecvCnt').textContent = cR.toLocaleString()+' 곳';
  document.getElementById('kPayCnt').textContent  = cP.toLocaleString()+' 곳';

  if(occ){
    /* 발생 모드 — 기간과 '실제로 자료가 있는 낟알 수'를 보여 준다(하나도 없으면 그 말을 그대로) */
    var bset={}; _list.forEach(function(o){ o.buckets.forEach(function(b){ bset[b.k]=1; }); });
    var bn=Object.keys(bset).length, unit=(_mode==='mon'?'일':'개월');
    _txt('kRange', _v('cbFrom')+' ~ '+_v('cbTo'));
    _txt('cbListSub', _v('cbFrom')+' ~ '+_v('cbTo')+' 발생 · '+_list.length.toLocaleString()+'곳'
                    + (bn ? ' · 거래 있는 '+unit+' '+bn.toLocaleString() : ' · 거래 없음'));
  } else {
    var yms={}; _rows.forEach(function(r){ if(r.ym) yms[r.ym]=1; });
    var yk=Object.keys(yms).sort();
    document.getElementById('kRange').textContent = yk.length ? (ymLbl(yk[0])+' ~ '+ymLbl(yk[yk.length-1])) : '자료 없음';
    /* 부제 = 누계 기준 + 그날 움직인 곳 수(발생 칸을 읽었을 때만) */
    var dayCnt=0; if(_dayOn) _list.forEach(function(o){ if(cbDayAny(o.custCd)) dayCnt++; });
    document.getElementById('cbListSub').textContent =
        (document.getElementById('cbYm').value||'전체') + ' 말 기준 누계 · ' + _list.length.toLocaleString() + '곳'
        + (_dayOn ? ' · ' + (document.getElementById('cbDt').value||'') + ' 거래 ' + dayCnt.toLocaleString() + '곳'
                  : (_dayErr ? ' · ' + _dayErr : ''));
  }

  cbSortList();
  cbListRender(tR, tP);
  /* 선택했던 거래처가 필터에서 빠지면 이력을 비운다 */
  if(_pick && !_list.some(function(o){ return o.custCd===_pick; })) _pick=null;
  cbHistRender();
  if(!occ) cbDayLoad();      // 특정일자 발생 칸 (누적 모드 전용 · 같은 날짜면 재조회 안 함)
  if(_mode==='yr') cbYrDayRender();   // 년 = 고른 달의 일자별 발생(입금·출금)
  else cbDtlLoad();                   // 누적·월 = 건별 내역
}

/* 정렬키 → _day(그날 발생분) 안의 이름. 묶음줄 소계키(ds/dr/dp/dy)와 짝이 맞아야 한다 */
var CB_DAYK = { dSale:'sale', dRcv:'rcv', dPurch:'purch', dPay:'pay' };
var CB_DAYG = { dSale:'ds',   dRcv:'dr',  dPurch:'dp',    dPay:'dy'  };
/* 거래처 줄 비교 — 전체 목록(cbSortList)과 **낟알 안 목록**(월·년 모드)이 같은 함수를 쓴다.
   한쪽만 고치면 "합계표와 일자 안 순서가 다르다"가 되므로 여기 하나로 둔다. */
function cbCmpRow(a, b){
  var k=_sort.key, d=_sort.desc?-1:1, x, y;
  if(k==='nm'){ x=(a.custNm||''); y=(b.custNm||''); return x<y?d*-1:(x>y?d:0); }
  if(k==='dt'){ x=a.lastDt||''; y=b.lastDt||''; return x<y?d*-1:(x>y?d:0); }
  /* ★[특정일자 발생] 4칸 정렬 (2026-07-28 요청 — "해당일자 한눈에")
       이 값은 거래처 객체가 아니라 _day(일계장 응답)에 있어 따로 꺼내야 한다.
       아직 발생분을 못 읽었으면 cbDayOf 가 0짜리를 주므로 전부 0으로 묶여 순서가 안 바뀐다(안전). */
  if(CB_DAYK[k]){ x=cbDayOf(a.custCd)[CB_DAYK[k]]; y=cbDayOf(b.custCd)[CB_DAYK[k]]; }
  else if(k==='net'){ x=a.recv-a.pay; y=b.recv-b.pay; }
  else { x=a[k]; y=b[k]; }
  return x===y ? 0 : (x<y?d*-1:d);
}
function cbSortList(){ _list.sort(cbCmpRow); }
function cbSort(key){
  if(_sort.key===key) _sort.desc=!_sort.desc;
  else { _sort.key=key; _sort.desc=true; }
  cbSortList(); cbListRender();
}
function _arrow(k){ return _sort.key===k ? (_sort.desc?' ▼':' ▲') : ''; }

function cbListRender(tR, tP){
  var el=document.getElementById('cbList');
  if(!_list.length){
    el.innerHTML='<tbody><tr><td class="cb-msg">조건에 맞는 거래처가 없습니다. (보기를 <b>전체</b>로 바꿔 보세요)</td></tr></tbody>';
    return;
  }
  if(tR===undefined){ tR=0; tP=0; _list.forEach(function(o){ tR+=o.recv; tP+=o.pay; }); }
  /* 합계줄의 이월·당월도 같이 낸다 — 잔액만 합치면 '이월+당월=잔액' 이 합계줄에서 안 맞아 보인다 */
  var s={pr:0,cs:0,cr:0,pp:0,cp:0,cy:0, ds:0,dr:0,dp:0,dy:0};
  _list.forEach(function(o){ s.pr+=o.prevRecv; s.cs+=o.curSale; s.cr+=o.curRcv;
                             s.pp+=o.prevPay;  s.cp+=o.curPurch; s.cy+=o.curPay;
                             var d=cbDayOf(o.custCd);
                             s.ds+=d.sale; s.dr+=d.rcv; s.dp+=d.purch; s.dy+=d.pay; });
  /* ★머리글 2줄 — 받을금액·지급할금액을 각각 [이월·당월·남은금액] 으로 편다(2026-07-26 요청).
       이월 = 기준월 앞달 말 잔액 · 당월 = 기준월에 생긴 것 · 남은금액 = 이월+당월매출−당월수금
     ★셋째 묶음 [특정일자 발생] 은 누계가 아니라 **그 하루** 것이다(2026-07-27 2차).
       앞의 두 묶음과 더하거나 빼는 칸이 아니다 — 나란히 놓고 보는 칸이다. */
  var dLb=document.getElementById('cbDt').value||'';
  /* ══ 월·년(발생) 모드 — 칸 구성이 다르다 : 거래처·구분 / 매출·수금·차액 / 매입·지급·차액 / 순액 / 최근거래일 (10칸)
       ★'차액' = 그 기간에 **늘어난 받을금액**(매출−수금)이다. 누적 모드의 '남은금액'과 뜻이 다르다. ══ */
  if(cbIsOcc()){
    var pLb=_v('cbFrom')+' ~ '+_v('cbTo');
    var ho='<thead><tr>'
        + '<th rowspan="2" class="sortable lft" onclick="cbSort(\'nm\')">거래처'+_arrow('nm')+'</th>'
        + '<th rowspan="2">구분</th>'
        + '<th colspan="3" class="grp" title="'+esc(pLb)+' 에 생긴 매출·수금입니다">받을금액 <span style="font-weight:600">발생</span></th>'
        + '<th colspan="3" class="grp" title="'+esc(pLb)+' 에 생긴 매입·지급입니다">지급할금액 <span style="font-weight:600">발생</span></th>'
        + '<th rowspan="2" class="sortable num" onclick="cbSort(\'net\')">순액'+_arrow('net')+'</th>'
        + '<th rowspan="2" class="sortable" onclick="cbSort(\'dt\')">최근거래일'+_arrow('dt')+'</th>'
        + '</tr><tr>'
        + '<th class="num">매출</th><th class="num">수금</th>'
        + '<th class="sortable num" onclick="cbSort(\'recv\')" title="매출 − 수금 = 그 기간에 늘어난 받을금액">차액'+_arrow('recv')+'</th>'
        + '<th class="num">매입</th><th class="num">지급</th>'
        + '<th class="sortable num" onclick="cbSort(\'pay\')" title="매입 − 지급 = 그 기간에 늘어난 지급할금액">차액'+_arrow('pay')+'</th>'
        + '</tr></thead><tbody>';
    var so={sale:0,rcv:0,purch:0,pay:0};
    _list.forEach(function(o){ so.sale+=o.sale; so.rcv+=o.rcv; so.purch+=o.purch; so.pay+=o.payout; });
    ho+='<tr class="tot"><td class="txt">■ 합계 ('+_list.length.toLocaleString()+'곳)</td><td></td>'
      + '<td>'+fmt(so.sale)+'</td><td>'+fmt(so.rcv)+'</td><td>'+fmt(tR)+'</td>'
      + '<td>'+fmt(so.purch)+'</td><td>'+fmt(so.pay)+'</td><td>'+fmt(tP)+'</td>'
      + '<td>'+(Math.round(tR-tP)).toLocaleString()+'</td><td></td></tr>';
    return cbOccListBody(el, ho);          // 본문 = 발생일자(월)마다 거래처별 발생표
  }
  var h='<thead><tr>'
      + '<th rowspan="2" class="sortable lft" onclick="cbSort(\'nm\')">거래처'+_arrow('nm')+'</th>'
      + '<th rowspan="2">구분</th>'
      + '<th colspan="4" class="grp">받을금액</th>'
      + '<th colspan="4" class="grp">지급할금액</th>'
      + '<th colspan="4" class="grpd" title="이 하루에 움직인 금액입니다 — 왼쪽 누계와 더하는 칸이 아닙니다">'
      +   '특정일자 발생 <span style="font-weight:600">'+esc(dLb||'-')+'</span></th>'
      + '<th rowspan="2" class="sortable num" onclick="cbSort(\'net\')">순액'+_arrow('net')+'</th>'
      + '<th rowspan="2" class="sortable" onclick="cbSort(\'dt\')">최근거래일'+_arrow('dt')+'</th>'
      + '</tr><tr>'
      + '<th class="num">이월</th><th class="num">당월매출</th><th class="num">당월수금</th>'
      + '<th class="sortable num" onclick="cbSort(\'recv\')">남은금액'+_arrow('recv')+'</th>'
      + '<th class="num">이월</th><th class="num">당월매입</th><th class="num">당월지급</th>'
      + '<th class="sortable num" onclick="cbSort(\'pay\')">남은금액'+_arrow('pay')+'</th>'
      /* ★발생 4칸도 누르면 정렬된다(2026-07-28 요청) — 그날 움직인 거래처를 맨 위로 올려 한눈에 본다.
           묶음(오산센터 등) 순서도 같은 값으로 다시 세운다 — 안 그러면 묶음 안에서만 정렬돼 위로 못 올라온다. */
      + '<th class="dayh num sortable" onclick="cbSort(\'dSale\')" title="그날 매출이 큰 곳부터">매출'+_arrow('dSale')+'</th>'
      + '<th class="dayh num sortable" onclick="cbSort(\'dRcv\')"  title="그날 수금이 큰 곳부터">수금'+_arrow('dRcv')+'</th>'
      + '<th class="dayh num sortable" onclick="cbSort(\'dPurch\')" title="그날 매입이 큰 곳부터">매입'+_arrow('dPurch')+'</th>'
      + '<th class="dayh num sortable" onclick="cbSort(\'dPay\')"  title="그날 지급이 큰 곳부터">지급'+_arrow('dPay')+'</th>'
      + '</tr></thead><tbody>';
  h+='<tr class="tot"><td class="txt">■ 합계 ('+_list.length.toLocaleString()+'곳)</td><td></td>'
   + '<td>'+fmt(s.pr)+'</td><td>'+fmt(s.cs)+'</td><td>'+fmt(s.cr)+'</td><td>'+fmt(tR)+'</td>'
   + '<td>'+fmt(s.pp)+'</td><td>'+fmt(s.cp)+'</td><td>'+fmt(s.cy)+'</td><td>'+fmt(tP)+'</td>'
   + cbDayCells(s.ds, s.dr, s.dp, s.dy)
   + '<td>'+(Math.round(tR-tP)).toLocaleString()+'</td><td></td></tr>';
  return cbListBody(el, h, tR, tP);
}

/* 머리글·합계줄 뒤의 **본문** — 누적 모드(잔액)는 종전처럼 [출고장 묶음 → 거래처] 2단이다. */
function cbListBody(el, h){
  var r=cbGroupHtml(_list, '', 0);
  el.innerHTML=h+r.html+'</tbody>';
  cbAllBtn(r.keys);
}

/* ★[출고장 묶음 → 거래처] 한 덩어리를 그린다 — 누적/월/년 세 모드가 같이 쓴다 (2026-07-29 분리).
     · list   = 그릴 거래처 줄들   · prefix = 접기키 앞머리(월·년은 낟알마다 접기 상태가 따로여야 한다)
     · lvl    = 들여쓰기 단계(0 = 맨 왼쪽 / 1 = 낟알 아래 / 2 = 낟알 ▸ 묶음 아래)
   ★칸 구성만 모드별로 갈리고(cbIsOcc 분기) 묶음·정렬·접기 규칙은 하나다 —
     한쪽만 고치면 "누적에서는 되는데 월에서는 안 된다"가 되므로 여기서 갈라 두지 않는다. */
function cbGroupHtml(list, prefix, lvl, bkey){
  lvl=lvl||0;
  var html='', keys=[];
  if(!document.getElementById('cbGroup').checked){
    list.forEach(function(o){ html+=cbRowHtml(o, lvl, bkey); });
    return { html:html, keys:keys };
  }

  /* ★출고장 묶음 2단 (대시보드1·매출마감과 같은 규칙) — 묶음 머리행 + 소계, 화살표를 누르면 접힌다.
       '기타 거래처'(출고장 없는 매입처 등)는 항상 맨 아래. */
  var gm={}, gord=[];
  list.forEach(function(o){
    var g=cbGrpOf(o);
    if(!gm[g]){ gm[g]={ nm:g, rows:[], recv:0, pay:0, pr:0, cs:0, cr:0, pp:0, cp:0, cy:0,
                        ds:0, dr:0, dp:0, dy:0, sale:0, rcv:0, purch:0, payout:0, lastDt:'' }; gord.push(g); }
    var t=gm[g];
    t.rows.push(o);
    t.recv+=o.recv; t.pay+=o.pay;
    t.pr+=o.prevRecv; t.cs+=o.curSale; t.cr+=o.curRcv;
    t.pp+=o.prevPay;  t.cp+=o.curPurch; t.cy+=o.curPay;
    t.sale+=o.sale; t.rcv+=o.rcv; t.purch+=o.purch; t.payout+=o.payout;   // 발생 모드 소계
    var d=cbDayOf(o.custCd);
    t.ds+=d.sale; t.dr+=d.rcv; t.dp+=d.purch; t.dy+=d.pay;
    if((o.lastDt||'') > t.lastDt) t.lastDt=o.lastDt||'';
  });
  /* ★묶음 순서도 지금 누른 정렬을 따른다 (2026-07-28) — 종전엔 무조건 '소계 받을금액 큰 순'이라
       [특정일자 발생]으로 정렬해도 묶음 안에서만 바뀌어 그날 움직인 곳이 위로 못 올라왔다.
     '기타 거래처'는 성격이 달라 예전처럼 **항상 맨 아래**로 둔다. */
  gord.sort(function(a,b){
    if(a===CB_ETC) return 1;
    if(b===CB_ETC) return -1;
    /* ★부호 주의 — cbSortList 와 **같은 방향**이어야 한다(줄은 내림차순인데 묶음만 오름차순으로 뒤집힌 적 있음) */
    var ta=gm[a], tb2=gm[b], k=_sort.key, d=_sort.desc?-1:1, x, y;
    if(k==='nm'){ return (a<b?-1:(a>b?1:0)) * (_sort.desc?-1:1); }
    if(k==='dt'){ x=ta.lastDt||''; y=tb2.lastDt||''; return x===y?0:(x<y?-d:d); }
    if(CB_DAYG[k]){ x=ta[CB_DAYG[k]]; y=tb2[CB_DAYG[k]]; }
    else if(k==='net'){ x=ta.recv-ta.pay; y=tb2.recv-tb2.pay; }
    else if(k==='pay'){ x=ta.pay; y=tb2.pay; }
    else { x=ta.recv; y=tb2.recv; }
    return x===y ? 0 : (x<y?-d:d);
  });

  gord.forEach(function(g){
    var t=gm[g], key=prefix+g, off=cbOffKey(key);
    /* 묶음이 한 곳뿐이면 머리행을 만들지 않는다(용인·평택은 혼자다) — 매출내역 4탭과 같은 규칙 */
    if(t.rows.length === 1 && g !== CB_ETC){ html+=cbRowHtml(t.rows[0], lvl, bkey); return; }
    keys.push(key);
    /* ★접기는 ▼ 화살표를 눌렀을 때만 (2026-07-26 요청).
         종전엔 머리행 전체가 onclick 이라 소계 숫자를 짚어 보려고 눌러도 접혔다. */
    html+='<tr class="grow">'
     + '<td class="txt'+_indCls(lvl)+'"><span class="tg" onclick="cbToggle(\''+esc(key).replace(/'/g,"\\'")+'\')" title="'+(off?'펼치기':'접기')+'">'+(off?'▶':'▼')+'</span> '
     +   esc(g)+' <span class="cnt">'+t.rows.length+'곳</span></td><td></td>'
     + (cbIsOcc()
         ? '<td>'+fmt(t.sale)+'</td><td>'+fmt(t.rcv)+'</td><td class="amt-r">'+fmt(t.recv)+'</td>'
           + '<td>'+fmt(t.purch)+'</td><td>'+fmt(t.payout)+'</td><td class="amt-p">'+fmt(t.pay)+'</td>'
         : '<td>'+fmt(t.pr)+'</td><td>'+fmt(t.cs)+'</td><td>'+fmt(t.cr)+'</td><td class="amt-r">'+fmt(t.recv)+'</td>'
           + '<td>'+fmt(t.pp)+'</td><td>'+fmt(t.cp)+'</td><td>'+fmt(t.cy)+'</td><td class="amt-p">'+fmt(t.pay)+'</td>'
           + cbDayCells(t.ds, t.dr, t.dp, t.dy))
     + cbNetCell(t.recv, t.pay)
     + '<td class="ctr">'+dtLbl(t.lastDt)+'</td></tr>';
    if(off) return;
    t.rows.forEach(function(o){ html+=cbRowHtml(o, lvl+1, bkey); });
  });
  return { html:html, keys:keys };
}
function _indCls(lvl){ return lvl>=2 ? ' ind2' : (lvl>=1 ? ' ind' : ''); }

/* ══════════════════════════════════════════════════════════════════
   ★월·년 모드 본문 — **발생일자(월 모드) / 발생월(년 모드) 마다** 거래처별 발생표를 만든다.
     (2026-07-29 요청 — "거래처별 발생양식을 발생일자마다", "일자별·월별 한눈에")
     · 낟알 머리행 = 그 일자(월)의 **소계** + 거래처 수 → 이것만 훑으면 하루하루가 한눈에 들어온다.
     · **기본은 접힘** — 펼치면 그 낟알 안에서 [출고장 묶음 → 거래처] 가 종전 규칙 그대로 나온다.
     · 낟알은 **최근이 위**(이 프로젝트 공통 방침). 거래 없는 날·달은 애초에 줄이 없다.
   ★접기키는 일자 '#'+낟알 / 그 안 묶음은 '낟알|묶음' — 낟알마다 접기 상태가 따로 논다.
     (같은 '오산센터'라도 7/27 은 펼치고 7/26 은 접을 수 있어야 한다)
   ══════════════════════════════════════════════════════════════════ */
function cbOccListBody(el, h){
  var mon=(_mode==='mon');
  /* 보기(필터)·검색을 통과한 거래처만 — 판정은 이미 _list 가 갖고 있다 */
  var keep={}, meta={};
  _list.forEach(function(o){ keep[o.custCd]=1; meta[o.custCd]=o; });

  var bm={}, bord=[];
  _occ.forEach(function(r){
    var cd=String(r.custCd||''); if(!keep[cd]) return;
    var dt=String(r.dt||''); if(!dt) return;
    var k=mon ? dt : dt.slice(0,6);
    if(!bm[k]){ bm[k]={ k:k, cm:{}, rows:[], sale:0, rcv:0, purch:0, payout:0, recv:0, pay:0, lastDt:'' }; bord.push(k); }
    var b=bm[k], o=b.cm[cd], src=meta[cd]||{};
    if(!o){ o=b.cm[cd]={ custCd:cd, custNm:src.custNm||r.custNm||cd,
                         /* 구분(매입·매출)은 **기간 전체 실거래**로 판정한 값을 그대로 쓴다 —
                            낟알마다 다시 판정하면 같은 거래처가 날마다 다른 구분으로 보인다 */
                         gb:src.gb||'', gbReal:src.gbReal||'', mgrNm:src.mgrNm||'', tel:src.tel||'',
                         dcCd:src.dcCd||r.dcCd||'',
                         sale:0, rcv:0, purch:0, payout:0, recv:0, pay:0,
                         prevRecv:0, prevPay:0, curSale:0, curRcv:0, curPurch:0, curPay:0,
                         lastDt:'', months:[], buckets:[] }; b.rows.push(o); }
    var sale=n(r.saleAmt)-n(r.saleDcAmt), rcv=n(r.rcvAmt),
        purch=n(r.purchAmt)-n(r.purchDcAmt), payout=n(r.payAmt);
    o.sale+=sale; o.rcv+=rcv; o.purch+=purch; o.payout+=payout;
    o.recv+=sale-rcv; o.pay+=purch-payout;
    if(dt>o.lastDt) o.lastDt=dt;
    b.sale+=sale; b.rcv+=rcv; b.purch+=purch; b.payout+=payout;
    b.recv+=sale-rcv; b.pay+=purch-payout;
    if(dt>b.lastDt) b.lastDt=dt;
  });
  bord.sort(); bord.reverse();                       // 최근이 위

  if(!bord.length){
    el.innerHTML=h+'<tr><td class="cb-msg" colspan="10">이 기간에 거래가 없습니다.</td></tr></tbody>';
    cbAllBtn([]);
    return;
  }

  var keys=[];
  bord.forEach(function(k){
    var b=bm[k], dk='#'+k;
    var off=cbOffKey(dk);                            // ★기본은 펼침(_dcolDef=false) — [⊟ 접기]로 한 번에 닫는다
    keys.push(dk);
    b.rows.sort(cbCmpRow);
    /* ★년 모드는 **달 이름을 누르면** 아래에 그 달의 일자별 발생(입금·출금 포함)이 펼쳐진다 (2026-07-29 요청).
         접기는 종전대로 ▶/▼ 화살표만 — 숫자를 짚어 보려고 눌렀다가 접히는 일이 없게. */
    h+='<tr class="grow dgrow'+(!mon && _pickB===k && !_pick ? ' on' : '')+'" data-k="'+k+'">'
     + '<td class="txt"><span class="tg" onclick="cbToggle(\''+dk+'\')" title="'+(off?'펼치기':'접기')+'">'+(off?'▶':'▼')+'</span> '
     +   (mon ? '<b>'+dtLbl(k)+'</b>'
              : '<b style="cursor:pointer;text-decoration:underline;text-underline-offset:3px" onclick="cbPickMon(\''+k+'\')"'
                + ' title="이 달의 일자별 발생(입금·출금)을 아래에 폅니다">'+ymLbl(k)+'</b>')
     +   ' <span class="cnt">'+b.rows.length+'곳</span></td><td></td>'
     + '<td>'+fmt(b.sale)+'</td><td>'+fmt(b.rcv)+'</td><td class="amt-r">'+fmt(b.recv)+'</td>'
     + '<td>'+fmt(b.purch)+'</td><td>'+fmt(b.payout)+'</td><td class="amt-p">'+fmt(b.pay)+'</td>'
     + cbNetCell(b.recv, b.pay)
     + '<td class="ctr">'+(mon?'':dtLbl(b.lastDt))+'</td></tr>';
    if(off) return;
    var r=cbGroupHtml(b.rows, k+'|', 1, k);      // k = 그 줄들이 속한 낟알 → 거래처 클릭 시 그 일자만 보게
    h+=r.html; keys=keys.concat(r.keys);
  });
  el.innerHTML=h+'</tbody>';
  cbAllBtn(keys);
}

/* [특정일자 발생] 4칸 — 합계줄·묶음줄·거래처줄이 모두 같은 함수를 쓴다.
   ★칸 수(4개)는 머리글과 반드시 맞아야 한다. 아직 안 읽었으면 '…' 로 비워 둔다(0 으로 보이면 거래가 없는 줄 알까봐). */
function cbDayCells(sale, rcv, purch, pay){
  if(!_dayOn) return '<td class="dayc">…</td><td class="dayc">…</td><td class="dayc">…</td><td class="dayc">…</td>';
  return '<td class="dayc'+(Math.round(sale) ?' amt-d':'')+'">'+fmt(sale)+'</td>'
       + '<td class="dayc'+(Math.round(rcv)  ?' amt-d':'')+'">'+fmt(rcv)+'</td>'
       + '<td class="dayc'+(Math.round(purch)?' amt-d':'')+'">'+fmt(purch)+'</td>'
       + '<td class="dayc'+(Math.round(pay)  ?' amt-d':'')+'">'+fmt(pay)+'</td>';
}

/* 구분 칸 — **실거래 기준**이 원칙(2026-07-27 확정).
     · 거래가 있으면 그 거래로 판정한 값을 보여주고, 마스터 등록값과 다르면 꼬리표를 호박색으로 표시한다.
     · 거래가 아예 없으면 판정할 근거가 없어 마스터 등록값을 흐리게 보여준다.
   ★마스터(TBL_VENDOR_MST.VENDOR_GB)는 고치지 않는다 — 여기는 조회 화면이고, 등록값 수정은 거래처관리에서. */
function cbGbCell(o){
  var gbR=o.gbReal||'', gbM=o.gb||'', txt=gbR||gbM;
  if(!txt) return '<td class="ctr"></td>';
  var diff=!!(gbR && gbM && gbR!==gbM);
  var tip = (gbR ? '실거래 기준 '+gbR : '거래 없음 — 거래처마스터 등록값')
          + (gbM ? ' · 마스터 등록 '+gbM : '')
          + (diff ? ' (등록값과 다름)' : '');
  return '<td class="ctr"><span class="gb'+(diff?' gbx':'')+(gbR?'':' gbm')+'" title="'+esc(tip)+'">'
       + esc(txt)+(diff?'<i>*</i>':'')+'</span></td>';
}

/* 거래처 한 줄. lvl = 들여쓰기 단계(0 맨 왼쪽 / 1 묶음·낟알 아래 / 2 낟알 ▸ 묶음 아래).
   ★옛 호출부는 true/false 를 넘긴다 — 그대로 0·1 로 읽힌다(_indCls). */
function cbRowHtml(o, lvl, bkey){
  /* ★출고장 꼬리표(평택·오산…)는 안 붙인다 (2026-07-27 요청) — 거래처명에 이미 지역이 들어 있어 겹치는 표시였다.
       대신 마우스를 올리면 나오는 설명(title)에 남겨 둔다. 뺀 만큼 거래처 칸을 좁혔다. */
  var net=o.recv-o.pay, dc=cbDcNm(o), d=cbDayOf(o.custCd);
  /* ★data-cd/data-b = 선택 표시를 **표를 다시 그리지 않고** 바꾸기 위한 표식(cbMarkPick).
       전체 재렌더로 하면 큰 표가 통째로 새로 그려져 화면이 깜박인다(2026-07-29 지적). */
  return '<tr class="pick'+((_pick===o.custCd && (!bkey || _pickB===bkey))?' on':'')+'"'
   + ' data-cd="'+esc(o.custCd)+'"'+(bkey?(' data-b="'+esc(bkey)+'"'):'')
   + ' onclick="cbPick(\''+esc(o.custCd).replace(/'/g,"\\'")+'\''+(bkey?(',\''+bkey+'\''):'')+')">'
   + '<td class="txt'+_indCls(lvl?(lvl===true?1:lvl):0)+'" title="'+esc(o.custNm)+' ('+esc(o.custCd)+')'+(dc?' · 출고장 '+esc(dc):'')
   +   (o.mgrNm?' · 담당 '+esc(o.mgrNm):'')+(o.tel?' · '+esc(o.tel):'')+'">'
   +   '<span class="nm">'+esc(o.custNm)+'</span></td>'
   + cbGbCell(o)
   /* 발생 모드(월·년) = 매출·수금·차액 / 매입·지급·차액 — 누계(이월·당월)와 [특정일자 발생] 칸은 없다 */
   + (cbIsOcc()
       ? '<td>'+fmt(o.sale)+'</td><td>'+fmt(o.rcv)+'</td><td class="amt-r">'+fmt(o.recv)+'</td>'
         + '<td>'+fmt(o.purch)+'</td><td>'+fmt(o.payout)+'</td><td class="amt-p">'+fmt(o.pay)+'</td>'
       : '<td>'+fmt(o.prevRecv)+'</td><td>'+fmt(o.curSale)+'</td><td>'+fmt(o.curRcv)+'</td>'
         + '<td class="amt-r">'+fmt(o.recv)+'</td>'
         + '<td>'+fmt(o.prevPay)+'</td><td>'+fmt(o.curPurch)+'</td><td>'+fmt(o.curPay)+'</td>'
         + '<td class="amt-p">'+fmt(o.pay)+'</td>'
         + cbDayCells(d.sale, d.rcv, d.purch, d.pay))
   + cbNetCell(o.recv, o.pay)
   + '<td class="ctr">'+dtLbl(o.lastDt)+'</td></tr>';
}

/* 순액 칸 = 받을 남은금액 − 지급 남은금액. **모든 줄에 그대로 찍는다.**
   ★[이력] 2026-07-28 — 한쪽만 있는 거래처는 순액이 옆 칸(남은금액)과 같은 값이라
     "둘 다 있는 줄에서만 숫자, 나머지는 비우기"로 바꿨다가 **사용자가 보고 원복 요청**("그냥 표현해주세요").
     같은 값이라도 한 줄에서 끝까지 눈으로 훑는 쪽이 낫다는 판단이다. 다시 비우자는 얘기가 나오면 이 이력을 먼저 확인할 것. */
function cbNetCell(recv, pay){
  var net=Math.round(recv-pay);
  return '<td>'+(net===0?'-':net.toLocaleString())+'</td>';
}

function cbToggle(g){ _col[g]=!cbOffKey(g); cbListRender(); if(_col[g]) cbListTop(); }
function cbToggleAll(){
  /* 하나라도 펼쳐져 있으면 전부 접고, 다 접혀 있으면 전부 펼친다.
     ★손댄 기록(_col)을 **지우고 기본값째** 바꾼다 — 그래야 아직 안 그린 **안쪽 묶음까지** 함께 열린다
       (2026-07-29 요청 "펼치기 하면 세부묶음까지 펼치기"). 종전엔 화면에 있는 키만 바꿔서
       낟알을 펼치면 그 안 오산센터가 접힌 채로 남아 두 번 눌러야 했다. */
  var ks=(_colKeys||[]).slice();
  if(!ks.length){ var gs={}; _list.forEach(function(o){ gs[cbGrpOf(o)]=1; }); ks=Object.keys(gs); }
  var anyOpen=ks.some(function(g){ return !cbOffKey(g); });
  _col={}; _dcolDef=anyOpen; _gcolDef=anyOpen;      // 펼칠 땐 둘 다 false(=펼침), 접을 땐 둘 다 true
  cbListRender();
  if(anyOpen) cbListTop();      // 접었을 때만 — 펼칠 때는 보던 자리를 지킨다
}
/* ★접으면 표가 짧아지는데 스크롤은 내려가 있던 그대로라 빈 자리만 보였다(2026-07-28 지적).
     표 안 세로스크롤을 맨 위로 올리고, 카드가 화면 위로 넘어가 있으면 카드째 끌어내린다.
     가로스크롤(scrollLeft)은 **건드리지 않는다** — 오른쪽 칸을 보던 중이면 그 자리를 잃는다. */
function cbListTop(){
  var el=document.getElementById('cbList'); if(!el) return;
  var wrap=el.parentNode;
  if(wrap) wrap.scrollTop=0;
  var card=(el.closest ? el.closest('.cb-card') : null) || wrap;
  var top=card.getBoundingClientRect().top;
  if(top < 0) window.scrollBy({ top:top-12, behavior:'smooth' });
}
/* [⊟ 접기] ↔ [⊞ 펼치기] — 다음에 눌렀을 때 무슨 일이 일어나는지를 글자로 보여준다.
   묶음이 없으면(출고장 묶음 체크 해제) 누를 것이 없어 흐리게 둔다. */
function cbAllBtn(gs){
  var b=document.getElementById('cbAllBtn'); if(!b) return;
  var ks=gs||[], has=ks.length>0;
  _colKeys=ks;          // 전체 접기/펼치기가 쓸 대상(직전 렌더가 만든 키들)
  var anyOpen=ks.some(function(g){ return !cbOffKey(g); });
  b.textContent = (has && !anyOpen) ? '⊞ 펼치기' : '⊟ 접기';
  b.title = has ? (anyOpen ? '묶음을 전부 접습니다' : '묶음을 전부 펼칩니다') : '출고장 묶음일 때만 씁니다';
  b.disabled = !has;
  b.style.opacity = has ? '' : '.45';
}

/* 거래처 줄 클릭. bkey = 그 줄이 들어 있던 일자(월) 낟알 — 월·년 모드에서만 넘어온다.
   ★낟알 안에서 골랐으면 아래 이력·건별을 **그 일자(월)만** 으로 좁힌다 (2026-07-29 요청). */
function cbPick(cd, bkey){
  _pick=cd; _pickB=bkey||'';
  /* ★월 모드 건별 내역이 볼 날짜 : 고른 낟알의 그 날 → 없으면 기간 안 마지막 거래일.
       조회줄의 특정일자(오늘)를 그대로 쓰면 기간 밖이라 늘 '거래 없음'이 떠서 헷갈린다. */
  if(_mode==='mon'){
    var o=null; _list.some(function(x){ if(x.custCd===cd){ o=x; return true; } return false; });
    var d=(_pickB && _pickB.length===8) ? _pickB : (o && o.lastDt);
    if(d) _setv('cbDt', dtLbl(d));
  }
  cbMarkPick(); cbHistRender();        // ★표를 다시 그리지 않고 선택 표시만 바꾼다(깜박임 방지)
  if(_mode==='yr') cbYrDayRender();    // 년 = 고른 달(+거래처)의 일자별 발생
  else cbDtlLoad();                    // 누적·월 = 그 하루 건별 내역
}
/* 년 모드 — 달 머리행의 달 이름을 눌렀을 때(거래처는 안 고른 상태 = 그 달 전체) */
function cbPickMon(k){ _pick=null; _pickB=k; cbMarkPick(); cbYrDayRender(); }

/* ★선택 표시만 갱신 (2026-07-29 "상단 선택하면 너무 깜박거림").
     종전엔 줄을 누를 때마다 cbListRender() 로 표를 통째로 다시 그려 화면이 번쩍이고
     스크롤 위치도 흔들렸다. 이제 class 만 바꾼다 — 자료·순서·접기 상태는 그대로다. */
function cbMarkPick(){
  var el=document.getElementById('cbList'); if(!el || !el.querySelectorAll) return;
  var rs=el.querySelectorAll('tr[data-cd]'), i;
  for(i=0;i<rs.length;i++){
    var b=rs[i].getAttribute('data-b')||'';
    var on=(rs[i].getAttribute('data-cd')===_pick && (!b || b===_pickB));
    rs[i].className='pick'+(on?' on':'');
  }
  var ds=el.querySelectorAll('tr[data-k]');
  for(i=0;i<ds.length;i++){
    var k=ds[i].getAttribute('data-k');
    ds[i].className='grow dgrow'+((_mode==='yr' && _pickB===k && !_pick)?' on':'');
  }
}

/* ★[년 모드] 고른 달의 **일자별 발생** — 매출·입금(수금)·매입·출금(지급) (2026-07-29 요청).
     · 거래처를 골랐으면 그 거래처만, 달 이름만 눌렀으면 **그 달 전체 거래처 합계**.
     · 원천은 이미 받아 둔 `_occ`(일자 × 거래처)라 **서버를 다시 부르지 않는다**.
     · 거래가 있는 날만 줄이 생기고, 합계는 맨 위(다른 표들과 같은 자리). 최근이 위. */
function cbYrDayRender(){
  var el=document.getElementById('cbDtl'), sub=document.getElementById('cbDtlSub'),
      tabs=document.getElementById('cbDtlTabs'), warn=document.getElementById('cbDtlWarn');
  if(tabs) tabs.innerHTML='';                      // 4탭(출고·매입·입금·출금)은 건별 내역 전용이라 여기선 안 쓴다
  if(warn) warn.innerHTML='';
  var o=null; _list.some(function(x){ if(x.custCd===_pick){ o=x; return true; } return false; });
  if(!_pickB){
    if(sub) sub.innerHTML='위에서 <b>달</b> 또는 그 안 <b>거래처</b>를 고르세요';
    el.innerHTML='<tbody><tr><td class="cb-msg">위 표에서 <b>달 이름</b>(또는 그 달의 거래처 줄)을 누르면 '
      + '<b>일자별 발생</b>이 여기 나옵니다.</td></tr></tbody>';
    return;
  }
  var m={}, ord=[];
  _occ.forEach(function(r){
    var dt=String(r.dt||''); if(dt.slice(0,6)!==_pickB) return;
    var cd=String(r.custCd||'');
    if(_pick ? (cd!==_pick) : !_list.some(function(x){ return x.custCd===cd; })) return;   // 필터 통과분만
    if(!m[dt]){ m[dt]={ dt:dt, sale:0, rcv:0, purch:0, pay:0 }; ord.push(dt); }
    var t=m[dt];
    t.sale  += n(r.saleAmt)-n(r.saleDcAmt);
    t.rcv   += n(r.rcvAmt);
    t.purch += n(r.purchAmt)-n(r.purchDcAmt);
    t.pay   += n(r.payAmt);
  });
  ord.sort(); ord.reverse();                       // 최근이 위
  if(sub) sub.innerHTML='<b style="color:#137a6c">'+esc(ymLbl(_pickB))+'</b> · '
      + (o ? esc(o.custNm)+' ('+esc(o.custCd)+')' : '전체 거래처')
      + ' · 거래 있는 일 '+ord.length.toLocaleString();
  var s={sale:0,rcv:0,purch:0,pay:0};
  ord.forEach(function(k){ s.sale+=m[k].sale; s.rcv+=m[k].rcv; s.purch+=m[k].purch; s.pay+=m[k].pay; });
  var h='<thead><tr><th rowspan="2">일자</th>'
      + '<th colspan="2" class="grp">받을금액</th><th colspan="2" class="grp">지급할금액</th>'
      + '<th rowspan="2" class="num">순액</th></tr>'
      + '<tr><th class="num">매출</th><th class="num" title="수금(입금) 전표">입금</th>'
      + '<th class="num">매입</th><th class="num" title="지급(출금) 전표">출금</th></tr></thead><tbody>';
  h+='<tr class="mtot"><td class="ctr">합계</td>'
   + '<td>'+fmt(s.sale)+'</td><td>'+fmt(s.rcv)+'</td>'
   + '<td>'+fmt(s.purch)+'</td><td>'+fmt(s.pay)+'</td>'
   + cbNetCell(s.sale-s.rcv, s.purch-s.pay)+'</tr>';
  if(!ord.length){
    el.innerHTML=h+'<tr><td class="cb-msg" colspan="6">이 달에 거래가 없습니다.</td></tr></tbody>';
    return;
  }
  ord.forEach(function(k){
    var t=m[k];
    h+='<tr><td class="ctr">'+dtLbl(k)+'</td>'
     + '<td class="amt-r">'+fmt(t.sale)+'</td><td>'+fmt(t.rcv)+'</td>'
     + '<td class="amt-p">'+fmt(t.purch)+'</td><td>'+fmt(t.pay)+'</td>'
     + cbNetCell(t.sale-t.rcv, t.purch-t.pay)+'</tr>';
  });
  el.innerHTML=h+'</tbody>';
}

/* 월별 이력 — 잔액은 오래된 달부터 누적해서 만들고, 화면에는 최근 달부터 보여준다.
   ★누적 모드 전용이다 — 월·년 모드는 위 표가 이미 일자(월)별이라 카드째 숨긴다(2026-07-29 사용자: "중복입니다"). */
function cbHistRender(){
  var el=document.getElementById('cbHist'), sub=document.getElementById('cbHistSub');
  if(cbIsOcc()){ el.innerHTML=''; return; }
  var o=null;
  _list.some(function(x){ if(x.custCd===_pick){ o=x; return true; } return false; });
  if(!o){
    sub.textContent='거래처를 고르세요';
    el.innerHTML='';
    return;
  }
  sub.textContent=o.custNm+' ('+o.custCd+')';

  // 같은 달이 여러 줄로 들어올 일은 없지만(서버가 월로 묶어 준다) 방어적으로 합친다
  var mm={}, ord=[];
  o.months.forEach(function(r){
    if(!mm[r.ym]){ mm[r.ym]={ ym:r.ym, sale:0, saleDc:0, rcv:0, purch:0, purchDc:0, pay:0 }; ord.push(r.ym); }
    var t=mm[r.ym];
    t.sale+=r.sale; t.saleDc+=r.saleDc; t.rcv+=r.rcv; t.purch+=r.purch; t.purchDc+=r.purchDc; t.pay+=r.pay;
  });
  /* 달마다 '그 달 시작 시점의 잔액(=이월)' 을 같이 들고 간다.
     이월 + 그달매출 − 그달수금 = 그달 잔액 이 한 줄에서 딱 떨어지게 하려는 것(2026-07-26 요청). */
  var asc=ord.sort(), bR=0, bP=0, list=[];
  asc.forEach(function(k){
    var t=mm[k], pR=bR, pP=bP;
    bR += (t.sale-t.saleDc) - t.rcv;
    bP += (t.purch-t.purchDc) - t.pay;
    list.push({ ym:k, prevR:pR, sale:t.sale-t.saleDc, rcv:t.rcv, balR:bR,
                      prevP:pP, purch:t.purch-t.purchDc, pay:t.pay, balP:bP });
  });
  list.reverse();     // ★최근 달이 맨 위 (2026-07-26 방침 — 다른 화면과 같다)

  var h='<thead><tr><th rowspan="2">월</th>'
      + '<th colspan="4" class="grp">받을금액</th>'
      + '<th colspan="4" class="grp">지급할금액</th></tr>'
      + '<tr><th class="num">이월</th><th class="num">매출</th><th class="num">수금</th><th class="num">남은금액</th>'
      + '<th class="num">이월</th><th class="num">매입</th><th class="num">지급</th><th class="num">남은금액</th></tr></thead><tbody>';
  h+='<tr class="mtot"><td class="ctr">누계</td>'
   + '<td>-</td><td>'+fmt(o.sale)+'</td><td>'+fmt(o.rcv)+'</td><td class="amt-r">'+fmt(o.recv)+'</td>'
   + '<td>-</td><td>'+fmt(o.purch)+'</td><td>'+fmt(o.payout)+'</td><td class="amt-p">'+fmt(o.pay)+'</td></tr>';
  list.forEach(function(r){
    h+='<tr><td class="ctr">'+ymLbl(r.ym)+'</td>'
     + '<td>'+fmt(r.prevR)+'</td><td>'+fmt(r.sale)+'</td><td>'+fmt(r.rcv)+'</td><td class="amt-r">'+fmt(r.balR)+'</td>'
     + '<td>'+fmt(r.prevP)+'</td><td>'+fmt(r.purch)+'</td><td>'+fmt(r.pay)+'</td><td class="amt-p">'+fmt(r.balP)+'</td></tr>';
  });
  el.innerHTML=h+'</tbody>';
}

/* ★[제거 2026-07-29] 월·년 모드의 가운데 이력표(cbOccHistRender/cbHistDay/cbPickAll)
     — 위 표가 이미 일자(월)별로 펼쳐지므로 **같은 것을 두 번 보는 표**였다 (사용자: “중복입니다”).
     월·년은 [위 표(일자·월 트리) → 거래처 클릭 → 아래 건별 내역] 세 걸음으로 끝난다.
     되살리자는 얘기가 나오면 이 이력부터 확인할 것 — 위 표와 무엇이 달라야 하는지부터 정해야 한다. */

/* ══════════════════════════════════════════════════════════════════
   하단 건별 명세 (2026-07-27 요청) — 고른 거래처의 **기준일자 하루** 거래
     · 위(잔액·월별이력)는 누계, 여기는 그날 발생분. 성격이 달라 표를 나눠 둔다.
     · 탭 4개 : 출고내역(정산서+판매전표) / 매입내역 / 입금내역 / 출금내역
     · 서버 selectCustDayDetail 은 4갈래를 한 번에 주고, 탭은 화면에서 gb 로 거른다
       (탭을 옮길 때마다 다시 부르지 않게 — 하루치라 양이 작다).
   ══════════════════════════════════════════════════════════════════ */
var _dtl = null;          // 서버 응답(그 거래처·그 날짜 전부). null = 아직 안 읽음
var _dtlTab = 'SALE';     // 'SALE' 출고 / 'PURCH' 매입 / 'RCV' 입금 / 'PAY' 출금
var _dtlKey = '';         // 마지막으로 읽은 (거래처|일자) — 같은 조건 재조회 방지
var CB_TABS = [
  { gb:'SALE',  nm:'출고내역', hint:'정산서 품목행 + 직접 판 판매전표' },
  { gb:'PURCH', nm:'매입내역', hint:'매입전표 명세' },
  { gb:'RCV',   nm:'입금내역', hint:'수금 전표' },
  { gb:'PAY',   nm:'출금내역', hint:'지급 전표' }
];
/* 출고내역 탭에는 정산서(SALE)와 판매전표(STRX)를 함께 담는다 — 잔액의 매출이 그 둘의 합이라서 */
function _dtlIn(r, tab){
  var g=String(r.gb||'');
  return tab==='SALE' ? (g==='SALE' || g==='STRX') : g===tab;
}

function cbDtlLoad(){
  var dt=cbDtVal();
  if(!_pick || !dt){ _dtl=null; _dtlKey=''; cbDtlRender(); return; }
  var key=_pick+'|'+dt;
  if(key===_dtlKey) { cbDtlRender(); return; }     // 같은 조건이면 다시 안 읽는다
  _dtlKey=key; _dtl=null; cbDtlRender('읽는 중…');
  fetch(CTX+'/mangr/selectCustDayDetail.do', { method:'POST', credentials:'same-origin',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'custCd='+encodeURIComponent(_pick)+'&trxDt='+encodeURIComponent(dt) })
    .then(function(r){ return r.json(); })
    .then(function(j){
      if(_dtlKey!==key) return;                    // 그 사이 다른 거래처를 골랐으면 버린다
      _dtl=(j&&j.data)||[];
      cbDtlRender();
    })
    .catch(function(e){
      if(_dtlKey!==key) return;
      _dtl=[]; cbDtlRender('내역을 읽지 못했습니다 — '+esc(e.message));
    });
}

function cbDtlTab(gb){ _dtlTab=gb; cbDtlRender(); }

function cbDtlRender(msg){
  var el=document.getElementById('cbDtl'), sub=document.getElementById('cbDtlSub'),
      tabs=document.getElementById('cbDtlTabs'), warn=document.getElementById('cbDtlWarn');
  var dtLb=document.getElementById('cbDt').value||'';
  var o=null; _list.some(function(x){ if(x.custCd===_pick){ o=x; return true; } return false; });

  if(!o){
    sub.textContent='거래처를 고르면 그 날짜의 거래가 나옵니다';
    tabs.innerHTML=''; warn.innerHTML='';
    el.innerHTML='<tbody><tr><td class="cb-msg">왼쪽에서 <b>거래처 줄</b>을 누르세요.</td></tr></tbody>';
    return;
  }
  sub.textContent=o.custNm+' ('+o.custCd+') · '+(dtLb||'-')+' 하루';

  /* 탭 — 건수를 같이 찍어 어디에 자료가 있는지 눌러보지 않고 알게 한다 */
  var cnt={SALE:0,PURCH:0,RCV:0,PAY:0};
  (_dtl||[]).forEach(function(r){ CB_TABS.forEach(function(t){ if(_dtlIn(r,t.gb)) cnt[t.gb]++; }); });
  tabs.innerHTML = CB_TABS.map(function(t){
    return '<span class="cb-tab'+(_dtlTab===t.gb?' on':'')+'" onclick="cbDtlTab(\''+t.gb+'\')" title="'+esc(t.hint)+'">'
         + esc(t.nm)+'<span class="c">'+(_dtl?cnt[t.gb]:'-')+'</span></span>';
  }).join('');

  if(msg){ warn.innerHTML=''; el.innerHTML='<tbody><tr><td class="cb-msg">'+esc(msg)+'</td></tr></tbody>'; return; }
  if(_dtl===null){ warn.innerHTML=''; el.innerHTML='<tbody><tr><td class="cb-msg">읽는 중…</td></tr></tbody>'; return; }

  var rows=(_dtl||[]).filter(function(r){ return _dtlIn(r,_dtlTab); });
  var tabNm=(CB_TABS.filter(function(t){ return t.gb===_dtlTab; })[0]||{}).nm||'';
  /* 전표 명세는 헤더 할인(DC_AMT) 때문에 합계가 잔액쪽 전표금액과 다를 수 있다 — 해당 탭에서만 알린다 */
  warn.innerHTML = (_dtlTab==='PURCH' || rows.some(function(r){ return r.gb==='STRX'; }))
    ? ' 전표는 <b>명세 줄</b>을 폅니다 — 전표 머리의 할인이 있으면 명세 합계가 잔액에 잡힌 전표 금액과 다를 수 있습니다.' : '';

  if(!rows.length){
    el.innerHTML='<tbody><tr><td class="cb-msg">'+esc(dtLb)+' 에 <b>'+esc(tabNm)+'</b>이 없습니다.'
      + '<br><span style="font-size:12.5px; color:#5a6b7a; font-weight:600">기준일자를 바꾸거나 다른 탭을 눌러 보세요.</span></td></tr></tbody>';
    return;
  }

  /* 입금·출금은 품목이 없다(계좌·수단이 그 자리) → 표 모양이 다르다.
       ★합계줄 colspan 은 머리글 칸수와 반드시 맞아야 한다 : 돈 탭 7칸(합계 colspan 5) / 물건 탭 10칸(합계 colspan 6). */
  var money=(_dtlTab==='RCV'||_dtlTab==='PAY');
  var neg  =(_dtlTab==='PURCH'||_dtlTab==='PAY') ? 'amt-p' : 'amt-r';
  var h='<thead><tr><th>구분</th><th>일자</th><th class="lft">전표번호</th>'
      + (money ? '<th class="lft">계좌</th><th class="lft">수단</th>'
               : '<th class="lft">출고장·창고</th><th class="lft">품목코드</th><th class="lft">품목명</th>'
                 + '<th class="num">수량</th><th class="num">단가</th>')
      + '<th class="num">금액</th><th class="lft">비고</th></tr></thead><tbody>';

  /* ★합계는 맨 위 (2026-07-27 요청) — 건수가 많으면 아래 합계는 스크롤해야 보인다.
       그래서 합계줄을 먼저 그려 두고 자리(idx)만 잡아 둔 뒤, 줄을 다 돈 다음 금액을 끼워 넣는다.
       머리글 바로 아래 sticky 로 붙어 스크롤해도 따라온다. */
  var totIdx=h.length;
  var tQ=0, tA=0;
  rows.forEach(function(r){
    tQ+=n(r.qty); tA+=n(r.amt);
    h+='<tr>'
     + '<td class="ctr"><span class="gb">'+esc(r.gbNm||'')+'</span></td>'
     + '<td class="ctr">'+dtLbl(r.dt)+'</td>'
     + '<td class="txt">'+esc(r.docNo||'-')+'</td>'
     + (money ? '<td class="txt">'+esc(r.place||'-')+'</td><td class="txt">'+esc(r.itemNm||'-')+'</td>'
              : '<td class="txt">'+esc(r.place||'-')+'</td>'
                + '<td class="txt">'+esc(r.itemCd||'-')+'</td>'
                + '<td class="txt" title="'+esc(r.itemNm||'')+'">'+esc(r.itemNm||'-')+'</td>'
                + '<td>'+(n(r.qty)===0?'-':n(r.qty).toLocaleString())+'</td>'
                + '<td>'+fmt(r.price)+'</td>')
     + '<td class="'+neg+'">'+fmt(r.amt)+'</td>'
     + '<td class="txt">'+esc(r.remark||'')+'</td></tr>';
  });
  var tot='<tr class="mtot"><td class="txt" colspan="'+(money?5:6)+'">■ '+esc(tabNm)+' 합계 ('+rows.length.toLocaleString()+'건)</td>'
   + (money ? '' : '<td>'+(Math.round(tQ)===0?'-':Math.round(tQ).toLocaleString())+'</td><td>-</td>')
   + '<td class="'+neg+'">'+fmt(tA)+'</td><td></td></tr>';
  el.innerHTML = h.slice(0,totIdx) + tot + h.slice(totIdx) + '</tbody>';
}

/* 도움말 열고닫기 — 인자 없이 부르면 토글, false 면 닫기 */
function cbHelp(on){
  var box=document.getElementById('cbHelpBox');
  var show = (on===undefined) ? (box.style.display==='none') : !!on;
  box.style.display = show ? '' : 'none';
  document.getElementById('cbHelpBtn').textContent = show ? 'ℹ️ 도움말 닫기' : 'ℹ️ 도움말';
}
</script>

<%-- 노트북(1366×768·1440×900) 대응 공통 CSS — 2026-08-02 추가.
     ★이 화면은 <head> 가 없는 조각 JSP 라 문서 맨 끝에 둔다 — 위 <style> 보다 뒤에 와야 값이 덮인다. --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-notebook.css">
<%-- ★공통 UI 보정 (2026-08-21) — 단추 글자 두 줄 접힘 방지 + [글자 축소/확대] 단추 모양.
     화면 크기와 무관하게 늘 적용된다(위 konet-notebook.css 는 노트북 전용 @media 라 큰 화면에서는 안 걸린다). --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/konet-ui-fix.css?v=20260821i">
