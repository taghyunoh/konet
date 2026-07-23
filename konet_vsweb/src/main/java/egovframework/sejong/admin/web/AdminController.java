package egovframework.sejong.admin.web;

import java.net.URLEncoder;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor.HSSFColorPredefined;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.w3c.dom.ls.LSInput;

import egovframework.sejong.admin.service.AdminService;
import egovframework.sejong.admin.service.CommService;
import egovframework.sejong.admin.model.AsqDTO;
import egovframework.sejong.admin.model.FaqDTO;
import egovframework.sejong.admin.model.CommDTO;
import egovframework.util.EgovFileScrty;

@Controller
public class AdminController {
	private static final Logger log = LoggerFactory.getLogger(AdminController.class);
	
	@Resource(name = "AdminService") // 서비스 선언
	private AdminService svc;
	@Resource(name = "CommService") // 서비스 선언
	private CommService codesvc;	
//	공지사항
// 공지사항화면
	@RequestMapping(value = "/admin/admin_noticeList.do")
	public String noticeList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/admin/admin_noticeList";

	}  
	// 환자정보관리 
    @RequestMapping(value = "/admin/admin_ptList.do")
	public String ptList(HttpServletRequest request, Model model) throws Exception {
		try {
			// 메인 최초 진입 자동 로드(handleMenuClick)가 1회만 동작하도록 admingu 제거 (의사 ptList 와 동일)
			request.getSession().removeAttribute("admingu");

			CommDTO cvo = new CommDTO();
			cvo.setCode("CD7");
			cvo.setUseYn("Y");

			List <?> resultLst = codesvc.selectCommDetailList(cvo);
			model.addAttribute("cdtpList", resultLst);

		}catch(Exception ex) {
			model.addAttribute("error_code", "10000");
		}
		return ".main/admin/admin_ptList";

	}
  
	// 관리자의사 
    @RequestMapping(value = "/admin/admin_auserList.do")
	public String AuserList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
		return ".main/admin/admin_auserList";

	}  	
	@RequestMapping(value = "/admin/admin_faqList.do")
	public String faqList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
	    return ".main/admin/admin_faqList";
	}  
	@RequestMapping(value="/admin/faqList.do", method = RequestMethod.POST)
	public String selectfaqList(@ModelAttribute("DTO") FaqDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selectfaqList(dto);
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" FaqListAct ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value = "/admin/faqInfo.do", method = RequestMethod.POST)
	public String faqInfo(@ModelAttribute("DTO") FaqDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			FaqDTO result = svc.faqInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" FaqInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 
	@RequestMapping(value="/admin/faqSaveProc.do")
	public String faqSaveProc(@ModelAttribute("VO") FaqDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud() ; //입력,수정, 삭제 구분
			System.out.println(iud);
			if("I".equals(iud)) {
				dto.setUseYn("Y");
				svc.insertfaq(dto);
			}else if("U".equals(iud)) {
				dto.setUseYn("Y");
				svc.updatefaq(dto);
			}else if("D".equals(iud)) {
				dto.setUseYn("N");
				svc.deletefaq(dto);
		 
			}

			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" FaqAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	@RequestMapping(value = "/admin/admin_asqList.do")
	public String asqList(Model model) throws Exception {
		try { 
		}catch(Exception ex) {
			model.addAttribute("error_code", "10000"); 
		}
	    return ".main/admin/admin_asqList";
	}  
	@RequestMapping(value="/admin/asqList.do", method = RequestMethod.POST)
	public String selectasqList(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, Model model) throws Exception {
	try {
		List<?> result = svc.selectasqList(dto);
		model.addAttribute("resultLst", result); 
		model.addAttribute("resultCnt", result.size());  
		model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" FaqListAct ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	}
	@RequestMapping(value = "/admin/asqInfo.do", method = RequestMethod.POST)
	public String asqInfo(@ModelAttribute("DTO") AsqDTO dto, HttpServletRequest request, Model model) throws Exception {
		try {
			AsqDTO result = svc.asqInfo(dto);
	 
			model.addAttribute("result", result); 
			model.addAttribute("error_code", "0"); 
		
	}catch(Exception ex) {
		log.error(" asqInfo ERROR ! : "+ ex.getMessage());
		model.addAttribute("error_code", "10000"); 
		}
		return "jsonView";
	} 
	@RequestMapping(value="/admin/asqSaveProc.do")
	public String asqSaveProc(@ModelAttribute("VO") AsqDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud() ; //입력,수정, 삭제 구분
			System.out.println(iud);
            if("U".equals(iud)) { 
				dto.setAnsrYn("Y");
				svc.updateasq(dto);
			}

			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" FaqAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000");

		}
		//
		return "jsonView";
	}

	// ══════════════════════════════════════════════
	//  물류관리 (입고/재고/발주/출고) — 화면(사이드바) 구성만, 테이블/로직 추후
	//  · 좌측 사이드바 + 우측 콘텐츠 단일 셸. 세부화면은 logistics.jsp 내 패널 전환
	// ══════════════════════════════════════════════
	@RequestMapping(value = "/admin/logistics.do")
	public String logistics(Model model) throws Exception {
		try {
		} catch (Exception ex) {
			model.addAttribute("error_code", "10000");
		}
		return ".main/admin/logistics";
	}

	// ══════════════════════════════════════════════
	//  환자 본인 1:1 문의 (질의응답) — sejong_app ASQ 참조
	//  · 보안: 사용자 식별은 항상 세션 userUuid 사용(클라이언트 값 무시)
	// ══════════════════════════════════════════════
	@RequestMapping(value = "/patient/myAsqList.do", method = RequestMethod.POST)
	public String myAsqList(HttpSession session, Model model) throws Exception {
		try {
			Object uuid = session.getAttribute("userUuid");
			AsqDTO dto = new AsqDTO();
			dto.setUserUuid(uuid == null ? "" : uuid.toString());
			List<?> result = svc.selectMyAsqList(dto);
			model.addAttribute("resultLst", result);
			model.addAttribute("resultCnt", result.size());
			model.addAttribute("error_code", "0");
		} catch (Exception ex) {
			log.error(" myAsqList ERROR ! : " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
	}

	@RequestMapping(value = "/patient/myAsqSave.do", method = RequestMethod.POST)
	public String myAsqSave(@ModelAttribute("DTO") AsqDTO dto, HttpSession session, Model model) throws Exception {
		try {
			Object uuid = session.getAttribute("userUuid");
			dto.setUserUuid(uuid == null ? "" : uuid.toString());
			// 제목 미입력 시 본문 앞부분으로 자동 생성(QSTN_TITL NOT NULL 대비)
			if (dto.getQstnTitl() == null || dto.getQstnTitl().trim().isEmpty()) {
				String c = dto.getQstnConts() == null ? "" : dto.getQstnConts().trim();
				dto.setQstnTitl(c.length() > 50 ? c.substring(0, 50) : c);
			}
			svc.insertasq(dto);
			model.addAttribute("error_code", "0");
		} catch (Exception ex) {
			log.error(" myAsqSave ERROR ! : " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
	}

	@RequestMapping(value = "/patient/myAsqDelete.do", method = RequestMethod.POST)
	public String myAsqDelete(@ModelAttribute("DTO") AsqDTO dto, HttpSession session, Model model) throws Exception {
		try {
			Object uuid = session.getAttribute("userUuid");
			dto.setUserUuid(uuid == null ? "" : uuid.toString());
			svc.deleteasq(dto);   // 세션 userUuid + asqSeq 조건 → 본인 글만 삭제
			model.addAttribute("error_code", "0");
		} catch (Exception ex) {
			log.error(" myAsqDelete ERROR ! : " + ex.getMessage());
			model.addAttribute("error_code", "10000");
		}
		return "jsonView";
	}
}
