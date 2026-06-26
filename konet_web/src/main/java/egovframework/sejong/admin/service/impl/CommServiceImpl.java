package egovframework.sejong.admin.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.sejong.admin.mapper.CommMapper;
import egovframework.sejong.admin.model.CommDTO;
import egovframework.sejong.admin.service.CommService;


@Service("CommService")
public class CommServiceImpl implements CommService {
	private static final Logger LOGGER = LoggerFactory.getLogger(CommServiceImpl.class);
	
	@Autowired
	private CommMapper mapper;	
	
	@Override
	public List<?> selectCommMstList(CommDTO dto) throws Exception {
		return mapper.selectCommMstList(dto);
	}

	@Override
	public String selectCommMstDupChk(CommDTO dto) throws Exception {
		return mapper.selectCommMstDupChk(dto);
	}

	@Override
	public boolean insertCommMst(CommDTO dto) throws Exception {
		return mapper.insertCommMst(dto);
	}

	@Override
	public boolean updateCommMst(CommDTO dto) throws Exception {
		return mapper.updateCommMst(dto);
	}

	@Override
	public boolean deleteCommMst(CommDTO dto) throws Exception {
		return mapper.deleteCommMst(dto);
	}

	@Override
	public List<?> selectCommDetailList(CommDTO dto) throws Exception {
		return mapper.selectCommDetailList(dto);
	}

	@Override
	public String selectCommDetailDupChk(CommDTO dto) throws Exception {
		return mapper.selectCommDetailDupChk(dto);
	}

	@Override
	public boolean insertCommDetail(CommDTO dto) throws Exception {
		return mapper.insertCommDetail(dto);
	}

	@Override
	public boolean updateCommDetail(CommDTO dto) throws Exception {
		return mapper.updateCommDetail(dto);
	}

	@Override
	public boolean deleteCommDetail(CommDTO dto) throws Exception {
		return mapper.deleteCommDetail(dto);
	}


}