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
    
    //MARK: - =========VARIABLES==========
    
    //MARK: Managers
    let dataManager = DataManager()
    let prefs = Prefs()
    
    //MARK: Other Variables
    var subcategories = List<Subcategory>()
    var transaction = Transaction()
    
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
        if self.prefs.account.type == .monthly {
            dateFloor = 120
            self.datePicker.datePickerMode = .date
        } else {
            self.datePicker.datePickerMode = .dateAndTime
        }
        self.datePicker.maximumDate = Date()
        self.datePicker.minimumDate = Date().addingTimeInterval(Double(-dateFloor * 60 * 60 * 24))
        
        // -- Update UI
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
        self.dataManager.newUpdateTransaction(transaction: self.transaction, name: self.nameField.text!, amount: amount, note: "", date: self.datePicker.date.dateInt(adjustedBy: self.prefs.account.daysEnd), account: self.prefs.account, category: self.subcategories[self.subcategoryPicker.selectedRow(inComponent: 0)])
        self.dismiss(animated: true, completion: nil)
     
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
            return self.dataManager.categories.count
        } else {
            return subcategories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        if pickerView == self.categoryPicker {
            label.text = self.dataManager.categories[row].name
            label.backgroundColor = self.dataManager.categories[row].color
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
        self.subcategories = self.dataManager.categories[self.categoryPicker.selectedRow(inComponent: 0)].subcategories
        self.subcategoryPicker.reloadAllComponents()
        self.subcategoryPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
}
