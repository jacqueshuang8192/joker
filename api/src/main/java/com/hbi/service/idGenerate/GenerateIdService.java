package com.hbi.service.idGenerate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.core.service.BaseService;
import com.hbi.mapper.TRecordMapper;
import com.hbi.model.TRecord;

@Service
public class GenerateIdService extends BaseService<TRecord> {

	@Autowired
	private TRecordMapper tRecordMapper;

	public Long generateId(String objectClassName) {
//		Long id = null;
//		id = tRecordMapper.getCurrentId(objectClassName);
//		// 如果为空说明没改记录，插入
//		if (id == null) {
//			id = 1l;
//			// 更新当前的id为2
//			tRecordMapper.insertRecord(objectClassName, 2l);
//		} else {
//			// 更新当前的记录 +1
//			tRecordMapper.updateRecord(objectClassName, 1l);
//		}
		IdGen gen = IdGen.get();
		Long id = gen.nextId();
		return id;
//		String str = ConfigUtil.get("idGenerator.no", "1") + id;
//		return Long.parseLong(str);
	}

	public Long generateId() {
		IdGen gen = IdGen.get();
		Long id = gen.nextId();
		return id;
	}

	/**
	 * 为一个插入列表返回id，其中返回的id为最小的一个id
	 *
	 * @param objectClassName
	 * @param size
	 * @return
	 */
//	public Long generateIdForList(String objectClassName, int size) {
//		Long id = null;
//		id = tRecordMapper.getCurrentId(objectClassName);
//		long toSize = size;
//		// 如果为空说明没改记录，插入
//		if (id == null) {
//			id = 1l;
//			// 更新当前的id为2
//			tRecordMapper.insertRecord(objectClassName, toSize + 1);
//		} else {
//			// 更新当前的记录 +1
//			tRecordMapper.updateRecord(objectClassName, toSize);
//		}
//		return id;
//	}

}
