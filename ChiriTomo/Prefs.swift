//
//  Prefs.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation

class Prefs : NSObject {
  
    //MARK: - Variables
    
    // - managers
    var dataManager = DataManager()
    let prefs = UserDefaults.standard

    
    
    //MARK: - INIT
    override init () {
        super.init()
        print("initiating datamanager")
        
    }
    
    
    //MARK: - READ/WRITE
    func save() {
        
    }
    
}
