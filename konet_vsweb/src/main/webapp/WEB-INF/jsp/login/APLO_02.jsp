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
<title>비밀번호 초기화</title>
<script type="text/javaScript">
	// ui-message.js 미로딩 대비 안전망 — 로드되면 자동 스킵
	if (typeof window._alertBox !== 'function') { window._alertBox = function(m,o){ o=o||{}; alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); if(o.onOk)o.onOk(); }; }
	if (typeof window._confirmBox !== 'function') { window._confirmBox = function(o){ o=o||{}; var m=String(o.msg||'진행할까요?').replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,''); if(confirm(m)){ if(o.onOk)o.onOk(); } else { if(o.onCancel)o.onCancel(); } }; }

	function fnSave(){

		if( $("#compCd").val() == ""){
			_alertBox("회사코드를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#compCd").focus(); }});
			return;
		}else if( $("#userId").val() == ""){
			_alertBox("사용자 ID를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#userId").focus(); }});
			return;
		}

		_confirmBox({
			icon:'🔑', okText:'초기화', okColor:'blue',
			msg:'해당 사용자의 비밀번호를 초기화하시겠습니까?',
			onOk:function(){
				$.ajax( {
					type : "post",
					url : CommonUtil.getContextPath() + "/json/user/pwdresetAct.do",
					data : {compCd : $("#compCd").val(), userId : $("#userId").val()},
					dataType : "json",
					success : function(data) {
						if(data.error_code != "0"){
							_alertBox(data.error_msg, {icon:'❌', okColor:'red', onOk:function(){ $("#userId").focus(); }});
						}else{
							_alertBox("비밀번호가 '1234'로 초기화되었습니다.<br>비밀번호를 변경 후 로그인 하세요.", {icon:'✅', onOk:function(){ fnPwdChange(); }});
						}
					}
				});
			}
		});
	}
	function fnPwdChange(){ 
		var popupwidth = '550';
		var popupheight = '400';  
		var url = CommonUtil.getContextPath() + "/popup/pwdchg.do";   
		 		
		var LeftPosition = (screen.width-popupwidth)/2;
		var TopPosition  = (screen.height-popupheight)/2; 
		var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
		if(oPopup){oPopup.focus();}
		   
	}
</script>    
 
</head>

<body>  
  
  <div id="login" class="container">

    <div class="set-pass-box">
      <div class="set-pass-wrap">
        <h3>비밀번호 초기화</h3>
        <div class="pass-box w-100">
          <input name="compCd" class="form-control" type="text" id="compCd" placeholder="회사코드" aria-label="회사코드">
          <input name="userId" class="form-control mt-2" type="text" id="userId" placeholder="사용자ID" aria-label="사용자ID">
        </div>
        <div class="set-btn-box w-100">
          <button type="button" class="btn btn-outline-dark" onclick="window.close();">취소</button>
          <button type="button" class="btn btn-primary" onclick="javascript:fnSave();">변경</button>
        </div>
      </div>
    </div>

  </div>


  </body>
</html>
