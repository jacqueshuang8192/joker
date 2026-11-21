//package com.hbi.model;
//
//public class GameInfo implements Comparable<GameInfo>{
//
//	private Long mid;
//
//	private Long exp;
//
//	private Long money;
//
//	private Long safebox;
//
//	private Long totalmoney;
//
//	private Integer level;
//
//	private Integer wintimes;
//
//	private Integer losetimes;
//
//	private Integer diamond;
//
//    public Long getMid() {
//        return mid;
//    }
//
//    public void setMid(Long mid) {
//        this.mid = mid;
//    }
//
//    public Long getExp() {
//        return exp;
//    }
//
//    public void setExp(Long exp) {
//        this.exp = exp;
//    }
//
//    public Long getMoney() {
//        return money;
//    }
//
//    public void setMoney(Long money) {
//        this.money = money;
//    }
//
//    public Long getSafebox() {
//        return safebox;
//    }
//
//    public void setSafebox(Long safebox) {
//        this.safebox = safebox;
//    }
//
//    public Long getTotalmoney() {
//        return totalmoney;
//    }
//
//    public void setTotalmoney(Long totalmoney) {
//        this.totalmoney = totalmoney;
//    }
//
//    public Integer getLevel() {
//        return level;
//    }
//
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//    public Integer getWintimes() {
//        return wintimes;
//    }
//
//    public void setWintimes(Integer wintimes) {
//        this.wintimes = wintimes;
//    }
//
//    public Integer getLosetimes() {
//        return losetimes;
//    }
//
//    public void setLosetimes(Integer losetimes) {
//        this.losetimes = losetimes;
//    }
//
//    public Integer getDiamond() {
//        return diamond;
//    }
//
//    public void setDiamond(Integer diamond) {
//        this.diamond = diamond;
//    }
//
//    @Override
//    public int compareTo(GameInfo o) {
//        if (money == null) {
//            return -1;
//        } else if (o.money == null) {
//            return 1;
//        } else if (money > o.money) {
//            return 1;
//        } else if (money < o.money) {
//            return -1;
//        }
//        return 0;
//    }
//
//}
