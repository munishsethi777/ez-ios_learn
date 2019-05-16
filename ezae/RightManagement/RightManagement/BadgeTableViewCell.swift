//
//  BadgeTableViewCell.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 30/11/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class BadgeTableViewCell: UITableViewCell {

    @IBOutlet weak var badgeDetailImage: UILabel!
    @IBOutlet weak var badgeTitleLabel: UILabel!
    @IBOutlet weak var badgeDateLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.badgeTitleLabel.numberOfLines=0
        self.badgeTitleLabel.sizeToFit()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
