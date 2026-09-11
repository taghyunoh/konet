package egovframework.sejong.user.model;

/**
 * 약관(개인정보동의/이용약관/고유식별정보) 마스터 DTO — T_SIGN_MST
 * SEJONG_APP 의 SjgnDTO 와 동일한 구조 (DB 공용).
 */
public class SjgnDTO {
	private String termsSeq;
	private String termsGb;
	private String termsTitle;
	private String termsConts;
	private String useYn;
	private String regId;
	private String regDtm;
	private String modId;
	private String modDtm;

	public String getTermsSeq()   { return termsSeq; }
	public void   setTermsSeq(String termsSeq)   { this.termsSeq = termsSeq; }
	public String getTermsGb()    { return termsGb; }
	public void   setTermsGb(String termsGb)     { this.termsGb = termsGb; }
	public String getTermsTitle() { return termsTitle; }
	public void   setTermsTitle(String termsTitle) { this.termsTitle = termsTitle; }
	public String getTermsConts() { return termsConts; }
	public void   setTermsConts(String termsConts) { this.termsConts = termsConts; }
	public String getUseYn()      { return useYn; }
	public void   setUseYn(String useYn)         { this.useYn = useYn; }
	public String getRegId()      { return regId; }
	public void   setRegId(String regId)         { this.regId = regId; }
	public String getRegDtm()     { return regDtm; }
	public void   setRegDtm(String regDtm)       { this.regDtm = regDtm; }
	public String getModId()      { return modId; }
	public void   setModId(String modId)         { this.modId = modId; }
	public String getModDtm()     { return modDtm; }
	public void   setModDtm(String modDtm)       { this.modDtm = modDtm; }
}
