package com.kofax.lexmarkhub.ServiceHandlers;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import com.kofax.lexmarkhub.Objects.User;

import net.openid.appauth.AuthState;
import net.openid.appauth.AuthorizationException;
import net.openid.appauth.AuthorizationRequest;
import net.openid.appauth.AuthorizationResponse;
import net.openid.appauth.AuthorizationService;
import net.openid.appauth.AuthorizationServiceConfiguration;
import net.openid.appauth.TokenResponse;

import org.json.JSONException;
import org.json.JSONObject;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import static com.kofax.lexmarkhub.Activities.MainApplication.LOG_TAG;

/**
 * Created by venkateshkarra on 17/11/16.
 */

public class GoogleAuthenticator{
    public  enum GoogleAuthResponse {
        GoogleAuthenticationSuccess, GoogleAuthenticationFailed
    }

    private GoogleAuthResponse mGoogleAuthResponse;
    private final String SHARED_PREFERENCES_NAME = "AuthStatePreference";
    private final String AUTH_STATE = "AUTH_STATE";
    private final String USED_INTENT = "USED_INTENT";

    private GoogleAuthenticatorCallBack mGoogleAuthenticatorCallBack;
    private Context mContext;
    private String mClientId = "890980614355-l8lm8hhjk7tidsvimq5meusk3q9t002n.apps.googleusercontent.com";
    private String mRedirectUri = "com.kofax.lexmarkhub:/oauth2callbackLexmarkHub";
    // state
    private AuthState mAuthState;

    public GoogleAuthenticator(Context context){
        mContext = context;
    }
    public void setGoogleAuthenticatorCallBack(GoogleAuthenticatorCallBack callBack){
        mGoogleAuthenticatorCallBack = callBack;
    }

    public void authenticate(){
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
        AuthorizationService service = new AuthorizationService(mContext);

        String action = "com.kofax.lexmarkhub.HANDLE_AUTHORIZATION_RESPONSE";
        Intent postAuthorizationIntent = new Intent(action);
        PendingIntent pendingIntent = PendingIntent.getActivity(mContext, request.hashCode(), postAuthorizationIntent, 0);
        service.performAuthorizationRequest(request, pendingIntent);
    }

    public void checkIntent(@Nullable Intent intent) {
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
            AuthorizationService service = new AuthorizationService(mContext);
            service.performTokenRequest(response.createTokenExchangeRequest(),
                    new AuthorizationService.TokenResponseCallback() {
                        @Override
                        public void onTokenRequestCompleted(@Nullable TokenResponse tokenResponse,
                                                            @Nullable AuthorizationException exception) {
                            if (exception != null) {
                                Log.w(LOG_TAG, "Token Exchange failed", exception);
                            } else {
                                if (tokenResponse != null) {

                                    authState.update(tokenResponse, null);
                                    persistAuthState(authState);
                                    mAuthState = restoreAuthState();
                                    Log.d("GoogleAuthenticator", "token : "+tokenResponse.idToken);
                                }
                            }
                        }
                    });
        }
    }

    private void persistAuthState(@NonNull AuthState authState) {
        mContext.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE).edit()
                .putString(AUTH_STATE, authState.toJsonString())
                .apply();
        enablePostAuthorizationFlows();
    }

    private void enablePostAuthorizationFlows() {
        mAuthState = restoreAuthState();
        if (mAuthState != null && mAuthState.isAuthorized()) {
            mGoogleAuthenticatorCallBack.didFinishGoogleAuthentication(mGoogleAuthResponse.GoogleAuthenticationSuccess,mAuthState.getIdToken());
        } else {
            mGoogleAuthenticatorCallBack.didFinishGoogleAuthentication(mGoogleAuthResponse.GoogleAuthenticationFailed,null);
        }
    }

    @Nullable
    private AuthState restoreAuthState() {
        String jsonString = mContext.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
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

    //Service Call to get the image
    public void getProfilePic(Context context) {
        mAuthState = restoreAuthState();
        mAuthState.performActionWithFreshTokens(new AuthorizationService(context), new AuthState.AuthStateAction() {
            @Override
            public void execute(@Nullable String accessToken, @Nullable String idToken, @Nullable AuthorizationException exception) {
                new AsyncTask<String, Void, JSONObject>() {
                    @Override
                    protected JSONObject doInBackground(String... tokens) {
                        OkHttpClient client = new OkHttpClient();
                        Request request = new Request.Builder()
                                .url("https://www.googleapis.com/oauth2/v3/userinfo")
                                .addHeader("Authorization", String.format("Bearer %s", tokens[0]))
                                .build();

                        try {
                            Response response = client.newCall(request).execute();
                            String jsonBody = response.body().string();
                            return new JSONObject(jsonBody);
                        } catch (Exception exception) {
                            Log.w(LOG_TAG, exception);
                        }
                        return null;
                    }

                    @Override
                    protected void onPostExecute(JSONObject userInfo) {
                        if (userInfo != null) {
                            String imageUrl = userInfo.optString("picture", null);
                            if (!TextUtils.isEmpty(imageUrl)) {
                                Log.d("Image URL","ImageURL : "+imageUrl);
                                //TODO load image from url here
                                mGoogleAuthenticatorCallBack.didFinishLoadingProfile(imageUrl,userInfo);
                            }
                            else
                                mGoogleAuthenticatorCallBack.didFinishLoadingProfile(null,userInfo);
                        }
                    }
                }.execute(accessToken);
            }
        });
    }
}

