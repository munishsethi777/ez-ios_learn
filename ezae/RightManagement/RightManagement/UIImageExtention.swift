//
//  UIImageExtention.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 15/02/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import Foundation
import UIKit
extension UIImage{
    static func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        // create a 1 by 1 pixel context
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
}
