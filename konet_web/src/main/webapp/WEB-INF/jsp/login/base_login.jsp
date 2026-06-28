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
<link href="${pageContext.request.contextPath}/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/asset/css/common.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/login.css" rel="stylesheet">
<style>

  /* ───────────────────────────────────────────────────────
     로그인 박스 — 모든 컨텐츠가 좌측 흰박스 안에 들어오게 강하게 압축
  ─────────────────────────────────────────────────────── */
  #login .login-box {
    display: flex !important;
    align-items: stretch !important;
    height: 520px !important;       /* login.css 의 400 → 520 (전체 박스 살짝 더 크게) */
    min-width: 0;                    /* 기존 880 제거 — max-width 가 적용되도록 */
    max-width: 540px;                /* 전체 박스 폭 제한 → 폼이 우측으로 과하게 늘어나지 않게 */
    width: 100%;
    margin: 0 auto;                  /* 가운데 정렬 */
    box-sizing: border-box;
  }
  #login .login-wrap {
    flex: 1 1 auto;
    display: flex;
    flex-direction: column;
    justify-content: center;       /* 컨텐츠를 박스 세로 중앙에 위치 */
    padding: 30px 22px !important; /* 좌우 18→22 (살짝 여유), 위아래 22→30 (상하 더 시원하게) */
    margin: 0 !important;           /* login.css 의 margin:0 50px 좌우 50px 빈공간 제거 */
    box-sizing: border-box;
    overflow: hidden;               /* 박스 밖으로 절대 안 나가게 */
  }
  #login .img-wrap {
    flex: 0 0 auto;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 8px;                  /* 이미지 좌우 살짝 여유 — 박스 가장자리에 붙지 않게 */
  }
  #login .img-wrap img {
    max-height: 100%;
    height: auto;
    max-width: 100%;                 /* 박스가 커져도 비율 유지하며 함께 커지도록 */
  }

  /* 박스 520px 에 맞춰 내부 컨텐츠 균형 — 충분한 간격으로 안정감 있게 */
  #login .login-wrap h1 {
    font-size: 30px !important;
    line-height: 1.25;
    margin: 0 0 22px 0;
    color: #1976d2;
    font-weight: 800;
    text-align: center;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;                       /* 로고와 제목 사이 간격 */
    transform: translateX(-22px);    /* 제목 줄(로고+텍스트) 살짝 왼쪽으로 이동 */
  }
  #login .login-wrap h1 .title-logo {  /* 제목 좌측 코네트 로고 */
    height: 72px;
    width: auto;
    flex: 0 0 auto;
  }
  #login .login-wrap .mb-3 {         /* "처음 방문하셨나요?" 배너 */
    margin-bottom: 16px !important;
    padding: 9px !important;
    font-size: 14px;
  }
  #login .login-wrap .id-box {
    margin-top: 4px;
  }
  #login .login-wrap .id-box h2 {    /* "로그인" 소제목 */
    font-size: 16px !important;
    margin: 6px 0 10px 0;
  }
  #login .login-wrap input.form-control {
    padding-top: 9px;
    padding-bottom: 9px;
    font-size: 14px;
    margin-top: 8px !important;
  }
  #login .login-wrap .id-box > div[style*="font-size:12px"] {  /* 안내문구 (※) */
    margin-top: 10px !important;
    font-size: 13px !important;
    line-height: 1.5;
  }
  #login .login-wrap .form-check {   /* 아이디 저장 */
    margin-top: 18px !important;
    margin-bottom: 4px;
    font-size: 14px;
  }
  #login .login-wrap .btn-primary.btn-lg {  /* 로그인 버튼 — 큼직하게 */
    padding-top: 13px;
    padding-bottom: 13px;
    margin-top: 10px !important;
    font-size: 16px;
    font-weight: 600;
  }
  #login .login-wrap .set-btn-box {  /* 비밀번호 초기화/변경 — 두 버튼이 가로폭 꽉 채우게 */
    margin-top: 14px;
    gap: 12px;
  }
  #login .login-wrap .set-btn-box .btn {
    flex: 1 1 0;        /* 가용 공간 균등 분할 — 두 버튼이 함께 폭 확장 */
    padding-top: 9px;
    padding-bottom: 9px;
    font-size: 16px;
  }
  /* 토스트·확인모달 스타일은 공통 ui-message.js 가 자동 주입 */
</style>
<!-- 부트스트랩 js -->
<script src="${pageContext.request.contextPath}/bootstrap/js/bootstrap.bundle.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script type="text/javascript" src='${pageContext.request.contextPath}/js/jqgrid_common.js'></script>
<script type="text/javascript" src='${pageContext.request.contextPath}/js/common.js'></script>
<script type="text/javascript" src='${pageContext.request.contextPath}/asset/js/ui-message.js'></script>
<title>로그인</title>
<script type="text/javaScript">
/*  Main Grid  *//*서브그리드 필요*/

// ID 저장 키 (localStorage)
var SAVED_USER_ID_KEY = "sejong_saved_user_id";

$(document).ready(function(){
	// 저장된 ID 복원
	try {
		var savedId = localStorage.getItem(SAVED_USER_ID_KEY);
		if (savedId) {
			$("#userId").val(savedId);
			$("#save_id").prop("checked", true);
			$("#userPw").focus();   // ID 자동입력 → 비밀번호 포커스
		} else {
			$("#userId").focus();
		}
	} catch (e) {
		// localStorage 미지원/차단 시 무시
		$("#userId").focus();
	}
});

// ID 저장 체크박스 처리 (체크 해제 즉시 저장값 삭제)
function fnSaveIdToggle(){
	try {
		if (!$("#save_id").is(":checked")) {
			localStorage.removeItem(SAVED_USER_ID_KEY);
		}
	} catch (e) {}
}

// _toast / _alertBox 는 공통 /asset/js/ui-message.js 에서 제공
// ui-message.js 미로딩(404 등) 대비 안전망 — 로드되면 자동 스킵
if (typeof window._toast !== 'function') { window._toast = function(m){ alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); }; }
if (typeof window._alertBox !== 'function') { window._alertBox = function(m,o){ o=o||{}; alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); if(o.onOk)o.onOk(); }; }
function loginproc2(){
	var id = $.trim($("#userId").val());
	var pw = $("#userPw").val();
	if (!id) { _alertBox("아이디 또는 전화번호를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#userId").focus(); }}); return; }
	if (!pw) { _alertBox("비밀번호를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#userPw").focus(); }}); return; }

	// 통합 로그인: 의료진(T_ADMIN_MST) 우선 → 환자(T_USER_TRAN) 자동 분기
	$.ajax({
		type: "post",
		url:  CommonUtil.getContextPath() + "/user/unifiedLoginAct.do",
		data: JSON.stringify({ idOrPhone: id, password: pw }),
		contentType: "application/json",
		dataType: "json",
		success: function(data) {
			if (!data.IsSucceed) {
				_alertBox(data.Message || "로그인 실패", {icon:'❌', okColor:'red', onOk:function(){ $("#userId").focus(); }});
				return;
			}
			// ID 저장 (성공 후에만)
			try {
				if ($("#save_id").is(":checked")) {
					localStorage.setItem(SAVED_USER_ID_KEY, id);
				} else {
					localStorage.removeItem(SAVED_USER_ID_KEY);
				}
			} catch (e) {}
			// /main.do 가 세션 q_admin_yn 으로 환자/의사 화면 자동 분기
			location.href = CommonUtil.getContextPath() + "/main.do";
		},
		error: function(){ _alertBox("로그인 요청 중 오류가 발생했습니다.", {icon:'❌', okColor:'red'}); }
	});
}
function logout(){
	$.ajax( {
		type : "post",
		url : CommonUtil.getContextPath() + "/com/loginOut.do",
		dataType : "json",
		success : function(data) {
		}
		})
		location.reload();		
}

function hitEnterKey(e){
	
	  if(e.keyCode == 13){ 
		loginproc2();
	  }else{
	   	e.keyCode == 0;
	  	return;
	  }
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

//비밀번호 초기화
function fnPwdClear(){ 

	var popupwidth = '550';
	var popupheight = '400'; 
	var url = "";  

	url = CommonUtil.getContextPath() + "/popup/pwdclear.do";
	 		
 	var LeftPosition = (screen.width-popupwidth)/2;
	var TopPosition  = (screen.height-popupheight)/2;

	var oPopup = window.open(url,"비밀번호변경","width="+popupwidth+",height="+popupheight+",top="+TopPosition+",left="+LeftPosition+", scrollbars=no");
	if(oPopup){oPopup.focus();}
   
}
</script>    


</head>

<body> 
  <div id="login" class="container">

    <div class="login-box">
      <div class="login-wrap">
        <h1><img src="${pageContext.request.contextPath}/asset/img/konet_login.png" alt="Konet" class="title-logo">코네트 물류관리 시스템</h1>

        <div class="id-box w-100">
          <h2>로그인</h2>
          <input name="userId" class="form-control" type="text" id="userId" placeholder="아이디" aria-label="아이디">
          <input type="password" class="form-control mt-3" id="userPw" placeholder="비밀번호" onKeypress="hitEnterKey(event);">
        </div>

        <!-- ID 저장 체크박스 -->
        <div class="form-check mt-2 w-100" style="text-align:left;">
          <input class="form-check-input" type="checkbox" id="save_id" onchange="fnSaveIdToggle();">
          <label class="form-check-label" for="save_id">아이디 저장</label>
        </div>

        <button type="submit" class="btn btn-primary btn-lg w-100 mt-2" onclick="javascript:loginproc2();">로그인</button>

        <div class="set-btn-box  w-100">
          	<button type="button" class="btn btn-outline-dark" onclick="javascript:fnPwdClear();">비밀번호 초기화</button>
          	<button type="button" class="btn btn-outline-dark" onclick="javascript:fnPwdChange();">비밀번호 변경</button>
        </div>
      </div>
    </div>
  </div>
<jsp:include page="footer.jsp"></jsp:include>
  </body>
</html>
