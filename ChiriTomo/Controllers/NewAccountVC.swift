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
    
    //MARK: - ==Lists/Arrays==
    var currencyKeys = CurrencyKeys
    
    //MARK: - ==OtherVariables==
    var account:Account?
    
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
        
        //MARK: UpdateUI
        self.populateFromAccount()
        self.toggleSave()
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        print(self.startDatePicker.date)
        print(self.startDatePicker.date.dateInt(forAccountType: .daily))
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
        
        //MARK: 
        
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
        if self.amountField.text != "" && self.nameField.text != "" {
            self.saveButton.isEnabled = false
        } else {
            self.saveButton.isEnabled = true
        }
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
    
    //MARK: - ==Delegate Methods==
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.currencyPicker {
            return Currencies[currencyKeys[row]]!.rawValue + " " + currencyKeys[row]
        } else {
            return AccountTypes[row].rawValue
        }
    }
    
}

