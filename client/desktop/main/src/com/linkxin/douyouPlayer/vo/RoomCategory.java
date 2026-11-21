package com.linkxin.douyouPlayer.vo;

/**
 * Created by lxy on 2016/4/9.
 */
public class RoomCategory {

    /**
     * liveActivityId : 7
     * liveActivityName : 百人牛牛
     * photo : douniu
     * type : 1 表示游戏，2表示电台
     */

	public static final String TYPE_GAME = "1";
	public static final String TYPE_FM = "2";
	
    private String liveActivityId;
    private String liveActivityName;
    private String photo;
    private String type;

    public String getLiveActivityId() {
        return liveActivityId;
    }

    public void setLiveActivityId(String liveActivityId) {
        this.liveActivityId = liveActivityId;
    }

    public String getLiveActivityName() {
        return liveActivityName;
    }

    public void setLiveActivityName(String liveActivityName) {
        this.liveActivityName = liveActivityName;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
