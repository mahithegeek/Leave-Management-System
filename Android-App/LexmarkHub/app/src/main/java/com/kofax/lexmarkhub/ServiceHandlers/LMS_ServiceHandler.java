package com.kofax.lexmarkhub.ServiceHandlers;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.kofax.lexmarkhub.Activities.MainActivity;
import com.kofax.lexmarkhub.Objects.User;
import com.kofax.lexmarkhub.SharedPreferences;

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

import okhttp3.RequestBody;

import static com.kofax.lexmarkhub.Constants.ACCEPT;
import static com.kofax.lexmarkhub.Constants.CONTENT_TYPE;
import static com.kofax.lexmarkhub.Constants.DUMMY_ERROR;
import static com.kofax.lexmarkhub.Constants.ENCODING_TYPE;
import static com.kofax.lexmarkhub.Constants.ERROR_CODE_SUCCESS;
import static com.kofax.lexmarkhub.Constants.EXCEPTION_ERROR;
import static com.kofax.lexmarkhub.Constants.REQUEST_METHOD_POST;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;
import static com.kofax.lexmarkhub.Constants.TYPE_JSON;
import static com.kofax.lexmarkhub.Constants.applyLeave_Endpoint;
import static com.kofax.lexmarkhub.Constants.approveLeave_Endpoint;
import static com.kofax.lexmarkhub.Constants.availableLeaves_Endpoint;
import static com.kofax.lexmarkhub.Constants.baseUrl;
import static com.kofax.lexmarkhub.Constants.leaveHistory_Endpoint;
import static com.kofax.lexmarkhub.Constants.leaverequests_Endpoint;

/**
 * Created by venkateshkarra on 20/10/16.
 */

public class LMS_ServiceHandler {

    private Context mContext;
    private LMS_ServiceHandlerCallBack mLmsServiceHandlerCallBack;

    public LMS_ServiceHandler(Context context) {
        mContext = context;
    }
    public void setLmsServiceCallBack(LMS_ServiceHandlerCallBack callBack){
        mLmsServiceHandlerCallBack = callBack;
    }
    public void getAvailableLeaves(String requestBody) {
        LmsServiceTask lmsServiceTask = new LmsServiceTask();
        lmsServiceTask.execute(availableLeaves_Endpoint,requestBody);
    }
    public void applyLeave(String requestBody){
        LmsServiceTask lmsServiceTask = new LmsServiceTask();
        lmsServiceTask.execute(applyLeave_Endpoint,requestBody);
    }
    public void getLeaveHistory(String requestBody){
        LmsServiceTask lmsServiceTask = new LmsServiceTask();
        lmsServiceTask.execute(leaveHistory_Endpoint,requestBody);
    }
    public void getLeaveRequests(String requestBody){
        LmsServiceTask lmsServiceTask = new LmsServiceTask();
        lmsServiceTask.execute(leaverequests_Endpoint,requestBody);
    }
    public void approveLeave(String requestBody){
        LmsServiceTask lmsServiceTask = new LmsServiceTask();
        lmsServiceTask.execute(approveLeave_Endpoint,requestBody);
    }

    public class LmsServiceTask extends AsyncTask<String,Void,String[]>{
        @Override
        protected String[] doInBackground(String... params) {

            if (params.length < 2) {// Url end point and request body is must
                return null;
            }

            String urlEndPoint = params[0];
            String requestBody = params[1];

            // These two need to be declared outside the try/catch
            // so that they can be closed in the finally block.
            BufferedReader reader = null;
            // Will contain the raw JSON response as a string.
            HttpURLConnection urlConnection = null;

            try{
                URL url = new URL(baseUrl+urlEndPoint);
                Log.d("LMS_ServiceHandler","request url :"+baseUrl+urlEndPoint);
                Log.d("LMS_ServiceHandler","request Body :"+requestBody);

                // Create the request to OpenWeatherMap, and open the connection
                urlConnection = (HttpURLConnection) url.openConnection();
                urlConnection.setRequestMethod(REQUEST_METHOD_POST);
                urlConnection.setRequestProperty(ACCEPT,TYPE_JSON);
                urlConnection.setRequestProperty(CONTENT_TYPE,TYPE_JSON);
                urlConnection.connect();

                if (requestBody.length()>0) {
                    OutputStream os = urlConnection.getOutputStream();
                    OutputStreamWriter osw = new OutputStreamWriter(os, ENCODING_TYPE);
                    String prmtrs = requestBody;
                    osw.write(prmtrs);
                    osw.flush();
                    osw.close();
                }

                if (urlConnection.getResponseCode() != ERROR_CODE_SUCCESS){
                    mLmsServiceHandlerCallBack.didFailService(urlConnection.getResponseCode());
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
                String mProductsJsonStr = buffer.toString();
                mLmsServiceHandlerCallBack.didFinishServiceWithResponse(mProductsJsonStr);

            } catch (IOException e) {
                //hardcoding this error code because we could't get the error code here from exception object
                mLmsServiceHandlerCallBack.didFailService(EXCEPTION_ERROR);
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
                        mLmsServiceHandlerCallBack.didFailService(EXCEPTION_ERROR);
                    }
                }
            }
            return params;
        }
    }
}
