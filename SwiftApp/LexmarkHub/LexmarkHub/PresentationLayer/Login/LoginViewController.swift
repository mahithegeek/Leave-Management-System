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

    @IBAction func signInWithGoogle(_ sender: UIButton){
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

       appDelegate.oAuthManager  = OAuthManager.init(withIssuer: URL(string: kIssuer)!, clientID: kClientID, redirecURI: URL(string: kRedirectURI)!, viewController: self)
        appDelegate.oAuthManager!.authWithAutoCodeExchange { (token, error) in
            if((token == nil)){
                Popups.sharedInstance.ShowPopup(kAppTitle, message: "Problem occured while authenticating. Please try again.")
                return
            }
            
            let parameters = [
                "tokenID": token!
            ]
            Loader.show("Loading", disableUI: true)
            let loginService:LoginService = LoginService.init(withURLString: kLoginURL)
            loginService.fireService(withParams: parameters, completion: { (dictionary, error) in
                NSLog("Result is \(dictionary)")
                Loader.hide()
                if(dictionary != nil){
                    self.employee = Employee.init(withDictionary: dictionary!)
                    self.performSegue(withIdentifier: kDashboardSegue, sender: sender)
                } else {
                    Popups.sharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kDashboardSegue {
            if let dashboardViewController = segue.destination as? DashboardViewController {
                if let employee = self.employee {
                    dashboardViewController.employee = employee
                }
            }
        }
    }

    @IBAction func logoutButtonAction(_ segue: UIStoryboardSegue){
        self.navigationController?.popViewController(animated: true)
    }
}
