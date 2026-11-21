package com.hbi.ioc.account;

import com.core.util.ApplicationContextHelper;
import com.hbi.interfaces.IAccount;

/**
 * Created by ceeuoo on 8/1/2016.
 */
public class AccountOperationService {
    private IAccount account;

    public AccountOperationService() {
        account = (IAccount)ApplicationContextHelper.getBean("accountProvider");
    }

    public String invokeQuery(Long userId) throws Exception {
        return account.invokeQuery(userId);
    }

    public void updateCoin(Long userId, Integer amount) throws Exception {
        account.updateCoin(userId, amount);
    }

    public Integer queryCoinAmount(Long userId) throws Exception {
        return account.queryCoinAmount(userId);
    }

    public boolean isCoinEnough(Long userId, Integer amount) throws Exception {
        return account.isCoinEnough(userId, amount);
    }
}
