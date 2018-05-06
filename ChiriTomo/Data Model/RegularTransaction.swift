//
//  File.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class RegularTransaction : Object {
    
    @objc dynamic var name = ""
    @objc dynamic var amount = 0
    @objc dynamic var numberOfTransactions = 0
    
    @objc dynamic var numberOfRecentTransactions:Int {
        get {
            //TODO: Adjust for other types
            print("going to get recent")
            let startDate = Date().addingTimeInterval(-30 * 60 * 60).dateInt()
            return self.account.first!.transactions.filter("(name == %@) AND (date >= %i)", self.name, startDate).count
            //return self.transactions.filter("date >= %i", startDate).count
        }
    }
    
    var category = LinkingObjects(fromType: Subcategory.self, property: "regularTransactions")
    var account = LinkingObjects(fromType: Account.self, property: "regularTransactions")
    
    let transactions = List<Transaction>()
}
