//
//  DateUtil.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 29/11/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import Foundation

class DateUtil{
    static let sharedInstance = DateUtil()
    static let format = "MMM d, yyyy HH:mm a"
    static let format1 = "yyyy-MM-dd HH:mm:ss"
    static let format2 = "dd/MM/yyyy"
    static let time_format = "HH:mm"
    func stringToDate(dateStr: String)-> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.init(identifier: "IST")
        let date = dateFormatter.date(from: dateStr)
        return date!;
    }
    
    func dateToString(date: Date,format: String)-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let myStringafd = dateFormatter.string(from: date)
        return myStringafd;
    }
    
    func getDatesDiff(start:Date,end:Date)->[Date]{
        var dates:[Date] = []
        let startDate = start
        let endDate = end
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        let numberOfDays = components.day ?? 0
        if(numberOfDays > 0){
            for i in 1...numberOfDays {
                let nextDate = Calendar.current.date(byAdding: .day, value: i, to: startDate)
                dates.append(nextDate!)
            }
        }
        return dates
    }
}
