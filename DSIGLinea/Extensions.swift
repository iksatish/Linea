//
//  UIViewControllerExtension.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/5/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import Foundation

extension UIViewController{
    
    func showProgressView(title:String, withDetailText detailtext:String)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let progressView = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressView.label.text = title
        progressView.tintColor = UIColor.darkGray
        progressView.detailsLabel.text = detailtext
    }
    
    func hideProgressView()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        MBProgressHUD.hide(for: self.view, animated: true)
        
    }
    
    func showAlert(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


}

extension UITableView{

    func setupFooterView()
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
        view.backgroundColor = UIColor.clear
        self.tableFooterView = view
        
    }
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

