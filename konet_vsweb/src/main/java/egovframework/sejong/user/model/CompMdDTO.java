package egovframework.sejong.user.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * 회사(TBL_COMP_MST) 관리용 DTO — compcd.jsp (hospcd.jsp 포팅)
 * COMP 스키마에 없는 hosp 필드(hosGrd/omtYn/wardcnt 등)는 제외.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class CompMdDTO {
	private String compCd;
	private String jobSeq;
	private String compNm;
	private String compAddr;
	private String compExtradr;
	private String compCeo;
	private String busiNum;
	private String inaccd;
	private String zipCd;
	private String compTel;
	private String compFax;
	private String startDt;
	private String endDt;
	private String joinDt;
	private String acceptDt;
	private String closeDt;
	private String useYn;
	private String actionYn;
	private String sthpnm;
	private String commstYn;   // 관리자여부 (구 WINNER_YN)
	private String regDttm;
	private String regUser;
	private String regIp;
	private String updDttm;
	private String updUser;
	private String updIp;

	private String fileYn;     // 첨부파일 존재여부
	private String findData;   // 조회조건
	private String keyCompCd;  // 그리드 PK(수정/삭제용)

	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }
	public String getJobSeq() { return jobSeq; }
	public void setJobSeq(String jobSeq) { this.jobSeq = jobSeq; }
	public String getCompNm() { return compNm; }
	public void setCompNm(String compNm) { this.compNm = compNm; }
	public String getCompAddr() { return compAddr; }
	public void setCompAddr(String compAddr) { this.compAddr = compAddr; }
	public String getCompExtradr() { return compExtradr; }
	public void setCompExtradr(String compExtradr) { this.compExtradr = compExtradr; }
	public String getCompCeo() { return compCeo; }
	public void setCompCeo(String compCeo) { this.compCeo = compCeo; }
	public String getBusiNum() { return busiNum; }
	public void setBusiNum(String busiNum) { this.busiNum = busiNum; }
	public String getInaccd() { return inaccd; }
	public void setInaccd(String inaccd) { this.inaccd = inaccd; }
	public String getZipCd() { return zipCd; }
	public void setZipCd(String zipCd) { this.zipCd = zipCd; }
	public String getCompTel() { return compTel; }
	public void setCompTel(String compTel) { this.compTel = compTel; }
	public String getCompFax() { return compFax; }
	public void setCompFax(String compFax) { this.compFax = compFax; }
	public String getStartDt() { return startDt; }
	public void setStartDt(String startDt) { this.startDt = startDt; }
	public String getEndDt() { return endDt; }
	public void setEndDt(String endDt) { this.endDt = endDt; }
	public String getJoinDt() { return joinDt; }
	public void setJoinDt(String joinDt) { this.joinDt = joinDt; }
	public String getAcceptDt() { return acceptDt; }
	public void setAcceptDt(String acceptDt) { this.acceptDt = acceptDt; }
	public String getCloseDt() { return closeDt; }
	public void setCloseDt(String closeDt) { this.closeDt = closeDt; }
	public String getUseYn() { return useYn; }
	public void setUseYn(String useYn) { this.useYn = useYn; }
	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }
	public String getSthpnm() { return sthpnm; }
	public void setSthpnm(String sthpnm) { this.sthpnm = sthpnm; }
	public String getCommstYn() { return commstYn; }
	public void setCommstYn(String commstYn) { this.commstYn = commstYn; }
	public String getRegDttm() { return regDttm; }
	public void setRegDttm(String regDttm) { this.regDttm = regDttm; }
	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdDttm() { return updDttm; }
	public void setUpdDttm(String updDttm) { this.updDttm = updDttm; }
	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }
	public String getFileYn() { return fileYn; }
	public void setFileYn(String fileYn) { this.fileYn = fileYn; }
	public String getFindData() { return findData; }
	public void setFindData(String findData) { this.findData = findData; }
	public String getKeyCompCd() { return keyCompCd; }
	public void setKeyCompCd(String keyCompCd) { this.keyCompCd = keyCompCd; }
}
