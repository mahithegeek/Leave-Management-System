//
//  ApplyLeaveCellTableViewCell.swift
//  LexmarkHub
//
//  Created by Durga on 26/08/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class ApplyLeaveCell: UITableViewCell {
    
    @IBOutlet weak var leaveType: UITextField!
    @IBOutlet weak var startdateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
