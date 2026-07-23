package egovframework.sejong.admin.web;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.sejong.admin.service.CommService;
import egovframework.sejong.admin.model.CommDTO;;


@Controller
public class CommController {
	private static final Logger log = LoggerFactory.getLogger(CommController.class);
	@Resource(name = "CommService") // 서비스 선언
	private CommService svc;
	
	/* 사용자 공통관리 */
	@RequestMapping(value="/admin/admin_commList.do")
	public String CommMgr(@ModelAttribute("DTO") CommDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  

		return ".main/admin/admin_commList";
	}		
	@RequestMapping(value="/admin/selectCommMstList.do")
	public String selectCommMstList(@ModelAttribute("VO") CommDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			//사용자 현황 조회 
			List <?> result = svc.selectCommMstList(dto);
 
			model.addAttribute("resultLst", result); 
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CommMstAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	@RequestMapping(value="/admin/CommSaveProc.do")
	public String CommSaveProc(@ModelAttribute("VO") CommDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			
			String iud = dto.getIud();  //입력,수정, 삭제 구분
			if("MI".equals(iud)) {
				dto.setUseYn("Y");
				svc.insertCommMst(dto);
			}else if("MU".equals(iud)) {
				dto.setUseYn("Y");
				svc.updateCommMst(dto);
			}else if("MD".equals(iud)) {
				dto.setUseYn("N");
				svc.deleteCommMst(dto);

			}else if("DI".equals(iud)) {
				dto.setUseYn("Y");
				svc.insertCommDetail(dto);
			}else if("DU".equals(iud)) {
				dto.setUseYn("Y");
				svc.updateCommDetail(dto);
			}else if("DD".equals(iud)) {
				dto.setUseYn("N");
				svc.deleteCommDetail(dto);
				 
			}
			
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CommMstAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	@RequestMapping(value="/admin/CommMstDupChk.do")
	public String CommMstDupChk(@ModelAttribute("VO") CommDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			//사용자 현황 조회 
			String dupchk = svc.selectCommMstDupChk(dto);
			System.out.println("dupchk " + dupchk);
			model.addAttribute("dupchk", dupchk);  

			model.addAttribute("error_code", "0"); 
		}catch(Exception ex) {
			log.error(" CommListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}	
	@RequestMapping(value="/admin/CommDetailDupChk.do")
	public String CommDetailDupChk(@ModelAttribute("VO") CommDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			//사용자 현황 조회 
			String dupchk = svc.selectCommDetailDupChk(dto);

			System.out.println("dupchk " + dupchk);
			model.addAttribute("dupchk", dupchk);  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CommListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
	@RequestMapping(value="/admin/selectCommDetailList.do")
	public String selectCommDetailList(@ModelAttribute("VO") CommDTO dto, HttpServletRequest request, ModelMap model)
			throws Exception {  
		
		try {
			//사용자 현황 조회 
			List <?> result = svc.selectCommDetailList(dto);
 
			model.addAttribute("resultLst", result);  
			model.addAttribute("resultCnt", result.size());  
			model.addAttribute("error_code", "0"); 
			
		}catch(Exception ex) {
			log.error(" CommListAct ERROR ! : "+ ex.getMessage());
			model.addAttribute("error_code", "10000"); 
						
		}
		//
		return "jsonView";
	}
		
}
