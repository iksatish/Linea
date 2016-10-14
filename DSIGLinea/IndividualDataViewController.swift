//
//  IndividualDataViewController.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/6/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import UIKit
protocol ButtonActionsDelegate{
    func handleButtonActionForTag(tagNo:Int, specimen:Specimen)
}
class IndividualDataViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ButtonActionsDelegate {
    @IBOutlet weak var tableView: UITableView!
    var selectedRow = 999
    let verifiedColor = UIColor.init(colorLiteralRed: 144/255, green: 187/255, blue: 145/255, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setupFooterView()
        self.getDataForActionType(actionType: actionType, caseno: self.caseData.caseno)
        self.title = self.actionType.rawValue + " Data"
   }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.caseData.specimens.count > 0 ? self.caseData.specimens.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.caseData.specimens.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        if self.caseData.specimens.count > 0
        {
            let specimen = self.caseData.specimens[indexPath.section]
            if indexPath.row == 0{
                cell.textLabel?.text = self.getDataForSpecimen(specimen: specimen, forActionType: actionType)
                cell.backgroundColor = specimen.isVerified ? verifiedColor : UIColor.white
            }else{
                let actionCell = tableView.dequeueReusableCell(withIdentifier: "actionCellIdentifier", for: indexPath) as! ActionTableViewCell
                actionCell.delegate = self
                actionCell.selectionStyle = .none
                actionCell.backgroundColor = specimen.isVerified ? verifiedColor : UIColor.white
                actionCell.specimen = specimen
                actionCell.updateButtonsForActionType(actionType: self.actionType)
                return actionCell

            }
        }
        else
        {
         cell.textLabel?.text = "No Data Available"
        }
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.section
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 4))
        footerView.backgroundColor = UIColor.init(colorLiteralRed: 85/255, green: 140/255, blue: 137/255, alpha: 1.0)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    override func openNextView(caseData: CaseData) {
        self.tableView.reloadData()
    }
    
    @IBAction func doAction(_ sender: UIButton) {
    }
    
    func handleButtonActionForTag(tagNo: Int, specimen:Specimen) {
        if tagNo == 1   {
            self.getNotesForSpecimen(specimen: specimen)
        }else if tagNo == 2 && !specimen.isVerified{
            self.markSpecimenAsVerified(actionType: self.actionType, specimen: specimen)
        }
    }
    override func showNotes(notes: [Notes], specimen: Specimen) {
        let notesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        notesVC.notes = notes
        notesVC.specimen = specimen
        notesVC.actionType = self.actionType
        self.navigationController?.present(notesVC, animated: true, completion: nil)
    }
    
    override func refreshData()
    {
        self.getDataForActionType(actionType: self.actionType, caseno: self.caseData.caseno)
    }
}



class ActionTableViewCell: UITableViewCell
{
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    var delegate: ButtonActionsDelegate?
    var specimen: Specimen = Specimen()
    @IBAction func doAction(_ sender: UIButton) {
        self.delegate?.handleButtonActionForTag(tagNo: sender.tag, specimen: self.specimen)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button1.isHidden = true
        self.button2.isHidden = true
        self.button3.isHidden = true
    }
    
    func updateButtonsForActionType(actionType: ActionType)
    {
        switch actionType{
        case .Accessioning:
            self.button1.isHidden = false
        case .QA, .Staining, .Grossing, .Embedding:
            self.button1.isHidden = false
            self.button2.isHidden = false
        default:
            self.button1.isHidden = false
        }
    }
    
}
