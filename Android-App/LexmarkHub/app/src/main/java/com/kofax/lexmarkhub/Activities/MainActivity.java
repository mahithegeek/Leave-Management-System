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
import com.kofax.lexmarkhub.ServiceHandlers.LoginService;
import com.kofax.lexmarkhub.ServiceHandlers.LoginServiceCallBack;
import com.kofax.lexmarkhub.SharedPreferences;

import net.openid.appauth.AuthState;
import net.openid.appauth.AuthorizationException;
import net.openid.appauth.AuthorizationRequest;
import net.openid.appauth.AuthorizationResponse;
import net.openid.appauth.AuthorizationService;
import net.openid.appauth.AuthorizationServiceConfiguration;
import net.openid.appauth.TokenResponse;

import org.json.JSONException;

public class MainActivity extends Activity {
    private static final String SHARED_PREFERENCES_NAME = "AuthStatePreference";
    private static final String AUTH_STATE = "AUTH_STATE";
    private static final String USED_INTENT = "USED_INTENT";

    private  ProgressDialog mProgress;
    private final String LOG_TAG = MainActivity.class.getSimpleName();
    LinearLayout mButtonContainer;
    private static String mClientId = "890980614355-l8lm8hhjk7tidsvimq5meusk3q9t002n.apps.googleusercontent.com";
    private static String mRedirectUri = "com.kofax.lexmarkhub:/oauth2callbackLexmarkHub";

    AuthorizationService service;
    // state
    AuthState mAuthState;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mButtonContainer = (LinearLayout)findViewById(R.id.buttonContainer);
        mButtonContainer.setOnClickListener(new AuthorizeListener());
    }

    /**
     * Kicks off the authorization flow.
     */
    public class AuthorizeListener implements Button.OnClickListener {
        @Override
        public void onClick(View view) {
//            Intent intent = new Intent(MainActivity.this,LandingPageActivity.class);
//            startActivity(intent);
            AuthorizationServiceConfiguration serviceConfiguration = new AuthorizationServiceConfiguration(
                    Uri.parse("https://accounts.google.com/o/oauth2/v2/auth") /* auth endpoint */,
                    Uri.parse("https://www.googleapis.com/oauth2/v4/token") /* token endpoint */
            );
            // code from the section 'Making API Calls' goes here
            Uri redirectUri = Uri.parse(mRedirectUri);
            AuthorizationRequest.Builder builder = new AuthorizationRequest.Builder(
                    serviceConfiguration,
                    mClientId,
                    AuthorizationRequest.RESPONSE_TYPE_CODE,
                    redirectUri
            );

            builder.setScopes("profile");
            AuthorizationRequest request = builder.build();
            service = new AuthorizationService(view.getContext());

            String action = "com.kofax.lexmarkhub.HANDLE_AUTHORIZATION_RESPONSE";
            Intent postAuthorizationIntent = new Intent(action);
            PendingIntent pendingIntent = PendingIntent.getActivity(view.getContext(), request.hashCode(), postAuthorizationIntent, 0);
            service.performAuthorizationRequest(request, pendingIntent);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        checkIntent(intent);
    }

    private void checkIntent(@Nullable Intent intent) {
        if (intent != null) {
            String action = intent.getAction();
            switch (action) {
                case "com.kofax.lexmarkhub.HANDLE_AUTHORIZATION_RESPONSE":
                    if (!intent.hasExtra(USED_INTENT)) {
                        handleAuthorizationResponse(intent);
                        intent.putExtra(USED_INTENT, true);
                    }
                    break;
                default:
                    // do nothing
            }
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        checkIntent(getIntent());
    }

    @Override
    public void onDestroy(){
        super.onDestroy();
    }

    /**
     * Exchanges the code, for the {@link TokenResponse}.
     *
     * @param intent represents the {@link Intent} from the Custom Tabs or the System Browser.
     */
    private void handleAuthorizationResponse(@NonNull Intent intent) {

        // code from the step 'Handle the Authorization Response' goes here.
        AuthorizationResponse response = AuthorizationResponse.fromIntent(intent);
        AuthorizationException error = AuthorizationException.fromIntent(intent);
        final AuthState authState = new AuthState(response, error);

        if (response != null) {
            service = new AuthorizationService(this);
            service.performTokenRequest(response.createTokenExchangeRequest(),
                    new AuthorizationService.TokenResponseCallback() {
                        @Override
                        public void onTokenRequestCompleted(@Nullable TokenResponse tokenResponse,
                                                            @Nullable AuthorizationException exception) {
                            if (exception != null) {
//                                Log.w(LOG_TAG, "Token Exchange failed", exception);
                            } else {
                                if (tokenResponse != null) {
                                    authState.update(tokenResponse, exception);
                                    SharedPreferences.saveAuthToken(tokenResponse.idToken,MainActivity.this);
                                    loginWithTokenId(tokenResponse.idToken);
                                }
                            }
                        }
                    });
        }
    }

    private void loginWithTokenId(String tokenId){
        mAuthState = restoreAuthState();
        if (!tokenId.isEmpty()) {
            showSpinner();
            LoginService loginTask = new LoginService(MainActivity.this);
            loginTask.setLoginServiceCallBack(new LoginServiceCallBack() {
                @Override
                public void didFinishLogin(User user) {
                    removeSpinner();
                    //save user details in preferences and proceed
                    SharedPreferences.saveLoggedInUser(user,MainActivity.this);
                    Intent intent = new Intent(MainActivity.this,LandingPageActivity.class);
                    startActivity(intent);
                }
                @Override
                public void didFailLogin(int responseCode) {
                    toastError(""+responseCode);
                }
            });
            loginTask.execute(tokenId);
        } else {
            // TODO Google authentication failed. handle failure here
        }
    }

    public void toastError(String message){
        removeSpinner();
        final String toastmessage = message;
        this.runOnUiThread(new Runnable() {
            public void run() {
                Toast.makeText(MainActivity.this, toastmessage, Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void showSpinner(){
        mProgress = new ProgressDialog(this);
        mProgress.setMessage("Wait while loading...");
        mProgress.show();
    }

    private void removeSpinner(){
        mProgress.dismiss();
    }

    @Nullable
    private AuthState restoreAuthState() {
        String jsonString = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
                .getString(AUTH_STATE, null);
        if (!TextUtils.isEmpty(jsonString)) {
            try {
                return AuthState.fromJson(jsonString);
            } catch (JSONException jsonException) {
                // should never happen
            }
        }
        return null;
    }

}
