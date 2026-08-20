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
var SAVED_COMP_CD_KEY = "sejong_saved_comp_cd";   // 사업장기호(회사코드) 저장

$(document).ready(function(){
	// 저장된 ID 복원
	try {
		var savedId   = localStorage.getItem(SAVED_USER_ID_KEY);
		var savedComp = localStorage.getItem(SAVED_COMP_CD_KEY);
		if (savedComp) { $("#compCd").val(savedComp); }
		if (savedId) {
			$("#userId").val(savedId);
			$("#save_id").prop("checked", true);
			$("#userPw").focus();   // 사업장기호·ID 자동입력 → 비밀번호 포커스
		} else if (savedComp) {
			$("#userId").focus();   // 사업장기호만 있으면 ID로 포커스
		} else {
			$("#compCd").focus();
		}
	} catch (e) {
		// localStorage 미지원/차단 시 무시
		$("#compCd").focus();
	}
});

// ID 저장 체크박스 처리 (체크 해제 즉시 저장값 삭제)
function fnSaveIdToggle(){
	try {
		if (!$("#save_id").is(":checked")) {
			localStorage.removeItem(SAVED_USER_ID_KEY);
			localStorage.removeItem(SAVED_COMP_CD_KEY);
		}
	} catch (e) {}
}

// _toast / _alertBox 는 공통 /asset/js/ui-message.js 에서 제공
// ui-message.js 미로딩(404 등) 대비 안전망 — 로드되면 자동 스킵
if (typeof window._toast !== 'function') { window._toast = function(m){ alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); }; }
if (typeof window._alertBox !== 'function') { window._alertBox = function(m,o){ o=o||{}; alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); if(o.onOk)o.onOk(); }; }
function loginproc2(){
	var comp = $.trim($("#compCd").val());
	var id   = $.trim($("#userId").val());
	var pw   = $("#userPw").val();
	if (!comp) { _alertBox("회사코드를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#compCd").focus(); }}); return; }
	if (!id)   { _alertBox("아이디를 입력하세요.",   {icon:'⚠️', onOk:function(){ $("#userId").focus(); }}); return; }
	if (!pw)   { _alertBox("비밀번호를 입력하세요.", {icon:'⚠️', onOk:function(){ $("#userPw").focus(); }}); return; }

	// KOLGSDB 로그인: COMP_CD + USER_ID + 비밀번호 (form 파라미터 → @ModelAttribute UserDTO)
	$.ajax({
		type: "post",
		url:  CommonUtil.getContextPath() + "/user/loginChk.do",
		data: { compCd: comp, userId: id, passWd: pw },
		dataType: "json",
		success: function(data) {
			if (data.error_code !== "00000") {
				_alertBox(data.error_mess || "로그인 실패", {icon:'❌', okColor:'red', onOk:function(){ $("#userId").focus(); }});
				return;
			}
			// ID 저장 (성공 후에만)
			try {
				if ($("#save_id").is(":checked")) {
					localStorage.setItem(SAVED_USER_ID_KEY, id);
					localStorage.setItem(SAVED_COMP_CD_KEY, comp);
				} else {
					localStorage.removeItem(SAVED_USER_ID_KEY);
					localStorage.removeItem(SAVED_COMP_CD_KEY);
				}
			} catch (e) {}
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

<%-- ★[2026-08-20] 로그인 화면을 **다른 화면과 같은 콘셉**으로 (요청 「로그인화면 콘셉에 맞게」).
     종전에는 제목·로그인 단추가 **파랑(#1976d2)** 이라 업무화면(청록 #137a6c)과 따로 놀았다 —
     같은 프로그램인데 문을 열면 색이 바뀌었다.
     ★고친 것은 **색·글자체·모서리·초점 표시**뿐이다 — 배치·문구·동작은 그대로 두었다.
     ★부트스트랩 기본값을 덮어야 해서 `!important` 를 쓴다(이 화면은 bootstrap.css 를 통째로 싣는다).
     ⚠되돌리려면 이 블록만 지우면 된다. --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
<style>
  /* 글자체 — 업무화면과 같은 것. 못 받으면 맑은 고딕으로 조용히 내려간다.
     ⚠**`#login *` 로 안쪽까지 덮어야 한다** — `reset.css` 가 `h1,h2,p,label…` 을 낱개로 잡아
       「Noto Sans KR」 을 박아 두어서, 바깥(#login)에만 걸면 제목·라벨이 안 바뀐다(2026-08-20 실측). */
  #login, #login *{
    font-family:'Pretendard Variable',Pretendard,'맑은 고딕','Malgun Gothic',system-ui,sans-serif;
  }
  /* 제목 — 파랑 → 청록. 로고는 그대로 둔다(회사 표시라 색을 바꾸지 않는다) */
  #login .login-wrap h1{ color:#0e6657 !important; letter-spacing:-.02em; }
  #login .login-wrap .id-box h2{ color:#37475a !important; font-weight:600; }

  /* 입력칸 — 업무화면 규칙(모서리 8 · 한 겹 테두리 · 초점은 청록 링 하나) */
  #login .login-wrap input.form-control{
    height:46px !important; border:1px solid #cfd9e2 !important; border-radius:8px !important;
    padding:0 13px !important; font-size:15px !important; color:#1f2a37 !important;
    background:#fff !important; box-shadow:none !important;
    transition:border-color .12s, box-shadow .12s;
  }
  #login .login-wrap input.form-control:focus{
    border-color:#137a6c !important; box-shadow:0 0 0 3px rgba(19,122,108,.14) !important;
  }
  #login .login-wrap input.form-control::placeholder{ color:#9aa7b3; }

  /* 로그인 단추 — 이 화면의 **주된 작업 하나**만 채운 색(화면 규칙 3) */
  #login .login-wrap .btn-primary.btn-lg{
    background:#137a6c !important; border-color:#137a6c !important; color:#fff !important;
    border-radius:8px !important; text-decoration:none !important; letter-spacing:.01em;
  }
  #login .login-wrap .btn-primary.btn-lg:hover{ background:#0e6657 !important; border-color:#0e6657 !important; }
  #login .login-wrap .btn-primary.btn-lg:focus{ box-shadow:0 0 0 3px rgba(19,122,108,.22) !important; }

  /* 나머지 단추 — 테두리만(주된 작업과 헷갈리지 않게) */
  #login .login-wrap .set-btn-box .btn{
    border-radius:8px !important; border-color:#cfd9e2 !important; color:#37475a !important;
    background:#fff !important; font-weight:500 !important;
  }
  #login .login-wrap .set-btn-box .btn:hover{ border-color:#137a6c !important; color:#0e6657 !important; }

  /* 아이디 저장 체크 — 청록으로 */
  #login .form-check-input:checked{ background-color:#137a6c !important; border-color:#137a6c !important; }
  #login .form-check-input:focus{ box-shadow:0 0 0 3px rgba(19,122,108,.14) !important; border-color:#137a6c !important; }
</style>
</head>

<body> 
  <div id="login" class="container">

    <div class="login-box">
      <div class="login-wrap">
        <h1><img src="${pageContext.request.contextPath}/asset/img/konet_login.png" alt="Konet" class="title-logo">코네트 물류관리 시스템</h1>

        <div class="id-box w-100">
          <h2>로그인</h2>
          <input name="compCd" class="form-control" type="text" id="compCd" placeholder="회사코드" aria-label="회사코드">
          <input name="userId" class="form-control mt-3" type="text" id="userId" placeholder="아이디" aria-label="아이디">
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
