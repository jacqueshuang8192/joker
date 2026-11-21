//package com.hbi.model;
//
//import javax.persistence.*;
//
//@Table(name = "t_level_point")
//public class TLevelPoint {
//    @Id
//    private Integer level;
//
//    private Integer points;
//
//    @Column(name = "min_minutes")
//    private Integer minMinutes;
//
//    @Column(name = "allow_low")
//    private Short allowLow;
//
//    /**
//     * @return level
//     */
//    public Integer getLevel() {
//        return level;
//    }
//
//    /**
//     * @param level
//     */
//    public void setLevel(Integer level) {
//        this.level = level;
//    }
//
//    /**
//     * @return points
//     */
//    public Integer getPoints() {
//        return points;
//    }
//
//    /**
//     * @param points
//     */
//    public void setPoints(Integer points) {
//        this.points = points;
//    }
//
//    /**
//     * @return min_minutes
//     */
//    public Integer getMinMinutes() {
//        return minMinutes;
//    }
//
//    /**
//     * @param minMinutes
//     */
//    public void setMinMinutes(Integer minMinutes) {
//        this.minMinutes = minMinutes;
//    }
//
//    /**
//     * @return allow_low
//     */
//    public Short getAllowLow() {
//        return allowLow;
//    }
//
//    /**
//     * @param allowLow
//     */
//    public void setAllowLow(Short allowLow) {
//        this.allowLow = allowLow;
//    }
//}