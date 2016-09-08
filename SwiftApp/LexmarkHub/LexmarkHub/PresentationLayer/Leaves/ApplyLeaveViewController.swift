//
//  ApplyLeaveViewController.swift
//  LexmarkHub
//
//  Created by Durga on 26/08/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class ApplyLeaveViewController: UIViewController {
    
    @IBOutlet weak var tblApplyLeave: UITableView!
    
    var leavesArray = [AnyObject]()
    
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
    
    // MARK: - Button actions
    
    @IBAction func btnAddLeaveAction(sender: AnyObject) {
        
//        let employee=Employee(id: 1,name: "Srilatha",role: "Software Developer",email: "srilatha.karancheti@kofax.com",totalLeaves: 1,availableLeaves: 2);
//        
//        let strDate = "30/09/2016"
//        let endDate = "10/10/2016"
//        
////        let strDate = ""
////        let endDate = ""
//
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        
//        let leave=Leave(reason:"Comp off",employee: employee,startDate:dateFormatter.dateFromString( strDate )!,endDate: dateFormatter.dateFromString( endDate )!,leaveType:"Comp off")
//        
//        leavesArray.append(leave)
        
        tblApplyLeave.reloadData()
        
        
    }
    
}


//MARK: - UITableViewDataSource methods
extension ApplyLeaveViewController :UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (leavesArray.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ApplyLeaveCell"
        let  cell : ApplyLeaveCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
            as! ApplyLeaveCell
        
        let leave:Leave=leavesArray[indexPath.row] as! Leave
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let stringFromDate = dateFormatter.stringFromDate(leave.startDate!)
        
        if(stringFromDate.isEmpty){
            cell.startdateButton.hidden=false
        }else{
            cell.fromDate.text=stringFromDate
            cell.startdateButton.hidden=true
        }
        
        let stringEndDate = dateFormatter.stringFromDate(leave.endDate!)
        
        if(stringFromDate.isEmpty){
            cell.endDateButton.hidden=false
        }else{
            cell.toDate.text=stringEndDate
            cell.endDateButton.hidden=true
        }
        cell.leaveType.text=leave.leaveType
        
        return cell
    }
}


// MARK: - UITableViewDelegate methods
extension ApplyLeaveViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
}