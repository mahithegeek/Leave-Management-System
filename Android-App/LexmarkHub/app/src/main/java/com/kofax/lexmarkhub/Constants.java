package com.kofax.lexmarkhub;

import com.kofax.lexmarkhub.Objects.User;

import static android.R.attr.description;
import static android.R.attr.id;

/**
 * Created by venkateshkarra on 21/10/16.
 */

public class Constants {
    public static final String baseUrl = "http://172.26.32.163:9526/";
    public static final String availableLeaves_Endpoint = "availableLeaves";
    public static final String applyLeave_Endpoint = "leave";
    public static final String login_Endpoint = "login";
    public static final String leaveHistory_Endpoint = "leaveHistory";
    public static final String leaverequests_Endpoint = "leaverequests";
    public static final String approveLeave_Endpoint = "approveLeave";

    public static final String ENCODING_TYPE = "UTF-8";

    public static final String ACCEPT = "Accept";
    public static final String TYPE_JSON = "application/json";
    public static final String CONTENT_TYPE= "Content-Type";
    public static final String REQUEST_METHOD_POST = "POST";
    public static final String REQUEST_METHOD_GET = "GET";

    //Login RequestKeys
    public static final String TOKEN_ID = "tokenID";

    //Login ResponseKeys
    public static final String FNAME = "firstName";
    public static final String LNAME = "lastName";
    public static final String EMAIL = "email";
    public static final String EMPID = "empID";
    public static final String ROLE = "role";
    public static final String SUPERVISOR = "supervisor";

    //AvailableLEave Response Keys
    public static final String REC_ID ="id";
    public static final String SPECIAL = "special";
    public static final String COMP_OFF = "comp-off";
    public static final String CARRY_FORWARD = "carry_forward";
    public static final String AVAILABLE = "available";

    //ApplyLeave Request Keys
    public static final String LEAVE = "leave";
    public static final String FROM_DATE = "fromDate";
    public static final String TO_DATE = "toDate";
    public static final String IS_HALF_DAY = "isHalfDay";
    public static final String TYPE = "type";

    //LeaveHistory ResponseKeys
    public static final String DATE_FROM = "date_from";
    public static final String DATE_TO = "date_to";
    public static final String STATUS = "status";


    //LeaveRequests responseKeys
    public static final String APPLIED_ON = "appliedOn";
    public static final String REQUESTID = "id";
    public static final String LEAVE_REQUESTS = "leaverequests";
    public static final String SUCCESS = "success";
    public static final String DESCRIPTION = "description";
    public static final String REASON = "reason";

    //Approve RequestKeys
    public static final String REQUEST_ID = "requestID";
    public static final String LEAVE_STATUS = "leaveStatus";
    public static final String STATUS_APPROVE = "Approve";
    public static final String STATUS_REJECT = "Reject";
    public static final String STATUS_APPLIED = "Applied";

    //CustomKeys
    public static final String REQUEST_OBJECT_EXTRA = "RequestExtra";

    //Exception Codes
    public static final int EXCEPTION_ERROR =  111;
    public static final int DUMMY_ERROR = 0;
    public static final int ERROR_CODE_SUCCESS = 200;
}
