//
//  Users.swift
//  LexmarkHub
//
//  Created by Kofax on 23/09/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class ReportiesCell: UITableViewCell {
    
    @IBOutlet weak var employeeNameLabel: UILabel!
    @IBOutlet weak var totalLeavesLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
