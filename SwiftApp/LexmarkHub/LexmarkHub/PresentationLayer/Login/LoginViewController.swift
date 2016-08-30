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
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginButton" {
            self.employee = Employee(id: 9552, name: "Rambabu Nayudu", role: "Employee", email: "rambabu.nayudu@kofax.com", totalLeaves: 25, availableLeaves: 10)
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
