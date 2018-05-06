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

class NewTransactionVC: UIViewController {

    //MARK: - =========IBOUTLETS==========
    
    //MARK: Textfields
    @IBOutlet weak var nameField: AkiraTextField!
    @IBOutlet weak var amountField: AkiraTextField!
    
    //MARK: PickerViews
    @IBOutlet weak var subcategoryPicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //MARK: Buttons
    @IBOutlet weak var plusMinusControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    //MARK: - =========VARIABLES==========
    
    //MARK: Managers
    var prefs = Prefs()
    
    //MARK: Other Variables
    var subcategories = List<Subcategory>()
    var transaction = Transaction()
    var mainView:MainViewController!
    
    
    //MARK: - =========SETUP==========
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // -- Delegates
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
        self.subcategoryPicker.delegate = self
        self.subcategoryPicker.dataSource = self
        
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
        
        // -- Update UI
        self.rememberSwitch.onTintColor = UIColor(hexString: "#77B05E")
        self.toggleSave()
    }
    
    //MARK: - ==========TEXT ENTRY=============
    
    

    //MARK: - ==========CANCEL/SAVE BUTTONS=============
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        //-- set amount
        var amount = -Int(self.amountField.text!)!
        if plusMinusControl.selectedSegmentIndex == 1 {
            amount = Int(self.amountField.text!)!
        }
        
        //-- save transaction
        self.prefs.dataManager.newUpdateTransaction(transaction: self.transaction, name: self.nameField.text!, amount: amount, note: "", date: self.datePicker.date, category: self.subcategories[self.subcategoryPicker.selectedRow(inComponent: 0)])
        
        
        //-- Make sure total is updated
        self.prefs.dataManager.updateTotal()
        
        //-- if transaction is earlier than today update surplus
        let daysEnd = self.prefs.dataManager.account.daysEnd
        if self.datePicker.date.adjusted(by: daysEnd).dateInt() < Date().adjusted(by: daysEnd).dateInt() {
            self.prefs.dataManager.adjustSurplus(by: amount)
        }
        
        //-- Dismiss view
        self.dismiss(animated: true) {
            self.mainView.refresh()
            
        }
    }
    
    //MARK: - ==========UI UPDATES=============
    @IBAction func textDidChange(_ sender: Any) {
        self.toggleSave()
    }
    
    //MARK: Hide Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
            return subcategories.count
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
