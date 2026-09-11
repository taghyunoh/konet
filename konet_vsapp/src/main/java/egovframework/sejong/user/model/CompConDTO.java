package egovframework.sejong.user.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * 회사 계약(TBL_COMPCONT_MST) 관리용 DTO — compcd.jsp
 * COMPCONT 스키마엔 CONACT_GB / OCS_* / HOSP_UUID 가 없으므로 제외.
 * PK = (COMP_CD, START_DT, END_DT, JOB_SEQ)
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class CompConDTO {
	private String compCd;
	private String jobSeq;
	private String startDt;
	private String endDt;
	private String conContent;
	private String conUserId;
	private String conUserTel;
	private String conEmail;
	private String joinDt;
	private String acceptDt;
	private String closeDt;
	private String useYn;
	private String actionYn;
	private String regDttm;
	private String regUser;
	private String regIp;
	private String updDttm;
	private String updUser;
	private String updIp;

	// 그리드 PK(수정/삭제용)
	private String keycompCd;
	private String keystartDt;
	private String keyendDt;

	// 사용자등록 화면 표시용(회사정보 조인)
	private String compNm;
	private String compAddr;
	private String compTel;
	private String compFax;

	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }
	public String getJobSeq() { return jobSeq; }
	public void setJobSeq(String jobSeq) { this.jobSeq = jobSeq; }
	public String getStartDt() { return startDt; }
	public void setStartDt(String startDt) { this.startDt = startDt; }
	public String getEndDt() { return endDt; }
	public void setEndDt(String endDt) { this.endDt = endDt; }
	public String getConContent() { return conContent; }
	public void setConContent(String conContent) { this.conContent = conContent; }
	public String getConUserId() { return conUserId; }
	public void setConUserId(String conUserId) { this.conUserId = conUserId; }
	public String getConUserTel() { return conUserTel; }
	public void setConUserTel(String conUserTel) { this.conUserTel = conUserTel; }
	public String getConEmail() { return conEmail; }
	public void setConEmail(String conEmail) { this.conEmail = conEmail; }
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
	public String getKeycompCd() { return keycompCd; }
	public void setKeycompCd(String keycompCd) { this.keycompCd = keycompCd; }
	public String getKeystartDt() { return keystartDt; }
	public void setKeystartDt(String keystartDt) { this.keystartDt = keystartDt; }
	public String getKeyendDt() { return keyendDt; }
	public void setKeyendDt(String keyendDt) { this.keyendDt = keyendDt; }
	public String getCompNm() { return compNm; }
	public void setCompNm(String compNm) { this.compNm = compNm; }
	public String getCompAddr() { return compAddr; }
	public void setCompAddr(String compAddr) { this.compAddr = compAddr; }
	public String getCompTel() { return compTel; }
	public void setCompTel(String compTel) { this.compTel = compTel; }
	public String getCompFax() { return compFax; }
	public void setCompFax(String compFax) { this.compFax = compFax; }
}
