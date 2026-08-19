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
import org.springframework.web.bind.annotation.RequestParam;
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

	    @RequestMapping(value = "/konet.do")
	    public String KonetEntry(HttpServletRequest request) throws Exception {
	        return ".login/base_login";   // 정문은 항상 로그인 → 성공 시 /main.do 로 이동
	    }

	    //메인화면 호출 (환자 P → 환자 메인, 그 외 → 물류 화면 단독 메인)
		@RequestMapping(value = "/main.do")
		public String MainPage(HttpServletRequest request, ModelMap model) throws Exception {
			HttpSession session = request.getSession();
			if (session.getAttribute("q_user_id") == null) return ".login/base_login";   // 미로그인 진입 차단(konet.do 와 동일)
			String userGb = (String) session.getAttribute("q_admin_yn");
			return ".raw/main/admin/logistics_demo2";   // 셸(사이드바) = logistics_demo2.jsp — 로그인 후 메인
		}

		/* 출고현황표(데시보드2) = logistics_demo1.jsp — 셸(logistics_demo2.jsp)의 사이드메뉴에서
		   iframe 패널(logiFrame 'shipstatus2')로 로드되는 단독 화면. (파일명: demo1 = 대시보드2 내용) */
		@RequestMapping(value = "/admin/logistics_demo1.do")
		public String LogisticsDemo2(HttpServletRequest request, ModelMap model) throws Exception {
			if (request.getSession().getAttribute("q_user_id") == null) return ".login/base_login";   // 미로그인 직접접근 차단(iframe 조각)
			return ".raw/main/admin/logistics_demo1";
		}

		/* 물류관리 셸(사이드바) = logistics_demo2.jsp — 로그인 후 /main.do 및 상단 '물류관리' 버튼
		   (header.jsp loadMenuPage)로 로드되는 메인 화면. tiles .raw (nav/top 래핑 없음).
		   (파일명: demo2 = 셸 내용. 대시보드2는 이 화면 iframe 안에서 demo1.do 로 로드) */
		@RequestMapping(value = "/admin/logistics_demo2.do")
		public String LogisticsDemo(HttpServletRequest request, ModelMap model) throws Exception {
			if (request.getSession().getAttribute("q_user_id") == null) return ".login/base_login";   // 미로그인 직접접근 차단
			return ".raw/main/admin/logistics_demo2";
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
				// ★ 관리자여부 = 회사(TBL_COMP_MST.COMMST_YN) 기준 (2026-07-31 변경 — 종전엔 TBL_USER_MST.COMMST_YN)
				//   'Y' 회사만 회사/사용자 관리 메뉴 노출 + 전체 회사코드 조회 허용
				String adminYn = "Y".equals(result.getCompAdminYn()) ? "Y" : "N";
				session.setAttribute("s_admin_yn", adminYn);
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
				res.put("login_AdminYn", adminYn);   // 관리자여부(회사 COMMST_YN 기준)
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

		/* 사용자 로그아웃 처리 — 사이드바 하단 '로그아웃' 메뉴(logistics_demo2.jsp logiLogout)·header.jsp 공용.
		   ※ /login.do 는 이 컨텍스트에 매핑이 없어 종전 forward:/login.do 는 404 였다(2026-07-31 수정)
		      → 정문(/konet.do = 로그인 화면)으로 리다이렉트. */
		@RequestMapping(value="/user/loginOutAct.do")
		 public String UserLogOutProcess(@ModelAttribute("DTO") UserDTO dto, HttpServletRequest request, ModelMap model) throws Exception {

			HttpSession session = request.getSession();
			//세션 초기화
			session.invalidate();

			return "redirect:/konet.do";
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
			// ★ 회사/사용자 관리 = 관리자 회사(TBL_COMP_MST.COMMST_YN='Y')만 — 메뉴 숨김 + 직접 URL 접근도 차단
			if (!"Y".equals(session.getAttribute("s_admin_yn"))) return "redirect:/main.do";
			return ".raw/main/mangr/compcd";
		}

		/* ---- 회사 ---- */
		@RequestMapping(value="/user/compCdList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> compCdList(@ModelAttribute("DTO") CompMdDTO dto, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return null;
			// ★ 관리자 회사(COMMST_YN='Y')가 특정 회사코드 없이 조회하면 전체 회사 목록.
			//   (멀티테넌트 인터셉터가 빈 compCd 를 자기 회사로 채우므로 allYn 으로 필터를 우회)
			//   비관리자는 인터셉터 주입 그대로 → 자기 회사 1건만.
			if ("Y".equals(session.getAttribute("s_admin_yn"))
			 && (dto.getCompCd() == null || dto.getCompCd().trim().isEmpty())) {
				dto.setAllYn("Y");
			}
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
		   · 논리키 = (DLV_DT 납품일자 + DC_CD 물류센터코드). 조합별 1배치 — 기존 활성배치 이력마감 후 JOB_SEQ+1 신규 INSERT
		   · ★SHPOUT_DT(출고일자)는 키에서 제외(2026-07-27 요청). 종전 키에는 출고일자가 있어, 같은 납품일자·출고장을
		     다른 출고일자로 다시 올리면 기존 자료가 활성인 채 남아 두 배치가 함께 잡혔다(이중계상). 이제 대체된다.
		     출고일자는 저장·조회 컬럼으로는 그대로 쓴다(화면 조회 기준은 여전히 SHPOUT_DT).
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

				// (납품일자 DLV_DT + 물류센터 DC_CD) 복합키로 묶어 각 조합을 1배치로 저장 (출고일자·사업장은 키 아님)
				java.util.LinkedHashMap<String, java.util.List<egovframework.sejong.user.model.ShipoutDTO>> groups
				    = new java.util.LinkedHashMap<String, java.util.List<egovframework.sejong.user.model.ShipoutDTO>>();
				for (egovframework.sejong.user.model.ShipoutDTO r : rows) {
					String key = (r.getDlvDt() == null ? "" : r.getDlvDt())
					           + "|" + (r.getDcCd() == null ? "" : r.getDcCd());
					java.util.List<egovframework.sejong.user.model.ShipoutDTO> g = groups.get(key);
					if (g == null) { g = new java.util.ArrayList<egovframework.sejong.user.model.ShipoutDTO>(); groups.put(key, g); }
					g.add(r);
				}

				int total = 0;
				java.util.LinkedHashSet<String> syncDates = new java.util.LinkedHashSet<String>();
				for (java.util.List<egovframework.sejong.user.model.ShipoutDTO> grp : groups.values()) {
					// 0) 이력마감으로 사라질 기존 활성배치의 출고일자 수집  1) 같은 (납품일자,물류센터) 기존 활성배치 이력마감(삭제이력)
					// 2) 신규 JOB_SEQ  3) 그룹 전체행 INSERT
					egovframework.sejong.user.model.ShipoutDTO head = grp.get(0);
					head.setUpdUser(regUser);
					head.setUpdIp(regIp);
					// ★출고일자가 키에서 빠지면서 '옛 배치의 출고일자 ≠ 새 배치의 출고일자' 가 가능해졌다.
					//   그 경우 옛 출고일자의 재고원장 O행이 그대로 남으므로, 마감 전에 미리 받아 함께 재동기화한다.
					java.util.List<String> oldDts = svc.selectShipoutActiveShpoutDts(head);
					//   ※ DB 값은 'yyyymmdd', 화면에서 온 값은 'yyyy-mm-dd' — 같은 날이 두 번 돌지 않게 '-' 를 떼어 담는다.
					if (oldDts != null) for (String d : oldDts) if (d != null && !d.trim().isEmpty()) syncDates.add(d.trim().replace("-", ""));
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
					/* ★거래처 코드 → 우리 품목 해석 (2026-08-01). 반드시 INSERT 뒤·재고연동(A) 앞.
					   · 원본 ITEM_CD/ITEM_NM 은 건드리지 않는다. PROD_SEQ 칸만 채운다.
					   · 행마다 조회하지 않는다 — 배치 단위 UPDATE 한 문장(resolveShipoutProd).
					   · 매핑이 없으면 PROD_SEQ 가 NULL 로 남고, 그 행은 재고연동에서 자연히 빠진다
					     (= 미매핑 보류). 나중에 매핑을 걸면 saveXref 가 소급으로 채운다. */
					egovframework.sejong.user.model.ProdXrefDTO rx = new egovframework.sejong.user.model.ProdXrefDTO();
					rx.setJobSeq(Long.valueOf(jobSeq));
					rx.setDlvDt(head.getDlvDt());
					rx.setDcCd(head.getDcCd());
					svc.resolveShipoutProd(rx);

					// 새 배치의 출고일자 — 그룹키에 출고일자가 없으므로 한 그룹 안에 두 날짜가 섞일 여지가 있다(행 단위로 모은다)
					for (egovframework.sejong.user.model.ShipoutDTO r : grp) {
						if (r.getShpoutDt() != null && !r.getShpoutDt().trim().isEmpty()) syncDates.add(r.getShpoutDt().trim().replace("-", ""));
					}
				}
				// (A) 출고→재고 자동연동 : 저장된 출고일자별로 원장 O행 재동기화 후 전체 현재고 재집계
				//     (재고 동기화 실패가 출고 저장 자체를 롤백하지 않도록 별도 try — 실패 시 로그만)
				try {
					for (String d : syncDates) svc.syncShipoutLedgerDate(d, regUser, regIp);
					if (!syncDates.isEmpty()) svc.recalcStockMstAll(regUser, regIp);
				} catch (Exception se) {
					log.error(" saveShipoutMst 재고연동 WARN : " + se.getMessage());
				}
				return ResponseEntity.ok(String.valueOf(total));
			} catch (Exception e) {
				log.error(" saveShipoutMst ERROR ! : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/* ---- 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 ----
		   · 원천 = 출고장 프로그램이 출력하는 엑셀(발주번호·발주항번·입고량·단가·매입금액)
		   · ★엑셀은 '출고장 기준' → 우리 기준으로 환산해 받는다
		       엑셀 '입고량'=우리 출고량(outQty) / '단가'=우리 판매단가(salePrice) / '매입금액'=우리 매출액(saleAmt)
		   · 논리키 = (DLV_DT 납품일자 + DC_NM 출고장). 파일 1개 = 1배치 — 기존 활성배치 이력마감 후 JOB_SEQ+1 신규 INSERT
		   · 출고장(평택 등)은 엑셀 안에 없어 화면(파일명 파싱)에서 dcNm 으로 실어 보낸다 */
		//   · 응답은 반드시 Map(JSON 객체)으로 — ResponseEntity<String> 로 JSON 문자열을 담으면
		//     Jackson 이 그 문자열을 한 번 더 감싸서 "{\"saved\":..}" 로 나가고, 화면의 JSON.parse 가 객체가 아닌
		//     문자열을 받아 saved/price 가 전부 0으로 보인다(실제 저장은 정상인데 토스트만 0). 그 함정 회피.
		@RequestMapping(value="/sales/saveSalesMst.do", method = RequestMethod.POST)
		@ResponseBody
		public ResponseEntity<Map<String,Object>> saveSalesMst(@RequestBody List<egovframework.sejong.user.model.SalesDTO> rows,
		                                           HttpServletRequest request, HttpSession session) {
			Map<String,Object> res = new java.util.HashMap<String,Object>();
			try {
				if (rows == null || rows.isEmpty()) {
					res.put("saved", 0); res.put("price", 0); res.put("none", 0); res.put("skip", 0);
					return ResponseEntity.ok(res);
				}

				String regUser = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				               : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : "");
				String regIp   = request.getRemoteAddr();

				// (납품일자 DLV_DT + 출고장 DC_NM) 복합키로 묶어 각 조합을 1배치로 저장
				java.util.LinkedHashMap<String, java.util.List<egovframework.sejong.user.model.SalesDTO>> groups
				    = new java.util.LinkedHashMap<String, java.util.List<egovframework.sejong.user.model.SalesDTO>>();
				for (egovframework.sejong.user.model.SalesDTO r : rows) {
					String key = (r.getDlvDt() == null ? "" : r.getDlvDt())
					           + "|" + (r.getDcNm() == null ? "" : r.getDcNm());
					java.util.List<egovframework.sejong.user.model.SalesDTO> g = groups.get(key);
					if (g == null) { g = new java.util.ArrayList<egovframework.sejong.user.model.SalesDTO>(); groups.put(key, g); }
					g.add(r);
				}

				int total = 0;
				for (java.util.List<egovframework.sejong.user.model.SalesDTO> grp : groups.values()) {
					// 1) 같은 (납품일자,출고장) 기존 활성배치 이력마감  2) 신규 JOB_SEQ  3) 그룹 전체행 INSERT
					egovframework.sejong.user.model.SalesDTO head = grp.get(0);
					head.setUpdUser(regUser);
					head.setUpdIp(regIp);
					svc.markSalesHistory(head);

					int jobSeq = svc.getSalesNextJobSeq(head);
					int seq = 0;
					for (egovframework.sejong.user.model.SalesDTO r : grp) {
						r.setJobSeq(jobSeq);
						r.setActionYn("Y");
						if (r.getRowNo() == null) r.setRowNo(seq + 1);
						r.setRegUser(regUser);
						r.setRegIp(regIp);
						svc.insertSalesMst(r);
						seq++; total++;
					}
					/* ★거래처 코드 → 우리 품목 해석 (2026-08-01) — 발주현황표와 같은 처리.
					   정산서에는 규격·단가·면과세가 있어 매핑 '검증' 의 주 근거가 된다.
					   여기서 PROD_SEQ 가 채워지면 매출내역 대사가 우리 품목 기준으로 통일된다. */
					egovframework.sejong.user.model.ProdXrefDTO rx = new egovframework.sejong.user.model.ProdXrefDTO();
					rx.setJobSeq(Long.valueOf(jobSeq));
					rx.setDlvDt(head.getDlvDt());
					svc.resolveSalesProd(rx);
				}

				/* ★정산서 → 재고원장 동기화 (2026-08-19) — 출고 원천이 정산서로 바뀌면서 생긴 연결.
				   종전에는 [재고 재집계] 버튼을 따로 눌러야 재고에 반영됐다 — 업로드만 하면 재고가
				   그대로여서 「올렸는데 재고가 안 바뀜다」가 된다. 날짜당 1회(중복 제거).
				   ★실패해도 정산서 저장 자체는 이미 끝난 것 — 롤백하지 않고 로그만 남긴다
				   (판매단가 이력 반영과 같은 규칙). 마감 확정월은 서비스가 조용히 건너뛴다. */
				int ledgerRows = 0;
				try {
					java.util.LinkedHashSet<String> dts = new java.util.LinkedHashSet<String>();
					for (egovframework.sejong.user.model.SalesDTO r : rows)
						if (r.getDlvDt() != null && !r.getDlvDt().trim().isEmpty()) dts.add(r.getDlvDt().trim());
					for (String d : dts) ledgerRows += svc.syncSalesLedger(d, null, regUser, regIp);
				} catch (Exception le) {
					log.error(" saveSalesMst 재고원장 동기화 WARN : " + le.getMessage());
					res.put("ledgerErr", le.getMessage());
				}
				res.put("ledger", ledgerRows);   // 재고원장에 만든 출고·반품 행수 (화면은 몰라도 무해)

				// (B) 판매단가 이력 반영 — 매출마감의 출고단가가 '(마스터)' 폴백이 아니라 '(이력)' = 실제 확정가로 잡히게 한다.
				//     · ★키 = 품목코드 + 납품일자(DLV_DT = 발주일자) → TBL_PROD_SALEPRICE_HST.APPLY_DT
				//       출고일자를 쓰면 안 된다 — 먼 지역은 발주분을 하루 당겨 출고해서 출고일자가 발주일자보다 이를 수 있고,
				//       매출마감은 'APPLY_DT <= 발주일자' 로 집으므로 기준을 발주일자로 통일해야 맞물린다.
				//     · 같은 품목·같은 날 단가가 서로 다르면 어느 쪽이 맞는지 알 수 없으므로 넣지 않고 건너뛴다(추측 금지)
				//     · 이력 반영 실패가 매출 저장 자체를 롤백하지 않도록 별도 try (실패 시 로그만)
				int pApplied = 0, pSkip = 0, pNone = 0;
				try {
					java.util.LinkedHashMap<String, egovframework.sejong.user.model.SalesDTO> pmap
					    = new java.util.LinkedHashMap<String, egovframework.sejong.user.model.SalesDTO>();
					java.util.HashSet<String> conflict = new java.util.HashSet<String>();
					for (egovframework.sejong.user.model.SalesDTO r : rows) {
						if (r.getItemCd() == null || r.getItemCd().trim().isEmpty()) continue;
						if (r.getDlvDt()  == null || r.getDlvDt().trim().isEmpty())  continue;
						if (r.getSalePrice() == null) continue;
						String k = r.getItemCd().trim() + "|" + r.getDlvDt().trim();
						egovframework.sejong.user.model.SalesDTO p = pmap.get(k);
						if (p == null) pmap.put(k, r);
						else if (p.getSalePrice().compareTo(r.getSalePrice()) != 0) conflict.add(k);
					}
					for (java.util.Map.Entry<String, egovframework.sejong.user.model.SalesDTO> en : pmap.entrySet()) {
						if (conflict.contains(en.getKey())) { pSkip++; continue; }
						egovframework.sejong.user.model.SalesDTO src = en.getValue();
						egovframework.sejong.user.model.SalesDTO h = new egovframework.sejong.user.model.SalesDTO();
						h.setItemCd(src.getItemCd().trim());
						h.setDlvDt(src.getDlvDt().trim());
						h.setSalePrice(src.getSalePrice());
						h.setRegUser(regUser);
						h.setRegIp(regIp);
						// 반환 0 = 상품마스터에 없는 품목코드이거나 이미 같은 단가 → 이력 변화 없음
						if (svc.mergeSalepriceFromSales(h) > 0) pApplied++; else pNone++;
					}
					if (!conflict.isEmpty())
						log.error(" saveSalesMst 판매단가 이력 SKIP(같은 품목·같은 날 단가 상이) : " + conflict);
				} catch (Exception pe) {
					log.error(" saveSalesMst 판매단가 이력 WARN : " + pe.getMessage());
				}

				res.put("saved", total);      // 저장된 행수
				res.put("price", pApplied);   // 판매단가 이력이 실제로 들어가거나 바뀐 품목수
				res.put("none",  pNone);      // 변화 없음(이미 같은 단가 or 품목코드가 상품마스터에 없음)
				res.put("skip",  pSkip);      // 같은 품목·같은 날 단가가 달라 확정 못해 건너뜀
				return ResponseEntity.ok(res);
			} catch (Exception e) {
				log.error(" saveSalesMst ERROR ! : " + e.getMessage());
				res.put("error", e.getMessage());
				return ResponseEntity.status(500).body(res);
			}
		}

		/* 매출 확정내역 조회 — 기간(dlvDtFrom~dlvDtTo) 또는 단일 납품일자 + 출고장(선택) (JSON: {data:[...]}) */
		@RequestMapping(value="/sales/selectSalesMst.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectSalesMst(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesDTO dto,
		                                          HttpSession session) throws Exception {
			Map<String,Object> res = new java.util.HashMap<String,Object>();
			try {
				res.put("data", svc.selectSalesMst(dto));
			} catch (Exception e) {
				log.error(" selectSalesMst ERROR ! : " + e.getMessage());
				res.put("data", new java.util.ArrayList<Object>());
				res.put("error", e.getMessage());
			}
			return res;
		}

		/* ================= 거래처 마스터 관리 (TBL_VENDOR_MST — 회계 거래처, 사업장 TBL_BIZI_MST 와 별개) ================= */
		@RequestMapping(value="/mangr/vendorMng.do")
		public String vendorMng(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/vendorMng";
		}
		@RequestMapping(value="/vendor/insertVendorMst.do", method = RequestMethod.POST)
		public ResponseEntity<String> insertVendorMst(@RequestBody egovframework.sejong.user.model.VendorDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getVendorCd()==null || dto.getVendorCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처코드 필요");
				if (svc.vendorDupChk(dto) > 0) return ResponseEntity.status(409).body("이미 존재하는 거래처코드입니다: "+dto.getVendorCd());
				dto.setRegUser(session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertVendorMst(dto)));
			} catch (Exception e) { log.error(" insertVendorMst ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/vendor/updateVendorMst.do", method = RequestMethod.POST)
		public ResponseEntity<String> updateVendorMst(@RequestBody egovframework.sejong.user.model.VendorDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getVendorCd()==null || dto.getVendorCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처코드 필요");
				dto.setUpdUser(session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateVendorMst(dto)));
			} catch (Exception e) { log.error(" updateVendorMst ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/vendor/deleteVendorMst.do", method = RequestMethod.POST)
		public ResponseEntity<String> deleteVendorMst(@RequestBody egovframework.sejong.user.model.VendorDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getVendorCd()==null || dto.getVendorCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처코드 필요");
				dto.setUpdUser(session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteVendorMst(dto)));
			} catch (Exception e) { log.error(" deleteVendorMst ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/* 거래처리스트.xls 재업로드 — 화면에서 파싱·코드기준 병합까지 끝낸 행 목록을 받아 코드별 MERGE upsert
		   (파일 자체는 확장자만 xls 인 HTML 표 — 화면 DOMParser 가 파싱한다) */
		@RequestMapping(value="/vendor/uploadVendorMst.do", method = RequestMethod.POST)
		public ResponseEntity<String> uploadVendorMst(@RequestBody List<egovframework.sejong.user.model.VendorDTO> rows, HttpServletRequest request, HttpSession session) {
			try {
				if (rows == null || rows.isEmpty()) return ResponseEntity.ok("0");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.sejong.user.model.VendorDTO r : rows) {
					if (r.getVendorCd()==null || r.getVendorCd().trim().isEmpty()) continue;
					r.setRegUser(u); r.setRegIp(ip); r.setUpdUser(u); r.setUpdIp(ip);
					n += svc.mergeVendorMst(r);
				}
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" uploadVendorMst ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 거래처 마스터 조회 — TBL_VENDOR_MST (TBL_BIZI_MST 사업장과 별개)
		   · gbFilter='매입' → 매입처 후보(매입가·재고입고 화면 선택박스). 빈값이면 전체
		   · findData → 코드/거래처명/정식명칭/별칭/사업자번호/대표자 부분검색 */
		@RequestMapping(value="/vendor/selectVendorMst.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectVendorMst(@ModelAttribute("DTO") egovframework.sejong.user.model.VendorDTO dto,
		                                           HttpSession session) throws Exception {
			Map<String,Object> res = new java.util.HashMap<String,Object>();
			try {
				res.put("data", svc.selectVendorMst(dto));
			} catch (Exception e) {
				log.error(" selectVendorMst ERROR ! : " + e.getMessage());
				res.put("data", new java.util.ArrayList<Object>());
				res.put("error", e.getMessage());
			}
			return res;
		}

		/* 거래처별 최근 6개월 매출·매입 합계 (2026-08-04)
		   — 거래처 선택 팝업 정렬용: 판매등록은 saleAmt, 매입등록은 purchAmt 내림차순으로 쓴다. */
		@RequestMapping(value="/vendor/vendorTrxSum.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> vendorTrxSum(@ModelAttribute("DTO") egovframework.sejong.user.model.VendorDTO dto,
		                                        HttpSession session) throws Exception {
			Map<String,Object> res = new java.util.HashMap<String,Object>();
			try {
				res.put("data", svc.selectVendorTrxSum(dto));
			} catch (Exception e) {
				log.error(" vendorTrxSum ERROR ! : " + e.getMessage());
				res.put("data", new java.util.ArrayList<Object>());
				res.put("error", e.getMessage());
			}
			return res;
		}

		/* 이미 업로드(반영)된 매출 엑셀 파일 목록 — 업로드 화면 '이미 반영' 배지용 */
		@RequestMapping(value="/sales/selectSalesSrcFiles.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectSalesSrcFiles(HttpSession session) throws Exception {
			Map<String,Object> res = new java.util.HashMap<String,Object>();
			try {
				res.put("data", svc.selectSalesSrcFiles());
			} catch (Exception e) {
				log.error(" selectSalesSrcFiles ERROR ! : " + e.getMessage());
				res.put("data", new java.util.ArrayList<Object>());
			}
			return res;
		}

		/* 출고장 정정(2026-07-27) — 엑셀 파일명에서 잘못 딴 출고장(예: '15.24.')이 그대로 저장된 지난 자료를
		     바로잡는다. 범위 = 조회 기간(dlvDtFrom~dlvDtTo) 안의 그 출고장 전체(활성+이력).
		   응답: {ok:true, rows:n} / 키 충돌이면 {ok:false, conflict:true} / 입력오류면 {ok:false, msg:...} */
		@RequestMapping(value="/sales/renameSalesDc.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> renameSalesDc(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesDTO dto,
		                                        HttpServletRequest request, HttpSession session) {
			Map<String,Object> res = new java.util.HashMap<String,Object>();
			try {
				String oldNm = dto.getDcNm()    == null ? "" : dto.getDcNm().trim();
				String newNm = dto.getNewDcNm() == null ? "" : dto.getNewDcNm().trim();
				if (oldNm.isEmpty() || newNm.isEmpty()) { res.put("ok", false); res.put("msg", "출고장이 비어 있습니다."); return res; }
				if (oldNm.equals(newNm))                { res.put("ok", false); res.put("msg", "같은 출고장입니다.");     return res; }
				dto.setDcNm(oldNm); dto.setNewDcNm(newNm);
				dto.setUpdUser(session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				             : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : ""));
				dto.setUpdIp(request.getRemoteAddr());
				int n = svc.renameSalesDc(dto);
				if (n < 0) { res.put("ok", false); res.put("conflict", true); return res; }   // 같은 납품일자에 그 출고장 활성배치가 이미 있다
				res.put("ok", true); res.put("rows", n);
			} catch (Exception e) {
				log.error(" renameSalesDc ERROR ! : " + e.getMessage());
				res.put("ok", false); res.put("msg", "서버 오류: " + e.getMessage());
			}
			return res;
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

		/* 마감 집계 — 출고(SHPOUT_DT 마감월) × 단가이력/마스터 → 품목·사업장·매입처별 매출/매입/마진 (마감관리 3화면 공용) */
		@RequestMapping(value="/shipout/selectClosing.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosing(@ModelAttribute("DTO") egovframework.sejong.user.model.ClosingDTO dto,
		                                         HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosing(dto));
			return response;
		}

		/* 출고미상 — 정산서에는 있는데 출고 자료에 짝이 없는 행. 마감에서 빠지는 금액이라 화면에 경고로 띄운다 */
		@RequestMapping(value="/shipout/selectClosingUnmatched.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosingUnmatched(@ModelAttribute("DTO") egovframework.sejong.user.model.ClosingDTO dto,
		                                                 HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosingUnmatched(dto));
			return response;
		}

		/* 재고마감 — TBL_STOCK_LEDGER 기준 기초+입고-출고±조정=기말 + 이동평균 재고금액 */
		@RequestMapping(value="/shipout/selectStockClosing.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectStockClosing(@ModelAttribute("DTO") egovframework.sejong.user.model.StockClosingDTO dto,
		                                             HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectStockClosing(dto));
			return response;
		}

		/* 입고(매입)마감 — TBL_STOCK_LEDGER 당월 입고(IO_GB='I') 품목별 집계 */
		@RequestMapping(value="/shipout/selectInboundClosing.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectInboundClosing(@ModelAttribute("DTO") egovframework.sejong.user.model.StockClosingDTO dto,
		                                              HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectInboundClosing(dto));
			return response;
		}

		/* 월별 마감 이력 목록 */
		@RequestMapping(value="/shipout/selectClosingList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosingList(@ModelAttribute("DTO") egovframework.sejong.user.model.ClosingMstDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosingMstList(dto));
			return response;
		}

		/* 마감 확정 상태 조회 */
		@RequestMapping(value="/shipout/selectClosingStatus.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosingStatus(@ModelAttribute("DTO") egovframework.sejong.user.model.ClosingMstDTO dto,
		                                              HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosingMst(dto));
			return response;
		}
		/* 마감 확정 — 3종 집계 저장 + 재고 스냅샷 + 잠금 */
		@RequestMapping(value="/shipout/confirmClosing.do", method = RequestMethod.POST)
		public ResponseEntity<String> confirmClosing(@RequestBody egovframework.sejong.user.model.ClosingMstDTO dto,
		                                             HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getYm()==null || dto.getYm().trim().isEmpty()) return ResponseEntity.status(400).body("마감월 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.confirmClosing(dto)));
			} catch (Exception e) { log.error(" confirmClosing ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/* 마감 확정 해제 */
		@RequestMapping(value="/shipout/cancelClosing.do", method = RequestMethod.POST)
		public ResponseEntity<String> cancelClosing(@RequestBody egovframework.sejong.user.model.ClosingMstDTO dto,
		                                            HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getYm()==null || dto.getYm().trim().isEmpty()) return ResponseEntity.status(400).body("마감월 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.cancelClosing(dto)));
			} catch (Exception e) { log.error(" cancelClosing ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 출고장 출고 소프트 삭제 — 특정 출고장(dcCd+inwh)+출고일자(shpoutDt)의 활성분을 ACTION_YN='D'로 표시(이력 보존) */
		@RequestMapping(value="/shipout/deleteShipoutZone.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> deleteShipoutZone(@ModelAttribute("DTO") egovframework.sejong.user.model.ShipoutDTO dto,
		                                           HttpServletRequest request, HttpSession session) {
			Map<String,Object> response = new HashMap<String,Object>();
			try {
				String regUser = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				               : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : "");
				dto.setUpdUser(regUser);
				dto.setUpdIp(request.getRemoteAddr());
				int n = svc.deleteShipoutZone(dto);
				response.put("ok", true);
				response.put("count", n);
			} catch (Exception e) {
				log.error(" deleteShipoutZone ERROR ! : " + e.getMessage());
				response.put("ok", false);
				response.put("msg", e.getMessage());
			}
			return response;
		}

		/* 폴더 업로드 화면 — 이미 업로드(반영)된 원본 파일명 목록 (JSON: {data:[{srcFile,shpoutDt,uploadDttm}]}) */
		@RequestMapping(value="/shipout/selectShipoutSrcFiles.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutSrcFiles(HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutSrcFiles());
			return response;
		}

		/* 출고현황표(데시보드2) 이력 비교용 — 해당 출고일자의 '직전 배치'(ACTION_YN='N' 최근본) 조회.
		   현재 활성배치와 대조해 신규/삭제 표시 (JSON: {data:[...]}) */
		@RequestMapping(value="/shipout/selectShipoutPrev.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutPrev(@ModelAttribute("DTO") egovframework.sejong.user.model.ShipoutDTO dto,
		                                            HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutPrev(dto));
			return response;
		}

		/* 출고현황표(데시보드2) 품목별 변경 이력 팝업 — 특정 물류센터코드(dcCd)+출고일자(shpoutDt)의 전 배치(활성+이력) 조회.
		   클라이언트가 (사업장+품목) × 배치(UPLOAD_DTTM)로 피벗해 신규/삭제/증감 표시 (JSON: {data:[...]}) */
		@RequestMapping(value="/shipout/selectShipoutHistory.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutHistory(@ModelAttribute("DTO") egovframework.sejong.user.model.ShipoutDTO dto,
		                                               HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutHistory(dto));
			return response;
		}

		/* 출고현황표(데시보드2) 메인 그리드 차수별 수량 매트릭스 — 해당 출고일자 전체 출고장의 전 배치(활성+이력) 조회 (JSON: {data:[...]}) */
		@RequestMapping(value="/shipout/selectShipoutHistAll.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutHistAll(@ModelAttribute("DTO") egovframework.sejong.user.model.ShipoutDTO dto,
		                                               HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutHistAll(dto));
			return response;
		}

		/* ===== 매출 그래프 — 월별 / 출고장별 매출액 (2026-07-25 사용자 요청) =====
		   금액 정의는 마감현황(selectClosing)과 같다 : 정산서 + 정산서 없는 출고의 추정 + 직접판매.
		   실측 202607 = 254,850,543 으로 마감현황과 일치함을 확인했다. */
		@RequestMapping(value="/shipout/salesChart.do")
		public String salesChart(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/admin/salesChart";
		}
		@RequestMapping(value="/shipout/selectSalesChart.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectSalesChart(@ModelAttribute("DTO") egovframework.sejong.user.model.ClosingDTO dto,
		                                           HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesChart(dto));
			return response;
		}
		/** 매출 그래프(일자별) — 월별과 별도 화면·별도 쿼리. 기간은 날짜 그대로 받는다(기본 일주일) */
		@RequestMapping(value="/shipout/salesChartDay.do")
		public String salesChartDay(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/admin/salesChartDay";
		}
		@RequestMapping(value="/shipout/selectSalesChartDaily.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectSalesChartDaily(@ModelAttribute("DTO") egovframework.sejong.user.model.ClosingDTO dto,
		                                                HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesChartDaily(dto));
			return response;
		}

		/* ===== 출고현황이력조회 — 발주현황표 엑셀 업로드 이력 (2026-07-25 사용자 요청) =====
		   대시보드에서 엑셀을 올릴 때마다 배치(출고일자+출고장+차수)가 남는다.
		   언제·누가·어느 파일로·몇 건을 올렸는지, 몇 차까지 다시 올렸는지를 일자별로 보여준다. */
		@RequestMapping(value="/shipout/shipoutHist.do")
		public String shipoutHist(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/admin/shipoutHist";
		}
		@RequestMapping(value="/shipout/selectShipoutUploadHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutUploadHist(@ModelAttribute("DTO") egovframework.sejong.user.model.ShipoutDTO dto,
		                                                  HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutUploadHist(dto));
			return response;
		}
		@RequestMapping(value="/shipout/selectShipoutUploadDtl.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutUploadDtl(@ModelAttribute("DTO") egovframework.sejong.user.model.ShipoutDTO dto,
		                                                 HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutUploadDtl(dto));
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

		/* ===== 택배 정보 저장 (2026-08-06) — 사업장관리·택배출고관리 공용.
		   사업장이 아직 TBL_BIZI_MST 에 없으면(출고자료에만 있는 신규) 먼저 등록하고 택배정보를 채운다. */
		@RequestMapping(value="/mangr/biziParcelUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> biziParcelUpdate(@RequestBody List<egovframework.sejong.user.model.BiziDTO> data,
		                                               HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.sejong.user.model.BiziDTO d : data) {
					if (d.getBizCd() == null || d.getBizCd().trim().isEmpty()) continue;
					d.setRegUser(u); d.setRegIp(ip); d.setUpdUser(u); d.setUpdIp(ip);
					if (d.getBizNm() != null && !d.getBizNm().trim().isEmpty()) svc.insertBiziIfAbsent(d);
					n += svc.updateBiziParcel(d);
				}
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" biziParcelUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ===== 택배출고관리 (2026-08-06 신설) — 출고일자의 직송(ZONE='직송') 줄을 택배 발송 양식으로 =====
		   화면: parcelOut.jsp. 주소·전화는 택배값 우선(없으면 기본값), 운임은 PARCEL_FEE(없으면 4500). */
		@RequestMapping(value="/shipout/parcelOut.do")
		public String parcelOut(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/parcelOut";
		}
		@RequestMapping(value="/shipout/parcelList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> parcelList(@RequestParam(value="frDt", required=false) String frDt,
		                                     @RequestParam(value="toDt", required=false) String toDt,
		                                     @RequestParam(value="outDt", required=false) String outDt,
		                                     HttpSession session) throws Exception {
			/* 출고일자 기간 (2026-08-06). 옛 호출(outDt 하나)도 그대로 받도록 남겨 둔다 */
			if (frDt == null || frDt.trim().isEmpty()) frDt = outDt;
			if (toDt == null || toDt.trim().isEmpty()) toDt = (outDt != null ? outDt : frDt);
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("frDt", frDt);
			p.put("toDt", toDt);
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectParcelOutList(p));
			return response;
		}

		/* ================= 거래처관리 (사업장 TBL_BIZI_MST) ================= */
		@RequestMapping(value="/mangr/clientMng.do")
		public String clientMng(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/clientMng";
		}
		@RequestMapping(value="/mangr/clientList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> clientList(@ModelAttribute("DTO") egovframework.sejong.user.model.BiziDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectBiziList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/clientInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> clientInsert(@RequestBody egovframework.sejong.user.model.BiziDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("사업장코드 필요");
				if (svc.biziDupChk(dto) > 0) return ResponseEntity.status(409).body("이미 존재하는 사업장코드입니다: "+dto.getBizCd());
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertBizi(dto)));
			} catch (Exception e) { log.error(" clientInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/clientUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> clientUpdate(@RequestBody egovframework.sejong.user.model.BiziDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("사업장코드 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateBizi(dto)));
			} catch (Exception e) { log.error(" clientUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/clientDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> clientDelete(@RequestBody egovframework.sejong.user.model.BiziDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("사업장코드 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteBizi(dto)));
			} catch (Exception e) { log.error(" clientDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 매입등록 (TBL_PURCHASE_MST/DTL) — 2026-07-25 ================= */
		@RequestMapping(value="/mangr/purchaseReg.do")
		public String purchaseReg(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/purchaseReg";
		}
		@RequestMapping(value="/mangr/purchaseList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseList(@ModelAttribute("DTO") egovframework.sejong.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/purchaseDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseDetail(@ModelAttribute("DTO") egovframework.sejong.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseOne(dto));
			return response;
		}
		@RequestMapping(value="/mangr/purchaseNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseNextNo(@ModelAttribute("DTO") egovframework.sejong.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseNextNo(dto));
			return response;
		}
		/** 전표 저장 — 헤더+명세를 통째로 받는다(JSON). 신규/수정 모두 이 하나로 */
		@RequestMapping(value="/mangr/purchaseSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> purchaseSave(@RequestBody egovframework.sejong.user.model.PurchaseDTO dto,
		                                           HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPurchDt()==null || dto.getPurchDt().trim().isEmpty()) return ResponseEntity.status(400).body("매입일자를 선택하세요.");
				if (dto.getVendorCd()==null || dto.getVendorCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처를 선택하세요.");
				if (dto.getItems()==null || dto.getItems().isEmpty()) return ResponseEntity.status(400).body("상품을 한 줄 이상 입력하세요.");
				/* ★★서브코드로 매입을 잡는 것을 막는다 (2026-08-17 요청) ─────────────────────────
				   서브코드(거래처 매칭코드)는 '남의 코드'일 뿐 재고의 주인이 아니다. 그 코드로 매입이 잡히면
				   ***같은 물건의 재고가 마스터코드와 서브코드로 갈라진다.***
				   ★화면 경고만으로는 못 막는다 — 담기는 길이 여럿(상품선택·일괄담기·최근매입·전표복사)이라
				     ***저장 관문 하나에서*** 걸러야 빠짐이 없다. 화면은 이보다 먼저 안내할 뿐이다.
				   ⚠서브코드의 등록·수정은 막지 않는다(요청 그대로). 막는 것은 '매입자료로 잡는 것' 하나다.
				   ⚠판매전표(salesTrxSave)는 막지 않는다 — 거래처에 나갈 때는 그쪽 코드를 쓰는 것이 정상이다. */
				String subMsg = subCodeBlockMsg(dto, session);
				if (subMsg != null) return ResponseEntity.status(409).body(subMsg);
				/* ★거래중지 코드 차단 (2026-08-17) — 전표일자 기준 */
				java.util.List<String> pCodes = new java.util.ArrayList<String>();
				for (egovframework.sejong.user.model.PurchaseDtlDTO it : dto.getItems()) pCodes.add(it.getProdCd());
				String stopMsg = stopBlockMsg(pCodes, dto.getPurchDt(), session);
				if (stopMsg != null) return ResponseEntity.status(409).body(stopMsg);
				String u = (session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setRegUser(u); dto.setUpdUser(u);
				dto.setRegIp(request.getRemoteAddr()); dto.setUpdIp(request.getRemoteAddr());
				int n = svc.savePurchase(dto);
				return ResponseEntity.ok("{\"rows\":" + n + ",\"purchSeq\":" + dto.getPurchSeq() + ",\"purchNo\":\"" + dto.getPurchNo() + "\"}");
			} catch (Exception e) { log.error(" purchaseSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/**
		 * ★거래중지된 코드가 섞였으면 막는 문구를 만든다. 없으면 null. (2026-08-17 요청)
		 *
		 * <p>거래가 붙어 <b>지울 수 없는</b> 잘못된 코드를 「거래중지」로 표시해 두면,
		 * 옛 전표·재고는 그대로 남고 <b>새 거래만</b> 여기서 막힌다.
		 * <p>⚠견주는 것은 <b>전표일자</b>다(오늘 날짜가 아니다) — 지난 일자로 넣는 전표가 실제로 있어,
		 *   오늘로 판정하면 "중지 전에 있었던 거래"까지 막아 버린다.
		 * <p>★매입·판매 <b>둘 다</b> 막는다(사용자 지시). 서브코드 차단이 매입만인 것과 다르다 —
		 *   그쪽은 "거래처 코드로 나가는 판매는 정상"이지만, 중지된 코드는 어느 쪽으로도 쓰면 안 된다.
		 */
		private String stopBlockMsg(java.util.List<String> codes, String trxDt, HttpSession session) throws Exception {
			java.util.LinkedHashSet<String> set = new java.util.LinkedHashSet<String>();
			if (codes != null) for (String c : codes) if (c != null && !c.trim().isEmpty()) set.add(c.trim());
			if (set.isEmpty() || trxDt == null || trxDt.trim().isEmpty()) return null;
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("codes", new java.util.ArrayList<String>(set));
			p.put("trxDt", trxDt);
			p.put("compCd", session.getAttribute("s_comp_cd"));
			java.util.List<egovframework.sejong.user.model.ProdDTO> st = svc.selectStoppedAmong(p);
			if (st == null || st.isEmpty()) return null;
			StringBuilder sb = new StringBuilder("거래중지된 상품코드가 있어 저장할 수 없습니다.\n");
			for (egovframework.sejong.user.model.ProdDTO d : st) {
				sb.append("\n· ").append(d.getProdCd()).append(" ").append(d.getProdNm()==null?"":d.getProdNm());
				sb.append("  (").append(d.getStopFrDt()).append(" 부터 중지");
				if (d.getStopMemo()!=null && !d.getStopMemo().isEmpty()) sb.append(" · ").append(d.getStopMemo());
				sb.append(")");
			}
			return sb.toString();
		}

		/**
		 * 매입 명세에 <b>서브코드</b>가 섞였으면 막는 문구를 만든다. 없으면 null.
		 *
		 * <p>★코드는 <b>한 번에</b> 물어본다 — 줄마다 조회하면 100줄짜리 전표에서 100번 돈다.
		 * <p>⚠빈 코드·중복은 미리 걸러 낸다(IN 절이 커지고 같은 답이 여러 번 온다).
		 */
		private String subCodeBlockMsg(egovframework.sejong.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			java.util.LinkedHashSet<String> codes = new java.util.LinkedHashSet<String>();
			for (egovframework.sejong.user.model.PurchaseDtlDTO it : dto.getItems()) {
				if (it.getProdCd() != null && !it.getProdCd().trim().isEmpty()) codes.add(it.getProdCd().trim());
			}
			if (codes.isEmpty()) return null;
			java.util.Map<String,Object> p = new HashMap<String,Object>();
			p.put("codes", new java.util.ArrayList<String>(codes));
			p.put("compCd", session.getAttribute("s_comp_cd"));   // ★Map 이라 인터셉터가 안 넣어 준다 — 직접 넣는다
			java.util.List<egovframework.sejong.user.model.ExtItemDTO> subs = svc.selectSubCodesAmong(p);
			if (subs == null || subs.isEmpty()) return null;
			StringBuilder sb = new StringBuilder();
			sb.append("서브코드로는 매입을 잡을 수 없습니다. 마스터코드로 바꿔 주세요.\n");
			for (egovframework.sejong.user.model.ExtItemDTO x : subs) {
				sb.append("\n· ").append(x.getExtItemCd()).append(" (서브)  →  마스터 ").append(x.getProdCd());
				if (x.getProdNm() != null && !x.getProdNm().isEmpty()) sb.append("  ").append(x.getProdNm());
			}
			return sb.toString();
		}

		/**
		 * 화면용 — 넘긴 코드 중 서브코드인 것을 마스터코드와 함께 돌려준다 (2026-08-17).
		 * 매입등록이 <b>담는 순간</b> 안내하고 [마스터코드로 바꾸기]를 권하는 데 쓴다.
		 * (막는 것은 저장 관문이고, 이것은 그보다 먼저 알려 주기 위한 것이다.)
		 */
		@RequestMapping(value="/prod/subCodeCheck.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> subCodeCheck(@RequestBody Map<String,Object> body, HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("data", new java.util.ArrayList<Object>()); return res; }
			Object raw = body.get("codes");
			java.util.LinkedHashSet<String> codes = new java.util.LinkedHashSet<String>();
			if (raw instanceof java.util.List) {
				for (Object o : (java.util.List<?>) raw) {
					if (o != null && !String.valueOf(o).trim().isEmpty()) codes.add(String.valueOf(o).trim());
				}
			}
			if (codes.isEmpty()) { res.put("data", new java.util.ArrayList<Object>()); return res; }
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("codes", new java.util.ArrayList<String>(codes));
			p.put("compCd", session.getAttribute("s_comp_cd"));
			res.put("data", svc.selectSubCodesAmong(p));
			return res;
		}

		@RequestMapping(value="/mangr/purchaseDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> purchaseDelete(@RequestBody egovframework.sejong.user.model.PurchaseDTO dto,
		                                             HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPurchSeq()==null) return ResponseEntity.status(400).body("전표 키가 필요합니다.");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""));
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deletePurchase(dto)));
			} catch (Exception e) { log.error(" purchaseDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/** 품목 선택 시 그 거래처의 최근 매입단가 (remark 칸에 거래처코드를 담아 보낸다) */
		@RequestMapping(value="/mangr/purchaseLastPrice.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseLastPrice(@ModelAttribute("DTO") egovframework.sejong.user.model.PurchaseDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectVendorLastPrice(dto));
			return response;
		}
		/** 품명 클릭 → 거래처 × 상품 매입단가 이력(최대 3년) */
		@RequestMapping(value="/mangr/purchasePriceHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchasePriceHist(@ModelAttribute("DTO") egovframework.sejong.user.model.PurchaseDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchasePriceHist(dto));
			return response;
		}

		/** 거래처 원장(분개장) — 매입등록 화면 우측. 일자별 매입·DC·지급·할인 */
		@RequestMapping(value="/mangr/purchaseLedger.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseLedger(@ModelAttribute("DTO") egovframework.sejong.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseLedger(dto));
			return response;
		}

		/* ================= 판매등록 (TBL_SALES_TRX_MST/DTL) — 2026-07-25 =================
		   매입등록과 대칭. 정산서(TBL_SALES_MST)와는 별개 표다 — 그쪽은 출고장 엑셀 적재표라
		   재업로드하면 기존 행이 죽으므로 손으로 친 판매를 섞을 수 없다. */
		@RequestMapping(value="/mangr/salesReg.do")
		public String salesReg(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/salesReg";
		}
		@RequestMapping(value="/mangr/salesTrxList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxList(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/salesTrxDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxDetail(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxOne(dto));
			return response;
		}
		@RequestMapping(value="/mangr/salesTrxNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxNextNo(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxNextNo(dto));
			return response;
		}
		/** 전표 저장 — 헤더+명세를 통째로 받는다(JSON). 신규/수정 모두 이 하나로 */
		@RequestMapping(value="/mangr/salesTrxSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> salesTrxSave(@RequestBody egovframework.sejong.user.model.SalesTrxDTO dto,
		                                           HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getSaleDt()==null || dto.getSaleDt().trim().isEmpty()) return ResponseEntity.status(400).body("판매일자를 선택하세요.");
				if (dto.getCustCd()==null || dto.getCustCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처를 선택하세요.");
				if (dto.getItems()==null || dto.getItems().isEmpty()) return ResponseEntity.status(400).body("상품을 한 줄 이상 입력하세요.");
				/* ★거래중지 코드 차단 (2026-08-17 지시 "매입등록시, 판매등록시 조건 추가") — 판매일자 기준.
				   ⚠서브코드 차단은 매입만이지만(판매는 거래처 코드로 나가는 것이 정상), ***중지된 코드는
				     어느 쪽으로도 쓰면 안 된다*** — 그래서 판매도 막는다. */
				java.util.List<String> sCodes = new java.util.ArrayList<String>();
				for (egovframework.sejong.user.model.SalesTrxDtlDTO it : dto.getItems()) sCodes.add(it.getProdCd());
				String sStopMsg = stopBlockMsg(sCodes, dto.getSaleDt(), session);
				if (sStopMsg != null) return ResponseEntity.status(409).body(sStopMsg);
				String u = (session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setRegUser(u); dto.setUpdUser(u);
				dto.setRegIp(request.getRemoteAddr()); dto.setUpdIp(request.getRemoteAddr());
				int n = svc.saveSalesTrx(dto);
				return ResponseEntity.ok("{\"rows\":" + n + ",\"saleSeq\":" + dto.getSaleSeq() + ",\"saleNo\":\"" + dto.getSaleNo() + "\"}");
			} catch (Exception e) { log.error(" salesTrxSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/salesTrxDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> salesTrxDelete(@RequestBody egovframework.sejong.user.model.SalesTrxDTO dto,
		                                             HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getSaleSeq()==null) return ResponseEntity.status(400).body("전표 키가 필요합니다.");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""));
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteSalesTrx(dto)));
			} catch (Exception e) { log.error(" salesTrxDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/** 품목 선택 시 그 거래처의 최근 판매단가 (remark 칸에 거래처코드를 담아 보낸다) */
		@RequestMapping(value="/mangr/salesLastPrice.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesLastPrice(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesTrxDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectCustLastPrice(dto));
			return response;
		}
		/** 매출내역·마감현황에 얹을 판매전표 명세 — 정산서 행과 같은 모양으로 돌려준다 */
		@RequestMapping(value="/mangr/salesTrxHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxHist(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxHist(dto));
			return response;
		}
		/** 품명 클릭 → 거래처 × 상품 판매단가 이력(최대 3년) */
		@RequestMapping(value="/mangr/salesPriceHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesPriceHist(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesTrxDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesPriceHist(dto));
			return response;
		}

		/* ===== 납품분 (2026-07-31) — 그 거래처에 이미 나간 품목을 중복 없이 =====
		   판매전표 + 정산서를 함께 본다. 체크한 순서대로 명세에 담는 건 화면이 한다.
		   제외는 거래처별(TBL_SALES_DLV_EXCL) — DDL: sql/sales_dlv_excl_ddl.sql */
		@RequestMapping(value="/mangr/salesDlvList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesDlvList(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesDlvDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesDlvList(dto));
			return response;
		}
		/** 매입분 — 그 매입처에서 사 온 품목(매입전표 + 매입단가이력). 매입등록 화면의 [매입분] */
		@RequestMapping(value="/mangr/purchDlvList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchDlvList(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesDlvDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchDlvList(dto));
			return response;
		}
		/** 제외이력보기 — 그 거래처에서 빼 둔 품목. gb 'S' 판매(납품분) / 'P' 매입(매입분) */
		@RequestMapping(value="/mangr/salesDlvExclList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesDlvExclList(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesDlvDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesDlvExclList(dto));
			return response;
		}
		/** 납품분제외 / 제외해제 — prodCds 에 상품코드를 콤마로 이어 보낸다. actionYn 'Y' 제외 / 'N' 해제 */
		@RequestMapping(value="/mangr/salesDlvExclSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> salesDlvExclSave(@ModelAttribute("DTO") egovframework.sejong.user.model.SalesDlvDTO dto,
		                                               @RequestParam(value="prodCds", required=false) String prodCds,
		                                               HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getCustCd()==null || dto.getCustCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처를 선택하세요.");
				if (prodCds==null || prodCds.trim().isEmpty()) return ResponseEntity.status(400).body("품목을 선택하세요.");
				java.util.List<String> l = new java.util.ArrayList<String>(java.util.Arrays.asList(prodCds.split(",")));
				if (l.size() > 1) dto.setProdNm(null);   // 이름 스냅샷은 한 건일 때만 — 여러 건이면 상품마스터가 채운다
				String u = (session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setRegUser(u); dto.setUpdUser(u);
				dto.setRegIp(request.getRemoteAddr()); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.saveSalesDlvExcl(dto, l)));
			} catch (Exception e) { log.error(" salesDlvExclSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 수금/지급 등록 (TBL_SETTLE_TRX) — 2026-07-25 =================
		   한 컨트롤러로 두 화면을 다룬다. 화면이 trxGb 로 'RCV'(수금)/'PAY'(지급)를 넘긴다. */
		@RequestMapping(value="/mangr/payReg.do")
		public String payReg(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/payReg";
		}
		@RequestMapping(value="/mangr/rcvReg.do")
		public String rcvReg(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/rcvReg";
		}
		@RequestMapping(value="/mangr/settleList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> settleList(@ModelAttribute("DTO") egovframework.sejong.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSettleList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/settleNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> settleNextNo(@ModelAttribute("DTO") egovframework.sejong.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSettleNextNo(dto));
			return response;
		}
		@RequestMapping(value="/mangr/settleSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> settleSave(@RequestBody egovframework.sejong.user.model.SettleTrxDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getTrxDt()==null || dto.getTrxDt().trim().isEmpty()) return ResponseEntity.status(400).body("일자를 선택하세요.");
				if (dto.getCustCd()==null || dto.getCustCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처를 선택하세요.");
				String u = (session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setRegUser(u); dto.setUpdUser(u);
				dto.setRegIp(request.getRemoteAddr()); dto.setUpdIp(request.getRemoteAddr());
				int n = (dto.getTrxSeq()==null || dto.getTrxSeq()<=0) ? svc.insertSettleTrx(dto) : svc.updateSettleTrx(dto);
				return ResponseEntity.ok("{\"rows\":" + n + ",\"trxSeq\":" + dto.getTrxSeq() + ",\"trxNo\":\"" + dto.getTrxNo() + "\"}");
			} catch (Exception e) { log.error(" settleSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/settleDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> settleDelete(@RequestBody egovframework.sejong.user.model.SettleTrxDTO dto,
		                                           HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getTrxSeq()==null) return ResponseEntity.status(400).body("전표 키가 필요합니다.");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""));
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteSettleTrx(dto)));
			} catch (Exception e) { log.error(" settleDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/custLedger.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> custLedger(@ModelAttribute("DTO") egovframework.sejong.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectCustLedger(dto));
			return response;
		}

		/* ===== 거래처별 받을금액·지급할금액 (2026-07-26 신설) — 원장관리 ▸ 조회 전용 =====
		   전 거래처 × 월 한 번에 내려주고 화면에서 잔액 누계·이력으로 접는다(기간 파라미터 없음).
		   잔액은 '전 기간 누계'라 기간을 걸면 잔액이 아니게 되기 때문. 자세한 근거는 SQL 주석 참조.
		   ※ 2026-07-27 에 추가된 '특정일자'는 이 잔액과 무관하다 — 아래 selectCustDayDetail(하단 내역) 전용. */
		@RequestMapping(value="/mangr/custBalance.do")
		public String custBalance(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/custBalance";
		}
		@RequestMapping(value="/mangr/selectCustBalance.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectCustBalance(@ModelAttribute("DTO") egovframework.sejong.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectCustBalance(dto));
			return response;
		}
		/* 위 화면 하단 — 고른 거래처의 **특정일자 하루** 건별 내역(출고·매입·입금·출금).
		   ★위 잔액(누계)과는 별개다. 한 표에 섞었다가 "너무 복잡"하다는 지적으로 갈라 놓은 것이니 다시 섞지 말 것.
		   파라미터 = custCd + trxDt. */
		@RequestMapping(value="/mangr/selectCustDayDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectCustDayDetail(@ModelAttribute("DTO") egovframework.sejong.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectCustDayDetail(dto));
			return response;
		}

		/* ===== 일계장 (2026-07-26 신설) — 하루치 거래처별 매출·매입·수금·지급 + 전일잔액 =====
		   금액 규칙은 거래처별 채권·채무(selectCustBalance)와 같고 낟알만 일자다. 조회 전용·인쇄용. */
		@RequestMapping(value="/mangr/dayBook.do")
		public String dayBook(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/dayBook";
		}
		@RequestMapping(value="/mangr/selectDayBook.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectDayBook(@ModelAttribute("DTO") egovframework.sejong.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectDayBook(dto));
			return response;
		}

		/* ================= 수금/미수금 (TBL_RECEIVE_MST) ================= */
		@RequestMapping(value="/mangr/receiveMng.do")
		public String receiveMng(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/receiveMng";
		}
		@RequestMapping(value="/mangr/receiveList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> receiveList(@ModelAttribute("DTO") egovframework.sejong.user.model.ReceiveDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectReceiveList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/receiveInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> receiveInsert(@RequestBody egovframework.sejong.user.model.ReceiveDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getRcvYm()==null || dto.getRcvYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertReceive(dto)));
			} catch (Exception e) { log.error(" receiveInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/receiveUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> receiveUpdate(@RequestBody egovframework.sejong.user.model.ReceiveDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getRcvSeq()==null) return ResponseEntity.status(400).body("RCV_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateReceive(dto)));
			} catch (Exception e) { log.error(" receiveUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/receiveDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> receiveDelete(@RequestBody egovframework.sejong.user.model.ReceiveDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getRcvSeq()==null) return ResponseEntity.status(400).body("RCV_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteReceive(dto)));
			} catch (Exception e) { log.error(" receiveDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/receiveUpload.do", method = RequestMethod.POST)
		public ResponseEntity<String> receiveUpload(@RequestBody List<egovframework.sejong.user.model.ReceiveDTO> rows, HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.upsertReceiveList(rows, u, request.getRemoteAddr())));
			} catch (Exception e) { log.error(" receiveUpload ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/receiveCarryForward.do", method = RequestMethod.POST)
		public ResponseEntity<String> receiveCarryForward(@RequestBody egovframework.sejong.user.model.ReceiveDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getRcvYm()==null || dto.getRcvYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.carryForwardReceive(dto)));
			} catch (Exception e) { log.error(" receiveCarryForward ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/receiveCloseStatus.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> receiveCloseStatus(@RequestBody egovframework.sejong.user.model.ReceiveDTO dto, HttpSession session) throws Exception {
			Map<String,Object> r = new HashMap<String,Object>();
			egovframework.sejong.user.model.SettleCloseDTO c = svc.selectSettleClose("RCV", dto.getRcvYm());
			boolean closed = (c != null && "Y".equals(c.getStatus()));
			r.put("closed", closed); r.put("confirmDttm", c!=null?c.getConfirmDttm():null); r.put("confirmUser", c!=null?c.getConfirmUser():null);
			return r;
		}
		@RequestMapping(value="/mangr/receiveConfirm.do", method = RequestMethod.POST)
		public ResponseEntity<String> receiveConfirm(@RequestBody egovframework.sejong.user.model.ReceiveDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getRcvYm()==null || dto.getRcvYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.confirmSettleClose("RCV", dto.getRcvYm(), u)));
			} catch (Exception e) { log.error(" receiveConfirm ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/receiveCancel.do", method = RequestMethod.POST)
		public ResponseEntity<String> receiveCancel(@RequestBody egovframework.sejong.user.model.ReceiveDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getRcvYm()==null || dto.getRcvYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.cancelSettleClose("RCV", dto.getRcvYm(), u)));
			} catch (Exception e) { log.error(" receiveCancel ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 출금/미지급 (TBL_PAYMENT_MST) ================= */
		@RequestMapping(value="/mangr/paymentMng.do")
		public String paymentMng(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/paymentMng";
		}
		@RequestMapping(value="/mangr/paymentList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> paymentList(@ModelAttribute("DTO") egovframework.sejong.user.model.PaymentDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPaymentList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/paymentInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> paymentInsert(@RequestBody egovframework.sejong.user.model.PaymentDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPayYm()==null || dto.getPayYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("매입처 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertPayment(dto)));
			} catch (Exception e) { log.error(" paymentInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/paymentUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> paymentUpdate(@RequestBody egovframework.sejong.user.model.PaymentDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPaySeq()==null) return ResponseEntity.status(400).body("PAY_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updatePayment(dto)));
			} catch (Exception e) { log.error(" paymentUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/paymentDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> paymentDelete(@RequestBody egovframework.sejong.user.model.PaymentDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPaySeq()==null) return ResponseEntity.status(400).body("PAY_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deletePayment(dto)));
			} catch (Exception e) { log.error(" paymentDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/paymentUpload.do", method = RequestMethod.POST)
		public ResponseEntity<String> paymentUpload(@RequestBody List<egovframework.sejong.user.model.PaymentDTO> rows, HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.upsertPaymentList(rows, u, request.getRemoteAddr())));
			} catch (Exception e) { log.error(" paymentUpload ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/paymentCarryForward.do", method = RequestMethod.POST)
		public ResponseEntity<String> paymentCarryForward(@RequestBody egovframework.sejong.user.model.PaymentDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPayYm()==null || dto.getPayYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.carryForwardPayment(dto)));
			} catch (Exception e) { log.error(" paymentCarryForward ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/paymentCloseStatus.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> paymentCloseStatus(@RequestBody egovframework.sejong.user.model.PaymentDTO dto, HttpSession session) throws Exception {
			Map<String,Object> r = new HashMap<String,Object>();
			egovframework.sejong.user.model.SettleCloseDTO c = svc.selectSettleClose("PAY", dto.getPayYm());
			boolean closed = (c != null && "Y".equals(c.getStatus()));
			r.put("closed", closed); r.put("confirmDttm", c!=null?c.getConfirmDttm():null); r.put("confirmUser", c!=null?c.getConfirmUser():null);
			return r;
		}
		@RequestMapping(value="/mangr/paymentConfirm.do", method = RequestMethod.POST)
		public ResponseEntity<String> paymentConfirm(@RequestBody egovframework.sejong.user.model.PaymentDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPayYm()==null || dto.getPayYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.confirmSettleClose("PAY", dto.getPayYm(), u)));
			} catch (Exception e) { log.error(" paymentConfirm ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/paymentCancel.do", method = RequestMethod.POST)
		public ResponseEntity<String> paymentCancel(@RequestBody egovframework.sejong.user.model.PaymentDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getPayYm()==null || dto.getPayYm().trim().isEmpty()) return ResponseEntity.status(400).body("귀속월 필요");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.cancelSettleClose("PAY", dto.getPayYm(), u)));
			} catch (Exception e) { log.error(" paymentCancel ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 상품마스터 (TBL_PROD_MST) ================= */
		@RequestMapping(value="/prod/prodmst.do")
		public String prodmst(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/prod/prodmst";
		}
		/* 상품코드 등록 — 같은 TBL_PROD_MST 를 보는 등록 전용 화면(목록/저장은 아래 prod* 엔드포인트 공용) */
		@RequestMapping(value="/prod/prodcd.do")
		public String prodcd(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/prod/prodcd";
		}
		@RequestMapping(value="/prod/prodList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> prodList(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectProdList(dto));
			return response;
		}
		/* ===== 삭제한 상품 보기 · 되살리기 (2026-08-17 요청) ================================
		   삭제는 원래부터 소프트 삭제(ACTION_YN='N')라 자료가 남아 있다. 되살리기는 값 하나를
		   'Y' 로 되돌리는 것뿐 — 그래서 복원 표도, 별도 백업도 필요 없다. */
		@RequestMapping(value="/prod/prodDeletedList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> prodDeletedList(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { response.put("data", new java.util.ArrayList<Object>()); return response; }
			response.put("data", svc.selectProdDeletedList(dto));
			return response;
		}
		@RequestMapping(value="/prod/prodRestore.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodRestore(@RequestBody egovframework.sejong.user.model.ProdDTO dto,
		                                          HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""));
				dto.setUpdIp(request.getRemoteAddr());
				/* 0건 = 이미 살아 있거나 남의 회사 것. WHERE 에 COMP_CD 가 있어 동작은 원래도 안전하다. */
				if (svc.restoreProd(dto) == 0) return ResponseEntity.status(409).body("되살릴 상품을 찾을 수 없습니다. (이미 살아 있거나 다른 회사의 상품입니다)");
				return ResponseEntity.ok("1");
			} catch (Exception e) { log.error(" prodRestore ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ===== 거래중지 처리 · 해제 (2026-08-17 요청) ==========================================
		   거래가 붙어 **지울 수 없는** 잘못된 코드를 「앞으로 안 쓰는 코드」로 표시한다.
		   옛 전표·재고는 손대지 않는다 — 이력은 그대로, 새 거래만 막는다. */
		@RequestMapping(value="/prod/prodStop.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodStop(@RequestBody egovframework.sejong.user.model.ProdDTO dto,
		                                       HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""));
				dto.setUpdIp(request.getRemoteAddr());
				if (svc.stopProd(dto) == 0) return ResponseEntity.status(409).body("대상 상품을 찾을 수 없습니다.");
				return ResponseEntity.ok("1");
			} catch (Exception e) { log.error(" prodStop ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/prodUnstop.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodUnstop(@RequestBody egovframework.sejong.user.model.ProdDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""));
				dto.setUpdIp(request.getRemoteAddr());
				if (svc.unstopProd(dto) == 0) return ResponseEntity.status(409).body("대상 상품을 찾을 수 없습니다.");
				return ResponseEntity.ok("1");
			} catch (Exception e) { log.error(" prodUnstop ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/prod/prodInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodInsert(@RequestBody egovframework.sejong.user.model.ProdDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdCd()==null || dto.getProdCd().trim().isEmpty()) return ResponseEntity.status(400).body("코드 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertProd(dto)));
			} catch (Exception e) { log.error(" prodInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/prodUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodUpdate(@RequestBody egovframework.sejong.user.model.ProdDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateProd(dto)));
			} catch (Exception e) { log.error(" prodUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/prodDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodDelete(@RequestBody egovframework.sejong.user.model.ProdDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				int rel = svc.countProdRelated(dto);   // 하단 연관정보(매입가/판매가/재고) 있으면 삭제 차단
				if (rel > 0) return ResponseEntity.status(409).body("연관 정보(매입가·판매가·재고 내역) "+rel+"건이 있어 삭제할 수 없습니다. 해당 내역을 먼저 삭제하세요.");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteProd(dto)));
			} catch (Exception e) { log.error(" prodDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 매입가 이력 (TBL_PROD_INPRICE_HST) ================= */
		/* ===== 거래처별 품목 표기(교차참조) — TBL_PROD_XREF (2026-08-01) =====================
		   코네트 품목은 하나, 거래처가 요청하는 코드·품명은 XREF 에 N건. 가상코드를 만들지 않는다.
		   등록 지점 = 상품관리(상품코드) 화면의 [거래처 코드] 탭 + 업로드 프리뷰의 미매핑 연결. */
		@RequestMapping(value="/prod/xrefList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefList(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectXrefList(dto));
			return response;
		}
		/* 미매핑 목록 — 업로드된 자료 중 우리 품목으로 해석되지 않은 코드(거래처·코드별 집계) */
		@RequestMapping(value="/prod/xrefUnmapped.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefUnmapped(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectUnmappedItems(dto));
			return response;
		}
		/* 후보 추천 — ★품명은 거래처마다 제각각으로 들어오므로 보조 신호일 뿐이다.
		   단가(extPrice)·규격(extSpec)이 있으면 그것이 1순위 근거가 된다. 자동 확정은 없다. */
		@RequestMapping(value="/prod/xrefCandidates.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefCandidates(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectXrefCandidates(dto));
			return response;
		}
		/* 매핑 점검 리포트 — 틀린 매핑이 남기는 신호를 한 화면에.
		   ①미매핑(재고 보류) ②단가 이탈(정산 vs 우리 판매가 10%↑) ③미확인 출고 ④재고 음수.
		   기간(일)은 matchScore 칸을 빌려 쓴다(기본 30). */
		/* 그 거래처로 나갈 때 쓸 품명 — 판매등록이 명세 품명을 이걸로 채운다.
		   "출고는 거래처가 요청한 품목명으로 나가야 한다" 는 요구가 실제로 지켜지는 지점. */
		@RequestMapping(value="/prod/xrefNames.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefNames(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectXrefNames(dto));
			return response;
		}
		@RequestMapping(value="/prod/xrefAudit.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefAudit(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectXrefAudit(dto));
			return response;
		}
		@RequestMapping(value="/prod/xrefSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> xrefSave(@RequestBody egovframework.sejong.user.model.ProdXrefDTO dto,
		                                       HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq() == null) return ResponseEntity.status(400).body("우리 품목(PROD_SEQ)을 고르세요.");
				if (dto.getExtItemCd() == null || dto.getExtItemCd().trim().isEmpty())
					return ResponseEntity.status(400).body("거래처 품목코드가 필요합니다.");
				String regUser = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				               : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : "");
				dto.setRegUser(regUser); dto.setUpdUser(regUser);
				dto.setRegIp(request.getRemoteAddr()); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.saveXref(dto)));
			} catch (org.springframework.dao.DuplicateKeyException de) {
				/* UX_PROD_XREF_EXT 위반 = 같은 거래처의 같은 코드가 이미 다른 품목에 걸려 있다.
				   데이터가 깨지지 않게 DB 가 막아 준 것이므로 사용자에게 그대로 알린다. */
				return ResponseEntity.status(409).body("이미 다른 품목에 연결된 거래처 코드입니다. 기존 연결을 먼저 확인하세요.");
			} catch (Exception e) {
				log.error(" xrefSave ERROR ! : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}
		/* 대사 확정 — 정산서의 단가·규격이 맞았을 때 또는 상품관리에서 사람이 직접 */
		@RequestMapping(value="/prod/xrefConfirm.do", method = RequestMethod.POST)
		public ResponseEntity<String> xrefConfirm(@RequestBody egovframework.sejong.user.model.ProdXrefDTO dto, HttpSession session) {
			try {
				if (dto.getXrefSeq() == null) return ResponseEntity.status(400).body("XREF_SEQ 필요");
				dto.setConfirmUser(session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "");
				return ResponseEntity.ok(String.valueOf(svc.confirmXref(dto)));
			} catch (Exception e) {
				log.error(" xrefConfirm ERROR ! : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}
		@RequestMapping(value="/prod/xrefDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> xrefDelete(@RequestBody egovframework.sejong.user.model.ProdXrefDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getXrefSeq() == null) return ResponseEntity.status(400).body("XREF_SEQ 필요");
				dto.setUpdUser(session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "");
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteXref(dto)));
			} catch (Exception e) {
				log.error(" xrefDelete ERROR ! : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/* ================= 상품 매칭코드 (TBL_EXT_ITEM_MST) — 2026-08-01 =================
		   거래처가 **구두·문서로** 알려 주는 품목코드·품목명을 우리 상품에 붙여 두는 표.
		   화면은 별도 메뉴가 아니라 **상품코드등록(prodcd.jsp) 하단 패널** 이다 — 진입이 언제나 '우리 상품이 먼저'.
		   ★등록해 두면 발주현황표 업로드가 이 코드를 읽어 그 상품으로 해석한다(미매핑으로 안 잡힘).
		     등록이 없으면 종전과 동일 — 미매핑 → 품목코드(매핑)·[연결](TBL_PROD_XREF) 흐름 유지. */
		@RequestMapping(value="/prod/extItemList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> extItemList(@ModelAttribute("DTO") egovframework.sejong.user.model.ExtItemDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectExtItemList(dto));
			return response;
		}
		/**
		 * ★[2026-08-19 요청] 매칭코드를 붙이려는 상품이 <b>거래중지</b>면 막는 문구를 만든다. 아니면 null.
		 *
		 * <p>화면(prodcd.jsp)에서도 막고 있지만, <b>화면은 우회할 수 있다</b> — 열어 둔 창을 그대로 둔 채
		 *   다른 사람이 그 상품을 중지했거나, 주소로 직접 부르면 화면 잠금은 지나간다.
		 *   <b>자료가 실제로 들어가는 마지막 문은 여기</b>라, 규칙을 여기서 한 번 더 본다.
		 * <p>⚠<b>날짜를 견주지 않는다</b>(매입·판매의 stopBlockMsg 와 다른 점) — 매칭코드는 전표가 아니라
		 *   「앞으로 이 코드로 들어올 자료를 이 상품로 잍겠다」는 약속이다. 중지된 상품이면 날짜와 무관하게 막는다.
		 */
		private String extStopBlockMsg(Long prodSeq, HttpSession session) throws Exception {
			if (prodSeq == null) return null;
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("prodSeq", prodSeq);
			p.put("compCd", session.getAttribute("s_comp_cd"));
			egovframework.sejong.user.model.ProdDTO d = svc.selectProdStopById(p);
			if (d == null) return null;
			StringBuilder sb = new StringBuilder("거래중지된 상품에는 매칭코드를 등록할 수 없습니다.\n\n· ");
			sb.append(d.getProdCd()).append(" ").append(d.getProdNm()==null?"":d.getProdNm());
			if (d.getStopFrDt()!=null && !d.getStopFrDt().isEmpty()) sb.append("  (").append(d.getStopFrDt()).append(" 부터 중지");
			else sb.append("  (중지");
			if (d.getStopMemo()!=null && !d.getStopMemo().isEmpty()) sb.append(" · ").append(d.getStopMemo());
			sb.append(")");
			sb.append("\n\n붙여야 한다면 상품코드등록에서 [▶ 거래해제] 를 먼저 누르세요.");
			return sb.toString();
		}
		@RequestMapping(value="/prod/extItemSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> extItemSave(@RequestBody egovframework.sejong.user.model.ExtItemDTO dto,
		                                          HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getExtItemCd() == null || dto.getExtItemCd().trim().isEmpty())
					return ResponseEntity.status(400).body("품목코드 필요");
				// ★거래중지된 상품은 여기서 막는다(2026-08-19) — 화면을 거치지 않고 불러도 막힌다.
				String blk = extStopBlockMsg(dto.getProdSeq(), session);
				if (blk != null) return ResponseEntity.status(403).body(blk);   /* ★409(중복)와 가르려고 403 — 화면이 둘을 다르게 알린다 */
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				// (거래처 + 코드)는 한 건만 — UX_EXT_ITEM_CD 위반을 500 대신 안내로 돌려준다
				if (svc.countExtItemCd(dto) > 0)
					return ResponseEntity.status(409).body("이미 등록된 품목코드입니다 — " + dto.getExtItemCd());
				if (dto.getExtSeq() == null) {
					dto.setRegUser(u); dto.setRegIp(request.getRemoteAddr());
					return ResponseEntity.ok(String.valueOf(svc.insertExtItem(dto)));
				}
				dto.setUpdUser(u); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateExtItem(dto)));
			} catch (Exception e) { log.error(" extItemSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/extItemDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> extItemDelete(@RequestBody egovframework.sejong.user.model.ExtItemDTO dto,
		                                            HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getExtSeq() == null) return ResponseEntity.status(400).body("EXT_SEQ 필요");
				dto.setUpdUser(session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "");
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteExtItem(dto)));
			} catch (Exception e) { log.error(" extItemDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/* 통보서 여러 줄 붙여넣기 — 같은 (거래처+코드)면 갱신, 없으면 신규. 지우지는 않는다. */
		@RequestMapping(value="/prod/extItemBulk.do", method = RequestMethod.POST)
		public ResponseEntity<String> extItemBulk(@RequestBody java.util.List<egovframework.sejong.user.model.ExtItemDTO> list,
		                                          HttpServletRequest request, HttpSession session) {
			try {
				if (list == null || list.isEmpty()) return ResponseEntity.status(400).body("등록할 자료가 없습니다");
				/* ★거래중지 가드는 여기도 같이(2026-08-19) — 한 줄이라도 중지된 상품이면 묶음 전체를 되돌린다.
				   ⚠같은 PROD_SEQ 를 줄마다 묻지 않는다 — 중복을 걸러 한 번씩만 본다. */
				java.util.LinkedHashSet<Long> seqs = new java.util.LinkedHashSet<Long>();
				for (egovframework.sejong.user.model.ExtItemDTO d : list) if (d != null && d.getProdSeq() != null) seqs.add(d.getProdSeq());
				for (Long sq : seqs) {
					String blk = extStopBlockMsg(sq, session);
					if (blk != null) return ResponseEntity.status(403).body(blk);
				}
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				for (egovframework.sejong.user.model.ExtItemDTO d : list) { d.setRegUser(u); d.setRegIp(request.getRemoteAddr()); }
				return ResponseEntity.ok(String.valueOf(svc.mergeExtItems(list)));
			} catch (Exception e) { log.error(" extItemBulk ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/prod/inpriceList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> inpriceList(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdInpriceDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectInpriceList(dto));
			return response;
		}
		@RequestMapping(value="/prod/inpriceInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> inpriceInsert(@RequestBody egovframework.sejong.user.model.ProdInpriceDTO dto,
		                                            HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				if (dto.getInPrice()==null) return ResponseEntity.status(400).body("매입단가 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertInprice(dto)));
			} catch (Exception e) { log.error(" inpriceInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/inpriceDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> inpriceDelete(@RequestBody egovframework.sejong.user.model.ProdInpriceDTO dto,
		                                            HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getInpriceSeq()==null) return ResponseEntity.status(400).body("INPRICE_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteInprice(dto)));
			} catch (Exception e) { log.error(" inpriceDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 판매가 이력 (TBL_PROD_SALEPRICE_HST) ================= */
		@RequestMapping(value="/prod/salepriceList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salepriceList(@ModelAttribute("DTO") egovframework.sejong.user.model.ProdSalepriceDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalepriceList(dto));
			return response;
		}
		@RequestMapping(value="/prod/salepriceInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> salepriceInsert(@RequestBody egovframework.sejong.user.model.ProdSalepriceDTO dto,
		                                              HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				if (dto.getSalePrice()==null) return ResponseEntity.status(400).body("판매단가 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertSaleprice(dto)));
			} catch (Exception e) { log.error(" salepriceInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/salepriceDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> salepriceDelete(@RequestBody egovframework.sejong.user.model.ProdSalepriceDTO dto,
		                                              HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getSalepriceSeq()==null) return ResponseEntity.status(400).body("SALEPRICE_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteSaleprice(dto)));
			} catch (Exception e) { log.error(" salepriceDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 재고 수불 / 현황 (TBL_STOCK_LEDGER / TBL_STOCK_MST) ================= */
		@RequestMapping(value="/prod/stockList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockList(@ModelAttribute("DTO") egovframework.sejong.user.model.StockLedgerDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data",  svc.selectStockLedgerList(dto));   // 수불 이력
			response.put("stock", svc.selectStockMst(dto));          // 현재고 현황
			return response;
		}

		/* 재고현황 — 전체 품목 현재고(TBL_STOCK_MST) 목록 */
		@RequestMapping(value="/prod/stockStatusList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockStatusList(@ModelAttribute("DTO") egovframework.sejong.user.model.StockMstDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectStockMstList(dto));
			return response;
		}
		/* 출고현황표(대시보드) 전용 — 코드별 재고만. extQtys 를 안 만들어 664ms→29ms (2026-08-07 실측) */
		@RequestMapping(value="/prod/stockQtyMap.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockQtyMap(@ModelAttribute("DTO") egovframework.sejong.user.model.StockMstDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectStockQtyMap(dto));
			return response;
		}
		/* 마감 확정월 목록 — 재집계 팝업에 '제외되는 마감월' 표시용 */
		@RequestMapping(value="/prod/closedMonths.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> closedMonths(HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("months", svc.selectClosedYmList());
			return response;
		}
		/* (A) 출고반영 재집계 — 전체 출고를 원장 O행으로 재동기화 + 현재고 재집계 (백필 SQL 없이 화면 버튼) */
		@RequestMapping(value="/prod/stockRebuild.do", method = RequestMethod.POST)
		public ResponseEntity<String> stockRebuild(HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.rebuildShipoutLedgerAll(u, request.getRemoteAddr())));
			} catch (Exception e) { log.error(" stockRebuild ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 재집계 진행률 — 위 stockRebuild 가 도는 동안 화면이 짧은 주기로 물어본다.
		   DB 를 건드리지 않는 메모리 조회라 재집계 트랜잭션을 방해하지 않는다.
		   running=false 면 아직 시작 전이거나 이미 끝난 것 — 화면은 그때 진행바를 닫는다. */
		@RequestMapping(value="/prod/stockRebuildProgress.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockRebuildProgress(HttpSession session) {
			String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
			egovframework.sejong.cmmn.RebuildProgress.P p = egovframework.sejong.cmmn.RebuildProgress.get(u);
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("running", p != null);
			if (p != null) { res.put("phase", p.phase); res.put("done", p.done); res.put("total", p.total); }
			return res;
		}

		/* 입고내역 — 전체 입고(수불 IO_GB='I') 거래 목록 */
		@RequestMapping(value="/prod/inboundList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> inboundList(@ModelAttribute("DTO") egovframework.sejong.user.model.StockLedgerDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectInboundList(dto));
			return response;
		}
		@RequestMapping(value="/prod/stockInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> stockInsert(@RequestBody egovframework.sejong.user.model.StockLedgerDTO dto,
		                                          HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				if (dto.getIoGb()==null || dto.getIoGb().trim().isEmpty()) return ResponseEntity.status(400).body("입출구분 필요");
				if (dto.getQty()==null) return ResponseEntity.status(400).body("수량 필요");
				/* 수기 수불은 조정(A)만 받는다 — 2026-07-25.
				   입고(I)·출고(O)·반품(R)은 전표가 만든다(매입등록 PURCH / 판매등록 SALE / 발주현황표 SHIPOUT).
				   여기로 또 들어오면 재고가 두 번 움직이고 되짚을 전표가 없다.
				   화면 드롭다운에서도 조정만 남겼지만, 그 길은 우회가 되므로 서버에서 막는다. */
				if (!"A".equals(dto.getIoGb()))
					return ResponseEntity.status(400).body("수기 입력은 재고 조정(A)만 가능합니다. 입고·출고·반품은 매입등록·판매등록에서 처리하세요.");
				if (dto.getRemark()==null || dto.getRemark().trim().isEmpty())
					return ResponseEntity.status(400).body("조정 사유를 입력하세요.");
				dto.setRefGb(null); dto.setRefNo(null);   // 수기 조정은 근거 전표가 없다 — 출처 칸이 '수기 조정'으로 뜬다
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertStockLedger(dto)));
			} catch (Exception e) { log.error(" stockInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/stockDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> stockDelete(@RequestBody egovframework.sejong.user.model.StockLedgerDTO dto,
		                                          HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getLedgerSeq()==null) return ResponseEntity.status(400).body("LEDGER_SEQ 필요");
				if (dto.getProdSeq()==null)   return ResponseEntity.status(400).body("PROD_SEQ 필요"); // 재집계용
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteStockLedger(dto)));
			} catch (Exception e) { log.error(" stockDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
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
			// ★ 공통코드 관리 = 관리자 회사(TBL_COMP_MST.COMMST_YN='Y')만 (2026-07-31 — 회사/사용자 관리와 동일 가드)
			if (!"Y".equals(session.getAttribute("s_admin_yn"))) return "redirect:/main.do";
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

		/* ══════════════════════════════════════════════════════════════════════
		 *  재고 일괄조정 (2026-08-19)
		 *
		 *  기존화면의 [리스트조회] + [수정저장]. 재고의 주인은 수불원장이라
		 *  수정값으로 덮지 않고 **차이만큼 조정행(A)** 을 더한다.
		 * ════════════════════════════════════════════════════════════════════ */

		/* 화면 */
		@RequestMapping(value="/prod/stockAdj.do")
		public String stockAdj(HttpSession session, ModelMap model) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/prod/stockAdj";   // 아이프레임 전용 — 셸(상단바) 없이 화면만
		}

		/* 목록 — 기준일자까지의 누계 현재고 + BOX/EA */
		@RequestMapping(value="/prod/stockAdjList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockAdjList(@ModelAttribute("DTO") egovframework.sejong.user.model.StockMstDTO dto,
		                                       HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			dto.setCompCd((String) session.getAttribute("s_comp_cd"));
			response.put("data", svc.selectStockAdjList(dto));
			return response;
		}

		/* 일괄저장 — 고친 줄만 조정행 + 이력으로 남긴다 */
		@RequestMapping(value="/prod/stockAdjSave.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockAdjSave(@RequestBody Map<String,Object> body,
		                                       HttpSession session, HttpServletRequest request) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			try {
				egovframework.sejong.user.model.StockAdjHisDTO head =
				        new egovframework.sejong.user.model.StockAdjHisDTO();
				head.setCompCd((String) session.getAttribute("s_comp_cd"));
				head.setBaseDt(str(body.get("baseDt")));
				head.setRemark(str(body.get("remark")));
				head.setRegUser((String) session.getAttribute("s_user_id"));
				head.setRegIp(request.getRemoteAddr());

				java.util.List<egovframework.sejong.user.model.StockAdjHisDTO> rows =
				        new java.util.ArrayList<egovframework.sejong.user.model.StockAdjHisDTO>();

				Object raw = body.get("rows");
				if (raw instanceof java.util.List) {
					for (Object o : (java.util.List<?>) raw) {
						if (!(o instanceof Map)) continue;
						Map<?,?> m = (Map<?,?>) o;
						egovframework.sejong.user.model.StockAdjHisDTO r =
						        new egovframework.sejong.user.model.StockAdjHisDTO();
						r.setProdSeq(lng(m.get("prodSeq")));
						r.setProdCd(str(m.get("prodCd")));
						r.setPackQty(intg(m.get("packQty")));
						r.setBefQty(intg(m.get("befQty")));
						r.setBefBox(intg(m.get("befBox")));
						r.setBefEa(intg(m.get("befEa")));
						r.setAftBox(intg(m.get("aftBox")));
						r.setAftEa(intg(m.get("aftEa")));
						rows.add(r);
					}
				}

				int n = svc.saveStockAdjBatch(head, rows);
				response.put("result", "OK");
				response.put("cnt", Integer.valueOf(n));
				response.put("batchNo", head.getBatchNo());
			} catch (Exception e) {
				response.put("result", "FAIL");
				response.put("message", e.getMessage());
			}
			return response;
		}

		/* 조정 이력 */
		@RequestMapping(value="/prod/stockAdjHisList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockAdjHisList(@ModelAttribute("DTO") egovframework.sejong.user.model.StockAdjHisDTO dto,
		                                          HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			dto.setCompCd((String) session.getAttribute("s_comp_cd"));
			response.put("data", svc.selectStockAdjHisList(dto));
			return response;
		}

		/* 묶음 되돌리기 */
		@RequestMapping(value="/prod/stockAdjCancel.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockAdjCancel(@ModelAttribute("DTO") egovframework.sejong.user.model.StockAdjHisDTO dto,
		                                         HttpSession session, HttpServletRequest request) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			try {
				dto.setCompCd((String) session.getAttribute("s_comp_cd"));
				dto.setRegUser((String) session.getAttribute("s_user_id"));
				dto.setRegIp(request.getRemoteAddr());
				int n = svc.cancelStockAdjBatch(dto);
				response.put("result", "OK");
				response.put("cnt", Integer.valueOf(n));
			} catch (Exception e) {
				response.put("result", "FAIL");
				response.put("message", e.getMessage());
			}
			return response;
		}

		/* --- 요청 본문 값 꺼내기 (JSON 은 숫자가 Integer·Double 로 섞여 온다) --- */
		private String str(Object o) { return o == null ? null : String.valueOf(o).trim(); }
		private Integer intg(Object o) {
			if (o == null || String.valueOf(o).trim().isEmpty()) return null;
			try { return Integer.valueOf((int) Double.parseDouble(String.valueOf(o))); }
			catch (Exception e) { return null; }
		}
		private Long lng(Object o) {
			if (o == null || String.valueOf(o).trim().isEmpty()) return null;
			try { return Long.valueOf((long) Double.parseDouble(String.valueOf(o))); }
			catch (Exception e) { return null; }
		}

		/* 입수수량 일괄 저장 — BOX/EA 환산 기준만 바꾼다(재고는 안 건드림) */
		@RequestMapping(value="/prod/packQtySave.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> packQtySave(@RequestBody Map<String,Object> body,
		                                      HttpSession session, HttpServletRequest request) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			try {
				String compCd = (String) session.getAttribute("s_comp_cd");
				String user   = (String) session.getAttribute("s_user_id");
				String ip     = request.getRemoteAddr();

				java.util.List<egovframework.sejong.user.model.StockMstDTO> rows =
				        new java.util.ArrayList<egovframework.sejong.user.model.StockMstDTO>();

				Object raw = body.get("rows");
				if (raw instanceof java.util.List) {
					for (Object o : (java.util.List<?>) raw) {
						if (!(o instanceof Map)) continue;
						Map<?,?> m = (Map<?,?>) o;
						egovframework.sejong.user.model.StockMstDTO r =
						        new egovframework.sejong.user.model.StockMstDTO();
						r.setCompCd(compCd);
						r.setProdSeq(lng(m.get("prodSeq")));
						r.setPackQty(intg(m.get("packQty")));
						r.setRegUser(user);
						r.setRegIp(ip);
						rows.add(r);
					}
				}
				int n = svc.saveProdPackQty(rows);
				response.put("result", "OK");
				response.put("cnt", Integer.valueOf(n));
			} catch (Exception e) {
				response.put("result", "FAIL");
				response.put("message", e.getMessage());
			}
			return response;
		}
}
