package com.kofax.lexmarkhub.Activities;

import android.app.ProgressDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;

import com.kofax.lexmarkhub.Adapters.RequestListAdapter;
import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandler;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandlerCallBack;
import com.kofax.lexmarkhub.SharedPreferences;
import com.kofax.lexmarkhub.Utility.Utility;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import javax.xml.transform.stream.StreamSource;

import static com.kofax.lexmarkhub.Constants.FNAME;
import static com.kofax.lexmarkhub.Constants.FROM_DATE;
import static com.kofax.lexmarkhub.Constants.IS_HALFDAY;
import static com.kofax.lexmarkhub.Constants.LEAVE_STATUS;
import static com.kofax.lexmarkhub.Constants.LNAME;
import static com.kofax.lexmarkhub.Constants.PARSING_ERROR;
import static com.kofax.lexmarkhub.Constants.REASON;
import static com.kofax.lexmarkhub.Constants.REQUESTID;
import static com.kofax.lexmarkhub.Constants.REQUEST_ID;
import static com.kofax.lexmarkhub.Constants.REQUEST_OBJECT_EXTRA;
import static com.kofax.lexmarkhub.Constants.STATUS_APPROVE;
import static com.kofax.lexmarkhub.Constants.STATUS_REJECT;
import static com.kofax.lexmarkhub.Constants.SUCCESS;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;
import static com.kofax.lexmarkhub.Constants.TO_DATE;

public class EditRequestActivity extends AppCompatActivity {
    private TextView fromDateTxtView;
    private TextView toDateTxtView;
    private TextView reasonTxtView;
    private TextView nameTxtView;
    private TextView notesTxtView;
    private JSONObject requestObject;
    private ProgressDialog mProgress;
    private CheckBox mHalfdayCheckBox;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_request);
        getSupportActionBar().setTitle(R.string.pending_request_title);

        fromDateTxtView = (TextView) findViewById(R.id.fromdate_textView);
        toDateTxtView = (TextView) findViewById(R.id.todate_textView);
        reasonTxtView = (TextView) findViewById(R.id.reason_txtView);
        nameTxtView = (TextView) findViewById(R.id.name_textView);
        notesTxtView = (TextView) findViewById(R.id.notes_textView);
        mHalfdayCheckBox = (CheckBox)findViewById(R.id.HDL_checkbox);
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
            notesTxtView.setText(requestObject.getString(REASON));
            mHalfdayCheckBox.setChecked(requestObject.getInt(IS_HALFDAY)==1) ;


        }catch (JSONException e){
            e.printStackTrace();
        }
    }

    public void responseAction(View view){
        Utility.showSpinner(this);
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response,
                                                     LMS_ServiceHandler.RequestType requestType) {
                Utility.removeSpinner();
                EditRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Log.d("EditRequest Page", "response :"+response);
                        showResult(response);
                    }
                });
            }
            @Override
            public void didFailService(final int responseCode, final String errorResponse,
                                       LMS_ServiceHandler.RequestType requestType) {
                EditRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Utility.removeSpinner();
                        Toast.makeText(EditRequestActivity.this,
                                Utility.getErrorMessageForCode(responseCode,errorResponse),
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });
        lms_serviceHandler.startRequest(LMS_ServiceHandler.RequestType.ApproveLeave,
                getJsonBodyForPendingRequests(view).toString());
    }

    private void showResult(String response){
        try{
            JSONObject productsJson = new JSONObject(response);
            String result = productsJson.getString(SUCCESS);
            Toast.makeText(EditRequestActivity.this, result, Toast.LENGTH_SHORT).show();
            finish();
        }
        catch (JSONException e){
            e.printStackTrace();
            Toast.makeText(EditRequestActivity.this, Utility.getErrorMessageForCode(PARSING_ERROR,null),
                        Toast.LENGTH_SHORT).show();
        }
    }

    private JSONObject getJsonBodyForPendingRequests(View view) {
        JSONObject parameters = new JSONObject();
        try {
            parameters.put(TOKEN_ID, SharedPreferences.getAuthToken(this));
            parameters.put(REQUEST_ID, requestObject.get(REQUESTID));
            parameters.put(LEAVE_STATUS, view.getId() == R.id.approve_button);
            if(view.getId() == R.id.approve_button){
                parameters.put(LEAVE_STATUS, STATUS_APPROVE);
            }
            else {
                parameters.put(LEAVE_STATUS, STATUS_REJECT);
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return parameters;
    }
}
