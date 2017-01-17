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
    @IBAction func pendingRequestBack (_ segue: UIStoryboardSegue){
        self.navigationController?.popViewController(animated: true)
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
                LMSServiceFactory.sharedInstance().getLeaveRequests(withURL: kLeaveRequestsURL, withParams: parameters as [String : AnyObject], completion: { (leaveRequests, error) in
                    Loader.hide();
                    self.pendingRequests.removeAll()
                    
                    if leaveRequests != nil {
                        
                        for leaveRequest in leaveRequests! {
                            print(leaveRequest)
                            let leaveRequestDict = leaveRequest as! NSDictionary
                            
                            
                            let firstName = leaveRequestDict["firstName"] as! String
                            let lastName = leaveRequestDict["lastName"] as! String

                            let employee=Employee.init(withDictionary: [
                                kFirstName:firstName,
                                kLastName:lastName
                                ])
                            
                            let reason = leaveRequestDict["reason"] as! String
                            let leave = Leave(reason: reason, employee: employee, startDate: AppUtilities().dateFromString(leaveRequestDict["fromDate"] as! String), endDate: AppUtilities().dateFromString(leaveRequestDict["toDate"] as! String), isHalfDay:leaveRequestDict["halfDay"] as! Bool,leaveType: leaveRequestDict["leaveType"] as! String)
                           
                            let leaveRequest = LeaveRequest(requestId: leaveRequestDict["id"] as! NSNumber
                                , status: leaveRequestDict["status"] as! String, leave: leave)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "pendingRequests", for: indexPath) as? PendingRequestsCell
        cell?.selectionStyle = .none
        let pendingRequest = pendingRequests[indexPath.row] as LeaveRequest
        cell?.nameLabel.text = pendingRequest.leave.employee!.name!
        cell?.leaveDatesLabel.text = AppUtilities().dateStringFromDate(pendingRequest.leave.startDate!) + " to " + AppUtilities().dateStringFromDate(pendingRequest.leave.endDate!)
        cell?.reasonLabel.text = "\(pendingRequest.leave.leaveType! )"
        cell?.statusLabel.text = pendingRequest.status
        return cell!
    }

     func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 120
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
       
        let pendingRequest = pendingRequests[indexPath.row] as LeaveRequest
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ApplyLeaveViewControllerIdentifier") as? ApplyLeaveViewController
        viewController?.leaveRequest = pendingRequest
        viewController?.leave = Leave(reason:pendingRequest.leave.reason! ,employee:pendingRequest.leave.employee ,startDate:pendingRequest.leave.startDate,endDate: pendingRequest.leave.endDate,isHalfDay:pendingRequest.leave.isHalfDay!,leaveType:pendingRequest.leave.leaveType!)
        viewController?.isFromPending = true
        self.navigationController?.pushViewController(viewController!, animated: true)

    }

    @IBAction func backButtonAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
