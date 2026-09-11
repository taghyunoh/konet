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
<script type="text/javascript" src='/asset/js/commonUtil.js'></script>
<script type="text/javascript" src='/asset/js/ui-message.js'></script>
<script type="text/javascript">
  sessionStorage.setItem("contextPath", '<c:out value="${pageContext.request.contextPath}"/>');
</script>
<title>사용자 회원가입</title>
<style>
  /* ── 회원가입 폼 — 거래처정보 입력 화면 컨셉(테이블형 2열, 청록 라벨셀) 이식 ── */
  /* 청록 포인트 컬러 변수 (이미지 컨셉) */
  :root {
    --reg-teal:        #1f9b8e;   /* 라벨 텍스트 / 버튼 */
    --reg-teal-dark:   #178074;   /* 버튼 hover */
    --reg-teal-border: #bfe0db;   /* 셀 테두리 */
    --reg-teal-bg:     #eaf6f4;   /* 라벨 셀 배경 */
  }
  /* 입력 테이블 — label(청록셀) | input 을 2쌍씩 한 행에 배치 */
  .reg-table { width:100%; border-collapse:collapse; table-layout:fixed; margin-top:4px; }
  .reg-table th, .reg-table td { border:1px solid var(--reg-teal-border); padding:9px 12px; vertical-align:middle; font-size:14px; }
  .reg-table th { background:var(--reg-teal-bg); color:var(--reg-teal); font-weight:600; text-align:left; width:18%; white-space:nowrap; }
  .reg-table td { background:#fff; }
  .reg-table .req { color:#dc3545; margin-right:3px; font-weight:700; }
  .reg-table input.form-control { height:36px; font-size:14px; }
  .reg-table .gender-wrap { padding:2px 0; }
  .reg-table .gender-wrap label { margin:0 18px 0 0; font-weight:500; cursor:pointer; }
  .reg-table .triple { display:flex; gap:8px; }
  /* 청록 버튼(이미지 가입 버튼 컨셉) */
  .btn-reg-teal { background:var(--reg-teal); border-color:var(--reg-teal); color:#fff; font-weight:600; }
  .btn-reg-teal:hover, .btn-reg-teal:focus { background:var(--reg-teal-dark); border-color:var(--reg-teal-dark); color:#fff; }
  #login h3.reg-title { color:var(--reg-teal); border-bottom:2px solid var(--reg-teal); padding-bottom:8px; margin-bottom:6px; width:100%; }

  /* 약관 동의 영역 — SEJONG_APP login.jsp 의 agreeList 스타일을 단순화하여 이식 */
  .agree-box { border:1px solid var(--reg-teal-border); border-radius:6px; padding:12px 14px; margin-top:14px; background:#f8fbfb; }
  .agree-box h6 { margin:0 0 8px 0; font-size:14px; color:var(--reg-teal); font-weight:600; }
  .agree-item { display:flex; align-items:center; justify-content:space-between; padding:6px 0; border-bottom:1px dashed #e9ecef; }
  .agree-item:last-child { border-bottom:0; }
  .agree-item .agree-link { color:#0d6efd; text-decoration:underline; cursor:pointer; font-size:15px; flex:1; }
  .agree-item .agree-link .req { color:#dc3545; margin-right:4px; font-weight:700; font-size:15px; }
  .agree-item input[type=checkbox] { width:18px; height:18px; margin:0 0 0 8px; }
  .agree-all { padding:8px 0; margin-bottom:6px; border-bottom:1px solid #ced4da; }
  .agree-all label { font-weight:700; color:#212529; cursor:pointer; }
  .sign-conts-box { display:none; margin-top:8px; padding:14px 18px; max-height:360px; overflow-y:auto; background:#fff; border:1px solid #ced4da; border-radius:4px; font-size:13px; line-height:1.65; white-space:pre-wrap; color:#333; text-align:left; }
  .sign-conts-box.open { display:block; }
  /* 약관 본문 영역의 빈 상태(준비중) placeholder — 가운데 정렬해서 안내 느낌 */
  .sign-conts-placeholder { text-align:center; color:#888; padding:18px 8px; font-size:12px; line-height:1.6; }
</style>
<script type="text/javaScript">
// 현재 펼쳐진 약관 (토글용)
var __openedTermsGb = "";

// ui-message.js 미로딩(404 등) 대비 안전망 — 로드되면 자동 스킵
if (typeof window._toast !== 'function') { window._toast = function(m){ alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); }; }
if (typeof window._alertBox !== 'function') { window._alertBox = function(m,o){ o=o||{}; alert(String(m).replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,'')); if(o.onOk)o.onOk(); }; }
if (typeof window._confirmBox !== 'function') { window._confirmBox = function(o){ o=o||{}; var m=String(o.msg||'진행할까요?').replace(/<br\s*\/?>/gi,'\n').replace(/<[^>]*>/g,''); if(confirm(m)){ if(o.onOk)o.onOk(); } else { if(o.onCancel)o.onCancel(); } }; }

function registerProc(){
	var dto = {
		userNm: $.trim($("#userNm").val()),
		phone : $.trim($("#phone").val()),
		userPw: $("#userPw").val(),
		birth : $.trim($("#birth").val()),
		gender: $("input[name='gender']:checked").val(),
		email : $.trim($("#email").val()),
		height: $("#height").val() ? parseInt($("#height").val(),10) : 0,
		weight: $("#weight").val() ? parseInt($("#weight").val(),10) : 0,
		blodGb: $("#blodGb").val() ? parseInt($("#blodGb").val(),10) : 0
	};
	if (!dto.userNm) { _alertBox("이름을 입력하세요.", {icon:'⚠️'}); return; }
	if (!dto.phone)  { _alertBox("전화번호를 입력하세요.", {icon:'⚠️'}); return; }
	if (!dto.userPw || dto.userPw.length < 4) { _alertBox("비밀번호는 4자 이상 입력하세요.", {icon:'⚠️'}); return; }
	if ($("#userPw").val() !== $("#userPw2").val()) { _alertBox("비밀번호 확인이 일치하지 않습니다.", {icon:'⚠️'}); return; }
	if (!/^\d{8}$/.test(dto.birth)) { _alertBox("생년월일은 YYYYMMDD 8자리로 입력하세요.", {icon:'⚠️'}); return; }
	if (!dto.gender) { _alertBox("성별을 선택하세요.", {icon:'⚠️'}); return; }

	// 약관 동의 검증 (3개 모두 필수) — SEJONG_APP login.jsp goJoin3() 와 동일
	if (!$("#chk_01").is(":checked")) { _alertBox("서비스 이용약관에 동의해주세요.", {icon:'⚠️'}); return; }
	if (!$("#chk_02").is(":checked")) { _alertBox("개인정보 수집·이용동의 항목에 동의해주세요.", {icon:'⚠️'}); return; }
	if (!$("#chk_03").is(":checked")) { _alertBox("고유식별정보 처리동의 항목에 동의해주세요.", {icon:'⚠️'}); return; }

	$.ajax({
		type: "post",
		url:  CommonUtil.getContextPath() + "/patient/registerAct.do",
		data: JSON.stringify(dto),
		contentType: "application/json",
		dataType: "json",
		success: function(data){
			if (data.IsSucceed) {
				_alertBox(data.Message || "회원가입이 완료되었습니다.", {icon:'✅', okText:'확인',
					onOk:function(){ location.href = CommonUtil.getContextPath() + "/patient/login.do"; }});
			} else {
				_alertBox(data.Message || "회원가입 실패", {icon:'❌', okColor:'red'});
			}
		},
		error: function(){ _alertBox("회원가입 요청 중 오류가 발생했습니다.", {icon:'❌', okColor:'red'}); }
	});
}

/**
 * 약관 본문 조회/토글 — SEJONG_APP 의 /getSignList.do 와 동일 시그니처.
 * 같은 termsGb 를 다시 클릭하면 닫힘 (setting.jsp 의 토글 패턴 참고).
 *
 * termsGb: 1 = 개인정보 수집·이용동의 / 2 = 고유식별정보 처리동의 / 3 = 서비스 이용약관
 */
function getSignList(termsGb) {
	var $box = $("#signContsBox");
	// 토글: 같은 약관을 다시 클릭하면 닫기
	if (__openedTermsGb === String(termsGb)) {
		$box.removeClass("open").empty();
		__openedTermsGb = "";
		return;
	}
	$.ajax({
		url:  CommonUtil.getContextPath() + "/getSignList.do",
		type: "post",
		data: JSON.stringify({ termsGb: termsGb }),
		contentType: "application/json",
		dataType: "json",
		success: function(result){
			// IsSucceed=false 도 빈 목록과 동일하게 "준비중" 표시 (T_SIGN_MST 미설정 케이스)
			var arr = (result && result.Data) ? result.Data : [];
			renderSignList(arr);
			__openedTermsGb = String(termsGb);
		},
		error: function(){
			// 네트워크/서버 오류여도 폼은 그대로 — "준비중" 안내만 표시
			renderSignList([]);
			__openedTermsGb = String(termsGb);
		}
	});
}

function renderSignList(data) {
	var $box = $("#signContsBox");
	$box.empty();
	if (!data || data.length === 0) {
		// T_SIGN_MST 에 아직 본문이 들어있지 않은 초기 상태 안내 — 데이터가 등록되면 자동으로 표시됨.
		// placeholder 는 가운데 정렬(.sign-conts-placeholder), 본문이 들어오면 좌측 정렬.
		$box.html('<div class="sign-conts-placeholder">약관 본문이 준비 중입니다.<br>운영자 등록 후 표시됩니다.</div>').addClass("open");
		return;
	}
	// 여러 행을 단순히 줄바꿈으로 연결 (SEJONG_APP 동일 — termsConts 가 본문 텍스트)
	var html = "";
	for (var i = 0; i < data.length; i++) {
		var conts = data[i].termsConts || "";
		html += $("<div/>").text(conts).html() + "\n\n";
	}
	$box.html(html).addClass("open");
}

// "전체 동의" 체크박스 → 3개 일괄 토글
function toggleAllAgree(el){
	var checked = !!el.checked;
	$("#chk_01,#chk_02,#chk_03").prop("checked", checked);
}
// 개별 변경 시 전체동의 체크 상태 동기화
$(function(){
	$("#chk_01,#chk_02,#chk_03").on("change", function(){
		var all = $("#chk_01").is(":checked") && $("#chk_02").is(":checked") && $("#chk_03").is(":checked");
		$("#chk_all").prop("checked", all);
	});
});

</script>
</head>
<body>
  <div id="login" class="container">
    <!--
      login.css 의 #login .set-pass-box { width:400px } 가 폭을 400 으로 고정하고 있어
      회원가입 화면처럼 항목 많은 폼은 좁아짐. 이 페이지에서만 inline 으로 확장.
      향후 T_SIGN_MST 약관 본문이 화면에 표시되는 것을 감안해서 넓게 잡음.
      max-width:96vw 는 모바일/좁은 창에서 화면 넘침 방지.
    -->
    <div class="set-pass-box" style="width:920px;max-width:96vw;padding:30px 48px;">
      <div class="set-pass-wrap" style="max-width:none;width:100%;">
        <h3 class="reg-title">사용자 회원가입</h3>
        <div class="pass-box w-100">
          <!--
            입력 영역 — 거래처정보 화면 컨셉의 테이블형 2열 레이아웃.
            라벨은 청록 셀(왼쪽), 입력은 흰 셀(오른쪽). 필수 항목은 빨강 * 표시.
            이메일·신장 라인은 입력 폭이 커서 colspan 으로 단독 행 유지.
          -->
          <table class="reg-table">
            <colgroup>
              <col style="width:18%"><col style="width:32%"><col style="width:18%"><col style="width:32%">
            </colgroup>
            <tbody>
              <tr>
                <th><span class="req">*</span>이름</th>
                <td><input type="text" id="userNm" class="form-control" placeholder="이름"></td>
                <th><span class="req">*</span>전화번호</th>
                <td><input type="text" id="phone" class="form-control" placeholder="01012345678 (-없이 숫자만)" maxlength="11" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"></td>
              </tr>
              <tr>
                <th><span class="req">*</span>비밀번호</th>
                <td><input type="password" id="userPw" class="form-control" placeholder="4자 이상"></td>
                <th><span class="req">*</span>비밀번호 확인</th>
                <td><input type="password" id="userPw2" class="form-control" placeholder="비밀번호 확인"></td>
              </tr>
              <tr>
                <th><span class="req">*</span>생년월일</th>
                <td><input type="text" id="birth" class="form-control" placeholder="YYYYMMDD 8자리" maxlength="8" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"></td>
                <th><span class="req">*</span>성별</th>
                <td>
                  <div class="gender-wrap">
                    <label><input type="radio" name="gender" value="M"> 남자</label>
                    <label><input type="radio" name="gender" value="F"> 여자</label>
                  </div>
                </td>
              </tr>
              <tr>
                <th>이메일</th>
                <td colspan="3"><input type="text" id="email" class="form-control" placeholder="example@example.com (선택)"></td>
              </tr>
              <tr>
                <th>신장 / 체중 / 당뇨분류</th>
                <td colspan="3">
                  <div class="triple">
                    <input type="text" id="height" class="form-control" placeholder="신장(cm)" maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
                    <input type="text" id="weight" class="form-control" placeholder="체중(kg)" maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
                    <input type="text" id="blodGb" class="form-control" placeholder="당뇨분류코드" maxlength="2" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');">
                  </div>
                </td>
              </tr>
            </tbody>
          </table>

          <!-- 약관 동의 — SEJONG_APP login.jsp 의 agreeList 와 동일 항목 (3개 모두 필수) -->
          <div class="agree-box">
            <h6>약관 동의</h6>
            <div class="agree-all">
              <label>
                <input type="checkbox" id="chk_all" onclick="toggleAllAgree(this);" style="width:18px;height:18px;vertical-align:middle;margin-right:6px;">
                전체 약관에 동의합니다.
              </label>
            </div>
            <div class="agree-item">
              <a class="agree-link" onclick="getSignList(3);"><span class="req">[필수]</span>서비스 이용약관 보기</a>
              <input type="checkbox" id="chk_01">
            </div>
            <div class="agree-item">
              <a class="agree-link" onclick="getSignList(1);"><span class="req">[필수]</span>개인정보 수집·이용동의 보기</a>
              <input type="checkbox" id="chk_02">
            </div>
            <div class="agree-item">
              <a class="agree-link" onclick="getSignList(2);"><span class="req">[필수]</span>고유식별정보 처리동의 보기</a>
              <input type="checkbox" id="chk_03">
            </div>
            <div id="signContsBox" class="sign-conts-box"></div>
          </div>
        </div>

        <div class="set-btn-box w-100">
          <button type="button" class="btn btn-outline-dark" onclick="location.href='/patient/login.do';">취소</button>
          <button type="button" class="btn btn-reg-teal" onclick="registerProc();">가입</button>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
