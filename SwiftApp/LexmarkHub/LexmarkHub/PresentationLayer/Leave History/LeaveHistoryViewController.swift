//
//  LeaveHistoryViewController.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class LeaveHistoryViewController: UITableViewController {

    var leaveHistory: [LeaveRequest]?

    @IBAction func leaveHistoryBack (_ segue: UIStoryboardSegue){
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

//        let employee = Employee(id: 9552, name: "Rambabu Nayudu", role: "Employee", email: "rambabu.nayudu@kofax.com", totalLeaves: 25, availableLeaves: 10)
//
//        let leave = Leave(reason: "Marriage vacation", employee: employee, startDate: NSDate(), endDate: NSDate(),leaveType: "")
//        let leaveRequest = LeaveRequest(requestId: 1, status: "Pending", leave: leave)
//        leaveHistory = Array()
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
//        leaveHistory?.append(leaveRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaveHistory", for: indexPath) as? LeaveHistoryCell

        // Configure the cell...

        let leaveRequest = leaveHistory![indexPath.row] as LeaveRequest

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        cell?.nameLabel.text = dateFormatter.string(from: leaveRequest.leave.startDate! as Date)
        cell?.reasonLabel.text = "Reason: \(leaveRequest.leave.reason)"
        cell?.statusLabel.text = leaveRequest.status
        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
