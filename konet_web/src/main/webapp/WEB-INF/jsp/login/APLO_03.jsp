<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<!DOCTYPE html>
<html>
 <head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" /> 
<!-- Bootstrap CSS -->
<link href="/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="/asset/css/common.css" rel="stylesheet">
<link href="/css/login.css" rel="stylesheet">
<!-- 부트스트랩 js -->
<script src="/bootstrap/js/bootstrap.bundle.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script type="text/javascript" src='/js/jqgrid_common.js'></script>
<script type="text/javascript" src='/js/jquery/common.js'></script>
<script type="text/javascript" src='/asset/js/ui-message.js'></script>
<title>비밀번호 변경</title>
<script type="text/javaScript">
	// ui-message.js 미로딩 대비 안전망 — 로드되면 자동 스킵
	if (typeof window._alertBox !== 'function') { window._alertBox = function(m,o){ o=o||{}; alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); if(o.onOk)o.onOk(); }; }

	function fnSave(){

		if( $("#compCd").val() == ""){
			_alertBox("회사코드를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#compCd").focus(); }});
			return;
		}else if( $("#userId").val() == ""){
			_alertBox("사용자 ID를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#userId").focus(); }});
			return;
		}else if( $("#userPw").val() == "") {
			_alertBox("현재 비밀번호를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#userPw").focus(); }});
			return;
		}else if( $("#bfUserPwd").val() != $("#afUserPwd").val()) {
			_alertBox("변경할 비밀번호가 서로 일치하지 않습니다.", {icon:'⚠️', onOk:function(){ $("#bfUserPwd").focus(); }});
			return;
		}

		var formData = $("form[name='regForm']").serialize();

		$.ajax( {
			type : "post",
			url : CommonUtil.getContextPath() + "/json/user/pwdchgAct.do",
			data : formData,
			dataType : "json",
			success : function(data) {

				if(data.error_code != "0"){
					_alertBox(data.error_msg, {icon:'❌', okColor:'red', onOk:function(){ $("#userId").focus(); }});
				}else{
					_alertBox("비밀번호가 변경되었습니다.", {icon:'✅', onOk:function(){ window.close(); }});
				}
			}
		});

	}

</script>
 
</head>

<body>  
  
  <div id="login" class="container">

    <div class="set-pass-box">
      <div class="set-pass-wrap">
       <form:form commandName="DTO" id="regForm" name="regForm" method="post">
        <h3>비밀번호 변경</h3>
        <div class="pass-box w-100">
          <input name="compCd" class="form-control" type="text" id="compCd" placeholder="회사코드">
          <input name="userId" class="form-control mt-2" type="text" id="userId" placeholder="사용자ID">
          <input type="password" class="form-control mt-2" id="userPw" name="userPw" placeholder="현재 비밀번호">
          <input type="password" class="form-control mt-2" id="bfUserPwd" name="bfUserPwd"  placeholder="변경 비밀번호">
          <input type="password" class="form-control mt-2" id="afUserPwd" name="afUserPwd"  placeholder="변경 비밀번호 확인">
        </div>
		</form:form>
        <div class="set-btn-box w-100">
          <button type="button" class="btn btn-outline-dark" onclick="window.close();">취소</button>
          <button type="button" class="btn btn-primary" onclick="javascript:fnSave();">변경</button>
        </div>
      </div>
    </div>

  </div>


  </body>
</html>
