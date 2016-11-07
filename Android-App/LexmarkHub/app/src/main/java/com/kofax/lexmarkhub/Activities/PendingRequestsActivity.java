package com.kofax.lexmarkhub.Activities;

import android.app.ProgressDialog;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
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
import static com.kofax.lexmarkhub.Constants.LEAVE_REQUESTS;
import static com.kofax.lexmarkhub.Constants.REQUEST_OBJECT_EXTRA;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;

public class PendingRequestsActivity extends AppCompatActivity {
    private  ProgressDialog mProgress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pending_requests);
        getSupportActionBar().setTitle(R.string.pending_requests_title);
        getPendingRequests();
    }

    public void loadLeavesList(JSONArray response){
        final ArrayList<JSONObject> requests = new ArrayList<JSONObject>();

        if (response != null) {
            for (int i=0;i<response.length();i++){
                try{
                    JSONObject object = response.getJSONObject(0);
                    requests.addAll(Arrays.asList(object));
                }
                catch (JSONException e){
                    e.printStackTrace();
                }
            }
        }
        RequestListAdapter requestListAdapter = new RequestListAdapter(this,requests,true);
        ListView listview = (ListView)findViewById(R.id.requestList);
        listview.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(PendingRequestsActivity.this,EditRequestActivity.class);
                intent.putExtra(REQUEST_OBJECT_EXTRA,requests.get(position).toString());
                startActivity(intent);
            }
        });
        listview.setAdapter(requestListAdapter);
    }

    public void  getPendingRequests(){
        showSpinner();
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response) {
                removeSpinner();
                PendingRequestsActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Log.d("pendingRequests Page", ""+response);
                        try{
                            JSONObject jsonObject = new JSONObject(response);
                            JSONArray responseObject = jsonObject.getJSONArray(LEAVE_REQUESTS);
                            loadLeavesList(responseObject);
                        }
                        catch (JSONException e){
                            e.printStackTrace();
                            Toast.makeText(PendingRequestsActivity.this, Utility.getErrorMessageForCode(DUMMY_ERROR),
                                    Toast.LENGTH_SHORT).show();
                        }

                    }
                });
            }
            @Override
            public void didFailService(final int responseCode) {
                PendingRequestsActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        removeSpinner();
                        Toast.makeText(PendingRequestsActivity.this, Utility.getErrorMessageForCode(responseCode),
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        lms_serviceHandler.getLeaveRequests(getJsonBodyForPendingRequests().toString());
    }

    private JSONObject getJsonBodyForPendingRequests() {
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