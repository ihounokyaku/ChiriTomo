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
    @objc dynamic var lastPrice = 0
    @objc dynamic var numberOfTransactions = 0
    
    var category = LinkingObjects(fromType: Subcategory.self, property: "regularTransactions")

}
