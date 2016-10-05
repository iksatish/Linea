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
    static var loggedInUser: User?
    
    class func isSessionStillValid() -> Bool
    {
        return true
    }
    
    
}

class User:NSObject{
    var userName: String?
    var firstName: String?
    var lastName: String?
}
