package egovframework.sejong.admin.service;

import java.util.List;

import egovframework.sejong.admin.model.AsqDTO;
import egovframework.sejong.admin.model.FaqDTO;
public interface AdminService {

	//Foa
	List<?>   selectfaqList(FaqDTO dto)   throws Exception;
	FaqDTO    faqInfo(FaqDTO dto)         throws Exception;
	boolean   insertfaq(FaqDTO dto)       throws Exception; 
	boolean   updatefaq(FaqDTO dto)       throws Exception; 
	boolean   deletefaq(FaqDTO dto)       throws Exception;
	
	List<?>   selectasqList(AsqDTO dto)   throws Exception;
	List<?>   selectMyAsqList(AsqDTO dto) throws Exception;   // 환자 본인 1:1 문의 목록
	AsqDTO    asqInfo(AsqDTO dto)         throws Exception;
	boolean   insertasq(AsqDTO dto)       throws Exception;
	boolean   updateasq(AsqDTO dto)       throws Exception;
	boolean   deleteasq(AsqDTO dto)       throws Exception;
}