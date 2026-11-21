//package com.hbi.cache.cacheWritter;
//
//import java.util.Date;
//import java.util.List;
//
//import com.hbi.model.TCompere;
//import org.apache.commons.collections.CollectionUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.hbi.mapper.TCaptureDefenderMapper;
//import com.hbi.mapper.TCaptureSpellMapper;
//import com.hbi.mapper.TCompereMapper;
//import com.hbi.model.TCaptureDefender;
//import com.hbi.model.TCaptureSpell;
//
//import tk.mybatis.mapper.entity.Example;
//import tk.mybatis.mapper.entity.Example.Criteria;
//
//@Service
//public class CaptureCacheLoader {
//    @Autowired
//    private TCaptureDefenderMapper defenderMapper;
//    @Autowired
//    private TCompereMapper compereMapper;
//    @Autowired
//    private TCaptureSpellMapper spellMapper;
//
//    public List<TCaptureDefender> queryDefenderListByCompereId(Long compereId) {
////        Example example = new Example(TCaptureDefender.class);
////        Criteria criteria = example.createCriteria();
////        criteria.andEqualTo("compereId", compereId);
////        Date nowDate = new Date();
////        criteria.andGreaterThan("endDate", nowDate);
////        criteria.andLessThan("startDate", nowDate);
////        List<TCaptureDefender> list = defenderMapper.selectByExample(example);
//        List<TCaptureDefender> list = defenderMapper.queryDefendersByCompereId(compereId, new Date());
//        return list;
//    }
//
//    public List<TCaptureDefender> queryDefenderListByPlayerId(Long playerId) {
////        Example example = new Example(TCaptureDefender.class);
////        Criteria criteria = example.createCriteria();
////        criteria.andEqualTo("playerId", playerId);
////        Date nowDate = new Date();
////        criteria.andGreaterThan("endDate", nowDate);
////        criteria.andLessThan("startDate", nowDate);
////        List<TCaptureDefender> list = defenderMapper.selectByExample(example);
//        List<TCaptureDefender> list = defenderMapper.queryDefendersByPlayerId(playerId, new Date());
//        return list;
//    }
//
//    public List<Long> queryMyWivesById(Long playerId) {
//        return compereMapper.queryMyWives(playerId);
//    }
//
//    public List<TCaptureSpell> querySpells() {
//        return spellMapper.select(new TCaptureSpell());
//    }
//
//    public TCompere queryCaptureTotalLife(Long compereId) {
//        TCompere compere = new TCompere();
//        compere.setCompereId(compereId);
//        List<TCompere> list = compereMapper.select(compere);
//        if (CollectionUtils.isNotEmpty(list)) {
//            return list.get(0);
//        }
//        return null;
////        return compereMapper.queryCaptureTotalLifeList(cityId);
//    }
//
//}
