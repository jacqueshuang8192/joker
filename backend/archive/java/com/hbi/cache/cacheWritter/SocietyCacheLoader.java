//package com.hbi.cache.cacheWritter;
//
//import java.text.SimpleDateFormat;
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.List;
//
//import com.hbi.constants.Constants;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.hbi.cache.model.CacheSocietyProfile;
//import com.hbi.mapper.TMiningGameSectionMapper;
//import com.hbi.mapper.TSocietyManagerMapper;
//import com.hbi.mapper.TSocietyMapper;
//import com.hbi.model.TMiningGameSection;
//import com.hbi.model.TSociety;
//import tk.mybatis.mapper.entity.Example;
//
//@Service
//public class SocietyCacheLoader {
//    @Autowired
//    private TSocietyMapper societyMapper;
//
//    @Autowired
//    private TSocietyManagerMapper societyManagerMapper;
//
//    @Autowired
//    private TMiningGameSectionMapper sectionMapper;
//
//    public CacheSocietyProfile loadSocietyProfile(Long societyId) {
//        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//        CacheSocietyProfile cacheSocietyProfile = societyMapper
//                .getSocietyDetail(societyId, format.format(new Date()));
//        if (cacheSocietyProfile == null) {
//            return null;
//        }
//        if (cacheSocietyProfile.getActivityId() == null) {
//            cacheSocietyProfile.setActivityId(0l);
//        }
//        TSociety society = new TSociety();
//        society.setSocietyId(societyId);
//        List<String> managerList = societyManagerMapper
//                .queryManagerIdList(societyId);
//        cacheSocietyProfile.setAdmins(managerList);
//
////        String photos =
////        cacheSocietyProfile.setPhotos(photos);
//        return cacheSocietyProfile;
//    }
//
//    public List<TMiningGameSection> loadMineSegments(Long activityId) {
//        TMiningGameSection section = new TMiningGameSection();
//        section.setActivityId(activityId);
//        List<TMiningGameSection> list = sectionMapper.select(section);
//        return list;
//    }
//
//    public List<Long> queryAllSocieties() {
//        List<Long> ids = new ArrayList<Long>();
//        Example example = new Example(TSociety.class);
//        Example.Criteria criteria = example.createCriteria();
//        criteria.andNotEqualTo("status", Constants.SOCIETY_INVALID);
//        List<TSociety> societies = societyMapper.selectByExample(example);
//        for (TSociety s : societies) {
//            ids.add(s.getSocietyId());
//        }
//        return ids;
//    }
//
//}
