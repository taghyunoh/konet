function getLengthCounts(input) {
    let  kCount = 0;
    let  eCount = 0;
    let  nCount = 0;
    let  tCount = 0;

    for (let char of input) {
        if        (/[가-힣]/.test(char)) {
            kCount += 1;
        } else if (/[a-zA-Z]/.test(char)) {
            eCount += 1;
        } else if (/[0-9]/.test(char)) {
            nCount += 1;
        }
        tCount += 1;
    }

    return { kCount, eCount, nCount, tCount };
}

function getLength(input) {
	
    return input.length;
}

function isGetLength(input,count,focusid) {
	
    let  tCount = input.length;

    if (count === tCount) {		
		return true;		
	} else {
		messageBox("4","입력값이 " + tCount + "자리입니다. 정확하게 " + count + "자리 만큼 " + getCodeMessage("A001") ,focusid,"","");
		return false;	
	}    
}


function replaceMulti(str, ...targets) {
	/* 호출 예시
	replaceMulti(input, "-", "_", "+", "=", "&");
	*/
	for (const target of targets) {
        str = str.split(target).join(''); // 각 타겟 문자열을 공백으로 대체
    }
    return str.trim(); // 최종 결과 반환
	
}

function getFormat(input,format,mess_yn,focusid,cleanyn) {
	
	if (mess_yn === null || mess_yn === undefined) {
    	mess_yn ='N';
	} 
	if (cleanyn === null || cleanyn === undefined) {
    	cleanyn ='N';
	}
	if (focusid === null || focusid === undefined) {
    	focusid ='';
	}
	
	let rtn_value = "";
	let newstring = "";
	
	if (format === 'E1')
		newstring = input.replace(/[^\w\s@.-]/g, '').trim(); // 알파벳,숫자,'@','.','-'를 제외한 모든문자 제거.
	else 		
		newstring = input.replace(/[-년월일,()/\s]/g, '');     // 특정문자와 공백 제거
		
	switch (format.toUpperCase()) {
        case "D1": // yyyy-mm-dd
			rtn_value = newstring.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
			break;
		case "D2": // yyyy/mm/dd
			rtn_value = newstring.replace(/(\d{4})(\d{2})(\d{2})/, '$1/$2/$3');
			break;				
		case "D3": // yyyy년mm월dd
			rtn_value = newstring.replace(/(\d{4})(\d{2})(\d{2})/, '$1년$2월$3일');
			break;
		case "D4": // yyyy년 mm월 dd일
			rtn_value = newstring.replace(/(\d{4})(\d{2})(\d{2})/, '$1년 $2월 $3일');
			break;	
		case "D5": // yyyy-mm
			rtn_value = newstring.replace(/(\d{4})(\d{2})/, '$1-$2');
			break;
		case "D6": // yyyy년 mm월
			rtn_value = newstring.replace(/(\d{4})(\d{2})/, '$1년 $2월');
			break;			
		case "N1": // 100단위마다 ','
			rtn_value = newstring.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
			break;	
		case "T1":						
			const phoneRegex = newstring.match(/^(\d{2,3})(\d{3,4})(\d{4})$/);				   
			if (phoneRegex) {
    			if (phoneRegex[1].length === 2) { // 지역번호가 2자리인 경우 (02)
        			rtn_value = `${phoneRegex[1]}-${phoneRegex[2]}-${phoneRegex[3]}`;
    			}
    			else { // 지역번호나 휴대폰 번호 앞자리가 3자리인 경우
        			rtn_value = `${phoneRegex[1]}-${phoneRegex[2]}-${phoneRegex[3]}`;
    			}
			} else {
				rtn_value = input; // 원래값 input return
				if (mess_yn) {
					messageBox("4","전화번호 " + getCodeMessage("A002"),focusid,"","");
					mess_yn = 'N';
				}
			}		
			break;	
		case "E1":
			const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    		if (emailRegex.test(newstring)) {        		
        		rtn_value = newstring.replace(/(\w+)@(\w+)\.(\w+)/, '$1@$2.$3');
    		} else {
        		rtn_value = input; // 원래값 input return
				if (mess_yn) {
					messageBox("4","이메일 " + getCodeMessage("A002"),focusid,"","");
					mess_yn = 'N';
				}
    		}
		
	default:
			rtn_value = input; // 원래값 input return
			break;
    }

	if (mess_yn.toUpperCase() === "Y") {
		// 항상 날짜는 8자리를 입력 받아야 됨
		switch (format.substring(0,1)) {
	        case "d": // 날짜				
				const { kCount, eCount, nCount, tCount } = getLengthCounts(newstring);
				if (nCount !== 8){
					messageBox("4","날짜는 년(4자리)월(2자리)일(2자리)-예(20240101, 8자리)로 " + getCodeMessage("A001"),focusid,"","");
				}
				break;
		}
	}
	if (cleanyn.toUpperCase() === "Y"){
		$("#" + focusid).val("");
	}	
	
    return rtn_value;
}

function getValChk(input,f_mess,messcode,l_mess,focusid,cleanyn) {
	
	if (input.trim() === null || input.trim() === undefined || input.trim() === "") {
		
		if (cleanyn.toUpperCase() === "Y"){
			$("#" + focusid).val("");
		}
		
		messageBox("1",f_mess + getCodeMessage(messcode) + l_mess,focusid,"","");
		
		return false;
		
	}
	return true;
}

function getReqValChk(formId) {
	const form = document.getElementById(formId);
    if (!form) {
        messageBox("4","요청하신 Form 정보가 없습니다. Not found - 점검하지 못했습니다. ","","",""); 
        return false;
    }

	const inputs = Array.from(form.querySelectorAll('input, select, textarea'));
    
    for (let i = 0; i < inputs.length; i++) {
        const input = inputs[i];
        const isRequired = input.hasAttribute('required');
        
        if (isRequired) {
            if (input.type === 'checkbox' || input.type === 'radio') {
                const checkedInGroup = form.querySelector(`input[name="${input.name}"]:checked`);
                if (!checkedInGroup) {
					messageBox("4",`${input.name}` + " 값을 선택해 주세요 ","","","");
                    input.focus();
                    return false;
                }
            } else {
                // 다른 타입의 input 요소
                const inputValue = input.value.trim();
                if (inputValue === '') {
					messageBox("4",`${input.name}` + " - 필드는, " + getCodeMessage("A001"),`${input.id}`,"","");
                    input.focus();
                    return false;
                }
            }
        }
    }
    return true;
}

function inputEnterFocus(formId) {
    const form = document.getElementById(formId);
    if (!form) {
        messageBox("4","요청하신 Form 정보가 없습니다. Not found ","","",""); 
        return;
    }

    const inputs = Array.from(form.querySelectorAll('input, select'));

    inputs.forEach((input, index) => {
        input.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault(); // 기본 Enter 키 동작 방지
                const isRequired = input.hasAttribute('required');
                const inputValue = input.value.trim();

                if (isRequired && inputValue === '') {
                    // 필수 입력 필드가 비어 있으면 포커스 유지
                    input.focus();
                } else {
                    // 다음 입력 필드로 이동
                    const nextInput = inputs[index + 1];
                    if (nextInput) {
                        nextInput.focus();
                    } else {
                        // 마지막 필드에서 Enter를 누르면 첫 번째로 이동
                        inputs[0].focus();
                    }
                }
            }
        });
    });
}


function formValCheck(formId, validations) {

	const form = document.getElementById(formId);
	
    const rtns = [];

	if (!form) {
        messageBox("4","요청하신 Form 정보가 없습니다. Not found - 점검하지 못했습니다. ","","",""); 
        return false;
    }
	const inputs = Array.from(form.querySelectorAll('input, select, textarea'));

    for (let i = 0; i < inputs.length; i++) {
	
		const input = inputs[i];
		
		let key   = input.id;		
		let name  = input.name;
		let len   = 0; 
        let min   = input.minLength; 
        let max   = input.maxLength;
		let req   = input.required;
        let num   = input.type === 'number' || input.inputMode === 'numeric';
        let spc   = false; 
        let clr   = false;
		let chr   = '';
		let type  = input.type;
    	let value = input.value; 
		// ChangeKey 규칙
		// checkbox, radio의 id는 Modal내 정의된 이름가 같지 않아 변경
		// checkbox, radio는 name으로 Modal내 정의된 이름가 같게 한다. 
		// c_Key값은 Result에 담을때만 사용, 내부에서는 key로 사용해야 됨 (focus등 ...)
		let c_Key = input.id;     
		
		if (Object.hasOwn(validations, key)) {

			const [keyId, validation] = [key, validations[key]];
    		const {kname, k_len, k_min, k_max, k_req, k_num, k_spc, k_chr, k_clr } = validation;

			// 재정의해서 넘긴값을 최종으로 확인함
			if (kname) { name = kname; }
			if (k_len) { len  = k_len; }
			if (k_min) { min  = k_min; }
			if (k_max) { max  = k_max; }
			if (k_req) { req  = k_req; }
			if (k_num) { num  = k_num; }
			if (k_spc) { spc  = k_spc; }
			if (k_chr) { chr  = k_chr; }
			if (k_clr) { clr  = k_clr; }
		}		
		
		if (type === 'checkbox' || type === 'radio') {
            const checkedInGroup = document.querySelector(`input[name="${input.name}"]:checked`);
			value = checkedInGroup ? checkedInGroup.value : '';			
			c_Key = name;
			
        } else if (type === 'select-one' || type === 'select-multiple') {
			value = Array.from(input.selectedOptions).map(option => option.value).join(',');
		} 
		
		if (num) {	//숫자인 경우 초기값 0으로 하기로 함
			if (value === null || value === undefined || value === '') { 
				value = '0';
			}
		}
		
		// null 또는 undefined 체크
        if (value === null || value === undefined || value === '') {
	        if (req || spc) {
				messageBox("4", name + " - 필드는, " + getCodeMessage("A001"), key, "","");
				
				if (clr) {
					$("#" + key).val("")
				}
                return null;
            } else {
				value = '';
			}
			
        } else {
            // 타입 체크 및 변환
            let str = String(value);

            // 지정된 문자 제거
            if (chr) {
			    const escapedChars = chr.replace(/[-/\\^$*+?.()|[\]{}]/g, '\\$&');
			    const regex = new RegExp('[' + escapedChars + ']', 'g');
			    str = str.replace(regex, '');
			}

            str = str.trim();
			
            // 숫자만 입력 체크
            if (num && !/^\d+$/.test(str)) {
                messageBox("4", name + " - 필드는, " + getCodeMessage("A003"), key,"","");
				if (clr) {
					$("#" + key).val("");
				}
                return null;
            }

            // 길이 체크
            const { kCount, eCount, nCount, tCount } = getLengthCounts(str);
				
            if (len > 0 && tCount != len) {
                
				messageBox("4", name + " 입력값이 " + tCount + " 자리입니다. 정확하게 " + len + "자리 만큼 " + getCodeMessage("A001") ,key,"","");
				return null;

			} else if ((min > 0 && tCount < min) || 
			           (max > 0 && tCount > max)) {
				messageBox("4", name + " 입력값이 " + min + " 자리 보다 크고 " + max + " 자리 보다 작아야 합니다. ",key,"","");
				
				if (clr) {
					$("#" + key).val("");
				}
            	return null;
            }
			value = str;
        }
		
		// 기존 항목의 인덱스를 찾습니다. (radio는 같은 Element 여러개 존재함 )
		const index = rtns.findIndex(item => item.id === c_Key);
				  
		if (index !== -1) {
		    // 중복된 key가 있으면 해당 항목을 업데이트합니다.
		    rtns[index].val = value;
		} else {
		    // 중복된 key가 없으면 새 항목을 추가합니다.
		    rtns.push({ id: c_Key, val: value });
		}
	}	
	return rtns;	
	
}


function formValClear(formId) {

	const form = document.getElementById(formId);

	if (!form) {
        messageBox("4","요청하신 Form 정보가 없습니다. Not found - 점검하지 못했습니다. ","","",""); 
        return false;
    }
	const inputs = Array.from(form.querySelectorAll('input, select, textarea'));

    for (let i = 0; i < inputs.length; i++) {
        const input = inputs[i];
        
        if (input.tagName === 'SELECT') {
            if (!input.querySelector('option[selected]')) {
                input.selectedIndex = 0; // 기본 선택된 옵션이 없으면 첫 번째 옵션 선택
            }
        } else if (input.type === 'checkbox' || input.type === 'radio') {
            input.checked = input.defaultChecked;
		} else {
            input.value = input.defaultValue;
        }
    }
}	

function formValueSet(formId,edits) {

	const form = document.getElementById(formId);

	if (!form) {
        messageBox("4","요청하신 Form 정보가 없습니다. Not found - 점검하지 못했습니다. ","","",""); 
        return false;
    }
	const inputs = Array.from(form.querySelectorAll('input, select, textarea'));

    for (let i = 0; i < inputs.length; i++) {
	
        const input = inputs[i];
        
        if (input.type === 'checkbox' || input.type === 'radio') {
            if (edits.hasOwnProperty(input.name)) {
                input.checked = (input.value === edits[input.name].toString());
            }
        } else {
            if (edits.hasOwnProperty(input.id)) {
                input.value = edits[input.id];
            }
        }
    }
}






