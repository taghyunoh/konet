<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>대상 발주 등록</title>
<script src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>   <%-- 공통 알림창(_alertBox·_confirmBox·_toast) --%>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 읽기·쓰기 (전역 XLSX) --%>
<script src="${pageContext.request.contextPath}/asset/js/ui-gridgrip.js?v=20261014"></script>   <%-- 표 높이 막대(판매등록과 같은 공용 파일) --%>
<script src="${pageContext.request.contextPath}/asset/js/comp-set.js?v=20260917"></script>
<script src="${pageContext.request.contextPath}/asset/js/ui-popdrag.js?v=20260910b"></script>   <%-- 단가표·이력 창 제목줄 잡고 끌기 (2026-10-27 「이 내용 클릭해서 움직이게」) — konetPopDrag(덮개, 제목줄) --%>   <%-- 회사 설정(konetSet) — 기본 택배 운임 parcelFeeDef --%>
<!--
  대상 발주 등록 (2026-10-02 신설 — 사용자 「토더처럼 대상이라는 곳에서 이메일로 엑셀을 캡쳐해서 옵니다(토더는 금액은 있는데 대상은 없습니다, 발주일자도 없고),
    캡쳐를 엑셀로 출력 기능도 있어야 함 · 토더처럼 입력하고 저장하는 스타일로 · 나중에 쌓이면 발주일자만 입력 · 매출관리에 대상발주등록 추가 · 저장 후 취소 기능도 · 매출은 토더처럼 발생하게」)
  매출 관리 ▸ 대상 발주 등록. 셸 iframe(logiFrame) 화면. 토더 발주 등록(toderPo.jsp)과 같은 틀.
  · 원본 = 대상(대상주식회사)이 이메일 본문에 넣어 보내는 배송요청 표 : 받는 사람 · 공란 · 주소 · 전화번호1 · 전화번호2 · 수량(ea) · 공란 · 공란 · 제품코드 · 제품명. 금액·발주일자가 없다.
  · 올리는 길 셋 —
      ① 메일의 표를 끌어 복사해(Ctrl+C) 이 화면에 붙여넣기(Ctrl+V) : 글자 그대로 표에 들어간다(HTML 표 · 탭으로 나뉜 글).
      ② 캡쳐 «그림»을 붙여넣거나 파일로 올리기 : 그림 속 글자는 자동으로 못 읽는다 — 그림을 위에 띄워 두고 보면서 아래 표에 친다.
         (같은 날 AI(구글 Gemini) 판독을 붙였다가 사용자 「제미나이는 취소하고 기존 해놓은 대로」로 뺐다.) 그림의 확대·축소는 그림에만 적용한다.
      ③ 엑셀 파일(같은 양식) 올리기 · [＋ 줄 추가]로 직접 치기.
  · 표의 모든 칸을 고칠 수 있다(사용자 「발주일자(납품일자)·품목코드·금액 수정 가능하게」). 발주일자는 위 칸의 날짜가 줄마다 들어가고 [전체 적용]으로 한꺼번에 바꾼다.
  · 품목코드(우리 코드)는 줄마다 넣는다 — 같은 제품명의 빈 칸은 한 번 넣으면 같이 채워지고, 저장하면 (제품명 → 품목코드) 짝이 쌓여 다음부터 자동(/shipout/daesangPoMap.do).
    그래서 쌓이고 나면 발주일자만 넣고 저장하면 된다.
  · 단가 = 고른 품목코드의 상품코드 판매가(매칭코드면 그 주코드의 판매가)를 자동으로 넣고 고칠 수 있다(사용자 확정). 금액 = 수량 × 단가.
  · ★★[2026-10-27 되돌림 「대상 발주 등록을 매출 주인으로 되돌려줘 택배비는 로젠 한 줄로」] 저장하면 곧 출고·매출(수량 × 단가)·재고 차감이다 — 대상 판매전표는 입력하지 않는다(10-23 분은 사용자가 취소). 받는 사람마다 택배비 합이 0 보다 크면 서버가 「택배비(로젠)」 줄(DLV_GB DSFEE)을 자동으로 만들어 매출에 넣는다(재고·화면엔 안 보임, syncDsFeeRows).
  · (옛) [2026-10-26 「대상은 판매전표가 주인」] 이 화면의 줄은 «배송(택배) 처리용»이었다 — 매출·재고·마감·채권·월별 출고현황에는 안 들어가고 판매등록 전표(거래처 대상 주식회사 00177)가 맡는다.
      운영 실측 : 10-01 부터 대상 발주와 대상 판매전표가 같은 날 같은 수량으로 둘 다 들어가 있어(10-21 34,400 / 34,402) 둘 다 세면 두 번 빠진다. 매퍼 11문이 DC_CD<>'DAESANG' 으로 뺀다(마감·그래프·이익·채권·일계장·원장·거래처합계·재고원장·월별출고).
      아래 두 줄은 옛 규칙(10-02 판)이다 :
  · 저장 = TBL_SHIPOUT_MST — 토더와 같은 종류(PROD_KIND='TD'), 출고장만 「대상」(DC_CD='DAESANG'). (옛) 그래서 매출·재고·마감·채권이 토더와 똑같이 선다 :
      저장하면 곧 출고·매출(수량 × 단가), 그 날짜의 재고에서 빠진다. 매출 거래처 = 대상주식회사(물류센터코드 DAESANG — ⛔DDL docs/sql/20261002_daesang_po.sql 먼저).
    사업장 = 위에서 고른 대상 사업장 하나. 받는 사람(학교·지점)은 사업장으로 만들지 않고 줄마다 배송 정보로만 남긴다(사용자 확정).
  · 저장 뒤 : 아래 목록에서 발주일자·품목코드·수량·단가를 고치고(옛 줄을 이력으로 닫고 새 줄을 넣는다), [선택 삭제]로 저장을 취소한다(재고도 다시 맞춘다).
    받는 사람·주소·전화 1·2·제품코드·제품명·택배비도 고칠 수 있다(같은 날 사용자 「저장내용 수정기능」) — 매출·재고와 무관한 칸이라 그 줄만 제자리에서 바로 저장한다(확인창 없이 알림만).
  · 엑셀 저장 = «택배 납기관리»의 엑셀과 같은 양식(머리글 없는 9칸 — 사용자 「엑셀출력은 택배 납기관리에서 엑셀저장처럼 동일하게」) — 올린 표에서도, 저장된 목록에서도 된다.
    (처음엔 「캡쳐처럼 엑셀 저장만 하면 됨」으로 메일 표와 같은 10칸이었다가 같은 날 이것으로 바꿨다.)
  · 택배비 (같은 날 사용자 「기본 택배비는 4500으로 입력 가능하게」) — 줄마다 기본 4,500원(회사 설정의 기본 택배 운임), 칸에서 고칠 수 있고 엑셀의 운임(G) 칸으로 나간다.
    ★DB 에 저장한다(같은 날 사용자 「DB 저장은 없나요」 — TBL_SHIPOUT_MST.RCV_FEE, DDL 같은 파일에 덧붙임) — 저장할 때 줄마다 같이 들어가고,
     저장 목록에서 고치면 그 줄만 바로 저장된다(/shipout/daesangPoFee.do). 매출·재고와는 무관한 값이라 재고를 다시 맞추지 않는다.
     (처음엔 택배 납기관리처럼 화면에서만 쓰는 값이었다.)
    택배 납기관리는 「총수량 × 운임」이지만 대상의 수량은 낱개(ea)라 곱하지 않고 한 줄에 한 번만 넣는다.
  · 같은 표를 두 번 올리면 두 번 들어간다(발주번호가 없다) — 저장 때 같은 줄(날짜·받는 사람·제품명·수량)이 이미 있으면 한 번 더 묻는다.
  ★★[2026-10-27 사용자 「품목마다 기본수량일 때 단가, 이하일 때 단가 관리 · 받는 사람 하나로 합해서 3만원부터 택배무료 · 미만 4,000원 · 붙여넣기·수동·바로 수정 모두 · 엑셀 일자에 10월 1차」]
  · 단가 = 대상 단가표(TBL_DS_PRICE, [💲 대상 단가표] 창) — 수량 ≥ 기본 수량 → 이상 단가 · 미만 → 미만 단가(예 1,000개 62원 · 그 미만 67원). 단가표에 없는 품목만 상품코드 판매가.
    수량을 고치면 단가도 따라 바뀐다(단가 칸 아래 「기본/미만/수동」). 손으로 넣은 단가는 그대로, 비우면 다시 자동. 저장 목록에서 수량·품목을 고칠 때도 같은 규칙(자동 값이었을 때만 바꾼다).
  · 택배비 = «같은 발주일자·차수·받는 사람»을 합쳐 3만 원부터 0원, 미만 4,000원 — 그 사람 첫 줄에 한 번(나머지 0). 제주는 3,000원 추가. 손으로 넣으면 그 사람은 자동 멈춤(비우면 다시).
    저장 목록은 [🚚 택배비 다시 계산] 또는 줄을 고친 뒤 자동(lsFeeSync — 3×4,000 처럼 손으로 넣은 묶음은 안 건드림). 종전 「줄마다 4,500 고정」은 없앴다.
  · 차수(DS_ROUND) = 「10월 1차」 — 마감월 기준(9/28 이 10월 1차). 지난 저장의 다음 차수를 제안(같은 날이면 같은 차수). 줄마다 저장·목록에서 고침.
  · [2026-10-28] 합계 줄 = 묶음 «맨 앞» + ▾/▸ 접기(_dsFold · dsFold/dsFoldAll/dsFoldApply — 토글은 합계 줄 맨 앞 칸 td.fd, 라벨 옆이 아님) · [⊟ 전체 접기] 단추(저장 목록 조회 옆 · 올린 표 엑셀 저장 옆) · 차수 칸 88→112px.
  · [📑 마감 엑셀(대상 송부용)] = 「대상급식 마감.xlsx」 월 시트 모양(dsCloseXls) — 일자(차수)·출고점 세로 합침 · 상품명·규격은 우리 상품코드 것 · 택배비 줄 「택배비(로젠) n×4,000」 · 오른쪽 위 건수·합계 · 합계 식.
  ⛔DDL docs/sql/20261027_daesang_price.sql(단가표 + DS_ROUND 칸 + 씨앗 8품목) 먼저. 자바·매퍼 → 재기동. 시뮬 docs/tools/sim/sim_daesangPo_price.js(33검사).
-->
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#c0392b; --amber:#b45309; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:14px 11px 16px; }
  h2{ margin:0 0 10px; font-size:20px; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  h2 small{ font-size:12.5px; color:#6b7a89; font-weight:600; }
  .bar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
  .btn{ height:34px; border:1px solid var(--bd); background:#fff; border-radius:7px; padding:0 14px; cursor:pointer; font-size:13px; font-weight:700; color:#37475a; white-space:nowrap; }
  .btn:hover{ border-color:var(--teal); } .btn:disabled{ opacity:.5; cursor:default; }
  .btn-teal{ background:var(--teal); color:#fff; border-color:var(--teal); } .btn-red{ color:var(--red); }
  .card{ background:#fff; border:1px solid var(--bd); border-radius:10px; margin-bottom:14px; }
  .card .hd{ display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:9px 12px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:14px; }
  .card .hd small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .card .hd label{ font-weight:700; font-size:12.5px; color:#37475a; }
  #upCard.on{ outline:2px dashed var(--teal); outline-offset:-2px; background:#f3faf8; }
  .tw{ overflow:auto; }
  table.g{ border-collapse:collapse; width:100%; font-size:13px; }
  table.g th{ position:sticky; top:0; z-index:1; background:#eaf2f0; color:#125a4e; font-weight:600; font-size:12.5px; border-bottom:1px solid #cfe0da; border-right:1px solid #d8e6e1; padding:7px 6px; text-align:center; white-space:nowrap; }
  table.g td{ border-bottom:1px solid #eef1f5; border-right:1px solid #eef1f5; padding:4px 6px; text-align:center; white-space:nowrap; vertical-align:middle; }
  table.g td.l{ text-align:left; } table.g td.r{ text-align:right; font-variant-numeric:tabular-nums; }
  table.g input[type=text], table.g input[type=date]{ height:30px; border:1px solid var(--bd); background:#fff; border-radius:6px; padding:0 6px; font-size:13px; font-family:inherit; }
  table.g input:focus{ border-color:var(--teal); outline:none; }
  table.g input.num{ text-align:right; font-variant-numeric:tabular-nums; }
  /* 품목코드 칸 — 넣어야 하는 칸(주황) · 초록 = 마스터에 있는 코드 · 파랑 = 자동 · 노랑 = 마스터에 없는 코드 (토더 화면과 같은 색) */
  table.g input.cd{ width:170px; border:1.5px solid #e9b98a; background:#fdebd9; }
  table.g input.cd.ok{ border-color:#7cc5b2; background:#f3fbf8; }
  table.g input.cd.auto{ border-color:#9db7e8; background:#eef3fd; }
  table.g input.cd.bad, table.g input.num.bad, table.g input.req.bad{ border-color:#e2b93b; background:#fff7d6; }
  table.g tr.off td{ color:#9aa7b3; background:#fafbfc; }
  .sub{ display:block; font-size:11.5px; color:#6b7a89; margin-top:1px; max-width:230px; overflow:hidden; text-overflow:ellipsis; }
  .sub.warn{ color:var(--amber); }
  .sub.nmf{ font-size:12.5px; color:#1f2a37; font-weight:700; margin:0 0 3px; max-width:260px; }
  .bd{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 6px; }
  .bd.auto{ background:#e8eefb; color:#2f4f9a; }
  .dim{ color:#8a98a8; }
  #lsQ{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; font-family:inherit; background:#fff; }   /* 품목코드 검색칸 = 날짜 칸과 같은 높이 (2026-10-31) */
  .hd input[type=date], .hd select{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; font-family:inherit; background:#fff; }
  .msg{ padding:22px; text-align:center; color:#8a98a8; }
  .note{ font-size:12.5px; color:#6b7a89; padding:8px 12px; line-height:1.6; }
  .x{ border:0; background:none; color:#b0392b; cursor:pointer; font-size:15px; padding:2px 6px; }
  /* 올리는 방법 안내(올린 줄이 없을 때) */
  #howBox{ padding:14px 14px 12px; color:#3d4d5c; font-size:13px; }
  .how-top{ text-align:right; margin-bottom:6px; } .how-top .btn{ height:28px; padding:0 10px; font-size:12px; }
  /* 접힌 모양 — 붙여넣기 자리 한 줄 + [펼치기] */
  #howBox.fold{ display:flex; align-items:center; gap:8px; padding:8px 12px; }
  #howBox.fold .how-top{ order:2; margin:0; }
  #howBox.fold #pasteZone{ flex:1; padding:6px 12px; text-align:left; border-radius:8px; }
  #howBox.fold .pz-ic, #howBox.fold .pz-s, #howBox.fold .how-cards, #howBox.fold .how-steps{ display:none; }
  #howBox.fold .pz-t{ font-size:14px; margin-top:0; }
  #howBox.fold #pasteZone kbd{ font-size:12.5px; min-width:24px; padding:0 6px; border-bottom-width:2px; }
  #pasteZone{ border:2px dashed #b9c7d6; border-radius:12px; background:#f8fafc; padding:20px 12px 18px; text-align:center; cursor:pointer; outline:none; transition:border-color .12s, background .12s; }
  #pasteZone:hover{ border-color:#7fa9a1; background:#f3faf8; }
  #pasteZone:focus{ border-color:var(--teal); border-style:solid; background:#eaf6f3; box-shadow:0 0 0 3px rgba(19,122,108,.14); }
  #pasteZone .pz-ic{ font-size:30px; line-height:1; }
  #pasteZone .pz-t{ font-size:19px; font-weight:800; color:#125a4e; margin-top:6px; }
  #pasteZone .pz-s{ font-size:13px; color:#6b7a89; margin-top:6px; }
  #pasteZone .pz-s b{ color:#37475a; }
  #pasteZone .pz-on{ display:none; } #pasteZone:focus .pz-on{ display:inline; } #pasteZone:focus .pz-idle{ display:none; }
  #pasteZone kbd{ display:inline-block; min-width:30px; padding:1px 8px; border:1px solid #9fb3ae; border-bottom-width:3px; border-radius:6px; background:#fff; font:800 15px/1.5 Consolas,'Malgun Gothic',monospace; color:#125a4e; }
  .how-cards{ display:flex; gap:8px; flex-wrap:wrap; margin-top:10px; }
  .hc{ flex:1 1 220px; display:flex; gap:10px; align-items:center; border:1px solid #b9d6cf; border-radius:10px; background:#f6fbfa; padding:10px 12px; cursor:pointer; }
  .hc:hover{ border-color:var(--teal); background:#eaf6f3; }
  .hc .hc-ic{ font-size:22px; line-height:1.1; }
  .hc b{ display:block; font-size:13.5px; color:#125a4e; }
  .hc span{ display:block; font-size:12px; color:#6b7a89; margin-top:2px; }
  .how-steps{ display:flex; align-items:center; justify-content:center; gap:10px; flex-wrap:wrap; margin-top:11px; font-size:12.5px; font-weight:700; color:#37475a; }
  .how-steps i{ display:inline-block; width:19px; height:19px; line-height:19px; border-radius:50%; background:var(--teal); color:#fff; font-style:normal; font-size:11.5px; text-align:center; margin-right:4px; }
  .how-steps b{ color:#9aa7b3; font-size:15px; }
  /* 캡쳐 그림 — 보면서 입력 */
  #capBox{ display:none; border-bottom:1px solid #eef1f5; padding:8px 12px; background:#fbfcfd; overflow:hidden; min-width:0; }
  #capBox .ct{ display:flex; align-items:center; gap:8px; font-size:12.5px; color:#3d4d5c; margin-bottom:6px; }
  #capScroll{ max-height:260px; max-width:100%; overflow:auto; border:1px solid var(--bd); border-radius:8px; background:#fff; }
  #capScroll.big{ max-height:70vh; }
  #capImg{ display:block; max-width:none; }
  /* ★「거래처 매출장·마감」 그리드 모양으로 (2026-10-21 사용자 「DC 발주등록, 토더 발주등록, 대상 발주등록도」 — 품목별재고현황과 같게)
       머리줄 하늘(#d9edf7)+회청 테두리(#9fb6c3) · 칸 테두리 #c9d3dc · 합계 줄 크림(#fcf8e3). 고른 줄·상태 배지·입력칸은 그대로. !important = 공용 ui-concept.css 가 덮지 않게 */
  table.g th{ background:#d9edf7 !important; color:#1f2a37 !important; font-weight:700; border:1px solid #9fb6c3 !important; padding:6px 6px; box-shadow:inset 0 -1px 0 #9fb6c3, inset 0 1px 0 #9fb6c3 !important; }
  table.g td{ border:1px solid #c9d3dc !important; }
  table.g tr.tot td, table.g tr.sum td{ background:#fcf8e3 !important; color:#1f2a37; font-weight:800; }
  /* ★대상 단가표·택배비·차수 (2026-10-27) — 단가 칸 아래 「기본/미만/수동」 · 택배비 칸 아래 받는 사람 합계 */
  .tier{ display:block; font-size:11px; font-weight:800; margin-top:1px; text-align:right; }
  .tier.base{ color:#137a6c; } .tier.under{ color:#b45309; } .tier.man{ color:#6b7a89; }
  .feeg{ display:block; font-size:10.5px; color:#6b7a89; margin-top:1px; text-align:right; white-space:nowrap; }
  .feeg.free{ color:#137a6c; } .feeg.pay{ color:#b45309; }
  table.g input.rnd{ width:112px; text-align:center; font-weight:700; color:#2f4f9a; }   /* 88 → 112 (2026-10-28 「표시부분 조금 늘리고」 — 「10월 11차」가 꽉 찼다) */
  table.g tr.sum td.fd{ text-align:center; padding:2px 0; }   /* 접기 토글 칸 = 줄 맨 앞(체크 칸 자리) */
  table.g tr.sum td.fd .fold{ display:inline-block; width:22px; text-align:center; cursor:pointer; user-select:none; color:#0f6b5e; font-size:13px; border:1px solid #b9d6cf; border-radius:6px; background:#fff; }
  table.g tr.sum td.fd .fold:hover{ background:#e3f2ee; }
  #round{ height:34px; border:1px solid var(--bd); border-radius:7px; padding:0 8px; font-size:13px; font-weight:700; color:#2f4f9a; width:110px; }
  /* 이력·복구 창 */
  #dhMask,#dkMask{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.38); z-index:9000; }
  #dhMask.on,#dkMask.on{ display:flex; align-items:flex-start; justify-content:center; padding-top:4vh; }
  #dhBox,#dkBox{ background:#fff; border-radius:12px; width:min(1280px,97vw); max-height:78vh; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.25); }
  #dhBox .dh,#dkBox .dh{ display:flex; align-items:center; gap:8px; padding:12px 16px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:15px; }
  #dhBox .dh small,#dkBox .dh small{ font-weight:600; color:#6b7a89; font-size:12px; }
  #dhBox .db,#dkBox .db{ overflow:auto; padding:10px 14px; }
  #dhBox .df,#dkBox .df{ display:flex; gap:8px; align-items:center; padding:2px 12px; border-top:1px solid #eef1f5; font-size:10.5px; color:#6b7a89; line-height:1.25; }
  #dhBox .df .btn,#dkBox .df .btn{ height:24px; padding:0 9px; font-size:11.5px; }
  .st{ display:inline-block; font-size:11px; font-weight:800; border-radius:6px; padding:1px 7px; white-space:nowrap; }
  .st.N{ background:#e8eefb; color:#2f4f9a; } .st.D{ background:#fdecec; color:var(--red); }
  .st.gone{ background:#eef2f5; color:#6b7a89; }
  /* 중복 점검 창 (2026-10-31) — 이력조회 창과 같은 틀 */
  .dkh{ display:flex; align-items:center; gap:8px; font-weight:800; color:#125a4e; font-size:13.5px; margin:8px 0 6px; }
  .dkh small{ font-weight:600; color:#6b7a89; font-size:12px; }
  .dkh .btn{ height:26px; padding:0 9px; font-size:12px; }
  #dkBox table.g{ margin-bottom:6px; }
  /* 대상 단가표 창 */
  #dpMask{ display:none; position:fixed; inset:0; background:rgba(15,23,32,.38); z-index:9000; }
  #dpMask.on{ display:flex; align-items:flex-start; justify-content:center; padding-top:5vh; }
  #dpBox{ background:#fff; border-radius:12px; width:min(980px,96vw); max-height:88vh; display:flex; flex-direction:column; box-shadow:0 12px 40px rgba(0,0,0,.25); }
  #dpBox .dh{ display:flex; align-items:center; gap:8px; padding:12px 16px; border-bottom:1px solid #eef1f5; font-weight:800; color:#125a4e; font-size:15px; }
  #dpBox .dh small{ font-weight:600; color:#6b7a89; font-size:12px; }
  #dpBox .db{ overflow:auto; padding:10px 14px; }
  #dpBox .df{ display:flex; gap:8px; align-items:center; padding:6px 12px; border-top:1px solid #eef1f5; font-size:12px; }
  #dpBox table.g input[type=text]{ width:100%; }
  .dpwarn{ background:#fff7d6; color:#8a5a00; border:1px solid #e9cf7a; border-radius:8px; padding:8px 12px; margin:0 12px 10px; font-size:12.5px; }
  a.vauto{ margin-left:3px; color:#1a73e8; text-decoration:none; font-size:14px; } a.vauto:hover{ color:#c0392b; }
</style>
</head>
<body>
<div class="wrap">
  <h2>📦 대상 발주 등록 <small>— 대상의 배송요청 표를 올려 저장하면 곧 출고·매출이다(수량 × 단가 + 택배비(로젠)). 재고도 그 날짜에서 빠진다. 품목코드는 한 번 넣으면 다음부터 자동으로 채워진다</small></h2>

  <div class="card" id="upCard">
    <div class="hd">올리기
      <button class="btn btn-teal" onclick="document.getElementById('fi').click()" style="margin-left:6px"
        title="엑셀(xlsx · 메일 표와 같은 양식) 또는 캡쳐 그림 파일을 고릅니다. 이 카드 위로 끌어다 놓아도 됩니다.&#10;메일의 표를 복사했으면 파일 없이 이 화면에서 Ctrl+V 만 누르면 됩니다.">📄 파일 선택</button>
      <button class="btn" onclick="addRow(true)" title="빈 줄을 하나 더합니다 — 캡쳐 그림을 보면서 직접 칠 때">＋ 줄 추가</button>
      <button class="btn btn-red" id="btnClear" onclick="pvClearAsk()" title="화면에 올려 둔 줄과 캡쳐 그림을 모두 비웁니다(저장된 것은 그대로)">🧹 전체 비우기</button>
      <label style="margin-left:8px" title="줄마다 들어가는 발주일자(납품일자) = 출고일자. 줄마다 따로 고칠 수도 있습니다">발주일자(납품일자)</label>
      <input type="date" id="dt" onchange="roundAuto()">
      <%-- ★차수 (2026-10-27 사용자 「엑셀에 일자에 10월 1차 찍어야 하니 관리하게」) — 마감월 기준(9/28 이 10월 1차일 수 있다). 지난 저장을 보고 다음 차수를 제안한다 --%>
      <label style="margin-left:4px" title="새로 올리는 줄에 들어갈 차수 — 마감 엑셀의 「일자」 칸에 날짜와 함께 찍힙니다(예 10월 1차). 다음 차수를 자동으로 제안하며, 이미 저장된 줄은 아래 목록에서 넣습니다">차수</label>
      <input type="text" id="round" list="roundList" placeholder="10월 1차" autocomplete="off" oninput="_roundTouched=true">
      <button class="btn" onclick="dtAll()" title="위 발주일자·차수를 올려 둔 모든 줄에 넣습니다">전체 적용</button>
      <button class="btn" onclick="dpOpen()" title="품목마다 기본 수량 · 이상 단가 · 미만 단가 — 붙여넣기·직접 입력·저장 뒤 고치기에서 이 표대로 단가가 들어갑니다">💲 대상 단가표</button>
      <label style="margin-left:8px" title="이 발주를 붙일 대상 사업장 — 받는 사람(학교·지점)은 줄마다 배송 정보로만 남습니다">사업장</label>
      <select id="bizSel" onchange="bizSave()"></select>
      <span class="bar" style="margin-left:auto">
        <span id="pvInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
        <button class="btn" id="pvFoldAll" data-all="0" onclick="dsFoldAll('pv')" style="display:none" title="올린 표의 차수 묶음을 전부 접거나 펼칩니다">⊟ 전체 접기</button>
        <button class="btn" id="btnXls" onclick="pvXls()" style="display:none" title="올려 둔 표를 택배 납기관리의 엑셀과 같은 양식(머리글 없는 9칸)으로 저장합니다(체크한 줄)">📊 엑셀 저장</button>
        <button class="btn btn-teal" id="btnSave" onclick="save()" style="display:none">💾 저장</button>
      </span>
    </div>
    <input type="file" id="fi" accept=".xlsx,.xls,image/*" multiple style="display:none" onchange="onFiles(this.files); this.value=''">
    <div id="capBox">
      <div class="ct"><b>🖼 캡쳐 그림</b> <span class="dim">— 그림을 보면서 아래 표에 넣으세요. 확대·축소는 <b>그림에만</b> 적용됩니다(그림 위에서 Ctrl+휠도 됩니다).</span>
        <span style="margin-left:auto"></span>
        <button class="btn" style="height:28px" onclick="capZoom(-1)" title="그림만 작게">🔍 작게</button><button class="btn" style="height:28px" onclick="capZoom(1)" title="그림만 크게">🔍 크게</button>
        <button class="btn" style="height:28px" onclick="capReset()" title="그림을 원래 크기로">원래 크기</button><span id="capPct" class="dim" style="min-width:42px;text-align:right;font-weight:700">100%</span>
        <button class="btn" style="height:28px" onclick="capTall()" id="capTallBtn">길게 보기</button>
        <button class="btn" style="height:28px" onclick="capClose()">그림 닫기</button></div>
      <div id="capScroll"><img id="capImg" alt="캡쳐"></div>
    </div>
    <%-- 올리는 방법 안내 (2026-10-02 사용자 「이 부분을 직관적으로」 · 「사용자는 무엇인지 헷갈림」) — 설명 글 네 줄을 없애고 할 일만 남겼다 :
         «큰 붙여넣기 자리 + 단추 둘 + 차례 한 줄».
         큰 자리는 눌러서 이 화면을 잡게 한다 — 메뉴를 막 누른 직후에는 글쇠가 바깥(셸)으로 가서 Ctrl+V 가 안 먹기 때문. 잡히면 테두리가 초록으로 바뀌고 글이 「준비됐습니다」로 바뀐다. --%>
    <%-- ★기본은 접힌 한 줄 (2026-10-02 사용자 「기본은 접기」) — 아래 저장 목록이 바로 보이게. 접혀 있어도 그 한 줄을 누르고 Ctrl+V 하면 그대로 붙는다.
         [▼ 펼치기]로 큰 자리·단추·차례를 다시 볼 수 있고, 펼침·접힘은 이 PC 에 기억한다(dsPoHow). --%>
    <div id="howBox" class="fold">
      <div class="how-top"><button class="btn" id="howTgl" onclick="howToggle()" title="붙여넣기 안내를 펼치거나 접습니다">▼ 펼치기</button></div>
      <div id="pasteZone" tabindex="0" title="여기를 한 번 누른 뒤 Ctrl+V 를 누르세요">
        <div class="pz-ic">📋</div>
        <div class="pz-t"><span class="pz-idle">여기를 누르고 <kbd>Ctrl</kbd> + <kbd>V</kbd></span><span class="pz-on">준비됐습니다 — <kbd>Ctrl</kbd> + <kbd>V</kbd> 를 누르세요</span></div>
        <div class="pz-s">메일에서 복사한 <b>표</b>나 <b>캡쳐 그림</b>을 붙여넣으면 아래에 표로 나옵니다</div>
      </div>
      <div class="how-cards">
        <div class="hc" onclick="document.getElementById('fi').click()" title="엑셀(같은 양식)이나 그림 파일을 고릅니다"><div class="hc-ic">📄</div><div><b>파일로 올리기</b><span>엑셀 · 그림 파일을 고릅니다</span></div></div>
        <div class="hc" onclick="addRow(true)" title="빈 줄을 만들고 직접 칩니다"><div class="hc-ic">✏️</div><div><b>직접 입력하기</b><span>빈 줄을 만들어 하나씩 넣습니다</span></div></div>
      </div>
      <div class="how-steps"><span><i>1</i> 붙여넣기</span><b>›</b><span><i>2</i> 발주일자 · 품목코드 넣기</span><b>›</b><span><i>3</i> 💾 저장</span></div>
    </div>
    <div class="tw" id="pvWrap" style="display:none;max-height:56vh">
      <table class="g"><thead><tr>
        <%-- 줄 빼기(✕) 칸은 No 앞에 둔다 (2026-10-02 사용자 「취소코드를 NO 앞으로」) — 맨 오른쪽 끝에 있을 때는 표를 옆으로 밀어야 보였다 --%>
        <th><input type="checkbox" id="pvAll" checked onchange="pvAllChk(this)"></th><th title="✕ = 그 줄을 화면에서 뺍니다(저장된 것과는 무관)">빼기</th><th>No</th>
        <th title="발주일자(납품일자) = 출고일자">발주일자</th><th title="마감 엑셀의 일자 칸에 찍히는 차수 — 예) 10월 1차">차수</th><th>받는 사람</th><th>주소</th><th>전화번호1</th><th>전화번호2</th><th>수량(ea)</th><th title="받는 사람 한 곳의 금액 합계(부가세 별도)가 3만 원부터 0원, 3만 원 미만이면 4,000원 — 그 사람 첫 줄에 한 번. 손으로 고치면 그 받는 사람은 자동 계산을 멈춥니다(비우면 다시 자동)">택배비</th>
        <th title="대상의 제품코드(메일 표에 적힌 값 그대로)">제품코드</th>
        <%-- 품목코드를 제품명 앞에 (2026-10-02 사용자 「품목코드가 제품명 앞으로 오게」) — 아래 저장 목록도 같은 차례 --%>
        <th title="우리 품목코드(상품코드) — 한 번 넣으면 같은 제품명의 빈 칸에 같이 들어가고, 저장하면 다음부터 자동">품목코드</th>
        <th title="대상의 제품명(메일 표에 적힌 값 그대로) — 이 이름으로 품목코드를 기억합니다">제품명</th>
        <th title="대상 단가표에 있는 품목은 수량이 기본 수량 이상이면 이상 단가, 미만이면 미만 단가(없는 품목은 상품코드 판매가). 고칠 수 있습니다(수동)">단가</th><th id="pvAmtTh"></th></tr></thead>
        <tbody id="pvBody"></tbody></table>
    </div>
    <div class="note" id="pvNote" style="display:none">· 모든 칸을 고칠 수 있습니다 · 주황 칸(품목코드) = 넣어야 하는 칸 · 파랑 = 지난 저장에서 자동으로 채운 값 · 초록 = 마스터에 있는 코드 · 노랑 = 마스터에 없는 코드(<b>저장 안 됨</b>) 또는 빠진 값 · 발주일자·품목코드·수량이 든 줄만 저장됩니다 · <b>단가</b> = 대상 단가표대로(기본/미만) · <b>택배비</b> = 받는 사람 합계 3만 원부터 0원, 미만 4,000원 · 저장 = 출고·매출(수량 × 단가) + 재고 차감 · 저장한 뒤에도 아래 목록에서 고치거나 취소(삭제)할 수 있습니다</div>
  </div>

  <div class="card">
    <div class="hd">저장된 대상 발주 <small>— 발주일자 기준</small>
      <span class="bar" style="margin-left:8px">
        <input type="date" id="fr"> <span class="dim">~</span> <input type="date" id="to">
        <input type="text" id="lsQ" placeholder="품목코드" style="width:120px" title="품목코드·우리 품목·제품코드·품목명 부분일치 — 치는 대로 아래 목록을 거릅니다(기간 안에서 · 서버 재조회 없음) · Esc = 지우기" oninput="lsRender()" onkeydown="if(event.key==='Escape'){this.value='';lsRender();}">
        <button class="btn btn-teal" onclick="load()">🔍 조회</button>
        <button class="btn" id="lsFoldAll" data-all="0" onclick="dsFoldAll('ls')" title="차수 묶음을 전부 접거나 펼칩니다 — 묶음마다 합계 줄 앞 ▾/▸ 로 하나씩도 됩니다">⊟ 전체 접기</button>
        <button class="btn" onclick="lsXls()" title="저장된 줄을 택배 납기관리의 엑셀과 같은 양식(머리글 없는 9칸)으로 저장합니다(체크한 줄 — 체크가 없으면 조회된 전부)">📊 엑셀 저장</button>
        <%-- 차수 넣기는 «이 칸 + 이 단추» 한 쌍으로 (2026-10-27 사용자 「차수 넣기 헷갈림」 — 위 올리기 줄의 차수 칸을 읽게 했더니 어느 칸인지 헷갈렸다) --%>
        <span style="display:inline-flex;align-items:center;gap:4px;border:1px dashed #9fb6c3;border-radius:8px;padding:2px 6px" title="왼쪽 체크칸으로 고른 줄에 이 차수를 넣습니다(전부면 머리줄 체크). 줄마다 바로 저장됩니다"><input type="text" id="roundLs" list="roundList" class="rnd" placeholder="10월 1차" autocomplete="off" style="height:30px"><button class="btn" style="height:30px" onclick="lsRoundAll()">📌 체크한 줄에 이 차수 넣기</button></span>
        <button class="btn" onclick="lsFeeAll()" title="체크한 줄(없으면 조회된 전부)의 받는 사람마다 택배비를 규칙대로 다시 넣습니다 — 3만 원부터 0원 · 미만 4,000원">🚚 택배비 다시 계산</button>
        <button class="btn btn-teal" onclick="dsCloseXls()" title="조회한 기간을 대상에 보내는 마감 엑셀(매출장 양식)로 만듭니다 — 일자(차수) · 출고점 · 상품명 · 규격 · 수량 · 단가 · 금액 + 택배비 줄 + 합계">📑 마감 엑셀(대상 송부용)</button>
        <button class="btn btn-red" onclick="delSel()" title="체크한 줄의 저장을 취소합니다 — 출고·매출에서 빠지고 재고도 다시 맞춥니다">🗑 선택 삭제(저장 취소)</button>
        <button class="btn" onclick="dhOpen()" title="이 기간에 고쳐서 닫힌 줄(수정 전)과 삭제한 줄을 보고 되살립니다">🕘 이력조회</button>
        <%-- ⚠ 중복 점검 (2026-10-31 사용자 「오류 사용자 수정할 수 있게」) — 같은 기간의 «대상 판매전표»(판매등록으로 따로 넣은 것 = 매출·재고 두 번) 와 대상 발주 안의 겹친 줄을 보여 주고 그 자리에서 지운다 --%>
        <button class="btn" onclick="dkOpen()" title="이 기간의 대상 판매전표(판매등록으로 따로 넣은 것)와, 대상 발주 안에서 같은 날·같은 받는 사람·같은 품목이 두 번 들어간 줄을 찾아 그 자리에서 지웁니다 — 판매등록과 대상 발주 등록은 하나만 쓴다(2026-10-31)">⚠ 중복 점검</button>
        <span id="lsInfo" class="dim" style="font-weight:600;font-size:12.5px"></span>
      </span>
    </div>
    <div class="tw" id="lsWrap" style="max-height:50vh"><table class="g"><thead><tr>
      <th><input type="checkbox" id="lsAll" onchange="lsAllChk(this)"></th><th title="고치면 그 줄을 새 날짜로 옮깁니다(재고도 두 날짜 모두 다시 맞춥니다)">발주일자</th><th title="고치면 그 줄만 바로 저장됩니다 — 마감 엑셀의 일자 칸">차수</th><th title="고치면 그 줄만 바로 저장됩니다">받는 사람</th><th title="고치면 그 줄만 바로 저장됩니다">주소</th><th>전화번호1</th><th>전화번호2</th><th>제품코드</th>
      <th title="고르거나 쳐서 바꾸면 이 줄의 품목코드가 바뀌고 재고도 다시 맞춥니다">품목코드</th><th title="고치면 그 줄만 바로 저장됩니다. 이 이름으로 품목코드를 기억합니다">제품명</th><th title="고쳐서 Enter">수량</th><th title="엑셀의 운임 칸으로 나갑니다. 고쳐서 Enter — 그 줄만 바로 저장됩니다">택배비</th><th title="고쳐서 Enter. 비면 매출 0">단가</th><th id="lsAmtTh"></th><th>사업장</th><th title="프로그램이 적는 수정·복구 기록">수정 기록</th><th>등록</th></tr></thead>
      <tbody id="lsBody"><tr><td colspan="19" class="msg">[🔍 조회]를 누르세요.</td></tr></tbody></table></div>
  </div>
</div>
<datalist id="prodList"></datalist>
<datalist id="roundList"></datalist>
<%-- ★이력·복구 창 (2026-10-27 사용자 「이력조회 및 복구기능」) — 고쳐서 닫힌 줄(수정 전)·삭제한 줄. [복구]로 되살린다 --%>
<div id="dhMask"><div id="dhBox" class="box">
  <div class="dh">🕘 이력조회 <small>— 발주일자</small>
    <%-- 기간을 창 안에서 바꿔 조회 (2026-10-27 「일자 변경 조회 가능하게」) — 처음엔 저장 목록의 조회 기간이 들어온다 --%>
    <input type="date" id="dhFr" style="height:30px;border:1px solid var(--bd);border-radius:6px;padding:0 6px;font-size:13px"> <span class="dim">~</span> <input type="date" id="dhTo" style="height:30px;border:1px solid var(--bd);border-radius:6px;padding:0 6px;font-size:13px">
    <button class="btn btn-teal" style="height:30px;padding:0 12px" onclick="dhLoad()">🔍 조회</button><small id="dhSub"></small>
    <span style="margin-left:auto"></span><button class="x" onclick="dhClose()" title="닫기">✕</button></div>
  <div class="db"><table class="g"><thead><tr><th style="width:62px">상태</th><th style="width:110px">언제</th><th style="width:60px">누가</th><th style="width:92px">발주일자</th><th style="width:72px">차수</th><th>받는 사람</th><th>품목</th><th style="width:70px">수량</th><th style="width:70px">단가</th><th style="width:80px">금액</th><th style="width:64px">택배비</th><th>비고</th><th style="width:70px">복구</th></tr></thead>
    <tbody id="dhBody"><tr><td colspan="13" class="msg">읽는 중…</td></tr></tbody></table></div>
  <div class="df"><span><b>수정 전</b> = 고치면서 닫힌 옛 줄(복구 = 고친 결과를 닫고 이 값으로) · <b>삭제</b> = 저장 취소한 줄(복구 = 다시 살림) · 받는 사람·택배비·차수만 고친 것은 이력이 없음</span>
    <span style="margin-left:auto"></span><button class="btn" onclick="dhClose()">닫기</button></div>
</div></div>
<%-- ★대상 단가표 창 (2026-10-27) — 품목코드 · 기본 수량 · 이상 단가 · 미만 단가. 기본 수량이 0 이면 단가 하나 --%>
<div id="dpMask"><div id="dpBox" class="box">
  <div class="dh">💲 대상 단가표 <small>— 수량이 기본 수량 <b>이상</b>이면 이상 단가, <b>미만</b>이면 미만 단가 (개당 · 부가세 별도) · 기본 수량 0 = 단가 하나</small>
    <span style="margin-left:auto"></span><button class="x" onclick="dpClose()" title="닫기">✕</button></div>
  <div id="dpWarn"></div>
  <div class="db"><table class="g"><thead><tr><th style="width:190px">품목코드</th><th>품명</th><th style="width:92px">기본 수량</th><th style="width:92px">이상 단가</th><th style="width:92px">미만 단가</th><th style="width:150px">메모</th><th style="width:54px">사용</th><th style="width:44px">빼기</th></tr></thead>
    <tbody id="dpBody"></tbody></table></div>
  <div class="df"><button class="btn" onclick="dpAdd()">＋ 품목 추가</button>
    <span class="dim" style="font-size:12.5px">고친 뒤 [💾 단가표 저장] — 올려 둔 줄의 자동 단가도 새 단가로 바뀝니다(손으로 고친 단가는 그대로).</span>
    <span style="margin-left:auto"></span><button class="btn" onclick="dpClose()">닫기</button><button class="btn btn-teal" onclick="dpSave()">💾 단가표 저장</button></div>
</div></div>
<%-- ★⚠ 중복 점검 창 (2026-10-31 사용자 「오류 사용자 수정할 수 있게」) — 판매등록과 대상 발주 등록은 앞으로 하나만 쓴다(사용자 확정). 둘 다 넣은 날은 매출·재고가 두 번 잡히므로
     ① 같은 기간의 대상 판매전표(거래처가 DC_CD DAESANG 이거나 이름이 「대상」으로 시작)를 보여 주고 [체크한 전표 삭제](/mangr/salesTrxDelete.do — 판매등록의 삭제와 같은 길)
     ② 대상 발주 안에서 같은 발주일자·받는 사람·품목코드가 두 줄 이상(차수를 다시 올려 겹친 것)을 보여 주고 [체크한 줄 삭제](daesangPoDelete — 재고 원장도 그 날짜를 다시 맞춘다)
     ③ [🔄 출고반영 재집계](/prod/stockRebuild.do) — 정리한 뒤 원장을 전 기간 다시 만든다. 서버 무변경 — 전부 있던 끝점. --%>
<div id="dkMask"><div id="dkBox" class="box">
  <div class="dh">⚠ 중복 점검 <small id="dkSub">— 저장 목록의 조회 기간</small>
    <span style="margin-left:auto"></span><button class="x" onclick="dkClose()" title="닫기">✕</button></div>
  <div class="db">
    <div class="dkh">① 같은 기간의 대상 판매전표 <small>— 판매등록으로 따로 넣은 전표. 대상 발주 등록을 쓰기로 했으면 이 전표는 지운다(매출·재고가 두 번 잡힌다)</small>
      <button class="btn btn-red" onclick="dkDelTrx()">🗑 체크한 전표 삭제</button></div>
    <table class="g"><thead><tr><th style="width:30px"><input type="checkbox" onchange="dkAll('dkTrx',this)"></th><th style="width:92px">판매일자</th><th style="width:60px">전표</th><th>거래처</th><th style="width:60px">품목수</th><th style="width:110px">판매금액(부가세 포함)</th><th style="width:170px" title="같은 발주일자에 저장된 대상 발주 줄 수와 공급가 합">같은 날 대상 발주</th></tr></thead>
      <tbody id="dkTrx"><tr><td colspan="7" class="msg">읽는 중…</td></tr></tbody></table>
    <div class="dkh">② 대상 발주 안의 겹친 줄 <small>— 같은 발주일자 · 받는 사람 · 품목코드가 두 줄 이상(같은 표를 다시 올려 차수만 다른 것). 남길 줄을 빼고 체크해서 지운다</small>
      <button class="btn btn-red" onclick="dkDelDup()">🗑 체크한 줄 삭제</button></div>
    <table class="g"><thead><tr><th style="width:30px"><input type="checkbox" onchange="dkAll('dkDup',this)"></th><th style="width:92px">발주일자</th><th style="width:80px">차수</th><th>받는 사람</th><th>품목</th><th style="width:70px">수량</th><th style="width:70px">단가</th><th style="width:130px">저장한 때</th></tr></thead>
      <tbody id="dkDup"><tr><td colspan="8" class="msg">읽는 중…</td></tr></tbody></table>
  </div>
  <div class="df"><span>지운 뒤에는 <b>[🔄 출고반영 재집계]</b>를 한 번 — 재고 원장을 전 기간 다시 만들어 두 번 빠진 출고를 바로잡는다(수십 초 걸릴 수 있음) · 매출내역·마감·그래프는 지우는 즉시 바뀐다</span>
    <span style="margin-left:auto"></span><button class="btn" onclick="dkRebuild()">🔄 출고반영 재집계</button><button class="btn" onclick="dkClose()">닫기</button></div>
</div></div>

<script>
var CTX='${pageContext.request.contextPath}';
function n(v){ if(v==null) return 0; var x=parseFloat(String(v).replace(/,/g,'')); return isFinite(x)?x:0; }
function fmt(v){ return n(v).toLocaleString('ko-KR'); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function post(url, body, json){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type': json?'application/json;charset=UTF-8':'application/x-www-form-urlencoded'}, body: json?JSON.stringify(body):(body||'') }); }
/* 응답 = JSON(Map). 문자열로 한 번 더 싸여 올 때도 푼다 */
function pj(r){ return r.text().then(function(t){ var j=null; try{ j=JSON.parse(t); if(typeof j==='string') j=JSON.parse(j); }catch(e){ j=null; }
  if(!j) throw new Error(r.ok?'서버 응답을 읽지 못했습니다.':('서버 오류 ('+r.status+')')); return j; }); }
function ok(m){ _alertBox(m,{icon:'✅'}); } function err(m){ _alertBox(m,{icon:'⚠️'}); }
function ymd(d){ return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2); }
function d10(s){ s=String(s||'').replace(/[^0-9]/g,''); return s.length>=8? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function fmtIn(v){ if(v==null||v==='') return ''; var x=n(v); return String(Math.round(x*100)/100); }

/* ── 기준자료 : 상품 마스터(이름·판매가) · 매칭코드(→ 주코드) · 대상 사업장 · 자동 매칭(지난 저장의 제품명 → 품목코드) ── */
var _prod={}, _price={}, _main={}, _bizNm={}, _map={}, _pv=[], _ls=[], _fileNm='';
function loadMasters(){
  var p1=post('/mangr/clientList.do','findData=').then(function(r){ return r.json(); }).then(function(j){
      var all=((j&&j.data)||[]).filter(function(o){ return o.bizCd; }), ds=all.filter(function(o){ return String(o.bizNm||'').indexOf('대상')>=0; });
      var list=ds.length?ds:all, sel=document.getElementById('bizSel'), keep=sel.value, saved='';
      try{ saved=localStorage.getItem('dsPoBiz')||''; }catch(e){}
      _bizNm={}; sel.innerHTML=list.map(function(o){ _bizNm[String(o.bizCd)]=o.bizNm||''; return '<option value="'+esc(o.bizCd)+'">'+esc((o.bizNm||'')+' ['+o.bizCd+']')+'</option>'; }).join('');
      var want=[keep, saved, 'K0000002'].filter(function(c){ return c && _bizNm[c]!=null; })[0];   /* 기본 = 마지막에 고른 곳 → 대상주식회사(급식) → 첫 줄 */
      if(want) sel.value=want;
    }).catch(function(){});
  var p2=post('/prod/prodList.do','').then(function(r){ return r.json(); }).then(function(j){ _prod={}; _price={}; _spec={}; var h=[];
      ((j&&j.data)||[]).forEach(function(o){ if(!o.prodCd) return; var c=String(o.prodCd); _prod[c]=o.prodNm||''; _price[c]=n(o.salePrice); _spec[c]=o.spec||''; _tax[c]=o.taxGb||'';
        if(o.stopYn!=='Y') h.push('<option value="'+esc((o.prodNm||'')+' ['+c+']')+'"></option>'); });
      document.getElementById('prodList').innerHTML=h.join(''); }).catch(function(){});
  var p3=p2.then(function(){ return post('/prod/extItemList.do',''); }).then(function(r){ return r.json(); }).then(function(j){ _main={};
      ((j&&j.data)||[]).forEach(function(o){ if(!o.extItemCd) return; var c=String(o.extItemCd);
        if(o.prodCd && String(o.prodCd)!==c) _main[c]=String(o.prodCd);
        if(_prod[c]==null) _prod[c]=(o.extItemNm||'')+' 〔매칭코드〕'; }); }).catch(function(){});
  var p4=loadDsMap();
  return Promise.all([p1,p3,p4]).then(function(){ if(_pv.length){ autoFill(); pvRender(); } if(_ls.length) lsRender(); });
}
/* 자동 매칭 + 대상 단가표 + 지금까지 쓴 차수 — 한 번에 받는다(2026-10-27) */
function loadDsMap(){
  return post('/shipout/daesangPoMap.do','').then(function(r){ return r.json(); }).then(function(j){
    _map=(j&&j.item)||{}; _priceErr=(j&&j.priceErr)||''; _rounds=(j&&j.rounds)||[];
    dsPriceSet((j&&j.price)||[]); roundListFill(); roundAuto();
  }).catch(function(){});
}
function bizSave(){ try{ localStorage.setItem('dsPoBiz', document.getElementById('bizSel').value||''); }catch(e){} }
/* 단가 = ★대상 단가표가 먼저(2026-10-27 — 수량이 기본 수량 이상이면 이상 단가, 미만이면 미만 단가).
     단가표에 없는 품목은 종전대로 그 코드의 상품코드 판매가 · 매칭코드면 그 주코드의 판매가. 없으면 0 */
function priceOf(cd, q){ cd=String(cd||''); var t=dsTier(cd); if(t) return tierPrice(t, q);
  if(_price[cd]>0) return _price[cd]; var m=_main[cd]; return (m && _price[m]>0) ? _price[m] : 0; }
function prodNmOf(cd){ return String(_prod[cd]||'').replace(' 〔매칭코드〕',''); }
/* 기본 택배비 = 회사 설정의 기본 택배 운임(없으면 4,500) — 택배 납기관리(poFeeDef)와 같은 값. 줄마다 한 번(수량을 곱하지 않는다) */
function feeDef(){ var v=Number(window.konetSet ? konetSet.f('parcelFeeDef') : 0); return (isFinite(v) && v>0) ? v : 4500; }
function feeNum(x){ return (x.fee===''||x.fee==null) ? '' : n(x.fee); }   /* 비운 줄은 빈 칸 */

/* ═══ 대상 단가표 · 택배비 · 차수 (2026-10-27 사용자 「품목마다 기본수량일 때 단가, 이하일 때 단가 관리 · 받는 사람 하나로 합해서 3만원부터 택배무료,
       3만원 미만이면 4,000원 · Ctrl+C→Ctrl+V 할 때나 수동 입력 시 · 바로 수정 시도 적용 · 엑셀 일자에 10월 1차 찍어야 하니 관리」) ═══
   · 단가표 = TBL_DS_PRICE(품목코드 · 기본 수량 · 이상 단가 · 미만 단가). 매칭코드면 그 주코드의 단가표를 본다. 기본 수량 0 = 단가 하나.
   · 택배비 = «같은 발주일자 · 같은 차수 · 같은 받는 사람»의 줄을 합쳐 금액(수량 × 단가, 부가세 별도)이 3만 원부터 0원, 미만이면 4,000원 —
       그 사람 «첫 줄»에 한 번 넣고 나머지 줄은 0원. 주소에 「제주」가 있으면 3,000원을 더한다(사장님 요청 「제주도는 3,000원 추가」).
       손으로 고친 받는 사람은 자동 계산을 멈춘다(박스가 여러 개라 3 × 4,000 처럼 매기는 경우 — 실제 마감 엑셀에 있다). 비우면 다시 자동.
   · 근거 = 「대상급식 마감.xlsx」 2026-09·10월 시트(실제로 매긴 단가·택배비 줄)와 견적서 0310-1. */
var DS_FEE=4000, DS_FREE=30000, DS_JEJU=3000;
/* 택배비 부가세 = 10% (2026-10-27 사용자 「택배비 4,000 에 부가세 400 이 반영 안 됨 — 택배 포함 판매금액은 490,050」) — 택배비 칸 값은 부가세 별도(4,000) 그대로 두고,
   합계 줄 「택배 포함」·요약줄·마감 엑셀 택배비(로젠) 줄의 판매금액에서만 부가세를 더한다. 서버 택배비(로젠) 매출 줄은 수량 × 4,000(공급가)이라 그대로 */
function feeVat(f){ return Math.round(n(f)*0.1); }
function feeTot(f){ return n(f)+feeVat(f); }
var _dsPrice={}, _dsPriceList=[], _rounds=[], _spec={}, _tax={}, _priceErr='', _roundTouched=false;
/* 공급가·부가세·판매금액 (2026-10-27 사용자 「판매등록 그리드처럼 세부로」) — 공급가 = 수량 × 단가 · 부가세 = 과세 품목 10%(면세 0) · 판매금액 = 공급가 + 부가세. 매칭코드면 주코드의 과세 구분 */
function taxOf(cd){ cd=String(cd||''); return _tax[cd]||_tax[_main[cd]]||'과세'; }
function vatOf(cd, amt){ return taxOf(cd)==='면세' ? 0 : Math.round(n(amt)*0.1); }
/* ★판매등록 그리드와 같은 칸 (2026-10-27 사용자 「단가·금액·DC·공급가·부가세·판매금액·서비스·비고·영세·거래구분 동일하게」)
   금액 = 수량 × 단가 · 공급가 = 금액 − DC · 부가세 = 영세면 0, 아니면 과세 10%(면세 0) · 판매금액 = 공급가 + 부가세 · 서비스 = 무상 수량(재고만 빠짐) · 거래구분 반품 = 금액이 음수
   DS_DC_AMT · DS_SVC_QTY · DS_ZERO_YN · DS_TRX_GB · DS_MEMO (DDL docs/sql/20261027_daesang_cols.sql). 올린 표는 pv(x.price) · 저장 목록은 ls(x.salePrice) */
/* 부가세 칸 규칙 (2026-10-27 「부가세 빼면 금액 변경안됨」) : 비우면 0(부가세 없음) · 「자동」(또는 a) 이라 쓰거나 ↺ 를 누르면 자동(과세 10% · 영세 0).
   종전 「비우면 자동」은 지운 뒤 판매금액이 그대로라 「안 바뀐다」로 읽혔다 */
function vatIsAuto(v){ v=String(v==null?'':v).trim().toLowerCase(); return v==='자동' || v==='auto' || v==='a'; }
function vatAuto(i, mode){ if(mode==='pv'){ var x=_pv[i]; if(!x) return; x.dsVatAmt=''; pvLater(); }
  else { var y=_ls[i]; if(!y) return; lsInfo(i, 'dsVatAmt', { value:'자동', getAttribute:function(){ return y.dsVatAmt==null?'':String(y.dsVatAmt); } }); } }
function dsCalc(x, mode){
  var price=(mode==='pv')?x.price:x.salePrice, gross=Math.round(n(x.qty)*n(price)), dc=Math.round(n(x.dsDcAmt)), sup=gross-dc;
  var zero=(x.dsZeroYn==='Y'), man=(x.dsVatAmt!==''&&x.dsVatAmt!=null), vat=man?Math.round(n(x.dsVatAmt)):(zero?0:vatOf(x.itemCd, sup)), sign=(x.dsTrxGb==='반품')?-1:1;
  return { gross:gross, dc:dc, sup:sup, vat:vat, vatMan:man, tot:sup+vat, sign:sign, svc:Math.round(n(x.dsSvcQty)) };   /* vatMan = 손으로 넣은 부가세 (2026-10-27 「부가세 수정도 가능하게」) */
}
function extCells(x, i, mode){
  var c=dsCalc(x, mode), pv=(mode==='pv'), id=function(k){ return pv?' id="'+k+i+'"':''; }, dv=function(v){ return pv?'':' data-v="'+esc(v)+'"'; };
  var onDc=pv?('pvSet('+i+',\'dsDcAmt\',this)'):('lsInfo('+i+',\'dsDcAmt\',this)'), onSvc=pv?('pvSet('+i+',\'dsSvcQty\',this)'):('lsEdit('+i+',\'dsSvcQty\',this)');
  var onMemo=pv?('pvSet('+i+',\'dsMemo\',this)'):('lsInfo('+i+',\'dsMemo\',this)'), onZero=pv?('pvSet('+i+',\'dsZeroYn\',{value:this.checked?\'Y\':\'N\'})'):('lsZero('+i+',this)');
  var onTrx=pv?('pvSet('+i+',\'dsTrxGb\',this)'):('lsEdit('+i+',\'dsTrxGb\',this)'), ek=pv?'':' onkeydown="if(event.key===\'Enter\'){this.blur();}"';
  var onVat=pv?('pvSet('+i+',\'dsVatAmt\',this)'):('lsInfo('+i+',\'dsVatAmt\',this)');
  var neg=c.sign<0?' style="color:#c0392b"':'';
  return '<td class="r" style="min-width:90px"'+neg+'><b'+id('amt')+'>'+fmt(c.gross*c.sign)+'</b></td>'
    +'<td><input type="text" class="num" style="width:64px" value="'+fmt(x.dsDcAmt)+'"'+dv(n(x.dsDcAmt)?fmtIn(x.dsDcAmt):'')+' title="DC(할인액) — 공급가 = 금액 − DC"'+ek+' onchange="'+onDc+'"></td>'
    +'<td class="r" style="min-width:90px"'+neg+'><b'+id('sup')+'>'+fmt(c.sup*c.sign)+'</b></td><td><input type="text" class="num" style="width:70px'+(c.vatMan?';border-color:#e2b93b':'')+'" value="'+fmt(c.vat*c.sign)+'"'+dv(c.vatMan?fmtIn(x.dsVatAmt):'')+' title="'+(c.vatMan?'손으로 넣은 부가세 — 자동(10%)으로 되돌리려면 ↺ 를 누르거나 「자동」이라 쓰세요':'자동 부가세(과세 10% · 영세 0) — 고치면 그 값으로 · 비우면 0')+'"'+ek+' onchange="'+onVat+'">'+(c.vatMan?'<a href="#" class="vauto" title="자동 부가세(10%)로 되돌림" onclick="vatAuto('+i+',\''+mode+'\');return false;">↺</a>':'')+'</td><td class="r" style="min-width:96px"'+neg+'><b'+id('tot')+'>'+fmt(c.tot*c.sign)+'</b></td>'
    +'<td><input type="text" class="num" style="width:58px" value="'+fmt(c.svc)+'"'+dv(c.svc?fmtIn(c.svc):'')+' title="서비스(무상) 수량 — 재고에서는 빠지고 매출에는 안 들어갑니다"'+ek+' onchange="'+onSvc+'"></td>'
    +'<td class="l"><input type="text" style="width:150px" value="'+esc(x.dsMemo||'')+'"'+dv(x.dsMemo||'')+' title="'+esc(x.dsMemo||'')+'" placeholder="비고"'+ek+' onchange="'+onMemo+'"></td>'
    +'<td><input type="checkbox" '+(x.dsZeroYn==='Y'?'checked':'')+' title="영세 — 부가세 0" onchange="'+onZero+'"></td>'
    +'<td><select style="height:28px;border:1px solid var(--bd);border-radius:6px;font-size:12.5px"'+dv(x.dsTrxGb||'판매')+' title="거래구분 — 반품이면 금액이 음수, 재고는 돌아옵니다" onchange="'+onTrx+'"><option'+(x.dsTrxGb==='반품'?'':' selected')+'>판매</option><option'+(x.dsTrxGb==='반품'?' selected':'')+'>반품</option></select></td>';
}
var AMT_TH='<th title="금액 = 수량 × 단가" style="min-width:90px">금액</th><th title="DC(할인액)" style="width:70px">DC</th><th title="공급가 = 금액 − DC (부가세 별도)" style="min-width:90px">공급가</th>'
  +'<th title="자동 = 영세면 0 · 과세 품목 10% · 면세 0. 고칠 수 있고, 비우면 다시 자동" style="min-width:76px">부가세</th><th title="판매금액 = 공급가 + 부가세" style="min-width:96px">판매금액</th>'
  +'<th title="서비스(무상) 수량" style="width:64px">서비스</th><th title="비고(사용자 글)">비고</th><th title="영세 — 부가세 0" style="width:44px">영세</th><th title="판매 / 반품" style="width:70px">거래구분</th>';
/* 차수(발주일자 + 차수)마다 합계 줄 (2026-10-27 사용자 「차수마다 합계」) — 줄 차례대로 묶어, 묶음이 바뀌는 자리와 끝에 「n월 m차 합계」, 묶음이 둘 이상이면 끝에 「전체 합계」.
   withRows(rows, keyOf, rowHtml, cols) : cols = { lead(합계 글자가 차지할 칸 수), mid(수량·택배비 뒤 ~ 금액 앞 칸 수), tail(금액 뒤 칸 수) } */
/* 접기/펼치기 (2026-10-28 사용자 「차수마다 앞에 접기·펼치기 · 차수 전체 접기·펼치기」) — 합계 줄이 묶음 «맨 앞»에 서고(대시보드 소계와 같은 자리) 그 앞 ▾/▸ 가 그 묶음 줄을 숨기고 보인다.
   상태 = _dsFold[mode][묶음키](손댄 것) · 없으면 _dsFoldAll[mode](전체 단추). 다시 그려도 남는다(조회·저장 뒤에도 접힌 채). 「전체 합계」 줄은 토글 없음 */
var _dsFold={ pv:{}, ls:{} }, _dsFoldAll={ pv:false, ls:false }, _dsGrpKeys={ pv:[], ls:[] };
function dsFolded(mode, key){ var v=_dsFold[mode][key]; return (v===undefined) ? !!_dsFoldAll[mode] : !!v; }
function dsFoldApply(mode){ var tb=document.getElementById(mode==='pv'?'pvBody':'lsBody'); if(!tb) return;
  _dsGrpKeys[mode].forEach(function(key, gi){ var f=dsFolded(mode, key);
    Array.prototype.forEach.call(tb.querySelectorAll('tr[data-g="'+gi+'"]'), function(tr){ tr.style.display=f?'none':''; });
    var b=document.getElementById('dsfold-'+mode+'-'+gi); if(b){ b.textContent=f?'▸':'▾'; b.title=f?'펼치기 — 이 차수의 줄을 보입니다':'접기 — 이 차수의 줄을 숨기고 합계만 남깁니다'; } });
  var ab=document.getElementById(mode==='pv'?'pvFoldAll':'lsFoldAll'); if(ab){ var all=_dsGrpKeys[mode].length>0 && _dsGrpKeys[mode].every(function(k){ return dsFolded(mode,k); }); ab.textContent=all?'⊞ 전체 펼치기':'⊟ 전체 접기'; ab.dataset.all=all?'1':'0'; } }
function dsFold(mode, gi){ var key=_dsGrpKeys[mode][gi]; if(key===undefined) return; _dsFold[mode][key]=!dsFolded(mode, key); dsFoldApply(mode); }
function dsFoldAll(mode){ var ab=document.getElementById(mode==='pv'?'pvFoldAll':'lsFoldAll'); var fold=!(ab && ab.dataset.all==='1'); _dsFoldAll[mode]=fold; _dsFold[mode]={}; dsFoldApply(mode); }
function sumRowHtml(label, g, cols, mode, gi){
  /* 토글은 «맨 앞 칸»(체크 칸 자리)에 따로 — 라벨 옆이 아니다 (2026-10-28 사용자 캡처 「1번 접기로, 2번 접기는 제거」). 「전체 합계」 줄(mode 없음)은 종전대로 한 칸 */
  var tg=(mode && gi!=null) ? '<td class="fd"><span class="fold" id="dsfold-'+mode+'-'+gi+'" onclick="dsFold(\''+mode+'\','+gi+')">▾</span></td><td colspan="'+(cols.lead-1)+'"' : '<td colspan="'+cols.lead+'"';
  return '<tr class="sum">'+tg+' class="l" style="text-align:right">'+esc(label)+' <span class="dim" style="font-weight:600">· 받는 사람 '+g.people+'곳 · '+g.n+'줄</span></td>'
    +'<td class="r">'+fmt(g.qty)+'</td><td class="r">'+fmt(g.fee)+'</td>'+(cols.mid?'<td colspan="'+cols.mid+'"></td>':'')
    +'<td class="r">'+fmt(g.gross)+'</td><td class="r">'+fmt(g.dc)+'</td><td class="r">'+fmt(g.amt)+'</td><td class="r">'+fmt(g.vat)+'</td>'
    +'<td class="r">'+fmt(g.amt+g.vat)+(g.fee?'<span class="feeg pay" title="판매금액 + 택배비 '+fmt(g.fee)+' + 택배비 부가세 '+fmt(feeVat(g.fee))+' (택배비도 부가세 10%)">택배 포함 '+fmt(g.amt+g.vat+feeTot(g.fee))+'</span>':'')+'</td>'
    +'<td class="r">'+(g.svc?fmt(g.svc):'')+'</td><td colspan="3"></td>'+(cols.tail?'<td colspan="'+cols.tail+'"></td>':'')+'</tr>';
}
function withSums(rows, keyOf, labelOf, acc, rowHtml, cols, mode){
  var h='', g=null, gk=null, mk=function(first){ return { qty:0, gross:0, dc:0, amt:0, vat:0, fee:0, svc:0, n:0, people:0, _p:{}, first:first }; }, tot=mk(null), groups=0, mark=0, keys=[];
  /* 합계 줄은 묶음 «맨 앞»(mark 자리)에 끼운다 — 다 더한 뒤라 flush 때 slice 로 삽입(대시보드 csub 와 같은 요령). 묶음 줄엔 data-g 로 묶음 번호 */
  var flush=function(){ if(!g) return; var gi=keys.length-1; var sr=sumRowHtml(labelOf(g.first)+' 합계', g, cols, mode, gi); h=h.slice(0,mark)+sr+h.slice(mark); groups++; g=null; };
  rows.forEach(function(x, i){ var k=keyOf(x); if(k!==gk){ flush(); gk=k; g=mk(x); keys.push(k); mark=h.length; }
    var rh=rowHtml(x, i), gi=keys.length-1, hid=(mode && dsFolded(mode, k)) ? ' style="display:none"' : '';
    h+=rh.replace(/^<tr/, '<tr data-g="'+gi+'"'+hid); var a=acc(x); [g, tot].forEach(function(t){ ['qty','gross','dc','amt','vat','fee','svc'].forEach(function(f){ t[f]+=n(a[f]); }); t.n++; if(a.who && !t._p[a.who]){ t._p[a.who]=1; t.people++; } }); });
  flush(); if(groups>1) h+=sumRowHtml('전체 합계', tot, cols);
  if(mode){ _dsGrpKeys[mode]=keys; setTimeout(function(){ dsFoldApply(mode); }, 0); }
  return h;
}
/* 합계용 — 반품은 음수 · 체크 안 한 올린 줄은 0 */
function dsAcc(x, mode){ var on=(mode==='pv')?!!x.chk:true, c=dsCalc(x, mode), sg=on?c.sign:0;
  return { qty:on?n(x.qty)*c.sign:0, gross:c.gross*sg, dc:c.dc*sg, amt:c.sup*sg, vat:c.vat*sg, fee:on?n(x.fee):0, svc:on?c.svc:0, who:on?dsName(x.rcvNm):'' }; }
function dsKeyLabel(dt, rd){ return (d10(dt)||'')+(rd?' '+rd:''); }
function dsPriceSet(list){ _dsPriceList=list||[]; _dsPrice={}; _dsPriceList.forEach(function(t){ if(t && t.prodCd) _dsPrice[String(t.prodCd)]=t; }); }
function dsTier(cd){ cd=String(cd||''); var t=_dsPrice[cd]||_dsPrice[_main[cd]]; return (t && t.useYn!=='N' && n(t.basePrice)>0) ? t : null; }
function tierUnder(t, q){ return n(t.baseQty)>0 && n(q)<n(t.baseQty) && n(t.underPrice)>0; }
function tierPrice(t, q){ return tierUnder(t, q) ? n(t.underPrice) : n(t.basePrice); }
/* 단가 칸 아래 표시 — 기본(이상 단가) · 미만(미만 단가) · 수동(단가표 값과 다름) */
function tierTag(cd, q, price){ var t=dsTier(cd); if(!t) return '';
  var u=tierUnder(t, q), want=tierPrice(t, q), man=(price!=='' && price!=null && Math.abs(n(price)-want)>0.0001);
  var tip=n(t.baseQty)>0 ? ('대상 단가표 : '+fmt(t.baseQty)+'개 이상 '+fmt(t.basePrice)+' · 미만 '+fmt(n(t.underPrice)||n(t.basePrice))) : ('대상 단가표 : 단가 '+fmt(t.basePrice));
  if(man) tip+=' — 지금 단가는 손으로 넣은 값('+fmt(want)+' 이 단가표 값)';
  return '<span class="tier '+(man?'man':(u?'under':'base'))+'" title="'+esc(tip)+'">'+(man?'수동':(u?'미만 '+fmt(t.underPrice):'기본'))+'</span>'; }
function dsName(v){ return String(v||'').replace(/s+/g,' ').trim(); }
function isJeju(a){ return /제주/.test(String(a||'')); }
function feeWant(amt, jeju){ return (amt>=DS_FREE?0:DS_FEE)+(jeju?DS_JEJU:0); }
function feeAutoSum(v){ return v===0 || v===DS_FEE || v===DS_JEJU || v===DS_FEE+DS_JEJU; }
/* 올린 표 — 받는 사람마다 택배비. 체크한 줄만 묶는다(빼는 줄은 저장되지 않으니) */
function pvFeeCalc(){
  var g={}, order=[];
  _pv.forEach(function(x, i){ x.feeInfo=null; if(!x.chk) return; var nm=dsName(x.rcvNm), k=nm ? (x.dlvDt+'|'+dsName(x.dsRound)+'|'+nm) : ('#'+i);
    if(!g[k]){ g[k]=[]; order.push(k); } g[k].push(x); });
  order.forEach(function(k){ var l=g[k], amt=0, jj=false; l.forEach(function(x){ var c=dsCalc(x,'pv'); amt+=c.sup*c.sign; if(isJeju(x.rcvAddr)) jj=true; });
    var info={ amt:amt, n:l.length, jeju:jj };
    l.forEach(function(x){ x.feeInfo=info; });
    if(l.some(function(x){ return !x.feeAuto; })) return;   /* 손으로 고친 받는 사람은 그대로 */
    var w=feeWant(amt, jj); l.forEach(function(x, i){ x.fee=(i===0 ? w : 0); }); });
}
function feeTag(info){ if(!info) return '';
  var free=info.amt>=DS_FREE;
  return '<span class="feeg '+(free?'free':'pay')+'" title="받는 사람 '+info.n+'줄 합계 '+fmt(info.amt)+'원(부가세 별도) — 3만 원부터 택배비 0원'+(info.jeju?' · 제주 '+fmt(DS_JEJU)+'원 추가':'')+'">'+(info.n>1?info.n+'줄 ':'')+'합 '+fmt(info.amt)+'</span>'; }
/* 차수 — 지난 저장의 마지막 차수 다음을 제안(같은 날이면 같은 차수). 예) 10월 11차 → 10월 12차 */
function roundParse(v){ var m=/(\d+)\s*월\s*(\d+)\s*차/.exec(String(v||'')); return m ? { m:+m[1], k:+m[2] } : null; }
function roundNext(){
  var dt=(document.getElementById('dt').value||'').replace(/-/g,''), r=_rounds[0], p=r?roundParse(r.dsRound):null;
  if(!p) return dt ? (+dt.slice(4,6))+'월 1차' : '';
  if(dt && String(r.toDt)===dt) return r.dsRound;
  return p.m+'월 '+(p.k+1)+'차';
}
function roundAuto(){ var v=roundNext(); var el=document.getElementById('round'); if(el && !_roundTouched && v) el.value=v;
  var l=document.getElementById('roundLs'); if(l && !l.value && v) l.value=v; }   /* 목록 쪽 칸도 비어 있으면 제안값으로 */
function roundListFill(){
  var o=[], seen={}, add=function(v){ v=dsName(v); if(v && !seen[v]){ seen[v]=1; o.push('<option value="'+esc(v)+'"></option>'); } };
  add(roundNext()); var p=roundParse(_rounds[0]&&_rounds[0].dsRound); if(p){ add(_rounds[0].dsRound); add((p.m%12+1)+'월 1차'); }
  _rounds.slice(0,8).forEach(function(r){ add(r.dsRound); });
  var dl=document.getElementById('roundList'); if(dl) dl.innerHTML=o.join('');
}


/* ── 읽기 : 표(HTML · 탭 글 · 엑셀) → 줄 ── */
function htmlRows(html){
  var doc=new DOMParser().parseFromString(html,'text/html'), best=null, bn=0;
  Array.prototype.forEach.call(doc.querySelectorAll('table'), function(t){ if(t.querySelector('table')) return;   /* 틀로 쓴 바깥 표는 건너뛴다 */
    var k=t.querySelectorAll('tr').length; if(k>bn){ bn=k; best=t; } });
  if(!best) return [];
  return Array.prototype.map.call(best.querySelectorAll('tr'), function(tr){ var out=[];
    Array.prototype.forEach.call(tr.children, function(td){ if(!/^(TD|TH)$/.test(td.tagName)) return;
      out.push(String(td.textContent||'')); var cs=parseInt(td.getAttribute('colspan'),10)||1; for(var k=1;k<cs;k++) out.push(''); });
    return out; });
}
/* 글 → 칸. 탭이 있으면 탭으로, 없으면 «빈칸 둘 이상»으로 나눈다 (2026-10-02 사용자 「이미지를 텍스트로 했는데 가능할까요」 —
     그림을 글자로 바꿔 주는 도구(글자 인식)는 칸 사이를 빈칸 여러 개로 띄우고 빈 칸 자리에 전각 빈칸(U+3000)을 넣어 준다. 전각 빈칸 하나짜리 칸은 parseRows 가 빈 칸으로 본다) */
function tsvRows(txt){ txt=String(txt||''); var tab=txt.indexOf('\t')>=0;
  return txt.split(/\r?\n/).map(function(l){ return tab ? l.split('\t') : l.replace(/^ +| +$/g,'').split(/ {2,}/); }); }
/* 빈칸으로 나눈 글이 «표»로 보이는가 — 네 칸 이상인 줄이 있을 때만(주소 한 줄을 칸에 붙여넣는 것까지 표로 읽지 않게) */
function looksSpaceTable(txt){ return String(txt||'').split(/\r?\n/).some(function(l){ return l.replace(/^ +| +$/g,'').split(/ {2,}/).length>=4; }); }
var TEL=/^0\d{1,2}[-\s.]?\d{3,4}[-\s.]?\d{4}$/;
function parseRows(aoa){
  aoa=(aoa||[]).map(function(r){ return (r||[]).map(function(c){ return String(c==null?'':c).replace(/ /g,' ').replace(/\s+/g,' ').trim(); }); })
               .filter(function(r){ return r.some(function(c){ return c!==''; }); });
  if(!aoa.length) return [];
  var hr=-1, col={ nm:-1, addr:-1, tel1:-1, tel2:-1, qty:-1, code:-1, item:-1 };
  for(var r=0;r<Math.min(aoa.length,15);r++){ var j=aoa[r].join('|').replace(/\s+/g,'');
    if(/받는|수령|수취/.test(j) && /(제품|품목|상품)명|품명|주소/.test(j)){ hr=r; break; } }
  if(hr>=0){ aoa[hr].forEach(function(c,i){ var t=c.replace(/\s+/g,'');
      if(col.nm<0 && /받는|수령|수취/.test(t)) col.nm=i;
      else if(col.addr<0 && /주소/.test(t)) col.addr=i;
      else if(/전화|연락처|휴대/.test(t)){ if(col.tel1<0) col.tel1=i; else if(col.tel2<0) col.tel2=i; }
      else if(col.qty<0 && /수량/.test(t)) col.qty=i;
      else if(col.code<0 && /(제품|품목|상품)코드/.test(t)) col.code=i;
      else if(col.item<0 && /(제품|품목|상품)명|품명/.test(t)) col.item=i; }); }
  var body=aoa.slice(hr+1), W=0; body.forEach(function(r){ if(r.length>W) W=r.length; });
  var HW=(hr>=0) ? aoa[hr].length : W;   /* 제대로 된 줄의 칸 수 */
  /* 머리 줄이 없으면 열 수로 — 10열 = 메일 표 그대로(공란 셋 포함) · 7열 = 공란을 뺀 것. 그 밖은 줄마다 짐작한다 */
  if(hr<0){ if(W>=10) col={ nm:0, addr:2, tel1:3, tel2:4, qty:5, code:8, item:9 }; else if(W===7) col={ nm:0, addr:1, tel1:2, tel2:3, qty:4, code:5, item:6 }; else col=null; }
  var out=[];
  body.forEach(function(a){
    var g=function(k){ return (col && col[k]>=0 && a[col[k]]!=null) ? a[col[k]] : ''; }, x;
    /* 칸 수가 머리 줄보다 모자라면(글자 인식이 두 칸을 붙였거나 빈 칸을 빠뜨린 줄) 칸 번호로 읽으면 한 칸씩 밀린다 → 전화번호를 기준으로 맞춘다(anchorRow) */
    if(col && a.length<HW && a.some(function(v){ return TEL.test(v); })){ x=anchorRow(a); }
    else if(col){ x={ rcvNm:g('nm'), rcvAddr:g('addr'), rcvTel:g('tel1'), rcvTel2:g('tel2'), qty:n(String(g('qty')).replace(/[^0-9.,]/g,'')), rcvItemCd:g('code'), itemNm:g('item') }; }
    else { x=guessRow(a); }
    if(!x.rcvNm && !x.itemNm && !x.qty) return;
    out.push(x);
  });
  return out;
}
/* 칸이 붙거나 빠진 줄 — 전화번호 칸을 기준으로 앞·뒤를 나눠 맞춘다.
     앞 = 받는 사람·주소(한 칸으로 붙었으면 시·도 이름이 시작하는 자리에서 가른다) · 뒤 = (전화번호2) · 수량 · 제품코드 · 제품명.
     맞춰 넣은 줄은 fix 표시를 달아 화면이 ⚠ 로 알린다(사람이 한 번 본다). */
var REGION=/\s(서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충청[남북]|충[남북]|전라[남북]|전[남북]|경상[남북]|경[남북]|제주)/;
function anchorRow(a){
  var x={ rcvNm:'', rcvAddr:'', rcvTel:'', rcvTel2:'', qty:0, rcvItemCd:'', itemNm:'', fix:true }, t=-1, i;
  for(i=0;i<a.length;i++){ if(TEL.test(a[i])){ t=i; break; } }
  if(t<0) return guessRow(a);
  var nb=function(v){ return v!==''; }, left=a.slice(0,t).filter(nb), right=a.slice(t+1);
  x.rcvTel=a[t];
  if(right.length && TEL.test(right[0])){ x.rcvTel2=right[0]; right=right.slice(1); }
  var r=right.filter(nb);
  for(i=0;i<r.length;i++){ if(/^[\d,]+$/.test(r[i])){ x.qty=n(r[i]); r.splice(i,1); break; } }
  if(r.length>=2){ x.itemNm=r[r.length-1]; x.rcvItemCd=r[r.length-2]; } else if(r.length===1){ x.itemNm=r[0]; }
  if(left.length>=2){ x.rcvNm=left[0]; x.rcvAddr=left.slice(1).join(' '); }
  else if(left.length===1){ var m=REGION.exec(left[0]);
    if(m){ x.rcvNm=left[0].slice(0,m.index).trim(); x.rcvAddr=left[0].slice(m.index).trim(); } else x.rcvNm=left[0]; }
  return x;
}
/* 머리 줄도 없고 열 수도 낯선 줄 — 전화 모양·숫자 모양으로 짐작한다(넣은 뒤 화면에서 고친다) */
function guessRow(a){
  var c=a.filter(function(v){ return v!==''; }), x={ rcvNm:'', rcvAddr:'', rcvTel:'', rcvTel2:'', qty:0, rcvItemCd:'', itemNm:'' }, rest=[];
  c.forEach(function(v){ if(TEL.test(v)){ if(!x.rcvTel) x.rcvTel=v; else if(!x.rcvTel2) x.rcvTel2=v; } else rest.push(v); });
  var nums=[]; rest.forEach(function(v,i){ if(/^[\d,]+$/.test(v)) nums.push(i); });
  if(nums.length){ x.qty=n(rest[nums[0]]); if(nums.length>1) x.rcvItemCd=rest[nums[nums.length-1]]; }
  var txt=rest.filter(function(v,i){ return nums.indexOf(i)<0; });
  if(txt.length){ x.rcvNm=txt[0]; if(txt.length>1) x.itemNm=txt[txt.length-1];
    if(txt.length>2) x.rcvAddr=txt.slice(1,-1).sort(function(p,q){ return q.length-p.length; })[0]; }
  return x;
}
function newRow(x){ x=x||{}; return { chk:true, dlvDt:document.getElementById('dt').value||'', dsRound:dsName(document.getElementById('round').value), rcvNm:x.rcvNm||'', rcvAddr:x.rcvAddr||'', rcvTel:x.rcvTel||'', rcvTel2:x.rcvTel2||'',
  qty:n(x.qty), rcvItemCd:x.rcvItemCd||'', itemNm:x.itemNm||'', itemCd:'', itemAuto:false, price:'', priceAuto:true, fix:!!x.fix, fee:'', feeAuto:true,
  dsDcAmt:'', dsSvcQty:'', dsZeroYn:'N', dsTrxGb:'판매', dsMemo:'', dsVatAmt:'' }; }   /* 판매등록 그리드 칸 (2026-10-27) · dsVatAmt '' = 자동 */   /* 택배비 = 받는 사람마다 자동(pvFeeCalc) — 종전 줄마다 4,500 고정 */
function addParsed(rows, src){
  if(!rows.length){ err('표에서 읽을 줄을 찾지 못했습니다.<br><span style="font-size:13px">메일 본문의 표를 머리 줄(받는 사람 … 제품명)부터 끝 줄까지 끌어 고른 뒤 복사해 붙여 보세요.</span>'); return; }
  if(src && !_fileNm) _fileNm=src;
  /* 직접 넣으려고 더해 둔 빈 줄은 치운다 */
  _pv=_pv.filter(function(y){ return y.rcvNm||y.rcvAddr||y.itemNm||y.itemCd||y.qty; });
  rows.forEach(function(x){ _pv.push(newRow(x)); });
  autoFill(); pvRender();
  if(window._toast) _toast(rows.length+'줄을 읽었습니다 — 발주일자·품목코드·단가를 확인하고 [저장]','ok');
}
function addRow(focus){ _pv.push(newRow()); pvRender();
  if(focus){ var e=document.querySelector('#pvBody [data-k="'+(_pv.length-1)+':rcvNm"]'); if(e) e.focus(); } }
function onFiles(files){
  var list=Array.prototype.slice.call(files||[]); if(!list.length) return;
  var img=list.filter(function(f){ return /^image\//.test(f.type); }), xl=list.filter(function(f){ return !/^image\//.test(f.type); });
  if(img.length) showImg(img[0]);
  if(!xl.length) return;
  if(!window.XLSX){ err('엑셀 읽기 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  var jobs=xl.map(function(f){ return new Promise(function(res){ var rd=new FileReader();
    rd.onload=function(e){ try{ var wb=XLSX.read(new Uint8Array(e.target.result),{ type:'array' }), rows=[];
        wb.SheetNames.forEach(function(sn){ rows=rows.concat(parseRows(XLSX.utils.sheet_to_json(wb.Sheets[sn],{ header:1, raw:false, defval:'' }))); });
        res({ nm:f.name, rows:rows }); }catch(x){ res({ nm:f.name, rows:[], err:x.message }); } };
    rd.readAsArrayBuffer(f); }); });
  Promise.all(jobs).then(function(rs){ var add=[], bad=[];
    rs.forEach(function(r){ if(r.rows.length) add=add.concat(r.rows); else bad.push(esc(r.nm)+(r.err?' — '+esc(r.err):' — 읽을 줄을 못 찾았습니다')); });
    if(add.length) addParsed(add, rs.map(function(r){ return r.nm; }).join(', '));
    if(bad.length) err('읽지 못한 파일<br><span style="font-size:13px">'+bad.join('<br>')+'</span>'); });
}
/* 캡쳐 그림 — 위에 띄워 두고 보면서 친다. 그림 속 글자는 자동으로 읽지 않는다.
     (2026-10-02 같은 날 AI(구글 Gemini) 판독을 붙였다가 사용자 「제미나이는 취소하고 기존 해놓은 대로」로 뺐다 — 그림은 어디로도 보내지 않는다. 다시 붙이지 말 것)
   ★확대·축소는 «그림에만» (사용자 「이미지 올린 것 확대축소 이미지만 적용되게 — 지금 전체 됨」) :
     [작게][크게][원래 크기] 단추 · 그림 위에서 Ctrl+휠. 그림 너비(px)만 바꾸고, 넘치는 부분은 그림 칸(#capScroll) 안에서 스크롤한다.
     셸의 화면 배율(가+/가-)과 브라우저의 Ctrl+휠은 화면 전체를 키운다 — 그래서 그림 위의 Ctrl+휠은 가로채 그림만 키운다. */
var _capUrl='', _capW=0, _capNat=0;
function showImg(file){
  if(_capUrl){ try{ URL.revokeObjectURL(_capUrl); }catch(e){} }
  _capUrl=URL.createObjectURL(file); var im=document.getElementById('capImg');
  im.onload=function(){ _capNat=im.naturalWidth||600; _capW=_capNat; capApply(); };
  im.src=_capUrl; document.getElementById('capBox').style.display='block';
  if(!_fileNm) _fileNm=file.name||'캡쳐 그림';
  if(!_pv.length){ for(var i=0;i<3;i++) _pv.push(newRow()); }
  pvRender();
  if(window._toast) _toast('캡쳐 그림을 띄웠습니다 — 그림을 보면서 아래 표에 넣으세요. 확대·축소는 그림에만 적용됩니다.','info');
}
function capApply(){ var im=document.getElementById('capImg'), p=document.getElementById('capPct'); if(!_capW) return;
  im.style.width=_capW+'px'; if(p) p.textContent=Math.round(_capW/(_capNat||_capW)*100)+'%'; }
/* d>0 크게 · d<0 작게. step = 한 번에 바꾸는 비율(단추 1.25 · 휠 1.1). 원래 크기의 20% ~ 600% */
function capZoom(d, step){ if(!_capW) return; var f=step||1.25, nat=_capNat||_capW;
  _capW=Math.max(Math.round(nat*0.2), Math.min(Math.round(nat*6), Math.round(_capW*(d>0?f:1/f)))); capApply(); }
function capReset(){ if(!_capNat) return; _capW=_capNat; capApply(); }
function capTall(){ var s=document.getElementById('capScroll'), b=s.classList.toggle('big'); document.getElementById('capTallBtn').textContent=b?'짧게 보기':'길게 보기'; }
function capClose(){ document.getElementById('capBox').style.display='none'; }

/* ── 올린 표 ── */
function autoFill(){ _pv.forEach(function(x){
  if(!x.itemCd && x.itemNm && _map[x.itemNm]){ x.itemCd=_map[x.itemNm]; x.itemAuto=true; }
  if(x.itemCd && x.priceAuto){ var p=priceOf(x.itemCd, x.qty); x.price=(p>0?p:''); } }); }   /* 자동 단가는 수량에 따라 늘 다시 (단가표 기본/미만) */
function cdCls(cd, auto){ if(!cd) return ''; return _prod[cd]!=null ? (auto?' auto':' ok') : ' bad'; }
function rowReady(x){ return x.chk && x.dlvDt && x.itemCd && n(x.qty)>=1; }
function pvRender(){
  var has=_pv.length>0;
  document.getElementById('howBox').style.display=has?'none':'';
  ['pvWrap','pvNote'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  var pg=document.getElementById('pvWrap').nextElementSibling; if(pg && pg.classList.contains('kgg')) pg.style.display=has?'':'none';   /* 높이 막대도 같이 숨긴다 */
  ['btnSave','btnXls','pvFoldAll'].forEach(function(id){ document.getElementById(id).style.display=has?'':'none'; });
  pvFeeCalc();
  document.getElementById('pvBody').innerHTML=withSums(_pv, function(x){ return x.dlvDt+'|'+dsName(x.dsRound); }, function(x){ return dsKeyLabel(x.dlvDt, dsName(x.dsRound)); },
    function(x){ return dsAcc(x, 'pv'); }, /* rowHtml */
    function(x,i){
    var pn=_prod[x.itemCd], k=function(f){ return ' data-k="'+i+':'+f+'"'; }, t=function(f,w,ph){ return '<input type="text"'+k(f)+' style="width:'+w+'px" value="'+esc(x[f])+'" placeholder="'+(ph||'')+'" onchange="pvSet('+i+',\''+f+'\',this)">'; };
    return '<tr class="'+(x.chk?'':'off')+'"><td><input type="checkbox" '+(x.chk?'checked':'')+' onchange="_pv['+i+'].chk=this.checked; pvLater()"></td>'
      +'<td><button class="x" title="이 줄을 화면에서 뺍니다" onclick="pvDel('+i+')">✕</button></td>'
      +(x.fix?'<td style="color:#b45309;font-weight:800;background:#fff7d6" title="원본 글에서 이 줄은 칸이 붙거나 빠져 있어 전화번호를 기준으로 맞춰 넣었습니다 — 받는 사람·주소·수량·제품명을 확인하세요">⚠ '+(i+1)+'</td>':'<td>'+(i+1)+'</td>')
      +'<td><input type="date"'+k('dlvDt')+' class="req'+(x.dlvDt?'':' bad')+'" value="'+esc(x.dlvDt)+'" onchange="pvSet('+i+',\'dlvDt\',this)"></td>'
      +'<td><input type="text" list="roundList"'+k('dsRound')+' class="rnd" value="'+esc(x.dsRound||'')+'" placeholder="10월 1차" onchange="pvSet('+i+',\'dsRound\',this)"></td>'
      +'<td class="l">'+t('rcvNm',150,'받는 사람')+'</td><td class="l">'+t('rcvAddr',300,'주소')+'</td><td>'+t('rcvTel',118,'')+'</td><td>'+t('rcvTel2',118,'')+'</td>'
      +'<td><input type="text"'+k('qty')+' class="num'+(n(x.qty)>=1?'':' bad')+'" style="width:84px" value="'+(x.qty?esc(fmt(x.qty)):'')+'" onchange="pvSet('+i+',\'qty\',this)"></td>'
      +'<td><input type="text"'+k('fee')+' class="num" style="width:68px'+(x.feeAuto?'':';border-color:#e2b93b')+'" value="'+(feeNum(x)===''?'':esc(fmt(x.fee)))+'" title="'+(x.feeAuto?'자동 — 받는 사람 합계 3만 원부터 0원, 미만 4,000원':'손으로 넣은 값 — 비우면 다시 자동')+'" onchange="pvSet('+i+',\'fee\',this)">'+feeTag(x.feeInfo)+'</td>'
      +'<td>'+t('rcvItemCd',64,'')+'</td>'
      +'<td class="l">'+(x.itemCd?'<span class="sub nmf'+(pn==null?' warn':'')+'">'+(x.itemAuto?'<span class="bd auto" title="지난 저장에서 가져온 값">자동</span> ':'')+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span>':'')
        +'<input type="text" list="prodList"'+k('itemCd')+' class="cd'+cdCls(x.itemCd,x.itemAuto)+'" value="'+esc(x.itemCd)+'" placeholder="명칭 또는 코드" onchange="setItem('+i+',this)"></td>'
      +'<td class="l">'+t('itemNm',190,'제품명')+'</td>'
      +'<td><input type="text"'+k('price')+' class="num" style="width:74px" value="'+(x.price===''?'':esc(fmt(x.price)))+'" title="'+(x.priceAuto&&x.price!==''?(dsTier(x.itemCd)?'대상 단가표 값 — 고칠 수 있습니다(비우면 다시 자동)':'상품코드 판매가에서 가져온 값 — 고칠 수 있습니다'):'손으로 넣은 값 — 비우면 다시 자동')+'" onchange="pvSet('+i+',\'price\',this)">'+tierTag(x.itemCd, x.qty, x.price)+'</td>'
      +extCells(x, i, 'pv')+'</tr>';
  }, { lead:9, mid:4, tail:0 }, 'pv');   /* 칸 차례 : 체크·빼기·No·발주일자·차수·받는 사람·주소·전화 1·전화 2(9) | 수량 | 택배비 | 제품코드·품목코드·제품명·단가(4) | 공급가·부가세·판매금액 */
  pvInfo();
}
function pvInfo(){
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(rowReady), unk=rdy.filter(function(x){ return _prod[x.itemCd]==null; }).length;
  var q=0, amt=0, vat=0, fee=0; rdy.forEach(function(x){ var c=dsCalc(x,'pv'); q+=n(x.qty)*c.sign; amt+=c.sup*c.sign; vat+=c.vat*c.sign; }); sel.forEach(function(x){ fee+=n(x.fee); });
  document.getElementById('pvInfo').textContent=_pv.length ? ('올린 줄 '+_pv.length+' · 선택 '+sel.length+' · 저장 가능 '+(rdy.length-unk)
    +(sel.length-rdy.length?' · 빠진 값이 있는 줄 '+(sel.length-rdy.length):'')+(unk?' · 마스터에 없는 코드 '+unk+'줄(저장 막힘)':'')+' · 수량 '+fmt(q)+' · 공급가 '+fmt(amt)+' · 부가세 '+fmt(vat)+' · 판매금액 '+fmt(amt+vat)+'원 · 택배비 '+fmt(fee)+'원(부가세 포함 '+fmt(feeTot(fee))+') · 택배 포함 '+fmt(amt+vat+feeTot(fee))+'원') : '';
  var a=document.getElementById('pvAll'); if(a) a.checked=_pv.length>0 && _pv.every(function(x){ return x.chk; });
}
/* 다시 그리기 — 칸을 벗어난 뒤(다음 칸으로 옮겨 간 뒤)에 그리고, 옮겨 간 칸을 다시 잡는다(Tab 으로 이어 칠 수 있게) */
function pvLater(){ setTimeout(function(){ var a=document.activeElement, k=(a&&a.getAttribute)?a.getAttribute('data-k'):null; pvRender();
  if(k){ var e=document.querySelector('#pvBody [data-k="'+k+'"]'); if(e){ e.focus(); if(e.type==='text'){ try{ e.select(); }catch(x){} } } } },0); }
function pvSet(i, f, el){
  var x=_pv[i]; if(!x) return; var v=String(el.value||'').trim();
  if(f==='qty'){ x.qty=Math.round(n(v)); el.value=x.qty?fmt(x.qty):''; el.classList.toggle('bad', !(x.qty>=1));
    if(x.itemCd && x.priceAuto){ var pq=priceOf(x.itemCd, x.qty); x.price=(pq>0?pq:''); }   /* 수량이 바뀌면 기본/미만 단가도 다시 (2026-10-27) */
    pvLater(); return; }
  else if(f==='price'){ if(v===''){ x.priceAuto=true; var pp=priceOf(x.itemCd, x.qty); x.price=(pp>0?pp:''); } else { x.price=Math.max(0,n(v)); x.priceAuto=false; } pvLater(); return; }
  else if(f==='fee'){ if(v===''){ x.feeAuto=true; } else { x.fee=Math.max(0,Math.round(n(v))); x.feeAuto=false; } pvLater(); return; }   /* 손으로 넣으면 그 받는 사람은 자동을 멈춘다 · 비우면 다시 자동 */
  else if(f==='dlvDt'){ x.dlvDt=v; el.classList.toggle('bad', !v); pvLater(); return; }
  else if(f==='dsRound' || f==='rcvNm' || f==='rcvAddr'){ x[f]=(f==='dsRound'?dsName(v):v); pvLater(); return; }   /* 받는 사람 묶음이 바뀐다 → 택배비 다시 */
  else if(f==='dsVatAmt'){ x[f]=(vatIsAuto(v)?'':Math.max(0,Math.round(n(v)))); pvLater(); return; }   /* 비우면 0(부가세 없음) · 「자동」·↺ 이면 자동 (2026-10-27 「부가세 빼면 금액 변경안됨」 — 비움=자동이던 것을 비움=0 으로) */
  else if(f==='dsDcAmt' || f==='dsSvcQty'){ x[f]=(v===''?'':Math.max(0,Math.round(n(v)))); pvLater(); return; }   /* DC·서비스 → 다시 계산 (2026-10-27) */
  else if(f==='dsZeroYn' || f==='dsTrxGb'){ x[f]=v; pvLater(); return; }
  else if(f==='dsMemo'){ x[f]=v; return; }
  else if(f==='itemNm'){ x.itemNm=v; if(!x.itemCd && v && _map[v]){ autoFill(); pvLater(); return; } }
  else x[f]=v;
  var a=document.getElementById('amt'+i), a0=Math.round(n(x.qty)*n(x.price)), v0=vatOf(x.itemCd, a0); if(a){ a.textContent=fmt(a0); var ve=document.getElementById('vat'+i), te=document.getElementById('tot'+i); if(ve) ve.textContent=fmt(v0); if(te) te.textContent=fmt(a0+v0); }
  pvInfo();
}
/* 목록에서 고른 「명칭 [코드]」 → 코드. 코드만 친 것은 그대로, 명칭만 정확히 친 것은 마스터에서 찾는다 */
function pickCd(v){
  v=String(v||'').trim(); var m=/\[([^\[\]]+)\]\s*$/.exec(v); if(m) return m[1].trim();
  if(_prod[v]!=null) return v;
  var hit=[]; for(var cd in _prod){ if(String(_prod[cd]).trim()===v) hit.push(cd); } return hit.length===1? hit[0] : v;
}
/* 품목코드 — 한 번 넣으면 같은 제품명의 빈 칸(또는 자동으로 채워졌던 칸)에 같이. 단가도 그 코드의 판매가로(손으로 고친 단가는 그대로 둔다) */
function setItem(i, el){
  var x=_pv[i]; if(!x) return; var v=pickCd(el.value), nm=x.itemNm;
  _pv.forEach(function(y){ if(y===x || (nm && y.itemNm===nm && (!y.itemCd || y.itemAuto))){ y.itemCd=v; y.itemAuto=false;
    if(y.priceAuto){ var p=priceOf(v, y.qty); y.price=(p>0?p:''); } } });
  pvLater();
}
function pvAllChk(el){ _pv.forEach(function(x){ x.chk=el.checked; }); pvRender(); }
function pvDel(i){ _pv.splice(i,1); pvRender(); }
function pvClear(){ _pv=[]; _fileNm=''; capClose();
  if(_capUrl){ try{ URL.revokeObjectURL(_capUrl); }catch(e){} _capUrl=''; _capW=0; _capNat=0; document.getElementById('capImg').removeAttribute('src'); }
  pvRender(); }
/* 전체 비우기 — 올려 둔 줄과 캡쳐 그림을 모두 치운다. 넣어 둔 내용이 있으면 한 번 묻는다(저장된 것은 건드리지 않는다) */
function pvClearAsk(){
  var img=document.getElementById('capBox').style.display==='block';
  var filled=_pv.filter(function(y){ return y.rcvNm||y.rcvAddr||y.rcvTel||y.itemNm||y.itemCd||y.qty; }).length;
  if(!_pv.length && !img){ if(window._toast) _toast('비울 내용이 없습니다.','info'); return; }
  if(!filled){ pvClear(); return; }
  _confirmBox({ icon:'🧹', okText:'비우기', msg:'올려 둔 <b>'+filled+'</b>줄'+(img?'과 캡쳐 그림':'')+'을 모두 비웁니다.<br><span style="font-size:13px;color:#3d4d5c">아직 저장하지 않은 내용은 사라집니다. 아래 「저장된 대상 발주」는 그대로입니다.</span>',
    onOk:function(){ pvClear(); if(window._toast) _toast('비웠습니다','ok'); }, onCancel:function(){} });
}
function dtAll(){ var d=document.getElementById('dt').value, rd=dsName(document.getElementById('round').value); if(!d){ err('발주일자(납품일자)를 고르세요.'); return; }
  if(!_pv.length){ if(window._toast) _toast('올려 둔 줄이 없습니다 — 이 날짜·차수는 앞으로 올리는 줄에 들어갑니다.','info'); return; }
  _pv.forEach(function(x){ x.dlvDt=d; x.dsRound=rd; }); pvRender(); if(window._toast) _toast('모든 줄에 발주일자 '+d+(rd?' · 차수 '+rd:'')+' 를 넣었습니다','ok'); }

/* ── 저장 ── */
function save(){
  var bizCd=document.getElementById('bizSel').value||'', bizNm=_bizNm[bizCd]||'';
  if(!bizCd){ err('사업장(대상)을 고르세요.<br><span style="font-size:13px">목록이 비어 있으면 거래처관리(사업장)에 대상 사업장을 먼저 등록하세요.</span>'); return; }
  var sel=_pv.filter(function(x){ return x.chk; }), rdy=sel.filter(rowReady), miss=sel.length-rdy.length;
  if(!rdy.length){ err('저장할 줄이 없습니다 — 발주일자·품목코드·수량을 넣으세요.'); return; }
  var unk=rdy.filter(function(x){ return _prod[x.itemCd]==null; });
  if(unk.length){ var ui={}; unk.forEach(function(x){ ui[x.itemCd]=1; });
    err('마스터에 없는 품목코드가 든 줄이 <b>'+unk.length+'</b>개 있어 저장하지 않았습니다.<br><span style="font-size:13px">품목코드 : <b>'+esc(Object.keys(ui).join(', '))+'</b> — 상품코드등록·매칭코드에 먼저 등록하거나, 노란 칸을 고치거나 그 줄의 체크를 빼고 다시 저장하세요.</span>'); return; }
  var noRnd=rdy.filter(function(x){ return !dsName(x.dsRound); }).length;
  var noPrice=rdy.filter(function(x){ return !(n(x.price)>0); }).length, amt=rdy.reduce(function(s,x){ return s+n(x.qty)*n(x.price); },0);
  var ds={}; rdy.forEach(function(x){ ds[x.dlvDt]=1; }); var dl=Object.keys(ds).sort();
  var body=function(force){ return { bizCd:bizCd, bizNm:bizNm, fileNm:_fileNm||'', force:force?'Y':'',
    rows:rdy.map(function(x){ return { dlvDt:x.dlvDt, dsRound:dsName(x.dsRound), rcvNm:x.rcvNm, rcvAddr:x.rcvAddr, rcvTel:x.rcvTel, rcvTel2:x.rcvTel2, qty:x.qty, rcvItemCd:x.rcvItemCd,
      itemNm:(x.itemNm||prodNmOf(x.itemCd)), itemCd:x.itemCd, price:(x.price===''?'':x.price), fee:feeNum(x),
      dsDcAmt:(x.dsDcAmt===''?'':x.dsDcAmt), dsSvcQty:(x.dsSvcQty===''?'':x.dsSvcQty), dsZeroYn:x.dsZeroYn||'N', dsTrxGb:x.dsTrxGb||'판매', dsMemo:x.dsMemo||'', dsVatAmt:(x.dsVatAmt==null?'':x.dsVatAmt) }; }) }; };
  var go=function(force){
    var b=document.getElementById('btnSave'); b.disabled=true;
    post('/shipout/daesangPoSave.do', body(force), true).then(pj)
      .then(function(j){
        if(j.error){ err(esc(j.error)); return; }
        if(j.dup){ _confirmBox({ icon:'⚠️', okText:'그래도 저장',
            msg:'이미 저장된 것과 <b>같은 줄이 '+j.dup+'개</b> 있습니다(발주일자·받는 사람·제품명·수량이 모두 같음).<br><span style="font-size:13px;color:#3d4d5c">같은 표를 두 번 올린 것이 아닌지 확인하세요. 그래도 저장하면 두 번 들어갑니다.</span>',
            onOk:function(){ go(true); }, onCancel:function(){} }); return; }
        rdy.forEach(function(x){ if(x.itemNm) _map[x.itemNm]=x.itemCd; });
        _pv=_pv.filter(function(x){ return rdy.indexOf(x)<0; }); if(!_pv.length){ _fileNm=''; } pvRender();
        document.getElementById('fr').value=dl[0]<document.getElementById('fr').value||!document.getElementById('fr').value?dl[0]:document.getElementById('fr').value;
        if(dl[dl.length-1]>document.getElementById('to').value) document.getElementById('to').value=dl[dl.length-1];
        load(); _roundTouched=false; loadDsMap();   /* 차수 목록 새로 → 다음 차수 제안 */
        ok('대상 발주 <b>'+(j.cnt||rdy.length)+'</b>줄을 저장했습니다.'+(_pv.length?'<br><span style="font-size:13px">저장하지 않은 '+_pv.length+'줄이 화면에 남아 있습니다.</span>':'')
          +(j.warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(j.warn)+'</span>':''));
      })
      .catch(function(e){ err('저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
      .then(function(){ b.disabled=false; });
  };
  _confirmBox({ icon:'💾', okText:'저장',
    msg:'대상 발주 <b>'+rdy.length+'</b>줄을 저장합니다 — 저장하면 곧 <b>출고·매출</b>이고 재고에서 빠집니다.<br>발주일자 <b>'+esc(dl.length>1?(dl[0]+' ~ '+dl[dl.length-1]):dl[0])+'</b> · 사업장 <b>'+esc(bizNm)+'</b><br>금액 <b>'+fmt(amt)+'</b>원'
      +(noPrice?'<br><span style="color:#c0392b;font-size:13px">단가가 빈 줄 '+noPrice+'개 — 금액 0원으로 남습니다(매출 0원 · 저장 뒤 목록에서 고칠 수 있습니다).</span>':'')
      +(miss?'<br><span style="color:#b45309;font-size:13px">발주일자·품목코드·수량이 빠진 '+miss+'줄은 저장하지 않습니다(화면에 남습니다).</span>':'')
      +(noRnd?'<br><span style="color:#b45309;font-size:13px">차수가 빈 줄 '+noRnd+'개 — 마감 엑셀에 날짜만 찍힙니다(저장 뒤 목록에서 넣을 수 있습니다).</span>':'')
      +'<br>택배비 합계 <b>'+fmt(rdy.reduce(function(s2,x){ return s2+n(x.fee); },0))+'</b>원'
      +'<br><span style="font-size:13px;color:#3d4d5c">택배비는 받는 사람마다 「택배비(로젠)」 한 줄로 매출에 같이 잡힙니다. 같은 날짜에 이미 저장된 줄이 있어도 그대로 들어갑니다 — 겹치면 아래 목록에서 지우세요.</span>',
    onOk:function(){ go(true); }, onCancel:function(){} });   /* ★같은 날짜·같은 줄이 있어도 무조건 들어간다 (2026-10-27 사용자 「동일 일자도 저장하면 무조건 들어오게 — 사용자가 알아서 조정」) — 종전엔 서버 dup 검사에 걸리면 한 번 더 물었다 */
}

/* ── 엑셀 저장 — «택배 납기관리»의 엑셀과 같은 양식 (2026-10-02 사용자 「엑셀출력은 택배 납기관리에서 엑셀저장처럼 동일하게」) ──
     parcelOut.jsp 의 poExcelMake 와 같은 모양 : 머리글 줄 없음 · 9칸 · 시트명 = MMDD(여러 날이면 MMDD-MMDD) · 같은 칸 너비·테두리.
       A = 받는 분 · B = 빈칸 · C = 주소 · D = 전화 · E = 휴대폰(전화번호2) · F = 총수량 · G = 운임 · H = 빈칸 · I = 품목명(대상 제품명)
     ★G(운임) = 화면의 택배비 칸 그대로(기본 4,500 · 고친 줄은 그 값 · 비운 줄은 빈 칸). 택배 납기관리는 「총수량 × 기본 운임」이지만
       대상의 수량은 낱개(ea)라 곱하지 않는다 — 한 줄에 한 번.
     (같은 날 먼저 만든 「메일 표와 같은 10칸 + 머리글」 양식은 이 요청으로 바꿨다. 대상 제품코드 칸은 택배 양식에 없어 빠진다.) */
function xlsOut(rows){
  if(!window.XLSX){ err('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  if(!rows.length){ err('엑셀로 저장할 줄이 없습니다.'); return; }
  var ds=rows.map(function(x){ return d10(x.dlvDt); }).filter(function(v){ return v; }).sort();
  var dt=ds.length?ds[0]:ymd(new Date()), dt2=ds.length?ds[ds.length-1]:dt;
  var mmdd=dt.slice(5,7)+dt.slice(8,10)+(dt2!==dt ? '-'+dt2.slice(5,7)+dt2.slice(8,10) : '');
  var aoa=rows.map(function(x){ return [ x.rcvNm||'', '', x.rcvAddr||'', x.rcvTel||'', x.rcvTel2||'', n(x.qty), feeNum(x), '', x.itemNm||'' ]; });
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  ws['!cols']=[{ wch:24 },{ wch:4 },{ wch:46 },{ wch:14 },{ wch:14 },{ wch:9 },{ wch:8 },{ wch:4 },{ wch:44 }];
  var LINE={ style:'thin', color:{ rgb:'DFE6E3' } }, box={ top:LINE, bottom:LINE, left:LINE, right:LINE };
  var CELL={ alignment:{ vertical:'center' }, border:box }, NUM={ alignment:{ horizontal:'right', vertical:'center' }, border:box };
  for(var r=0;r<aoa.length;r++){ for(var c=0;c<9;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c });
    if(!ws[ref]) ws[ref]={ t:'s', v:'' };          /* 빈 칸도 테두리가 이어지게 */
    ws[ref].s=((c===5 || c===6) ? NUM : CELL); } }   /* F = 총수량 · G = 운임 = 숫자 칸(오른쪽 맞춤) */
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, mmdd);
  XLSX.writeFile(wb, '택배출고_대상_'+dt.replace(/-/g,'')+'.xlsx');
  if(window._toast) _toast('📥 엑셀 생성 — '+rows.length+'줄 (택배 납기관리와 같은 양식)','ok');
}
function pvXls(){ xlsOut(_pv.filter(function(x){ return x.chk && (x.rcvNm||x.rcvAddr||x.itemNm||x.qty); })); }
function lsXls(){ var pick=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) pick.push(x); });
  xlsOut(pick.length?pick:_ls); }

/* ── 저장된 목록 ── */
function load(cb){
  document.getElementById('lsBody').innerHTML='<tr><td colspan="19" class="msg">조회 중…</td></tr>';
  post('/shipout/daesangPoList.do','frDt='+encodeURIComponent(document.getElementById('fr').value)+'&toDt='+encodeURIComponent(document.getElementById('to').value)).then(pj)
    .then(function(j){ _ls=(j&&j.data)||[]; _ls.forEach(function(x){ x.fee=(x.rcvFee==null ? '' : n(x.rcvFee)); });   /* 택배비 = 저장된 값(없으면 빈 칸) */ if(j&&j.error){ _ls=[]; document.getElementById('lsBody').innerHTML='<tr><td colspan="19" class="msg" style="color:#c0392b">'+esc(j.error)+'</td></tr>'; document.getElementById('lsInfo').textContent=''; return; } lsRender(); if(typeof cb==='function') cb(); })
    .catch(function(e){ document.getElementById('lsBody').innerHTML='<tr><td colspan="19" class="msg" style="color:#c0392b">조회 오류 — '+esc(e.message)+'</td></tr>'; });
}
function lsRender(){
  var tb=document.getElementById('lsBody'); document.getElementById('lsAll').checked=false;
  if(!_ls.length){ tb.innerHTML='<tr><td colspan="19" class="msg">저장된 대상 발주가 없습니다.</td></tr>'; document.getElementById('lsInfo').textContent=''; return; }
  var q=0, amt=0, lsGrpInfo={};
  _ls.forEach(function(x){ var k=lsKey(x), g=lsGrpInfo[k]||(lsGrpInfo[k]={ amt:0, n:0, jeju:false }), c=dsCalc(x,'ls'); g.amt+=c.sup*c.sign; g.n++; if(isJeju(x.rcvAddr)) g.jeju=true; });
  var V=_ls.filter(lsHit);   /* 품목코드 검색(2026-10-31) — 거른 줄만 묶음·합계에 · i 는 아래에서 _ls 색인으로 */
  tb.innerHTML=withSums(V, function(x){ return String(x.dlvDt)+'|'+dsName(x.dsRound); }, function(x){ return dsKeyLabel(x.dlvDt, dsName(x.dsRound)); },
    function(x){ return dsAcc(x, 'ls'); },
    function(x,i){ i=_ls.indexOf(x); q+=n(x.qty); amt+=n(x.qty)*n(x.salePrice); var pn=_prod[x.itemCd];
    /* 글자 칸(배송 정보·제품코드·제품명) = 입력칸 — 고치면 lsInfo 가 그 줄만 바로 저장한다 */
    var ti=function(f,w){ return '<input type="text" style="width:'+w+'px" value="'+esc(x[f])+'" data-v="'+esc(x[f])+'" title="'+esc(x[f])+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsInfo('+i+',\''+f+'\',this)">'; };
    return '<tr><td><input type="checkbox" class="lchk" data-i="'+i+'"></td>'
      +'<td><input type="date" value="'+d10(x.dlvDt)+'" data-v="'+d10(x.dlvDt)+'" onchange="lsEdit('+i+',\'dlvDt\',this)"></td>'
      +'<td><input type="text" list="roundList" class="rnd" value="'+esc(x.dsRound||'')+'" data-v="'+esc(x.dsRound||'')+'" placeholder="10월 1차" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsInfo('+i+',\'dsRound\',this)"></td>'
      +'<td class="l">'+ti('rcvNm',150)+'</td><td class="l">'+ti('rcvAddr',300)+'</td><td>'+ti('rcvTel',116)+'</td><td>'+ti('rcvTel2',116)+'</td>'
      +'<td>'+ti('rcvItemCd',60)+'</td>'
      +'<td class="l"><span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:'상품 마스터에 없는 코드')+'</span><input type="text" list="prodList" class="cd '+(pn==null?'bad':'ok')+'" value="'+esc(x.itemCd)+'" data-v="'+esc(x.itemCd)+'" onchange="lsEdit('+i+',\'itemCd\',this)">'+(x.prodCd&&x.prodCd!==x.itemCd?'<span class="sub">주코드 '+esc(x.prodCd)+'</span>':'')+'</td>'
      +'<td class="l">'+ti('itemNm',180)+'</td>'
      +'<td class="r"><input type="text" class="num" style="width:84px" value="'+esc(fmtIn(x.qty))+'" data-v="'+esc(fmtIn(x.qty))+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsEdit('+i+',\'qty\',this)"></td>'
      +'<td class="r"><input type="text" class="num" style="width:68px" value="'+(feeNum(x)===''?'':esc(fmt(x.fee)))+'" title="택배비(엑셀 운임 칸) — 고쳐서 Enter. 그 줄만 바로 저장됩니다" data-v="'+(feeNum(x)===''?'':x.fee)+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsFee('+i+',this)">'+feeTag(lsGrpInfo[lsKey(x)])+'</td>'
      +'<td class="r"><input type="text" class="num'+(x.salePrice==null||x.salePrice===''?' bad':'')+'" style="width:74px" value="'+esc(fmtIn(x.salePrice))+'" data-v="'+esc(fmtIn(x.salePrice))+'" onkeydown="if(event.key===\'Enter\'){this.blur();}" onchange="lsEdit('+i+',\'price\',this)">'+tierTag(x.itemCd, x.qty, x.salePrice)+'</td>'
      +extCells(x, i, 'ls')
      +'<td class="l dim">'+esc(x.bizNm)+'</td>'
      +'<td class="l dim" style="max-width:220px;overflow:hidden;text-overflow:ellipsis" title="'+esc(x.remark)+'">'+esc(x.remark)+'</td>'
      +'<td class="dim">'+esc(String(x.uploadDttm||'').slice(0,16))+'<br>'+esc(x.regUser)+'</td></tr>'; }, { lead:10, mid:1, tail:3 }, 'ls');
  /* 칸 차례 : 체크·발주일자·차수·받는 사람·주소·전화 1·전화 2·제품코드·품목코드·제품명(10) | 수량 | 택배비 | 단가(1) | 공급가·부가세·판매금액 | 사업장·비고·등록(3) */
  if(!V.length) tb.innerHTML='<tr><td colspan="19" class="msg">품목코드 검색에 맞는 줄이 없습니다 — 칸을 비우면(Esc) 전부 보입니다.</td></tr>';
  lsInfoUpd();
}

/* 품목코드 검색 (2026-10-31 「품목코드 검색도 추가」) — 조회줄 #lsQ · 화면에서 거른다(서버 재조회 없음) · itemCd·prodCd·rcvItemCd·itemNm 부분일치 · 빈 값 = 전부.
     lsRender 가 안 맞는 줄은 안 그리고(색인 i 는 _ls 그대로 — 고치기·체크가 그 줄을 가리킨다) 합계·줄 수도 거른 것만 센다. */
function lsHit(x){ var q=String((document.getElementById('lsQ')||{}).value||'').trim().toLowerCase(); if(!q) return true;
  return [x.itemCd,x.prodCd,x.rcvItemCd,x.itemNm].some(function(v){ return String(v||'').toLowerCase().indexOf(q)>=0; }); }
function lsHitCnt(){ return _ls.filter(lsHit).length; }
function lsInfoUpd(){ var q=0, amt=0, vat=0, fee=0, V=_ls.filter(lsHit); V.forEach(function(x){ var c=dsCalc(x,'ls'); q+=n(x.qty)*c.sign; amt+=c.sup*c.sign; vat+=c.vat*c.sign; fee+=n(x.fee); });
  document.getElementById('lsInfo').textContent=V.length+'줄'+(V.length<_ls.length?' / '+_ls.length:'')+' · 수량 '+fmt(q)+' · 공급가 '+fmt(amt)+' · 부가세 '+fmt(vat)+' · 판매금액 '+fmt(amt+vat)+'원 · 택배비 '+fmt(fee)+'원(부가세 포함 '+fmt(feeTot(fee))+') · 택배 포함 '+fmt(amt+vat+feeTot(fee))+'원'; }
/* 저장 목록의 글자 칸(받는 사람·주소·전화 1·2·제품코드·제품명) — 고치면 그 줄만 바로 저장한다(/shipout/daesangPoInfo.do).
     매출·재고와 무관한 칸이라 확인창 없이 저장하고 알림만 띄운다. 실패하면 옛 값으로 되돌린다. 바꾸지 않은 칸은 지금 값을 그대로 보낸다 */
function lsInfo(i, fld, el){
  var x=_ls[i]; if(!x) return; var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/\s+/g,' ').trim();
  var back=function(){ el.value=old; };
  if(fld==='dsVatAmt'){ v=(vatIsAuto(v)?'':(v===''?'0':v)); }   /* 비우면 0 · 「자동」·↺ 이면 자동('') (2026-10-27) */
  if(v===old){ back(); return; }
  if(fld==='itemNm' && !v){ back(); err('제품명은 비울 수 없습니다.'); return; }
  if(fld==='dsDcAmt'){ v=v.replace(/,/g,''); if(v!=='' && !/^\d+$/.test(v)){ back(); err('DC 는 숫자로 넣으세요(비우면 0).'); return; } }
  if(fld==='dsVatAmt'){ v=v.replace(/,/g,'').replace(/^-/,''); if(v!=='' && !/^\d+$/.test(v)){ back(); err('부가세는 숫자로 넣으세요(비우면 0 · 「자동」이면 10%).'); return; } if(v!=='' && n(v)===dsCalc(Object.assign({},x,{dsVatAmt:''}),'ls').vat) v='';   /* 자동값과 같으면 자동으로 */ }
  if(fld==='dsRound') v=dsName(v);
  var oldKey=lsKey(x);
  var b={ seq:x.seq, rcvNm:x.rcvNm||'', rcvAddr:x.rcvAddr||'', rcvTel:x.rcvTel||'', rcvTel2:x.rcvTel2||'', rcvItemCd:x.rcvItemCd||'', itemNm:x.itemNm||'', dsRound:x.dsRound||'',
          dsMemo:x.dsMemo||'', dsDcAmt:(x.dsDcAmt==null?'':String(x.dsDcAmt)), dsZeroYn:x.dsZeroYn||'N', dsVatAmt:(x.dsVatAmt==null?'':String(x.dsVatAmt)) }; b[fld]=v;   /* DC·영세·비고·부가세도 제자리 (2026-10-27) */
  post('/shipout/daesangPoInfo.do', b, true).then(pj)
    .then(function(j){ if(j.error){ back(); err(esc(j.error)); return; }
      x[fld]=v; if(el.setAttribute){ el.value=v; el.setAttribute('data-v', v); el.title=v; }
      if(fld==='dsVatAmt'){ x[fld]=(v===''?null:v); lsRender(); if(window._toast) _toast(v===''?'부가세를 자동(10%)으로 되돌렸습니다':(v==='0'?'부가세 0 으로 저장했습니다':'부가세를 저장했습니다'),'ok'); return; }
      if(fld==='dsDcAmt' || fld==='dsZeroYn'){ lsFeeSync([lsKey(x)], false).then(function(){ lsRender(); }); if(window._toast) _toast('저장했습니다','ok'); return; }   /* 공급가가 바뀌면 그 받는 사람 택배비·합계 다시 */
      if(fld==='itemNm' && x.itemCd) _map[v]=x.itemCd;   /* 고친 제품명도 다음 붙여넣기의 자동 매칭에 쓴다 */
      if(fld==='dsRound' || fld==='rcvNm' || fld==='rcvAddr'){   /* 받는 사람 묶음이 바뀌었다 — 옛 묶음·새 묶음의 택배비를 다시 (2026-10-27) */
        lsFeeSync([oldKey, lsKey(x)], false).then(function(r){ lsRender(); if(window._toast) _toast('저장했습니다'+(r.cnt?' — 택배비 '+r.cnt+'줄 다시 계산':''),'ok'); });
        if(fld==='dsRound'){ _roundTouched=false; loadDsMap(); }
        return; }
      if(window._toast) _toast('저장했습니다','ok'); })
    .catch(function(e){ back(); err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}
/* 영세 체크(저장 목록) — lsInfo 로 넘긴다(되돌릴 땐 체크를 원복) (2026-10-27) */
function lsZero(i, cb){ var old=cb.checked?'N':'Y'; lsInfo(i, 'dsZeroYn', { value:cb.checked?'Y':'N', getAttribute:function(){ return old; }, set value(v){ cb.checked=(v==='Y'); }, get value(){ return cb.checked?'Y':'N'; } }); }
/* 저장 목록의 택배비 — 고치면 그 줄만 바로 저장한다(/shipout/daesangPoFee.do). 매출·재고와 무관한 값이라 확인창 없이 저장하고 알림만 띄운다. 실패하면 옛 값으로 되돌린다 */
function lsFee(i, el){
  var x=_ls[i]; if(!x) return; var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/,/g,'').trim();
  var back=function(){ el.value=(old===''?'':fmt(old)); };
  if(v!=='' && !/^\d+$/.test(v)){ back(); err('택배비는 숫자로 넣으세요(비우면 빈 칸).'); return; }
  if(v===old){ back(); return; }
  post('/shipout/daesangPoFee.do',{ seq:x.seq, fee:v },true).then(pj)
    .then(function(j){ if(j.error){ back(); err(esc(j.error)); return; }
      x.fee=(v===''?'':n(v)); x.rcvFee=(v===''?null:n(v)); el.setAttribute('data-v', v); el.value=(v===''?'':fmt(v)); lsInfoUpd();
      if(window._toast) _toast('택배비를 저장했습니다','ok'); })
    .catch(function(e){ back(); err('택배비를 저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}
/* 저장된 한 줄 고치기 — 발주일자·품목코드·수량·단가. 바꾼 칸만 새 값, 다른 칸은 지금 값 그대로 보낸다(서버가 옛 줄을 이력으로 닫고 새 줄을 넣는다) */
function lsEdit(i, fld, el){
  var x=_ls[i]; if(!x) return;
  var old=el.getAttribute('data-v')||'', v=String(el.value||'').replace(/,/g,'').trim(), back=function(){ el.value=old; };
  if(fld==='itemCd') v=pickCd(el.value);
  if(v===old){ back(); return; }
  if(fld==='dlvDt' && !v){ back(); return; }
  if(fld==='qty' && !(/^\d+$/.test(v) && +v>=1)){ back(); err('수량은 1 이상의 정수로 넣으세요.<br><span style="font-size:13px">이 줄을 취소하려면 체크하고 [선택 삭제(저장 취소)]를 누르세요.</span>'); return; }
  if(fld==='price' && v!=='' && !(/^\d+(\.\d+)?$/.test(v))){ back(); err('단가는 숫자로 넣으세요.'); return; }
  if(fld==='dsSvcQty' && v!=='' && !/^\d+$/.test(v)){ back(); err('서비스 수량은 0 이상의 정수로 넣으세요(비우면 0).'); return; }
  if(fld==='dsTrxGb' && v!=='판매' && v!=='반품'){ back(); return; }
  if(fld==='itemCd' && (!v || _prod[v]==null)){ back(); err('품목코드 <b>'+esc(v)+'</b> 는 마스터에 없습니다 — 상품코드등록·매칭코드에 먼저 등록하세요.'); return; }
  var b={ seq:x.seq, dlvDt:(fld==='dlvDt'?v:d10(x.dlvDt)), itemCd:(fld==='itemCd'?v:x.itemCd), qty:(fld==='qty'?v:fmtIn(x.qty)), price:(fld==='price'?v:fmtIn(x.salePrice)),
          dsSvcQty:(fld==='dsSvcQty'?(v===''?'0':v):fmtIn(x.dsSvcQty||0)), dsTrxGb:(fld==='dsTrxGb'?v:(x.dsTrxGb||'판매')) };   /* 서비스·거래구분은 재고에 닿아 이력 남는 길 (2026-10-27) */
  var lab={ dlvDt:'발주일자', itemCd:'품목코드', qty:'수량', price:'단가', dsSvcQty:'서비스', dsTrxGb:'거래구분' }[fld];
  /* ★바로 수정에도 단가표 (2026-10-27 사용자 「바로 수정 시도 적용되게」) — 수량·품목코드를 고치면, 지금 단가가 «자동 값»(단가표·판매가 그대로)일 때만
       새 수량·코드의 단가표 값으로 같이 바꾼다. 손으로 넣은 단가는 그대로 둔다. 단가 칸을 비우면 단가표 값으로 */
  var autoP='', oldAuto=Math.abs(n(x.salePrice)-priceOf(x.itemCd, x.qty))<0.0001 || x.salePrice==null || x.salePrice==='';
  if((fld==='qty' || fld==='itemCd') && oldAuto){ var np=priceOf(b.itemCd, b.qty); if(np>0 && Math.abs(np-n(x.salePrice))>0.0001){ b.price=fmtIn(np); autoP=np; } }
  if(fld==='price' && v===''){ var ep=priceOf(b.itemCd, b.qty); if(ep>0){ b.price=fmtIn(ep); autoP=ep; } }
  var keys=[lsKey(x)]; if(fld==='dlvDt') keys.push(v+'|'+dsName(x.dsRound)+'|'+dsName(x.rcvNm));
  _confirmBox({ icon:'✏️', okText:'고치기',
    msg:esc(x.rcvNm||'')+' · '+esc(x.itemNm)+'<br>'+lab+' <b>'+esc(old||'없음')+'</b> → <b>'+esc(v||'없음')+'</b>'+(fld==='itemCd'?' ('+esc(_prod[v])+')':'')
      +(autoP!==''?'<br>단가 <b>'+esc(fmtIn(x.salePrice)||'없음')+'</b> → <b>'+fmt(autoP)+'</b> <span style="font-size:12.5px;color:#137a6c">(대상 단가표 · '+(dsTier(b.itemCd)&&tierUnder(dsTier(b.itemCd), b.qty)?'미만':'기본')+')</span>':'')
      +'<br><span style="font-size:13px;color:#3d4d5c">매출 '+fmt(n(b.qty)*n(b.price))+'원'+(fld==='price'?'':' · 재고를 다시 맞춥니다')+'. 비고에 수정 기록이 남습니다.</span>',
    onOk:function(){
      post('/shipout/daesangPoRow.do', b, true).then(pj)
        .then(function(j){ if(j.error){ back(); err(esc(j.error)); return; }
          if(fld==='itemCd' && x.itemNm) _map[x.itemNm]=v;
          load(function(){ lsFeeSync(keys, false).then(function(r){ if(r.cnt) lsRender();   /* 금액이 바뀌었으니 그 받는 사람의 택배비를 다시 */
            if(j.warn) err('고쳤지만 재고 반영에 실패했습니다 — '+esc(j.warn)); else if(window._toast) _toast('고쳤습니다'+(r.cnt?' — 택배비 '+r.cnt+'줄 다시 계산':'')+(r.skip?' (손으로 넣은 택배비 '+r.skip+'곳은 그대로)':''),'ok'); }); }); })
        .catch(function(e){ back(); err('고치지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
    }, onCancel:back });
}
/* ═══ 저장 목록의 택배비 맞추기 (2026-10-27) — 받는 사람(같은 발주일자·차수·이름)마다 첫 줄 = 규칙 값, 나머지 = 0.
     force 가 아니면 «손으로 넣은 것 같은» 묶음(합이 0·4,000·제주 값이 아닌 것 — 예 3 × 4,000)은 건드리지 않는다. 바뀌는 줄만 /shipout/daesangPoFee.do 로 하나씩 */
function lsKey(x){ var nm=dsName(x.rcvNm); return nm ? (d10(x.dlvDt)+'|'+dsName(x.dsRound)+'|'+nm) : ('#'+x.seq); }
function lsFeeSync(keys, force){
  var g={}; _ls.forEach(function(x){ var k=lsKey(x); if(keys && keys.indexOf(k)<0) return; (g[k]=g[k]||[]).push(x); });
  var jobs=[], skip=0;
  Object.keys(g).forEach(function(k){ var l=g[k].slice().sort(function(a,b){ return n(a.seq)-n(b.seq); });
    var cur=0, blank=true; l.forEach(function(x){ if(feeNum(x)!==''){ blank=false; cur+=n(x.fee); } });
    if(!force && !blank && !feeAutoSum(cur)){ skip++; return; }
    var amt=0, jj=false; l.forEach(function(x){ var c=dsCalc(x,'ls'); amt+=c.sup*c.sign; if(isJeju(x.rcvAddr)) jj=true; });
    var w=feeWant(amt, jj);
    l.forEach(function(x, i){ var v=(i===0 ? w : 0); if(feeNum(x)==='' || n(x.fee)!==v) jobs.push({ x:x, v:v }); }); });
  var done=0, fail=0;
  return jobs.reduce(function(p, jb){ return p.then(function(){ return post('/shipout/daesangPoFee.do',{ seq:jb.x.seq, fee:String(jb.v) },true).then(pj)
      .then(function(j){ if(j.error){ fail++; return; } jb.x.fee=jb.v; jb.x.rcvFee=jb.v; done++; }).catch(function(){ fail++; }); }); }, Promise.resolve())
    .then(function(){ if(fail) err('택배비 '+fail+'줄을 저장하지 못했습니다 — [조회] 뒤 다시 해 보세요.'); return { cnt:done, skip:skip, fail:fail }; });
}
function lsFeeAll(){
  if(!_ls.length){ err('조회된 줄이 없습니다.'); return; }
  var pick=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) pick.push(x); });
  var rows=pick.length?pick:_ls, keys=[]; rows.forEach(function(x){ var k=lsKey(x); if(keys.indexOf(k)<0) keys.push(k); });
  _confirmBox({ icon:'🚚', okText:'다시 계산',
    msg:(pick.length?'체크한 줄':'조회된 줄 전부')+'의 받는 사람 <b>'+keys.length+'</b>곳 택배비를 규칙대로 다시 넣습니다.<br><span style="font-size:13px;color:#3d4d5c">받는 사람 합계(부가세 별도)가 3만 원부터 0원 · 미만이면 4,000원(첫 줄에 한 번)'+(DS_JEJU?' · 제주 '+fmt(DS_JEJU)+'원 추가':'')+'.<br><b style="color:#b45309">손으로 넣은 택배비(예 3 × 4,000)도 규칙 값으로 바뀝니다.</b></span>',
    onOk:function(){ lsFeeSync(keys, true).then(function(r){ lsRender();
      /* 택배비(로젠) 매출 줄도 조회 기간 전체를 다시 만든다 (2026-10-27 「택배비는 로젠 한 줄로」) — 아무 줄도 안 바뀐 날(옛 저장분)에도 줄이 생긴다 */
      return post('/shipout/daesangFeeSync.do',{ frDt:document.getElementById('fr').value, toDt:document.getElementById('to').value },true).then(pj)
        .then(function(j){ if(j.error){ err(esc(j.error)); return; } if(j.warn) err('택배비 줄은 만들었지만 재고 반영에 실패했습니다 — '+esc(j.warn));
          if(window._toast) _toast('택배비 '+r.cnt+'줄 다시 넣음 · 택배비(로젠) 매출 줄 '+(j.cnt||0)+'건('+(j.days||0)+'일)','ok'); })
        .catch(function(e){ err('택배비(로젠) 매출 줄을 만들지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }); }, onCancel:function(){} });
}

/* 저장 목록 — 차수 일괄 넣기 (2026-10-27 「차수 안 찍힘」 : 이 기능 전에 저장된 줄은 차수가 비어 마감 엑셀 일자 칸에 날짜만 찍혔다). 위 차수 칸의 값을 체크한 줄(없으면 전부)에 — 줄마다 daesangPoInfo */
function lsRoundAll(){
  var rd=dsName(document.getElementById('roundLs').value); if(!rd){ err('단추 왼쪽 칸에 넣을 차수를 적으세요 — 예) 10월 1차'); document.getElementById('roundLs').focus(); return; }
  if(!_ls.length){ err('조회된 줄이 없습니다.'); return; }
  var pick=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x) pick.push(x); });
  if(!pick.length){ err('차수를 넣을 줄을 먼저 <b>체크</b>하세요.<br><span style="font-size:13px">맨 왼쪽 체크칸 — 전부면 머리줄의 체크칸.</span>'); return; }   /* 체크한 줄에만 (2026-10-27 사용자 「체크하고 차수 일괄 적용하게」) */
  var rows=pick.filter(function(x){ return dsName(x.dsRound)!==rd; });
  if(!rows.length){ if(window._toast) _toast('체크한 줄은 이미 모두 '+rd+' 입니다','info'); return; }
  _confirmBox({ icon:'📌', okText:'넣기', msg:'체크한 '+pick.length+'줄 가운데 <b>'+rows.length+'</b>줄의 차수를 <b>'+esc(rd)+'</b> 로 넣습니다.<br><span style="font-size:13px;color:#3d4d5c">마감 엑셀의 일자 칸에 날짜와 함께 찍힙니다. 받는 사람 택배비도 차수 묶음으로 다시 맞춥니다.</span>',
    onOk:function(){ var done=0, fail=0, keys=[];
      return rows.reduce(function(p,x){ return p.then(function(){ keys.push(lsKey(x));
        return post('/shipout/daesangPoInfo.do',{ seq:x.seq, rcvNm:x.rcvNm||'', rcvAddr:x.rcvAddr||'', rcvTel:x.rcvTel||'', rcvTel2:x.rcvTel2||'', rcvItemCd:x.rcvItemCd||'', itemNm:x.itemNm||'', dsRound:rd },true).then(pj)
          .then(function(j){ if(j.error){ fail++; return; } x.dsRound=rd; keys.push(lsKey(x)); done++; }).catch(function(){ fail++; }); }); }, Promise.resolve())
      .then(function(){ return lsFeeSync(keys, false); })
      .then(function(){ lsRender(); _roundTouched=false; loadDsMap();
        if(fail) err('차수 '+fail+'줄을 저장하지 못했습니다 — [조회] 뒤 다시 해 보세요.'); else if(window._toast) _toast('차수 '+rd+' 를 '+done+'줄에 넣었습니다','ok'); }); },
    onCancel:function(){} });
}

/* ═══ 마감 엑셀(대상 송부용) — 「대상급식 마감.xlsx」 월 시트와 같은 모양 (2026-10-27 「나중에 해당 자료 보내 주어야 함 — 엑셀 일자에 10월 1차」) ═══
   맨 위 [매출장] · 조회기간 · VAT 별도 · 오른쪽 위 = 택배비 건수(I1)·합계(J1) (사용자 「표시 제거하지 말아주세요」 — 그대로 둠) / 칸 = 일자 · 출고점 · 상품명 · 규격 · 수량 · 단가 · 금액
   · 일자 칸 = 「2026-09-28 10월 1차」 — 같은 차수의 줄은 위아래로 합친다. 출고점 칸 = 받는 사람 — 그 사람의 줄(택배비 줄 포함)을 합친다.
   · 상품명·규격 = 우리 상품코드의 이름·규격(대상 제품명이 아니다 — 실제 마감 엑셀이 그렇다). 매칭코드면 그 주코드의 것.
   · 받는 사람마다 택배비가 있으면 그 사람 줄 밑에 「택배비(로젠) 수량 × 4,000」 한 줄(4,000 의 배수면 수량으로 — 3 × 4,000 = 12,000). 판매금액 = 택배비 × 1.1(부가세 10% · 2026-10-27).
   · 금액 = 수량 × 단가(엑셀 식) · 맨 아래 합 계(식). 범위 = 지금 조회한 기간의 줄 전부(체크와 무관). */
function dsCloseXls(){
  if(!window.XLSX){ err('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  if(!_ls.length){ err('조회된 줄이 없습니다 — 마감 기간을 고르고 [🔍 조회] 하세요.'); return; }
  var rk=function(v){ var p=roundParse(v); return p ? p.m*1000+p.k : 0; };
  var rows=_ls.slice().sort(function(a,b){ return String(a.dlvDt).localeCompare(String(b.dlvDt)) || (rk(a.dsRound)-rk(b.dsRound)) || String(a.ordNo).localeCompare(String(b.ordNo)) || (n(a.lineNo)-n(b.lineNo)) || (n(a.seq)-n(b.seq)); });
  /* 차수 묶음 → 그 안에서 받는 사람(처음 나온 차례) 묶음 */
  var rounds=[], rIdx={};
  rows.forEach(function(x){ var rkey=String(x.dlvDt)+'|'+dsName(x.dsRound); var R=rIdx[rkey];
    if(!R){ R={ dt:d10(x.dlvDt), rd:dsName(x.dsRound), people:[], pIdx:{} }; rIdx[rkey]=R; rounds.push(R); }
    var pk=dsName(x.rcvNm)||('#'+x.seq), P=R.pIdx[pk]; if(!P){ P={ nm:dsName(x.rcvNm), rows:[], fee:0 }; R.pIdx[pk]=P; R.people.push(P); }
    P.rows.push(x); P.fee+=n(x.fee); });
  var noRnd=rows.filter(function(x){ return !dsName(x.dsRound); }).length;
  var nmOf=function(cd, fb){ var m=_main[cd]; var v=prodNmOf(cd)||(m?prodNmOf(m):''); return v||fb||''; };
  var spOf=function(cd){ return _spec[cd]||(_main[cd]?(_spec[_main[cd]]||''):''); };
  var aoa=[], merges=[], FEE_NM='택배비(로젠)', feeQty=0, feeSum=0;
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  aoa.push(['[매출장]','','','','','','','','','']); aoa.push(['조회기간 : '+(fr||rows[0].dlvDt)+' ~ '+(to||rows[rows.length-1].dlvDt),'','','','','','VAT 별도']);   /* 금액 = 공급가(수량×단가 − DC · 반품 음수 · 부가세 안 더함) — 2026-10-28 사용자 「마감엑셀에 부가세 미포함으로」 (10-27 밤 「판매금액(VAT 포함)」을 뒤집음 · 화면 합계 줄의 판매금액·택배 포함은 그대로) */
  aoa.push(['일자','출고점','상품명','규격','수량','단가','공급가액']);
  merges.push({ s:{r:0,c:0}, e:{r:0,c:6} }, { s:{r:1,c:0}, e:{r:1,c:3} });
  rounds.forEach(function(R){ var r0=aoa.length;
    R.people.forEach(function(P){ var p0=aoa.length;
      P.rows.forEach(function(x){ aoa.push(['', '', nmOf(x.itemCd, x.itemNm), spOf(x.itemCd), n(x.qty)*(x.dsTrxGb==='반품'?-1:1), (x.salePrice==null||x.salePrice==='')?'':n(x.salePrice), (function(c){ return c.sup*c.sign; })(dsCalc(x,'ls'))]); });   /* 반품은 수량 음수 · 공급가도 음수 (2026-10-27) · 부가세 미포함 (2026-10-28) */
      if(P.fee>0){ var fq=(P.fee%DS_FEE===0)?P.fee/DS_FEE:1, fu=(P.fee%DS_FEE===0)?DS_FEE:P.fee; aoa.push(['', '', FEE_NM, '', fq, fu, P.fee]); feeQty+=fq; feeSum+=P.fee; }   /* 택배비 줄 금액 = 택배비 그대로(부가세 별도 · 2026-10-28 — 10-27 밤 ×1.1 을 뒤집음) */
      aoa[p0][1]=P.nm; if(aoa.length-1>p0) merges.push({ s:{r:p0,c:1}, e:{r:aoa.length-1,c:1} }); });
    aoa[r0][0]=R.dt+(R.rd?' '+R.rd:''); if(aoa.length-1>r0) merges.push({ s:{r:r0,c:0}, e:{r:aoa.length-1,c:0} }); });
  var last=aoa.length;   /* 엑셀 줄 번호(1부터) = 마지막 자료 줄 */
  aoa.push(['합 계','','','','',null,null]); merges.push({ s:{r:last,c:0}, e:{r:last,c:1} });
  aoa[0][8]=feeQty+'건'; aoa[0][9]=feeSum;   /* 택배비 합계 = 부가세 별도(G 열과 같은 기준 · 2026-10-28) */
  var ws=XLSX.utils.aoa_to_sheet(aoa);
  var L={ style:'thin', color:{ rgb:'000000' } }, BX={ top:L, bottom:L, left:L, right:L };
  var st=function(ref, s){ if(!ws[ref]) ws[ref]={ t:'s', v:'' }; ws[ref].s=s; };
  var C={ alignment:{ vertical:'center', wrapText:true }, border:BX, font:{ name:'맑은 고딕', sz:10 } };
  var CC={ alignment:{ horizontal:'center', vertical:'center', wrapText:true }, border:BX, font:{ name:'맑은 고딕', sz:10 } };
  var NI={ alignment:{ horizontal:'right', vertical:'center' }, border:BX, numFmt:'#,##0', font:{ name:'맑은 고딕', sz:10 } };
  var ND={ alignment:{ horizontal:'right', vertical:'center' }, border:BX, numFmt:'#,##0.0#', font:{ name:'맑은 고딕', sz:10 } };
  var HD={ alignment:{ horizontal:'center', vertical:'center' }, border:BX, fill:{ fgColor:{ rgb:'DDEBF7' } }, font:{ name:'맑은 고딕', sz:10, bold:true } };
  var TT={ alignment:{ horizontal:'center', vertical:'center' }, border:BX, fill:{ fgColor:{ rgb:'FCF8E3' } }, font:{ name:'맑은 고딕', sz:10, bold:true } };
  ws['A1'].s={ alignment:{ horizontal:'center', vertical:'center' }, font:{ name:'맑은 고딕', sz:14, bold:true } };   /* 제목 가운데 (사용자 「매출장 가운데로」 — A1:G1 병합 위에서) */
  ws['A2'].s={ font:{ name:'맑은 고딕', sz:10 } }; ws['G2'].s={ alignment:{ horizontal:'right' }, font:{ name:'맑은 고딕', sz:10 } };
  ws['I1'].s={ font:{ name:'맑은 고딕', sz:10, bold:true } }; ws['J1'].s={ numFmt:'#,##0', font:{ name:'맑은 고딕', sz:10, bold:true } };
  for(var c=0;c<7;c++) st(XLSX.utils.encode_cell({ r:2, c:c }), HD);
  for(var r=3;r<last;r++){ var R1=r+1;
    st('A'+R1, CC); st('B'+R1, CC); st('C'+R1, C); st('D'+R1, C);
    st('E'+R1, NI); var fv=aoa[r][5]; st('F'+R1, (typeof fv==='number' && Math.round(fv)!==fv) ? ND : NI);
    ws['G'+R1]={ t:'n', v:n(aoa[r][6]), s:NI }; }   /* 값으로(식 아님) — 수량×단가에 DC·부가세가 더해져 식으로는 못 적는다 */
  var T=last+1, sumE=0, sumG=0; for(var r2=3;r2<last;r2++){ if(typeof aoa[r2][4]==='number') sumE+=aoa[r2][4]; if(ws['G'+(r2+1)]) sumG+=ws['G'+(r2+1)].v; }
  ['A','B','C','D','F'].forEach(function(cl){ st(cl+T, TT); });
  ws['E'+T]={ t:'n', v:sumE, f:'SUM(E4:E'+last+')', s:Object.assign({}, NI, { fill:TT.fill, font:TT.font }) };
  ws['G'+T]={ t:'n', v:sumG, f:'SUM(G4:G'+last+')', s:Object.assign({}, NI, { fill:TT.fill, font:TT.font }) };
  ws['!merges']=merges;
  ws['!cols']=[{ wch:20 },{ wch:25 },{ wch:42 },{ wch:21 },{ wch:8 },{ wch:9 },{ wch:11 },{ wch:2 },{ wch:6 },{ wch:9 }];
  /* 시트 이름 = 마감월 YYYYMM — 차수의 월(가장 많이 나온 것), 차수가 없으면 마지막 발주일자의 월. 차수 월이 날짜 월보다 앞이면(1월 차수에 12월 날짜) 해를 넘긴다 */
  var cnt={}; rows.forEach(function(x){ var p=roundParse(x.dsRound); if(p) cnt[p.m]=(cnt[p.m]||0)+1; });
  var lastDt=String(rows[rows.length-1].dlvDt), yy=+lastDt.slice(0,4), mm=+lastDt.slice(4,6), best=0;
  Object.keys(cnt).forEach(function(k){ if(cnt[k]>best){ best=cnt[k]; mm=+k; } });
  if(mm<+lastDt.slice(4,6)-6) yy++;
  var sheet=yy+('0'+mm).slice(-2);
  var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, sheet);
  XLSX.writeFile(wb, '대상급식_마감_'+sheet+'.xlsx');
  if(window._toast) _toast('📑 마감 엑셀 — '+sheet+' · '+rows.length+'줄 · 택배비 '+feeQty+'건 '+fmt(feeSum)+'원(부가세 별도)','ok');
  if(noRnd) err('차수가 빈 줄 <b>'+noRnd+'</b>개는 일자 칸에 날짜만 찍혔습니다.<br><span style="font-size:13px">목록의 「차수」 칸에 넣고 다시 만들면 됩니다.</span>');
}

/* ═══ 이력 · 복구 (2026-10-27 사용자 「이력조회 및 복구기능」) ═══
   /shipout/daesangPoHist.do(조회 기간의 N·D 줄, 최근 닫힌 것 먼저) · /shipout/daesangPoRestore.do({seq}).
   수정 전(N) 줄의 [복구] = 그 묶음(ORD_NO+줄번호)의 지금 살아 있는 줄(liveSeq)을 닫고 옛 값으로 — 확인창에 「지금 → 되돌릴 값」을 적는다. 삭제(D) 줄의 [복구] = 그냥 되살림.
   복구 뒤 저장 목록을 다시 읽고 그 받는 사람의 택배비를 다시 맞춘다 */
var _dh=[];
/* ── ⚠ 중복 점검 (2026-10-31 사용자 「오류 사용자 수정할 수 있게」) — 판매전표 ↔ 대상 발주 겹침 · 대상 발주 안 겹침을 보여 주고 지운다. 서버 무변경 ── */
var _dk={ trx:[], dup:[] };
function dkOpen(){ document.getElementById('dkMask').classList.add('on'); dkLoad(); }
function dkClose(){ document.getElementById('dkMask').classList.remove('on'); }
function dkAll(id, el){ Array.prototype.forEach.call(document.querySelectorAll('#'+id+' input.dkc'), function(c){ c.checked=el.checked; }); }
function dkLoad(){
  var fr=document.getElementById('fr').value, to=document.getElementById('to').value;
  document.getElementById('dkSub').textContent='— '+fr+' ~ '+to+' (저장 목록의 조회 기간 · 기간을 바꾸려면 목록에서 [🔍 조회])';
  document.getElementById('dkTrx').innerHTML='<tr><td colspan="7" class="msg">읽는 중…</td></tr>';
  document.getElementById('dkDup').innerHTML='<tr><td colspan="8" class="msg">읽는 중…</td></tr>';
  /* 대상 거래처 = 거래처관리에서 물류센터코드 DAESANG 인 곳 + 이름이 「대상」으로 시작하는 곳(00177 대상 급식은 DC_CD 가 비어 있다 — selectStockOutDetail 과 같은 규칙) */
  var pV=post('/vendor/selectVendorMst.do','').then(pj).then(function(j){ var s={}; ((j&&j.data)||[]).forEach(function(v){ if(String(v.dcCd||'')==='DAESANG') s[String(v.vendorCd)]=1; }); return s; }).catch(function(){ return {}; });
  var pT=post('/mangr/salesTrxList.do','fromDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)).then(pj).then(function(j){ return (j&&j.data)||[]; }).catch(function(){ return null; });
  Promise.all([pV,pT]).then(function(a){ var vs=a[0], trx=a[1];
    if(trx===null){ _dk.trx=[]; document.getElementById('dkTrx').innerHTML='<tr><td colspan="7" class="msg" style="color:#c0392b">판매전표를 읽지 못했습니다</td></tr>'; }
    else { _dk.trx=trx.filter(function(m){ return vs[String(m.custCd||'')] || /^대상/.test(String(m.custNm||'').trim()); }); dkRenderTrx(); }
    dkRenderDup();
  });
}
/* 같은 발주일자의 대상 발주(지금 목록) — 줄 수 · 공급가 합 */
function dkSameDay(ymd){ var n0=0, sup=0; _ls.forEach(function(x){ if(d10(x.dlvDt)===ymd){ n0++; var c=dsCalc(x,'ls'); sup+=c.sup*c.sign; } }); return { n:n0, sup:sup }; }
function dkRenderTrx(){
  var tb=document.getElementById('dkTrx');
  if(!_dk.trx.length){ tb.innerHTML='<tr><td colspan="7" class="msg">이 기간에 대상 거래처로 넣은 판매전표가 없습니다.</td></tr>'; return; }
  tb.innerHTML=_dk.trx.map(function(m,i){ var d=d10(m.saleDt), s=dkSameDay(d);
    return '<tr><td><input type="checkbox" class="dkc" data-i="'+i+'"></td><td>'+esc(d)+'</td><td>'+esc(m.saleNo||'')+'</td><td class="l">'+esc(m.custNm||'')+' <span class="dim">'+esc(m.custCd||'')+'</span></td>'
      +'<td class="r">'+fmt(m.prodCnt)+'</td><td class="r">'+fmt(m.totAmt)+'</td>'
      +'<td class="r">'+(s.n ? ('<b>'+s.n+'</b>줄 · 공급가 '+fmt(s.sup)+' <span style="color:#c0392b;font-weight:800">겹침</span>') : '<span class="dim">없음</span>')+'</td></tr>'; }).join('');
}
function dkRenderDup(){
  var tb=document.getElementById('dkDup'), g={}, ord=[];
  _ls.forEach(function(x){ var k=d10(x.dlvDt)+'|'+dsName(x.rcvNm)+'|'+String(x.itemCd||''); if(!g[k]){ g[k]=[]; ord.push(k); } g[k].push(x); });
  var dup=[]; ord.forEach(function(k){ if(g[k].length>1) dup.push(k); });
  _dk.dup=dup.map(function(k){ return g[k]; });
  if(!dup.length){ tb.innerHTML='<tr><td colspan="8" class="msg">같은 날·같은 받는 사람·같은 품목이 두 번 들어간 줄이 없습니다.</td></tr>'; return; }
  var h=[];
  _dk.dup.forEach(function(rows, gi){
    h.push('<tr class="sum"><td colspan="8" style="text-align:left">'+esc(d10(rows[0].dlvDt))+' · '+esc(dsName(rows[0].rcvNm))+' · '+esc(rows[0].itemCd)+' '+esc(_prod[rows[0].itemCd]||rows[0].itemNm||'')+' — <b>'+rows.length+'</b>줄 겹침 (남길 줄 하나를 빼고 체크)</td></tr>');
    rows.forEach(function(x){ h.push('<tr><td><input type="checkbox" class="dkc" data-seq="'+esc(x.seq)+'"></td><td>'+esc(d10(x.dlvDt))+'</td><td>'+esc(x.dsRound||'')+'</td><td class="l">'+esc(x.rcvNm)+'</td><td class="l">'+esc(x.itemCd)+' '+esc(x.itemNm||'')+'</td>'
      +'<td class="r">'+fmt(x.qty)+'</td><td class="r">'+fmt(x.salePrice)+'</td><td class="dim">'+esc(String(x.uploadDttm||'').slice(0,16))+' '+esc(x.regUser||'')+'</td></tr>'); });
  });
  tb.innerHTML=h.join('');
}
/* 판매전표 삭제 = 판매등록의 [✖ 삭제하기]와 같은 길(/mangr/salesTrxDelete.do · 전표 원장도 그 서비스가 거둔다). 한 장씩 차례로 */
function dkDelTrx(){
  var pick=[]; Array.prototype.forEach.call(document.querySelectorAll('#dkTrx input.dkc:checked'), function(c){ var m=_dk.trx[+c.getAttribute('data-i')]; if(m) pick.push(m); });
  if(!pick.length){ err('지울 판매전표를 체크하세요.'); return; }
  var amt=0; pick.forEach(function(m){ amt+=n(m.totAmt); });
  _confirmBox({ icon:'🗑', okText:'전표 삭제', okColor:'#c0392b',
    msg:'대상 판매전표 <b>'+pick.length+'</b>장(판매금액 '+fmt(amt)+'원)을 삭제합니다.<br><span style="font-size:13px;color:#3d4d5c">판매등록에서 지우는 것과 같습니다 — 매출·채권·재고 원장에서 빠집니다. 대상 발주 등록 줄은 그대로 남습니다.</span>',
    onOk:function(){
      var done=0, fail=[];
      (function next(i){
        if(i>=pick.length){ dkLoad(); ok('판매전표 <b>'+done+'</b>장을 지웠습니다.'+(fail.length?'<br><span style="color:#c0392b;font-size:13px">실패 '+fail.length+'장 — '+esc(fail.join(' / '))+'</span>':'')+'<br><span style="font-size:13px">정리가 끝나면 [🔄 출고반영 재집계]를 한 번 눌러 주세요.</span>'); return; }
        var m=pick[i];
        post('/mangr/salesTrxDelete.do',{ saleSeq:m.saleSeq },true)
          .then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); done++; }); })
          .catch(function(e){ fail.push(d10(m.saleDt)+'-'+(m.saleNo||'')+' '+e.message); })
          .then(function(){ next(i+1); });
      })(0);
    }, onCancel:function(){} });
}
/* 대상 발주 겹친 줄 삭제 = [🗑 선택 삭제]와 같은 길(daesangPoDelete — 그 날짜 재고 원장을 다시 맞춘다) */
function dkDelDup(){
  var seqs=[], keys=[]; Array.prototype.forEach.call(document.querySelectorAll('#dkDup input.dkc:checked'), function(c){ var sq=c.getAttribute('data-seq'); if(sq){ seqs.push(+sq); _ls.forEach(function(x){ if(String(x.seq)===String(sq)) keys.push(lsKey(x)); }); } });
  if(!seqs.length){ err('지울 줄을 체크하세요.'); return; }
  _confirmBox({ icon:'🗑', okText:'삭제', okColor:'#c0392b',
    msg:'대상 발주 <b>'+seqs.length+'</b>줄을 삭제합니다.<br><span style="font-size:13px;color:#3d4d5c">출고·매출에서 빠지고 그 날 재고도 다시 맞춥니다. 이력조회에서 되살릴 수 있습니다.</span>',
    onOk:function(){ post('/shipout/daesangPoDelete.do',{ seqs:seqs },true).then(pj)
      .then(function(j){ if(j.error){ err(esc(j.error)); return; }
        load(function(){ lsFeeSync(keys, false).then(function(r){ if(r.cnt) lsRender(); dkLoad(); }); });
        ok((j.cnt||0)+'줄을 삭제했습니다.'+(j.warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(j.warn)+'</span>':'')); })
      .catch(function(e){ err('삭제하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }, onCancel:function(){} });
}
/* 출고반영 재집계 — 셸의 단추와 같은 끝점(/prod/stockRebuild.do). 전 기간이라 수십 초 */
function dkRebuild(){
  _confirmBox({ icon:'🔄', okText:'재집계',
    msg:'출고 원장을 <b>전 기간</b> 다시 만듭니다(발주현황표 → 정산서 → 발주 등록 차례). 수십 초 걸릴 수 있습니다.<br><span style="font-size:13px;color:#3d4d5c">마감 확정한 달은 건너뜁니다. 품목별재고현황 숫자가 바로잡힙니다.</span>',
    onOk:function(){ var b=document.querySelector('#dkBox .df .btn'); if(b) b.disabled=true; if(window._toast) _toast('재집계 중… 끝나면 알립니다','info');
      post('/prod/stockRebuild.do','').then(function(r){ return r.text().then(function(t){ if(!r.ok) throw new Error(t); return t; }); })
        .then(function(t){ ok('출고반영 재집계를 마쳤습니다 — '+esc(String(t).replace(/^"|"$/g,''))+'일치 처리.'); })
        .catch(function(e){ err('재집계에 실패했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); })
        .then(function(){ if(b) b.disabled=false; }); }, onCancel:function(){} });
}
function dhOpen(){
  document.getElementById('dhMask').classList.add('on');
  document.getElementById('dhFr').value=document.getElementById('fr').value; document.getElementById('dhTo').value=document.getElementById('to').value;   /* 처음 = 저장 목록의 기간 */
  dhLoad();
}
function dhLoad(){
  document.getElementById('dhBody').innerHTML='<tr><td colspan="13" class="msg">읽는 중…</td></tr>';
  var fr=document.getElementById('dhFr').value, to=document.getElementById('dhTo').value;
  document.getElementById('dhSub').textContent='';
  post('/shipout/daesangPoHist.do','frDt='+encodeURIComponent(fr)+'&toDt='+encodeURIComponent(to)).then(pj)
    .then(function(j){ if(j.error){ _dh=[]; document.getElementById('dhBody').innerHTML='<tr><td colspan="13" class="msg" style="color:#c0392b">'+esc(j.error)+'</td></tr>'; return; } _dh=(j&&j.data)||[]; dhRender(); document.getElementById('dhSub').textContent=_dh.length?(_dh.length+'줄'):''; })
    .catch(function(e){ document.getElementById('dhBody').innerHTML='<tr><td colspan="13" class="msg" style="color:#c0392b">읽지 못했습니다 — '+esc(e.message)+'</td></tr>'; });
}
function dhClose(){ document.getElementById('dhMask').classList.remove('on'); }
function dhLive(seq){ var hit=null; _ls.forEach(function(x){ if(String(x.seq)===String(seq)) hit=x; }); return hit; }
function dhRender(){
  var tb=document.getElementById('dhBody');
  if(!_dh.length){ tb.innerHTML='<tr><td colspan="13" class="msg">이 기간에 고치거나 삭제한 줄이 없습니다.</td></tr>'; return; }
  tb.innerHTML=_dh.map(function(x,i){ var isN=x.actionYn==='N', live=isN&&x.liveSeq?dhLive(x.liveSeq):null, pn=_prod[x.itemCd];
    var st=isN ? (x.liveSeq?'<span class="st N" title="고친 결과가 살아 있는 줄 SEQ '+esc(x.liveSeq)+' 입니다">수정 전</span>':'<span class="st gone" title="고친 결과도 그 뒤에 삭제되어 지금 살아 있는 줄이 없습니다">수정 전 (결과 삭제됨)</span>')
                 : '<span class="st D">삭제</span>';
    return '<tr><td>'+st+'</td><td class="dim">'+esc(x.updDttm||'')+'</td><td class="dim">'+esc(x.updUser||'')+'</td><td>'+d10(x.dlvDt)+'</td><td>'+esc(x.dsRound||'')+'</td>'
      +'<td class="l">'+esc(x.rcvNm)+'</td><td class="l" style="white-space:normal"><span class="sub nmf'+(pn==null?' warn':'')+'">'+esc(pn!=null?pn:x.itemNm)+'</span><span class="sub">'+esc(x.itemCd)+(x.itemNm&&pn!=null?' · '+esc(x.itemNm):'')+'</span></td>'
      +'<td class="r">'+fmt(x.qty)+'</td><td class="r">'+(x.salePrice==null?'':fmtIn(x.salePrice))+'</td><td class="r">'+fmt(n(x.qty)*n(x.salePrice))+'</td><td class="r">'+(x.rcvFee==null?'':fmt(x.rcvFee))+'</td>'
      +'<td class="l" style="white-space:normal;min-width:230px;max-width:300px;font-size:12px">'+dhRemark(x.remark, i)+'</td>'
      +'<td><button class="btn" style="height:28px;padding:0 10px" onclick="dhRestore('+i+')">↩ 복구</button></td></tr>'; }).join('');
}
/* 비고의 수정 기록을 한 줄씩 — 최근 것부터, 3건 넘으면 접음 (2026-10-27 「수정 한 개 많으면 보기 어려움」).
   비고 = 「대상 발주 · 수정 10-27 17:53 수량 150→10000 판매가 67→62 · 수정 … · 복구 …」 꼴 — 「· 」로 가른다 */
function dhRemark(rm, i){
  var parts=String(rm||'').split(/\s·\s(?=(?:수정|복구)\s)/).map(function(p){ return p.trim(); }).filter(Boolean);
  var base=parts.length&&!/^(수정|복구)\s/.test(parts[0]) ? parts.shift() : '';
  if(!parts.length) return '<span class="dim">'+esc(base)+'</span>';
  parts.reverse();   /* 최근 것 먼저 */
  var line=function(p){ var m=/^(수정|복구)\s(\d\d-\d\d \d\d:\d\d)\s*(.*)$/.exec(p); if(!m) return '<div>'+esc(p)+'</div>';
    var what=m[3].replace(/\s(수량|판매가|일자|품목)\s/g,' · $1 ').replace(/→/g,' → ');
    return '<div style="white-space:nowrap"><span class="dim">'+esc(m[2])+'</span> <b style="color:'+(m[1]==='복구'?'#137a6c':'#2f4f9a')+'">'+m[1]+'</b> '+esc(what)+'</div>'; };
  var h=parts.slice(0,3).map(line).join('');
  if(parts.length>3) h+='<div id="dhMore'+i+'" style="display:none">'+parts.slice(3).map(line).join('')+'</div>'
    +'<a href="javascript:;" class="dim" style="font-size:11px" data-n="'+(parts.length-3)+'" onclick="dhMoreTgl(this,'+i+')">+ '+(parts.length-3)+'건 더</a>';
  return h+'<div class="dim" style="font-size:11px">총 '+parts.length+'회'+(base?' · '+esc(base):'')+'</div>';
}
function dhMoreTgl(a, i){ var e=document.getElementById('dhMore'+i); if(!e) return; var on=e.style.display!=='none'; e.style.display=on?'none':''; a.textContent=on?('+ '+a.getAttribute('data-n')+'건 더'):'접기'; }
function dhRestore(i){
  var x=_dh[i]; if(!x) return; var isN=x.actionYn==='N', live=isN&&x.liveSeq?dhLive(x.liveSeq):null;
  var msg;
  if(isN){
    msg='<b>'+esc(x.rcvNm||'')+' · '+esc(_prod[x.itemCd]||x.itemNm)+'</b> 을(를) <b>수정 전 값</b>으로 되돌립니다.<br>'
      +(live ? '<span style="font-size:13px;color:#3d4d5c">지금 : '+d10(live.dlvDt)+' · '+esc(live.itemCd)+' · 수량 '+fmt(live.qty)+' · 단가 '+fmtIn(live.salePrice)+'<br>→ 되돌릴 값 : '+d10(x.dlvDt)+' · '+esc(x.itemCd)+' · 수량 '+fmt(x.qty)+' · 단가 '+(x.salePrice==null?'없음':fmtIn(x.salePrice))+'</span>'
             : '<span style="font-size:13px;color:#3d4d5c">되돌릴 값 : '+d10(x.dlvDt)+' · '+esc(x.itemCd)+' · 수량 '+fmt(x.qty)+' · 단가 '+(x.salePrice==null?'없음':fmtIn(x.salePrice))+(x.liveSeq?'<br>지금 살아 있는 줄(고친 결과)은 닫힙니다.':'<br>고친 결과는 이미 삭제되어 이 줄만 살아납니다.')+'</span>')
      +'<br><span style="font-size:12.5px;color:#6b7a89">두 날짜의 재고를 다시 맞춥니다. 비고에 복구 기록이 남습니다.</span>';
  } else {
    msg='삭제했던 줄을 <b>다시 살립니다</b>.<br><span style="font-size:13px;color:#3d4d5c">'+d10(x.dlvDt)+(x.dsRound?' '+esc(x.dsRound):'')+' · '+esc(x.rcvNm||'')+' · '+esc(_prod[x.itemCd]||x.itemNm)+' · 수량 '+fmt(x.qty)+' · 단가 '+(x.salePrice==null?'없음':fmtIn(x.salePrice))+'</span>'
      +'<br><span style="font-size:12.5px;color:#6b7a89">같은 표를 다시 올려 둔 상태면 같은 줄이 둘이 됩니다 — 복구 뒤 목록에서 확인하세요.</span>';
  }
  _confirmBox({ icon:'↩', okText:'복구', msg:msg,
    onOk:function(){ post('/shipout/daesangPoRestore.do',{ seq:x.seq },true).then(pj)
      .then(function(j){ if(j.error){ err(esc(j.error)); return; }
        _dh.splice(i,1); dhRender();
        var k=d10(x.dlvDt)+'|'+dsName(x.dsRound)+'|'+dsName(x.rcvNm), keys=[k]; if(live) keys.push(lsKey(live));
        load(function(){ lsFeeSync(keys, false).then(function(r){ if(r.cnt) lsRender(); }); });
        if(j.warn) err('복구했지만 재고 반영에 실패했습니다 — '+esc(j.warn)); else if(window._toast) _toast('복구했습니다','ok'); })
      .catch(function(e){ err('복구하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }, onCancel:function(){} });
}

/* ═══ 대상 단가표 창 (2026-10-27) ═══ */
var _dpRows=[];
function dpOpen(){
  _dpRows=_dsPriceList.map(function(t){ return { prodCd:String(t.prodCd||''), baseQty:t.baseQty, basePrice:t.basePrice, underPrice:(t.underPrice==null?'':t.underPrice), remark:t.remark||'', sortOrd:t.sortOrd, useYn:t.useYn||'Y', saved:true }; });
  document.getElementById('dpWarn').innerHTML=_priceErr?'<div class="dpwarn">'+esc(_priceErr)+'</div>':'';
  dpRender(); document.getElementById('dpMask').classList.add('on');
}
function dpClose(){ document.getElementById('dpMask').classList.remove('on'); }
function dpAdd(){ var mx=0; _dpRows.forEach(function(r){ mx=Math.max(mx, n(r.sortOrd)); }); _dpRows.push({ prodCd:'', baseQty:'', basePrice:'', underPrice:'', remark:'', sortOrd:mx+10, useYn:'Y', saved:false }); dpRender();
  var e=document.querySelector('#dpBody tr:last-child input'); if(e) e.focus(); }
function dpRender(){
  document.getElementById('dpBody').innerHTML=_dpRows.length ? _dpRows.map(function(r,i){ var pn=_prod[r.prodCd];
    var inp=function(f,cls,ph){ return '<input type="text" class="'+cls+'" value="'+esc(r[f]==null?'':(cls==='num'&&r[f]!==''?fmtIn(r[f]):r[f]))+'" placeholder="'+(ph||'')+'" onchange="dpSet('+i+',\''+f+'\',this)">'; };
    return '<tr'+(r.useYn==='N'?' class="off"':'')+'><td class="l"><input type="text" list="prodList" class="cd '+(r.prodCd?(pn!=null?'ok':'bad'):'')+'" style="width:170px" value="'+esc(r.prodCd)+'" placeholder="명칭 또는 코드" onchange="dpSet('+i+',\'prodCd\',this)"></td>'
      +'<td class="l" style="white-space:normal">'+esc(pn!=null?pn:(r.prodCd?'상품 마스터에 없는 코드':''))+'</td>'
      +'<td>'+inp('baseQty','num','0 = 하나')+'</td><td>'+inp('basePrice','num','')+'</td><td>'+inp('underPrice','num','같음')+'</td><td>'+inp('remark','','')+'</td>'
      +'<td><input type="checkbox" '+(r.useYn!=='N'?'checked':'')+' onchange="_dpRows['+i+'].useYn=this.checked?\'Y\':\'N\'; dpRender()"></td>'
      +'<td><button class="x" title="단가표에서 뺍니다" onclick="dpDel('+i+')">✕</button></td></tr>'; }).join('')
    : '<tr><td colspan="8" class="msg">등록된 품목이 없습니다 — [＋ 품목 추가]</td></tr>';
}
function dpSet(i, f, el){ var r=_dpRows[i]; if(!r) return; var v=String(el.value||'').trim();
  if(f==='prodCd'){ r.prodCd=pickCd(v); dpRender(); return; }
  if(f==='remark'){ r.remark=v; return; }
  v=v.replace(/,/g,''); if(v!=='' && !/^\d+(\.\d+)?$/.test(v)){ err('숫자로 넣으세요.'); el.value=(r[f]===''||r[f]==null)?'':fmtIn(r[f]); return; }
  r[f]=(v===''?'':n(v)); el.value=(r[f]===''?'':fmtIn(r[f])); }
function dpDel(i){ var r=_dpRows[i]; if(!r) return;
  if(!r.saved){ _dpRows.splice(i,1); dpRender(); return; }
  _confirmBox({ icon:'🗑', okText:'빼기', msg:'단가표에서 <b>'+esc(r.prodCd)+'</b> '+esc(_prod[r.prodCd]||'')+' 을(를) 뺍니다.<br><span style="font-size:13px;color:#3d4d5c">이미 저장된 대상 발주의 단가는 그대로입니다. 앞으로 이 품목은 상품코드 판매가로 들어갑니다.</span>',
    onOk:function(){ post('/shipout/daesangPriceDel.do',{ prodCd:r.prodCd },true).then(pj).then(function(j){ if(j.error){ err(esc(j.error)); return; }
      dsPriceSet(j.price||[]); _dpRows.splice(i,1); dpRender(); dpApply(); if(window._toast) _toast('단가표에서 뺐습니다','ok'); }).catch(function(e){ err(esc(e.message)); }); }, onCancel:function(){} });
}
function dpSave(){
  var rows=_dpRows.filter(function(r){ return r.prodCd; }), bad=[], seen={};
  rows.forEach(function(r){ if(_prod[r.prodCd]==null) bad.push(r.prodCd+' (마스터에 없는 코드)'); else if(!(n(r.basePrice)>0)) bad.push(r.prodCd+' (이상 단가 없음)'); else if(seen[r.prodCd]) bad.push(r.prodCd+' (두 번 들어감)'); seen[r.prodCd]=1; });
  if(!rows.length){ err('저장할 품목이 없습니다.'); return; }
  if(bad.length){ err('고칠 줄이 있습니다.<br><span style="font-size:13px">'+esc(bad.join(' · '))+'</span>'); return; }
  post('/shipout/daesangPriceSave.do',{ rows:rows.map(function(r){ return { prodCd:r.prodCd, baseQty:String(r.baseQty===''?0:r.baseQty), basePrice:String(r.basePrice), underPrice:(r.underPrice===''?'':String(r.underPrice)), remark:r.remark||'', sortOrd:String(n(r.sortOrd)), useYn:r.useYn }; }) },true).then(pj)
    .then(function(j){ if(j.error){ err(esc(j.error)); return; } dsPriceSet(j.price||[]); _priceErr=''; dpOpen(); dpApply();
      if(window._toast) _toast('대상 단가표를 저장했습니다 — '+(j.cnt||0)+'품목','ok'); })
    .catch(function(e){ err('단가표를 저장하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); });
}
/* 단가표가 바뀌면 올려 둔 줄의 자동 단가를 새로(손으로 넣은 단가는 그대로) · 저장 목록은 표시만 새로 */
function dpApply(){ autoFill(); pvRender(); if(_ls.length) lsRender(); }

function lsAllChk(el){ Array.prototype.forEach.call(document.querySelectorAll('.lchk'), function(c){ c.checked=el.checked; }); }
function delSel(){
  var seqs=[], dkeys=[]; Array.prototype.forEach.call(document.querySelectorAll('.lchk:checked'), function(c){ var x=_ls[+c.getAttribute('data-i')]; if(x){ seqs.push(x.seq); dkeys.push(lsKey(x)); } });
  if(!seqs.length){ err('취소(삭제)할 줄을 고르세요.'); return; }
  _confirmBox({ icon:'🗑', okText:'삭제', msg:'고른 대상 발주 <b>'+seqs.length+'</b>줄의 저장을 취소(삭제)합니다.<br><span style="font-size:13px;color:#3d4d5c">출고·매출에서 빠지고 재고도 다시 맞춥니다. (자동 매칭용 제품명 → 품목코드 짝은 남습니다)</span>',
    onOk:function(){ post('/shipout/daesangPoDelete.do',{ seqs:seqs },true).then(pj)
      .then(function(j){ if(j.error){ err(esc(j.error)); return; } load(function(){ lsFeeSync(dkeys, false).then(function(r){ if(r.cnt) lsRender(); }); });   /* 남은 줄의 택배비 다시 */
        ok((j.cnt||0)+'줄을 삭제했습니다.'+(j.warn?'<br><span style="color:#c0392b;font-size:13px">재고 반영 경고 — '+esc(j.warn)+'</span>':'')); })
      .catch(function(e){ err('삭제하지 못했습니다.<br><span style="font-size:13px">'+esc(e.message)+'</span>'); }); }, onCancel:function(){} });
}

/* 붙여넣기 안내 펼치기·접기 — 기본은 접힘. 이 PC 에 기억한다 */
function howSet(open){ var b=document.getElementById('howBox'), t=document.getElementById('howTgl');
  b.classList.toggle('fold', !open); t.textContent=open?'▲ 접기':'▼ 펼치기'; }
function howToggle(){ var open=document.getElementById('howBox').classList.contains('fold'); howSet(open);
  try{ localStorage.setItem('dsPoHow', open?'1':'0'); }catch(e){} }

/* ── 붙여넣기 · 끌어다 놓기 · 시작 ── */
(function(){
  /* 붙여넣기 — 표(HTML 표 · 탭으로 나뉜 글)면 줄로 읽고, 그림뿐이면 캡쳐로 띄운다. 칸 안에서 한 칸짜리 글을 붙이는 것은 그대로 둔다 */
  document.addEventListener('paste', function(e){
    var cd=e.clipboardData; if(!cd) return;
    var html=cd.getData('text/html')||'', txt=cd.getData('text/plain')||'', img=null;
    Array.prototype.forEach.call(cd.items||[], function(it){ if(!img && it.kind==='file' && /^image\//.test(it.type)) img=it.getAsFile(); });
    var rows=null;
    if(/<table[\s>]/i.test(html)) rows=parseRows(htmlRows(html));
    if((!rows || !rows.length) && (txt.indexOf('\t')>=0 || looksSpaceTable(txt))) rows=parseRows(tsvRows(txt));   /* 탭 글 · 빈칸으로 띄운 글(그림을 글자로 바꾼 것) */
    if(rows && rows.length){ e.preventDefault(); addParsed(rows,'메일 표 붙여넣기');
      var fx=rows.filter(function(r){ return r.fix; }).length;
      if(fx) err('칸이 붙거나 빠진 줄 <b>'+fx+'</b>개를 전화번호 기준으로 맞춰 넣었습니다.<br><span style="font-size:13px">번호 칸에 <b style="color:#b45309">⚠</b> 가 붙은 줄입니다 — 받는 사람·주소·수량·제품명을 한 번 확인하세요.</span>');
      return; }
    if(img && !txt.trim()){ e.preventDefault(); showImg(img); return; }
    var t=e.target, inInput=t && (t.tagName==='INPUT' || t.tagName==='TEXTAREA');
    if(!inInput && txt.trim()){ err('붙여넣은 내용을 표로 읽지 못했습니다.<br><span style="font-size:13px">메일 본문의 표를 머리 줄(받는 사람 … 제품명)부터 끝 줄까지 끌어 고른 뒤 복사해 붙여 보세요. 그림(캡쳐)이면 그림만 복사해 붙이면 위에 뜹니다.</span>'); }
  });
  /* 그림 위의 Ctrl+휠 = 그림만 확대·축소(브라우저가 화면 전체를 키우지 않게 가로챈다). Ctrl 없이 굴리면 그림 칸 안에서 스크롤 */
  document.getElementById('capScroll').addEventListener('wheel', function(e){ if(!e.ctrlKey) return; e.preventDefault(); capZoom(e.deltaY<0?1:-1, 1.1); }, { passive:false });
  var d=document.getElementById('upCard');
  ['dragenter','dragover'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.add('on'); }); });
  ['dragleave','drop'].forEach(function(ev){ d.addEventListener(ev,function(e){ e.preventDefault(); d.classList.remove('on'); }); });
  d.addEventListener('drop',function(e){ onFiles(e.dataTransfer.files); });
  if(window.konetGridGrip){
    konetGridGrip('pvWrap','pvWrap','daesangPoPv'); konetGridGrip('lsWrap','lsWrap','daesangPoList');
    if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', pvRender); else pvRender();
  }
  try{ howSet(localStorage.getItem('dsPoHow')==='1'); }catch(e){ howSet(false); }
  /* 단가표·이력 창 — 제목줄(.dh)을 잡고 끈다 · 더블클릭 = 가운데 · 자리는 localStorage konetPopPos.dpMask / dhMask (2026-10-27) */
  /* ⚠덮개의 「바깥 누르면 닫기」는 onclick 속성이 아니라 여기서 — popdrag 는 onclick 이 달린 요소 «안»에서는 끌지 않는다(제목줄도 덮개 안이라 창이 안 움직였다, 2026-10-27 「마우스 표시는 되는데 안 움직임」) */
  document.getElementById('dpMask').addEventListener('click', function(e){ if(e.target===this) dpClose(); });
  document.getElementById('dhMask').addEventListener('click', function(e){ if(e.target===this) dhClose(); });
  if(window.konetPopDrag){ konetPopDrag('#dpMask','.dh'); konetPopDrag('#dhMask','.dh'); konetPopDrag('#dkMask','.dh'); }
  ['pvAmtTh','lsAmtTh'].forEach(function(id){ var th=document.getElementById(id); if(th) th.outerHTML=AMT_TH; });   /* 공급가·부가세·판매금액 머리글 (2026-10-27) */
  var t=new Date(), a=new Date(t.getFullYear(), t.getMonth(), t.getDate()-30);
  document.getElementById('dt').value=ymd(t);
  document.getElementById('fr').value=ymd(a); document.getElementById('to').value=ymd(t);
  loadMasters();
  grabFocus();
})();
/* 이 화면이 보일 때 글쇠를 이 화면으로 가져온다 — 메뉴를 누른 직후에는 글쇠가 바깥(셸)에 있어 Ctrl+V 가 안 먹는다(접혀 있어도 바로 붙여넣을 수 있게).
   입력칸에 커서가 있으면 건드리지 않는다 */
function grabFocus(){ try{ var a=document.activeElement; if(a && (a.tagName==='INPUT' || a.tagName==='SELECT' || a.tagName==='TEXTAREA')) return; window.focus(); }catch(e){} }
window.konetShown=function(){ loadMasters(); grabFocus(); };   /* 다른 화면에서 상품·사업장을 고치고 돌아오면 새로 */
</script>
</body>
</html>
