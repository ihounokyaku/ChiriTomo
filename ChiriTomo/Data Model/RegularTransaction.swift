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
            
            let startDate = Date().addingTimeInterval(-30 * 24 * 60 * 60).dateInt(forAccountType:self.account.first!.type)
            print("start date \(startDate)")
            let transactionsWithSameName = self.account.first!.transactions.filter("name == %@", self.name)
            print("same name = \(transactionsWithSameName.count)")
            
            return self.account.first!.transactions.filter("(name == %@) AND (date >= %i)", self.name, startDate).count
            //return self.transactions.filter("date >= %i", startDate).count
        }
    }
    
    var category = LinkingObjects(fromType: Subcategory.self, property: "regularTransactions")
    var account = LinkingObjects(fromType: Account.self, property: "regularTransactions")
    
    let transactions = List<Transaction>()
}
