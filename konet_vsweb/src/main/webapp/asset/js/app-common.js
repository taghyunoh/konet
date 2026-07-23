/**
 * 
 */
var IorA = navigator.userAgent.toLowerCase();
//
var android_interface = [
	{func: "Function Name", data: {cmd:"command", callback:"callback Function Name", data:""}},
	{func: "f100", data: {cmd:"100", callback:"appCloseCallBack", data:""}},
	{func: "f102", data: {cmd:"102", callback:"userInfoCallBack", data:""}},
	{func: "f200", data: {cmd:"200", callback:"isensCallBack", data:""}},
	{func: "f201", data: {cmd:"201", callback:"foodlensCallBack", data:""}},
	{func: "f202", data: {cmd:"202", callback:"foodEditCallBack", data:""}},
	{func: "f203", data: {cmd:"203", callback:"foodImageCallBack", data:""}},
	{func: "f301", data: {cmd:"301", callback:"getHealthDataCallBack", data:""}},
	{func: "f302", data: {cmd:"302", callback:"getDataCallBack", data:""}},
	{func: "f303", data: {cmd:"303", callback:"BleCallBack", data:""}},
	{func: "f304", data: {cmd:"304", callback:"BleCheckCallBack", data:""}},
	{func: "f305", data: {cmd:"305", callback:"BleStartCallBack", data:""}},
	{func: "f501", data: {cmd:"501", callback:"walkDataCallBack", data:""}},
	{func: "f502", data: {cmd:"502", callback:"sleepDataCallBack", data:""}},
	{func: "f503", data: {cmd:"503", callback:"walkServiceCallBack", data:""}},
	{func: "f504", data: {cmd:"504", callback:"sleepServiceCallBack", data:""}},
	{func: "Error", data: {cmd:"400", callback:"ErrorDiologCallBack", data:{msg:"callAdroid Error"}}}
];
	
//case1 data가 없는 interface 수정본
function callAndroid(funcName, ifData) {
	var obj = android_interface.filter(function(item){
											return item.func === funcName
										})[0].data;
	obj.data = ifData;
	
	const JsonEncodeString = JSON.stringify(obj);
	if(IorA.indexOf("android") !== -1){
		Android.callAppFunc(JsonEncodeString);
		console.log("안드");
	}else if(IorA.indexOf("iphone") !== -1){
		window.webkit.messageHandlers.IOS.postMessage(JsonEncodeString);
		console.log("iphone Login");
	}else{
		console.log("Web Login");
	}
	console.log("callAndroid JsonEncodeString : " + JsonEncodeString);
}

//case2 data가 이미 있는 interface
function callAndroid2(funcName){
	var obj = android_interface.filter(function(item){
										return item.func === funcName
										})[0].data;

	const JsonEncodeString = JSON.stringify(obj)
	if(IorA.indexOf("android") !== -1){
		Android.callAppFunc(JsonEncodeString);
		console.log("안드");
	}else if(IorA.indexOf("iphone") !== -1){
		window.webkit.messageHandlers.IOS.postMessage(JsonEncodeString);
		console.log("iphone Login");
	}else{
		console.log("Web Login");
	}
	console.log(JsonEncodeString);
	
}

function getUserLoginInfo(data) {
	loginInfo(data);
}

function appBackButton() {
	var conF = confirm("종료하시겠습니까?");
	//확인시 100번커맨드
	if(conF == true){
		sessionStorage.clear();
		callAndroid2("f100");
	}
}  
//Native에서 호출할 펑션 
function returnFoodData(data){
	console.log(data);
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/insertFoodData.do","POST",data,function(response){
		console.log(response);
	})
}
function editFoodData(data){
	console.log(data);
	//$("#FoodData").text(data);
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/editFoodData.do","POST",data,function(response){
		console.log(response);
	})
}
function returnStepData(data){
	console.log(data);
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/updateStep.do","POST",data,function(response){
		console.log(response);
	})
}
function returnDistanceData(data){
	console.log(data);
}
function returnCalData(data){
	console.log(data);
}
function returnHealthData(data){
	console.log(data);
	CommonUtil.callAjax(CommonUtil.getContextPath() + "/updateHealth.do","POST",data,function(response){
		console.log(response);
	})
}

