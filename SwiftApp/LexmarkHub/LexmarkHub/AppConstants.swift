//
//  AppConstants.swift
//  LexmarkHub
//
//  Created by Ravi on 8/31/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation
import UIKit

// Segues
let kDashboardSegue:String = "dashboardSegue"
let kUserLeaveRequestsSegue:String = "userLeaveRequestsSegue"
let kUserApplyLeaveSegue:String = "userApplyLeaveSegue"

/*! @var kIssuer
 @brief The OIDC issuer from which the configuration will be discovered.
 */
let kIssuer:String = "https://accounts.google.com"

/*! @var kClientID
 @brief The OAuth client ID.
 @discussion For Google, register your client at
 https://console.developers.google.com/apis/credentials?project=_
 The client should be registered with the "iOS" type.
 */
let kClientID:String = "890980614355-irpa0ap8n2phdq3fbop1382n2dufdep7.apps.googleusercontent.com"

/*! @var kRedirectURI
 @brief The OAuth redirect URI for the client @c kClientID.
 @discussion With Google, the scheme of the redirect URI is the reverse DNS notation of the
 client ID. This scheme must be registered as a scheme in the project's Info
 property list ("CFBundleURLTypes" plist key). Any path component will work, we use
 'oauthredirect' here to help disambiguate from any other use of this scheme.
 */
let kRedirectURI:String = "com.googleusercontent.apps.890980614355-irpa0ap8n2phdq3fbop1382n2dufdep7:/oauthredirect"

let kLoginURL:String = "http://172.26.32.163:9526/login"
let kAvailableLeavesURL:String = "http://172.26.32.163:9526/availableLeaves"
let kgetUsersURL:String = "http://172.26.32.163:9526/users"
let kApplyLeaveURL:String = "http://172.26.32.163:9526/leave"
let kApproveLeaveURL:String = "http://172.26.32.163:9526/approveLeave"
let kLeaveRequestsURL:String = "http://172.26.32.163:9526/leaveRequests"
let kUserRequestsURL:String = "http://172.26.32.163:9526/leaveHistory"
let kCancelLeaveURL:String = "http://172.26.32.163:9526/cancelLeave"

let kAppTitle = "Lexmark Hub"

let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate


