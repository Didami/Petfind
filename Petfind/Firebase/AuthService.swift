//
//  AuthService.swift
//  Petfind
//
//  Created by Didami on 22/01/22.
//

import Foundation
import Firebase
import FirebaseAuth

public var currentUserUid = Auth.auth().currentUser?.uid

public enum AuthErrors: Error {
    case failedToCreateUser
}

public func authWith(email: String, password: String, completion: @escaping (_ success: Bool) -> ()) {
    
    Auth.auth().signIn(withEmail: email, password: password) { result, err in
        
        if err != nil {
            completion(false)
            return
        }
        
        currentUserUid = result?.user.uid
        completion(true)
    }
}

func createUserWith(email: String, password: String, username: String, location: String, completion: @escaping (_ result: Result<User, Error>) -> ()) {
    
    Auth.auth().createUser(withEmail: email, password: password) { result, err in
        
        if err != nil {
            completion(.failure(AuthErrors.failedToCreateUser))
            return
        }
        
        guard let uid = result?.user.uid else {
            completion(.failure(AuthErrors.failedToCreateUser))
            return
        }
        
        let dict = [
            "email": email,
            "username": username.lowercased(),
            "location": location
        ] as [String: AnyObject]
        
        completion(.success(User(dict: dict, uid: uid)))
    }
}

public func signOut(completion: @escaping (_ success: Bool) -> ()) {
    
    do {
        
        try Auth.auth().signOut()
        
    } catch {
        completion(false)
    }
    
    completion(true)
}

public func isUserAdmin(userId: String?, completion: @escaping (_ isAdmin: Bool) -> ()) {
    
    guard let uid = userId else {
        completion(false)
        return
    }
    
    FirestoreManager.shared.getUserDictFrom(uid) { result in
        
        switch result {
            
        case .success(let dict):
            
            guard let isAdmin = dict["isAdmin"] as? Bool else {
                completion(false)
                return
            }
            
            completion(isAdmin)
            
        case .failure(_):
            completion(false)
        }
    }
    
//    DatabaseManager.shared.getUserDictFrom(uid) { dict in
//
//        guard let isAdmin = dict["isAdmin"] as? Bool else {
//            completion(false)
//            return
//        }
//
//        completion(isAdmin)
//    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
