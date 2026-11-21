//package com.hbi.service.common;
//
//import java.util.ArrayList;
//import java.util.Collections;
//import java.util.Iterator;
//import java.util.List;
//
//import org.apache.commons.collections.CollectionUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.cache.model.CacheMerchantGoodsProfile;
//import com.hbi.cache.model.CacheMerchantStoreProfile;
//import com.hbi.cache.model.CacheStoreCategory;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TMerchantGoodsMapper;
//import com.hbi.utils.InfServerException;
//import com.hbi.vo.response.onlineStore.RecommendedStore;
//
//@Service
//public class OnlineStoreService {
//
//	@Autowired
//	private CommonCacheController commonCacheController;
//
//	@Autowired
//	private TMerchantGoodsMapper merchantGoodsMapper;
//
//	/**
//	 * 获取线上商城商品分类
//	 * @return
//	 */
//	public List<CacheStoreCategory> queryStoreCategories(Long cityId) throws Exception {
//		ICache cache = null;
//		try {
//			cache = CacheManager.getCache();
//			return commonCacheController.queryStoreCategories(cityId, cache);
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			if (cache != null) {
//				CacheManager.releaseCache(cache);
//			}
//		}
//	}
//
//	/**
//	 * 获取线上商城店铺
//	 * @param cityId
//	 * @param categoryId
//	 * @param categoryType
//	 * @return
//	 * @throws Exception
//	 */
//	public List<CacheMerchantStoreProfile> queryStores(Long cityId, long categoryId, String categoryType) throws Exception {
//	    ICache cache = null;
//		try {
//		    cache = CacheManager.getCache();
//		    return commonCacheController.queryStores(cityId, categoryId, categoryType, cache);
//		} catch (Exception e) {
//			throw e;
//		} finally {
//			if (cache != null) {
//				CacheManager.releaseCache(cache);
//			}
//		}
//	}
//
//	/**
//     * 获取线上商城店铺
//     * @param cityId
//     * @return
//     * @throws Exception
//     */
//    public List<RecommendedStore> queryRecommendedStores(Long cityId) throws Exception {
//        List<RecommendedStore> recommendedStores = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<CacheStoreCategory> categories = commonCacheController.queryStorePrimaryCategories(cache);
//            if (CollectionUtils.isNotEmpty(categories)) {
//                recommendedStores = new ArrayList<RecommendedStore>();
//                for (CacheStoreCategory category : categories) {
//
//                    List<CacheMerchantStoreProfile> stores = new ArrayList<CacheMerchantStoreProfile>();
//                    List<CacheMerchantStoreProfile> tempStores = commonCacheController.queryStores(cityId, category.getCategoryId(), Constants.MERCHANT_PRIMARY_CATEGORY, cache);
//                    if (CollectionUtils.isNotEmpty(tempStores)) {
//                        Collections.sort(tempStores, Collections.reverseOrder());
//                        RecommendedStore recommendedStore = new RecommendedStore();
//                        recommendedStore.setCategoryId(category.getCategoryId());
//                        recommendedStore.setCategoryName(category.getName());
//                        for (int i = 0; i < tempStores.size(); i++) {
//                            stores.add(tempStores.get(i));
//                            if (i == 1) {
//                                break;
//                            }
//                        }
//                        recommendedStore.setStores(stores);
//                        recommendedStores.add(recommendedStore);
//                    }
//                }
//            }
//            return recommendedStores;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//	/**
//     * 获取线上商城商品详情
//     * @return
//	 * @throws Exception
//     */
//    public CacheMerchantGoodsProfile queryMerchantGoodsDetail(Long merchantGoodsId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            return commonCacheController.queryMerchantGoodsDetail(merchantGoodsId, cache);
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 获取店铺详情
//     * @param storeId
//     * @return
//     * @throws Exception
//     */
//    public CacheMerchantStoreProfile queryStoreDetail(Long storeId) throws Exception {
//        CacheMerchantStoreProfile store = null;
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            store = commonCacheController.queryStoreDetail(storeId, cache);
//            return store;
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    /**
//     * 购买商品
//     * @param merchantGoodsId
//     * @throws Exception
//     */
//    public void buyMerchantGoods(long merchantGoodsId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            int count = merchantGoodsMapper.updateMerchantGoodsHotAndPrice(merchantGoodsId);
//            if (count > 0) {
//                commonCacheController.updateMerchantGoodsAndStoreHot(merchantGoodsId, cache);
//            } else {
//                throw new InfServerException(Constants.RETURN_CODE_FAIL, "更新商品热度失败");
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//
//    }
//
//    public List<CacheMerchantStoreProfile> queryAds(Long cityId) throws Exception {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<CacheMerchantStoreProfile> adList = commonCacheController.queryAdStores(cityId, cache);
//            return adList;
//        } catch (Exception e) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.toString());
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    public List<CacheMerchantStoreProfile> queryStoreByName(Long cityId, String name) {
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            List<CacheMerchantStoreProfile> stores = commonCacheController.queryStoresByCity(cityId, cache);
//            Iterator<CacheMerchantStoreProfile> iterator = stores.iterator();
//            while (iterator.hasNext()) {
//                CacheMerchantStoreProfile profile = iterator.next();
//                if (profile.getStoreName().indexOf(name) == -1) {
//                    iterator.remove();
//                }
//            }
//            return stores;
//        } catch (Exception e) {
//            throw new InfServerException(Constants.RETURN_CODE_FAIL, e.toString());
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//}
