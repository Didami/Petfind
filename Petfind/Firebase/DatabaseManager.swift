//
//  DatabaseManager.swift
//  Petfind
//
//  Created by Didami on 23/01/22.
//

import Foundation
import Firebase
import FirebaseDatabase

#warning("Consider deleting this file, code using FirestoreManager now :)")
final class DatabaseManager {
    
    public static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

// MARK: - Account
extension DatabaseManager {
    
    public func insertUser(_ user: User,
                           completion: @escaping (_ success: Bool) -> ()) {
        
        guard let userId = user.userId, let email = user.email, let location = user.location, let username = user.username else {
            completion(false)
            return
        }
        
        // TODO: - profile icon upload
        let x = 1
        
        let userDict = [
            "email": email,
            "location": location,
            "username": username,
            "profileIcon": x
        ] as [String: AnyObject]
        
        database.child("users").child(userId).setValue(userDict) { err, _ in
            
            if err != nil {
                completion(false)
                return
            }
            
            currentUserUid = userId
            
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    public func updateBio(for userId: String, bio: String, completion: @escaping (_ success: Bool) -> ()) {
        
        database.child("users").child(userId).child("bio").setValue(bio) { err, _ in
            
            if err != nil {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    public func fetchUsersStarting(with lastUserId: String? = nil, limit: UInt, completion: @escaping (Result<[User], Error>) -> Void) {
        
        var users = [User]()

        var query = database.child("users").queryOrderedByKey()

        if lastUserId != nil {
            query = query.queryStarting(afterValue: lastUserId)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).async {
            
            query.queryLimited(toFirst: limit).observeSingleEvent(of: .value, with: { snap in

                guard let snapshot = snap.children.allObjects as? [DataSnapshot] else {
                    completion(.failure(DatabaseErrors.failedToFetch))
                    return
                }
                
                if snapshot.isEmpty {
                    semaphore.signal()
                    return
                }

                users.removeAll()
                
                for data in snapshot {

                    if let dict = data.value as? [String: AnyObject] {

                        let user = User(dict: dict, uid: data.key)
                        users.append(user)
                        semaphore.signal()
                    }
                }
                
            }, withCancel: nil)
            
            // wait
            semaphore.wait()
            
            DispatchQueue.main.async {
                completion(.success(users))
            }
        }
    }
    
    public func getUserInfoFrom(_ userId: String?, completion: @escaping (_ user: User?) -> ()) {
        
        if let uid = userId {
            
            database.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
                
                if let dict = snapshot.value as? [String: AnyObject] {
                    let user = User(dict: dict, uid: uid)
                    
                    DispatchQueue.main.async {
                        completion(user)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    public func getUserDictFrom(_ userId: String?, completion: @escaping (_ user: [String: AnyObject]) -> ()) {
        
        if let uid = userId {
            
            database.child("users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
                
                if let dict = snapshot.value as? [String: AnyObject] {
                    completion(dict)
                }
                
            }, withCancel: nil)
        }
    }
    
    public func setUserAdmin(_ isAdmin: Bool, userId: String) {
        
        let ref = database.child("users").child(userId).child("isAdmin")
        
        if isAdmin {
            ref.setValue(true)
        } else {
            ref.removeValue()
        }
    }
}

// MARK: - Pets
extension DatabaseManager {
    
    public func insertPet(with dict: [String: AnyObject], images: [UIImage], completion: @escaping (_ success: Bool) -> ()) {
        
        let petId = UUID().uuidString
        
        StorageManager.shared.uploadPetImages(images, petId: petId) { result in
            
            switch result {
            case .success(let imagesUrl):
                
                guard let type = dict[PetVars.type.rawValue] as? String else { return }
                let ref = self.database.child("pets").child(type.lowercased()).child(petId)
                    
                ref.setValue(dict) { err, _ in
                    
                    if err != nil {
                        completion(false)
                        return
                    }
                    
                    ref.child("imagesUrl").setValue(imagesUrl) { err, _ in
                        
                        if err != nil {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
                
            case .failure(_):
                print("err")
                return
            }
        }
    }
    
    public enum DatabaseErrors: Error {
        case failedToUpload
        case failedToFetch
        case invalidUid
    }
    
    public func fetchAllPets(completion: @escaping (Result<[Pet], Error>) -> Void) {
        
        var pets = [Pet]()
        
        let group = DispatchGroup()
        
        database.child("pets").observeSingleEvent(of: .value, with: { snap in
            
            guard let snapshot = snap.children.allObjects as? [DataSnapshot] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            pets.removeAll()
            for data in snapshot {
                group.enter()
                
                if let dict = data.value as? [String: AnyObject] {
                    pets.append(Pet(dict: dict, petId: data.key))
                }
                
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(.success(pets))
            }
            
        }, withCancel: nil)
    }
    
    public func fetchUserPets(with type: String, completion: @escaping (_ result: Result<[Pet], Error>) -> Void) {
        
        guard let currentUserUid = currentUserUid else {
            return
        }
        
        var pets = [Pet]()
        
        let query = database.child("pets").child(type.lowercased()).queryOrdered(byChild: currentUserUid).queryEqual(toValue: true)
        
        let group = DispatchGroup()
        
        query.observeSingleEvent(of: .value, with: { snap in
            
            guard let snapshot = snap.children.allObjects as? [DataSnapshot] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            pets.removeAll()
            
            for data in snapshot {
                group.enter()
                
                if let dict = data.value as? [String: AnyObject] {
                    pets.append(Pet(dict: dict, petId: data.key))
                }
                
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(.success(pets))
            }
            
        }, withCancel: nil)
    }
    
    public func fetchPetsStarting(with lastPetId: String? = nil, limit: UInt, type: String, completion: @escaping (Result<[Pet], Error>) -> Void) {

        guard let currentUserUid = currentUserUid else {
            return
        }
        
        var pets = [Pet]()

        var query = database.child("pets").child(type.lowercased()).queryOrdered(byChild: currentUserUid)

        if lastPetId != nil {
            query = query.queryStarting(atValue: nil, childKey: lastPetId)
        } else {
            query = query.queryEqual(toValue: nil)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).async {
            
            query.queryLimited(toFirst: limit).observeSingleEvent(of: .value, with: { snap in

                guard let snapshot = snap.children.allObjects as? [DataSnapshot] else {
                    completion(.failure(DatabaseErrors.failedToFetch))
                    return
                }
                
                if snapshot.isEmpty {
                    semaphore.signal()
                    return
                }

                pets.removeAll()
                
                for data in snapshot {

                    if let dict = data.value as? [String: AnyObject] {

                        let pet = Pet(dict: dict, petId: data.key)
                        pets.append(pet)
                        semaphore.signal()
                    }
                }
                
            }, withCancel: nil)
            
            // wait before filtering
            semaphore.wait()
            
            print("PETS: \(pets)")
            // FILTERING
            PetFilterManager.shared.filterPets(pets) { filtered in
                
                DispatchQueue.main.async {
                    print("FILTERED: \(filtered)")
                    completion(.success(filtered))
                }
            }
        }
    }
    
    public func likePetWith(id: String, type: String, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let currentUserUid = currentUserUid else {
            completion(false)
            return
        }
        
        database.child("pets").child(type.lowercased()).child(id).child("likes").child(currentUserUid).setValue(1) { [weak self] err, _ in
            
            if err != nil {
                completion(false)
                return
            }
            
            self?.database.child("users").child(currentUserUid).child("liked").child(id).setValue(1) { err, _ in
                
                if err != nil {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    public func getLikesFromPet(with id: String, type: String, competion: @escaping (_ result: Result<[User], Error>) -> Void) {
        
        var users = [User]()
        
        getLikesIdsFromPet(with: id, type: type.lowercased()) { [weak self] result in
            
            users.removeAll()
            
            let group = DispatchGroup()
            
            switch result {
            case .success(let uids):
                
                for uid in uids {
                    group.enter()
                    
                    self?.getUserInfoFrom(uid) { user in
                        
                        guard let user = user else {
                            competion(.failure(DatabaseErrors.failedToFetch))
                            return
                        }
                        
                        users.append(user)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    competion(.success(users))
                }
                
            case .failure(let err):
                competion(.failure(err))
            }
        }
    }
    
    private func getLikesIdsFromPet(with id: String, type: String, completion: @escaping (_ result: Result<[String], Error>) -> Void) {
        
        var likes = [String]()
        
        let group = DispatchGroup()
        
        database.child("pets").child(type).child(id).child("likes").observeSingleEvent(of: .value, with: { snap in
            
            likes.removeAll()
            guard let snapshot = snap.children.allObjects as? [DataSnapshot] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            for data in snapshot {
                group.enter()
                likes.append(data.key)
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(.success(likes))
            }
            
        }, withCancel: nil)
    }
    
    public func getLikedPetsIdsFromUser(with id: String, completion: @escaping (_ ids: [String]) -> ()) {
        
        var petsIds = [String]()
        
        let group = DispatchGroup()
        
        database.child("users").child(id).child("liked").observeSingleEvent(of: .value, with: { snap in
            
            petsIds.removeAll()
            guard let snapshot = snap.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            for data in snapshot {
                group.enter()
                petsIds.append(data.key)
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(petsIds)
                return
            }
            
        }, withCancel: nil)
    }
    
    public func removeLikedPetFromUser(with id: String, petId: String, petType: String, completion: @escaping (_ success: Bool) -> ()) {
        
        database.child("pets").child(petType.lowercased()).child(petId).child("likes").child(id).removeValue { err, _ in
            
            if err != nil {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}

// MARK: - Messages
extension DatabaseManager {
    
    public func sendMessage(to userId: String, text: String, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let currentUserId = currentUserUid else {
            completion(false)
            return
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let messageDict = [
            MessageVars.text.rawValue: text,
            MessageVars.toId.rawValue: userId,
            MessageVars.fromId.rawValue: currentUserId,
            MessageVars.timestamp.rawValue: timestamp
        ] as [String: AnyObject]
        
        database.child("messages").childByAutoId().setValue(messageDict) { [weak self] err, ref in
            
            if err != nil {
                completion(false)
                return
            }
            
            guard let messageId = ref.key else { return }
            
            self?.database.child("user-messages").child(currentUserId).child(messageId).setValue(1) { [weak self] err, _ in
                
                if err != nil {
                    completion(false)
                    return
                }
                
                self?.database.child("user-messages").child(userId).child(messageId).setValue(1) { err, _ in
                    
                    if err != nil {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    public func fetchMessages(for userId: String, completion: @escaping (_ result: Result<[String: Message], Error>) -> Void) {
        
        var messagesDict = [String: Message]()
        
        messagesDict.removeAll()
        
        database.child("user-messages").child(userId).observe(.childAdded, with: { [weak self] snapshot in
                
            let messageId = snapshot.key
                
            self?.database.child("messages").child(messageId).observeSingleEvent(of: .value, with: { snapshot in
                
                if let dict = snapshot.value as? [String: AnyObject] {

                    let message = Message(dict: dict)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        
                        DispatchQueue.main.async {
                            
                            messagesDict[chatPartnerId] = message
                            completion(.success(messagesDict))
                        }
                    }
                    
                }
                
            }, withCancel: nil)
                
        }, withCancel: nil)
    }
    
    public func fetchMessagesWith(_ chatPartnerId: String, completion: @escaping (_ result: Result<[Message], Error>) -> Void) {
        
        guard let currentUserId = currentUserUid else {
            completion(.failure(DatabaseErrors.invalidUid))
            return
        }
        
        var messages = [Message]()
        
        messages.removeAll()
        database.child("user-messages").child(currentUserId).observe(.childAdded, with: { [weak self] snapshot in
            
            self?.database.child("messages").child(snapshot.key).observeSingleEvent(of: .value, with: { snapshot in
                
                if let dict = snapshot.value as? [String: AnyObject] {
                    
                    let message = Message(dict: dict)
                    
                    if message.chatPartnerId() == chatPartnerId {
                        
                        messages.append(message)
                        
                        completion(.success(messages))
                        
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */

// #warning("IGNORE")
//
//
/*
 01010011 01101001 01100101 01101101 01110000 01110010 01100101 00100000 01110100 01110101 01110110 01100101 00100000 01101100 01100001 00100000 01101001 01100100 01100101 01100001 00100000 01100100 01100101 00100000 01100101 01110011 01100011 01101111 01101110 01100100 01100101 01110010 00100000 01110101 01101110 00100000 01101101 01100101 01101110 01110011 01100001 01101010 01100101 00100000 01100101 01101110 00100000 01100101 01101100 00100000 01100011 11000011 10110011 01100100 01101001 01100111 01101111 00101110 01010011 01100101 00100000 01110001 01110101 01100101 00100000 01101110 01110101 01101110 01100011 01100001 00100000 01101100 01100101 01100101 01110010 11000011 10100001 01110011 00100000 01100101 01110011 01110100 01101111 00100000 01110000 01100101 01110010 01101111 00100000 00101110 00101110 00101110 01010000 01101111 01110010 00100000 01101101 11000011 10100001 01110011 00100000 01110001 01110101 01100101 00100000 01101110 01110101 01100101 01110011 01110100 01110010 01101111 01110011 00100000 01100011 01100001 01101101 01101001 01101110 01101111 01110011 00100000 01110011 01100101 00100000 01101000 01100001 01111001 01100001 01101110 00100000 01110011 01100101 01110000 01100001 01110010 01100001 01100100 01101111 00100000 01111001 00100000 01101000 01100001 01111001 01100001 01110011 00100000 01100011 01100001 01101101 01100010 01101001 01100001 01100100 01101111 00111011 00100000 01100101 01110010 01100101 01110011 00100000 01101001 01101101 01110000 01101111 01110010 01110100 01100001 01101110 01110100 01100101 00101100 00100000 01110011 01110101 01110000 01100101 01110010 01101000 01100101 01110010 01101111
*/
