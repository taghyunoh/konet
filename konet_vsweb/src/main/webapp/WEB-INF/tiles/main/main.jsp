<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
 <tiles:insertAttribute name="header" /> 
</head>
<body>
	<div id="wrap" class="wrap">
   	    <div id="header">
		<tiles:insertAttribute name="top" />
		</div>  
		<div id="contents">
		<tiles:insertAttribute name="content" />	
		</div>
	</div>
</body>