package egovframework.sejong.admin.model;

public class CommDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud        = "";    //
	private String code       = "";    // 공통코드
	private String codeName   = "";    // 공통코드명
	private String startDate  = "";    // 적용시작일
	private String endDate    = "";    // 적용종료일
	private String useYn      = "";    // 사용여부
	private String dtlCode    = "";    // 상세코드
	private String dtlCodeNm  = "";    // 상세코드명
	private String sort       = "";    // 정렬순서

	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
	}
	public String getCodeName() {
		return codeName;
	}
	public void setCodeName(String codeName) {
		this.codeName = codeName;
	}
	public String getStartDate() {
		return startDate;
	}
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}
	public String getEndDate() {
		return endDate;
	}
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	public String getUseYn() {
		return useYn;
	}
	public void setUseYn(String useYn) {
		this.useYn = useYn;
	}
	public String getDtlCode() {
		return dtlCode;
	}
	public void setDtlCode(String dtlCode) {
		this.dtlCode = dtlCode;
	}
	public String getDtlCodeNm() {
		return dtlCodeNm;
	}
	public void setDtlCodeNm(String dtlCodeNm) {
		this.dtlCodeNm = dtlCodeNm;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}

}
