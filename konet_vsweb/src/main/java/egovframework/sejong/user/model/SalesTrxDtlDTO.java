package egovframework.sejong.user.model;

/**
 * 판매 전표 명세 DTO  →  TBL_SALES_TRX_DTL
 *  · 매입 명세(PurchaseDtlDTO)와 컬럼이 같다. 한 줄 = 품목 하나.
 *  · qty = boxQty * packQty + eaQty (박스 × 입수 + 낱개)
 *  · trxGb : '판매' | '반품'. 반품이면 재고원장 수량이 반대로 들어간다.
 *  · ledgerSeq : 저장할 때 파생 생성한 TBL_STOCK_LEDGER 행. 수정/삭제 때 되짚는다.
 *  · 단가이력 팝업은 이 DTO를 재사용한다 — spec 칸에 거래일자, prodNm 칸에 거래처명을
 *    담아 보낸다(매입 쪽 selectPurchasePriceHist 와 같은 방식).
 */
public class SalesTrxDtlDTO {

    private Long    dtlSeq;        // PK
    private Long    saleSeq;       // → TBL_SALES_TRX_MST.SALE_SEQ
    private Integer rowNo;         // 명세 줄번호
    private Long    prodSeq;
    private String  prodCd;
    private String  prodNm;
    private String  spec;
    private Double  packQty;       // 입수
    private Double  boxQty;
    private Double  eaQty;
    private Double  qty;           // 총수량
    private Double  unitPrice;     // 판매단가
    private Double  amt;
    private Double  dcAmt;
    private Double  supplyAmt;
    private Double  vatAmt;
    private Double  totAmt;
    private Double  serviceQty;    // 서비스(무상) 수량
    private String  remark;        // ★ 단가 조회 시에는 거래처코드를 담아 보낸다(매입과 같은 방식)
    private String  eventYn;
    private String  trxGb;         // 판매 | 반품
    private Long    ledgerSeq;     // 파생 재고원장 행

    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    public Long getDtlSeq() { return dtlSeq; }
    public void setDtlSeq(Long dtlSeq) { this.dtlSeq = dtlSeq; }
    public Long getSaleSeq() { return saleSeq; }
    public void setSaleSeq(Long saleSeq) { this.saleSeq = saleSeq; }
    public Integer getRowNo() { return rowNo; }
    public void setRowNo(Integer rowNo) { this.rowNo = rowNo; }
    public Long getProdSeq() { return prodSeq; }
    public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
    public String getProdCd() { return prodCd; }
    public void setProdCd(String prodCd) { this.prodCd = prodCd; }
    public String getProdNm() { return prodNm; }
    public void setProdNm(String prodNm) { this.prodNm = prodNm; }
    public String getSpec() { return spec; }
    public void setSpec(String spec) { this.spec = spec; }
    public Double getPackQty() { return packQty; }
    public void setPackQty(Double packQty) { this.packQty = packQty; }
    public Double getBoxQty() { return boxQty; }
    public void setBoxQty(Double boxQty) { this.boxQty = boxQty; }
    public Double getEaQty() { return eaQty; }
    public void setEaQty(Double eaQty) { this.eaQty = eaQty; }
    public Double getQty() { return qty; }
    public void setQty(Double qty) { this.qty = qty; }
    public Double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }
    public Double getAmt() { return amt; }
    public void setAmt(Double amt) { this.amt = amt; }
    public Double getDcAmt() { return dcAmt; }
    public void setDcAmt(Double dcAmt) { this.dcAmt = dcAmt; }
    public Double getSupplyAmt() { return supplyAmt; }
    public void setSupplyAmt(Double supplyAmt) { this.supplyAmt = supplyAmt; }
    public Double getVatAmt() { return vatAmt; }
    public void setVatAmt(Double vatAmt) { this.vatAmt = vatAmt; }
    public Double getTotAmt() { return totAmt; }
    public void setTotAmt(Double totAmt) { this.totAmt = totAmt; }
    public Double getServiceQty() { return serviceQty; }
    public void setServiceQty(Double serviceQty) { this.serviceQty = serviceQty; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public String getEventYn() { return eventYn; }
    public void setEventYn(String eventYn) { this.eventYn = eventYn; }
    public String getTrxGb() { return trxGb; }
    public void setTrxGb(String trxGb) { this.trxGb = trxGb; }
    public Long getLedgerSeq() { return ledgerSeq; }
    public void setLedgerSeq(Long ledgerSeq) { this.ledgerSeq = ledgerSeq; }
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
