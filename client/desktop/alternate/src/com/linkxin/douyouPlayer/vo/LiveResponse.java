package com.linkxin.douyouPlayer.vo;

/**
 * Created by zhongweihao on 16/8/9.
 */
public class LiveResponse {
    private String returnCode;
    private String command;
    private String errorMessage;
    private String liveAddress;
    private String decodeType;

    public String getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(String returnCode) {
        this.returnCode = returnCode;
    }

    public String getCommand() {
        return command;
    }

    public void setCommand(String command) {
        this.command = command;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getLiveAddress() {
        return liveAddress;
    }

    public void setLiveAddress(String liveAddress) {
        this.liveAddress = liveAddress;
    }

    public String getDecodeType() {
        return decodeType;
    }

    public void setDecodeType(String decodeType) {
        this.decodeType = decodeType;
    }
}
