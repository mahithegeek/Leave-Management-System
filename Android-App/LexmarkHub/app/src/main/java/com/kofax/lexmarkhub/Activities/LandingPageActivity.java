package com.kofax.lexmarkhub.Activities;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.kofax.lexmarkhub.Objects.User;
import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.ServiceHandlers.GoogleAuthenticator;
import com.kofax.lexmarkhub.ServiceHandlers.GoogleAuthenticatorCallBack;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandler;
import com.kofax.lexmarkhub.ServiceHandlers.LMS_ServiceHandlerCallBack;
import com.kofax.lexmarkhub.SharedPreferences;
import com.kofax.lexmarkhub.Utility.RoundedTransformation;
import com.kofax.lexmarkhub.Utility.Utility;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static com.kofax.lexmarkhub.Constants.AVAILABLE;
import static com.kofax.lexmarkhub.Constants.DUMMY_ERROR;
import static com.kofax.lexmarkhub.Constants.TOKEN_ID;

public class LandingPageActivity extends Activity {

    private User mUser;
    private ImageView mNewRequestView;
    private LinearLayout mListofholidaysView;
    private LinearLayout mViewstatusView;
    private LinearLayout mPendingrequestView;
    private ImageView mProfileImageView;
    private TextView mLeavesTextView;
    private TextView mUserNameView;
    private TextView mEmpIdView;
    private TextView mEmailIdView;

    ProgressDialog mProgress;
    GoogleAuthenticator mGoogleAuthenticator;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_landing_page);
        mUser = Utility.getLoggedInUser(this);

        setupUI();
        getAvailableLeaves();
    }

    @Override
    public void onBackPressed() {
        moveTaskToBack(false);
    }

    public void setupUI(){
        mNewRequestView = (ImageView) findViewById(R.id.newrequest_View);
        mListofholidaysView = (LinearLayout) findViewById(R.id.listofholidays_View);
        mViewstatusView = (LinearLayout) findViewById(R.id.viewstatus_View);
        mPendingrequestView = (LinearLayout) findViewById(R.id.pendingrequest_View);
        mLeavesTextView = (TextView) findViewById(R.id.num_leaves_txtView);
        mProfileImageView = (ImageView) findViewById(R.id.profile_imageView);
        mUserNameView = (TextView) findViewById(R.id.name_textView);
        mEmpIdView = (TextView) findViewById(R.id.empid_textView);
        mEmailIdView = (TextView) findViewById(R.id.email_textView);

        if (mUser.getRole() == User.Role.EMPLOYEE){
            mPendingrequestView.setVisibility(View.GONE);
        }

        User user = Utility.getLoggedInUser(this);
        mUserNameView.setText(user.getfName()+" "+user.getlName());
        mEmpIdView.setText(user.getEmpId());
        mEmailIdView.setText(user.getEmailId());

        mNewRequestView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LandingPageActivity.this, NewLeaveRequestActivity.class);
                startActivity(intent);
            }
        });

        mViewstatusView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LandingPageActivity.this, ViewStatusActivity.class);
                startActivity(intent);
            }
        });

        mPendingrequestView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LandingPageActivity.this, PendingRequestsActivity.class);
                startActivity(intent);
            }
        });

        mGoogleAuthenticator = new GoogleAuthenticator(this);
        mGoogleAuthenticator.setGoogleAuthenticatorCallBack(new GoogleAuthenticatorCallBack() {
            @Override
            public void didFinishGoogleAuthentication(GoogleAuthenticator.GoogleAuthResponse response, String tokenID) {
            }

            @Override
            public void didFinishLoadingProfile(String imageUrl, JSONObject userInfo) {
              if (imageUrl.length()>0){
                  Picasso.with(getApplicationContext())
                          .load(imageUrl)
                          .transform(new RoundedTransformation(300, 0))
                          .fit()
                          .into(mProfileImageView);
              }
            }
        });
        mGoogleAuthenticator.getProfilePic(this);
    }

    public void logoutAction(View view){
        SharedPreferences.removeAuthenticaionToken(this);
        SharedPreferences.removeLoggedInUser(this);
        finish();
    }

    public void  getAvailableLeaves(){
        showSpinner();
        LMS_ServiceHandler lms_serviceHandler = new LMS_ServiceHandler(this);
        lms_serviceHandler.setLmsServiceCallBack(new LMS_ServiceHandlerCallBack() {
            @Override
            public void didFinishServiceWithResponse(final String response) {

                LandingPageActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        removeSpinner();
                        Log.d("landing Page", ""+response);
                        try{
                            JSONArray responseObject = new JSONArray(response);
                            JSONObject requestJson = responseObject.getJSONObject(0);
                            String availableLeaves = requestJson.getString(AVAILABLE);
                            mLeavesTextView.setText(availableLeaves);
                        }
                        catch (JSONException e){
                            e.printStackTrace();
                            Toast.makeText(LandingPageActivity.this, Utility.getErrorMessageForCode(DUMMY_ERROR),
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                });

            }

            @Override
            public void didFailService(final int responseCode) {
                LandingPageActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        removeSpinner();
                        Toast.makeText(LandingPageActivity.this, Utility.getErrorMessageForCode(responseCode),
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        lms_serviceHandler.getAvailableLeaves(getJsonBodyForAvailableLeaves().toString());
    }

    private JSONObject getJsonBodyForAvailableLeaves() {
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
