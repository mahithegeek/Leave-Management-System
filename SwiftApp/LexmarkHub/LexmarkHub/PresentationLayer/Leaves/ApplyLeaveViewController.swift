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
    var leave=Leave(reason:"Vacation",employee:nil ,startDate:Date(),endDate: Date(),isHalfDay: false,leaveType:"")
    var isFromPending:Bool = false
    var employee: Employee?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        
        startDateWidthConstraint.constant = (UIScreen.main.bounds.size.width - 2 * padding - gapBetweenDates) / 2
        self.startDateLabel.text = AppUtilities().dateStringFromDate(leave.startDate!)
        self.endDateLabel.text = AppUtilities().dateStringFromDate(leave.endDate!)
        NotificationCenter.default.addObserver(self, selector: #selector(ApplyLeaveViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ApplyLeaveViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if isFromPending == true {
            applyButtonWidthConstraint.constant = (UIScreen.main.bounds.size.width - 2 * padding - gapBetweenDates) / 2
            self.reportToLabel.text = "From: " + (leave.employee?.name)!
            self.titleLabel.text = "Pending Request"
            reasonTextView.text = leave.reason
            self.leaveTypeLabel.text = "Reason: " + leave.leaveType!
            approveButton.isHidden = false
            rejectButton.isHidden = false
            startDateButton.isUserInteractionEnabled = false
            endDateButton.isUserInteractionEnabled = false
            reasonTextView.isEditable = false
            submitButton.isHidden = true
            leaveTypeButton.isUserInteractionEnabled = false
            self.halfDayLeaveButton.isSelected = leave.isHalfDay!
            self.halfDayLeaveButton.isUserInteractionEnabled = false
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
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        if reasonTextView.isFirstResponder {
            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            var viewRect:CGRect = self.view.frame
            viewRect.origin.y =  -keyboardHeight
            self.view.frame = viewRect
            print(viewRect)

        }
    }

    func keyboardWillHide(_ notification:Notification) {
        var viewRect:CGRect = self.view.frame
        viewRect.origin.y = 0
        self.view.frame = viewRect
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputView = pickerView
    }
    
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func leaveTypesButtonAction(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: kAppTitle, message: "Please select leave type.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        for leaveType in leaveTypes {
            
            let OKAction = UIAlertAction(title: leaveType, style: .default) { (action) in
                print(action.title!)
                self.leaveTypeLabel.text = "Reason: " + action.title!
                self.leave.leaveType = action.title!
            }
            alertController.addAction(OKAction)
        }
        
        
        
        self.present(alertController, animated: true) {
        }

    }
    
    @IBAction func startDateButtonAction(_ sender: AnyObject) {
    
        
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date, minDate:Date(), maxDate:nil) {
            (date) -> Void in
            self.leave.startDate = date
            self.startDateLabel.text = AppUtilities().dateStringFromDate(date)
            if (self.halfDayLeaveButton.isSelected) {
                self.leave.endDate! = self.leave.startDate!
                self.endDateLabel.text = AppUtilities().dateStringFromDate(self.leave.endDate!)
            }
        }
    }
    
    @IBAction func endDateButtonAction(_ sender: AnyObject) {
        
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date, minDate:Date(), maxDate:nil) {
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
        if compareDate(Date(), toDate: leave.startDate!) == .orderedDescending || compareDate(Date(), toDate: leave.endDate!) == .orderedDescending {
            return(false, "Please select valid dates")
        }
        if compareDate(leave.startDate!, toDate: leave.endDate!) == .orderedDescending  {
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
    
    func daysBetweenDates(_ startDate: Date, endDate: Date) -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day], from: startDate, to: endDate, options: [])
        return components.day!
    }
    
    func numberOfWeekendsBeetweenDates(startDate:Date,endDate:Date)->Int{
        var count = 0
        var oneDay = DateComponents()
        oneDay.day = 1;
        // Using a Gregorian calendar.
        let calendar = Calendar.current
        var currentDate = startDate;
        // Iterate from fromDate until toDate
        while (currentDate.compare(endDate) != .orderedDescending) {
            let dateComponents = (calendar as NSCalendar).components(.weekday, from: currentDate)
            if (dateComponents.weekday == 1 || dateComponents.weekday == 7 ) {
                count += 1;
            }
            // "Increment" currentDate by one day.
            currentDate = (calendar as NSCalendar).date(byAdding: oneDay, to: currentDate, options: [])!
        }
        return count
    }

    @IBAction func halfDayButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            endDateButton.isUserInteractionEnabled = false
            if compareDate(leave.startDate!, toDate: leave.endDate!) != .orderedSame {
                leave.endDate! = leave.startDate!
                self.endDateLabel.text = AppUtilities().dateStringFromDate(leave.endDate!)
            }
        }
        else {
            endDateButton.isUserInteractionEnabled = true
        }
        
        
        
    }
    @IBAction func submitButtonAction(_ sender: AnyObject) {
        
        
        let validationResult:(Bool, String) = checkValidation()
        
        if validationResult.0 == false {
            Popups.sharedInstance.ShowPopup(kAppTitle, message: validationResult.1)
            return
        }

        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                
                let ishalfDay = self.halfDayLeaveButton.isSelected
                let parameters = [
                    "tokenID": idToken!,
                    "leave": [
                        "fromDate": AppUtilities().dateStringFromDate(self.leave.startDate!),
                        "toDate" : AppUtilities().dateStringFromDate(self.leave.endDate!),
                        "isHalfDay" : ishalfDay,
                        "leaveType" : self.leave.leaveType!.lowercased(),
                        "reason" : (self.reasonTextView.text as NSString).replacingOccurrences(of: "Notes :", with: "")
                        ]
                ] as [String : Any]
                //Notes :
                print(parameters)
                LMSServiceFactory.sharedInstance().applyLeave(withURL: kApplyLeaveURL, withParams: parameters as [String : AnyObject], completion: { (responseDict, error) in
                    
                    print("response: \(responseDict)" )
                    Loader.hide()
                    
                    if responseDict != nil {
                        Popups.sharedInstance.ShowAlert(self, title: kAppTitle, message: "Applied leave successfully.", buttons: ["OK"], completion: { (buttonPressed) in
                            LMSThreading.dispatchOnMain(withBlock: { (Void) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        })
                    } else {
                        Popups.sharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
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
    
    @IBAction func approveLeaveButtonAction(_ sender: AnyObject) {
        approveLeave(true)
    }
    
    @IBAction func rejectLeaveButtonAction(_ sender: AnyObject) {
        approveLeave(false)
    }
    
    
    func approveLeave(_ approve:Bool) -> Void {
        
        Loader.show("Loading", disableUI: true)
        appDelegate.oAuthManager?.requestAccessToken(withCompletion: { (idToken, error) in
            
            if idToken?.isEmpty == false {
                let parameters = [
                    "tokenID": idToken!,
                    "requestID": self.leaveRequest!.requestId,
                    "leaveStatus":(approve ? "Approve":"Reject")
                ] as [String : Any]
                
                print(parameters)
                LMSServiceFactory.sharedInstance().approveLeave(withURL: kApproveLeaveURL, withParams: parameters as [String : AnyObject], completion: { (responseDict, error) in
                    
                    
                    Loader.hide();
                    if responseDict != nil {
                        print(responseDict)
                        Popups.sharedInstance.ShowAlert(self, title: kAppTitle, message: responseDict!["success"] as! String, buttons: ["OK"], completion: { (buttonPressed) in
                            LMSThreading.dispatchOnMain(withBlock: { (Void) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        })
                    } else {
                        Popups.sharedInstance.ShowPopup(kAppTitle, message: (error?.localizedDescription)!)
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

    func compareDate(_ fromDate:Date, toDate:Date) -> ComparisonResult{
        
        let order = (Calendar.current as NSCalendar).compare(fromDate, to: toDate,
                                                         toUnitGranularity: .day)
        return order
    }
    
}


