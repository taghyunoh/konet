package egovframework.konet.user.web;

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

import egovframework.konet.admin.service.AdminService;
import egovframework.konet.user.model.CodeMdDTO;
import egovframework.konet.user.model.CompConDTO;
import egovframework.konet.user.model.CompMdDTO;
import egovframework.konet.user.model.SjgnDTO;
import egovframework.konet.user.model.UserDTO;
import egovframework.konet.user.service.UserService;
import egovframework.util.EgovFileScrty;

import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestBody;
import egovframework.konet.util.ResponseObject;

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
			if (!isChief(session)) return "redirect:/main.do";   // ★관리자 회사여도 총괄관리자(MAIN_GU='1')만 (2026-09-17)
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

		/** 거래명세표 <공급자(우리 회사)> 칸 — 업태·종목·계좌·공지사항만 저장 (2026-09-09)
		 *  판매등록 ▸ [🖨 거래명세표] ▸ 공급자 칸의 [💾 회사 정보로 저장] 이 부른다.
		 *  ★회사코드는 화면 값을 받지 않고 <세션>에서 꺼낸다 — 남의 회사 마스터를 고칠 길을 만들지 않는다.
		 *  ★인쇄 양식 칸이라 이력(JOB_SEQ)을 만들지 않고 활성행을 그 자리에서 고친다(updateCompBizInfo). */
		@RequestMapping(value="/user/compBizInfoSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> compBizInfoSave(@RequestParam(value="bizCond",  required=false) String bizCond,
		                                              @RequestParam(value="bizItem",  required=false) String bizItem,
		                                              @RequestParam(value="bankAcct", required=false) String bankAcct,
		                                              @RequestParam(value="stmtNotice", required=false) String stmtNotice,
		                                              HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				CompMdDTO dto = new CompMdDTO();
				dto.setCompCd(String.valueOf(session.getAttribute("s_comp_cd")));
				dto.setBizCond(bizCond == null ? "" : bizCond.trim());
				dto.setBizItem(bizItem == null ? "" : bizItem.trim());
				dto.setBankAcct(bankAcct == null ? "" : bankAcct.trim());
				dto.setStmtNotice(stmtNotice == null ? "" : stmtNotice.trim());
				dto.setUpdUser(session.getAttribute("s_user_id") == null ? "" : String.valueOf(session.getAttribute("s_user_id")));
				dto.setUpdIp(request.getRemoteAddr());
				int cnt = svc.updateCompBizInfo(dto);
				if (cnt == 0) return ResponseEntity.status(404).body("회사 정보를 찾을 수 없습니다.");
				return ResponseEntity.ok(String.valueOf(cnt));
			} catch (Exception e) {
				log.error(" compBizInfoSave ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		// ============================================================
		// 회사 정보 수정 (기준정보관리 ▸ 회사 정보 수정, 2026-09-11) — compInfo.jsp
		//   ★모든 회사가 쓴다(관리자 전용 아님). 회사코드는 늘 <세션>에서 — 화면 값을 받지 않는다.
		//   ★쓰기는 세션 회사코드가 비면 거절한다(fail-open 이 쓰기에 걸리면 전 회사가 바뀐다).
		//   화면 3장(① 필수·기본 정보 ② 도장 ③ 거래명세서 인쇄 옵션 + 「기능」) 을 한 화면에 담는다.
		// ============================================================
		private static final com.fasterxml.jackson.databind.ObjectMapper COMP_JSON = new com.fasterxml.jackson.databind.ObjectMapper();

		private String sessComp(HttpSession session) {
			Object c = session.getAttribute("s_comp_cd");
			return c == null ? "" : String.valueOf(c).trim();
		}
		private Map<String,Object> compParam(HttpSession session, HttpServletRequest request) {
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("compCd", sessComp(session));
			p.put("updUser", session.getAttribute("s_user_id") == null ? "" : String.valueOf(session.getAttribute("s_user_id")));
			if (request != null) p.put("updIp", request.getRemoteAddr());
			return p;
		}
		/** SQL 이 직접 봐야 하는 설정(평균 매입단가 0원 포함)만 칸으로 따로 둔다 — DB 가 2012 라 JSON_VALUE 가 없다 */
		@SuppressWarnings("unchecked")
		private static String avgZeroOf(Object set) {
			if (set instanceof Map) {
				Object f = ((Map<String,Object>) set).get("func");
				if (f instanceof Map && "N".equals(String.valueOf(((Map<String,Object>) f).get("avgZero")))) return "N";
			}
			return "Y";
		}
		private static String trimStr(Object o, int max) {
			if (o == null) return "";
			String s = String.valueOf(o).trim();
			return s.length() > max ? s.substring(0, max) : s;
		}

		@RequestMapping(value="/mangr/compInfo.do")
		public String compInfo(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/compInfo";
		}

		/** 화면이 여는 순간 한 번 — 회사 정보 + 설정 + 계좌·카드 목록 */
		@RequestMapping(value="/user/compInfoGet.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> compInfoGet(HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (sessComp(session).isEmpty()) { res.put("error", "로그인이 필요합니다."); return res; }
			Map<String,Object> p = compParam(session, null);
			Map<String,Object> info = svc.selectCompInfoFull(p);
			res.put("info", info == null ? new HashMap<String,Object>() : info);
			res.put("bank", svc.selectCompBankList(p));
			res.put("card", svc.selectCompCardList(p));
			return res;
		}

		/** 다른 화면(판매·매입·수금·상품·거래처 등록)이 「기능」·인쇄 옵션을 읽는 곳 — 설정 JSON 만 돌려준다 */
		@RequestMapping(value="/user/compSetGet.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> compSetGet(HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (sessComp(session).isEmpty()) return res;
			String js = svc.selectCompSetJson(compParam(session, null));
			res.put("setJson", js == null ? "" : js);
			return res;
		}

		/** ① 필수·기본 정보 + 설정(JSON) 저장 — body = {info:{...}, set:{...}} */
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/user/compInfoSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> compInfoSave(@RequestBody Map<String,Object> body, HttpServletRequest request, HttpSession session) {
			try {
				if (sessComp(session).isEmpty()) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				Map<String,Object> info = body.get("info") instanceof Map ? (Map<String,Object>) body.get("info") : null;
				Object set = body.get("set");
				int cnt = 0;
				if (info != null) {
					Map<String,Object> p = compParam(session, request);
					String[][] cols = {
						{"compNm","100"},{"compCeo","50"},{"busiNum","20"},{"bizCond","100"},{"bizItem","200"},
						{"zipCd","10"},{"compAddr","200"},{"compExtradr","200"},{"compHp","30"},{"compTel","30"},
						{"compFax","30"},{"compEmail","100"},{"foundDt","10"},{"corpNo","20"},{"ceoBirth","10"},
						{"bankAcct","200"},{"stmtNotice","500"},{"stmtNotice2","500"} };
					for (String[] c : cols) p.put(c[0], trimStr(info.get(c[0]), Integer.parseInt(c[1])));
					if (String.valueOf(p.get("compNm")).isEmpty() || String.valueOf(p.get("compCeo")).isEmpty()
					 || String.valueOf(p.get("busiNum")).isEmpty())
						return ResponseEntity.status(400).body("회사명·대표자명·사업자번호는 꼭 넣어야 합니다.");
					cnt = svc.updateCompInfoSelf(p);
					if (cnt == 0) return ResponseEntity.status(404).body("회사 정보를 찾을 수 없습니다.");
					// 거래명세표 화면이 세션 회사명을 쓰는 곳이 있어 함께 맞춘다
					session.setAttribute("s_comp_nm", p.get("compNm"));
				}
				if (set instanceof Map) {
					Map<String,Object> p = compParam(session, request);
					p.put("setJson", COMP_JSON.writeValueAsString(set));
					p.put("avgZeroYn", avgZeroOf(set));
					svc.mergeCompSetJson(p);
				}
				return ResponseEntity.ok(String.valueOf(cnt));
			} catch (Exception e) {
				log.error(" compInfoSave ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/** 설정 한 덩어리만 고친다 — body = {key:"prt", val:{...}}
		 *  판매등록 거래명세표 조건 창의 [회사 기본값으로 저장] 이 부른다(설정 전체를 들고 있지 않으므로 그 덩어리만). */
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/user/compSetPatch.do", method = RequestMethod.POST)
		public ResponseEntity<String> compSetPatch(@RequestBody Map<String,Object> body, HttpServletRequest request, HttpSession session) {
			try {
				if (sessComp(session).isEmpty()) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String key = trimStr(body.get("key"), 20);
				if (!key.matches("func|prt|prtApp|cost")) return ResponseEntity.status(400).body("알 수 없는 설정입니다.");   // cost = 원가·마진 계산의 센터 비율·보관 기본값 (2026-09-17)
				Map<String,Object> p = compParam(session, request);
				String js = svc.selectCompSetJson(p);
				Map<String,Object> all = (js == null || js.trim().isEmpty())
					? new java.util.LinkedHashMap<String,Object>() : COMP_JSON.readValue(js, java.util.LinkedHashMap.class);
				all.put(key, body.get("val"));
				p.put("setJson", COMP_JSON.writeValueAsString(all));
				p.put("avgZeroYn", avgZeroOf(all));
				svc.mergeCompSetJson(p);
				return ResponseEntity.ok("1");
			} catch (Exception e) {
				log.error(" compSetPatch ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/** ② 도장 — data URL 한 줄(화면이 300px 안쪽 PNG 로 줄여 보낸다). 빈 값 = 지우기 */
		@RequestMapping(value="/user/compStampSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> compStampSave(@RequestParam(value="stampImg", required=false) String stampImg,
		                                            HttpServletRequest request, HttpSession session) {
			try {
				if (sessComp(session).isEmpty()) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String v = stampImg == null ? "" : stampImg.trim();
				if (!v.isEmpty()) {
					if (!v.matches("^data:image/(png|jpeg|gif|webp);base64,[A-Za-z0-9+/=]+$"))
						return ResponseEntity.status(400).body("그림 파일(png·jpg·gif·webp)만 올릴 수 있습니다.");
					if (v.length() > 900000) return ResponseEntity.status(400).body("그림이 너무 큽니다.");
				}
				Map<String,Object> p = compParam(session, request);
				p.put("stampImg", v.isEmpty() ? null : v);
				svc.mergeCompStamp(p);
				return ResponseEntity.ok("1");
			} catch (Exception e) {
				log.error(" compStampSave ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/** 은행계좌 관리 — body = {bankSeq?, bankNm, acctNo, acctHolder, aliasNm, sortOrd} */
		@RequestMapping(value="/user/compBankSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> compBankSave(@RequestBody Map<String,Object> body, HttpServletRequest request, HttpSession session) {
			try {
				if (sessComp(session).isEmpty()) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				Map<String,Object> p = compParam(session, request);
				p.put("bankSeq", body.get("bankSeq") == null || String.valueOf(body.get("bankSeq")).isEmpty() ? null : Long.valueOf(String.valueOf(body.get("bankSeq"))));
				p.put("bankNm", trimStr(body.get("bankNm"), 50));
				p.put("acctNo", trimStr(body.get("acctNo"), 50));
				p.put("acctHolder", trimStr(body.get("acctHolder"), 100));
				p.put("aliasNm", trimStr(body.get("aliasNm"), 100));
				p.put("sortOrd", body.get("sortOrd") == null || String.valueOf(body.get("sortOrd")).isEmpty() ? null : Integer.valueOf(String.valueOf(body.get("sortOrd"))));
				if (String.valueOf(p.get("bankNm")).isEmpty() || String.valueOf(p.get("acctNo")).isEmpty())
					return ResponseEntity.status(400).body("은행명과 계좌번호를 넣어 주세요.");
				int cnt = svc.saveCompBank(p);
				if (cnt == 0) return ResponseEntity.status(404).body("계좌를 찾을 수 없습니다.");
				return ResponseEntity.ok(String.valueOf(cnt));
			} catch (Exception e) {
				log.error(" compBankSave ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}
		@RequestMapping(value="/user/compBankDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> compBankDelete(@RequestParam("bankSeq") Long bankSeq, HttpServletRequest request, HttpSession session) {
			try {
				if (sessComp(session).isEmpty()) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				Map<String,Object> p = compParam(session, request);
				p.put("bankSeq", bankSeq);
				return ResponseEntity.ok(String.valueOf(svc.deleteCompBank(p)));
			} catch (Exception e) {
				log.error(" compBankDelete ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		/** 카드 관리 — ★카드번호는 뒤 4자리만 받는다(숫자 4개가 아니면 버린다) */
		@RequestMapping(value="/user/compCardSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> compCardSave(@RequestBody Map<String,Object> body, HttpServletRequest request, HttpSession session) {
			try {
				if (sessComp(session).isEmpty()) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				Map<String,Object> p = compParam(session, request);
				p.put("cardSeq", body.get("cardSeq") == null || String.valueOf(body.get("cardSeq")).isEmpty() ? null : Long.valueOf(String.valueOf(body.get("cardSeq"))));
				p.put("cardCo", trimStr(body.get("cardCo"), 50));
				p.put("cardNm", trimStr(body.get("cardNm"), 100));
				String l4 = trimStr(body.get("cardLast4"), 40).replaceAll("[^0-9]", "");
				p.put("cardLast4", l4.length() >= 4 ? l4.substring(l4.length() - 4) : "");
				p.put("cardUser", trimStr(body.get("cardUser"), 50));
				p.put("cardGb", trimStr(body.get("cardGb"), 10));
				p.put("remark", trimStr(body.get("remark"), 200));
				p.put("sortOrd", body.get("sortOrd") == null || String.valueOf(body.get("sortOrd")).isEmpty() ? null : Integer.valueOf(String.valueOf(body.get("sortOrd"))));
				if (String.valueOf(p.get("cardCo")).isEmpty() && String.valueOf(p.get("cardNm")).isEmpty())
					return ResponseEntity.status(400).body("카드사나 카드 이름을 넣어 주세요.");
				int cnt = svc.saveCompCard(p);
				if (cnt == 0) return ResponseEntity.status(404).body("카드를 찾을 수 없습니다.");
				return ResponseEntity.ok(String.valueOf(cnt));
			} catch (Exception e) {
				log.error(" compCardSave ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}
		@RequestMapping(value="/user/compCardDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> compCardDelete(@RequestParam("cardSeq") Long cardSeq, HttpServletRequest request, HttpSession session) {
			try {
				if (sessComp(session).isEmpty()) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				Map<String,Object> p = compParam(session, request);
				p.put("cardSeq", cardSeq);
				return ResponseEntity.ok(String.valueOf(svc.deleteCompCard(p)));
			} catch (Exception e) {
				log.error(" compCardDelete ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
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
		public ResponseEntity<String> saveShipoutMst(@RequestBody List<egovframework.konet.user.model.ShipoutDTO> rows,
		                                             HttpServletRequest request, HttpSession session) {
			try {
				if (rows == null || rows.isEmpty()) return ResponseEntity.ok("0");

				String regUser = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				               : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : "");
				String regIp   = request.getRemoteAddr();

				// (납품일자 DLV_DT + 물류센터 DC_CD) 복합키로 묶어 각 조합을 1배치로 저장 (출고일자·사업장은 키 아님)
				java.util.LinkedHashMap<String, java.util.List<egovframework.konet.user.model.ShipoutDTO>> groups
				    = new java.util.LinkedHashMap<String, java.util.List<egovframework.konet.user.model.ShipoutDTO>>();
				for (egovframework.konet.user.model.ShipoutDTO r : rows) {
					String key = (r.getDlvDt() == null ? "" : r.getDlvDt())
					           + "|" + (r.getDcCd() == null ? "" : r.getDcCd());
					java.util.List<egovframework.konet.user.model.ShipoutDTO> g = groups.get(key);
					if (g == null) { g = new java.util.ArrayList<egovframework.konet.user.model.ShipoutDTO>(); groups.put(key, g); }
					g.add(r);
				}

				int total = 0;
				java.util.LinkedHashSet<String> syncDates = new java.util.LinkedHashSet<String>();
				for (java.util.List<egovframework.konet.user.model.ShipoutDTO> grp : groups.values()) {
					// 0) 이력마감으로 사라질 기존 활성배치의 출고일자 수집  1) 같은 (납품일자,물류센터) 기존 활성배치 이력마감(삭제이력)
					// 2) 신규 JOB_SEQ  3) 그룹 전체행 INSERT
					egovframework.konet.user.model.ShipoutDTO head = grp.get(0);
					head.setUpdUser(regUser);
					head.setUpdIp(regIp);
					// ★[2026-09-03] 재고원장 키 = 납기일자(DLV_DT). 배치 키가 (납품일자,물류센터)라 옛 배치도 같은 납기일자 → 그 날 하나만 재동기화하면 된다.
					//   (종전엔 옛 배치의 출고일자들(selectShipoutActiveShpoutDts)을 모았다 — 출고일자 키였을 때 얘기)
					String _dlv = (head.getDlvDt() == null) ? "" : head.getDlvDt().trim().replace("-", "");
					//   ※ DB 값은 'yyyymmdd', 화면에서 온 값은 'yyyy-mm-dd' — 같은 날이 두 번 돌지 않게 '-' 를 떼어 담는다.
					if (!_dlv.isEmpty()) syncDates.add(_dlv);
					svc.markShipoutHistory(head);

					int jobSeq = svc.getShipoutNextJobSeq(head);
					int seq = 0;
					/* ★행마다 INSERT 를 던지지 않고 <40행씩 묶어> 한 문장으로 넣는다 (2026-08-28 속도 개선).
					     종전 : 4,564행 업로드 = INSERT 왕복 4,564번 → 「서버 반영 중…」에서 오래 멈췄다.
					     지금 : 약 115문장. 값 채우는 순서·내용은 종전과 같다(JOB_SEQ·ROW_NO·등록자).
					   ⚠40행 상한은 지킬 것 — SQL Server 는 한 문장의 파라미터가 2,100개를 넘을 수 없고
					     이 INSERT 는 행당 41개를 쓴다(40행 = 1,640개). 늘리면 런타임에 터진다. */
					final int BULK = 40;
					java.util.List<egovframework.konet.user.model.ShipoutDTO> buf
					    = new java.util.ArrayList<egovframework.konet.user.model.ShipoutDTO>(BULK);
					for (egovframework.konet.user.model.ShipoutDTO r : grp) {
						r.setJobSeq(jobSeq);
						r.setActionYn("Y");
						if (r.getRowNo() == null) r.setRowNo(seq + 1);
						r.setRegUser(regUser);
						r.setRegIp(regIp);
						buf.add(r);
						seq++; total++;
						if (buf.size() >= BULK) { svc.insertShipoutMstBulk(buf); buf.clear(); }
					}
					if (!buf.isEmpty()) { svc.insertShipoutMstBulk(buf); buf.clear(); }
					/* ★거래처 코드 → 우리 품목 해석 (2026-08-01). 반드시 INSERT 뒤·재고연동(A) 앞.
					   · 원본 ITEM_CD/ITEM_NM 은 건드리지 않는다. PROD_SEQ 칸만 채운다.
					   · 행마다 조회하지 않는다 — 배치 단위 UPDATE 한 문장(resolveShipoutProd).
					   · 매핑이 없으면 PROD_SEQ 가 NULL 로 남고, 그 행은 재고연동에서 자연히 빠진다
					     (= 미매핑 보류). 나중에 매핑을 걸면 saveXref 가 소급으로 채운다. */
					egovframework.konet.user.model.ProdXrefDTO rx = new egovframework.konet.user.model.ProdXrefDTO();
					rx.setJobSeq(Long.valueOf(jobSeq));
					rx.setDlvDt(head.getDlvDt());
					rx.setDcCd(head.getDcCd());
					svc.resolveShipoutProd(rx);

					// 새 배치의 납기일자(행 단위로 모은다 — 원장 키가 납기일자, 2026-09-03). 납기일자가 빈 행만 출고일자로 대신한다.
					for (egovframework.konet.user.model.ShipoutDTO r : grp) {
						String _rd = (r.getDlvDt() != null && !r.getDlvDt().trim().isEmpty()) ? r.getDlvDt() : r.getShpoutDt();
						if (_rd != null && !_rd.trim().isEmpty()) syncDates.add(_rd.trim().replace("-", ""));
					}
				}
				// (A) 출고→재고 자동연동 : 저장된 출고일자별로 원장 O행 재동기화 후 전체 현재고 재집계
				//     (재고 동기화 실패가 출고 저장 자체를 롤백하지 않도록 별도 try — 실패 시 로그만)
				/* ★★실패를 <조용히> 넘기지 않는다 (2026-09-10 신설) —
				   종전에는 로그만 남기고 업로드는 «성공»으로 끝났다. 그러면 자료는 들어갔는데 재고만 안 맞고,
				   그 사실을 아무도 모른 채 나중에 「재고조정도 안 했는데 재고가 틀어졌다」로 나타난다
				   (사용자가 [출고반영 재집계]를 습관적으로 누르게 된 이유이기도 하다).
				   ⇒ 저장 자체는 그대로 성공시키되(롤백하면 올린 자료를 잃는다), <재고 반영이 안 됐다>는 사실을
				     응답에 실어 화면이 곧바로 알리게 한다. 화면은 그때 [출고반영 재집계]를 권한다.
				   ★글자 모양 : "<건수>|STOCKFAIL:<사유>" — 앞의 건수는 종전 그대로라 옛 화면도 안 깨진다. */
				/* ★사업장 자동 등록 + 주소 없는 직송 사업장 (2026-09-16 P2-c, 목적 ④「삼성 발주 정확한 배송」)
				   종전엔 업로드가 사업장 마스터(TBL_BIZI_MST)를 안 만들어, 새 직송 사업장은 택배납기관리에서 「신규」 배지 + 빈 주소로만 드러났다.
				   ⇒ 올라온 사업장 코드·이름을 마스터에 넣고(있으면 그대로 — insertBiziIfAbsent), 직송 사업장 중 주소가 없는 것을 응답에 실어
				     화면이 바로 알리고 택배납기관리로 보낸다. 실패해도 업로드는 그대로 성공(try 로 감싼다 — 사업장 등록이 자료 저장을 막으면 안 된다).
				   ★응답 꼬리 "|BIZ:{json}" — 화면이 lastIndexOf 로 떼어 낸다(옛 화면은 건수 앞부분만 읽으므로 안 깨진다). */
				String bizInfo = "";
				try {
					java.util.LinkedHashMap<String,String> allBiz = new java.util.LinkedHashMap<String,String>();
					java.util.LinkedHashSet<String> jikBiz = new java.util.LinkedHashSet<String>();
					for (egovframework.konet.user.model.ShipoutDTO r : rows) {
						String bc = r.getBizCd() == null ? "" : r.getBizCd().trim();
						String bn = r.getBizNm() == null ? "" : r.getBizNm().trim();
						if (bc.isEmpty() || bn.isEmpty()) continue;
						if (!allBiz.containsKey(bc)) allBiz.put(bc, bn);
						String zn = r.getZone() == null ? "" : r.getZone().trim(), dg = r.getDlvGb() == null ? "" : r.getDlvGb().trim();
						if ("직송".equals(zn) || "직송".equals(dg)) jikBiz.add(bc);
					}
					int newCnt = 0;
					for (java.util.Map.Entry<String,String> e : allBiz.entrySet()) {
						egovframework.konet.user.model.BiziDTO b = new egovframework.konet.user.model.BiziDTO();
						b.setCompCd(session.getAttribute("s_comp_cd") == null ? null : String.valueOf(session.getAttribute("s_comp_cd")));
						b.setBizCd(e.getKey()); b.setBizNm(e.getValue()); b.setRegUser(regUser); b.setRegIp(regIp);
						newCnt += svc.insertBiziIfAbsent(b);
					}
					StringBuilder sb = new StringBuilder("{\"newCnt\":" + newCnt + ",\"noAddr\":[");
					if (!jikBiz.isEmpty()) {
						java.util.List<String> codes = new java.util.ArrayList<String>(jikBiz);
						if (codes.size() > 500) codes = codes.subList(0, 500);   // 한 문장 파라미터 상한(2,100) 안
						Map<String,Object> q = new HashMap<String,Object>();
						q.put("codes", codes); q.put("compCd", session.getAttribute("s_comp_cd"));
						java.util.List<Map<String,Object>> na = svc.selectBiziNoAddr(q);
						int k = 0;
						for (Map<String,Object> m : na) {
							if (k++ > 0) sb.append(",");
							sb.append("{\"bizCd\":\"").append(poJs(m.get("bizCd"))).append("\",\"bizNm\":\"").append(poJs(m.get("bizNm"))).append("\"}");
						}
					}
					bizInfo = "|BIZ:" + sb.append("]}").toString();
				} catch (Exception be) { log.error(" saveShipoutMst 사업장 등록 WARN : " + be.getMessage()); bizInfo = ""; }
				String stockWarn = null;
				try {
					for (String d : syncDates) svc.syncShipoutLedgerDate(d, regUser, regIp);
					if (!syncDates.isEmpty()) svc.recalcStockMstAll(regUser, regIp);
				} catch (Exception se) {
					log.error(" saveShipoutMst 재고연동 WARN : " + se.getMessage());
					stockWarn = (se.getMessage() == null || se.getMessage().trim().isEmpty())
					          ? se.getClass().getSimpleName() : se.getMessage().trim();
				}
				return ResponseEntity.ok(String.valueOf(total)
				        + (stockWarn == null ? "" : "|STOCKFAIL:" + stockWarn)
				        + bizInfo);
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
		public ResponseEntity<Map<String,Object>> saveSalesMst(@RequestBody List<egovframework.konet.user.model.SalesDTO> rows,
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
				java.util.LinkedHashMap<String, java.util.List<egovframework.konet.user.model.SalesDTO>> groups
				    = new java.util.LinkedHashMap<String, java.util.List<egovframework.konet.user.model.SalesDTO>>();
				for (egovframework.konet.user.model.SalesDTO r : rows) {
					String key = (r.getDlvDt() == null ? "" : r.getDlvDt())
					           + "|" + (r.getDcNm() == null ? "" : r.getDcNm());
					java.util.List<egovframework.konet.user.model.SalesDTO> g = groups.get(key);
					if (g == null) { g = new java.util.ArrayList<egovframework.konet.user.model.SalesDTO>(); groups.put(key, g); }
					g.add(r);
				}

				int total = 0;
				for (java.util.List<egovframework.konet.user.model.SalesDTO> grp : groups.values()) {
					// 1) 같은 (납품일자,출고장) 기존 활성배치 이력마감  2) 신규 JOB_SEQ  3) 그룹 전체행 INSERT
					egovframework.konet.user.model.SalesDTO head = grp.get(0);
					head.setUpdUser(regUser);
					head.setUpdIp(regIp);
					svc.markSalesHistory(head);

					int jobSeq = svc.getSalesNextJobSeq(head);
					int seq = 0;
					for (egovframework.konet.user.model.SalesDTO r : grp) {
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
					egovframework.konet.user.model.ProdXrefDTO rx = new egovframework.konet.user.model.ProdXrefDTO();
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
					for (egovframework.konet.user.model.SalesDTO r : rows)
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
					java.util.LinkedHashMap<String, egovframework.konet.user.model.SalesDTO> pmap
					    = new java.util.LinkedHashMap<String, egovframework.konet.user.model.SalesDTO>();
					java.util.HashSet<String> conflict = new java.util.HashSet<String>();
					for (egovframework.konet.user.model.SalesDTO r : rows) {
						if (r.getItemCd() == null || r.getItemCd().trim().isEmpty()) continue;
						if (r.getDlvDt()  == null || r.getDlvDt().trim().isEmpty())  continue;
						if (r.getSalePrice() == null) continue;
						String k = r.getItemCd().trim() + "|" + r.getDlvDt().trim();
						egovframework.konet.user.model.SalesDTO p = pmap.get(k);
						if (p == null) pmap.put(k, r);
						else if (p.getSalePrice().compareTo(r.getSalePrice()) != 0) conflict.add(k);
					}
					for (java.util.Map.Entry<String, egovframework.konet.user.model.SalesDTO> en : pmap.entrySet()) {
						if (conflict.contains(en.getKey())) { pSkip++; continue; }
						egovframework.konet.user.model.SalesDTO src = en.getValue();
						egovframework.konet.user.model.SalesDTO h = new egovframework.konet.user.model.SalesDTO();
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
		public Map<String,Object> selectSalesMst(@ModelAttribute("DTO") egovframework.konet.user.model.SalesDTO dto,
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
		public ResponseEntity<String> insertVendorMst(@RequestBody egovframework.konet.user.model.VendorDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getVendorCd()==null || dto.getVendorCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처코드 필요");
				if (svc.vendorDupChk(dto) > 0) return ResponseEntity.status(409).body("이미 존재하는 거래처코드입니다: "+dto.getVendorCd());
				dto.setRegUser(session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertVendorMst(dto)));
			} catch (Exception e) { log.error(" insertVendorMst ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/vendor/updateVendorMst.do", method = RequestMethod.POST)
		public ResponseEntity<String> updateVendorMst(@RequestBody egovframework.konet.user.model.VendorDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getVendorCd()==null || dto.getVendorCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처코드 필요");
				dto.setUpdUser(session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateVendorMst(dto)));
			} catch (Exception e) { log.error(" updateVendorMst ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/vendor/deleteVendorMst.do", method = RequestMethod.POST)
		public ResponseEntity<String> deleteVendorMst(@RequestBody egovframework.konet.user.model.VendorDTO dto, HttpServletRequest request, HttpSession session) {
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
		public ResponseEntity<String> uploadVendorMst(@RequestBody List<egovframework.konet.user.model.VendorDTO> rows, HttpServletRequest request, HttpSession session) {
			try {
				if (rows == null || rows.isEmpty()) return ResponseEntity.ok("0");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.konet.user.model.VendorDTO r : rows) {
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
		public Map<String,Object> selectVendorMst(@ModelAttribute("DTO") egovframework.konet.user.model.VendorDTO dto,
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
		public Map<String,Object> vendorTrxSum(@ModelAttribute("DTO") egovframework.konet.user.model.VendorDTO dto,
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
		public Map<String,Object> renameSalesDc(@ModelAttribute("DTO") egovframework.konet.user.model.SalesDTO dto,
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

		/* ================= 견적서 관리 (2026-09-17) — 화면 mangr/quoteMng.jsp =================
		   우리가 낸 견적서 엑셀(xls/xlsx)을 올려 문서번호·견적일·수신·담당자·품목을 저장하고 목록으로 관리. 원본 파일도 같이 보관(내려받기).
		   멀티파트 설정이 없어 파일은 base64 JSON 으로 받는다(DC 발주 등록과 같은 길). */
		@RequestMapping(value="/mangr/quoteMng.do")
		public String quoteMng(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/quoteMng";
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/mangr/quoteParse.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteParse(@RequestBody Map<String,Object> p, HttpSession session) {
			Map<String,Object> res = new HashMap<String,Object>();
			List<Map<String,Object>> docs = new java.util.ArrayList<Map<String,Object>>();
			List<String> errs = new java.util.ArrayList<String>();
			if (session.getAttribute("s_comp_cd") == null) { errs.add("로그인이 필요합니다."); res.put("docs", docs); res.put("errors", errs); return res; }
			List<Map<String,Object>> files = (List<Map<String,Object>>) p.get("files");
			if (files != null) for (Map<String,Object> fl : files) {
				String nm = poStr(fl.get("name"));
				try {
					String b64 = poStr(fl.get("b64")); int cm = b64.indexOf(','); if (b64.startsWith("data:") && cm > 0) b64 = b64.substring(cm + 1);
					byte[] b = Base64.getDecoder().decode(b64);
					if (b.length > 5 * 1024 * 1024) { errs.add(nm + " : 5MB 가 넘습니다."); continue; }
					Map<String,Object> q = svc.parseQuoteXls(b, nm);
					q.put("fileB64", b64);
					/* 기존에 올린 게 있는지 (2026-09-17) — 미리보기에 「이미 올린 견적서」 배지 */
					if (!poStr(q.get("docNo")).isEmpty()) { Map<String,Object> k = new HashMap<String,Object>(); k.put("compCd", session.getAttribute("s_comp_cd")); k.put("docNo", poStr(q.get("docNo"))); q.put("exists", svc.selectQuoteByDoc(k)); }
					if (((List<?>) q.get("lines")).isEmpty() && poStr(q.get("docNo")).isEmpty()) errs.add(nm + " : 견적서 양식을 찾지 못했습니다(문서 번호·품명·수량·단가 머리글이 있어야 합니다).");
					docs.add(q);
				} catch (Exception e) {
					log.error(" quoteParse " + nm + " : " + e.getMessage());
					errs.add(nm + " : 읽지 못했습니다 — " + e.getClass().getSimpleName() + (e.getMessage() == null ? "" : " " + e.getMessage()));
				}
			}
			res.put("docs", docs); res.put("errors", errs);
			return res;
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/mangr/quoteSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> quoteSave(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String compCd = String.valueOf(session.getAttribute("s_comp_cd"));
				List<Map<String,Object>> docs = (List<Map<String,Object>>) p.get("docs");
				if (docs == null || docs.isEmpty()) return ResponseEntity.status(400).body("저장할 견적서가 없습니다.");
				/* ★기존에 올린 게 있으면 먼저 묻는다 (2026-09-17) — confirm=Y 가 아니면 409 + 「문서번호(등록일시·담당자)」 목록. 화면이 확인창을 띄우고 confirm=Y 로 다시 보낸다.
				   화면 목록(기간 필터)이 아니라 서버가 문서번호로 찾으므로 기간 밖에 있는 것도 잡는다. */
				if (!"Y".equals(poStr(p.get("confirm")))) {
					StringBuilder dup = new StringBuilder();
					for (Map<String,Object> q : docs) {
						String dn = poStr(q.get("docNo")); if (dn.isEmpty()) continue;
						Map<String,Object> k = new HashMap<String,Object>(); k.put("compCd", compCd); k.put("docNo", dn);
						Map<String,Object> ex = svc.selectQuoteByDoc(k);
						if (ex != null) { if (dup.length() > 0) dup.append("\n"); dup.append(dn).append(" (").append(poStr(ex.get("regDttm")).length() >= 16 ? poStr(ex.get("regDttm")).substring(0, 16) : poStr(ex.get("regDttm"))).append(poStr(ex.get("regUser")).isEmpty() ? "" : " · " + poStr(ex.get("regUser"))).append(")"); }
					}
					if (dup.length() > 0) return ResponseEntity.status(409).body(dup.toString());
				}
				int n = 0; StringBuilder seqs = new StringBuilder(); long lastSeq = 0;
				for (Map<String,Object> q : docs) { long s = svc.saveQuote(q, u, request.getRemoteAddr(), compCd); if (seqs.length() > 0) seqs.append(','); seqs.append(s); lastSeq = s; n++; }
				/* JSON 으로 (2026-09-17 「저장 출력 오류」) — 종전 「n|번호」 글자를 화면이 번호로 못 읽어 출력·재저장이 「저장 전」으로 취급됐다 */
				return ResponseEntity.ok().header("Content-Type", "application/json;charset=UTF-8").body("{\"cnt\":" + n + ",\"seqs\":[" + seqs + "],\"seq\":" + lastSeq + "}");
			} catch (Exception e) { log.error(" quoteSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/quoteList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteList(@RequestParam(value="frDt", required=false) String frDt, @RequestParam(value="toDt", required=false) String toDt,
		                                    @RequestParam(value="mgrNm", required=false) String mgrNm, @RequestParam(value="findData", required=false) String findData,
		                                    HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("data", new java.util.ArrayList<Object>()); return res; }
			Map<String,Object> q = new HashMap<String,Object>();
			q.put("compCd", session.getAttribute("s_comp_cd")); q.put("frDt", frDt); q.put("toDt", toDt); q.put("mgrNm", mgrNm); q.put("findData", findData);
			res.put("data", svc.selectQuoteList(q));
			return res;
		}
		@RequestMapping(value="/mangr/quoteDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteDetail(@RequestParam("quoteSeq") long quoteSeq, HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("data", new java.util.ArrayList<Object>()); return res; }
			Map<String,Object> q = new HashMap<String,Object>(); q.put("compCd", session.getAttribute("s_comp_cd")); q.put("quoteSeq", Long.valueOf(quoteSeq));
			res.put("data", svc.selectQuoteDtl(q));
			return res;
		}
		/* 견적서 작성·출력 (2026-09-17 「여기에서 견적서 작성 및 출력 가능하게」) — 작성 화면 mangr/quoteEdit.jsp (새로/수정), 인쇄 mangr/quotePrint.jsp
		   저장은 quoteSave.do 그대로(파일 없이) — 같은 문서번호는 대체되므로 「수정」도 같은 길이다. */
		@RequestMapping(value="/mangr/quoteEdit.do")
		public String quoteEdit(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/quoteEdit";
		}
		/* 원가·마진 계산 (2026-09-17 — 표본 오택현.xls 「견적서를 내기 위한 원가계산」) — 화면뿐, DB 표 없음. 센터 비율은 compSetPatch key=cost */
		@RequestMapping(value="/mangr/costCalc.do")
		public String costCalc(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/costCalc";
		}
		@RequestMapping(value="/mangr/quoteMst.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteMst(@RequestParam("quoteSeq") long quoteSeq, HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) return res;
			Map<String,Object> q = new HashMap<String,Object>(); q.put("compCd", session.getAttribute("s_comp_cd")); q.put("quoteSeq", Long.valueOf(quoteSeq));
			res.put("mst", svc.selectQuoteMst(q)); res.put("lines", svc.selectQuoteDtl(q));
			return res;
		}
		/* 쌓인 담당자·수신 이름 (2026-09-17) — 작성 화면의 목록(datalist). {mgr:[…], recv:[…]} 최근 차례 */
		@RequestMapping(value="/mangr/quoteNames.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteNames(HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			List<String> mgr = new java.util.ArrayList<String>(), recv = new java.util.ArrayList<String>();
			if (session.getAttribute("s_comp_cd") != null) {
				Map<String,Object> q = new HashMap<String,Object>(); q.put("compCd", session.getAttribute("s_comp_cd"));
				for (Map<String,Object> r : svc.selectQuoteNames(q)) { if ("mgr".equals(poStr(r.get("kind")))) mgr.add(poStr(r.get("nm"))); else recv.add(poStr(r.get("nm"))); }
			}
			res.put("mgr", mgr); res.put("recv", recv);
			return res;
		}
		/* 문서번호 → 지금 활성 번호 (2026-09-17 「저장 후 출력 시 오류」) — 저장 직후 화면이 응답 번호 대신 이것으로 확정한다(대체 저장 뒤 옛 번호로 인쇄하던 것) */
		@RequestMapping(value="/mangr/quoteByDoc.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteByDoc(@RequestParam("docNo") String docNo, HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>(); res.put("quoteSeq", 0);
			if (session.getAttribute("s_comp_cd") == null || docNo == null || docNo.trim().isEmpty()) return res;
			Map<String,Object> k = new HashMap<String,Object>(); k.put("compCd", session.getAttribute("s_comp_cd")); k.put("docNo", docNo.trim());
			Map<String,Object> ex = svc.selectQuoteByDoc(k);
			if (ex != null) { res.put("quoteSeq", ex.get("quoteSeq")); res.put("docNo", ex.get("docNo")); }
			return res;
		}
		@RequestMapping(value="/mangr/quoteNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteNextNo(@RequestParam(value="quoteDt", required=false) String quoteDt, HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("docNo", ""); return res; }
			res.put("docNo", svc.nextQuoteNo(String.valueOf(session.getAttribute("s_comp_cd")), quoteDt));
			return res;
		}
		@RequestMapping(value="/mangr/quotePrint.do")
		public String quotePrint(@RequestParam("quoteSeq") long quoteSeq, Model model, HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			Map<String,Object> q = new HashMap<String,Object>(); q.put("compCd", session.getAttribute("s_comp_cd")); q.put("quoteSeq", Long.valueOf(quoteSeq));
			Map<String,Object> mst = svc.selectQuoteMst(q);
			model.addAttribute("mst", mst);
			if (mst != null) {
				model.addAttribute("items", svc.selectQuoteDtl(q));
				Map<String,Object> c = new HashMap<String,Object>(); c.put("compCd", session.getAttribute("s_comp_cd"));
				Map<String,Object> comp = svc.selectCompInfo(c); if (comp == null) comp = new HashMap<String,Object>();
				poFillDefault(comp, "compNm", "company.name"); poFillDefault(comp, "busiNum", "company.busi.num"); poFillDefault(comp, "compCeo", "company.ceo");
				poFillDefault(comp, "compAddr", "company.addr"); poFillDefault(comp, "compTel", "company.tel"); poFillDefault(comp, "compType", "company.type");
				poFillDefault(comp, "compFax", "company.fax");
				model.addAttribute("comp", comp);
			}
			return ".raw/main/mangr/quotePrint";
		}
		/* 견적서 엑셀 (2026-09-17 「엑셀로 출력은 양식 그대로」) — 우리 양식 파일(quote_tpl1/2.xls)에 값만 채워 내려준다. 파일 이름 = 문서번호.xls */
		@RequestMapping(value="/mangr/quoteExcel.do")
		public void quoteExcel(@RequestParam("quoteSeq") long quoteSeq, HttpSession session, javax.servlet.http.HttpServletResponse response) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) { response.sendError(401); return; }
			Map<String,Object> q = new HashMap<String,Object>(); q.put("compCd", session.getAttribute("s_comp_cd")); q.put("quoteSeq", Long.valueOf(quoteSeq));
			Map<String,Object> mst = svc.selectQuoteMst(q);
			if (mst == null) { response.sendError(404); return; }
			byte[] b = svc.buildQuoteXls(mst, svc.selectQuoteDtl(q));
			String nm = poStr(mst.get("docNo")); if (nm.isEmpty()) nm = "견적서"; nm += ".xls";
			String enc = java.net.URLEncoder.encode(nm, "UTF-8").replace("+", "%20");
			response.setContentType("application/vnd.ms-excel");
			response.setHeader("Content-Disposition", "attachment; filename=\"" + enc + "\"; filename*=UTF-8''" + enc);
			response.setContentLength(b.length);
			response.getOutputStream().write(b); response.getOutputStream().flush();
		}
		/* 견적서별 비교분석 (2026-09-17) — {seqs:[…]} 최대 30건. 고른 견적서들의 품목 줄 전부를 주고 화면이 품명 × 견적서 행렬로 짠다 */
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/mangr/quoteCompare.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> quoteCompare(@RequestBody Map<String,Object> p, HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("data", new java.util.ArrayList<Object>()); return res; }
			List<Long> seqs = new java.util.ArrayList<Long>();
			Object raw = p.get("seqs");
			if (raw instanceof List) for (Object o : (List<Object>) raw) { long v = Math.round(poNum(o)); if (v > 0 && seqs.size() < 30) seqs.add(Long.valueOf(v)); }
			if (seqs.isEmpty()) { res.put("data", new java.util.ArrayList<Object>()); return res; }
			Map<String,Object> q = new HashMap<String,Object>(); q.put("compCd", session.getAttribute("s_comp_cd")); q.put("seqs", seqs);
			res.put("data", svc.selectQuoteCompare(q));
			return res;
		}
		/* 원본 내려받기 — base64 를 풀어 그대로 준다. 파일 이름은 올린 이름(없으면 문서번호.xls) */
		@RequestMapping(value="/mangr/quoteFile.do")
		public void quoteFile(@RequestParam("quoteSeq") long quoteSeq, HttpSession session, javax.servlet.http.HttpServletResponse response) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) { response.sendError(401); return; }
			Map<String,Object> q = new HashMap<String,Object>(); q.put("compCd", session.getAttribute("s_comp_cd")); q.put("quoteSeq", Long.valueOf(quoteSeq));
			Map<String,Object> f = svc.selectQuoteFile(q);
			if (f == null || f.get("fileB64") == null) { response.sendError(404); return; }
			byte[] b = Base64.getDecoder().decode(String.valueOf(f.get("fileB64")));
			String nm = poStr(f.get("fileNm")); if (nm.isEmpty()) nm = poStr(f.get("docNo")) + ".xls";
			String enc = java.net.URLEncoder.encode(nm, "UTF-8").replace("+", "%20");
			response.setContentType(nm.toLowerCase().endsWith(".xlsx") ? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" : "application/vnd.ms-excel");
			response.setHeader("Content-Disposition", "attachment; filename=\"" + enc + "\"; filename*=UTF-8''" + enc);
			response.setContentLength(b.length);
			response.getOutputStream().write(b); response.getOutputStream().flush();
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/mangr/quoteDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> quoteDelete(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				List<Object> seqs = (List<Object>) p.get("seqs"); int n = 0;
				if (seqs != null) for (Object o : seqs) {
					Map<String,Object> q = new HashMap<String,Object>();
					q.put("compCd", session.getAttribute("s_comp_cd")); q.put("quoteSeq", Long.valueOf(Math.round(poNum(o))));
					q.put("regUser", session.getAttribute("s_user_id")); q.put("regIp", request.getRemoteAddr());
					n += svc.deleteQuote(q);
				}
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" quoteDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= DC 발주 등록 (2026-09-17) =================
		   삼성웰스토리 SRM 「발주현황조회」에서 상품종류 DC 인 발주 — 발주현황표(통합가마감/라벨발행)에는 안 실린다.
		   그래서 정산서가 올 때까지 재고가 안 빠지고, 출고내역 대사에서는 「정산서만」으로 떴다.
		   · 원본 두 가지 : 입고예약서(PDF, 입고예약서번호·업체출고일·발주번호·납품장소) / 발주서(엑셀 ZMMA_XI_13_PO_QUERY, 발주일자·납기일자, 발주번호 없음)
		   · 저장 = TBL_SHIPOUT_MST, PROD_KIND='DC'. 출고장은 납품장소 이름으로(없으면 평택 E500 — 사용자 확정 2026-09-17)
		   · 납기현황관리(대시보드·납기세부·이력)에서만 빠지고 재고 원장·정산서 교체·월별 출고현황·마감·출고내역 대사에는 들어간다
		   · 멀티파트 설정이 없어 파일은 base64 JSON 으로 받는다. 해석은 서버(POI · itext)가 하고 화면은 미리보기 후 저장한다 */
		@RequestMapping(value="/shipout/dcPo.do")
		public String dcPo(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/dcPo";
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/shipout/dcPoParse.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> dcPoParse(@RequestBody Map<String,Object> p, HttpSession session) {
			Map<String,Object> res = new HashMap<String,Object>();
			java.util.List<Map<String,Object>> rows = new java.util.ArrayList<Map<String,Object>>();
			java.util.List<String> errs = new java.util.ArrayList<String>();
			if (session.getAttribute("s_comp_cd") == null) { errs.add("로그인이 필요합니다."); res.put("rows", rows); res.put("errors", errs); return res; }
			java.util.List<Map<String,Object>> files = (java.util.List<Map<String,Object>>) p.get("files");
			if (files != null) for (Map<String,Object> fl : files) {
				String nm = poStr(fl.get("name"));
				try {
					String b64 = poStr(fl.get("b64")); int cm = b64.indexOf(','); if (b64.startsWith("data:") && cm > 0) b64 = b64.substring(cm + 1);
					byte[] b = Base64.getDecoder().decode(b64);
					if (b.length > 15 * 1024 * 1024) { errs.add(nm + " : 15MB 가 넘습니다."); continue; }
					java.util.List<Map<String,Object>> got = (b.length > 4 && b[0] == '%' && b[1] == 'P' && b[2] == 'D' && b[3] == 'F')
					        ? dcParsePdf(b, nm) : dcParseXlsx(b, nm);
					if (got.isEmpty()) errs.add(nm + " : 품목 줄을 찾지 못했습니다(입고예약서 PDF 또는 발주서 엑셀인지 확인).");
					rows.addAll(got);
				} catch (Exception e) {
					log.error(" dcPoParse " + nm + " : " + e.getMessage());
					errs.add(nm + " : 읽지 못했습니다 — " + e.getClass().getSimpleName() + (e.getMessage() == null ? "" : " " + e.getMessage()));
				}
			}
			res.put("rows", rows); res.put("errors", errs);
			return res;
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/shipout/dcPoSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> dcPoSave(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String compCd = String.valueOf(session.getAttribute("s_comp_cd"));
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				java.util.List<Map<String,Object>> in = (java.util.List<Map<String,Object>>) p.get("rows");
				java.util.List<egovframework.konet.user.model.ShipoutDTO> rows = new java.util.ArrayList<egovframework.konet.user.model.ShipoutDTO>();
				java.util.LinkedHashSet<String> dates = new java.util.LinkedHashSet<String>();
				if (in != null) for (Map<String,Object> m : in) {
					String dlv = poStr(m.get("dlvDt")).replace("-", "").replace("/", "");
					String cd = poStr(m.get("itemCd"));
					long q = Math.round(poNum(m.get("qty")));
					if (!dlv.matches("\\d{8}") || cd.isEmpty() || q == 0) continue;
					String dcCd = poStr(m.get("dcCd")).toUpperCase(); if (dcCd.isEmpty()) dcCd = "E500";
					egovframework.konet.user.model.ShipoutDTO d = new egovframework.konet.user.model.ShipoutDTO();
					d.setDlvDt(dlv);
					String sh = poStr(m.get("shpoutDt")).replace("-", "").replace("/", ""); d.setShpoutDt(sh.matches("\\d{8}") ? sh : dlv);
					d.setDcCd(dcCd); d.setDcNm(dcNmOf(dcCd, poStr(m.get("place"))));
					d.setItemCd(cd); d.setItemNm(poStr(m.get("itemNm")));
					d.setUnit(poStr(m.get("unit"))); d.setCurQty((int) q); d.setLabelQty((int) q);
					d.setOrdNo(poStr(m.get("ordNo")));
					d.setZone("DC"); d.setDlvGb("DC"); d.setBizNm("DC 입고(" + d.getDcNm() + ")");
					String rsv = poStr(m.get("rsvNo")), ordDt = poStr(m.get("ordDt"));
					String rmk = (rsv.isEmpty() ? "" : "입고예약서 " + rsv) + (ordDt.isEmpty() ? "" : (rsv.isEmpty() ? "" : " · ") + "발주일 " + ordDt);
					if (!poStr(m.get("price")).isEmpty()) rmk += (rmk.isEmpty() ? "" : " · ") + "단가 " + poStr(m.get("price"));
					d.setRemark(rmk.length() > 190 ? rmk.substring(0, 190) : rmk);
					String src = poStr(m.get("fileNm")); d.setSrcFile(src.length() > 190 ? src.substring(0, 190) : src);
					rows.add(d); dates.add(dlv);
				}
				if (rows.isEmpty()) return ResponseEntity.status(400).body("저장할 줄이 없습니다(납기일자·품목코드·수량을 확인하세요).");
				int n = svc.saveDcPo(rows, u, ip, compCd);
				String warn = dcResync(dates, u, ip);
				return ResponseEntity.ok(n + (warn == null ? "" : "|STOCKFAIL:" + warn));
			} catch (Exception e) { log.error(" dcPoSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/shipout/dcPoList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> dcPoList(@RequestParam(value="dlvDtFrom", required=false) String fr, @RequestParam(value="dlvDtTo", required=false) String to,
		                                   HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("data", new java.util.ArrayList<Object>()); return res; }
			Map<String,Object> q = new HashMap<String,Object>();
			q.put("compCd", session.getAttribute("s_comp_cd")); q.put("dlvDtFrom", fr); q.put("dlvDtTo", to);
			res.put("data", svc.selectDcPoList(q));
			return res;
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/shipout/dcPoDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> dcPoDelete(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				java.util.List<Map<String,Object>> keys = (java.util.List<Map<String,Object>>) p.get("keys");
				int n = svc.deleteDcPo(keys, u, request.getRemoteAddr(), String.valueOf(session.getAttribute("s_comp_cd")));
				java.util.LinkedHashSet<String> dates = new java.util.LinkedHashSet<String>();
				if (keys != null) for (Map<String,Object> k : keys) { String d = poStr(k.get("dlvDt")).replace("-", ""); if (d.matches("\\d{8}")) dates.add(d); }
				String warn = dcResync(dates, u, request.getRemoteAddr());
				return ResponseEntity.ok(n + (warn == null ? "" : "|STOCKFAIL:" + warn));
			} catch (Exception e) { log.error(" dcPoDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/* 재고 원장 재동기화 — 발주현황표 저장과 같은 길(납기일자별 syncShipoutLedgerDate → 전체 현재고). 실패는 조용히 넘기지 않고 사유를 돌려준다 */
		private String dcResync(java.util.Set<String> dates, String u, String ip) {
			try {
				for (String d : dates) svc.syncShipoutLedgerDate(d, u, ip);
				if (!dates.isEmpty()) svc.recalcStockMstAll(u, ip);
				return null;
			} catch (Exception se) {
				log.error(" DC 발주 재고연동 WARN : " + se.getMessage());
				return (se.getMessage() == null || se.getMessage().trim().isEmpty()) ? se.getClass().getSimpleName() : se.getMessage().trim();
			}
		}
		/* 납품장소·코드 → 출고장 코드. 매퍼 dcKeyOf 와 같은 지역명 규칙. 못 찾으면 평택(E500) */
		private static String dcCdOf(String place) {
			String s = place == null ? "" : place;
			if (s.contains("용인")) return "E100"; if (s.contains("왜관")) return "E200"; if (s.contains("김해")) return "E300";
			if (s.contains("광주")) return "E400"; if (s.contains("평택")) return "E500"; if (s.contains("제주")) return "E600";
			if (s.contains("오산")) return "E700";
			return "E500";
		}
		private static String dcNmOf(String dcCd, String place) {
			String[][] t = { {"E100","용인"},{"E200","왜관"},{"E300","김해"},{"E400","광주"},{"E500","평택"},{"E600","제주"},{"E700","오산"} };
			for (String[] r : t) if (r[0].equals(dcCd)) return r[1] + "물류센터";
			return place == null || place.isEmpty() ? "평택물류센터" : place;
		}
		private static String dcDt8(String s) {
			String d = s == null ? "" : s.replaceAll("[^0-9]", "");
			return d.length() >= 8 ? d.substring(0, 8) : "";
		}
		private static double dcNum(String s) {
			try { String t = (s == null ? "" : s).replace(",", "").trim(); return t.isEmpty() ? 0 : Double.parseDouble(t); } catch (Exception e) { return 0; }
		}
		private static Map<String,Object> dcRow(String src, String fileNm) {
			Map<String,Object> m = new java.util.LinkedHashMap<String,Object>();
			m.put("src", src); m.put("fileNm", fileNm);
			return m;
		}

		/* 발주서 엑셀(ZMMA_XI_13_PO_QUERY) — 칸 번호는 머리글(품목코드·품명 줄 / 규격·단위 줄)로 찾는다. 품목은 두 줄이 한 벌.
		   윗줄 = No·품목코드·품명·금액·납기일자·납품장소 / 아랫줄 = 규격·단위·수량·단가·부가세·적요. 발주일자·납기일자(머리)는 위쪽 표에서.
		   한 시트에 발주서가 여러 장 이어 붙어 있어도 머리글을 다시 만나면 칸을 새로 잡는다. */
		private static java.util.List<Map<String,Object>> dcParseXlsx(byte[] b, String fileNm) throws Exception {
			java.util.List<Map<String,Object>> out = new java.util.ArrayList<Map<String,Object>>();
			org.apache.poi.ss.usermodel.Workbook wb = org.apache.poi.ss.usermodel.WorkbookFactory.create(new java.io.ByteArrayInputStream(b));
			try {
				org.apache.poi.ss.usermodel.DataFormatter df = new org.apache.poi.ss.usermodel.DataFormatter();
				for (int si = 0; si < wb.getNumberOfSheets(); si++) {
					org.apache.poi.ss.usermodel.Sheet sh = wb.getSheetAt(si);
					String ordDt = "", headDlv = "";
					int cCode = -1, cName = -1, cAmt = -1, cDlv = -1, cPlace = -1, cSpec = -1, cUnit = -1, cQty = -1, cPrice = -1, cRmk = -1;
					for (int r = 0; r <= sh.getLastRowNum(); r++) {
						org.apache.poi.ss.usermodel.Row row = sh.getRow(r); if (row == null) continue;
						java.util.TreeMap<Integer,String> cells = new java.util.TreeMap<Integer,String>();
						for (int c = 0; c < row.getLastCellNum(); c++) {
							org.apache.poi.ss.usermodel.Cell cl = row.getCell(c); if (cl == null) continue;
							String v = df.formatCellValue(cl).trim(); if (!v.isEmpty()) cells.put(c, v);
						}
						if (cells.isEmpty()) continue;
						if (cells.containsValue("품목코드") && cells.containsValue("품명")) {
							for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
								String v = e.getValue().replace(" ", "");
								if ("품목코드".equals(v)) cCode = e.getKey(); else if ("품명".equals(v)) cName = e.getKey();
								else if ("금액".equals(v)) cAmt = e.getKey(); else if ("납기일자".equals(v)) cDlv = e.getKey();
								else if ("납품장소".equals(v)) cPlace = e.getKey();
							}
							org.apache.poi.ss.usermodel.Row nx = sh.getRow(r + 1);
							if (nx != null) for (int c = 0; c < nx.getLastCellNum(); c++) {
								org.apache.poi.ss.usermodel.Cell cl = nx.getCell(c); if (cl == null) continue;
								String v = df.formatCellValue(cl).trim().replace(" ", "");
								if ("규격".equals(v)) cSpec = c; else if ("단위".equals(v)) cUnit = c; else if ("수량".equals(v)) cQty = c;
								else if ("단가".equals(v)) cPrice = c; else if ("적요".equals(v)) cRmk = c;
							}
							r++; continue;
						}
						// 머리 표 : 「발주일자 … 20260629」 「납기일자 … 20260701」 — 이름표 오른쪽 첫 값
						for (java.util.Map.Entry<Integer,String> e : cells.entrySet()) {
							String v = e.getValue().replace(" ", "");
							if ("발주일자".equals(v) || "납기일자".equals(v)) {
								java.util.Map.Entry<Integer,String> nv = cells.higherEntry(e.getKey());
								if (nv != null && dcDt8(nv.getValue()).length() == 8) { if ("발주일자".equals(v)) ordDt = dcDt8(nv.getValue()); else headDlv = dcDt8(nv.getValue()); }
							}
						}
						if (cCode < 0) continue;
						String code = cells.containsKey(cCode) ? cells.get(cCode).replace(" ", "") : "";
						if (!code.matches("\\d{6,14}")) continue;
						org.apache.poi.ss.usermodel.Row lo = sh.getRow(r + 1);
						java.util.function.IntFunction<String> low = (c) -> {
							if (lo == null || c < 0) return "";
							org.apache.poi.ss.usermodel.Cell cl = lo.getCell(c); return cl == null ? "" : df.formatCellValue(cl).trim();
						};
						Map<String,Object> m = dcRow("발주서", fileNm);
						String dlv = cDlv >= 0 && cells.containsKey(cDlv) ? dcDt8(cells.get(cDlv)) : "";
						if (dlv.isEmpty()) dlv = headDlv;
						String place = cPlace >= 0 && cells.containsKey(cPlace) ? cells.get(cPlace) : "";
						m.put("dlvDt", dlv); m.put("shpoutDt", dlv); m.put("ordDt", ordDt); m.put("ordNo", ""); m.put("rsvNo", "");
						m.put("itemCd", code); m.put("itemNm", cName >= 0 && cells.containsKey(cName) ? cells.get(cName) : "");
						m.put("spec", low.apply(cSpec)); m.put("unit", low.apply(cUnit));
						m.put("qty", dcNum(low.apply(cQty))); m.put("price", low.apply(cPrice).replace(",", ""));
						m.put("amt", cAmt >= 0 && cells.containsKey(cAmt) ? dcNum(cells.get(cAmt)) : 0);
						m.put("place", place); m.put("dcCd", dcCdOf(place)); m.put("remark", low.apply(cRmk));
						out.add(m);
						r++;   // 아랫줄은 이미 읽었다
					}
				}
			} finally { wb.close(); }
			return out;
		}

		/* 입고예약서 PDF — 글자를 좌표(x,y)째로 모아 줄(y)로 묶고, 칸은 머리글 글자 위치로 가른다(텍스트 추출 순서는 칸이 섞여 못 쓴다).
		   윗줄 = 품목번호·품명·금액·납품장소·발주번호 / 아랫줄 = 규격·단위·판매가·수량·단가·청구자(납품장소 (FD)). 쪽마다 머리(입고예약서번호·업체출고일)가 따로 있다. */
		private static final class DcCh { final float x, xe, y; final String t; DcCh(float x, float xe, float y, String t) { this.x = x; this.xe = xe; this.y = y; this.t = t; } }
		private static final class DcTok { float x; StringBuilder t = new StringBuilder(); }
		private static java.util.List<DcTok> dcTokens(java.util.List<DcCh> line) {
			java.util.List<DcCh> l = new java.util.ArrayList<DcCh>(line);
			java.util.Collections.sort(l, (a, c) -> Float.compare(a.x, c.x));
			java.util.List<DcTok> out = new java.util.ArrayList<DcTok>(); DcTok cur = null; float pe = -999;
			for (DcCh ch : l) {
				if (ch.t.trim().isEmpty()) { pe = -999; cur = null; continue; }
				if (cur == null || ch.x - pe > 3.5f) { cur = new DcTok(); cur.x = ch.x; out.add(cur); }
				cur.t.append(ch.t); pe = ch.xe;
			}
			return out;
		}
		private static java.util.List<Map<String,Object>> dcParsePdf(byte[] b, String fileNm) throws Exception {
			java.util.List<Map<String,Object>> out = new java.util.ArrayList<Map<String,Object>>();
			com.itextpdf.text.pdf.PdfReader rd = new com.itextpdf.text.pdf.PdfReader(b);
			try {
				com.itextpdf.text.pdf.parser.PdfReaderContentParser pr = new com.itextpdf.text.pdf.parser.PdfReaderContentParser(rd);
				for (int pg = 1; pg <= rd.getNumberOfPages(); pg++) {
					final java.util.List<DcCh> chars = new java.util.ArrayList<DcCh>();
					pr.processContent(pg, new com.itextpdf.text.pdf.parser.RenderListener() {
						public void beginTextBlock() {}
						public void endTextBlock() {}
						public void renderImage(com.itextpdf.text.pdf.parser.ImageRenderInfo ri) {}
						public void renderText(com.itextpdf.text.pdf.parser.TextRenderInfo ri) {
							for (com.itextpdf.text.pdf.parser.TextRenderInfo c : ri.getCharacterRenderInfos()) {
								com.itextpdf.text.pdf.parser.LineSegment bl = c.getBaseline();
								chars.add(new DcCh(bl.getStartPoint().get(0), bl.getEndPoint().get(0), bl.getStartPoint().get(1), c.getText()));
							}
						}
					});
					// 줄로 묶기 (위에서 아래로, y 차이 2.5 이내 = 같은 줄)
					java.util.Collections.sort(chars, (a, c) -> Float.compare(c.y, a.y));
					java.util.List<java.util.List<DcCh>> lines = new java.util.ArrayList<java.util.List<DcCh>>();
					java.util.List<Float> ys = new java.util.ArrayList<Float>();
					for (DcCh ch : chars) {
						if (lines.isEmpty() || Math.abs(ys.get(ys.size() - 1) - ch.y) > 2.5f) { lines.add(new java.util.ArrayList<DcCh>()); ys.add(ch.y); }
						lines.get(lines.size() - 1).add(ch);
					}
					java.util.List<java.util.List<DcTok>> toks = new java.util.ArrayList<java.util.List<DcTok>>();
					StringBuilder all = new StringBuilder();
					for (java.util.List<DcCh> l : lines) { java.util.List<DcTok> t = dcTokens(l); toks.add(t); for (DcTok k : t) all.append(k.t).append(' '); all.append('\n'); }
					String txt = all.toString();
					java.util.regex.Matcher mm;
					String rsvNo = (mm = java.util.regex.Pattern.compile("입고예약서번호\\s*(\\d{6,14})").matcher(txt)).find() ? mm.group(1) : "";
					String outDt = (mm = java.util.regex.Pattern.compile("업체출고일\\s*(\\d{4}[/.-]\\d{2}[/.-]\\d{2})").matcher(txt)).find() ? dcDt8(mm.group(1)) : "";
					String genDt = (mm = java.util.regex.Pattern.compile("생성일\\s*(\\d{4}[/.-]\\d{2}[/.-]\\d{2})").matcher(txt)).find() ? dcDt8(mm.group(1)) : "";
					// 칸 경계 — 머리글 글자 위치. 못 찾으면 표본(2026-08-03 호호솥밥) 값
					float xAmt = 412, xPlace = 468, xOrd = 531, xUnit = 258, xSale = 286, xQty = 325, xPrice = 363;
					for (java.util.List<DcTok> t : toks) for (DcTok k : t) {
						String v = k.t.toString();
						if ("금액".equals(v)) xAmt = k.x; else if ("납품장소".equals(v)) xPlace = k.x; else if ("발주번호".equals(v)) xOrd = k.x;
						else if ("단위".equals(v)) xUnit = k.x; else if ("판매가".equals(v)) xSale = k.x; else if ("수량".equals(v)) xQty = k.x;
						else if ("단가".equals(v)) xPrice = k.x;
					}
					for (int li = 0; li < toks.size(); li++) {
						java.util.List<DcTok> t = toks.get(li);
						if (t.isEmpty()) continue;
						DcTok first = null; for (DcTok k : t) { if (k.x < xUnit - 60) { first = k; break; } }
						if (first == null || !first.t.toString().matches("\\d{8,14}") || first.x < 40) continue;   // x<40 = No 칸
						String code = first.t.toString(), amt = "", ordNo = ""; StringBuilder name = new StringBuilder(), place = new StringBuilder();
						for (DcTok k : t) {
							if (k == first) continue;
							String v = k.t.toString();
							if (k.x >= xOrd - 12) { if (v.matches("\\d{6,14}")) ordNo = v; }
							else if (k.x >= xPlace - 20) place.append(place.length() > 0 ? " " : "").append(v);
							else if (k.x >= xAmt - 30 && v.matches("[\\d,.-]+")) amt = v;
							else name.append(name.length() > 0 ? " " : "").append(v);
						}
						// 아랫줄 : 22pt 안에서 수량 칸에 숫자가 있는 첫 줄
						String spec = "", unit = "", qty = "", price = "", place2 = "";
						for (int lj = li + 1; lj < toks.size() && ys.get(li) - ys.get(lj) <= 24f; lj++) {
							String q0 = "";
							for (DcTok k : toks.get(lj)) if (k.x >= xQty - 6 && k.x < xPrice - 4 && k.t.toString().matches("[\\d,.]+")) q0 = k.t.toString();
							if (q0.isEmpty()) continue;
							StringBuilder sp = new StringBuilder();
							for (DcTok k : toks.get(lj)) {
								String v = k.t.toString();
								if (k.x >= xPlace - 20) place2 = v;
								else if (k.x >= xPrice - 4) price = v;
								else if (k.x >= xQty - 6) qty = v;
								else if (k.x >= xSale - 4) { /* 판매가 — 비어 있다 */ }
								else if (k.x >= xUnit - 10) unit = v;
								else if (k.x > first.x + 20) sp.append(sp.length() > 0 ? " " : "").append(v);
							}
							spec = sp.toString();
							break;
						}
						Map<String,Object> m = dcRow("입고예약서", fileNm);
						String pl = place.length() > 0 ? place.toString() : place2;
						m.put("dlvDt", outDt); m.put("shpoutDt", outDt); m.put("ordDt", genDt); m.put("ordNo", ordNo); m.put("rsvNo", rsvNo);
						m.put("itemCd", code); m.put("itemNm", name.toString()); m.put("spec", spec); m.put("unit", unit);
						m.put("qty", dcNum(qty)); m.put("price", price.replace(",", "")); m.put("amt", dcNum(amt));
						m.put("place", pl); m.put("dcCd", dcCdOf(pl)); m.put("remark", "");
						out.add(m);
					}
				}
			} finally { rd.close(); }
			return out;
		}

		/* 출고현황표 화면 — 선택한 납기일자(단일)의 활성배치 조회 (JSON: {data:[...]}) */
		@RequestMapping(value="/shipout/selectShipoutMst.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutMst(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto,
		                                            HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutMst(dto));
			return response;
		}

		/* 마감 집계 — 출고(SHPOUT_DT 마감월) × 단가이력/마스터 → 품목·사업장·매입처별 매출/매입/마진 (마감관리 3화면 공용) */
		@RequestMapping(value="/shipout/selectClosing.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosing(@ModelAttribute("DTO") egovframework.konet.user.model.ClosingDTO dto,
		                                         HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosing(dto));
			return response;
		}

		/* 출고미상 — 정산서에는 있는데 출고 자료에 짝이 없는 행. 마감에서 빠지는 금액이라 화면에 경고로 띄운다 */
		@RequestMapping(value="/shipout/selectClosingUnmatched.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosingUnmatched(@ModelAttribute("DTO") egovframework.konet.user.model.ClosingDTO dto,
		                                                 HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosingUnmatched(dto));
			return response;
		}

		/* 재고마감 — TBL_STOCK_LEDGER 기준 기초+입고-출고±조정=기말 + 이동평균 재고금액 */
		@RequestMapping(value="/shipout/selectStockClosing.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectStockClosing(@ModelAttribute("DTO") egovframework.konet.user.model.StockClosingDTO dto,
		                                             HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectStockClosing(dto));
			return response;
		}

		/* 입고(매입)마감 — TBL_STOCK_LEDGER 당월 입고(IO_GB='I') 품목별 집계 */
		@RequestMapping(value="/shipout/selectInboundClosing.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectInboundClosing(@ModelAttribute("DTO") egovframework.konet.user.model.StockClosingDTO dto,
		                                              HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectInboundClosing(dto));
			return response;
		}

		/* 월별 마감 이력 목록 */
		@RequestMapping(value="/shipout/selectClosingList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosingList(@ModelAttribute("DTO") egovframework.konet.user.model.ClosingMstDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosingMstList(dto));
			return response;
		}

		/* 마감 확정 상태 조회 */
		@RequestMapping(value="/shipout/selectClosingStatus.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectClosingStatus(@ModelAttribute("DTO") egovframework.konet.user.model.ClosingMstDTO dto,
		                                              HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectClosingMst(dto));
			return response;
		}
		/* 마감 확정 — 3종 집계 저장 + 재고 스냅샷 + 잠금 */
		@RequestMapping(value="/shipout/confirmClosing.do", method = RequestMethod.POST)
		public ResponseEntity<String> confirmClosing(@RequestBody egovframework.konet.user.model.ClosingMstDTO dto,
		                                             HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getYm()==null || dto.getYm().trim().isEmpty()) return ResponseEntity.status(400).body("마감월 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.confirmClosing(dto)));
			} catch (Exception e) { log.error(" confirmClosing ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/* 마감 확정 해제 */
		@RequestMapping(value="/shipout/cancelClosing.do", method = RequestMethod.POST)
		public ResponseEntity<String> cancelClosing(@RequestBody egovframework.konet.user.model.ClosingMstDTO dto,
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
		public Map<String,Object> deleteShipoutZone(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto,
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
		public Map<String,Object> selectShipoutPrev(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto,
		                                            HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutPrev(dto));
			return response;
		}

		/* 출고현황표(데시보드2) 품목별 변경 이력 팝업 — 특정 물류센터코드(dcCd)+출고일자(shpoutDt)의 전 배치(활성+이력) 조회.
		   클라이언트가 (사업장+품목) × 배치(UPLOAD_DTTM)로 피벗해 신규/삭제/증감 표시 (JSON: {data:[...]}) */
		@RequestMapping(value="/shipout/selectShipoutHistory.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutHistory(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto,
		                                               HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutHistory(dto));
			return response;
		}

		/* 출고현황표(데시보드2) 메인 그리드 차수별 수량 매트릭스 — 해당 출고일자 전체 출고장의 전 배치(활성+이력) 조회 (JSON: {data:[...]}) */
		@RequestMapping(value="/shipout/selectShipoutHistAll.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutHistAll(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto,
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
		public Map<String,Object> selectSalesChart(@ModelAttribute("DTO") egovframework.konet.user.model.ClosingDTO dto,
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
		public Map<String,Object> selectSalesChartDaily(@ModelAttribute("DTO") egovframework.konet.user.model.ClosingDTO dto,
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
		public Map<String,Object> selectShipoutUploadHist(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto,
		                                                  HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectShipoutUploadHist(dto));
			return response;
		}
		@RequestMapping(value="/shipout/selectShipoutUploadDtl.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectShipoutUploadDtl(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto,
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
		/** 사업장별 «통상 출고장» 이력 (2026-09-16) — 대시보드1 이상 배지. 기간(dlvDtFrom~dlvDtTo)은 화면이 「조회일 앞 90일」로 준다.
		 *  회사코드는 인터셉터가 넣는다. 조회 전용이라 실패해도 화면은 배지만 안 뜬다. */
		@RequestMapping(value="/shipout/bizZoneHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> bizZoneHist(@ModelAttribute("DTO") egovframework.konet.user.model.ShipoutDTO dto) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectBizZoneHist(dto));
			return response;
		}

		/* 업로드 자동등록 — 사업장코드가 없을 때만 신규저장(insert if absent) */
		@RequestMapping(value="/shipout/saveBiziAuto.do", method = RequestMethod.POST)
		public ResponseEntity<String> saveBiziAuto(@RequestBody List<egovframework.konet.user.model.BiziDTO> rows,
		                                           HttpServletRequest request, HttpSession session) {
			try {
				if (rows == null || rows.isEmpty()) return ResponseEntity.ok("0");
				String regUser = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id"))
				               : (session.getAttribute("s_comp_cd") != null ? String.valueOf(session.getAttribute("s_comp_cd")) : "");
				String regIp = request.getRemoteAddr();
				int n = 0;
				for (egovframework.konet.user.model.BiziDTO r : rows) {
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
		public ResponseEntity<String> biziInsert(@RequestBody List<egovframework.konet.user.model.BiziDTO> data,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.konet.user.model.BiziDTO d : data) {
					if (d.getBizCd() == null || d.getBizCd().trim().isEmpty()) continue;
					d.setRegUser(u); d.setRegIp(ip); n += svc.insertBiziIfAbsent(d);
				}
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" biziInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 관리화면 — 사업장명 수정 */
		@RequestMapping(value="/mangr/biziUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> biziUpdate(@RequestBody List<egovframework.konet.user.model.BiziDTO> data,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.konet.user.model.BiziDTO d : data) { d.setUpdUser(u); d.setUpdIp(ip); n += svc.updateBiziMst(d); }
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" biziUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 관리화면 — 삭제(비활성화) */
		@RequestMapping(value="/mangr/biziDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> biziDelete(@RequestBody List<egovframework.konet.user.model.BiziDTO> data,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.konet.user.model.BiziDTO d : data) { d.setUpdUser(u); d.setUpdIp(ip); n += svc.deleteBiziMst(d); }
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" biziDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ===== 택배 정보 저장 (2026-08-06) — 사업장관리·택배출고관리 공용.
		   사업장이 아직 TBL_BIZI_MST 에 없으면(출고자료에만 있는 신규) 먼저 등록하고 택배정보를 채운다. */
		@RequestMapping(value="/mangr/biziParcelUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> biziParcelUpdate(@RequestBody List<egovframework.konet.user.model.BiziDTO> data,
		                                               HttpServletRequest request, HttpSession session) {
			try {
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				String ip = request.getRemoteAddr();
				int n = 0;
				for (egovframework.konet.user.model.BiziDTO d : data) {
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
		/* ── 출고재고현황 (2026-09-03 신설) — 재고 관리 > 재고현황 아래 메뉴.
		     행=년월(최근월부터) · 열=품목 · 값=월 출고량, 맨 위 줄=현재고. 화면: stockOutMonth.jsp
		     자료는 두 조회를 한 응답에 담는다 — months(년월×품목 출고) + stock(품목별 현재고). */
		@RequestMapping(value="/prod/stockOutMonth.do")
		public String stockOutMonth(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/stockOutMonth";
		}
		@RequestMapping(value="/prod/stockOutMonthList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockOutMonthList(@RequestParam(value="frDt", required=false) String frDt,
		                                            @RequestParam(value="toDt", required=false) String toDt,
		                                            @RequestParam(value="frYm", required=false) String frYm,
		                                            @RequestParam(value="toYm", required=false) String toYm,
		                                            HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>();
			/* 기간은 일자(frDt·toDt, 2026-09-03 「일자까지 보여주는 형식으로」). 옛 호출(frYm·toYm)만 오면 그 달 1일~31일로 편다 */
			String fd = _d8(frDt), td = _d8(toDt);
			if (fd.isEmpty() && frYm != null) fd = _d8(frYm) + "01";
			if (td.isEmpty() && toYm != null) td = _d8(toYm) + "31";
			p.put("frDt", fd); p.put("toDt", td);
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("months", svc.selectStockOutByMonth(p));
			res.put("stock",  svc.selectStockQtyMap(new egovframework.konet.user.model.StockMstDTO()));
			/* ★srcDays(월별 정산서/발주 원천 일수) 호출은 뺐다 (2026-09-03 속도점검) —
			     화면이 년월 칸 표시를 뺀 뒤로 쓰는 데가 없는데 조회마다 실측 120ms 를 썼다.
			     화면의 srcBadge() 함수는 그대로 남아 있으니, 다시 보여 주려면 이 줄만 되살리면 된다.
			     res.put("srcDays", svc.selectStockOutSrcDays(p)); */
			return res;
		}
		private static String _d8(String s) { return (s == null) ? "" : s.trim().replace("-", ""); }   // yyyy-mm-dd → yyyymmdd
		/* 월별 출고현황 하단 — 고른 (년월·사업장·품목)의 출고내역(통합 원천, 납기일자별) + 입고내역(수불원장 I·R·A 행) (2026-09-03) */
		@RequestMapping(value="/prod/stockOutDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockOutDetail(@RequestParam(value="ym",      required=false) String ym,
		                                         @RequestParam(value="frDt",    required=false) String frDt,
		                                         @RequestParam(value="toDt",    required=false) String toDt,
		                                         @RequestParam(value="prodCd",  required=false) String prodCd,
		                                         @RequestParam(value="prodSeq", required=false) Long prodSeq,
		                                         @RequestParam(value="bizKey",  required=false) String bizKey,
		                                         @RequestParam(value="bizNm",   required=false) String bizNm,
		                                         HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>();
			/* 기간은 일자. 년월(ym) 셀을 눌렀으면 그 달 안에서 조회 일자 범위와 겹치는 부분만 */
			String fd = _d8(frDt), td = _d8(toDt);
			if (ym != null && !ym.trim().isEmpty()) {
				String y = _d8(ym), a = y + "01", b = y + "31";
				if (fd.isEmpty() || fd.compareTo(a) < 0) fd = a;
				if (td.isEmpty() || td.compareTo(b) > 0) td = b;
			}
			p.put("frDt", fd); p.put("toDt", td);
			p.put("prodCd", prodCd); p.put("bizKey", bizKey); p.put("bizNm", bizNm);
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("out", svc.selectStockOutDetail(p));
			/* ★입고내역은 selectStockLedgerInList — 출고(O)행을 서버에서 빼고 기간까지 걸러 받는다 (2026-09-03 속도점검).
			     종전 selectStockLedgerList 는 O행마다 사업장·대체출고를 FOR XML 로 만드는데 화면은 그 행을 전부 버렸다
			     (실측 2,599ms → 7ms). ⚠품목별재고현황 ②수불내역은 O행이 필요하므로 그쪽은 종전 구문 그대로다. */
			java.util.List<java.util.Map<String,Object>> led = new java.util.ArrayList<java.util.Map<String,Object>>();
			if (prodSeq != null) {
				Map<String,Object> lp = new HashMap<String,Object>();
				lp.put("prodSeq", prodSeq); lp.put("frDt", fd); lp.put("toDt", td);
				led = svc.selectStockLedgerInList(lp);
			}
			res.put("ledger", led);
			return res;
		}
		/* ================= 발주서 관리 (2026-09-03 신설) — 매입 관리 ▸ 발주서 관리 =================
		   거래처에 보낼 발주서를 등록·인쇄·엑셀·카톡 공유. 매입전표와 별개 표(TBL_PO_MST/DTL).
		   카톡 공유 = 공개 페이지(/pub/po.do?t=토큰)를 카카오 「공유하기」 카드로 보낸다 — 받는 쪽은 로그인 없이 발주서만 본다.
		   설정 = src/main/resources/kakao.properties (kakao.js.key · share.base.url). */
		private static String poProp(String key) {
			try { String v = System.getProperty(key); if (v != null && !v.trim().isEmpty()) return v.trim(); } catch (Exception e) {}
			return poPropOf("kakao", key);
		}
		/** .properties 를 UTF-8 로 읽는다 — ResourceBundle 은 Java 8 에서 ISO-8859-1 로 읽어 한글이 깨졌다(「(주)코네트」→ 「(ì£¼)ì½ë„¤íŠ¸」, 2026-09-03 실제). */
		private static String poPropOf(String bundle, String key) {
			try (java.io.InputStream in = UserController.class.getClassLoader().getResourceAsStream(bundle + ".properties")) {
				if (in == null) return "";
				java.util.Properties p = new java.util.Properties();
				p.load(new java.io.InputStreamReader(in, java.nio.charset.StandardCharsets.UTF_8));
				String v = p.getProperty(key);
				return v == null ? "" : v.trim();
			} catch (Exception e) { return ""; }
		}
		private static String poShareBase(HttpServletRequest request) {
			String b = poProp("share.base.url");
			if (b.length() > 0) return b.replaceAll("/+$", "");
			int port = request.getServerPort();
			boolean std = ("http".equals(request.getScheme()) && port == 80) || ("https".equals(request.getScheme()) && port == 443);
			return request.getScheme() + "://" + request.getServerName() + (std ? "" : ":" + port) + request.getContextPath();
		}
		@RequestMapping(value="/mangr/poReg.do")
		public String poReg(HttpServletRequest request, HttpSession session, Model model) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			model.addAttribute("kakaoJsKey", poProp("kakao.js.key"));
			model.addAttribute("shareBase", poShareBase(request));
			return ".raw/main/mangr/poReg";
		}
		@RequestMapping(value="/mangr/poList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poList(@RequestParam(value="fromDt", required=false) String fromDt,
		                                 @RequestParam(value="toDt", required=false) String toDt,
		                                 @RequestParam(value="vendorCd", required=false) String vendorCd,
		                                 @RequestParam(value="findData", required=false) String findData, HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("fromDt", fromDt); p.put("toDt", toDt); p.put("vendorCd", vendorCd); p.put("findData", findData); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectPoList(p));
			return res;
		}
		/* 품목별 최근 발주 (2026-09-16 「①재고 파악이 안 돼 중복 발주」) — 발주서 화면의 「최근발주」 칸. 로그인 회사 것만.
		   현재고·적정재고는 새 엔드포인트 없이 /prod/stockQtyMap.do 와 상품마스터(safeStock)를 그대로 쓴다. */
		@RequestMapping(value="/mangr/poRecentByProd.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poRecentByProd(HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectPoRecentByProd(p));
			return res;
		}
		@RequestMapping(value="/mangr/poDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poDetail(@RequestParam("poSeq") long poSeq, HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("poSeq", poSeq);
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("mst", svc.selectPoMst(p));
			res.put("items", svc.selectPoDtl(p));
			return res;
		}
		@RequestMapping(value="/mangr/poNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poNextNo(@RequestParam("poDt") String poDt, HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("poDt", poDt); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectPoNextNo(p));
			return res;
		}
		/** 발주서 저장 — 머리 + 품목 줄을 JSON 하나로. 신규/수정 모두. 돌려주는 값 = poSeq */
		@RequestMapping(value="/mangr/poSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> poSave(@RequestBody Map<String,Object> body, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String poDt = String.valueOf(body.get("poDt") == null ? "" : body.get("poDt")).trim();
				String venCd = String.valueOf(body.get("vendorCd") == null ? "" : body.get("vendorCd")).trim();
				Object items = body.get("items");
				if (poDt.isEmpty()) return ResponseEntity.status(400).body("발주일자를 선택하세요.");
				if (venCd.isEmpty()) return ResponseEntity.status(400).body("거래처를 선택하세요.");
				if (!(items instanceof java.util.List) || ((java.util.List<?>) items).isEmpty()) return ResponseEntity.status(400).body("상품을 한 줄 이상 입력하세요.");
				String u = (session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "");
				body.put("compCd", String.valueOf(session.getAttribute("s_comp_cd")));
				long seq = svc.savePo(body, u, request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(seq));
			} catch (Exception e) {
				log.error(" poSave ERROR ! : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}
		@RequestMapping(value="/mangr/poDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> poDelete(@RequestParam("poSeq") long poSeq, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				Map<String,Object> p = new HashMap<String,Object>();
				p.put("poSeq", poSeq); p.put("compCd", session.getAttribute("s_comp_cd"));
				p.put("regUser", session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "");
				p.put("regIp", request.getRemoteAddr());
				svc.deletePo(p);
				return ResponseEntity.ok("1");
			} catch (Exception e) { log.error(" poDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/** 카톡 공유 뒤 화면이 알려 준다 — 공유 횟수·마지막 공유 시각만 남긴다 */
		@RequestMapping(value="/mangr/poShared.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poShared(@RequestParam("poSeq") long poSeq, HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("poSeq", poSeq);
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", session.getAttribute("s_comp_cd") == null ? 0 : svc.updatePoShared(p));
			return res;
		}
		/** 발주서 인쇄(로그인) — 새 창 */
		@RequestMapping(value="/mangr/poPrint.do")
		public String poPrint(@RequestParam("poSeq") long poSeq, HttpSession session, Model model) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			Map<String,Object> p = new HashMap<String,Object>(); p.put("poSeq", poSeq);
			return poFillPrint(p, model, false);
		}
		/** ★공개 발주서 — 카톡 카드가 여는 주소. 로그인 없이 토큰만으로 읽기. 토큰이 틀리면 빈 안내만 보인다 */
		@RequestMapping(value="/pub/po.do")
		public String poPublic(@RequestParam(value="t", required=false) String token,
		                       @RequestParam(value="s", required=false) String trackKey, Model model) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("token", token == null ? "" : token.trim());
			if (token != null && !token.trim().isEmpty()) sendHistView(trackKey, "PO");   /* 읽음·열람 (2026-09-10) */
			return poFillPrint(p, model, true);
		}
		private String poFillPrint(Map<String,Object> p, Model model, boolean pub) throws Exception {
			Map<String,Object> mst = (p.get("token") != null && String.valueOf(p.get("token")).length() > 0)
			        ? svc.selectPoMstByToken(String.valueOf(p.get("token"))) : svc.selectPoMst(p);
			if (mst == null) { model.addAttribute("pub", pub); model.addAttribute("notFound", true); return ".raw/main/mangr/poPrint"; }
			Map<String,Object> q = new HashMap<String,Object>(); q.put("poSeq", mst.get("poSeq"));
			Map<String,Object> c = new HashMap<String,Object>(); c.put("compCd", mst.get("compCd"));
			model.addAttribute("mst", mst);
			model.addAttribute("items", svc.selectPoDtl(q));
			/* company.properties 에 값이 있으면 그것을 쓰고, 없으면 회사 마스터 값 (2026-09-03 「129-86-67271 사업자번호 추가 · (주)코네트」) */
			Map<String,Object> comp = svc.selectCompInfo(c); if (comp == null) comp = new HashMap<String,Object>();
			poFillDefault(comp, "compNm", "company.name"); poFillDefault(comp, "busiNum", "company.busi.num"); poFillDefault(comp, "compCeo", "company.ceo");
			poFillDefault(comp, "compAddr", "company.addr"); poFillDefault(comp, "compTel", "company.tel");
			model.addAttribute("comp", comp);
			model.addAttribute("pub", pub);
			return ".raw/main/mangr/poPrint";
		}
		/** 발주서 → 매입전표 (2026-09-03 신설 · 2026-09-16 P1-b 「부분 입고」로 개편)
		 *  · 화면(cvGo)이 JSON 으로 보낸다 : { poSeq, purchDt, whNm, payGb, items:[{poDtlSeq, boxQty, eaQty, qty}] }
		 *    items 가 없으면 줄마다 <잔량> 만큼 — 두 번째 전환은 저절로 나머지만 들어간다.
		 *  · 0 인 줄은 전표에서 뺀다. 잔량보다 많이 넣어도 막지 않는다(초과 입고 — 화면이 빨갛게 보여 줄 뿐. 사용자 확정 「강제 아님, 메시지 처리」).
		 *  · 매입 명세마다 PO_SEQ/PO_DTL_SEQ 를 적는다 — 입고·잔량은 이 연결로 센다(저장하지 않는다). 전표 머리에는 대표 발주(PO_SEQ).
		 *  · 저장 경로는 종전과 같은 svc.savePurchase — 재고 입고(원장 I행)·단가 이력이 함께 생긴다. 서브코드·거래중지 관문도 매입 등록과 같다.
		 *  · 종전의 「이미 전환 → 409」는 없앴다 — 잔량이 없고 이번 입고도 없으면 400 으로 알려 줄 뿐이다. */
		@RequestMapping(value="/mangr/poToPurchase.do", method = RequestMethod.POST)
		public ResponseEntity<String> poToPurchase(@RequestBody Map<String,Object> body, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				long poSeq = poLongOf(body.get("poSeq"));
				String purchDt = poStr(body.get("purchDt")).trim();
				String whNm = poStr(body.get("whNm")).trim(), payGb = poStr(body.get("payGb")).trim();
				String whCd = poStr(body.get("whCd")).trim();   // 창고 코드(2026-09-16 P3) — 비면 기본창고
				if (poSeq <= 0) return ResponseEntity.status(400).body("발주서 번호가 없습니다.");
				if (purchDt.isEmpty()) return ResponseEntity.status(400).body("매입일자를 고르세요.");
				Map<String,Object> p = new HashMap<String,Object>(); p.put("poSeq", poSeq); p.put("compCd", session.getAttribute("s_comp_cd"));
				Map<String,Object> mst = svc.selectPoMst(p);
				if (mst == null) return ResponseEntity.status(404).body("발주서를 찾을 수 없습니다.");
				java.util.List<Map<String,Object>> items = svc.selectPoDtl(p);   // inQty·remainQty·closeYn 까지 온다
				if (items == null || items.isEmpty()) return ResponseEntity.status(400).body("발주 품목이 없습니다.");

				// 화면이 보낸 「이번 입고」 — poDtlSeq 로 찾는다. 안 보냈으면 줄마다 잔량
				Map<Long, Map<String,Object>> want = new HashMap<Long, Map<String,Object>>();
				boolean explicit = false;
				Object io = body.get("items");
				if (io instanceof java.util.List) for (Object o : (java.util.List<?>) io) {
					if (!(o instanceof Map)) continue;
					@SuppressWarnings("unchecked") Map<String,Object> w = (Map<String,Object>) o;
					long k = poLongOf(w.get("poDtlSeq")); if (k > 0) { want.put(k, w); explicit = true; }
				}

				egovframework.konet.user.model.PurchaseDTO dto = new egovframework.konet.user.model.PurchaseDTO();
				dto.setCompCd(String.valueOf(session.getAttribute("s_comp_cd")));
				dto.setPurchDt(purchDt);
				dto.setVendorCd(poStr(mst.get("vendorCd"))); dto.setVendorNm(poStr(mst.get("vendorNm")));
				dto.setMgrCd(poStr(mst.get("mgrCd")));       dto.setMgrNm(poStr(mst.get("mgrNm")));
				dto.setWhCd(whCd); dto.setWhNm(whNm.isEmpty() ? "물류창고" : whNm);
				dto.setPayGb(payGb.isEmpty() ? "외상" : payGb); dto.setPayAmt(0d);
				dto.setPoSeq(poSeq);
				java.util.List<egovframework.konet.user.model.PurchaseDtlDTO> dl = new java.util.ArrayList<egovframework.konet.user.model.PurchaseDtlDTO>();
				java.util.List<String> codes = new java.util.ArrayList<String>();
				double tBox = 0, tEa = 0, tQty = 0, tSup = 0, tVat = 0, tTot = 0, tDc = 0;
				boolean partial = false;
				for (Map<String,Object> it : items) {
					long dseq = poLongOf(it.get("poDtlSeq"));
					double pack = poNum(it.get("packQty")); if (pack <= 0) pack = 1;
					double poQty = poNum(it.get("qty"));
					double qty, box, ea;
					if (explicit) {
						Map<String,Object> w = want.get(dseq); if (w == null) continue;
						box = poNum(w.get("boxQty")); ea = poNum(w.get("eaQty")); qty = poNum(w.get("qty"));
						if (qty <= 0 && (box > 0 || ea > 0)) qty = box * pack + ea;
					} else {
						qty = poNum(it.get("remainQty")); if (qty <= 0) continue;
						box = Math.floor(qty / pack); ea = qty - box * pack;
					}
					if (qty <= 0) continue;
					if (qty < poQty) partial = true;
					double unit = poNum(it.get("unitPrice"));
					double amt = Math.round(qty * unit);
					double dc = poQty > 0 ? Math.round(poNum(it.get("dcAmt")) * qty / poQty) : 0;   // 발주 줄 DC 를 수량 비율로
					double supply = amt - dc;
					String tg = poStr(it.get("taxGb")).toUpperCase();
					boolean taxFree = tg.equals("F") || tg.equals("N") || tg.contains("면세") || tg.contains("FREE")
					               || (poNum(it.get("vatAmt")) <= 0 && poNum(it.get("supplyAmt")) > 0);   // 발주 줄에 부가세가 0 이면 면세 품목
					double vat = taxFree ? 0 : Math.round(supply * 0.1);
					double tot = supply + vat;
					egovframework.konet.user.model.PurchaseDtlDTO d = new egovframework.konet.user.model.PurchaseDtlDTO();
					d.setCompCd(dto.getCompCd());
					Object ps = it.get("prodSeq"); d.setProdSeq(ps == null ? null : Long.valueOf(String.valueOf(ps).split("[.]")[0]));
					d.setProdCd(poStr(it.get("prodCd"))); d.setProdNm(poStr(it.get("prodNm"))); d.setSpec(poStr(it.get("spec")));
					d.setPackQty(pack); d.setBoxQty(box); d.setEaQty(ea); d.setQty(qty);
					d.setUnitPrice(unit); d.setAmt(amt); d.setDcAmt(dc); d.setSupplyAmt(supply); d.setVatAmt(vat); d.setTotAmt(tot);
					d.setServiceQty(qty >= poQty ? poNum(it.get("serviceQty")) : 0d);   // 서비스 수량은 전량 입고 때만 따라간다
					d.setRemark(poStr(it.get("remark")));
					d.setTrxGb("매입"); d.setEventYn("N");
					d.setPoSeq(poSeq); d.setPoDtlSeq(dseq > 0 ? dseq : null);
					dl.add(d); codes.add(d.getProdCd());
					tBox += box; tEa += ea; tQty += qty; tSup += supply; tVat += vat; tTot += tot; tDc += dc;
				}
				if (dl.isEmpty()) return ResponseEntity.status(400).body(explicit
					? "이번에 들어온 수량이 없습니다 — 「이번 입고」에 수량을 넣으세요."
					: "잔량이 없습니다 — 이미 전부 입고된 발주서입니다. 추가로 들어온 것이 있으면 「이번 입고」에 수량을 넣으세요.");
				dto.setTotBoxQty(tBox); dto.setTotEaQty(tEa); dto.setTotQty(tQty);
				dto.setSupplyAmt(tSup); dto.setVatAmt(tVat); dto.setTotAmt(tTot); dto.setDcAmt(tDc);
				String poNo = poStr(mst.get("poDt")) + "-" + poStr(mst.get("poNo"));
				String rm = poStr(mst.get("remark"));
				dto.setRemark("발주서 " + poNo + " 전환" + (partial || dl.size() < items.size() ? "(일부)" : "") + (rm.isEmpty() ? "" : " · " + rm));
				dto.setItems(dl);
				String subMsg = subCodeBlockMsg(dto, session);
				if (subMsg != null) return ResponseEntity.status(409).body(subMsg);
				String stopMsg = stopBlockMsg(codes, dto.getPurchDt(), session);
				if (stopMsg != null) return ResponseEntity.status(409).body(stopMsg);
				String u = (session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "");
				dto.setRegUser(u); dto.setUpdUser(u); dto.setRegIp(request.getRemoteAddr()); dto.setUpdIp(request.getRemoteAddr());
				int n = svc.savePurchase(dto);
				Map<String,Object> q = new HashMap<String,Object>();
				q.put("poSeq", poSeq); q.put("purchSeq", dto.getPurchSeq()); q.put("regUser", u);
				svc.updatePoPurchSeq(q);   // 「마지막으로 만든 전표」 — 목록·상태 띠 표시용(입고·잔량은 명세 연결로 센다)
				return ResponseEntity.ok("{\"rows\":" + n + ",\"purchSeq\":" + dto.getPurchSeq() + ",\"purchNo\":\"" + dto.getPurchNo() + "\",\"qty\":" + tQty + "}");
			} catch (Exception e) {
				log.error(" poToPurchase ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}
		private static long poLongOf(Object o) { if (o == null) return 0; try { return Long.parseLong(String.valueOf(o).trim().split("[.]")[0]); } catch (Exception e) { return 0; } }
		/** JSON 문자열 값 이스케이프(따옴표·역슬래시·제어문자) — 응답을 손으로 짤 때 */
		private static String poJs(Object o) {
			String s = o == null ? "" : String.valueOf(o); StringBuilder b = new StringBuilder(s.length() + 8);
			for (int i = 0; i < s.length(); i++) { char c = s.charAt(i);
				if (c == '"' || c == '\\') b.append('\\').append(c);
				else if (c < 0x20) b.append(String.format("\\u%04x", (int) c));
				else b.append(c); }
			return b.toString();
		}
		/** 품목별 미입고(잔량 합 = 입고예정) — 발주서 「미입고」 칸·재고현황 「입고예정」 (2026-09-16 P1-b) */
		@RequestMapping(value="/mangr/poRemainByProd.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poRemainByProd(HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectPoRemainByProd(p));
			return res;
		}
		/** 적정재고 미달 = 추천 발주 (2026-09-16 P1-c 후반, 프로그램 목적 ①의 반대쪽 「떨어졌는데 발주를 안 하는」).
		    마스터 기준이라 원장에 기록이 없는 품목도 나온다. 화면 = 발주서 [⚠ 추천 발주] · 재고현황 요약 줄. */
		@RequestMapping(value="/prod/safeStockShort.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> safeStockShort(HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectSafeStockShort(p));
			return res;
		}
		/** 적정재고 자동 산출 제안 (2026-09-17, 설계 docs/설계_적정재고_자동산출_2026-09-17.md) — 조건이 비면 회사 설정값. 적용은 safeStockBulk(src='A') */
		@RequestMapping(value="/prod/safeStockSuggest.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> safeStockSuggest(@RequestParam(value="window", required=false) Integer window, @RequestParam(value="lead", required=false) Integer lead,
		                                           @RequestParam(value="buf", required=false) Integer buf, @RequestParam(value="minDays", required=false) Integer minDays,
		                                           HttpSession session) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) { Map<String,Object> e = new HashMap<String,Object>(); e.put("data", new java.util.ArrayList<Object>()); e.put("error", "로그인이 필요합니다."); return e; }
			return svc.selectSafeStockSuggest(String.valueOf(session.getAttribute("s_comp_cd")), window, lead, buf, minDays);
		}
		/** 적정재고 일괄 입력 (2026-09-16 결정 ⑥) — 상품코드관리에서 「품목코드 적정재고」 두 열을 붙여넣는다.
		    없는 코드는 세어서 알려 주고 나머지는 그대로 넣는다(막지 않는다). */
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/prod/safeStockBulk.do", method = RequestMethod.POST)
		public ResponseEntity<String> safeStockBulk(@RequestBody Map<String,Object> body, HttpSession session) {
			try {
				if (!adjLoggedIn(session)) return ResponseEntity.status(401).body(ADJ_LOGIN_MSG);
				Object o = body.get("rows");
				if (!(o instanceof java.util.List)) return ResponseEntity.status(400).body("보낼 줄이 없습니다.");
				java.util.List<Map<String,Object>> rows = (java.util.List<Map<String,Object>>) o;
				if (rows.size() > 5000) return ResponseEntity.status(400).body("한 번에 5,000줄까지만 넣을 수 있습니다.");
				Map<String,Object> r = svc.saveSafeStockBulk(rows, String.valueOf(session.getAttribute("s_comp_cd")), String.valueOf(session.getAttribute("s_user_id")));
				return ResponseEntity.ok(new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(r));
			} catch (Exception e) { log.error(" safeStockBulk ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/** 거래처별 매입가 비교 (2026-09-16 P2-a, 프로그램 목적 ③) — 화면 + 자료. months 가 0/없음이면 전체 기간 */
		@RequestMapping(value="/mangr/vendorPriceCmp.do")
		public String vendorPriceCmp(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/vendorPriceCmp";
		}
		@RequestMapping(value="/mangr/vendorPriceCmpList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> vendorPriceCmpList(@RequestParam(value="findData", required=false) String findData,
		                                             @RequestParam(value="months", required=false) Integer months,
		                                             @RequestParam(value="vendorCd", required=false) String vendorCd, HttpSession session) throws Exception {
			String fromDt = "";
			if (months != null && months > 0) {
				java.util.Calendar c = java.util.Calendar.getInstance(); c.add(java.util.Calendar.MONTH, -months);
				fromDt = new java.text.SimpleDateFormat("yyyyMMdd").format(c.getTime());
			}
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("findData", findData); p.put("fromDt", fromDt); p.put("vendorCd", vendorCd); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectVendorPriceCmp(p)); res.put("fromDt", fromDt);
			return res;
		}
		/** 잔량 남은 발주 줄 — 매입등록 [발주분] 팝업 (2026-09-16 P1-b 2단계). vendorCd 가 오면 그 거래처 발주만 */
		@RequestMapping(value="/mangr/poOpenLines.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poOpenLines(@RequestParam(value="vendorCd", required=false) String vendorCd, HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("vendorCd", vendorCd); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectPoOpenLines(p));
			return res;
		}
		/** 이 발주서를 보고 있는 매입전표들 — 삭제 확인창이 보여 준다(막지 않는다) */
		@RequestMapping(value="/mangr/poLinkedPurch.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> poLinkedPurch(@RequestParam("poSeq") long poSeq, HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>(); p.put("poSeq", poSeq); p.put("compCd", session.getAttribute("s_comp_cd"));
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("data", svc.selectPoLinkedPurch(p));
			return res;
		}
		/** 발주 줄 마감(더 안 온다)/해제 — 잔량을 미입고에서 뺀다. 상태 중 사람이 저장하는 유일한 것 */
		@RequestMapping(value="/mangr/poLineClose.do", method = RequestMethod.POST)
		public ResponseEntity<String> poLineClose(@RequestParam("poDtlSeq") long poDtlSeq, @RequestParam("closeYn") String closeYn,
		                                          @RequestParam(value="closeRmk", required=false) String closeRmk, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				Map<String,Object> p = new HashMap<String,Object>();
				p.put("poDtlSeq", poDtlSeq); p.put("closeYn", "Y".equalsIgnoreCase(closeYn) ? "Y" : "N"); p.put("closeRmk", closeRmk); p.put("compCd", session.getAttribute("s_comp_cd"));
				int n = svc.updatePoLineClose(p);
				if (n == 0) return ResponseEntity.status(404).body("발주 줄을 찾을 수 없습니다(다른 회사 것이거나 지워진 줄).");
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" poLineClose ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		private static void poFillDefault(Map<String,Object> m, String key, String prop) {
			String d = poPropOf("company", prop); if (d.length() > 0) m.put(key, d);   // 설정값이 있으면 우선
		}
		private static String poStr(Object o) { return o == null ? "" : String.valueOf(o).trim(); }
		private static Double poNum(Object o) {
			if (o == null) return 0d;
			try { return Double.parseDouble(String.valueOf(o).replace(",", "").trim()); } catch (Exception e) { return 0d; }
		}
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
		public Map<String,Object> clientList(@ModelAttribute("DTO") egovframework.konet.user.model.BiziDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectBiziList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/clientInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> clientInsert(@RequestBody egovframework.konet.user.model.BiziDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("사업장코드 필요");
				if (svc.biziDupChk(dto) > 0) return ResponseEntity.status(409).body("이미 존재하는 사업장코드입니다: "+dto.getBizCd());
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertBizi(dto)));
			} catch (Exception e) { log.error(" clientInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/clientUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> clientUpdate(@RequestBody egovframework.konet.user.model.BiziDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("사업장코드 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateBizi(dto)));
			} catch (Exception e) { log.error(" clientUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/clientDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> clientDelete(@RequestBody egovframework.konet.user.model.BiziDTO dto, HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getBizCd()==null || dto.getBizCd().trim().isEmpty()) return ResponseEntity.status(400).body("사업장코드 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.deleteBizi(dto)));
			} catch (Exception e) { log.error(" clientDelete ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ── 사업장 공통 매칭코드 (2026-08-28) ─────────────────────────────────────
		     선택한 사업장들을 하나의 코드/이름으로 묶는다. 매칭코드를 비워 보내면 <해제>다.
		     ★DDL 먼저 : docs/sql/20260828_bizi_match_cd.sql
		     ★지금은 거래처관리 화면 전용 — 출고현황표 묶음에는 쓰지 않는다. */
		@RequestMapping(value="/mangr/clientMatchNext.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> clientMatchNext(HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			egovframework.konet.user.model.BiziDTO dto = new egovframework.konet.user.model.BiziDTO();
			int no = svc.biziMatchNextNo(dto);
			res.put("matchCd", String.format("M%04d", no));
			return res;
		}
		@RequestMapping(value="/mangr/clientMatchSet.do", method = RequestMethod.POST)
		public ResponseEntity<String> clientMatchSet(@RequestBody egovframework.konet.user.model.BiziDTO dto,
		                                            HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getBizCds()==null || dto.getBizCds().isEmpty()) return ResponseEntity.status(400).body("사업장을 하나 이상 고르세요");
				/* 한 문장에 담을 수 있는 파라미터에 한계가 있어 300개씩 나눠 돌린다 —
				   1,575건 전부를 한 번에 고를 수도 있다. */
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""));
				dto.setUpdIp(request.getRemoteAddr());
				java.util.List<String> all = dto.getBizCds();
				int n = 0;
				final int CHUNK = 300;
				for (int i = 0; i < all.size(); i += CHUNK) {
					dto.setBizCds(all.subList(i, Math.min(i + CHUNK, all.size())));
					n += svc.updateBiziMatch(dto);
				}
				dto.setBizCds(all);
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" clientMatchSet ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 매입등록 (TBL_PURCHASE_MST/DTL) — 2026-07-25 ================= */
		@RequestMapping(value="/mangr/purchaseReg.do")
		public String purchaseReg(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/mangr/purchaseReg";
		}
		@RequestMapping(value="/mangr/purchaseList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseList(@ModelAttribute("DTO") egovframework.konet.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/purchaseDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseDetail(@ModelAttribute("DTO") egovframework.konet.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseOne(dto));
			return response;
		}
		@RequestMapping(value="/mangr/purchaseNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseNextNo(@ModelAttribute("DTO") egovframework.konet.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseNextNo(dto));
			return response;
		}
		/** 전표 저장 — 헤더+명세를 통째로 받는다(JSON). 신규/수정 모두 이 하나로 */
		@RequestMapping(value="/mangr/purchaseSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> purchaseSave(@RequestBody egovframework.konet.user.model.PurchaseDTO dto,
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
				for (egovframework.konet.user.model.PurchaseDtlDTO it : dto.getItems()) pCodes.add(it.getProdCd());
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
			java.util.List<egovframework.konet.user.model.ProdDTO> st = svc.selectStoppedAmong(p);
			if (st == null || st.isEmpty()) return null;
			StringBuilder sb = new StringBuilder("거래중지된 상품코드가 있어 저장할 수 없습니다.\n");
			for (egovframework.konet.user.model.ProdDTO d : st) {
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
		private String subCodeBlockMsg(egovframework.konet.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			java.util.LinkedHashSet<String> codes = new java.util.LinkedHashSet<String>();
			for (egovframework.konet.user.model.PurchaseDtlDTO it : dto.getItems()) {
				if (it.getProdCd() != null && !it.getProdCd().trim().isEmpty()) codes.add(it.getProdCd().trim());
			}
			if (codes.isEmpty()) return null;
			java.util.Map<String,Object> p = new HashMap<String,Object>();
			p.put("codes", new java.util.ArrayList<String>(codes));
			p.put("compCd", session.getAttribute("s_comp_cd"));   // ★Map 이라 인터셉터가 안 넣어 준다 — 직접 넣는다
			java.util.List<egovframework.konet.user.model.ExtItemDTO> subs = svc.selectSubCodesAmong(p);
			if (subs == null || subs.isEmpty()) return null;
			StringBuilder sb = new StringBuilder();
			sb.append("서브코드로는 매입을 잡을 수 없습니다. 마스터코드로 바꿔 주세요.\n");
			for (egovframework.konet.user.model.ExtItemDTO x : subs) {
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
		public ResponseEntity<String> purchaseDelete(@RequestBody egovframework.konet.user.model.PurchaseDTO dto,
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
		public Map<String,Object> purchaseLastPrice(@ModelAttribute("DTO") egovframework.konet.user.model.PurchaseDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			egovframework.konet.user.model.PurchaseDtlDTO last = svc.selectVendorLastPrice(dto);
			response.put("data",   last == null ? null : last.getUnitPrice());   // 종전 그대로 — 화면은 data 를 단가로 읽는다
			response.put("remark", last == null ? null : last.getRemark());      // 이전 비고(2026-09-13) — 비어 있지 않은 마지막 것
			response.put("purchDt", last == null ? null : last.getPurchDt());    // 그 단가를 산 날(2026-09-13) — 이전단가 ▲▼ 알림에 표시
			return response;
		}
		/** 품명 클릭 → 거래처 × 상품 매입단가 이력(최대 3년) */
		@RequestMapping(value="/mangr/purchasePriceHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchasePriceHist(@ModelAttribute("DTO") egovframework.konet.user.model.PurchaseDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchasePriceHist(dto));
			return response;
		}

		/** 거래처 원장(분개장) — 매입등록 화면 우측. 일자별 매입·DC·지급·할인 */
		@RequestMapping(value="/mangr/purchaseLedger.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchaseLedger(@ModelAttribute("DTO") egovframework.konet.user.model.PurchaseDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchaseLedger(dto));
			return response;
		}

		/* ================= 판매등록 (TBL_SALES_TRX_MST/DTL) — 2026-07-25 =================
		   매입등록과 대칭. 정산서(TBL_SALES_MST)와는 별개 표다 — 그쪽은 출고장 엑셀 적재표라
		   재업로드하면 기존 행이 죽으므로 손으로 친 판매를 섞을 수 없다. */
		@RequestMapping(value="/mangr/salesReg.do")
		public String salesReg(HttpServletRequest request, HttpSession session, Model model) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			/* 거래명세서 카톡 공유 — 발주서(poReg)와 같은 설정(kakao.properties) 을 그대로 쓴다 (2026-09-09) */
			model.addAttribute("kakaoJsKey", poProp("kakao.js.key"));
			model.addAttribute("shareBase", poShareBase(request));
			return ".raw/main/mangr/salesReg";
		}
		@RequestMapping(value="/mangr/salesTrxList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxList(@ModelAttribute("DTO") egovframework.konet.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/salesTrxDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxDetail(@ModelAttribute("DTO") egovframework.konet.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxOne(dto));
			return response;
		}
		/* ================= 거래명세서 보내기 (2026-09-09 신설) =================
		   판매등록 ▸ [🖨 거래명세표] ▸ [💬 카톡] / [✉ 이메일] / [🔗 링크].
		   ★발주서(poReg)와 **똑같은 방식**이다 — 카카오는 파일을 못 붙이므로 «로그인 없이 그 전표 하나만 보는
		     공개 주소»(/pub/stmt.do?t=토큰)를 만들어 그 링크를 보낸다. 설정도 발주서와 같은 kakao.properties.
		   ★명세서를 그리는 코드는 화면과 공개 페이지가 **한 파일**을 쓴다(asset/js/stmt-sheet.js) —
		     두 벌로 두면 <보낸 명세서>와 <내가 찍은 명세서>가 조용히 달라진다. */
		@RequestMapping(value="/mangr/salesTrxShare.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxShare(@RequestParam("saleSeq") long saleSeq,
		                                        HttpServletRequest request, HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("error", "로그인이 필요합니다."); return res; }
			egovframework.konet.user.model.SalesTrxDTO dto = new egovframework.konet.user.model.SalesTrxDTO();
			dto.setSaleSeq(saleSeq);
			dto.setUpdUser(session.getAttribute("s_user_id") == null ? "" : String.valueOf(session.getAttribute("s_user_id")));
			dto.setUpdIp(request.getRemoteAddr());
			String token = svc.shareSalesTrx(dto);
			if (token == null || token.isEmpty()) { res.put("error", "전표를 찾을 수 없습니다. 먼저 저장하세요."); return res; }
			res.put("token", token);
			res.put("url", poShareBase(request) + "/pub/stmt.do?t=" + token);
			return res;
		}
		/** ★공개 거래명세서 — 카톡 카드·이메일이 여는 주소. 로그인 없이 <토큰만으로> 그 전표 하나를 읽는다.
		 *  토큰이 없거나 틀리면 빈 안내만 보인다(전표 목록이 새어 나갈 길이 없다 — 서비스가 빈 토큰을 거절한다). */
		@RequestMapping(value="/pub/stmt.do")
		public String stmtPublic(@RequestParam(value="t", required=false) String token,
		                         @RequestParam(value="s", required=false) String trackKey,
		                         @RequestParam(value="o", required=false) String opt,
		                         @RequestParam(value="b", required=false) String bal, Model model) throws Exception {
			egovframework.konet.user.model.SalesTrxDTO mst = svc.selectSalesTrxByToken(token);
			if (mst == null) { model.addAttribute("notFound", true); return ".raw/main/mangr/stmtPrint"; }
			sendHistView(trackKey, "STMT");     /* 읽음·열람 (2026-09-10) — 전표를 찾았을 때만 센다 */
			model.addAttribute("dataJson", stmtJson(mst, opt, bal));
			/* 카톡 카드 미리보기(og:) — 링크만 붙여 넣어도 제목·설명이 보인다. 발주서 공개 페이지와 같은 방식 */
			model.addAttribute("ogTitle", "거래명세서 — " + poStr(mst.getCustNm()) + " (" + poDash(mst.getSaleDt()) + ")");
			model.addAttribute("ogDesc", "합계 " + new java.text.DecimalFormat("#,##0").format(mst.getTotAmt()==null?0d:mst.getTotAmt())
			                            + "원 · 품목 " + (mst.getItems()==null?0:mst.getItems().size()) + "건");
			return ".raw/main/mangr/stmtPrint";
		}
		/** 공개 페이지가 그대로 쓰는 자료 한 덩어리 — 화면(salesReg)이 만드는 D·O·S·P 와 같은 모양이다.
		 *  @param opt 보낸 사람이 고른 출력 조건(주소 뒤 &o=) — 없으면(옛 링크) 종전 고정 조건 그대로.
		 *  @param bal 보낼 때의 전잔고·잔고(주소 뒤 &b=) — 「잔고 출력」을 골랐을 때만 실려 온다. */
		private String stmtJson(egovframework.konet.user.model.SalesTrxDTO m, String opt, String bal) throws Exception {
			Map<String,Object> D = new HashMap<String,Object>();
			D.put("dt", poDash(m.getSaleDt())); D.put("no", m.getSaleNo()); D.put("dlvDt", poDash(m.getDlvDt()));
			D.put("venNm", m.getCustNm()); D.put("remark", m.getRemark());
			D.put("pay", m.getPayAmt()); D.put("dc", m.getDcAmt());
			Map<String,Object> t = new HashMap<String,Object>();
			t.put("box", m.getTotBoxQty()); t.put("ea", m.getTotEaQty()); t.put("qty", m.getTotQty());
			t.put("sup", m.getSupplyAmt()); t.put("vat", m.getVatAmt()); t.put("tot", m.getTotAmt());
			D.put("t", t);
			D.put("rows", m.getItems() == null ? new java.util.ArrayList<Object>() : m.getItems());
			/* 공급받는자 — 거래처 마스터 그대로(사업자번호·주소·이메일·연락처) */
			Map<String,Object> ven = new HashMap<String,Object>();
			egovframework.konet.user.model.VendorDTO vq = new egovframework.konet.user.model.VendorDTO();
			vq.setVendorCd(m.getCustCd()); vq.setCompCd(m.getCompCd());
			java.util.List<egovframework.konet.user.model.VendorDTO> vl = svc.selectVendorMst(vq);
			if (vl != null && !vl.isEmpty()) {
				egovframework.konet.user.model.VendorDTO v = vl.get(0);
				ven.put("bizno", v.getBizno()); ven.put("addr", v.getAddr()); ven.put("addr2", v.getAddr2());
				ven.put("email", v.getEmail()); ven.put("hp", v.getHp()); ven.put("tel", v.getTel());
			}
			D.put("ven", ven);
			/* 공급자 — 회사 마스터(업태·종목·계좌 포함, 2026-09-09 신설 칸) */
			Map<String,Object> c = new HashMap<String,Object>(); c.put("compCd", m.getCompCd());
			Map<String,Object> comp = svc.selectCompInfo(c); if (comp == null) comp = new HashMap<String,Object>();
			poFillDefault(comp, "compNm", "company.name"); poFillDefault(comp, "busiNum", "company.busi.num");
			poFillDefault(comp, "compCeo", "company.ceo"); poFillDefault(comp, "compAddr", "company.addr");
			poFillDefault(comp, "compTel", "company.tel");
			Map<String,Object> S = new HashMap<String,Object>();
			S.put("nm", poStr(comp.get("compNm")));   S.put("biz", poStr(comp.get("busiNum")));
			S.put("ceo", poStr(comp.get("compCeo"))); S.put("cond", poStr(comp.get("bizCond")));
			S.put("item", poStr(comp.get("bizItem"))); S.put("addr", poStr(comp.get("compAddr")));
			S.put("bank", poStr(comp.get("bankAcct"))); S.put("tel", poStr(comp.get("compTel")));
			/* 공지사항도 회사 정보에서 온다 (2026-09-09) — 종전에는 브라우저에만 있어 공개 링크에는 빈 칸으로 나갔다 */
			S.put("notice", poStr(comp.get("stmtNotice")));
			/* 공지사항2·도장 (2026-09-11 회사 정보 수정 ①②) — 보낸 명세서에도 인쇄와 똑같이 찍힌다 */
			S.put("notice2", poStr(comp.get("stmtNotice2")));
			S.put("stamp", poStr(comp.get("stampImg")));
			/* ★조건 = <보낸 사람이 고른 그대로> (2026-09-10 「카톡·이메일이 조건대로 안 나옴, 미리보기·인쇄는 잘됨」)
			     종전에는 여기서 고정이라 인쇄방식·줄수를 아무리 바꿔도 보낸 명세서는 늘
			     「공급받는자용 한 부 · 38줄」이었다 — [👁 미리보기]로 본 것과 받는 쪽이 보는 것이 달랐다.
			   ★조건은 주소 뒤(&o=)로 온다 — 전표에 저장하지 않는다. 토큰은 전표당 하나뿐이라
			     저장해 버리면 조건만 바꿔 다시 보낼 때 <이미 보낸 링크의 모양까지> 같이 바뀐다.
			   ★조건이 없거나(옛 링크) 모양이 틀리면 <종전 고정 조건>으로 되돌아간다 — 이미 나간 링크가 살아 있어야 한다. */
			Map<String,Object> O = new HashMap<String,Object>();
			O.put("ord","in"); O.put("amt","Y"); O.put("price","Y"); O.put("bal","N"); O.put("inv","N");
			O.put("boxp","N"); O.put("chg","N");
			O.put("vat", (m.getVatAmt()!=null && m.getVatAmt().doubleValue()!=0d) ? "Y" : "N");
			O.put("rows", 38); O.put("mode","b1");
			/* 2026-09-11 늘어난 넷 — 옛 링크(7자리·조건 없음)는 종전 모양 그대로(바코드·반품실매출·음영 없음, 인쇄일시 있음) */
			O.put("bc","N"); O.put("rtn","N"); O.put("shade","N"); O.put("ptime","Y");
			stmtOpt(O, opt);
			/* 바코드 — 전표 줄마다 상품마스터 바코드를 붙여 왔다(selectSalesTrxDtl.bcNo) */
			if ("Y".equals(O.get("bc")) && m.getItems() != null) {
				Map<String,Object> bm = new HashMap<String,Object>();
				for (egovframework.konet.user.model.SalesTrxDtlDTO d : m.getItems())
					if (d.getBcNo() != null && d.getProdCd() != null) bm.put(d.getProdCd(), d.getBcNo());
				D.put("bcMap", bm);
			}
			/* 잔고 — <보낼 때의 숫자>를 그대로 싣는다(&b=전잔고,잔고).
			   여기서 원장을 다시 세면 나중에 열 때마다 잔고가 달라져 「보낸 명세서」와 어긋난다. */
			if ("Y".equals(O.get("bal")) && bal != null && bal.trim().matches("^-?\\d{1,15},-?\\d{1,15}$")) {
				String[] bb = bal.trim().split(",");
				D.put("balBefore", Double.valueOf(bb[0]));
				D.put("balAfter",  Double.valueOf(bb[1]));
			}
			/* 정렬 = 조회번호 — 상품마스터의 SORT_ORD 를 전표 줄마다 붙여 왔다(selectSalesTrxDtl) */
			if ("sort".equals(O.get("ord")) && m.getItems() != null) {
				Map<String,Object> sm = new HashMap<String,Object>();
				for (egovframework.konet.user.model.SalesTrxDtlDTO d : m.getItems())
					if (d.getSortOrd() != null && d.getProdCd() != null) sm.put(d.getProdCd(), d.getSortOrd());
				D.put("sortMap", sm);
			}
			Map<String,Object> all = new HashMap<String,Object>();
			all.put("D", D); all.put("O", O); all.put("S", S);
			/* 단가변동 — 이 거래처의 직전 판매단가. 화면(saPrtPrev)과 <같은 규칙>이다 :
			   같은 판매일자 줄은 건너뛰고 그 앞의 첫 줄을 직전 단가로 본다. 지난 자료라 나중에 열어도 안 변한다. */
			all.put("P", stmtPrevPrice(m, O));
			/* ★'<' 를 < 로 바꿔 둔다 — 이 JSON 은 페이지의 <script> 안에 그대로 박히는데,
			     품명·비고에 「</script」 같은 글자가 있으면 거기서 스크립트가 끊겨 페이지가 깨진다.
			     JSON 문자열 안에서는 < 가 '<' 와 같은 뜻이라 값은 그대로다. */
			return new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(all).replace("<", "\\u003C");
		}
		/** 보낸 사람이 고른 출력 조건 한 줄 — 주소 뒤 &o= 에 실려 온다 (2026-09-10).
		 *  모양 : 「정렬 + 예/아니오 7개 - 한 장에 품목 줄수 - 인쇄방식」  예) i1100001-10-both
		 *    정렬 i=입력순서 · s=조회번호 / 1·0 = 금액·단가·잔고·반전·박스단가·단가변동·부가세
		 *    인쇄방식 both=한 장에 모두 · two=두 장으로 · b1=공급받는자용만 · r1=공급자 보관용만
		 *  ★만드는 곳은 화면의 saShareOptQs() 하나뿐이다 — 글자 순서를 바꾸면 두 곳을 같이 고칠 것.
		 *  ★틀린 글자는 <통째로 무시>한다(고정 조건 유지) — 주소를 손으로 고쳐도 엉뚱한 명세서가 나오지 않는다. */
		private static void stmtOpt(Map<String,Object> O, String opt) {
			if (opt == null) return;
			/* ★7자리(2026-09-10 옛 링크) · 11자리(2026-09-11 — 바코드·반품실매출·음영·인쇄일시 넷을 뒤에 더함) 둘 다 받는다 */
			java.util.regex.Matcher mo =
				java.util.regex.Pattern.compile("^([is])([01]{7}|[01]{11})-(\\d{1,2})-(both|two|b1|r1)$").matcher(opt.trim());
			if (!mo.matches()) return;
			String f = mo.group(2);
			String[] k = { "amt", "price", "bal", "inv", "boxp", "chg", "vat", "bc", "rtn", "shade", "ptime" };
			if (f.length() < k.length) k = java.util.Arrays.copyOf(k, f.length());
			O.put("ord", "i".equals(mo.group(1)) ? "in" : "sort");
			for (int i = 0; i < k.length; i++) O.put(k[i], f.charAt(i) == '1' ? "Y" : "N");
			int rows = Integer.parseInt(mo.group(3));
			O.put("rows", Math.max(3, Math.min(40, rows)));       /* 조건 창과 같은 한계(3~40) */
			O.put("mode", mo.group(4));
		}
		/** 이메일 본문에 넣을 주소 뒤 「&o=…&b=…」 — 화면이 보내 준 조건을 <검사해서> 붙인다.
		 *  틀린 글자면 아무것도 안 붙여 종전 고정 조건으로 나간다(공개 페이지 stmtOpt 와 같은 규칙). */
		private static String stmtOptQs(String opt, String bal) {
			String s = "";
			if (opt != null && opt.trim().matches("^[is]([01]{7}|[01]{11})-\\d{1,2}-(both|two|b1|r1)$")) {
				s = "&o=" + opt.trim();
				if (bal != null && bal.trim().matches("^-?\\d{1,15},-?\\d{1,15}$")) s += "&b=" + bal.trim();
			}
			return s;
		}
		/** 단가변동(예)일 때만 — 품목마다 이 거래처의 직전 판매단가 {상품코드:단가}. 화면 saPrtPrev() 와 같은 규칙.
		 *  조회가 실패하면 그 품목만 빠진다(▲▼ 가 안 붙을 뿐 명세서는 그대로 나온다). */
		private Map<String,Object> stmtPrevPrice(egovframework.konet.user.model.SalesTrxDTO m, Map<String,Object> O) {
			Map<String,Object> P = new HashMap<String,Object>();
			if (!"Y".equals(O.get("chg")) || m.getItems() == null) return P;
			String ymd = m.getSaleDt() == null ? "" : m.getSaleDt().replace("-", "");
			for (egovframework.konet.user.model.SalesTrxDtlDTO d : m.getItems()) {
				String cd = d.getProdCd();
				if (cd == null || cd.isEmpty() || P.containsKey(cd)) continue;
				try {
					egovframework.konet.user.model.SalesTrxDtlDTO q = new egovframework.konet.user.model.SalesTrxDtlDTO();
					q.setProdCd(cd);
					q.setRemark(m.getCustCd());      /* ★이 조회는 remark 칸에 거래처코드를 담는다(매입과 같은 방식) */
					java.util.List<egovframework.konet.user.model.SalesTrxDtlDTO> l = svc.selectSalesPriceHist(q);
					if (l == null) continue;
					for (egovframework.konet.user.model.SalesTrxDtlDTO x : l) {
						if (ymd.equals(poStr(x.getSpec()))) continue;    /* 같은 날 전표(=지금 이 전표)는 건너뛴다 */
						if (x.getUnitPrice() != null) P.put(cd, x.getUnitPrice());
						break;
					}
				} catch (Exception e) { log.error(" stmtPrevPrice ERROR : " + cd + " / " + e.getMessage()); }
			}
			return P;
		}
		private static String poDash(String ymd) {
			String s = ymd == null ? "" : ymd.trim();
			return s.length()==8 ? s.substring(0,4)+"-"+s.substring(4,6)+"-"+s.substring(6,8) : s;
		}
		/** 메일 계정이 설정돼 있는지 — 화면이 [이메일발송] 단추 모양을 정할 때 묻는다 (2026-09-09) */
		@RequestMapping(value="/mangr/mailReady.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> mailReady(HttpSession session) {
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("ready", session.getAttribute("s_comp_cd") != null && egovframework.konet.cmmn.MailSender.ready());
			res.put("from", egovframework.konet.cmmn.MailSender.prop("mail.from"));
			/* 인증 실패(535) 안내에 쓴다 (2026-09-10) — <어느 계정>을 <어디서> 고쳐야 하는지.
			   ★비밀번호 값은 안 보낸다. 온 곳(실행옵션/파일)과 아이디만. */
			res.put("user",   egovframework.konet.cmmn.MailSender.prop("mail.smtp.user"));
			res.put("host",   egovframework.konet.cmmn.MailSender.prop("mail.smtp.host"));
			res.put("pwFrom", egovframework.konet.cmmn.MailSender.pwSource());
			return res;
		}
		/** ★거래명세서 이메일 발송 (2026-09-09) — 서버가 직접 보낸다(위너넷 방식).
		 *  계정(mail.properties)이 비어 있으면 <보내지 않고> 그 사실을 돌려준다 —
		 *  화면은 그때 [메일 프로그램 열기]로 넘긴다. 그래서 계정이 없어도 기능이 죽지 않는다.
		 *  본문 = 인사말 + 요약(일자·전표번호·합계) + <명세서 보기> 링크(공개 주소). */
		@RequestMapping(value="/mangr/stmtMailSend.do", method = RequestMethod.POST)
		public ResponseEntity<String> stmtMailSend(@RequestParam("saleSeq") long saleSeq,
		                                           @RequestParam("to") String to,
		                                           @RequestParam(value="subject", required=false) String subject,
		                                           @RequestParam(value="memo", required=false) String memo,
		                                           /* 출력 조건 (2026-09-10) — 카톡·링크는 화면이 주소에 붙이지만
		                                              이메일은 <서버가> 주소를 만들므로 그대로 받아서 붙인다. */
		                                           @RequestParam(value="opt", required=false) String opt,
		                                           @RequestParam(value="bal", required=false) String bal,
		                                           HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				if (!egovframework.konet.cmmn.MailSender.ready())
					return ResponseEntity.status(503).body("메일 계정이 아직 설정되지 않았습니다 (mail.properties).");
				egovframework.konet.user.model.SalesTrxDTO q = new egovframework.konet.user.model.SalesTrxDTO();
				q.setSaleSeq(saleSeq);
				q.setUpdUser(session.getAttribute("s_user_id") == null ? "" : String.valueOf(session.getAttribute("s_user_id")));
				q.setUpdIp(request.getRemoteAddr());
				String token = svc.shareSalesTrx(q);            // 토큰 발급(처음 한 번) — 링크가 본문에 들어간다
				if (token == null) return ResponseEntity.status(404).body("전표를 찾을 수 없습니다.");
				egovframework.konet.user.model.SalesTrxDTO m = svc.selectSalesTrxByToken(token);
				if (m == null) return ResponseEntity.status(404).body("전표를 찾을 수 없습니다.");
				/* 읽음·열람 열쇠 (2026-09-10) — 이 전송 한 건의 무작위 열쇠. 링크 뒤 &s= 와 1×1 그림 ?k= 에 붙어 나가
				   받는 쪽이 열면 «이 줄»로 돌아온다(토큰은 전표당 하나라 전송을 못 가른다). */
				String key = sendHistKey();
				String url = poShareBase(request) + "/pub/stmt.do?t=" + token + stmtOptQs(opt, bal) + "&s=" + key;
				String pixel = poShareBase(request) + "/pub/mailOpen.do?k=" + key;
				Map<String,Object> c = new HashMap<String,Object>(); c.put("compCd", m.getCompCd());
				Map<String,Object> comp = svc.selectCompInfo(c); if (comp == null) comp = new HashMap<String,Object>();
				poFillDefault(comp, "compNm", "company.name"); poFillDefault(comp, "compTel", "company.tel");
				String sender = poStr(comp.get("compNm"));
				String subj = (subject == null || subject.trim().isEmpty())
				            ? "[" + sender + "] 거래명세서 " + poDash(m.getSaleDt()) + " (" + poStr(m.getSaleNo()) + ")"
				            : subject.trim();
				try {
					egovframework.konet.cmmn.MailSender.sendHtml(to, subj, stmtMailHtml(m, url, sender, poStr(comp.get("compTel")), memo, pixel));
				} catch (Exception se) {
					/* ★실패도 이력에 남긴다 — 「보냈는데 안 왔다」를 가릴 수 있는 유일한 기록이다 */
					sendHistLog(request, session, "STMT", saleSeq, m.getSaleDt(), m.getSaleNo(),
					            m.getCustCd(), m.getCustNm(), "EMAIL", to, subj, memo, url,
					            m.getTotAmt(), "FAIL", se.getMessage(), key);
					throw se;
				}
				sendHistLog(request, session, "STMT", saleSeq, m.getSaleDt(), m.getSaleNo(),
				            m.getCustCd(), m.getCustNm(), "EMAIL", to, subj, memo, url,
				            m.getTotAmt(), "OK", null, key);
				return ResponseEntity.ok("1");
			} catch (Exception e) {
				log.error(" stmtMailSend ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage() == null ? "발송에 실패했습니다." : e.getMessage());
			}
		}
		/* ═══════════ 문서 전송이력 (2026-09-10 신설) ═══════════
		   판매등록 [거래명세표] 와 발주서(poReg) 를 카톡·이메일·링크로 보낸 <사실>을 남긴다.
		   ★두 화면이 같은 표(TBL_SEND_HIST)를 쓰고 DOC_GB('STMT'/'PO') 로만 갈린다 —
		     표를 두 벌로 두면 조회 규칙도 두 벌이 되어 조용히 달라진다.
		   ★기록은 «보낸 사실» 이라 고치거나 지우는 길을 두지 않는다(넣기·읽기 두 개뿐).
		   ★서버가 직접 보내는 이메일은 <서버가> 남기고(성공·실패 둘 다),
		     카톡·링크·메일프로그램처럼 <브라우저에서 나가는 것>은 화면이 sendHistSave.do 로 알린다.
		     브라우저가 보낸 것을 서버가 알 길이 없기 때문이다. */
		private void sendHistLog(HttpServletRequest request, HttpSession session,
		                         String docGb, long docSeq, String docDt, String docNo,
		                         String vendorCd, String vendorNm, String sendGb, String sendTo,
		                         String subject, String memo, String shareUrl,
		                         Double totAmt, String resultGb, String errMsg, String trackKey) {
			try {
				Map<String,Object> p = new HashMap<String,Object>();
				p.put("docGb", docGb); p.put("docSeq", docSeq); p.put("docDt", docDt); p.put("docNo", docNo);
				p.put("vendorCd", vendorCd); p.put("vendorNm", vendorNm);
				p.put("sendGb", sendGb); p.put("sendTo", sendTo);
				p.put("subject", poCut(subject, 300)); p.put("memo", poCut(memo, 500));
				p.put("shareUrl", poCut(shareUrl, 300)); p.put("totAmt", totAmt);
				p.put("resultGb", resultGb == null ? "OK" : resultGb); p.put("errMsg", poCut(errMsg, 500));
				p.put("trackKey", poCut(trackKey, 32));
				p.put("regUser", session.getAttribute("s_user_id") == null ? "" : String.valueOf(session.getAttribute("s_user_id")));
				p.put("regIp", request.getRemoteAddr());
				svc.insertSendHist(p);
			} catch (Exception e) {
				/* ★이력이 안 남았다고 이미 나간 메일·카톡을 되돌릴 수는 없다 — 로그만 남기고 넘어간다 */
				log.error(" sendHistLog ERROR : " + e.getMessage());
			}
		}
		private static String poCut(String s, int n) {
			if (s == null) return null;
			String t = s.trim();
			return t.length() > n ? t.substring(0, n) : t;
		}
		/** 화면에서 나간 전송(카톡·링크·메일프로그램·Gmail·내용복사)을 기록한다. */
		@RequestMapping(value="/mangr/sendHistSave.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> sendHistSave(@RequestParam("docGb") String docGb,
		                                       @RequestParam("docSeq") long docSeq,
		                                       @RequestParam(value="docDt", required=false) String docDt,
		                                       @RequestParam(value="docNo", required=false) String docNo,
		                                       @RequestParam(value="vendorCd", required=false) String vendorCd,
		                                       @RequestParam(value="vendorNm", required=false) String vendorNm,
		                                       @RequestParam("sendGb") String sendGb,
		                                       @RequestParam(value="sendTo", required=false) String sendTo,
		                                       @RequestParam(value="subject", required=false) String subject,
		                                       @RequestParam(value="memo", required=false) String memo,
		                                       @RequestParam(value="shareUrl", required=false) String shareUrl,
		                                       @RequestParam(value="totAmt", required=false) Double totAmt,
		                                       @RequestParam(value="resultGb", required=false) String resultGb,
		                                       @RequestParam(value="errMsg", required=false) String errMsg,
		                                       @RequestParam(value="trackKey", required=false) String trackKey,
		                                       HttpServletRequest request, HttpSession session) {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("error", "로그인이 필요합니다."); return res; }
			sendHistLog(request, session, docGb, docSeq, docDt, docNo, vendorCd, vendorNm,
			            sendGb, sendTo, subject, memo, shareUrl, totAmt, resultGb, errMsg, trackKey);
			res.put("data", 1);
			return res;
		}
		/** 전송 한 건의 열쇠 — 무작위 20자(맞혀 낼 수 없고, 맞혀도 횟수만 올릴 수 있다). 화면 쪽은 send-hist.js 의 key() 가 같은 꼴로 만든다. */
		private static String sendHistKey() {
			return java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 20);
		}
		/** ★메일 열림 — 메일 본문의 1×1 그림이 부르는 주소 (2026-09-10). 로그인 없이 열쇠만으로 그 전송 한 줄의 MAIL_OPEN 을 올린다.
		 *  어떤 경우에도 그림(1×1 GIF)은 돌려준다 — 실패해도 메일 본문에 깨진 그림이 보이면 안 된다.
		 *  ⚠메일 프로그램이 그림을 막으면 안 불린다 — 「못 잡았다」≠「안 읽었다」. 명세서 열람(VIEW)이 더 확실하다. */
		@RequestMapping(value="/pub/mailOpen.do")
		public ResponseEntity<byte[]> mailOpen(@RequestParam(value="k", required=false) String key) {
			try {
				if (key != null && key.matches("[0-9a-fA-F]{8,32}")) {
					Map<String,Object> p = new HashMap<String,Object>(); p.put("trackKey", key);
					svc.updateSendHistMailOpen(p);
				}
			} catch (Exception e) { log.error(" mailOpen ERROR : " + e.getMessage()); }
			byte[] gif = new byte[]{ 0x47,0x49,0x46,0x38,0x39,0x61, 1,0,1,0, (byte)0x80,0,0, 0,0,0, 0,0,0,
			                         0x21,(byte)0xF9,4,1,0,0,0,0, 0x2C,0,0,0,0,1,0,1,0,0, 2,2,0x44,1,0,0x3B };
			return ResponseEntity.ok()
				.header("Content-Type", "image/gif")
				.header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
				.header("Pragma", "no-cache").header("Expires", "0")
				.body(gif);
		}
		/** 링크 열람 — 공개 페이지(/pub/stmt.do · /pub/po.do)가 열릴 때 &s=열쇠 가 있으면 그 전송 줄의 VIEW 를 올린다. 실패해도 페이지는 그대로 보인다. */
		private void sendHistView(String key, String docGb) {
			try {
				if (key == null || !key.matches("[0-9a-fA-F]{8,32}")) return;
				Map<String,Object> p = new HashMap<String,Object>(); p.put("trackKey", key); p.put("docGb", docGb);
				svc.updateSendHistView(p);
			} catch (Exception e) { log.error(" sendHistView ERROR : " + e.getMessage()); }
		}
		/** 전송이력 조회 — docSeq 를 주면 그 전표 하나, 안 주면 기간 전체(최근 500건). */
		@RequestMapping(value="/mangr/sendHistList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> sendHistList(@RequestParam(value="docGb", required=false) String docGb,
		                                       @RequestParam(value="docSeq", required=false, defaultValue="0") long docSeq,
		                                       @RequestParam(value="fromDt", required=false) String fromDt,
		                                       @RequestParam(value="toDt", required=false) String toDt,
		                                       @RequestParam(value="findData", required=false) String findData,
		                                       HttpSession session) throws Exception {
			Map<String,Object> res = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { res.put("error", "로그인이 필요합니다."); return res; }
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("docGb", docGb); p.put("docSeq", docSeq);
			p.put("fromDt", fromDt); p.put("toDt", toDt); p.put("findData", findData);
			res.put("data", svc.selectSendHistList(p));
			return res;
		}
		/** 메일 본문 — 명세서 자체는 링크로 본다(양식을 두 벌로 만들지 않는다). 여기는 안내와 요약만. */
		private String stmtMailHtml(egovframework.konet.user.model.SalesTrxDTO m, String url,
		                            String sender, String tel, String memo, String pixel) {
			java.text.DecimalFormat df = new java.text.DecimalFormat("#,##0");
			StringBuilder b = new StringBuilder();
			b.append("<div style=\"font-family:'맑은 고딕',Malgun Gothic,sans-serif;font-size:14px;color:#1f2a37;line-height:1.7\">");
			b.append("<p><b>").append(poEsc(m.getCustNm())).append("</b> 귀하</p>");
			b.append("<p>거래명세서를 보내 드립니다. 아래 단추를 누르면 명세서를 보실 수 있습니다(로그인 없이 열립니다).</p>");
			if (memo != null && !memo.trim().isEmpty())
				b.append("<p style=\"white-space:pre-line;background:#f5f7f9;border-left:3px solid #137a6c;padding:8px 12px\">")
				 .append(poEsc(memo.trim())).append("</p>");
			b.append("<table style=\"border-collapse:collapse;margin:14px 0;font-size:13.5px\">");
			b.append("<tr><td style=\"padding:4px 14px 4px 0;color:#5a6b7a\">일자</td><td><b>")
			 .append(poDash(m.getSaleDt())).append("</b> (").append(poEsc(m.getSaleNo())).append(")</td></tr>");
			b.append("<tr><td style=\"padding:4px 14px 4px 0;color:#5a6b7a\">품목</td><td>")
			 .append(m.getItems()==null?0:m.getItems().size()).append("건</td></tr>");
			b.append("<tr><td style=\"padding:4px 14px 4px 0;color:#5a6b7a\">합계금액</td><td><b style=\"font-size:16px;color:#137a6c\">")
			 .append(df.format(m.getTotAmt()==null?0d:m.getTotAmt())).append(" 원</b></td></tr>");
			b.append("</table>");
			b.append("<p><a href=\"").append(poEsc(url)).append("\" ")
			 .append("style=\"display:inline-block;background:#137a6c;color:#fff;text-decoration:none;")
			 .append("padding:11px 22px;border-radius:7px;font-weight:700\">📄 거래명세서 보기</a></p>");
			b.append("<p style=\"font-size:12px;color:#8a97a4;word-break:break-all\">단추가 눌리지 않으면 이 주소를 붙여 넣으세요<br>")
			 .append(poEsc(url)).append("</p>");
			b.append("<hr style=\"border:0;border-top:1px solid #dbe2ea;margin:18px 0\">");
			b.append("<p style=\"font-size:12.5px;color:#5a6b7a\">").append(poEsc(sender));
			if (tel != null && !tel.isEmpty()) b.append(" · ").append(poEsc(tel));
			b.append("</p>");
			/* 읽음 표시용 1×1 그림 (2026-09-10) — 메일을 열면 /pub/mailOpen.do?k=열쇠 가 불린다 */
			if (pixel != null && !pixel.isEmpty())
				b.append("<img src=\"").append(poEsc(pixel)).append("\" width=\"1\" height=\"1\" alt=\"\" ")
				 .append("style=\"display:block;width:1px;height:1px;border:0;opacity:0\">");
			b.append("</div>");
			return b.toString();
		}
		private static String poEsc(String s) {
			return s == null ? "" : s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
		}

		/** 거래처 이메일만 저장 — 거래명세서 [이메일발송] 창의 「저장」 (2026-09-09).
		 *  ★EMAIL 한 칸만 고친다. 발송 창에서 거래처를 통째로 저장하면 다른 칸이 빈 값으로 날아간다. */
		@RequestMapping(value="/vendor/vendorEmailSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> vendorEmailSave(@RequestParam("vendorCd") String vendorCd,
		                                              @RequestParam(value="email", required=false) String email,
		                                              HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				if (vendorCd == null || vendorCd.trim().isEmpty()) return ResponseEntity.status(400).body("거래처를 고르세요.");
				egovframework.konet.user.model.VendorDTO dto = new egovframework.konet.user.model.VendorDTO();
				dto.setVendorCd(vendorCd.trim());
				dto.setEmail(email == null ? "" : email.trim());
				dto.setUpdUser(session.getAttribute("s_user_id") == null ? "" : String.valueOf(session.getAttribute("s_user_id")));
				dto.setUpdIp(request.getRemoteAddr());
				int cnt = svc.updateVendorEmail(dto);
				if (cnt == 0) return ResponseEntity.status(404).body("거래처를 찾을 수 없습니다.");
				return ResponseEntity.ok(String.valueOf(cnt));
			} catch (Exception e) {
				log.error(" vendorEmailSave ERROR : " + e.getMessage());
				return ResponseEntity.status(500).body(e.getMessage());
			}
		}

		@RequestMapping(value="/mangr/salesTrxNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxNextNo(@ModelAttribute("DTO") egovframework.konet.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxNextNo(dto));
			return response;
		}
		/** 전표 저장 — 헤더+명세를 통째로 받는다(JSON). 신규/수정 모두 이 하나로 */
		@RequestMapping(value="/mangr/salesTrxSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> salesTrxSave(@RequestBody egovframework.konet.user.model.SalesTrxDTO dto,
		                                           HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getSaleDt()==null || dto.getSaleDt().trim().isEmpty()) return ResponseEntity.status(400).body("판매일자를 선택하세요.");
				if (dto.getCustCd()==null || dto.getCustCd().trim().isEmpty()) return ResponseEntity.status(400).body("거래처를 선택하세요.");
				if (dto.getItems()==null || dto.getItems().isEmpty()) return ResponseEntity.status(400).body("상품을 한 줄 이상 입력하세요.");
				/* ★거래중지 코드 차단 (2026-08-17 지시 "매입등록시, 판매등록시 조건 추가") — 판매일자 기준.
				   ⚠서브코드 차단은 매입만이지만(판매는 거래처 코드로 나가는 것이 정상), ***중지된 코드는
				     어느 쪽으로도 쓰면 안 된다*** — 그래서 판매도 막는다. */
				java.util.List<String> sCodes = new java.util.ArrayList<String>();
				for (egovframework.konet.user.model.SalesTrxDtlDTO it : dto.getItems()) sCodes.add(it.getProdCd());
				String sStopMsg = stopBlockMsg(sCodes, dto.getSaleDt(), session);
				if (sStopMsg != null) return ResponseEntity.status(409).body(sStopMsg);
				/* ★회사 설정 관문 (2026-09-11 회사 정보 수정 「기능 ▸ 매출」) — 재고 부족 제한 · 여신 초과 제한.
				     서버에서 막는다(판매 저장 길이 여럿 — 명세·일괄등록·카톡 주문 — 이 한 엔드포인트로 모인다). 둘 다 기본은 꺼짐. */
				String sLimitMsg = svc.salesLimitMsg(dto);
				if (sLimitMsg != null) return ResponseEntity.status(409).body(sLimitMsg);
				String u = (session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"");
				dto.setRegUser(u); dto.setUpdUser(u);
				dto.setRegIp(request.getRemoteAddr()); dto.setUpdIp(request.getRemoteAddr());
				int n = svc.saveSalesTrx(dto);
				return ResponseEntity.ok("{\"rows\":" + n + ",\"saleSeq\":" + dto.getSaleSeq() + ",\"saleNo\":\"" + dto.getSaleNo() + "\"}");
			} catch (Exception e) { log.error(" salesTrxSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/salesTrxDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> salesTrxDelete(@RequestBody egovframework.konet.user.model.SalesTrxDTO dto,
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
		public Map<String,Object> salesLastPrice(@ModelAttribute("DTO") egovframework.konet.user.model.SalesTrxDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			egovframework.konet.user.model.SalesTrxDtlDTO last = svc.selectCustLastPrice(dto);
			response.put("data",   last == null ? null : last.getUnitPrice());   // 종전 그대로 — 화면은 data 를 단가로 읽는다
			response.put("remark", last == null ? null : last.getRemark());      // 이전 비고(2026-09-13) — 비어 있지 않은 마지막 것, 카톡 원문 제외
			return response;
		}
		/** 매출내역·마감현황에 얹을 판매전표 명세 — 정산서 행과 같은 모양으로 돌려준다 */
		@RequestMapping(value="/mangr/salesTrxHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesTrxHist(@ModelAttribute("DTO") egovframework.konet.user.model.SalesTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesTrxHist(dto));
			return response;
		}
		/** 품명 클릭 → 거래처 × 상품 판매단가 이력(최대 3년) */
		@RequestMapping(value="/mangr/salesPriceHist.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesPriceHist(@ModelAttribute("DTO") egovframework.konet.user.model.SalesTrxDtlDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesPriceHist(dto));
			return response;
		}

		/* ===== 납품분 (2026-07-31) — 그 거래처에 이미 나간 품목을 중복 없이 =====
		   판매전표 + 정산서를 함께 본다. 체크한 순서대로 명세에 담는 건 화면이 한다.
		   제외는 거래처별(TBL_SALES_DLV_EXCL) — DDL: sql/sales_dlv_excl_ddl.sql */
		@RequestMapping(value="/mangr/salesDlvList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesDlvList(@ModelAttribute("DTO") egovframework.konet.user.model.SalesDlvDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesDlvList(dto));
			return response;
		}
		/** 매입분 — 그 매입처에서 사 온 품목(매입전표 + 매입단가이력). 매입등록 화면의 [매입분] */
		@RequestMapping(value="/mangr/purchDlvList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> purchDlvList(@ModelAttribute("DTO") egovframework.konet.user.model.SalesDlvDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectPurchDlvList(dto));
			return response;
		}
		/** 제외이력보기 — 그 거래처에서 빼 둔 품목. gb 'S' 판매(납품분) / 'P' 매입(매입분) */
		@RequestMapping(value="/mangr/salesDlvExclList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> salesDlvExclList(@ModelAttribute("DTO") egovframework.konet.user.model.SalesDlvDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalesDlvExclList(dto));
			return response;
		}
		/** 납품분제외 / 제외해제 — prodCds 에 상품코드를 콤마로 이어 보낸다. actionYn 'Y' 제외 / 'N' 해제 */
		@RequestMapping(value="/mangr/salesDlvExclSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> salesDlvExclSave(@ModelAttribute("DTO") egovframework.konet.user.model.SalesDlvDTO dto,
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
		public Map<String,Object> settleList(@ModelAttribute("DTO") egovframework.konet.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSettleList(dto));
			return response;
		}
		@RequestMapping(value="/mangr/settleNextNo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> settleNextNo(@ModelAttribute("DTO") egovframework.konet.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSettleNextNo(dto));
			return response;
		}
		@RequestMapping(value="/mangr/settleSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> settleSave(@RequestBody egovframework.konet.user.model.SettleTrxDTO dto,
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
		public ResponseEntity<String> settleDelete(@RequestBody egovframework.konet.user.model.SettleTrxDTO dto,
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
		public Map<String,Object> custLedger(@ModelAttribute("DTO") egovframework.konet.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
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
		public Map<String,Object> selectCustBalance(@ModelAttribute("DTO") egovframework.konet.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectCustBalance(dto));
			return response;
		}
		/* 위 화면 하단 — 고른 거래처의 **특정일자 하루** 건별 내역(출고·매입·입금·출금).
		   ★위 잔액(누계)과는 별개다. 한 표에 섞었다가 "너무 복잡"하다는 지적으로 갈라 놓은 것이니 다시 섞지 말 것.
		   파라미터 = custCd + trxDt. */
		@RequestMapping(value="/mangr/selectCustDayDetail.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> selectCustDayDetail(@ModelAttribute("DTO") egovframework.konet.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
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
		public Map<String,Object> selectDayBook(@ModelAttribute("DTO") egovframework.konet.user.model.SettleTrxDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectDayBook(dto));
			return response;
		}

		/* ================= 정산 월 마감 — TBL_SETTLE_CLOSE_MST (2026-09-16 P2-g 수금/미수 연동) =================
		   · 수기 장부(receiveMng/paymentMng · TBL_RECEIVE_MST/TBL_PAYMENT_MST 직접 입력) 엔드포인트 14개는 삭제했다 —
		     메뉴에서 내린 2026-07-25 이후 실사용 0. 남긴 것은 월 마감 «상태·확정·해제» 뿐이고 거래처별 채권·채무(custBalance.jsp)가 쓴다.
		   · RCV 확정 = 그 달의 거래처별 이월·매출·수금을 TBL_RECEIVE_MST 에 **스냅샷**으로 굳힌다(서비스 confirmSettleClose).
		   · 확정된 달의 전표 저장·삭제는 **막지 않는다** — 수금·판매 등록 화면이 settleCloseInfo 로 확인창만 띄운다(사용자 방침 「메시지 처리」). */
		@RequestMapping(value="/mangr/settleCloseInfo.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> settleCloseInfo(@RequestParam(value="settleGb", required=false) String settleGb, HttpSession session) throws Exception {
			Map<String,Object> r = new HashMap<String,Object>();
			String gb = (settleGb == null || settleGb.trim().isEmpty()) ? "RCV" : settleGb.trim().toUpperCase();
			String compCd = session.getAttribute("s_comp_cd") == null ? null : String.valueOf(session.getAttribute("s_comp_cd"));
			r.put("closed", svc.selectSettleCloseList(gb, compCd));                                                     // 확정된 달 [{closeYm, confirmDttm, confirmUser}]
			r.put("snap", "RCV".equals(gb) ? svc.selectRcvSnapshot(null, compCd) : new java.util.ArrayList<Object>()); // 확정 스냅샷(전 달 · 거래처별)
			return r;
		}
		@RequestMapping(value="/mangr/settleCloseConfirm.do", method = RequestMethod.POST)
		public ResponseEntity<String> settleCloseConfirm(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String ym = p.get("closeYm") == null ? "" : String.valueOf(p.get("closeYm")).trim();
				String gb = p.get("settleGb") == null ? "RCV" : String.valueOf(p.get("settleGb")).trim().toUpperCase();
				if (ym.replace("-","").length() != 6) return ResponseEntity.status(400).body("마감할 달(YYYY-MM)이 필요합니다.");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.confirmSettleClose(gb, ym, u, request.getRemoteAddr(), String.valueOf(session.getAttribute("s_comp_cd")))));
			} catch (Exception e) { log.error(" settleCloseConfirm ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/mangr/settleCloseCancel.do", method = RequestMethod.POST)
		public ResponseEntity<String> settleCloseCancel(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				String ym = p.get("closeYm") == null ? "" : String.valueOf(p.get("closeYm")).trim();
				String gb = p.get("settleGb") == null ? "RCV" : String.valueOf(p.get("settleGb")).trim().toUpperCase();
				if (ym.replace("-","").length() != 6) return ResponseEntity.status(400).body("해제할 달(YYYY-MM)이 필요합니다.");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.cancelSettleClose(gb, ym, u, String.valueOf(session.getAttribute("s_comp_cd")))));
			} catch (Exception e) { log.error(" settleCloseCancel ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* 총괄관리자 판정(2026-09-17) — 로그인 때 세션 s_main_gu = TBL_USER_MST.MAIN_GU ('1' 총괄관리자 · '2' 부관리자 · '3' 담당자, 공통코드 Z/MAIN_GU).
		   비용 등록·회사/사용자 관리는 총괄만 — 셸 메뉴(logistics_demo2.jsp)가 같은 조건으로 숨기고 여기서 직접 URL 을 막는다. */
		private static boolean isChief(HttpSession session) {
			Object g = session.getAttribute("s_main_gu");
			return g != null && "1".equals(String.valueOf(g).trim());
		}
		/* ================= 비용 등록 (2026-09-16 P2-e) — TBL_EXPENSE_ITEM / TBL_EXPENSE_TRX. 순마진 = 매출총이익 − 비용.
		   마감 확정된 달에 저장해도 막지 않는다(확인창은 화면이) — 확정값에 반영하려면 마감현황에서 다시 확정. ================= */
		@RequestMapping(value="/mangr/expenseReg.do")
		public String expenseReg(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			if (!isChief(session)) return "redirect:/main.do";   // ★총괄관리자만(2026-09-17) — 메뉴 숨김 + 직접 URL 차단
			return ".raw/main/mangr/expenseReg";
		}
		@RequestMapping(value="/mangr/expenseMonth.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> expenseMonth(@RequestParam(value="ym", required=false) String ym, HttpSession session) throws Exception {
			String compCd = session.getAttribute("s_comp_cd") == null ? null : String.valueOf(session.getAttribute("s_comp_cd"));
			return svc.selectExpenseMonth(ym, compCd);
		}
		@RequestMapping(value="/mangr/expenseItemSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> expenseItemSave(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				if (!isChief(session)) return ResponseEntity.status(403).body("총괄관리자만 비용을 등록할 수 있습니다.");
				String cd = p.get("itemCd") == null ? "" : String.valueOf(p.get("itemCd")).trim().toUpperCase();
				String nm = p.get("itemNm") == null ? "" : String.valueOf(p.get("itemNm")).trim();
				if (!cd.matches("[A-Z0-9_]{1,20}")) return ResponseEntity.status(400).body("항목코드는 영문 대문자·숫자·_ 1~20자입니다.");
				if (nm.isEmpty()) return ResponseEntity.status(400).body("항목 이름이 필요합니다.");
				int so = 0; try { so = (int) Double.parseDouble(String.valueOf(p.get("sortOrd"))); } catch (Exception e) { so = 0; }
				p.put("itemCd", cd); p.put("itemNm", nm); p.put("sortOrd", so);
				p.put("itemGb", "VAR".equals(p.get("itemGb")) ? "VAR" : "FIX");
				p.put("useYn", "N".equals(p.get("useYn")) ? "N" : "Y");
				p.put("compCd", session.getAttribute("s_comp_cd"));
				p.put("regUser", session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):""); p.put("regIp", request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.saveExpenseItem(p)));
			} catch (Exception e) { log.error(" expenseItemSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/mangr/expenseSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> expenseSave(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				if (!isChief(session)) return ResponseEntity.status(403).body("총괄관리자만 비용을 등록할 수 있습니다.");
				String ym = p.get("ym") == null ? "" : String.valueOf(p.get("ym")).trim();
				if (ym.replace("-","").length() != 6) return ResponseEntity.status(400).body("귀속월(YYYY-MM)이 필요합니다.");
				List<Map<String,Object>> rows = (List<Map<String,Object>>) p.get("rows");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.saveExpenseTrx(rows, ym, u, request.getRemoteAddr(), String.valueOf(session.getAttribute("s_comp_cd")))));
			} catch (Exception e) { log.error(" expenseSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/* 비용 내역 저장(2026-09-17) — {ym, itemCd, rows:[{dtlSeq, del, expDt, title, amt, remark, chkYn}]}. 한 항목의 그 달 목록을 통째로 받는다 */
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/mangr/expenseDtlSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> expenseDtlSave(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				if (!isChief(session)) return ResponseEntity.status(403).body("총괄관리자만 비용을 등록할 수 있습니다.");
				String ym = p.get("ym") == null ? "" : String.valueOf(p.get("ym")).trim();
				if (ym.replace("-","").length() != 6) return ResponseEntity.status(400).body("귀속월(YYYY-MM)이 필요합니다.");
				String cd = p.get("itemCd") == null ? "" : String.valueOf(p.get("itemCd")).trim().toUpperCase();
				if (!cd.matches("[A-Z0-9_]{1,20}")) return ResponseEntity.status(400).body("비용 항목 코드가 필요합니다.");
				List<Map<String,Object>> rows = (List<Map<String,Object>>) p.get("rows");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.saveExpenseDtl(rows, ym, cd, u, request.getRemoteAddr(), String.valueOf(session.getAttribute("s_comp_cd")))));
			} catch (Exception e) { log.error(" expenseDtlSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 창고 (2026-09-16 P3 1단계) — 창고 관리(whMng) · 창고별 재고현황(whStock) · 창고 이동 ================= */
		@RequestMapping(value="/prod/whMng.do")
		public String whMng(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/prod/whMng";
		}
		@RequestMapping(value="/prod/whStock.do")
		public String whStock(HttpSession session) {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/prod/whStock";
		}
		/* 창고 목록 — useOnly=Y 면 사용 중인 창고만(전표 셀렉트용). qty = 창고별 현재고 합(창고 관리 표시·사용 끄기 가드) */
		@RequestMapping(value="/prod/whList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> whList(@RequestParam(value="useOnly", required=false) String useOnly, HttpSession session) throws Exception {
			String compCd = session.getAttribute("s_comp_cd") == null ? null : String.valueOf(session.getAttribute("s_comp_cd"));
			Map<String,Object> r = new HashMap<String,Object>();
			r.put("data", svc.selectWhList(compCd, "Y".equalsIgnoreCase(useOnly)));
			r.put("qty", "Y".equalsIgnoreCase(useOnly) ? new HashMap<String,Object>() : svc.selectWhQtyMap(compCd));
			return r;
		}
		@RequestMapping(value="/prod/whSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> whSave(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (!adjLoggedIn(session)) return ResponseEntity.status(401).body(ADJ_LOGIN_MSG);
				String cd = p.get("whCd") == null ? "" : String.valueOf(p.get("whCd")).trim().toUpperCase();
				String nm = p.get("whNm") == null ? "" : String.valueOf(p.get("whNm")).trim();
				if (!cd.matches("[A-Z0-9_]{1,20}")) return ResponseEntity.status(400).body("창고코드는 영문 대문자·숫자·_ 1~20자입니다.");
				if (nm.isEmpty()) return ResponseEntity.status(400).body("창고 이름이 필요합니다.");
				boolean def = "Y".equals(p.get("defaultYn")), use = !"N".equals(p.get("useYn"));
				if (def && !use) return ResponseEntity.status(400).body("기본창고는 사용을 끌 수 없습니다 — 먼저 다른 창고를 기본으로 두세요.");
				int so = 0; try { so = (int) Double.parseDouble(String.valueOf(p.get("sortOrd"))); } catch (Exception e) { so = 0; }
				p.put("whCd", cd); p.put("whNm", nm); p.put("defaultYn", def ? "Y" : "N"); p.put("useYn", use ? "Y" : "N"); p.put("sortOrd", so);
				p.put("compCd", session.getAttribute("s_comp_cd"));
				p.put("regUser", String.valueOf(session.getAttribute("s_user_id"))); p.put("regIp", request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.saveWhMst(p)));
			} catch (Exception e) { log.error(" whSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		/* 품목 × 창고 현재고 — 창고별 재고현황·창고 이동의 재고 확인. wh 도 함께(열 머리) */
		@RequestMapping(value="/prod/whStockList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> whStockList(@ModelAttribute("DTO") egovframework.konet.user.model.StockMstDTO dto, HttpSession session) throws Exception {
			String compCd = session.getAttribute("s_comp_cd") == null ? null : String.valueOf(session.getAttribute("s_comp_cd"));
			dto.setCompCd(compCd);
			Map<String,Object> r = new HashMap<String,Object>();
			r.put("wh", svc.selectWhList(compCd, false));
			r.put("data", svc.selectStockByWh(dto));
			return r;
		}
		@RequestMapping(value="/prod/stockMoveList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockMoveList(@RequestParam(value="fromDt", required=false) String fromDt, @RequestParam(value="toDt", required=false) String toDt, HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("compCd", session.getAttribute("s_comp_cd")); p.put("fromDt", fromDt); p.put("toDt", toDt);
			Map<String,Object> r = new HashMap<String,Object>(); r.put("data", svc.selectStockMoveList(p));
			return r;
		}
		@RequestMapping(value="/prod/stockMoveSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> stockMoveSave(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (!adjLoggedIn(session)) return ResponseEntity.status(401).body(ADJ_LOGIN_MSG);
				String fr = str(p.get("fromWh")).trim(), to = str(p.get("toWh")).trim(), cd = str(p.get("prodCd")).trim();
				long qty = Math.round(Double.parseDouble(String.valueOf(p.get("qty") == null ? "0" : p.get("qty"))));
				if (str(p.get("trxDt")).trim().isEmpty()) return ResponseEntity.status(400).body("이동일자가 필요합니다.");
				if (fr.isEmpty() || to.isEmpty() || fr.equals(to)) return ResponseEntity.status(400).body("보내는 창고와 받는 창고를 다르게 고르세요.");
				if (cd.isEmpty()) return ResponseEntity.status(400).body("품목코드가 필요합니다.");
				if (qty <= 0) return ResponseEntity.status(400).body("수량은 1 이상이어야 합니다.");
				p.put("fromWh", fr); p.put("toWh", to); p.put("prodCd", cd); p.put("qty", qty);
				p.put("compCd", session.getAttribute("s_comp_cd"));
				p.put("regUser", String.valueOf(session.getAttribute("s_user_id"))); p.put("regIp", request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.saveStockMove(p)));
			} catch (Exception e) { log.error(" stockMoveSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/stockMoveCancel.do", method = RequestMethod.POST)
		public ResponseEntity<String> stockMoveCancel(@RequestBody Map<String,Object> p, HttpServletRequest request, HttpSession session) {
			try {
				if (!adjLoggedIn(session)) return ResponseEntity.status(401).body(ADJ_LOGIN_MSG);
				String refNo = str(p.get("refNo")).trim();
				if (!refNo.startsWith("MV")) return ResponseEntity.status(400).body("이동 번호가 아닙니다.");
				p.put("refNo", refNo); p.put("compCd", session.getAttribute("s_comp_cd"));
				p.put("updUser", String.valueOf(session.getAttribute("s_user_id"))); p.put("updIp", request.getRemoteAddr());
				int n = svc.cancelStockMove(p);
				if (n == 0) return ResponseEntity.status(404).body("이미 취소됐거나 없는 이동입니다.");
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" stockMoveCancel ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		/* ================= 택배 「출력됨」 서버 저장 · 출고장 표 (2026-09-16 P3) =================
		   · parcelPrintList/Mark : 택배출고관리가 엑셀에 담은 줄(출고일자×사업장×품목명)을 서버에 남긴다 — PC 를 바꿔도 「출력됨」이 보인다.
		   · dcList : 출고장(삼성 센터) 표(TBL_DC_MST) — asset/js/dc-map.js 가 읽어 다섯 화면의 상수를 갈아 채운다. */
		@RequestMapping(value="/shipout/parcelPrintList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> parcelPrintList(@RequestParam(value="frDt", required=false) String frDt, @RequestParam(value="toDt", required=false) String toDt, HttpSession session) throws Exception {
			String compCd = session.getAttribute("s_comp_cd") == null ? null : String.valueOf(session.getAttribute("s_comp_cd"));
			Map<String,Object> r = new HashMap<String,Object>(); r.put("data", svc.selectParcelPrintList(compCd, frDt, toDt));
			return r;
		}
		@SuppressWarnings("unchecked")
		@RequestMapping(value="/shipout/parcelPrintMark.do", method = RequestMethod.POST)
		public ResponseEntity<String> parcelPrintMark(@RequestBody Map<String,Object> p, HttpSession session) {
			try {
				if (session.getAttribute("s_comp_cd") == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
				List<Map<String,Object>> rows = (List<Map<String,Object>>) p.get("rows");
				String u = session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"";
				return ResponseEntity.ok(String.valueOf(svc.markParcelPrint(rows, u, String.valueOf(session.getAttribute("s_comp_cd")))));
			} catch (Exception e) { log.error(" parcelPrintMark ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/shipout/dcList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> dcList(HttpSession session) throws Exception {
			String compCd = session.getAttribute("s_comp_cd") == null ? null : String.valueOf(session.getAttribute("s_comp_cd"));
			Map<String,Object> r = new HashMap<String,Object>(); r.put("data", svc.selectDcList(compCd));
			return r;
		}

		/* 출고장 → 창고 매핑 저장 (창고 2단계 2026-09-16) — 창고 관리 화면. 빈 창고 = 기본창고 */
		@RequestMapping(value="/shipout/dcWhSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> dcWhSave(@RequestBody Map<String,Object> p, HttpSession session) {
			try {
				if (!adjLoggedIn(session)) return ResponseEntity.status(401).body(ADJ_LOGIN_MSG);
				String dc = str(p.get("dcCd")).trim().toUpperCase(), wh = str(p.get("whCd")).trim().toUpperCase();
				if (dc.isEmpty()) return ResponseEntity.status(400).body("출고장 코드가 필요합니다.");
				p.put("dcCd", dc); p.put("whCd", wh); p.put("compCd", session.getAttribute("s_comp_cd")); p.put("regUser", String.valueOf(session.getAttribute("s_user_id")));
				int n = svc.saveDcWh(p);
				if (n == 0) return ResponseEntity.status(404).body("출고장 " + dc + " 이(가) 표에 없습니다.");
				return ResponseEntity.ok(String.valueOf(n));
			} catch (Exception e) { log.error(" dcWhSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
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
		public Map<String,Object> prodList(@ModelAttribute("DTO") egovframework.konet.user.model.ProdDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectProdList(dto));
			return response;
		}
		/* ===== 삭제한 상품 보기 · 되살리기 (2026-08-17 요청) ================================
		   삭제는 원래부터 소프트 삭제(ACTION_YN='N')라 자료가 남아 있다. 되살리기는 값 하나를
		   'Y' 로 되돌리는 것뿐 — 그래서 복원 표도, 별도 백업도 필요 없다. */
		@RequestMapping(value="/prod/prodDeletedList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> prodDeletedList(@ModelAttribute("DTO") egovframework.konet.user.model.ProdDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			if (session.getAttribute("s_comp_cd") == null) { response.put("data", new java.util.ArrayList<Object>()); return response; }
			response.put("data", svc.selectProdDeletedList(dto));
			return response;
		}
		@RequestMapping(value="/prod/prodRestore.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodRestore(@RequestBody egovframework.konet.user.model.ProdDTO dto,
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
		public ResponseEntity<String> prodStop(@RequestBody egovframework.konet.user.model.ProdDTO dto,
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
		public ResponseEntity<String> prodUnstop(@RequestBody egovframework.konet.user.model.ProdDTO dto,
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
		public ResponseEntity<String> prodInsert(@RequestBody egovframework.konet.user.model.ProdDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdCd()==null || dto.getProdCd().trim().isEmpty()) return ResponseEntity.status(400).body("코드 필요");
				/* ★상품코드 중복 막기 (2026-09-07) — 같은 코드가 마스터에 두 줄이 되면 재고가 갈린다.
				     실측 : 15개 코드가 두 줄(하나는 세 줄)이었고, 1000783958 은 한쪽에 입고·다른 쪽에 출고가
				     붙어 재고가 −140 까지 갔다. 화면에서도 막지만 저장 직전에 여기서 한 번 더 본다
				     (두 사람이 같은 코드를 동시에 넣는 경우는 화면 검사로 못 막는다). */
				java.util.Map<String,Object> dup = svc.countProdCd(dto);
				int alive = dup==null || dup.get("ALIVE")==null ? 0 : Integer.parseInt(String.valueOf(dup.get("ALIVE")));
				int dead  = dup==null || dup.get("DELETED")==null ? 0 : Integer.parseInt(String.valueOf(dup.get("DELETED")));
				if (alive > 0) return ResponseEntity.status(409).body("이미 있는 상품코드입니다 : " + dto.getProdCd().trim() + " — 그 상품을 고쳐 쓰세요.");
				if (dead  > 0) return ResponseEntity.status(409).body("삭제된 상품코드입니다 : " + dto.getProdCd().trim() + " — [♻ 삭제 목록]에서 되살리세요.");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertProd(dto)));
			} catch (Exception e) { log.error(" prodInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/prodUpdate.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodUpdate(@RequestBody egovframework.konet.user.model.ProdDTO dto,
		                                         HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				dto.setUpdUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateProd(dto)));
			} catch (Exception e) { log.error(" prodUpdate ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/prodDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> prodDelete(@RequestBody egovframework.konet.user.model.ProdDTO dto,
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
		public Map<String,Object> xrefList(@ModelAttribute("DTO") egovframework.konet.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectXrefList(dto));
			return response;
		}
		/* 미매핑 목록 — 업로드된 자료 중 우리 품목으로 해석되지 않은 코드(거래처·코드별 집계) */
		@RequestMapping(value="/prod/xrefUnmapped.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefUnmapped(@ModelAttribute("DTO") egovframework.konet.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectUnmappedItems(dto));
			return response;
		}
		/* 후보 추천 — ★품명은 거래처마다 제각각으로 들어오므로 보조 신호일 뿐이다.
		   단가(extPrice)·규격(extSpec)이 있으면 그것이 1순위 근거가 된다. 자동 확정은 없다. */
		@RequestMapping(value="/prod/xrefCandidates.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefCandidates(@ModelAttribute("DTO") egovframework.konet.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
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
		public Map<String,Object> xrefNames(@ModelAttribute("DTO") egovframework.konet.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectXrefNames(dto));
			return response;
		}
		@RequestMapping(value="/prod/xrefAudit.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> xrefAudit(@ModelAttribute("DTO") egovframework.konet.user.model.ProdXrefDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectXrefAudit(dto));
			return response;
		}
		@RequestMapping(value="/prod/xrefSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> xrefSave(@RequestBody egovframework.konet.user.model.ProdXrefDTO dto,
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
		public ResponseEntity<String> xrefConfirm(@RequestBody egovframework.konet.user.model.ProdXrefDTO dto, HttpSession session) {
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
		public ResponseEntity<String> xrefDelete(@RequestBody egovframework.konet.user.model.ProdXrefDTO dto,
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
		public Map<String,Object> extItemList(@ModelAttribute("DTO") egovframework.konet.user.model.ExtItemDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectExtItemList(dto));
			return response;
		}
		/** 정산실적 «납품일자 시점» 매입단가 (2026-09-16 P2-f) — 회사 전체 매입가 이력. 회사코드는 인터셉터가 넣는다. */
		@RequestMapping(value="/prod/inpriceHstAll.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> inpriceHstAll(@ModelAttribute("DTO") egovframework.konet.user.model.ProdInpriceDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectInpriceHstAll(dto));
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
			egovframework.konet.user.model.ProdDTO d = svc.selectProdStopById(p);
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
		/**
		 * ★추가 매칭코드 겹침 안내 (2026-09-13) — selectExtCodeConflict 가 돌려준 줄로 문구를 만든다.
		 * <p>⚠문구에 「추가 매칭코드」 가 반드시 들어가야 한다 — 화면(prodcd)이 그 말로 409 를 갈라 그대로 보여 준다.
		 */
		private static String extConflictMsg(egovframework.konet.user.model.ExtItemDTO d, egovframework.konet.user.model.ExtItemDTO c) {
			String add  = d.getAddItemCd() == null ? "" : d.getAddItemCd().trim();
			String cExt = c.getExtItemCd() == null ? "" : c.getExtItemCd().trim();
			String cAdd = c.getAddItemCd() == null ? "" : c.getAddItemCd().trim();
			String at   = "주코드 " + (c.getProdCd() == null ? "" : c.getProdCd()) + (c.getProdNm() == null ? "" : " " + c.getProdNm());
			/* ★[2026-09-13] selectExtCodeConflict 는 이제 «추가 코드끼리» 겹침만 돌려준다 — 품목코드(매칭코드)와의 겹침은 허용 */
			return "추가 매칭코드 " + (add.isEmpty() ? cAdd : add) + " 는 이미 다른 줄의 추가 매칭코드입니다 — " + at + " (품목코드 " + cExt + ")"
			     + "\n추가 매칭코드끼리는 겹칠 수 없습니다(어느 주코드로 갈지 정할 수 없습니다). 옮기려면 그 줄에서 먼저 지우세요.";
		}
		@RequestMapping(value="/prod/extItemSave.do", method = RequestMethod.POST)
		public ResponseEntity<String> extItemSave(@RequestBody egovframework.konet.user.model.ExtItemDTO dto,
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
				/* ★추가 매칭코드(2026-09-13) — 비우면 NULL. 품목코드·주코드 자신과 같으면 뜻이 없다.
				   한 코드는 표 전체에서 한 곳에만(겹치면 어느 주코드로 갈지 정할 수 없다) — 화면도 막지만 마지막 문은 여기다. */
				String add = dto.getAddItemCd() == null ? "" : dto.getAddItemCd().trim();
				dto.setAddItemCd(add.isEmpty() ? null : add);
				if (!add.isEmpty() && add.equalsIgnoreCase(dto.getExtItemCd().trim()))
					return ResponseEntity.status(409).body("추가 매칭코드가 품목코드와 같습니다 — " + add);
				if (!add.isEmpty() && dto.getProdCd() != null && add.equalsIgnoreCase(dto.getProdCd().trim()))
					return ResponseEntity.status(409).body("추가 매칭코드가 주코드 자신입니다 — " + add);
				egovframework.konet.user.model.ExtItemDTO cf = svc.selectExtCodeConflict(dto);
				if (cf != null) return ResponseEntity.status(409).body(extConflictMsg(dto, cf));
				if (dto.getExtSeq() == null) {
					dto.setRegUser(u); dto.setRegIp(request.getRemoteAddr());
					return ResponseEntity.ok(String.valueOf(svc.insertExtItem(dto)));
				}
				dto.setUpdUser(u); dto.setUpdIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.updateExtItem(dto)));
			} catch (Exception e) { log.error(" extItemSave ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/extItemDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> extItemDelete(@RequestBody egovframework.konet.user.model.ExtItemDTO dto,
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
		public ResponseEntity<String> extItemBulk(@RequestBody java.util.List<egovframework.konet.user.model.ExtItemDTO> list,
		                                          HttpServletRequest request, HttpSession session) {
			try {
				if (list == null || list.isEmpty()) return ResponseEntity.status(400).body("등록할 자료가 없습니다");
				/* ★거래중지 가드는 여기도 같이(2026-08-19) — 한 줄이라도 중지된 상품이면 묶음 전체를 되돌린다.
				   ⚠같은 PROD_SEQ 를 줄마다 묻지 않는다 — 중복을 걸러 한 번씩만 본다. */
				java.util.LinkedHashSet<Long> seqs = new java.util.LinkedHashSet<Long>();
				for (egovframework.konet.user.model.ExtItemDTO d : list) if (d != null && d.getProdSeq() != null) seqs.add(d.getProdSeq());
				for (Long sq : seqs) {
					String blk = extStopBlockMsg(sq, session);
					if (blk != null) return ResponseEntity.status(403).body(blk);
				}
				String u = session.getAttribute("s_user_id") != null ? String.valueOf(session.getAttribute("s_user_id")) : "";
				for (egovframework.konet.user.model.ExtItemDTO d : list) { d.setRegUser(u); d.setRegIp(request.getRemoteAddr()); }
				return ResponseEntity.ok(String.valueOf(svc.mergeExtItems(list)));
			} catch (Exception e) { log.error(" extItemBulk ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}

		@RequestMapping(value="/prod/inpriceList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> inpriceList(@ModelAttribute("DTO") egovframework.konet.user.model.ProdInpriceDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectInpriceList(dto));
			return response;
		}
		@RequestMapping(value="/prod/inpriceInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> inpriceInsert(@RequestBody egovframework.konet.user.model.ProdInpriceDTO dto,
		                                            HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				if (dto.getInPrice()==null) return ResponseEntity.status(400).body("매입단가 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertInprice(dto)));
			} catch (Exception e) { log.error(" inpriceInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/inpriceDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> inpriceDelete(@RequestBody egovframework.konet.user.model.ProdInpriceDTO dto,
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
		public Map<String,Object> salepriceList(@ModelAttribute("DTO") egovframework.konet.user.model.ProdSalepriceDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectSalepriceList(dto));
			return response;
		}
		@RequestMapping(value="/prod/salepriceInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> salepriceInsert(@RequestBody egovframework.konet.user.model.ProdSalepriceDTO dto,
		                                              HttpServletRequest request, HttpSession session) {
			try {
				if (dto.getProdSeq()==null) return ResponseEntity.status(400).body("PROD_SEQ 필요");
				if (dto.getSalePrice()==null) return ResponseEntity.status(400).body("판매단가 필요");
				dto.setRegUser((session.getAttribute("s_user_id")!=null?String.valueOf(session.getAttribute("s_user_id")):"")); dto.setRegIp(request.getRemoteAddr());
				return ResponseEntity.ok(String.valueOf(svc.insertSaleprice(dto)));
			} catch (Exception e) { log.error(" salepriceInsert ERROR : " + e.getMessage()); return ResponseEntity.status(500).body(e.getMessage()); }
		}
		@RequestMapping(value="/prod/salepriceDelete.do", method = RequestMethod.POST)
		public ResponseEntity<String> salepriceDelete(@RequestBody egovframework.konet.user.model.ProdSalepriceDTO dto,
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
		public Map<String,Object> stockList(@ModelAttribute("DTO") egovframework.konet.user.model.StockLedgerDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data",  svc.selectStockLedgerList(dto));   // 수불 이력
			response.put("stock", svc.selectStockMst(dto));          // 현재고 현황
			return response;
		}

		/* 재고현황 — 전체 품목 현재고(TBL_STOCK_MST) 목록 */
		@RequestMapping(value="/prod/stockStatusList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockStatusList(@ModelAttribute("DTO") egovframework.konet.user.model.StockMstDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectStockMstList(dto));
			return response;
		}
		/* 출고현황표(대시보드) 전용 — 코드별 재고만. extQtys 를 안 만들어 664ms→29ms (2026-08-07 실측) */
		@RequestMapping(value="/prod/stockQtyMap.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockQtyMap(@ModelAttribute("DTO") egovframework.konet.user.model.StockMstDTO dto, HttpSession session) throws Exception {
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
			egovframework.konet.cmmn.RebuildProgress.P p = egovframework.konet.cmmn.RebuildProgress.get(u);
			Map<String,Object> res = new HashMap<String,Object>();
			res.put("running", p != null);
			if (p != null) { res.put("phase", p.phase); res.put("done", p.done); res.put("total", p.total); }
			return res;
		}

		/* 입고내역 — 전체 입고(수불 IO_GB='I') 거래 목록 */
		@RequestMapping(value="/prod/inboundList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> inboundList(@ModelAttribute("DTO") egovframework.konet.user.model.StockLedgerDTO dto, HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			response.put("data", svc.selectInboundList(dto));
			return response;
		}
		@RequestMapping(value="/prod/stockInsert.do", method = RequestMethod.POST)
		public ResponseEntity<String> stockInsert(@RequestBody egovframework.konet.user.model.StockLedgerDTO dto,
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
		public ResponseEntity<String> stockDelete(@RequestBody egovframework.konet.user.model.StockLedgerDTO dto,
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
		public Map<String,Object> stockAdjList(@ModelAttribute("DTO") egovframework.konet.user.model.StockMstDTO dto,
		                                       HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			dto.setCompCd((String) session.getAttribute("s_comp_cd"));
			response.put("data", svc.selectStockAdjList(dto));
			return response;
		}

		/* 일괄저장 — 고친 줄만 조정행 + 이력으로 남긴다 */
		/* ★재고조정 저장·되돌리기·서브코드 정리는 <로그인이 살아 있을 때만> (2026-09-14) —
		   화면을 켜 둔 채 서버가 다시 올라오면(세션 소실) 종전엔 «등록자 없음 · 기본 회사(W1234567)» 로 조용히 들어갔다
		   (실측 : 조정 이력 110건 중 31건 등록자 빈 값 · 2026-09-07·09-14 서버 재기동 시각대). 재고조정은 «누가 고쳤나»가 남아야 한다
		   (모바일 재고조정 내역 — 대표 확인용). 화면 셋(stockAdj·prodcd·subStockFix)은 result≠OK 면 message 를 그대로 띄운다. */
		private static final String ADJ_LOGIN_MSG = "로그인이 끊겼습니다 — 다시 로그인한 뒤 해 주세요. (재고는 바뀌지 않았습니다)";
		private static boolean adjLoggedIn(HttpSession s) {
			return s.getAttribute("s_user_id") != null && s.getAttribute("s_comp_cd") != null;
		}

		@RequestMapping(value="/prod/stockAdjSave.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockAdjSave(@RequestBody Map<String,Object> body,
		                                       HttpSession session, HttpServletRequest request) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			if (!adjLoggedIn(session)) { response.put("result", "FAIL"); response.put("login", Boolean.TRUE); response.put("message", ADJ_LOGIN_MSG); return response; }
			try {
				egovframework.konet.user.model.StockAdjHisDTO head =
				        new egovframework.konet.user.model.StockAdjHisDTO();
				head.setCompCd((String) session.getAttribute("s_comp_cd"));
				head.setBaseDt(str(body.get("baseDt")));
				head.setRemark(str(body.get("remark")));
				head.setWhCd(str(body.get("whCd")));            // 조정 창고(2026-09-16 P3) — 비면 기본창고
				head.setRegUser((String) session.getAttribute("s_user_id"));
				head.setRegIp(request.getRemoteAddr());

				java.util.List<egovframework.konet.user.model.StockAdjHisDTO> rows =
				        new java.util.ArrayList<egovframework.konet.user.model.StockAdjHisDTO>();

				Object raw = body.get("rows");
				if (raw instanceof java.util.List) {
					for (Object o : (java.util.List<?>) raw) {
						if (!(o instanceof Map)) continue;
						Map<?,?> m = (Map<?,?>) o;
						egovframework.konet.user.model.StockAdjHisDTO r =
						        new egovframework.konet.user.model.StockAdjHisDTO();
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

				/* ★★서브코드로는 재고조정을 할 수 없다 (2026-09-10) — 매입(purchaseSave)과 <같은 관문>이다.
				   서브코드(거래처 매칭코드)는 «남의 코드»일 뿐 **재고의 주인이 아니다.**
				   그 코드로 조정하면 같은 물건의 재고가 주코드와 서브코드로 갈라진다 :
				     실측 2026-09-10 14:15 — 조정 +157 이 서브코드 1000791735 로 들어가고
				     주코드 9904013072 는 −145 그대로였다(조정한 사람은 고쳤다고 믿는다).
				   ⚠**[출고반영 재집계]로도 안 고쳐진다** — 그 버튼은 출고 원천(발주현황표·정산서)만 다시 만든다.
				   ★막는 곳이 여기(서버)여야 한다 — 담기는 길이 늘 때마다 화면 가드는 새기 때문.
				   ★바꿔 주지는 않는다(매입과 다른 점) — 조정은 «그 줄의 앞수량/뒷수량»이 짝이라
				     코드만 옮기면 주코드의 현재고와 어긋난다. 주코드 줄에서 다시 입력하는 것이 옳다. */
				java.util.LinkedHashSet<String> adjCds = new java.util.LinkedHashSet<String>();
				for (egovframework.konet.user.model.StockAdjHisDTO r : rows)
					if (r.getProdCd() != null && !r.getProdCd().trim().isEmpty()) adjCds.add(r.getProdCd().trim());
				if (!adjCds.isEmpty()) {
					Map<String,Object> sp = new HashMap<String,Object>();
					sp.put("codes", new java.util.ArrayList<String>(adjCds));
					sp.put("compCd", session.getAttribute("s_comp_cd"));
					java.util.List<egovframework.konet.user.model.ExtItemDTO> subs = svc.selectSubCodesAmong(sp);
					if (subs != null && !subs.isEmpty()) {
						StringBuilder sb = new StringBuilder();
						for (egovframework.konet.user.model.ExtItemDTO s : subs) {
							if (sb.length() > 0) sb.append(" / ");
							sb.append(poStr(s.getExtItemCd())).append("(서브) → 주코드 ").append(poStr(s.getProdCd()));
						}
						response.put("result", "SUBCODE");
						response.put("subs", subs);
						response.put("message", "서브코드로는 재고조정을 할 수 없습니다 — " + sb
						        + " . 주코드 줄에서 조정하세요(서브코드로 넣으면 재고가 두 코드로 갈라집니다).");
						return response;
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

		/* ══ 서브코드 재고 정리 (2026-09-13) — 화면 prod/subStockFix.jsp ══════════════════════════════
		   ①재고가 남은 서브코드 ②서브코드로 잡힌 매입 줄(→ 매입등록으로 보냄) ③남은 재고 0 으로 조정.
		   ★③은 stockAdjSave 의 「서브코드로는 조정 불가」 관문의 <예외 길>이다 — 서브코드를 0 으로 비우는 것이 목적이라서.
		     주코드·수량은 서버가 원장으로 다시 센다(화면 값 무시). */
		@RequestMapping(value="/prod/subStockFix.do")
		public String subStockFix(HttpSession session, ModelMap model) throws Exception {
			if (session.getAttribute("s_comp_cd") == null) return ".login/base_login";
			return ".raw/main/prod/subStockFix";   // 아이프레임 전용
		}
		@RequestMapping(value="/prod/subStockList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> subStockList(HttpSession session) throws Exception {
			Map<String,Object> p = new HashMap<String,Object>();
			p.put("compCd", session.getAttribute("s_comp_cd"));   // Map 이라 직접 넣는다
			p.put("subCd", null);
			return svc.selectSubStock(p);
		}
		@RequestMapping(value="/prod/subStockZero.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> subStockZero(@RequestBody Map<String,Object> body,
		                                       HttpSession session, HttpServletRequest request) {
			Map<String,Object> response = new HashMap<String,Object>();
			try {
				String comp = (String) session.getAttribute("s_comp_cd");
				if (!adjLoggedIn(session)) { response.put("result", "FAIL"); response.put("login", Boolean.TRUE); response.put("message", ADJ_LOGIN_MSG); return response; }
				java.util.List<String> cds = new java.util.ArrayList<String>();
				Object raw = body.get("subCds");
				if (raw instanceof java.util.List)
					for (Object o : (java.util.List<?>) raw) { String s = str(o); if (s != null && !s.isEmpty()) cds.add(s); }
				if (cds.isEmpty()) { response.put("result", "FAIL"); response.put("message", "고른 서브코드가 없습니다."); return response; }
				String m = str(body.get("merge"));
				boolean merge = !("false".equalsIgnoreCase(m) || "N".equalsIgnoreCase(m));   // 기본 = 합침
				Map<String,Object> r = svc.saveSubStockZero(cds, merge, comp,
				        (String) session.getAttribute("s_user_id"), request.getRemoteAddr());
				response.putAll(r);
				response.put("result", "OK");
			} catch (Exception e) {
				response.put("result", "FAIL");
				response.put("message", e.getMessage());
			}
			return response;
		}

		/* 조정 이력 */
		@RequestMapping(value="/prod/stockAdjHisList.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockAdjHisList(@ModelAttribute("DTO") egovframework.konet.user.model.StockAdjHisDTO dto,
		                                          HttpSession session) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			dto.setCompCd((String) session.getAttribute("s_comp_cd"));
			response.put("data", svc.selectStockAdjHisList(dto));
			return response;
		}

		/* 묶음 되돌리기 */
		@RequestMapping(value="/prod/stockAdjCancel.do", method = RequestMethod.POST)
		@ResponseBody
		public Map<String,Object> stockAdjCancel(@ModelAttribute("DTO") egovframework.konet.user.model.StockAdjHisDTO dto,
		                                         HttpSession session, HttpServletRequest request) throws Exception {
			Map<String,Object> response = new HashMap<String,Object>();
			if (!adjLoggedIn(session)) { response.put("result", "FAIL"); response.put("login", Boolean.TRUE); response.put("message", ADJ_LOGIN_MSG); return response; }
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

				java.util.List<egovframework.konet.user.model.StockMstDTO> rows =
				        new java.util.ArrayList<egovframework.konet.user.model.StockMstDTO>();

				Object raw = body.get("rows");
				if (raw instanceof java.util.List) {
					for (Object o : (java.util.List<?>) raw) {
						if (!(o instanceof Map)) continue;
						Map<?,?> m = (Map<?,?>) o;
						egovframework.konet.user.model.StockMstDTO r =
						        new egovframework.konet.user.model.StockMstDTO();
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
