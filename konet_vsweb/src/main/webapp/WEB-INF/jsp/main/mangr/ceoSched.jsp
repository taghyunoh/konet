<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script type="text/javascript" src="${pageContext.request.contextPath}/asset/js/ui-message.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/xlsx-js-style/xlsx.bundle.js"></script>   <%-- 엑셀 쓰기 (전역 XLSX, 서식 포함) — 재고내용분석과 같은 도구 (2026-11-19) --%>
<title>대표자 일정</title>
<%-- 대표자 일정 (처음 이름 「대표이사 일정」 — 같은 날 사용자 「대표자 일정 으로 하고 별도 메뉴표시」. 주소·data-key·파일·표 이름은 ceoSched 그대로) (2026-11-19 신설 — 사용자 「직원일정 말고 대표이사 일정 등록하고 완료여부 체크, 편집기능도」 「총괄관리자만 보여지면 됨」)
     왼쪽 메뉴의 따로 선 묶음 「대표자 일정」(직원관리 묶음 밑, 처음엔 직원관리 서브메뉴였다). 셸 iframe(logiFrame 'ceoSched'). 총괄관리자(s_main_gu 1)만 — 메뉴·화면·서버 셋 다 같은 조건.

     화면 : 왼쪽 = 월 달력(날짜 칸에 일정 띠, 완료는 줄 긋고 흐리게) · 오른쪽 = 목록(「이 달」 / 「미완료」 / 「전체」 — 전체는 2026-11-19 추가, 최근 날짜가 위), 줄 앞 상태 칸 = 빈 칸(-) · 완료 · 일정취소(2026-11-19 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」 — 처음엔 완료 체크 하나였다. DB 칸은 DONE_YN 그대로 N·Y·C).
            날짜 칸의 빈 곳을 누르면 그 날짜로 새 일정, 띠·목록 줄을 누르면 그 일정을 연다(고치기·지우기).
     일정 한 건 : 일자(기간) · 시간(없어도 됨) · 장소 · 완료 · 내용(편집기).
     ★제목 칸 없음 · 내용을 줄로 보여 준다 (2026-11-19 사용자 「제목 필요 없고 직원 업무일지 내용처럼 일정 등록 · 이 내용 완료·일정취소 할 수 있게 — 한 텍스트로 저장하지만 · 검색은 내용으로」) :
       창에서 제목 칸을 뺐다 — DB TITLE 에는 내용의 첫 줄을 넣는다(목록·삭제 확인·겹침 알림이 쓴다). 내용이 없는 옛 일정은 제목을 한 줄로 보여 준다.
       달력 칸·오른쪽 목록에 그 일정의 내용 줄을 그대로(직원 업무일지 격자처럼) 보이고, 줄 앞 칩을 누르면 그 줄만 (없음) → 완료 → 일정취소 → (없음).
       ★줄 상태는 따로 칸을 두지 않고 «그 줄 끝 글자»로 저장한다 — 「… 완료」 / 「… 일정취소」(손으로 줄 끝에 「완료」라고 적은 것도 완료로 읽는다. 앞에 띄어쓰기나 괄호가 있어야 한다 — 「검수완료」는 아님).
       일정 전체 상태(DONE_YN 완료·일정취소)는 종전 그대로 따로다. 검색 = 내용 글자 + 장소.
       목록에는 내용이 실려 온다(selectCeoSchedList content) — 옛 서버면 내용 있는 일정만 한 건씩 읽어 채운다(loadContents).
     편집기 : 가벼운 자체 편집기(contenteditable + execCommand) — 굵게·기울임·밑줄·취소선 · 글꼴 · 크기 · 글자색 · 형광펜 · 목록 · 정렬 · 서식 지우기.
              ★그림은 넣지 않는다(붙여 넣어도 빠진다) — 내용이 DB 한 칸(NVARCHAR(MAX))에 들어가므로. 붙여 넣은 글은 clean() 으로 걸러(허용 태그·속성만) 넣는다.
              서버(ceoClean)도 한 번 더 거른다.
     엑셀·인쇄 (2026-11-19) : 오른쪽 목록에 보이는 것 그대로(탭 + 검색). 내용은 그때 한 건씩 읽어 온다 — 아래 「엑셀 · 인쇄」 묶음.
     삭제 (2026-11-19) : 창의 [삭제] · 목록 줄 끝의 🗑. 완료한 일정은 일정취소로 바꾼 뒤에만 지운다 — 아래 delAsk.
     같은 시간 일정 (2026-11-19) : 날짜가 겹치고 시간이 같은 다른 일정이 있으면 창에 노란 띠 + 저장 때 「그래도 저장」 확인 — 아래 dupOf.
     자료 : /mangr/ceoSchedList.do(목록, 내용 없이) · ceoSchedGet.do(한 건, 내용 포함) · ceoSchedSave.do · ceoSchedDone.do(완료 체크만) · ceoSchedDel.do
            표 = TBL_CEO_SCHED (docs/sql/20261119_ceo_sched.sql) — 아직 없으면 서버가 noTable=Y 를 주고 화면 위에 안내 띠가 뜬다.
     ⚠JSP 라 스크립트 안에 달러+중괄호 · 샵+중괄호를 쓰지 않는다(EL 로 읽힌다) — 글 잇기는 + 로. --%>
<style>
  :root{ --bd:#dbe2ea; --teal:#137a6c; --bg:#f5f7f9; --red:#b23b3b; }
  *{ box-sizing:border-box; }
  html,body{ margin:0; padding:0; height:100%; overflow:hidden; }
  body{ font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#1f2a37; background:var(--bg); font-size:14px; }
  .wrap{ padding:6px 11px 8px; height:100%; display:flex; flex-direction:column; min-height:0; }
  .hd{ display:flex; align-items:baseline; gap:10px; margin:2px 2px 6px; }
  .hd h2{ margin:0; font-size:19px; } .hd small{ color:#6b7a89; font-size:12.5px; }
  .bar{ display:flex; flex-wrap:wrap; align-items:center; gap:5px 8px; padding:6px 10px; background:#fff; border:1px solid var(--bd); border-radius:8px; margin-bottom:6px; }
  .bar .sp{ flex:1; }
  /* 로그인 알림 설정 (2026-11-19) */
  .bar .lateset{ display:inline-flex; align-items:center; gap:5px; margin-left:10px; font-size:12.5px; color:#48606f; }
  .bar .lateset input{ width:62px; height:28px; border:1px solid #cbd5e1; border-radius:5px; font-size:13px; font-family:inherit; padding:0 6px; text-align:right; font-variant-numeric:tabular-nums; }
  .bar .lateset small{ color:#8794a1; font-size:11.5px; }
  .bar .ym{ font-size:17px; font-weight:800; min-width:118px; text-align:center; font-variant-numeric:tabular-nums; }
  .bar .nav{ width:30px; height:30px; border:1px solid #cbd5e1; background:#fff; border-radius:5px; cursor:pointer; font-size:13px; color:#37475a; }
  .bar .nav:hover{ border-color:var(--teal); color:var(--teal); }
  .bar input[type=search]{ height:30px; width:200px; border:1px solid #cbd5e1; border-radius:5px; padding:0 8px; font-size:13px; font-family:inherit; }
  .bar .sum{ font-size:13px; color:#48606f; margin-left:6px; } .bar .sum b{ color:#0f6b5e; } .bar .sum b.late{ color:var(--red); }
  .btn{ height:30px; border:1px solid var(--teal); background:var(--teal); color:#fff; border-radius:5px; padding:0 14px; font-size:13px; font-weight:700; cursor:pointer; font-family:inherit; }
  .btn.ghost{ background:#fff; color:var(--teal); }
  .btn.danger{ background:#fff; border-color:#d9a3a3; color:var(--red); }
  .btn.danger:hover{ background:var(--red); border-color:var(--red); color:#fff; }
  .warn{ padding:9px 12px; margin-bottom:6px; background:#fff6dc; border:1px solid #e9c46a; border-radius:8px; color:#7a5c00; font-size:13.5px; line-height:1.6; }
  .deny{ margin:60px auto; padding:26px 34px; background:#fff; border:1px solid var(--bd); border-radius:10px; font-size:15px; color:#48606f; text-align:center; }

  .main{ flex:1 1 0; min-height:0; display:flex; gap:8px; }
  /* 달력 */
  .calbox{ flex:1 1 0; min-width:0; background:#fff; border:1px solid var(--bd); border-radius:8px; overflow:hidden; display:flex; flex-direction:column; }
  .calhd{ display:grid; grid-template-columns:repeat(7,1fr); background:#d9edf7; border-bottom:1px solid #9fb6c3; flex:none; overflow:hidden; }   /* 칸 폭은 calHdSync 가 달력 칸에 맞춘다 · 좌우 스크롤도 따라간다 */
  .calhd div{ padding:3px 0; text-align:center; font-weight:700; font-size:13px; }
  .calhd div span{ display:inline-block; min-width:24px; height:24px; line-height:24px; border-radius:12px; padding:0 4px; }
  .calhd div.tdy span{ background:var(--teal); color:#fff; }   /* 오늘 요일 (2026-11-19 사용자 「헤더 해당요일표시」) — 오늘이 든 달을 볼 때만. 직원 휴가 관리 달력과 같은 표시 */
  .calhd div:first-child{ color:#c0392b; } .calhd div:last-child{ color:#2f4f9a; }
  /* ★칸 안 글을 다 보인다 (2026-11-19 사용자 「입력 내용 우측처럼 다 보였으면」) — 칸이 내용만큼 자라고(주 줄 높이 = 그 주에서 가장 긴 칸), 넘치면 달력 전체가 스크롤된다.
     종전엔 칸 높이를 고정하고 칸마다 스크롤 · 줄은 한 줄로 잘랐다(…). 줄 높이의 바닥은 «화면을 주 수로 나눈 높이»(calRows)라 내용이 적은 달은 종전 모양 그대로 */
  /* ★칸이 옆으로도 자란다 (2026-11-19 사용자 「내용 따라 아래로 늘지만 횡으로도 늘게 — 좌우 스크롤」) — 요일 칸 폭 = 그 요일에서 가장 긴 줄(max-content), 바닥은 화면 폭 ÷ 7(--dcw), 꼭대기는 520px(그 이상은 줄이 접힌다).
     넘치면 달력이 좌우로도 스크롤되고, 위 요일 머리줄은 칸 폭·스크롤을 따라간다(calHdSync). ⚠minmax(바닥, max-content) 로는 안 자란다 — 줄(rows)과 같은 까닭 */
  /* ★빈 칸은 최소 크기 (2026-11-19 사용자 「한 라인 하나도 없으면 최소 사이즈로」) — 칸·줄 = minmax(내용 크기, auto) :
       내용 있는 칸이 먼저 제 크기를 차지하고, 화면이 남으면 남는 자리를 일곱 칸(다섯·여섯 주)에 고르게 나눈다(빈 달은 종전처럼 화면을 꽉 채운다).
       자리가 모자라면 빈 칸은 최소(폭 64px · 높이 46px)까지 줄고, 그래도 모자라면 좌우·위아래로 스크롤된다.
       종전(같은 날)엔 바닥이 «화면 ÷ 7»·«화면 ÷ 주 수»로 고정이라 빈 칸도 넓게 남아 내용 있는 칸이 화면 밖으로 밀렸다 */
  .cal{ flex:1 1 0; min-height:0; min-width:0; display:grid; grid-template-columns:repeat(7, minmax(max-content, auto)); overflow:auto; scrollbar-width:thin; }
  .cal .dc{ border-right:1px solid #e3e8ee; border-bottom:1px solid #e3e8ee; padding:3px 4px 4px; min-width:64px; max-width:520px; min-height:46px; cursor:pointer; }
  .cal .dc:nth-child(7n){ border-right:0; }
  .cal .dc:hover{ background:#f6fbfa; }
  .cal .dc.out{ background:#fafbfc; } .cal .dc.out .dn{ color:#b6c0ca; }
  .cal .dn{ display:inline-flex; align-items:center; justify-content:center; min-width:22px; height:22px; font-size:12.5px; font-weight:700; color:#37475a; border-radius:11px; padding:0 4px; }
  .cal .dc.sun .dn{ color:#c0392b; } .cal .dc.sat .dn{ color:#2f4f9a; }
  .cal .dc.tdy .dn{ background:var(--teal); color:#fff; }
  .cal .dc.flash{ animation:dcflash 1.8s ease-out 1; }   /* 목록 날짜를 눌러 찾아간 칸 (2026-11-20) */
  @keyframes dcflash{ 0%,35%{ background:#fff3a3; box-shadow:inset 0 0 0 2px #e0b000; } 100%{ background:transparent; box-shadow:inset 0 0 0 0 transparent; } }
  .it .t2 .dgo{ cursor:pointer; } .it .t2 .dgo:hover{ color:var(--teal); text-decoration:underline; }
  .cal .ev{ display:block; margin-top:2px; padding:1px 6px; border-radius:4px; background:#e3f2ee; border-left:3px solid var(--teal); color:#12453d; font-size:12px; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  /* 내용 줄 (2026-11-19) — 달력 칸·목록에 일정의 내용 줄을 업무일지처럼. 줄 앞 칩 = 그 줄의 상태(없음 · 완료 · 일정취소) */
  .cal .ev.lns{ white-space:normal; padding:2px 4px 2px 5px; font-weight:600; }
  .eh{ display:flex; align-items:center; gap:4px; font-size:11.5px; font-weight:800; color:#0f6b5e; font-variant-numeric:tabular-nums; margin-bottom:2px; white-space:nowrap; }
  .eh .et{ min-width:0; overflow:hidden; text-overflow:ellipsis; } .eh .cnt{ margin-right:0; }
  /* 달력 칸의 상태 칸 — 목록 상태 칸을 작게 */
  .cal .ev select.st{ flex:none; width:58px; height:20px; padding:0 0 0 6px; border:1px solid #cbd5e1; border-radius:10px; background:#fff; color:#5a6b7a; font-size:11px; font-weight:800; font-family:inherit; cursor:pointer; }
  .cal .ev select.st.stY{ background:#137a6c; border-color:#137a6c; color:#fff; } .cal .ev select.st.stC{ background:#fde8e8; border-color:#e3a5a5; color:#c0392b; }
  .cal .ev select.st option{ background:#fff; color:#1f2a37; font-weight:600; }
  .ln{ display:flex; gap:4px; align-items:flex-start; font-size:12px; line-height:1.4; color:#1f2a37; font-weight:500; word-break:break-all; }
  .ln .ck{ flex:none; display:inline-flex; align-items:center; justify-content:center; min-width:17px; height:16px; margin-top:1px; padding:0 3px; border:1px solid #b9c4d0; border-radius:4px; background:#fff; color:#8794a1; font-size:10.5px; font-weight:800; cursor:pointer; line-height:1; }
  .ln .ck:hover{ border-color:var(--teal); color:var(--teal); }
  .ln.lY .ck{ background:#137a6c; border-color:#137a6c; color:#fff; } .ln.lC .ck{ background:#fde8e8; border-color:#e3a5a5; color:#c0392b; }   /* 취소 = 빨간 ✕ (2026-11-19 사용자 「취소는 x 빨간색으로」) */
  .tag.cx{ background:#fde8e8; color:#c0392b; }
  /* ★완료·일정취소 줄에 취소선을 긋지 않는다 (2026-11-19 사용자 「글자 중간선은 제거」) — 흐린 글자 + 「완료」·「일정취소」 꼬리표로만 알린다 */
  .ln.lY .lt, .ln.lC .lt{ text-decoration:none; }   /* ★끝난 줄도 글자는 또렷하게 (2026-11-19 사용자 「글자가 흐림」) — 흐리게·회색 글자를 없애고 체크된 칸 + 「완료」·「취소」 꼬리표로만 알린다 */
  .ln .lt mark{ background:#fff3a3; color:inherit; padding:0; }
  .ln.nock .ck{ visibility:hidden; }
  /* 업무일지 꼴 (2026-11-19 사용자 「이런 식으로 입력 가능하게」 — 직원 업무일지 격자 그림) : 번호는 따로 칸(줄이 넘쳐도 글이 번호 뒤에 맞춰 들어간다) · 번호 없는 줄은 묶음 머리(굵게) · 일정마다 「N건」 */
  .ln .no{ flex:none; min-width:15px; text-align:right; color:#5a6b7a; font-variant-numeric:tabular-nums; }
  .ln .lt{ flex:1; min-width:0; }
  .ln.hd .lt{ font-weight:800; color:#12453d; } .ln.hd + .ln:not(.hd){ margin-top:0; } .ln.hd:not(:first-child){ margin-top:3px; }
  .cnt{ display:inline-block; padding:0 7px; margin-right:5px; border-radius:9px; background:#dff0eb; color:#0f6b5e; font-size:11px; font-weight:800; vertical-align:1px; }
  .cnt i{ font-style:normal; color:#5a6b7a; font-weight:700; }
  /* 달력 칸은 좁다 — 줄마다 한 줄로 자르고(…) 전체 글은 마우스를 올리면 보인다. 끝난 일정의 취소선은 글에만(칩에 줄이 그어지지 않게) */
  .cal .ev.lns.done, .cal .ev.lns.cancel{ text-decoration:none; }
  .cal .ev:hover{ background:#cfe9e2; }
  .cal .ev i{ font-style:normal; font-weight:800; color:#0f6b5e; margin-right:3px; font-variant-numeric:tabular-nums; }
  .cal .ev.late{ background:#fde8e8; border-left-color:var(--red); color:#7d2323; } .cal .ev.late i{ color:var(--red); }
  .cal .ev.done, .cal .ev.cancel{ background:#eef1f4; border-left-color:#aab5c0; color:#8794a1; text-decoration:none; font-weight:600; } .cal .ev.done i, .cal .ev.cancel i{ color:#8794a1; }
  .cal .ev.done .eh, .cal .ev.cancel .eh{ color:#48606f; }   /* 머리줄(「✓ 완료 · 시간 · 장소」)은 흐리게만 — 줄을 그으면 「완료」 글자까지 지워진 것처럼 보였다 (2026-11-19) */
  .cal .ev.done .lt, .cal .ev.cancel .lt{ text-decoration:none; }
  /* 목록 */
  .side{ flex:0 0 clamp(340px,30%,460px); min-width:0; background:#fff; border:1px solid var(--bd); border-radius:8px; display:flex; flex-direction:column; overflow:hidden; }
  .tabs{ display:flex; gap:4px; padding:6px 8px 0; border-bottom:1px solid var(--bd); background:#f7faf9; flex:none; }
  .tab{ padding:6px 13px; border:1px solid var(--bd); border-bottom:0; border-radius:7px 7px 0 0; background:#eef2f5; font-size:13px; font-weight:700; color:#5a6b7a; cursor:pointer; user-select:none; }
  .tab.on{ background:#fff; color:#0f6b5e; position:relative; top:1px; }
  .tabs .delbtn{ margin-left:auto; align-self:center; margin-bottom:4px; padding:2px 9px; border:1px solid var(--bd); border-radius:12px; background:#fff; font-size:12px; font-weight:700; color:#6b7a89; cursor:pointer; user-select:none; white-space:nowrap; }   /* 삭제함 단추 (2026-11-20) */
  .tabs .delbtn b{ font-weight:800; color:#48606f; } .tabs .delbtn:hover{ border-color:#c0392b; color:#c0392b; }
  .tabs .delbtn.on{ background:#fde8e8; border-color:#c0392b; color:#c0392b; } .tabs .delbtn.on b{ color:#c0392b; }
  .tab b{ display:inline-block; min-width:18px; padding:0 5px; margin-left:3px; border-radius:9px; background:#c7d2dc; color:#fff; font-size:11.5px; text-align:center; }
  .tab b.late{ background:var(--red); }
  /* 삭제 탭 (2026-11-19 사용자 「삭제한 것 보고 복구 기능도」) */
  .it.del{ cursor:default; } .it.del .lw{ background:#f3f4f6; border-left-color:#c3cad2; } .it.del .ln .ck{ cursor:default; }
  .it .rst{ flex:none; height:26px; padding:0 10px; border:1px solid var(--teal); border-radius:6px; background:#fff; color:var(--teal); font-size:12px; font-weight:800; cursor:pointer; font-family:inherit; }
  .it .rst:hover{ background:var(--teal); color:#fff; }
  .tag.dl{ background:#eef1f4; color:#5a6b7a; }
  .list{ flex:1 1 0; min-height:0; overflow:auto; }
  /* 맨 위 요약 + 기간 조건 (2026-11-20) */
  .pers{ display:flex; gap:5px; flex-wrap:wrap; padding:6px 8px; border-bottom:1px solid var(--bd); background:#fff; flex:none; }
  .pers:empty{ display:none; }
  .per{ display:inline-flex; align-items:center; gap:4px; padding:2px 10px; border:1px solid var(--bd); border-radius:13px; background:#f7f9fb; font-size:12.5px; font-weight:700; color:#48606f; cursor:pointer; user-select:none; }
  .per b{ font-weight:800; color:#1f2a37; } .per.z{ opacity:.55; } .per:hover{ border-color:var(--teal); }
  .per.on{ background:#e3f2ee; border-color:var(--teal); color:#0f6b5e; } .per.on b{ color:#0f6b5e; }
  .per.lt b{ color:var(--red); } .per.lt.on{ background:#fde8e8; border-color:var(--red); color:var(--red); }
  .list .pgh{ position:sticky; top:0; z-index:1; padding:4px 10px; font-size:12px; font-weight:800; color:#48606f; background:#eef2f5; border-bottom:1px solid #e3e8ee; }
  .list .pgh.lt{ color:var(--red); background:#fdf0f0; } .list .pgh b{ font-weight:800; }
  .list .empty{ padding:34px 12px; text-align:center; color:#8794a1; font-size:13.5px; line-height:1.8; }
  .it{ display:block; padding:7px 11px 8px; border-bottom:1px solid #eef1f5; cursor:pointer; }
  /* ★상태 칸은 날짜 줄 맨 앞에, 내용 판은 그 밑에 꽉 차게 (2026-11-19 사용자 「완료 앞으로 나오지 말고 박스와 나란히 위에 위치하게」) — 종전엔 상태 칸이 왼쪽 세로 칸을 차지해 판이 오른쪽으로 밀렸다 */
  .it .ih{ display:flex; align-items:center; gap:7px; margin-bottom:4px; }
  .it .ih .t2{ flex:1; min-width:0; margin:0; }
  .it:hover{ background:#f1f9f7; }
  /* 줄 끝 삭제 단추 (2026-11-19 사용자 「일정 삭제기능도」) — 평소엔 흐리게, 줄에 마우스를 올리면 또렷하게 */
  .it .rowdel{ flex:none; width:28px; height:28px; padding:0; border:1px solid transparent; border-radius:6px; background:transparent; font-size:13px; cursor:pointer; opacity:.3; }
  .it:hover .rowdel{ opacity:.85; border-color:#e6caca; } .it .rowdel:hover{ opacity:1; background:#fde8e8; border-color:#d9a3a3; }
  /* 상태 칸 (2026-11-19 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」) — 종전 완료 체크 칸 자리. 빈 칸(-) · 완료 · 일정취소 중에 고른다 */
  .it select.st{ flex:none; width:84px; height:26px; margin-top:1px; padding:0 2px 0 8px; border:1px solid #cbd5e1; border-radius:13px; background:#fff; color:#5a6b7a; font-size:12px; font-weight:800; font-family:inherit; cursor:pointer; }
  .it select.st.stY{ background:#137a6c; border-color:#137a6c; color:#fff; } .it select.st.stC{ background:#fde8e8; border-color:#e3a5a5; color:#c0392b; }
  .it select.st option{ background:#fff; color:#1f2a37; font-weight:600; }
  .it .tx{ flex:1; min-width:0; }
  .it .t1{ font-size:14px; font-weight:700; color:#1f2a37; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .it .t2{ margin-top:2px; font-size:12.5px; color:#5a6b7a; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .it .t2 b{ color:#0f6b5e; font-variant-numeric:tabular-nums; }
  .it .t2{ margin-top:0; margin-bottom:3px; } .it .lw .ln{ font-size:13px; } .it .lw .ln + .ln{ margin-top:1px; }
  .it.done .lw .lt, .it.cancel .lw .lt{ text-decoration:none; }
  /* 오른쪽 목록도 달력 칸과 같은 모양 (2026-11-19 사용자 「오른쪽 목록도 같은 서식으로」) */
  .it .lw{ padding:3px 6px 3px 5px; border-radius:4px; background:#e3f2ee; border-left:3px solid var(--teal); }
  .it.late .lw{ background:#fde8e8; border-left-color:var(--red); }
  .it.done .lw, .it.cancel .lw{ background:#eef1f4; border-left-color:#aab5c0; }
  .it .lw .ln{ font-size:12.5px; }
  .it .lw .lnhid{ font-size:11.5px; color:#6b7a89; margin-top:2px; text-align:right; }   /* 미완료 탭 — 끝난 줄 숨김 (2026-11-20) */
  .ln .lt .tag{ opacity:1; }
  .it.done .t1, .it.cancel .t1{ color:#8794a1; text-decoration:none; font-weight:600; } .it.done .t2, .it.done .t2 b, .it.cancel .t2, .it.cancel .t2 b{ color:#48606f; }
  .tag{ display:inline-block; padding:0 7px; border-radius:9px; font-size:11.5px; font-weight:800; margin-left:5px; vertical-align:1px; }
  .tag.late{ background:#fde8e8; color:#a12b2b; } .tag.tdy{ background:#dff0eb; color:#0f6b5e; } .tag.ok{ background:#eef1f4; color:#5a6b7a; }
  .memo{ margin-left:4px; font-size:12px; opacity:.75; }

  /* 등록·수정 창 */
  .pop{ position:fixed; inset:0; background:rgba(15,23,32,.35); display:none; align-items:flex-start; justify-content:center; z-index:900; padding-top:4vh; }
  .pop.on{ display:flex; }
  .pop .box{ background:#fff; width:min(760px,96vw);   /* 900 → 760 (2026-11-19 사용자 「이 부분 조금만 축소」 — 편집 칸 오른쪽 빈 자리) */ max-height:92vh; border-radius:12px; box-shadow:0 12px 40px rgba(0,0,0,.3); display:flex; flex-direction:column; overflow:hidden; }
  .pop .ph{ display:flex; gap:10px; align-items:center; padding:10px 14px; border-bottom:1px solid #eef1f5; flex:none; }
  .pop .ph b{ font-size:15.5px; color:#125a4e; } .pop .ph .info{ flex:1; font-size:12px; color:#8794a1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  .pop .pf{ display:flex; flex-wrap:wrap; gap:6px 8px; align-items:center; padding:7px 14px 0; flex:none; }
  .pop .pf label{ font-size:13px; font-weight:700; color:#48606f; min-width:34px; }
  .pop .pf input[type=text], .pop .pf input[type=date], .pop .pf input[type=time]{ height:32px; border:1px solid #cbd5e1; border-radius:6px; padding:0 8px; font-size:13.5px; font-family:inherit; }
  .pop .pf input.req{ border-color:#e9b98a; background:#fffaf4; }
  /* 창의 상태 고르기 — [완료][일정취소] 둘. 둘 다 안 눌린 것이 «아무것도 없음» (2026-11-19 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」) */
  .pop .pf .stg{ display:inline-flex; margin-left:8px; border:1px solid #cbd5e1; border-radius:16px; overflow:hidden; }
  .pop .pf .stg .sb{ min-width:0; display:inline-flex; align-items:center; height:30px; padding:0 14px; font-size:13px; font-weight:700; font-family:inherit; color:#5a6b7a; background:#fff; cursor:pointer; border:0; border-right:1px solid #e3e8ee; user-select:none; }
  .pop .pf .stg .sb:last-child{ border-right:0; } .pop .pf .stg .sb:hover{ background:#f6fbfa; }
  .pop .pf .stg .sb.on.vY{ background:#137a6c; color:#fff; } .pop .pf .stg .sb.on.vC{ background:#fde8e8; color:#c0392b; }
  .pop .pf .stg .sb.vN{ min-width:40px; justify-content:center; font-weight:800; } .pop .pf .stg .sb.on.vN{ background:#eef2f5; color:#1f2a37; box-shadow:inset 0 0 0 1px #9fb0c0; }   /* 창도 완료 / 공백(-) / 취소 (2026-11-19 사용자 「수정 창도 완료 / 공백 / 취소로」) — 늘 셋 중 하나가 눌려 있다 */
  .pop .dup{ margin:6px 14px 0; padding:5px 10px; border:1px solid #e9c46a; border-radius:6px; background:#fff6dc; color:#7a5c00; font-size:12.5px; line-height:1.55; flex:none; }   /* 같은 시간 일정 알림 (2026-11-19) */
  .pop .dup b{ color:#8a4a00; }
  /* 편집기 */
  .tb{ display:flex; flex-wrap:wrap; align-items:center; gap:3px; margin:9px 14px 0; padding:5px 6px; border:1px solid #cbd5e1; border-bottom:0; border-radius:7px 7px 0 0; background:#f3f6f8; flex:none; }
  .tb button{ min-width:28px; height:28px; padding:0 6px; border:1px solid #cfd8e3; border-radius:5px; background:#fff; font-size:13px; color:#1f2a37; cursor:pointer; font-family:inherit; }
  .tb button:hover{ border-color:var(--teal); color:var(--teal); }
  .tb button.on{ background:#dff0eb; border-color:var(--teal); color:#0f6b5e; }   /* 지금 켜져 있는 서식 (2026-11-19) */
  .tb select{ height:28px; border:1px solid #cfd8e3; border-radius:5px; background:#fff; font-size:12.5px; font-family:inherit; }
  .tb .sep{ width:1px; height:20px; background:#cfd8e3; margin:0 4px; }
  .tb .lb{ font-size:12px; color:#5a6b7a; font-weight:700; margin:0 2px 0 3px; }
  .tb .sw{ width:20px; min-width:20px; height:20px; padding:0; border-radius:4px; border:1px solid #b9c4d0; }
  .tb .sw.no{ background:#fff; color:#b23b3b; font-size:12px; line-height:16px; }
  .ed{ flex:1 1 auto; height:clamp(220px,44vh,460px); min-height:110px;   /* 창이 낮으면 편집 칸이 줄어 [저장] 줄이 늘 보인다 */ margin:0 14px; padding:10px 12px; border:1px solid #cbd5e1; border-radius:0 0 7px 7px; overflow:auto; font-size:14px; line-height:1.65; outline:none; background:#fff; word-break:break-word; }
  .ed:focus{ border-color:var(--teal); }
  .ed:empty:before{ content:attr(data-ph); color:#a3afbb; }
  .ed p{ margin:0 0 6px; } .ed ul, .ed ol{ margin:4px 0 6px; padding-left:24px; } .ed table{ border-collapse:collapse; } .ed td, .ed th{ border:1px solid #cbd5e1; padding:3px 6px; }
  .ed a{ color:#2f4f9a; }
  .pop .pb{ display:flex; gap:8px; align-items:center; padding:10px 14px; border-top:1px solid #dbe2ea; margin-top:9px; flex:none; }
  .pop .pb .sp{ flex:1; } .pop .pb .len{ font-size:12px; color:#8794a1; }
  .busy{ position:fixed; right:16px; bottom:14px; padding:7px 14px; background:#1f2a37; color:#fff; border-radius:16px; font-size:12.5px; display:none; z-index:950; }
  .busy.on{ display:block; }
  /* ── 인쇄 (2026-11-19 사용자 「엑셀출력 및 인쇄 넣어줘요」) — 화면(달력·단추·창)은 통째로 빼고 #printArea 의 제목 + 표만. A4 세로 ── */
  #printArea{ display:none; }
  @page{ size:A4 portrait; margin:10mm; }
  @media print{
    html, body{ height:auto !important; overflow:visible !important; background:#fff !important; }
    body > *:not(#printArea){ display:none !important; }
    #printArea{ display:block !important; color:#000; }
    #printArea .pt{ margin:0 0 7px; } #printArea .pt b{ font-size:17px; } #printArea .pt span{ font-size:11.5px; color:#333; margin-left:10px; }
    table.pl{ width:100%; border-collapse:collapse; table-layout:fixed; font-size:11px; }
    table.pl th{ background:#d9edf7 !important; border:1px solid #555; padding:3px 4px; font-weight:700; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    table.pl td{ border:1px solid #777; padding:3px 5px; vertical-align:top; word-break:break-word; line-height:1.45; }
    table.pl td.c{ text-align:center; } table.pl td.late{ color:#b23b3b; font-weight:700; }
    table.pl tr{ page-break-inside:avoid; } table.pl tr.dn td{ color:#555; }
    table.pl .pp{ font-size:10px; color:#555; font-weight:400; }
    table.pl td.ct p{ margin:0 0 3px; } table.pl td.ct ul, table.pl td.ct ol{ margin:2px 0; padding-left:18px; }
    table.pl td.ct table{ border-collapse:collapse; } table.pl td.ct td, table.pl td.ct th{ border:1px solid #999; padding:1px 4px; }
  }
</style>
</head>
<body>
<div class="wrap" id="wrap">
  <div class="hd"><h2>🗓 대표자 일정</h2><small>일정을 등록하고 끝난 일은 체크합니다 — 총괄관리자만 보입니다</small></div>
  <div class="bar">
    <button type="button" class="nav" onclick="monGo(-1)" title="앞 달">◀</button>
    <span class="ym" id="ymTxt"></span>
    <button type="button" class="nav" onclick="monGo(1)" title="다음 달">▶</button>
    <button type="button" class="btn ghost" onclick="monToday()">오늘</button>
    <span class="sum" id="sumTxt"></span>
    <span class="sp"></span>
    <label class="lateset" title="로그인할 때 뜨는 「오늘부터 일주일」 창에 «날짜가 지난 미완료»를 며칠 전 것까지 보일지 — 숫자 n = 끝난 지 n일 안쪽인 지난 미완료만 · 0 = 지난 미완료는 안 보임(기본) · 오늘·이번 주 일정은 늘 보입니다 (이 브라우저에 남음)">로그인 알림 · 지난 미완료 <input type="number" id="lateDays" min="0" max="365" step="1" placeholder="0" oninput="lateDaysSet(this.value)" onchange="lateDaysSet(this.value)"> 일 전까지 <small id="lateDaysTip"></small></label>
    <span class="sp"></span>
    <input type="search" id="q" placeholder="🔎 내용 / 장소 검색" title="일정 내용(줄 글자)과 장소에서 찾습니다" oninput="paintList()">
    <button type="button" class="btn ghost" onclick="xls()" title="오른쪽 목록에 보이는 일정(탭·검색 그대로)을 엑셀로 — 내용은 글자만">📥 엑셀</button>
    <button type="button" class="btn ghost" onclick="prt()" title="오른쪽 목록에 보이는 일정(탭·검색 그대로)을 인쇄 — A4 세로, 내용은 서식 그대로">🖨 인쇄</button>
    <%-- [＋ 일정 등록] 단추는 뺐다 (2026-11-19 사용자 「일정 등록 제거 — 의미 없음」) — 날짜 칸을 누르면 그 날 일정이 열리고 없으면 새 일정 --%>
  </div>
  <div class="warn" id="noTable" style="display:none">⚠ 일정 표(<b>TBL_CEO_SCHED</b>)가 아직 없습니다 — <b>docs/sql/20261119_ceo_sched.sql</b> 을 운영 DB에서 한 번 실행한 뒤 이 화면을 새로고침해 주세요. (그 전에는 저장되지 않습니다)</div>
  <div class="main">
    <div class="calbox">
      <div class="calhd" id="calHd"><div><span>일</span></div><div><span>월</span></div><div><span>화</span></div><div><span>수</span></div><div><span>목</span></div><div><span>금</span></div><div><span>토</span></div></div>
      <div class="cal" id="cal"></div>
    </div>
    <div class="side">
      <div class="tabs">
        <span class="tab on" id="tabTodo" onclick="tabGo('todo')" title="달과 관계없이 아직 끝내지 않은 일정 전부(완료·취소 제외) · 그 안에서도 끝낸 줄은 숨기고 남은 줄만 — 빨간 숫자는 날짜가 지난 것이 있다는 표시">미완료 <b id="todoCnt">0</b></span>
        <span class="tab" id="tabAll" onclick="tabGo('all')" title="달·완료 여부와 관계없이 등록된 일정 전부 — 최근 날짜가 위">전체 <b id="allCnt">0</b></span>
        <%-- 삭제는 탭이 아니라 오른쪽 끝 작은 단추 (2026-11-20 사용자 「삭제 별도 뺀다고 하지 않았나요」 — 자주 쓰지 않는다). id 는 그대로라 코드는 종전 그대로 --%>
        <span class="delbtn" id="tabDel" onclick="tabGo(_tab==='del' ? 'todo' : 'del')" title="지운 일정 보기 — 최근 지운 것이 위 · [↩ 복구]로 되살립니다 (다시 누르면 미완료로)">🗑 삭제함 <b id="delCnt">0</b></span>
      </div>
      <div class="pers" id="pers"></div>   <%-- 맨 위 요약 + 기간 조건 (2026-11-20) — 칩 숫자가 요약, 누르면 그 기간만 --%>
      <div class="list" id="list"></div>
    </div>
  </div>
</div>

<%-- 등록·수정 창 --%>
<div class="pop" id="pop">
  <div class="box">
    <div class="ph"><b id="popTit">일정 등록</b><span class="info" id="popInfo"></span><button type="button" class="btn ghost" onclick="edClose()">닫기 ✕</button></div>
    <div class="pf">
      <label>일자</label><input type="date" id="fFrom" class="req" onchange="edFromSet()"> <span style="color:#8794a1">~</span> <input type="date" id="fTo">
      <label style="margin-left:8px">시간</label><input type="time" id="fTm" title="비워 두면 종일 일정">
      <span style="display:inline-flex; align-items:center; gap:6px; margin-left:8px"><label>장소</label><input type="text" id="fPlace" maxlength="100" style="width:190px" placeholder="(선택)"></span>   <%-- 이름표와 칸이 따로 줄바꿈되지 않게 (창 폭 760) --%>
      <span class="stg" id="fSt" title="끝났으면 [완료], 없어진 일정이면 [취소], 아무 표시도 없게 하려면 [-] — 고르면 아래 내용 줄 전부에 같은 표시가 붙습니다. 목록의 상태 칸으로도 바꿀 수 있습니다"><button type="button" class="sb vY" data-v="Y">완료</button><button type="button" class="sb vN" data-v="N" title="공백 — 상태 없음">-</button><button type="button" class="sb vC" data-v="C">취소</button></span>
    </div>
    <div class="dup" id="dupHint" style="display:none"></div>
    <div class="tb" id="tb"></div>
    <div class="ed" id="ed" contenteditable="true" data-ph="일정을 줄마다 적으세요 — 예) 삼성미팅 ⏎ 1. 차상회 셀장 미팅 ⏎ (Enter 를 치면 2. 이 저절로) ⏎ 번호만 남은 줄에서 Enter = 번호 끝. 끝난 줄은 끝에 「완료」라고 적거나 달력·목록에서 줄 앞 칩을 누릅니다 (그림은 넣을 수 없습니다)"></div>
    <div class="pb">
      <button type="button" class="btn danger" id="btnDel" onclick="edDel()">🗑 삭제</button>
      <span class="sp"></span><span class="len" id="edLen"></span>
      <button type="button" class="btn" onclick="edSave()" title="Ctrl+S">💾 저장</button>
      <button type="button" class="btn ghost" onclick="edClose()">닫기</button>   <%-- [저장][닫기] 차례 (2026-11-19 사용자 「닫기, 저장 위치 변경」 — 종전 [닫기][저장]) --%>
    </div>
  </div>
</div>
<div id="printArea"></div>
<div class="busy" id="busy">⏳ 처리 중…</div>

<script>
var CTX='${pageContext.request.contextPath}', ADMIN=('${ceoAdmin}'==='Y');
var WK=['일','월','화','수','목','금','토'];
var _y=0, _m=0;            /* 보고 있는 달 (m = 0~11) */
var _rows=[], _todo=[];    /* 전체 일정(달력·「이 달」·「전체」가 여기서 고른다) · 그중 미완료 */
var _tab='todo', _seq=0, _dirty=false, _noTable=false;   /* 처음 탭 = 미완료 (2026-11-19 사용자 「미완료 기본으로」 · 「이 달」 탭은 달력과 겹쳐 뺐다 — 「이 달은 중복이라 제거」) */

function gel(id){ return document.getElementById(id); }
function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function p2(v){ return (v<10?'0':'')+v; }
function ymd(d){ return ''+d.getFullYear()+p2(d.getMonth()+1)+p2(d.getDate()); }
function d10(s){ s=String(s||''); return s.length>=8 ? s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8) : ''; }
function d8(s){ return String(s||'').replace(/[^0-9]/g,'').slice(0,8); }
function toDate(s){ return new Date(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8)); }
function dTxt(s){ var d=toDate(s); return (d.getMonth()+1)+'/'+d.getDate()+'('+WK[d.getDay()]+')'; }
function today(){ return ymd(new Date()); }
function lTxt(v){ return ((_tab!=='mon' && v.slice(0,4)!==String(new Date().getFullYear())) ? v.slice(2,4)+'/' : '')+dTxt(v); }   /* 목록의 날짜 — 올해가 아니면 연도 두 자리 */
function dayGap(a,b){ return Math.round((toDate(b).getTime()-toDate(a).getTime())/86400000); }
function busy(on){ gel('busy').classList.toggle('on', !!on); }
function alertBox(m){ if(window._alertBox) _alertBox(m,{icon:'⚠️'}); else alert(String(m).replace(/<[^>]*>/g,'')); }
function toast(m,t){ if(window._toast) _toast(m,t||'ok'); }
function noTable(on){ _noTable=!!on; gel('noTable').style.display=on?'':'none'; }

/* 서버 호출 — 오류(error)는 던진다. 표가 없으면(noTable) 안내 띠를 켠다 */
function done(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json().then(function(j){
  if(j && j.noTable==='Y') noTable(true);
  if(!j || j.error) throw new Error((j&&j.error)||'처리하지 못했습니다'); return j; }); }
function postForm(url, o){ var b=[]; for(var k in o) b.push(encodeURIComponent(k)+'='+encodeURIComponent(o[k]==null?'':o[k]));
  return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:b.join('&') }).then(done); }
function postJson(url, o){ return fetch(CTX+url,{ method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/json'}, body:JSON.stringify(o) }).then(done); }

/* ── 달 ── */
function gridRange(){ var f=new Date(_y,_m,1), l=new Date(_y,_m+1,0);
  var a=new Date(_y,_m,1-f.getDay()), b=new Date(_y,_m+1,0+(6-l.getDay())); return { a:a, b:b, weeks:Math.round((b.getTime()-a.getTime())/86400000+1)/7 }; }
function monGo(d){ var x=new Date(_y,_m+d,1); _y=x.getFullYear(); _m=x.getMonth(); load(); }
function monToday(){ var t=new Date(); _y=t.getFullYear(); _m=t.getMonth(); load(); }
function monOf(s){ var a=''+_y+p2(_m+1)+'01', b=ymd(new Date(_y,_m+1,0)); return s.toDt>=a && s.fromDt<=b; }   /* 이 달과 겹치는가 */

function load(){
  gel('ymTxt').textContent=_y+'년 '+(_m+1)+'월';
  if(!ADMIN) return;
  /* ★전부 한 번에 읽는다 (2026-11-19 「전체」 탭 추가) — 종전엔 달력 범위 + 미완료 두 번을 불렀다. 목록에는 내용(HTML)이 실려 오지 않아 줄이 많아도 가볍다.
       달력은 날짜로, 「이 달」은 monOf 로, 「미완료」는 완료 여부로 여기서 고른다 */
  busy(true);
  postForm('/mangr/ceoSchedList.do',{ frDt:'00000101', toDt:'99991231' })
    .then(function(r){ _rows=r.data||[]; _todo=_rows.filter(isOpen); noTable(false); busy(false); paint(); loadContents(); loadDels();
      try{ if(window.parent && window.parent!==window && typeof window.parent.konetCeoBadge==='function') window.parent.konetCeoBadge(); }catch(e){}   /* 메뉴 옆 «지난 미완료» 건수도 같이 (2026-11-19) */
    })
    .catch(function(e){ busy(false); _rows=[]; _todo=[]; paint(); if(!_noTable) alertBox(esc(e.message)); });
}
/* ★상태 셋 (2026-11-19 사용자 「완료, 일부완료, 일정취소로 구분해줘요」 → 곧바로 「완료 , 일정취소 만」) — DB 칸은 종전 DONE_YN(CHAR 1) 그대로 : N 미완료 · Y 완료 · C 일정취소.
   ★표시하는 상태는 「완료」「일정취소」 둘뿐이고 아무것도 안 고른 것(N)은 빈 칸이다(같은 날 사용자 「완료·일정취소, 아무것도 없는 것으로 세 가지」) —
   「미완료」는 그 빈 것들을 탭·합계에서 묶어 부르는 이름으로만 남는다.
   아무것도 없는 것(isOpen)만 「미완료」 탭 · 지난 미완료 · 메뉴 옆 숫자에 든다. 완료 · 일정취소는 끝난 것 — 흐리게 줄 긋는다 */
var ST={ N:{ nm:'', ic:'☐' }, Y:{ nm:'완료', ic:'☑' }, C:{ nm:'취소', ic:'✕' } }, ST_KEYS=['Y','C','N'];   /* N = 아무것도 없음(표시 글 없음) · 상태 칸 차례 = 완료 / 취소 / - (2026-11-19 사용자 「공백 제일 밑으로」 — 그 전 「- / 완료 / 취소」, 잠깐 「완료 / - / 취소」) */
function stKey(s){ return (s && ST[s.doneYn]) ? s.doneYn : 'N'; }
function isOpen(s){ return stKey(s)==='N'; }
function late(s){ return isOpen(s) && s.toDt<today(); }
function paint(){ paintCal(); paintList(); }

/* ══ 내용 줄 (2026-11-19 사용자 「제목 필요 없고 업무일지 내용처럼 · 이 내용 완료·일정취소 — 한 텍스트로 저장하지만 · 검색은 내용으로」) ══
     schedLines(html) = 편집기 글(HTML)을 «보이는 줄»로 나눈다 — 블록(div·p·li …) 경계와 br 에서 끊고 빈 줄은 뺀다.
       줄마다 그 줄을 이루는 글자 마디(nodes)를 들고 있어, 줄 상태를 바꿀 때 그 줄의 마지막 글자 마디 끝만 고친다(서식은 그대로).
     줄 상태 = 줄 끝 글자 : 「 완료」 · 「 일정취소」(괄호 [완료] (완료) 도) — 앞에 띄어쓰기나 괄호가 있어야 한다(「검수완료」는 상태 아님) */
var LN_MK=/(?:\s+|\s*[\[(])(완료|(?:일정\s?)?취소)\s*[\])]?\s*$/, LN_BLK=/^(P|DIV|LI|H1|H2|H3|H4|BLOCKQUOTE|TR|TD|TH|PRE|UL|OL|TABLE|HR)$/;
var LN_NUM=/^(\d{1,3})([.)])(?!\d)\s*/;   /* 「1. 」 「2)」 — 「11.19」처럼 점 뒤가 숫자면 번호가 아니다 */
var LN_ST={ N:{ ic:'\u00a0', nm:'' }, Y:{ ic:'✓', nm:'완료' }, C:{ ic:'✕', nm:'취소' } }, LN_NEXT={ N:'Y', Y:'C', C:'N' };
function lnMark(t){ var m=LN_MK.exec(t||''); if(!m) return { st:'N', body:String(t||'') }; return { st:(m[1]==='완료'?'Y':'C'), body:String(t).slice(0, m.index) }; }
function schedLines(html){
  var doc=new DOMParser().parseFromString('<body>'+String(html==null?'':html)+'</body>','text/html'), out=[], cur=null;
  function flush(){ if(cur) out.push(cur); cur=null; }
  (function walk(n){ [].slice.call(n.childNodes).forEach(function(c){
    if(c.nodeType===3){ if(!cur) cur={ txt:'', nodes:[], pre:'' }; cur.txt+=c.nodeValue; cur.nodes.push(c); return; }
    if(c.nodeType!==1) return;
    var t=c.tagName;
    if(t==='BR'){ flush(); return; }
    if(t==='LI'){ flush(); var p=c.parentNode; cur={ txt:'', nodes:[], pre:((p && p.tagName==='OL') ? (([].filter.call(p.children, function(x){ return x.tagName==='LI'; }).indexOf(c))+1)+'. ' : '• ') }; walk(c); flush(); return; }
    var blk=LN_BLK.test(t); if(blk) flush(); walk(c); if(blk) flush();
  }); })(doc.body);
  flush();
  var lines=[];
  out.forEach(function(l){ var tx=l.txt.replace(/\u00a0/g,' ').replace(/\s+/g,' ').trim(); if(!tx) return;
    var m=lnMark(tx); lines.push({ i:lines.length, txt:tx, body:(l.pre+m.body).trim(), st:m.st, nodes:l.nodes }); });
  return { doc:doc, lines:lines };
}
/* 한 일정의 보여 줄 줄 — 내용이 있으면 그 줄, 없으면(옛 일정) 제목 한 줄. 내용을 아직 못 읽었으면 제목을 잠깐(칩 없이) */
function linesOf(s){
  if(s._ln && s._lnSrc===s.content) return s._ln;
  var L=null;
  if(s.content) L=schedLines(s.content).lines.map(function(l){ return { i:l.i, body:l.body, st:l.st, h:l }; });
  if(L && L.length){ var anyNo=false;
    L.forEach(function(l){ var m=LN_NUM.exec(l.body); if(m){ l.no=m[1]+(m[2]===')'?')':'.'); l.rest=l.body.slice(m[0].length); anyNo=true; }
      if(l.h){ l.html=lnFmt(l.h, !!m); delete l.h; } });
    if(anyNo) L.forEach(function(l){ if(!l.no) l.hd=true; });   /* 번호 매긴 줄이 있으면 번호 없는 줄 = 묶음 머리(「삼성미팅」) */
  }
  if(!L || !L.length){
    if(s.hasContent==='Y' && s.content==null) L=[{ i:-1, body:(s.title||'')+' ...', st:'N' }];
    else { var m=lnMark(s.title||''); L=[{ i:0, body:(m.body.trim()||s.title||''), st:m.st }]; }
  }
  s._ln=L; s._lnSrc=s.content; return L;
}
/* 「N건」 — 번호 매긴 줄 수(없으면 줄 수). 끝난 줄(완료·일정취소)은 따로 센다 */
function cntOf(s){ var L=linesOf(s), it=L.filter(function(l){ return !l.hd && l.i>=0; }), d=it.filter(function(l){ return l.st!=='N'; }).length;
  return { n:it.length, d:d }; }
function cntHtml(s){ var c=cntOf(s); if(!c.n) return ''; return '<span class="cnt" title="번호 매긴 줄 '+c.n+'건'+(c.d?' · 그중 완료·취소 '+c.d+'건':'')+'">'+c.n+'건'+(c.d?' <i>· 끝 '+c.d+'</i>':'')+'</span>'; }
/* ★줄의 서식 (2026-11-19 사용자 「이렇게 한 것 밖에도 이렇게 보이게」 — 편집기에서 칠한 빨간 글·크기·굵게·밑줄·취소선·형광펜을 달력·목록에도) —
     그 줄의 글자 마디마다 위로 올라가며 글 모양 태그(b·i·u·s·span·font …)와 그 줄 블록(div·p)의 글 모양 스타일을 모아 다시 씌운다.
     남기는 것 = 굵게·기울임·밑줄·취소선·위첨자·아래첨자 + 스타일 몇 가지(색·형광펜·크기·글꼴·굵기·기울임·줄 장식)만. 링크·정렬·여백은 버린다.
     번호(「1. 」)는 번호 칸에 따로 쓰므로 첫 글자 마디에서 떼고, 줄 끝 「완료」·「일정취소」는 꼬리표로 붙으므로 마지막 마디에서 뗀다 */
var LN_TAG={ B:'b', STRONG:'b', I:'i', EM:'i', U:'u', S:'s', STRIKE:'s', SUB:'sub', SUP:'sup', SPAN:'span', FONT:'span', A:'span', H1:'b', H2:'b', H3:'b', H4:'b' };
var LN_CSS=['color','background-color','font-size','font-family','font-weight','font-style','text-decoration-line'];
function lnCss(el){ var st=el.style, out=[]; if(!st) return '';
  LN_CSS.forEach(function(p){ var v=String(st.getPropertyValue(p)||'').replace(/"/g,"'"); if(v && !/url\(|expression|javascript:|[<>]/i.test(v) && !/^(initial|inherit|unset|transparent)$/i.test(v)) out.push(p+':'+v); });
  if(el.tagName==='FONT'){ var c=el.getAttribute('color'); if(c && /^#?[0-9A-Za-z]+$/.test(c)) out.push('color:'+c); }
  return out.join(';'); }
function lnFmt(l, numbered){
  var nodes=l.nodes||[], first=-1, last=-1, k;
  for(k=0;k<nodes.length;k++) if(/\S/.test(String(nodes[k].nodeValue).replace(/\u00a0/g,' '))){ if(first<0) first=k; last=k; }
  if(first<0) return '';
  var html='';
  for(k=first;k<=last;k++){
    var t=String(nodes[k].nodeValue).replace(/\u00a0/g,' ');
    if(k===first){ t=t.replace(/^\s+/,''); if(numbered) t=t.replace(LN_NUM,''); }
    if(k===last){ if(l.st!=='N'){ var m=LN_MK.exec(t); if(m) t=t.slice(0,m.index); } t=t.replace(/\s+$/,''); }
    var h=esc(t), el=nodes[k].parentNode;
    while(el && el.nodeType===1 && el.tagName!=='BODY'){
      var tg=el.tagName, blk=LN_BLK.test(tg) || tg==='LI';
      var css=lnCss(el), w=LN_TAG[tg];
      if(blk){ if(css) h='<span style="'+esc(css)+'">'+h+'</span>'; if(/^H[1-4]$/.test(tg)) h='<b>'+h+'</b>'; break; }
      if(w){ if(w==='span'){ if(css) h='<span style="'+esc(css)+'">'+h+'</span>'; } else h='<'+w+(css?' style="'+esc(css)+'"':'')+'>'+h+'</'+w+'>'; }
      el=el.parentNode;
    }
    html+=h;
  }
  return html;
}
function lnText(s){ return linesOf(s).map(function(l){ return l.body+(l.st!=='N'?' '+LN_ST[l.st].nm:''); }).join('\n'); }
function hiTxt(t, q){ var e=esc(t); if(!q) return e; var i=String(t).toLowerCase().indexOf(q); if(i<0) return e;
  return esc(t.slice(0,i))+'<mark>'+esc(t.slice(i,i+q.length))+'</mark>'+esc(t.slice(i+q.length)); }
/* ★open = 「미완료」 탭 — 끝난 줄(완료·취소)은 숨긴다 (2026-11-20 사용자 「오른쪽 미완료를 줄 단위(끝난 줄 숨김)」 — 달력은 «그 날 전체», 오른쪽은 «남은 일»).
     묶음 머리(번호 없는 「삼성미팅」)는 그 밑에 남은 줄이 있을 때만 보인다. 숨긴 줄 수는 openLines 가 같이 돌려준다(목록이 「끝난 n줄 숨김」으로 적는다).
     ⚠줄 번호(l.i)는 그대로라 칩을 눌러도 원래 줄이 바뀐다 — 누른 줄은 끝난 줄이 되어 다음 그리기에서 사라진다. */
function openLines(s){
  var L=linesOf(s), keep=[], hid=0, hd=null;
  L.forEach(function(l){
    if(l.hd){ hd=l; return; }
    if(l.i>=0 && l.st!=='N'){ hid++; return; }
    if(hd){ keep.push(hd); hd=null; }
    keep.push(l);
  });
  return { lines:keep, hid:hid };
}
function linesHtml(s, q, ro, open){   /* ro = 읽기만(삭제 탭 — 칩을 눌러도 안 바뀐다) · open = 끝난 줄 숨김(미완료 탭) */
  return (open ? openLines(s).lines : linesOf(s)).map(function(l){
    var tip=(l.i<0 ? '내용을 읽는 중입니다' : (l.st==='N' ? '이 줄 상태 없음 — 누르면 완료' : (l.st==='Y' ? '완료 — 누르면 취소' : '취소 — 누르면 상태를 지웁니다')));
    /* ★묶음 머리(번호 없는 줄 「삼성미팅」)는 할 일이 아니라 칩이 없다 (2026-11-19 사용자 그림 — 머리 줄이 완료로 찍혀 있었다). 이미 상태가 붙은 머리만 칩을 보여 주고, 누르면 바로 지운다 */
    var hdNo=(l.hd && l.st==='N'), act=(!ro && l.i>=0 && !hdNo);
    if(l.hd && l.st!=='N') tip='묶음 제목에 붙은 '+LN_ST[l.st].nm+' — 누르면 지웁니다';
    return '<div class="ln l'+l.st+((l.i<0||hdNo)?' nock':'')+(l.hd?' hd':'')+'"><span class="ck"'+(act?' title="'+tip+'" onclick="lnSet('+s.schedSeq+','+l.i+',event'+(l.hd?",'N'":'')+')"':'')+'>'+LN_ST[l.st].ic+'</span>'
      +(l.no?'<span class="no">'+esc(l.no)+'</span>':'')+'<span class="lt">'+((l.html && !q) ? l.html : hiTxt(l.no?l.rest:l.body, q))+(l.st!=='N'?' <span class="tag '+(l.st==='C'?'cx':'ok')+'" style="margin-left:2px">'+LN_ST[l.st].nm+'</span>':'')+'</span></div>'; }).join('');
}
/* 줄 상태를 바꾼 HTML — 그 줄의 마지막 글자 마디 끝 글자만 고친다(다른 줄·서식은 그대로) */
function lnApply(html, idx, st){
  var P=schedLines(html), l=P.lines[idx]; if(!l) return null;
  var tn=null; for(var k=l.nodes.length-1;k>=0;k--){ if(/\S/.test(String(l.nodes[k].nodeValue).replace(/\u00a0/g,' '))){ tn=l.nodes[k]; break; } }
  if(!tn) return null;
  var v=String(tn.nodeValue), m=LN_MK.exec(v.replace(/\u00a0/g,' '));
  if(m) v=v.slice(0, m.index); else v=v.replace(/[\s\u00a0]+$/,'');
  if(st!=='N') v+=' '+LN_ST[st].nm;
  tn.nodeValue=v;
  return clean(P.doc.body.innerHTML);
}
function titleOf(html){ var L=schedLines(html).lines; return L.length ? L[0].body.slice(0,200) : ''; }
/* 줄 앞 칩 — 그때 내용을 서버에서 새로 읽어 그 줄 끝 글자만 고친 뒤 통째로 저장한다(일정 전체 상태·일자·장소는 그대로) */
/* 줄이 전부 끝났으면 일정 상태 — 전부 취소면 C, 하나라도 완료면 Y, 남은 줄이 있으면 null.
     세는 줄 = 할 일 줄(번호 매긴 줄이 있으면 번호 줄만 — 묶음 머리 「삼성미팅」은 할 일이 아니다). 줄이 하나도 없으면 null.
     ⚠미완료(빈칸) 일정에만 쓴다 — 완료·취소 일정에서 줄 하나를 되돌려도 일정 상태는 그대로(2026-11-19 「위는 전체 적용, 아래는 개별 수정」) */
function autoSt(html){
  var L=linesOf({ schedSeq:0, content:html, hasContent:'Y' }).filter(function(l){ return !l.hd && l.i>=0; });
  if(!L.length || L.some(function(l){ return l.st==='N'; })) return null;
  return L.every(function(l){ return l.st==='C'; }) ? 'C' : 'Y';
}
function lnSet(seq, idx, ev, to){   /* to = 바꿀 상태를 정해 줄 때(묶음 머리 → N). 없으면 차례대로 */
  if(ev) ev.stopPropagation();
  var r=rowOf(seq); if(!r) return;
  busy(true);
  postForm('/mangr/ceoSchedGet.do',{ schedSeq:seq }).then(function(j){
    var d=j.data||{}, html=d.content||'';
    if(!schedLines(html).lines.length && d.title) html='<div>'+esc(d.title)+'</div>';   /* 내용이 없는 옛 일정 — 제목을 첫 줄로 옮겨 그 줄에 표시 */
    var L=schedLines(html).lines; if(!L[idx]) throw new Error('그 줄을 찾지 못했습니다 — 다른 곳에서 내용이 바뀌었을 수 있습니다. 화면을 다시 읽습니다.');
    var nx=(to && LN_ST[to]) ? to : LN_NEXT[L[idx].st], nh=lnApply(html, idx, nx); if(nh==null) throw new Error('그 줄을 고치지 못했습니다.');
    var st0=stKey(d), au=(st0==='N') ? autoSt(nh) : null;   /* ★마지막 남은 줄을 끝내면 일정도 저절로 (2026-11-20 사용자 「이것도 헷갈림」 — 「남은 줄이 없습니다 …」 안내) */
    var body={ schedSeq:seq, fromDt:d.fromDt, toDt:d.toDt||d.fromDt, schedTm:d.schedTm||'', title:(titleOf(nh)||d.title||''), place:d.place||'', content:nh, doneYn:(au||st0) };
    return postJson('/mangr/ceoSchedSave.do', body).then(function(){
      busy(false); r.content=nh; r.title=body.title; r.hasContent='Y'; r._ln=null;
      if(au){ load(); return; }   /* 상태가 바뀌면 미완료 목록·건수·메뉴 숫자까지 다시 */
      paint();
      /* 줄 상태 알림은 띄우지 않는다 (2026-11-19 사용자 「줄 완료 알림도 제거」) — 칩 모양이 바로 바뀐다 */
    });
  }).catch(function(e){ busy(false); alertBox(esc(e.message)); load(); });
}
/* 옛 서버(목록에 내용이 안 실려 오는 판)면 내용 있는 일정만 한 건씩 읽어 채운다 — 새 서버면 할 일이 없다 */
function loadContents(){
  var need=_rows.filter(function(s){ return s.hasContent==='Y' && s.content==null; });
  if(!need.length) return;
  gather(need).then(function(map){ need.forEach(function(s){ if(map[s.schedSeq]!=null){ s.content=map[s.schedSeq]; s._ln=null; } }); paint(); }).catch(function(){});
}
function paintCal(){
  var g=gridRange(), t=today(), h='', d=new Date(g.a.getTime()), wkHas=[], colHas=[];
  for(var i=0;i<g.weeks*7;i++){
    var k=ymd(d), dow=d.getDay(), out=(d.getMonth()!==_m);
    var ev=_rows.filter(function(s){ return s.fromDt<=k && s.toDt>=k; }).sort(function(a,b){ return (a.schedTm||'99')<(b.schedTm||'99')?-1:((a.schedTm||'99')>(b.schedTm||'99')?1:a.schedSeq-b.schedSeq); });
    if(ev.length){ wkHas[Math.floor(i/7)]=true; colHas[i%7]=true; }
    h+='<div class="dc'+(out?' out':'')+(dow===0?' sun':'')+(dow===6?' sat':'')+(k===t?' tdy':'')+'" data-k="'+k+'" onclick="dayOpen(\''+k+'\')" title="'+d10(k)+(ev.length ? ' — 칸 어디를 눌러도 이 날짜 일정을 엽니다' : ' — 누르면 이 날짜로 새 일정')+'">'
      +'<span class="dn">'+d.getDate()+'</span>'
      + ev.map(function(s){ var k=stKey(s), cls=(k==='Y'?' done':(k==='C'?' cancel':(late(s)?' late':'')));
          var eh=(s.schedTm||'')+(s.place?(s.schedTm?' · ':'')+s.place:'');
          /* ★상태 칸 (2026-11-19 사용자 「상태 표시」) — 달력에도 목록과 같은 상태 칸(- / 완료 / 취소). 고르면 목록과 똑같이 아래 줄 전부에 적용(doneSet). 칸을 눌러도 창은 안 열린다 */
          var sel='<select class="st st'+k+'" onclick="event.stopPropagation()" onmousedown="event.stopPropagation()" onchange="doneSet('+s.schedSeq+', this.value, event)" title="일정 상태 — 고르면 아래 줄 전부에 같은 표시">'
            +stOpts(k)+'</select>';
          return '<div class="ev lns'+cls+'" onclick="edOpen('+s.schedSeq+',null,event)" title="'+esc((eh?eh+'\n':'')+lnText(s))+'\n(글자를 누르면 고치기 · 줄 앞 칩은 그 줄 완료·취소)">'
          +'<div class="eh">'+sel+cntHtml(s)+'<span class="et">'+esc(eh)+'</span></div>'+linesHtml(s, '')+'</div>'; }).join('')
      +'</div>';
    d.setDate(d.getDate()+1);
  }
  calRows(g.weeks, wkHas, colHas); gel('cal').innerHTML=h; calHdSync();
  /* 머리의 요일 — 오늘이 든 달을 보고 있으면 오늘 요일에 동그라미 */
  var now=new Date(), cur=(now.getFullYear()===_y && now.getMonth()===_m);
  [].forEach.call(gel('calHd').children, function(e, i){ e.classList.toggle('tdy', cur && i===now.getDay()); });
}
/* 주 줄 높이 = 바닥(달력 높이 ÷ 주 수) ~ 내용만큼. 창 크기가 바뀌면 바닥을 다시 잰다 */
var _weeks=6;
/* ★일정이 있는 주 = 내용 높이 딱 그만큼 · 남는 높이는 빈 주에만 나눈다 (2026-11-19 사용자 「제일 큰 경우 입력한 곳까지 — 지금은 하단 공간 있음」)
   — 종전엔 남는 높이를 모든 주에 고르게 나눠 일정 있는 주 밑에도 빈 자리가 생겼다. 일정이 하나도 없는 달은 종전처럼 모든 주가 고르게 화면을 채운다 */
/* ★옆으로도 같은 규칙 (2026-11-19 사용자 「옆으로도 내용 있는 칸만 그만큼 넓게」) — 일정이 있는 요일 = 내용 폭 딱 그만큼, 남는 폭은 빈 요일에만 */
var _wkHas=[], _colHas=[];
function calRows(w, has, col){ if(w) _weeks=w; if(has) _wkHas=has; if(col) _colHas=col;
  var any=_wkHas.some(Boolean), a=[], b=[];
  for(var i=0;i<_weeks;i++) a.push((any && _wkHas[i]) ? 'max-content' : 'minmax(max-content, auto)');
  for(var j=0;j<7;j++) b.push((any && _colHas[j]) ? 'max-content' : 'minmax(max-content, auto)');
  var c=gel('cal'); c.style.gridTemplateRows=a.join(' '); c.style.gridTemplateColumns=b.join(' '); }   /* 줄 = 내용 크기 이상, 남는 높이는 고르게 (빈 주는 최소) */   /* 칸마다 바닥 높이(--dch) + 줄 = max-content — minmax(바닥, auto)·auto 는 달력 높이가 정해져 있으면 바닥 이상 자라지 않아 글이 다음 주 칸 위로 넘쳤다(헤드리스 실측) */
/* 요일 머리줄 = 달력 칸 폭 그대로(px) + 좌우 스크롤 따라가기 */
function calHdSync(){ var c=gel('cal'), hd=gel('calHd'); if(!c || !hd) return;
  var cols=getComputedStyle(c).gridTemplateColumns; if(cols && cols!=='none') hd.style.gridTemplateColumns=cols;
  hd.style.paddingRight=(c.offsetWidth-c.clientWidth)+'px'; hd.scrollLeft=c.scrollLeft; }
window.addEventListener('resize', function(){ calRows(); calHdSync(); });
/* ★날짜 칸의 빈 곳 = 그 날짜 일정 열기 (2026-11-19 사용자 「입력 공간 아닌 곳을 클릭해도 해당 일자 전체 — 같은 날짜는 한꺼번에 입력하므로」) —
   종전엔 빈 곳을 누르면 늘 새 일정이었다. 이제 그 날짜에 일정이 있으면 그 일정을 연다(여럿이면 그 날 시작한 것 → 시간 이른 것 → 먼저 등록한 것).
   그 날짜에 일정이 없을 때만 새 일정. ([＋ 일정 등록] 단추는 같은 날 사용자 「의미 없음」으로 뺐다 — 같은 날은 한 일정에 이어 쓴다) */
function dayOpen(k){
  var ev=_rows.filter(function(s){ return s.fromDt<=k && s.toDt>=k; });
  if(!ev.length){ edOpen(0, k); return; }
  ev.sort(function(a,b){ var fa=(a.fromDt===k?0:1), fb=(b.fromDt===k?0:1); if(fa!==fb) return fa-fb;
    var ta=a.schedTm||'99', tb=b.schedTm||'99'; return ta<tb?-1:(ta>tb?1:a.schedSeq-b.schedSeq); });
  edOpen(ev[0].schedSeq);
}
/* 로그인 창 «지난 미완료» 며칠 전까지 (2026-11-19 사용자 「며칠 전까지 메세지 처리인지 설정」 → 「설정은 여기서 · 숫자로 치게 · 0이면 안 뜸」) —
   emp-badge.js 로그인 창과 같은 localStorage('konetCeoLateDays2') · 비우면 = 전부(키를 지움) · 0 = 안 띄움 · n = n일 전까지(365 상한) */
/* ★기본 = 0 (같은 날 사용자 「기본 0으로」) — 설정이 없거나 비우면 0 = 로그인 때 창을 안 띄움. n = n일 전까지(365 상한) */
function lateDaysGet(){ var v=null; try{ v=localStorage.getItem('konetCeoLateDays2'); }catch(e){} var n=parseInt(v==null?'':v,10); return String((isNaN(n)||n<0) ? 0 : Math.min(n,365)); }
function lateDaysTip(v){ var el=gel('lateDaysTip'); if(!el) return; el.textContent=(+v>0 ? '' : '(지난 건 안 보임)'); }
function lateDaysSet(v){ v=String(v==null?'':v).trim(); var n=parseInt(v,10); n=(isNaN(n)||n<0) ? 0 : Math.min(n,365);
  try{ localStorage.setItem('konetCeoLateDays2', String(n)); }catch(e){}
  lateDaysTip(String(n)); }
function tabGo(t){ _tab=t; paintList(); gel('list').scrollTop=0; }
/* ★기간 조건 + 맨 위 요약 (2026-11-20 사용자 「기간 조건이랑 맨 위 요약도 해줘」) — 한 줄 칩 : [전체 n] [지남 n] [오늘 n] [이번 주 n] [이후 n].
     숫자 = 지금 탭(미완료/전체) + 검색에 걸린 일정을 기간별로 센 것(요약) · 누르면 그 기간만(조건) · 다시 누르면 전체. 삭제 탭엔 없다.
     기간은 일정 날짜로 가른다(겹치지 않게) : 지남 = 끝나는 날 < 오늘 · 오늘 = 오늘이 그 기간 안 · 이번 주 = 내일 ~ 이번 주 토요일에 시작 · 이후 = 다음 주 일요일부터.
     ★「이번 주」 = 달력 주(일~토 — 달력 머리와 같은 차례) (2026-11-20 사용자 「이번 주로 바꿔줘」 — 같은 날 처음엔 «내일 ~ 6일 뒤»(7일 안)였다). 토요일이면 이번 주 칩은 0 이다.
     「전체」를 보고 있으면 목록에 기간 머리(지남 · 오늘 · 이번 주 · 이후)를 끼워 묶어 보인다. 엑셀·인쇄도 같은 목록(curList)이라 기간이 따라간다 */
var _per='', PERS=[['late','지남'],['tdy','오늘'],['wk','이번 주'],['aft','이후']];
function perOf(s, t){ t=t||today(); if(s.toDt<t) return 'late'; if(s.fromDt<=t) return 'tdy'; var d0=toDate(t), w=ymd(new Date(d0.getFullYear(), d0.getMonth(), d0.getDate()+(6-d0.getDay()))); return s.fromDt<=w ? 'wk' : 'aft'; }   /* w = 이번 주 토요일 */
function perNm(k){ for(var i=0;i<PERS.length;i++) if(PERS[i][0]===k) return PERS[i][1]; return '전체'; }
function perGo(k){ _per=(_per===k ? '' : k); paintList(); gel('list').scrollTop=0; }
function paintPers(base){
  var el=gel('pers'); if(!el) return;
  if(_tab==='del'){ el.innerHTML=''; return; }
  var t=today(), c={ late:0, tdy:0, wk:0, aft:0 }; base.forEach(function(s){ c[perOf(s,t)]++; });
  var tip={ '':'기간 상관없이 전부', late:'끝나는 날이 지난 일정', tdy:'오늘 하는 일정(여러 날 걸친 것 포함)', wk:'내일부터 이번 주 토요일까지 시작하는 일정(주 = 일~토)', aft:'다음 주 일요일부터 시작하는 일정' };
  el.innerHTML=[['','전체']].concat(PERS).map(function(p){ var n=p[0] ? c[p[0]] : base.length;
    return '<span class="per'+(_per===p[0]?' on':'')+(p[0]==='late'&&n&&_tab==='todo'?' lt':'')+(!n&&p[0]?' z':'')+'" onclick="perGo(\''+p[0]+'\')" title="'+tip[p[0]]+(_tab==='todo'?' — 미완료만':'')+'">'+p[1]+' <b>'+n+'</b></span>'; }).join('');
}
/* ★목록의 날짜 → 달력 그 달·그 날 (2026-11-20 사용자 「날짜 누르면 달력 이동도 해줘」) — 창은 열지 않는다(날짜 글자 밖을 누르면 종전대로 창).
     일정은 load 가 전부 읽어 두므로 달만 바꿔 다시 그린다(서버를 다시 부르지 않는다). 그 날 칸으로 굴리고 잠깐 노랗게 · 오른쪽 목록·탭·검색은 그대로 */
var _flashT=null;
function calGo(k, ev){
  if(ev){ ev.stopPropagation(); ev.preventDefault(); }
  k=d8(k); if(k.length!==8) return;
  var y=+k.slice(0,4), m=+k.slice(4,6)-1;
  if(y!==_y || m!==_m){ _y=y; _m=m; gel('ymTxt').textContent=_y+'년 '+(_m+1)+'월'; paint(); }
  var c=document.querySelector('#cal .dc[data-k="'+k+'"]'); if(!c) return;
  try{ c.scrollIntoView({ block:'nearest', inline:'nearest' }); }catch(e){}
  [].forEach.call(document.querySelectorAll('#cal .dc.flash'), function(e){ e.classList.remove('flash'); });
  void c.offsetWidth; c.classList.add('flash'); clearTimeout(_flashT); _flashT=setTimeout(function(){ c.classList.remove('flash'); }, 1800);
}
function paintList(){
  var q=gel('q').value.trim().toLowerCase(), t=today();
  var mon=_rows.filter(monOf), nLate=_todo.filter(late).length, cnt={ N:0, Y:0, C:0 }; mon.forEach(function(s){ cnt[stKey(s)]++; });
  gel('tabTodo').classList.toggle('on', _tab==='todo'); gel('tabAll').classList.toggle('on', _tab==='all'); gel('tabDel').classList.toggle('on', _tab==='del');
  gel('delCnt').textContent=(_dels ? _dels.length : '-');
  gel('todoCnt').textContent=_todo.length; gel('todoCnt').className=nLate?'late':''; gel('allCnt').textContent=_rows.length;
  gel('sumTxt').innerHTML='이 달 <b>'+mon.length+'</b>건 · 완료 <b>'+cnt.Y+'</b>'+(cnt.C?' · 취소 <b>'+cnt.C+'</b>':'')+' · 미완료 <b>'+cnt.N+'</b>'+(nLate?' &nbsp;|&nbsp; 지난 미완료 <b class="late">'+nLate+'</b>건':'');
  var list=curList();   /* 탭 + 검색 + 기간 + 차례 — 엑셀·인쇄와 같은 목록 */
  if(_tab!=='del'){ curList.base=curList.base||list; } paintPers(_tab==='del' ? [] : (curList.base||list));
  if(_tab==='del'){ paintDel(list, q); return; }
  if(!list.length && _per){ gel('list').innerHTML='<div class="empty">「'+perNm(_per)+'」에 '+(_tab==='todo'?'끝내지 않은 ':'')+'일정이 없습니다.'+(q?'<br>(검색 「'+esc(gel('q').value.trim())+'」)':'')+'<br><a href="javascript:void(0)" onclick="perGo(\'\')">전체 보기</a></div>'; return; }
  if(!list.length){ gel('list').innerHTML='<div class="empty">'+(q?'검색에 맞는 일정이 없습니다.':(_tab==='todo'?'끝내지 않은 일정이 없습니다 👍':((_tab==='all'?'등록된 일정이 없습니다.':'이 달에 등록된 일정이 없습니다.')+'<br>달력의 날짜 칸을 누르면 그 날짜로 새 일정을 씁니다.')))+'</div>'; return; }
  var pg='', t9=today(), pcnt={}; if(!_per) list.forEach(function(s){ var p=perOf(s,t9); pcnt[p]=(pcnt[p]||0)+1; });
  gel('list').innerHTML=list.map(function(s){
    var hd=''; if(!_per){ var p=perOf(s,t9); if(p!==pg){ pg=p; hd='<div class="pgh'+(p==='late'&&_tab==='todo'?' lt':'')+'">'+perNm(p)+' <b>'+pcnt[p]+'</b></div>'; } }   /* 기간 머리 — 「전체」를 볼 때만 */
    var k=stKey(s), tag='';
    if(k==='Y' || k==='C') tag='<span class="tag ok" title="'+ST[k].nm+'(으)로 바꾼 때">'+ST[k].nm+(s.doneDttm?' '+esc(s.doneDttm.slice(5,16)):'')+'</span>';
    else if(s.toDt<t) tag='<span class="tag late">'+dayGap(s.toDt,t)+'일 지남</span>';
    else if(s.fromDt<=t) tag='<span class="tag tdy">오늘</span>';
    return hd+'<div class="it'+(k==='Y'?' done':(k==='C'?' cancel':(late(s)?' late':'')))+'" onclick="edOpen('+s.schedSeq+')"><div class="ih">'
      +'<select class="st st'+k+'" onclick="event.stopPropagation()" onchange="doneSet('+s.schedSeq+', this.value, event)" title="'+(k==='N'?'상태 없음 — 눌러서 완료 · 취소를 고릅니다':'상태 — 눌러서 바꿉니다( - 를 고르면 지워집니다)')+'">'
        +stOpts(k)+'</select>'
      +'<div class="t2">'+cntHtml(s)+'<b class="dgo" onclick="calGo(\''+s.fromDt+'\', event)" title="달력에서 '+d10(s.fromDt)+' 보기">'+lTxt(s.fromDt)+(s.toDt!==s.fromDt?' ~ '+lTxt(s.toDt):'')+'</b>'+(s.schedTm?' '+esc(s.schedTm):'')+(s.place?' · '+esc(s.place):'')+tag+'</div>'
      +'<button type="button" class="rowdel" onclick="rowDel('+s.schedSeq+', event)" title="'+(k==='Y'?'완료한 일정 — 상태를 취소로 바꾼 뒤 지울 수 있습니다':'이 일정을 지웁니다')+'">🗑</button></div>'
      +(function(x){ return x ? '<div class="lw">'+x+'</div>' : ''; })(lwHtml(s, q))+'</div>';   /* 내용이 비면 판도 안 그린다 */
  }).join('');
}
/* 목록의 내용 판 — 「미완료」 탭(검색어 없음)은 남은 줄만 + 「끝난 n줄 숨김」 · 다 끝났으면 안내 한 줄. 그 밖(전체·검색)은 종전대로 전부 */
function lwHtml(s, q){
  if(_tab!=='todo' || q) return linesHtml(s, q);
  var o=openLines(s);
  if(!o.lines.length) return '';   /* 줄이 모두 끝난 옛 일정 — 아무 글도 없이 날짜 줄만 (2026-11-20 「「모든 줄 끝」 문구도 제거해줘」 — 그 전엔 긴 안내 → 단추 → 「모든 줄 끝」). 빼려면 위 상태 칸에서 완료 */
  return linesHtml(s, q, false, true)+(o.hid?'<div class="lnhid" title="완료·취소한 줄은 미완료 목록에서 숨깁니다 — 「전체」 탭이나 달력에서 모두 보입니다">끝난 '+o.hid+'줄 숨김</div>':'');
}
/* ══ 엑셀 · 인쇄 (2026-11-19 사용자 「엑셀출력 및 인쇄 넣어줘요」) ══
     범위 = 오른쪽 목록에 지금 보이는 것 그대로(탭 「이 달」/「미완료」/「전체」 + 검색). 화면·엑셀·인쇄가 curList() 하나를 쓴다.
     내용(편집기 글)은 목록에 실려 오지 않으므로 내보낼 때 내용 있는 일정만 한 건씩 읽어 온다(gather, 6건씩 묶어서).
     엑셀 : 재고내용분석·매출 반품내역과 같은 서식(굴림 9 · 제목 17 굵게 병합 · 조건 줄 · 머리글 하늘 D9EDF7 · 테두리). 날짜는 날짜 값으로.
            내용은 서식을 떼고 글자만(줄바꿈·목록 기호는 살린다) — 엑셀 칸 하나에 들어가야 해서. 줄 높이는 내용 줄 수에 맞춘다.
     인쇄 : 제목 + 표(일자·시간·제목/장소·완료·내용). 내용은 서식 그대로. A4 세로, 화면의 달력·단추는 빼고 표만 */
function curList(){
  var q=gel('q').value.trim().toLowerCase(), list=(_tab==='del' ? (_dels||[]) : (_tab==='mon' ? _rows.filter(monOf) : (_tab==='all' ? _rows : _todo))).slice();
  if(_tab==='del'){ if(q) list=list.filter(function(s){ return (lnText(s)+' '+(s.place||'')).toLowerCase().indexOf(q)>=0; }); return list; }   /* 삭제 탭 = 서버가 준 차례(최근 지운 것부터) */
  if(q) list=list.filter(function(s){ return (lnText(s)+' '+(s.place||'')).toLowerCase().indexOf(q)>=0; });   /* 내용(줄 글자) + 장소 (2026-11-19 — 종전 제목 + 장소) */
  curList.base=list.slice();   /* 기간 거르기 전 — 맨 위 칩 숫자(요약)가 쓴다 */
  if(_per){ var t0=today(); list=list.filter(function(s){ return perOf(s,t0)===_per; }); }   /* 기간 조건 (2026-11-20) */
  list.sort(function(a,b){ return a.fromDt<b.fromDt?-1:(a.fromDt>b.fromDt?1:((a.schedTm||'99')<(b.schedTm||'99')?-1:((a.schedTm||'99')>(b.schedTm||'99')?1:a.schedSeq-b.schedSeq))); });
  if(_tab==='all') list.reverse();   /* 「전체」는 최근 날짜가 위 (2026-11-19) */
  return list;
}
function scopeNm(){ return (_tab==='mon' ? (_y+'년 '+(_m+1)+'월') : (_tab==='all' ? '전체' : (_tab==='del' ? '삭제' : '미완료')))+((_per && _tab!=='del') ? ' · '+perNm(_per) : ''); }
/* ══ 삭제 탭 · 복구 (2026-11-19 사용자 「삭제한 것 보고 복구 기능도」) ══
     지운 일정(ACTION_YN 'N')을 최근 지운 것부터 보여 준다 — 날짜·상태·내용 줄은 읽기만(칩·창 안 열림), 줄마다 지운 때·사람 + [↩ 복구].
     복구하면 지울 때 상태·내용 그대로 달력·목록에 돌아온다. 목록은 화면을 열 때·지우거나 복구할 때 새로 읽는다(loadDels) */
var _dels=null, _delErr='';
function loadDels(){
  return postForm('/mangr/ceoSchedDelList.do',{}).then(function(r){ _dels=r.data||[]; _delErr=''; paintList(); })
    .catch(function(e){ _dels=null; _delErr=e.message||'읽지 못했습니다'; paintList(); });
}
function paintDel(list, q){
  if(_dels==null){ gel('list').innerHTML='<div class="empty">'+(_delErr ? ('지운 일정을 읽지 못했습니다 — '+esc(_delErr)+'<br><span style="font-size:12px">(서버를 새로 올린 뒤에 쓸 수 있습니다)</span>') : '읽는 중…')+'</div>'; return; }
  if(!list.length){ gel('list').innerHTML='<div class="empty">'+(q?'검색에 맞는 지운 일정이 없습니다.':'지운 일정이 없습니다.')+'</div>'; return; }
  gel('list').innerHTML=list.map(function(s){
    var k=stKey(s);
    return '<div class="it del"><div class="ih">'
      +(k!=='N' ? '<span class="tag '+(k==='C'?'cx':'ok')+'" style="margin-left:0">'+ST[k].nm+'</span>' : '')
      +'<div class="t2">'+cntHtml(s)+'<b>'+lTxt(s.fromDt)+(s.toDt!==s.fromDt?' ~ '+lTxt(s.toDt):'')+'</b>'+(s.schedTm?' '+esc(s.schedTm):'')+(s.place?' · '+esc(s.place):'')
      +'<span class="tag dl" title="지운 때 · 사람">🗑 '+esc((s.delDttm||'').slice(5,16))+(s.delUser?' '+esc(s.delUser):'')+'</span></div>'
      +'<button type="button" class="rst" onclick="restoreSched('+s.schedSeq+', event)" title="이 일정을 되살립니다 — 지울 때 상태·내용 그대로">↩ 복구</button></div>'
      +'<div class="lw">'+linesHtml(s, q, true)+'</div></div>';
  }).join('');
}
/* 복구 = 묻지 않고 바로 (2026-11-20 사용자 「복구 확인창 빼줘」 — 같은 날 「복구시 메세지 없이 바로 복구되네요」로 확인창을 넣었다가 되돌림).
     복구 뒤 알림도 없다(2026-11-19 「복구 메세지도 제거」) — 달력·목록에 바로 돌아온다. ⚠확인창을 다시 넣자는 얘기가 나오면 이 왕복부터 */
function restoreSched(seq, ev){
  if(ev) ev.stopPropagation();
  busy(true);
  postForm('/mangr/ceoSchedRestore.do',{ schedSeq:seq })
    .then(function(){ busy(false); load(); })
    .catch(function(e){ busy(false); alertBox(esc(e.message)); load(); });
}
function stOf(s, t){ var k=stKey(s); if(k==='Y' || k==='C') return { k:k, txt:ST[k].nm, late:false };
  if(s.toDt<t) return { k:k, txt:dayGap(s.toDt,t)+'일 지남', late:true }; return { k:k, txt:ST[k].nm, late:false }; }
/* 내용 있는 일정의 내용을 읽어 { 번호: 걸러 낸 HTML } 로 */
function gather(list){
  var need=[], map={}, i=0;
  list.forEach(function(s){ if(s.hasContent!=='Y') return; if(s.content!=null) map[s.schedSeq]=clean(s.content); else need.push(s); });
  function next(){ if(i>=need.length) return Promise.resolve(map);
    var part=need.slice(i, i+6); i+=6;
    return Promise.all(part.map(function(s){ return postForm('/mangr/ceoSchedGet.do',{ schedSeq:s.schedSeq }).then(function(j){ map[s.schedSeq]=clean((j.data && j.data.content) || ''); }); })).then(next); }
  return next();
}
/* 서식 있는 글 → 글자만. 문단·목록·표 줄은 줄바꿈으로, 목록은 • / 1. 을 앞에 붙인다 */
function htmlText(html){
  if(!html) return '';
  var doc=new DOMParser().parseFromString('<body>'+html+'</body>','text/html'), out='';
  (function walk(n){ [].slice.call(n.childNodes).forEach(function(c){
    if(c.nodeType===3){ out+=String(c.nodeValue).replace(/ /g,' '); return; }
    if(c.nodeType!==1) return;
    var t=c.tagName;
    if(t==='BR'){ out+='\n'; return; }
    var blk=/^(P|DIV|LI|H1|H2|H3|H4|BLOCKQUOTE|TR|PRE|UL|OL|TABLE|HR)$/.test(t);
    if(blk && out && !/\n$/.test(out)) out+='\n';
    if(t==='LI') out+=((c.parentNode && c.parentNode.tagName==='OL') ? (([].indexOf.call(c.parentNode.children, c)+1)+'. ') : '• ');
    walk(c);
    if(t==='TD' || t==='TH') out+='\t';
    if(blk && !/\n$/.test(out)) out+='\n';
  }); })(doc.body);
  return out.replace(/[ \t]+\n/g,'\n').replace(/\n{3,}/g,'\n\n').replace(/^\n+|\s+$/g,'');
}
function E(k){ var a=[]; for(var i=0;i<k;i++) a.push(''); return a; }
function wch(v){ var w=0; String(v==null?'':v).split('').forEach(function(ch){ w+=(ch.charCodeAt(0)>255?1.8:1); }); return w; }
function dser(v){ var d=d10(v); if(!d) return ''; var q=d.split('-'); return (Date.UTC(+q[0],+q[1]-1,+q[2])-Date.UTC(1899,11,30))/86400000; }
/* 표 하나 → 시트. o = { widths:[칸 너비], date:[날짜 칸], left:[왼쪽 맞춤 칸], red:function(줄) → 빨강 칸들, dim:function(줄) → 흐리게(완료) } */
function sheetOf(title, cond, head, body, o){
  var N=head.length, bd={ style:'thin', color:{ rgb:'000000' } }, box={ top:bd, bottom:bd, left:bd, right:bd };
  var aoa=[ [title].concat(E(N-1)), E(N), [cond].concat(E(N-1)), head ], kinds=['t','t','p','h'];
  body.forEach(function(r){ aoa.push(r); kinds.push('row'); });
  var ws=XLSX.utils.aoa_to_sheet(aoa), H=[];
  for(var r=0;r<aoa.length;r++){ var k=kinds[r], reds=(k==='row' && o.red) ? o.red(aoa[r]) : [], dim=(k==='row' && o.dim) ? o.dim(aoa[r]) : false, lines=1;
    for(var c=0;c<N;c++){ var ref=XLSX.utils.encode_cell({ r:r, c:c }); if(!ws[ref]) ws[ref]={ t:'s', v:'' };
      var st={ font:{ name:'굴림', sz:9 }, alignment:{ vertical:'center', wrapText:true } };
      if(k==='t'){ st.font={ name:'굴림', sz:17, bold:true }; st.alignment.horizontal='center'; }
      else if(k==='p'){ st.alignment.horizontal='left'; st.border={ bottom:bd }; }
      else if(k==='h'){ st.font.bold=true; st.alignment.horizontal='center'; st.fill={ fgColor:{ rgb:'D9EDF7' } }; st.border=box; }
      else {
        st.border=box; st.fill={ fgColor:{ rgb:'FFFFFF' } };
        st.alignment.horizontal=((o.left||[]).indexOf(c)>=0 ? 'left' : 'center');
        if((o.date||[]).indexOf(c)>=0 && ws[ref].t==='n') ws[ref].z='yyyy-mm-dd';
        if(dim) st.font.color={ rgb:'808080' };
        if(reds.indexOf(c)>=0){ st.font.color={ rgb:'C0392B' }; st.font.bold=true; }
        if(typeof aoa[r][c]==='string' && aoa[r][c]){ var n=0, per=Math.max(4, (o.widths[c]||10)-1); aoa[r][c].split('\n').forEach(function(ln){ n+=Math.max(1, Math.ceil(wch(ln)/per)); }); if(n>lines) lines=n; }
      }
      ws[ref].s=st; }
    H.push({ hpt:(r<2 ? 18.75 : (k==='row' ? Math.min(409, Math.max(16.5, lines*12.75+3)) : 16.5)) }); }
  ws['!merges']=[ { s:{ r:0, c:0 }, e:{ r:1, c:N-1 } }, { s:{ r:2, c:0 }, e:{ r:2, c:N-1 } } ];
  ws['!cols']=o.widths.map(function(w){ return { wch:w }; });
  ws['!rows']=H;
  return ws;
}
function sumTxt(list, t){ var c={ N:0, Y:0, C:0 }, nLate=0, q=gel('q').value.trim(); list.forEach(function(s){ c[stKey(s)]++; if(isOpen(s) && s.toDt<t) nLate++; });
  return list.length+'건 · 완료 '+c.Y+(c.C?' · 취소 '+c.C:'')+' · 미완료 '+c.N+(nLate?' (지남 '+nLate+')':'')+(q?' · 검색 「'+q+'」':''); }
function xls(){
  if(!ADMIN) return;
  if(!window.XLSX || !XLSX.utils){ alertBox('엑셀 도구를 불러오지 못했습니다 — 화면을 새로 고친 뒤 다시 해 보세요.'); return; }
  var list=curList(); if(!list.length){ alertBox('내보낼 일정이 없습니다.'); return; }
  busy(true);
  gather(list).then(function(map){
    busy(false);
    var t=today();
    var head=['No','시작일','종료일','요일','시간','장소','상태','처리 일시','내용'];   /* 제목 칸은 뺐다(2026-11-19 — 제목 = 내용 첫 줄) */
    var body=list.map(function(s, i){ var st=stOf(s,t), txt=(map[s.schedSeq] ? htmlText(map[s.schedSeq]) : (s.title||'')); if(txt.length>32000) txt=txt.slice(0,32000)+'\n…(이하 생략)';
      return [i+1, dser(s.fromDt), (s.toDt!==s.fromDt ? dser(s.toDt) : ''), WK[toDate(s.fromDt).getDay()], s.schedTm||'', s.place||'', st.txt, (s.doneDttm||'').slice(0,16), txt]; });
    var ws=sheetOf('[대표자 일정 — '+scopeNm()+']', scopeNm()+'   ('+sumTxt(list,t)+' · 출력 '+d10(t)+')', head, body,
      { widths:[5,11,11,5,7,18,12,16,90], date:[1,2], left:[5,8],
        red:function(a){ return /지남/.test(String(a[6])) ? [6] : []; }, dim:function(a){ return a[6]==='완료' || a[6]==='취소'; } });
    var wb=XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, '대표자 일정');
    XLSX.writeFile(wb, '대표자일정_'+(_tab==='mon' ? (_y+'-'+p2(_m+1)) : (_tab==='all' ? '전체' : '미완료'))+'_'+t+'.xlsx');
    toast('📥 '+list.length+'건을 엑셀로 저장했습니다');
  }).catch(function(e){ busy(false); alertBox(esc(e.message)); });
}
function prt(){
  if(!ADMIN) return;
  var list=curList(); if(!list.length){ alertBox('인쇄할 일정이 없습니다.'); return; }
  busy(true);
  gather(list).then(function(map){
    busy(false);
    var t=today();
    function pd(v){ return d10(v).slice(2)+'('+WK[toDate(v).getDay()]+')'; }
    gel('printArea').innerHTML='<div class="pt"><b>[대표자 일정 — '+esc(scopeNm())+']</b><span>'+esc(sumTxt(list,t))+' · 출력 '+d10(t)+'</span></div>'
      +'<table class="pl"><thead><tr><th style="width:26px">No</th><th style="width:100px">일자</th><th style="width:40px">시간</th><th style="width:16%">장소</th><th style="width:76px">상태</th><th>내용</th></tr></thead><tbody>'
      + list.map(function(s, i){ var st=stOf(s,t);
          return '<tr'+((st.k==='Y'||st.k==='C')?' class="dn"':'')+'><td class="c">'+(i+1)+'</td>'
            +'<td class="c" style="white-space:nowrap">'+pd(s.fromDt)+(s.toDt!==s.fromDt ? '<br>~ '+pd(s.toDt) : '')+'</td><td class="c">'+esc(s.schedTm||'')+'</td>'
            +'<td>'+esc(s.place||'')+'</td>'
            +'<td class="c'+(st.late?' late':'')+'">'+ST[st.k].ic+' '+esc(st.txt)+((st.k!=='N' && s.doneDttm) ? '<div class="pp">'+esc(s.doneDttm.slice(5,16))+'</div>' : '')+'</td>'
            +'<td class="ct">'+(map[s.schedSeq]||esc(s.title||''))+'</td></tr>'; }).join('')
      +'</tbody></table>';
    setTimeout(function(){ window.print(); }, 60);
  }).catch(function(e){ busy(false); alertBox(esc(e.message)); });
}

/* 목록의 상태 칸 — 상태만 바꾼다(창을 열지 않는다). v = N 미완료 · Y 완료 · C 일정취소 */
/* ★위 상태 칸을 고르면 아래 내용 줄 전부에 적용 (2026-11-19 사용자 「완료일 때 전체 적용」 → 「상단 박스 선택하면 하단 내용 전체 적용하고 하단은 개별 수정 가능하게」) —
   완료 → 모든 줄 완료 · 취소 → 모든 줄 취소 · 「-」(아무것도 없음) → 모든 줄 표시 지움. 이미 붙어 있던 표시도 새 상태로 바꾼다.
   묶음 제목(번호 없는 「삼성미팅」)은 할 일이 아니라 건드리지 않는다. 그 뒤에도 줄마다 칩으로 따로 바꿀 수 있다(일정 상태는 그대로).
   목록 상태 칸 = 내용을 새로 읽어 줄을 고친 뒤 상태와 함께 한 번에 저장(ceoSchedSave) · 창의 [완료][취소] = 편집 칸 글에 바로 반영(저장은 [저장]) */
function lnAll(html, st){
  var P=schedLines(html), L=P.lines, anyNo=L.some(function(l){ return LN_NUM.test(l.body); }), ch=0;
  L.forEach(function(l){
    if(anyNo && !LN_NUM.test(l.body)) return;   /* 묶음 제목 */
    if(l.st===st) return;
    var tn=null; for(var k=l.nodes.length-1;k>=0;k--){ if(/\S/.test(String(l.nodes[k].nodeValue).replace(/\u00a0/g,' '))){ tn=l.nodes[k]; break; } }
    if(!tn) return;
    var v=String(tn.nodeValue), m=LN_MK.exec(v.replace(/\u00a0/g,' '));
    v=(m ? v.slice(0, m.index) : v.replace(/[\s\u00a0]+$/,''));
    if(st!=='N') v+=' '+LN_ST[st].nm;
    tn.nodeValue=v; ch++;
  });
  return { html:(ch ? clean(P.doc.body.innerHTML) : html), n:ch };
}
function doneSet(seq, v, ev){
  if(ev) ev.stopPropagation();
  if(v==='' || v==null) return;   /* 숨은 «지금 상태» 칸 */
  if(!ST[v]) v='N';
  busy(true);
  postForm('/mangr/ceoSchedGet.do',{ schedSeq:seq }).then(function(j){
    var d=j.data||{}, html=d.content||'';
    if(!schedLines(html).lines.length && d.title) html='<div>'+esc(d.title)+'</div>';
    var r=lnAll(html, v);
    var body={ schedSeq:seq, fromDt:d.fromDt, toDt:d.toDt||d.fromDt, schedTm:d.schedTm||'', title:(titleOf(r.html)||d.title||''), place:d.place||'', content:r.html, doneYn:v };
    return postJson('/mangr/ceoSchedSave.do', body);   /* 상태 칸 알림은 띄우지 않는다 (2026-11-19 사용자 「상태 칸 변경 알림도 제거」) */
  }).then(function(){ busy(false); load(); })
    .catch(function(e){ busy(false); alertBox(esc(e.message)); load(); });
}
/* ★상태 칸 목록 (2026-11-19 사용자 「완료하면 취소 완료 안 됨 — 상태 칸 변경하면 해당 전체 적용」) —
   이미 「완료」인 일정에서 줄 하나를 취소한 뒤 다시 「완료」를 골라도 아무 일이 없었다(같은 값을 고르면 select 가 change 를 안 낸다).
   맨 위에 지금 상태 글자를 보여 주는 숨은 칸(value '', 목록에는 안 보임)을 골라 두고, 펼친 목록의 완료 · 취소 · - 는 늘 «다른 값»이라 고르면 반드시 적용된다 */
function stOpts(k){ return '<option value="" selected hidden>'+(ST[k].nm||'-')+'</option>'
  + ST_KEYS.map(function(x){ return '<option value="'+x+'">'+(ST[x].nm||'-')+'</option>'; }).join(''); }
/* 창의 상태 고르기 */
function stGet(){ var b=document.querySelector('#fSt .sb.on'), v=b ? b.getAttribute('data-v') : 'N'; return ST[v] ? v : 'N'; }
function stSet(v){ if(!ST[v]) v='N'; [].forEach.call(document.querySelectorAll('#fSt .sb'), function(b){ b.classList.toggle('on', b.getAttribute('data-v')===v); }); }

/* ══ 편집기 ══ */
var ED=null, _rng=null;
var FONTS=['맑은 고딕','굴림','돋움','바탕','궁서'], SIZES=[11,12,13,14,16,18,22,28];
var COLORS=['#1f2a37','#c0392b','#b45309','#137a6c','#2f4f9a','#6b4fa0','#8794a1'], HILITE=['#fff3a3','#d9f2c4','#d6ebff','#ffd9e0'];
function tbBuild(){
  function b(cmd, html, tip){ return '<button type="button" data-c="'+cmd+'" title="'+tip+'">'+html+'</button>'; }
  gel('tb').innerHTML=
     b('bold','<b>B</b>','굵게 (Ctrl+B)')+b('italic','<i>I</i>','기울임 (Ctrl+I)')+b('underline','<u>U</u>','밑줄 (Ctrl+U)')+b('strikeThrough','<s>S</s>','취소선')
    +'<span class="sep"></span>'
    +'<select id="tbFont" title="글꼴" onchange="edFont(this.value); this.value=\'\'"><option value="">글꼴</option>'+FONTS.map(function(f){ return '<option value="'+f+'" style="font-family:\''+f+'\'">'+f+'</option>'; }).join('')+'</select>'
    +'<select id="tbSize" title="글자 크기" onchange="edSize(this.value); this.value=\'\'"><option value="">크기</option>'+SIZES.map(function(s){ return '<option value="'+s+'">'+s+'</option>'; }).join('')+'</select>'
    +'<span class="sep"></span><span class="lb">글자색</span>'
    + COLORS.map(function(c){ return '<button type="button" class="sw" data-c="foreColor" data-v="'+c+'" style="background:'+c+'" title="글자색"></button>'; }).join('')
    +'<span class="sep"></span><span class="lb">형광펜</span>'
    + HILITE.map(function(c){ return '<button type="button" class="sw" data-c="hiliteColor" data-v="'+c+'" style="background:'+c+'" title="형광펜"></button>'; }).join('')
    +'<button type="button" class="sw no" data-c="hiliteColor" data-v="transparent" title="형광펜 지우기">✕</button>'
    +'<span class="sep"></span>'
    + b('renumber','🔢 번호 정리','번호 매긴 줄을 묶음(「삼성미팅」 같은 번호 없는 줄로 나뉜 덩어리)마다 1부터 다시 매깁니다')
    + b('insertUnorderedList','• 목록','글머리 기호')+b('insertOrderedList','1. 목록','번호 매기기')
    + b('justifyLeft','왼쪽','왼쪽 맞춤')+b('justifyCenter','가운데','가운데 맞춤')+b('justifyRight','오른쪽','오른쪽 맞춤')
    +'<span class="sep"></span>'
    + b('removeFormat','🧹 서식 지우기','고른 글의 굵기·색·크기를 지웁니다')+b('undo','↶','되돌리기 (Ctrl+Z)')+b('redo','↷','다시 (Ctrl+Y)');
  /* 단추를 눌러도 글 고른 것이 풀리지 않게 — mousedown 을 막고 click 에서 실행 */
  gel('tb').addEventListener('mousedown', function(e){ if(e.target.closest('button')) e.preventDefault(); });
  gel('tb').addEventListener('click', function(e){ var x=e.target.closest('button[data-c]'); if(!x) return; edCmd(x.getAttribute('data-c'), x.getAttribute('data-v')); });
}
function edKeep(){ var s=window.getSelection(); if(s && s.rangeCount && ED.contains(s.anchorNode)) _rng=s.getRangeAt(0).cloneRange(); }
/* ★이미 편집 칸 안에 커서가 있으면 건드리지 않는다 (2026-11-19) — 고른 범위를 다시 넣으면, 글자를 고르지 않고 누른 굵게·밑줄(«다음 글자 서식»)이 풀려
   [굵게][밑줄][색]을 차례로 눌러도 마지막 것만 먹었다. 글꼴·크기 고르기처럼 초점이 편집 칸을 떠났을 때만 되돌린다 */
function edBack(){ var s=window.getSelection();
  if(document.activeElement===ED && s && s.rangeCount && ED.contains(s.anchorNode)) return;
  ED.focus(); if(_rng){ s=window.getSelection(); s.removeAllRanges(); s.addRange(_rng); } }
/* ★빈 줄에는 밑줄·취소선·형광펜을 남기지 않는다 (2026-11-19 사용자 「키보드 이동인데 표시됨」) —
   밑줄 친 줄 끝에서 Enter 를 치면 브라우저가 그 서식을 새 줄로 그대로 물려줘, 아무것도 안 쓴 줄에 밑줄 토막이 보였다.
   커서가 놓인 줄이 비어 있으면(글자 없음) 그 줄의 «빈 곳에도 그려지는» 서식 셋만 뗀다. 굵기·색·크기는 여느 편집기처럼 이어진다.
   글이 있는 줄은 건드리지 않는다. 다시 밑줄을 쓰려면 [U] 를 누르면 된다 */
function edLineTidy(){
  var s=window.getSelection(); if(!s || !s.rangeCount || !s.isCollapsed) return;
  var n=s.anchorNode; if(!n || !ED.contains(n) || n===ED) return;
  var blk=(n.nodeType===1 ? n : n.parentNode);
  while(blk && blk!==ED && !/^(DIV|P|LI|H1|H2|H3|H4|BLOCKQUOTE|TD|TH|PRE)$/.test(blk.tagName)) blk=blk.parentNode;
  if(!blk || blk===ED) return;
  if((blk.textContent||'').replace(/[\s ​]/g,'')!=='') return;
  [].slice.call(blk.querySelectorAll('span,font,u,s,strike,b,i,em,strong')).forEach(function(e){
    var tag=e.tagName;
    if(tag==='U' || tag==='S' || tag==='STRIKE') e.style.textDecorationLine='none';
    else if(e.style){ e.style.removeProperty('text-decoration'); e.style.removeProperty('text-decoration-line'); e.style.removeProperty('background-color'); }
  });
}
/* 굵게·기울임·밑줄·취소선 단추 — 지금 커서 자리에 그 서식이 켜져 있으면 눌린 모양으로 */
function edState(){ if(!ED) return; var s=window.getSelection(), inEd=!!(s && s.rangeCount && ED.contains(s.anchorNode));
  ['bold','italic','underline','strikeThrough'].forEach(function(c){ var b=gel('tb').querySelector('button[data-c="'+c+'"]'); if(!b) return; var on=false; try{ on=inEd && document.queryCommandState(c); }catch(e){} b.classList.toggle('on', !!on); }); }
function edCmd(cmd, val){
  if(cmd==='renumber'){ edRenumber(); return; }
  edBack();
  try{ document.execCommand('styleWithCSS', false, true); }catch(e){}
  var ok=false; try{ ok=document.execCommand(cmd, false, val==null?null:val); }catch(e){}
  if(!ok && cmd==='hiliteColor'){ try{ document.execCommand('backColor', false, val); }catch(e){} }
  edKeep(); edTouched();
}
function edFont(f){ if(f) edCmd('fontName', f); }
/* 글자 크기 — execCommand 는 1~7 단계만 안다. 7로 찍어 표식을 만든 뒤 그 자리를 px 로 바꾼다 */
function edSize(px){
  if(!px) return; edBack();
  try{ document.execCommand('styleWithCSS', false, false); document.execCommand('fontSize', false, '7'); }catch(e){}
  [].slice.call(ED.querySelectorAll('font[size="7"]')).forEach(function(f){ var s=document.createElement('span'); s.style.fontSize=px+'px'; while(f.firstChild) s.appendChild(f.firstChild); f.parentNode.replaceChild(s, f); });
  try{ document.execCommand('styleWithCSS', false, true); }catch(e){}
  _rng=null; edTouched();
}
function edTouched(){ _dirty=true; var n=(ED.textContent||'').length; gel('edLen').textContent=n?('내용 '+n.toLocaleString()+'자'):''; }

/* ★걸러 내기 — 허용한 태그·속성만 남긴다. 붙여 넣을 때 · 저장 전 · 불러와 보여 줄 때 모두 이 함수를 지난다.
     버리는 것(안의 글까지) : 스크립트·스타일·그림·틀·입력 칸 … / 풀어 놓는 것(안의 글은 남김) : 그 밖의 모르는 태그 /
     속성 : style(글 모양에 쓰는 몇 가지만) · a 의 href(http·https·mailto) · 표 칸의 colspan·rowspan 만 */
var OKTAG={P:1,DIV:1,BR:1,SPAN:1,B:1,STRONG:1,I:1,EM:1,U:1,S:1,STRIKE:1,FONT:1,UL:1,OL:1,LI:1,H1:1,H2:1,H3:1,H4:1,BLOCKQUOTE:1,A:1,TABLE:1,THEAD:1,TBODY:1,TR:1,TD:1,TH:1,HR:1,SUB:1,SUP:1,PRE:1};
var DROP={SCRIPT:1,STYLE:1,IFRAME:1,OBJECT:1,EMBED:1,IMG:1,SVG:1,MATH:1,LINK:1,META:1,FORM:1,INPUT:1,BUTTON:1,TEXTAREA:1,SELECT:1,VIDEO:1,AUDIO:1,CANVAS:1,HEAD:1,TITLE:1,BASE:1,NOSCRIPT:1,TEMPLATE:1,PICTURE:1,SOURCE:1};
var OKCSS=['color','background-color','font-size','font-family','font-weight','font-style','text-decoration-line','text-align','vertical-align','border','border-collapse','padding','width','margin-left'];
function clean(html){
  var doc=new DOMParser().parseFromString('<body>'+String(html==null?'':html)+'</body>','text/html');
  (function walk(node){
    [].slice.call(node.childNodes).forEach(function(c){
      if(c.nodeType===3) return;
      if(c.nodeType!==1){ node.removeChild(c); return; }
      var tag=String(c.tagName||'').toUpperCase();
      if(DROP[tag]){ node.removeChild(c); return; }
      walk(c);
      if(!OKTAG[tag]){ while(c.firstChild) node.insertBefore(c.firstChild, c); node.removeChild(c); return; }
      var css=[], st=c.style;
      if(st) OKCSS.forEach(function(p){ var v=st.getPropertyValue(p); if(v && !/url\(|expression|javascript:|@import/i.test(v) && !/^(initial|inherit|unset)$/i.test(v)) css.push(p+':'+v); });
      var href=c.getAttribute('href'), cs=c.getAttribute('colspan'), rs=c.getAttribute('rowspan'), face=c.getAttribute('face'), col=c.getAttribute('color');
      [].slice.call(c.attributes).forEach(function(a){ c.removeAttribute(a.name); });
      if(tag==='FONT'){ if(face && /^[0-9A-Za-z가-힣 ,'_-]+$/.test(face)) css.push('font-family:'+face); if(col && /^#?[0-9A-Za-z]+$/.test(col)) css.push('color:'+col); }
      if(css.length) c.setAttribute('style', css.join(';'));
      if(tag==='A' && href && /^(https?:|mailto:)/i.test(href.trim())){ c.setAttribute('href', href.trim()); c.setAttribute('target','_blank'); c.setAttribute('rel','noopener noreferrer'); }
      if(tag==='TD'||tag==='TH'){ if(/^[0-9]{1,3}$/.test(cs||'')) c.setAttribute('colspan', cs); if(/^[0-9]{1,3}$/.test(rs||'')) c.setAttribute('rowspan', rs); }
    });
  })(doc.body);
  return doc.body.innerHTML;
}
function edInit(){
  ED=gel('ed'); tbBuild();
  ED.addEventListener('input', function(e){ if(e && (e.inputType==='insertParagraph' || e.inputType==='insertLineBreak')) edLineTidy(); if(e && e.inputType==='insertParagraph') edAutoNum(); edTouched(); });
  ED.addEventListener('keyup', function(e){ if(/^(Enter|ArrowUp|ArrowDown|ArrowLeft|ArrowRight|Home|End|PageUp|PageDown)$/.test(e.key)) edLineTidy(); });
  ED.addEventListener('mouseup', function(){ setTimeout(edLineTidy, 0); });
  document.addEventListener('selectionchange', function(){ edKeep(); edState(); });
  /* 붙여넣기 — 서식 있는 글은 걸러서, 그 밖은 글자만. 그림은 빠진다 */
  ED.addEventListener('paste', function(e){
    var cd=e.clipboardData; if(!cd) return;
    e.preventDefault();
    var html=cd.getData('text/html'), txt=cd.getData('text/plain');
    var had=/<img\b/i.test(html||'') || (cd.files && cd.files.length>0 && !html && !txt);
    if(html) document.execCommand('insertHTML', false, clean(html));
    else if(txt) document.execCommand('insertText', false, txt);
    if(had) toast('그림은 넣을 수 없어 글만 붙였습니다','warn');
    edTouched();
  });
  ED.addEventListener('drop', function(e){ if(e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length){ e.preventDefault(); toast('그림·파일은 넣을 수 없습니다','warn'); } });
  gel('fSt').addEventListener('click', function(e){ var b=e.target.closest('.sb'); if(!b) return; var v=b.getAttribute('data-v'), nv=(ST[v] ? v : 'N');   /* 눌린 단추를 또 눌러도 그 상태를 아래 줄에 다시 적용(풀기는 [-]) */ stSet(nv); _dirty=true; dupPaint();
    var r=lnAll(ED.innerHTML, nv); if(r.n){ ED.innerHTML=r.html; _rng=null; edTouched(); } });   /* [완료]·[취소]·풀기 = 내용 줄 전부에 같은 표시(편집 칸에 바로 — 고칠 수 있다) */   /* 눌린 것을 또 누르면 풀린다 */
  ['fFrom','fTo','fTm'].forEach(function(id){ gel(id).addEventListener('input', dupPaint); gel(id).addEventListener('change', function(){ setTimeout(dupPaint, 0); }); });   /* 같은 시간 일정 알림 — 시작일을 바꾸면 끝나는 날도 따라 바뀐 뒤에 본다 */
  ['fFrom','fTo','fTm','fPlace'].forEach(function(id){ gel(id).addEventListener('input', function(){ _dirty=true; }); gel(id).addEventListener('change', function(){ _dirty=true; }); });
  document.addEventListener('keydown', function(e){
    if(!gel('pop').classList.contains('on')) return;
    if((e.ctrlKey||e.metaKey) && (e.key==='s'||e.key==='S')){ e.preventDefault(); edSave(); }
    else if(e.key==='Escape' && !e.isComposing) edClose();
  });
}
/* ══ 업무일지처럼 줄 번호 (2026-11-19 사용자 「이런 식으로 입력 가능하게」 — 직원 업무일지 격자 그림) ══
     「1. 무엇」 줄 끝에서 Enter → 다음 줄이 「2. 」로 시작한다. 번호만 있고 글이 없는 줄에서 Enter → 번호를 지우고 번호 매기기를 멈춘다(묶음 머리를 쓰려고).
     Shift+Enter(줄 안 바꿈)는 번호를 안 붙인다. 번호 꼴은 앞 줄을 따른다(「1.」 / 「1)」).
     [🔢 번호 정리] = 묶음마다 1부터 다시(중간 줄을 지우거나 끼워 넣어 번호가 어긋났을 때) */
function edLineBlk(n){ while(n && n.parentNode && n.parentNode!==ED) n=n.parentNode; return (n && n.parentNode===ED) ? n : null; }
function edPrevLine(blk){
  var p=blk.previousSibling;
  if(p && p.nodeType===1 && /^(DIV|P)$/.test(p.tagName)) return { el:p, txt:p.textContent||'' };
  var t='', nodes=[];
  while(p && !(p.nodeType===1 && (p.tagName==='BR' || /^(DIV|P|UL|OL|TABLE|H1|H2|H3|H4|BLOCKQUOTE|PRE|HR)$/.test(p.tagName)))){ t=(p.textContent||'')+t; nodes.unshift(p); p=p.previousSibling; }
  return { el:null, nodes:nodes, txt:t };
}
function edAutoNum(){
  var sel=window.getSelection(); if(!sel || !sel.rangeCount || !sel.isCollapsed) return;
  var blk=edLineBlk(sel.anchorNode); if(!blk || blk.nodeType!==1 || !/^(DIV|P)$/.test(blk.tagName)) return;
  if((blk.textContent||'').replace(/[\s\u00a0\u200b]/g,'')!=='') return;   /* 줄 가운데서 Enter 를 쳐 글이 넘어온 줄은 건드리지 않는다 */
  var pv=edPrevLine(blk), m=/^\s*(\d{1,3})([.)])(?!\d)(.*)$/.exec(String(pv.txt).replace(/\u00a0/g,' '));
  if(!m) return;
  if(!m[3].trim()){   /* 번호만 있던 줄 — 그 번호를 지우고 끝낸다 */
    if(pv.el){ pv.el.innerHTML='<br>'; } else pv.nodes.forEach(function(x){ if(x.parentNode) x.parentNode.removeChild(x); });
    return;
  }
  try{ document.execCommand('insertText', false, (+m[1]+1)+m[2]+' '); }catch(e){}
}
function edRenumber(){
  var P=schedLines(ED.innerHTML), k=0, ch=0;
  P.lines.forEach(function(l){
    var m=/^\s*(\d{1,3})([.)])(?!\d)/.exec(String(l.txt));
    if(!m){ k=0; return; }   /* 번호 없는 줄(묶음 머리)에서 다시 1부터 */
    k++;
    for(var j=0;j<l.nodes.length;j++){ var v=String(l.nodes[j].nodeValue); if(!/\S/.test(v.replace(/\u00a0/g,' '))) continue;
      var nv=v.replace(/^([\s\u00a0]*)\d{1,3}(?=[.)])/, '$1'+k); if(nv!==v){ l.nodes[j].nodeValue=nv; ch++; } break; }
  });
  if(!ch){ toast('번호가 이미 차례대로입니다','ok'); return; }
  ED.innerHTML=clean(P.doc.body.innerHTML); _rng=null; edTouched();
}
function edFromSet(){ var a=gel('fFrom').value, b=gel('fTo').value; if(a && (!b || b<a)) gel('fTo').value=a; }
function edFill(s){
  _seq=s.schedSeq||0;
  gel('popTit').textContent=_seq?'일정 수정':'일정 등록';
  gel('popInfo').textContent=_seq?(('등록 '+(s.regDttm||'').slice(0,16)+(s.regUser?' '+s.regUser:''))+(s.updDttm?' · 수정 '+s.updDttm.slice(0,16)+(s.updUser?' '+s.updUser:''):'')+((stKey(s)!=='N' && s.doneDttm)?' · '+ST[stKey(s)].nm+' '+s.doneDttm.slice(0,16):'')):'';
  gel('fFrom').value=d10(s.fromDt); gel('fTo').value=d10(s.toDt||s.fromDt); gel('fTm').value=s.schedTm||'';
  gel('fPlace').value=s.place||''; stSet(stKey(s));
  ED.innerHTML=clean(s.content||''); _rng=null;
  if(!schedLines(ED.innerHTML).lines.length && s.title) ED.innerHTML='<div>'+esc(s.title)+'</div>';   /* 내용 없이 제목만 있던 옛 일정 — 제목을 첫 줄로 (2026-11-19 제목 칸 없앰) */
  gel('btnDel').style.display=_seq?'':'none';
  edTouched(); _dirty=false; dupPaint();
  gel('pop').classList.add('on');
  setTimeout(function(){ try{ ED.focus(); }catch(e){} }, 30);
}
/* 열기 — seq 0 = 새 일정(dt 가 있으면 그 날짜로, 없으면 오늘이 보이는 달이면 오늘·아니면 그 달 1일) */
function edOpen(seq, dt, ev){
  if(ev) ev.stopPropagation();
  if(!ADMIN) return;
  if(!seq){ var t=today(), d=dt || ((+t.slice(0,4)===_y && +t.slice(4,6)-1===_m) ? t : (''+_y+p2(_m+1)+'01'));
    edFill({ schedSeq:0, fromDt:d, toDt:d, schedTm:'', title:'', place:'', content:'', doneYn:'N' }); return; }
  busy(true);
  postForm('/mangr/ceoSchedGet.do',{ schedSeq:seq }).then(function(j){ busy(false); edFill(j.data); })
    .catch(function(e){ busy(false); alertBox(esc(e.message)); });
}
function edClose(force){
  if(!force && _dirty && window._confirmBox){ _confirmBox({ msg:'고친 내용을 저장하지 않고 닫을까요?', icon:'📝', okText:'저장 안 하고 닫기', onOk:function(){ edClose(true); }, onCancel:function(){} }); return; }
  gel('pop').classList.remove('on'); _dirty=false;
}
/* ★같은 시간 일정 (2026-11-19 사용자 「시간 중복있을경우 메세지처리」) —
   겹침 = 날짜(기간)가 겹치고 «시간이 같은» 다른 일정. 일정에는 끝나는 시간이 없어 시작 시간이 같은 것만 겹침으로 본다.
     · 시간을 비운 종일 일정은 따지지 않는다(시간이 없으니 겹칠 것이 없다)
     · 일정취소한 것은 상대로 치지 않고, 지금 일정을 일정취소로 저장할 때도 묻지 않는다
     · 고치는 중인 그 일정 자신은 뺀다
   알리는 곳 둘 : ① 창에서 일자·시간을 고르는 즉시 그 밑에 노란 띠(dupPaint) ② [저장]을 누르면 「그래도 저장」을 한 번 묻는다 — 막지는 않는다(일부러 겹쳐 잡는 일도 있다).
   목록(_rows)은 화면이 읽어 둔 전체 일정이라 서버에 다시 묻지 않는다 */
function dupOf(from, to, tm, st){
  if(!tm || st==='C' || from.length!==8) return [];
  return _rows.filter(function(x){ return x.schedSeq!==_seq && stKey(x)!=='C' && x.schedTm===tm && x.toDt>=from && x.fromDt<=to; });
}
function dupLine(x){ return '<b>'+dTxt(x.fromDt)+(x.toDt!==x.fromDt?' ~ '+dTxt(x.toDt):'')+' '+esc(x.schedTm)+'</b> '+esc(x.title)+(x.place?' · '+esc(x.place):'')+(stKey(x)==='Y'?' (완료)':''); }
function dupPaint(){
  var from=d8(gel('fFrom').value), to=d8(gel('fTo').value)||from, d=dupOf(from, to, gel('fTm').value||'', stGet()), el=gel('dupHint');
  if(!d.length){ el.style.display='none'; el.innerHTML=''; return; }
  el.innerHTML='⚠ 같은 시간에 이미 일정이 있습니다 — '+d.slice(0,3).map(dupLine).join(' / ')+(d.length>3?' 외 '+(d.length-3)+'건':'');
  el.style.display='';
}
function edSave(){
  var from=d8(gel('fFrom').value), to=d8(gel('fTo').value)||from;
  if(from.length!==8){ alertBox('일자를 넣으세요.'); return; }
  if(to<from){ alertBox('끝나는 날이 시작하는 날보다 앞섭니다.'); return; }
  var html=((ED.textContent||'').trim()==='' && !ED.querySelector('hr,table')) ? '' : clean(ED.innerHTML);
  var title=titleOf(html);   /* 제목 칸 없음 — 내용 첫 줄(줄 끝 「완료」·「일정취소」 뺀 것)을 제목으로 저장 */
  if(!title){ alertBox('일정 내용을 적으세요.'); try{ ED.focus(); }catch(e){} return; }
  if(html.length>200000){ alertBox('내용이 너무 깁니다(20만 자까지) — 줄여서 저장해 주세요.'); return; }
  var body={ schedSeq:_seq, fromDt:from, toDt:to, schedTm:gel('fTm').value||'', title:title, place:gel('fPlace').value.trim(), content:html, doneYn:stGet() };
  var d=dupOf(from, to, body.schedTm, body.doneYn);
  if(d.length){
    var msg='같은 시간에 이미 일정이 있습니다.<br><span style="font-size:12.5px;color:#3d4d5c;line-height:1.7">'+d.slice(0,5).map(function(x){ return '· '+dupLine(x); }).join('<br>')+(d.length>5?'<br>· 외 '+(d.length-5)+'건':'')+'</span><br>그래도 저장할까요?';
    if(window._confirmBox){ _confirmBox({ msg:msg, icon:'⏰', okText:'그래도 저장', onOk:function(){ edPost(body); }, onCancel:function(){ try{ gel('fTm').focus(); }catch(e){} } }); return; }
    if(!confirm('같은 시간에 이미 일정이 있습니다. 그래도 저장할까요?')) return;
  }
  edPost(body);
}
function edPost(body){
  var from=body.fromDt, to=body.toDt;
  busy(true);
  postJson('/mangr/ceoSchedSave.do', body)
    .then(function(){ busy(false);   /* 저장 알림(「일정을 등록했습니다」·「고쳤습니다」)은 띄우지 않는다 (2026-11-19 사용자 「일정 등록되었다는 메세지 제거」) */
      /* 저장한 일정이 다른 달이면 그 달로 옮겨 보여 준다 */
      var mA=''+_y+p2(_m+1)+'01', mB=ymd(new Date(_y,_m+1,0)); if(to<mA || from>mB){ _y=+from.slice(0,4); _m=+from.slice(4,6)-1; }
      edClose(true); load(); })
    .catch(function(e){ busy(false); alertBox(esc(e.message)); });
}
/* ★삭제 (2026-11-19 사용자 「일정 삭제기능도 (완료는 일정취소하고)」) — 창의 [🗑 삭제] 와 목록 줄 끝의 🗑 둘 다 delAsk 하나를 쓴다.
   완료한 일정은 바로 지우지 않는다 — 끝낸 일의 기록이 실수로 사라지지 않게, 상태를 일정취소(또는 빈 칸)로 바꾼 뒤에 지운다(delGuard). 서버도 같은 검사를 한다.
   상태는 «저장돼 있는 값»(_rows)으로 본다 — 창에서 단추만 눌러 놓고 저장하지 않은 것은 치지 않는다 */
function rowOf(seq){ for(var i=0;i<_rows.length;i++) if(_rows[i].schedSeq===seq) return _rows[i]; return null; }
function delGuard(seq){
  var s=rowOf(seq);
  if(s && stKey(s)==='Y'){ alertBox('완료한 일정은 바로 지울 수 없습니다.<br><span style="font-size:12.5px;color:#3d4d5c">상태 칸(달력·목록의 「완료」)을 <b>취소</b>로 바꾼 뒤 다시 🗑 를 눌러 주세요 — 목록의 상태 칸에서 바로 바꿀 수 있습니다.</span>'); return false; }
  return true;
}
/* 지운 뒤 알림(「🗑 일정을 지웠습니다」)은 띄우지 않는다 (2026-11-19 사용자 「일정 지웠다는 메세지 제거」) — 지운 일정은 「삭제」 탭에 보인다 */
function delAsk(seq, title, after){
  if(!seq || !delGuard(seq)) return;
  var go=function(){ busy(true); postForm('/mangr/ceoSchedDel.do',{ schedSeq:seq }).then(function(){ busy(false); if(after) after(); load(); }).catch(function(e){ busy(false); alertBox(esc(e.message)); }); };
  if(window._confirmBox) _confirmBox({ msg:'이 일정을 지울까요?<br><b>'+esc(title||'')+'</b><br><span style="font-size:12px;color:#6b7a89">지우면 달력과 목록에서 사라집니다.</span>', icon:'🗑', okText:'지우기', onOk:go, onCancel:function(){} });
  else if(confirm('이 일정을 지울까요?')) go();
}
/* ★창에서 완료를 풀고 바로 [삭제] (2026-11-19 사용자 「완료에서 일정취소 하고 저장 안 하고 하면 삭제 안 됨 — 저장하고 다시 들어와서 해야 삭제됨」) —
   저장돼 있는 상태는 완료인데 창에서 [일정취소](또는 완료 풀기)를 눌러 놓았으면, 따로 저장하지 않아도 «그 상태로 먼저 바꾼 뒤» 지운다(한 번에).
   확인 글에 상태를 바꾼다는 것을 같이 적는다. 창에서도 완료인 채면 종전대로 막고, 이 창에서 어떻게 하면 되는지 알려 준다 */
function edDel(){
  if(!_seq) return;
  var s=rowOf(_seq), cur=stGet(), seq=_seq, title=titleOf(ED.innerHTML)||(s?s.title:'');
  if(s && stKey(s)==='Y' && cur==='Y'){ alertBox('완료한 일정은 바로 지울 수 없습니다.<br><span style="font-size:12.5px;color:#3d4d5c">위의 <b>[취소]</b>를 누른 다음 [삭제]를 누르세요 — 저장은 따로 하지 않아도 됩니다.</span>'); return; }
  if(s && stKey(s)==='Y'){
    var nm=(cur==='C' ? '취소' : '완료 해제');
    var go=function(){ busy(true);
      postForm('/mangr/ceoSchedDone.do',{ schedSeq:seq, doneYn:cur })
        .then(function(){ return postForm('/mangr/ceoSchedDel.do',{ schedSeq:seq }); })
        .then(function(){ busy(false); edClose(true); load(); })
        .catch(function(e){ busy(false); alertBox(esc(e.message)); load(); }); };
    if(window._confirmBox) _confirmBox({ msg:'상태를 <b>'+nm+'</b>(으)로 바꾸고 이 일정을 지울까요?<br><b>'+esc(title)+'</b><br><span style="font-size:12px;color:#6b7a89">지우면 달력과 목록에서 사라집니다.</span>', icon:'🗑', okText:'지우기', onOk:go, onCancel:function(){} });
    else if(confirm('상태를 '+nm+'(으)로 바꾸고 이 일정을 지울까요?')) go();
    return;
  }
  delAsk(seq, title, function(){ edClose(true); });
}
/* 목록 줄 끝의 🗑 — 창을 열지 않고 바로 */
/* ★완료한 일정의 🗑 = 막고 안내만 (2026-11-19 사용자 「삭제 자동 말고 취소로 하고 삭제하기」) —
   잠깐(같은 날) 「완료면 취소로 바꾸고 바로 지우기」를 한 번에 했는데 되돌렸다. 완료한 일정은 상태 칸에서 직접 「취소」로 바꾼 뒤 🗑 로 지운다(delGuard 안내).
   취소·빈칸인 일정은 종전대로 한 번 묻고 지운다 */
function rowDel(seq, ev){
  if(ev) ev.stopPropagation();
  var s=rowOf(seq); if(!s) return;
  delAsk(seq, s.title);
}

(function(){
  var t=new Date(); _y=t.getFullYear(); _m=t.getMonth();
  if(!ADMIN){ gel('wrap').innerHTML='<div class="deny">🔒 대표자 일정은 <b>총괄관리자</b>만 볼 수 있습니다.</div>'; return; }
  edInit(); try{ gel('lateDays').value=lateDaysGet(); lateDaysTip(lateDaysGet()); }catch(e){} gel('cal').addEventListener('scroll', function(){ gel('calHd').scrollLeft=gel('cal').scrollLeft; }); load();
})();
</script>
</body>
</html>
