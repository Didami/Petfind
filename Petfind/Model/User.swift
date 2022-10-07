//
//  User.swift
//  Petfind
//
//  Created by Didami on 23/01/22.
//

import UIKit

class User: NSObject {
    
    @objc var email: String?
    @objc var username: String?
    @objc var profileIcon: NSNumber?
    @objc var location: String?
    @objc var bio: String?
    @objc var userId: String?
    
    init(dict: [String: AnyObject], uid: String) {
        
        self.email = dict["email"] as? String
        self.username = dict["username"] as? String
        self.profileIcon = dict["profileIcon"] as? NSNumber
        self.location = dict["location"] as? String
        self.bio = dict["bio"] as? String
        
        self.userId = uid
        
    }
}
