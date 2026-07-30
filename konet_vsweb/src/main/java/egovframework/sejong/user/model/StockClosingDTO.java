package egovframework.sejong.user.model;

/**
 * 재고마감 집계 DTO  ←  TBL_STOCK_LEDGER (수불원장)
 *  · 기초수량 = 마감월 이전 누계(입고+반품 − 출고 ± 조정)
 *  · 입고/출고/조정 = 마감월 당월분
 *  · 기말수량 = 기초 + 입고 − 출고 + 조정
 *  · 이동평균단가 = 월말 시점까지 입고 가중평균(없으면 상품마스터 IN_PRICE) → 재고금액 = 기말 × 평균단가(클라이언트 계산)
 */
public class StockClosingDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

    private String  ym;          // 마감월(요청) 'YYYY-MM'
    private String  fromDt;      // 시작일자(요청, 있으면 기간 BETWEEN)
    private String  toDt;        // 종료일자(요청)
    private Long    prodSeq;
    private String  prodCd;
    private String  prodNm;
    private String  vendorCd;    // 매입처(입고마감 집계 기준)
    private Integer beginQty;    // 기초수량
    private Integer inQty;       // 당월 입고(+반품)
    private Integer outQty;      // 당월 출고
    private Integer adjQty;      // 당월 조정(±)
    private Integer endQty;      // 기말수량
    private Double  avgInPrice;  // 이동평균 매입단가(월말 기준)
    private Double  inAmt;       // 매입액(입고마감용) = Σ 입고금액

    public String getYm() { return ym; }
    public void setYm(String ym) { this.ym = ym; }
    public String getFromDt() { return fromDt; }
    public void setFromDt(String fromDt) { this.fromDt = fromDt; }
    public String getToDt() { return toDt; }
    public void setToDt(String toDt) { this.toDt = toDt; }
    public Long getProdSeq() { return prodSeq; }
    public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
    public String getProdCd() { return prodCd; }
    public void setProdCd(String prodCd) { this.prodCd = prodCd; }
    public String getProdNm() { return prodNm; }
    public void setProdNm(String prodNm) { this.prodNm = prodNm; }
    public String getVendorCd() { return vendorCd; }
    public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
    public Integer getBeginQty() { return beginQty; }
    public void setBeginQty(Integer beginQty) { this.beginQty = beginQty; }
    public Integer getInQty() { return inQty; }
    public void setInQty(Integer inQty) { this.inQty = inQty; }
    public Integer getOutQty() { return outQty; }
    public void setOutQty(Integer outQty) { this.outQty = outQty; }
    public Integer getAdjQty() { return adjQty; }
    public void setAdjQty(Integer adjQty) { this.adjQty = adjQty; }
    public Integer getEndQty() { return endQty; }
    public void setEndQty(Integer endQty) { this.endQty = endQty; }
    public Double getAvgInPrice() { return avgInPrice; }
    public void setAvgInPrice(Double avgInPrice) { this.avgInPrice = avgInPrice; }
    public Double getInAmt() { return inAmt; }
    public void setInAmt(Double inAmt) { this.inAmt = inAmt; }
}
