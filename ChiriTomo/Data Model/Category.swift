//
//  File.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var color = "#EDDEC0"
    @objc dynamic var icon = "noIcon.png"
    @objc dynamic var name = ""
}
