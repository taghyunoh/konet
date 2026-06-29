package egovframework.sejong.user.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.sejong.user.mapper.UserMapper;
import egovframework.sejong.user.model.CompConDTO;
import egovframework.sejong.user.model.CompMdDTO;
import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;
import egovframework.sejong.user.service.UserService;


@Service("UserService")
public class UserServiceImpl implements UserService {

	private static final Logger LOGGER = LoggerFactory.getLogger(UserServiceImpl.class);

	@Autowired
	private UserMapper mapper;

	@Override
	public UserDTO userLoginCheck(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userLoginCheck(dto);
	}

	@Override
	public UserDTO compLoginCheck(UserDTO dto) throws Exception {
		return mapper.compLoginCheck(dto);
	}

	@Override
	public UserDTO compUserInfo(UserDTO dto) throws Exception {
		return mapper.compUserInfo(dto);
	}

	@Override
	public int compPwdUpdate(UserDTO dto) throws Exception {
		return mapper.compPwdUpdate(dto);
	}

	// ===== 회사/계약/사용자 관리 (compcd.jsp) =====
	@Override public List<CompMdDTO> selCompCdList(CompMdDTO dto) throws Exception { return mapper.selCompCdList(dto); }
	@Override public String CompCdMstDupChk(CompMdDTO dto) throws Exception { return mapper.CompCdMstDupChk(dto); }
	@Override public int insertCompCdMst(CompMdDTO dto) throws Exception { return mapper.insertCompCdMst(dto); }
	@Override public int updateCompCdMst(CompMdDTO dto) throws Exception { return mapper.updateCompCdMst(dto); }

	@Override public List<CompConDTO> selectCompContList(CompConDTO dto) throws Exception { return mapper.selectCompContList(dto); }
	@Override public List<CompConDTO> getCompContList(CompConDTO dto) throws Exception { return mapper.getCompContList(dto); }
	@Override public String CompContDupChk(CompConDTO dto) throws Exception { return mapper.CompContDupChk(dto); }
	@Override public int insertCompCont(CompConDTO dto) throws Exception { return mapper.insertCompCont(dto); }
	@Override public int updateCompCont(CompConDTO dto) throws Exception { return mapper.updateCompCont(dto); }

	@Override public java.util.List<java.util.Map<String,Object>> selectCommCodeList(java.util.Map<String,Object> param) throws Exception { return mapper.selectCommCodeList(param); }
	@Override public List<UserDTO> compUserList(UserDTO dto) throws Exception { return mapper.compUserList(dto); }
	@Override public int insertCompUser(UserDTO dto) throws Exception { return mapper.insertCompUser(dto); }
	@Override public int updateCompUser(UserDTO dto) throws Exception { return mapper.updateCompUser(dto); }
	@Override public String CompUserDupChk(UserDTO dto) throws Exception { return mapper.CompUserDupChk(dto); }
	@Override public String CompUseridDupChk(UserDTO dto) throws Exception { return mapper.CompUseridDupChk(dto); }

	@Override
	public UserDTO userInfo(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userInfo(dto);
	}

	@Override
	public boolean userPwdReset(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userPwdReset(dto);
	}

	@Override
	public boolean userPwdChange(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.userPwdChange(dto);
	}

	@Override
	public List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception {
		return mapper.getSignList(map);
	}

	@Override
	public String selectLatestTermsSeq(String termsGb) throws Exception {
		return mapper.selectLatestTermsSeq(termsGb);
	}

	@Override
	public int insertPersign(PersignDTO dto) throws Exception {
		return mapper.insertPersign(dto);
	}

	@Override
	public int saveAllPatientAgreements(String userUuid, String regId) throws Exception {
		// SEJONG_APP login.jsp 의 약관 3종 (3=이용약관, 1=개인정보, 2=고유식별) 모두 동의 상태로 저장.
		// T_SIGN_MST/T_PERSIGN_TRAN 이 아직 없거나 비어 있는 케이스(초기 운영)를 흡수하기 위해
		// 각 termsGb 처리를 개별 try/catch 로 격리 — 1개가 실패해도 다른 항목은 계속 시도.
		String[] termsGbList = { "1", "2", "3" };
		int total = 0;
		for (String gb : termsGbList) {
			try {
				String termsSeq = mapper.selectLatestTermsSeq(gb);
				if (termsSeq == null || termsSeq.isEmpty()) {
					// 해당 termsGb 의 활성 약관이 없으면 기록하지 않음 (마스터 미설정/빈 테이블 케이스).
					LOGGER.info("[Persign] no active termsSeq for termsGb={} — skip", gb);
					continue;
				}
				PersignDTO p = new PersignDTO();
				p.setUserUuid(userUuid);
				p.setTermsSeq(termsSeq);
				p.setTermsGb(gb);
				p.setAgreeYn("Y");
				p.setRegId(regId);
				total += mapper.insertPersign(p);
			} catch (Exception perGbEx) {
				// 테이블 미존재 등의 SQL 오류 — 다음 termsGb 계속 시도.
				LOGGER.warn("[Persign] save failed for termsGb={} (table missing/schema mismatch?): {}",
						gb, perGbEx.getMessage());
			}
		}
		return total;
	}

}