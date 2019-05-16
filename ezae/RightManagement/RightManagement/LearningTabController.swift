//
//  LearningTabController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 20/07/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import XLPagerTabStrip

class LearningTabController: ButtonBarPagerTabStripViewController{
    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
    var isReload = false
    var selectedModuleSeq: Int = 0
    var selectedLpSeq: Int = 0
    var isLaunch = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // change segmented style
        //settings.style.segmentedControlColor = .black
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = blueInstagramColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.blueInstagramColor
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLaunch {
            self.moveToViewController(at: 1,animated: false)
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
         //let child_1 = ChildExampleViewController(itemInfo: "View")
        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LearningPlans")
        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModulesList") as! ModuleViewController
        if isLaunch {
            child_2.isLaunch = isLaunch
            child_2.selectedLpSeq = selectedLpSeq
            child_2.selectedModuleSeq = selectedModuleSeq
        }
        return [child_1, child_2]
    }
    
}

