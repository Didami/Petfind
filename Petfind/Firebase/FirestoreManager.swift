//
//  FirestoreManager.swift
//  Petfind
//
//  Created by Didami on 21/03/22.
//

import Foundation
import Firebase
import FirebaseFirestore

// TODO: - Change database to firestore.

final class FirestoreManager {
    
    public static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    
    public enum FirestoreErrors: Error {
        case failedToUpload
        case failedToFetch
        case invalidUid
    }
}

// MARK: - Account
extension FirestoreManager {
    
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
        
        db.collection("users").document(userId).setData(userDict) { err in
            
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
        
        db.collection("users").document(userId).updateData([
            "bio": bio
        ]) { err in
            
            if err != nil {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    public func fetchUsersStarting(with lastUserId: String? = nil, limit: Int, completion: @escaping (Result<[User], Error>) -> Void) {
        
        var users = [User]()

        var query: Query = db.collection("users").order(by: FieldPath.documentID())

        if lastUserId != nil {
            query = query.start(after: [lastUserId!])
        }
        
        let semaph
        ore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).async {
            
            query.limit(to: limit).getDocuments(source: .default) { snap, err in
                
                if err != nil {
                    completion(.failure(FirestoreErrors.failedToFetch))
                    return
                }
                
                guard let snapshot = snap else {
                    completion(.failure(FirestoreErrors.failedToFetch))
                    return
                }
                
                if snapshot.isEmpty {
                    semaphore.signal()
                    return
                }
                
                for doc in snapshot.documents {
                    
                    if let dict = doc.data() as [String: AnyObject]? {
                        
                        let user = User(dict: dict, uid: doc.documentID)
                        users.append(user)
                        semaphore.signal()
                    }
                }
            }
            
            // wait
            semaphore.wait()
            
            DispatchQueue.main.async {
                completion(.success(users))
            }
        }
    }
    
    public func getUserInfoFrom(_ userId: String?, completion: @escaping(_ user: User?) -> ()) {
        
        if let uid = userId {
            
            var newUser: User?
            
            let semaphore = DispatchSemaphore(value: 0)
            
            db.collection("users").document(uid).getDocument(source: .default) { snap, err in
                
                if err != nil {
                    return
                }
                
                if snap?.exists == false {
                    semaphore.signal()
                }
                
                if let dict = snap?.data() as [String: AnyObject]?, let key = snap?.documentID {
                    
                    newUser = User(dict: dict, uid: key)
                    semaphore.signal()
                }
                
                // wait
                semaphore.wait()
                
                DispatchQueue.main.async {
                    completion(newUser)
                }
            }
        }
    }
    
    public func getUserDictFrom(_ userId: String?, completion: @escaping (_ result: Result<[String: AnyObject], Error>) -> ()) {
        
        if let uid = userId {
            
            db.collection("users").document(uid).getDocument(source: .default) { snap, err in
                
                if err != nil {
                    completion(.failure(FirestoreErrors.failedToFetch))
                    return
                }
                
                if let dict = snap?.data() as [String: AnyObject]? {
                    completion(.success(dict))
                }
            }
        }
    }
    
    public func setUserAdmin(_ isAdmin: Bool, userId: String) {
        
        let ref = db.collection("users").document(userId)
        
        if isAdmin {
            // update value
            ref.updateData([
                "isAdmin": true
            ])
            
        } else {
            // remove value
            ref.updateData([
                "isAdmin": FieldValue.delete()
            ])
        }
    }
}

// MARK: - Pets
extension FirestoreManager {
    
    public func insertPet(with dict: [String: AnyObject], images: [UIImage], completion: @escaping (_ success: Bool) -> ()) {
        
        let petId = UUID().uuidString
        
        StorageManager.shared.uploadPetImages(images, petId: petId) { [weak self] result in
            
            guard let strongSelf = self else {
                completion(false)
                return
            }
            
            switch result {
                
            case .success(let imagesUrl):
                
                let ref = strongSelf.db.collection("pets").document(petId)
                
                ref.setData(dict) { err in
                    
                    if err != nil {
                        completion(false)
                        return
                    }
                    
                    ref.updateData(["imagesUrl": imagesUrl]) { err in
                        
                        if err != nil {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
                
            case .failure(_):
                completion(false)
                return
            }
        }
    }
    
    public func removePet(with id: String, imagesCount: Int, completion: @escaping (_ success: Bool) -> ()) {
        
        db.collection("pets").document(id).delete { err in
            
            if err != nil {
                completion(false)
                return
            }
            
            StorageManager.shared.deletePetImages(with: id, count: imagesCount) { success in
                
                if !success {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    public func fetchUserPets(with type: String, completion: @escaping (_ result: Result<[Pet], Error>) -> Void) {
        
        guard let currentUserUid = currentUserUid else {
            return
        }
        
        var pets = [Pet]()
        
        let query: Query = db.collection("pets").whereField("userId", isEqualTo: currentUserUid).whereField("type", isEqualTo: type)
        
        let semaphore = DispatchSemaphore(value: 0)
         
        DispatchQueue.global(qos: .background).async {
            
            query.getDocuments(source: .default) { snap, err in
                
                if err != nil {
                    completion(.failure(FirestoreErrors.failedToFetch))
                    return
                }
                
                guard let snapshot = snap else {
                    completion(.failure(FirestoreErrors.failedToFetch))
                    return
                }
                
                if snapshot.isEmpty {
                    semaphore.signal()
                    return
                }
                
                for doc in snapshot.documents {
                    
                    if let dict = doc.data() as [String: AnyObject]? {
                        
                        let pet = Pet(dict: dict, petId: doc.documentID)
                        pets.append(pet)
                        semaphore.signal()
                    }
                }
            }
            
            // wait
            semaphore.wait()
            
            DispatchQueue.main.async {
                completion(.success(pets))
            }
        }
    }
    
    // TODO: - FIX. Return start point cursor.
    public func startPetsFetch(type: String, location: String, pageSize: Int, cursor: DocumentSnapshot? = nil, completion: @escaping (_ pets: [Pet], _ newCursor: DocumentSnapshot?, _ lastCursor: DocumentSnapshot?) -> ()) {
        
        guard let currentUserUid = currentUserUid else {
            return
        }
        
        var newCursor: DocumentSnapshot?
        var pets = [Pet]()
        
        var query = db.collection("pets")
            .whereField("type", isEqualTo: type)
            .whereField("location", isEqualTo: location)
            .whereField("userId", isNotEqualTo: currentUserUid)
        
        if cursor != nil {
            query = query.start(afterDocument: cursor!)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).async {
            
            query.limit(to: pageSize).getDocuments(source: .default) { snap, err in
                
                if err != nil {
                    completion(pets, nil, nil)
                    return
                }
                
                guard let snapshot = snap else {
                    completion(pets, nil, nil)
                    return
                }
                
                if snapshot.count < pageSize {
                    newCursor = nil
                    print("cursor: \(cursor?.reference.path)")
                } else {
                    newCursor = snapshot.documents.last
                    print("new cursor: \(newCursor?.reference.path)")
                }
                
                if snapshot.isEmpty {
                    semaphore.signal()
                    return
                }
                
                for doc in snapshot.documents {
                    
                    if let dict = doc.data() as [String: AnyObject]? {
                        
                        let pet = Pet(dict: dict, petId: doc.documentID)
                        pets.append(pet)
                        semaphore.signal()
                    }
                }
            }
            
            // wait before filtering
            semaphore.wait()
            
            print("PETS: \(pets)")
            // FILTERING
            PetFilterManager.shared.filterPets(pets) { filtered in
                
                DispatchQueue.main.async {
                    print("FILTERED: \(filtered)")
                    completion(filtered, newCursor, cursor)
                }
            }
        }
    }
    
    public func continuePetsFetch(type: String, location: String, cursor: DocumentSnapshot?, pageSize: Int, completion: @escaping (_ pets: [Pet], _ newCursor: DocumentSnapshot?, _ lastCursor: DocumentSnapshot?) -> ()) {
        
        var mayContinue = true
        
        var newCursor: DocumentSnapshot?
        var pets = [Pet]()
        
        guard mayContinue, let cursor = cursor, let currentUserUid = currentUserUid else {
            completion(pets, newCursor, cursor)
            return
        }
        
        mayContinue = false
        
        let query = db.collection("pets")
            .whereField("type", isEqualTo: type)
            .whereField("location", isEqualTo: location)
            .whereField("userId", isNotEqualTo: currentUserUid)
            .start(afterDocument: cursor).limit(to: pageSize)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).async {
            
            query.getDocuments(source: .default) { snap, err in
                
                if err != nil {
                    completion(pets, nil, nil)
                    return
                }
                
                guard let snapshot = snap else {
                    completion(pets, nil, nil)
                    return
                }
                
                print("last cursor: \(cursor.reference.path)")
                
                if snapshot.count < pageSize {
                    newCursor = nil
                    print("cursor: \(cursor.reference.path)")
                } else {
                    newCursor = snapshot.documents.last
                    print("new cursor: \(newCursor?.reference.path)")
                }
                
                if snapshot.isEmpty {
                    semaphore.signal()
                    return
                }
                
                for doc in snapshot.documents {
                    
                    if let dict = doc.data() as [String: AnyObject]? {
                        
                        let pet = Pet(dict: dict, petId: doc.documentID)
                        pets.append(pet)
                        semaphore.signal()
                    }
                }
            }
            
            // wait before filtering
            semaphore.wait()
            
            mayContinue = true
            
            print("PETS: \(pets)")
            // FILTERING
            PetFilterManager.shared.filterPets(pets) { filtered in
                
                DispatchQueue.main.async {
                    print("FILTERED: \(filtered)")
                    completion(filtered, newCursor, cursor)
                }
            }
        }
    }
    
    public func likePetWith(id: String, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let currentUserUid = currentUserUid else {
            completion(false)
            return
        }
        
        db.collection("pets").document(id).updateData([
            "likes": FieldValue.arrayUnion([currentUserUid])
        ]) { [weak self] err in
            
            if err != nil {
                completion(false)
                return
            }
            
            self?.db.collection("users").document(currentUserUid).updateData([
                "liked": FieldValue.arrayUnion([id])
            ], completion: { err in
                
                if err != nil {
                    completion(false)
                    return
                }
                
                completion(true)
            })
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
                            competion(.failure(FirestoreErrors.failedToFetch))
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
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let ref = db.collection("pets").document(id)
        DispatchQueue.global(qos: .background).async {
            
            ref.getDocument(source: .default) { document, err in
                
                guard err == nil, let document = document else {
                    return
                }
                
                if let fetchedLikes = document.get("likes") as? [String] {
                    likes = fetchedLikes
                    semaphore.signal()
                } else {
                    semaphore.signal()
                }
                
                // wait
                semaphore.wait()
                
                DispatchQueue.main.async {
                    completion(.success(likes))
                }
            }
        }
    }
    
    public func getLikedPetsIdsFromUser(with id: String, completion: @escaping (_ ids: [String]) -> ()) {
        
        var petIds = [String]()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let ref = db.collection("users").document(id)
        DispatchQueue.global(qos: .background).async {
            
            ref.getDocument(source: .default) { snap, err in
                
                if err != nil {
                    return
                }
                
                if snap?.get("liked") == nil {
                    semaphore.signal()
                }
                
                if let fetchedIds = snap?.get("liked") as? [String] {
                    petIds = fetchedIds
                    semaphore.signal()
                }
                
                // wait
                semaphore.wait()
                
                DispatchQueue.main.async {
                    completion(petIds)
                }
            }
        }
    }
    
    public func getPetInfoWith(_ id: String, completion: @escaping (_ pet: Pet) -> ()) {
        
        db.collection("pets").document(id).getDocument(source: .default) { snap, err in
            
            if err != nil {
                return
            }
            
            if let dict = snap?.data() as [String: AnyObject]? {
                let pet = Pet(dict: dict, petId: id)
                completion(pet)
            }
        }
    }
    
    public func getLikedPetsFromUser(with id: String, completion: @escaping (_ pets: [Pet]) -> ()) {
        
        var pets = [Pet]()
        
        let semaphore = DispatchSemaphore(value: 0)
        let group = DispatchGroup()
        
        DispatchQueue.global(qos: .background).async {
            
            var likedIds = [String]()
            
            // MARK: - TODO: - Fix
            self.getLikedPetsIdsFromUser(with: id) { ids in
                likedIds = ids
                semaphore.signal()
            }
            
            // wait
            semaphore.wait()
            
            for petId in likedIds {
                
                group.enter()
                
                self.getPetInfoWith(petId) { pet in
                    pets.append(pet)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                
                DispatchQueue.main.async {
                    completion(pets)
                }
            }
        }
    }
    
    public func removeLikedPetFromUser(with id: String, petId: String, completion: @escaping (_ success: Bool) -> ()) {
        
        db.collection("pets").document(petId).updateData([
            "likes": FieldValue.arrayRemove([id])
        ]) { err in
            
            if err != nil {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}

/*
  _____       _____
 /( )   \=== /     \----------------.
|       |   |       |--------------  \
|       |   |       |              \_/
 \_____/     \_____/
 
 */
