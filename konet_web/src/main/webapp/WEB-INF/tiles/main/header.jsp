<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>  
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

<html xmlns="http://www.w3.org/1999/xhtml">
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
<c:if test="${param.embed ne '1'}"><script src="/js/layout.js"></script></c:if>
<script src="/js/common.js"></script>
<script type="text/javascript" src='/asset/js/jquery/common.js'></script>

<script type="text/javascript">
 sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>

<!-- Font 및 animate 추후 수정  -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />
<link rel="stylesheet" type="text/css" href="<c:url value='/asset/css/style.css'/>?v=<%= nowTime.getTime() %>"/>
	
<!-- JQuery 관련 -->
<!-- <script type="text/javascript" src='/asset/js/jquery/common.js'></script>  --> 
<script type="text/javascript" src="<c:url value='/asset/js/jquery/common.js'/>"></script> 
<link   rel="stylesheet" href="/js/jquery/grid/css/jquery-ui.css" />
<script type="text/javascript" src="<c:url value='/asset/js/jquery-3.5.1.min.js'/>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/commonUtil.js'/>?date=<%= nowTime %>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/app-common.js'/>?date=<%= nowTime %>"></script> 
<script type="text/javascript" src="<c:url value='/asset/js/plugins.min.js'/>"></script>
<c:if test="${param.embed ne '1'}"><script type="text/javascript" src="<c:url value='/asset/js/default.js'/>"></script></c:if>
<script type="text/javascript" src="<c:url value='/asset/js/tmpl.min.js' />"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script> 
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>  
</head>  
<style>
	.black-btn {
	    color: black !important ;
	    border: none ;
	}
	
	.black-btn:hover {
	    background-color: #333 ; /* 호버 시 색상 변경 */
	    color: white ;
	}
</style>
<c:if test="${param.embed eq '1'}">
<style>
	/* 환자 대시보드 iframe(embed) — 헤더 제거 후 상단 빈 공간 제거 */
	html, body { margin:0 !important; padding:0 !important; }
	#header { display:none !important; }
	.gnb-container { display:none !important; }
</style>
</c:if>
<body>
<!-- 페이지 콘텐츠를 동적으로 업데이트할 div  -->
 <div id="contentArea">

  <!-- embed=1(환자 대시보드 iframe 등)일 때 공통 헤더 바 숨김 -->
  <c:if test="${param.embed ne '1'}">
  <nav class="navbar navbar-expand-lg bg-primary-v1 gnb-container">
    <div class="container-fluid">
         <div class="logo-wrap">
               <img src="/asset/img/logo_01.png" alt="allCare" />
        </div> 
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">
			<%-- konet: 기존 sejong 메뉴 전부 제거, 물류관리만 노출 (로그인 역할 무관) --%>
			<c:if test="${sessionScope['q_admin_yn'] == 'A' or sessionScope['q_admin_yn'] == 'D'}">
	          	<li class="menu-item" data-menu="08">
           			<a href="javascript:void(0);" onclick="loadMenuPage('/admin/logistics_demo.do');"><button id="logiBtn" class="btn" type="button">물류관리</button></a>
           		</li>
           </c:if>
        </ul>
      </div>
      
      <div class="login-info">
			<span class="user-name">${sessionScope['q_user_nm']}님</span>
        <button class="btn btn-sm btn-outline-dark" onclick="javascript:fnPwdChange();">비밀번호 변경</button> 
        <a class="logout" href="/user/loginOutAct.do">
          <img src="/asset/img/icon_logout_white.png" alt="로그아웃" />
        </a>
      </div>
    </nav>
  </c:if>
  </div>
  <!-- 페이지 콘텐츠를 동적으로 업데이트할 div  -->
</body>
<script>
  // 메뉴 클릭 시 AJAX로 페이지 콘텐츠 로드
  function loadMenuPage(url, clickedElement) {
	  // 중복된 메뉴를 방지하려면 기존에 로드된 콘텐츠를 지웁니다
    $(clickedElement).closest('li').addClass('active').siblings().removeClass('active');
 
    $.ajax({
      url: url,  // 요청할 URL
      method: "GET",  // HTTP 메소드
      cache: false,  // 캐시 비활성화 — 변경된 화면이 즉시 반영되도록
      success: function(response) {
   	  
        // 서버에서 받은 HTML을 contentArea에 삽입
        $('#contentArea').html(response);
 
        var modalElement = document.getElementById('adminModal');
        // 특정 조건을 체크 (예: 특정 값이 true일 때만 모달을 활성화)
        var condition = false; // 예시 조건, 필요에 따라 true/false로 설정
        if (modalElement && condition) {  // 조건이 true일 때만 모달을 초기화하고 열기
          if (window.adminModalInstance) {
            window.adminModalInstance.dispose(); // 기존 모달 인스턴스를 폐기
          }
       
          window.adminModalInstance = new bootstrap.Modal(modalElement);
          $('.btn-box').on('click', function() {
            window.adminModalInstance.show();  // 모달 열기
          });
        } else {
          // 조건이 false일 경우, 모달 열기 로직을 실행하지 않음
           console.log("조건이 맞지 않아 모달을 열지 않습니다.");
        }
        /*
        if (typeof execDaumPostcode === 'function') {
            execDaumPostcode();
        } else {
            console.error("execDaumPostcode 함수가 로드되지 않았습니다.");
        };
        */
      },
      error: function(xhr, status, error) {
        alert("페이지 로드 실패: " + error);
      }
    });
 }
</script>

<script type="text/javascript"> 
//--주메인 화면 들어오자마자 환자목록 뛰우기 jsp 에서는 변수처리 않됨 글로발 세션처리 한번만 타게 
//  window.onload 만 실행하면 반복적으로 실행되는 문제 처리  window.onload = null 않됨  
//
window.onload = function(){
    handleMenuClick() ;
} 

function handleMenuClick() {
  // konet 메인: 진입 즉시 물류관리 화면 자동 로드
  var logiBtn = document.getElementById("logiBtn");
  if (logiBtn) { logiBtn.click(); }
}
$(document).ready(function () {
    $('.menu-item').click(function () {
    $('.menu-item').removeClass('on');
    $(this).addClass('on');
   });
});


//비밀번호 초기화
function fnPwdChange(){ 
	
	var popupwidth = '550';
	var popupheight = '400';  
	var url = "/popup/Hpwdchg.do";   
	 		
	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2; 
	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
}
/////////////////////위너넷 
function fnPasswdChange(){ 
	
	var popupwidth = '550';
	var popupheight = '400';  
    var url = "/popup/base_pwdchg.do" ;
 
	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2; 
	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
}
//비밀번호 초기화
function fnPwdClear(){ 

	var popupwidth = '550';
	var popupheight = '400'; 
	var url = "";  

	url = CommonUtil.getContextPath() + "/popup/base_pwdclear.do";
	 		
 	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2;

	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
   
}
function fnPasswdmanager(){ 
	
	var popupwidth = '550';
	var popupheight = '400';  
    var url = "/popup/base_pwdmgr.do" ;
 
	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2; 
	var oPopup = window.open(url,"아이디비밀번호찾기","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
}
</script>  
</html>
 
 
 