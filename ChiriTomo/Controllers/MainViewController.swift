//
//  ViewController.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import ChameleonFramework

class MainViewController: UIViewController {

    
    //MARK: - ======IBOutlets=========
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var surplusLabel: UILabel!
    @IBOutlet weak var accountPicker: UIPickerView!
    
    
    //MARK: - ======Variables=========
    
    //MARK: Managers, etc
    var prefs = Prefs()
    
    //MARK: Variables to pass
    var transactionSelected:Transaction?

    //MARK: - ===========SETUP===========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-- assign D&D
        self.transactionTable.dataSource = self
        self.transactionTable.delegate = self
        self.accountPicker.delegate = self
        self.accountPicker.dataSource = self
        
        //-- register cell
        self.transactionTable.register(UINib(nibName:"TransactionCell", bundle:nil), forCellReuseIdentifier: "TransactionCell")
        
        //-- Update UI
        self.updateUI()
        
    }


    
    //MARK: - ===========BUTTONS===========
    @IBAction func populatePressed(_ sender: Any) {
        self.prefs.dataManager.updateTotal(all: true)
        self.updateUI()
    }
    
    @IBAction func newtransactionPressed(_ sender: Any) {
        self.presentView(withIdentifier: "NewTransaction")
    }
    
    @IBAction func newAccountPressed(_ sender: Any) {
        self.presentView(withIdentifier: "NewAccount")
    }
    
    
    
    //MARK: - ===========REFRESH AND UPDATE UI===========
    func refresh () {
        self.prefs.dataManager.sortTransactions()
        self.prefs.dataManager.updateTotal()
        self.updateUI()
    }
    
    func setAccountPicker() {
        self.accountPicker.reloadComponent(0)
        self.accountPicker.selectRow(self.prefs.dataManager.accounts.index(of: self.prefs.dataManager.account)!, inComponent: 0, animated: false)
    }
    
    func updateUI() {
        self.surplusLabel.text = self.prefs.dataManager.account.currencySymbol + String(self.prefs.dataManager.account.surplus)
        self.totalLabel.text = self.prefs.dataManager.account.currencySymbol + String(self.currentAmount())
        self.transactionTable.reloadData()
    }
    
    func currentAmount()-> Int {
        
        //-- Get current date
        let currentPeriod = Date().adjusted(by: self.prefs.dataManager.account.daysEnd).dateInt(forAccountType: self.prefs.dataManager.account.type)
        
        
        return self.prefs.dataManager.account.amount + (self.prefs.dataManager.transactions[currentPeriod]!["Total"] as? Int ?? self.prefs.dataManager.account.amount)
    
    }
    
    //MARK: - ===========PRESENTVIEW===========
    func presentView(withIdentifier identifier:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        
        //MARK: New Transaction
        if let destinationVC = controller as? NewTransactionVC {
            destinationVC.prefs = self.prefs
            destinationVC.mainView = self
            destinationVC.modalPresentationStyle = .popover
            
            //-- Set transaction if edit
            if self.transactionSelected != nil {
                destinationVC.transaction = self.transactionSelected!
                self.transactionSelected = nil
            }
        }
        
        //MARK: New Account
        //TODO: MOVE THIS TO SETTINGS
        if let destinationVC = controller as? NewAccountVC {
            destinationVC.prefs = self.prefs
            destinationVC.mainView = self
            destinationVC.modalPresentationStyle = .popover
        }
        
        //Present VC
        self.present(controller, animated:true, completion:nil)
    }
    
}
//MARK: - ===========TABLEVIEW===========
extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - SET NUMBER OF ROWS/SECTIONS
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.prefs.dataManager.transactionKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return (self.prefs.dataManager.transactions[self.prefs.dataManager.transactionKeys[section]]!["Transactions"] as! [Transaction]).count
    }
    
    //MARK: - SET CELL CONTENT
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //-- create cell & get transaction
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
        
        let date = self.prefs.dataManager.transactionKeys[indexPath.section]
        let transaction = self.transactions(fromDateInt: date)[indexPath.row]
        
        
        // -- get amount string
        var amount = ""
        if transaction.amount < 0 {
            amount = "-" + self.prefs.dataManager.account.currencySymbol + String(abs(transaction.amount))
        } else {
            amount = "+" + self.prefs.dataManager.account.currencySymbol + String(abs(transaction.amount))
        }
        cell.backgroundColor = transaction.category.first!.color.withAlphaComponent(0.7)
        
        //-- update cell UI
        cell.amountLabel.text = amount
        cell.nameLabel.text = transaction.name
        return cell
    }
    
    //MARK: - SET HEADER
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let header = UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
        
        //-- GET SECTION
        let key = self.prefs.dataManager.transactionKeys[section]
        let section = self.prefs.dataManager.transactions[key]!
        
        
        
        //-- CALCULATE TOTAL
        var totalString = ""
        guard let sectionTotal = section["Total"] as? Int else {fatalError("not an int \(section["Total"])")}
        
        if sectionTotal < 0 {
            totalString = "-" + self.prefs.dataManager.account.currencySymbol + String(abs(sectionTotal))
        } else {
            totalString = "+" + self.prefs.dataManager.account.currencySymbol + String(abs(sectionTotal))
        }

        //-- Set label position
        cell.nameLabel.center.y = 15
        cell.amountLabel.center.y = 15
        
        //-- Set label color
        cell.nameLabel.textColor = UIColor(hexString: "#D7D5B4")
        cell.amountLabel.textColor = UIColor(hexString: "#D7D5B4")
        cell.nameLabel.text = key.toDateString()
        cell.amountLabel.text = totalString
        
        //-- Set Cell color
        cell.alpha = 0.9
        cell.backgroundColor = UIColor(hexString: "#423F3F")
        
        return cell
    }
    
    
    //MARK: - Actions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let date = self.prefs.dataManager.transactionKeys[indexPath.section]
        let transaction = self.transactions(fromDateInt: date)[indexPath.row]
        self.transactionSelected = transaction
        self.presentView(withIdentifier: "NewTransaction")
    }
    
    func transactions(fromDateInt date:Int)-> [Transaction] {
        guard let dateothingo = self.prefs.dataManager.transactions[date]! as? [String:Any] else {fatalError("couldn't unwrap dictionary for \(date)")}
        guard let transactions = dateothingo["Transactions"] as? [Transaction] else {fatalError("couldn't get transactions from \(dateothingo)")}
        return transactions
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            
            let date = self.prefs.dataManager.transactionKeys[indexPath.section]
            let amount = self.transactions(fromDateInt: date)[indexPath.row].amount
            self.self.prefs.dataManager.deleteObject(object: self.transactions(fromDateInt: date)[indexPath.row])
            self.prefs.dataManager.adjustSurplus(by: -amount)
            self.refresh()
        }
        delete.backgroundColor = UIColor(hexString: "#A5484A").withAlphaComponent(0.8)
        return [delete]
    }
}

//MARK: - =========ACCOUNT PICKER==========

//MARK: - ==Data Source==
extension MainViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.prefs.dataManager.accounts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.prefs.dataManager.accounts[row].name
    }
    
    //MARK: - ==Delegate==
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.prefs.dataManager.account = self.prefs.dataManager.accounts[row]
        self.refresh()
    }
    
}

