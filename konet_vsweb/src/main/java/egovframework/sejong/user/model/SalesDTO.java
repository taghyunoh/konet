package egovframework.sejong.user.model;

import java.math.BigDecimal;

/**
 * 매출(판매) 확정내역 — 출고장 제공 엑셀 업로드 저장 DTO  →  TBL_SALES_MST
 *
 *  ★관점 주의 : 엑셀은 '출고장 기준'으로 쓰여 있어 우리 기준으로 뒤집어 담는다.
 *      엑셀 '입고량'   = 우리 출고량    → outQty
 *      엑셀 '단가'     = 우리 판매단가  → salePrice
 *      엑셀 '매입금액' = 우리 매출액    → saleAmt
 *      엑셀 '입고일자' = 우리 출고일자  → outDt
 *    우리 매입가(공급업체→우리)는 이 DTO와 무관 — TBL_PROD_MST.IN_PRICE 계열이 계속 담당한다.
 *
 *  · 낱알 = 발주번호(ordNo) + 발주항번(ordItemNo) — TBL_SHIPOUT_MST 의 ORD_NO+ORD_ITEM_NO 와 동일
 *  · 배치·이력 복합키 = (dlvDt 납품일자 + dcNm 출고장) , 버전 jobSeq , 활성/이력 actionYn ('Y'/'N')
 *  · 날짜(dlvDt/outDt)는 'yyyy-mm-dd' 문자로 받아 매퍼에서 '-' 제거(REPLACE) 후 NVARCHAR(8) 저장
 *  · 수량은 소수·음수가 온다(발주량 0.49 / 출고량 -0.49 반품행) → Integer 금지, BigDecimal 사용
 */
public class SalesDTO {

	// ----- 배치·이력 메타 -----
	private Integer    salesSeq;      // PK
	private Integer    jobSeq;        // 업로드(배치) 버전
	private String     actionYn;      // 'Y'=활성 / 'N'=이력
	private Integer    rowNo;         // 엑셀 No
	private String     srcFile;       // 원본 엑셀 파일명
	private String     uploadDttm;    // 업로드 일시 — 조회 시 CONVERT(varchar(19),UPLOAD_DTTM,120)

	// ----- 출고장(파일명에서 확보) -----
	private String     dcCd;          // 물류센터코드(선택)
	private String     dcNm;          // 출고장명(평택/오산/왜관/용인) — 배치키

	// ----- 엑셀 본문 (우리 관점) -----
	private String     ordNo;         // 발주번호
	private String     ordItemNo;     // 발주항번
	private String     itemCd;        // 품목코드
	private String     itemNm;        // 품목명
	private String     spec;          // 규격
	private String     unit;          // 단위
	private BigDecimal ordQty;        // 발주량
	private BigDecimal settleQty;     // 정산수량
	private BigDecimal settleAmt;     // 정산금액
	private String     dlvDt;         // 납품일자 — 배치키
	private String     outDt;         // 우리 출고일자   ← 엑셀 '입고일자'
	private BigDecimal outQty;        // 우리 출고량     ← 엑셀 '입고량' (음수=반품)
	private BigDecimal salePrice;     // 우리 판매단가   ← 엑셀 '단가'
	private BigDecimal saleAmt;       // 우리 매출액     ← 엑셀 '매입금액'
	private String     dlvType;       // 납품유형
	private String     taxGb;         // 면과세 구분

	// ----- 조회 전용(비영속) -----
	private String     dlvDtFrom;     // 기간조회 시작일 — 값 있으면 DLV_DT BETWEEN 조회
	private String     dlvDtTo;       // 기간조회 종료일

	/* ----- 출고장 정정 전용(비영속) — 2026-07-27 -----
	   엑셀 파일명에서 잘못 딴 출고장(예: '15.24.')이 그대로 저장된 지난 자료를 바로잡는다.
	   배치키가 (DLV_DT + DC_NM) 이라 이름을 바꾸는 것이 곧 그 배치를 옮기는 것 →
	   dcNm(현재값)으로 찾아 newDcNm/newDcCd 로 갱신한다. 행수·금액은 건드리지 않는다. */
	private String     newDcNm;       // 바꿀 출고장명
	private String     newDcCd;       // 바꿀 물류센터코드(이름으로 판정한 값)

	// ----- 감사 -----
	private String     regUser;
	private String     regIp;
	private String     updUser;
	private String     updIp;

	public Integer getSalesSeq() { return salesSeq; }
	public void setSalesSeq(Integer salesSeq) { this.salesSeq = salesSeq; }
	public Integer getJobSeq() { return jobSeq; }
	public void setJobSeq(Integer jobSeq) { this.jobSeq = jobSeq; }
	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }
	public Integer getRowNo() { return rowNo; }
	public void setRowNo(Integer rowNo) { this.rowNo = rowNo; }
	public String getSrcFile() { return srcFile; }
	public void setSrcFile(String srcFile) { this.srcFile = srcFile; }
	public String getUploadDttm() { return uploadDttm; }
	public void setUploadDttm(String uploadDttm) { this.uploadDttm = uploadDttm; }

	public String getDcCd() { return dcCd; }
	public void setDcCd(String dcCd) { this.dcCd = dcCd; }
	public String getDcNm() { return dcNm; }
	public void setDcNm(String dcNm) { this.dcNm = dcNm; }

	public String getOrdNo() { return ordNo; }
	public void setOrdNo(String ordNo) { this.ordNo = ordNo; }
	public String getOrdItemNo() { return ordItemNo; }
	public void setOrdItemNo(String ordItemNo) { this.ordItemNo = ordItemNo; }
	public String getItemCd() { return itemCd; }
	public void setItemCd(String itemCd) { this.itemCd = itemCd; }
	public String getItemNm() { return itemNm; }
	public void setItemNm(String itemNm) { this.itemNm = itemNm; }
	public String getSpec() { return spec; }
	public void setSpec(String spec) { this.spec = spec; }
	public String getUnit() { return unit; }
	public void setUnit(String unit) { this.unit = unit; }
	public BigDecimal getOrdQty() { return ordQty; }
	public void setOrdQty(BigDecimal ordQty) { this.ordQty = ordQty; }
	public BigDecimal getSettleQty() { return settleQty; }
	public void setSettleQty(BigDecimal settleQty) { this.settleQty = settleQty; }
	public BigDecimal getSettleAmt() { return settleAmt; }
	public void setSettleAmt(BigDecimal settleAmt) { this.settleAmt = settleAmt; }
	public String getDlvDt() { return dlvDt; }
	public void setDlvDt(String dlvDt) { this.dlvDt = dlvDt; }
	public String getOutDt() { return outDt; }
	public void setOutDt(String outDt) { this.outDt = outDt; }
	public BigDecimal getOutQty() { return outQty; }
	public void setOutQty(BigDecimal outQty) { this.outQty = outQty; }
	public BigDecimal getSalePrice() { return salePrice; }
	public void setSalePrice(BigDecimal salePrice) { this.salePrice = salePrice; }
	public BigDecimal getSaleAmt() { return saleAmt; }
	public void setSaleAmt(BigDecimal saleAmt) { this.saleAmt = saleAmt; }
	public String getDlvType() { return dlvType; }
	public void setDlvType(String dlvType) { this.dlvType = dlvType; }
	public String getTaxGb() { return taxGb; }
	public void setTaxGb(String taxGb) { this.taxGb = taxGb; }

	public String getDlvDtFrom() { return dlvDtFrom; }
	public void setDlvDtFrom(String dlvDtFrom) { this.dlvDtFrom = dlvDtFrom; }
	public String getDlvDtTo() { return dlvDtTo; }
	public void setDlvDtTo(String dlvDtTo) { this.dlvDtTo = dlvDtTo; }

	public String getNewDcNm() { return newDcNm; }
	public void setNewDcNm(String newDcNm) { this.newDcNm = newDcNm; }
	public String getNewDcCd() { return newDcCd; }
	public void setNewDcCd(String newDcCd) { this.newDcCd = newDcCd; }

	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }
}
