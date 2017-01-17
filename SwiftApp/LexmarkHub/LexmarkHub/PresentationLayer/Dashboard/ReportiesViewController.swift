//
//  UsersViewController.swift
//  LexmarkHub
//
//  Created by Kofax on 23/09/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation
import UIKit

class ReportiesViewController: UIViewController {
    
    var reporties = [Reporter]()
    @IBOutlet weak var reportiesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.reportiesTableView.tableHeaderView = UIView(frame:CGRect(x: 0.0, y: 0.0, width: 0.0, height: 1.0)); //To hide the gap
        
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!
                ]
                LMSServiceFactory.sharedInstance().getUsers(withURL: kgetUsersURL, withParams: parameters as [String : AnyObject], completion: { (users, error) in
                    Loader.hide();
                    if users != nil {
                        for reporterDict in users! {
                            let reporter = Reporter.init(withDictionary: reporterDict as! NSDictionary)
                            self.reporties.append(reporter)
                        }
                        LMSThreading.dispatchOnMain(withBlock: { (Void) in
                            self.reportiesTableView.reloadData()
                        })
                        
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

    // MARK: - Table view data source
    
     func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return reporties.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportiesCellIdentifier", for: indexPath) as? ReportiesCell
        let reporter = reporties[indexPath.row]
        cell?.employeeNameLabel.text = reporter.firstName
        cell?.totalLeavesLabel.text = String(reporter.availableLeaves)
        
        return cell!
    }
    
     func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 44   
    }
    

}
