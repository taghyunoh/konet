
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
		url : "/user/loginOut.do", 
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

//페이지 처리 관련 함수 정의 시작
//페이지 정보 셋팅(최초)
function pageDescription(){
	
	var data = ""; 
	var pangecnt=  parseInt($("#pageCnt").val());
	var pagenum = 1;
	var pagePrev = $("#pagePrev").val();  //이전 페이지
	var pageNext = $("#pageNext").val();  //다음 페이지
	var endpage = pangecnt; 
	
    data= '<a class="page-link" href="#" onclick="pagePrev();"  aria-label="Previous"><span aria-hidden="true">&laquo;</span></a></li>';

    if(pangecnt > 10 ) endpage = 10 ;

    for(var i= 0; i < endpage; i++){
    	if($("#pageNo").val() == (i+1))
    		data+= '<li class="page-item active" id="'+(i+1) +'"><a class="page-link" href="#" id="'+(i+1) +'" onclick=pageClick('+(i+1)+');">'+(i+1) +'</a></li>'; 
    	else
    		data+= '<li class="page-item" id="'+(i+1) +'" ><a class="page-link" href="#" id="'+(i+1) +'" onclick="pageClick('+(i+1)+');">'+(i+1) +'</a></li>'; 
    }

    data+= ' <li class="page-item">';
    data+= '<a class="page-link" href="#" onclick="pageNext();" aria-label="Next">';
    data+= '<span aria-hidden="true">&raquo;</span>';
    data+= '</a>';
    data+= '</li>';
//	console.log(" pageDescription "+ data);
    $("#pageList").append(data);
    $("#pageNum").val(1); 
}



//페이지 클릭시 처리
function pageClick(pageno){   
	
    $('.page-item').removeClass('active'); 
    $('.page-item#'+pageno).addClass('active');  
	$("#pageNo").val(pageno);
	var pagePrev = parseInt(pageno) - 1;  //이전 페이지
	var pageNext = parseInt(pageno) + 1;  //다음 페이지
//	console.log("common.js pageClick  pageno "+ pageno + " pagePrev " + pagePrev + " pageNext  "+ pageNext);
 
	$("#pagePrev").val(pagePrev);
	$("#pageNext").val(pageNext); 
	//화면에서 조회함수 호출 
	pageSearch();
}



//이전 페이지 선택시(10단위)
function pagePrev(){
	var pageno   = parseInt($("#pageNo").val()) - 1;
	var pageNum  = parseInt(pageno/10) +1; 
	var pagePrev = parseInt($("#pagePrev").val());
	var pageNext = parseInt($("#pageNext").val());
		
	if(parseInt(pageno) == 0) return;

    $("#pageNum").val(pageNum); 

    //이전 페이지 클릭시 페이지 리스트 재작성 처리(10/20/30.... 인 경우)
	if(parseInt(pageno%10) == 0){ 
		
		$("#pageList").text("");
		var startpage= 0; 
		var endpage  = 10;			
		var data = ""; 
			
		startpage= 10*(parseInt(pageNum -1) - 1);
		endpage  = 10*(parseInt(pageNum -1)) ;
		
		if(parseInt($("#pageCnt").val()) < parseInt(endpage ))
			endpage = parseInt($("#pageCnt").val());

	    data= '<a class="page-link" href="#" onclick="pagePrev();"  aria-label="Previous"><span aria-hidden="true">&laquo;</span></a></li>';
	    	    
	    //		
	    for(var i= startpage; i < endpage; i++){
	    	if(pageno == (i+1))
	    		data+= '<li class="page-item active" id="'+(i+1) +'" ><a class="page-link" href="#" id="'+(i+1) +'" onclick="pageClick('+(i+1)+');">'+(i+1) +'</a></li>'; 
	    	else
	    		data+= '<li class="page-item" id="'+(i+1) +'" ><a class="page-link" href="#" id="'+(i+1) +'" onclick="pageClick('+(i+1)+');">'+(i+1) +'</a></li>'; 
	    }
    
	    data+= ' <li class="page-item">';
	    data+= '<a class="page-link" href="#" onclick="pageNext();" aria-label="Next">';
	    data+= '<span aria-hidden="true">&raquo;</span>';
	    data+= '</a>';
	    data+= '</li>';

	    $("#pageList").append(data);
	}
	//
	pageno   = parseInt($("#pageNo").val()) -1;
	//이전 페이지 정보 조회 처리
	pageClick(pageno);

}

//다음 페이지 선택시
function pageNext(){    
	var pageno   = parseInt($("#pageNo").val())+1;
	var pageNum  = parseInt(pageno/10) + 1; 
	var pagePrev = parseInt($("#pagePrev").val());
	var pageNext = parseInt($("#pageNext").val());
	
	if(parseInt($("#pageCnt").val()) < pageno) return;
//	console.log("pageNext pageno  " +  pageno  + " pagePrev " + pagePrev  + "  pageNext  "+ pageNext);
    $("#pageNum").val(pageNum);  

    //다음 페이지 클릭시 페이지 리스트 재작성 처리(11/21/31.... 인 경우)
	if(parseInt(pageno)%10 == 1){ 
		$("#pageList").text("");
		var startpage= 0;
		var endpage  = 10;		
		var data = "";   	

		startpage= 10*(parseInt(pageNum) - 1) ;
		endpage  = 10*(parseInt(pageNum)) ;
		// 
		if(parseInt($("#pageCnt").val()) < parseInt(endpage ))
			endpage = parseInt($("#pageCnt").val());			
		
	    data= '<a class="page-link" href="#" onclick="pagePrev();"  aria-label="Previous"><span aria-hidden="true">&laquo;</span></a></li>';
	    	    
	    //		
	    for(var i= startpage; i < endpage; i++){
	    	if(parseInt(pageno) == parseInt(i+1))
	    		data+= '<li class="page-item active" id="'+(i+1) +'" ><a class="page-link" href="#"  id="'+(i+1) +'" onclick="pageClick('+parseInt(i+1)+');">'+ parseInt(i+1) +'</a></li>'; 
	    	else
	    		data+= '<li class="page-item" id="'+(i+1) +'" ><a class="page-link" href="#"  id="'+(i+1) +'" onclick="pageClick('+parseInt(i+1)+');">'+parseInt(i+1) +'</a></li>'; 
	    }
    
	    data+= ' <li class="page-item">';
	    data+= '<a class="page-link" href="#" onclick="pageNext();" aria-label="Next">';
	    data+= '<span aria-hidden="true">&raquo;</span>';
	    data+= '</a>';
	    data+= '</li>';
		    console.log(data);
	    $("#pageList").append(data);
	}
    //다음 페이지 정보 조회 처리
	pageClick(pageno);	
	
}
//페이지 처리 관련 함수 정의 시작
