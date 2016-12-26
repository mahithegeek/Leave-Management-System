package com.kofax.lexmarkhub.Activities;

import android.app.ProgressDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ListView;
import android.widget.Toast;

import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.Adapters.RequestListAdapter;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandler;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandlerCallBack;
import com.kofax.lexmarkhub.SharedPreferences;
import com.kofax.lexmarkhub.Utility.Utility;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;

import static com.kofax.lexmarkhub.Constants.PARSING_ERROR;
import static com.kofax.lexmarkhub.Constants.REC_ID;
import static com.kofax.lexmarkhub.Constants.STATUS;
import static com.kofax.lexmarkhub.Constants.STATUS_CANCELLED;
import static com.kofax.lexmarkhub.Constants.SUCCESS;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;

public class ViewStatusActivity extends AppCompatActivity implements RequestListAdapter.RequestListAdapterCallBack,LMS_ServiceHandlerCallBack{
    private  ProgressDialog mProgress;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_status);
        getSupportActionBar().setTitle(R.string.user_requests_title);
        getLeaveHistory();
    }
    public void loadLeavesList(JSONArray response){
        final ArrayList<JSONObject> requests = new ArrayList<JSONObject>();

        if (response != null) {
            for (int i=0;i<response.length();i++){
                try{
                    JSONObject object = response.getJSONObject(i);
                    if (!object.getString(STATUS).equalsIgnoreCase(STATUS_CANCELLED))
                        requests.addAll(Arrays.asList(object));
                }
                catch (JSONException e){
                    e.printStackTrace();
                }
            }
        }
        RequestListAdapter requestListAdapter = new RequestListAdapter(this,requests,false);
        requestListAdapter.requestListAdapterCallBack = this;
        ListView listview = (ListView)findViewById(R.id.requestList);
        listview.setAdapter(requestListAdapter);
    }
    public void  getLeaveHistory(){
        showSpinner();
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.lmsServiceHandlerCallBack = this;
        lms_serviceHandler.startRequest(LMS_ServiceHandler.RequestType.LeaveHistory,
                getJsonBodyForleaveHistory().toString());
    }
    private JSONObject getJsonBodyForleaveHistory() {
        JSONObject parameters = new JSONObject();
        try {
            parameters.put(TOKEN_ID, SharedPreferences.getAuthToken(this));

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return parameters;
    }
    public void showSpinner(){
        mProgress = new ProgressDialog(this);
        mProgress.setMessage("Wait while loading...");
        mProgress.show();
    }
    private void removeSpinner(){
        mProgress.dismiss();
    }
    private JSONObject getJsonBodyForCancelLeave(JSONObject leaveObject) {
        JSONObject parameters = new JSONObject();
        try {
            parameters.put(TOKEN_ID, SharedPreferences.getAuthToken(this));
            parameters.put("requestID", leaveObject.getString(REC_ID));

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return parameters;
    }

    //RequestListAdapterCallBack Methods
    @Override
    public void didSelectRequestItemWithAction(JSONObject requestItem, RequestListAdapter.RequestAction requestAction) {
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.lmsServiceHandlerCallBack = this;
        lms_serviceHandler.startRequest(LMS_ServiceHandler.RequestType.CancelLeave,
                getJsonBodyForCancelLeave(requestItem).toString());
    }

    //lmsServiceHandlerCallBack Methods
    @Override
    public void didFailService(int responseCode, final String errorResponse, LMS_ServiceHandler.RequestType requestType) {
        final int serResponseCode = responseCode;
        ViewStatusActivity.this.runOnUiThread(new Runnable() {
            public void run() {
                removeSpinner();
                Toast.makeText(ViewStatusActivity.this, Utility.getErrorMessageForCode(serResponseCode,errorResponse),
                        Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public void didFinishServiceWithResponse(String response, LMS_ServiceHandler.RequestType requestType) {
        final String serviceRes = response;
        final LMS_ServiceHandler.RequestType reqType = requestType;
        ViewStatusActivity.this.runOnUiThread(new Runnable() {
            public void run() {
                removeSpinner();
                Log.d("viewStatus Page", ""+serviceRes);
                try{
                    switch (reqType){
                        case LeaveHistory:
                            JSONObject leaveHistory = new JSONObject(serviceRes);
                            JSONArray responseObject = leaveHistory.getJSONArray("leaveHistory");
                            loadLeavesList(responseObject);
                            break;
                        case CancelLeave:
                            JSONObject jsonObject = new JSONObject(serviceRes);
                            String response = jsonObject.getString(SUCCESS);
                            Toast.makeText(ViewStatusActivity.this, response,
                                    Toast.LENGTH_SHORT).show();
                            getLeaveHistory();
                            break;
                    }
                }
                catch (JSONException e){
                    e.printStackTrace();
                    Toast.makeText(ViewStatusActivity.this, Utility.getErrorMessageForCode(PARSING_ERROR,null),
                            Toast.LENGTH_SHORT).show();
                }
            }
        });
    }
}
