package com.kofax.lexmarkhub.Activities;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.DatePicker;
import android.widget.ImageView;

import com.kofax.lexmarkhub.Utility.DatePickerDialogFragment;
import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandler;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandlerCallBack;
import com.kofax.lexmarkhub.SharedPreferences;
import com.kofax.lexmarkhub.Utility.Utility;

import android.app.DatePickerDialog.OnDateSetListener;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import static com.kofax.lexmarkhub.Constants.AVAILABLE;
import static com.kofax.lexmarkhub.Constants.DESCRIPTION;
import static com.kofax.lexmarkhub.Constants.DUMMY_ERROR;
import static com.kofax.lexmarkhub.Constants.FROM_DATE;
import static com.kofax.lexmarkhub.Constants.IS_HALF_DAY;
import static com.kofax.lexmarkhub.Constants.LEAVE;
import static com.kofax.lexmarkhub.Constants.SUCCESS;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;
import static com.kofax.lexmarkhub.Constants.TO_DATE;
import static com.kofax.lexmarkhub.Constants.TYPE;

public class NewLeaveRequestActivity extends AppCompatActivity implements OnDateSetListener{
    static final int START_DATE_PICKER_TAG = 1298;//random tag numbers
    static final int END_DATE_PICKER_TAG = 1299;
    private int startYear;
    private int startMonth;
    private int startDay;
    private int endYear;
    private int endMonth;
    private int endDay;

    private ProgressDialog mProgress;
    private TextView fromDateTxtView;
    private TextView toDateTxtView;
    private TextView reasonTxtView;
    private RadioGroup radioLeaveTypeGroup;
    private RadioButton radioLeaveTypeButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_leave_request);

        getSupportActionBar().setTitle(R.string.new_request_title);
        ImageView startDateButton = (ImageView) findViewById(R.id.startDateView);
        ImageView endDateButton = (ImageView) findViewById(R.id.endDateView);
        fromDateTxtView = (TextView) findViewById(R.id.fromdate_textView);
        toDateTxtView = (TextView) findViewById(R.id.todate_textView);
        reasonTxtView = (TextView) findViewById(R.id.reason_txtView);
        radioLeaveTypeGroup = (RadioGroup) findViewById(R.id.timeOff_radioGrooup);

        final Calendar c = Calendar.getInstance();
        startYear = endYear = c.get(Calendar.YEAR);
        startMonth = endMonth = c.get(Calendar.MONTH);
        startDay = endDay = c.get(Calendar.DAY_OF_MONTH);

        startDateButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Bundle b = new Bundle();
                b.putInt(DatePickerDialogFragment.YEAR, startYear);
                b.putInt(DatePickerDialogFragment.MONTH, startMonth);
                b.putInt(DatePickerDialogFragment.DATE, startDay);
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
                b.putInt(DatePickerDialogFragment.YEAR, endYear);
                b.putInt(DatePickerDialogFragment.MONTH, endMonth);
                b.putInt(DatePickerDialogFragment.DATE, endDay);
                b.putInt(DatePickerDialogFragment.TAG, END_DATE_PICKER_TAG);
                android.app.DialogFragment picker = new DatePickerDialogFragment();
                picker.setArguments(b);
                picker.show(getFragmentManager(), "fragment_date_picker");
            }
        });

        setCurrentDate();
    }
    public void submitRequestAction(View view){
        if (validateDate() == false){
            return;
        }
        showSpinner();
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response) {
                removeSpinner();
                NewLeaveRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Log.d("new request page", ""+response);
                        showResult(response);
                    }
                });

            }

            @Override
            public void didFailService(final int responseCode) {
                NewLeaveRequestActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        removeSpinner();
                        Toast.makeText(NewLeaveRequestActivity.this, Utility.getErrorMessageForCode(responseCode),
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        lms_serviceHandler.applyLeave(getJsonBodyForApplyLeave().toString().replace("\\",""));

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
                Toast.makeText(NewLeaveRequestActivity.this, Utility.getErrorMessageForCode(DUMMY_ERROR),
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

                String startDt = startYear+"-"+(startMonth+1)+"-"+startDay;
                leaveObject.put(FROM_DATE, startDt);
                leaveObject.put(TO_DATE, endYear+"-"+(endMonth+1)+"-"+endDay);
                leaveObject.put(IS_HALF_DAY, false);
                String reason = reasonTxtView.getText().toString();
                leaveObject.put(TYPE,reason.replace(getResources().getString(R.string.Reason),""));
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
        Calendar startcalendar = Calendar.getInstance();
        startcalendar.set(Calendar.YEAR, startYear);
        startcalendar.set(Calendar.MONTH, startMonth);
        startcalendar.set(Calendar.DAY_OF_MONTH, startDay);

        Calendar endcalendar = Calendar.getInstance();
        endcalendar.set(Calendar.YEAR, endYear);
        endcalendar.set(Calendar.MONTH, endMonth);
        endcalendar.set(Calendar.DAY_OF_MONTH, endDay);


        long startTime = startcalendar.getTimeInMillis();
        long endTime = endcalendar.getTimeInMillis();

        int selectedId = radioLeaveTypeGroup.getCheckedRadioButtonId();
        radioLeaveTypeButton = (RadioButton)findViewById(selectedId);
        if (startcalendar.getTimeInMillis()>endcalendar.getTimeInMillis()){
            Toast.makeText(this,"End date should be later than start Date",Toast.LENGTH_LONG).show();
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

        this.startYear = calendar.get(Calendar.YEAR);
        this.startMonth = calendar.get(Calendar.MONTH);
        this.startDay = calendar.get(Calendar.DAY_OF_MONTH);

        this.endYear = calendar.get(Calendar.YEAR);
        this.endMonth = calendar.get(Calendar.MONTH);
        this.endDay = calendar.get(Calendar.DAY_OF_MONTH);

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

        Log.d("ondateSet","monthOfYear : "+monthOfYear);

        Format formatter = new SimpleDateFormat("dd-MM-yyyy");
        String s = formatter.format(calendar.getTime());

        if (view.getTag().equals(START_DATE_PICKER_TAG)){
            this.startYear = year;
            this.startMonth = monthOfYear;
            this.startDay = dayOfMonth;
            fromDateTxtView.setText(s);
        }
        else if (view.getTag().equals(END_DATE_PICKER_TAG)){
            this.endYear = year;
            this.endMonth = monthOfYear;
            this.endDay = dayOfMonth;
            toDateTxtView.setText(s);
        }
    }

}
