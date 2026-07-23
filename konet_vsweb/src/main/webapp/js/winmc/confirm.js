function confirmBox(flag,mess,setf){
	if(!!$("#confirmDialog")){
         $("#confirmDialog").remove();
    }

	switch (flag) {
        case "1": // Question
            var option = {
                backdrop   : "static",
                bg_color   : "bg-info",
                title      : "Confirm",
                contents   : '' + mess + '',
                focusedId  : '' + setf + '',
                buttons    : '<button id="confirmYes" type="button" class="btn btn-blue" data-dismiss="modal">예(Yes)</button>' +
                             '<button id="confirmNo"  type="button" class="btn btn-info" data-dismiss="modal">노(No)</button>',
                maxWidth   : window.innerWidth,
                draggable  : "true",
                contentHref: ""
            }
            break;
        
       default:
            break;
    }   
        
    // option = $.extend(option);
    var dialog =
        '<div class="modal fade" id="confirmDialog" tabindex="-1" data-backdrop="' + option.backdrop + '" role="dialog" aria-hidden="false" data-keyboard="false">' +
        '  <div class="modal-dialog modal-dialog-centered  modal-dialog-scrollable"  role="dialog">' +
        '    <div class="modal-content">' +
        '      <div class="modal-header ' + option.bg_color + '" style="text-align:center>' +
        '        <h5 class="modal-title" id="alertTitle">' + option.title + '</h5>' +
        '        <button type="button" class="close" data-dismiss="modal" aria-label="Close">' +
        '          <span aria-hidden="true">&times;</span>' +
        '        </button>' +
        '      </div>' +
        '      <div class="modal-body" style="text-align:left">' +
                    option.contents +
        '      </div>' +
        '      <div class="modal-footer">' +
                    option.buttons +
        '      </div>' +
        '    </div>' +
        '  </div>' +
        '</div>';
    $("body").append(dialog);
    $('#confirmDialog').on('hidden.bs.modal', function (e) {
        if(option.focusedId !== ""){ $("#" + option.focusedId).focus();}
    });
    
    // 모달을 드레그할 수 있도록 처리
    if( option.draggable === "true"){
        
        // Make the DIV element draggable:
        var element = document.querySelector('#confirmDialog');
        dragElement(element);

        function dragElement(elmnt) {
            var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
            if (elmnt.querySelector('.modal-content')) {
                // if present, the header is where you move the DIV from:
                elmnt.querySelector('.modal-content').onmousedown = dragMouseDown;
            } else {
                // otherwise, move the DIV from anywhere inside the DIV:
                elmnt.onmousedown = dragMouseDown;
            }

            function dragMouseDown(e) {
                e = e || window.event;
                // get the mouse cursor position at startup:
                pos3 = e.clientX;
                pos4 = e.clientY;
                document.onmouseup = closeDragElement;
                // call a function whenever the cursor moves:
                document.onmousemove = elementDrag;
            }

            function elementDrag(e) {
                e = e || window.event;
                // calculate the new cursor position:
                pos1 = pos3 - e.clientX;
                pos2 = pos4 - e.clientY;
                pos3 = e.clientX;
                pos4 = e.clientY;
                // set the element's new position:
                elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
                elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
            }

            function closeDragElement() {
                // stop moving when mouse button is released:
                document.onmouseup   = null;
                document.onmousemove = null;
            }
        }
    }
    
    // 모달의 사이즈를 조정할 수 있도록 처리  
    $('#confirmDialog').on('show.bs.modal', function () {
        if( option.maxWidth !== ""){
            $(this).find('.modal-dialog').attr('style', 'max-width: ' + option.maxWidth + 'px;'); // modal.scss의 max-width를 override
        }
        $(this).find('.modal-body').css({'max-height':'100%'});
        if( option.contentHref !== ""){
            $(this).find(".modal-body").load(option.contentHref);
        }
    });
    $("#confirmDialog").modal('show');


}
