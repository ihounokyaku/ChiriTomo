//
//  File.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class Subcategory : Category {
    
    let transactions = List<Transaction>()
    let regularTransactions = List<RegularTransaction>()
    var parentCategory = LinkingObjects(fromType: MainCategory.self, property: "subcategories")
}
