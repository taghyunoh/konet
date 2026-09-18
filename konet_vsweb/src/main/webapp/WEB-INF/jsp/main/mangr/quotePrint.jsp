<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>견적서<c:if test="${not empty mst}"> — ${mst.docNo}</c:if></title>
<!--
  견적서 인쇄 (2026-09-17 신설) — /mangr/quotePrint.do?quoteSeq= . 양식은 우리 견적서 엑셀(260729-1 · 260730-1)과 같은 꼴 :
  왼쪽 수급자(문서번호·수신·견적일·담당자·유효기간) | 오른쪽 공급자(사업번호·상호·대표·주소·업태·팩스) | 제목 줄 | 품목 표(단가 묶음 1~2) | 비고 | 하단 회사명.
  공급자 값은 company.properties 가 우선, 없으면 회사 마스터(발주서 인쇄와 같은 규칙).
  · ★단가 묶음은 <값이 실제로 든 것만> 그린다 (2026-09-17 「센터배송/택배출고 없으면 출력하지 말고 선택한 내용만」) —
    PRICE2_NM 이 있어도 둘째 단가가 전부 비면 묶음 하나 양식으로(옛 저장분 대비 — 새 저장분은 저장 때부터 price2Nm 이 비워져 온다).
  · ★하단 합계 줄은 그리지 않는다 (2026-09-17 「하단 합계 내역은 출력 제외」).
  · 품명·규격·비고가 칸을 넘치면 줄 높이(26px) 안에서 글자를 줄여 두 줄로 접는다 (2026-09-17 「넘칠 때 두 줄로」 — 거래명세서와 같은 수법, 셋째 줄부터 자름).
-->
<style>
  *{ box-sizing:border-box; }
  body{ margin:0; background:#f2f3f5; font-family:'맑은 고딕','Malgun Gothic',sans-serif; color:#111; font-size:13px; }
  .bar{ display:flex; gap:8px; align-items:center; padding:10px 14px; background:#fff; border-bottom:1px solid #dbe2ea; }
  .bar b{ font-size:15px; color:#137a6c; margin-right:auto; }
  .bar button{ height:34px; padding:0 14px; border:1px solid #cfd8e3; border-radius:7px; background:#fff; font-weight:700; cursor:pointer; font-size:13px; }
  .bar button.p{ background:#137a6c; color:#fff; border-color:#137a6c; }
  .sheet{ width:210mm; min-height:297mm; margin:14px auto; background:#fff; padding:14mm 12mm; box-shadow:0 4px 20px rgba(0,0,0,.12); }
  h1{ text-align:center; font-size:30px; letter-spacing:14px; margin:0 0 14px; text-decoration:underline; text-underline-offset:6px; }
  table{ border-collapse:collapse; width:100%; table-layout:fixed; }
  td,th{ border:1px solid #222; padding:4px 6px; font-size:12.5px; height:26px; }
  .k{ background:#f6f7f9; text-align:center; font-weight:700; }
  .r{ text-align:right; } .c{ text-align:center; } .l{ text-align:left; }
  .side{ writing-mode:vertical-rl; text-orientation:upright; letter-spacing:6px; font-weight:800; text-align:center; width:22px; padding:0; }
  .hd td{ height:28px; }
  .title{ margin:10px 0 6px; font-size:13px; }
  .items thead td{ background:#f6f7f9; font-weight:700; text-align:center; white-space:nowrap; font-size:12px; padding:4px 2px; }
  /* 품목 표가 종이 아래까지 (2026-09-17 「양식은 하단까지」) — 빈 줄을 22~24줄 채운다 */
  .items td{ height:26px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
  /* ★품명·규격·비고 = 글자 원래 크기 그대로 두고 <여러 줄 내려쓰기> (2026-09-18 「글자 커지고 내려쓰기로」 — 종전 「10.5px 로 줄여 두 줄 클램프」(09-17)를 대체.
     줄이 길면 그 행 높이가 자란다(26px 은 최소) — 긴 품명이 많으면 종이가 길어질 수 있다 */
  .items td.wrap{ white-space:normal; line-height:1.25; font-size:12.5px; padding-top:2px; padding-bottom:2px; }
  .items td.wrap .tx{ word-break:break-all; }
  /* 숫자 칸(수량·단가·금액)도 넘치면 말줄임(…) 대신 아랫줄로 (2026-09-18 「글자 오버되는 아래로 내려쓰기」 — 칸을 넓혀 보통은 한 줄, 넘칠 때만 두 줄로 접힘) */
  .items tbody td.r{ white-space:normal; word-break:break-all; line-height:1.1; font-size:11.5px; }
  .foot td{ font-weight:700; }
  .rmk{ margin-top:8px; font-size:12.5px; white-space:pre-wrap; min-height:40px; border:1px solid #222; padding:6px 8px; }
  .comp{ margin-top:14px; text-align:right; font-size:13px; font-weight:700; }
  .none{ text-align:center; padding:60px 20px; color:#8a97a4; font-size:16px; }
  @media print { body{ background:#fff; } .bar{ display:none; } .sheet{ width:auto; min-height:auto; margin:0; padding:0; box-shadow:none; } @page{ size:A4 portrait; margin:12mm 10mm; } }
</style>
</head>
<body>
<div class="bar">
  <b>📄 견적서<c:if test="${not empty mst}"> — ${mst.docNo} · ${fn:substring(mst.quoteDt,0,4)}-${fn:substring(mst.quoteDt,4,6)}-${fn:substring(mst.quoteDt,6,8)} · ${mst.recvNm}</c:if></b>
  <button class="p" onclick="window.print()">🖨 인쇄</button>
  <button onclick="window.close()">닫기</button>
</div>
<div class="sheet">
<c:choose>
<c:when test="${empty mst}">
  <div class="none">견적서를 찾을 수 없습니다.<br><span style="font-size:13px">삭제됐거나 번호가 잘못되었습니다.</span></div>
</c:when>
<c:otherwise>
  <%-- ★둘째 묶음은 값이 실제로 든 줄이 있을 때만 (2026-09-17 「선택한 내용만 기입」) --%>
  <c:set var="any2" value="false"/>
  <c:forEach var="it" items="${items}"><c:if test="${not empty it.unitPrice2 and it.unitPrice2 > 0}"><c:set var="any2" value="true"/></c:if></c:forEach>
  <c:set var="has2" value="${not empty mst.price2Nm and any2}"/>
  <h1>견 적 서</h1>
  <table class="hd">
    <colgroup><col style="width:5%"><col style="width:14%"><col style="width:31%"><col style="width:5%"><col style="width:14%"><col style="width:31%"></colgroup>
    <tr><td class="side" rowspan="5">수급자</td><td class="k">문서 번호</td><td class="l"><b>${mst.docNo}</b></td>
        <td class="side" rowspan="5">공급자</td><td class="k">사업 번호</td><td class="c">${comp.busiNum}</td></tr>
    <tr><td class="k">수 신</td><td class="l">${mst.recvNm}</td><td class="k">상 호</td><td class="c">${comp.compNm}</td></tr>
    <tr><td class="k">견적일</td><td class="l">${fn:substring(mst.quoteDt,0,4)}-${fn:substring(mst.quoteDt,4,6)}-${fn:substring(mst.quoteDt,6,8)}</td><td class="k">대표이사</td><td class="c">${comp.compCeo}</td></tr>
    <tr><td class="k">담당자</td><td class="l">${mst.mgrNm}</td><td class="k">주 소</td><td class="l wrap" style="white-space:normal;font-size:11.5px">${comp.compAddr}</td></tr>
    <tr><td class="k">유효기간</td><td class="l">${mst.validTxt}</td><td class="k">업 태</td><td class="c">${comp.compType}<c:if test="${not empty comp.compFax}"> · 팩스 ${comp.compFax}</c:if></td></tr>
  </table>
  <div class="title">${empty mst.titleTxt ? '아래와 같이 견적을 드립니다.(부가세 별도)' : mst.titleTxt}</div>
  <table class="items">
    <c:choose>
      <c:when test="${has2}">
        <%-- 칸 폭 (2026-09-18 「단가가 잘림 — 품명·규격은 조금 축소」) : 품명 24→21 · 규격 26→22 로 줄이고 단가 8→10 · 금액 9→11 로 넓힘 --%>
        <%-- 비고(MOQ) 9→11% (2026-09-18 「비고 칸 늘려주세요」) + 품명 21→19 · 규격 22→18 (「규격·품명 줄이고」 — 내려쓰기로 받는다. 단가·금액 폭은 ⑨ 확정 그대로) --%>
        <colgroup><col style="width:19%"><col style="width:18%"><col style="width:6%"><col style="width:8%"><col style="width:10%"><col style="width:11%"><col style="width:10%"><col style="width:11%"><col style="width:11%"></colgroup>
        <thead>
          <tr><td rowspan="2">품목</td><td rowspan="2">규격 및 재질</td><td>단위</td><td>수량</td><td colspan="2">${mst.price1Nm}</td><td colspan="2">${mst.price2Nm}</td><td rowspan="2">비고<br>(MOQ)</td></tr>
          <tr><td>box</td><td>ea</td><td>단가</td><td>금액</td><td>단가</td><td>금액</td></tr>
        </thead>
      </c:when>
      <c:otherwise>
        <%-- 비고 12→16% (2026-09-18 「비고 칸 늘려주세요」) + 품명 27→22 · 규격 31→25 (「규격·품명 줄이고」 — 긴 글자는 내려쓰기로 받는다) --%>
        <colgroup><col style="width:22%"><col style="width:25%"><col style="width:7%"><col style="width:9%"><col style="width:10%"><col style="width:12%"><col style="width:16%"></colgroup>
        <thead>
          <tr><td rowspan="2">품명</td><td rowspan="2">규격</td><td>단위</td><td>수량</td><td rowspan="2">단가</td><td rowspan="2">금액</td><td rowspan="2">비고</td></tr>
          <tr><td>Box</td><td>ea</td></tr>
        </thead>
      </c:otherwise>
    </c:choose>
    <tbody>
    <c:forEach var="it" items="${items}">
      <tr><td class="l wrap"><div class="tx">${it.prodNm}</div></td><td class="l wrap"><div class="tx">${it.spec}</div></td>
          <td class="c"><c:if test="${not empty it.boxQty}"><fmt:formatNumber value="${it.boxQty}" pattern="#,##0.##"/></c:if></td>
          <td class="r"><fmt:formatNumber value="${it.qty}" pattern="#,##0.##"/></td>
          <%-- 단가·금액 0 은 빈칸 (2026-09-18) — 원가 포함 품명비 줄(단가에 이미 반영·비고에 근거)이 0 으로 찍히지 않게 --%>
          <td class="r"><c:if test="${not empty it.unitPrice and it.unitPrice > 0}"><fmt:formatNumber value="${it.unitPrice}" pattern="#,##0.##"/></c:if></td>
          <td class="r"><c:if test="${not empty it.amt and it.amt > 0}"><fmt:formatNumber value="${it.amt}" pattern="#,##0"/></c:if></td>
          <c:if test="${has2}">
          <td class="r"><c:if test="${not empty it.unitPrice2 and it.unitPrice2 > 0}"><fmt:formatNumber value="${it.unitPrice2}" pattern="#,##0.##"/></c:if></td>
          <td class="r"><c:if test="${not empty it.amt2 and it.amt2 > 0}"><fmt:formatNumber value="${it.amt2}" pattern="#,##0"/></c:if></td>
          </c:if>
          <td class="l wrap"><div class="tx">${it.remark}</div></td></tr>
    </c:forEach>
    <c:forEach begin="${fn:length(items) + 1}" end="${has2 ? 21 : 23}" var="i">
      <tr><td></td><td></td><td></td><td></td><td></td><td></td><c:if test="${has2}"><td></td><td></td></c:if><td></td></tr>
    </c:forEach>
    </tbody>
    <%-- 하단 합계 줄은 출력하지 않는다 (2026-09-17 「하단 합계 내역은 출력 제외」 — 되살리려면 여기 tfoot 으로) --%>
  </table>
  <div class="rmk">비고 : ${mst.remark}</div>
  <div class="comp">${comp.compNm}<c:if test="${not empty comp.compTel}"> · ${comp.compTel}</c:if></div>
</c:otherwise>
</c:choose>
</div>
</body>
</html>
