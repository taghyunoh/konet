package egovframework.sejong.admin.model;

public class AsqDTO {
	private String userUuid;
	private String qstnTitl;
	private String qstnConts;
	private String qstnYmd;
	private String ansrConts;
	private String ansrYn;
	private String iud;
	private String searchText;
	private String asqSeq;

	private String userNm;
	private String gender;
	private String birth;
	   
	public String getUserNm() {
		return userNm;
	}
	public void setUserNm(String userNm) {
		this.userNm = userNm;
	}
	public String getGender() {
		return gender;
	}
	public void setGender(String gender) {
		this.gender = gender;
	}
	public String getBirth() {
		return birth;
	}
	public void setBirth(String birth) {
		this.birth = birth;
	}
	public String getUserUuid() {
		return userUuid;
	}
	public void setUserUuid(String userUuid) {
		this.userUuid = userUuid;
	}
	public String getAsqSeq() {
		return asqSeq;
	}
	public void setAsqSeq(String asqSeq) {
		this.asqSeq = asqSeq;
	}
	public String getSearchText() {
		return searchText;
	}
	public void setSearchText(String searchText) {
		this.searchText = searchText;
	}
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getQstnTitl() {
		return qstnTitl;
	}
	public void setQstnTitl(String qstnTitl) {
		this.qstnTitl = qstnTitl;
	}
	public String getQstnConts() {
		return qstnConts;
	}
	public void setQstnConts(String qstnConts) {
		this.qstnConts = qstnConts;
	}
	public String getQstnYmd() {
		return qstnYmd;
	}
	public void setQstnYmd(String qstnYmd) {
		this.qstnYmd = qstnYmd;
	}
	public String getAnsrConts() {
		return ansrConts;
	}
	public void setAnsrConts(String ansrConts) {
		this.ansrConts = ansrConts;
	}
	public String getAnsrYn() {
		return ansrYn;
	}
	public void setAnsrYn(String ansrYn) {
		this.ansrYn = ansrYn;
	}

}
