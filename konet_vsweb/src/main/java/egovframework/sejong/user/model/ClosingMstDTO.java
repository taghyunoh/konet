package egovframework.sejong.user.model;

/**
 * 마감 확정 헤더 DTO  →  TBL_CLOSING_MST (마감월별 1행)
 *  · 월 확정 시 매출/매출원가/마진/매입/기말재고금액 스냅샷 + 확정상태·일시·자
 */
public class ClosingMstDTO {

    private Long    closeSeq;
    private String  ym;           // 요청 마감월 'YYYY-MM' (SQL에서 '-' 제거)
    private String  closeYm;      // 저장/조회 'YYYYMM'
    private String  status;       // 'C'=확정
    private Double  salesAmt;     // 매출액
    private Double  cogsAmt;      // 매출원가
    private Double  marginAmt;    // 순마진(매출-매출원가)
    private Double  purchaseAmt;  // 매입액(입고)
    private Double  stockAmt;     // 기말재고금액
    private String  confirmDttm;
    private String  confirmUser;
    private String  actionYn;
    private String  regUser;
    private String  regIp;
    private String  updUser;
    private String  updIp;

    public Long getCloseSeq() { return closeSeq; }
    public void setCloseSeq(Long closeSeq) { this.closeSeq = closeSeq; }
    public String getYm() { return ym; }
    public void setYm(String ym) { this.ym = ym; }
    public String getCloseYm() { return closeYm; }
    public void setCloseYm(String closeYm) { this.closeYm = closeYm; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Double getSalesAmt() { return salesAmt; }
    public void setSalesAmt(Double salesAmt) { this.salesAmt = salesAmt; }
    public Double getCogsAmt() { return cogsAmt; }
    public void setCogsAmt(Double cogsAmt) { this.cogsAmt = cogsAmt; }
    public Double getMarginAmt() { return marginAmt; }
    public void setMarginAmt(Double marginAmt) { this.marginAmt = marginAmt; }
    public Double getPurchaseAmt() { return purchaseAmt; }
    public void setPurchaseAmt(Double purchaseAmt) { this.purchaseAmt = purchaseAmt; }
    public Double getStockAmt() { return stockAmt; }
    public void setStockAmt(Double stockAmt) { this.stockAmt = stockAmt; }
    public String getConfirmDttm() { return confirmDttm; }
    public void setConfirmDttm(String confirmDttm) { this.confirmDttm = confirmDttm; }
    public String getConfirmUser() { return confirmUser; }
    public void setConfirmUser(String confirmUser) { this.confirmUser = confirmUser; }
    public String getActionYn() { return actionYn; }
    public void setActionYn(String actionYn) { this.actionYn = actionYn; }
    public String getRegUser() { return regUser; }
    public void setRegUser(String regUser) { this.regUser = regUser; }
    public String getRegIp() { return regIp; }
    public void setRegIp(String regIp) { this.regIp = regIp; }
    public String getUpdUser() { return updUser; }
    public void setUpdUser(String updUser) { this.updUser = updUser; }
    public String getUpdIp() { return updIp; }
    public void setUpdIp(String updIp) { this.updIp = updIp; }
}
