//
//  NewTransactionVC.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/26.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import TextFieldEffects
import RealmSwift

class NewTransactionVC: MainViewDelegate {

    //MARK: - =========IBOUTLETS==========
    

    //MARK: Textfields
    @IBOutlet weak var nameField: AkiraTextField!
    @IBOutlet weak var amountField: AkiraTextField!
    
    //MARK: PickerViews
    @IBOutlet weak var subcategoryPicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //MARK: TableViews
    @IBOutlet weak var autofillTable: UITableView!
    @IBOutlet weak var quickSelectTable: UITableView!
    
    //MARK: Buttons
    @IBOutlet weak var plusMinusControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    //MARK: - =========VARIABLES==========
    
    
    //MARK: LISTS
    var subcategories = List<Subcategory>()
    var regularTransactions = [RegularTransaction]()
    var filteredPreditions = [String]()
    
    //MARK: Other Variables
    
    var transaction:Transaction?
    var regularTransaction:RegularTransaction?


    
    
    //MARK: - =========SETUP==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // -- DELEGATES/DATASOURCES
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
        self.subcategoryPicker.delegate = self
        self.subcategoryPicker.dataSource = self
        self.autofillTable.delegate = self
        self.autofillTable.dataSource = self
        self.quickSelectTable.dataSource = self
        self.quickSelectTable.delegate = self
        
        // -- RefreshPicker
        self.refreshSubcategories()
        
        // -- Set Date limits
        var dateFloor = 30
        if self.prefs.dataManager.account.type == .monthly {
            dateFloor = 120
            self.datePicker.datePickerMode = .date
        } else {
            self.datePicker.datePickerMode = .dateAndTime
        }
        self.datePicker.maximumDate = Date()
        self.datePicker.minimumDate = Date().addingTimeInterval(Double(-dateFloor * 60 * 60 * 24))
        
        
        //-- Set Regular Transactions
        self.regularTransactions = self.prefs.dataManager.regularTransactions()
        
        // -- Update UI
        self.rememberSwitch.onTintColor = UIColor(hexString: "#77B05E")
        self.autofillTable.isHidden = true
        self.setUIFromTransaction()
        self.toggleSave()
    }
    
    //MARK: - ==========CANCEL/SAVE BUTTONS=============
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
 
        //-- SET VARIABLES
        var amount = -Int(self.amountField.text!)!
        if plusMinusControl.selectedSegmentIndex == 1 {
            amount = Int(self.amountField.text!)!
        }
        
        
        let category = self.subcategories[self.subcategoryPicker.selectedRow(inComponent: 0)]
        let daysEnd = self.prefs.dataManager.account.daysEnd
        //TODO: adjust for acct types
        let todaysDate = Date().adjusted(by: daysEnd).dateInt(forAccountType:self.prefs.dataManager.account.type)
        
        
        //-- Make sure total is updated
        self.prefs.dataManager.updateTotal()
        
        //--if updating transaction add amount to surplus
        if let transaction = self.transaction, transaction.date < todaysDate {
            self.prefs.dataManager.adjustSurplus(by: -transaction.amount)
        }
        //-- if transaction is earlier than today update surplus
        if self.datePicker.date.adjusted(by: daysEnd).dateInt(forAccountType:self.prefs.dataManager.account.type) < todaysDate {
            self.prefs.dataManager.adjustSurplus(by: amount)
        }
        
        //-- save/update transaction
        if let transaction = self.transaction {
            self.prefs.dataManager.UpdateTransaction(transaction: transaction, name: self.nameField.text!, amount: amount, note: "", date: self.datePicker.date, category: category)
        } else {
            self.prefs.dataManager.newTransaction(name: self.nameField.text!, amount: amount, note: "", date: self.datePicker.date, category: category)
        }
    
        //-- save/update regtran if necessary
        if self.rememberSwitch.isOn {
            if let regTran = self.prefs.dataManager.regularTransaction(withName: self.nameField.text!) {
                self.prefs.dataManager.updateRegularTransaction(transaction: regTran, name: self.nameField.text!, amount: amount, category: category)
            } else {
                self.prefs.dataManager.newRegularTransaction(name: self.nameField.text!, amount: amount, category: category)
            }
        }
    
        
        //-- Dismiss view
        self.dismiss(animated: true) {
            self.mainView.refresh()
            
        }
    }
    
    //MARK: - ==========UI UPDATES=============
    @IBAction func textDidChange(_ sender: UITextField) {
        self.toggleSave()
        if sender == self.nameField{
            showHideAutofillTable()
        }
    }
    
    //MARK: - AUTOFILL UI
    func setUIFromTransaction() {
        if let transaction = self.transaction {
            self.nameField.text = transaction.name
            self.setAmount(from: transaction.amount)
            self.setCategory(fromSubcategory: transaction.category.first!)
            self.datePicker.date = transaction.fullDate.date(format: "yyyy-MM-dd HH:mm")!
        }
    }
    
    func setAmount(from amount:Int) {
        self.amountField.text = String(abs(amount))
        
        if amount <= 0  {
            self.plusMinusControl.selectedSegmentIndex = 0
        } else {
            self.plusMinusControl.selectedSegmentIndex = 1
        }
    }
    
    func setCategory(fromSubcategory subcategory:Subcategory) {
        
        let mainCategory = subcategory.parentCategory.first!
        self.categoryPicker.selectRow(self.prefs.dataManager.categories.index(of: mainCategory)!, inComponent: 0, animated: true)
        self.refreshSubcategories()
        self.subcategoryPicker.selectRow(self.subcategories.index(of: subcategory)!, inComponent: 0, animated: true)
    }
    
    //MARK: Hide Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.autofillTable.isHidden = true
    }
    
    //MARK: TOGGLE BUTTONS
    func toggleSave() {
        if self.nameField.text?.count != 0 && self.amountField.text?.count != 0 {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
}

//MARK: - ==========PICKER VIEWS=============
extension NewTransactionVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.categoryPicker {
            return self.prefs.dataManager.categories.count
        } else {
            return self.subcategories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        if pickerView == self.categoryPicker {
            label.text = self.prefs.dataManager.categories[row].name
            label.backgroundColor = self.prefs.dataManager.categories[row].color
        } else {
            label.text = self.subcategories[row].name
            label.backgroundColor = self.subcategories[row].color.darken(byPercentage: CGFloat(Double(row) * 0.1))
        }
        
        label.textColor = UIColor(contrastingBlackOrWhiteColorOn: label.backgroundColor!, isFlat: true)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.categoryPicker {
            self.refreshSubcategories()
        }
    }
    
    //MARK: - REFRESH PICKERVIEW
    
    func refreshSubcategories() {
        self.subcategories = self.prefs.dataManager.categories[self.categoryPicker.selectedRow(inComponent: 0)].subcategories
        self.subcategoryPicker.reloadAllComponents()
        self.subcategoryPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
}

//MARK: - ========== TABLE STUFF =======================

extension NewTransactionVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.autofillTable {
            return self.filteredPreditions.count
        } else {
            if self.regularTransactions.count < 10 {
                return self.regularTransactions.count
            } else {
                return 10
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CandidateCell")!
        
        if tableView == self.autofillTable {
            cell.textLabel?.text = self.filteredPreditions[indexPath.row]
        } else {
            cell.textLabel?.text = self.regularTransactions[indexPath.row].name
            cell.backgroundColor = self.regularTransactions[indexPath.row].category.first!.parentCategory.first!.color.withAlphaComponent(0.7)
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var regTran:RegularTransaction!
        if tableView == self.autofillTable {
            regTran = self.prefs.dataManager.regularTransaction(withName: self.filteredPreditions[indexPath.row])!
            self.autofillTable.isHidden = true
        } else {
            regTran = self.regularTransactions[indexPath.row]
        }
        

        //-- UPDATE UI
        self.setCategory(fromSubcategory: regTran.category.first!)
        
        self.nameField.text = regTran.name
        self.setAmount(from: regTran.amount)
        self.toggleSave()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showHideAutofillTable() {
        
        //-- Filter predictions
        self.filteredPreditions = self.regularTransactions.filter({ (item) -> Bool in
            if item.name.lowercased().contains(self.nameField.text!.lowercased()) {
                print(item.name.lowercased() + " contains " + self.nameField.text!.lowercased())
            }
            return item.name.lowercased().contains(self.nameField.text!.lowercased())
        }).map({return $0.name})
        
        //-- If predictions exist display table
        if self.filteredPreditions.count > 0 {
            self.autofillTable.reloadData()
            
            //-- resize table
            var frame = self.autofillTable.frame
            if self.autofillTable.contentSize.height < 120 {
                frame.size.height = self.autofillTable.contentSize.height
            } else {
                frame.size.height = 100
            }
            self.autofillTable.frame = frame

            self.autofillTable.isHidden = false
        } else {
            self.autofillTable.isHidden = true
        }
    }
}



