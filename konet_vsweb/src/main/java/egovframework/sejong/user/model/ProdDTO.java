package egovframework.sejong.user.model;

/**
 * 상품마스터 DTO  →  TBL_PROD_MST
 *  · PK = PROD_SEQ(IDENTITY). 코드(PROD_CD)는 중복 가능하므로 수정/삭제는 PROD_SEQ 기준
 *  · 날짜(REG_DTTM/UPD_DTTM)는 문자열 저장
 */
public class ProdDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

    private Long    prodSeq;       // 대체키(PK)
    private String  prodCd;        // 코드
    private String  prodNm;        // 상품명
    private String  spec;          // 규격
    private String  makerNm;       // 제조사명
    private String  typeNm;        // 유형명
    private Integer sortOrd;       // 조회순서
    private String  taxGb;         // 과세('과세'/'면세')
    private Integer packQty;       // 입수수량
    private Double  inPrice;       // 입고단가
    private Double  salePrice;     // 판매단가
    private Double  wholePrice;    // 도매단가
    private Integer safeStock;     // 적정재고
    private Integer saleBaseQty;   // 판매기본수량
    private String  unitBarcode;   // 낱개바코드
    private String  boxBarcode;    // 박스바코드

    private String  actionYn;      // 'Y'=활성 / 'N'=삭제
    private String  regDttm;       // 등록일시(문자)
    private String  regUser;
    private String  regIp;
    private String  updDttm;       // 수정일시(문자)
    private String  updUser;
    private String  updIp;


    /* ★거래중지 (2026-08-17) — 삭제할 수 없는(거래가 붙은) 코드를 「앞으로 안 쓰는 코드」로 표시한다.
       ⚠ACTION_YN(삭제)과 축이 다르다 : 중지는 목록에 보이고 **새 거래만** 막힌다.
       ⚠막을 때 견주는 것은 stopFrDt 와 **전표일자**다(오늘 날짜가 아니다 — 지난 일자 전표가 있다). */
    private String  stopYn;        // 'Y' = 거래중지
    private String  stopFrDt;      // 중지 시작일(YYYYMMDD) — 이 날짜부터 새 거래를 막는다
    private String  stopDttm;      // 중지 처리한 시각(감사 기록)
    private String  stopUser;
    private String  stopMemo;      // 사유 (예: "9904013214 로 대체")
    private String  findData;      // 검색어(코드/상품명/규격/제조사)

    public Long getProdSeq() { return prodSeq; }
    public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
    public String getProdCd() { return prodCd; }
    public void setProdCd(String prodCd) { this.prodCd = prodCd; }
    public String getProdNm() { return prodNm; }
    public void setProdNm(String prodNm) { this.prodNm = prodNm; }
    public String getSpec() { return spec; }
    public void setSpec(String spec) { this.spec = spec; }
    public String getMakerNm() { return makerNm; }
    public void setMakerNm(String makerNm) { this.makerNm = makerNm; }
    public String getTypeNm() { return typeNm; }
    public void setTypeNm(String typeNm) { this.typeNm = typeNm; }
    public Integer getSortOrd() { return sortOrd; }
    public void setSortOrd(Integer sortOrd) { this.sortOrd = sortOrd; }
    public String getTaxGb() { return taxGb; }
    public void setTaxGb(String taxGb) { this.taxGb = taxGb; }
    public Integer getPackQty() { return packQty; }
    public void setPackQty(Integer packQty) { this.packQty = packQty; }
    public Double getInPrice() { return inPrice; }
    public void setInPrice(Double inPrice) { this.inPrice = inPrice; }
    public Double getSalePrice() { return salePrice; }
    public void setSalePrice(Double salePrice) { this.salePrice = salePrice; }
    public Double getWholePrice() { return wholePrice; }
    public void setWholePrice(Double wholePrice) { this.wholePrice = wholePrice; }
    public Integer getSafeStock() { return safeStock; }
    public void setSafeStock(Integer safeStock) { this.safeStock = safeStock; }
    public Integer getSaleBaseQty() { return saleBaseQty; }
    public void setSaleBaseQty(Integer saleBaseQty) { this.saleBaseQty = saleBaseQty; }
    public String getUnitBarcode() { return unitBarcode; }
    public void setUnitBarcode(String unitBarcode) { this.unitBarcode = unitBarcode; }
    public String getBoxBarcode() { return boxBarcode; }
    public void setBoxBarcode(String boxBarcode) { this.boxBarcode = boxBarcode; }
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
    public String getFindData() { return findData; }
    public void setFindData(String findData) { this.findData = findData; }

    public String getStopYn() { return stopYn; }
    public void setStopYn(String stopYn) { this.stopYn = stopYn; }
    public String getStopFrDt() { return stopFrDt; }
    public void setStopFrDt(String stopFrDt) { this.stopFrDt = stopFrDt; }
    public String getStopDttm() { return stopDttm; }
    public void setStopDttm(String stopDttm) { this.stopDttm = stopDttm; }
    public String getStopUser() { return stopUser; }
    public void setStopUser(String stopUser) { this.stopUser = stopUser; }
    public String getStopMemo() { return stopMemo; }
    public void setStopMemo(String stopMemo) { this.stopMemo = stopMemo; }
}
