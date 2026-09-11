// grid 새로고침
function reloadGrid(id){
	jQuery("#"+id).trigger("reloadGrid");
}


//문자 변경
//function replaceAll(text, before, after) {
//alert("replaceAll");
//	    return text.split(before).join(after);
//
//}

// Clear 처리
function clearForm(form) { 
	 
    $(':input', form).each(function() { 
        var type = this.type;
        var tag = this.tagName.toLowerCase(); // normalize case
        if (type == 'text' || type == 'password' || tag == 'textarea')
            this.value = "";
        else if (type == 'checkbox' || type == 'radio')
            this.checked = false;
        else if (tag == 'select')
            this.selectedIndex = 0;
            
     });
}  

function fn_resize(grid, gridw , rate){
	  
	if(rate == '')
		$("#"+grid).setGridWidth(gridw - 12); 
	else{ 
		$("#"+grid).setGridWidth(gridw*rate - 12);
	} 
}

// Grid Data Clear
function clearGrid(form){
	 $("#"+form).clearGridData();  
	 
}

/* 필수값 validation */
function fnRequired(id, message){
 
	if($.trim($("#" + id).val()) == ""){ 
		alert(message);
		$("#" + id).focus();
		return false;
	}
	
	return true;
}

/**
 * 숫자 입력값 체크
 * 
 */
function GridNumberValid(val){
	 
	var rtn = true;
	
	if(isNaN(val) == true) {
		alert(i18n.text_219 +" : " + val +" "+i18n.message_191);
		rtn = false;
	} else {
		rtn = true;
	}
 
	
	return rtn;
}

//닫기
function fn_close(){
	 
	$.ajax( {
		type : "post",
		url : "/PHSS/loginOut.do", 
		dataType : "json",
		success : function(data) {  
			 
			if (data == true) {   
				 self.window.close();
			}else{ 
				return;
			}				   
		}	 
	}); 
}


function setCurrTime(id){

	var now = new Date(); 
	var time = "";
	
	if(now.getMinutes()  < 10)
		time = '0'+now.getMinutes();
	else
		time = now.getMinutes();
	
	var currtime  = now.getHours() +":" +time ;
	
	$("#"+id).attr("value",currtime);
}
 
function onlyInt(element) {		// 입력시 숫자만 받기
	$(element).keyup(function(){
		var val1 = element.value;
		var num = new Number(val1);
		if(isNaN(num)){
			element.value = '';
		}
	})
} 

//현재일 설정
function setCurrDate(id){
	
	var now = new Date();
	var year = now.getFullYear(); 
	
	var month = now.getMonth()+1;
	if(month < 10) month = "0"+month;
	
	var date = now.getDate();
	if(date < 10) date = "0"+date; 
	
	var currdate = year+'-'+month+'-'+date;
	
	$("#"+id).attr("value",currdate);
  
}


 //엔터키 입력시 자동 조회 처리
 function searchpress(event) {
		if (event.keyCode == 13) {
			fn_search();
		}
 }
 
 function fnLayoutRearrange() {
	var height = $("#c_t_contact").css("height");

	if(height == undefined) return;

	height = eval(height.replace("px", "")) + eval(100);

	$("#center").css("height", height + "px");
	$("#left").css("height", height + "px");
	$("#contant").css("height", height + "px");
 }
   
/* userId, entryAddress 체크 validation */
function fnCheckAccount(addr){
	var pattern = /[^\.\-\_(가-힣a-zA-Z0-9)]/;
	if(pattern.test($.trim(addr))){
		 alert("사용 불가한 계정입니다.");
		 return false;
	}
	return true;
}

/* name 체크 validation */
function fnCheckName(name){
	var pattern = /[^(가-힣a-zA-Z0-9)]/;
	if(pattern.test($.trim(name))){
		 alert("사용 불가한 이름입니다.");
		 return false;
	}
	return true;
}

/* 숫자만 허용 validation(Input text 에서 입력시 체크) */
function fnOnlyNumber(event) {
	var code = window.event.keyCode; 

	if ((code >= 48 && code <= 57) || (code >= 96 && code <= 105) || code == 110 || code == 190 || code == 8 || code == 9 || code == 13 || code == 46){ 
		window.event.returnValue = true; 
		return; 
	} 
	window.event.returnValue = false; 
}
 
/* fileType validation */
function fnCheckFileType(file){
	file = file.toLowerCase();
	
	if(file.search(/(.gif)|(.jpg)|(.jpeg)|(.png)/) == -1){
		alert("gif, jpg, jpeg, png 파일만 업로드 가능합니다.");
		return false;
	}
	
	return true;
}

/* email 형식 validation */
function fnCheckEmail(email) {
             
    re = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
    
    if(email.length < 6 || !re.test(email)){
    	alert("전자메일 형식이 잘못되었습니다.");
    	return false;    	
    }
    
    return true;
}

function fnCheckMinLength(objname, message, minLength){
	if($("#"+ objname).val().length < minLength){
		alert(message + " " + minLength +"자 이상입니다.");
		$("#" + objname).focus();
		return false;
	}
	
	return true;
}

function fnCheckMaxLength(objname, message, maxLength){
	var objstr= $("#" + objname).val();
	var ojbstrlen= objstr.length;

	var maxlen = maxLength;
	
	var bytesize=0;
	var strlen=0;
	var onechar="";
	var objstr2="";

	for(var i=0;i<ojbstrlen;i++){
		onechar=objstr.charAt(i);
		if(escape(onechar).length > 4){
			bytesize+=2;
		}else{
			bytesize++;
		}
		if(bytesize <= maxlen){
			strlen=i+1; 
		}
	}
	 
	if(bytesize > maxlen){
		alert(message + " 한글 "+ eval(maxLength/2) +"자 영어 "+ maxLength +"자로 제한합니다.");
		objstr2=objstr.substr(0,strlen);
		$("#" + objname).val(objstr2);
		$("#" + objname).focus();
		return false;
	} 

	return true;
}
 
/**
 * 날짜 형식 검사
 * @param stObjId 시작일자 오브젝트id
 * @param edObjId 종료일자 오브젝트id
 * ex) cfn_dateCheck('start_dt','end_dt');
 */
function cfn_dateCheck(stObjId,edObjId){
	var rtn = true;
	var stval = cfn_dateDiv(stObjId,'');
	var edval = cfn_dateDiv(edObjId,'');
	//dateValid("day",stObjId);
	//dateValid("day",edObjId);

	if(stval!=''&&edval!=''){
		if(parseInt(stval)>parseInt(edval)){
			rtn = false;
		}
	}else{
		$('#'+stObjId).val('');
		$('#'+edObjId).val('');
	}
	return rtn;
}

/**
 * 날짜 타입 포맷을 한다.
 * ex) cfn_setDateMask('start_dt','-');
 * ex) cfn_setDateMask('start_dt','');
 */
function cfn_setDateMask(objId,maskchar){
	var $o;
	
	if(cfn_isEmpty($('#'+objId))) {
		return '';
	}else {
		$o = $('#'+objId);
	}
	$o.val(cfn_dateDiv(objId,maskchar));
}

/**
 * 날짜 타입 포맷을 한다.
 * ex) cfn_dateDiv('start_dt','-');
 * ex) cfn_dateDiv('start_dt','');
 */
function cfn_dateDiv(objId,maskchar){
	var expNum = /[^0-9]/g;
	var year=month=day=val = '';
	var $o;
	
	if(cfn_isEmpty($('#'+objId))) {
		return '';
	}else {
		$o = $('#'+objId);
		val = $o.val().replace(/[^0-9]/g,'');
	}
	
	if(val.length==6){
		year = val.substr(0,4);
		month = val.substr(4,2);
		val = year+maskchar+month;
	}
	else if(val.length==8){
		year = val.substr(0,4);
		month = val.substr(4,2);
		day = val.substr(6,2);
		val = year+maskchar+month+maskchar+day;
	}
	
	return val;
}

/**
 * 날짜 형식 체크
 * 
 */
function dateValid(tp,oId){
	var rtn = true;
	var expDay = /^(19|20)\d{2}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[0-1])$/;
	var expMonth = /^(19|20)\d{2}-(0[1-9]|1[012])$/;
	
	if($('#'+oId).val()!=''){
		if(tp=="day"){
			if(!expDay.test($('#'+oId).val())){
				alert("날짜 형식이 올바르지 않습니다. \n\n YYYY-MM-DD 형식으로 입력하세요.");
				//rtn = false;
				return;
			}
		}else if(tp=="month"){
			if(!expMonth.test($('#'+oId).val())){
				alert("날짜 형식이 올바르지 않습니다. \n\n YYYY-MM 형식으로 입력하세요.");
				//rtn = false;
				return;
			}
		}
	}
	//return rtn;
}


/**
 * 천단위 금액 콤마 찍기
 * @param n 숫자
 * ex) $("#tot1").text(cfn_commify($("#tot1").text()));
 */
function cfn_commify(n){
	var reg = /(^[+-]?\d+)(\d{3})/;   // 정규식
	n += '';  // 숫자를 문자열로 변환

	while (reg.test(n))
		n = n.replace(reg, '$1' + ',' + '$2');

	return n;
}

/**
 * object 공백 체크
 * ex) if(cfn_isEmpty($('#'+objId)))
 */
function cfn_isEmpty(obj) {
	if (obj == null)
		return true;

	if (typeof obj != "object") {
		if (typeof obj == "undefined")
			return true;
		if (obj == "")
			return true;
	}else if (typeof obj != "string") {
		if($(obj).val()=="")
			return true;
	}

	return false;
}

// 접속 브라우저 체크
function isBrowserCheck(){ 
	
	var agt = navigator.userAgent.toLowerCase(); 
	
	if (agt.indexOf("trident") != -1) return 'Explorer';
	if (agt.indexOf("chrome") != -1) return 'Chrome'; 
	if (agt.indexOf("opera") != -1) return 'Opera'; 
	if (agt.indexOf("staroffice") != -1) return 'Star Office'; 
	if (agt.indexOf("webtv") != -1) return 'WebTV'; 
	if (agt.indexOf("beonex") != -1) return 'Beonex'; 
	if (agt.indexOf("chimera") != -1) return 'Chimera'; 
	if (agt.indexOf("netpositive") != -1) return 'NetPositive'; 
	if (agt.indexOf("phoenix") != -1) return 'Phoenix'; 
	if (agt.indexOf("firefox") != -1) return 'Firefox'; 
	if (agt.indexOf("safari") != -1) return 'Safari'; 
	if (agt.indexOf("skipstone") != -1) return 'SkipStone'; 
	if (agt.indexOf("netscape") != -1) return 'Netscape'; 
	if (agt.indexOf("mozilla/5.0") != -1) return 'Mozilla'; 
	if (agt.indexOf("msie") != -1) { 
		// 익스플로러 일 경우
		var rv = -1; 
		if (navigator.appName == 'Microsoft Internet Explorer') { 
			var ua = navigator.userAgent; 
			var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})"); 
			if (re.exec(ua) != null) rv = parseFloat(RegExp.$1); 
		} 
		return 'Explorer';  
	} 
}
 
		
// 달력환경 설정

(function($) {
	  
	 $calendarConfig = function (objName) {
	  $( "#"+objName ).datepicker({
	     showOn: "button"   // 버튼 이미지 삽입 가능
//	   , buttonImage: "../asset/img/icon/icon_calendar.gif"  // 버튼 이미지 경로
//	   , buttonImageOnly: true  // true:버튼 이미지만 표시  false:버튼 안에 이미지 표시(default)
	   , changeMonth: true   // 월 선택을 combobox로 표현
	   , changeYear: true   // 년 선택을 combobox로 표현
	   , showOtherMonths: true  // 다른 월도 보여지도록
	   , selectOtherMonths: true // 다른 월의 셀도 선택가능하도록
	   , dateFormat: "yy-mm-dd" // 날짜 포맷 설정
//	   , showAnim: "drop"   // 달력 open, close시의 애니메이션 효과 설정
	   , dayNamesMin: ["일","월","화","수","목","금","토"]      //요일 해더 표시 설정
	   , monthNamesShort: ["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"] //월 combobox 표시 설정
	   //, showWeek: true   // 년간 주(week)를 표현
	  });
	 };
});

//Date to string
Date.prototype.yyyymmdd = function() {
    var yyyy = this.getFullYear().toString();
    var mm = (this.getMonth() + 1).toString();
    var dd = this.getDate().toString();
    return yyyy + "-" + (mm[1] ? mm : "0" + mm[0]) + "-" + (dd[1] ? dd : "0" + dd[0]);
}

function checkBtnYn(pgrm_id, pgrm_btn){
	var result = null;
	$.ajax( {
  		type : "post",
  		url : "/com/checkBtnYn.do",
  		data : {"pgrm_id": pgrm_id, "pgrm_btn": pgrm_btn},
  		async : false,
  		error : function(){
  			result = false;
	 	},
  		success : function(data) {
  			if (data.useYn == "Y"){
  				result = true;
  			} else {
  				result = false;
  			}
		}
  	});
	return result;
}
