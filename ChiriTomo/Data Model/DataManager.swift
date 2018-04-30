//
//  DataManager.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class DataManager:NSObject {
    
    let realm = try! Realm()
    
    
    //MARK: RESULTS
    var categories: Results<MainCategory>!
    
    
    //MARK: - INIT
    override init() {
        super.init()
        
        //-- Populate Categories
        self.categories = realm.objects(MainCategory.self)
        if categories.count == 0 {
            self.populateCategories()
        }
        
        //-- Set Account 
        
    }
    
    
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
    
    func newCategory(name:String, color:String, subCategories:[String]) {
        let category = MainCategory()
        var sc = subCategories
        sc.append("Misc")
        category.name = name
        category.colorHex = color
        for subcategoryName in sc {
            let newSubcategory = Subcategory()
            newSubcategory.name = subcategoryName
            newSubcategory.colorHex = color
            self.save(object: newSubcategory)
            category.subcategories.append(newSubcategory)
        }
        self.save(object: category)
    }
    
    func newUpdateTransaction(transaction:Transaction, name:String, amount:Int, note:String, date:Int, account:Account, category:Subcategory) {
        do {
            try realm.write {
                transaction.name = name
                transaction.amount = amount
                transaction.note = note
                transaction.date = date
                category.transactions.append(transaction)
                account.transactions.append(transaction)
            }
        } catch {
           print("error writing transaction \n\(error)")
        }
    }
    
    //MARK: - POPULATE
    func populateCategories() {
        let categoryDictionary: [[String:Any]] = [["MainCategory":"Household", "SubCategories":["Rent", "Utilities", "Phone/Internet", "Renovation/Repairs"], "color":UIColor.flatRed().hexValue()],
                                                  ["MainCategory":"Food", "SubCategories":["Groceries", "Beverages", "Eating Out", "Coffee"], "color":UIColor.flatYellow().hexValue()],
                                                  ["MainCategory":"Daily Expenses", "SubCategories":["Laundry","Cleaning"], "color":UIColor.flatLime().hexValue()],
                                                  ["MainCategory":"Entertainment", "SubCategories":["Cinema", "Concert/Event", "Alcohol","Movies/Games/Music"], "color":UIColor.flatBlue().hexValue()],
                                                  ["MainCategory":"Health", "SubCategories":["Gym","Supplements/equipment","Medicine","Clinic/Hospital","Dentist"], "color":UIColor.flatTeal().hexValue()],
                                                  ["MainCategory":"Transportation", "SubCategories":["Gas","Repairs","Public Transport","Vehicle Payment"], "color":UIColor.flatOrange().hexValue()],
                                                  ["MainCategory":"Holiday", "SubCategories":["Transportation", "Lodging","Souvenirs","Sightseeing"], "color":UIColor.flatMagenta().hexValue()],
                                                  ["MainCategory":"Fines/Fees", "SubCategories":["Service Fees", "Fines"], "color":UIColor.flatMaroon().hexValue()],
                                                  ["MainCategory":"Personal", "SubCategories":["Clothing", "Gifts", "Beauty", "Books"], "color":UIColor.flatSand().hexValue()],
                                                  ["MainCategory":"Electronics", "SubCategories":["Computer"], "color":UIColor.flatPlum().hexValue()],
                                                  ["MainCategory":"Misc", "SubCategories":["Lessons"], "color":UIColor.flatGray().hexValue()]]
        
        for category in categoryDictionary {
            self.newCategory(name: category["MainCategory"] as! String, color: category["color"] as! String, subCategories: category["SubCategories"] as! [String])
        }
        self.categories = realm.objects(MainCategory.self)
    }
}
