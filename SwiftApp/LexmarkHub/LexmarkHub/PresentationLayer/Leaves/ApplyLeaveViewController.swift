//
//  ApplyLeaveViewController.swift
//  LexmarkHub
//
//  Created by Durga on 26/08/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class ApplyLeaveViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var tblApplyLeave: UITableView!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var addLeaveButton: UIBarButtonItem!

    var leavesArray = [AnyObject]()
    let leaveTypes = ["Vacation", "Comp-of", "Special", "carry-forward"]
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        
        
        //Adding empty leave,user has to fill dates
        self.addLeaveButton.enabled = false
        let leave=Leave(reason:"Vacation",employee:nil ,startDate:nil,endDate: nil,leaveType:"Vacation")
        leavesArray.append(leave)
        tblApplyLeave.reloadData()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ApplyLeaveViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ApplyLeaveViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func keyboardWillShow(notification:NSNotification) {
        
        if reasonTextView.isFirstResponder() {
            let userInfo:NSDictionary = notification.userInfo!
            let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.CGRectValue()
            let keyboardHeight = keyboardRectangle.height
            var viewRect:CGRect = self.view.frame
            viewRect.size.height = UIScreen.mainScreen().bounds.size.height - keyboardHeight
            self.view.frame = viewRect
        }
    }

    func keyboardWillHide(notification:NSNotification) {
        var viewRect:CGRect = self.view.frame
        viewRect.size.height = UIScreen.mainScreen().bounds.size.height
        self.view.frame = viewRect
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.inputView = pickerView
    }
    
    // MARK: - Button actions
    
    @IBAction func btnAddLeaveAction(sender: AnyObject) {
        
        self.addLeaveButton.enabled = false
        
        let leave=Leave(reason:"Vacation",employee:nil ,startDate:nil,endDate: nil,leaveType:"Vacation")
        
        leavesArray.append(leave)
        tblApplyLeave.reloadData()
        
        
    }
    
    @IBAction func startDateButtonAction(sender: AnyObject) {
    
        
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (date) -> Void in
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" //format style. you can change according to yours
            let dateString = dateFormatter.stringFromDate(date)
            print(dateString)
            
            let leave = self.leavesArray.first as? Leave
            leave!.startDate = date
            
            self.tblApplyLeave.reloadData()

        }
    }
    
    @IBAction func endDateButtonAction(sender: AnyObject) {
        print("I am in end");
        
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (date) -> Void in
            
            let leave = self.leavesArray.first as? Leave
            leave!.endDate = date
            
            self.tblApplyLeave.reloadData()
            
        }
    }
    
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        if leavesArray.count == 0 {
            Popups.SharedInstance.ShowPopup(kAppTitle, message: "Please Select start and end dates by tapping on '+' symbol")
            return
        }
        
        let leave = leavesArray.first as! Leave
        
        if leave.startDate == nil || leave.endDate == nil {
            Popups.SharedInstance.ShowPopup(kAppTitle, message: "Please Select start/end date.")
            return
        }
        
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!,
                    "leave": [
                        "fromDate": self.dateStringFromDate(leave.startDate!),
                        "toDate" : self.dateStringFromDate(leave.endDate!),
                        "isHalfDay" : true,
                        "type" : "Vacation"
                        ]
                ]
                
                print(parameters)
                LMSServiceFactory.sharedInstance().applyLeave(withURL: kApplyLeaveURL, withParams: parameters as! [String : AnyObject], completion: { (responseDict, error) in
                    
                    print(responseDict)
                    Loader.hide();
                    
                    if responseDict != nil {
                        Popups.SharedInstance.ShowAlert(self, title: kAppTitle, message: "Applied leave successfully.", buttons: ["OK"], completion: { (buttonPressed) in
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    } else {
                        Popups.SharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
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
    
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return leaveTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return leaveTypes[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("selected")
        //genderTextField.text = "\(gender[row])"
        
        
        let leave = self.leavesArray.first as? Leave
        leave!.leaveType = leaveTypes[row]
        self.tblApplyLeave.reloadData()
        
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
        
       
        var stringFromDate = ""
        if let startDate = leave.startDate {
            stringFromDate = dateStringFromDate(startDate)
        }
        
        if(stringFromDate.isEmpty){
            cell.startdateButton.hidden=false
        }else{
            cell.startdateButton.setImage(nil, forState: .Normal)
            cell.startdateButton.setTitle(stringFromDate, forState: .Normal)
        }
        
        var stringEndDate = ""
        if let endDate = leave.endDate {
            stringEndDate = dateStringFromDate(endDate)
        }        
        if(stringEndDate.isEmpty){
            cell.endDateButton.hidden=false
        }else{
            cell.endDateButton.setImage(nil, forState: .Normal)
            cell.endDateButton.setTitle(stringEndDate, forState: .Normal)
        }
        cell.leaveType.text=leave.leaveType
        
        return cell
    }
    
    func dateStringFromDate(date:NSDate) -> String {
    
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. you can change according to yours
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
}


// MARK: - UITableViewDelegate methods
extension ApplyLeaveViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
}