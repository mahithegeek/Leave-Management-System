package com.kofax.lexmarkhub.ServiceHandlers;

import com.kofax.lexmarkhub.Objects.User;

public interface LoginServiceCallBack{
    void didFinishLogin(User user);
    void didFailLogin(int responseCode);
}
