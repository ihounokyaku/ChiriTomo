//
//  ViewController.swift
//  ChiriTomo
//
//  Created by Dylan Southard on 2018/04/25.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    
    //MARK: - ======IBOutlets=========
    @IBOutlet weak var transactionTable: UITableView!
    
    
    //MARK: - ======Variables=========
    
    //MARK: Managers, etc
    let prefs = Prefs()

    //MARK: - ===========SETUP===========
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    
    //MARK: - ===========BUTTONS===========
    @IBAction func populatePressed(_ sender: Any) {
    }
    
    @IBAction func newtransactionPressed(_ sender: Any) {
    }
    
}
//MARK: - ===========TABLEVIEW===========
extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: number in tv
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        //TODO: Make cell
        return cell
    }
    
    
}

