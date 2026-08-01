package egovframework.sejong.user.model;

/**
 * 거래처 통보품목 DTO  →  TBL_EXT_ITEM_MST
 *
 *  거래처(삼성웰스토리 등)가 **미리 통보해 주는** 품목코드·품목명을 원문 그대로 받아 두는 접수대장.
 *  종전에는 발주현황표를 올리는 순간에야 처음 보는 코드를 만났고, 그 자리에서 연결해야 했다.
 *
 *  ★이 표는 매핑 표가 아니다 — 여기 등록해도 상품마스터(TBL_PROD_MST)에 상품이 생기지 않고
 *    재고·원가와도 무관하다. 우리 품목과 이어 붙이는 방식은 **다음에 결정**한다(2026-08-01 사용자 확정).
 *    그래서 prodSeq/prodCd/xrefSeq 는 칸만 있고 채우는 로직이 없다.
 *
 *  ★TBL_PROD_XREF 와 섞지 말 것 : XREF = 확정 연결(재고·출고서가 본다) / 이 표 = 통보 원문 접수.
 *  · DDL : sql/ext_item_ddl.sql
 */
public class ExtItemDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

	private Long    extSeq;       // PK

	private String  vendorCd;     // 통보한 거래처코드. 빈값 = 거래처 안 가림(공통)
	private String  vendorNm;     // 거래처명(가독용 사본)
	private String  dcCd;         // 출고장코드(통보가 출고장까지 지정한 경우만)
	private String  dcNm;

	private String  extItemCd;    // ★통보 품목코드 (원문 그대로)
	private String  extItemNm;    // ★통보 품목명   (원문 그대로)
	private String  extSpec;      // 규격
	private String  extUnit;      // 단위('BOX' 등)
	private Double  extPrice;     // 단가 — 나중 매핑 대조에 가장 쓸모 있는 값
	private String  taxGb;        // 과세/면세

	private String  notiDt;       // 통보받은 날 (YYYYMMDD)
	private String  useFrDt;      // 적용 시작일
	private String  statGb;       // 통보 구분 : 신규 / 변경 / 중단

	// ----- 매핑 자리 (방식은 추후 결정 — 지금은 저장/표시만) -----
	private Long    prodSeq;
	private String  prodCd;
	private String  prodNm;       // 조회 시 조인해서 채운다(저장 컬럼 아님)
	private Long    xrefSeq;

	private String  remark;
	private String  actionYn;
	private String  regDttm;
	private String  regUser;
	private String  regIp;
	private String  updDttm;
	private String  updUser;
	private String  updIp;

	// ----- 조회 파라미터 (비영속) -----
	private String  findData;     // 검색어(코드·품명·거래처)
	private String  fromDt;       // 통보일자 범위
	private String  toDt;

	public Long getExtSeq() { return extSeq; }
	public void setExtSeq(Long extSeq) { this.extSeq = extSeq; }
	public String getVendorCd() { return vendorCd; }
	public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
	public String getVendorNm() { return vendorNm; }
	public void setVendorNm(String vendorNm) { this.vendorNm = vendorNm; }
	public String getDcCd() { return dcCd; }
	public void setDcCd(String dcCd) { this.dcCd = dcCd; }
	public String getDcNm() { return dcNm; }
	public void setDcNm(String dcNm) { this.dcNm = dcNm; }
	public String getExtItemCd() { return extItemCd; }
	public void setExtItemCd(String extItemCd) { this.extItemCd = extItemCd; }
	public String getExtItemNm() { return extItemNm; }
	public void setExtItemNm(String extItemNm) { this.extItemNm = extItemNm; }
	public String getExtSpec() { return extSpec; }
	public void setExtSpec(String extSpec) { this.extSpec = extSpec; }
	public String getExtUnit() { return extUnit; }
	public void setExtUnit(String extUnit) { this.extUnit = extUnit; }
	public Double getExtPrice() { return extPrice; }
	public void setExtPrice(Double extPrice) { this.extPrice = extPrice; }
	public String getTaxGb() { return taxGb; }
	public void setTaxGb(String taxGb) { this.taxGb = taxGb; }
	public String getNotiDt() { return notiDt; }
	public void setNotiDt(String notiDt) { this.notiDt = notiDt; }
	public String getUseFrDt() { return useFrDt; }
	public void setUseFrDt(String useFrDt) { this.useFrDt = useFrDt; }
	public String getStatGb() { return statGb; }
	public void setStatGb(String statGb) { this.statGb = statGb; }
	public Long getProdSeq() { return prodSeq; }
	public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
	public String getProdCd() { return prodCd; }
	public void setProdCd(String prodCd) { this.prodCd = prodCd; }
	public String getProdNm() { return prodNm; }
	public void setProdNm(String prodNm) { this.prodNm = prodNm; }
	public Long getXrefSeq() { return xrefSeq; }
	public void setXrefSeq(Long xrefSeq) { this.xrefSeq = xrefSeq; }
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
	public String getFindData() { return findData; }
	public void setFindData(String findData) { this.findData = findData; }
	public String getFromDt() { return fromDt; }
	public void setFromDt(String fromDt) { this.fromDt = fromDt; }
	public String getToDt() { return toDt; }
	public void setToDt(String toDt) { this.toDt = toDt; }
}
