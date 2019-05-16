//
//  NotificationTableViewCell.swift
//  RightManagement
//
//  Created by Munish Sethi on 11/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationTitle: UILabel!
    
    @IBOutlet weak var notificationButton: UIButton!
    
    
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var bottomView: baseView!
    
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
