//
//  Account.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

enum AccountType:String {
    case daily
    case weekly
    case monthly
}

enum Currency:String{
    case THB = "฿"
    case JPY = "¥"
    case USD = "$"
}

class Account : Object {
    @objc dynamic var name = ""
    @objc dynamic var amount = 0
    @objc dynamic var startingAmount = 0
    @objc dynamic var surplus = 0
    
    
    @objc dynamic var accountType = AccountType.daily.rawValue
    var type: AccountType {
        get {
            return AccountType(rawValue:accountType)!
        }
        set {
            accountType = newValue.rawValue
        }
    }
    
    @objc dynamic var currencySymbol = "฿"
    var currency: Currency {
        get {
            return Currency(rawValue: currencySymbol)!
        }
        set {
            currencySymbol = newValue.rawValue
        }
    }
    
    let transactions = List<Transaction>()
    
    
}

