package egovframework.sejong.user.model;

/**
 * 거래처 마스터 DTO  →  TBL_VENDOR_MST   (DDL: sql/vendor_mst_ddl.sql)
 *
 *  · 원천 = 회계시스템의 `거래처리스트.xls`(확장자만 xls, 실제는 HTML 표). 코드기준 병합 432종.
 *  · ★TBL_BIZI_MST(사업장/점포, 'A0386956'형)와 별개다 — 코드·이름 교집합 0. 섞지 말 것.
 *  · vendorGb = '매입' / '매출' / '매입&매출'
 *      매입처 후보(매입가·재고입고 화면) = vendorGb 에 '매입' 포함분 121종
 *  · dcCd = 물류센터 매핑. 발주현황표 출고장 7곳이 삼성웰스토리 지점 거래처와 1:1
 *      E100 용인=00273 / E200 왜관=00275 / E300 김해=00274 / E400 광주=00276
 *      E500 평택=00272 / E600 제주=00277 / E700 오산=00278
 */
public class VendorDTO {

	private String  vendorCd;    // 거래처코드 (PK)
	private String  vendorNm;    // 거래처명
	private String  fullNm;      // 정식명칭
	private String  alias;       // 별칭
	private String  ceoNm;       // 대표자명
	private String  vendorGb;    // 거래유형 '매입'/'매출'/'매입&매출'
	private String  bizCond;     // 업태
	private String  bizItem;     // 종목
	private String  mgrCd;       // 담당자코드
	private String  mgrNm;       // 담당자명
	private String  typeCd;      // 유형코드
	private String  typeNm;      // 유형명
	private String  areaCd;      // 지역코드
	private String  areaNm;      // 지역명
	private String  zipcd;       // 우편번호
	private String  addr;        // 주소
	private String  addr2;       // 상세주소
	private String  email;       // 이메일
	private String  hp;          // 연락처(휴대폰)
	private String  tel;         // 전화
	private String  fax;         // 팩스
	private String  bizno;       // 사업자등록번호
	private String  bankAcct;    // 계좌
	private String  taxbillGb;   // 계산서발행 '발행'/'미발행'
	private String  vatGb;       // 부가세 '포함'/'별도'
	private String  regDt;       // 원본 등록일 'YYYYMMDD'
	private String  dcCd;        // 물류센터코드(발주현황표 DC_CD 와 연결)
	private Integer sortOrd;     // 정렬순서
	private String  remark;      // 비고
	private String  actionYn;    // 'Y'=사용 / 'N'=미사용

	// ----- 조회 전용(비영속) -----
	private String  findData;    // 검색어(코드/명/정식명칭/별칭/사업자번호/대표자)
	private String  gbFilter;    // 거래유형 필터 — '매입' 또는 '매출' (LIKE 매칭, 빈값=전체)

	private String  regDttm;
	private String  updDttm;
	private String  regUser;
	private String  regIp;
	private String  updUser;
	private String  updIp;

	public String getVendorCd() { return vendorCd; }
	public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
	public String getVendorNm() { return vendorNm; }
	public void setVendorNm(String vendorNm) { this.vendorNm = vendorNm; }
	public String getFullNm() { return fullNm; }
	public void setFullNm(String fullNm) { this.fullNm = fullNm; }
	public String getAlias() { return alias; }
	public void setAlias(String alias) { this.alias = alias; }
	public String getCeoNm() { return ceoNm; }
	public void setCeoNm(String ceoNm) { this.ceoNm = ceoNm; }
	public String getVendorGb() { return vendorGb; }
	public void setVendorGb(String vendorGb) { this.vendorGb = vendorGb; }
	public String getBizCond() { return bizCond; }
	public void setBizCond(String bizCond) { this.bizCond = bizCond; }
	public String getBizItem() { return bizItem; }
	public void setBizItem(String bizItem) { this.bizItem = bizItem; }
	public String getMgrCd() { return mgrCd; }
	public void setMgrCd(String mgrCd) { this.mgrCd = mgrCd; }
	public String getMgrNm() { return mgrNm; }
	public void setMgrNm(String mgrNm) { this.mgrNm = mgrNm; }
	public String getTypeCd() { return typeCd; }
	public void setTypeCd(String typeCd) { this.typeCd = typeCd; }
	public String getTypeNm() { return typeNm; }
	public void setTypeNm(String typeNm) { this.typeNm = typeNm; }
	public String getAreaCd() { return areaCd; }
	public void setAreaCd(String areaCd) { this.areaCd = areaCd; }
	public String getAreaNm() { return areaNm; }
	public void setAreaNm(String areaNm) { this.areaNm = areaNm; }
	public String getZipcd() { return zipcd; }
	public void setZipcd(String zipcd) { this.zipcd = zipcd; }
	public String getAddr() { return addr; }
	public void setAddr(String addr) { this.addr = addr; }
	public String getAddr2() { return addr2; }
	public void setAddr2(String addr2) { this.addr2 = addr2; }
	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }
	public String getHp() { return hp; }
	public void setHp(String hp) { this.hp = hp; }
	public String getTel() { return tel; }
	public void setTel(String tel) { this.tel = tel; }
	public String getFax() { return fax; }
	public void setFax(String fax) { this.fax = fax; }
	public String getBizno() { return bizno; }
	public void setBizno(String bizno) { this.bizno = bizno; }
	public String getBankAcct() { return bankAcct; }
	public void setBankAcct(String bankAcct) { this.bankAcct = bankAcct; }
	public String getTaxbillGb() { return taxbillGb; }
	public void setTaxbillGb(String taxbillGb) { this.taxbillGb = taxbillGb; }
	public String getVatGb() { return vatGb; }
	public void setVatGb(String vatGb) { this.vatGb = vatGb; }
	public String getRegDt() { return regDt; }
	public void setRegDt(String regDt) { this.regDt = regDt; }
	public String getDcCd() { return dcCd; }
	public void setDcCd(String dcCd) { this.dcCd = dcCd; }
	public Integer getSortOrd() { return sortOrd; }
	public void setSortOrd(Integer sortOrd) { this.sortOrd = sortOrd; }
	public String getRemark() { return remark; }
	public void setRemark(String remark) { this.remark = remark; }
	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }

	public String getFindData() { return findData; }
	public void setFindData(String findData) { this.findData = findData; }
	public String getGbFilter() { return gbFilter; }
	public void setGbFilter(String gbFilter) { this.gbFilter = gbFilter; }

	public String getRegDttm() { return regDttm; }
	public void setRegDttm(String regDttm) { this.regDttm = regDttm; }
	public String getUpdDttm() { return updDttm; }
	public void setUpdDttm(String updDttm) { this.updDttm = updDttm; }
	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }
}
