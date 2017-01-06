//
//  ApplyLeaveViewController.swift
//  LexmarkHub
//
//  Created by Durga on 26/08/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

let kMaxLeaves = 7

let padding:CGFloat = 20.0
let gapBetweenDates:CGFloat = 15.0

class ApplyLeaveViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var startDateWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var applyButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var reportToLabel: UILabel!
    @IBOutlet weak var leaveTypeLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leaveTypeButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var halfDayLeaveButton: UIButton!
    let leaveTypes = ["Vacation", "Comp-off", "Bereavement", "Business Trip","Forgot Id","Loss Of Pay","Maternity","Paternity","Work From Home"]
    var pickerView = UIPickerView()
    var leaveRequest:LeaveRequest?
    var leave=Leave(reason:"Vacation",employee:nil ,startDate:NSDate(),endDate: NSDate(),isHalfDay: false,leaveType:"")
    var isFromPending:Bool = false
    var employee: Employee?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        
        startDateWidthConstraint.constant = (UIScreen.mainScreen().bounds.size.width - 2 * padding - gapBetweenDates) / 2
        self.startDateLabel.text = AppUtilities().dateStringFromDate(leave.startDate!)
        self.endDateLabel.text = AppUtilities().dateStringFromDate(leave.endDate!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ApplyLeaveViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ApplyLeaveViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if isFromPending == true {
            applyButtonWidthConstraint.constant = (UIScreen.mainScreen().bounds.size.width - 2 * padding - gapBetweenDates) / 2
            self.reportToLabel.text = "From: " + (leave.employee?.name)!
            self.titleLabel.text = "Pending Request"
            reasonTextView.text = leave.reason
            self.leaveTypeLabel.text = "Reason: " + leave.leaveType!
            approveButton.hidden = false
            rejectButton.hidden = false
            startDateButton.userInteractionEnabled = false
            endDateButton.userInteractionEnabled = false
            reasonTextView.editable = false
            submitButton.hidden = true
            leaveTypeButton.userInteractionEnabled = false
            self.halfDayLeaveButton.selected = leave.isHalfDay!
            self.halfDayLeaveButton.userInteractionEnabled = false
        }
        else if let supervisorName = self.employee!.supervisorName {
            self.reportToLabel.text = "To: " + supervisorName
        }
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
            viewRect.origin.y =  -keyboardHeight
            self.view.frame = viewRect
            print(viewRect)

        }
    }

    func keyboardWillHide(notification:NSNotification) {
        var viewRect:CGRect = self.view.frame
        viewRect.origin.y = 0
        self.view.frame = viewRect
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.inputView = pickerView
    }
    
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func leaveTypesButtonAction(sender: AnyObject) {
        
        let alertController = UIAlertController(title: kAppTitle, message: "Please select leave type.", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        for leaveType in leaveTypes {
            
            let OKAction = UIAlertAction(title: leaveType, style: .Default) { (action) in
                print(action.title!)
                self.leaveTypeLabel.text = "Reason: " + action.title!
                self.leave.leaveType = action.title!
            }
            alertController.addAction(OKAction)
        }
        
        
        
        self.presentViewController(alertController, animated: true) {
        }

    }
    
    @IBAction func startDateButtonAction(sender: AnyObject) {
    
        
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date, minDate:NSDate(), maxDate:nil) {
            (date) -> Void in
            self.leave.startDate = date
            self.startDateLabel.text = AppUtilities().dateStringFromDate(date)
            if (self.halfDayLeaveButton.selected) {
                self.leave.endDate! = self.leave.startDate!
                self.endDateLabel.text = AppUtilities().dateStringFromDate(self.leave.endDate!)
            }
        }
    }
    
    @IBAction func endDateButtonAction(sender: AnyObject) {
        
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date, minDate:NSDate(), maxDate:nil) {
            (date) -> Void in
            self.leave.endDate = date
            self.endDateLabel.text = AppUtilities().dateStringFromDate(date)
        }
    }
    
    func checkValidation() ->(Bool,String)
    {
        
        if leave.startDate == nil || leave.endDate == nil {
            return(false, "Please Select start/end date.")
        }
        if compareDate(NSDate(), toDate: leave.startDate!) == .OrderedDescending || compareDate(NSDate(), toDate: leave.endDate!) == .OrderedDescending {
            return(false, "Please select valid dates")
        }
        if compareDate(leave.startDate!, toDate: leave.endDate!) == .OrderedDescending  {
            return(false, "Start date should be greater than(equal to)  end date")
        }
        if daysBetweenDates(leave.startDate!, endDate: leave.endDate!) > kMaxLeaves - 1 {
            return(false, "You can only apply \(kMaxLeaves) days continuously")
        }
        
        else if (self.leave.leaveType!.characters.count <= 0) {
            return(false, "Please select reason for leave.")
        }
        print(numberOfWeekendsBeetweenDates(startDate:leave.startDate!, endDate: leave.endDate!))

        return(true, "Success")
    }
    
    func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        return components.day
    }
    
    func numberOfWeekendsBeetweenDates(startDate startDate:NSDate,endDate:NSDate)->Int{
        var count = 0
        let oneDay = NSDateComponents()
        oneDay.day = 1;
        // Using a Gregorian calendar.
        let calendar = NSCalendar.currentCalendar()
        var currentDate = startDate;
        // Iterate from fromDate until toDate
        while (currentDate.compare(endDate) != .OrderedDescending) {
            let dateComponents = calendar.components(.Weekday, fromDate: currentDate)
            if (dateComponents.weekday == 1 || dateComponents.weekday == 7 ) {
                count += 1;
            }
            // "Increment" currentDate by one day.
            currentDate = calendar.dateByAddingComponents(oneDay, toDate: currentDate, options: [])!
        }
        return count
    }

    @IBAction func halfDayButtonAction(sender: UIButton) {
        sender.selected = !sender.selected
        if sender.selected {
            endDateButton.userInteractionEnabled = false
            if compareDate(leave.startDate!, toDate: leave.endDate!) != .OrderedSame {
                leave.endDate! = leave.startDate!
                self.endDateLabel.text = AppUtilities().dateStringFromDate(leave.endDate!)
            }
        }
        else {
            endDateButton.userInteractionEnabled = true
        }
        
        
        
    }
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        
        let validationResult:(Bool, String) = checkValidation()
        
        if validationResult.0 == false {
            Popups.SharedInstance.ShowPopup(kAppTitle, message: validationResult.1)
            return
        }

        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                
                let ishalfDay = self.halfDayLeaveButton.selected
                let parameters = [
                    "tokenID": idToken!,
                    "leave": [
                        "fromDate": AppUtilities().dateStringFromDate(self.leave.startDate!),
                        "toDate" : AppUtilities().dateStringFromDate(self.leave.endDate!),
                        "isHalfDay" : ishalfDay,
                        "leaveType" : self.leave.leaveType!.lowercaseString,
                        "reason" : (self.reasonTextView.text as NSString).stringByReplacingOccurrencesOfString("Notes :", withString: "")
                        ]
                ]
                //Notes :
                print(parameters)
                LMSServiceFactory.sharedInstance().applyLeave(withURL: kApplyLeaveURL, withParams: parameters as! [String : AnyObject], completion: { (responseDict, error) in
                    
                    print(responseDict)
                    Loader.hide();
                    
                    if responseDict != nil {
                        Popups.SharedInstance.ShowAlert(self, title: kAppTitle, message: "Applied leave successfully.", buttons: ["OK"], completion: { (buttonPressed) in
                            LMSThreading.dispatchOnMain(withBlock: { (Void) in
                                self.navigationController?.popViewControllerAnimated(true)
                            })
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
    
    @IBAction func approveLeaveButtonAction(sender: AnyObject) {
        approveLeave(true)
    }
    
    @IBAction func rejectLeaveButtonAction(sender: AnyObject) {
        approveLeave(false)
    }
    
    
    func approveLeave(approve:Bool) -> Void {
        
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!,
                    "requestID": self.leaveRequest!.requestId,
                    "leaveStatus":(approve ? "Approve":"Reject")
                ]
                
                print(parameters)
                LMSServiceFactory.sharedInstance().approveLeave(withURL: kApproveLeaveURL, withParams: parameters, completion: { (responseDict, error) in
                    
                    
                    Loader.hide();
                    if responseDict != nil {
                        print(responseDict)
                        Popups.SharedInstance.ShowAlert(self, title: kAppTitle, message: responseDict!["success"] as! String, buttons: ["OK"], completion: { (buttonPressed) in
                            LMSThreading.dispatchOnMain(withBlock: { (Void) in
                                self.navigationController?.popViewControllerAnimated(true)
                            })
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

    func compareDate(fromDate:NSDate, toDate:NSDate) -> NSComparisonResult{
        
        let order = NSCalendar.currentCalendar().compareDate(fromDate, toDate: toDate,
                                                         toUnitGranularity: .Day)
        return order
    }
    
}


