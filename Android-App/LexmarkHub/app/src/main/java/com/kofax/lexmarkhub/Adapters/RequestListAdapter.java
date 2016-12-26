package com.kofax.lexmarkhub.Adapters;

import android.content.Context;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import com.google.gson.JsonObject;
import com.google.gson.internal.Primitives;
import com.kofax.lexmarkhub.R;
import com.kofax.lexmarkhub.ServiceHandlers.GoogleAuthenticator;
import com.kofax.lexmarkhub.Utility.Utility;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.concurrent.TimeoutException;

import static android.R.attr.name;
import static com.kofax.lexmarkhub.Constants.AVAILABLE;
import static com.kofax.lexmarkhub.Constants.DATE_FROM;
import static com.kofax.lexmarkhub.Constants.DATE_TO;
import static com.kofax.lexmarkhub.Constants.FNAME;
import static com.kofax.lexmarkhub.Constants.FROM_DATE;
import static com.kofax.lexmarkhub.Constants.LEAVE_TYPE;
import static com.kofax.lexmarkhub.Constants.LNAME;
import static com.kofax.lexmarkhub.Constants.STATUS;
import static com.kofax.lexmarkhub.Constants.STATUS_REJECT;
import static com.kofax.lexmarkhub.Constants.STATUS_REJECTED;
import static com.kofax.lexmarkhub.Constants.TO_DATE;

/**
 * Created by venkateshkarra on 27/10/16.
 */

public class RequestListAdapter extends ArrayAdapter<JSONObject> {
    public enum RequestAction {
        RequestCancel
    }

    public interface RequestListAdapterCallBack {
        void didSelectRequestItemWithAction(JSONObject RequestItem, RequestAction requestAction);
    }

    private Context mContext;
    private Boolean mIsForPendingScreen;
    public RequestListAdapterCallBack requestListAdapterCallBack;

    public RequestListAdapter(Context context, ArrayList<JSONObject> requests,Boolean isForPendingScreen){
        super(context, 0, requests);
        mContext = context;
        mIsForPendingScreen = isForPendingScreen;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        View listItemView = convertView;

        if (listItemView ==  null){
            listItemView = LayoutInflater.from(getContext()).inflate(R.layout.request_list_item,parent,false);
        }
        TextView cancelTextView = (TextView)listItemView.findViewById(R.id.cancel_action);
        ImageView arrowImage = (ImageView)listItemView.findViewById(R.id.disclosure_arrow);
        final JSONObject request = getItem(position);
        if(mIsForPendingScreen == true){
            cancelTextView.setVisibility(View.GONE);
            arrowImage.setVisibility(View.VISIBLE);
        }
        else {
            cancelTextView.setVisibility(View.VISIBLE);
            arrowImage.setVisibility(View.GONE);
        }

        try {
            // don't show cancel button if the status is rejected
            if (request.getString(STATUS).equalsIgnoreCase(STATUS_REJECTED)){
                cancelTextView.setVisibility(View.GONE);
            }
            TextView status = (TextView) listItemView.findViewById(R.id.status_lable);
            status.setText(request.getString(STATUS));

            TextView name = (TextView) listItemView.findViewById(R.id.name_lable);
            TextView date = (TextView) listItemView.findViewById(R.id.date_lable);
            String userName;
            String dateString;
            if(mIsForPendingScreen == true) {
                userName = request.getString(FNAME)+" "+request.getString(LNAME);
                dateString = request.getString(FROM_DATE)+" to "+request.getString(TO_DATE);
            }
            else{
                userName = Utility.getLoggedInUser(mContext).getfName()+" "
                        +Utility.getLoggedInUser(mContext).getlName();
                dateString = request.getString(FROM_DATE)+" to "+request.getString(TO_DATE);
            }
            name.setText(userName);
            date.setText(dateString);

            TextView reason = (TextView) listItemView.findViewById(R.id.reason_txtView);
            //TODO hardcoding this text for now. Once we get tha reason in response change this
            reason.setText(request.getString(LEAVE_TYPE));
        }
        catch (JSONException e){
            e.printStackTrace();
        }

        cancelTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                requestListAdapterCallBack.didSelectRequestItemWithAction(request,RequestAction.RequestCancel);
            }
        });
        return  listItemView;
    }
}
