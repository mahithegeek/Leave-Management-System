//
//  DashboardViewController.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet weak var availableLeavesLabel: UILabel!

    var employee: Employee?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        self.availableLeavesLabel.text = "\(employee!.availableLeaves)"
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

    @IBAction func backButtonAction(segue: UIStoryboardSegue){
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func cancelButtonAction(segue: UIStoryboardSegue){
        self.navigationController?.popViewControllerAnimated(true)
    }

}
