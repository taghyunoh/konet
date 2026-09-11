package egovframework.sejong.user.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * 공통코드 관리(codecd.jsp = commcd.jsp 포팅) — KOLGSDB TBL_CODE_MST / TBL_CODE_DTL
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class CodeMdDTO {
	private String findData;
	private String iud;
	private String jobSeq;
	private String actionYn;

	// 대표(TBL_CODE_MST)
	private String codeCd;
	private String codeNm;
	private String startDt;
	private String endDt;
	private String useYn;
	private Integer sort;
	private String regDttm;
	private String regUser;
	private String regIp;
	private String updDttm;
	private String updUser;
	private String updIp;

	// 상세(TBL_CODE_DTL)
	private String codeGb;
	private String subCode;
	private String subCodeNm;
	private String dtlCodeNm;   // 구분명칭(코드구분 SUB_CODE_NM 표시용)
	private String prop1;
	private String prop2;
	private String prop3;
	private String prop4;
	private String prop5;

	// 그리드 PK
	private String keycodeCd;
	private String keycodeGb;
	private String keysubCode;

	public String getFindData() { return findData; }
	public void setFindData(String findData) { this.findData = findData; }
	public String getIud() { return iud; }
	public void setIud(String iud) { this.iud = iud; }
	public String getJobSeq() { return jobSeq; }
	public void setJobSeq(String jobSeq) { this.jobSeq = jobSeq; }
	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }
	public String getCodeCd() { return codeCd; }
	public void setCodeCd(String codeCd) { this.codeCd = codeCd; }
	public String getCodeNm() { return codeNm; }
	public void setCodeNm(String codeNm) { this.codeNm = codeNm; }
	public String getStartDt() { return startDt; }
	public void setStartDt(String startDt) { this.startDt = startDt; }
	public String getEndDt() { return endDt; }
	public void setEndDt(String endDt) { this.endDt = endDt; }
	public String getUseYn() { return useYn; }
	public void setUseYn(String useYn) { this.useYn = useYn; }
	public Integer getSort() { return sort; }
	public void setSort(Integer sort) { this.sort = sort; }
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
	public String getCodeGb() { return codeGb; }
	public void setCodeGb(String codeGb) { this.codeGb = codeGb; }
	public String getSubCode() { return subCode; }
	public void setSubCode(String subCode) { this.subCode = subCode; }
	public String getSubCodeNm() { return subCodeNm; }
	public void setSubCodeNm(String subCodeNm) { this.subCodeNm = subCodeNm; }
	public String getDtlCodeNm() { return dtlCodeNm; }
	public void setDtlCodeNm(String dtlCodeNm) { this.dtlCodeNm = dtlCodeNm; }
	public String getProp1() { return prop1; }
	public void setProp1(String prop1) { this.prop1 = prop1; }
	public String getProp2() { return prop2; }
	public void setProp2(String prop2) { this.prop2 = prop2; }
	public String getProp3() { return prop3; }
	public void setProp3(String prop3) { this.prop3 = prop3; }
	public String getProp4() { return prop4; }
	public void setProp4(String prop4) { this.prop4 = prop4; }
	public String getProp5() { return prop5; }
	public void setProp5(String prop5) { this.prop5 = prop5; }
	public String getKeycodeCd() { return keycodeCd; }
	public void setKeycodeCd(String keycodeCd) { this.keycodeCd = keycodeCd; }
	public String getKeycodeGb() { return keycodeGb; }
	public void setKeycodeGb(String keycodeGb) { this.keycodeGb = keycodeGb; }
	public String getKeysubCode() { return keysubCode; }
	public void setKeysubCode(String keysubCode) { this.keysubCode = keysubCode; }
}
