//
//  Extensions.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import UIKit

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
        
        if let end = daysEnd, [components[3], components[4]].merge() < end {
           components = self.addingTimeInterval(Double(-60 * 60 * 12)).components()
        }
        
       return [components[0], components[1], components[2]].merge()
    }
}

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
