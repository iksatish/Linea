//
//  NotesViewController.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/12/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import UIKit

class NotesViewController: BaseViewController, UITabBarDelegate, UITableViewDataSource {

    @IBOutlet weak var headerLabel: UILabel!
    var notes: [Notes] = []
    var specimen = Specimen()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notesTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerLabel.text = "Case No: \(specimen.caseNo), Specimen Id: \(specimen.specimenId)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    @IBAction func closeNotes(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notes = self.notes[self.notes.count-indexPath.row-1]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = "At \(notes.createdTime): \(notes.notes) "
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
    
    @IBAction func notesTextView(_ sender: UIButton) {
        guard let notesText = self.notesTextView.text, notesText.characters.count > 0 else{
            self.showAlert(title: "Oops!", message: "Can't add empty notes!")
            return
        }
        self.postNotesForSpecimen(specimen: self.specimen)
    }
    
    override func showNotes(notes: [Notes], specimen: Specimen) {
        self.notes = notes
        self.tableView.reloadData()

    }
    
    func postNotesForSpecimen(specimen: Specimen)
    {
        let urlText = self.notesPostUrl(actionType: self.actionType, specimen: specimen)
        let url = URL(string: urlText.addingPercentEscapes(using: String.Encoding.utf8)!)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        self.showProgressView(title: "Adding Notes", withDetailText: "")
        let task = session.dataTask(with: request as URLRequest) {
            (
            data,  response, error) in
            DispatchQueue.main.async {
                self.hideProgressView()
            }
            do{
                if let _ = error
                {
                    self.showAlert(title: "Service Issue", message: "Please try again!")
                    return
                }
                DispatchQueue.main.async {
                    self.notesTextView.text = ""
                    self.getNotesForSpecimen(specimen: specimen)
                }
                
            }
            catch{
                DispatchQueue.main.async {
                    self.showNotes(notes: [Notes()], specimen: specimen)
                }
                
            }
            
        }
        
        task.resume()
    }
    
    func notesPostUrl(actionType: ActionType, specimen: Specimen) -> String{
        self.notesTextView.resignFirstResponder()
        guard let user = UserSession.signedInUser else{
            self.showAlert(title: "Error!", message: "User Signed out, Please Login in!")
            UserSession.logOutUser()
            self.dismiss(animated: true, completion: nil)
            return ""
        }
        switch actionType
        {
        case .Accessioning:
            return baseUrl + "accessioning?UserId=\(user.userId)&InternalId=\(specimen.internalId)&CaseNo=\(specimen.caseNo)&Notes=\(self.notesTextView.text!)"
        case .Grossing:
            return baseUrl + "grossing?UserId=\(user.userId)&InternalId=\(specimen.specimenId)&GrossingId=\(specimen.grossingId)&CaseNo=\(specimen.caseNo)&Notes=\(self.notesTextView.text!)"
        case .Embedding:
            return baseUrl + "embedding?UserId=\(user.userId)&InternalId=\(specimen.specimenId)&EmbeddingId=\(specimen.embeddingId)&CaseNo=\(specimen.caseNo)&Notes=\(self.notesTextView.text!)"
        case .Microtome:
            return baseUrl + "microtome?UserId=\(user.userId)&InternalId=\(specimen.specimenId)&MicrotomeId=\(specimen.microtomeId)&CaseNo=\(specimen.caseNo)&Notes=\(self.notesTextView.text!)"
        case .Staining:
            return baseUrl + "staining?UserId=\(user.userId)&InternalId=\(specimen.specimenId)&StainingId=\(specimen.stainingId)&CaseNo=\(specimen.caseNo)&Notes=\(self.notesTextView.text!)"
        case .QA:
            return baseUrl + "qa?UserId=\(user.userId)&InternalId=\(specimen.specimenId)&QAId=\(specimen.qaId)&CaseNo=\(specimen.caseNo)&Notes=\(self.notesTextView.text!)"
        }

    }

}

