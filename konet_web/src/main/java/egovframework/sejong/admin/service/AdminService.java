package egovframework.sejong.admin.service;

import java.util.List;

import egovframework.sejong.admin.model.AsqDTO;
import egovframework.sejong.admin.model.AuserDTO;
import egovframework.sejong.admin.model.PatientDTO;
import egovframework.sejong.admin.model.FaqDTO;
public interface AdminService {
	//공지
	
	//환자
	List<?> selectPatientList(PatientDTO dto) throws Exception;
	
	PatientDTO patientInfo(PatientDTO dto) throws Exception;
	boolean insertPatient(PatientDTO dto) throws Exception;
	boolean updatePatient(PatientDTO dto) throws Exception;
	boolean deletePatient(PatientDTO dto) throws Exception;

	// 환자 로그인/가입 (T_USER_TRAN)
	PatientDTO patientLoginCheck(PatientDTO dto) throws Exception;
	boolean    patientRegister(PatientDTO dto) throws Exception;
	int        patientExistsByPhone(PatientDTO dto) throws Exception;
		
	//관리자(의사)
	List<?> selectAuserList(AuserDTO dto) throws Exception;
	AuserDTO auserInfo(AuserDTO dto) throws Exception;
	boolean insertAuser(AuserDTO dto) throws Exception; 
	boolean updateAuser(AuserDTO dto) throws Exception; 
	boolean deleteAuser(AuserDTO dto) throws Exception;
	
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