<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>    
	
	<!-- JQuery 관련
	<script type="text/javascript" src='/js/common.js'></script>
	<script type="text/javascript" src='/css/common.css'></script>
	<link rel="stylesheet" href="/js/jquery/grid/css/jquery-ui.css" />
	<script type="text/javascript" src='<c:url value='/js/jqgrid_common.js'/>'></script>
	<script type="text/javascript" src='<c:url value='/js/jquery/grid/jquery-1.9.0.min.js'/>'></script>
	<script type="text/javascript" src='<c:url value='/js/jquery/grid/jquery.jqGrid.min.js'/>'></script>
	<script type="text/javascript" src='<c:url value='/js/jquery/grid/jquery.jqGrid.src.js'/>'></script>
	<script type="text/javascript" src='<c:url value='/js/jquery/grid/grid.locale-kr.js'/>'></script>
	<script type="text/javascript" src='<c:url value='/js/jquery/jquery.form.js'/>'></script>
	<script type="text/javascript" src='<c:url value='/js/jquery/jquery.form.min.js'/>'></script>
	<script type="text/javascript" src='<c:url value='/js/jquery/jquery-ui.js'/>'></script> 
	<script type="text/javascript" src='<c:url value='/js/jquery/jquery-ui.min.js'/>'></script>  
	<script type="text/javascript" src='<c:url value='/asset/js/commonUtil.js'/>'></script>  -->
	
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<%@ page import ="java.util.Date" %>
<%
	Date nowTime = new Date();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<head>
<%@ include file="/WEB-INF/jsp/main/com/head.jsp"%>    

<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> </meta>
<meta http-equiv="X-UA-Compatible" content="IE=edge"> </meta>
<meta name="description" content="">  </meta>

<!-- 부트스트랩 js -->
<script type="text/javascript" src="/bootstrap/js/bootstrap.bundle.js"></script> 
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- datepicker js -->
<script type="text/javascript" src="/asset/js/datepicker/jquery.min.js"></script>
<script type="text/javascript" src="/asset/js/datepicker/moment.min.js"></script>
<script type="text/javascript" src="/asset/js/datepicker/daterangepicker.min.js"></script>
<!-- Page js -->   
<script type="text/javascript" src="/asset/js/pagination.js"></script>
<!-- 데이트피커 년월 js -->
<script type="text/javascript" src="/asset/js/monthpicker/bootstrap-monthpicker.js"></script>
<script src="/js/layout.js"></script>   
<script src="/js/common.js"></script> 
<script type="text/javascript" src='/asset/js/jquery/common.js'></script>

	<script type="text/javascript">
		sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
	</script>
<script type="text/javascript">
 sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>

<!-- Font 및 animate 추후 수정  -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />
<link rel="stylesheet" type="text/css" href="<c:url value='/asset/css/style.css'/>"/>	
	
<!-- JQuery 관련 -->
<script type="text/javascript" src='/asset/js/jquery/common.js'></script>
<script type="text/javascript" src="<c:url value='/asset/js/jquery-3.5.1.min.js'/>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/commonUtil.js'/>?date=<%= nowTime %>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/app-common.js'/>?date=<%= nowTime %>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/plugins.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/asset/js/default.js'/>"></script>
<script type="text/javascript" src="<c:url value='/asset/js/tmpl.min.js' />"></script>

</head>   

	