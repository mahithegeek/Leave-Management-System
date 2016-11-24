//
//  PendingRequestViewController.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class PendingRequestViewController: UIViewController {

    var pendingRequests = [LeaveRequest]()

    @IBOutlet var pendingRequestsTableView: UITableView!
    @IBAction func pendingRequestBack (segue: UIStoryboardSegue){
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshPendingRequests()
    }


    func refreshPendingRequests() {
       
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!
                ]
                LMSServiceFactory.sharedInstance().getLeaveRequests(withURL: kLeaveRequestsURL, withParams: parameters, completion: { (leaveRequests, error) in
                    Loader.hide();
                    self.pendingRequests.removeAll()
                    
                    if leaveRequests != nil {
                        
                        for leaveRequest in leaveRequests! {
                            print(leaveRequest)
                            let firstName = leaveRequest["firstName"] as! String
                            let lastName = leaveRequest["lastName"] as! String

                            let employee=Employee.init(withDictionary: [
                                kFirstName:firstName,
                                kLastName:lastName
                                ])
                            
                            let reason = leaveRequest["reason"] as! String
                            let leave = Leave(reason: reason, employee: employee, startDate: AppUtilities().dateFromString(leaveRequest["fromDate"] as! String), endDate: AppUtilities().dateFromString(leaveRequest["toDate"] as! String),leaveType: "Vocation")
                            let leaveRequest = LeaveRequest(requestId: leaveRequest["id"] as! NSInteger
                                , status: leaveRequest["status"] as! String, leave: leave)
                            let leavestatus = leaveRequest.status
                            if (leavestatus == "Applied"){
                                self.pendingRequests.append(leaveRequest)
                            }
                        }
                        
                        LMSThreading.dispatchOnMain(withBlock: { (Void) in
                            self.pendingRequestsTableView.reloadData()

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
        let cell = tableView.dequeueReusableCellWithIdentifier("pendingRequests", forIndexPath: indexPath) as? PendingRequestsCell
        cell?.selectionStyle = .None
        let pendingRequest = pendingRequests[indexPath.row] as LeaveRequest
        cell?.nameLabel.text = pendingRequest.leave.employee!.name!
        cell?.leaveDatesLabel.text = AppUtilities().dateStringFromDate(pendingRequest.leave.startDate!) + " to " + AppUtilities().dateStringFromDate(pendingRequest.leave.endDate!)
        cell?.reasonLabel.text = "\(pendingRequest.leave.leaveType! )"
        cell?.statusLabel.text = pendingRequest.status
        
        
        return cell!
    }

     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        let pendingRequest = pendingRequests[indexPath.row] as LeaveRequest
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("ApplyLeaveViewControllerIdentifier") as? ApplyLeaveViewController
        viewController?.leaveRequest = pendingRequest
        viewController?.leave = Leave(reason:pendingRequest.leave.reason! ,employee:pendingRequest.leave.employee ,startDate:pendingRequest.leave.startDate,endDate: pendingRequest.leave.endDate,leaveType:"Vacation")
        viewController?.isFromPending = true
        self.navigationController?.pushViewController(viewController!, animated: true)

    }

    @IBAction func backButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
