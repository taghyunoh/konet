package egovframework.sejong.user.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.user.model.CompConDTO;
import egovframework.sejong.user.model.CompMdDTO;
import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;


@Mapper("UserMapper")
public interface UserMapper {

	// ===== 회사/계약/사용자 관리 (compcd.jsp) =====
	List<CompMdDTO> selCompCdList(CompMdDTO dto) throws Exception;
	String CompCdMstDupChk(CompMdDTO dto) throws Exception;
	int insertCompCdMst(CompMdDTO dto) throws Exception;
	int updateCompCdMst(CompMdDTO dto) throws Exception;

	List<CompConDTO> selectCompContList(CompConDTO dto) throws Exception;
	List<CompConDTO> getCompContList(CompConDTO dto) throws Exception;
	String CompContDupChk(CompConDTO dto) throws Exception;
	int insertCompCont(CompConDTO dto) throws Exception;
	int updateCompCont(CompConDTO dto) throws Exception;

	List<java.util.Map<String,Object>> selectCommCodeList(java.util.Map<String,Object> param) throws Exception;

	// ===== 출고장(발주현황표) 업로드 저장 (TBL_SHIPOUT_MST) =====
	int markShipoutHistory(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	int getShipoutNextJobSeq(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	int insertShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutMst(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;
	java.util.List<egovframework.sejong.user.model.ShipoutDTO> selectShipoutPrev(egovframework.sejong.user.model.ShipoutDTO dto) throws Exception;

	// ===== 사업장 분류 마스터 (TBL_BIZI_MST) =====
	java.util.List<egovframework.sejong.user.model.BiziDTO> selectBiziMst() throws Exception;
	int insertBiziIfAbsent(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int updateBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception;
	int deleteBiziMst(egovframework.sejong.user.model.BiziDTO dto) throws Exception;

	// ===== 공통코드 관리 (codecd.jsp) =====
	List<egovframework.sejong.user.model.CodeMdDTO> codeMstList(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	String codeMstDupChk(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int insertCodeMst(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int updateCodeMst(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	List<egovframework.sejong.user.model.CodeMdDTO> codeDtlList(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	String codeDtlDupChk(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int insertCodeDtl(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;
	int updateCodeDtl(egovframework.sejong.user.model.CodeMdDTO dto) throws Exception;

	List<UserDTO> compUserList(UserDTO dto) throws Exception;
	int insertCompUser(UserDTO dto) throws Exception;
	int updateCompUser(UserDTO dto) throws Exception;
	String CompUserDupChk(UserDTO dto) throws Exception;
	String CompUseridDupChk(UserDTO dto) throws Exception;

	UserDTO userLoginCheck(UserDTO dto) throws Exception;

	/** KOLGSDB 로그인: COMP_CD + USER_ID 로 최신 활성 사용자 1건 조회 */
	UserDTO compLoginCheck(UserDTO dto) throws Exception;

	/** KOLGSDB 비밀번호 변경/초기화용 현재 정보 조회 */
	UserDTO compUserInfo(UserDTO dto) throws Exception;

	/** KOLGSDB 비밀번호 갱신 (변경/초기화 공용) */
	int compPwdUpdate(UserDTO dto) throws Exception;

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
