package com.linkxin.douyouPlayer.vo;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.List;

/**
 * Created by Administrator on 2016-05-13.
 */
public class SocietyCompereResponse implements Parcelable {


    /**
     * count : 1
     * list : [{"attack":100,"birthday":"1970-01-01 00:00:00","city":"","cityId":"","data":"","defense":10,"fansCount":0,"fmCurrentRank":99,"fmCurrentScore":0,"fmTotalMatch":0,"fmTotalScore":0,"latitude":"","level":11,"life":500,"longitude":"","nickName":"张婧","onlineStatus":"1","phone":"","photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/310userHeader20160411143349.jpg","playingGame":"","position":"","resultMessage":"","returnCode":"","sex":"2","sign":"","societyId":19,"status":"1","type":"C","userId":"310"}]
     * returnCode :
     */

    private int count;
    private String returnCode;
    private List<SocietyCompere> list;

    public List<SocietyCompere> getList() {
        return list;
    }

    public void setList(List<SocietyCompere> list) {
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

    public SocietyCompereResponse() {
    }

    protected SocietyCompereResponse(Parcel in) {
        this.count = in.readInt();
        this.returnCode = in.readString();
        this.list = in.createTypedArrayList(SocietyCompere.CREATOR);
    }

    public static final Parcelable.Creator<SocietyCompereResponse> CREATOR = new Parcelable.Creator<SocietyCompereResponse>() {
        @Override
        public SocietyCompereResponse createFromParcel(Parcel source) {
            return new SocietyCompereResponse(source);
        }

        @Override
        public SocietyCompereResponse[] newArray(int size) {
            return new SocietyCompereResponse[size];
        }
    };
}
