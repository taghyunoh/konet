<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>거래명세서<c:if test="${not empty ogTitle}"> — ${ogTitle}</c:if></title>
<!--
  ★공개 거래명세서 (2026-09-09 신설) — /pub/stmt.do?t=토큰
    · 카톡 카드·이메일이 여는 주소. 받는 쪽(거래처)은 <로그인 없이> 이 전표 하나만 본다.
    · 토큰이 없거나 틀리면 아래 안내만 뜬다 — 서비스(selectSalesTrxByToken)가 빈 토큰을 거절하므로
      전표 목록이 새어 나갈 길이 없다.
    · ★명세서를 그리는 코드는 판매등록 화면과 **같은 파일**을 쓴다 : asset/js/stmt-sheet.js
      양식을 두 벌로 만들면 <보낸 명세서>와 <내가 찍은 명세서>가 조용히 달라진다.
    · ★조건은 <보낸 사람이 고른 그대로>다 (2026-09-10) — 주소 뒤 &o= 로 온다(잔고를 고르면 &b= 로 그때의 잔고까지).
      [👁 미리보기]로 본 것과 받는 쪽이 보는 것이 같아야 한다. 조건이 없는 <옛 링크>는 종전 고정 조건
      (공급받는자용 한 부 · 38줄 · 잔고·단가변동 없음)으로 나온다 — 컨트롤러 stmtJson 참고.
    · 발주서 공개 페이지(poPrint.jsp / /pub/po.do)와 같은 꼴이다.
-->
<c:if test="${not empty ogTitle}">
<meta property="og:title" content="${ogTitle}">
<meta property="og:description" content="${ogDesc}">
</c:if>
<script src="${pageContext.request.contextPath}/asset/js/stmt-sheet.js?v=20260911"></script>
<style id="stmtCss"></style>
<style>
  .none{ text-align:center; padding:70px 20px; color:#8a97a4; font-size:16px;
         font-family:'맑은 고딕','Malgun Gothic',sans-serif; }
  .none b{ color:#5a6b7a; }
</style>
</head>
<body>
<c:choose>
<c:when test="${notFound}">
  <div class="none"><b>거래명세서를 찾을 수 없습니다.</b><br>
    <span style="font-size:13px">주소가 잘못되었거나, 보낸 쪽에서 링크를 내렸습니다.</span></div>
</c:when>
<c:otherwise>
  <div class="bar">
    <b id="stmtTit">🧾 거래명세서</b>
    <button class="p" onclick="window.print()">🖨 인쇄</button>
  </div>
  <div id="stmtSheet"></div>
  <script>
  (function(){
    /* 컨트롤러(stmtJson)가 만들어 준 자료 한 덩어리 — 화면(salesReg)이 넘기는 D·O·S·직전단가 와 같은 모양이다.
       P = 직전 판매단가 {상품코드:단가} — 「단가변동 = 예」로 보냈을 때만 채워져 온다(아니면 빈 객체). */
    var DATA = ${dataJson};
    document.getElementById('stmtCss').textContent = konetStmt.css;
    var P = DATA.P || null;
    var r = konetStmt.body(DATA.D, DATA.O, DATA.S, (P && Object.keys(P).length) ? P : null);
    document.getElementById('stmtSheet').innerHTML = r.html;
    document.getElementById('stmtTit').textContent =
        '🧾 거래명세서 — ' + (DATA.D.venNm||'') + ' ' + (DATA.D.dt||'') + (DATA.D.no ? ' / '+DATA.D.no : '');
    /* 넘치는 주소·품명·규격 칸을 두 줄로 (2026-09-10) — 그린 뒤 재고, 인쇄 직전에 한 번 더 */
    konetStmt.fit();
    window.addEventListener('load', konetStmt.fit);
    window.addEventListener('beforeprint', konetStmt.fit);
  })();
  </script>
</c:otherwise>
</c:choose>
</body>
</html>
