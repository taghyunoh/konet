package egovframework.konet.tax.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

/** 매출·매입 계산서 (2026-11-27) — SQL = sqlmap/mapper/TaxBill_SQL.xml · 표 = docs/sql/20261127_taxbill.sql */
@Mapper("TaxBillMapper")
public interface TaxBillMapper {
	List<Map<String, Object>> selectTaxVendors(Map<String, Object> p);
	List<Map<String, Object>> selectTaxSrcSale(Map<String, Object> p);
	List<Map<String, Object>> selectTaxSrcPurch(Map<String, Object> p);
	List<Map<String, Object>> selectTaxExisting(Map<String, Object> p);
	int insertTaxBillMst(Map<String, Object> p);
	int insertTaxBillDtl(Map<String, Object> p);
	List<Map<String, Object>> selectTaxBillList(Map<String, Object> p);
	Map<String, Object> selectTaxBillOne(Map<String, Object> p);
	List<Map<String, Object>> selectTaxBillDtl(Map<String, Object> p);
	List<Map<String, Object>> selectTaxBadBizno(Map<String, Object> p);
	int updateTaxBillStatus(Map<String, Object> p);
	int deleteTaxBill(Map<String, Object> p);
	int updateTaxBillHead(Map<String, Object> p);
	Map<String, Object> selectTaxComp(Map<String, Object> p);
}
