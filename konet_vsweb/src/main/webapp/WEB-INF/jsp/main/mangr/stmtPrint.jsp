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
    · 조건은 고정이다(컨트롤러 stmtJson 참고) — 금액·단가는 찍고, 부가세는 세액이 있을 때만,
      잔고·단가변동은 안 찍는다(우리 원장을 거래처에 보여 줄 이유가 없다). 공급받는자용 한 부.
    · 발주서 공개 페이지(poPrint.jsp / /pub/po.do)와 같은 꼴이다.
-->
<c:if test="${not empty ogTitle}">
<meta property="og:title" content="${ogTitle}">
<meta property="og:description" content="${ogDesc}">
</c:if>
<script src="${pageContext.request.contextPath}/asset/js/stmt-sheet.js?v=20260909"></script>
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
    /* 컨트롤러(stmtJson)가 만들어 준 자료 한 덩어리 — 화면(salesReg)이 넘기는 D·O·S 와 같은 모양이다 */
    var DATA = ${dataJson};
    document.getElementById('stmtCss').textContent = konetStmt.css;
    var r = konetStmt.body(DATA.D, DATA.O, DATA.S, null);
    document.getElementById('stmtSheet').innerHTML = r.html;
    document.getElementById('stmtTit').textContent =
        '🧾 거래명세서 — ' + (DATA.D.venNm||'') + ' ' + (DATA.D.dt||'') + (DATA.D.no ? ' / '+DATA.D.no : '');
  })();
  </script>
</c:otherwise>
</c:choose>
</body>
</html>
