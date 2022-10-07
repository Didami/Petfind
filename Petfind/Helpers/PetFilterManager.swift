//
//  PetFilterManager.swift
//  Petfind
//
//  Created by Didami on 02/02/22.
//

import UIKit

final class PetFilterManager {
    
    static let shared = PetFilterManager()
    
    enum PetFilterError: Error {
        case invalidUid
        case nilValue
    }
    
    private init() { }
    
    // TODO: - FIX filtering (use group instead of semaphor may work).
//    public func filterPets(_ pets: [Pet], completion: @escaping (_ pets: [Pet]) -> Void) {
//
//        var filtered = [Pet]()
//
//        guard let userId = currentUserUid else {
//            return
//        }
//
//        let semaphore = DispatchSemaphore(value: 0)
//
//        DispatchQueue.global(qos: .background).async {
//
//            filtered = pets.filter({ $0.userId != userId })
//
//            FirestoreManager.shared.getLikedPetsIdsFromUser(with: userId) { ids in
//
//                if ids.isEmpty {
//                    semaphore.signal()
//                    return
//                }
//
//                for id in ids {
//                    filtered.removeAll(where: { $0.petId == id })
//                    semaphore.signal()
//                }
//            }
//
////            DatabaseManager.shared.getLikedPetsIdsFromUser(with: userId) { ids in
////            }
//
//            // wait
//            semaphore.wait()
//
//            guard let passedPetsIds = UserDefaults.standard.value(forKey: UserDefaultsKey.passedPetsIds.rawValue) as? [String: [String]] else {
//                completion(filtered)
//                return
//            }
//
//            guard let userPassedPetsId = passedPetsIds[userId] else  {
//                completion(filtered)
//                return
//            }
//
//            for id in userPassedPetsId {
//                filtered.removeAll(where: { $0.petId == id })
//                semaphore.signal()
//            }
//
//            // wait
//            semaphore.wait()
//
//            DispatchQueue.main.async {
//                completion(filtered)
//            }
//        }
//    }
    public func filterPets(_ pets: [Pet], completion: @escaping (_ pets: [Pet]) -> Void) {
        
        var filtered = [Pet]()
        
        guard let userId = currentUserUid else {
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        let group = DispatchGroup()
        
        DispatchQueue.global(qos: .background).async {
            
            filtered = pets.filter({ $0.userId != userId })
        
            var likedIds = [String]()
            
            FirestoreManager.shared.getLikedPetsIdsFromUser(with: userId) { ids in
                likedIds = ids
                semaphore.signal()
            }
            
            // wait
            semaphore.wait()
            
            for likedId in likedIds {
                filtered.removeAll(where: { $0.petId == likedId })
            }
            
            guard let passedPetsIds = UserDefaults.standard.value(forKey: UserDefaultsKey.passedPetsIds.rawValue) as? [String: [String]] else {
                completion(filtered)
                return
            }
            
            guard let userPassedPetsId = passedPetsIds[userId] else  {
                completion(filtered)
                return
            }
            
            for id in userPassedPetsId {
                group.enter()
                filtered.removeAll(where: { $0.petId == id })
                group.leave()
            }
            
            group.notify(queue: .main) {
                semaphore.signal()
            }
            
            // wait
            semaphore.wait()
            
            DispatchQueue.main.async {
                completion(filtered)
            }
        }
    }

    public func passPet(with petId: String, userId: String) {
        
        var passedPetsIds = UserDefaults.standard.value(forKey: UserDefaultsKey.passedPetsIds.rawValue) as? [String: [String]]
        
        if passedPetsIds == nil {
            UserDefaults.standard.set([userId: [petId]], forKey: UserDefaultsKey.passedPetsIds.rawValue)
            return
        }
        
        guard var userPassedPetsId = passedPetsIds?[userId] else {
            
            passedPetsIds?[userId] = [petId]
            
            UserDefaults.standard.set(passedPetsIds, forKey: UserDefaultsKey.passedPetsIds.rawValue)
            
            return
        }
        
        userPassedPetsId.append(petId)
        passedPetsIds?[userId] = userPassedPetsId
        
        UserDefaults.standard.set(passedPetsIds, forKey: UserDefaultsKey.passedPetsIds.rawValue)
    }
}
