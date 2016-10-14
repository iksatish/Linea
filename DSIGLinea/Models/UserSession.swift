//
//  UserSession.swift
//  DSIGLinea
//
//  Created by Satish Kumar R Kancherla on 10/5/16.
//  Copyright © 2016 DSIG. All rights reserved.
//

import Foundation

class UserSession:NSObject
{
    static var signedInUser: User?
    
    class func isUserLoggedIn() -> Bool
    {
        if let _ = UserDefaults.value(forKey: kLoggedInKey){
            return true
        }
        return false
    }
    
    class func loggedInUser(user: User)
    {
        self.signedInUser = user
        UserDefaults.standard.set("loggedIn", forKey: kLoggedInKey)
        UserDefaults.standard.synchronize()
    }
    
    class func logOutUser()
    {
        self.signedInUser = nil
        
        UserDefaults.standard.removeObject(forKey: kLoggedInKey)
    }
    
}

class User:NSObject{
    var userName = ""
    var firstName: String?
    var lastName: String?
    var isAdmin = false
    var userId = ""
}
