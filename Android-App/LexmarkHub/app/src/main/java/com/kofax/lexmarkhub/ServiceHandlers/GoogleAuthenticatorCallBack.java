package com.kofax.lexmarkhub.ServiceHandlers;

import org.json.JSONObject;

/**
 * Created by venkateshkarra on 17/11/16.
 */

public interface GoogleAuthenticatorCallBack {
    void didFinishGoogleAuthentication(GoogleAuthenticator.GoogleAuthResponse response, String tokenId);
    void didFinishLoadingProfile(String ImageUrl, JSONObject userInfo);
}
