package com.kofax.lexmarkhub;

import android.content.Context;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.kofax.lexmarkhub.Objects.User;
import java.lang.reflect.Type;
import static android.content.Context.MODE_PRIVATE;

/**
 * Created by venkateshkarra on 20/10/16.
 */

public class SharedPreferences {

    private static String PREFFRENCE_NAME = "LexmarkHubSharedPreference";

    private static final String AUTH_TOKEN = "AUTH_TOKEN";
    private static final String LOGGEDIN_USER = "LOGGEDIN_USER";

    public static void saveAuthToken(String token, Context context){

        context.getSharedPreferences(PREFFRENCE_NAME, MODE_PRIVATE).edit()
                .putString(AUTH_TOKEN, token)
                .apply();
    }

    public  static void removeAuthenticaionToken(Context context){
        context.getSharedPreferences(PREFFRENCE_NAME, MODE_PRIVATE).edit()
                .remove(AUTH_TOKEN)
                .apply();
    }

    public static String getAuthToken(Context context){
        android.content.SharedPreferences mPrefs = context.getSharedPreferences(PREFFRENCE_NAME, context.MODE_PRIVATE);
        return mPrefs.getString(AUTH_TOKEN, "");
    }

    public static void saveLoggedInUser(User user,Context context){
        Gson gson = new Gson();
        String userString = gson.toJson(user);
        context.getSharedPreferences(PREFFRENCE_NAME, MODE_PRIVATE).edit()
                .putString(LOGGEDIN_USER, userString)
                .apply();
    }

    public  static void removeLoggedInUser(Context context){
        context.getSharedPreferences(PREFFRENCE_NAME, MODE_PRIVATE).edit()
                .remove(LOGGEDIN_USER)
                .apply();
    }

    public static User getLoggedInUser(Context context){
        android.content.SharedPreferences mPrefs = context.getSharedPreferences(PREFFRENCE_NAME, context.MODE_PRIVATE);
        String userString = mPrefs.getString(LOGGEDIN_USER, "");
        Gson gson = new Gson();
        if (userString.isEmpty()) {
            return null;
        } else {
            Type type = new TypeToken<User>() {
            }.getType();
            return gson.fromJson(userString, type);
        }
    }
}
