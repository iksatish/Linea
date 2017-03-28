//
//  LoginViewController.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/5/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, URLSessionDelegate {

    @IBOutlet weak var baseUrlTextField: UITextField!
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBtn.layer.cornerRadius = 3.0
        self.loginContainer.layer.cornerRadius = 10.0
        self.baseUrlTextField.text = baseUrl
    }

    @IBAction func doLogin(_ sender: UIButton) {
        self.makeLogin()
    }
    
    func makeLogin()
    {
        let defaults = UserDefaults.standard
        if let baseTxt = self.baseUrlTextField.text{
            defaults.set(baseTxt, forKey: baseUrlKey)
        }else{
            defaults.removeObject(forKey: baseUrlKey)
        }
        defaults.synchronize()
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        guard let userId = self.userNameTextField.text, let password = self.passwordTextField.text, userId.characters.count > 0, password.characters.count > 0 else
        {
            self.showAlert(title: "Oops!", message: "Please enter both id and password to continue!")
            return
        }
        
        let urlText = self.getLoginUrl()
        
        let url = URL(string: urlText.addingPercentEscapes(using: String.Encoding.utf8)!)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        self.showProgressView(title: "Logging In", withDetailText: "")
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
                let user = User()
                guard let _ = data, let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else
                {
                    self.showAlert(title: "Oops!", message: "Invalid Credentials, Please try again!")
                    return
                }
                DispatchQueue.main.async {
                    if let userId = jsonData.value(forKey: "UserName") as? String{
                        user.userName = userId
                    }
                    if let isAdmin = jsonData.value(forKey: "isAdming") as? Bool{
                        user.isAdmin = isAdmin
                    }
                    if let uid = jsonData.value(forKey: "UserId") as? Int{
                        user.userId = "\(uid)"
                    }
                    UserSession.loggedInUser(user: user)
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            catch{
                DispatchQueue.main.async {
                    self.showAlert(title: "Oops!", message: "Invalid Credentials, Please try again!")
                }
                
            }
            guard let _ = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
        }
        
        task.resume()
    }
    
    func getLoginUrl() -> String
    {
        return baseUrl + "login?UserName=\(self.userNameTextField.text!)&Password=\(self.passwordTextField.text!)"
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,credential);
        }
        
    }

}
