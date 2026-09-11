package egovframework.sejong.user.model;

import java.util.List;

/**
 * 매입 전표 헤더 DTO  →  TBL_PURCHASE_MST
 *  · 전표 1건 = 헤더 1행(이 DTO) + 명세 N행(PurchaseDtlDTO)
 *  · 저장하면 명세마다 TBL_STOCK_LEDGER(입고/반품)와 TBL_PROD_INPRICE_HST(매입단가 이력)가 파생 생성된다.
 *    → 재고현황·재고마감·매입마감·매출마감 원가가 별도 작업 없이 맞는다.
 *  · 전표번호 purchNo = 매입일자별 순번 '0001' (홀세일닥터와 같은 체계)
 *  · 조회 파라미터(fromDt/toDt/findData/mgrCd)는 비영속 — 목록 검색용
 */
public class PurchaseDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

    private Long    purchSeq;      // PK
    private String  purchDt;       // 매입일자 yyyymmdd (화면은 yyyy-mm-dd)
    private String  purchNo;       // 그날의 순번 '0001'
    private String  vendorCd;      // 거래처(매입처)
    private String  vendorNm;
    private String  mgrCd;         // 담당사원
    private String  mgrNm;
    private String  whCd;          // 창고
    private String  whNm;
    private Double  totBoxQty;     // 합계 BOX수량
    private Double  totEaQty;      // 합계 EA수량
    private Double  totQty;        // 합계수량
    private Double  supplyAmt;     // 공급가 합
    private Double  vatAmt;        // 부가세 합
    private Double  totAmt;        // 매입금액 합
    private Double  dcAmt;         // 할인액(헤더)
    private String  payGb;         // 지급구분 현금/카드/외상
    private Double  payAmt;        // 지급액
    private String  remark;        // 매입메모

    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    /** 명세 — 저장 시 화면에서 함께 올라오고, 상세조회 시 함께 내려간다 */
    private List<PurchaseDtlDTO> items;

    // ── 조회 파라미터 (비영속) ──
    private String  fromDt;        // 검색기간 시작
    private String  toDt;          // 검색기간 종료
    private String  findData;      // 거래처명 검색어
    private Integer prodCnt;       // 상품수(목록 표시용, 집계)

    public Long getPurchSeq() { return purchSeq; }
    public void setPurchSeq(Long purchSeq) { this.purchSeq = purchSeq; }
    public String getPurchDt() { return purchDt; }
    public void setPurchDt(String purchDt) { this.purchDt = purchDt; }
    public String getPurchNo() { return purchNo; }
    public void setPurchNo(String purchNo) { this.purchNo = purchNo; }
    public String getVendorCd() { return vendorCd; }
    public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
    public String getVendorNm() { return vendorNm; }
    public void setVendorNm(String vendorNm) { this.vendorNm = vendorNm; }
    public String getMgrCd() { return mgrCd; }
    public void setMgrCd(String mgrCd) { this.mgrCd = mgrCd; }
    public String getMgrNm() { return mgrNm; }
    public void setMgrNm(String mgrNm) { this.mgrNm = mgrNm; }
    public String getWhCd() { return whCd; }
    public void setWhCd(String whCd) { this.whCd = whCd; }
    public String getWhNm() { return whNm; }
    public void setWhNm(String whNm) { this.whNm = whNm; }
    public Double getTotBoxQty() { return totBoxQty; }
    public void setTotBoxQty(Double totBoxQty) { this.totBoxQty = totBoxQty; }
    public Double getTotEaQty() { return totEaQty; }
    public void setTotEaQty(Double totEaQty) { this.totEaQty = totEaQty; }
    public Double getTotQty() { return totQty; }
    public void setTotQty(Double totQty) { this.totQty = totQty; }
    public Double getSupplyAmt() { return supplyAmt; }
    public void setSupplyAmt(Double supplyAmt) { this.supplyAmt = supplyAmt; }
    public Double getVatAmt() { return vatAmt; }
    public void setVatAmt(Double vatAmt) { this.vatAmt = vatAmt; }
    public Double getTotAmt() { return totAmt; }
    public void setTotAmt(Double totAmt) { this.totAmt = totAmt; }
    public Double getDcAmt() { return dcAmt; }
    public void setDcAmt(Double dcAmt) { this.dcAmt = dcAmt; }
    public String getPayGb() { return payGb; }
    public void setPayGb(String payGb) { this.payGb = payGb; }
    public Double getPayAmt() { return payAmt; }
    public void setPayAmt(Double payAmt) { this.payAmt = payAmt; }
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
    public List<PurchaseDtlDTO> getItems() { return items; }
    public void setItems(List<PurchaseDtlDTO> items) { this.items = items; }
    public String getFromDt() { return fromDt; }
    public void setFromDt(String fromDt) { this.fromDt = fromDt; }
    public String getToDt() { return toDt; }
    public void setToDt(String toDt) { this.toDt = toDt; }
    public String getFindData() { return findData; }
    public void setFindData(String findData) { this.findData = findData; }
    public Integer getProdCnt() { return prodCnt; }
    public void setProdCnt(Integer prodCnt) { this.prodCnt = prodCnt; }
}
