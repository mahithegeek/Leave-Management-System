//
//  UserRequestsViewController.swift
//  LexmarkHub
//
//  Created by Kofax on 13/10/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

let cancelButtonWidth:CGFloat = 57

class UserRequestsViewController: UIViewController, UserRequestsCellDelegate {
    
    var pendingRequests = [LeaveRequest]()
    var employee: Employee?

    @IBOutlet var userRequestsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUserLeaveRequests()
    }
    
    
    func refreshUserLeaveRequests() {
        print("hbjshdbfhjsdbf jhsb dfsbdfjbsdjfhbdhsfjs")
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!
                ]
                LMSServiceFactory.sharedInstance().getUserLeaveRequests(withURL: kUserRequestsURL, withParams: parameters, completion: { (leaveRequests, error) in
                    Loader.hide();
                    self.pendingRequests.removeAll()
                    
                    print(leaveRequests)
                    if leaveRequests != nil {
                        
                        for leaveRequest in leaveRequests! {
                            
                            let employee=Employee.init(withDictionary: [
                                kFirstName:(self.employee?.name?.componentsSeparatedByString(" ").first)!,
                                kLastName:(self.employee?.name?.componentsSeparatedByString(" ").last)!
                                ])
                            let leave = Leave(reason: leaveRequest["reason"] as! String, employee: employee, startDate: AppUtilities().dateFromString(leaveRequest["fromDate"] as! String), endDate: AppUtilities().dateFromString(leaveRequest["toDate"] as! String),isHalfDay:leaveRequest["halfDay"] as! Bool,leaveType: leaveRequest["leaveType"] as! String)
                            let leaveRequest = LeaveRequest(requestId: leaveRequest["id"] as! NSInteger
                                , status: leaveRequest["status"] as! String, leave: leave)
                            
                            let status = leaveRequest.status
                            if(status != "Cancelled"){
                                self.pendingRequests.append(leaveRequest)
                            }
                        }
                        
                        LMSThreading.dispatchOnMain(withBlock: { (Void) in
                            self.userRequestsTableView.reloadData()
                            
                        })
                        
                        print("leaveRequests:\(leaveRequests)")
                    }
                    else {
                        if error != nil {
                            Popups.SharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                        }
                    }
                })
            }
            else {
                Loader.hide();
                if error != nil {
                    Popups.SharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pendingRequests.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserRequests", forIndexPath: indexPath) as? UserRequestsCell
        cell?.selectionStyle = .None
        let pendingRequest = pendingRequests[indexPath.row] as LeaveRequest
        cell?.delegate = self
        cell?.nameLabel.text = pendingRequest.leave.employee!.name!
        cell?.leaveDatesLabel.text = AppUtilities().dateStringFromDate(pendingRequest.leave.startDate!) + " to " + AppUtilities().dateStringFromDate(pendingRequest.leave.endDate!)
        cell?.reasonLabel.text = "\(pendingRequest.leave.leaveType! )"
        cell?.statusLabel.text = pendingRequest.status
        cell?.reqId = pendingRequest.requestId
        if pendingRequest.status != "Rejected" {
            cell?.cancelWidthConstraint.constant = cancelButtonWidth
        }
        else {
            cell?.cancelWidthConstraint.constant = 0
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didSelectUserRequestWithId(requestId: NSNumber) {
        cancelLeaveWithId(requestId)
    }
    
    func cancelLeaveWithId(reqId: NSNumber){
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!,
                    "requestID":reqId
                ]
                LMSServiceFactory.sharedInstance().cancelLeave(withURL: kCancelLeaveURL, withParams: parameters, completion: { (response, error) in
                    Loader.hide();
                    if response != nil {
                        self.refreshUserLeaveRequests()
                        print("response:\(response)")
                    }
                    else {
                        if error != nil {
                            Popups.SharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                        }
                    }
                })
            }
            else {
                Loader.hide();
                if error != nil {
                    Popups.SharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                }
            }
        })
    }
}
