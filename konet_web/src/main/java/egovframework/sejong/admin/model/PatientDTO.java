package egovframework.sejong.admin.model;
public class PatientDTO{
	private String userUuid;
	private String userId;
	private String userNm;
	private String userPw;
	private String userGb;
	private String mgmtGb;
	private String birth;
	private String gender;
	private String phone;
	private String email;
	private String joinYmd;
	private String pwdChgYmd;
	private String loginFailCnt;
	private String lockYn;
	private String regDtm;
	private String modDtm;
	private String token;
	private String pushYn;
	private String delDtm;
	private String searchText;
	private String iud;
	private String year;
	private String month;
	private String day;
	private String dtlCodeNm;
	private int size;
	private int height;
	private int weight;
	private int blodGb;
	private String userCheck;

	private String cgmDtm;
	private String cgmGap;
	private String eatDtm;
	private String eatGap;

	public String getCgmDtm() { return cgmDtm; }
	public void setCgmDtm(String cgmDtm) { this.cgmDtm = cgmDtm; }

	public String getCgmGap() { return cgmGap; }
	public void setCgmGap(String cgmGap) { this.cgmGap = cgmGap; }

	public String getEatDtm() { return eatDtm; }
	public void setEatDtm(String eatDtm) { this.eatDtm = eatDtm; }

	public String getEatGap() { return eatGap; }
	public void setEatGap(String eatGap) { this.eatGap = eatGap; }

	public String getUserCheck() { return userCheck; }
	public void setUserCheck(String userCheck) { this.userCheck = userCheck; }

	public int getBlodGb() { return blodGb; }
	public void setBlodGb(int blodGb) { this.blodGb = blodGb; }

	public int getHeight() { return height; }
	public void setHeight(int height) { this.height = height; }

	public int getWeight() { return weight; }
	public void setWeight(int weight) { this.weight = weight; }

	public String getDtlCodeNm() { return dtlCodeNm; }
	public void setDtlCodeNm(String dtlCodeNm) { this.dtlCodeNm = dtlCodeNm; }

	public String getUserUuid() { return userUuid; }
	public void setUserUuid(String userUuid) { this.userUuid = userUuid; }

	public String getUserId() { return userId; }
	public void setUserId(String userId) { this.userId = userId; }

	public String getUserNm() { return userNm; }
	public void setUserNm(String userNm) { this.userNm = userNm; }

	public String getUserPw() { return userPw; }
	public void setUserPw(String userPw) { this.userPw = userPw; }

	public String getUserGb() { return userGb; }
	public void setUserGb(String userGb) { this.userGb = userGb; }

	public String getMgmtGb() { return mgmtGb; }
	public void setMgmtGb(String mgmtGb) { this.mgmtGb = mgmtGb; }

	public String getBirth() { return birth; }
	public void setBirth(String birth) { this.birth = birth; }

	public String getGender() { return gender; }
	public void setGender(String gender) { this.gender = gender; }

	public String getPhone() { return phone; }
	public void setPhone(String phone) { this.phone = phone; }

	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }

	public String getJoinYmd() { return joinYmd; }
	public void setJoinYmd(String joinYmd) { this.joinYmd = joinYmd; }

	public String getPwdChgYmd() { return pwdChgYmd; }
	public void setPwdChgYmd(String pwdChgYmd) { this.pwdChgYmd = pwdChgYmd; }

	public String getLoginFailCnt() { return loginFailCnt; }
	public void setLoginFailCnt(String loginFailCnt) { this.loginFailCnt = loginFailCnt; }

	public String getLockYn() { return lockYn; }
	public void setLockYn(String lockYn) { this.lockYn = lockYn; }

	public String getRegDtm() { return regDtm; }
	public void setRegDtm(String regDtm) { this.regDtm = regDtm; }

	public String getModDtm() { return modDtm; }
	public void setModDtm(String modDtm) { this.modDtm = modDtm; }

	public String getToken() { return token; }
	public void setToken(String token) { this.token = token; }

	public String getPushYn() { return pushYn; }
	public void setPushYn(String pushYn) { this.pushYn = pushYn; }

	public String getDelDtm() { return delDtm; }
	public void setDelDtm(String delDtm) { this.delDtm = delDtm; }

	public String getSearchText() { return searchText; }
	public void setSearchText(String searchText) { this.searchText = searchText; }

	public String getIud() { return iud; }
	public void setIud(String iud) { this.iud = iud; }

	public int getSize() { return size; }
	public void setSize(int size) { this.size = size; }

	public String getYear() { return year; }
	public void setYear(String year) { this.year = year; }

	public String getMonth() { return month; }
	public void setMonth(String month) { this.month = month; }

	public String getDay() { return day; }
	public void setDay(String day) { this.day = day; }
}
