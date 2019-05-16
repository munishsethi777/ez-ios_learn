//
//  Notes.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 24/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class Notes {
    var seq:Int
    var title:String
    var dateTime:String

    init(seq:Int,title:String,dateTime:String){
        self.seq = seq
        self.title = title
        self.dateTime = dateTime
    }
}
