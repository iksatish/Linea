//
//  Constants.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/6/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import Foundation

var baseUrl:String {
    let defaults = UserDefaults.standard
    if let base = defaults.value(forKey: baseUrlKey) as? String{
        return base
    }else{
        return "https://apitracking.apeasy.com/api/"
    }
}
let baseUrlKey = "baseUrlKey"
let kLoggedInKey = "kLoggedInUser"
