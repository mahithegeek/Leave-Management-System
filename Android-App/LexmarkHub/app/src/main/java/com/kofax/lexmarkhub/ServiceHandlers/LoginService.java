package com.kofax.lexmarkhub.ServiceHandlers;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.StrictMode;
import android.util.Log;

import com.kofax.lexmarkhub.Objects.User;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;


import static com.kofax.lexmarkhub.Constants.ACCEPT;
import static com.kofax.lexmarkhub.Constants.CONTENT_TYPE;
import static com.kofax.lexmarkhub.Constants.EMAIL;
import static com.kofax.lexmarkhub.Constants.EMPID;
import static com.kofax.lexmarkhub.Constants.ENCODING_TYPE;
import static com.kofax.lexmarkhub.Constants.ERROR_CODE_SUCCESS;
import static com.kofax.lexmarkhub.Constants.EXCEPTION_ERROR;
import static com.kofax.lexmarkhub.Constants.FNAME;
import static com.kofax.lexmarkhub.Constants.LNAME;
import static com.kofax.lexmarkhub.Constants.PARSING_ERROR;
import static com.kofax.lexmarkhub.Constants.REQUEST_METHOD_POST;
import static com.kofax.lexmarkhub.Constants.ROLE;
import static com.kofax.lexmarkhub.Constants.SUPERVISOR;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;
import static com.kofax.lexmarkhub.Constants.TYPE_JSON;
import static com.kofax.lexmarkhub.Constants.baseUrl;
import static com.kofax.lexmarkhub.Constants.login_Endpoint;

public class LoginService  extends AsyncTask<String, Void, String[]> {
    static Context mContext;
    private String mProductsJsonStr = null;
    private LoginServiceCallBack mLoginServiceCallBack;

    public LoginService(Context context){
        mContext = context;
    }

    public void setLoginServiceCallBack(LoginServiceCallBack callBack){
        mLoginServiceCallBack = callBack;
    }
    @Override
    protected String[] doInBackground(String... params) {

        if (params.length == 0) {
            return null;
        }
        String tokenId = params[0];

        // These two need to be declared outside the try/catch
        // so that they can be closed in the finally block.
        BufferedReader reader = null;
        // Will contain the raw JSON response as a string.
        HttpURLConnection urlConnection = null;

        try{

            URL url = new URL(baseUrl+login_Endpoint);
            // Create the request to OpenWeatherMap, and open the connection
            urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestMethod(REQUEST_METHOD_POST);
            urlConnection.setRequestProperty(ACCEPT,TYPE_JSON);
            urlConnection.setRequestProperty(CONTENT_TYPE,TYPE_JSON);
            urlConnection.connect();

            OutputStream os = urlConnection.getOutputStream();
            OutputStreamWriter osw = new OutputStreamWriter(os, ENCODING_TYPE);
            osw.write(getJsonBodyForProduct(tokenId).toString());
            osw.flush();
            osw.close();


            InputStream errorStream = urlConnection.getErrorStream();

            if (urlConnection.getResponseCode() != ERROR_CODE_SUCCESS){
                mLoginServiceCallBack.didFailLogin(urlConnection.getResponseCode());
                return null;
            }


            // Read the input stream into a String
            InputStream inputStream = urlConnection.getInputStream();

            StringBuffer buffer = new StringBuffer();

            if (inputStream == null) {
                // Nothing to do.
                return null;
            }
            reader = new BufferedReader(new InputStreamReader(inputStream));

            String line;
            while ((line = reader.readLine()) != null) {
                // Since it's JSON, adding a newline isn't necessary (it won't affect parsing)
                // But it does make debugging a *lot* easier if you print out the completed
                // buffer for debugging.
                buffer.append(line);
            }

            if (buffer.length() == 0) {
                // Stream was empty.  No point in parsing.
                return null;
            }
            mProductsJsonStr = buffer.toString();
            parseResponse(mProductsJsonStr);
        } catch (IOException e) {
            //hardcoding this error code because we could't get the error code here from exception object
            mLoginServiceCallBack.didFailLogin(EXCEPTION_ERROR);
            return null;
        } finally {
            if (urlConnection != null) {
                urlConnection.disconnect();
            }
            if (reader != null) {
                try {
                    reader.close();
                } catch (final IOException e) {
                    //check
                    //hardcoding this error code because we could't get the error code here from exception object
                    mLoginServiceCallBack.didFailLogin(EXCEPTION_ERROR);
                }
            }
        }

        return params;
    }

    private JSONObject getJsonBodyForProduct(String tokenId) {
        JSONObject parameters = new JSONObject();
        try {
            parameters.put(TOKEN_ID, tokenId);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return parameters;
    }

    public void parseResponse(String response){
        Log.d("EditRequest Page", ""+response);

        try {
            JSONObject userJson = new JSONObject(response);

            String fname = userJson.getString(FNAME);
            String lname = userJson.getString(LNAME);
            User user = new User(fname, lname);
            user.setEmail(userJson.getString(EMAIL));
            user.setEmpId(userJson.getString(EMPID));
            user.setRole(userJson.getString(ROLE));

            if (!userJson.optString(SUPERVISOR).isEmpty()){
                JSONObject supervisorDetails = new JSONObject(userJson.getString(SUPERVISOR));

                user.setSupervisorDetails(supervisorDetails.getString(FNAME),
                        supervisorDetails.getString(LNAME),
                        supervisorDetails.getString(EMAIL));
            }
            mLoginServiceCallBack.didFinishLogin(user);
        }
        catch (JSONException e){
            //send Random Error code as the parsing failed
            // need toc change
            mLoginServiceCallBack.didFailLogin(PARSING_ERROR);
            e.printStackTrace();
        }
    }

}
