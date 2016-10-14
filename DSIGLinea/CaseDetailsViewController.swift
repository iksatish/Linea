//
//  CaseDetailsViewController.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/6/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import UIKit

class CaseDetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Case Details"
        self.tableView.setupFooterView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ActionType.allActions.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allActions = ActionType.allActions
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        if indexPath.row == 0
        {
            cell.textLabel?.text = self.getCaseData(caseData: self.caseData)
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.selectionStyle = .none
        }else{
            cell.textLabel?.text = "\(allActions[indexPath.row-1]) Data"
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0
        {
            self.actionType = self.getActionTypeForIndexPath(indexPath: indexPath)
            self.performSegue(withIdentifier: "showDataSegue", sender: self)            
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? IndividualDataViewController, segue.identifier == "showDataSegue"
        {
            vc.actionType = self.actionType
            vc.caseData = self.caseData
        }
    }
    func getActionTypeForIndexPath(indexPath: IndexPath) -> ActionType
    {
        switch indexPath.row
        {
        case 1:
            return .Accessioning
        case 2:
            return .Grossing
        case 3:
            return .Embedding
        case 4:
            return .Microtome
        case 5:
            return .Staining
        default:
            return .QA
        }
        
    }
    

    
}
