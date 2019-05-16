//
//  MyScoreTableViewCell.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 24/07/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//
import UIKit
class MyScoreTableViewCell : UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBOutlet weak var scoreLabelView: UILabel!
    @IBOutlet weak var moduleNameLableView: UILabel!
    @IBOutlet weak var moduleImageView: UIImageView!
}
