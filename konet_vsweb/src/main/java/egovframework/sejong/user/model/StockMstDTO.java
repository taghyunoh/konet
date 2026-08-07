package egovframework.sejong.user.model;

/**
 * 재고 현황(현재고) DTO  →  TBL_STOCK_MST
 *  · 품목당 1행. 원장(TBL_STOCK_LEDGER) 이동 시 재집계되는 현재고 스냅샷
 */
public class StockMstDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

    private Long    stockSeq;      // PK
    private Long    prodSeq;       // 품목마스터 PK (UNIQUE)
    private String  prodCd;        // 품목코드
    private String  prodNm;        // 품목명(조인)
    private String  extQtys;       // 매칭코드별 출고수량 "코드:수량|코드:수량" — 화면이 ↳ 줄에 붙인다(2026-08-07)
    private String  findData;      // 검색어(코드/품목명) — 비영속
    private String  asOfDt;        // 기준일(종료일) — 비우면 전체(현재고), 넣으면 그 날짜까지 누계(재고마감 기말과 대사) — 비영속
    private Integer curQty;        // 현재고 수량 = 입고누계 − 출고누계
    private Integer inQty;         // 입고누계(수불원장)
    private Integer outQty;        // 출고누계(TBL_SHIPOUT_MST)
    private Double  avgInPrice;    // 이동평균 매입단가
    private Double  lastInprice;   // 최근 매입단가
    private Double  lastSaleprice; // 최근 판매단가
    private Double  stockAmt;      // 재고금액
    private String  lastInDt;      // 최근 입고일자
    private String  lastOutDt;     // 최근 출고일자
    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    public Long getStockSeq() { return stockSeq; }
    public void setStockSeq(Long stockSeq) { this.stockSeq = stockSeq; }
    public Long getProdSeq() { return prodSeq; }
    public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
    public String getProdCd() { return prodCd; }
    public void setProdCd(String prodCd) { this.prodCd = prodCd; }
    public String getExtQtys() { return extQtys; }
    public void setExtQtys(String extQtys) { this.extQtys = extQtys; }
    public String getProdNm() { return prodNm; }
    public void setProdNm(String prodNm) { this.prodNm = prodNm; }
    public String getFindData() { return findData; }
    public void setFindData(String findData) { this.findData = findData; }
    public String getAsOfDt() { return asOfDt; }
    public void setAsOfDt(String asOfDt) { this.asOfDt = asOfDt; }
    public Integer getCurQty() { return curQty; }
    public void setCurQty(Integer curQty) { this.curQty = curQty; }
    public Integer getInQty() { return inQty; }
    public void setInQty(Integer inQty) { this.inQty = inQty; }
    public Integer getOutQty() { return outQty; }
    public void setOutQty(Integer outQty) { this.outQty = outQty; }
    public Double getAvgInPrice() { return avgInPrice; }
    public void setAvgInPrice(Double avgInPrice) { this.avgInPrice = avgInPrice; }
    public Double getLastInprice() { return lastInprice; }
    public void setLastInprice(Double lastInprice) { this.lastInprice = lastInprice; }
    public Double getLastSaleprice() { return lastSaleprice; }
    public void setLastSaleprice(Double lastSaleprice) { this.lastSaleprice = lastSaleprice; }
    public Double getStockAmt() { return stockAmt; }
    public void setStockAmt(Double stockAmt) { this.stockAmt = stockAmt; }
    public String getLastInDt() { return lastInDt; }
    public void setLastInDt(String lastInDt) { this.lastInDt = lastInDt; }
    public String getLastOutDt() { return lastOutDt; }
    public void setLastOutDt(String lastOutDt) { this.lastOutDt = lastOutDt; }
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
