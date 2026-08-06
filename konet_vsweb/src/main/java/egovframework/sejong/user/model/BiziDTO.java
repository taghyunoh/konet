package egovframework.sejong.user.model;

/**
 * 사업장 분류 마스터 DTO  →  TBL_BIZI_MST
 *  · PK: bizCd(사업장코드) / bizNm(사업장명)
 *  · 출고현황표에서 "품목명 앞 () 없는" 행의 사업장코드→사업장명을 등록.
 *    업로드 분류 시 bizCd 가 이 테이블에 있으면 bizNm 으로 분류(없으면 품목명 () 접두어).
 */
public class BiziDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

	private String  bizCd;     // 사업장코드 (PK)
	private Integer jobSeq;    // 버전
	private String  actionYn;  // 'Y'=활성
	private String  bizNm;     // 사업장명
	private String  bizSmallNm;// 약칭
	private String  bizGb;     // 거래구분(매입/매출/both)
	private String  bizno;     // 사업자등록번호
	private String  ceoNm;     // 대표자명
	private String  bizCond;   // 업태
	private String  bizItem;   // 종목
	private String  zipcd;     // 우편번호
	private String  addr;      // 주소
	private String  addr2;     // 상세주소
	private String  tel;       // 전화
	private String  fax;       // 팩스
	private String  hp;        // 휴대폰
	private String  email;     // 이메일
	private String  manager;   // 담당자
	private Integer sortOrd;   // 정렬순서
	private String  remark;    // 비고
	// ----- 택배 정보 (2026-08-06 신설) — 사업장관리·택배출고관리에서 입력 -----
	private String  parcelAddr; // 택배주소(있으면 ADDR 보다 우선)
	private String  parcelTel;  // 택배 전화
	private String  parcelHp;   // 택배 휴대폰
	private String  parcelNm;   // 택배 수령자(SRM 비상연락망의 수령자)
	private Integer parcelFee;  // 기본 택배운임(원) — 비면 화면에서 4500
	private String  regDttm;   // 등록일시(조회)
	private String  updDttm;   // 수정일시(조회)
	private String  findData;  // 검색어(코드/명/약칭/사업자번호/대표자) — 비영속

	private String  regUser;
	private String  regIp;
	private String  updUser;
	private String  updIp;

	public String getBizCd() { return bizCd; }
	public void setBizCd(String bizCd) { this.bizCd = bizCd; }
	public Integer getJobSeq() { return jobSeq; }
	public void setJobSeq(Integer jobSeq) { this.jobSeq = jobSeq; }
	public String getActionYn() { return actionYn; }
	public void setActionYn(String actionYn) { this.actionYn = actionYn; }
	public String getBizNm() { return bizNm; }
	public void setBizNm(String bizNm) { this.bizNm = bizNm; }
	public String getBizSmallNm() { return bizSmallNm; }
	public void setBizSmallNm(String bizSmallNm) { this.bizSmallNm = bizSmallNm; }
	public String getBizGb() { return bizGb; }
	public void setBizGb(String bizGb) { this.bizGb = bizGb; }
	public String getBizno() { return bizno; }
	public void setBizno(String bizno) { this.bizno = bizno; }
	public String getCeoNm() { return ceoNm; }
	public void setCeoNm(String ceoNm) { this.ceoNm = ceoNm; }
	public String getBizCond() { return bizCond; }
	public void setBizCond(String bizCond) { this.bizCond = bizCond; }
	public String getBizItem() { return bizItem; }
	public void setBizItem(String bizItem) { this.bizItem = bizItem; }
	public String getZipcd() { return zipcd; }
	public void setZipcd(String zipcd) { this.zipcd = zipcd; }
	public String getAddr() { return addr; }
	public void setAddr(String addr) { this.addr = addr; }
	public String getAddr2() { return addr2; }
	public void setAddr2(String addr2) { this.addr2 = addr2; }
	public String getTel() { return tel; }
	public void setTel(String tel) { this.tel = tel; }
	public String getFax() { return fax; }
	public void setFax(String fax) { this.fax = fax; }
	public String getHp() { return hp; }
	public void setHp(String hp) { this.hp = hp; }
	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }
	public String getManager() { return manager; }
	public void setManager(String manager) { this.manager = manager; }
	public Integer getSortOrd() { return sortOrd; }
	public void setSortOrd(Integer sortOrd) { this.sortOrd = sortOrd; }
	public String getRemark() { return remark; }
	public void setRemark(String remark) { this.remark = remark; }
	public String getRegDttm() { return regDttm; }
	public void setRegDttm(String regDttm) { this.regDttm = regDttm; }
	public String getUpdDttm() { return updDttm; }
	public void setUpdDttm(String updDttm) { this.updDttm = updDttm; }
	public String getFindData() { return findData; }
	public void setFindData(String findData) { this.findData = findData; }

	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }
	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }
	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }
	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }

	public String getParcelAddr() { return parcelAddr; }
	public void setParcelAddr(String parcelAddr) { this.parcelAddr = parcelAddr; }
	public String getParcelTel() { return parcelTel; }
	public void setParcelTel(String parcelTel) { this.parcelTel = parcelTel; }
	public String getParcelHp() { return parcelHp; }
	public void setParcelHp(String parcelHp) { this.parcelHp = parcelHp; }
	public String getParcelNm() { return parcelNm; }
	public void setParcelNm(String parcelNm) { this.parcelNm = parcelNm; }
	public Integer getParcelFee() { return parcelFee; }
	public void setParcelFee(Integer parcelFee) { this.parcelFee = parcelFee; }
}
