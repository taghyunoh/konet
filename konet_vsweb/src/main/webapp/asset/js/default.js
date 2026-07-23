// 스크롤 유무
$.fn.hasVerticalScrollbar = function() {
    return this.get(0).scrollHeight > this.height();
}

// Scroll End
var ignoreScroll = false;
var ns = (new Date).getTime();
var special = $.event.special;
var dispatch = $.event.handle || $.event.dispatch;
var scroll = 'scroll';
var scrollEnd = scroll + 'end';
var nsScrollEnd = scroll + '.' + scrollEnd + ns
special.scrollend = {
    delay: 300,
    setup: function() {
        var pid, handler = function(e) {
            var _this = this,
                args = arguments;

            clearTimeout(pid);
            pid = setTimeout(function() {
                e.type = scrollEnd;
                dispatch.apply(_this, args);
            }, special.scrollend.delay);
        };

        $(this).on(nsScrollEnd, handler);
    },
    teardown: function() {
        $(this).off(nsScrollEnd);
    }
};

// Touch Prevent
function lockTouch(e) {
    e.stopImmediatePropagation();
}

// is Mobile
function _isMobile() {
    var isMobile = (/iphone|ipod|android|blackberry|fennec/).test(navigator.userAgent.toLowerCase());
    return isMobile;
}

// Responsive 이미지 변환
function ResponsiveImagesNew() {
    $(".imgResponsive").each(function() {
        var winW = window.innerWidth;
        if (winW > 1023 && $(this).attr("data-media-type") != "pc") {
            var url = $(this).attr("data-src-pc");
            $(this).attr("data-media-type", "pc");
            chgImg($(this), url, "pc");
        }
        if (winW <= 1023 && $(this).attr("data-media-type") != "mobile") {
            var url = $(this).attr("data-src-mobile");
            $(this).attr("data-media-type", "mobile");
            chgImg($(this), url, "mobile");
        }
    });

    function chgImg($target, url, type) {
        $target.attr("src", url);
        $target.attr("data-media-type", type);
    }

    if ($('.container').length) {
        $('.container').css({
            minHeight: window.innerHeight - $('#footer').outerHeight(true)
        });
    }
}

// allmenuUI
function allmenuUI(){
    var el = $('.menuWrap');

    if(el.length <= 0){
        return;
    }

    // Open
    $(document).on('click' , '.btnMenu', function(e){
        e.preventDefault();

        el.after('<div class="layerAllmenuBg"></div>');

        el.addClass('open');
        TweenMax.to(el.next('.layerAllmenuBg') , 0.3 , {display : 'block' , opacity : 1});
        document.addEventListener('touchmove' , lockTouch, false);

        el.one('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', function() {
            $('html').addClass('closeHidden');
            $('html').css({height : $('.wrap').outerHeight(true)});
        });
    });

    // Close
    el.find('.menuClose').on('click' , function(e){
        e.preventDefault();

        el.removeClass('open');
        $('html').removeClass('closeHidden');
        $('html').removeAttr('style');

        el.one('transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', function() {
            el.next('.layerAllmenuBg').stop().fadeOut(function(){
                $(this).remove();
            });
            document.removeEventListener('touchmove' , lockTouch, false);
        });
    });
}

// LayerPopup 열기
var idxLayPop = 0;
function layerPop(n, target, type){
    var $this = $('.popupWrap.'+target);
    if(n == 'open'){
        idxLayPop = idxLayPop + 1;
        TweenMax.set($this, {zIndex : 9999 + idxLayPop});
        if ($this.hasClass('popupFull')){
            TweenMax.set($this.find('.popupInner'), {
                opacity : 0,
                y : 500
            });
        } else {
            TweenMax.set($this.find('.popupInner'), {
                opacity : 0,
                y : -100
            });
        }

        $('html').addClass('closeHidden');

        $this.stop().fadeIn(300, function(){
            TweenMax.to($this.find('.popupInner'), 0.4, {
                opacity : 1,
                y : 0
            });
            $this.find('.popContent').css({height : $this.find('.popupInner').outerHeight(true) - $this.find('.popupHead').outerHeight(true)});
        });

    }else{
        idxLayPop = idxLayPop - 1;
        if ($this.hasClass('popupFull')){
            TweenMax.to($this.find('.popupInner'), 0.4, {
                opacity : 0,
                y : 500,
                onComplete : fComplete()
            });
        } else {
            TweenMax.to($this.find('.popupInner'), 0.4, {
                opacity : 0,
                y : -100,
                onComplete : fComplete()
            });
        }
        function fComplete() {
            $this.stop().fadeOut(300, function(){
                $this.find('.popupInner').removeAttr('style');
            });
            $this.find('.popContent').removeAttr('style');
            $('html').removeClass('closeHidden');
        }
    }
}


// 아코디언
function accordionUI() {
    var el = $('.accordionList');

    if (el.length <= 0) {
        return;
    }

    el.find('>ul>li').removeClass('on');

    bindEvents();

    function bindEvents() {
        el.find('.accordionAnchor').off('click.accordionEvt').on('click.accordionEvt', function(e) {
            e.preventDefault();

            var index = $(this).closest('li').index();

            $(this).closest(el).find('>ul>li').each(function(idx, obj) {
                if (idx == index) {
                    if ($(obj).hasClass('on')) {
                        $(obj).removeClass('on');
                    } else {
                        $(obj).addClass('on');
                    }
                } else {
                    $(obj).removeClass('on');
                }
            });

        });
    }
}

// insCalSecUI
function insCalSecUI() {
    var el;

    el = $('.insCalSec');
    insInduceFix = $('.insInduceFix');

    if (el.lenght <= 0 && insInduceFix.length <= 0) {
        return;
    }

    bindEvents();

    function bindEvents() {
        $(window).on('scroll', function() {
            var footer = $('#footer');

            if ($(window).scrollTop() >= $('.wrap').outerHeight(true) - window.innerHeight - footer.height()) {
                el.find('.insCalBtnWrap').addClass('nofixed');
                insInduceFix.addClass('nofixed');
            } else {
                el.find('.insCalBtnWrap').removeClass('nofixed');
                insInduceFix.removeClass('nofixed');
            }
        }).trigger('scroll');

        el.find('.insCalBtnWrap .btn.character').on('click', function(e) {
            e.preventDefault();
            $(document).scrollTop(0);
            $('body').addClass('pageOpen');

		   //Mobile
		   if($('html').hasClass('ui-m')){
			   $('.ui-m .mainWrap').css({
    			   marginTop : -$('.ui-m .mainSec').outerHeight(true) + 45
    		   });
		   }else {
			   $('.ui-m .mainWrap').css({
    			   marginTop : ''
    		   });
		   }

		   $(window).off('resize.mainResize').on('resize.mainResize' , function(){
	   			//Mobile
	   			if($('html').hasClass('ui-m')){
	   				el.find('.insCalStep.result').css({height : el.find('.insCalStep.first').outerHeight(true)});
	   			}
	   			else{
	   				el.find('.insCalStep.result').css({height : ''});
	   			}

				if($('body').hasClass('pageOpen')){
					$('.ui-m .mainWrap').css({
	     			   marginTop : -$('.ui-m .mainSec').outerHeight(true) + 45
	     		   });
				}
				else{
					$('.ui-m .mainWrap').css({
	     			   marginTop : ''
	     		   });
				}
	   		}).trigger('resize.mainResize')
        });
    }
}

// file custom
function fileUploadUI(){
    var el = $('.fileBox');
    var uploadFile;
    var btnDel;

    if(el.length <= 0){
        return;
    }

    el.each(function(idx, obj){
        uploadFile = $(obj).find('.uploadBtn');
        btnDel = $(obj).find('.del');

        uploadFile.on('change', function(){
            var filename;
            if(window.FileReader){
                if( $(this)[0].files[0] ){
                    filename = $(this)[0].files[0].name;

                    $(this).parent('.fileBox').addClass('on');
                    btnDel.addClass("on");
                    $(this).siblings('.fileName').find('span').html(filename);
                }
                else{
                    filename = '';

                    $(this).parent('.fileBox').removeClass('on');
                    btnDel.removeClass("on");
                    $(this).siblings('.fileName').find('span').html(filename);
                }
            } else {
                filename = $(this).val().split('/').pop().split('\\').pop();

                $(this).parent('.fileBox').addClass('on');
                btnDel.addClass("on");
                $(this).siblings('.fileName').find('span').html(filename);
            }

        });

        // 첨부파일 삭제
        btnDel.on('click', function(e){
            e.preventDefault();
            uploadFile.val('').trigger('change');
            $(this).removeClass('on');
        });

    });
}


// datepickerUI ( 달력 UI)
function datepickerUI() {
    var el;
    var elBtn;
    var elIco;

    el = $('.inputDate').find('input:text');
    elBtn = $('.ui-datepicker-trigger');
    elIco = $('.btnCalendar');

    bindEvents();

    function defaultOption() {
        if ($.datepicker && !window.GROBAL_datepicker) {
            $.datepicker.regional['ko'] = {
                closeText: '취소',
                prevText: '이전달로 이동',
                nextText: '다음달로 이동',
                currentText: '오늘',
                monthNames: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],
                monthNamesShort: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"],
                dayNames: ["일", "월", "화", "수", "목", "금", "토"],
                dayNamesShort: ["일", "월", "화", "수", "목", "금", "토"],
                dayNamesMin: ["일", "월", "화", "수", "목", "금", "토"],
                weekHeader: 'Wk',
                dateFormat: 'yy.mm.dd ',
                buttonText: '달력보기',
                showMonthAfterYear: true,
                //yearSuffix: '년',
                showOtherMonths: true,
                showButtonPanel: true,
                changeMonth: true,
                changeYear: true,
                constrainInput: true,
                showOn: 'button',
                buttonText: 'Select date',
                onSelect: function(dateText, inst) {
                    $(this).focus();
                },
                beforeShow: function(dateText, inst) {
                    $('.datepickerMask').remove();
                    $('.ui-datepicker').after('<div class="datepickerMask"></div>');
                },
                onClose: function() {
                    $('.ui-datepicker').find('.ui-datepicker-head').remove();
                    $('.datepickerMask').remove();
                },
                onChangeMonthYear: function(year, month, inst) {
                }
            };
            $.datepicker.setDefaults($.datepicker.regional['ko']);
            window.GROBAL_datepicker = true;

            $.datepicker._gotoToday = function(id) {
                $(id).datepicker('setDate', new Date()).datepicker('hide').blur();
            };
        }
    }

    function bindEvents() {
        defaultOption();

        if ($.datepicker) {
            el.datepicker();

            elBtn = $('.ui-datepicker-trigger');
            elIco = $('.btnCalendar');
            elBtn.hide();

            // 키보드 접근 불가능하게 하기 위해 href 제거
            elIco.attr('aria-hidden', true);
            elIco.removeAttr('href').css('cursor', 'pointer');
            elIco.off('click.eventCalendar').on('click.eventCalendar', function(e) {
                e.preventDefault();
                $(this).closest('.inputDate').find('.ui-datepicker-trigger').trigger('click');
                $(this).closest('.inputDate').find('input:text').trigger('focus');
            });

            el.off('click.eventCalendar').on('click.eventCalendar', function(e) {
                e.preventDefault();
                $(this).closest('.inputDate').find('.ui-datepicker-trigger').trigger('click');
                $(this).closest('.inputDate').find('input:text').trigger('focus');
            });
        }
    }
}

// 탭 메뉴
function tabUI() {
	var el = $('.tabGroup');

	if(el.length <= 0){
		return;
	}

	el.each(function(idx, obj){
		if($(obj).find('.tabs > li').hasClass('on')){
			$(obj).find('.tabs > li').each(function(){
				var idx = $(this).filter('.on').index();
				if(idx >= 0){
					$(obj).find('.tabs > li').eq(idx).addClass('on').siblings().removeClass('on');
					$(obj).find('> .tabCont').hide().eq(idx).show();
				}

			});
		}
		else{
			$(obj).find('.tabs > li').eq(0).addClass('on').siblings().removeClass('on');
			$(obj).find('> .tabCont').hide().eq(0).show();
		}

		bindEvents(obj);
	});


	function bindEvents(obj){
		var $this = $(obj);

		$this.find('.tabs > li > a').on('click', function(e){
			e.preventDefault();

			var index = $(this).closest('li').index();

			if($this.find('> .tabCont').eq(index).length <= 0){
				return;
			}

			$(this).closest(el).find('.tabs > li').eq(index).addClass('on').siblings().removeClass('on');
			$(this).closest(el).find('> .tabCont').hide().eq(index).show();

			// $(window).scrollTop(0);
		});

	}
}

function lnbInit() {

    var $anchor = $('.lnbAnchor.depth02.hasChild');

    $anchor.on('click', function(e){
        $('.lnbItem').removeClass('on');
        $(this).parent('.lnbItem').addClass('on');
    })
}

function treeViewInit(){
    $(".codeTree").treeview();
}

function menuInit() {

    var $anchor01 = $('.menuWrap .anchor01');
    var $anchor02 = $('.menuWrap .anchor02');

    $anchor01.on('click', function(e){
        $(this).parent('.item01').toggleClass('on');
        e.preventDefault();
    })
    $anchor02.on('click', function(e){
        $(this).parent('.item02').toggleClass('on');
        e.preventDefault();
    })
}

$(window).on('load' , function(){
    $(".imgFluid img").each(function (e) {
        var $this = $(this);
        var imgW = $this.prop('naturalWidth');
        var imgH = $this.prop('naturalHeight');

        if(imgW < imgH){
            $this.closest(".imgFluid").addClass("portrait");
        } else if(imgW > imgH) {
            $this.closest(".imgFluid").addClass("landscape");
        } else {
            $this.closest(".imgFluid").removeClass();
        }
    });
});


$(function() {
    ResponsiveImagesNew();
    $(window).resize(function() {
        ResponsiveImagesNew();
    }).resize();
    allmenuUI();
    accordionUI();
    insCalSecUI();
    fileUploadUI();
	tabUI();
    lnbInit();
    menuInit();
    datepickerUI();
    treeViewInit();

    if($('.wrap').hasClass('main')){
        $(window).on('scroll' , function(){
            var sct = $(this).scrollTop();
    
            if(sct > 0){
                $('#header').addClass('on');
            }
            else{
                $('#header').removeClass('on');
            }
        }).trigger('scroll');
    }
    
});
