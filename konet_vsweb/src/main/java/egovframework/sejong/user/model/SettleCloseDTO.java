package egovframework.sejong.user.model;

/**
 * 정산(수금/출금) 월 마감상태 DTO  →  TBL_SETTLE_CLOSE_MST
 *  · settleGb : 'RCV'(수금) / 'PAY'(출금)
 *  · status   : 'Y' 확정(잠금) / 'N' 해제
 */
public class SettleCloseDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

    private String settleGb;
    private String closeYm;      // 'YYYYMM' 또는 'YYYY-MM'
    private String status;
    private String confirmDttm;
    private String confirmUser;
    private String updDttm;
    private String updUser;

    public String getSettleGb() { return settleGb; }
    public void setSettleGb(String settleGb) { this.settleGb = settleGb; }
    public String getCloseYm() { return closeYm; }
    public void setCloseYm(String closeYm) { this.closeYm = closeYm; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getConfirmDttm() { return confirmDttm; }
    public void setConfirmDttm(String confirmDttm) { this.confirmDttm = confirmDttm; }
    public String getConfirmUser() { return confirmUser; }
    public void setConfirmUser(String confirmUser) { this.confirmUser = confirmUser; }
    public String getUpdDttm() { return updDttm; }
    public void setUpdDttm(String updDttm) { this.updDttm = updDttm; }
    public String getUpdUser() { return updUser; }
    public void setUpdUser(String updUser) { this.updUser = updUser; }
}
