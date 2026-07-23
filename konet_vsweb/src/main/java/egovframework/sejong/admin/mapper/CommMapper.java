package egovframework.sejong.admin.mapper;

import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.admin.model.CommDTO;

@Mapper("CommMapper")
public interface CommMapper {
	List<?>   selectCommMstList(CommDTO dto) throws Exception; 
	String    selectCommMstDupChk(CommDTO dto) throws Exception; 
	boolean   insertCommMst(CommDTO dto) throws Exception; 
	boolean   updateCommMst(CommDTO dto) throws Exception; 
	boolean   deleteCommMst(CommDTO dto) throws Exception; 
	List<?>   selectCommDetailList(CommDTO dto) throws Exception; 
	String    selectCommDetailDupChk(CommDTO dto) throws Exception; 
	boolean   insertCommDetail(CommDTO dto) throws Exception; 
	boolean   updateCommDetail(CommDTO dto) throws Exception; 
	boolean   deleteCommDetail(CommDTO dto) throws Exception; 	

}
