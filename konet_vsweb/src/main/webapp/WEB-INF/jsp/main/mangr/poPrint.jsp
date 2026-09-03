<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>발주서<c:if test="${not empty mst}"> — ${mst.vendorNm}</c:if></title>
<!--
  발주서 인쇄/공개 보기 (2026-09-03 신설)
  · /mangr/poPrint.do?poSeq=   : 로그인 사용자의 인쇄 창 (버튼 : 🖨 인쇄 · 닫기)
  · /pub/po.do?t=토큰          : 카톡 카드가 여는 공개 페이지 — 로그인 없이 이 발주서 하나만 읽는다(pub=true). 토큰이 틀리면 안내만.
  · 양식은 홀세일닥터 발주서와 같은 꼴 : 발주일 · 거래처 귀하 · 합계액 | 공급받는자(우리 회사) | 품목 20줄 | 공급가·세액·합계
  · 카톡 카드 미리보기(og:) 태그 — 링크만 붙여 넣어도 제목·설명이 보인다
-->
<c:if test="${not empty mst}">
<meta property="og:title" content="발주서 — ${mst.vendorNm} (${fn:substring(mst.poDt,0,4)}-${fn:substring(mst.poDt,4,6)}-${fn:substring(mst.poDt,6,8)})">
<meta property="og:description" content="합계 <fmt:formatNumber value="${mst.totAmt}" pattern="#,##0"/>원 · 품목 ${fn:length(items)}종 · ${comp.compNm}">
</c:if>
<style>
  *{ box-sizing:border-box; }
  body{ margin:0; background:#f2f3f5; font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#111; font-size:13px; }
  .bar{ display:flex; gap:8px; align-items:center; padding:10px 14px; background:#fff; border-bottom:1px solid #dbe2ea; }
  .bar b{ font-size:15px; color:#137a6c; margin-right:auto; }
  .bar button{ height:34px; padding:0 14px; border:1px solid #cfd8e3; border-radius:7px; background:#fff; font-weight:700; cursor:pointer; font-size:13px; }
  .bar button.p{ background:#137a6c; color:#fff; border-color:#137a6c; }
  .sheet{ width:210mm; min-height:297mm; margin:14px auto; background:#fff; padding:12mm 10mm; box-shadow:0 4px 20px rgba(0,0,0,.12); }
  table{ border-collapse:collapse; width:100%; table-layout:fixed; }
  td,th{ border:1px solid #222; padding:4px 6px; font-size:12.5px; height:26px; }
  h1{ text-align:center; font-size:30px; letter-spacing:12px; margin:0 0 10px; }
  .hd td{ height:28px; }
  .k{ background:#f6f7f9; text-align:center; font-weight:700; }
  .r{ text-align:right; } .c{ text-align:center; } .l{ text-align:left; }
  .items td{ height:26px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .items thead td{ background:#f6f7f9; font-weight:700; text-align:center; }
  .foot td{ font-weight:700; }
  .none{ text-align:center; padding:60px 20px; color:#8a97a4; font-size:16px; }
  @media print { body{ background:#fff; } .bar{ display:none; } .sheet{ width:auto; min-height:auto; margin:0; padding:0; box-shadow:none; } @page{ size:A4 portrait; margin:12mm 10mm; } }
</style>
</head>
<body>
<div class="bar">
  <b>📋 발주서<c:if test="${not empty mst}"> — ${mst.vendorNm} · ${fn:substring(mst.poDt,0,4)}-${fn:substring(mst.poDt,4,6)}-${fn:substring(mst.poDt,6,8)} · ${mst.poNo}</c:if></b>
  <button class="p" onclick="window.print()">🖨 인쇄</button>
  <c:if test="${!pub}"><button onclick="window.close()">닫기</button></c:if>
</div>
<div class="sheet">
<c:choose>
<c:when test="${empty mst}">
  <div class="none">발주서를 찾을 수 없습니다.<br><span style="font-size:13px">링크가 잘못되었거나 발주서가 삭제되었습니다.</span></div>
</c:when>
<c:otherwise>
  <h1>발 주 서</h1>
  <table class="hd">
    <colgroup><col style="width:16%"><col style="width:16%"><col style="width:4%"><col style="width:12%"><col style="width:22%"><col style="width:9%"><col style="width:21%"></colgroup>
    <tr><td colspan="2" class="c">${fn:substring(mst.poDt,0,4)}년 ${fn:substring(mst.poDt,4,6)}월 ${fn:substring(mst.poDt,6,8)}일</td>
        <td rowspan="4" class="c" style="font-weight:700; line-height:1.15">공<br>급<br>받<br>는<br>자</td>
        <td class="k">등록번호</td><td colspan="3" class="c">${comp.busiNum}</td></tr>
    <tr><td colspan="2" class="c">아래와 같이 발주합니다.</td>
        <td class="k">상호</td><td class="c">${comp.compNm}</td><td class="k">성명</td><td class="c">${comp.compCeo}</td></tr>
    <tr><td colspan="2" class="r"><b>${mst.vendorNm}</b> 귀하</td>
        <td class="k">사업장</td><td colspan="3" class="l">${comp.compAddr}</td></tr>
    <tr><td class="k">합계액</td><td class="r"><b><fmt:formatNumber value="${mst.totAmt}" pattern="#,##0"/></b> 원정</td>
        <td class="k">전화번호</td><td colspan="3" class="c">${comp.compTel}</td></tr>
  </table>
  <table class="items" style="margin-top:6px">
    <colgroup><col style="width:6%"><col style="width:36%"><col style="width:14%"><col style="width:11%"><col style="width:9%"><col style="width:12%"><col style="width:12%"></colgroup>
    <thead><tr><td>번호</td><td>품명</td><td>규격</td><td>BOX/EA수량</td><td>총수량</td><td>BOX/EA단가</td><td>공급가액</td></tr></thead>
    <tbody>
    <c:forEach var="it" items="${items}" varStatus="s">
      <tr><td class="c">${s.index + 1}</td><td class="l" title="${it.prodNm}">${it.prodNm}</td><td class="l" title="${it.spec}">${it.spec}</td>
          <td class="r"><fmt:formatNumber value="${it.boxQty}" pattern="#,##0.##"/>/<fmt:formatNumber value="${it.eaQty}" pattern="#,##0.##"/></td>
          <td class="r"><fmt:formatNumber value="${it.qty}" pattern="#,##0.##"/></td>
          <td class="r"><fmt:formatNumber value="${it.unitPrice * (empty it.packQty or it.packQty == 0 ? 1 : it.packQty)}" pattern="#,##0"/>/<fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/></td>
          <td class="r"><fmt:formatNumber value="${it.supplyAmt}" pattern="#,##0"/></td></tr>
    </c:forEach>
    <c:forEach begin="${fn:length(items) + 1}" end="20" var="i"><tr><td class="c">${i}</td><td></td><td></td><td></td><td></td><td></td><td></td></tr></c:forEach>
    </tbody>
    <tfoot class="foot">
      <tr><td class="k">비고</td><td colspan="2" class="l" rowspan="3" style="vertical-align:top; white-space:normal">${mst.remark}</td><td colspan="3" class="c">공 급 가 총 액</td><td class="r"><fmt:formatNumber value="${mst.supplyAmt}" pattern="#,##0"/></td></tr>
      <tr><td style="border-right:0"></td><td colspan="3" class="c">세 액 ( 부가가치세 )</td><td class="r"><fmt:formatNumber value="${mst.vatAmt}" pattern="#,##0"/></td></tr>
      <tr><td style="border-right:0"></td><td colspan="3" class="c">합 계 금 액</td><td class="r"><fmt:formatNumber value="${mst.totAmt}" pattern="#,##0"/></td></tr>
    </tfoot>
  </table>
  <div style="margin-top:8px; font-size:11.5px; color:#555">담당 ${mst.mgrNm} · 발주번호 ${mst.poDt}-${mst.poNo}<c:if test="${!pub}"> · 공유 ${mst.shareCnt}회</c:if></div>
</c:otherwise>
</c:choose>
</div>
</body>
</html>
