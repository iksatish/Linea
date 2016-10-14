//
//  BaseViewController.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/5/16.
//  Copyright © 2016 DSIG. All rights reserved.
//
enum ActionType:String
{
    case Accessioning = "Accessioning"
    case Grossing = "Grossing"
    case Embedding = "Embedding"
    case Microtome = "Micotome"
    case Staining = "Staining"
    case QA = "QA"
    
    static let allActions = [Accessioning, Grossing, Embedding, Microtome, Staining, QA]
}

import UIKit

class BaseViewController: UIViewController, DTDeviceDelegate, URLSessionDelegate {
    let scanner = DTDevices()
    var connectionStatebutton:UIButton?
    var caseno: String = ""
    var caseData: CaseData = CaseData()
    var actionType:ActionType = .Grossing
    let noCaseString = "Case Details Not Available"
    var selectedSpecimenId = ""
    
    override func viewDidLoad() {
        self.scanner.delegate = self
        self.scanner.connect()
        super.viewDidLoad()
        self.connectionStatebutton = UIButton(frame: CGRect(x: 5, y: 0, width: 22, height: 22))
        self.connectionStatebutton?.layer.cornerRadius = 11
        self.connectionState(self.scanner.connstate)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.connectionStatebutton!)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let _ = UserSession.signedInUser else{
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.present(loginVC, animated: true, completion: nil)
            return
        }
    }
    
    func barcodeData(_ barcode: String!, type: Int32) {
        self.handleDataSourceUpdate(resultString: barcode)
        self.caseno = barcode
        self.getDataForActionType(actionType: .Grossing, caseno: barcode)
        
    }
    
    func getDataForActionType(actionType: ActionType, caseno: String)
    {
        let urlText = self.urlForActionType(actionType: actionType) + "?caseno=\(caseno)"
        
        let url = URL(string: urlText.addingPercentEscapes(using: String.Encoding.utf8)!)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        self.showProgressView(title: "Loading Data", withDetailText: "")
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
                }
                guard let _ = data, let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else
                {
                    DispatchQueue.main.async {
                        self.showAlert(title: "No Case Found", message: "")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.parseDataFor(dataObj: jsonData)
                }
                
            }
            catch{
                DispatchQueue.main.async {
                    self.showAlert(title: "Oops!", message: "There are no records for case no: \(caseno).")
                }
                
            }
            guard let _ = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString)
            DispatchQueue.main.async {
 //               self.navigationController?.popToRootViewController(animated: false)
 //               self.performSegue(withIdentifier: "showdetailsegue", sender: self)
            }
        }
        
        task.resume()
    }
    
    func handleDataForActionType()
    {
        
    }
    
    func handleErrorForActionType()
    {
        
    }
    func urlForActionType(actionType: ActionType) -> String
    {
        var actionhandler = ""
        switch actionType
        {
        case .Accessioning:
            actionhandler = "accessioning"
        case .Grossing:
            actionhandler = "grossing"
        case .Embedding:
            actionhandler = "embedding"
        case .Microtome:
            actionhandler = "microtome"
        case .Staining:
            actionhandler = "staining"
        case .QA:
            actionhandler = "qa"
        }
        return "\(baseUrl)\(actionhandler)"
    }
    
    func handleDataSourceUpdate(resultString: String)
    {
     //   let resultInfo = NSDictionary()
        
    }
    func connectionState(_ state: Int32) {
        var color = UIColor.green
        if state == 0
        {
            color = UIColor.red
        }else if state == 1
        {
            color = UIColor.yellow
        }
        self.connectionStatebutton?.backgroundColor = color
        
    }
    

    func getDataForSpecimen(specimen: Specimen, forActionType actionType:ActionType) -> String{
        var dataString = ""
        switch actionType{
        case .Grossing, .Embedding, .Microtome:
            dataString += "Specimen Code: \(specimen.specimenCode) \n"
            dataString += "Specimen: \(specimen.specimenTitle) \n"
            dataString += "Cassette: \(specimen.cassette)"
        case .Accessioning:
            dataString += "Specimen Code: \(specimen.specimenCode) \n"
            dataString += "Site Name: \(specimen.siteName) \n"
            dataString += "Tissue: \(specimen.tissue) \n"
            dataString += "Procedure: \(specimen.procedure) \n"
            dataString += "Number of Cassettes: \(specimen.numberOfCassettes) \n"
            dataString += "Number of Slides: \(specimen.numberOfSlides) "
        case .QA, .Staining:
            dataString += "Specimen Code: \(specimen.specimenCode) \n"
            dataString += "Specimen: \(specimen.specimenTitle) \n"
            dataString += "Slide: \(specimen.slide) "
            
        }
        return dataString
    }
    
    func getCaseData(caseData:CaseData) -> String
    {
        var dataString = ""
        dataString += "Case No: \(caseData.caseno) \n"
        dataString += "First Name: \(caseData.firstName) \n"
        dataString += "Last Name: \(caseData.lastName) \n"
        dataString += "Date of Birth: \(caseData.dob) \n"
        dataString += "Received Date: \(caseData.receivedDate) \n"
        dataString += "Accessioned Date: \(caseData.accessionedDate)"
        return dataString
    }
    
    func convertDate(dateString: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let dateFromString = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            return dateFormatter.string(from: dateFromString)
        
        }
        return ""
    }

    func convertDateTime(dateString: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let dateFromString = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            return dateFormatter.string(from: dateFromString)
            
        }
        return ""
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,credential);
        }
        
    }
    
    
    func parseDataFor(dataObj:NSDictionary?)
    {
        let caseData = CaseData()
        if let accessionObj = dataObj?.value(forKey: "accessionObj") as? NSDictionary
        {
            if let caseno = accessionObj.value(forKey: "CaseNo") as? String{
                caseData.caseno = caseno
            }
            if let firstName = accessionObj.value(forKey: "First_Name") as? String{
                caseData.firstName = firstName
            }
            if let lastName = accessionObj.value(forKey: "Last_Name") as? String{
                caseData.lastName = lastName
            }
            if let dob = accessionObj.value(forKey: "DOB") as? String{
                caseData.dob = convertDate(dateString: dob)
            }
            if let dateReceived = accessionObj.value(forKey: "Date_Specimen_Received") as? String{
                caseData.receivedDate = convertDate(dateString: dateReceived)
            }
            if let dateAccessioned = accessionObj.value(forKey: "Date_Accessioned") as? String{
                caseData.accessionedDate = convertDate(dateString: dateAccessioned)
            }
            if let grossingInfo = dataObj?.value(forKey: "grossingInfo") as? [AnyObject]
            {
                var specimens:[Specimen] = []
                for grossData in grossingInfo
                {
                    let specimen = Specimen()
                    if let title = grossData.value(forKey: "Specimen") as? String{
                        specimen.specimenTitle = title
                    }
                    if let code = grossData.value(forKey: "Specimen_Code") as? String{
                        specimen.specimenCode = code
                    }
                    if let cassette = grossData.value(forKey: "Cassette_Key") as? String{
                        specimen.cassette = cassette
                    }
                    if let verifiedFlag = grossData.value(forKey: "Verification_Flag") as? Bool{
                        specimen.isVerified = verifiedFlag
                    }
                    if let internalId = grossData.value(forKey: "Grossing_Id") as? Int{
                        specimen.grossingId = "\(internalId)"
                    }
                    if let specimenId = grossData.value(forKey: "Specimen_Id") as? String{
                        specimen.specimenId = specimenId
                    }

                    specimen.caseNo = caseData.caseno
                    specimens.append(specimen)
                }
                caseData.specimens = specimens
            }
            if let specimenInfo = dataObj?.value(forKey: "specimenInfo") as? [AnyObject]
            {
                var specimens:[Specimen] = []
                for specimenData in specimenInfo
                {
                    let specimen = Specimen()
                    if let siteId = specimenData.value(forKey: "Site_Id") as? String{
                        specimen.siteName = siteId
                    }
                    if let code = specimenData.value(forKey: "Specimen_Code") as? String{
                        specimen.specimenCode = code
                    }
                    if let tissue = specimenData.value(forKey: "TissueId") as? String{
                        specimen.tissue = tissue
                    }
                    if let procedure = specimenData.value(forKey: "ProcedureId") as? String{
                        specimen.procedure = procedure
                    }
                    if let cassettesCount = specimenData.value(forKey: "Number_Of_Cassettes") as? Int{
                        specimen.numberOfCassettes = "\(cassettesCount)"
                    }
                    if let slidesCount = specimenData.value(forKey: "Number_Of_Slides") as? Int{
                        specimen.numberOfSlides = "\(slidesCount)"
                    }
                    if let internalId = specimenData.value(forKey: "internalID") as? String{
                        specimen.internalId = internalId
                    }
                    if let specimenId = specimenData.value(forKey: "Specimen_Id") as? Int{
                        specimen.specimenId = "\(specimenId)"
                    }

                    specimen.caseNo = caseData.caseno
                    specimens.append(specimen)
                }
                caseData.specimens = specimens
            }
            if let embeddingInfo = dataObj?.value(forKey: "embeddingInfo") as? [AnyObject]
            {
                var specimens:[Specimen] = []
                for embeddingData in embeddingInfo
                {
                    let specimen = Specimen()
                    if let title = embeddingData.value(forKey: "Specimen") as? String{
                        specimen.specimenTitle = title
                    }
                    if let code = embeddingData.value(forKey: "Specimen_Code") as? String{
                        specimen.specimenCode = code
                    }
                    if let cassette = embeddingData.value(forKey: "Cassette_Key") as? String{
                        specimen.cassette = cassette
                    }
                    if let verifiedFlag = embeddingData.value(forKey: "Verification_Flag") as? Bool{
                        specimen.isVerified = verifiedFlag
                    }
                    if let embeddingId = embeddingData.value(forKey: "Embedded_Id") as? Int{
                        specimen.embeddingId = "\(embeddingId)"
                    }
                    if let specimenId = embeddingData.value(forKey: "Specimen_Id") as? String{
                        specimen.specimenId = specimenId
                    }

                    specimen.caseNo = caseData.caseno
                    specimens.append(specimen)
                }
                caseData.specimens = specimens
            }
            if let microTomeInfo = dataObj?.value(forKey: "microTomeInfo") as? [AnyObject]
            {
                var specimens:[Specimen] = []
                for microTomeData in microTomeInfo
                {
                    let specimen = Specimen()
                    if let title = microTomeData.value(forKey: "Specimen") as? String{
                        specimen.specimenTitle = title
                    }
                    if let code = microTomeData.value(forKey: "Specimen_Code") as? String{
                        specimen.specimenCode = code
                    }
                    if let cassette = microTomeData.value(forKey: "Cassette_Key") as? String{
                        specimen.cassette = cassette
                    }
                    if let verifiedFlag = microTomeData.value(forKey: "Verification_Flag") as? Bool{
                        specimen.isVerified = verifiedFlag
                    }
                    if let microtomeId = microTomeData.value(forKey: "Microtome_Id") as? Int{
                        specimen.microtomeId = "\(microtomeId)"
                    }
                    if let specimenId = microTomeData.value(forKey: "Specimen_Id") as? String{
                        specimen.specimenId = specimenId
                    }

                    specimen.caseNo = caseData.caseno
                    specimens.append(specimen)
                }
                caseData.specimens = specimens
            }
            if let stainingInfo = dataObj?.value(forKey: "stainingInfo") as? [AnyObject]
            {
                var specimens:[Specimen] = []
                for stainingData in stainingInfo
                {
                    let specimen = Specimen()
                    if let title = stainingData.value(forKey: "Specimen") as? String{
                        specimen.specimenTitle = title
                    }
                    if let code = stainingData.value(forKey: "Specimen_Code") as? String{
                        specimen.specimenCode = code
                    }
                    if let slide = stainingData.value(forKey: "Slide_Key") as? String{
                        specimen.slide = slide
                    }
                    if let verifiedFlag = stainingData.value(forKey: "Verification_Flag") as? Bool{
                        specimen.isVerified = verifiedFlag
                    }
                    if let stainingId = stainingData.value(forKey: "Slide_Id") as? Int{
                        specimen.stainingId = "\(stainingId)"
                    }
                    if let specimenId = stainingData.value(forKey: "Specimen_Id") as? String{
                        specimen.specimenId = specimenId
                    }

                    specimen.caseNo = caseData.caseno
                    specimens.append(specimen)
                }
                caseData.specimens = specimens
            }
            if let QAInfo = dataObj?.value(forKey: "QAInfo") as? [AnyObject]
            {
                var specimens:[Specimen] = []
                for qaData in QAInfo
                {
                    let specimen = Specimen()
                    if let title = qaData.value(forKey: "Specimen") as? String{
                        specimen.specimenTitle = title
                    }
                    if let code = qaData.value(forKey: "Specimen_Code") as? String{
                        specimen.specimenCode = code
                    }
                    if let slide = qaData.value(forKey: "Slide_Key") as? String{
                        specimen.slide = slide
                    }
                    if let qaId = qaData.value(forKey: "QA_Slide_Id") as? Int{
                        specimen.qaId = "\(qaId)"
                    }
                    if let specimenId = qaData.value(forKey: "Specimen_Id") as? String{
                        specimen.specimenId = specimenId
                    }

                    specimen.caseNo = caseData.caseno
                    specimens.append(specimen)
                }
                caseData.specimens = specimens
            }
        }
        self.caseData = caseData
        self.openNextView(caseData: caseData)
    }
    
    func openNextView(caseData:CaseData)
    {
        
    }
    
    func checkNilValues(data:AnyObject?) -> String
    {
        guard let _ = data?.string else{
            return ""
        }
        /*
        if data!.isKind(of: String) || data!.isKind(of: Int)
        {
            return data!.string
        }
        else */
        if data!.isKind(of: NSDate.self)
        {
            return data!.string
        }
        else
        {
            return data!.string
        }
    }
    
    func getNotesForSpecimen(specimen: Specimen)
    {
        let urlText = self.notesGETUrl(actionType: self.actionType, specimen: specimen)
        let url = URL(string: urlText.addingPercentEscapes(using: String.Encoding.utf8)!)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        self.showProgressView(title: "Fetching Notes", withDetailText: "")
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
                guard let _ = data, let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [AnyObject] else
                {
                    DispatchQueue.main.async {
                        self.showNotes(notes: [Notes()], specimen: specimen)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.parseNotesData(jsonData: jsonData, specimen: specimen)
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

    func parseNotesData(jsonData: [AnyObject], specimen: Specimen)
    {
        var notes:[Notes] = []
        
        for notesData in jsonData{
            let notesObj = Notes()
            if let notesId = notesData.value(forKey: "NotesId") as? Int{
                notesObj.notesId = "\(notesId)"
            }
            if let notes = notesData.value(forKey: "Notes") as? String{
                notesObj.notes = notes
            }
            if let createdDate = notesData.value(forKey: "Created_DtTm") as? String{
                notesObj.createdTime = self.convertDateTime(dateString: createdDate)
            }
            notes.append(notesObj)
            
        }
        self.showNotes(notes: notes, specimen: specimen)

        
    }
    
    func showNotes(notes: [Notes], specimen: Specimen)
    {
        
    }
    
    
    func notesGETUrl(actionType:ActionType, specimen:Specimen) -> String{
        switch actionType
        {
        case .Accessioning:
            return baseUrl + "accessioning?SpecimenInternalId=\(specimen.internalId)&CaseNo=\(specimen.caseNo)"
        case .Grossing:
            return baseUrl + "grossing?GrossingId=\(specimen.grossingId)"
        case .Embedding:
            return baseUrl + "embedding?EmbeddingId=\(specimen.embeddingId)"
        case .Microtome:
            return baseUrl + "microtome?MicrotomeId=\(specimen.microtomeId)"
        case .Staining:
            return baseUrl + "staining?StainingId=\(specimen.stainingId)"
        case .QA:
            return baseUrl + "qa?QAId=\(specimen.qaId)"
        }
    }
    
    func markSpecimenAsVerified(actionType: ActionType, specimen: Specimen)
    {
        let urlText = self.verifypPOSTUrl(actionType: self.actionType, specimen: specimen)
        let url = URL(string: urlText.addingPercentEscapes(using: String.Encoding.utf8)!)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        self.showProgressView(title: "Updating Status", withDetailText: "")
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
                    self.refreshData()
                }
                
            }
            catch{
                DispatchQueue.main.async {
                    self.showAlert(title: "Service Issue", message: "Please try again!")
                    return

                }
                
            }
            
        }
        
        task.resume()
    }
    
    func verifypPOSTUrl(actionType: ActionType, specimen: Specimen) -> String
    {
        guard let user = UserSession.signedInUser else{
            self.showAlert(title: "Error!", message: "User Signed out, Please Login in!")
            UserSession.logOutUser()
            self.dismiss(animated: true, completion: nil)
            return ""
        }

        switch actionType
        {
        case .Grossing:
            return baseUrl + "grossing?AccessionNo=\(specimen.grossingId)&UserName=\(user.userName)&UserId=\(user.userId)&gsid=\(specimen.grossingId),\(specimen.specimenId)"
        case .Embedding:
            return baseUrl + "embedding?AccessionNo=\(specimen.embeddingId)&UserName=\(user.userName)&UserId=\(user.userId)&eid=\(specimen.embeddingId),\(specimen.specimenId)"
        case .Staining:
            return baseUrl + "staining?AccessionNo=\(specimen.stainingId)&UserName=\(user.userName)&UserId=\(user.userId)&sid=\(specimen.grossingId),\(specimen.specimenId)"
        case .QA:
            return baseUrl + "qa?AccessionNo=\(specimen.grossingId)&UserName=\(user.userName)&UserId=\(user.userId)&qaid=\(specimen.grossingId),\(specimen.specimenId)"
        default:
            return ""
        }

    }
    
    func refreshData()
    {
        
    }
}
