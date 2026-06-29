package egovframework.sejong.admin.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.sejong.admin.mapper.AdminMapper;
import egovframework.sejong.admin.service.AdminService;

import egovframework.sejong.admin.model.AsqDTO;
import egovframework.sejong.admin.model.FaqDTO;


@Service("AdminService")
public class AdminServiceImpl implements AdminService {
	private static final Logger LOGGER = LoggerFactory.getLogger(AdminServiceImpl.class);	
	@Autowired
	private AdminMapper mapper;


	@Override
	public List<?> selectfaqList(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectfaqList(dto);
	}
	@Override
	public FaqDTO faqInfo(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.faqInfo(dto);
	}
	@Override
	public boolean insertfaq(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertfaq(dto);
	}
	@Override
	public boolean updatefaq(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updatefaq(dto);
	}
	@Override
	public boolean deletefaq(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deletefaq(dto);
	}
	@Override
	public List<?> selectasqList(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectasqList(dto);
	}
	@Override
	public List<?> selectMyAsqList(AsqDTO dto) throws Exception {
		return mapper.selectMyAsqList(dto);
	}
	@Override
	public AsqDTO asqInfo(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.asqInfo(dto);
	}
	@Override
	public boolean insertasq(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertasq(dto);
	}
	@Override
	public boolean updateasq(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateasq(dto);
	}
	@Override
	public boolean deleteasq(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteasq(dto);
	}
}