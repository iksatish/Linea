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
        progressView.detailsLabel.text = detailtext
    }
    
    func hideProgressView()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        MBProgressHUD.hide(for: self.view, animated: true)
        
    }
    
}
