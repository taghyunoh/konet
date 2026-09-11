package egovframework.sejong.user.model;

/**
 * 매입 전표 명세 DTO  →  TBL_PURCHASE_DTL
 *  · 전표 1건에 여러 행. 화면 그리드 한 줄 = 이 DTO 하나
 *  · 저장 시 이 행으로 TBL_STOCK_LEDGER(입고/반품) 한 줄이 파생 생성되고 그 PK를 ledgerSeq 에 남긴다
 *    (전표를 고치거나 지울 때 파생 원장까지 같이 처리하기 위한 역추적 키)
 *  · 합계수량 qty = boxQty * packQty + eaQty  (화면에서 계산해 내려보내되 서버에서도 검산)
 */
public class PurchaseDtlDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

    private Long    dtlSeq;        // PK
    private Long    purchSeq;      // 전표 헤더 PK
    private Integer rowNo;         // 화면 행번호(1부터)
    private Long    prodSeq;       // 품목마스터 PK
    private String  prodCd;        // 품목코드
    private String  prodNm;        // 품목명
    private String  spec;          // [입수량]규격
    private Double  packQty;       // 입수량 — BOX→합계수량 환산 근거
    private Double  boxQty;        // BOX수량
    private Double  eaQty;         // EA수량(낱개)
    private Double  qty;           // 합계수량
    private Double  unitPrice;     // 단가
    private Double  amt;           // 금액 = 합계수량 × 단가
    private Double  dcAmt;         // 행 DC
    private Double  supplyAmt;     // 공급가
    private Double  vatAmt;        // 부가세
    private Double  totAmt;        // 매입금액 = 공급가 + 부가세
    private Double  serviceQty;    // 서비스(무상수량)
    private String  remark;        // 비고
    private String  eventYn;       // 행사 Y/N
    private String  trxGb;         // 거래구분 '매입' / '반품'
    private Long    ledgerSeq;     // 이 행이 만든 TBL_STOCK_LEDGER PK

    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    public Long getDtlSeq() { return dtlSeq; }
    public void setDtlSeq(Long dtlSeq) { this.dtlSeq = dtlSeq; }
    public Long getPurchSeq() { return purchSeq; }
    public void setPurchSeq(Long purchSeq) { this.purchSeq = purchSeq; }
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
