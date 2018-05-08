//
//  Global Variables.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/05/08.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation

let AccountTypes:[AccountType] = [.daily, .weekly, .monthly]
let Currencies:[String:Currency] = ["JPY":.JPY, "USD":.USD, "THB":.THB]
var CurrencyKeys:[String] {
    get {
        var currencies = [String]()
        for (key, _) in Currencies {
            currencies.append(key)
        }
        return currencies.sorted()
    }
}

