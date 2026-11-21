//package com.hbi.cache.cacheWritter;
//
//import java.util.List;
//
//import org.apache.commons.lang.StringUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.hbi.cache.model.CacheCompereListProfile;
//import com.hbi.cache.model.CacheCompereProfile;
//import com.hbi.cache.model.CacheCompereRelation;
//import com.hbi.cache.model.CachePlayerListProfile;
//import com.hbi.mapper.TAlbumMapper;
//import com.hbi.mapper.TAttentionMapper;
//import com.hbi.mapper.TCompereAssistantMapper;
//import com.hbi.mapper.TCompereIncomeMapper;
//import com.hbi.mapper.TCompereMapper;
//import com.hbi.mapper.TUserGoodsMapper;
//import com.hbi.mapper.TUserGoodsPresentRecordMapper;
//import com.hbi.model.TAttention;
//import com.hbi.model.TCompere;
//import com.hbi.model.TCompereAssistant;
//import com.hbi.model.TCompereIncome;
//import com.hbi.model.TUserGoods;
//import com.hbi.model.TUserGoodsPresentRecord;
//
//@Service
//public class CompereCacheLoader {
//
//	@Autowired
//	private TAttentionMapper attentionMapper;
//
//	@Autowired
//	private TAlbumMapper albumMapper;
//
//	@Autowired
//	private TCompereMapper compereMapper;
//
//	@Autowired
//	private TCompereAssistantMapper assistantMapper;
//
//	@Autowired
//	private TUserGoodsMapper userGoodsMapper;
//	@Autowired
//	private TUserGoodsPresentRecordMapper userGoodsPresentRecordMapper;
//	@Autowired
//	private TCompereIncomeMapper compereIncomeMapper;
//
//	public CacheCompereProfile loadCompereDetails(String compereId) throws Exception {
//
//		CacheCompereProfile cacheVo = compereMapper.queryCompereDetails(Long.parseLong(compereId));
//
//		if (cacheVo == null) {
//			return null;
//		} else {
//
//		    if (!StringUtils.isBlank(cacheVo.getPayPassword())) {
//	            cacheVo.setHasPayPassword(true);
//	        } else {
//	            cacheVo.setHasPayPassword(false);
//	        }
//	        cacheVo.setPayPassword(null);
//
//			TAttention attention = new TAttention();
//			attention.setCompereId(Long.parseLong(compereId));
//			int fansCount = attentionMapper.selectCount(attention);
//
////			TMoments moments = new TMoments();
////			moments.setUserId(Long.parseLong(compereId));
//
////			TAlbum album = new TAlbum();
////			album.setUserid(Long.parseLong(compereId));
////			List<TAlbum> albums = albumMapper.select(album);
//
//			TCompereAssistant assistant = new TCompereAssistant();
//			assistant.setCompereId(Long.parseLong(compereId));
//			List<TCompereAssistant> assistants = assistantMapper.select(assistant);
//
//			cacheVo.setFansCount(fansCount);
//
////			if (albums != null) {
////				Map<String, String> mediaUrls = new HashMap<String, String>();
////				for (TAlbum t : albums) {
////					Date d = t.getUploadDate();
////					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
////					String dateStr = sdf.format(d);
////
////					String value = mediaUrls.get(dateStr);
////
////					if (value == null) {
////						value = t.getType() + ":" + t.getPath();
////						mediaUrls.put(dateStr, value);
////					} else {
////						value += "_" + t.getType() + ":" + t.getPath();
////						mediaUrls.put(dateStr, value);
////					}
////
////				}
////
////				cacheVo.setMediaUrls(mediaUrls);
////			}
//
//			if (assistants != null) {
//				String idsStr = "";
//				for (TCompereAssistant t : assistants) {
//					idsStr += "_" + t.getManagerId();
//				}
//
//				if (idsStr.length() > 0) {
//					idsStr = idsStr.substring(1);
//				}
//
//				cacheVo.setAdmins(idsStr);
//			}
//			return cacheVo;
//		}
//	}
//
//	public List<TUserGoods> loadExchangeRecords(String compereId) throws Exception {
//		TUserGoods e = new TUserGoods();
//		/*e.setGiverId(88888l);
//		e.setUserId(Long.parseLong(compereId));
//		e.setType("3");*/
//		List<TUserGoods> result = userGoodsMapper.select(e);
//
//		return result;
//	}
//
//	public List<TUserGoods> loadGiveJewelRecords(String compereId) throws Exception {
//		TUserGoods e = new TUserGoods();
//		/*e.setGiverId(Long.parseLong(compereId));
//		e.setType("3");*/
//		List<TUserGoods> result = userGoodsMapper.select(e);
//
//		return result;
//	}
//
//	public List<CachePlayerListProfile> loadFans(String compereId) throws Exception {
//		return compereMapper.queryFansByCompereId(Long.parseLong(compereId));
//	}
//
//	public List<TUserGoodsPresentRecord> loadGiftsByRoom(String roomId) throws Exception {
//		return userGoodsPresentRecordMapper.queryPresentRecordByRoom(Long.parseLong(roomId));
//	}
//
//	public List<TUserGoodsPresentRecord> loadPresentRecordByDateRange(Long compereId, String startDate, String endDate) throws Exception {
//		return userGoodsPresentRecordMapper.queryPresentRecordByDateRange(compereId, startDate, endDate);
//	}
//
//	public List<TUserGoods> loadAllGifts(String compereId) throws Exception {
//		return userGoodsMapper.queryAllByCompere(Long.parseLong(compereId));
//	}
//
//	public List<CachePlayerListProfile> loadContributionRank(String compereId) throws Exception {
//		return compereMapper.queryContributionRank(Long.parseLong(compereId));
//	}
//
//	public List<CacheCompereListProfile> loadCompereRank() {
//		return compereMapper.queryCompereRank();
//	}
//
//	public List<CacheCompereListProfile> loadCompereNearbyCityId(String cityId) {
//		return compereMapper.queryCompereNearbyCityId(cityId);
//	}
//
//	public List<TCompere> loadAllComperes() {
//		return compereMapper.select(new TCompere());
//	}
//
//	public CacheCompereRelation loadCompereRelation(Long compereId) {
//		return compereMapper.queryCompereAllRelation(compereId);
//	}
//
//	public List<String> loadCompereIncomeDatesByByDateRange(Long compereId, String startDate, String endDate, String nowDate) {
//	    return compereIncomeMapper.queryCompereIncomeDatesByDateRange(compereId, startDate, endDate, nowDate);
//	}
//
//	public TCompereIncome loadCompereIncomeByDate(Long compereId, String date) {
//        return compereIncomeMapper.queryCompereIncomeByDate(compereId, date);
//    }
//
//	public Integer loadComperePriority(String compereId) {
//		TCompere compere = compereMapper.selectByPrimaryKey(Long.parseLong(compereId));
//		return compere.getPriority();
//	}
//}
