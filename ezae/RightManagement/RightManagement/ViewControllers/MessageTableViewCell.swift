//
//  MealTableViewCell.swift
//  RightManagement
//
//  Created by Munish Sethi on 10/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageDescription: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
