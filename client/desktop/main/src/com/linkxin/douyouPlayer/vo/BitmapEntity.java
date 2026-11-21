package com.linkxin.douyouPlayer.vo;

/**
 * Created by lxy on 2016/5/3.
 */
public class BitmapEntity {
    public float x;
    public float y;
    public float width;
    public float height;
    public static int devide = 1;
    public int index = -1;

    @Override
    public String toString() {
        return "MyBitmap [x=" + x + ", y=" + y + ", width=" + width
                + ", height=" + height + ", devide=" + devide + ", index="
                + index + "]";
    }
}
