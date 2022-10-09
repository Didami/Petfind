//
//  Pet.swift
//  Petfind
//
//  Created by Didami on 28/01/22.
//

import UIKit

enum PetType: String {
    case Dog
    case Cat
    case Other
}

enum Gender: String {
    case Male
    case Female
}

class Pet: NSObject {
    
    @objc var name: String?
    @objc var type: String?
    @objc var breed: String?
    @objc var gender: String?
    @objc var age: String?
    
    @objc var imagesUrl: [String]?
    
    @objc var petId: String?
    @objc var userId: String?
    
    init(dict: [String: AnyObject], petId: String) {
        
        self.name = dict[PetVars.name.rawValue] as? String
        self.type = dict[PetVars.type.rawValue] as? String
        self.breed = dict[PetVars.breed.rawValue] as? String
        self.gender = dict[PetVars.gender.rawValue] as? String
        self.age = dict[PetVars.age.rawValue] as? String
        
        self.imagesUrl = dict[PetVars.imagesUrl.rawValue] as? [String]
        
        self.userId = dict[PetVars.userId.rawValue] as? String
        self.petId = petId
    }
}

enum PetVars: String {
    case name
    case type
    case location
    case breed
    case gender
    case age
    case imagesUrl
    case userId
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
