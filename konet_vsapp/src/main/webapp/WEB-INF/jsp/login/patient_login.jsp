<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<link href="/css/login.css" rel="stylesheet">
<script src="/bootstrap/js/bootstrap.bundle.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script type="text/javascript" src='/js/jqgrid_common.js'></script>
<script type="text/javascript" src='/js/jquery/common.js'></script>
<title>환자 로그인</title>
<script type="text/javaScript">
$(function() { $("#phone").focus(); });

function loginProc() {
	var phone = $.trim($("#phone").val());
	var pw    = $("#userPw").val();
	if (!phone) { alert("전화번호를 입력하세요."); $("#phone").focus(); return; }
	if (!pw)    { alert("비밀번호를 입력하세요."); $("#userPw").focus(); return; }

	$.ajax({
		type: "post",
		url:  CommonUtil.getContextPath() + "/patient/loginAct.do",
		data: JSON.stringify({ phone: phone, userPw: pw }),
		contentType: "application/json",
		dataType: "json",
		success: function(data){
			if (!data.IsSucceed) {
				alert(data.Message || "로그인 실패");
				return;
			}
			location.href = CommonUtil.getContextPath() + "/main.do";
		},
		error: function(){ alert("로그인 요청 중 오류가 발생했습니다."); }
	});
}

function goRegister(){
	location.href = CommonUtil.getContextPath() + "/patient/register.do";
}

function hitEnter(e){ if (e.keyCode === 13) loginProc(); }
</script>
</head>
<body>
  <div id="login" class="container">
    <div class="login-box">
      <div class="login-wrap">
        <h1>AI 기반 디지털 헬스케어 — 환자 포털</h1>
        <div class="id-box w-100">
          <h2>환자 로그인</h2>
          <input name="phone" class="form-control" type="text" id="phone" placeholder="전화번호 (-없이 숫자만)" maxlength="11" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" onkeypress="hitEnter(event);">
          <input type="password" class="form-control mt-3" id="userPw" placeholder="비밀번호" onkeypress="hitEnter(event);">
        </div>
        <button type="button" class="btn btn-primary btn-lg w-100 mt-2" onclick="loginProc();">로그인</button>
        <div class="set-btn-box w-100">
          <button type="button" class="btn btn-outline-dark" onclick="goRegister();">회원가입</button>
          <button type="button" class="btn btn-outline-dark" onclick="location.href='/login.do';">의료진 로그인</button>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
