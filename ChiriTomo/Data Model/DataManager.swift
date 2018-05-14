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
    //MARK: VARIABLES
    let realm = try! Realm()
    let prefs = UserDefaults.standard
    var account:Account!
    
    
    //MARK: RESULTS
    var categories: Results<MainCategory>!
    var transactionsUnsorted: Results<Transaction>!
    var accounts: Results<Account>!
    var transactions = [Int:NSMutableDictionary]()
    var transactionKeys = [Int]()
    
    //MARK: - INIT
    override init() {
        super.init()
        
        //-- Populate Categories
        self.categories = realm.objects(MainCategory.self)
        if categories.count == 0 {
            self.populateCategories()
        }
        
        //-- Set Account 
        if let accountName = self.prefs.value(forKey: "account") as? String, let acct = self.account(withName: accountName) {
            self.account = acct
        } else {
            //TODO: deal with new account
            self.account = self.newAccount(name: "TestAccount", amount: 500, startingAmount: 0, startDate:Date().addingTimeInterval(-45 * 24 * 60 * 60).dateInt(forAccountType:.daily), daysEnd:0400, accountType: .daily, currency: .THB)
            self.prefs.set(self.account.name, forKey: "account")
        }
        
        //-- Set Accounts
        self.accounts = realm.objects(Account.self)
        
        //-- Update transactions and total
        self.sortTransactions()
        self.updateTotal()
    }
    
    //MARK: - ==============GET RESULTS/VARIABLES===============
    
    //MARK: - ==Sort==
    
    func sortTransactions() {
    
        //MARK: empty arrays
        self.transactions = [:]
        self.transactionKeys = []
        
        //MARK: get adjusted start and end dates
        let endDate = Date().adjusted(by: self.account.daysEnd)
        var startDate:Date!
        let accountStartDate = account.startDate.toDate()
        
        switch self.account.type {
        case .daily:
            startDate = endDate.addingTimeInterval(-30 * 24 * 60 * 60)
        case .monthly:
            startDate = endDate.stepDown(by: 12, forAccountType: .monthly)
        case .weekly:
            startDate = endDate.addingTimeInterval(-24 * 7 * 24 * 60 * 60)
        }
        if startDate < accountStartDate {
            startDate = accountStartDate
        }
        
        //MARK: Get All Keys and fill in Dictionary
        self.transactionKeys = self.dates(from: startDate, to: endDate.dateInt(forAccountType:self.account.type))
        
        
        //-- get all transactions within date range
         self.transactionsUnsorted = self.account.transactions.filter("date >= %i", startDate.dateInt(forAccountType:self.account.type)).sorted(byKeyPath: "date", ascending: false)
        
        //-- Fill dic
        for dateInt in self.transactionKeys {
            self.transactions[dateInt] = ["Transactions":[Transaction](), "Total":0]
        }
        
        self.transactionKeys = self.transactionKeys.sorted(by: {($0 > $1)})

        //-- Fill in transaction info
        for transaction in transactionsUnsorted {
            
            let date = transaction.date
            //TODO - Adjust for other types
            
            //-- append to transactions
            var transArray = self.transactions[date]!["Transactions"] as? [Transaction] ?? [Transaction]()
            transArray.append(transaction)
            self.transactions[date]!["Transactions"] = transArray

            //-- adjust amount
            let amount = self.transactions[date]!["Total"] as? Int ?? 0
           
            self.transactions[date]!["Total"] = amount + transaction.amount
        }
        
    }
    
    func updateTotal(all:Bool = false) {
        //-- check if amount needs updating
        let today = Date().adjusted(by: self.account.daysEnd).dateInt(forAccountType:self.account.type)
        //-- TODO: - Adjust for different typess
        if self.account.lastUpdated < today || all {

            // -- filter by date
            var startDate:Date!
            if all {
                startDate = self.account.startDate.toDate()
            } else {
                startDate = self.account.lastUpdated.toDate()
            }
            let dates = self.dates(from: startDate, to: today)
            var amountByDate = [Int:Int]()
            
            //-- Fill in all dates
            
            for date in dates {
                if date < today {
                    amountByDate[date] = self.account.amount
                }
            }
            
            //-- adjust for transactions
            let transactions = self.account.transactions.filter("(date >= %i) AND (date < %i)", startDate.dateInt(forAccountType:self.account.type), today)
            
            for transaction in transactions {
                let amount = amountByDate[transaction.date] ?? self.account.amount
                amountByDate[transaction.date] = amount + transaction.amount
            }
            var totalSurplus = self.account.surplus
            if all {
                totalSurplus = 0
            }
            
            //-- add total
            for (_, amount) in amountByDate {
                totalSurplus += amount
            }
            
            //-- update Account
            do {
                try realm.write {
                    self.account.surplus = totalSurplus
                    self.account.lastUpdated = today
                }
            } catch {
                print("couldn't write to account \(error)")
            }
        }
        
    }
    
    func regularTransactions() -> [RegularTransaction] {
        return self.account.regularTransactions.sorted(by: {$0.numberOfRecentTransactions > $1.numberOfRecentTransactions})
    }
    
    //MARK: - == Set ==
    
    func setAccount(account:Account) {
        self.account = account
        self.prefs.set(self.account.name, forKey: "account")
    }
    
    

    //MARK: GET DATES
    func dates(from startDate:Date, to endDateInt:Int)-> [Int] {
        var dates = [Int]()
        
        //-- get starting dates
        var date = startDate
        var dateInt = startDate.dateInt()
        
        while dateInt <= endDateInt {
            //-- add to array
            dates.append(dateInt)
            
            date = date.stepUp(forAccountType: self.account.type)
            dateInt = date.dateInt()
        }
        
        return dates
    }
    
    //MARK: - =====================CRUD===========================
    
    //MARK: - CREATE
    func save(object:Object) {
        do {
            try self.realm.write {
                realm.add(object)
            }
        } catch {
            print("Error saving object \(error)")
        }
    }
    
    func newAccount(name:String, amount:Int, startingAmount:Int, startDate:Int, daysEnd:Int, accountType:AccountType, currency:Currency)-> Account {
        let account = Account()
        account.name = name
        account.amount = amount
        account.startingAmount = startingAmount
        account.startDate = startDate
        account.type = accountType
        account.currency = currency
        account.lastUpdated = startDate
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
    
    func newTransaction(name:String, amount:Int, note:String, date:Date, category:Subcategory) {
        let transaction = Transaction()
        transaction.name = name
        transaction.amount = amount
        transaction.note = note
        transaction.fullDate = date.adjusted(by: self.account.daysEnd)
        transaction.date = date.dateInt(forAccountType:self.account.type, adjustedBy: self.account.daysEnd)
        self.save(object: transaction)
        do {
            try realm.write {
                self.account.transactions.append(transaction)
                category.transactions.append(transaction)
            }
        } catch {
            print("could not append transaction \(error)")
        }
    }
    
    func newRegularTransaction (name:String, amount:Int, category:Subcategory) {
        let transaction = RegularTransaction()
        transaction.name = name
        transaction.amount = amount
        
        do {
            try realm.write {
                self.account.regularTransactions.append(transaction)
                category.regularTransactions.append(transaction)
            }
        } catch {
            print("could not append transaction \(error)")
        }
    }
    
    //MARK: - READ
    func account(withName name:String)-> Account? {
        return self.realm.objects(Account.self).filter("name == %@", name).first
    }
    
    func regularTransaction(withName name:String)-> RegularTransaction? {
        return self.account.regularTransactions.filter("name == %@", name).first
    }
    
    //MARK: - CREATE
    
    
    //MARK: - UPDATE
    func adjustSurplus(by amount:Int) {
        do {
            try self.realm.write {
                self.account.surplus += amount
            }
        } catch {
            print("could not update total \(error)")
        }
    }
    
    func UpdateTransaction(transaction:Transaction, name:String, amount:Int, note:String, date:Date, category:Subcategory) {
        do {
            try realm.write {
                transaction.name = name
                transaction.amount = amount
                transaction.note = note
                transaction.fullDate = date
                transaction.date = date.dateInt(forAccountType:self.account.type, adjustedBy: self.account.daysEnd)
                if !category.transactions.contains(transaction) {
                    if let oldCategory = transaction.category.first {
                        oldCategory.transactions.remove(at: oldCategory.transactions.index(of: transaction)!)
                    }
                    category.transactions.append(transaction)
                }
            }
        } catch {
            print("error writing transaction \n\(error)")
        }
    }
    
    func updateRegularTransaction(transaction:RegularTransaction, name:String, amount:Int, category:Subcategory) {
        
        do {
            try realm.write {
                transaction.name = name
                transaction.amount = amount
                
                if !category.regularTransactions.contains(transaction) {
                    if let oldCategory = transaction.category.first {
                        oldCategory.regularTransactions.remove(at: oldCategory.regularTransactions.index(of: transaction)!)
                    }
                    category.regularTransactions.append(transaction)
                }
            }
        } catch {
            print("error writing transaction \n\(error)")
        }
    }
    
    func appendTransactionToRegular(transaction:Transaction) {
        
    }
    
    func updateAccount(account:Account, name:String, amount:Int, startingAmount:Int, startDate:Int, daysEnd:Int, accountType:AccountType, currency:Currency) {
        do {
            try realm.write {
                account.name = name
                account.amount = amount
                account.startingAmount = startingAmount
                account.startDate = startDate
                account.type = accountType
                account.currency = currency
                account.lastUpdated = startDate
            }
        } catch {
            print("error updating account\(error)")
        }
    }
    
    //MARK: - DESTROY
    func deleteObject(object:Object) {
        do {
            try self.realm.write {
                realm.delete(object)
            }
        } catch {
            print("error deleting \(object) \n \(error)")
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
