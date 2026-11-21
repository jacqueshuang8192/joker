//package com.hbi.schedule.service;
//
//import java.io.InputStreamReader;
//import java.util.ArrayList;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Set;
//import java.util.zip.GZIPInputStream;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.apache.http.client.config.RequestConfig;
//import org.apache.http.client.methods.CloseableHttpResponse;
//import org.apache.http.client.methods.HttpGet;
//import org.apache.http.impl.client.CloseableHttpClient;
//import org.apache.http.impl.client.HttpClients;
//import org.apache.http.util.EntityUtils;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.transaction.annotation.Transactional;
//
//import com.alibaba.fastjson.JSONArray;
//import com.alibaba.fastjson.JSONObject;
//import com.hbi.cache.CacheManager;
//import com.hbi.cache.ICache;
//import com.hbi.cache.controller.CommonCacheController;
//import com.hbi.constants.Constants;
//import com.hbi.mapper.TRadioStationContentMapper;
//import com.hbi.mapper.TRadioStationTypeMapper;
//import com.hbi.model.TRadioStationContent;
//import com.hbi.model.TRadioStationType;
//import com.hbi.service.idGenerate.GenerateIdService;
//import com.hbi.utils.CommonUtil;
//
//public class RadioStationContentScheduleService {
//
//    private static final Log log = LogFactory.getLog(RadioStationContentScheduleService.class);
//
//    @Autowired
//    private TRadioStationContentMapper radioStationContentMapper;
//    @Autowired
//    private TRadioStationTypeMapper radioStationTypeMapper;
//    @Autowired
//    private GenerateIdService generateIdService;
//    @Autowired
//    private CommonCacheController commonCacheController;
//
//    private RequestConfig requestConfig;
//
//    private TRadioStationType radioStationType;
//    private List<TRadioStationContent> radioStationContents;
//    private long minTime;
//    private long initialMinTime;
//
//    @Transactional
//    public void loadRadioStationJokeContent() throws Exception {
//
//        radioStationContents = new ArrayList<TRadioStationContent>();
//        ICache cache = null;
//        try {
//            cache = CacheManager.getCache();
//            TRadioStationType temp = new TRadioStationType();
//            temp.setCode(Constants.RADIO_STATION_JOKE_CONTENT);
//            radioStationType = radioStationTypeMapper.selectOne(temp);
//            if (radioStationType != null) {
//                initHttpClientConfig();
//                int i = 0;
//                boolean hasMore = false;
//                do {
//                    hasMore = loadNetworkRadioStationJokeContent(cache);
//                    i++;
//                } while (hasMore || i <= 10);
//
//                if (initialMinTime != 0) {
//                    for (int j = 0; j < 10; j++) {
//                        minTime = initialMinTime - 30000;
//                        loadNetworkRadioStationJokeContent(cache);
//                    }
//                }
//
//                if (radioStationContents.size() > 0) {
//                    // 去重
//                    Set<String> oldSourceIds = commonCacheController
//                            .queryRadioStationContentSourceIds(radioStationType.getId(), cache);
//                    Iterator<TRadioStationContent> iterator = radioStationContents.iterator();
//                    while (iterator.hasNext()) {
//                        TRadioStationContent rsc = iterator.next();
//                        if (oldSourceIds.contains(rsc.getSourceId().toString())) {
//                            iterator.remove();
//                        } else {
//                            oldSourceIds.add(rsc.getSourceId().toString());
//                        }
//                    }
//
////                    Long id = generateIdService.generateIdForList(TRadioStationContent.class.getName(),
////                            radioStationContents.size());
//                    for (TRadioStationContent rsc : radioStationContents) {
//                        Long id = generateIdService.generateId();
//                        rsc.setId(id);
//                        radioStationContentMapper.insert(rsc);
//                    }
//                }
//                commonCacheController.addRadioStationContentsByType(radioStationContents, radioStationType.getId(),
//                        cache);
//            }
//
//        } catch (Exception e) {
//            log.error(CommonUtil.buildErrorLog(e));
//        } finally {
//            if (cache != null) {
//                CacheManager.releaseCache(cache);
//            }
//        }
//    }
//
//    private boolean loadNetworkRadioStationJokeContent(ICache cache) throws Exception {
//        boolean hasMore = false;
//        CloseableHttpResponse response = null;
//        GZIPInputStream gzin = null;
//        InputStreamReader isr = null;
//        try {
//            CloseableHttpClient httpClient = HttpClients.createDefault();
//            String url = "http://m.neihanshequ.com/?skip_guidence=1&is_json=1&app_name=neihanshequ_web&min_time=";
//            if (minTime != 0) {
//                minTime += 6000;
//                url += minTime;
//            }
//
//            HttpGet httpGet = new HttpGet(url);
//            httpGet.setConfig(requestConfig);
//            httpGet.setHeader("Accept", "*/*");
//            // httpGet.setHeader("Accept-Encoding", "gzip, deflate");
//            httpGet.setHeader("Accept-Language", "zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3");
//            httpGet.setHeader("Connection", "keep-alive");
//            httpGet.setHeader("Host", "m.neihanshequ.com");
//            httpGet.setHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:44.0) Gecko/20100101 Firefox/44.0");
//
//            response = httpClient.execute(httpGet);
//            String res = EntityUtils.toString(response.getEntity());
//            System.out.println(res);
//            // 解压
//            /*
//             * gzin = new GZIPInputStream(response.getEntity().getContent());
//             * isr = new InputStreamReader(gzin, "UTF-8"); BufferedReader br =
//             * new BufferedReader(isr); StringBuffer resBuff = new
//             * StringBuffer(); String tempbf; while ((tempbf = br.readLine()) !=
//             * null) { resBuff.append(tempbf); }
//             */
//
//            JSONObject jsonObject = JSONObject.parseObject(res);
//            if (jsonObject != null) {
//                JSONObject dataObj = jsonObject.getJSONObject("data");
//                if (dataObj != null) {
//                    hasMore = dataObj.getBoolean("has_more");
//                    if (minTime == 0) {
//                        minTime = dataObj.getLongValue("min_time");
//                        initialMinTime = minTime;
//                    }
//
//                    JSONArray datas = dataObj.getJSONArray("data");
//                    if (datas != null && datas.size() > 0) {
//                        for (int i = 0; i < datas.size(); i++) {
//                            JSONObject obj = datas.getJSONObject(i);
//                            if (obj != null) {
//                                JSONObject group = obj.getJSONObject("group");
//                                if (group != null) {
//                                    TRadioStationContent radioStationContent = new TRadioStationContent();
//                                    if (group.containsKey("content")) {
//                                        radioStationContent.setContent(group.getString("content"));
//                                    } else {
//                                        continue;
//                                    }
//                                    // radioStationContent
//                                    // .setId(generateIdService.generateId(TRadioStationContent.class.getName()));
//                                    radioStationContent.setTypeId(radioStationType.getId());
//                                    if (group.containsKey("id")) {
//                                        radioStationContent.setSourceId(group.getLong("id"));
//                                    }
//                                    radioStationContents.add(radioStationContent);
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        } catch (Exception e) {
//            throw e;
//        } finally {
//            if (response != null) {
//                response.close();
//            }
//            if (isr != null) {
//                isr.close();
//            }
//            if (gzin != null) {
//                gzin.close();
//            }
//        }
//        return hasMore;
//    }
//
//    private void initHttpClientConfig() {
//        if (requestConfig == null) {
//            requestConfig = RequestConfig.custom().setSocketTimeout(10000).setConnectTimeout(2000).build();// 设置请求和传输超时时间
//        }
//    }
//
//}
