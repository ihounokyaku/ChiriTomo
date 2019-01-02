//
//  Global Variables.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/05/08.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation

//MARK - ==ACCOUNT TYPES==
let AccountTypes:[AccountType] = [.daily, .weekly, .monthly]

//MARK: - ==CURRENCIES==
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

//MARK: - ==LANGUAGE==
enum Language:String {
    case ja = "日本語"
    case en = "English"
    case th = "ภาษาไทย"
}

let Languages:[String:Language] = ["English" : .en, "日本語" : .ja, "ภาษาไทย" : .th]

var LanguageKeys:[String] {
    get {
        var languages = [String]()
        for (key, _) in Languages {
            languages.append(key)
        }
        return languages.sorted()
    }
}

let LabelText:[String:[Language:String]] = ["Settings":[.en:"Settings",.ja:"設定", .th:"ตั้งค่า"],
                                            "Refresh":[.en:"Refresh",.ja:"更新", .th:"ตั้งค่า"],
                                            "Account":[.en:"Account",.ja:"講座", .th:"บัญชี"],
                                            "New Account":[.en:"New Account",.ja:"新規口座", .th:"บัญชีใหม่"]]


