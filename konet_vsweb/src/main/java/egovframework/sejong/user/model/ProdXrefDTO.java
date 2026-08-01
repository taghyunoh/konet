package egovframework.sejong.user.model;

/**
 * 거래처별 품목 표기(교차참조) DTO  →  TBL_PROD_XREF
 *
 *  코네트는 품목코드·품목명을 하나로 쓰고, 거래처(출고장)가 자기 코드·자기 품명으로
 *  요청하는 것은 이 표에 N건으로 담는다. 종전처럼 표기마다 TBL_PROD_MST 에 '가상코드'를
 *  새로 등록하지 않는다 — 그러면 재고가 원코드와 가상코드로 갈라진다.
 *
 *  · 재고·원가의 주인은 언제나 prodSeq(TBL_PROD_MST.PROD_SEQ) 하나다.
 *  · extItemNm = 출고서·거래명세서에 찍히는 이름(거래처가 요청한 이름).
 *  · ★(vendorCd + dcCd + extItemCd) → prodSeq 는 반드시 1개 (UX_PROD_XREF_EXT 가 강제).
 *    반대로 한 품목에 거래처 코드가 여럿인 것은 정상.
 *  · DDL : sql/prod_xref_ddl.sql
 */
public class ProdXrefDTO {

	// ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
	private String compCd;        // 회사코드(COMP_CD)
	public String getCompCd() { return compCd; }
	public void setCompCd(String compCd) { this.compCd = compCd; }

	private Long    xrefSeq;      // PK
	private Long    prodSeq;      // 우리 품목(TBL_PROD_MST.PROD_SEQ) — 재고의 주인
	private String  prodCd;       // 우리 품목코드(가독용 사본)
	private String  prodNm;       // 우리 품명 — 조회 시 조인해서 채운다(저장 컬럼 아님)

	private String  vendorCd;     // 거래처코드. null/빈값 = 모든 거래처 공통 별칭
	private String  vendorNm;     // 거래처명(가독용 사본)
	private String  dcCd;         // 출고장코드. null = 그 거래처 전체
	private String  extItemCd;    // ★거래처가 쓰는 품목코드 (업로드 ITEM_CD 와 맞대는 칸)
	private String  extItemNm;    // ★거래처가 쓰는 품목명 (출고서에 찍히는 이름)
	private String  extSpec;      // 거래처 규격 표기
	private String  extUnit;      // 거래처 단위 표기('BOX' 등)

	private Double  convQty;      // 환산계수 — 거래처 수량 1 = 우리 수량 N (기본 1)
	private String  mainYn;       // 그 거래처의 대표 표기(출력 기본값)

	// ----- 검증 상태 : 자동 추천은 confirmYn='N' 으로만 들어온다(자동 확정 없음) -----
	private Integer matchScore;   // 자동 대조 점수 0~100 (단가·규격·면과세·품명)
	private String  confirmYn;    // 'Y' = 사람이 확인함
	private String  confirmUser;
	private String  confirmDttm;

	private String  remark;
	private String  actionYn;
	private String  regDttm;
	private String  regUser;
	private String  regIp;
	private String  updDttm;
	private String  updUser;
	private String  updIp;

	// ----- 조회 전용(저장 컬럼 아님) -----
	private String  findData;     // 목록 검색어
	private Long    jobSeq;       // resolve* 대상 배치
	private String  dlvDt;        // resolve* 대상 배치(납품일자)
	private String  useQty;       // 그 코드로 들어온 최근 실적 요약(건수 등) — 화면 표시용
	private String  lastDt;       // 그 코드가 마지막으로 들어온 일자
	/* ★후보 추천의 1순위 근거. 품명은 거래처마다 제각각으로 들어오지만 단가는 숫자라 흔들리지 않는다.
	   (실측: 정산 엑셀 단가 = 우리 출고단가. 평택 6건 중 5건 정확히 일치 / 매입단가 일치 0건) */
	private Double  extPrice;     // 정산서에서 온 단가 — 우리 판매가와 대조
	private String  matchWhy;     // 후보로 뽑힌 근거('단가 일치' / '규격 일치' / '이전 코드' …)
	/* 후보가 비슷비슷할 때 고르는 재료 (2026-08-01 요청).
	   품명·규격이 같은 후보가 둘 나오면 근거만으로는 못 고른다. 실제로 '살아 있는' 품목이
	   어느 쪽인지 — 판매단가·현재고·최근 출고 — 를 같이 보여 준다.
	   재고도 거래도 없는 쪽은 예전에 만든 가상코드일 가능성이 높다. */
	private Double  salePrice;    // 우리 판매단가
	private String  makerNm;      // 제조사
	private Double  curQty;       // 현재고
	private String  lastOutDt;    // 최근 출고일자

	public Long getXrefSeq() { return xrefSeq; }
	public void setXrefSeq(Long xrefSeq) { this.xrefSeq = xrefSeq; }
	public Long getProdSeq() { return prodSeq; }
	public void setProdSeq(Long prodSeq) { this.prodSeq = prodSeq; }
	public String getProdCd() { return prodCd; }
	public void setProdCd(String prodCd) { this.prodCd = prodCd; }
	public String getProdNm() { return prodNm; }
	public void setProdNm(String prodNm) { this.prodNm = prodNm; }
	public String getVendorCd() { return vendorCd; }
	public void setVendorCd(String vendorCd) { this.vendorCd = vendorCd; }
	public String getVendorNm() { return vendorNm; }
	public void setVendorNm(String vendorNm) { this.vendorNm = vendorNm; }
	public String getDcCd() { return dcCd; }
	public void setDcCd(String dcCd) { this.dcCd = dcCd; }
	public String getExtItemCd() { return extItemCd; }
	public void setExtItemCd(String extItemCd) { this.extItemCd = extItemCd; }
	public String getExtItemNm() { return extItemNm; }
	public void setExtItemNm(String extItemNm) { this.extItemNm = extItemNm; }
	public String getExtSpec() { return extSpec; }
	public void setExtSpec(String extSpec) { this.extSpec = extSpec; }
	public String getExtUnit() { return extUnit; }
	public void setExtUnit(String extUnit) { this.extUnit = extUnit; }
	public Double getConvQty() { return convQty; }
	public void setConvQty(Double convQty) { this.convQty = convQty; }
	public String getMainYn() { return mainYn; }
	public void setMainYn(String mainYn) { this.mainYn = mainYn; }
	public Integer getMatchScore() { return matchScore; }
	public void setMatchScore(Integer matchScore) { this.matchScore = matchScore; }
	public String getConfirmYn() { return confirmYn; }
	public void setConfirmYn(String confirmYn) { this.confirmYn = confirmYn; }
	public String getConfirmUser() { return confirmUser; }
	public void setConfirmUser(String confirmUser) { this.confirmUser = confirmUser; }
	public String getConfirmDttm() { return confirmDttm; }
	public void setConfirmDttm(String confirmDttm) { this.confirmDttm = confirmDttm; }
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
	public Long getJobSeq() { return jobSeq; }
	public void setJobSeq(Long jobSeq) { this.jobSeq = jobSeq; }
	public String getDlvDt() { return dlvDt; }
	public void setDlvDt(String dlvDt) { this.dlvDt = dlvDt; }
	public String getUseQty() { return useQty; }
	public void setUseQty(String useQty) { this.useQty = useQty; }
	public String getLastDt() { return lastDt; }
	public void setLastDt(String lastDt) { this.lastDt = lastDt; }
	public Double getExtPrice() { return extPrice; }
	public void setExtPrice(Double extPrice) { this.extPrice = extPrice; }
	public String getMatchWhy() { return matchWhy; }
	public void setMatchWhy(String matchWhy) { this.matchWhy = matchWhy; }
	public Double getSalePrice() { return salePrice; }
	public void setSalePrice(Double salePrice) { this.salePrice = salePrice; }
	public String getMakerNm() { return makerNm; }
	public void setMakerNm(String makerNm) { this.makerNm = makerNm; }
	public Double getCurQty() { return curQty; }
	public void setCurQty(Double curQty) { this.curQty = curQty; }
	public String getLastOutDt() { return lastOutDt; }
	public void setLastOutDt(String lastOutDt) { this.lastOutDt = lastOutDt; }
}
