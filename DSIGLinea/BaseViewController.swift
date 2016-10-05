//
//  BaseViewController.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/5/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, DTDeviceDelegate {
    let scanner = DTDevices()
    
    override func viewDidLoad() {
        self.scanner.delegate = self
        self.scanner.connect()
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let _ = UserSession.loggedInUser else{
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.present(loginVC, animated: true, completion: nil)
            return
        }
    }
    
    func barcodeData(_ barcode: String!, type: Int32) {
        let alertController = UIAlertController(title: "barcode", message: barcode, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}
