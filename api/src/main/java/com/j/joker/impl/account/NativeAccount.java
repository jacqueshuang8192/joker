package com.j.joker.impl.account;

import com.j.joker.interfaces.IAccount;
import com.j.joker.utils.GameServerUtil;

/**
 * Created by ceeuoo on 8/1/2016.
 */
public class NativeAccount implements IAccount {
    @Override
    public String invokeQuery(Long userId) throws Exception {
        return GameServerUtil.invokeQuery(userId);
    }

    @Override
    public void updateCoin(Long userId, Integer amount) throws Exception {
        GameServerUtil.invokeUpdateCoin(userId, amount);
    }

    @Override
    public Integer queryCoinAmount(Long userId) throws Exception {
        return GameServerUtil.queryCoinAmount(userId);
    }

    @Override
    public boolean isCoinEnough(Long userId, Integer amount) throws Exception {
        Integer coinAmount = queryCoinAmount(userId);
        if (coinAmount < amount) {
            return false;
        }
        return true;
    }
}
