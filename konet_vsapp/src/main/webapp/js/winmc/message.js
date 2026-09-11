function messageBox(flag,mess,setf,wsize,jobs,addmessyn){
	if(!!$("#messageDialog")){
         $("#messageDialog").remove();
    }

    /*
    확인(OK)/예(Yes)/아니요(No)/취소(Cancel)
    OK
    OK/Cancel
    Yes/No
    Yes/No/Cancel 

    1.MessageBox    
    2.Question       
    3.Information    
    4.Warning       
    5.Error 
    */
       
    /**
     * Bootstrap’s JavaScript modal plug-in to add dialogs
     * JavaScript의 alert를 대신할 수 있는 단순한 형태의 모달 창을 표시
     * @param option
     * backdrop:"true","false","static"(static for a backdrop which doesn't close the modal on click.), default is "static"
     * bg_color: modal-header에 사용할 수 있는 background color 
     * 단순한 헤더 컬러:"bg-primary", "bg-success", "bg-info", "bg-warning", "bg-danger", "bg-secondary", "bg-dark" and "bg-light"
     * Alert를 위한 컬러:"alert-primary", "alert-secondary", "alert-success", "alert-danger", "alert-warning", "alert-info", "alert-light", "alert-dark"
     * default is "bg-info"
     * title:"" 모달 창의 타이틀,
     * contents:"" 모달 창에 표시할 본문 내용,
     * focusedId:"" 모달 창을 닫을 때 포커스할 부모 창의 엘리먼트 ID
     * maxWidth:"" 모달 창의 사이즈를 표시(단위: px 고정)
     * draggable:"false" 모달 창을 드레그할 수 있도록 한다.(https://code.jquery.com/ui/1.12.1/jquery-ui.min.js)
     * contentHref: ajax로 호출할 컨텐트의 내용
     * @returns
     */
	
	if(!wsize){
		wsize = 120;
	}
     const modalColors = {
        "1": "bg-blue",  // MessageBox
        "2": "bg-info",     // Question
        "3": "bg-success",  // Information
        "4": "bg-warning",  // Warning
        "5": "bg-danger",   // Error
        "9": "bg-info"      // Confirm
    };

    const modalTitles = {
        "1": "알림", "2": "질문", "3": "정보", "4": "경고", "5": "오류", "9": "확인"
    };

    const modalButtons = {
        "1": '<button type="button" class="btn btn-blue rounded-pill px-4 py-2" onClick="modalClose()">확인(OK)</button>',
        "2": '<button type="button" class="btn btn-blue rounded-pill px-4 py-2" onClick="modalClose(\'Y\', \'' + jobs + '\',\'' + addmessyn + '\')">예(Yes)</button>' +
              '<button type="button" class="btn btn-info rounded-pill px-4 py-2" onClick="modalClose(\'N\', \'' + jobs + '\',\'' + addmessyn + '\')">아니오(No)</button>',
        "3": '<button type="button" class="btn btn-success rounded-pill px-4 py-2" onClick="modalClose()">확인(OK)</button>',
        "4": '<button type="button" class="btn btn-warning rounded-pill px-4 py-2" onClick="modalClose()">확인(OK)</button>',
        "5": '<button type="button" class="btn btn-danger rounded-pill px-4 py-2" onClick="modalClose()">확인(OK)</button>',
        "9": '<button type="button" class="btn btn-blue rounded-pill px-4 py-2" onClick="modalClose()">예(Yes)</button>' +
              '<button type="button" class="btn btn-info rounded-pill px-4 py-2" onClick="modalClose()">아니오(No)</button>'
    };

    let modalHTML = `
	<div class="modal fade" id="messageDialog" tabindex="-1" aria-hidden="true">
	    <div class="modal-dialog" style="margin-top: 50vh;">
	        <div class="modal-content rounded-3 overflow-hidden" style="max-width: ${wsize}%; margin: 0 auto;">
	            <div class="modal-header ${modalColors[flag]} text-white text-center w-100" style="padding: 8px;">
	                <h5 class="modal-title text-white mx-auto">${modalTitles[flag]}</h5>
	            </div>
	            <div class="modal-body text-center" style="padding: 10px;">
	                <p class="m-3 fw-bold text-dark">${mess}</p>
	            </div>
	            <div class="modal-footer border-0 d-flex justify-content-center" style="padding: 8px;">
	                ${modalButtons[flag]}
	            </div>
	        </div>
	    </div>
	</div>`;

    $("body").append(modalHTML);
    $("#messageDialog").modal('show');
}

function modalClose(flag, jobs, yesno) {
    $("#messageDialog").off('hide.bs.modal'); // 기존 이벤트 제거

    if (flag === "Y") {
        if (!jobs) {
            $("#messageDialog").on('hide.bs.modal', function () {
                messageBox("5", "<br> 처리할 Routine 정보가 정의되지 않았습니다.(담당자 문의 필요) !! <br>", "");
            });
        } else {
            CallRoutine(jobs.trim(), yesno);
        }
    } else {
        if (yesno === "Y") {
            $("#messageDialog").on('hide.bs.modal', function () {
                messageBox("3", "<br> 정상적으로 취소되었습니다. !! <br>", "");
            });
        }
    }

    $("#messageDialog").modal("hide");
}

function CallRoutine(JobName, yesno) {
    let errflag = false;
    let errmess = "";

    switch (JobName) {
        case "호출루틴명1":
            errmess = "<br> Error Message 내용입니다. <br>";
            errflag = true;
            break;
        case "호출루틴명2":
            break;
        default:
            break;
    }

    $("#messageDialog").on('hide.bs.modal', function () {
        if (errflag) {
            messageBox("5", errmess, "");
        } else {
            if (yesno === "Y") {
                messageBox("3", "<br> 정상적으로 처리되었습니다. !! <br>", "");
            }
        }
    });
}
