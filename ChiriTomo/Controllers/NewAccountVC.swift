//
//  NewAccountVC.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/05/08.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import TextFieldEffects

class NewAccountVC: UIViewController {
    
    //MARK: - ===========IBOUTLETS===========
    
    //MARK: - ==TextFields==
    @IBOutlet weak var nameField: AkiraTextField!
    @IBOutlet weak var startingSurplusField: AkiraTextField!
    @IBOutlet weak var amountField: AkiraTextField!
    
    //MARK: - ==PickerViews==
    @IBOutlet weak var frequencyPicker: UIPickerView!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    //MARK: - ==DatePickers==
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var dayRolloverPicker: UIDatePicker!
    
    //MARK: - ==Buttons==
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - ===========VARIABLES===========
    
    //MARK: - ==Managers/Delegates==
    var prefs = Prefs()
    
    //TODO: Change to prefs
    var mainView:MainViewController!
    
    
    //MARK: - ==Lists/Arrays==
    var currencyKeys = CurrencyKeys
    
    //MARK: - ==OtherVariables==
    var account:Account?
    var datePickerPreviousValue:Date!
    
//MARK: - ===========SETUP===========
    //MARK: - ==ViewDidLoad==
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Delegates
        self.currencyPicker.delegate = self
        self.currencyPicker.dataSource = self
        self.frequencyPicker.dataSource = self
        self.frequencyPicker.delegate = self
        
        //MARK: SetDatePickers
        self.startDatePicker.maximumDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dayRolloverPicker.date = dateFormatter.date(from: "04:00")!
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.startDatePicker.minimumDate = dateFormatter.date(from: "2017-01-01")
        self.startDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        self.datePickerPreviousValue = self.startDatePicker.date
        
        //MARK: UpdateUI
        self.populateFromAccount()
        self.toggleSave()
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        print("THIS IS STILL ACTIVE!")
       
    }
    //MARK: - ===========SAVE/CANCEL===========
    
    //MARK: - ==Cancel==
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            //TODO: Cancel Completion
        }
    }
    
    //MARK: - ==Save==
    @IBAction func savePressed(_ sender: Any) {
        //TODO: Save Account
        
        //MARK: Declare / Adjust variables
        var startingSurplus = 0
        if let surplus = Int(self.startingSurplusField.text!){
            startingSurplus = surplus
        }
        let accountType = AccountTypes[self.frequencyPicker.selectedRow(inComponent: 0)]
        let startDate = self.startDatePicker.date.dateInt(forAccountType: accountType)
        let amount = Int(self.amountField.text!)!
        let currency = Currencies[self.currencyKeys[self.currencyPicker.selectedRow(inComponent: 0)]]!
        let daysEnd = dayRolloverPicker.date.timeInt()
        
        //MARK: check if in edit mode and if so update
        if let account = self.account {
            self.prefs.dataManager.updateAccount(account: account, name: self.nameField.text!, amount: amount, startingAmount: startingSurplus, startDate: startDate, daysEnd:daysEnd, accountType: accountType, currency: currency)
        } else {
            //MARK: if not edit save account
            self.account = self.prefs.dataManager.newAccount(name: self.nameField.text!, amount: amount, startingAmount: startingSurplus, startDate: startDate, daysEnd:daysEnd, accountType: accountType, currency: currency)
        }
        
        //MARK: Dismiss and switch to account
        self.prefs.dataManager.setAccount(account: self.account!)
        self.dismiss(animated: true) {
            self.mainView.prefs = self.prefs
            self.mainView.setAccountPicker()
            self.mainView.refresh()
        }
    }
    
    //MARK: - ===========UpdateUI===========
    func populateFromAccount() {
        if let account = self.account {
            self.amountField.text = String(account.amount)
            self.startingSurplusField.text = String(account.startingAmount)
            self.nameField.text = account.name
            self.startDatePicker.date = account.startDate.toDate()
            //TODO: Set time picker
        }
    }
    
    func toggleSave() {
        if let int = Int(self.amountField.text!), int > 0, self.nameField.text != "" {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
    
    //MARK: - ==Set DatePicker==
    func setDatePickerInterval(direction:String) {
        print(startDatePicker.date)
        let frequency = AccountTypes[self.frequencyPicker.selectedRow(inComponent: 0)]
        var newDate = self.startDatePicker.date.closestDate(forFrequency: frequency)[direction]!
        if newDate > self.startDatePicker.maximumDate! {
            newDate = self.startDatePicker.date.closestDate(forFrequency: frequency)["Down"]!
        }
        self.startDatePicker.date = newDate
    }
    
}

//MARK: - ===========PICKERVIEWS===========
extension NewAccountVC : UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - ==Datasource Methods==
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //TODO: Number of rows
        if pickerView == self.currencyPicker {
            return self.currencyKeys.count
        } else {
            return AccountTypes.count
        }
    }
    
    //MARK: - ==Display==
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.currencyPicker {
            return Currencies[currencyKeys[row]]!.rawValue + " " + currencyKeys[row]
        } else {
            return AccountTypes[row].rawValue
        }
    }
    
    //MARK: - ==Delegate==
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.frequencyPicker {
            let frequency = AccountTypes[row]
            self.startDatePicker.maximumDate = Date().closestDate(forFrequency: frequency)["Down"]!
            self.startDatePicker.date = self.startDatePicker.date.closestDate(forFrequency: frequency)["Down"]!
        }
    }
    
    //MARK: - ==DatePicker==
    @objc func datePickerChanged(picker:UIDatePicker) {
        print("old date is \(self.datePickerPreviousValue) startdate is \(self.startDatePicker.date)")
        var direction = "Down"
        if self.datePickerPreviousValue! < startDatePicker.date {
            direction = "Up"
        }
        print("\(direction)")
        self.setDatePickerInterval(direction: direction)
        
        self.datePickerPreviousValue = startDatePicker.date
    }
    
}

