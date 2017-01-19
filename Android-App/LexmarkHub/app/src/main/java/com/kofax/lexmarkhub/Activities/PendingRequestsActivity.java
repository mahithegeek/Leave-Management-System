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

import okhttp3.internal.Util;

import static com.kofax.lexmarkhub.Constants.LEAVE_REQUESTS;
import static com.kofax.lexmarkhub.Constants.PARSING_ERROR;
import static com.kofax.lexmarkhub.Constants.REQUEST_OBJECT_EXTRA;
import static com.kofax.lexmarkhub.Constants.STATUS;
import static com.kofax.lexmarkhub.Constants.STATUS_APPLIED;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;
import static com.kofax.lexmarkhub.Utility.Utility.removeSpinner;

public class PendingRequestsActivity extends AppCompatActivity {
    private  ProgressDialog mProgress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pending_requests);
        getSupportActionBar().setTitle(R.string.pending_requests_title);
    }

    @Override
    protected void onResume() {
        super.onResume();
        getPendingRequests();
    }
    public void loadLeavesList(JSONArray response){
        final ArrayList<JSONObject> requests = new ArrayList<JSONObject>();

        if (response != null) {
            for (int i=0;i<response.length();i++){
                try{
                    JSONObject object = response.getJSONObject(i);
                    if (object.getString(STATUS).equalsIgnoreCase(STATUS_APPLIED))
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
        Utility.showSpinner(this);
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response, LMS_ServiceHandler.RequestType requestType) {
                Utility.removeSpinner();
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
                            Toast.makeText(PendingRequestsActivity.this, Utility.getErrorMessageForCode(PARSING_ERROR,null),
                                    Toast.LENGTH_SHORT).show();
                        }

                    }
                });
            }
            @Override
            public void didFailService(final int responseCode, final String errorResponse, LMS_ServiceHandler.RequestType requestType) {
                PendingRequestsActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Utility.removeSpinner();
                        Toast.makeText(PendingRequestsActivity.this, Utility.getErrorMessageForCode(responseCode,errorResponse),
                                Toast.LENGTH_SHORT).show();

                    }
                });
            }
        });

        lms_serviceHandler.startRequest(LMS_ServiceHandler.RequestType.LeaveRequests,
                getJsonBodyForPendingRequests().toString());
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


}
