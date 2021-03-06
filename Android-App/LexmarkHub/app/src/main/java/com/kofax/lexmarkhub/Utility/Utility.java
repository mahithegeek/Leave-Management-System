package com.kofax.lexmarkhub.Utility;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.kofax.lexmarkhub.Activities.NewLeaveRequestActivity;
import com.kofax.lexmarkhub.Activities.PendingRequestsActivity;
import com.kofax.lexmarkhub.Objects.User;
import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.SharedPreferences;
import com.squareup.picasso.StatsSnapshot;

import org.json.JSONException;
import org.json.JSONObject;

import static com.kofax.lexmarkhub.Activities.MainApplication.LOG_TAG;
import static com.kofax.lexmarkhub.Constants.RESPONSEKEY_CODE;

/**
 * Created by venkateshkarra on 20/10/16.
 */

public class Utility {
    private  static ProgressDialog mProgress;
    public static User getLoggedInUser(Context context){
        return  SharedPreferences.getLoggedInUser(context);
    }
    public static  String getErrorMessageForCode(int code, String errorResponse){

        int errorCode = code;
        if (errorResponse != null){
            try{
                JSONObject productsJson = new JSONObject(errorResponse);
                errorCode = productsJson.getInt(RESPONSEKEY_CODE);

                //return productsJson.getInt(DESCRIPTION);
            }
            catch (JSONException e){
                e.printStackTrace();
            }
        }

        Log.d("Utility","Error Code:"+code);
        switch (errorCode){
            case 4300:
                return "Leaves of type not available";
            case 4001:
                return "User not found";
            default:
                return "Error occurred. Please try again later";
        }
    }



    private boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivityManager
                = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetworkInfo != null && activeNetworkInfo.isConnected();
    }

    public static void showSpinner(Context context){
        mProgress = new ProgressDialog(context);
        mProgress.setMessage(context.getResources().getString(R.string.loading));
        mProgress.show();
    }
    public static void removeSpinner(){
        mProgress.dismiss();
    }

}
