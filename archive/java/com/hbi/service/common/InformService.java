//package com.hbi.service.common;
//
//import java.util.Date;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//
//import com.core.service.BaseService;
//import com.hbi.model.TInform;
//import com.hbi.service.idGenerate.GenerateIdService;
//
//@Service
//public class InformService extends BaseService<TInform>{
//
//    @Autowired
//    private GenerateIdService idService;
//
//    /**
//     * 举报
//     * @param informerId
//     * @param informantId
//     * @param content
//     * @throws Exception
//     */
//    public void informUser(Long informerId, Long informantId, String content, Integer type) throws Exception {
//        TInform inform = new TInform();
//        inform.setId(idService.generateId(TInform.class.getName()));
//        inform.setInformantId(informantId);
//        inform.setInformerId(informerId);
//        inform.setContent(content);
//        inform.setType(type);
//        inform.setCreateDate(new Date());
//        save(inform);
//    }
//}
