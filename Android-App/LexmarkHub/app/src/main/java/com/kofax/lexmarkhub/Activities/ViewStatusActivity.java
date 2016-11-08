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

import static com.kofax.lexmarkhub.Constants.DUMMY_ERROR;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;

public class ViewStatusActivity extends AppCompatActivity {
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
                    requests.addAll(Arrays.asList(object));
                }
                catch (JSONException e){
                    e.printStackTrace();
                }
            }
        }
        RequestListAdapter requestListAdapter = new RequestListAdapter(this,requests,false);
        ListView listview = (ListView)findViewById(R.id.requestList);
        listview.setAdapter(requestListAdapter);
    }
    public void  getLeaveHistory(){
        showSpinner();
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response) {
                removeSpinner();
                ViewStatusActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Log.d("viewStatus Page", ""+response);
                        try{
                            JSONArray responseObject = new JSONArray(response);
                            loadLeavesList(responseObject);
                        }
                        catch (JSONException e){
                            e.printStackTrace();
                            Toast.makeText(ViewStatusActivity.this, Utility.getErrorMessageForCode(DUMMY_ERROR),
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                });
            }
            @Override
            public void didFailService(final int responseCode) {
                ViewStatusActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        removeSpinner();
                        Toast.makeText(ViewStatusActivity.this, Utility.getErrorMessageForCode(responseCode),
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        lms_serviceHandler.getLeaveHistory(getJsonBodyForleaveHistory().toString());
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
}
