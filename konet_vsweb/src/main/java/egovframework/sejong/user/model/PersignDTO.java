package egovframework.sejong.user.model;

/**
 * 개인정보 동의이력 DTO — T_PERSIGN_TRAN
 *
 * ⚠ 컬럼 가정 (확정된 DDL 부재로 표준 형태 추정):
 *   - USER_UUID  : 사용자 UUID (PK 일부) — 코드에 명시된 유일한 컬럼
 *   - TERMS_SEQ  : T_SIGN_MST FK (PK 일부)
 *   - TERMS_GB   : 1=개인정보 수집·이용 / 2=고유식별정보 / 3=서비스 이용약관 (denormalize)
 *   - AGREE_YN   : Y/N
 *   - AGREE_DTM  : 동의 시각
 *   - REG_ID / REG_DTM / MOD_ID / MOD_DTM : 감사 컬럼
 *
 * 실제 DB 스키마와 다르면 User_SQL.xml 의 INSERT 컬럼명만 맞춰 수정.
 */
public class PersignDTO {
	private String userUuid;
	private String termsSeq;
	private String termsGb;
	private String agreeYn;
	private String agreeDtm;
	private String regId;
	private String regDtm;
	private String modId;
	private String modDtm;

	public String getUserUuid()  { return userUuid; }
	public void   setUserUuid(String userUuid)  { this.userUuid = userUuid; }
	public String getTermsSeq()  { return termsSeq; }
	public void   setTermsSeq(String termsSeq)  { this.termsSeq = termsSeq; }
	public String getTermsGb()   { return termsGb; }
	public void   setTermsGb(String termsGb)    { this.termsGb = termsGb; }
	public String getAgreeYn()   { return agreeYn; }
	public void   setAgreeYn(String agreeYn)    { this.agreeYn = agreeYn; }
	public String getAgreeDtm()  { return agreeDtm; }
	public void   setAgreeDtm(String agreeDtm)  { this.agreeDtm = agreeDtm; }
	public String getRegId()     { return regId; }
	public void   setRegId(String regId)        { this.regId = regId; }
	public String getRegDtm()    { return regDtm; }
	public void   setRegDtm(String regDtm)      { this.regDtm = regDtm; }
	public String getModId()     { return modId; }
	public void   setModId(String modId)        { this.modId = modId; }
	public String getModDtm()    { return modDtm; }
	public void   setModDtm(String modDtm)      { this.modDtm = modDtm; }
}
