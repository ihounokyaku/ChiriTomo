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
    
    // - Other
    var account:Account!
    
    
    //MARK: - INIT
    override init () {
        super.init()
        
        if let accountName = prefs.value(forKey: "account") as? String, let acct = self.dataManager.getAccount(withName: accountName) {
            self.account = acct
        } else {
            self.account = self.dataManager.newAccount(name: "TestAccount", amount: 500, startingAmount: 0, accountType: .daily, currency: .THB)
            self.save()
        }
    }
    
    
    //MARK: - READ/WRITE
    func save() {
        self.prefs.set(self.account.name, forKey: "account")
    }
    
}
