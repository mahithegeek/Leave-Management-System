package com.kofax.lexmarkhub.Activities;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.CheckBox;
import android.widget.DatePicker;
import android.widget.ImageView;

import com.kofax.lexmarkhub.Objects.User;
import com.kofax.lexmarkhub.Utility.DatePickerDialogFragment;
import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandler;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandlerCallBack;
import com.kofax.lexmarkhub.SharedPreferences;
import com.kofax.lexmarkhub.Utility.Utility;

import android.app.DatePickerDialog.OnDateSetListener;

import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Calendar;


import static com.kofax.lexmarkhub.Constants.DESCRIPTION;
import static com.kofax.lexmarkhub.Constants.FROM_DATE;
import static com.kofax.lexmarkhub.Constants.IS_HALF_DAY;
import static com.kofax.lexmarkhub.Constants.LEAVE;
import static com.kofax.lexmarkhub.Constants.LEAVE_TYPE;
import static com.kofax.lexmarkhub.Constants.PARSING_ERROR;
import static com.kofax.lexmarkhub.Constants.REASON;
import static com.kofax.lexmarkhub.Constants.SUCCESS;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;
import static com.kofax.lexmarkhub.Constants.TO_DATE;

public class NewLeaveRequestActivity extends AppCompatActivity implements OnDateSetListener{
    private static final int START_DATE_PICKER_TAG = 1298;//random tag numbers
    private static final int END_DATE_PICKER_TAG = 1299;

    private ProgressDialog mProgress;
    private TextView fromDateTxtView;
    private TextView toDateTxtView;
    private TextView reasonTxtView;
    private TextView toTextView;
    private TextView notesView;
    private CheckBox halfDayLeaveCheckBox;
    private Calendar mEndCalendar;
    private Calendar mStartCalendar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_new_leave_request);

        getSupportActionBar().setTitle(R.string.new_request_title);
        ImageView startDateButton = (ImageView) findViewById(R.id.startDateView);
        final ImageView endDateButton = (ImageView) findViewById(R.id.endDateView);
        fromDateTxtView = (TextView) findViewById(R.id.fromdate_textView);
        toDateTxtView = (TextView) findViewById(R.id.todate_textView);
        reasonTxtView = (TextView) findViewById(R.id.reason_txtView);
        toTextView = (TextView) findViewById(R.id.toTextView);
        notesView = (TextView) findViewById(R.id.notes_view);
        halfDayLeaveCheckBox = (CheckBox) findViewById(R.id.HDL_checkbox);

        mStartCalendar = mEndCalendar = Calendar.getInstance();
        setCurrentDate();

        halfDayLeaveCheckBox.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(halfDayLeaveCheckBox.isChecked()){
                    endDateButton.setClickable(false);
                    if (mStartCalendar != mEndCalendar){
                        mEndCalendar = mStartCalendar;
                        Format formatter = new SimpleDateFormat("dd-MM-yyyy");
                        String s = formatter.format(mEndCalendar.getTime());
                        toDateTxtView.setText(s);
                    }
                }
                else {
                    endDateButton.setClickable(true);
                }
            }
        });

        startDateButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Bundle b = new Bundle();
                b.putInt(DatePickerDialogFragment.YEAR,mStartCalendar.get(Calendar.YEAR));
                b.putInt(DatePickerDialogFragment.MONTH, mStartCalendar.get(Calendar.MONTH));
                b.putInt(DatePickerDialogFragment.DATE, mStartCalendar.get(Calendar.DAY_OF_MONTH));
                b.putInt(DatePickerDialogFragment.TAG, START_DATE_PICKER_TAG);
                android.app.DialogFragment picker = new DatePickerDialogFragment();
                picker.setArguments(b);
                picker.show(getFragmentManager(), "fragment_date_picker");
            }
        });

        endDateButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Bundle b = new Bundle();
                b.putInt(DatePickerDialogFragment.YEAR, mEndCalendar.get(Calendar.YEAR));
                b.putInt(DatePickerDialogFragment.MONTH, mEndCalendar.get(Calendar.MONTH));
                b.putInt(DatePickerDialogFragment.DATE, mEndCalendar.get(Calendar.DAY_OF_MONTH));
                b.putInt(DatePickerDialogFragment.TAG, END_DATE_PICKER_TAG);
                android.app.DialogFragment picker = new DatePickerDialogFragment();
                picker.setArguments(b);
                picker.show(getFragmentManager(), "fragment_date_picker");
            }
        });


        User user = Utility.getLoggedInUser(this);
        toTextView.setText(getResources().getString(R.string.to)
                +" "+user.getSuperVisorFName()
                +" "+user.getSuperVisorLName());
    }
    public void submitRequestAction(View view){
        if (validateDate() == false){
            return;
        }
        showSpinner();
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response, LMS_ServiceHandler.RequestType requestType) {
                removeSpinner();
                NewLeaveRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Log.d("new request page", ""+response);
                        showResult(response);
                    }
                });

            }

            @Override
            public void didFailService(final int responseCode, final String errorResponse, LMS_ServiceHandler.RequestType requestType) {
                NewLeaveRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        removeSpinner();
                        Toast.makeText(NewLeaveRequestActivity.this, Utility.getErrorMessageForCode(responseCode,errorResponse),
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        lms_serviceHandler.startRequest(LMS_ServiceHandler.RequestType.ApplyLeave,
                getJsonBodyForApplyLeave().toString().replace("\\",""));

    }
    private void showResult(String response){
        try{
            JSONObject productsJson = new JSONObject(response);
            String result = productsJson.getString(SUCCESS);
            Toast.makeText(NewLeaveRequestActivity.this, result, Toast.LENGTH_SHORT).show();
            finish();
        }
        catch (JSONException e){
            try{
                JSONObject productsJson = new JSONObject(response);
                String result = productsJson.getString(DESCRIPTION);
                Toast.makeText(NewLeaveRequestActivity.this, result, Toast.LENGTH_SHORT).show();
            }
            catch (JSONException ex){
                ex.printStackTrace();
                Toast.makeText(NewLeaveRequestActivity.this, Utility.getErrorMessageForCode(PARSING_ERROR,null),
                        Toast.LENGTH_SHORT).show();
            }

        }
    }
    private JSONObject getJsonBodyForApplyLeave() {
        JSONObject parameters = new JSONObject();

        try {
            parameters.put(TOKEN_ID, SharedPreferences.getAuthToken(this));
            JSONObject leaveObject = new JSONObject();
            try {
                String startDt = mStartCalendar.get(Calendar.YEAR)
                        +"-"+(mStartCalendar.get(Calendar.MONTH)+1)
                        +"-"+mStartCalendar.get(Calendar.DAY_OF_MONTH);
                leaveObject.put(FROM_DATE, startDt);
                String endDate = mEndCalendar.get(Calendar.YEAR)
                        +"-"+(mEndCalendar.get(Calendar.MONTH)+1)
                        +"-"+mEndCalendar.get(Calendar.DAY_OF_MONTH);
                leaveObject.put(TO_DATE, endDate);
                leaveObject.put(IS_HALF_DAY, halfDayLeaveCheckBox.isChecked());
                String reason = reasonTxtView.getText().toString();
                leaveObject.put(LEAVE_TYPE,reason.replace(getResources().getString(R.string.Reason),"").toLowerCase());
                leaveObject.put(REASON,notesView.getText());
            }
            catch (JSONException e){
                e.printStackTrace();
            }

            parameters.put(LEAVE,leaveObject);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return parameters;
    }
    public void leaveTypeAction(View view){
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.please_select_leave_type);
        builder.setItems(R.array.leave_type_array_options, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int item) {

                String reason = getResources().getString(R.string.Reason)
                        + (getResources().getStringArray(R.array.leave_type_array_options))[item];
                reasonTxtView.setText(reason);
            }
        });
        AlertDialog alert = builder.create();
        alert.show();
    }
    public boolean validateDate(){
        if (mStartCalendar.getTimeInMillis()>mEndCalendar.getTimeInMillis()){
            Toast.makeText(this,"End date should be later than start date",Toast.LENGTH_LONG).show();
            return false;
        }
        else if(reasonTxtView.getText().equals(getResources().getString(R.string.Reason))){
            Toast.makeText(this,"Please select reason for leave",Toast.LENGTH_LONG).show();
            return false;
        }

        return true;
    }
    public void setCurrentDate(){
        Calendar calendar = Calendar.getInstance();
        mStartCalendar = mEndCalendar = calendar;
        Format formatter = new SimpleDateFormat("dd-MM-yyyy");
        String s = formatter.format(calendar.getTime());
        fromDateTxtView.setText(s);
        toDateTxtView.setText(s);
    }
    public void showSpinner(){
        mProgress = new ProgressDialog(this);
        mProgress.setMessage("Wait while loading...");
        mProgress.show();
    }
    private void removeSpinner(){
        mProgress.dismiss();
    }
    @Override
    public void onDateSet(DatePicker view, int year, int monthOfYear,int dayOfMonth) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, year);
        calendar.set(Calendar.MONTH, monthOfYear);
        calendar.set(Calendar.DAY_OF_MONTH, dayOfMonth);
        Format formatter = new SimpleDateFormat("dd-MM-yyyy");
        String s = formatter.format(calendar.getTime());
        if (view.getTag().equals(START_DATE_PICKER_TAG)){
            mStartCalendar = calendar;
            fromDateTxtView.setText(s);

            if(halfDayLeaveCheckBox.isChecked()){
                mEndCalendar = mStartCalendar;
                toDateTxtView.setText(s);
            }
        }
        else if (view.getTag().equals(END_DATE_PICKER_TAG)){
            mEndCalendar = calendar;
            toDateTxtView.setText(s);
        }
    }

}
