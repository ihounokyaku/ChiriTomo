//
//  SettingsVC.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/05/14.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingsVC: MainViewDelegate {

    //MARK: - =========IBOUTLETS==========

    
    //MARK: - ==PickerViews==
    @IBOutlet weak var accountPicker: UIPickerView!
    @IBOutlet weak var languagePicker: UIPickerView!
    
    
    //MARK: - ==Buttons==
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var accountsController: UISegmentedControl!
    
    
    //MARK: - ==Labels==
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var accountsLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    //MARK: - =========VARIABLES==========
    
    //MARK: - ==Managers==

    
    //MARK: - ==LISTS==
    
    //MARK: - ==Other Variables==
    
    
    
    //MARK: - =========SETUP==========
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - ==DELEGATES AND DATASOURCES==
        self.accountPicker.delegate = self
        self.accountPicker.dataSource = self
        self.languagePicker.dataSource = self
        self.languagePicker.delegate = self

    }
    
    //MARK: - =========ADD/REMOVE/DELETE ACCOUNT==========
    
    //MARK: - ==Delegate Buttons==
    @IBAction func accountsControlsPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.presentView()
        case 1:
            self.deleteConfirmation()
        case 2:
            self.showRenameAlert()
        default:
            break
        }
    }
    
    //MARK: - ==Present Controller==
    func presentView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewAccount") as! NewAccountVC
        
        //MARK: Configure and Present VC
        controller.prefs = self.prefs
        controller.mainView = self.mainView
        controller.modalPresentationStyle = .popover
        self.present(controller, animated:true, completion:nil)
    }
    
    //MARK: - ==Alerts==
    func showRenameAlert() {
        var textField = UITextField()
        let index = self.accountPicker.selectedRow(inComponent: 0)
        let account = self.prefs.dataManager.accounts[index]
        
        
        let alert = UIAlertController(title: "Rename Account", message: "", preferredStyle: .alert)
        
        //Mark: Define Rename/Cancel Actions
        let action = UIAlertAction(title: "Rename", style: .default) { (action) in
            
            if textField.text != "" {
                let oldName = account.name
                
                self.prefs.dataManager.updateAccountName(account: account, name: textField.text!)
                if let name = UserDefaults.standard.value(forKey: "account") as? String, name == oldName {
                    UserDefaults.standard.set(textField.text!, forKey: "account")
                }
                self.accountPicker.reloadComponent(0)
                self.accountPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        let action2 = UIAlertAction(title:"Cancel", style:.cancel)
        
        //MARK: Add elements and present
        alert.addTextField { (alertTextField) in
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
        textField.text = account.name
    }
    
    
    
    func deleteConfirmation() {
        let alert = UIAlertController(title: "Delete Account??", message: "This can't be undone. Do you want to back it up first?", preferredStyle: .alert)
        
        //Mark: Define Rename/Cancel Actions
        let action = UIAlertAction(title: "DO IT!!!", style: .default) { (action) in
            if self.prefs.dataManager.accounts.count > 1 {
                self.prefs.dataManager.deleteObject(object: self.prefs.dataManager.accounts[self.accountPicker.selectedRow(inComponent: 0)])
                self.accountPicker.reloadComponent(0)
            }
        }
        let action2 = UIAlertAction(title: "Back Up", style: .default) { (action) in
            //Backup
        }
        
        let action3 = UIAlertAction(title:"Cancel", style:.cancel)
        
        //MARK: - Add elements and present
        alert.addAction(action)
        alert.addAction(action2)
        alert.addAction(action3)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - =========FINISH UP==========
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.mainView.prefs = self.prefs
            self.mainView.setAccountPicker()
            self.mainView.refresh()
        }
    }
    
    //MARK: - =========BACKUP==========
    @IBAction func exportPressed(_ sender: Any) {
        self.createJson()
    }
    
    func createJson() {
        let json = JSON(self.prefs.dataManager.dictionary(fromAccount: self.prefs.dataManager.accounts[self.accountPicker.selectedRow(inComponent: 0)]))
        do {
            let data = try json.rawData()
            let exportFilePath = NSTemporaryDirectory() + self.prefs.dataManager.account.name + ".chiri"
            self.exportFile(data, toPath: exportFilePath)
        } catch {
            print("error making data \(error)")
        }
    }
    
    func exportFile(_ data:Data, toPath path:String) {
        
        let url = URL(fileURLWithPath: path)
        
        do {
            try data.write(to: url, options: .atomicWrite)
            let firstActivityItem = URL(fileURLWithPath: path)
            let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [
                UIActivityType.postToVimeo,
                UIActivityType.postToFlickr,
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToTencentWeibo,
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
        catch {
            print("could not write data to file")
        }
    }
    
    
}




//MARK: - =========PICKERVIEW==========
extension SettingsVC : UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - ==DATASOURCE==
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.accountPicker {
            return self.prefs.dataManager.accounts.count
        } else {
            return LanguageKeys.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.accountPicker {
            return self.prefs.dataManager.accounts[row].name
        } else {
            return LanguageKeys[row]
        }
    }
}
