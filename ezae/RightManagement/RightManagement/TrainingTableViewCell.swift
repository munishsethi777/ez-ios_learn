//
//  File.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 04/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class TrainingTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    @IBOutlet weak var launchImageButton: UIButton!
    
    @IBOutlet weak var baseView: bottomView!
    
    @IBOutlet weak var pointsCaptionLabel: UILabel!
    @IBOutlet weak var scoreCaptionLabel: UILabel!
    @IBOutlet weak var leaderboardLabel: UILabel!
    @IBOutlet weak var launchModuleButton: UIButton!
   
   
    
    @IBOutlet weak var moduleImageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var moduleTitle: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
}
