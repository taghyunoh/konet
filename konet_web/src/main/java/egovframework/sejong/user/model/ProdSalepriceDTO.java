package egovframework.sejong.user.model;

/**
 * 판매/도매 단가 이력 DTO  →  TBL_PROD_SALEPRICE_HST
 *  · 품목(PROD_SEQ)별·적용일자별 판매단가·도매단가 이력
 *  · 판매처(vendorCd) : NULL=공통(기본) 판매가 / 값 있음=그 판매처(TBL_VENDOR_MST 매출 거래처) 전용가.
 *    매출마감은 공통가만 집고, 전용가 등록은 마스터 SALE_PRICE 를 동기화하지 않는다.
 *  · 공통가 신규 등록 시 TBL_PROD_MST.SALE_PRICE/WHOLE_PRICE(현재 판매/도매가) 동기화
 */
public class ProdSalepriceDTO {

    private Long    salepriceSeq;  // PK
    private Long    prodSeq;       // 품목마스터 PK
    private String  prodCd;        // 품목코드
    private String  vendorCd;      // 판매처코드 (NULL=공통가)
    private String  vendorNm;      // 판매처명(스냅샷)
    private String  applyDt;       // 적용시작일자
    private Double  salePrice;     // 판매(출고)단가
    private Double  wholePrice;    // 도매단가
    private Double  baseInprice;   // 산정 시점 매입단가(마진 기준)
    private Double  marginRt;      // 마진율(%)
    private Double  prevPrice;     // 직전 판매단가
    private String  remark;
    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    public Long getSalepriceSeq() { return salepriceSeq; }
    public void setSalepriceSeq(Long salepriceSeq) { this.salepriceSeq = salepriceSeq; }
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
    public Double getSalePrice() { return salePrice; }
    public void setSalePrice(Double salePrice) { this.salePrice = salePrice; }
    public Double getWholePrice() { return wholePrice; }
    public void setWholePrice(Double wholePrice) { this.wholePrice = wholePrice; }
    public Double getBaseInprice() { return baseInprice; }
    public void setBaseInprice(Double baseInprice) { this.baseInprice = baseInprice; }
    public Double getMarginRt() { return marginRt; }
    public void setMarginRt(Double marginRt) { this.marginRt = marginRt; }
    public Double getPrevPrice() { return prevPrice; }
    public void setPrevPrice(Double prevPrice) { this.prevPrice = prevPrice; }
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
