package com.kofax.lexmarkhub.ServiceHandlers;

import com.google.gson.JsonObject;
import com.kofax.lexmarkhub.Objects.User;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Created by venkateshkarra on 21/10/16.
 */

public interface LMS_ServiceHandlerCallBack {
    void didFinishServiceWithResponse(String response);
    void didFailService(int responseCode);
}
