package egovframework.sejong.user.model;

/**
 * 납품분(그 거래처에 이미 나간 품목) 조회 · 납품분 제외 DTO   (2026-07-31 신설)
 *
 *  · 조회 원천은 둘이다 — 판매전표(TBL_SALES_TRX_DTL) + 정산서(TBL_SALES_MST).
 *    상품코드로 중복을 없애고 '가장 최근 거래' 한 줄만 남긴다(단가·일자는 그 최근 건 기준).
 *  · 제외는 거래처별(TBL_SALES_DLV_EXCL). DDL : sql/sales_dlv_excl_ddl.sql
 *  · srcGb : '전표' | '정산서' — 그 품목의 가장 최근 거래가 어디서 왔는지
 *  · curQty: 현재고(수불원장 집계). 음수면 입고 없이 나간 것 — 원본 화면도 빨갛게 보여준다.
 */
public class SalesDlvDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

	// ----- 키 -----
	private Long   exclSeq;      // TBL_SALES_DLV_EXCL PK
	private String custCd;       // 거래처(매출처)
	private String custNm;
	private Long   prodSeq;
	private String prodCd;
	private String prodNm;

	// ----- 표시 -----
	private String spec;         // 규격
	private String makerNm;      // 제조사
	private Double packQty;      // 입수
	private String taxGb;        // 과세/면세
	private Double unitPrice;    // 최근 거래단가
	private Double qty;          // 최근 거래수량
	private Double curQty;       // 현재고
	private String lastDt;       // 최근 거래일자 yyyymmdd
	private Integer cnt;         // 거래 횟수
	private String srcGb;        // 전표 / 정산서
	private String reason;       // 제외 사유
	private String regDttm;

	// ----- 조회 조건 -----
	private String findData;     // 상품코드·상품명 검색어
	private String fromDt;       // 이 일자 이후 거래만 (비우면 전체)
	private String srcFilter;    // '' 전체 / 'TRX' 판매전표만 / 'MST' 정산서만
	private String actionYn;     // 제외 켜기 'Y' / 해제 'N'
	private String gb;           // 제외 구분 — 'S' 판매(납품분) / 'P' 매입(매입분). 비우면 'S'

	// ----- 감사 -----
	private String regUser;
	private String regIp;
	private String updUser;
	private String updIp;

	public Long   getExclSeq() { return exclSeq; }
	public void   setExclSeq(Long exclSeq) { this.exclSeq = exclSeq; }
	public String getCustCd() { return custCd; }
	public void   setCustCd(String custCd) { this.custCd = custCd; }
	public String getCustNm() { return custNm; }
	public void   setCustNm(String custNm) { this.custNm = custNm; }
	public Long   getProdSeq() { return prodSeq; }
	public void   setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
	public String getProdCd() { return prodCd; }
	public void   setProdCd(String prodCd) { this.prodCd = prodCd; }
	public String getProdNm() { return prodNm; }
	public void   setProdNm(String prodNm) { this.prodNm = prodNm; }
	public String getSpec() { return spec; }
	public void   setSpec(String spec) { this.spec = spec; }
	public String getMakerNm() { return makerNm; }
	public void   setMakerNm(String makerNm) { this.makerNm = makerNm; }
	public Double getPackQty() { return packQty; }
	public void   setPackQty(Double packQty) { this.packQty = packQty; }
	public String getTaxGb() { return taxGb; }
	public void   setTaxGb(String taxGb) { this.taxGb = taxGb; }
	public Double getUnitPrice() { return unitPrice; }
	public void   setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }
	public Double getQty() { return qty; }
	public void   setQty(Double qty) { this.qty = qty; }
	public Double getCurQty() { return curQty; }
	public void   setCurQty(Double curQty) { this.curQty = curQty; }
	public String getLastDt() { return lastDt; }
	public void   setLastDt(String lastDt) { this.lastDt = lastDt; }
	public Integer getCnt() { return cnt; }
	public void   setCnt(Integer cnt) { this.cnt = cnt; }
	public String getSrcGb() { return srcGb; }
	public void   setSrcGb(String srcGb) { this.srcGb = srcGb; }
	public String getReason() { return reason; }
	public void   setReason(String reason) { this.reason = reason; }
	public String getRegDttm() { return regDttm; }
	public void   setRegDttm(String regDttm) { this.regDttm = regDttm; }
	public String getFindData() { return findData; }
	public void   setFindData(String findData) { this.findData = findData; }
	public String getFromDt() { return fromDt; }
	public void   setFromDt(String fromDt) { this.fromDt = fromDt; }
	public String getSrcFilter() { return srcFilter; }
	public void   setSrcFilter(String srcFilter) { this.srcFilter = srcFilter; }
	public String getActionYn() { return actionYn; }
	public void   setActionYn(String actionYn) { this.actionYn = actionYn; }
	public String getGb() { return gb; }
	public void   setGb(String gb) { this.gb = gb; }
	public String getRegUser() { return regUser; }
	public void   setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void   setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdUser() { return updUser; }
	public void   setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void   setUpdIp(String updIp) { this.updIp = updIp; }
}
