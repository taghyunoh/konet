package egovframework.sejong.user.model;

/**
 * 출금/미지급 DTO  →  TBL_PAYMENT_MST (매입처 × 귀속월)
 *  · 미지급잔액 = 전월이월 + 당월매입 − 당월출금 (화면/조회 계산)
 */
public class PaymentDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

    private Long    paySeq;
    private String  payYm;       // 귀속월 'YYYYMM' 또는 'YYYY-MM'(요청)
    private String  bizCd;       // 매입처(거래처)코드
    private String  bizNm;       // 매입처명
    private Double  prevAmt;     // 전월이월
    private Double  purchAmt;    // 당월매입
    private Double  payoutAmt;   // 당월출금(지급)
    private String  payoutDt;    // 최근 출금일자
    private String  payGb;       // 지급방법
    private String  remark;
    private String  actionYn;
    private String  regDttm;
    private String  updDttm;
    private String  findData;    // 검색어(매입처코드/명) — 비영속
    private String  regUser;
    private String  regIp;
    private String  updUser;
    private String  updIp;

    public Long getPaySeq() { return paySeq; }
    public void setPaySeq(Long paySeq) { this.paySeq = paySeq; }
    public String getPayYm() { return payYm; }
    public void setPayYm(String payYm) { this.payYm = payYm; }
    public String getBizCd() { return bizCd; }
    public void setBizCd(String bizCd) { this.bizCd = bizCd; }
    public String getBizNm() { return bizNm; }
    public void setBizNm(String bizNm) { this.bizNm = bizNm; }
    public Double getPrevAmt() { return prevAmt; }
    public void setPrevAmt(Double prevAmt) { this.prevAmt = prevAmt; }
    public Double getPurchAmt() { return purchAmt; }
    public void setPurchAmt(Double purchAmt) { this.purchAmt = purchAmt; }
    public Double getPayoutAmt() { return payoutAmt; }
    public void setPayoutAmt(Double payoutAmt) { this.payoutAmt = payoutAmt; }
    public String getPayoutDt() { return payoutDt; }
    public void setPayoutDt(String payoutDt) { this.payoutDt = payoutDt; }
    public String getPayGb() { return payGb; }
    public void setPayGb(String payGb) { this.payGb = payGb; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public String getActionYn() { return actionYn; }
    public void setActionYn(String actionYn) { this.actionYn = actionYn; }
    public String getRegDttm() { return regDttm; }
    public void setRegDttm(String regDttm) { this.regDttm = regDttm; }
    public String getUpdDttm() { return updDttm; }
    public void setUpdDttm(String updDttm) { this.updDttm = updDttm; }
    public String getFindData() { return findData; }
    public void setFindData(String findData) { this.findData = findData; }
    public String getRegUser() { return regUser; }
    public void setRegUser(String regUser) { this.regUser = regUser; }
    public String getRegIp() { return regIp; }
    public void setRegIp(String regIp) { this.regIp = regIp; }
    public String getUpdUser() { return updUser; }
    public void setUpdUser(String updUser) { this.updUser = updUser; }
    public String getUpdIp() { return updIp; }
    public void setUpdIp(String updIp) { this.updIp = updIp; }
}
