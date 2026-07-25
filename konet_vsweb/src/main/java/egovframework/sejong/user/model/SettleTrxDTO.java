package egovframework.sejong.user.model;

/**
 * 수금/지급 전표 DTO  →  TBL_SETTLE_TRX
 *  · 한 테이블에서 TRX_GB 로 구분한다 : 'RCV'=수금(매출처) / 'PAY'=지급(매입처)
 *    (정산 마감상태 TBL_SETTLE_CLOSE_MST 가 SETTLE_GB='RCV'/'PAY' 로 쓰는 방식과 같다)
 *  · 전표번호 trxNo = 일자별 순번 '0001' (매입등록과 같은 체계)
 *  · saleDcAmt(매출할인 DC)는 수금 화면에만 있는 칸이다.
 *  · 조회 파라미터(fromDt/toDt/findData/payGb/mgrCd)는 비영속.
 */
public class SettleTrxDTO {

    private Long    trxSeq;        // PK
    private String  trxGb;         // 'RCV' | 'PAY'
    private String  trxDt;         // 수금/지급 일자 yyyymmdd
    private String  trxNo;         // 그날의 순번 '0001'
    private String  payGb;         // 무통장입금 / 카드 / 현금 / 무통장지급 …
    private String  acctCd;        // 계좌 코드
    private String  acctNm;        // '국민은행 / 699237-01-004560 / (주)코네트'
    private String  custCd;        // 거래처 (수금=매출처, 지급=매입처)
    private String  custNm;
    private String  mgrCd;         // 담당사원
    private String  mgrNm;
    private Double  amt;           // 수금액 / 지급액
    private Double  dcAmt;         // 할인액
    private Double  saleDcAmt;     // 매출할인(DC) — 수금 전용
    private Double  totAmt;        // 합계금액 = amt + dcAmt
    private String  remark;        // 메모

    private String  actionYn;
    private String  regDttm;
    private String  regUser;
    private String  regIp;
    private String  updDttm;
    private String  updUser;
    private String  updIp;

    // ── 조회 파라미터 (비영속) ──
    private String  fromDt;
    private String  toDt;
    private String  findData;      // 거래처명 검색어

    public Long getTrxSeq() { return trxSeq; }
    public void setTrxSeq(Long trxSeq) { this.trxSeq = trxSeq; }
    public String getTrxGb() { return trxGb; }
    public void setTrxGb(String trxGb) { this.trxGb = trxGb; }
    public String getTrxDt() { return trxDt; }
    public void setTrxDt(String trxDt) { this.trxDt = trxDt; }
    public String getTrxNo() { return trxNo; }
    public void setTrxNo(String trxNo) { this.trxNo = trxNo; }
    public String getPayGb() { return payGb; }
    public void setPayGb(String payGb) { this.payGb = payGb; }
    public String getAcctCd() { return acctCd; }
    public void setAcctCd(String acctCd) { this.acctCd = acctCd; }
    public String getAcctNm() { return acctNm; }
    public void setAcctNm(String acctNm) { this.acctNm = acctNm; }
    public String getCustCd() { return custCd; }
    public void setCustCd(String custCd) { this.custCd = custCd; }
    public String getCustNm() { return custNm; }
    public void setCustNm(String custNm) { this.custNm = custNm; }
    public String getMgrCd() { return mgrCd; }
    public void setMgrCd(String mgrCd) { this.mgrCd = mgrCd; }
    public String getMgrNm() { return mgrNm; }
    public void setMgrNm(String mgrNm) { this.mgrNm = mgrNm; }
    public Double getAmt() { return amt; }
    public void setAmt(Double amt) { this.amt = amt; }
    public Double getDcAmt() { return dcAmt; }
    public void setDcAmt(Double dcAmt) { this.dcAmt = dcAmt; }
    public Double getSaleDcAmt() { return saleDcAmt; }
    public void setSaleDcAmt(Double saleDcAmt) { this.saleDcAmt = saleDcAmt; }
    public Double getTotAmt() { return totAmt; }
    public void setTotAmt(Double totAmt) { this.totAmt = totAmt; }
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
    public String getFromDt() { return fromDt; }
    public void setFromDt(String fromDt) { this.fromDt = fromDt; }
    public String getToDt() { return toDt; }
    public void setToDt(String toDt) { this.toDt = toDt; }
    public String getFindData() { return findData; }
    public void setFindData(String findData) { this.findData = findData; }
}
