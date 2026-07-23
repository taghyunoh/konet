/*  
 * JQGRID 추가, 삭제, 수정 ,조회 관련 공통 함수 선언
 * 
 */  
// JQGRID 행추가
function fn_GridAdd(grid, rowId) {
	
	if(rowId == "1"){
		jQuery("#"+grid).jqGrid('clearGridData');
	}
	
	var rowData ={"iud":"I"};
	
	if($("#"+grid).getGridParam( "selrow" ) == null){
		$("#"+grid).jqGrid("addRowData",rowId,rowData); // 첫 행에 Row 추가 
		jQuery("#"+grid).jqGrid('editRow',rowId,false);
	}else{
		$("#"+grid).jqGrid("addRowData",rowId,rowData,'after',$("#"+grid).getGridParam( "selrow" )); //선택된 행 뒤에 Row추가
		jQuery("#"+grid).jqGrid('editRow',rowId,false);
	}
	 
	$("#"+grid).jqGrid('setSelection', rowId, true);  
	//                     
}  


function fn_GridUpdate(grid, rowid){
	
	var rowid = $("#"+grid ).getGridParam( "selrow" );
	if(rowid == null) {
		alert(i18n.message_019); //"수정할 정보가 존재하지 않습니다."
		return;
	} 
	//
	jQuery("#"+grid ).editRow(rowid);
	$("#"+grid).jqGrid('setRowData', rowid, { iud: "U"});
}

// 행 삭제(Grid 이름, row 정보, 삭제가능여부
function fn_GridDelete(grid, rowid, gubun){ 

	var rowid = $("#"+grid ).getGridParam( "selrow" );
	//이전 row
	var before_rowid = parseInt($("#"+grid).getGridParam( "selrow" ) - 1); 
	var iud = $("#"+grid).getCell(rowid, "iud");  
	
	if(iud == "I"){ 
		$("#"+grid).jqGrid("delRowData", rowid); // 행 삭제
		jQuery("#"+grid).jqGrid('editRow',rowid,false);
		if(before_rowid > 0)
			$("#"+grid).jqGrid('setSelection', before_rowid, true);  
	}else{
		if(gubun == "N")
			alert(i18n.message_190); //"이미 등록된 정보는 삭제가 불가합니다.!"
		else{ 
//			jQuery("#"+grid).editRow(rowid);
			$("#"+grid).jqGrid('setRowData', rowid, { iud: "D"});
		}
			
		return;
	} 
	
}
