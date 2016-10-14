//
//  CaseListViewController.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/5/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import UIKit

class CaseListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var results: [String] = []
    var originalResults: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DSIG Linea"
        self.searchBar.delegate = self
        self.tableView.setupFooterView()
        self.results = ["S16-00088", "CA1001", "1CA001", "2CA23001", "232CA0012", "C22A22222202101"]
        self.originalResults = self.results
    }

    //MARK : - TableView Delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.results.count > 0
        {
            return self.results.count
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = self.results.count > 0 ? "cellIdIdentifier" : "nocaseIndentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if self.results.count > 0
        {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell.textLabel?.text = self.results[self.results.count-indexPath.row-1]
        }
        else
        {
            cell.selectionStyle = .none
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.results.count > 0
        {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.results.remove(at: self.results.count-indexPath.row-1)
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.caseno = searchBar.text!
        self.getDataForActionType(actionType: .Grossing, caseno: searchBar.text!)
        self.handleDataSourceUpdate(resultString: searchBar.text!)
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text, searchText != ""{
            
            self.results = self.originalResults.filter({(item: String) -> Bool in
                
                let stringMatch = item.lowercased().range(of: searchBar.text!.lowercased())
                return stringMatch != nil ? true : false
            })
        }
        else
        {
            self.results = self.originalResults
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.results = self.originalResults
        self.tableView.reloadData()
    }
    override func handleDataSourceUpdate(resultString: String)
    {
        self.results.append(resultString)
        self.originalResults = self.results
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.results.count > 0
        {
            self.caseno = self.results[self.results.count-indexPath.row-1]
            self.getDataForActionType(actionType: .Grossing, caseno: self.caseno)
        }
    }
    
    override func openNextView(caseData:CaseData) {
        self.performSegue(withIdentifier: "showdetailsegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdetailsegue"
        {
            if let vc = segue.destination as? CaseDetailsViewController
            {
                vc.caseno = self.caseno
                vc.caseData = self.caseData
            }
        }
    }

    
    
}
