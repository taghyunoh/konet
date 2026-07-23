package egovframework.sejong.user.model;

/**
 * 수금/미수금 DTO  →  TBL_RECEIVE_MST (거래처 × 귀속월)
 *  · 미수잔액 = 전월이월 + 당월매출 − 당월수금 (화면/조회 계산)
 */
public class ReceiveDTO {

    private Long    rcvSeq;
    private String  rcvYm;       // 귀속월 'YYYYMM' 또는 'YYYY-MM'(요청)
    private String  bizCd;       // 거래처코드
    private String  bizNm;       // 거래처명
    private Double  prevAmt;     // 전월이월
    private Double  salesAmt;    // 당월매출
    private Double  collectAmt;  // 당월수금
    private String  collectDt;   // 최근 수금일자
    private String  payGb;       // 수금방법
    private String  remark;
    private String  actionYn;
    private String  regDttm;
    private String  updDttm;
    private String  findData;    // 검색어(거래처코드/명) — 비영속
    private String  regUser;
    private String  regIp;
    private String  updUser;
    private String  updIp;

    public Long getRcvSeq() { return rcvSeq; }
    public void setRcvSeq(Long rcvSeq) { this.rcvSeq = rcvSeq; }
    public String getRcvYm() { return rcvYm; }
    public void setRcvYm(String rcvYm) { this.rcvYm = rcvYm; }
    public String getBizCd() { return bizCd; }
    public void setBizCd(String bizCd) { this.bizCd = bizCd; }
    public String getBizNm() { return bizNm; }
    public void setBizNm(String bizNm) { this.bizNm = bizNm; }
    public Double getPrevAmt() { return prevAmt; }
    public void setPrevAmt(Double prevAmt) { this.prevAmt = prevAmt; }
    public Double getSalesAmt() { return salesAmt; }
    public void setSalesAmt(Double salesAmt) { this.salesAmt = salesAmt; }
    public Double getCollectAmt() { return collectAmt; }
    public void setCollectAmt(Double collectAmt) { this.collectAmt = collectAmt; }
    public String getCollectDt() { return collectDt; }
    public void setCollectDt(String collectDt) { this.collectDt = collectDt; }
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
