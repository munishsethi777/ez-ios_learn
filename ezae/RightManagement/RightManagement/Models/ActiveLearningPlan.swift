//
//  ActiveLearningPlan.swift
//  RightManagement
//
//  Created by Munish Sethi on 11/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import Foundation
class ActiveLearningPlan{
    var learningPlanSeq:Int
    var learningPlanName:String
    var percentageCompleted:Int
    
    init(learningPlanSeq:Int,learningPlanName:String,percentageCompleted:Int){
        self.learningPlanSeq = learningPlanSeq
        self.learningPlanName = learningPlanName
        self.percentageCompleted = percentageCompleted
    }
}
