package egovframework.sejong.user.model;

/**
 * 재고 수불원장 DTO  →  TBL_STOCK_LEDGER
 *  · 입/출/조정/반품 이동 1행. 현재고 = 원장 누계(TBL_STOCK_MST 로 집계)
 *  · IO_GB : 'I'=입고/매입(+), 'O'=출고/판매(-), 'R'=반품(+), 'A'=조정(±, QTY 부호 그대로)
 */
public class StockLedgerDTO {

    private Long    ledgerSeq;     // PK
    private Long    prodSeq;       // 품목마스터 PK
    private String  prodCd;        // 품목코드
    private String  prodNm;        // 품목명(조인) — 비영속
    private String  fromDt;        // 조회 시작일자 — 비영속
    private String  toDt;          // 조회 종료일자 — 비영속
    private String  findData;      // 검색어(품목/매입처) — 비영속
    private String  trxDt;         // 거래일자
    private String  ioGb;          // 입출구분 I/O/R/A
    private Integer qty;           // 수량(조정은 부호 허용)
    private Double  unitPrice;     // 단가
    private Double  amt;           // 금액
    private Integer balQty;        // 거래 후 잔량(스냅샷)
    private String  vendorCd;      // 매입처(입고)
    private String  bizCd;         // 사업장(출고)
    private String  refGb;         // 근거구분(SHIPOUT 등)
    private String  refNo;         // 근거번호
    private String  remark;
    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    public Long getLedgerSeq() { return ledgerSeq; }
    public void setLedgerSeq(Long ledgerSeq) { this.ledgerSeq = ledgerSeq; }
    public Long getProdSeq() { return prodSeq; }
    public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
    public String getProdCd() { return prodCd; }
    public void setProdCd(String prodCd) { this.prodCd = prodCd; }
    public String getProdNm() { return prodNm; }
    public void setProdNm(String prodNm) { this.prodNm = prodNm; }
    public String getFromDt() { return fromDt; }
    public void setFromDt(String fromDt) { this.fromDt = fromDt; }
    public String getToDt() { return toDt; }
    public void setToDt(String toDt) { this.toDt = toDt; }
    public String getFindData() { return findData; }
    public void setFindData(String findData) { this.findData = findData; }
    public String getTrxDt() { return trxDt; }
    public void setTrxDt(String trxDt) { this.trxDt = trxDt; }
    public String getIoGb() { return ioGb; }
    public void setIoGb(String ioGb) { this.ioGb = ioGb; }
    public Integer getQty() { return qty; }
    public void setQty(Integer qty) { this.qty = qty; }
    public Double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }
    public Double getAmt() { return amt; }
    public void setAmt(Double amt) { this.amt = amt; }
    public Integer getBalQty() { return balQty; }
    public void setBalQty(Integer balQty) { this.balQty = balQty; }
    public String getVendorCd() { return vendorCd; }
    public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
    public String getBizCd() { return bizCd; }
    public void setBizCd(String bizCd) { this.bizCd = bizCd; }
    public String getRefGb() { return refGb; }
    public void setRefGb(String refGb) { this.refGb = refGb; }
    public String getRefNo() { return refNo; }
    public void setRefNo(String refNo) { this.refNo = refNo; }
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
