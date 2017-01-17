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
                LMSServiceFactory.sharedInstance().getUserLeaveRequests(withURL: kUserRequestsURL, withParams: parameters as [String : AnyObject], completion: { (leaveRequests, error) in
                    Loader.hide();
                    self.pendingRequests.removeAll()
                    
                    print(leaveRequests)
                    if leaveRequests != nil {
                        
                        for leaveRequest in leaveRequests! {
                            
                            let leaveRequestDict = leaveRequest as! NSDictionary
                            
                            let employee=Employee.init(withDictionary: [
                                kFirstName:(self.employee?.name?.components(separatedBy: " ").first)!,
                                kLastName:(self.employee?.name?.components(separatedBy: " ").last)!
                                ])
                            let leave = Leave(reason: leaveRequestDict["reason"] as! String, employee: employee, startDate: AppUtilities().dateFromString(leaveRequestDict["fromDate"] as! String), endDate: AppUtilities().dateFromString(leaveRequestDict["toDate"] as! String),isHalfDay:leaveRequestDict["halfDay"] as! Bool,leaveType: leaveRequestDict["leaveType"] as! String)
                          
                            
                            
                            let leaveRequest = LeaveRequest(requestId: leaveRequestDict["id"] as! NSNumber
                                , status: leaveRequestDict["status"] as! String, leave: leave)

                            
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
                            Popups.sharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                        }
                    }
                })
            }
            else {
                Loader.hide();
                if error != nil {
                    Popups.sharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pendingRequests.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserRequests", for: indexPath) as? UserRequestsCell
        cell?.selectionStyle = .none
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
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
    
        
    }
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectUserRequestWithId(_ requestId: NSNumber) {
        cancelLeaveWithId(requestId)
    }
    
    func cancelLeaveWithId(_ reqId: NSNumber){
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!,
                    "requestID":reqId
                ] as [String : Any]
                LMSServiceFactory.sharedInstance().cancelLeave(withURL: kCancelLeaveURL, withParams: parameters as [String : AnyObject], completion: { (response, error) in
                    Loader.hide();
                    if response != nil {
                        self.refreshUserLeaveRequests()
                        print("response:\(response)")
                    }
                    else {
                        if error != nil {
                            Popups.sharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                        }
                    }
                })
            }
            else {
                Loader.hide();
                if error != nil {
                    Popups.sharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                }
            }
        })
    }
}
