


// 메뉴 클릭시 탭 생성 
$(document).ready(function () { 
	var userid= document.chkfrm.session.value;
	if(userid == null || userid == ""){
		alert("로그인 정보가 없습니다. 로그인 하시길 바랍니다.");
		window.location.href = "/index.do";
	} 
	 
	
      $('.menu-item a').on('click', function (e) {   
        e.preventDefault();
        var menuText = $(this).text();
        var menuId = $(this).closest('.menu-item').data('menu');
       
        $('#tab-list').find('.nav-link').removeClass('active');
        $('.tab-content').children().removeClass('active');
        
        var id = $(this).attr("href");
        var menuurl = $(this).data("url");
        var sessionValue = sessionStorage.getItem('q_screen_id');
        
        var tabId = $(e.target).attr('aria-controls');
        var jspPath = menuurl; // 탭에 해당하는 JSP 파일 경로 
        //
        if($('.nav-link').length > 10 ) {
        	alert("최대 10개 TAB만 구성가능합니다.");
        	return;
        }
        
        var i = $('.nav-link').length; 
    	var findchk   = "N";
    	var chkpos    = 0;
        //
        if(i > 0){
        	var elements  = document.getElementsByClassName("tab-pane");
        	 
        	findchk = "N";
        	for (var i = 0; i < elements.length; i++) {
        	    var element = elements[i];
        	    if (element.id == id) { 
        	        findchk = "Y";
        	        break;
        	    }
        	    chkpos = i;
        	} 
        	if(findchk == "Y") {
	          $('#tab-list').find('.nav-link').removeClass('active'); 
	          $('.tab-content').children().removeClass('active');  
  	          $('.nav-link#'+id).addClass('active');    
  	          $('.tab-pane#'+id).addClass('active');
        	}
        		
        } 
   	 	
     
        if(findchk != "Y"){ 
	        // 닫기 버튼을 추가하고 해당 버튼에 close 클래스 부여 
	        $('#tab-list').append('<li class="nav-item"><a class="nav-link active" role="tab" aria-controls="'+ id +'" id="'+ id +'">' + menuText +
	                              '<button class="buttcon close" id="'+id+'"><span class="icon icon-close" ></span></button> </a></li>'); 
	         
	        if(id != '')
	        	$('.tab-content').append('<div class="tab-pane active"' +' id="'+id+'"></div>');

  		    $('.tab-pane').empty();   //추가
	        TabOpen(i, id, menuurl);  
        }
        
    }); 
      
      // 닫기 버튼에 대한 클릭 이벤트 핸들러 등록 (수정된 부분)
      $('#tab-list').on('click', '.nav-item .close', function (e) {
    	  e.preventDefault();
          var tabId = $(this).closest('.nav-item').index();
          var id = $(this).attr("href");
          var menuurl = $(this).data("url");
 
          // 현재 보여지고 있는 탭이면 맨 앞 탭을 활성화
          if ($('.nav-link').eq(tabId).hasClass('active')) {
        	  TabClose(tabId, true);
          } else {
        	  TabClose(tabId, false); 
          }
          //무조건 첫번째 탭으로 이동하게 처리
    	  $('#tab-list .nav-item').first().find('.nav-link').click();

      });

      function TabOpen(e,id,menuurl) {
    	  
    	  if(menuurl != '') {
    		  $('.tab-pane#'+id).load(menuurl); 
    	  } 
    	  // 
    	  $('.nav-link').eq(e).click(function () {       
        	  
    		  $('.tab-pane').empty();   //추가
	          $('#tab-list').find('.nav-link').removeClass('active'); 
	          $('.tab-content').children().removeClass('active');   
	          $('.nav-link#'+id).addClass('active');    
	          $('.tab-pane#'+id).addClass('active');
    		  $('.tab-pane#'+id).load(menuurl);//추가 
 
          });

      }
      
       
      // 수정된 부분: 두 번째 파라미터 added
      function TabClose(e, added) {
    	  
        // 수정된 부분: 현재 보여지고 있는 탭이면 맨 앞 탭을 활성화
        if (added == true) {   
        	$('.nav-link').eq(0).addClass('active');
        	$('.tab-pane').eq(0).addClass('active');
        	
        	var element = $('.nav-link').eq(0);        	
        	element.click(); 
        } else if (added == false) {
        	$('.nav-link').eq(e).addClass('active');
          	$('.tab-pane').eq(e).addClass('active'); 
      		var element = $('.nav-link').eq(e);
      		element.click(); 
        }

        // 클릭된 닫기 버튼의 부모 .nav-item을 제거
        $('.nav-link').eq(e).closest('.nav-item').remove();
        $('.tab-pane').eq(e).remove(); 
      }

   

});


