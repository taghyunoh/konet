package egovframework.sejong.user.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class UserDTO{

	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String userId;          // 사용자 ID
	private String userNm;          // 사용자 명
	private String userPw;          // 사용자비밀번호
	private String userGb;          // 관리자 여부
	private String deptNm;          // 진료과명
	private String startDate;       // 적용시작일자
	private String endDate;         // 적용종료일자
	private String pwdChgYmd;       // 비밀번호 변경 일(8자리)
	private String loginFailCnt;    // 로그인 실패 횟수
	private String lockYn;          // 로그인 잠김 여부
	private String useYn;           // 사용여부
	private String useyn;           // 사용여부 (소문자 컬럼 USEYN 호환용)
	private String bigo;            // 비고사항
	private String regId;           // 등록한 아이디
 	private String regDtm;          // 등록일
	private String modId;           // 수정한 아이디
	private String modDtm;          // 수정일

	private String encUserId;       // 아이디 (암호화)
	private String encUserPwd;      // 사용자 비밀번호 (암호화)
	private String bfUserPwd;       // 이전 비밀번호
	private String afUserPwd;       // 변경 비밀번호
	private String pwdreset;        // 초기화여부

	private String userUuid;

	private String userIdNm;

	// ===== KOLGSDB(TBL_USER_MST/TBL_COMP_MST) 로그인용 추가 필드 =====
	private String compCd;     // 회사코드(COMP_CD)
	private String compNm;     // 회사명(COMP_NM)
	private String passWd;     // 비밀번호(DB 저장 해시 base64 문자열)
	private String mainGu;     // 사용자구분(MAIN_GU)
	private String startDt;    // 시작일자(START_DT)
	private String endDt;      // 종료일자(END_DT)
	private String commstYn;   // COMMST_YN
	private String actionYn;   // 활성여부(ACTION_YN)

	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

	public String getCompNm() { return compNm; }
	public void setCompNm(String compNm) { this.compNm = compNm; }

	public String getPassWd() { return passWd; }
	public void setPassWd(String passWd) { this.passWd = passWd; }

	public String getMainGu() { return mainGu; }
	public void setMainGu(String mainGu) { this.mainGu = mainGu; }

	public String getStartDt() { return startDt; }
	public void setStartDt(String startDt) { this.startDt = startDt; }

	public String getEndDt() { return endDt; }
	public void setEndDt(String endDt) { this.endDt = endDt; }

	public String getCommstYn() { return commstYn; }
	public void setCommstYn(String commstYn) { this.commstYn = commstYn; }

	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }

	// ===== 회사 사용자(compcd.jsp) CRUD 추가 필드 =====
	private String jobSeq;
	private String email;
	private String userTel;
	private String mbrJoin;
	private String passCdt;
	private String encPassWd;   // 신규 저장용 인코딩 비번
	private String bfPassWd;    // 입력 원문 비번
	private String regUser;
	private String regIp;
	private String updUser;
	private String updIp;
	private String regDttm;
	private String updDttm;
	private String useNot;      // 기간내 사용여부(Y/N)
	private String mainGuNm;    // 사용자구분 명
	private String keyurcompCd; // 그리드 PK (그리드 name 속성과 동일 소문자)
	private String keyurstartDt;
	private String keyuruserId;

	public String getJobSeq() { return jobSeq; }
	public void setJobSeq(String jobSeq) { this.jobSeq = jobSeq; }
	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }
	public String getUserTel() { return userTel; }
	public void setUserTel(String userTel) { this.userTel = userTel; }
	public String getMbrJoin() { return mbrJoin; }
	public void setMbrJoin(String mbrJoin) { this.mbrJoin = mbrJoin; }
	public String getPassCdt() { return passCdt; }
	public void setPassCdt(String passCdt) { this.passCdt = passCdt; }
	public String getEncPassWd() { return encPassWd; }
	public void setEncPassWd(String encPassWd) { this.encPassWd = encPassWd; }
	public String getBfPassWd() { return bfPassWd; }
	public void setBfPassWd(String bfPassWd) { this.bfPassWd = bfPassWd; }
	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }
	public String getRegDttm() { return regDttm; }
	public void setRegDttm(String regDttm) { this.regDttm = regDttm; }
	public String getUpdDttm() { return updDttm; }
	public void setUpdDttm(String updDttm) { this.updDttm = updDttm; }
	public String getUseNot() { return useNot; }
	public void setUseNot(String useNot) { this.useNot = useNot; }
	public String getMainGuNm() { return mainGuNm; }
	public void setMainGuNm(String mainGuNm) { this.mainGuNm = mainGuNm; }
	public String getKeyurcompCd() { return keyurcompCd; }
	public void setKeyurcompCd(String keyurcompCd) { this.keyurcompCd = keyurcompCd; }
	public String getKeyurstartDt() { return keyurstartDt; }
	public void setKeyurstartDt(String keyurstartDt) { this.keyurstartDt = keyurstartDt; }
	public String getKeyuruserId() { return keyuruserId; }
	public void setKeyuruserId(String keyuruserId) { this.keyuruserId = keyuruserId; }

	public String getUserIdNm() { return userIdNm; }
	public void setUserIdNm(String userIdNm) { this.userIdNm = userIdNm; }

	public String getEncUserId() { return encUserId; }
	public void setEncUserId(String encUserId) { this.encUserId = encUserId; }

	public String getUserId() { return userId; }
	public void setUserId(String userId) { this.userId = userId; }

	public String getUserNm() { return userNm; }
	public void setUserNm(String userNm) { this.userNm = userNm; }

	public String getUserPw() { return userPw; }
	public void setUserPw(String userPw) { this.userPw = userPw; }

	public String getUserGb() { return userGb; }
	public void setUserGb(String userGb) { this.userGb = userGb; }

	public String getDeptNm() { return deptNm; }
	public void setDeptNm(String deptNm) { this.deptNm = deptNm; }

	public String getStartDate() { return startDate; }
	public void setStartDate(String startDate) { this.startDate = startDate; }

	public String getEndDate() { return endDate; }
	public void setEndDate(String endDate) { this.endDate = endDate; }

	public String getPwdChgYmd() { return pwdChgYmd; }
	public void setPwdChgYmd(String pwdChgYmd) { this.pwdChgYmd = pwdChgYmd; }

	public String getLoginFailCnt() { return loginFailCnt; }
	public void setLoginFailCnt(String loginFailCnt) { this.loginFailCnt = loginFailCnt; }

	public String getLockYn() { return lockYn; }
	public void setLockYn(String lockYn) { this.lockYn = lockYn; }

	public String getUseYn() { return useYn; }
	public void setUseYn(String useYn) { this.useYn = useYn; }

	public String getUseyn() { return useyn; }
	public void setUseyn(String useyn) { this.useyn = useyn; }

	public String getBigo() { return bigo; }
	public void setBigo(String bigo) { this.bigo = bigo; }

	public String getRegId() { return regId; }
	public void setRegId(String regId) { this.regId = regId; }

	public String getRegDtm() { return regDtm; }
	public void setRegDtm(String regDtm) { this.regDtm = regDtm; }

	public String getModId() { return modId; }
	public void setModId(String modId) { this.modId = modId; }

	public String getModDtm() { return modDtm; }
	public void setModDtm(String modDtm) { this.modDtm = modDtm; }

	public String getEncUserPwd() { return encUserPwd; }
	public void setEncUserPwd(String encUserPwd) { this.encUserPwd = encUserPwd; }

	public String getBfUserPwd() { return bfUserPwd; }
	public void setBfUserPwd(String bfUserPwd) { this.bfUserPwd = bfUserPwd; }

	public String getAfUserPwd() { return afUserPwd; }
	public void setAfUserPwd(String afUserPwd) { this.afUserPwd = afUserPwd; }

	public String getPwdreset() { return pwdreset; }
	public void setPwdreset(String pwdreset) { this.pwdreset = pwdreset; }

	public String getUserUuid() { return userUuid; }
	public void setUserUuid(String userUuid) { this.userUuid = userUuid; }
}
