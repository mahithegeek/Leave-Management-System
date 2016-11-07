package com.kofax.lexmarkhub.Activities;

import android.app.ProgressDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandler;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandlerCallBack;
import com.kofax.lexmarkhub.SharedPreferences;
import com.kofax.lexmarkhub.Utility.Utility;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static com.kofax.lexmarkhub.Constants.DUMMY_ERROR;
import static com.kofax.lexmarkhub.Constants.FNAME;
import static com.kofax.lexmarkhub.Constants.FROM_DATE;
import static com.kofax.lexmarkhub.Constants.LEAVE_REQUESTS;
import static com.kofax.lexmarkhub.Constants.LEAVE_STATUS;
import static com.kofax.lexmarkhub.Constants.LNAME;
import static com.kofax.lexmarkhub.Constants.REQUESTID;
import static com.kofax.lexmarkhub.Constants.REQUEST_ID;
import static com.kofax.lexmarkhub.Constants.REQUEST_OBJECT_EXTRA;
import static com.kofax.lexmarkhub.Constants.STATUS;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;
import static com.kofax.lexmarkhub.Constants.TO_DATE;

public class EditRequestActivity extends AppCompatActivity {
    private TextView fromDateTxtView;
    private TextView toDateTxtView;
    private TextView reasonTxtView;
    private TextView nameTxtView;
    private JSONObject requestObject;
    private ProgressDialog mProgress;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_request);
        getSupportActionBar().setTitle(R.string.pending_request_title);

        fromDateTxtView = (TextView) findViewById(R.id.fromdate_textView);
        toDateTxtView = (TextView) findViewById(R.id.todate_textView);
        reasonTxtView = (TextView) findViewById(R.id.reason_txtView);
        nameTxtView = (TextView) findViewById(R.id.name_textView);

        try{
            requestObject = new JSONObject(getIntent().getStringExtra(REQUEST_OBJECT_EXTRA));
            String userName = requestObject.getString(FNAME)+" "+requestObject.getString(LNAME);
            nameTxtView.setText("From :"+userName);
            fromDateTxtView.setText(requestObject.getString(FROM_DATE).replace("-","/"));
            toDateTxtView.setText(requestObject.getString(TO_DATE).replace("-","/"));
            //TODO remove hardcoding

            String reason = getResources().getString(R.string.Reason)+ " "
                    + getResources().getString(R.string.leave_type_Vacation);
            reasonTxtView.setText(reason);

        }catch (JSONException e){
            e.printStackTrace();
        }
    }

    public void responseAction(View view){
        showSpinner();
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response) {
                removeSpinner();
                EditRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Log.d("EditRequest Page", "response :"+response);
                        try{
                            JSONObject jsonObject = new JSONObject(response);
                            JSONArray responseObject = jsonObject.getJSONArray(LEAVE_REQUESTS);
                            finish();// show toast if required
                        }
                        catch (JSONException e){
                            e.printStackTrace();
                            Toast.makeText(EditRequestActivity.this, Utility.getErrorMessageForCode(DUMMY_ERROR),
                                    Toast.LENGTH_SHORT).show();
                        }

                    }
                });
            }
            @Override
            public void didFailService(final int responseCode) {
                EditRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        removeSpinner();
                        Toast.makeText(EditRequestActivity.this, Utility.getErrorMessageForCode(responseCode),
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        lms_serviceHandler.approveLeave(getJsonBodyForPendingRequests(view).toString());
    }
    public void showSpinner(){
        mProgress = new ProgressDialog(this);
        mProgress.setMessage("Wait while loading...");
        mProgress.show();
    }
    private void removeSpinner(){
        mProgress.dismiss();
    }

    private JSONObject getJsonBodyForPendingRequests(View view) {
        JSONObject parameters = new JSONObject();
        try {
            parameters.put(TOKEN_ID, SharedPreferences.getAuthToken(this));
            parameters.put(REQUEST_ID, requestObject.get(REQUESTID));
            parameters.put(LEAVE_STATUS, view.getId() == R.id.approve_button);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return parameters;
    }
}
