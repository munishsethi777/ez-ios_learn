//
//  tab2Viewcontoller.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 09/05/19.
//  Copyright © 2019 Munish Sethi. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class tab2Viewcontroller: UIViewController,IndicatorInfoProvider{
    var itemInfo:IndicatorInfo = "Tab2"
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo;
    }
}
