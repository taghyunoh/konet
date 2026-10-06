<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<head>
<%-- http 로 들어오면 https 로 (2026-10-06) — 운영 nginx 가 http(80)도 그대로 받아 주어, 로그아웃 뒤 http 화면에 머무르는 일이 있었다.
     allcare24.kr 에서만 동작(로컬·IP 접속은 그대로). 근본 해결은 nginx 에서 80 → 443 301. --%>
<script>(function(l){if(l.protocol==='http:'&&/(^|\.)allcare24\.kr$/i.test(l.hostname)){l.replace('https://'+l.host+l.pathname+l.search+l.hash);}})(location);</script>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<tiles:insertAttribute name="header" />
</head>
<body>
	<div id="wrap" class="wrap">
		<div id="header">
		</div>
		<div id="contents">
		<tiles:insertAttribute name="content" />	
		<%-- <tiles:insertAttribute name="foot" /> --%>
		</div>
	</div>
</body>