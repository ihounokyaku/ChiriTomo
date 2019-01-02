//
//  Transaction.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class Transaction : Object {
    
    @objc dynamic var date = 19810910
    @objc dynamic var amount = 0
    @objc dynamic var name = "transaction"
    @objc dynamic var note = ""
    @objc dynamic var fullDate = "2018-05-19 23:10"
    
    var account = LinkingObjects(fromType: Account.self, property: "transactions")
    var category = LinkingObjects(fromType: Subcategory.self, property: "transactions")
}
