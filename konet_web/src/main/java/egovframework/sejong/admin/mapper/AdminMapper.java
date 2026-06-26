package egovframework.sejong.admin.mapper;
import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.admin.model.PatientDTO;
import egovframework.sejong.admin.model.AsqDTO;
import egovframework.sejong.admin.model.AuserDTO;
import egovframework.sejong.admin.model.FaqDTO;

@Mapper("AdminMapper")
public interface AdminMapper {
	//환자
	List<?> selectPatientList(PatientDTO dto) throws Exception;
	PatientDTO patientInfo(PatientDTO dto) throws Exception;
	boolean insertPatient(PatientDTO dto) throws Exception;
	boolean updatePatient(PatientDTO dto) throws Exception;
	boolean deletePatient(PatientDTO dto) throws Exception;

	// 환자 로그인 (T_USER_TRAN)
	PatientDTO patientLoginCheck(PatientDTO dto) throws Exception;
	// 환자 회원가입 (T_USER_TRAN INSERT, USER_GB='P')
	boolean patientRegister(PatientDTO dto) throws Exception;
	// 전화번호/이메일 중복 체크
	int patientExistsByPhone(PatientDTO dto) throws Exception;
	
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
