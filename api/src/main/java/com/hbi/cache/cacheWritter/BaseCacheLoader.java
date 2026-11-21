package com.hbi.cache.cacheWritter;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.hbi.mapper.*;
import com.hbi.model.*;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.core.beanUtil.BeanMapUtils;
import com.core.util.DateUtils;
import com.hbi.cache.model.CacheExtractStrategyProfile;
import com.hbi.cache.model.CachePrivilegeRule;
import com.hbi.constants.Constants;

@Service
public class BaseCacheLoader {
    @Autowired
    private TProvinceMapper provinceMapper;
    @Autowired
    private TCityMapper cityMapper;
    @Autowired 
    private TTownMapper townMapper;
//    @Autowired
//    private TBaseDetailMapper baseDetailMapper;
//    @Autowired
//    private TPlatformLevelMapper platformLevelMapper;
//    @Autowired
//    private TCompereLevelMapper compereLevelMapper;
//    @Autowired
//    private TVipLevelMapper vipLevelMapper;
    @Autowired
    private TConfigMapper configMapper;
//    @Autowired
//    private TExtractStrategyMapper extractStrategyMapper;
//    @Autowired
//    private TExtractStrategyDetailMapper extractStrategyDetailMapper;
//    @Autowired
//    private TIndividuationExtractStrategyMapper individuationExtractStrategyMapper;
    @Autowired
    private TVersionMapper versionMapper;
    @Autowired
    private TAnnouncementMapper announcementMapper;
//    @Autowired
//    private TDataVersionMapper dataVersionMapper;
//    @Autowired
//    private TRoomRedPacketMapper roomRedPacketMapper;
//    @Autowired
//    private TAllowanceMapper allowanceMapper;
    @Autowired
    private LandlordScoreSectionMapper landlordScoreSectionMapper;
    
    public List<TProvince> loadCountry() {
        List<TProvince> provinces = provinceMapper.select(new TProvince());
        List<TCity> cities = cityMapper.select(new TCity());
        List<TTown> towns = townMapper.select(new TTown());
        
        for(TCity city : cities) {
            List<TTown> tempTownList = new ArrayList<TTown>();
            for(TTown town : towns) {
                if(town.getCityId() == city.getCityId()) {
                    tempTownList.add(town);
                }
            }
            city.setTowns(tempTownList);
        }
        
        for(TProvince province : provinces) {
            List<TCity> tempCityList = new ArrayList<TCity>();
            for(TCity city : cities) {
                if(city.getProvinceId() == province.getProvinceId()) {
                    tempCityList.add(city);
                }
            }
            province.setCities(tempCityList);
        }
        return provinces;
    }
    
//    public List<CachePrivilegeRule> queryPrivileges() throws Exception {
//        List<CachePrivilegeRule> privilegeRules = new ArrayList<CachePrivilegeRule>();
//        List<TCompereLevel> compereLevels = compereLevelMapper.select(new TCompereLevel());
//        List<TVipLevel> vipLevels = vipLevelMapper.select(new TVipLevel());
//        List<TPlatformLevel> platformLevels = platformLevelMapper.select(new TPlatformLevel());
//        for(TCompereLevel compereLevel : compereLevels) {
//            Map<String, String> map = BeanMapUtils.toMap(compereLevel);
//            CachePrivilegeRule rule = (CachePrivilegeRule) BeanMapUtils.toBean(CachePrivilegeRule.class, map);
//            privilegeRules.add(rule);
//        }
//        for(TVipLevel vipLevel : vipLevels) {
//            Map<String, String> map = BeanMapUtils.toMap(vipLevel);
//            CachePrivilegeRule rule = (CachePrivilegeRule) BeanMapUtils.toBean(CachePrivilegeRule.class, map);
//            privilegeRules.add(rule);
//        }
//        for(TPlatformLevel platformLevel : platformLevels) {
//            Map<String, String> map = BeanMapUtils.toMap(platformLevel);
//            CachePrivilegeRule rule = (CachePrivilegeRule) BeanMapUtils.toBean(CachePrivilegeRule.class, map);
//            privilegeRules.add(rule);
//        }
//        return privilegeRules;
//    }
    
    public List<TConfig> queryConfig() throws Exception {
        return configMapper.select(new TConfig());
    }
    
//    public List<TBaseDetail> loadBaseDetailByType(String classificationCode) {
//    	return baseDetailMapper.findBaseDetailByClassificationCode(classificationCode);
//    }
//
//    public List<TPlatformLevel> loadPlatformLevel() {
//        return platformLevelMapper.select(new TPlatformLevel());
//    }
//
//    public List<TCompereLevel> loadCompereLevel() {
//        return compereLevelMapper.select(new TCompereLevel());
//    }
//
    /**
     * 获取普通分成策略
     * @return
     */
//    public List<CacheExtractStrategyProfile> loadBaseExtractStrategies() {
//        List<CacheExtractStrategyProfile> strategyProfiles = null;
//    	TExtractStrategy temp = new TExtractStrategy();
//    	temp.setStatus(Constants.VALID);
//    	List<TExtractStrategy> extractStrategies = extractStrategyMapper.select(temp);
//    	TExtractStrategyDetail esdTemp = new TExtractStrategyDetail();
//        List<TExtractStrategyDetail> extractStrategyDetails = extractStrategyDetailMapper.select(esdTemp);
//        if (CollectionUtils.isNotEmpty(extractStrategies) && CollectionUtils.isNotEmpty(extractStrategyDetails)) {
//            strategyProfiles = new ArrayList<CacheExtractStrategyProfile>();
//            for (TExtractStrategy extractStrategy : extractStrategies) {
//                CacheExtractStrategyProfile cesp = new CacheExtractStrategyProfile();
//                cesp.setId(extractStrategy.getStrategyId());
//                cesp.setSource(extractStrategy.getSource());
//                cesp.setStatus(extractStrategy.getStatus());
//                Iterator<TExtractStrategyDetail> iterator = extractStrategyDetails.iterator();
//                while(iterator.hasNext()) {
//                    TExtractStrategyDetail esd = iterator.next();
//                    if (esd.getStrategyId().equals(extractStrategy.getStrategyId())) {
//                        if (Constants.USER_TYPE_PLATFORM.equals(esd.getPart())) {
//                            cesp.setPlatformPercentage(esd.getPercentage());
//                            cesp.setPlatformCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_OPERATOR.equals(esd.getPart())) {
//                            cesp.setOperatorPercentage(esd.getPercentage());
//                            cesp.setOperatorCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_PRIMARY_AGENT.equals(esd.getPart())) {
//                            cesp.setPrimaryAgentPercentage(esd.getPercentage());
//                            cesp.setPrimaryAgentCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_SECONDARY_AGENT.equals(esd.getPart())) {
//                            cesp.setSecondaryAgentPercentage(esd.getPercentage());
//                            cesp.setSecondaryAgentCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_THIRDLY_AGENT.equals(esd.getPart())) {
//                            cesp.setThirdlyAgentPercentage(esd.getPercentage());
//                            cesp.setThirdlyAgentCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_MANAGER.equals(esd.getPart())) {
//                            cesp.setManagerPercentage(esd.getPercentage());
//                            cesp.setManagerCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_COMPERE.equals(esd.getPart())) {
//                            cesp.setComperePercentage(esd.getPercentage());
//                            cesp.setCompereCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_SUPPLIER.equals(esd.getPart())) {
//                            cesp.setSupplierPercentage(esd.getPercentage());
//                            cesp.setSupplierCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        } else if (Constants.USER_TYPE_USER.equals(esd.getPart())) {
//                            cesp.setUserPercentage(esd.getPercentage());
//                            cesp.setUserCurrency(esd.getCurrency());
//                            strategyProfiles.add(cesp);
//                        }
//                        iterator.remove();
//                    }
//                }
//            }
//        }
//
//    	return strategyProfiles;
//    }
    
//    public List<CacheExtractStrategyProfile> loadIndividuationExtractStrategiesByManagerId(String source, Long managerId) {
//        return individuationExtractStrategyMapper.findIndividuationExtractStrategiesByManagerId(source, managerId);
//    }
    
    /**
     * 获取所有应用平台的版本
     * @return
     */
    public Map<String, TVersion> loadNewestApplicationVersions() {
        Map<String, TVersion> versionMaps = null;
        List<TVersion> versions = versionMapper.queryNewestApplicationVersions();
        if (CollectionUtils.isNotEmpty(versions)) {
            versionMaps = new HashMap<String, TVersion>();
            for (TVersion version : versions) {
                if (versionMaps.containsKey(version.getApplicationType())) {
                    TVersion oldVersion = versionMaps.get(version.getApplicationType());
                    if (compareVersion(version.getVersion(), oldVersion.getVersion()) > 0) {
                        versionMaps.put(version.getApplicationType(), version);
                    }
                } else {
                    versionMaps.put(version.getApplicationType(), version);
                }
            }
        }
        return versionMaps;
    }
    
    /**
     * 获取游戏大厅版本
     * @return
     */
    public TVersion loadNewestGameHallVersions() {
        TVersion versionResult = null;
        List<TVersion> versions = versionMapper.queryNewestGameHallVersions();
        if (CollectionUtils.isNotEmpty(versions)) {
            for (TVersion version : versions) {
                if (versionResult != null) {
                    if (compareVersion(version.getVersion(), versionResult.getVersion()) > 0) {
                        versionResult = version;
                    }
                } else {
                    versionResult = version;
                }
            }
        }
        return versionResult;
    }
    
    public TVersion loadNewestGameVersionByGameId(Long gameId) {
        TVersion versionResult = null;
        List<TVersion> versions = versionMapper.queryNewestGameVersionByGameIds(gameId);
        if (CollectionUtils.isNotEmpty(versions)) {
            for (TVersion version : versions) {
                if (versionResult != null) {
                    if (compareVersion(version.getVersion(), versionResult.getVersion()) > 0) {
                        versionResult = version;
                    }
                } else {
                    versionResult = version;
                }
            }
        }
        return versionResult;
    }
    
    public List<TAnnouncement> loadAnnouncementsByType(String type) {
        return announcementMapper.queryAnnouncementsByType(type, new Date());
    }
    
    /**
     * 版本比较
     * @param v1
     * @param v2
     * @return
     */
    private int compareVersion(String v1, String v2) {
        String[] v1s = v1.split("\\.");
        String [] v2s = v2.split("\\.");
        int minLength = Math.min(v1s.length, v2s.length);
        for (int i = 0; i < minLength; i++) {
            if (Integer.parseInt(v1s[i]) > Integer.parseInt(v2s[i])) {
                return 1;
            } else if (Integer.parseInt(v1s[i]) < Integer.parseInt(v2s[i])) {
                return -1;
            }
        }
        return 0;
    }
//
//    public List<TDataVersion> queryDataVersions() {
//        return dataVersionMapper.select(new TDataVersion());
//    }
//
//    public List<TRoomRedPacket> queryRedPacketLevels() {
//        return roomRedPacketMapper.select(new TRoomRedPacket());
//    }
//
//    public List<TAllowance> queryAllowanceList(Integer cardType) {
//        TAllowance allowance = new TAllowance();
//        allowance.setCardType(cardType);
//        return allowanceMapper.select(allowance);
//    }

    public LandlordScoreSection queryScoreSectio() {
        return landlordScoreSectionMapper.select(new LandlordScoreSection()).get(0);
    }
}
