//
//  Badge.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 30/11/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import Foundation
class Badge{
    var title: String
    var detail: String
    var date: String
    var imagepath: String
    init(title:String,detail: String, date: String,imagepath:String){
        self.title = title
        self.detail = detail
        self.date = date
        self.imagepath = imagepath
    }
}
