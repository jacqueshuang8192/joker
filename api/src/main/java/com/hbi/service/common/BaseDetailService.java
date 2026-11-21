//package com.hbi.service.common;
//
//import java.util.List;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.core.service.BaseService;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.BaseCacheController;
//import com.hbi.constants.Constants;
//import com.hbi.model.TBaseDetail;
//import com.hbi.utils.InfServerException;
//
//@Service
//public class BaseDetailService extends BaseService<TBaseDetail> {
//
//	@Autowired
//	private BaseCacheController baseCacheController;
//
//
//	public List<TBaseDetail> queryBackgroundSongs() throws Exception {
//		ICache cache = null;
//		try {
//			cache = CacheManager.getCache();
//			List<TBaseDetail> result = baseCacheController.queryBackgroundSongs(cache);
//
//			if (result == null) {
//				throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "查询不到背景音乐数据");
//			}
//			return result;
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			if (cache != null) {
//				CacheManager.releaseCache(cache);
//			}
//		}
//	}
//
//	public List<TBaseDetail> queryTheme() throws Exception {
//		ICache cache = null;
//		try {
//			cache = CacheManager.getCache();
//			List<TBaseDetail> result = baseCacheController.queryTheme(cache);
//
//			if (result == null) {
//				throw new InfServerException(Constants.RETURN_CODE_OBJECT_NOT_FOUND_ERROR, "查询不到主题数据");
//			}
//			return result;
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			if (cache != null) {
//				CacheManager.releaseCache(cache);
//			}
//		}
//	}
//}
