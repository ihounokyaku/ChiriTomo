//
//  Extensions.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import UIKit


//MARK: - =============UICOLOR=====================
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

//MARK: - =============DATE=====================
extension Date {
    func components()-> [Int] {
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return [year, month, day, hour, minute]
    }
    
    func dateInt(adjustedBy daysEnd:Int? = nil)-> Int {
        var components = self.components()
        
        if let end = daysEnd {
           components = self.adjusted(by: end).components()
        }
        
       return [components[0], components[1], components[2]].merge()
    }
    
    func adjusted(by daysEnd:Int)-> Date {
        var components = self.components()
        var date = self
        if [components[3], components[4]].merge() < daysEnd {
            date = self.addingTimeInterval(Double(-60 * 60 * 12))
        }
        
        return date
    }
}


//MARK: - =============ARRAY====================
extension Array where Element == Int{
    func merge()-> Int {
        var fullString = ""
        
        for int in self {
            var intString = String(int)
            if int < 10 {
                intString = String(format:"%02d", int)
            }
            fullString += intString
        }
        return Int(fullString)!
    }
}


//MARK: - =============STRING===================

extension String {
    func subString(from startIndex:Int, to endIndex:Int)-> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: endIndex)
        let range = start...end
        
        let mySubstring = self[range]
        return String(mySubstring)
    }
    func date(format:String = "yyyy-MM-dd")-> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from:self)
    }
}

//MARK: - =============INT===================
extension Int {
    func toDateString()-> String {
        let str = String(self)
        var dateString = ""
        if self > 2000 {
            dateString += str.subString(from: 0, to: 3)
        }
        if self > 200000 {
            dateString += "-" + str.subString(from: 4, to: 5)
        }
        if self > 20000100 {
             dateString += "-" + str.subString(from: 6, to: 7)
        }
        return dateString
    }
    
    func toDate()-> Date {
        var dateString = self.toDateString()
        
        
        if dateString.count == 7 {
            dateString += "-01"
        } else if dateString.count == 4 {
            dateString += "-01"
        }
        
        return dateString.date() ?? Date()
    }
}
