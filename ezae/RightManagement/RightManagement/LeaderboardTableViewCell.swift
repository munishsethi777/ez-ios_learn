//
//  LeaderboardTableViewCell.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 16/05/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
class LeaderboardTableViewCell : UITableViewCell {
    
 
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
