package egovframework.sejong.user.model;

/**
 * 마감(매출/매입/마진) 집계 DTO
 *  · 원천: TBL_SHIPOUT_MST(출고일자 SHPOUT_DT 기준) × 단가
 *  · 단가: 출고일자 시점 유효단가 — TBL_PROD_SALEPRICE_HST(출고) / TBL_PROD_INPRICE_HST(매입)
 *          해당 이력 없으면 TBL_PROD_MST(SALE_PRICE / IN_PRICE) 마스터 단가로 폴백
 *  · 최소단위 그룹: 품목(ITEM_CD) + 사업장(BIZ_CD) + 매입처(VENDOR_CD)
 *    → 화면별로 재집계(매출마감=품목·사업장, 매입마감=품목·매입처, 마감현황=합계)
 */
public class ClosingDTO {

    private String  ym;         // 마감월(요청) 'YYYY-MM' — from/to 없을 때 월 전체
    private String  fromDt;     // 시작일자(요청) 'YYYY-MM-DD' — 있으면 기간 BETWEEN
    private String  toDt;       // 종료일자(요청) 'YYYY-MM-DD'
    private String  itemCd;     // 품목코드
    private String  itemNm;     // 품목명
    private String  bizCd;      // 사업장코드
    private String  bizNm;      // 사업장명
    private String  dcCd;       // 물류센터코드(출고장 그룹 판정용)
    private String  dcNm;       // 물류센터명
    private String  vendorCd;   // 매입처코드
    private String  vendorNm;   // 매입처명
    private Integer outQty;     // 출고수량 합
    private Double  salesAmt;   // 매출액 = Σ(출고수량 × 출고단가)
    private Double  costAmt;    // 매입액 = Σ(출고수량 × 매입단가)
    private Double  marginAmt;  // 순수마진액 = 매출액 − 매입액
    private String  saleSrc;    // 매출액 근거 ('정산'/'정산안분'/'이력'/'마스터')
    private String  inSrc;      // 매입단가 근거 ('이력'/'마스터')
    /* 출고미상(selectClosingUnmatched) 전용 — 정산서에는 있는데 출고 자료에 짝이 없는 행.
       마감은 출고에서 출발하므로 이 금액이 통째로 빠진다. 마감 화면에서 경고로 띄운다(2026-07-25). */
    private String  dlvDt;      // 납품일자 'yyyymmdd'
    private Double  settleQty;  // 정산수량

    public String getDlvDt() { return dlvDt; }
    public void setDlvDt(String dlvDt) { this.dlvDt = dlvDt; }
    public Double getSettleQty() { return settleQty; }
    public void setSettleQty(Double settleQty) { this.settleQty = settleQty; }
    public String getYm() { return ym; }
    public void setYm(String ym) { this.ym = ym; }
    public String getFromDt() { return fromDt; }
    public void setFromDt(String fromDt) { this.fromDt = fromDt; }
    public String getToDt() { return toDt; }
    public void setToDt(String toDt) { this.toDt = toDt; }
    public String getDcCd() { return dcCd; }
    public void setDcCd(String dcCd) { this.dcCd = dcCd; }
    public String getDcNm() { return dcNm; }
    public void setDcNm(String dcNm) { this.dcNm = dcNm; }
    public String getItemCd() { return itemCd; }
    public void setItemCd(String itemCd) { this.itemCd = itemCd; }
    public String getItemNm() { return itemNm; }
    public void setItemNm(String itemNm) { this.itemNm = itemNm; }
    public String getBizCd() { return bizCd; }
    public void setBizCd(String bizCd) { this.bizCd = bizCd; }
    public String getBizNm() { return bizNm; }
    public void setBizNm(String bizNm) { this.bizNm = bizNm; }
    public String getVendorCd() { return vendorCd; }
    public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
    public String getVendorNm() { return vendorNm; }
    public void setVendorNm(String vendorNm) { this.vendorNm = vendorNm; }
    public Integer getOutQty() { return outQty; }
    public void setOutQty(Integer outQty) { this.outQty = outQty; }
    public Double getSalesAmt() { return salesAmt; }
    public void setSalesAmt(Double salesAmt) { this.salesAmt = salesAmt; }
    public Double getCostAmt() { return costAmt; }
    public void setCostAmt(Double costAmt) { this.costAmt = costAmt; }
    public Double getMarginAmt() { return marginAmt; }
    public void setMarginAmt(Double marginAmt) { this.marginAmt = marginAmt; }
    public String getSaleSrc() { return saleSrc; }
    public void setSaleSrc(String saleSrc) { this.saleSrc = saleSrc; }
    public String getInSrc() { return inSrc; }
    public void setInSrc(String inSrc) { this.inSrc = inSrc; }
}
