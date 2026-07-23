package egovframework.sejong.admin.model;

public class FaqDTO {
	private String faqGb;
	private String qstnConts;
	private String ansrConts;
	private String useYn;
	private String regId;
	private String regDtm;
	private String modId;
	private String modDtm;
	private String iud;
	private String faqSeq;
	private String searchText;
	private String searchGb;

	public String getSearchGb() { return searchGb; }
	public void setSearchGb(String searchGb) { this.searchGb = searchGb; }

	public String getSearchText() { return searchText; }
	public void setSearchText(String searchText) { this.searchText = searchText; }

	public String getFaqGb() { return faqGb; }
	public void setFaqGb(String faqGb) { this.faqGb = faqGb; }

	public String getQstnConts() { return qstnConts; }
	public void setQstnConts(String qstnConts) { this.qstnConts = qstnConts; }

	public String getAnsrConts() { return ansrConts; }
	public void setAnsrConts(String ansrConts) { this.ansrConts = ansrConts; }

	public String getUseYn() { return useYn; }
	public void setUseYn(String useYn) { this.useYn = useYn; }

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

	public String getFaqSeq() { return faqSeq; }
	public void setFaqSeq(String faqSeq) { this.faqSeq = faqSeq; }
}
