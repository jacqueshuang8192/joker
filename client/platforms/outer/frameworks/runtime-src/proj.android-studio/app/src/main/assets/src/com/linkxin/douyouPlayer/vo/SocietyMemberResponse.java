package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.List;

/**
 * Created by Administrator on 2016-05-13.
 */
public class SocietyMemberResponse implements Parcelable {


    /**
     * count : 2
     * list : [{"attack":51,"birthday":"1970-01-01 00:00:00","city":"","cityId":"","contribution":0,"data":"","defense":6,"fmCurrentRank":99,"fmCurrentScore":0,"fmTotalMatch":0,"fmTotalScore":0,"latitude":"","level":"","life":271,"longitude":"","nickName":"张婧","onlineStatus":"1","phone":"","photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/(null)userHeader20160411140036.jpg","playingGame":"","position":"","resultMessage":"","returnCode":"","sex":"2","sign":"","societyId":"","status":"","type":"","userId":"363","vipLevel":"9","wealth":0},{"attack":100,"birthday":"","city":"","cityId":"","contribution":0,"data":"","defense":10,"fmCurrentRank":99,"fmCurrentScore":0,"fmTotalMatch":0,"fmTotalScore":0,"latitude":"","level":"","life":500,"longitude":"","nickName":"猫","onlineStatus":"1","phone":"","photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/386userHeader20160411161257.jpg","playingGame":"","position":"","resultMessage":"","returnCode":"","sex":"2","sign":"","societyId":"","status":"","type":"","userId":"388","vipLevel":"5","wealth":0}]
     * returnCode :
     */

    private int count;
    private String returnCode;
    private List<SocietyMember> list;

    public List<SocietyMember> getList() {
        return list;
    }

    public void setList(List<SocietyMember> list) {
        this.list = list;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public String getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(String returnCode) {
        this.returnCode = returnCode;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.count);
        dest.writeString(this.returnCode);
        dest.writeTypedList(this.list);
    }

    public SocietyMemberResponse() {
    }

    protected SocietyMemberResponse(Parcel in) {
        this.count = in.readInt();
        this.returnCode = in.readString();
        this.list = in.createTypedArrayList(SocietyMember.CREATOR);
    }

    public static final Parcelable.Creator<SocietyMemberResponse> CREATOR = new Parcelable.Creator<SocietyMemberResponse>() {
        @Override
        public SocietyMemberResponse createFromParcel(Parcel source) {
            return new SocietyMemberResponse(source);
        }

        @Override
        public SocietyMemberResponse[] newArray(int size) {
            return new SocietyMemberResponse[size];
        }
    };
}
