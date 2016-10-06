//
//  DashboardViewController.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

let EID_KEY:String = "emp_id"
let AVAILABLE_LEAVES_KEY:String = "available"
let COMPOFF_LEAVES_KEY:String = "comp-off"
let SPECIAL_LEAVES_KEY:String = "special"
let CARRYFORWARD_LEAVES_KEY:String = "carry_forward"

enum role: String {
    case manager
    case employee
}

class DashboardViewController: UIViewController {
    @IBOutlet weak var availableLeavesLabel: UILabel!

    var employee: Employee?

    @IBOutlet weak var reportiesButton: UIButton!
    @IBOutlet weak var pendingRequestsButton: UIButton!
    @IBOutlet weak var pendingRequestsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if employee?.role != role.manager.rawValue {
            self.pendingRequestsButton.hidden = true
            pendingRequestsLabel.hidden = true
        }
        self.fetchAvailableLeaves()
    }

    func fetchAvailableLeaves() {
        self.availableLeavesLabel.text = ""
        
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!
                ]
                LMSServiceFactory.sharedInstance().getAvilableLeaves(withURL: kAvailableLeavesURL, withParams: parameters, completion: { (availableLeaves, error) in
                    Loader.hide();
                    if availableLeaves != nil {
                        let availLeaves:Int? = availableLeaves?.objectForKey(AVAILABLE_LEAVES_KEY)?.integerValue
                        self.availableLeavesLabel.text = "\(availLeaves!)"
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logoutButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
   

}
