//package com.hbi.service.schedule;
//
//import com.core.util.ConfigUtil;
//import com.hbi.mapper.TUserMapper;
//import com.hbi.vo.request.common.MapVo;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.scheduling.annotation.Scheduled;
//import org.springframework.stereotype.Service;
//
//import java.util.List;
//
//@Service
//public class schedule {
//
//    @Autowired
//    private TUserMapper userMapper;
//
//    //定时任务,统计代理的房卡分成
//    @Scheduled(cron="${Scheduled.cardRepart}")
//    public void sanjiMoney() {
//        String s = ConfigUtil.get("commission.type");
//        if ("1".equals(s)) {
//            //上级设置下级代理的分销模式
//            ims_tpmoney();
//        }else {
//            cardReport();
//        }
//    }
//
//    private void ims_tpmoney() {
//        System.out.println("开始处理代理的房卡收益 typ=1");
//        List<String> agentlist = userMapper.selectAllagents();
//        System.out.println(agentlist.size() + "size");
//        for (String agentId: agentlist) {
//            Integer agentGoldMoneyA = 0;
//            Integer agentGoldMoneyB = 0;
//            Integer agentGoldMoneyC = 0;
//            Integer agentMoneyA = 0;
//            Integer agentMoneyB = 0;
//            Integer agentMoneyC = 0;
//
//            Integer robotUse = 0;
//
//            Integer parentMoneyCard = 0;
//            Integer parentMoneyGold = 0;
//
//            MapVo map;
//            Integer agentOrderCount = 0;
//            Integer channelMoney = 0;
//
////            if (!"1".equals(agentId)) {
//                //代理钻的金币数
//                int i = Integer.parseInt(agentId) % 10;
//                agentGoldMoneyA = userMapper.selectAgentImsTpmoney(agentId,i);
//                agentGoldMoneyB = 0;
//                agentGoldMoneyC = 0;
//                //代理有多少个玩家玩了,总共玩了多少把
//                map = userMapper.selectAgentGoldinfoImsTpmoney(agentId,i);
//                //代理的房卡分成
//                agentMoneyA =  userMapper.selectAgentMoneyCountAImstpmoney(agentId,i);
//                agentMoneyB =  0;
//                agentMoneyC =  0;
//                //代理的玩家下的订单数量
//                agentOrderCount = userMapper.selectAgentOrderCountImstpmoney(agentId,i);
////            }else {
////                agentGoldMoneyA = userMapper.selectAgentImsTpmoney("1",1);
////                //代理有多少个玩家玩了,总共玩了多少把
////                map = userMapper.selectAgentGoldinfoImsTpmoney("1",1);
////                //代理的房卡分成
////                agentMoneyA =  userMapper.selectAgentMoneyCountAImstpmoney("1",1);
////                //代理的玩家下的订单数量
////                agentOrderCount = userMapper.selectAgentOrderCountImstpmoney("1",1);
////            }
//
//            //代理的损耗
//            Integer useMoney = userMapper.selectAgentUseMoney(agentId);
//            if ("1".equals(agentId)) {
//                //计算平台支出的渠道费
//                channelMoney = userMapper.selectCommissionMoney();
//                robotUse = userMapper.selectRobotUse();
//            }
//
//
//            //给代理贡献了多少  房卡和金币
//            parentMoneyCard = userMapper.selectParnetMoneyCard(agentId,i);
//            parentMoneyGold = userMapper.selectParnetMoneyGold(agentId,i);
//
//
//            int surplus = agentGoldMoneyA+agentGoldMoneyB+agentGoldMoneyC + agentMoneyA + agentMoneyB + agentMoneyC - useMoney -channelMoney + robotUse;
//            userMapper.insertIntoImstpagentcardreport(agentId,agentGoldMoneyA,agentGoldMoneyB,agentGoldMoneyC,map.getMapKey(),map.getMapValue(),agentMoneyA,agentMoneyB,agentMoneyC,agentOrderCount,useMoney,channelMoney,robotUse,surplus,parentMoneyCard,parentMoneyGold);
//        }
//        System.out.println("结束处理代理的房卡收益 typ=1");
//    }
//
//
//    public void cardReport() {
//        System.out.println("开始处理代理的房卡收益 typ=0");
//        List<String> agentlist = userMapper.selectAllagents();
//        for (String agentId: agentlist) {
//            Integer agentGoldMoneyA = 0;
//            Integer agentGoldMoneyB = 0;
//            Integer agentGoldMoneyC = 0;
//            Integer agentMoneyA = 0;
//            Integer agentMoneyB = 0;
//            Integer agentMoneyC = 0;
//
//            Integer robotUse = 0;
//
//            MapVo map;
//            Integer agentOrderCount = 0;
//            Integer channelMoney = 0;
//
//
//
//            if (!"1".equals(agentId)) {
//                //代理钻的金币数
//                agentGoldMoneyA = userMapper.selectAgentGoldMoneyA(agentId);
//                agentGoldMoneyB = userMapper.selectAgentGoldMoneyB(agentId);
//                agentGoldMoneyC = userMapper.selectAgentGoldMoneyC(agentId);
//                //代理有多少个玩家玩了,总共玩了多少把
//                map = userMapper.selectAgentGoldinfo(agentId);
//                //代理的房卡分成
//                agentMoneyA =  userMapper.selectAgentMoneyCountA(agentId);
//                agentMoneyB =  userMapper.selectAgentMoneyCountB(agentId);
//                agentMoneyC =  userMapper.selectAgentMoneyCountC(agentId);
//                //代理的玩家下的订单数量
//                agentOrderCount = userMapper.selectAgentOrderCount(agentId);
//            }else {
//                agentGoldMoneyA = userMapper.selectAgentGoldMoneyAdmin();
//                //代理有多少个玩家玩了,总共玩了多少把
//                map = userMapper.selectAgentGoldinfoAdmin();
//                //代理的房卡分成
//                agentMoneyA =  userMapper.selectAgentMoneyCountAdmin();
//                //代理的玩家下的订单数量
//                agentOrderCount = userMapper.selectAgentOrderCountAdmin();
//            }
//
//            //代理的损耗
//            Integer useMoney = userMapper.selectAgentUseMoney(agentId);
//            if ("1".equals(agentId)) {
//                //计算平台支出的渠道费
//                channelMoney = userMapper.selectCommissionMoney();
//                robotUse = userMapper.selectRobotUse();
//            }
//            int surplus = agentGoldMoneyA+agentGoldMoneyB+agentGoldMoneyC + agentMoneyA + agentMoneyB + agentMoneyC - useMoney -channelMoney + robotUse;
//           userMapper.insertIntoImstpagentcardreport(agentId,agentGoldMoneyA,agentGoldMoneyB,agentGoldMoneyC,map.getMapKey(),map.getMapValue(),agentMoneyA,agentMoneyB,agentMoneyC,agentOrderCount,useMoney,channelMoney,robotUse,surplus,0,0);
//        }
//        System.out.println("结束处理代理的房卡收益 typ=0");
//    }
//}
