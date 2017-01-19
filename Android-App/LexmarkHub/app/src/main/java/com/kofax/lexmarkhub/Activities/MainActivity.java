package com.kofax.lexmarkhub.Activities;

import android.app.Activity;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.Toast;

import com.kofax.lexmarkhub.Objects.User;
import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.ServiceHandlers.GoogleAuthenticator;
import com.kofax.lexmarkhub.ServiceHandlers.GoogleAuthenticatorCallBack;
import com.kofax.lexmarkhub.ServiceHandlers.LoginService;
import com.kofax.lexmarkhub.ServiceHandlers.LoginServiceCallBack;
import com.kofax.lexmarkhub.SharedPreferences;
import com.kofax.lexmarkhub.Utility.Utility;

import net.openid.appauth.AuthState;
import net.openid.appauth.AuthorizationException;
import net.openid.appauth.AuthorizationRequest;
import net.openid.appauth.AuthorizationResponse;
import net.openid.appauth.AuthorizationService;
import net.openid.appauth.AuthorizationServiceConfiguration;
import net.openid.appauth.TokenResponse;

import org.json.JSONException;
import org.json.JSONObject;

import static android.R.attr.breadCrumbShortTitle;
import static android.R.attr.id;
import static android.R.attr.thickness;

public class MainActivity extends Activity {
    private  ProgressDialog mProgress;
    LinearLayout mButtonContainer;

    GoogleAuthenticator mGoogleAuthenticator;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mButtonContainer = (LinearLayout)findViewById(R.id.buttonContainer);
        mButtonContainer.setOnClickListener(new AuthorizeListener());
        mGoogleAuthenticator = new GoogleAuthenticator(this);
        mGoogleAuthenticator.setGoogleAuthenticatorCallBack(new GoogleAuthenticatorCallBack() {
            @Override
            public void didFinishGoogleAuthentication(GoogleAuthenticator.GoogleAuthResponse response, String tokenID) {
//                mGoogleAuthenticator.getProfilePic(MainActivity.this);
                switch (response){
                    case GoogleAuthenticationSuccess:
                        SharedPreferences.saveAuthToken(tokenID,MainActivity.this);
                        loginWithTokenId(tokenID);
                        break;
                    case GoogleAuthenticationFailed:
                        toastError("GoogleAuthentication failed.");
                        break;
                    default:
                }
            }

            @Override
            public void didFinishLoadingProfile(String ImageUrl, JSONObject userInfo) {

            }
        });
    }

    public class AuthorizeListener implements Button.OnClickListener {
        @Override
        public void onClick(View view) {
            mGoogleAuthenticator.authenticate();
        }
    }
    @Override
    protected void onNewIntent(Intent intent) {
        mGoogleAuthenticator.checkIntent(intent);
    }
    @Override
    protected void onStart() {
        super.onStart();
        mGoogleAuthenticator.checkIntent(getIntent());
    }
    @Override
    public void onDestroy(){
        super.onDestroy();
    }
    public void loginWithTokenId(String tokenId){
        if (!tokenId.isEmpty()) {
            Utility.showSpinner(this);
            LoginService loginTask = new LoginService(MainActivity.this);
            loginTask.setLoginServiceCallBack(new LoginServiceCallBack() {
                @Override
                public void didFinishLogin(User user) {
                    Utility.removeSpinner();
                    //save user details in preferences and proceed
                    SharedPreferences.saveLoggedInUser(user,MainActivity.this);
                    Intent intent = new Intent(MainActivity.this,LandingPageActivity.class);
                    startActivity(intent);
                }
                @Override
                public void didFailLogin(final int responseCode, final String errorResponse) {
                    MainActivity.this.runOnUiThread(new Runnable() {
                        public void run() {
                            Utility.removeSpinner();
                            Toast.makeText(MainActivity.this, Utility.getErrorMessageForCode(responseCode,errorResponse),
                                    Toast.LENGTH_SHORT).show();
                        }
                    });
                }
            });
            loginTask.execute(tokenId);
        } else {
            // TODO Google authentication failed. handle failure here
        }
    }
    public void toastError(String message){
        Utility.removeSpinner();
        final String toastMessage = message;
        this.runOnUiThread(new Runnable() {
            public void run() {
                Toast.makeText(MainActivity.this, toastMessage, Toast.LENGTH_SHORT).show();
            }
        });
    }
    public void showSpinner(){
        mProgress = new ProgressDialog(this);
        mProgress.setMessage(getResources().getString(R.string.loading));
        mProgress.show();
    }
}
