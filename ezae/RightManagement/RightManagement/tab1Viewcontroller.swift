//
//  tab1Viewcontroller.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 09/05/19.
//  Copyright © 2019 Munish Sethi. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class tab1Viewcontroller: UIViewController,IndicatorInfoProvider{
    var itemInfo:IndicatorInfo = "Tab1"
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo;
    }
}
