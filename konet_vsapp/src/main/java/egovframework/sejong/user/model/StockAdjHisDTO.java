package egovframework.sejong.user.model;

/**
 * 재고 일괄조정 이력 DTO  →  TBL_STOCK_ADJ_HIS                        2026-08-19
 *
 *  재고 수불원장(TBL_STOCK_LEDGER)은 <b>차이(조정수량)만</b> 남는다.
 *  "420 이던 것을 400 으로 고쳤다" 를 나중에 볼 수 없고, 한 번에 저장한 묶음도 흩어진다.
 *  그래서 조정 전/후 값과 저장 묶음(BATCH_NO)을 따로 남긴다.
 *
 *  · 재고의 주인은 여전히 원장이다. 이 표는 <b>설명용 기록</b>이지 재고를 만들지 않는다.
 *  · ledgerSeq 로 원장행과 짝을 맞춘다 — 묶음 되돌리기가 이 짝을 따라간다.
 *  · packQty 를 같이 남기는 이유 : 입수수량이 나중에 바뀌면 BOX 환산이 달라져
 *    과거 기록을 재현할 수 없다. 그때의 값을 박아 둔다.
 */
public class StockAdjHisDTO {

    // ----- 다중회사(멀티테넌트) — 로그인 세션(s_comp_cd)에서 주입 -----
    private String  compCd;

    private Long    adjSeq;        // PK
    private String  batchNo;       // 저장 묶음 ([수정저장] 1회 = 1개)
    private Long    prodSeq;
    private String  prodCd;
    private String  prodNm;        // 조인
    private String  spec;          // 조인
    private String  baseDt;        // 기준일자(YYYYMMDD) = 조정행 거래일자

    private Integer befQty;        // 변경 전 재고 (EA 환산)
    private Integer aftQty;        // 변경 후 재고 (EA 환산)
    private Integer diffQty;       // 차이 = 원장 조정행 수량

    private Integer befBox;        // 화면에 보인 그대로
    private Integer befEa;
    private Integer aftBox;        // 사용자가 적은 그대로
    private Integer aftEa;
    private Integer packQty;       // 그때의 입수수량(환산 근거)

    private Long    ledgerSeq;     // 만들어진 원장행 (차이가 0이면 null)

    private String  remark;        // 사유
    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    // ----- 조회 조건(비영속) -----
    private String  dtFrom;        // 기준일자 시작
    private String  dtTo;          // 기준일자 종료

    public String  getCompCd()    { return compCd; }
    public void    setCompCd(String v)    { this.compCd = v; }
    public Long    getAdjSeq()    { return adjSeq; }
    public void    setAdjSeq(Long v)      { this.adjSeq = v; }
    public String  getBatchNo()   { return batchNo; }
    public void    setBatchNo(String v)   { this.batchNo = v; }
    public Long    getProdSeq()   { return prodSeq; }
    public void    setProdSeq(Long v)     { this.prodSeq = v; }
    public String  getProdCd()    { return prodCd; }
    public void    setProdCd(String v)    { this.prodCd = v; }
    public String  getProdNm()    { return prodNm; }
    public void    setProdNm(String v)    { this.prodNm = v; }
    public String  getSpec()      { return spec; }
    public void    setSpec(String v)      { this.spec = v; }
    public String  getBaseDt()    { return baseDt; }
    public void    setBaseDt(String v)    { this.baseDt = v; }

    public Integer getBefQty()    { return befQty; }
    public void    setBefQty(Integer v)   { this.befQty = v; }
    public Integer getAftQty()    { return aftQty; }
    public void    setAftQty(Integer v)   { this.aftQty = v; }
    public Integer getDiffQty()   { return diffQty; }
    public void    setDiffQty(Integer v)  { this.diffQty = v; }

    public Integer getBefBox()    { return befBox; }
    public void    setBefBox(Integer v)   { this.befBox = v; }
    public Integer getBefEa()     { return befEa; }
    public void    setBefEa(Integer v)    { this.befEa = v; }
    public Integer getAftBox()    { return aftBox; }
    public void    setAftBox(Integer v)   { this.aftBox = v; }
    public Integer getAftEa()     { return aftEa; }
    public void    setAftEa(Integer v)    { this.aftEa = v; }
    public Integer getPackQty()   { return packQty; }
    public void    setPackQty(Integer v)  { this.packQty = v; }

    public Long    getLedgerSeq() { return ledgerSeq; }
    public void    setLedgerSeq(Long v)   { this.ledgerSeq = v; }

    public String  getRemark()    { return remark; }
    public void    setRemark(String v)    { this.remark = v; }
    public String  getActionYn()  { return actionYn; }
    public void    setActionYn(String v)  { this.actionYn = v; }
    public String  getRegDttm()   { return regDttm; }
    public void    setRegDttm(String v)   { this.regDttm = v; }
    public String  getRegUser()   { return regUser; }
    public void    setRegUser(String v)   { this.regUser = v; }
    public String  getRegIp()     { return regIp; }
    public void    setRegIp(String v)     { this.regIp = v; }
    public String  getUpdDttm()   { return updDttm; }
    public void    setUpdDttm(String v)   { this.updDttm = v; }
    public String  getUpdUser()   { return updUser; }
    public void    setUpdUser(String v)   { this.updUser = v; }
    public String  getUpdIp()     { return updIp; }
    public void    setUpdIp(String v)     { this.updIp = v; }

    public String  getDtFrom()    { return dtFrom; }
    public void    setDtFrom(String v)    { this.dtFrom = v; }
    public String  getDtTo()      { return dtTo; }
    public void    setDtTo(String v)      { this.dtTo = v; }
}
