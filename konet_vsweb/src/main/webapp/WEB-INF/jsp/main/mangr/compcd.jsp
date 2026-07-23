<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="decorator"
	uri="http://www.opensymphony.com/sitemesh/decorator"%>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page"%>
<%@ page import="java.util.Date"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title>회사/계약/사용자 관리</title>
<!-- 대시보드 테마 (medcost /assets) -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/libs/css/style.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/fonts/fontawesome/css/fontawesome-all.css">
<link rel="stylesheet" href="https://cdn.datatables.net/v/dt/jszip-3.10.1/dt-2.1.8/b-3.2.0/b-colvis-3.2.0/b-html5-3.2.0/b-print-3.2.0/datatables.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/winmc/addstyle.css?v=100">
<style> html, body { font-family:'Malgun Gothic','맑은 고딕','Apple SD Gothic Neo',sans-serif; } </style>
<!-- jQuery 먼저 -->
<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js"></script>
<script src="https://cdn.datatables.net/v/dt/jszip-3.10.1/dt-2.1.8/b-3.2.0/b-colvis-3.2.0/b-html5-3.2.0/b-print-3.2.0/datatables.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendor/inputmask/js/jquery.inputmask.bundle.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<!-- winmc 공통 프레임워크 (dataLoad/getFormat/formValueSet/comm_Check/messageBox/authControl 등) -->
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/main.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/mess_cd.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/message.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/commons.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/contact.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/loading.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/jqBootstrapValidation.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/schcommons.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/winmc/authControl.js"></script>
<script>
/* 컨텍스트 경로 (서버 /konet, 로컬 루트 "") — 모든 AJAX URL prefix */
var ctx = '${pageContext.request.contextPath}';
/* 권한 전역값 (authControl.js 의 applyAuthControl 참조) — 관리화면이므로 전체 허용 */
var s_insauth = 'Y', s_updauth = 'Y', s_delauth = 'Y', s_inqauth = 'Y';
$(document).on('init.dt', function(e, settings) {
    setTimeout(function() { try { $(settings.nTable).DataTable().columns.adjust(); } catch(e){} }, 300);
});
</script>
<style>
  /* iframe 단독 표시 — 테마의 사이드바 여백(264px) 제거하고 우측 전체 폭 사용 */
  html, body { margin:0 !important; padding:0 !important; }
  .dashboard-wrapper { margin-left:0 !important; padding:8px !important; width:100% !important; }
  .dashboard-content, .container-fluid { max-width:100% !important; width:100% !important; margin:0 !important; padding:0 !important; }
</style>

<!-- Customized Bootstrap Stylesheet -->

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" /> <!-- 파일다운로드관련아이콘 -->

<link href="${pageContext.request.contextPath}/css/winmc/style_comm.css?v=126"  rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/winmc/logi-skin.css?v=1"  rel="stylesheet"> <!-- logistics_demo 스타일 리스킨 -->
<style>
  /* ★ style_comm.css(.dashboard-wrapper margin-left:300px) 뒤에서 덮어써 우측 전체폭 사용 */
  html, body { margin:0 !important; padding:0 !important; }
  .dashboard-wrapper { margin-left:0 !important; padding:8px !important; width:100% !important; }
  .dashboard-content, .container-fluid { max-width:100% !important; width:100% !important; margin:0 !important; padding:0 !important; }
  /* 메인 그리드가 컨테이너 우측 끝까지 채우도록 강제 + 주소 컬럼이 남는 폭 흡수 */
  table#tableName.dataTable { width:100% !important; }
</style>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<!-- 카카오주소검색 -->
<!-- DataTables CSS -->

<style>
/* ===== 3개 모달 공통 라벨 스타일 ===== */
#modalName .modal-body .col-form-label,
#hc_modalName .modal-body .col-form-label,
#hu_modalName .modal-body .col-form-label {
	font-size: 14px; font-weight: 500; color: #333;
	background: linear-gradient(135deg, #b3ddf0 0%, #d4ecf7 100%);
	border-radius: 3px; padding: 4px 8px 4px 18px;
	display: flex; align-items: center;
	min-height: 30px; white-space: nowrap;
}
/* row 좌측 마진 리셋 (공지제목 바와 정렬) */
#modalName .modal-body .form-group.row,
#hc_modalName .modal-body .form-group.row,
#hu_modalName .modal-body .form-group.row {
	margin-left: 0; margin-right: 0;
}
/* 바디 간격 */
#modalName .modal-body,
#hc_modalName .modal-body,
#hu_modalName .modal-body {
	padding: 10px 18px;
}
#modalName .modal-body .form-group,
#hc_modalName .modal-body .form-group,
#hu_modalName .modal-body .form-group {
	margin-bottom: 3px; align-items: center;
}
/* 입력 필드 */
#modalName .modal-body .form-control,
#modalName .modal-body .custom-select,
#hc_modalName .modal-body .form-control,
#hc_modalName .modal-body .custom-select,
#hu_modalName .modal-body .form-control,
#hu_modalName .modal-body .custom-select {
	font-size: 14px; height: 30px; padding: 2px 8px;
}
#modalName .modal-body textarea.form-control,
#hc_modalName .modal-body textarea.form-control,
#hu_modalName .modal-body textarea.form-control {
	height: auto; padding: 4px 8px;
}
</style>
<!-- ============================================================== -->
<!-- Main Form start -->
<!-- ============================================================== -->
</head>
<body>
<div class="dashboard-wrapper">
	<div class="container-fluid  dashboard-content">
		<div class="row">
			<!-- ============================================================== -->
			<!-- data table start -->
			<!-- ============================================================== -->
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<div class="card">
					<div class="card-body">
						<div class="form-row mb-2">
							<div class="col-sm-4">
								<div class="input-group">
									<input id="findData" type="text" class="form-control"
										placeholder="3글자 이상 입력 후 [ enter ]" onkeyup="findEnterKey()"
										oninput="findField(this)">
									<div class="input-group-append">
										<button type="button" class="btn btn-info btn-sm  px-2"
										    style="background-color: #ffd43b; color: black;"
											onClick="fn_FindData()">
											조회. <i class="fas fa-search"></i>
										</button>
									</div>
								</div>
							</div>
							<div class="col-sm-6">
								<div class="btn-group ml-auto">
									<button class="btn btn-outline-dark" data-toggle="tooltip"
										data-placement="top" title="" onClick="fn_re_load()">
										재조회. <i class="fas fa-binoculars"></i>
									</button>
									<button class="btn btn-outline-dark btn-insert" data-toggle="tooltip"
										data-placement="top" title="신규 Data 입력"
										onClick="modal_Open('I')">
										입력. <i class="far fa-edit"></i>
									</button>
									<button class="btn btn-outline-dark btn-update" data-toggle="tooltip"
										data-placement="top" title="선택 Data 수정"
										onClick="modal_Open('U')">
										수정. <i class="far fa-save"></i>
									</button>
									<!-- <button class="btn btn-outline-dark d-none">   -->
									<button class="btn btn-outline-dark btn-delete" data-toggle="tooltip"
										data-toggle="tooltip" data-placement="top" title="선택 Data 삭제"
										onClick="modal_Open('D')">
										삭제. <i class="far fa-trash-alt"></i>
									</button>
									<button class="btn btn-outline-dark btn-delete" data-toggle="tooltip"
										data-toggle="tooltip" data-placement="top" title="체크 Data 삭제"
										onClick="fn_findchk()">
										체크삭제. <i class="far fa-calendar-check"></i>
									</button>
									<button class="btn btn-outline-dark" data-toggle="tooltip"
										data-placement="top" title="화면 Size 확대.축소"
										id="fullscreenToggle">
										화면확장축소. <i class="fas fa-expand" id="fullscreenIcon"></i>
									</button>
								</div>
							</div>
						</div>
						<div id="hospContractMsg" style="display: inline-block; margin-left: 16px; vertical-align: middle; color: #d32f2f; font-weight: bold; font-size: 13px; white-space: nowrap;">
							※ 계약정보가 변경된 경우 사용자 로그인 시 로그아웃하고 다시 진행 부탁합니다.
						</div>
						<div style="width: 100%;">
							<table id="tableName"
								class="display nowrap stripe hover cell-border  order-column responsive">

							</table>
						</div>
					</div>
				</div>
			</div>
			<!-- ============================================================== -->
			<!-- data table end   -->
			<!-- ============================================================== -->
		</div>
	</div>
	<!-- Bottom Section - Moved Inside dashboard-content -->
	<div class="bottom-section mt-0">
		<!-- mt-3로 상단과 간격 조정 -->
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<div class="card">
				<div class="card-body">
					<div class="d-flex justify-content-between">
						<div class="left-panel w-50 pr-2">
							<div
								class="d-flex justify-content-between align-items-center border p-2 rounded">
								<h6 class="mb-1 fw-bold text-dark">계약정보</h6>
								<div>
									<button class="btn btn-outline-dark btn-insert" data-toggle="tooltip"
										data-placement="top" title="신규 Data 입력"
										onClick="hc_modal_Open('I')">
										입력. <i class="far fa-edit"></i>
									</button>
									<button class="btn btn-outline-dark btn-update" data-toggle="tooltip"
										data-placement="top" title="선택 Data 수정"
										onClick="hc_modal_Open('U')">
										수정. <i class="far fa-save"></i>
									</button>
									<button class="btn btn-outline-dark btn-delete" data-toggle="tooltip"
										data-placement="top" title="선택 Data 삭제"
										onClick="hc_modal_Open('D')">
										삭제. <i class="far fa-trash-alt"></i>
									</button>
								</div>
							</div>
							<table id="hc_tableName"
								class="display nowrap table table-striped table-bordered">
							</table>
						</div>
						<div class="right-panel w-50 pl-2">
							<div
								class="d-flex justify-content-between align-items-center border p-2 rounded">
								<h6 class="mb-1 fw-bold text-dark">사용자정보</h6>
								<div>
									<button class="btn btn-outline-dark btn-insert" data-toggle="tooltip"
										data-placement="top" title="신규 Data 입력"
										onClick="hu_modal_Open('I')">
										입력. <i class="far fa-edit"></i>
									</button>
									<button class="btn btn-outline-dark btn-update" data-toggle="tooltip"
										data-placement="top" title="선택 Data 수정"
										onClick="hu_modal_Open('U')">
										수정. <i class="far fa-save"></i>
									</button>
									<button class="btn btn-outline-dark btn-delete" data-toggle="tooltip"
										data-placement="top" title="선택 Data 삭제"
										onClick="hu_modal_Open('D')">
										삭제. <i class="far fa-trash-alt"></i>
									</button>
								</div>
							</div>
							<table id="hu_tableName"
								class="display nowrap table table-striped table-bordered">
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Bottom Section End -->

	<!-- 주소 검색 모달 -->
	<div class="modal fade" id="addressModal" tabindex="-1"
		data-backdrop="static" role="dialog" aria-hidden="true"
		data-keyboard="false">
		<div
			class="modal-dialog modal-dialog-centered modal-dialog-scrollable"
			style="position: fixed; left: 50%; top: 50%; transform: translate(50%, -50%); width: 400px; max-width: 400px; z-index: 10550;">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title">주소 검색</h5>
					<button type="button" class="close" onclick="closeModal()">&times;</button>
				</div>
				<div class="modal-body" style="position: relative; z-index: 10600;">
					<div id="addressSearchResult" style="width: 100%; height: 400px;"></div>
				</div>
			</div>
		</div>
	</div>
</div>
<!--  -->
<!-- ============================================================== -->
<!-- modal form start -->
<!-- ============================================================== -->
<div class="modal fade" id="modalName" tabindex="-1"
	data-backdrop="static" role="dialog" aria-hidden="false"
	data-keyboard="false">
	<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable"
		role="dialog"
		style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 50vw; max-width: 50vw; height: auto; max-height: 90vh;">
		<div class="modal-content"
			style="height: auto; max-height: 90vh; display: flex; flex-direction: column;">
			<div class="modal-header bg-light">
				<h6 class="modal-title" id="modalHead"></h6>
				<!-- ============================================================== -->
				<!-- button start -->
				<!-- ============================================================== -->
				<div class="form-row">
					<div class="col-sm-12 mb-2" style="text-align: right;">
						<button id="form_btn_new" type="submit"
							class="btn btn-outline-dark btn-delete" onClick="fn_Potion()">
							센터. <i class="far fa-object-group"></i>
						</button>
						<button id="form_btn_ins" type="submit"
							class="btn btn-outline-info btn-insert" onClick="fn_Insert()">
							입력. <i class="far fa-edit"></i>
						</button>
						<button id="form_btn_udt" type="submit"
							class="btn btn-outline-success btn-update" onClick="fn_Update()">
							수정. <i class="far fa-save"></i>
						</button>
						<button id="form_btn_del" type="submit"
							class="btn btn-outline-danger btn-delete" onClick="fn_Delete()">
							삭제. <i class="far fa-trash-alt"></i>
						</button>
						<button type="button" class="btn btn-outline-dark"
							data-dismiss="modal" onClick="modalMainClose()">
							닫기 <i class="fas fa-times"></i>
						</button>
					</div>
				</div>
				<!-- ============================================================== -->
				<!-- end button -->
				<!-- ============================================================== -->
			</div>
			<div class="modal-body"
				style="text-align: left; flex: 1; overflow-y: auto;">

				<!-- ================================================================== -->
				<div id="inputZone">
						<!-- 회사(TBL_COMP_MST) 입력/수정 — COMP 스키마 -->
						<input type="hidden" id="compUuid" name="compUuid" value="">
						<input type="hidden" id="regUser"  name="regUser"  value="">
						<input type="hidden" id="updUser"  name="updUser"  value="">
						<input type="hidden" id="regIp"    name="regIp"    value="">
						<input type="hidden" id="updIp"    name="updIp"    value="">
						<input type="hidden" id="updDttm"  name="updDttm"  value="">
						<div class="form-group row">
							<label for="compCd" class="col-2 col-form-label text-left">회사코드</label>
							<div class="col-2"><input id="compCd" name="compCd" type="text" class="form-control text-left" required placeholder="회사코드"></div>
							<label for="joinDt" class="col-2 col-form-label text-left">가입일자</label>
							<div class="col-2"><input id="joinDt" name="joinDt" type="text" class="form-control date1-inputmask" placeholder="yyyy-mm-dd"></div>
							<label for="compCeo" class="col-2 col-form-label text-left">대표자</label>
							<div class="col-2"><input id="compCeo" name="compCeo" type="text" class="form-control text-left" placeholder="대표자명"></div>
						</div>
						<div class="form-group row">
							<label for="compNm" class="col-2 col-form-label text-left">회사명</label>
							<div class="col-6"><input id="compNm" name="compNm" type="text" class="form-control text-left" placeholder="회사명을 입력하세요"></div>
							<label for="commstYn" class="col-2 col-form-label text-left" style="color:#1976d2;">관리자여부</label>
							<div class="col-2">
								<select id="commstYn" name="commstYn" class="custom-select">
									<option value="Y">Y</option>
									<option value="N" selected>N</option>
								</select>
							</div>
						</div>
						<div class="form-group row">
							<label for="busiNum" class="col-2 col-form-label text-left">사업자번호</label>
							<div class="col-6"><input id="busiNum" name="busiNum" type="text" class="form-control text-left" placeholder="사업자번호"></div>
							<label for="useYn" class="col-2 col-form-label text-left">사용여부</label>
							<div class="col-2">
								<select id="useYn" name="useYn" class="custom-select">
									<option value="Y" selected>사용</option>
									<option value="N">미사용</option>
								</select>
							</div>
						</div>
						<div class="form-group row">
							<label for="zipCd" class="col-2 col-form-label text-left">우편번호</label>
							<div class="col-6">
								<div class="input-group">
									<input id="zipCd" name="zipCd" type="text" class="form-control text-left" placeholder="우편번호">
									<button class="btn btn-outline-info" type="button" onclick="openAddressSearch(event)"><i class="fas fa-search">검색</i></button>
								</div>
							</div>
							<label for="sthpnm" class="col-2 col-form-label text-left">표준기관명</label>
							<div class="col-2"><input id="sthpnm" name="sthpnm" type="text" class="form-control text-left" placeholder=""></div>
						</div>
						<div class="form-group row">
							<label for="compAddr" class="col-2 col-form-label text-left">주소</label>
							<div class="col-10"><input id="compAddr" name="compAddr" type="text" class="form-control text-left" placeholder="주소를 입력하세요"></div>
						</div>
						<div class="form-group row">
							<label for="compExtradr" class="col-2 col-form-label text-left">상세주소</label>
							<div class="col-10"><input id="compExtradr" name="compExtradr" type="text" class="form-control text-left" placeholder="상세주소를 입력하세요"></div>
						</div>
						<div class="form-group row">
							<label for="compTel" class="col-2 col-form-label text-left">연락처</label>
							<div class="col-2"><input id="compTel" name="compTel" type="text" class="form-control" placeholder="(02)-000-0000"></div>
							<label for="compFax" class="col-2 col-form-label text-left">Fax</label>
							<div class="col-2"><input id="compFax" name="compFax" type="text" class="form-control" placeholder="(02)-000-0000"></div>
							<label for="inaccd" class="col-2 col-form-label text-left">기관구분</label>
							<div class="col-2"><input id="inaccd" name="inaccd" type="text" class="form-control" placeholder=""></div>
						</div>
						<!-- 파일업로드 미사용(COMP) — 기존 JS(modal_Open/uploadForm/drag-area 등) 호환용 hidden 스텁 -->
						<form id="uploadForm" style="display:none;" onsubmit="return false;">
							<div class="btn-box"></div>
							<input type="file" id="file-input">
							<button type="button" id="fileSelectBtn"></button>
							<span id="file-name-display"></span>
							<div id="drag-area"><div id="file-list"></div></div>
						</form>
						<table id="fileTable" style="display:none;"></table>
					</div>

				<div class="modal-footer"></div>
			</div>
		</div>
	</div>
</div>
<!-- 계약관계등록관리 -->
<!-- 모달 -->
<div class="modal fade" id="hc_modalName" tabindex="-1"
	data-backdrop="static" role="dialog" aria-hidden="true"
	data-keyboard="false">
	<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable"
		role="dialog"
		style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 50vw; max-width: 50vw; height: auto; max-height: 90vh;">
		<div class="modal-content"
			style="height: auto; max-height: 90vh; display: flex; flex-direction: column;">
			<div class="modal-header bg-light">
				<h6 class="modal-title" id="hc_modalHead"></h6>
				<div class="form-row">
					<div class="col-sm-12 mb-2" style="text-align: right;">
						<button id="hc_form_btn_ins" type="submit"
							class="btn btn-outline-info btn-insert" onClick="hc_fn_Insert()">
							입력. <i class="far fa-edit"></i>
						</button>
						<button id="hc_form_btn_udt" type="submit"
							class="btn btn-outline-success btn-update" onClick="hc_fn_Update()">
							수정. <i class="far fa-save"></i>
						</button>
						<button id="hc_form_btn_del" type="submit"
							class="btn btn-outline-danger btn-delete" onClick="hc_fn_Delete()">
							삭제. <i class="far fa-trash-alt"></i>
						</button>
						<button type="button" class="btn btn-outline-dark"
							data-dismiss="modal" onClick="hc_modalClose()">
							닫기 <i class="fas fa-times"></i>
						</button>
					</div>
				</div>
			</div>
			<div class="modal-body"
				style="text-align: left; flex: 1; overflow-y: auto;">
				<div id="hc_inputZone">
						<!-- 계약(TBL_COMPCONT_MST) — COMP 스키마 (계약구분/OCS 제거) -->
						<input type="hidden" id="compCd_one"  name="compCd_one"  value="">
						<input type="hidden" id="regUser_one" name="regUser_one" value="">
						<input type="hidden" id="updUser_one" name="updUser_one" value="">
						<input type="hidden" id="regIp_one"   name="regIp_one"   value="">
						<input type="hidden" id="updIp_one"   name="updIp_one"   value="">
						<div class="form-group row">
							<label for="startDt_one" class="col-2 col-form-label text-left">시작일자</label>
							<div class="col-4"><input id="startDt_one" name="startDt_one" type="text" class="form-control date1-inputmask" required placeholder="yyyy-mm-dd"></div>
							<label for="endDt_one" class="col-2 col-form-label text-left">종료일자</label>
							<div class="col-4"><input id="endDt_one" name="endDt_one" type="text" class="form-control date1-inputmask" required placeholder="yyyy-mm-dd"></div>
						</div>
						<div class="form-group row">
							<label for="conContent_one" class="col-2 col-form-label text-left">세부내용</label>
							<div class="col-10"><input id="conContent_one" name="conContent_one" type="text" class="form-control text-left" placeholder="계약 세부내용을 입력하세요"></div>
						</div>
						<div class="form-group row">
							<label for="acceptDt_one" class="col-2 col-form-label text-left">승인일자</label>
							<div class="col-4"><input id="acceptDt_one" name="acceptDt_one" type="text" class="form-control date1-inputmask" placeholder="yyyy-mm-dd"></div>
							<label for="closeDt_one" class="col-2 col-form-label text-left">중지일자</label>
							<div class="col-4"><input id="closeDt_one" name="closeDt_one" type="text" class="form-control date1-inputmask" placeholder="yyyy-mm-dd"></div>
						</div>
						<div class="form-group row">
							<label for="useYn_one" class="col-2 col-form-label text-left">사용구분</label>
							<div class="col-4">
								<select id="useYn_one" name="useYn_one" class="custom-select">
									<option value="Y">Y</option>
									<option value="N" selected>N</option>
								</select>
							</div>
							<label for="conUserId_one" class="col-2 col-form-label text-left">계약담당</label>
							<div class="col-4"><input id="conUserId_one" name="conUserId_one" type="text" class="form-control" placeholder=""></div>
						</div>
						<div class="form-group row">
							<label for="conUserTel_one" class="col-2 col-form-label text-left">담당전화</label>
							<div class="col-4"><input id="conUserTel_one" name="conUserTel_one" type="text" class="form-control phone-inputmask" placeholder="(010)-0000-0000"></div>
							<label for="conEmail_one" class="col-2 col-form-label text-left">이메일</label>
							<div class="col-4"><input id="conEmail_one" name="conEmail_one" type="text" class="form-control" placeholder="aaa@bbb.com"></div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
		<!-- 계약관계등록관리끝  -->
<!-- 사용자등록시작 -->
<div class="modal fade" id="hu_modalName" tabindex="-1"
	data-backdrop="static" role="dialog" aria-hidden="true"
	data-keyboard="false">
	<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable"
		role="dialog"
		style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 50vw; max-width: 50vw; height: auto; max-height: 90vh;">
		<div class="modal-content"
			style="height: auto; max-height: 90vh; display: flex; flex-direction: column;">
			<div class="modal-header bg-light">
				<h5 class="modal-title" id="hu_modalHead"></h5>
				<div class="form-row">
					<div class="col-sm-12 mb-2" style="text-align: right;">
						<button id="hu_form_btn_ins" type="submit"
							class="btn btn-outline-info btn-insert" onClick="hu_fn_Insert()">
							입력. <i class="far fa-edit"></i>
						</button>
						<button id="hu_form_btn_udt" type="submit"
							class="btn btn-outline-success btn-update" onClick="hu_fn_Update()">
							수정. <i class="far fa-save"></i>
						</button>
						<button id="hu_form_btn_del" type="submit"
							class="btn btn-outline-danger btn-delete" onClick="hu_fn_Delete()">
							삭제. <i class="far fa-trash-alt"></i>
						</button>
						<button type="button" class="btn btn-outline-dark"
							data-dismiss="modal" onClick="hu_modalClose()">
							닫기 <i class="fas fa-times"></i>
						</button>
					</div>
				</div>
			</div>
			<div class="modal-body"
				style="text-align: left; flex: 1; overflow-y: auto;">
				<div id="hu_inputZone">
					<!-- ★ Chrome 자격증명 자동완성 방지: 더미 필드 (Chrome이 여기에 autofill → 실제 필드/검색창 무시) -->
					<div style="position:absolute; left:-9999px; opacity:0; height:0; overflow:hidden;" aria-hidden="true">
						<input type="text" tabindex="-1" autocomplete="username" name="fake_user_chrome">
						<input type="password" tabindex="-1" autocomplete="current-password" name="fake_pass_chrome">
					</div>
					<input type="hidden" id="hospUuid_two" name="hospUuid_two" value="">
					<input type="hidden" id="compCd_two"   name="compCd_two"   value="">
					<input type="hidden" id="passWd_two"   name="passWd_two"   value="">
					<input type="hidden" id="regUser_two"  name="regUser_two"  value="">
					<input type="hidden" id="updUser_two"  name="updUser_two"  value="">
					<input type="hidden" id="regIp_two"    name="regIpt_wo"    value="">
					<input type="hidden" id="updIp_two"    name="updIp_two"    value="">
					<input type="hidden" id="mainGuNm_two" name="mainGuNm_two" value="">
					<input type="hidden" name="dupchk" id="dupchk" value="X" />
					<div class="form-group row ">
						<div class="input-group">
							<label for="userId_two"
								class="col-2 col-lg-2 col-form-label text-left">사용아이디</label>
							<div class="col-4 col-lg-4">
								<input id="userId_two" name="userId_two" type="text"
									class="form-control text-left" placeholder="사용자아이디 입력하세요"
									autocomplete="off">
							</div>
							<button class="btn btn-outline-info" onclick="fnDupchk()">
								<i class="fas fa-search">중복</i>
							</button>
							<label for="startDt_two"
								class="col-2 col-lg-2 col-form-label text-left">시작일자</label>
							<div class="col-2 col-lg-2">
								<input id="startDt_two" name="startDt_two" type="text"
									class="form-control date1-inputmask" required
									placeholder="yyyy-mm-dd">
							</div>
						</div>
					</div>
					<div class="form-group row ">
						<label for="userNm_two"
							class="col-2 col-lg-2 col-form-label text-left">사용자성명</label>
						<div class="col-4 col-lg-4">
							<input id="userNm_two" name="userNm_two" type="text"
								class="form-control text-left" placeholder="사용자명을 입력하세요"
								autocomplete="off">
						</div>
						<label for="mainGu_two"
							class="col-2 col-lg-2 col-form-label text-left">사용자구분</label>
						<div class="col-4 col-lg-4">
							<select id="mainGu_two" name="mainGu_two" class="custom-select"
								oninput="findField(this)" style="height: 35px; font-size: 14px;">
								<option selected value="">구분 1</option>
							</select>
						</div>

					</div>
					<div class="form-group row ">
						<label for="userTel_two"
							class="col-2 col-lg-2 col-form-label text-left">담당전화</label>
						<div class="col-4 col-lg-4">
							<input id="userTel_two" name="userTel_two" type="text"
								class="form-control phone-inputmask"
								placeholder="(010)-0000-0000" maxlength="">
						</div>
						<label for="email_two"
							class="col-2 col-lg-2 col-form-label text-left">이메일주소</label>
						<div class="col-4 col-lg-4">
							<input id="email_two" name="email_two" type="text"
								class="form-control email-inputmask"
								placeholder="메일주소 예) aaa@bbb.com" maxlength="">
						</div>
					</div>
					<div class="form-group row ">
						<label for="endDt_two"
							class="col-2 col-lg-2 col-form-label text-left">종료일자</label>
						<div class="col-2 col-lg-2">
							<input id="endDt_two" name="endDt_two" type="text"
								class="form-control date1-inputmask" required
								placeholder="yyyy-mm-dd">
						</div>
						<label for="useYn_two"
							class="col-2 col-lg-2 col-form-label text-left">사용구분</label>
						<div class="col-2 col-lg-2">
							<select id="useYn_two" name="useYn_two" class="custom-select">
								<option value="Y">Y</option>
								<option value="N" selected>N</option>
							</select>
						</div>
						<label for="mbrJoin_two"
							class="col-2 col-lg-2 col-form-label text-left">회원가입여부</label>
						<div class="col-2 col-lg-2">
							<select id="mbrJoin_two" name="mbrJoin_two" class="custom-select">
								<option value="Y">Y</option>
								<option value="N" selected>N</option>
							</select>
						</div>
					</div>
					<div class="form-group row ">
						<label for="bfPassWd_two"
							class="col-2 col-lg-2 col-form-label text-left">비밀번호</label>
						<div class="col-4 col-lg-4">
							<input id="bfPassWd_two" name="bfPassWd_two" type="password"
								class="form-control text-left" placeholder=""
								autocomplete="new-password">
						</div>
						<label for="afPassWd_two"
							class="col-2 col-lg-2 col-form-label text-left">비밀번호확인</label>
						<div class="col-4 col-lg-4">
							<input id="afPassWd_two" name="afPassWd_two" type="password"
								class="form-control text-left" placeholder=""
								autocomplete="new-password">
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 사용자등록관리  -->
<!-- ============================================================== -->
<!-- modal form end -->
<!-- ============================================================== -->
<!-- ============================================================== -->
<!-- 기본 초기화 Start -->
<!-- ============================================================== -->
<script type="text/javascript">
		// 안해도 상관없음, 단 getElementById를 변경하면 꼭해야됨
		// Form마다 수정해야 될 부분 시작
		var tableName = document.getElementById('tableName');
		tableName.style.display = 'none';		
		var modalName = document.getElementById('modalName');
		var modalHead = document.getElementById('modalHead');
		modalHead.innerText = "...";
		var inputZone = document.getElementById('inputZone');
		// Form마다 수정해야 될 부분 종료
		
		// Form마다 조회 조건 변경 시작
		var findTxtln  = 0;    // 조회조건시 글자수 제한 / 0이면 제한 없음
		var firstflag  = false; // 첫음부터 Find하시려면 false를 주면됨
		var findValues = [];
		// 조회조건이 있으면 설정하면됨 / 조건 없으면 막으면 됨
		// 글자수조건 있는건 1개만 설정가능 chk: true 아니면 모두 flase
		// 조회조건은 필요한 만큼 추가사용 하면됨.
		findValues.push({ id: "findData", val: "",  chk: true  });
		//Form마다 조회 조건 변경 종료
		
		// 초기값 설정
		var mainFocus = 'findData'; // Main 화면 focus값 설정, Modal은 따로 Focus 맞춤
		var edit_Data = null;
		var dataTable = new DataTable();
		dataTable.clear();
		
		<!-- ============================================================== -->
		<!-- 공통코드 Setting Start -->
		<!-- ============================================================== -->
		var list_flag = ['Z'];     										// 대표코드, ['Z','X','Y'] 여러개 줄 수 있음
		//  list_code, select_id, firstnull는 갯수가 같아야함.
		var list_code = ['MAIN_GU'];          // 사용자구분만 사용 (CONACT_GB/HOS_GRD 제거 - COMP 미사용)
		var select_id = ['mainGu_two'];       // 사용자구분 Select
		var firstnull = ['N'];
		<!-- ============================================================== -->
		<!-- 공통코드 Setting End -->
		<!-- ============================================================== -->
		var format_convert = ['startDt','endDt','compTel' ,'acceptDt','joinDt','closeDt','compTel', 'compFax',
		                      'startDt_one','endDt_one','acceptDt_one','joinDt_one','closeDt_one','startDt_two','endDt_two'
			                 ] ; //날자에서 '-' '/' 제외설정   
		
		<!-- ============================================================== -->
		<!-- Table Setting Start -->
		<!-- ============================================================== -->
		var gridColums = [];
		var btm_Scroll = false;   		// scrollX 끔 → 표가 폭 100% 채움(우측 빈공간 제거)
		var auto_Width = false;   		// 열 너비 자동 계산 off → 컬럼이 폭에 맞게 분배
		var page_Hight = 300;// 650;    		// Page 길이보다 Data가 많으면 자동 scroll - scrollY
		var p_Collapse = false;  		// Page 길이까지 auto size - scrollCollapse
		
		var datWaiting = true;   		// Data 가져오는 동안 대기상태 Waiting 표시 여부
		var page_Navig = true;   		// 페이지 네비게이션 표시여부 
		var hd_Sorting = true;   		// Head 정렬(asc,desc) 표시여부
		var info_Count = true;   		// 총건수 대비 현재 건수 보기 표시여부 
		var searchShow = true;   		// 검색창 Show/Hide 표시여부
		var showButton = true;   		// Button (복사, 엑셀, 출력)) 표시여부
		var copyBtn_nm = '복사.';
		var copy_Title = 'Copy Title';		
		var excelBtnnm = '엑셀.';
		var excelTitle = 'Excel Title';
		var excelFName = "파일명_";		// Excel Download시 파일명
		var printBtnnm = '출력.';
		var printTitle = 'Print Title';
        
		var find_Enter = false;  		// 검색창 바로바로 찾기(false) / Enter후 찾기(true)
		var row_Select = true;   		// Page내 Data 선택시 선택 row 색상 표시
		
		var colPadding = '0.2px'   		// 행 높이 간격 설정
		var data_Count = [15 , 30, 50, 70, 100, 150, 200];  // Data 보기 설정
		var defaultCnt = 15;                      // Data Default 갯수
		
		
		//  DataTable Columns 정의, c_Head_Set, columnsSet갯수는 항상 같아야함.
		var c_Head_Set = [  '회사코드','회사명','가입일','대표자','사업자번호','사용여부','관리자여부','주소','등록일자'];

		var columnsSet = [  // data = SQL 별칭/ DTO 컬럼, name(keyXxx) = 수정/삭제 PK
	        				{ data: 'compCd',  visible: true, className: 'dt-body-center', width: '110px', name: 'keyCompCd', primaryKey: true },
	        				{ data: 'compNm',  visible: true, className: 'dt-body-left',   width: '260px' },
	        				{ data: 'joinDt',  visible: true, className: 'dt-body-center', width: '100px',
	                          	render: function(data, type, row) {
		            				if (type === 'display') { return getFormat(data,'d1'); }
		                			return data;
	            				}
	        				},
	        				{ data: 'compCeo', visible: true, className: 'dt-body-center', width: '100px' },
	        				{ data: 'busiNum', visible: true, className: 'dt-body-center', width: '120px' },
	        				{ data: 'useYn',   visible: true, className: 'dt-body-center', width: '70px' },
	        				{ data: 'commstYn', visible: true, className: 'dt-body-center', width: '90px',
	        				  render: function (data, type, row) {
	        			        if (type === 'display') {
	        			            return data === 'Y' ? '관리' : '제외';
	        			        }
	        			        return data;
	        			      }
	        				},
	        				{ data: 'compAddr', visible: true, className: 'dt-body-left',   width: '600px' },
	        				{ data: 'updDttm', visible: true, className: 'dt-body-center', width: '120px' }
					    ];
		
		var s_CheckBox = true;   		           	 // CheckBox 표시 여부
        var s_AutoNums = true;   		             // 자동순번 표시 여부
        
		// 초기 data Sort,  없으면 []
		var muiltSorts = [
							['compCd', 'asc' ]
        				 ];
        // Sort여부 표시를 일부만 할 때 개별 id, ** 전체 적용은 '_all'하면 됩니다. ** 전체 적용 안함은 []        				 
		var showSortNo = ['compCd','compNm'];                   
		// Columns 숨김 columnsSet -> visible로 대체함 hideColums 보다 먼제 처리됨 ( visible를 선언하지 않으면 hideColums컬럼 적용됨 )	
		var hideColums = [];             // 없으면 []; 일부 컬럼 숨길때
		var txt_Markln = 20;                       				 // 컬럼의 글자수가 설정값보다 크면, 다음은 ...로 표시함
		// 글자수 제한표시를 일부만 할 때 개별 id, ** 전체 적용은 '_all'하면 됩니다. ** 전체 적용 안함은 []
		var markColums = ['compNm'];
		var mousePoint = 'pointer';                				 // row 선택시 Mouse모양
		<!-- ============================================================== -->
		<!-- Table Setting End -->
		<!-- ============================================================== -->
		let dt_com = new DataTransfer();
		window.onload = function() { 
			find_Check();
		    comm_Check();
		};
		
		// find_data` 입력 필드에서 Enter 키 이벤트를 강제 실행하는 함수
		function triggerEnterKey() {
		    let findDataInput = document.getElementById("findData");
		    if (findDataInput) {
		        findDataInput.focus(); // 자동 포커스 설정
		        // 가짜 'Enter' 키 이벤트 생성하여 `findEnterKey()` 실행
		        let enterEvent = new KeyboardEvent("keyup", { key: "Enter" });
		        findDataInput.dispatchEvent(enterEvent);
		        console.log("🔍 Enter 키 자동 실행 완료!");
		    }
		}
	
		</script>
<!-- ============================================================== -->
<!-- 기본 초기화 End -->
<!-- ============================================================== -->

<!-- ============================================================== -->
<!-- 화면 Size변경 Start -->
<!-- ============================================================== -->
<script type="text/javascript">
		const fullscreenToggle = document.getElementById('fullscreenToggle');
		const fullscreenIcon   = document.getElementById('fullscreenIcon');
		
		fullscreenToggle.addEventListener('click', toggleFullscreen);
		
		function toggleFullscreen() {
			if (!document.fullscreenElement) {
				
				if (document.documentElement.requestFullscreen) {
				    document.documentElement.requestFullscreen();
				} else if (document.documentElement.webkitRequestFullscreen) {
				    document.documentElement.webkitRequestFullscreen();
				} else if (document.documentElement.msRequestFullscreen) {
				    document.documentElement.msRequestFullscreen();
				}
				fullscreenIcon.classList.replace('fa-expand', 'fa-compress');
			  
			} else {
				if (document.exitFullscreen) {
				    document.exitFullscreen();
				} else if (document.webkitExitFullscreen) {
				    document.webkitExitFullscreen();
				} else if (document.msExitFullscreen) {
				    document.msExitFullscreen();
				}
				fullscreenIcon.classList.replace('fa-compress', 'fa-expand');
			}
		}
		document.addEventListener('fullscreenchange', updateIcon);
		document.addEventListener('webkitfullscreenchange', updateIcon);
		document.addEventListener('msfullscreenchange', updateIcon);
		
		function updateIcon() {
		    if (document.fullscreenElement) {
		        fullscreenIcon.classList.replace('fa-expand', 'fa-compress');
		    } else {
		        fullscreenIcon.classList.replace('fa-compress', 'fa-expand');
		    }
		}
		//승인일종료일기준으로 사요일자 산정 시작일 종료일 입력할때 자동처리 (input 은 똑같이 작동)
		$(document).ready(function () {
		    $("#startDt_one, #endDt_one").inputmask("9999-99-99", { placeholder: "YYYY-MM-DD" });

		    $("#startDt_one").on("change", function () {
		        $("#acceptDt_one").val($(this).val());
		    });

		    $("#endDt_one").on("change", function () {
		        $("#closeDt_one").val($(this).val());
		    });
		});

		</script>
<!-- ============================================================== -->
<!-- 화면 Size변경 End -->
<!-- ============================================================== -->

<!-- ============================================================== -->
<!-- modal Form 띄우기 Start -->
<!-- ============================================================== -->
<script type="text/javascript">
		function modal_Open(flag) {
		    
			fileinput_clear() ;
		    
			let modal_OpenFlag = true;
			const insertButton = document.getElementById('form_btn_ins');
		    const updateButton = document.getElementById('form_btn_udt');
		    const deleteButton = document.getElementById('form_btn_del');

		    // Hide all
		    insertButton.style.display = 'none';
		    updateButton.style.display = 'none';
		    deleteButton.style.display = 'none';
		    if (flag == 'I') {
		        document.getElementById("file-input").disabled = true;
		        document.querySelector(".btn-box").style.display = "none";
		        document.getElementById("drag-area").style.pointerEvents = "none";
		        document.getElementById("drag-area").style.opacity = 0.5;
		    } else {
		        document.getElementById("file-input").disabled = false;
		        document.querySelector(".btn-box").style.display = "inline-block";
		        document.getElementById("drag-area").style.pointerEvents = "auto";  // 고친 부분
		        document.getElementById("drag-area").style.opacity = 1;
		    }
	
		    // Show button
		    switch (flag) {
		        case 'I': // Show Insert button
		            insertButton.style.display = 'inline-block';
		            modalHead.innerText  = "입력 모드입니다" ; 
		            break;
		        case 'U': // Show Update button
		            updateButton.style.display = 'inline-block';
		            modalHead.innerText  = "수정 모드입니다" ;
		            break;
		        case 'D': // Show Delete button
		            deleteButton.style.display = 'inline-block';
		            modalHead.innerText  = "삭제 모드입니다" ;
		            break;
		    }    
		    applyAuthControl(); //권한관리 (입력수정삭제 ) 모달뛰우기전 
		    formValClear(inputZone.id);
		    
			if (flag !== 'I'){ 
				// 수정.삭제 모드 (대상확인)
				if (edit_Data) {
					// Value Setting
					formValueSet(inputZone.id,edit_Data);
					
				} else {
					modal_OpenFlag = false;
					messageBox("1","<h5>작업 할 Data가 선택되지 않았습니다. !!</h5><p></p><br>",mainFocus,"","");			
					return null;
				}
			}
			
			showfileModal('1', 'C');	
			
			if (modal_OpenFlag) {
				// 모달을 드레그할 수 있도록 처리
			    // Make the DIV element draggable:	    
			    
				var element = document.querySelector('#' + modalName.id);
			    dragElement(element);
				//수정시 키는 readonly 
				modal_key_hidden(flag)
				
			    function dragElement(elmnt) {
			        var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
			        // 어디든 클릭하여 움직여도 가능 (.modal-content)
			        // 타이틀 클릭하여 움직여만 가능 (.modal-header)
			        // 필요시 변경하여 사용하면 됨
			        if (elmnt.querySelector('.modal-header')) {
			            elmnt.querySelector('.modal-header').onmousedown = dragMouseDown;
			        } else {
			            elmnt.onmousedown = dragMouseDown;
			        }
			        function dragMouseDown(e) {
			            e = e || window.event;
			            //e.preventDefault(); // 기본 동작 방지
			            pos3 = e.clientX;
			            pos4 = e.clientY;
			            document.onmouseup = closeDragElement;
			            document.onmousemove = elementDrag;
			        }
		
			        function elementDrag(e) {
			            e = e || window.event;
			            //e.preventDefault(); // 기본 동작 방지
			            pos1 = pos3 - e.clientX;
			            pos2 = pos4 - e.clientY;
			            pos3 = e.clientX;
			            pos4 = e.clientY;
			            elmnt.style.top  = (elmnt.offsetTop - pos2)  + "px";
			            elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
			        }
		
			        function closeDragElement() {
			            document.onmouseup = null;
			            document.onmousemove = null;
			        }
			    }
		
			    function centerModal() {
			        const modal = document.querySelector('#' + modalName.id);
			        modal.style.top  = "50%";
			        modal.style.left = "50%";
			        modal.style.transform = "translate(-50%, -50%)";
			    }
			    // 모달 띄울 때 항상 중앙에 위치
			    $("#" + modalName.id).on('show.bs.modal', function () {	    	
			        centerModal();
			        var firstFocus = $(this).find('input:first');
			        setTimeout(function () {
		     	        $("#" + firstFocus.attr('id')).focus();
			        }, 500); // 포커스 강제 설정
			    });
			    // 모달 창 크기가 변경될 때도 중앙에 유지
			    window.addEventListener('resize', centerModal);
			    // 모달 띄우기
			    $("#" + modalName.id).modal('show');   
			    
			    if (getCookie("s_userid")) {
			        inputZone.querySelector("[name='regUser']").value = getCookie("s_userid");
			        inputZone.querySelector("[name='updUser']").value = getCookie("s_userid");
			    }

			    if (getCookie("s_connip")) {
			        inputZone.querySelector("[name='regIp']").value = getCookie("s_connip");
			        inputZone.querySelector("[name='updIp']").value = getCookie("s_connip");
			    }  
			}
		}
		function fn_Potion() {
		    
			const modal = document.querySelector('#' + modalName.id);
		    modal.style.top  = "50%";
		    modal.style.left = "50%";
		    modal.style.transform = "translate(-50%, -50%)";    
		}
		</script>
<!-- ============================================================== -->
<!-- modal Form 띄우기 End -->
<!-- ============================================================== -->

<!-- ============================================================== -->
<!-- DataTable 설정 Start -->
<!-- ============================================================== -->
<script type="text/javascript">
		function fn_FirstGridSet() {
			(function($) {
				 dataTable = $('#' + tableName.id).DataTable({	
						language : {
		 					search: "자 료 검 색 : ",
						    emptyTable: "데이터가 없습니다.",
						    lengthMenu: "_MENU_",
						    info: "현재 _START_ - _END_ / 총 _TOTAL_건",
						    infoEmpty: "데이터 없음",
						    infoFiltered: "( _MAX_건의 데이터에서 필터링됨 )",
						    loadingRecords: "대기중...",
						    processing: "잠시만 기다려 주세요...",
						    paginate: {"next": "다음", "previous": "이전"},
						},
						scrollX:        btm_Scroll,
						autoWidth:      auto_Width,				
					    scrollY:        page_Hight, 
					    scrollCollapse: p_Collapse,
					    select:         row_Select,					    
					    processing:     datWaiting,
					    paging:         page_Navig,
					    ordering:       hd_Sorting,					    
					    info:           info_Count,					    
		    			searching:      searchShow,
		    			search: {
		    	            return:     find_Enter,          	            
		    	        },		    	        
					    rowCallback: function(row, data, index) {
				            $(row).find('td').css('padding',colPadding); 
				        },				        
				        lengthMenu: [data_Count, data_Count],
				        pageLength: defaultCnt, 
					     // 페이지와 버튼 간격 넓히기      
						//	 dom: showButton   ? '<"row"<"col-sm-2"l><"col-sm-2"B><"col-sm-5"><"col-sm-3"f>>t<"row mt-2"<"col-sm-7"i><"col-sm-5"p>>'
						//	                   : '<"row"<"col-sm-2"l><"col-sm-7"><"col-sm-3"f>>t<"row mt-2"<"col-sm-7"i><"col-sm-5"p>>',

						// 페이지와 버튼 간격 좁히기 
					    dom: showButton  
					        ? '<"datatable-controls d-flex align-items-center justify-content-between"<"d-flex"<"mr-2"l><"mr-2"B><"ml-auto"f>>>' +
					          't' +
					          '<"row mt-2"<"col-sm-7"i><"col-sm-5"p>>'
					        : '<"datatable-controls d-flex align-items-center justify-content-between"<"d-flex"<"mr-2"l><"ml-auto"f>>>' +
					          't' +
					          '<"row mt-2"<"col-sm-7"i><"col-sm-5"p>>',
                        //
						     buttons: showButton
				             ? [
				            	{
				        		    extend: 'copy',
				        		    text:  copyBtn_nm,
				        		    title: copy_Title
				        		},
				        		{
				        			extend: 'excelHtml5',
				        		    text: excelBtnnm,
				        		    filename: function() {
				        		        var d = new Date();
				        		        var formattedDate = d.getFullYear() + 
				        		                            ('0' + (d.getMonth() + 1)).slice(-2) + 
				        		                            ('0' + d.getDate()).slice(-2) + '_' +
				        		                            ('0' + d.getHours()).slice(-2) + 
				        		                            ('0' + d.getMinutes()).slice(-2) + 
				        		                            ('0' + d.getSeconds()).slice(-2);
				        		        return excelFName + formattedDate;
				        		    },
				        		    title: excelTitle
				        		},  
				        		{
				        			extend: 'print',
				        			text: printBtnnm,
				        		    autoPrint: true,
				        		    title: printTitle,
				        		    customize: function(win) {
				        		        $(win.document.body).find('h1').text(printTitle);
				        		        $(win.document.body).css('font-size', '10pt');
				        		        $(win.document.body).find('table')
				        		            .addClass('compact')
				        		            .css('font-size', 'inherit');
				        		    }
				        		}]
				             : []
				        ,
			    		columns: gridColums,
				        order: muiltSorts,
					    columnDefs: [
					    	// 특정 열만 정렬
					    	{ 
					    		orderable: true,  
					    		targets: showSortNo 
					    	},					    	
					    	// 모든 나머지 열 정렬 불가능 설정
				            {
				                orderable: false,
				                targets: '_all'
				            },				            
				         	// column 숨김
				            { 
				            	visible: false, 
				            	targets: hideColums 
				            },
					        {
				            	targets: markColums,
					            render: function(data, type, row) {
					                return type === 'display' && data.length > txt_Markln ?
					                data.substr(0, txt_Markln) + '...' : data;
					            }
					        },				            
					        {
					            targets: ['_all'], 
					            createdCell: function (td, cellData, rowData, row, col) {
					                $(td).css('cursor', mousePoint);
					            }
					        }
					    ],
					    
					    ajax: dataLoad,
					});
				// 브라우저 자동완성 방지: DataTables 검색 input 초기화
				// (근본 원인: 비밀번호 필드 때문에 Chrome 자격증명 매니저가 검색창을 username으로 인식)
				// → 비밀번호 필드에 autocomplete="new-password" + 더미 필드로 해결
				$('.dataTables_filter input').attr('autocomplete', 'off').val('');
				dataTable.search('').draw();

				// 안내 메시지를 자료검색 입력란 우측에 나란히 배치
				$('#hospContractMsg').insertAfter('#' + tableName.id + '_filter');

				// 전체 선택 체크박스 기능
			    $('#selectAll').on('click', function() {
			        var rows = dataTable.rows({ 'search': 'applied' }).nodes();
			        $('input[type="checkbox"]', rows).prop('checked', this.checked);
			    });
		
				
			    // 개별 체크박스 변경 시 전체 선택 체크박스 상태 업데이트
			    $('#' + tableName.id + ' tbody').on('change', 'input[type="checkbox"]', function() {
			        var allChecked = ($('input[type="checkbox"]:checked', dataTable.rows().nodes()).length === dataTable.rows().count());
			        $('#selectAll').prop('checked', allChecked);
			    });
			    
			    
			    // 입력 버튼 클릭 이벤트
			    $('#' + tableName.id + ' tbody').on('click', '.ins-btn', function() {
			        // 여기에 입력 로직을 구현하세요
			        
			    });
			    // 수정 버튼 클릭 이벤트
			    $('#' + tableName.id + ' tbody').on('click', '.upt-btn', function() {
			        var data = dataTable.row($(this).parents('tr')).data();
			        // 여기에 수정 로직을 구현하세요
			    });
		
			    // 삭제 버튼 클릭 이벤트
			    $('#' + tableName.id + ' tbody').on('click', '.del-btn', function() {
			    	
			    	var data = dataTable.row($(this).parents('tr')).data();
			    	
			    	messageBox("9","<h5>정말로 삭제하시겠습니까 ? 요양기관코드 : " + data.compCd + " 입니다. </h5><p></p><br>",mainFocus,"","");
			    	confirmYes.addEventListener('click', () => {
			    		// Yes후 여기서 처리할 로직 구현
			    		
			    		// grid data 삭제
			    		dataTable.row($(this).parents('tr')).remove().draw();    		 
			    		messageDialog.hide();
			    		
			        });
			    });
			    
			    // 컬럼 Click과 CheckBox를 이벤트 동작이 동시에 일어나 분리함  
			    dataTable.on('click', 'td', function(e) {
			    	var column = $(this).index();        
			        var $row = $(this).closest('tr');
			        var $checkbox = $row.find('input[type="checkbox"]');
			        
			        // 체크박스가 아닌 다른 부분을 클릭했을 때 방지하기 위해 column순번 넣음
			        if ((!$(e.target).is(':checkbox')) & column === 0) {
			            e.preventDefault();         // 기본 동작 방지
			            $checkbox.trigger('click'); // 체크박스 클릭 이벤트 트리거
			        }
			    });
			    // 체크박스 클릭 이벤트
			    dataTable.on('change', 'input[type="checkbox"]', function(e) {
			        e.stopPropagation(); // 이벤트 전파 중지
			        var $row = $(this).closest('tr');
			    });
			    
			    /* row data선택 후 value set start */
			    dataTable.on('click', 'tbody tr', function() {
				    edit_Data = dataTable.row(this).data();
				});	    
			    /* 싱글 선택 start */
			    if (row_Select) {
				    dataTable.on('click', 'tbody tr', (e) => {
				  	    let classList = e.currentTarget.classList;
				  	 
				  	    if (!classList.contains('selected')) {
				  	    	dataTable.rows('.selected').nodes().each((row) => row.classList.remove('selected'));
				  	        classList.add('selected');
				  	    } 
				  	});    
			    }
				//더블클릭시 수정모드  
			    $('#' + tableName.id + ' tbody').on('dblclick', 'tr', function () {
			        let table = $('#' + tableName.id).DataTable();
			        let rowData = table.row(this).data(); // 해당 행 데이터 가져오기
			        modal_Open('U', rowData);
			    });	
			    
			    /* 선택 Data 삭제 확인 */  
			    //document.querySelector('#button').addEventListener('click', function () {
			    //    table.row('.selected').remove().draw(false);
			    //});  
			    /* 싱글 선택 end */
			    
			    /* 멀티 선택 start */
			    //table.on('click', 'tbody tr', function (e) {
			   	//	e.currentTarget.classList.toggle('selected');
				//});
			    /* 선택 Data 건수 확인 */   
			    //document.querySelector('#button').addEventListener('click', function () {
			    //    alert(table.rows('.selected').data().length + ' row(s) selected');
			    //});
			    /* 멀티 선택 end */
 
	    
			})(jQuery);
		}	   
		
		//ajax 함수 정의
		function dataLoad(data, callback, settings) {
		
			// var table = $(settings.nTable).DataTable();
		    // table.processing(true); // 처리 중 상태 시작
				
		    let find = {};
		   	
		   	for (let findValue of findValues) {
		   		let key = findValue.id === "fee_type1" ? "fee_type" : findValue.id;
		   		find[key] = findValue.val;
		   	}
		   	
		    $.ajax({
		        type: "POST",
		        url: ctx + "/user/compCdList.do",
		        data: find,
		        dataType: "json",
		        
		        // timeout: 10000, // 10초 후 타임아웃
		        beforeSend : function () {
		        	
				},
		        success: function(response) {
		        	// table.processing(false); // 처리 중 상태 종료
		            if (response && Object.keys(response).length > 0) {
		            	callback(response);
		            } else {
		            	callback([]); // 빈 배열을 콜백으로 전달
		            }
		        },
		        error: function(jqXHR, textStatus, errorThrown) {
		        	// table.processing(false); // 처리 중 상태 종료		                    
		            callback({
		                data: []
		            });
		            // table.clear().draw(); // 테이블 초기화 및 다시 그리기
		        }
		    });
		    
		    
		}
		
		
		// DataTable에 자료 담기 Start	   
		function fn_FindData() {
			hctmpedit_Data = null;
			hutmpedit_Data = null;
			// 조회조건이 있을 경우	
			if (findValues && findValues.length > 0) {
				
				// 조회조건시 문자 길이가 있을 경우
				if (findTxtln > 0) {
						
					const foundItem = findValues.find(item => item.chk === true);
		
					if (foundItem !== undefined) {
						
						const index = findValues.findIndex(item => item.id === foundItem.id);
						
					    let { kCount, eCount, nCount, tCount } = getLengthCounts(findValues[index].val);
						
					    if (tCount >= findTxtln) {
			                fn_FindDataTable(); 	
						} else {
							messageBox("4","조회시 " + findTxtln + "글자 이상 " + getCodeMessage("A001"),findValues[index].id,"","");
						}
					    
					} else {
					    
					    messageBox("4","글자수 " + findTxtln + "글자 이상 조건이 있지만 조회 객체에는 true설정 안됨 !!","","","");			    
					}
					
				} else {
					fn_FindDataTable();
				}
			} else {
				fn_FindDataTable();
			}
			
		}
		
		function fn_FindDataTable() {
			if (firstflag) {
				firstflag = false;
				tableName.style.display = 'inline-block';
				fn_FirstGridSet();	
			} else {
				dataTable.ajax.reload();
			}
			edit_Data = null;
			// 재조회시 전체 선택 체크박스 해제
			$("#selectAll").prop("checked", false);
		}
		
		function fn_re_load(){
			if (findValues && findValues.length > 0) {
				fn_FindData();
			} 
		}
		//DataTable에 자료 담기 End
		</script>
<!-- ============================================================== -->
<!-- DataTable 설정 End -->
<!-- ============================================================== -->

<!-- ============================================================== -->
<!-- 입력, 수정, 삭제 Start -->
<!-- ============================================================== -->
<script type="text/javascript">
		//Modal Form에서 입력
		//일력값 오류체크및 서버데이타전달(json) 
		function validateForm() {
		    const results = formValCheck(inputZone.id, {
		    	compCd:      { kname: "회사코드" , k_min: 3, k_max: 10, k_req: true, k_spc: true, k_clr: true },
		    	compNm:      { kname: "회사명"  , k_req: true },
		    	joinDt:      { kname: "가입일자" },
		    	compCeo:     { kname: "대표자" },
		    	busiNum:     { kname: "사업자번호" },
		    	zipCd:       { kname: "우편번호"} ,
		    	compAddr:    { kname: "주소" },
		    	compExtradr: { kname: "상세주소"},
		    	compTel:     { kname: "연락처" },
		    	compFax:     { kname: "Fax"   }
		    });
		    return results;
		}
		//그리드상 데이타생성및 수정 작업
		function newuptData() {
        	let newData = {
        		compCd:      $('#compCd').val(),
        		compNm:      $('#compNm').val(),
        		joinDt:      $('#joinDt').val(),
        		compCeo:     $('#compCeo').val(),
        		busiNum:     $('#busiNum').val(),
        		useYn:       $('#useYn').val(),
        		commstYn:    $('#commstYn').val(),
        		updDttm:     $('#updDttm').val()
			    };
		    return newData;
		}	
		function fn_Insert(){
			// 1. form (input, select, textarea Element 및 Value 확인
			// key는 (반드시 Field id로 넣어야 됨) !!!!!!!!!!!!!!!!!!!!!!			
			// { 
			//   kname(Message 처리시 재정의된 kname로 표시됨),  
			//	 k_len(자리수),      k_min(최소자릿수), k_max(최대자리수), 
			//	 k_req(반드시입력확인), k_num(숫자만입력), k_spc(공백확인), k_clr(입력값Clear), 
			//   k_chr(제거문자)
			// };
			const results = validateForm();
			if (results)
			{
				let dats = [];
				let data = {};
		        results.forEach(result => {
		        	if (format_convert.length > 0) {
		        		if (format_convert.includes(result.id)) {
				            data[result.id] = replaceMulti(result.val,'-','/');		        		
			        	}else{
			        		data[result.id] = result.val;
			        	}
		        	}else{
		        		data[result.id] = result.val;
		        	}	
		        });
				
		        dats.push(data);	    
			    $.ajax({
			            type: "POST",
			            url: ctx + "/user/compCdInsert.do",
			            data: JSON.stringify(dats),
			            contentType: "application/json",
			    	    dataType: "json",
			            success: function(response) {
			            	// checkbox, 자동순번은 넣지 않습니다.
			            	// *******단, 나머지 컬럼은 반드시 기술해야 합니다. 
			            	let newData = newuptData();
	
			            	dataTable.row.add(newData).draw(false);
			            	
			            	messageBox("1","<h5> 정상처리 되었습니다 ...... </h5><p></p><br>",mainFocus,"","");	            	
			            	$("#" + modalName.id).modal('hide');
			            	
			        	},
			        	error: function(xhr, status, error) {
				         	switch (xhr.status){  
				         	     case 500: messageBox("5","<h5>서버에 문제가 발생했습니다.</h5>" +  
			                               "<h6>잠시후 다시, 시도해주십시요. !!</h6>",mainFocus,"","");
				        		    break;
				         	     case 400:
				        		    messageBox("5","<h5>기존자료가 존재합니다.</h5>" +  
			                               "<h6>다시 확인하고, 시도해주십시요. !!</h6>",mainFocus,"","");
				        		    break;
				        		 defalut:  
				                     messageBox("5", "<h5>알 수 없는 오류가 발생했습니다.</h5>" +  
			                                   "<h6>관리자에게 문의하세요.</h6>", mainFocus, "", "");
			                        break;
				        		end    
				           	}
			        	}	
			    });
			}
		}
		// Modal Form에서 수정
		function fn_Update() {
		    // 1. 입력값 검증 및 유효성 검사
            const results = validateForm();
		    if (results) {
		        // 2. 데이터 수집
		        let data = {};
		        results.forEach(result => {
		        	if (format_convert.length > 0) {
		        		if (format_convert.includes(result.id)) {
				            data[result.id] = replaceMulti(result.val,'-','/');		        		
			        	}else{
			        		data[result.id] = result.val;
			        	}
		        	}else{
		        		data[result.id] = result.val;
		        	}	
  	
		        });
		
		        // 3. 선택된 행의 Primary Key 가져오기
		        var selectedRows = dataTable.rows('.selected');
		        let keys = dataTableKeys(dataTable, selectedRows);
		
		        // 4. Primary Key와 입력 데이터 병합 (배열로 만들어 서버에 전송)
		        let mergeData = keys.map(key => ({ ...data, ...key }));
		        // 5. AJAX로 서버 업데이트 요청
		        $.ajax({
		            type: "POST",
		            url: ctx + "/user/compCdUpdate.do",
		            data: JSON.stringify(mergeData), // JSON 변환
		            contentType: "application/json",
		            dataType: "json",
		            success: function(response) {
		                console.log("업데이트 성공", response);
		                // 6. DataTable에 변경된 값 반영
		                let updatedData = newuptData();		                

		                selectedRows.every(function(rowIdx) {
		                    let rowData = this.data();
		                    Object.keys(updatedData).forEach(function(key) {
		                    	rowData[key] = updatedData[key];
		                    });
		                    this.data(rowData);
		                });
		
		                dataTable.draw(false);
		                
		                // 7. 모달 닫기 및 성공 메시지 표시
		                $("#" + modalName.id).modal('hide');
		                messageBox("1", "<h5> 정상적으로 업데이트되었습니다. </h5>", mainFocus, "", "");
		            },
		            error: function(xhr, status, error) {
		                console.error("업데이트 실패", xhr.responseText);
		                messageBox("5", "<h5>서버에 문제가 발생했습니다.</h5><h6>잠시 후 다시 시도해주세요.</h6>", mainFocus, "", "");
		            }
		        });
		    }
		}

		// Modal Form에서 삭제
		function fn_Delete(){
			let isKey = false;
			// success:  성공 또는 완료를 나타내는 녹색 체크 마크 아이콘
			// error:    오류나 실패를 나타내는 빨간색 X 아이콘
			// warning:  주의나 경고를 나타내는 노란색 느낌표 아이콘
			// info:     정보를 나타내는 파란색 i 아이콘
			// question: 질문이나 확인을 나타내는 파란색 물음표 아이콘	
			Swal.fire({title:'삭제여부',text:'정말 삭제 하시겠습니까 ?', icon:'question' ,
					   showCancelButton:true,confirmButtonText:'예',cancelButtonText:'아니오',
					   customClass: {
						   popup: 'small-swal'}
			     }).then((result) => {
				// 사용자가 '예' 버튼을 클릭한 경우
				let data = {};
				if (result.isConfirmed) {
					// (수정.삭제 primaryKey로 조회)			
				    // primaryKey로 설정된 컬럼 찾기 
				    var selectedRows = dataTable.rows('.selected');
					let keys = dataTableKeys(dataTable, selectedRows);
					if (keys.length > 0) {	        	
						$.ajax({
				            type: "POST",
				            url: ctx + "/user/compCdDelete.do",
				    	    data: JSON.stringify(keys),	    	    
				    	    contentType: "application/json",
				    	    dataType: "json",
				            success: function(response) {
				            	Swal.fire({
						            title: '처리확인',
						            text:  '정상처리 되었습니다. ',
						            icon:  'success',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false,
						            customClass: {
										   popup: 'small-swal'}
						        });
							    // 선택된 행 삭제
							    selectedRows.remove().draw();
							    // 삭제 후 선택 초기화
							    selectedRow = null; 
							    $("#" + modalName.id).modal('hide');
		
				        	},
				        	error: function(xhr, status, error) {
				        		Swal.fire({
						            title: '에러확인',
						            text:  '문제 발생, 잠시후 다시 하십시요.',
						            icon:  'error',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false,
						            customClass: {
										   popup: 'small-swal'}
						        });
				        	}
					    });
							
					} else {
						Swal.fire({
				            title: '오류확인',
				            text:  '삭제 Key가 존재하지 않습니다. ',
				            icon:  'warning',
				            confirmButtonText: '확인',
				            timer: 1500, // 1.5초후 없어짐
				            timerProgressBar: true,
				            showConfirmButton: false ,
				            customClass: {
								   popup: 'small-swal'}
				        });
					}
				
				} else if (result.isDismissed) {
					Swal.fire({
			            title: '취소확인',
			            text:  '작업이 취소 되었습니다. ',
			            icon:  'info',
			            confirmButtonText: '확인',
			            timer: 1000, // 1.5초후 없어짐
			            timerProgressBar: true,
			            showConfirmButton: false ,
			            customClass: {
							   popup: 'small-swal'}
			        });
				}
			});
		}
		// Check된 자료 찾아 삭제
		function fn_findchk(){
			let isKey = false; 	    
		 	// success:  성공 또는 완료를 나타내는 녹색 체크 마크 아이콘
			// error:    오류나 실패를 나타내는 빨간색 X 아이콘
			// warning:  주의나 경고를 나타내는 노란색 느낌표 아이콘
			// info:     정보를 나타내는 파란색 i 아이콘
			// question: 질문이나 확인을 나타내는 파란색 물음표 아이콘	
			Swal.fire({title:'삭제여부',text:'정말 삭제 하시겠습니까 ?', 
				       icon:'question' ,
					   showCancelButton:true,confirmButtonText:'예',cancelButtonText:'아니오',
					   customClass: {
						   popup: 'small-swal'}
			          }).then((result) => {

               	  // 사용자가 '예' 버튼을 클릭한 경우
				if (result.isConfirmed) {
					// 체크박스가 ':checked'인 행만 선택
					let selectedRows = dataTable.rows(function (idx, data, node) {
					    let $row = $(node); // 현재 행의 DOM 노드
					    let $checkbox = $row.find('input[type="checkbox"]'); // 체크박스 찾기
					    return $checkbox.is(':checked'); // 체크된 행만 필터링
					});
					
					let keys = dataTableKeys(dataTable, selectedRows);
					
			        if (keys.length > 0) {
						$.ajax({
				            type: "POST",
				            url: ctx + "/user/compCdDelete.do",		    	    
				    	    data: JSON.stringify(keys),	    	    
				    	    contentType: "application/json",
				    	    dataType: "json",
				            success: function(response) {
				            	Swal.fire({
						            title: '처리확인',
						            text:  '정상처리 되었습니다. ',
						            icon:  'success',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false ,
						            customClass: {
										   popup: 'small-swal'}
						        });
				            	// 선택된 행 삭제
							    selectedRows.remove().draw();
							    // 삭제 후 선택 초기화
							    selectedRow = null; 
				        	},
				        	error: function(xhr, status, error) {
				        		Swal.fire({
						            title: '에러확인',
						            text:  '문제 발생, 잠시후 다시 하십시요.',
						            icon:  'error',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false ,
						            customClass: {
										   popup: 'small-swal'}
						        });
				        	}
					    });
							
					} else {
						
						Swal.fire({
				            title: '오류확인',
				            text:  '삭제 Key가 존재하지 않습니다. ',
				            icon:  'warning',
				            confirmButtonText: '확인',
				            timer: 1500, // 1.5초후 없어짐
				            timerProgressBar: true,
				            showConfirmButton: false ,
				            customClass: {
								   popup: 'small-swal'}
				        });
					}
			        
			          
				
				
				} else if (result.isDismissed) {
					Swal.fire({
			            title: '취소확인',
			            text:  '작업이 취소 되었습니다. ',
			            icon:  'info',
			            confirmButtonText: '확인',
			            timer: 1500, // 1.5초후 없어짐
			            timerProgressBar: true,
			            showConfirmButton: false ,
			            customClass: {
							   popup: 'small-swal'}
			        });
				}
			});
		}
		</script>
<!-- ============================================================== -->
<!-- 입력, 수정, 삭제 End -->
<!-- ============================================================== -->

<!-- ============================================================== -->
<!-- 기타 정보 Start -->
<!-- ============================================================== -->
<script type="text/javascript">
		// key Setting
		function dataTableKeys(dataTable, selectedRows) {
			// 데이터 객체 초기화
			let  keysID = []; 
			if (selectedRows.count() > 0) {
			    // 선택된 행의 데이터 가져오기
			    selectedRows.every(function(rowIdx, tableLoop, rowLoop) {
			        var rowData = this.data(); // 현재 행의 데이터 가져오기
			        let  key_ID = {};
			        // rowData가 배열이 아니라 객체 형태일 경우
			        if (rowData && typeof rowData === "object") {
			        	// primaryKey로 설정된 컬럼 찾기
				        dataTable.settings()[0].aoColumns.forEach(function(column, index) {
				            if (column.primaryKey) {
				            	// primaryKey로 name으로 id 설정
				            	key_ID[column.name] = rowData[column.data]; 
				            }	
				        });
		
				        // 객체를 배열에 추가
				        keysID.push(key_ID);
			        } 
			    });
			}
			return keysID;
		}
		
		// 첫조회 확인
		function find_Check() {
			if (!firstflag){
				
				if (findTxtln > 0) {
					
					const foundItem = findValues.find(item => item.chk === true);
		
					if (foundItem !== undefined) {
						
						const index = findValues.findIndex(item => item.id === foundItem.id);
						
					    let { kCount, eCount, nCount, tCount } = getLengthCounts(findValues[index].val);
						
					    if (tCount >= findTxtln) {
					    	tableName.style.display = 'inline-block';
							fn_FirstGridSet();	
						} else {
							firstflag = true;
							messageBox("4","조회시 " + findTxtln + "글자 이상 " + getCodeMessage("A001"),findValues[index].id,"","");
						}
					    
					} else {
						firstflag = true;
					    messageBox("4","글자수 " + findTxtln + "글자 이상 조건이 있지만 조회 객체에는 true설정 안됨 !!",mainFocus,"","");			    
					}
					
				} else {
					tableName.style.display = 'inline-block';
					fn_FirstGridSet();
				}
		    }	
			$("#" + mainFocus).focus();
		}
		// 공통담기
		function comm_Check() {			
			if (list_code.length > 0) {
				$.ajax({
				    type: "POST",
				    url: ctx + "/base/commList.do",    
				    data: {
				        listGb: list_flag,
				        listCd: list_code
				    },
				    dataType: "json",
				 	
				    beforeSend : function () {
				    	
					},
				    success: function(response) {
				   	
				        const commList = response.data || [];
				        
				        for (var i = 0; i < select_id.length; i++) {
				            
				        	let select = $('#' + select_id[i]);
				            select.empty();
				            
				            let filteredItems = commList.filter(item => item.codeCd === list_code[i]);
				            
				            if (filteredItems.length > 0) {
				            	if (firstnull[i] === "Y")
				            		select.append('<option value=""></option>');
				            		
				            	filteredItems.forEach(function (item) {
				                    select.append('<option value=' + item.subCode + '>' + item.subCodeNm + '</option>');
				                });
				            } else {
				                select.append('<option value="">No options</option>');
				            }
				        }
				    },
				    error: function(jqXHR, textStatus, errorThrown) {
				    	console.error("Status:   " + jqXHR.status);
				        console.error("Response: " + jqXHR.responseText);
				    }
				});
			}
		}
			
		
		//mask 설정
		$(function(e) {
		    "use strict";
		    $(".date1-inputmask").inputmask("9999-99-99"),
		    // 전화번호 마스크 (서울, 휴대폰, 지역번호 등 대응)
		    $(".phone-inputmask").inputmask({
		        mask: [
		            "02-####-####",
		            "010-####-####",
		            "011-####-####",
		            "016-####-####",
		            "017-####-####",
		            "018-####-####",
		            "019-####-####",
		            "070-####-####",
		            "03##-###-####", // 3자리 지역번호
		            "03##-####-####" // 4자리 국번
		        ],
		        greedy: false,
		        clearIncomplete: true,
		        placeholder: "",
		        definitions: {
		            "#": {
		                validator: "[0-9]",
		                cardinality: 1
		            }
		        }
		    });
		    $(".email-inputmask").inputmask({
		        mask: "*{1,20}[.*{1,20}][.*{1,20}][.*{1,20}]@*{1,20}[*{2,6}][*{1,2}].*{1,}[.*{2,6}][.*{1,2}]",
		        greedy: !1,
		        onBeforePaste: function(n, a) {
		            return (e = e.toLowerCase()).replace("mailto:", "")
		        },
		        definitions: {
		            "*": {
		                validator: "[0-9A-Za-z!#$%&'*+/=?^_`{|}~/-]",
		                cardinality: 1,
		                casing: "lower"
		            }
		        }
		    })
		    
		});
		
		// modal EnterKey 
		document.addEventListener('DOMContentLoaded', () => {
			inputEnterFocus(inputZone.id);
		});
		
		
		// Table Heads 정리하기
        if (c_Head_Set.length > 0) {
        	
        	const thead = document.createElement('thead');
       	    thead.id = 'tableHead';

       	    const tr = document.createElement('tr');

       	    // 체크박스 열 추가
       	    if (s_CheckBox) {
       	        const th = document.createElement('th');
       	        th.innerHTML = '<input type="checkbox" id="selectAll">';
       	        tr.appendChild(th);
       	    }

       	    // 자동 번호 열 추가
       	    if (s_AutoNums) {
       	        const th = document.createElement('th');
       	        th.textContent = 'No';
       	        tr.appendChild(th);
       	    }

       	    // 헤더 배열을 순회하며 <th> 추가
       	    c_Head_Set.forEach(header => {
       	        const th = document.createElement('th');
       	        th.textContent = header; // 텍스트만 추가
       	        tr.appendChild(th);
       	    });

	       	thead.appendChild(tr);
	       	    
       	    // 기존 thead가 있으면 대체하고 없으면 새로 추가
       	    const existingThead = tableName.querySelector('thead');
       	    if (existingThead) {
       	    	tableName.removeChild(existingThead);
       	    }
       	    tableName.insertBefore(thead, tableName.firstChild);
        }
		// Table Columns 정리하기
        if (columnsSet.length > 0) {
        	gridColums = [];
        	let setnum = 0;
        	if (s_CheckBox) {
	   			gridColums.push({ data: null, orderable: false, searchable: false, className: 'select-checkbox dt-body-center',
	               	render: function (data, type, full, meta) {
	                   	return '<input type="checkbox" name="id[]" value="' + $('<div/>').text(data.id).html() + '">';
	               	}
	           	});
	   			setnum++;
       	 	}
        	if (s_AutoNums) {
        		gridColums.push({ data: null, orderable: false, searchable: false, className: 'dt-body-center',
                    render: function (data, type, row, meta) {
                        return meta.row + 1; // 자동순번: 현재 행 번호
                    }
                });
        		setnum++;
            }
        	let mark_Colnm = []; 
        	let show_Sorts = [];
        	let hide_Colnm = [];
        	let muilt_Sort = [];
        	for (let i = 0; i < columnsSet.length; i++) {
        		gridColums.push(columnsSet[i]);
        		for (let a = 0; a < markColums.length; a++) {
        			if (markColums[a] === columnsSet[i].data) {
        				mark_Colnm.push(setnum+i);
        			}
        		}
        		for (let b = 0; b < showSortNo.length; b++) {
        			if (showSortNo[b] === columnsSet[i].data) {
        				show_Sorts.push(setnum+i);
        			}
        		}
        		for (let c = 0; c < hideColums.length; c++) {
        			if (hideColums[c] === columnsSet[i].data) {
        				hide_Colnm.push(setnum+i);
        			}
        		}
        		for (let d = 0; d < muiltSorts.length; d++) {
        			if (muiltSorts[d][0] === columnsSet[i].data) {
        				muilt_Sort.push(setnum+i); 
        				muilt_Sort.push(muiltSorts[d][1]);
        			}
        		}
        	}
        	if (mark_Colnm.length > 0) { markColums = mark_Colnm; }
        	if (show_Sorts.length > 0) { showSortNo = show_Sorts; }
        	if (hide_Colnm.length > 0) { hideColums = hide_Colnm; }
        	if (muilt_Sort.length > 0) {        		
        		muiltSorts = [];
	        	for (let j = 0; j < muilt_Sort.length; j += 2) {
	        		muiltSorts.push([muilt_Sort[j],muilt_Sort[j + 1]]);
	        	}
        	}
        }
		// 조회 조건 담기
		function findField(element) {
			
			const index = findValues.findIndex(item => item.id === element.id);
		
			if (index !== -1) {
			    findValues[index].val = element.value;
			} else {
			    findValues.push({ id: element.id, val: element.value });
			}
		}
		// 조회 조건에서 input Field가 있으면 EnterKey 후 검색 (단, input Field에서 함수 호출 해야됨)
		function findEnterKey() {
		    if (event.key === 'Enter') {
		    	fn_FindData(); 
		    }
		}
		// 주소 검색 모달 열기
		function openAddressSearch() {
		    $('#addressModal').modal({ backdrop: false, keyboard: true }); // 배경 막음 없이 모달 열기
		    $('#addressModal').css("z-index", "10700"); // z-index를 올려서 다른 모달보다 위로 배치
		    $("#addressModal").modal("show"); // Bootstrap 모달 닫기
		}
		// 주소 검색 모달 닫기
		function closeModal() {
		    $("#addressModal").modal("hide"); // Bootstrap 모달 닫기
		}
		$(document).ready(function () {
		    // 모달이 열릴 때 카카오 주소 검색 실행
		    $('#addressModal').on('shown.bs.modal', function () {
		        var addressSearchDiv = document.getElementById('addressSearchResult');
		        addressSearchDiv.innerHTML = ""; // 기존 내용 초기화 (중복 실행 방지)

		        new daum.Postcode({
		            oncomplete: function(data) {
		                var addr = '';
		                var extraAddr = '';

		                if (data.userSelectedType === 'R') {
		                    addr = data.roadAddress;
		                } else {
		                    addr = data.jibunAddress;
		                }

		                if (data.userSelectedType === 'R') {
		                    if (data.bname !== '' && /[동|로|가]$/g.test(data.bname)) {
		                        extraAddr += data.bname;
		                    }
		                    if (data.buildingName !== '' && data.apartment === 'Y') {
		                        extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
		                    }
		                    if (extraAddr !== '') {
		                        extraAddr = ' (' + extraAddr + ')';
		                    }
		                } else {
		                    extraAddr = '';
		                }

		                // 주소 및 우편번호 입력
		                $("#zipCd").val(data.zonecode);
		                $("#compAddr").val(addr + extraAddr);

		                closeModal(); // 주소 선택 후 모달 닫기
		            },
		            width: '100%',
		            height: '400px'
		        }).embed(addressSearchDiv);
		    });
		    
		    
		    initHcResultsTable(); //계약관리   
		    initHuResultsTable(); //사용자관리
 
		});
	//병원계약관계 로직시작  
        //계약관계 전역변수 
        var hcedit_Data = null;
        var hctmpedit_Data = null;
		var hc_tableName  = document.getElementById('hc_tableName');
		var hc_modalName  = document.getElementById('hc_modalName');
		var hc_inputZone  = document.getElementById('hc_inputZone');
		var hc_dataTable  = new DataTable();
		hc_dataTable.clear();
		function hc_validateForm() {
		    const results = formValCheck(hc_inputZone.id, {
		        startDt_one:      { kname: "시작일자", k_req: true },
		        endDt_one:        { kname: "종료일자", k_req: true },
		        useYn_one:        { kname: "사용여부" , k_req: true },
		        conUserId_one:    { kname: "계약담당"},
		        conUserTel_one:   { kname: "전화번호"}
		    });
		    return results;
		}
		//그리드상 데이타생성및 수정 작업
		function hc_newuptData() {
        	let hc_newData = {
                compCd_one:        $('#compCd_one').val(),
        		startDt_one:       $('#startDt_one').val(),
        		endDt_one:         $('#endDt_one').val(),
        		conContent_one:    $('#conContent_one').val(),
        		useYn_one:         $('#useYn_one').val(),
                acceptDt_one:      $('#acceptDt_one').val(),
                closeDt_one:       $('#closeDt_one').val(),
                conUserId_one:     $('#conUserId_one').val(),
                conUserTel_one:    $('#conUserTel_one').val(),
                conEmail_one:      $('#conEmail_one').val()
			    };
		    return hc_newData;
		}	
		//	
		function initHcResultsTable() {
		  if (!$.fn.DataTable.isDataTable('#' + hc_tableName.id)) {
		   	hc_dataTable =  $('#' + hc_tableName.id).DataTable({  // 올바르게 닫힌 선택자
		            responsive:    false,
		            autoWidth:     false,
		            ordering:      false,
		            searching:     false, // 검색 기능 제거
		            lengthChange:  true, // 페이지당 개수 변경 옵션 제거
		            info:          false,
		            paging:        false, // 페이징 제거
		            scrollY: "300px", // 세로 스크롤 추가
		            fixedHeader: true, // 헤더 고정
	    			search: {
	    	            return:  false,          	            
	    	        },	
				    rowCallback: function(row, data, index) {
			            $(row).find('td').css('padding',colPadding); 
			        },	
		            language: {
						search: "자 료 검 색 : ",
					    emptyTable: "데이터가 없습니다.",
					    lengthMenu: "_MENU_",
					    info: "현재 _START_ - _END_ / 총 _TOTAL_건",
					    infoEmpty: "데이터 없음",
					    infoFiltered: "( _MAX_건의 데이터에서 필터링됨 )",
					    loadingRecords: "대기중...",
					    processing: "잠시만 기다려 주세요...",
					    paginate: {"next": "다음", "previous": "이전"},
		            },
		            columns: [
		            	{ title: "회사코드",    data: "compCd_one" ,    visible: false  , name: 'keycompCd' , primaryKey: true },
		            	{ title: "계약시작일",   data: "startDt_one",    className: "text-center" , name: 'keystartDt', primaryKey: true,  defaultContent: '',
			              render: function(data, type, row) {
			            	 if (type === 'display') { return data ? getFormat(data,'d1') : ''; }
			                 return data;
			              }
			            },
		            	{ title: "계약종료일",  data: "endDt_one",      className: "text-center" , name: 'keyendDt', primaryKey: true , defaultContent: '',
			                render: function(data, type, row) {
					            	if (type === 'display') { return data ? getFormat(data,'d1') : ''; }
					                return data;
			                }
					      },
		            	{ title: "세부내용",    data: "conContent_one",   className: "text-left", defaultContent: '' },
		            	{ title: "승인일자",    data: "acceptDt_one",      className: "text-center", defaultContent: '',
			              render: function(data, type, row) {
			            	 if (type === 'display') { return data ? getFormat(data,'d1') : ''; }
			                 return data;
			              }
			            },
		            	{ title: "중지일자",    data: "closeDt_one",       className: "text-center", defaultContent: '',
			              render: function(data, type, row) {
			            	 if (type === 'display') { return data ? getFormat(data,'d1') : ''; }
			                 return data;
			              }
			            },
		            	{ title: "사용",       data: "useYn_one",     className: "text-center", defaultContent: '' },
		            	{ title: "계약담당",    data: "conUserId_one", className: "text-center", defaultContent: '' }
		            ],
		            ajax: hcontLoad,   
				});                               
			    // 입력 버튼 클릭 이벤트
			    $('#' + hc_tableName.id + ' tbody').on('click', '.ins-btn', function() {
			        // 여기에 입력 로직을 구현하세요
			        
			    });
			    // 수정 버튼 클릭 이벤트
			    $('#' + hc_tableName.id + ' tbody').on('click', '.upt-btn', function() {
			        var data = hc_dataTable.row($(this).parents('tr')).data();
			        // 여기에 수정 로직을 구현하세요
			    });
		
			    // 삭제 버튼 클릭 이벤트
			    $('#' + hc_tableName.id + ' tbody').on('click', '.del-btn', function() {
			    	var data = hc_dataTable.row($(this).parents('tr')).data();
			    	messageBox("9","<h5>정말로 삭제하시겠습니까 ? 요양기관기호 : " + data.compCd_one + " 입니다. </h5><p></p><br>",mainFocus,"","");
			    	confirmYes.addEventListener('click', () => {
			    		// Yes후 여기서 처리할 로직 구현
			    		// grid data 삭제
			    		hc_dataTable.row($(this).parents('tr')).remove().draw();    		 
			    		messageDialog.hide();
			    		
			        });
			    });
		   	//row 모든데이타 자동 가져오기(모달창에서 데이타 조건없이뿌려짐)  
		   	    $('#' + hc_tableName.id + ' tbody').on('click', 'tr', function() {
		        	  hcedit_Data = hc_dataTable.row(this).data(); // 선택한 행 데이터 저장
		        });  
			    /* 싱글 선택 start */
			    if (row_Select) {
			    	hc_dataTable.on('click', 'tbody tr', (e) => {
				  	    let classList = e.currentTarget.classList;
				  	 
				  	    if (!classList.contains('selected')) {
				  	    	hc_dataTable.rows('.selected').nodes().each((row) => row.classList.remove('selected'));
				  	        classList.add('selected');
				  	    } 
				  	});    
			    }	
				//더블클릭시 수정모드  
			    $('#' + hc_tableName.id + ' tbody').on('dblclick', 'tr', function () {
			        let table = $('#' + hc_tableName.id).DataTable();
			        let rowData = table.row(this).data(); // 해당 행 데이터 가져오기
			        hc_modal_Open('U', rowData);
			    });	
		    }
		}
		function hcontLoad(data, callback, settings) {
			$('#' + tableName.id).on("click", "tr", function () {
				hcedit_Data = null ;
			    var selectedRowData = $('#' + tableName.id).DataTable().row(this).data(); // 선택한 행 데이터 가져오기
			    if (!selectedRowData) return;
			    var hospUuidcd  = selectedRowData.hospUuid; // 선택한 병원 코드(hospUuid)
			    var hospidcd    = selectedRowData.compCd; // 선택한 병원 코드(hospUuid)
			    //상단에서 기존row에서 받은자료에  hcedit_Data 추가로 json저장  
				// 기존 hcedit_Data 유지, compCdone 값이 사라지는 걸 방지
				hctmpedit_Data = hctmpedit_Data || {}; 
				hctmpedit_Data.compCd_one   = hospidcd; // 기본값 저장
				hctmpedit_Data.hospUuid_one = hospUuidcd;
			    if (hospidcd) {
			        // AJAX 요청하여 hospUuid에 해당하는 데이터 가져오기
			        $.ajax({
			            url: ctx + "/user/compContList.do", // 실제 서버 엔드포인트 입력
			            type: "POST",
			            data: { compCd: hospidcd }, // hospUuid 전달
			            dataType: "json",
				        beforeSend : function () {
				        	var table = $('#'+ hc_tableName.id).DataTable();
		                    table.clear().draw(); // 기존 데이터 초기화				        	
						},
				        success: function(response) {
				            if (response && Object.keys(response).length > 0) {
				            	let receiveList = receiveDTO(response,"_one") || [];
					    	    // DataTable 적용 시 데이터 확인 후 처리 받은 DTO KEY 뱐환작업(중복ID 배제)   
					    	    if (Array.isArray(receiveList) && receiveList.length > 0) {
					    	    	$('#' + hc_tableName.id).DataTable().clear().rows.add(receiveList).draw();
					    	    } else {
					    	        $('#' + hc_tableName.id).DataTable().clear().draw();
					    	    }
					    	    callback(receiveList);
				            } else {
				            	callback([]); // 빈 배열을 콜백으로 전달
				            }
				        },
				        error: function(jqXHR, textStatus, errorThrown) {
				            callback({
				                data: []
				            });
				            // table.clear().draw(); // 테이블 초기화 및 다시 그리기
				        }
			        });
			    }
			});
		}
		function hc_modal_Open(flag) {
			
			
			let hc_modal_OpenFlag = true;
			const hc_insertButton = document.getElementById('hc_form_btn_ins');
		    const hc_updateButton = document.getElementById('hc_form_btn_udt');
		    const hc_deleteButton = document.getElementById('hc_form_btn_del');
  
		    // Hide all
		    hc_insertButton.style.display = 'none';
		    hc_updateButton.style.display = 'none';
		    hc_deleteButton.style.display = 'none';
		
		    // Show button
		    switch (flag) {
		        case 'I': // Show Insert button
		            hc_insertButton.style.display = 'inline-block';
		            hc_modalHead.innerText  = "입력 모드입니다" ; 
		            break;
		        case 'U': // Show Update button
		            hc_updateButton.style.display = 'inline-block';
		            hc_modalHead.innerText  = "수정 모드입니다" ;
		            break;
		        case 'D': // Show Delete button
		            hc_deleteButton.style.display = 'inline-block';
		            hc_modalHead.innerText  = "삭제 모드입니다" ;
		            break;
		    }    
		    applyAuthControl(); //권한관리 (입력수정삭제 ) 모달뛰우기전 
		    formValClear(hc_inputZone.id);
		 // hospUuidone 값이 있는지 확인 후 설정
		    if (flag == 'I'){
		        if (!hctmpedit_Data) {
		        	messageBox("1","<h5> 병원자료가 선택되지 않았습니다. !!</h5><p></p><br>",mainFocus,"","");	
		            return;
		        }
		    	$("#compCd_one").val(hctmpedit_Data.compCd_one ? hctmpedit_Data.compCd_one : '');
		        $("#hospUuid_one").val(hctmpedit_Data.hospUuid_one ? hctmpedit_Data.hospUuid_one : '');
		    }   
		    if (flag !== 'I') {
				// 수정.삭제 모드 (대상확인)
				if (hcedit_Data) {
					formValueSet(hc_inputZone.id,hcedit_Data);
			
				} else {
					hc_modal_OpenFlag = false;
					messageBox("1","<h5>작업 할 Data가 선택되지 않았습니다. !!</h5><p></p><br>",mainFocus,"","");			
					return null;
				}
			}
			
			if (hc_modal_OpenFlag) {
				// 모달을 드레그할 수 있도록 처리
			    // Make the DIV element draggable:	    
			    
				var element = document.querySelector('#' + hc_modalName.id);
			    dragElement(element);
			    //수정키 readonly 
				modal_key_hidden(flag)
			    function dragElement(elmnt) {
			        var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
			        // 어디든 클릭하여 움직여도 가능 (.modal-content)
			        // 타이틀 클릭하여 움직여만 가능 (.modal-header)
			        // 필요시 변경하여 사용하면 됨
			        if (elmnt.querySelector('.modal-header')) {
			            elmnt.querySelector('.modal-header').onmousedown = dragMouseDown;
			        } else {
			            elmnt.onmousedown = dragMouseDown;
			        }
			        function dragMouseDown(e) {
			            e = e || window.event;
			            //e.preventDefault(); // 기본 동작 방지
			            pos3 = e.clientX;
			            pos4 = e.clientY;
			            document.onmouseup = closeDragElement;
			            document.onmousemove = elementDrag;
			        }
		
			        function elementDrag(e) {
			            e = e || window.event;
			            //e.preventDefault(); // 기본 동작 방지
			            pos1 = pos3 - e.clientX;
			            pos2 = pos4 - e.clientY;
			            pos3 = e.clientX;
			            pos4 = e.clientY;
			            elmnt.style.top  = (elmnt.offsetTop - pos2)  + "px";
			            elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
			        }
		
			        function closeDragElement() {
			            document.onmouseup = null;
			            document.onmousemove = null;
			        }
			    }
		
			    function centerModal() {
			        const modal = document.querySelector('#' + hc_modalName.id);
			        modal.style.top  = "50%";
			        modal.style.left = "50%";
			        modal.style.transform = "translate(-50%, -50%)";
			    }
			    // 모달 띄울 때 항상 중앙에 위치
			    $("#" + hc_modalName.id).on('show.bs.modal', function () {	    	
			        centerModal();
			        var firstFocus = $(this).find('input:first');
			        setTimeout(function () {
		     	        $("#" + firstFocus.attr('id')).focus();
			        }, 500); // 포커스 강제 설정
			    });
			    // 모달 창 크기가 변경될 때도 중앙에 유지
			    window.addEventListener('resize', centerModal);
			    // 모달 띄우기
			    $("#" + hc_modalName.id).modal('show');   
			    
			    if (getCookie("s_userid")) {
			        hc_inputZone.querySelector("[name='regUser_one']").value = getCookie("s_userid");
			        hc_inputZone.querySelector("[name='updUser_one']").value = getCookie("s_userid");
			    }

			    if (getCookie("s_connip")) {
			        hc_inputZone.querySelector("[name='regIp_one']").value = getCookie("s_connip");
			        hc_inputZone.querySelector("[name='updIp_one']").value = getCookie("s_connip");
			    }  
			}
		}		
		// (COMP) 계약구분(conactGb)/subCodeNm 제거 — 관련 로드/리스너 삭제
		function hc_fn_Insert(){
			const results = hc_validateForm();
			if (results)
			{
				let dats = [];
				let data = {};
		        results.forEach(result => {
		        	if (format_convert.length > 0) {
		        		if (format_convert.includes(result.id)) {
				            data[result.id] = replaceMulti(result.val,'-','/');		        		
			        	}else{
			        		data[result.id] = result.val;
			        	}
		        	}else{
		        		data[result.id] = result.val;
		        	}	
		        });
		        //////////////////// ✅ sendDTO(true)의 반환값 추가 (필요한 경우)
		        let dtoData = sendDTO(true,"_one");
		        Object.keys(dtoData).forEach(key => {
		            if (format_convert.length > 0 && format_convert.includes(key)) {
		            	dtoData[key] = replaceMulti(dtoData[key], '-', '/');  
		            }
		        });
		        ////////////////////////////////////////////////////// 위내용을 다시적용해야합니다 		        
		        if (dtoData && Object.keys(dtoData).length > 0) {
		            dats.push(dtoData);
		        }				
		      //  dats.push(data);	    
			    $.ajax({
			            type: "POST",
			            url: ctx + "/user/compContInsert.do",
			            data: JSON.stringify(dats),
			            contentType: "application/json",
			    	    dataType: "json",
			            success: function(response) {
			            	// checkbox, 자동순번은 넣지 않습니다.
			            	// *******단, 나머지 컬럼은 반드시 기술해야 합니다. 
			            	let hc_newData = hc_newuptData();
	
			            	hc_dataTable.row.add(hc_newData).draw(false);
    			
			            	messageBox("1","<h5> 정상처리 되었습니다 ...... </h5><p></p><br>",mainFocus,"","");	
			            	$("#" + hc_modalName.id).modal('hide');
		            	
			            	HospGrid_Update(hc_newData.compCd_one) ; //상당그리드 업데이트  
	                
	            	
			        	},
			        	error: function(xhr, status, error) {
				         	switch (xhr.status){  
				         	     case 500: messageBox("5","<h5>서버에 문제가 발생했습니다.</h5>" +  
			                               "<h6>잠시후 다시, 시도해주십시요. !!</h6>",mainFocus,"","");
				        		    break;
				         	     case 400:
				        		    messageBox("5","<h5>기존자료가 존재합니다.</h5>" +  
			                               "<h6>다시 확인하고, 시도해주십시요. !!</h6>",mainFocus,"","");
				        		    break;
				         	     default:  
				                     messageBox("5", "<h5>알 수 없는 오류가 발생했습니다.</h5>" +  
			                                   "<h6>관리자에게 문의하세요.</h6>", mainFocus, "", "");
			                        break;
				        		end    
				           	}
			        	}	
			    });
			}
		}
	
		// Modal Form에서 수정
		function hc_fn_Update() {
		    // 1. 입력값 검증 및 유효성 검사
            const results = hc_validateForm();
		    if (results) {
		        // 2. 데이터 수집
		        let data = {};
		        results.forEach(result => {
		        	if (format_convert.length > 0) {
		        		if (format_convert.includes(result.id)) {
				            data[result.id] = replaceMulti(result.val,'-','/');		        		
			        	}else{
			        		data[result.id] = result.val;
			        	}
		        	}else{
		        		data[result.id] = result.val;
		        	}	
  	
		        });
			     // ✅ sendDTO(true) 먼저 호출하여 값 가져오기
		        let sendData = sendDTO(true,"_one"); 
				Object.keys(sendData).forEach(key => {
				    if (format_convert.length > 0 && format_convert.includes(key)) {
				        sendData[key] = replaceMulti(sendData[key], '-', '/');  
				    }
				});
		        data = { ...data, ...sendData }; //id중복(_one) 제거    
		        
		        ////////////////////////////////////////////////////// 위내용을 다시적용해야합니다 		
		        // 3. 선택된 행의 Primary Key 가져오기
		        var selectedRows = hc_dataTable.rows('.selected');
		        let keys = dataTableKeys(hc_dataTable, selectedRows);
		
		        // 4. Primary Key와 입력 데이터 병합 (배열로 만들어 서버에 전송)
		        let mergeData = keys.map(key => ({ ...data, ...key }));
		        // 5. AJAX로 서버 업데이트 요청
		        $.ajax({
		            type: "POST",
		            url: ctx + "/user/compContUpdate.do",
		            data: JSON.stringify(mergeData), // JSON 변환
		            contentType: "application/json",
		            dataType: "json",
		            success: function(response) {
		                console.log("업데이트 성공", response);
		                // 6. DataTable에 변경된 값 반영
		                let hc_updatedData = hc_newuptData();		                

		                selectedRows.every(function(rowIdx) {
		                    let rowData = this.data();
		                    Object.keys(hc_updatedData).forEach(function(key) {
		                    	rowData[key] = hc_updatedData[key];
		                    });
		                    this.data(rowData);
		                });
		
		                dataTable.draw(false);
	                
 	                // 7. 모달 닫기 및 성공 메시지 표시
		                $("#" + hc_modalName.id).modal('hide');
		                messageBox("1", "<h5> 정상적으로 업데이트되었습니다. </h5>", mainFocus, "", "");
		                
		                HospGrid_Update(hc_updatedData.compCd_one) ; //상당그리드 업데이트  
		            },
		            error: function(xhr, status, error) {
		                console.error("업데이트 실패", xhr.responseText);
		                messageBox("5", "<h5>서버에 문제가 발생했습니다.</h5><h6>잠시 후 다시 시도해주세요.</h6>", mainFocus, "", "");
		            }
		        });
		    }
		}

		// Modal Form에서 삭제
		function hc_fn_Delete(){
			let isKey = false;
			Swal.fire({title:'삭제여부',text:'정말 삭제 하시겠습니까 ?', icon:'question' ,
					   showCancelButton:true,confirmButtonText:'예',cancelButtonText:'아니오',
					   customClass: {
						   popup: 'small-swal'}
			     }).then((result) => {
				// 사용자가 '예' 버튼을 클릭한 경우
				let data = {};
				if (result.isConfirmed) {
					// (수정.삭제 primaryKey로 조회)			
				    // primaryKey로 설정된 컬럼 찾기 
				    var selectedRows = hc_dataTable.rows('.selected');
					let keys = dataTableKeys(hc_dataTable, selectedRows);
					if (keys.length > 0) {	        	
						$.ajax({
				            type: "POST",
				            url: ctx + "/user/compContDelete.do",	    	    
				    	    data: JSON.stringify(keys),	    	    
				    	    contentType: "application/json",
				    	    dataType: "json",
				            success: function(response) {
				            	Swal.fire({
						            title: '처리확인',
						            text:  '정상처리 되었습니다. ',
						            icon:  'success',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false,
						            customClass: {
										   popup: 'small-swal'}
						        });
				            	let hc_updatedData = hc_newuptData();
			            	
							    // 선택된 행 삭제
							    selectedRows.remove().draw();
							    // 삭제 후 선택 초기화
							    selectedRow = null; 
							    $("#" + hc_modalName.id).modal('hide');
							    
							    HospGrid_Update(hc_updatedData.compCd_one) ; //상당그리드 업데이트 
				            },
				        	error: function(xhr, status, error) {
				        		Swal.fire({
						            title: '에러확인',
						            text:  '문제 발생, 잠시후 다시 하십시요.',
						            icon:  'error',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false,
						            customClass: {
										   popup: 'small-swal'}
						        });
				        	}
					    });
							
					} else {
						Swal.fire({
				            title: '오류확인',
				            text:  '삭제 Key가 존재하지 않습니다. ',
				            icon:  'warning',
				            confirmButtonText: '확인',
				            timer: 1500, // 1.5초후 없어짐
				            timerProgressBar: true,
				            showConfirmButton: false ,
				            customClass: {
								   popup: 'small-swal'}
				        });
					}
				
				} else if (result.isDismissed) {
					Swal.fire({
			            title: '취소확인',
			            text:  '작업이 취소 되었습니다. ',
			            icon:  'info',
			            confirmButtonText: '확인',
			            timer: 1000, // 1.5초후 없어짐
			            timerProgressBar: true,
			            showConfirmButton: false ,
			            customClass: {
							   popup: 'small-swal'}
			        });
				}
			});
		}
		 //사용자등록 부분
        //사용자등록 전역변수 
        var huedit_Data = null;
        var hutmpedit_Data = null;
		var hu_tableName  = document.getElementById('hu_tableName');
		var hu_modalName  = document.getElementById('hu_modalName');
		var hu_inputZone  = document.getElementById('hu_inputZone');
		var hu_dataTable  = new DataTable();
		hu_dataTable.clear();

       
		function hu_validateForm() {
		    const results = formValCheck(hu_inputZone.id, {
		    	userId_two:     { kname: "사용자구분" , k_req: true, k_spc: true, k_clr: true },
		    	userNm_two:     { kname: "사용자성명" , k_req: true },
		    	startDt_two:    { kname: "사용시작일" , k_req: true },
		    	endDt_two:      { kname: "사용종료일" , k_req: true },
		    	useYn_two:      { kname: "사용여부" },
		    	mbrJoin_two:    { kname: "회원가입여부" }
		    });
		    return results;
		}
	//	document.getElementById("commstYn").addEventListener("change", function() {
	//	    this.value = this.checked ? "Y" : "N"; 
	//	});		
		//그리드상 데이타생성및 수정 작업
		function hu_newuptData() {
        	let hu_newData = {
        		userId_two  :    $('#userId_two').val(),
        		userNm_two  :    $('#userNm_two').val(),
        		startDt_two:     $('#startDt_two').val(),
        		compCd_two:      $('#compCd_two').val(),
        		endDt_two:       $('#endDt_two').val(),
        		useYn_two:       $('#useYn_two').val(),
        		mainGuNm_two:    $('#mainGuNm_two').val(),
        		mbrJoin_two:     $('#mbrJoin_two').val()
			    };
		    return hu_newData;
		}	
		//	
		function initHuResultsTable() {
		  if (!$.fn.DataTable.isDataTable('#' + hu_tableName.id)) {
		   	hu_dataTable =  $('#' + hu_tableName.id).DataTable({  // 올바르게 닫힌 선택자
		            responsive:    false,
		            autoWidth:     false,
		            ordering:      false,
		            searching:     false, // 검색 기능 제거
		            lengthChange:  true, // 페이지당 개수 변경 옵션 제거
		            info:          false,
		            paging:        false, // 페이징 제거
		            scrollY: "300px", // 세로 스크롤 추가
		            fixedHeader: true, // 헤더 고정
	    			search: {
	    	            return:  false,          	            
	    	        },	
				    rowCallback: function(row, data, index) {
			            $(row).find('td').css('padding',colPadding); 
			        },	
		            language: {
						search: "자 료 검 색 : ",
					    emptyTable: "데이터가 없습니다.",
					    lengthMenu: "_MENU_",
					    info: "현재 _START_ - _END_ / 총 _TOTAL_건",
					    infoEmpty: "데이터 없음",
					    infoFiltered: "( _MAX_건의 데이터에서 필터링됨 )",
					    loadingRecords: "대기중...",
					    processing: "잠시만 기다려 주세요...",
					    paginate: {"next": "다음", "previous": "이전"},
		            },
		            columns: [
		            	{ title: "요양기관"  , data: "compCd_two",    className: "text-center", visible: true  , name: 'keyurcompCd' , primaryKey: true },
		            	{ title: "사용자아이디", data: "userId_two",   className: "text-center", visible: true  , name: 'keyuruserId' , primaryKey: true },
		            	{ title: "사용자성명",  data: "userNm_two",   className: "text-center"},  
		            	{ title: "사용자구분",  data: "mainGuNm_two", className: "text-center"},  
		            	{ title: "사용시작일",  data: "startDt_two",  className: "text-center" ,visible: true  , name: 'keyurstartDt' , primaryKey: true ,
	                      	render: function(data, type, row) {
	            				if (type === 'display') {
	            					return getFormat(data,'d1')
	                			}
	                			return data;
	        				}
	    				},
		            	{ title: "사용종료일",  data: "endDt_two",   className: "text-center", 
			              	render: function(data, type, row) {
	            				if (type === 'display') {
	            					return getFormat(data,'d1')
	                			}
	                			return data;
	        				}
	    				},
	    				{ title: "회원가입여부",   data: "mbrJoin_two",    visible: true ,   className: "text-center" }, 
		            	{ title: "사용여부",      data: "useYn_two",    className: "text-center" } 
		            ],
		            ajax: huserLoad ,
				});
			    // 입력 버튼 클릭 이벤트
			    $('#' + hu_tableName.id + ' tbody').on('click', '.ins-btn', function() {
			        // 여기에 입력 로직을 구현하세요
			        
			    });
			    // 수정 버튼 클릭 이벤트
			    $('#' + hu_tableName.id + ' tbody').on('click', '.upt-btn', function() {
			        var data = hu_dataTable.row($(this).parents('tr')).data();
			        // 여기에 수정 로직을 구현하세요
			    });
		
			    // 삭제 버튼 클릭 이벤트
			    $('#' + hu_tableName.id + ' tbody').on('click', '.del-btn', function() {
			    	var data = hc_dataTable.row($(this).parents('tr')).data();
			    	messageBox("9","<h5>정말로 삭제하시겠습니까 ? 사용자코드 : " + data.userId_two + " 입니다. </h5><p></p><br>",mainFocus,"","");
			    	confirmYes.addEventListener('click', () => {
			    		// Yes후 여기서 처리할 로직 구현
			    		// grid data 삭제
			    		hu_dataTable.row($(this).parents('tr')).remove().draw();    		 
			    		messageDialog.hide();
			    		
			        });
			    });
		   	//row 모든데이타 자동 가져오기(모달창에서 데이타 조건없이뿌려짐)  
		   	    $('#' + hu_tableName.id + ' tbody').on('click', 'tr', function() {
		        	  huedit_Data = hu_dataTable.row(this).data(); // 선택한 행 데이터 저장
		        });  
			    /* 싱글 선택 start */
			    if (row_Select) {
			    	hu_dataTable.on('click', 'tbody tr', (e) => {
				  	    let classList = e.currentTarget.classList;
				  	 
				  	    if (!classList.contains('selected')) {
				  	    	hu_dataTable.rows('.selected').nodes().each((row) => row.classList.remove('selected'));
				  	        classList.add('selected');
				  	    } 
				  	});    
			    }	
				//더블클릭시 수정모드  
			    $('#' + hu_tableName.id + ' tbody').on('dblclick', 'tr', function () {
			        let table = $('#' + hu_tableName.id).DataTable();
			        let rowData = table.row(this).data(); // 해당 행 데이터 가져오기
			        hu_modal_Open('U', rowData);
			    });	
				//datatable(jquery) 옵션관련 label을 span 변환 
				 $(document).ready(function() {
	                 let replaceLabelWithSpan = function(forValue) {
	                     let $label = $("label[for='" + forValue + "']");
	                     if ($label.length) {
	                         let $span = $("<span>").html($label.html()).attr("id", $label.attr("for"));
	                         $label.replaceWith($span);
	                     }
	                 };

	                 replaceLabelWithSpan('dt-search-0');
	                 replaceLabelWithSpan('dt-length-0');
	                 replaceLabelWithSpan('dt-length-1');
	             });       				
		    }
		}
		function huserLoad(data, callback, settings) {
			$('#' + tableName.id).on("click", "tr", function () {
				huedit_Data = null ;
			    var selectedRowData = $('#' + tableName.id).DataTable().row(this).data(); // 선택한 행 데이터 가져오기
			    if (!selectedRowData) return;
			    var hospUuidcd  = selectedRowData.hospUuid; // 선택한 병원 코드(hospUuid)
			    var hospidcd    = selectedRowData.compCd; // 선택한 병원 코드(hospUuid)
			    //상단에서 기존row에서 받은자료에  hcedit_Data 추가로 json저장  
				// 기존 hcedit_Data 유지, compCdone 값이 사라지는 걸 방지
				hutmpedit_Data = hutmpedit_Data || {}; 
				hutmpedit_Data.compCd_two   = hospidcd; // 기본값 저장
				hutmpedit_Data.hospUuid_two = hospUuidcd;
				hutmpedit_Data.compNm_two   = selectedRowData.compNm;
			    if (hospidcd) {
			        // AJAX 요청하여 hospUuid에 해당하는 데이터 가져오기
			        $.ajax({
			            url: ctx + "/user/compuserList.do", // 실제 서버 엔드포인트 입력
			            type: "POST",
			            data: { compCd: hospidcd }, // hospUuid 전달
			            dataType: "json",
				        beforeSend : function () {
				        	var table = $('#'+ hu_tableName.id).DataTable();
		                    table.clear().draw(); // 기존 데이터 초기화				        	
						},
				        success: function(response) {
				            if (response && Object.keys(response).length > 0) {
				            	let receiveList = receiveDTO(response,"_two") || [];
					    	    // DataTable 적용 시 데이터 확인 후 처리 받은 DTO KEY 뱐환작업(중복ID 배제)   
					    	    if (Array.isArray(receiveList) && receiveList.length > 0) {
					    	    	$('#' + hu_tableName.id).DataTable().clear().rows.add(receiveList).draw();
					    	    } else {
					    	        $('#' + hu_tableName.id).DataTable().clear().draw();
					    	    }
					    	    callback(receiveList);
				            } else {
				            	callback([]); // 빈 배열을 콜백으로 전달
				            }
				        },
				        error: function(jqXHR, textStatus, errorThrown) {
				            callback({
				                data: []
				            });
				            // table.clear().draw(); // 테이블 초기화 및 다시 그리기
				        }
			        });
			    }
			});
		}
		//수정시 키는 readonly
		function modal_key_hidden(flag) {	
			// 병원정보
	        const compCdInput         = document.getElementById("compCd");
	        const commstYnInput       = document.getElementById("commstYn");
	        // 계약정보
	        const conactGb_oneInput   = document.getElementById("conactGb_one");
	        const startDt_oneInput    = document.getElementById("startDt_one");
	        const endDt_oneInput      = document.getElementById("endDt_one");
	        // 사용자 정보 
	        const userId_twoInput     = document.getElementById("userId_two");
	        const startDt_twoInput    = document.getElementById("startDt_two");
	        const inputs = [compCdInput, commstYnInput, conactGb_oneInput, startDt_oneInput, endDt_oneInput, userId_twoInput, startDt_twoInput];
	        if (flag !== 'I') {
		        const isReadOnly = flag !== 'I';
		        inputs.forEach(input => {
		            if (input) { // 요소가 존재하는지 확인
		                input.readOnly = isReadOnly;
		            }
		        });
		    }else{
		        const isReadOnly = flag == 'N';
		        inputs.forEach(input => {
		            if (input) { // 요소가 존재하는지 확인
		                input.readOnly = isReadOnly;
		            }
		        });		    	
		    }
	        //콤보박스는 READONLY로 안됨
	        if (flag !== 'I') {
	            $(conactGb_oneInput).css("pointer-events", "none").css("background-color", "#e9ecef"); // 비활성화된 느낌의 배경색 적용
	        } else {
	            $(conactGb_oneInput).css("pointer-events", "").css("background-color", ""); // 활성화
	        }
		    $(commstYnInput).css("pointer-events", "none").css("background-color", "#e9ecef"); // 비활성화된 느낌의 배경색 적용
		}
		function hu_modal_Open(flag) {	

            let hu_modal_OpenFlag = true;
			const hu_insertButton = document.getElementById('hu_form_btn_ins');
		    const hu_updateButton = document.getElementById('hu_form_btn_udt');
		    const hu_deleteButton = document.getElementById('hu_form_btn_del');
  
		    // Hide all
		    hu_insertButton.style.display = 'none';
		    hu_updateButton.style.display = 'none';
		    hu_deleteButton.style.display = 'none';
		    // Show button
		    switch (flag) {
		        case 'I': // Show Insert button
		            hu_insertButton.style.display = 'inline-block';
		            hu_modalHead.innerText  = "입력 모드입니다" ; 
		            break;
		        case 'U': // Show Update button
		            hu_updateButton.style.display = 'inline-block';
		            hu_modalHead.innerText  = "수정 모드입니다" ;
		            break;
		        case 'D': // Show Delete button
		            hu_deleteButton.style.display = 'inline-block';
		            hu_modalHead.innerText  = "삭제 모드입니다" ;
		            break;
		    }    
		    applyAuthControl(); //권한관리 (입력수정삭제 ) 모달뛰우기전 
		    formValClear(hu_inputZone.id);
		 // hospUuidone 값이 있는지 확인 후 설정
		    if (flag == 'I'){
		        if (!hutmpedit_Data) {
		        	messageBox("1","<h5> 병원자료가 선택되지 않았습니다. !!</h5><p></p><br>",mainFocus,"","");	
		            return;
		        }		    	
		       $("#compCd_two").val(hutmpedit_Data.compCd_two ? hutmpedit_Data.compCd_two : '');
		       $("#hospUuid_two").val(hutmpedit_Data.hospUuid_two ? hutmpedit_Data.hospUuid_two : '');
		       
		       // 기본입력 조건 
		       $("#userId_two").val(hutmpedit_Data.compCd_two || '');
		       $("#userNm_two").val((hutmpedit_Data.compNm_two || '').substring(0, 3));
		       
		       var today = new Date();
		       var yyyy = today.getFullYear();
		       var mm = String(today.getMonth() + 1).padStart(2, '0');
		       var dd = String(today.getDate()).padStart(2, '0');
		       $("#startDt_two").val(yyyy + mm + dd);
		       $("#endDt_two").val('20991231');
		       $("#useYn_two").val('Y');
		       $("#mbrJoin_two").val('Y');
		       
		       $("#mainGu_two").val('3');
		       
    	       $("#bfPassWd_two").val('win7*');
		       $("#afPassWd_two").val('win7*');
		       //

		    }   
	        if (flag !== 'I') {
				// 수정.삭제 모드 (대상확인)
				if (huedit_Data) {
					formValueSet(hu_inputZone.id,huedit_Data);
			
				} else {
					hu_modal_OpenFlag = false;
					messageBox("1","<h5>작업 할 Data가 선택되지 않았습니다. !!</h5><p></p><br>",mainFocus,"","");			
					return null;
				}
				/*
				let commstYnCheckbox = document.getElementById("commstYn");

				// 체크박스 상태 설정 (huedit_Data가 존재하는 경우)
				if (huedit_Data && commstYnCheckbox) { 
				    if (huedit_Data.commstYn === "Y") {
				        commstYnCheckbox.checked = true;
				        commstYnCheckbox.value = "Y"; // 체크된 경우 값 변경
				    } else {
				        commstYnCheckbox.checked = false;
				        commstYnCheckbox.value = "N"; // 체크 해제된 경우 값 유지
				    }
				}
				*/
		    }

			if (hu_modal_OpenFlag) {
				// 모달을 드레그할 수 있도록 처리
			    // Make the DIV element draggable:	    
			    
				var element = document.querySelector('#' + hu_modalName.id);
			    dragElement(element);
	            //수정시 키는 readonly
	            modal_key_hidden(flag)
	            
			    function dragElement(elmnt) {
			        var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
			        // 어디든 클릭하여 움직여도 가능 (.modal-content)
			        // 타이틀 클릭하여 움직여만 가능 (.modal-header)
			        // 필요시 변경하여 사용하면 됨
			        if (elmnt.querySelector('.modal-header')) {
			            elmnt.querySelector('.modal-header').onmousedown = dragMouseDown;
			        } else {
			            elmnt.onmousedown = dragMouseDown;
			        }
			        function dragMouseDown(e) {
			            e = e || window.event;
			            //e.preventDefault(); // 기본 동작 방지
			            pos3 = e.clientX;
			            pos4 = e.clientY;
			            document.onmouseup = closeDragElement;
			            document.onmousemove = elementDrag;
			        }
		
			        function elementDrag(e) {
			            e = e || window.event;
			            //e.preventDefault(); // 기본 동작 방지
			            pos1 = pos3 - e.clientX;
			            pos2 = pos4 - e.clientY;
			            pos3 = e.clientX;
			            pos4 = e.clientY;
			            elmnt.style.top  = (elmnt.offsetTop - pos2)  + "px";
			            elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
			        }
		
			        function closeDragElement() {
			            document.onmouseup = null;
			            document.onmousemove = null;
			        }
			    }
		
			    function centerModal() {
			        const modal = document.querySelector('#' + hu_modalName.id);
			        modal.style.top  = "50%";
			        modal.style.left = "50%";
			        modal.style.transform = "translate(-50%, -50%)";
			    }
			    // 모달 띄울 때 항상 중앙에 위치
			    $("#" + hu_modalName.id).on('show.bs.modal', function () {	    	
			        centerModal();
			        var firstFocus = $(this).find('input:first');
			        setTimeout(function () {
		     	        $("#" + firstFocus.attr('id')).focus();
			        }, 500); // 포커스 강제 설정
			    });
			    // 모달 창 크기가 변경될 때도 중앙에 유지
			    window.addEventListener('resize', centerModal);
			    // 모달 띄우기
			    $("#" + hu_modalName.id).modal('show');   
			    
			    if (getCookie("s_userid")) {
			        hu_inputZone.querySelector("[name='regUser_two']").value = getCookie("s_userid");
			        hu_inputZone.querySelector("[name='updUser_two']").value = getCookie("s_userid");
			    }

			    if (getCookie("s_connip")) {
			        hc_inputZone.querySelector("[name='regIp_two']").value = getCookie("s_connip");
			        hc_inputZone.querySelector("[name='updIp_two']").value = getCookie("s_connip");
			    }  
			}
		}	
        //입력시는 비밀번호반드시 입력 수정이라도 입력가능 
        function hu_pass_chk(huflag){
        	
		    const hu_bfPassWd = document.getElementById('bfPassWd_two');
		    const hu_afPassWd = document.getElementById('afPassWd_two');        	
 		    
		    if (huflag == 'I') { 
               if (!hu_bfPassWd.value.trim() || !hu_afPassWd.value.trim()){
            	   messageBox("1","<h5>입력시 반드시 비밀번호를 입력하세요. !!</h5><p></p><br>",hu_bfPassWd,"","");
            	   return false;
               } 
            }
            if (hu_bfPassWd.value.trim()){
                if (hu_bfPassWd.value != hu_afPassWd.value){
             	   messageBox("1","<h5>비밀번호가 일치하지않습니다. !!</h5><p></p><br>",hu_bfPassWd,"","");
             	   return false;            	   
                }            	
            } 
        	return true ;
        }
		function hu_fn_Insert(){
			//패스워드 체크 
			if (!hu_pass_chk('I')){ 
			    return ; 			
		    }
			
			let dupchkVal = $("#dupchk").val();
			if (["N", "X"].includes(dupchkVal)) {
			    messageBox("1", "<h5>사용자아이디 중복체크 여부를 확인하세요.!!</h5><p></p><br>", mainFocus, "", "");
			    return;
			}    	

			const results = hu_validateForm();
			if (results)
			{
				let dats = [];
				let data = {};
		        results.forEach(result => {
		        	if (format_convert.length > 0) {
		        		if (format_convert.includes(result.id)) {
				            data[result.id] = replaceMulti(result.val,'-','/');		        		
			        	}else{
			        		data[result.id] = result.val;
			        	}
		        	}else{
		        		data[result.id] = result.val;
		        	}	
		        });
		       // let commstYnCheckbox = document.getElementById("commstYn");
		       // data["commstYn"] = commstYnCheckbox.checked ? "Y" : "N"; 
		        
		        //////////////////// ✅ sendDTO(true)의 반환값 추가 (필요한 경우)
		        let dtoData = sendDTO(true,"_two");
		        Object.keys(dtoData).forEach(key => {
		            if (format_convert.length > 0 && format_convert.includes(key)) {
		            	dtoData[key] = replaceMulti(dtoData[key], '-', '/');  
		            }
		        });
		        if (dtoData && Object.keys(dtoData).length > 0) {
		            dats.push(dtoData);
		        }
		        ////////////////////////////////////////////////////////////////
		       // dats.push(data);	    
			    $.ajax({
			            type: "POST",
			            url: ctx + "/user/compUserInsert.do",
			            data: JSON.stringify(dats),
			            contentType: "application/json",
			    	    dataType: "json",
			            success: function(response) {
			            	// checkbox, 자동순번은 넣지 않습니다.
			            	// *******단, 나머지 컬럼은 반드시 기술해야 합니다. 
			            	let hu_newData = hu_newuptData();
	
			            	hu_dataTable.row.add(hu_newData).draw(false);
			            	
			            	messageBox("1","<h5> 정상처리 되었습니다 ...... </h5><p></p><br>",mainFocus,"","");	            	
			            	$("#" + hu_modalName.id).modal('hide');
			            	
			        	},
			        	error: function(xhr, status, error) {
				         	switch (xhr.status){  
				         	     case 500: messageBox("5","<h5>서버에 문제가 발생했습니다.</h5>" +  
			                               "<h6>잠시후 다시, 시도해주십시요. !!</h6>",mainFocus,"","");
				        		    break;
				         	     case 400:
				        		    messageBox("5","<h5>기존자료가 존재합니다.</h5>" +  
			                               "<h6>다시 확인하고, 시도해주십시요. !!</h6>",mainFocus,"","");
				        		    break;
				         	     default:  
				                     messageBox("5", "<h5>알 수 없는 오류가 발생했습니다.</h5>" +  
			                                   "<h6>관리자에게 문의하세요.</h6>", mainFocus, "", "");
			                        break;
				        		end    
				           	}
			        	}	
			    });
			}
		}
		// Modal Form에서 수정
		function hu_fn_Update() {
			//패스워드 체크 
			if (!hu_pass_chk('U')){ 
			    return ; 			
		    }
			// 1. 입력값 검증 및 유효성 검사
            const results = hu_validateForm();
		    if (results) {
		        // 2. 데이터 수집
		        let data = {};
		        results.forEach(result => {
		        	if (format_convert.length > 0) {
		        		if (format_convert.includes(result.id)) {
				            data[result.id] = replaceMulti(result.val,'-','/');		        		
			        	}else{
			        		data[result.id] = result.val;
			        	}
		        	}else{
		        		data[result.id] = result.val;
		        	}	
  	
		        });
		        ////////////////////////////////////////////////////// 위내용을 다시적용해야합니다 
		        //  let commstYnCheckbox = document.getElementById("commstYn");
		      //  data["commstYn"] = commstYnCheckbox.checked ? "Y" : "N"; 
		        // ✅ sendDTO(true) 먼저 호출하여 값 가져오기
		        let sendData = sendDTO(true,"_two"); 
				Object.keys(sendData).forEach(key => {
				    if (format_convert.length > 0 && format_convert.includes(key)) {
				        sendData[key] = replaceMulti(sendData[key], '-', '/');  
				    }
				});
		        
		        data = { ...data, ...sendData }; //id중복(_one) 제거    
		        // 3. 선택된 행의 Primary Key 가져오기
		        var selectedRows = hu_dataTable.rows('.selected');
		        let keys = dataTableKeys(hu_dataTable, selectedRows);
		
		        // 4. Primary Key와 입력 데이터 병합 (배열로 만들어 서버에 전송)
		        let mergeData = keys.map(key => ({ ...data, ...key }));
		        // 5. AJAX로 서버 업데이트 요청
		        $.ajax({
		            type: "POST",
		            url: ctx + "/user/compUserUpdate.do",
		            data: JSON.stringify(mergeData), // JSON 변환
		            contentType: "application/json",
		            dataType: "json",
		            success: function(response) {
		                console.log("업데이트 성공", response);
		                // 6. DataTable에 변경된 값 반영
		                let hu_updatedData = hu_newuptData();		                

		                selectedRows.every(function(rowIdx) {
		                    let rowData = this.data();
		                    Object.keys(hu_updatedData).forEach(function(key) {
		                    	rowData[key] = hu_updatedData[key];
		                    });
		                    this.data(rowData);
		                });
		
		                dataTable.draw(false);
		                
		                // 7. 모달 닫기 및 성공 메시지 표시
		                $("#" + hu_modalName.id).modal('hide');
		                messageBox("1", "<h5> 정상적으로 업데이트되었습니다. </h5>", mainFocus, "", "");
		            },
		            error: function(xhr, status, error) {
		                console.error("업데이트 실패", xhr.responseText);
		                messageBox("5", "<h5>서버에 문제가 발생했습니다.</h5><h6>잠시 후 다시 시도해주세요.</h6>", mainFocus, "", "");
		            }
		        });
		    }
		}

		// Modal Form에서 삭제
		function hu_fn_Delete(){
			let isKey = false;
			Swal.fire({title:'삭제여부',text:'정말 삭제 하시겠습니까 ?', icon:'question' ,
					   showCancelButton:true,confirmButtonText:'예',cancelButtonText:'아니오',
					   customClass: {
						   popup: 'small-swal'}
			     }).then((result) => {
				// 사용자가 '예' 버튼을 클릭한 경우
				let data = {};
				if (result.isConfirmed) {
					// (수정.삭제 primaryKey로 조회)			
				    // primaryKey로 설정된 컬럼 찾기 
				    var selectedRows = hu_dataTable.rows('.selected');
					let keys = dataTableKeys(hu_dataTable, selectedRows);
					if (keys.length > 0) {	        	
						$.ajax({
				            type: "POST",
				            url: ctx + "/user/compUserDelete.do",	    	    
				    	    data: JSON.stringify(keys),	    	    
				    	    contentType: "application/json",
				    	    dataType: "json",
				            success: function(response) {
				            	Swal.fire({
						            title: '처리확인',
						            text:  '정상처리 되었습니다. ',
						            icon:  'success',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false,
						            customClass: {
										   popup: 'small-swal'}
						        });
							    // 선택된 행 삭제
							    selectedRows.remove().draw();
							    // 삭제 후 선택 초기화
							    selectedRow = null; 
							    $("#" + hu_modalName.id).modal('hide');
		
				        	},
				        	error: function(xhr, status, error) {
				        		Swal.fire({
						            title: '에러확인',
						            text:  '문제 발생, 잠시후 다시 하십시요.',
						            icon:  'error',
						            confirmButtonText: '확인',
						            timer: 1500, // 1.5초후 없어짐
						            timerProgressBar: true,
						            showConfirmButton: false,
						            customClass: {
										   popup: 'small-swal'}
						        });
				        	}
					    });
							
					} else {
						Swal.fire({
				            title: '오류확인',
				            text:  '삭제 Key가 존재하지 않습니다. ',
				            icon:  'warning',
				            confirmButtonText: '확인',
				            timer: 1500, // 1.5초후 없어짐
				            timerProgressBar: true,
				            showConfirmButton: false ,
				            customClass: {
								   popup: 'small-swal'}
				        });
					}
				
				} else if (result.isDismissed) {
					Swal.fire({
			            title: '취소확인',
			            text:  '작업이 취소 되었습니다. ',
			            icon:  'info',
			            confirmButtonText: '확인',
			            timer: 1000, // 1.5초후 없어짐
			            timerProgressBar: true,
			            showConfirmButton: false ,
			            customClass: {
							   popup: 'small-swal'}
			        });
				}
			});
		}
		function fnDupchk() {
		    let userId = $('#userId_two').val();

		    if (userId === "") {
		        messageBox("1", "<h5>사용자아이디를 입력하세요,!!</h5><p></p><br>", "userId_two", "", "");
		        return;
		    }
		    $("#dupchk").val("N");
		    $.ajax({
		        type: "POST",
		        url: ctx + "/user/compuseridupchk.do",
		        data: JSON.stringify({ userId: $("#userId_two").val(), compCd: $("#compCd_two").val() } ),
		        contentType: "application/json",
		        dataType: "json" ,
		    	success: function(response) {
		           messageBox("1", "<h5>해당 사용자아이디는 사용가능합니다.</h5><p></p><br>", "userId_two", "", "");
		           $("#dupchk").val("Y");
			    },
	        	error: function(xhr, status, error) {
		         	switch (xhr.status){  
		         	     case 500: messageBox("5","<h5>서버에 문제가 발생했습니다.</h5>" +  
	                               "<h6>잠시후 다시, 시도해주십시요. !!</h6>",mainFocus,"","");
		        		    break;
		         	     case 400:
		        		    messageBox("5","<h5>기존사용아이디가 존재합니다.</h5>" +  
	                               "<h6>다시 확인하고, 시도해주십시요. !!</h6>",mainFocus,"","");
		        		    break;
		         	      default :  
		                     messageBox("5", "<h5>알 수 없는 오류가 발생했습니다.</h5>" +  
	                                   "<h6>관리자에게 문의하세요.</h6>", mainFocus, "", "");
	                        break;
			       	}
		        }	
		    });
		}
		// DTO내용을 중복 피하기 위해 동적으로 "_one" 또는 "_two" 추가
		function receiveDTO(response, suffix) {
		    if (!response || !response.data || !Array.isArray(response.data)) {
		        console.error("🚨 변환할 데이터가 올바르지 않습니다:", response);
		        return [];
		    }

		    console.log("📌 원본 데이터:", response);

		    return response.data.map(data => {
		        let transformedData = {};
		        Object.entries(data).forEach(([key, value]) => {
		            transformedData[key + suffix] = value; // ✅ ID 변경 (예: codeCd → codeCd_one or codeCd_two)
		        });
		        console.log(`📌 바뀐 데이터 (${suffix} 적용):`, transformedData);
		        return transformedData;
		    });
		}

		// 화면의 값을 DTO로 변환하여 서버로 전송 (_one, _two 붙인 값 반전)
		function sendDTO(isSub, suffix) {
		    let dto = {};
		    // 모든 입력 요소(input, select, textarea)를 순회
		    $("input, select, textarea").each(function () {
		        let key = $(this).attr("id");
		        if (key) {
		            let newKey = key; // 기본적으로 기존 key 유지

		            if (isSub && key.endsWith(suffix)) {
		                newKey = key.replace(suffix, ""); // ✅ "_one" 또는 "_two" 제거
		            }
		            // ✅ SELECT 요소는 선택된 값(value)을 가져옴
		            // ✅ CHECKBOX는 체크 여부에 따라 true/false 또는 value 값을 설정
		            if ($(this).is("input[type='checkbox']")) {
		                dto[newKey] = $(this).prop("checked") ? $(this).val() || true : false;
		            } else if ($(this).is("input[type='radio']")) {
		                if ($(this).prop("checked")) {
		                    dto[newKey] = $(this).val();
		                }
		            } else {
		                dto[newKey] = $(this).val();
		            }
		            // ✅ 기존 `_one` 또는 `_two` 키를 dto에서 제거
		            if (isSub && key !== newKey && dto.hasOwnProperty(key)) {
		                delete dto[key];
		            }
		        }
		    });
		    console.log(`✅ 최종 DTO 데이터 (중복 제거 후, ${suffix} 제거):`, dto);
		    return dto;
		}
		// 파일 업로드 기능
		document.addEventListener("DOMContentLoaded", function () {
		    const dragArea = document.getElementById("drag-area");
		    const fileInput = document.getElementById("file-input");
		    const fileList = document.getElementById("file-list");
		
		   // 📌 파일 선택 버튼 클릭 시, 숨겨진 file-input을 클릭하도록 트리거
		    function openFileInput() {
		        fileInput.click();
		    }
		
		    // 📌 파일 변경 이벤트 핸들러 (파일이 선택되면 목록에 표시)
		    function changeHandler(event) {
		        let files = event.target.files;
		        handleFiles(files);
		    }
		
		    // 📌 파일 드래그 오버 이벤트 (파일이 드래그되면 스타일 변경)
		    function dragOverHandler(event) {
		        event.preventDefault();
		        dragArea.style.border = "2px dashed #007bff";
		    }
		
		    // 📌 파일 드래그 리브 이벤트 (드래그 해제 시 원래 스타일로 복귀)
		    function dragLeaveHandler(event) {
		        event.preventDefault();
		        dragArea.style.border = "2px dashed #ccc";
		    }
		
		    // 📌 파일 드롭 이벤트 (파일이 드롭되면 입력 필드에 추가)
		    function dropHandler(event) {
		        event.preventDefault();
		        dragArea.style.border = "2px dashed #ccc";
		
		        let dt = new DataTransfer(); // DataTransfer 객체 생성
		        for (let file of event.dataTransfer.files) {
		            dt.items.add(file);
		        }
		
		        fileInput.files = dt.files; // 파일 리스트를 file input에 설정
		        handleFiles(event.dataTransfer.files);
		    }
		    //파일문서등록 
		    function handleFiles(files) {
		    	// ✅ 새로 추가된 파일을 DataTransfer에 추가
		    	for (let k = 0; k < files.length; k++) {
		            const file = files[k];
		            // ✅ 중복 체크
		            if (!fileExists(file.name, dt_com.files)) {  
		                const fileItem = document.createElement("div");
		                fileItem.classList.add("file-item");
		                fileItem.textContent = file.name;
		                const deleteBtn = document.createElement("button");
		                deleteBtn.textContent = "삭제";
		                deleteBtn.classList.add("delete-btn");
		                deleteBtn.style.marginLeft = "10px";
		                // ✅ 삭제 버튼 클릭 시 파일 삭제
		                deleteBtn.addEventListener("click", function () {
		                    removeFile(file.name);
		                    fileItem.remove(); // ✅ UI에서도 제거
		                    dt_com.items.remove(k); 
		                });
		                dt_com.items.add(file); // ✅ 새로운 파일 추가
		                fileItem.appendChild(deleteBtn);
		                fileList.appendChild(fileItem);
		            } else {
		                console.warn(`⚠ 중복 파일 감지됨: ${file.name}`);
		            }
		        }
		        console.log("📌 최종 추가된 파일 개수:", dt_com.files.length);
		        
		        // ✅ 기존 fileInput을 직접 업데이트 (새로운 input을 만들지 않음)
			    updateFileInput(dt_com.files); //파일등록 초기화되지않는문제 로 마킹 (누적현상)
		        
		        console.log("📌 fileInput.files 업데이트 후 개수:", fileInput.files.length);
		        
		        saveFileListToStorage();
		    }
		 // ✅ 기존 fileInput을 직접 업데이트하는 함수
		    function updateFileInput(files) {
		        // dt 객체의 items를 새로운 파일 리스트로 설정
		        let dt_com = new DataTransfer();
		        for (let i = 0; i < files.length; i++) {
		        	dt_com.items.add(files[i]);
		        }

		        // ✅ 실제 fileInput의 files를 새로 설정
		        fileInput.files = dt_com.files;
		    }

		    // 📌 파일이 이미 존재하는지 확인하는 함수
 		    function fileExists(fileName) {
		        const fileItems = document.querySelectorAll(".file-item");
		        return Array.from(fileItems).some(item => item.textContent.includes(fileName));
		    }  
		    
			function removeFile(fileName) {
			    let dt = new DataTransfer();

			    // ✅ 삭제되지 않은 파일만 유지
			    for (let i = 0; i < fileInput.files.length; i++) {
			        if (fileInput.files[i].name !== fileName) {
			            dt.items.add(fileInput.files[i]);
			        }
			    }

			    fileInput.files = dt.files; // ✅ 변경된 파일 리스트 반영
			    saveFileListToStorage(); // ✅ LocalStorage 업데이트 (선택사항)
			}		
	
		    // 📌 파일 목록을 LocalStorage에 저장하는 함수
		    function saveFileListToStorage() {
		        const fileItems = document.querySelectorAll(".file-item");
		        const fileNames = Array.from(fileItems).map(item => item.textContent.replace("삭제", "").trim());
		        localStorage.setItem("fileList", JSON.stringify(fileNames));
		    }
		
		    // 📌 LocalStorage에서 파일 목록을 불러와 UI에 추가하는 함수
		    function loadFileListFromStorage() {
		        const savedFileList = JSON.parse(localStorage.getItem("fileList") || "[]");
		
		        savedFileList.forEach(fileName => {
		            if (!fileExists(fileName)) {
		                const fileItem = document.createElement("div");
		                fileItem.classList.add("file-item");
		                fileItem.textContent = fileName;
		
		                const deleteBtn = document.createElement("button");
		                deleteBtn.textContent = "삭제";
		                deleteBtn.classList.add("delete-btn");
		                deleteBtn.style.marginLeft = "10px";
		                deleteBtn.addEventListener("click", function () {
		                    fileItem.remove();
		                    saveFileListToStorage();
		                });
		
		                fileItem.appendChild(deleteBtn);
		                fileList.appendChild(fileItem);
		            }
		        });
		    }
		
		    // 📌 이벤트 리스너 등록
		    dragArea.addEventListener("dragover", dragOverHandler);
		    dragArea.addEventListener("dragleave", dragLeaveHandler);
		    dragArea.addEventListener("drop", dropHandler);
		    fileInput.addEventListener("change", changeHandler);
		
		    // 📌 페이지 로드 시 LocalStorage에서 파일 목록 불러오기
		    loadFileListFromStorage();
		
		    // 📌 파일 선택 버튼이 있으면 이벤트 리스너 추가
		    const fileSelectButton = document.getElementById("fileSelectBtn");
		    if (fileSelectButton) {
		        fileSelectButton.addEventListener("click", openFileInput);
		    }
		});
		// ✅ 파일문서 초기화 
		function fileinput_clear() {
		    const fileInput = document.getElementById("file-input");
		    const fileList = document.getElementById("file-list");
		    const fileNameDisplay = document.getElementById("file-name-display");

		    dt_com = new DataTransfer();

		 // input 요소의 files 속성에 빈 DataTransfer 적용
		    fileInput.files = dt_com.files;
		    // ✅ UI 초기화
		    fileList.innerHTML = "";
		    fileNameDisplay.innerText = "";

		    // ✅ 로컬스토리지도 초기화 (필요시)
		    localStorage.removeItem("fileList");

		    console.log("🧹 파일 초기화 완료 → 남은 파일 수:", dt_com.files.length);
		}
		
		//파일문서 업로드 부분(다중처리)
		document.getElementById("uploadForm").addEventListener("submit", function (event) {
			
		    event.preventDefault(); // 기본 제출 방지
			
		    let fileInput     = document.getElementById("file-input"); 
		    let statusDisplay = document.getElementById("file-name-display");
		    if (!fileInput.files.length) {
		        alert("📌 파일을 선택해주세요!");
		        return;
		    }
		    
		    let formData = new FormData();
		    // ✅ 다중 파일 추가 (서버에서 `files`로 받도록 수정)
		    for (let i = 0; i < fileInput.files.length; i++) {
		        formData.append("file", fileInput.files[i]); 
		    }
		    
		    // ✅ 추가 폼 데이터 설정
		    
		    let hospcd   =  document.getElementById("compCd").value;
		    let notiseq  =  '1';
		    let filegb   =  'C' ;
		    let reguser  =  document.getElementById("regUser").value;
		    let regip    =  document.getElementById("regIp").value;
		    formData.append("action" , "upload");
		    formData.append("compCd" , hospcd); // 병원 코드
		    formData.append("notiSeq", notiseq); // 공시사항 번호
		    formData.append("fileGb" , filegb); // 1: 공시사항, 2: 심사방, 3: 소식지  
		    formData.append("regUser", reguser);
		    formData.append("regIp"  , regip);
		    
		    console.log("📌 FormData 확인:");
		    for (let pair of formData.entries()) {
		        console.log(`🔹 Key: ${pair[0]}, Value:`, pair[1]);
		    }
		    
		    fetch("/sftp/fileupload.do", {
		        method: "POST",
		        body: formData
		    })
		    .then(response => {
		        if (!response.ok) {
		            throw new Error(`서버 오류: ${response.status}`);
		        }
		        return response.text();
		    })
		    .then(data => {
		        fileInput.value = "";
		        console.log("✅ 파일 업로드 성공:", data);
		        statusDisplay.textContent = "✅ 업로드 성공!";
		        statusDisplay.style.color = "green";
		        fileinput_clear() ;
		        showfileModal('1', 'C');
		    })
		    .catch(error => {
		        console.error("❌ 파일 업로드 실패:", error);
		        statusDisplay.textContent = "❌ 업로드 실패!!!!!!!";
		        statusDisplay.style.color = "red";
		    });
		}); 
		//데이타테입르 최초생성 
		$(document).ready(function() {
		    console.log("📌 최초 DataTables 생성");
		    $("#fileTable").DataTable({
		      //  scrollX: true,
		      //  scrollY: "100px",
		        scrollCollapse: true, // ✅ 내용이 적을 때도 높이 유지
		        paging:        false, // 페이지네이션 비활성화 (원하는 경우 제거 가능)
		        searching:     false,
		        ordering:      false,
		        autoWidth:     false,  // 🔹 자동 너비 조정 비활성화
		        fixedHeader:   true,   // 🔹 헤더 고정
		        colReorder:    true,
		        lengthChange:  true, 
		        fixedHeader:   true, // 헤더 고정
		        info:          false,	
		        lengthMenu: [],
		        language: {
		            search: "검색:",
		            lengthMenu: "페이지당 _MENU_ 개씩 보기",
		            info: "_START_ - _END_ (총 _TOTAL_ 개)",
		            paginate: {
		                next: "다음",
		                previous: "이전"
		            }
		        },
		        columns: [
		        	{ title: "번호",     className: "text-center", width: '50px' },
		            { title: "문서유형",  className: "text-center", width: '100px' },
		            { title: "문서제목",  className: "text-center", width: '300px' },
		            { title: "사이즈",   className: "text-center", width: '50px' },
		            { title: "작성일",   className: "text-center", width: '150px' },
		            { title: "삭제",     className: "text-center", width: '100px' },
		            { title: "첨부",     className: "text-center", width: '100px' }
		        ],
		        initComplete: function() {
		            // 테이블의 헤더 높이 맞추기
		            var headerHeight = $('#fileTable thead').outerHeight();
		            $('#fileTable tbody').css('padding-top', headerHeight + 'px');
		        }
		    });
		});	  
		function showfileModal(notiSeq, fileGb) {
			return; // COMP: 파일첨부 미사용 — /mangr/fileCdList.do 호출/그리드 초기화 스킵
			var compCd =  document.getElementById("compCd").value;
		    $.ajax({
		        type: "post",
		        url: ctx + "/mangr/fileCdList.do",
		        data: { compCd : compCd , fileGb: fileGb, fileSeq: notiSeq },
		        dataType: "json",
		        success: function (data) {
		          //  console.log("📌 서버 응답 데이터 개수:", data.length);
		          //  console.log("📌 서버 응답 데이터:", JSON.stringify(data, null, 2));

		            let tbody = document.querySelector("#fileTable tbody");
		            tbody.innerHTML = "";

		            if (!Array.isArray(data) || data.length === 0) {
		                console.warn("⚠️ 파일 목록이 없습니다.");
		                tbody.innerHTML = "<tr><td colspan='8' style='text-align: center;'>등록된 파일이 없습니다.</td></tr>";
		                return;
		            }

		            let tableBody = "";
		            data.forEach(function (doc, index) {
		                let subCodeNm = doc.subCodeNm || "정보 없음";
		                let fileTitle = doc.fileTitle || "제목 없음";
		                let fileSize  = doc.fileSize  || "제목 없음";
		                let regDttm   = doc.regDttm   || "날짜 없음";

		                // ✅ SFTP 기반 다운로드 URL 생성
		                let fileUrl = "#";
		                if (doc.filePath && doc.fileTitle) {
		                    let encodedPath = encodeURIComponent(doc.filePath);
		                    fileUrl = "/sftp/download.do?filePath=" + encodedPath;
		                }

		                console.log("📌 생성된 SFTP fileUrl:", fileUrl);

		                tableBody += "<tr>";
		                tableBody += "<td>" + (index + 1) + "</td>";
		                tableBody += "<td>" + subCodeNm + "</td>";
		                tableBody += "<td><a href='#' class='doc-link' data-url='" + fileUrl + "' data-title='" + fileTitle + "'>" + fileTitle + "</a></td>";
		                tableBody += "<td>" + fileSize + " KB</td>";
		                tableBody += "<td>" + regDttm + "</td>";

		                if (fileUrl !== "#") {
		                    // ✅ 삭제 버튼
		                    tableBody += "<td style='text-align: center; vertical-align: middle;'>";
		                    tableBody += "<a href='#' class='btn btn-link delete-file' " +
		                                 "data-filepath ='" + doc.filePath     + "' " +
		                                 "data-filetitle='" + doc.fileTitle    + "' " +
		                                 "data-filegb   ='" + doc.fileGb       + "' " +
		                                 "data-fileseq  ='" + doc.fileSeq      + "'>"; // fileSeq가 notiSeq인 경우
		                    tableBody += "<i class='fa-solid fa-trash' style='font-size: 1.2em; color: black;'></i>";
		                    tableBody += "</a>";
		                    tableBody += "</td>";

		                    // ✅ 다운로드 버튼
		                    tableBody += "<td style='text-align: center; vertical-align: middle;'>";
		                    tableBody += "<a href='" + fileUrl + "' download='" + fileTitle + "' " +
		                                 "class='btn btn-link file-download' title='다운로드'>" +
		                                 "<i class='fa-solid fa-floppy-disk' style='font-size: 1.2em; color: green; margin-right: 10px;'></i>" +
		                                 "</a>";
		                    tableBody += "</td>";
		                } else {
		                    // 파일 없을 때
		                    tableBody += "<td colspan='2' style='text-align: center; color: black;'>❌ 파일 없음</td>";
		                }
		                tableBody += "</tr>";

		            });

		            tbody.innerHTML = tableBody;
		            console.log("✅ 테이블 업데이트 완료!");
		        },
		        error: function (xhr, status, error) {
		            console.error("❌ AJAX 요청 실패:", status, error);
		            console.error("❌ 서버 응답:", xhr.responseText);
		        }
		    });
		}
		// ✅ 파일 미리보기 클릭 시
		$(document).on("click", ".file-download", function (e) {
		    const fileUrl = $(this).attr("href");
		    const fileTitle = $(this).attr("download");
		
		    if (!fileUrl.startsWith("/sftp/download.do")) {
		        alert("❌ 유효하지 않은 다운로드 경로입니다.");
		        e.preventDefault();
		    } else {
		        console.log("⬇️ 다운로드 시작: " + fileTitle);
		        // 기본 다운로드 동작이므로 굳이 loadFileContent() 호출할 필요 없음
		    }
		});

		// ✅ 미리보기 로직 (PDF, 이미지만 iframe)
		function loadFileContent(fileUrl, fileTitle) {
		    let fileExtension = fileTitle.split('.').pop().toLowerCase();
		    let contentHtml = "";

		    if (["pdf", "jpg", "jpeg", "png", "gif"].includes(fileExtension)) {
		        contentHtml = `<iframe src="${fileUrl}" width="100%" height="500px"></iframe>`;
		    } else {
		        contentHtml = `<p>미리보기를 지원하지 않는 파일 형식입니다. 
		                       <a href="${fileUrl}" download>다운로드</a>하여 확인하세요.</p>`;
		    }

		    $("#docContent").html(contentHtml);
		}

	// ✅ 삭제 버튼 클릭 시
	$(document).on("click", ".delete-file", function (e) {
	    e.preventDefault();
	
	    const filePath  = $(this).data("filepath");
	    const fileTitle = $(this).data("filetitle");
	    const fileSeq   = $(this).data("fileseq");
	    const fileGb    = $(this).data("filegb");
	    const compCd    = document.getElementById("compCd").value;
	    const updUser   = document.getElementById("updUser").value;
	    const updIp     = document.getElementById("updIp").value;
	
	    Swal.fire({
	        title: '삭제 확인',
	        text: '파일 "' + fileTitle + '" 을(를) 삭제하시겠습니까?',
	        icon: 'question',
	        showCancelButton: true,
	        confirmButtonText: '예',
	        cancelButtonText: '아니오',
	        customClass: {
	            popup: 'small-swal'
	        }
		    }).then((result) => {
		        if (result.isConfirmed) {
		            $.ajax({
		                type: "POST",
		                url: ctx + "/sftp/deleteFile.do",
		                data: {
		                	compCd   : compCd  ,
		                    filePath:  filePath,
		                    fileTitle: fileTitle,
		                    fileSeq:   fileSeq,
		                    fileGb:    fileGb,
		                    updUser:   updUser,
		                    updIp:     updIp
		                },
		                success: function (res) {
		                    showfileModal(fileSeq, fileGb); // 필요에 맞게 값 지정
		                },
		                error: function (xhr, status, error) {
		                    console.error("❌ 삭제 실패:", status, error);
		                }
		            });
		        }
		    });
	});
	function modalMainClose() {
		$("#" + modalName.id).modal('hide');
	}		
	function hc_modalClose() {
		$("#" + hc_modalName.id).modal('hide');
	}	
	function hu_modalClose() {
		$("#" + hu_modalName.id).modal('hide');
	}		
	//권한조건체크 applyAuthControl.js
    document.addEventListener("DOMContentLoaded", function() {
        applyAuthControl();
    });
    /*입력수정삭제 시 hosp_cont_getload(hospidcd) 호출 */
    function HospGrid_Update(compCd) {

        if (compCd) {
            setTimeout(() => {
                hosp_cont_getload(compCd); // 0.3초 지연 후 실행
            }, 300);
        } else {
            console.warn("compCd_one 없음, 데이터 갱신 생략");
        }	    	
    	
    }
	
	/*계약정보입력후 상단자료 그리드 업데이트*/
	function hosp_cont_getload(hospidcd) {
        $.ajax({
            type: "POST",
            url: ctx + "/user/compCdList.do",
            data: { compCd: hospidcd },  // 서버에서는 이 compCd 기준으로 1건 반환해야 함
            dataType: "json",
            timeout: 10000,
            beforeSend: function () {
                console.log("병원 데이터 조회 요청 시작:", hospidcd);
            },
            success: function (response) {
                if (response && response.data && response.data.length > 0) {
                    const newRowData = response.data[0];  // ← 서버에서 받은 최신 데이터 (전체 필드 포함)

                    let rowFound = false;

                    dataTable.rows().every(function () {
                        const rowData = this.data();

                        if (String(rowData.compCd) === String(hospidcd)) {
                            console.log("업데이트 대상 행 찾음:", rowData.compCd);

                            this.data(newRowData);   // ✅ 행 전체를 새로운 객체로 교체
                            this.invalidate();        // 무효화 → 렌더링 재계산
                            rowFound = true;

                            // 선택 상태 유지
                            dataTable.$('tr.selected').removeClass('selected');
                            $(this.node()).addClass('selected');
                            $(this.node()).trigger('click');

                            return false;  // 탐색 종료
                        }
                    });

                    if (!rowFound) {
                        alert("상단 그리드에 compCd 일치 행이 없어 새로 추가합니다.");
                        dataTable.row.add(newRowData).draw(false);
                    } else {
                        dataTable.draw(false);  // 현재 페이지 유지한 채 UI 반영
                    }
                } else {
                    alert("해당 병원 데이터를 찾을 수 없습니다.");
                }
            },
            error: function (err) {
                alert("상단 병원 목록 갱신 중 오류 발생");
                console.error(err);
            }
        });
    }


	</script>
<!-- ============================================================== -->
<!-- 기타 정보 End -->
<!-- ============================================================== -->
</body>
</html>
