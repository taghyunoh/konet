function getCodeMessage(messCode){
	
	let rtn_value = '';	
	
	if (messCode.trim() === null || messCode.trim() === undefined || messCode.trim() === '') {
		return rtn_value;
		
	} 
	
	let chk_val01 = messCode.substring(0,1).toUpperCase();
	let chk_val02 = messCode.substring(1,4).toUpperCase();
	
	switch (chk_val01) {
		case "A": // 
			if        (chk_val02 === "001"){
				rtn_value = '반드시 입력해 주시길 바랍니다 !!';
			} else if (chk_val02 === "002"){
				rtn_value = '형식에 맞지 않습니다. !!';
			} else if (chk_val02 === "003"){
				rtn_value = '숫자만 입력 해주십시요. !!';
			}
			 	 	
			break;
		case "B": // 
			if        (chk_val02 === "001"){
				rtn_value = '정상처리 되었습니다 !!';
			} else if (chk_val02 === "002"){
				rtn_value = '002';
			} 
			 	 	
			break;			
		case "C": // 
			if        (chk_val02 === "001"){
				rtn_value = '001';
			} else if (chk_val02 === "002"){
				rtn_value = '002';
			} 
			 	 	
			break;
	}
	return rtn_value;
		
}	






