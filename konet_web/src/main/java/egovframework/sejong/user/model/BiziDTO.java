package egovframework.sejong.user.model;

/**
 * 사업장 분류 마스터 DTO  →  TBL_BIZI_MST
 *  · PK: bizCd(사업장코드) / bizNm(사업장명)
 *  · 출고현황표에서 "품목명 앞 () 없는" 행의 사업장코드→사업장명을 등록.
 *    업로드 분류 시 bizCd 가 이 테이블에 있으면 bizNm 으로 분류(없으면 품목명 () 접두어).
 */
public class BiziDTO {

	private String  bizCd;     // 사업장코드 (PK)
	private Integer jobSeq;    // 버전
	private String  actionYn;  // 'Y'=활성
	private String  bizNm;     // 사업장명

	private String  regUser;
	private String  regIp;
	private String  updUser;
	private String  updIp;

	public String getBizCd() { return bizCd; }
	public void setBizCd(String bizCd) { this.bizCd = bizCd; }
	public Integer getJobSeq() { return jobSeq; }
	public void setJobSeq(Integer jobSeq) { this.jobSeq = jobSeq; }
	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }
	public String getBizNm() { return bizNm; }
	public void setBizNm(String bizNm) { this.bizNm = bizNm; }

	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }
}
