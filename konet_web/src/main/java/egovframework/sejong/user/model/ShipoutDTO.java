package egovframework.sejong.user.model;

/**
 * 출고장(발주현황표) 업로드 저장 DTO  →  TBL_SHIPOUT_MST
 *  · 논리키: dlvDt(납기일자) , 버전: jobSeq , 활성/이력: actionYn ('Y'/'N')
 *  · 날짜(dlvDt)는 NVARCHAR(10) 문자 저장. INSERT/WHERE 에서 '-' 제거 처리(REPLACE)
 */
public class ShipoutDTO {

	// ----- 버전·이력 메타 -----
	private Integer jobSeq;        // 업로드(배치) 버전
	private String  actionYn;      // 'Y'=활성 / 'N'=이력(삭제)
	private Integer rowNo;         // 배치 내 행번호(엑셀 No)
	private String  srcFile;       // 원본 엑셀 파일명

	// ----- 엑셀 본문 -----
	private String  inrsvYn;       // 입고예약
	private String  labelPrtGb;    // 라벨발행구분
	private String  dcCd;          // 물류센터코드
	private String  dcNm;          // 물류센터명
	private String  vendorCd;      // 협력업체코드
	private String  vendorNm;      // 협력업체명
	private String  itemCd;        // 품목코드
	private String  itemNm;        // 품목명
	private String  fsfdGb;        // FS/FD 구분
	private String  dlvDt;         // 납기일자
	private String  statYn;        // 상황여부
	private String  prodKind;      // 상품종류
	private String  tempGb;        // 온도구분
	private String  ordGb;         // 발주구분
	private String  bizCd;         // 사업장코드
	private String  bizNm;         // 사업장명
	private Integer boxQty;        // Box입수량
	private Integer labelQty;      // 라벨수량
	private Integer unpaidLabelQty;// 미납라벨수량
	// 현 발주
	private String  inwh;          // 입고장
	private String  zone;          // 존
	private String  busNo;         // 버스번호
	private String  rtSeq;         // RT순번
	private Integer curQty;        // 수량
	private String  dlvGb;         // 배송구분
	private String  remark;        // 특기사항
	// 발주/주문
	private String  unit;          // 단위
	private String  indivId;       // 개체식별번호
	private String  ordNo;         // 발주번호
	private String  ordItemNo;     // 발주ITEM번호
	private String  jumunNo;       // 주문번호
	private String  jumunItemNo;   // 주문ITEM번호
	private String  sorter;        // 소터

	// ----- 감사 -----
	private String  regUser;
	private String  regIp;
	private String  updUser;
	private String  updIp;

	public Integer getJobSeq() { return jobSeq; }
	public void setJobSeq(Integer jobSeq) { this.jobSeq = jobSeq; }
	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }
	public Integer getRowNo() { return rowNo; }
	public void setRowNo(Integer rowNo) { this.rowNo = rowNo; }
	public String getSrcFile() { return srcFile; }
	public void setSrcFile(String srcFile) { this.srcFile = srcFile; }

	public String getInrsvYn() { return inrsvYn; }
	public void setInrsvYn(String inrsvYn) { this.inrsvYn = inrsvYn; }
	public String getLabelPrtGb() { return labelPrtGb; }
	public void setLabelPrtGb(String labelPrtGb) { this.labelPrtGb = labelPrtGb; }
	public String getDcCd() { return dcCd; }
	public void setDcCd(String dcCd) { this.dcCd = dcCd; }
	public String getDcNm() { return dcNm; }
	public void setDcNm(String dcNm) { this.dcNm = dcNm; }
	public String getVendorCd() { return vendorCd; }
	public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
	public String getVendorNm() { return vendorNm; }
	public void setVendorNm(String vendorNm) { this.vendorNm = vendorNm; }
	public String getItemCd() { return itemCd; }
	public void setItemCd(String itemCd) { this.itemCd = itemCd; }
	public String getItemNm() { return itemNm; }
	public void setItemNm(String itemNm) { this.itemNm = itemNm; }
	public String getFsfdGb() { return fsfdGb; }
	public void setFsfdGb(String fsfdGb) { this.fsfdGb = fsfdGb; }
	public String getDlvDt() { return dlvDt; }
	public void setDlvDt(String dlvDt) { this.dlvDt = dlvDt; }
	public String getStatYn() { return statYn; }
	public void setStatYn(String statYn) { this.statYn = statYn; }
	public String getProdKind() { return prodKind; }
	public void setProdKind(String prodKind) { this.prodKind = prodKind; }
	public String getTempGb() { return tempGb; }
	public void setTempGb(String tempGb) { this.tempGb = tempGb; }
	public String getOrdGb() { return ordGb; }
	public void setOrdGb(String ordGb) { this.ordGb = ordGb; }
	public String getBizCd() { return bizCd; }
	public void setBizCd(String bizCd) { this.bizCd = bizCd; }
	public String getBizNm() { return bizNm; }
	public void setBizNm(String bizNm) { this.bizNm = bizNm; }
	public Integer getBoxQty() { return boxQty; }
	public void setBoxQty(Integer boxQty) { this.boxQty = boxQty; }
	public Integer getLabelQty() { return labelQty; }
	public void setLabelQty(Integer labelQty) { this.labelQty = labelQty; }
	public Integer getUnpaidLabelQty() { return unpaidLabelQty; }
	public void setUnpaidLabelQty(Integer unpaidLabelQty) { this.unpaidLabelQty = unpaidLabelQty; }
	public String getInwh() { return inwh; }
	public void setInwh(String inwh) { this.inwh = inwh; }
	public String getZone() { return zone; }
	public void setZone(String zone) { this.zone = zone; }
	public String getBusNo() { return busNo; }
	public void setBusNo(String busNo) { this.busNo = busNo; }
	public String getRtSeq() { return rtSeq; }
	public void setRtSeq(String rtSeq) { this.rtSeq = rtSeq; }
	public Integer getCurQty() { return curQty; }
	public void setCurQty(Integer curQty) { this.curQty = curQty; }
	public String getDlvGb() { return dlvGb; }
	public void setDlvGb(String dlvGb) { this.dlvGb = dlvGb; }
	public String getRemark() { return remark; }
	public void setRemark(String remark) { this.remark = remark; }
	public String getUnit() { return unit; }
	public void setUnit(String unit) { this.unit = unit; }
	public String getIndivId() { return indivId; }
	public void setIndivId(String indivId) { this.indivId = indivId; }
	public String getOrdNo() { return ordNo; }
	public void setOrdNo(String ordNo) { this.ordNo = ordNo; }
	public String getOrdItemNo() { return ordItemNo; }
	public void setOrdItemNo(String ordItemNo) { this.ordItemNo = ordItemNo; }
	public String getJumunNo() { return jumunNo; }
	public void setJumunNo(String jumunNo) { this.jumunNo = jumunNo; }
	public String getJumunItemNo() { return jumunItemNo; }
	public void setJumunItemNo(String jumunItemNo) { this.jumunItemNo = jumunItemNo; }
	public String getSorter() { return sorter; }
	public void setSorter(String sorter) { this.sorter = sorter; }

	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }
}
