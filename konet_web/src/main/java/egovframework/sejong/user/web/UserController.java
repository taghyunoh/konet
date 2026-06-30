package egovframework.sejong.user.web;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import org.springframework.http.ResponseEntity;

import egovframework.sejong.admin.service.AdminService;
import egovframework.sejong.user.model.CodeMdDTO;
import egovframework.sejong.user.model.CompConDTO;
import egovframework.sejong.user.model.CompMdDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;
import egovframework.sejong.user.service.UserService;
import egovframework.util.EgovFileScrty;

import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestBody;
import egovframework.sejong.util.ResponseObject;

@Controller
public class UserController {

	private static final Logger log = LoggerFactory.getLogger(UserController.class);


	@Resource(name = "UserService") // 서비스 선언
	private UserService svc;

	@Resource(name = "AdminService") // 환자(T_USER_TRAN) 처리용
	private AdminService adminSvc;

	    @GetMapping("/")
	    public String redirectToLogin() {
	    	return "redirect:https://allcare24.kr/login.do";
	    }

	    /* 최초 진입점 — 미로그인이면 로그인 화면, 로그인 상태면 물류 화면을 풀스크린 메인으로 직접 렌더.
	       (logistics_demo.jsp 가 자체 사이드바/헤더를 가진 완결 화면이라 상단 allCare 메뉴 셸 없이 단독 표시) */
	    @RequestMapping(value = "/konet.do")
	    public String KonetEntry(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
	    	HttpSession session = request.getSession();
	    	if (session.getAttribute("q_user_id") == null) {
	    		return ".login/base_login";
	    	}
	    	return ".raw/main/admin/logistics_demo";
	    }

	    //메인화면 호출 (환자 P → 환자 메인, 그 외 → 물류 화면 단독 메인)
		@RequestMapping(value = "/main.do")
		public String MainPage(HttpServletRequest request, ModelMap model) throws Exception {
			HttpSession session = request.getSession();
			String userGb = (String) session.getAttribute("q_admin_yn");
			if ("P".equals(userGb)) {
				return ".raw/main/patient/patient_main";
			}
			return ".raw/main/admin/logistics_demo";
		}

		/* 물류관리 화면 — 메뉴/진입 시 AJAX(loadMenuPage)로 #contentArea 에 삽입되는 단독 조각.
		   tiles .raw  → /WEB-INF/jsp/main/admin/logistics_demo.jsp (nav/top 래핑 없음) */
		@RequestMapping(value = "/admin/logistics_demo.do")
		public String LogisticsDemo(HttpServletRequest request, ModelMap model) throws Exception {
			return ".raw/main/admin/logistics_demo";
		}


		//최초 로그인 페이지 호출
		@RequestMapping(value = "/index.do")
		public String IndexPage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model) throws Exception {
		
			return ".login/base_login";
			
		}	 
		
		// 2026-05-27 정리: /test/test.do, /test/pagetest.do 제거 (대상 JSP 삭제됨)

		/* 사용자 로그인 처리 */
		@RequestMapping(value="/user/loginAct.do", method = RequestMethod.POST)
		public String UserLoginProcess(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, Model model) throws Exception {
			
			try {  
//				HashMap<String, Object> reqMap = new HashMap<String, Object>();

				dto.setUserId(EgovFileScrty.encryptPassword(dto.getUserId(), dto.getUserId()));
				
				UserDTO result = svc.userLoginCheck(dto);

				if("".equals(result.getUserId()) && result.getUserId() == null ) {
						model.addAttribute("error_code", "20000");
						model.addAttribute("error_msg", "사용자 ID 정보가 존재하지 않습니다."); 
					return "jsonView";
				}else {	
					byte[] salt = {};
					//String chkpwd = EgovFileScrty.encryptPassword(dto.getUserPw(), dto.getUserId());
					String chkpwd = EgovFileScrty.encryptPassword(dto.getUserPw(), "1234");
					//비밀번호 초기화 여부 체크
					String resetpwd = EgovFileScrty.encryptPassword("1234", dto.getUserId()); 
					HttpSession session = request.getSession(); 
					
					session.setAttribute("q_user_id"   , result.getUserId());   //사용자 ID
					session.setAttribute("q_user_nm"   , result.getUserNm());   //사용자 명
					session.setAttribute("q_admin_yn"  , result.getUserGb()); 	// 관리자 구분 'A', 의사 : D
					session.setAttribute("q_dept_nm"   , result.getDeptNm()); 	// 진료과명
					session.setAttribute("q_user_ip"   , request.getRemoteAddr().toString()); 	// 접속IP 주소
					session.setAttribute("q_screen_id" , "login");
					session.setAttribute("admingu"     , result.getUserGb());
					session.setAttribute("q_uuid"      , "8e17a341-a750-4bfb-9e6c-35d31a7308dd");
					
			
					if(!result.getUserPw().equals(chkpwd)) {
						model.addAttribute("error_code", "30000");
						model.addAttribute("error_msg" , "비밀번호를 확인하세요.!");
//					}else if(!"Y".equals(result.getUseyn())) {
//						model.addAttribute("error_code", "20000");
//						model.addAttribute("error_msg" , "사용자의 사용여부가 비활성화된 상태입니다.");
					}else {
						model.addAttribute("error_code", "00000");
						model.addAttribute("error_msg" , "");
					}
				}
				
			}catch(Exception ex) {
				log.error(" LOGIN ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "20000");
				model.addAttribute("error_msg" , "사용자 정보가 존재하지 않습니다."); 
							
			}
			
			
			return "jsonView";
		}
		
		/* ============================================================
		   KOLGSDB 로그인 — COMP_CD + USER_ID + 비밀번호
		   비밀번호 검증은 WNN_CONSULT 방식 그대로 이식
		   (PASS_WD = Base64(SHA-256(salt + 비밀번호)), salt = USER_ID)
		   로그인 성공 시 세션에 COMP_CD 등록.
		   ============================================================ */
		@RequestMapping(value="/user/loginChk.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,String> compLogin(@ModelAttribute("DTO") UserDTO dto,
				HttpSession session, HttpServletRequest request,
				javax.servlet.http.HttpServletResponse response) throws Exception {

			Map<String,String> res = new HashMap<String,String>();
			try {
				if (dto.getCompCd() == null || dto.getCompCd().trim().isEmpty()
				 || dto.getUserId() == null || dto.getUserId().trim().isEmpty()
				 || dto.getPassWd() == null || dto.getPassWd().isEmpty()) {
					res.put("error_code", "10000");
					res.put("error_mess", "회사코드/아이디/비밀번호를 입력하세요.");
					return res;
				}
				dto.setCompCd(dto.getCompCd().trim());
				dto.setUserId(dto.getUserId().trim());

				UserDTO result = svc.compLoginCheck(dto);
				if (result == null || result.getUserId() == null) {
					res.put("error_code", "10000");
					res.put("error_mess", "사용자 정보가 존재하지 않습니다.");
					return res;
				}

				// WNN_CONSULT 와 동일한 2-way 비교 (salt=userId / salt=userId.toLowerCase 후 URL-base64)
				String chkpwd1  = EgovFileScrty.encryptPassword(dto.getPassWd(), dto.getUserId());
				String inputEnc = EgovFileScrty.encryptPassword(dto.getPassWd(), dto.getUserId().toLowerCase());
				String chkpwd2  = Base64.getUrlEncoder().encodeToString(inputEnc.getBytes(StandardCharsets.UTF_8));

				if (!chkpwd1.equals(result.getPassWd()) && !chkpwd2.equals(result.getPassWd())) {
					res.put("error_code", "20000");
					res.put("error_mess", "비밀번호를 확인하세요.");
					return res;
				}
				// 사용여부: 명시적으로 'N' 인 경우에만 차단 (Y/NULL/공백은 허용)
				if ("N".equals(result.getUseYn())) {
					res.put("error_code", "10002");
					res.put("error_mess", "사용자 사용여부를 확인하세요.");
					return res;
				}

				// ★ 로그인 성공 → COMP_CD 등 세션 등록
				session.setAttribute("s_comp_cd", result.getCompCd());     // ★ COMP_CD
				session.setAttribute("s_comp_nm", result.getCompNm());
				session.setAttribute("s_user_id", result.getUserId());
				session.setAttribute("s_user_nm", result.getUserNm());
				session.setAttribute("s_main_gu", result.getMainGu());     // 사용자구분
				session.setAttribute("s_admin_yn", result.getCommstYn());  // ★ 관리자여부(구 WINNER_YN→COMMST_YN)
				session.setAttribute("s_conn_ip", request.getRemoteAddr());
				// 기존 진입 가드(KonetEntry/main.do)가 q_user_id 로 미로그인 판정하므로 함께 세팅
				session.setAttribute("q_user_id", result.getUserId());
				session.setAttribute("q_user_nm", result.getUserNm());

				// compcd.jsp(winmc commons.js)가 쿠키(getCookie)로 등록자/IP/회사코드를 참조 → 쿠키도 심음
				String connIp = request.getRemoteAddr();
				addCookie(response, "s_userid", result.getUserId());
				addCookie(response, "s_connip", connIp);
				addCookie(response, "s_compcd", result.getCompCd());

				res.put("login_Comp", result.getCompNm());
				res.put("login_User", result.getUserNm());
				res.put("login_AdminYn", result.getCommstYn());   // 관리자여부
				res.put("error_code", "00000");
				res.put("error_mess", "정상적 처리 되었습니다.");
				return res;

			} catch (Exception ex) {
				log.error("compLogin ERROR: " + ex.getMessage(), ex);
				res.put("error_code", "90001");
				res.put("error_mess", "로그인 처리 중 오류가 발생했습니다.");
				return res;
			}
		}

		/* 사용자 로그아웃 처리 */
		@RequestMapping(value="/user/loginOutAct.do")
		 public String UserLogOutProcess(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model) throws Exception {

			HttpSession session = request.getSession();
			//세션 초기화
			session.invalidate();

			return "forward:/login.do";
		}

		// =====================================================================
		// 환자(T_USER_TRAN, USER_GB='P') 로그인 / 회원가입
		// =====================================================================

		/** 환자 로그인 페이지 — 통합 로그인으로 리다이렉트 (호환 유지) */
		@RequestMapping(value = "/patient/login.do")
		public String patientLoginPage() {
			return "redirect:/login.do";
		}

		/** 환자 회원가입 페이지 — raw 단독 JSP (tiles wrap 없음, InternalResourceViewResolver 처리) */
		@RequestMapping(value = "/patient/register.do")
		public String patientRegisterPage() {
			return ".raw/login/patient_register";
		}


		@RequestMapping(value = "/getSignList.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseObject getSignList(@RequestBody Map<String, Object> map) throws Exception {
			ResponseObject res = new ResponseObject();
			try {
				List<SjgnDTO> list = svc.getSignList(map);
				res.IsSucceed = true;
				res.Data = list;
			} catch (Exception ex) {
				// T_SIGN_MST 가 아직 없거나 SQL 오류 시에도 폼을 막지 않도록 빈 목록으로 정상 응답.
				// 클라이언트는 "약관이 준비 중입니다." 안내만 표시.
				log.warn("getSignList — 약관 마스터 조회 실패 (테이블 미설정 가능): " + ex.getMessage());
				res.IsSucceed = true;
				res.Data = new java.util.ArrayList<SjgnDTO>();
			}
			return res;
		}

		/**
		 * 통합 로그인 — 단일 폼에서 의료진(T_ADMIN_MST) + 환자(T_USER_TRAN) 자동 구분
		 *
		 * 입력: { idOrPhone: "kim123 또는 01012345678", password: "1234" }
		 *
		 * 알고리즘
		 *   1) T_ADMIN_MST 시도: USER_ID = SHA256(idOrPhone || idOrPhone) Base64 매칭
		 *      → 매칭되면 USER_PW = SHA256("1234" || password) 비교 → 성공 시 의사/관리자 세션
		 *   2) 1)이 실패하면 T_USER_TRAN(USER_GB='P') 시도: PHONE = idOrPhone
		 *      → 매칭되면 USER_PW = SHA256(phone || password) 비교 → 성공 시 환자 세션
		 *   3) 둘 다 실패하면 거부
		 *
		 * 세션 q_admin_yn = 'A'/'D' (의료진) 또는 'P' (환자)

		/** 환자 식사 기록 화면 — raw 단독 JSP */
		@RequestMapping(value = "/patient/food.do")
		public String patientFoodPage(HttpSession session) {
			if (session.getAttribute("userUuid") == null) return "redirect:/login.do";
			return ".raw/main/patient/patient_food";
		}

		/** 환자 운동 기록 화면 — raw 단독 JSP */
		@RequestMapping(value = "/patient/exer.do")
		public String patientExerPage(HttpSession session) {
			if (session.getAttribute("userUuid") == null) return "redirect:/login.do";
			return ".raw/main/patient/patient_exer";
		}

		/* 사용자 비밀번호변경 화면 */
		@RequestMapping(value="/popup/pwdchg.do")
		public String UserPwdChangePage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			 
			 
			return ".login/APLO_03";
		}
		/* 로그인한 사용자 비밀번호변경 화면 */
		@RequestMapping(value="/popup/Hpwdchg.do")
		public String UserHPwdChangePage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			 
			 
			return ".login/Hpwdchg";
		}
		/* 사용자 비밀번호 초기화 화면 */
		@RequestMapping(value="/popup/pwdclear.do")
		public String UserPwdClearPage(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			 
			
			return ".login/APLO_02";
		}
		

		/* 사용자 비밀번호 초기화 처리 — KOLGSDB(TBL_USER_MST), '1234' 로 초기화 (salt=userId) */
		@RequestMapping(value="/json/user/pwdresetAct.do")
		public String UserPwdResetSave(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {

			try {
				if (dto.getCompCd() == null || dto.getCompCd().trim().isEmpty()
				 || dto.getUserId() == null || dto.getUserId().trim().isEmpty()) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "회사코드와 사용자 ID를 입력하세요.");
					return "jsonView";
				}
				dto.setCompCd(dto.getCompCd().trim());
				dto.setUserId(dto.getUserId().trim());

				UserDTO result = svc.compUserInfo(dto);
				if(result == null || result.getUserId() == null) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}
				// '1234' 로 초기화 — WNN_CONSULT 표준 형식: base64url(SHA-256(아이디소문자+"1234"))
				String resetEnc = EgovFileScrty.encryptPassword("1234", dto.getUserId().toLowerCase());
				dto.setEncUserPwd(Base64.getUrlEncoder().encodeToString(resetEnc.getBytes(StandardCharsets.UTF_8)));
				int chk = svc.compPwdUpdate(dto);
				if(chk > 0) {
					model.addAttribute("error_code", "0");
					model.addAttribute("error_msg" , "");
				}else {
					model.addAttribute("error_code", "10000");
					model.addAttribute("error_msg" , "사용자 비밀번호 초기화 실패하였습니다.");
				}
			}catch(Exception ex) {
				log.error(" UserPwdResetSave ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "20000");
				model.addAttribute("error_msg" , "사용자 비밀번호 초기화 실패하였습니다.");

			}
			//
			return "jsonView";
		}
		

		/* 사용자 비밀번호변경 처리 */
		@RequestMapping(value="/json/user/pwdchgAct.do")
		public String UserPwdChangeSave(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model)
				throws Exception {  
			
			try {
				if (dto.getCompCd() == null || dto.getCompCd().trim().isEmpty()
				 || dto.getUserId() == null || dto.getUserId().trim().isEmpty()) {
					model.addAttribute("error_code", "20000");
					model.addAttribute("error_msg" , "회사코드와 사용자 ID를 입력하세요.");
					return "jsonView";
				}
				dto.setCompCd(dto.getCompCd().trim());
				dto.setUserId(dto.getUserId().trim());

				UserDTO result = svc.compUserInfo(dto);
				if(result == null || result.getUserId() == null){
					model.addAttribute("error_code", "20000");
					model.addAttribute("error_msg" , "비밀번호 변경할 사용자 정보가 존재하지 않습니다.");
					return "jsonView";
				}

				// 현재 비밀번호 검증 (로그인과 동일한 2-way, salt=userId)
				String chk1  = EgovFileScrty.encryptPassword(dto.getUserPw(), dto.getUserId());
				String enc   = EgovFileScrty.encryptPassword(dto.getUserPw(), dto.getUserId().toLowerCase());
				String chk2  = Base64.getUrlEncoder().encodeToString(enc.getBytes(StandardCharsets.UTF_8));
				if(!chk1.equals(result.getPassWd()) && !chk2.equals(result.getPassWd())) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "현재 비밀번호를 확인하세요.!");
					return "jsonView";
				}

				if(dto.getBfUserPwd() == null || dto.getBfUserPwd().isEmpty()) {
					model.addAttribute("error_code", "30000");
					model.addAttribute("error_msg" , "변경할 비밀번호를 입력하세요.");
					return "jsonView";
				}
				// 신규 비밀번호 저장 — WNN_CONSULT 표준 형식: base64url(SHA-256(아이디소문자+신규비번))
				String newEnc = EgovFileScrty.encryptPassword(dto.getBfUserPwd(), dto.getUserId().toLowerCase());
				dto.setEncUserPwd(Base64.getUrlEncoder().encodeToString(newEnc.getBytes(StandardCharsets.UTF_8)));
				int chk = svc.compPwdUpdate(dto);

				if(chk > 0) {
					model.addAttribute("error_code", "0");
					model.addAttribute("error_msg" , "");
				}else {
					model.addAttribute("error_code", "10000");
					model.addAttribute("error_msg" , "사용자 비밀번호 변경 실패하였습니다.");
				}
			}catch(Exception ex) {
				log.error(" UserPwdChangeSave ERROR ! : "+ ex.getMessage());
				model.addAttribute("error_code", "10000");
				model.addAttribute("error_msg" , "사용자 비밀번호 변경 실패하였습니다.");

			}
			//
			return "jsonView";
		}

		// ============================================================
		// 회사/계약/사용자 관리 (compcd.jsp = hospcd.jsp 포팅, KOLGSDB)
		//   화면 진입은 세션 s_comp_cd 로 로그인 확인
		// ============================================================
		@RequestMapping(value="/mangr/compcd.do")
		public String compcd(HttpSession session, ModelMap model) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/compcd";
		}

		/* ---- 회사 ---- */
		@RequestMapping(value="/user/compCdList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> compCdList(@ModelAttribute("DTO") CompMdDTO dto, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return null;
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selCompCdList(dto));
			return response;
		}

		@RequestMapping(value="/user/compCdInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> compCdInsert(@RequestBody List<CompMdDTO> data) {
			try {
				for (CompMdDTO dto : data) {
					if ("Y".equals(svc.CompCdMstDupChk(dto))) return ResponseEntity.status(400).body(dto.getKeyCompCd());
					svc.insertCompCdMst(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/user/compCdUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> compCdUpdate(@RequestBody List<CompMdDTO> data) {
			try {
				for (CompMdDTO dto : data) { svc.updateCompCdMst(dto); svc.insertCompCdMst(dto); }
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/user/compCdDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> compCdDelete(@RequestBody List<CompMdDTO> data) {
			try {
				for (CompMdDTO dto : data) { dto.setCompCd(dto.getKeyCompCd()); svc.updateCompCdMst(dto); }
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ---- 출고장(발주현황표) 엑셀 업로드 저장 ----
		   · 논리키 = DLV_DT(납기일자). 납기일자별로 1배치 — 기존 활성배치 이력마감 후 JOB_SEQ+1 신규 INSERT
		   · "기존화면 자료 초기화 후 생성" = 기존 활성배치 ACTION_YN='N' 처리(이력보존) 후 신규 적재
		   · 날짜('-' 포함 yyyy-mm-dd)는 매퍼에서 REPLACE 로 '-' 제거하여 NVARCHAR(10) 저장 */
		@RequestMapping(value="/shipout/saveShipoutMst.do", method = RequestMethod.POST)
		public ResponseEntity<String> saveShipoutMst(@RequestBody List<egovframework.sejong.user.model.ShipoutDTO> rows,
		                                             HttpServletRequest request, HttpSession session) {
			try {
				if (rows == null || rows.isEmpty()) return ResponseEntity.ok("0");

				String regUser = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				               : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : "");
				String regIp   = request.getRemoteAddr();

				// 납기일자(DLV_DT)별로 묶어 각 일자를 1배치로 저장 (물류센터/사업장은 키 아님)
				java.util.LinkedHashMap<String, java.util.List<egovframework.sejong.user.model.ShipoutDTO>> groups
				    = new java.util.LinkedHashMap<String, java.util.List<egovframework.sejong.user.model.ShipoutDTO>>();
				for (egovframework.sejong.user.model.ShipoutDTO r : rows) {
					String key = (r.getDlvDt() == null ? "" : r.getDlvDt());
					java.util.List<egovframework.sejong.user.model.ShipoutDTO> g = groups.get(key);
					if (g == null) { g = new java.util.ArrayList<egovframework.sejong.user.model.ShipoutDTO>(); groups.put(key, g); }
					g.add(r);
				}

				int total = 0;
				for (java.util.List<egovframework.sejong.user.model.ShipoutDTO> grp : groups.values()) {
					// 1) 해당 납기일자 기존 활성배치 이력마감(삭제이력)  2) 신규 JOB_SEQ  3) 그룹 전체행 INSERT
					egovframework.sejong.user.model.ShipoutDTO head = grp.get(0);
					head.setUpdUser(regUser);
					head.setUpdIp(regIp);
					svc.markShipoutHistory(head);

					int jobSeq = svc.getShipoutNextJobSeq(head);
					int seq = 0;
					for (egovframework.sejong.user.model.ShipoutDTO r : grp) {
						r.setJobSeq(jobSeq);
						r.setActionYn("Y");
						if (r.getRowNo() == null) r.setRowNo(seq + 1);
						r.setRegUser(regUser);
						r.setRegIp(regIp);
						svc.insertShipoutMst(r);
						seq++; total++;
					}
				}
				return ResponseEntity.ok(String.valueOf(total));
			} catch (Exception e) {
				log.error(" saveShipoutMst ERROR ! : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/* 출고현황표 화면 — 선택한 납기일자(단일)의 활성배치 조회 (JSON: {data:[...]}) */
		@RequestMapping(value="/shipout/selectShipoutMst.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutMst(@ModelAttribute("DTO") egovframework.sejong.user.model.ShipoutDTO dto,
		                                            HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutMst(dto));
			return response;
		}

		/* ============================================================
		   사업장 분류 마스터 (TBL_BIZI_MST)
		   · 출고현황표 분류용 목록조회 + 업로드 자동등록(없을때만) + 관리화면 CRUD
		   ============================================================ */
		/* 목록 (분류 로딩 / 관리 그리드 공용, JSON: {data:[...]}) */
		@RequestMapping(value={"/shipout/selectBiziMst.do","/mangr/biziList.do"}, method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectBiziMst() throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectBiziMst());
			return response;
		}

		/* 업로드 자동등록 — 사업장코드가 없을 때만 신규저장(insert if absent) */
		@RequestMapping(value="/shipout/saveBiziAuto.do", method = RequestMethod.POST)
		public ResponseEntity<String> saveBiziAuto(@RequestBody List<egovframework.sejong.user.model.BiziDTO> rows,
		                                           HttpServletRequest request, HttpSession session) {
			try {
				if (rows == null || rows.isEmpty()) return ResponseEntity.ok("0");
				String regUser = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				               : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : "");
				String regIp = request.getRemoteAddr();
				int n = 0;
				for (egovframework.sejong.user.model.BiziDTO r : rows) {
					if (r.getBizCd() == null || r.getBizCd().trim().isEmpty()) continue;
					r.setRegUser(regUser); r.setRegIp(regIp);
					n += svc.insertBiziIfAbsent(r);
				}
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) {
				log.error(" saveBiziAuto ERROR ! : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/* 관리화면 페이지 (사업장 분류 정보 수정/관리) */
		@RequestMapping(value="/mangr/bizimst.do")
		public String bizimst(HttpSession session, ModelMap model) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/bizimst";
		}

		/* 관리화면 — 신규(없을때만) */
		@RequestMapping(value="/mangr/biziInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> biziInsert(@RequestBody List<egovframework.sejong.user.model.BiziDTO> data,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.sejong.user.model.BiziDTO d : data) {
					if (d.getBizCd() == null || d.getBizCd().trim().isEmpty()) continue;
					d.setRegUser(u); d.setRegIp(ip); n += svc.insertBiziIfAbsent(d);
				}
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" biziInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 관리화면 — 사업장명 수정 */
		@RequestMapping(value="/mangr/biziUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> biziUpdate(@RequestBody List<egovframework.sejong.user.model.BiziDTO> data,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.sejong.user.model.BiziDTO d : data) { d.setUpdUser(u); d.setUpdIp(ip); n += svc.updateBiziMst(d); }
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" biziUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 관리화면 — 삭제(비활성화) */
		@RequestMapping(value="/mangr/biziDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> biziDelete(@RequestBody List<egovframework.sejong.user.model.BiziDTO> data,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.sejong.user.model.BiziDTO d : data) { d.setUpdUser(u); d.setUpdIp(ip); n += svc.deleteBiziMst(d); }
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" biziDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ---- 계약 ---- */
		@RequestMapping(value="/user/compContList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> compContList(@ModelAttribute("DTO") CompConDTO dto, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return null;
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectCompContList(dto));
			return response;
		}

		@RequestMapping(value="/user/gethompContList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> getCompContList(@ModelAttribute("DTO") CompConDTO dto, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return null;
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.getCompContList(dto));
			return response;
		}

		@RequestMapping(value="/user/compContInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> compContInsert(@RequestBody List<CompConDTO> data) {
			try {
				for (CompConDTO dto : data) {
					if ("Y".equals(svc.CompContDupChk(dto))) return ResponseEntity.status(400).body(dto.getCompCd());
					svc.insertCompCont(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/user/compContUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> compContUpdate(@RequestBody List<CompConDTO> data) {
			try {
				for (CompConDTO dto : data) { svc.updateCompCont(dto); svc.insertCompCont(dto); }
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/user/compContDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> compContDelete(@RequestBody List<CompConDTO> data) {
			try {
				for (CompConDTO dto : data) {
					dto.setCompCd(dto.getKeycompCd());
					dto.setStartDt(dto.getKeystartDt());
					dto.setEndDt(dto.getKeyendDt());
					svc.updateCompCont(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ---- 사용자 ---- */
		@RequestMapping(value="/user/compuserList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> compuserList(@ModelAttribute("DTO") UserDTO dto, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return null;
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.compUserList(dto));
			return response;
		}

		@RequestMapping(value="/user/compUserInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> compUserInsert(@RequestBody List<UserDTO> data) {
			try {
				for (UserDTO dto : data) {
					dto.setEncPassWd("");
					if (dto.getBfPassWd() != null && !dto.getBfPassWd().isEmpty()) {
						String enc = EgovFileScrty.encryptPassword(dto.getBfPassWd(), dto.getUserId().trim().toLowerCase());
						dto.setEncPassWd(Base64.getUrlEncoder().encodeToString(enc.getBytes(StandardCharsets.UTF_8)));
					}
					if ("Y".equals(svc.CompUserDupChk(dto))) return ResponseEntity.status(400).body(dto.getCompCd());
					svc.insertCompUser(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/user/compUserUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> compUserUpdate(@RequestBody List<UserDTO> data) {
			try {
				for (UserDTO dto : data) {
					svc.updateCompUser(dto);
					dto.setEncPassWd("");
					if (dto.getBfPassWd() != null && !dto.getBfPassWd().isEmpty()) {
						String enc = EgovFileScrty.encryptPassword(dto.getBfPassWd(), dto.getUserId().trim().toLowerCase());
						dto.setEncPassWd(Base64.getUrlEncoder().encodeToString(enc.getBytes(StandardCharsets.UTF_8)));
					}
					svc.insertCompUser(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/user/compUserDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> compUserDelete(@RequestBody List<UserDTO> data) {
			try {
				for (UserDTO dto : data) {
					dto.setCompCd(dto.getKeyurcompCd());
					dto.setStartDt(dto.getKeyurstartDt());
					dto.setUserId(dto.getKeyuruserId());
					svc.updateCompUser(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/user/compuseridupchk.do", method = RequestMethod.POST)
		public ResponseEntity<String> compUseridupchk(@RequestBody UserDTO dto) {
			try {
				if ("Y".equals(svc.CompUseridDupChk(dto))) return ResponseEntity.status(400).body("기존사용아이디가 존재합니다.");
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body("서버 오류: " + e.getMessage()); }
		}

		/* 공통코드 콤보 — compcd.jsp comm_Check() : TBL_CODE_DTL */
		@RequestMapping(value="/base/commList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> baseCommList(HttpServletRequest request) throws Exception {
			String[] gb = request.getParameterValues("listGb[]");
			if (gb == null) gb = request.getParameterValues("listGb");
			String[] cd = request.getParameterValues("listCd[]");
			if (cd == null) cd = request.getParameterValues("listCd");
			Map<String,Object> param = new HashMap<String,Object>();
			param.put("listGb", gb == null ? null : java.util.Arrays.asList(gb));
			param.put("listCd", cd == null ? null : java.util.Arrays.asList(cd));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectCommCodeList(param));
			return res;
		}

		// ============================================================
		// 공통코드 관리 (codecd.jsp = commcd.jsp 포팅, KOLGSDB TBL_CODE_MST/DTL)
		// ============================================================
		@RequestMapping(value="/base/commcd.do")
		public String commcd(HttpSession session, ModelMap model) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/base/codecd";
		}

		/* ---- 대표코드 ---- */
		@RequestMapping(value="/base/commMstList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> commMstList(@ModelAttribute("DTO") CodeMdDTO dto, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return null;
			Map<String,Object> r = new HashMap<String,Object>();
			r.put("data", svc.codeMstList(dto));
			return r;
		}
		@RequestMapping(value="/base/commMstInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> commMstInsert(@RequestBody List<CodeMdDTO> data) {
			try {
				for (CodeMdDTO dto : data) {
					if ("Y".equals(svc.codeMstDupChk(dto))) return ResponseEntity.status(400).body(dto.getCodeCd());
					svc.insertCodeMst(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/base/commMstUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> commMstUpdate(@RequestBody List<CodeMdDTO> data) {
			try {
				for (CodeMdDTO dto : data) { svc.updateCodeMst(dto); svc.insertCodeMst(dto); }
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value={"/base/commMstDelete.do","/user/commMstDelete.do"}, method = RequestMethod.POST)
		public ResponseEntity<String> commMstDelete(@RequestBody List<CodeMdDTO> data) {
			try {
				for (CodeMdDTO dto : data) { dto.setCodeCd(dto.getKeycodeCd()); svc.updateCodeMst(dto); }
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ---- 상세코드 ---- */
		@RequestMapping(value="/base/commDtlList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> commDtlList(@ModelAttribute("DTO") CodeMdDTO dto, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return null;
			Map<String,Object> r = new HashMap<String,Object>();
			r.put("data", svc.codeDtlList(dto));
			return r;
		}
		@RequestMapping(value="/base/CommDtlInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> CommDtlInsert(@RequestBody List<CodeMdDTO> data) {
			try {
				for (CodeMdDTO dto : data) {
					if ("Y".equals(svc.codeDtlDupChk(dto))) return ResponseEntity.status(400).body(dto.getCodeCd());
					svc.insertCodeDtl(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/base/CommDtlUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> CommDtlUpdate(@RequestBody List<CodeMdDTO> data) {
			try {
				for (CodeMdDTO dto : data) { svc.updateCodeDtl(dto); svc.insertCodeDtl(dto); }
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/base/CommDtlDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> CommDtlDelete(@RequestBody List<CodeMdDTO> data) {
			try {
				for (CodeMdDTO dto : data) {
					dto.setCodeCd(dto.getKeycodeCd());
					dto.setCodeGb(dto.getKeycodeGb());
					dto.setSubCode(dto.getKeysubCode());
					svc.updateCodeDtl(dto);
				}
				return ResponseEntity.ok("OK");
			} catch (Exception e) { return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* compcd.jsp(winmc) 호환용 쿠키 — 1일 유지 */
		private void addCookie(javax.servlet.http.HttpServletResponse response, String name, String value) {
			javax.servlet.http.Cookie c = new javax.servlet.http.Cookie(name, value == null ? "" : value);
			c.setPath("/");
			c.setMaxAge(60 * 60 * 24);
			response.addCookie(c);
		}
}
