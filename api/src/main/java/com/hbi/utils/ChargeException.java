package com.hbi.utils;

/**
 * Created by ceeuoo on 6/21/2016.
 */
public class ChargeException extends Exception {
    private String errorCode;
    private String errorMsg;

    public ChargeException() {
    }

    public ChargeException(String errorCode, String errorMsg) {
        super();
        this.errorCode = errorCode;
        this.errorMsg = errorMsg;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorMsg() {
        return errorMsg;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }
}
