//
//  StorageManager.swift
//  Petfind
//
//  Created by Didami on 29/01/22.
//

import Foundation
import Firebase
import FirebaseStorage

final class StorageManager {

    static let shared = StorageManager()

    private init() {}

    private let storage = Storage.storage().reference()

    /// Uploads picture to firebase storage and returns completion with url string to download
    public func uploadImage(with data: Data, path: String, fileName: String, completion: @escaping (_ urlString: String) -> ()) {
        
        storage.child(path)
        
        storage.child("\(path)/\(fileName)").putData(data, metadata: nil, completion: { _, error in

            guard error == nil else {
                // failed
                return
            }

            self.storage.child("\(path)/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    return
                }

                let urlString = url.absoluteString
                completion(urlString)
            })
        })
    }

    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }

    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            completion(.success(url))
        })
    }
}

// MARK: - Pets
extension StorageManager {
    
    public func uploadPetImages(_ images: [UIImage], petId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        
        var imagesUrl = [String]() {
            didSet {
                
                if imagesUrl.count == images.count {
                    completion(.success(imagesUrl))
                }
            }
        }
        
        var x = 0
        
        for image in images {
            
            guard let data = image.jpegData(compressionQuality: 0.1) else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            StorageManager.shared.uploadImage(with: data, path: "pet_images/\(petId)", fileName: "\(x).jpg") { urlString in
                imagesUrl.append(urlString)
            }
            
            x += 1
        }
    }
    
    public func deletePetImages(with id: String, count: Int, completion: @escaping (_ success: Bool) -> ()) {
        
        let group = DispatchGroup()
        
        for x in 0...(count - 1) {
            group.enter()
            
            storage.child("pet_images").child(id).child("\(x).jpg").delete { err in
                
                if err != nil {
                    completion(false)
                    return
                }
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
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
