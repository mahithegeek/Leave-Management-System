//
//  LoginViewController.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var employee: Employee!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func signInWithGoogle(sender: UIButton){
        let oAuthManager:OAuthManager = OAuthManager.init(withIssuer: NSURL(string: kIssuer)!, clientID: kClientID, redirecURI: NSURL(string: kRedirectURI)!, viewController: self)
        oAuthManager.authWithAutoCodeExchange { (token, error) in
            let parameters = [
                "tokenID": token!
            ]
            let loginService:LoginService = LoginService.init(withURLString: kLoginURL)
            loginService.fireService(withParams: parameters, completion: { (dictionary, error) in
                NSLog("Result is \(dictionary)")
                if(dictionary != nil){
                    self.employee = Employee.init(withDictionary: dictionary!)
                    self.performSegueWithIdentifier(kDashboardSegue, sender: sender)
                }
                
            })
        }

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kDashboardSegue {
            if let dashboardViewController = segue.destinationViewController as? DashboardViewController {
                if let employee = self.employee {
                    dashboardViewController.employee = employee
                }
            }
        }
    }

    @IBAction func logoutButtonAction(segue: UIStoryboardSegue){
        self.navigationController?.popViewControllerAnimated(true)
    }

}
