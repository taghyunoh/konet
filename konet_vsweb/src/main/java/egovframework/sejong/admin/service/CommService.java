package egovframework.sejong.admin.service;

import java.util.List;

import egovframework.sejong.admin.model.CommDTO;

public interface CommService {
	//공통코드 관리
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