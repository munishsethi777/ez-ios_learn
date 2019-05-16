//
//  MessageFormat.swift
//  right
//
//  Created by Baljeet Gaheer on 14/11/17.
//  Copyright © 2017 Baljeet Gaheer. All rights reserved.
//

import Foundation

class MessageFormat{
    static func format(pattern: String,args: [String])->String{
        var url: String = pattern
        var count: Int = 0
        for arg in args{
            url = url.replacingOccurrences(of: "{"+String(count)+"}", with: arg)
            count+=1
        }
        return url
    }
    static func format(pattern: String,args: [Int])->String{
        var url: String = pattern
        var count: Int = 0
        for arg in args{
            url = url.replacingOccurrences(of: "{"+String(count)+"}", with: String(arg))
            count+=1
        }
        return url
    }
    static func format(pattern: String,args: [Any])->String{
        var url: String = pattern
        var count: Int = 0
        for arg in args{
            url = url.replacingOccurrences(of: "{"+String(count)+"}", with: String(describing: arg))
            count+=1
        }
        return url
    }
    
    
    static func indexOf(string:String,substring:String)->Int{
        var index = 0
        for char in string.characters {
            if substring.characters.first == char {
                // Create a start and end index to ultimately creata range
                //
                // Hello Agnosticdev, I love Tutorials
                //       6   ->   17 - rage of substring from 7 to 18
                //
                let startOfFoundCharacter = string.index(string.startIndex, offsetBy: index)
                let lengthOfFoundCharacter = string.index(string.startIndex, offsetBy: (substring.characters.count + index))
                let range = startOfFoundCharacter..<lengthOfFoundCharacter
                
                // Grab the substring from the parent string and compare it against substring
                // Essentially, looking for the needle in a haystack
                if string.substring(with: range) == substring {
                    break
                }
            }
            index += 1
        }
        return index;
    }
}
