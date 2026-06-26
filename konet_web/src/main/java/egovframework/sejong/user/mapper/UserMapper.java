package egovframework.sejong.user.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;


@Mapper("UserMapper")
public interface UserMapper {

	UserDTO userLoginCheck(UserDTO dto) throws Exception;

	UserDTO userInfo(UserDTO dto) throws Exception;

	boolean userPwdReset(UserDTO dto) throws Exception;

	boolean userPwdChange(UserDTO dto) throws Exception;

	/** 약관 본문 조회 (T_SIGN_MST) — termsGb 별 */
	List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception;

	/** termsGb 의 가장 최신(MAX TERMS_SEQ) USE_YN='Y' 약관 SEQ — 동의이력 INSERT 시 어느 버전에 동의했는지 기록용 */
	String selectLatestTermsSeq(String termsGb) throws Exception;

	/** 동의이력 INSERT (T_PERSIGN_TRAN) — 회원가입 시 termsGb 1/2/3 각 1건씩 호출 */
	int insertPersign(PersignDTO dto) throws Exception;
}
