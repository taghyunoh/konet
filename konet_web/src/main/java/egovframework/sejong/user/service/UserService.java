package egovframework.sejong.user.service;

import java.util.List;
import java.util.Map;

import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;

public interface UserService {
	UserDTO userLoginCheck(UserDTO dto) throws Exception;

	UserDTO userInfo(UserDTO dto) throws Exception;

	boolean userPwdReset(UserDTO dto) throws Exception;

	boolean userPwdChange(UserDTO dto) throws Exception;

	/** 약관 본문 조회 (T_SIGN_MST) */
	List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception;

	/** termsGb 의 가장 최신 USE_YN='Y' termsSeq */
	String selectLatestTermsSeq(String termsGb) throws Exception;

	/** 동의이력 1건 저장 (T_PERSIGN_TRAN) */
	int insertPersign(PersignDTO dto) throws Exception;

	/**
	 * 가입 시 termsGb 1/2/3 에 대해 각각 최신 termsSeq 를 lookup 하여 T_PERSIGN_TRAN 에 INSERT.
	 * @param userUuid 가입 직후 생성된 사용자 UUID
	 * @param regId    감사 ID (보통 userUuid 또는 시스템)
	 * @return 실제 INSERT 된 row 수 (정상이면 3)
	 */
	int saveAllPatientAgreements(String userUuid, String regId) throws Exception;
}