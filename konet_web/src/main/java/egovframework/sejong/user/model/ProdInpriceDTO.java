package egovframework.sejong.user.model;

/**
 * 매입단가 이력 DTO  →  TBL_PROD_INPRICE_HST
 *  · 품목(PROD_SEQ)별·매입처별·적용일자별 매입단가 이력
 *  · 신규 등록 시 TBL_PROD_MST.IN_PRICE(현재 매입단가) 동기화
 */
public class ProdInpriceDTO {

    private Long    inpriceSeq;    // PK
    private Long    prodSeq;       // 품목마스터 PK
    private String  prodCd;        // 품목코드
    private String  vendorCd;      // 매입처코드
    private String  vendorNm;      // 매입처명
    private String  applyDt;       // 적용시작일자 (YYYY-MM-DD / YYYYMMDD)
    private Double  inPrice;       // 매입단가
    private Double  prevPrice;     // 직전 매입단가
    private String  taxGb;         // 과세구분
    private String  remark;        // 비고
    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    public Long getInpriceSeq() { return inpriceSeq; }
    public void setInpriceSeq(Long inpriceSeq) { this.inpriceSeq = inpriceSeq; }
    public Long getProdSeq() { return prodSeq; }
    public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
    public String getProdCd() { return prodCd; }
    public void setProdCd(String prodCd) { this.prodCd = prodCd; }
    public String getVendorCd() { return vendorCd; }
    public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
    public String getVendorNm() { return vendorNm; }
    public void setVendorNm(String vendorNm) { this.vendorNm = vendorNm; }
    public String getApplyDt() { return applyDt; }
    public void setApplyDt(String applyDt) { this.applyDt = applyDt; }
    public Double getInPrice() { return inPrice; }
    public void setInPrice(Double inPrice) { this.inPrice = inPrice; }
    public Double getPrevPrice() { return prevPrice; }
    public void setPrevPrice(Double prevPrice) { this.prevPrice = prevPrice; }
    public String getTaxGb() { return taxGb; }
    public void setTaxGb(String taxGb) { this.taxGb = taxGb; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public String getActionYn() { return actionYn; }
    public void setActionYn(String actionYn) { this.actionYn = actionYn; }
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
}
