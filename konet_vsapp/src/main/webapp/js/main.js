
$(document).ready(function () {
	
	// 데이트피커 단일
	$('input[type = date]').daterangepicker({
	  singleDatePicker: true,
	  showDropdowns: false,
	  minYear: 2000,
	  maxYear: 2999,
	  startView: 'days', 
	  locale: {
	    format: 'YYYY-MM-DD',
	    separator: " ~ ",
	    applyLabel: "확인",
	    cancelLabel: "취소",
	    fromLabel: "From",
	    toLabel: "To", 
	    customRangeLabel: "Custom",
	    weekLabel: "주",
	    daysOfWeek: [
	      "일", "월", "화", "수", "목", "금", "토"
	    ],
	    monthNames: [
	      "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"
	    ],
	    firstDay: 1,
	  },
	}, function (start, end, label) {
	  // var years = moment().diff(start, 'years');
	});
	  
	//년월 데이트피커
	 // 실제로 보여지는 날짜를 정의.
	 $('#txt-work-month').text(new Date().getFullYear() + '년 ' + (new Date().getMonth() + 1) + '월');
	 // monthpicker 에서 사용할 초기 날짜 정의
	 $('.monthpicker').val(new Date().getFullYear() + '-' + (new Date().getMonth() + 1));
	
	 // monthpicker 적용
	 $('.monthpicker').bootstrapMonthpicker({
	   // from: '2014-05',
	   // to: '2014-10', 
	   // 달을 선택한 다음의 이벤트 정의 
	   onSelect: function (value) {
	     var workMonthStr = '';
	     /* 
	     * monthpicker 라이브러리에서 기본으로 "-" 를 사용
	     **************************************/
	     var splitDate = $.trim(value).split("-");
	
	     // 표한하고 싶으신 포맷으로 알아서 정의하시면 됩니다.
	     $.each(splitDate, function (_idx, _date) {
	       if (_idx == 0)
	         workMonthStr += _date + '년 ';
	       if (_idx == 1)
	         workMonthStr += _date + '월';
	     });
	
	     // 표시
	     $('#txt-work-month').text(workMonthStr);
	   } 
	 });
	 // #choice-work-month 에 monthpicker 이벤트 정의
	 $('#choice-work-month').click(function () {
	   $('.monthpicker').click();
	 });
	 
});