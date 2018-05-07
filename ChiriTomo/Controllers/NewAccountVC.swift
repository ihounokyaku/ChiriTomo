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
    
    
    //MARK: - ==OtherVariables==
    var account:Account?
    
//MARK: - ===========SETUP===========
    //MARK: - ==ViewDidLoad==
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Delegates
        

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
        return 0
    }
    
    //MARK: - ==Delegate Methods==
    
    
    
}

