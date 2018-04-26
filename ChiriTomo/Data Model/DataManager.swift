//
//  DataManager.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager:NSObject {
    
    let realm = try! Realm()
    
    
    
    //MARK: - READWRITE
    func save(object:Object) {
        do {
            try self.realm.write {
                realm.add(object)
            }
        } catch {
            print("Error saving object \(error)")
        }
    }
    
    func deleteObject(object:Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("error deleting \(object) \n \(error)")
        }
    }
    
    //MARK: - QUERY
    func getAccount(withName name:String)-> Account? {
        return self.realm.objects(Account.self).filter("name == %@", name).first
    }
    
    //MARK: - CREATE
    func newAccount(name:String, amount:Int, startingAmount:Int, accountType:AccountType, currency:Currency)-> Account {
        let account = Account()
        account.name = name
        account.amount = amount
        account.startingAmount = startingAmount
        account.type = accountType
        account.currency = currency
        self.save(object: account)
        
        return account
    }
    
}
