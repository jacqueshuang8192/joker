package com.hbi.interfaces;

/**
 * Created by ceeuoo on 8/1/2016.
 */
public interface IAccount {
    public String invokeQuery(Long userId) throws Exception;

    public void updateCoin(Long userId, Integer amount) throws Exception;

    public Integer queryCoinAmount(Long userId) throws Exception;

    public boolean isCoinEnough(Long userId, Integer amount) throws Exception;
}
