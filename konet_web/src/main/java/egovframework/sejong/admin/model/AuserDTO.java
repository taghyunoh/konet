package egovframework.sejong.admin.model;
public class AuserDTO{
	private String userId;
	private String encUserId;       //암호화 사용자id
	private String decUserId;       //복호화 사용자id
	private String userNm;
	private String userPw;
	private String userGb;
	private String deptNm;
	private String startDate;
	private String endDate;
	private String pwdChgYmd;
	private String loginFailCnt;
	private String lockYn;
	private String useYn;
	private String bigo;
	private String regId;
	private String regDtm;
	private String modId;
	private String modDtm;
	private String iud;
	private int size;
	private String encAuserPwd;     //사용자 비밀번호
	private String bfAuserPwd;      //이전 비밀번호
	private String afAuserPwd;      //변경 비밀번호
	private String pwdreset;        //초기화여부
	private String userIdNm;

	public String getUserIdNm() { return userIdNm; }
	public void setUserIdNm(String userIdNm) { this.userIdNm = userIdNm; }

	public String getEncUserId() { return encUserId; }
	public void setEncUserId(String encUserId) { this.encUserId = encUserId; }

	public String getDecUserId() { return decUserId; }
	public void setDecUserId(String decUserId) { this.decUserId = decUserId; }

	public String getEncAuserPwd() { return encAuserPwd; }
	public void setEncAuserPwd(String encAuserPwd) { this.encAuserPwd = encAuserPwd; }

	public String getBfAuserPwd() { return bfAuserPwd; }
	public void setBfAuserPwd(String bfAuserPwd) { this.bfAuserPwd = bfAuserPwd; }

	public String getAfAuserPwd() { return afAuserPwd; }
	public void setAfAuserPwd(String afAuserPwd) { this.afAuserPwd = afAuserPwd; }

	public String getPwdreset() { return pwdreset; }
	public void setPwdreset(String pwdreset) { this.pwdreset = pwdreset; }

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

	public String getIud() { return iud; }
	public void setIud(String iud) { this.iud = iud; }

	public int getSize() { return size; }
	public void setSize(int size) { this.size = size; }
}
