package egovframework.konet.photo.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

/** 사진함 (2026-11-26) — SQL = sqlmap/mapper/Photo_SQL.xml. ★konet_vsweb · konet_vsapp 두 앱에 같은 파일 */
@Mapper("PhotoMapper")
public interface PhotoMapper {
	int insertPhotoGrp(Map<String, Object> p);
	Map<String, Object> selectPhotoGrpOne(Map<String, Object> p);
	int insertPhoto(Map<String, Object> p);
	int updatePhotoGrpCnt(Map<String, Object> p);
	List<Map<String, Object>> selectPhotoDays(Map<String, Object> p);
	List<Map<String, Object>> selectPhotoGrpList(Map<String, Object> p);
	List<Map<String, Object>> selectPhotoList(Map<String, Object> p);
	Map<String, Object> selectPhotoImg(Map<String, Object> p);
	Map<String, Object> selectPhotoThumb(Map<String, Object> p);
	int deletePhoto(Map<String, Object> p);
	int deletePhotoByGrp(Map<String, Object> p);
	int deletePhotoGrp(Map<String, Object> p);
	int updatePhotoGrpTitle(Map<String, Object> p);
	int deletePhotoOld(Map<String, Object> p);
	int deletePhotoGrpOld(Map<String, Object> p);
	int deletePhotoGrpEmpty(Map<String, Object> p);
}
