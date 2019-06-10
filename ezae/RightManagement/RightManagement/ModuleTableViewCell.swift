//
//  ModuleTableViewCell.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 06/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class ModuleTableViewCell : UITableViewCell{
    @IBOutlet weak var lauchModuleButton: PassableUIButton!
  
    @IBOutlet weak var baseView: bottomView!
    @IBOutlet weak var pointsCaptionLabel: UILabel!
    @IBOutlet weak var scoreCaptionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var leaderboardLabel: UILabel!
   
    @IBOutlet weak var moduleImageView: UIImageView!
    
    @IBOutlet weak var launchModuleImageButton: PassableUIButton!
    

    @IBOutlet weak var moduleDesLabel: UILabel!
    @IBOutlet weak var moduleTitleLabel: UILabel!
}


