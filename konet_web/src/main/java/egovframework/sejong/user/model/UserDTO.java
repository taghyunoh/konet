package egovframework.sejong.user.model;

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
