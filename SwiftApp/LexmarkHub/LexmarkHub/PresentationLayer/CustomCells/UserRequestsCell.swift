//
//  UserRequestsCell.swift
//  LexmarkHub
//
//  Created by Kofax on 13/10/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

@objc protocol UserRequestsCellDelegate {
    func didSelectUserRequestWithId(requestId:NSNumber);
}

class UserRequestsCell: UITableViewCell {
   
    @IBOutlet weak var leaveDatesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cancelWidthConstraint: NSLayoutConstraint!
    var reqId : NSNumber!
    weak var delegate : UserRequestsCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func cancelButtonAction(sender: AnyObject){
        delegate?.didSelectUserRequestWithId(reqId)
    }
    
}
